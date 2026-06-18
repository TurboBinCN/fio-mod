local data_util = require("data_util")
local make_recipe = data_util.make_recipe

data:extend({
  {
    -- the dummy recipe for the rocket silo section, required for launch.
    -- the component is inserted when the launch pad has the required parts.
    type = "recipe",
    name = data_util.mod_prefix .. "rocket-launch-pad-silo-dummy-recipe",
    results = {
      {type = "item", name = data_util.mod_prefix .. "rocket-launch-pad-silo-dummy-result-item", amount = 1},
    },
    category = "rocket-building",
    enabled = false,
    energy_required = 0.01,
    hidden = true,
    auto_recycle = false, -- 0.01 / 16 = crash
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "rocket-launch-pad-silo-dummy-ingredient-item", amount = 1} -- could be anything really
    },
    always_show_made_in = true,
  },
  {
      type = "recipe",
      name = data_util.mod_prefix .. "rocket-launch-pad",
      results = {
        {type = "item", name = data_util.mod_prefix .. "rocket-launch-pad", amount = 1},
      },
      enabled = false,
      energy_required = 30,
      ingredients = {
        {type = "item", name = "steel-plate", amount = 1000},
        {type = "item", name = "concrete", amount = 1000},
        {type = "item", name = "pipe", amount = 100},
        {type = "item", name = "storage-tank", amount = 10},
        {type = "item", name = "radar", amount = 10},
        {type = "item", name = "steel-chest", amount = 10},
        {type = "item", name = "processing-unit", amount = 200},
        {type = "item", name = "electric-engine-unit", amount = 200}
      },
      requester_paste_multiplier = 1,
    },
    always_show_made_in = true,
})
