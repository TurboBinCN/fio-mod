data:extend(
{
  {
    type = "recipe",
    name = "priyutils-dug-water",
    energy_required = 0.5,
    enabled = false,
    auto_recycle = false,
    category = "crafting-with-fluid",
    ingredients =
    {
      {type = "fluid", name = "water", amount = 50},
      {type = "item", name = "barrel", amount = 1}
    },
    results = {{type="item", name="priyutils-dug-water", amount=1}}
  },
  {
    type = "recipe",
    name = "priyutils-dug-water-super",
    icon = "__PriyUtils__/graphics/icons/dug-water-super.png",
    icon_size = 32,
    subgroup = "terrain",
    order = "z[priyutils-dug]-b[priyutils-dug-water-super]",
    energy_required = 2,
    enabled = false,
    auto_recycle = false,
    category = "crafting-with-fluid",
    ingredients =
    {
      {type = "fluid", name = "water", amount = 500},
      {type = "item", name = "barrel", amount = 1},
      {type = "item", name = "explosives", amount = 3}
    },
    results = {
      {type = "item", name="priyutils-dug-water-super", amount=1, probability = 0.9, show_details_in_recipe_tooltip = false},
      {type = "item", name="priyutils-dug-water", amount=1, probability = 0.1, show_details_in_recipe_tooltip = false}
    }
  }
}
)