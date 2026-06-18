local data_util = require("data_util")

-- SE makes all it's changes to Energy Shield Equipment in phase-3 so we make our changes here
data_util.tech_add_prerequisites("energy-shield-equipment",{"se-adaptive-armour-3"})

data_util.tech_add_prerequisites("energy-shield-mk2-equipment",{"kr-optimization-tech-card"})
data_util.tech_add_ingredients("energy-shield-mk2-equipment",{"kr-optimization-tech-card"})
data.raw.technology["energy-shield-mk2-equipment"].unit.count = 300

data_util.tech_add_ingredients("energy-shield-mk3-equipment",{"kr-optimization-tech-card"})
data.raw.technology["energy-shield-mk3-equipment"].unit.count = 700

data_util.tech_add_ingredients("energy-shield-mk4-equipment",{"kr-optimization-tech-card"})
data.raw.technology["energy-shield-mk4-equipment"].unit.count = 1200

data_util.tech_add_prerequisites("energy-shield-mk5-equipment",{"kr-advanced-tech-card","kr-matter-tech-card"})
data_util.tech_add_ingredients("energy-shield-mk5-equipment",{"kr-advanced-tech-card","kr-matter-tech-card"})
data.raw.technology["energy-shield-mk5-equipment"].unit.count = 2400

data_util.tech_add_prerequisites("energy-shield-mk6-equipment",{"kr-singularity-tech-card"})
data_util.tech_add_ingredients("energy-shield-mk6-equipment",{"kr-singularity-tech-card","se-kr-matter-science-pack-2"})
data.raw.technology["energy-shield-mk6-equipment"].unit.count = 4800

-- SE makes it's changes to the Portable Fusion Reactor in phase-3 so we make our changes here as well
data_util.tech_remove_ingredients("fission-reactor-equipment", {"se-energy-science-pack-2"})
data_util.tech_remove_prerequisites("fission-reactor-equipment", {"se-rtg-equipment", "se-holmium-solenoid", "se-energy-science-pack-2"})
data_util.tech_add_prerequisites("fission-reactor-equipment", {"utility-science-pack"})
data_util.tech_add_ingredients("fission-reactor-equipment", {"utility-science-pack"})
-- update K2s portable fission reactor to fall in line correctly
data_util.tech_add_ingredients("kr-fusion-reactor-equipment", {"se-energy-science-pack-2", "se-material-science-pack-2", "production-science-pack"})

-- SE makes cascading changes to battery-mk2-equipment in phase-3 so we need to make changes to child techs here
-- Personal Battery Mk3
data.raw.technology["kr-battery-mk3-equipment"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_ingredients("kr-battery-mk3-equipment", {"se-energy-science-pack-1","se-material-science-pack-2"})
data_util.tech_add_prerequisites("kr-battery-mk3-equipment", {"se-superconductive-cable"})
data_util.tech_add_ingredients("kr-battery-mk3-equipment", {"se-rocket-science-pack","space-science-pack","production-science-pack","utility-science-pack","se-energy-science-pack-3","se-material-science-pack-3"})
