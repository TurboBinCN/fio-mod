local data_util = require("data_util")

-- NOTE: space- prefix categories should ONLY be available in space
-- otherwise add a non-prefixed version
local crafting_categories = {
  "arcosphere",
  "condenser-turbine",
  "big-turbine",
  "casting",
  "kiln",
  "delivery-cannon",
  "delivery-cannon-weapon",
  "fixed-recipe", -- generic group for anything with a fixed recipe, not chosen by player
  "fuel-refining",
  "core-fragment-processing",
  "lifesupport", -- same as "space-lifesupport" but can be on land
  "melting",
  "nexus",
  "pulverising",
  "crafting-or-electromagnetics",
  "hard-recycling", -- no conflict with "recycling"
  "hand-hard-recycling", -- no conflict with "recycling"
  "se-electric-boiling", -- needs to be SE specific otherwise energy values will be off
  "space-accelerator",
  "space-astrometrics",
  "space-biochemical",
  "space-collider",
  "space-crafting", -- same as basic assembling but only in space
  "space-decontamination",
  "space-electromagnetics",
  "space-elevator",
  "space-materialisation",
  "space-genetics",
  "space-gravimetrics",
  "space-growth",
  "space-hypercooling",
  "space-laser",
  "space-lifesupport", -- same as "lifesupport" but can only be in space
  "space-manufacturing",
  "space-mechanical",
  "space-observation-gammaray",
  "space-observation-xray",
  "space-observation-uv",
  "space-observation-visible",
  "space-observation-infrared",
  "space-observation-microwave",
  "space-observation-radio",
  "space-plasma",
  "space-radiation",
  "space-radiator",
  "space-hard-recycling", -- no conflict with "recycling"
  "space-research",
  "space-spectrometry",
  "space-supercomputing-1",
  "space-supercomputing-2",
  "space-supercomputing-3",
  "space-supercomputing-4",
  "space-thermodynamics",
  "spaceship-console",
  "spaceship-antimatter-engine",
  "spaceship-ion-engine",
  "spaceship-rocket-engine",
  "dummy",
  "no-category" -- has no recipes
}
for _, name in pairs(crafting_categories) do
  data:extend({
    { type = "recipe-category", name = name },
    {
      type = "item-subgroup",
      name = name,
      group = "intermediate-products", --group = "space",
      order = "z-b-"..name
    },
  })
end
-- table.insert(data.raw.character.character.crafting_categories, "lifesupport") -- too many fluid recipes
data:extend({
  {
    type = "recipe-category",
    name = "rocket-deploying"
  },
  {
    type = "fuel-category",
    name = "antimatter"
  },
  {
    type = "resource-category",
    name = "hard-resource",
  },
  {
    type = "resource-category",
    name = data_util.mod_prefix .. "core-mining",
  },
  {
    type = "ammo-category",
    name = "weapons-delivery-cannon",
    subgroup = "ammo-category",
    hidden = true,
    bonus_gui_order = "z",
  },
})
