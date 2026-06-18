local data_util = require("data_util")

local target_animation_speed = 0.5
local crafting_speed = 4
local module_slots = 4
local animation_speed = (target_animation_speed / crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * module_slots)

data:extend({
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-genetics-laboratory",
    icon = "__space-exploration-graphics__/graphics/icons/genetics-laboratory.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "space-genetics-laboratory"},
    max_health = 1200,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-3.3, -3.3}, {3.3, 3.3}},
    selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
    drawing_box_vertical_extension = 0.4,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {2, 3}, shadow_offset = {2, 3}, show_shadow = true },
        { variation = 18, main_offset = {2, 3}, shadow_offset = {2, 3}, show_shadow = true },
        { variation = 18, main_offset = {2, 3}, shadow_offset = {2, 3}, show_shadow = true },
        { variation = 18, main_offset = {2, 3}, shadow_offset = {2, 3}, show_shadow = true },
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
        pipe_connections = {{ flow_direction="input", position = {0, -3}, direction = defines.direction.north }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {-3, 0}, direction = defines.direction.west }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {0, 3}, direction = defines.direction.south }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {3, 0}, direction = defines.direction.east }},
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
          filename = "__base__/sound/chemical-plant.ogg",
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
        [spaceship_collision_layer] = true,
      },
    },
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__space-exploration-graphics-2__/graphics/entity/genetics-laboratory/genetics-laboratory.png",
            priority = "high",
            width = 3584/8,
            height = 2048/4,
            frame_count = 32,
            line_length = 8,
            shift = util.by_pixel(0, -16),
            animation_speed = animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-2__/graphics/entity/genetics-laboratory/genetics-laboratory-shadow.png",
            priority = "high",
            width = 604,
            height = 302,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(40, 8),
            animation_speed = 0.5,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.5, size = 8, shift = {0.0, 0.0}, color = {r = 0.7, g = 0.8, b = 1}}
        },
      },
    },
    crafting_categories = {"space-genetics"},
    crafting_speed = crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 }
    },
    energy_usage = "1000kW",
    module_slots = module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },
})
