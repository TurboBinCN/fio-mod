if not mods["space-exploration"] then
  return
end

local sounds = require("__base__.prototypes.entity.sounds")

local graphics = require("prototypes.buildings.loader-graphics")

data:extend({
  {
    type = "recipe",
    name = "priy-space-loader",
    category = data.raw.recipe["se-space-splitter"].category,
    energy_required = data.raw.recipe["se-space-splitter"].energy_required,
    enabled = false,
    ingredients = {
      { type = "item", name = "low-density-structure", amount = 2 },
      { type = "item", name = "electric-engine-unit", amount = 1 },
      { type = "item", name = "processing-unit", amount = 2 },
      { type = "fluid", name = "lubricant", amount = 10 },
      { type = "item", name = "se-space-transport-belt", amount = 1 },
    },
    results = {
      { type = "item", name = "priy-space-loader", amount = 1 },
    },
    subgroup = "belt",
  },
  {
    type = "item",
    name = "priy-space-loader",
    icon = "__PriyUtils__/graphics/icons/entities/se-space-loader.png",
    icon_size = 64,
    order = "d[loader]-a6[priy-space-loader]",
    subgroup = "belt",
    place_result = "priy-space-loader",
    stack_size = 50,
  },
  {
    type = "loader-1x1",
    name = "priy-space-loader",
    icon = "__PriyUtils__/graphics/icons/entities/se-space-loader.png",
    icon_size = 64,
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 0.25, result = "priy-space-loader" },
    placeable_by = { item = "priy-space-loader", count = 1 },
    max_health = 300,
    filter_count = 5,
    next_upgrade = "priy-deep-space-loader",
    corpse = "small-remnants",
    resistances = {
      { type = "fire", percent = 90 },
    },
    collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
    selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    animation_speed_coefficient = 32,
    icon_draw_specification = { scale = 0.7 },
    container_distance = 1,
    structure_render_layer = graphics.structure_render_layer,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    belt_animation_set = data.raw["transport-belt"]["se-space-transport-belt"].belt_animation_set,
    fast_replaceable_group = data.raw["transport-belt"]["se-space-transport-belt"].fast_replaceable_group,
    speed = data.raw["transport-belt"]["se-space-transport-belt"].speed,
    se_allow_in_space = true,
    structure = graphics.structure({ 240 / 255, 240 / 255, 240 / 255 }),
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "1.5kW",
    },
    energy_per_item = "9kJ",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
  },
  {
    type = "recipe",
    name = "priy-deep-space-loader",
    category = data.raw.recipe["se-deep-space-splitter-black"].category,
    energy_required = data.raw.recipe["se-deep-space-splitter-black"].energy_required,
    enabled = false,
    ingredients = {
      { type = "item", name = "se-naquium-cube", amount = 1 },
      { type = "item", name = "priy-space-loader", amount = 50 },
      { type = "fluid", name = "lubricant", amount = 10 },
      { type = "item", name = "se-deep-space-transport-belt-black", amount = 2 },
      { type = "item", name = "se-nanomaterial", amount = 1 },
      { type = "item", name = "se-heavy-assembly", amount = 1 },
      { type = "item", name = "se-quantum-processor", amount = 1 },
    },
    results = {
      { type = "item", name = "priy-deep-space-loader", amount = 50 },
    },
    subgroup = "belt",
  },
  {
    type = "item",
    name = "priy-deep-space-loader",
    icon = "__PriyUtils__/graphics/icons/entities/se-deep-space-loader.png",
    icon_size = 64,
    order = "d[loader]-a7[priy-deep-space-loader]",
    subgroup = "belt",
    place_result = "priy-deep-space-loader",
    stack_size = 50,
  },
  {
    type = "loader-1x1",
    name = "priy-deep-space-loader",
    icon = "__PriyUtils__/graphics/icons/entities/se-deep-space-loader.png",
    icon_size = 64,
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 0.25, result = "priy-deep-space-loader" },
    placeable_by = { item = "priy-deep-space-loader", count = 1 },
    max_health = 300,
    filter_count = 5,
    corpse = "small-remnants",
    resistances = {
      { type = "fire", percent = 90 },
    },
    collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
    selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    animation_speed_coefficient = 32,
    icon_draw_specification = { scale = 0.7 },
    container_distance = 1,
    structure_render_layer = graphics.structure_render_layer,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    belt_animation_set = data.raw["transport-belt"]["se-deep-space-transport-belt-black"].belt_animation_set,
    fast_replaceable_group = data.raw["transport-belt"]["se-deep-space-transport-belt-black"].fast_replaceable_group,
    speed = data.raw["transport-belt"]["se-deep-space-transport-belt-black"].speed,
    se_allow_in_space = true,
    structure = graphics.structure({ 25 / 255, 25 / 255, 25 / 255 }),
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "2kW",
    },
    energy_per_item = "9kJ",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
  },
})

if data.raw.technology["se-space-belt"] then
  table.insert(data.raw.technology["se-space-belt"].effects, {
    type = "unlock-recipe",
    recipe = "priy-space-loader"
  })
end

if data.raw.technology["se-deep-space-transport-belt"] then
  table.insert(data.raw.technology["se-deep-space-transport-belt"].effects, {
    type = "unlock-recipe",
    recipe = "priy-deep-space-loader"
  })
end