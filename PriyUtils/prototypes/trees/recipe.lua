data:extend(
{
  {
    type = "recipe",
    name = "priyutils-tree-seedling",
    energy_required = 0.5,
    enabled = false,
    auto_recycle = false,
    category = "crafting-with-fluid",
    ingredients = 
    {
      {type = "item", name = "wood", amount = 1},
      {type = "fluid", name = "water", amount = 10}
    },
    results = {{type="item", name="priyutils-tree-seedling", amount=1}}
  },
  {
    type = "recipe",
    name = "priyutils-tree-forest",
    icon = "__base__/graphics/icons/tree-01.png",
    icon_size = 64,
    subgroup = "terrain",
    order = "z[priyutils-trees]-b[priyutils-tree-forest]",
    energy_required = 2,
    enabled = false,
    auto_recycle = false,
    category = "crafting-with-fluid",
    ingredients = 
    {
      {type = "item", name = "wood", amount = 5},
      {type = "fluid", name = "water", amount = 50},
      {type = "item", name = "coal", amount = 2} -- 使用煤作为替代
    },
    results = {{
      type = "item", name="priyutils-tree-forest", amount=2, probability = 0.9, show_details_in_recipe_tooltip = false
    },{
      type = "item", name="priyutils-tree-seedling", amount=1, probability = 0.1, show_details_in_recipe_tooltip = false
    }}
  }
}
)