require ("prototypes.equipment.equipment")
require ("prototypes.pump.pump")
require ("prototypes.dugwater.dugwater")
require ("prototypes.inserter.inserter")
require ("prototypes.warehouse.warehouse")

-- Space Exploration compatibility - loaded in data-updates because SE entities aren't available in data.lua
if mods["space-exploration"] then
  require("prototypes.buildings.space-loader")
end