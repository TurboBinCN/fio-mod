local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local water_tile_condition = {"landfill", "grass-1", "grass-2", "grass-3", "grass-4", "dry-dirt", "dirt-1", "dirt-2", "dirt-3", "dirt-4", "dirt-5", "dirt-6", "dirt-7", "sand-1", "sand-2", "sand-3", "red-desert-0", "red-desert-1", "red-desert-2", "red-desert-3", "nuclear-ground"}
local super_tile_condition = {"landfill", "grass-1", "grass-2", "grass-3", "grass-4", "dry-dirt", "dirt-1", "dirt-2", "dirt-3", "dirt-4", "dirt-5", "dirt-6", "dirt-7", "sand-1", "sand-2", "sand-3", "red-desert-0", "red-desert-1", "red-desert-2", "red-desert-3", "nuclear-ground"}

data:extend(
{
  {
    type = "item",
    name = "priyutils-dug-water", --普通挖水材料
    icon = "__PriyUtils__/graphics/icons/dug-water.png",
    icon_size = 128,
    subgroup = "terrain",
    order = "z[priyutils-dug]-a[priyutils-dug-water]",
    inventory_move_sound = item_sounds.landfill_inventory_move,
    pick_sound = item_sounds.landfill_inventory_pickup,
    drop_sound = item_sounds.landfill_inventory_move,
    stack_size = 2400,
    weight = 20*kg,
    place_as_tile =
    {
      result = "water",
      condition_size = 1,
      condition = {layers={water_tile=true}},
      -- tile_condition = water_tile_condition
    },
    random_tint_color = item_tints.organic_green
  },
  {
    type = "item",
    name = "priyutils-dug-water-super", --超级挖水材料
    icon = "__PriyUtils__/graphics/icons/dug-water-super.png",
    icon_size = 128,
    subgroup = "terrain",
    order = "z[priyutils-dug]-b[priyutils-dug-water-super]",
    inventory_move_sound = item_sounds.landfill_inventory_move,
    pick_sound = item_sounds.landfill_inventory_pickup,
    drop_sound = item_sounds.landfill_inventory_move,
    stack_size = 2400,
    weight = 20*kg,
    place_as_tile =
    {
      result = "water",
      condition_size = 1,
      condition = {layers={water_tile=true}},
      -- tile_condition = super_tile_condition
    },
    random_tint_color = item_tints.organic_green
  }
}
)

data.raw["item"]["landfill"].stack_size = 2400