
local se_fuel_refinery = data.raw["assembling-machine"]["se-fuel-refinery"]
local se_fuel_refinery_spaced = data.raw["assembling-machine"]["se-fuel-refinery-spaced"]
local kr_fuel_refinery = data.raw["assembling-machine"]["kr-fuel-refinery"]

-- Slightly better specification to start with
se_fuel_refinery.module_slots = 4
se_fuel_refinery.crafting_speed = 2
se_fuel_refinery.energy_usage = "5000kW" -- Bit more expensive energy-wise because of the "rocket fuel out of thin air" recipes.
se_fuel_refinery.localised_name = {"entity-name.se-kr-big-fuel-refinery"}

-- Give both fuel refineries the same recipe categories
table.insert(se_fuel_refinery.crafting_categories, "kr-fuel-refinery")
table.insert(kr_fuel_refinery.crafting_categories, "fuel-refining")

-- Update the spaced version of the SE Fuel Refinery
if se_fuel_refinery_spaced then
  se_fuel_refinery_spaced.module_slots = 4
  se_fuel_refinery_spaced.crafting_speed = 2
  se_fuel_refinery_spaced.energy_usage = "5000kW"
  se_fuel_refinery_spaced.localised_name = {"entity-name.se-kr-big-fuel-refinery"}

  table.insert(se_fuel_refinery_spaced.crafting_categories, "fuel-refinery")
end
