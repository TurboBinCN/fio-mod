local data_util = require("data_util")

local decontamination_target_animation_speed = 0.75
local decontamination_crafting_speed = 2
local decontamination_module_slots = 4
local decontamination_animation_speed = (decontamination_target_animation_speed / decontamination_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * decontamination_module_slots)

local lifesupport_target_animation_speed = 0.75
local lifesupport_crafting_speed = 1
local lifesupport_module_slots = 4
local lifesupport_animation_speed = (lifesupport_target_animation_speed / lifesupport_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * lifesupport_module_slots)

data:extend({
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-decontamination-facility",
    icon = "__space-exploration-graphics__/graphics/icons/decontamination-facility.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "space-decontamination-facility"},
    max_health = 700,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-2.8, -2.8}, {2.8, 2.8}},
    selection_box = {{-3, -3}, {3, 3}},
    drawing_box_vertical_extension = 0.5,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {2.5, 2.5}, shadow_offset = {2.5, 2.5}, show_shadow = true },
        { variation = 18, main_offset = {2.5, 2.5}, shadow_offset = {2.5, 2.5}, show_shadow = true },
        { variation = 18, main_offset = {2.5, 2.5}, shadow_offset = {2.5, 2.5}, show_shadow = true },
        { variation = 18, main_offset = {2.5, 2.5}, shadow_offset = {2.5, 2.5}, show_shadow = true },
      }
    ),
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    se_allow_in_space = true,
    resistances =
    {
      {
        type = "impact",
        percent = 10
      }
    },
    fluid_boxes = {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {-1.5, -2.5}, direction = defines.direction.north }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {1.5, -2.5}, direction = defines.direction.north }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {-2.5, -1.5}, direction = defines.direction.west }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {2.5, -1.5}, direction = defines.direction.east }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {-1.5, 2.5}, direction = defines.direction.south }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {1.5, 2.5}, direction = defines.direction.south }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {2.5, 1.5}, direction = defines.direction.east }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {-2.5, 1.5}, direction = defines.direction.west }},
        secondary_draw_orders = { north = -1 }
      },
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound = {
      apparent_volume = 1.5,
      idle_sound = {
        filename = "__base__/sound/idle1.ogg",
        volume = 0.6
      },
      sound = {
        {
          filename = "__base__/sound/assembling-machine-t1-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t1-2.ogg",
          volume = 0.8
        }
      }
    },
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
      },
    },
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/decontamination-facility/decontamination-facility.png",
            priority = "high",
            width = 3072/8,
            height = 1792/4,
            frame_count = 32,
            line_length = 8,
            shift = util.by_pixel(0, -16),
            animation_speed = decontamination_animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-5__/graphics/entity/decontamination-facility/decontamination-facility-shadow.png",
            priority = "high",
            width = 426,
            height = 298,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(26, 24),
            animation_speed = decontamination_animation_speed,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.5, size = 8, shift = {0.0, 0.0}, color = {r = 1, g = 0.9, b = 0.5}}
        },
      },
    },
    crafting_categories = {"space-decontamination"},
    crafting_speed = decontamination_crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "2000kW",
    module_slots = decontamination_module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "lifesupport-facility",
    icon = "__space-exploration-graphics__/graphics/icons/lifesupport-facility.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "lifesupport-facility"},
    max_health = 700,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-2.8, -2.8}, {2.8, 2.8}},
    se_allow_in_space = true,
    selection_box = {{-3, -3}, {3, 3}},
    drawing_box_vertical_extension = 0.5,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {2.5, 2.5}, shadow_offset = {2.5, 2.5}, show_shadow = true },
        { variation = 18, main_offset = {2.5, 2.5}, shadow_offset = {2.5, 2.5}, show_shadow = true },
        { variation = 18, main_offset = {2.5, 2.5}, shadow_offset = {2.5, 2.5}, show_shadow = true },
        { variation = 18, main_offset = {2.5, 2.5}, shadow_offset = {2.5, 2.5}, show_shadow = true },
      }
    ),
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
      {
        type = "impact",
        percent = 10
      }
    },
    fluid_boxes = {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {-1.5, -2.5}, direction = defines.direction.north }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {1.5, -2.5}, direction = defines.direction.north }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {-2.5, -1.5}, direction = defines.direction.west }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {2.5, -1.5}, direction = defines.direction.east }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {-1.5, 2.5}, direction = defines.direction.south }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {1.5, 2.5}, direction = defines.direction.south }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {2.5, 1.5}, direction = defines.direction.east }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {-2.5, 1.5}, direction = defines.direction.west }},
        secondary_draw_orders = { north = -1 }
      },
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound = {
      apparent_volume = 1.5,
      idle_sound = {
        filename = "__base__/sound/idle1.ogg",
        volume = 0.6
      },
      sound = {
        {
          filename = "__base__/sound/assembling-machine-t1-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t1-2.ogg",
          volume = 0.8
        }
      }
    },
    collision_mask = {
      layers = {
        water_tile = true,
        --ground_tile = true, -- allow on ground
        item = true,
        object = true,
        player = true,
      },
    },
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/lifesupport-facility/lifesupport-facility.png",
            priority = "high",
            width = 3072/8,
            height = 1792/4,
            frame_count = 32,
            line_length = 8,
            shift = util.by_pixel(0, -16),
            animation_speed = lifesupport_animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-5__/graphics/entity/lifesupport-facility/lifesupport-facility-shadow.png",
            priority = "high",
            width = 426,
            height = 298,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(26, 24),
            animation_speed = lifesupport_animation_speed,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.5, size = 8, shift = {0.0, 0.0}, color = {r = 100/255, g = 48/255, b = 1}}
        },
      },
    },
    crafting_categories = {"lifesupport"},
    crafting_speed = lifesupport_crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "1000kW",
    module_slots = lifesupport_module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },
})
