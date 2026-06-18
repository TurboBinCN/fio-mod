Log = require('scripts/log')

local data_util = require("shared_util")

data_util.liquid_rocket_fuel_per_solid = 50
data_util.speed_module_3_speed_bonus = 0.4 -- Used for animation speed calculations

data_util.console_tint = {r=0, g=0.3, b=1}
data_util.console_alt_tint = {r=1, g=0.5, b=0}
data_util.utility_science_tint = {r=0, g=1, b=0.8}
data_util.production_science_tint = {r=1, g=0, b=0}

data_util.coolant_temperature = {
    supercooled = -273,
    cold = -100,
    normal = -10,
    hot = 25
}

data_util.obs_types = {
  ["infrared"] = {"infrared", 10, 0.85},
  ["visible"] = {"visible", 12, 0.98},
  ["uv"] = {"uv", 10, 0.9},
  ["microwave"] = {"microwave", 8, 0.75},
  ["xray"] = {"xray", 4, 0.85},
  ["radio"] = {"radio", 6, 0.6},
  ["gammaray"] = {"gammaray", 3, 0.85},
}

data_util.char_to_multiplier = {
    m = 0.001,
    c = 0.01,
    d = 0.1,
    h = 100,
    k = 1000,
    K = 1000,
    M = 1000000,
    G = 1000000000,
    T = 1000000000000,
    P = 1000000000000000,
}

data_util.machine_open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.5}
data_util.machine_close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.5}
data_util.electric_network_open_sound = {filename = "__base__/sound/electric-network-open.ogg", volume = 0.6}
data_util.electric_network_close_sound = {filename = "__base__/sound/electric-network-close.ogg", volume = 0.6}

function data_util.string_to_number(str)
    str = ""..str
    local number_string = ""
    local last_char = nil
    for i = 1, #str do
        local c = str:sub(i,i)
        if c == "." or tonumber(c) ~= nil then
            number_string = number_string .. c
        else
            last_char = c
            break
        end
    end
    local number = tonumber(number_string)
    if number and last_char and data_util.char_to_multiplier[last_char] then
        return number * data_util.char_to_multiplier[last_char]
    end
    return number
end

function data_util.string_to_simple_int(str, continues)
    str = ""..str
    if continues then -- Remove the tech's prefix, to hopefully stop issues with numbers in the prefix.
        str = str:gsub ("%w+-", "", 1)
    end
    local number_string = ""
    for i = 1, #str do
        local c = str:sub(i,i)
        if tonumber(c) ~= nil then
          number_string = number_string .. c
        --[[       elseif continues then -- discard the numbers found so far if a non-number is found, if the flag is set to true
          number_string = ""]]
        end
    end
    local number = tonumber(number_string)
    return number
end

function data_util.string_split(str, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(str, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function data_util.string_join(str_table, sep)
  local str = ""
  for _, str_part in pairs(str_table) do
    if str ~= "" then
      str = str .. sep
    end
      str = str .. str_part
  end
  return str
end

function data_util.dot_string_less_than(a, b, allow_equal)
  if allow_equal and a == b then return true end
  local a_parts = data_util.string_split(a, ".")
  local b_parts = data_util.string_split(b, ".")
  for i = 1, #a_parts do
    if tonumber(a_parts[i]) < tonumber(b_parts[i]) then
      return true
    elseif a_parts[i] ~= b_parts[i] then
      return false
    end
  end
  return false
end

function data_util.dot_string_greater_than(a, b, allow_equal)
  if allow_equal and a == b then return true end
  local a_parts = data_util.string_split(a, ".")
  local b_parts = data_util.string_split(b, ".")
  for i = 1, #a_parts do
    if tonumber(a_parts[i]) > tonumber(b_parts[i]) then
      return true
    elseif a_parts[i] ~= b_parts[i] then
      return false
    end
  end
  return false
end

function data_util.remove_number_suffix(str)
  local parts = data_util.string_split (str, "-")
  local int = data_util.string_to_simple_int(parts[#parts])
  if int and int.."" == parts[#parts] then
    -- last part was a number
    parts[#parts] = nil
    return data_util.string_join(parts, "-")
  end
  return str
end

-- return {name = name, amount = amount::float}
function data_util.collapse_product(product)
  if product[1] and type(product[1]) == "string" then
    if product[2] then
      return {name = product[1], amount = product[2]}
    else
      return {name = product[1], amount = 1}
    end
  end
  if product.name then
    local collapsed = {name = product.name, amount = product.amount, type = product.type}
    if product.amount_min and product.amount_max then
      collapsed.amount = (product.amount_min + product.amount_max) / 2 * (product.probability or 1)
    end
    return collapsed
  end
end

-- return {name = name, amount = amount::float}
function data_util.collapse_products(products)
  local combined = {}
  for _, product in pairs(products) do
    local collapsed = data_util.collapse_product(product)
    if collapsed then
      if combined[collapsed.name] then
        combined[collapsed.name].amount = combined[collapsed.name].amount + collapsed.amount
      else
        combined[collapsed.name] = collapsed
      end
    end
  end
  return combined
end


function data_util.get_ingredients_tables(recipe)
  local tables = {}
  if recipe.ingredients then table.insert(tables, recipe.ingredients) end
  return tables
end

function data_util.conditional_modify(prototype)
  -- pass in a partial prototype that includes .type and .name
  -- overwrite sections of the raw prototype with the new one
  if data.raw[prototype.type] and data.raw[prototype.type][prototype.name] then
    local raw = data.raw[prototype.type][prototype.name]

    for key, property in pairs(prototype) do
      raw[key] = property
    end

  end
end

function data_util.disable_recipe(recipe_name)
  data_util.conditional_modify({
    type = "recipe",
    name = recipe_name,
    enabled = false,
  })
end

function data_util.enable_recipe(recipe_name)
  data_util.conditional_modify({
    type = "recipe",
    name = recipe_name,
    enabled = true,
  })
  for _, tech in pairs(data.raw.technology) do
      if tech.effects then
          data_util.remove_recipe_from_effects(tech.effects, recipe_name)
      end
  end
end

function data_util.remove_recipe_from_effects(effects, recipe)
    local index = 0
    for _,_item in ipairs(effects) do
        if _item.type == "unlock-recipe" and _item.recipe == recipe then
            index = _
            break
        end
    end
    if index > 0 then
        table.remove(effects, index)
    end
end

function data_util.recipe_set_energy_required(recipe, energy_required)
  if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
  recipe.energy_required = energy_required
end

function data_util.remove_ingredient_sub(recipe, name)
  for i = #recipe.ingredients, 1, -1 do
    if recipe.ingredients[i] then
      for _, value in pairs(recipe.ingredients[i]) do
        if value == name then
          table.remove(recipe.ingredients, i)
        end
      end
    end
  end
end

function data_util.remove_result_sub(recipe, name)
  for i = #recipe.results, 1, -1 do
    if recipe.results[i] then
      for _, value in pairs(recipe.results[i]) do
        if value == name then
          table.remove(recipe.results, i)
        end
      end
    end
  end
end


function data_util.has_ingredient(recipe, name)
  if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
  if not recipe then return false end
  if recipe.ingredients then
    if data_util.has_ingredient_sub(recipe, name) then return true end
  end
  return false
end

function data_util.has_ingredient_sub(recipe, name)
  for i = #recipe.ingredients, 1, -1 do
    if recipe.ingredients[i] then
      for _, value in pairs(recipe.ingredients[i]) do
        if value == name then
          return true
        end
      end
    end
  end
  return false
end

function data_util.add_ingredient_sub(recipe, name, amount, is_fluid)
  local found = false
  for i = #recipe.ingredients, 1, -1 do
    if recipe.ingredients[i] then
      for _, value in pairs(recipe.ingredients[i]) do
        if value == name then
          found = true
          recipe.ingredients[i] = {type=is_fluid and "fluid" or "item", name=name, amount=amount}
          break
        end
      end
    end
  end
  if not found then
    table.insert(recipe.ingredients, {type=is_fluid and "fluid" or "item", name=name, amount=amount})
  end
end

function data_util.add_result_sub(recipe, name, amount, is_fluid, amount_min, amount_max, probability)
  local found = false
  for i = #recipe.results, 1, -1 do
    if recipe.results[i] then
      for _, value in pairs(recipe.results[i]) do
        if value == name then
          found = true
          if amount then
            recipe.results[i] = {type=is_fluid and "fluid" or "item", name=name, amount=amount}
          else
            recipe.results[i] = {type=is_fluid and "fluid" or "item", name=name, amount_min=amount_min, amount_max=amount_max, probability=probability}
          end
          break
        end
      end
    end
  end
  if not found then
    if amount then
      table.insert(recipe.results, {type=is_fluid and "fluid" or "item", name=name, amount=amount})
    else
      table.insert(recipe.results, {type=is_fluid and "fluid" or "item", name=name, amount_min=amount_min, amount_max=amount_max, probability=probability})
    end
  end
end

function data_util.replace_or_add_ingredient_sub(recipe, old, new, amount, is_fluid)
  -- old can be nil to just add
  if old then
      data_util.remove_ingredient_sub(recipe, old)
  end
  data_util.add_ingredient_sub(recipe, new, amount, is_fluid)
end

function data_util.replace_or_add_result_sub(recipe, old, new, amount, is_fluid, amount_min, amount_max, probability)
  -- old can be nil to just add
  if old then
    data_util.remove_result_sub(recipe, old)
  end
  data_util.add_result_sub(recipe, new, amount, is_fluid, amount_min, amount_max, probability)
end

function data_util.remove_ingredient(recipe, name)
  if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
  if not recipe then return end
  if recipe.ingredients then
    data_util.remove_ingredient_sub(recipe, name)
  end
end

function data_util.replace_or_add_ingredient(recipe, old, new, amount, is_fluid)
  if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
  if not recipe then return end
  if recipe.ingredients then
    data_util.replace_or_add_ingredient_sub(recipe, old, new, amount, is_fluid)
  end
end

function data_util.replace_or_add_result(recipe, old, new, amount, is_fluid, amount_min, amount_max, probability)
  if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
  if not recipe then return end
  if recipe.results then
    data_util.replace_or_add_result_sub(recipe, old, new, amount, is_fluid, amount_min, amount_max, probability)
  end
end

function data_util.set_craft_time(recipe, energy_required)
  if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
  if not recipe then return end
  if recipe.energy_required then
    recipe.energy_required = energy_required
  end
end

function data_util.recipe_require_tech(recipe_name, tech_name)
  if data.raw.recipe[recipe_name] and data.raw.technology[tech_name] then
    data_util.disable_recipe(recipe_name)
    for _, tech in pairs(data.raw.technology) do
        if tech.effects then
            data_util.remove_recipe_from_effects(tech.effects, recipe_name)
        end
    end
    local already = false
    data.raw.technology[tech_name].effects = data.raw.technology[tech_name].effects or {}
    for _, effect in pairs(data.raw.technology[tech_name].effects) do
      if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
        already = true
        break
      end
    end
    if not already then
      table.insert(data.raw.technology[tech_name].effects, { type = "unlock-recipe", recipe = recipe_name})
    end
  end
end

function data_util.tech_split_at_level(tech_name, level)
  -- skip if it exists
  if data.raw.technology[tech_name.."-"..level] then return end
  local last_tech = data.raw.technology[tech_name]
  for i = 1, level - 1 do
    if data.raw.technology[tech_name.."-"..i] then
      last_tech = data.raw.technology[tech_name.."-"..i]
    end
  end
  if last_tech then
    local new_tech = table.deepcopy(last_tech)
    last_tech.max_level = level - 1
    new_tech.name = tech_name.."-"..level
    new_tech.prerequisites = {last_tech.name}
    data:extend({new_tech})
    -- make the chain linear
    local last_level = new_tech.max_level or level
    if last_level ~= "infinite" then
      local next_level = last_level + 1
      if data.raw.technology[tech_name.."-"..next_level] then
        local next_tech = data.raw.technology[tech_name.."-"..next_level]
        for i, prereq in pairs(next_tech.prerequisites) do
          if prereq == last_tech.name then
            debug_log("Changing tech "..next_tech.name .." prerequisite from " .. last_tech.name.." to "..new_tech.name)
            next_tech.prerequisites[i] = new_tech.name
          end
        end
      end
    end
    return new_tech
  end
end

function data_util.tech_split_at_levels(tech_name, levels)
  local techs = {}
  for _, level in pairs(levels) do
    local tech = data_util.tech_split_at_level(tech_name, level)
    if tech then table.insert(techs, tech) end
  end
  return techs
end


function data_util.tech_split_levels(tech_name, max_split_level)
  if not max_split_level then max_split_level = 9 end
  local max_level = 1
  local prev_tech_template
  local prev_tech_name
  local techs = {}
  local last_i = 0
  for i = 1, max_split_level do
    -- prep prerequisites
    local prerequisites = {}
    local tech_template

    -- load best template
    if data.raw.technology[tech_name.."-"..i] then
      tech_template = data.raw.technology[tech_name.."-"..i]
      if tech_template.prerequisites then
        prerequisites = tech_template.prerequisites
      end
      tech_template.prerequisites = nil
    end
    if not tech_template then
      if prev_tech_template and (max_level == "infinite" or i <= max_level) then
        tech_template = prev_tech_template
      end
    end

    if not tech_template then return end
    prev_tech_template = tech_template
    last_i = i

    -- link the chain
    if prev_tech_name and not data_util.table_contains(prerequisites, prev_tech_name)then
      table.insert(prerequisites, prev_tech_name)
    end

    -- establish maximum
    if max_level ~= "infinite" then
      if tech_template.max_level then
        if tech_template.max_level == "infinite" then
          max_level = "infinite"
        elseif tech_template.max_level > max_level then
          max_level = tech_template.max_level
        end
      end
    end

    local new_tech = table.deepcopy(tech_template)
    new_tech.name = tech_name.."-"..i
    new_tech.prerequisites = prerequisites
    new_tech.max_level = nil
    data:extend({new_tech})

    prev_tech_name = new_tech.name
    table.insert(techs, new_tech)
  end
  if max_level == "infinite" then
    data.raw.technology[tech_name.."-"..last_i].max_level = max_level
  else
    data.raw.technology[tech_name.."-"..last_i].max_level = math.max(last_i, max_level)
  end
  return techs
end

function data_util.tech_lock_recipes(tech_name, recipe_names)
  if not data.raw.technology[tech_name] then return end
  if type(recipe_names) == "string" then recipe_names = {recipe_names} end
  for _, recipe_name in pairs(recipe_names) do
    if data.raw.recipe[recipe_name] then
      data_util.recipe_require_tech(recipe_name, tech_name)
    end
  end
end

function data_util.tech_find_parent_names_cascade(names, prototype_name, cascade)
  if not (data.raw.technology[prototype_name] and data.raw.technology[prototype_name].prerequisites) then return end
  if data.raw.technology[prototype_name].prerequisites then
    for _, prerequisite in pairs(data.raw.technology[prototype_name].prerequisites) do
      if not names[prerequisite] then
        names[prerequisite] = prerequisite
        if cascade then
          data_util.tech_find_parent_names_cascade(names, prerequisite, cascade)
        end
      end
    end
  end
  return names
end

function data_util.tech_find_parent_names(prototype_name, cascade)
  return data_util.tech_find_parent_names_cascade({}, prototype_name, cascade)
end

function data_util.tech_find_child_names(prototype_name)
  local names = {}
  for _, tech in pairs(data.raw.technology) do
    if tech.prerequisites then
      for _, prerequisite in pairs(tech.prerequisites) do
        if prerequisite == prototype_name then
          table.insert(names, tech.name)
        end
      end
    end
  end
  return names
end

function data_util.tech_add_prerequisites(prototype_name, prerequisites, warn_on_missing)
  local prototype = data.raw.technology[prototype_name]
  if not prototype then return end
  for _, new_prerequisite in pairs(prerequisites) do
    local found = false
    if prototype.prerequisites then
      for _, old_prerequisite in pairs(prototype.prerequisites) do
        if old_prerequisite == new_prerequisite then
          found = true break
        end
      end
    end
    if not found then
      prototype.prerequisites = prototype.prerequisites or {}
      if warn_on_missing and not data.raw.technology[new_prerequisite] then
        log("TECH PREREQUISITE WARNING trying to add " .. new_prerequisite .. " but it does not exist as a technology")
      else
        table.insert(prototype.prerequisites, new_prerequisite)
      end
    end
  end
end

function data_util.tech_remove_prerequisite_recursive(prototype_name, prerequisites)
  if not data.raw.technology[prototype_name] then return end
  local names = data_util.tech_find_parent_names(prototype_name, true)
  table.insert(names, prototype_name)

  for _, name in pairs(names) do
    local prototype = data.raw.technology[name]
    if prototype and prototype.prerequisites then --FIXME? should this be made to work with trigger techs?
      for _, prereq in pairs(prerequisites) do
        if data_util.table_contains(prototype.prerequisites, prereq) then
          data_util.tech_remove_prerequisites(name, {prereq})
        end
      end
    end
  end
end

function data_util.tech_remove_prerequisites(prototype_name, prerequisites)
  local prototype = data.raw.technology[prototype_name]
  if not prototype then return end
  for _, new_prerequisite in pairs(prerequisites) do
    if prototype.prerequisites then
      for i = #prototype.prerequisites, 1, -1 do
        if prototype.prerequisites[i] == new_prerequisite then
          table.remove(prototype.prerequisites, i)
        end
      end
    end
  end
end

function data_util.tech_has_ingredient(prototype_name, pack)
  local prototype = data.raw.technology[prototype_name]
  if prototype and prototype.unit then --FIXME? should this be made to work with trigger techs?
    for _, ingredient in pairs(prototype.unit.ingredients) do
      if ingredient[1] == pack or ingredient.name == pack then
        return true
      end
    end
  end
  return false
end

function data_util.tech_remove_ingredients_recursive(prototype_name, packs)
  if not data.raw.technology[prototype_name] then return end
  local names = data_util.tech_find_parent_names(prototype_name, true)
  table.insert(names, prototype_name)

  for _, name in pairs(names) do
    local prototype = data.raw.technology[name]
    if prototype and prototype.unit then --FIXME? should this be made to work with trigger techs?
      for _, pack in pairs(packs) do
        for i = #prototype.unit.ingredients, 1, -1 do
          if prototype.unit.ingredients[i] and
          (prototype.unit.ingredients[i][1]     and prototype.unit.ingredients[i][1] == pack
          or prototype.unit.ingredients[i].name and prototype.unit.ingredients[i].name == pack) then -- added handling for full format
            table.remove(prototype.unit.ingredients, i)
          end
        end
      end
    end
  end
end

function data_util.tech_remove_ingredients(prototype_name, packs)
  local prototype = data.raw.technology[prototype_name]
  if prototype and prototype.unit then --FIXME? should this be made to work with trigger techs?
    for _, pack in pairs(packs) do
      for i = #prototype.unit.ingredients, 1, -1 do
        if prototype.unit.ingredients[i] and
          (prototype.unit.ingredients[i][1]     and prototype.unit.ingredients[i][1] == pack
          or prototype.unit.ingredients[i].name and prototype.unit.ingredients[i].name == pack) then -- added handling for full format
          table.remove(prototype.unit.ingredients, i)
        end
      end
    end
  end
end

function data_util.tech_remove_effects(prototype_name, effects)
  --log("tech_remove_effects")
  local prototype = data.raw.technology[prototype_name]
  if not data.raw.technology[prototype_name] then return end
  for _, new_effect in pairs(effects) do
    --log("new effect: " .. new_effect.type .. " " .. new_effect.recipe)
    for _, old_effect in pairs(prototype.effects) do
      --log("old effect: " .. old_effect.type .. " " .. old_effect.recipe)
      local match = true
      for new_key, new_var in pairs(new_effect) do
        if old_effect[new_key] ~= new_var then
          --log("compare fails")
          match = false break
        end
      end
      if match then
      --  log("compare pass")
        table.remove(prototype.effects, _)
      end
    end
  end
end

-- cascade applies to children too
function data_util.tech_add_ingredients(prototype_name, ingredients, cascade, allow_multiple_specialist, allow_multiple_deep)
  --Log.debug_log("tech_add_ingredients: " .. prototype_name .. ", added " .. serpent.line(ingredients))
  local prototype = data.raw.technology[prototype_name]
  if not prototype then return end
  if not prototype.unit then return end --FIXME? should this be made to work with trigger techs?
  local added = false
  for _, new_ingredient in pairs(ingredients) do
    local found = false
    local specialist_pack = nil
    if string.find(new_ingredient, data_util.mod_prefix .. "astronomic-science-pack", 1, true) then
      specialist_pack = data_util.mod_prefix .. "astronomic-science-pack"
    elseif string.find(new_ingredient, data_util.mod_prefix .. "energy-science-pack", 1, true) then
      specialist_pack = data_util.mod_prefix .. "energy-science-pack"
    elseif string.find(new_ingredient, data_util.mod_prefix .. "material-science-pack", 1, true) then
      specialist_pack = data_util.mod_prefix .. "material-science-pack"
    elseif string.find(new_ingredient, data_util.mod_prefix .. "biological-science-pack", 1, true) then
      specialist_pack = data_util.mod_prefix .. "biological-science-pack"
    end
    local deep_pack = nil
    if string.find(new_ingredient, data_util.mod_prefix .. "deep-space-science-pack", 1, true) then
      deep_pack = data_util.mod_prefix .. "deep-space-science-pack"
    end
    if specialist_pack and not allow_multiple_specialist then
      for _, old_ingredient in pairs(prototype.unit.ingredients) do
        if string.find(old_ingredient[1] or old_ingredient.name, specialist_pack, 1, true) then -- added hanldling for full format
          old_ingredient[1] = new_ingredient
          found = true break
        end
      end
    else
      if deep_pack and not allow_multiple_deep then
        for _, old_ingredient in pairs(prototype.unit.ingredients) do
          if string.find(old_ingredient[1] or old_ingredient.name, deep_pack, 1, true) then -- added hanldling for full format
            old_ingredient[1] = new_ingredient
            found = true break
          end
        end
      else
        for _, old_ingredient in pairs(prototype.unit.ingredients) do
          if old_ingredient[1] and  old_ingredient[1] == new_ingredient or old_ingredient.name and old_ingredient.name == new_ingredient then -- added hanldling for full format
            found = true break
          end
        end
      end
    end
    if not found then
      table.insert(prototype.unit.ingredients, {new_ingredient, 1})
      added = true
    end
  end
  if added and cascade then
    local child_techs = data_util.tech_find_child_names(prototype_name)
    for _, tech in pairs(child_techs) do
      data_util.tech_add_ingredients(tech, ingredients, cascade)
    end
  end
end

function data_util.tech_has_prerequisite(prototype_name, prerequisite)
  local prototype = data.raw.technology[prototype_name]
  if not prototype then return end
  for _, prototype_prerequisite in pairs(prototype.prerequisites) do
    if prerequisite == prototype_prerequisite then return true end
  end
  return false
end

-- cascade applies to children too
function data_util.tech_add_ingredients_with_prerequisites(prototype_name, ingredients)
  -- assumes that ingredient and tech are same name
  --log("tech_add_ingredients: " .. prototype_name)
  local prototype = data.raw.technology[prototype_name]
  if not prototype then return end
  for _, ingredient in pairs(ingredients) do
    if not data_util.tech_has_ingredient(prototype_name, ingredient) then
      data_util.tech_add_ingredients(prototype_name, {ingredient}, true)
    end
    if not data_util.tech_has_prerequisite(prototype_name, ingredient) then
      data_util.tech_add_prerequisites(prototype_name, {ingredient})
    end
  end
end

function data_util.delete_recipe(recipe_name)
  for _, tech in pairs(data.raw.technology) do
    if tech.effects then
      for i, effect in pairs(tech.effects) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
          table.remove(tech.effects, i)
        end
      end
    end
  end
  data.raw.recipe[recipe_name] = nil
end

function data_util.create_dummy_migration_recipe(recipe_name)
  local original_recipe = data.raw.recipe[recipe_name]
  local dummy_recipe = {
    type = "recipe",
    name = Shared.dummy_migration_recipe_prefix .. recipe_name,
    category = original_recipe.category,
    icon = "__core__/graphics/icons/alerts/warning-icon.png",
    icon_size = 64,
    energy_required = 1,
    enabled = false,
    hide_from_player_crafting = true,
    hidden = true,
    ingredients = {}, -- Ingredients here might show in the result of set_recipe. Factorio bug?
    results = {},
    subgroup = "other",
    order = "zzzzzzzzzzzzzzzzzzz",
  }
  data:extend({dummy_recipe})
end

function data_util.disallow_efficiency(recipe_name)
  if data.raw.recipe[recipe_name] then
    for _, prototype in pairs(data.raw["module"]) do
      if string.find(prototype.name, "efficiency", 1, true) then
        if not prototype.limitation_blacklist then
          prototype.limitation_blacklist = {}
        end
        if not prototype.limitation_message_key then
          prototype.limitation_message_key = "efficiency-module-not-allowed"
        end
        table.insert(prototype.limitation_blacklist, recipe_name)  -- Use blacklist here because we want efficiency to be allowed by default
      end
    end
  end
end

function data_util.replace_filenames_recursive(subject, what, with)
  if not subject then return end
  if subject.filename then
    subject.filename = data_util.replace(subject.filename, what, with)
  end
  for _, sub in pairs(subject) do
    if (type(sub) == "table") then
      data_util.replace_filenames_recursive(sub, what, with)
    end
  end
end

function data_util.tint_recursive(subject, tint)
  if not subject then return end
  if subject.filename then
    subject.tint = tint
  end
  for _, sub in pairs(subject) do
    if (type(sub) == "table") then
      data_util.tint_recursive(sub, tint)
    end
  end
end

function data_util.blend_mode_recursive(subject, blend_mode)
  if not subject then return end
  if subject.filename then
    subject.blend_mode = blend_mode
  end
  for _, sub in pairs(subject) do
    if (type(sub) == "table") then
      data_util.blend_mode_recursive(sub, blend_mode)
    end
  end
end

function data_util.shift_recursive(subject, shift)
  if not subject then return end
  if subject.filename then
    subject.shift = shift
  end
  for _, sub in pairs(subject) do
    if (type(sub) == "table") then
      data_util.shift_recursive(sub, shift)
    end
  end
end

function data_util.replace_sr_with_half_hr(subject)
  if not subject then return end
  if subject.hr_version then
    subject.width = math.floor(subject.hr_version.width/2)
    subject.height = math.floor(subject.hr_version.height/2)
    if subject.hr_version.x then subject.x = math.floor(subject.hr_version.x/2) end
    if subject.hr_version.y then subject.y = math.floor(subject.hr_version.y/2) end
  end
  for _, sub in pairs(subject) do
    if (type(sub) == "table") then
      data_util.replace_sr_with_half_hr(sub)
    end
  end
end

function data_util.shift_sprite(sprite, shift)
 local shifted_sprite = table.deepcopy(sprite)
 shifted_sprite.shift = shift
 return shifted_sprite
end

function data_util.make_recipe(proto)
  --name is prefixed with data_util.mod_prefix
  --energy required deafults to 10
  local name = proto.name
  if proto.is_data then name = name .. "-data" end
  local def = {
    type = "recipe",
    name = name,
    category = proto.category or nil,
    enabled = proto.enabled == true,
    energy_required = proto.energy_required or 10,
    ingredients = proto.ingredients,
    results = proto.results or { {type = "item", name = name, amount = 1 } },
    icon = proto.icon or nil,
    icons = proto.icons or nil,
    icon_size = proto.icon_size or 64,
    crafting_machine_tint = proto.crafting_machine_tint or nil,
    main_product = proto.main_product or nil,
    allow_as_intermediate = proto.allow_as_intermediate,
    subgroup = proto.subgroup or nil,
    order = proto.order or nil,
    localised_name = proto.localised_name,
    localised_description = proto.localised_description,
    always_show_products = true,
    always_show_made_in = true,
    show_amount_in_title = proto.show_amount_in_title,
    hide_from_signal_gui = proto.hide_from_signal_gui,
    allow_productivity = proto.allow_productivity,
    allow_quality = proto.allow_quality,
    auto_recycle = proto.auto_recycle,
  }

  if (not def.main_product) and #def.results == 1 then
    local p_name = def.results[1].name or def.results[1][1]
    local p_type = def.results[1].type or "item"
    local prod = data.raw[p_type][p_name]
    if p_type == "item" and not prod then
      p_type = "capsule"
      prod = data.raw[p_type][p_name]
    end
    if prod then
      def.main_product = prod.name
    end
  end
  if not (def.icon or def.icons) then
    local p_name = def.results[1].name or def.results[1][1]
    local p_type = def.results[1].type or "item"
    local prod = data.raw[p_type][p_name]
    if p_type == "item" and not prod then
      p_type = "capsule"
      prod = data.raw[p_type][p_name]
    end
    if prod then
      --log("recipe " .. name .. " icon " .. p_type .. "." .. p_name)
      if prod.icon then
        def.icon = prod.icon
        def.icon_size = prod.icon_size
      elseif prod.icons then
        def.icons = prod.icons
      else
        --log("recipe " .. name .. " error: items has no icon(s)")
      end
    elseif p_type and p_name then
      --log("recipe " .. name .. " can't find: " .. p_type .. "." .. p_name)
    else
      --log("recipe " .. name .. " error")
    end
  end
  data:extend({def})
end


function data_util.icon_stack_shift(original_shift, scale, offset)
  local shift = original_shift and table.deepcopy(original_shift) or {0,0}
  shift[1] = shift[1] * scale
  shift[2] = shift[2] * scale
  if offset then
    shift[1] = shift[1]  + offset[1] * 32
    shift[2] = shift[2]  + offset[2] * 32
  end
  return shift
end

function data_util.multiply_tables(a, b)
  if a and b then
    local keys = {}
    for k,v in pairs(a) do
      keys[k]=k
    end
    for k,v in pairs(b) do
      keys[k]=k
    end
    local mult = {}
    for k, v in pairs(keys) do
      mult[k] = (a[k] or 1) * (b[k] or 1)
    end
    return mult
  end
  return a or b
end

function data_util.technology_icon_xx(xx, technology_icon, icon_size)
  local scale = icon_size / 256
  local icons =
  {
    {
      icon = technology_icon,
      icon_size = icon_size,
      scale = scale * 2,
    },
    {
      icon = "__core__/graphics/icons/technology/constants/" .. xx .. ".png",
      icon_size = 128,
      scale = scale,
      shift = {100 * scale, 100 * scale},
      floating = true,
    }
  }
  return icons
end

function data_util.technology_icon_constant_equipment(technology_icon, icon_size)
  return data_util.technology_icon_xx("constant-equipment", technology_icon, icon_size)
end

function data_util.technology_icon_constant_damage(technology_icon, icon_size)
  return data_util.technology_icon_xx("constant-damage", technology_icon, icon_size)
end

function data_util.technology_icon_constant_speed(technology_icon, icon_size)
  return data_util.technology_icon_xx("constant-speed", technology_icon, icon_size)
end

function data_util.technology_icon_constant_movement_speed(technology_icon, icon_size)
  return data_util.technology_icon_xx("constant-movement-speed", technology_icon, icon_size)
end

function data_util.technology_icon_constant_range(technology_icon, icon_size)
  return data_util.technology_icon_xx("constant-range", technology_icon, icon_size)
end

function data_util.technology_icon_constant_count(technology_icon, icon_size)
  return data_util.technology_icon_xx("constant-count", technology_icon, icon_size)
end

function data_util.technology_icon_constant_capacity(technology_icon, icon_size)
  return data_util.technology_icon_xx("constant-capacity", technology_icon, icon_size)
end

function data_util.technology_icon_constant_productivity(technology_icon, icon_size)
  return data_util.technology_icon_xx("constant-mining-productivity", technology_icon, icon_size)
end

function data_util.add_icons_to_stack(existing_stack, icons_properties)
  local stack = existing_stack or {{ icon = "__space-exploration-graphics__/graphics/blank.png", scale = 1, icon_size = 32 }}
  for _, icon_properties in pairs(icons_properties) do
    if icon_properties.icon then
      data_util.add_icon_to_stack(stack, icon_properties.icon, icon_properties.properties)
    end
  end
  return stack
end

function data_util.add_icon_to_stack(existing_stack, icon_or_prototype, properties)

  -- properties.scale, properties.offset (0-1), tint?
  -- assume base layer is 32, as this is forced in all use cases
  local stack = existing_stack or {{ icon = "__space-exploration-graphics__/graphics/blank.png", scale = 1, icon_size = 32 }}

  local scale = properties and properties.scale or 1
  local offset = properties and properties.offset -- note, this is in a 0-1 scale, not pixels, ends up being multiplied by 32
  local tint = properties and properties.tint
  local draw_background = properties and properties.draw_background or false
  local default_size = icon_or_prototype.icon_size or 64 -- this can still set the icon_size for icons not just icon
  local icons = {}

  if icon_or_prototype.icons then
    icons = icon_or_prototype.icons
  elseif icon_or_prototype.icon then
    table.insert(icons, {
      icon = icon_or_prototype.icon,
      icon_size = icon_or_prototype.icon_size or 64,
    })
  elseif icon_or_prototype[1] and icon_or_prototype[1].icon then
    -- format was {{icon = ...}}
    icons = icon_or_prototype
  end

  for _, icon in pairs(icons) do
    if icon.icon then
      local icon_size = icon.icon_size or default_size
      table.insert(stack, {
        icon=icon.icon,
        icon_size=icon_size,
        scale=(icon.scale or 1) * scale * 32 / icon_size,
        shift= data_util.icon_stack_shift(icon.shift, scale, offset),
        tint= data_util.multiply_tables(icon.tint, tint),
        draw_background = draw_background,
      })
    end
  end
  return stack
end

function data_util.transition_icons(icon_from, icon_to)
  if icon_to.icon then -- single 'to' icon format
    return {
      { icon = "__space-exploration-graphics__/graphics/blank.png", scale = 0.5, shift = {0, 0}, icon_size = 64 }, -- to lock scale
      { icon = icon_from.icon, scale = 0.33 * 64 / (icon_from.icon_size or 64), shift = {8, -8}, icon_size = (icon_from.icon_size or 64), draw_background = (icon_from.draw_background or true) },
      { icon = icon_to.icon, scale = 0.33 * 64 / (icon_to.icon_size or 64), shift = {-8, 8}, icon_size = (icon_to.icon_size or 64), draw_background = (icon_from.draw_background or true) },
      { icon = "__space-exploration-graphics__/graphics/icons/transition-arrow.png", scale = 0.5, shift = {0, 0}, icon_size = 64 }, -- to overlay
    }
  else -- multiple 'to' icons
    local icons = {
      { icon = "__space-exploration-graphics__/graphics/blank.png", scale = 0.5, shift = {0, 0}, icon_size = 64 }, -- to lock scale
      { icon = icon_from.icon, scale = 0.33 * 64 / (icon_from.icon_size or 64), shift = {8, -8}, icon_size = (icon_from.icon_size or 64), draw_background = (icon_from.draw_background or true) },
    }
    for _, icon_and_size in pairs(icon_to) do
      table.insert(icons, { icon = icon_and_size.icon, scale = 0.25 * 64 / (icon_and_size.icon_size or 64), shift = {-12 + (_-1) * 8, 12}, icon_size = (icon_and_size.icon_size or 64), draw_background = (icon_and_size.draw_background or true) })
    end
    table.insert(icons, { icon = "__space-exploration-graphics__/graphics/icons/transition-arrow.png", scale = 0.5, shift = {0, 0}, icon_size = 64 })
    return icons
  end
end

-- Puts sub-icon in the top-left of the main icon
-- If multiple sub-icons, they will all overlap if not given a new shift value
function data_util.sub_icons(icon_main, ...)
  local icons_sub = {...}
  local results = {{ icon = icon_main, shift = {2, 0}, icon_size = 64 }}
  for _, icon in pairs(icons_sub) do
    table.insert(results, { icon = icon.icon or icon,
                            scale = icon.scale or 0.25,
                            shift = icon.shift or {-7, -7},
                            icon_size = icon.icon_size or 64,
                            draw_background = icon.draw_background or true,
                          })
  end
  return results
end

-- Puts add-icon in the bottom-right of the main icon
-- If multiple add-icons, they will all overlap if not given a new shift value
function data_util.add_icons(icon_or_icons, ...)
  local icons_sub = {...}
  local results
  if type(icon_or_icons) == "string" then
    results = {{ icon = icon_or_icons, shift = {-2, 0}, icon_size = 64 }}
  elseif type(icon_or_icons) == "table" then
    results = table.deepcopy(icon_or_icons)
  end
  for _, icon in pairs(icons_sub) do
    table.insert(results, { icon = icon.icon or icon,
                            scale = icon.scale or 0.25,
                            shift = icon.shift or {7, 7},
                            icon_size = icon.icon_size or 64,
                            draw_background = icon.draw_background or true,
                          })
  end
  return results
end

-- adds a new custom tooltip field to this prototype,
-- supports a "key" parameter that can override an existing one with the same key.
function data_util.add_custom_tooltip_field(prototype, custom_tooltip_field)
  prototype.custom_tooltip_fields = prototype.custom_tooltip_fields or {}

  for i, tooltip in ipairs(prototype.custom_tooltip_fields) do
    if tooltip.key and tooltip.key == custom_tooltip_field.key then
      prototype.custom_tooltip_fields[i] = custom_tooltip_field
      return
    end
  end

  table.insert(prototype.custom_tooltip_fields, custom_tooltip_field)
end

function data_util.collision_description_sub(prototype, collision_mask)
  local disallowed = {}
  --if collision_mask.layers["water_tile"] then
  --  table.insert(disallowed, {"space-exploration.collision_mask_water"})
  --end
  if not collision_mask then return end
  if collision_mask.layers["ground_tile"] then
    table.insert(disallowed, {"space-exploration.collision_mask_land"})
  end
  if collision_mask.layers[space_collision_layer] then
    table.insert(disallowed, {"space-exploration.collision_mask_space_platform"})
  end
  if collision_mask.layers[spaceship_collision_layer] or collision_mask.layers[space_collision_layer] then
    table.insert(disallowed, {"space-exploration.collision_mask_spaceship"})
  end
  if next(disallowed) then
    local disallowed_locale = nil
    for _, disallow in pairs(disallowed) do
      if disallowed_locale == nil then
        disallowed_locale = disallow
      else
        disallowed_locale = {"space-exploration.comma_separate", disallowed_locale, disallow}
      end
    end
    data_util.add_custom_tooltip_field(prototype, {
      key = "cannot-be-placed-on",
      name = "", -- the colon cannot be styled bold like the rest so we hide it
      value = {"space-exploration.cannot_be_placed_on_line", disallowed_locale},
      order = 0,
    })
  end
end

function data_util.collision_description(prototype)
  if not prototype.collision_mask then return end
  data_util.collision_description_sub(prototype, prototype.collision_mask)
end

function data_util.add_placement_restriction_tooltip(prototype, where)
  data_util.add_custom_tooltip_field(prototype, {
    key = "placement-restriction",
    name = "", -- the colon cannot be styled bold like the rest so we hide it
    value = {"space-exploration.placement_restriction_line", where},
    order = 0, -- ideally 1, but it appears that puts it under the led with the entity status which is undesirable
  })
end

function data_util.auto_box(x, y, inset, shift, top_extension)
  inset = inset or 0
  shift = shift or {0,0}
  top_extension = top_extension or 0
  return {{-x/2+inset+shift[1], -y/2+inset+shift[2]-top_extension},{x/2-inset+shift[1], y/2-inset+shift[2]}}
end

function data_util.resistances_max(resistances, add_resistances)
  local r = table.deepcopy(resistances or {})
  for _, add_resistance in pairs(add_resistances) do
    local found = false
    for _, resistance in pairs(r) do
      if resistance.type == add_resistance.type then
        found = true
        resistance.percent = math.max(resistance.percent or 0, add_resistances.percent or 0)
        resistance.amount = math.max(resistance.amount or 0, add_resistances.amount or 0)
      end
    end
    if not found then
      table.insert(r, {type = add_resistance.type, amount = add_resistance.amount, percent = add_resistance.percent})
    end
  end
  return r
end

function data_util.extend_style(base_name, new_name, styles)
  local base_style = data.raw["gui-style"]["default"][base_name]
  local prototype = {type = base_style.type, parent = base_name}
  data_util.apply_styles(prototype, styles)
  data.raw["gui-style"]["default"][new_name] = prototype
  return prototype
end

function data_util.apply_styles(prototype, styles)
  for k, v in pairs(styles) do
    prototype[k] = v
  end
  return prototype
end

function data_util.set_transparency(color, alpha)
  color.a = alpha
  return color
end

function data_util.all_effects()
  return {"consumption", "speed", "productivity", "pollution", "quality"}
end

function data_util.all_effects_except(...)
  local all_effects = {"consumption", "speed", "productivity", "pollution", "quality"}
  local except = util.list_to_map({...}) -- there *must* be no nil in between the args

  local effects = {}
  for _, effect in ipairs(all_effects) do
    if not except[effect] then
      effects[#effects+1] = effect
    end
  end

  return effects
end

function data_util.find_item_prototype(item_name)
  for type_name in pairs(defines.prototypes.item) do
    local prototype = data.raw[type_name][item_name]
    if prototype then return prototype end
  end
end

return data_util
