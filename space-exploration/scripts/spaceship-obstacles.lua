local SpaceshipObstacles = {}

SpaceshipObstacles.particle_enemy_proxy = mod_prefix .. "spaceship-enemy-proxy"
SpaceshipObstacles.particle_travel_anchor = mod_prefix .. "spaceship-travel-anchor"
SpaceshipObstacles.particle_hp_multiplier = 300
SpaceshipObstacles.bounding_box_buffer = 2

-- This dictates how much sideways velocity the asteroids get
-- (0.00 is purely vertical)
--SpaceshipObstacles.particle_orientation_variance = 0.00
SpaceshipObstacles.particle_orientation_variance = 0.03

-- sprite_prefix: append variation index, used by rendering api
-- vehicle_name: the actual vehicle being used to move the asteroid
-- Speed values are not true speed, asteroid areas have a multiplier.
---@type table<string, SpaceshipObstacleParticleInfo>
SpaceshipObstacles.particles = {
  ["speck"] = { multiplier = 1/1000, speed = 1/100, min_speed = 0, max_effective_speed = 50,
      sprite_name = mod_prefix.."spaceship-speck-graphic"
  },
  ["small"] = {
      multiplier = 1/8000, speed = 1/400, min_speed = 5,
      variations = 16, scale = 0.25, max_effective_speed = 100,
      sprite_prefix = mod_prefix .. "spaceship-obstacle-small-sprite-",
      vehicle_name = mod_prefix .. "spaceship-obstacle-small-vehicle",
  },
  ["medium"] = {
      multiplier = 1/60000, speed = 1/450, min_speed = 25, destroys_floor = true,
      variations = 16, scale = 0.5, max_effective_speed = 200,
      sprite_prefix = mod_prefix .. "spaceship-obstacle-medium-sprite-",
      vehicle_name = mod_prefix .. "spaceship-obstacle-medium-vehicle",
  },
  ["large"] = {
      multiplier = 1/3000000, speed = 1/500, min_speed = 100, min_size = 1000, destroys_floor = true,
      variations = 16, scale = 1,
      sprite_prefix = mod_prefix .. "spaceship-obstacle-large-sprite-",
      vehicle_name = mod_prefix .. "spaceship-obstacle-large-vehicle",
  },
}

---@type table<string, SpaceshipObstacleEntityParticleInfo>
SpaceshipObstacles.entity_particle_templates = {
  ["ice"] = {speed = 1/300},
  ["small"] = {
    speed = 1/300,
    projectile_name = mod_prefix.."spaceship-obstacle-entity-small-projectile",
    targetable_name = mod_prefix.."spaceship-obstacle-entity-small-targetable",
  },
  ["large"] = {
    speed = 1/600,
    projectile_name = mod_prefix.."spaceship-obstacle-entity-large-projectile",
    targetable_name = mod_prefix.."spaceship-obstacle-entity-large-targetable",
  }
}

-- names of the entities used to make the asteroids mineable when a ship is stopped
SpaceshipObstacles.mineable_particles = {}
for x=1,16 do
  table.insert(SpaceshipObstacles.mineable_particles, mod_prefix .. "spaceship-obstacle-small-static-"..x)
  table.insert(SpaceshipObstacles.mineable_particles, mod_prefix .. "spaceship-obstacle-medium-static-"..x)
  table.insert(SpaceshipObstacles.mineable_particles, mod_prefix .. "spaceship-obstacle-large-static-"..x)
end

SpaceshipObstacles.collision_slowdown_factor = 0.98 -- slow down the ship when an obstacle collides with it
SpaceshipObstacles.particle_spawn_range = 32 -- same as laser turret prepare range

SpaceshipObstacles.all_targetables = {}
for _, particle in pairs(SpaceshipObstacles.particles) do
  if particle.vehicle_name then
    SpaceshipObstacles.all_targetables[particle.vehicle_name] = true
  end
end
SpaceshipObstacles.obstacle_damage_multipliers = {
  ["electric-turret"] = 120,
  ["ammo-turret"] = 12
}

SpaceshipObstacles.default_asteroid_density = 1
SpaceshipObstacles.asteroid_density_by_zone_type = {
  ["asteroid-belt"] = 2,
  ["asteroid-field"] = 3
}
SpaceshipObstacles.near_enough_by_zone_type = {
  ["asteroid-belt"] = 300,
  ["asteroid-field"] = 4500
}

---@param spaceship_speed number
---@return number
function SpaceshipObstacles.particle_speed_factor(spaceship_speed) -- particle speed from spaceship speed
  return spaceship_speed > 0 and (spaceship_speed / Spaceship.speed_taper) ^ Spaceship.particle_speed_power * Spaceship.speed_taper or 0
end

--- Gets the asteroid density caption for a spaceship
---@param spaceship SpaceshipType the spaceship data
function SpaceshipObstacles.get_asteroid_density_caption(spaceship)
  if not spaceship.asteroid_density then return {"space-exploration.spaceship-asteroid-density-default"} end
  if spaceship.asteroid_density < SpaceshipObstacles.asteroid_density_by_zone_type["asteroid-belt"] then return {"space-exploration.spaceship-asteroid-density-default"} end
  if spaceship.asteroid_density < SpaceshipObstacles.asteroid_density_by_zone_type["asteroid-field"] then return {"space-exploration.spaceship-asteroid-density-belt"} end
  return {"space-exploration.spaceship-asteroid-density-field"}
end

--- Gets the asteroid density for a spaceship
---@param spaceship SpaceshipType the spaceship data
function SpaceshipObstacles.get_asteroid_density(spaceship)
  local density = SpaceshipObstacles.default_asteroid_density
  local zone = Zone.find_nearest_zone(
    spaceship.space_distortion,
    spaceship.stellar_position,
    spaceship.star_gravity_well,
    spaceship.planet_gravity_well
  )
  local delta_v = Zone.get_travel_delta_v_sub(spaceship, zone)
  if zone and zone.type and SpaceshipObstacles.asteroid_density_by_zone_type[zone.type] and delta_v < SpaceshipObstacles.near_enough_by_zone_type[zone.type] then
    density = SpaceshipObstacles.asteroid_density_by_zone_type[zone.type]
  end
  return density
end

--[[
Destroys all particles on a surface
]]
---@param spaceship SpaceshipType
---@param surface LuaSurface
function SpaceshipObstacles.destroy(spaceship, surface)
  if spaceship.particle_objects then
    for _, objects in pairs(spaceship.particle_objects) do
      for _, object in pairs(objects) do
        if object.valid then object.destroy() end
      end
    end
    spaceship.particle_objects = nil
  end

  local destroy_names = {}
  table.insert(destroy_names, SpaceshipObstacles.particle_travel_anchor)
  for _, particle in pairs(SpaceshipObstacles.particles) do
    if particle.vehicle_name then
      table.insert(destroy_names, particle.vehicle_name)
    end
  end
  for _, mineable_particle in pairs(SpaceshipObstacles.mineable_particles) do
    table.insert(destroy_names, mineable_particle)
  end
  local destroy_entities = surface.find_entities_filtered{name = destroy_names}
  for _, entity in pairs(destroy_entities) do
    -- this does not raise any event!
    -- it will silently destroy the entity
    -- if any mod was tracking the space rocks, it will get borked by this
    -- why do potentially other-mod breaking thing?
    -- we do this for performance reasons because raising events is expensive
    entity.destroy()
  end
  for _, proxy in pairs(surface.find_entities_filtered{name = SpaceshipObstacles.particle_enemy_proxy}) do
    util.safe_destroy(proxy)
  end
end

--[[
Travel anchor particles are used for visual only particles that move exactly downward.
One particle may have many sprites attached to it.
As such, travel anchor particles are reused based on speed and position along the y-axis.
This will get the travel anchor particle for a speed and position, or create it if it does not exist.
]]
---@param spaceship SpaceshipType
---@param surface LuaSurface
---@param y number
---@param particle_template SpaceshipObstacleParticleInfo
---@return LuaEntity
function SpaceshipObstacles.get_make_travel_anchor_particle(spaceship, surface, y, particle_template)
  local speed = particle_template.speed
  if not (spaceship.travel_anchor_particles
          and spaceship.travel_anchor_particles[speed]
          and spaceship.travel_anchor_particles[speed].valid
          and y + 10 > spaceship.travel_anchor_particles[speed].position.y) then
    spaceship.travel_anchor_particles = spaceship.travel_anchor_particles or {}
    spaceship.travel_anchor_particles[speed] = surface.create_entity({
      name = SpaceshipObstacles.particle_travel_anchor,
      position = {
        x = spaceship.known_bounds.left_top.x - SpaceshipObstacles.particle_spawn_range,
        y = spaceship.known_bounds.left_top.y - SpaceshipObstacles.particle_spawn_range - 10 - 10
      },
      direction = defines.direction.south
    })

    table.insert(spaceship.particles, {
      valid = true,
      vehicle = spaceship.travel_anchor_particles[speed],
      speed = speed,
    })
  end
  return spaceship.travel_anchor_particles[speed]
end

--[[
Computes the number of asteroids to spawn for a certain template.
The number of asteroids to spawn is based on the spaceship's speed and the time passed.
]]
---@param spaceship SpaceshipType
---@param time_passed integer
---@param particle_template SpaceshipObstacleParticleInfo
---@return integer
function SpaceshipObstacles.get_num_particles_to_spawn(spaceship, time_passed, particle_template)
  local density = spaceship.asteroid_density or SpaceshipObstacles.default_asteroid_density
  local effective_speed = spaceship.speed * density
  if particle_template.max_effective_speed then
    effective_speed = math.min(effective_speed, particle_template.max_effective_speed)
  end
  local spawn_particles_quota = (Spaceship.minimum_mass + spaceship.integrity_stress) * effective_speed / 60 * particle_template.multiplier * time_passed
  local spawn_particles_whole = math.floor(spawn_particles_quota)

  -- we can only ever spawn a whole number of particles so use math.random() to average out the decimal part of spawn_particles_quota
  local spawn_particles_chance = spawn_particles_quota - spawn_particles_whole
  if math.random() <= spawn_particles_chance then
    spawn_particles_whole = spawn_particles_whole + 1
  end

  return spawn_particles_whole
end

--[[
Determines if a surface has no players on it. Useful for optimizing away visual particles if no one can see them.
]]
---@param surface LuaSurface
---@return boolean
function SpaceshipObstacles.surface_has_no_players(surface)
  for _, player in pairs(game.connected_players) do
    if player.surface.index == surface.index then
      return false
    end
  end
  return true
end

--[[
Spawns a visual only particle.
These particles are always just sprites attached to a travel anchor particle by LuaRendering.draw_sprite
]]
---@param spaceship SpaceshipType
---@param surface LuaSurface
---@param time_passed integer
---@param particle_template SpaceshipObstacleParticleInfo
function SpaceshipObstacles.spawn_particles_visual_only(spaceship, surface, time_passed, particle_template)
  local spawn_particles_whole = SpaceshipObstacles.get_num_particles_to_spawn(spaceship, time_passed, particle_template)
  if spawn_particles_whole > 0 then
    local speed_factor = SpaceshipObstacles.particle_speed_factor(spaceship.speed)
    local x_min = spaceship.known_bounds.left_top.x - SpaceshipObstacles.particle_spawn_range
    local x_max = spaceship.known_bounds.right_bottom.x + SpaceshipObstacles.particle_spawn_range
    local spawn_y = spaceship.known_bounds.left_top.y - SpaceshipObstacles.particle_spawn_range - 20
    local travel_anchor_particle = SpaceshipObstacles.get_make_travel_anchor_particle(spaceship, surface, spawn_y, particle_template)
    spaceship.particle_objects = spaceship.particle_objects or {}
    spaceship.particle_objects[travel_anchor_particle.unit_number] = spaceship.particle_objects[travel_anchor_particle.unit_number] or {}
    travel_anchor_particle.speed = particle_template.speed * spaceship.speed
    local x_delta = x_max - x_min
    local y_factor = time_passed * speed_factor * particle_template.speed
    for i = 1, spawn_particles_whole do
      local spawn_x = x_min + math.random() * x_delta
      local this_spawn_y = spawn_y - math.random() * y_factor
      table.insert(spaceship.particle_objects[travel_anchor_particle.unit_number], rendering.draw_sprite({
        surface = surface,
        sprite = particle_template.sprite_name,
        target = {
          entity = travel_anchor_particle,
          offset = {
            x = spawn_x - travel_anchor_particle.position.x,
            y = this_spawn_y - travel_anchor_particle.position.y
          }
        },
      }))
    end
  end
end

--[[
Spawns a non-visual only particle.
Asteroids are invisible vehicles, with an invisible enemy character riding them that have a graphic attached with LuaRendering.draw_sprite
]]
---@param spaceship SpaceshipType
---@param surface LuaSurface
---@param time_passed integer
---@param particle_template SpaceshipObstacleParticleInfo
---@param no_players boolean
function SpaceshipObstacles.spawn_particles_non_visual(spaceship, surface, time_passed, particle_template, no_players)
  local spawn_particles_whole = SpaceshipObstacles.get_num_particles_to_spawn(spaceship, time_passed, particle_template)
  if spawn_particles_whole > 0 then
    local speed_factor = SpaceshipObstacles.particle_speed_factor(spaceship.speed)
    local x_min = spaceship.known_bounds.left_top.x - SpaceshipObstacles.particle_spawn_range
    local x_max = spaceship.known_bounds.right_bottom.x + SpaceshipObstacles.particle_spawn_range
    local spawn_y = spaceship.known_bounds.left_top.y - SpaceshipObstacles.particle_spawn_range - 20
    -- aabb cannot be exactly the ship bounds since asteroids are not points (they have a rectangular bounding box)
    local aabb = {
      min_x = spaceship.known_bounds.left_top.x - SpaceshipObstacles.bounding_box_buffer,
      max_x = spaceship.known_bounds.right_bottom.x + SpaceshipObstacles.bounding_box_buffer,
      min_y = spaceship.known_bounds.left_top.y - SpaceshipObstacles.bounding_box_buffer,
      max_y = spaceship.known_bounds.right_bottom.y + SpaceshipObstacles.bounding_box_buffer
    }
    local speed = particle_template.speed * spaceship.speed
    local x_delta = x_max - x_min
    local y_factor = time_passed * speed_factor * particle_template.speed
    for i = 1, spawn_particles_whole do
      local spawn_x = x_min + math.random() * x_delta
      local this_spawn_y = spawn_y - math.random() * y_factor
      local spawn_orientation = 0.5 - SpaceshipObstacles.particle_orientation_variance * (math.random() - math.random())
      local intersects = util.intersects_ray_aabb({x=spawn_x,y=spawn_y}, spawn_orientation, aabb)
      if not no_players or intersects then
        local particle = table.deepcopy(particle_template)
        particle.valid = true
        particle.variation = math.random(particle.variations)
        particle.vehicle = surface.create_entity{
          name = particle_template.vehicle_name,
          position = {x = spawn_x, y = this_spawn_y },
          create_build_effect_smoke = false,
        }
        particle.vehicle.orientation = spawn_orientation
        -- smart turrets only attack asteroids that will hit the ship
        if intersects then
          particle.enemy_proxy = surface.create_entity{
            name = SpaceshipObstacles.particle_enemy_proxy,
            position = {x = spawn_x, y = this_spawn_y },
          }
          particle.vehicle.set_driver(particle.enemy_proxy)
        end
        rendering.draw_sprite{
          sprite = particle.sprite_prefix..particle.variation,
          surface = surface,
          target = particle.vehicle,
          scale = particle.scale
        }
        particle.vehicle.speed = speed
        table.insert(spaceship.particles, particle)
      end
    end
  end
end

--[[
Spawns particles from a particle_template.
]]
---@param spaceship SpaceshipType
---@param surface LuaSurface
---@param time_passed integer
---@param particle_template SpaceshipObstacleParticleInfo
function SpaceshipObstacles.spawn_particles_speed_size(spaceship, surface, time_passed, particle_template)
  -- only spawn the asteroids if the conditions on their template are met
  if spaceship.speed > (particle_template.min_speed or 0)
   and spaceship.integrity_stress > (particle_template.min_size or 0) then
    local no_players = SpaceshipObstacles.surface_has_no_players(surface)
    if particle_template.sprite_name then
      -- visual particles are only spawned if players are on that surface
      if not no_players then
        SpaceshipObstacles.spawn_particles_visual_only(spaceship, surface, time_passed, particle_template)
      end
    else
      SpaceshipObstacles.spawn_particles_non_visual(spaceship, surface, time_passed, particle_template, no_players)
    end
  end
end

--[[
Resolves a collision between a particle and an obstacle it collided with.
Either the particle or the obstacle will survive, not both.
If the particle has enough effective health to kill the obstacle, the obstacle dies and the particle loses hp
Otherwise, the obstacle has enough effective health to kill the particle, so the particle dies and the obstacle loses hp
]]
---@param particle_entity LuaEntity
---@param other_entity LuaEntity
function SpaceshipObstacles.smash_particle_to_entity(particle_entity, other_entity)
  local particle_effective_health = particle_entity.health / SpaceshipObstacles.particle_hp_multiplier
  if particle_effective_health > other_entity.health then
    -- the particle "wins" the collision
    local other_effective_health = other_entity.health * SpaceshipObstacles.particle_hp_multiplier
    particle_entity.health = particle_entity.health - other_effective_health
    other_entity.die()
  else
    -- the obstacle "wins" the collision
    other_entity.health = other_entity.health - particle_effective_health
    if particle_entity.type == "car" and particle_entity.get_driver() then
      particle_entity.get_driver().destroy()
    end
    particle_entity.die()
  end
end

--[[
Listen to the event when an entity is damaged. Necessary in order to modify the damage done to/from particles
]]
---@param event EventData.on_entity_damaged Event data
function SpaceshipObstacles.on_entity_damaged(event)
  --[[
  In a vehicle collision:
  the struck object takes damage first with the vehicle as the cause.
  Then the striking vehile takes damage with no cause. (may be the crash trigger damage?)
  ]]
  if event.entity.valid then
    if SpaceshipObstacles.all_targetables[event.entity.name] then
      if event.cause and event.cause.valid then
        if SpaceshipObstacles.obstacle_damage_multipliers[event.cause.type] then -- take more damage from certain sources.
          event.entity.health = event.entity.health - event.final_damage_amount * (SpaceshipObstacles.obstacle_damage_multipliers[event.cause.type] - 1)
        end
      end
      event.entity.surface.create_trivial_smoke{name = "smoke", position = event.entity.position }
    elseif event.cause and event.cause.valid and SpaceshipObstacles.all_targetables[event.cause.name] then
      if event.damage_type.name == "impact" then
        if event.entity.name ~= "shield-projector-barrier" then
          local spaceship = Spaceship.from_own_surface_index(event.entity.surface.index)
          if spaceship then spaceship.speed = spaceship.speed * SpaceshipObstacles.collision_slowdown_factor end
        end
        SpaceshipObstacles.smash_particle_to_entity(event.cause, event.entity)
        if event.cause.valid then
          table.insert(storage.spaceship_projectile_speeds, {entity = event.cause, speed = event.cause.speed})
        end
      end
    end
  end
end
Event.addListener(defines.events.on_entity_damaged, SpaceshipObstacles.on_entity_damaged)

function SpaceshipObstacles.tick_projectile_speeds()
  for i, ps in pairs(storage.spaceship_projectile_speeds) do
    if ps.entity and ps.entity.valid and ps.entity.type == "car" then
      ps.entity.speed = ps.speed
    end
    storage.spaceship_projectile_speeds[i] = nil
  end
end

--[[
Listen for when vehicles are destroyed so we can destroy their dummy drivers.
]]
---@param event EntityRemovalEvent Event data
function SpaceshipObstacles.on_entity_removed(event)
  if event.entity and event.entity.valid then
    if event.entity.type == "car" and SpaceshipObstacles.all_targetables[event.entity.name] then
      local driver = event.entity.get_driver()
      if driver then driver.destroy() end
    end
  end
end
Event.addOnEntityRemovedListeners(SpaceshipObstacles.on_entity_removed)

--- Adds an entity to the pool of moveable entities.
--- Moveable entities act like obstacles in that:
--- 1. they move downwards
--- 2. they are targetted by turrets
--- 3. they get destroyed by shields
--- They are dissimilar in that:
--- 1. they don't damage anything on the ship
--- 2. they suck for UPS
---@param spaceship SpaceshipType
---@param entity LuaEntity
---@param name string
function SpaceshipObstacles.add_moveable_entity(spaceship, entity, name)
  if spaceship and entity then
    spaceship.entity_particles = spaceship.entity_particles or {}
    local entity_particle = table.deepcopy(SpaceshipObstacles.entity_particle_templates[name])
    entity_particle.graphic = entity
    entity_particle.valid = true
    table.insert(spaceship.entity_particles, entity_particle)
  end
end

--- Debris needs to be moved. This trigger listens for when that is created on a spaceship surface,
--- and if so, puts it in the list of things that need to move.
---@param event EventData.on_trigger_created_entity Event data
function SpaceshipObstacles.on_trigger_created_entity(event)
  if event.entity and event.entity.valid and event.entity.name == mod_prefix.."trigger-movable-debris" then
    local surface = event.entity.surface
    local spaceship = Spaceship.from_own_surface_index(surface.index)
    if spaceship then
      local entities = surface.find_entities_filtered{type = "simple-entity", area = Util.position_to_area(event.entity.position, 0.5)}
      for _, entity in pairs(entities) do
        if string.find(entity.name, "meteor") then
          SpaceshipObstacles.add_moveable_entity(spaceship, entity, "large")
        else
          SpaceshipObstacles.add_moveable_entity(spaceship, entity, "small")
        end
      end
    end
  end
end
Event.addListener(defines.events.on_trigger_created_entity, SpaceshipObstacles.on_trigger_created_entity)

---Moves the moveable entities. Handles destroying them safely if one of the component entities is
---destroyed or if they get offscreen.
---@param spaceship SpaceshipType Spaceship data
---@param surface LuaSurface spaceship surface
function SpaceshipObstacles.tick_entity_obstacles(spaceship, surface)
  -- log("tick_entity_obstacles")
  spaceship.entity_particles = spaceship.entity_particles or {}
  local speed_factor = SpaceshipObstacles.particle_speed_factor(spaceship.speed)
  local upper_bound = spaceship.known_bounds.right_bottom.y + SpaceshipObstacles.particle_spawn_range + 32
  for i = #spaceship.entity_particles, 1, -1 do -- Reverse iteration for safe removal
    local entity_particle = spaceship.entity_particles[i]
    if not (entity_particle.graphic and entity_particle.graphic.valid) then -- killed or mined
      entity_particle.valid = false
    elseif entity_particle.graphic.position.y > upper_bound then -- out of range
      entity_particle.valid = false
    elseif entity_particle.projectile and entity_particle.projectile.valid == false then -- projectile was there but detonated
      entity_particle.valid = false
    elseif entity_particle.targetable and entity_particle.targetable.valid == false then -- projectile detonated
      entity_particle.valid = false
    end

    if not entity_particle.valid then
      -- destroy invalid entity particles
      if entity_particle.graphic and entity_particle.graphic.valid then
        entity_particle.graphic.destroy()
        entity_particle.graphic = nil
      end
      if entity_particle.projectile and entity_particle.projectile.valid then
        entity_particle.projectile.destroy()
        entity_particle.projectile = nil
      end
      if entity_particle.targetable and entity_particle.targetable.valid then
        entity_particle.targetable.destroy()
        entity_particle.targetable = nil
      end
      table.remove(spaceship.entity_particles, i)
    else
      -- update the speed and move valid entity particles
       local position = entity_particle.graphic.position
       position.y = position.y + entity_particle.speed * speed_factor

       if spaceship.speed > 0.001 then
        entity_particle.graphic.teleport(position)

          if entity_particle.projectile then
            entity_particle.projectile.speed = entity_particle.speed * speed_factor
          elseif entity_particle.projectile_name then
            entity_particle.projectile = surface.create_entity{
              name = entity_particle.projectile_name,
              -- particle would overtake the rest if we didn't subtract the current vector
              position = util.vectors_add(position, {x = 0, y = -entity_particle.speed * speed_factor}),
              speed = entity_particle.speed * speed_factor,
              target = {x = position.x, y = position.y + 100},
              force="enemy"
            }
          end
          if entity_particle.targetable then
            entity_particle.targetable.teleport(position)
          elseif entity_particle.targetable_name then
            entity_particle.targetable = surface.create_entity{
              name = entity_particle.targetable_name,
              position = position,
              target = {x = position.x, y = position.y + 100},
              force="enemy"
            }
          end
       else
         if entity_particle.projectile and entity_particle.projectile.valid then
          entity_particle.projectile.destroy()
          entity_particle.projectile = nil
         end
         if entity_particle.targetable and entity_particle.targetable.valid then
          entity_particle.targetable.destroy()
          entity_particle.targetable = nil
         end
       end
    end
  end
end

---@param spaceship SpaceshipType
---@param surface LuaSurface
---@param time_passed integer
function SpaceshipObstacles.tick_obstacles(spaceship, surface, time_passed)
  spaceship.particles = spaceship.particles or {}
  spaceship.mineables = spaceship.mineables or {}

  -- spawn particles of each template
  for _, particle_template in pairs(SpaceshipObstacles.particles) do
    SpaceshipObstacles.spawn_particles_speed_size(spaceship, surface, time_passed, particle_template)
  end

  -- update particles
  if spaceship.particles then
    local speed_factor = SpaceshipObstacles.particle_speed_factor(spaceship.speed)
    local upper_bound = spaceship.known_bounds.right_bottom.y + SpaceshipObstacles.particle_spawn_range + 32
    for i = #spaceship.particles, 1, -1 do
      local particle = spaceship.particles[i]
      if not (particle.vehicle and particle.vehicle.valid
      and particle.vehicle.position.y < upper_bound) then -- the particle is in bounds
        particle.valid = false
      end

      if not particle.valid then
        if particle.vehicle and particle.vehicle.valid then
          particle.vehicle.destroy()
          particle.vehicle = nil
        end
        if particle.enemy_proxy and particle.enemy_proxy.valid then
          particle.enemy_proxy.destroy()
          particle.enemy_proxy = nil
        end
        table.remove(spaceship.particles, i)
      end

      if particle and particle.valid then -- particle is still valid
          particle.vehicle.speed = particle.speed * speed_factor

          local targetable = particle.vehicle
          local position = targetable.position

          if targetable and particle.destroys_floor then
            -- destroy floor
            local x = math.floor(position.x)
            local y = math.floor(position.y)
            if spaceship.known_tiles[x] and spaceship.known_tiles[x][y] then

              spaceship.known_tiles[x][y] = nil

              local tile = surface.get_tile(x, y)
              local tile_name = tile.name
              if tile_name ~= name_space_tile then

                targetable.damage(50, "neutral", "explosion") -- damage the particle

                local entities = surface.find_entities_filtered{ -- destroy entities on the floor
                  area = util.tile_to_area({x=x,y=y}),
                  collision_mask = {
                    [storage.named_collision_masks.space_collision_layer] = true,
                    object = true, --"obct-layer", ?
                    resource = true,
                  }
                }
                for _, entity in pairs(entities) do
                  if entity and entity.valid then entity.die() end
                end

                surface.set_tiles(
                  {{name=name_space_tile, position = {x,y}}},
                  false, -- corect tiles
                  true, -- remove_colliding_entities
                  true, -- remove_colliding_decoratives
                  true -- raise_event
                )

                if Util.table_contains(Spaceship.names_spaceship_floors, tile_name) then
                  -- make blueprint for the tile.
                  surface.create_entity{name = "tile-ghost", inner_name = tile_name, force = spaceship.force_name, position = {x=x,y=y}}
                end

                SpaceshipIntegrity.start_integrity_check(spaceship)
              end
            end
          end
      end
    end
  end

  -- swap vehicles with mineables and vice-versa when the spaceship changes between stopped and moving
  SpaceshipObstacles.maybe_swap_vehicles_mineables(spaceship, surface)
end

--[[
Converts name + variation from vehicle asteroids to mineable asteroids
]]
---@param vehicle_name string
---@param variation uint
---@return string?
function SpaceshipObstacles.static_name_for_vehicle_name_and_variation(vehicle_name, variation)
  if vehicle_name == mod_prefix .. "spaceship-obstacle-small-vehicle" then
    return mod_prefix .. "spaceship-obstacle-small-static-"..variation
  elseif vehicle_name == mod_prefix .. "spaceship-obstacle-medium-vehicle" then
    return mod_prefix .. "spaceship-obstacle-medium-static-"..variation
  elseif vehicle_name == mod_prefix .. "spaceship-obstacle-large-vehicle" then
    return mod_prefix .. "spaceship-obstacle-large-static-"..variation
  else
    return nil
  end
end

--[[
Converts name + variation from mineable asteroids to vehicle asteroids
]]
---@param static_name string
---@param variation uint
---@return SpaceshipObstacleParticleInfo?
---@return uint variation
function SpaceshipObstacles.particle_template_for_static_name(static_name, variation)
  if string.find(static_name,"spaceship-obstacle-small-static-", 1, true) then
    return SpaceshipObstacles.particles["small"], variation
  elseif string.find(static_name,"spaceship-obstacle-medium-static-", 1, true) then
    return SpaceshipObstacles.particles["medium"], variation
  elseif string.find(static_name,"spaceship-obstacle-large-static-", 1, true) then
    return SpaceshipObstacles.particles["large"], variation
  else
    return nil, 1
  end
end

--[[
Tries to swap vehicles asteroids with mineable asteroids when the spaceship's speed goes from moving to stopped
Tries to swap mineable asteroids with vehicle asteroids when the spaceship's speed goes from stopped to moving
]]
---@param spaceship SpaceshipType
---@param surface LuaSurface
function SpaceshipObstacles.maybe_swap_vehicles_mineables(spaceship, surface)
  if spaceship.speed and spaceship.last_speed then
    if spaceship.speed == 0 and spaceship.speed ~= spaceship.last_speed then
      -- spaceship came to a stop, replace vehicles with mineables
      for _, particle in pairs(spaceship.particles) do
        if particle.valid and particle.vehicle.valid then
          -- make the mineable
          local mineable_name = SpaceshipObstacles.static_name_for_vehicle_name_and_variation(particle.vehicle.name, particle.variation)
          if mineable_name then
            local mineable = {
              mineable = surface.create_entity{
                name=mineable_name,
                position=particle.vehicle.position,
                force="enemy"
              },
              variation=particle.variation
            }
            table.insert(spaceship.mineables, mineable)
          end
          -- destroy the vehicle
          if particle.vehicle and particle.vehicle.valid then
            particle.vehicle.destroy()
            particle.vehicle = nil
          end
          if particle.enemy_proxy and particle.enemy_proxy.valid then
            particle.enemy_proxy.destroy()
            particle.enemy_proxy = nil
          end
        end
      end
      spaceship.particles = {}
    elseif spaceship.last_speed == 0 and spaceship.speed ~= spaceship.last_speed then
      -- spaceship is starting moving, replaces mineables with vehicles
      local aabb = {
        min_x = spaceship.known_bounds.left_top.x,
        max_x = spaceship.known_bounds.right_bottom.x,
        min_y = spaceship.known_bounds.left_top.y,
        max_y = spaceship.known_bounds.right_bottom.y
      }
      local no_players = SpaceshipObstacles.surface_has_no_players(surface)
      for _, mineable in pairs(spaceship.mineables) do
        if mineable.mineable and mineable.mineable.valid then
          -- make the vehicle
          local particle_template, variation = SpaceshipObstacles.particle_template_for_static_name(mineable.mineable.name, mineable.variation)
          if particle_template then
            local speed = particle_template.speed * spaceship.speed
            local spawn_orientation = 0.5 - SpaceshipObstacles.particle_orientation_variance * (math.random() - math.random())
            local intersects = util.intersects_ray_aabb({x=mineable.mineable.position.x,y=mineable.mineable.position.y}, spawn_orientation, aabb)
            if not no_players or intersects then
              local particle = table.deepcopy(particle_template) --[[@as SpaceshipObstacleParticleInfo]]
              particle.valid = true
              particle.variation = variation
              particle.vehicle = surface.create_entity{
                name = particle_template.vehicle_name,
                position = {x = mineable.mineable.position.x, y = mineable.mineable.position.y },
                create_build_effect_smoke = false,
              }
              particle.vehicle.orientation = spawn_orientation
              -- smart turrets only attack asteroids that will hit the ship
              if intersects then
                particle.enemy_proxy = surface.create_entity{
                  name = SpaceshipObstacles.particle_enemy_proxy,
                  position = {x = mineable.mineable.position.x, y = mineable.mineable.position.y },
                }
                particle.vehicle.set_driver(particle.enemy_proxy)
              end
              rendering.draw_sprite{
                sprite = particle.sprite_prefix..particle.variation,
                surface = surface,
                target = particle.vehicle,
                scale = particle.scale
              }
              particle.vehicle.speed = speed
              table.insert(spaceship.particles, particle)
            end
          end
          -- destroy the mineable
          if mineable.mineable and mineable.mineable.valid then
            mineable.mineable.destroy()
          end
        end
      end
      spaceship.mineables = {}
    end
  end

  spaceship.last_speed = spaceship.speed
end

function SpaceshipObstacles.on_init()
  storage.spaceship_projectile_speeds = {}
end
Event.addListener("on_init", SpaceshipObstacles.on_init, true)

return SpaceshipObstacles
