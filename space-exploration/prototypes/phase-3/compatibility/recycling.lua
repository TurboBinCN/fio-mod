local data_util = require("data_util")

if mods["quality"] then
  local recycling = require(debug.getinfo(generate_recycling_recipe_icons_from_item, "S").short_src)

  -- here we replicate data-updates.lua of the quality mod at the end of our own data-final-fixes,
  -- note that we override the recycling recipes, any we skip will probably come back to haunt us.

  do
    for name, recipe in pairs(data.raw.recipe) do
      recycling.generate_recycling_recipe(recipe)
    end

    local maybe_generate_self_recycling_recipe = function(item)
      if item.auto_recycle == false then return end
      if item.parameter then return end

      if not data.raw.recipe[item.name .. "-recycling"] then
        if not string.find(item.name, "-barrel") then
          recycling.generate_self_recycling_recipe(item)
        end
      end
    end

    for type_name in pairs(defines.prototypes.item) do
      for _, item in pairs(data.raw[type_name] or {}) do
        if item.self_recycle then
          recycling.generate_self_recycling_recipe(item)
        else
          maybe_generate_self_recycling_recipe(item)
        end
      end
    end
  end

  -- blocks the item from going in at all
  local function not_recycable(item_name)
    data.raw.recipe[item_name .. "-recycling"] = nil
  end

  not_recycable(data_util.mod_prefix .. "arcosphere")
  not_recycable(data_util.mod_prefix .. "arcosphere-a")
  not_recycable(data_util.mod_prefix .. "arcosphere-b")
  not_recycable(data_util.mod_prefix .. "arcosphere-c")
  not_recycable(data_util.mod_prefix .. "arcosphere-d")
  not_recycable(data_util.mod_prefix .. "arcosphere-e")
  not_recycable(data_util.mod_prefix .. "arcosphere-f")
  not_recycable(data_util.mod_prefix .. "arcosphere-g")
  not_recycable(data_util.mod_prefix .. "arcosphere-h")
  not_recycable(data_util.mod_prefix .. "linked-container")

  -- note: the if is just there in case we still clear the categories array somewhere in order to hide the feature
  local recycling_recipe_categories = data.raw["utility-constants"]["default"].factoriopedia_recycling_recipe_categories
  if #recycling_recipe_categories > 0 then
    table.insert(recycling_recipe_categories, "recycling-blacklist")
    data:extend{{
      type = "recipe-category",
      name = "recycling-blacklist",
    }}
  end

  for type_name in pairs(defines.prototypes.item) do
    for _, item in pairs(data.raw[type_name] or {}) do
      local recipe_name = item.name .. "-recycling"
      if not data.raw.recipe[recipe_name] then
        data:extend{{
          type = "recipe",
          name = recipe_name,
          localised_name = {"recipe-name.recycling-blacklist"},
          icon = "__base__/graphics/icons/signal/signal-no-entry.png",
          subgroup = item.subgroup,
          category = "recycling-blacklist",
          hidden = true,
          enabled = true,
          unlock_results = false,
          ingredients = {{type = "item", name = item.name, amount = 1, ignored_by_stats = 1}},
          energy_required = 1,
        }}
      end
    end
  end
end
