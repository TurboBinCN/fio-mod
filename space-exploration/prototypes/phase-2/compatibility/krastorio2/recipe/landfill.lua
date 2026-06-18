-- Landfill recipes -- needs to be in phase 2
local template = data.raw.recipe["landfill-iron-ore"]
local tech = data.raw.technology["se-recycling-facility"]

for order_letter, resource_name in pairs({["f"] = "kr-rare-metal-ore"}) do
  local recipe = table.deepcopy(template)
  recipe.name = "landfill-" .. resource_name
  recipe.order = "c[landfill]-"..order_letter.."["..resource_name.."]"
  recipe.icon = nil
  recipe.icons = {
    { icon = data.raw.item["landfill"].icon, icon_size = data.raw.item["landfill"].icon_size },
    { icon = data.raw.item[resource_name].icon, icon_size = data.raw.item[resource_name].icon_size, scale = 0.33 },
  }
  if recipe.ingredients then
    recipe.ingredients = { {type = "item",  name = resource_name, amount = 50 } }
  end
  table.insert(tech.effects, { type = "unlock-recipe", recipe = recipe.name })
  data:extend({ recipe })
end
