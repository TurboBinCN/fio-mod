local data_util = require("data_util")
local make_recipe = data_util.make_recipe
local RecipeTints = require("prototypes/recipe-tints")

-- making data cell
--[[make_recipe({
  name = data_util.mod_prefix .. "omega-tool",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 100 },
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "omega-tool", amount = 1},
  },
  category = "space-manufacturing"
})]]--

-- making data cell
make_recipe({
  name = data_util.mod_prefix .. "data-storage-substrate",
  ingredients = {
    { type = "item", name = SEItemNames.get_glass_name(), amount = 2 },
    { type = "item", name = "iron-plate", amount = 4 }
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "data-storage-substrate", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "scrap", amount_min = 1, amount_max = 1, probability = 0.5 },
  },
  energy_required = 5,
  allow_productivity = true,
  main_product = data_util.mod_prefix .. "data-storage-substrate",
  category = "crafting",
  enabled = false,
  always_show_made_in = false,
  order = "a[data-generic]-a[substrate]-01",
})

make_recipe({
  name = data_util.mod_prefix .. "empty-data",
  ingredients = {
    { type = "item", name = "advanced-circuit", amount = 3 },
    { type = "item", name = "copper-plate", amount = 6 },
    { type = "item", name = data_util.mod_prefix .. "data-storage-substrate-cleaned", amount = 4 }
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1},
  },
  energy_required = 10,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "material-testing-pack",
  ingredients = {
    { type = "item", name = "iron-plate", amount = 1},
    { type = "item", name = "copper-plate", amount = 1},
    { type = "item", name = "stone", amount = 1},
    { type = "item", name = "plastic-bar", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "material-testing-pack", amount = 1},
  },
  energy_required = 5,
  category = "crafting",
  enabled = false,
  always_show_made_in = false,
  allow_productivity = true,
})

make_recipe({
  name = data_util.mod_prefix .. "canister",
  ingredients = {
    { type = "item", name = "steel-plate", amount = 5},
    { type = "item", name = "copper-plate", amount = 10},
    { type = "item", name = "plastic-bar", amount = 5},
    { type = "item", name = SEItemNames.get_glass_name(), amount = 5},
    { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "canister", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 1},
  },
  main_product = data_util.mod_prefix .. "canister",
  energy_required = 10,
  category = "crafting",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "space-mirror",
  ingredients = {
    { type = "item", name = SEItemNames.get_glass_name(), amount = 6},
    { type = "item", name = "steel-plate", amount = 3},
    { type = "item", name = "low-density-structure", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 1},
    { type = "fluid", name = "lubricant", amount = 10},
    { type = "fluid", name = data_util.mod_prefix .."chemical-gel", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix.."space-mirror", amount = 1 },
    { type = "item", name = data_util.mod_prefix.."scrap", amount = 1 },
  },
  energy_required = 10,
  main_product = data_util.mod_prefix .. "space-mirror",
  category = "space-manufacturing",
  icon = "__space-exploration-graphics__/graphics/icons/space-mirror.png",
  icon_size = 64,
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "space-mirror-alternate",
  localised_name = {"item-name."..data_util.mod_prefix.."space-mirror"},
  ingredients = {
    { type = "item", name = SEItemNames.get_glass_name(), amount = 2},
    { type = "item", name = data_util.mod_prefix.."iridium-plate", amount = 2},
    { type = "item", name = "low-density-structure", amount = 1},
    { type = "fluid", name = "lubricant", amount = 5},
    { type = "fluid", name = data_util.mod_prefix.."chemical-gel", amount = 5},
  },
  results = {
    { type = "item", name = data_util.mod_prefix.."space-mirror", amount = 1 },
    { type = "item", name = data_util.mod_prefix.."scrap", amount = 5 },
  },
  energy_required = 10,
  main_product = data_util.mod_prefix .. "space-mirror",
  category = "space-manufacturing",
  icons = data_util.sub_icons(data.raw.item[data_util.mod_prefix .. "space-mirror"].icon,
                              data.raw.item[data_util.mod_prefix .. "iridium-plate"].icon),
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
})

make_recipe({
  name = data_util.mod_prefix .. "gammaray-detector",
  ingredients = {
    { type = "item", name = data_util.mod_prefix.."space-mirror", amount = 1 },
    { type = "item", name = data_util.mod_prefix.."beryllium-plate", amount = 1},
    { type = "fluid", name = data_util.mod_prefix.."cryonite-slush", amount = 5},
    { type = "fluid", name = data_util.mod_prefix.."chemical-gel", amount = 5},
  },
  results = {
    { type = "item", name = data_util.mod_prefix.."gammaray-detector", amount = 1 },
  },
  energy_required = 10,
  category = "space-manufacturing",
  icon = "__space-exploration-graphics__/graphics/icons/gammaray-detector.png",
  icon_size = 64,
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "space-solar-panel",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "space-mirror", amount = 4},
    { type = "item", name = "solar-panel", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "space-solar-panel", amount = 1 },
  },
  energy_required = 20,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "space-solar-panel-2",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "space-solar-panel", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "holmium-plate", amount = 4},
    { type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 4},
    { type = "item", name = data_util.mod_prefix .. "space-mirror", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "space-solar-panel-2", amount = 1 },
  },
  energy_required = 40,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "space-solar-panel-3",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "space-solar-panel-2", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "naquium-cube", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 4},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "space-solar-panel-3", amount = 1 },
  },
  energy_required = 60,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "space-accumulator",
  ingredients = {
    { type = "item", name = "accumulator", amount = 2},
    { type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 8},
    { type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 40},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "space-accumulator", amount = 1 },
  },
  energy_required = 30,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "space-accumulator-2",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "space-accumulator", amount = 2},
    { type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 8},
    { type = "item", name = data_util.mod_prefix .. "naquium-cube", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "space-accumulator-2", amount = 1 },
  },
  energy_required = 60,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "observation-frame-blank",
  ingredients = {
    { type = "item", name = "coal", amount = 1},
    { type = "item", name = SEItemNames.get_glass_name(), amount = 1},
    { type = "item", name = "steel-plate", amount = 1},
    { type = "fluid", name = "light-oil", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix.."observation-frame-blank", amount = 5 },
  },
  energy_required = 5,
  category = "space-manufacturing",
  icons = data_util.sub_icons("__space-exploration-graphics__/graphics/icons/observation-frame-blank.png",
                              data.raw.item["steel-plate"].icon),
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "observation-frame-blank-beryllium",
  localised_name = {"item-name."..data_util.mod_prefix.."observation-frame-blank"},
  ingredients = {
    { type = "item", name = "coal", amount = 1},
    { type = "item", name = SEItemNames.get_glass_name(), amount = 1},
    { type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 1},
    { type = "fluid", name = "light-oil", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix.."observation-frame-blank", amount = 10 },
  },
  energy_required = 10,
  category = "space-manufacturing",
  icons = data_util.sub_icons("__space-exploration-graphics__/graphics/icons/observation-frame-blank.png",
                              data.raw.item[data_util.mod_prefix .. "beryllium-plate"].icon),
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
})


make_recipe({
  name = data_util.mod_prefix .. "chemical-gel",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "space-water", amount = 10},
    { type = "fluid", name = "petroleum-gas", amount = 100},
  },
  results = {
    { type="fluid", name = data_util.mod_prefix .. "chemical-gel", amount = 20},
  },
  energy_required = 10,
  category = "space-biochemical",
  subgroup = "gel",
  enabled = false,
  always_show_made_in = true,
  crafting_machine_tint = RecipeTints.chemical_gel_tint,
  order = "a"
})

--[[
make_recipe({
  name = data_util.mod_prefix .. "space-rail",
  ingredients = {
    { type = "item", name = "low-density-structure", amount = 1},
    { type = "item", name = "steel-plate", amount = 2},
    { type = "item", name = "copper-cable", amount = 4},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "space-rail", amount = 1},
  },
  energy_required = 10,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})
]]--

make_recipe({
  name = data_util.mod_prefix .. "space-rail",
  ingredients = {
    { type = "item", name = "rail", amount = 100},
    { type = "item", name = "steel-plate", amount = 100},
    { type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 100},
    { type = "item", name = data_util.mod_prefix .. "energy-catalogue-1", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "space-rail", amount = 100},
  },
  energy_required = 100,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "star-probe",
  ingredients = {
    { type = "item", name = "rocket-fuel", amount = 100},
    { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 100},
    { type = "item", name = "rocket-control-unit", amount = 20},
    { type = "item", name = data_util.mod_prefix .. "space-solar-panel-2", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "holmium-solenoid", amount = 20},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1000},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "star-probe", amount = 1},
  },
  energy_required = 60,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})
make_recipe({
  name = data_util.mod_prefix .. "belt-probe",
  ingredients = {
    { type = "item", name = "rocket-fuel", amount = 100},
    { type = "item", name = "uranium-fuel-cell", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 40},
    { type = "item", name = "rocket-control-unit", amount = 20},
    { type = "item", name = data_util.mod_prefix .. "space-solar-panel", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1000},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "belt-probe", amount = 1},
  },
  energy_required = 60,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})
make_recipe({
  name = data_util.mod_prefix .. "void-probe",
  ingredients = {
    { type = "item", name = "uranium-fuel-cell", amount = 20},
    { type = "item", name = "rocket-fuel", amount = 100},
    { type = "item", name = "rocket-control-unit", amount = 20},
    { type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 20},
    { type = "item", name = "laser-turret", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1000},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "void-probe", amount = 1},
  },
  energy_required = 60,
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "nanomaterial",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
    { type = "item", name = data_util.mod_prefix .. "dynamic-emitter", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 4},
    { type = "item", name = data_util.mod_prefix .. "heavy-composite", amount = 4},
    { type = "item", name = data_util.mod_prefix .. "vitalic-epoxy", amount = 2},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "nanomaterial", amount=16},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 60,
  main_product = data_util.mod_prefix .. "nanomaterial",
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})


make_recipe({
  name = data_util.mod_prefix .. "nano-engineering-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount=1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "nano-engineering-data", amount=1},
    { type = "item", name = data_util.mod_prefix .. "nanomaterial", amount_min = 1, amount_max = 1, probability = 0.05},
    { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount_min = 1, amount_max = 1, probability = 0.05},
    { type = "item", name = "low-density-structure", amount_min = 1, amount_max = 1, probability = 0.05},
    { type = "item", name = data_util.mod_prefix .. "holmium-solenoid", amount_min = 1, amount_max = 1, probability = 0.05},
    { type = "item", name = data_util.mod_prefix .. "scrap", amount_min = 1, amount_max = 1, probability = 0.05},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount_min = 1, amount_max = 1, probability = 0.05},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 60,
  main_product = data_util.mod_prefix .. "nano-engineering-data",
  category = "space-manufacturing",
  enabled = false,
  always_show_made_in = true,
})
