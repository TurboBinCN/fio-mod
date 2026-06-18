local data_util = require("data_util")

local belt_span = 5
local deep_belt_span = 16
local deep_speed = settings.startup[data_util.mod_prefix .. "deep-space-belt-speed-2"].value * (1+1/3)/10 / 64 -- 0.133333333
local default_variant = "black"
local deep_space_variants = {
  ["black"]   = {r=0,g=0,b=0},
  ["white"]   = {r=1,g=1,b=1},
  ["red"]     = {r=1,g=0,b=0},
  ["magenta"] = {r=1,g=0,b=1},
  ["blue"]    = {r=0,g=0,b=1},
  ["cyan"]    = {r=0,g=1,b=1},
  ["green"]   = {r=0,g=1,b=0},
  ["yellow"]  = {r=1,g=1,b=0},
}

local collision_floor = {
  layers = {
    --item = true, -- stops player from dropping items on belts.
    floor = true,
    object = true,
    water_tile = true,
    transport_belt = true,
  },
}
local collision_floor_platform = {
  layers = {
    --item = true, -- stops player from dropping items on belts.
    floor = true,
    object= true,
    water_tile = true,
    transport_belt = true,
  },
}

data:extend({
  {
    icon = "__space-exploration-graphics__/graphics/icons/transport-belt.png",
    icon_size = 64,
    name = data_util.mod_prefix .. "space-transport-belt",
    order = "x[space-transport-belt]",
    place_result = data_util.mod_prefix .. "space-transport-belt",
    stack_size = 100,
    subgroup = "transport-belt",
    type = "item"
  },
  {
    icon = "__space-exploration-graphics__/graphics/icons/underground-belt.png",
    icon_size = 64,
    name = data_util.mod_prefix .. "space-underground-belt",
    order = "x[space-underground-belt]-u[underground]",
    place_result = data_util.mod_prefix .. "space-underground-belt",
    stack_size = 50,
    subgroup = "underground-belt",
    type = "item"
  },
  {
    icon = "__space-exploration-graphics__/graphics/icons/splitter.png",
    icon_size = 64,
    name = data_util.mod_prefix .. "space-splitter",
    order = "x[space-splitter]-s[splitter]",
    place_result = data_util.mod_prefix .. "space-splitter",
    stack_size = 50,
    subgroup = "splitter",
    type = "item"
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-transport-belt",
    category = "space-crafting",
    ingredients = {
      {type = "fluid", name = "lubricant", amount = 10},
      {type = "item", name = "steel-plate", amount = 2 },
      {type = "item", name = "low-density-structure", amount = 1 },
      {type = "item", name = "iron-gear-wheel", amount = 12 },
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "space-transport-belt", amount = 2},
    },
    energy_required = 10,
    enabled = false,
    always_show_made_in = true,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-underground-belt",
    category = "space-crafting",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 8},
      {type = "item", name = data_util.mod_prefix .. "space-transport-belt", amount = 8},
      {type = "fluid", name = "lubricant", amount = 40}
    },
    energy_required = 10,
    results = {
      {type = "item", name = data_util.mod_prefix .. "space-underground-belt", amount = 1},
    },
    enabled = false,
    always_show_made_in = true,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-splitter",
    category = "space-crafting",
    ingredients = {
      {type = "item", name = "steel-plate", amount = 10 },
      {type = "item", name = "advanced-circuit", amount = 10 },
      {type = "item", name = data_util.mod_prefix .. "space-transport-belt", amount = 4 },
      {type = "fluid", name = "lubricant", amount = 40}
    },
    energy_required = 10,
    results = {
      {type = "item", name = data_util.mod_prefix .. "space-splitter", amount = 1},
    },
    enabled = false,
    always_show_made_in = true,
  },
})

-- Make express belt a bit cheaper than space belt. 10 -> 6 wheels, 20 -> 10 lubricant
data_util.replace_or_add_ingredient("express-transport-belt", "iron-gear-wheel", "iron-gear-wheel", 6)
if data_util.has_ingredient("express-transport-belt", "lubricant") then -- Some mods remove lubricant, if we add it back it causes an issue due to crafting category
  data_util.replace_or_add_ingredient("express-transport-belt", "lubricant", "lubricant", 10, true)
end

local belt = table.deepcopy(data.raw["transport-belt"]["express-transport-belt"])
belt.name = data_util.mod_prefix .. "space-transport-belt"
belt.minable.result = data_util.mod_prefix .. "space-transport-belt"
belt.icon = "__space-exploration-graphics__/graphics/icons/transport-belt.png"
belt.icon_size = 64
belt.fast_replaceable_group = "space-transport-belt"
belt.next_upgrade = nil
belt.related_underground_belt = data_util.mod_prefix .. "space-underground-belt"
local fields = {"animations", "belt_animation_set", "structure", "structure_patch", "belt_horizontal", "belt_vertical",
  "ending_bottom", "ending_patch", "ending_side", "ending_top",
  "starting_bottom", "starting_patch", "starting_side", "starting_top"}
for _, field in pairs(fields) do
  data_util.replace_filenames_recursive(belt[field],
    "__base__",
    "__space-exploration-graphics__")
  data_util.replace_filenames_recursive(belt[field],
    "express-",
    "space-")
end
belt.belt_animation_set.frozen_patch = data.raw["transport-belt"]["express-transport-belt"].belt_animation_set.frozen_patch
belt.belt_animation_set.belt_reader = data.raw["transport-belt"]["express-transport-belt"].belt_animation_set.belt_reader
belt.collision_mask = collision_floor

local splitter = table.deepcopy(data.raw["splitter"]["express-splitter"])
splitter.name = data_util.mod_prefix .. "space-splitter"
splitter.minable.result = data_util.mod_prefix .. "space-splitter"
splitter.icon = "__space-exploration-graphics__/graphics/icons/splitter.png"
splitter.icon_size = 64
splitter.fast_replaceable_group = "space-transport-belt"
splitter.next_upgrade = nil
for _, field in pairs(fields) do
  data_util.replace_filenames_recursive(splitter[field],
    "__base__",
    "__space-exploration-graphics__")
  data_util.replace_filenames_recursive(splitter[field],
    "express-",
    "space-")
end
splitter.belt_animation_set.frozen_patch = data.raw["splitter"]["express-splitter"].belt_animation_set.frozen_patch
splitter.belt_animation_set.belt_reader = data.raw["splitter"]["splitter"].belt_animation_set.belt_reader -- quez asks: why does this use the yellow tier one?
splitter.collision_mask = collision_floor

local ug_belt = table.deepcopy(data.raw["underground-belt"]["express-underground-belt"])
ug_belt.name = data_util.mod_prefix .. "space-underground-belt"
ug_belt.minable.result = data_util.mod_prefix .. "space-underground-belt"
ug_belt.icon = "__space-exploration-graphics__/graphics/icons/underground-belt.png"
ug_belt.icon_size = 64
ug_belt.fast_replaceable_group = "space-transport-belt"
ug_belt.next_upgrade = nil
ug_belt.factoriopedia_simulation = nil
for _, field in pairs(fields) do
  data_util.replace_filenames_recursive(ug_belt[field],
    "__base__",
    "__space-exploration-graphics__")
  data_util.replace_filenames_recursive(ug_belt[field],
    "express-",
    "space-")
end
ug_belt.belt_animation_set.frozen_patch = data.raw["underground-belt"]["express-underground-belt"].belt_animation_set.frozen_patch
ug_belt.belt_animation_set.belt_reader = data.raw["underground-belt"]["underground-belt"].belt_animation_set.belt_reader -- quez asks: why does this use the yellow tier one?
ug_belt.max_distance = belt_span + 1
ug_belt.collision_mask = collision_floor_platform
ug_belt.underground_collision_mask = settings.startup[data_util.mod_prefix.."use-underground-collision-masks"].value and {layers={[empty_space_collision_layer]=true}} or nil


-- NOTE: items and recipes are still elsewhere
data:extend({belt, splitter, ug_belt})

-- DEEP SPACE -----------------------------------------------------------------


local deep_tech = {
  type = "technology",
  name = data_util.mod_prefix.."deep-space-transport-belt",
  effects = {
    {type = "unlock-recipe", recipe = data_util.mod_prefix.."deep-space-transport-belt-"..default_variant},
    {type = "unlock-recipe", recipe = data_util.mod_prefix.."deep-space-splitter-"..default_variant},
    {type = "unlock-recipe", recipe = data_util.mod_prefix.."deep-space-underground-belt-"..default_variant},
  },
  icon = "__space-exploration-graphics__/graphics/technology/deep-space-transport-belt.png",
  icon_size = 128,
  order = "e-g",
  prerequisites = {
    data_util.mod_prefix.."deep-space-science-pack-2",
    data_util.mod_prefix.."heavy-assembly"
  },
  unit = {
   count = 500,
   time = 60,
   ingredients = {
     { "automation-science-pack", 1 },
     { "logistic-science-pack", 1 },
     { "chemical-science-pack", 1 },
     { data_util.mod_prefix .. "rocket-science-pack", 1 },
     { data_util.mod_prefix.."astronomic-science-pack-4", 1 },
     { data_util.mod_prefix.."energy-science-pack-4", 1 },
     { data_util.mod_prefix.."material-science-pack-4", 1 },
     { data_util.mod_prefix.."biological-science-pack-4", 1 },
     { data_util.mod_prefix.."deep-space-science-pack-2", 1 },
   }
  }
}
local deep_belt_recipe = {
  type = "recipe",
  name = data_util.mod_prefix.."deep-space-transport-belt-"..default_variant,
  ingredients = {
    {type = "item", name = data_util.mod_prefix.."space-transport-belt", amount = 10 },
    {type = "item", name = data_util.mod_prefix.."naquium-plate", amount = 2 },
    {type = "item", name = data_util.mod_prefix.."nanomaterial", amount = 2 },
    {type = "item", name = data_util.mod_prefix.."heavy-bearing", amount = 1 },
    {type = "item", name = data_util.mod_prefix.."superconductive-cable", amount = 1 },
    {type = "item", name = data_util.mod_prefix.."aeroframe-scaffold", amount = 1 },
    {type = "fluid", name = "lubricant", amount = 50 },
  },
  results = {
    {type = "item", name = data_util.mod_prefix.."deep-space-transport-belt-"..default_variant, amount = 20},
  },
  energy_required = 20,
  enabled = false,
  always_show_made_in = true,
  category = "space-manufacturing",
}
local deep_splitter_recipe = {
  type = "recipe",
  name = data_util.mod_prefix.."deep-space-splitter-"..default_variant,
  ingredients = {
    {type = "item", name = data_util.mod_prefix.."space-splitter", amount = 2 },
    {type = "item", name = data_util.mod_prefix.."deep-space-transport-belt-"..default_variant, amount = 4 },
    {type = "item", name = data_util.mod_prefix.."naquium-cube", amount = 1 },
    {type = "item", name = data_util.mod_prefix.."quantum-processor", amount = 1 },
    {type = "item", name = data_util.mod_prefix.."heavy-assembly", amount = 1 },
    {type = "item", name = data_util.mod_prefix.."superconductive-cable", amount = 1 },
    {type = "fluid", name = "lubricant", amount = 100 },
  },
  results = {
    {type = "item", name = data_util.mod_prefix.."deep-space-splitter-"..default_variant, amount = 10},
  },
  energy_required = 100,
  enabled = false,
  always_show_made_in = true,
  category = "space-manufacturing",
}
local deep_ug_recipe = {
  type = "recipe",
  name = data_util.mod_prefix.."deep-space-underground-belt-"..default_variant,
  ingredients = {
    {type = "item", name = data_util.mod_prefix.."space-underground-belt", amount = 4 },
    {type = "item", name = data_util.mod_prefix.."deep-space-transport-belt-"..default_variant, amount = 40 },
    {type = "item", name = data_util.mod_prefix.."naquium-cube", amount = 1 },
    {type = "item", name = data_util.mod_prefix.."heavy-composite", amount = 5 },
    {type = "item", name = data_util.mod_prefix.."aeroframe-scaffold", amount = 10 },
    {type = "item", name = data_util.mod_prefix.."superconductive-cable", amount = 1 },
    {type = "fluid", name = "lubricant", amount = 100 },
  },
  results = {
    {type = "item", name = data_util.mod_prefix.."deep-space-underground-belt-"..default_variant, amount = 4},
  },
  energy_required = 100,
  enabled = false,
  always_show_made_in = true,
  category = "space-manufacturing",
}
data:extend({
  deep_tech,
  deep_belt_recipe,
  deep_splitter_recipe,
  deep_ug_recipe,
})

local deep_space_belt_base = table.deepcopy(belt)
deep_space_belt_base.name = data_util.mod_prefix .. "deep-space-transport-belt"
deep_space_belt_base.order = "z"
deep_space_belt_base.belt_animation_set.animation_set.layers = {
  {
    filename = "__space-exploration-graphics__/graphics/entity/deep-space-transport-belt/deep-space-transport-belt.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5,
    frame_count = 32,
    direction_count = 20,
    flags = {"no-crop"}
  },
  {
    filename = "__space-exploration-graphics__/graphics/entity/deep-space-transport-belt/deep-space-transport-belt-glow.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5,
    frame_count = 32,
    direction_count = 20,
    flags = {"no-crop"},
    tint = {0, 0, 0},
    blend_mode = "additive"
  }
}
deep_space_belt_base.speed = deep_speed
deep_space_belt_base.related_underground_belt = data_util.mod_prefix.."deep-space-underground-belt"

local deep_space_splitter_base = table.deepcopy(splitter)
deep_space_splitter_base.name = data_util.mod_prefix .. "deep-space-splitter"
deep_space_splitter_base.order = "z"
deep_space_splitter_base.speed = deep_speed
data_util.replace_filenames_recursive(deep_space_splitter_base.structure,
  "space-s",
  "deep-space-s")
data_util.replace_filenames_recursive(deep_space_splitter_base.structure_patch,
  "space-s",
  "deep-space-s")
data_util.replace_sr_with_half_hr(deep_space_splitter_base.structure)
data_util.replace_sr_with_half_hr(deep_space_splitter_base.structure_patch)

local deep_space_ug_base = table.deepcopy(ug_belt)
deep_space_ug_base.name = data_util.mod_prefix .. "deep-space-underground-belt"
deep_space_ug_base.order = "z"
deep_space_ug_base.speed = deep_speed
deep_space_ug_base.max_distance = deep_belt_span + 1
data_util.replace_filenames_recursive(deep_space_ug_base.structure,
  "space-u",
  "deep-space-u")

for name, tint in pairs(deep_space_variants) do
  local suffix = "-"..name

  local variant_belt = table.deepcopy(deep_space_belt_base)
  variant_belt.name = variant_belt.name ..suffix
  variant_belt.minable.result = variant_belt.name
  variant_belt.icons = {
    {icon="__space-exploration-graphics__/graphics/icons/deep-space-transport-belt.png", icon_size=64},
    {icon="__space-exploration-graphics__/graphics/icons/deep-space-transport-belt-glow.png", icon_size=64,tint=tint}
  }

  variant_belt.related_underground_belt = deep_space_ug_base.name .. suffix
  data_util.tint_recursive(variant_belt.belt_animation_set.animation_set.layers[2], tint)


  local variant_splitter = table.deepcopy(deep_space_splitter_base)
  variant_splitter.name = variant_splitter.name ..suffix
  variant_splitter.minable.result = variant_splitter.name
  variant_splitter.icons = {
    {icon="__space-exploration-graphics__/graphics/icons/deep-space-splitter.png", icon_size=64},
    {icon="__space-exploration-graphics__/graphics/icons/deep-space-splitter-glow.png", icon_size=64,tint=tint}
  }
  variant_splitter.icon = nil
  variant_splitter.belt_animation_set = table.deepcopy(variant_belt.belt_animation_set)
  for _, structure in pairs({"structure", "structure_patch"}) do
    for direction, pictures in pairs(variant_splitter[structure]) do
      local pictures = table.deepcopy(pictures)
      local glow_pictures = table.deepcopy(pictures)
      data_util.replace_filenames_recursive(glow_pictures,
        "patch.png",
        "patch-glow.png")
      data_util.replace_filenames_recursive(glow_pictures,
        "east.png",
        "east-glow.png")
      data_util.replace_filenames_recursive(glow_pictures,
        "north.png",
        "north-glow.png")
      data_util.replace_filenames_recursive(glow_pictures,
        "west.png",
        "west-glow.png")
      data_util.replace_filenames_recursive(glow_pictures,
        "south.png",
        "south-glow.png")
      data_util.tint_recursive(glow_pictures, tint)
      data_util.blend_mode_recursive(glow_pictures, "additive")
      variant_splitter[structure][direction] = {
        layers = {pictures, glow_pictures}
      }
    end
  end

  local variant_ug = table.deepcopy(deep_space_ug_base)
  variant_ug.name = variant_ug.name ..suffix
  variant_ug.minable.result = variant_ug.name
  variant_ug.icons = {
    {icon="__space-exploration-graphics__/graphics/icons/deep-space-underground-belt.png", icon_size=64},
    {icon="__space-exploration-graphics__/graphics/icons/deep-space-underground-belt-glow.png", icon_size=64,tint=tint}
  }
  variant_ug.belt_animation_set = table.deepcopy(variant_belt.belt_animation_set)
  for _, field in pairs({"direction_in", "direction_in_side_loading","direction_out","direction_out_side_loading"}) do
    local sheet = table.deepcopy(variant_ug.structure[field].sheet)
    local glow_sheet = table.deepcopy(sheet)
    data_util.replace_filenames_recursive(glow_sheet,
      "underground-belt-structure.png",
      "underground-belt-structure-glow.png")
    data_util.tint_recursive(glow_sheet, tint)
    data_util.blend_mode_recursive(glow_sheet, "additive")
    variant_ug.structure[field].sheet = nil
    variant_ug.structure[field].sheets = {
      sheet, glow_sheet
    }
  end

  local variant_item_belt =   {
      type = "item",
      name = variant_belt.name,
      icons = variant_belt.icons,
      order = "z[space-transport-belt]-"..name,
      stack_size = 50,
      subgroup = "transport-belt",
      place_result = variant_belt.name,
  }
  local variant_item_splitter =   {
      type = "item",
      name = variant_splitter.name,
      icons = variant_splitter.icons,
      icon_size = 64,
      order = "z[space-transport-belt]-"..name.."-s[splitter]",
      stack_size = 50,
      subgroup = "splitter",
      place_result = variant_splitter.name,
  }
  local variant_item_ug =   {
      type = "item",
      name = variant_ug.name,
      icons = variant_ug.icons,
      icon_size = 64,
      order = "z[space-transport-belt]-"..name.."-u[underground]",
      stack_size = 50,
      subgroup = "underground-belt",
      place_result = variant_ug.name,
  }

  if name ~= default_variant then
    local variant_recipe_belt = {
      type = "recipe",
      name = variant_belt.name,
      ingredients = {
        {type = "item", name = deep_space_belt_base.name.."-"..default_variant, amount = 10 },
        {type = "item", name = "small-lamp", amount = 1 },
      },
      results = {
        {type = "item", name = variant_belt.name, amount = 10},
      },
      energy_required = 0.1,
      enabled = false,
      always_show_made_in = true,
      category = "crafting",
    }
    local variant_recipe_splitter = {
      type = "recipe",
      name = variant_splitter.name,
      ingredients = {
        {type = "item", name = deep_space_splitter_base.name.."-"..default_variant, amount = 1 },
        {type = "item", name = "small-lamp", amount = 1 },
      },
      results = {
        {type = "item", name = variant_splitter.name, amount = 1},
      },
      energy_required = 0.5,
      enabled = false,
      always_show_made_in = true,
      category = "crafting",
    }
    local variant_recipe_ug = {
      type = "recipe",
      name = variant_ug.name,
      ingredients = {
        {type = "item", name = deep_space_ug_base.name.."-"..default_variant, amount = 2 },
        {type = "item", name = "small-lamp", amount = 1 },
      },
      results = {
        {type = "item", name = variant_ug.name, amount = 2},
      },
      energy_required = 0.5,
      enabled = false,
      always_show_made_in = true,
      category = "crafting",
    }

    if (not settings.startup[data_util.mod_prefix .. "deep-space-belt-"..name]) or settings.startup[data_util.mod_prefix .. "deep-space-belt-"..name].value ~= false then
      table.insert(deep_tech.effects, {type = "unlock-recipe", recipe = variant_recipe_belt.name,})
      table.insert(deep_tech.effects, {type = "unlock-recipe", recipe = variant_recipe_splitter.name,})
      table.insert(deep_tech.effects, {type = "unlock-recipe", recipe = variant_recipe_ug.name,})
    end

    data:extend({
      variant_belt,
      variant_splitter,
      variant_ug,
      variant_item_belt,
      variant_item_splitter,
      variant_item_ug,
      variant_recipe_belt,
      variant_recipe_splitter,
      variant_recipe_ug
    })
  end

  data:extend({
    variant_belt,
    variant_splitter,
    variant_ug,
    variant_item_belt,
    variant_item_splitter,
    variant_item_ug,
  })
end



--log( serpent.block( data.raw["transport-belt"], {comment = false, numformat = '%1.8g' } ) )
