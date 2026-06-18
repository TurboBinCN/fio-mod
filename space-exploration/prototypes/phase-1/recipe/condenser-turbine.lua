local data_util = require("data_util")
local make_recipe = data_util.make_recipe

make_recipe({
  name = data_util.mod_prefix .. "condenser-turbine",
  ingredients = {
    {type = "item", name = "steam-turbine", amount = 1},
    {type = "item", name = "storage-tank", amount = 2},
    {type = "item", name = "electric-engine-unit", amount = 10},
    {type = "item", name = "low-density-structure", amount = 20},
    {type = "item", name = SEItemNames.get_glass_name(), amount = 20},
  },
  results = {
    {type = "item", name = data_util.mod_prefix .. "condenser-turbine", amount = 1},
  },
  energy_required = 5,
  category = "crafting",
  enabled = false,
  always_show_made_in = false,
})
local steam_temperature_ranges = {
  100, -- Min
  165, -- Vanilla boiler
  200,
  300,
  400,
  415, -- K2 HE
  500, -- HE
  600,
  700,
  800,
  900,
  1000  -- last one is accepted but previous temperature is used internally
}
for i = 1, #steam_temperature_ranges - 1 do
  local low = steam_temperature_ranges[i]
  local high = steam_temperature_ranges[i+1]

  data:extend({
    {
      type = "recipe",
      name = data_util.mod_prefix .. "condenser-turbine-reclaim-water-"..low.."-"..high,
      icons = {
        { icon = data.raw.item[data_util.mod_prefix .. "condenser-turbine"].icon, scale = 0.5, icon_size = 64 },
        { icon = data.raw.fluid["steam"].icon, scale = 0.375, icon_size = 64 },
      },
      order = "a-" .. i,
      subgroup = "spaceship-process",
      hidden = true,
      energy_required = 0.1,
      category = "condenser-turbine",
      ingredients =
      {
        {type="fluid", name="steam", amount=100,
        minimum_temperature = low - 1,
        maximum_temperature = (i == (#steam_temperature_ranges - 1)) and (high + 1) or (high -1)},
      },
      results = {
        {type="fluid", name="water", amount=9.9},
        {type="fluid", name=data_util.mod_prefix .. "decompressing-steam", amount=75, temperature = low},
      },
      hide_from_player_crafting = true,
      enabled = true,
      allow_as_intermediate = false,
      always_show_made_in = true,
      localised_name = {"", {"recipe-name.se-condenser-turbine-reclaim-water"}, " (", tostring(low), "°C)"}
    },
  })
end
