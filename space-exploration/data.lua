is_debug_mode = false
debug_log = is_debug_mode and log or function()end

Shared = require("shared")

-- Identify if we can reuse other items rather than creating our own
-- for sand and glass. This is to enable seemless updating for those playing with K2
-- installed, as it has changed its sand and glass into kr-sand and kr-glass
-- and before we just reused the K2 sand and glass items
SEItemNames = require("prototypes/phase-1/compatibility/item-names")

-- COLLISION MASKS
-- We need to be able to refer to these layers in control.lua so getting a sequential layer from the collision mask util is not ideal
-- remember to update control.lua setup_collision_layers()
 -- global scope
collision_mask_util = require("__core__/lualib/collision-mask-util")

function se_make_collision_layer(name)
  if not data.raw["collision-layer"][name] then
    data:extend{{type = "collision-layer", name = name}}
  end
  return name
end

-- a full-height wall that you cannot fly though, such as the wall of an underground tunnel.
flying_collision_layer = se_make_collision_layer("flying")
-- things that should block projectiles
projectile_collision_layer = se_make_collision_layer("projectile")
-- Cars, trees, pipes
vehicle_collision_layer = se_make_collision_layer("vehicle")
-- empty space only
empty_space_collision_layer = se_make_collision_layer("empty_space_tile")
-- All space tiles have this
space_collision_layer = se_make_collision_layer("space_tile")
-- Spaceship tiles move around
spaceship_collision_layer = se_make_collision_layer("moving_tile")
-- Tiles that don't move, i.e. block things that can ONLY nly be on spaceship
static_tile_layer = se_make_collision_layer("static_tile")
-- Composite entity internal circuit connection entities get a separate layer so they don't collide with the main entity
composite_entity_circuit_connection_layer = se_make_collision_layer("composite_entity_circuit_connection_layer")
-- From pylons.lua
addon_layer = se_make_collision_layer("addon_layer")
-- From control.lua
planet_collision_layer = se_make_collision_layer("planet_tile")
-- From control.lua
asteroid_collision_layer = se_make_collision_layer("asteroid_tile")

rocket_capacity = 500
local data_util = require("data_util")
if not logged_mods_once then logged_mods_once = true log("Log mods once: "..serpent.block(mods)) end
--log(serpent.block( mods, {comment = false, numformat = '%1.8g' } ))

-- SURFACE RESOURCE VALUES -------------------------------------------------------------
se_resources = se_resources or {}
se_resources["iron-ore"] = se_resources["iron-ore"] or {  order = "c-a", base_density = 14, starting_rq_factor_multiplier = 1.5}
se_resources["copper-ore"] = se_resources["copper-ore"] or {order = "c-b", base_density = 12, starting_rq_factor_multiplier = 1.5}
se_resources["stone"] = se_resources["stone"] or {order = "c-c", base_density = 12, starting_rq_factor_multiplier = 1.5}
se_resources["coal"] = se_resources["coal"] or {order = "c-e", base_density = 9, starting_rq_factor_multiplier = 1.5,}
se_resources["uranium-ore"] = se_resources["uranium-ore"] or {
  order = "c-d",
  has_starting_area_placement = false,
  base_density = 1,
  base_spots_per_km2 = 2,
  random_spot_size_minimum = 2,
  random_spot_size_maximum = 4,
}
se_resources["crude-oil"] = se_resources["crude-oil"] or {
  order = "e-a",
  has_starting_area_placement = true,
  base_density = 8,
  base_spots_per_km2 = 2.5,
  random_probability = 1/24,
  random_spot_size_minimum = 1,
  random_spot_size_maximum = 1, -- don't randomize spot size
  additional_richness = 220000, -- this increases the total everywhere, so base_density needs to be decreased to compensate
  regular_rq_factor_multiplier = 1.2,
  starting_rq_factor_multiplier = 1.5,
}
se_resources[data_util.mod_prefix.."vulcanite"] = se_resources[data_util.mod_prefix.."vulcanite"] or { order = "b-v", base_density = 10, base_spots_per_km2 = 5 }
se_resources[data_util.mod_prefix.."cryonite"] = se_resources[data_util.mod_prefix.."cryonite"] or { order = "b-c", base_density = 10, base_spots_per_km2 = 5 }
se_resources[data_util.mod_prefix.."vitamelange"] = se_resources[data_util.mod_prefix.."vitamelange"] or { order = "a-a", base_density = 10 }
se_resources[data_util.mod_prefix.."iridium-ore"] = se_resources[data_util.mod_prefix.."iridium-ore"] or { order = "a-b" }
se_resources[data_util.mod_prefix.."holmium-ore"] = se_resources[data_util.mod_prefix.."holmium-ore"] or { order = "a-b" }
se_resources[data_util.mod_prefix.."beryllium-ore"] = se_resources[data_util.mod_prefix.."beryllium-ore"] or { order = "a-b" }
se_resources[data_util.mod_prefix.."naquium-ore"] = se_resources[data_util.mod_prefix.."naquium-ore"] or { order = "a-a", base_density = 1 }
se_resources[data_util.mod_prefix.."water-ice"] = se_resources[data_util.mod_prefix.."water-ice"] or { order = "f-a" }
se_resources[data_util.mod_prefix.."methane-ice"] = se_resources[data_util.mod_prefix.."methane-ice"] or { order = "f-b" }

-- CORE FRAGMENT RESOURCE VALUES -------------------------------------------------------------
-- allows other mods to alter core fragment resources
se_core_fragment_resources = se_core_fragment_resources or {}
se_core_fragment_resources["water"] = se_core_fragment_resources["water"] or { multiplier = 0, omni_multiplier = 0.1}
se_core_fragment_resources["crude-oil"] = se_core_fragment_resources["crude-oil"] or { multiplier = 1, omni_multiplier = 0.1}
se_core_fragment_resources["stone"] = se_core_fragment_resources["stone"] or { multiplier = 1, omni_multiplier = 0.5}
se_core_fragment_resources["iron-ore"] = se_core_fragment_resources["iron-ore"] or { multiplier = 1.2, omni_multiplier = 0.5}
se_core_fragment_resources["copper-ore"] = se_core_fragment_resources["copper-ore"] or { multiplier = 1, omni_multiplier = 0.5}
se_core_fragment_resources["coal"] = se_core_fragment_resources["coal"] or { multiplier = 1, omni_multiplier = 0.25}
se_core_fragment_resources["uranium-ore"] = se_core_fragment_resources["uranium-ore"] or { multiplier = 0.2, omni_multiplier = 0.005}

-- Depreciated, don't do this. Add se_allow_in_space =true to the prototype directly instead. --------------------------------------------------------------
se_allow_in_space = se_allow_in_space or {}

-- EXCLUDE FROM PROCEDURAL TECHNOLOGY INGREDIENT FUNCTIONS ---------------------
-- These techs won't have science packs dynamically added.
-- If additional technologies are specified your mod should add the appropriate specialist science packs for that stage of the game
se_procedural_tech_exclusions = se_procedural_tech_exclusions or {}
table.insert(se_procedural_tech_exclusions, "productivity-module")
table.insert(se_procedural_tech_exclusions, "speed-module")
table.insert(se_procedural_tech_exclusions, "efficiency-module")
table.insert(se_procedural_tech_exclusions, "nano-speed")
table.insert(se_procedural_tech_exclusions, "nano-range")
table.insert(se_procedural_tech_exclusions, "mining-productivity")
table.insert(se_procedural_tech_exclusions, "research-speed")
table.insert(se_procedural_tech_exclusions, "inserter-capacity")
table.insert(se_procedural_tech_exclusions, "jetpack")

-- DELIVERY CANNON: Should ONLY deliver homogenous resources, nothing manufactured.
-- defaults to stack size for items
se_delivery_cannon_recipes = se_delivery_cannon_recipes or {}
se_delivery_cannon_recipes["iron-ore"] = {name="iron-ore"}
se_delivery_cannon_recipes["iron-plate"] = {name="iron-plate"}
se_delivery_cannon_recipes[data_util.mod_prefix.."iron-ingot"] = {name=data_util.mod_prefix.."iron-ingot"}
se_delivery_cannon_recipes["copper-ore"] = {name="copper-ore"}
se_delivery_cannon_recipes["copper-plate"] = {name="copper-plate"}
se_delivery_cannon_recipes[data_util.mod_prefix.."copper-ingot"] = {name=data_util.mod_prefix.."copper-ingot"}
se_delivery_cannon_recipes["uranium-ore"] = {name="uranium-ore"}
se_delivery_cannon_recipes["uranium-238"] = {name="uranium-238"}
se_delivery_cannon_recipes["uranium-235"] = {name="uranium-235"}
se_delivery_cannon_recipes["steel-plate"] = {name="steel-plate"}
se_delivery_cannon_recipes[data_util.mod_prefix.."steel-ingot"] = {name=data_util.mod_prefix.."steel-ingot"}
se_delivery_cannon_recipes["stone"] = {name="stone"}
se_delivery_cannon_recipes["stone-brick"] = {name="stone-brick"}
se_delivery_cannon_recipes["coal"] = {name="coal"}
se_delivery_cannon_recipes["concrete"] = {name="concrete"}
se_delivery_cannon_recipes["plastic-bar"] = {name="plastic-bar"}
se_delivery_cannon_recipes["sulfur"] = {name="sulfur"}
se_delivery_cannon_recipes["wood"] = {name="wood"}
se_delivery_cannon_recipes["fish"] = {name="fish"}
se_delivery_cannon_recipes["rocket-fuel"] = {name="rocket-fuel", amount = 10}
se_delivery_cannon_recipes["solid-fuel"] = {name="solid-fuel"}
se_delivery_cannon_recipes["processed-fuel"] = {name="processed-fuel"}
se_delivery_cannon_recipes[SEItemNames.get_sand_name()] = {name=SEItemNames.get_sand_name()}
se_delivery_cannon_recipes[SEItemNames.get_glass_name()] = {name=SEItemNames.get_glass_name()}
se_delivery_cannon_recipes["explosives"] = {name="explosives"}
se_delivery_cannon_recipes["low-density-structure"] = {name="low-density-structure"}
se_delivery_cannon_recipes[data_util.mod_prefix.."heat-shielding"] = {name=data_util.mod_prefix.."heat-shielding"}
se_delivery_cannon_recipes[data_util.mod_prefix.."scrap"] = {name=data_util.mod_prefix.."scrap"}
se_delivery_cannon_recipes[data_util.mod_prefix.."contaminated-scrap"] = {name=data_util.mod_prefix.."contaminated-scrap"}

se_delivery_cannon_recipes[data_util.mod_prefix.."water-ice"] = {name=data_util.mod_prefix.."water-ice"}
se_delivery_cannon_recipes[data_util.mod_prefix.."methane-ice"] = {name=data_util.mod_prefix.."methane-ice"}
se_delivery_cannon_recipes[data_util.mod_prefix.."beryllium-ore"] = {name=data_util.mod_prefix.."beryllium-ore"}
se_delivery_cannon_recipes[data_util.mod_prefix.."beryllium-sulfate"] = {name=data_util.mod_prefix.."beryllium-sulfate"}
se_delivery_cannon_recipes[data_util.mod_prefix.."beryllium-powder"] = {name=data_util.mod_prefix.."beryllium-powder"}
se_delivery_cannon_recipes[data_util.mod_prefix.."beryllium-ingot"] = {name=data_util.mod_prefix.."beryllium-ingot"}
se_delivery_cannon_recipes[data_util.mod_prefix.."iridium-ore"] = {name=data_util.mod_prefix.."iridium-ore"}
se_delivery_cannon_recipes[data_util.mod_prefix.."iridium-ore-crushed"] = {name=data_util.mod_prefix.."iridium-ore-crushed"}
se_delivery_cannon_recipes[data_util.mod_prefix.."iridium-blastcake"] = {name=data_util.mod_prefix.."iridium-blastcake"}
se_delivery_cannon_recipes[data_util.mod_prefix.."iridium-ingot"] = {name=data_util.mod_prefix.."iridium-ingot"}
se_delivery_cannon_recipes[data_util.mod_prefix.."holmium-ore"] = {name=data_util.mod_prefix.."holmium-ore"}
se_delivery_cannon_recipes[data_util.mod_prefix.."holmium-ore-crushed"] = {name=data_util.mod_prefix.."holmium-ore-crushed"}
se_delivery_cannon_recipes[data_util.mod_prefix.."holmium-chloride"] = {name=data_util.mod_prefix.."holmium-chloride"}
se_delivery_cannon_recipes[data_util.mod_prefix.."holmium-ingot"] = {name=data_util.mod_prefix.."holmium-ingot"}
se_delivery_cannon_recipes[data_util.mod_prefix.."naquium-ore"] = {name=data_util.mod_prefix.."naquium-ore"}
se_delivery_cannon_recipes[data_util.mod_prefix.."naquium-ore-crushed"] = {name=data_util.mod_prefix.."naquium-ore-crushed"}
se_delivery_cannon_recipes[data_util.mod_prefix.."naquium-refined"] = {name=data_util.mod_prefix.."naquium-refined"}
se_delivery_cannon_recipes[data_util.mod_prefix.."naquium-ingot"] = {name=data_util.mod_prefix.."naquium-ingot"}
se_delivery_cannon_recipes[data_util.mod_prefix.."vitamelange"] = {name=data_util.mod_prefix.."vitamelange"}
se_delivery_cannon_recipes[data_util.mod_prefix.."vitamelange-nugget"] = {name=data_util.mod_prefix.."vitamelange-nugget"}
se_delivery_cannon_recipes[data_util.mod_prefix.."vitamelange-bloom"] = {name=data_util.mod_prefix.."vitamelange-bloom"}
se_delivery_cannon_recipes[data_util.mod_prefix.."vitamelange-spice"] = {name=data_util.mod_prefix.."vitamelange-spice"}
se_delivery_cannon_recipes[data_util.mod_prefix.."cryonite"] = {name=data_util.mod_prefix.."cryonite"}
se_delivery_cannon_recipes[data_util.mod_prefix.."cryonite-powder"] = {name=data_util.mod_prefix.."cryonite-powder"}
se_delivery_cannon_recipes[data_util.mod_prefix.."cryonite-rod"] = {name=data_util.mod_prefix.."cryonite-rod"}
se_delivery_cannon_recipes[data_util.mod_prefix.."vulcanite"] = {name=data_util.mod_prefix.."vulcanite"}
se_delivery_cannon_recipes[data_util.mod_prefix.."vulcanite-crushed"] = {name=data_util.mod_prefix.."vulcanite-crushed"}
se_delivery_cannon_recipes[data_util.mod_prefix.."vulcanite-enriched"] = {name=data_util.mod_prefix.."vulcanite-enriched"}
se_delivery_cannon_recipes[data_util.mod_prefix.."vulcanite-block"] = {name=data_util.mod_prefix.."vulcanite-block"}

se_delivery_cannon_recipes[data_util.mod_prefix.."cryonite-ion-exchange-beads"] = {name=data_util.mod_prefix.."cryonite-ion-exchange-beads"}
se_delivery_cannon_recipes[data_util.mod_prefix.."vulcanite-ion-exchange-beads"] = {name=data_util.mod_prefix.."vulcanite-ion-exchange-beads"}

se_delivery_cannon_recipes[data_util.mod_prefix.."space-elevator-cable"] = {name=data_util.mod_prefix.."space-elevator-cable"}

-- WEAPON DELIVERY CANNON
se_delivery_cannon_ammo_recipes = se_delivery_cannon_ammo_recipes or {}
se_delivery_cannon_ammo_recipes["atomic-bomb"] = {
  type = "ammo",
  name="atomic-bomb",
  amount = 1,
  ingredients = {
    {type = "item", name = "atomic-bomb", amount = 1},
    {type = "item", name = data_util.mod_prefix .. "delivery-cannon-weapon-capsule", amount = 1},
  },
  map_color = {r=0, g=1.0, b=0},
}
se_delivery_cannon_ammo_recipes[data_util.mod_prefix.."plague-bomb"] = {
  type = "ammo",
  name=data_util.mod_prefix.."plague-bomb",
  amount = 1,
  ingredients = {
    {type = "item", name = data_util.mod_prefix .. "plague-bomb", amount = 1},
    {type = "item", name = data_util.mod_prefix .. "delivery-cannon-weapon-capsule", amount = 1},
  },
  map_color = {r=0, g=1.0, b=1.0}
}

if not mods["space-exploration-postprocess"] then
  local message = "\n\n---------------------------------------------------------------------------------------------------"
  message = message .. "\n\nPlease install the Space Exploration Postprocess mod."
  message = message .. " \n\nYou have the Space Exploration mod installed but not the Space Exploration Postprocess mod. Both are required."
  message = message .. " \n\nUnfortunately the postprocess mod can't be listed as a dependency without creating a dependancy loop, sorry for the inconvenience. "
  message = message .. " \nTo install the postprocess mod you can disable Space Exploration using the 'disable listed mods' button below and reload the game,"
  message = message .. " \ndownload Space Exploration Postprocess mod using the in-game interface, then enable both mods. \nAlternatively you can download the postprocess mod directly here:"
  message = message .. " \nhttps://mods.factorio.com/mod/space-exploration-postprocess/downloads "
  message = message .. "\n\n---------------------------------------------------------------------------------------------------"
  error(message)
end

require("prototypes/phase-1/mod-data")

resource_autoplace = require("prototypes/resource_autoplace_overrides") -- load the updated functions

require("prototypes/phase-1/combined/rocket-control-unit")

require("prototypes/phase-1/input")
require("prototypes/phase-1/shortcut")
require("prototypes/phase-1/custom-events")

require("prototypes/phase-1/item/utility")
require("prototypes/phase-1/item/science-pack")

require("prototypes/phase-1/achievements")
require("prototypes/phase-1/damage-types")
require("prototypes/phase-1/categories")
require("prototypes/phase-1/item-groups")
require("prototypes/phase-1/signal")
require("prototypes/phase-1/planet") -- after signal
require("prototypes/phase-1/sound")
require("prototypes/phase-1/styles")
require("prototypes/phase-1/styles-legacy")
require("prototypes/phase-1/sprite")

require("prototypes/phase-1/item/armor")
require("prototypes/phase-1/item/cargo-rocket")
require("prototypes/phase-1/item/condenser-turbine")
require("prototypes/phase-1/item/core-miner")
require("prototypes/phase-1/item/items")
require("prototypes/phase-1/item/gate")
require("prototypes/phase-1/item/meteor-defence")
require("prototypes/phase-1/item/platforms")
require("prototypes/phase-1/item/resources")
require("prototypes/phase-1/item/rocket-landing-pad")
require("prototypes/phase-1/item/rocket-launch-pad")
require("prototypes/phase-1/item/spaceship")
require("prototypes/phase-1/item/structures")
require("prototypes/phase-1/item/medpack")

require("prototypes/phase-1/item/weapon-tesla")
require("prototypes/phase-1/item/weapon-cryogun")
require("prototypes/phase-1/item/weapon-plague")
require("prototypes/phase-1/item/weapon-railgun")

require("prototypes/phase-1/item/equipment")

require("prototypes/phase-1/fluid/fluid")

require("prototypes/phase-1/recipe/recipe")
require("prototypes/phase-1/recipe/structures")
require("prototypes/phase-1/recipe/astrometrics-laboratory")
require("prototypes/phase-1/recipe/biochemical-laboratory")
require("prototypes/phase-1/recipe/cargo-rocket")
require("prototypes/phase-1/recipe/condenser-turbine")
require("prototypes/phase-1/recipe/core-miner")
require("prototypes/phase-1/recipe/decontamination-facility")
require("prototypes/phase-1/recipe/electromagnetics-laboratory")
require("prototypes/phase-1/recipe/material-fabricator")
require("prototypes/phase-1/recipe/gate")
require("prototypes/phase-1/recipe/genetics-laboratory")
require("prototypes/phase-1/recipe/gravimetrics-laboratory")
require("prototypes/phase-1/recipe/growth-facility")
require("prototypes/phase-1/recipe/hypercooler")
require("prototypes/phase-1/recipe/laser-laboratory")
require("prototypes/phase-1/recipe/lifesupport-facility")
require("prototypes/phase-1/recipe/manufacturing")
require("prototypes/phase-1/recipe/mechanical-laboratory")
require("prototypes/phase-1/recipe/observation")
require("prototypes/phase-1/recipe/particle-accelerator")
require("prototypes/phase-1/recipe/particle-collider")
require("prototypes/phase-1/recipe/plasma-generator")
require("prototypes/phase-1/recipe/platforms")
require("prototypes/phase-1/recipe/resources")
require("prototypes/phase-1/recipe/radiation-laboratory")
require("prototypes/phase-1/recipe/radiator")
require("prototypes/phase-1/recipe/recycling-facility")
require("prototypes/phase-1/recipe/rocket-landing-pad")
require("prototypes/phase-1/recipe/rocket-launch-pad")
require("prototypes/phase-1/recipe/science-lab")
require("prototypes/phase-1/recipe/science")
require("prototypes/phase-1/recipe/supercomputing")
require("prototypes/phase-1/recipe/thermodynamics-laboratory")
require("prototypes/phase-1/recipe/spaceship")
require("prototypes/phase-1/recipe/medpack")

require("prototypes/phase-1/decorative/crater")
require("prototypes/phase-1/decorative/rocks")

require("prototypes/phase-1/entity/entity") -- must be first
require("prototypes/phase-1/entity/astrometric-gravimetric")
require("prototypes/phase-1/entity/compact-beacon")
require("prototypes/phase-1/entity/wide-beacon")
require("prototypes/phase-1/entity/cargo-rocket")
require("prototypes/phase-1/entity/condenser-turbine")
require("prototypes/phase-1/entity/core-miner")
require("prototypes/phase-1/entity/decontamination-lifesupport")
require("prototypes/phase-1/entity/dimensional-anchor")
require("prototypes/phase-1/entity/explosion")
require("prototypes/phase-1/entity/fluid-burner-generator")
require("prototypes/phase-1/entity/fuel-refinery")
require("prototypes/phase-1/entity/gate")
require("prototypes/phase-1/entity/genetics-laboratory")
require("prototypes/phase-1/entity/growth-facility")
require("prototypes/phase-1/entity/laser-radi-thermo")
require("prototypes/phase-1/entity/light")
require("prototypes/phase-1/entity/meteor")
require("prototypes/phase-1/entity/meteor-defence")
require("prototypes/phase-1/entity/recycle-mechanical-pulverise")
require("prototypes/phase-1/entity/resources")
require("prototypes/phase-1/entity/rocket-fragments")
require("prototypes/phase-1/entity/rocket-landing-pad")
require("prototypes/phase-1/entity/rocket-launch-pad")
require("prototypes/phase-1/entity/particle-acc-col-fab")
require("prototypes/phase-1/entity/pylons")
require("prototypes/phase-1/entity/scaffold")
require("prototypes/phase-1/entity/space-biochemical")
require("prototypes/phase-1/entity/space-capsule")
require("prototypes/phase-1/entity/space-electromagnetics")
require("prototypes/phase-1/entity/space-hypercooler")
require("prototypes/phase-1/entity/space-manufactory")
require("prototypes/phase-1/entity/space-plasma-generator")
require("prototypes/phase-1/entity/space-radiator")
require("prototypes/phase-1/entity/space-supercomputer")
require("prototypes/phase-1/entity/space-science-lab")
require("prototypes/phase-1/entity/spaceship")
require("prototypes/phase-1/entity/spaceship-obstacles")
require("prototypes/phase-1/entity/starmap")
require("prototypes/phase-1/entity/supercharger")
require("prototypes/phase-1/entity/telescopes")
require("prototypes/phase-1/entity/ancient")
require("prototypes/phase-1/entity/character")

require("prototypes/phase-1/technology/technology")
require("prototypes/phase-1/technology/bio-upgrades")

require("prototypes/phase-1/combined/arcosphere")
require("prototypes/phase-1/combined/antimatter-reactor")
require("prototypes/phase-1/combined/big-heat-exchanger")
require("prototypes/phase-1/combined/big-turbine")
require("prototypes/phase-1/combined/delivery-cannon")
require("prototypes/phase-1/combined/electric-boiler")
require("prototypes/phase-1/combined/energy-transmitter")
require("prototypes/phase-1/combined/iridium-piledriver")
require("prototypes/phase-1/combined/interburbulator")
require("prototypes/phase-1/combined/lifesupport")
require("prototypes/phase-1/combined/nexus")
require("prototypes/phase-1/combined/pipe")
require("prototypes/phase-1/combined/probe")
require("prototypes/phase-1/combined/rail")
--require("prototypes/phase-1/combined/shield-projector")
require("prototypes/phase-1/combined/transport-belt")
require("prototypes/phase-1/combined/spaceship-clamps")
require("prototypes/phase-1/combined/weapon-bio")
require("prototypes/phase-1/combined/linked-container")
require("prototypes/phase-1/combined/space-elevator")


require("prototypes/phase-1/tile/space")
require("prototypes/phase-1/tile/regolith")
require("prototypes/phase-1/tile/asteroid")
require("prototypes/phase-1/tile/scaffold")
require("prototypes/phase-1/tile/plating")
require("prototypes/phase-1/tile/spaceship")

require("prototypes/phase-1/compatibility/krastorio2/krastorio2")
require("prototypes/phase-1/compatibility/qol_research.lua")
require("prototypes/phase-1/compatibility/space-age")
require("prototypes/phase-1/compatibility/freezing")
require("prototypes/phase-1/compatibility/quality")

-- Alien Biomes adds all its tiles to nauvis.map_gen_settings.autoplace_settings.tile.settings so
-- out-of-map needs to be added to allow for Nauvis to be round. If we want to prevent Nauvis from
-- having certain Alien Biomes tile/decoratives, we should also remove those here.
data.raw.planet["nauvis"].map_gen_settings.autoplace_settings.tile.settings["out-of-map"] = {}

require("prototypes/phase-multi/item-group-assign")
require("prototypes/phase-1/compatibility/recycling")

--log( serpent.block( data.raw["tile"], {comment = false, numformat = '%1.8g' } ) )
