-- Used for energy transmission and cross-surface energy beam weapons.
local EnergyBeam = {}

EnergyBeam.name_emitter = mod_prefix.."energy-transmitter-emitter"
EnergyBeam.name_chamber = mod_prefix.."energy-transmitter-chamber"
EnergyBeam.name_injector = mod_prefix.."energy-transmitter-injector"
EnergyBeam.name_injector_reactor = mod_prefix.."energy-transmitter-injector-reactor"
EnergyBeam.name_receiver = mod_prefix.."energy-receiver"
EnergyBeam.name_receiver_beam = mod_prefix.."energy-receiver-beam" -- projectile
EnergyBeam.name_glaive_beam = mod_prefix.."energy-glaive-beam" -- projectile
EnergyBeam.name_glaive_beam_sprite = mod_prefix.."energy-glaive-beam-sprite" -- sprite
EnergyBeam.name_glaive_path_fx = mod_prefix.."energy-glaive-path-fx"
EnergyBeam.name_glaive_damage_projectile = mod_prefix.."energy-glaive-damage-projectile"
EnergyBeam.name_glaive_damage_aoe = mod_prefix.."energy-glaive-damage-aoe"
EnergyBeam.name_glaive_damage_aoe_large = mod_prefix.."energy-glaive-damage-aoe-large"
EnergyBeam.name_glaive_damage_aoe_large_10 = mod_prefix.."energy-glaive-damage-aoe-large-10"

EnergyBeam.emitter_width = 10
EnergyBeam.chamber_box = {x=8, y=4}
EnergyBeam.injector_length = 5

EnergyBeam.name_transmitter_targeter = mod_prefix .. "energy-transmitter-targeter"
EnergyBeam.name_transmitter_effect = mod_prefix .. "energy-transmitter-beam"
EnergyBeam.transfer_interval = 60
EnergyBeam.specific_heat = 1000000000 -- 1GJ
EnergyBeam.receiver_specific_heat = 500000000

EnergyBeam.injector_donate_rate = 0.05
EnergyBeam.injector_waste_rate = 0.005
EnergyBeam.beam_speed_base = 0.05
EnergyBeam.beam_speed_temperature_multiplier = 0.06
EnergyBeam.beam_speed_temperature_exponent = 0.7
EnergyBeam.beam_jump_threshold = 512
EnergyBeam.large_aoe_heat = 100

EnergyBeam.glaive_cost_aoe = 0.5
EnergyBeam.glaive_cost_aoe_large = 1.2
EnergyBeam.glaive_cost_aoe_large_10 = 12

-- [originID][destinationID] = efficiency
---@type table<uint, table<uint, number>>
EnergyBeam.cache_transmission_efficiency = {}

---Gets the energy beam emitter data for the given unit_number.
---@param unit_number uint Unit number of emitter entity
---@return EnergyBeamEmitterInfo? tree
function EnergyBeam.from_unit_number(unit_number)
  if not unit_number then Log.debug("EnergyBeam.from_unit_number: invalid unit_number: nil") return end
  unit_number = tonumber(unit_number)
  if storage.energy_transmitters[unit_number] then
    return storage.energy_transmitters[unit_number]
  else
    Log.debug("EnergyBeam.from_unit_number: invalid unit_number: " .. unit_number)
  end
end

---Gets the energy beam emitter data for the given entity.
---@param entity LuaEntity Emitter entity
---@return EnergyBeamEmitterInfo? tree
function EnergyBeam.from_entity (entity)
  if not(entity and entity.valid) then
    Log.debug("EnergyBeam.from_entity: invalid entity")
    return
  end
  return EnergyBeam.from_unit_number(entity.unit_number)
end

---Does the enery beamer have a destination set?
---@param tree EnergyBeamEmitterInfo Beam emitter data
---@return AnyZoneType? zone
function EnergyBeam.has_destination(tree)
  return tree and tree.destination and tree.destination.coordinate and tree.destination.zone
end

---Returns the transmission efficiency of beaming energy from a given origin to a given destination.
---@param origin AnyZoneType Source zone
---@param destination AnyZoneType Destination zone
---@return number efficiency
function EnergyBeam.get_transmission_efficiency(origin, destination)
  local cache_origin = EnergyBeam.cache_transmission_efficiency[origin.index] or {}
  local cache_destination = cache_origin[destination.index]
  if not cache_destination then
    local delta_v = Zone.get_launch_delta_v(origin) + Zone.get_travel_delta_v(origin, destination)
    local efficiency = 1- delta_v/(delta_v+10000)
    if destination.type == "anomaly" or origin.type == "anomaly" then
      efficiency = efficiency * 0.01
    else
      local origin_stellar_position = Zone.get_stellar_position(origin)
      local destination_stellar_position = Zone.get_stellar_position(destination)
      if origin_stellar_position and destination_stellar_position then -- interstellar less effective
        if Util.vectors_delta_length(origin_stellar_position, destination_stellar_position) > 0.001 then
          efficiency = efficiency * 0.5
        end
      else
        efficiency = efficiency * 0.5
      end
    end
    if Zone.is_solid(origin) then
      ---@cast origin PlanetType|MoonType
      efficiency = efficiency * 0.5
    end
    cache_destination = efficiency
    cache_origin[destination.index] = cache_destination
    EnergyBeam.cache_transmission_efficiency[origin.index] = cache_origin
  end
  return cache_destination
end

---Gets the coordinates set for a given beam emitter, if any.
---@param tree EnergyBeamEmitterInfo Beam emitter data
---@return MapPosition? coordinates
function EnergyBeam.get_coordinate(tree)
  if tree.destination and tree.destination.coordinate then
    return tree.destination.coordinate
  end
  --return tree.emitter.position -- return nil
end

---Returns if a target zone is reachable from a given energy beam emitter.
---@param tree EnergyBeamEmitterInfo Beam emitter data
---@param target_zone AnyZoneType|SpaceshipType Target zone
---@return boolean is_reachable
function EnergyBeam.is_reachable_destination(tree, target_zone)
  if target_zone and target_zone.type ~= "spaceship" then
    ---@cast target_zone SpaceshipType
    return true
  else
    return false
  end
end

---Sets the target of an energy beam after verifiying that it's valid.
---@param tree EnergyBeamEmitterInfo Beam emitter data
---@param player? LuaPlayer Player setting target
---@param target_zone? AnyZoneType|SpaceshipType Target zone
---@param coordinates? MapPosition Target coordinates
---@return boolean is_successful
function EnergyBeam.set_target(tree, player, target_zone, coordinates)
  if target_zone then
    if EnergyBeam.is_reachable_destination(tree, target_zone) then
      if coordinates and target_zone.radius and util.vector_length(coordinates) > target_zone.radius then
        if player then
          player.print({"space-exploration.target-out-of-bounds",
          "item/" .. EnergyBeam.name_emitter,
            Zone.get_print_name(target_zone), math.floor(coordinates.x), math.floor(coordinates.y)})
        end
        return false
      end

      tree.destination.zone = target_zone
      tree.destination.coordinate = coordinates
      tree.destination.enemy = nil

      if player then
        player.print({"space-exploration.target-set",
          "item/" .. EnergyBeam.name_emitter,
          {"space-exploration.target-label-energy-transmitter"},
          Zone.get_print_name(target_zone), math.floor(coordinates.x), math.floor(coordinates.y)})
      end

      Log.debug("Emitter destination set to: " .. target_zone.name )
      return true
    else
      -- Inform the player that the chosen target_zone was not reachable
      if player then
        player.print({"space-exploration.energy-transmitter-invalid-destination",
          Zone.get_print_name(tree.zone), Zone.get_print_name(target_zone)})
      end

      Log.debug("Attempted to set unreachable emitter destination: " .. target_zone.name)
      return false
    end
  else
    tree.destination.zone = nil
    tree.destination.coordinate = nil
    tree.destination.enemy = nil

    return true
  end
end

---Destroys the receiver or glaive beam sprites of a given energy beam emitter.
---@param tree EnergyBeamEmitterInfo Beam emitter data
function EnergyBeam.clear_end_beam(tree)
  if tree.receiver_beam then
    if tree.receiver_beam.valid then
      tree.receiver_beam.destroy()
    end
    tree.receiver_beam = nil
  end
  if tree.glaive_beam then
    if tree.glaive_beam.valid then
      tree.glaive_beam.destroy()
    end
    tree.glaive_beam = nil
  end
  EnergyBeam.remove_markers(tree)
end

---Collects heat in a beam emitter from injector reactors.
---@param tree EnergyBeamEmitterInfo Beam emitter data
---@param waste? boolean Should any heat be wasted during collection?
---@return number temperature
function EnergyBeam.collect_heat(tree, waste)
  local temperature = 0
  for _, injector_reactor in pairs(tree.injector_reactors) do
    if injector_reactor.valid then
      local injector_temperature = injector_reactor.temperature
      local heat = (injector_temperature - 15) * EnergyBeam.injector_donate_rate
      if heat > 1 then heat = heat ^ 0.5 end -- reduce overload charge efficiency
      local remove = (injector_temperature - 15) * (waste and EnergyBeam.injector_waste_rate or EnergyBeam.injector_donate_rate)
      injector_reactor.temperature = injector_temperature - remove
      temperature = temperature + heat
    end
  end
  return temperature
end

---@param tree EnergyBeamEmitterInfo
function EnergyBeam.beam_step_idle(tree)
  EnergyBeam.clear_end_beam(tree)
  if tree.emitter_beam and tree.emitter_beam.valid then
    tree.emitter_beam.destroy()
  end

  local temperature = EnergyBeam.collect_heat(tree, true) -- waste
  tree.last_temperature = temperature
  tree.last_efficiency = tree.destination and tree.destination.zone and EnergyBeam.get_transmission_efficiency(tree.zone, tree.destination.zone) or 0
end

---Searchs for an enemy for the energy beam to target when in "auto-glaive" mode
---@param tree EnergyBeamEmitterInfo Beam emitter data
function EnergyBeam.find_enemy(tree)
  local destination_surface = EnergyBeam.get_target_surface_or_turn_off(tree)
  if not destination_surface then return end

  local position = tree.destination.coordinate or {x = 0, y = 0}
  local force = game.forces[tree.force_name]
  local enemy = find_enemy(force, destination_surface, position)

  if enemy then
    tree.destination.coordinate = enemy.position
    tree.destination.enemy = enemy
    force.chart(destination_surface, Util.position_to_area(enemy.position, 32))
    return
  end
  -- nothing found
  game.forces[tree.force_name].print({
    "space-exploration.energy-transmitter-no-enemies-found",
    "[gps="..math.floor(tree.emitter.position.x)..","..math.floor(tree.emitter.position.y)..","..destination_surface.name.."]"
    })
  tree.mode = "off"
end

---@param tree EnergyBeamEmitterInfo
---@param destination_surface LuaSurface
function EnergyBeam.scale_glaive_sprite(tree, destination_surface)
  local position = EnergyBeam.get_coordinate(tree)
  if not position then
    if not (tree.glaive_beam and tree.glaive_beam.valid) then return end
    position = tree.glaive_beam.position
  end

  if not (tree.glaive_beam and tree.glaive_beam.valid) then
    tree.glaive_beam = destination_surface.create_entity{
      name = EnergyBeam.name_glaive_beam,
      position = position,
      target = Util.vectors_add(position, {x=0,y=-1}),
      speed = 0,
      force = tree.force_name
    }
  end
  if not (tree.glaive_beam_sprite_render and tree.glaive_beam_sprite_render.valid) then
    tree.glaive_beam_sprite_render = rendering.draw_sprite{
      target = tree.glaive_beam,
      sprite = EnergyBeam.name_glaive_beam_sprite,
      surface = tree.glaive_beam.surface,
    }
    tree.prev_temp_scale = nil
  end
  local last_temp_scale = math.min(1, tree.last_temperature / 100)
  if tree.prev_temp_scale ~= last_temp_scale then
    tree.glaive_beam_sprite_render.x_scale = 0.4 + 2 * last_temp_scale
    tree.glaive_beam_sprite_render.y_scale = 0.5 + 1.5 * last_temp_scale
    tree.glaive_beam_sprite_render.color = {
      r = 1,
      g = 0.5 + 0.5 * last_temp_scale,
      b = 0.5 + 0.5 * last_temp_scale
    }
    tree.prev_temp_scale = last_temp_scale
  end

end

---@param tree EnergyBeamEmitterInfo
function EnergyBeam.remove_markers(tree)
  if tree.markers then
    for _, marker in pairs(tree.markers) do
      if marker and marker.valid then
        marker.destroy()
      end
    end
  end
  tree.markers = nil
end

---@param tree EnergyBeamEmitterInfo
function EnergyBeam.add_markers(tree)
  EnergyBeam.remove_markers(tree)
  if tree.glaive_beam and tree.glaive_beam.valid then
    tree.markers = {}
    for force_name, forcedata in pairs(storage.forces) do
      if force_name ~= "friendly" and force_name ~= "ignore" and force_name ~= "capture" then
        tree.markers[force_name] = game.forces[force_name].add_chart_tag(tree.glaive_beam.surface, {
          icon = {type = "virtual", name = mod_prefix.."heat"},
          position = tree.glaive_beam.position,
          text = "Energy Glaive"
        })
      end
    end
  end
end

---@param tree EnergyBeamEmitterInfo
function EnergyBeam.beam_step(tree)
  local mode = tree.mode or "off"
  local position = EnergyBeam.get_coordinate(tree)
  if position == nil and mode == "auto-glaive" and tree.destination.zone then
    EnergyBeam.find_enemy(tree)
    position = EnergyBeam.get_coordinate(tree)
  end

  if mode == "off" or (not position) or not (tree.destination and tree.destination.zone) then
    EnergyBeam.beam_step_idle(tree)
  else

    local efficiency = EnergyBeam.get_transmission_efficiency(tree.zone, tree.destination.zone)
    tree.last_efficiency = efficiency
    local destination_surface = EnergyBeam.get_target_surface_or_turn_off(tree)
    if not destination_surface then return end
    local emitter_beam = false

    if mode == "energise" then
      local receiver = destination_surface.find_entity(EnergyBeam.name_receiver, position)
      if receiver then
        local temperature = EnergyBeam.collect_heat(tree)
        tree.last_temperature = temperature
        if temperature > 0.1 then
          emitter_beam = true
          if tree.glaive_beam then EnergyBeam.clear_end_beam(tree) end
          receiver.temperature = receiver.temperature + (temperature * efficiency) * (EnergyBeam.specific_heat / EnergyBeam.receiver_specific_heat)
          if not (tree.receiver_beam and tree.receiver_beam.valid) then
            tree.receiver_beam = destination_surface.create_entity{
              name = EnergyBeam.name_receiver_beam,
              position = receiver.position,
              target = Util.vectors_add(receiver.position, {x=0,y=-1}),
              speed = 0
            }
          end
        end
      else
        EnergyBeam.beam_step_idle(tree)
      end
      if emitter_beam == false then EnergyBeam.clear_end_beam(tree) end

    elseif mode == "glaive" or mode == "auto-glaive" then

      local temperature = EnergyBeam.collect_heat(tree)
      tree.last_temperature = temperature
      if temperature > 0.1 then
        EnergyBeamDefence.zone_add_pressure(tree.destination.zone, tree)

        if tree.receiver_beam then EnergyBeam.clear_end_beam(tree) end
        tree.glaive_energy = (tree.glaive_energy or 0) + temperature * efficiency
        if EnergyBeamDefence.zone_is_defended(tree.destination.zone, tree.force_name) then
          -- the beam is blocked but pressure is being applied
          if tree.glaive_beam and tree.glaive_beam.valid then
            tree.glaive_beam.destroy()
            tree.glaive_beam = nil
          end
          tree.glaive_energy = 0
          emitter_beam = true
        else
          if tree.glaive_energy > 0.1 then
            emitter_beam = true
          end
          if emitter_beam == false then
            EnergyBeam.beam_move(tree) -- removes?
          else
            EnergyBeam.scale_glaive_sprite(tree, destination_surface)
            if mode == "auto-glaive" then
              -- find target
              if tree.destination.coordinate == nil or Util.vectors_delta_length(tree.destination.coordinate, tree.glaive_beam.position) < 0.1 then
                EnergyBeam.find_enemy(tree)
              end
            end
            tree.glaive_beam.surface.create_entity{
              name = "fire-flame-on-tree",
              position = tree.glaive_beam.position,
              force = tree.force_name
            }
            EnergyBeam.add_markers(tree)
          end
        end
      end
    end

    if emitter_beam then
      if not (tree.emitter_beam and tree.emitter_beam.valid) then
        tree.emitter_beam = tree.emitter.surface.create_entity{
          name = EnergyBeam.name_transmitter_effect,
          position = tree.emitter.position,
          target = {x = tree.emitter.position.x, y = tree.emitter.position.y - 1},
          speed = 0}
      end
    else
      if tree.emitter_beam and tree.emitter_beam.valid then
        tree.emitter_beam.destroy()
      end
    end
  end
end

---@param tree EnergyBeamEmitterInfo
function EnergyBeam.beam_move(tree)
  local destination_surface = EnergyBeam.get_target_surface_or_turn_off(tree)
  if not destination_surface then return end

  local position = EnergyBeam.get_coordinate(tree)
  if not position then
    if not (tree.glaive_beam and tree.glaive_beam.valid) then return end
    position = tree.glaive_beam.position
  end

  EnergyBeam.scale_glaive_sprite(tree, destination_surface)
  local curent_position = tree.glaive_beam.position

  local move_speed = EnergyBeam.beam_speed_base * (1 + (EnergyBeam.beam_speed_temperature_multiplier * tree.last_temperature) ^ EnergyBeam.beam_speed_temperature_exponent)
  local new_position =
    util.vectors_delta_length(curent_position, position) < EnergyBeam.beam_jump_threshold and
    util.move_to(curent_position, position, move_speed, false) or position
  tree.glaive_beam.teleport(new_position)

  if tree.mode == "auto-glaive" then
    -- update the target position to a potentially moving enemy
    local target_valid = tree.destination.enemy and tree.destination.enemy.valid and tree.destination.enemy.destructible

    if target_valid then
      tree.destination.coordinate = tree.destination.enemy.position
    elseif Util.vectors_delta_length(new_position, position) < 0.1 then
      -- find a new enemy if we are at the destination and the enemy is not still alive
      EnergyBeam.find_enemy(tree)
    end
  end

  tree.glaive_energy_2 = tree.glaive_energy_2 or 0
  if tree.glaive_energy_2 < tree.glaive_energy then
    tree.glaive_energy_2 = tree.glaive_energy_2 + tree.glaive_energy / 600
    tree.glaive_energy = tree.glaive_energy - tree.glaive_energy / 600
  end

  local energy_to_use = tree.glaive_energy_2 / 100
  local energy_used = 0
  --local cost_projectile = 0.05

  local surface = tree.glaive_beam.surface
  if (new_position.x ~= curent_position.x or new_position.y ~= curent_position.y) and math.random() < 0.1 then
    surface.create_entity{
      name = "fire-flame-on-tree",
      position = new_position,
      force = tree.force_name
    }
    surface.create_entity{
      name = EnergyBeam.name_glaive_path_fx,
      position = new_position,
      force = tree.force_name
    }
  end

  local continue = energy_used + EnergyBeam.glaive_cost_aoe_large <= energy_to_use
  while continue do
    if tree.last_temperature > EnergyBeam.large_aoe_heat then
      if energy_used + EnergyBeam.glaive_cost_aoe_large_10 <= energy_to_use then
        energy_used = energy_used + EnergyBeam.glaive_cost_aoe_large_10
        surface.create_entity{
          name = EnergyBeam.name_glaive_damage_aoe_large_10,
          position = new_position,
          force = tree.force_name
        }
      else
        energy_used = energy_used + EnergyBeam.glaive_cost_aoe_large
        surface.create_entity{
          name = EnergyBeam.name_glaive_damage_aoe_large,
          position = new_position,
          force = tree.force_name
        }
      end
    else
      local r = math.random()
      if r < tree.last_temperature/EnergyBeam.large_aoe_heat then -- transition the damage to lower direct dps but larger area as it gets towards 100 GW
        energy_used = energy_used + EnergyBeam.glaive_cost_aoe_large
        surface.create_entity{
          name = EnergyBeam.name_glaive_damage_aoe_large,
          position = new_position,
          force = tree.force_name
        }
      else
        energy_used = energy_used + EnergyBeam.glaive_cost_aoe
        surface.create_entity{
          name = EnergyBeam.name_glaive_damage_aoe,
          position = new_position,
          force = tree.force_name
        }
      end
    end
    --[[else
      energy_used = energy_used + cost_projectile
      tree.glaive_beam.surface.create_entity{
        name = EnergyBeam.name_glaive_damage_projectile,
        position = tree.glaive_beam.position,
        target = Util.vectors_add(tree.glaive_beam.position, Util.orientation_to_vector(math.random(), 5)),
        speed = 1,
        max_range = 5,
        force = tree.force_name
      }
    end]]
    --break loop if we destroyed the beam emitter yet still have power to use this tick
    continue = (energy_used + EnergyBeam.glaive_cost_aoe_large <= energy_to_use) and tree.glaive_beam ~= nil
  end
  tree.glaive_energy_2 = tree.glaive_energy_2 - energy_used
end

---@param tree EnergyBeamEmitterInfo
---@param event EntityRemovalEvent the event that triggered the destruction if it was caused by an event
function EnergyBeam.destroy(tree, event)
  if not tree then
    Log.debug("tree_destroy: no tree")
    return
  end

  tree.valid = false
  EnergyBeam.clear_end_beam(tree)
  if tree.emitter_beam and tree.emitter_beam.valid then
    tree.emitter_beam.destroy()
  end

  if not event or event.name == defines.events.on_entity_died then
    -- For died it will be cleaned in post_died event
    storage.energy_transmitters[tree.unit_number] = nil
  end

  -- if a player has this gui open then close item-layer
  local gui_name = EnergyBeamGUI.name_transmitter_gui_root
  for _, player in pairs(game.connected_players) do
    local root = player.gui.relative[gui_name]
    if root and root.tags and root.tags.unit_number == tree.unit_number then
      root.destroy()
    end
  end
end

---@param event EventData.on_tick Event data
function EnergyBeam.on_tick(event)
  -- beam update
  for unit_number, tree in pairs(storage.energy_transmitters) do
    if (event.tick + unit_number) % 60 == 0 then
      EnergyBeam.beam_step(tree)
    elseif tree.glaive_beam then
      EnergyBeam.beam_move(tree)
    end
  end
end
Event.addListener(defines.events.on_tick, EnergyBeam.on_tick)

-- gui update
---@param event NthTickEventData Event data
function EnergyBeam.on_nth_tick_60(event)
  for _, player in pairs(game.connected_players) do
    EnergyBeamGUI.gui_update(player)
  end
end
Event.addListener("on_nth_tick_60", EnergyBeam.on_nth_tick_60)


---Handles the player selecting a target for the energy beam emitter.
---@param event EventData.CustomInputEvent Event data
function EnergyBeam.on_targeter(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if not player then return end
  local cursor_item = player.cursor_stack
  if not (cursor_item and cursor_item.valid_for_read) then return end
  if cursor_item.name ~= EnergyBeam.name_transmitter_targeter then return end
  local remote_view_activity = RemoteView.get_activity(player, "energy-beam-emitter")
  if not remote_view_activity then return end
  local tree = remote_view_activity.tree
  local destination_zone = Zone.from_surface(player.surface)
  if not (tree and tree.emitter and tree.emitter.valid and destination_zone) then return end
  local coordinates = event.cursor_position
  local is_successful = EnergyBeam.set_target(tree, player, destination_zone, coordinates)
  if is_successful then
    player.print({"space-exploration.target-set",
        "item/" .. EnergyBeam.name_emitter,
        {"space-exploration.target-label-energy-transmitter"},
        Zone.get_print_name(destination_zone),
        math.floor(tree.destination.coordinate.x),
        math.floor(tree.destination.coordinate.y)})
    if tree.mode == "energise" then
      EnergyBeam.clear_end_beam(tree)
    end
  end
end
Event.addListener(mod_prefix .. "-targeter", EnergyBeam.on_targeter)

---@param name string item name
---@return boolean
function EnergyBeam.is_targeter(name)
  return name == EnergyBeam.name_transmitter_targeter
end

function EnergyBeam.on_init()
    storage.energy_transmitters = {}
end
Event.addListener("on_init", EnergyBeam.on_init, true)

---@param zone AnyZoneType
---@param immediate? true
function EnergyBeam.rebuild_trees(zone, immediate)

  -- remove old tick tasks
  for _, tick_task in pairs(storage.tick_tasks) do
    ---@cast tick_task GrowEnergyTreeTickTask
    if tick_task.type == "grow_energy_tree" and tick_task.zone == zone then
      tick_task.valid = false
      storage.tick_tasks[tick_task.id] = nil
    end
  end

  if zone then
    local tick_task = new_tick_task("grow_energy_tree") --[[@as GrowEnergyTreeTickTask]]
    tick_task.zone = zone

    if immediate then
      EnergyBeam.grow_energy_tree(tick_task)
    end
  end
end

---@param tick_task GrowEnergyTreeTickTask
function EnergyBeam.grow_energy_tree(tick_task)
  local zone = tick_task.zone
  local surface = Zone.get_surface(zone)

  if not tick_task.emitters then
    -- init
    zone.energy_transmitters = zone.energy_transmitters or {}
    for unit_number, tree in pairs(zone.energy_transmitters) do
      if not tree.emitter.valid then
        -- remove invalid trees
        zone.energy_transmitters[unit_number] = nil
        storage.energy_transmitters[unit_number] = nil

      else
        tree.chamberes = {}
        tree.leaves = {}
        tree.injector_reactors = {}
        tree.open = {tree.emitter}
      end
    end

    tick_task.emitters = surface.find_entities_filtered{name = EnergyBeam.name_emitter}
    for _, emitter in pairs(tick_task.emitters) do
      if not zone.energy_transmitters[emitter.unit_number] then
        zone.energy_transmitters[emitter.unit_number] = {
          type = "energy-beam-emitter-tree",
          unit_number = emitter.unit_number,
          valid = true,
          zone = zone,
          force_name = emitter.force.name,
          emitter = emitter,
          chamberes = {},
          leaves = {},
          injector_reactors = {},
          open = {emitter},
          destination = {type = "zone", zone = zone}
        } --[[@as EnergyBeamEmitterInfo]]
        storage.energy_transmitters[emitter.unit_number] = zone.energy_transmitters[emitter.unit_number]
      end
    end
    -- chamberes are moreved from the list as they are assigned to trees
    tick_task.chamberes = surface.find_entities_filtered{name = EnergyBeam.name_chamber}

    -- when a chamber is added to a tree, trach the tree for the chamber (so leaves can find the tree by finding the chamber)
    tick_task.chamber_trees = {}
  end

  tick_task.valid = false -- end unless chamberes are found

  for _, tree in pairs(zone.energy_transmitters) do
    local open = tree.open
    tree.open = {}
    for _, entity in pairs(open) do
      if entity.name == EnergyBeam.name_emitter then
        -- find chamberes connected end-on
        local extent = (EnergyBeam.emitter_width + EnergyBeam.chamber_box.x)/2
        for i, chamber in pairs(tick_task.chamberes) do
          if (chamber.position.x == entity.position.x and (chamber.position.y == entity.position.y + extent or chamber.position.y == entity.position.y - extent))
           or (chamber.position.y == entity.position.y and (chamber.position.x == entity.position.x + extent or chamber.position.x == entity.position.x - extent)) then
            tree.chamberes[chamber.unit_number] = chamber
            tree.open[chamber.unit_number] = chamber
            tick_task.chamber_trees[chamber.unit_number] = tree
            tick_task.chamberes[i] = nil
            tick_task.valid = true
          end
        end
      elseif entity.name == EnergyBeam.name_chamber then
        -- find chamberes connected
        local extent_short = (EnergyBeam.chamber_box.x + EnergyBeam.chamber_box.y) / 2
        local extent_long = (EnergyBeam.chamber_box.x + EnergyBeam.chamber_box.x) / 2
        local is_horizontal = entity.direction == defines.direction.east or entity.direction == defines.direction.west
        for i, chamber in pairs(tick_task.chamberes) do
          local chamber_is_horizontal = chamber.direction == defines.direction.east or chamber.direction == defines.direction.west
          if (is_horizontal ~= chamber_is_horizontal and ((chamber.position.x == entity.position.x and (chamber.position.y == entity.position.y + extent_short or chamber.position.y == entity.position.y - extent_short))
           or (chamber.position.y == entity.position.y and (chamber.position.x == entity.position.x + extent_short or chamber.position.x == entity.position.x - extent_short))))
           or (is_horizontal == chamber_is_horizontal and ((chamber.position.x == entity.position.x and (chamber.position.y == entity.position.y + extent_long or chamber.position.y == entity.position.y - extent_long))
            or (chamber.position.y == entity.position.y and (chamber.position.x == entity.position.x + extent_long or chamber.position.x == entity.position.x - extent_long)))) then
              tree.chamberes[chamber.unit_number] = chamber
              tick_task.chamber_trees[chamber.unit_number] = tree
              tree.open[chamber.unit_number] = chamber
              tick_task.chamberes[i] = nil
              tick_task.valid = true
          end
        end
      end
    end
  end

  if not tick_task.valid then -- finished the chamberes, add the leaves
    for _, entity in pairs(surface.find_entities_filtered{name = EnergyBeam.name_injector}) do
      local direction = entity.direction
      local is_horizontal = direction == defines.direction.east or direction == defines.direction.west
      local vector = Util.direction_to_vector(direction)

      local chamber = surface.find_entities_filtered({
        name = EnergyBeam.name_chamber,
        position = Util.vectors_add(entity.position, Util.vector_multiply(vector, (EnergyBeam.injector_length + 1)/2)),
        limit = 1,
      })[1]
      if chamber then
        local chamber_is_horizontal = chamber.direction == defines.direction.east or chamber.direction == defines.direction.west
        if is_horizontal ~= chamber_is_horizontal then
          -- if the chamber is part of a tree
          if tick_task.chamber_trees[chamber.unit_number] then
            -- add the injector to the tree
            local injector_reactor = surface.find_entity(EnergyBeam.name_injector_reactor, entity.position)
            if injector_reactor then
              tick_task.chamber_trees[chamber.unit_number].leaves[entity.unit_number] = entity
              tick_task.chamber_trees[chamber.unit_number].injector_reactors[injector_reactor.unit_number] = injector_reactor
            end
          end
        end
      end
    end
    -- for _, tree in pairs(zone.energy_transmitters) do
    --   Log.debug(table_size(tree.leaves))
    -- end
  end

end

---@param tree EnergyBeamEmitterInfo
---@return LuaSurface?
function EnergyBeam.get_target_surface_or_turn_off(tree)
  local destination_surface = tree.destination.zone and Zone.get_surface(tree.destination.zone)
  if not destination_surface then -- Surface was deleted
    tree.mode = "off"
    EnergyBeam.set_target(tree, nil, nil, nil)
    EnergyBeam.clear_end_beam(tree)
    return nil
  else
    return destination_surface
  end
end

---Handles creation of energy beam-related entities.
---@param event EntityCreationEvent|EventData.on_entity_cloned Event data
function EnergyBeam.on_entity_created(event)
  local entity = event.entity or event.destination
  if not entity.valid then return end
  local entity_name = entity.name

  if entity_name == EnergyBeam.name_chamber
    or entity_name == EnergyBeam.name_injector
    or entity_name == EnergyBeam.name_emitter then
    local zone = Zone.from_surface(entity.surface)
    if cancel_creation_when_invalid(zone, entity, event) then return end
    ---@cast zone -?
    if zone and zone.type == "spaceship" then
      ---@cast zone SpaceshipType
      cancel_entity_creation(entity, event.player_index, {"space-exploration.construction-denied"}, event)
    end

    if entity_name == EnergyBeam.name_chamber then
      --
    elseif entity_name == EnergyBeam.name_injector then
      local reactor = entity.surface.create_entity{
        name = EnergyBeam.name_injector_reactor,
        position = entity.position,
        force = entity.force}
        ---@cast reactor -?
      reactor.destructible = false
    end
    EnergyBeam.rebuild_trees(zone, true)
    local tree = storage.energy_transmitters[entity.unit_number]

    -- Apply settings if any
    local tags = util.get_tags_from_event(event, EnergyBeam.serialize)
    if tags then EnergyBeam.deserialize(entity, tags) end

    if tree and entity_name == EnergyBeam.name_emitter
      and event.player_index
      and game.get_player(event.player_index)
      and game.get_player(event.player_index).connected then
      EnergyBeamGUI.gui_open(game.get_player(event.player_index), tree)
    end
  end
end
Event.addListener(defines.events.on_entity_cloned, EnergyBeam.on_entity_created)
Event.addOnEntityCreatedListeners(EnergyBeam.on_entity_created)

---Handles removal of energy beam-related entities.
---@param event EntityRemovalEvent Event data
function EnergyBeam.on_entity_removed(event)
  local entity = event.entity
  if not entity.valid then return end
  local entity_name = entity.name
  if entity_name == EnergyBeam.name_chamber then
    EnergyBeam.rebuild_trees(Zone.from_surface(entity.surface))
  elseif entity_name == EnergyBeam.name_injector then
    EnergyBeam.rebuild_trees(Zone.from_surface(entity.surface))
    local reactor = entity.surface.find_entity(EnergyBeam.name_injector_reactor, entity.position)
    if reactor then reactor.destroy() end
  elseif entity_name == EnergyBeam.name_emitter then
    EnergyBeam.rebuild_trees(Zone.from_surface(entity.surface))
    local tree = EnergyBeam.from_entity(entity)
    if tree then
      EnergyBeam.destroy(tree, event)
    end
  elseif entity_name == EnergyBeam.name_receiver then
    local beam = entity.surface.find_entity(EnergyBeam.name_receiver_beam, entity.position)
    if beam then beam.destroy() end
  end

end
Event.addOnEntityRemovedListeners(EnergyBeam.on_entity_removed)

---@param event EventData.on_post_entity_died
local function on_post_entity_died(event)
  local ghost = event.ghost
  local unit_number = event.unit_number
  if not (ghost and unit_number) then return end
  if event.prototype.name ~= EnergyBeam.name_emitter then return end
  ghost.tags = EnergyBeam.serialize_from_struct(storage.energy_transmitters[unit_number])
  storage.energy_transmitters[unit_number] = nil
end
Event.addListener(defines.events.on_post_entity_died, on_post_entity_died)

---@param tree EnergyBeamEmitterInfo?
---@return Tags?
function EnergyBeam.serialize_from_struct(tree)
  if tree then
    local tags = {}
    if tree.destination then
      tags.destination = {
        coordinate = tree.destination.coordinate,
        zone_name = tree.destination.zone and tree.destination.zone.name
      }
    end
    tags.mode = tree.mode
    return tags
  end
end

---@param entity LuaEntity
---@return Tags?
function EnergyBeam.serialize(entity)
  return EnergyBeam.serialize_from_struct(EnergyBeam.from_entity(entity))
end

---@param entity LuaEntity
---@param tags Tags
function EnergyBeam.deserialize(entity, tags)
  local tree = EnergyBeam.from_entity(entity)
  if tree then
    if tags.destination then
      local coordinates = table.deepcopy(tags.destination.coordinate)
      local target_zone = Zone.from_name(tags.destination.zone_name)

      EnergyBeam.set_target(tree, nil, target_zone, coordinates)
    end
    tree.mode = tags.mode
  end
end

---Handles the player creating a blueprint by setting tags to store the state of energy emitters.
---@param event EventData.on_player_setup_blueprint Event data
function EnergyBeam.on_player_setup_blueprint(event)
  util.setup_blueprint(event, EnergyBeam.name_emitter, EnergyBeam.serialize)
end
Event.addListener(defines.events.on_player_setup_blueprint, EnergyBeam.on_player_setup_blueprint)

---Handles the player copy/pasting settings between energy emitters.
---@param event EventData.on_entity_settings_pasted Event data
function EnergyBeam.on_entity_settings_pasted(event)
  util.settings_pasted(event, EnergyBeam.name_emitter, EnergyBeam.serialize, EnergyBeam.deserialize,
    function(entity, player_index)
      local tree = EnergyBeam.from_entity(entity)
      local player = game.get_player(player_index)
      if tree and tree.destination and tree.destination.coordinate then
        player.print({"space-exploration.target-pasted",
          "item/" .. EnergyBeam.name_emitter,
          {"space-exploration.target-label-energy-transmitter"},
          Zone.get_print_name(tree.destination.zone),
          math.floor(tree.destination.coordinate.x),
          math.floor(tree.destination.coordinate.y)})
      end
    end)
end
Event.addListener(defines.events.on_entity_settings_pasted, EnergyBeam.on_entity_settings_pasted)

---Debug renderer to check which injectors and chambers are registered to which emitter.
---@param event EventData.on_selected_entity_changed
function EnergyBeam.on_selected_entity_changed(event)
  local player = game.get_player(event.player_index)

  local selected = player.selected
  if not selected then return end

  if selected.name ~= EnergyBeam.name_emitter then return end -- EnergyBeam.from_entity(selected) prints an error otherwise

  local tree = EnergyBeam.from_entity(selected)
  if not tree then return end

  for _, entities in pairs({tree.chamberes, tree.leaves}) do
    for _, entity in pairs(entities) do
      selected.surface.create_entity{
        name = "highlight-box",
        position = entity.position,
        bounding_box = entity.selection_box,
        box_type = "train-visualization",
        render_player_index = player.index,
        time_to_live = 1 * second,
      }
    end
  end
end
Event.addListener(defines.events.on_selected_entity_changed, EnergyBeam.on_selected_entity_changed)

return EnergyBeam
