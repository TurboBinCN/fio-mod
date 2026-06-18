local data_util = require("data_util")


data:extend({
  {
    type = "item",
    name = data_util.mod_prefix .. "linked-container",
    icon = "__space-exploration-graphics__/graphics/icons/linked-container.png",
    icon_size = 64,
    subgroup = data.raw["item-subgroup"]["container-2"] and "container-2" or "storage",
    order = "z-l",
    place_result = data_util.mod_prefix .. "linked-container",
    stack_size = 1,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "linked-container",
    category = "space-manufacturing",
    enabled = false,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "heavy-assembly", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "lattice-pressure-vessel", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "dynamic-emitter", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "self-sealing-gel", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "nanomaterial", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "naquium-processor", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "antimatter-canister", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 10},
    },
    energy_required = 600,
    results = {
      {type = "item", name = data_util.mod_prefix .. "linked-container", amount = 1},
    },
  },
  {
    type = "linked-container",
    name = data_util.mod_prefix .. "linked-container",
    gui_mode = "none",
    icon = "__space-exploration-graphics__/graphics/icons/linked-container.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = data_util.mod_prefix .. "linked-container"},
    max_health = 250,
    corpse = "medium-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
    se_allow_in_space = true,
    collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selection_box = {{-1, -1}, {1, 1}},
    damaged_trigger_effect = {
      entity_name = "spark-explosion",
      offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
      offsets = { { 0, 1 } },
      type = "create-entity"
    },
    inventory_size = 10,
    impact_category = "metal",
    picture =
    {
      layers =
      {
        {
          filename = "__space-exploration-graphics-5__/graphics/entity/linked-container/linked-container.png",
          width = 132,
          height = 136,
          shift = {0, 0/32},
          scale = 0.5
        },
        {
          draw_as_shadow = true,
          filename = "__space-exploration-graphics-5__/graphics/entity/linked-container/linked-container-shadow.png",
          width = 132,
          height = 88,
          shift = {13/32, 9/32},
          scale = 0.5
        },
      }
    },
    circuit_connector = table.deepcopy(data.raw.container["wooden-chest"].circuit_connector),
    circuit_wire_max_distance = 9,
  },
  {
    type = "technology",
    name = data_util.mod_prefix .. "linked-container",
    effects = {{ type = "unlock-recipe", recipe = data_util.mod_prefix .. "linked-container"}},
    icon = "__space-exploration-graphics__/graphics/technology/linked-container.png",
    icon_size = 128,
    order = "e-g",
    prerequisites = {
      data_util.mod_prefix .. "teleportation",
      data_util.mod_prefix .. "lattice-pressure-vessel",
      data_util.mod_prefix .. "self-sealing-gel",
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
