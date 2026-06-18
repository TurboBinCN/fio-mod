local data_util = require("data_util")

local function self_recycles(item_type, item_name)
  data.raw[item_type][item_name].self_recycle = true
end

self_recycles("item", "stone")
self_recycles("capsule", "raw-fish")
self_recycles("item", SEItemNames.get_sand_name())
self_recycles("item", data_util.mod_prefix .. "scrap")
self_recycles("item", data_util.mod_prefix .. "contaminated-scrap")

-- material processing steps that felt out of line with others
self_recycles("item", data_util.mod_prefix .. "holmium-powder")
self_recycles("item", data_util.mod_prefix .. "iridium-blastcake")
self_recycles("item", data_util.mod_prefix .. "vitamelange-bloom") -- especially with k2
self_recycles("item", data_util.mod_prefix .. "vitalic-reagent") -- epoxy does not recycle either (because of the chemical category, bad?)
self_recycles("item", data_util.mod_prefix .. "self-sealing-gel") -- questionable, but feels like an odd one out

do -- recipes with alternative recipes recycle into themselves
  -- vanilla
  self_recycles("item", "wood")
  self_recycles("item", "landfill")

  -- technically the LDS should also self recycle,
  -- but you would lack copper/plastic on fulgora.
  -- self_recycles("item", "low-density-structure")
  data.raw["recipe"][data_util.mod_prefix .. "low-density-structure-beryllium"].auto_recycle = false

  -- space exploration
  self_recycles("item", data_util.mod_prefix .. "space-elevator-cable")
  self_recycles("item", data_util.mod_prefix .. "cargo-rocket-section")
  self_recycles("item", data_util.mod_prefix .. "lifesupport-canister")
  self_recycles("item", data_util.mod_prefix .. "empty-lifesupport-canister")
  self_recycles("item", data_util.mod_prefix .. "heat-shielding")
  self_recycles("item", data_util.mod_prefix .. "delivery-cannon-capsule")
  self_recycles("item", data_util.mod_prefix .. "cryonite-rod")
  self_recycles("item", data_util.mod_prefix .. "astronomic-insight")
  self_recycles("item", data_util.mod_prefix .. "biological-insight")
  self_recycles("item", data_util.mod_prefix .. "energy-insight")
  self_recycles("item", data_util.mod_prefix .. "material-insight")
end

if mods["Krastorio2"] then
  self_recycles("item", "kr-space-research-data") -- no longer a rocket result

  -- 2+ recipes
  self_recycles("item", "kr-silicon")
  self_recycles("item", "electric-motor") -- vanilla item, alt recipe from k2
end

local function starts_with(str, prefix)
   return str:sub(1, #prefix) == prefix
end

local function ends_with(str, suffix)
   return str:sub(-#suffix) == suffix
end

local subgroup_self_recycles = util.list_to_map({
  "specimen", -- nutrients, bio-cultures, biomass
  "observation-frame", -- blank & variants
  "processor", -- (multi-recipe) circuits
  "fuel", -- processed, solid, (nuclear) rocket
})

-- add all the item groups containing data cards
for _, subgroup in pairs(data.raw["item-subgroup"]) do
  if subgroup.group == "science" and starts_with(subgroup.name, "data-") and not starts_with(subgroup.name, "data-catalogue-") then
    subgroup_self_recycles[subgroup.name] = true
  end
end
self_recycles("item", "satellite") -- the other satellites are inside a data- category

-- now go through all their items and flag for self recycling (note: excludes tools and other item types atm)
for _, item in pairs(data.raw.item) do
  if item.subgroup and subgroup_self_recycles[item.subgroup] then
    item.self_recycle = true
  end

  -- plates and ingots are forced to self recycle
  local item_subgroup = item.subgroup and data.raw["item-subgroup"][item.subgroup]
  if item_subgroup and item_subgroup.group == "resources" and not ends_with(item.subgroup, "-capsule") then
    if ends_with(item.name, "-plate") or ends_with(item.name, "-ingot") then
      item.self_recycle = true
    end
  end
end
