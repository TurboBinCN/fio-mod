local sounds = require("__base__/prototypes/item_sounds")

local void_container_item = {
    type = "item",
    name = "priyutils-void-container",
    icon = "__PriyUtils__/graphics/icons/cartoonbox.png",
    icon_size = 128,
    subgroup = "storage",
    order = "a[items]-e[priyutils-void-container]",
    inventory_move_sound = sounds.metal_chest_inventory_move,
    pick_sound = sounds.metal_chest_inventory_pickup,
    drop_sound = sounds.metal_chest_inventory_move,
    place_result = "priyutils-void-container",
    stack_size = 50
}

local void_tank_item = {
    type = "item",
    name = "priyutils-void-tank",
    icon = "__base__/graphics/icons/cartooncup.png",
    icon_size = 128,
    subgroup = "storage",
    order = "b[fluids]-b[priyutils-void-tank]",
    inventory_move_sound = sounds.metal_large_inventory_move,
    pick_sound = sounds.metal_large_inventory_pickup,
    drop_sound = sounds.metal_large_inventory_move,
    place_result = "priyutils-void-tank",
    stack_size = 50
}

data:extend({
    void_container_item,
    void_tank_item
})