local SimulationSpaceship = {}

-- local function populate_known_tiles(spaceship) end

-- Given a console entity, return a spaceship object.
---@param console_entity LuaEntity
---@return SpaceshipType?
function SimulationSpaceship.create_simulation_spaceship(console_entity)
  storage.simulation_spaceships = storage.simulation_spaceships or {}
  local spaceship_index = #storage.simulation_spaceships + 1

  -- Pump up the integrity limit
  for i = 1, 5 do
    game.forces.player.technologies[SpaceshipIntegrity.names_tech_integrity[2].name .. "-" .. i].researched = true
  end

  local spaceship = {
    type = "simulation-spaceship",
    index = spaceship_index,
    valid = true,
    force_name = "player",
    console = console_entity,
    speed = 1,
    check_flash_alpha = 0
  }
  storage.simulation_spaceships[spaceship_index] = spaceship

  -- TODO: We don't need to verify integrity, just get all tiles in known_tiles. That would be way faster.
  SpaceshipIntegrity.start_integrity_check(spaceship, 0)
  while spaceship.is_doing_check do -- Do integrity check in a single tick
    SpaceshipIntegrity.integrity_check_tick(spaceship)
  end

  -- populate_known_tiles(spaceship)
  -- Turn check_tiles into known_tiles and calculate bounds and streamline
  -- SpaceshipIntegrity.stop_integrity_check(spaceship)

  if not spaceship.integrity_valid then
    log {"", "Spaceship integrity failed: ", spaceship.check_message}
    return
  end

  return spaceship
end

-- Given 2 simulation spaceships, combine them into 1 spaceship for the purpose of flying them together on a single surface
---@param spaceship1 SpaceshipType
---@param spaceship2 SpaceshipType
---@return SpaceshipType
function SimulationSpaceship.merge_spaceships(spaceship1, spaceship2)

  local merged_spaceship = {
    type = "simulation-spaceship",
    index = spaceship1.index,
    valid = true,
    force_name = "player",
    console = spaceship1.console,
    speed = 1,
    check_flash_alpha = 0
  }

  util.concatenate_tables(spaceship1.known_tiles, spaceship2.known_tiles)
  merged_spaceship.known_tiles = spaceship1.known_tiles

  local min_x = math.min(spaceship1.known_bounds.left_top.x, spaceship2.known_bounds.left_top.x)
  local min_y = math.min(spaceship1.known_bounds.left_top.y, spaceship2.known_bounds.left_top.y)
  local max_x = math.max(spaceship1.known_bounds.right_bottom.x, spaceship2.known_bounds.right_bottom.x)
  local max_y = math.max(spaceship1.known_bounds.right_bottom.y, spaceship2.known_bounds.right_bottom.y)
  merged_spaceship.known_bounds = {left_top = {x = min_x, y = min_y}, right_bottom={x = max_x, y = max_y}}
  merged_spaceship.known_tiles_average_x = math.floor((min_x + max_x)/2)
  merged_spaceship.known_tiles_average_y = math.floor((min_y + max_y)/2)
  merged_spaceship.streamline = math.min(spaceship1.streamline, spaceship2.streamline) -- Good enough
  merged_spaceship.integrity_stress = math.max(spaceship1.integrity_stress, spaceship2.integrity_stress)

  storage.simulation_spaceships[spaceship1.index] = merged_spaceship
  storage.simulation_spaceships[spaceship2.index] = nil

  return merged_spaceship
end

-- Given a spaceship, make it act as if it was flying. Asteroids and all.
---@param spaceship SpaceshipType
---@param starting_speed number
---@param target_speed number
function SimulationSpaceship.fly(spaceship, starting_speed, target_speed)
  spaceship.zone_index = nil
  spaceship.own_surface_name = "nauvis"
  spaceship.on_own_surface = true
  spaceship.is_moving = true
  spaceship.speed = starting_speed
  spaceship.target_speed = target_speed
  Spaceship.activate_engines(spaceship)
end

---@param event EventData.on_tick Event data
function SimulationSpaceship.on_tick(event)
  for _, spaceship in pairs(storage.simulation_spaceships) do

    if spaceship.is_moving then

      if event.tick % Spaceship.tick_interval_move == 0 then
        Spaceship.surface_tick(spaceship, Spaceship.tick_interval_move)
        Spaceship.apply_engine_thust(spaceship, Spaceship.tick_interval_move)
        Spaceship.apply_drag(spaceship, Spaceship.tick_interval_move)
      end

      if (event.tick % 6) == 0 then
        Spaceship.toggle_engines_for_target_speed(spaceship)
      end

      SpaceshipObstacles.tick_entity_obstacles(spaceship, game.surfaces.nauvis)

    end
  end
end

return SimulationSpaceship
