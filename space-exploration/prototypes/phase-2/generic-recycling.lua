local data_util = require("data_util")

local function scrapping_recipe(item_name, input_count, results)
  local item = data.raw.item[item_name]
  if not item then return end
  -- return can be a number or a result list
  if type(results) == "number" then
    if results < 1 then
      results = {{type = "item", name = data_util.mod_prefix .. "scrap", amount_min = 1, amount_max = 1, probability = results}}
    else
      results = {{type = "item", name = data_util.mod_prefix .. "scrap", amount = results}}
    end
  end

  local recipe = {
    type = "recipe",
    name = data_util.mod_prefix .. "-scrapping-"..item_name,
    ingredients = {
      {type = "item", name = item_name, amount = input_count}
    },
    results = results,
    category = "hard-recycling",
    subgroup = "recycling",
    icons = data_util.transition_icons(
      {
        icon = item.icon,
        icon_size = item.icon_size, scale = 0.5,
        draw_background = true,
      },
      {
        icon = data.raw.item[data_util.mod_prefix .. "scrap"].icon,
        icon_size = data.raw.item[data_util.mod_prefix .. "scrap"].icon_size, scale = 0.5,
        draw_background = true,
      }
    ),
    energy_required = 1,
    localised_name = {"recipe-name." .. data_util.mod_prefix .. "generic-scrapping", {"entity-name."..item_name}},
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    --hide_from_player_crafting = true,
    hide_from_signal_gui = false,
    order = "a[recycling]-d[scrapping]-f[scrapping]"
  }
  data:extend({recipe})
  data_util.tech_lock_recipes(data_util.mod_prefix.."recycling-facility", {data_util.mod_prefix .. "-scrapping-"..item_name})
end

local function reverse_recipe(recipe_name, item_name)
  local o_recipe = data.raw.recipe[recipe_name]
  if not o_recipe then return end
  if not item_name then item_name = recipe_name end
  local item = data.raw.item[item_name]
  if not item then return end


  local recipe = {
    type = "recipe",
    name = data_util.mod_prefix .. "recycle-"..recipe_name,
    category = "hard-recycling",
    subgroup = "recycling",
    icons = data_util.transition_icons(
      {
        icon = item.icon,
        icon_size = item.icon_size, scale = 0.5,
        draw_background = true,
      },
      {
        icon = data.raw.item[data_util.mod_prefix .. "scrap"].icon,
        icon_size = data.raw.item[data_util.mod_prefix .. "scrap"].icon_size, scale = 0.5,
        draw_background = true,
      }
    ),
    energy_required = 1,
    localised_name = {"recipe-name." .. data_util.mod_prefix .. "generic-recycling", {"entity-name."..item_name}},
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    --hide_from_player_crafting = true,
    hide_from_signal_gui = false,
    order = "a[recycling]-d[scrapping]-f[scrapping-"..recipe_name.."]"
  }
  recipe.ingredients = {{type = "item", name=item_name, amount = 1}}
  recipe.results = table.deepcopy(o_recipe.ingredients)

  local o_result_qty
  for k, o_result in pairs(o_recipe.results) do
    if o_result.name == item_name then
      o_result_qty = o_result.amount or 1
    end
  end

  for k, result in pairs(recipe.results) do
    local name = result.name or result[1]
    local count = result.amount or (result[2] or 1)
    local type = result.type
    local return_count = count * 0.75 * (1 / o_result_qty)
    if return_count < 1 then
      recipe.results[k] = {type = type, name=name, amount_min = 1, amount_max = 1, probability = return_count}
    else
      recipe.results[k] = {type = type, name=name, amount = math.floor(return_count)}
    end
  end
  data:extend({recipe})
  data_util.tech_lock_recipes(data_util.mod_prefix.."recycling-facility", {data_util.mod_prefix .. "recycle-"..recipe_name})
end

reverse_recipe("small-electric-pole")
reverse_recipe("small-iron-electric-pole")
reverse_recipe("medium-electric-pole")
reverse_recipe("big-electric-pole")
reverse_recipe("substation")
reverse_recipe("radar")
reverse_recipe("pistol")

data:extend({
  {
    type = "recipe",
    name = "landfill",
    subgroup = "landfill",
    energy_required = 1,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = "stone", amount = 50}
    },
    results = {
      {type = "item", name = "landfill", amount = 1},
    },
    order = "z-a-a"
  },
  {
    type = "recipe",
    name = "landfill-sand",
    subgroup = "landfill",
    localised_name = {"item-name.landfill"},
    energy_required = 1,
    enabled = false,
    category = "crafting",
    icons = {
      {icon = data.raw.item.landfill.icon, icon_size = data.raw.item.landfill.icon_size},
      {icon = data.raw.item[SEItemNames.get_sand_name()].icon, icon_size = data.raw.item[SEItemNames.get_sand_name()].icon_size or 64, scale = 0.33*64/(data.raw.item[SEItemNames.get_sand_name()].icon_size or 64)},
    },
    ingredients =
    {
      {type = "item", name = SEItemNames.get_sand_name(), amount = 200}
    },
    results = {
      {type = "item", name = "landfill", amount = 1},
    },
    order = "z-a-b",
    allow_decomposition = false,
    hide_from_signal_gui = false,
  }
})
data_util.tech_lock_recipes("landfill", {"landfill-sand"})
data.raw.item["landfill"].subgroup = "landfill"

local function landfil_recipe(item_name, count)
  data:extend({
    {
      type = "recipe",
      name = "landfill-"..item_name,
      subgroup = "landfill",
      localised_name = {"item-name.landfill"},
      energy_required = 1,
      enabled = false,
      category = "hard-recycling",
      icons = {
        {icon = data.raw.item.landfill.icon, icon_size = data.raw.item.landfill.icon_size or 64},
        {icon = data.raw.item[item_name].icon, icon_size = data.raw.item[item_name].icon_size or 64, scale = 0.33*64/(data.raw.item[item_name].icon_size or 64)},
      },
      ingredients =
      {
        {type = "item", name = item_name, amount = count}
      },
      results = {
        {type = "item", name = "landfill", amount = 1},
      },
      order = "z-b-"..item_name,
      allow_decomposition = false,
      hide_from_signal_gui = false,
    }
  })
  data_util.tech_lock_recipes(data_util.mod_prefix.."recycling-facility", {"landfill-"..item_name})
end

landfil_recipe(data_util.mod_prefix.."scrap", 100)
landfil_recipe("iron-ore", 50)
landfil_recipe("copper-ore", 50)
landfil_recipe(data_util.mod_prefix.."iridium-ore", 25)
landfil_recipe(data_util.mod_prefix.."holmium-ore", 50)
landfil_recipe(data_util.mod_prefix.."beryllium-ore", 50)
