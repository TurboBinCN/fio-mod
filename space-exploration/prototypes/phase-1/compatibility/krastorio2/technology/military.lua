local data_util = require("data_util")

local function move_to_specialist_science_packs(tech_name, science_packs, require_imersium)
  data_util.tech_remove_ingredients(tech_name, {"kr-optimization-tech-card", "kr-matter-tech-card", "kr-advanced-tech-card", "se-deep-space-science-pack-1"})
  data_util.tech_remove_prerequisites(tech_name, {"kr-optimization-tech-card", "kr-matter-tech-card", "kr-advanced-tech-card", "se-deep-space-science-pack-1"})
  data_util.tech_add_ingredients(tech_name, science_packs)
  data_util.tech_add_prerequisites(tech_name, science_packs)
  if require_imersium then
    data_util.tech_add_prerequisites(tech_name, {"kr-imersium-processing"})
  end
end


-- Military 4
data_util.tech_add_prerequisites("military-4",{"se-rocket-science-pack"})

-- Military 5
data_util.tech_add_prerequisites("kr-military-5",{"utility-science-pack"})

-- Laser Artillery Turret
move_to_specialist_science_packs("kr-laser-artillery-turret", {"se-energy-science-pack-2"})
data_util.tech_add_ingredients("kr-laser-artillery-turret", {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack"})
data_util.tech_add_prerequisites("kr-laser-artillery-turret", {"se-holmium-solenoid", "se-heavy-girder"})

-- Railgun Turret
data_util.tech_add_ingredients("kr-railgun-turret", {"automation-science-pack", "logistic-science-pack", "chemical-science-pack"})

-- Rocket Turret
data.raw.technology["kr-rocket-turret"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-rocket-turret",{"kr-advanced-tech-card"})
data_util.tech_remove_ingredients("kr-rocket-turret",{"kr-advanced-tech-card","utility-science-pack"})
data_util.tech_add_prerequisites("kr-rocket-turret",{"se-heavy-girder"})
data_util.tech_add_ingredients("kr-rocket-turret", {"automation-science-pack", "logistic-science-pack", "chemical-science-pack","kr-optimization-tech-card","se-material-science-pack-1"})

-- Artillery Shell Upgrades
data_util.tech_add_prerequisites("artillery-shell-range-1", {"utility-science-pack"})
data_util.tech_add_prerequisites("artillery-shell-speed-1", {"utility-science-pack"})

-- Account for Advanced Radar option from K2
if data.raw.technology["kr-advanced-radar"] then
  data_util.tech_add_prerequisites("kr-advanced-radar", {"chemical-science-pack"})
  data_util.tech_add_ingredients("kr-advanced-radar", {"chemical-science-pack"})
end

-- Seperate Imersite Weapons away from K2 Military Tech 5 into new Imersite Weapons tech
if data.raw.technology["kr-military-5"] then
  local tech = table.deepcopy(data.raw.technology["kr-military-5"])
  tech.name = "kr-imersite-weapons"
  tech.effects = {}
  tech.prerequisites = {
    "kr-military-5",
    "kr-optimization-tech-card",
    "se-energy-science-pack-1",
    "se-material-science-pack-1",
  }
  tech.unit.ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"military-science-pack", 1},
    {"se-rocket-science-pack", 1},
    {"space-science-pack", 1},
    {"kr-optimization-tech-card", 1},
    {"se-energy-science-pack-1", 1},
    {"se-material-science-pack-1", 1}
  }
  tech.kr_check_science_packs_incompatibilities = false
  data:extend({tech})
  data_util.tech_lock_recipes("kr-imersite-weapons", {"kr-impulse-rifle", "kr-impulse-rifle-ammo", "kr-imersite-rifle-magazine", "kr-imersite-anti-materiel-rifle-magazine"})
end

-- Remove Quarry Mineral Extraction as a requirement from Military 5 as no unlocks require it
data_util.tech_remove_prerequisites("kr-military-5", {"kr-quarry-minerals-extraction"})

-- Power Armour Mk3
data.raw.technology["kr-power-armor-mk3"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_ingredients("kr-power-armor-mk3", {"kr-advanced-tech-card"})
data_util.tech_remove_prerequisites("kr-power-armor-mk3", {"kr-advanced-tech-card"})
data_util.tech_add_ingredients("kr-power-armor-mk3", {"automation-science-pack","logistic-science-pack","military-science-pack","chemical-science-pack","production-science-pack","space-science-pack","se-material-science-pack-1","se-energy-science-pack-1"})
data_util.tech_add_prerequisites("kr-power-armor-mk3", {"se-material-science-pack-1","se-energy-science-pack-1"})

--Power Armour Mk4
data.raw.technology["kr-power-armor-mk4"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_ingredients("kr-power-armor-mk4", {"kr-optimization-tech-card","kr-singularity-tech-card"})
data_util.tech_remove_prerequisites("kr-power-armor-mk4", {"kr-singularity-tech-card"})
data_util.tech_add_ingredients("kr-power-armor-mk4", {"automation-science-pack","logistic-science-pack","military-science-pack","chemical-science-pack","production-science-pack","space-science-pack","se-material-science-pack-3","se-energy-science-pack-3"})
data_util.tech_add_prerequisites("kr-power-armor-mk4", {"kr-advanced-tech-card"})

-- Thruster Suit 3
data_util.tech_remove_ingredients("se-thruster-suit-3", {"se-biological-science-pack-1"})
data_util.tech_add_ingredients("se-thruster-suit-3", {"kr-advanced-tech-card","se-biological-science-pack-3"})
data_util.tech_add_prerequisites("se-thruster-suit-3", {"kr-advanced-tech-card"})

-- Adaptive Armor 4
data_util.tech_add_prerequisites("se-adaptive-armour-equipment-4", {"kr-imersium-processing"})

-- Adaptive Armor 5
data_util.tech_add_prerequisites("se-adaptive-armour-equipment-5", {"kr-advanced-tech-card"})
data_util.tech_add_ingredients("se-adaptive-armour-equipment-5", {"kr-advanced-tech-card"})

-- For K2 make the first medpack only require the basic tech card
if data.raw.tool["kr-basic-tech-card"] then
  data_util.tech_remove_ingredients("se-medpack", {"automation-science-pack"})
  data_util.tech_add_ingredients("se-medpack", {"kr-basic-tech-card"})
  data.raw.technology["se-medpack"].prerequisites = {}
end

-- Biter Virus capsule
data_util.tech_remove_ingredients("kr-biter-virus", {"kr-advanced-tech-card", "kr-matter-tech-card"})
data_util.tech_add_prerequisites("kr-biter-virus", {"se-capsule-big-biter", "se-capsule-big-spitter"})
data_util.tech_add_ingredients("kr-biter-virus", {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack","se-biological-science-pack-3"})

-- Personal Laser Defence Mk3
data.raw.technology["kr-personal-laser-defense-mk3-equipment"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_ingredients("kr-personal-laser-defense-mk3-equipment", {"kr-advanced-tech-card"})
data_util.tech_remove_prerequisites("kr-personal-laser-defense-mk3-equipment", {"kr-advanced-tech-card"})
data_util.tech_add_ingredients("kr-personal-laser-defense-mk3-equipment", {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","production-science-pack","kr-optimization-tech-card","space-science-pack","se-energy-science-pack-2"})
data_util.tech_add_prerequisites("kr-personal-laser-defense-mk3-equipment", {"se-energy-science-pack-2"})

-- Personal Laser Defense Mk4
data.raw.technology["kr-personal-laser-defense-mk4-equipment"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_ingredients("kr-personal-laser-defense-mk4-equipment", {"kr-singularity-tech-card","kr-optimization-tech-card"})
data_util.tech_remove_prerequisites("kr-personal-laser-defense-mk4-equipment", {"kr-singularity-tech-card"})
data_util.tech_add_ingredients("kr-personal-laser-defense-mk4-equipment", {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","production-science-pack","space-science-pack","se-energy-science-pack-4"})
data_util.tech_add_prerequisites("kr-personal-laser-defense-mk4-equipment", {"kr-advanced-tech-card","se-energy-science-pack-4"})

-- Advanced Exoskeleton
data_util.tech_add_prerequisites("kr-advanced-exoskeleton-equipment", {"production-science-pack"})
data_util.tech_add_ingredients("kr-advanced-exoskeleton-equipment", {"production-science-pack"})

-- Superiror Exoskeleton
data.raw.technology["kr-superior-exoskeleton-equipment"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-superior-exoskeleton-equipment", {"kr-advanced-tech-card"})
data_util.tech_remove_ingredients("kr-superior-exoskeleton-equipment", {"kr-advanced-tech-card"})
data_util.tech_add_prerequisites("kr-superior-exoskeleton-equipment", {"production-science-pack","se-aeroframe-scaffold","se-heavy-bearing","speed-module-5"})
data_util.tech_add_ingredients("kr-superior-exoskeleton-equipment", {"automation-science-pack","logistic-science-pack","chemical-science-pack","production-science-pack","se-astronomic-science-pack-2","se-material-science-pack-2"})

-- Imersite Nightvision
data_util.tech_add_prerequisites("kr-superior-night-vision-equipment", {"production-science-pack","space-science-pack"})
data_util.tech_add_ingredients("kr-superior-night-vision-equipment", {"production-science-pack","space-science-pack"})

-- Tank
data_util.tech_remove_prerequisites("kr-advanced-tank", {"kr-advanced-tech-card","kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-advanced-tank", {"kr-advanced-tech-card","kr-matter-tech-card"})
data_util.tech_add_prerequisites("kr-advanced-tank", {"se-heavy-bearing","kr-energy-control-unit","se-holmium-solenoid"})
data_util.tech_add_ingredients("kr-advanced-tank", {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-energy-science-pack-2","se-material-science-pack-2"}, true)
