local scale = 0.4
local data_util = require("data_util")

local function shadow_pictures()
  local frame_count = 24
  local width = 359
  local height = 120
  local line_length = 3
  local pictures = {}
  for i = 1, frame_count do
    pictures[i] = {
      draw_as_shadow = true,
      filename = "__space-exploration-graphics__/graphics/entity/space-capsule/space-capsule-shadow.png",
      width = width,
      height = height,
      x = width * ((i -1) % line_length),
      y = height * math.floor((i -1) / line_length),
      shift = {21/32, 12/32},
      scale = scale
    }
  end
  return pictures
end

data:extend({
  { -- Capsule vehicle
    type = "car",
    name = data_util.mod_prefix .. "space-capsule-_-vehicle",
    subgroup = "composite-entity-parts",
    hidden = true,
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}}, -- 2 wide is most a vehicle can be and be able to get in
    selection_box = {{-1, -1}, {1, 1}},
    display_box = {{-1.5, -4}, {1.5, 1.5}},
    collision_mask  = {layers={}},
    --minable = { mining_time = 0.25, result = data_util.mod_prefix .. "space-capsule"},
    has_belt_immunity = true,
    selection_priority = 100,
    selectable_in_game = false,
    animation = {
      layers = {
        {
          animation_speed = 1,
          direction_count = 24,
          line_length = 8,
          filename = "__space-exploration-graphics__/graphics/entity/space-capsule/space-capsule.png",
          frame_count = 1,
          height = 362,
          width = 188,
          shift = {1/32, -8/32},
          scale = scale
        },
      }
    },
    braking_power = "200kW",
    energy_source = {
      type = "void"
    },
    consumption = "1W",
    effectivity = 0.0,
    energy_per_hit_point = 1,
    flags = { "placeable-neutral", "player-creation", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
    friction = 0.9,
    icons = data_util.add_icons(
      "__space-exploration-graphics__/graphics/icons/space-capsule.png",
      "__base__/graphics/icons/arrows/signal-input.png"
    ),
    inventory_size = 0,
    max_health = 1000,
    open_sound = {
      filename = "__base__/sound/car-door-open.ogg",
      volume = 0.7
    },
    close_sound = {
      filename = "__base__/sound/car-door-close.ogg",
      volume = 0.7
    },
    render_layer = "wires-above",
    rotation_speed = 0.00,
    order = "zz",
    weight = 10000,
  },
  { -- Scorched vehicle
    type = "car",
    name = data_util.mod_prefix .. "space-capsule-scorched-_-vehicle",
    subgroup = "composite-entity-parts",
    hidden = true,
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}}, -- 2 wide is most a vehicle can be and be able to get in
    selection_box = {{-1, -1}, {1, 1}},
    display_box = {{-1.5, -4}, {1.5, 1.5}},
    collision_mask  = {layers={}},
    --minable = { mining_time = 0.25, result = data_util.mod_prefix .. "space-capsule-scorched"},
    has_belt_immunity = true,
    selection_priority = 100,
    selectable_in_game = false,
    animation = {
      layers = {
        {
          animation_speed = 1,
          direction_count = 24,
          line_length = 8,
          filename = "__space-exploration-graphics__/graphics/entity/space-capsule/space-capsule-scorched.png",
          frame_count = 1,
          height = 362,
          width = 188,
          shift = {1/32, -8/32},
          scale = scale
        },
      }
    },
    braking_power = "200kW",
    energy_source = {
      type = "void"
    },
    consumption = "1W",
    effectivity = 0.5,
    energy_per_hit_point = 1,
    flags = { "placeable-neutral", "player-creation", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"},
    friction = 0.9,
    icons = data_util.add_icons(
      "__space-exploration-graphics__/graphics/icons/space-capsule-scorched.png",
      "__base__/graphics/icons/arrows/signal-input.png"
    ),
    inventory_size = 0,
    max_health = 1000,
    open_sound = {
      filename = "__base__/sound/car-door-open.ogg",
      volume = 0.7
    },
    close_sound = {
      filename = "__base__/sound/car-door-close.ogg",
      volume = 0.7
    },
    render_layer = "wires-above",
    rotation_speed = 0.00,
    order = "zz",
    weight = 10000,
  },
  { -- Capsule container
    type = "container",
    name = data_util.mod_prefix .. "space-capsule",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}}, -- 2 wide is most a vehicle can be and be able to get in
    selection_box = {{-1, -1}, {1, 1}},
    selection_priority = 200,
    display_box = {{-1.5, -4}, {1.5, 1.5}},
    collision_mask  = {
      layers = {
        water_tile = true,
        --object = true, -- Placeable on empty space
        floor = true,
        --player = true,
      },
    },
    icon = "__space-exploration-graphics__/graphics/icons/space-capsule.png",
    icon_size = 64,
    flags = { "placeable-neutral", "player-creation", "placeable-off-grid"},
    is_military_target = true,
    minable = { mining_time = 0.25, result = data_util.mod_prefix .. "space-capsule"},
    max_health = 1000,
    dying_explosion = "roboport-explosion",
    inventory_size = 40,
    open_sound = {filename = "__base__/sound/car-door-open.ogg",volume = 0.7},
    close_sound = {filename = "__base__/sound/car-door-close.ogg",volume = 0.7},
    impact_category = "metal",
    picture =
    {
      layers =
      {
        {
          filename = "__space-exploration-graphics__/graphics/entity/space-capsule/space-capsule.png",
          frame_count = 1,
          height = 362,
          width = 188,
          shift = {1/32, -8/32},
          scale = scale
        },
      }
    },
    order = "zz",
  },
  { -- Scorched container
    type = "container",
    name = data_util.mod_prefix .. "space-capsule-scorched",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}}, -- 2 wide is most a vehicle can be and be able to get in
    selection_box = {{-1, -1}, {1, 1}},
    selection_priority = 200,
    display_box = {{-1.5, -4}, {1.5, 1.5}},
    collision_mask  = {
      layers = {
        water_tile = true,
        --object = true, -- Placeable on empty space
        floor = true,
        --player = true,
      },
    },
    icon = "__space-exploration-graphics__/graphics/icons/space-capsule-scorched.png",
    icon_size = 64,
    flags = { "placeable-neutral", "player-creation", "placeable-off-grid"},
    is_military_target = true,
    minable = { mining_time = 0.25, result = data_util.mod_prefix .. "space-capsule-scorched"},
    max_health = 1000,
    dying_explosion = "roboport-explosion",
    inventory_size = 40,
    open_sound = {filename = "__base__/sound/car-door-open.ogg",volume = 0.7},
    close_sound = {filename = "__base__/sound/car-door-close.ogg",volume = 0.7},
    impact_category = "metal",
    picture =
    {
      layers =
      {
        {
          filename = "__space-exploration-graphics__/graphics/entity/space-capsule/space-capsule-scorched.png",
          frame_count = 1,
          height = 362,
          width = 188,
          shift = {1/32, -8/32},
          scale = scale
        },
      }
    },
    order = "zz",
  },
  { -- Capsule shadow
    type = "simple-entity-with-force",
    name = data_util.mod_prefix .. "space-capsule-_-vehicle-shadow",
    subgroup = "composite-entity-parts",
    hidden = true,
    collision_box = {{-0, -0}, {0, 0}},
    selection_box = {{-0, -0}, {0, 0}},
    collision_mask  = {
      layers = {},
      not_colliding_with_itself = true,
    },
    selectable_in_game = false,
    pictures = shadow_pictures(),
    flags = { "placeable-neutral", "placeable-off-grid"},
    icon = "__space-exploration-graphics__/graphics/icons/space-capsule.png",
    icon_size = 64,
    render_layer = "object",
    order = "zz",
  },
  { -- Capsule target selection tool
    type = "item",
    name = data_util.mod_prefix .. "space-capsule-targeter",
    icon = "__space-exploration-graphics__/graphics/icons/target.png",
    icon_size = 64,
    subgroup = "rocket-logistics",
    order = "a-d",
    stack_size = 1,
    flags = {"only-in-cursor"},
    hidden = true,
  }
})

local capsule = {
  filename = "__space-exploration-graphics__/graphics/entity/space-capsule/space-capsule.png",
  frame_count = 1,
  y = 362 * 2,
  height = 362,
  width = 188,
  shift = {1/32, -8/32},
  scale = scale
}

local emission = {
  filename = "__space-exploration-graphics__/graphics/entity/space-capsule/space-capsule-emission.png",
  frame_count = 1,
  height = 364,
  width = 165,
  shift = {-2/32, -7/32},
  scale = scale,
  blend_mode = "additive"
}

local procession_graphic_catalogue_types = require("__base__/prototypes/planet/procession-graphic-catalogue-types")
local cargo_pod_procession_catalogue =
{
  -- POD
  {
    index = procession_graphic_catalogue_types.pod_base,
    sprite = capsule
  },
  {
    index = procession_graphic_catalogue_types.pod_base_emission,
    type = "sprite",
    sprite = emission
  },
  {
    index = procession_graphic_catalogue_types.pod_open,
    sprite = capsule
  },
  {
    index = procession_graphic_catalogue_types.pod_open_emission,
    sprite = emission
  },
  {
    index = procession_graphic_catalogue_types.pod_shadow,
    sprite = util.sprite_load("__base__/graphics/entity/cargo-pod/pod-static-shadow",
    {
      priority = "medium",
      scale = 0.5,
    })
  },
  -- POD Animated
  {
    index = procession_graphic_catalogue_types.pod_anim_opening,
    animation = capsule
  },
  {
    index = procession_graphic_catalogue_types.pod_anim_opening_emission,
    animation = emission
  },
  {
    index = procession_graphic_catalogue_types.pod_anim_landing,
    animation = {
      filename = "__space-exploration-graphics__/graphics/entity/space-capsule/space-capsule.png",
      frame_count = 16,
      line_length = 8,
      --y = 362 * 2,
      height = 362,
      width = 188,
      shift = {1/32, -8/32},
      scale = scale,
      animation_speed = 0.5,
      run_mode = "backward"
    }
  },
  {
    index = procession_graphic_catalogue_types.pod_anim_landing_emission,
    animation = emission
  },
  {
    index = procession_graphic_catalogue_types.pod_anim_rotation_closed,
    animation = capsule
   },
   {
    index = procession_graphic_catalogue_types.pod_anim_rotation_closed_emission,
    animation = emission
   },
   {
    index = procession_graphic_catalogue_types.pod_anim_rotation_open,
    animation = capsule
   },
   {
    index = procession_graphic_catalogue_types.pod_anim_rotation_open_emission,
    animation = emission
   },
  -- POD Thrusters
  {
    index = procession_graphic_catalogue_types.thruster_flames_loop,
    type = "sprite",
    animation = util.sprite_load("__base__/graphics/entity/cargo-pod/pod-thruster-loop",
    {
      animation_speed = 0.5,
      scale = 0.25,
      frame_count = 10,
      draw_as_glow = true,
      shift = util.by_pixel(0, 64),
      blend_mode = "additive",
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
    })
  },
  {
    index = procession_graphic_catalogue_types.thruster_flames_start,
    type = "sprite",
    animation = util.sprite_load("__base__/graphics/entity/cargo-pod/pod-thruster-ignition",
    {
      animation_speed = 0.5,
      scale = 0.25,
      frame_count = 10,
      draw_as_glow = true,
      shift = util.by_pixel(0, 64),
      blend_mode = "additive",
      priority = "no-atlas",
      flags = { "group=effect-texture", "linear-minification", "linear-magnification" },
    })
  },
  {
    index = procession_graphic_catalogue_types.reentry_flames,
    animation = emission
  }
}

for _, chd in pairs(data.raw["cargo-landing-pad"]["cargo-landing-pad"].cargo_station_parameters.hatch_definitions) do
  -- it only fits in the middel (1.25 offset) hatch
  if chd.offset and (chd.offset[1] == 1.25 or chd.offset.x == 1.25) then
    table.insert(chd.receiving_cargo_units, data_util.mod_prefix .. "space-capsule-pod")
  end
end

local capsule_pod = table.deepcopy(data.raw["cargo-pod"]["cargo-pod"])
capsule_pod.name = data_util.mod_prefix .. "space-capsule-pod"
capsule_pod.localised_name = {"entity-name."..data_util.mod_prefix.."space-capsule"}
capsule_pod.icon = "__space-exploration-graphics__/graphics/icons/space-capsule.png"

capsule_pod.default_graphic = { type = "pod-catalogue", catalogue_id = procession_graphic_catalogue_types.pod_base }
capsule_pod.default_shadow_graphic = { type = "pod-catalogue", catalogue_id = procession_graphic_catalogue_types.pod_shadow }
capsule_pod.procession_graphic_catalogue = cargo_pod_procession_catalogue
capsule_pod.spawned_container = data_util.mod_prefix .. "space-capsule"

data:extend({
  capsule_pod
})
