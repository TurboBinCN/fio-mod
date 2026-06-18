local data_util = require("data_util")

-- Add recipe categories to the machines
table.insert(data.raw["assembling-machine"]["se-space-material-fabricator"].crafting_categories, "advanced-particle-stream")
table.insert(data.raw["assembling-machine"]["kr-matter-plant"].crafting_categories, "basic-matter-conversion")
table.insert(data.raw["assembling-machine"]["kr-matter-associator"].crafting_categories, "basic-matter-deconversion")

-- Update some matter fusion recipes.
data_util.replace_or_add_ingredient("se-kr-matter-fusion-kr-rare-metal-ore", "se-fusion-test-data", "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-kr-matter-fusion-kr-imersite", nil, "se-kr-matter-synthesis-data", 1)

---- K2 Matter Recipes
-- Remove biological matter recipes as conversion is not able to make "complex biochemistry"
data_util.delete_recipe("kr-wood-to-matter")
data_util.delete_recipe("kr-matter-to-wood")
data_util.delete_recipe("kr-kr-biomass-to-matter")
data_util.delete_recipe("kr-matter-to-kr-biomass")
-- Remove imersite powder to bring in line with vulcanite and cryonite
data_util.delete_recipe("kr-kr-imersite-powder-to-matter")
data_util.delete_recipe("kr-matter-to-kr-imersite-powder")

-- Experimental Matter Processing
data_util.make_recipe({
    type = "recipe",
    name = "se-kr-experimental-matter-processing",
    localised_name = {"recipe-name.se-kr-experimental-matter-processing"},
    category = "basic-matter-conversion",
    subgroup = "basic-matter-conversion",
    order = "a[basic-matter]-a[conversion]-a[particle]",
    ingredients = {
      { type = "item", name = "se-material-testing-pack", amount = 5},
      { type = "item", name = "se-kr-matter-catalogue-1", amount = 1},
      { type = "fluid", name = "se-particle-stream", amount = 50},
    },
    results = {
      { type = "item", name = "se-scrap", amount = 15},
      { type = "fluid", name = "kr-matter", amount = 10}, -- amount can change if needed.
    },
    icons = {
      { icon = "__Krastorio2Assets__/icons/arrows/arrow-m.png", icon_size = 64},
      { icon = data.raw.fluid["se-particle-stream"].icon, icon_size = 64, scale = 0.28, shift = {-8,-6}},
      { icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {4,8}},
    },
    main_product = "kr-matter",
    allow_as_intermediate = false,
  })

  -- Add Naquium Cube nad other SE Materials to K2 Matter buildings
data.raw.recipe["kr-matter-plant"].ingredients = {
  { type = "item", name = "kr-imersium-beam", amount = 5},
  { type = "item", name = "se-heat-shielding", amount = 10},
  { type = "item", name = "se-heavy-assembly", amount = 4},
  { type = "item", name = "kr-ai-core", amount = 2},
  { type = "item", name = "se-lattice-pressure-vessel", amount = 5},
  { type = "item", name = "se-kr-matter-catalogue-1", amount = 1},
  { type = "item", name = "se-naquium-cube", amount = 1},
  { type = "item", name = "se-space-pipe", amount = 10},
}

data.raw.recipe["kr-matter-associator"].ingredients = {
  { type = "item", name = "kr-imersium-beam", amount = 5},
  { type = "item", name = "se-heat-shielding", amount = 10},
  { type = "item", name = "se-heavy-assembly", amount = 4},
  { type = "item", name = "kr-ai-core", amount = 2},
  { type = "item", name = "se-lattice-pressure-vessel", amount = 5},
  { type = "item", name = "se-kr-matter-catalogue-2", amount = 1},
  { type = "item", name = "se-naquium-cube", amount = 1},
  { type = "item", name = "se-space-pipe", amount = 10},
}

-- Make Basic Stabilizer recipes
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-basic-stabilizer",
  ingredients = {
    {type = "item",  name = "se-magnetic-canister", amount = 1},
    {type = "item",  name = "se-kr-matter-catalogue-2", amount = 1},
    {type = "item",  name = "se-lattice-pressure-vessel", amount = 1},
    {type = "item",  name = "kr-energy-control-unit", amount = 2},
    {type = "item",  name = "kr-ai-core", amount = 1},
  },
  results = {
    {type = "item",  name = "se-kr-basic-stabilizer", amount = 1},
  },
  icons = {
    {icon = "__Krastorio2Assets__/icons/items/matter-stabilizer.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/compatability/icons/basic-matter-stabilizer-layer.png", icon_size = 64}
  },
  main_product = "se-kr-basic-stabilizer",
  allow_as_intermediate = false,
  allow_productivity = true,
  energy_required = 5
})

data_util.make_recipe({
  type = "recipe",
  name = "se-kr-charged-basic-stabilizer",
  category = "kr-stabilizer-charging",
  subgroup = "advanced-assembling",
  ingredients = {
    {type = "item",  name = "se-kr-basic-stabilizer", amount = 1},
  },
  results = {
    {type = "item",  name = "se-kr-charged-basic-stabilizer", amount = 1},
  },
  icons = {
    {icon = "__Krastorio2Assets__/icons/items/charged-matter-stabilizer.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/compatability/icons/basic-matter-stabilizer-layer.png", icon_size = 64}
  },
  main_product = "se-kr-charged-basic-stabilizer",
  allow_as_intermediate = false,
  energy_required = 2,
})
data_util.recipe_require_tech("se-kr-charged-basic-stabilizer", "kr-matter-processing")

-- Require Naquium Cube and other SE Materials for the Stabilizer Charging Station
data_util.replace_or_add_ingredient("kr-stabilizer-charging-station", nil, "se-heavy-assembly", 2)
data_util.replace_or_add_ingredient("kr-stabilizer-charging-station", nil, "se-quantum-processor", 2)
data_util.replace_or_add_ingredient("kr-stabilizer-charging-station", nil, "se-dynamic-emitter", 1)
data_util.replace_or_add_ingredient("kr-stabilizer-charging-station", nil, "se-naquium-cube", 1)

-- Non-basic Stabiliser recipe
data_util.replace_or_add_ingredient("kr-matter-stabilizer", "processing-unit", "se-kr-basic-stabilizer", 1)
data_util.replace_or_add_ingredient("kr-matter-stabilizer", "kr-energy-control-unit", "kr-ai-core", 1)
data_util.replace_or_add_ingredient("kr-matter-stabilizer", "kr-imersium-plate", "se-quantum-processor", 2)
data_util.replace_or_add_ingredient("kr-matter-stabilizer", nil, "se-naquium-tessaract", 1)

-- Introduce the basic stabilizer to the raw resource matter deconversion recipes.
local function add_basic_stabilizer(recipe)
  data_util.replace_or_add_ingredient(recipe, nil, "se-kr-charged-basic-stabilizer", 1)
  data_util.replace_or_add_result(recipe, nil, "se-kr-charged-basic-stabilizer", nil, nil, 1, 1, 0.199)
  data_util.replace_or_add_result(recipe, nil, "se-kr-basic-stabilizer", nil, nil, 1, 1, 0.8)
end

add_basic_stabilizer("kr-matter-to-stone")
add_basic_stabilizer("kr-matter-to-kr-sand")
add_basic_stabilizer("kr-matter-to-coal")
add_basic_stabilizer("kr-matter-to-copper-ore")
add_basic_stabilizer("kr-matter-to-iron-ore")
add_basic_stabilizer("kr-matter-to-crude-oil")
add_basic_stabilizer("kr-matter-to-kr-rare-metal-ore")
add_basic_stabilizer("kr-matter-to-uranium-ore")
add_basic_stabilizer("kr-matter-to-uranium-238")
add_basic_stabilizer("kr-matter-to-water")
add_basic_stabilizer("kr-matter-to-kr-mineral-water")

-- Replace Singularity Cells with Antimatter Canisters in Antimatter Weaponry
data_util.replace_or_add_ingredient("kr-antimatter-turret-rocket", "kr-charged-antimatter-fuel-cell", "se-antimatter-canister", 1)
data_util.replace_or_add_ingredient("kr-antimatter-artillery-shell", "kr-charged-antimatter-fuel-cell", "se-antimatter-canister", 3)
data_util.replace_or_add_ingredient("kr-antimatter-rocket", "kr-charged-antimatter-fuel-cell", "se-antimatter-canister", 2)
data_util.replace_or_add_ingredient("kr-antimatter-railgun-shell", "kr-charged-antimatter-fuel-cell", "se-antimatter-canister", 1)

data_util.replace_or_add_ingredient("kr-antimatter-reactor-equipment", nil, "se-naquium-processor", 1)

local function increase_catalysts(ingredient, factor)
  if ingredient.ignored_by_stats then
    ingredient.ignored_by_stats = ingredient.ignored_by_stats * factor
  end
  if ingredient.ignored_by_productivity then
    ingredient.ignored_by_productivity = ingredient.ignored_by_productivity * factor
  end
end

-- reduce effectivness of matter deconversion
-- otherwise it is too easy to bypass planet resource restrictions.
for _, recipe in pairs(data.raw.recipe) do
  if recipe.subgroup == "kr-matter-deconversion" then
    if recipe.ingredients then
      for _, ingredient in pairs(recipe.ingredients) do
        if ingredient.name == "kr-matter" then
          ingredient.amount = ingredient.amount * 2
          increase_catalysts(ingredient, 2)
        end
      end
    end
  end
end
