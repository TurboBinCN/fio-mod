local data_util = require("data_util")
local item_sounds = require("__base__.prototypes.item_sounds")

if mods["space-age"] then

  data:extend{
    {
      type = "item",
      name = "satellite",
      icon = "__base__/graphics/icons/satellite.png",
      subgroup = "space-related",
      order = "d[rocket-parts]-e[satellite]",
      inventory_move_sound = item_sounds.mechanical_inventory_move,
      pick_sound = item_sounds.mechanical_inventory_pickup,
      drop_sound = item_sounds.mechanical_inventory_move,
      stack_size = 1,
      weight = 1 * tons,
      rocket_launch_products = {{type = "item", name = "space-science-pack", amount = 1000}},
      send_to_orbit_mode = "automated"
    },
    {
      type = "recipe",
      name = "satellite",
      energy_required = 5,
      enabled = false,
      categories = {"crafting"},
      ingredients =
      {
        {type = "item", name = "low-density-structure", amount = 100},
        {type = "item", name = "solar-panel", amount = 100},
        {type = "item", name = "accumulator", amount = 100},
        {type = "item", name = "radar", amount = 5},
        {type = "item", name = "processing-unit", amount = 100},
        {type = "item", name = "rocket-fuel", amount = 50}
      },
      results = {{type="item", name="satellite", amount=1}},
      requester_paste_multiplier = 1
    },
  }

  data.raw["technology"]["recycling"].unit =
  {
    count = 5000,
    ingredients =
    {
      { "automation-science-pack", 1 },
      { "logistic-science-pack", 1 },
      { "chemical-science-pack", 1 },
      { "production-science-pack", 1 }
    },
    time = 15
  }

  data:extend{
    {
      type = "autoplace-control",
      name = "tungsten-ore",
      order = "r-t-a",
      category = "resource",
      richness = true,
      hidden = true,
      enabled = false
    },
    {
      type = "autoplace-control",
      name = "sulfuric-acid-geyser",
      order = "r-t-b",
      category = "resource",
      richness = true,
      hidden = true,
      enabled = false
    },
    {
      type = "autoplace-control",
      name = "lithium-brine",
      order = "r-t-c",
      category = "resource",
      richness = true,
      hidden = true,
      enabled = false
    },
    {
      type = "autoplace-control",
      name = "fluorine-vent",
      order = "r-t-d",
      category = "resource",
      richness = true,
      hidden = true,
      enabled = false
    },
  }

  -- quez notes: the above was copy pasted and some guesswork just to make space-age load, there was not much thought put into it.

  -- quez notes: below is the tried and tested optional stuff, the rest is here: https://github.com/Quezler/glutenfree/tree/main/mods_2.0/162_sesa

  for _, resource in ipairs({
    {name = "calcite"},
    {name = "sulfuric-acid-geyser", product = "sulfuric-acid"},
    {name = "tungsten-ore"},
    {name = "scrap"},
    {name = "lithium-brine"},
    {name = "fluorine-vent", product = "fluorine"},
  }) do
    resource.product = resource.product or resource.name

    -- prevent zones from having space age ores as their primary resource or as ore
    data.raw["mod-data"]["se-universe-resource-word-rules"].data[resource.name] = {
      forbid_space = true,
      forbid_orbit = true,
      forbid_belt = true,
      forbid_field = true,
      forbid_planet = true,
      forbid_homeworld = true,
    }

    se_core_fragment_resources[resource.product] = {
      multiplier = 0, -- do not create a pulverizer recipe for this resource/fragment
      omni_multiplier = 0, -- do not output this resource when crushing omni fragments
    }
  end

  -- https://github.com/wube/Factorio/commit/7226d95f9a3a8656e37d739d7d5bb100dab7b432
  -- Fixed base game space science getting throughput limited due to limited hatches. (https://forums.factorio.com/118064)
  local cargo_station_parameters = data.raw["cargo-landing-pad"]["cargo-landing-pad"].cargo_station_parameters
  local hatch_definitions = {}
  local covered_hatches = {}
  cargo_station_parameters.giga_hatch_definitions[1].covered_hatches = covered_hatches
  for i = 1, 10 do
    for _, hatch_definition in ipairs(cargo_station_parameters.hatch_definitions) do
      table.insert(hatch_definitions, hatch_definition)
      table.insert(covered_hatches, #covered_hatches)
    end
  end
  cargo_station_parameters.hatch_definitions = hatch_definitions

  -- even with a delivery cannon recipe it is still very annoying
  data.raw["tool"]["agricultural-science-pack"].spoil_ticks = nil

  local function add_recipe_category(recipe, category)
    recipe.additional_categories = recipe.additional_categories or {}
    table.insert(recipe.additional_categories, category)
  end

  add_recipe_category(data.raw.recipe["rocket-control-unit"], "electromagnetics")

  -- in a really akward spot with vanilla only science packs and inability to be placed in space
  data.raw["lab"]["biolab"].hidden = true
  data.raw["item"]["biolab"].hidden = true
  data.raw["recipe"]["biolab"].hidden = true
  data.raw["technology"]["biolab"].hidden = true

  -- allow the big mining drill to mine iridium & naquium (area mining drill may not do tungsten)
  table.insert(data.raw["mining-drill"]["big-mining-drill"].resource_categories, "hard-resource")

  -- area mining drill uses 500kw so 300kw is a bit low for this drill
  data.raw["mining-drill"]["big-mining-drill"].energy_usage = "1000kW"

  data.raw["resource"]["scrap"].se_skip_resource_autoplace_override = true
  data.raw["reactor"]["heating-tower"].se_max_effectivity = 2.5
end
