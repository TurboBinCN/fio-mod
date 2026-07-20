local sounds = require("__base__/prototypes/entity/sounds")
local hit_effects = require("__base__/prototypes/entity/hit-effects")

local void_container_entity = {
    type = "linked-container",
    name = "priyutils-void-container",
    gui_mode = "all",
    icon = "__PriyUtils__/graphics/icons/cartoonbox.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.1, result = "priyutils-void-container"},
    max_health = 500,
    corpse = "steel-chest-remnants",
    dying_explosion = "steel-chest-explosion",
    open_sound = sounds.metal_chest_open,
    close_sound = sounds.metal_chest_close,
    resistances = {
        {type = "fire", percent = 90},
        {type = "impact", percent = 60}
    },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    damaged_trigger_effect = hit_effects.entity(),
    fast_replaceable_group = "container",
    inventory_size = 50,
    impact_category = "metal",
    picture =
    {
      layers =
      {
        {
          filename = "__PriyUtils__/graphics/icons/cartoonbox.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          shift = util.by_pixel(-0.25, -0.5),
          scale = 0.25
        },
        {
          filename = "__base__/graphics/entity/steel-chest/steel-chest-shadow.png",
          priority = "extra-high",
          width = 110,
          height = 46,
          shift = util.by_pixel(12.25, 8),
          draw_as_shadow = true,
          scale = 0.5
        }
      }
    },
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions["chest"]
}

local void_tank_entity = {
    type = "storage-tank",
    name = "priyutils-void-tank",
    icon = "__PriyUtils__/graphics/icons/cartooncup.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "priyutils-void-tank"},
    max_health = 500,
    se_allow_in_space = true,
    corpse = "storage-tank-remnants",
    dying_explosion = "storage-tank-explosion",
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "storage-tank",
    damaged_trigger_effect = hit_effects.entity(),
    fluid_box = {
        volume = 25000,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
            {direction = defines.direction.east, position = {1, 0}},
            {direction = defines.direction.west, position = {-1, 0}},
            {direction = defines.direction.north, position = {0, -1}},
            {direction = defines.direction.south, position = {0, 1}},
        },
        hide_connection_info = true
    },
    two_direction_only = true,
    -- window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
    window_bounding_box = {{-0.2, -0.5}, {0.3, 0.3}},
    pictures = {
        picture = {
            sheets = {
                {
                    filename = "__PriyUtils__/graphics/entity/storage-tank/cartooncup.png",
                    priority = "extra-high",
                    frames = 2,
                    width = 219,
                    height = 235,
                    shift = util.by_pixel(-0.25, -1.25),
                    scale = 0.5
                },
                {
                    filename = "__base__/graphics/entity/storage-tank/storage-tank-shadow.png",
                    priority = "extra-high",
                    frames = 2,
                    width = 291,
                    height = 153,
                    shift = util.by_pixel(29.75, 22.25),
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        },
        fluid_background = {
            filename = "__base__/graphics/entity/storage-tank/fluid-background.png",
            priority = "extra-high",
            width = 32,
            height = 15
        },
        window_background = {
            filename = "__PriyUtils__/graphics/entity/storage-tank/cartooncup-window-background.png",
            priority = "extra-high",
            width = 53,
            height = 38,
            scale = 0.5
        },
        flow_sprite = {
            filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 20
        },
        gas_flow = {
            filename = "__base__/graphics/entity/pipe/steam.png",
            priority = "extra-high",
            line_length = 10,
            width = 48,
            height = 30,
            frame_count = 60,
            animation_speed = 0.25,
            scale = 0.5
        }
    },
    flow_length_in_ticks = 360,
    impact_category = "metal-large",
    open_sound = sounds.metal_large_open,
    close_sound = sounds.metal_large_close,
    working_sound = {
        sound = {filename = "__base__/sound/storage-tank.ogg", volume = 0.6, audible_distance_modifier = 0.5},
        match_volume_to_activity = true,
        max_sounds_per_prototype = 3
    },
    circuit_connector = circuit_connector_definitions["storage-tank"],
    circuit_wire_max_distance = default_circuit_wire_max_distance
}

data:extend({
    void_container_entity,
    void_tank_entity
})