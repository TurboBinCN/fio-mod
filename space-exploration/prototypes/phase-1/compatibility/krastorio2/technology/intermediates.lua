local data_util = require("data_util")

-- Advanced Fuel
data.raw.technology["kr-advanced-fuel"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-advanced-fuel",{"kr-fuel","production-science-pack"})
data_util.tech_remove_ingredients("kr-advanced-fuel",{"production-science-pack"})
data_util.tech_add_prerequisites("kr-advanced-fuel",{"kr-optimization-tech-card"})
data_util.tech_add_ingredients("kr-advanced-fuel",{"space-science-pack","kr-optimization-tech-card"})

-- Energy Control Unit
data_util.tech_remove_ingredients("kr-energy-control-unit", {"kr-matter-tech-card"})
data_util.tech_remove_prerequisites("kr-energy-control-unit", {"kr-matter-tech-card", "kr-singularity-lab"})
data_util.tech_add_ingredients("kr-energy-control-unit", {"se-energy-science-pack-1"})
data_util.tech_add_prerequisites("kr-energy-control-unit", {"se-energy-science-pack-1"})

-- Remove "se-rocket-fuel-from-water" tech
data.raw.technology["se-rocket-fuel-from-water"] = nil

-- Scaffolding *in space!*
data_util.tech_add_prerequisites("se-space-platform-scaffold",{"kr-steel-fluid-handling"})

data:extend({
  {
    type = "technology",
    name = "se-kr-efficient-fabrication",
    effects = {},
    icons = {
      {icon = "__base__/graphics/technology/advanced-circuit.png", icon_size = 256},
      {icon = "__Krastorio2Assets__/icons/items/lithium.png", icon_size = 64, scale = 1.25, shift = {-32, 32}},
      {icon = "__Krastorio2Assets__/icons/fluids/nitric-acid.png", icon_size = 64, scale = 1, shift = {32, 32}}
    },
    order = "e-g",
    prerequisites = {
      "se-energy-science-pack-1",
      "kr-advanced-chemical-plant"
    },
    unit = {
      count = 100,
      time = 60,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"kr-optimization-tech-card", 1},
        {"space-science-pack", 1},
        {"utility-science-pack", 1},
        {"se-energy-science-pack-1", 1},
        {"se-biological-science-pack-2",1}
      }
    },
    kr_check_science_packs_incompatibilities = false
  }
})
data_util.recipe_require_tech("kr-electronic-components-with-lithium", "se-kr-efficient-fabrication")

local nutrient_enriched_fert = {
  type = "technology",
  name = "se-kr-nutrient-enrichment",
  effects = {
    { type = "unlock-recipe", recipe = "se-kr-fertilizer-with-nutrients"},
  },
  icons = {
    {icon = "__Krastorio2Assets__/icons/items/fertilizer.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/fluid/nutrient-gel.png", icon_size = 64, scale = 1, shift = {-16,16}}
  },
  order = "e-g",
  prerequisites = {
    "kr-advanced-chemical-plant"
  },
  unit = {
    count = 100,
    time = 60,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"se-rocket-science-pack", 1},
      {"space-science-pack", 1},
      {"kr-optimization-tech-card", 1},
      {"production-science-pack", 1},
      {"se-biological-science-pack-2", 1}
    },
  },
  kr_check_science_packs_incompatibilities = false
}
data:extend({nutrient_enriched_fert})

-- AI Core
data_util.tech_remove_prerequisites("kr-ai-core", {"kr-quarry-minerals-extraction","utility-science-pack"})
data_util.tech_add_prerequisites("kr-ai-core",{"se-quantum-processor","se-biological-science-pack-3"})
data_util.tech_add_ingredients("kr-ai-core",{"se-energy-science-pack-3","se-biological-science-pack-3"})


-- Add Imersite Processing as a prerequisite to Energy Control Units
data_util.tech_add_prerequisites("kr-energy-control-unit", {"kr-quarry-minerals-extraction"})
data_util.tech_add_ingredients("kr-energy-control-unit", {"automation-science-pack", "logistic-science-pack", "chemical-science-pack"})

-- Create the Rare Metal Substrate technology
data:extend({
  {
    type = "technology",
    name = "se-kr-rare-metal-substrate",
    effects = {
      { type = "unlock-recipe", recipe = "se-kr-rare-metal-substrate"},
    },
    icons = {
      {icon = "__space-exploration-graphics__/graphics/technology/data-card.png", icon_size = 141},
      {icon = "__Krastorio2Assets__/icons/items/rare-metals.png", icon_size = 64, shift = {-32, -32}}
    },
    order = "e-g",
    prerequisites = {
      "se-energy-science-pack-1",
      "kr-optimization-tech-card"
    },
    unit = {
      count = 100,
      time = 60,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"kr-optimization-tech-card", 1},
        {"space-science-pack", 1},
        {"utility-science-pack", 1},
        {"se-energy-science-pack-1", 1}
      }
    },
    kr_check_science_packs_incompatibilities = false
  }
})

-- Move Quarry Mineral Extraction (Imersite Mining) to same stage as other SE space materials and act as prereqs for Optimization
data_util.tech_remove_prerequisites("kr-quarry-minerals-extraction",{"production-science-pack"})
data_util.tech_remove_ingredients("kr-quarry-minerals-extraction",{"production-science-pack"})
data_util.tech_add_prerequisites("kr-quarry-minerals-extraction", {"space-science-pack"})
data_util.tech_add_ingredients("kr-quarry-minerals-extraction", {"space-science-pack"})

data_util.tech_remove_prerequisites("kr-imersium-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-imersium-processing", {"production-science-pack","utility-science-pack","kr-matter-tech-card"})
data_util.tech_add_prerequisites("kr-imersium-processing", {"kr-quarry-minerals-extraction"})
data_util.tech_add_ingredients("kr-imersium-processing", {"automation-science-pack","logistic-science-pack","chemical-science-pack","space-science-pack"})

-- Move the air purifier to post-imersite (since it requires imersite powder)
data_util.tech_add_prerequisites("kr-air-purification", {"kr-lithium-processing"})

---- Add Optimisation Tech Card to the simulation techs.
data_util.tech_add_prerequisites("se-space-simulation-sb", {"kr-optimization-tech-card"})
data_util.tech_add_ingredients("se-space-simulation-sb", {"kr-optimization-tech-card"})
data_util.tech_add_prerequisites("se-space-simulation-bm", {"kr-optimization-tech-card"})
data_util.tech_add_ingredients("se-space-simulation-bm", {"kr-optimization-tech-card"})
data_util.tech_add_prerequisites("se-space-simulation-ab", {"kr-optimization-tech-card"})
data_util.tech_add_ingredients("se-space-simulation-ab", {"kr-optimization-tech-card"})
data_util.tech_add_prerequisites("se-space-simulation-sm", {"kr-optimization-tech-card"})
data_util.tech_add_ingredients("se-space-simulation-sm", {"kr-optimization-tech-card"})
data_util.tech_add_prerequisites("se-space-simulation-as", {"kr-optimization-tech-card"})
data_util.tech_add_ingredients("se-space-simulation-as", {"kr-optimization-tech-card"})
data_util.tech_add_prerequisites("se-space-simulation-am", {"kr-optimization-tech-card"})
data_util.tech_add_ingredients("se-space-simulation-am", {"kr-optimization-tech-card"})

data_util.tech_add_ingredients("se-space-simulation-sbm", {"kr-optimization-tech-card"})
data_util.tech_add_ingredients("se-space-simulation-asb", {"kr-optimization-tech-card"})
data_util.tech_add_ingredients("se-space-simulation-abm", {"kr-optimization-tech-card"})
data_util.tech_add_ingredients("se-space-simulation-asm", {"kr-optimization-tech-card"})

data_util.tech_add_ingredients("se-space-simulation-asbm", {"kr-optimization-tech-card"})
