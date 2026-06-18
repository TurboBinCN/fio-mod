local data_util = require("data_util")
local make_recipe = data_util.make_recipe

-- plasma
make_recipe({
  name = data_util.mod_prefix .. "plasma-canister",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "magnetic-canister", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 1000},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "plasma-canister", amount = 1},
  },
  energy_required = 2,
  category = "space-plasma",
  subgroup = "canister-full",
  enabled = false,
  always_show_made_in = true,
  order = "a-a",
  allow_quality = false,
  auto_recycle = false, -- fill plasma canister
})

make_recipe({
  name = data_util.mod_prefix .. "plasma-canister-empty", -- todo: empty should be prefix instead of suffix
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "plasma-canister", amount = 1},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 1000},
    { type = "item", name = data_util.mod_prefix .. "magnetic-canister", amount = 1},
  },
  icons = data_util.transition_icons(
    {
      icon = data.raw.item[data_util.mod_prefix .. "plasma-canister"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "plasma-canister"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "plasma-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "plasma-stream"].icon_size, scale = 0.5
    }
  ),
  main_product = data_util.mod_prefix .. "plasma-stream",
  energy_required = 2,
  category = "space-plasma",
  subgroup = "canister-full",
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "plasma-canister-empty"},
  order = "b-a",
  allow_quality = false,
  auto_recycle = false, -- empty plasma canister
})

make_recipe({
  name = data_util.mod_prefix .. "plasma-stream",
  ingredients = {
    { type = "item", name = "stone", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "chemical-gel", amount = 10},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 100},
  },
  energy_required = 30,
  category = "space-plasma",
  subgroup = "stream",
  enabled = false,
  always_show_made_in = true,
})
