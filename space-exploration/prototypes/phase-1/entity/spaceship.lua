local data_util = require("data_util")

local blank_image = {
    filename = "__space-exploration-graphics__/graphics/blank.png",
    width = 1,
    height = 1,
    frame_count = 1,
    line_length = 1,
    shift = { 0, 0 },
}
local blank_directions = {
    north = blank_image,
    east = blank_image,
    south = blank_image,
    west = blank_image
}
local wall = table.deepcopy(data.raw.wall["stone-wall"])

wall.name =  data_util.mod_prefix .. "spaceship-wall"
wall.minable.result =  data_util.mod_prefix .. "spaceship-wall"
wall.max_health = 400
wall.resistances = {
  {type = "meteor", percent = 50},
  {type = "impact", percent = 50},
  {type = "physical", percent = 50},
  {type = "laser", percent = 50},
  {type = "fire", percent = 50},
  {type = "electric", percent = 50},
  {type = "explosion", percent = 50},
  {type = "acid", percent = 50},
  {type = "poison", percent = 100},
}
if mods["aai-industry"] then
  data_util.replace_filenames_recursive(wall.pictures, "__aai-industry__", "__space-exploration-graphics__")
  data_util.replace_filenames_recursive(wall.pictures, "stone-wall", "spaceship-wall")
else
  data_util.replace_filenames_recursive(wall.pictures, "__base__", "__space-exploration-graphics__")
  data_util.replace_filenames_recursive(wall.pictures, "entity/wall", "entity/spaceship-wall")
end
wall.collision_mask = {
  layers = {
    ground_tile = true,
    water_tile = true,
    object = true,
    player = true,
    train = true,
    item = true,
    [static_tile_layer] = true,
  },
}
wall.se_placement_restriction_text = {"tile-name.se-spaceship-floor"}
wall.fast_replaceable_group = "spaceship-wall"
wall.next_upgrade = nil
wall.icon = "__space-exploration-graphics__/graphics/icons/spaceship-wall.png"
wall.icon_size = 64

local gate = table.deepcopy(data.raw.gate["gate"])
gate.name =  data_util.mod_prefix .. "spaceship-gate"
gate.minable.result =  data_util.mod_prefix .. "spaceship-gate"
for _, pictures in pairs({gate.horizontal_animation, gate.horizontal_rail_animation_left, gate.horizontal_rail_animation_right, gate.horizontal_rail_base,
  gate.vertical_animation, gate.vertical_rail_animation_left, gate.vertical_rail_animation_right, gate.vertical_rail_base }) do
    data_util.replace_filenames_recursive(pictures, "__aai-industry__/graphics/entity/stone-gate/", "__space-exploration-graphics__/graphics/entity/spaceship-gate/")
end
gate.collision_mask = {
  layers = {
    ground_tile = true,
    water_tile = true,
    object = true,
    item = true,
    player = true,
    train = true,
    [static_tile_layer] = true,
  },
}
gate.opened_collision_mask = { -- thanks Bilka
  layers = {
    ground_tile = true,
    water_tile = true,
    object = true,
    item = true,
    [static_tile_layer] = true,
  },
}
gate.se_placement_restriction_text = {"tile-name.se-spaceship-floor"}
gate.fast_replaceable_group = "spaceship-wall"
gate.next_upgrade = nil
gate.icon = "__space-exploration-graphics__/graphics/icons/spaceship-gate.png"
gate.icon_size = 64


local booster = {
  type = "storage-tank",
  name = data_util.mod_prefix .. "spaceship-rocket-booster-tank",
  icon = "__space-exploration-graphics__/graphics/icons/spaceship-rocket-booster-tank.png",
  icon_size = 64,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.5, result = data_util.mod_prefix .. "spaceship-rocket-booster-tank"},
  max_health = 500,
  corpse = "medium-remnants",
  dying_explosion = "storage-tank-explosion",
  collision_mask = {
    layers = {
      water_tile = true,
      ground_tile = true,
      item = true,
      object = true,
      player = true,
      [static_tile_layer] = true,
    },
  },
  se_placement_restriction_text = {"tile-name.se-spaceship-floor"},
  collision_box = {{-1.3, -1.1}, {1.3, 1.3}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  drawing_box_vertical_extension = 1,
  fluid_box = {
    filter = data_util.mod_prefix .. "liquid-rocket-fuel", -- Filters don't prevent other fluids from entering, but useful for QoL mechanics.
    volume = 100 * 1000,
    hide_connection_info = true,
    pipe_connections = {
      { position = { 0, -1 }, direction = defines.direction.north },
      { position = { 1, 0 }, direction = defines.direction.east },
      { position = { -1, 0 }, direction = defines.direction.west },
      { position = { 0, 1 }, direction = defines.direction.south },
    },
    pipe_covers = pipecoverspictures(),
    secondary_draw_orders = { north = -1 }
  },
  two_direction_only = true,
  window_bounding_box = {
    util.by_pixel(40/2, -32/2),
    util.by_pixel(72/2, 64/2)
  },
  pictures =
  {
    flow_sprite = {
      filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
      height = 20,
      priority = "extra-high",
      width = 160,
    },
    fluid_background = {
      filename = "__base__/graphics/entity/storage-tank/fluid-background.png",
      height = 15,
      priority = "extra-high",
      width = 32,
      shift = util.by_pixel(-5, 0)
    },
    gas_flow = {
      animation_speed = 0.25,
      axially_symmetrical = false,
      direction_count = 1,
      filename = "__base__/graphics/entity/pipe/steam.png",
      frame_count = 60,
      height = 30,
      line_length = 10,
      priority = "extra-high",
      width = 48,
      shift = util.by_pixel(-14, 2),
    },
    picture = {
      sheets = {
        {
          filename = "__space-exploration-graphics__/graphics/entity/spaceship-rocket-booster-tank/spaceship-rocket-booster-tank.png",
          frames = 1,
          height = 256,
          width = 192,
          priority = "extra-high",
          shift = util.by_pixel(0, -16),
          scale = 0.5,
        },
        {
          draw_as_shadow = true,
          filename = "__space-exploration-graphics__/graphics/entity/spaceship-rocket-booster-tank/spaceship-rocket-booster-tank-shadow.png",
          frames = 1,
          width = 262,
          height = 134,
          priority = "extra-high",
          shift = util.by_pixel(18, 14),
          scale = 0.5,
        }
      }
    },
    window_background = {
      filename = "__space-exploration-graphics__/graphics/entity/spaceship-rocket-booster-tank/spaceship-rocket-booster-tank-background.png",
      priority = "extra-high",
      width = 32,
      height = 96,
      scale = 0.5,
    }
  },
  flow_length_in_ticks = 360,
  open_sound = data_util.machine_open_sound,
  close_sound = data_util.machine_close_sound,
  impact_category = "metal-large",
  working_sound =
  {
    sound =
    {
        filename = "__base__/sound/storage-tank.ogg",
        volume = 0.8
    },
    match_volume_to_activity = true,
    apparent_volume = 1.5,
    max_sounds_per_type = 3
  },
  circuit_connector = circuit_connector_definitions["storage-tank"],
  circuit_wire_max_distance = default_circuit_wire_max_distance,
  rotatable = false
}

local ion_booster = table.deepcopy(booster)
ion_booster.name = data_util.mod_prefix.."spaceship-ion-booster-tank"
ion_booster.icon = "__space-exploration-graphics__/graphics/icons/spaceship-ion-booster-tank.png"
ion_booster.minable.result =  data_util.mod_prefix .. "spaceship-ion-booster-tank"
ion_booster.max_health = 400
ion_booster.rotatable = true
ion_booster.collision_box = {{-0.8, -0.8}, {0.8, 0.8}}
ion_booster.selection_box = {{-1, -1}, {1, 1}}
ion_booster.drawing_box_vertical_extension = 1.5
ion_booster.fluid_box = {
  filter = data_util.mod_prefix .. "ion-stream", -- Filters don't prevent other fluids from entering, but useful for QoL mechanics.
  volume = 100 * 100,
  hide_connection_info = true,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    { position = {-0.5, -0.5}, direction = defines.direction.north },
    { position = {0.5, 0.5}, direction = defines.direction.east },
    { position = {0.5, 0.5}, direction = defines.direction.south },
    { position = {-0.5, -0.5}, direction = defines.direction.west }
  }
}
ion_booster.window_bounding_box = {
  util.by_pixel(18/2, -16/2),
  util.by_pixel((18+32)/2, (-16+66)/2)
}
ion_booster.pictures.picture.sheets = {
  {
    filename = "__space-exploration-graphics__/graphics/entity/spaceship-ion-booster-tank/spaceship-ion-booster-tank.png",
    frames = 2,
    height = 164,
    width = 256/2,
    priority = "extra-high",
    shift = util.by_pixel(0, -8),
    scale = 0.5,
  },
  {
    draw_as_shadow = true,
    filename = "__space-exploration-graphics__/graphics/entity/spaceship-ion-booster-tank/spaceship-ion-booster-tank-shadow.png",
    frames = 1,
    repeat_count = 2,
    width = 184,
    height = 94,
    priority = "extra-high",
    shift = util.by_pixel(16, 12),
    scale = 0.5,
  }
}
ion_booster.pictures.window_background = {
  filename = "__space-exploration-graphics__/graphics/entity/spaceship-ion-booster-tank/spaceship-ion-booster-tank-background.png",
  priority = "extra-high",
  width = 32,
  height = 66,
  scale = 0.5,
}
--same as vanilla storage-tank but scaled down to entity size 2x2 from original 3x3
circuit_connector_definitions["storage-tank-2x2"] = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    { variation = 27, main_offset = util.mul_shift(util.by_pixel(33.5, 18.5), 2/3), shadow_offset = util.mul_shift(util.by_pixel(33.5, 18.5), 2/3), show_shadow = false },
    { variation = 25, main_offset = util.mul_shift(util.by_pixel(-33.5, 19.5), 2/3), shadow_offset = util.mul_shift(util.by_pixel(-33.5, 19.5), 2/3), show_shadow = false },
    { variation = 27, main_offset = util.mul_shift(util.by_pixel(33.5, 18.5), 2/3), shadow_offset = util.mul_shift(util.by_pixel(33.5, 18.5), 2/3), show_shadow = false },
    { variation = 25, main_offset = util.mul_shift(util.by_pixel(-33.5, 19.5), 2/3), shadow_offset = util.mul_shift(util.by_pixel(-33.5, 19.5), 2/3), show_shadow = false }
  }
)
ion_booster.circuit_connector = circuit_connector_definitions["storage-tank-2x2"]

local antimatter_booster = table.deepcopy(booster)
antimatter_booster.name = data_util.mod_prefix.."spaceship-antimatter-booster-tank"
antimatter_booster.icon = "__space-exploration-graphics__/graphics/icons/spaceship-antimatter-booster-tank.png"
antimatter_booster.minable.result =  data_util.mod_prefix .. "spaceship-antimatter-booster-tank"
data_util.replace_filenames_recursive(antimatter_booster.pictures, "rocket", "antimatter")
antimatter_booster.fluid_box.filter = data_util.mod_prefix .. "antimatter-stream" -- Filters don't prevent other fluids from entering, but useful for QoL mechanics.
antimatter_booster.fluid_box.volume = 100 * 500

local console_layers =  {
  layers =
  {
    {
      filename = "__space-exploration-graphics__/graphics/entity/spaceship-console/spaceship-console-base.png",
      priority = "high",
      width = 256,
      height = 256,
      frame_count = 1,
      line_length = 1,
      shift = util.by_pixel(0, -16+3),
      animation_speed = 1,
      scale = 0.5,
    },
    {
      filename = "__space-exploration-graphics__/graphics/entity/spaceship-console/spaceship-console-mask.png",
      priority = "high",
      width = 256,
      height = 256,
      frame_count = 1,
      line_length = 1,
      shift = util.by_pixel(0, -16+3),
      animation_speed = 1,
      scale = 0.5,
      tint = data_util.console_tint,
      blend_mode = "additive",
      draw_as_glow = true,
    },
    {
      filename = "__space-exploration-graphics__/graphics/entity/spaceship-console/spaceship-console-white.png",
      priority = "high",
      width = 256,
      height = 256,
      frame_count = 1,
      line_length = 1,
      shift = util.by_pixel(0, -16+3),
      animation_speed = 1,
      scale = 0.5,
      blend_mode = "additive",
      draw_as_glow = true,
    },
    {
      draw_as_shadow = true,
      filename = "__space-exploration-graphics__/graphics/entity/spaceship-console/spaceship-console-shadow.png",
      priority = "high",
      width = 110,
      height = 74,
      frame_count = 1,
      line_length = 1,
      shift = util.by_pixel(75, 16+3),
      animation_speed = 1,
      scale = 0.5,
    },
  },
}
local console_alt_layers = table.deepcopy(console_layers)
console_alt_layers.layers[2].tint = data_util.console_alt_tint

local function connection_sprites(offset)
  return {
    blue_led_light_offset = offset,
    led_blue = {
      filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04e-blue-LED-on-sequence.png",
      height = 60,
      priority = "low",
      shift = offset,
      width = 60,
      x = 60,
      y = 0
    },
    led_blue_off = {
      filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04f-blue-LED-off-sequence.png",
      height = 44,
      priority = "low",
      shift = offset,
      width = 46,
      x = 46,
      y = 0
    },
    led_green = {
      filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04h-green-LED-sequence.png",
      height = 46,
      priority = "low",
      shift = offset,
      width = 48,
      x = 48,
      y = 0
    },
    led_light = {
      intensity = 0.8,
      size = 0.9
    },
    led_red = {
      filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04i-red-LED-sequence.png",
      height = 46,
      priority = "low",
      shift = offset,
      width = 48,
      x = 48,
      y = 0
    },
    red_green_led_light_offset = offset,
  }
end

local console_connection_point_left = {
  wire = { green = {-92/64, -108/64},   red = {-102/64, -102/64}, },
  shadow = { green = {-92/64 + 1, 0.5},   red = {-102/64 + 1, 0.5}, },
}
local console_connection_point_right = {
  wire = { red = {92/64, -108/64},   green = {102/64, -102/64}, },
  shadow = { red = {92/64 + 1, 0.5},   green = {102/64 + 1, 0.5}, },
}
local output_connection_point = {
  wire = { red = {92/64-1.5, -108/64+1},   green = {102/64-1.5, -102/64+1}, },
  shadow = { red = {92/64-1.5 + 1, 0.5+1},   green = {102/64-1.5 + 1, 0.5+1}, },
}

data:extend({
  wall,
  gate,
  booster,
  ion_booster,
  antimatter_booster,
  {
    type = "accumulator",
    name = data_util.mod_prefix .. "spaceship-console",
    icons = {
      {icon = "__space-exploration-graphics__/graphics/icons/spaceship-console-base.png", icon_size = 64},
      {icon = "__space-exploration-graphics__/graphics/icons/spaceship-console-mask.png", icon_size = 64, tint = data_util.console_tint},
      {icon = "__space-exploration-graphics__/graphics/icons/spaceship-console-white.png", icon_size = 64},
    },
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = { mining_time = 1, result = data_util.mod_prefix .. "spaceship-console"},
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-1.6, -1.6}, {1.6, 1.6}},
    selection_box = {{-2, -2}, {2, 2}},
    drawing_box_vertical_extension = 0,
    resistances =
    {
      { type = "poison", percent = 100 },
      { type = "fire", percent = 80 },
      { type = "explosion", percent = 50 }
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal",
    working_sound = {
      match_speed_to_activity = true,
      max_sounds_per_type = 2,
      sound = {
        filename = "__base__/sound/combinator.ogg",
        volume = 0.5
      }
    },
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
        [static_tile_layer] = true,
      },
    },
    se_placement_restriction_text = {"tile-name.se-spaceship-floor"},
    chargable_graphics = {
      charge_animation = console_layers,
      picture = console_layers,
      charge_cooldown = 30,
      discharge_cooldown = 30,
    },
    crafting_categories = {"spaceship-console"},
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-input",
      input_flow_limit = "1001kW",
      buffer_capacity = "1J",
      render_no_power_icon = false
    },
    energy_usage = "1000kW",
    allowed_effects = {},
    circuit_wire_max_distance = 10,
    circuit_connector = {
      points = console_connection_point_left
    },
  },
  {
      type = "constant-combinator",
      name = data_util.mod_prefix .. "spaceship-console-output",
      hidden = true,
      subgroup = "composite-entity-parts",
      factoriopedia_alternative = data_util.mod_prefix.."spaceship-console",
      fast_replaceable_group = data_util.mod_prefix .. "spaceship-console-output",
      placeable_by = { item = data_util.mod_prefix .. "struct-generic-output", count = 1},
      minable = { mining_time = 0.1 },
      icons = data_util.add_icons(
        {{icon = "__space-exploration-graphics__/graphics/icons/spaceship-console-base.png", icon_size = 64},
         {icon = "__space-exploration-graphics__/graphics/icons/spaceship-console-mask.png", icon_size = 64, tint = data_util.console_tint},
         {icon = "__space-exploration-graphics__/graphics/icons/spaceship-console-white.png", icon_size = 64}},
        data.raw.item["constant-combinator"].icon),
      flags = {"placeable-player", "player-creation", "placeable-off-grid",  "not-rotatable", "not-deconstructable", "hide-alt-info"},
      order = "y",
      max_health = 500,
      open_sound = data_util.machine_open_sound,
      close_sound = data_util.machine_close_sound,
      corpse = "small-remnants",
      collision_box = {{-0.5, -1}, {0.5, 1}},
      collision_mask = { layers = {} },
      selection_box = {{-0.5, -1}, {0.5, 1}},
      scale_info_icons = false,
      selectable_in_game = true,
      selection_priority = 150,
      item_slot_count = 10, -- speed, current_surface, target_surface, distance
      sprites =
      {
          north = blank_image,
          east = blank_image,
          south = blank_image,
          west = blank_image
      },
      activity_led_sprites =
      {
          north = blank_image,
          east = blank_image,
          south = blank_image,
          west = blank_image
      },
      activity_led_light =
      {
          intensity = 0.8,
          size = 1,
      },
      activity_led_light_offsets =
      {
          {0, 0},
          {0, 0},
          {0, 0},
          {0, 0}
      },
      circuit_wire_connection_points =
      {
          output_connection_point,  output_connection_point,  output_connection_point,  output_connection_point,
      },
      circuit_wire_max_distance = 10
  },
  {
    type = "accumulator",
    name = data_util.mod_prefix .. "spaceship-console-alt",
    icons = {
      {icon = "__space-exploration-graphics__/graphics/icons/spaceship-console-base.png", icon_size = 64},
      {icon = "__space-exploration-graphics__/graphics/icons/spaceship-console-mask.png", icon_size = 64, tint = data_util.console_alt_tint},
      {icon = "__space-exploration-graphics__/graphics/icons/spaceship-console-white.png", icon_size = 64},
    },
    flags = {"placeable-neutral", "placeable-player", "player-creation", "not-deconstructable"},
    hidden = true,
    --minable = { mining_time = 1, result = data_util.mod_prefix .. "spaceship-console-alt"},
    max_health = 5000,
    healing_per_tick = 1,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-1.6, -1.6}, {1.6, 1.6}},
    selection_box = {{-2, -2}, {2, 2}},
    drawing_box_vertical_extension = 0,
    resistances =
    {
      { type = "poison", percent = 100 },
      { type = "fire", percent = 80 },
      { type = "explosion", percent = 50 }
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal",
    working_sound = {
      match_speed_to_activity = true,
      max_sounds_per_type = 2,
      sound = {
        filename = "__base__/sound/combinator.ogg",
        volume = 0.5
      }
    },
    collision_mask = {
      layers = {
        --item = true, -- stops player from dropping items on belts.
        floor = true,
        --object = true,
        water_tile = true,
        player = true,
        [static_tile_layer] = true,
      },
    },
    se_placement_restriction_text = {"tile-name.se-spaceship-floor"},
    chargable_graphics = {
      charge_animation = console_alt_layers,
      picture = console_alt_layers,
      charge_cooldown = 30,
      discharge_cooldown = 30,
    },
    crafting_categories = {"spaceship-console"},
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-input",
      input_flow_limit = "1001kW",
      buffer_capacity = "1J",
      render_no_power_icon = false
    },
    energy_usage = "1000kW",
    allowed_effects = {},
    circuit_wire_max_distance = 10,
    circuit_connector = {
      points = console_connection_point_left
    },
  },
  {
    type = "furnace",
    name = data_util.mod_prefix .. "spaceship-rocket-engine",
    icon = "__space-exploration-graphics__/graphics/icons/spaceship-rocket-engine.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation", "not-rotatable"},
    show_recipe_icon = false,
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "spaceship-rocket-engine"},
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-1.45, -1.95}, {1.45, 1.95}},
    selection_box = {{-1.45, -1.95}, {1.45, 1.95}},
    drawing_box_vertical_extension = 1.05,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation =  4, main_offset = util.by_pixel(-4, -24.125), shadow_offset = util.by_pixel(-4, -24.125), show_shadow = true },
        { variation =  4, main_offset = util.by_pixel(-4, -24.125), shadow_offset = util.by_pixel(-4, -24.125), show_shadow = true },
        { variation =  4, main_offset = util.by_pixel(-4, -24.125), shadow_offset = util.by_pixel(-4, -24.125), show_shadow = true },
        { variation =  4, main_offset = util.by_pixel(-4, -24.125), shadow_offset = util.by_pixel(-4, -24.125), show_shadow = true },
      }
    ),
    -- circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
      { type = "poison", percent = 100 },
      { type = "fire", percent = 80 },
      { type = "explosion", percent = 50 }
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
          filename = "__base__/sound/fight/flamethrower-mid.ogg",
          volume = 0.9
        },
      }
    },
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
        [static_tile_layer] = true,
      },
    },
    se_placement_restriction_text = {"tile-name.se-spaceship-floor"},
    source_inventory_size = 0,
    result_inventory_size = 0,
    graphics_set = {
      always_draw_idle_animation = true,
      animation = {
        layers = {
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-rocket-engine/rocket-engine-shadow.png",
            priority = "high",
            width = 302,
            height = 236,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(40, 24 + 16),
            animation_speed = 1,
            scale = 0.5,
          },
        },
      },
      idle_animation =  {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-rocket-engine/rocket-engine-inactive.png",
            priority = "high",
            width = 256,
            height = 416,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 24 + 16),
            animation_speed = 1,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-rocket-engine/rocket-engine-shadow.png",
            priority = "high",
            width = 302,
            height = 236,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(40, 24 + 16),
            animation_speed = 1,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 1.2, size = 8, shift = {0.0, 3}, color = {r = 1, g = 0.7, b = 0.1}}
        },
        {
          animation =  {
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-rocket-engine/rocket-engine-active.png",
            priority = "high",
            width = 256,
            height = 416,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 24 + 16),
            animation_speed = 1,
            scale = 0.5,
          },
        },
      },
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        filter = data_util.mod_prefix.."liquid-rocket-fuel",
        pipe_covers = pipecoverspictures(),
        volume = 10,
        pipe_connections = {
          { flow_direction="input", position = {-1, -1.5}, direction = defines.direction.north },
          { flow_direction="input", position = { 1, -1.5}, direction = defines.direction.north }
        },
        secondary_draw_orders = { north = -1 }
      },
    },
    crafting_categories = {"spaceship-rocket-engine"},
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "100kW",
  },
  {
    type = "furnace",
    name = data_util.mod_prefix .. "spaceship-ion-engine",
    icon = "__space-exploration-graphics__/graphics/icons/spaceship-ion-engine.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation", "not-rotatable"},
    show_recipe_icon = false,
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "spaceship-ion-engine"},
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-1.95, -2.45}, {1.95, 2.45}},
    selection_box = {{-1.95, -2.45}, {1.95, 2.45}},
    drawing_box_vertical_extension = 1.55,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation =  4, main_offset = util.by_pixel(-3.75, -27.875), shadow_offset = util.by_pixel(-3.75, -27.875), show_shadow = true },
        { variation =  4, main_offset = util.by_pixel(-3.75, -27.875), shadow_offset = util.by_pixel(-3.75, -27.875), show_shadow = true },
        { variation =  4, main_offset = util.by_pixel(-3.75, -27.875), shadow_offset = util.by_pixel(-3.75, -27.875), show_shadow = true },
        { variation =  4, main_offset = util.by_pixel(-3.75, -27.875), shadow_offset = util.by_pixel(-3.75, -27.875), show_shadow = true },
      }
    ),
    -- circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
      { type = "poison", percent = 100 },
      { type = "fire", percent = 80 },
      { type = "explosion", percent = 50 }
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
          filename = "__base__/sound/electric-furnace.ogg",
          volume = 0.8
        },
      }
    },
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
        [static_tile_layer] = true,
      },
    },
    se_placement_restriction_text = {"tile-name.se-spaceship-floor"},
    source_inventory_size = 0,
    result_inventory_size = 0,
    graphics_set = {
      always_draw_idle_animation = true,
      animation = {
        layers = {
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-ion-engine/ion-engine-shadow.png",
            priority = "high",
            width = 368,
            height = 474,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(40, 24 + 16+24),
            animation_speed = 1,
            scale = 0.5*4/5,
          },
        },
      },
      idle_animation =  {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-ion-engine/ion-engine-inactive.png",
            priority = "high",
            width = 384,
            height = 904,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 76+24),
            animation_speed = 1,
            scale = 0.5*4/5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-ion-engine/ion-engine-shadow.png",
            priority = "high",
            width = 368,
            height = 474,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(40, 24 + 16+24),
            animation_speed = 1,
            scale = 0.5*4/5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 1.3, size = 12, shift = {0.0, 3}, color = {r = 0, g = 0.1, b = 1}}
        },
        {
          animation =  {
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-ion-engine/ion-engine-active.png",
            priority = "high",
            width = 384,
            height = 904,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 76+24),
            animation_speed = 1,
            scale = 0.5*4/5,
          },
        },
      },
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        filter = data_util.mod_prefix.."ion-stream",
        --pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 10,
        pipe_connections = {
          { flow_direction="input", position = {-0.5, -2}, direction = defines.direction.north },
          { flow_direction="input", position = { 0.5, -2}, direction = defines.direction.north }
        },
        secondary_draw_orders = { north = -1 }
      },
    },
    crafting_categories = {"spaceship-ion-engine"},
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "10MW",
  },
  {
    type = "furnace",
    name = data_util.mod_prefix .. "spaceship-antimatter-engine",
    icon = "__space-exploration-graphics__/graphics/icons/spaceship-antimatter-engine.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation", "not-rotatable"},
    show_recipe_icon = false,
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "spaceship-antimatter-engine"},
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-2.45, -2.95}, {2.45, 2.95}},
    selection_box = {{-2.45, -2.95}, {2.45, 2.95}},
    drawing_box_vertical_extension = 1.55,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation =  4, main_offset = util.by_pixel(-3.25, -33.125), shadow_offset = util.by_pixel(-3.25, -33.125), show_shadow = true },
        { variation =  4, main_offset = util.by_pixel(-3.25, -33.125), shadow_offset = util.by_pixel(-3.25, -33.125), show_shadow = true },
        { variation =  4, main_offset = util.by_pixel(-3.25, -33.125), shadow_offset = util.by_pixel(-3.25, -33.125), show_shadow = true },
        { variation =  4, main_offset = util.by_pixel(-3.25, -33.125), shadow_offset = util.by_pixel(-3.25, -33.125), show_shadow = true },
      }
    ),
    -- circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
      { type = "poison", percent = 100 },
      { type = "fire", percent = 80 },
      { type = "explosion", percent = 50 }
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
          filename = "__base__/sound/fight/flamethrower-mid.ogg",
          volume = 0.9
        },
      }
    },
    collision_mask = {
      layers = {
        water_tile = true,
        ground_tile = true,
        item = true,
        object = true,
        player = true,
        [static_tile_layer] = true,
      },
    },
    se_placement_restriction_text = {"tile-name.se-spaceship-floor"},
    source_inventory_size = 0,
    result_inventory_size = 0,
    graphics_set = {
      always_draw_idle_animation = true,
      animation = {
        layers = {
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-antimatter-engine/antimatter-engine-shadow.png",
            priority = "high",
            width = 368,
            height = 474,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(40, 24 + 16),
            animation_speed = 1,
            scale = 0.5,
          },
        },
      },
      idle_animation = {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-antimatter-engine/antimatter-engine-inactive.png",
            priority = "high",
            width = 384,
            height = 704,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 76),
            animation_speed = 1,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-antimatter-engine/antimatter-engine-shadow.png",
            priority = "high",
            width = 368,
            height = 474,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(40, 24 + 16),
            animation_speed = 1,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 1.3, size = 12, shift = {0.0, 3}, color = {r = 1, g = 0.1, b = 1}}
        },
        {
          animation =  {
            filename = "__space-exploration-graphics__/graphics/entity/spaceship-antimatter-engine/antimatter-engine-active.png",
            priority = "high",
            width = 384,
            height = 704,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, 76),
            animation_speed = 1,
            scale = 0.5,
          },
        },
      },
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        --pipe_picture = assembler3pipepictures(),
        filter = data_util.mod_prefix.."antimatter-stream",
        pipe_covers = pipecoverspictures(),
        volume = 10,
        pipe_connections = {
          { flow_direction="input", position = {-1, -2.5}, direction = defines.direction.north },
          { flow_direction="input", position = { 1, -2.5}, direction = defines.direction.north }
        },
        secondary_draw_orders = { north = -1 }
      },
    },
    crafting_categories = {"spaceship-antimatter-engine"},
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 },
    },
    energy_usage = "1000kW",
  },
  {
    type = "smoke-with-trigger",
    name = data_util.mod_prefix .. "spaceship-engine-smoke",
    order = "a",
    subgroup = "composite-entity-parts",
    hidden = true,
    icons = data_util.add_icons(
      "__space-exploration-graphics__/graphics/icons/spaceship-rocket-engine.png",
      "__base__/graphics/icons/signal/signal-fire.png"
    ),
    flags = {"placeable-off-grid", "not-on-map"},
    action_cooldown = 1,
    action = {
      type = "direct",
      probability = 0.2,
      action_delivery = {
        type = "instant",
        source_effects = {
          type = "create-trivial-smoke",
          smoke_name = "turbine-smoke",
          speed_multiplier = 1,
          speed_multiplier_deviation = 0.5,
          speed = {0, 0.02},
          speed_from_center = 0.02,
          speed_from_center_deviation = 0.02,
          starting_frame_deviation = 5,
          offsets = {{0.25, 0}}, -- smoke is left-bias
        }
      }
    },
    animation = blank_image,
    affected_by_wind = false,
    show_when_smoke_off = true,
    cyclic = true,
    duration = 4294967295
  }
})

data.raw["furnace"][data_util.mod_prefix .. "spaceship-rocket-engine"].factoriopedia_simulation =
{
  init =
  [[
    game.simulation.camera_zoom = 1.6
    game.simulation.camera_position = {0, 0.5}
    game.surfaces[1].create_entity{name = "se-spaceship-rocket-engine", position = {0, 0}}
  ]]
}
data.raw["furnace"][data_util.mod_prefix .. "spaceship-ion-engine"].factoriopedia_simulation =
{
  init =
  [[
    game.simulation.camera_zoom = 1.25
    game.simulation.camera_position = {0, 1.25}
    game.surfaces[1].create_entity{name = "se-spaceship-ion-engine", position = {0, 0}}
  ]]
}
data.raw["furnace"][data_util.mod_prefix .. "spaceship-antimatter-engine"].factoriopedia_simulation =
{
  init =
  [[
    game.simulation.camera_zoom = 1.0
    game.simulation.camera_position = {0, 1}
    game.surfaces[1].create_entity{name = "se-spaceship-antimatter-engine", position = {0, 0}}
  ]]
}

for _, booster_type in pairs(Shared.spaceship_booster_types) do
  local entity = data.raw["storage-tank"][booster_type.name]
  local fluid = data.raw["fluid"][booster_type.allowed_fluid]
  local fuel_value = booster_type.fuel_value_override and booster_type.fuel_value_override or util.parse_energy(fluid.fuel_value)
  data_util.add_custom_tooltip_field(entity, {
    name = {"description.launch-energy-when-full"},
    value = tostring(entity.fluid_box.volume * fuel_value / 1e9) .. " GJ",
    order = 99,
  })
end
