data:extend({
    {
        type = "technology",
        name = "kr-advanced-roboports",
        icon = "__PriyUtils__/graphics/technology/advanced-roboports.png",
        icon_size = 256,
        icon_mipmaps = 4,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "kr-small-roboport",
            },
            {
                type = "unlock-recipe",
                recipe = "kr-large-roboport",
            },
        },
        prerequisites = {"utility-science-pack", "production-science-pack","logistic-robotics","construction-robotics","concrete"},
        unit = {
          count = 500,
          ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 1 },
            { "chemical-science-pack", 1 },
            { "production-science-pack", 1 },
            { "utility-science-pack", 1 },
          },
          time = 60,
        },
    },
})
