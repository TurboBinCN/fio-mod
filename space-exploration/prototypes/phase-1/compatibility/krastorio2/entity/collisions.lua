local data_util = require("data_util")

-- Whitelist K2 entities for use in Space

local allow_in_space = {
  ["accumulator"] = {
    "kr-energy-storage",
    "kr-intergalactic-transceiver",
  },
  ["assembling-machine"] = {
    "kr-fuel-refinery",
    "kr-electrolysis-plant",
    "kr-matter-plant",
    "kr-matter-associator",
    "kr-fusion-reactor", -- Technically an assembling machine as it consumes energy
  },
  ["beacon"] = {
    "kr-singularity-beacon",
  },
  ["burner-generator"] = {
      "kr-antimatter-reactor",
  },
  ["container"] = {
    "kr-strongbox",
    "kr-warehouse",
  },
  ["electric-energy-interface"] = {
    "kr-tesla-coil",
  },
  ["furnace"] = {
    "kr-stabilizer-charging-station",
  },
  ["inserter"] = {
    "kr-superior-inserter",
    "kr-superior-long-inserter",
    "kr-superior-inserter",
    "kr-superior-long-inserter",
    "kr-superior-long-inserter",
  },
  ["lab"] = {
    "kr-advanced-lab",
    "kr-singularity-lab",
  },
  ["logistic-container"] = {
    "kr-active-provider-strongbox",
    "kr-buffer-strongbox",
    "kr-passive-provider-strongbox",
    "kr-requester-strongbox",
    "kr-storage-strongbox",

    "kr-active-provider-warehouse",
    "kr-buffer-warehouse",
    "kr-passive-provider-warehouse",
    "kr-requester-warehouse",
    "kr-storage-warehouse",
  },
  ["mining-drill"] = {
    "kr-quarry-drill",
  },
  ["radar"] = {
    "kr-sentinel",
  },
  ["solar-panel"] = {
    "kr-advanced-solar-panel",
  },
  ["storage-tank"] = {
    "kr-big-storage-tank",
    "kr-huge-storage-tank",
  },
}

for category_name, entities in pairs(allow_in_space) do
  for _, entity_name in pairs(entities) do
    local entity = data.raw[category_name][entity_name]
    if entity then
      --log("Entity Exists: " .. entity_name)
      entity.se_allow_in_space = true
    else
      --log("Entity Not Exisiting: " .. entity_name)
    end
  end
end

-- Blacklist K2 entities from use in Space
local krastorio_entities_to_add = {
  ["assembling-machine"] = {
    "kr-advanced-furnace",
    "kr-electrolysis-plant",
    "kr-filtration-plant",
    --"kr-air-filter", -- added later?
  },
  -- ["boiler"] = {
  --   "se-electric-boiler", -- added later, also should be done by SE
  -- },
  ["generator"] = {
    "kr-gas-power-station",
  },
  ["furnace"] = {
    "kr-crusher",
    "kr-air-purifier",
  },
  ["loader-1x1"] = {
    "kr-loader",
    "kr-fast-loader",
    "kr-express-loader",
    "kr-advanced-loader",
    "kr-superior-loader",
  },
  ["electric-energy-interface"] = {
    "kr-wind-turbine",
  },
}

-- Add appropriate collision masks for the Intergalactic Transciever entities
for _, prototype in pairs({
  data.raw["accumulator"]["kr-intergalactic-transceiver"],
  data.raw["electric-energy-interface"]["kr-activated-intergalactic-transceiver"]}) do
  if not prototype.collision_mask then
    prototype.collision_mask = {
      layers = {
        item = true,
        object = true,
        player = true,
        water_tile = true,
      },
    }
  end
  if not prototype.collision_mask.layers[spaceship_collision_layer] then
    prototype.collision_mask.layers[spaceship_collision_layer] = true
  end
end
