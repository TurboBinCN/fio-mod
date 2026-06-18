local data_util = require("data_util")

data:extend({
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-console",
    energy_required = 30,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "aeroframe-pole", amount = 20},
      {type = "item", name = SEItemNames.get_glass_name(), amount = 20},
      {type = "item", name = "low-density-structure", amount = 20},
      {type = "item", name = "processing-unit", amount = 200},
      {type = "item", name = data_util.mod_prefix .. "astronomic-catalogue-3", amount = 1},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-console", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-floor",
    energy_required = 10,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 4},
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 4}
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-floor", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-wall",
    energy_required = 10,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 2},
      {type = "item", name = SEItemNames.get_glass_name(), amount = 8},
      {type = "item", name = "low-density-structure", amount = 4},
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 4}
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-wall", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-gate",
    energy_required = 10,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "spaceship-wall", amount = 1},
      {type = "item", name = "electric-engine-unit", amount = 6},
      {type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 1}
      -- TODO: add forcefield projector here
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-gate", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-rocket-engine",
    energy_required = 20,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 4},
      {type = "item", name = "steel-plate", amount = 20},
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 20},
      {type = "item", name = data_util.mod_prefix .. "space-pipe", amount = 20},
      {type = "item", name = "electric-engine-unit", amount = 10},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-rocket-engine", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-rocket-engine-burn",
    icon = "__space-exploration-graphics__/graphics/icons/spaceship-rocket-engine.png",
    icon_size = 64,
    order = "a",
    subgroup = "spaceship-process",
    hidden = true,
    energy_required = 0.1,
    category = "spaceship-rocket-engine",
    ingredients =
    {
      {type="fluid", name=data_util.mod_prefix .. "liquid-rocket-fuel", amount=5},
    },
    results = {},
    hide_from_player_crafting = true,
    enabled = true,
    always_show_made_in = true,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-rocket-booster-tank",
    energy_required = 10,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 4},
      {type = "item", name = "steel-plate", amount = 10},
      {type = "item", name = "storage-tank", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "space-pipe", amount = 4},
      {type = "item", name = "electric-engine-unit", amount = 4},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-rocket-booster-tank", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-ion-engine",
    energy_required = 30,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "spaceship-rocket-engine", amount = 1},
      {type = "item", name = "low-density-structure", amount = 40},
      {type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 40},
      {type = "item", name = data_util.mod_prefix .. "holmium-solenoid", amount = 8},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-ion-engine", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-ion-engine-burn",
    icon = "__space-exploration-graphics__/graphics/icons/spaceship-ion-engine.png",
    icon_size = 64,
    order = "a",
    subgroup = "spaceship-process",
    hidden = true,
    energy_required = 0.5,
    category = "spaceship-ion-engine",
    ingredients =
    {
      {type="fluid", name=data_util.mod_prefix .. "ion-stream", amount=1},
    },
    results = {},
    hide_from_player_crafting = true,
    enabled = true,
    always_show_made_in = true,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-ion-booster-tank",
    energy_required = 30,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = "storage-tank", amount = 1},
      {type = "item", name = "electric-engine-unit", amount = 4},
      {type = "item", name = data_util.mod_prefix .. "holmium-solenoid", amount = 8},
      {type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 40},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-ion-booster-tank", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-antimatter-engine",
    energy_required = 30,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "lattice-pressure-vessel", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "spaceship-ion-engine", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "heavy-assembly", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 100},
      {type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 100},
      {type = "item", name = data_util.mod_prefix .. "naquium-cube", amount = 4},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-antimatter-engine", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-antimatter-engine-burn",
    icon = "__space-exploration-graphics__/graphics/icons/spaceship-antimatter-engine.png",
    icon_size = 64,
    order = "a",
    subgroup = "spaceship-process",
    hidden = true,
    energy_required = 0.5,
    category = "spaceship-antimatter-engine",
    ingredients =
    {
      {type="fluid", name=data_util.mod_prefix .. "antimatter-stream", amount=1},
      -- 10x energy density, 5 burn would be the same thrust, 25 is 5x faster
    },
    results = {},
    hide_from_player_crafting = true,
    enabled = true,
    always_show_made_in = true,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "spaceship-antimatter-booster-tank",
    energy_required = 20,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "lattice-pressure-vessel", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "spaceship-rocket-booster-tank", amount = 1},
      {type = "item", name = "low-density-structure", amount = 50},
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 50},
      {type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 100},
      {type = "item", name = data_util.mod_prefix .. "naquium-cube", amount = 1},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "spaceship-antimatter-booster-tank", amount = 1},
    },
    enabled = false,
    always_show_made_in = false,
  },
})
