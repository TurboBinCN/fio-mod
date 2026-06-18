local SpaceshipClone = {}

--list of entities to not generically clone
SpaceshipClone.names_excluded_map = core_util.list_to_map{
  Spectator.name_seat,
  Capsule.name_space_capsule_container,
  Capsule.name_space_capsule_scorched_container,
  Capsule.name_space_capsule_vehicle_light,
  Capsule.name_space_capsule_vehicle_light_launch,
  Capsule.name_space_capsule_vehicle_shadow,
  Launchpad.name_rocket_launch_pad_seat,
  "shield-projector-barrier"
}

SpaceshipClone.types_excluded_map = core_util.list_to_map{
  "character",
  "car",
  "spider-vehicle",
  "rocket-silo-rocket",
  "cliff",
  "tile-ghost"
}

--list of vehicles to not teleport
SpaceshipClone.vehicles_excluded_map = core_util.list_to_map{
  Spectator.name_seat,
  Launchpad.name_rocket_launch_pad_seat,
  "shield-projector-barrier"
}

SpaceshipClone.mineable_tile_prototypes = nil -- cache of minable tiles to check against hidden tiles
SpaceshipClone.spaced_names = nil -- lists of entities allowed on various surface types
SpaceshipClone.unspaced_names = nil
SpaceshipClone.grounded_names = nil
SpaceshipClone.ungrounded_names = nil

---Adds a delta vector to a given position.
---@param position MapPosition Starting position
---@param delta Delta
---@return MapPosition.0
local function _add_delta_to_position(position, delta)
  return {
    x = (position.x or position[1]) + delta.dx,
    y = (position.y or position[2]) + delta.dy,
  }
end

--Checks if a tile isn't minable, so we should clear it as a hidden tile
---@param tile string
---@return boolean
function SpaceshipClone.check_tile_non_deconstruct(tile)
  if not SpaceshipClone.mineable_tile_prototypes then
    SpaceshipClone.mineable_tile_prototypes = prototypes.get_tile_filtered{{filter = "minable"}}
  end
  return not SpaceshipClone.mineable_tile_prototypes[tile]
end

---Builds the arrays of entities that are cared about for the purposes of grounding/spacing.
function SpaceshipClone.build_spaced_grounded_table()
  if SpaceshipClone.spaced_names then return end

  SpaceshipClone.spaced_names = {}
  SpaceshipClone.unspaced_names = {}
  SpaceshipClone.grounded_names = {}
  SpaceshipClone.ungrounded_names = {}
  for name, _ in pairs(prototypes.entity) do
    if string.find(name, name_suffix_spaced, 1, true) then
      table.insert(SpaceshipClone.spaced_names, name)
      table.insert(SpaceshipClone.unspaced_names, util.replace(name, name_suffix_spaced, ""))
    elseif string.find(name, name_suffix_grounded, 1, true) then
      table.insert(SpaceshipClone.grounded_names, name)
      table.insert(SpaceshipClone.ungrounded_names, util.replace(name, name_suffix_grounded, ""))
    end
  end
end

--- Grounds or ungrounds entities
--- Used to ensure that entities space buildings can't have space recipes on the ground
--- and similar things. Swaps entities betweened normal, spaced, and grounded versions
---@param from_surface LuaSurface surface the clone is coming from
---@param to_surface LuaSurface surface the clone is going to
---@param from_zone AnyZoneType|SpaceshipType zone the clone is coming from
---@param to_zone AnyZoneType|SpaceshipType zone the clone is going to
---@param from_area BoundingBox area on the from_surface the clone is coming from
---@param to_area BoundingBox area on the to_surface the clone is going to
function SpaceshipClone.ground_unground_entities(from_surface, to_surface, from_zone, to_zone, from_area, to_area)
  SpaceshipClone.build_spaced_grounded_table()
  if Zone.is_space(from_zone) ~= Zone.is_space(to_zone) then
    if Zone.is_space(to_zone) then
      ---@cast to_zone -PlanetType, -MoonType
      local entities_for_unspaced = to_surface.find_entities_filtered{name = SpaceshipClone.unspaced_names, area = to_area}
      for _, entity in pairs(entities_for_unspaced) do
        EntitySwap.swap_structure(entity, entity.name..name_suffix_spaced)
      end
      local entities_for_grounded = to_surface.find_entities_filtered{name = SpaceshipClone.grounded_names, area = to_area}
      for _, entity in pairs(entities_for_grounded) do
        EntitySwap.swap_structure(entity, util.replace(entity.name, name_suffix_grounded, ""))
      end
    else
      ---@cast to_zone PlanetType|MoonType
      local entities_for_ungrounded = to_surface.find_entities_filtered{name = SpaceshipClone.ungrounded_names, area = to_area}
      for _, entity in pairs(entities_for_ungrounded) do
        EntitySwap.swap_structure(entity, entity.name..name_suffix_grounded)
      end
      local entities_for_spaced = to_surface.find_entities_filtered{name = SpaceshipClone.spaced_names, area = to_area}
      for _, entity in pairs(entities_for_spaced) do
        EntitySwap.swap_structure(entity, util.replace(entity.name, name_suffix_spaced, ""))
      end
    end
  end
end

---Enqueues chunk generation requests for the area being cloned to.
---@param spaceship SpaceshipType Spaceship data
---@param clone_from LuaSurface surface to clone from
---@param clone_to LuaSurface surface to clone to
---@param clone_delta Delta the delta between the spaceship's position on clone_from and the target spaceship position on clone_to
---@return uint requests_made
function SpaceshipClone.enqueue_generate_clone_to_area(spaceship, clone_from, clone_to, clone_delta)
  local clone_to_area = {
    left_top = {x = spaceship.known_bounds.left_top.x + clone_delta.dx, y = spaceship.known_bounds.left_top.y + clone_delta.dy},
    right_bottom = {x = spaceship.known_bounds.right_bottom.x + clone_delta.dx, y = spaceship.known_bounds.right_bottom.y + clone_delta.dy},
  }

  local clone_from_zone = Zone.from_surface(clone_from)
  local clone_to_zone = Zone.from_surface(clone_to)

  -- force generate chunks in the area being cloned to
  local x_force_gen_modifier = 0
  local y_force_gen_modifier_sub = 0
  local y_force_gen_modifier_add = 0
  if clone_to_zone and clone_to_zone.type == "spaceship" then
    ---@cast clone_to_zone SpaceshipType
    x_force_gen_modifier = SpaceshipObstacles.particle_spawn_range
    y_force_gen_modifier_sub = SpaceshipObstacles.particle_spawn_range + 20
    y_force_gen_modifier_add = SpaceshipObstacles.particle_spawn_range + 32
  end
  local requests_made = 0
  for x=clone_to_area.left_top.x-32-x_force_gen_modifier,clone_to_area.right_bottom.x+32+x_force_gen_modifier,32 do
    for y=clone_to_area.left_top.y-32-y_force_gen_modifier_sub,clone_to_area.right_bottom.y+32+y_force_gen_modifier_add,32 do
      clone_to.request_to_generate_chunks({x=x,y=y},1)
      requests_made = requests_made + 1
    end
  end
  return requests_made
end

---@param player LuaPlayer
---@param spaceship SpaceshipType Spaceship data
---@param clone_from LuaSurface Surface to clone from
---@param clone_to_area BoundingBox The area being cloned to
---@param clone_delta Delta
function SpaceshipClone.transfer_remote_view(spaceship, player, clone_from, clone_to_area, clone_delta)
  if not RemoteView.is_active(player) then return end
  if player.surface ~= clone_from then return end
  local playerdata = get_make_playerdata(player)

  -- Determine if we should transfer the remote view
  local is_from_spaceship = Zone.from_surface(clone_from).type == "spaceship"
  local player_watching_this_spaceship = playerdata.watching_spaceship == spaceship.index
  local should_transfer_view = is_from_spaceship or player_watching_this_spaceship
  if not should_transfer_view then return end

  -- We can now assume that the player was watching the spaceship before the clone operation.
  -- We will try to maintain the same relative position on the new surface.
  local zoom = player.zoom --[[@as number?]]
  local position = player.position
  position.x = position.x + clone_delta.dx
  position.y = position.y + clone_delta.dy

  if not is_from_spaceship then -- if cloning to spaceship surface

    -- If moving from an non-spaceship surface might have too much of an delta. So in
    -- that case let's clamp the position to something around the spaceship.
    local area = Util.area_extend(clone_to_area, 32) -- Some padding to not be too strict
    if not Util.area_contains_position(area, position) then
      -- The player wandered too far from the spaceship. Let's reset the position onto
      -- the spaceship. We can't rely on `remote-view` to do this because the intergrity
      -- info is outdated. So instead we centered it on the spaceship clone area which
      -- frames it nicely in the middle.
      zoom = nil -- So that it can be calculated by `remote-view`
      position = {
        x = (clone_to_area.left_top.x + clone_to_area.right_bottom.x) / 2,
        y = (clone_to_area.left_top.y + clone_to_area.right_bottom.y) / 2,
      }
    end
  end

  RemoteView.start(player, spaceship, position, zoom)
end

---Clones a spaceship from its current location to a new location (deletes the original as part of
---the cloning).
---@param spaceship SpaceshipType Spaceship data
---@param clone_from LuaSurface Surface to clone from
---@param clone_to LuaSurface Surface to clone to
---@param clone_delta Delta Delta between the spaceship's position on clone_from and the target spaceship position on clone_to
---@param post_clone_cb? fun(spaceship:SpaceshipType, clone_from: LuaSurface, clone_to:LuaSurface, clone_delta:Delta) Callback function to call once the clone completes
function SpaceshipClone.clone(spaceship, clone_from, clone_to, clone_delta, post_clone_cb)
  local tick = game.tick
  local clone_from_area = {
    left_top = {
      x = spaceship.known_bounds.left_top.x,
      y = spaceship.known_bounds.left_top.y
    },
    right_bottom = {
      x = spaceship.known_bounds.right_bottom.x,
      y = spaceship.known_bounds.right_bottom.y
    },
  }
  local clone_to_area = {
    left_top = _add_delta_to_position(spaceship.known_bounds.left_top, clone_delta),
    right_bottom = _add_delta_to_position(spaceship.known_bounds.right_bottom, clone_delta)
  }
  local clone_from_zone = Zone.from_surface(clone_from) --[[@as AnyZoneType|SpaceshipType]]
  local clone_to_zone = Zone.from_surface(clone_to) --[[@as AnyZoneType|SpaceshipType]]
  local to_is_solid = Zone.is_solid(clone_to_zone)
  local to_is_spaceship = clone_to_zone.type == "spaceship"
  local spaceship_known_tiles = spaceship.known_tiles

  -- Flag for cloning in progress
  spaceship.is_cloning = true

  -- If we somehow didn't generate all of the chunks before this call is made, forcibly create them
  clone_to.force_generate_chunk_requests()

  -- Copy ship tiles
  local change_tiles_zone = {}
  local change_tiles_zone_count = 0
  local clone_positions = {}
  local clone_positions_count = 0
  for x = spaceship.known_bounds.left_top.x, spaceship.known_bounds.right_bottom.x do
    for y = spaceship.known_bounds.left_top.y, spaceship.known_bounds.right_bottom.y do
      local value = spaceship_known_tiles[x] and spaceship_known_tiles[x][y]
      if value == "floor_console_connected" or value == "bulkhead_console_connected" then
        local tile = clone_from.get_tile(x, y)
        if Spaceship.names_spaceship_floors_map[tile.name] then
          local to_position = {x = x + clone_delta.dx, y = y + clone_delta.dy}
          change_tiles_zone_count = change_tiles_zone_count + 1
          change_tiles_zone[change_tiles_zone_count] = {name = tile.name, position = to_position}

          local from_position = {x=x, y=y}
          clone_positions_count = clone_positions_count + 1
          clone_positions[clone_positions_count] = from_position
        else
          -- the tile was changed somehow, the ship will be invalid but it is too late to stop launch
        end
      end
    end
  end
  clone_to.set_tiles(change_tiles_zone, true)

  local vehicles = clone_from.find_entities_filtered{
    type = {"car", "spider-vehicle"},
    area = clone_from_area
  }
  local rail_vehicles = clone_from.find_entities_filtered{
    type = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"},
    area = clone_from_area
  }
  local rail_vehicle_drivers = {}

  -- Iterate over cars and spidertrons and teleport them if appropriate
  for _, vehicle in pairs(vehicles) do
    local vehicle_position = vehicle.position

    if Spaceship.is_position_on_spaceship(vehicle_position, spaceship, false) then
      local vehicle_name = vehicle.name

      if vehicle_name == Capsule.name_space_capsule_vehicle or
        vehicle_name == Capsule.name_space_capsule_scorched_vehicle then
        -- Space capsules get special handling to "move" containers, lights, and shadows
        Capsule.teleport_to_surface(vehicle, clone_to, _add_delta_to_position(vehicle.position, clone_delta))
      elseif not SpaceshipClone.vehicles_excluded_map[vehicle_name] then
        teleport_vehicle_to_surface(vehicle, clone_to, _add_delta_to_position(vehicle.position, clone_delta))

        -- Non-space vehicles must be deactivated in space, and reactivated on land
        if vehicle.type == "car" and not string.find(vehicle_name, mod_prefix .. "space", 1, true) then
          vehicle.active = to_is_solid
        end
      end
    end
  end

  -- Gather rail vehicles on board, eject drivers, and keep a record of them
  for index, vehicle in pairs(rail_vehicles) do
    local vehicle_position = vehicle.position --[[@as MapPosition.0]]

    if Spaceship.is_position_on_spaceship(vehicle_position, spaceship, false) then
      local driver = vehicle.get_driver()
      vehicle.set_driver(nil)
      if driver and driver.is_player() then driver = driver.character end -- sets to nil if required
      if driver and driver.valid then
        table.insert(rail_vehicle_drivers, {
          vehicle_name = vehicle.name,
          vehicle_position = vehicle_position,
          driver_name = driver.name,
          driver_position = driver.position
        })
      end
    else
      rail_vehicles[index] = nil
    end
  end

  -- store locomotive status (automatic vs normal)
  local train_settings = {}
  for _, locomotive in pairs(clone_from.find_entities_filtered{
    type = "locomotive",
    area = clone_from_area
  }) do
    local train = locomotive.train --[[@as LuaTrain]]
    if not train_settings[train.id] then
      local locomotive_x = math.floor(locomotive.position.x)
      local locomotive_y = math.floor(locomotive.position.y)
      local value = spaceship.known_tiles[locomotive_x] and spaceship.known_tiles[locomotive_x][locomotive_y]
      if value == "floor_console_connected" then
        train_settings[train.id] = {
          current_stop_index = train.get_schedule().current,
          manual_mode = train.manual_mode,
          name = locomotive.name,
          position = locomotive.position
        }
      end
    end
  end

  -- Teleport characters
  local characters =  clone_from.find_entities_filtered{
    type = "character",
    area = clone_from_area
  }
  for _, character in pairs(characters) do
    local character_position = character.position

    if Spaceship.is_position_on_spaceship(character_position, spaceship, false) then
      local associated_playerdata
      local to_position = _add_delta_to_position(character_position, clone_delta)

      -- Get associated `PlayerData` table, in order to update the `character` field afterwards
      for _, playerdata in pairs(storage.playerdata) do
        if playerdata.character == character then
          associated_playerdata = playerdata
          break
        end
      end

      -- Teleport the character
      local new_character, _ = teleport_character_to_surface_2(character, clone_to, to_position, true)

      -- Update `character` in `playerdata`
      if associated_playerdata then associated_playerdata.character = new_character end
    end
  end

  -- destroy the shield projections
  local destroy_names = {}
  for _, name in pairs(remote.call("shield-projector", "get_sub_entity_names")) do
    table.insert(destroy_names, name)
  end

  -- check nearby the ship since we need to capture all shield projector barriers which don't count towards the known_bounds
  local expanded_clone_from_area = util.area_extend(clone_from_area, 15)
  local destroy_entities = clone_from.find_entities_filtered{
    name = destroy_names,
    area = expanded_clone_from_area -- shield projector barriers can be outside the range of the ship bounding box
  }
  for _, entity in pairs(destroy_entities) do
    entity.destroy()
  end

  clone_from.clone_brush{
    source_offset = {0, 0},
    destination_offset = {clone_delta.dx, clone_delta.dy},
    destination_surface = clone_to,
    clone_tiles = false,
    clone_entities = true,
    clone_decoratives = false,
    clear_destination_entities = false,
    clear_destination_decoratives = false,
    expand_map = true,
    source_positions = clone_positions
  }

  -- Pause inserters, workaround for https://forums.factorio.com/viewtopic.php?f=58&t=89035
  local condition_entities = clone_to.find_entities_filtered{
    type = Spaceship.types_to_restore,
    area = clone_to_area
  }
  spaceship.entities_to_restore = spaceship.entities_to_restore or {}
  spaceship.entities_to_restore_tick = tick + Spaceship.time_to_restore
  for _, entity in pairs(condition_entities) do
    table.insert(spaceship.entities_to_restore, {
      entity = entity,
      active=entity.active
    })
    entity.active = false
  end

  -- clean out of map tiles in the clone area
  local bad_tiles = clone_to.find_tiles_filtered{
    name = {name_out_of_map_tile},
    area = clone_to_area
  }
  local set_tiles = {}
  for _, tile in pairs(bad_tiles) do
    table.insert(set_tiles, {
      position = tile.position,
      name = name_space_tile
    })
    clone_to.set_hidden_tile(tile.position, name_space_tile)
  end
  clone_to.set_tiles(set_tiles)

  -- Transfer the ship console
  local old_console = spaceship.console
  if old_console then
    local new_console = clone_to.find_entities_filtered({
      name = Spaceship.name_spaceship_console,
      position = _add_delta_to_position(old_console.position, clone_delta),
      limit = 1,
    })[1]
    spaceship.console = new_console
    spaceship.last_console_unit_number = new_console.unit_number
    spaceship.console_output = nil
    old_console.destroy()
  end

  -- using safe_destroy (which raises the script_raised_destroy) even causes the destruction part of the code take ~10x longer
  -- but if we don't do this (and silently destroy the entities) we can break mod compatibility
  local change_tiles_from = {}
  local change_tiles_from_count = 0
  local change_tiles_to = {}
  local area_table = {left_top = {}, right_bottom = {}}
  for _, clone_position in pairs(clone_positions) do
    local x = clone_position.x
    local y = clone_position.y
    -- part of the spaceship so remove from clone_from surface
    local under_tile = clone_from.get_hidden_tile({x=x,y=y})
    if under_tile == nil or Spaceship.names_spaceship_floors_map[under_tile] then
      if to_is_solid then
        under_tile = "landfill" -- fallback
      else
        under_tile = name_space_tile
      end
    end

    change_tiles_from_count = change_tiles_from_count + 1
    change_tiles_from[change_tiles_from_count] = {name = under_tile, position = {x=x,y=y}}

    if SpaceshipClone.check_tile_non_deconstruct(under_tile) then
      clone_from.set_hidden_tile({x=x,y=y}, nil)
    end

    local left_top = area_table.left_top
    local right_bottom = area_table.right_bottom
    left_top.x = x
    left_top.y = y
    right_bottom.x = x + 1
    right_bottom.y = y + 1
    local entities = clone_from.find_entities_filtered{area = area_table}
    for _, entity in pairs(entities) do
      if entity.valid then
        local entity_name = entity.name
        local entity_type = entity.type
        local entity_position = entity.position

        if SpaceshipClone.types_excluded_map[entity_type]
          or SpaceshipClone.names_excluded_map[entity_name] then
          -- Characters, cars, and spidertrons "inside" the ship should have already been teleported.
          -- If they were standing outside the ship but colliding with the wall exterior, they would
          -- still have gotten cloned; their clones therefore need to be destroyed.
          -- This also applies to space capsule entities.
          -- Also excludes cliffs, rockets, tile ghosts, or something that should not change surfaces.
          local clone = clone_to.find_entity(entity_name,
            _add_delta_to_position(entity_position, clone_delta))
          if clone then util.safe_destroy(clone) end
        elseif entity_name == "se-spaceship-wall" then
          -- this does not raise any event!
          -- it will silently destroy the entity
          -- if any mod was tracking the ship walls, it will get borked by this
          -- why do potentially other-mod breaking thing?
          -- we do this for performance reasons because raising events is expensive
          entity.destroy()
        elseif entity_type ~= "spider-leg" then
          util.safe_destroy(entity)
        end
      end
    end
  end
  clone_from.set_tiles(change_tiles_from, true, false)
  clone_to.set_tiles(change_tiles_to, true)

  -- Force re-finding all engines on the next engine activation
  spaceship.engines = nil

  -- fix some composite entities that don't clone nicely
  CondenserTurbine.reset_surface(clone_to, clone_to_area)
  Nexus.reset_surface(clone_to, clone_to_area)
  LinkedContainer.update()

  -- ground and unground entities
  SpaceshipClone.ground_unground_entities(clone_from, clone_to, clone_from_zone, clone_to_zone, clone_from_area, clone_to_area)

  -- put players back in vehicles
  for _, vehicle_driver in pairs(rail_vehicle_drivers) do
    local vehicle = clone_to.find_entity(vehicle_driver.vehicle_name,
      _add_delta_to_position(vehicle_driver.vehicle_position, clone_delta))
    local driver = clone_to.find_entity(vehicle_driver.driver_name,
      _add_delta_to_position(vehicle_driver.driver_position, clone_delta))

    if vehicle and driver then
      vehicle.set_driver(driver)
    end
  end

  -- set train status (automatic vs normal)
  -- train is defined as any one locomotive within its rolling stock
  for _, locomotive in pairs(train_settings) do
    local from_position = locomotive.position

    if Spaceship.is_position_on_spaceship(from_position, spaceship) then
      local to_position = _add_delta_to_position(from_position, clone_delta)
      local match = clone_to.find_entity(locomotive.name, to_position)

      if match and match.train then
        match.train.get_schedule().go_to_station(locomotive.current_stop_index)
        match.train.manual_mode = locomotive.manual_mode
      end
    end
  end

  if to_is_spaceship then
    -- remove any spaceship colliding entities
    local invalids = clone_to.find_entities_filtered{
      collision_mask = {"moving_tile"},
      area = clone_to_area
    }
    for _, invalid in pairs(invalids) do
      util.safe_destroy(invalid)
    end

    -- Make sure spaceship surface has correct name
    clone_to.localised_name = Zone.get_default_localised_name_for_surface(spaceship)
  end

  -- Turn on the new shield projectors
  remote.call("shield-projector", "find_on_surface", {
    surface = clone_to,
    area = clone_to_area
  })

  -- Play ship whooshing sound
  for _, player in pairs(game.connected_players) do
    if player.surface.index == clone_from.index or player.surface.index == clone_to.index then
      player.play_sound{path = "se-spaceship-woosh", volume = 1}
    end
  end

  -- Flag for cloning in progress
  spaceship.is_cloning = false
  spaceship.surface_lock_timeout = tick + 60

  SpaceshipIntegrity.start_integrity_check(spaceship)
  Spaceship.update_output_combinator(spaceship, tick)

  if clone_from_zone.type ~= "spaceship" then
    ---@cast clone_from_zone -SpaceshipType
    -- Spaceship tiles have been removed to any in-progress checks are sus
    SpaceshipIntegrity.restart_integrity_checks_on_surface(clone_from)
  end

  -- Iterating all players to also update players' remote view state even if they're
  -- offline during multiplayer games.
  for _, player in pairs(game.players) do
    SpaceshipClone.transfer_remote_view(spaceship, player, clone_from, clone_to_area, clone_delta)
  end

  -- Clean up for after the clone completes
  if post_clone_cb then post_clone_cb(spaceship, clone_from, clone_to, clone_delta) end
end

return SpaceshipClone
