local hit_effects = require("__base__/prototypes/entity/hit-effects")

-- 定义电池组的充电逻辑
data:extend({
  {
    type = "battery-equipment",
    name = "battery-mk2-equipment",
    sprite = {
      filename = "__base__/graphics/equipment/battery-mk2-equipment.png",
      width = 64,
      height = 128,
      priority = "medium",
      scale = 0.5
    },
    shape = {
      width = 1,
      height = 1,
      type = "full"
    },
    energy_source = {
      type = "electric",
      buffer_capacity = "100MJ",
      input_flow_limit = "50MW", -- 设置最大输入功率
      usage_priority = "tertiary"
    },
    categories = {"armor"}
  }
})
