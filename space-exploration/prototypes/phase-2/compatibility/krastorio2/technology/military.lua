local data_util = require("data_util")

-- Move K2 Antimatter Weaponry to SE Antimatter Reactor
if data.raw.technology["kr-antimatter-ammo"] then -- Can be disabled by some other mods e.g. "Realistic Fusion Weaponry"
  data.raw.technology["kr-antimatter-ammo"].kr_check_science_packs_incompatibilities = false
  data_util.tech_remove_prerequisites("kr-antimatter-ammo",{"kr-antimatter-reactor"})
  data_util.tech_remove_ingredients("kr-antimatter-ammo",{"kr-optimization-tech-card","kr-singularity-tech-card"})
  data_util.tech_add_prerequisites("kr-antimatter-ammo",{"se-antimatter-reactor", "kr-advanced-tech-card"})
  data_util.tech_add_ingredients("kr-antimatter-ammo",{"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-astronomic-science-pack-4","se-energy-science-pack-4","se-material-science-pack-4","se-deep-space-science-pack-1"})
end

data_util.tech_remove_prerequisites("physical-projectile-damage-16",{"se-naquium-processor"})
data_util.tech_add_prerequisites("physical-projectile-damage-16",{"se-deep-space-science-pack-4"})
data_util.tech_remove_prerequisites("physical-projectile-damage-18",{"se-deep-space-science-pack-4"})
