local data_util = require("data_util")
local RecipeTints = require("prototypes/recipe-tints")

data:extend({
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "beryllium-sulfate",
    main_product = data_util.mod_prefix .. "beryllium-sulfate",
    results = {
      {type = "item", name = data_util.mod_prefix .. "beryllium-sulfate", amount = 1}, -- 4
      {type = "item", name = SEItemNames.get_sand_name(), probability = 0.25, amount_min = 1, amount_max = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "fluid", name = "water", amount = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
    },
    energy_required = 2,
    ingredients = {
      {type = "fluid", name="sulfuric-acid", amount = 1}, -- 1 per 4 plate
      {type = "item", name = data_util.mod_prefix .. "beryllium-ore", amount = 4}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    crafting_machine_tint = RecipeTints.beryllium_tint,
    order = "a[beryllium]-c[beryllium-sulfate]-a[beryllium-sulfate]",
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "beryllium-hydroxide",
    main_product = data_util.mod_prefix .. "beryllium-hydroxide",
    results = {
      {type = "fluid", name = data_util.mod_prefix .. "beryllium-hydroxide", amount = 50}, --2
    },
    energy_required = 15,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 1}, -- 1 per 10 plate
      {type = "fluid", name="water", amount = 25},
      {type = "item", name = data_util.mod_prefix .. "beryllium-sulfate", amount = 25}
    },
    subgroup = "beryllium",
    allow_productivity = true,
    enabled = false,
    always_show_made_in = true,
    crafting_machine_tint = RecipeTints.beryllium_tint,
    order = "a[beryllium]-d[beryllium-hydroxide]-a[beryllium-hydroxide]",
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "beryllium-powder",
    main_product = data_util.mod_prefix .. "beryllium-powder",
    results = {
      {type = "item", name = data_util.mod_prefix .. "beryllium-powder", amount = 4}, -- 2
      {type = "fluid", name = "water", amount = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
    },
    energy_required = 1,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "beryllium-hydroxide", amount = 4},
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    crafting_machine_tint = RecipeTints.beryllium_tint,
    order = "a[beryllium]-e[beryllium-powder]-a[beryllium-powder]"
  },
  {
    type = "recipe",
    category = "smelting",
    name = data_util.mod_prefix .. "molten-beryllium",
    subgroup = "beryllium",
    results = {
      {type = "fluid", name = data_util.mod_prefix .. "molten-beryllium", amount = 250}, --0.4
    },
    energy_required = 75,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "pyroflux", amount = 10}, -- 1 block) per 10 plate
      {type = "item", name = data_util.mod_prefix .. "beryllium-powder", amount = 50},
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[beryllium]-f[molten-beryllium]-a[molten-beryllium]"
  },
  {
    type = "recipe",
    category = "casting",
    name = data_util.mod_prefix .. "beryllium-ingot",
    results = {
      {type = "item", name = data_util.mod_prefix .. "beryllium-ingot", amount = 1}, -- 100
    },
    energy_required = 25,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "molten-beryllium", amount = 250},
      {type = "item", name = SEItemNames.get_sand_name(), amount = 2},
    },
    enabled = false,
    always_show_made_in = true,
    order = "a[beryllium]-g[beryllium-ingot]-a[beryllium-ingot]"
  },
  {
    type = "recipe",
    category = "smelting",
    name = data_util.mod_prefix .. "beryllium-ingot-no-vulcanite",
    localised_name = {"item-name."..data_util.mod_prefix.."beryllium-ingot"},
    results = {
      {type = "item", name = data_util.mod_prefix .. "beryllium-ingot", amount = 1},
    },
    icons = data_util.sub_icons(data.raw.item[data_util.mod_prefix .. "beryllium-ingot"].icon,
                                data.raw.item["coal"].icon),
    energy_required = 25,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "beryllium-powder", amount = 100},
      {type = "item", name = "coal", amount = 10},
      {type = "item", name = SEItemNames.get_sand_name(), amount = 10},
    },
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    hide_from_signal_gui = false,
    order = "a[beryllium]-g[beryllium-ingot]-b[beryllium-ingot]"
  },
  {
    type = "recipe",
    category = "crafting",
    name = data_util.mod_prefix .. "beryllium-plate",
    localised_name = {"item-name."..data_util.mod_prefix.."beryllium-plate"},
    results = {
      {type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 10}, -- 10
    },
    energy_required = 5,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "beryllium-ingot", amount = 1}
    },
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    order = "a[beryllium]-h[beryllium-plate]-a[beryllium-plate]"
  },
  {
    type = "recipe",
    category = "pulverising",
    name = data_util.mod_prefix .. "cryonite-powder",
    main_product = data_util.mod_prefix .. "cryonite-powder",
    results = {
      {type = "item", name = data_util.mod_prefix .. "cryonite-powder", amount = 1}, --1
      {type = "item", name = SEItemNames.get_sand_name(), amount_min = 1, amount_max = 1, probability = 0.25, ignored_by_stats = 1, ignored_by_productivity = 1},
    },
    energy_required = 0.5,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "cryonite", amount = 1}
    },
    enabled = false,
    always_show_made_in = true,
    allow_productivity = true,
    order = "a[cryonite]-c[cryonite-powder]-a[cryonite-powder]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "cryonite-crystal",
    main_product = data_util.mod_prefix .. "cryonite-crystal",
    results = {
      {type = "item", name = data_util.mod_prefix .. "cryonite-crystal", amount = 1}, -- 4
      {type = "fluid", name="water", amount = 2, ignored_by_stats = 2, ignored_by_productivity = 2},
    },
    energy_required = 3,
    ingredients = {
      {type = "fluid", name="steam", amount = 20, ignored_by_stats = 20},
      {type = "item", name = data_util.mod_prefix .. "cryonite-powder", amount = 4}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    crafting_machine_tint = RecipeTints.cryonite_tint,
    order = "a[cryonite]-d[cryonite-crystal]-a[cryonite-crystal]"
  },
  {
    type = "recipe",
    category = "smelting",
    name = data_util.mod_prefix .. "cryonite-rod",
    results = {
      {type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 1}, -- 10
    },
    energy_required = 10,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "cryonite-crystal", amount = 2},
      {type = "item", name = data_util.mod_prefix .. "cryonite-powder", amount = 2},
      {type = "fluid", name = "heavy-oil", amount = 1},
    },
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_productivity = true,
    order = "a[cryonite]-e[cryonite-rod]-a[cryonite-rod]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "cryonite-ion-exchange-beads",
    results = {
      {type = "item", name = data_util.mod_prefix .. "cryonite-ion-exchange-beads", amount = 10},
    },
    energy_required = 10,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 1},
      {type = "item", name = "plastic-bar", amount = 1},
      {type = "fluid", name = "sulfuric-acid", amount = 5},
      {type = "fluid", name = "steam", amount = 5},
    },
    crafting_machine_tint = RecipeTints.cryonite_tint,
    enabled = false,
    always_show_made_in = true,
    allow_productivity = true,
    order = "a[cryonite]-e[cryonite-rod]-a[cryonite-ion]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "cryonite-slush",
    results = {
      {type = "fluid", name = data_util.mod_prefix .. "cryonite-slush", amount = 10},
    },
    energy_required = 5,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 1},
      {type = "fluid", name = "sulfuric-acid", amount = 1},
    },
    crafting_machine_tint = RecipeTints.cryonite_tint,
    subgroup = "cryonite",
    enabled = false,
    always_show_made_in = true,
    allow_as_intermediate = false,
    allow_productivity = true,
    order = "a[cryonite]-f[cryonite-slush]-a[cryonite-slush]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "cryonite-lubricant",
    localised_name = {"fluid-name.lubricant"},
    results = {
      {type = "fluid", name = "lubricant", amount = 20},
    },
    energy_required = 5,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "cryonite-slush", amount = 10},
      {type = "fluid", name = "heavy-oil", amount = 1},
    },
    icons = data_util.sub_icons(data.raw.fluid["lubricant"].icon,
                                data.raw.fluid[data_util.mod_prefix .. "cryonite-slush"].icon),
    subgroup = "oil",
    crafting_machine_tint = data.raw["recipe"]["lubricant"].crafting_machine_tint,
    enabled = false,
    always_show_made_in = true,
    allow_productivity = true,
    allow_as_intermediate = false,
    hide_from_signal_gui = false,
    order = "a[oil]-f[lube]-b[cryo-lube]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "water-ice",
    localised_name = {"item-name."..data_util.mod_prefix.."water-ice"},
    results = {
      {type = "item", name = data_util.mod_prefix .. "water-ice", amount = 1},
    },
    energy_required = 1,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "cryonite-slush", amount = 1},
      {type = "fluid", name = "water", amount = 100},
    },
    crafting_machine_tint = RecipeTints.cryonite_tint,
    subgroup = "water",
    enabled = false,
    always_show_made_in = true,
    allow_as_intermediate = false,
    order="a[water]-b[water-ice]-a[water-ice]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "methane-ice",
    localised_name = {"item-name."..data_util.mod_prefix.."methane-ice"},
    results = {
      {type = "item", name = data_util.mod_prefix .. "methane-ice", amount = 10},
    },
    energy_required = 1,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "cryonite-slush", amount = 10},
      {type = "fluid", name = data_util.mod_prefix .. "methane-gas", amount = 100},
    },
    crafting_machine_tint = RecipeTints.methane_tint,
    subgroup = "chemical",
    enabled = false,
    always_show_made_in = true,
    allow_as_intermediate = false,
    order = "a[oil]-g[methane]-a[methane]",
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "steam-to-water",
    localised_name = {"fluid-name.water"},
    results = {
      {type = "fluid", name = "water", amount = 99},
    },
    energy_required = 5,
    ingredients = {
      {type = "fluid", name = "steam", amount = 1000},
    },
    icons = data_util.sub_icons(
      data.raw.fluid.water.icon,
      {icon = data.raw.fluid.steam.icon}
    ),
    subgroup = "water",
    enabled = false,
    always_show_made_in = true,
    allow_as_intermediate = false,
    hide_from_signal_gui = false,
    crafting_machine_tint = RecipeTints.water_tint,
    order = "a[water]-a[water]-c[steam-to-water]"
  },

  {
    type = "recipe",
    category = "pulverising",
    name = data_util.mod_prefix .. "holmium-ore-crushed",
    main_product = data_util.mod_prefix .. "holmium-ore-crushed",
    results = {
      {type = "item", name = data_util.mod_prefix .. "holmium-ore-crushed", amount = 1}, -- 2
      {type = "item", name = "stone", amount_min = 1, amount_max = 1, probability = 0.25, ignored_by_stats = 1, ignored_by_productivity = 1}
    },
    energy_required = 1,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "holmium-ore", amount = 2}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[holmium]-c[holmium-crushed]-a[holmium-crushed]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "holmium-chloride",
    main_product = data_util.mod_prefix .. "holmium-chloride",
    results = {
      {type = "item", name = data_util.mod_prefix .. "holmium-chloride", probability = 0.25, amount_min = 1, amount_max = 1}, -- 4
      {type = "item", name = data_util.mod_prefix .. "cryonite-ion-exchange-beads", probability = 0.5, amount_min = 1, amount_max = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "item", name = data_util.mod_prefix .. "holmium-ore-crushed", probability = 0.5, amount_min = 1, amount_max = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "item", name = SEItemNames.get_sand_name(), probability = 0.1, amount_min = 1, amount_max = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
    },
    energy_required = 1,
    ingredients = {
      {type = "fluid", name="water", amount = 2, ignored_by_stats = 2},
      {type = "item", name = data_util.mod_prefix .. "cryonite-ion-exchange-beads", amount = 1, ignored_by_stats = 1 },
      {type = "item", name = data_util.mod_prefix .. "holmium-ore-crushed", amount = 1, ignored_by_stats = 1 }
    },
    allow_productivity = true,
    enabled = false,
    always_show_made_in = true,
    crafting_machine_tint = RecipeTints.holmium_tint,
    order = "a[holmium]-d[holmium-chloride]-a[holmium-chloride]"
  },
  {
    type = "recipe",
    category = "centrifuging",
    name = data_util.mod_prefix .. "holmium-powder",
    main_product = data_util.mod_prefix .. "holmium-powder",
    results = {
      {type = "item", name = data_util.mod_prefix .. "holmium-powder", amount = 10}, -- 2
    },
    energy_required = 1,
    ingredients = {
      {type = "item", name = "copper-cable", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "holmium-chloride", amount = 5}
    },
    enabled = false,
    always_show_made_in = true,
    crafting_machine_tint = RecipeTints.holmium_tint,
    allow_productivity = true,
    order = "a[holmium]-e[holmium-powder]-a[holmium-powder]"
  },
  {
    type = "recipe",
    category = "smelting",
    name = data_util.mod_prefix .. "molten-holmium",
    subgroup = "holmium",
    results = {
      {type = "fluid", name = data_util.mod_prefix .. "molten-holmium", amount = 250}, -- 0.4
    },
    energy_required = 75,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "pyroflux", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "holmium-powder", amount = 50},
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[holmium]-f[molten-holmium]-a[molten-holmium]"
  },
  {
    type = "recipe",
    category = "casting",
    name = data_util.mod_prefix .. "holmium-ingot",
    results = {
      {type = "item", name = data_util.mod_prefix .. "holmium-ingot", amount = 1}, -- 100
    },
    energy_required = 25,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "molten-holmium", amount = 250},
      {type = "item", name = SEItemNames.get_sand_name(), amount = 2},
    },
    enabled = false,
    always_show_made_in = true,
    order = "a[holmium]-g[holmium-ingot]-a[holmium-ingot]"
  },
  {
    type = "recipe",
    category = "smelting",
    name = data_util.mod_prefix .. "holmium-ingot-no-vulcanite",
    localised_name = {"item-name."..data_util.mod_prefix.."holmium-ingot"},
    results = {
      {type = "item", name = data_util.mod_prefix .. "holmium-ingot", amount = 1},
    },
    icons = data_util.sub_icons(data.raw.item[data_util.mod_prefix .. "holmium-ingot"].icon,
                                data.raw.item["coal"].icon),
    energy_required = 25,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "holmium-powder", amount = 100},
      {type = "item", name = "coal", amount = 10},
      {type = "item", name = SEItemNames.get_sand_name(), amount = 10},
    },
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    hide_from_signal_gui = false,
    order = "a[holmium]-g[holmium-ingot]-b[holmium-ingot]"
  },
  {
    type = "recipe",
    category = "crafting",
    name = data_util.mod_prefix .. "holmium-plate",
    localised_name = {"item-name."..data_util.mod_prefix.."holmium-plate"},
    results = {
      {type = "item", name = data_util.mod_prefix .. "holmium-plate", amount = 10}, -- 10
    },
    energy_required = 2.5,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "holmium-ingot", amount = 1}
    },
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    order = "a[holmium]-h[holmium-plate]-a[holmium-plate]"
  },
  {
    type = "recipe",
    category = "pulverising",
    name = data_util.mod_prefix .. "iridium-ore-crushed",
    main_product = data_util.mod_prefix .. "iridium-ore-crushed",
    results = {
      {type = "item", name = data_util.mod_prefix .. "iridium-ore", amount_min = 1, amount_max = 1, probability = 0.4, ignored_by_stats = 1, ignored_by_productivity = 1}, -- uses 0.6 -- catalyst trick: a higher catalyst amount than the result ends up with a "consumed" stat
      {type = "item", name = data_util.mod_prefix .. "iridium-ore-crushed", amount_min = 1, amount_max = 1, probability = 0.3}, -- 2 -- produces 0.3
      {type = "item", name = SEItemNames.get_sand_name(), amount_min = 1, amount_max = 1, probability = 0.1, ignored_by_stats = 1, ignored_by_productivity = 1},
    },
    energy_required = 1,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "iridium-ore", amount = 1, ignored_by_stats = 1}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[iridium]-c[iridium-crushed]-a[iridium-crushed]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "iridium-powder",
    main_product = data_util.mod_prefix .. "iridium-powder",
    results = {
      {type = "item", name = data_util.mod_prefix .. "iridium-powder", probability = 0.5, amount_min = 1, amount_max = 1},  -- 2
      {type = "item", name = data_util.mod_prefix .. "vulcanite-ion-exchange-beads", probability = 0.66, amount_min = 1, amount_max = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "item", name = data_util.mod_prefix .. "iridium-ore-crushed", probability = 0.5, amount_min = 1, amount_max = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "item", name = SEItemNames.get_sand_name(), probability = 0.1, amount_min = 1, amount_max = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
    },
    energy_required = 1,
    ingredients = {
      {type = "fluid", name="water", amount = 2, ignored_by_stats = 2},
      {type = "item", name = data_util.mod_prefix .. "vulcanite-ion-exchange-beads", amount = 1, ignored_by_stats = 1,},
      {type = "item", name = data_util.mod_prefix .. "iridium-ore-crushed", amount = 1, ignored_by_stats = 1,}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    crafting_machine_tint = RecipeTints.iridium_tint,
    order = "a[iridium]-d[iridium-powder]-a[iridium-powder]"
  },
  {
    type = "recipe",
    category = "centrifuging",
    name = data_util.mod_prefix .. "iridium-blastcake",
    results = {
      {type = "item", name = data_util.mod_prefix .. "iridium-blastcake", amount = 4}, -- 10
    },
    energy_required = 20,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "iridium-powder", amount = 20},
      {type = "item", name = data_util.mod_prefix .. "vulcanite-enriched", amount = 1},
    },
    crafting_machine_tint = RecipeTints.iridium_centri_tint,
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[iridium]-e[iridium-blastcake]-a[iridium-blastcake]"
  },
  {
    type = "recipe",
    category = "smelting",
    name = data_util.mod_prefix .. "iridium-ingot",
    main_product = data_util.mod_prefix .. "iridium-ingot",
    results = {
      {type = "fluid", name="steam", amount = 5, ignored_by_stats = 5, ignored_by_productivity = 5, temperature = 165},
      {type = "item", name = data_util.mod_prefix .. "iridium-ingot", amount = 1}, -- 100
    },
    energy_required = 50,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "iridium-blastcake", amount = 10},
      {type = "fluid", name = data_util.mod_prefix .. "pyroflux", amount = 5},
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[iridium]-f[iridium-ingot]-a[iridium-ingot]"
  },
  {
    type = "recipe",
    category = "crafting",
    name = data_util.mod_prefix .. "iridium-plate", -- 10
    localised_name = {"item-name."..data_util.mod_prefix.."iridium-plate"},
    results = {
      {type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 10},
    },
    energy_required = 10,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "iridium-ingot", amount = 1}
    },
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    order = "a[iridium]-g[iridium-plate]-a[iridium-plate]"
  },
  {
    type = "recipe",
    category = "pulverising",
    name = data_util.mod_prefix .. "naquium-ore-crushed",
    main_product = data_util.mod_prefix .. "naquium-ore-crushed",
    results = {
      {type = "item", name = data_util.mod_prefix .. "naquium-ore-crushed", amount = 2}, -- 4
      {type = "item", name = data_util.mod_prefix .. "iridium-powder", probability = 0.1, amount_min=1, amount_max=1, ignored_by_stats = 1, ignored_by_productivity  = 1},
      {type = "item", name = data_util.mod_prefix .. "iridium-plate", probability = 0.8, amount_min=1, amount_max=1, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "fluid", name = "water", amount = 10},
    },
    energy_required = 4,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "naquium-ore", amount = 8},
      {type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 1, ignored_by_stats = 1},
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    always_show_products = true,
    show_amount_in_title = true,
    order = "a[naquium]-c[naquium-crushed]-a[naquium-crushed]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "naquium-refined",
    main_product = data_util.mod_prefix .. "naquium-refined",
    results = {
      {type = "item", name = data_util.mod_prefix .. "vulcanite-ion-exchange-beads", probability = 0.5, amount_min = 1, amount_max = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "item", name = data_util.mod_prefix .. "beryllium-powder", probability = 0.2, amount_min=1, amount_max=1, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "item", name = data_util.mod_prefix .. "naquium-refined", amount_min = 5, amount_max = 7}, --6 -- value 4
      {type = "item", name = data_util.mod_prefix .. "naquium-powder", amount_min = 3, amount_max = 5}, --4 -- value 4
      {type = "fluid", name = "water", amount = 1},
    },
    energy_required = 10,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "cryonite-slush", amount = 1},
      {type = "fluid", name = data_util.mod_prefix .. "beryllium-hydroxide", amount = 2},
      {type = "item", name = data_util.mod_prefix .. "cryonite-ion-exchange-beads", amount = 1, ignored_by_stats = 1},
      {type = "item", name = data_util.mod_prefix .. "naquium-ore-crushed", amount = 10}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    always_show_products = true,
    show_amount_in_title = true,
    crafting_machine_tint = RecipeTints.naq_tint,
    order = "a[naquium]-d[naquium-refined]-a[naquium-refined]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "naquium-powder",
    main_product = data_util.mod_prefix .. "naquium-powder",
    results = {
      {type = "item", name = data_util.mod_prefix .. "cryonite-ion-exchange-beads", amount_min = 0, amount_max = 2, ignored_by_stats = 2, ignored_by_productivity = 2},
      {type = "item", name = data_util.mod_prefix .. "holmium-powder", probability = 0.2, amount_min = 1, amount_max = 1, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "item", name = data_util.mod_prefix .. "naquium-refined", amount_min = 4, amount_max = 8}, -- 6 -- value 4
      {type = "item", name = data_util.mod_prefix .. "naquium-powder", amount_min = 10, amount_max = 16}, -- 14 -- value 4
      {type = "fluid", name = "sulfuric-acid", amount = 1},
    },
    energy_required = 20,
    ingredients = {
      {type = "fluid", name = data_util.mod_prefix .. "vitalic-acid", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "vulcanite-ion-exchange-beads", amount = 2, ignored_by_stats = 2},
      {type = "item", name = data_util.mod_prefix .. "naquium-ore-crushed", amount = 20}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    always_show_products = true,
    show_amount_in_title = true,
    crafting_machine_tint = RecipeTints.naq_tint,
    order = "a[naquium]-e[naquium-powder]-a[naquium-powder]"
  },
  {
    type = "recipe",
    category = "centrifuging",
    name = data_util.mod_prefix .. "naquium-crystal",
    main_product = data_util.mod_prefix .. "naquium-crystal",
    results = {
      {type = "item", name = data_util.mod_prefix .. "naquium-crystal", probability = 0.618, amount_min=1, amount_max=1}, -- value 60 ish
      {type = "item", name = data_util.mod_prefix .. "naquium-powder", amount_min=1, amount_max=6, ignored_by_stats = 10, ignored_by_productivity = 10}, -- catalyst trick: a higher catalyst amount than the result ends up with a "consumed" stat
      {type = "item", name = data_util.mod_prefix .. "naquium-refined", amount_min=1, amount_max=4, ignored_by_stats = 8, ignored_by_productivity = 8},
      {type = "item", name = data_util.mod_prefix .. "vitalic-reagent", probability = 1-0.618, amount_min=1, amount_max=1, ignored_by_stats = 1, ignored_by_productivity = 1},
    },
    energy_required = 16,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vitalic-reagent", amount = 1, ignored_by_stats = 1},
      {type = "item", name = data_util.mod_prefix .. "naquium-powder", amount = 10, ignored_by_stats = 10},
      {type = "item", name = data_util.mod_prefix .. "naquium-refined", amount = 8, ignored_by_stats = 8},
    },
    enabled = false,
    always_show_made_in = true,
    always_show_products = true,
    show_amount_in_title = true,
    allow_productivity = true,
    crafting_machine_tint = RecipeTints.naq_centri_tint,
    order = "a[naquium]-f[naquium-crystal]-a[naquium-crystal]"
  },
  {
    type = "recipe",
    category = "smelting",
    name = data_util.mod_prefix .. "naquium-ingot",
    results = {
      {type = "item", name = data_util.mod_prefix .. "naquium-ingot", amount = 1}, -- value 200 ish
    },
    energy_required = 150,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "naquium-crystal", amount = 2},
      {type = "item", name = data_util.mod_prefix .. "naquium-refined", amount = 8},
      {type = "item", name = data_util.mod_prefix .. "naquium-powder", amount = 8},
      {type = "fluid", name = data_util.mod_prefix .. "pyroflux", amount = 25},
      {type = "fluid", name = data_util.mod_prefix .. "methane-gas", amount = 25},
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[naquium]-g[naquium-ingot]-a[naquium-ingot]"
  },
  {
    type = "recipe",
    category = "crafting",
    name = data_util.mod_prefix .. "naquium-plate",
    main_product = data_util.mod_prefix .. "naquium-plate",
    localised_name = {"item-name."..data_util.mod_prefix.."naquium-plate"},
    results = {
      {type = "item", name = data_util.mod_prefix .. "naquium-plate", amount = 10}, -- value 20 ish
      {type = "item", name = data_util.mod_prefix .. "heavy-bearing", amount_min=1, amount_max=1, probability=0.95, ignored_by_stats = 1}
    },
    energy_required = 4,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "heavy-bearing", amount = 1, ignored_by_stats = 1},
      {type = "item", name = data_util.mod_prefix .. "naquium-ingot", amount = 1}
    },
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    order = "a[naquium]-h[naquium-plate]-a[naquium-plate]"
  },

  {
    type = "recipe",
    category = "pulverising",
    name = data_util.mod_prefix .. "vitamelange-nugget",
    main_product = data_util.mod_prefix .. "vitamelange-nugget",
    results = {
      {type = "item", name = "wood", amount_min=0, amount_max=2, ignored_by_stats = 2, ignored_by_productivity = 2},
      {type = "item", name = "stone",  amount_min=0, amount_max=4, ignored_by_stats = 4, ignored_by_productivity = 4},
      {type = "item", name = data_util.mod_prefix .."vitamelange-nugget", amount_min=15, amount_max=25}, -- 0.5
    },
    energy_required = 10,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vitamelange", amount = 10}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[vitamelange]-c[vitamelange-nugget]-a[vitamelange-nugget]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "vitamelange-bloom",
    results = {
      {type = "item", name = data_util.mod_prefix .. "vitamelange-bloom", amount = 15}, -- 1
    },
    energy_required = 15,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vitamelange-nugget", amount = 30},
      {type = "fluid", name = "water", amount = 300},
      {type = "item", name = SEItemNames.get_sand_name(), amount = 15},
    },
    crafting_machine_tint = RecipeTints.vita_tint,
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    allow_decomposition = false,
    order = "a[vitamelange]-d[vitamelange-bloom]-a[vitamelange-bloom]"
  },
  {
    type = "recipe",
    category = "smelting",
    name = data_util.mod_prefix .. "vitamelange-spice",
    main_product = data_util.mod_prefix .. "vitamelange-spice",
    results = {
      {type = "fluid", name = data_util.mod_prefix .. "methane-gas", amount = 5},
      {type = "item", name = data_util.mod_prefix .. "vitamelange-spice", amount = 40}, -- 5
      {type = "item", name = data_util.mod_prefix .. "vitamelange-extract", amount_min=1, amount_max=1, probability=0.1}
    },
    energy_required = 100,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vulcanite-block", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "vitamelange-bloom", amount = 200}
    },
    allow_productivity = true,
    crafting_machine_tint = RecipeTints.vita_tint,
    enabled = false,
    always_show_made_in = true,
    order = "a[vitamelange]-e[vitamelange-spice]-a[vitamelange-spice]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "vitamelange-extract",
    main_product = data_util.mod_prefix .. "vitamelange-extract",
    results = {
      {type = "item", name = data_util.mod_prefix .. "vitamelange-spice", amount = 20, ignored_by_stats = 20, ignored_by_productivity = 20},
      {type = "item", name = data_util.mod_prefix .. "vitamelange-extract", amount_min=4, amount_max=8, ignored_by_stats = 1, ignored_by_productivity = 1}, -- 5, value 10
      {type = "fluid", name = "light-oil", amount = 1},
    },
    energy_required = 15,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vitamelange-spice", amount = 30, ignored_by_stats = 20},
      {type = "item", name = data_util.mod_prefix .. "vitamelange-extract", amount = 1, ignored_by_stats = 1}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    allow_decomposition = false,
    crafting_machine_tint = RecipeTints.vita_centri_tint,
    order = "a[vitamelange]-f[vitamelange-extract]-a[vitamelange-extract]"
  },

  {
    type = "recipe",
    category = "pulverising",
    name = data_util.mod_prefix .. "vulcanite-crushed",
    main_product = data_util.mod_prefix .. "vulcanite-crushed",
    results = {
      {type = "item", name = "stone", amount_min = 1, amount_max = 1, probability = 0.25},
      {type = "item", name = data_util.mod_prefix .. "vulcanite-crushed", amount = 3}, -- 2
      {type = "item", name = data_util.mod_prefix .. "vulcanite-enriched", amount_min=1, amount_max=1, probability=0.1},
    },
    energy_required = 1,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vulcanite", amount = 6},
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    allow_decomposition = false,
    crafting_machine_tint = RecipeTints.vulcanite_tint,
    order = "a[vulcanite]-c[vulcanite-crushed]-a[vulcanite-crushed]"
  },
  {
    type = "recipe",
    category = "centrifuging",
    name = data_util.mod_prefix .. "vulcanite-enriched",
    main_product = data_util.mod_prefix .. "vulcanite-enriched",
    results = {
      {type = "item", name = SEItemNames.get_sand_name(), amount_min = 1, amount_max = 1, probability = 0.2, ignored_by_stats = 1, ignored_by_productivity = 1},
      {type = "item", name = data_util.mod_prefix .. "vulcanite-enriched", amount = 4, ignored_by_stats = 1, ignored_by_productivity = 1}, -- 4
      {type = "item", name = data_util.mod_prefix .. "vulcanite-crushed", amount = 4, ignored_by_stats = 4, ignored_by_productivity = 4},
    },
    energy_required = 10,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vulcanite-crushed", amount = 10, ignored_by_stats = 4},
      {type = "item", name = data_util.mod_prefix .. "vulcanite-enriched", amount = 1, ignored_by_stats = 1},
      {type = "item", name = "sulfur", amount = 1},
    },
    enabled = false,
    always_show_made_in = true,
    allow_productivity = true,
    crafting_machine_tint = RecipeTints.vulcanite_centri_tint,
    order = "a[vulcanite]-d[vulcanite-enriched]-a[vulcanite-enriched]"
  },
  {
    type = "recipe",
    category = "smelting",
    name = data_util.mod_prefix .. "vulcanite-block",
    main_product = data_util.mod_prefix .. "vulcanite-block",
    results = {
      {type = "item", name = data_util.mod_prefix .. "vulcanite-block", amount = 1}, -- 10
      {type = "fluid", name="steam", amount = 40, temperature = 165, ignored_by_stats = 40, ignored_by_productivity = 40},
    },
    energy_required = 1,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vulcanite-crushed", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "vulcanite-enriched", amount = 2},
      {type = "fluid", name="water", amount = 5, ignored_by_stats = 5},
      {type = "fluid", name="petroleum-gas", amount = 1}
    },
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[vulcanite]-e[vulcanite-block]-a[vulcanite-block]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "pyroflux",
    subgroup = "vulcanite",
    main_product = data_util.mod_prefix .. "pyroflux",
    results = {
      {type = "fluid", name = data_util.mod_prefix .. "pyroflux", amount = 10},
    },
    energy_required = 1,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vulcanite-block", amount = 1},
      {type = "item", name = SEItemNames.get_sand_name(), amount = 1}
    },
    crafting_machine_tint = RecipeTints.pyroflux_tint,
    enabled = false,
    always_show_made_in = true,
    allow_productivity = true,
    order = "a[vulcanite]-f[pyroflux]-a[pyroflux]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "pyroflux-steam",
    localised_name = {"recipe-name."..data_util.mod_prefix .. "pyroflux-steam"},
    subgroup = "vulcanite",
    icons = data_util.sub_icons(data.raw.fluid["steam"].icon,
                                data.raw.fluid[data_util.mod_prefix .. "pyroflux"].icon),
    main_product = "steam",
    results = {
      {type = "fluid", name="steam", amount = 500, temperature = 165},
      {type = "item", name = "stone", amount_min = 1, amount_max = 1, probability = 0.1},
      {type = "item", name = "iron-ore", amount_min = 1, amount_max = 1, probability = 0.01},
      {type = "item", name = "copper-ore", amount_min = 1, amount_max = 1, probability = 0.01}
    },
    energy_required = 1,
    ingredients = {
      {type = "fluid", name = "water", amount = 50},
      {type = "fluid", name = data_util.mod_prefix .. "pyroflux", amount = 5},
    },
    enabled = false,
    always_show_made_in = true,
    order = "a[vulcanite]-f[pyroflux]-b[pyro-steam]"
  },
  {
    type = "recipe",
    category = "chemistry",
    name = data_util.mod_prefix .. "vulcanite-ion-exchange-beads",
    results = {
      {type = "item", name = data_util.mod_prefix .. "vulcanite-ion-exchange-beads", amount = 10},
    },
    energy_required = 10,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "vulcanite-block", amount = 1},
      {type = "item", name = "plastic-bar", amount = 1},
      {type = "fluid", name = "sulfuric-acid", amount = 5},
      {type = "fluid", name = "steam", amount = 5},
    },
    crafting_machine_tint = RecipeTints.vulcanite_tint,
    enabled = false,
    allow_productivity = true,
    always_show_made_in = true,
    order = "a[vulcanite]-e[vulcanite-block]-b[vulcanite-ion]"
  },


})
