local data_util = require("data_util")
local make_recipe = data_util.make_recipe

make_recipe({
  name = data_util.mod_prefix .. "comparative-genetic-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "significant-specimen", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "specimen", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 4},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "comparative-genetic-data", amount = 4},
    { type="fluid", name = data_util.mod_prefix .. "bio-sludge", amount = 20},
  },
  energy_required = 8,
  main_product = data_util.mod_prefix .. "comparative-genetic-data",
  category = "space-genetics",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "experimental-bioculture",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "experimental-genetic-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "nutrient-vat", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "vitamelange-extract", amount = 1},
    { type="fluid", name = data_util.mod_prefix .. "bio-sludge", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "experimental-bioculture", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount = 1},
  },
  energy_required = 3,
  main_product = data_util.mod_prefix .. "experimental-bioculture",
  category = "space-genetics",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "experimental-genetic-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "genetic-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "biochemical-data", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "experimental-genetic-data", amount = 2},
  },
  energy_required = 3,
  main_product = data_util.mod_prefix .. "experimental-genetic-data",
  category = "space-genetics",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "bioculture",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "genetic-data", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "nutrient-vat", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "vitamelange-spice", amount = 5},
    { type = "fluid", name = data_util.mod_prefix .. "bio-sludge", amount = 50},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "bioculture", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "genetic-data", amount = 9},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount = 1},
  },
  energy_required = 5,
  main_product = data_util.mod_prefix .. "bioculture",
  category = "space-genetics",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "genetic-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
    { type="fluid", name = data_util.mod_prefix .. "bio-sludge", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "genetic-data", amount = 1},
    { type="fluid", name = data_util.mod_prefix .. "contaminated-space-water", amount = 9},
  },
  energy_required = 1,
  main_product = data_util.mod_prefix .. "genetic-data",
  category = "space-genetics",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "significant-specimen",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "experimental-specimen", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "neural-gel", amount = 2},
    { type = "item", name = data_util.mod_prefix .. "vitalic-reagent", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "significant-specimen", amount_min = 1, amount_max = 1, probability = 0.4},
    { type = "item", name = data_util.mod_prefix .. "experimental-specimen", amount_min = 1, amount_max = 1, probability = 0.5},
    { type="fluid", name = data_util.mod_prefix .. "bio-sludge", amount_min = 1, amount_max = 5, probability = 1},
  },
  energy_required = 1.25,
  main_product = data_util.mod_prefix .. "significant-specimen",
  category = "space-genetics",
  enabled = false,
  always_show_made_in = true,
})
