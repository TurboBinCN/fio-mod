local data_util = require("data_util")


data.raw.recipe["stone-brick"].category = "kiln"

data_util.replace_or_add_ingredient("low-density-structure", "steel-plate", "steel-plate", 5)
data_util.replace_or_add_ingredient("low-density-structure", "copper-plate", "copper-plate", 10)
if data.raw.item[SEItemNames.get_glass_name()] then
  data_util.replace_or_add_ingredient("low-density-structure", nil, SEItemNames.get_glass_name(), 10)
else
  data_util.replace_or_add_ingredient("low-density-structure", nil, "stone", 10)
end
data_util.replace_or_add_ingredient("low-density-structure", "plastic-bar", "plastic-bar", 10)
data_util.recipe_set_energy_required("low-density-structure", 10)

data_util.replace_or_add_ingredient("rocket-control-unit", nil, "iron-plate", 5)
data_util.replace_or_add_ingredient("rocket-control-unit", "processing-unit", SEItemNames.get_glass_name(), 5)
data_util.replace_or_add_ingredient("rocket-control-unit", "speed-module", "battery", 5)
data_util.replace_or_add_ingredient("rocket-control-unit", "advanced-circuit", "advanced-circuit", 5)

data_util.replace_or_add_ingredient("rocket-part", "low-density-structure", "low-density-structure", 1)
data_util.replace_or_add_ingredient("rocket-part", "rocket-control-unit", "rocket-control-unit", 1)
data_util.replace_or_add_ingredient("rocket-part", "processing-unit", data_util.mod_prefix .. "heat-shielding", 1)
data_util.replace_or_add_ingredient("rocket-part", "rocket-fuel", "rocket-fuel", 3)
data_util.recipe_set_energy_required("rocket-part", 2)
data.raw.recipe["rocket-part"].subgroup = "rocket-part"
data.raw["rocket-silo"]["rocket-silo"].rocket_parts_required = 100
data.raw["rocket-silo"]["rocket-silo"].rocket_result_inventory_size = 20 -- needed for 50x20 = 1000 data returned

data.raw.recipe["solid-fuel-from-heavy-oil"].category = "fuel-refining"
data.raw.recipe["solid-fuel-from-heavy-oil"].energy_required = 0.5
data.raw.recipe["solid-fuel-from-light-oil"].category = "fuel-refining"
data.raw.recipe["solid-fuel-from-light-oil"].energy_required = 0.5
data.raw.recipe["solid-fuel-from-petroleum-gas"].category = "fuel-refining"
data.raw.recipe["solid-fuel-from-petroleum-gas"].energy_required = 0.5

data.raw.recipe["rocket-fuel"].crafting_machine_tint =
{
  primary = {r = 0.290, g = 0.027, b = 0.000, a = 0.000}, -- #49060000
  secondary = {r = 0.722, g = 0.465, b = 0.190, a = 0.000}, -- #b8763000
  tertiary = {r = 0.870, g = 0.365, b = 0.000, a = 0.000}, -- #dd5d0000
}
data.raw.recipe["rocket-fuel"].category = "fuel-refining"
data.raw.recipe["rocket-fuel"].subgroup = "fuel"
data.raw.recipe["rocket-fuel"].order = "p"
data.raw.recipe["rocket-fuel"].energy_required = 1

data:extend({
  {
    type = "recipe",
    name = data_util.mod_prefix .. "liquid-rocket-fuel",
    ingredients = {
      {type = "item",  name = "rocket-fuel", amount = 1 },
    },
    results = {
      {type = "fluid", name = data_util.mod_prefix.."liquid-rocket-fuel", amount=data_util.liquid_rocket_fuel_per_solid}
    },
    allow_productivity = true,
    energy_required = 1,
    enabled = false,
    category = "fuel-refining",
    subgroup = "fuel",
    order = "a[fuel]-d[liquid-rocket]-a[liquid-rocket]",
    crafting_machine_tint =
    {
      primary = {r = 0.290, g = 0.027, b = 0.000, a = 0.000}, -- #49060000
      secondary = {r = 0.722, g = 0.465, b = 0.190, a = 0.000}, -- #b8763000
      tertiary = {r = 0.870, g = 0.365, b = 0.000, a = 0.000}, -- #dd5d0000
    }
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "vulcanite-rocket-fuel",
    localised_name = {"item-name.rocket-fuel"},
    ingredients = {
      { type = "fluid", name = data_util.mod_prefix .. "pyroflux", amount = 60 },
      { type = "item", name = "coal", amount = 1 },
    },
    results = {
      { type = "item", name = "rocket-fuel", amount= 1 }
    },
    icons = data_util.transition_icons(
      {
        icon = data.raw.fluid[data_util.mod_prefix .. "pyroflux"].icon,
        icon_size = data.raw.fluid[data_util.mod_prefix .. "pyroflux"].icon_size, scale = 0.5
      },
      {
        icon = data.raw.item["rocket-fuel"].icon,
        icon_size = data.raw.item["rocket-fuel"].icon_size, scale = 0.5
      }
    ),
    energy_required = 1,
    allow_productivity = true,
    enabled = false,
    category = "fuel-refining",
    subgroup = "fuel",
    order = "a[fuel]-c[rocket-fuel]-c[rocket-fuel]",
    crafting_machine_tint =
    {
      primary = {r = 0.290, g = 0.027, b = 0.000, a = 0.000}, -- #49060000
      secondary = {r = 0.722, g = 0.465, b = 0.190, a = 0.000}, -- #b8763000
      tertiary = {r = 0.870, g = 0.365, b = 0.000, a = 0.000}, -- #dd5d0000
    },
    allow_as_intermediate = false,
    allow_decomposition = false,
    hide_from_signal_gui = false,
  },
})

data:extend({
  {
    type = "recipe",
    name = data_util.mod_prefix .. "rocket-fuel-from-water-copper",
    ingredients = {
      { type = "fluid", name = "water", amount = 1000 },
      { type = "item", name = "copper-plate", amount = 1 },
    },
    results = {
      {type = "item", name = "rocket-fuel", amount = 1 },
      {type = "item", name = data_util.mod_prefix .. "scrap", probability = 0.1, amount_min = 1, amount_max = 1 },
    },
    icons = data_util.transition_icons(
      {
        icon = data.raw.fluid["water"].icon,
        icon_size = data.raw.fluid["water"].icon_size, scale = 0.5
      },
      {
        icon = data.raw.item["rocket-fuel"].icon,
        icon_size = data.raw.item["rocket-fuel"].icon_size, scale = 0.5
      }
    ),
    energy_required = 500,
    allow_productivity = true,
    enabled = false,
    category = "fuel-refining",
    subgroup = "fuel",
    order = "a[fuel]-c[rocket-fuel]-b[rocket-fuel]",
    crafting_machine_tint =
    {
      primary = {r = 0.290, g = 0.027, b = 0.000, a = 0.000}, -- #49060000
      secondary = {r = 0.722, g = 0.465, b = 0.190, a = 0.000}, -- #b8763000
      tertiary = {r = 0.870, g = 0.365, b = 0.000, a = 0.000}, -- #dd5d0000
    },
    allow_decomposition = false,
    hide_from_signal_gui = false,
  },
})

data.raw.recipe["barrel"].allow_productivity = false
data.raw.recipe["barrel"].ingredients = { {type = "item",  name = "steel-plate", amount = 1 } }
data.raw.recipe["barrel"].results = { {type = "item",  name = "barrel", amount = 1 } }
