local data_util = require("data_util")
local make_recipe = data_util.make_recipe

make_recipe({
  name = data_util.mod_prefix .. "medpack",
  ingredients = {
    { type = "item", name = "raw-fish", amount = 5},
    { type = "item", name = "wood", amount = 5},
    { type = "item", name = "iron-plate", amount = 1},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "medpack", amount = 1},
  },
  order = "a-a-a",
  energy_required = 10,
  category = "crafting",
  enabled = false,
  always_show_made_in = true,
})
make_recipe({
  name = data_util.mod_prefix .. "medpack-plastic",
  localised_name = {"item-name."..data_util.mod_prefix.."medpack"},
  ingredients = {
    { type = "item", name = "iron-plate", amount = 1},
    { type = "item", name = "plastic-bar", amount = 5},
    { type = "fluid", name =  "water" , amount = 100},
    { type = "fluid", name =  "heavy-oil" , amount = 100},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "medpack", amount = 1},
  },
  order = "a-a-b",
  energy_required = 10,
  category = "lifesupport",
  enabled = false,
  always_show_made_in = true,
})
make_recipe({
  name = data_util.mod_prefix .. "medpack-2",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "medpack", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "canister", amount = 1},
    { type = "fluid", name =  "petroleum-gas" , amount = 100},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "medpack-2", amount = 1},
  },
  order = "a-b",
  energy_required = 10,
  category = "lifesupport",
  enabled = false,
  always_show_made_in = true,
})
make_recipe({
  name = data_util.mod_prefix .. "medpack-3",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "medpack-2", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "specimen", amount = 1},
    { type = "fluid", name =  data_util.mod_prefix .. "chemical-gel" , amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "medpack-3", amount = 1},
  },
  order = "a-c",
  energy_required = 10,
  category = "lifesupport",
  enabled = false,
  always_show_made_in = true,
})
make_recipe({
  name = data_util.mod_prefix .. "medpack-4",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "medpack-3", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "significant-specimen", amount = 1},
    { type = "item", name = data_util.mod_prefix .. "self-sealing-gel", amount = 1},
    { type = "fluid", name =  data_util.mod_prefix .. "neural-gel-2" , amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "medpack-4", amount = 1},
  },
  order = "a-d",
  energy_required = 10,
  category = "lifesupport",
  enabled = false,
  always_show_made_in = true,
})
