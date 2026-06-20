data:extend({
  {
    type = "technology",
    name = "kr-logistic-4",
    icon = "__PriyUtils__/graphics/technology/advanced-logistics.png",
    icon_size = 256,
    icon_mipmaps = 4,
    order = "c-a",
    unit = {
      time = 30,
      count = 200,
      ingredients = {
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
        { "utility-science-pack", 1 },
      },
    },
    prerequisites = { "logistics-3", "utility-science-pack" },
    effects = {
      { type = "unlock-recipe", recipe = "kr-advanced-splitter" },
      { type = "unlock-recipe", recipe = "kr-advanced-transport-belt" },
      { type = "unlock-recipe", recipe = "kr-advanced-underground-belt" },
    },
  },
  {
    type = "technology",
    name = "kr-logistic-5",
    icon = "__PriyUtils__/graphics/technology/superior-logistics.png",
    icon_size = 256,
    icon_mipmaps = 4,
    order = "c-b",
    unit = {
      time = 30,
      count = 300,
      ingredients = {
        { "production-science-pack", 1 },
        { "utility-science-pack", 1 },
      },
    },
    prerequisites = { "kr-logistic-4" },
    effects = {
      { type = "unlock-recipe", recipe = "kr-superior-splitter" },
      { type = "unlock-recipe", recipe = "kr-superior-transport-belt" },
      { type = "unlock-recipe", recipe = "kr-superior-underground-belt" },
    },
  },
})
