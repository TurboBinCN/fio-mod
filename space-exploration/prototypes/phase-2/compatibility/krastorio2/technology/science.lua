local data_util = require("data_util")

-- Rocket science pack
-- Since K2 doesn't have an icon for this specifically, we will use one of the existing but unused K2 icons instead.
local rocket_science_tech = data.raw.technology["se-rocket-science-pack"]
rocket_science_tech.localised_name = {"technology-name.se-kr-rocket-tech-card"}
rocket_science_tech.icons = nil
rocket_science_tech.icon = "__Krastorio2Assets__/technologies/utility-tech-card.png"
rocket_science_tech.icon_size = 256

-- Ensure correct naming for Production and Utility science packs
data.raw.technology["production-science-pack"].localised_name = {"technology-name.production-science-pack"}
data.raw.technology["utility-science-pack"].localised_name = {"technology-name.utility-science-pack"}

-- Ensure the correct image for the Optimization science pack
local optimization_pack_tint = {r = 255, g = 128, b = 0}
local opti_science_tech = data.raw.technology["kr-optimization-tech-card"]
opti_science_tech.icon = nil
opti_science_tech.icon_size = nil
opti_science_tech.icons = {
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/deep-2.png", icon_size = 128},
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-2.png", icon_size = 128, tint = optimization_pack_tint}
}

-- Adjust Optimization Tech Card tech to be inline with Production and Utility
data_util.tech_remove_prerequisites("kr-optimization-tech-card", {"se-processing-cryonite","uranium-processing","electric-energy-accumulators","production-science-pack","se-space-science-lab","kr-singularity-lab"})
data_util.tech_remove_ingredients("kr-optimization-tech-card", {"production-science-pack"})
data_util.tech_add_prerequisites("kr-optimization-tech-card", {"se-space-supercomputer-1","kr-imersium-processing"})
data_util.tech_add_ingredients("kr-optimization-tech-card", {"space-science-pack"})

-- Nexus also needs basic cards adding
data_util.tech_add_ingredients("se-nexus",{"automation-science-pack","logistic-science-pack","chemical-science-pack"})

-- Logistics Tech Card needs the Electric Lab as a prerequisite
data_util.tech_add_prerequisites("logistic-science-pack", {"electric-lab"})
