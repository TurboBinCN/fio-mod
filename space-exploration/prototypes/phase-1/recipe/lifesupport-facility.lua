local data_util = require("data_util")
local make_recipe = data_util.make_recipe

make_recipe({
  name = data_util.mod_prefix .. "empty-lifesupport-canister",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "canister", amount = 1},
    { type = "item", name = "processing-unit", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "empty-lifesupport-canister", amount = 1},
  },
  energy_required = 10,
  category = "lifesupport",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "lifesupport-canister-fish",
  localised_name = {"item-name."..data_util.mod_prefix.."lifesupport-canister"},
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-lifesupport-canister", amount = 2},
    { type = "item", name = "raw-fish", amount = 1},
    { type = "item", name = "wood", amount = 10},
    { type = "fluid", name = "water" , amount = 100},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "lifesupport-canister", amount = 2},
  },
  energy_required = 10,
  category = "lifesupport",
  enabled = false,
  icons = data_util.sub_icons(data.raw.item[data_util.mod_prefix .. "lifesupport-canister"].icon,
                              { icon = data.raw.item["wood"].icon, scale = 0.2, shift = {-7, -9} },
                              { icon = data.raw.capsule["raw-fish"].icon, scale = 0.2, shift = {-7, 1} }),
  always_show_made_in = true,
  hide_from_signal_gui = false,
})

make_recipe({
  name = data_util.mod_prefix .. "lifesupport-canister",
  localised_name = {"item-name."..data_util.mod_prefix.."lifesupport-canister"},
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-lifesupport-canister", amount = 2},
    { type = "item", name = "coal", amount = 2},
    { type = "fluid", name = "water" , amount = 100},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "lifesupport-canister", amount = 2},
  },
  energy_required = 10,
  category = "lifesupport",
  enabled = false,
  icon = data.raw.item[data_util.mod_prefix .. "lifesupport-canister"].icon,
  icon_size = 64,
  icons = data_util.sub_icons(data.raw.item[data_util.mod_prefix .. "lifesupport-canister"].icon,
                              data.raw.item["coal"].icon),
  allow_as_intermediate = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
})

make_recipe({
  name = data_util.mod_prefix .. "lifesupport-canister-specimen",
  localised_name = {"item-name."..data_util.mod_prefix.."lifesupport-canister"},
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-lifesupport-canister", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "specimen", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-water" , amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "lifesupport-canister", amount = 1},
  },
  energy_required = 10,
  category = "lifesupport",
  icons = data_util.sub_icons(data.raw.item[data_util.mod_prefix .. "lifesupport-canister"].icon,
                              data.raw.item[data_util.mod_prefix .. "specimen"].icon),
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
})

make_recipe({
  name = data_util.mod_prefix .. "used-lifesupport-canister-cleaning",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "used-lifesupport-canister", amount = 1},
    { type = "fluid", name = "water", amount = 100},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "empty-lifesupport-canister", amount = 1},
  },
  energy_required = 10,
  localised_name = {"recipe-name."..data_util.mod_prefix .. "used-lifesupport-canister-cleaning"},
  main_product = data_util.mod_prefix .. "empty-lifesupport-canister",
  allow_as_intermediate = false,
  category = "lifesupport",
  icons = data_util.sub_icons(data.raw.item[data_util.mod_prefix .. "used-lifesupport-canister"].icon,
                              data.raw.fluid["water"].icon),
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
})
