local data_util = require("data_util")
--[[
3 entities:
- furnace is the placed entity, short but wide, takes steam, outputs water out front, outputs outputs decompressing-steam to storage-tank
- storage-tank passes decompressing-steam and is a buffer
- generator takes decompressing-steam to output power

fluid box connections don't need to line up just find the right entity.

furnace just has a 1 frame idle animation (for the ghost item)
generator has the actual animation (so it scales speed to power output)
For some reason the generator animation always plays above the furnace's graphics, which is great because that's what we want.
]]--
local selectable = false
local idle_horizontal = {
  layers = {
    {
      filename = "__space-exploration-graphics-3__/graphics/entity/condenser-turbine/condenser-turbine-H.png",
      frame_count = 1,
      height = 245,
      line_length = 1,
      scale = 0.5,
      shift = {
        0,
        -0.0859375 - 1/32
      },
      width = 320
    },
    {
      draw_as_shadow = true,
      filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H-shadow.png",
      frame_count = 1,
      height = 150,
      line_length = 1,
      scale = 0.5,
      shift = {
        0.890625,
        0.5625
      },
      width = 435
    }
  }
}
local idle_vertical = {
  layers = {
    {
      filename = "__space-exploration-graphics-3__/graphics/entity/condenser-turbine/condenser-turbine-V.png",
      frame_count = 1,
      height = 347,
      line_length = 1,
      scale = 0.5,
      shift = {
        0.1484375,
        0.2109375 - 1/32
      },
      width = 217
    },
    {
      draw_as_shadow = true,
      filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V-shadow.png",
      frame_count = 1,
      height = 260,
      line_length = 1,
      repeat_count = 1,
      scale = 0.5,
      shift = {
        1.234375,
        0.765625
      },
      width = 302
    }
  }
}
local blank_image = {
    filename = "__space-exploration-graphics__/graphics/blank.png",
    width = 1,
    height = 1,
    frame_count = 1,
    line_length = 1,
    shift = { 0, 0 },
}
data:extend({

  {
    type = "storage-tank",
    name = data_util.mod_prefix .. "condenser-turbine-tank",
    hidden = true,
    subgroup = "composite-entity-parts",
    order = "a",
    icons = data_util.add_icons(
      "__space-exploration-graphics__/graphics/icons/condenser-turbine.png",
      data.raw.item["storage-tank"].icon
    ),
    flags = {"placeable-player", "player-creation", "not-deconstructable", "not-blueprintable", "hide-alt-info"},
    max_health = 500,
    collision_box = {{-1.5, -0.25},{1.5, 0.25}},
    selection_box = {{-1.5, -0.25},{1.5, 0.25}},
    se_allow_in_space = true,
    collision_mask = {
      layers = {},
      not_colliding_with_itself = true,
    },
    selectable_in_game = selectable,
    fluid_box =
    {
      filter =  data_util.mod_prefix .. "decompressing-steam",
      volume = 25,
       -- pull fluid in
      pipe_connections =
      {
        { position = {0, 0}, direction = defines.direction.north }, -- connects to generator
        { position = {1, 0}, direction = defines.direction.north }, -- connects to furnace
        { position = {-1, 0}, direction = defines.direction.north }, -- connects to furnace
      },
    },
    window_bounding_box = {{-0.0, 0.0}, {0.0, 1.0}},
    pictures = {
      picture = blank_image,
      window_background = blank_image,
      fluid_background = blank_image,
      flow_sprite = blank_image,
      gas_flow = blank_image,
    },
    flow_length_in_ticks = 360,
    circuit_wire_max_distance = 0
  },
  {
    type = "generator",
    name = data_util.mod_prefix .. "condenser-turbine-generator",
    hidden = true,
    subgroup = "composite-entity-parts",
    icon = "__space-exploration-graphics__/graphics/icons/condenser-turbine.png",
    icon_size = 64,
    alert_icon_shift = { 0, 0.375 },
    burns_fluid = false,
    fluid_usage_per_tick = 1,
    scale_fluid_usage = true,
    selectable_in_game = selectable,
    collision_box = {  { -1.25, -1.6 }, { 1.25, 1.6 } }, -- short and wide thin
    --collision_box = { { -1, -0.1 }, { 1, 0.1 } }, -- sits on y 2.25
    collision_mask = {
      layers = {},
      not_colliding_with_itself = true,
    },
    selection_box =  {  { -1.25, -1.6 }, { 1.25, 1.6 } },
    se_allow_in_space = true,
    order = "zzz",
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    efficiency = 1,
    energy_source = { type = "electric", usage_priority = "secondary-output" },
    flags = { "placeable-neutral", "player-creation", "placeable-off-grid", "hide-alt-info"},
    fluid_box = {
      volume = 25,
      filter =  data_util.mod_prefix .. "decompressing-steam",
      height = 2,
      minimum_temperature = 15,
      pipe_connections = {
        {
          position = { 0, 0.65 },
          flow_direction = "input-output",
          direction = defines.direction.south
        },
        {
          position = { 0, -0.65 },
          flow_direction = "input-output",
          direction = defines.direction.north
        },
      },
      production_type = "input-output"
    },
    horizontal_animation = {
      layers = {
        {
          filename = "__space-exploration-graphics-3__/graphics/entity/condenser-turbine/condenser-turbine-H.png",
          frame_count = 8,
          height = 245,
          line_length = 4,
          scale = 0.5,
          shift = {
            0,
            -0.0859375 - 1/32
          },
          width = 320
        },
      }
    },
    max_health = 300,
    maximum_temperature = 500,
    perceived_performance = { minimum = 0.25, performance_to_activity_rate = 0.5 },
    resistances = {
      {
        percent = 70,
        type = "fire"
      }
    },
    smoke = {
      {
        east_position = {
          0.75,
          -0.75
        },
        frequency = 0.3125,
        name = "turbine-smoke",
        north_position = {
          0,
          -1
        },
        slow_down_factor = 1,
        starting_frame_deviation = 60,
        starting_vertical_speed = 0.08
      }
    },
    impact_category = "metal",
    vertical_animation = {
      layers = {
        {
          filename = "__space-exploration-graphics-3__/graphics/entity/condenser-turbine/condenser-turbine-V.png",
          frame_count = 8,
          height = 347,
          line_length = 4,
          scale = 0.5,
          shift = {
            0.1484375,
            0.2109375 - 1/32
          },
          width = 217
        }
      }
    },
    working_sound = table.deepcopy(data.raw.generator["steam-turbine"].working_sound)
  },
  {
    type = "furnace",
    name = data_util.mod_prefix .. "condenser-turbine",
    icon = "__space-exploration-graphics__/graphics/icons/condenser-turbine.png",
    icon_size = 64,
    collision_box = {  { -1.3, -2.15 }, { 1.3, 2.15 } },
    --selection_box = { { -1.5, -2.5 }, { 1.5, 2.5 } },
    selection_box =  {  { -1.3, -2.15 }, { 1.3, 2.15 } },
    se_allow_in_space = true,
    fluid_boxes =
    {
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 100 * 1.5,

        filter = "steam",
        pipe_connections = {
          { flow_direction="input", position = {0, -2}, direction = defines.direction.north }
        },
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 100 * 1.5,

        filter = "water",
        pipe_connections = {
          { flow_direction="output", position = {0, 2}, direction = defines.direction.south }
        },
        secondary_draw_orders = { north = -1 }
      },
      {
        filter =  data_util.mod_prefix .. "decompressing-steam",
        --filter = "steam",
        production_type = "output",
        --pipe_picture = assembler3pipepictures(),
        volume = 100 * 1.5,

        hide_connection_info = true,
        pipe_connections = {
          { flow_direction="output", position = {1, 1.25}, direction = defines.direction.south },
          { flow_direction="output", position = {-1, 1.25}, direction = defines.direction.south },
        },
        secondary_draw_orders = { north = -1 }
      },
    },
    minable = {
      mining_time = 0.3,
      result = data_util.mod_prefix .. "condenser-turbine",
    },
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    show_recipe_icon = false,
    show_recipe_icon_on_map = false,
    fast_replaceable_group = "steam-engine", -- This doesn't work for some reason
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    drawing_box_vertical_extension = 0.85,
    resistances = {
      { type = "poison", percent = 100 },
      { type = "fire", percent = 80 },
      { type = "explosion", percent = 50 }
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal",
    source_inventory_size = 0,
    result_inventory_size = 0,
    graphics_set = {
      always_draw_idle_animation = true,
      idle_animation = {
        east = idle_horizontal,
        west = idle_horizontal,
        north = idle_vertical,
        south = idle_vertical,
      },
    },
    crafting_categories = {"condenser-turbine"},
    crafting_speed = 1,
    energy_source =
    {
      type = "void",
    },
    energy_usage = "0.1W",
    bottleneck_ignore = true -- Bottleneck lite
  },
})
