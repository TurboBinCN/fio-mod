local data_util = require("data_util")

data.raw.fluid["kr-hydrogen"].fuel_value = "50kJ"

-- Fine Imersite Powder
local fine_powder = {
  type = "item",
  name = "se-kr-fine-imersite-powder",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/fine-imersite-powder.png",
  icon_size = 64,
  group = "resources",
  subgroup = "kr-imersite",
  order = "a[kr-imersite]-e[fine-imersite-powder]-a[fine-imersite-powder]",
  stack_size = 100
}
data:extend({fine_powder})

-- Imersium Sulfide
local imersium_sulfide = {
  type = "fluid",
  name = "se-kr-imersium-sulfide",
  default_temperature = 25,
  heat_capacity = "0.1kJ",
  max_temperature = 100,
  base_color = {r=136 , g=10, b=95},
  flow_color = {r=248 , g=76, b=244},
  icon = "__space-exploration-graphics__/graphics/compatability/icons/imersium-sulfide.png",
  icon_size = 64,
  pressure_to_speed_ratio = 0.4,
  flow_to_energy_ratio = 0.59,
  auto_barrel = true,
  subgroup = "kr-imersite",
  order = "a[kr-imersite]-d[imersium-sulfide]-a[imersium-sulfide]"
}
data:extend({imersium_sulfide})

-- Create Iridium and Holmium specific Dirty Water
local dirty_ir_water = table.deepcopy(data.raw.fluid["kr-dirty-water"])
dirty_ir_water.name = "dirty-water-ir"
dirty_ir_water.subgroup = "iridium"
dirty_ir_water.order = "a[iridium]-d[iridium-powder]-b[dirty-water-ir]"
dirty_ir_water.base_color = { r = 0.80, g = 0.50, b = 0.20}
dirty_ir_water.flow_color = { r = 0.80, g = 0.50, b = 0.20}

local dirty_ho_water = table.deepcopy(data.raw.fluid["kr-dirty-water"])
dirty_ho_water.name = "dirty-water-ho"
dirty_ho_water.subgroup = "holmium"
dirty_ho_water.order = "a[holmium]-d[holmium-chloride]-b[dirty-water-ho]"
dirty_ho_water.base_color = { r = 0.80, g = 0.50, b = 0.20}
dirty_ho_water.flow_color = { r = 0.80, g = 0.50, b = 0.20}

data:extend({dirty_ir_water, dirty_ho_water})

local flare_stack_lib = require("__Krastorio2__/prototypes/libraries/flare-stack")
-- Tell K2 to give the new fluids a byproduct when voided
flare_stack_lib.add_byproduct("dirty-water-ir",{{type = "item", name = "stone", amount = 1, probability = 0.30}})
flare_stack_lib.add_byproduct("dirty-water-ho",{{type = "item", name = "stone", amount = 1, probability = 0.30}})

-- Also make the recipe as polluting as the base dirty water
flare_stack_lib.set_fluid_emissions_multiplier("dirty-water-ir",6.0)
flare_stack_lib.set_fluid_emissions_multiplier("dirty-water-ho",6.0)

-- swap item icons to make steel ingots dark and iron ingots light
if data.raw.item["se-steel-ingot"] and data.raw.item["se-iron-ingot"] then
  data.raw.item["se-steel-ingot"].icon, data.raw.item["se-iron-ingot"].icon = data.raw.item["se-iron-ingot"].icon, data.raw.item["se-steel-ingot"].icon
end

-- Create liquified air
local air_fluid_colour = {r = 158/255, g = 195/255, b = 255/255, a = 0.7}
local liquid_air = {
  type = "fluid",
  name = "se-kr-liquid-air",
  default_temperature = -230,
  heat_capacity = "0.24kJ",
  max_temperature = -196,
  base_color = air_fluid_colour,
  flow_color = air_fluid_colour,
  icon = "__space-exploration-graphics__/graphics/compatability/icons/liquid-air.png",
  icon_size = 64,
  order = "a[resource-fluid]-l1",
  pressure_to_speed_ratio = 0.5,
  flow_to_energy_ratio = 0.7,
  auto_barrel = true,
  subgroup = "kr-atmosphere-condensation",
}
data:extend({liquid_air})

local liquid_purified_air = table.deepcopy(data.raw.fluid["se-kr-liquid-air"])
liquid_purified_air.name = "se-kr-liquid-purified-air"
liquid_purified_air.base_color = {r = 158/255, g = 195/255, b = 255/255, a = 1}
liquid_purified_air.flow_color = {r = 158/255, g = 195/255, b = 255/255, a = 1}
liquid_purified_air.icon = "__space-exploration-graphics__/graphics/compatability/icons/liquid-purified-air.png"
liquid_purified_air.order = "a[resource-fluid]-l2"
data:extend({liquid_purified_air})

-- Code close aproximation of the generated K2 burn/void recipe
-- local burn_ir_water = {
--   type = "recipe",
--   name = "se-kr-burn-dirty-water-ir",
--   localised_name = {"recipe-name.kr-burn", {"fluid-name.dirty-water-ir"}},
--   localised_description = {"recipe-description.kr-burn-with-residue", {"fluid-name.dirty-water-ir"}, {"item-name.stone"}},
--   category = "fuel-burning",
--   icons = {
--     {
--       icon = "__Krastorio2Assets__/icons/burn-recipes-background/burn-recipe-corner.png",
--       icon_size = 64,
--     },
--     {
--       icon = "__Krastorio2Assets__/icons/burn-recipes-background/burn-recipe-corner-mask.png",
--       icon_size = 64,
--       tint = data_util.set_transparency(table.deepcopy(dirty_ir_water.base_color), 0.9),
--     },
--     {
--       icon = dirty_ir_water.icon,
--       icon_size = dirty_ir_water.icon_size or 64,
--       scale = 0.34,
--     }
--   },
--   crafting_machine_tint = {
--     primary = dirty_ir_water.base_color,
--     secondary = data_util.set_transparency(table.deepcopy(dirty_ir_water.base_color), 0.35),
--     tertiary = data_util.set_transparency(table.deepcopy(dirty_ir_water.flow_color), 0.5),
--     quaternary = data_util.set_transparency(table.deepcopy(dirty_ir_water.flow_color), 0.75)
--   },
--   energy_required = 2,
--   enabled = false,
--   hidden = true,
--   hide_from_player_crafting = true,
--   always_show_products = true,
--   show_amount_in_title = false,
--   ingredients = {
--     {type = "fluid", name = "dirty-water-ir", amount = 100},
--   },
--   results = {
--     {type = "item", name = "stone", amount = 1, probability = 0.30},
--   },
--   subgroup = "kr-void",
--   order = dirty_ir_water.order,
-- }
-- data:extend({burn_ir_water})
