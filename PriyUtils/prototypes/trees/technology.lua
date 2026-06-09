data:extend(
{
  {
    type = "technology",
    name = "priyutils-tree-farming",
      icon = "__base__/graphics/icons/tree-01.png",
    icon_size = 64,
    effects = 
    {
      {
        type = "unlock-recipe",
        recipe = "priyutils-tree-seedling"
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
    name = "priyutils-forest-farming",
      icon = "__base__/graphics/icons/tree-01.png",
    icon_size = 64,
    effects = 
    {
      {
        type = "unlock-recipe",
        recipe = "priyutils-tree-forest"
      }
    },
    prerequisites = {"priyutils-tree-farming", "advanced-material-processing-2"},
    unit = 
    {
      count = 200,
      ingredients = --红绿灰蓝
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 45
    }
  }
}
)