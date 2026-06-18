local data_util = require("data_util")
local module_util = require("prototypes/phase-multi/module-util")

local modules_per_tier = module_util.modules_per_tier
local energy_required = module_util.energy_required

if mods["quality"] then

  data.raw.technology["quality-module"].icon = "__space-exploration-graphics__/graphics/technology/modules/quality-1.png"
  data.raw.technology["quality-module"].icon_size = 128
  data.raw.technology["quality-module-2"].icon = "__space-exploration-graphics__/graphics/technology/modules/quality-2.png"
  data.raw.technology["quality-module-2"].icon_size = 128
  data.raw.technology["quality-module-3"].icon = "__space-exploration-graphics__/graphics/technology/modules/quality-3.png"
  data.raw.technology["quality-module-3"].icon_size = 128

  data:extend{{
    type = "item-subgroup",
    name = "module-quality",
    group = "production",
    order = "z-m-e"
  }}

  data.raw.module["quality-module"].icon = "__space-exploration-graphics__/graphics/icons/modules/quality-1.png"
  data.raw.module["quality-module"].icon_size = 64
  data.raw.module["quality-module"].subgroup = "module-quality"

  data.raw.module["quality-module-2"].icon = "__space-exploration-graphics__/graphics/icons/modules/quality-2.png"
  data.raw.module["quality-module-2"].icon_size = 64
  data.raw.module["quality-module-2"].subgroup = "module-quality"

  data.raw.module["quality-module-3"].icon = "__space-exploration-graphics__/graphics/icons/modules/quality-3.png"
  data.raw.module["quality-module-3"].icon_size = 64
  data.raw.module["quality-module-3"].subgroup = "module-quality"

  -- # space age
  -- speed 20 30 50
  -- efficiency -30 -40 -50
  -- productivity 4 6 10
  -- quality 1 2 2.5

  -- # space exploration
  -- speed 10 + 10 * level
  -- productivity 2 + 2 * level
  -- efficiency unclear pattern

  -- therefore 0.5 + 0.5 * level (so 1 till 5) seems sensible (well, a little op, but there's no normal recycling)

  local effects = {
    speed = {
      [1] = {quality = -0.10},
      [2] = {quality = -0.15},
      [3] = {quality = -0.20},
      [4] = {quality = -0.25},
      [5] = {quality = -0.30},
      [6] = {quality = -0.35},
      [7] = {quality = -0.40},
      [8] = {quality = -0.45},
      [9] = {quality = -0.50},
    },
    quality = {
      [1] = {speed = -0.05, quality = 0.10},
      [2] = {speed = -0.05, quality = 0.15},
      [3] = {speed = -0.05, quality = 0.20},
      [4] = {speed = -0.05, quality = 0.25},
      [5] = {speed = -0.05, quality = 0.30},
      [6] = {speed = -0.05, quality = 0.35},
      [7] = {speed = -0.05, quality = 0.40},
      [8] = {speed = -0.05, quality = 0.45},
      [9] = {speed = -0.05, quality = 0.50},
    }
  }

  -- warning: manual meld that only does quality
  for tier, to_meld in pairs(effects.speed) do
    data.raw.module[module_util.module_name("speed-module", tier)].effect.quality = to_meld.quality
  end

  -- not much thought/balancing went into these, feel free to tweak them,
  -- i am just going for a sort of space theme since it has space colors.
  local ingredients = {
    quality = {
      [1] = {
        {type = "item", name = "electronic-circuit", amount = 20},
        {type = "item", name = "plastic-bar", amount = 10},
      },
      [2] = {
        {type = "item", name = "quality-module", amount = modules_per_tier},
        {type = "item", name = "advanced-circuit", amount = 20},
        {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 2},
      },
      [3] = {
        {type = "item", name = "quality-module-2", amount = modules_per_tier},
        {type = "item", name = "processing-unit", amount = 20},
        {type = "item", name = data_util.mod_prefix .. "water-ice", amount = 20},
      },
      [4] = {
        {type = "item", name = "quality-module-3", amount = modules_per_tier},
        {type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 90},
        {type = "item", name = data_util.mod_prefix .. "machine-learning-data", amount = 1},
      },
      [5] = {
        {type = "item", name = "quality-module-4", amount = modules_per_tier},
        {type = "item", name = data_util.mod_prefix .. "aeroframe-pole", amount = 100},
        {type = "item", name = data_util.mod_prefix .. "astronomic-catalogue-1", amount = 1}
      },
      [6] = {
        {type = "item", name = "quality-module-5", amount = modules_per_tier},
        {type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 80},
        {type = "item", name = data_util.mod_prefix .. "astronomic-catalogue-2", amount = 2}
      },
      [7] = {
        {type = "item", name = "quality-module-6", amount = modules_per_tier},
        {type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 60},
        {type = "item", name = data_util.mod_prefix .. "astronomic-catalogue-3", amount = 4}
      },
      [8] = {
        {type = "item", name = "quality-module-7", amount = modules_per_tier},
        {type = "item", name = data_util.mod_prefix .. "lattice-pressure-vessel", amount = 80},
        {type = "item", name = data_util.mod_prefix .. "astronomic-catalogue-4", amount = 8},
        {type = "fluid", name = data_util.mod_prefix .. "methane-gas", amount = 500},
      },
      [9] = {
        {type = "item", name = "quality-module-8", amount = modules_per_tier},
        {type = "item", name = data_util.mod_prefix .. "naquium-crystal", amount = 500},
        {type = "item", name = data_util.mod_prefix .. "deep-catalogue-1", amount = 10},
        {type = "fluid", name = data_util.mod_prefix .. "ion-stream", amount = 1000},
      },
    }
  }

  data_util.tech_add_prerequisites("quality-module", {"plastics"})
  data_util.tech_remove_ingredients("quality-module-3", {"production-science-pack"})
  data_util.tech_remove_prerequisites("quality-module-3", {"production-science-pack"})
  data_util.tech_add_prerequisites("quality-module-3", {"space-science-pack"})
  data_util.tech_add_ingredients("quality-module-3", {"space-science-pack"})

  data.raw.module["quality-module"].effect = effects.quality[1]
  data.raw.module["quality-module-2"].effect = effects.quality[2]
  data.raw.module["quality-module-3"].effect = effects.quality[3]

  data.raw.module["quality-module"].order = "d[quality]-a[quality-module-1]"
  data.raw.module["quality-module-2"].order = "d[quality]-b[quality-module-2]"
  data.raw.module["quality-module-3"].order = "d[quality]-c[quality-module-3]"

  data:extend{

    --quality
    {
        type = "recipe",
        name = "quality-module",
        ingredients = ingredients.quality[1],
        energy_required = energy_required(1),
        results = {
          {type = "item", name = "quality-module", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "recipe",
        name = "quality-module-2",
        ingredients = ingredients.quality[2],
        energy_required = energy_required(2),
        results = {
          {type = "item", name = "quality-module-2", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "recipe",
        name = "quality-module-3",
        ingredients = ingredients.quality[3],
        energy_required = energy_required(3),
        results = {
          {type = "item", name = "quality-module-3", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "module",
        name = "quality-module-4",
        icon = "__space-exploration-graphics__/graphics/icons/modules/quality-4.png",
        icon_size = 64,
        subgroup = "module-quality",
        category = "quality",
        tier = 4,
        order = "d[quality]-d[quality-module-4]",
        stack_size = 50,
        effect = effects.quality[4],
    },
    {
        type = "recipe",
        name = "quality-module-4",
        ingredients = ingredients.quality[4],
        energy_required = energy_required(4),
        results = {
          {type = "item", name = "quality-module-4", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "quality-module-4",
        effects = {
            {type = "unlock-recipe", recipe = "quality-module-4"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/quality-4.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
          "quality-module-3",
          "utility-science-pack",
           data_util.mod_prefix .. "processing-beryllium",
           data_util.mod_prefix .. "space-supercomputer-1",
        },
        unit = {
         count = 300,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
          --  { "rocket-science-pack", 1 }, -- added automatically "somewhere"
           { "utility-science-pack", 1 },
         }
        },
    },
    {
        type = "module",
        name = "quality-module-5",
        icon = "__space-exploration-graphics__/graphics/icons/modules/quality-5.png",
        icon_size = 64,
        subgroup = "module-quality",
        category = "quality",
        tier = 5,
        order = "d[quality]-e[quality-module-5]",
        stack_size = 50,
        effect = effects.quality[5],
    },
    {
        type = "recipe",
        name = "quality-module-5",
        ingredients = ingredients.quality[5],
        energy_required = energy_required(5),
        results = {
          {type = "item", name = "quality-module-5", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "quality-module-5",
        effects = {
            {type = "unlock-recipe", recipe = "quality-module-5"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/quality-5.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
          "quality-module-4",
           data_util.mod_prefix .. "aeroframe-pole",
        },
        unit = {
         count = 500,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           --  { "rocket-science-pack", 1 }, -- added automatically "somewhere"
           { data_util.mod_prefix .. "astronomic-science-pack-1", 1 },
         }
        },
    },
    {
        type = "module",
        name = "quality-module-6",
        icon = "__space-exploration-graphics__/graphics/icons/modules/quality-6.png",
        icon_size = 64,
        subgroup = "module-quality",
        category = "quality",
        tier = 6,
        order = "d[quality]-f[quality-module-6]",
        stack_size = 50,
        effect = effects.quality[6],
    },
    {
        type = "recipe",
        name = "quality-module-6",
        ingredients = ingredients.quality[6],
        energy_required = energy_required(6),
        results = {
          {type = "item", name = "quality-module-6", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "quality-module-6",
        effects = {
            {type = "unlock-recipe", recipe = "quality-module-6"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/quality-6.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
          "quality-module-5",
           data_util.mod_prefix .. "aeroframe-scaffold",
        },
        unit = {
         count = 200,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           --  { "rocket-science-pack", 1 }, -- added automatically "somewhere"
           { data_util.mod_prefix .. "astronomic-science-pack-2", 1 },
         }
        },

    },
    {
        type = "module",
        name = "quality-module-7",
        icon = "__space-exploration-graphics__/graphics/icons/modules/quality-7.png",
        icon_size = 64,
        subgroup = "module-quality",
        category = "quality",
        tier = 7,
        order = "d[quality]-f[quality-module-7]",
        stack_size = 50,
        effect = effects.quality[7],
    },
    {
        type = "recipe",
        name = "quality-module-7",
        ingredients = ingredients.quality[7],
        energy_required = energy_required(7),
        results = {
          {type = "item", name = "quality-module-7", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "quality-module-7",
        effects = {
            {type = "unlock-recipe", recipe = "quality-module-7"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/quality-7.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
          "quality-module-6",
           data_util.mod_prefix .. "aeroframe-bulkhead",
        },
        unit = {
         count = 500,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           --  { "rocket-science-pack", 1 }, -- added automatically "somewhere"
           { data_util.mod_prefix .. "astronomic-science-pack-3", 1 },
         }
        },

    },
    {
        type = "module",
        name = "quality-module-8",
        icon = "__space-exploration-graphics__/graphics/icons/modules/quality-8.png",
        icon_size = 64,
        subgroup = "module-quality",
        category = "quality",
        tier = 8,
        order = "d[quality]-h[quality-module-8]",
        stack_size = 50,
        effect = effects.quality[8],
    },
    {
        type = "recipe",
        name = "quality-module-8",
        ingredients = ingredients.quality[8],
        energy_required = energy_required(8),
        category = "crafting-with-fluid",
        results = {
          {type = "item", name = "quality-module-8", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "quality-module-8",
        effects = {
            {type = "unlock-recipe", recipe = "quality-module-8"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/quality-8.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
          "quality-module-7",
           data_util.mod_prefix .. "lattice-pressure-vessel",
        },
        unit = {
         count = 800,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           --  { "rocket-science-pack", 1 }, -- added automatically "somewhere"
           { data_util.mod_prefix .. "astronomic-science-pack-4", 1 },
         }
        },

    },
    {
        type = "module",
        name = "quality-module-9",
        icon = "__space-exploration-graphics__/graphics/icons/modules/quality-9.png",
        icon_size = 64,
        subgroup = "module-quality",
        category = "quality",
        tier = 9,
        order = "d[quality]-i[quality-module-9]",
        stack_size = 50,
        effect = effects.quality[9],
    },
    {
        type = "recipe",
        name = "quality-module-9",
        ingredients = ingredients.quality[9],
        energy_required = energy_required(9),
        category = "crafting-with-fluid",
        results = {
          {type = "item", name = "quality-module-9", amount = 1},
        },
        enabled = false,
        always_show_products = true,
        always_show_made_in = true,
    },
    {
        type = "technology",
        name = "quality-module-9",
        effects = {
            {type = "unlock-recipe", recipe = "quality-module-9"}
        },
        icon = "__space-exploration-graphics__/graphics/technology/modules/quality-9.png",
        icon_size = 128,
        order = "i-e-a",
        upgrade = true,
        prerequisites = {
          "quality-module-8",
           data_util.mod_prefix .. "spaceship",
           data_util.mod_prefix .. "deep-space-science-pack-1",
        },
        unit = {
         count = 1000,
         time = 10,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           --  { "rocket-science-pack", 1 }, -- added automatically "somewhere"
           { data_util.mod_prefix .. "astronomic-science-pack-4", 1},
           { data_util.mod_prefix .. "deep-space-science-pack-1", 1},
         }
        },

    },

  }

  table.insert(se_procedural_tech_exclusions, "quality-module")
  table.insert(se_procedural_tech_exclusions, "quality-module-2")
  table.insert(se_procedural_tech_exclusions, "quality-module-3")
  table.insert(se_procedural_tech_exclusions, "quality-module-4")
  table.insert(se_procedural_tech_exclusions, "quality-module-5")
  table.insert(se_procedural_tech_exclusions, "quality-module-6")
  table.insert(se_procedural_tech_exclusions, "quality-module-7")
  table.insert(se_procedural_tech_exclusions, "quality-module-8")
  table.insert(se_procedural_tech_exclusions, "quality-module-9")

  -- could not think of a nice spot for them so i got creative,
  -- epic might unlock a little too early considering how easy you can reach the canary prospector,
  -- but then again there is currently no official support for it so it might be interesting for now.
  data_util.tech_remove_prerequisites("epic-quality", {"production-science-pack", "utility-science-pack"})
  data.raw.technology["epic-quality"].unit = nil
  data.raw.technology["epic-quality"].research_trigger = {
    type = "capture-spawner",
    entity = data_util.mod_prefix .. "spaceship-console",
  }
  data_util.tech_remove_prerequisites("legendary-quality", {"space-science-pack"})
  data.raw.technology["legendary-quality"].unit = nil
  data.raw.technology["legendary-quality"].research_trigger = {
    type = "capture-spawner",
    entity = data_util.mod_prefix .. "spaceship-console-alt",
  }
end
