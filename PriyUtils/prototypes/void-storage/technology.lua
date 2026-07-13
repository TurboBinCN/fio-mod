local void_storage_technology = {
    type = "technology",
    name = "priyutils-void-storage",
    icon = "__PriyUtils__/graphics/icons/cartoonbox.png",
    icon_size = 128,
    order = "e-a",
    prerequisites = {
        "steel-processing",
        "circuit-network"
    },
    effects = {
        {type = "unlock-recipe", recipe = "priyutils-void-container"},
        {type = "unlock-recipe", recipe = "priyutils-void-tank"}
    },
    unit = {
        count = 100,
        time = 30,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        }
    },
    enabled = true
}

data:extend({
    void_storage_technology
})