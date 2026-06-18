

-- Rebalance Portable RTGs stats compared with K2 balancing
-- Portable RTG
data.raw["generator-equipment"]["se-rtg-equipment"].power = "1MW"
table.insert(data.raw["generator-equipment"]["se-rtg-equipment"].categories, "armor")

-- Portable fusion
data.raw["generator-equipment"]["se-fusion-reactor-equipment"].power = "2MW"
table.insert(data.raw["generator-equipment"]["se-rtg-equipment"].categories, "armor")

-- Portable antimatter
data.raw["generator-equipment"]["se-antimatter-reactor-equipment"].power = "3MW"
table.insert(data.raw["generator-equipment"]["se-rtg-equipment"].categories, "armor")

-- First Aid Kit
data.raw.capsule["kr-first-aid-kit"].subgroup = "tool"
data.raw.capsule["kr-first-aid-kit"].order = "a"
data.raw.capsule["kr-first-aid-kit"].stack_size = 20
data.raw.capsule["kr-first-aid-kit"].capsule_action = {
  attack_parameters = {
    ammo_category = "capsule",
    ammo_type = {
      action = {
        action_delivery = {
          target_effects = {
            damage = {
              amount = -25,
              type = "poison"
            },
            type = "damage"
          },
          type = "instant"
        },
        type = "direct"
      },
      category = "capsule",
      target_type = "position"
    },
    cooldown = 10,
    range = 0,
    type = "projectile"
  },
  type = "use-on-self"
}

-- Allow Jackhammer to collect Space Platform Scaffolding and Plating
table.insert(data.raw["selection-tool"]["kr-jackhammer"].select.tile_filters,"se-space-platform-scaffold")
table.insert(data.raw["selection-tool"]["kr-jackhammer"].alt_select.tile_filters,"se-space-platform-scaffold")
table.insert(data.raw["selection-tool"]["kr-jackhammer"].select.tile_filters,"se-space-platform-plating")
table.insert(data.raw["selection-tool"]["kr-jackhammer"].alt_select.tile_filters,"se-space-platform-plating")
