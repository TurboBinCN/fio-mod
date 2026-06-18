local data_util = require("data_util")

-- space-science-lab is a lab

data:extend({
  {
        type = "lab",
        name = data_util.mod_prefix .. "space-science-lab",
        energy_usage = "1000kW", --"60kW",
        researching_speed = 10, -- 1,
        collision_box = {{-3.2, -3.2}, {3.2, 3.2}}, -- 7 wide
        selection_box = {{-3.5, -3.5}, {3.5, 3.5}}, -- 7 wide
        display_box = {{-3.5, -4.8}, {3.5, 3.5}}, -- 7 wide
        collision_mask = {
          layers = {
            water_tile = true,
            ground_tile = true,
            item = true,
            object = true,
            player = true,
            [spaceship_collision_layer] = true, -- not spaceship
          },
        },
        icon = "__space-exploration-graphics__/graphics/icons/space-science-lab.png",
        icon_size = 64,
        inputs = {
          "automation-science-pack",
          "logistic-science-pack",
          "chemical-science-pack",
          "military-science-pack",
          "production-science-pack",
          "utility-science-pack",
          "space-science-pack",
          data_util.mod_prefix .. "rocket-science-pack",
          data_util.mod_prefix .. "astronomic-science-pack-1",
          data_util.mod_prefix .. "biological-science-pack-1",
          data_util.mod_prefix .. "energy-science-pack-1",
          data_util.mod_prefix .. "material-science-pack-1",
          data_util.mod_prefix .. "astronomic-science-pack-2",
          data_util.mod_prefix .. "biological-science-pack-2",
          data_util.mod_prefix .. "energy-science-pack-2",
          data_util.mod_prefix .. "material-science-pack-2",
          data_util.mod_prefix .. "astronomic-science-pack-3",
          data_util.mod_prefix .. "biological-science-pack-3",
          data_util.mod_prefix .. "energy-science-pack-3",
          data_util.mod_prefix .. "material-science-pack-3",
          data_util.mod_prefix .. "astronomic-science-pack-4",
          data_util.mod_prefix .. "biological-science-pack-4",
          data_util.mod_prefix .. "energy-science-pack-4",
          data_util.mod_prefix .. "material-science-pack-4",
          data_util.mod_prefix .. "deep-space-science-pack-1",
          data_util.mod_prefix .. "deep-space-science-pack-2",
          data_util.mod_prefix .. "deep-space-science-pack-3",
          data_util.mod_prefix .. "deep-space-science-pack-4",
        },
        corpse = "big-remnants",
        dying_explosion = "medium-explosion",
        energy_source = {
          type = "electric",
          usage_priority = "secondary-input"
        },
        flags = { "placeable-player", "player-creation" },
        light = { color = { b = 1, g = 0.6, r = 0.4 }, intensity = 1, size = 12 },
        max_health = 500,
        minable = { mining_time = 0.2, result = data_util.mod_prefix .. "space-science-lab" },
        module_slots = 6,
        icons_positioning = {
          {inventory_index = defines.inventory.lab_modules, shift = { 0, 2.5 }, max_icons_per_row = 8},
          {inventory_index = defines.inventory.lab_input, shift = {0, 0}, max_icons_per_row = 8, separation_multiplier = 1/1.1}
        },
        off_animation = {
          layers = {
            {
              filename = "__space-exploration-graphics-3__/graphics/entity/space-science-lab/space-science-lab-inactive.png",
              frame_count = 1,
              height = 541,
              width = 467,
              shift = { 0/32, -12/32},
              scale = 0.5,
            },
            {
              draw_as_shadow = true,
              filename = "__space-exploration-graphics-3__/graphics/entity/space-science-lab/space-science-lab-shadow.png",
              frame_count = 1,
              width = 599,
              height = 345,
              scale = 0.5,
              shift = { 1.40625, 0.34375 },
            }
          }
        },
        on_animation = {
          layers = {
            {
              filename = "__space-exploration-graphics-3__/graphics/entity/space-science-lab/space-science-lab-base.png",
              width = 467,
              height = 290,
              line_length = 1,
              frame_count = 1,
              repeat_count = 64,
              animation_speed = 1,
              shift = { 0/32, 50.75/32 },
              scale = 0.5,
            },
            {
              height = 448,
              width = 402,
              frame_count = 64,
              animation_speed = 1,
              shift = { 0.75/32, -34.75/32 },
              stripes =
              {
                {
                 filename = "__space-exploration-graphics-3__/graphics/entity/space-science-lab/space-science-lab-1.png",
                 width_in_frames = 4,
                 height_in_frames = 4,
                },
                {
                 filename = "__space-exploration-graphics-3__/graphics/entity/space-science-lab/space-science-lab-2.png",
                 width_in_frames = 4,
                 height_in_frames = 4,
                },
                {
                 filename = "__space-exploration-graphics-3__/graphics/entity/space-science-lab/space-science-lab-3.png",
                 width_in_frames = 4,
                 height_in_frames = 4,
                },
                {
                 filename = "__space-exploration-graphics-3__/graphics/entity/space-science-lab/space-science-lab-4.png",
                 width_in_frames = 4,
                 height_in_frames = 4,
                },
              },
              scale = 0.5,
            },
            {
              draw_as_shadow = true,
              filename = "__space-exploration-graphics-3__/graphics/entity/space-science-lab/space-science-lab-shadow.png",
              width = 599,
              height = 345,
              line_length = 1,
              frame_count = 1,
              repeat_count = 64,
              animation_speed = 1,
              scale = 0.5,
              shift = { 1.40625, 0.34375 },
            }
          }
        },
        open_sound = data_util.machine_open_sound,
        close_sound = data_util.machine_close_sound,
        impact_category = "metal-large",
        working_sound = {
          apparent_volume = 1,
          sound = {
            filename = "__base__/sound/lab.ogg",
            volume = 0.7
          }
        }
      }
})
