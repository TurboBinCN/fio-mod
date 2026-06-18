local data_util = require("data_util")
local make_recipe = data_util.make_recipe

make_recipe({
  name = data_util.mod_prefix .. "radiating-space-coolant-slow",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 500}, -- 2.5/s
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-warm", amount = 499}, -- -0.2%
  },
  icons = data_util.add_icons(data.raw.fluid[data_util.mod_prefix.."space-coolant-warm"].icon,
                              "__space-exploration-graphics__/graphics/icons/modules/efficiency-1.png"),
  energy_required = 200,
  subgroup = "thermofluid",
  category = "space-radiator",
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "radiating-space-coolant-slow"},
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  order = "a[thermofluid]-b[warm]-b[warm]",
})

make_recipe({
  name = data_util.mod_prefix .. "space-coolant-warm",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 50}, -- 5/s
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-warm", amount = 49}, -- -2%
  },
  energy_required = 10,
  subgroup = "thermofluid",
  category = "space-radiator",
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "radiating-space-coolant-normal"},
  enabled = false,
  always_show_made_in = true,
  order = "a[thermofluid]-b[warm]-a[warm]",
})



make_recipe({
  name = data_util.mod_prefix .. "radiating-space-coolant-fast",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10}, -- 10/s
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-warm", amount = 9}, -- -10%
  },
  icons = data_util.add_icons(data.raw.fluid[data_util.mod_prefix.."space-coolant-warm"].icon,
                              "__space-exploration-graphics__/graphics/icons/modules/speed-1.png"),
  energy_required = 1,
  subgroup = "thermofluid",
  category = "space-radiator",
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "radiating-space-coolant-fast"},
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  order = "a[thermofluid]-b[warm]-c[warm]",
})
