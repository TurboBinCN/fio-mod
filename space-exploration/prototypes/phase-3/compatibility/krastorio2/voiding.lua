local data_util = require("data_util")

local item_category_mult = {
  ["tile"] = 50,
  ["entity"] = 20,
  ["default"] = 5
}

local voids_to_remove = {
  "landfill"
}

for recipe_name, recipe_data in pairs(data.raw.recipe) do
  if recipe_data.category == "kr-void-crushing" then
    -- The way K2 sets these recipes up, they are furnace recipes that can
    -- only be done in the Crusher. So they must only have 1 ingredient.
    local name
    if    recipe_data.ingredients
      and recipe_data.ingredients[1]
    then
      if recipe_data.ingredients[1].name then
        name = recipe_data.ingredients[1].name
      else
        name = recipe_data.ingredients[1][1]
      end
    end

    if name then
      if data_util.table_contains(voids_to_remove, name) then
        data_util.delete_recipe(recipe_name)
      else
        local time_mult
        if data.raw.item[name] then
          if data.raw.item[name].place_as_tile then
            time_mult = item_category_mult["tile"]
          elseif data.raw.item[name].place_result then
            time_mult = item_category_mult["entity"]
          else
            time_mult = item_category_mult["default"]
          end
        else
          time_mult = item_category_mult["default"]
        end

        data.raw.recipe[recipe_name].auto_recycle = false
        data.raw.recipe[recipe_name].results = data.raw.recipe[recipe_name].results or {}
        data_util.replace_or_add_result(
          recipe_name,
          "kr-void",
          name,
          nil,
          nil,
          1,
          1,
          0.75
        )

        data_util.set_craft_time(recipe_name, recipe_data.energy_required * time_mult)
      end
    end
  end
end
