local data_util = require("data_util")

-- This source is dedicated to maintaining compatability changes required for the K2 and SE resources
-- E.G.
--  - Control the ability to gather gases from the atmosphere

---- Atmospheric Condenser Changes
-- Can't get hydrogen for free. Use electrolyser
data_util.delete_recipe("kr-hydrogen")

local oxygen = data.raw.recipe["kr-oxygen"]
oxygen.energy_required = 7
data_util.disallow_efficiency("kr-oxygen")

-- Atmosphere composition is 70:20 Nitrogen:Oxygen, Nitrogen is easier to collect.
local nitrogen = data.raw.recipe["kr-nitrogen"]
nitrogen.energy_required = 5 -- Down from 30
nitrogen.results = {
  {type = "fluid", name = "kr-nitrogen", amount = 45} -- Up from 30
}
data_util.disallow_efficiency("kr-nitrogen")

-- Cryo-condensation of Air
local cryo_air = table.deepcopy(data.raw.recipe["kr-nitrogen"])
cryo_air.name = "se-kr-liquid-air"
cryo_air.subgroup = "kr-atmosphere-condensation"
cryo_air.order = "a[condensing]-c[liquid-air]"
cryo_air.icon = data.raw.fluid["se-kr-liquid-air"].icon
cryo_air.icon_size = data.raw.fluid["se-kr-liquid-air"].icon_size
cryo_air.energy_required = 45
cryo_air.ingredients = {
  {type = "item", name = "se-cryonite-rod", amount = 10, ignored_by_stats = 9},
}
cryo_air.results = {
  {type = "fluid", name = "se-kr-liquid-air", amount = 3000},
  {type = "item", name = "se-cryonite-rod", amount = 9, ignored_by_stats = 9}
}
cryo_air.main_product = "se-kr-liquid-air"

-- Filtration of cryo condensed air
local air_filtration = table.deepcopy(data.raw.recipe["kr-quartz"])
air_filtration.name = "se-kr-liquid-purified-air"
air_filtration.subgroup = "kr-atmosphere-condensation"
air_filtration.order = "a[condensing]-d[purified-air]"
air_filtration.icon = data.raw.fluid["se-kr-liquid-purified-air"].icon
air_filtration.icon_size = data.raw.fluid["se-kr-liquid-purified-air"].icon_size
air_filtration.energy_required = 50
air_filtration.allow_productivity = true
air_filtration.ingredients = {
  {type = "fluid", name = "se-kr-liquid-air", amount = 2000},
  {type = "item", name = "se-cryonite-rod", amount = 10, ignored_by_stats = 9},
}
air_filtration.results = {
  {type = "fluid", name = "se-kr-liquid-purified-air", amount = 1250},
  {type = "item", name = "se-cryonite-rod", amount = 9, ignored_by_stats = 9, ignored_by_productivity = 9},
}
air_filtration.main_product = "se-kr-liquid-purified-air"

-- Seperation of gases from purified liquid air
local air_sep = table.deepcopy(data.raw.recipe["kr-nitric-acid"])
air_sep.name = "se-kr-air-separation"
air_sep.subgroup = "kr-atmosphere-condensation"
air_sep.order = "a[condensing]-e[air-separation]"
air_sep.icon = nil
air_sep.icon_size = nil
air_sep.icons = {
  {
    icon = "__space-exploration-graphics__/graphics/blank.png",
    icon_size = 64,
    scale = 0.5,
    shift = {0, 0},
  },
  {
    icon = data.raw.fluid["se-kr-liquid-purified-air"].icon,
    icon_size = data.raw.fluid["se-kr-liquid-purified-air"].icon_size,
    scale = 0.33,
    shift = {8, -8}
  },
  {
    icon = data.raw.fluid["kr-nitrogen"].icon,
    icon_size = data.raw.fluid["kr-nitrogen"].icon_size,
    scale = 0.25,
    shift = {-12,9},
  },
  {
    icon = data.raw.fluid["kr-oxygen"].icon,
    icon_size = data.raw.fluid["kr-oxygen"].icon_size,
    scale = 0.25,
    shift = {-4,9},
  },
  {
    icon = "__space-exploration-graphics__/graphics/icons/transition-arrow.png",
    icon_size = 64,
    scale = 0.5,
    shift = {0, 0},
  },
}
air_sep.energy_required = 10
air_sep.ingredients = {
  {type = "fluid", name = "se-kr-liquid-purified-air", amount = 120},
}
air_sep.results = {
  {type = "fluid", name = "kr-nitrogen", amount = 40},
  {type = "fluid", name = "kr-oxygen", amount = 20},
}
data:extend({cryo_air, air_filtration, air_sep})
data_util.disallow_efficiency("se-kr-liquid-air")

---- Ammonia
data_util.replace_or_add_ingredient("kr-ammonia","kr-hydrogen","kr-hydrogen",150,true)
data_util.replace_or_add_ingredient("kr-ammonia","kr-nitrogen","kr-nitrogen",50,true)
data_util.replace_or_add_result("kr-ammonia","kr-ammonia","kr-ammonia",35,true)
data_util.recipe_set_energy_required("kr-ammonia",14)

-- Iron catalysed Ammonia
local cat_ammonia = table.deepcopy(data.raw.recipe["kr-ammonia"])
cat_ammonia.name = "se-kr-cat-ammonia"
cat_ammonia.icon = nil
cat_ammonia.icons = data_util.add_icons_to_stack(
  nil, {
    {icon = data.raw.fluid["kr-ammonia"], properties = {scale = 1, offset = {0,0}, draw_background = true}},
    {icon = data.raw.item["iron-plate"], properties = {scale = 0.5, offset = {-0.3,-0.3}}}
  }
)
data:extend({cat_ammonia})
data_util.replace_or_add_ingredient("se-kr-cat-ammonia", "iron-plate", "iron-plate", 10)
data_util.replace_or_add_result("se-kr-cat-ammonia", "kr-ammonia", "kr-ammonia", 70, true)
data_util.recipe_set_energy_required("se-kr-cat-ammonia", 10)
data_util.tech_lock_recipes("kr-advanced-chemistry",{"se-kr-cat-ammonia"})

---- Hydrogen Chloride
data_util.replace_or_add_result("kr-hydrogen-chloride","kr-hydrogen-chloride","kr-hydrogen-chloride",35,true)
data_util.recipe_set_energy_required("kr-hydrogen-chloride",8)

-- Correct Salt Water Electrolysis gas production ratios
-- Original is 40 water for 20 chlorine and 30 hydrogen
local electrolysis = data.raw.recipe["kr-water-electrolysis"]
electrolysis.energy_required = 5 -- Up from 3
electrolysis.allow_productivity = false
electrolysis.results = {
  {type = "fluid", name = "kr-chlorine", amount = 20},
  {type = "fluid", name = "kr-hydrogen", amount = 20},
}
data_util.disallow_efficiency("kr-water-electrolysis") -- To avoid power generation from rocket fuel recipes

-- Catalysed Salt Water Electrolysis
local cat_elec = table.deepcopy(data.raw.recipe["kr-water-electrolysis"])
cat_elec.name = "se-kr-catalysed-water-electrolysis"
cat_elec.subgroup = "water"
cat_elec.icons = {
  {
    icon = "__Krastorio2Assets__/icons/recipes/water-electrolysis.png",
    icon_size = 128
  },
  {
    icon = data.raw.item["se-iridium-plate"].icon,
    icon_size = data.raw.item["se-iridium-plate"].icon_size,
    scale = 0.15,
    shift = {0,2}
  },
}
cat_elec.ingredients = {
  {type = "fluid", name = "water", amount = 400},
  {type = "item", name = "kr-sand", amount = 100},
  {type = "item", name = "se-iridium-plate", amount = 10, ignored_by_stats = 9},
}
cat_elec.results = {
  {type = "fluid", name = "kr-chlorine", amount = 200},
  {type = "fluid", name = "kr-hydrogen", amount = 200},
  {type = "item", name = "se-iridium-plate", amount = 9, ignored_by_stats = 9},
}
cat_elec.energy_required = 10
data:extend({cat_elec})
data_util.disallow_efficiency("se-kr-catalysed-water-electrolysis")

-- Correct Water Seperation gas production ratios
-- Original is 50 water for 20 oxygen and 40 hydrogen
local separation = data.raw.recipe["kr-water-separation"]
separation.energy_required = 4 -- Up from 3
separation.ingredients = {
  {type = "fluid", name = "water", amount = 60}
}
separation.results = {
  {type = "fluid", name = "kr-oxygen", amount = 20},
  {type = "fluid", name = "kr-hydrogen", amount = 40},
}
separation.allow_productivity = false
data_util.disallow_efficiency("kr-water-separation") -- To avoid power generation from rocket fuel recipes

-- Catalysed Water Seperation
local cat_sep = table.deepcopy(data.raw.recipe["kr-water-separation"])
cat_sep.name = "se-kr-catalysed-water-separation"
cat_sep.subgroup = "water"
cat_sep.icon = nil
cat_sep.icon_size = nil
cat_sep.icons = {
  {
    icon = "__Krastorio2Assets__/icons/recipes/water-separation.png",
    icon_size = 128
  },
  {
    icon = data.raw.item["se-iridium-plate"].icon,
    icon_size = data.raw.item["se-iridium-plate"].icon_size,
    scale = 0.15,
    shift = {0,2}
  },
}
cat_sep.energy_required = 8
cat_sep.ingredients = {
  {type = "fluid", name = "water", amount = 600},
  {type = "item", name = "se-iridium-plate", amount = 10, ignored_by_stats = 9},
}
cat_sep.results = {
  {type = "fluid", name = "kr-oxygen", amount = 200},
  {type = "fluid", name = "kr-hydrogen", amount = 400},
  {type = "item", name = "se-iridium-plate", amount = 9, ignored_by_stats = 9}
}
data:extend({cat_sep})
data_util.disallow_efficiency("se-kr-catalysed-water-separation")

-- Correct Water Creation consumption ratios
-- Original is 20 oxygen and 30 hydrogen for 50 water
local water = data.raw.recipe["kr-water"]
water.energy_required = 6
water.ingredients = {
  {type = "fluid", name = "kr-oxygen", amount = 20},
  {type = "fluid", name = "kr-hydrogen", amount = 40},
}
water.results = {
  {type = "fluid", name = "water", amount = 60}
}
water.allow_productivity = false

-- Remove Imersite Crystal to Imersite Powder recipe, it leads to loops and is unnecessary.
data_util.delete_recipe("kr-crush-kr-imersite-crystal")

-- Rebalance Coal Liquefaction to avoid creation of matter with Prod 9 modules
data.raw.recipe["coal-liquefaction"].ingredients = {
  {type = "item", name = "coal", amount = 10},
  {type = "fluid", name = "heavy-oil", amount = 25, ignored_by_stats = 25},
  {type = "fluid", name = "steam", amount = 50},
}
data.raw.recipe["coal-liquefaction"].results = {
  {type = "fluid", name = "heavy-oil", amount = 85, ignored_by_stats = 25, ignored_by_productivity = data.raw.recipe["coal-liquefaction"].allow_productivity and 25 or nil},
  {type = "fluid", name = "light-oil", amount = 20},
  {type = "fluid", name = "petroleum-gas", amount = 10},
}

-- Rebalance Used Fuel Cell Reprocessing to avoid creation of matter with Prod 9 modules
data_util.replace_or_add_result("nuclear-fuel-reprocessing", "uranium-238", "uranium-238", 5)
data_util.replace_or_add_result("nuclear-fuel-reprocessing", "stone", "stone",3)

-- Rebalance Lithium Chloride production to avoid chlorine creation with Prod 9 modules when making Lithium.
data_util.replace_or_add_ingredient("kr-lithium","kr-lithium-chloride","kr-lithium-chloride",10)
data_util.replace_or_add_ingredient("kr-lithium-chloride","kr-hydrogen-chloride","kr-hydrogen-chloride",25, true)

-- Vitamelange Bloom
data_util.replace_or_add_ingredient("se-vitamelange-bloom","kr-sand","kr-fertilizer",10)
data.raw.recipe["se-vitamelange-bloom"].category = "vita-growth"

-- swap recipe item icons to make steel ingots dark and iron ingots light
if data.raw.recipe["se-iron-ingot"] and data.raw.recipe["se-steel-ingot"] then
  data.raw.recipe["se-iron-ingot"].icons, data.raw.recipe["se-steel-ingot"].icons = data.raw.recipe["se-steel-ingot"].icons, data.raw.recipe["se-iron-ingot"].icons
end

-- Crack Methane to get Hydrogen
local cracking_methane = {
  type = "recipe",
  name = "kr-hydrogen", -- Despite this being a SEK2 specific recipe, if we want it to turn up as the main method for Hydrogen it must match the name
  localised_name = {"recipe-name.se-kr-methane-cracking"},
  category = "chemistry",
  subgroup = "oil",
  icons = {
    {icon = "__Krastorio2Assets__/icons/fluids/hydrogen.png", icon_size = 64},
  },
  ingredients = {
    {type = "item", name = "iron-plate", amount = 10},
    {type = "fluid", name = "se-methane-gas", amount = 100}
  },
  results = {
    {type = "item", name = "iron-plate", amount = 6},
    {type = "item", name = "steel-plate", amount = 1},
    {type = "fluid", name = "kr-hydrogen", amount = 50}
  },
  main_product = "kr-hydrogen",
  energy_required = 10,
  enabled = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  show_amount_in_title = true,
  order = "a[oil]-g[methane]-c[hydrogen]"
}
data:extend({cracking_methane})
data_util.recipe_require_tech("kr-hydrogen","se-processing-methane-ice")

