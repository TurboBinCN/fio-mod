local data_util = require("data_util")
local collision_mask_util = require("collision-mask-util")

-- The purpose of this file is to added the "elevated_rail" layer to certain entities when the "elevated-rails" mod is detected.
if mods["elevated-rails"] then
  ---@param proto data.EntityPrototype
  local function add_elevated_rail_collision(proto)
    if not proto then error("Invalid Prototype passed") end
    if not proto.collision_mask then
      proto.collision_mask = collision_mask_util.get_mask(proto)
    end
    proto.collision_mask.layers["elevated_rail"] = true
  end
  ---@param proto data.EntityPrototype
  local function add_moving_tile_collision(proto)
    if not proto then error("Invalid Prototype passed") end
    if not proto.collision_mask then
      proto.collision_mask = collision_mask_util.get_mask(proto)
    end
    proto.collision_mask.layers[spaceship_collision_layer] = true
  end

  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."delivery-cannon"])
  add_elevated_rail_collision(data.raw["container"][data_util.mod_prefix.."delivery-cannon-chest"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."delivery-cannon-weapon"])
  add_elevated_rail_collision(data.raw["ammo-turret"][data_util.mod_prefix.."meteor-defence-container"])
  add_elevated_rail_collision(data.raw["ammo-turret"][data_util.mod_prefix.."meteor-point-defence-container"])
  add_elevated_rail_collision(data.raw["rocket-silo"][data_util.mod_prefix.."space-probe-rocket-silo"])
  add_elevated_rail_collision(data.raw["container"][data_util.mod_prefix.."rocket-launch-pad"])
  add_elevated_rail_collision(data.raw["cargo-landing-pad"]["cargo-landing-pad"])
  add_elevated_rail_collision(data.raw["constant-combinator"][data_util.mod_prefix.."spaceship-clamp"])
  add_elevated_rail_collision(data.raw["storage-tank"][data_util.mod_prefix.."spaceship-clamp-place"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-elevator"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."energy-transmitter-emitter"])
  add_elevated_rail_collision(data.raw["reactor"][data_util.mod_prefix.."energy-receiver"])
  add_elevated_rail_collision(data.raw["electric-energy-interface"][data_util.mod_prefix.."energy-beam-defence"])
  add_elevated_rail_collision(data.raw["electric-energy-interface"][data_util.mod_prefix.."dimensional-anchor"])
  add_elevated_rail_collision(data.raw["mining-drill"][data_util.mod_prefix.."core-miner-drill"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-telescope-microwave"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-telescope-radio"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-telescope-xray"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-telescope-gammaray"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-telescope"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-manufactory"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."pulveriser"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-mechanical-laboratory"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."recycling-facility"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-thermodynamics-laboratory"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-radiation-laboratory"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-laser-laboratory"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."fuel-refinery"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-electromagnetics-laboratory"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-plasma-generator"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-biochemical-laboratory"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-growth-facility"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-material-fabricator"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-particle-accelerator"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-particle-collider"])
  add_elevated_rail_collision(data.raw["assembling-machine"][data_util.mod_prefix.."space-genetics-laboratory"])
  add_elevated_rail_collision(data.raw["lab"][data_util.mod_prefix.."space-science-lab"])

  -- We cannot add "elevated_rail" collision layer to the Spaceship floor tile otherwise we block all other things with the "elevated_rail"
  -- collision layer from being built on spaceships. Instead we must give the elevated rails prototypes the "moving_tile" collision layer
  add_moving_tile_collision(data.raw["elevated-straight-rail"]["elevated-straight-rail"])
  add_moving_tile_collision(data.raw["elevated-curved-rail-a"]["elevated-curved-rail-a"])
  add_moving_tile_collision(data.raw["elevated-curved-rail-b"]["elevated-curved-rail-b"])
  add_moving_tile_collision(data.raw["elevated-half-diagonal-rail"]["elevated-half-diagonal-rail"])
  add_moving_tile_collision(data.raw["rail-ramp"][data_util.mod_prefix.."space-rail-ramp"])
  -- add_moving_tile_collision(data.raw["rail-support"][data_util.mod_prefix.."space-rail-support"]) -- would collide with elevated space rail
  add_moving_tile_collision(data.raw["elevated-straight-rail"][data_util.mod_prefix.."elevated-space-straight-rail"])
  add_moving_tile_collision(data.raw["elevated-curved-rail-a"][data_util.mod_prefix.."elevated-space-curved-rail-a"])
  add_moving_tile_collision(data.raw["elevated-curved-rail-b"][data_util.mod_prefix.."elevated-space-curved-rail-b"])
  add_moving_tile_collision(data.raw["elevated-half-diagonal-rail"][data_util.mod_prefix.."elevated-space-half-diagonal-rail"])
end
