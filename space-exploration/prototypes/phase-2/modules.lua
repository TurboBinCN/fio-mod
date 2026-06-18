local data_util = require("data_util")
local module_util = require("prototypes/phase-multi/module-util")

local modules_per_tier = module_util.modules_per_tier
local energy_required = module_util.energy_required

data.raw.technology["productivity-module"].icon = "__space-exploration-graphics__/graphics/technology/modules/productivity-1.png"
data.raw.technology["productivity-module"].icon_size = 128
data.raw.technology["productivity-module-2"].icon = "__space-exploration-graphics__/graphics/technology/modules/productivity-2.png"
data.raw.technology["productivity-module-2"].icon_size = 128
data.raw.technology["productivity-module-3"].icon = "__space-exploration-graphics__/graphics/technology/modules/productivity-3.png"
data.raw.technology["productivity-module-3"].icon_size = 128

data.raw.technology["speed-module"].icon = "__space-exploration-graphics__/graphics/technology/modules/speed-1.png"
data.raw.technology["speed-module"].icon_size = 128
data.raw.technology["speed-module-2"].icon = "__space-exploration-graphics__/graphics/technology/modules/speed-2.png"
data.raw.technology["speed-module-2"].icon_size = 128
data.raw.technology["speed-module-3"].icon = "__space-exploration-graphics__/graphics/technology/modules/speed-3.png"
data.raw.technology["speed-module-3"].icon_size = 128

data.raw.technology["efficiency-module"].icon = "__space-exploration-graphics__/graphics/technology/modules/efficiency-1.png"
data.raw.technology["efficiency-module"].icon_size = 128
data.raw.technology["efficiency-module-2"].icon = "__space-exploration-graphics__/graphics/technology/modules/efficiency-2.png"
data.raw.technology["efficiency-module-2"].icon_size = 128
data.raw.technology["efficiency-module-3"].icon = "__space-exploration-graphics__/graphics/technology/modules/efficiency-3.png"
data.raw.technology["efficiency-module-3"].icon_size = 128

data_util.tech_remove_prerequisites("modules", {"advanced-circuit"})
data_util.tech_add_prerequisites("modules", {"automation-2"})

data_util.tech_add_prerequisites("speed-module", {data_util.mod_prefix .. "fuel-refining"})

data_util.tech_remove_prerequisites("speed-module-2", {"processing-unit"})
data_util.tech_add_prerequisites("speed-module-2", {data_util.mod_prefix .."rocket-science-pack"})
data_util.tech_add_ingredients("speed-module-2", {data_util.mod_prefix .. "rocket-science-pack"})

data_util.tech_remove_ingredients("speed-module-3", {"utility-science-pack", "production-science-pack"})
data_util.tech_remove_prerequisites("speed-module-3", {"utility-science-pack", "production-science-pack"})
data_util.tech_add_prerequisites("speed-module-3", {"electric-engine"})

data_util.tech_remove_prerequisites("productivity-module-2", {"processing-unit"})
data_util.tech_add_prerequisites("productivity-module-2", {data_util.mod_prefix .."rocket-science-pack"})
data_util.tech_add_ingredients("productivity-module-2", {data_util.mod_prefix .. "rocket-science-pack"})

data_util.tech_remove_ingredients("productivity-module-3", {"utility-science-pack", "production-science-pack"})
data_util.tech_remove_prerequisites("productivity-module-3", {"utility-science-pack", "production-science-pack"})
data_util.tech_add_prerequisites("productivity-module-2", {"sulfur-processing"})
data_util.tech_add_prerequisites("productivity-module-3", {data_util.mod_prefix .. "processing-vulcanite"})

data_util.tech_remove_prerequisites("efficiency-module-2", {"processing-unit"})
data_util.tech_add_prerequisites("efficiency-module-2", {data_util.mod_prefix .."rocket-science-pack", "battery"})
data_util.tech_add_ingredients("efficiency-module-2", {data_util.mod_prefix .. "rocket-science-pack"})

data_util.tech_remove_ingredients("efficiency-module-3", {"utility-science-pack", "production-science-pack"})
data_util.tech_remove_prerequisites("efficiency-module-3", {"utility-science-pack", "production-science-pack"})
data_util.tech_add_prerequisites("efficiency-module-3", {data_util.mod_prefix .. "processing-cryonite"})

data_util.tech_add_prerequisites("speed-module-3", {"space-science-pack"})
data_util.tech_add_ingredients("speed-module-3", {"space-science-pack"})
data_util.tech_add_prerequisites("productivity-module-3", {"space-science-pack"})
data_util.tech_add_ingredients("productivity-module-3", {"space-science-pack"})
data_util.tech_add_prerequisites("efficiency-module-3", {"space-science-pack"})
data_util.tech_add_ingredients("efficiency-module-3", {"space-science-pack"})

data.raw.module["productivity-module"].icon = "__space-exploration-graphics__/graphics/icons/modules/productivity-1.png"
data.raw.module["productivity-module"].icon_size = 64
data.raw.module["productivity-module"].subgroup = "module-productivity"
data.raw.module["productivity-module"].effect =
  {
    productivity = 0.04,
    consumption = 0.5,
    pollution = 0.05,
    speed = -0.1
  }
data.raw.module["productivity-module-2"].icon = "__space-exploration-graphics__/graphics/icons/modules/productivity-2.png"
data.raw.module["productivity-module-2"].icon_size = 64
data.raw.module["productivity-module-2"].subgroup = "module-productivity"
data.raw.module["productivity-module-2"].effect =
  {
    productivity = 0.06,
    consumption = 0.6,
    pollution = 0.06,
    speed = -0.15
  }
data.raw.module["productivity-module-3"].icon = "__space-exploration-graphics__/graphics/icons/modules/productivity-3.png"
data.raw.module["productivity-module-3"].icon_size = 64
data.raw.module["productivity-module-3"].subgroup = "module-productivity"
data.raw.module["productivity-module-3"].effect =
  {
    productivity = 0.08,
    consumption = 0.8,
    pollution = 0.08,
    speed = -0.2
  }

data.raw.module["speed-module"].icon = "__space-exploration-graphics__/graphics/icons/modules/speed-1.png"
data.raw.module["speed-module"].icon_size = 64
data.raw.module["speed-module"].subgroup = "module-speed"
data.raw.module["speed-module"].effect =
  {
    consumption = 0.5,
    pollution = 0.04,
    speed = 0.2
  }
data.raw.module["speed-module-2"].icon = "__space-exploration-graphics__/graphics/icons/modules/speed-2.png"
data.raw.module["speed-module-2"].icon_size = 64
data.raw.module["speed-module-2"].subgroup = "module-speed"
data.raw.module["speed-module-2"].effect =
  {
    consumption = 0.6,
    pollution = 0.06,
    speed = 0.3
  }
data.raw.module["speed-module-3"].icon = "__space-exploration-graphics__/graphics/icons/modules/speed-3.png"
data.raw.module["speed-module-3"].icon_size = 64
data.raw.module["speed-module-3"].subgroup = "module-speed"
data.raw.module["speed-module-3"].effect =
  {
    consumption = 0.8,
    pollution = 0.08,
    speed = data_util.speed_module_3_speed_bonus
  }

data.raw.module["efficiency-module"].icon = "__space-exploration-graphics__/graphics/icons/modules/efficiency-1.png"
data.raw.module["efficiency-module"].icon_size = 64
data.raw.module["efficiency-module"].subgroup = "module-efficiency"
data.raw.module["efficiency-module"].effect =
  {
    consumption = -0.4,
    pollution = -0.1,
  }
data.raw.module["efficiency-module-2"].icon = "__space-exploration-graphics__/graphics/icons/modules/efficiency-2.png"
data.raw.module["efficiency-module-2"].icon_size = 64
data.raw.module["efficiency-module-2"].subgroup = "module-efficiency"
data.raw.module["efficiency-module-2"].effect =
  {
    consumption = -0.6,
    pollution = -0.15,
  }
data.raw.module["efficiency-module-3"].icon = "__space-exploration-graphics__/graphics/icons/modules/efficiency-3.png"
data.raw.module["efficiency-module-3"].icon_size = 64
data.raw.module["efficiency-module-3"].subgroup = "module-efficiency"
data.raw.module["efficiency-module-3"].effect =
  {
    consumption = -1,
    pollution = -0.2,
  }


--[[
Speed
  1 iron gear
  2 electric motor
  3 big electric motor
  4 iridium plate, machine learning
  5 heavy girder, matcat 1
  6 heavy bearing. matcat 2
  7 heavy composite, matcat 3
  8 heavy assembly, matcat 4
  9 Superconductive cable, nanomaterial, deepcat 1
Productivity
  1 Solid fuel
  2 Sulfur
  3 Vulcanite
  4 Vitamelange Extract, machine learning
  5 bioscrubber, biocat 1
  6 vitalic reagent, biocat 2
  7 vitalic epoxy, biocat 3
  8 self sealing gel, biocat 4
  9 Superconductive cable, adv neural gel, deepcat 1
Efficiency
  1 copper plate
  2 Battery
  3 Cryonite
  4 Holmium plate, machine learning
  5 Holmium cable, energycat 1
  6 Holmium solenoid, energycat 2
  7 Quantum Processor, energycat 3
  8 Dynamic Emitter, energycat 4
  9 Superconductive cable, antimatter canister, deepcat 1
]]

local ingredients = {
  speed = {
    [1] = { --45 / 20
      {type = "item", name = "electronic-circuit", amount = 20},
      {type = "item", name = "solid-fuel", amount = 10},
    },
    [2] = { -- 330
      {type = "item", name = "speed-module", amount = modules_per_tier},
      {type = "item", name = "advanced-circuit", amount = 20},
      {type = "item", name = "electric-motor", amount = 20},
    },
    [3] = { -- 2720
      {type = "item", name = "speed-module-2", amount = modules_per_tier},
      {type = "item", name = "processing-unit", amount = 20},
      {type = "item", name = "electric-engine-unit", amount = 20},
    },
    [4] = { -- 5550
      {type = "item", name = "speed-module-3", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 120},
      {type = "item", name = data_util.mod_prefix .. "machine-learning-data", amount = 1},
    },
    [5] = {
      {type = "item", name = "speed-module-4", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 100},
      {type = "item", name = data_util.mod_prefix .. "material-catalogue-1", amount = 1}
    },
    [6] = {
      {type = "item", name = "speed-module-5", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "heavy-bearing", amount = 140},
      {type = "item", name = data_util.mod_prefix .. "material-catalogue-2", amount = 2}
    },
    [7] = {
      {type = "item", name = "speed-module-6", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "heavy-composite", amount = 160},
      {type = "item", name = data_util.mod_prefix .. "material-catalogue-3", amount = 4}
    },
    [8] = {
      {type = "item", name = "speed-module-7", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "heavy-assembly", amount = 180},
      {type = "item", name = data_util.mod_prefix .. "material-catalogue-4", amount = 8},
      {type = "fluid", name = "lubricant", amount = 500},
    },
    [9] = {
      {type = "item", name = "speed-module-8", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 500},
      {type = "item", name = data_util.mod_prefix .. "deep-catalogue-1", amount = 10},
      {type = "fluid", name = data_util.mod_prefix .. "cryonite-slush", amount = 1000},
    },
  },
  productivity = {
    [1] = { --45 / 20
      {type = "item", name = "electronic-circuit", amount = 25},
      {type = "item", name = SEItemNames.get_glass_name(), amount = 25},
    },
    [2] = {
      {type = "item", name = "productivity-module", amount = modules_per_tier},
      {type = "item", name = "advanced-circuit", amount = 25},
      {type = "item", name = "sulfur", amount = 50},
    },
    [3] = {
      {type = "item", name = "productivity-module-2", amount = modules_per_tier},
      {type = "item", name = "processing-unit", amount = 25},
      {type = "item", name = data_util.mod_prefix .. "vulcanite-block", amount = 50},
    },
    [4] = {
      {type = "item", name = "productivity-module-3", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "vitamelange-extract", amount = 120},
      {type = "item", name = data_util.mod_prefix .. "machine-learning-data", amount = 1},
    },
    [5] = {
      {type = "item", name = "productivity-module-4", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "bioscrubber", amount = 50},
      {type = "item", name = data_util.mod_prefix .. "biological-catalogue-1", amount = 1},
    },
    [6] = {
      {type = "item", name = "productivity-module-5", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "vitalic-reagent", amount = 140},
      {type = "item", name = data_util.mod_prefix .. "biological-catalogue-2", amount = 2}
    },
    [7] = {
      {type = "item", name = "productivity-module-6", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "vitalic-epoxy", amount = 160},
      {type = "item", name = data_util.mod_prefix .. "biological-catalogue-3", amount = 4}
    },
    [8] = {
      {type = "item", name = "productivity-module-7", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "self-sealing-gel", amount = 180},
      {type = "item", name = data_util.mod_prefix .. "biological-catalogue-4", amount = 8},
      {type = "fluid", name = data_util.mod_prefix .. "neural-gel", amount = 200},
    },
    [9] = {
      {type = "item", name = "productivity-module-8", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "lattice-pressure-vessel", amount = 500},
      {type = "item", name = data_util.mod_prefix .. "deep-catalogue-1", amount = 10},
      {type = "fluid", name = data_util.mod_prefix .. "neural-gel-2", amount = 1000},
    },
  },
  efficiency = {
    [1] = { --45 / 20
      {type = "item", name = "electronic-circuit", amount = 15},
      {type = "item", name = "copper-cable", amount = 15},
    },
    [2] = {
      {type = "item", name = "efficiency-module", amount = modules_per_tier},
      {type = "item", name = "advanced-circuit", amount = 15},
      {type = "item", name = "battery", amount = 15},
    },
    [3] = {
      {type = "item", name = "efficiency-module-2", amount = modules_per_tier},
      {type = "item", name = "processing-unit", amount = 15},
      {type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 30},
    },
    [4] = {
      {type = "item", name = "efficiency-module-3", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "holmium-plate", amount = 90},
      {type = "item", name = data_util.mod_prefix .. "machine-learning-data", amount = 1}
    },
    [5] = {
      {type = "item", name = "efficiency-module-4", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 100},
      {type = "item", name = data_util.mod_prefix .. "energy-catalogue-1", amount = 1}
    },
    [6] = {
      {type = "item", name = "efficiency-module-5", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "holmium-solenoid", amount = 80},
      {type = "item", name = data_util.mod_prefix .. "energy-catalogue-2", amount = 2}
    },
    [7] = {
      {type = "item", name = "efficiency-module-6", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "quantum-processor", amount = 60},
      {type = "item", name = data_util.mod_prefix .. "energy-catalogue-3", amount = 4}
    },
    [8] = {
      {type = "item", name = "efficiency-module-7", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "dynamic-emitter", amount = 80},
      {type = "item", name = data_util.mod_prefix .. "energy-catalogue-4", amount = 8},
      {type = "fluid", name = data_util.mod_prefix .. "chemical-gel", amount = 100},
    },
    [9] = {
      {type = "item", name = "efficiency-module-8", amount = modules_per_tier},
      {type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 500},
      {type = "item", name = data_util.mod_prefix .. "deep-catalogue-1", amount = 10},
      {type = "fluid", name = data_util.mod_prefix .. "antimatter-stream", amount = 1000},
    },
  }
}

data:extend({

    --productivity
    {
        type = "recipe",
        name = "productivity-module",
        ingredients = ingredients.productivity[1],
        energy_required = energy_required(1),
        results = {
          {type = "item", name = "productivity-module", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "recipe",
        name = "productivity-module-2",
        ingredients = ingredients.productivity[2],
        energy_required = energy_required(2),
        results = {
          {type = "item", name = "productivity-module-2", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "recipe",
        name = "productivity-module-3",
        ingredients = ingredients.productivity[3],
        energy_required = energy_required(3),
        results = {
          {type = "item", name = "productivity-module-3", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "module",
        name = "productivity-module-4",
        icon = "__space-exploration-graphics__/graphics/icons/modules/productivity-4.png",
        icon_size = 64,
        subgroup = "module-productivity",
        category = "productivity",
        tier = 4,
        order = "c[productivity]-d[productivity-module-4]",
        stack_size = 50,
        effect =
        {
          productivity = 0.1,
          consumption = 1,
          pollution = 0.1,
          speed = -0.25
        }
    },
    {
        type = "recipe",
        name = "productivity-module-4",
        ingredients = ingredients.productivity[4],
        energy_required = energy_required(4),
        results = {
          {type = "item", name = "productivity-module-4", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "productivity-module-4",
        effects = {
            {type = "unlock-recipe", recipe = "productivity-module-4"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/productivity-4.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "processing-vitamelange",
           data_util.mod_prefix .. "space-supercomputer-1",
           "productivity-module-3",
           "production-science-pack",
        },
        unit = {
         count = 300,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { "production-science-pack", 1 },
         }
        },
    },
    {
        type = "module",
        name = "productivity-module-5",
        icon = "__space-exploration-graphics__/graphics/icons/modules/productivity-5.png",
        icon_size = 64,
        subgroup = "module-productivity",
        category = "productivity",
        tier = 5,
        order = "c[productivity]-e[productivity-module-5]",
        stack_size = 50,
        effect =
        {
          productivity = 0.12,
          consumption = 1.2,
          pollution = 0.12,
          speed = -0.3
        }
    },
    {
        type = "recipe",
        name = "productivity-module-5",
        ingredients = ingredients.productivity[5],
        energy_required = energy_required(5),
        results = {
          {type = "item", name = "productivity-module-5", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "productivity-module-5",
        effects = {
            {type = "unlock-recipe", recipe = "productivity-module-5"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/productivity-5.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "bioscrubber",
           "productivity-module-4",
        },
        unit = {
         count = 500,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "biological-science-pack-1", 1 },
         }
        },
    },
    {
        type = "module",
        name = "productivity-module-6",
        icon = "__space-exploration-graphics__/graphics/icons/modules/productivity-6.png",
        icon_size = 64,
        subgroup = "module-productivity",
        category = "productivity",
        tier = 6,
        order = "c[productivity]-f[productivity-module-6]",
        stack_size = 50,
        effect =
        {
          productivity = 0.14,
          consumption = 1.4,
          pollution = 0.14,
          speed = -0.35
        }
    },
    {
        type = "recipe",
        name = "productivity-module-6",
        ingredients = ingredients.productivity[6],
        energy_required = energy_required(6),
        results = {
          {type = "item", name = "productivity-module-6", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "productivity-module-6",
        effects = {
            {type = "unlock-recipe", recipe = "productivity-module-6"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/productivity-6.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "vitalic-reagent",
           "productivity-module-5",
        },
        unit = {
         count = 200,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "biological-science-pack-2", 1 },
         }
        },

    },
    {
        type = "module",
        name = "productivity-module-7",
        icon = "__space-exploration-graphics__/graphics/icons/modules/productivity-7.png",
        icon_size = 64,
        subgroup = "module-productivity",
        category = "productivity",
        tier = 7,
        order = "c[productivity]-f[productivity-module-7]",
        stack_size = 50,
        effect =
        {
          productivity = 0.16,
          consumption = 1.6,
          pollution = 0.16,
          speed = -0.4
        }
    },
    {
        type = "recipe",
        name = "productivity-module-7",
        ingredients = ingredients.productivity[7],
        energy_required = energy_required(7),
        results = {
          {type = "item", name = "productivity-module-7", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "productivity-module-7",
        effects = {
            {type = "unlock-recipe", recipe = "productivity-module-7"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/productivity-7.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "vitalic-epoxy",
           "productivity-module-6"
        },
        unit = {
         count = 500,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "biological-science-pack-3", 1 },
         }
        },

    },
    {
        type = "module",
        name = "productivity-module-8",
        icon = "__space-exploration-graphics__/graphics/icons/modules/productivity-8.png",
        icon_size = 64,
        subgroup = "module-productivity",
        category = "productivity",
        tier = 8,
        order = "c[productivity]-h[productivity-module-8]",
        stack_size = 50,
        effect =
        {
          productivity = 0.18,
          consumption = 1.8,
          pollution = 0.18,
          speed = -0.45
        }
    },
    {
        type = "recipe",
        name = "productivity-module-8",
        ingredients = ingredients.productivity[8],
        energy_required = energy_required(8),
        category = "crafting-with-fluid",
        results = {
          {type = "item", name = "productivity-module-8", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "productivity-module-8",
        effects = {
            {type = "unlock-recipe", recipe = "productivity-module-8"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/productivity-8.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "self-sealing-gel",
           "productivity-module-7"
        },
        unit = {
         count = 800,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "biological-science-pack-4", 1 },
         }
        },

    },
    {
        type = "module",
        name = "productivity-module-9",
        icon = "__space-exploration-graphics__/graphics/icons/modules/productivity-9.png",
        icon_size = 64,
        subgroup = "module-productivity",
        category = "productivity",
        tier = 9,
        order = "c[productivity]-i[productivity-module-9]",
        stack_size = 50,
        effect =
        {
          productivity = 0.2,
          consumption = 2,
          pollution = 0.2,
          speed = -0.5
        }
    },
    {
        type = "recipe",
        name = "productivity-module-9",
        ingredients = ingredients.productivity[9],
        energy_required = energy_required(9),
        category = "crafting-with-fluid",
        results = {
          {type = "item", name = "productivity-module-9", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "productivity-module-9",
        effects = {
            {type = "unlock-recipe", recipe = "productivity-module-9"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/productivity-9.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "self-sealing-gel",
           data_util.mod_prefix .. "deep-space-science-pack-1",
           data_util.mod_prefix .. "lattice-pressure-vessel",
           "productivity-module-8"
        },
        unit = {
         count = 1000,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "biological-science-pack-4", 1 },
           { data_util.mod_prefix .. "deep-space-science-pack-1", 1},
         }
        },

    },

    --speed
    {
        type = "recipe",
        name = "speed-module",
        ingredients = ingredients.speed[1],
        energy_required = energy_required(1),
        results = {
          {type = "item", name = "speed-module", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "recipe",
        name = "speed-module-2",
        ingredients = ingredients.speed[2],
        energy_required = energy_required(2),
        results = {
          {type = "item", name = "speed-module-2", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "recipe",
        name = "speed-module-3",
        ingredients = ingredients.speed[3],
        energy_required = energy_required(3),
        results = {
          {type = "item", name = "speed-module-3", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "module",
        name = "speed-module-4",
        icon = "__space-exploration-graphics__/graphics/icons/modules/speed-4.png",
        icon_size = 64,
        subgroup = "module-speed",
        category = "speed",
        tier = 4,
        order = "a[speed]-d[speed-module-4]",
        stack_size = 50,
        effect = {
          speed = 0.5,
          consumption = 1.1,
          pollution = 0.1
        }
    },
    {
        type = "recipe",
        name = "speed-module-4",
        ingredients = ingredients.speed[4],
        energy_required = energy_required(4),
        results = {
          {type = "item", name = "speed-module-4", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "speed-module-4",
        effects = {
            {type = "unlock-recipe", recipe = "speed-module-4"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/speed-4.png",
        icon_size = 128,
        order = "i-c-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "processing-iridium",
           "production-science-pack",
           "speed-module-3"
        },
        unit = {
         count = 300,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { "production-science-pack", 1 },
         }
        },

    },
    {
        type = "module",
        name = "speed-module-5",
        icon = "__space-exploration-graphics__/graphics/icons/modules/speed-5.png",
        icon_size = 64,
        subgroup = "module-speed",
        category = "speed",
        tier = 5,
        order = "a[speed]-e[speed-module-5]",
        stack_size = 50,
        effect = {
          speed = 0.6,
          consumption = 1.5,
          pollution = 0.12
        }
    },
    {
        type = "recipe",
        name = "speed-module-5",
        ingredients = ingredients.speed[5],
        energy_required = energy_required(5),
        results = {
          {type = "item", name = "speed-module-5", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "speed-module-5",
        effects = {
            {type = "unlock-recipe", recipe = "speed-module-5"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/speed-5.png",
        icon_size = 128,
        order = "i-c-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "heavy-girder",
           "speed-module-4"
        },
        unit = {
         count = 500,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "material-science-pack-1", 1 },
         }
        },

    },
    {
        type = "module",
        name = "speed-module-6",
        icon = "__space-exploration-graphics__/graphics/icons/modules/speed-6.png",
        icon_size = 64,
        subgroup = "module-speed",
        category = "speed",
        tier = 6,
        order = "a[speed]-f[speed-module-6]",
        stack_size = 50,
        effect = {
          speed = 0.7,
          consumption = 2,
          pollution = 0.14
        }
    },
    {
        type = "recipe",
        name = "speed-module-6",
        ingredients = ingredients.speed[6],
        energy_required = energy_required(6),
        results = {
          {type = "item", name = "speed-module-6", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "speed-module-6",
        effects = {
            {type = "unlock-recipe", recipe = "speed-module-6"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/speed-6.png",
        icon_size = 128,
        order = "i-c-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "heavy-bearing",
           "speed-module-5"
        },
        unit = {
         count = 200,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "material-science-pack-2", 1 },
         }
        },

    },
    {
        type = "module",
        name = "speed-module-7",
        icon = "__space-exploration-graphics__/graphics/icons/modules/speed-7.png",
        icon_size = 64,
        subgroup = "module-speed",
        category = "speed",
        tier = 7,
        order = "a[speed]-g[speed-module-7]",
        stack_size = 50,
        effect = {
          speed = 0.8,
          consumption = 2.6,
          pollution = 0.16
        }
    },
    {
        type = "recipe",
        name = "speed-module-7",
        ingredients = ingredients.speed[7],
        energy_required = energy_required(7),
        results = {
          {type = "item", name = "speed-module-7", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "speed-module-7",
        effects = {
            {type = "unlock-recipe", recipe = "speed-module-7"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/speed-7.png",
        icon_size = 128,
        order = "i-c-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "heavy-composite",
           "speed-module-6"
        },
        unit = {
         count = 500,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "material-science-pack-3", 1 },
         }
        },

    },
    {
        type = "module",
        name = "speed-module-8",
        icon = "__space-exploration-graphics__/graphics/icons/modules/speed-8.png",
        icon_size = 64,
        subgroup = "module-speed",
        category = "speed",
        tier = 8,
        order = "a[speed]-h[speed-module-8]",
        stack_size = 50,
        effect = {
          speed = 0.9,
          consumption = 3.3,
          pollution = 0.18
        }
    },
    {
        type = "recipe",
        name = "speed-module-8",
        category = "crafting-with-fluid",
        ingredients = ingredients.speed[8],
        energy_required = energy_required(8),
        results = {
          {type = "item", name = "speed-module-8", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "speed-module-8",
        effects = {
            {type = "unlock-recipe", recipe = "speed-module-8"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/speed-8.png",
        icon_size = 128,
        order = "i-c-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "heavy-assembly",
           "speed-module-7"
        },
        unit = {
         count = 800,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "material-science-pack-4", 1 },
         }
        },

    },
    {
        type = "module",
        name = "speed-module-9",
        icon = "__space-exploration-graphics__/graphics/icons/modules/speed-9.png",
        icon_size = 64,
        subgroup = "module-speed",
        category = "speed",
        tier = 9,
        order = "a[speed]-i[speed-module-9]",
        stack_size = 50,
        effect = {
          speed = 1,
          consumption = 4,
          pollution = 0.2
        }
    },
    {
        type = "recipe",
        name = "speed-module-9",
        category = "crafting-with-fluid",
        ingredients = ingredients.speed[9],
        energy_required = energy_required(9),
        results = {
          {type = "item", name = "speed-module-9", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "speed-module-9",
        effects = {
            {type = "unlock-recipe", recipe = "speed-module-9"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/speed-9.png",
        icon_size = 128,
        order = "i-c-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "deep-space-science-pack-1",
           data_util.mod_prefix .. "nanomaterial",
           "speed-module-8"
        },
        unit = {
         count = 1000,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "material-science-pack-4", 1 },
           { data_util.mod_prefix .. "deep-space-science-pack-1", 1 },
         }
        },

    },
      --efficiency
    {
        type = "recipe",
        name = "efficiency-module",
        ingredients = ingredients.efficiency[1],
        energy_required = energy_required(1),
        results = {
          {type = "item", name = "efficiency-module", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "recipe",
        name = "efficiency-module-2",
        ingredients = ingredients.efficiency[2],
        energy_required = energy_required(2),
        results = {
          {type = "item", name = "efficiency-module-2", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "recipe",
        name = "efficiency-module-3",
        ingredients = ingredients.efficiency[3],
        energy_required = energy_required(3),
        results = {
          {type = "item", name = "efficiency-module-3", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "module",
        name = "efficiency-module-4",
        icon = "__space-exploration-graphics__/graphics/icons/modules/efficiency-4.png",
        icon_size = 64,
        subgroup = "module-efficiency",
        category = "efficiency",
        tier = 4,
        order = "c[efficiency]-d[efficiency-module-4]",
        stack_size = 50,
        effect = {
          consumption = -1.7,
          pollution = -0.25,
        }
    },
    {
        type = "recipe",
        name = "efficiency-module-4",
        ingredients = ingredients.efficiency[4],
        energy_required = energy_required(4),
        results = {
          {type = "item", name = "efficiency-module-4", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "efficiency-module-4",
        effects = {
            {type = "unlock-recipe", recipe = "efficiency-module-4"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/efficiency-4.png",
        icon_size = 128,
        order = "i-g-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "processing-holmium",
           "utility-science-pack",
           "efficiency-module-3"
        },
        unit = {
         count = 300,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { "utility-science-pack", 1 },
         }
        },

    },
    {
        type = "module",
        name = "efficiency-module-5",
        icon = "__space-exploration-graphics__/graphics/icons/modules/efficiency-5.png",
        icon_size = 64,
        subgroup = "module-efficiency",
        category = "efficiency",
        tier = 5,
        order = "c[efficiency]-e[efficiency-module-5]",
        stack_size = 50,
        effect = {
          consumption = -2.7,
          pollution = -0.3,
        }
    },
    {
        type = "recipe",
        name = "efficiency-module-5",
        ingredients = ingredients.efficiency[5],
        energy_required = energy_required(5),
        results = {
          {type = "item", name = "efficiency-module-5", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "efficiency-module-5",
        effects = {
            {type = "unlock-recipe", recipe = "efficiency-module-5"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/efficiency-5.png",
        icon_size = 128,
        order = "i-g-a",
        upgrade = true,
        prerequisites = {
          data_util.mod_prefix .. "holmium-cable",
          "efficiency-module-4"
        },
        unit = {
         count = 500,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "energy-science-pack-1", 1 },
         }
        },

    },
    {
        type = "module",
        name = "efficiency-module-6",
        icon = "__space-exploration-graphics__/graphics/icons/modules/efficiency-6.png",
        icon_size = 64,
        subgroup = "module-efficiency",
        category = "efficiency",
        tier = 6,
        order = "c[efficiency]-f[efficiency-module-6]",
        stack_size = 50,
        effect = {
          consumption = -4,
          pollution = -0.35,
        }
    },
    {
        type = "recipe",
        name = "efficiency-module-6",
        ingredients = ingredients.efficiency[6],
        energy_required = energy_required(6),
        results = {
          {type = "item", name = "efficiency-module-6", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "efficiency-module-6",
        effects = {
            {type = "unlock-recipe", recipe = "efficiency-module-6"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/efficiency-6.png",
        icon_size = 128,
        order = "i-g-a",
        upgrade = true,
        prerequisites = {
          data_util.mod_prefix .. "holmium-solenoid",
          "efficiency-module-5"
        },
        unit = {
         count = 200,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "energy-science-pack-2", 1 },
         }
        },

    },
    {
        type = "module",
        name = "efficiency-module-7",
        icon = "__space-exploration-graphics__/graphics/icons/modules/efficiency-7.png",
        icon_size = 64,
        subgroup = "module-efficiency",
        category = "efficiency",
        tier = 7,
        order = "c[efficiency]-g[efficiency-module-7]",
        stack_size = 50,
        effect = {
          consumption = -5.6,
          pollution = -0.4,
        }
    },
    {
        type = "recipe",
        name = "efficiency-module-7",
        ingredients = ingredients.efficiency[7],
        energy_required = energy_required(7),
        results = {
          {type = "item", name = "efficiency-module-7", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "efficiency-module-7",
        effects = {
            {type = "unlock-recipe", recipe = "efficiency-module-7"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/efficiency-7.png",
        icon_size = 128,
        order = "i-g-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "quantum-processor",
           "efficiency-module-6"
        },
        unit = {
         count = 500,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "energy-science-pack-3", 1 },
         }
        },

    },
    {
        type = "module",
        name = "efficiency-module-8",
        icon = "__space-exploration-graphics__/graphics/icons/modules/efficiency-8.png",
        icon_size = 64,
        subgroup = "module-efficiency",
        category = "efficiency",
        tier = 8,
        order = "c[efficiency]-h[efficiency-module-8]",
        stack_size = 50,
        effect = {
          consumption = -7.6,
          pollution = -0.45
        }
    },
    {
        type = "recipe",
        name = "efficiency-module-8",
        category = "crafting-with-fluid",
        ingredients = ingredients.efficiency[8],
        energy_required = energy_required(8),
        results = {
          {type = "item", name = "efficiency-module-8", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "efficiency-module-8",
        effects = {
            {type = "unlock-recipe", recipe = "efficiency-module-8"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/efficiency-8.png",
        icon_size = 128,
        order = "i-g-a",
        upgrade = true,
        prerequisites = {
           data_util.mod_prefix .. "dynamic-emitter",
           "efficiency-module-7"
        },
        unit = {
         count = 800,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "energy-science-pack-4", 1 },
         }
        },

    },
    {
        type = "module",
        name = "efficiency-module-9",
        icon = "__space-exploration-graphics__/graphics/icons/modules/efficiency-9.png",
        icon_size = 64,
        subgroup = "module-efficiency",
        category = "efficiency",
        tier = 9,
        order = "c[efficiency]-i[efficiency-module-9]",
        stack_size = 50,
        effect = {
          consumption = -10,
          pollution = -0.5
        }
    },
    {
        type = "recipe",
        name = "efficiency-module-9",
        category = "crafting-with-fluid",
        ingredients = ingredients.efficiency[9],
        energy_required = 512,
        results = {
          {type = "item", name = "efficiency-module-9", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "efficiency-module-9",
        effects = {
            {type = "unlock-recipe", recipe = "efficiency-module-9"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/efficiency-9.png",
        icon_size = 128,
        order = "i-g-a",
        upgrade = true,
        prerequisites = {
            data_util.mod_prefix .. "antimatter-production",
            "efficiency-module-8"
        },
        unit = {
         count = 1000,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "energy-science-pack-4", 1 },
           { data_util.mod_prefix .. "deep-space-science-pack-1", 1 },
         }
        },

    },
})

-- show modules 4-9 in the vanilla beacon as module 3 (instead of an empty slot)
for base_name, prototype_source in pairs({
  ["speed-module"] = data.raw["module"]["speed-module-3"],
  ["efficiency-module"] = data.raw["module"]["efficiency-module-3"],
}) do
  for tier = 4, 9 do
    local prototype_destination = data.raw["module"][module_util.module_name(base_name, tier)]
    for _, key in ipairs({"beacon_tint", "art_style", "requires_beacon_alt_mode"}) do
      prototype_destination[key] = prototype_source[key]
    end
  end
end

