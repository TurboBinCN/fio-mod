local data_util = require("data_util")
local make_recipe = data_util.make_recipe

data:extend({
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-science-lab",
    category = "space-crafting",
    enabled = false,
    energy_required = 30,
    ingredients = {
      {type = "item", name = "lab", amount = 10},
      {type = "item", name = "low-density-structure", amount = 40},
      {type = "item", name = "processing-unit", amount = 20},
      {type = "item", name = "electric-engine-unit", amount = 10},
      {type = "item", name = "battery", amount = 10},
    },
    results=
    {
      {type = "item", name=data_util.mod_prefix .. "space-science-lab", amount=1}
    },
    icon = "__space-exploration-graphics__/graphics/icons/space-science-lab.png",
    icon_size = 64,
    crafting_machine_tint =
    {
      primary = {r = 0.290, g = 0.027, b = 0.000, a = 0.000}, -- #49060000
      secondary = {r = 0.722, g = 0.465, b = 0.190, a = 0.000}, -- #b8763000
      tertiary = {r = 0.870, g = 0.365, b = 0.000, a = 0.000}, -- #dd5d0000
    },
    requester_paste_multiplier = 3,
    always_show_made_in = true,
  }
})
