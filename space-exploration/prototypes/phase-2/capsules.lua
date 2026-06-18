local data_util = require("data_util")
local mod_prefix = data_util.mod_prefix
require ("__base__.prototypes.entity.biter-animations")

local biter_friend = table.deepcopy(data.raw.unit["big-biter"])
biter_friend.name = mod_prefix .. "biter-friend"
local friend_size = 0.9
friend_tint1 = {0.1, 1, 1, 1}
friend_tint2 = {0.2, 0.6, 0.9, 0.7}
biter_friend.run_animation = biterrunanimation(0.8, friend_tint1, friend_tint2)
biter_friend.attack_parameters.animation = biterattackanimation(0.8, friend_tint1, friend_tint2)
biter_friend.max_health = 500
biter_friend.healing_per_tick = 0.02
biter_friend.ai_settings = {
  destroy_when_commands_fail = false, -- Prevent despawn
  allow_try_return_to_spawner = false -- Not important but might save some performance
}
biter_friend.collision_mask = {
  layers = { -- Default unit mask + empty_space_collision_layer
    player = true,
    train = true,
    [empty_space_collision_layer] = true,
  },
  not_colliding_with_itself = true,
}
biter_friend.resistances =
{
  {
    type = "physical",
    decrease = 8,
    percent = 10
  },
  {
    type = "explosion",
    percent = 50
  },
  {
    type = "fire",
    percent = 50
  },
  {
    type = "laser",
    percent = 50
  }
}
biter_friend.corpse = biter_friend.name.."-corpse"
local biter_friend_corpse = table.deepcopy(data.raw.corpse["big-biter-corpse"])
biter_friend_corpse.name = biter_friend.name.."-corpse"
data:extend({
  biter_friend,
  add_biter_die_animation(friend_size, friend_tint1, friend_tint2,
  {
    type = "corpse",
    name = biter_friend.name.."-corpse",
    icon = "__base__/graphics/icons/big-biter-corpse.png",
    icon_size = 64,
    selectable_in_game = true,
    selection_box = {{-1, -1}, {1, 1}},
    subgroup="corpses",
    order = "c[corpse]-a[biter]-c[big]",
    flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-on-map"}
  })
})

local unit_settings = {
  {
    name = biter_friend.name,
    stack_size = 50,
    cooldown = 20,
    localised_name = {"item-name." .. mod_prefix .. "capsule-" .. biter_friend.name},
    item_flags = {},
    hidden = true,
  },
  {
    name="small-biter",
    stack_size = 100,
    cooldown = 10,
    craft_time = 10,
    prerequisites = {mod_prefix .. "vitalic-acid"},
    ingredients = {
      { type = "item", name = mod_prefix .. "specimen", amount = 1 },
      { type = "fluid", name = mod_prefix .. "vitalic-acid", amount = 20 },
      { type = "fluid", name = mod_prefix .. "nutrient-gel", amount = 20 },
    },
    tech_unit = { count = 100, time = 60, ingredients = { { mod_prefix .. "biological-science-pack-1", 1 }, } }
  },
  {
    name="medium-biter",
    stack_size = 75,
    cooldown = 15,
    craft_time = 20,
    prerequisites = {mod_prefix.."capsule-small-biter", mod_prefix .. "vitalic-reagent"},
    ingredients = {
      { type = "item", name = mod_prefix .. "capsule-small-biter", amount = 1 },
      { type = "item", name = mod_prefix .. "vitalic-reagent", amount = 4 },
      { type = "fluid", name = mod_prefix .. "nutrient-gel", amount = 40 },
    },
    tech_unit = { count = 200, time = 60, ingredients = { { mod_prefix .. "biological-science-pack-2", 1 }, } }
  },
  {
    name="big-biter",
    stack_size = 50,
    cooldown = 20,
    craft_time = 30,
    prerequisites = {mod_prefix.."capsule-medium-biter", mod_prefix .. "vitalic-epoxy"},
    ingredients = {
      { type = "item", name = mod_prefix .. "capsule-medium-biter", amount = 1 },
      { type = "item", name = mod_prefix .. "vitalic-epoxy", amount = 4 },
      { type = "fluid", name = mod_prefix .. "nutrient-gel", amount = 60 },
    },
    tech_unit = { count = 300, time = 60, ingredients = { { mod_prefix .. "biological-science-pack-3", 1 }, } }
  },
  {
    name="behemoth-biter",
    stack_size = 25,
    cooldown = 25,
    craft_time = 40,
    prerequisites = {mod_prefix.."capsule-big-biter", mod_prefix .. "self-sealing-gel"},
    ingredients = {
      { type = "item", name = mod_prefix .. "capsule-big-biter", amount = 1 },
      { type = "item", name = mod_prefix .. "self-sealing-gel", amount = 4 },
      { type = "fluid", name = mod_prefix .. "nutrient-gel", amount = 80 },
    },
    tech_unit = { count = 400, time = 60, ingredients = { { mod_prefix .. "biological-science-pack-4", 1 }, } }
  },
  {
    name="small-spitter",
    stack_size = 100,
    cooldown = 10,
    craft_time = 10,
    prerequisites = {mod_prefix .. "vitalic-acid"},
    ingredients = {
      { type = "item", name = mod_prefix .. "specimen", amount = 1 },
      { type = "fluid", name = mod_prefix .. "vitalic-acid", amount = 20 },
      { type = "fluid", name = mod_prefix .. "nutrient-gel", amount = 20 },
    },
    tech_unit = { count = 100, time = 60, ingredients = { { mod_prefix .. "biological-science-pack-1", 1 }, } }
  },
  {
    name="medium-spitter",
    stack_size = 75,
    cooldown = 15,
    craft_time = 20,
    prerequisites = {mod_prefix.."capsule-small-spitter", mod_prefix .. "vitalic-reagent"},
    ingredients = {
      { type = "item", name = mod_prefix .. "capsule-small-spitter", amount = 1 },
      { type = "item", name = mod_prefix .. "vitalic-reagent", amount = 4 },
      { type = "fluid", name = mod_prefix .. "nutrient-gel", amount = 40 },
    },
    tech_unit = { count = 200, time = 60, ingredients = { { mod_prefix .. "biological-science-pack-2", 1 }, } }
  },
  {
    name="big-spitter",
    stack_size = 50,
    cooldown = 20,
    craft_time = 30,
    prerequisites = {mod_prefix.."capsule-medium-spitter", mod_prefix .. "vitalic-epoxy"},
    ingredients = {
      { type = "item", name = mod_prefix .. "capsule-medium-spitter", amount = 1 },
      { type = "item", name = mod_prefix .. "vitalic-epoxy", amount = 4 },
      { type = "fluid", name = mod_prefix .. "nutrient-gel", amount = 60 },
    },
    tech_unit = { count = 300, time = 60, ingredients = { { mod_prefix .. "biological-science-pack-3", 1 }, } }
  },
  {
    name="behemoth-spitter",
    stack_size = 25,
    cooldown = 25,
    craft_time = 40,
    prerequisites = {mod_prefix.."capsule-big-spitter", mod_prefix .. "self-sealing-gel"},
    ingredients = {
      { type = "item", name = mod_prefix .. "capsule-big-spitter", amount = 1 },
      { type = "item", name = mod_prefix .. "self-sealing-gel", amount = 4 },
      { type = "fluid", name = mod_prefix .. "nutrient-gel", amount = 80 },
    },
    tech_unit = { count = 400, time = 60, ingredients = { { mod_prefix .. "biological-science-pack-4", 1 }, } }
  },
}

for i, unit_setting in pairs(unit_settings) do
  local name = mod_prefix .. "capsule-"..unit_setting.name
  local base_entity = data.raw.unit[unit_setting.name]
  data:extend({
    {
      type = "capsule",
      subgroup = "capsule",
      name = name,
      capsule_action = {
        attack_parameters = {
          ammo_category = "capsule",
          ammo_type = {
            action = {
              action_delivery = {
                projectile = name,
                starting_speed = 0.3,
                type = "projectile"
              },
              type = "direct"
            },
            category = "capsule",
            target_type = "position"
          },
          cooldown = unit_setting.cooldown,
          projectile_creation_distance = 0.6,
          range = 25,
          type = "projectile"
        },
        type = "throw"
      },
      icons = {
        {icon = "__space-exploration-graphics__/graphics/icons/vatling.png", icon_size = 64, shift = {-8, 0}},
        {icon = base_entity.icon, icon_size = base_entity.icon_size, shift = {2, 0}}
      },
      order = "u[unit-capsule]-"..string.format("%02d", i),
      stack_size = unit_setting.stack_size,
      localised_name = unit_setting.localised_name or {"space-exploration.unit-capsule", {"entity-name."..unit_setting.name}},
      flags = unit_setting.item_flags,
    },
    {
      type = "projectile",
      name = name,
      localised_name = unit_setting.localised_name or {"space-exploration.unit-capsule", {"entity-name."..unit_setting.name}},
      subgroup = "ammo-effects",
      hidden = true,
      acceleration = 0.005,
      action = {
        action_delivery = {
          target_effects = {
            entity_name = unit_setting.name,
            show_in_tooltip = true,
            trigger_created_entity = true,
            find_non_colliding_position = true,
            type = "create-entity"
          },
          type = "instant"
        },
        type = "direct"
      },
      icons = {
        {icon = "__space-exploration-graphics__/graphics/icons/vatling.png", icon_size = 64, shift = {-8, 0}},
        {icon = base_entity.icon, icon_size = base_entity.icon_size, shift = {2, 0}}
      },
      animation = {
        filename = "__base__/graphics/entity/poison-capsule/poison-capsule.png",
        frame_count = 1,
        height = 32,
        priority = "high",
        width = 32
      },
      flags = {
        "not-on-map"
      },
      light = {
        intensity = 0.5,
        size = 4
      },
      shadow = {
        filename = "__base__/graphics/entity/poison-capsule/poison-capsule-shadow.png",
        frame_count = 1,
        height = 32,
        priority = "high",
        width = 32
      },
      smoke = nil,
    },
  })
  if unit_setting.ingredients then
    data:extend({
      {
        type = "recipe",
        name = name,
        results = {
          {type = "item", name = name, amount = 1},
        },
        enabled = false,
        energy_required = unit_setting.craft_time,
        ingredients = unit_setting.ingredients,
        requester_paste_multiplier = 1,
        always_show_made_in = true,
        category = "space-growth"
      }
    })
  end
  if unit_setting.tech_unit then
    data:extend({
      {
        type = "technology",
        name = name,
        effects = {
         {
           type = "unlock-recipe",
           recipe = name,
         },
        },
        icons = {
          {icon = "__space-exploration-graphics__/graphics/technology/vatling.png", icon_size = 128},
          {icon = base_entity.icon, icon_size = base_entity.icon_size, shift = {0, 8}}
        },
        order = "e-g",
        prerequisites = unit_setting.prerequisites,
        unit = unit_setting.tech_unit,
        localised_name = {"space-exploration.unit-capsule", {"entity-name."..unit_setting.name}},
        localised_description = {"technology-description.se-unit-capsule", {"entity-name."..unit_setting.name}}
      },
    })
  end
end
