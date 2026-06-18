local data_util = require("data_util")

local rad1_target_animation_speed = 0.25
local rad1_crafting_speed = 1
local rad1_module_slots = 2
local rad1_animation_speed = (rad1_target_animation_speed / rad1_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * rad1_module_slots)

local rad2_target_animation_speed = 0.35
local rad2_crafting_speed = 3
local rad2_module_slots = rad1_module_slots
local rad2_animation_speed = (rad2_target_animation_speed / rad2_crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * rad2_module_slots)

data:extend({
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-radiator",
    icon = "__space-exploration-graphics__/graphics/icons/radiator.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {mining_time = 0.1, result = data_util.mod_prefix .. "space-radiator"},
    fast_replaceable_group = data_util.mod_prefix .. "space-radiator",
    max_health = 150,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, 0),
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    drawing_box_vertical_extension = 1,
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
    resistances =
    {
      {
        type = "fire",
        percent = 90
      }
    },
    fluid_boxes = {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="input", position = {0, -1}, direction = defines.direction.north }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction="output", position = {0, 1}, direction = defines.direction.south }},
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
          filename = "__base__/sound/electric-furnace.ogg",
          volume = 0.7
        },
      },
      apparent_volume = 1.5,
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
            priority = "high",
            width = 196,
            height = 275,
            frame_count = 20,
            shift = util.by_pixel(-0, -12),
            animation_speed = rad1_animation_speed,
            scale = 0.5,
            stripes =
            {
              {
               filename = "__space-exploration-graphics-4__/graphics/entity/radiator/radiator.png",
               width_in_frames = 10,
               height_in_frames = 2,
              },
            }
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-4__/graphics/entity/radiator/radiator-shadow.png",
            priority = "high",
            width = 242,
            height = 147,
            frame_count = 1,
            line_length = 1,
            repeat_count = 20,
            shift = util.by_pixel(25, 11),
            animation_speed = rad1_animation_speed,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.3, size = 9, shift = {0.0, 0.0}, color = {r = 1, g = 0.3, b = 0.05}}
        },
      },
    },
    crafting_categories = {"space-radiator"},
    crafting_speed = rad1_crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 1 },
    },
    energy_usage = "100kW",
    module_slots = rad1_module_slots,
    allowed_effects = data_util.all_effects_except("productivity", "quality"),
  },
})
local radiator_2 = table.deepcopy(data.raw["assembling-machine"][data_util.mod_prefix .. "space-radiator"])
radiator_2.name = data_util.mod_prefix .. "space-radiator-2"
radiator_2.energy_usage = "20kW"
radiator_2.crafting_speed = rad2_crafting_speed
radiator_2.module_slots = rad2_module_slots
radiator_2.graphics_set.animation.layers[1].animation_speed = rad2_animation_speed
radiator_2.icon = "__space-exploration-graphics__/graphics/icons/radiator-blue.png"
radiator_2.minable.result = data_util.mod_prefix .. "space-radiator-2"
data_util.replace_filenames_recursive(radiator_2.graphics_set.animation, "radiator.png", "radiator-blue.png")
data:extend({
  radiator_2
})
data.raw["assembling-machine"][data_util.mod_prefix .. "space-radiator"].next_upgrade = radiator_2.name
