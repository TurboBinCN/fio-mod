require ("prototypes.equipment.equipment")
require ("prototypes.dugwater.dugwater")
require ("prototypes.inserter.inserter")
require ("prototypes.warehouse.warehouse")

if mods["space-exploration"] then
  require("prototypes.buildings.space-loader")
  
  if data.raw.furnace["priyutils-trashcan"] then
    data.raw.furnace["priyutils-trashcan"].se_allow_in_space = true
  end
  if data.raw.furnace["priyutils-advanced-trashcan"] then
    data.raw.furnace["priyutils-advanced-trashcan"].se_allow_in_space = true
  end
  if data.raw.furnace["priyutils-void-tank"] then
    data.raw.furnace["priyutils-void-tank"].se_allow_in_space = true
  end
end
if not mods["Krastorio2"] then
  require("prototypes.buildings.logistic-upgrade")
end

