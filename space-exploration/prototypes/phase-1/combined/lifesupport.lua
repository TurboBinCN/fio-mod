local data_util = require("data_util")
local make_recipe = data_util.make_recipe

--[[
Lifesupport mechanics:
Consume lifesupport canisters for food & air

Equiment boosts the lifessuport drain efficiency, stacks additivly.
All thruster suits have some base level life support efficiency, 1 module is built-in.

Non-thruster suits can have modules added but only function on land and efficiency banafits are halved. Only useful on hostile planets.
A spacesuit proper spacesuit is required in space.
]]

local lifesupport_equipment_prototypes = {
  ["lifesupport-equipment-1"] = {
    tier = 1, grid_width = 2, grid_height = 2, power = "100kW",
    ingredients = {
      {type = "item", name="low-density-structure", amount = 10},
      {type = "item", name="pipe", amount = 10},
      {type = "item", name="coal", amount = 10},
      {type = "item", name="electric-engine-unit", amount = 10},
    },
    science_packs = {
      { "automation-science-pack", 1 },
      { "logistic-science-pack", 1 },
      { "chemical-science-pack", 1 },
      { data_util.mod_prefix .. "rocket-science-pack", 1 },
    },
    prerequisites = {
      "battery-equipment",
      data_util.mod_prefix .. "rocket-science-pack",
      data_util.mod_prefix .. "lifesupport-facility",
    }
  }, -- +100% efficiency

  ["lifesupport-equipment-2"] = {
    tier = 2, grid_width = 2, grid_height = 2, power = "100kW",
    ingredients = {
      {type = "item", name=data_util.mod_prefix .. "lifesupport-equipment-1", amount = 1},
      {type = "item", name=data_util.mod_prefix.."space-pipe", amount = 10},
      {type = "item", name=data_util.mod_prefix.."bioscrubber", amount = 10},
      {type = "fluid", name=data_util.mod_prefix.."bio-sludge", amount = 100},
    },
    science_packs = {
      { "automation-science-pack", 1 },
      { "logistic-science-pack", 1 },
      { "chemical-science-pack", 1 },
      { data_util.mod_prefix .. "rocket-science-pack", 1 },
      { data_util.mod_prefix .. "biological-science-pack-1", 1 },
    },
    prerequisites = {
      data_util.mod_prefix .. "lifesupport-equipment-1",
      data_util.mod_prefix.."bioscrubber"
    }
  }, -- +200% efficiency

  ["lifesupport-equipment-3"] = {
    tier = 3, grid_width = 2, grid_height = 2, power = "100kW",
    ingredients = {
      {type = "item", name=data_util.mod_prefix .. "lifesupport-equipment-2", amount = 1},
      {type = "item", name=data_util.mod_prefix.."vitalic-reagent", amount = 10},
      {type = "item", name=data_util.mod_prefix.."aeroframe-bulkhead", amount = 10},
    },
    science_packs = {
      { "automation-science-pack", 1 },
      { "logistic-science-pack", 1 },
      { "chemical-science-pack", 1 },
      { data_util.mod_prefix .. "rocket-science-pack", 1 },
      { data_util.mod_prefix .. "biological-science-pack-2", 1 },
      { data_util.mod_prefix .. "astronomic-science-pack-3", 1},
    },
    prerequisites = {
      data_util.mod_prefix .. "lifesupport-equipment-2",
      data_util.mod_prefix.."vitalic-reagent",
      data_util.mod_prefix.."aeroframe-bulkhead"
    }
  }, -- +400% efficiency

  ["lifesupport-equipment-4"] = {
    tier = 4, grid_width = 2, grid_height = 2, power = "100kW",
    ingredients = {
      {type = "item", name=data_util.mod_prefix .. "lifesupport-equipment-3", amount = 1},
      {type = "item", name=data_util.mod_prefix.."lattice-pressure-vessel", amount = 10},
      {type = "item", name=data_util.mod_prefix.."self-sealing-gel", amount = 10},
      {type = "item", name=data_util.mod_prefix.."naquium-tessaract", amount = 1},
    },
    science_packs = {
      { "automation-science-pack", 1 },
      { "logistic-science-pack", 1 },
      { "chemical-science-pack", 1 },
      { data_util.mod_prefix .. "rocket-science-pack", 1 },
      { data_util.mod_prefix .. "biological-science-pack-4", 1 },
      { data_util.mod_prefix .. "astronomic-science-pack-4", 1 },
      { data_util.mod_prefix .. "deep-space-science-pack-2", 1 },
    },
    prerequisites = {
      data_util.mod_prefix .. "lifesupport-equipment-3",
      data_util.mod_prefix.."lattice-pressure-vessel",
      data_util.mod_prefix.."self-sealing-gel",
      data_util.mod_prefix.."naquium-tessaract",
    }
  }, -- +800% efficiency
}

for name, lep in pairs(lifesupport_equipment_prototypes) do

  local lifesupport_equipment = {
    type = "inventory-bonus-equipment",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
  }
  lifesupport_equipment.name = data_util.mod_prefix .. name
  lifesupport_equipment.inventory_size_bonus = 0
  lifesupport_equipment.energy_source.buffer_capacity = tonumber(lep.power:sub(1, -3)) * 60 .. "kW" -- 1 second buffer
  lifesupport_equipment.energy_source.drain = lep.power
  lifesupport_equipment.sprite = { filename = "__space-exploration-graphics__/graphics/equipment/"..name..".png", width = 128, height = 128, priority = "medium" }
  --lifesupport_equipment.background_color = { r = 0.2, g = 0.3, b = 0.6, a = 1 }
  lifesupport_equipment.shape = { width = lep.grid_width, height = lep.grid_width, type = "full" }
  lifesupport_equipment.categories = {"armor-jetpack"} -- we only want to put lifesupports in armors, same as jetpacks. Let's jump on an existing restriction. Should be safe as long as jetpacks is a hard req.
  data_util.add_custom_tooltip_field(lifesupport_equipment, {
    name = {"description.constant-energy-consumption"},
    value = lep.power:sub(1, -3) .. " kW", -- adds a space
    order = 101, -- after inventory size bonus
  })

  local lifesupport_item = table.deepcopy(data.raw["item"]["exoskeleton-equipment"])
  lifesupport_item.name = data_util.mod_prefix ..name
  lifesupport_item.icon = "__space-exploration-graphics__/graphics/icons/"..name..".png"
  lifesupport_item.icon_size = 64
  lifesupport_item.place_as_equipment_result = data_util.mod_prefix ..name

  local lifesupport_recipe = table.deepcopy(data.raw["recipe"]["exoskeleton-equipment"])
  lifesupport_recipe.name = data_util.mod_prefix ..name
  lifesupport_recipe.enabled = false
  lifesupport_recipe.results = {{type="item", name = data_util.mod_prefix .. name, amount = 1}}
  lifesupport_recipe.ingredients = lep.ingredients
  lifesupport_recipe.energy_required = lep.tier * 10
  lifesupport_recipe.category = "lifesupport"

  local lifesupport_tech = {
    type = "technology",
    name = data_util.mod_prefix .. name,
    effects = { { type = "unlock-recipe", recipe = data_util.mod_prefix ..name } },
    icons = data_util.technology_icon_constant_equipment("__space-exploration-graphics__/graphics/technology/"..name..".png", 128),
    order = "e-g",
    prerequisites = lep.prerequisites,
    unit = {
     count = lep.tier * 100,
     time = 30,
     ingredients = lep.science_packs
    },
    localised_description = {"technology-description."..data_util.mod_prefix..name}
  }

  data:extend({
    lifesupport_equipment,
    lifesupport_item,
    lifesupport_recipe,
    lifesupport_tech
  })

end

data:extend({
  {
    type = "sprite",
    name = data_util.mod_prefix .. "lifesupport-button-sprite",
    filename = "__space-exploration-graphics__/graphics/icons/thruster-suit-black.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
  },
  {
    type = "sound",
    name = data_util.mod_prefix .. "canister-breath",
    variations = { filename = "__space-exploration__/sound/canister-breath.ogg", volume = 0.25 }
  }
})
