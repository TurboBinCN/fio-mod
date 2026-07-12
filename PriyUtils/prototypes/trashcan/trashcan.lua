local sounds = require("__base__/prototypes/entity/sounds")
local hit_effects = require("__base__/prototypes/entity/hit-effects")

local trashcan_path = "__PriyUtils__/graphics/entity/trashcan"
local base_path = "__base__/graphics/entity/electric-furnace"

-- Basic trashcan (tier 1) graphics set
local basic_graphics_set = {
    animation = {
        layers = {
            {
                filename = trashcan_path.."/reverse-factory-1.png",
                priority = "high",
                width = 239,
                height = 219,
                shift = util.by_pixel(0.75, 5.75),
                scale = 0.5
            },
            {
                filename = base_path.."/electric-furnace-shadow.png",
                priority = "high",
                width = 227,
                height = 171,
                frame_count = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(11.25, 7.75),
                scale = 0.5
            }
        }
    },
    working_visualisations = {
        {
            fadeout = true,
            animation = {
                layers = {
                    {
                        filename = trashcan_path.."/reverse-factory-heater.png",
                        priority = "high",
                        width = 60,
                        height = 56,
                        frame_count = 12,
                        animation_speed = 1,
                        draw_as_glow = true,
                        shift = util.by_pixel(1.75, 32.75),
                        scale = 0.5
                    },
                    {
                        filename = base_path.."/electric-furnace-light.png",
                        blend_mode = "additive",
                        width = 202,
                        height = 202,
                        repeat_count = 12,
                        draw_as_glow = true,
                        shift = util.by_pixel(1, 0),
                        scale = 0.5,
                    },
                }
            },
        },
        {
            fadeout = true,
            animation = {
                filename = base_path.."/electric-furnace-ground-light.png",
                blend_mode = "additive",
                width = 166,
                height = 124,
                draw_as_light = true,
                shift = util.by_pixel(3, 69),
                scale = 0.5,
            },
        },
        {
            animation = {
                filename = trashcan_path.."/reverse-factory-propeller-1.png",
                priority = "high",
                width = 37,
                height = 25,
                frame_count = 4,
                animation_speed = 1,
                shift = util.by_pixel(-20.5, -18.5),
                scale = 0.5
            }
        },
        {
            animation = {
                filename = trashcan_path.."/reverse-factory-propeller-2.png",
                priority = "high",
                width = 23,
                height = 15,
                frame_count = 4,
                animation_speed = 1,
                shift = util.by_pixel(3.5, -38),
                scale = 0.5
            }
        }
    },
    water_reflection = {
        pictures = {
            filename = base_path.."/electric-furnace-reflection.png",
            priority = "extra-high",
            width = 24,
            height = 24,
            shift = util.by_pixel(5, 40),
            variation_count = 1,
            scale = 5
        },
        rotate = false,
        orientation_to_variation = false
    }
}

-- Advanced trashcan (tier 2) graphics set with turbine
local advanced_graphics_set = {
    animation = {
        layers = {
            {
                filename = trashcan_path.."/reverse-factory-2.png",
                priority = "high",
                width = 239,
                height = 219,
                frame_count = 1,
                repeat_count = 32,
                shift = util.by_pixel(0.75, 5.75),
                scale = 0.5
            },
            {
                filename = base_path.."/electric-furnace-shadow.png",
                priority = "high",
                width = 227,
                height = 171,
                frame_count = 1,
                repeat_count = 32,
                draw_as_shadow = true,
                shift = util.by_pixel(11.25, 7.75),
                scale = 0.5
            },
            {
                filename = trashcan_path.."/reverse-factory-turbine.png",
                priority = "high",
                width = 116,
                height = 78,
                frame_count = 32,
                repeat_count = 1,
                line_length = 8,
                animation_speed = 0.5,
                shift = util.by_pixel(15.25, -13.5),
                scale = 0.33
            }
        }
    },
    working_visualisations = {
        {
            fadeout = true,
            animation = {
                layers = {
                    {
                        filename = trashcan_path.."/reverse-factory-heater.png",
                        priority = "high",
                        width = 60,
                        height = 56,
                        frame_count = 12,
                        animation_speed = 0.5,
                        draw_as_glow = true,
                        shift = util.by_pixel(1.75, 32.75),
                        scale = 0.5
                    },
                    {
                        filename = base_path.."/electric-furnace-light.png",
                        blend_mode = "additive",
                        width = 202,
                        height = 202,
                        repeat_count = 12,
                        draw_as_glow = true,
                        shift = util.by_pixel(1, 0),
                        scale = 0.5,
                    },
                }
            },
        },
        {
            fadeout = true,
            animation = {
                filename = base_path.."/electric-furnace-ground-light.png",
                blend_mode = "additive",
                width = 166,
                height = 124,
                draw_as_light = true,
                shift = util.by_pixel(3, 69),
                scale = 0.5,
            },
        },
        {
            animation = {
                filename = trashcan_path.."/reverse-factory-propeller-1.png",
                priority = "high",
                width = 37,
                height = 25,
                frame_count = 4,
                animation_speed = 0.5,
                shift = util.by_pixel(-20.5, -18.5),
                scale = 0.5
            }
        },
        {
            animation = {
                filename = trashcan_path.."/reverse-factory-propeller-2.png",
                priority = "high",
                width = 23,
                height = 15,
                frame_count = 4,
                animation_speed = 0.5,
                shift = util.by_pixel(3.5, -38),
                scale = 0.5
            }
        },
        {
            animation = {
                filename = trashcan_path.."/reverse-factory-turbine.png",
                priority = "high",
                width = 116,
                height = 78,
                frame_count = 32,
                repeat_count = 1,
                line_length = 8,
                animation_speed = 0.45,
                shift = util.by_pixel(15.25, -13.5),
                scale = 0.33
            }
        },
    },
    water_reflection = {
        pictures = {
            filename = base_path.."/electric-furnace-reflection.png",
            priority = "extra-high",
            width = 24,
            height = 24,
            shift = util.by_pixel(5, 40),
            variation_count = 1,
            scale = 5
        },
        rotate = false,
        orientation_to_variation = false
    }
}

local trashcan_entity = {
    type = "furnace",
    name = "priyutils-trashcan",
    icon = "__PriyUtils__/graphics/icons/trashcan/reverse-factory-1.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "priyutils-trashcan"},
    max_health = 300,
    corpse = "small-remnants",
    dying_explosion = "electric-furnace-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    module_slots = 2,
    allowed_effects = {"consumption", "speed"},
    crafting_categories = {"trashcan"},
    result_inventory_size = 1,
    crafting_speed = 10,
    energy_usage = "50kW",
    source_inventory_size = 1,
    fast_replaceable_group = "priyutils-trashcan",
    next_upgrade = "priyutils-advanced-trashcan",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0}
    },
    impact_category = "metal",
    open_sound = sounds.electric_large_open,
    close_sound = sounds.electric_large_close,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-furnace.ogg",
            volume = 0.5,
            modifiers = volume_multiplier("main-menu", 4.2),
            advanced_volume_control = {attenuation = "exponential"}
        },
        max_sounds_per_type = 4,
        audible_distance_modifier = 0.7,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    graphics_set = basic_graphics_set
}

local advanced_trashcan_entity = {
    type = "furnace",
    name = "priyutils-advanced-trashcan",
    icon = "__PriyUtils__/graphics/icons/trashcan/reverse-factory-3.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "priyutils-advanced-trashcan"},
    max_health = 800,
    corpse = "medium-remnants",
    dying_explosion = "electric-furnace-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    module_slots = 4,
    allowed_effects = {"consumption", "speed"},
    crafting_categories = {"trashcan", "trashcan-fluid"},
    result_inventory_size = 1,
    crafting_speed = 40,
    energy_usage = "300kW",
    source_inventory_size = 1,
    fast_replaceable_group = "priyutils-trashcan",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0}
    },
    impact_category = "metal",
    open_sound = sounds.electric_large_open,
    close_sound = sounds.electric_large_close,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-furnace.ogg",
            volume = 0.7,
            modifiers = volume_multiplier("main-menu", 4.2),
            advanced_volume_control = {attenuation = "exponential"}
        },
        max_sounds_per_type = 4,
        audible_distance_modifier = 0.7,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    graphics_set = advanced_graphics_set,
    fluid_boxes = {
        {
            production_type = "input",
            pipe_picture = assembler3pipepictures(),
            pipe_covers = pipecoverspictures(),
            volume = 2000,
            pipe_connections = {
                {
                    flow_direction = "input-output",
                    direction = defines.direction.north,
                    position = {-1, -1}
                },
                {
                    flow_direction = "input-output",
                    direction = defines.direction.north,
                    position = {1, -1}
                }
            }
        }
    }
}

data:extend({
    trashcan_entity,
    advanced_trashcan_entity,
    {
        type = "recipe-category",
        name = "trashcan"
    },
    {
        type = "recipe-category",
        name = "trashcan-fluid"
    }
})
