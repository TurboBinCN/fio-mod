local data_util = require("data_util")

-- Singularity Lab Recipe
data.raw.recipe["kr-singularity-lab"].category = "space-manufacturing"
data.raw.recipe["kr-singularity-lab"].ingredients = { -- this needs to change too much to make item by item changes
  {type = "item", name = "se-space-science-lab", amount = 1},
  {type = "item", name = "se-space-radiator-2", amount = 8},
  {type = "item", name = "se-space-hypercooler", amount = 2},
  {type = "item", name = "kr-ai-core", amount = 50}, -- Biological
  {type = "item", name = "se-heavy-composite", amount = 50}, -- Material
  {type = "item", name = "se-dynamic-emitter", amount = 50}, -- Energy
  {type = "item", name = "se-nanomaterial", amount = 50}, -- Astronomic
  { type = "fluid", name = "se-space-coolant-supercooled", amount = 2000},
}

-- Replace Battery with Lithium-Sulfur Battery in the Space Science Laboratory recipe
data_util.replace_or_add_ingredient("se-space-science-lab","battery","kr-lithium-sulfur-battery",10)
