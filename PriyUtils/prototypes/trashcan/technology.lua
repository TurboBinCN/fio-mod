local trashcan_tech = {
    type = "technology",
    name = "priyutils-trashcan",
    icon = "__PriyUtils__/graphics/icons/trashcan/reverse-factory-1.png",
    icon_size = 64,
    prerequisites = {"automation", "electric-energy-distribution-1"},
    effects = {
        {
            type = "unlock-recipe",
            recipe = "priyutils-trashcan"
        }
    },
    unit = {
        count = 30,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    },
    order = "a-d-b"
}

local advanced_trashcan_tech = {
    type = "technology",
    name = "priyutils-advanced-trashcan",
    icon = "__PriyUtils__/graphics/icons/trashcan/reverse-factory-3.png",
    icon_size = 64,
    prerequisites = {"priyutils-trashcan", "automation-2"},
    effects = {
        {
            type = "unlock-recipe",
            recipe = "priyutils-advanced-trashcan"
        }
    },
    unit = {
        count = 100,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    },
    order = "a-d-c"
}

data:extend({
    trashcan_tech,
    advanced_trashcan_tech
})