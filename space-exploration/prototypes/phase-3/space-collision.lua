local data_util = require("data_util")

local block_from_space = {
  "beacon",
  "assembling-machine", -- chemical plants, etc
  "furnace",
  "unit-spawner",
  "lab",
  "market",
  "offshore-pump",
  "pipe",
  "pipe-to-ground",
  "legacy-straight-rail",
  "legacy-curved-rail",
  "straight-rail",
  "curved-rail-a",
  "curved-rail-b",
  "half-diagonal-rail",
  "elevated-straight-rail",
  "elevated-curved-rail-a",
  "elevated-curved-rail-b",
  "elevated-half-diagonal-rail",
  "rail-ramp",
  "rail-support",
  "storage-tank",
  "splitter",
  "transport-belt",
  "underground-belt",
  "loader",
  "loader-1x1",
  "tree",
  "turret",
  "fluid-turret",
}

local use_tile_buildability_rules_instead = util.list_to_map({
  "elevated-straight-rail",
  "elevated-curved-rail-a",
  "elevated-curved-rail-b",
  "elevated-half-diagonal-rail",
})

-- Allow logo in space and empty space for menu simulations
for _, name in pairs({"factorio-logo-11tiles", "factorio-logo-16tiles", "factorio-logo-22tiles"}) do
  local prototype = data.raw.container[name]
  prototype.se_allow_in_space = true
  prototype.collision_mask = collision_mask_util.get_mask(prototype)
  prototype.collision_mask.layers.object = nil
  prototype.max_health = 666666
end


-- make vehicles collide with trees and pipes (train-layer)
-- stop characters colliding with pipes (player-layer)
for _, type in pairs({"pipe", "pipe-to-ground"}) do
  for _, prototype in pairs(data.raw[type]) do
    prototype.collision_mask = collision_mask_util.get_mask(prototype)
    if prototype.collision_mask then
      prototype.collision_mask.layers.player = nil
      prototype.collision_mask.layers.is_object = nil
      prototype.collision_mask.layers[vehicle_collision_layer] = true
    end
  end
end


-- disable paving over space and other space platform
for _, item in pairs(data.raw.item) do

  -- space
  if item.name ~= data_util.mod_prefix.."space-platform-scaffold"
      and item.name ~= data_util.mod_prefix.."space-platform-plating"
      and item.name ~= data_util.mod_prefix.."spaceship-floor" then
    if item.place_as_tile then
      if string.starts(item.place_as_tile.result, "lab") then
        item.place_as_tile = nil -- Don't allow placing lab tiles since we treat them special
      elseif not item.place_as_tile.condition then
        item.place_as_tile.condition = {space_collision_layer}
        item.place_as_tile.condition_size = 1
      else
        table.insert(item.place_as_tile.condition, space_collision_layer)
        item.place_as_tile.condition_size = math.max(item.place_as_tile.condition_size or 1)
      end
    end
  end
end

for _, prototype in pairs(data.raw["rocket-silo"]) do
  if prototype.name ~= data_util.mod_prefix .. "rocket-launch-pad-silo" then
    prototype.collision_mask = collision_mask_util.get_mask(prototype)
    prototype.collision_mask.layers[spaceship_collision_layer] = true
    data_util.collision_description(prototype)
  end
end

for _, prototype in pairs(data.raw["mining-drill"]) do
  local type = "mining-drill"
  if prototype.resource_categories and prototype.resource_categories[1] == "basic-solid" then
    -- allow in space
  elseif prototype.collision_mask then
    prototype.collision_mask = collision_mask_util.get_mask(prototype)
    prototype.collision_mask.layers[space_collision_layer] = true
  end
end

for _, prototype in pairs(data.raw["linked-container"]) do
  if prototype.name ~= data_util.mod_prefix .. "linked-container" then
    prototype.collision_mask = collision_mask_util.get_mask(prototype)
    if prototype.collision_mask then
      prototype.collision_mask.layers[spaceship_collision_layer] = true -- block from spaceship
    end
    data_util.collision_description(prototype)
  end
end

local function collides_with_all_layers()
  local layers = {}

  for _, prototype in pairs(data.raw["collision-layer"]) do
    layers[prototype.name] = true
  end

  return layers
end

for _, type in pairs(block_from_space) do
  for _, prototype in pairs(data.raw[type]) do

    prototype.collision_mask = collision_mask_util.get_mask(prototype)

    if prototype.se_allow_in_space -- Add this to your prototype to allow it in space
      or string.starts(prototype.name, data_util.mod_prefix .. "space")
      or string.starts(prototype.name, data_util.mod_prefix .. "deep-space")
      or string.find(prototype.name, "storage-tank", 1, true)
      or string.find(prototype.name, "valve", 1, true)
      or prototype.name == data_util.mod_prefix .. "core-miner-drill" -- the resource collides with spaceships
      or prototype.name == "beacon"
      or prototype.name == "realistic-reactor-eccs"
      -- Note pumps are already allowed, `pump` type is not in block_from_space
    then
      -- is allowed in space
      if prototype.allowed_effects and data_util.table_contains(prototype.allowed_effects, "productivity") and (not prototype.se_allow_productivity_in_space) then
        local spaced = table.deepcopy(prototype)
        spaced.name = spaced.name .. "-spaced"
        spaced.localised_name = {"space-exploration.structure_name_spaced", prototype.localised_name or {"entity-name."..prototype.name}}
        spaced.localised_description = {"space-exploration.structure_description_spaced", prototype.localised_description or {"entity-description."..prototype.name}}
        spaced.flags = spaced.flags or {}
        spaced.hidden = true
        if not spaced.placeable_by then
          for _, item in pairs(data.raw.item) do
            if item.place_result == prototype.name then
              spaced.placeable_by = spaced.placeable_by or {item = item.name, count=1}
              break
            end
          end
        end
        local allowed_effects = {}
        for _, effect in pairs(prototype.allowed_effects) do
          if effect ~= "productivity" then
            table.insert(allowed_effects, effect)
          end
        end
        spaced.allowed_effects = allowed_effects
        data:extend({spaced})
      end
    else
      -- Collide with space layer
      if prototype.collision_mask then
        prototype.collision_mask.layers[space_collision_layer] = true
      end
    end

    if prototype.name ~= data_util.mod_prefix.."dimensional-anchor"
      and type ~= "tree"
      and type ~= "turret"
      and type ~= "unit-spawner"
    then
      data_util.collision_description(prototype)
      -- Check to update the item description if it exists
      if data.raw.item[prototype.name] then
        if data.raw.item[prototype.name].localised_description then
          data_util.collision_description_sub(data.raw.item[prototype.name], prototype.collision_mask)
        else
          data.raw.item[prototype.name].localised_description = table.deepcopy(prototype.localised_description)
        end
      end
      if use_tile_buildability_rules_instead[prototype.type] and prototype.collision_mask.layers[space_collision_layer] then
        prototype.collision_mask.layers[space_collision_layer] = nil
        prototype.tile_buildability_rules = prototype.tile_buildability_rules or {}
        table.insert(prototype.tile_buildability_rules, {
          area = prototype.collision_box,
          colliding_tiles = {layers = {[space_collision_layer] = true}},
        })
      end
    end
    if prototype.crafting_categories and prototype.collision_mask and (not prototype.collision_mask.layers[spaceship_collision_layer]) then
      local has_space_recipe = false
      for _, category in pairs(prototype.crafting_categories) do
        if string.sub(category, 1, 6) == "space-" then
          has_space_recipe = true
          break
        end
      end
      if has_space_recipe then
        local grounded = table.deepcopy(prototype)
        grounded.name = grounded.name .. "-grounded"
        grounded.localised_name = {"space-exploration.structure_name_grounded", prototype.localised_name or {"entity-name."..prototype.name}}
        grounded.localised_description = {"space-exploration.structure_description_grounded",  prototype.localised_description or {"entity-description."..prototype.name}}
        grounded.flags = grounded.flags or {}
        grounded.hidden = true
        grounded.crafting_categories = {}
        for _, category in pairs(prototype.crafting_categories) do
          if string.sub(category, 1, 6) ~= "space-" then
            table.insert(grounded.crafting_categories, category)
          end
        end
        if #grounded.crafting_categories == 0 then
          grounded.crafting_categories = {"no-category"}
        end
        if not grounded.placeable_by then
          for _, item in pairs(data.raw.item) do
            if item.place_result == prototype.name then
              grounded.placeable_by = grounded.placeable_by or {item = item.name, count=1}
              break
            end
          end
        end
        data:extend({grounded})
      end
    end
  end
end

for _, type in pairs({"accumulator"}) do
  for _, prototype in pairs(data.raw[type]) do
    data_util.collision_description(prototype)
  end
end

for _, container in pairs({"container", "logistic-container"}) do
  for _, prototype in pairs(data.raw[container]) do
    if (not prototype.se_allow_in_space)
    and string.sub(prototype.name, 1, 8) ~= "se-space"
    and prototype.name ~= data_util.mod_prefix .. "cargo-rocket-cargo-pod"
    and prototype.name ~= data_util.mod_prefix.."meteor-defence-container"
    and prototype.name ~= data_util.mod_prefix.."meteor-point-defence-container"
    and prototype.name ~= data_util.mod_prefix.."meteor-point-defence-container"
    and (not string.find(prototype.name, data_util.mod_prefix.."rocket-", 1, true))
    and (not string.find(prototype.name, "silo", 1, true))
    and (not string.find(prototype.name, "chest", 1, true))
    and (not string.find(prototype.name, "warehouse", 1, true))
    and (not string.find(prototype.name, "storehouse", 1, true))
    and prototype.collision_mask then
      --log(prototype.name)
      prototype.collision_mask = collision_mask_util.get_mask(prototype)
      prototype.collision_mask.layers[space_collision_layer] = true
    end
  end
end

--[[ -- this prevents cars from driving over belts
for _, prototype in pairs(data.raw.car) do
  if prototype.name ~= "se-space-capsule-_-vehicle" then
    prototype.collision_mask = prototype.collision_mask or {layers={player=true, train=true}}
    prototype.collision_mask.layers[space_collision_layer] = true
  end
end
]]--
for _, prototype in pairs(data.raw.fish) do
  if not string.find(prototype.name, "space", 1, true) and prototype.collision_mask then
    prototype.collision_mask = collision_mask_util.get_mask(prototype)
    prototype.collision_mask.layers[space_collision_layer] = true
  end
end

for _, prototype in pairs(data.raw["offshore-pump"]) do
  prototype.collision_mask = collision_mask_util.get_mask(prototype)
  if prototype.collision_mask then
    prototype.collision_mask.layers[spaceship_collision_layer] = true
  end
end

-- note: they share the same order as the "cannot be placed on" text so they'll have to be added after the colission masks get processed
for prototype_type, _ in pairs(data.raw) do
  for _, prototype in pairs(data.raw[prototype_type]) do
    if prototype.se_placement_restriction_text then
      data_util.add_placement_restriction_tooltip(prototype, prototype.se_placement_restriction_text)
    end
  end
end

