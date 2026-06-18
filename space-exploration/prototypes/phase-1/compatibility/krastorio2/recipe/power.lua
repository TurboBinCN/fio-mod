local data_util = require("data_util")

-- Rebalancing the K2 Fusion Reactor
-- 16720 Steam / 1672 Water to power 16 K2 Advanced Turbines, for an output of 1.6GW, pretty much the limit of efficiency for D-T Fusion.
data.raw.recipe["kr-fusion"].ingredients = {
  { type = "fluid", name = "water", amount = 1672},
  { type = "item", name = "kr-dt-fuel-cell", amount = 1 },
}
data.raw.recipe["kr-fusion"].results = {
  { type = "fluid", name = "steam", amount = 16720, temperature = 1625},
  { type = "item", name = "kr-empty-dt-fuel-cell", amount = 1 }
}

-- Adjust Pylon recipies to use Lithium-Sulfur batteries instead
data_util.replace_or_add_ingredient("se-pylon-substation","battery","kr-lithium-sulfur-battery",16)
data_util.replace_or_add_ingredient("se-pylon-construction","battery","kr-lithium-sulfur-battery",16)
data_util.replace_or_add_ingredient("se-pylon-construction-radar","battery","kr-lithium-sulfur-battery",16)

-- Adjust Holmium Accumulator item to require Lithium-Sulfur Batteries
data_util.replace_or_add_ingredient("se-space-accumulator",nil,"kr-energy-control-unit",2)

-- Increase cost Energy Storage recipe to account for now being the final accumulator
data.raw.recipe["kr-energy-storage"].ingredients = {
  {type = "item", name = "se-naquium-plate", amount = 20},
  {type = "item", name = "se-naquium-heat-pipe", amount = 10},
  {type = "item", name = "se-naquium-processor", amount = 4},
  {type = "item", name = "se-space-accumulator-2", amount = 10}
}

-- Adjust energy cost of biomethanol recipe to reduce total energy required for production of biomethanol
data_util.recipe_set_energy_required("kr-biomethanol",6)

local cat_biometh = table.deepcopy(data.raw.recipe["kr-biomethanol"])
cat_biometh.name = "se-kr-cat-biomethanol"
cat_biometh.icon = nil
cat_biometh.icons = data_util.add_icons_to_stack(
  nil, {
    {icon = data.raw.fluid["kr-biomethanol"], properties = {scale = 1, offset = {0,0}, draw_background = true}},
    {icon = data.raw.item["copper-plate"], properties = {scale = 0.5, offset = {-0.3,-0.3}}}
  }
)
data:extend({cat_biometh})
data_util.recipe_set_energy_required("se-kr-cat-biomethanol", 2)
data_util.replace_or_add_ingredient("se-kr-cat-biomethanol", nil, "copper-plate", 10)
data_util.replace_or_add_ingredient("se-kr-cat-biomethanol", "kr-oxygen", "kr-oxygen", 30, true)
data_util.tech_lock_recipes("kr-advanced-chemistry",{"se-kr-cat-biomethanol"})

-- Adjust costs of Flat Solar Panel
data_util.replace_or_add_ingredient("se-space-solar-panel","solar-panel","kr-advanced-solar-panel",1)
data_util.replace_or_add_ingredient("se-space-solar-panel", nil, "se-holmium-cable", 4)
data_util.replace_or_add_ingredient("se-space-solar-panel", nil, "se-holmium-plate", 4)

-- Flat Solar Panel 2
data_util.replace_or_add_ingredient("se-space-solar-panel-2", "se-holmium-plate", "se-holmium-solenoid", 2)
data_util.replace_or_add_ingredient("se-space-solar-panel-2", "se-space-mirror", "se-aeroframe-scaffold", 2)

-- K2 Antimatter (Renamed to Singularity)
-- Add Naquium products to K2 Antimatter processes
data_util.replace_or_add_ingredient("kr-antimatter-reactor", nil, "se-naquium-processor", 10)
data_util.replace_or_add_ingredient("kr-antimatter-reactor", nil, "se-naquium-plate", 350)
data_util.replace_or_add_ingredient("kr-antimatter-reactor", "steel-plate", "se-antimatter-reactor", 1)

-- K2 Fusion Reactor
data_util.replace_or_add_ingredient("kr-fusion-reactor", "processing-unit", "se-space-supercomputer-1", 1)
data_util.replace_or_add_ingredient("kr-fusion-reactor", "kr-steel-beam", "kr-steel-beam", 150)
data_util.replace_or_add_ingredient("kr-fusion-reactor", "concrete", "concrete", 500)
data_util.replace_or_add_ingredient("kr-fusion-reactor", "steel-plate", "steel-plate", 100)
data_util.replace_or_add_ingredient("kr-fusion-reactor", "copper-plate", "copper-plate", 100)
data_util.replace_or_add_ingredient("kr-fusion-reactor", "kr-rare-metals", "se-holmium-solenoid", 50)
data_util.replace_or_add_ingredient("kr-fusion-reactor", nil, "se-iridium-plate", 50)
data_util.replace_or_add_ingredient("kr-fusion-reacotr", nil, "se-space-pipe", 20)
data_util.replace_or_add_ingredient("kr-fusion-reactor", nil, "se-heat-shielding", 20)

-- K2 Advanced Steam Turbine
data_util.replace_or_add_ingredient("kr-advanced-steam-turbine", "kr-rare-metals", "se-holmium-solenoid", 10)
data_util.replace_or_add_ingredient("kr-advanced-steam-turbine", "kr-steel-beam", "steel-plate", 10)
data_util.replace_or_add_ingredient("kr-advanced-steam-turbine", "kr-steel-gear-wheel", "se-heavy-bearing", 10)

-- K2 Advanced Condenser Turbine
local adv_cons_turbine_recipe = table.deepcopy(data.raw.recipe["kr-advanced-steam-turbine"])
adv_cons_turbine_recipe.name = "se-kr-advanced-condenser-turbine"
adv_cons_turbine_recipe.icon = nil
adv_cons_turbine_recipe.icon_size = nil
adv_cons_turbine_recipe.icons = {
  {
    icon = data.raw.item["se-kr-advanced-condenser-turbine"].icon,
    icon_size = data.raw.item["se-kr-advanced-condenser-turbine"].icon_size,
  }
}
adv_cons_turbine_recipe.main_product = "se-kr-advanced-condenser-turbine"
data:extend({adv_cons_turbine_recipe})
data_util.replace_or_add_ingredient("se-kr-advanced-condenser-turbine", "steam-turbine", "se-condenser-turbine", 2)
data_util.replace_or_add_result("se-kr-advanced-condenser-turbine", "kr-advanced-steam-turbine", "se-kr-advanced-condenser-turbine", 1)

-- Advanced condenser turbine steam decompressing recipes
local steam_temperature_ranges = {
  951, -- Min
  1000,
  1100,
  1200,
  1300,
  1400,
  1500,
  1600,
  1624,
  1625 -- last one is accepted by previous temp is used internally
}
for i = 1, #steam_temperature_ranges - 1 do
  local low = steam_temperature_ranges[i]
  local high = steam_temperature_ranges[i+1]

  data:extend({
    {
      type = "recipe",
      name = "se-kr-advanced-condenser-turbine-reclaim-water-"..low.."-"..high,
      hidden = true,
      icons = {
        {icon = data.raw.item["kr-advanced-steam-turbine"].icon, scale = 0.5, icon_size = data.raw.item["kr-advanced-steam-turbine"].icon_size},
        {icon = data.raw.fluid["steam"].icon, scale = 0.375, icon_size = data.raw.fluid["steam"].icon_size},
      },
      order = "a-"..i,
      subgroup = "spaceship-process",
      energy_required = 0.1,
      category = "advanced-condenser-turbine",
      ingredients = {
        {
          type = "fluid",
          name = "steam",
          amount = 100,
          minimum_temperature = low - 1,
          maximum_temperature = (i == (#steam_temperature_ranges - 1)) and (high + 1) or (high - 1)
        },
      },
      results = {
        {type = "fluid", name = "water", amount = 9.9},
        {type = "fluid", name = "se-decompressing-steam", amount = 75, temperature = low},
      },
      hide_from_player_crafting = true,
      enabled = true,
      allow_as_intermediate = false,
      always_show_made_in = true,
      localised_name = {"", {"recipe-name.se-condenser-turbine-reclaim-water"}, " (", tostring(low), "°C)"}
    }
  })
end
