local data_util = require("data_util")

-- SE makes changes to rocket-fuel in technology.lua so we must make our changes here.

-- Replace "se-fuel-refining" with "kr-fuel" tech
data_util.tech_add_prerequisites("rocket-fuel",{"kr-fuel"})
data_util.tech_remove_prerequisites("rocket-fuel",{"se-fuel-refining"})
data_util.tech_add_prerequisites("speed-module",{"kr-fuel"})
data_util.tech_remove_prerequisites("speed-module",{"se-fuel-refining"})

data_util.tech_lock_recipes("kr-fuel",{"solid-fuel-from-heavy-oil","solid-fuel-from-light-oil","solid-fuel-from-petroleum-gas"})
data_util.tech_add_prerequisites("se-fuel-refining",{"kr-fuel"})
data_util.tech_remove_prerequisites("se-fuel-refining",{"oil-processing","logistic-science-pack"})

-- Repurpose "se-fuel-refining" tech and building as an advanced option.
data_util.tech_add_prerequisites("se-fuel-refining", {"space-science-pack"})
data_util.tech_add_ingredients("se-fuel-refining", {"chemical-science-pack","se-rocket-science-pack","space-science-pack"})
data_util.tech_remove_ingredients("se-fuel-refining",{"kr-basic-tech-card"})
