local data_util = require("data_util")

---- Matter Science Pack
-- Matter Science Pack Tint
local matter_pack_tint = {r = 255, g = 51, b = 151}

-- Data Card Recipes
-- Matter Analysis
local matter_analysis = data.raw.recipe["kr-matter-research-data"]
matter_analysis.icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-analysis.png"
matter_analysis.icon_size = 64
matter_analysis.ingredients = {
  {type = "item", name = "se-material-testing-pack", amount = 1},
  {type = "item", name = "se-quantum-phenomenon-data", amount = 1},
  {type = "item", name = "se-quark-data", amount = 1},
  {type = "fluid", name = "se-particle-stream", amount = 50},
}
matter_analysis.results = {
  {type = "item", name = "kr-matter-research-data", amount = 1},
  {type = "item", name = "se-junk-data", amount_min = 1, amount_max = 1, probability = 0.70},
  {type = "item", name = "se-broken-data", amount_min = 1, amount_max = 1, probability = 0.30},
  {type = "fluid", name = "se-particle-stream", amount = 35},
}
matter_analysis.main_product = "kr-matter-research-data"
matter_analysis.category = "space-materialisation"
matter_analysis.subgroup = "data-matter"

-- Matter Synthesis
local matter_synthesis = table.deepcopy(data.raw.recipe["se-matter-fusion-dirty"])
matter_synthesis.name = "se-kr-matter-synthesis-data"
matter_synthesis.localised_name = {"",{"recipe-name.se-kr-matter-synthesis-data"}}
matter_synthesis.icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-synthesis.png"
matter_synthesis.icon_size = 64
matter_synthesis.icons = nil
matter_synthesis.main_product = "se-kr-matter-synthesis-data"
matter_synthesis.subgroup = "data-matter"
matter_synthesis.ingredients = {
  { type = "item", name = "se-quark-data", amount = 1},
  { type = "fluid", name = "se-particle-stream", amount = 50},
  { type = "fluid", name = "se-space-coolant-supercooled", amount = 25}
}
matter_synthesis.results = {
  { type = "item", name = "se-contaminated-scrap", amount = 15},
  { type = "item", name = "se-kr-matter-synthesis-data", amount_min = 1, amount_max = 1, probability = 0.90},
  { type = "item", name = "se-junk-data", amount_min = 1, amount_max = 1, probability = 0.10},
  { type = "fluid", name = "se-space-coolant-hot", amount = 25}
}
matter_synthesis.energy_required = 10
data:extend({matter_synthesis})
data_util.delete_recipe("se-matter-fusion-dirty")

-- Matter Liberation
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-matter-liberation-data",
  category = "space-materialisation",
  subgroup = "data-matter",
  ingredients = {
    { type = "item", name = "se-radiation-data", amount = 1},
    { type = "item", name = "se-hot-thermodynamics-data", amount = 1},
    { type = "item", name = "se-material-testing-pack", amount = 5},
    { type = "fluid", name = "se-particle-stream", amount = 100}
  },
  results = {
    { type = "item", name = "se-kr-matter-liberation-data", amount = 1},
    { type = "item", name = "se-junk-data", amount_min = 1, amount_max = 1, probability = 0.80},
    { type = "item", name = "se-broken-data", amount_min = 1, amount_max = 1, probability = 0.20},
    { type = "item", name = "se-contaminated-scrap", amount = 15},
    { type = "fluid", name = "se-particle-stream", amount = 110}
  },
  main_product = "se-kr-matter-liberation-data",
  always_show_made_in = true,
})

-- Matter Containment
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-matter-containment-data",
  category = "space-materialisation",
  subgroup = "data-matter",
  ingredients = {
    { type = "item", name = "se-forcefield-data", amount = 1},
    { type = "item", name = "se-pressure-containment-data", amount = 1},
    { type = "item", name = "se-magnetic-canister", amount = 5},
    { type = "fluid", name = "se-particle-stream", amount = 100}
  },
  results = {
    { type = "item", name = "se-kr-matter-containment-data", amount_min = 2, amount_max = 2, probability = 0.70},
    { type = "item", name = "se-junk-data", amount_min = 2, amount_max = 2, probability = 0.30},
    { type = "item", name = "se-scrap", amount = 15},
    { type = "item", name = "se-contaminated-scrap", amount = 10}
  },
  main_product = "se-kr-matter-containment-data",
  always_show_made_in = true,
})

-- Matter Manipulation
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-matter-manipulation-data",
  group = "science",
  category = "basic-matter-conversion",
  subgroup = "data-matter",
  ingredients = {
    { type = "item", name = "se-forcefield-data", amount = 1},
    { type = "item", name = "se-hot-thermodynamics-data", amount = 1},
    { type = "fluid", name = "kr-matter", amount = 50},
  },
  results = {
    { type = "item", name = "se-kr-matter-manipulation-data", amount = 2},
    { type = "item", name = "se-scrap", amount = 10},
    { type = "fluid", name = "se-particle-stream", amount = 40},
    { type = "fluid", name = "kr-matter", amount = 10},
  },
  main_product = "se-kr-matter-manipulation-data",
  always_show_made_in = true,
})

-- Matter Recombination
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-matter-recombination-data",
  group = "science",
  category = "basic-matter-conversion",
  subgroup = "data-matter",
  ingredients = {
    { type = "item", name = "kr-ai-core", amount = 1},
    { type = "item", name = "se-boson-data", amount = 1},
    { type = "item", name = "se-fusion-test-data", amount = 1},
    { type = "fluid", name = "kr-matter", amount = 50},
  },
  results = {
    { type = "item", name = "se-kr-matter-recombination-data", amount = 1},
    { type = "item", name = "se-junk-data", amount_min = 1, amount_max = 1, probability = 0.80},
    { type = "item", name = "se-broken-data", amount_min = 1, amount_max = 1, probability = 0.20},
    { type = "item", name = "kr-ai-core", amount_min = 1, amount_max = 1, probability = 0.75},
    { type = "item", name = "se-scrap", amount = 15},
  },
  main_product = "se-kr-matter-recombination-data",
  allow_as_intermediate = false,
})

-- Matter Stabilization
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-matter-stabilization-data",
  group = "science",
  category = "basic-matter-conversion",
  subgroup = "data-matter",
  ingredients = {
    { type = "item", name = "kr-ai-core", amount = 1},
    { type = "item", name = "se-kr-matter-containment-data", amount = 1},
    { type = "item", name = "se-experimental-alloys-data", amount = 1},
    { type = "fluid", name = "kr-matter", amount = 50},
  },
  results = {
    { type = "item", name = "se-kr-matter-stabilization-data", amount = 2},
    { type = "item", name = "kr-ai-core", amount_min = 1, amount_max = 1, probability = 0.80},
    { type = "fluid", name = "kr-matter", amount = 45},
  },
  main_product = "se-kr-matter-stabilization-data",
  allow_as_intermediate = false,
})

-- Matter Utilization
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-matter-utilization-data",
  group = "science",
  category = "basic-matter-conversion",
  subgroup = "data-matter",
  ingredients = {
    { type = "item", name = "kr-ai-core", amount = 1},
    { type = "item", name = "se-magnetic-canister", amount = 5},
    { type = "item", name = "se-kr-matter-containment-data", amount = 1},
    { type = "fluid", name = "kr-matter", amount = 50},
  },
  results = {
    { type = "item", name = "se-kr-matter-utilization-data", amount = 1},
    { type = "item", name = "kr-ai-core", amount = 1},
    { type = "item", name = "se-magnetic-canister", amount_min = 1, amount_max = 4},
    { type = "fluid", name = "kr-matter", amount = 35},
  },
  main_product = "se-kr-matter-utilization-data",
  allow_as_intermediate = false,
})

-- Catalogue recipes
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-matter-catalogue-1",
  ingredients = {
    { type = "item", name = "kr-matter-research-data", amount = 1 },
    { type = "item", name = "se-kr-matter-synthesis-data", amount = 1},
    { type = "item", name = "se-kr-matter-liberation-data", amount = 1},
    { type = "item", name = "se-kr-matter-containment-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
  },
  results = {
    { type = "item", name = "se-kr-matter-catalogue-1", amount = 1 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
  },
  energy_required = 50,
  main_product = "se-kr-matter-catalogue-1",
  subgroup = "data-catalogue-matter",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-1.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png", icon_size = 64, tint = matter_pack_tint}
  },
  category = "catalogue-creation-1",
  always_show_made_in = true,
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-matter-catalogue-2",
  ingredients = {
    { type = "item", name = "se-kr-matter-manipulation-data", amount = 1},
    { type = "item", name = "se-kr-matter-recombination-data", amount = 1},
    { type = "item", name = "se-kr-matter-stabilization-data", amount = 1},
    { type = "item", name = "se-kr-matter-utilization-data", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
  },
  results = {
    { type = "item", name = "se-kr-matter-catalogue-2", amount = 1 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
  },
  energy_required = 60,
  main_product = "se-kr-matter-catalogue-2",
  subgroup = "data-catalogue-matter",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-2.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png", icon_size = 64, tint = matter_pack_tint}
  },
  category = "catalogue-creation-2",
  always_show_made_in = true,
})

-- Science Pack Recipes
local matter_tech_card_recipe = data.raw.recipe["kr-matter-tech-card"]
matter_tech_card_recipe.category = "science-pack-creation-1"
matter_tech_card_recipe.subgroup = "matter-science-pack"
matter_tech_card_recipe.ingredients = {
  {type = "item", name = "se-scrap", amount = 10},
  {type = "item", name = "se-significant-data", amount = 1},
  {type = "item", name = "se-kr-matter-catalogue-1", amount = 1},
  {type = "fluid", name = "se-particle-stream", amount = 5},
  {type = "fluid", name = "se-space-coolant-supercooled", amount = 50}
}
matter_tech_card_recipe.results = {
  {type = "item", name = "kr-matter-tech-card", amount = 2},
  {type = "item", name = "se-junk-data", amount = 4},
  {type = "item", name = "se-broken-data", amount = 1},
  {type = "fluid", name = "se-space-coolant-hot", amount = 50}
}
matter_tech_card_recipe.energy_required = 10
matter_tech_card_recipe.main_product = "kr-matter-tech-card"
matter_tech_card_recipe.always_show_made_in = true

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-matter-science-pack-2",
  category = "science-pack-creation-2",
  subgroup = "matter-science-pack",
  ingredients = {
    { type = "item", name = "se-scrap", amount = 10}, -- needs changed?
    { type = "item", name = "se-significant-data", amount = 1},
    { type = "item", name = "se-kr-matter-catalogue-2", amount = 1},
    { type = "item", name = "kr-matter-tech-card", amount = 2},
    { type = "fluid", name = "kr-matter", amount = 50 },
    { type = "fluid", name = "se-space-coolant-supercooled", amount = 100},
  },
  results = {
    { type = "item", name = "se-kr-matter-science-pack-2", amount = 4},
    { type = "item", name = "se-junk-data", amount = 4},
    { type = "item", name = "se-broken-data", amount = 1},
    { type = "fluid", name = "se-space-coolant-hot", amount = 100},
  },
  energy_required = 20,
  main_product = "se-kr-matter-science-pack-2",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-3.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png", icon_size = 64, tint = matter_pack_tint}
  },
  always_show_made_in = true,
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-combined-catalogue",
  category = "catalogue-creation-1",
  subgroup = "data-catalogue-advanced",
  energy_required = 40,
  main_product = "se-kr-combined-catalogue",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/universal-catalogue.png", icon_size = 64}
  },
  ingredients = {
    {type = "item", name = "se-astronomic-catalogue-3", amount = 1},
    {type = "item", name = "se-biological-catalogue-3", amount = 1},
    {type = "item", name = "se-energy-catalogue-3", amount = 1},
    {type = "item", name = "se-material-catalogue-3", amount = 1},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10}
  },
  results = {
    {type = "item", name = "se-kr-combined-catalogue", amount = 2},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10}
  }
})

local advanced_pack_tint = {r = 133, g = 33, b = 209}
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-advanced-catalogue-1",
  category = "catalogue-creation-1",
  subgroup = "data-catalogue-advanced",
  energy_required = 50,
  main_product = "se-kr-advanced-catalogue-1",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-1.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png", icon_size = 64, tint = advanced_pack_tint}
  },
  ingredients = {
    { type = "item", name = "se-kr-power-density-data", amount = 1},
    { type = "item", name = "se-kr-quantum-computation-data", amount = 1},
    { type = "item", name = "se-kr-remote-sensing-data", amount = 1},
    { type = "item", name = "se-kr-combined-catalogue", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
  },
  results = {
    { type = "item", name = "se-kr-advanced-catalogue-1", amount = 1 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
  },
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-advanced-catalogue-2",
  category = "catalogue-creation-2",
  subgroup = "data-catalogue-advanced",
  energy_required = 80,
  main_product = "se-kr-advanced-catalogue-2",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-2.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png", icon_size = 64, tint = advanced_pack_tint}
  },
  ingredients = {
    { type = "item", name = "se-kr-macroscale-entanglement-data", amount = 1},
    { type = "item", name = "se-kr-timespace-manipulation-data", amount = 1},
    { type = "item", name = "se-kr-singularity-application-data", amount = 1},
    { type = "item", name = "se-kr-combined-catalogue", amount = 1},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 10},
  },
  results = {
    { type="item", name = "se-kr-advanced-catalogue-2", amount = 1 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
  },
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-power-density-data",
  group = "science",
  category = "space-electromagnetics",
  subgroup = "data-advanced",
  energy_required = 30,
  main_product = "se-kr-power-density-data",
  order = "a-a",
  allow_productivity = false,
  ingredients = {
    {type = "item", name = "kr-lithium-sulfur-battery", amount = 1},
    {type = "item", name = "se-space-accumulator", amount = 1},
    {type = "item", name = "kr-energy-control-unit", amount = 1},
    {type = "item", name = "se-empty-data", amount = 3}
  },
  results = {
    {type = "item", name = "se-kr-power-density-data", amount = 3}
  }
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-quantum-computation-data",
  group = "science",
  category = "space-supercomputing-2",
  subgroup = "data-advanced",
  energy_required = 90,
  main_product = "se-kr-quantum-computation-data",
  order = "a-b",
  allow_productivity = false,
  ingredients = {
    {type = "item", name = "se-quantum-processor", amount = 6},
    {type = "item", name = "se-empty-data", amount = 6},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 30}
  },
  results = {
    {type = "item", name = "se-kr-quantum-computation-data", amount = 6},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 30}
  }
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-remote-probe",
  group = "science",
  category = "space-manufacturing",
  subgroup = "data-advanced",
  energy_required = 60,
  main_product = "se-kr-remote-probe",
  order = "a-c",
  allow_productivity = false,
  ingredients = {
    {type = "item", name = "radar", amount = 20},
    {type = "item", name = "rocket-control-unit", amount = 20},
    {type = "item", name = "rocket-fuel", amount = 100},
    {type = "item", name = "se-space-solar-panel-2", amount = 10},
    {type = "item", name = "se-empty-data", amount = 1000}
  },
  results = {
    {type = "item", name = "se-kr-remote-probe", amount = 1}
  }
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-macroscale-entanglement-data",
  group = "science",
  category = "arcosphere",
  subgroup = "data-advanced",
  energy_required = 20,
  main_product = "se-kr-macroscale-entanglement-data",
  order = "b-a-a",
  allow_productivity = false,
  ingredients = {
    {type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1}, -- lambda
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 0}, -- xi
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 0}, -- zeta
    {type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 1}, -- theta
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 0}, -- gamma
    {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1}, -- omega
    {type = "item", name = data_util.mod_prefix .. "significant-data", amount = 1},
    {type = "item", name = "kr-ai-core", amount = 1},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 20}
  },
  results = {
    { type = "item", name = "se-kr-macroscale-entanglement-data", amount = 1},
    { type = "item", name = "kr-ai-core", amount_min = 1, amount_max = 1, probability = 0.75},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
    { type = "item", name = "se-arcosphere-a", amount = 1}, -- lambda
    { type = "item", name = "se-arcosphere-b", amount = 0}, -- xi
    { type = "item", name = "se-arcosphere-c", amount = 1}, -- zeta
    { type = "item", name = "se-arcosphere-d", amount = 0}, -- theta
    { type = "item", name = "se-arcosphere-g", amount = 1}, -- gamma
    { type = "item", name = "se-arcosphere-h", amount = 0}, -- omega
  }
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-macroscale-entanglement-data-alt",
  localised_name = {"item-name.se-kr-macroscale-entanglement-data"},
  group = "science",
  category = "arcosphere",
  subgroup = "data-advanced",
  energy_required = 20,
  main_product = "se-kr-macroscale-entanglement-data",
  order = "b-a-b",
  allow_productivity = false,
  ingredients = {
    {type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1}, -- lambda
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 0}, -- xi
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 0}, -- zeta
    {type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 1}, -- theta
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 0}, -- gamma
    {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1}, -- omega
    {type = "item", name = data_util.mod_prefix .. "significant-data", amount = 1},
    {type = "item", name = "kr-ai-core", amount = 1},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 20}
  },
  results = {
    { type = "item", name = "se-kr-macroscale-entanglement-data", amount = 1},
    { type = "item", name = "kr-ai-core", amount_min = 1, amount_max = 1, probability = 0.75},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
    { type = "item", name = "se-arcosphere-a", amount = 0}, -- lambda
    { type = "item", name = "se-arcosphere-b", amount = 1}, -- xi
    { type = "item", name = "se-arcosphere-c", amount = 0}, -- zeta
    { type = "item", name = "se-arcosphere-d", amount = 1}, -- theta
    { type = "item", name = "se-arcosphere-g", amount = 0}, -- gamma
    { type = "item", name = "se-arcosphere-h", amount = 1}, -- omega
  }
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-timespace-manipulation-data",
  group = "science",
  category = "arcosphere",
  subgroup = "data-advanced",
  energy_required = 20,
  main_product = "se-kr-timespace-manipulation-data",
  order = "b-b-a",
  allow_productivity = false,
  ingredients = {
    {type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1}, -- lambda
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 0}, -- xi
    {type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 1}, -- epsilon
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 0}, -- phi
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 0}, -- gamma
    {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1}, -- omega
    {type = "item", name = data_util.mod_prefix .. "significant-data", amount = 1},
    {type = "item", name = "kr-ai-core", amount = 1},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 20}
  },
  results = {
    { type = "item", name = "se-kr-timespace-manipulation-data", amount = 1},
    { type = "item", name = "kr-ai-core", amount_min = 1, amount_max = 1, probability = 0.75},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
    { type = "item", name = "se-arcosphere-a", amount = 1}, -- lambda
    { type = "item", name = "se-arcosphere-b", amount = 0}, -- xi
    { type = "item", name = "se-arcosphere-e", amount = 1}, -- epsilon
    { type = "item", name = "se-arcosphere-f", amount = 0}, -- phi
    { type = "item", name = "se-arcosphere-g", amount = 1}, -- gamma
    { type = "item", name = "se-arcosphere-h", amount = 0}, -- omega
  }
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-timespace-manipulation-data-alt",
  localised_name = {"item-name.se-kr-timespace-manipulation-data"},
  group = "science",
  category = "arcosphere",
  subgroup = "data-advanced",
  energy_required = 20,
  main_product = "se-kr-timespace-manipulation-data",
  order = "b-b-b",
  allow_productivity = false,
  ingredients = {
    {type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1}, -- lambda
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 0}, -- xi
    {type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 1}, -- epsilon
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 0}, -- phi
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 0}, -- gamma
    {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1}, -- omega
    {type = "item", name = data_util.mod_prefix .. "significant-data", amount = 1},
    {type = "item", name = "kr-ai-core", amount = 1},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 20}
  },
  results = {
    { type = "item", name = "se-kr-timespace-manipulation-data", amount = 1},
    { type = "item", name = "kr-ai-core", amount_min = 1, amount_max = 1, probability = 0.75},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
    { type = "item", name = "se-arcosphere-a", amount = 0}, -- lambda
    { type = "item", name = "se-arcosphere-b", amount = 1}, -- xi
    { type = "item", name = "se-arcosphere-e", amount = 0}, -- epsilon
    { type = "item", name = "se-arcosphere-f", amount = 1}, -- phi
    { type = "item", name = "se-arcosphere-g", amount = 0}, -- gamma
    { type = "item", name = "se-arcosphere-h", amount = 1}, -- omega
  }
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-singularity-application-data",
  group = "science",
  category = "arcosphere",
  subgroup = "data-advanced",
  energy_required = 20,
  main_product = "se-kr-singularity-application-data",
  order = "b-c-a",
  allow_productivity = false,
  ingredients = {
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 0}, -- zeta
    {type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 1}, -- theta
    {type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 1}, -- epsilon
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 0}, -- phi
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 0}, -- gamma
    {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1}, -- omega
    {type = "item", name = data_util.mod_prefix .. "significant-data", amount = 1},
    {type = "item", name = "kr-ai-core", amount = 1},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 20}
  },
  results = {
    { type = "item", name = "se-kr-singularity-application-data", amount = 1},
    { type = "item", name = "kr-ai-core", amount_min = 1, amount_max = 1, probability = 0.75},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
    { type = "item", name = "se-arcosphere-c", amount = 1}, -- zeta
    { type = "item", name = "se-arcosphere-d", amount = 0}, -- theta
    { type = "item", name = "se-arcosphere-e", amount = 1}, -- epsilon
    { type = "item", name = "se-arcosphere-f", amount = 0}, -- phi
    { type = "item", name = "se-arcosphere-g", amount = 1}, -- gamma
    { type = "item", name = "se-arcosphere-h", amount = 0}, -- omega
  }
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-singularity-application-data-alt",
  localised_name = {"item-name.se-kr-singularity-application-data"},
  group = "science",
  category = "arcosphere",
  subgroup = "data-advanced",
  energy_required = 20,
  main_product = "se-kr-singularity-application-data",
  order = "b-c-b",
  allow_productivity = false,
  ingredients = {
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 0}, -- zeta
    {type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 1}, -- theta
    {type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 1}, -- epsilon
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 0}, -- phi
    --{type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 0}, -- gamma
    {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1}, -- omega
    {type = "item", name = data_util.mod_prefix .. "significant-data", amount = 1},
    {type = "item", name = "kr-ai-core", amount = 1},
    {type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 20}
  },
  results = {
    { type = "item", name = "se-kr-singularity-application-data", amount = 1},
    { type = "item", name = "kr-ai-core", amount_min = 1, amount_max = 1, probability = 0.75},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 20},
    { type = "item", name = "se-arcosphere-c", amount = 0}, -- zeta
    { type = "item", name = "se-arcosphere-d", amount = 1}, -- theta
    { type = "item", name = "se-arcosphere-e", amount = 0}, -- epsilon
    { type = "item", name = "se-arcosphere-f", amount = 1}, -- phi
    { type = "item", name = "se-arcosphere-g", amount = 0}, -- gamma
    { type = "item", name = "se-arcosphere-h", amount = 1}, -- omega
  }
})

local adv_card = data.raw.recipe["kr-advanced-tech-card"]
adv_card.category = "science-pack-creation-1"
adv_card.energy_required = 20
adv_card.allow_productivity = false
adv_card.ingredients = {
  {type = "item", name = "se-significant-data", amount = 1}, -- 1 data card
  {type = "item", name = "se-kr-advanced-catalogue-1", amount = 1}, -- 11 data card
  {type = "fluid", name = data_util.mod_prefix .. "neural-gel-2", amount = 50},
  {type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 100}
}
adv_card.results = {
  {type = "item", name = "kr-advanced-tech-card", amount = 6},
  {type = "item", name = "se-junk-data", amount = 10},
  {type = "item", name = "se-broken-data", amount = 2},
  {type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 100}
}
adv_card.main_product = "kr-advanced-tech-card"
adv_card.always_show_made_in = true

-- Need to leave these in to migrate away from them.
local card = data.raw.recipe["kr-singularity-tech-card"]
card.category = "arcosphere"
card.energy_required = 180
card.allow_productivity = false
card.ingredients = {
  { type = "item", name = "se-deep-space-science-pack-3" , amount = 6},
  { type = "item", name = "se-significant-data", amount = 1},
  { type = "item", name = "kr-ai-core", amount = 1},
  { type = "item", name = "se-arcosphere-a", amount = 1}, -- lambda
  --{ type = "item", name = "se-arcosphere-b", amount = 0}, -- xi
  --{ type = "item", name = "se-arcosphere-c", amount = 0}, -- zeta
  { type = "item", name = "se-arcosphere-d", amount = 1}, -- theta
  { type = "item", name = "se-arcosphere-e", amount = 1}, -- epsilon
  --{ type = "item", name = "se-arcosphere-f", amount = 0}, -- phi
  --{ type = "item", name = "se-arcosphere-g", amount = 0}, -- gamma
  { type = "item", name = "se-arcosphere-h", amount = 1}, -- omega
  { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 200}
}
card.results = {
  { type = "item", name = "kr-singularity-tech-card", amount = 8},
  { type = "item", name = "se-junk-data", amount = 4},
  { type = "item", name = "se-broken-data", amount = 1},
  { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 200},
  { type = "item", name = "se-arcosphere-a", amount = 1}, -- lambda
  { type = "item", name = "se-arcosphere-b", amount = 0}, -- xi
  { type = "item", name = "se-arcosphere-c", amount = 1}, -- zeta
  { type = "item", name = "se-arcosphere-d", amount = 0}, -- theta
  { type = "item", name = "se-arcosphere-e", amount = 1}, -- epsilon
  { type = "item", name = "se-arcosphere-f", amount = 0}, -- phi
  { type = "item", name = "se-arcosphere-g", amount = 1}, -- gamma
  { type = "item", name = "se-arcosphere-h", amount = 0}, -- omega
}
card.hidden = true
card.main_product = "kr-singularity-tech-card"
card.always_show_made_in = true
card.icon = "__Krastorio2Assets__/icons/cards/singularity-tech-card.png"
card.icon_size = 64
card.subgroup = "science-pack"
card.order = "b11[singularity-tech-card]"
data_util.enable_recipe("kr-singularity-tech-card")

local card_alt = table.deepcopy(data.raw.recipe["kr-singularity-tech-card"])
card_alt.name = "singularity-tech-card-alt"
card_alt.ingredients = {
  { type = "item", name = "se-deep-space-science-pack-3" , amount = 6},
  { type = "item", name = "se-significant-data", amount = 1},
  { type = "item", name = "kr-ai-core", amount = 1},
  { type = "item", name = "se-arcosphere-a", amount = 1}, -- lambda
  --{ type = "item", name = "se-arcosphere-b", amount = 0}, -- xi
  --{ type = "item", name = "se-arcosphere-c", amount = 0}, -- zeta
  { type = "item", name = "se-arcosphere-d", amount = 1}, -- theta
  { type = "item", name = "se-arcosphere-e", amount = 1}, -- epsilon
  --{ type = "item", name = "se-arcosphere-f", amount = 0}, -- phi
  --{ type = "item", name = "se-arcosphere-g", amount = 0}, -- gamma
  { type = "item", name = "se-arcosphere-h", amount = 1}, -- omega
  { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 200}
}
card_alt.results = {
  { type = "item", name = "kr-singularity-tech-card", amount = 8},
  { type = "item", name = "se-junk-data", amount = 4},
  { type = "item", name = "se-broken-data", amount = 1},
  { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 200},
  { type = "item", name = "se-arcosphere-a", amount = 0}, -- lambda
  { type = "item", name = "se-arcosphere-b", amount = 1}, -- xi
  { type = "item", name = "se-arcosphere-c", amount = 0}, -- zeta
  { type = "item", name = "se-arcosphere-d", amount = 1}, -- theta
  { type = "item", name = "se-arcosphere-e", amount = 0}, -- epsilon
  { type = "item", name = "se-arcosphere-f", amount = 1}, -- phi
  { type = "item", name = "se-arcosphere-g", amount = 0}, -- gamma
  { type = "item", name = "se-arcosphere-h", amount = 1}, -- omega
}
card_alt.icon = "__Krastorio2Assets__/icons/cards/singularity-tech-card.png"
card_alt.icon_size = 64
card_alt.subgroup = "science-pack"
card_alt.order = "b11[singularity-tech-card]"
data:extend({card_alt})


local sing_pack = table.deepcopy(data.raw.recipe["kr-singularity-tech-card"])
sing_pack.name = "se-kr-advanced-science-pack-2"
sing_pack.category = "science-pack-creation-2"
sing_pack.subgroup = "advanced-science-pack"
sing_pack.order = "g[optimization-tech-card-3]-c"
sing_pack.hidden = false
sing_pack.energy_required = 40
sing_pack.allow_productivity = false
sing_pack.ingredients = {
  { type = "item", name = "kr-advanced-tech-card", amount = 6},
  { type = "item", name = "se-significant-data", amount = 1}, -- 1 data card
  { type = "item", name = "se-kr-advanced-catalogue-2", amount = 1}, -- 11 data cards
  { type = "item", name = "kr-ai-core", amount = 5},
  { type = "fluid", name = data_util.mod_prefix .. "neural-gel-2", amount = 10},
  { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 200}
}
sing_pack.results = {
  { type = "item", name = "kr-singularity-tech-card", amount = 8},
  { type = "item", name = "se-junk-data", amount = 10},
  { type = "item", name = "se-broken-data", amount = 2},
  { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 200},
}
sing_pack.icon = nil
sing_pack.icon_size = nil
sing_pack.icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-3.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png", icon_size = 64, tint = advanced_pack_tint}
}
sing_pack.main_product = "kr-singularity-tech-card"
sing_pack.always_show_made_in = true
data:extend({sing_pack})
data_util.tech_lock_recipes("kr-singularity-tech-card",{"se-kr-advanced-science-pack-2"})

local recipe = data.raw.recipe
-- Add categories to K2 Research Server and Quantum Computer (Advanced Research Server)
local catalog_1 = "catalogue-creation-1"
local catalog_2 = "catalogue-creation-2"
local science_1 = "science-pack-creation-1"
local science_2 = "science-pack-creation-2"

-- Add recipes to these new categories
recipe["se-astronomic-catalogue-1"].category = catalog_1
recipe["se-astronomic-catalogue-2"].category = catalog_1
recipe["se-astronomic-catalogue-3"].category = catalog_1
recipe["se-astronomic-catalogue-4"].category = catalog_1
recipe["se-biological-catalogue-1"].category = catalog_1
recipe["se-biological-catalogue-2"].category = catalog_1
recipe["se-biological-catalogue-3"].category = catalog_1
recipe["se-biological-catalogue-4"].category = catalog_1
recipe["se-energy-catalogue-1"].category = catalog_1
recipe["se-energy-catalogue-2"].category = catalog_1
recipe["se-energy-catalogue-3"].category = catalog_1
recipe["se-energy-catalogue-4"].category = catalog_1
recipe["se-material-catalogue-1"].category = catalog_1
recipe["se-material-catalogue-2"].category = catalog_1
recipe["se-material-catalogue-3"].category = catalog_1
recipe["se-material-catalogue-4"].category = catalog_1

recipe["se-deep-catalogue-1"].category = catalog_2
recipe["se-deep-catalogue-2"].category = catalog_2
recipe["se-deep-catalogue-3"].category = catalog_2
recipe["se-deep-catalogue-4"].category = catalog_2

recipe["se-astronomic-science-pack-1"].category = science_1
--recipe["se-astronomic-science-pack-1-no-beryllium"].category = science_1
recipe["se-astronomic-science-pack-2"].category = science_1
recipe["se-astronomic-science-pack-3"].category = science_1
recipe["se-astronomic-science-pack-4"].category = science_1
recipe["se-biological-science-pack-1"].category = science_1
recipe["se-biological-science-pack-2"].category = science_1
recipe["se-biological-science-pack-3"].category = science_1
recipe["se-biological-science-pack-4"].category = science_1
recipe["se-energy-science-pack-1"].category = science_1
recipe["se-energy-science-pack-2"].category = science_1
recipe["se-energy-science-pack-3"].category = science_1
recipe["se-energy-science-pack-4"].category = science_1
recipe["se-material-science-pack-1"].category = science_1
recipe["se-material-science-pack-2"].category = science_1
recipe["se-material-science-pack-3"].category = science_1
recipe["se-material-science-pack-4"].category = science_1

recipe["se-deep-space-science-pack-1"].category = science_2
recipe["se-deep-space-science-pack-2"].category = science_2
recipe["se-deep-space-science-pack-3"].category = science_2
recipe["se-deep-space-science-pack-4"].category = science_2

-- Original SE timings
-- Automation: 5s
-- 2x Logistic: 10s
-- 2x Military: 10s
-- 3x Chemical: 26s
-- 8x Rocket: 80s
-- 5x Space: 75s
-- Utility: 80s
-- Production: 60s
-- A/B/E/M 1/2/3/4 : 30s
-- Deep Space Science 1/2/3/4 : 60s/120s/180s/240s

-- Additionally, since the pack creation recipes previously took place in a 10 crafting speed machine, adjust time to craft down.
-- The servers consume much higher power per crafting speed as well, so science packs now cost more energy to craft too.
-- The servers also have fewer module slots, so their moduled and beaconed top speed is lower than a top speed manufactury as well.
local time_factor = 6 -- Arbitrary factor, can be changed as required for balance
recipe["se-astronomic-science-pack-1"].energy_required = recipe["se-astronomic-science-pack-1"].energy_required / time_factor
--recipe["se-astronomic-science-pack-1-no-beryllium"].energy_required = recipe["se-astronomic-science-pack-1-no-beryllium"].energy_required / time_factor
recipe["se-astronomic-science-pack-2"].energy_required = recipe["se-astronomic-science-pack-2"].energy_required / time_factor
recipe["se-astronomic-science-pack-3"].energy_required = recipe["se-astronomic-science-pack-3"].energy_required / time_factor
recipe["se-astronomic-science-pack-4"].energy_required = recipe["se-astronomic-science-pack-4"].energy_required / time_factor
recipe["se-biological-science-pack-1"].energy_required = recipe["se-biological-science-pack-1"].energy_required / time_factor
recipe["se-biological-science-pack-2"].energy_required = recipe["se-biological-science-pack-2"].energy_required / time_factor
recipe["se-biological-science-pack-3"].energy_required = recipe["se-biological-science-pack-3"].energy_required / time_factor
recipe["se-biological-science-pack-4"].energy_required = recipe["se-biological-science-pack-4"].energy_required / time_factor
recipe["se-energy-science-pack-1"].energy_required = recipe["se-energy-science-pack-1"].energy_required / time_factor
recipe["se-energy-science-pack-2"].energy_required = recipe["se-energy-science-pack-2"].energy_required / time_factor
recipe["se-energy-science-pack-3"].energy_required = recipe["se-energy-science-pack-3"].energy_required / time_factor
recipe["se-energy-science-pack-4"].energy_required = recipe["se-energy-science-pack-4"].energy_required / time_factor
recipe["se-material-science-pack-1"].energy_required = recipe["se-material-science-pack-1"].energy_required / time_factor
recipe["se-material-science-pack-2"].energy_required = recipe["se-material-science-pack-2"].energy_required / time_factor
recipe["se-material-science-pack-3"].energy_required = recipe["se-material-science-pack-3"].energy_required / time_factor
recipe["se-material-science-pack-4"].energy_required = recipe["se-material-science-pack-4"].energy_required / time_factor

recipe["se-deep-space-science-pack-1"].energy_required = recipe["se-deep-space-science-pack-1"].energy_required / time_factor
recipe["se-deep-space-science-pack-2"].energy_required = recipe["se-deep-space-science-pack-2"].energy_required / time_factor
recipe["se-deep-space-science-pack-3"].energy_required = recipe["se-deep-space-science-pack-3"].energy_required / time_factor
recipe["se-deep-space-science-pack-4"].energy_required = recipe["se-deep-space-science-pack-4"].energy_required / time_factor
