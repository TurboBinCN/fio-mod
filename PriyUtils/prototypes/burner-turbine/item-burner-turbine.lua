local sounds = require("__base__.prototypes.entity.sounds")

data:extend({
  {
    type = "item",
    name = "burner-turbine",
    icon = "__PriyUtils__/graphics/icons/burner-turbine.png",
    icon_size = 64,
    subgroup = "energy",
    order = "b[steam-power]-c[burner-turbine]",
    place_result = "burner-turbine",
    stack_size = 10,
  },
})