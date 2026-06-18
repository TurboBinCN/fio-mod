local data_util = require("data_util")

local target_animation_speed = 0.5
local crafting_speed = 4
local module_slots = 4
local animation_speed = (target_animation_speed / crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * module_slots)

local pipe_pics = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"].fluid_boxes[1].pipe_picture)
data_util.replace_filenames_recursive(pipe_pics,
  "__base__",
  "__space-exploration-graphics__")
data_util.replace_filenames_recursive(pipe_pics,
  "assembling-machine-3",
  "assembling-machine")


data:extend({
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-growth-facility",
    icon = "__space-exploration-graphics__/graphics/icons/growth-facility.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "space-growth-facility"},
    max_health = 1500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-4.3, -4.3}, {4.3, 4.3}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    drawing_box_vertical_extension = 0.4,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {1,4}, shadow_offset = {1,4}, show_shadow = true },
        { variation = 18, main_offset = {1,4}, shadow_offset = {1,4}, show_shadow = true },
        { variation = 18, main_offset = {1,4}, shadow_offset = {1,4}, show_shadow = true },
        { variation = 18, main_offset = {1,4}, shadow_offset = {1,4}, show_shadow = true },
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
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {-4, 2}, direction = defines.direction.west }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {-2, -4}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {-4, 0}, direction = defines.direction.west }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {0, -4}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {-4, -2}, direction = defines.direction.west }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {2, -4}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {-2, 4}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {4, 2}, direction = defines.direction.east }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {0, 4}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {4, 0}, direction = defines.direction.east }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {2, 4}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {4, -2}, direction = defines.direction.east }},
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
            filename = "__space-exploration-graphics-3__/graphics/entity/growth-facility/growth-facility.png",
            priority = "high",
            width = 4032/7,
            height = 3360/5,
            frame_count = 32,
            line_length = 7,
            shift = util.by_pixel(0, -24),
            animation_speed = animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-3__/graphics/entity/growth-facility/growth-facility-shadow.png",
            priority = "high",
            width = 618,
            height = 570,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(8, 2),
            animation_speed = animation_speed,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.5, size = 24, shift = {0.0, 0.0}, color = {r = 0.7, g = 0.8, b = 1}}
        },
      },
    },
    crafting_categories = {"space-growth"},
    crafting_speed = crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "4000kW",
    module_slots = module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },
})
