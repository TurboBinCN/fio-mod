local data_util = require("data_util")
local types = {"item", "item-with-entity-data", "rail-planner", "capsule", "fluid"}

local function change_group (name, group, order)
  if data.raw["item-subgroup"][name] then
    data.raw["item-subgroup"][name].group = group
    if order then
      data.raw["item-subgroup"][name].order = order
    end
  end
end

change_group("fluid-recipes", "resources")
change_group("fuel-processing", "resources")
change_group("raw-resource", "resources")
change_group("raw-material", "resources")
change_group("fill-barrel", "intermediate-products")
change_group("barrel", "intermediate-products")
change_group("science-pack", "science", "a")
change_group("tool", "combat", "a-a")
change_group("gun", "combat", "a-b")

local function change_subgroup (name, subgroup, order)
  for _, type in pairs(types) do
    if data.raw[type][name] then
      data.raw[type][name].subgroup = subgroup
      if order then
        data.raw[type][name].order = order
      end
    end
  end
  if data.raw.recipe[name] then
    if data.raw.recipe[name].subgroup then
      data.raw.recipe[name].subgroup = subgroup
      if order then
        data.raw.recipe[name].order = order
      end
    end
  end
end

local function change_recipe_subgroup (name, subgroup, order)
  if data.raw.recipe[name] then
    data.raw.recipe[name].subgroup = subgroup
    if order then
      data.raw.recipe[name].order = order
    end
  end
end

if mods["aai-containers"] then
  change_subgroup("active-provider-chest", "container-1")
  change_subgroup("passive-provider-chest", "container-1")
  change_subgroup("storage-chest", "container-1")
  change_subgroup("buffer-chest", "container-1")
  change_subgroup("requester-chest", "container-1")
else
  change_subgroup("active-provider-chest", "storage")
  change_subgroup("passive-provider-chest", "storage")
  change_subgroup("storage-chest", "storage")
  change_subgroup("buffer-chest", "storage")
  change_subgroup("requester-chest", "storage")
end

change_subgroup("transport-belt", "transport-belt")
change_subgroup("fast-transport-belt", "transport-belt")
change_subgroup("express-transport-belt", "transport-belt")

change_subgroup("underground-belt", "underground-belt")
change_subgroup("fast-underground-belt", "underground-belt")
change_subgroup("express-underground-belt", "underground-belt")

change_subgroup("splitter", "splitter")
change_subgroup("fast-splitter", "splitter")
change_subgroup("express-splitter", "splitter")

if mods["space-age"] then
  change_subgroup("turbo-transport-belt", "transport-belt")
  change_subgroup("turbo-underground-belt", "underground-belt")
  change_subgroup("turbo-splitter", "splitter")
end

change_subgroup("pipe", "pipe")
change_subgroup("pipe-to-ground", "pipe")
change_subgroup("pump", "pipe")
change_subgroup("storage-tank", "pipe")

change_subgroup("rail", "rail")
change_subgroup("train-stop", "rail")
change_subgroup("rail-signal", "rail")
change_subgroup("rail-chain-signal", "rail")
change_subgroup("locomotive", "rail")
change_subgroup("cargo-wagon", "rail")
change_subgroup("fluid-wagon", "rail")
change_subgroup("artillery-wagon", "rail")

change_subgroup("burner-lab", "lab")
change_subgroup("lab", "lab")

change_subgroup("solar-panel", "solar")
change_subgroup("accumulator", "solar")

change_subgroup("chemical-plant", "chemistry")
change_subgroup("oil-refinery", "chemistry")
change_subgroup("fuel-processor", "chemistry")

change_subgroup("burner-assembling-machine", "assembling")
change_subgroup("assembling-machine-1", "assembling")
change_subgroup("assembling-machine-2", "assembling")
change_subgroup("assembling-machine-3", "assembling")

change_subgroup("centrifuge", "radiation")

change_recipe_subgroup("basic-oil-processing", "oil", "a[oil]-c[pet-gas]-b[basic-oil]")
change_recipe_subgroup("advanced-oil-processing", "oil", "a[oil]-d[light-oil]-b[advanced-oil]")
change_recipe_subgroup("oil-processing-heavy", "oil", "a[oil]-e[heavy-oil]-b[oil-processing]")
change_recipe_subgroup("coal-liquefaction", "oil", "a[oil]-e[heavy-oil]-c[coal-liquefaction]")
change_recipe_subgroup("light-oil-cracking", "oil", "a[oil]-d[light-oil]-c[light-cracking]")
change_recipe_subgroup("heavy-oil-cracking", "oil", "a[oil]-e[heavy-oil]-d[heavy-cracking]")
change_recipe_subgroup("lubricant", "oil", "a[oil]-f[lube]-a[lube]")

change_recipe_subgroup("solid-fuel-from-petroleum-gas", "fuel", "a[fuel]-b[solid-fuel]-b[solid-fuel]")
change_recipe_subgroup("solid-fuel-from-light-oil", "fuel", "a[fuel]-b[solid-fuel]-c[solid-fuel]")
change_recipe_subgroup("solid-fuel-from-heavy-oil", "fuel", "a[fuel]-b[solid-fuel]-d[solid-fuel]")

change_subgroup("raw-fish", "water", "z")

change_subgroup("processed-fuel", "fuel", "a[fuel]-a[pro-fuel]-a[pro-fuel]")
change_subgroup("solid-fuel", "fuel", "a[fuel]-b[solid-fuel]-a[solid-fuel]")
change_subgroup("rocket-fuel", "fuel", "a[fuel]-c[rocket-fuel]-a[rocket-fuel]")
change_recipe_subgroup("rocket-fuel", "fuel", "a[fuel]-c[rocket-fuel]-a[rocket-fuel]")
change_subgroup("nuclear-fuel", "fuel", "a[fuel]-z[nuclear-fuel]-a[nuclear-fuel]")

change_recipe_subgroup("sulfuric-acid", "chemical", "a[chemical]-d[sulfur]-b[sulfuric-acid]")
change_subgroup("sulfur", "chemical", "a[chemical]-d[sulfur]-a[sulfur]")
change_subgroup("plastic-bar", "chemical", "a[chemical]-e[plastic]-a[plastic]")
change_subgroup("explosives", "chemical", "a[chemical]-f[explosives]-a[explosives]")

change_subgroup("crude-oil", "oil", "a[oil]-b[oil]-a[oil]")
change_subgroup("petroleum-gas", "oil", "a[oil]-c[pet-gas]-a[pet-gas]")
change_subgroup("light-oil", "oil", "a[oil]-d[light-oil]-a[light-oil]")
change_subgroup("heavy-oil", "oil", "a[oil]-e[heavy-oil]-a[heavy-oil]")
change_subgroup("lubricant", "oil", "a[oil]-f[lube]-a[lube]")
change_subgroup("sulfuric-acid", "chemical", "a[chemical]-d[sulfur]-b[sulfuric-acid]")

change_subgroup("wood", "chemical", "a[chemical]-b[wood]-a[wood]")
change_subgroup("coal", "chemical", "a[chemical]-c[coal]-a[coal]")
change_subgroup("stone", "stone", "a[stone]-b[stone]-a[stone]")
change_subgroup(SEItemNames.get_sand_name(), "stone", "a[stone]-c[sand]-a[sand]")
change_subgroup(SEItemNames.get_glass_name(), "stone", "a[stone]-d[glass]-a[glass]")
change_subgroup("stone-tablet", "stone", "a[stone]-b[stone]-b[stone]")
change_subgroup("iron-ore", "iron", "a[iron]-b[iron-ore]-a[iron-ore]")
change_subgroup("iron-plate", "iron", "a[iron]-e[iron-plate]-a[iron-plate]")
change_subgroup("steel-plate", "iron", "a[iron]-g[steel-plate]-a[steel-plate]")
change_subgroup("copper-ore", "copper", "a[copper]-b[copper-ore]-a[copper-ore]")
change_subgroup("copper-plate", "copper", "a[copper]-e[copper-plate]-a[copper-plate]")

change_subgroup("uranium-ore", "uranium", "a[uranium]-b[uranium-ore]-a[uranium-ore]")
change_subgroup("uranium-238", "uranium", "a[uranium]-c[uranium-238]-a[uranium-238]")
change_subgroup("uranium-235", "uranium", "a[uranium]-d[uranium-235]-a[uranium-235]")
change_recipe_subgroup("uranium-processing", "uranium", "a[uranium]-e[uranium-proc]-a[uranium-proc]")
change_recipe_subgroup("kovarex-enrichment-process", "uranium", "a[uranium]-e[uranium-proc]-b[kovarex]")
change_subgroup("uranium-fuel-cell", "uranium", "a[uranium]-f[fuel-cell]-a[fuel-cell]")
change_subgroup("depleted-uranium-fuel-cell", "uranium", "a[uranium]-f[fuel-cell]-b[dep-fuel-cell]")
change_recipe_subgroup("nuclear-fuel-reprocessing", "uranium", "a[uranium]-f[fuel-cell]-c[proc-fuel-cell]")

change_subgroup("iron-stick", "basic-assembling")
change_subgroup("iron-gear-wheel", "basic-assembling")
change_subgroup("barrel", "basic-assembling")
change_subgroup("motor", "basic-assembling")
change_subgroup("engine-unit", "basic-assembling")
change_subgroup("electric-motor", "basic-assembling")
change_subgroup("electric-engine-unit", "basic-assembling")
change_subgroup("flying-robot-frame", "basic-assembling")

change_subgroup("copper-cable", "electronic", "a")
change_subgroup("battery", "electronic", "f")

change_subgroup("electronic-circuit", "processor")
change_subgroup("advanced-circuit", "processor")
change_subgroup("processing-unit", "processor")

change_subgroup("cliff-explosives", "capsule")

if data.raw.item["logistic-train-stop"] then data.raw.item["logistic-train-stop"].subgroup = "rail" end
if data.raw["item-subgroup"]["angels-warehouses"] then data.raw["item-subgroup"]["angels-warehouses"].order = "a1-"..data.raw["item-subgroup"]["angels-warehouses"].order end
if data.raw.item["angels-pressure-tank-1"] then data.raw.item["angels-pressure-tank-1"].subgroup = "pipe" end
