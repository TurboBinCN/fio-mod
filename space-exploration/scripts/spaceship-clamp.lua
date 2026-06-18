local SpaceshipClamp = {}

SpaceshipClamp.name_spaceship_clamp_keep = mod_prefix .. "spaceship-clamp"
SpaceshipClamp.name_spaceship_clamp_place = mod_prefix .. "spaceship-clamp-place"
SpaceshipClamp.name_spaceship_clamp_internal_power_pole = mod_prefix .. "spaceship-clamp-power-pole-internal"
SpaceshipClamp.name_spaceship_clamp_external_power_pole_east = mod_prefix .. "spaceship-clamp-power-pole-external-east"
SpaceshipClamp.name_spaceship_clamp_external_power_pole_west = mod_prefix .. "spaceship-clamp-power-pole-external-west"

SpaceshipClamp.internal_power_pole_offsets = {
  [defines.direction.east] = { x = 0.35, y = 0},
  [defines.direction.west] = { x = -0.35, y = 0}
}

SpaceshipClamp.external_power_pole_names = {
  [defines.direction.east] = SpaceshipClamp.name_spaceship_clamp_external_power_pole_east,
  [defines.direction.west] = SpaceshipClamp.name_spaceship_clamp_external_power_pole_west
}

SpaceshipClamp.external_power_pole_offsets = {
  [defines.direction.east] = { x = -0.75, y = -0.5},
  [defines.direction.west] = { x = 0.75, y = -0.5}
}

SpaceshipClamp.other_clamp_offsets = {
  [defines.direction.east] = { x = 2, y = 0},
  [defines.direction.west] = { x = -2, y = 0}
}

SpaceshipClamp.signal_for_disable = {type = "virtual", name = "signal-red"}
SpaceshipClamp.signal_for_spaceship_limit = {type = "virtual", name = "signal-L"}
SpaceshipClamp.signal_for_priority = {type = "virtual", name = "signal-P"}
SpaceshipClamp.default_priority = 50
SpaceshipClamp.max_tag_length = 200 -- Don't want players putting Bee-movie script as a tag
SpaceshipClamp.max_spaceship_limit = util.circuit_signal_max
SpaceshipClamp.max_priority = 255
SpaceshipClamp.grace_period = 5 * 60

---Lookup table to easily get signal names this direction supports
---The using signal is always in index 1.
---@type table<defines.direction, string[]>
SpaceshipClamp.signal_names_from_direction = {
  [defines.direction.east] = {
    mod_prefix.."anchor-using-right-clamp",
    mod_prefix.."anchor-to-right-clamp",
  },
  [defines.direction.west] = {
    mod_prefix.."anchor-using-left-clamp",
    mod_prefix.."anchor-to-left-clamp",
  },
}

---Lookup table to easily get the direction from a signal
---@type table<string, defines.direction>
SpaceshipClamp.clamp_direction_from_signal_name = {
    [mod_prefix.."anchor-using-right-clamp"]  = defines.direction.east,
    [mod_prefix.."anchor-to-right-clamp"]     = defines.direction.east,
    [mod_prefix.."anchor-to-left-clamp"]      = defines.direction.west,
    [mod_prefix.."anchor-using-left-clamp"]   = defines.direction.west,
}

---Handly lookup table to determine if a signal is used to anchor with
---Meaning it's usually placed on the spaceship.
---@type table<string, boolean>
SpaceshipClamp.is_using_signal = core_util.list_to_map{
  mod_prefix.."anchor-using-right-clamp",
  mod_prefix.."anchor-using-left-clamp",
}

---Handly lookup table to determine if a signal is used to anchor to
---Meaning it's usually placed on a surface.
---@type table<string, boolean>
SpaceshipClamp.is_to_signal = core_util.list_to_map{
  mod_prefix.."anchor-to-right-clamp",
  mod_prefix.."anchor-to-left-clamp",
}

--- Gets the SpaceshipClamp for this unit_number
---@param unit_number number
---@return SpaceshipClampInfo?
function SpaceshipClamp.from_unit_number (unit_number)
  if not unit_number then Log.debug("SpaceshipClamp.from_unit_number: invalid unit_number: nil") return end
  unit_number = tonumber(unit_number)
  -- NOTE: only supports container as the entity
  if storage.spaceship_clamps[unit_number] then
    return storage.spaceship_clamps[unit_number]
  else
    Log.debug("SpaceshipClamp.from_unit_number: invalid unit_number: " .. unit_number)
  end
end

--- Gets the SpaceshipClamp for this entity
---@param entity LuaEntity
---@return SpaceshipClampInfo?
function SpaceshipClamp.from_entity (entity)
  if not(entity and entity.valid) then
    Log.debug("SpaceshipClamp.from_entity: invalid entity")
    return
  end
  -- NOTE: only supports container as the entity
  return SpaceshipClamp.from_unit_number(entity.unit_number)
end

--[[========================================================================================
Lifecycle methods for maintaining state of composite entity
]]--

---@param spaceship_clamp SpaceshipClampInfo
---@return LuaEntity?
function SpaceshipClamp.get_make_internal_power_pole(spaceship_clamp)
  if spaceship_clamp.internal_power_pole and spaceship_clamp.internal_power_pole.valid then
    return spaceship_clamp.internal_power_pole
  end

  local entity = spaceship_clamp.main
  local offset = SpaceshipClamp.internal_power_pole_offsets[entity.direction]
  if not offset then return Log.debug('could not get offset for clamp external power pole because the direction of ' .. entity.direction .. ' does not match') end
  local power_pole_position = util.vectors_add(entity.position, offset)
  local power_pole = entity.surface.find_entity(SpaceshipClamp.name_spaceship_clamp_internal_power_pole, power_pole_position)
  if not power_pole then
    local power_pole_ghosts = entity.surface.find_entities_filtered{
      ghost_name = SpaceshipClamp.name_spaceship_clamp_internal_power_pole,
      position = power_pole_position}
    -- take the first one, delete the rest
    for _, power_pole_ghost in pairs(power_pole_ghosts) do
      if power_pole_ghost.valid then
        if not power_pole then
          local collisions, pole = power_pole_ghosts[1].revive({})
          if pole then
            power_pole = pole
          end
          if power_pole_ghost.valid then
            power_pole_ghost.destroy()
          end
        else
          power_pole_ghost.destroy()
        end
      end
    end
  end
  if not power_pole then
    power_pole = entity.surface.create_entity{
      name = SpaceshipClamp.name_spaceship_clamp_internal_power_pole,
      position = power_pole_position,
      force = entity.force
    }
    ---@cast power_pole -?
  end

  power_pole.destructible = false
  power_pole.rotatable = false

  spaceship_clamp.internal_power_pole = power_pole
  return spaceship_clamp.internal_power_pole
end

---@param entity LuaEntity
function SpaceshipClamp.delete_internal_power_pole(entity)
  local power_poles = entity.surface.find_entities_filtered{
    name = SpaceshipClamp.name_spaceship_clamp_internal_power_pole,
    area = entity.bounding_box
  }
  for _, power_pole in pairs(power_poles) do
    if power_pole.valid then
      power_pole.destroy()
    end
  end
  local power_pole_ghosts = entity.surface.find_entities_filtered{
    ghost_name = SpaceshipClamp.name_spaceship_clamp_internal_power_pole,
    area = entity.bounding_box
  }
  for _, power_pole_ghost in pairs(power_pole_ghosts) do
    if power_pole_ghost.valid then
      power_pole_ghost.destroy()
    end
  end
end

---@param spaceship_clamp SpaceshipClampInfo
---@return LuaEntity?
function SpaceshipClamp.get_make_external_power_pole(spaceship_clamp)
  if spaceship_clamp.external_power_pole and spaceship_clamp.external_power_pole.valid then
    return spaceship_clamp.external_power_pole
  end
  local entity = spaceship_clamp.main
  local offset = SpaceshipClamp.external_power_pole_offsets[entity.direction]
  if not offset then return Log.debug('could not get offset for clamp external power pole because the direction of ' .. entity.direction .. ' does not match') end
  local name = SpaceshipClamp.external_power_pole_names[entity.direction]
  local power_pole_position = util.vectors_add(entity.position, offset)

  -- try to find the power pole *anywhere* inside the main entity
  -- because it is not centered on the main entity and the entity can be rotated
  local power_pole = nil
  local power_poles = entity.surface.find_entities_filtered{
    name = {SpaceshipClamp.name_spaceship_clamp_external_power_pole_east, SpaceshipClamp.name_spaceship_clamp_external_power_pole_west},
    area = entity.bounding_box
  }
  for _, pole in pairs(power_poles) do
    if pole.valid and util.area_contains_position(entity.bounding_box, pole.position) then
      -- if the name is correct for the direction, reuse as-is
      if pole.name == name and util.position_equal(pole.position, power_pole_position) then
        power_pole = pole
      else
        -- otherwise the circuit connections have to be recorded, the entity deleted
        -- the correct direction entity created, and circuit connections restored
        pole.destroy()
      end
    end
  end

  if not power_pole then
    -- try to find the power pole ghost *anywhere* inside the main entity
    -- because it is not centered on the main entity and the entity can be rotated
    local power_pole_ghosts = entity.surface.find_entities_filtered{
      ghost_name = {SpaceshipClamp.name_spaceship_clamp_external_power_pole_east, SpaceshipClamp.name_spaceship_clamp_external_power_pole_west},
      area = entity.bounding_box
    }
    for _, power_pole_ghost in pairs(power_pole_ghosts) do
      if power_pole_ghost.valid and util.area_contains_position(entity.bounding_box, power_pole_ghost.position) then
        local collisions, pole = power_pole_ghost.revive({})
        if pole then
          -- if the name is correct for the direction, reuse as-is
          if pole.name == name and util.position_equal(pole.position, power_pole_position) then
            power_pole = pole
          else
            -- otherwise the circuit connections have to be recorded, the entity deleted
            -- the correct direction entity created, and circuit connections restored
            pole.destroy()
          end
        end
      end
    end
  end

  if not power_pole then
    -- it's not anywhere inside the clamp so make a new one
    power_pole = entity.surface.create_entity{
      name = name,
      position = power_pole_position,
      force = entity.force
    }
    ---@cast power_pole -?
  end

  power_pole.destructible = false
  power_pole.rotatable = false

  spaceship_clamp.external_power_pole = power_pole
  return spaceship_clamp.external_power_pole
end

---@param entity LuaEntity
function SpaceshipClamp.delete_external_power_pole(entity)
  local power_poles = entity.surface.find_entities_filtered{
    name = {SpaceshipClamp.name_spaceship_clamp_external_power_pole_east, SpaceshipClamp.name_spaceship_clamp_external_power_pole_west},
    area = entity.bounding_box
  }
  for _, power_pole in pairs(power_poles) do
    if power_pole.valid then
      power_pole.destroy()
    end
  end
  local power_pole_ghosts = entity.surface.find_entities_filtered{
    ghost_name = {SpaceshipClamp.name_spaceship_clamp_external_power_pole_east, SpaceshipClamp.name_spaceship_clamp_external_power_pole_west},
    area = entity.bounding_box
  }
  for _, power_pole_ghost in pairs(power_pole_ghosts) do
    if power_pole_ghost.valid then
      power_pole_ghost.destroy()
    end
  end
end

---@param event EntityCreationEvent|EventData.on_entity_cloned Event data
function SpaceshipClamp.on_entity_created(event)
  local entity = util.get_entity_from_event(event)

  if not entity then return end
  local entity_name = entity.name
  if entity_name == SpaceshipClamp.name_spaceship_clamp_place or entity_name == SpaceshipClamp.name_spaceship_clamp_keep then

    -- find spaceship at tile
    local direction
    if entity_name == SpaceshipClamp.name_spaceship_clamp_place then
      direction = (entity.direction == defines.direction.east or entity.direction == defines.direction.west ) and defines.direction.west or defines.direction.east
    else
      direction = (entity.direction == defines.direction.west or entity.direction == defines.direction.north ) and defines.direction.west or defines.direction.east
      entity.direction = direction
    end
    local surface = entity.surface

    local check_positions = {}
    if direction == defines.direction.west then
      table.insert(check_positions, util.vectors_add(entity.position, {x=0, y=-1})) -- top right over
      table.insert(check_positions, util.vectors_add(entity.position, {x=0, y=0})) -- bottom right behind
    else
      table.insert(check_positions, util.vectors_add(entity.position, {x=-1, y=-1})) -- top left over
      table.insert(check_positions, util.vectors_add(entity.position, {x=-1, y=0})) -- bottom left behind
    end

    local space_tiles = 0
    for _, pos in pairs(check_positions) do
      if tile_is_space(surface.get_tile(pos)) then
        space_tiles = space_tiles + 1
        Spaceship.flash_tile(surface, pos, {r=255,g=0,b=0, a = 0.25}, 10)
      end
    end

    if space_tiles >= 1 then
      SpaceshipClamp.delete_internal_power_pole(entity)
      SpaceshipClamp.delete_external_power_pole(entity)
      cancel_entity_creation(entity, event.player_index,  {"space-exploration.clamp_invalid_empty_space"}, event)
      return
    end

    local force_name = entity.force.name

    local keep
    if entity_name == SpaceshipClamp.name_spaceship_clamp_place then
      keep = entity.surface.create_entity{
        name = SpaceshipClamp.name_spaceship_clamp_keep,
        position = entity.position,
        force = entity.force,
        direction = direction,
        quality = entity.quality,
      }
      entity.destroy()
    else
      keep = entity
    end
    ---@cast keep -?
    keep.rotatable = false

    ---@type SpaceshipClampInfo
    local spaceship_clamp = {
      force_name = force_name,
      unit_number = keep.unit_number,
      main = keep,
      direction = keep.direction,
      surface_name = keep.surface.name,
      priority = SpaceshipClamp.default_priority,
      tag = SpaceshipClamp.find_unique_tag(keep),
      grace_period_until = event.tick + SpaceshipClamp.grace_period,
      spaceship_reservations = { },
    }

    storage.spaceship_clamps[spaceship_clamp.unit_number] = spaceship_clamp
    storage.spaceship_clamps_by_surface[spaceship_clamp.surface_name] = storage.spaceship_clamps_by_surface[spaceship_clamp.surface_name] or {}
    storage.spaceship_clamps_by_surface[spaceship_clamp.surface_name][spaceship_clamp.unit_number] =  spaceship_clamp
    Log.debug("SpaceshipClamp: spaceship_clamp added")

    -- Handle case where clamp is placed through blueprint with data
    local tags = util.get_tags_from_event(event, SpaceshipClamp.serialize)
    if tags then
      SpaceshipClamp.deserialize(keep, tags)

    elseif entity_name == SpaceshipClamp.name_spaceship_clamp_place then
      -- This entity was manually placed. Assign it a unique ID
      local signal_id = SpaceshipClamp.find_unique_clamp_id(direction, keep.surface, keep)
      SpaceshipClamp.write_id(spaceship_clamp, signal_id)
    end

    -- make the poles and connections
    SpaceshipClamp.poles_and_connection(spaceship_clamp)

    -- attempt to connect this clamp to the one next to it
    SpaceshipClamp.attempt_connect_clamp(keep)
  end
end
Event.addListener(defines.events.on_entity_cloned, SpaceshipClamp.on_entity_created)
Event.addOnEntityCreatedListeners(SpaceshipClamp.on_entity_created)

--- Makes sure the internal and external poles exist and aer connected
---@param spaceship_clamp SpaceshipClampInfo
function SpaceshipClamp.poles_and_connection(spaceship_clamp)
  local internal = SpaceshipClamp.get_make_internal_power_pole(spaceship_clamp)
  local external = SpaceshipClamp.get_make_external_power_pole(spaceship_clamp)
  spaceship_clamp.internal_power_pole.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    .connect_to(spaceship_clamp.external_power_pole.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script)
  spaceship_clamp.internal_power_pole.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    .connect_to(spaceship_clamp.external_power_pole.get_wire_connector(defines.wire_connector_id.circuit_green, true), false, defines.wire_origin.script)
    spaceship_clamp.internal_power_pole.get_wire_connector(defines.wire_connector_id.pole_copper, true)
      .connect_to(spaceship_clamp.external_power_pole.get_wire_connector(defines.wire_connector_id.pole_copper, true), false, defines.wire_origin.script)
end

---@param spaceship_clamp SpaceshipClampInfo
---@param key string
function SpaceshipClamp.destroy_sub(spaceship_clamp, key)
  if spaceship_clamp[key] and spaceship_clamp[key].valid then
    spaceship_clamp[key].destroy()
    spaceship_clamp[key] = nil
  end
end

---@param spaceship_clamp SpaceshipClampInfo
function SpaceshipClamp.invalidate_reservations(spaceship_clamp)
  for _, reservation in pairs(spaceship_clamp.spaceship_reservations) do
    reservation.valid = false
  end
  spaceship_clamp.spaceship_reservations = { }
end

---@param spaceship_clamp SpaceshipClampInfo?
---@param event EntityRemovalEvent? the event that triggered the destruction if it was caused by an event
function SpaceshipClamp.destroy(spaceship_clamp, event)
  if not spaceship_clamp then
    Log.debug("spaceship_clamp_destroy: not spaceship_clamp")
    return
  end

  spaceship_clamp.valid = false
  SpaceshipClamp.destroy_sub(spaceship_clamp, 'internal_power_pole')
  SpaceshipClamp.destroy_sub(spaceship_clamp, 'external_power_pole')

  if not event then
    SpaceshipClamp.destroy_sub(spaceship_clamp, 'main')
  end

  SpaceshipClamp.invalidate_reservations(spaceship_clamp)

  if not event or event.name ~= defines.events.on_entity_died then
    -- For died it will be cleaned in post_died event
    storage.spaceship_clamps[spaceship_clamp.unit_number] = nil
    storage.spaceship_clamps_by_surface[spaceship_clamp.surface_name][spaceship_clamp.unit_number] = nil
  end
end

---@param event EntityRemovalEvent
function SpaceshipClamp.on_entity_removed(event)
  local entity = event.entity
  if entity and entity.valid then
    if entity.name == SpaceshipClamp.name_spaceship_clamp_keep then
      SpaceshipClamp.destroy(SpaceshipClamp.from_entity(entity), event)
    elseif entity.type == "entity-ghost" and entity.ghost_name == SpaceshipClamp.name_spaceship_clamp_keep then
      SpaceshipClamp.delete_internal_power_pole(entity)
      SpaceshipClamp.delete_external_power_pole(entity)
    end
  end
end
Event.addOnEntityRemovedListeners(SpaceshipClamp.on_entity_removed)

---@param event EventData.on_post_entity_died
local function on_post_entity_died(event)
  local ghost = event.ghost
  local unit_number = event.unit_number
  if not (ghost and unit_number) then return end
  if event.prototype.name ~= SpaceshipClamp.name_spaceship_clamp_keep then return end
  local clamp_info = storage.spaceship_clamps[unit_number]
  ghost.tags = SpaceshipClamp.serialize_from_struct(clamp_info)
  storage.spaceship_clamps_by_surface[clamp_info.surface_name][unit_number] = nil
  storage.spaceship_clamps[unit_number] = nil
end
Event.addListener(defines.events.on_post_entity_died, on_post_entity_died)

---@param event EventData.on_marked_for_deconstruction
local function on_marked_for_deconstruction(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if entity.name ~= SpaceshipClamp.name_spaceship_clamp_keep then return end
  local clamp_info = SpaceshipClamp.from_entity(entity)
  if not clamp_info then return end
  SpaceshipClamp.invalidate_reservations(clamp_info)
end
Event.addListener(defines.events.on_marked_for_deconstruction, on_marked_for_deconstruction)

--- Attempts to connect a clamp to the other clamp it is anchored to
--- Also reconnects each clamps internal power poles in case the player
--- managed to disconnect them by accident (for example shift clicking the external power pole)
---@param entity LuaEntity
function SpaceshipClamp.attempt_connect_clamp(entity)
  local spaceship_clamp = SpaceshipClamp.from_entity(entity)
  SpaceshipClamp.poles_and_connection(spaceship_clamp)
  local offset = SpaceshipClamp.other_clamp_offsets[entity.direction]
  if not offset then return Log.debug('could not get offset for clamp external power pole because the direction of ' .. entity.direction .. ' does not match') end
  local other_clamp_position = util.vectors_add(spaceship_clamp.main.position, offset)
  local other_clamp_entity = spaceship_clamp.main.surface.find_entity(SpaceshipClamp.name_spaceship_clamp_keep, other_clamp_position)
  if not other_clamp_entity then return end
  local other_clamp = SpaceshipClamp.from_entity(other_clamp_entity)
  if other_clamp then
    SpaceshipClamp.poles_and_connection(other_clamp)
    local external_power_pole = spaceship_clamp.external_power_pole
    local other_external_power_pole = other_clamp.external_power_pole
    if external_power_pole and external_power_pole.valid and other_external_power_pole and other_external_power_pole.valid then
      external_power_pole.get_wire_connector(defines.wire_connector_id.pole_copper, true)
        .disconnect_from(other_external_power_pole.get_wire_connector(defines.wire_connector_id.pole_copper, true), defines.wire_origin.script)
    end
    local internal_power_pole = spaceship_clamp.internal_power_pole
    local other_internal_power_pole = other_clamp.internal_power_pole
    if internal_power_pole and internal_power_pole.valid and other_internal_power_pole and other_internal_power_pole.valid then
      spaceship_clamp.internal_power_pole.get_wire_connector(defines.wire_connector_id.circuit_red, true)
        .connect_to(other_clamp.internal_power_pole.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script)
      spaceship_clamp.internal_power_pole.get_wire_connector(defines.wire_connector_id.circuit_green, true)
        .connect_to(other_clamp.internal_power_pole.get_wire_connector(defines.wire_connector_id.circuit_green, true), false, defines.wire_origin.script)
        spaceship_clamp.internal_power_pole.get_wire_connector(defines.wire_connector_id.pole_copper, true)
        .connect_to(other_clamp.internal_power_pole.get_wire_connector(defines.wire_connector_id.pole_copper, true), false, defines.wire_origin.script)
    end
  end
end

---@param spaceship_clamp SpaceshipClampInfo
---@return boolean
function SpaceshipClamp.is_clamp_enabled(spaceship_clamp)
  if not spaceship_clamp.main.valid then return false end
  ---@TODO This can also be cached.
  local red_signal_count = spaceship_clamp.main.get_signal(SpaceshipClamp.signal_for_disable, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
  return red_signal_count <= 0
end

---Checks if this spaceship is placed on a spaceship. This is done by checking
---if there is at least one spaceship tile underneath the clamp. This check
---is relatively UPS expensive.
---@param clamp LuaEntity the main entity. Must be valid!
---@return boolean
function SpaceshipClamp.is_on_spaceship_tiles(clamp)
  return clamp.surface.count_tiles_filtered{name=Spaceship.names_spaceship_floors, limit=1,
    area = {{clamp.position.x-0.5, clamp.position.y - 0.2}, {clamp.position.x+0.5, clamp.position.y + 0.2}}
  } > 0
end

---Returns a list of clamps on a spaceship. When the spaceship
---is flying this call is quite cheap. But if not we have to
---to rely on the integrity check results, and search a surface
---with the known positions which is a little more UPS expensive.
---@param spaceship SpaceshipType
---@return SpaceshipClampInfo[]
function SpaceshipClamp.get_clamps_on_spaceship(spaceship)
  local console = spaceship.console
  if not console then return { } end -- Can't open the schedule if there's no console
  local surface = console.surface

  local clamps_found = { } --[[@as SpaceshipClampInfo[] ]]

  -- It's quite easy to find when on it's own surface. Let's prefer that
  if Spaceship.is_on_own_surface(spaceship) then
    -- Change the table to an array.
    for _, clamp_info in pairs(storage.spaceship_clamps_by_surface[surface.name] or { }) do
      table.insert(clamps_found, clamp_info)
    end
    return clamps_found
  end

  -- If we are not on our own surface then we need to rely on the integrity
  -- check being run already. If not, there's nothing to do. The check
  -- also finds clamps.
  if not spaceship.known_bounds then return { } end

  for _, clamp in pairs(surface.find_entities_filtered{
    name = SpaceshipClamp.name_spaceship_clamp_keep,
    area = {
      left_top = { x = spaceship.known_bounds.left_top.x, y = spaceship.known_bounds.left_top.y },
      right_bottom = { x = spaceship.known_bounds.right_bottom.x, y = spaceship.known_bounds.right_bottom.y },
    }
  }) do
      local clamp_x = math.floor(clamp.position.x)
      local clamp_y = math.floor(clamp.position.y)

      -- Check that this clamp is on the spaceship
      if not spaceship.known_tiles[clamp_x] or not spaceship.known_tiles[clamp_x][clamp_y] then goto continue end

      if clamp.to_be_deconstructed() then goto continue end

      local clamp_info = SpaceshipClamp.from_entity(clamp)
      if not clamp_info then goto continue end

      -- Make sure not to also select clamps that we are anchored to. This is tricky because the spaceship clamp
      -- might overlap the edge with one tile. And the bound of the ship technically also contains a single tile
      -- outside the spaceship walls.
      -- A side effect of this is that if the spaceship is docked to another ship it will return both clamps.
      if not SpaceshipClamp.is_on_spaceship_tiles(clamp) then goto continue end

      -- TODO With spaceship-to-spaceship docking another check will have to be added here
      -- to ensure that this clamp is not already anchored to another clamp.

      table.insert(clamps_found, clamp_info)

      ::continue::
  end

  return clamps_found
end

---Find the spaceship clamp with area given signal that can be used to anchor with.
---For future proofing with ship-to-ship docking, if there are multiple with the
---same signal then return the one that's the most north. This function will
---only work if the spaceship has run an integriry check.
---@note Only works when spaceship is on own surface or integrity check has run
---@param spaceship SpaceshipType
---@param descriptor SpaceshipClampDescriptor
---@return SpaceshipClampInfo?
function SpaceshipClamp.find_clamp_on_spaceship(spaceship, descriptor)
    ---@type SpaceshipClampInfo?
    local best_clamp_info
    local best_clamp_y

    local force_name = spaceship.force_name

    for _, clamp_info in pairs(SpaceshipClamp.get_clamps_on_spaceship(spaceship)) do
        local clamp = clamp_info.main
        if not (clamp and clamp.valid) then goto continue end
        if clamp.direction ~= descriptor.direction then goto continue end
        if force_name ~= clamp_info.force_name then goto continue end
        if descriptor.tag and descriptor.tag ~= clamp_info.tag then goto continue end

        -- Only prefer the new clamp if it's more north than the previous one
        -- This is cheaper than reading the signal, so do it first.
        if best_clamp_info and best_clamp_y < clamp.position.y then goto continue end

        if clamp.to_be_deconstructed() then goto continue end

        if descriptor.id then
          local other_clamp_id = SpaceshipClamp.read_id(clamp_info)
          if not other_clamp_id then goto continue end
          if descriptor.id ~= other_clamp_id then goto continue end
        end

        -- If reaching here we have the best clamp
        best_clamp_info = clamp_info
        best_clamp_y = clamp.position.y

        ::continue::
    end

    return best_clamp_info
end

---Returns the clamp connected to the supplied clamp if any
---@param clamp_info SpaceshipClampInfo
---@return SpaceshipClampInfo?
function SpaceshipClamp.find_connected_clamp(clamp_info)
  local clamp = clamp_info.main
  if not (clamp and clamp.valid) then return end
  local offset = SpaceshipClamp.other_clamp_offsets[clamp_info.main.direction]
  local docked_clamp_position = util.vectors_add(clamp.position, offset)
  local docked_clamp_entity = clamp.surface.find_entity(SpaceshipClamp.name_spaceship_clamp_keep, docked_clamp_position)
  if not docked_clamp_entity then return end -- API only returns valid entities
  return SpaceshipClamp.from_entity(docked_clamp_entity)
end

---Finds a random clamp to anchor with on a surface. It will always return the highest priority clamp
---This function is currently only used when ships are flying by circuit.
---@param surface LuaSurface
---@param force_name string
---@param descriptor SpaceshipClampDescriptor
---@return SpaceshipClampInfo?
function SpaceshipClamp.find_unoccupied_destination_clamps(surface, force_name, descriptor)
  local tick = game.tick

  ---@type SpaceshipClampInfo[]
  local viable_clamps = { }
  local best_priority = -1 -- real clamps can't be below 0

  for _, clamp_info in pairs(storage.spaceship_clamps_by_surface[surface.name] or { }) do
    local clamp = clamp_info.main
    if not clamp.valid then goto continue end
    if clamp_info.grace_period_until and tick < clamp_info.grace_period_until then goto continue end

    -- First use the easy dismissals. If this clamp has a lower priority as the current best clamp
    -- we can also just ignore it.
    if clamp_info.direction ~= descriptor.direction then goto continue end
    if best_priority > clamp_info.priority then goto continue end -- equal comparison done later
    if descriptor.tag and descriptor.tag ~= clamp_info.tag then goto continue end

    -- Filter out unfriendly clamps
    if clamp_info.force_name ~= force_name then goto continue end

    -- Now maybe read the signal and see if it's what we requested
    if descriptor.id then
      local id = SpaceshipClamp.read_id(clamp_info)
      if not id then goto continue end
      if id ~= descriptor.id then goto continue end
    end
    if not SpaceshipClamp.is_clamp_enabled(clamp_info) then goto continue end --[[@TODO this can also be cached? ]]

    -- Check if this clamp has another clamp docked to it
    -- It could be that a combinator setup or player landed a
    -- ship at this open, and we don't want scheduler ships waiting then while another clamp is open.
    if SpaceshipClamp.find_connected_clamp(clamp_info) then goto continue end -- There is a clamp docked! Ignore it. Don't need to look at its data

    -- If we reach here it's a viable clamp to dock to
    if clamp_info.priority > best_priority then
      best_priority = clamp_info.priority
      viable_clamps = { clamp_info }
    else
      table.insert(viable_clamps, clamp_info)
    end

    ::continue::
  end

  if next(viable_clamps) then
    return viable_clamps[math.random(#viable_clamps)]
  end
end

--- Finds an id value that is unused by any clamp on the given surface
---@param direction defines.direction direction of clamp
---@param surface LuaSurface? surface on which to find the unique id. All if not specified
---@param exclude_clamp LuaEntity entity to exlude from search
function SpaceshipClamp.find_unique_clamp_id(direction, surface, exclude_clamp)
  local used_ids = {}

  local surfaces_to_iterate = surface and {storage.spaceship_clamps_by_surface[surface.name] or { }} or storage.spaceship_clamps_by_surface
  for _, clamps_on_surface in pairs(surfaces_to_iterate) do
    for _, spaceship_clamp in pairs(clamps_on_surface) do

      local entity = spaceship_clamp.main
      if entity.valid then
        if entity ~= exclude_clamp and entity.direction == direction then
          local value = 0
          local id = SpaceshipClamp.read_id(spaceship_clamp)
          if id then value = id end
          used_ids[value] = value
        end
      else
        SpaceshipClamp.destroy(spaceship_clamp)
      end

    end
  end

  local i = 1
  while used_ids[i] do
    i = i + 1
  end
  return i
end

---Finds a unique tag for a clamp.
---It will check if the clamp is on spaceship tiles and adjust the tag accordingly.
---@param clamp LuaEntity must be valid!
---@return string tag
function SpaceshipClamp.find_unique_tag(clamp)

  local existing_tags = { } --[[@as table<string, boolean>]]
  for _, other_clamp_info in pairs(storage.spaceship_clamps) do
    if other_clamp_info.tag then -- Protect against old clamps for when called through migration
      existing_tags[other_clamp_info.tag] = true
    end
  end

  local tag --[[@as string?]]

  if SpaceshipClamp.is_on_spaceship_tiles(clamp) then
    -- This clamp is (likely) on a spaceship. Let's name it after the spaceship.
    -- This isn't done often so it's fine I guess?
    local p = clamp.position
    local fl = math.floor
    local tiles = {{fl(p.x-0.5), fl(p.y-0.5)},{fl(p.x+0.5), fl(p.y-0.5)},{fl(p.x-0.5), fl(p.y+0.5)},{fl(p.x+0.5), fl(p.y+0.5)}}
    local spaceship_name --[[@as string?]]
    for _, spaceship in pairs(storage.spaceships) do
      if not spaceship.valid then goto continue end
      if not spaceship.known_tiles then goto continue end
      if not (spaceship.console and spaceship.console.valid) then goto continue end
      if spaceship.console.surface ~= clamp.surface then goto continue end
      for _, tile in pairs(tiles) do
        if spaceship.known_tiles[tile[1]] and spaceship.known_tiles[tile[1]][tile[2]] then
          spaceship_name = spaceship.name
          break
        end
      end
      if spaceship_name then break end
      ::continue::
    end

    if spaceship_name then -- Make sure it's unique
      for i = 1,1e6 do
        tag = "[img=virtual-signal/se-spaceship] " .. spaceship_name .. " " .. tostring(i)
        if not existing_tags[tag] then
          break
        else
          tag = nil
        end
      end
    end
  end

  -- Now let's just go through a bunch of numbers until we find a unique one.
  if not tag then
    local maximum_number = 1000000 -- No one will ever build this many clamps, right?
    for i=1, maximum_number do -- Big loop!
      tag = string.format("Clamp %d", i)
      if not existing_tags[tag] then
        break -- Found a unique one!
      end
      tag = nil
    end
  end

  assert(tag, "Well done on building over a million clamps! Report this crash so we can bump the limit to 2 million.")

  return tag
end

---Read the signal located on this clamp.
---@param clamp_info SpaceshipClampInfo
---@return uint?
function SpaceshipClamp.read_id(clamp_info)

  ---@TODO This is now used often. We can cache in the clamp_info struct with 1 second timeout

  local clamp = clamp_info.main
  if not (clamp and clamp.valid) then return end
  local control = clamp.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
  local slot = control.get_section(1).get_slot(1)
  return next(slot) and slot.min
end

---Overwrite signal located on this clamp.
---@param clamp_info SpaceshipClampInfo
---@param id uint
function SpaceshipClamp.write_id(clamp_info, id)

  ---@TODO This is now used often. We can cache in the clamp_info struct with 1 second timeout

  local clamp = clamp_info.main
  if not (clamp and clamp.valid) then return end
  local control = clamp.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
  local signal_name = mod_prefix.."anchor-using-"..(clamp_info.direction == defines.direction.west and "left" or "right").."-clamp"
  control.get_section(1).set_slot(1, {
    value = { type="virtual", name=signal_name, quality="normal"},
    min = id
  })
end

--- Validates the type of a clamp signal
---@param spaceship_clamp_entity LuaEntity
function SpaceshipClamp.validate_clamp_signal(spaceship_clamp_entity)
  -- make sure it still has the correct signal.
  local value = 1
  local comb = spaceship_clamp_entity.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
  local signal = comb.get_section(1).get_slot(1)
  if next(signal) then value = signal.min end

  if value == 0 then value = 1 end -- 0 isn't valid
  if spaceship_clamp_entity.direction == defines.direction.west then
    comb.get_section(1).set_slot(1, {value={type="virtual", name=mod_prefix.."anchor-using-left-clamp", quality="normal"}, min=value})
  else
    comb.get_section(1).set_slot(1, {value={type="virtual", name=mod_prefix.."anchor-using-right-clamp", quality="normal"}, min=value})
  end
end

---Update the specified clamp to
---possibly update the priority/limit through signals.
---@param clamp_info SpaceshipClampInfo
function SpaceshipClamp.update_clamp_info(clamp_info)
  local entity = clamp_info.main
  if not (entity and entity.valid) then
    SpaceshipClamp.destroy(clamp_info)
    return
  end

  if clamp_info.spaceship_limit_set_by_circuit then
    local signal = entity.get_signal(SpaceshipClamp.signal_for_spaceship_limit, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
    clamp_info.spaceship_limit = math.max(0, math.min(signal, SpaceshipClamp.max_spaceship_limit))
  end

  if clamp_info.priority_set_by_circuit then
    local signal = entity.get_signal(SpaceshipClamp.signal_for_priority, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
    clamp_info.priority = math.max(0, math.min(signal, SpaceshipClamp.max_priority))
  end
end

---This tick handler will check all
---@param event EventData.on_tick
function SpaceshipClamp.on_tick(event)
  for clamp_unitnumber, clamp_info in pairs(storage.spaceship_clamps) do
    if (event.tick + clamp_unitnumber) % 60 == 0 then
      SpaceshipClamp.update_clamp_info(clamp_info)
    end
  end
end
Event.addListener(defines.events.on_tick, SpaceshipClamp.on_tick)

local function update_guis()
  for _, player in pairs(game.connected_players) do
    SpaceshipClampGUI.update(player, true) -- To ignore input fields while player has it open
  end
end
Event.addListener("on_nth_tick_60", update_guis)

---@param clamp_info SpaceshipClampInfo?
---@return Tags?
function SpaceshipClamp.serialize_from_struct(clamp_info)
  if not clamp_info then return end
  local tags = {}
  tags.tag = clamp_info.tag
  if clamp_info.spaceship_limit_set_by_circuit then
    tags.spaceship_limit_set_by_circuit = clamp_info.spaceship_limit_set_by_circuit
  else
    tags.spaceship_limit = clamp_info.spaceship_limit
  end
  if clamp_info.priority_set_by_circuit then
    tags.priority_set_by_circuit = clamp_info.priority_set_by_circuit
  else
    tags.priority = clamp_info.priority
  end
  return tags
end

---@param entity LuaEntity
---@return Tags?
function SpaceshipClamp.serialize(entity)
  return SpaceshipClamp.serialize_from_struct(SpaceshipClamp.from_entity(entity))
end

---@param entity LuaEntity
---@param tags Tags
function SpaceshipClamp.deserialize(entity, tags)
  local clamp = SpaceshipClamp.from_entity(entity)
  if clamp then

    if clamp.tag then
      local new_tag = tostring(tags.tag)
      if clamp.tag ~= new_tag then
        clamp.tag = new_tag
        SpaceshipClamp.invalidate_reservations(clamp)
      end
    end

    if tags.spaceship_limit_set_by_circuit then
      clamp.spaceship_limit_set_by_circuit = tags.spaceship_limit_set_by_circuit --[[@as boolean?]]
    else
      clamp.spaceship_limit_set_by_circuit = nil
      clamp.spaceship_limit = tags.spaceship_limit --[[@as uint]]
    end
    if tags.priority_set_by_circuit then
      clamp.priority_set_by_circuit = tags.priority_set_by_circuit --[[@as boolean?]]
    else
      clamp.priority_set_by_circuit = nil
      clamp.priority = tags.priority --[[@as uint]]
    end

    -- Fix the direction of the clamp if the blueprint was mirrored
    SpaceshipClamp.validate_clamp_signal(entity)
  end
end

---Handles the player creating a blueprint by setting tags to store the state of clamp
---@param event EventData.on_player_setup_blueprint
function SpaceshipClamp.on_player_setup_blueprint(event)
  util.setup_blueprint(event, {SpaceshipClamp.name_spaceship_clamp_keep}, SpaceshipClamp.serialize)
end
Event.addListener(defines.events.on_player_setup_blueprint, SpaceshipClamp.on_player_setup_blueprint)

---Combinator settings pasted so need to valdiate clamp signal
---@param event EventData.on_entity_settings_pasted
function SpaceshipClamp.on_entity_settings_pasted(event)
  if event.destination and event.destination.valid and event.destination.name == SpaceshipClamp.name_spaceship_clamp_keep then
    SpaceshipClamp.validate_clamp_signal(event.destination)
    local clamp_info = SpaceshipClamp.from_entity(event.destination)
    if clamp_info then
      SpaceshipClamp.invalidate_reservations(clamp_info) -- Because copy-pasting might change the ID.
    end
  end
  util.settings_pasted(event, {SpaceshipClamp.name_spaceship_clamp_keep}, SpaceshipClamp.serialize, SpaceshipClamp.deserialize)

end
Event.addListener(defines.events.on_entity_settings_pasted, SpaceshipClamp.on_entity_settings_pasted)

---@param event EventData.on_player_pipette
function SpaceshipClamp.on_player_pipette(event)
  local player = game.get_player(event.player_index) --[[@cast player -?]]

  -- Fix the case where the player pipette's the external pole and end
  -- up with a hidden entity in their cursor. The expected behavior would
  -- be having the clamp itself. Could maybe be fixed in datastage, but would require
  -- removing the dedicated hidden external pole items.
  local item = event.item
  if not (item and item.valid) then return end
  if item.name == "se-struct-generic-clamp-west" or item.name == "se-struct-generic-clamp-east" then
    -- Player pipette'd the external pole, so we need to redirect to the clamp!
    local selected = player.selected -- Should be the hidden external pole entity
    if not selected then return end
    local clamp = selected.surface.find_entity(SpaceshipClamp.name_spaceship_clamp_keep, selected.position)
    if not clamp then return end -- Should never happen. The pole should always have an assosiated clamp.
    -- Remove the external pole item stack from the cursor
    player.cursor_stack.clear()
    player.pipette_entity(clamp)
  end
end
Event.addListener(defines.events.on_player_pipette, SpaceshipClamp.on_player_pipette)

---@param event EventData.on_player_rotated_entity
function SpaceshipClamp.on_player_rotated_entity(event)
  if event.entity.name == SpaceshipClamp.name_spaceship_clamp_keep then
    event.entity.direction = event.previous_direction
  end
end
Event.addListener(defines.events.on_player_rotated_entity, SpaceshipClamp.on_player_rotated_entity)


function SpaceshipClamp.on_init()
  storage.spaceship_clamps = {}
  storage.spaceship_clamps_by_surface = {}
end
Event.addListener("on_init", SpaceshipClamp.on_init, true)

return SpaceshipClamp
