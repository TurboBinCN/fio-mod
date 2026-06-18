local data_util = require("data_util")

-- Rocket science pack
-- Since K2 doesn't have an icon for this specifically, we will use one of the existing but unused K2 icons instead.
local rocket_science_recipe = data.raw.recipe["se-rocket-science-pack"]
rocket_science_recipe.icons = nil
rocket_science_recipe.icon = "__Krastorio2Assets__/icons/cards/utility-tech-card.png"
rocket_science_recipe.icon_size = 64

-- Add Blank Tech Card from K2 tech cards
data_util.replace_or_add_ingredient("se-rocket-science-pack", nil, "kr-blank-tech-card", 8)

-- Ensure a recipe for space research data exists
if data.raw.item["kr-space-research-data"] and not data.raw.recipe["kr-space-research-data"] then
  data:extend({
    {
        type = "recipe",
        name = "kr-space-research-data",
        enabled = false,
        energy_required = 1,
        ingredients = {
          { type = "item", name = "se-heat-shielding", amount = 2},
          { type = "item", name = "speed-module", amount = 1},
          { type = "item", name = "kr-imersite-crystal", amount = 2},
          { type = "item", name = "kr-imersium-plate", amount = 3},
          { type = "item", name = "se-machine-learning-data", amount = 3},
          { type = "fluid", name = "lubricant", amount = 100}
        },
        results = {
          { type = "item", name = "kr-space-research-data", amount = 5},
        },
        main_product = "kr-space-research-data",
        requester_paste_multiplier = 1,
        subgroup = "science-pack",
        category = "space-manufacturing",
        always_show_made_in = true
    }
  })
  data_util.recipe_require_tech("kr-space-research-data", "kr-optimization-tech-card")
end

local opti_recipe = data.raw.recipe["kr-optimization-tech-card"]

-- Update Optimization Tech Card to only be made in space
opti_recipe.category = "space-manufacturing"
opti_recipe.always_show_made_in = true

data_util.replace_or_add_result("kr-optimization-tech-card", nil, "se-junk-data", 3)
opti_recipe.main_product = "kr-optimization-tech-card"
