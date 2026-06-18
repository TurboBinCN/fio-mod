Weapon = {}

-- constants
Weapon.cryogun_freeze_time_min = 300
Weapon.cryogun_freeze_time_max = 1200
Weapon.cryogun_ice_radius = 1
Weapon.cryogun_freeze_radius = 4
Weapon.name_cryogun_ice = mod_prefix.."cryogun-ice"
Weapon.name_cryogun_ice_spacer = mod_prefix.."cryogun-ice-spacer"
Weapon.name_biter_friend = mod_prefix.."biter-friend"
Weapon.tesla_random_factor = 2
Weapon.tesla_range = 10

Weapon.entity_with_health_types = {
  -- taken from https://wiki.factorio.com/Prototype/EntityWithHealth
  "accumulator", "agricultural-tower", "artillery-turret", "asteroid",
  "beacon", "boiler", "burner-generator", "character", "cargo-bay", "cargo-landing-pad", "cargo-pod",
  "arithmetic-combinator", "decider-combinator", "selector-combinator", "constant-combinator", "container",
  "logistic-container", "infinity-container", "temporary-container",
  "assembling-machine", "rocket-silo",
  "furnace", "display-panel", "electric-energy-interface", "electric-pole", "unit-spawner",
  --"fish",
  "capture-robot", "combat-robot", "construction-robot", "logistic-robot",
  "fusion-generator", "fusion-reactor", "gate", "generator",
  "heat-interface", "heat-pipe", "inserter", "lab", "lamp", "land-mine", "lightning-attractor", "linked-container",
  "market", "mining-drill", "offshore-pump", "pipe", "infinity-pipe", "pipe-to-ground",
  "player-port", "power-switch", "programmable-speaker", "pump", "radar",
  "legacy-straight-rail", "legacy-curved-rail",
  "straight-rail", "curved-rail-a", "curved-rail-b", "half-diagonal-rail",
  "elevated-straight-rail", "elevated-curved-rail-a", "elevated-curved-rail-b", "elevated-half-diagonal-rail",
  "rail-ramp", "rail-support",
  "rail-chain-signal", "rail-signal", "reactor", "roboport",
  "segment", "segmented-unit",
  "simple-entity", "simple-entity-with-owner", "simple-entity-with-force", "solar-panel", "spider-unit",
  --"spider-leg",
  "space-platform-hub", "storage-tank", "thruster",
  "train-stop", "linked-belt", "lane-splitter", "loader-1x1", "loader", "splitter",
  "transport-belt", "underground-belt", "tree", "plant", "turret", "ammo-turret", "electric-turret",
  "fluid-turret", "unit", "car", "artillery-wagon", "cargo-wagon", "fluid-wagon",
  "locomotive", "spider-vehicle", "wall"
}
--[[
plague new plan.
Limit to 1 acive per chunk?
  Have a table of chunks and expiration date?

Get all entities, sort by distance, destroy 1 per frame?

Get a chunk, get entities, destroy, get neighbors.
Choose a random chunk nearby to infect, repeat.
Limit to X active chunks.
]]

---@param event EventData.on_trigger_created_entity Event data
function Weapon.on_trigger_created_entity(event)
  if not event.entity and event.entity.valid then return end
  local entity_name = event.entity.name
  if entity_name == mod_prefix.."tesla-gun-trigger" then
    if event.source and event.source.valid then
      local tick_task = new_tick_task("chain-beam") --[[@as ChainBeamTickTask]]
      tick_task.surface = event.entity.surface
      tick_task.beam = mod_prefix.."tesla-gun-beam"
      tick_task.max_bounces = 10 + math.random() * 20
      tick_task.instigator = event.source
      tick_task.instigator_force = event.source.force
      tick_task.inverted_forces = {}
      for _, force in pairs(game.forces) do
        if force ~= tick_task.instigator_force then
          table.insert(tick_task.inverted_forces, force)
        end
      end
      local position = event.source.position
      local initial_vector_delta = util.vectors_delta(position, event.entity.position)
      local initial_vector_length = util.vector_length(initial_vector_delta)
      local initial_vector
      if initial_vector_length == 0 then
        -- have no vector, just point north
        initial_vector = {x=0, y=-1}
      else
        -- normalise the vector
        initial_vector = util.vector_multiply(initial_vector_delta, 1/initial_vector_length)
      end
      tick_task.desired_vector = util.vector_multiply(initial_vector, 2)
      tick_task.bonus_damage = Shared.tesla_base_damage * tick_task.instigator_force.get_ammo_damage_modifier(Shared.tesla_ammo_category)
      local first_hit = util.move_to(position, event.entity.position, 3, false)
      tick_task.affected_locations = {{position = first_hit}}
      -- gun graphic offset
      local source_offset = util.vectors_add(util.move_to({x=0, y=0}, initial_vector, 0.7, true), {x=0, y=-1})

      tick_task.surface.create_entity{
        name = tick_task.beam,
        position = first_hit,
        target_position = first_hit,
        source = tick_task.instigator,
        source_offset = source_offset,
        duration = 10,
      }
    end
  elseif entity_name == mod_prefix .. "plague-cloud"then
    local surface_index = event.entity.surface.index
    local zone = Zone.from_surface_index(surface_index)
    if zone and Zone.is_solid(zone) and not zone.plague_tick_task then
      ---@cast zone PlanetType|MoonType
      if not zone.plague_used then
        zone.plague_used = event.tick
      end
      Zone.apply_plague_to_controls(zone)
      local tick_task = new_tick_task("plague-tick") --[[@as PlagueTickTask]]
      tick_task.surface_index = surface_index
      tick_task.position = event.entity.position
      tick_task.zone = zone
      if event.entity.force then
        tick_task.force_name = event.entity.force.name
      end
      tick_task.started = event.tick
      zone.plague_tick_task = tick_task
    end
  elseif entity_name == mod_prefix.."cryogun-trigger" then
    local pos = event.entity.position
    local surface = event.entity.surface
    local spaceship = Spaceship.from_own_surface_index(surface.index)
    local safe_pos = surface.find_non_colliding_position(Weapon.name_cryogun_ice_spacer, pos, Weapon.cryogun_ice_radius, 0.1, false)
    local ice_entities = {}
    if safe_pos then
      local ice = surface.create_entity{name = Weapon.name_cryogun_ice, position = safe_pos, force = "neutral"}
      ---@cast ice -?
      table.insert(ice_entities, ice)
      if spaceship then
        SpaceshipObstacles.add_moveable_entity(spaceship, ice, "ice")
      end
    end
    local extinguish_entities = surface.find_entities_filtered{
      type = {"fire"},
      position = safe_pos or pos,
      radius = Weapon.cryogun_freeze_radius
    }
    for _, entity in pairs(extinguish_entities) do
      --Only restrict to "flame" entities - acid pool uses fires as a base, and has fire in the name
      if entity.active and string.find(entity.name, "-flame", 1, true) then
        entity.destroy()
      end
    end

    local freeze_entities = surface.find_entities_filtered{
      type = {"unit", "turret", "ammo-turret", "electric-turret", "fluid-turret"},
      position = safe_pos or pos,
      radius = Weapon.cryogun_freeze_radius
    }
    local reactivate_entities = {}
    for _, entity in pairs(freeze_entities) do
      if entity.active then
        entity.active = false
        if entity.stickers then
          for _, sticker in pairs(entity.stickers) do
            --Consider expanded whitelist on request
            if sticker.name == "fire-sticker" then
              sticker.destroy()
            end
          end
        end
        table.insert(reactivate_entities, entity)
        table.insert(ice_entities, surface.create_entity{name = Weapon.name_cryogun_ice, position = entity.position, force = "neutral"})
      end
    end
    if next(ice_entities) or next(reactivate_entities) then
      local tick_task = new_tick_task("cryogun-unfreeze") --[[@as CryogunUnfreezeTickTask]]
      tick_task.ice_entities = ice_entities
      tick_task.reactivate_entities = reactivate_entities
      tick_task.freeze_tick = event.tick
      tick_task.unfreeze_tick = event.tick + math.random(Weapon.cryogun_freeze_time_min, Weapon.cryogun_freeze_time_max)
    end
  elseif entity_name == mod_prefix.."pheromone-trigger" then
    local units = event.entity.surface.find_entities_filtered{type="unit", position = event.entity.position}
    if event.source and event.source.valid then
      for _, unit in pairs(units) do
        if unit.force ~= event.source.force then
          if string.find(unit.name, "biter", 1, true) or string.find(unit.name, "spitter", 1, true) then
            unit.force = event.source.force
            unit.commandable.set_command({type = defines.command.wander})
          end
        end
      end
    end
  elseif entity_name == "grenade-explosion" then
    local cliffs = event.entity.surface.find_entities_filtered{name = mod_prefix .. "core-seam-fissure", position = event.entity.position, radius = 6}
    for _, cliff in pairs(cliffs) do
      cliff.destroy({do_cliff_correction=true, raise_destroy=true})
    end
  end
end
Event.addListener(defines.events.on_trigger_created_entity, Weapon.on_trigger_created_entity)

---@param tick_task CryogunUnfreezeTickTask
---@param tick uint Current tick
function Weapon.cryogun_unfreeze(tick_task, tick)
  if tick >= tick_task.unfreeze_tick then
    tick_task.valid = false
    for _, e in pairs(tick_task.ice_entities) do
      if e.valid then e.destroy() end
    end
    for _, e in pairs(tick_task.reactivate_entities) do
      if e.valid then e.active = true end
    end
  end
end

---@param tick_task PlagueTickTask
function Weapon.plague_end(tick_task)
  tick_task.valid = false
  tick_task.zone.plague_tick_task = nil
  local surface = game.get_surface(tick_task.surface_index)
  if surface then
    local enemies = surface.find_entities_filtered{ force = "enemy" }
    for _, entity in pairs(enemies) do
      entity.destroy()
    end
    local plague = surface.find_entities_filtered{ name={
      mod_prefix .. "plague-cloud",
      mod_prefix .. "plague-wave"} }
    for _, entity in pairs(plague) do
      entity.destroy()
    end
    local trees = surface.find_entities_filtered{ type = "tree" }
    for _, entity in pairs(trees) do
      entity.destroy()
    end
  end
end

---@type string[]
local plaguable_entity_names_cache
---@return string[]
local function get_plaguable_entities_names()
  if plaguable_entity_names_cache then return plaguable_entity_names_cache end
  plaguable_entity_names_cache = {}
  -- Things breathing air, except characters
  local breathing_air = prototypes.get_entity_filtered({
    {filter="flag", flag="breaths-air"},
    {filter="type", type={"unit", "turret", "tree", "fish"}, mode="and"}
  })
  for name, _ in pairs(breathing_air) do
    table.insert(plaguable_entity_names_cache, name)
  end
  -- Unit spawners (they don't breathe air but plague hits them anyway)
  local unit_spawners = prototypes.get_entity_filtered({
    {filter="type", type={"unit-spawner"}}
  })
  for name, _ in pairs(unit_spawners) do
    table.insert(plaguable_entity_names_cache, name)
  end
  return plaguable_entity_names_cache
end

---@param tick_task PlagueTickTask
---@param tick uint Current tick
function Weapon.plague_tick(tick_task, tick)
  --game.print((tick - (tick_task.started + 10 * 60 * 60)) / 60)
  if tick > tick_task.started + settings.global["se-plague-max-runtime-2"].value * 60 * 60 then -- 15 minutes
    Weapon.plague_end(tick_task)
  end

  if not tick_task.death_range then
    tick_task.death_range = 32
  end
  local surface = game.get_surface(tick_task.surface_index)
  if not surface then
    Weapon.plague_end(tick_task)
    return
  end
  if (not tick_task.death_list) or #tick_task.death_list <= (tick_task.death_quota or 0) then
    if tick_task.death_range > tick_task.zone.radius * 4 then
      Weapon.plague_end(tick_task)
    else
      if (tick_task.death_quota or 0) > 1000 then
        tick_task.death_range = tick_task.death_range + 1
      else
        tick_task.death_range = tick_task.death_range + 32
      end
      local plaguable_entities = get_plaguable_entities_names()
      tick_task.death_list = surface.find_entities_filtered{
        name = plaguable_entities,
        position = tick_task.position or {0,0},
        radius = tick_task.death_range
      }
      tick_task.death_quota = math.ceil(#tick_task.death_list*0.1)
      if #tick_task.death_list < 10 then
        tick_task.death_range = tick_task.death_range * 2
      end
    end
  else
    local m = math.min(10, math.ceil(#tick_task.death_list / 100))
    for i = 1, m do
      local entity = table.remove(tick_task.death_list, math.random(#tick_task.death_list))
      if entity and entity.valid then
        if entity.type == "unit-spawner" then
          local enemy = surface.find_nearest_enemy{
            position = entity.position,
            max_distance = 2000,
            force = entity.force}
          if enemy and enemy.valid then
            entity.damage(200, tick_task.force_name, "poison", nil, enemy)
          else
            entity.damage(200, tick_task.force_name, "poison")
          end
          if entity.valid then
            entity.die()
          end
        elseif entity.type == "unit" then
          if #tick_task.death_list % 20 == 0 then
            entity.die()
          end
        else
          entity.die()
        end
      end
    end
  end

end

---@param tick_task ChainBeamTickTask
function Weapon.chain_beam(tick_task)
  if not (tick_task.surface and tick_task.surface.valid) then
    tick_task.valid = false
    return
  end
  local branch_chance = tick_task.branch_chance or 0.1
  local emanate_from = nil
  if math.random() < branch_chance then
    emanate_from = tick_task.affected_locations[math.random(#tick_task.affected_locations)] -- branching bouncing beam
  else
    emanate_from = tick_task.affected_locations[#tick_task.affected_locations] -- single bouncing beam
  end

  -- get initial entity list
  local desired_pos = util.vectors_add(emanate_from.position, tick_task.desired_vector)
  local entities = tick_task.surface.find_entities_filtered{
    position = desired_pos,
    radius = Weapon.tesla_range,
    layers={object=true, player=true,},
    force = tick_task.inverted_forces,
    type = Weapon.entity_with_health_types
  }

  local rand_position = util.vectors_add(desired_pos, util.orientation_to_vector(math.random(), math.random() * Weapon.tesla_random_factor))
  local chosen = nil
  local entity_count = #entities
  while entity_count > 0 and not chosen do
    chosen = tick_task.surface.get_closest(rand_position, entities)
    for i = 1, #tick_task.affected_locations do
      if chosen == tick_task.affected_locations[i].entity then
        entities[i] = entities[entity_count]
        entities[entity_count] = nil
        entity_count = entity_count - 1
        chosen = nil
        break
      end
    end
  end

  if chosen then
    local target_position = chosen.position
    table.insert(tick_task.affected_locations, {position = target_position, entity = chosen})

    if chosen.type == "simple-entity" and string.find(chosen.name, "rock") then
      chosen.health = math.max(0.01, chosen.health - chosen.max_health / 50)
    elseif tick_task.bonus_damage > 0 then
      if tick_task.instigator.valid and tick_task.instigator.surface == tick_task.surface then
        chosen.damage(tick_task.bonus_damage, tick_task.instigator_force, "electric", nil, tick_task.instigator)
      else
        chosen.damage(tick_task.bonus_damage, tick_task.instigator_force, "electric")
      end
    end

    tick_task.surface.create_entity{
      name = tick_task.beam,
      position = emanate_from.position,
      target = chosen.valid and chosen or nil,
      force = tick_task.instigator_force,
      target_position = target_position,
      source_position = emanate_from.position,
      duration = 10,
    }
  else
    -- hit ground
    local ground = {x = desired_pos.x + ((math.random() - 0.5) * 0.25 * Weapon.tesla_range),
                    y = desired_pos.y + ((math.random() - 0.5) * 0.25 * Weapon.tesla_range)}

    table.insert(tick_task.affected_locations, {position = ground})

    tick_task.surface.create_entity{
      name = tick_task.beam,
      position = emanate_from.position,
      target_position = ground,
      source_position = emanate_from.position,
      duration = 10,
    }
  end

  if #tick_task.affected_locations >= (tick_task.max_bounces or 2) then
    tick_task.valid = false
  end
end

---@param event EventData.on_entity_died Event data
function Weapon.on_entity_died(event)
  if event.entity and event.entity.valid and event.entity.type == "unit" then
    local entity = event.entity
    if entity.stickers then
      for _, sticker in pairs(entity.stickers) do
        if sticker.name == mod_prefix .. "bloater-sticker" then
          local max_health = entity.max_health
          local remain = max_health
          while remain > 0 do
            local done = false
            for _, e in pairs({10000, 4000, 1000, 400, 100, 40, 10}) do
              done = true
              remain = remain - e
              entity.surface.create_entity{
                name= mod_prefix .. "bloater-burst-"..e,
                position = entity.position,
                force = sticker.force or "player" -- TODO, correct force
              }
            end
            if not done then remain = 0 end
          end
        end
      end
    end
  end
end
Event.addListener(defines.events.on_entity_died, Weapon.on_entity_died)

-- Migrate any currently running chain beams to the new force
---@param event EventData.on_forces_merging Event data
function Weapon.on_forces_merging(event)
  for _, tick_task in pairs(storage.tick_tasks) do
    if tick_task.type == "chain-beam" then
      for i, force in pairs(tick_task.inverted_force) do
        if force == event.source then
          table.remove(tick_task.inverted_force, i)
          break
        end
      end
      if event.source == tick_task.instigator_force then
        tick_task.instigator_force = event.destination
      end
    end
  end
end
Event.addListener(defines.events.on_forces_merging, Weapon.on_forces_merging)

return Weapon
