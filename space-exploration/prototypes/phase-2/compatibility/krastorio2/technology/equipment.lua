local data_util = require("data_util")

local function move_technology(tech_name, techs_to_add, ingredients_to_add, techs_to_remove, ingredients_to_remove)
  if ingredients_to_remove then
    data_util.tech_remove_ingredients(tech_name, ingredients_to_remove)
  end
  if techs_to_remove then
    data_util.tech_remove_prerequisites(tech_name, techs_to_remove)
  end
  if ingredients_to_add then
    data_util.tech_add_ingredients(tech_name, ingredients_to_add)
  end
  if techs_to_add then
    data_util.tech_add_prerequisites(tech_name, techs_to_add)
  end
end

local function move_to_specialist_science_packs(tech_name, science_packs, require_imersium)
  data_util.tech_remove_ingredients(tech_name, {"kr-optimization-tech-card", "kr-matter-tech-card", "kr-advanced-tech-card", "se-deep-space-science-pack-1"})
  data_util.tech_remove_prerequisites(tech_name, {"kr-optimization-tech-card", "kr-matter-tech-card", "kr-advanced-tech-card", "se-deep-space-science-pack-1"})
  data_util.tech_add_ingredients(tech_name, science_packs)
  data_util.tech_add_prerequisites(tech_name, science_packs)
  if require_imersium then
    data_util.tech_add_prerequisites(tech_name, {"kr-imersium-processing"})
  end
end


-- Shield Projector
data.raw.technology["shield-projector"].kr_check_science_packs_incompatibilities = false
data_util.tech_add_prerequisites("shield-projector",{"kr-advanced-tech-card"})
data_util.tech_add_ingredients("shield-projector",{"kr-advanced-tech-card"})

---- Shields
-- Clean up unused K2 alternate techs.
data.raw.technology["kr-energy-shield-mk3-equipment"] = nil
data.raw.technology["kr-energy-shield-mk4-equipment"] = nil

-- Portable Antimatter Reactor
data.raw.technology["kr-antimatter-reactor-equipment"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_ingredients("kr-antimatter-reactor-equipment", {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1"})
data_util.tech_remove_prerequisites("kr-antimatter-reactor-equipment", {"fission-reactor-equipment"})
data_util.tech_add_ingredients("kr-antimatter-reactor-equipment", {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-deep-space-science-pack-3","se-kr-matter-science-pack-2"})
data_util.tech_add_prerequisites("kr-antimatter-reactor-equipment", {"fission-reactor-equipment"})

-- Spidertron
data_util.tech_remove_prerequisites("spidertron", {"kr-ai-core", "kr-optimization-tech-card", "kr-matter-tech-card", "kr-advanced-tech-card", "se-deep-space-science-pack"})
move_to_specialist_science_packs("spidertron", {"se-biological-science-pack-1"})
data_util.tech_remove_prerequisite_recursive("spidertron", {"kr-fusion-reactor-equipment"})

local spidertron = data.raw["spider-vehicle"]["spidertron"]
spidertron.energy_source.fuel_categories = spidertron.energy_source.fuel_categories or {}
if spidertron.energy_source.fuel_categories then
  data_util.tech_add_prerequisites("spidertron", {"uranium-processing"})
  table.insert(spidertron.energy_source.fuel_categories, "nuclear")
end

data_util.tech_remove_ingredients("battery-mk2-equipment",{"utility-science-pack"})

data_util.tech_remove_prerequisites("refined-flammables-4",{"utility-science-pack"})
data_util.tech_remove_ingredients_recursive("refined-flammables-6", {"utility-science-pack"})

data_util.tech_remove_prerequisites("stronger-explosives-4",{"utility-science-pack"})
data_util.tech_remove_ingredients("stronger-explosives-4",{"utility-science-pack"})

---- Lifesupport 4 ----
data_util.tech_add_prerequisites("se-lifesupport-equipment-4", {"se-thruster-suit-4"})
data_util.tech_remove_prerequisites("se-lifesupport-equipment-4", {"se-naquium-tessaract"})
data_util.tech_add_ingredients("se-lifesupport-equipment-4", {"se-deep-space-science-pack-3"})

---- Weapon Shooting Speed ----
move_technology(
  "weapon-shooting-speed-2",
  {"military-2"},
  nil,
  {"logistic-science-pack"}
)

move_technology(
  "weapon-shooting-speed-3",
  {"defender"},
  nil,
  {"military-science-pack"}
)

move_technology(
  "weapon-shooting-speed-4",
  {"military-3"},
  nil,
  {"chemical-science-pack"}
)

move_technology(
  "weapon-shooting-speed-5",
  {"destroyer"},
  nil,
  {"space-science-pack"}
)

move_technology(
  "weapon-shooting-speed-6",
  {"se-railgun"},
  nil,
  {"se-material-science-pack-1"}
)

---- Laser Shooting Speed ----

move_technology(
  "laser-shooting-speed-1",
  {"laser-turret"},
  nil,
  {"military-science-pack"}
)

move_technology(
  "laser-shooting-speed-3",
  {"military-4"},
  nil,
  {"space-science-pack"}
)

move_technology(
  "laser-shooting-speed-5",
  {"se-space-laser-laboratory"},
  nil,
  {"utility-science-pack"}
)

move_technology(
  "laser-shooting-speed-6",
  {"kr-imersite-weapons"},
  nil,
  {"se-energy-science-pack-1"}
)

move_technology(
  "laser-shooting-speed-7",
  {"kr-personal-laser-defense-mk3-equipment"},
  nil,
  {"se-energy-science-pack-2"}
)
