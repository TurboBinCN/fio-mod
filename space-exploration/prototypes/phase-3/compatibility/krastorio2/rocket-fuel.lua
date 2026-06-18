local data_util = require("data_util")

-- This source is dedicated to enforcing the balance of the creation of Rocket Fuel within SE and K2

----------------------------------------------------------------------------------------------------------------------
-- Begin rocket fuel energy fixes
-- don't wrap the following changes in if statements, the entities are needed so if one is missing then there is a compatibility problem

data.raw.item["rocket-fuel"].fuel_value = "100MJ"
data.raw.item["rocket-fuel"].stack_size = 10

-- Remove Rocket Fuel from Water recipe
data_util.delete_recipe("se-rocket-fuel-from-water-copper")

-- Hydrogen comes from Electrolysis, Increase cost of the process.
-- Really increase the energy cost of the eletrolyser plant so that rocket fuel can't be used to make energy out of thin air.
local kr_electrolysis_plant = data.raw["assembling-machine"]["kr-electrolysis-plant"]
local kr_electrolysis_plant_spaced = data.raw["assembling-machine"]["kr-electrolysis-plant-spaced"]
kr_electrolysis_plant.energy_usage = "4000kW" --was 375kW
kr_electrolysis_plant.allowed_effects = data_util.all_effects_except("consumption")
kr_electrolysis_plant_spaced.energy_usage = "4000kW"
kr_electrolysis_plant_spaced.allowed_effects = data_util.all_effects_except("consumption", "productivity")
kr_electrolysis_plant.collision_mask.layers[space_collision_layer] = nil
kr_electrolysis_plant_spaced.collision_mask.layers[space_collision_layer] = nil
kr_electrolysis_plant.collision_mask.layers[spaceship_collision_layer] = nil
kr_electrolysis_plant_spaced.collision_mask.layers[spaceship_collision_layer] = nil
kr_electrolysis_plant.localised_description = {"entity-description.kr-electrolysis-plant"}
kr_electrolysis_plant_spaced.localised_description = {"space-exploration.structure_description_spaced", {"entity-description.kr-electrolysis-plant"}}

-- make sure that it can't use productivity (true by default)
--data.raw["assembling-machine"]["kr-electrolysis-plant"].allowed_effects = data_util.all_effects_except("productivity")

-- As we force oxygen into the recipes for rocket fuel, make sure the player has researched the way to collect oxygen first
data_util.tech_add_prerequisites("rocket-fuel",{"kr-atmosphere-condensation"})

-- Increase consumption of gaseous ingredients, add Oxygen and Hydrogen to Vulcanite recipe
-- Slightly increase consumption of gaseous ingredients, add Oxygen and Hydrogen to Vulcanite recipe
data_util.replace_or_add_ingredient("rocket-fuel", "light-oil", "light-oil", 10, true)
data_util.replace_or_add_ingredient("rocket-fuel", nil, "solid-fuel", 10)
data_util.replace_or_add_ingredient("rocket-fuel", "kr-oxygen", "kr-oxygen", 100, true)
data_util.set_craft_time("rocket-fuel", 2) -- Double the time of SE's rocket fuel, but SEK2's fuel refinery goes double speed

data_util.replace_or_add_ingredient("kr-rocket-fuel-with-ammonia", "kr-ammonia", "kr-ammonia", 100, true)
data_util.replace_or_add_ingredient("kr-rocket-fuel-with-ammonia", "kr-oxygen", "kr-oxygen", 120, true)
data_util.set_craft_time("kr-rocket-fuel-with-ammonia", 16)

data_util.replace_or_add_ingredient("kr-rocket-fuel-with-hydrogen-chloride", "kr-hydrogen-chloride", "kr-hydrogen-chloride", 75, true)
data_util.replace_or_add_ingredient("kr-rocket-fuel-with-hydrogen-chloride", "kr-oxygen", "kr-oxygen", 75, true)
data_util.set_craft_time("kr-rocket-fuel-with-hydrogen-chloride", 8)

data_util.replace_or_add_ingredient("se-vulcanite-rocket-fuel", nil, "iron-plate", 1)
data_util.replace_or_add_ingredient("se-vulcanite-rocket-fuel", "kr-oxygen", "kr-oxygen", 50, true)
data_util.set_craft_time("se-vulcanite-rocket-fuel", 2)

-- match the SE version to avoid infinite power exploits and cheap fuel
local fuel_refinery = data.raw["assembling-machine"]["kr-fuel-refinery"]
fuel_refinery.allowed_effects = data_util.all_effects()
fuel_refinery.crafting_speed = 1 -- Half of SE fuel refinery
fuel_refinery.energy_usage = "2500kW" -- Half of SE fuel refinery

fuel_refinery = data.raw["assembling-machine"]["kr-fuel-refinery-spaced"]
fuel_refinery.allowed_effects = data_util.all_effects_except("productivity")
fuel_refinery.crafting_speed = 1
fuel_refinery.energy_usage = "2500kW"
if not data_util.table_contains(fuel_refinery.crafting_categories, "fuel-refining") then
  table.insert(fuel_refinery.crafting_categories, "fuel-refining")
end
fuel_refinery.localised_description = {"space-exploration.structure_description_spaced", ""}
-- end rocket fuel energy fixes
----------------------------------------------------------------------------------------------------------------------
