local data_util = require("data_util")
local tech_effects = {}
if mods["aai-containers"] then
  local base_models = {
    "passive-provider-chest",
    "aai-strongbox-passive-provider",
    "aai-storehouse-passive-provider",
    "aai-warehouse-passive-provider"
  }
  local inventory_sizes = {1, 4, 9, 25}
  local arcosphere_cost = {2, 4, 7, 10}
  local base_containers = {"steel-chest", "aai-strongbox", "aai-storehouse", "aai-warehouse"}
  for i, base_model in pairs(base_models) do
    local item = table.deepcopy(data.raw.item[base_model])
    local entity = table.deepcopy(data.raw["logistic-container"][base_model])

    local name = data_util.replace(item.name, "passive-provider", "linked")
    name = data_util.replace(name, "logistic-chest", "chest")

    item.name = name
    item.place_result = name
    item.icons[2].tint = {1,1,1}
    item.order = "z" ..item.order

    local recipe = {
      type = "recipe",
      name = name,
      ingredients = {
        { type = "item", name = base_containers[i], amount = 1 },
        { type = "item", name = data_util.mod_prefix .. "naquium-processor", amount = inventory_sizes[i]},
        { type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = arcosphere_cost[i]},
      },
      results = {
        {type = "item", name = name, amount = 1},
      },
      energy_required = 60 * i,
      category = "space-manufacturing",
      enabled = false,
      always_show_made_in = true,
    }
    table.insert(tech_effects, { type = "unlock-recipe", recipe = name})

    entity.type = "linked-container"
    entity.name = name
    entity.inventory_size = inventory_sizes[i]
    entity.minable.result = name
    entity.type = "linked-container"
    entity.circuit_connector = nil
    entity.circuit_wire_max_distance = nil
    entity.gui_mode = "none"
    entity.picture = entity.animation
    entity.animation = nil
    entity.picture.layers[3].tint = {1,1,1}
    data:extend({item, recipe, entity})
  end
end
data:extend({
  {
    type = "technology",
    name = data_util.mod_prefix .. "linked-containers",
    effects = tech_effects,
    icons = mods["aai-containers"] and {
      { icon = "__aai-containers__/graphics/technology/container-6-base.png", icon_size = 128 },
      { icon = "__aai-containers__/graphics/technology/container-6-mask.png", icon_size = 128 }
    } or nil,
    icon = mods["aai-containers"] and nil or "__space-exploration-graphics__/graphics/technology/teleportation.png",
    icon_size = 128,
    order = "e-g",
    prerequisites = {
      data_util.mod_prefix .. "teleportation",
    },
    unit = {
     count = 5000,
     time = 60,
     ingredients = {
       { "logistic-science-pack", 1 },
       { "utility-science-pack", 1 },
       { "production-science-pack", 1 },
       { data_util.mod_prefix .. "rocket-science-pack", 1 },
       { data_util.mod_prefix .."astronomic-science-pack-4", 1 },
       { data_util.mod_prefix .."energy-science-pack-4", 1 },
       { data_util.mod_prefix .."deep-space-science-pack-4", 1 },
     }
    },
    enabled = true
  },
})
if not mods["aai-containers"] then
  data.raw.technology[data_util.mod_prefix .. "linked-containers"].localised_description = {"technology-description."..data_util.mod_prefix .. "linked-containers-disabled"}
end
