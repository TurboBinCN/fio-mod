local data_util = require("data_util")

data:extend({
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "fuel-refinery",
    icon = "__space-exploration-graphics__/graphics/icons/fuel-refinery.png",
    icon_size = 64,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "fuel-refinery"},
    max_health = 350,
    dying_explosion = "medium-explosion",
    corpse = "oil-refinery-remnants",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    se_allow_in_space = true,
    drawing_box_vertical_extension = 0.3,
    module_slots = 3,
    scale_entity_info_icon = true,
    allowed_effects = data_util.all_effects(),
    crafting_categories = {"fuel-refining"},
    crafting_speed = 1,
    has_backer_name = false,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {1,1}, shadow_offset = {1,1}, show_shadow = true },
        { variation = 18, main_offset = {1,1}, shadow_offset = {1,1}, show_shadow = true },
        { variation = 18, main_offset = {1,1}, shadow_offset = {1,1}, show_shadow = true },
        { variation = 18, main_offset = {1,1}, shadow_offset = {1,1}, show_shadow = true },
      }
    ),
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 6 }
    },
    energy_usage = "1000kW",
    graphics_set = {
      animation = make_4way_animation_from_spritesheet({ layers =
      {
        {
          filename = "__space-exploration-graphics-5__/graphics/entity/fuel-refinery/fuel-refinery.png",
          width = 386,
          height = 430,
          frame_count = 1,
          shift = util.by_pixel(0, -7.5),
          scale = 0.5
        },
        {
          filename = "__space-exploration-graphics-5__/graphics/entity/fuel-refinery/fuel-refinery-shadow.png",
          width = 674,
          height = 426,
          frame_count = 1,
          shift = util.by_pixel(82.5, 26.5),
          draw_as_shadow = true,
          scale = 0.5
        }
      }}),
      working_visualisations =
      {
        {
          north_position = util.by_pixel(34, -65),
          east_position = util.by_pixel(-52, -61),
          south_position = util.by_pixel(-59, -82),
          west_position = util.by_pixel(57, -58),
          animation =
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/fuel-refinery/fuel-refinery-fire.png",
            line_length = 10,
            width = 40,
            height = 81,
            frame_count = 60,
            animation_speed = 0.75,
            scale = 0.5,
            shift = util.by_pixel(0, -14.25)
          },
          light = {intensity = 0.4, size = 6, color = {r = 1.0, g = 1.0, b = 1.0}}
        }
      },
    },
    impact_category = "metal",
    open_sound = data_util.machine_open_sound,
    e_sound = data_util.machine_close_sound,
    working_sound =
    {
      sound = { filename = "__base__/sound/oil-refinery.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 100 * 10,

        pipe_connections = {{ flow_direction="input", position = {-1, 2}, direction = defines.direction.south }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 100 * 10,

        pipe_connections = {{ flow_direction="input", position = {1, 2}, direction = defines.direction.south }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 100,
        pipe_connections = {{ position = {-2, -2}, direction = defines.direction.north }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 100,
        pipe_connections = {{ position = {0, -2}, direction = defines.direction.north }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 100,
        pipe_connections = {{ position = {2, -2}, direction = defines.direction.north }}
      }
    }
  },
})
