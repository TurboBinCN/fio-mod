local data_util = require("data_util")

local astrometric_target_animation_speed = 1
local astrometric_crafting_speed = 1
local astrometric_module_slots = 4
local astrometric_animation_speed = (astrometric_target_animation_speed / astrometric_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * astrometric_module_slots)

local gravimetric_target_animation_speed = 0.75
local gravimetric_crafting_speed = 1
local gravimetric_module_slots = 4
local gravimetric_animation_speed = (gravimetric_target_animation_speed / gravimetric_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * gravimetric_module_slots)

local astrometrics_pipe_pictures = {
  north = {
    filename = "__space-exploration-graphics-4__/graphics/entity/astrometrics-laboratory/pipe-top.png",
    width = 128,
    height = 128,
    priority = "extra-high",
    shift = util.by_pixel(0, 22),
    scale = 0.5,
  },
  east = {
    filename = "__space-exploration-graphics-4__/graphics/entity/astrometrics-laboratory/pipe-right.png",
    width = 10,
    height = 60,
    priority = "extra-high",
    shift = util.by_pixel(-18, 1),
    scale = 0.5,
  },
  south = {
    filename = "__space-exploration-graphics-4__/graphics/entity/astrometrics-laboratory/pipe-bottom.png",
    width = 70,
    height = 44,
    priority = "extra-high",
    shift = util.by_pixel(3, -27),
    scale = 0.5,
  },
  west = {
    filename = "__space-exploration-graphics-4__/graphics/entity/astrometrics-laboratory/pipe-left.png",
    width = 10,
    height = 64,
    priority = "extra-high",
    shift = util.by_pixel(18, 2),
    scale = 0.5,
  }
}


local gravimetrics_pipe_pictures = {
  north = {
    filename = "__space-exploration-graphics-4__/graphics/entity/gravimetrics-laboratory/pipe-top.png",
    width = 128,
    height = 128,
    priority = "extra-high",
    shift = util.by_pixel(0, 32),
    scale = 0.5,
  },
  east = {
    filename = "__space-exploration-graphics-4__/graphics/entity/gravimetrics-laboratory/pipe-right.png",
    width = 46,
    height = 68,
    priority = "extra-high",
    shift = util.by_pixel(-27, 1),
    scale = 0.5,
  },
  south = {
    filename = "__space-exploration-graphics-4__/graphics/entity/gravimetrics-laboratory/pipe-bottom.png",
    width = 70,
    height = 44,
    priority = "extra-high",
    shift = util.by_pixel(3, -27),
    scale = 0.5,
  },
  west = {
    filename = "__space-exploration-graphics-4__/graphics/entity/gravimetrics-laboratory/pipe-left.png",
    width = 46,
    height = 74,
    priority = "extra-high",
    shift = util.by_pixel(27, 3),
    scale = 0.5,
  }
}

data:extend({
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-astrometrics-laboratory",
    icon = "__space-exploration-graphics__/graphics/icons/astrometrics-laboratory.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 1, result = data_util.mod_prefix .. "space-astrometrics-laboratory"},
    max_health = 700,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box_vertical_extension = 1,
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
      {
        type = "impact",
        percent = 10
      }
    },
    fluid_boxes = {
      {
        production_type = "input",
        pipe_picture = astrometrics_pipe_pictures,
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction ="input", position = {0, -2}, direction = defines.direction.north }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_picture = astrometrics_pipe_pictures,
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction = "output", position = {0, 2}, direction = defines.direction.south }},
        secondary_draw_orders = { north = -1 }
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
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
        [spaceship_collision_layer] = true,
      },
    },
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__space-exploration-graphics-4__/graphics/entity/astrometrics-laboratory/astrometrics-laboratory.png",
            priority = "high",
            width = 2752/8,
            height = 3120/8,
            frame_count = 64,
            line_length = 8,
            shift = util.by_pixel(0, -11),
            animation_speed = astrometric_animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-4__/graphics/entity/astrometrics-laboratory/astrometrics-laboratory-shadow.png",
            priority = "high",
            width = 330,
            height = 220,
            frame_count = 1,
            line_length = 1,
            repeat_count = 64,
            shift = util.by_pixel(26, 24),
            animation_speed = astrometric_animation_speed,
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
    crafting_categories = {"space-astrometrics"},
    crafting_speed = astrometric_crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "1000kW",
    module_slots = astrometric_module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-gravimetrics-laboratory",
    icon = "__space-exploration-graphics__/graphics/icons/gravimetrics-laboratory.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 1, result = data_util.mod_prefix .. "space-gravimetrics-laboratory"},
    max_health = 700,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box_vertical_extension = 1,
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
          pipe_picture = gravimetrics_pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {0, -2}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = gravimetrics_pipe_pictures,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {0, 2}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
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
          filename = "__space-exploration__/sound/gravimetrics-facility-working-sound.ogg",
          volume = 0.5
        },
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
            filename = "__space-exploration-graphics-4__/graphics/entity/gravimetrics-laboratory/gravimetrics-laboratory.png",
            priority = "high",
            width = 3360/10,
            height = 2304/6,
            frame_count = 60,
            line_length = 10,
            shift = util.by_pixel(0, -11),
            animation_speed = gravimetric_animation_speed,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-4__/graphics/entity/gravimetrics-laboratory/gravimetrics-laboratory-shadow.png",
            priority = "high",
            width = 4480/10,
            height = 1500/6,
            frame_count = 30,
            line_length = 10,
            repeat_count = 2,
            shift = util.by_pixel(26, 24),
            animation_speed = gravimetric_animation_speed,
            scale = 0.5,
          },
        },
      },
      default_recipe_tint =
      {
        -- differentiation between primary and secondary is for the recipes that can alternate
        primary = {r = 81.0/255.0, g = 0.0, b = 252.0/255.0, a = 1.000}, -- purple tint that matches the building colors
        secondary = {r = 81.0/255.0, g = 0.0, b = 252.0/255.0, a = 1.000}, -- purple tint that matches the building colors
      },
      status_colors =
      {
        working = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}, -- green
        full_output = {r = 1.0, g = 1.0, b = 0.0, a = 1.0}, -- yellow
        idle = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}, -- red
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.5, size = 8, shift = {0.0, 0.0}, color = {r = 100/255, g = 48/255, b = 1}}
        },
        {
          apply_recipe_tint = "primary",
          animation =
          {
            filename = "__space-exploration-graphics-4__/graphics/entity/gravimetrics-laboratory/gravimetrics-laboratory-tint.png",
            width = 3360/10,
            height = 2304/6,
            frame_count = 60,
            line_length = 10,
            shift = util.by_pixel(0, -11),
            animation_speed = gravimetric_animation_speed,
            scale = 0.5,
            blend_mode = "additive",
          }
        },
        {
          apply_recipe_tint = "secondary",
          animation =
          {
            filename = "__space-exploration-graphics-4__/graphics/entity/gravimetrics-laboratory/gravimetrics-laboratory-tint-2.png",
            width = 112,
            height = 112,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(68, 45),
            animation_speed = gravimetric_animation_speed,
            scale = 0.5,
            blend_mode = "additive",
          }
        },
        {
          always_draw = true,
          apply_tint = "status",
          animation =
          {
            filename = "__space-exploration-graphics-4__/graphics/entity/gravimetrics-laboratory/gravimetrics-laboratory-working.png",
            width = 24,
            height = 24,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(57, 34),
            animation_speed = gravimetric_animation_speed,
            scale = 0.5,
            blend_mode = "additive",
          }
        }
      },
    },
    crafting_categories = {"space-gravimetrics", "arcosphere"},
    crafting_speed = gravimetric_crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "1000kW",
    module_slots = gravimetric_module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },
})
