local data_util = require("data_util")

data.raw["utility-constants"].default.bonus_gui_ordering["tesla"] = "k-c"
data:extend({
  {
    type = "ammo-category",
    name = "tesla",
    subgroup = "ammo-category",
    bonus_gui_order = "k-c",
    icon = "__space-exploration-graphics__/graphics/icons/ammo-category/tesla-gun.png",
    icon_size = 64,
  },
  {
    type = "gun",
    name = data_util.mod_prefix .. "tesla-gun",
    attack_parameters = {
      ammo_category = "tesla",
      cooldown = 10,
      movement_slow_down_factor = 0.2,
      damage_modifier = 1,
      range = 10,
      type = "projectile",
      sound = {
        {
          filename = "__space-exploration__/sound/tesla-gunshot.ogg",
          volume = 0.9
        },
      },
    },
    icon = "__space-exploration-graphics__/graphics/icons/tesla-gun.png",
    icon_size = 64,
    order = "z-t[tesla]",
    stack_size = 5,
    subgroup = "gun",
  },
  {
    type = "ammo",
    name = data_util.mod_prefix .. "tesla-ammo",
    ammo_category = Shared.tesla_ammo_category,
    ammo_type =
    {
      category = Shared.tesla_ammo_category,
      target_type = "direction",
      action = {
        {
          type = "direct",
          action_delivery = {
            type = "instant",
            target_effects = {
              {
                type = "create-entity",
                entity_name = data_util.mod_prefix .. "tesla-gun-trigger",
                trigger_created_entity = true,
                show_in_tooltip = false,
              },
              {
                type = "damage",
                damage = {
                  amount = Shared.tesla_base_damage, -- Because this is a "direction" target_type doing "direct" damage, this damage won't actually be applied and is only for the tooltip
                  type = "electric"
                },
              },
            }
          }
        },
      }
    },
    icon = "__space-exploration-graphics__/graphics/icons/tesla-ammo.png",
    icon_size = 64,
    magazine_size = 10,
    order = "z-t[tesla]",
    stack_size = 200,
    subgroup = "ammo",
    sound = {
      {
        filename = "__space-exploration__/sound/tesla-gunshot.ogg",
        volume = 0.9
      },
    },
  },
  {
    type = "explosion",
    name = data_util.mod_prefix .. "tesla-gun-trigger",
    subgroup = "ammo-effects",
    hidden = true,
    icons = {
      {
        icon = "__space-exploration-graphics__/graphics/icons/tesla-gun.png",
        icon_size = 64,
        scale = 0.5,
      },
      {
        icon = "__core__/graphics/icons/unknown.png",
        icon_size = 64,
        scale = 0.5,
      },
    },
    animations = {
      {
        direction_count = 1,
        filename = "__space-exploration-graphics__/graphics/blank.png",
        frame_count = 1,
        height = 1,
        line_length = 1,
        width = 1
      }
    },
    flags = {
      "not-on-map", "placeable-off-grid"
    },
  },
  {
    type = "explosion",
    name = data_util.mod_prefix .. "tesla-gun-light",
    subgroup = "ammo-effects",
    hidden = true,
    icons = {
      {
        icon = "__space-exploration-graphics__/graphics/icons/tesla-gun.png",
        icon_size = 64,
        scale = 0.5,
      },
      {
        icon = "__core__/graphics/icons/unknown.png",
        icon_size = 64,
        scale = 0.5,
      },
    },
    animations = {
      {
        blend_mode = "additive",
        animation_speed = 1.5,
        direction_count = 1,
        filename = "__base__/graphics/entity/beam/tileable-beam-END.png",
        frame_count = 16,
        height = 93,
        line_length = 4,
        scale = 0.5,
        shift = { 0, 1 },
        width = 91
      }
    },
    flags = {
      "not-on-map", "placeable-off-grid"
    },
    light = {
      color = {
        b = 1,
        g = 1,
        r = 0.7
      },
      intensity = 0.1,
      size = 10
    },
    smoke = "smoke-fast",
    smoke_count = 1,
    smoke_slow_down_factor = 1,
  },
  {
    type = "beam",
    name = data_util.mod_prefix .. "tesla-gun-beam",
    subgroup = "ammo-effects",
    hidden = true,
    icons = {
      {
        icon = "__space-exploration-graphics__/graphics/icons/tesla-gun.png",
        icon_size = 64,
        scale = 0.5,
      },
      {
        icon = "__core__/graphics/icons/unknown.png",
        icon_size = 64,
        scale = 0.5,
      },
    },
    action = {
      action_delivery = {
        target_effects = {
          {
            type = "create-entity",
            entity_name = data_util.mod_prefix .. "tesla-gun-light",
          },
          {
            damage = {
              amount = Shared.tesla_beam_flat_damage,
              type = "electric"
            },
            type = "damage"
          },
        },
        type = "instant"
      },
      type = "direct"
    },
    graphics_set = {
      beam = {
        body = {
          {
            blend_mode = "additive",
            filename = "__base__/graphics/entity/beam/beam-body-1.png",
            frame_count = 16,
            height = 39,
            line_length = 16,
            width = 45
          },
          {
            blend_mode = "additive",
            filename = "__base__/graphics/entity/beam/beam-body-2.png",
            frame_count = 16,
            height = 39,
            line_length = 16,
            width = 45
          },
          {
            blend_mode = "additive",
            filename = "__base__/graphics/entity/beam/beam-body-3.png",
            frame_count = 16,
            height = 39,
            line_length = 16,
            width = 45
          },
          {
            blend_mode = "additive",
            filename = "__base__/graphics/entity/beam/beam-body-4.png",
            frame_count = 16,
            height = 39,
            line_length = 16,
            width = 45
          },
          {
            blend_mode = "additive",
            filename = "__base__/graphics/entity/beam/beam-body-5.png",
            frame_count = 16,
            height = 39,
            line_length = 16,
            width = 45
          },
          {
            blend_mode = "additive",
            filename = "__base__/graphics/entity/beam/beam-body-6.png",
            frame_count = 16,
            height = 39,
            line_length = 16,
            width = 45
          }
        },
        ending = {
          direction_count = 1,
          filename = "__base__/graphics/entity/beam/tileable-beam-END.png",
          frame_count = 16,
          height = 93,
          line_length = 4,
          scale = 0.5,
          shift = {
            -0.078125,
            -0.046875
          },
          width = 91
        },
        head = {
          animation_speed = 0.5,
          blend_mode = "additive",
          filename = "__base__/graphics/entity/beam/beam-head.png",
          frame_count = 16,
          height = 39,
          line_length = 16,
          width = 45
        },
        tail = {
          blend_mode = "additive",
          filename = "__base__/graphics/entity/beam/beam-tail.png",
          frame_count = 16,
          height = 39,
          line_length = 16,
          width = 45
        },
        start = {
          direction_count = 1,
          filename = "__base__/graphics/entity/beam/tileable-beam-START.png",
          frame_count = 16,
          height = 66,
          line_length = 4,
          scale = 0.5,
          shift = {
            0.53125,
            0
          },
          width = 94
        },
      }
    },
    damage_interval = 20,
    flags = {
      "not-on-map", "placeable-off-grid"
    },
    random_target_offset = true,
    target_offset_y = -0.3,
    width = 0.5,
    working_sound = {
      {
        filename = "__base__/sound/fight/electric-beam.ogg",
        volume = 0.7
      }
    }
  },
})
for _, tech in pairs(data.raw.technology) do
  if tech.effects then
    for _, effect in pairs(tech.effects) do
      if (effect.type == "ammo-damage" or effect.type == "gun-speed") and effect.ammo_category == "laser" then
        local level = data_util.string_to_simple_int(tech.name, true)
        if level >= 6 then
          local c = table.deepcopy(effect)
          c.ammo_category = "tesla"
          c.modifier = 0.5
          table.insert(tech.effects, c)
        end
      end
    end
  end
end
