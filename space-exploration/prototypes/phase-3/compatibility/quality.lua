local data_util = require("data_util")

if feature_flags["quality"] then

  for _, entity in ipairs(data.raw["mod-data"][data_util.mod_prefix .. "loses-quality-when-placed"].data.entities) do
    local prototype = data.raw[entity.type][entity.name]
    if prototype then
      data_util.add_custom_tooltip_field(prototype, {
        key = "loses-quality-when-placed",
        name = "", -- the colon cannot be styled bold like the rest so we hide it
        value = {"space-exploration.loses_quality_when_placed_line"},
        order = 0,
      })
    end
  end

  local is_arcosphere_variant = util.list_to_map({
    data_util.mod_prefix .. "arcosphere-a",
    data_util.mod_prefix .. "arcosphere-b",
    data_util.mod_prefix .. "arcosphere-c",
    data_util.mod_prefix .. "arcosphere-d",
    data_util.mod_prefix .. "arcosphere-e",
    data_util.mod_prefix .. "arcosphere-f",
    data_util.mod_prefix .. "arcosphere-g",
    data_util.mod_prefix .. "arcosphere-h",
  })

  for _, recipe in pairs(data.raw.recipe) do
    for _, result in ipairs(recipe.results or {}) do
      if result.type == "item" and is_arcosphere_variant[result.name] then
        if recipe.allow_quality ~= false then
          recipe.allow_quality = false
          debug_log("blocked quality on recipe producing arcosphere variants: " .. recipe.name)
        end
      end
    end
  end

end

-- require opt-in before being able to research quality mod techs
if mods["quality"] and settings.startup["se-quality-mod-support"].value == false then

  for _, technology_name in pairs({
    "quality-module",
    "quality-module-2",
    "quality-module-3",
    "quality-module-4",
    "quality-module-5",
    "quality-module-6",
    "quality-module-7",
    "quality-module-8",
    "quality-module-9",
    "epic-quality",
    "legendary-quality",
  }) do
    local technology = data.raw.technology[technology_name]
    technology.hidden = true
  end

  for _, item_name in pairs({
    "quality-module",
    "quality-module-2",
    "quality-module-3",
    "quality-module-4",
    "quality-module-5",
    "quality-module-6",
    "quality-module-7",
    "quality-module-8",
    "quality-module-9",
  }) do
    local item = data.raw.module[item_name]
    local recipe = data.raw.recipe[item_name]
    item.hidden = true
    recipe.hidden = true
  end

  if not mods["space-age"] then
    data.raw.item["recycler"].hidden = true
    data.raw.recipe["recycler"].hidden = true
    data.raw.furnace["recycler"].hidden = true
    data.raw.technology["recycling"].hidden = true
    data.raw["utility-constants"]["default"].factoriopedia_recycling_recipe_categories = {}
  end

  for _, quality_name in pairs({
    "normal", -- to avoid normal quality being the only one in the list
    "uncommon",
    "rare",
    "epic",
    "legendary",
  }) do
    local quality = data.raw.quality[quality_name]
    quality.hidden = true
  end

  -- hidden qualities still cause the recipe quality selector to appear as well as a dropdown in the production stats
  data_util.tech_remove_effects("quality-module", {{type = "unlock-quality", quality = "uncommon"}})
  data_util.tech_remove_effects("quality-module", {{type = "unlock-quality", quality = "rare"}})
  data_util.tech_remove_effects("epic-quality", {{type = "unlock-quality", quality = "epic"}})
  data_util.tech_remove_effects("legendary-quality", {{type = "unlock-quality", quality = "legendary"}})

  -- block quality scrolling through hidden (well, all) qualities
  data:extend{
    {
      type = "custom-input",
      name = data_util.mod_prefix .. "cycle-quality-up",
      linked_game_control = "cycle-quality-up", key_sequence = "",
      consuming = "game-only",
    },
    {
      type = "custom-input",
      name = data_util.mod_prefix .. "cycle-quality-down",
      linked_game_control = "cycle-quality-down", key_sequence = "",
      consuming = "game-only",
    },
  }
end
