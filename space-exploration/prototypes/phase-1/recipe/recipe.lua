local data_util = require("data_util")
local RecipeTints = require("prototypes/recipe-tints")
local make_recipe = data_util.make_recipe

if not data.raw.recipe[SEItemNames.get_sand_name()] then
  data:extend({
    {
      ingredients = {
        { type = "item", name = "stone", amount = 1 }
      },
      name = "sand-from-stone",
      results = {
        {type = "item", name = SEItemNames.get_sand_name(), amount = 2},
      },
      type = "recipe",
      enabled = false,
      energy_required = 0.5,
      allow_productivity = true,
    }
  })
end
data:extend({
  {
    ingredients = {
      { type = "item", name = "stone", amount = 1 }
    },
    name = data_util.mod_prefix .. "pulverised-sand",
    results = {
      {type = "item", name = SEItemNames.get_sand_name(), amount = 3},
    },
    type = "recipe",
    enabled = false,
    energy_required = 0.5,
    category = "pulverising",
    --localised_name = {"recipe-name."..data_util.mod_prefix .. "pulverised-sand"},
    always_show_made_in = true,
    allow_productivity = true,
    order = "a[stone]-c[sand]-b[sand]",
  }
})

if not data.raw.recipe[SEItemNames.get_glass_name()] then
  data:extend({
    {
      category = "smelting",
      energy_required = 4,
      ingredients = {
        { type = "item", name = SEItemNames.get_sand_name(), amount = 4 }
      },
      name = "glass-from-sand",
      results = {
        {type = "item", name = SEItemNames.get_glass_name(), amount = 1},
      },
      type = "recipe",
      enabled = false,
      allow_productivity = true,
    },
  })
end

local naquium_tessaract_a = {r = 0.805, g = 0.055, b = 0.055, a = 1.000}
local naquium_tessaract_b = {r = 0.805, g = 0.055, b = 0.569, a = 1.000}

local naquium_processor_a = {r = 0.481, g = 0.805, b = 0.055, a = 1.000}
local naquium_processor_b = {r = 0.805, g = 0.279, b = 0.055, a = 1.000}

data:extend({
  {
    type = "recipe",
    name = data_util.mod_prefix .. "low-density-structure-beryllium",
    localised_name = {"item-name.low-density-structure"},
    results = {
      {type = "item", name = "low-density-structure", amount = 2},
    },
    energy_required = 10,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 1},
      { type = "item", name = SEItemNames.get_glass_name(), amount = 2},
      { type = "item", name = "steel-plate", amount = 2 },
      { type = "item", name = "plastic-bar", amount = 2 }
    },
    icons = data_util.sub_icons(data.raw.item["low-density-structure"].icon,
                                data.raw.item[data_util.mod_prefix .. "aeroframe-scaffold"].icon),
    requester_paste_multiplier = 2,
    enabled = false,
    always_show_made_in = false,
    allow_as_intermediate = false,
    allow_productivity = true,
    hide_from_signal_gui = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "heat-shielding",
    subgroup = "stone",
    results = {
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 1},
    },
    energy_required = 10,
    ingredients = {
      { type = "item", name = "stone-tablet", amount = 20},
      { type = "item", name = "sulfur", amount = 8 },
      { type = "item", name = "steel-plate", amount = 2 }
    },
    requester_paste_multiplier = 2,
    allow_productivity = true,
    enabled = false,
    always_show_made_in = false,
    order = "a[stone]-e[heat-shield]-a[heat-shield]",
  },
  {

    type = "recipe",
    name = data_util.mod_prefix .. "heat-shielding-iridium",
    localised_name = {"item-name."..data_util.mod_prefix.."heat-shielding"},
    subgroup = "stone",
    results = {
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 2},
    },
    energy_required = 10,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 1},
      { type = "item", name = "stone-tablet", amount = 4},
      { type = "item", name = "sulfur", amount = 1 },
    },
    icons = data_util.sub_icons(data.raw.item[data_util.mod_prefix .. "heat-shielding"].icon,
                                data.raw.item[data_util.mod_prefix .. "iridium-plate"].icon),
    requester_paste_multiplier = 2,
    enabled = false,
    always_show_made_in = true,
    allow_as_intermediate = false,
    allow_productivity = true,
    hide_from_signal_gui = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "processing-unit-holmium",
    localised_name = {"item-name.processing-unit"},
    results = {
      {type = "item", name = "processing-unit", amount = 2},
    },
    energy_required = 10,
    ingredients = {
      { type = "item", name = "electronic-circuit", amount = 10 },
      { type = "item", name = "advanced-circuit", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 4},
      { type = "fluid", name = "sulfuric-acid", amount = 2 },
    },
    icons = data_util.sub_icons(data.raw.item["processing-unit"].icon,
                                data.raw.item[data_util.mod_prefix .. "holmium-cable"].icon),
    requester_paste_multiplier = 3,
    enabled = false,
    always_show_made_in = true,
    allow_as_intermediate = false,
    allow_productivity = true,
    hide_from_signal_gui = false,
    category = "crafting-with-fluid",
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "thruster-suit",
    results = {
      {type = "item", name = data_util.mod_prefix .. "thruster-suit", amount = 1},
    },
    enabled = false,
    energy_required = 30,
    ingredients = {
      { type = "item", name = "rocket-control-unit", amount = 10 },
      { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 20 },
      { type = "item", name = "low-density-structure", amount = 20 },
      { type = "item", name = SEItemNames.get_glass_name(), amount = 20 },
      { type = "item", name = "jetpack-1", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "lifesupport-equipment-1", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "thruster-suit-2",
    results = {
      { type = "item", name=data_util.mod_prefix .. "thruster-suit-2", amount = 1},
    },
    main_product = data_util.mod_prefix .. "thruster-suit-2",
    enabled = false,
    energy_required = 30,
    ingredients = {
      { type = "item", name = "processing-unit", amount = 50 },
      { type = "item", name = "rocket-fuel", amount = 50 },
      { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 50 },
      { type = "item", name = data_util.mod_prefix .. "material-catalogue-1", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "thruster-suit", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "thruster-suit-3",
    results = {
      { type = "item", name=data_util.mod_prefix .. "thruster-suit-3", amount = 1},
    },
    main_product = data_util.mod_prefix .. "thruster-suit-3",
    enabled = false,
    energy_required = 30,
    ingredients = {
      { type = "item", name = "processing-unit", amount = 100 },
      { type = "item", name = "rocket-fuel", amount = 50 },
      { type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 50 },
      { type = "item", name = data_util.mod_prefix .. "astronomic-catalogue-1", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "biological-catalogue-1", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "energy-catalogue-3", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "material-catalogue-3", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "thruster-suit-2", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "thruster-suit-4",
    results = {
      { type = "item", name=data_util.mod_prefix .. "thruster-suit-4", amount = 1},
    },
    main_product = data_util.mod_prefix .. "thruster-suit-4",
    enabled = false,
    energy_required = 30,
    ingredients = {
      { type = "item", name = "processing-unit", amount = 200 },
      { type = "item", name = data_util.mod_prefix .. "antimatter-canister", amount = 10 },
      { type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 200 },
      { type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 100 },
      { type = "item", name = data_util.mod_prefix .. "naquium-plate", amount = 100 },
      { type = "item", name = data_util.mod_prefix .. "deep-catalogue-2", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "self-sealing-gel", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "lattice-pressure-vessel", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "naquium-processor", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "thruster-suit-3", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "rtg-equipment",
    results = {
      {type = "item", name = data_util.mod_prefix .. "rtg-equipment", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "processing-unit", amount = 50 },
      { type = "item", name = "low-density-structure", amount = 50 },
      { type = "item", name = "uranium-238", amount = 20 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = "fission-reactor-equipment",
    results = {
      {type = "item", name = "fission-reactor-equipment", amount = 1},
    },
    enabled = false,
    energy_required = 20,
    ingredients = {
      { type = "item", name = "processing-unit", amount = 50 },
      { type = "item", name = data_util.mod_prefix .."atomic-data", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "rtg-equipment", amount = 4 },
      { type = "item", name = "uranium-fuel-cell", amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "holmium-solenoid", amount = 8 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "fusion-reactor-equipment",
    results = {
      {type = "item", name = data_util.mod_prefix .. "fusion-reactor-equipment", amount = 1},
    },
    enabled = false,
    energy_required = 40,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 50 },
      { type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 50 },
      { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1 },
      { type = "item", name = "fission-reactor-equipment", amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "dynamic-emitter", amount = 8 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "antimatter-reactor-equipment",
    results = {
      {type = "item", name = data_util.mod_prefix .. "antimatter-reactor-equipment", amount = 1},
    },
    enabled = false,
    energy_required = 80,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 50},
      { type = "item", name = data_util.mod_prefix .. "antimatter-canister", amount = 8 },
      { type = "item", name = data_util.mod_prefix .. "naquium-tessaract", amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "fusion-reactor-equipment", amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "antimatter-reactor", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "adaptive-armour-equipment-1",
    results = {
      {type = "item", name = data_util.mod_prefix .. "adaptive-armour-equipment-1", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "steel-plate", amount = 20 },
      { type = "item", name = "advanced-circuit", amount = 10 },
      { type = "item", name = "battery", amount = 5 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "adaptive-armour-equipment-2",
    results = {
      {type = "item", name = data_util.mod_prefix .. "adaptive-armour-equipment-2", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "steel-plate", amount = 30 },
      { type = "item", name = "processing-unit", amount = 10 },
      { type = "item", name = "low-density-structure", amount = 10 },
      { type = "item", name = data_util.mod_prefix .. "adaptive-armour-equipment-1", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "adaptive-armour-equipment-3",
    results = {
      {type = "item", name = data_util.mod_prefix .. "adaptive-armour-equipment-3", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "steel-plate", amount = 40 },
      { type = "item", name = "processing-unit", amount = 10 },
      { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 10 },
      { type = "item", name = data_util.mod_prefix .. "adaptive-armour-equipment-2", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "adaptive-armour-equipment-4",
    results = {
      {type = "item", name = data_util.mod_prefix .. "adaptive-armour-equipment-4", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "steel-plate", amount = 50 },
      { type = "item", name = "processing-unit", amount = 20 },
      { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 20 },
      { type = "item", name = data_util.mod_prefix .. "adaptive-armour-equipment-3", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "adaptive-armour-equipment-5",
    results = {
      {type = "item", name = data_util.mod_prefix .. "adaptive-armour-equipment-5", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "steel-plate", amount = 40 },
      { type = "item", name = "processing-unit", amount = 30 },
      { type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 10 },
      { type = "item", name = data_util.mod_prefix .. "adaptive-armour-equipment-4", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = "energy-shield-mk3-equipment",
    results = {
      {type = "item", name = "energy-shield-mk3-equipment", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "energy-shield-mk2-equipment", amount = 5 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = "energy-shield-mk4-equipment",
    results = {
      {type = "item", name = "energy-shield-mk4-equipment", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "energy-shield-mk3-equipment", amount = 5 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = "energy-shield-mk5-equipment",
    results = {
      {type = "item", name = "energy-shield-mk5-equipment", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "energy-shield-mk4-equipment", amount = 5 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = "energy-shield-mk6-equipment",
    results = {
      {type = "item", name = "energy-shield-mk6-equipment", amount = 1},
    },
    enabled = false,
    energy_required = 10,
    ingredients = {
      { type = "item", name = "energy-shield-mk5-equipment", amount = 5 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },




  { -- 2
    type = "recipe",
    name = data_util.mod_prefix .. "aeroframe-pole",
    results = {{type="item", name=data_util.mod_prefix .. "aeroframe-pole", amount=1}},
    energy_required = 1,
    ingredients = {
      { type = "item", name = "iron-stick", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 2 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    allow_productivity = true,
    enabled = false,
  },
  { -- 8
    type = "recipe",
    name = data_util.mod_prefix .. "aeroframe-scaffold",
    results = {
      {type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 1},
    },
    energy_required = 4,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "aeroframe-pole", amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    allow_productivity = true,
    enabled = false,
  },
  { -- 32
    type = "recipe",
    name = data_util.mod_prefix .. "aeroframe-bulkhead",
    results = {
      {type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 1},
    },
    energy_required = 4,
    ingredients = {
      { type = "item", name = "low-density-structure", amount = 2 },
      { type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 2 },
      { type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 8 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    allow_productivity = true,
    enabled = false,
  },
  { -- 128
    type = "recipe",
    name = data_util.mod_prefix .. "lattice-pressure-vessel",
    results = {
      {type = "item", name = data_util.mod_prefix .. "lattice-pressure-vessel", amount = 1},
    },
    energy_required = 3,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 3 },
      { type = "item", name = data_util.mod_prefix .. "beryllium-plate", amount = 16 },
      { type = "fluid", name = data_util.mod_prefix .. "chemical-gel", amount = 4 },
      { type = "fluid", name = data_util.mod_prefix .. "methane-gas", amount = 20 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    enabled = false,
    category="space-manufacturing"
  },

  { --4
    type = "recipe",
    name = data_util.mod_prefix .. "heavy-girder",
    results = {
      {type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 1},
    },
    energy_required = 1,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "vulcanite-block", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 4 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    enabled = false,
    allow_productivity = true,
  },
  { -- 8
    type = "recipe",
    name = data_util.mod_prefix .. "heavy-bearing",
    results = {
      {type = "item", name = data_util.mod_prefix .. "heavy-bearing", amount = 1},
    },
    energy_required = 2,
    ingredients = {
      { type="item", name=data_util.mod_prefix .. "heavy-girder", amount = 1 },
      { type="item", name=data_util.mod_prefix .. "iridium-plate", amount = 4 },
      { type="fluid", name="lubricant", amount=4 },
    },
    category="crafting-with-fluid",
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    enabled = false,
    allow_productivity = true,
  },
  { -- 32
    type = "recipe",
    name = data_util.mod_prefix .. "heavy-composite",
    results = {
      {type = "item", name = data_util.mod_prefix .. "heavy-composite", amount = 1},
    },
    energy_required = 3,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 16 },
      { type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 8 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    enabled = false,
    allow_productivity = true,
  },
  { -- 128
    type = "recipe",
    name = data_util.mod_prefix .. "heavy-assembly",
    results = {
      {type = "item", name = data_util.mod_prefix .. "heavy-assembly", amount = 1},
    },
    energy_required = 4,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "heavy-composite", amount = 2 },
      { type = "item", name = data_util.mod_prefix .. "heavy-bearing", amount = 8 },
      { type = "item", name = "electric-engine-unit", amount = 2 },
      { type="fluid", name="lubricant", amount = 16 },
    },
    category="crafting-with-fluid",
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    enabled = false,
    allow_productivity = true,
  },


  { --0.5
    type = "recipe",
    name = data_util.mod_prefix .. "vitalic-acid",
    results = {
      { type = "fluid", name = data_util.mod_prefix .. "vitalic-acid", amount = 2}
    },
    energy_required = 2,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "vitamelange-extract", amount = 1 },
      { type = "fluid", name = "sulfuric-acid", amount = 2 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    allow_productivity = true,
    enabled = false,
    category = "chemistry",
    subgroup = "vitamelange",
    crafting_machine_tint = RecipeTints.vita_tint,
    order = "a[vitamelange]-g[vitalic-acid]-a[vitalic-acid]"
  },
  { -- 16
    type = "recipe",
    name = data_util.mod_prefix .. "bioscrubber",
    results = {
      {type = "item", name = data_util.mod_prefix .. "bioscrubber", amount = 1},
    },
    energy_required = 2,
    ingredients = {
      { type = "fluid", name = data_util.mod_prefix .. "vitalic-acid", amount = 30 },
      { type = "item", name = "coal", amount = 2 },
      { type = "item", name = SEItemNames.get_glass_name(), amount = 2 },
      { type = "item", name = "steel-plate", amount = 2 },
    },
    crafting_machine_tint = RecipeTints.vita_tint,
    requester_paste_multiplier = 1,
    always_show_made_in = true,
    enabled = false,
    category = "chemistry",
    allow_productivity = true,
  },
  { -- 8
    type = "recipe",
    name = data_util.mod_prefix .. "vitalic-reagent",
    results = {
      {type = "item", name = data_util.mod_prefix .. "vitalic-reagent", amount = 1},
    },
    energy_required = 3,
    ingredients = {
      { type = "item", name = SEItemNames.get_glass_name(), amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "vitamelange-extract", amount = 8 },
      { type = "item", name = data_util.mod_prefix .. "vulcanite-block", amount = 1 },
    },
    crafting_machine_tint = RecipeTints.vita_tint,
    requester_paste_multiplier = 1,
    always_show_made_in = true,
    allow_productivity = true,
    enabled = false,
    category = "centrifuging",
    order = "a[vitamelange]-g[vitalic-reagent]-a[vitalic-reagent]"
  },
  { -- 64
    type = "recipe",
    name = data_util.mod_prefix .. "vitalic-epoxy",
    results = {
      {type = "item", name = data_util.mod_prefix .. "vitalic-epoxy", amount = 1},
    },
    energy_required = 4,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "vitalic-reagent", amount = 6 },
      { type = "fluid", name = data_util.mod_prefix .. "vitalic-acid", amount = 32 },
      { type = "item", name = "sulfur", amount = 8 },
    },
    crafting_machine_tint = RecipeTints.vita_tint,
    requester_paste_multiplier = 1,
    always_show_made_in = true,
    enabled = false,
    allow_productivity = true,
    category = "chemistry",
    order = "a-h"
  },
  { -- 128
    type = "recipe",
    name = data_util.mod_prefix .. "self-sealing-gel",
    results = {
      {type = "item", name = data_util.mod_prefix .. "self-sealing-gel", amount = 2},
    },
    energy_required = 5,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "vitalic-reagent", amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "vitalic-epoxy", amount = 3 },
      { type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 4 },
      { type = "fluid", name = data_util.mod_prefix .. "methane-gas", amount = 32 },
    },
    crafting_machine_tint = RecipeTints.vita_tint,
    requester_paste_multiplier = 1,
    always_show_made_in = true,
    enabled = false,
    category = "space-biochemical",
    order = "a-i"
  },

  {
    type = "recipe",
    name = data_util.mod_prefix .. "naquium-cube",
    results = {
      {type = "item", name = data_util.mod_prefix .. "naquium-cube", amount = 1},
    },
    energy_required = 10,
    ingredients = {
      { type="fluid", name = data_util.mod_prefix .. "particle-stream", amount = 12 },
      { type="item", name = data_util.mod_prefix .. "naquium-plate", amount = 12 },
      { type="item", name = data_util.mod_prefix .. "nanomaterial", amount = 1 },
      { type="item", name = data_util.mod_prefix .. "vulcanite-block", amount = 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = true,
    enabled = false,
    category = "space-materialisation",
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "naquium-tessaract",
    main_product = data_util.mod_prefix .. "naquium-tessaract",
    energy_required = 20,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "naquium-cube", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "naquium-plate", amount = 16 },
      { type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 1},
    },
    results = {
      { type = "item", name = data_util.mod_prefix .. "naquium-tessaract", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount= 1 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount= 1 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount= 1 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount= 0 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount= 0 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = true,
    enabled = false,
    category = "arcosphere",
    localised_description = {"space-exploration.arcosphere-random"},
    crafting_machine_tint =
    {
      primary = naquium_tessaract_a,
      secondary = naquium_tessaract_b,
    },
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "naquium-tessaract-alt",
    localised_name = {"item-name."..data_util.mod_prefix.."naquium-tessaract"},
    main_product = data_util.mod_prefix .. "naquium-tessaract",
    energy_required = 20,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "naquium-cube", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "naquium-plate", amount = 16 },
      { type = "item", name = data_util.mod_prefix .. "cryonite-rod", amount = 4 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 1},
    },
    results = {
      { type = "item", name = data_util.mod_prefix .. "naquium-tessaract", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount= 0 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount= 0 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount= 1 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount= 1 },
      { type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount= 1 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = true,
    enabled = false,
    category = "arcosphere",
    localised_description = {"space-exploration.arcosphere-random"},
    crafting_machine_tint =
    {
      primary = naquium_tessaract_b,
      secondary = naquium_tessaract_a,
    },
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "naquium-processor",
    main_product = data_util.mod_prefix .. "naquium-processor",
    energy_required = 30,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "quantum-processor", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "naquium-tessaract", amount = 1 },
      { type = "fluid", name = data_util.mod_prefix .. "neural-gel-2", amount = 4},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1},
    },
    results = {
      { type = "item", name = data_util.mod_prefix .. "naquium-processor", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 5},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 1},
    },
    requester_paste_multiplier = 1,
    always_show_made_in = true,
    enabled = false,
    category = "arcosphere",
    localised_description = {"space-exploration.arcosphere-random"},
    crafting_machine_tint =
    {
      primary = naquium_processor_a,
      secondary = naquium_processor_b,
    },
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "naquium-processor-alt",
    localised_name = {"item-name."..data_util.mod_prefix.."naquium-processor"},
    main_product = data_util.mod_prefix .. "naquium-processor",
    energy_required = 30,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "quantum-processor", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "naquium-tessaract", amount = 1 },
      { type = "fluid", name = data_util.mod_prefix .. "neural-gel-2", amount = 4},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1},
    },
    results = {
      { type = "item", name = data_util.mod_prefix .. "naquium-processor", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1},
      { type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 5},
    },
    requester_paste_multiplier = 1,
    always_show_made_in = true,
    enabled = false,
    category = "arcosphere",
    localised_description = {"space-exploration.arcosphere-random"},
    crafting_machine_tint =
    {
      primary = naquium_processor_b,
      secondary = naquium_processor_a,
    },
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "processed-fuel-from-solid-fuel",
    localised_name = {"item-name.processed-fuel"},
    category = "fuel-refining",
    order = "a[fuel]-a[pro-fuel]-b[pro-fuel-from-solid]",
    enabled = false,
    energy_required = 5,
    ingredients = {
      { type = "item", name = "solid-fuel", amount = 2 },
      { type = "fluid", name = data_util.mod_prefix .. "methane-gas", amount = 20 },
    },
    results = {
      { type = "item", name = "processed-fuel", amount = 5 },
    },
    icons = data_util.sub_icons(data.raw.item["processed-fuel"].icon,
                                data.raw.fluid[data_util.mod_prefix .. "methane-gas"].icon),
    icon_size = 64,
    requester_paste_multiplier = 1,
    allow_decomposition = false,
    always_show_made_in = true,
    hide_from_signal_gui = false,
    subgroup = "fuel",
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "vitalic-hydrocarbon-extraction",
    localised_name = {"recipe-name."..data_util.mod_prefix .. "vitalic-hydrocarbon-extraction"},
    category = "oil-processing",
    order = "a[chemical]-c[coal]-b[vitalic-extraction]",
    enabled = false,
    energy_required = 5,
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "vitalic-reagent", amount = 1 },
      { type = "item", name = data_util.mod_prefix .. "vitamelange-bloom", amount = 4 },
      { type = "item", name = "processed-fuel", amount = 4 },
      { type = "fluid", name = "petroleum-gas", amount = 40 },
    },
    results = {
      { type = "fluid", name = "crude-oil", amount = 20 },
      { type = "item", name = "coal", amount = 2 },
      { type = "item", name = "wood", amount = 3 },
    },
    icons = data_util.transition_icons(
      {
        icon = data.raw.item[data_util.mod_prefix .. "vitalic-reagent"].icon,
        icon_size = data.raw.item[data_util.mod_prefix .. "vitalic-reagent"].icon_size, scale = 0.5,
        draw_background = true,
      },
      {
        icon = data.raw.item["coal"].icon,
        icon_size = data.raw.item["coal"].icon_size, scale = 0.5,
        draw_background = true,
      }
    ),
    icon_size = 64,
    requester_paste_multiplier = 1,
    allow_decomposition = false,
    always_show_made_in = true,
    hide_from_signal_gui = false,
    subgroup = "chemical",
  },
})
