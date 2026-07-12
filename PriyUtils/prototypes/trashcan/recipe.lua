local trashcan_recipe = {
    type = "recipe",
    name = "priyutils-trashcan",
    enabled = false,
    ingredients = {
        {type = "item", name = "iron-plate", amount = 10},
        {type = "item", name = "iron-gear-wheel", amount = 5},
        {type = "item", name = "electronic-circuit", amount = 3}
    },
    results = {{type = "item", name = "priyutils-trashcan", amount = 1}},
    energy_required = 5
}

local advanced_trashcan_recipe = {
    type = "recipe",
    name = "priyutils-advanced-trashcan",
    enabled = false,
    ingredients = {
        {type = "item", name = "priyutils-trashcan", amount = 1},
        {type = "item", name = "steel-plate", amount = 10},
        {type = "item", name = "copper-plate", amount = 5},
        {type = "item", name = "processing-unit", amount = 2}
    },
    results = {{type = "item", name = "priyutils-advanced-trashcan", amount = 1}},
    energy_required = 10
}

data:extend({
    trashcan_recipe,
    advanced_trashcan_recipe
})