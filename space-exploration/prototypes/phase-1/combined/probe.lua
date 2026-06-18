local data_util = require("data_util")

data:extend({
  {
    type = "item",
    name = data_util.mod_prefix.."space-probe-rocket-silo",
    icon = "__space-exploration-graphics__/graphics/icons/probe-rocket-silo.png",
    icon_size = 64,
    order = "a-b",
    subgroup = "rocket-logistics",
    stack_size = 1,
    place_result = data_util.mod_prefix.."space-probe-rocket-silo",
  },
  {
    type = "item",
    name = data_util.mod_prefix.."space-probe-rocket",
    icon = "__space-exploration-graphics__/graphics/icons/probe-rocket.png",
    icon_size = 64,
    order = "r-a",
    subgroup = "intersurface-part",
    stack_size = 1,
  },
  {
    type = "item",
    name = data_util.mod_prefix .. "space-probe-rocket-deployed",
    icon = "__space-exploration-graphics__/graphics/icons/probe-rocket.png",
    icon_size = 64,
    order = "r-b",
    stack_size = 1,
    subgroup = "intersurface-part",
    flags = {},
    hidden = true,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix.."space-probe-rocket-silo",
    results = {
      {type = "item", name = data_util.mod_prefix.."space-probe-rocket-silo", amount = 1},
    },
    enabled = false,
    energy_required = 50,
    ingredients = {
      {type = "item", name = "electric-engine-unit", amount = 200 },
      {type = "item", name = "processing-unit", amount = 200 },
      {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 200 },
      {type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 200 },
      {type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 100 },
      {type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 100 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix.."space-probe-rocket",
    results = {
      {type = "item", name = data_util.mod_prefix.."space-probe-rocket", amount = 1},
    },
    enabled = false,
    energy_required = 100,
    ingredients = {
      {type = "item", name = data_util.mod_prefix.."cargo-rocket-section", amount = 10 },
      {type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 50 },
      {type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 20 },
      {type = "item", name = data_util.mod_prefix .. "holmium-solenoid", amount = 5 },
      {type = "item", name = "rocket-fuel", amount = 50 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    allow_productivity = true,
  },
  {
    -- the dummy recipe for ethe rcoket silo section, required for launch
    -- the component is inserted then the launch pad has the required parts.
    type = "recipe",
    name = data_util.mod_prefix.."space-probe-rocket-deploy",
    localised_name = {"recipe-name."..data_util.mod_prefix.."space-probe-rocket-deployed"},
    results = {
      {type = "item", name = data_util.mod_prefix .. "space-probe-rocket-deployed", amount = 1}
    },
    category = "rocket-deploying",
    subgroup = "intersurface-part",
    enabled = false,
    energy_required = 100,
    ingredients = {
      {type = "item", name = data_util.mod_prefix.."space-probe-rocket", amount = 1} -- could be anything really
    },
    always_show_made_in = true,
  },
  {
      type = "technology",
      name = data_util.mod_prefix .. "space-probe",
      effects = {
        { type = "unlock-recipe", recipe = data_util.mod_prefix.."space-probe-rocket-silo"},
        { type = "unlock-recipe", recipe = data_util.mod_prefix.."space-probe-rocket" },
      },
      icon = "__space-exploration-graphics__/graphics/technology/probe-rocket.png",
      icon_size = 128,
      order = "e-g",
      prerequisites = {
        data_util.mod_prefix .. "aeroframe-scaffold",
        data_util.mod_prefix .. "holmium-solenoid",
        data_util.mod_prefix .. "heavy-girder",
      },
      unit = {
       count = 200,
       time = 60,
       ingredients = {
         { "automation-science-pack", 1 },
         { "logistic-science-pack", 1 },
         { "chemical-science-pack", 1 },
         { data_util.mod_prefix .. "rocket-science-pack", 1 },
         { data_util.mod_prefix .. "astronomic-science-pack-2", 1 },
         { data_util.mod_prefix .. "energy-science-pack-2", 1 },
       }
     }
  },
  {
    type = "rocket-silo",
    name = data_util.mod_prefix.."space-probe-rocket-silo",
    icon = "__space-exploration-graphics__/graphics/icons/probe-rocket-silo.png",
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    crafting_categories = {"rocket-deploying"},
    rocket_parts_required = 1,
    rocket_quick_relaunch_start_offset = -0.625,
    can_launch_without_landing_pads = true,
    cargo_station_parameters =
    {
      hatch_definitions =
      {
        {
          hatch_graphics = nil,
          offset = {0, 0},
          pod_shadow_offset = {0, 0}; --flush with ground
          cargo_unit_entity_to_spawn = "", --silo defines the lift pod
          receiving_cargo_units = {}
        }
      },
    },
    crafting_speed = 1,
    to_be_inserted_to_rocket_inventory_size = 1,
    --rocket_result_inventory_size = 40,
    module_slots = 4,
    icons_positioning =
    {
      {inventory_index = defines.inventory.crafter_modules, shift = {0, 3.3}}
    },
    fixed_recipe = data_util.mod_prefix.."space-probe-rocket-deploy",
    show_recipe_icon = false,
    allowed_effects = data_util.all_effects_except("productivity", "quality"),
    minable = {mining_time = 1, result = data_util.mod_prefix.."space-probe-rocket-silo"},
    max_health = 5000,
    corpse = "rocket-silo-remnants",
    dying_explosion = "rocket-silo-explosion",
    collision_box = {{-4.20, -4.20}, {4.20, 4.20}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
        [spaceship_collision_layer] = true
      },
    },
    se_allow_in_space = true,
    damaged_trigger_effect = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"].damaged_trigger_effect),
    hole_clipping_box = { {-2.75, -1.15}, {2.75, 2.25} },
    resistances =
    {
      {
        type = "fire",
        percent = 60
      },
      {
        type = "impact",
        percent = 60
      }
    },
    impact_category = "metal-large",
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-input"
    },
    energy_usage = "250kW", --energy usage used when crafting the rocket
    lamp_energy_usage = "0kW",
    active_energy_usage = "3990kW",
    rocket_entity = data_util.mod_prefix.."space-probe-rocket",
    times_to_blink = 3,
    light_blinking_speed = 1 / (3 * 60),
    door_opening_speed = 1 / (4.25 * 60),

    base_engine_light =
    {
      intensity = 1,
      size = 25,
      shift = {0, 1.5}
    },

    shadow_sprite =
    {
      filename = "__base__/graphics/entity/rocket-silo/00-rocket-silo-shadow.png",
      priority = "medium",
      width = 612,
      height = 578,
      draw_as_shadow = true,
      dice = 2,
      shift = util.by_pixel(7, 2),
      scale = 0.5
    },

    hole_sprite =
    {
      filename = "__base__/graphics/entity/rocket-silo/01-rocket-silo-hole.png",
      width = 400,
      height = 270,
      shift = util.by_pixel(-5, 16),
      scale = 0.5
    },
    hole_light_sprite =
    {
      filename = "__base__/graphics/entity/rocket-silo/01-rocket-silo-hole-light.png",
      width = 400,
      height = 270,
      shift = util.by_pixel(-5, 16),
      tint = {1,1,1,0},
      scale = 0.5
    },

    rocket_shadow_overlay_sprite =
    {
      filename = "__base__/graphics/entity/rocket-silo/03-rocket-over-shadow-over-rocket.png",
      width = 426,
      height = 288,
      shift = util.by_pixel(-2, 21),
      scale = 0.5
    },
    rocket_glow_overlay_sprite =
    {
      filename = "__base__/graphics/entity/rocket-silo/03-rocket-over-glow.png",
      blend_mode = "additive",
      width = 434,
      height = 446,
      shift = util.by_pixel(-3, 36),
      scale = 0.5
    },

    door_back_sprite =
    {
      filename = "__base__/graphics/entity/rocket-silo/04-door-back.png",
      width = 312,
      height = 286,
      shift = util.by_pixel(37, 12),
      scale = 0.5
    },
    door_back_open_offset = {1.8, -1.8 * 0.43299225},
    door_front_sprite =
    {
      filename = "__base__/graphics/entity/rocket-silo/05-door-front.png",
      width = 332,
      height = 300,
      shift = util.by_pixel(-28, 33),
      scale = 0.5
    },
    door_front_open_offset = {-1.8, 1.8 * 0.43299225},

    base_day_sprite = {layers = {
      {
        filename = "__base__/graphics/entity/rocket-silo/06-rocket-silo.png",
        width = 608,
        height = 596,
        shift = util.by_pixel(3, -1),
        scale = 0.5
      },
      {
        filename = "__space-exploration-graphics-5__/graphics/entity/probe/06-rocket-silo-mask.png",
        width = 608,
        height = 596,
        shift = util.by_pixel(3, -1),
        tint = {r=0.4,b=0.9,g=0.6},
        scale = 0.5
      },
    }},
    red_lights_back_sprites =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {1.34375, 0.28125-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {2.3125, 0.9375-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {2.65625, 1.90625-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {-2.65625, 1.90625-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {-2.3125, 0.9375-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {-1.34375, 0.28125-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {0, 0-1.375},
          scale = 0.5
        }
      }
    },

    red_lights_front_sprites =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {2.3125, 2.8125-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {1.34375, 3.40625-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {0, 3.75-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {0, 3.75-1.375},
          scale = 0.5
        },
        {
          filename = "__base__/graphics/entity/rocket-silo/07-red-lights-back/red-light.png",
          width = 32,
          height = 32,
          shift = {-2.3125, 2.8125-1.375},
          scale = 0.5
        }
      }
    },
    satellite_animation =
    {
      filename = "__base__/graphics/entity/rocket-silo/15-rocket-silo-turbine.png",
      priority = "medium",
      width = 54,
      height = 88,
      frame_count = 32,
      line_length = 8,
      animation_speed = 0.4,
      shift = util.by_pixel(-100, 111),
      scale = 0.5
    },

    arm_01_back_animation =
    {
      filename = "__base__/graphics/entity/rocket-silo/08-rocket-silo-arms-back.png",
      priority = "medium",
      width = 128,
      height = 150,
      frame_count = 32,
      line_length = 32,
      animation_speed = 0.3,
      shift = util.by_pixel(-53, -84),
      scale = 0.5
    },

    arm_02_right_animation =
    {
      filename = "__base__/graphics/entity/rocket-silo/08-rocket-silo-arms-right.png",
      priority = "medium",
      width = 182,
      height = 188,
      frame_count = 32,
      line_length = 32,
      animation_speed = 0.3,
      shift = util.by_pixel(101, -38),
      scale = 0.5
    },

    arm_03_front_animation =
    {
      filename = "__base__/graphics/entity/rocket-silo/13-rocket-silo-arms-front.png",
      priority = "medium",
      width = 126,
      height = 228,
      frame_count = 32,
      line_length = 32,
      animation_speed = 0.3,
      shift = util.by_pixel(-51, 16),
      scale = 0.5
    },

    base_front_sprite = {
      layers = {
        {
          filename = "__base__/graphics/entity/rocket-silo/14-rocket-silo-front.png",
          width = 580,
          height = 262,
          shift = util.by_pixel(-1, 78),
          scale = 0.5
        },
        {
          filename = "__space-exploration-graphics-5__/graphics/entity/probe/14-rocket-silo-front-mask.png",
          width = 580,
          height = 262,
          shift = util.by_pixel(-1, 78),
          tint = {r=0.4,b=0.9,g=0.6},
          scale = 0.5
        },
      }
    },
    silo_fade_out_start_distance = 8,
    silo_fade_out_end_distance = 15,

    alarm_sound =
    {
      filename = "__base__/sound/silo-alarm.ogg",
      volume = 1.0
    },
    clamps_on_sound =
    {
      filename = "__base__/sound/silo-clamps-on.ogg",
      volume = 1.0
    },
    clamps_off_sound =
    {
      filename = "__base__/sound/silo-clamps-off.ogg",
      volume = 0.8
    },
    doors_sound =
    {
      filename = "__base__/sound/silo-doors.ogg",
      volume = 0.8
    },
    raise_rocket_sound =
    {
      filename = "__base__/sound/silo-raise-rocket.ogg",
      volume = 1.0
    },
    open_sound = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"].open_sound),
    close_sound = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"].close_sound),
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/rocket-silo-working-1.ogg",
        volume = 0.8
      },
      fade_in_ticks = 10,
      fade_out_ticks = 15,
    }

  },
  {
    type = "rocket-silo-rocket",
    name = data_util.mod_prefix.."space-probe-rocket",
    subgroup = "rocket-effects",
    hidden = true,
    flags = {"not-on-map"},
    collision_mask = {
      layers = {},
      not_colliding_with_itself = true,
    },
    collision_box = {{-2, -7}, {2, 4}},
    selection_box = {{0, 0}, {0, 0}},
    dying_explosion = "massive-explosion",
    shadow_slave_entity = "rocket-silo-rocket-shadow",
    inventory_size = 1,
    rising_speed = 1 / (7 * 60),
    engine_starting_speed = 1 / (5.5 * 60),
    flying_speed = 1 / (2000 * 60),
    flying_acceleration = 0.01,
    cargo_pod_entity = "cargo-pod",
    glow_light =
    {
      intensity = 1,
      size = 30,
      shift = {0, 1.5},
      color = {r = 1.0, g = 1.0, b = 1.0}
    },

    rocket_sprite = util.add_shift_offset(util.by_pixel(0, 32*3.5), --util.mul_shift(rocket_rise_offset, -1),
    {
      filename = "__space-exploration-graphics-5__/graphics/entity/probe/probe-rocket.png",
      width = 310,
      height = 596,
      shift = util.by_pixel(-5, -27),
      scale = 0.5
    }),

    rocket_shadow_sprite = util.add_shift_offset(util.by_pixel(-146, -120),
    {
      filename = "__space-exploration-graphics__/graphics/entity/rocket-silo/09-rocket-shadow.png",
      priority = "medium",
      width = 672,
      height = 216,
      draw_as_shadow = true,
      shift = util.by_pixel(146, 121),
      scale = 0.5
    }),

    rocket_glare_overlay_sprite = util.add_shift_offset(util.by_pixel(0, 112+112),
    {
      filename = "__base__/graphics/entity/rocket-silo/03-rocket-over-glare.png",
      blend_mode = "additive",
      width = 481,
      height = 481,
      shift = util.by_pixel(-2, -2),
      flags = { "linear-magnification", "linear-minification" },
      --hr_version =
      --{
      --  filename = "__base__/graphics/entity/rocket-silo/03-rocket-over-glare.png",
      --  blend_mode = "additive",
      --  width = 954,
      --  height = 954,
      --  shift = util.by_pixel(0, 0),
      --  scale = 0.5
      --}
    }),
    rocket_smoke_top1_animation = util.add_shift_offset(util.by_pixel(0-66, -112+28+232+32),
    {
      filename = "__base__/graphics/entity/rocket-silo/12-rocket-smoke.png",
      priority = "medium",
      tint = { r = 0.8, g = 0.8, b = 1, a = 0.8 },
      --tint = { r = 1, g = 0, b = 0, a = 0.8 },
      width = 80,
      height = 286,
      frame_count = 24,
      line_length = 8,
      animation_speed = 0.5,
      scale = 1.5/2*1.3,
      shift = util.by_pixel(-1, -3),
    }),
    rocket_smoke_top2_animation = util.add_shift_offset(util.by_pixel(0+17, -112+28+265+32),
    {
      filename = "__base__/graphics/entity/rocket-silo/12-rocket-smoke.png",
      priority = "medium",
      tint = { r = 0.8, g = 0.8, b = 1, a = 0.8 },
      --tint = { r = 0, g = 1, b = 0, a = 0.8 },
      width = 80,
      height = 286,
      frame_count = 24,
      line_length = 8,
      animation_speed = 0.5,
      scale = 1.5/2*1.3,
      shift = util.by_pixel(-1, -3),
    }),
    rocket_smoke_top3_animation = util.add_shift_offset(util.by_pixel(0+48, -112+28+252+32),
    {
      filename = "__base__/graphics/entity/rocket-silo/12-rocket-smoke.png",
      priority = "medium",
      tint = { r = 0.8, g = 0.8, b = 1, a = 0.8 },
      --tint = { r = 0, g = 0, b = 1, a = 0.8 },
      width = 80,
      height = 286,
      frame_count = 24,
      line_length = 8,
      animation_speed = 0.5,
      scale = 1.5/2*1.3,
      shift = util.by_pixel(-1, -3),
    }),

    rocket_smoke_bottom1_animation = util.add_shift_offset(util.by_pixel(0-69, -112+28+205+32),
    {
      filename = "__base__/graphics/entity/rocket-silo/12-rocket-smoke.png",
      priority = "medium",
      tint = { r = 0.8, g = 0.8, b = 1, a = 0.7 },
      --tint = { r = 1, g = 1, b = 0, a = 0.8 },
      width = 80,
      height = 286,
      frame_count = 24,
      line_length = 8,
      animation_speed = 0.5,
      scale = 1.5/2*1.3,
      shift = util.by_pixel(-1, -3),
    }),
    rocket_smoke_bottom2_animation = util.add_shift_offset(util.by_pixel(0+62, -112+28+207+32),
    {
      filename = "__base__/graphics/entity/rocket-silo/12-rocket-smoke.png",
      priority = "medium",
      tint = { r = 0.8, g = 0.8, b = 1, a = 0.7 },
      --tint = { r = 0, g = 1, b = 1, a = 0.8 },
      width = 80,
      height = 286,
      frame_count = 24,
      line_length = 8,
      animation_speed = 0.5,
      scale = 1.5/2*1.3,
      shift = util.by_pixel(-1, -3),
    }),
    rocket_flame_animation = util.add_shift_offset(util.by_pixel(-1, 280-16),
    {
      filename = "__space-exploration-graphics__/graphics/entity/rocket-silo/10-jet-flame.png",
      priority = "medium",
      blend_mode = "additive",
      width = 172,
      height = 256,
      frame_count = 8,
      line_length = 8,
      animation_speed = 0.5,
      scale = 1.13/2,
      shift = util.by_pixel(-1, -2),
    }),
    rocket_flame_left_animation = util.add_shift_offset(util.by_pixel(-32-28+3, 280-68+1),
    {
      filename = "__space-exploration-graphics__/graphics/entity/rocket-silo/10-jet-flame.png",
      priority = "medium",
      blend_mode = "additive",
      width = 172,
      height = 256,
      frame_count = 8,
      line_length = 8,
      animation_speed = 0.5,
      scale = 0.345/2*1.15,
      shift = util.by_pixel(-1, -2),
    }),
    rocket_flame_left_rotation = 0.0611,

    rocket_flame_right_animation = util.add_shift_offset(util.by_pixel(32+16, 280-50),
    {
      filename = "__space-exploration-graphics__/graphics/entity/rocket-silo/10-jet-flame.png",
      priority = "medium",
      blend_mode = "additive",
      width = 172,
      height = 256,
      frame_count = 8,
      line_length = 8,
      animation_speed = 0.5,
      scale = 0.368/2*1.15,
      shift = util.by_pixel(-1, -2),
    }),
    rocket_flame_right_rotation = 0.952,

    rocket_initial_offset = {0, 1.5},
    rocket_rise_offset = {0, -3.5},
    rocket_launch_offset = {0, -256},
    rocket_render_layer_switch_distance = 7.5,
    full_render_layer_switch_distance = 9,
    effects_fade_in_start_distance = 4.5,
    effects_fade_in_end_distance = 7.5,
    shadow_fade_out_start_ratio = 0.25,
    shadow_fade_out_end_ratio = 0.75,
    rocket_visible_distance_from_center = 2.75,
    rocket_above_wires_slice_offset_from_center = -3,
    rocket_air_object_slice_offset_from_center = -5.5,
    flying_sound =
    {
      filename = "__base__/sound/silo-rocket.ogg",
      volume = 1.0,
      audible_distance_modifier = 3,
    }
  },
})

-- This means that you can: silo.selected.get_inventory(8).insert()
-- but an output inserter will steal the satellite.
-- Silo could be made no-output
-- and then an overlapping output only proxy container could link to inventory 8?
data.raw["rocket-silo"]["rocket-silo"].trash_inventory_size = 20
-- expected in 2.0.44
data.raw["rocket-silo"]["rocket-silo"].can_launch_without_landing_pads = true

--- Base Cargo Pod's inventory can't hold all probe data
data.raw["cargo-pod"]["cargo-pod"].inventory_size = math.max(20, data.raw["cargo-pod"]["cargo-pod"].inventory_size)

if mods["space-age"] then

  -- rocket silo for SA that can be placed outside of zones, on nauvis the SE rocket silo functions just fine for platform interactions.
  local vanilla_rocket_silo = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
  vanilla_rocket_silo.localised_name = {"space-exploration.simple-a-b-space", {"entity-name." .. vanilla_rocket_silo.name}, "[space-age]"}
  vanilla_rocket_silo.localised_description = {"entity-description." .. vanilla_rocket_silo.name}
  vanilla_rocket_silo.placeable_by = {item = vanilla_rocket_silo.name, count = 1}
  vanilla_rocket_silo.name = "sa-" .. vanilla_rocket_silo.name
  vanilla_rocket_silo.hidden = true
  data:extend{vanilla_rocket_silo}

end
