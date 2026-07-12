local void_container_recipe = {
    type = "recipe",
    name = "priyutils-void-container",
    enabled = false,
    ingredients = {
        {type = "item", name = "steel-chest", amount = 1},
        {type = "item", name = "electronic-circuit", amount = 10},
        {type = "item", name = "iron-plate", amount = 20}
    },
    energy_required = 10,
    results = {
        {type = "item", name = "priyutils-void-container", amount = 1}
    }
}

local void_tank_recipe = {
    type = "recipe",
    name = "priyutils-void-tank",
    enabled = false,
    ingredients = {
        {type = "item", name = "storage-tank", amount = 1},
        {type = "item", name = "electronic-circuit", amount = 10},
        {type = "item", name = "iron-plate", amount = 20}
    },
    energy_required = 10,
    results = {
        {type = "item", name = "priyutils-void-tank", amount = 1}
    }
}

data:extend({
    void_container_recipe,
    void_tank_recipe
})