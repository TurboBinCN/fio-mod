local data_util = require("data_util")

local target_animation_speed = 2
local crafting_speed = 10
local module_slots = 6
local animation_speed = (target_animation_speed / crafting_speed) / (1 + data_util.speed_module_3_speed_bonus * module_slots)

table.insert(data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories, "crafting-or-electromagnetics")

local space_assembler = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
space_assembler.name = data_util.mod_prefix .. "space-assembling-machine"
space_assembler.icon = "__space-exploration-graphics__/graphics/icons/assembling-machine.png"
space_assembler.icon_size = 64
data_util.replace_filenames_recursive(space_assembler.graphics_set.animation,
  "__base__",
  "__space-exploration-graphics__")
data_util.replace_filenames_recursive(space_assembler.graphics_set.animation,
  "assembling-machine-3",
  "assembling-machine")
local pipe_pics = nil
for _, fluid_box in pairs(space_assembler.fluid_boxes) do
  if type(fluid_box) == "table" then
    data_util.replace_filenames_recursive(fluid_box.pipe_picture,
      "__base__",
      "__space-exploration-graphics__")
    data_util.replace_filenames_recursive(fluid_box.pipe_picture,
      "assembling-machine-3",
      "assembling-machine")
    pipe_pics = table.deepcopy(fluid_box.pipe_picture)
  end
end
space_assembler.minable.result = data_util.mod_prefix .. "space-assembling-machine"
space_assembler.allowed_effects = data_util.all_effects_except("productivity")
space_assembler.fast_replaceable_group = nil
space_assembler.next_upgrade = nil
space_assembler.collision_mask = {
  layers = {
    water_tile = true,
    ground_tile = true,
    item = true,
    object = true,
    player = true,
  },
}
table.insert(space_assembler.crafting_categories, "space-crafting")

local m_pipe_pics = table.deepcopy(pipe_pics)
m_pipe_pics.north = {
  filename = "__space-exploration-graphics__/graphics/entity/pipe/pipe-straight-vertical.png",
  width = 128,
  height = 128,
  priority = "extra-high",
  scale = 0.5,
  shift = {0, 1}
}

data:extend({
  space_assembler,
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-manufactory",
    icon = "__space-exploration-graphics__/graphics/icons/manufactory.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "space-manufactory"},
    max_health = 900,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {3,4}, shadow_offset = {3,4}, show_shadow = true },
        { variation = 18, main_offset = {3,4}, shadow_offset = {3,4}, show_shadow = true },
        { variation = 18, main_offset = {3,4}, shadow_offset = {3,4}, show_shadow = true },
        { variation = 18, main_offset = {3,4}, shadow_offset = {3,4}, show_shadow = true },
      }
    ),
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    fluid_boxes = {
      {
          production_type = "input",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {-4, 2}, direction = defines.direction.west }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {-2, -4}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {-4, 0}, direction = defines.direction.west }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {0, -4}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {-4, -2}, direction = defines.direction.west }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "input",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="input", position = {2, -4}, direction = defines.direction.north }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {-2, 4}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {4, 2}, direction = defines.direction.east }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {0, 4}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {4, 0}, direction = defines.direction.east }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {2, 4}, direction = defines.direction.south }},
          secondary_draw_orders = { north = -1 }
      },
      {
          production_type = "output",
          pipe_picture = m_pipe_pics,
          pipe_covers = pipecoverspictures(),
          volume = 1000,
          pipe_connections = {{ flow_direction="output", position = {4, -2}, direction = defines.direction.east }},
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
          filename = "__base__/sound/assembling-machine-t3-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t3-2.ogg",
          volume = 0.8
        },
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
      },
    },
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    drawing_box_vertical_extension = 0.2,
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/base.png",
            priority = "high",
            width = 577,
            height = 605,
            frame_count = 1,
            line_length = 1,
            repeat_count = 128,
            shift = util.by_pixel(0, -8),
            animation_speed = animation_speed,
            scale = 0.5,
          },
          {
            priority = "high",
            width = 512,
            height = 422,
            frame_count = 128,
            shift = util.by_pixel(-0, -51),
            animation_speed = animation_speed,
            scale = 0.5,
            stripes =
            {
              {
               filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/top-1.png",
               width_in_frames = 4,
               height_in_frames = 4,
              },
              {
               filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/top-2.png",
               width_in_frames = 4,
               height_in_frames = 4,
              },
              {
               filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/top-3.png",
               width_in_frames = 4,
               height_in_frames = 4,
              },
              {
               filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/top-4.png",
               width_in_frames = 4,
               height_in_frames = 4,
              },
              {
               filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/top-5.png",
               width_in_frames = 4,
               height_in_frames = 4,
              },
              {
               filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/top-6.png",
               width_in_frames = 4,
               height_in_frames = 4,
              },
              {
               filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/top-7.png",
               width_in_frames = 4,
               height_in_frames = 4,
              },
              {
               filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/top-8.png",
               width_in_frames = 4,
               height_in_frames = 4,
              },
            }
          },
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/middle.png",
            priority = "high",
            width = 40,
            height = 82,
            frame_count = 128,
            line_length = 16,
            shift = util.by_pixel(51, 79),
            animation_speed = animation_speed,
            scale = 0.5,
          },
          --[[{
            filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/lower.png",
            priority = "high",
            width = 80,
            height = 22,
            frame_count = 128,
            line_length = 8,
            shift = util.by_pixel(62, 137),
            scale = 0.5,
          },]]--
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics-5__/graphics/entity/space-manufactory/shadow.png",
            priority = "high",
            width = 795,
            height = 430,
            frame_count = 1,
            line_length = 1,
            repeat_count = 128,
            shift = util.by_pixel(67, 38),
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.8, size = 20, shift = {0.0, 0.0}, color = {r = 0.7, g = 0.8, b = 1}}
        },
      },
    },
    crafting_categories = table.deepcopy(space_assembler.crafting_categories),
    crafting_speed = crafting_speed,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 50 },
    },
    energy_usage = "2000kW",
    module_slots = module_slots,
    allowed_effects = data_util.all_effects_except("productivity"),
  },
})

table.insert(data.raw["assembling-machine"][data_util.mod_prefix .. "space-manufactory"].crafting_categories, "space-manufacturing")
