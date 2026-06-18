local data_util = require("data_util")
local path = "prototypes/phase-2/compatibility/krastorio2/"

if mods["Krastorio2"] then

  require(path .. "item/item_compat")
  require(path .. "recipe/recipe_compat")
  require(path .. "technology/technology_compat")
  require(path .. "entity/entity_compat")

  require(path .. "ordering")
end
