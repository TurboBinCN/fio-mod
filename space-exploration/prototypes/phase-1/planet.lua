local data_util = require("data_util")

if not mods["space-age"] then
  data.raw["planet"]["nauvis"].icon = data.raw["virtual-signal"][data_util.mod_prefix .. "planet"].icon
end
