local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
--local tree_tile_condition = {"landfill", "grass-1", "grass-2", "grass-3", "grass-4", "dry-dirt", "dirt-1", "dirt-2", "dirt-3", "dirt-4", "dirt-5", "dirt-6", "dirt-7", "sand-1", "sand-2", "sand-3", "red-desert-0", "red-desert-1", "red-desert-2", "red-desert-3", "nuclear-ground", "out-of-map", "stone-path", "lab-dark-1", "lab-dark-2", "lab-white", "tutorial-grid", "concrete", "hazard-concrete-left", "hazard-concrete-right", "refined-concrete", "refined-hazard-concrete-left", "refined-hazard-concrete-right"}
--local tree_tile_condition = {"landfill", "grass-1", "grass-2", "grass-3", "grass-4", "dry-dirt", "dirt-1", "dirt-2", "dirt-3", "dirt-4", "dirt-5", "dirt-6", "dirt-7", "sand-1", "sand-2", "sand-3", "red-desert-0", "red-desert-1", "red-desert-2", "red-desert-3", "nuclear-ground"}

data:extend(
{
  {
    type = "item",
    name = "priyutils-tree-seedling", --普通树苗
    icon = "__base__/graphics/icons/tree-01.png",
    icon_size = 64,
    subgroup = "terrain",
    order = "z[priyutils-trees]-a[priyutils-tree-seedling]",
    inventory_move_sound = item_sounds.landfill_inventory_move,
    pick_sound = item_sounds.landfill_inventory_pickup,
    drop_sound = item_sounds.landfill_inventory_move,
    stack_size = 2400,
    weight = 20*kg,
    place_as_tile = 
    {
        result = "grass-2",
      condition_size = 1,
      condition = {layers={water_tile=true}},
      --tile_condition = tree_tile_condition
    },
    random_tint_color = item_tints.organic_green
  },
  {
    type = "item",
    name = "priyutils-tree-forest", --森林种子
    icon = "__base__/graphics/icons/tree-01.png",
    icon_size = 64,
    subgroup = "terrain",
    order = "z[priyutils-trees]-b[priyutils-tree-forest]",
    inventory_move_sound = item_sounds.landfill_inventory_move,
    pick_sound = item_sounds.landfill_inventory_pickup,
    drop_sound = item_sounds.landfill_inventory_move,
    stack_size = 2400,
    weight = 20*kg,
    place_as_tile = 
    {
      result = "grass-4",
      condition_size = 1,
      condition = {layers={water_tile=true}}
    },
    random_tint_color = item_tints.organic_green
  }
}
)