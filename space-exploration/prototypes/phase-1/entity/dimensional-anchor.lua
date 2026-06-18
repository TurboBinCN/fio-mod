local data_util = require("data_util")

data:extend({

  {
    type = "electric-energy-interface",
    name = data_util.mod_prefix .. "dimensional-anchor",
    hidden_in_factoriopedia = true,
    icon = "__space-exploration-graphics__/graphics/icons/dimensional-anchor.png",
    icon_size = 64,
    minable = {hardness = 0.2, mining_time = 1, result = data_util.mod_prefix .. "dimensional-anchor"},
    order = "z-d-a",
    allow_copy_paste = true,
    picture =
    {
      layers =
      {
        {
          filename = "__space-exploration-graphics-3__/graphics/entity/dimensional-anchor/dimensional-anchor.png",
          priority = "high",
          width = 576,
          height = 672,
          frame_count = 1,
          line_length = 1,
          shift = util.by_pixel(0, -24),
          animation_speed = 1,
          scale = 0.5,
        },
        {
          draw_as_shadow = true,
          filename = "__space-exploration-graphics-3__/graphics/entity/dimensional-anchor/dimensional-anchor-shadow.png",
          priority = "high",
          width = 709,
          height = 477,
          frame_count = 1,
          line_length = 1,
          repeat_count = 1,
          shift = util.by_pixel(32, 28),
          scale = 0.5,
        },
      },
    },
    collision_box = {{-4.4, -4.4},{4.4, 4.4}},
    selection_box = {{-4.4, -4.4},{4.4, 4.4}},
    drawing_box_vertical_extension = 1,
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
    se_placement_restriction_text = {"space-exploration.environment-close-star-orbit"},
    selectable = false,
    continuous_animation = true,
    corpse = "medium-remnants",
    energy_source = {
      buffer_capacity = "1TJ",
      input_flow_limit = "60GW", -- total when all active (values over 60GW won't work)
      output_flow_limit = "0kW",
      type = "electric",
      usage_priority = "primary-input"
    },
    energy_production = "0kW",
    energy_usage = "0GW", -- platform + 1x per lock + 1x for final energy spike final activation.
    --energy_usage = "60GW", -- platform + 1x per lock + 1x for final energy spike final activation.
    flags = {
      "placeable-player",
      "player-creation",
      "not-rotatable"
    },
    hidden = true,
    max_health = 5000,
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound = {
      apparent_volume = 1.5,
      fade_in_ticks = 10,
      fade_out_ticks = 30,
      max_sounds_per_type = 3,
      sound = {
        {
          filename = "__base__/sound/nuclear-reactor-1.ogg",
          volume = 0.6
        },
        {
          filename = "__base__/sound/nuclear-reactor-2.ogg",
          volume = 0.6
        }
      }
    },
    --light = {intensity = 1, size = 8, shift = {0.0, 0.0}, color = {r = 0.6, g = 0.9, b = 1}}
  },
  {
    type = "projectile",
    name = data_util.mod_prefix .. "dimensional-anchor-fx",
    subgroup = "environmental-effects",
    hidden = true,
    direction_only = false,
    flags = { "not-on-map", "placeable-off-grid" },
    acceleration = 0,
    collision_mask = {
      layers = {},
      not_colliding_with_itself = true,
    },
    light = {intensity = 1, size = 8, shift = {0.0, 0.0}, color = {r = 0.6, g = 0.9, b = 1}},
    working_sound = {
      apparent_volume = 1.5,
      fade_in_ticks = 10,
      fade_out_ticks = 30,
      max_sounds_per_type = 3,
      sound = {
        {
          filename = "__base__/sound/nuclear-reactor-1.ogg",
          volume = 0.6
        },
        {
          filename = "__base__/sound/nuclear-reactor-2.ogg",
          volume = 0.6
        }
      }
    },
    animation = {
      layers = {
        {
          filename = "__space-exploration-graphics-3__/graphics/entity/dimensional-anchor/dimensional-anchor-light.png",
          priority = "high",
          width = 576,
          height = 640,
          frame_count = 1,
          line_length = 1,
          shift = util.by_pixel(0, -32),
          animation_speed = 1,
          scale = 0.5,
          apply_runtime_tint = true,
          blend_mode = "additive", --"additive-soft"
        },
        {
          filename = "__space-exploration-graphics-3__/graphics/entity/dimensional-anchor/dimensional-anchor-skybeam.png",
          priority = "high",
          width = 77,
          height = 597,
          frame_count = 1,
          line_length = 1,
          shift = util.by_pixel(0, -19 * 32 -2),
          animation_speed = 1,
          scale = 2,
          apply_runtime_tint = true,
          blend_mode = "additive-soft",
        },
      }
    },
  },

})
