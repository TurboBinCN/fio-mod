local data_util = require("data_util")
local make_recipe = data_util.make_recipe

-- accelerator
make_recipe({
  name = data_util.mod_prefix .. "ion-stream",
  ingredients = {
    { type = "item", name = "copper-plate", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 100},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "ion-stream", amount = 100},
  },
  energy_required = 10,
  category = "space-accelerator",
  subgroup = "stream",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "proton-stream",
  ingredients = {
    { type = "item", name = "iron-plate", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 100},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "proton-stream", amount = 100},
  },
  energy_required = 20,
  category = "space-accelerator",
  subgroup = "stream",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "particle-stream",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "material-testing-pack", amount = 1},
    { type = "item", name = SEItemNames.get_sand_name(), amount = 5},
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 100},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 200},
  },
  energy_required = 30,
  category = "space-accelerator",
  subgroup = "stream",
  enabled = false,
  always_show_made_in = true,
  main_product = data_util.mod_prefix .. "particle-stream"
})

-- collider
make_recipe({
  name = data_util.mod_prefix .. "empty-antimatter-canister",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "antimatter-canister", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 100},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "antimatter-stream", amount = 1000},
    { type = "item",  name = data_util.mod_prefix .. "magnetic-canister", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 100},
  },
  icons = data_util.transition_icons(
    {
      icon = data.raw.item[data_util.mod_prefix .. "antimatter-canister"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "antimatter-canister"].icon_size, scale = 0.5,
      draw_background = true,
    },
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "antimatter-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "antimatter-stream"].icon_size, scale = 0.5,
      draw_background = true,
    }
  ),
  main_product = data_util.mod_prefix .. "antimatter-stream",
  energy_required = 30,
  category = "space-accelerator",
  subgroup = "canister-full",
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "empty-antimatter-canister"},
  order = "b-c",
  allow_quality = false,
  auto_recycle = false, -- empty antimatter canister
})

make_recipe({
  name = data_util.mod_prefix .. "ion-canister-empty", -- todo: empty should be prefix instead of suffix
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "ion-canister", amount = 1},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "ion-stream", amount = 1000},
    { type = "item", name = data_util.mod_prefix .. "magnetic-canister", amount = 1},
  },
  icons = data_util.transition_icons(
    {
      icon = data.raw.item[data_util.mod_prefix .. "ion-canister"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "ion-canister"].icon_size, scale = 0.5,
      draw_background = true,
    },
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "ion-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "ion-stream"].icon_size, scale = 0.5,
      draw_background = true,
    }
  ),
  main_product = data_util.mod_prefix .. "ion-stream",
  energy_required = 4,
  category = "space-accelerator",
  subgroup = "canister-full",
  enabled = false,
  always_show_made_in = true,
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "ion-canister-empty"},
  order = "b-b",
  hide_from_signal_gui = false,
  allow_quality = false,
  auto_recycle = false, -- empty ion canister
})
