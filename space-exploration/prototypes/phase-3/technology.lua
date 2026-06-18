local data_util = require("data_util")

data_util.tech_lock_recipes("rocket-fuel", {data_util.mod_prefix .."liquid-rocket-fuel"})

local function auto() return {"automation-science-pack", 1} end
local function logi() return {"logistic-science-pack", 1} end
local function chem() return {"chemical-science-pack", 1} end
local function mili() return {"military-science-pack", 1} end
local function util() return {"utility-science-pack", 1} end
local function prod() return {"production-science-pack", 1} end
local function rock() return {data_util.mod_prefix .. "rocket-science-pack", 1} end
local function spac() return {"space-science-pack", 1} end
local function deep() return {data_util.mod_prefix .."deep-space-science-pack-1", 1} end

--[[
data.raw.technology["logistic-science-pack"].icon = "__space-exploration-graphics__/graphics/technology/beaker/teal.png"
data.raw.technology["chemical-science-pack"].icon = "__space-exploration-graphics__/graphics/technology/beaker/cyan.png"
data.raw.technology["military-science-pack"].icon = "__space-exploration-graphics__/graphics/technology/beaker/grey.png"
data.raw.technology["production-science-pack"].icon = "__space-exploration-graphics__/graphics/technology/beaker/purple.png"
data.raw.technology["utility-science-pack"].icon = "__space-exploration-graphics__/graphics/technology/beaker/yellow.png"
data.raw.technology["space-science-pack"].icon = "__space-exploration-graphics__/graphics/technology/beaker/white.png"

data.raw.tool["automation-science-pack"].icon = "__space-exploration-graphics__/graphics/icons/beaker/red.png"
data.raw.tool["automation-science-pack"].icon_size = 64
data.raw.tool["logistic-science-pack"].icon = "__space-exploration-graphics__/graphics/icons/beaker/teal.png"
data.raw.tool["logistic-science-pack"].icon_size = 64
data.raw.tool["chemical-science-pack"].icon = "__space-exploration-graphics__/graphics/icons/beaker/cyan.png"
data.raw.tool["chemical-science-pack"].icon_size = 64
data.raw.tool["military-science-pack"].icon = "__space-exploration-graphics__/graphics/icons/beaker/grey.png"
data.raw.tool["military-science-pack"].icon_size = 64
data.raw.tool["production-science-pack"].icon = "__space-exploration-graphics__/graphics/icons/beaker/purple.png"
data.raw.tool["production-science-pack"].icon_size = 64
data.raw.tool["utility-science-pack"].icon = "__space-exploration-graphics__/graphics/icons/beaker/yellow.png"
data.raw.tool["utility-science-pack"].icon_size = 64
data.raw.tool["space-science-pack"].icon = "__space-exploration-graphics__/graphics/icons/beaker/white.png"
data.raw.tool["space-science-pack"].icon_size = 64
]]--

--data_util.tech_remove_prerequisites("space-science-pack", {"rocket-silo"})
--data_util.tech_add_prerequisites("space-science-pack", {data_util.mod_prefix .."space-science-lab"})
--data.raw.technology["space-science-pack"].prerequisites = {"production-science-pack", data_util.mod_prefix .. "processing-cryonite"}
--data.raw.technology["space-science-pack"].unit.ingredients = {auto(), logi(), chem(), prod()}
data.raw.technology["space-science-pack"].essential = true
data_util.tech_lock_recipes("space-science-pack", {"space-science-pack"})
data_util.tech_remove_ingredients("space-science-pack", {"utility-science-pack"})


data.raw.technology["utility-science-pack"].essential = true
data.raw.technology["utility-science-pack"].unit.count = 500
data.raw.technology["utility-science-pack"].prerequisites = {
  data_util.mod_prefix .. "space-supercomputer-1",
  data_util.mod_prefix .. "processing-cryonite",
  "efficiency-module"
}
data.raw.technology["utility-science-pack"].icons = {
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/deep-2.png", icon_size = 128},
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-2.png", icon_size = 128, tint = data_util.utility_science_tint},
}

data.raw.technology["production-science-pack"].essential = true
data.raw.technology["production-science-pack"].unit.count = 500
data.raw.technology["production-science-pack"].prerequisites = {
  data_util.mod_prefix .. "space-supercomputer-1",
  data_util.mod_prefix .. "space-plasma-generator",
  data_util.mod_prefix .. "pyroflux-smelting",
  "productivity-module"
}
data.raw.technology["production-science-pack"].icons = {
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/deep-2.png", icon_size = 128},
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-2.png", icon_size = 128, tint = data_util.production_science_tint},
}

local lab_names_to_not_remove_packs_from = {
  "space"
 ,"singularity"
 ,"kr-advanced-lab" -- K2 Advanced Lab that is in space thanks to compat work.
}

for _, lab in pairs(data.raw.lab) do
  lab.inputs = lab.inputs or {}
  local remove_packs = true
  for _, string in pairs(lab_names_to_not_remove_packs_from) do
    if string.find(lab.name, string, 1, true) then
      remove_packs = false
    end
  end
  if remove_packs then
    data_util.remove_from_table(lab.inputs, "utility-science-pack")
    data_util.remove_from_table(lab.inputs, "production-science-pack")
    data_util.remove_from_table(lab.inputs, "space-science-pack")
  end
  table.sort(lab.inputs, function(a,b) return data.raw.tool[a].order < data.raw.tool[b].order end)
end

data_util.tech_add_prerequisites("rocket-fuel", {"chemical-science-pack"})
data_util.tech_add_prerequisites("rocket-fuel", {data_util.mod_prefix .. "fuel-refining"})
data.raw.technology["rocket-fuel"].unit.ingredients = {auto(), logi(), chem()}
data_util.tech_lock_recipes("rocket-fuel", {data_util.mod_prefix .."liquid-rocket-fuel"})

data.raw.technology["rocket-silo"].unit.count = 500
data.raw.technology["rocket-silo"].unit.time = 30
data.raw.technology["rocket-silo"].unit.ingredients = {auto(), logi(), chem()}
data_util.tech_lock_recipes("rocket-silo", {"satellite"})
data.raw.technology['rocket-silo'].prerequisites = {
  "concrete", "electric-engine", "rocket-control-unit", "rocket-fuel", "solar-energy", "electric-energy-accumulators",
  "low-density-structure", data_util.mod_prefix .. "heat-shielding"
}

if data.raw.technology['radar'] then
  data_util.tech_add_prerequisites('rocket-silo', {'radar'})
  data.raw.technology['radar'].enabled = true
  data_util.tech_lock_recipes("radar", {"radar"})
end

data.raw.technology["rocket-control-unit"].unit.ingredients = {auto(), logi(), chem()}
data_util.tech_remove_prerequisites("rocket-control-unit", {"utility-science-pack", "speed-module", "speed-module-1"})
data_util.tech_add_prerequisites("rocket-control-unit", {"chemical-science-pack", "advanced-circuit", "battery"})

data_util.tech_add_prerequisites("basic-optics", {"glass-processing"})

data_util.tech_add_prerequisites("chemical-science-pack", {"engine"})  --optics was removed. why was it there?

data_util.tech_remove_prerequisites("advanced-material-processing-2", {"chemical-science-pack"})
data_util.tech_add_prerequisites("advanced-material-processing-2", {data_util.mod_prefix .. "heat-shielding"})

data_util.tech_remove_prerequisites("processing-unit", {"chemical-science-pack"})
data_util.tech_add_ingredients_with_prerequisites("processing-unit", {data_util.mod_prefix .. "rocket-science-pack"})

-- modify military tech so military-4 uses rocket science so it continues to be the next unlock after military-3
-- in vanilla it goes military-3 (chem) to military-4 (utility) so for SE we need it to be military-3 (chem) to military-4 (rocket)
do
  data_util.tech_remove_prerequisites("military-4", {"utility-science-pack"})
  data_util.tech_remove_ingredients("military-4", {"utility-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("military-4", {data_util.mod_prefix .. "rocket-science-pack"})

  data_util.tech_remove_prerequisites("destroyer", {"utility-science-pack"})
  data_util.tech_remove_ingredients("destroyer", {"utility-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("destroyer", {"space-science-pack"})

  data_util.tech_remove_prerequisites("uranium-ammo", {"utility-science-pack"})
  data_util.tech_remove_ingredients("uranium-ammo", {"utility-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("uranium-ammo", {"space-science-pack"})

  data_util.tech_remove_prerequisites("nuclear-fuel-reprocessing", {"production-science-pack"})
  data_util.tech_remove_ingredients("nuclear-fuel-reprocessing", {"production-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("nuclear-fuel-reprocessing", {"space-science-pack"})

  data_util.tech_remove_prerequisites("artillery", {"utility-science-pack"})
  data_util.tech_remove_ingredients("artillery", {"utility-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("artillery", {"space-science-pack"})

  data_util.tech_add_prerequisites("power-armor-mk2", {"utility-science-pack"})

  -- atomic bomb is a reward for going down the production science path
  -- thematically it matches with the other uranium rewards of production science
  data_util.tech_remove_prerequisites("atomic-bomb", {"utility-science-pack"})
  data_util.tech_remove_ingredients("atomic-bomb", {"utility-science-pack"})
end

-- modify tier 3 logistics and tier 3 automation to unlock after rocket science instead of utility science
-- this keeps the progression of vanilla where they unlock after getting the next science pack after blue/chem
do
  data.raw.technology["automation-3"].prerequisites = {data_util.mod_prefix .. "space-assembling", "space-science-pack"}
  -- data_util.tech_remove_prerequisites("automation-3", {"production-science-pack"}) -- quez: commented out due to the line above
  data_util.tech_remove_ingredients("automation-3", {"utility-science-pack", "production-science-pack"})
  data_util.tech_add_ingredients("automation-3", {"space-science-pack"})

  data.raw.technology["logistics-3"].prerequisites = {data_util.mod_prefix .. "space-belt", "space-science-pack"}
  -- data_util.tech_remove_prerequisites("logistics-3", {"production-science-pack"}) -- quez: commented out due to the line above
  data_util.tech_remove_ingredients("logistics-3", {"utility-science-pack", "production-science-pack"})
  data_util.tech_add_ingredients("logistics-3", {"space-science-pack"})

  if mods["aai-loaders"] then
    data_util.tech_remove_prerequisites("aai-express-loader", {"production-science-pack"})
    data_util.tech_remove_ingredients("aai-express-loader", {"production-science-pack"})
    data_util.tech_add_ingredients("aai-express-loader", {"space-science-pack"})
  end
end

-- prevent other mods from putting logistic robots before chemical science
data_util.tech_add_ingredients("logistic-robotics", { "chemical-science-pack"})

-- separate out the centrifuge unlock from uranium processing into its own tech because the centrifuge now
-- is used for more than just uranium processing
do
  data_util.tech_remove_prerequisites("uranium-processing", {"chemical-science-pack", "concrete"})
  data_util.tech_add_prerequisites("uranium-processing", {data_util.mod_prefix .. "centrifuge"})
  data_util.tech_remove_effects("uranium-processing", {{
    type = "unlock-recipe",
    recipe = "centrifuge"
  }})
  data.raw.item["centrifuge"].icon = "__space-exploration-graphics__/graphics/icons/centrifuge.png"
  data.raw["assembling-machine"]["centrifuge"].icon = "__space-exploration-graphics__/graphics/icons/centrifuge.png"
  data_util.tech_add_ingredients("uranium-processing", { data_util.mod_prefix .. "rocket-science-pack"}, true)
end

do
  data_util.tech_remove_prerequisites("uranium-mining", {"chemical-science-pack", "concrete"})
  data_util.tech_add_prerequisites("uranium-mining", {data_util.mod_prefix .. "centrifuge"})
  data_util.tech_add_ingredients("uranium-mining", { data_util.mod_prefix .. "rocket-science-pack"}, true)
end



data_util.tech_remove_prerequisites("nuclear-power", {"steam-power"})
data_util.tech_add_prerequisites("nuclear-power", {"steam-turbine"})
data_util.tech_remove_effects("nuclear-power", {{type = "unlock-recipe", recipe = "steam-turbine"}})
data_util.tech_add_ingredients("nuclear-power", { data_util.mod_prefix .. "rocket-science-pack"}, true)

-- all beacon unlocks are put behind production science (i.e. the basic beacon and any modded children of the basic beacon)
do
  data_util.tech_add_prerequisites("effect-transmission", { "production-science-pack"})
  data_util.tech_add_ingredients("effect-transmission", { "production-science-pack"}, true)
end

--data_util.tech_add_ingredients_with_prerequisites("modular-armor", {"chemical-science-pack"})
--data_util.tech_add_ingredients_with_prerequisites("power-armor", {"utility-science-pack"})
--data_util.tech_add_prerequisites("power-armor-mk2", {data_util.mod_prefix.."processing-iridium"})
--data_util.tech_add_ingredients("power-armor-mk2", { "space-science-pack"}, true)

data_util.tech_remove_prerequisites("battery-mk2-equipment", {"utility-science-pack"})
data_util.tech_add_prerequisites("battery-mk2-equipment", {data_util.mod_prefix .. "space-accumulator"})
data_util.tech_add_ingredients("battery-mk2-equipment", { "space-science-pack", "utility-science-pack", "production-science-pack", data_util.mod_prefix .. "material-science-pack-2", data_util.mod_prefix .. "energy-science-pack-1"}, true)

data_util.tech_add_prerequisites("personal-roboport-mk2-equipment", {"utility-science-pack"})
data_util.tech_add_ingredients("personal-roboport-mk2-equipment", { "utility-science-pack"}, true)

data_util.tech_lock_recipes(data_util.mod_prefix.."fuel-refining", {"solid-fuel-from-heavy-oil", "solid-fuel-from-light-oil", "solid-fuel-from-petroleum-gas"})

data_util.tech_remove_prerequisites("spidertron", {"fission-reactor-equipment", "efficiency-module-3"})
data_util.tech_add_prerequisites("spidertron", {
  data_util.mod_prefix .. "biological-science-pack-1",
  data_util.mod_prefix .. "heavy-girder",
  data_util.mod_prefix .. "rtg-equipment"})
data_util.tech_add_ingredients("spidertron", { "space-science-pack", data_util.mod_prefix .. "biological-science-pack-1", data_util.mod_prefix .. "material-science-pack-1"}, true)
data_util.tech_remove_ingredients("spidertron", { "utility-science-pack"})
if data.raw.technology.spidertron then
  data.raw.technology.spidertron.unit.count = 1000
end

-- modify infinite techs to respect that SE switches the ordering of space science (aka rocket science) and utility/production science
do
  -- worker robot storage is production science only
  data_util.tech_add_ingredients_with_prerequisites("worker-robots-storage-1", {data_util.mod_prefix .. "rocket-science-pack"})
  data_util.tech_add_ingredients("worker-robots-storage-2", {"space-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("worker-robots-storage-3",  {data_util.mod_prefix .. "material-science-pack-1"})
  data_util.tech_remove_ingredients_recursive("worker-robots-storage-3", {"utility-science-pack"})
  data_util.tech_remove_prerequisites("worker-robots-storage-3", {"utility-science-pack"})

  -- worker robot speed is utility science only
  data_util.tech_remove_ingredients_recursive("worker-robots-speed-6", {"production-science-pack"})
  data_util.tech_remove_ingredients("worker-robots-speed-3", {"utility-science-pack"})
  data_util.tech_remove_prerequisites("worker-robots-speed-3", {"utility-science-pack"})
  data_util.tech_add_ingredients("worker-robots-speed-3", {"space-science-pack"})
  data_util.tech_add_prerequisites("worker-robots-speed-3", {"space-science-pack"})
  data_util.tech_remove_ingredients("worker-robots-speed-4", {"utility-science-pack"})
  data_util.tech_add_ingredients("worker-robots-speed-4", {"space-science-pack"})
  data_util.tech_remove_prerequisites("worker-robots-speed-5", {"production-science-pack"})
  data_util.tech_add_ingredients("worker-robots-speed-5", {"space-science-pack"})
  data_util.tech_add_prerequisites("worker-robots-speed-5", {"utility-science-pack"})

  -- laser weapon damage should have some unlocks at rocket science
  data_util.tech_add_ingredients("laser-weapons-damage-3", {"space-science-pack"})
  data_util.tech_add_prerequisites("laser-weapons-damage-3", {"space-science-pack"})
  data_util.tech_add_ingredients("laser-weapons-damage-4", {"space-science-pack"})
  data_util.tech_remove_prerequisites("laser-weapons-damage-7", {"space-science-pack"})

  -- follower robot count is production science only - 1.1 aligned
  data_util.tech_split_at_levels("follower-robot-count", {6, 7, 8, 9, 10})
  data_util.tech_remove_ingredients("follower-robot-count-4", {data_util.mod_prefix .. "rocket-science-pack","space-science-pack"})
  data_util.tech_remove_prerequisites("follower-robot-count-4", {"destroyer"})
  data_util.tech_add_prerequisites("follower-robot-count-5", {"destroyer","production-science-pack"})
  data_util.tech_remove_ingredients_recursive("follower-robot-count-6", {"utility-science-pack"})
  data_util.tech_add_prerequisites("follower-robot-count-7", {"utility-science-pack"})

  -- for i=1,10 do
  --   log("EDW: Tech follower-robot-count-"..i.." exists: "..(data.raw.technology["follower-robot-count-"..i] and "true" or "false"))
  -- end

  -- stronger explosives is production science only - 1.1 aligned
  data_util.tech_add_ingredients_with_prerequisites("stronger-explosives-4", {"space-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("stronger-explosives-5", {"production-science-pack"})
  data_util.tech_remove_ingredients_recursive("stronger-explosives-6", {"utility-science-pack"})
  data_util.tech_remove_prerequisite_recursive("stronger-explosives-6", {"utility-science-pack"})
  data_util.tech_add_prerequisites("stronger-explosives-7", {"utility-science-pack"})

  -- refined flamables is production science only - 1.1 aligned
  data_util.tech_add_ingredients_with_prerequisites("refined-flammables-4", {"space-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("refined-flammables-5", {"production-science-pack"})
  data_util.tech_remove_ingredients_recursive("refined-flammables-6", {"utility-science-pack"})
  data_util.tech_remove_prerequisite_recursive("refined-flammables-6", {"utility-science-pack"})
  data_util.tech_add_prerequisites("refined-flammables-7", {"utility-science-pack"})
  data_util.tech_remove_prerequisites("refined-flammables-7", {"space-science-pack"})

  -- laser shooting speed
  data_util.tech_add_ingredients_with_prerequisites("laser-shooting-speed-3", {"space-science-pack"})
  data_util.tech_add_ingredients("laser-shooting-speed-4", {"space-science-pack"})

  -- artillery shell range
  data_util.tech_add_prerequisites("artillery-shell-range-1", {"utility-science-pack"})

  -- mining productivity is production science only
  data_util.tech_remove_ingredients("mining-productivity-3", {"utility-science-pack", "production-science-pack"})
  data_util.tech_remove_prerequisites("mining-productivity-3", {"utility-science-pack", "production-science-pack"})
  data_util.tech_remove_ingredients("mining-productivity-4", {"utility-science-pack"})
  data_util.tech_split_at_levels("mining-productivity", {4, 5, 6, 7, 8, 9, 10, 11, 12, 13})
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-3", {"space-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-4", {"production-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-6", {data_util.mod_prefix .. "biological-science-pack-1"})
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-7", {data_util.mod_prefix .. "biological-science-pack-2"})
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-8", {data_util.mod_prefix .. "biological-science-pack-3"})
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-9", {data_util.mod_prefix .. "biological-science-pack-4"})
  data_util.tech_add_ingredients("mining-productivity-10", { data_util.mod_prefix .. "biological-science-pack-4" }, true)
  data_util.tech_add_ingredients("mining-productivity-11", { data_util.mod_prefix .. "biological-science-pack-4" }, true)
  data_util.tech_add_ingredients("mining-productivity-12", { data_util.mod_prefix .. "biological-science-pack-4" }, true)
  data_util.tech_add_ingredients("mining-productivity-13", { data_util.mod_prefix .. "biological-science-pack-4" }, true)
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-10", {data_util.mod_prefix .. "deep-space-science-pack-1"})
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-11", {data_util.mod_prefix .. "deep-space-science-pack-2"})
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-12", {data_util.mod_prefix .. "deep-space-science-pack-3"})
  data_util.tech_add_ingredients_with_prerequisites("mining-productivity-13", {data_util.mod_prefix .. "deep-space-science-pack-4"})

  -- research speed is utility science only
  data_util.tech_remove_ingredients_recursive("research-speed-6", {"production-science-pack"})
  data_util.tech_remove_prerequisite_recursive("research-speed-6", {"production-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("research-speed-4", {"space-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("research-speed-5", {"utility-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("research-speed-6", {data_util.mod_prefix .. "energy-science-pack-1"})

  -- inserter capacity bonus is production science only
  data_util.tech_remove_ingredients_recursive("inserter-capacity-bonus-7", {"utility-science-pack"})
  data_util.tech_remove_prerequisite_recursive("inserter-capacity-bonus-7", {"utility-science-pack"})
  data_util.tech_remove_ingredients("inserter-capacity-bonus-4", {"production-science-pack"})
  data_util.tech_remove_prerequisites("inserter-capacity-bonus-4", {"production-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("inserter-capacity-bonus-4", {"space-science-pack"})
  data_util.tech_add_ingredients("inserter-capacity-bonus-5", {"space-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("inserter-capacity-bonus-5", {"production-science-pack"})
  data_util.tech_add_ingredients_with_prerequisites("inserter-capacity-bonus-6", {data_util.mod_prefix .. "material-science-pack-1"})
  data_util.tech_add_ingredients_with_prerequisites("inserter-capacity-bonus-7", {data_util.mod_prefix .. "material-science-pack-2"})

  -- physical projectile damage
  data_util.tech_remove_prerequisites("physical-projectile-damage-7", {"space-science-pack"})

  -- artillery shell shooting speed
  data_util.tech_add_prerequisites("artillery-shell-speed-1", {"utility-science-pack"})
  data_util.tech_remove_prerequisites("stronger-explosives-7", {"space-science-pack"})
end

-- put a toolbelt unlock at just rocket science
data_util.tech_remove_prerequisites("toolbelt-4", {"utility-science-pack"})
data_util.tech_remove_ingredients("toolbelt-4", {"utility-science-pack"})
data_util.tech_add_ingredients_with_prerequisites("toolbelt-4", {"space-science-pack"})
data_util.tech_remove_prerequisites("toolbelt-5", {"utility-science-pack"})
data_util.tech_remove_ingredients("toolbelt-5", {"utility-science-pack"})
data_util.tech_remove_prerequisites("toolbelt-6", {"utility-science-pack"})
data_util.tech_remove_ingredients("toolbelt-6", {"utility-science-pack"})
data_util.tech_add_ingredients_with_prerequisites("toolbelt-6", {data_util.mod_prefix .. "material-science-pack-1"})

data_util.tech_add_prerequisites("jetpack-2", { "space-science-pack"})
data_util.tech_add_prerequisites("jetpack-3", { data_util.mod_prefix .. "aeroframe-pole"})
data_util.tech_add_prerequisites("jetpack-4", { data_util.mod_prefix .. "naquium-cube"})
data_util.tech_add_ingredients_with_prerequisites("jetpack-2", {"space-science-pack"})
data_util.tech_add_ingredients_with_prerequisites("jetpack-3", {data_util.mod_prefix .. "astronomic-science-pack-1"})
data_util.tech_add_ingredients_with_prerequisites("jetpack-4", {data_util.mod_prefix .. "astronomic-science-pack-4", data_util.mod_prefix .. "material-science-pack-4", data_util.mod_prefix .. "energy-science-pack-4", data_util.mod_prefix .. "biological-science-pack-4", data_util.mod_prefix .. "deep-space-science-pack-1"})

if not data.raw.technology["industrial-furnace"] then error("Mod conflict, industrial-furnace tech is missing.") end
data_util.tech_remove_ingredients_recursive("industrial-furnace", {"production-science-pack"})
data_util.tech_remove_prerequisites("industrial-furnace", {"production-science-pack"})
data_util.tech_add_prerequisites("industrial-furnace", { "advanced-material-processing-2"})
data_util.tech_add_ingredients_with_prerequisites("industrial-furnace", {"space-science-pack"})
data.raw.technology["industrial-furnace"].unit.count = 100

if data.raw.technology["electric-mining-drill"] and not data.raw.technology["electric-mining-drill"].enabled == false then
  data_util.tech_add_prerequisites(data_util.mod_prefix .. "core-miner", {"electric-mining-drill"})
end
