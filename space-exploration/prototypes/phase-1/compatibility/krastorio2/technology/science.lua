local data_util = require("data_util")

---- Matter Science Pack
-- Matter Science Pack Tint
local matter_pack_tint = {r = 255, g = 51, b = 151}

--- Catalogue techs
local matter_catalogue_tech = {
  type = "technology",
  name = "se-kr-space-catalogue-matter-1",
  effects = {
    { type = "unlock-recipe", recipe = "se-kr-matter-catalogue-1" },
    { type = "unlock-recipe", recipe = "se-kr-matter-liberation-data"},
    { type = "unlock-recipe", recipe = "se-kr-matter-containment-data"},
    { type = "unlock-recipe", recipe = "se-kr-matter-synthesis-data"},
  },
  icons = {
    {icon = "__space-exploration-graphics__/graphics/technology/catalogue/base-catalogue-1.png", icon_size = 128},
    {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-catalogue-1.png", icon_size = 128, tint = matter_pack_tint}
  },
  order = "e-g",
  prerequisites = {
    "se-space-material-fabricator"
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
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"se-astronomic-science-pack-2", 1},
      {"se-energy-science-pack-3", 1},
      {"se-material-science-pack-2", 1},
    }
  },
}
data:extend({matter_catalogue_tech})
data_util.recipe_require_tech("kr-matter-research-data", "se-kr-space-catalogue-matter-1")

local matter_catalogue_2_tech = {
    type = "technology",
    name = "se-kr-space-catalogue-matter-2",
    effects = {
      { type = "unlock-recipe", recipe = "se-kr-matter-catalogue-2" },
      { type = "unlock-recipe", recipe = "se-kr-matter-manipulation-data"},
      { type = "unlock-recipe", recipe = "se-kr-matter-recombination-data"},
      { type = "unlock-recipe", recipe = "se-kr-matter-stabilization-data"},
      { type = "unlock-recipe", recipe = "se-kr-matter-utilization-data"},
    },
    icons = {
      {icon = "__space-exploration-graphics__/graphics/technology/catalogue/base-catalogue-2.png", icon_size = 128},
      {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-catalogue-2.png", icon_size = 128, tint = matter_pack_tint}
    },
    order = "e-g",
    prerequisites = {
    },
    unit = {
      count = 100,
      time = 60,
      ingredients = {
        {"se-rocket-science-pack", 1},
        {"space-science-pack", 1},
        {"kr-matter-tech-card", 1},
        {"se-deep-space-science-pack-1", 1},
      }
    },
  }
  data:extend({matter_catalogue_2_tech})

data_util.tech_add_prerequisites("kr-quantum-computer",{"kr-advanced-tech-card"})
data_util.tech_add_ingredients("kr-quantum-computer",{"kr-advanced-tech-card"})

-- Bring the Matter Tech Card to directly after the Matter Fabricator Tech
data_util.tech_remove_prerequisites("kr-matter-tech-card", {"kr-quantum-computer","se-space-material-fabricator","se-naquium-tessaract","kr-singularity-lab","se-deep-space-science-pack-2"})
data_util.tech_remove_ingredients("kr-matter-tech-card",{"se-deep-space-science-pack-2"})
data_util.tech_add_prerequisites("kr-matter-tech-card", {"se-kr-space-catalogue-matter-1"})
data_util.tech_add_ingredients("kr-matter-tech-card",{"se-energy-science-pack-3","se-material-science-pack-2","se-astronomic-science-pack-2"})
data.raw.technology["kr-matter-tech-card"].icon = nil
data.raw.technology["kr-matter-tech-card"].icon_size = nil
data.raw.technology["kr-matter-tech-card"].icons = {
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/deep-2.png", icon_size = 128},
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-2.png", icon_size = 128, tint = matter_pack_tint}
}


local matter_science_pack_2_tech = {
  type = "technology",
  name = "se-kr-matter-science-pack-2",
  effects = {
    { type = "unlock-recipe", recipe = "se-kr-matter-science-pack-2" }
  },
  icons = {
    {icon = "__space-exploration-graphics__/graphics/technology/catalogue/deep-3.png", icon_size = 128},
    {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-3.png", icon_size = 128, tint = matter_pack_tint}
  },
  order = "e-g",
  prerequisites = {
    "se-kr-space-catalogue-matter-2"
  },
  unit = {
    count = 2000,
    time = 60,
    ingredients = {
      {"se-rocket-science-pack", 1},
      {"space-science-pack", 1},
      {"kr-matter-tech-card", 1}
    }
  }
}
data:extend({matter_science_pack_2_tech})


-- Add Research Server as Prerequisite to Catalogue techs
data_util.tech_add_prerequisites("se-space-catalogue-astronomic-1",{"kr-research-server"})
data_util.tech_add_prerequisites("se-space-catalogue-biological-1",{"kr-research-server"})
data_util.tech_add_prerequisites("se-space-catalogue-material-1",{"kr-research-server"})
data_util.tech_add_prerequisites("se-space-catalogue-energy-1",{"kr-research-server"})

local advanced_pack_tint = {r = 133, g = 33, b = 209}
local adv_catalogue_1_tech = {
  type = "technology",
  name = "se-kr-advanced-catalogue-1",
  effects = {
    {type = "unlock-recipe", recipe = "se-kr-advanced-catalogue-1"},
    {type = "unlock-recipe", recipe = "se-kr-combined-catalogue"},
    {type = "unlock-recipe", recipe = "se-kr-power-density-data"},
    {type = "unlock-recipe", recipe = "se-kr-quantum-computation-data"},
    {type = "unlock-recipe", recipe = "se-kr-remote-probe"}
  },
  icons = {
    {icon = "__space-exploration-graphics__/graphics/technology/catalogue/base-catalogue-1.png", icon_size = 128},
    {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-catalogue-1.png", icon_size = 128, tint = advanced_pack_tint}
  },
  order = "e-g",
  prerequisites = {
    "se-astronomic-science-pack-3",
    "se-biological-science-pack-3",
    "se-quantum-processor",
    "se-material-science-pack-3"
  },
  unit = {
    count = 500,
    time = 60,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"se-rocket-science-pack", 1},
      {"space-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"kr-optimization-tech-card", 1},
      {"se-astronomic-science-pack-3", 1},
      {"se-biological-science-pack-3", 1},
      {"se-energy-science-pack-3", 1},
      {"se-material-science-pack-3", 1}
    }
  }
}
local adv_catalogue_2_tech = {
  type = "technology",
  name = "se-kr-advanced-catalogue-2",
  effects = {
    {type = "unlock-recipe", recipe = "se-kr-advanced-catalogue-2"},
    {type = "unlock-recipe", recipe = "se-kr-macroscale-entanglement-data"},
    {type = "unlock-recipe", recipe = "se-kr-macroscale-entanglement-data-alt"},
    {type = "unlock-recipe", recipe = "se-kr-timespace-manipulation-data"},
    {type = "unlock-recipe", recipe = "se-kr-timespace-manipulation-data-alt"},
    {type = "unlock-recipe", recipe = "se-kr-singularity-application-data"},
    {type = "unlock-recipe", recipe = "se-kr-singularity-application-data-alt"}
  },
  icons = {
    {icon = "__space-exploration-graphics__/graphics/technology/catalogue/base-catalogue-2.png", icon_size = 128},
    {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-catalogue-2.png", icon_size = 128, tint = advanced_pack_tint}
  },
  order = "e-g",
  prerequisites = {
    "se-deep-space-science-pack-3",
    "se-kr-matter-science-pack-2"
  },
  unit = {
    count = 500,
    time = 60,
    ingredients = {
      {"se-rocket-science-pack", 1},
      {"space-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"kr-optimization-tech-card", 1},
      {"se-kr-matter-science-pack-2", 1},
      {"kr-advanced-tech-card", 1},
      {"se-deep-space-science-pack-3", 1}
    }
  }
}
data:extend({adv_catalogue_1_tech, adv_catalogue_2_tech})

-- Advanced Science Pack 1 is unlocked by the Advanced Catalogue 1
local adv_card = data.raw.technology["kr-advanced-tech-card"]
adv_card.prerequisites = {
  "se-kr-advanced-catalogue-1"
}
adv_card.icon = nil
adv_card.icon_size = nil
adv_card.icons = {
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/deep-2.png", icon_size = 128},
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-2.png", icon_size = 128, tint = advanced_pack_tint}
}
data_util.tech_add_ingredients("kr-advanced-tech-card",{"kr-optimization-tech-card","se-energy-science-pack-3","se-material-science-pack-3","se-biological-science-pack-3","se-astronomic-science-pack-3"})
data_util.tech_remove_ingredients("kr-advanced-tech-card",{"kr-matter-tech-card"})


-- Advanced Science Pack 2 is unlocked by the Advanced Catalogue 2
local sing_card = data.raw.technology["kr-singularity-tech-card"]
sing_card.prerequisites = {
  "se-kr-advanced-catalogue-2"
}
sing_card.icon = nil
sing_card.icon_size = nil
sing_card.icons = {
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/deep-3.png", icon_size = 128},
  {icon = "__space-exploration-graphics__/graphics/technology/catalogue/mask-3.png", icon_size = 128, tint = advanced_pack_tint}
}
data_util.tech_remove_ingredients("kr-singularity-tech-card",{"se-deep-space-science-pack-4","kr-matter-tech-card"})
data_util.tech_add_ingredients("kr-singularity-tech-card",{"se-deep-space-science-pack-3","se-kr-matter-science-pack-2"})
