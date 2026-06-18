local data_util = require("data_util")
local make_recipe = data_util.make_recipe

data:extend({
  --[[{
    type = "recipe",
    name = data_util.mod_prefix .. "gate-addon",
    icon = "__space-exploration-graphics__/graphics/icons/scaffold.png",
    icon_size = 64,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "space-pipe", amount = 1000},
      { type = "item", name = "battery", amount = 1000},
      { type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 1000},
    },
    results = {},
    energy_required = 1,
    category = "fixed-recipe",
    subgroup = "ancient",
    order = "z",
    enabled = true,
    always_show_made_in = false,
    flags = {},
    hidden = true,
  },]]--
  {
    type = "recipe",
    name = data_util.mod_prefix .. "gate-platform",
    localised_name = {"entity-name."..data_util.mod_prefix.."gate-platform-scaffold"},
    icon = "__space-exploration-graphics__/graphics/icons/scaffold.png",
    icon_size = 64,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "space-pipe", amount = 100},
      { type = "item", name = "battery", amount = 100},
      { type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 100},
      { type = "item", name = data_util.mod_prefix .. "naquium-processor", amount = 9},
    },
    results = {},
    energy_required = 1,
    category = "fixed-recipe",
    subgroup = "ancient",
    order = "z",
    enabled = true,
    always_show_made_in = false,
    hidden = true,
  }
})
