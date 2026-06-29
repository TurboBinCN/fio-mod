data:extend({
    {
        type = "recipe",
        name = "kr-large-roboport",
        energy_required = 30,
        enabled = false,
        ingredients = {
          { type="item", name="steel-plate", amount=80 },
          { type="item", name="concrete", amount=100 },
          { type="item", name="iron-gear-wheel", amount=80 },
          { type="item", name="low-density-structure", amount=80 },
          { type="item", name="processing-unit", amount=20 },
          { type="item", name="roboport", amount=1 },
        },
        results = {
          { type="item", name="kr-large-roboport", amount=1 }
        },
    },
    {
        type = "recipe",
        name = "kr-small-roboport",
        energy_required = 5,
        enabled = false,
        ingredients = {
          { type="item", name="concrete", amount=25 },
          { type="item", name="steel-plate", amount=10 },
          { type="item", name="low-density-structure", amount=20 },
          { type="item", name="processing-unit", amount=2 },
          { type="item", name="advanced-circuit",  amount=5 },
        },
        results = {
          { type="item", name="kr-small-roboport", amount=2 }
        },
    },
})
