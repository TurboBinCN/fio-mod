local data_util = require("data_util")
--[[
]]

local blank = {
  filename = "__space-exploration-graphics__/graphics/blank.png",
  priority = "high",
  frame_count = 1,
  height = 1,
  width = 1,
  direction_count = 1,
  -- variation_count = 1
}
local blank_explosion = {
  filename = "__space-exploration-graphics__/graphics/blank.png",
  priority = "high",
  frame_count = 1,
  height = 1,
  width = 1,
  -- direction_count = 1,
  -- variation_count = 1
}

local shadow = {
  draw_as_shadow = true,
  filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-shadow.png",
  priority = "high",
  width = 2304,
  height = 1344,
  frame_count = 1,
  line_length = 1,
  repeat_count = 1,
  shift = util.by_pixel(6*32, 2*32 + 16),
  animation_speed = 0.5,
  scale = 0.5
}

local hidden_switch = table.deepcopy(data.raw["power-switch"]["power-switch"])
hidden_switch.name = data_util.mod_prefix .. "space-elevator-power-switch"
hidden_switch.localised_description = {"entity-name."..data_util.mod_prefix.."space-elevator-power-switch"}
hidden_switch.collision_mask = {layers={}}
hidden_switch.working_sound = nil
hidden_switch.draw_copper_wires = false
hidden_switch.power_on_animation = blank
hidden_switch.overlay_start = blank
hidden_switch.overlay_loop = blank
hidden_switch.led_on = blank
hidden_switch.led_off = blank
hidden_switch.selectable_in_game = false
hidden_switch.hidden = true
data_util.concatenate_tables(hidden_switch.flags, {"hide-alt-info", "not-repairable", "not-blueprintable", "not-deconstructable", "not-on-map", "not-in-kill-statistics"})

data:extend({
  hidden_switch,
  {
    type = "simple-entity",
    name = data_util.mod_prefix .. "space-elevator-train-collider",
    localised_name = {"entity-name."..data_util.mod_prefix.."space-elevator-collider"},
    subgroup = "composite-entity-parts",
    order = "a",
    icons = data_util.add_icons(
      "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
      {icon = data.raw.locomotive.locomotive.icon, shift = {5,7}},
      {icon = "__base__/graphics/icons/signal/signal-alert.png", shift = {9,7}}
    ),
    flags = {"hide-alt-info", "not-repairable", "not-blueprintable", "not-deconstructable", "not-on-map", "not-in-kill-statistics"},
    hidden = true,
    collision_box = {{-2,-3}, {2,3}},
    selection_box = {{-2,-3}, {2,3}},
    selection_priority = 100,
    collision_mask = {
      layers = {
        train = true,
      },
    },
    picture = blank,
    resistances =
    { -- AOE is the main concern
      { type = "fire", percent = 100 },
      { type = "explosion", percent = 100 },
      { type = "poison", percent = 100 },
      { type = "laser", percent = 100 },
      { type = "meteor", percent = 100 },
      { type = "acid", percent = 100 },
    },
    max_health = 1,
    selectable_in_game = false,
  },

  {
    type = "item",
    name = data_util.mod_prefix .. "space-elevator",
    icon = "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
    icon_size = 64,
    order = "s-a-z",
    subgroup = "elevator-logistics",
    stack_size = 1,
    place_result = data_util.mod_prefix .. "space-elevator",
  },
  {
    type = "item",
    name = data_util.mod_prefix .. "space-elevator-cable",
    icon = "__space-exploration-graphics-5__/graphics/icons/space-elevator-cable.png",
    icon_size = 64,
    order = "t",
    subgroup = "intersurface-part",
    stack_size = 20,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-elevator-cable",
    results = {
      {type = "item", name = data_util.mod_prefix .. "space-elevator-cable", amount = 1},
    },
    enabled = false,
    energy_required = 5,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 1 },
      {type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 1 },
      {type = "item", name = "coal", amount = 2 }, -- for graphene
      {type = "item", name = data_util.mod_prefix .. "aeroframe-pole", amount = 3 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    allow_productivity = true,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-elevator-cable-nano",
    localised_name = {"item-name."..data_util.mod_prefix.."space-elevator-cable"},
    icons = data_util.sub_icons("__space-exploration-graphics-5__/graphics/icons/space-elevator-cable.png",
                                data.raw.item[data_util.mod_prefix .. "nanomaterial"].icon),
    results = {
      {type = "item", name = data_util.mod_prefix .. "space-elevator-cable", amount = 20},
    },
    enabled = false,
    energy_required = 40,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 4 },
      {type = "item", name = data_util.mod_prefix .. "aeroframe-pole", amount = 4 },
      {type = "item", name = data_util.mod_prefix .. "superconductive-cable", amount = 1},
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    allow_productivity = true,
    hide_from_signal_gui = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-elevator",
    results = {
      {type = "item", name = data_util.mod_prefix .. "space-elevator", amount = 1},
    },
    enabled = false,
    energy_required = 60,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 500 },
      {type = "item", name = data_util.mod_prefix .. "heavy-bearing", amount = 100 },
      {type = "item", name = "processing-unit", amount = 500 },
      {type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 500 },
      {type = "item", name = "refined-concrete", amount = 1000 },
      {type = "item", name = data_util.mod_prefix .. "aeroframe-pole", amount = 2000 },
    },
    requester_paste_multiplier = 1,
    always_show_made_in = false,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "space-elevator-maintenance",
    icon = "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
    icon_size = 64,
    enabled = false,
    energy_required = 0.25,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "space-elevator-cable", amount = 1 },
    },
    results = {},
    requester_paste_multiplier = 1,
    always_show_made_in = false,
    hidden = true,
    category = "space-elevator",
    subgroup = "spaceship-process",
  },
  {
    type = "technology",
    name = data_util.mod_prefix .. "space-elevator",
    effects = {
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "space-elevator" },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "space-elevator-cable" },
      { type = "unlock-recipe", recipe =  data_util.mod_prefix .. "space-elevator-maintenance" },
    },
    icon = "__space-exploration-graphics-5__/graphics/technology/space-elevator.png",
    icon_size = 256,
    order = "e-g",
    prerequisites = {
      data_util.mod_prefix .. "aeroframe-pole",
      data_util.mod_prefix .. "heavy-bearing",
      data_util.mod_prefix .. "holmium-cable",
    },
    unit = {
     count = 2000,
     time = 60,
     ingredients = {
       { "automation-science-pack", 1 },
       { "logistic-science-pack", 1 },
       { "chemical-science-pack", 1 },
       { data_util.mod_prefix.."rocket-science-pack", 1 },
       { data_util.mod_prefix.."energy-science-pack-1", 1 },
       { data_util.mod_prefix.."astronomic-science-pack-1", 1 },
       { data_util.mod_prefix.."material-science-pack-2", 1 },
     }
    },
  },
  {
    type = "technology",
    name = data_util.mod_prefix .. "space-elevator-cable-nano",
    effects = {
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "space-elevator-cable-nano" },
    },
    icon = "__space-exploration-graphics-5__/graphics/technology/space-elevator.png",
    icon_size = 256,
    order = "e-g",
    prerequisites = {
      data_util.mod_prefix .. "nanomaterial",
      data_util.mod_prefix .. "superconductive-cable",
      data_util.mod_prefix .. "space-elevator"
    },
    unit = {
     count = 500,
     time = 60,
     ingredients = {
       { "automation-science-pack", 1 },
       { "logistic-science-pack", 1 },
       { "chemical-science-pack", 1 },
       { data_util.mod_prefix.."rocket-science-pack", 1 },
       { data_util.mod_prefix.."energy-science-pack-4", 1 },
       { data_util.mod_prefix.."astronomic-science-pack-4", 1 },
       { data_util.mod_prefix.."material-science-pack-4", 1 },
       { data_util.mod_prefix.."biological-science-pack-4", 1 },
     }
    },
  },
  {
    type = "simple-entity",
    name = data_util.mod_prefix .. "space-elevator-blocker-vertical",
    subgroup = "composite-entity-parts",
    order = "a",
    hidden = true,
    icons = data_util.add_icons(
      "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
      "__base__/graphics/icons/signal/signal-no-entry.png"
    ),
    flags = { "placeable-neutral", "placeable-off-grid", "not-repairable" },
    picture = blank,
    collision_mask = {
      layers = {
        player = true,
      },
    },
    collision_box = data_util.auto_box(2, 8, 0.1),
    selection_box = data_util.auto_box(2, 8, 0),
    selectable_in_game = false,
    localised_name = {"entity-name."..data_util.mod_prefix.."space-elevator"}
  },
  {
    type = "simple-entity",
    name = data_util.mod_prefix .. "space-elevator-blocker-horizontal",
    subgroup = "composite-entity-parts",
    order = "a",
    hidden = true,
    icons = data_util.add_icons(
      "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
      "__base__/graphics/icons/signal/signal-no-entry.png"
    ),
    flags = { "placeable-neutral", "placeable-off-grid", "not-repairable" },
    picture = blank,
    collision_mask = {
      layers = {
        player = true,
      },
    },
    collision_box = data_util.auto_box(8, 2, 0.1),
    selection_box = data_util.auto_box(8, 2, 0),
    selectable_in_game = false,
    localised_name = {"entity-name."..data_util.mod_prefix.."space-elevator"}
  },
  --[[{
      type = "car",
      name = data_util.mod_prefix .. "space-elevator-blocker",
      icon = "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
      icon_size = 64,
      allow_passengers = false,
      collision_mask = {
        layers = {
          player = true,
          [vehicle_collision_layer] = true,
        },
      },
      collision_box = data_util.auto_box(2, 8, 0.1),
      selection_box = data_util.auto_box(2, 8, 0),
      animation = blank,
      braking_power = "1000kW",
      flags = {
        "placeable-neutral",
        "building-direction-8-way",
        "placeable-off-grid",
        "not-repairable"
      },
      energy_source = {
        type = "void"
      },
      consumption = "0W",
      efficiency = 0.5,
      energy_per_hit_point = 1,
      friction = 1,
      inventory_size = 0,
      max_health = 5000,
      alert_when_damaged = false,
      healing_per_tick = 1,
      render_layer = "object",
      rotation_speed = 0.00,
      order = "zz",
      selectable_in_game = false,
      weight = 700,
      minimap_representation = blank,
      selected_minimap_representation = blank,
      has_belt_immunity = true,
      hide_resistances = true,
      repair_speed_modifier = 0,
  },]]
  {
    type = "lamp",
    name = data_util.mod_prefix .. "space-elevator-lamp",
    subgroup = "composite-entity-parts",
    order = "a",
    hidden = true,
    icons = data_util.add_icons(
      "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
      data.raw.item["small-lamp"].icon
    ),
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      render_no_power_icon = false,
      render_no_network_icon = false,
    },
    energy_usage_per_tick = "100kW",
    picture_off = blank,
    picture_on = blank,
    always_on = true,
    --darkness_for_all_lamps_off = 0,
    --darkness_for_all_lamps_on = 0,
    collision_mask = {layers={}},
    collision_box = data_util.auto_box(24, 24, 0.1),
    selection_box = data_util.auto_box(24, 24, 0),
    selectable_in_game = false,
    light = {
      type = "basic",
      intensity = 1,
      size = 48,
      color = {r=1,g=0.95,b=0.9},
    }
  },
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "space-elevator",
    icon = "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
    icon_size = 64,
    minable = {mining_time = 5, result = data_util.mod_prefix .. "space-elevator"},
    flags = {"placeable-neutral","placeable-player", "player-creation", "hide-alt-info"},
    max_health = 10000,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = data_util.auto_box(23.9, 24, 0.2), -- non square needed to be diractional
    selection_box = data_util.auto_box(24, 24, 0),
    selection_priority = 50,
    build_grid_size = 2,
    resistances =
    {
      { type = "meteor", percent = 90 },
      { type = "impact", percent = 100 },
      { type = "fire", percent = 100 }
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound = {
      apparent_volume = 1.5,
      fade_in_ticks = 10,
      fade_out_ticks = 15,
      idle_sound = {
        audible_distance_modifier = 3,
        filename = "__base__/sound/rocket-silo-working-2.ogg",
        volume = 0.5
      },
      sound = {
        audible_distance_modifier = 3,
        filename = "__base__/sound/rocket-silo-working-1.ogg",
        volume = 0.8
      }
    },
    collision_mask = {
      layers = {
        water_tile = true,
        item = true,
        floor = true,
        --[vehicle_collision_layer] = true, ?
        --object = true,
        --player = true,
        [spaceship_collision_layer] = true,
      },
    },
    integration_patch_render_layer = "lower-object-above-shadow", -- default
    integration_patch = {
      north = {
        layers = {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-left.png",
            priority = "high",
            width = 1664,
            height = 1664,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 0),
            scale = 0.5
          },
        },
      },
      east = {
        layers = {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-right.png",
            priority = "high",
            width = 1664,
            height = 1664,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 0),
            scale = 0.5
          },
        },
      },
      south = {
        layers = {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-right.png",
            priority = "high",
            width = 1664,
            height = 1664,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 0),
            scale = 0.5
          },
        },
      },
      west = {
        layers = {
          {
            filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-left.png",
            priority = "high",
            width = 1664,
            height = 1664,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 0),
            scale = 0.5
          },
        },
      },
    },
    graphics_set = {
      animation =
      {
        north = {
          layers = {
            {
              filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-left-top.png",
              priority = "high",
              width = 1664,
              height = 1664,
              frame_count = 1,
              line_length = 1,
              shift = util.by_pixel(0, 0),
              scale = 0.5
            },
            shadow
          },
        },
        east = {
          layers = {
            {
              filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-right-top.png",
              priority = "high",
              width = 1664,
              height = 1664,
              frame_count = 1,
              line_length = 1,
              shift = util.by_pixel(0, 0),
              scale = 0.5
            },
            shadow
          },
        },
        south = {
          layers = {
            {
              filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-right-top.png",
              priority = "high",
              width = 1664,
              height = 1664,
              frame_count = 1,
              line_length = 1,
              shift = util.by_pixel(0, 0),
              scale = 0.5
            },
            shadow
          },
        },
        west = {
          layers = {
            {
              filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-left-top.png",
              priority = "high",
              width = 1664,
              height = 1664,
              frame_count = 1,
              line_length = 1,
              shift = util.by_pixel(0, 0),
              scale = 0.5
            },
            shadow
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.5, size = 8, shift = {0.0, 0.0}, color = {r = 1, g = 1, b = 1}}
        },
      },
    },
    crafting_categories = {"space-elevator"},
    fixed_recipe = data_util.mod_prefix .. "space-elevator-maintenance",
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "1000kW",
    squeak_behaviour = false -- Squeak Through prevents rotating without this
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "space-elevator-left",
    filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-left-top.png",
    priority = "high",
    width = 1664,
    height = 1664,
    frame_count = 1,
    line_length = 1,
    shift = util.by_pixel(0, 0),
    scale = 0.5
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "space-elevator-right",
    filename = "__space-exploration-graphics-5__/graphics/entity/space-elevator/space-elevator-right-top.png",
    priority = "high",
    width = 1664,
    height = 1664,
    frame_count = 1,
    line_length = 1,
    shift = util.by_pixel(0, 0),
    scale = 0.5
  },
  {
    type = "electric-energy-interface",
    name = data_util.mod_prefix .. "space-elevator-energy-interface", -- input
    subgroup = "composite-entity-parts",
    hidden = true,
    icons = data_util.add_icons(
      "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
      "__base__/graphics/icons/accumulator.png"
    ),
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable", "not-blueprintable"},
    order = "b-a",
    selectable_in_game = false,
    collision_mask = {layers = {}},
    collision_box = data_util.auto_box(23.95, 24, 0.2),
    selection_box = data_util.auto_box(24, 24, 0),
    energy_source = {
      buffer_capacity = "20GJ",
      input_flow_limit = "600MW",
      output_flow_limit = "0GW",
      type = "electric",
      render_no_power_icon = false,
      render_no_network_icon = false,
      usage_priority = "secondary-input"--"tertiary"
    },
    --energy_usage = "10MW"
  },
  {
    type = "electric-pole",
    name = data_util.mod_prefix .. "space-elevator-energy-pole",
    subgroup = "composite-entity-parts",
    hidden = true,
    icons = data_util.add_icons(
      "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
      "__space-exploration-graphics__/graphics/icons/addon-power-pole.png"
    ),
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable", "not-blueprintable"},
    order = "b-a",
    collision_mask = {layers = {}},
    collision_box = data_util.auto_box(23.95, 24, 0.2),
    selection_box = data_util.auto_box(6, 6, 0),
    selection_priority = 52,
    selectable_in_game = true,
    open_sound = data_util.electric_network_open_sound,
    close_sound = data_util.electric_network_close_sound,
    supply_area_distance = 12,
    connection_points = {
      {
        shadow = {
          copper = { 1.1-0.1, 0.1 },
          green = { 1.1+0.1, 0.1-0.4 },
          red = { 1.1-0.15, 0.1-0.3  }
        },
        wire = {
          copper = { 0+0.1, -2.3-0.2 },
          green = {  0+0.2, -2.3-0.5 },
          red = {  0-0.25, -2.3-0.4 }
        }
      },
    },
    maximum_wire_distance = 32,
    pictures = blank,
    radius_visualisation_picture = {
      filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
      height = 12,
      priority = "extra-high-no-scale",
      width = 12
    },
  },
  {
    type = "item",
    name = data_util.mod_prefix .. "space-elevator-connection-blocker",
    icon = "__space-exploration-graphics__/graphics/blank.png",
    stack_size = 1,
    place_result = data_util.mod_prefix .. "space-elevator-connection-blocker",
    hidden = true,
    hidden_in_factoriopedia = true
  },
  {
    type = "cargo-wagon",
    name = data_util.mod_prefix .. "space-elevator-connection-blocker",
    subgroup = "composite-entity-parts",
    order = "b",
    flags = {"not-deconstructable", "player-creation", "placeable-off-grid", "placeable-neutral"},
    hidden = true,
    hidden_in_factoriopedia = true,
    icons = data_util.add_icons(
      "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
      data.raw.locomotive.locomotive.icon
    ),
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selectable_in_game = false,
    inventory_size = 0,
    connection_distance = 0,
    joint_distance = 0.1,
    max_speed = 1,
    air_resistance = 0,
    weight = 20000,
    braking_force = 10,
    friction_force = 0.5,
    vertical_selection_shift = -0.5,
    energy_per_hit_point = 1,
    collision_mask = {
      layers = {
        ["train"] = true
      },
    }
  },
  {
    type = "locomotive",
    name = data_util.mod_prefix .. "space-elevator-tug",
    subgroup = "composite-entity-parts",
    order = "b",
    flags = {"not-blueprintable", "not-deconstructable"},
    hidden = true,
    icons = data_util.add_icons(
      "__space-exploration-graphics-5__/graphics/icons/space-elevator.png",
      data.raw.locomotive.locomotive.icon
    ),
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selectable_in_game = false,
    selection_priority = 52,
    air_resistance = 0,
    friction_force = 0.5,
    connection_distance = 0,
    joint_distance = 0.1,
    max_health = 1000,
    energy_per_hit_point = 1,
    weight = 20000,
    max_power = "10000kW",
    max_speed = 1,
    reversing_power_modifier = 1,
    braking_force = 10,
    energy_source = {type = "void"},
    pictures = {rotated = blank},
    vertical_selection_shift = -0.5,
    collision_mask = {
      layers = {
        ["train"] = true
      },
      colliding_with_tiles_only = true
    }
  },
})

local function internalise(prototype)
  prototype.minable = nil
  prototype.placeable_by = nil
  prototype.flags = {"hide-alt-info", "not-repairable", "not-blueprintable", "not-deconstructable", "not-on-map", "not-in-kill-statistics"}
  prototype.hidden = true
  prototype.selectable_in_game = false
  prototype.animations = nil
  prototype.light1 = nil
  prototype.light2 = nil
  prototype.rail_overlay_animations = nil
  prototype.top_animations = nil
  prototype.next_upgrade = nil
  prototype.fast_replaceable_group = nil
  if prototype.pictures and prototype.pictures.straight_rail_horizontal then
    local layers = {metals = blank, backplates=blank, ties=blank, stone_path=blank}
    prototype.pictures.straight_rail_horizontal = layers
    prototype.pictures.straight_rail_vertical = layers
    prototype.pictures.straight_rail_diagonal_left_top = layers
    prototype.pictures.straight_rail_diagonal_right_top = layers
    prototype.pictures.straight_rail_diagonal_right_bottom = layers
    prototype.pictures.straight_rail_diagonal_left_bottom = layers
    prototype.pictures.curved_rail_vertical_left_top = layers
    prototype.pictures.curved_rail_vertical_right_top = layers
    prototype.pictures.curved_rail_vertical_right_bottom = layers
    prototype.pictures.curved_rail_vertical_left_bottom = layers
    prototype.pictures.curved_rail_horizontal_left_top = layers
    prototype.pictures.curved_rail_horizontal_right_top = layers
    prototype.pictures.curved_rail_horizontal_right_bottom = layers
    prototype.pictures.curved_rail_horizontal_left_bottom = layers
    prototype.pictures.rail_endings = {
      north = blank,
      north_east = blank,
      east = blank,
      south_east = blank,
      south = blank,
      south_west = blank,
      west = blank,
      north_west = blank,
    }
  end
end

local internal_trainstop = table.deepcopy(data.raw["train-stop"]["train-stop"])
internal_trainstop.name = data_util.mod_prefix.."space-elevator-train-stop"
internalise(internal_trainstop)

local internal_straight_rail = table.deepcopy(data.raw["legacy-straight-rail"]["legacy-straight-rail"])
internal_straight_rail.name = data_util.mod_prefix.."space-elevator-legacy-straight-rail"
internalise(internal_straight_rail)

local internal_curved_rail = table.deepcopy(data.raw["legacy-curved-rail"]["legacy-curved-rail"])
internal_curved_rail.name = data_util.mod_prefix.."space-elevator-legacy-curved-rail"
internalise(internal_curved_rail)

local internal_rail_signal = table.deepcopy(data.raw["rail-signal"]["rail-signal"])
internal_rail_signal.name = data_util.mod_prefix.."space-elevator-rail-signal"
internalise(internal_rail_signal)

data:extend({internal_trainstop, internal_straight_rail, internal_curved_rail, internal_rail_signal})
