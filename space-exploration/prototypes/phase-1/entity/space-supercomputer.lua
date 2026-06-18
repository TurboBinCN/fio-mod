local data_util = require("data_util")

local cpu1_target_animation_speed = 0.4
local cpu1_crafting_speed = 1
local cpu1_module_slots = 2
local cpu1_animation_speed = (cpu1_target_animation_speed / cpu1_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * cpu1_module_slots)

local cpu2_target_animation_speed = 0.5
local cpu2_crafting_speed = 2
local cpu2_module_slots = 4
local cpu2_animation_speed = (cpu2_target_animation_speed / cpu2_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * cpu2_module_slots)

local cpu3_target_animation_speed = 0.6
local cpu3_crafting_speed = 4
local cpu3_module_slots = 6
local cpu3_animation_speed = (cpu3_target_animation_speed / cpu3_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * cpu3_module_slots)

local cpu4_target_animation_speed = 0.5
local cpu4_crafting_speed = 6
local cpu4_module_slots = 8
local cpu4_animation_speed = (cpu4_target_animation_speed / cpu4_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * cpu4_module_slots)

local blank_image = {
    filename = "__space-exploration-graphics__/graphics/blank.png",
    width = 1,
    height = 1,
    frame_count = 1,
    line_length = 1,
    shift = { 0, 0 },
}
local pipe_pictures = {
  north = blank_image,
  east = {
    filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/pipe-right.png",
    width = 46,
    height = 68,
    priority = "extra-high",
    shift = util.by_pixel(-28, 2),
    scale = 0.5,
  },
  south = {
    filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/pipe-bottom.png",
    width = 84,
    height = 58,
    priority = "extra-high",
    shift = util.by_pixel(1, -30),
    scale = 0.5,
  },
  west = {
    filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/pipe-left.png",
    width = 46,
    height = 74,
    priority = "extra-high",
    shift = util.by_pixel(28, 3),
    scale = 0.5,
  }
}
data:extend({
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-supercomputer-1",
    icon = "__space-exploration-graphics__/graphics/icons/supercomputer-1.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = { mining_time = 0.1, result = data_util.mod_prefix .. "space-supercomputer-1"},
    fast_replaceable_group = data_util.mod_prefix .. "space-supercomputer",
    next_upgrade = data_util.mod_prefix .. "space-supercomputer-2",
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, 0),
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
      }
    ),
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
    },
    fluid_boxes = {
      {
          production_type = "input",
          pipe_picture = pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {0, -2}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {0, 2}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/lab.ogg",
          volume = 0.7
        },
      },
      apparent_volume = 1,
    },
    collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
      },
    },
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box_vertical_extension = 1.5,
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-1.png",
            priority = "high",
            width = 320,
            height = 384,
            frame_count = 1,
            shift = util.by_pixel(-0, -16),
            animation_speed = cpu1_animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-shadow.png",
            priority = "high",
            width = 264,
            height = 234,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(75, 23),
            animation_speed = cpu1_animation_speed,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.6, size = 16, shift = {0.0, 0.0}, color = {r = 1, g = 0.2, b = 0.1}}
        },
        {
          animation = {
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-1-working.png",
            priority = "high",
            width = 720/9,
            height = 258,
            frame_count = 9,
            shift = util.by_pixel(-0, -25),
            animation_speed = cpu1_animation_speed,
            scale = 0.5,
          },
        }
      },
    },
    crafting_categories = {"space-supercomputing-1"},
    crafting_speed = cpu1_crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "1000kW",
    module_slots = cpu1_module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },

  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-supercomputer-2",
    icon = "__space-exploration-graphics__/graphics/icons/supercomputer-2.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = data_util.mod_prefix .. "space-supercomputer-2"},
    fast_replaceable_group = data_util.mod_prefix .. "space-supercomputer",
    next_upgrade = data_util.mod_prefix .. "space-supercomputer-3",
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, 0),
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
      }
    ),
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
    },
    fluid_boxes = {
      {
          production_type = "input",
          pipe_picture = pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {0, -2}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {0, 2}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/lab.ogg",
          volume = 0.7
        },
      },
      apparent_volume = 1,
    },
    collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
      },
    },
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box_vertical_extension = 1.5,
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-2.png",
            priority = "high",
            width = 320,
            height = 384,
            frame_count = 1,
            shift = util.by_pixel(-0, -16),
            animation_speed = cpu2_animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-shadow.png",
            priority = "high",
            width = 264,
            height = 234,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(75, 23),
            animation_speed = cpu2_animation_speed,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.6, size = 16, shift = {0.0, 0.0}, color = {r = 1, g = 1, b = 0.1}}
        },
        {
          animation = {
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-2-working.png",
            priority = "high",
            width = 720/9,
            height = 258,
            frame_count = 9,
            shift = util.by_pixel(-0, -25),
            animation_speed = cpu2_animation_speed,
            scale = 0.5,
          },
        }
      },
    },
    crafting_categories = {"space-supercomputing-1", "space-supercomputing-2"},
    crafting_speed = cpu2_crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "2500kW",
    module_slots = cpu2_module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-supercomputer-3",
    icon = "__space-exploration-graphics__/graphics/icons/supercomputer-3.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = data_util.mod_prefix .. "space-supercomputer-3"},
    fast_replaceable_group = data_util.mod_prefix .. "space-supercomputer",
    next_upgrade = data_util.mod_prefix .. "space-supercomputer-4",
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, 0),
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
      }
    ),
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
    },
    fluid_boxes = {
      {
          production_type = "input",
          pipe_picture = pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {0, -2}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {0, 2}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/lab.ogg",
          volume = 0.7
        },
      },
      apparent_volume = 1,
    },
    collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
      },
    },
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box_vertical_extension = 1.5,
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-3.png",
            priority = "high",
            width = 320,
            height = 384,
            frame_count = 1,
            shift = util.by_pixel(-0, -16),
            animation_speed = cpu3_animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-shadow.png",
            priority = "high",
            width = 264,
            height = 234,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(75, 23),
            animation_speed = cpu3_animation_speed,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.6, size = 16, shift = {0.0, 0.0}, color = {r = 0.1, g = 1, b = 1}}
        },
        {
          animation = {
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-3-working.png",
            priority = "high",
            width = 720/9,
            height = 258,
            frame_count = 9,
            shift = util.by_pixel(-0, -25),
            animation_speed = cpu3_animation_speed,
            scale = 0.5,
          },
        }
      },
    },
    crafting_categories = {"space-supercomputing-1", "space-supercomputing-2", "space-supercomputing-3"},
    crafting_speed = cpu3_crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "5000kW",
    module_slots = cpu3_module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },

  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-supercomputer-4",
    icon = "__space-exploration-graphics__/graphics/icons/supercomputer-4.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = data_util.mod_prefix .. "space-supercomputer-4"},
    fast_replaceable_group = data_util.mod_prefix .. "space-supercomputer",
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, 0),
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
        { variation = 18, main_offset = {1, 2}, shadow_offset = {1, 2}, show_shadow = true },
      }
    ),
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
    },
    fluid_boxes = {
      {
          production_type = "input",
          pipe_picture = pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {0, -2}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {0, 2}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/lab.ogg",
          volume = 0.7
        },
      },
      apparent_volume = 1,
    },
    collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
      },
    },
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box_vertical_extension = 1.5,
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-4.png",
            priority = "high",
            width = 320,
            height = 384,
            frame_count = 1,
            shift = util.by_pixel(-0, -16),
            animation_speed = cpu4_animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-shadow.png",
            priority = "high",
            width = 264,
            height = 234,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(75, 23),
            animation_speed = cpu4_animation_speed,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.8, size = 16, shift = {0.0, 0.0}, color = {r = 0.3, g = 0.1, b = 1}}
        },
        {
          animation = {
            filename = "__space-exploration-graphics-5__/graphics/entity/supercomputer/supercomputer-4-working.png",
            priority = "high",
            width = 504/4,
            height = 1064/4,
            line_length = 4,
            frame_count = 16,
            shift = util.by_pixel(-0, -22),
            animation_speed = cpu4_animation_speed,
            blend_mode = "additive",
            draw_as_glow = true,
            max_advance = 1,
            scale = 0.5,
          },
        },
      },
    },
    crafting_categories = {"space-supercomputing-1", "space-supercomputing-2", "space-supercomputing-3", "space-supercomputing-4"},
    crafting_speed = cpu4_crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "10000kW",
    module_slots = cpu4_module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  }
})
