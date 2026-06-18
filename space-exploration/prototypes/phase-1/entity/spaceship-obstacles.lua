local data_util = require("data_util")

local health_multiplier = 300

-- projectile: invisible. Deals damage if it hits stuff, maybe destroys floor too.
-- graphic: The visible graphic, may also be mined.
-- targetable: invisible. exists so that turrets will shoot it, should only exist when moving.
local blank = {
  filename = "__space-exploration-graphics__/graphics/blank.png",
  priority = "high",
  frame_count = 1,
  height = 1,
  width = 1,
  -- direction_count = 1
}
local blank_d18 = {
  filename = "__space-exploration-graphics__/graphics/blank.png",
  priority = "high",
  frame_count = 1,
  height = 1,
  width = 1,
  direction_count = 18
}
local meteors = {
  ["meteor-01"] = {209, 138},
  ["meteor-02"] = {165,129},
  ["meteor-03"] = {151,139},
  ["meteor-04"] = {216,110},
  ["meteor-05"] = {154,147},
  ["meteor-06"] = {154,132},
  ["meteor-07"] = {193,120},
  ["meteor-08"] = {136,117},
  ["meteor-09"] = {157,115},
  ["meteor-10"] = {198,153},
  ["meteor-11"] = {190,115},
  ["meteor-12"] = {229,126},
  ["meteor-13"] = {151,125},
  ["meteor-14"] = {137,117},
  ["meteor-15"] = {201,141},
  ["meteor-16"] = {209,154},
}
local function collision_mask()
  return {
    layers = {
      [vehicle_collision_layer] = true,
      player = true,
      floor = true,
      [flying_collision_layer] = true,
      [projectile_collision_layer] = true,
    },
    not_colliding_with_itself = true
  }
end
local resistances = {
  -- no laser
  { type = "explosion", percent = 10 },
  { type = "physical", percent = 20},
  { type = "electric", percent = 50 },
  { type = "fire", percent = 90 },
  { type = "poison", percent = 100 },
  --{ type = "meteor", percent = 100 },
}

local sizes = {
  ["small"] = {
    size = 1,
    radius = 0.125,
    graphic_scale = 0.15,
    minimap_graphic_scale = 0.25,
    max_health = 20*health_multiplier,
    weight = 100,
    damage = 200,
    tint = {0.6,0.6,0.6},
    minable = {
      mining_particle = "stone-particle",
      mining_time = 0.2,
      results = {
        {type = "item", name = "stone", amount_min = 1, amount_max = 3},
        {type = "item", name = "iron-ore", amount_min = 1, amount_max = 3},
        {type = "item", name = "copper-ore", amount_min = 1, amount_max = 3},
      },
    },
    target_effects = {
      {
        damage = {
          amount = 200,
          type = "meteor"
        },
        type = "damage"
      },
      { type = "create-entity", entity_name = "explosion-hit" },
    },
  },
  ["medium"] = {
    size = 2,
    radius = 0.25,
    graphic_scale = 0.3,
    minimap_graphic_scale = 0.375,
    max_health = 200*health_multiplier,
    weight = 1000,
    tint = {0.8,0.8,0.8},
    minable = {
      mining_particle = "stone-particle",
      mining_time = 0.5,
      results = {
        {type = "item", name = "stone", amount_min = 0, amount_max = 15},
        {type = "item", name = "iron-ore", amount_min = 0, amount_max = 15},
        {type = "item", name = "copper-ore", amount_min = 0, amount_max = 15},
      },
    },
    target_effects = {
      { type = "nested-result", action = { type = "area", radius = 0.5,
          action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 400, type = "meteor" }}}},
      }},
      { type = "nested-result", action = { type = "area", radius = 1,
          action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 40, type = "meteor" }}}},
      }},
      { type = "create-entity", entity_name = "big-explosion-hit" },
    }
  },
  ["large"] = {
    size = 3,
    radius = 1,
    graphic_scale = 0.7,
    minimap_graphic_scale = 0.5,
    max_health = 2000*health_multiplier,
    weight = 10000,
    tint = {1,1,1},
    minable = {
      mining_particle = "stone-particle",
      mining_time = 1,
      results = {
        {type = "item", name = "stone", amount_min = 0, amount_max = 5000},
        {type = "item", name = "iron-ore", amount_min = 0, amount_max = 5000},
        {type = "item", name = "copper-ore", amount_min = 0, amount_max = 5000},
        {type = "item", name = "uranium-ore", amount_min = 0, amount_max = 500},
      },
    },
    target_effects = {
      { type = "nested-result", action = { type = "area", radius = 0.5,
          action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 4000, type = "meteor" }}}},
      }},
      { type = "nested-result", action = { type = "area", radius = 1,
          action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 400, type = "meteor" }}}},
      }},
      { type = "create-entity", entity_name = "big-explosion-hit" },
    }
  },
}

for size_name, size in pairs(sizes) do
  local i = 0
  for meteor_name, meteor in pairs(meteors) do
    -- make the graphics variations
    i = i + 1
    data:extend({
      -- sprites get attached to the vehicles using the target of a LuaRendering.draw_sprite call
      {
        type = "sprite",
        name = data_util.mod_prefix .. "spaceship-obstacle-"..size_name.."-sprite-"..i,
        filename = "__space-exploration-graphics__/graphics/entity/meteor/"..meteor_name..".png",
        priority = "low",
        width = math.floor(meteor[1]),
        height = math.floor(meteor[2]),
        shift = {0,0},
        apply_runtime_tint = true,
        tint = size.tint,
        scale = size.graphic_scale,
      },
      -- entities are used for making them mineable when the ship is stopped
      {
        type = "simple-entity",
        name = data_util.mod_prefix .. "spaceship-obstacle-"..size_name.."-static-"..i,
        subgroup = "grass",
        selectable_in_game = true,
        selection_priority = 2,
        count_as_rock_for_filtered_deconstruction = true,
        collision_box = { { -size.radius, -size.radius }, { size.radius, size.radius } },
        collision_mask = collision_mask(),
        selection_box = { { -(size.radius+1), -(size.radius+1) }, { (size.radius+1), (size.radius+1) } },
        minable = table.deepcopy(size.minable),
        flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
        factoriopedia_alternative = ((size_name ~= "large") or (i ~= 1)) and "se-spaceship-obstacle-large-static-1" or nil,
        icon = "__base__/graphics/icons/small-scorchmark.png",
        icon_size = 64,
        max_health = size.max_health,
        order = "s-e-w-f",
        render_layer = "object",
        picture = {
          filename = "__space-exploration-graphics__/graphics/entity/meteor/"..meteor_name..".png",
          width = math.floor(meteor[1]),
          height = math.floor(meteor[2]),
          priority = "low",
          shift = { 0, 0 },
          scale = size.graphic_scale,
          tint = size.tint,
        },
        mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
        dying_explosion = "explosion-hit",
        localised_name = {"entity-name."..size_name.."-asteroid"},
        resistances = resistances,
      }
    })
  end
  -- make the asteroid vehicle, the debris vehicle, the character, and the damage explosion
  local vehicle = { -- This will have the entity name, asteroid or debris
    type = "car",
    name = data_util.mod_prefix .. "spaceship-obstacle-"..size_name.."-vehicle",
    collision_mask = collision_mask(),
    collision_box = { { -size.radius, -size.radius }, { size.radius, size.radius } },
    selection_box = { { -(size.radius+1), -(size.radius+1) }, { size.radius+1, size.radius+1 } },
    selectable_in_game = false,
    has_belt_immunity = true,
    animation = {
      layers = {
        {
          animation_speed = 1,
          direction_count = 1,
          filename = "__space-exploration-graphics__/graphics/blank.png",
          frame_count = 1,
          height = 1,
          width = 1
        },
      }
    },
    braking_power = "200kW",
    energy_source = {type = "void"},
    consumption = "150kW",
    effectivity = 1,
    energy_per_hit_point = 1,
    flags = { "placeable-neutral", "player-creation", "placeable-off-grid" },
    friction = 0.0000000000000001,
    hidden = true,
    icons = {
      {
        icon = "__base__/graphics/icons/small-scorchmark.png",
        icon_size = 64,
        scale = 0.5,
      },
      {
        icon = "__core__/graphics/icons/unknown.png",
        icon_size = 64,
        scale = 0.5,
      },
    },
    inventory_size = 0,
    max_health = size.max_health,
    render_layer = "object",
    rotation_speed = 0.01,
    subgroup = "wrecks",
    order = "zz",
    weight = size.weight,
    resistances = resistances,
    immune_to_rock_impacts = true,
    immune_to_tree_impacts = true,
    localised_name = {"entity-name."..size_name.."-asteroid"},
    crash_trigger = {
      type = "create-entity",
      entity_name = data_util.mod_prefix .. "spaceship-obstacle-explosion-"..size_name,
      trigger_created_entity = true
    },
    minimap_representation = {
      filename = "__space-exploration-graphics__/graphics/entity/meteor/meteor-minimap-representation.png",
      flags = {"icon"},
      size = {20, 20},
      scale = size.minimap_graphic_scale
    },
    selected_minimap_representation = {
      filename = "__space-exploration-graphics__/graphics/entity/meteor/meteor-minimap-representation.png",
      flags = {"icon"},
      size = {20, 20},
      scale = size.minimap_graphic_scale
    },
    trigger_target_mask = {"common"}
  }
  local debris_vehicle = table.deepcopy(vehicle)
  debris_vehicle.name = data_util.mod_prefix .. "spaceship-obstacle-debris-"..size_name.."-vehicle"
  debris_vehicle.localised_name = {"entity-name."..size_name.."-asteroid"}
  data:extend({
    vehicle,
    debris_vehicle,
    { -- applies to both the asteroid and the same sized debris
      type = "explosion",
      name = data_util.mod_prefix .. "spaceship-obstacle-explosion-"..size_name,
      subgroup = "explosions",
      hidden = true,
      icons = {
        {
          icon = "__base__/graphics/icons/explosion.png",
          icon_size = 64,
          scale = 0.5,
        },
        {
          icon = "__space-exploration-graphics__/graphics/icons/spaceship.png",
          icon_size = 64,
          scale = 0.5,
        },
      },
      animations = blank,
      created_effect = {
        type = "direct",
        action_delivery = {
          type = "instant",
          target_effects = size.target_effects,
        },
      },
      flags = {"placeable-off-grid"},
    },
  })
end

local enemy_proxy = table.deepcopy(data.raw.character.character)
enemy_proxy.name = data_util.mod_prefix .. "spaceship-enemy-proxy"
enemy_proxy.localised_name = {"entity-name.proxy"}
enemy_proxy.crafting_categories = {"dummy"}
enemy_proxy.character_corpse = nil
enemy_proxy.max_health = 1
enemy_proxy.light = nil
enemy_proxy.animations = {{
  idle = blank_d18,
  idle_with_gun = blank_d18,
  running = blank_d18,
  running_with_gun = blank_d18,
  mining_with_tool = blank_d18,
}}
enemy_proxy.collision_mask = {layers={}}
enemy_proxy.hidden = true
data:extend({
  enemy_proxy,
  { -- This will have the entity name, asteroid or debris
     type = "car",
     name = data_util.mod_prefix.."spaceship-travel-anchor",
     subgroup = "environmental-effects",
     hidden = true,
     collision_mask = {layers={}},
     collision_box = {{0,0},{0,0}},
     has_belt_immunity = true,
     icons = data_util.add_icons(
      "__space-exploration-graphics__/graphics/icons/astronomic/asteroid-belt.png",
      "__space-exploration-graphics__/graphics/icons/arrows/arrow_left_down_white.png"
     ),
     animation = {
       layers = {
         {
           animation_speed = 1,
           direction_count = 1,
           filename = "__space-exploration-graphics__/graphics/blank.png",
           frame_count = 1,
           height = 1,
           width = 1
         },
       }
     },
     braking_power = "200kW",
     energy_source = {type = "void"},
     consumption = "150kW",
     effectivity = 1,
     energy_per_hit_point = 1,
     flags = { "placeable-neutral", "player-creation", "placeable-off-grid" },
     friction = 0.0000000000000001,
     inventory_size = 0,
     max_health = 1000000,
     render_layer = "object",
     rotation_speed = 0.01,
     order = "zz",
     weight = 1000,
     resistances = resistances,
     immune_to_rock_impacts = true,
     immune_to_tree_impacts = true,
     localised_name = {"entity-name.small-asteroid"},
     selectable_in_game = false,
     minimap_representation = blank,
     selected_minimap_representation = blank,
     trigger_target_mask = {"common"}
  },
  -- SPECK
  { -- just a visual for motion
    type = "simple-entity",
    name = data_util.mod_prefix.."spaceship-speck-graphic",
    subgroup = "environmental-effects",
    hidden = true,
    direction_only = true,
    flags = { "not-on-map", "placeable-off-grid" },
    acceleration = 0,
    collision_mask = {
      layers = {},
      not_colliding_with_itself = true,
    },
    icons = data_util.add_icons(
     "__space-exploration-graphics__/graphics/icons/astronomic/asteroid-belt.png",
     "__space-exploration-graphics__/graphics/icons/arrows/arrow_left_down_white.png"
    ),
    collision_box = { { -0.0, -0.0 }, { 0.0, 0.0 } },
    pictures = {
      filename = "__space-exploration-graphics__/graphics/entity/spaceship-particle/speck.png",
      frame_count = 1,
      height = 50,
      priority = "high",
      width = 3
    },
    localised_name = {"entity-name.small-asteroid"},
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "spaceship-speck-graphic",
    filename = "__space-exploration-graphics__/graphics/entity/spaceship-particle/speck.png",
    priority = "extra-high",
    width = 3,
    height = 50,
    shift = {0,0},
    apply_runtime_tint = true,
  },
})

-- moveable entities
data:extend({
   {
    type = "simple-entity-with-force",
    name = data_util.mod_prefix .. "spaceship-obstacle-entity-small-targetable",
    subgroup = "environmental-effects",
    hidden = true,
    selectable_in_game = false,
    collision_box = { { -0, -0 }, { 0, 0 } },
    collision_mask = {
      layers = {},
      not_colliding_with_itself = true,
    },
    selection_box = { { -0.2, -0.2 }, { 0.2, 0.2 } },
    flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
    icons = {
      {
        icon = "__base__/graphics/icons/small-scorchmark.png",
        icon_size = 64,
        scale = 0.5,
      },
      {
        icon = "__core__/graphics/icons/unknown.png",
        icon_size = 64,
        scale = 0.5,
      },
    },
    max_health = 20*health_multiplier,
    order = "s-e-w-f",
    render_layer = "object",
    picture = blank,
    dying_explosion = "explosion-hit",
    localised_name = {"entity-name.small-asteroid"},
    resistances = resistances,
  },
  {
    type = "projectile",
    name = data_util.mod_prefix.."spaceship-obstacle-entity-small-projectile",
    subgroup = "environmental-effects",
    hidden = true,
    icons = {
      {
        icon = "__space-exploration-graphics__/graphics/icons/astronomic/asteroid-belt.png",
        icon_size = 64,
        scale = 0.5,
      },
      {
        icon = "__core__/graphics/icons/unknown.png",
        icon_size = 64,
        scale = 0.5,
      },
    },
    direction_only = true,
    flags = { "not-on-map", "placeable-off-grid" },
    acceleration = 0,
    collision_box = { { -0.05, -0.25 }, { 0.05, 0.25 } },
    force_condition = "not-friend",
    action = {
      action_delivery = {
        target_effects = {
          {
            damage = {
              amount = 200,
              type = "meteor"
            },
            type = "damage"
          },
          { type = "create-entity", entity_name = "explosion-hit" },
        },
        type = "instant"
      },
      type = "direct"
    },
    animation = blank,
    localised_name = {"entity-name.small-asteroid"},
  },
  {
    type = "simple-entity-with-force",
    name = data_util.mod_prefix .. "spaceship-obstacle-entity-large-targetable",
    selectable_in_game = false,
    collision_box = { { -0, -0 }, { 0, 0 } },
    collision_mask = {
      layers = {},
      not_colliding_with_itself = true,
    },
    selection_box = { { -1, -1 }, { 1, 1 } },
    flags = { "placeable-neutral", "player-creation", "placeable-off-grid"},
    subgroup = "environmental-effects",
    hidden = true,
    icons = {
      {
        icon = "__base__/graphics/icons/small-scorchmark.png",
        icon_size = 64,
        scale = 0.5,
      },
      {
        icon = "__core__/graphics/icons/unknown.png",
        icon_size = 64,
        scale = 0.5,
      },
    },
    max_health = 2000*health_multiplier,
    order = "s-e-w-f",
    render_layer = "object",
    pictures = blank,
    dying_explosion = "big-explosion-hit",
    localised_name = {"entity-name.small-asteroid"},
    resistances = resistances,
  },
  {
    type = "projectile",
    name = data_util.mod_prefix.."spaceship-obstacle-entity-large-projectile",
    subgroup = "environmental-effects",
    hidden = true,
    icons = {
      {
        icon = "__space-exploration-graphics__/graphics/icons/astronomic/asteroid-belt.png",
        icon_size = 64,
        scale = 0.5,
      },
      {
        icon = "__core__/graphics/icons/unknown.png",
        icon_size = 64,
        scale = 0.5,
      },
    },
    direction_only = true,
    flags = { "not-on-map", "placeable-off-grid" },
    acceleration = 0,
    collision_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    force_condition = "not-friend",
    action = {
      action_delivery = {
        target_effects = {
          { type = "nested-result", action = { type = "area", radius = 0.5,
              action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 4000, type = "meteor" }}}},
          }},
          { type = "nested-result", action = { type = "area", radius = 1.5,
              action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 150, type = "meteor" }}}},
          }},
          { type = "nested-result", action = { type = "area", radius = 2.5,
              action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 150, type = "meteor" }}}},
          }},
          { type = "create-entity", entity_name = "big-explosion-hit" },
        },
        type = "instant"
      },
      type = "direct"
    },
    animation = blank,
    localised_name = {"entity-name.small-asteroid"},
  },
})
