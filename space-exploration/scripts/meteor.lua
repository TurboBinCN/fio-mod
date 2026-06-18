local Meteor = {}

Meteor.name_meteor_defence = mod_prefix.."meteor-defence"
Meteor.name_meteor_defence_container = mod_prefix.."meteor-defence-container"
Meteor.name_meteor_defence_charger = mod_prefix.."meteor-defence-charger"
Meteor.name_meteor_defence_ammo = mod_prefix.."meteor-defence-ammo"
Meteor.name_meteor_defence_beam = mod_prefix.."meteor-defence-beam"
Meteor.name_meteor_defence_beam_offset = {x = -1, y = -5}

Meteor.name_meteor_point_defence = mod_prefix.."meteor-point-defence"
Meteor.name_meteor_point_defence_container = mod_prefix.."meteor-point-defence-container"
Meteor.name_meteor_point_defence_charger = mod_prefix.."meteor-point-defence-charger"
Meteor.name_meteor_point_defence_charger_overcharged = mod_prefix.."meteor-point-defence-charger-overcharged"
Meteor.name_meteor_point_defence_ammo = mod_prefix.."meteor-point-defence-ammo"
Meteor.name_meteor_point_defence_beam = mod_prefix.."meteor-point-defence-beam"
Meteor.name_meteor_point_defence_mask = mod_prefix.."meteor-point-defence-mask"
Meteor.name_meteor_point_defence_beam_offsets = {
  {x = 0.1, y = -3.5},
  {x = 0.4, y = -3.1},
  {x = -0.3, y = -3.4},
  {x = 0.7, y = -3.2},
}

Meteor.meteor_hole_variants = {
  {
    offset = {x=5, y=5},
    matrix = { -- variant 1
      {0, 1, 0, 0},
      {0, 1, 1, 0},
      {1, 1, 1, 1},
      {0, 0, 0, 1}
    }
  },
  {
    offset = {x=4, y=5},
    matrix = { -- variant 2
      {1, 0, 0},
      {1, 1, 1},
      {1, 1, 0},
      {0, 1, 0},
    }
  },
  {
    offset = {x=6, y=6},
    matrix = { -- variant 3
      {0, 1, 1, 0, 0},
      {1, 1, 1, 1, 0},
      {1, 0, 1, 1, 1},
      {0, 0, 1, 1, 0},
      {0, 0, 1, 0, 0}
    }
  },
  {
    offset = {x=7, y=9},
    matrix = { -- variant 4
      {1, 0, 0, 0, 0, 0},
      {1, 1, 0, 0, 0, 0},
      {0, 1, 1, 0, 1, 0},
      {0, 0, 1, 1, 1, 0},
      {0, 1, 1, 1, 1, 0},
      {0, 0, 1, 0, 1, 1},
      {0, 0, 0, 0, 0, 1},
      {0, 0, 0, 0, 0, 1},
    }
  },
  {
    offset = {x=6, y=10},
    matrix = { -- variant 5
      {0, 0, 1, 0, 0, 0},
      {0, 0, 1, 0, 0, 1},
      {0, 0, 1, 1, 0, 1},
      {0, 0, 1, 1, 1, 1},
      {0, 1, 1, 1, 1, 0},
      {1, 1, 1, 1, 0, 0},
      {0, 1, 1, 1, 0, 0},
      {0, 1, 1, 0, 0, 0},
      {0, 1, 0, 0, 0, 0}
    }
  }
}

Meteor.name_setting_meteor_interval = mod_prefix.."meteor-interval"

Meteor.defence_accuracy = 0.8
Meteor.defence_full_power = 2000 * 1000000
Meteor.defence_passive_draw = 5000000

Meteor.point_defence_range = 64
Meteor.point_defence_accuracy = 0.5
Meteor.point_defence_full_power = 200 * 1000000
Meteor.point_defence_fire_power = Meteor.point_defence_full_power / 4
Meteor.point_defence_passive_draw = 500000
Meteor.point_defence_passive_draw_overcharged = 250000
Meteor.point_defence_efficiency = 1
Meteor.point_defence_efficiency_overcharged = 0.25

Meteor.meteor_swarm_altitude = 100
Meteor.meteor_swarm_x_deviation = Meteor.meteor_swarm_altitude

Meteor.meteor_fall_time = 2 * 60
Meteor.meteor_chain_delay = 10

Meteor.meteor_random_range = 512
Meteor.meteor_variants = 16
Meteor.meteor_position_deviation = 10
Meteor.meteor_chain_distance = 10

Meteor.tick_skip_meteor_shower = 10
Meteor.tick_skip_defence = 30
Meteor.tick_skip_defence_charged = 3600

---Returns the index of a `MeteorDefenceInfo` table in the `storage.meteor_defences` array given the
---`unit_number` of its container (ammo-turret) entity.
---@param unit_number uint `unit_number` of container entity
---@param type string Can be "global" or "point"; defaults to "point"
---@return uint? index
function Meteor.get_any_defence_index(unit_number, type)
  local group = (type == "global") and storage.meteor_defences or storage.meteor_point_defences

  for i, compare in pairs(group) do
    if compare.unit_number == unit_number then return i end
  end
end

---Returns the `MeteorDefenceInfo` table associated with a meteor defense entity, if one exists.
---@param entity LuaEntity Meteor defense entity, _must_ be valid
---@return MeteorDefenceInfo? defence
function Meteor.any_defence_from_entity(entity)
  local entity_name = entity.name
  local unit_number = entity.unit_number

  local zone = Zone.from_surface(entity.surface)
  if not zone then return end

  -- First, search for it in the appropriate zone defences tables. If zone doesn't have a
  -- `meteor_defences` table (because it's a spaceship), search through the `global` arrays.
  if entity_name == Meteor.name_meteor_defence_container then
    if zone.meteor_defences and zone.meteor_defences[unit_number] then
      return zone.meteor_defences[unit_number]
    else  -- zone is a spaceship
      local index = Meteor.get_any_defence_index(unit_number, "global")
      if index then return storage.meteor_defences[index] end
    end
  elseif entity_name == Meteor.name_meteor_defence_charger then
    if zone.meteor_defences then
      for _, defence in pairs(zone.meteor_defences) do
        if defence.charger == entity then return defence end
      end
    else  -- zone is a spaceship
      for _, defence in pairs(storage.meteor_defences) do
        if defence.charger == entity then return defence end
      end
    end
  elseif entity_name == Meteor.name_meteor_point_defence_container then
    if zone.meteor_point_defences and zone.meteor_point_defences[unit_number] then
      return zone.meteor_point_defences[unit_number]
    else  -- zone is a spaceship
      local index = Meteor.get_any_defence_index(unit_number, "point")
      if index then return storage.meteor_point_defences[index] end
    end
  elseif entity_name == Meteor.name_meteor_point_defence_charger
   or entity_name == Meteor.name_meteor_point_defence_charger_overcharged then
    if zone.meteor_point_defences then
      for _, defence in pairs(zone.meteor_point_defences) do
        if defence.charger == entity then return defence end
      end
    else  -- zone is a spaceship
      for _, defence in pairs(storage.meteor_point_defences) do
        if defence.charger == entity then return defence end
      end
    end
  end
end

---Removes references to a particular `MeteorDefenceInfo` table from the relevant zone and `global`
---tables. Used when a container or charger is found to be invalid.
---@param defence MeteorDefenceInfo Defense data
---@param retain_global boolean? If true, the defence will not be removed from the global table. Useful for died events
function Meteor.remove_any_defence_references(defence, retain_global)
  if defence.type == "global" then
    if not retain_global then
      local index = Meteor.get_any_defence_index(defence.unit_number, "global")
      if index then table.remove(storage.meteor_defences, index) end
    end

    if defence.zone.meteor_defences then
      defence.zone.meteor_defences[defence.unit_number] = nil
    end
  else
    if not retain_global then
      local index = Meteor.get_any_defence_index(defence.unit_number, "point")
      if index then table.remove(storage.meteor_point_defences, index) end
    end

    if defence.zone.meteor_point_defences then
      defence.zone.meteor_point_defences[defence.unit_number] = nil
    end
  end
end

---Handles creation of anym eteor defense entities and populates `storage.meteor_zones` for other
---player entities.
---@param event EntityCreationEvent|EventData.on_entity_cloned Event data
function Meteor.on_entity_created(event)
  local entity = event.entity or event.destination
  if not entity.valid then return end

  local entity_name = entity.name
  local entity_type = entity.type

  if entity_name == Meteor.name_meteor_defence_container
   or entity_name == Meteor.name_meteor_point_defence_container then
    local zone = Zone.from_surface(entity.surface)
    if cancel_creation_when_invalid(zone, entity, event) then return end
    ---@cast zone -?

    -- Disable entity, since it needs to charge first
    entity.active = false

    if entity_name == Meteor.name_meteor_defence_container then
      local charger

      -- If this was a cloning event, try to find the corresponding charger
      if event.destination then
        charger = util.find_entity_or_revive_ghost(
          entity.surface, Meteor.name_meteor_defence_charger, entity.position)
      end

      if not charger then
        charger = entity.surface.create_entity{
          name=Meteor.name_meteor_defence_charger,
          position=entity.position,
          direction=entity.direction,
          force=entity.force,
          create_build_effect_smoke=false
        }
        ---@cast charger -?
        charger.destructible = false
        charger.energy = 0
      end

      local defence = {
        container=entity,
        charger=charger,
        type="global",
        unit_number=entity.unit_number,
        zone=zone
      }

      -- Add defence structure to `global`, and if appropriate, zone tables
      table.insert(storage.meteor_defences, defence)
      if zone.type ~= "spaceship" then
        ---@cast zone -SpaceshipType
        if not zone.meteor_defences then zone.meteor_defences = {} end
        zone.meteor_defences[entity.unit_number] = defence
      end
    else
      local charger

      -- If this was a cloning event, try to find the corresponding charger before making one
      if event.destination then
        charger = util.find_entity_or_revive_ghost(
          entity.surface,
          { Meteor.name_meteor_point_defence_charger, Meteor.name_meteor_point_defence_charger_overcharged },
          entity.position)
      end

      if not charger then
        charger = entity.surface.create_entity{
          name=Meteor.name_meteor_point_defence_charger,
          position=entity.position,
          direction=entity.direction,
          force=entity.force,
          create_build_effect_smoke=false
        }
        ---@cast charger -?
        charger.destructible = false
        charger.energy = 0
      end

      -- Have charger render on top of container
      entity.teleport(entity.position)

      local point_defence = {
        container=entity,
        charger=charger,
        type="point",
        mode=(charger.name == Meteor.name_meteor_point_defence_charger_overcharged)
          and "fast" or "normal",
        unit_number=entity.unit_number,
        zone=zone
      }

      -- Add defence structure to `global` and, if appropriate, zone tables
      table.insert(storage.meteor_point_defences, point_defence)
      if zone.type ~= "spaceship" then
        ---@cast zone -SpaceshipType
        if not zone.meteor_point_defences then zone.meteor_point_defences = {} end
        zone.meteor_point_defences[entity.unit_number] = point_defence
      end
    end

    -- Apply entity settings, if any
    local tags = util.get_tags_from_event(event, Meteor.serialize)
    if tags then Meteor.deserialize(entity, tags) end

    -- Add to list of zones where meteors can appear
    if zone.type ~= "spaceship" then storage.meteor_zones[zone.index] = zone end

  elseif entity_type == "electric-pole" or entity_type == "assembling-machine" then
    if is_player_force(entity.force.name) then
      local zone = Zone.from_surface(entity.surface)
      if zone and zone.type ~= "spaceship" then
        ---@cast zone -SpaceshipType
        storage.meteor_zones[zone.index] = zone
      end
    end
  end
end
Event.addListener(defines.events.on_entity_cloned, Meteor.on_entity_created)
Event.addOnEntityCreatedListeners(Meteor.on_entity_created)

---Handles removal of a meteor defense-associated entity.
---@param event EntityRemovalEvent Event data
function Meteor.on_entity_removed(event)
  local entity = event.entity
  if not entity.valid then return end

  local entity_name = entity.name

  if entity_name ~= Meteor.name_meteor_defence_container
   and entity_name ~= Meteor.name_meteor_point_defence_container then
    return
  end

  local defence = Meteor.any_defence_from_entity(entity)
  if defence then
    if defence.charger.valid then defence.charger.destroy() end
    Meteor.remove_any_defence_references(defence, event.name == defines.events.on_entity_died)
  end
end
Event.addOnEntityRemovedListeners(Meteor.on_entity_removed)

---@param event EventData.on_post_entity_died
local function on_post_entity_died(event)
  local ghost = event.ghost
  local unit_number = event.unit_number
  if not (ghost and unit_number) then return end
  local prototype_name = event.prototype.name
  if prototype_name ~= Meteor.name_meteor_defence_container and prototype_name ~= Meteor.name_meteor_point_defence_container then
    return
  end

  local defenses = prototype_name == Meteor.name_meteor_defence_container and storage.meteor_defences or storage.meteor_point_defences
  for index, defense in pairs(defenses) do -- Find the appropriate table
    if defense.unit_number == unit_number then
      ghost.tags = Meteor.serialize_from_struct(defense)
      table.remove(defenses, index) -- Make sure to remove the entry for the global table
      return
    end
  end
end
Event.addListener(defines.events.on_post_entity_died, on_post_entity_died)

-- Local functions used in the try_* methods

--- Used in Meteor.try_global_defences for defence vs meteors
---@param meteor_shower MeteorShowerInfo
local function update_meteor_data_global(meteor_shower)
  meteor_shower.skip = 30
  meteor_shower.defences_activated = meteor_shower.defences_activated + 1
end

--- Used in Meteor.try_global_defences for defence vs projectiles
---@param projectile ProjectileInfo
---@param charger LuaEntity
local function update_projectile_data_global(projectile, charger)
  projectile.defence_data = projectile.defence_data or {}
  projectile.defence_data[charger.force.name] = projectile.defence_data[charger.force.name]  or {defence_shots = 0, point_defence_shots = 0}
  projectile.defence_data[charger.force.name].defence_shots = projectile.defence_data[charger.force.name].defence_shots + 1
end

--- Method ran when a meteor was successfully hit by global or point defence
---@param meteor_shower MeteorShowerInfo
---@param defence MeteorDefenceInfo Meteor point defense data
local function update_meteor_data_hit(meteor_shower, defence)
  Meteor.credit_kill(defence.container, mod_prefix .. "static-meteor-01")
  meteor_shower.remaining_meteors[math.random(#meteor_shower.remaining_meteors)] = nil
  local remaining_meteors = {}
  for _, meteor in pairs(meteor_shower.remaining_meteors) do
    table.insert(remaining_meteors, meteor)
  end
  meteor_shower.remaining_meteors = remaining_meteors
  return true
end

--- Method ran when a projectile was successfully hit by global or point defence
---@param projectile ProjectileInfo
---@param defence MeteorDefenceInfo
local function update_projectile_data_hit(projectile, defence)
  projectile.health = projectile.health - 1
  if projectile.health <= 0 then
    Meteor.credit_kill(defence.container, "se-delivery-cannon-weapon-capsule-artillery-projectile")
    return true
  end
end

---@param projectile MeteorShowerInfo|ProjectileInfo|DeliveryCannonPayloadInfo
---@return boolean is_friendly_projectile
local function is_friendly_projectile(projectile, charger)
  local charger_force = charger.force
  return projectile.force_name == charger_force.name or charger_force.get_cease_fire(projectile.force_name) or charger_force.get_friend(projectile.force_name)
end


---Attempts to use a meteor defense installation from a given table to defend against a meteor
---shower or projectile. Returns true if a meteor defence successfully activated (against a meteor)
---or both activated and hit (against a projectile).
---@param incoming_object MeteorShowerInfo|ProjectileInfo|DeliveryCannonPayloadInfo Meteor shower or projectile to defend against
---@param meteor_defences IndexMap<MeteorDefenceInfo> Table of meteor defences for the surface
---@param surface LuaSurface Surface the meteor defences are on
---@param update_incoming_data_fn function Function to update the projectile data after a defence is activated
---@param update_incoming_data_hit_fn function Function to update the projectile data after it is hit
---@param is_meteor boolean If the projectile is a meteor
---@return boolean is_successful Whether meteor defence installation activated, and for projectiles, successfully hit
function Meteor.try_global_defences(incoming_object, meteor_defences, surface, update_incoming_data_fn, update_incoming_data_hit_fn, is_meteor)
  if not meteor_defences then return false end
  for _, defence in pairs(meteor_defences) do
    if defence.last_charged and defence.charger.valid and defence.container.valid
      and (is_meteor or not is_friendly_projectile(incoming_object, defence.charger)) then
      local charger = defence.charger
      if charger.energy >= Meteor.defence_full_power * 0.99 then
        local inv = defence.container.get_inventory(defines.inventory.turret_ammo)
        if inv.get_item_count(Meteor.name_meteor_defence_ammo) > 0 then
          -- this defence is ready to fire so remove ammo and update the projectile with the fact it has been fired upon
          local take = 1
          inv.remove({name=Meteor.name_meteor_defence_ammo, count=take})
          charger.force.get_item_production_statistics(surface).on_flow(Meteor.name_meteor_defence_ammo, -take)
          charger.energy = 0
          defence.last_charged = nil
          update_incoming_data_fn(incoming_object, charger)

          -- always create the defense beam gfx regardless of hit or miss
          surface.create_entity{
            name = Meteor.name_meteor_defence_beam,
            position = Util.vectors_add(charger.position, Meteor.name_meteor_defence_beam_offset),
            target = Util.vectors_add(charger.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
          }

          -- this defence may or may not hit, if it hits calculate the result of hitting the projectile and return if necessary
          if math.random() < Meteor.defence_accuracy then
            local hit = update_incoming_data_hit_fn(incoming_object, defence)
            if hit then return true end
          end

          -- Always return true if defence fired against a meteor
          if is_meteor then return true end
        end
      else
        defence.last_charged = nil
      end
    end
  end
  return false
end

---@param defence MeteorDefenceInfo
---@return number efficiency
local function get_point_defence_efficiency(defence)
  return (defence.mode == "fast") and Meteor.point_defence_efficiency_overcharged or Meteor.point_defence_efficiency
end

--- Does this point defense have ammo and energy?
---@param defence MeteorDefenceInfo
---@return boolean is_point_defence_ready_to_fire
local function is_point_defence_ready_to_fire(defence)
  local inv = defence.container.get_inventory(defines.inventory.turret_ammo)
  local charger = defence.charger
  return inv.get_item_count(Meteor.name_meteor_point_defence_ammo) > 0
    and charger.energy * get_point_defence_efficiency(defence) >= Meteor.point_defence_fire_power
end

---Fires a given point defence at the given projectile.
---@param inv LuaInventory Meteor point defense container inventory
---@param charger LuaEntity Charger entity, _must_ be valid
---@param defence MeteorDefenceInfo Meteor point defense data
---@param incoming_object MeteorShowerInfo|ProjectileInfo|DeliveryCannonPayloadInfo Meteor shower or projectile to defend against
---@param surface LuaSurface Surface that defenses are located on
---@param update_incoming_data_hit_fn function Function to update the projectile data after it is hit
---@return boolean is_successful Whether meteor point defense activated, and for projectiles, successfully hit
function Meteor.fire_point_defence(inv, charger, defence, incoming_object, surface, update_incoming_data_hit_fn)
  -- this defence is ready to fire
  local take = 1
  inv.remove({name=Meteor.name_meteor_point_defence_ammo, count=take})
  charger.force.get_item_production_statistics(surface).on_flow(Meteor.name_meteor_point_defence_ammo, -take)
  charger.energy = charger.energy - (Meteor.point_defence_fire_power / get_point_defence_efficiency(defence))
  defence.last_charged = nil

  -- always create the defense beam gfx regardless of hit or miss
  defence.barrel = (defence.barrel or 0) % 4 + 1
  surface.create_entity{
    name = Meteor.name_meteor_point_defence_beam,
    position = Util.vectors_add(charger.position, Meteor.name_meteor_point_defence_beam_offsets[defence.barrel]),
    target = Util.vectors_add(charger.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
  }

  -- this defence may or may not hit, if it hits calculate the result of hitting the projectile
  if math.random() < Meteor.point_defence_accuracy then
    if update_incoming_data_hit_fn(incoming_object, defence) then return true end
  end
  return false
end

---Attempts to use a meteor point defense from a given table to defend against a meteor shower.
---Returns true if a meteor defence successfully activated.
---@param meteor_shower MeteorShowerInfo Meteor shower to defend against
---@param meteor_point_defences IndexMap<MeteorDefenceInfo> Table of meteor point defences for the surface
---@param surface LuaSurface Surface the meteor point defences are on
---@return boolean is_successful Whether meteor point defense activated, and for projectiles, successfully hit
function Meteor.try_point_defences_vs_meteor(meteor_shower, meteor_point_defences, surface)
  if not meteor_point_defences then return false end
  for _, defence in pairs(meteor_point_defences) do
    if defence.charger.valid and defence.container.valid then
      local charger = defence.charger
      local inv = defence.container.get_inventory(defines.inventory.turret_ammo)

      local ready = is_point_defence_ready_to_fire(defence)
      for _, meteor in pairs(meteor_shower.remaining_meteors) do
        if Util.vectors_delta_length(meteor.land_position, defence.charger.position) <= Meteor.point_defence_range * defence.container.quality.range_multiplier then
          meteor_shower.has_point_defences_in_range = true -- Mark the meteor shower as being in range of defences
          if ready then
            meteor_shower.point_defences_activated = meteor_shower.point_defences_activated + 1
            Meteor.fire_point_defence(inv, charger, defence, meteor_shower, surface, update_meteor_data_hit)
            return true -- meteor defending must always return true for completion after a shot regardless of hit or miss
          end
        end
      end
    end
  end
  return false
end

---Attempts to use a meteor point defence from a given table to defend against a projectile.
---Returns true if a meteor defence successfully activated and hit.
---@param projectile ProjectileInfo|DeliveryCannonPayloadInfo Projectile to defend against
---@param meteor_point_defences table<uint, MeteorDefenceInfo> Table of meteor point defences for the surface
---@param surface LuaSurface Surface the meteor point defences are on
---@return boolean
function Meteor.try_point_defences_vs_projectile(projectile, meteor_point_defences, surface)
  if not meteor_point_defences then return false end
  for _, defence in pairs(meteor_point_defences) do
    local charger = defence.charger
    if defence.charger.valid and defence.container.valid and not is_friendly_projectile(projectile, charger) then
      local inv = defence.container.get_inventory(defines.inventory.turret_ammo)

      if Util.vectors_delta_length(projectile.target_position, defence.charger.position) <= Meteor.point_defence_range * defence.container.quality.range_multiplier then
        while is_point_defence_ready_to_fire(defence) do
          projectile.defence_data = projectile.defence_data or {}
          projectile.defence_data[charger.force.name] = projectile.defence_data[charger.force.name]  or {defence_shots = 0, point_defence_shots = 0}
          projectile.defence_data[charger.force.name].point_defence_shots = projectile.defence_data[charger.force.name].point_defence_shots + 1
          if Meteor.fire_point_defence(inv, charger, defence, projectile, surface, update_projectile_data_hit) then
            return true -- projectile defending only returns true after a hit
          end
        end
      end
    end
  end
  return false
end

---Processes a given meteor shower, triggering defenses if appropriate.
---@param meteor_shower MeteorShowerInfo Meteor shower data
function Meteor.tick_meteor_shower(meteor_shower)
  if type(meteor_shower.remaining_meteors) ~= "table" then
    meteor_shower.valid = false
    return
  end

  if meteor_shower.skip and meteor_shower.skip > 0 then
    meteor_shower.skip = meteor_shower.skip - Meteor.tick_skip_meteor_shower
    return
  end

  if not next(meteor_shower.remaining_meteors) then
    -- No meteors left, defences won, victory message
    meteor_shower.valid = false
    Meteor.meteor_shower_alert(meteor_shower)
    return
  end

  local surface = Zone.get_make_surface(meteor_shower.zone)

  -- If zone is a planet/moon, try its orbit's MDIs first
  if Zone.is_solid(meteor_shower.zone) then
    local orbit = meteor_shower.zone.orbit
    if orbit.surface_index then
      if Meteor.try_global_defences(meteor_shower, orbit.meteor_defences, Zone.get_surface(orbit),
        update_meteor_data_global, update_meteor_data_hit, true) then return end
    end
  end

  -- Fire the zone's MDIs (regardless of zone type)
  if Meteor.try_global_defences(meteor_shower, meteor_shower.zone.meteor_defences,
        surface, update_meteor_data_global, update_meteor_data_hit, true) then return end

  -- If zone is a planet/moon orbit, try the MDIs of the surface below now
  if meteor_shower.zone.type == "orbit" and Zone.is_solid(meteor_shower.zone.parent) then
    local parent = meteor_shower.zone.parent
    if parent.surface_index then
      if Meteor.try_global_defences(meteor_shower, parent.meteor_defences, Zone.get_surface(parent),
      update_meteor_data_global, update_meteor_data_hit, true) then return end
    end
  end

  -- Finally, try the point defenses for the zone being targeted
  if Meteor.try_point_defences_vs_meteor(meteor_shower, meteor_shower.zone.meteor_point_defences, surface) then return end

  -- Show alerts for players meeting the conditions
  Meteor.meteor_shower_alert(meteor_shower)

  meteor_shower.valid = false
  Meteor.spawn_meteor_shower(meteor_shower)
end

---Processes a given projectile, allowing meteor defences to defend against it if appropriate.
---@param projectile ProjectileInfo|DeliveryCannonPayloadInfo Projectile data
---@return {[string]:MeteorDefenceShootingInfo}
function Meteor.defence_vs_projectile(projectile)
  local zone = projectile.target_zone
  projectile.health = projectile.health or 1 -- some may take multiple hits?

  local surface = Zone.get_make_surface(zone)

  -- If zone is a planet/moon, try its orbit's MDIs first
  if Zone.is_solid(zone) then
    ---@cast zone PlanetType|MoonType
    local orbit = zone.orbit
    if orbit.surface_index then
      if Meteor.try_global_defences(projectile, orbit.meteor_defences, Zone.get_surface(orbit),
        update_projectile_data_global, update_projectile_data_hit, false) then
        local defence_data = projectile.defence_data
        projectile.defence_data = nil
        return defence_data
      end
    end
  end

  -- Fire the zone's MDIs (regardless of zone type)
  if Meteor.try_global_defences(projectile, zone.meteor_defences, surface,
    update_projectile_data_global, update_projectile_data_hit, false) then
    local defence_data = projectile.defence_data
    projectile.defence_data = nil
    return defence_data
  end

  -- If zone is a planet/moon orbit, try the MDIs of the surface below now
  if zone.type == "orbit" and Zone.is_solid(zone.parent) then
    ---@cast zone OrbitType
    local parent = zone.parent
    if parent.surface_index then
      if Meteor.try_global_defences(projectile, parent.meteor_defences, Zone.get_surface(parent),
        update_projectile_data_global, update_projectile_data_hit, false) then
        local defence_data = projectile.defence_data
        projectile.defence_data = nil
        return defence_data
      end
    end
  end

  -- Finally, try the point defenses for the zone being targeted
  if Meteor.try_point_defences_vs_projectile(projectile, zone.meteor_point_defences, surface) then
    local defence_data = projectile.defence_data
    projectile.defence_data = nil
    return defence_data
  end

  -- Defence was unsuccessful
  return {}
end

--- Counts how many meteor defences are present and still ready
---@param meteor_defences? MeteorDefenceInfo[]
---@return {count: uint, count_ready: uint}
function Meteor.count_ready_global_defence(meteor_defences)
  local count = 0
  local count_ready = 0
  if not meteor_defences then return {count=count, count_ready=count_ready} end
  for _, defence in pairs(meteor_defences) do
    count = count + 1
    local charger = defence.charger
    if defence.last_charged and defence.charger.valid and defence.container.valid then
      if charger.energy >= Meteor.defence_full_power * 0.99 then
        local inv = defence.container.get_inventory(defines.inventory.turret_ammo)
        if inv.get_item_count(Meteor.name_meteor_defence_ammo) > 0 then
          count_ready = count_ready + 1
        end
      else
        defence.last_charged = nil
      end
    end
  end
  return {count = count, count_ready = count_ready}
end

--- Counts how many point meteor defences are present and still ready
---@param meteor_point_defences IndexMap<MeteorDefenceInfo>
---@return {count: uint, count_ready: uint}
function Meteor.count_ready_point_defence(meteor_point_defences)
  local count = 0
  local count_ready = 0
  if not meteor_point_defences then return {count=count, count_ready=count_ready} end
  for _, defence in pairs(meteor_point_defences) do
    count = count + 1
    if defence.charger.valid and defence.container.valid then
      if is_point_defence_ready_to_fire(defence) then
        count_ready = count_ready + 1
      end
    end
  end
  return {count = count, count_ready = count_ready}
end

---Generates a meteor shower alert and optionally prints alert to console.
---@param meteor_shower MeteorShowerInfo Meteor shower data
function Meteor.meteor_shower_alert(meteor_shower)
  local meteor_defences = 0
  local meteor_defences_ready = 0
  local meteor_defences_shot_fired = meteor_shower.defences_activated

  -- Count ready global defences
  local ready_global_defence_data = Meteor.count_ready_global_defence(meteor_shower.zone.meteor_defences)
  meteor_defences = meteor_defences + ready_global_defence_data.count
  meteor_defences_ready = meteor_defences_ready + ready_global_defence_data.count_ready
  local alternate_defence_zone = Zone.get_alternate_defence_zone(meteor_shower.zone)
  if alternate_defence_zone and Zone.get_surface(alternate_defence_zone) then
    ready_global_defence_data = Meteor.count_ready_global_defence(alternate_defence_zone.meteor_defences)
    meteor_defences = meteor_defences + ready_global_defence_data.count
    meteor_defences_ready = meteor_defences_ready + ready_global_defence_data.count_ready
  end

  -- Count ready point defences
  local ready_point_defence_data = Meteor.count_ready_point_defence(meteor_shower.zone.meteor_point_defences)
  local meteor_point_defences = ready_point_defence_data.count
  local meteor_point_defences_ready = ready_point_defence_data.count_ready
  local meteor_point_defence_shots_fired = meteor_shower.point_defences_activated

  local surface = Zone.get_make_surface(meteor_shower.zone)
  local dummy = surface.create_entity{name = mod_prefix.."dummy-explosion", position = meteor_shower.land_position}
  ---@cast dummy -?

  local message = {"space-exploration.meteor_shower_report",
    (#meteor_shower.meteors - #meteor_shower.remaining_meteors),
    #meteor_shower.meteors,
    util.gps_tag(surface.name, meteor_shower.land_position),
    meteor_defences_shot_fired,
    meteor_defences_ready,
    meteor_defences,
    meteor_point_defence_shots_fired,
    meteor_point_defences_ready,
    meteor_point_defences
  }

  local is_breakthrough =
    next(meteor_shower.remaining_meteors)
    and (meteor_defences > 0 or meteor_shower.has_point_defences_in_range)

  for _, player in pairs(game.connected_players) do
    if Zone.is_visible_to_force(meteor_shower.zone, player.force.name) then
      local player_meteor_setting = settings.get_player_settings(player)["se-print-meteor-info"].value
      local is_current_zone = player.surface_index == surface.index or (alternate_defence_zone and player.surface_index == alternate_defence_zone.surface_index)
      if player_meteor_setting == "always"
          or player_meteor_setting == "current-zone-only" and is_current_zone
          or player_meteor_setting == "breakthrough-only" and is_breakthrough
          or player_meteor_setting == "breakthrough-and-current-zone-only" and is_breakthrough and is_current_zone
      then
        player.add_custom_alert(dummy, {type = "virtual", name = "se-meteor"}, message, true)
        player.print(message, {volume_modifier = 0.5})
      end
    end
  end
end

---Creates a meteor shower in a given zone using the given parameters.
---@param zone AnyZoneType Zone data
---@param position MapPosition Position that meteor shower will target
---@param range float Radius around `position` within which meteor swarm may land
---@param force_meteor_count uint Number of meteors, capped at 100
function Meteor.begin_meteor_shower(zone, position, range, force_meteor_count)
  if not zone then return end
  local surface = Zone.get_make_surface(zone)

  if not position then position = {x=0, y=0} end
  if not range then range = Meteor.meteor_random_range end

  local meteor_count
  if force_meteor_count then
    meteor_count = force_meteor_count
    if force_meteor_count > 100 then
      game.print("Meteor shower count capped at 100, use multiple meteor showers to bypass this limit.")
    end
  else
    ---50% chance for 1, 25% chance for 2, 12.5% chance for 3, 6.25% chance for 4, etc...
    meteor_count = math.floor(math.log(1/(1-math.random()), 2))+1
  end
  meteor_count = math.min(meteor_count, 100)
  Log.debug_log("Meteor shower on "..zone.name.." with "..tostring(meteor_count).." meteors")

  local land_position
  local attempt = 0
  repeat
    attempt = attempt + 1
    land_position = {
      x = position.x + (math.random() - 0.5) * range * 2,
      y = position.y + (math.random() - 0.5) * range * 2
    }
  until(attempt > 20 or not (zone.radius and util.vector_length(land_position) > zone.radius)) -- Repeat until in-bounds

  local x_offset = Meteor.meteor_swarm_x_deviation * 2 * (math.random() - 0.5)
  local start_position = {
    x = land_position.x + x_offset,
    y = land_position.y - Meteor.meteor_swarm_altitude
  }
  local shadow_start_position = {
    x = land_position.x + Meteor.meteor_swarm_altitude + x_offset,
    y = land_position.y
  }

  local meteors = {}
  local chain_angle = math.random() * 360
  for chain = 1, meteor_count do
    local meteor = {
      id = chain,
      safe = false
    }
    if chain == 1 then
      meteor.land_position = {
        x = land_position.x,
        y = land_position.y,
      }
    else
      meteor.land_position = {
        x = land_position.x + (math.random() - 0.5) * Meteor.meteor_position_deviation,
        y = land_position.y + (math.random() - 0.5) * Meteor.meteor_position_deviation,
      }
      meteor.land_position = util.vectors_add(meteor.land_position, util.rotate_vector(chain_angle, {x = 0, y = Meteor.meteor_chain_distance * ((chain - 1) + 0.7 * math.random()) }))
    end
    table.insert(meteors, meteor)
  end

  local defences = zone.meteor_defences or {}

  local meteor_shower = {
    valid = true,
    type = "meteor-shower",
    zone = zone,
    land_position = land_position,
    start_position = start_position,
    shadow_start_position = shadow_start_position,
    meteors = meteors,
    remaining_meteors = table.deepcopy(meteors),
    defences_activated = 0,
    point_defences_activated = 0,
    has_point_defences_in_range = false,
    defences = defences,
    skip = 60
  }
  table.insert(storage.meteor_showers, meteor_shower)

  for _, player in pairs(game.connected_players) do
    if player.surface.index == surface.index then
      player.play_sound{path="se-meteor-woosh", volume=3}
    end
  end
end

-- Chunk must be generated, and if this is a solid zone, position must be in-bounds
---comment
---@param position MapPosition
---@param surface LuaSurface
---@param zone AnyZoneType
---@return boolean is_valid_position_for_meteor
local function is_valid_position_for_meteor(position, surface, zone)
  local chunk_position = util.position_to_chunk_position(position)
  return surface.is_chunk_generated(chunk_position) and not (zone.radius and util.vector_length(position) > zone.radius)
end

---Spawns the actual meteor and shadow sprites.
---@param meteor_shower MeteorShowerInfo Meteor shower data
function Meteor.spawn_meteor_shower(meteor_shower)
  local zone = meteor_shower.zone
  local surface = Zone.get_make_surface(zone)

  -- Determine what zone meteors could fall through to (only possible in orbit over a solid body)
  local zone_below = (zone.type == "orbit" and Zone.is_solid(zone.parent)) and zone.parent or nil
  local fallthrough_count = 0

  -- Condition spawn on whether starting chunk is generated or not.
  if surface.is_chunk_generated(util.position_to_chunk_position(meteor_shower.start_position)) and
    surface.is_chunk_generated(util.position_to_chunk_position(meteor_shower.shadow_start_position)) then
    -- Spawn individual meteors and their shadows after checking their landing position
    for _, meteor in pairs(meteor_shower.remaining_meteors) do
      if is_valid_position_for_meteor(meteor.land_position, surface, zone) then
        if zone_below then
          local below_tile =
            surface.get_tile(math.floor(meteor.land_position.x), math.floor(meteor.land_position.y))
          if tile_is_space(below_tile) then
            fallthrough_count = fallthrough_count + 1
          end
        end

        local variant = string.format("%02d", math.random(Meteor.meteor_variants))

        surface.create_entity{
          name = mod_prefix .. "falling-meteor-" .. variant,
          position = meteor_shower.start_position,
          target = meteor.land_position,
          force = "neutral",
          speed = Util.vectors_delta_length(meteor_shower.start_position, meteor.land_position) / (Meteor.meteor_fall_time + Meteor.meteor_chain_delay * meteor.id)
        }
        surface.create_entity{
          name = mod_prefix .. "shadow-meteor-" .. variant,
          position = meteor_shower.shadow_start_position,
          target = meteor.land_position,
          force = "neutral",
          speed = Util.vectors_delta_length(meteor_shower.shadow_start_position, meteor.land_position) / (Meteor.meteor_fall_time + Meteor.meteor_chain_delay * meteor.id)
        }
      elseif zone_below then
        fallthrough_count = fallthrough_count + 1
      end
    end
  elseif zone_below then
    fallthrough_count = #meteor_shower.remaining_meteors
  end


  -- if any meteors fell through, and the zone they would fall through to is generated, make a
  -- meteor shower with the remaining meteors on that surface
  if zone_below and storage.meteor_zones[zone_below.index] and fallthrough_count > 0 then
    -- Schedule meteor shower to be executed at the nearest opportunity, at most, 30s from now
    Meteor.schedule_meteor_shower{
      zone = zone_below,
      tick = game.tick,
      count = fallthrough_count,
      is_direct = true
    }
  end
end

---Checks a given meteor global/point defense, creating/destroying charging shapes and text if
---appropriate.
---@param defence MeteorDefenceInfo Defense data
---@param tick uint Current tick
function Meteor.on_tick_any_defence(defence, tick)
  local full_power = (defence.type == "global") and
    Meteor.defence_full_power * 0.99 or Meteor.point_defence_full_power * 0.99

  if defence.container.valid and defence.charger.valid then
    local is_connected_to_electric_network = defence.charger.is_connected_to_electric_network()

    if is_connected_to_electric_network and defence.charger.energy < full_power then
      if not defence.charging_shape then
        defence.charging_shape = rendering.draw_sprite{
          sprite="utility/recharge_icon",
          surface=defence.container.surface,
          target=defence.container,
          x_scale=0.5,
          y_scale=0.5,
        }
      end
      local eff = get_point_defence_efficiency(defence)
      local text_content = (defence.type == "global") and
        string.format("%.2f", 100 * defence.charger.energy / full_power) .. "%" or
        string.format("%.2f", 100 * defence.charger.energy * eff / Meteor.point_defence_fire_power) .. "% (" .. math.floor(defence.charger.energy * eff / Meteor.point_defence_fire_power) .. "/4)"
      if defence.charging_text and defence.charging_text.valid then
        defence.charging_text.text = text_content
      else
        defence.charging_text = rendering.draw_text{
          text=text_content,
          surface=defence.container.surface,
          target={entity=defence.container,offset={x=0, y=1}},
          color={r=255, g=255, b=255, a=255},
          alignment="center",
        }
      end
    else
      -- Mark this defense structure as fully charged
      if is_connected_to_electric_network then
        defence.last_charged = tick
      end

      -- Destroy renders, since defence is either not connected to electric network or fully charged
      if defence.charging_shape and defence.charging_shape.valid then
        defence.charging_shape.destroy()
        defence.charging_shape = nil
      end
      if defence.charging_text and defence.charging_text.valid then
        defence.charging_text.destroy()
        defence.charging_text = nil
      end
    end
    if defence.container.health <= 0 then defence.container.active = true end
  elseif defence.container.valid then
    -- Something is wrong; the charger is invalid
    if defence.type == "global" then
      -- Search for an _orphaned_ charger at the container's position
      local charger = defence.container.surface.find_entity(Meteor.name_meteor_defence_charger, defence.container.position)
      if charger and not Meteor.any_defence_from_entity(charger) then defence.charger = charger end

      -- Create a new charger if no orphaned charger was found
      if not defence.charger.valid then
        defence.charger = defence.container.surface.create_entity{
          name=Meteor.name_meteor_defence_charger,
          position=defence.container.position,
          direction=defence.container.direction,
          force=defence.container.force
        }
        defence.charger.destructible = false
        defence.charger.energy = 0
      end
    elseif defence.type == "point" then
      -- Search for a matching _orphaned_ charger at the container's position
      local charger = defence.container.surface.find_entity(
        (defence.mode == "fast") and Meteor.name_meteor_point_defence_charger_overcharged
        or Meteor.name_meteor_point_defence_charger, defence.container.position)
      if charger and not Meteor.any_defence_from_entity(charger) then defence.charger = charger end

      -- Create a new charger if no orphaned charger was found
      if not defence.charger.valid then
        defence.charger = defence.container.surface.create_entity{
          name=(defence.mode == "fast")
            and Meteor.name_meteor_point_defence_charger_overcharged
            or Meteor.name_meteor_point_defence_charger,
          position=defence.container.position,
          direction=defence.container.direction,
          force=defence.container.force
        }
        defence.charger.destructible = false
        defence.charger.energy = 0

        -- Have charger render on top of container
        defence.container.teleport(defence.container.position)
      end
    end
  else
    -- The container is invalid; destroy the charger if it's valid and delete the defence table
    if defence.charger.valid then defence.charger.destroy() end
    Meteor.remove_any_defence_references(defence)
  end
end

---Credits a given defence container (ammo-turret) and its force for killing given entity.
---@param container LuaEntity Defence container entity, _must_ be valid
---@param killed_entity_name string Name of entity killed
function Meteor.credit_kill(container, killed_entity_name)
    --Credit the force with the kill
    --All of the icons look the same so there's no reason in spltting the stastics up.
    container.force.get_kill_count_statistics(container.surface).on_flow(killed_entity_name, 1)
    container.kills = container.kills + 1
end

---Handles periodic checks on meteor defense entities, and steps through in-progress meteor showers.
---@param event EventData.on_tick Event data
function Meteor.on_tick(event)
  -- Process meteor showers like tick tasks
  if event.tick % Meteor.tick_skip_meteor_shower == 0 then
    for i = #storage.meteor_showers, 1, -1 do
      if storage.meteor_showers[i].valid then
        Meteor.tick_meteor_shower(storage.meteor_showers[i])
      else
        table.remove(storage.meteor_showers, i)
      end
    end
  end

  local tick_skip = Meteor.tick_skip_defence
  local tick_skip_charged = Meteor.tick_skip_defence_charged

  local meteor_defences = storage.meteor_defences
  local meteor_point_defences = storage.meteor_point_defences

  -- Iterate over meteor defences in a staggered fashion
  for i = (event.tick % tick_skip) + 1, #meteor_defences, tick_skip do
    local defence = meteor_defences[i]
    if defence then
      if event.tick - (defence.last_charged or -tick_skip_charged) > tick_skip_charged then
        Meteor.on_tick_any_defence(defence, event.tick)
      end
    end
  end

  -- Iterate over meteor point defences in a staggered fashion
  for i = (event.tick % tick_skip) + 1, #meteor_point_defences, tick_skip do
    local point_defence = meteor_point_defences[i]
    if point_defence then
      if event.tick - (point_defence.last_charged or -tick_skip_charged) > tick_skip_charged then
        Meteor.on_tick_any_defence(point_defence, event.tick)
      end
    end
  end
end
Event.addListener(defines.events.on_tick, Meteor.on_tick)

---Returns a reasonable position to place a meteor shower in this zone, if any.
---@param zone AnyZoneType Zone to find a position for
---@return MapPosition? position Position for a shower in that zone, if any
function Meteor.choose_shower_position(zone)
  local surface = Zone.get_surface(zone)
  if not surface then return end

  local position
  local entities = {}

  -- Get positions of connected player characters on this surface
  for _, player in pairs(game.connected_players) do
    local character = player_get_character(player)
    if character and character.surface.index == surface.index then
      table.insert(entities, character)
    end
  end

  -- Use one of those positions if they exist
  position = next(entities) and entities[math.random(#entities)].position or nil

  -- Get position of a random chunk from zone.inhabited_chunks
  if not position and zone.inhabited_chunks and next(zone.inhabited_chunks) then
    local keys = {}
    for key, _ in pairs(zone.inhabited_chunks) do table.insert(keys, key) end
    local random_key = keys[math.random(#keys)]
    local chunk_pos = zone.inhabited_chunks[random_key]
    position = {x=chunk_pos.x*32, y=chunk_pos.y*32}
  end

  return position
end

---Schedules a meteor shower for the given zones.
---@param data ScheduledMeteorShower Scheduling details of meteor shower
function Meteor.schedule_meteor_shower(data)
  data.tick = data.tick or game.tick

  local meteor_schedule = storage.meteor_schedule
  local schedule_index = math.floor(data.tick / 1800) * 1800
  local zone_index = data.zone.index

  -- Create a table for this tick range, if one doesn't exist
  if not meteor_schedule[schedule_index] then
    meteor_schedule[schedule_index] = {}
  end

  -- Create a table for this zone, if one doesn't exist
  if not meteor_schedule[schedule_index][zone_index] then
    meteor_schedule[schedule_index][zone_index] = {}
  end

  -- Add meteor shower to the schedule for this zone
  table.insert(meteor_schedule[schedule_index][zone_index], data)
end

---Runs every 30 seconds, starting up scheduled meteor showers, and scheduling new ones.
---@param event NthTickEventData Event data
function Meteor.on_nth_tick_1800(event)
  local schedule_index = (math.floor(event.tick / 1800) * 1800) - 1800
  local meteor_schedule = storage.meteor_schedule

  -- Iterate over each meteor event scheduled for the tick range that immediately precedes this one
  for _, zone_meteor_events in pairs(meteor_schedule[schedule_index] or {}) do
    for _, meteor_event in pairs(zone_meteor_events) do
      local target_zone = meteor_event.zone

      -- If a meteor shower was scheduled for a planet whose orbit is a meteor zone, target the orbit
      if Zone.is_solid(target_zone)
      and storage.meteor_zones[target_zone.orbit.index]
      and not meteor_event.is_direct then
        ---@cast target_zone PlanetType|MoonType
        target_zone = target_zone.orbit
      else
        target_zone = target_zone
      end

      local position = meteor_event.position or Meteor.choose_shower_position(target_zone)
      if position then
        Meteor.begin_meteor_shower(target_zone, position, meteor_event.range, meteor_event.count)
      else
        storage.meteor_zones[target_zone.index] = nil
      end
    end
  end

  -- Remove tick range entry from the schedule
  storage.meteor_schedule[schedule_index] = nil

  -- Cache settings value later on, if needed
  local meteor_interval

  for _, candidate in pairs(storage.meteor_zones) do
    local zone = candidate

    -- Always schedule for the parent planet, if applicable
    if candidate.type == "orbit" and Zone.is_solid(candidate.parent) then
      ---@cast candidate OrbitType
      zone = candidate.parent
    end

    if event.tick > (zone.next_meteor_shower or 3600) then
      -- Determine _when_ the next natural meteor shower for this zone should be
      local star = Zone.get_star_from_child(zone)
      local s_gravity = 0 -- 0 in deep space, 1 at roughly 1/3 out from the star
      if star then
        s_gravity = math.min(1, (Zone.get_star_gravity_well(zone) / Zone.get_star_gravity_well(star)) * 1.5)
      end
      local m_multiplier = 1 + (1 - s_gravity) * 3 -- outer space can be 4x longer between strikes
      meteor_interval = meteor_interval or settings.global["se-meteor-interval"].value
      zone.next_meteor_shower =
        math.floor(event.tick + 60 * 60 + m_multiplier * math.random() * 60 * 60 * meteor_interval)

      -- Add a meteor shower to the schedule
      Meteor.schedule_meteor_shower{zone=zone, tick=zone.next_meteor_shower}
    end
  end
end
Event.addListener("on_nth_tick_1800", Meteor.on_nth_tick_1800) -- 30s

---Handles the player modifying a meteor-related setting.
---@param event EventData.on_runtime_mod_setting_changed Event data
function Meteor.on_runtime_mod_setting_changed(event)
  if event.setting == Meteor.name_setting_meteor_interval then
    for _, zone in pairs(storage.meteor_zones) do
      if (zone.next_meteor_shower or 0) > event.tick + 60 * 60 * settings.global[Meteor.name_setting_meteor_interval].value then
        local star = Zone.get_star_from_child(zone)
        local s_gravity = 0 -- 0 in deep space, 1 at roughly 1/3 out from the star
        if star then s_gravity = math.min( 1, (Zone.get_star_gravity_well(zone) / Zone.get_star_gravity_well(star)) * 1.5) end
        local m_multiplier = 1 + (1 - s_gravity) * 3 -- outer space can be 4x longer between strikes
        zone.next_meteor_shower = event.tick + 30*60 + m_multiplier * math.random() * 60 * 60 * settings.global[Meteor.name_setting_meteor_interval].value
      end
    end
  end
end
Event.addListener(defines.events.on_runtime_mod_setting_changed, Meteor.on_runtime_mod_setting_changed)

---Returns a tileset that is suitable for a meteor to destroy in a space zone.
---@param surface LuaSurface Surface to get tiles from
---@param position MapPosition Position to search
---@param variant uint Can be 1–5
---@return Tile[] tiles
function Meteor.get_tiles_to_destroy(surface, position, variant)
  local tiles = {}
  local row_start, row_stop, row_increment
  local col_start, col_stop, col_increment
  local chance = math.random()
  local offset = {}

  -- Cache globals
  local selected = Meteor.meteor_hole_variants[variant]
  local matrix = selected.matrix
  local tile_plate = sp_tile_plate
  local tile_scaffold = sp_tile_scaffold
  local table_insert = table.insert

  if math.random() < 0.5 then
    row_start = 1
    row_stop = #matrix
    row_increment = 1
  else
    row_start = #matrix
    row_stop = 1
    row_increment = -1
  end

  if math.random() < 0.5 then
    col_start = 1
    col_stop = #matrix[1]
    col_increment = 1
  else
    col_start = #matrix[1]
    col_stop = 1
    col_increment = -1
  end

  if chance < 0.5 then
    offset.a = -math.random(1, selected.offset.x)
    offset.b = -math.random(1, selected.offset.y)
  else
    offset.a = -math.random(1, selected.offset.y)
    offset.b = -math.random(1, selected.offset.x)
  end

  local y = 1
  for row_num = row_start, row_stop, row_increment do
    local x = 1
    for col_num = col_start, col_stop, col_increment do
      local a, b
      if chance then
        a, b = row_num, col_num
      else
        a, b = col_num, row_num
      end
      if matrix[a][b] == 1 then
        local candidate_pos = {x=position.x + x + offset.b, y=position.y + y + offset.a}
        local current_tile = surface.get_tile(candidate_pos).name
        local hidden_tile = surface.get_hidden_tile(candidate_pos)

        if current_tile == tile_plate then
          table_insert(tiles, {name=tile_scaffold, position=candidate_pos})
        elseif current_tile == tile_scaffold and hidden_tile then
          table_insert(tiles, {name=hidden_tile, position=candidate_pos})
        end
      end
      x = x + 1
    end
    y = y + 1
  end

  return tiles
end

---@type table<string, string>? Cache of meteor names to their normal names
local meteor_names

---@param event EventData.on_trigger_created_entity
local function on_trigger_created_entity(event)
  local trigger_entity = event.entity
  if not (trigger_entity and trigger_entity.valid and trigger_entity.type == "explosion") then return end

  -- Filter out non-meteors
  if not meteor_names then
    meteor_names = { }
    for _, prototype in pairs(prototypes.entity) do
      if prototype.type == "explosion" then
      local matched_name = string.match(prototype.name, "meteor[-]%d%d")
        if matched_name then
          meteor_names[prototype.name] = matched_name
        end
      end
    end
  end
  local meteor_name = meteor_names[trigger_entity.name]
  if not meteor_name then return end

  local surface = trigger_entity.surface
  local position = trigger_entity.position
  local tile = surface.get_tile(position)

  -- Do nothing if the meteor hit empty space or somewhere the player can't walk
  if tile_is_space(tile) or tile.collides_with("player") then return end

  -- Create an explosion for some visuals
  surface.create_entity{name=mod_prefix .. "meteor-explosion", position=position}

  -- If in space, destroy space platform if no entities are on top
  local zone = Zone.from_surface(surface)
  if zone and Zone.is_space(zone) then
    ---@cast zone -PlanetType, -MoonType
    local tileset = Meteor.get_tiles_to_destroy(surface, position, math.random(5))
    surface.set_tiles(tileset, true, "abort_on_collision")

    -- Update tile, depending on whether it changed
    tile = surface.get_tile(position)
  end

  -- Decide whether to spawn biter meteors or meteor fragments
  local entity_to_create = "se-static-" .. meteor_name
  local force_name = "neutral"
  if zone and Zone.is_biter_meteors_hazard(zone) then
    force_name = "enemy"

    local r = math.random()
    if r < 0.1 then
      entity_to_create = "behemoth-worm-turret"
    elseif r < 0.5 then
      entity_to_create = "spitter-spawner"
    else
      entity_to_create = "biter-spawner"
    end
  end

  -- Create the entity safely, without destroying any ghosts
  local entity = surface.create_entity{
    name = entity_to_create,
    position = position,
    force = force_name,
    preserve_ghosts_and_corpses = true, -- This little flag saves us from such a crazy hack!
  }

  -- Maybe mark it for construction
  if entity then

    -- See if there's some entities or ghosts colliding with the created entity
    local colliding_entity --[[@as LuaEntity?]]
    for _, other_entity in pairs(surface.find_entities_filtered{area=entity.bounding_box}) do
        if not SystemForces.is_system_force(other_entity.force.name) then -- Also filters out created entity
          colliding_entity = other_entity
          break
        end
    end

    -- Always mark for deconstruction if there's a colliding entity or
    -- if inside a construction network
    if colliding_entity then
      entity.order_deconstruction(colliding_entity.force)
    else
      Util.conditional_mark_for_deconstruction({entity}, surface, position)
    end
  end
end
Event.addListener(defines.events.on_trigger_created_entity, on_trigger_created_entity)

---Sets the charging mode of a given MeteorDefenceInfo to the given mode. Does nothing if not a
---point-defence type. Returns true if mode was modified.
---@param defence MeteorDefenceInfo Meteor defense data, internal entities _must_ be valid
---@param mode string Cane be "normal" or "fast"
---@return boolean is_set
function Meteor.set_defence_charging_mode(defence, mode)
  if defence.type ~= "point" then return false end
  if defence.mode == mode then return false end

  if defence.charging_text and defence.charging_text.valid then
    defence.charging_text.destroy()
    defence.charging_text = nil
  end
  if defence.charging_shape and defence.charging_shape.valid then
    defence.charging_shape.destroy()
    defence.charging_shape = nil
  end

  local charger_name = (mode == "fast") and Meteor.name_meteor_point_defence_charger_overcharged
    or Meteor.name_meteor_point_defence_charger
  local energy_transfer = math.min(defence.charger.energy, Meteor.point_defence_fire_power*2)

  defence.charger.destroy()
  defence.charger = defence.container.surface.create_entity{
    name=charger_name,
    position=defence.container.position,
    direction=defence.container.direction,
    force=defence.container.force,
    create_build_effect_smoke=false
  }
  defence.charger.destructible = false
  defence.charger.energy = energy_transfer

  defence.mode = mode
  defence.last_charged = nil

  -- Have charger render on top of container
  defence.container.teleport(defence.container.position)

  return true
end

---Handles the player clicking the mode toggle hotkey over a meteor point defense.
---@param event EventData.CustomInputEvent Event data
function Meteor.on_mode_toggle(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?

  local container = player.selected
  if not container or container.name ~= Meteor.name_meteor_point_defence_container then return end

  if player.force ~= container.force then return end

  local defence = Meteor.any_defence_from_entity(container)
  if not defence then return end

  if defence.charger.valid then
    if defence.mode == "normal" then
      Meteor.set_defence_charging_mode(defence, "fast")
      container.surface.play_sound{path="utility/build_blueprint_large", position=container.position}
      player.create_local_flying_text{
        text={"space-exploration.meteor-point-defence-charge-mode-fast"},
        position=container.position,
        color={255, 165, 0}
      }
    else
      Meteor.set_defence_charging_mode(defence, "normal")
      container.surface.play_sound{path="utility/build_blueprint_medium", position=container.position}
      player.create_local_flying_text{
        text={"space-exploration.meteor-point-defence-charge-mode-normal"},
        position=container.position
      }
    end
  else
    player.print("No " .. Meteor.name_meteor_point_defence_charger .. " found")
  end
end
Event.addListener(mod_prefix .. 'mode-toggle', Meteor.on_mode_toggle)

---@param defence MeteorDefenceInfo?
---@return Tags? tags
function Meteor.serialize_from_struct(defence)
  if defence and defence.mode then return {mode=defence.mode} end
end

---Generates tags from a given meteor defence entity. Only relevant for point defences.
---@param entity LuaEntity Container entity, _must_ be valid
---@return Tags? tags
function Meteor.serialize(entity)
  return Meteor.serialize_from_struct(Meteor.any_defence_from_entity(entity))
end

---Uses given tags to modify the given defence container entity to match.
---@param entity LuaEntity Any defence container, _must_ be valid
---@param tags Tags Tags, expected to contain `mode` property
function Meteor.deserialize(entity, tags)
  local defence = Meteor.any_defence_from_entity(entity)
  if defence then Meteor.set_defence_charging_mode(defence, tags.mode) end
end

---Handles a player copying entity settings from one point defence to another, or from a meteor
---defence to a requester/buffer chest.
---@param event EventData.on_entity_settings_pasted Event data
function Meteor.on_entity_settings_pasted(event)
  -- Set requests on requester/buffer chests
  if event.destination.type == "logistic-container" then
    local source_name = event.source.name

    if source_name == Meteor.name_meteor_point_defence_container then
      local logistic_mode = event.destination.prototype.logistic_mode
      if logistic_mode == "requester" or logistic_mode == "buffer" then
        util.set_logistic_request(event.destination, {value = Meteor.name_meteor_point_defence_ammo, min=5, max=5})
      end
    elseif source_name == Meteor.name_meteor_defence_container then
      local logistic_mode = event.destination.prototype.logistic_mode
      if logistic_mode == "requester" or logistic_mode == "buffer" then
        util.set_logistic_request(event.destination, {value = Meteor.name_meteor_defence_ammo, min=5, max=5})
      end
    end

    return
  end

  -- Handle copy-paste from one point defence to another
  util.settings_pasted(event,
    Meteor.name_meteor_point_defence_container,
    Meteor.serialize,
    Meteor.deserialize,
    function (entity, player_index)
      local player = game.get_player(player_index)
      local defence = Meteor.any_defence_from_entity(entity)

      if defence.mode == "normal" then
        player.create_local_flying_text{
          text={"space-exploration.meteor-point-defence-charge-mode-normal"},
          position=entity.position
        }
      else
        player.create_local_flying_text{
          text={"space-exploration.meteor-point-defence-charge-mode-fast"},
          position=entity.position,
          color={255, 165, 0}
        }
      end
    end
  )
end
Event.addListener(defines.events.on_entity_settings_pasted, Meteor.on_entity_settings_pasted)

---Handles the player making a blueprint containing a meteor point defence.
---@param event EventData.on_player_setup_blueprint Event data
function Meteor.on_player_setup_blueprint(event)
  util.setup_blueprint(event, Meteor.name_meteor_point_defence_container, Meteor.serialize)
end
Event.addListener(defines.events.on_player_setup_blueprint, Meteor.on_player_setup_blueprint)

---Removes zone associated with deleted surface (if any) from `storage.meteor_zones`.
---@param event EventData.on_pre_surface_deleted Event data
function Meteor.on_pre_surface_deleted(event)
  local zone = Zone.from_surface_index(event.surface_index)

  -- Delete zone from storage.meteor_zones table
  if zone and storage.meteor_zones[zone.index] then
    storage.meteor_zones[zone.index] = nil
  end
end
Event.addListener(defines.events.on_pre_surface_deleted, Meteor.on_pre_surface_deleted)

---Creates empty global arrays for Meteor defenses and point defenses.
function Meteor.on_init()
  storage.meteor_schedule = {}
  storage.meteor_defences = {}
  storage.meteor_point_defences = {}
  storage.meteor_showers = {}
end
Event.addListener("on_init", Meteor.on_init, true)

return Meteor
