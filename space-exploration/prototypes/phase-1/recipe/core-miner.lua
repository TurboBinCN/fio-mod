local data_util = require("data_util")
data:extend({
  {
    type = "recipe",
    name = data_util.mod_prefix .. "core-miner-drill",
    category = "crafting",
    enabled = false,
    energy_required = 100,
    ingredients = {
      {type = "item", name = "concrete", amount = 400},
      {type = "item", name = "electronic-circuit", amount = 200},
      {type = "item", name = "steel-plate", amount = 100},
      {type = "item", name = "electric-mining-drill", amount = 40},
    },
    results=
    {
      {type = "item", name = data_util.mod_prefix .. "core-miner-drill", amount=1}
    },
    icon = "__space-exploration-graphics__/graphics/icons/core-miner.png",
    icon_size = 64,
    order = "zzz-core-miner",
    always_show_made_in = true,
  },
})
