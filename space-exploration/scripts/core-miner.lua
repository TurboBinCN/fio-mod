local CoreMiner = {}

--[[
Calculate core miner seam positions based on the zone seed.
Place the seam when the chunk is generated.
The number of seans scales with distance not area, so density decreases away from the center.
]]

-- constants
CoreMiner.name_core_miner_drill = mod_prefix.."core-miner-drill"
CoreMiner.name_core_seam_sealed_suffix = "-sealed"
CoreMiner.name_core_seam_fissure = mod_prefix.."core-seam-fissure"
CoreMiner.name_core_seam_smoke_generator = mod_prefix.."core-seam-smoke-generator"
CoreMiner.resource_normal = 1000000
CoreMiner.resource_category = mod_prefix.."core-mining"

--[[
Core seam resource saver.
Resoruce set should save ID and zone index, then position can be retained.
Only restore the resource if the chunk exists.
]]

---Iterates through a zone's core_mining table verifying each entity.
---If an entity is invalid, destroys associated entities and removes entry
---from storage and zone `core_mining` tables.
---@param zone PlanetType|MoonType Zone table, assumed to have a `core_mining` element
function CoreMiner.validate_core_mining_table(zone)
  for key, entry in pairs(zone.core_mining) do
    if not (entry.drill and entry.drill.valid and entry.resource and entry.resource.valid) then
      Log.debug("Remove invalid core mining entry " .. serpent.block(entry))

      local miner = entry.drill
      local resource_index

      if miner and miner.valid then
        local resource = miner.surface.find_entity(zone.fragment_name, miner.position)

        if resource then
          resource_index = CoreMiner.get_resource_index(zone, resource.position)
          if not resource_index then
            resource.destroy()
          end
        end

        if not resource_index then
          cancel_entity_creation(miner, nil, "Invalid Resource", nil)
        else
          ---@cast resource LuaEntity
          entry.drill_unit_number = miner.unit_number
          entry.resource = resource
          entry.resource_index = resource_index
          entry.position = resource.position
          entry.zone_index = zone.index
          entry.surface_index = miner.surface.index
          entry.force_name = miner.force.name
        end
      end

      if not resource_index then
        zone.core_mining[key] = nil
        storage.core_mining[key] = nil
      end
    end
  end
end

---Iterates through a zone's core_seam_resources table verifying each entity.
---If an entity is invalid, destroys associated entities and removes entry
---from zone `core_seam_resources` tables.
---@param zone PlanetType|MoonType Zone table, assumed to have a `core_seam_positions` element
function CoreMiner.validate_core_seam_resources_table(zone)
  local surface = Zone.get_surface(zone)
  if not surface then return end

  zone.core_seam_resources = zone.core_seam_resources or {}
  CoreMiner.default_fragment_name(zone)

  for resource_index, position in pairs(zone.core_seam_positions) do
    local chunk_position = util.position_to_chunk_position(position)

    if surface.is_chunk_generated(chunk_position) then
      local resource = surface.find_entity(zone.fragment_name, position)
        or surface.find_entity(zone.fragment_name .. CoreMiner.name_core_seam_sealed_suffix, position)
      local fissure = surface.find_entity(CoreMiner.name_core_seam_fissure, position)

      -- Need to search a small area for the smoke generator since it has no bounding box and may
      -- otherwise get missed by `find_entity` using `position` alone.
      local smoke_generator = surface.find_entities_filtered{name=CoreMiner.name_core_seam_smoke_generator, position=position, radius=3}[1]

      -- If the three components of a core seam couldn't be found, destroy them all and recreate seam
      if not (resource and fissure and smoke_generator) and
        not (resource and smoke_generator and string.ends(resource.name, CoreMiner.name_core_seam_sealed_suffix)) then
        CoreMiner.remove_seam{resource_index=resource_index, zone_index=zone.index,
          resource=resource, fissure=fissure, smoke_generator=smoke_generator}

        Log.debug("CoreMiner.validate_core_seam_resources_table: [" .. zone.name ..
          "] Recreating core seam " .. resource_index .. " at"  .. " {" .. position.x .. ", " .. position.y .. "}")

        CoreMiner.create_seam(zone, resource_index)
      elseif not zone.core_seam_resources[resource_index] then
        ---@type CoreSeamInfo
        local resource_set = {
          resource_index = resource_index,
          zone_index = zone.index,
          resource = resource,
          fissure = fissure,
          smoke_generator = smoke_generator,
        }

        Log.debug("CoreMiner.validate_core_seam_resources_table: [" .. zone.name ..
          "] Core seam " .. resource_index .. " added to zone.core_seam_resources")

        zone.core_seam_resources[resource_index] = resource_set
        CoreMiner.register_seam_fissure(resource_set)
        CoreMiner.register_seam_resource(resource_set)
      end
    end
  end
end

---Registers seam fissures because cliff explosives don't trigger on_entity_died.
---@param resource_set CoreSeamInfo Core seam table
function CoreMiner.register_seam_fissure(resource_set)
  if not resource_set.fissure or not resource_set.fissure.valid then return end

  local registration_number = script.register_on_object_destroyed(resource_set.fissure)

  resource_set.fissure_registration_number = registration_number

  storage.core_seams_by_registration_number[registration_number] = resource_set
end

---Registers the resource entity of a core seam; needed in case of chunk deletion.
---@param resource_set CoreSeamInfo Core seam table, assumed to have a valid `resource` reference
function CoreMiner.register_seam_resource(resource_set)
  if not resource_set.resource or not resource_set.resource.valid then return end

  local registration_number = script.register_on_object_destroyed(resource_set.resource)

  resource_set.resource_registration_number = registration_number

  storage.core_seams_by_registration_number[registration_number] = resource_set
end

---Sets the yield of core-fragment resources based on zone properties.
---Updates `resource.entity` values if needed.
---@param zone PlanetType|MoonType Zone table
---@param silent? boolean Set to true to suppress flying text creation
function CoreMiner.equalise(zone, silent)
  local surface = Zone.get_surface(zone)
  if not (zone and surface) then return end
  CoreMiner.default_fragment_name(zone)

  local new_amount, efficiency, mined_resources = CoreMiner.get_resource_data(zone)

  if zone.core_seam_resources then
    for _, resource_set in pairs(zone.core_seam_resources) do
      local resource =  resource_set.resource
      if resource.valid then
        resource.amount = new_amount
        if not silent then
          rendering.draw_text{
            text = string.format("%.2f", efficiency * 100).."% effective",
            surface = resource.surface,
            target = resource,
            color = {1,1,1},
            alignment = "center",
            time_to_live = 80,
          }
        end
      end
    end
  end
end

---Calculates the appropriate yield of core-fragment resources based on zone properties.
---@param zone PlanetType|MoonType Zone table
function CoreMiner.get_resource_data(zone)
  zone.core_mining = zone.core_mining or {}
  CoreMiner.validate_core_mining_table(zone)

  -- Gather resource entities
  local mined_resources = {}
  for _, entry in pairs(zone.core_mining) do
    table.insert(mined_resources, entry.resource)
  end

  local zone_efficiency = (zone.radius + 5000) / 5000 -- 1x to 3x
  local n_mined_resources = math.max(1, table_size(mined_resources))
  local efficiency = n_mined_resources ^ 0.5 / n_mined_resources
  local new_amount = CoreMiner.resource_normal * zone_efficiency * efficiency
  return new_amount, efficiency, mined_resources
end

---Sets the yield of core-fragment resources based on zone properties for all zones.
---@param silent? boolean Set to true to suppress flying text creation
function CoreMiner.equalise_all(silent)
  for _, zone in pairs(storage.zone_index) do
    -- only zones with generated surfaces and zones that are solid can possibly have
    -- core-fragment resources
    if zone.surface_index and Zone.is_solid(zone) then
      ---@cast zone PlanetType|MoonType
      CoreMiner.equalise(zone, silent)
    end
  end
end

---Validates the placement of the core miner and saves a reference to zone and
---storage `core_mining` tables.
---@param event EntityCreationEvent|{entity:LuaEntity} Event data
function CoreMiner.on_entity_created(event)
  ---@type LuaEntity
  local entity = event.entity
  if not entity.valid then return end

  local entity_name = entity.name
  if entity_name ~= CoreMiner.name_core_miner_drill then return end

  local zone = Zone.from_surface(entity.surface)
  if zone and Zone.is_solid(zone) then
    ---@cast zone PlanetType|MoonType
    CoreMiner.default_fragment_name(zone)
    if not zone.fragment_name then
      game.print("[color=red]Error: This surface is missing a core fragment setting. Please report the issue.[/color]")
      cancel_entity_creation(entity, event.player_index, "Error", event)
      return
    else
      local surface = entity.surface
      local resource_index = CoreMiner.get_resource_index(zone, entity.position)

      if not resource_index then
        game.print("[color=red]Error, core seam was invalid.[/color]")
        cancel_entity_creation(entity, event.player_index, "Error", event)
        return
      end

      local resource_set = zone.core_seam_resources[resource_index]
      if not resource_set then
        -- the seam was invalid
        CoreMiner.create_seam(zone, resource_index)
        resource_set = zone.core_seam_resources[resource_index]
        if not resource_set then
          game.print("[color=red]Error in core seam configuration. Please report the issue.[/color]")
          cancel_entity_creation(entity, event.player_index, "Error", event)
          return
        end
      end
      local valid_resource = resource_set.resource

      if not valid_resource then
        cancel_entity_creation(entity, event.player_index, "No valid resource", event)
        return
      end

      if valid_resource.name ~= zone.fragment_name then
        -- replace the "sealed" version with the open one.
        CoreMiner.destroy_resource(resource_set)
        valid_resource = surface.create_entity{
          name = zone.fragment_name,
          position = zone.core_seam_positions[resource_index],
          amount = 1 -- non-zero, gets updated at equalise
        }
        ---@cast valid_resource -?
        resource_set.resource = valid_resource
        entity.update_connections()
        CoreMiner.register_seam_resource(resource_set)
        if not (resource_set.smoke_generator and resource_set.smoke_generator.valid) then
          resource_set.smoke_generator = surface.create_entity{
            name = CoreMiner.name_core_seam_smoke_generator,
            position = zone.core_seam_positions[resource_index],
            force = "neutral"
          }
        end
      end

      if not (resource_set.fissure and resource_set.fissure.valid) then
        local fissure = entity.surface.create_entity{
          name = CoreMiner.name_core_seam_fissure,
          position = zone.core_seam_positions[resource_index]
        }
        ---@cast fissure -?
        resource_set.fissure = fissure
        CoreMiner.register_seam_fissure(resource_set)
      end
      resource_set.fissure.destructible = false -- Can no longer be targeted by cliff explosives

      ---@type CoreMiningInfo
      local record = {
        drill = entity,
        drill_unit_number = entity.unit_number,
        resource = valid_resource,
        resource_index = resource_index,
        position = entity.position,
        zone_index = zone.index,
        surface_index = surface.index,
        force_name = entity.force.name
      }


      storage.core_mining[entity.unit_number] = record

      zone.core_mining = zone.core_mining or {}
      zone.core_mining[entity.unit_number] = record

      -- recompute resource amounts based on the new number of core miners
      CoreMiner.equalise(zone)
    end
  else
    ---@cast zone -PlanetType, -MoonType
    cancel_entity_creation(entity, event.player_index, {"space-exploration.construction-denied-solid-only"}, event)
    return
  end
end
Event.addOnEntityCreatedListeners(CoreMiner.on_entity_created)

---Searches for the given entity `unit_number` in the `storage.core_mining` table and returns
---the index if a match is found.
---@param unit_number uint|nil Entity `unit_number` to search for
---@return uint|nil
function CoreMiner.get_core_mining_entities_index(unit_number)
  if not unit_number then Log.debug("CoreMiner.get_core_mining_entities_index: invalid unit_number: nil") return end
  for index, entry in pairs(storage.core_mining) do
    if entry.miner_unit_number == unit_number or
      entry.drill_unit_number == unit_number then
      return index
    end
  end
end

---Removes the core miner from the zone and storage `core_mining` tables.
---@param event EntityRemovalEvent Event data
function CoreMiner.on_entity_removed(event)
  local entity = event.entity
  if not (entity and entity.valid and entity.name == CoreMiner.name_core_miner_drill) then return end

  local index = CoreMiner.get_core_mining_entities_index(entity.unit_number)

  -- exit if no match in core miner list
  if not index then return end

  local entry = storage.core_mining[index]
  local zone = storage.zone_index[entry.zone_index]
  local surface = game.get_surface(entry.surface_index)

  zone.core_mining[index] = nil
  storage.core_mining[index] = nil

  local seam_fissure = surface.find_entity(CoreMiner.name_core_seam_fissure, entry.position)
  if not seam_fissure then
    -- Something is wrong here
    CoreMiner.validate_core_seam_resources_table(zone)
  else
    seam_fissure.destructible = true -- Can be targeted by explosives again
  end

  -- recompute resource amounts based on the new number of core miners
  CoreMiner.equalise(zone)
end
Event.addOnEntityRemovedListeners(CoreMiner.on_entity_removed)

---Replaces destroyed seam fissures with sealed seams.
---@param event EventData.on_object_destroyed Event data
function CoreMiner.on_object_destroyed(event)
  local registration_number = event.registration_number

  local resource_set = storage.core_seams_by_registration_number[registration_number]
  if not resource_set then return end

  -- Ensure table is dereferenced from storage table for given registration number
  storage.core_seams_by_registration_number[registration_number] = nil

  if not resource_set.resource_index then return end

  Log.debug("CoreMiner.on_object_destroyed: resource_index " .. resource_set.resource_index ..
    ", registration_number " .. registration_number)

  local zone = Zone.from_zone_index(resource_set.zone_index)
  if (not zone) or zone.core_seam_resources[resource_set.resource_index] ~= resource_set then
    -- this is not a valid resource set anymore
    return
  end

  if registration_number == resource_set.resource_registration_number then
    -- Resource got destroyed due to surface deletion, adjacent chunk deletion, etc.
    Log.debug("CoreMiner.on_object_destroyed: resource destroyed for resource_index "
      .. resource_set.resource_index)
    if not resource_set.resource.valid then
      local surface = Zone.get_surface(zone)
      local core_seam_position = zone.core_seam_positions[resource_set.resource_index]
      local chunk_position = util.position_to_chunk_position(core_seam_position)

      -- Clean up associated entities in case they still exist
      CoreMiner.remove_seam(resource_set)

      -- Recreate seam if appropriate
      if surface and surface.is_chunk_generated(chunk_position) then
        CoreMiner.create_seam(zone, resource_set.resource_index)
      end
    end
  elseif registration_number == resource_set.fissure_registration_number and resource_set.resource.valid then
    -- Fissure got destroyed, presumably from a cliff explosive; seal core seam
    Log.debug("CoreMiner.on_object_destroyed: fissure destroyed for resource_index "
      .. resource_set.resource_index)
    CoreMiner.modify_seam_state(resource_set, true)
  end
end
Event.addListener(defines.events.on_object_destroyed, CoreMiner.on_object_destroyed)

---Replaces all tracked resources on a zone with the current
---fragment type of the zone. Used when the fragment type of
---a zone changes.
---@param zone PlanetType|MoonType Zone table
function CoreMiner.update_zone_fragment_resources(zone)
  CoreMiner.reset_seams(zone)
end

---Gets the name of the fragment from the name of the resource.
---@param resource_name string
function CoreMiner.resource_to_fragment_name(resource_name)
  local try_name = util.mod_prefix .. "core-fragment-" .. resource_name
  if prototypes.item[try_name] then
    return try_name
  end
  -- otherwise there is no fragment
end

---Sets the fragment name for the zone to either its primary resource or a default value.
---After calling this function, the given zone will have some valid core fragment type
---associated with it.
---@param zone PlanetType|MoonType Zone table
function CoreMiner.default_fragment_name(zone)
  if not zone.fragment_name then
    if zone.primary_resource then
      zone.fragment_name = CoreMiner.resource_to_fragment_name(zone.primary_resource)
    end
    if not zone.fragment_name then
      -- maybe choose something at random?
      error("Primary resource has no core fragment: " .. zone.name )
      zone.fragment_name = util.mod_prefix .. "core-fragment-omni"
    end
  end
end

---Deletes and regenerates all core seams.
---Should only be needed if plant size changed or the core fragment changed.
---@param zone PlanetType|MoonType Zone table
function CoreMiner.reset_seams(zone)
  if not zone.surface_index then return end
  CoreMiner.remove_seams(zone)
  zone.core_seam_positions = nil
  CoreMiner.generate_core_seam_positions(zone)
end

---@return string[]
function CoreMiner.get_all_core_resource_names()
  if CoreMiner.all_core_resource_names then return CoreMiner.all_core_resource_names end
  CoreMiner.all_core_resource_names = {}
  for _, resource in pairs(prototypes.get_entity_filtered{{filter="type", type="resource"}}) do
    if resource.resource_category == CoreMiner.resource_category then
      table.insert(CoreMiner.all_core_resource_names, resource.name)
    end
  end
  return CoreMiner.all_core_resource_names
end

---Destroys `resource` entity in a given CoreSeamInfo, also removing it from the storage registry
---@param resource_set CoreSeamInfo Core seam data, assumed to have a valid resource
function CoreMiner.destroy_resource(resource_set)
  resource_set.resource.destroy()

  -- Remove resource from storage registry table
  if resource_set.resource_registration_number then
    storage.core_seams_by_registration_number[resource_set.resource_registration_number] = nil
    resource_set.resource_registration_number = nil
  end
end

---Destroys `fissure` entity in a given CoreSeamInfo, also removing it from the storage registry
---@param resource_set CoreSeamInfo Core seam data, assumed to have a valid fissure
function CoreMiner.destroy_fissure(resource_set)
  resource_set.fissure.destroy()

  -- Remove fissure from storage registry table
  if resource_set.fissure_registration_number then
    storage.core_seams_by_registration_number[resource_set.fissure_registration_number] = nil
    resource_set.fissure_registration_number = nil
  end
end

---Deletes entities associated with a given `CoreSeamInfo` object and removes references to it from
---respective zone and global tables.
---@param resource_set CoreSeamInfo Core seam table
function CoreMiner.remove_seam(resource_set)
  -- Remove reference to this CoreSeamInfo object from `zone.core_seam_resources`
  -- This also disables most of the on_object_destroyed trigger, so do this before destroying entities
  local zone = Zone.from_zone_index(resource_set.zone_index)
  if zone and zone.core_seam_resources[resource_set.resource_index] == resource_set then
    zone.core_seam_resources[resource_set.resource_index] = nil
  end

  -- Destroy the resource if it is valid; destroy any associated chart tags
  if resource_set.resource and resource_set.resource.valid then
    for _, force in pairs(game.forces) do
      local existing_tags = force.find_chart_tags(
        resource_set.resource.surface, util.position_to_rect(resource_set.resource.position, 1))
      for _, tag in pairs(existing_tags) do
        if tag.icon and tag.icon.name == mod_prefix .. "core-seam" then
          tag.destroy()
        end
      end
    end
    CoreMiner.destroy_resource(resource_set)
  end

  -- Destroy the fissure if it is valid
  if resource_set.fissure and resource_set.fissure.valid then
    CoreMiner.destroy_fissure(resource_set)
  end

  -- Destroy the smoke generator if it is valid
  if resource_set.smoke_generator and resource_set.smoke_generator.valid then
    resource_set.smoke_generator.destroy()
  end
end

---Removes all generated seams from the zone surface.
---@param zone PlanetType|MoonType Zone table
function CoreMiner.remove_seams(zone)
  local surface = Zone.get_surface(zone)
  if zone.core_seam_resources then
    for _, resource_set in pairs(zone.core_seam_resources) do
      CoreMiner.remove_seam(resource_set)
    end
  end

  -- remove legacy entities
  if surface then
    for _, entity in pairs(surface.find_entities_filtered{type = "resource", name = CoreMiner.get_all_core_resource_names()}) do
      entity.destroy()
    end
  end

  zone.core_seam_resources = {}
end

---Gets the index into the zone `core_seam_positions` for a given resource position.
---@param zone PlanetType|MoonType Zone table
---@param position MapPosition Position data
function CoreMiner.get_resource_index(zone, position)
  local chunk_position = util.position_to_chunk_position(position)
  if zone.core_seam_chunks and zone.core_seam_chunks[chunk_position.x] and zone.core_seam_chunks[chunk_position.x][chunk_position.y] then
    return zone.core_seam_chunks[chunk_position.x][chunk_position.y]
  end
end

---Build a set of core seam positions in a deterministic way.
---Save the chunk positions for chunks with a resource.
---@param zone PlanetType|MoonType
function CoreMiner.generate_core_seam_positions(zone)
  if zone.core_seam_positions then return end
  if not Zone.is_solid(zone) then return end
  ---@cast zone PlanetType|MoonType
  local surface = Zone.get_surface(zone)
  zone.core_seam_positions = {}
  zone.core_seam_chunks = {}
  -- Target seam count for a 10k planet is roughly 100.
  local target_seams = 5 + 95 * (zone.radius / 10000)
  local seam_band_width = zone.radius / (target_seams + 2) -- skip the middle, skip the end
  local rng = game.create_random_generator(zone.seed)
  local phi = (1 + 5 ^ 0.5) / 2
  for i = 1, target_seams do
    local orientation = i * phi + 0.2 * rng() -- + up to 0.2 of a rotation randomness
    local distance = (i + rng()) * seam_band_width
    local position = util.orientation_to_vector(orientation, distance)
    local build_position = util.position_to_build_position(position)
    table.insert(zone.core_seam_positions, build_position)
  end
  for resource_index, core_seam_position in pairs(zone.core_seam_positions) do
    local chunk_position = util.position_to_chunk_position(core_seam_position)
    zone.core_seam_chunks[chunk_position.x] = zone.core_seam_chunks[chunk_position.x] or {}
    zone.core_seam_chunks[chunk_position.x][chunk_position.y] = resource_index
    if surface and surface.is_chunk_generated(chunk_position) then
      -- force the full ammount to avoid checking every miner for every resource placed
      -- also soon-to-be valid placements might be invalid at the time of checking the miner
      CoreMiner.create_seam(zone, resource_index, CoreMiner.resource_normal)
    end
    for _, force in pairs(game.forces) do
      if surface and  force.is_chunk_charted(surface, chunk_position) then
        CoreMiner.create_tag(zone, force, resource_index)
      end
    end
  end
  -- only check mined resources once
  CoreMiner.equalise(zone, true)
end

---Creates the seam entities at the appropriate position for a given `resource_index`.
---@param zone PlanetType|MoonType Zone table
---@param resource_index uint Index into the zone `core_seam_positions` to put the resource
---@param override_amount? number Set the amount of the resource explicitly (optional)
function CoreMiner.create_seam(zone, resource_index, override_amount)
  zone.core_seam_resources = zone.core_seam_resources or {}

  -- Don't recreate the seam if a valid resource already exists for that `resource_index`
  if zone.core_seam_resources[resource_index] and zone.core_seam_resources[resource_index].resource.valid then return end

  local surface = Zone.get_surface(zone)
  if not surface then return end
  local position = zone.core_seam_positions[resource_index]
  if not position then return end
  local new_amount = override_amount
  if not new_amount then new_amount = CoreMiner.get_resource_data(zone) end

  CoreMiner.default_fragment_name(zone)

  local resource = surface.create_entity{
    name = zone.fragment_name,
    position = position,
    amount = new_amount,
  }
  ---@cast resource -?
  local fissure = surface.create_entity{
    name = CoreMiner.name_core_seam_fissure,
    position = position,
  }
  ---@cast fissure -?
  local smoke_generator = surface.create_entity{
    name = CoreMiner.name_core_seam_smoke_generator,
    position = position,
    force = "neutral"
  }
  ---@cast smoke_generator -?

  -- Make fissure indestructible if there's a core miner on top of it
  if surface.find_entity(CoreMiner.name_core_miner_drill, position) then
    fissure.destructible = false
  end

  local resource_set = {
    resource_index = resource_index,
    zone_index = zone.index,
    resource = resource,
    fissure = fissure,
    smoke_generator = smoke_generator
  }

  zone.core_seam_resources[resource_index] = resource_set
  CoreMiner.register_seam_resource(resource_set)
  CoreMiner.register_seam_fissure(resource_set)

  local collision_mask_combined = {layers = {}}
  for _, collider in pairs({resource, fissure}) do
    for mask, bool in pairs(collider.prototype.collision_mask) do
      if mask == "layers" then
        for layer, value in pairs(collider.prototype.collision_mask.layers) do
          collision_mask_combined.layers[layer] = true
        end
      else
        collision_mask_combined[mask] = true
      end
    end
  end

  local collision_mask = collision_mask_combined

  -- make the area on top of and nearby the core seam clear and non-water
  CoreMiner.remove_colliding_entities(resource_set, collision_mask, surface)

  -- Update resource reference in case the core seam was sealed by `remove_colliding_entities`
  resource = resource_set.resource

  CoreMiner.place_tiles_below_and_around(resource, collision_mask, surface)
  surface.destroy_decoratives{area = resource.bounding_box}
end

---Seals or unseals a given CoreSeamInfo to new `seal` state. If `seal` is nil, it functions as a
---toggle
---@param resource_set CoreSeamInfo Core seam data; resource assumed to be valid
---@param seal? boolean Whether or not to seal the resource
function CoreMiner.modify_seam_state(resource_set, seal)
  local resource = resource_set.resource
  local surface = resource.surface
  local zone = Zone.from_surface(surface)
  local position = resource.position
  local current_state = string.ends(resource.name, CoreMiner.name_core_seam_sealed_suffix)

  seal = seal or not current_state

  if seal then
    if resource_set.smoke_generator and resource_set.smoke_generator.valid then
      resource_set.smoke_generator.destroy()
    end
  else
    if not (resource_set.smoke_generator and resource_set.smoke_generator.valid) then
      resource_set.smoke_generator = surface.create_entity{
        name = CoreMiner.name_core_seam_smoke_generator,
        position = position,
        force = "neutral"
      }
    end
  end

  -- Create or destroy fissure as needed
  if seal and resource_set.fissure and resource_set.fissure.valid then
    CoreMiner.destroy_fissure(resource_set)
  elseif not seal and (not resource_set.fissure or not resource_set.fissure.valid) then
    resource_set.fissure = surface.create_entity{
      name = CoreMiner.name_core_seam_fissure,
      position = resource.position
    }
    CoreMiner.register_seam_fissure(resource_set)
  end

  -- Create or destroy resource as needed
  if seal ~= current_state and zone then
    local name = seal and zone.fragment_name .. CoreMiner.name_core_seam_sealed_suffix
      or zone.fragment_name
    CoreMiner.destroy_resource(resource_set)
    resource_set.resource = surface.create_entity{
      name = name,
      position = position
    }
    CoreMiner.register_seam_resource(resource_set)
  end
end

---Creates the seam tag at the specified position.
---Expects the specified position to be charted for the given force.
---This is a no-op if the position is not charted.
---@param zone PlanetType|MoonType Zone table
---@param force LuaForce Force for which to place the tag
---@param resource_index uint Index into the zone `core_seam_positions` to put the resource
function CoreMiner.create_tag(zone, force, resource_index)
  zone.core_seam_resources = zone.core_seam_resources or {}
  if not (zone.core_seam_resources[resource_index] and zone.core_seam_resources[resource_index].resource.valid) then return end
  local surface = Zone.get_surface(zone)
  if not surface then return end
  local position = zone.core_seam_positions[resource_index]
  if not position then return end

  -- don't place tags if the setting is off
  if not settings.global["se-core-seam-map-tags"].value then return end

  -- early exit if the tag already exists in this location
  local existing_tags = force.find_chart_tags(surface, util.position_to_rect(position, 1))
  for _, tag in pairs(existing_tags) do
    if tag.icon and tag.icon.name == mod_prefix .. "core-seam" then
      return
    end
  end

  -- tag definitely doesn't exist; so create it
  force.add_chart_tag(surface, {
    position = position,
    icon = {
      type = "virtual",
      name = mod_prefix .. "core-seam"
    }
  })
end

---Removes any entities colliding with the seam resource. Seals seam if colliding player entities
---are found.
---@param resource_set CoreSeamInfo Core seam data
---@param collision_mask CollisionMask Collision mask
---@param surface LuaSurface Surface that resource is located on
function CoreMiner.remove_colliding_entities(resource_set, collision_mask, surface)
  local resource = resource_set.resource
  local position = resource.position
  local entities = surface.find_entities_filtered{
    collision_mask = collision_mask.layers, area = resource.bounding_box}
  local radius = (resource.bounding_box.right_bottom.x - resource.bounding_box.left_top.x) / 2

  local vectors_delta_length = Util.vectors_delta_length
  local vaults = Ancient.vault_entrance_structures_map

  local zone = Zone.from_zone_index(resource_set.zone_index) --[[@as PlanetType|MoonType]]
  -- create static random number generator in case seams get recreated later
  local rng = game.create_random_generator((zone.seed + resource_set.resource_index) % (util.max_uint32+1))
  for _, entity in pairs(entities) do
    if entity.valid then
      local force_name = entity.force and entity.force.name or nil
      if entity ~= resource_set.resource and entity ~= resource_set.fissure then
        if entity.type == "resource" then
          -- remove resources in an irregular circle.
          if vectors_delta_length(position, entity.position) < radius + 1 - rng(2) then
            entity.destroy({raise_destroy = true})
          end
        elseif not force_name then
          entity.destroy({raise_destroy = true})
        elseif SystemForces.is_system_force(force_name) and not SystemForces.protected_system_forces_map[force_name] and entity.type ~= "spider-leg" then
          local entity_name = entity.name
          entity.destroy({raise_destroy = true})

          -- If entity is a vault, queue it for recreation (in a different position)
          if vaults[entity_name] then
            zone.vault_pyramid = nil
            zone.vault_pyramid_position = nil
            local tick_task = new_tick_task("make-vault-pyramid") --[[@as MakeVaultPyramidTickTask]]
            tick_task.zone = zone
            tick_task.delay_until = game.tick + 1
          end
        else
          -- Seal the seam if the colliding entity belongs to a player force
          CoreMiner.modify_seam_state(resource_set, true)
        end
      end
    end
  end
end

---Places tiles underneath the core seam to ensure it's not on top of water.
---Uses a tile type from near the core seam (or a default if there are no non-water tiles nearby).
---@param resource LuaEntity Resource entity
---@param collision_mask CollisionMask Collision mask
---@param surface LuaSurface Surface that core seam is located on
function CoreMiner.place_tiles_below_and_around(resource, collision_mask, surface)
  -- ensure land tiles are below the seam
  if surface.count_tiles_filtered{collision_mask = collision_mask.layers, position = resource.position, radius = 8, limit = 1} > 0 then
    local non_water_tile_position = surface.find_non_colliding_position(resource.name, resource.position, 80, 1, false)
    local non_water_tile

    if non_water_tile_position then
      non_water_tile = surface.get_tile(non_water_tile_position).name
    else
      non_water_tile = "mineral-cream-sand-2" -- there needs to be some half-sensible default / brown won't ever look too out of place
    end

    -- correct the bad tiles in the circular radius around the center of the core seam
    local bad_tiles = surface.find_tiles_filtered{collision_mask = collision_mask.layers, position = resource.position, radius = 8}
    local corrected_tiles = {}
    for _, tile in pairs(bad_tiles) do
      table.insert(corrected_tiles, {name = non_water_tile, position = tile.position})
    end
    surface.set_tiles(corrected_tiles)
    -- correct some more tiles around the center of the core seam to make it more irregular
    for i=1,10 do
      local seed_value = resource.position.x * i + resource.position.y
      local theta = (seed_value % 360) / 180 * math.pi
      local distance = 6 + (seed_value % 5)
      local radius = 2 + (seed_value % 3)
      local position = {
        x = resource.position.x + distance * math.cos(theta),
        y = resource.position.y + distance * math.sin(theta)
      }
      local bad_tiles_2 = surface.find_tiles_filtered{collision_mask = collision_mask.layers, position = position, radius = radius}
      local corrected_tiles_2 = {}
      for _, tile in pairs(bad_tiles_2) do
        table.insert(corrected_tiles_2, {name = non_water_tile, position = tile.position})
      end
      surface.set_tiles(corrected_tiles_2)
    end
  end
end

---Searches all zones for miner entities and (re)creates global and zone `core_mining` tables.
---Any existing ones are deleted. This function can be quite expensive and should only run once
---`on_configuration_changed`, when loading an old save where `storage.core_mining` is nil.
function CoreMiner.create_core_mining_tables()
  storage.core_mining = {}

  for _, zone in pairs(storage.zone_index) do
    if zone.surface_index and Zone.is_solid(zone) then
      ---@cast zone PlanetType|MoonType
      local surface = Zone.get_surface(zone)
      local miners = surface.find_entities_filtered{name=CoreMiner.name_core_miner_drill}

      zone.core_mining = {} -- must be before reset_seams becuase that does validation on the core_mining table.

      CoreMiner.reset_seams(zone)

      for _, miner in pairs(miners) do
        local resource = surface.find_entity(zone.fragment_name, miner.position)
        local resource_index
        if resource then
          resource_index = CoreMiner.get_resource_index(zone, resource.position)
          if not resource_index then
            resource.destroy()
          end
        end
        if not resource_index then
          cancel_entity_creation(miner, nil, "Invalid Resource", nil)
        else

          local record = {
            drill = miner,
            drill_unit_number = miner.unit_number,
            resource = resource,
            resource_index = resource_index,
            position = miner.position,
            zone_index = zone.index,
            surface_index = miner.surface.index,
            force_name = miner.force.name
          }

          storage.core_mining[miner.unit_number] = record
          zone.core_mining[miner.unit_number] = record
        end
      end
    end
  end
end

---Check the generted chunk position against the seam chunks
---and generate the seam resource if needed.
---@param event EventData.on_chunk_generated Event data
function CoreMiner.on_chunk_generated(event)
  local zone = Zone.from_surface(event.surface)
  if not (zone and zone.core_seam_chunks) then return end
  local chunk_position = event.position
  if zone.core_seam_chunks[chunk_position.x] and zone.core_seam_chunks[chunk_position.x][chunk_position.y] then
    CoreMiner.create_seam(zone, zone.core_seam_chunks[chunk_position.x][chunk_position.y])
  end
end
Event.addListener(defines.events.on_chunk_generated, CoreMiner.on_chunk_generated)

---Check the charted chunk position against the seam chunks
---and generate the seam map tag if needed.
---@param event EventData.on_chunk_charted Event data
function CoreMiner.on_chunk_charted(event)
  local zone = Zone.from_surface_index(event.surface_index)
  if not (zone and zone.core_seam_chunks) then return end
  local chunk_position = event.position
  if zone.core_seam_chunks[chunk_position.x] and zone.core_seam_chunks[chunk_position.x][chunk_position.y] then
    for _, force in pairs(game.forces) do
      CoreMiner.create_tag(zone, force, zone.core_seam_chunks[chunk_position.x][chunk_position.y])
    end
  end
end
Event.addListener(defines.events.on_chunk_charted, CoreMiner.on_chunk_charted)

function CoreMiner.on_init()
  storage.core_seams_by_registration_number = {}
end
Event.addListener("on_init", CoreMiner.on_init, true)

return CoreMiner
