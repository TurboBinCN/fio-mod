local data_util = require("data_util")
local make_recipe = data_util.make_recipe

make_recipe({
  name = data_util.mod_prefix .. "radiation-shielding-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1 },
    { type = "item", name = "uranium-235", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "material-testing-pack", amount = 4 },
    { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "radiation-shielding-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 8},
    { type = "item", name = "uranium-235", amount_min = 1, amount_max = 1, probability = 0.5 },
    { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount_min = 1, amount_max = 1, probability = 0.75 },
  },
  energy_required = 10,
  main_product = data_util.mod_prefix .. "radiation-shielding-data",
  category = "space-radiation",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "radiation-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1 },
    { type = "item", name = "uranium-235", amount = 1 },
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "radiation-data", amount = 1},
    { type = "item", name = "uranium-235", amount_min = 1, amount_max = 1, probability = 0.5 },
  },
  energy_required = 8,
  main_product = data_util.mod_prefix .. "radiation-data",
  category = "space-radiation",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "radiation-exposure-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "specimen", amount = 1 },
    { type = "item", name = "uranium-235", amount = 1 },
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "radiation-exposure-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "contaminated-bio-sludge", amount = 10},
    { type = "item", name = "uranium-235", amount_min = 1, amount_max = 1, probability = 0.5 },
  },
  energy_required = 10,
  main_product = data_util.mod_prefix .. "radiation-exposure-data",
  category = "space-radiation",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "radiation-exposure-resistance-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "significant-specimen", amount = 1 },
    { type = "item", name = "uranium-235", amount = 1 },
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "radiation-exposure-resistance-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "significant-specimen", amount_min = 1, amount_max = 1, probability = 0.80 },
    { type = "fluid", name = data_util.mod_prefix .. "contaminated-bio-sludge", amount_min = 1, amount_max = 10, probability = 1 },
    { type = "item", name = "uranium-235", amount_min = 1, amount_max = 1, probability = 0.5 },
  },
  energy_required = 10,
  main_product = data_util.mod_prefix .. "radiation-exposure-resistance-data",
  category = "space-radiation",
  enabled = false,
  always_show_made_in = true,
})
