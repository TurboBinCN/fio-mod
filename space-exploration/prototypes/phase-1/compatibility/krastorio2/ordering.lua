-- Logistics Tab
-- Reorder the K2 Warehouse subgroups.
data.raw["item-subgroup"]["kr-strongbox"].order = "a3[container-3]"
data.raw["item-subgroup"]["kr-warehouse"].order = "a6[container-6-b]"

-- Reorder K2 Warehouse items
if settings.startup["kr-containers"].value then
  -- Harmonize AAI Containers & Warehouses and Krastorio 2 versions
  -- Correct Medium Container and Warehouse item-subgroups
  -- Correct item ordering within their groups.
  data.raw.item["kr-strongbox"].order = "b[storage]-3-a[kr-medium-container]"
  data.raw.item["kr-passive-provider-strongbox"].order = "b[storage]-3-b[kr-passive-provider-container]"
  data.raw.item["kr-active-provider-strongbox"].order = "b[storage]-3-c[kr-active-provider-container]"
  data.raw.item["kr-storage-strongbox"].order = "b[storage]-3-d[kr-storage-container]"
  data.raw.item["kr-buffer-strongbox"].order = "b[storage]-3-e[kr-buffer-container]"
  data.raw.item["kr-requester-strongbox"].order = "b[storage]-3-f[kr-requester-container]"
  --
  data.raw.item["kr-warehouse"].order = "b[storage]-6-a[kr-big-container]"
  data.raw.item["kr-passive-provider-warehouse"].order = "b[storage]-6-b[kr-big-passive-provider-container]"
  data.raw.item["kr-active-provider-warehouse"].order = "b[storage]-6-c[kr-big-active-provider-container]"
  data.raw.item["kr-storage-warehouse"].order = "b[storage]-6-d[kr-big-storage-container]"
  data.raw.item["kr-buffer-warehouse"].order = "b[storage]-6-e[kr-big-buffer-container]"
  data.raw.item["kr-requester-warehouse"].order = "b[storage]-6-f[kr-big-requester-container]"
end

-- Re-order K2 belts
data.raw.item["kr-advanced-splitter"].subgroup = "splitter"
data.raw.item["kr-advanced-transport-belt"].subgroup = "transport-belt"
data.raw.item["kr-advanced-underground-belt"].subgroup = "underground-belt"

data.raw.item["kr-superior-splitter"].subgroup = "splitter"
data.raw.item["kr-superior-transport-belt"].subgroup = "transport-belt"
data.raw.item["kr-superior-underground-belt"].subgroup = "underground-belt"

-- Pipes ordering
data.raw.item["kr-steel-pipe"].subgroup = "pipe"
data.raw.item["kr-steel-pipe"].order = "a[pipe]-c[steel-pipe]"
data.raw.item["kr-steel-pipe-to-ground"].subgroup = "pipe"
data.raw.item["kr-steel-pipe-to-ground"].order = "a[pipe]-d[steel-pipe]"
data.raw.item["kr-steel-pump"].subgroup = "pipe"
data.raw.item["kr-steel-pump"].order = "b[pipe]-d[steel-pump]"
data.raw.item["kr-big-storage-tank"].subgroup = "pipe"
data.raw.item["kr-big-storage-tank"].order = "b[fluid]-b[big-storage-tank]"
data.raw.item["kr-huge-storage-tank"].subgroup = "pipe"
data.raw.item["kr-huge-storage-tank"].order = "b[fluid]-c[huge-storage-tank]"

-- Nuclear Locomotive
data.raw["item-with-entity-data"]["kr-nuclear-locomotive"].subgroup = "rail"
data.raw["item-with-entity-data"]["kr-nuclear-locomotive"].order = "c[rolling-stock]-b[nuclear-locomotive]"
data.raw["item-with-entity-data"]["cargo-wagon"].order = "c[rolling-stock]-c[cargo-wagon]"
data.raw["item-with-entity-data"]["fluid-wagon"].order = "c[rolling-stock]-d[fluid-wagon]"
data.raw["item-with-entity-data"]["artillery-wagon"].order = "c[rolling-stock]-e[artillery-wagon]"

-- Production Tab
-- Solar Panels
data.raw.item["kr-advanced-solar-panel"].subgroup = "solar"
data.raw.item["se-space-solar-panel"].order = "d[solar-panel]-c[space-solar-panel]"
data.raw.item["se-space-solar-panel-2"].order = "d[solar-panel]-d[space-solar-panel-2]"
data.raw.item["se-space-solar-panel-3"].order = "d[solar-panel]-e[space-solar-panel-3]"
data.raw.item["kr-energy-storage"].subgroup = "solar"

-- Mining Drills
data.raw.item["area-mining-drill"].order = "a[items]-d[area-mining-drill]"
data.raw.item["kr-electric-mining-drill-mk3"].order = "a[items]-e[electric-mining-drill-mk3]"

-- Mechanical Facilities
data.raw.item["kr-crusher"].subgroup = "mechanical"
data.raw.item["kr-crusher"].order = "z-c-a[crusher]"
data.raw.item["se-pulveriser"].order = "z-c-b[pulveriser]"

-- Assemblers
data.raw.item["kr-advanced-assembling-machine"].subgroup = "assembling"

-- Fuel Processors
data.raw.item["fuel-processor"].order = "a[fuel-processor]-a[fuel-processor]"
data.raw.item["kr-fuel-refinery"].subgroup = "fuel-processors"
data.raw.item["kr-fuel-refinery"].order = "a[fuel-processor]-b[kr-fuel-processor]"
data.raw.item["se-fuel-refinery"].subgroup = "fuel-processors"
data.raw.item["se-fuel-refinery"].order = "a[fuel-processor]-c[se-fuel-processor]"

-- Chemistry Facilities
data.raw.item["kr-electrolysis-plant"].subgroup = "chemistry"
data.raw.item["kr-advanced-chemical-plant"].subgroup = "chemistry"
data.raw.item["kr-flare-stack"].subgroup = "chemistry"
data.raw.item["kr-filtration-plant"].subgroup = "chemistry"

-- Plasma / Matter Facilities
data.raw.item["kr-matter-plant"].subgroup = "plasma"
data.raw.item["kr-matter-associator"].subgroup = "plasma"
data.raw.item["kr-stabilizer-charging-station"].subgroup = "plasma"

-- Computation Facilities
data.raw.item["kr-research-server"].subgroup = "computation"
data.raw.item["kr-quantum-computer"].subgroup = "computation"

-- Labs
data.raw.item["burner-lab"].order = "g[lab]-a[burner-lab]"
data.raw.item["lab"].order = "g[lab]-b[lab]"
data.raw.item["kr-advanced-lab"].subgroup = "lab"
data.raw.item["kr-advanced-lab"].order = "g[lab]-c[kr-advanced-lab]"
data.raw.item["se-space-science-lab"].order = "g[lab]-d[se-space-science-lab]"
data.raw.item["kr-singularity-lab"].subgroup = "lab"
data.raw.item["kr-singularity-lab"].order = "g[lab]-e[kr-singularity-lab]"

-- Resources Tab
-- Water
data.raw.recipe["kr-water-from-atmosphere"].subgroup = "water"
data.raw.recipe["kr-water-from-atmosphere"].order = "a[water]-a[water]-d[water-from-atmosphere]"
data.raw.recipe["kr-water-from-atmosphere"].category = "atmosphere-condensation-water"
data.raw.recipe["kr-water-electrolysis"].subgroup = "water"
data.raw.recipe["kr-water-separation"].subgroup = "water"
data.raw.recipe["kr-water"].subgroup = "water"
data.raw.fluid["kr-heavy-water"].subgroup = "water"

-- Condensation
data.raw.fluid["kr-oxygen"].subgroup = "kr-atmosphere-condensation"
data.raw.fluid["kr-oxygen"].order = "a[condensing]-a[oxygen]"
data.raw.recipe["kr-oxygen"].subgroup = "kr-atmosphere-condensation"
data.raw.recipe["kr-oxygen"].order = "a[condensing]-a[oxygen]"
data.raw.fluid["kr-nitrogen"].subgroup = "kr-atmosphere-condensation"
data.raw.fluid["kr-nitrogen"].order = "a[condensing]-b[nitrogen]"
data.raw.recipe["kr-nitrogen"].subgroup = "kr-atmosphere-condensation"
data.raw.recipe["kr-nitrogen"].order = "a[condensing]-b[nitrogen]"

-- Chemical subgroup (wood, coal, coke, sulfur)
data.raw.recipe["kr-wood-with-fertilizer"].subgroup = "chemical"
data.raw.recipe["kr-wood-with-fertilizer"].order = "a[chemical]-b[wood]-c[wood-with-fertilizer]"
data.raw.fluid["kr-biomethanol"].subgroup = "chemical"
data.raw.fluid["kr-biomethanol"].order = "a[chemical]-b[wood]-d[biomethanol]"
data.raw.item["kr-coke"].subgroup = "chemical"
data.raw.item["kr-coke"].order = "a[chemical]-b[wood]-e[coke]"
data.raw.item["kr-biomass"].subgroup = "chemical"
data.raw.item["kr-biomass"].order = "a[chemical]-g[biomass]-a[biomass]"
data.raw.item["kr-fertilizer"].subgroup = "chemical"
data.raw.item["kr-fertilizer"].order = "a[chemical]-g[biomass]-b[fertilizer]"
data.raw.recipe["se-kr-fertilizer-with-nutrients"].subgroup = "chemical"
data.raw.recipe["se-kr-fertilizer-with-nutrients"].order = "a[chemical]-g[biomass]-c[fertilizer-with-nutrients]"
data.raw.fluid["kr-chlorine"].subgroup = "chemical"
data.raw.fluid["kr-chlorine"].order = "a[chemical]-h[chlorine]-a[chlorine]"
data.raw.fluid["kr-hydrogen-chloride"].subgroup = "chemical"
data.raw.fluid["kr-hydrogen-chloride"].order = "a[chemical]-h[chlorine]-b[hydrogen-chloride]"
data.raw.fluid["kr-ammonia"].subgroup = "chemical"
data.raw.fluid["kr-ammonia"].order = "a[chemical]-i[ammonia]-a[ammonia]"
data.raw.fluid["kr-nitric-acid"].subgroup = "chemical"
data.raw.fluid["kr-nitric-acid"].order = "a[chemical]-i[ammonia]-b[nitric-acid]"

-- Oil
data.raw.recipe["kr-coke-liquefaction"].subgroup = "oil"
data.raw.recipe["kr-coke-liquefaction"].order = "a[oil]-d[light-oil]-c[coke-liquefaction]"
data.raw.recipe["light-oil-cracking"].order = "a[oil]-d[light-oil]-d[light-cracking]"
data.raw.recipe["kr-coal-filtration"].subgroup = "oil"
data.raw.recipe["kr-coal-filtration"].order = "a[oil]-e[heavy-oil]-d[coal-filtration]"
data.raw.fluid["kr-hydrogen"].subgroup = "oil"
data.raw.fluid["kr-hydrogen"].order = "a[oil]-g[methane]-c[hydrogen]"

-- Fuels
data.raw.item["kr-fuel"].subgroup = "fuel"
data.raw.item["kr-biofuel"].subgroup = "fuel"
data.raw.item["kr-advanced-fuel"].subgroup = "fuel"
data.raw.recipe["kr-fuel-from-light-oil"].subgroup = "fuel"
data.raw.recipe["kr-fuel-from-solid-fuel"].subgroup = "fuel"

-- Stone
data.raw.fluid["kr-dirty-water"].subgroup = "stone"
data.raw.item["kr-quartz"].subgroup = "stone"
data.raw.item["kr-quartz"].order = "a[stone]-c[sand]-b[quartz]"
data.raw.item["kr-silicon"].subgroup = "stone"
data.raw.item["kr-silicon"].order = "a[stone]-c[sand]-c[silicon]"

-- Iron
data.raw.item["kr-enriched-iron"].subgroup = "iron"
data.raw.item["kr-enriched-iron"].order = "a[iron]-b[iron-ore]-b[enriched-iron-ore]"
data.raw.recipe["kr-enriched-iron"].subgroup = "iron"
data.raw.recipe["kr-enriched-iron"].order = "a[iron]-b[iron-ore]-b[enriched-iron-ore]"
data.raw.recipe["kr-enriched-iron"].main_product = "kr-enriched-iron"
data.raw.recipe["kr-iron-plate-from-enriched-iron"].order = "a[iron]-e[iron-plate]-b[iron-plate]"
data.raw.recipe["kr-filter-iron-ore-from-dirty-water"].subgroup = "iron"
data.raw.recipe["kr-filter-iron-ore-from-dirty-water"].order = "a[iron]-b[iron-ore]-c[dirty-water-iron]"

-- Copper
data.raw.item["kr-enriched-copper"].subgroup = "copper"
data.raw.item["kr-enriched-copper"].order  = "a[copper]-b[copper-ore]-b[enriched-copper-ore]"
data.raw.recipe["kr-enriched-copper"].subgroup = "copper"
data.raw.recipe["kr-enriched-copper"].order = "a[copper]-b[copper-ore]-b[enriched-copper-ore]"
data.raw.recipe["kr-enriched-copper"].main_product = "kr-enriched-copper"
data.raw.recipe["kr-copper-plate-from-enriched-copper"].order = "a[copper]-e[copper-plate]-b[copper-plate]"
data.raw.recipe["kr-filter-copper-ore-from-dirty-water"].subgroup = "copper"
data.raw.recipe["kr-filter-copper-ore-from-dirty-water"].order = "a[copper]-b[copper-ore]-c[dirty-water-copper]"

-- Rare Metals
data.raw.item["kr-rare-metal-ore"].subgroup = "kr-rare-metal-ore"
data.raw.item["kr-rare-metal-ore"].order = "a[kr-rare-metal]-b[rare-metal-ore]-a[rare-metal-ore]"
data.raw.item["kr-enriched-rare-metals"].subgroup = "kr-rare-metal-ore"
data.raw.item["kr-enriched-rare-metals"].order = "a[kr-rare-metal]-b[rare-metal-ore]-b[enriched-rare-metal-ore]"
data.raw.recipe["kr-enriched-rare-metals"].subgroup = "kr-rare-metal-ore"
data.raw.recipe["kr-enriched-rare-metals"].order = "a[kr-rare-metal]-b[rare-metal-ore]-b[enriched-rare-metal-ore]"
data.raw.recipe["kr-enriched-rare-metals"].main_product = "kr-enriched-rare-metals"
data.raw.item["kr-rare-metals"].subgroup = "kr-rare-metal-ore"
data.raw.item["kr-rare-metals"].order = "a[kr-rare-metal]-c[rare-metals]-a[rare-metals]"
data.raw.recipe["kr-rare-metals"].subgroup = "kr-rare-metal-ore"
data.raw.recipe["kr-rare-metals"].order = "a[kr-rare-metal]-c[rare-metals]-a[rare-metals]"
data.raw.recipe["kr-rare-metals-from-enriched-rare-metals"].subgroup = "kr-rare-metal-ore"
data.raw.recipe["kr-rare-metals-from-enriched-rare-metals"].order = "a[kr-rare-metal]-c[rare-metals]-b[rare-metals]"
data.raw.recipe["kr-filter-rare-metal-ore-from-dirty-water"].subgroup = "kr-rare-metal-ore"
data.raw.recipe["kr-filter-rare-metal-ore-from-dirty-water"].order = "a[kr-rare-metal]-b[rare-metal]-c[dirty-water-rare-metal]"

-- Lithium
data.raw.fluid["kr-mineral-water"].subgroup = "kr-lithium"
data.raw.fluid["kr-mineral-water"].order = "a[kr-lithium]-b[mineral-water]-a[mineral-water]"
data.raw.item["kr-lithium-chloride"].subgroup = "kr-lithium"
data.raw.item["kr-lithium-chloride"].order = "a[kr-lithium]-c[lithium-chloride]-a[lithium-chloride]"
data.raw.item["kr-lithium"].subgroup = "kr-lithium"
data.raw.item["kr-lithium"].order = "a[kr-lithium]-d[lithium]-a[lithium]"
data.raw.item["kr-lithium-sulfur-battery"].group = "intermediate-products"
data.raw.item["kr-lithium-sulfur-battery"].subgroup = "intermediate-product"

-- Uranium
data.raw.item["kr-tritium"].subgroup = "uranium"

-- Imersite
data.raw.item["kr-imersite"].subgroup = "kr-imersite"
data.raw.item["kr-imersite"].order = "a[kr-imersite]-b[imersite]-a[imersite]"
data.raw.item["kr-imersite-powder"].subgroup = "kr-imersite"
data.raw.item["kr-imersite-powder"].order = "a[kr-imersite]-c[imersite-powder]-a[imersite-powder]"
data.raw.item["kr-imersite-crystal"].subgroup = "kr-imersite"
data.raw.item["kr-imersite-crystal"].order = "a[kr-imersite]-f[imersite-crystal]-a[imersite-crystal]"
data.raw.item["kr-imersium-plate"].subgroup = "kr-imersite"
data.raw.item["kr-imersium-plate"].order = "a[kr-imersite]-g[imersium-plate]-a[imersium-plate]"

-- Particle Stream Conversions

data.raw.recipe["se-matter-fusion-stone"].order = "a[fusion]-a[conversion]-a[stone]"
data.raw.recipe["se-matter-fusion-iron"].order = "a[fusion]-a[conversion]-b[iron]"
data.raw.recipe["se-matter-fusion-copper"].order = "a[fusion]-a[conversion]-c[copper]"
data.raw.recipe["se-kr-matter-fusion-kr-rare-metal-ore"].order = "a[fusion]-a[conversion]-d[rare-metal]"
data.raw.recipe["se-matter-fusion-uranium"].order = "a[fusion]-a[conversion]-e[uranium]"
data.raw.recipe["se-matter-fusion-vulcanite"].order = "a[fusion]-a[conversion]-f[vulcanite]"
data.raw.recipe["se-matter-fusion-cryonite"].order = "a[fusion]-a[conversion]-g[cryonite]"
data.raw.recipe["se-kr-matter-fusion-kr-imersite"].order = "a[fusion]-a[conversion]-h[imersite]"
data.raw.recipe["se-matter-fusion-beryllium"].order = "a[fusion]-a[conversion]-i[beryllium]"
data.raw.recipe["se-matter-fusion-holmium"].order = "a[fusion]-a[conversion]-j[holmium]"
data.raw.recipe["se-matter-fusion-iridium"].order = "a[fusion]-a[conversion]-k[iridium]"

data.raw.recipe["se-kr-stone-to-particle-stream"].order = "a[fusion]-b[deconversion]-a[stone]"
data.raw.recipe["se-kr-iron-to-particle-stream"].order = "a[fusion]-b[deconversion]-b[iron]"
data.raw.recipe["se-kr-copper-to-particle-stream"].order = "a[fusion]-b[deconversion]-c[copper]"
data.raw.recipe["se-kr-kr-rare-metal-ore-to-particle-stream"].order = "a[fusion]-b[deconversion]-d[rare-metal]"
data.raw.recipe["se-kr-uranium-to-particle-stream"].order = "a[fusion]-b[deconversion]-e[uranium]"
data.raw.recipe["se-kr-vulcanite-to-particle-stream"].order = "a[fusion]-b[deconversion]-f[vulcanite]"
data.raw.recipe["se-kr-cryonite-to-particle-stream"].order = "a[fusion]-b[deconversion]-g[cryonite]"
data.raw.recipe["se-kr-kr-imersite-to-particle-stream"].order = "a[fusion]-b[deconversion]-h[imersite]"
data.raw.recipe["se-kr-beryllium-to-particle-stream"].order = "a[fusion]-b[deconversion]-i[beryllium]"
data.raw.recipe["se-kr-holmium-to-particle-stream"].order = "a[fusion]-b[deconversion]-j[holmium]"
data.raw.recipe["se-kr-iridium-to-particle-stream"].order = "a[fusion]-b[deconversion]-k[iridium]"

-- Manufacturing Tab

-- Basic Assembling
data.raw.item["iron-gear-wheel"].order = "a[basic-intermediates]-a[gear]-a[iron]"
data.raw.item["kr-steel-gear-wheel"].subgroup = "basic-assembling"
data.raw.item["kr-steel-gear-wheel"].order = "a[basic-intermediates]-a[gear]-b[steel]"
data.raw.item["kr-imersium-gear-wheel"].subgroup = "basic-assembling"
data.raw.item["kr-imersium-gear-wheel"].order = "a[basic-intermediates]-a[gear]-c[imersium]"
data.raw.item["kr-iron-beam"].subgroup = "basic-assembling"
data.raw.item["kr-steel-beam"].subgroup = "basic-assembling"
data.raw.item["kr-imersium-beam"].subgroup = "basic-assembling"
data.raw.item["kr-automation-core"].subgroup = "basic-assembling"
data.raw.item["kr-inserter-parts"].subgroup = "basic-assembling"
data.raw.item["kr-pollution-filter"].subgroup = "basic-assembling"
data.raw.item["kr-pollution-filter"].order = "h[filter]-a[clean-filter]-a[clean-filter]"
data.raw.recipe["kr-air-cleaning"].subgroup = "basic-assembling"
data.raw.recipe["kr-air-cleaning"].order = "h[filter]-b[cleaning]-a[cleaning]"
data.raw.item["kr-used-pollution-filter"].subgroup = "basic-assembling"
data.raw.item["kr-used-pollution-filter"].order = "h[filter]-c[used-filter]-a[used-filter]"
data.raw.recipe["kr-restore-used-pollution-filter"].subgroup = "basic-assembling"
data.raw.recipe["kr-restore-used-pollution-filter"].order = "h[filter]-d[restore-filter]-a[restore-filter]"

-- Electronics
data.raw.item["kr-electronic-components"].subgroup = "electronic"
data.raw.recipe["kr-electronic-components-with-lithium"].subgroup = "electronic"
data.raw.item["kr-lithium-sulfur-battery"].subgroup = "electronic"

-- Processor
data.raw.item["kr-energy-control-unit"].subgroup = "processor"
data.raw.item["kr-energy-control-unit"].order = "b[circuits]-d[energy-control-unit]"
data.raw.item["se-quantum-processor"].order = "c[processor]-a[quantum]"
data.raw.item["kr-ai-core"].subgroup = "processor"
data.raw.item["kr-ai-core"].order = "c[processor]-b[ai-core]"

-- Advanced Assembling
data.raw.item["low-density-structure"].order = "a[advanced]-a[lds]-a[lds]"
data.raw.recipe["se-low-density-structure-beryllium"].order = "a[advanced]-a[lds]-b[beryllium]"
data.raw.item["se-space-mirror"].order = "a[advanced]-b[mirror]-a[mirror]"
data.raw.recipe["se-space-mirror-alternate"].order = "a[advanced]-b[mirror]-b[iridium]"
data.raw.item["se-gammaray-detector"].order = "a[advanced]-b[mirror]-c[gamma]"
data.raw.item["se-material-testing-pack"].order = "a[advanced]-c[mtp]-a[mtp]"
data.raw.item["se-nanomaterial"].order = "a[advanced]-d[nano]-a[nano]"
data.raw.item["kr-matter-stabilizer"].subgroup = "advanced-assembling"
data.raw.item["kr-matter-stabilizer"].order = "a[advanced]-e[stabilizer]-c[adv-stab]"
data.raw.item["kr-charged-matter-stabilizer"].subgroup = "advanced-assembling"
data.raw.item["kr-charged-matter-stabilizer"].order = "a[advanced]-e[stabilizer]-d[charged-adv-stab]"

-- Rocket Part
data.raw.item["kr-gps-satellite"].subgroup = "rocket-part"
data.raw.item["kr-teleportation-gps-module"].subgroup = "rocket-part"

-- Canisters
data.raw.item["kr-empty-dt-fuel-cell"].subgroup = "canister-full"
data.raw.item["kr-dt-fuel-cell"].subgroup = "canister-full"
data.raw.item["kr-empty-antimatter-fuel-cell"].subgroup = "canister-full"
data.raw.item["kr-charged-antimatter-fuel-cell"].subgroup = "canister-full"

-- Recycling
data.raw.recipe["kr-crush-burner-inserter"].subgroup = "recycling"
data.raw.recipe["kr-crush-inserter"].subgroup = "recycling"
data.raw.recipe["kr-crush-fast-inserter"].subgroup = "recycling"
data.raw.recipe["kr-crush-long-handed-inserter"].subgroup = "recycling"
data.raw.recipe["kr-crush-bulk-inserter"].subgroup = "recycling"
data.raw.recipe["kr-crush-kr-superior-inserter"].subgroup = "recycling"
data.raw.recipe["kr-crush-kr-superior-long-inserter"].subgroup = "recycling"

-- Basic Matter Conversion
data.raw.item["kr-matter-cube"].subgroup = "se-kr-matter"
data.raw.fluid["kr-matter"].subgroup = "se-kr-matter"

data.raw["item-subgroup"]["kr-matter-conversion"].order = "m[matter]-c[advanced]-a[conversion]"
data.raw["item-subgroup"]["kr-matter-deconversion"].order = "m[matter]-c[advanced]-b[deconversion]"

-- -- Items directly

-- -- Portable RTG
-- data.raw.item["se-rtg-equipment"].subgroup = "equipment"
-- data.raw.item["se-rtg-equipment"].order = "a2[energy-source]-a41[portable-nuclear-core]"
-- -- Portable RTG 2
-- data.raw.item["fission-reactor-equipment"].subgroup = "equipment"
-- data.raw.item["fission-reactor-equipment"].order = "a2[energy-source]-a42[portable-nuclear-core]"

-- -- Energy Storage Accumulator
-- data.raw.item["kr-energy-storage"].subgroup = "solar"
-- data.raw.item["kr-energy-storage"].order = "e[accumulator]-a[accumulator]-final"






-- ---- Adaptive Armor
-- -- Alter ordering
-- data.raw.item["se-adaptive-armour-equipment-1"].subgroup = "kr-character-equipment"
-- data.raw.item["se-adaptive-armour-equipment-1"].order = "s[energy-shield]-a1[adaptive-armour]"
-- data.raw.item["se-adaptive-armour-equipment-2"].subgroup = "kr-character-equipment"
-- data.raw.item["se-adaptive-armour-equipment-2"].order = "s[energy-shield]-a2[adaptive-armour]"
-- data.raw.item["se-adaptive-armour-equipment-3"].subgroup = "kr-character-equipment"
-- data.raw.item["se-adaptive-armour-equipment-3"].order = "s[energy-shield]-a3[adaptive-armour]"
-- data.raw.item["se-adaptive-armour-equipment-4"].subgroup = "kr-character-equipment"
-- data.raw.item["se-adaptive-armour-equipment-4"].order = "s[energy-shield]-a4[adaptive-armour]"
-- data.raw.item["se-adaptive-armour-equipment-5"].subgroup = "kr-character-equipment"
-- data.raw.item["se-adaptive-armour-equipment-5"].order = "s[energy-shield]-a5[adaptive-armour]"
