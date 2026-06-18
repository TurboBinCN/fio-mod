local data_util = require("data_util")

--Integrate Material Science and its products into K2 Belts.
data_util.tech_remove_prerequisites("kr-logistic-4", {"utility-science-pack"})
data_util.tech_add_prerequisites("kr-logistic-4", {"kr-imersium-processing","se-material-science-pack-1"})
data_util.tech_add_ingredients("kr-logistic-4", {"se-material-science-pack-1"})

data.raw.technology["kr-logistic-5"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-logistic-5", {"kr-advanced-tech-card"})
data_util.tech_remove_ingredients("kr-logistic-5", {"kr-advanced-tech-card"})
data_util.tech_add_prerequisites("kr-logistic-5", {"kr-optimization-tech-card","se-heavy-bearing"})
data_util.tech_add_ingredients("kr-logistic-5", {"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-optimization-tech-card","se-material-science-pack-2"})

-- Inserter Capacity Bonuses
data_util.tech_add_prerequisites("inserter-capacity-bonus-6",{"se-material-science-pack-1"})
data_util.tech_add_prerequisites("inserter-capacity-bonus-7",{"se-material-science-pack-2"})

-- Update the cost of the Advanced Robotport Tech
-- Tell K2 to not check science pack coherance since SE-K2 has a different paradigm
data.raw.technology["kr-advanced-roboports"].kr_check_science_packs_incompatibilities = false
-- Make changes
data_util.tech_add_ingredients("kr-advanced-roboports",{"automation-science-pack","logistic-science-pack","chemical-science-pack","space-science-pack","se-material-science-pack-3","se-energy-science-pack-3"})

-- Rebalance cost of Superiror Robot Battery tech
data.raw.technology["kr-robot-battery-plus"].kr_check_science_packs_incompatibilities = false
data_util.tech_add_ingredients("kr-robot-battery-plus",{"automation-science-pack","logistic-science-pack","chemical-science-pack","space-science-pack","kr-advanced-tech-card","se-energy-science-pack-3"})
data_util.tech_remove_ingredients("kr-robot-battery-plus",{"kr-matter-tech-card"})
data_util.tech_remove_prerequisites("kr-robot-battery-plus", {"kr-matter-tech-card"})

-- Add Singularity Tech Card to Teleportation Tech
data_util.tech_add_prerequisites("se-teleportation",{"kr-singularity-tech-card"})
data_util.tech_add_ingredients("se-teleportation",{"kr-singularity-tech-card","se-kr-matter-science-pack-2"})

-- Move K2 Planetary Teleporter to require SE Teleportation Tech
data.raw.technology["kr-planetary-teleporter"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-planetary-teleporter",{"effect-transmission"})
data_util.tech_remove_ingredients("kr-planetary-teleporter",{"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"})
data_util.tech_add_prerequisites("kr-planetary-teleporter",{"se-teleportation"})
data_util.tech_add_ingredients("kr-planetary-teleporter",{"automation-science-pack","logistic-science-pack","chemical-science-pack","se-energy-science-pack-4","se-material-science-pack-4","se-deep-space-science-pack-4","se-kr-matter-science-pack-2"})

-- Add Singularity Tech Card to Arcolink Chest tech
data_util.tech_add_ingredients("se-linked-container",{"automation-science-pack","chemical-science-pack","kr-singularity-tech-card","se-kr-matter-science-pack-2"})

-- Superiror Inserters
data.raw.technology["kr-superior-inserters"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-superior-inserters",{"kr-advanced-tech-card"})
data_util.tech_remove_ingredients("kr-superior-inserters",{"kr-advanced-tech-card"})
data_util.tech_add_prerequisites("kr-superior-inserters",{"se-aeroframe-scaffold","se-heavy-bearing"})
data_util.tech_add_ingredients("kr-superior-inserters",{"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-optimization-tech-card","se-astronomic-science-pack-2","se-material-science-pack-2"})
