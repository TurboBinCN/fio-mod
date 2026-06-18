local data_util = require("data_util")

if mods["quality"] then
  -- we cannot assume the load order of quality forks, so everything is one stage later than where it should be.
end

-- until landing pads can scale their inventory size its better to let control stage code believe its always 500 slots
data.raw["container"][data_util.mod_prefix .. "rocket-launch-pad"].quality_affects_inventory_size = false

-- none of the space exploration beacons currently get a boost from quality,
-- until that ever happens we will just block it for the standard beacon as well.
data.raw["beacon"]["beacon"].distribution_effectivity_bonus_per_quality_level = nil

-- if other mods edit this list it should be done before data-final-fixes since we generate tooltips with it there.
data:extend{{
  type = "mod-data",
  name = data_util.mod_prefix .. "loses-quality-when-placed",
  data = {
    entities = {
      -- aai industry
      {type = "assembling-machine", name = "fuel-processor"},

      -- space exploration
      {type = "assembling-machine", name = data_util.mod_prefix .. "electric-boiler"},
      {type = "electric-pole"     , name = data_util.mod_prefix .. "addon-power-pole"},
      {type = "furnace"           , name = data_util.mod_prefix .. "condenser-turbine"},
      {type = "furnace"           , name = data_util.mod_prefix .. "kr-advanced-condenser-turbine"}, -- krastorio 2
      {type = "furnace"           , name = data_util.mod_prefix .. "big-turbine"},
    }
  },
}}

data.raw.recipe[data_util.mod_prefix .. "cargo-rocket-section-unpack"].allow_quality = false
data.raw.recipe[data_util.mod_prefix .. "cargo-rocket-section-packed"].allow_quality = false
