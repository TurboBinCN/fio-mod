local data_util = require("data_util")

local resource_image = {
    filename = "__space-exploration-graphics__/graphics/blank.png",
    width = 1,
    height = 1,
    frame_count = 1,
    line_length = 1,
    shift = { 0, 0 },
    variation_count = 1,
}

local base_mining_time = 14.25 -- 15/s on nauvis with current planet size calculations
-- core fragments (cooled magma)
-- A generic mining recipe is used, the actual output item is chosen by script
-- default is 1, set 0 to exclude
se_core_fragment_resources = se_core_fragment_resources or {}
se_core_fragment_resources["water"] = se_core_fragment_resources["water"] or { multiplier = 0, omni_multiplier = 0.1}
se_core_fragment_resources["crude-oil"] = se_core_fragment_resources["crude-oil"] or { multiplier = 1, omni_multiplier = 0.1}
se_core_fragment_resources["stone"] = se_core_fragment_resources["stone"] or { multiplier = 1.6, omni_multiplier = 0.5}
se_core_fragment_resources["iron-ore"] = se_core_fragment_resources["iron-ore"] or { multiplier = 1.4, omni_multiplier = 0.5}
se_core_fragment_resources["copper-ore"] = se_core_fragment_resources["copper-ore"] or { multiplier = 1.2, omni_multiplier = 0.5}
se_core_fragment_resources["coal"] = se_core_fragment_resources["coal"] or { multiplier = 1, omni_multiplier = 0.25}
se_core_fragment_resources["uranium-ore"] = se_core_fragment_resources["uranium-ore"] or { multiplier = 0.2, omni_multiplier = 0.005}

se_core_fragment_resources[data_util.mod_prefix .. "vulcanite"] = se_core_fragment_resources[data_util.mod_prefix .. "vulcanite"] or  { multiplier = 1.6, omni_multiplier = 0}
se_core_fragment_resources[data_util.mod_prefix .. "beryllium-ore"] = se_core_fragment_resources[data_util.mod_prefix .. "beryllium-ore"] or { multiplier = 1, omni_multiplier = 0}
se_core_fragment_resources[data_util.mod_prefix .. "iridium-ore"] = se_core_fragment_resources[data_util.mod_prefix .. "iridium-ore"] or { multiplier = 1, omni_multiplier = 0}
se_core_fragment_resources[data_util.mod_prefix .. "holmium-ore"] = se_core_fragment_resources[data_util.mod_prefix .. "holmium-ore"] or { multiplier = 1, omni_multiplier = 0}
se_core_fragment_resources[data_util.mod_prefix .. "vitamelange"] = se_core_fragment_resources[data_util.mod_prefix .. "vitamelange"] or { multiplier = 1, omni_multiplier = 0}
se_core_fragment_resources[data_util.mod_prefix .. "cryonite"] = se_core_fragment_resources[data_util.mod_prefix .. "cryonite"] or { multiplier = 1.2, omni_multiplier = 0}

se_core_fragment_resources[data_util.mod_prefix .. "water-ice"] = se_core_fragment_resources[data_util.mod_prefix .. "water-ice"] or { multiplier = 0, omni_multiplier = 0}
se_core_fragment_resources[data_util.mod_prefix .. "methane-ice"] = se_core_fragment_resources[data_util.mod_prefix .. "methane-ice"] or { multiplier = 0, omni_multiplier = 0}
se_core_fragment_resources[data_util.mod_prefix .. "naquium-ore"] = se_core_fragment_resources[data_util.mod_prefix .. "naquium-ore"] or { multiplier = 0, omni_multiplier = 0}

local fragments = {}
local omni_name = data_util.mod_prefix .. "core-fragment-omni"
fragments[omni_name] = {name = omni_name, divisor = 1, products = {}}

for _, resource in pairs(data.raw.resource) do
  --log("add fragment resource " ..  resource.name )
  if resource.autoplace then -- don't add removed resources?
    local fragment = {
      resource = resource,
      name = data_util.mod_prefix .. "core-fragment-" .. resource.name,
      item_name = "entity-name."..resource.name,
      tint = resource.mining_visualisation_tint or resource.map_color
    }
    --log(resource.name)
    local products = {}
    if resource.minable.result and type(resource.minable.result) == "string" then
      products[resource.minable.result] = {type = "item", name = resource.minable.result, amount = 1}
    elseif type(resource.minable.result) == "table" then
      local product = data_util.collapse_product(resource.minable.result)
      products[product.name] = product
    elseif resource.minable.results and resource.minable.results.name then
      products = {data_util.collapse_product(resource.minable.results)}
    elseif resource.minable.results and resource.minable.results[1] and type(resource.minable.results[1]) == "table" then
      for _, p in pairs(resource.minable.results) do
        table.insert(products, data_util.collapse_product(p))
      end
    elseif resource.minable.results then
      products = data_util.collapse_product(resource.minable.results)
    end
    if resource.minable.required_fluid then
      fragment.processing_fluid = {
        name = resource.minable.required_fluid,
        amount = resource.minable.fluid_amount or 1
      }
    end
    local valid_products = 0
    if table_size(products) > 0 then
      fragment.products = products
      for _, product in pairs(products) do
        local amount = 0
        if product.amount then
          amount = product.amount
        elseif product.amount_min and product.amount_max then
          amount = (product.amount_min + product.amount_max) / 2
        end
        if product.probability then amount = amount * product.probability end

        product.amount = amount
        if se_core_fragment_resources[product.name] and se_core_fragment_resources[product.name].multiplier then
          product.amount = amount * se_core_fragment_resources[product.name].multiplier
        end

        product.amount_min = nil
        product.amount_max = nil
        product.probability = 1

        if product.amount == 0 then
          products[product.name] = nil
        else
          valid_products = valid_products + 1
        end

        local omni_multiplier = 0.5
        if se_core_fragment_resources[product.name] and se_core_fragment_resources[product.name].omni_multiplier then
          omni_multiplier = se_core_fragment_resources[product.name].omni_multiplier
        end
        if omni_multiplier > 0 then
          fragments[omni_name].products[product.name] = fragments[omni_name].products[product.name] or {name = product.name, amount = 0, type = product.type}
          fragments[omni_name].divisor = fragments[omni_name].divisor + 1
          fragments[omni_name].products[product.name].amount = fragments[omni_name].products[product.name].amount + amount * omni_multiplier
        end
      end
    end
    if valid_products > 0 then
      fragments[fragment.name] = fragment
    end
  end
end

-- water, can be hard to find on some planets,
-- adding water to the omni measn there's a small chance that
-- a different fragment type breaks down into something with water
if not fragments[omni_name].products["water"] then
  fragments[omni_name].products.water = {type = "fluid", name = "water", amount = 1}
end

if not fragments[omni_name].products[data_util.mod_prefix .. "pyroflux"] then
  fragments[omni_name].products.pyroflux = {type = "fluid", name = data_util.mod_prefix .. "pyroflux", amount = 0.25}
end

local vulcanite_fragment_name = data_util.mod_prefix .. "core-fragment-" .. data_util.mod_prefix .. "vulcanite"
if not fragments[vulcanite_fragment_name].products[data_util.mod_prefix .. "pyroflux"] then
  fragments[vulcanite_fragment_name].products.pyroflux = {type = "fluid", name = data_util.mod_prefix .."pyroflux",  amount = 0.25}
end

-- TODO: test with high fluid resource modpack
local pulverizer_fluid_boxes = data.raw["assembling-machine"][data_util.mod_prefix .. "pulveriser"].fluid_boxes
local pulverizer_max_fluid_outputs = 0
for _, fluid_box in pairs(pulverizer_fluid_boxes) do
  if fluid_box.production_type == "output" then
    pulverizer_max_fluid_outputs = pulverizer_max_fluid_outputs + 1
  end
end
local omni_fluids = 0
for _, product in pairs(fragments[omni_name].products) do
  if product.type == "fluid" then
    omni_fluids = omni_fluids + 1
  end
end
if omni_fluids > pulverizer_max_fluid_outputs then -- water infinite anyway
  fragments[omni_name].products.water = nil
  omni_fluids = omni_fluids - 1
end
if omni_fluids > pulverizer_max_fluid_outputs then -- crude-oil infinite anyway
  fragments[omni_name].products["crude-oil"] = nil
  omni_fluids = omni_fluids - 1
end
if omni_fluids > pulverizer_max_fluid_outputs then
  local safe_products = {}
  omni_fluids = 0
  for _, product in pairs(fragments[omni_name].products) do
    if product.type == "fluid" then
      if omni_fluids < pulverizer_max_fluid_outputs then
        safe_products[product.name] = product
        omni_fluids = omni_fluids + 1
      end
    else
      safe_products[product.name] = product
    end
  end
  fragments[omni_name].products = safe_products
end


local c = 0
for fragment_name, fragment in pairs(fragments) do
    c = c + 1
    local item =
    {
      type = "item",
      name = fragment.name,
      icon_size = 64,
      icons = {
        {icon = "__space-exploration-graphics__/graphics/icons/core-fragment.png", scale = 0.5, icon_size = 64}
      },
      subgroup = "core-fragments",
      order = "a-a-a-"..string.format("%02d", c),
      stack_size = 20,
      localised_name = {"item-name.core-fragment", {fragment.item_name}},
      pictures = {
        { layers = {
          {filename = "__space-exploration-graphics__/graphics/icons/core-fragment.png",
            scale = 0.5,
            size = 64
        }}},
        { layers = {{
          filename = "__space-exploration-graphics__/graphics/icons/core-fragment-1.png",
          scale = 0.5,
          size = 64
        }}},
        { layers = {{
          filename = "__space-exploration-graphics__/graphics/icons/core-fragment-2.png",
          scale = 0.5,
          size = 64
        }}},
        { layers = {{
          filename = "__space-exploration-graphics__/graphics/icons/core-fragment-3.png",
          scale = 0.5,
          size = 64
        }}},
      },
      auto_recycle = false,
    }
    local subgroup
    if fragment_name ~= omni_name then
      for _, product in pairs(fragment.products) do
        if product.type == "fluid" and  data.raw.fluid[product.name] and  data.raw.fluid[product.name].icon then
          subgroup = data.raw.fluid[product.name].subgroup
          if product.name == "crude-oil" then
            subgroup = "oil"
          end
          table.insert(item.icons, {
            icon = data.raw.fluid[product.name].icon,
            icon_size = data.raw.fluid[product.name].icon_size or 64,
            scale = 32 / (data.raw.fluid[product.name].icon_size or 64),
            tint = {r = 0.5, g = 0.5, b = 0.5, a = 0.5},
          })
          for _, variant in pairs(item.pictures) do
            table.insert(variant.layers, {
              filename = data.raw.fluid[product.name].icon,
              size = data.raw.fluid[product.name].icon_size or 64,
              scale = 16 / (data.raw.fluid[product.name].icon_size or 64),
              tint = {r = 0.5, g = 0.5, b = 0.5, a = 0.5},
            })
          end
        elseif data.raw.item[product.name] and data.raw.item[product.name].icon then
          subgroup = data.raw.item[product.name].subgroup
          table.insert(item.icons, {
            icon = data.raw.item[product.name].icon,
            icon_size = data.raw.item[product.name].icon_size or 64,
            scale = 32 / (data.raw.item[product.name].icon_size or 64),
            tint = {r = 0.5, g = 0.5, b = 0.5, a = 0.5}
          })

          for i, variant in pairs(item.pictures) do
            if data.raw.item[product.name].pictures and data.raw.item[product.name].pictures[i] then
              local pic = table.deepcopy(data.raw.item[product.name].pictures[i])
              pic.tint = {r = 0.5, g = 0.5, b = 0.5, a = 0.5}
              table.insert(variant.layers, pic)
            else
              table.insert(variant.layers, {
                filename = data.raw.item[product.name].icon,
                size = data.raw.item[product.name].icon_size or 64,
                scale = 16 / (data.raw.item[product.name].icon_size or 64),
                tint = {r = 0.5, g = 0.5, b = 0.5, a = 0.5},
              })
            end
          end
        end
        break -- only add 1 layer
      end
    end
    subgroup = subgroup or "chemical"
    item.subgroup = subgroup
    item.order = "a["..subgroup.."]-a[core-frag]-a[core-frag]-"..string.format("%02d", c)
    local recipe_products = { }
    if fragment_name ~= omni_name then
      table.insert(recipe_products, {type = "item", name = omni_name, amount_min = 0, amount_max = 4}) -- 2 average
    else
      item.localised_name  = nil
    end
    local has_stone = false
    --local has_vulcanite = false
    local max_amount = 0
    for _, product in pairs(fragment.products) do
      if product.name == "stone" then has_stone = true end
      --if product.name ==  data_util.mod_prefix.."vulcanite" then has_vulcanite = true end
      local prod = {type = product.type, name = product.name}
      max_amount = math.max(max_amount, product.amount * 16)
      if product.amount * 16 >= 1 then
        prod.amount = product.amount * 16
      else
        prod.amount = nil
        prod.probability = product.amount * 16
        prod.amount_min = 1
        prod.amount_max = 1
      end
      table.insert(recipe_products, prod)
    end
    if not has_stone then
      table.insert(recipe_products, {type = "item", name = "stone", amount = 1})
    end
    --if not has_vulcanite then
    --  table.insert(recipe_products, {name = data_util.mod_prefix.."vulcanite", amount = 1})
    --end
    local recipe = {
      type = "recipe",
      name = fragment.name,
      icon_size = 64,
      icons = data_util.add_icons(item.icons or item.icon,
                                  data.raw.item[data_util.mod_prefix.."pulveriser"]),
      subgroup = subgroup,
      category = "core-fragment-processing",
      order = item.order,
      ingredients = {{type = "item", name = item.name, amount = 20}},
      results = recipe_products,
      allow_as_intermediate = false, -- prevent being sown as a base resource?
      allow_productivity = true,
      energy_required = 20,
      enabled = false,
      localised_name = {"recipe-name.core-fragment", {fragment.item_name}},
      always_show_made_in = true,
      allow_decomposition = false,
      hide_from_signal_gui = false,
    }
    if fragment.processing_fluid then
      table.insert(recipe.ingredients, {
        type = "fluid",
        name = fragment.processing_fluid.name,
        amount = math.ceil(fragment.processing_fluid.amount * max_amount / 10)}) -- /10 to compensate for janky engine format
    end
    local map_tint = fragment.tint or {r = 0, g = 0, b = 0, a = 1.0}
    local sprite_tint = fragment.tint or {r = 0.8, g = 0.8, b = 0.8, a = 1.0}
    -- special case crude oil because its map color is purple which is not the black color that it appears on the ground
    if fragment.name == (data_util.mod_prefix .. "core-fragment-" .. "crude-oil") then
      sprite_tint = {r = 0.2, g = 0.15, b = 0.2, a = 1.0}
    end
    --local mining_time = 6.25
    local mining_time = base_mining_time
    -- adjust mining time based on the primary resource.
    if fragment.resource and fragment.resource.minable.mining_time then
      -- apply 20% of the mining time modifier from the resource
      -- e.g. 500x time becomes 2x time
      mining_time = mining_time * (1 + 0.5 * (fragment.resource.minable.mining_time - 1))
    end
    local localised_name = {"entity-name."..data_util.mod_prefix .. "core-seam"}
    if fragment.resource then
      localised_name = {"", {"entity-name."..data_util.mod_prefix .. "core-seam"}, ": ", {"entity-name."..fragment.resource.name}}
    end
    local core_resource_patch = {
      type = "resource",
      name = fragment.name,
      category = data_util.mod_prefix.."core-mining",
      collision_box = {{-5.2, -5.2}, {5.2, 5.2}},
      selection_box = {{-5.2, -5.2}, {5.2, 5.2}},
      selectable_in_game = true,
      selection_priority = 1,
      collision_mask = {
        layers = {
          resource = true,
          doodad = true,
        },
      },
      flags = { "placeable-neutral" },
      highlight = true,
      icon_size = 64,
      icons = item.icons,
      infinite = true,
      infinite_depletion_amount = 0,
      map_color = map_tint,
      map_grid = false,
      minable = {
        mining_time = mining_time,
        results = {
          {
            type = "item",
            amount_max = 1,
            amount_min = 1,
            name = fragment.name,
            probability = 1,
          }
        }
      },
      minimum = 1,
      normal = 1000000,
      order = "a-b-a",
      resource_patch_search_radius = 12, --#FIXME: set to 12 to workaround engine bug present in 2.0.43, once that is fixed consider reverting to 0.
      stage_counts = { 0 },
      stages = {
        sheet = {
          filename = "__space-exploration-graphics-3__/graphics/entity/core-seam/core-seam.png",
          width = 556,
          height = 456,
          frame_count = 1,
          line_length = 1,
          shift = { 0, 0 },
          variation_count = 1,
          scale = 0.8
        }
      },
      stages_effect = {
        sheet = {
          filename = "__space-exploration-graphics-3__/graphics/entity/core-seam/core-seam-resource.png",
          width = 556,
          height = 456,
          frame_count = 1,
          line_length = 1,
          shift = { 0, 0 },
          variation_count = 1,
          scale = 0.8,
          tint = sprite_tint
        }
      },
      effect_animation_period = 1.0, -- the stages_effect does not render at all if this is 0.0
      effect_animation_period_deviation = 0,
      effect_darkness_multiplier = 1.0,
      min_effect_alpha = 1.0,
      max_effect_alpha = 1.0,
      localised_name = {"entity-name."..data_util.mod_prefix .. "core-seam-type", {fragment.item_name}},
      localised_description = {"entity-description."..data_util.mod_prefix .. "core-seam", "[img=item/"..fragment.name.."]", {"item-name.core-fragment", {fragment.item_name}}},
      se_skip_resource_autoplace_override = true,
    }
    if fragment_name == omni_name then
      recipe.localised_name  = nil
      core_resource_patch.localised_name = {"entity-name."..data_util.mod_prefix .. "core-seam"}
      core_resource_patch.localised_description = {"entity-description."..data_util.mod_prefix .. "core-seam", "[img=item/"..fragment.name.."]", {"item-name." .. fragment.name}}
    end
    local core_resource_patch_sealed = table.deepcopy(core_resource_patch)
    core_resource_patch_sealed.name = core_resource_patch_sealed.name .. "-sealed"
    core_resource_patch_sealed.factoriopedia_alternative = core_resource_patch_sealed.name
    core_resource_patch_sealed.hidden = true
    core_resource_patch_sealed.localised_description[1] = "entity-description."..data_util.mod_prefix .. "core-seam-sealed"
    core_resource_patch_sealed.stages.sheet.filename = "__space-exploration-graphics-3__/graphics/entity/core-seam/core-seam-sealed.png"
    core_resource_patch_sealed.stages_effect.sheet.filename = "__space-exploration-graphics-3__/graphics/entity/core-seam/core-seam-resource-sealed.png"
    data:extend({
      core_resource_patch,
      core_resource_patch_sealed,
      item,
      recipe
    })
    table.insert(
      data.raw.technology[data_util.mod_prefix .. "core-miner"].effects,
      {
        type = "unlock-recipe",
        recipe = recipe.name,
      }
    )
    se_delivery_cannon_recipes[fragment.name] = {name=fragment.name}
end

--log(serpent.block(data.raw["item"]["se-core-fragment-crude-oil"]))
