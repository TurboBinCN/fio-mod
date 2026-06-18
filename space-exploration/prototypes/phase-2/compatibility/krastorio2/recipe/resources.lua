local data_util = require("data_util")

-- Crusher does Crushing, not as fine a result as the pulveriser?
if data.raw.recipe["sand"] then
  data.raw.recipe["sand"].category = "kr-crushing"
end
if data.raw.recipe["kr-sand"] then
  data.raw.recipe["kr-sand"].category = "pulverising"
end
-- This source is dedicated to maintaining compatability changes required for the K2 and SE resource processing steps.
-- E.G.
--  - Making sure K2 enrichment and SE molten metal casting are both available and the recipe amounts make sense as progressive levels of plate production efficiency
--  - Introducing changes to Iridium and Holomium to include the K2 Washing loop.

-- Make the Iridium and Holmium processing changes.
-- Replace input water with equal parts Hydrogen Chloride and Nitric Acid
data_util.replace_or_add_ingredient("se-iridium-powder", "water", "kr-hydrogen-chloride", 2, true)
data_util.replace_or_add_ingredient("se-iridium-powder", nil, "kr-nitric-acid", 2, true)

-- Add Dirty Water to Iridium Washing
data_util.replace_or_add_result("se-iridium-powder", "kr-sand", "dirty-water-ir", 4, true) --replace 10% sand

-- Add Iridium recovery from dirty water.
local dirty_iridium = table.deepcopy(data.raw.recipe["kr-filter-iron-ore-from-dirty-water"])
dirty_iridium.name = "se-kr-dirty-water-filtration-iridium"
dirty_iridium.icons = {
  {
    icon = data.raw.fluid["kr-dirty-water"].icon,
    icon_size = data.raw.fluid["kr-dirty-water"].icon_size,
  },
  {
    icon = data.raw.item["se-iridium-ore-crushed"].icon,
    icon_size = data.raw.item["se-iridium-ore-crushed"].icon_size,
    scale = 0.20 * ((data.raw.fluid["kr-dirty-water"].icon_size or 64) / (data.raw.item["se-iridium-ore-crushed"].icon_size or 64)),
    shift = { 0, 4 },
  },
}
dirty_iridium.energy_required = 4
dirty_iridium.ingredients = {
  {type = "fluid", name = "dirty-water-ir", amount = 100},
  {type = "item", name = "se-vulcanite-ion-exchange-beads", amount = 1},
}
dirty_iridium.results = {
  {type = "fluid", name = "water", amount = 80},
  {type = "item", name = "stone", probability = 0.30, amount = 1},
  {type = "item", name = "se-iridium-ore-crushed", probability = 0.40, amount_min = 2, amount_max = 3},
  {type = "item", name = "se-vulcanite-ion-exchange-beads", probability = 0.7, amount =1}
}
dirty_iridium.always_show_made_in = true
dirty_iridium.crafting_machine_tint = {
  primary = { r = 0.30, g = 0.30, b = 0.00, a = 0.4},
  secondary = { r = 0.64, g = 0.83, b = 0.93, a = 0.9},
}
dirty_iridium.subgroup = "iridium"
dirty_iridium.order = "a[iridium]-d[iridium-powder]-c[dirty-water-ir]"

data:extend({dirty_iridium})
data_util.recipe_require_tech("se-kr-dirty-water-filtration-iridium", "se-processing-iridium")

-- Replace water with Hydrogen Chloride
data_util.replace_or_add_ingredient("se-holmium-chloride","water","kr-hydrogen-chloride", 2, true)

-- Add Dirty Water to Holmium Washing
data_util.replace_or_add_result("se-holmium-chloride", "kr-sand", "dirty-water-ho", 3, true) --replace 10% sand

-- Add Holmium recovery from dirty water.
local dirty_holmium = table.deepcopy(data.raw.recipe["kr-filter-iron-ore-from-dirty-water"])
dirty_holmium.name = "se-kr-dirty-water-filtration-holmium"
dirty_holmium.icons = {
  {
    icon = data.raw.fluid["kr-dirty-water"].icon,
    icon_size = data.raw.fluid["kr-dirty-water"].icon_size,
  },
  {
    icon = data.raw.item["se-holmium-ore-crushed"].icon,
    icon_size = data.raw.item["se-holmium-ore-crushed"].icon_size,
    scale = 0.20 * ((data.raw.fluid["kr-dirty-water"].icon_size or 64) / (data.raw.item["se-holmium-ore-crushed"].icon_size or 64)),
    shift = { 0, 4 },
  },
}
dirty_holmium.energy_required = 4
dirty_holmium.ingredients = {
  {type = "fluid", name = "dirty-water-ho", amount = 100},
  {type = "item", name = "se-cryonite-ion-exchange-beads", amount = 1},
}
dirty_holmium.results = {
  {type = "fluid", name = "water", amount = 80},
  {type = "item", name = "stone", probability = 0.30, amount = 1},
  {type = "item", name = "se-holmium-ore-crushed", probability = 0.50, amount_min = 2, amount_max = 3},
  {type = "item", name = "se-cryonite-ion-exchange-beads", probability = 0.7, amount =1}
}
dirty_holmium.always_show_made_in = true
dirty_holmium.crafting_machine_tint = {
  primary = { r = 0.30, g = 0.00, b = 0.00, a = 0.4},
  secondary = { r = 0.64, g = 0.83, b = 0.93, a = 0.9},
}
dirty_holmium.subgroup = "holmium"
dirty_holmium.order = "a[holmium]-d[holmium-chloride]-c[dirty-water-ho]"

data:extend({dirty_holmium})
data_util.recipe_require_tech("se-kr-dirty-water-filtration-holmium", "se-processing-holmium")

---- Iron, Copper, Rare Metals are interchangable
-- Alter K2s existant filtration recipes to make their loops require water input.
data.raw.recipe["kr-filter-iron-ore-from-dirty-water"].ingredients = {
  { type = "fluid", name = "kr-dirty-water", amount = 100 },
}
data.raw.recipe["kr-filter-iron-ore-from-dirty-water"].results = {
  { type = "fluid", name = "water", amount = 90 },
  { type = "item", name = "kr-sand", probability = 0.20, amount_min = 2, amount_max = 3},
  { type = "item", name = "iron-ore", probability = 0.50, amount_min = 2, amount_max = 5},
}

data.raw.recipe["kr-filter-copper-ore-from-dirty-water"].ingredients = {
  { type = "fluid", name = "kr-dirty-water", amount = 100 },
}
data.raw.recipe["kr-filter-copper-ore-from-dirty-water"].results = {
  { type = "fluid", name = "water", amount = 90 },
  { type = "item", name = "kr-sand", probability = 0.20, amount_min = 2, amount_max = 3},
  { type = "item", name = "copper-ore", probability = 0.50, amount_min = 2, amount_max = 5},
}

data.raw.recipe["kr-filter-rare-metal-ore-from-dirty-water"].ingredients = {
  { type = "fluid", name = "kr-dirty-water", amount = 100 },
}
data.raw.recipe["kr-filter-rare-metal-ore-from-dirty-water"].results = {
  { type = "fluid", name = "water", amount = 90 },
  { type = "item", name = "kr-sand", probability = 0.10, amount_min = 0, amount_max = 1},
  { type = "item", name = "kr-rare-metal-ore", probability = 0.40, amount_min = 2, amount_max = 5},
}

---- Copper Plates ----

-- SE
-- 1st Tier: 1 Copper Ore = 1 Copper Plate, Copper Ore directly smelted to Copper Plates
-- 2nd Tier: 1 Copper Ore = 1.5 Copper Plate
--     24 Copper Ore processed with 10 Pyroflux to 900 Molten Copper
--     250 Molten Copper cast to 1 Copper Ingot
--     1 Copper Ingots processed to 10 Copper Plates

-- K2
-- 1st Tier: 1 Copper Ore = 0.5 Copper Plate, Copper Ore directly smelted to Copper Plates
-- 2nd Tier: 1 Copper Ore = 0.667 Copper Plate
--     9 Copper Ore processed with 3 Sulfuric Acid to 6 Enriched Copper Ore
--     5 Enriched Copper Ore to 5 Copper Plates

-- SE-K2
-- 1st Tier: 1 Copper Ore = 0.75 Copper Plate, Copper Ore directly smelted to Copper Plates
-- 2nd Tier: 1 Copper Ore = 1 Copper Plate
--     9 Copper Ore processed with 3 Sulfuric Acid to 9 Enriched Copper Ore
--     5 Enriched Copper Ore to 5 Copper Plates
-- 3rd Tier: 1 Copper Ore = 1.25 Copper Plate -- Less than SE efficiency due to additional productivity steps being possible
--     9 Copper Ore processed with 3 Sulfuric Acid to 9 Enriched Copper Ore
--     24 Enriched Copper Ore processed with 10 Pyroflux to 750 Molten Copper
--     250 Molten Copper cast to 1 Copper Ingot
--     1 Copper Ingot processed to 10 Copper Plates

-- Krastorio 2 overwrites these changes after this point and so they will be applied in space-exploration/prototypes/phase-3/compatibility/krastorio2/resource-processing
-- -- Copper Ore smelting recipe
-- data_util.replace_or_add_ingredient("copper-plate", "copper-ore", "copper-ore", 20)
-- data_util.replace_or_add_result("copper-plate", "copper-plate", "copper-plate", 15)

-- Copper Ore smelting recipe
data_util.set_craft_time("copper-plate", 3.2*15)
data_util.replace_or_add_ingredient("copper-plate", "copper-ore", "copper-ore", 20)
data_util.replace_or_add_result("copper-plate", "copper-plate", "copper-plate", 15)

-- Enriched Copper Ore recipe
data_util.replace_or_add_result("kr-enriched-copper", "kr-enriched-copper", "kr-enriched-copper", 9)

-- Molten Copper recipe
data.raw.recipe["se-molten-copper"].ingredients = {
  {type = "item", name = "kr-enriched-copper", amount = 24},
  {type = "fluid", name = "se-pyroflux", amount = 10},
}
data.raw.recipe["se-molten-copper"].results = {
  {type = "fluid", name = "se-molten-copper", amount = 750},
}

---- Iron Plates ----

-- SE
-- 1st Tier: 1 Iron Ore = 1 Iron Plate, Iron Ore directly smelted to Iron Plates
-- 2nd Tier: 1 Iron Ore = 1.5 Iron Plate
--     24 Iron Ore processed with 10 Pyroflux to 900 Molten Iron
--     250 Molten Iron cast to 1 Iron Ingot
--     1 Iron Ingots processed to 10 Iron Plates

-- K2
-- 1st Tier: 1 Iron Ore = 0.5 Iron Plate, Iron Ore directly smelted to Iron Plates
-- 2nd Tier: 1 Iron Ore = 0.667 Iron Plate
--     9 Iron Ore processed with 3 Sulfuric Acid to 6 Enriched Iron Ore
--     5 Enriched Iron Ore to 5 Iron Plates

-- SE-K2
-- 1st Tier: 1 Iron Ore = 0.75 Iron Plate, Iron Ore directly smelted to Iron Plates
-- 2nd Tier: 1 Iron Ore = 1 Iron Plate
--     9 Iron Ore processed with 3 Sulfuric Acid to 9 Enriched Iron Ore
--     5 Enriched Iron Ore to 5 Iron Plates
-- 3rd Tier: 1 Iron Ore = 1.25 Iron Plate -- Less than SE efficiency due to additional productivity steps being possible
--     9 Iron Ore processed with 3 Sulfuric Acid to 9 Enriched Iron Ore
--     24 Enriched Iron Ore processed with 10 Pyroflux to 750 Molten Iron
--     250 Molten Iron cast to 1 Iron Ingot
--     1 Iron Ingot processed to 10 Iron Plates

-- Iron Ore smelting recipe
data_util.set_craft_time("iron-plate", 3.2*15)
data_util.replace_or_add_ingredient("iron-plate", "iron-ore", "iron-ore", 20)
data_util.replace_or_add_result("iron-plate", "iron-plate", "iron-plate", 15)

-- Enriched Iron Ore recipe
data_util.replace_or_add_result("kr-enriched-iron", "kr-enriched-iron", "kr-enriched-iron", 9)

-- Molten Iron recipe
data.raw.recipe["se-molten-iron"].ingredients = {
  {type = "item", name = "kr-enriched-iron", amount = 24},
  {type = "fluid", name = "se-pyroflux", amount = 10},
}
data.raw.recipe["se-molten-iron"].results = {
  {type = "fluid", name = "se-molten-iron", amount = 750},
}

---- Steel Plates ----

-- SE
-- 1st Tier: 1 Iron Ore = 0.2 Steel Plate
--     1 Iron Ore smelted to 1 Iron Plate
--     5 Iron Plate smelted to 1 Steel Plate
-- 2nd Tier: 1 Iron Ore = 0.3 Steel Plate -- Possible unnecessary to consider given 3rd Tier is unlocked at the same time.
--     24 Iron Ore processed with 10 Pyroflux to 900 Molten Iron
--     250 Molten Iron cast to 1 Iron Ingot
--     1 Iron Ingot processed to 10 Iron Plates
--     5 Iron Plates smelted to 1 Steel Plate
-- 3rd Tier: 1 Iron Ore = 0.75 Steel Plate
--     24 Iron Ore processed with 10 Pyroflud to 900 Molten Iron
--     500 Molten Iron processed with 8 Coal into 1 Steel Ingot
--     1 Steel Ingot processed to 10 Steel Plate

-- K2
-- 1st Tier: 1 Iron Ore = 0.25 Steel Plate
--     10 Iron Ore Smelted to 5 Iron Plate
--     10 Iron Plate processed with 2 Coke to 5 Steel Plate
-- 2nd Tier: 1 Iron Ore = 0.33.. Steel Plate
--     9 Iron Ore Processed with 3 Sulfuric Acid to 6 Enriched Iron Ore
--     5 Enriched Iron Ore smelted to 5 Iron Plate
--     10 Iron Plate processed with 2 Coke to 5 Steel Plate

-- SE-K2
-- 1st Tier: 1 Iron Ore = 0.25 Steel Plate
--     20 Iron Ore smelted to 15 Iron Plates
--     15 Iron Plates processed with 3 Coke to 5 Steel Plates
-- 2nd Tier: 1 Iron Ore = 0.33.. Steel Plate?
--     9 Iron Ore processed with 3 Sulfuric Acid to 9 Enriched Iron Ore
--     5 Enriched Iron Ore smelted to 5 Iron Plate
--     15 Iron Plate processed with 3 Coke to 5 Steel Plate
-- 3rd Tier: 1 Iron Ore = 0.4166.. Steel Plate
--     9 Iron Ore processed with 3 Sulfuric Acid to 9 Enriched Iron Ore
--     24 Enriched Iron Ore processed with 10 Pyroflux to 750 Molten Iron
--     250 Molten Iron cast to 1 Iron Ingot
--     1 Iron Ingot processed to 10 Iron Plates
--     15 Iron Plates processed with 3 Coke to 5 Steel Plates
-- 4th Tier: 1 Iron Ore = 0.893.. Steel Plate -- Slightly better than SE Efficiency due to needing to be better than Ore -> Ingot -> Plate -> Steel
--     9 Iron Ore processed with 3 Sulfuric Acid to 9 Enriched Iron Ore
--     24 Enriched Iron Ore processed with 10 Pyroflux to 750 Molten Iron
--     700 Molten Iron processed with 6 Coke into 2 Steel Ingot
--     1 Steel Ingot processed into 10 Steel Plate

-- Steel Plate from Iron Plate
data_util.replace_or_add_ingredient("steel-plate","iron-plate","iron-plate",15)
data_util.replace_or_add_ingredient("steel-plate","kr-coke","kr-coke",3)

-- Steel Ingot to Steel Plate
-- Icon update due to K2 changing the Steel Plate icon drastically
data.raw.recipe["se-steel-ingot-to-plate"].icons = data_util.sub_icons(data.raw.item["steel-plate"].icon, data.raw.item[data_util.mod_prefix .. "steel-ingot"].icon)

-- Steel Ingot From Molten Iron
data_util.replace_or_add_ingredient("se-steel-ingot","coal","kr-coke",6)
data_util.replace_or_add_ingredient("se-steel-ingot","se-molten-iron","se-molten-iron",700,true)
data_util.replace_or_add_result("se-steel-ingot","se-steel-ingot","se-steel-ingot",2)

---- Rare Metals ----

-- K2
-- 1st Tier: 1 Raw Rare Metals = 0.5 Rare Metals, Raw Rare Metals directly smelted to Rare Metals
-- 2nd Tier: 1 Raw Rare Metals = 0.667 Rare Metals
--     9 Raw Rare Metals processed with 10 Hydrogen Chloride to 6 Enriched Rare Metals
--     5 Enriched Rare Metals to 5 Rare Metals

-- SE-K2
-- 1st Tier: 1 Raw Rare Metals = 0.5 Rare Metals, Raw Rare Metals directly smelted to Rare Metals
-- 2nd Tier: 1 Raw Rare Metals = 0.66.. Rare Metals
--     9 Raw Rare Metals processed with 10 Hydrogen Chloride to 6 Enriched Rare Metals
--     5 Enriched Rare Metals to 5 Rare Metals
-- 3rd Tier: 1 Raw Rare Metals = 1 Rare Metals
--     9 Raw Rare Metals processed with 10 Hydrogen Chloride to 6 Enriched Rare Metals
--     24 Enriched Rare Metals processed with 1 Vulcanite Block to 36 Rare Metals

-- Create a Rare Metal-Vulcanite smelting recipe
local rare_metals_vulcanite = table.deepcopy(data.raw.recipe["se-molten-copper"])
rare_metals_vulcanite.name = "se-kr-rare-metals-with-vulcanite"
rare_metals_vulcanite.ingredients = {
  {type = "item", name = "kr-enriched-rare-metals", amount = 24},
  {type = "item", name = "se-vulcanite-block", amount = 1}
}
rare_metals_vulcanite.icons = data_util.sub_icons(data.raw.item["kr-rare-metals"].icon,
                                                  data.raw.item[data_util.mod_prefix .. "vulcanite-block"].icon)
rare_metals_vulcanite.results = {{type = "item", name = "kr-rare-metals", amount = 36}}
rare_metals_vulcanite.group = "resources"
rare_metals_vulcanite.subgroup = "kr-rare-metal-ore"
rare_metals_vulcanite.order = "a[rare-metal]-c[rare-metals]-c[rare-metals]"
rare_metals_vulcanite.allow_productivity = true
rare_metals_vulcanite.show_amount_in_title = true
data:extend({
  rare_metals_vulcanite
})
table.insert(data.raw.technology["se-pyroflux-smelting"].effects, {type = "unlock-recipe", recipe = "se-kr-rare-metals-with-vulcanite"})

---- Imersite ----

-- K2
-- Raw Imersite -> Imersite Powder -> Imersite Crystal/Imersite Plate
-- 1 Raw Imersite Ore : 0.166.. Imersite Crystal
-- 1 Raw Imersite Ore : 0.33.. Imersite Plate

-- SE-K2
-- 6 Raw Imersite processed via the Pulveriser into 3 Crushed Imersite + 3 Sand (base K2 recipe, just renamed Imersite Powder)
-- 25 Crushed Imersite and 5 Sulfuric Acid (Heating) ->  50 Imersiumsulfide (Fluid)
-- 8 Imersiumsulfide + 15 Nitric Acid (Heating)-> 8 Fine Imersite Powder + 5 Nitrogen (Fine Imersite Powder replaces all current uses of Imersite Powder)

--  32 Fine Imersite Powder + 8 Rare Metals (Alloying) -> 4 Imersium Plate + 2 Sulfur
--  40 Imersiumsulfide + 8 Fine Imersite Powder + 6 Silicon (Crystalisation)->  6 Imersite Crystals + 3 Sulfur

-- 1 Raw Imersite Ore : 1 Fine Imersite Powder
-- 1 Raw Imersite Ore : 0.125 Imersite Crystal
-- 1 Raw Imersite Ore : 0.125 Imersite Plate
-- Vulc and Cryo are 1 Ore : 0.1 Block/Rod but as no guarenteed Imersite primary we are a little kinder on ratios?

-- Alter Imersite Powder localisation
data.raw.item["kr-imersite-powder"].localised_name = {"item-name.se-kr-imersite-powder"}



-- Adjust Crushed Imersite recipe
data_util.replace_or_add_ingredient("kr-imersite-powder", "kr-imersite", "kr-imersite", 6)

-- 25 Crushed Imersite + 5 Sulfuric Acid => 50 Imersium Sulfide
-- Productivity intentionally left disabled for this recipe
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-imersium-sulfide",
  category = "chemistry",
  subgroup = "kr-imersite",
  order = "a[kr-imersite]-d[imersium-sulfide]-a[imersium-sulfide]",
  energy_required = 15,
  ingredients = {
    { type = "item",  name = "kr-imersite-powder", amount = 25},
    { type = "fluid", name = "sulfuric-acid", amount = 5}
  },
  results = {
    { type = "fluid", name = "se-kr-imersium-sulfide", amount = 50}
  },
  main_product = "se-kr-imersium-sulfide",
  always_show_made_in = true,
  enabled = false
})
table.insert(data.raw.technology["kr-quarry-minerals-extraction"].effects, {type = "unlock-recipe", recipe = "se-kr-imersium-sulfide"})

-- 16 Imersiumsulfide + 30 Nitric Acid (Heating)-> 16 Fine Imersite Powder + 10 Nitrogen
-- Productivity intentionally left disabled for this recipe
data_util.make_recipe({
  type = "recipe",
  name = "se-kr-fine-imersite-powder",
  category = "smelting",
  subgroup = "kr-imersite",
  energy_required = 10,
  ingredients = {
    { type = "fluid", name = "se-kr-imersium-sulfide", amount = 16},
    { type = "fluid", name = "kr-nitric-acid", amount = 30}
  },
  results = {
    { type = "item", name = "se-kr-fine-imersite-powder", amount = 16},
    { type = "fluid", name = "kr-nitrogen", amount = 10}
  },
  main_product = "se-kr-fine-imersite-powder",
  always_show_made_in = true,
  enabled = false
})
table.insert(data.raw.technology["kr-quarry-minerals-extraction"].effects, {type = "unlock-recipe", recipe = "se-kr-fine-imersite-powder"})

-- Adjust Imersite Plate recipe
data_util.replace_or_add_ingredient("kr-imersium-plate", "kr-imersite-powder", "se-kr-fine-imersite-powder", 32)
data_util.replace_or_add_ingredient("kr-imersium-plate", "kr-rare-metals", "kr-rare-metals", 8)
data_util.replace_or_add_result("kr-imersium-plate", "kr-imersium-plate", "kr-imersium-plate", 4)
data_util.replace_or_add_result("kr-imersium-plate", nil, "sulfur", 2)
data_util.recipe_set_energy_required("kr-imersium-plate", 20)
data.raw.recipe["kr-imersium-plate"].main_product = "kr-imersium-plate"

-- Adjust Imersite Crystal recipe
data_util.replace_or_add_ingredient("kr-imersite-crystal", "sulfuric-acid", "se-kr-imersium-sulfide", 40, true)
data_util.replace_or_add_ingredient("kr-imersite-crystal", "kr-imersite-powder", "se-kr-fine-imersite-powder", 8)
data_util.replace_or_add_ingredient("kr-imersite-crystal", "kr-nitric-acid", "kr-silicon", 6)
data_util.replace_or_add_result("kr-imersite-crystal", "kr-imersite-crystal", "kr-imersite-crystal", 6)
data_util.replace_or_add_result("kr-imersite-crystal", nil, "sulfur", 3)
data.raw.recipe["kr-imersite-crystal"].main_product = "kr-imersite-crystal"

-- Replace Imersite Powder with Fine Imersite Powder in all other recipes
data_util.replace_or_add_ingredient("kr-easy-imersium-beam", "kr-imersite-powder", "se-kr-fine-imersite-powder", 6)
data_util.replace_or_add_ingredient("kr-easy-imersium-gear-wheel", "kr-imersite-powder", "se-kr-fine-imersite-powder", 3)
data_util.replace_or_add_ingredient("kr-advanced-fuel", "kr-imersite-powder", "se-kr-fine-imersite-powder", 6)

---- Stone ----

data.raw.recipe["se-glass-vulcanite"].results ={{type = "item", name = SEItemNames.get_glass_name(), amount = 24}}

-- Switch Coke recipes over to the Kiln recipe group
data.raw.recipe["kr-coke"].category = "kiln"

-- Make Silicon a kiln recipe
data.raw.recipe["kr-silicon"].category = "kiln"
-- Create a Silicon-Vulcanite smelting recipe
local silicon_vulcanite = table.deepcopy(data.raw.recipe["se-molten-copper"])
silicon_vulcanite.name = "se-kr-silicon-with-vulcanite"
silicon_vulcanite.localised_name = {"item-name.kr-silicon"}
silicon_vulcanite.ingredients = {
  {type = "item", name = "kr-quartz", amount = 18},
  {type = "item", name = "se-vulcanite-block", amount = 1}
}
silicon_vulcanite.icons = data_util.sub_icons(data.raw.item["kr-silicon"].icon,
                                              data.raw.item[data_util.mod_prefix .. "vulcanite-block"].icon)
silicon_vulcanite.results = {{type = "item", name = "kr-silicon", amount = 18}}
silicon_vulcanite.allow_productivity = true
silicon_vulcanite.category = "kiln"
silicon_vulcanite.subgroup = "stone"
silicon_vulcanite.order = "a[stone]-c[sand]-d[vulc-silicon]"
data:extend({
  silicon_vulcanite
})
table.insert(data.raw.technology["se-pyroflux-smelting"].effects, {type = "unlock-recipe", recipe = "se-kr-silicon-with-vulcanite"})

-- Blank observation frame
local ofb = data.raw.recipe[data_util.mod_prefix .. "observation-frame-blank"]
ofb.icons = data_util.sub_icons("__space-exploration-graphics__/graphics/icons/observation-frame-blank.png",
                                data.raw.item["steel-plate"].icon)
