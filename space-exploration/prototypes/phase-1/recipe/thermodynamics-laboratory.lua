local data_util = require("data_util")
local make_recipe = data_util.make_recipe

local recipe_multiplier = 4

make_recipe({
  name = data_util.mod_prefix .. "thermodynamics-coal",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "experimental-specimen", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 10},
  },
  results = {
    { type = "item", name = "coal", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "contaminated-space-water", amount = 20},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
  },
  icons = data_util.transition_icons(
    {
      icon = data.raw.item[data_util.mod_prefix .. "experimental-specimen"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "experimental-specimen"].icon_size, scale = 0.5,
      draw_background = true,
    },
    {
      icon = data.raw.item["coal"].icon,
      icon_size = data.raw.item["coal"].icon_size, scale = 0.5,
      draw_background = true,
    }
  ),
  energy_required = 5 * recipe_multiplier,
  subgroup = "chemical",
  category = "space-thermodynamics",
  allow_as_intermediate = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  order = "a[chemical]-c[coal]-c[thermodynamics-coal]",
})

make_recipe({
  name = data_util.mod_prefix .. "bio-combustion-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "specimen", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "bio-combustion-data", amount_min = 1, amount_max = 1, probability = 0.75},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.24},
    { type = "fluid", name = data_util.mod_prefix .. "contaminated-bio-sludge", amount = 2},
  },
  energy_required = 5 * recipe_multiplier,
  main_product = data_util.mod_prefix .. "bio-combustion-data",
  category = "space-thermodynamics",
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "bio-combustion-resistance-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "experimental-specimen", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "bio-combustion-resistance-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "experimental-specimen", amount_min = 1, amount_max = 1, probability = 0.5},
    { type = "fluid", name = data_util.mod_prefix .. "contaminated-bio-sludge", amount = 7},
  },
  energy_required = 10 * recipe_multiplier,
  main_product = data_util.mod_prefix .. "bio-combustion-resistance-data",
  category = "space-thermodynamics",
  always_show_made_in = true,
})

--[[
-- removed
make_recipe({
  name = data_util.mod_prefix .. "bio-combustion-suppression-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "significant-specimen", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "experimental-material", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 100},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "bio-combustion-suppression-data", amount_min = 1, amount_max = 1, probability = 0.5},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.49},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 3},
    { type = "fluid", name = data_util.mod_prefix .. "contaminated-bio-sludge", amount = 100},
  },
  category = "space-thermodynamics",
})
]]--

make_recipe({
  name = data_util.mod_prefix .. "cold-thermodynamics-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "material-testing-pack", amount = 4},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "cold-thermodynamics-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 8},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 8},
  },
  energy_required = 10 * recipe_multiplier,
  main_product = data_util.mod_prefix .. "cold-thermodynamics-data",
  category = "space-thermodynamics",
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "hot-thermodynamics-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "material-testing-pack", amount = 4},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "plasma-stream", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "hot-thermodynamics-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 8},
  },
  energy_required = 10 * recipe_multiplier,
  main_product = data_util.mod_prefix .. "hot-thermodynamics-data",
  category = "space-thermodynamics",
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "pressure-containment-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 1},
    { type = "item", name = "storage-tank", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-water", amount = 1000},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "pressure-containment-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-water", amount = 990},
  },
  energy_required = 2 * recipe_multiplier,
  main_product = data_util.mod_prefix .. "pressure-containment-data",
  category = "space-thermodynamics",
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "explosion-shielding-data",
  ingredients = {
    { type = "item", name = "explosives", amount = 20},
    { type = "item", name = data_util.mod_prefix .. "material-testing-pack", amount = 4},
    { type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 2},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "explosion-shielding-data", amount = 2},
    { type = "item", name = data_util.mod_prefix .. "heavy-girder", amount_min = 1, amount_max = 1, probability = 0.5},
    { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount_min = 1, amount_max = 1, probability = 0.5},
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 10},
  },
  energy_required = 20,
  main_product = data_util.mod_prefix .. "explosion-shielding-data",
  category = "space-thermodynamics",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "experimental-alloys-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "holmium-plate", amount = 1},
    { type = "item", name = "iron-plate", amount = 1},
    { type = "item", name = "copper-plate", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 6},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "experimental-alloys-data", amount = 6},
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 5},
  },
  energy_required = 18,
  main_product = data_util.mod_prefix .. "experimental-alloys-data",
  category = "space-thermodynamics",
  enabled = false,
  always_show_made_in = true,
})

data_util.make_recipe({
  name = data_util.mod_prefix .. "cryogun",
  ingredients = {
    { type = "item",  name = data_util.mod_prefix .. "beryllium-plate", amount = 10},
    { type = "item",  name = data_util.mod_prefix .. "aeroframe-pole", amount = 10},
    { type = "item",  name = data_util.mod_prefix .. "cryonite-rod", amount = 10},
  },
  results = {
    { type = "item",  name = data_util.mod_prefix .. "cryogun", amount = 1},
  },
  energy_required = 60,
  category = "space-thermodynamics",
  enabled = false,
})

data_util.make_recipe({
  name = data_util.mod_prefix .. "cryogun-ammo",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 10},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "cryogun-ammo", amount = 1},
  },
  energy_required = 10,
  category = "space-thermodynamics",
  enabled = false,
  always_show_made_in = true,
})
