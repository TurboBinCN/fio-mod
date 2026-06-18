local data_util = require("data_util")
local make_recipe = data_util.make_recipe

make_recipe({
  name = data_util.mod_prefix .. "antimatter-stream",
  ingredients = {
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount=50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 100},
  },
  results = {
    { type = "fluid", name = data_util.mod_prefix .. "antimatter-stream", amount = 50}, -- 50 * 20MJ = 1000 MJ = 1GJ
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 100},
  },
  energy_required = 4, -- 400 * 5MW = 2000MJ
  main_product = data_util.mod_prefix .. "antimatter-stream",
  category = "space-materialisation",
  subgroup = "stream",
  enabled = false,
  always_show_made_in = true,
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-dirty",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 15},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 1,
  category = "space-materialisation",
  subgroup = "materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item[data_util.mod_prefix .. "contaminated-scrap"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "contaminated-scrap"].icon_size, scale = 0.5
    }
  ),
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  order = "a-a"
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-iron",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = "iron-ore", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 1,
  category = "space-materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item["iron-ore"].icon,
      icon_size = data.raw.item["iron-ore"].icon_size, scale = 0.5
    }
  ),
  subgroup = "materialisation",
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name.se-matter-fusion-to", {"item-name.iron-ore"}},
  order = "a-b"
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-copper",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = "copper-ore", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 1,
  category = "space-materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item["copper-ore"].icon,
      icon_size = data.raw.item["copper-ore"].icon_size, scale = 0.5
    }
  ),
  subgroup = "materialisation",
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name.se-matter-fusion-to", {"item-name.copper-ore"}},
  order = "a-c"
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-stone",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = "stone", amount = 10},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 1,
  category = "space-materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item["stone"].icon,
      icon_size = data.raw.item["stone"].icon_size, scale = 0.5
    }
  ),
  subgroup = "materialisation",
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name.se-matter-fusion-to", {"item-name.stone"}},
  order = "a-d"
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-uranium",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = "uranium-ore", amount_min = 1, amount_max = 1, probability = 0.5},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 6,
  category = "space-materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item["uranium-ore"].icon,
      icon_size = data.raw.item["uranium-ore"].icon_size, scale = 0.5
    }
  ),
  subgroup = "materialisation",
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name.se-matter-fusion-to", {"item-name.uranium-ore"}},
  order = "a-e"
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-vulcanite",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .."vulcanite", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 3,
  category = "space-materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item[data_util.mod_prefix .."vulcanite"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .."vulcanite"].icon_size, scale = 0.5
    }
  ),
  subgroup = "materialisation",
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name.se-matter-fusion-to", {"item-name." .. data_util.mod_prefix .."vulcanite"}},
  order = "a-f"
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-cryonite",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .."cryonite", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 3,
  category = "space-materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item[data_util.mod_prefix .."cryonite"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .."cryonite"].icon_size, scale = 0.5
    }
  ),
  subgroup = "materialisation",
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name.se-matter-fusion-to", {"item-name." .. data_util.mod_prefix .."cryonite"}},
  order = "a-g"
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-beryllium",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .."beryllium-ore", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 6,
  category = "space-materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item[data_util.mod_prefix .."beryllium-ore"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .."beryllium-ore"].icon_size, scale = 0.5
    }
  ),
  subgroup = "materialisation",
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name.se-matter-fusion-to", {"item-name." .. data_util.mod_prefix .."beryllium-ore"}},
  order = "a-h"
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-holmium",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .."holmium-ore", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 6,
  category = "space-materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item[data_util.mod_prefix .."holmium-ore"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .."holmium-ore"].icon_size, scale = 0.5
    }
  ),
  subgroup = "materialisation",
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name.se-matter-fusion-to", {"item-name." .. data_util.mod_prefix .."holmium-ore"}},
  order = "a-i"
})

make_recipe({
  name = data_util.mod_prefix .. "matter-fusion-iridium",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount = 1, ignored_by_stats = 1},
    { type = "fluid", name = data_util.mod_prefix .. "particle-stream", amount = 50},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-supercooled", amount = 25},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .."iridium-ore", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "contaminated-scrap", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "fusion-test-data", amount_min = 1, amount_max = 1, probability = 0.99, ignored_by_stats = 1},
    { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.01},
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 25},
  },
  energy_required = 6,
  category = "space-materialisation",
  icons = data_util.transition_icons(
    {
      icon = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon,
      icon_size = data.raw.fluid[data_util.mod_prefix .. "particle-stream"].icon_size, scale = 0.5
    },
    {
      icon = data.raw.item[data_util.mod_prefix .."iridium-ore"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .."iridium-ore"].icon_size, scale = 0.5
    }
  ),
  subgroup = "materialisation",
  enabled = false,
  allow_as_intermediate = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  localised_name = {"recipe-name.se-matter-fusion-to", {"item-name." .. data_util.mod_prefix .."iridium-ore"}},
  order = "a-j"
})
