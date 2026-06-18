--Known issues:
--  Single train going through 2 elevators at once won't have its schedule cached and restored correctly. It will lose its interrupts but otherwise works properly.
--  Modifying a train's schedule when its in progress of being transferred won't be saved.
--    Schedules are saved at start and restored at end. In between, interrupts are removed and behind train is set to elevator only.
--    Needed to ensure interrupts do not trigger mid transfer due to the transfer and rear train has its locomotives still applying force.
--  Train will not stop at a station if it is still traversing the elevator.
--    Schedules are copied each carriage, including current stop. Even without this, train.state doesn't update until the following tick even
--    with a forced recalculate which means we can't update speeds every tick. Even with all of this worked around, cloning a carriage can push
--    the front past the station leaving it unfixable.

--Notes:
--  Contact with the collider starts the traversal
--  Collider only respawns when traversal is complete
--  elevator.collider.valid <=> not elevator.carriage_behind
--  train will be split iff:
--    carriage_ahead is far enough to fit another carriage but carriage_next.clone failed
--    a carriage was placed behind the rear carriage of train_ahead or ahead of the front carriage of train_behind
--      effectively placing a carriage in the middle of the train
--    carriage_ahead or carriage_behind was destroyed
--    elevator runs low on cables
--    elevator runs out of power
--    train_behind travels away from the elevator
--  elevator.carriage_ahead dictates if a transfer has been started and whether to fire on_teleport_start/finish events
--  on_train_teleport_started is always followed by a on_train_teleport_finished even on entity destruction
--  schedules are cached during transfer with only the basic records (no interrupts) restored until transfer complete
--    this means schedules cannot be altered mid transfer as they will be restored afterward
--  tug is only created if no other locomotive on train_ahead faces forward yet
--  tug is small enough that if a player tries to connect rolling stock behind it, the tug will be destroyed and 
--    the new rolling stock should still connect to the existing train
--  do not cache schedule's manual_mode as enabling manual mode mid transfer is the only way for a player to clear a train that can't path
--  "blocker" is placed at the edge of a space elevator which is a carriage that does nothing but is placed via blueprint which can have
--    its automatic connections disabled. This guarantees newly teleporting trains cannot connect to a train in front as they will connect
--    to the blocker instead

local SpaceElevator = {}

SpaceElevator.on_train_teleport_started_event = util.get_custom_event("on_train_teleport_started")
SpaceElevator.on_train_teleport_finished_event = util.get_custom_event("on_train_teleport_finished")
SpaceElevator.on_space_elevator_changed_state_event = util.get_custom_event("on_space_elevator_changed_state")

-- start at the higher end for now then reduce until competitive.
SpaceElevator.maintenance_min_multiplier = 0.25 -- 25%, 100% for a max gravity planet
SpaceElevator.maintenance_per_stack_up = 0.005 -- at max gravity.
SpaceElevator.maintenance_per_stack_down = 0.001 -- at max gravity.
SpaceElevator.maintenance_per_second = 0.1
-- these are way too low for now
SpaceElevator.energy_per_stack_up = -2000000
SpaceElevator.energy_per_stack_down = 1000000 -- recharge the battery
SpaceElevator.energy_buffer = 10000000000
SpaceElevator.interface_energy_buffer = SpaceElevator.energy_buffer/2 -- for the entity
SpaceElevator.energy_passive_draw = SpaceElevator.energy_buffer/1000 --10MJ
SpaceElevator.energy_min = .25 * SpaceElevator.energy_buffer

SpaceElevator.parts_per_radius = 0.2 -- 8.3 minutes for max radius
SpaceElevator.parts_display_threshold = 0.98

-- lower bound of speed through elevator depending on manual_mode
SpaceElevator.passive_train_speed = {
  [true] = 0.1,
  [false] = 0.1 / 4
}
SpaceElevator.max_train_speed = 1
SpaceElevator.player_teleport_distance = 15

SpaceElevator.teleport_next_tick_frequency = 4

local east = defines.direction.east
local west = defines.direction.west

SpaceElevator.stock_types =  {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}
SpaceElevator.stock_types_map = core_util.list_to_map(SpaceElevator.stock_types)
SpaceElevator.name_space_elevator = mod_prefix.."space-elevator"
SpaceElevator.name_energy_interface = mod_prefix.."space-elevator-energy-interface"
SpaceElevator.name_space_elevator_overlay_left = mod_prefix.."space-elevator-left"
SpaceElevator.name_space_elevator_overlay_right = mod_prefix.."space-elevator-right"
SpaceElevator.name_space_elevator_train_collider = mod_prefix.."space-elevator-train-collider"

SpaceElevator.name_sound_carriage_up = mod_prefix.."sound-elevator-carriage-up"
SpaceElevator.name_sound_carriage_down = mod_prefix.."sound-elevator-carriage-down"
SpaceElevator.name_sound_train_up = mod_prefix.."sound-elevator-train-up"
SpaceElevator.name_sound_train_down = mod_prefix.."sound-elevator-train-down"
SpaceElevator.name_sound_train_start = mod_prefix.."sound-elevator-train-start"
SpaceElevator.name_sound_train_stop = mod_prefix.."sound-elevator-train-stop"

SpaceElevator.name_connection_blocker = mod_prefix .. "space-elevator-connection-blocker"
SpaceElevator.name_tug = mod_prefix.."space-elevator-tug"
SpaceElevator.name_part = mod_prefix.."space-elevator-cable"
-- radius of space elevator entity
SpaceElevator.space_elevator_radius = 12
-- radius of outer edge of tracks
SpaceElevator.space_elevator_hypertrain_radius = 12
-- radius of track centerline
SpaceElevator.space_elevator_hypertrain_rail_radius = SpaceElevator.space_elevator_hypertrain_radius - 1
-- y offset from main entity to center circle whose circumference is the track
SpaceElevator.space_elevator_rail_base_offset_y = -8

SpaceElevator.output_rail_circle_offset = {
  [east] = {x =  SpaceElevator.space_elevator_hypertrain_radius, y = SpaceElevator.space_elevator_rail_base_offset_y},
  [west] = {x = -SpaceElevator.space_elevator_hypertrain_radius, y = SpaceElevator.space_elevator_rail_base_offset_y}
}
SpaceElevator.input_rail_circle_offset = {
  [east] = {x = -SpaceElevator.space_elevator_hypertrain_radius, y = SpaceElevator.space_elevator_rail_base_offset_y},
  [west] = {x =  SpaceElevator.space_elevator_hypertrain_radius, y = SpaceElevator.space_elevator_rail_base_offset_y}
}
SpaceElevator.blocker_offset = {
  [east] = Util.vectors_add(SpaceElevator.output_rail_circle_offset[east], {x = 0, y = SpaceElevator.space_elevator_hypertrain_rail_radius}),
  [west] = Util.vectors_add(SpaceElevator.output_rail_circle_offset[west], {x = 0, y = SpaceElevator.space_elevator_hypertrain_rail_radius})
}
-- length of tug plus buffer
SpaceElevator.tug_length = (prototypes.entity[SpaceElevator.name_tug].connection_distance + prototypes.entity[SpaceElevator.name_tug].joint_distance) / SpaceElevator.space_elevator_hypertrain_rail_radius + util.pi_div_16
SpaceElevator.space_elevator_collider_position = {
  [east] = {x=-2, y=-4},
  [west] = {x= 2, y=-4}
}
SpaceElevator.space_elevator_output_rect = {
  [east] = {left_top={x=0, y=-12}, right_bottom={x=12,y=12}},
  [west] = {left_top={x=-12, y=-12}, right_bottom={x=0,y=12}},
}
-- check farther out in case where blocker doesn't work
SpaceElevator.space_elevator_output_scan_rect = {
  [east] = {left_top={x=12, y=-12}, right_bottom={x=16, y=12}},
  [west] = {left_top={x=-16, y=-12}, right_bottom={x=-12, y=12}}
}

-- angle covering distance of collider
SpaceElevator.behind_compensator_angle = (
    -(SpaceElevator.space_elevator_rail_base_offset_y - SpaceElevator.space_elevator_collider_position[west].y) + --distance to center of collider
    prototypes.entity[SpaceElevator.name_space_elevator_train_collider].collision_box.right_bottom.y --distance from center of collider to edge of collider
  ) / SpaceElevator.space_elevator_hypertrain_rail_radius

SpaceElevator.internals = {
  shared = {
    ["se-space-elevator-blocker-vertical"] = {
      { position = {x=-10.85, y=-4.85}, direction = defines.direction.north },
      { position = {x=-10.85, y=7.85}, direction = defines.direction.north },
      { position = {x=-10.85, y=-2}, direction = defines.direction.north },
      { position = {x=10.85, y=7.85}, direction = defines.direction.north },
      { position = {x=10.85, y=-4.85}, direction = defines.direction.north },
      { position = {x=10.85, y=-2}, direction = defines.direction.north },
    },
    ["se-space-elevator-blocker-horizontal"] = {
      { position = {x=0, y=10.85}, direction = defines.direction.east },
      { position = {x=-7.85, y=10.85}, direction = defines.direction.east },
      { position = {x=7.85, y=10.85}, direction = defines.direction.east },
      { position = {x=0, y=-7.85}, direction = defines.direction.east },
      { position = {x=-7.85, y=-7.85}, direction = defines.direction.east },
      { position = {x=7.85, y=-7.85}, direction = defines.direction.east },
    },
    ["se-space-elevator-legacy-straight-rail"] = {
      { position = {x=-5.5, y=-1.5}, direction = defines.direction.southeast },
      { position = {x=4.5, y=-1.5}, direction = defines.direction.southwest },
    },
    ["se-space-elevator-legacy-curved-rail"] = {
      { position = {x=2, y=-4}, direction = defines.direction.south, railend_output_when_facing = defines.direction.east },
      { position = {x=-2, y=-4}, direction = defines.direction.southwest, railend_output_when_facing = defines.direction.west },
      { position = {x=8, y=2}, direction = defines.direction.northwest },
      { position = {x=-8, y=2}, direction = defines.direction.east },
    },
    ["se-space-elevator-lamp"] = {
      { position = {x=0, y=0}, direction = defines.direction.north },
    },
    ["se-space-elevator-energy-interface"] = {
      { position = {x=0, y=0}, direction = defines.direction.north },
    },
    ["se-space-elevator-energy-pole"] = {
      { position = {x=0, y=0}, direction = defines.direction.north },
    },
    ["se-space-elevator-power-switch"] = {
      { position = {x=0, y=0}, direction = defines.direction.north, primary_only = true },
    },
  },
  [east] = {
    ["se-space-elevator-legacy-straight-rail"] = {
      { position = {x=-1, y=-9}, direction = defines.direction.north, railend_input = true },
    },
    ["se-space-elevator-rail-signal"] = {
      { position = {x=-11.5, y=4.5}, direction = defines.direction.west },
      { position = {x=11.5, y=4.5}, direction = defines.direction.west },
    },
    ["se-space-elevator-train-stop"] = {
      { position = {x=1, y=-9}, direction = defines.direction.north },
    },
  },
  [west] = {
    ["se-space-elevator-legacy-straight-rail"] = {
      { position = {x=1, y=-9}, direction = defines.direction.north, railend_input = true },
    },
    ["se-space-elevator-rail-signal"] = {
      { position = {x=-11.5, y=1.5}, direction = defines.direction.east },
      { position = {x=11.5, y=1.5}, direction = defines.direction.east },
    },
    ["se-space-elevator-train-stop"] = {
      { position = {x=3, y=-9}, direction = defines.direction.north },
    },
  }
}

-- Holds inventory size used for maintenance calculations
SpaceElevator.inventory_size = {}

-- Holds carriage half lengths for determining optimial position to spawn a new carriage
SpaceElevator.carriage_half_length_angle = {}

-- draw the part the sits over the train.
---@param elevator SpaceElevatorInfo
function SpaceElevator.draw_top(elevator)
  rendering.draw_sprite{
    surface = elevator.surface,
    sprite = elevator.elevator_struct.direction == east and SpaceElevator.name_space_elevator_overlay_right or SpaceElevator.name_space_elevator_overlay_left,
    render_layer = "under-elevated",
    target = elevator.main,
  }
end

---Builds and caches entities
---@param elevator SpaceElevatorInfo
function SpaceElevator.setup_elevator(elevator)
  local struct = elevator.elevator_struct
  local sub_entities = {}
  for _, entity_set in pairs({SpaceElevator.internals.shared, SpaceElevator.internals[struct.direction]}) do
    for proto_name, placements in pairs(entity_set) do
      for _, placement in pairs(placements) do
        if (elevator == struct.primary) or (not placement.primary_only) then
          local sub_entity = elevator.surface.create_entity{
            name = proto_name,
            position = Util.vectors_add(struct.position, placement.position),
            direction = placement.direction,
            force = struct.force_name
          }
          ---@cast sub_entity -?
          sub_entity.destructible = false
          if sub_entity.type == "train-stop" then
            if (elevator == struct.primary) then
              sub_entity.backer_name = "[img=entity/"..SpaceElevator.name_space_elevator.."]  " .. struct.name .. " ↑"
            else
              sub_entity.backer_name = "[img=entity/"..SpaceElevator.name_space_elevator.."]  " .. struct.name .. " ↓"
            end
            elevator.station = sub_entity
            elevator.station_connected_rail = sub_entity.connected_rail
          elseif sub_entity.type == "electric-energy-interface" then
            if sub_entity.name == SpaceElevator.name_energy_interface then
              elevator.energy_interface = sub_entity
            end
            sub_entity.power_usage = 0
            sub_entity.energy = 0
            sub_entity.electric_buffer_size = SpaceElevator.interface_energy_buffer
          elseif sub_entity.type == "electric-pole" then
            elevator.electric_pole = sub_entity
            elevator.electric_pole_copper = sub_entity.get_wire_connector(defines.wire_connector_id.pole_copper, true)
            elevator.electric_pole_red = sub_entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
            elevator.electric_pole_green = sub_entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
          elseif sub_entity.type == "power-switch" then
            sub_entity.power_switch_state = true
            struct.power_switch = sub_entity
            struct.power_switch_left = sub_entity.get_wire_connector(defines.wire_connector_id.power_switch_left_copper, true)
            struct.power_switch_right = sub_entity.get_wire_connector(defines.wire_connector_id.power_switch_right_copper, true)
          elseif sub_entity.name == "se-space-elevator-legacy-curved-rail" and placement.railend_output_when_facing == struct.direction then
            elevator.opposite_elevator.output_railend = sub_entity.get_rail_end(defines.rail_direction.front)
          elseif sub_entity.name == "se-space-elevator-legacy-straight-rail" and placement.railend_input then
            elevator.input_railend = sub_entity.get_rail_end(defines.rail_direction.front)
          end
          table.insert(sub_entities, sub_entity)
        end
      end
    end
  end
  elevator.sub_entities = sub_entities

  elevator.collider = elevator.surface.create_entity{
    name = SpaceElevator.name_space_elevator_train_collider,
    position = struct.collider_position,
    force = "neutral"
  }

  storage.space_elevators[elevator.unit_number] = elevator
  SpaceElevator.draw_top(elevator)
  script.register_on_object_destroyed(elevator.main)

  -- move character out of the way.
  local characters = elevator.surface.find_entities_filtered{type = "character", area = util.position_to_area(struct.position, SpaceElevator.space_elevator_radius)}
  for _, character in pairs(characters) do
    teleport_non_colliding(character, character.position, 12, 0.5)
  end
end

---Gets info for export via remote.call
---@param unit_number number
---@return table?
function SpaceElevator.get_export_info(unit_number)
  local elevator = storage.space_elevators[unit_number]
  if not elevator then return end
  return {
    main = elevator.main,
    train_stop = elevator.station,
    opposite = elevator.opposite_elevator.main,
    constructed = elevator.elevator_struct.constructed,
    powered = elevator.elevator_struct.powered
  }
end

---@param struct SpaceElevatorStruct
---@param new_name string
function SpaceElevator.rename(struct, new_name)
  struct.name = new_name
  local station_name_base = "[img=entity/"..SpaceElevator.name_space_elevator.."]  " .. struct.name
  struct.primary.station.backer_name = station_name_base .. " ↑"
  struct.secondary.station.backer_name = station_name_base .. " ↓"
  -- TODO: update open UIs
end

---@param tile_position TilePosition
---@param tilebox table<string, MapPosition>
local function add_position_to_tilebox(tile_position, tilebox)
  tilebox[core_util.positiontostr(tile_position)] = {x = tile_position.x + 0.5, y = tile_position.y + 0.5}
end

---@param bounding_box BoundingBox
---@param tilebox table<string, MapPosition>
local function add_area_to_tilebox(bounding_box, tilebox)
  local left_top = {x = math.floor(bounding_box.left_top.x), y = math.floor(bounding_box.left_top.y)}
  local right_bottom = {x = math.ceil(bounding_box.right_bottom.x), y = math.ceil(bounding_box.right_bottom.y)}

  for y = left_top.y, right_bottom.y - 1 do
    for x = left_top.x, right_bottom.x - 1 do
      add_position_to_tilebox({x = x, y = y}, tilebox)
    end
  end
end

---@param this_surface LuaSurface
---@param other_surface LuaSurface
---@param position MapPosition
---@param force LuaForce
function SpaceElevator.render_invalid_placement(this_surface, other_surface, position, force)
  local shift = 0.125
  local area = {
    left_top = util.vectors_add(position, {x = -SpaceElevator.space_elevator_radius+shift, y = -SpaceElevator.space_elevator_radius+shift}),
    right_bottom = util.vectors_add(position, {x = SpaceElevator.space_elevator_radius-shift, y = SpaceElevator.space_elevator_radius-shift}),
  }

  for _, surface in pairs({this_surface, other_surface}) do
    rendering.draw_rectangle{
      surface = surface,
      filled = false,
      width = 8,
      color = {r = 0.1, g = 0.1, b = 0, a = 0.01},
      left_top = area.left_top,
      right_bottom = area.right_bottom,
      time_to_live = 10 * 60,
      forces = {force},
    }
  end

  local tilebox = {}

  local entities = other_surface.find_entities_filtered{
    area = area, -- technically slightly larger than the collission box, but this code only gets triggered upon failure anyways
    collision_mask = prototypes.entity[mod_prefix .. "space-elevator"].collision_mask.layers,
  }
  for _, entity in ipairs(entities) do
    add_area_to_tilebox(entity.bounding_box, tilebox)
  end

  local tiles = other_surface.find_tiles_filtered{
    area = area, -- technically slightly larger than the collission box, but this code only gets triggered upon failure anyways
    collision_mask = prototypes.entity[mod_prefix .. "space-elevator"].collision_mask.layers,
  }
  for _, tile in ipairs(tiles) do
    add_position_to_tilebox(tile.position, tilebox)
  end

  for _, center_of_tile in pairs(tilebox) do
    rendering.draw_sprite{
      surface = this_surface,
      target = center_of_tile,
      sprite = "utility/buildability_collision",
      time_to_live = 10 * 60,
      forces = {force},
    }
  end
end

---Handles creation of space elevator structure
---@param event EntityCreationEvent Event data
function SpaceElevator.on_entity_created(event)
  local entity = event.entity
  if not entity.valid then return end
  if not (
    entity.name == SpaceElevator.name_space_elevator or
    (entity.type == "entity-ghost" and entity.ghost_name == SpaceElevator.name_space_elevator))
  then
    return
  end

  local player_index = event.player_index
  local is_ghost = entity.type == "entity-ghost"
  local surface = entity.surface
  local force = entity.force
  local force_name = entity.force.name
  local zone = Zone.from_surface(entity.surface)

  if cancel_creation_when_invalid(zone, entity, event) then return end
  ---@cast zone -?

  if not RemoteView.is_intersurface_unlocked_force(force_name) then
    cancel_entity_creation(entity, player_index, RemoteView.intersurface_unlock_requirement_string_2(force_name, "space-exploration.space-elevator-requires-satellite"), event)
    return
  end

  local opposite_zone
  if Zone.is_solid(zone) then
    ---@cast zone PlanetType|MoonType
    opposite_zone = zone.orbit
  elseif zone.type == "orbit" and Zone.is_solid(zone.parent) then
    ---@cast zone OrbitType
    opposite_zone = zone.parent
  else
    ---@cast zone -PlanetType, -MoonType
    cancel_entity_creation(entity, player_index, {"space-exploration.space-elevator-placement-invalid-zone"}, event)
    return
  end
  local opposite_surface = Zone.get_make_surface(opposite_zone)
  if not opposite_surface then
    cancel_entity_creation(entity, player_index, "The opposite surface (planet vs orbit) could not be found.", event)
    return
  end

  local direction -- direction of travel, 2-way rotation
  local position = entity.position
  if entity.direction == defines.direction.east or entity.direction == defines.direction.south then
    direction = east
  else
    direction = west
  end

  opposite_surface.request_to_generate_chunks(position, 2)
  opposite_surface.force_generate_chunk_requests()

  if is_ghost then
    if not opposite_surface.can_place_entity{
      name = SpaceElevator.name_space_elevator,
      position = position,
      direction = direction,
      force = force
    } then
      if player_index then
        game.get_player(player_index).print({
          "space-exploration.space-elevator-placement-invalid-opposite-alert",
          util.gps_tag(opposite_surface.name, position)
        })
        SpaceElevator.render_invalid_placement(surface, opposite_surface, position, force)
      end
      cancel_entity_creation(entity, player_index, {"space-exploration.space-elevator-placement-invalid-opposite"}, event)
    end

    return
  end

  -- real version only beyond this point

  if direction ~= entity.direction then
    local old_entity = entity
    entity = surface.create_entity{
      name = SpaceElevator.name_space_elevator,
      position = position,
      direction = direction,
      force = force
    }
    ---@cast entity -?
    old_entity.destroy()
  end

  -- returns nil on failed create
  local opposite_entity = opposite_surface.create_entity{
    name = SpaceElevator.name_space_elevator,
    position = position,
    direction = direction,
    force = force
  }

  if not opposite_entity then
    if player_index then
      game.get_player(player_index).print({
        "space-exploration.space-elevator-placement-invalid-opposite-alert",
        util.gps_tag(opposite_surface.name, position)
      })
      SpaceElevator.render_invalid_placement(surface, opposite_surface, position, force)
    end
    cancel_entity_creation(entity, player_index, {"space-exploration.space-elevator-placement-invalid-opposite"}, event)
    return
  end

  ---@type SpaceElevatorInfo
  local elevator = {
    unit_number = entity.unit_number,
    surface = surface,
    last_crafts = 0,
    main = entity,
    zone = zone,
    opposite_elevator = nil,
  }
  ---@type SpaceElevatorInfo  
  local opposite_elevator = {
    unit_number = opposite_entity.unit_number,
    surface = opposite_surface,
    last_crafts = 0,
    main = opposite_entity,
    zone = opposite_zone,
    opposite_elevator = elevator,
  }
  elevator.opposite_elevator = opposite_elevator
  local primary = Zone.is_solid(zone) and elevator or opposite_elevator
  local secondary = primary.opposite_elevator

  local maintenance_cost = (SpaceElevator.maintenance_min_multiplier + (1-SpaceElevator.maintenance_min_multiplier) * primary.zone.radius / 10000 )
  primary.maintenance_per_stack = SpaceElevator.maintenance_per_stack_up * maintenance_cost
  secondary.maintenance_per_stack = SpaceElevator.maintenance_per_stack_down * maintenance_cost
  primary.energy_per_stack = SpaceElevator.energy_per_stack_up * maintenance_cost
  secondary.energy_per_stack = SpaceElevator.energy_per_stack_down * maintenance_cost

  ---@type SpaceElevatorStruct
  local struct = {
    primary = primary,
    secondary = secondary,
    parts = 0,
    constructed = false,
    powered = false,
    above_threshold = false,
    name = primary.zone.name,
    total_energy = 0, -- cached for reading
    lua_energy = 0, -- the lua energy buffer
    force_name = force_name,
    direction = direction,
    collider_position = Util.vectors_add(SpaceElevator.space_elevator_collider_position[direction], position),
    position = position,
    parts_needed = SpaceElevator.parts_per_radius * primary.zone.radius,
    direction_sign = direction == west and 1 or -1,
    output_rail_circle_offset = Util.vectors_add(SpaceElevator.output_rail_circle_offset[direction], position),
    input_rail_circle_offset = Util.vectors_add(SpaceElevator.input_rail_circle_offset[direction], position),
    output_area = Util.area_add_position(SpaceElevator.space_elevator_output_rect[direction], position),
    output_scan_area = Util.area_add_position(SpaceElevator.space_elevator_output_scan_rect[direction], position),
    blocker_position = Util.vectors_add(SpaceElevator.blocker_offset[direction], position),
    parts_per_second = SpaceElevator.maintenance_per_second * maintenance_cost,
    disabled = false
  }
  struct.rail_radius_multiplier = SpaceElevator.space_elevator_hypertrain_rail_radius * struct.direction_sign
  struct.parts_threshold = struct.parts_needed * SpaceElevator.parts_display_threshold

  elevator.elevator_struct = struct
  opposite_elevator.elevator_struct = struct

  SpaceElevator.setup_elevator(elevator)
  SpaceElevator.setup_elevator(opposite_elevator)

  -- find open spot in array. Order and packing is irrelevant but idx should be maintained once set.
  local idx = 1
  while storage.space_elevator_structs[idx] do
    idx = idx + 1
  end
  struct.index = idx
  storage.space_elevator_structs[idx] = struct

  SpaceElevator.set_parts_icon_and_text(struct, "se-danger-parts")
end
Event.addOnEntityCreatedListeners(SpaceElevator.on_entity_created)

---Detects collision with collider to start a train transfer
---@param event EventData.on_entity_died Event data
function SpaceElevator.on_entity_died(event)
  local entity = event.entity
  if not entity.valid or entity.name ~= SpaceElevator.name_space_elevator_train_collider then return end

  -- something has hit a train collider.
  local carriage_behind = event.cause
  if not carriage_behind or not carriage_behind.valid then return end

  -- find correct struct
  local elevator_entity = entity.surface.find_entities_filtered{
    name = SpaceElevator.name_space_elevator,
    position = entity.position,
    limit = 1
  }[1]
  local elevator = storage.space_elevators[elevator_entity.unit_number]

  if not SpaceElevator.stock_types_map[carriage_behind.type] then
    -- something else broke it, just replace it
    elevator.collider = elevator.surface.create_entity{
      name = SpaceElevator.name_space_elevator_train_collider,
      position = elevator.elevator_struct.collider_position,
      force = "neutral"
    }
  else
    -- its a train
    elevator.carriage_behind = carriage_behind
    elevator.train_behind = carriage_behind.train
    elevator.train_behind_weight = elevator.train_behind.weight
    elevator.train_behind_id = elevator.train_behind.id
    elevator.behind_forward_sign = SpaceElevator.get_behind_forward_sign(elevator)
    storage.space_elevator_train_behind[carriage_behind.train.id] = elevator

    SpaceElevator.space_elevator_teleport_start(elevator, event.tick)
  end
end
Event.addListener(defines.events.on_entity_died, SpaceElevator.on_entity_died)

---Initial checks to start a train transfer
---@param elevator SpaceElevatorInfo
---@param tick integer
function SpaceElevator.space_elevator_teleport_start(elevator, tick)
  local struct = elevator.elevator_struct
  -- only start a new train if the minimum energy is satisfied
  if not struct.constructed or not struct.powered then
    SpaceElevator.delay_transfer(elevator)
    return
  end

  -- Check for banned items
  if next(storage.items_banned_from_transport) then
    local banned_items = find_items_banned_from_transport(elevator.train_behind)
    if next(banned_items) then
      local gps_tag = util.gps_tag(elevator.carriage_behind.surface.name, elevator.carriage_behind.position)
      if (tick + elevator.unit_number) % (SpaceElevator.teleport_next_tick_frequency * 80) == 0 then
        elevator.carriage_behind.force.print({"space-exploration.banned-items-in-train", gps_tag, serpent.line(banned_items)})
      end
      SpaceElevator.delay_transfer(elevator)
      return
    end
  end

  -- make sure the entire area is clear so we don't attach to another train
  if elevator.opposite_elevator.surface.count_entities_filtered{
      type = SpaceElevator.stock_types,
      area = struct.output_area,
      limit = 1
    } > 0 then
    SpaceElevator.delay_transfer(elevator)
    return
  end

  -- place a blocker carriage so that new carriages cannot connect to existing trains
  local blocker_ghost = storage.space_elevator_blocker_blueprint.build_blueprint{
    surface = elevator.opposite_elevator.surface,
    force = elevator.carriage_behind.force,
    position = struct.blocker_position
  }[1]
  if blocker_ghost then
    local _
    _, elevator.blocker, _ = blocker_ghost.silent_revive()
  end
  if not elevator.blocker then
    if blocker_ghost then blocker_ghost.destroy() end
    -- may fail due to ghost rail adjacent to output rail https://forums.factorio.com/viewtopic.php?p=692459
    if elevator.opposite_elevator.surface.count_entities_filtered{
        type = SpaceElevator.stock_types,
        area = struct.output_scan_area,
        limit = 1
      } > 0 then
      SpaceElevator.delay_transfer(elevator)
      return
    end
  end

  -- clear to attempt teleport
  local output_position
  local carriage_next = elevator.carriage_behind.get_connected_rolling_stock(defines.rail_direction.back) or elevator.carriage_behind.get_connected_rolling_stock(defines.rail_direction.front)
  if carriage_next then
    --calculate max angle carriage for this train
    local max_angle = 0
    for _, carriage in pairs(elevator.train_behind.carriages) do
      half_angle = SpaceElevator.carriage_half_length_angle[carriage.name]
      if half_angle > max_angle then
        max_angle = half_angle
      end
    end
    --We need space for the full length of new stock, and full length of a tug
    local ahead_compensator_angle = 2 * max_angle + SpaceElevator.tug_length
    -- Solve for the angular distance between ahead and behind stocks to try to maintain
    elevator.carriage_compensator_angle = ahead_compensator_angle + SpaceElevator.behind_compensator_angle

    --calculate location based on speed compensator
    local input_position_offset = Util.vectors_delta(struct.input_rail_circle_offset, carriage_next.position)
    local behind_angle = Util.half_pi + struct.direction_sign * math.atan2(input_position_offset.x, input_position_offset.y)
    local ahead_angle = elevator.carriage_compensator_angle + SpaceElevator.carriage_half_length_angle[carriage_next.name] + SpaceElevator.carriage_half_length_angle[elevator.carriage_behind.name]
    local output_position_offset = Util.half_pi + behind_angle - ahead_angle
    output_position_offset = math.max(output_position_offset, max_angle + util.pi_div_16)
    output_position = SpaceElevator.angle_to_position(output_position_offset, struct)
  else
    -- single carriage train
    output_position = SpaceElevator.angle_to_position(SpaceElevator.carriage_half_length_angle[elevator.carriage_behind.name] + util.pi_div_16, struct)
  end
  -- transfer the carriage
  SpaceElevator.space_elevator_teleport_next(elevator, output_position, carriage_next)
end

---cache carriage lengths
---cache inventory sizes
---get max angle difference from 0 point to spawn carriages based on longest carriage
function SpaceElevator.setup_data_caches()
  local filter = {}
  for _, stock_type in pairs(SpaceElevator.stock_types) do
    table.insert(filter, {filter="type", type=stock_type})
  end
  for name, prototype in pairs(prototypes.get_entity_filtered(filter)) do
    -- half lengths
    local half_length = (prototype.connection_distance + prototype.joint_distance) / 2 / SpaceElevator.space_elevator_hypertrain_rail_radius
    SpaceElevator.carriage_half_length_angle[name] = half_length

    --setup inventory sizes
    local inventory_size
    if prototype.type == "cargo-wagon" then
      inventory_size = 5 + (prototype.get_inventory_size(defines.inventory.cargo_wagon) or 0)
    elseif prototype.type == "fluid-wagon" then
      inventory_size = 5 + prototype.fluid_capacity / 650
    elseif  prototype.type == "artillery-wagon" then
      inventory_size = 10 + (prototype.get_inventory_size(defines.inventory.artillery_turret_ammo) or 0)
        + (prototype.get_inventory_size(defines.inventory.artillery_turret_ammo) or 0)
    else
      inventory_size = 5 + (prototype.get_inventory_size(defines.inventory.fuel) or 0)
    end
    SpaceElevator.inventory_size[name] = inventory_size
  end
end

---Completes transfer and reverts elevator back to default state
---carriage_behind and train_behind must be set appropriately before calling this function
---@param elevator SpaceElevatorInfo
function SpaceElevator.finish_teleport(elevator)
  local carriage_ahead = elevator.carriage_ahead
  if carriage_ahead then
    elevator.carriage_ahead = nil
    local carriage_behind = elevator.carriage_behind
    local struct = elevator.elevator_struct
    local train_ahead = elevator.train_ahead
    ---@cast train_ahead -?
    storage.space_elevator_train_ahead[elevator.train_ahead_id] = nil

    elevator.surface.create_entity{
      name = SpaceElevator.name_sound_train_stop,
      position = struct.position
    }
    elevator.opposite_elevator.surface.create_entity{
      name = SpaceElevator.name_sound_train_stop,
      position = struct.position
    }

    if elevator.tug then
      elevator.tug.destroy()
      elevator.tug = nil
      train_ahead = carriage_ahead.train
    end

    -- fully replace the new schedule
    for _, train in pairs{train_ahead, carriage_behind and elevator.train_behind} do
      local schedule = train.get_schedule()
      if elevator.schedule_group then
        -- this prevents interrupts from firing the instant group is set but before current_stop
        train.manual_mode = true
        schedule.group = elevator.schedule_group
        --setting the group sets non-temporary schedule records and interrupts. Add remaining temporary stops.
        for idx, record in pairs(elevator.schedule_records) do
          ---@cast record AddRecordData
          if record.temporary then
            record.index = {schedule_index = idx}
            schedule.add_record(record)
          end
        end
        if next(elevator.schedule_interrupts) and schedule.interrupt_count == 0 then
          -- can happen when all trains belonging to this group have their group membership removed
          schedule.set_interrupts(elevator.schedule_interrupts)
        end
      else
        schedule.set_records(elevator.schedule_records)
        schedule.set_interrupts(elevator.schedule_interrupts)
      end
      if next(elevator.schedule_records) then
        schedule.go_to_station(elevator.schedule_current)
      end
    end
    if carriage_behind then
      -- train was split, force manual mode
      elevator.train_behind.manual_mode = true
      train_ahead.manual_mode = true
    end

    -- Raise on_train_teleport_finished event after the last carriage is created on the new surface and the elevator is reset.
    script.raise_event(SpaceElevator.on_train_teleport_finished_event,
      {
        train = train_ahead,
        old_train_id_1 = elevator.old_train_id,
        old_surface_index = elevator.surface.index,
        teleporter = elevator.main,
        stranded = carriage_behind and elevator.train_behind -- optional: only if train is split due to incomplete transfer
      })
    if carriage_behind then
      elevator.main.force.print({"space-exploration.space-elevator-train-split",
        util.gps_tag(elevator.surface.name, struct.position)
      })
    end
    --do not cleanup storage.space_elevator_train_behind here as broken trains can still be ready to go
  end
end

---@param elevator SpaceElevatorInfo
---@param carriage LuaEntity
function SpaceElevator.create_tug(elevator, carriage)
  -- place a "tug" behind the carriage
  local struct = elevator.elevator_struct

    -- angle to carriage_ahead
  local output_position_offset = util.vectors_delta(struct.output_rail_circle_offset, carriage.position)
  local full_angle = Util.half_pi - struct.direction_sign * math.atan2(output_position_offset.x, output_position_offset.y) -
    (SpaceElevator.carriage_half_length_angle[carriage.name] + SpaceElevator.carriage_half_length_angle[SpaceElevator.name_tug])
  local output_position = SpaceElevator.get_back_angle_output_position(struct, full_angle)
  local tug = elevator.opposite_elevator.surface.create_entity{
    name = SpaceElevator.name_tug,
    position = output_position,
    direction = struct.direction,
    force = carriage.force,
  }
  tug.backer_name = ""
  tug.destructible = false
  elevator.tug = tug
end

-- returns an angle based on down direction being the 0 point
---@param angle number
---@param struct SpaceElevatorStruct
---@return MapPosition.0
function SpaceElevator.angle_to_position(angle, struct)
  -- position on circle
  local x = math.sin(angle) * struct.rail_radius_multiplier
  local y = math.cos(angle) * SpaceElevator.space_elevator_hypertrain_rail_radius

  return util.vectors_add(struct.output_rail_circle_offset, {x = x, y = y})
end

---calculate output position by going backwards from carriage_ahead
---@param struct SpaceElevatorStruct
---@param full_angle number
---@return MapPosition.0
function SpaceElevator.get_back_angle_output_position(struct, full_angle)
  local x = math.cos(full_angle) * struct.rail_radius_multiplier
  local y = math.sin(full_angle) * SpaceElevator.space_elevator_hypertrain_rail_radius
  return util.vectors_add(struct.output_rail_circle_offset, {x = x, y = y})
end

---Get multiplier for behind_trains forward direction
---@param elevator SpaceElevatorInfo
---@return 1|-1
function SpaceElevator.get_behind_forward_sign(elevator)
  local front_end = elevator.train_behind.front_end
  front_end.move_to_segment_end()
  if front_end == elevator.input_railend then
    return 1
  else
    -- it may be that the behind carriage is outside the elevator entity and so first call to move_to_segment_end will go to the internal rail signal
    -- move a few more segments forward in case we're outside the elevators internal signal (worst case scenario of a straight rail loaded with signals just prior to elevator)
    local path = game.train_manager.request_train_path{goals = {elevator.input_railend}, starts = {{rail = front_end.rail, direction= front_end.direction}}, steps_limit = 5}
    return (path.found_path and path.total_length < 40) and 1 or -1
  end
end

---Get multiplier for ahead_trains forward direction
---@param elevator SpaceElevatorInfo
---@return 1|-1
function SpaceElevator.get_ahead_forward_sign(elevator)
  local back_end = elevator.train_ahead.back_end
  back_end.move_to_segment_end()
  return back_end == elevator.output_railend and 1 or -1
end

-- Teleports struct.carriage_behind to the back of struct.carriage_ahead if exists, otherwise teleports to the output of space elevator
---@param elevator SpaceElevatorInfo
---@param carriage_ahead_output_position Coordinate.0 map position to create new carriage
---@param carriage_behind? LuaEntity
function SpaceElevator.space_elevator_teleport_next(elevator, carriage_ahead_output_position, carriage_behind)
  local struct = elevator.elevator_struct
  local carriage_next = elevator.carriage_behind
  ---@cast carriage_next -?
  local carriage_next_name = carriage_next.name
  local carriage_next_train = elevator.train_behind
  ---@cast carriage_next_train -?
  local carriage_ahead = elevator.carriage_ahead

  -- try to move the carriage to the other end's output

  -- needs set before _built event
  carriage_behind = carriage_behind or carriage_next.get_connected_rolling_stock(defines.rail_direction.front) or carriage_next.get_connected_rolling_stock(defines.rail_direction.back)

  -- Save manual mode for restoring later
  local carriage_ahead_manual_mode
  if carriage_ahead then
    -- mid transfer
    carriage_ahead_manual_mode = elevator.train_ahead.manual_mode
    if elevator.tug then
      elevator.tug.destroy()
      elevator.tug = nil
    end
  else
    carriage_ahead_manual_mode = carriage_next_train.manual_mode
    elevator.needs_tug = true
  end
  -- transfer the carriage
  local carriage_new = carriage_next.clone{
    position = carriage_ahead_output_position,
    surface = elevator.opposite_elevator.surface,
    create_build_effect_smoke = false
  }

  if not carriage_new then
    -- Carriage was unable to be created for some reason
    if elevator.blocker then elevator.blocker.destroy() end
    if not carriage_ahead then
      -- only do delay setup for new trains
      SpaceElevator.delay_transfer(elevator)
    else
      SpaceElevator.finish_teleport(elevator)
    end
    return
  end

  --debug to see line between guessed carriage clone location and actual location
  --rendering.draw_line{color = {1, 0, 0}, width = 1, to = carriage_ahead_output_position, from=carriage_new.position, surface = carriage_new.surface, time_to_live = 60}

  -- Transfer was successful beyond this point
  elevator.carriage_ahead = carriage_new
  elevator.carriage_behind = carriage_behind

  -- sounds
  elevator.surface.create_entity{
    name = SpaceElevator.name_sound_carriage_up,
    position = struct.position
  }
  elevator.opposite_elevator.surface.create_entity{
    name = SpaceElevator.name_sound_carriage_down,
    position = struct.position
  }

  -- Move carriage driver
  local driver = carriage_next.get_driver()
  if driver then
    carriage_next.set_driver(nil)
    if driver.object_name ~= "LuaPlayer" then -- In some cases players can control trains directly e.g. editor
      driver = teleport_character_to_surface(driver, carriage_new.surface, carriage_new.position)
    end
    carriage_new.set_driver(driver)
  end

  -- parts maintenance cost for transferring a carriage
  local inventory_size = SpaceElevator.inventory_size[carriage_next_name]
  struct.parts = struct.parts - inventory_size * elevator.maintenance_per_stack
  struct.lua_energy = struct.lua_energy + inventory_size * elevator.energy_per_stack

  -- Raise built event for compatibility with mods like Electric Train. `cloned = true` is also for our own code.
  script.raise_script_built{entity=carriage_new, cloned=true}

  local carriage_new_train
  -- set new trains caches
  if not carriage_ahead then
    --new train
    if elevator.blocker then elevator.blocker.destroy() end
    carriage_new_train = carriage_new.train
    ---@cast carriage_new_train -?
    elevator.train_ahead = carriage_new_train
    elevator.train_ahead_weight = carriage_new_train.weight
    elevator.train_ahead_id = carriage_new_train.id
    elevator.ahead_forward_sign = SpaceElevator.get_ahead_forward_sign(elevator)
    storage.space_elevator_train_ahead[carriage_new_train.id] = elevator
  else
    carriage_new_train = carriage_new.train
  end

  -- place a "tug" behind the carriage if no locomotives in order to save the schedule or to automatically traverse forward
  if elevator.needs_tug then
    if carriage_new.type == "locomotive" and (
      (carriage_new.is_headed_to_trains_front and elevator.ahead_forward_sign == 1) or
      (not carriage_new.is_headed_to_trains_front and elevator.ahead_forward_sign == -1))
    then
      elevator.needs_tug = false
    else
      SpaceElevator.create_tug(elevator, carriage_new)
      carriage_new_train = carriage_new.train
      ---@cast carriage_new_train -?
    end
  end

  -- Save the old train speed before modifying train scheduling
  local old_train_speed = math.abs(carriage_next_train.speed)

  -- Is this a brand new train?
  if not carriage_ahead then
    -- new train sounds
    elevator.surface.create_entity{
      name = SpaceElevator.name_sound_train_up,
      position = struct.position
    }
    elevator.opposite_elevator.surface.create_entity{
      name = SpaceElevator.name_sound_train_down,
      position = struct.position
    }
    elevator.surface.create_entity{
      name = SpaceElevator.name_sound_train_start,
      position = struct.position
    }
    elevator.opposite_elevator.surface.create_entity{
      name = SpaceElevator.name_sound_train_start,
      position = struct.position
    }

    -- save the schedule
    local schedule_old = carriage_next_train.get_schedule()
    -- schedule records need some processing first
    local records = schedule_old.get_records()
    ---@cast records -?
    local current_stop_index = schedule_old.current

    -- cleanup schedule records
    for i = #records, 1, -1 do
      if records[i].rail then
        --Remove all rail based stops as they will cause a crash. Includes wait condition for blocked trains.
        table.remove(records, i)
        current_stop_index = current_stop_index - 1
        if current_stop_index < 1 then
          current_stop_index = #records
        end
      end
    end

    local current_record = records[current_stop_index]
    --it is possible to set a train to automatic while manually driving causing it to drift through the elevator with no schedule.
    if not carriage_next_train.manual_mode and current_record and current_record.station == elevator.station.backer_name then
      if current_record.temporary then
        --remove this scheduled stop if its temporary as the native scheduler does not.
        table.remove(records, current_stop_index)
        if current_stop_index > #records then
          current_stop_index = 1
        end
      else
        current_stop_index = (current_stop_index % #records) + 1
      end
    end

    --cleanup complete, save these
    elevator.schedule_records = records
    elevator.schedule_current = current_stop_index
    elevator.schedule_group = schedule_old.group
    elevator.schedule_interrupts = schedule_old.get_interrupts()

    --set the schedule for pathing purposes but do not include interrupts as these may inadvertantly fire mid transfer
    local schedule_new = carriage_new_train.get_schedule()
    schedule_new.group = nil
    schedule_new.set_interrupts{}
    schedule_new.set_records(records)
    if next(records) then
      schedule_new.go_to_station(current_stop_index)
    end
    local new_train_state = carriage_new_train.state
    if new_train_state == defines.train_state.no_path or new_train_state == defines.train_state.destination_full then
      SpaceElevator.check_interrupts(elevator)
    end

    --safeguard train_behind from accidental changes
    schedule_old.group = nil
    schedule_old.set_interrupts{}

    -- Save the old train id before removing the carriage
    elevator.old_train_id = carriage_next_train.id

    -- Raise on_train_teleport_started event after the first carriage is created on the new surface.
    script.raise_event(SpaceElevator.on_train_teleport_started_event,
      {
        train = carriage_new_train,
        old_train_id_1 = elevator.old_train_id,
        old_surface_index = elevator.surface.index,
        teleporter = elevator.main
      })
  else
    --set the schedule for pathing purposes but do not include interrupts as these may inadvertantly fire mid transfer
    local schedule_new = carriage_new_train.get_schedule()
    schedule_new.set_records(elevator.schedule_records)
    if next(elevator.schedule_records) then
      schedule_new.go_to_station(elevator.schedule_current)
    end
  end

  local train_behind_id
  if not carriage_behind then
    --save id before destroying train to cleanup caches
    train_behind_id = carriage_next_train.id
  end

  -- Raise destroy event for compatibility with Vehicle Wagon and others.  `cloned = true` is also for our own code.
  script.raise_script_destroy{entity=carriage_next, cloned=true}
  carriage_next.destroy() -- This also sets the "behind" train to manual mode

  local carriage_behind_train
  if carriage_behind then -- there is more train to traverse
    carriage_behind_train = elevator.carriage_behind.train
    ---@cast carriage_behind_train -?

    -- set the rear of the train to automatically continue to the elevator
    local locomotives = carriage_behind_train.locomotives
    if (not carriage_ahead_manual_mode) and next(elevator.behind_forward_sign == 1 and locomotives.front_movers or locomotives.back_movers) then
      carriage_behind_train.schedule = {records = {{rail = elevator.station_connected_rail}}, current = 1}
      carriage_behind_train.manual_mode = false
    else
      carriage_behind_train.manual_mode = true
    end
    -- Modifying train reduces it's speed, put it back
    carriage_behind_train.speed = elevator.behind_forward_sign * old_train_speed
  else
    -- This is the last carriage of this train
    elevator.collider = elevator.surface.create_entity{
      name = SpaceElevator.name_space_elevator_train_collider,
      position = struct.collider_position,
      force = "neutral"
    }
    SpaceElevator.finish_teleport(elevator)
    --finishing via last carriage removal does not trigger `on_train_created` for cleanup
    storage.space_elevator_train_behind[train_behind_id] = nil
    carriage_new_train = carriage_new.train -- finish_teleport may delete tug invalidating .train
    ---@cast carriage_new_train -?
  end

  -- Modifying train reduces it's speed, put it back
  carriage_new_train.speed = elevator.ahead_forward_sign * old_train_speed

  -- After placing new carriages or removing the tug, Factorio will set the train to manual and to the 1st station in its schedule.
  -- We put it back to how it was before.
  if next(elevator.schedule_records) then
    carriage_new_train.go_to_station(elevator.schedule_current)
  end
  carriage_new_train.manual_mode = carriage_ahead_manual_mode
end

---@type table<string, fun(a: number, b: number):boolean>
local comparator_handlers = {
  ["="] = function(a, b) return a == b end,
  ["≠"] = function(a, b) return a ~= b end,
  [">"] = function(a, b) return a  > b end,
  ["≥"] = function(a, b) return a >= b end,
  ["<"] = function(a, b) return a  < b end,
  ["≤"] = function(a, b) return a <= b end,
}

---@param train LuaTrain
---@return ItemWithQualityCount?
function SpaceElevator.get_first_fuel(train)
  for _, direction in pairs(train.locomotives) do
    for _, locomotive in pairs(direction) do
      local inventory = locomotive.get_fuel_inventory()
      if inventory then
        local contents = inventory.get_contents()
        if contents[1] then
          return contents[1]
        end
      end
    end
  end
end

---@param name string
---@param train_ahead LuaTrain
---@param train_behind LuaTrain
---@return string
function SpaceElevator.replace_virtual_signals(name, train_ahead, train_behind)
  if string.find(name, "[virtual-signal=signal-item-parameter]", 1, true) then
    local item = train_ahead.get_contents()[1] or
                  train_behind.get_contents()[1]
    if item then
      local signal = "[item="..item.name..(item.quality and item.quality ~= "normal" and ",quality="..item.quality or "").."]"
      name = core_util.string_replace(name, "[virtual-signal=signal-item-parameter]", signal)
    end
  end
  if string.find(name, "[virtual-signal=signal-fuel-parameter]", 1, true) then
    local fuel = SpaceElevator.get_first_fuel(train_ahead) or SpaceElevator.get_first_fuel(train_behind)
    if fuel then
      local signal = "[item="..fuel.name..(fuel.quality and fuel.quality ~= "normal" and ",quality="..fuel.quality or "").."]"
      name = core_util.string_replace(name, "[virtual-signal=signal-fuel-parameter]", signal)
    end
  end
  if string.find(name, "[virtual-signal=signal-fluid-parameter]", 1, true) then
    local fluid_name = next(train_ahead.get_fluid_contents()) or
                        next(train_behind.get_fluid_contents())
    if fluid_name then
      local signal = "[fluid="..fluid_name.."]"
      name = core_util.string_replace(name, "[virtual-signal=signal-fluid-parameter]", signal)
    end
  end
  -- never at a station so no need to process circuit signals
  return name
end

---@param condition WaitCondition
---@param train_ahead LuaTrain
---@param train_behind LuaTrain
---@return boolean
function SpaceElevator.check_basic_condition(condition, train_ahead, train_behind)
  if condition.type == "at_station" then
    return false -- never at a station to call this function

  elseif condition.type == "circuit" then
    return false -- never at a station to get a circuit signal

  elseif condition.type == "destination_full_or_no_path" then
    return true -- we already verified no path to call this function

  elseif condition.type == "empty" then
    return train_ahead.get_item_count() == 0 and train_behind.get_item_count() == 0

  elseif condition.type == "fluid_count" then
    if not condition.condition.first_signal then return false end
    if not condition.condition.constant or not condition.condition.second_signal then return false end

    local first_signal_name = condition.condition.first_signal.name
    if first_signal_name == "signal-fluid-parameter" then
      first_signal_name = next(train_ahead.get_fluid_contents()) or
                          next(train_behind.get_fluid_contents())
      if not first_signal_name then return false end
    end

    local count = train_ahead.get_fluid_count(first_signal_name) +
                  train_behind.get_fluid_count(first_signal_name)
    local compare_to = condition.condition.constant or
      train_ahead.get_fluid_count(condition.condition.second_signal.name) +
      train_behind.get_fluid_count(condition.condition.second_signal.name)
    return comparator_handlers[condition.condition.comparator](count, compare_to)

  elseif condition.type == "fuel_item_count_all" then
    if not condition.condition.first_signal then return false end
    if not condition.condition.constant or not condition.condition.second_signal then return false end

    local first_signal = condition.condition.first_signal
    if first_signal.name == "signal-fuel-parameter" then
      first_signal = SpaceElevator.get_first_fuel(train_ahead) or
                      SpaceElevator.get_first_fuel(train_behind)
      if not first_signal then return false end
      first_signal.count = nil
      ---@cast first_signal SignalID
    end
    local second_signal = condition.condition.second_signal
    if second_signal and not second_signal.quality then
      second_signal.quality = "normal"
    end

    for _, train in pairs{train_ahead, train_behind} do
      for _, direction in pairs(train.locomotives) do
        for _, locomotive in pairs(direction) do
          local inventory = locomotive.get_fuel_inventory()
          if inventory then
            local count = inventory.get_item_count(first_signal)
            local compare_to = condition.condition.constant or inventory.get_item_count(second_signal)
            if not comparator_handlers[condition.condition.comparator](count, compare_to) then
              return false
            end
          end
        end
      end
    end
    return true

  elseif condition.type == "fuel_item_count_any" then
    if not condition.condition.first_signal then return false end
    if not condition.condition.constant or not condition.condition.second_signal then return false end

    local first_signal = condition.condition.first_signal
    if first_signal.name == "signal-fuel-parameter" then
      first_signal = SpaceElevator.get_first_fuel(train_ahead) or
                      SpaceElevator.get_first_fuel(train_behind)
      if not first_signal then return false end
      first_signal.count = nil
      ---@cast first_signal SignalID
    end
    local second_signal = condition.condition.second_signal
    if second_signal and not second_signal.quality then
      second_signal.quality = "normal"
    end

    for _, train in pairs{train_ahead, train_behind} do
      for _, direction in pairs(train.locomotives) do
        for _, locomotive in pairs(direction) do
          local inventory = locomotive.get_fuel_inventory()
          if inventory then
            local count = inventory.get_item_count(first_signal)
            local compare_to = condition.condition.constant or inventory.get_item_count(second_signal)
            if comparator_handlers[condition.condition.comparator](count, compare_to) then
              return true
            end
          end
        end
      end
    end
    return false

  elseif condition.type == "full" then
    for _, train in pairs{train_ahead, train_behind} do
      for _, cargo_wagon in pairs(train.cargo_wagons) do
        if not cargo_wagon.get_inventory(defines.inventory.cargo_wagon).is_full() then
          return false
        end
      end
    end
    return true

  elseif condition.type == "fuel_full" then
    for _, train in pairs{train_ahead, train_behind} do
      for _, direction in pairs(train.locomotives) do
        for _, locomotive in pairs(direction) do
          local inventory = locomotive.get_fuel_inventory()
          if inventory then
            if not inventory.is_full() then
              return false
            end
          end
        end
      end
    end
    return true

  elseif condition.type == "not_empty" then
    return train_ahead.get_item_count() ~= 0 or train_behind.get_item_count() ~= 0

  elseif condition.type == "item_count" then
    if not condition.condition.first_signal then return false end
    if not condition.condition.constant or not condition.condition.second_signal then return false end

    local first_signal = condition.condition.first_signal
    if first_signal.name == "signal-item-parameter" then
      first_signal = train_ahead.get_contents()[1] or
                    train_behind.get_contents()[1]
      if not first_signal then return false end
      first_signal.count = nil
      ---@cast first_signal SignalID
    end
    if not first_signal.quality then
      first_signal.quality = "normal"
    end
    local second_signal = condition.condition.second_signal
    if second_signal and not second_signal.quality then
      second_signal.quality = "normal"
    end

    local count = train_ahead.get_item_count(first_signal) +
                  train_behind.get_item_count(first_signal)
    local compare_to = condition.condition.constant or
      train_ahead.get_item_count(second_signal) +
      train_behind.get_item_count(second_signal)
    return comparator_handlers[condition.condition.comparator](count, compare_to)

  elseif condition.type == "not_at_station" then
    return true -- we can't be at a station to call this function

  elseif condition.type == "passenger_present" then
    return next(train_ahead.passengers) ~= nil or next(train_behind.passengers) ~= nil

  elseif condition.type == "passenger_not_present" then
    return next(train_ahead.passengers) == nil and next(train_behind.passengers) ~= nil

  elseif condition.type == "specific_destination_full" then
    if not condition.station then return false end
    local carriage = train_ahead.front_stock
    ---@cast carriage -?
    local station = SpaceElevator.replace_virtual_signals(condition.station, train_ahead, train_behind)

    local stations = game.train_manager.get_train_stops{surface = carriage.surface, force = carriage.force, station_name = station, is_full = false, is_disabled = false}
    return next(stations) == nil

  elseif condition.type == "specific_destination_not_full" then
    if not condition.station then return false end
    local carriage = train_ahead.front_stock
    ---@cast carriage -?
    local station = SpaceElevator.replace_virtual_signals(condition.station, train_ahead, train_behind)

    local stations = game.train_manager.get_train_stops{surface = carriage.surface, force = carriage.force, station_name = station, is_full = false, is_disabled = false}
    return next(stations) ~= nil
  end

  error("unknown interrupt condition: "..condition.type)
  return false
end

---@param conditions WaitCondition[]
---@param train_ahead LuaTrain
---@param train_behind LuaTrain
---@return boolean
function SpaceElevator.check_interrupt_conditions(conditions, train_ahead, train_behind)
  local valid = true
  for _, condition in pairs(conditions) do
    if valid then
      if condition.compare_type == "and" then
        if not SpaceElevator.check_basic_condition(condition, train_ahead, train_behind) then
          valid = false
        end
      else
        return true
      end
    elseif condition.compare_type == "or" then
      if SpaceElevator.check_basic_condition(condition, train_ahead, train_behind) then
        valid = true
      end
    end
  end
  return valid
end

---@param elevator SpaceElevatorInfo
function SpaceElevator.check_interrupts(elevator)
  local train = elevator.train_ahead
  ---@cast train -?
  local inside_interrupt = elevator.schedule_records[elevator.schedule_current].created_by_interrupt
  for _, interrupt in pairs(elevator.schedule_interrupts) do
    if (not inside_interrupt or interrupt.inside_interrupt) and next(interrupt.conditions) and SpaceElevator.check_interrupt_conditions(interrupt.conditions, elevator.train_ahead, elevator.train_behind) then
      while elevator.schedule_records[elevator.schedule_current] and elevator.schedule_records[elevator.schedule_current].created_by_interrupt do
        table.remove(elevator.schedule_records, elevator.schedule_current)
      end
      if elevator.schedule_current > #elevator.schedule_records then
        elevator.schedule_current = 1
      end
      for i = #interrupt.targets, 1, -1 do
        local target = table.deepcopy(interrupt.targets[i])
        target.temporary = true
        target.created_by_interrupt = true
        target.station = SpaceElevator.replace_virtual_signals(target.station, elevator.train_ahead, elevator.train_behind)
        table.insert(elevator.schedule_records, elevator.schedule_current, target)
      end
      local schedule = train.get_schedule()
      schedule.set_records(elevator.schedule_records)
      schedule.go_to_station(elevator.schedule_current)
      break
    end
  end
end

---@param elevator SpaceElevatorInfo
function SpaceElevator.delay_transfer(elevator)
  -- New train, but we can't teleport it.
  -- It will reach the elevator station and maybe move on to the next station in its schedule, causing station skip or even making the train go backwards.
  -- Prevent this by setting an infinite wait condition on the elevator station.
  -- We will remove it after teleport.
  local schedule = elevator.train_behind.get_schedule()
  if next(schedule.get_records()) and not elevator.train_behind.manual_mode then -- Could be wagons only or manually driven
    local current_record = schedule.get_record({schedule_index = schedule.current})
    ---@cast current_record -?
    if not current_record.rail or current_record.rail ~= elevator.station_connected_rail then -- did we already add this?
      -- use a temporary schedule record that points to a rail segment
      -- can't use non-temporary as such a stop will be added to the group
      local temp_stop = {
        rail = elevator.station_connected_rail,
        wait_conditions = {{type = "time", ticks = 9999999 * 60, compare_type = "and"}},
        temporary = true,
        index = {schedule_index = schedule.current + 1}
      }
      schedule.add_record(temp_stop)
      schedule.go_to_station(schedule.current + 1)
    end
  end
end

---@param elevator SpaceElevatorInfo
function SpaceElevator.clear_text(elevator)
  if not elevator.text then return end
  elevator.text.destroy() -- Safe to call even when invalid
  elevator.text = nil
end

---@param elevator SpaceElevatorInfo
---@param text string
---@param color Color
function SpaceElevator.set_text(elevator, text, color)
  color = color or {1,1,1}
  if elevator.text then
    elevator.text.text = text
    elevator.text.color = color
  else
    elevator.text = rendering.draw_text{
      text = text,
      surface = elevator.surface,
      target = {
        entity = elevator.main,
        offset = {0, -4.5},
      },
      color = color,
      alignment = "center",
      scale = 1.5,
      only_in_alt_mode = true
    }
  end
end

---@param elevator SpaceElevatorInfo
function SpaceElevator.clear_icon(elevator)
  if not elevator.icon then return end
  elevator.icon.destroy() -- Safe to call even when invalid
  elevator.icon = nil
end

---@param elevator SpaceElevatorInfo
---@param sprite string
function SpaceElevator.set_icon(elevator, sprite)
  if elevator.icon then
    elevator.icon.sprite = sprite
  else
    elevator.icon = rendering.draw_sprite{
      sprite = sprite,
      surface = elevator.surface,
      target = {
        entity = elevator.main,
        offset = {0, -5},
      },
      only_in_alt_mode = false,
      x_scale  = 0.5,
      y_scale  = 0.5
    }
  end
end

-- check if there are any trains that would prevent track removal.
---@param struct SpaceElevatorStruct
---@return boolean
function SpaceElevator.space_elevator_can_mine_pair(struct)
  return struct.primary.main.surface.count_entities_filtered{type=SpaceElevator.stock_types, area = struct.primary.main.bounding_box, limit = 1} == 0 and
    struct.secondary.main.surface.count_entities_filtered{type=SpaceElevator.stock_types, area = struct.secondary.main.bounding_box, limit = 1} == 0
end

---@param event EventData.on_entity_renamed
function SpaceElevator.on_entity_renamed(event)
  local entity = event.entity
  if not entity.valid or entity.type ~= "train-stop" then return end
  local old_name = event.old_name
  -- only rename if no stops are left with this name
  if next(game.train_manager.get_train_stops{force = entity.force, station_name = old_name}) then return end
  local new_name = entity.backer_name
  for _, elevator in pairs(storage.space_elevators) do
    if elevator.schedule_records then
      for _, record in pairs(elevator.schedule_records) do
        if record.station == old_name then
          record.station = new_name
        end
        if record.wait_conditions then
          for _, condition in pairs(record.wait_conditions) do
            if condition.station == old_name then
              condition.station = new_name
            end
          end
        end
      end
    end
    if elevator.schedule_interrupts then
      for _, interrupt in pairs(elevator.schedule_interrupts) do
        if interrupt.conditions then
          for _, condition in pairs(interrupt.conditions) do
            if condition.station == old_name then
              condition.station = new_name
            end
          end
        end
        if interrupt.targets then
          for _, target in pairs(interrupt.targets) do
            if target.station == old_name then
              target.station = new_name
            end
            if target.wait_conditions then
              for _, wait_condition in pairs(target.wait_conditions) do
                if wait_condition.station == old_name then
                  wait_condition.station = new_name
                end
              end
            end
          end
        end
      end
    end
  end
end
Event.addListener(defines.events.on_entity_renamed, SpaceElevator.on_entity_renamed)

---Detect adding a carriage onto a currently transferring train which will invalidate caches
---@param event EntityCreationEvent|{cloned:true} Event data
function SpaceElevator.on_entity_created_rollingstock(event)
  local entity = event.entity
  -- This is only for player modified rollingstock. We raise_script_built with cloned = true, so check that and skip this if applicable
  if not entity.valid or not SpaceElevator.stock_types_map[entity.type] or event.cloned then return end
  local train_id = entity.train.id
  local elevator = storage.space_elevator_train_ahead[train_id]
  if elevator then
    if (elevator.ahead_forward_sign == 1 and elevator.train_ahead.back_stock == entity) or
        (elevator.ahead_forward_sign == -1 and elevator.train_ahead.front_stock == entity) then
      --carriage was added to the rear of train_ahead
      elevator.carriage_ahead = entity
      if elevator.tug then
        --try to reconnect the newly created entity to the back of the actual train, hiding the tug
        elevator.tug.destroy()
        elevator.tug = nil
        --destroying tug creates 2 trains, on_train_created will link to one but don't know which
        elevator.carriage_ahead.connect_rolling_stock(defines.rail_direction.front)
        elevator.carriage_ahead.connect_rolling_stock(defines.rail_direction.back)
        --on_train_created will have the correct train now
      end
      SpaceElevator.finish_teleport(elevator)
    end
  end
  elevator = storage.space_elevator_train_behind[train_id]
  if elevator then
    if (elevator.behind_forward_sign == 1 and elevator.train_behind.front_stock == entity) or
        (elevator.behind_forward_sign == -1 and elevator.train_behind.back_stock == entity) then
      -- carriage was added to front of train_behind
      elevator.carriage_behind = entity
      SpaceElevator.finish_teleport(elevator)
    end
  end
end
Event.addOnEntityCreatedListeners(SpaceElevator.on_entity_created_rollingstock)

---Detect removing a carriage onto a currently transferring train which will invalidate caches
---Note that entity has yet to be removed so train has not yet changed
---@param event EntityRemovalEvent|{cloned:true} Event data
function SpaceElevator.on_entity_removed_rollingstock(event)
  local entity = event.entity
  -- This is only for player modified rollingstock. We raise_script_built with cloned = true, so check that and skip this if applicable
  if not entity.valid or not SpaceElevator.stock_types_map[entity.type] or event.cloned then return end

  --trains have NOT updated yet
  local train_id = entity.train.id
  local elevator = storage.space_elevator_train_ahead[train_id]
  if elevator then
    if elevator.carriage_ahead == entity then
      SpaceElevator.finish_teleport(elevator)
    end
  end
  elevator = storage.space_elevator_train_behind[train_id]
  if elevator then
    if not elevator.carriage_ahead then
      --may be in a delay state. Clean up the schedule delay entry
      local schedule = elevator.train_behind.get_schedule()
      local record_position = {schedule_index = schedule.current}
      local current_record = schedule.get_record(record_position)
      if current_record and current_record.rail == elevator.station_connected_rail then
        schedule.remove_record(record_position)
      end
    else
      -- call finish_teleport first to have the correct info for the teleport_finished event
      SpaceElevator.finish_teleport(elevator)
    end
    if elevator.carriage_behind == entity then
      elevator.carriage_behind = nil
      if #elevator.train_behind.carriages <= 1 then
        -- removal of last carriage won't trigger on_train_created for cleanup
        storage.space_elevator_train_behind[train_id] = nil
      end
      elevator.collider = elevator.surface.create_entity{
        name = SpaceElevator.name_space_elevator_train_collider,
        position = elevator.elevator_struct.collider_position,
        force = "neutral"
      }
    end
  end
end
Event.addOnEntityRemovedListeners(SpaceElevator.on_entity_removed_rollingstock)

---@param event EventData.on_train_created
function SpaceElevator.on_train_created(event)
  local elevator_ahead = event.old_train_id_1 and (storage.space_elevator_train_ahead[event.old_train_id_1] or event.old_train_id_2 and storage.space_elevator_train_ahead[event.old_train_id_2])
  if elevator_ahead then
    storage.space_elevator_train_ahead[elevator_ahead.train_ahead_id] = nil
    if elevator_ahead.carriage_ahead then
      -- read from carriage in case of train split. If train is being destroyed, read from event
      local train = elevator_ahead.carriage_ahead.train or event.train
      elevator_ahead.train_ahead = train
      elevator_ahead.train_ahead_weight = train.weight
      elevator_ahead.train_ahead_id = train.id
      elevator_ahead.ahead_forward_sign = SpaceElevator.get_ahead_forward_sign(elevator_ahead)
      storage.space_elevator_train_ahead[elevator_ahead.train_ahead_id] = elevator_ahead
    end
  end

  local elevator_behind = event.old_train_id_1 and (storage.space_elevator_train_behind[event.old_train_id_1] or event.old_train_id_2 and storage.space_elevator_train_behind[event.old_train_id_2])
  if elevator_behind then
    storage.space_elevator_train_behind[elevator_behind.train_behind_id] = nil
    if elevator_behind.carriage_behind then
      -- read from carriage in case of train split. If train is being destroyed, read from event
      local train = elevator_behind.carriage_behind.train or event.train
      elevator_behind.train_behind = train
      elevator_behind.train_behind_weight = train.weight
      elevator_behind.train_behind_id = train.id
      elevator_behind.behind_forward_sign = SpaceElevator.get_behind_forward_sign(elevator_behind)
      storage.space_elevator_train_behind[elevator_behind.train_behind_id] = elevator_behind
    end
  end
end
Event.addListener(defines.events.on_train_created, SpaceElevator.on_train_created)

---@param event EventData.on_train_schedule_changed
function SpaceElevator.on_train_schedule_changed(event)
  if not event.player_index then return end
  local train_id = event.train.id
  local elevator_ahead = storage.space_elevator_train_ahead[train_id]
  if elevator_ahead then
    -- player tried changing this schedule, put it back
    local player = game.get_player(event.player_index)
    ---@cast player -?
    player.print({"space-exploration.space-elevator-schedule-changed"})

    local schedule = elevator_ahead.train_ahead.get_schedule()
    schedule.group = nil
    schedule.set_records(elevator_ahead.schedule_records)
    schedule.set_interrupts{}
    if next(elevator_ahead.schedule_records) then
      schedule.go_to_station(elevator_ahead.schedule_current)
    end
  end

  local elevator_behind = storage.space_elevator_train_behind[train_id]
  if elevator_behind then
    if elevator_behind.carriage_ahead then
      -- player tried changing this schedule, put it back
      local player = game.get_player(event.player_index)
      ---@cast player -?
      player.print({"space-exploration.space-elevator-schedule-changed"})

      local locomotives = elevator_behind.train_behind.locomotives
      if not elevator_behind.train_behind.manual_mode and next(elevator_behind.behind_forward_sign == 1 and locomotives.front_movers or locomotives.back_movers) then
        elevator_behind.train_behind.schedule = {records = {{rail = elevator_behind.station_connected_rail}}, current = 1}
        elevator_behind.train_behind.manual_mode = false
      else
        elevator_behind.train_behind.schedule = nil
        elevator_behind.train_behind.manual_mode = true
      end
    end
  end
end
Event.addListener(defines.events.on_train_schedule_changed, SpaceElevator.on_train_schedule_changed)

---@param event EventData.on_pre_player_mined_item|EventData.on_robot_pre_mined Event data
function SpaceElevator.on_pre_mined(event)
  if not event.entity.valid then return end
  if event.entity.name == SpaceElevator.name_space_elevator then
    local entity = event.entity
    local elevator = storage.space_elevators[entity.unit_number]
    if not elevator then return end -- will happen when entity creation is cancelled
    local struct = elevator.elevator_struct
    if not SpaceElevator.space_elevator_can_mine_pair(struct) then
      -- cancel action
      --entity.minable = false -- does not work.
      local text_target
      local icon_target
      if elevator.text then
        text_target = elevator.text.target
        elevator.text.target = {0,0}
      end
      if elevator.icon then
        icon_target = elevator.icon.target
        elevator.icon.target = {0,0}
      end
      local products_finished = entity.products_finished
      local inventory = entity.get_inventory(defines.inventory.crafter_input)
      local temp_inventory = game.create_inventory(#inventory)
      util.move_inventory_items(inventory, temp_inventory)
      local health = entity.health
      entity.destroy()
      local main = elevator.surface.create_entity{
        name = SpaceElevator.name_space_elevator,
        position = struct.position,
        direction = struct.direction,
        force = struct.force_name,
        create_build_effect_smoke = false
      }
      ---@cast main -?
      elevator.main = main
      SpaceElevator.draw_top(elevator)
      main.health = health
      main.products_finished = products_finished
      util.move_inventory_items(temp_inventory, main.get_inventory(defines.inventory.crafter_input))
      temp_inventory.destroy()
      local new_unit_number = main.unit_number
      ---@cast new_unit_number -?
      storage.space_elevators[elevator.unit_number] = nil
      elevator.unit_number = new_unit_number
      storage.space_elevators[new_unit_number] = elevator
      script.register_on_object_destroyed(main)
      main.disabled_by_script = struct.disabled
      if elevator.text then
        text_target.entity = main
        elevator.text.target = text_target
      end
      if elevator.icon then
        icon_target.entity = main
        elevator.icon.target = icon_target
      end
    else
      local parts = struct.parts * 0.9 -- lose 10%
      struct.parts = 0
      if parts >= 1 then
        if event.player_index then
          parts = parts - game.get_player(event.player_index).insert({name = SpaceElevator.name_part, count = parts})
        end
        if parts >= 1 then
          elevator.surface.spill_item_stack{
            position = struct.position,
            stack = {name = SpaceElevator.name_part, count = parts},
            enable_looted = true,
            force = struct.force_name,
            allow_belts = false
          }
        end
      end
    end
  end
end
Event.addListener(defines.events.on_pre_player_mined_item, SpaceElevator.on_pre_mined)
Event.addListener(defines.events.on_robot_pre_mined, SpaceElevator.on_pre_mined)

function SpaceElevator.destroy_elevator(elevator)
  if not elevator then return end -- will happen when entity creation is cancelled
  local struct = elevator.elevator_struct
  SpaceElevator.space_elevator_destroy(elevator.opposite_elevator)
  if elevator.opposite_elevator.main.valid then
    elevator.opposite_elevator.main.destroy()
  end
  SpaceElevator.space_elevator_destroy(elevator)
  storage.space_elevator_structs[struct.index] = nil
end

---Handles surface deletion
---@param event EventData.on_object_destroyed Event data
function SpaceElevator.on_object_destroyed(event)
  if not storage.space_elevators[event.useful_id] then return end
  if event.type ~= defines.target_type.entity then return end
  SpaceElevator.destroy_elevator(storage.space_elevators[event.useful_id])
end
Event.addListener(defines.events.on_object_destroyed, SpaceElevator.on_object_destroyed)

---@param event EntityRemovalEvent Event data
function SpaceElevator.on_entity_removed(event)
  local entity = event.entity
  if not entity.valid or entity.name ~= SpaceElevator.name_space_elevator then return end
  SpaceElevator.destroy_elevator(storage.space_elevators[entity.unit_number])
end
Event.addOnEntityRemovedListeners(SpaceElevator.on_entity_removed)

---@param elevator SpaceElevatorInfo
function SpaceElevator.space_elevator_destroy(elevator)
  local struct = elevator.elevator_struct
  local area = Util.area_add_position(prototypes.entity[SpaceElevator.name_space_elevator].collision_box, struct.position)
  -- Destroy rolling stock first
  -- This should only happen if the elevator is destroyed, not mined. Mining an elevator will be cancelled if rolling stock is still on the rails.
  if elevator.tug and elevator.tug.valid then --opposite surface may not exist
    elevator.tug.destroy()
  end
  if elevator.surface.valid then
    local carriages = elevator.surface.find_entities_filtered{type=SpaceElevator.stock_types, area = area}
    for _, carriage in pairs(carriages) do
      -- call .die to drop any inventory. If it doesn't die, force it with .destroy
      carriage.die()
      if carriage.valid then
        carriage.destroy()
      end
    end
    --destroy all the sub entities
    if elevator.collider and elevator.collider.valid then elevator.collider.destroy() end
    for _, sub_entity in pairs(elevator.sub_entities) do
      if sub_entity.valid then sub_entity.destroy() end
    end
  end

  storage.space_elevators[elevator.unit_number] = nil
end

---@param value number
---@return Color
function SpaceElevator.colour_from_value(value)
  -- same red as danger icon, transition to orange, yellow, then light grey
  return {
    249,
    55 + (249 - 55)*math.max(0, math.min(1,2*value)),
    46 + (249 - 46)*math.max(0, math.min(1,-1 + 2*value))
  }
end

---@param struct SpaceElevatorStruct
function SpaceElevator.clear_all_icons_and_text(struct)
  local primary = struct.primary
  local secondary = struct.secondary
  SpaceElevator.clear_text(primary)
  SpaceElevator.clear_text(secondary)
  SpaceElevator.clear_icon(primary)
  SpaceElevator.clear_icon(secondary)
end

---@param struct SpaceElevatorStruct
---@param icon_string string
function SpaceElevator.set_parts_icon_and_text(struct, icon_string)
  local primary = struct.primary
  local secondary = struct.secondary
  local str_parts = struct.parts <= 0 and "0" or string.format("%.0f", struct.parts)
  local str_parts_needed = string.format("%.0f", struct.parts_needed)
  str_parts_needed = str_parts .. "/" .. str_parts_needed
  local color = SpaceElevator.colour_from_value(struct.parts/struct.parts_needed)
  SpaceElevator.set_text(primary, str_parts_needed, color)
  SpaceElevator.set_text(secondary, str_parts_needed, color)
  SpaceElevator.set_icon(primary, icon_string)
  SpaceElevator.set_icon(secondary, icon_string)
end

---@param struct SpaceElevatorStruct
function SpaceElevator.connect_wires(struct)
  local primary = struct.primary
  local secondary = struct.secondary
  primary.electric_pole_copper.connect_to(struct.power_switch_left, false, defines.wire_origin.script)
  secondary.electric_pole_copper.connect_to(struct.power_switch_right, false, defines.wire_origin.script)
  primary.electric_pole_red.connect_to(secondary.electric_pole_red, false, defines.wire_origin.script)
  primary.electric_pole_green.connect_to(secondary.electric_pole_green, false, defines.wire_origin.script)
end

---@param struct SpaceElevatorStruct
function SpaceElevator.disconnect_wires(struct)
  local primary = struct.primary
  local secondary = struct.secondary
  struct.power_switch_left.disconnect_all(defines.wire_origin.script)
  struct.power_switch_right.disconnect_all(defines.wire_origin.script)
  primary.electric_pole_red.disconnect_from(secondary.electric_pole_red, defines.wire_origin.script)
  primary.electric_pole_green.disconnect_from(secondary.electric_pole_green, defines.wire_origin.script)
end

---@param struct SpaceElevatorStruct
function SpaceElevator.space_elevator_maintain_parts(struct)
  local primary = struct.primary
  local secondary = struct.secondary
  --update crafted parts
  local primary_products_finished = primary.main.products_finished
  if primary_products_finished > primary.last_crafts then
    struct.parts = struct.parts + primary_products_finished - primary.last_crafts
    primary.last_crafts = primary_products_finished
  end
  local secondary_products_finished = secondary.main.products_finished
  if secondary_products_finished > secondary.last_crafts then
    struct.parts = struct.parts + secondary_products_finished - secondary.last_crafts
    secondary.last_crafts = secondary_products_finished
  end

  if struct.constructed then
    struct.parts = struct.parts - struct.parts_per_second
    if struct.parts >= struct.parts_needed then --don't need parts
      if not struct.disabled then
        primary.main.disabled_by_script = true
        secondary.main.disabled_by_script = true
        struct.disabled = true
      end
      return -- no need to check further.
    end -- below this, need parts
    if struct.disabled then
      primary.main.disabled_by_script = false
      secondary.main.disabled_by_script = false
      struct.disabled = false
    end
    SpaceElevator.connect_wires(struct) -- prevent shift-left-click shenanigans
    if struct.parts > struct.parts_threshold then
      if not struct.above_threshold then
        struct.above_threshold = true
        SpaceElevator.clear_all_icons_and_text(struct)
      end
      return -- the other thresholds are lower, so don't care.
    end
    -- constructed, but less than threshold parts
    if struct.above_threshold then
      struct.above_threshold = false
      SpaceElevator.set_parts_icon_and_text(struct, "se-warning-parts")
    end
    if struct.parts <= 0 then
      struct.parts = math.max(0, struct.parts)
      game.forces[struct.force_name].print({"space-exploration.space-elevator-broken", util.gps_tag(primary.surface.name, struct.position)})
      struct.constructed = false
      SpaceElevator.disconnect_wires(struct)
      primary.energy_interface.power_usage = 0
      secondary.energy_interface.power_usage = 0
      SpaceElevator.set_parts_icon_and_text(struct, "se-danger-parts")
      script.raise_event(SpaceElevator.on_space_elevator_changed_state_event, {primary = primary.main, constructed = struct.constructed, powered = struct.powered})
    end
  elseif struct.parts < struct.parts_needed then -- not constructed, and need more parts
    if struct.disabled then
      primary.main.disabled_by_script = false
      secondary.main.disabled_by_script = false
      struct.disabled = false
    end
    SpaceElevator.set_parts_icon_and_text(struct, "se-danger-parts")
  else -- not constructed, but have enough parts
    if not struct.disabled then
      primary.main.disabled_by_script = true
      secondary.main.disabled_by_script = true
      struct.disabled = true
    end
    struct.constructed = true
    SpaceElevator.clear_all_icons_and_text(struct)
    SpaceElevator.connect_wires(struct)
    script.raise_event(SpaceElevator.on_space_elevator_changed_state_event, {primary = primary.main, constructed = struct.constructed, powered = struct.powered})
  end
end

---@param struct SpaceElevatorStruct
function SpaceElevator.space_elevator_maintain_energy(struct)
  local primary = struct.primary
  local secondary = struct.secondary
  -- do power check
  local primary_energy = primary.energy_interface.energy
  local secondary_energy = secondary.energy_interface.energy
  local interface_energy = primary_energy + secondary_energy
  if struct.constructed then
    struct.lua_energy = struct.lua_energy - math.min(SpaceElevator.energy_passive_draw, interface_energy)
    local transfer_each = math.max(-struct.lua_energy, 0) / 2
    local transfer_primary = math.min(transfer_each, primary_energy)
    local transfer_secondary = math.min(transfer_each, secondary_energy)
    primary.energy_interface.power_usage = transfer_primary / 60
    secondary.energy_interface.power_usage = transfer_secondary / 60
    struct.lua_energy = struct.lua_energy + transfer_primary + transfer_secondary
    struct.total_energy = struct.lua_energy + interface_energy
    if struct.powered then
      if struct.total_energy < SpaceElevator.energy_min then
        struct.powered = false
        SpaceElevator.set_icon(primary, "se-danger-charge")
        SpaceElevator.set_icon(secondary, "se-danger-charge")
        script.raise_event(SpaceElevator.on_space_elevator_changed_state_event, {primary = primary.main, constructed = struct.constructed, powered = struct.powered})
      end
      return -- other thresholds are lower
    end
    if struct.total_energy >= SpaceElevator.energy_min then
      struct.powered = true
      if struct.above_threshold then -- don't clear cable warnings
        SpaceElevator.clear_icon(primary)
        SpaceElevator.clear_icon(secondary)
      end
      script.raise_event(SpaceElevator.on_space_elevator_changed_state_event, {primary = primary.main, constructed = struct.constructed, powered = struct.powered})
    end
  else
    struct.total_energy = struct.lua_energy + interface_energy
  end
end

---@param event EventData.on_pre_surface_deleted
function SpaceElevator.on_pre_surface_deleted(event)
  --don't rely on on_object_destroyed as that can be delayed by a tick
  for _, elevator in pairs(storage.space_elevators) do
    if elevator.surface.index == event.surface_index then
      SpaceElevator.destroy_elevator(elevator)
    end
  end
end
Event.addListener(defines.events.on_pre_surface_deleted, SpaceElevator.on_pre_surface_deleted)

---@param elevator SpaceElevatorInfo
function SpaceElevator.hypertrain_manage_speed(elevator)
  -- adjust speeds of trains to maintain separation
  local struct = elevator.elevator_struct
  local output_position_offset = Util.vectors_delta(struct.output_rail_circle_offset, elevator.carriage_ahead.position)
  local behind_half_length_angle = SpaceElevator.carriage_half_length_angle[elevator.carriage_behind.name]
  local ahead_angle = Util.half_pi - struct.direction_sign * math.atan2(output_position_offset.x, output_position_offset.y)
  local half_length_angles = SpaceElevator.carriage_half_length_angle[elevator.carriage_ahead.name] + behind_half_length_angle
  local full_angle = ahead_angle - half_length_angles
  local full_angle_tug = full_angle - (behind_half_length_angle + SpaceElevator.tug_length)
  if full_angle_tug > 0 then
    --Teleport next carriage. Don't manage speed here, it will be managed in the teleport
    --calculate position of next carriage
    local output_position = SpaceElevator.get_back_angle_output_position(struct, full_angle)
    SpaceElevator.space_elevator_teleport_next(elevator, output_position)
    return
  end

  -- try to have a consistent speed through the elevator
  local train_ahead = elevator.train_ahead
  ---@cast train_ahead -?
  local train_behind = elevator.train_behind
  ---@cast train_behind -?
  local ahead_speed = math.abs(train_ahead.speed)
  local behind_speed = math.abs(train_behind.speed)
  local behind_stopped = behind_speed == 0

  local manual_mode = train_ahead.manual_mode
  local behind_train_weight = elevator.train_behind_weight
  local ahead_train_weight = elevator.train_ahead_weight
  local total_weight = behind_train_weight + ahead_train_weight
  local behind_weight_ratio = behind_train_weight / total_weight
  local ahead_weight_ratio = ahead_train_weight / total_weight
  local average_speed = behind_weight_ratio * behind_speed + ahead_weight_ratio * ahead_speed
  -- keep the train speed within reasonable range
  average_speed = math.max(math.min(average_speed, SpaceElevator.max_train_speed), SpaceElevator.passive_train_speed[manual_mode])

  -- speed compensator to maintain a normal gap between ahead and behind
  local input_position_offset = Util.vectors_delta(struct.input_rail_circle_offset, elevator.carriage_behind.position)
  local behind_angle = Util.half_pi + struct.direction_sign * math.atan2(input_position_offset.x, input_position_offset.y)
  local compensator = (behind_angle + full_angle - elevator.carriage_compensator_angle) * SpaceElevator.space_elevator_hypertrain_rail_radius
  -- soften the compensator a bit
  compensator = compensator / 10

  if not (
    behind_stopped and
    (
      train_behind.state == defines.train_state.wait_station or --automatic mode
      train_behind.get_rail_end(elevator.behind_forward_sign == 1 and defines.rail_direction.front or defines.rail_direction.back) == elevator.input_railend --manual mode
    )
  )
  then
    -- only set if we're not at the end of the line. Otherwise let the train stop on its own
    train_behind.speed = math.max(average_speed + compensator * behind_weight_ratio, SpaceElevator.passive_train_speed[manual_mode]) * elevator.behind_forward_sign
  end
  local ahead_state = train_ahead.state
  if manual_mode or ahead_state == defines.train_state.on_the_path then
    -- only set speed under normal operating states
    train_ahead.speed = math.max(average_speed - compensator * ahead_weight_ratio, SpaceElevator.passive_train_speed[manual_mode]) * elevator.ahead_forward_sign
  elseif (ahead_state == defines.train_state.no_path or ahead_state == defines.train_state.destination_full) and (game.tick + elevator.unit_number) % 60 == 0 then
    -- update interrupts
    if elevator.schedule_group then
      local train = game.train_manager.get_trains{group = elevator.schedule_group}[1]
      if train then
        elevator.schedule_interrupts = train.get_schedule().get_interrupts()
      end
    end
    SpaceElevator.check_interrupts(elevator)
  end
end

---@param event EventData.on_tick Event data
function SpaceElevator.on_tick(event)
  local tick = event.tick
  -- maintenance
  for idx, struct in pairs(storage.space_elevator_structs) do
    if (tick + idx) % 60 == 0 then
      SpaceElevator.space_elevator_maintain_parts(struct)
      SpaceElevator.space_elevator_maintain_energy(struct)
      if not struct.constructed or not struct.powered then
        -- Cut train in half if it is in the middle of transport
        if struct.primary.carriage_behind then
          SpaceElevator.finish_teleport(struct.primary)
        end
        if struct.secondary.carriage_behind then
          SpaceElevator.finish_teleport(struct.secondary)
        end
      end
    end
  end

  -- manage current transfers
  for unit_number, elevator in pairs(storage.space_elevators) do
    if elevator.carriage_behind then
      if not elevator.carriage_ahead then
        --Train is waiting to start its transfer but was delayed
        if (tick + unit_number) % SpaceElevator.teleport_next_tick_frequency == 0 then
          local train_behind = elevator.train_behind
          ---@cast train_behind -?
          local speed_sign = Util.sign(train_behind.speed)
          if speed_sign == elevator.behind_forward_sign or speed_sign == 0 then
            SpaceElevator.space_elevator_teleport_start(elevator, tick)
          else
            --train has been reversed, break it
            elevator.carriage_behind = nil
            elevator.collider = elevator.surface.create_entity{
              name = SpaceElevator.name_space_elevator_train_collider,
              position = elevator.elevator_struct.collider_position,
              force = "neutral"
            }
            SpaceElevator.finish_teleport(elevator)
            storage.space_elevator_train_behind[elevator.train_behind_id] = nil
          end
        end
      else
        SpaceElevator.hypertrain_manage_speed(elevator)
      end
    end
  end
end
Event.addListener(defines.events.on_tick, SpaceElevator.on_tick)

function SpaceElevator.on_post_migrations(event)
  --if any entity prototypes were removed, make sure it wasn't a rolling stock which would destroy a cached train
  for _, new in pairs(event.migrations.entity) do
    if new == "" then
      --Something was removed. We have no info on what the old prototype was so verify all cached info
      for _, elevator in pairs(storage.space_elevators) do
        local destroyed = false
        if (elevator.carriage_ahead and not elevator.carriage_ahead.valid) then
          --cannot call finish_teleport here as we no longer have train_ahead nor any way of getting that info
          destroyed = true
          elevator.carriage_ahead = nil
          elevator.train_ahead = nil
          elevator.train_ahead_weight = nil
          if storage.space_elevator_train_ahead[elevator.train_ahead_id] then
            storage.space_elevator_train_ahead[elevator.train_ahead_id] = nil
          end
          if elevator.tug and elevator.tug.valid then
            elevator.tug.destroy()
            elevator.tug = nil
          end
        end
        if (elevator.carriage_behind and not elevator.carriage_behind.valid) then
          destroyed = true
          elevator.carriage_behind = nil
          elevator.train_behind = nil
          elevator.train_ahead_weight = nil
          if storage.space_elevator_train_behind[elevator.train_behind_id] then
            storage.space_elevator_train_behind[elevator.train_behind_id] = nil
          end
          if not elevator.collider or not elevator.collider.valid then
            elevator.collider = elevator.surface.create_entity{
              name = SpaceElevator.name_space_elevator_train_collider,
              position = elevator.elevator_struct.collider_position,
              force = "neutral"
            }
          end
        end

        --check if another carriage was removed from the train
        if elevator.train_ahead and not elevator.train_ahead.valid then
          SpaceElevator.on_train_created{old_train_id_1 = elevator.train_ahead_id}
        end
        if elevator.train_behind and not elevator.train_behind.valid then
          SpaceElevator.on_train_created{old_train_id_1 = elevator.train_behind_id}
        end

        if destroyed then
          -- Raise on_train_teleport_finished event after the last carriage is created on the new surface and the elevator is reset.
          script.raise_event(SpaceElevator.on_train_teleport_finished_event,
            {
              train = elevator.train_ahead, -- may be nil here if we've lost the data
              old_train_id_1 = elevator.old_train_id,
              old_surface_index = elevator.surface.index,
              teleporter = elevator.main,
              stranded = elevator.carriage_behind and elevator.train_behind -- optional: only if train is split due to incomplete transfer
            })
          if elevator.carriage_ahead then
            elevator.train_ahead.manual_mode = true
          end
          if elevator.carriage_behind then
            elevator.train_behind.manual_mode = true
          end
          if elevator.carriage_behind then
            elevator.main.force.print({"space-exploration.space-elevator-train-split",
              util.gps_tag(elevator.surface.name, elevator.elevator_struct.position)
            })
          end
        end

      end
      break
    end
  end
end
Event.addListener("on_post_migrations", SpaceElevator.on_post_migrations, true)

function SpaceElevator.on_init()
  storage.space_elevators = {}
  storage.space_elevator_structs = {}
  storage.space_elevator_train_ahead = {}
  storage.space_elevator_train_behind = {}

  -- create script inventory to hold blocker blueprint
  local inv = game.create_inventory(1)
  inv.insert{name="blueprint", count = 1}
  local blueprint = inv[1]
  blueprint.set_blueprint_entities{{
    entity_number = 1,
    name = SpaceElevator.name_connection_blocker,
    position = {0, 0},
    orientation = 0.25,
    stock_connections = {stock = 1}
  }}
  storage.space_elevator_blocker_blueprint = blueprint
end
Event.addListener("on_init", SpaceElevator.on_init, true)

SpaceElevator.setup_data_caches()

return SpaceElevator
