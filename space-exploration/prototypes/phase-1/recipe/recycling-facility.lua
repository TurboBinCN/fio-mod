-- NOTE: fluids x100

local data_util = require("data_util")
local make_recipe = data_util.make_recipe

make_recipe({
  name = data_util.mod_prefix .. "scrap-hard-recycling",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 1},
  },
  results = {
    { type = "item", name = "iron-ore", amount_min = 1, amount_max = 1, probability = 0.1},
    { type = "item", name = "copper-ore", amount_min = 1, amount_max = 1, probability = 0.1},
    { type = "item", name = "stone", amount_min = 1, amount_max = 1, probability = 0.1},
    { type = "fluid", name = "heavy-oil", amount_min = 1, amount_max = 1, probability = 0.1},
  },
  category = "hard-recycling",
  subgroup = "recycling",
  icons = data_util.transition_icons(
    {
      icon = data.raw.item[data_util.mod_prefix .. "scrap"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "scrap"].icon_size, scale = 0.5,
      draw_background = true,
    },
    {
      {icon = data.raw.item["iron-ore"].icon, icon_size = data.raw.item["iron-ore"].icon_size, scale = 0.5, draw_background = true,},
      {icon = data.raw.item["copper-ore"].icon, icon_size = data.raw.item["copper-ore"].icon_size, scale = 0.5, draw_background = true,},
      {icon = data.raw.item["stone"].icon, icon_size = data.raw.item["stone"].icon_size, scale = 0.5, draw_background = true,},
    }
  ),
  energy_required = 1,
  allow_as_intermediate = false,
  enabled = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  order = "a[recycling]-c[recycling]-a[recycling]"
})

make_recipe({
  name = data_util.mod_prefix .. "broken-data-scrapping",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "broken-data", amount = 1}
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 5},
  },
  icon = "__space-exploration-graphics__/graphics/icons/scrap.png",
  category = "hard-recycling",
  subgroup = "recycling",
  icons = data_util.transition_icons(
    {
      icon = data.raw.item[data_util.mod_prefix .. "broken-data"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "broken-data"].icon_size, scale = 0.5,
      draw_background = true,
    },
    {
      icon = data.raw.item[data_util.mod_prefix .. "scrap"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "scrap"].icon_size, scale = 0.5,
      draw_background = true,
    }
  ),
  energy_required = 5,
  allow_as_intermediate = false,
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "broken-data-scrapping"},
  enabled = false,
  always_show_made_in = true,
  allow_decomposition = false,
  show_amount_in_title = false,
  hide_from_signal_gui = false,
  order = "a[recycling]-d[scrapping]-b[scrapping]"
})

make_recipe({
  name = data_util.mod_prefix .. "barrel-reprocessing",
  ingredients = {
    { type = "item", name = "barrel", amount = 1}
  },
  results = {
    { type = "item", name = "steel-plate", amount = 1},
  },
  category = "hard-recycling",
  subgroup = "recycling",
  icons = data_util.transition_icons(
    {
      icon = data.raw.item["barrel"].icon,
      icon_size = data.raw.item["barrel"].icon_size, scale = 0.5,
      draw_background = true,
    },
    {
      icon = data.raw.item["steel-plate"].icon,
      icon_size = data.raw.item["steel-plate"].icon_size, scale = 0.5,
      draw_background = true,
    }
  ),
  energy_required = 2,
  allow_as_intermediate = false,
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "barrel-reprocessing"},
  enabled = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  order = "a[recycling]-d[scrapping]-a[scrapping]"
})

make_recipe({
  name = data_util.mod_prefix .. "space-capsule-scrapping",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "space-capsule", amount = 1}
  },
  results = {
    { type = "item", name = "solar-panel", amount = 45},
    { type = "item", name = "accumulator", amount = 45},
    { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 90},
    { type = "item", name = "low-density-structure", amount = 90},
    { type = "item", name = "rocket-control-unit", amount = 90},
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 1000},
  },
  icon = "__space-exploration-graphics__/graphics/icons/scrap.png",
  category = "hard-recycling",
  subgroup = "recycling",
  icons = data_util.transition_icons(
    {
      icon = data.raw.item[data_util.mod_prefix .. "space-capsule"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "space-capsule"].icon_size, scale = 0.5,
      draw_background = true,
    },
    {
      icon = data.raw.item[data_util.mod_prefix .. "scrap"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "scrap"].icon_size, scale = 0.5,
      draw_background = true,
    }
  ),
  energy_required = 2,
  allow_as_intermediate = false,
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "space-capsule-scrapping"},
  enabled = false,
  always_show_made_in = true,
  allow_decomposition = false,
  hide_from_signal_gui = false,
  order = "a[recycling]-d[scrapping]-c[scrapping]"
})

make_recipe({
  name = data_util.mod_prefix .. "space-capsule-scorched-scrapping",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "space-capsule-scorched", amount = 1}
  },
  results = {
    { type = "item", name = "solar-panel", amount = 45},
    { type = "item", name = "accumulator", amount = 45},
    { type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 50},
    { type = "item", name = "low-density-structure", amount = 75},
    { type = "item", name = "rocket-control-unit", amount = 90},
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 1000},
  },
  icon = "__space-exploration-graphics__/graphics/icons/scrap.png",
  category = "hard-recycling",
  subgroup = "recycling",
  icons = data_util.transition_icons(
    {
      icon = data.raw.item[data_util.mod_prefix .. "space-capsule-scorched"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "space-capsule-scorched"].icon_size,
      draw_background = true,
    },
    {
      icon = data.raw.item[data_util.mod_prefix .. "scrap"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "scrap"].icon_size,
      draw_background = true,
    }
  ),
  energy_required = 2,
  allow_as_intermediate = false,
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "space-capsule-scorched-scrapping"},
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  order = "a[recycling]-d[scrapping]-d[scrapping]"
})

make_recipe({
  name = data_util.mod_prefix .. "cargo-pod-scrapping",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "cargo-rocket-cargo-pod", amount = 1}
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "scrap", amount = 100},
  },
  icon = "__space-exploration-graphics__/graphics/icons/scrap.png",
  category = "hard-recycling",
  subgroup = "recycling",
  icons = data_util.transition_icons(
    {
      icon = data.raw.item[data_util.mod_prefix .. "cargo-rocket-cargo-pod"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "cargo-rocket-cargo-pod"].icon_size, scale = 0.5,
      draw_background = true,
    },
    {
      icon = data.raw.item[data_util.mod_prefix .. "scrap"].icon,
      icon_size = data.raw.item[data_util.mod_prefix .. "scrap"].icon_size, scale = 0.5,
      draw_background = true,
    }
  ),
  energy_required = 2,
  allow_as_intermediate = false,
  localised_name = {"recipe-name." .. data_util.mod_prefix .. "cargo-pod-scrapping"},
  enabled = false,
  always_show_made_in = true,
  allow_decomposition = false,
  show_amount_in_title = false,
  hide_from_signal_gui = false,
  order  = "a[recycling]-d[scrapping]-e[scrapping]"
})
