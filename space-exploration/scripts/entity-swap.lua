--Used for swapping entities based on zone specific properties
local EntitySwap = {}

EntitySwap.composite_suffix_seperator = "-_-"

EntitySwap.tag_to_suffix = {
  ["water_none"] = "waterless",
  ["space"] = "spaced",
  ["ground"] = "grounded",
}

EntitySwap.entity_swap_cache = {}

---@param surface_index uint
---@param entity_name string
---@param entity_swapped_name string
function EntitySwap.add_to_cache(surface_index, entity_name, entity_swapped_name)
  if EntitySwap.entity_swap_cache[surface_index] then
    EntitySwap.entity_swap_cache[surface_index][entity_name] = entity_swapped_name
  else
    EntitySwap.entity_swap_cache[surface_index] = {}
    EntitySwap.entity_swap_cache[surface_index][entity_name] = entity_swapped_name
  end
end

---@param surface_index uint
---@param entity_name string
---@return string?
function EntitySwap.return_cached_swap(surface_index, entity_name)
  if EntitySwap.entity_swap_cache[surface_index] and EntitySwap.entity_swap_cache[surface_index][entity_name] then
    return EntitySwap.entity_swap_cache[surface_index][entity_name]
  end
end

---@param entity LuaEntity
---@param prototype_name string
---@return LuaEntity
function EntitySwap.swap_ghost(entity, prototype_name)
  local surface = entity.surface
  local recipe, quality
  if entity.ghost_type == "assembling-machine" then
    recipe, quality = entity.get_recipe()
  end
  local clone = surface.create_entity{
    name = "entity-ghost",
    inner_name = prototype_name,
    position = entity.position,
    force = entity.force,
    direction = entity.direction,
    recipe = recipe and recipe.name,
    recipe_quality = quality and quality.name,
    quality = entity.quality,
  }
  ---@cast clone -?
  clone.operable = entity.operable
  clone.active = entity.active
  clone.destructible = entity.destructible
  clone.rotatable = entity.rotatable
  --if entity.item_requests then -- this is read only now
  --  clone.item_requests = util.deep_copy(entity.item_requests)
  --end
  clone.insert_plan = entity.insert_plan
  entity.destroy()
  return clone
end

---@param entity LuaEntity
---@param prototype_name string
---@return LuaEntity?
function EntitySwap.swap_structure(entity, prototype_name)
  if storage.remove_placement_restrictions then return end
  local surface = entity.surface
  local recipe, quality
  if entity.type == "assembling-machine" then
    recipe, quality = entity.get_recipe()
  end
  local clone = surface.create_entity{
    name = prototype_name,
    position = entity.position,
    force = entity.force,
    direction = entity.direction,
    recipe = recipe and recipe.name,
    recipe_quality = quality and quality.name,
    quality = entity.quality,
  }
  ---@cast clone -?
  local crafting_progress
  if recipe then
    --pause crafting so it doesn't attempt to finish a craft during inventory swap
    crafting_progress = entity.crafting_progress
    entity.crafting_progress = 0
  end
  clone.operable = entity.operable
  clone.active = entity.active
  clone.destructible = entity.destructible
  clone.rotatable = entity.rotatable
  local inventories = {}
  for _, inv_type in pairs({
    defines.inventory.fuel,
    defines.inventory.burnt_result,
    defines.inventory.crafter_input,
    defines.inventory.crafter_output,
    defines.inventory.crafter_modules,
  }) do
    inventories[inv_type] = inv_type -- no duplicate indexes
  end
  for _, inv_type in pairs(inventories) do
    local inv_a = entity.get_inventory(inv_type)
    local inv_b = clone.get_inventory(inv_type)
    if inv_a and inv_b then
      util.move_inventory_items(inv_a, inv_b)
    end
  end
  if #entity.fluidbox > 0 then
    local entity_fluidbox = entity.fluidbox
    local clone_fluidbox = clone.fluidbox
    for i = 1, math.min(#entity_fluidbox, #clone_fluidbox) do
      clone_fluidbox[i] = entity_fluidbox[i]
    end
  end
  if crafting_progress then
    clone.crafting_progress = crafting_progress
  end
  local proxy = surface.find_entity("item-request-proxy", entity.position)
  if proxy and next(proxy.item_requests) then
    surface.create_entity{
      name = "item-request-proxy",
      position = entity.position,
      force = entity.force,
      target = clone,
      --modules = util.deep_copy(proxy.item_requests)
      modules = util.deep_copy(proxy.insert_plan),
      removal_plan = util.deep_copy(proxy.removal_plan)
    }
  end
  entity.destroy()
  clone.teleport(clone.position) -- reconnect pipes
  return clone
end

---@param surface LuaSurface
---@return boolean
function is_surface_space(surface)
  local zone = Zone.from_surface(surface)
  if zone then
    return Zone.is_space(zone)
  elseif core_util.list_to_map({
    "space-factory-floor",
    "se-spaceship-factory-floor",
  })[surface.name] then
    return true
  elseif string.starts(surface.name, "Space Factory") then -- Space Factorissimo compatibility (quez notes: that mod is still 1.1)
    return true
  end
  return false
end

---@param entity_name string
---@param surface LuaSurface
---@return string?
function EntitySwap.entity_name_for_surface(entity_name, surface)
  local cached_value = EntitySwap.return_cached_swap(surface.index, entity_name)
  if cached_value then
    return cached_value
  end

  local zone = Zone.from_surface(surface)
  local relevant_tags = {}
  local constructed_suffix

  if is_surface_space(surface) then
    table.insert(relevant_tags, "space")
  else
    table.insert(relevant_tags, "ground")
  end

  if zone and zone.tags then
    if util.table_contains(zone.tags, "water_none") then
      table.insert(relevant_tags, "water_none")
    end
  end

  for _, tag in pairs(relevant_tags) do
    if constructed_suffix then
      if prototypes.entity[entity_name .. EntitySwap.composite_suffix_seperator .. constructed_suffix .. "-" .. EntitySwap.tag_to_suffix[tag]] then
        constructed_suffix = constructed_suffix .. "-" .. EntitySwap.tag_to_suffix[tag]
      end
    else
      if prototypes.entity[entity_name .. EntitySwap.composite_suffix_seperator .. EntitySwap.tag_to_suffix[tag]] then
        constructed_suffix = EntitySwap.tag_to_suffix[tag]
      end
    end
  end

  if constructed_suffix then
    local entity_swapped_name = entity_name .. EntitySwap.composite_suffix_seperator .. constructed_suffix
    EntitySwap.add_to_cache(surface.index, entity_name, entity_swapped_name)
    return entity_swapped_name
  end

end

---@param event EntityCreationEvent Event data
function EntitySwap.on_entity_created(event)
  local entity
  if event.entity and event.entity.valid then
    entity = event.entity
  end
  if (not entity) or entity.type == "tile-ghost" then return end

  -- Is the entity actually a ghost?
  if entity.type == "entity-ghost" then
    -- Make the ghost into its base entity instead of a possible varient, so that it will react properly to being hand-built. It will be re-swapped once properly built.
    local sub_index = string.find(entity.ghost_name, EntitySwap.composite_suffix_seperator, 1, true)
    if sub_index then
      return EntitySwap.swap_ghost(entity, string.sub(entity.ghost_name,1,sub_index-1))
    end
  else
    local swapped_entity_name = EntitySwap.entity_name_for_surface(entity.name, entity.surface)
    if swapped_entity_name then
      return EntitySwap.swap_structure(entity, swapped_entity_name)
    end
  end
end
Event.addOnEntityCreatedListeners(EntitySwap.on_entity_created)

return EntitySwap
