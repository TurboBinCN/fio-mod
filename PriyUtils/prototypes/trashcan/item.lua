local item_sounds = require("__base__.prototypes.item_sounds")

local trashcan_item = {
    type = "item",
    name = "priyutils-trashcan",
    icon = "__PriyUtils__/graphics/icons/trashcan/reverse-factory-1.png",
    icon_size = 64,
    subgroup = "smelting-machine",
    order = "d[priyutils-trashcan]-1",
    inventory_move_sound = item_sounds.electric_large_inventory_move,
    pick_sound = item_sounds.electric_large_inventory_pickup,
    drop_sound = item_sounds.electric_large_inventory_move,
    se_allow_in_space = true,
    place_result = "priyutils-trashcan",
    stack_size = 10
}

local advanced_trashcan_item = {
    type = "item",
    name = "priyutils-advanced-trashcan",
    icon = "__PriyUtils__/graphics/icons/trashcan/reverse-factory-3.png",
    icon_size = 64,
    subgroup = "smelting-machine",
    order = "d[priyutils-trashcan]-2",
    inventory_move_sound = item_sounds.electric_large_inventory_move,
    pick_sound = item_sounds.electric_large_inventory_pickup,
    drop_sound = item_sounds.electric_large_inventory_move,
    place_result = "priyutils-advanced-trashcan",
    se_allow_in_space = true,
    stack_size = 10
}

data:extend({
    trashcan_item,
    advanced_trashcan_item
})