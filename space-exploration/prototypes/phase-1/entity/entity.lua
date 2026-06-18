local data_util = require("data_util")

table.insert(data.raw.lab.lab.inputs, data_util.mod_prefix .. "rocket-science-pack")

-- Collision entities
local base_collision_entity = {
    type = "simple-entity",
    icon = "__base__/graphics/icons/iron-chest.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-off-grid"},
    subgroup = "grass",
    hidden = true,
    order = "z-z",
    selection_box = {{-0.0, -0.0}, {0.0, 0.0}},
    selectable_in_game = false,
    render_layer = "resource",
    pictures = {{
        filename = "__space-exploration-graphics__/graphics/blank.png",
        width = 1,
        height = 1
    }},
}

local collision_player = table.deepcopy(base_collision_entity)
collision_player.name = data_util.mod_prefix .. "collision-player"
collision_player.collision_mask = {layers={player=true, train=true},}
collision_player.collision_box = { { -0.25, -0.25 }, { 0.25, 0.25 } }
collision_player.icon = data.raw.character.character.icon

local collision_player_not_space = table.deepcopy(base_collision_entity)
collision_player_not_space.name = data_util.mod_prefix .. "collision-player-not-space"
collision_player_not_space.collision_mask = {layers={player=true,train=true,[space_collision_layer]=true,},}
collision_player_not_space.collision_box = { { -0.25, -0.25 }, { 0.25, 0.25 } }
collision_player_not_space.icon = data.raw.character.character.icon

local collision_rocket_destination_surface = table.deepcopy(base_collision_entity)
collision_rocket_destination_surface.name = data_util.mod_prefix .. "collision-rocket-destination-surface"
collision_rocket_destination_surface.collision_mask = {layers={player=true,train=true,[space_collision_layer]=true,},}
collision_rocket_destination_surface.collision_box = { { -0.25, -0.25 }, { 0.25, 0.25 } }
collision_rocket_destination_surface.icons = data_util.add_icons(
  "__space-exploration-graphics__/graphics/icons/cargo-rocket.png",
  "__space-exploration-graphics__/graphics/icons/astronomic/planet-small.png"
)

local collision_rocket_destination_orbital = table.deepcopy(base_collision_entity)
collision_rocket_destination_orbital.name = data_util.mod_prefix .. "collision-rocket-destination-orbital"
collision_rocket_destination_orbital.collision_mask = {layers={player=true,train=true},}
collision_rocket_destination_orbital.collision_box = { { -0.25, -0.25 }, { 0.25, 0.25 } }
collision_rocket_destination_orbital.icons = data_util.add_icons(
  "__space-exploration-graphics__/graphics/icons/cargo-rocket.png",
  "__space-exploration-graphics__/graphics/icons/astronomic/planet-orbit.png"
)

-- Slightly bigger collision_box than a real item-on-ground, to ignore the center hole of an item spill.
local item_on_ground = data.raw["item-entity"]["item-on-ground"]
local collision_size = item_on_ground.collision_box[1][1] - 0.07 -- 0.07 is enough to ignore the center hole, 0.06 is too little
local collision_item_on_ground = table.deepcopy(base_collision_entity)
collision_item_on_ground.name = data_util.mod_prefix .. "collision-item-on-ground"
collision_item_on_ground.icon = item_on_ground.icon
collision_item_on_ground.icon_size = item_on_ground.icon_size
collision_item_on_ground.collision_mask = table.deepcopy(item_on_ground.collision_mask)
collision_item_on_ground.collision_box = { { collision_size, collision_size }, { -collision_size, -collision_size } }

data:extend({
  collision_player,
  collision_player_not_space,
  collision_rocket_destination_surface,
  collision_rocket_destination_orbital,
  collision_item_on_ground
})

-- settings entity
data:extend({
  { -- this is a tempalte
    type = "programmable-speaker",
    name = data_util.mod_prefix .. "struct-settings-string",
    subgroup = "composite-entity-parts",
    hidden = true,
    icon = "__space-exploration-graphics__/graphics/icons/settings.png",
    icon_size = 64,
    order="zzz",
    flags = {"placeable-neutral", "player-creation"},
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selection_box = {{-0.0, -0.0}, {0.0, 0.0}},
    drawing_box_vertical_extension = 0,
    selectable_in_game = false,
    energy_source = {
      --type = "electric",
      type = "void",
      usage_priority = "secondary-input",
      render_no_power_icon = false
    },
    energy_usage_per_tick = "1W",
    sprite =
    {
      layers =
      {
        {
            filename = "__space-exploration-graphics__/graphics/blank.png",
            width = 1,
            height = 1,
            frame_count = 1,
            line_length = 1,
            shift = { 0, 0 },
        }
      }
    },
    maximum_polyphony = 0,
    instruments = { },
  },
})
--[[
energy_source = {
  buffer_capacity = "5MJ",
  input_flow_limit = "300kW",
  output_flow_limit = "300kW",
  type = "electric",
  usage_priority = "tertiary"
},]]--

data.raw.accumulator.accumulator.fast_replaceable_group = "accumulator"
data.raw.accumulator.accumulator.next_upgrade = data_util.mod_prefix .. "space-accumulator"
data.raw.accumulator.accumulator.collision_box = {{-0.8,-0.8},{0.8,0.8}}
data.raw.accumulator.accumulator.energy_source.buffer_capacity = "5MJ"
data.raw.accumulator.accumulator.energy_source.input_flow_limit = "250kW"
data.raw.accumulator.accumulator.energy_source.output_flow_limit = "500kW"
local accumulator = table.deepcopy(data.raw.accumulator.accumulator)
accumulator.name = data_util.mod_prefix .. "space-accumulator"
--accumulator.collision_mask = {layers={floor=true,object=true,water_tile=true,ground_tile=true,player=true},}
data_util.replace_filenames_recursive(accumulator, "__base__/graphics/entity/accumulator/accumulator.png", "__space-exploration-graphics-3__/graphics/entity/accumulator/accumulator.png")
data_util.replace_filenames_recursive(accumulator, "__base__/graphics/entity/accumulator/accumulator.png", "__space-exploration-graphics-3__/graphics/entity/accumulator/accumulator.png")
accumulator.icon = "__space-exploration-graphics__/graphics/icons/accumulator.png"
accumulator.icon_size = 64
accumulator.energy_source = {
  --buffer_capacity = "25MJ",
  --input_flow_limit = "2500kW",
  --output_flow_limit = "2500kW",
  buffer_capacity = "50MJ",
  input_flow_limit = "500kW",
  output_flow_limit = "5MW",
  type = "electric",
  usage_priority = "tertiary"
}
accumulator.minable.result = data_util.mod_prefix .. "space-accumulator"
--accumulator.fast_replaceable_group = "space-accumulator"
accumulator.next_upgrade = data_util.mod_prefix .. "space-accumulator-2"


local accumulator2 = table.deepcopy(accumulator)
accumulator2.name = data_util.mod_prefix .. "space-accumulator-2"
data_util.replace_filenames_recursive(accumulator2, "__space-exploration-graphics-3__/graphics/entity/accumulator/accumulator.png", "__space-exploration-graphics-3__/graphics/entity/accumulator/accumulator-2.png")
data_util.replace_filenames_recursive(accumulator2, "__space-exploration-graphics-3__/graphics/entity/accumulator/accumulator.png", "__space-exploration-graphics-3__/graphics/entity/accumulator/accumulator-2.png")
accumulator2.icon = "__space-exploration-graphics__/graphics/icons/accumulator-2.png"
accumulator2.icon_size = 64
accumulator2.energy_source = {
  --buffer_capacity = "100MJ",
  --input_flow_limit = "10000kW",
  --output_flow_limit = "10000kW",
  buffer_capacity = "250MJ",
  input_flow_limit = "2500kW",
  output_flow_limit = "25MW",
  type = "electric",
  usage_priority = "tertiary"
}
accumulator2.minable.result = data_util.mod_prefix .. "space-accumulator-2"
accumulator2.next_upgrade = nil

data:extend{
  accumulator,
  accumulator2,
  {
    type = "solar-panel",
    name = data_util.mod_prefix .. "space-solar-panel",
    collision_box = {
      { -1.95, -1.95 },
      { 1.95, 1.95 }
    },
    collision_mask = {
      layers = {
        floor = true,
        object = true,
        water_tile = true,
        --ground_tile = true,
      },
    },
    selection_box = {
      { -2, -2 },
      { 2, 2 }
    },
    production = "400kW", -- 106.6 would be equivalent to a solar panel for its size.
    corpse = "big-remnants",
    energy_source = {
      type = "electric",
      usage_priority = "solar"
    },
    flags = {
      "placeable-neutral",
      "player-creation"
    },
    fast_replaceable_group = "space-solar-panel",
    icon = "__space-exploration-graphics__/graphics/icons/solar-panel.png",
    icon_size = 64,
    max_health = 400,
    minable = {
      mining_time = 0.1,
      result =  data_util.mod_prefix .. "space-solar-panel"
    },
    next_upgrade = data_util.mod_prefix .. "space-solar-panel-2",
    picture = {
      layers = {
        {
          filename = "__space-exploration-graphics-3__/graphics/entity/solar-panel/solar-panel.png",
          width = 260,
          height = 272,
          priority = "high",
          scale = 0.5,
          shift = {
            0,
            -1/32
          },
        },
        {
          draw_as_shadow = true,
          filename = "__space-exploration-graphics-3__/graphics/entity/solar-panel/solar-panel-shadow.png",
          width = 92,
          height = 260,
          priority = "high",
          scale = 0.5,
          shift = {
            1.5,
            1/32
          },
        }
      }
    },
    impact_category = "metal",
  },
  {
    type = "solar-panel",
    name = data_util.mod_prefix .. "space-solar-panel-2",
    collision_box = {
      { -1.95, -1.95 },
      { 1.95, 1.95 }
    },
    collision_mask = {
      layers = {
        floor = true,
        object = true,
        water_tile = true,
        --ground_tile = true,
      },
    },
    selection_box = {
      { -2, -2 },
      { 2, 2 }
    },
    production = "800kW", -- 106.6 would be equivalent to a solar panel for its size.
    corpse = "big-remnants",
    energy_source = {
      type = "electric",
      usage_priority = "solar"
    },
    flags = {
      "placeable-neutral",
      "player-creation"
    },
    fast_replaceable_group = "space-solar-panel",
    icon = "__space-exploration-graphics__/graphics/icons/solar-panel-2.png",
    icon_size = 64,
    max_health = 500,
    minable = {
      mining_time = 0.1,
      result =  data_util.mod_prefix .. "space-solar-panel-2"
    },
    next_upgrade = data_util.mod_prefix .. "space-solar-panel-3",
    picture = {
      layers = {
        {
          filename = "__space-exploration-graphics-3__/graphics/entity/solar-panel-2/solar-panel.png",
          width = 260,
          height = 272,
          priority = "high",
          scale = 0.5,
          shift = {
            0,
            -1/32
          },
        },
        {
          draw_as_shadow = true,
          filename = "__space-exploration-graphics-3__/graphics/entity/solar-panel-2/solar-panel-shadow.png",
          width = 92,
          height = 260,
          priority = "high",
          scale = 0.5,
          shift = {
            1.5,
            1/32
          },
        }
      }
    },
    impact_category = "metal",
  },
  {
    type = "solar-panel",
    name = data_util.mod_prefix .. "space-solar-panel-3",
    collision_box = {
      { -1.95, -1.95 },
      { 1.95, 1.95 }
    },
    collision_mask = {
      layers = {
        floor = true,
        object = true,
        water_tile = true,
        --ground_tile = true,
      },
    },
    selection_box = {
      { -2, -2 },
      { 2, 2 }
    },
    production = "1600kW", -- 106.6 would be equivalent to a solar panel for its size.
    corpse = "big-remnants",
    energy_source = {
      type = "electric",
      usage_priority = "solar"
    },
    flags = {
      "placeable-neutral",
      "player-creation"
    },
    fast_replaceable_group = "space-solar-panel",
    icon = "__space-exploration-graphics__/graphics/icons/solar-panel-3.png",
    icon_size = 64,
    max_health = 500,
    minable = {
      mining_time = 0.1,
      result =  data_util.mod_prefix .. "space-solar-panel-3"
    },
    picture = {
      layers = {
        {
          filename = "__space-exploration-graphics-3__/graphics/entity/solar-panel-3/solar-panel.png",
          width = 260,
          height = 272,
          priority = "high",
          scale = 0.5,
          shift = {
            0,
            -1/32
          },
        },
        {
          draw_as_shadow = true,
          filename = "__space-exploration-graphics-3__/graphics/entity/solar-panel-3/solar-panel-shadow.png",
          width = 92,
          height = 260,
          priority = "high",
          scale = 0.5,
          shift = {
            1.5,
            1/32
          },
        }
      }
    },
    impact_category = "metal",
  }
}

local tree_fire_starter = table.deepcopy(data.raw.fire["fire-flame"])
tree_fire_starter.name = data_util.mod_prefix .. "tree-fire-starter"
tree_fire_starter.localised_name = {"entity-name.fire-flame"}
tree_fire_starter.damage_multiplier_decrease_per_tick = 0
tree_fire_starter.initial_lifetime = 600
tree_fire_starter.spread_delay = 1
tree_fire_starter.spread_delay_deviation = 1
tree_fire_starter.spawn_entity = data_util.mod_prefix .. "fire-flame-on-tree-no-pollution"
tree_fire_starter.emissions_per_second = {pollution = 0}
data:extend({tree_fire_starter})

local treefire = table.deepcopy(data.raw.fire["fire-flame-on-tree"])
treefire.name = data_util.mod_prefix .. "fire-flame-on-tree-no-pollution"
treefire.spawn_entity = treefire.name
treefire.emissions_per_second = {pollution = 0}
data:extend({treefire})

local centrifuge = data.raw["assembling-machine"].centrifuge
if centrifuge then
  centrifuge.graphics_set.working_visualisations[1].light.color = {r = 0.9, g = 1.0, b = 0.7}
  centrifuge.graphics_set.working_visualisations[2].apply_recipe_tint = "primary"
  centrifuge.graphics_set.working_visualisations[2].animation.layers[1].filename = "__space-exploration-graphics__/graphics/entity/centrifuge/centrifuge-C-light.png"
  centrifuge.graphics_set.working_visualisations[2].animation.layers[2].filename = "__space-exploration-graphics__/graphics/entity/centrifuge/centrifuge-B-light.png"
  centrifuge.graphics_set.working_visualisations[2].animation.layers[3].filename = "__space-exploration-graphics__/graphics/entity/centrifuge/centrifuge-A-light.png"
end

local casting_machine_base_vertical =
{
  filename = "__space-exploration-graphics-2__/graphics/entity/casting-machine/casting-machine-base.png",
  priority = "high",
  x = 256,
  width = 192,
  height = 288,
  frame_count = 1,
  line_length = 2,
  shift = util.by_pixel(0, -8),
  scale = 0.5
}
local casting_machine_base_horizontal =
{
  filename = "__space-exploration-graphics-2__/graphics/entity/casting-machine/casting-machine-base.png",
  priority = "high",
  width = 256,
  height = 288,
  frame_count = 1,
  line_length = 2,
  shift = util.by_pixel(0, -8),
  scale = 0.5
}
local casting_machine_glow_vertical =
{
  draw_as_glow = true,
  blend_mode = "additive",
  filename = "__space-exploration-graphics-2__/graphics/entity/casting-machine/casting-machine-glow.png",
  priority = "high",
  x = 256,
  width = 192,
  height = 288,
  frame_count = 1,
  line_length = 2,
  shift = util.by_pixel(0, -8),
  scale = 0.5
}
local casting_machine_glow_horizontal =
{
  draw_as_glow = true,
  blend_mode = "additive",
  filename = "__space-exploration-graphics-2__/graphics/entity/casting-machine/casting-machine-glow.png",
  priority = "high",
  width = 256,
  height = 288,
  frame_count = 1,
  line_length = 2,
  shift = util.by_pixel(0, -8),
  scale = 0.5
}
local casting_machine_shadow_vertical =
{
  draw_as_shadow = true,
  filename = "__space-exploration-graphics-2__/graphics/entity/casting-machine/casting-machine-shadow.png",
  priority = "high",
  x = 256,
  width = 192,
  height = 288,
  frame_count = 1,
  line_length = 2,
  shift = util.by_pixel(16, -8),
  scale = 0.5
}
local casting_machine_shadow_horizontal =
{
  draw_as_shadow = true,
  filename = "__space-exploration-graphics-2__/graphics/entity/casting-machine/casting-machine-shadow.png",
  priority = "high",
  width = 256,
  height = 288,
  frame_count = 1,
  line_length = 2,
  shift = util.by_pixel(16, -8),
  scale = 0.5
}

--table.insert(data.raw["assembling-machine"]["industrial-furnace"].crafting_categories, "casting")
data:extend({
  {
    type = "assembling-machine",
    name = data_util.mod_prefix .. "casting-machine",
    icon = "__space-exploration-graphics-2__/graphics/icons/casting-machine.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {mining_time = 0.1, result = data_util.mod_prefix .. "casting-machine"},
    max_health = 200,
    corpse = "big-remnants",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-1.3, -0.8}, {1.3, 0.8}},
    selection_box = {{-1.5, -1}, {1.5, 1}},
    drawing_box_vertical_extension = 0.5,
    se_allow_in_space = true,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = {0.8, 0.5}, shadow_offset = {0.8, 0.5}, show_shadow = true },
        { variation = 18, main_offset = {0.8, 0.5}, shadow_offset = {0.8, 0.5}, show_shadow = true },
        { variation = 18, main_offset = {0.8, 0.5}, shadow_offset = {0.8, 0.5}, show_shadow = true },
        { variation = 18, main_offset = {0.8, 0.5}, shadow_offset = {0.8, 0.5}, show_shadow = true },
      }
    ),
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
      { type = "impact", percent = 30 },
      { type = "fire", percent = 30 },
    },
    open_sound = data_util.machine_open_sound,
    close_sound = data_util.machine_close_sound,
    impact_category = "metal",
    working_sound = {
      idle_sound = {
        filename = "__base__/sound/idle1.ogg",
        volume = 0.6
      },
      apparent_volume = 1.5,
      fade_in_ticks = 10,
      fade_out_ticks = 60,
      max_sounds_per_type = 2,
      sound = {
        filename = "__base__/sound/electric-furnace.ogg",
        volume = 0.7
      }
    },
    graphics_set = {
      always_draw_idle_animation = true,
      idle_animation =
      {
        east = {layers = {casting_machine_base_vertical, casting_machine_shadow_vertical}},
        west = {layers = {casting_machine_base_vertical, casting_machine_shadow_vertical}},
        north = {layers = {casting_machine_base_horizontal, casting_machine_shadow_horizontal}},
        south = {layers = {casting_machine_base_horizontal, casting_machine_shadow_horizontal}},
      },
      working_visualisations =
      {
        {
          fadeout = true,
          east_animation = {layers = {casting_machine_glow_vertical}, draw_as_light=true},
          west_animation = {layers = {casting_machine_glow_vertical}, draw_as_light=true},
          north_animation = {layers = {casting_machine_glow_horizontal}, draw_as_light=true},
          south_animation = {layers = {casting_machine_glow_horizontal}, draw_as_light=true},
        },
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.2, size = 8, shift = {0.0, 1}, color = {r = 1, g = 0.4, b = 0.1}}
        },
      },
    },
    crafting_categories = { "casting" },
    crafting_speed = 1,
    damaged_trigger_effect = {
      entity_name = "spark-explosion",
      offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
      offsets = { { 0, 1 } },
      type = "create-entity"
    },
    dying_explosion = "electric-furnace-explosion",
    energy_source = {
      emissions_per_minute = { pollution = 0.25 },
      type = "electric",
      usage_priority = "secondary-input",
      light_flicker =
      {
        minimum_light_size = 5,
        color = {1,0.3,0},
        minimum_intensity = 0.6,
        maximum_intensity = 0.95
      },
    },
    energy_usage = "50kW",
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = pipe_pics,
        pipe_covers = pipecoverspictures(),
        volume = 100,

        height = 2,
        pipe_connections = {
          { flow_direction="input-output", position = {0, -.5}, direction = defines.direction.north }
        },
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
      {
        production_type = "input",
        pipe_picture = pipe_pics,
        pipe_covers = pipecoverspictures(),
        volume = 100,

        height = 2,
        pipe_connections = {{ flow_direction="input-output", position = {0, .5}, direction = defines.direction.south }},
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
    },
    module_slots = 2,
    allowed_effects = data_util.all_effects_except("productivity"),
    water_reflection = {
      orientation_to_variation = true,
      pictures = {
        filename = "__base__/graphics/entity/boiler/boiler-reflection.png",
        height = 32,
        priority = "extra-high",
        scale = 5,
        shift = {
          0.15625,
          0.9375
        },
        variation_count = 4,
        width = 28
      },
      rotate = false
    },
  },
})

local logo_shattered_15 = {
  type = "simple-entity",
  name = data_util.mod_prefix .. "space-exploration-logo-shattered-15tiles",
  subgroup = "logo",
  order = "a[logo-15]",
  hidden = true,
  icon = "__space-exploration-graphics__/graphics/icons/space-exploration-logo-shattered.png",
  icon_size = 64,
  collision_box = {{-7.5, -2}, {7.5, 2}},
  selection_box = {{-7.5, -2}, {7.5, 2}},
  collision_mask = {layers={}},
  se_allow_in_space = true,
  max_health = 1000000,
  render_layer = "floor", -- Let biters and debris walk over it, looks weird otherwise
  secondary_draw_order = 1,
  picture = {
    filename = "__space-exploration-graphics__/graphics/entity/space-exploration-logo/space-exploration-logo-shattered.png",
    width = 1267,
    height = 269,
    scale = 0.375,
    shift = {0, -0.15}
  }
}

local logo_shadow_15 = {
  type = "simple-entity",
  name = data_util.mod_prefix .. "space-exploration-logo-shadow-15tiles",
  subgroup = "logo",
  order = "a[logo-15-shadow]",
  hidden = true,
  icon = "__space-exploration-graphics__/graphics/icons/space-exploration-logo-black.png",
  icon_size = 64,
  collision_box = {{-7.5, -2}, {7.5, 2}},
  selection_box = {{-7.5, -2}, {7.5, 2}},
  collision_mask = {layers={}},
  se_allow_in_space = true,
  max_health = 1000000,
  render_layer = "floor",
  secondary_draw_order = 0,
  picture = {
    filename = "__space-exploration-graphics__/graphics/entity/space-exploration-logo/space-exploration-logo-shadow.png",
    width = 566,
    height = 195,
    scale = 1.03125,
    shift = {0, -0.15},
    draw_as_glow = true,
  }
}

-- Used for x0.6875 zoom
local logo_shattered_22 = table.deepcopy(logo_shattered_15)
logo_shattered_22.name = data_util.mod_prefix .. "space-exploration-logo-shattered-22tiles"
logo_shattered_22.order = "a[logo-22]"
logo_shattered_22.picture.scale = logo_shattered_15.picture.scale * 1.4545454545
logo_shattered_22.picture.shift[2] = logo_shattered_15.picture.shift[2] * 1.4545454545
logo_shattered_22.collision_box = {{-11, -2}, {11, 2}}
logo_shattered_22.selection_box = {{-11, -2}, {11, 2}}

local logo_shadow_22 = table.deepcopy(logo_shadow_15)
logo_shadow_22.name = data_util.mod_prefix .. "space-exploration-logo-shadow-22tiles"
logo_shadow_22.order = "a[logo-22-shadow]"
logo_shadow_22.picture.scale = logo_shattered_22.picture.scale
logo_shadow_22.picture.shift = logo_shattered_22.picture.shift
logo_shadow_22.collision_box = logo_shattered_22.collision_box
logo_shadow_22.selection_box = logo_shattered_22.collision_box

-- Used for x0.5 zoom
local logo_shattered_30 = table.deepcopy(logo_shattered_15)
logo_shattered_30.name = data_util.mod_prefix .. "space-exploration-logo-shattered-30tiles"
logo_shattered_30.order = "a[logo-30]"
logo_shattered_30.picture.scale = logo_shattered_15.picture.scale * 2
logo_shattered_30.picture.shift[2] = logo_shattered_15.picture.shift[2] * 2
logo_shattered_30.collision_box = {{-15, -3}, {15, 3}}
logo_shattered_30.selection_box = {{-15, -3}, {15, 3}}

local logo_shadow_30 = table.deepcopy(logo_shadow_15)
logo_shadow_30.name = data_util.mod_prefix .. "space-exploration-logo-shadow-30tiles"
logo_shadow_30.order = "a[logo-30-shadow]"
logo_shadow_30.picture.scale = logo_shattered_30.picture.scale
logo_shadow_30.picture.shift = logo_shattered_30.picture.shift
logo_shadow_30.collision_box = logo_shattered_30.collision_box
logo_shadow_30.selection_box = logo_shattered_30.collision_box

local logo_white_15 = table.deepcopy(logo_shattered_15)
logo_white_15.name = data_util.mod_prefix .. "space-exploration-logo-white-15tiles"
logo_white_15.order = "a[logo-15-colour-white]"
logo_white_15.icon = "__space-exploration-graphics__/graphics/icons/space-exploration-logo-white.png"
logo_white_15.picture.filename = "__space-exploration-graphics__/graphics/entity/space-exploration-logo/space-exploration-logo-white.png"

local logo_black_15 = table.deepcopy(logo_shattered_15)
logo_black_15.name = data_util.mod_prefix .. "space-exploration-logo-black-15tiles"
logo_black_15.order = "a[logo-15-colour-black]"
logo_black_15.icon = "__space-exploration-graphics__/graphics/icons/space-exploration-logo-black.png"
logo_black_15.picture.filename = "__space-exploration-graphics__/graphics/entity/space-exploration-logo/space-exploration-logo-black.png"

data:extend({
  logo_shattered_15,
  logo_shattered_22,
  logo_shattered_30,
  logo_shadow_15,
  logo_shadow_22,
  logo_shadow_30,
  logo_white_15,
  logo_black_15,
})

local weapons_cache = table.deepcopy(data.raw["container"]["crash-site-chest-2"])
weapons_cache.localised_name = {"entity-name." .. weapons_cache.name}
weapons_cache.localised_description = {"entity-description." .. weapons_cache.name}
weapons_cache.name = data_util.mod_prefix .. "weapons-cache"
weapons_cache.type = "temporary-container"
weapons_cache.alert_after_time = 1
data:extend{weapons_cache}
