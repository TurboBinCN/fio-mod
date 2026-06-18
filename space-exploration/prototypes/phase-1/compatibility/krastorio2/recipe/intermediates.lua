local data_util = require("data_util")

-- This source is dedicated to integrating K2 and SEs materials into each others intermediaries

-- K2s Pollution Filter: Switch Imersite to something on Nauvis
data_util.replace_or_add_ingredient("kr-pollution-filter", "kr-imersite-powder", "kr-lithium-chloride", 1)

-- Small Electric Motor
local em_2 = table.deepcopy(data.raw.recipe["electric-motor"])
em_2.name = "se-kr-rare-metal-electric-motor"
em_2.localised_name = {"item-name.electric-motor"}
em_2.allow_as_intermediate = false
em_2.allow_productivity = true
em_2.hide_from_signal_gui = false
em_2.icons = data_util.add_icons_to_stack(
  nil, {
    {icon = data.raw.item["electric-motor"], properties = {scale = 1, offset = {0,0}, draw_background = true}},
    {icon = data.raw.item["kr-rare-metals"], properties = {scale = 0.5, offset = {-0.3,-0.3}}}
  }
)
data:extend({em_2})
data_util.replace_or_add_ingredient("se-kr-rare-metal-electric-motor","iron-gear-wheel","iron-gear-wheel",2)
data_util.replace_or_add_ingredient("se-kr-rare-metal-electric-motor","iron-plate","iron-plate",2)
data_util.replace_or_add_ingredient("se-kr-rare-metal-electric-motor","copper-cable","copper-cable",5)
data_util.replace_or_add_ingredient("se-kr-rare-metal-electric-motor",nil,"kr-rare-metals",2)
data_util.replace_or_add_result("se-kr-rare-metal-electric-motor","electric-motor","electric-motor",2)
data_util.tech_lock_recipes("electricity",{"se-kr-rare-metal-electric-motor"})

-- AI Core
table.insert(data.raw.recipe["kr-ai-core"].ingredients, {type = "fluid", name = "se-neural-gel-2", amount = 20})
data_util.replace_or_add_ingredient("kr-ai-core", "processing-unit", "se-quantum-processor", 2)
data_util.replace_or_add_ingredient("kr-ai-core", "kr-nitric-acid", "se-vitalic-reagent",4)
data_util.replace_or_add_ingredient("kr-ai-core", nil, "se-bioelectrics-data", 2)

-- Integrate the K2 AI Core into the Naquium Processor recipe
data_util.replace_or_add_ingredient("se-naquium-processor","se-quantum-processor","kr-ai-core",1)
data_util.replace_or_add_ingredient("se-naquium-processor-alt","se-quantum-processor","kr-ai-core",1)

-- Nitric Acid has the nitrogen for Anion resin
data_util.replace_or_add_ingredient("se-cryonite-ion-exchange-beads","sulfuric-acid","kr-nitric-acid",5,true)

---- Beryllium
-- Adjust Aeroframe Scaffold to use Imersium Plate
data_util.replace_or_add_ingredient("se-aeroframe-scaffold", nil, "kr-imersium-plate", 1)

-- Adjust Aeroframe Bulkhead to use Imersium Plate
data_util.replace_or_add_ingredient("se-aeroframe-bulkhead", "se-beryllium-plate", "se-beryllium-plate", 2)
data_util.replace_or_add_ingredient("se-aeroframe-bulkhead", nil, "kr-imersium-plate", 2)

---- Iridium
-- Adjust Heavy Composite item to require Rare Metals
data_util.replace_or_add_ingredient("se-heavy-composite",nil,"kr-rare-metals",4)

-- Adjust Heavy Assembly item to require Imersium Beams
data_util.replace_or_add_ingredient("se-heavy-assembly",nil,"kr-imersium-beam",2)

---- Holmium
-- Replace Holmium plate with Rare metals in Holmium solenoid recipe
data_util.replace_or_add_ingredient("se-holmium-solenoid", "se-holmium-plate", "kr-rare-metals", 2)

-- Adjust Quantum processor to use Imersite crystal
data_util.replace_or_add_ingredient("se-quantum-processor", nil, "kr-imersite-crystal", 2)

-- Adjust Dynamic Emitter item to require Imersite Crystals
data_util.replace_or_add_ingredient("se-dynamic-emitter",nil,"kr-imersite-crystal",2)

---- Vitamelange
-- Replace Sulfuric acid with Nitric acid in Vitalic acid recipe
data_util.replace_or_add_ingredient("se-vitalic-acid", "sulfuric-acid", "kr-nitric-acid", 2, true)

-- Adjust Vitalic reagent to use Lithium chloride
data_util.replace_or_add_ingredient("se-vitalic-reagent", nil, "kr-lithium-chloride", 10)

---- Streams
-- Replace Battery with Lithium-Sulfur Battery in the Magnetic Canister recipe
data_util.replace_or_add_ingredient("se-magnetic-canister","battery","kr-lithium-sulfur-battery",1)
data_util.replace_or_add_ingredient("se-magnetic-canister",nil,"kr-rare-metals",1)

-- Replace Copper in Ion Stream recipe with Rare Metals
data_util.replace_or_add_ingredient("se-ion-stream","copper-plate","kr-rare-metals",1)

-- Replace Stone in Plasma Stream recipe with Lithium
data_util.replace_or_add_ingredient("se-plasma-stream","stone","kr-lithium",2)

-- Replace Iron in Proton Stream recipe with Lithium
data_util.replace_or_add_ingredient("se-proton-stream","iron-plate","kr-lithium",2)

---- Lubricant alternate recipe
-- Lithium + Sulfuric Acid + Light Oil = Lubricant?

---- Biological Science
-- Adjust Nutrient gel to use fertilizer
data_util.replace_or_add_ingredient("se-nutrient-gel", nil, "kr-fertilizer", 5)
data_util.replace_or_add_ingredient("se-nutrient-gel-methane", nil, "kr-fertilizer", 5)

-- Adjust Genetic Data item to require Lithium Chloride
data_util.replace_or_add_ingredient("se-genetic-data",nil,"kr-lithium-chloride",5)

---- Energy Science
-- Adjust Magnetic data packs to require Rare Metals
data_util.replace_or_add_ingredient("se-magnetic-monopole-data",nil,"kr-rare-metals",1)
data_util.replace_or_add_ingredient("se-electromagnetic-field-data",nil,"kr-rare-metals",5)

---- Material Science
-- Replace Stone in Material Testing Pack with Rare Metals
data_util.replace_or_add_ingredient("se-material-testing-pack","stone","kr-rare-metals",1)

-- Adjust Material Testing Pack to require Lithium Chloride
data_util.replace_or_add_ingredient("se-material-testing-pack",nil,"kr-lithium-chloride",1)

-- Replace Copper in Experimental Alloys Data with Rare Metals
data_util.replace_or_add_ingredient("se-experimental-alloys-data","copper-plate","kr-rare-metals",1)

-- Fertilizer needs maybe 1 sand and some Mineral Water
data_util.replace_or_add_ingredient("kr-fertilizer",nil,"kr-sand",5)
data_util.replace_or_add_ingredient("kr-fertilizer",nil,"kr-mineral-water",50,true)

local enhanced_fert_recipe = table.deepcopy(data.raw.recipe["kr-fertilizer"])
enhanced_fert_recipe.name = "se-kr-fertilizer-with-nutrients"
enhanced_fert_recipe.main_product = "kr-fertilizer"
data:extend({enhanced_fert_recipe})

data_util.replace_or_add_ingredient("se-kr-fertilizer-with-nutrients","kr-mineral-water","kr-mineral-water",20,true)
data_util.replace_or_add_ingredient("se-kr-fertilizer-with-nutrients",nil,"se-nutrient-gel",10,true)
data_util.replace_or_add_result("se-kr-fertilizer-with-nutrients","kr-fertilizer","kr-fertilizer",20)
data_util.replace_or_add_result("se-kr-fertilizer-with-nutrients",nil,"se-contaminated-bio-sludge",2,true)
data_util.replace_or_add_result("se-kr-fertilizer-with-nutrients",nil,"se-contaminated-space-water",1,true)

-- Include Rare Metal in scrap recycling
if data.raw.recipe["se-scrap-hard-recycling"] then
  table.insert(data.raw.recipe["se-scrap-hard-recycling"].results,
    {type = "item", name = "kr-rare-metal-ore", amount_min = 1, amount_max = 1, probability = 0.05}
  )
end

-- Adjust Holmium cable Processing Unit recipe to require Rare Metals
data.raw.recipe["se-processing-unit-holmium"].ingredients = {
  {type="item", name="advanced-circuit", amount=3},
  {type="item", name="kr-rare-metals", amount=2},
  {type="item", name="se-holmium-cable", amount=8},
  {type="fluid", name="sulfuric-acid", amount=4}
}
data_util.replace_or_add_result("se-processing-unit-holmium","processing-unit","processing-unit", 2)

--Biosludge
data_util.replace_or_add_ingredient("se-bio-sludge-from-wood", "wood", "wood", 50)
data_util.replace_or_add_ingredient("se-bio-sludge-from-wood", "se-space-water", "se-space-water", 20, true)

-- Biosluge balance
local biomass_recipe = table.deepcopy(data.raw.recipe["se-bio-sludge-from-wood"])
biomass_recipe.name = "se-bio-sludge-from-biomass"
biomass_recipe.icons = {
  { icon = data.raw.fluid[data_util.mod_prefix .. "bio-sludge"].icon, scale = 1, icon_size = 64  },
  { icon = data.raw.item["kr-biomass"].icon, scale = 0.75/2, icon_size = 64  },
}
biomass_recipe.localised_name = {"recipe-name.se-bio-sludge-from-biomass"}
data:extend({biomass_recipe})
data_util.replace_or_add_ingredient("se-bio-sludge-from-biomass", "wood", "kr-biomass", 10)
data_util.tech_lock_recipes("se-space-biochemical-laboratory", {"se-bio-sludge-from-biomass"})

-- Integrate Silicon into the Data Card recipe
data_util.replace_or_add_ingredient("se-data-storage-substrate", nil, "kr-silicon", 2)

-- Create a recipe for Data Cards using Rare Metals
local adv_data_recipe = table.deepcopy(data.raw.recipe["se-data-storage-substrate"])
adv_data_recipe.name = "se-kr-rare-metal-substrate"
adv_data_recipe.show_amount_in_title = true
adv_data_recipe.energy_required = 10
adv_data_recipe.ingredients = {
  {type="item", name="kr-glass", amount=2},
  {type="item", name="iron-plate", amount=2},
  {type="item", name="kr-silicon", amount=2},
  {type="item", name="kr-rare-metals", amount=2}
}
adv_data_recipe.results = {
  {type = "item", name = "se-data-storage-substrate", amount = 2},
  {type = "item", name = "se-scrap", amount_min = 1, amount_max = 2, probability = 0.5 },
}
adv_data_recipe.main_product = "se-data-storage-substrate"
adv_data_recipe.icon = nil
adv_data_recipe.icons = data_util.add_icons_to_stack(
  nil, {
    {icon = data.raw.item["se-data-storage-substrate"], properties = {scale = 1, offset = {0,0}, draw_background = true}},
    {icon = data.raw.item["kr-rare-metals"], properties = {scale = 0.5, offset = {-0.3,-0.3}}}
  }
)
adv_data_recipe.allow_productivity = true
data:extend({adv_data_recipe})
