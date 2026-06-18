local data_util = require("data_util")

local function find_furnace(name)
  if data.raw.furnace[name] then return data.raw.furnace[name] end
  if data.raw["assembling-machine"][name] then return data.raw["assembling-machine"][name] end
end

local stone_furnace = find_furnace("stone-furnace")
local steel_furnace = find_furnace("steel-furnace")
local electric_furnace = find_furnace("electric-furnace")

if stone_furnace then
  table.insert(stone_furnace.crafting_categories, "kiln")
end
if steel_furnace then
  table.insert(steel_furnace.crafting_categories, "kiln")
end
if electric_furnace then
  electric_furnace.energy_usage = "150kW" --"180kW"
  electric_furnace.energy_source.emissions_per_minute = { pollution = 0.5 }
  table.insert(electric_furnace.crafting_categories, "kiln")
end

if data.raw.projectile.grenade then
  local grenade = data.raw.projectile.grenade
  if grenade.action and
     grenade.action[1] and
     grenade.action[1].action_delivery and
     grenade.action[1].action_delivery.target_effects then
        grenade.action[1].action_delivery.target_effects[1] = {
          type = "create-entity",
          entity_name = "grenade-explosion",
          trigger_created_entity = true
        }
        if not data.raw.explosion["grenade-explosion"] then
          local grenade_explosion = table.deepcopy(data.raw.explosion["medium-explosion"])
          grenade_explosion.name = "grenade-explosion"
          data:extend({grenade_explosion})
        end
  end
end

if data.raw.container["crash-site-chest-2"] then
  data.raw.container["crash-site-chest-2"].minable = {type = "item", mining_time = 1, result = data_util.mod_prefix .. "heavy-composite"}
end

data.raw.beacon["beacon"].distribution_effectivity = 0.5

-- Fix Factoriopedia for all beacons to have correct profile
for _, beacon in pairs(data.raw.beacon) do
  beacon.profile = {1, 0}
end
