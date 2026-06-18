local data_util = require("data_util")

local blank = {
  direction_count = 8,
  frame_count = 1,
  filename = "__space-exploration-graphics__/graphics/blank.png",
  width = 1,
  height = 1,
  priority = "low"
}

data:extend({

  {
    type = "technology",
    name = data_util.mod_prefix .. "delivery-cannon",
    effects = {
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "delivery-cannon", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "delivery-cannon-chest", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "delivery-cannon-capsule", },
    },
    icon = "__space-exploration-graphics__/graphics/technology/delivery-cannon.png",
    icon_size = 128,
    order = "e-g",
    prerequisites = {
      "explosives",
      data_util.mod_prefix .. "meteor-defence",
      data_util.mod_prefix .. "rocket-science-pack",
    },
    unit = {
     count = 200,
     time = 30,
     ingredients = {
       { "automation-science-pack", 1 },
       { "logistic-science-pack", 1 },
       { "chemical-science-pack", 1 },
       { data_util.mod_prefix .. "rocket-science-pack", 1 },
     }
    },
  },
  {
    type = "technology",
    name = data_util.mod_prefix .. "delivery-cannon-capsule-iridium",
    effects = {
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "delivery-cannon-capsule-iridium", },
    },
    icons = {
      {icon = "__space-exploration-graphics__/graphics/technology/delivery-cannon.png", scale = 1, icon_size = 128, shift = {6, 6}},
      {icon = "__space-exploration-graphics__/graphics/technology/iridium-processing.png", scale = 0.5, icon_size = 128, shift = {-32, -32}},
    },
    order = "e-g",
    prerequisites = {
      "explosives",
      data_util.mod_prefix .. "delivery-cannon",
      data_util.mod_prefix .. "material-science-pack-1"
    },
    unit = {
     count = 100,
     time = 30,
     ingredients = {
       { "automation-science-pack", 1 },
       { "logistic-science-pack", 1 },
       { "chemical-science-pack", 1 },
       { data_util.mod_prefix .. "rocket-science-pack", 1 },
       { data_util.mod_prefix .. "material-science-pack-1", 1 },
     }
    },
  },
  {
    type = "technology",
    name = data_util.mod_prefix .. "delivery-cannon-weapon",
    effects = {
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "delivery-cannon-weapon", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "delivery-cannon-weapon-capsule", },
    },
    icon = "__space-exploration-graphics__/graphics/technology/delivery-cannon-weapon.png",
    icon_size = 128,
    order = "e-g",
    prerequisites = {
      "military-4",
      data_util.mod_prefix .. "delivery-cannon",
      data_util.mod_prefix .. "heavy-girder",
      data_util.mod_prefix .. "holmium-cable",
      data_util.mod_prefix .. "aeroframe-pole",
    },
    unit = {
     count = 200,
     time = 30,
     ingredients = {
       { "automation-science-pack", 1 },
       { "logistic-science-pack", 1 },
       { "chemical-science-pack", 1 },
       { "military-science-pack", 1 },
       { data_util.mod_prefix .. "rocket-science-pack", 1 },
       { data_util.mod_prefix .. "material-science-pack-1", 1 },
       { data_util.mod_prefix .. "energy-science-pack-1", 1 },
       { data_util.mod_prefix .. "astronomic-science-pack-1", 1 },
     }
    },
  },

  {
      type = "item",
      name = data_util.mod_prefix .. "delivery-cannon",
      icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon.png",
      icon_size = 64,
      order = "j-a",
      subgroup = "delivery-cannon-logistics",
      stack_size = 20,
      place_result = data_util.mod_prefix .. "delivery-cannon",
  },
  {
      type = "item",
      name = data_util.mod_prefix .. "delivery-cannon-weapon",
      icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-weapon.png",
      icon_size = 64,
      order = "j-a",
      subgroup = "surface-defense",
      stack_size = 1,
      place_result = data_util.mod_prefix .. "delivery-cannon-weapon",
  },
  {
      type = "item",
      name = data_util.mod_prefix .. "delivery-cannon-chest",
      icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-chest.png",
      icon_size = 64,
      order = "j-b",
      subgroup = "delivery-cannon-logistics",
      stack_size = 50,
      place_result = data_util.mod_prefix .. "delivery-cannon-chest",
  },
  {
      type = "item",
      name = data_util.mod_prefix .. "delivery-cannon-capsule",
      icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-capsule.png",
      icon_size = 64,
      order = "s",
      subgroup = "intersurface-part",
      stack_size = 50,
  },
  {
      type = "item",
      name = data_util.mod_prefix .. "delivery-cannon-weapon-capsule",
      icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-weapon-capsule.png",
      icon_size = 64,
      order = "j-c",
      subgroup = "surface-defense",
      stack_size = 20,
  },
  {
      type = "item",
      name = data_util.mod_prefix .. "delivery-cannon-targeter",
      icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-targeter.png",
      icon_size = 64,
      subgroup = "tool",
      order = "c[automated-construction]-e[unit-remote-control]",
      stack_size = 1,
      hidden = true,
      flags = {"only-in-cursor"},
  },
  {
      type = "recipe",
      name = data_util.mod_prefix .. "delivery-cannon-capsule",
      results = {
        {type= "item", name = data_util.mod_prefix .. "delivery-cannon-capsule", amount = 1},
      },
      enabled = false,
      energy_required = 10,
      ingredients = {
        {type = "item", name = "low-density-structure", amount = 1},
        {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 1},
        {type = "item", name = "explosives", amount = 5},
        {type = "item", name = "copper-cable", amount = 10},
      },
      requester_paste_multiplier = 1,
      always_show_made_in = false,
  },
  {
      type = "recipe",
      name = data_util.mod_prefix .. "delivery-cannon-capsule-iridium",
      localised_name = {"item-name."..data_util.mod_prefix.."delivery-cannon-capsule"},
      results = {
        {type = "item", name = data_util.mod_prefix .. "delivery-cannon-capsule", amount = 1},
      },
      enabled = false,
      energy_required = 10,
      ingredients = {
        {type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 2},
        {type = "item", name = "explosives", amount = 4},
      },
      icons = data_util.sub_icons("__space-exploration-graphics__/graphics/icons/delivery-cannon-capsule.png",
                                  data.raw.item[data_util.mod_prefix .. "iridium-plate"].icon),
      requester_paste_multiplier = 1,
      always_show_made_in = false,
      hide_from_signal_gui = false,
  },
  {
      type = "recipe",
      name = data_util.mod_prefix .. "delivery-cannon-weapon-capsule",
      results = {
        {type = "item", name = data_util.mod_prefix .. "delivery-cannon-weapon-capsule", amount = 1},
      },
      enabled = false,
      energy_required = 20,
      ingredients = {
        {type = "item", name = "low-density-structure", amount = 10},
        {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 10},
        {type = "item", name = data_util.mod_prefix .. "iridium-plate", amount = 10},
        {type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 20},
        {type = "item", name = "explosives", amount = 50},
      },
      requester_paste_multiplier = 1,
      always_show_made_in = false,
  },
  {
      type = "recipe",
      name = data_util.mod_prefix .. "delivery-cannon",
      results = {
        {type = "item", name = data_util.mod_prefix .. "delivery-cannon", amount = 1},
      },
      enabled = false,
      energy_required = 10,
      ingredients = {
        {type = "item", name = "steel-chest", amount = 10},
        {type = "item", name = "pipe", amount = 10},
        {type = "item", name = "electric-engine-unit", amount = 10},
        {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 10},
        {type = "item", name = "concrete", amount = 20},
      },
      requester_paste_multiplier = 1,
      always_show_made_in = false,
  },
  {
      type = "recipe",
      name = data_util.mod_prefix .. "delivery-cannon-weapon",
      results = {
        {type = "item", name = data_util.mod_prefix .. "delivery-cannon-weapon", amount = 1},
      },
      enabled = false,
      energy_required = 30,
      ingredients = {
        {type = "item", name = "electric-engine-unit", amount = 50},
        {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 50},
        {type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 100},
        {type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 200},
        {type = "item", name = data_util.mod_prefix .. "aeroframe-pole", amount = 200},
        {type = "item", name = "processing-unit", amount = 100},
      },
      requester_paste_multiplier = 1,
      always_show_made_in = false,
  },
  {
      type = "recipe",
      name = data_util.mod_prefix .. "delivery-cannon-chest",
      results = {
        {type = "item", name = data_util.mod_prefix .. "delivery-cannon-chest", amount = 1},
      },
      enabled = false,
      energy_required = 10,
      ingredients = {
        {type = "item", name = "radar", amount = 1},
        {type = "item", name = "steel-chest", amount = 10},
        {type = "item", name = "concrete", amount = 20},
        {type = "item", name = data_util.mod_prefix .. "heat-shielding", amount = 10},
      },
      requester_paste_multiplier = 1,
      always_show_made_in = false,
  },
  {
    type = "assembling-machine",
    name = data_util.mod_prefix.."delivery-cannon",
    minable = {
      mining_time = 0.5,
      result = data_util.mod_prefix.."delivery-cannon",
    },
    icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon.png",
    icon_size = 64,
    order = "a-a",
    max_health = 1500,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box_vertical_extension = 5,
    se_allow_in_space = true,
    resistances =
    {
      { type = "meteor", percent = 99 },
      { type = "explosion", percent = 99 },
      { type = "impact", percent = 99 },
      { type = "fire", percent = 99 },
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound = {
      apparent_volume = 1.5,
      idle_sound = {
        filename = "__base__/sound/idle1.ogg",
        volume = 0.6
      },
      sound = {
        {
          filename = "__base__/sound/assembling-machine-t1-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t1-2.ogg",
          volume = 0.8
        }
      }
    },
    collision_mask = {
      layers = {
        water_tile = true,
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
            filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon.png",
            frame_count = 1,
            line_length = 1,
            width = 320,
            height = 640,
            shift = {0,-2.5},
            scale = 0.5,
          },
          {
                draw_as_shadow = true,
                filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-shadow.png",
                shift = { 1.25, 1/32 },
                width = 470,
                height = 306,
                scale = 0.5,
          }
        }
      },
    },
    crafting_categories = {"delivery-cannon"},
    crafting_speed = 1,
    energy_source =
    {
      type = "void",
    },
    energy_usage = "100kW",
  },
  {
    type = "electric-energy-interface",
    name = data_util.mod_prefix .. "delivery-cannon-energy-interface",
    subgroup = "composite-entity-parts",
    icons = data_util.add_icons(
      "__space-exploration-graphics__/graphics/icons/delivery-cannon.png",
      "__base__/graphics/icons/accumulator.png"
    ),
    order = "z-d-a",
    picture =
    {
      layers =
      {
        blank
      },
    },
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    selectable_in_game = false,
    collision_mask = {
      layers = {},
    },
    continuous_animation = true,
    corpse = "medium-remnants",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      input_flow_limit = "50MW",
      output_flow_limit = "0kW",
      buffer_capacity = "1000MJ",-- launch energy cost is removed from buffer
      drain = "100kW",
    },
    energy_production = "0kW",
    energy_usage = "0GW",
    flags = {
      "placeable-player",
      "player-creation",
      "not-rotatable"
    },
    hidden = true,
    max_health = 1500,
  },

  {
    type = "assembling-machine",
    name = data_util.mod_prefix.."delivery-cannon-weapon",
    minable = {
      mining_time = 1,
      result = data_util.mod_prefix.."delivery-cannon-weapon",
    },
    icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-weapon.png",
    icon_size = 64,
    order = "a-a",
    max_health = 1500,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = { { -4.3, -4.3 }, { 4.3, 4.3 } },
    selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
    drawing_box_vertical_extension = 9,
    se_allow_in_space = true,
    resistances =
    {
      { type = "meteor", percent = 99 },
      { type = "explosion", percent = 50 },
      { type = "impact", percent = 99 },
      { type = "fire", percent = 50 },
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal-large",
    working_sound = {
      apparent_volume = 1.5,
      idle_sound = {
        filename = "__base__/sound/idle1.ogg",
        volume = 0.6
      },
      sound = {
        {
          filename = "__base__/sound/assembling-machine-t1-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t1-2.ogg",
          volume = 0.8
        }
      }
    },
    collision_mask = {
      layers = {
        water_tile = true,
        item = true,
        object = true,
        player = true,
      },
    },
    graphics_set = {
      animation =
      {
        layers = {
          {
                filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-weapon.png",
                shift = { 0, -4.75 },
                width = 616,
                height = 1198,
                scale = 0.5,
          },
          {
                draw_as_shadow = true,
                filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-weapon-shadow.png",
                shift = { 2.5, 2/32 },
                width = 890,
                height = 578,
                scale = 0.5,
          }
        }
      },
    },
    crafting_categories = {"delivery-cannon-weapon"},
    crafting_speed = 1,
    energy_source =
    {
      type = "void",
    },
    energy_usage = "100kW",
  },
  {
    type = "electric-energy-interface",
    name = data_util.mod_prefix .. "delivery-cannon-weapon-energy-interface",
    subgroup = "composite-entity-parts",
    icons = data_util.add_icons(
      "__space-exploration-graphics__/graphics/icons/delivery-cannon-weapon.png",
      "__base__/graphics/icons/accumulator.png"
    ),
    order = "z-d-a",
    picture =
    {
      layers =
      {
        blank
      },
    },
    collision_box = { { -4.3, -4.3 }, { 4.3, 4.3 } },
    selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
    selectable_in_game = false,
    collision_mask = {
      layers = {},
    },
    continuous_animation = true,
    corpse = "medium-remnants",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      input_flow_limit = "500MW",
      output_flow_limit = "0kW",
      buffer_capacity = "10000MJ",-- launch energy cost is removed from buffer - copied to DeliveryCannon.weapon_delivery_cannon_electric_buffer_size so update that if you modify this value
      drain = "1000kW",
    },
    energy_production = "0kW",
    energy_usage = "0GW",
    flags = {
      "placeable-player",
      "player-creation",
      "not-rotatable"
    },
    hidden = true,
    max_health = 1500,
  },

  {
    type = "container",
    name = data_util.mod_prefix .. "delivery-cannon-chest",
    icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-chest.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = data_util.mod_prefix .. "delivery-cannon-chest"},
    max_health = 1000,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.3,-1.3},{1.3,1.3}},
    collision_mask = {
      layers = {
        water_tile = true,
        item = true,
        object = true,
        player = true,
      },
    },
    selection_box = {{-1.5,-1.5},{1.5,1.5}},
    se_allow_in_space = true,
    inventory_size = 40,
    resistances = {
      { type = "meteor", percent = 99 },
      { type = "explosion", percent = 75 },
      { type = "impact", percent = 90 },
      { type = "fire", percent = 90 },
    },
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    impact_category = "metal",
    picture = {
      layers = {
        {
          filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-chest.png",
          frame_count = 1,
          line_length = 1,
          width = 208,
          height = 200,
          shift = {0,0},
          scale = 0.5,
        },
        {
          draw_as_shadow = true,
          filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-chest-shadow.png",
          frame_count = 1,
          line_length = 1,
          width = 278,
          height = 150,
          shift = {0.5625,0.5875},
          scale = 0.5,
        },
      }
    },
    circuit_connector = {
      points =
      {
        shadow =
          {
              red = {0.7, -1.3},
              green = {0.7, -1.3},
          },
        wire =
          {
              red = {0.7, -1.3},
              green = {0.7, -1.3},
          }
      },
    },
    circuit_wire_max_distance = 12.5,
  },

  {
    type = "explosion",
    name = data_util.mod_prefix .. "delivery-cannon-beam",
    subgroup = "ammo-effects",
    hidden = true,
    animations = {
      {
        filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-beam.png",
        frame_count = 6,
        height = 1,
        priority = "extra-high",
        width = 187
      }
    },
    beam = true,
    flags = { "not-on-map", "placeable-off-grid"},
    light = {
      color = {
        b = 0.8,
        g = 1,
        r = 0.9
      },
      intensity = 1,
      size = 20
    },
    rotate = true,
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1,
    sound = {
      {
        filename = "__base__/sound/fight/old/huge-explosion.ogg",
        volume = 1
      }
    },
  },
  {
    type = "explosion",
    name = data_util.mod_prefix .. "delivery-cannon-weapon-beam",
    subgroup = "ammo-effects",
    hidden = true,
    animations = {
      {
        filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-weapon-beam.png",
        frame_count = 6,
        height = 1,
        priority = "extra-high",
        width = 187
      }
    },
    beam = true,
    flags = { "not-on-map", "placeable-off-grid"},
    light = {
      color = {
        b = 0.8,
        g = 0.9,
        r = 1
      },
      intensity = 1,
      size = 20
    },
    rotate = true,
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1,
    sound = {
      {
        filename = "__base__/sound/fight/old/huge-explosion.ogg",
        volume = 1
      }
    },
  },
  {
    -- making these artillery-projectile(s) instead of projectile(s) makes it possible for them to show up on the map
    type = "artillery-projectile",
    name = data_util.mod_prefix.."delivery-cannon-capsule-artillery-projectile",
    subgroup = "ammo-effects",
    hidden = true,
    icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-capsule.png",
    icon_size = 64,
    acceleration = 0,
    rotatable = false,
    picture = {
      filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-capsule.png",
      width = 58,
      height = 94,
      priority = "high",
      shift = { 0, 0 },
      scale = 0.25,
    },
    -- reveal_map, map_color, and chart_picture are specific to artillery-projectile and dictate how it will behave with the map
    -- because charting is handled by the delivery cannon script, reveal_map should be left false
    reveal_map = false,
    map_color = {r=0.3, g=0.6, b=0.1},
    chart_picture =
    {
      filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
      flags = { "icon" },
      frame_count = 1,
      width = 64,
      height = 64,
      priority = "high",
      scale = 0.20,
      tint = {r=0.3, g=0.6, b=0.1},
    },
    flags = { "not-on-map", "placeable-off-grid"},
    light = { intensity = 0.2, size = 10},
    smoke = {
      {
        deviation = {
          0.15,
          0.15
        },
        frequency = 1,
        name = "smoke-fast",
        --name = "smoke-explosion-particle",
        --name = "soft-fire-smoke", -- lasts longer
        position = {0,0},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    },
  },
  {
    -- making these artillery-projectile(s) instead of projectile(s) makes it possible for them to show up on the map
    type = "artillery-projectile",
    name = data_util.mod_prefix.."delivery-cannon-weapon-capsule-artillery-projectile",
    subgroup = "ammo-effects",
    hidden = true,
    icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-weapon-capsule.png",
    icon_size = 64,
    acceleration = 0,
    rotatable = false,
    picture = {
      filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-weapon-capsule.png",
      width = 58,
      height = 94,
      priority = "high",
      shift = { 0, 0 },
      scale = 0.25,
    },
    -- reveal_map, map_color, and chart_picture are specific to artillery-projectile and dictate how it will behave with the map
    -- because charting is handled by the delivery cannon script, reveal_map should be left false
    reveal_map = false,
    map_color = {r=1, g=1, b=0},
    chart_picture =
    {
      filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
      flags = { "icon" },
      frame_count = 1,
      width = 64,
      height = 64,
      priority = "high",
      scale = 0.25
    },
    flags = { "not-on-map", "placeable-off-grid"},
    light = { intensity = 0.2, size = 10},
    smoke = {
      {
        deviation = {
          0.15,
          0.15
        },
        frequency = 1,
        name = "smoke-fast",
        --name = "smoke-explosion-particle",
        --name = "soft-fire-smoke", -- lasts longer
        position = {0,0},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    },
  },
  {
    type = "projectile",
    name = data_util.mod_prefix.."delivery-cannon-capsule-shadow",
    subgroup = "ammo-effects",
    hidden = true,
    acceleration = 0,
    rotatable = false,
    animation = {
      draw_as_shadow = true,
      filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-capsule-shadow.png",
      frame_count = 1,
      width = 98,
      height = 50,
      line_length = 1,
      priority = "high",
      shift = { 0, 0 },
      scale = 0.5,
    },
    flags = { "not-on-map", "placeable-off-grid"},
  },
  {
    type = "explosion",
    name = data_util.mod_prefix.."delivery-cannon-capsule-explosion",
    subgroup = "ammo-effects",
    hidden = true,
    localised_name = {"item-name." .. data_util.mod_prefix .. "delivery-cannon-capsule"},
    animations = table.deepcopy(data.raw.explosion["medium-explosion"].animations),
    created_effect = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "create-particle",
            particle_name = "explosion-remnants-particle",
            initial_height = 0.5,
            initial_vertical_speed = 0.08,
            initial_vertical_speed_deviation = 0.08,
            offset_deviation = { { -0.2, -0.2 }, { 0.2, 0.2 } },
            repeat_count = 16,
            speed_from_center = 0.08,
            speed_from_center_deviation = 0.08,
          },
          {
            type = "create-particle",
            particle_name = "stone-particle",
            initial_height = 0.5,
            initial_vertical_speed = 0.1,
            initial_vertical_speed_deviation = 0.1,
            offset_deviation = { { -0.2, -0.2 }, { 0.2, 0.2 } },
            repeat_count = 60,
            speed_from_center = 0.08,
            speed_from_center_deviation = 0.08,
          },
          {
            action = {
              action_delivery = {
                target_effects = {
                  {
                    damage = {
                      amount = 5,
                      type = "meteor"
                    },
                    type = "damage"
                  },
                },
                type = "instant"
              },
              radius = 10,
              type = "area"
            },
            type = "nested-result"
          },
          {
            action = {
              action_delivery = {
                target_effects = {
                  {
                    damage = {
                      amount = 10,
                      type = "meteor"
                    },
                    type = "damage"
                  },
                },
                type = "instant"
              },
              radius = 4,
              type = "area"
            },
            type = "nested-result"
          },
          {
            action = {
              action_delivery = {
                target_effects = {
                  {
                    damage = {
                      amount = 35,
                      type = "meteor"
                    },
                    type = "damage"
                  },
                },
                type = "instant"
              },
              radius = 2,
              type = "area"
            },
            type = "nested-result"
          },
          {
            action = {
              action_delivery = {
                target_effects = {
                  {
                    damage = {
                      amount = 100,
                      type = "meteor"
                    },
                    type = "damage"
                  },
                },
                type = "instant"
              },
              radius = 1,
              type = "area"
            },
            type = "nested-result"
          },
        },
      },
    },
    flags = { "not-on-map", "placeable-off-grid"},
    light = { color = { r = 1, g = 0.9, b = 0.8 }, intensity = 1, size = 30 },
    sound = {
      aggregation = { max_count = 1, remove = true },
      variations = table.deepcopy(data.raw.explosion["medium-explosion"].sound.variations)
    },
  },
})

-- deprecated with the change from projectile -> artillery-projectile for the actual delivery cannon projectiles
-- but there is no option to do prototype migration for these types so the old type is left-in to avoid the "removed prototypes"
-- popup for players and to prevent issues with in-flight delivery cannons projectiles when loading the save
data:extend({
  {
    type = "projectile",
    name = data_util.mod_prefix.."delivery-cannon-capsule-projectile",
    subgroup = "ammo-effects",
    hidden = true,
    icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-capsule.png",
    icon_size = 64,
    acceleration = 0,
    rotatable = false,
    animation = {
      filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-capsule.png",
      frame_count = 1,
      width = 58/2,
      height = 94/2,
      line_length = 1,
      priority = "high",
      shift = { 0, 0 },
      {
        filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-capsule.png",
        frame_count = 1,
        width = 58,
        height = 94,
        line_length = 1,
        priority = "high",
        shift = { 0, 0 },
        scale = 0.5,
      },
    },
    flags = { "not-on-map", "placeable-off-grid"},
    light = { intensity = 0.2, size = 10},
    smoke = {
      {
        deviation = {
          0.15,
          0.15
        },
        frequency = 1,
        name = "smoke-fast",
        position = {0,0},
        starting_frame = 3,
        starting_frame_deviation = 5,
      }
    },
  },
  {
    type = "projectile",
    name = data_util.mod_prefix.."delivery-cannon-weapon-capsule-projectile",
    subgroup = "ammo-effects",
    hidden = true,
    icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-weapon-capsule.png",
    icon_size = 64,
    acceleration = 0,
    rotatable = false,
    animation = {
      filename = "__space-exploration-graphics-5__/graphics/entity/delivery-cannon/delivery-cannon-weapon-capsule.png",
      frame_count = 1,
      width = 58,
      height = 94,
      line_length = 1,
      priority = "high",
      shift = { 0, 0 },
      scale = 0.5,
    },
    flags = { "not-on-map", "placeable-off-grid"},
    light = { intensity = 0.2, size = 10},
    smoke = {
      {
        deviation = {
          0.15,
          0.15
        },
        frequency = 1,
        name = "smoke-fast",
        --name = "smoke-explosion-particle",
        --name = "soft-fire-smoke", -- lasts longer
        position = {0,0},
        -- slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        -- starting_frame_speed = 0,
        -- starting_frame_speed_deviation = 5
      }
    },
  },
})
