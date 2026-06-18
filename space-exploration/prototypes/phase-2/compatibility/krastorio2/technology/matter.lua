local data_util = require("data_util")

-- Update stone/sand-to-matter unlocking techs
data_util.recipe_require_tech("kr-stone-to-matter", "se-kr-basic-matter-processing")
data_util.recipe_require_tech("sand-to-matter", "se-kr-basic-matter-processing")

-- Update Matter Processing Techs requirements
data_util.tech_remove_prerequisites("kr-matter-processing", {"kr-imersium-processing","kr-energy-control-unit"})
data_util.tech_remove_ingredients("kr-matter-processing", {"kr-matter-tech-card"})
data_util.tech_add_prerequisites("kr-matter-processing",{"se-kr-basic-matter-processing"})
data_util.tech_add_ingredients("kr-matter-processing", {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-astronomic-science-pack-4","se-material-science-pack-4","se-energy-science-pack-4","se-deep-space-science-pack-2", "se-kr-matter-science-pack-2"})

-- Create a tech for unlocking advanced matter processing
local adv_matter_processing = table.deepcopy(data.raw.technology["kr-matter-processing"])
adv_matter_processing.name = "se-kr-advanced-matter-processing"
adv_matter_processing.effects = {}
adv_matter_processing.prerequisites = {
  "kr-matter-processing",
  "se-naquium-tessaract"
}
data:extend({adv_matter_processing})
data_util.recipe_require_tech("kr-matter-stabilizer", "se-kr-advanced-matter-processing")
data_util.recipe_require_tech("kr-charged-matter-stabilizer", "se-kr-advanced-matter-processing")

-- Alter Matter Processing tech icon
data.raw.technology["kr-matter-processing"].icon = "__Krastorio2Assets__/icons/entities/stabilizer-charging-station.png"
data.raw.technology["kr-matter-processing"].icon_size = 64

-- Update Matter Conversion and De-Conversion recipe techs to have A4, E4, M4, Matter 2 and DSS2 in the cost
local cards_to_add = {
  "automation-science-pack",
  "logistic-science-pack",
  "chemical-science-pack",
  "se-astronomic-science-pack-4",
  "se-energy-science-pack-4",
  "se-material-science-pack-4",
  "se-deep-space-science-pack-2",
  "se-kr-matter-science-pack-2"
}

data_util.tech_remove_ingredients("kr-matter-coal-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-matter-copper-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-matter-iron-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-matter-minerals-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-matter-oil-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-matter-rare-metals-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-matter-stone-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-matter-uranium-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("kr-matter-water-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("se-kr-matter-beryllium-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("se-kr-matter-cryonite-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("se-kr-matter-holmium-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("se-kr-matter-iridium-processing", {"kr-matter-tech-card"})
data_util.tech_remove_ingredients("se-kr-matter-vulcanite-processing", {"kr-matter-tech-card"})
data_util.tech_add_ingredients("kr-matter-coal-processing", cards_to_add)
data_util.tech_add_ingredients("kr-matter-copper-processing", cards_to_add)
data_util.tech_add_ingredients("kr-matter-iron-processing", cards_to_add)
data_util.tech_add_ingredients("kr-matter-minerals-processing", cards_to_add)
data_util.tech_add_ingredients("kr-matter-oil-processing", cards_to_add)
data_util.tech_add_ingredients("kr-matter-rare-metals-processing", cards_to_add)
data_util.tech_add_ingredients("kr-matter-stone-processing", cards_to_add)
data_util.tech_add_ingredients("kr-matter-uranium-processing", cards_to_add)
data_util.tech_add_ingredients("kr-matter-water-processing", cards_to_add)
data_util.tech_add_ingredients("se-kr-matter-beryllium-processing", cards_to_add)
data_util.tech_add_ingredients("se-kr-matter-cryonite-processing", cards_to_add)
data_util.tech_add_ingredients("se-kr-matter-holmium-processing", cards_to_add)
data_util.tech_add_ingredients("se-kr-matter-iridium-processing", cards_to_add)
data_util.tech_add_ingredients("se-kr-matter-vulcanite-processing", cards_to_add)

-- Split the Conversion/De-conversion techs into raw material tier and processed material tier
local function extend_tech(name)
  if data.raw.technology[name] then
    local new_tech = table.deepcopy(data.raw.technology[name])
    new_tech.name = "se-" .. new_tech.name .. "-adv"
    new_tech.effects = {}
    new_tech.prerequisites = {
      name,
      "se-kr-advanced-matter-processing"
    }
    data:extend({new_tech})
  end
end
extend_tech("kr-matter-copper-processing")
data_util.recipe_require_tech("kr-matter-to-copper-plate","se-kr-matter-copper-processing-adv")
extend_tech("kr-matter-iron-processing")
data_util.recipe_require_tech("kr-matter-to-iron-plate","se-kr-matter-iron-processing-adv")
data_util.recipe_require_tech("kr-matter-to-steel-plate","se-kr-matter-iron-processing-adv")
extend_tech("kr-matter-oil-processing")
data_util.recipe_require_tech("kr-matter-to-sulfur","se-kr-matter-oil-processing-adv")
data_util.recipe_require_tech("kr-matter-to-plastic-bar","se-kr-matter-oil-processing-adv")
extend_tech("kr-matter-rare-metals-processing")
data_util.recipe_require_tech("kr-matter-to-kr-rare-metals","se-kr-matter-rare-metals-processing-adv")
-- Stone
data_util.recipe_require_tech("kr-matter-to-stone","kr-matter-processing")
data_util.recipe_require_tech("kr-matter-to-kr-sand","kr-matter-processing")
-- Move techs only the non-Basic matter stabilizer to need the advanced matter processing tech
-- Iridium
data_util.tech_remove_prerequisites("se-kr-matter-iridium-processing",{"kr-matter-processing"})
data_util.tech_add_prerequisites("se-kr-matter-iridium-processing",{"se-kr-advanced-matter-processing"})
-- Beryllium
data_util.tech_remove_prerequisites("se-kr-matter-beryllium-processing",{"kr-matter-processing"})
data_util.tech_add_prerequisites("se-kr-matter-beryllium-processing",{"se-kr-advanced-matter-processing"})
-- Holmium
data_util.tech_remove_prerequisites("se-kr-matter-holmium-processing",{"kr-matter-processing"})
data_util.tech_add_prerequisites("se-kr-matter-holmium-processing",{"se-kr-advanced-matter-processing"})
-- Cryonite
data_util.tech_remove_prerequisites("se-kr-matter-cryonite-processing",{"kr-matter-processing"})
data_util.tech_add_prerequisites("se-kr-matter-cryonite-processing",{"se-kr-advanced-matter-processing"})
-- Vulcanite
data_util.tech_remove_prerequisites("se-kr-matter-vulcanite-processing",{"kr-matter-processing"})
data_util.tech_add_prerequisites("se-kr-matter-vulcanite-processing",{"se-kr-advanced-matter-processing"})
-- Imersite
data_util.tech_remove_prerequisites("kr-matter-minerals-processing", {"kr-matter-processing"})
data_util.tech_add_prerequisites("kr-matter-minerals-processing", {"se-kr-advanced-matter-processing"})
-- Quartz/Glass/Silicon
data_util.tech_remove_prerequisites("kr-matter-stone-processing", {"kr-matter-processing"})
data_util.tech_add_prerequisites("kr-matter-stone-processing", {"se-kr-advanced-matter-processing"})

-- SE Antimatter
-- Update SE Antimatter Production Tech to require Matter Fusion Tech
data_util.tech_add_prerequisites("se-antimatter-production",{"se-space-matter-fusion-2"})
data_util.tech_add_ingredients("se-antimatter-production",{"kr-matter-tech-card"})

-- Add Matter Tech Card to Techs decending from SE Antimatter Production Tech
data_util.tech_add_ingredients("se-antimatter-reactor",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-antimatter-engine",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-spaceship-victory",{"kr-matter-tech-card"})

-- Add Matter Tech Card to Naquium processing
data_util.tech_add_prerequisites("se-processing-naquium",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-processing-naquium",{"kr-matter-tech-card"})

-- Add Matter Tech Card to Nanomaterial requiring techs
data_util.tech_add_ingredients("se-adaptive-armour-5",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-big-heat-exchanger",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-big-turbine",{"kr-matter-tech-card"})

-- Add Matter Tech Card to Naquium Cube requiring techs
data_util.tech_add_ingredients("se-naquium-cube",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-space-solar-panel-3",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-space-accumulator-2",{"kr-matter-tech-card"})

-- Add Matter Tech Card to Naquium Tesseract requiring techs
data_util.tech_add_ingredients("se-naquium-tessaract",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-lifesupport-equipment-4",{"kr-matter-tech-card"})

-- Add Matter Tech Card to Naquium Processor requiring techs
data_util.tech_add_ingredients("se-naquium-processor",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-thruster-suit-4",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-nexus",{"kr-matter-tech-card"})

-- Add Matter Tech Card to Factory Spaceship
data_util.tech_add_ingredients("se-spaceship-integrity-7",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-factory-spaceship-1",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-factory-spaceship-2",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-factory-spaceship-3",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-factory-spaceship-4",{"kr-matter-tech-card"})
data_util.tech_add_ingredients("se-factory-spaceship-5",{"kr-matter-tech-card"})

-- Matter Cube Technology
data.raw.technology["kr-matter-cube"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_ingredients("kr-matter-cube",{"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"})
data_util.tech_add_ingredients("kr-matter-cube",{"automation-science-pack","logistic-science-pack","chemical-science-pack","se-energy-science-pack-4","se-material-science-pack-4","se-deep-space-science-pack-3","se-kr-matter-science-pack-2"})


-- Lock recipes behind techs.
data_util.recipe_require_tech("se-kr-matter-fusion-kr-rare-metal-ore", "se-space-matter-fusion")
data_util.recipe_require_tech("se-kr-matter-fusion-kr-imersite", "se-space-matter-fusion-2")

data_util.recipe_require_tech("se-kr-iron-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-copper-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-kr-rare-metal-ore-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-stone-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-uranium-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-beryllium-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-holmium-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-iridium-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-kr-imersite-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-vulcanite-to-particle-stream", "se-kr-advanced-stream-production")
data_util.recipe_require_tech("se-kr-cryonite-to-particle-stream", "se-kr-advanced-stream-production")

data_util.recipe_require_tech("kr-kr-imersite-to-matter","kr-matter-minerals-processing")
data_util.recipe_require_tech("se-kr-matter-to-kr-imersite","kr-matter-minerals-processing")

data_util.recipe_require_tech("kr-matter-plant", "se-kr-experimental-matter-processing")
data_util.recipe_require_tech("se-kr-experimental-matter-processing", "se-kr-experimental-matter-processing")

data_util.recipe_require_tech("se-kr-basic-stabilizer", "kr-matter-processing")
data_util.recipe_require_tech("se-kr-charge-basic-stabilizer", "kr-matter-processing")
