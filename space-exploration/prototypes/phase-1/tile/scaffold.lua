local data_util = require("data_util")
local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local tile_spritesheet_layout = tile_graphics.tile_spritesheet_layout

data:extend(
{
  {
    type = "tile",
    name = data_util.mod_prefix .. "space-platform-scaffold",
    needs_correction = false,
    minable = {mining_time = 0.1, result = data_util.mod_prefix .. "space-platform-scaffold"},
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    collision_mask = {
      layers = {
        [space_collision_layer] = true,
        --resource = true,
      },
    },
    walking_speed_modifier = 0.75,
    layer_group = "ground-artificial",
    layer = 99,
    decorative_removal_probability = 0.75,
    variants =
    {
      main =
      {
        {
          picture = "__space-exploration-graphics__/graphics/terrain/space-platform-scaffold/tile1.png",
          count = 16,
          size = 1,
          scale = 0.5
        },
        {
          picture = "__space-exploration-graphics__/graphics/terrain/space-platform-scaffold/tile2.png",
          count = 5,
          size = 2,
          scale = 0.5
        },
        {
          picture = "__space-exploration-graphics__/graphics/terrain/space-platform-scaffold/tile4.png",
          count = 1,
          size = 4,
          scale = 0.5
        },
      },
      transition = {
        overlay_layout = {
          inner_corner =
          {
            spritesheet = "__space-exploration-graphics__/graphics/terrain/space-platform-scaffold/tile-inner-corner.png",
            count = 8,
            tall = false,
            scale = 0.5
          },
          outer_corner =
          {
            spritesheet = "__space-exploration-graphics__/graphics/terrain/space-platform-scaffold/tile-outer-corner.png",
            count = 8,
            tall = false,
            scale = 0.5
          },
          side =
          {
            spritesheet = "__space-exploration-graphics__/graphics/terrain/space-platform-scaffold/tile-side.png",
            count = 8,
            tall = false,
            scale = 0.5
          },
          u_transition =
          {
            spritesheet = "__space-exploration-graphics__/graphics/terrain/space-platform-scaffold/tile-u.png",
            count = 1,
            tall = false,
            scale = 0.5
          },
          o_transition =
          {
            spritesheet = "__space-exploration-graphics__/graphics/terrain/space-platform-scaffold/tile-o.png",
            count = 8,
            scale = 0.5
          }
        }
      }
    },
    walking_sound =
    {
      {
        filename = "__base__/sound/walking/concrete-1.ogg",
        volume = 1.2
      },
      {
        filename = "__base__/sound/walking/concrete-2.ogg",
        volume = 1.2
      },
      {
        filename = "__base__/sound/walking/concrete-3.ogg",
        volume = 1.2
      },
      {
        filename = "__base__/sound/walking/concrete-4.ogg",
        volume = 1.2
      }
    },
    map_color={r=50, g=50, b=50},
    ageing=0,
    vehicle_friction_modifier = 100,
    transitions = {
        {
          to_tiles = {
            "water",
            "deepwater",
            "water-green",
            "deepwater-green",
            "water-shallow",
            "water-mud",
            data_util.mod_prefix .. "space"
          },
          transition_group = 1,

          spritesheet = "__space-exploration-graphics__/graphics/terrain/space-platform-scaffold/tile-transitions.png",

          overlay_enabled = true,
          background_enabled = true,
          mask_enabled = false,
          background_mask_enabled = true,

          --overlay_layer_group = "zero",
          background_layer_offset = 1,
          --background_layer_group = "zero",
          offset_background_layer_by_tile_layer = true,

          layout = {
            scale = 0.5,
            inner_corner_count = 8,
            outer_corner_count = 8,
            side_count = 8,
            u_transition_count = 1,
            o_transition_count = 4,
            inner_corner_y = 0,
            outer_corner_y = 576,
            side_y = 1152,
            u_transition_y = 1728,
            o_transition_y = 2304,
            inner_corner_tile_height = 2,
            outer_corner_tile_height = 2,
            side_tile_height = 2,
            u_transition_tile_height = 2,
            overlay    = { x_offset = 0 },
            mask       = { x_offset = 2176 },
            background = { x_offset = 1088 }
          },
        },
      }
  },
})
