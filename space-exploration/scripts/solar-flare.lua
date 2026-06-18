local SolarFlare = {}

SolarFlare.name_glaive_beam = mod_prefix.."energy-glaive-beam" -- projectile
SolarFlare.name_glaive_beam_sprite = mod_prefix.."energy-glaive-beam-sprite" -- sprite
SolarFlare.name_glaive_path_fx = mod_prefix.."energy-glaive-path-fx"
SolarFlare.name_glaive_damage_projectile = mod_prefix.."energy-glaive-damage-projectile"
SolarFlare.name_glaive_damage_aoe = mod_prefix.."energy-glaive-damage-aoe"
SolarFlare.name_glaive_damage_aoe_large = mod_prefix.."energy-glaive-damage-aoe-large"
SolarFlare.name_fire = mod_prefix .. "fire-flame-on-tree-no-pollution"

SolarFlare.max_age = 60*60*2 -- 5 minutes
SolarFlare.speed = 0.10
SolarFlare.damage_interval = 20
SolarFlare.warning_time = 60*60*60*24 -- 24 hours
SolarFlare.base_power = 2000000000

---@param zone AnyZoneType
---@return number
function SolarFlare.default_flare_power(zone)
  local power_multiplier = Zone.get_solar(zone)
  if zone.radius then
    power_multiplier = power_multiplier * zone.radius / 5000
  else
    power_multiplier = 0.2 * power_multiplier
  end
  return power_multiplier
end

---@param zone AnyZoneType
---@param targeting string
---@param power_multiplier? number
---@param delay? integer
---@param max_age? integer
function SolarFlare.begin_flare(zone, targeting, power_multiplier, delay, max_age)
  if not power_multiplier then
    power_multiplier = SolarFlare.default_flare_power(zone)
  end
  delay = delay or 0
  local tick_task = new_tick_task("solar-flare") --[[@as SolarFlareTickTask]]
  tick_task.zone = zone
  tick_task.start_tick = game.tick + delay
  tick_task.beams = {}
  tick_task.power_multiplier = power_multiplier
  tick_task.targeting = targeting
  tick_task.max_age = max_age or SolarFlare.max_age
  Log.debug("SolarFlare on zone: " .. zone.name.." power: "..power_multiplier)
end

---@param tick_task SolarFlareTickTask
---@param tick uint Current tick
function SolarFlare.tick_flare(tick_task, tick)
  if tick < tick_task.start_tick then return end

  if not tick_task.pressure_applied then
    tick_task.pressure_applied  = true
    EnergyBeamDefence.zone_add_pressure(tick_task.zone, tick_task)
    tick_task.defended = EnergyBeamDefence.zone_is_defended(tick_task.zone)
  end

  if not tick_task.start_warning_sent then
    tick_task.start_warning_sent = true
    for _, force in pairs(game.forces) do
      if Zone.is_visible_to_force(tick_task.zone, force.name) then
        force.print({"space-exploration.alert-cme-arrived", Zone.get_print_name(tick_task.zone)})
      end
    end
  end

  local surface = Zone.get_surface(tick_task.zone)
  if not surface then
    Log.debug("SolarFlare.begin_flare: No surface")
    tick_task.valid = false
    return
  end

  if tick > tick_task.start_tick + (tick_task.max_age or SolarFlare.max_age) or settings.global["se-cmes-max-frequency"].value == 0 then
    for _, beam in pairs(tick_task.beams) do
      if beam.beam and beam.beam.valid then
        beam.beam.destroy()
      end
      if beam.markers then
        for _, marker in pairs(beam.markers) do
          if marker and marker.valid then
            marker.destroy()
          end
        end
      end
    end
    tick_task.valid = false
    Log.debug("SolarFlare end")
    surface.print({"space-exploration.alert-cme-passed"})
    return
  end

  local age = tick - tick_task.start_tick
  local age_p = age / (tick_task.max_age or SolarFlare.max_age)
  --tick_task.age_peak  = math.min(age_p, 1-age_p) * 2
  tick_task.age_peak = math.sin(age_p*math.pi)

  if tick % 60 == 0 then
    tick_task.defended = EnergyBeamDefence.zone_is_defended(tick_task.zone)
  end

  if tick_task.defended then
    while next(tick_task.beams) do
      local beam = tick_task.beams[#tick_task.beams]
      if beam.beam and beam.beam.valid then
        beam.beam.destroy()
      end
      if beam.markers then
        for _, marker in pairs(beam.markers) do
          if marker and marker.valid then
            marker.destroy()
          end
        end
      end
      table.remove(tick_task.beams, #tick_task.beams)
    end
    return
  end

  if not tick_task.chunk_count then
    tick_task.chunk_count = 0
    for chunk in surface.get_chunks() do
      tick_task.chunk_count = tick_task.chunk_count + 1
    end
  end
  -- tiny -> 2
  -- 5k small = 1.9 -> 4
  -- 50k medium = 11.18 -> 14
  local target_beams = math.min(20, math.ceil(tick_task.age_peak * (2 + (tick_task.chunk_count / 2000) ^ 0.75)))

  while #tick_task.beams < target_beams do
    local chunk = surface.get_random_chunk()
    local position = {x = (chunk.x+math.random())*32, y = (chunk.y+math.random())*32}
    chunk = surface.get_random_chunk()
    local target_position = {x = (chunk.x+math.random())*32, y = (chunk.y+math.random())*32}
    if not next(tick_task.beams) then
      if tick_task.targeting == "basic" then
        local entities = surface.find_entities_filtered{type={"furnace","electric-pole","roboport","reactor"}}
        if entities and next(entities) then
          position = entities[math.random(#entities)].position
        end
      elseif tick_task.targeting == "crash" then
        position = Util.vector_set_length(position, 80)
        target_position = {x = 0, y = 0}
      end
    end
    local beam = {
      position = position,
      target_position = target_position
    }
    beam.beam = surface.create_entity{
      name = SolarFlare.name_glaive_beam,
      position = position,
      target = {0,0},
      speed = 0,
      force = "neutral"
    }
    if not (beam.beam_sprite_render and beam.beam_sprite_render.valid) then
      beam.beam_sprite_render = rendering.draw_sprite{
        target = beam.beam,
        sprite = SolarFlare.name_glaive_beam_sprite,
        surface = surface,
      }
    end
    beam.beam_sprite_render.x_scale = 2
    beam.beam_sprite_render.y_scale = 1.5
    beam.beam_sprite_render.color = {
      r = 1,
      g = 0.7,
      b = 0.7
    }
    surface.create_entity{
      name = SolarFlare.name_fire,
      position = position,
    }
    table.insert(tick_task.beams, beam)
    Log.debug("SolarFlare "..#tick_task.beams.." for tick_task " .. tick_task.id)
    surface.print({"space-exploration.alert-cme-stream", "[gps="..math.floor(position.x)..","..math.floor(position.y)..","..surface.name.."]"})
  end

  while #tick_task.beams > target_beams do
    local beam = tick_task.beams[#tick_task.beams]
    if beam.beam and beam.beam.valid then
      beam.beam.destroy()
    end
    if beam.markers then
      for _, marker in pairs(beam.markers) do
        if marker and marker.valid then
          marker.destroy()
        end
      end
    end
    table.remove(tick_task.beams, #tick_task.beams)
  end

  if tick % 60 == 0 then
    for i, beam in pairs(tick_task.beams) do
      if beam.markers then
        for _, marker in pairs(beam.markers) do
          if marker and marker.valid then
            marker.destroy()
          end
        end
      end
      beam.markers = {}
      for force_name, forcedata in pairs(storage.forces) do
        if game.forces[force_name] and force_name ~= "friendly" and force_name ~= "ignore" and force_name ~= "capture" then
          beam.markers[force_name] = game.forces[force_name].add_chart_tag(surface, {
            icon = {type = "virtual", name = mod_prefix.."heat"},
            position = beam.position,
            text = "CME"
          })
        end
      end
      if (tick_task.targeting == "basic" or tick_task.targeting == "crash") and (i == 1 or i == 3) then
        local chunk = surface.get_random_chunk()
        beam.target_position = {x = (chunk.x+math.random())*32, y = (chunk.y+math.random())*32}
        if math.random() < 0.1 then
          local entities = surface.find_entities_filtered{type={"character", "furnace","electric-pole","roboport","reactor"}}
          if entities and next(entities) and math.random() < 0.1 then
            beam.target_position = entities[math.random(#entities)].position
          end
        end
      else
        if math.random() < 0.4 then
          beam.target_position = Util.vectors_add(beam.beam.position, {x = (math.random()-0.5)*64, y = (math.random()-0.5)*64})
        else
          local chunk = surface.get_random_chunk()
          beam.target_position = {x = (chunk.x+math.random())*32, y = (chunk.y+math.random())*32}
        end
      end
    end
  end

  for _, beam in pairs(tick_task.beams) do
    if not(beam.beam and beam.beam.valid) then
      beam.beam = surface.create_entity{
        name = SolarFlare.name_glaive_beam,
        position = beam.position,
        target = {0,0},
        speed = 0,
        force = "neutral"
      }
    end
    if not (beam.beam_sprite_render and beam.beam_sprite_render.valid) then
      beam.beam_sprite_render = rendering.draw_sprite{
        target = beam.beam,
        sprite = SolarFlare.name_glaive_beam_sprite,
        surface = surface,
      }
    end
    beam.beam_sprite_render.x_scale = 2
    beam.beam_sprite_render.y_scale = 1.5
    beam.beam_sprite_render.color = {
      r = 1,
      g = 0.7,
      b = 0.7
    }
    local new_position = util.move_to(beam.position, beam.target_position, SolarFlare.speed, false)
    beam.position = new_position
    beam.beam.teleport(new_position)
    if math.random() < 0.1 then
      surface.create_entity{
        name = SolarFlare.name_fire,
        position = new_position,
      }
      surface.create_entity{
        name = SolarFlare.name_glaive_path_fx,
        position = new_position,
        force = "neutral"
      }
    end
    if tick % math.ceil(SolarFlare.damage_interval / math.min(tick_task.power_multiplier or 1, 2)) == 0 then
      surface.create_entity{
        name = SolarFlare.name_glaive_damage_aoe_large,
        position = new_position,
        force = "neutral"
      }
    end
  end

end

---@param zone AnyZoneType
---@param arrival_tick uint
---@return integer
function SolarFlare.arrival_snap(zone, arrival_tick)

  if Zone.is_solid(zone) then
    ---@cast zone PlanetType|MoonType
    local targeted_time_of_day = (arrival_tick / zone.ticks_per_day) % 1
    -- target morning (0.75), snapped to the next minute
    arrival_tick = arrival_tick + (0.75 - targeted_time_of_day) * zone.ticks_per_day
  end
  -- snap to minute so timer does not have a random delay
  arrival_tick = math.ceil(arrival_tick / 3600) * 3600

  return arrival_tick
end

---@param event NthTickEventData
function SolarFlare.on_nth_tick_3600(event)
  if settings.global["se-cmes-max-frequency"].value == 0 then
    for force_name, forcedata in pairs(storage.forces) do
      if forcedata.solar_flare then
        forcedata.solar_flare = nil
      end
    end
  else
    if event.tick == 0 then
      local entities = game.get_surface(1).find_entities_filtered{
        area = {{-64,-64},{64,64}}
      }
      for _, entity in pairs(entities) do
        if string.find(entity.name, "wreck", 1, true) or string.find(entity.name, "crash", 1, true)then
          entity.destructible = false
        end
      end
      if not is_testing_game() then
        SolarFlare.begin_flare(Zone.from_name("Nauvis") --[[@as PlanetType]], "crash", 0.25, 60*13, 45*60) -- 13s delay
      end
    end
    for force_name, forcedata in pairs(storage.forces) do
      local force = game.forces[force_name]
      if force and forcedata.has_players and forcedata.homeworld_index
        and force_name ~= "friendly" and force_name ~= "ignore" and force_name ~= "capture" then
        --Log.debug("SolarFlare.on_nth_tick_3600 "..force_name)

        if not forcedata.solar_flare then
          -- first one, on homeworld, has a 48 hour delay + 1 hour warning
          local arrival_tick = math.max(
            48*60*60*60 + math.random()*60*60*60, -- 48 hours + up to 1 hour
            event.tick + settings.global["se-cmes-max-frequency"].value * (0.5 + 0.5 * math.random()) * 60*60*60 ) -- 12 to 24 hours normally
          local zone = Zone.from_zone_index(forcedata.homeworld_index)
          arrival_tick = SolarFlare.arrival_snap(zone, arrival_tick)
          forcedata.solar_flare = {
            type = "solar-flare",
            zone = zone,
            tick = arrival_tick
          }
        end
        if forcedata.solar_flare then
          if SolarFlare.warning_time + event.tick >= forcedata.solar_flare.tick
            and forcedata.solar_flare.tick - event.tick >= 0
            and (forcedata.solar_flare.last_warned == nil or event.tick - forcedata.solar_flare.last_warned >= forcedata.solar_flare.tick - event.tick) then
              for force_name, force in pairs(game.forces) do
                if Zone.is_visible_to_force(forcedata.solar_flare.zone, force.name) then
                  force.print({"space-exploration.alert-cme-eta",
                    Zone.get_print_name(forcedata.solar_flare.zone),
                    Util.seconds_to_clock((forcedata.solar_flare.tick - event.tick)/60, true)})
                end
              end
              forcedata.solar_flare.last_warned = event.tick
          end
          if event.tick >= forcedata.solar_flare.tick then
            -- do the solar flare tick task setup
            SolarFlare.begin_flare(forcedata.solar_flare.zone, forcedata.solar_flare.targeting)
            -- set the next one
            local zone_options = {forcedata.homeworld_index}
            if forcedata.zone_assets then
              for zone_index, force_zone_assets in pairs(forcedata.zone_assets) do
                if (force_zone_assets.rocket_launch_pad_names and table_size(force_zone_assets.rocket_launch_pad_names) > 0) or
                  (force_zone_assets.rocket_landing_pad_names and table_size(force_zone_assets.rocket_landing_pad_names) > 0) then
                  local try_zone = Zone.from_zone_index(zone_index)
                  if try_zone.type ~= "asteroid-field" and try_zone.type ~= "anomaly" and try_zone.type ~= "spaceship" then
                    ---@cast try_zone -AsteroidFieldType, -AnomalyType, -SpaceshipType
                    table.insert(zone_options, zone_index)
                  end
                end
              end
            end
            if (#zone_options <= 1 and math.random() < 0.6) or math.random() < 0.3 then
              for zone_index, discovered_data in pairs(forcedata.zones_discovered) do
                local try_zone = Zone.from_zone_index(zone_index)
                if try_zone.type ~= "asteroid-field" and try_zone.type ~= "anomaly" and try_zone.type ~= "spaceship" then
                  ---@cast try_zone -AsteroidFieldType, -AnomalyType, -SpaceshipType
                  table.insert(zone_options, zone_index)
                end
              end
            end
            local zone = Zone.from_zone_index(zone_options[math.random(#zone_options)])

            -- other solar flares have 12-24 hour interval
            local arrival_tick = event.tick + settings.global["se-cmes-max-frequency"].value * (0.5 + 0.5 * math.random()) * 60*60*60 -- 12-24 hours
            arrival_tick = SolarFlare.arrival_snap(zone, arrival_tick)

            forcedata.solar_flare = {
              type = "solar-flare",
              zone = zone,
              tick = arrival_tick
            }
            if forcedata.solar_flare.zone.type == "star" then forcedata.solar_flare.zone = forcedata.solar_flare.zone.orbit end
            if forcedata.solar_flare.zone.index == forcedata.homeworld_index then
              forcedata.solar_flare.targeting = "basic"
            end
          end
        end
      else
        forcedata.solar_flare = nil
      end

    end
  end
end
Event.addListener("on_nth_tick_3600", SolarFlare.on_nth_tick_3600) -- 1 minute

return SolarFlare
