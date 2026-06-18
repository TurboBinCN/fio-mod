local data_util = require("data_util")

-- This source is dedicated to integrating SE and K2's competing Matter and Antimater mechanics.
-- Progression philosophy is:
-- - SE Energy Science Pack 3
-- - SE Matter Fabricator
-- - SEK2 Matter Science Pack (Replaces K2 Matter Tech Card)
-- - SE Matter Fusion Tier 1 (Homeworld Resources)
-- - SE Energy Science Pack 4
-- - SE Matter Fusion Tier 2 (Offworld Resources)
-- - SE Deep Space Science Pack 1
-- - SE Antimatter Production / SE Matter Production (Making Particle Stream using raw materials) and Experimental Matter Processing (uses Matter Plant)
-- - SEK2 Matter Science Pack 2 (Unlocks Matter Assembler and Basic Matter Processing(Stone and Sand), and then Matter Processing (Homeworld resource ores to and from Matter))
-- - SE Deep Space Science Pack 2 (Unlocks Offworld Resources to and from Matter)
-- - SEK2 Advanced Matter Processing
-- - K2 Singularity Tech Card
-- - K2 Antimatter Reactor (Renamed to Singularity Reactor)

---- Matter
-- Break down ores into three tiers:
--  - Common: Iron, Copper, Rare Metals, Stone, Coal, Oil
--  - Rare: Holmium, Beryllium, Iridium, Uranium, Mineral Water
--  - Exotic: Vulcanite, Cryonite, Imersite
-- The Exotic tier materials never have efficient creation mechanisms, they are the resource cost for being
-- able to transition between the other materials.

-- SE Matter Costs
-- Requires 50 particle stream to make 10 common ore, costs 50 common ore to make 50 particle stream.
-- Requires 50 particle stream to make 5 rare ore, costs 50 rare ore to make 50 particle stream
-- Requires 50 particle stream to make 1 exotic ore, costs 100 exotic ore to make 50 particle stream.
-- Requires 50 particle stream to make 10 matter, this is not equivalence, this is so that the second tier of data cards for the Matter Science Pack can be made.
-- However this is a good guideline for the efficiencies of K2 matter conversion/deconversion

---- SE Matter Tier 1
-- Material Fabricator Tech adjustments
data_util.tech_remove_prerequisites("se-space-material-fabricator",{"se-energy-science-pack-4"})
data_util.tech_remove_ingredients("se-space-material-fabricator",{"se-energy-science-pack-1","se-material-science-pack-1"})
data_util.tech_add_prerequisites("se-space-material-fabricator",{"se-energy-science-pack-3"})
data_util.tech_add_ingredients("se-space-material-fabricator",{"se-energy-science-pack-3","se-material-science-pack-2"})

-- Add Matter Tech Card to Techs decending from Matter Fabricator Tech
data_util.tech_add_prerequisites("se-nanomaterial",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-nanomaterial",{"kr-matter-tech-card"})

data_util.tech_remove_ingredients("se-space-matter-fusion",{"se-energy-science-pack-4"})
data_util.tech_add_prerequisites("se-space-matter-fusion",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-space-matter-fusion",{"production-science-pack","utility-science-pack","kr-matter-tech-card","se-energy-science-pack-3"})


-- Make missing K2 Matter technologies
local make_tech = function(name, tech_image, item_name)
  data:extend({
    {
      type = "technology",
      name = data_util.mod_prefix .. "kr-matter-"..name.."-processing",
      mod = "space-exploration",
      icons = {
        {icon = "__Krastorio2Assets__/technologies/backgrounds/matter.png", icon_size = 256},
        {icon = "__space-exploration-graphics__/graphics/technology/"..tech_image..".png", icon_size = 128, scale = 0.5}
      },
      effects = {
        {type = "unlock-recipe", recipe = "se-kr-"..item_name .. "-to-matter"},
        {type = "unlock-recipe", recipe = "se-kr-matter-to-" .. item_name},
      },
      prerequisites = {"kr-matter-processing"},
      order = "g-e-e",
      unit =
      {
        count = 500,
        ingredients =
        {
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"kr-matter-tech-card", 1}
        },
        time = 60
      },
      localised_name = {"technology-name.k2-conversion", {"item-name."..item_name}}
    }
  })
end

make_tech("vulcanite", "vulcanite-processing", "se-vulcanite")
make_tech("cryonite", "cryonite-processing", "se-cryonite")
make_tech("beryllium", "beryllium-processing", "se-beryllium-ore")
make_tech("holmium", "holmium-processing", "se-holmium-ore")
make_tech("iridium", "iridium-processing", "se-iridium-ore")

-- Duplicate Matter Fusion tech, splitting offworld materials into a second tier
local matter_fusion_2_tech = table.deepcopy(data.raw.technology["se-space-matter-fusion"])
matter_fusion_2_tech.name = "se-space-matter-fusion-2"
matter_fusion_2_tech.effects = {}
matter_fusion_2_tech.prerequisites = {
  "se-space-matter-fusion",
  "se-energy-science-pack-4"
}
data:extend({matter_fusion_2_tech})
data_util.tech_remove_ingredients("se-space-matter-fusion-2", {"se-energy-science-pack-3"})
data_util.tech_add_ingredients("se-space-matter-fusion-2", {"se-energy-science-pack-4"})
data_util.recipe_require_tech("se-matter-fusion-beryllium", "se-space-matter-fusion-2")
data_util.recipe_require_tech("se-matter-fusion-holmium", "se-space-matter-fusion-2")
data_util.recipe_require_tech("se-matter-fusion-iridium", "se-space-matter-fusion-2")
data_util.recipe_require_tech("se-matter-fusion-vulcanite", "se-space-matter-fusion-2")
data_util.recipe_require_tech("se-matter-fusion-cryonite", "se-space-matter-fusion-2")

-- Create a tech to introduce more efficient Particle Stream recipes
local adv_stream_production = table.deepcopy(data.raw.technology["se-space-matter-fusion-2"])
adv_stream_production.name = "se-kr-advanced-stream-production"
adv_stream_production.effects = {}
adv_stream_production.prerequisites = {
  "se-space-matter-fusion-2",
  "se-deep-space-science-pack-1"
}
adv_stream_production.unit = {
  count = 2000,
  time = 60,
  ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"se-rocket-science-pack", 1},
    {"space-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"se-astronomic-science-pack-4", 1},
    {"se-energy-science-pack-4", 1},
    {"se-material-science-pack-4", 1},
    {"kr-matter-tech-card", 1},
    {"se-deep-space-science-pack-1", 1},
  }
}
data:extend({adv_stream_production})

-- Create a tech to serve as a stepping stone between SE Matter Fusion and K2 Matter Processing
data:extend({
  {
    type = "technology",
    name = "se-kr-experimental-matter-processing",
    effects = {}, -- Matter Plant done by function after this creation
    icon = "__Krastorio2Assets__/icons/entities/matter-plant.png",
    icon_size = 64,
    order = "e-g",
    prerequisites = {
      "se-naquium-cube",
      "se-space-matter-fusion-2",
    },
    unit = {
      count = 200,
      time = 120,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"se-rocket-science-pack", 1},
        {"space-science-pack", 1},
        {"se-astronomic-science-pack-4", 1},
        {"se-energy-science-pack-4", 1},
        {"se-material-science-pack-4", 1},
        {"kr-matter-tech-card", 1},
        {"se-deep-space-science-pack-1", 1},
      }
    },
    kr_check_science_packs_incompatibilities = false
  }
})
data_util.tech_add_prerequisites("se-kr-space-catalogue-matter-2", {"se-kr-experimental-matter-processing"})

-- Unlock the K2 Matter Plant with Experimental Matter Processing
data_util.recipe_require_tech("kr-matter-plant", "se-kr-experimental-matter-processing")

-- Create a tech to introduce basic K2 Matter Processing
local basic_matter_tech = table.deepcopy(data.raw.technology["kr-matter-processing"])
basic_matter_tech.name = "se-kr-basic-matter-processing"
basic_matter_tech.effects = {}
basic_matter_tech.icon = "__Krastorio2Assets__/icons/entities/matter-associator.png"
basic_matter_tech.icon_size = 64
basic_matter_tech.prerequisites = {
  "se-kr-matter-science-pack-2"
}
basic_matter_tech.unit = {
  count = 300,
  time = 120,
  ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"se-rocket-science-pack", 1},
    {"space-science-pack", 1},
    {"se-astronomic-science-pack-4", 1},
    {"se-energy-science-pack-4", 1},
    {"se-material-science-pack-4", 1},
    {"se-kr-matter-science-pack-2", 1},
    {"se-deep-space-science-pack-1", 1},
  }
}
data:extend({basic_matter_tech})
data_util.recipe_require_tech("kr-matter-associator", "se-kr-basic-matter-processing")
