local data_util = require("data_util")

if feature_flags["freezing"] then

  -- they can withstand the cold of deep space already anyways (space pipes were immune already)
  data.raw["transport-belt"][data_util.mod_prefix .. "space-transport-belt"].heating_energy = nil
  data.raw["splitter"][data_util.mod_prefix .. "space-splitter"].heating_energy = nil
  data.raw["underground-belt"][data_util.mod_prefix .. "space-underground-belt"].heating_energy = nil

end
