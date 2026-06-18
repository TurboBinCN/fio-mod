local data_util = require("data_util")

local sand_to_matter = {
  type = "recipe",
  name = "se-kr-sand-to-matter",
  localised_name = {"recipe-name.kr-to-matter",{"item-name.sand"}},
  category = "basic-matter-conversion",
  subgroup = "basic-matter-conversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-m.png", icon_size = 64},
    {icon = data.raw.item["kr-sand"].icon, icon_size = 64, scale = 0.28, shift = {-8,-6}},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {4,8}},
  },
  energy_required = 0.5,
  enabled = false,
  hidden = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "item", name = "kr-sand", amount = 10},
  },
  results = {
    {type = "fluid", name = "kr-matter", amount = 1},
  },
  order = "a[basic-matter]-a[conversion]-c[sand]"
}
data:extend({sand_to_matter})

local vulcanite_to_matter = {
  type = "recipe",
  name = "se-kr-se-vulcanite-to-matter",
  localised_name = {"recipe-name.kr-to-matter",{"item-name.se-vulcanite"}},
  category = "kr-matter-conversion",
  subgroup = "kr-matter-conversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-m.png", icon_size = 64},
    {icon = data.raw.item["se-vulcanite"].icon, icon_size = 64, scale = 0.28, shift = {-8,-6}},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {4,8}},
  },
  energy_required = 8,
  enabled = false,
  hidden = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "item", name = "se-vulcanite", amount = 10},
  },
  results = {
    {type = "fluid", name = "kr-matter", amount = 8},
  },
}
local matter_to_vulcanite = {
  type = "recipe",
  name = "se-kr-matter-to-se-vulcanite",
  localised_name = {"recipe-name.kr-matter-to",{"item-name.se-vulcanite"}},
  localised_description = {"recipe-description.matter-recipe-with-stabilizer"},
  category = "kr-matter-deconversion",
  subgroup = "kr-matter-deconversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-i.png", icon_size = 64},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {8,-6}},
    {icon = data.raw.item["se-vulcanite"].icon, icon_size = 64, scale = 0.28, shift = {-4,8}},
  },
  energy_required = 8,
  enabled = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "fluid", name = "kr-matter", amount = 64},
    {type = "item", name = "kr-charged-matter-stabilizer", amount = 1, ignored_by_stats = 1}
  },
  results = {
    {type = "item", name = "se-vulcanite", amount = 10},
    {type = "item", name = "kr-matter-stabilizer", probability = 0.99, amount = 1, amount_max = 1, ignored_by_stats = 1}
  },
  main_product = "se-vulcanite",
}
data:extend({vulcanite_to_matter, matter_to_vulcanite})

local cryonite_to_matter = {
  type = "recipe",
  name = "se-kr-se-cryonite-to-matter",
  localised_name = {"recipe-name.kr-to-matter",{"item-name.se-cryonite"}},
  category = "kr-matter-conversion",
  subgroup = "kr-matter-conversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-m.png", icon_size = 64},
    {icon = data.raw.item["se-cryonite"].icon, icon_size = 64, scale = 0.28, shift = {-8,-6}},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {4,8}},
  },
  energy_required = 10,
  enabled = false,
  hidden = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "item", name = "se-cryonite", amount = 10},
  },
  results = {
    {type = "fluid", name = "kr-matter", amount = 10},
  },
}
local matter_to_cryonite = {
  type = "recipe",
  name = "se-kr-matter-to-se-cryonite",
  localised_name = {"recipe-name.kr-matter-to",{"item-name.se-cryonite"}},
  localised_description = {"recipe-description.matter-recipe-with-stabilizer"},
  category = "kr-matter-deconversion",
  subgroup = "kr-matter-deconversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-i.png", icon_size = 64},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {8,-6}},
    {icon = data.raw.item["se-cryonite"].icon, icon_size = 64, scale = 0.28, shift = {-4,8}},
  },
  energy_required = 10,
  enabled = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "fluid", name = "kr-matter", amount = 80},
    {type = "item", name = "kr-charged-matter-stabilizer", amount = 1, ignored_by_stats = 1}
  },
  results = {
    {type = "item", name = "se-cryonite", amount = 10},
    {type = "item", name = "kr-matter-stabilizer", probability = 0.99, amount = 1, amount_max = 1, ignored_by_stats = 1}
  },
  main_product = "se-cryonite",
}
data:extend({cryonite_to_matter, matter_to_cryonite})

local beryllium_ore_to_matter = {
  type = "recipe",
  name = "se-kr-se-beryllium-ore-to-matter",
  localised_name = {"recipe-name.kr-to-matter",{"item-name.se-beryllium-ore"}},
  category = "kr-matter-conversion",
  subgroup = "kr-matter-conversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-m.png", icon_size = 64},
    {icon = data.raw.item["se-beryllium-ore"].icon, icon_size = 64, scale = 0.28, shift = {-8,-6}},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {4,8}},
  },
  energy_required = 12,
  enabled = false,
  hidden = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "item", name = "se-beryllium-ore", amount = 10},
  },
  results = {
    {type = "fluid", name = "kr-matter", amount = 12},
  },
}
local matter_to_beryllium_ore = {
  type = "recipe",
  name = "se-kr-matter-to-se-beryllium-ore",
  localised_name = {"recipe-name.kr-matter-to",{"item-name.se-beryllium-ore"}},
  localised_description = {"recipe-description.matter-recipe-with-stabilizer"},
  category = "kr-matter-deconversion",
  subgroup = "kr-matter-deconversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-i.png", icon_size = 64},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {8,-6}},
    {icon = data.raw.item["se-beryllium-ore"].icon, icon_size = 64, scale = 0.28, shift = {-4,8}},
  },
  energy_required = 12,
  enabled = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "fluid", name = "kr-matter", amount = 96},
    {type = "item", name = "kr-charged-matter-stabilizer", amount = 1, ignored_by_stats = 1}
  },
  results = {
    {type = "item", name = "se-beryllium-ore", amount = 10},
    {type = "item", name = "kr-matter-stabilizer", probability = 0.99, amount = 1, amount_max = 1, ignored_by_stats = 1}
  },
  main_product = "se-beryllium-ore",
}
data:extend({beryllium_ore_to_matter, matter_to_beryllium_ore})

local holmium_ore_to_matter = {
  type = "recipe",
  name = "se-kr-se-holmium-ore-to-matter",
  localised_name = {"recipe-name.kr-to-matter",{"item-name.se-holmium-ore"}},
  category = "kr-matter-conversion",
  subgroup = "kr-matter-conversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-m.png", icon_size = 64},
    {icon = data.raw.item["se-holmium-ore"].icon, icon_size = 64, scale = 0.28, shift = {-8,-6}},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {4,8}},
  },
  energy_required = 14,
  enabled = false,
  hidden = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "item", name = "se-holmium-ore", amount = 10},
  },
  results = {
    {type = "fluid", name = "kr-matter", amount = 14},
  },
}
local matter_to_holmium_ore = {
  type = "recipe",
  name = "se-kr-matter-to-se-holmium-ore",
  localised_name = {"recipe-name.kr-matter-to",{"item-name.se-holmium-ore"}},
  localised_description = {"recipe-description.matter-recipe-with-stabilizer"},
  category = "kr-matter-deconversion",
  subgroup = "kr-matter-deconversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-i.png", icon_size = 64},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {8,-6}},
    {icon = data.raw.item["se-holmium-ore"].icon, icon_size = 64, scale = 0.28, shift = {-4,8}},
  },
  energy_required = 14,
  enabled = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "fluid", name = "kr-matter", amount = 112},
    {type = "item", name = "kr-charged-matter-stabilizer", amount = 1, ignored_by_stats = 1}
  },
  results = {
    {type = "item", name = "se-holmium-ore", amount = 10},
    {type = "item", name = "kr-matter-stabilizer", probability = 0.99, amount = 1, amount_max = 1, ignored_by_stats = 1}
  },
  main_product = "se-holmium-ore",
}
data:extend({holmium_ore_to_matter, matter_to_holmium_ore})

local iridium_ore_to_matter = {
  type = "recipe",
  name = "se-kr-se-iridium-ore-to-matter",
  localised_name = {"recipe-name.kr-to-matter",{"item-name.se-iridium-ore"}},
  category = "kr-matter-conversion",
  subgroup = "kr-matter-conversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-m.png", icon_size = 64},
    {icon = data.raw.item["se-iridium-ore"].icon, icon_size = 64, scale = 0.28, shift = {-8,-6}},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {4,8}},
  },
  energy_required = 16,
  enabled = false,
  hidden = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "item", name = "se-iridium-ore", amount = 10},
  },
  results = {
    {type = "fluid", name = "kr-matter", amount = 16},
  },
}
local matter_to_iridium_ore = {
  type = "recipe",
  name = "se-kr-matter-to-se-iridium-ore",
  localised_name = {"recipe-name.kr-matter-to",{"item-name.se-iridium-ore"}},
  localised_description = {"recipe-description.matter-recipe-with-stabilizer"},
  category = "kr-matter-deconversion",
  subgroup = "kr-matter-deconversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-i.png", icon_size = 64},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {8,-6}},
    {icon = data.raw.item["se-iridium-ore"].icon, icon_size = 64, scale = 0.28, shift = {-4,8}},
  },
  energy_required = 16,
  enabled = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "fluid", name = "kr-matter", amount = 128},
    {type = "item", name = "kr-charged-matter-stabilizer", amount = 1, ignored_by_stats = 1}
  },
  results = {
    {type = "item", name = "se-iridium-ore", amount = 10},
    {type = "item", name = "kr-matter-stabilizer", probability = 0.99, amount = 1, amount_max = 1, ignored_by_stats = 1}
  },
  main_product = "se-iridium-ore",
}
data:extend({iridium_ore_to_matter, matter_to_iridium_ore})

local imersite_ore_to_matter = {
  type = "recipe",
  name = "se-kr-kr-imersite-to-matter",
  localised_name = {"recipe-name.kr-to-matter",{"item-name.kr-imersite"}},
  category = "kr-matter-conversion",
  subgroup = "kr-matter-conversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-m.png", icon_size = 64},
    {icon = data.raw.item["kr-imersite"].icon, icon_size = 64, scale = 0.28, shift = {-8,-6}},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {4,8}},
  },
  energy_required = 1,
  enabled = false,
  hidden = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "item", name = "kr-imersite", amount = 10},
  },
  results = {
    {type = "fluid", name = "kr-matter", amount = 10},
  },
}
local matter_to_imersite_ore = {
  type = "recipe",
  name = "se-kr-matter-to-kr-imersite",
  localised_name = {"recipe-name.kr-matter-to",{"item-name.kr-imersite"}},
  localised_description = {"recipe-description.matter-recipe-with-stabilizer"},
  category = "kr-matter-deconversion",
  subgroup = "kr-matter-deconversion",
  allow_as_intermediate = false,
  icons = {
    {icon = "__Krastorio2Assets__/icons/arrows/arrow-i.png", icon_size = 64},
    {icon = "__Krastorio2Assets__/icons/fluids/matter.png", icon_size = 64, scale = 0.28, shift = {8,-6}},
    {icon = data.raw.item["kr-imersite"].icon, icon_size = 64, scale = 0.28, shift = {-4,8}},
  },
  energy_required = 1,
  enabled = false,
  hide_from_player_crafting = true,
  always_show_made_in = true,
  always_show_products = true,
  show_amount_in_title = false,
  ingredients = {
    {type = "fluid", name = "kr-matter", amount = 10},
    {type = "item", name = "kr-charged-matter-stabilizer", amount = 1, ignored_by_stats = 1}
  },
  results = {
    {type = "item", name = "kr-imersite", amount = 10},
    {type = "item", name = "kr-matter-stabilizer", probability = 0.99, amount = 1, amount_max = 1, ignored_by_stats = 1}
  },
  main_product = "kr-imersite",
}
data:extend({imersite_ore_to_matter, matter_to_imersite_ore})

-- Create basic, ineffective recipes for SE Particle Stream creation.
local function make_particle_stream_recipe(name, item_name, required_amount, bonus_particle_stream)
  data_util.make_recipe({
    type = "recipe",
    name = "se-kr-" .. name .. "-to-particle-stream",
    category = "space-materialisation",
    subgroup = "advanced-particle-stream",
    localised_name = {"recipe-name.se-kr-matter-liberation", {"item-name." .. item_name}},
    ingredients = {
      {type = "item", name = item_name, amount = required_amount},
      {type = "item", name = "se-kr-matter-liberation-data", amount = 1},
      {type = "fluid", name = "se-particle-stream", amount = 500},
    },
    results = {
      {type = "item", name = "se-kr-matter-liberation-data", amount_min = 1, amount_max = 1, probability = 0.99},
      {type = "item", name = "se-broken-data", amount_min = 1, amount_max = 1, probability = 0.01},
      {type = "fluid", name = "se-particle-stream", amount = 500 + bonus_particle_stream},
    },
    energy_required = 30,
    -- SE Definition
    icons = data_util.transition_icons(
      {
        icon = data.raw.item[item_name].icon,
        icon_size = data.raw.item[item_name].icon_size, scale = 0.5
      },
      {
        icon = data.raw.fluid["se-particle-stream"].icon,
        icon_size = data.raw.fluid["se-particle-stream"].icon_size, scale = 0.5
      }
    ),
    allow_as_intermediate = false,
    always_show_made_in = true,
    allow_decomposition = false,
  })
  --data_util.recipe_require_tech("se-kr-".. name .. "-to-particle-stream", "se-kr-advanced-stream-production")
end

data_util.replace_or_add_ingredient("se-particle-stream","kr-sand","kr-sand",25)
data_util.replace_or_add_result("se-particle-stream","se-particle-stream","se-particle-stream",50,true)

-- Requires 500 particle stream to make 10 common ore, costs 50 common ore to make 500 particle stream.
make_particle_stream_recipe("iron", "iron-ore", 10, 100)
make_particle_stream_recipe("copper", "copper-ore", 10, 100)
make_particle_stream_recipe("kr-rare-metal-ore", "kr-rare-metal-ore", 10, 100)
make_particle_stream_recipe("stone", "stone", 10, 100)
-- Requires 500 particle stream to make 5 rare ore, costs 50 rare ore to make 500 particle stream
make_particle_stream_recipe("uranium", "uranium-ore", 10, 100)
make_particle_stream_recipe("beryllium", "se-beryllium-ore", 10, 100)
make_particle_stream_recipe("holmium", "se-holmium-ore", 10, 100)
make_particle_stream_recipe("iridium", "se-iridium-ore", 10, 100)
-- Requires 500 particle stream to make 1 exotic ore, costs 100 exotic ore to make 500 particle stream.
make_particle_stream_recipe("kr-imersite", "kr-imersite", 10, 50)
make_particle_stream_recipe("vulcanite", "se-vulcanite", 10, 50)
make_particle_stream_recipe("cryonite", "se-cryonite", 10, 50)

-- Update 1st Tier Fusion recipes to use Matter Synthesis Data instead of Fusion Test Data
data_util.replace_or_add_ingredient("se-matter-fusion-iron", "se-fusion-test-data", "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-matter-fusion-iron", "se-particle-stream", "se-particle-stream", 500, true)
data_util.replace_or_add_result("se-matter-fusion-iron", "se-fusion-test-data", "se-kr-matter-synthesis-data", nil, nil, 1, 1, 0.99)
data_util.replace_or_add_result("se-matter-fusion-iron", "se-junk-data", "se-broken-data", nil, nil, 1, 1, 0.01)

data_util.replace_or_add_ingredient("se-matter-fusion-copper", "se-fusion-test-data", "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-matter-fusion-copper", "se-particle-stream", "se-particle-stream", 500, true)
data_util.replace_or_add_result("se-matter-fusion-copper", "se-fusion-test-data", "se-kr-matter-synthesis-data", nil, nil, 1, 1, 0.99)
data_util.replace_or_add_result("se-matter-fusion-copper", "se-junk-data", "se-broken-data", nil, nil, 1, 1, 0.01)

data_util.replace_or_add_ingredient("se-matter-fusion-stone", "se-fusion-test-data", "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-matter-fusion-stone", "se-particle-stream", "se-particle-stream", 500, true)
data_util.replace_or_add_result("se-matter-fusion-stone", "se-fusion-test-data", "se-kr-matter-synthesis-data", nil, nil, 1, 1, 0.99)
data_util.replace_or_add_result("se-matter-fusion-stone", "se-junk-data", "se-broken-data", nil, nil, 1, 1, 0.01)

data_util.replace_or_add_ingredient("se-matter-fusion-uranium", "se-fusion-test-data", "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-matter-fusion-uranium", "se-particle-stream", "se-particle-stream", 500, true)
data_util.replace_or_add_result("se-matter-fusion-uranium", nil, "uranium-ore", 5)
data_util.replace_or_add_result("se-matter-fusion-uranium", "se-fusion-test-data", "se-kr-matter-synthesis-data", nil, nil, 1, 1, 0.99)
data_util.replace_or_add_result("se-matter-fusion-uranium", "se-junk-data", "se-broken-data", nil, nil, 1, 1, 0.01)

-- Update 2nd Tier Fusion recipes to use Matter Synthesis Data in addition to Fusion Test Data, and improve their material output
data_util.replace_or_add_ingredient("se-matter-fusion-beryllium", nil, "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-matter-fusion-beryllium", "se-particle-stream", "se-particle-stream", 500, true)
data_util.replace_or_add_result("se-matter-fusion-beryllium", nil, "se-beryllium-ore", 5)
data_util.replace_or_add_result("se-matter-fusion-beryllium", nil, "se-kr-matter-synthesis-data", nil, nil, 1, 1, 0.99)
data_util.replace_or_add_result("se-matter-fusion-beryllium", "se-junk-data", "se-broken-data", nil ,nil, 1, 1, 0.02)

data_util.replace_or_add_ingredient("se-matter-fusion-holmium", nil, "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-matter-fusion-holmium", "se-particle-stream", "se-particle-stream", 500, true)
data_util.replace_or_add_result("se-matter-fusion-holmium", nil, "se-holmium-ore", 5)
data_util.replace_or_add_result("se-matter-fusion-holmium", nil, "se-kr-matter-synthesis-data", nil, nil, 1, 1, 0.99)
data_util.replace_or_add_result("se-matter-fusion-holmium", "se-junk-data", "se-broken-data", nil ,nil, 1, 1, 0.02)

data_util.replace_or_add_ingredient("se-matter-fusion-iridium", nil, "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-matter-fusion-iridium", "se-particle-stream", "se-particle-stream", 500, true)
data_util.replace_or_add_result("se-matter-fusion-iridium", nil, "se-iridium-ore", 5)
data_util.replace_or_add_result("se-matter-fusion-iridium", nil, "se-kr-matter-synthesis-data", nil, nil, 1, 1, 0.99)
data_util.replace_or_add_result("se-matter-fusion-iridium", "se-junk-data", "se-broken-data", nil ,nil, 1, 1, 0.02)

data_util.replace_or_add_ingredient("se-matter-fusion-vulcanite", nil, "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-matter-fusion-vulcanite", "se-particle-stream", "se-particle-stream", 500, true)
data_util.replace_or_add_result("se-matter-fusion-vulcanite", nil, "se-vulcanite", 1)
data_util.replace_or_add_result("se-matter-fusion-vulcanite", nil, "se-kr-matter-synthesis-data", nil, nil, 1, 1, 0.99)
data_util.replace_or_add_result("se-matter-fusion-vulcanite", "se-junk-data", "se-broken-data", nil ,nil, 1, 1, 0.02)

data_util.replace_or_add_ingredient("se-matter-fusion-cryonite", nil, "se-kr-matter-synthesis-data", 1)
data_util.replace_or_add_ingredient("se-matter-fusion-cryonite", "se-particle-stream", "se-particle-stream", 500, true)
data_util.replace_or_add_result("se-matter-fusion-cryonite", nil, "se-cryonite", 1)
data_util.replace_or_add_result("se-matter-fusion-cryonite", nil, "se-kr-matter-synthesis-data", nil, nil, 1, 1, 0.99)
data_util.replace_or_add_result("se-matter-fusion-cryonite", "se-junk-data", "se-broken-data", nil ,nil, 1, 1, 0.02)

-- Matter Fusion recipes for K2 resources
local raw_rare_metals_recipe = table.deepcopy(data.raw.recipe["se-matter-fusion-iron"])
raw_rare_metals_recipe.name = "se-kr-matter-fusion-kr-rare-metal-ore"
raw_rare_metals_recipe.icon = nil
raw_rare_metals_recipe.icons = data_util.transition_icons(
  {
    icon = data.raw.fluid["se-particle-stream"].icon,
    icon_size = data.raw.fluid["se-particle-stream"].icon_size, scale = 0.5
  },
  {
    icon = data.raw.item["kr-rare-metal-ore"].icon,
    icon_size = data.raw.item["kr-rare-metal-ore"].icon_size, scale = 0.5
  }
)
raw_rare_metals_recipe.results = {
  { type = "item", name = "kr-rare-metal-ore", amount = 10},
  { type = "item", name = "se-contaminated-scrap", amount = 1},
  { type = "item", name = "se-kr-matter-synthesis-data", amount_min = 1, amount_max = 1, probability = 0.99},
  { type = "item", name = "se-broken-data", amount_min = 1, amount_max = 1, probability = 0.01},
  { type = "fluid", name = "se-space-coolant-hot", amount = 25},
}
raw_rare_metals_recipe.localised_name = {"recipe-name.se-matter-fusion-to", {"item-name.kr-rare-metal-ore"}}
data:extend({raw_rare_metals_recipe})

local raw_imersite_recipe = table.deepcopy(data.raw.recipe["se-matter-fusion-vulcanite"])
raw_imersite_recipe.name = "se-kr-matter-fusion-kr-imersite"
raw_imersite_recipe.icon = nil
raw_imersite_recipe.icons = data_util.transition_icons(
  {
    icon = data.raw.fluid["se-particle-stream"].icon,
    icon_size = data.raw.fluid["se-particle-stream"].icon_size, scale = 0.5
  },
  {
    icon = data.raw.item["kr-imersite"].icon,
    icon_size = data.raw.item["kr-imersite"].icon_size, scale = 0.5
  }
)
raw_imersite_recipe.results = {
  { type = "item", name = "kr-imersite", amount = 1},
  { type = "item", name = "se-contaminated-scrap", amount = 1},
  { type = "item", name = "se-fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99},
  { type = "item", name = "se-kr-matter-synthesis-data", amount_min = 1, amount_max = 1, probability = 0.99},
  { type = "item", name = "se-broken-data", amount_min = 1, amount_max = 1, probability = 0.02},
  { type = "fluid", name = "se-space-coolant-hot", amount = 25},
}
raw_imersite_recipe.localised_name = {"recipe-name.se-matter-fusion-to", {"item-name.kr-imersite"}}
data:extend({raw_imersite_recipe})
