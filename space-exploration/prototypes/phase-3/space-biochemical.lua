local RecipeTints = require("prototypes/recipe-tints")

-- biochemical facility can do both oil-processing and chemistry
-- oil-processing doesn't have tints in vanilla
data.raw.recipe["basic-oil-processing"].crafting_machine_tint = RecipeTints.oil_to_petrol_tint
data.raw.recipe["coal-liquefaction"].crafting_machine_tint = RecipeTints.coal_to_petrol_tint
data.raw.recipe["advanced-oil-processing"].crafting_machine_tint = RecipeTints.oil_to_light_tint
data.raw.recipe["oil-processing-heavy"].crafting_machine_tint = RecipeTints.oil_to_heavy_tint
