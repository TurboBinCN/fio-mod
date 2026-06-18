local data_util = require("data_util")
local make_recipe = data_util.make_recipe

--[[
make_recipe({
  name = data_util.mod_prefix .. "doppler-shift-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 50},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "doppler-shift-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 50},
  },
  energy_required = 2,
  main_product = data_util.mod_prefix .. "doppler-shift-data",
  category = "space-laser",
  enabled = false,
  always_show_made_in = true,
})]]

make_recipe({
  name = data_util.mod_prefix .. "gravity-wave-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "astrometric-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "gravity-wave-data", amount_min = 1, amount_max = 1, probability = 0.3},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.69},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-warm", amount = 10},
  },
  energy_required = 2,
  main_product = data_util.mod_prefix .. "gravity-wave-data",
  category = "space-laser",
  enabled = false,
  always_show_made_in = true,
})


make_recipe({
  name = data_util.mod_prefix .. "negative-pressure-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "astrometric-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "negative-pressure-data", amount_min = 1, amount_max = 1, probability = 0.9},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.09},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
  },
  energy_required = 10,
  main_product = data_util.mod_prefix .. "negative-pressure-data",
  category = "space-laser",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "polarisation-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "space-mirror", amount = 2},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "polarisation-data", amount = 9},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 2},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-warm", amount = 10},
  },
  energy_required = 60,
  main_product = data_util.mod_prefix .. "polarisation-data",
  category = "space-laser",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "quantum-phenomenon-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "quantum-phenomenon-data", amount_min = 1, amount_max = 1, probability = 0.5},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.49},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
  },
  energy_required = 10,
  main_product = data_util.mod_prefix .. "quantum-phenomenon-data",
  category = "space-laser",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "zero-point-energy-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "negative-pressure-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "zero-point-energy-data", amount_min = 1, amount_max = 1, probability = 0.4},
    { type = "item", name = data_util.mod_prefix .. "negative-pressure-data", amount_min = 1, amount_max = 1, probability = 0.4},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.19},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-warm", amount = 10},
  },
  energy_required = 10,
  main_product = data_util.mod_prefix .. "zero-point-energy-data",
  category = "space-laser",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "laser-shielding-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "material-testing-pack", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "laser-shielding-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 5},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount_min = 1, amount_max = 1, probability = 0.5 },
  },
  energy_required = 5,
  main_product = data_util.mod_prefix .. "laser-shielding-data",
  category = "space-laser",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "teleportation-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 2 },
    { type = "item", name = data_util.mod_prefix .. "singularity-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "timespace-anomaly-data", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "naquium-cube", amount = 2},
    { type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 5},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "teleportation-data", amount = 4},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-warm", amount = 10},
  },
  energy_required = 40,
  main_product = data_util.mod_prefix .. "teleportation-data",
  category = "space-laser",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "hyperlattice-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 6 },
    { type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "naquium-plate", amount = 24},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "hyperlattice-data", amount=6},
  },
  energy_required = 40,
  main_product = data_util.mod_prefix .. "hyperlattice-data",
  category = "space-laser",
  enabled = false,
  always_show_made_in = true,
})
