local data_util = require("data_util")
local make_recipe = data_util.make_recipe

data:extend({
  --[[{
    type = "recipe",
    name = "starfield-sparse",
    energy_required = 10,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = "iron-plate", amount = 1}
    },
    result= "space",
    result_count = 10
  },]]--
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-platform-scaffold",
    category = "space-crafting",
    ingredients =
    {
      {type = "item", name = "steel-plate", amount = 1},
      {type = "item", name = "low-density-structure", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 1},
    },
    energy_required = 10,
    results = {
      {type = "item", name = data_util.mod_prefix .. "space-platform-scaffold", amount = 1},
    },
    enabled = false,
    always_show_made_in = true,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-platform-plating",
    category = "space-crafting",
    ingredients =
    {
      {type = "item", name = data_util.mod_prefix .. "space-platform-scaffold", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 1},
      {type = "item", name = "steel-plate", amount = 4},
    },
    energy_required = 30,
    results = {
      {type = "item", name = data_util.mod_prefix .. "space-platform-plating", amount = 1},
    },
    enabled = false,
    always_show_made_in = true,
  },
})
