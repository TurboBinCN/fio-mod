data:extend({
  {
    type = "technology",
    name = "priy-loader",
    icon = "__PriyUtils__/graphics/icons/entities/loader.png",
    icon_size = 64,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "priy-loader"
      }
    },
    prerequisites = {"logistics", "automation"},
    unit = {
      count = 50,
      ingredients = {
        {"automation-science-pack", 1}
      },
      time = 30
    },
    order = "a-b-c"
  },
  {
    type = "technology",
    name = "priy-fast-loader",
    icon = "__PriyUtils__/graphics/icons/entities/fast-loader.png",
    icon_size = 64,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "priy-fast-loader"
      }
    },
    prerequisites = {"priy-loader", "logistics-2"},
    unit = {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = "a-b-d"
  },
  {
    type = "technology",
    name = "priy-express-loader",
    icon = "__PriyUtils__/graphics/icons/entities/express-loader.png",
    icon_size = 64,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "priy-express-loader"
      }
    },
    prerequisites = {"priy-fast-loader", "logistics-3"},
    unit = {
      count = 200,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 45
    },
    order = "a-b-e"
  },
  {
    type = "technology",
    name = "priy-advanced-loader",
    icon = "__PriyUtils__/graphics/icons/entities/advanced-loader.png",
    icon_size = 64,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "priy-advanced-loader"
      }
    },
    prerequisites = {"priy-express-loader", "automation-2"},
    unit = {
      count = 300,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 60
    },
    order = "a-b-f"
  },
  {
    type = "technology",
    name = "priy-superior-loader",
    icon = "__PriyUtils__/graphics/icons/entities/superior-loader.png",
    icon_size = 64,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "priy-superior-loader"
      }
    },
    prerequisites = {"priy-advanced-loader", "logistic-system"},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 90
    },
    order = "a-b-g"
  }
})