data:extend(
{
  {
    type = "technology",
    name = "priyutils-dug-water",
    icon = "__PriyUtils__/graphics/technology/dug-water.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "priyutils-dug-water"
      }
    },
    prerequisites = {"steel-axe", "fluid-handling"},
    unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    }
  },
  {
    type = "technology",
    name = "priyutils-dug-water-super",
    icon = "__PriyUtils__/graphics/technology/dug-water-super.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "priyutils-dug-water-super"
      }
    },
    prerequisites = {"priyutils-dug-water", "space-science-pack"},
    unit =
    {
      count = 500,
      ingredients = --红绿灰蓝白
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 60
    }
  }
}
)