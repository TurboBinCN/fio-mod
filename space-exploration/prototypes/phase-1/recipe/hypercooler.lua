local data_util = require("data_util")
local make_recipe = data_util.make_recipe

make_recipe({
  name = data_util.mod_prefix .. "space-coolant-cold",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-warm", amount = 40},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 20},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
  },
  energy_required = 4,
  subgroup = "thermofluid",
  category = "space-hypercooling",
  main_product = data_util.mod_prefix.."space-coolant-cold",
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "space-coolant-cold"},
  enabled = false,
  always_show_made_in = true,
  order = "c-a",
})


make_recipe({
  name = data_util.mod_prefix .. "space-coolant-supercooled",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 30},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
  },
  energy_required = 4,
  subgroup = "thermofluid",
  category = "space-hypercooling",
  main_product = data_util.mod_prefix.."space-coolant-supercooled",
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "space-coolant-supercooled"},
  enabled = false,
  always_show_made_in = true,
  order = "d-a",
})

make_recipe({
  name = data_util.mod_prefix .. "space-coolant-cold-cryonite",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-warm", amount = 80},
    { type = "fluid", name = data_util.mod_prefix .. "cryonite-slush", amount = 1},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 60},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
  },
  icons = data_util.sub_icons(data.raw.fluid[data_util.mod_prefix .. "space-coolant-cold"].icon,
                              data.raw.fluid[data_util.mod_prefix .. "cryonite-slush"].icon),
  energy_required = 2,
  subgroup = "thermofluid",
  category = "space-hypercooling",
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "space-coolant-cold-cryonite"},
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  order = "a[thermofluid]-c[cold]-b[cold]",
})


make_recipe({
  name = data_util.mod_prefix .. "space-coolant-supercooled-cryonite",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 60},
    { type = "fluid", name = data_util.mod_prefix .. "cryonite-slush", amount = 1},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 40},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
  },
  icons = data_util.sub_icons(data.raw.fluid[data_util.mod_prefix .. "space-coolant-supercooled"].icon,
                              data.raw.fluid[data_util.mod_prefix .. "cryonite-slush"].icon),
  energy_required = 2,
  subgroup = "thermofluid",
  category = "space-hypercooling",
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "space-coolant-supercooled-cryonite"},
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  order = "a[thermofluid]-d[supercooled]-b[supercooled]",
})
