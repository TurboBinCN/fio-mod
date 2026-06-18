local data_util = require("data_util")

-- restrict planet size by placing out-of-map tiles at a certain radius from the center.
-- elevation is not required, put the expression on out-of-map

data:extend({
  {
    type = "autoplace-control",
    name = "planet-size",
    localised_description = {"autoplace-control-names.planet-size-description"},
    order = "z-z",
    category = "terrain",
    richness = false,
    can_be_disabled = false,
  },
  {
    type = "noise-expression",
    name = "control-setting_planet-size_frequency_multiplier",
    expression = "1" --FIXME?
  },
  {
    type = "noise-expression",
    name = "control-setting_planet-size_size_multiplier",
    expression = "1"
  },
  {
    type = "noise-expression",
    name = "vault-land-probability",
    --expression = 2 + noise.max(0, 20 - noise.var("distance")) - noise.var("distance")/30 - noise.absolute_value(scaled_noise_layer_expression(2))
    expression = "2\z
                + max(0, 20 - distance)\z
                - distance/30\z
                - abs(multioctave_noise{\z
                    x = x/2,\z
                    y = y/2,\z
                    persistence = 0.7,\z
                    seed0 = map_seed,\z
                    seed1 = 1,\z
                    octaves = 4,\z
                    input_scale = 1/6,\z
                    output_scale = 1\z
                  })"
  },
  {
    type = "autoplace-control",
    name = data_util.mod_prefix.."cryonite",
    order = "r-c-a",
    category = "resource",
    richness = true,
    hidden = true,
    enabled = false
  },
  {
    type = "autoplace-control",
    name = data_util.mod_prefix.."vulcanite",
    order = "r-c-b",
    category = "resource",
    richness = true,
    hidden = true,
    enabled = false
  },
  {
    type = "autoplace-control",
    name = data_util.mod_prefix.."vitamelange",
    order = "r-c-c",
    category = "resource",
    richness = true,
    hidden = true,
    enabled = false
  },
  {
    type = "autoplace-control",
    name = data_util.mod_prefix.."beryllium-ore",
    order = "r-c-d",
    category = "resource",
    richness = true,
    hidden = true,
    enabled = false
  },
  {
    type = "autoplace-control",
    name = data_util.mod_prefix.."holmium-ore",
    order = "r-c-e",
    category = "resource",
    richness = true,
    hidden = true,
    enabled = false
  },
  {
    type = "autoplace-control",
    name = data_util.mod_prefix.."iridium-ore",
    order = "r-c-f",
    category = "resource",
    richness = true,
    hidden = true,
    enabled = false
  },
  {
    type = "autoplace-control",
    name = data_util.mod_prefix.."water-ice",
    order = "r-s-a",
    category = "resource",
    richness = true,
    hidden = true,
    enabled = false
  },
  {
    type = "autoplace-control",
    name = data_util.mod_prefix.."methane-ice",
    order = "r-s-b",
    category = "resource",
    richness = true,
    hidden = true,
    enabled = false
  },
  {
    type = "autoplace-control",
    name = data_util.mod_prefix.."naquium-ore",
    order = "r-s-c",
    category = "resource",
    richness = true,
    hidden = true,
    enabled = false
  },
})

-- biggest planet size is 10000 at max(600%)
-- planet_radius = 10000 / 6 * (6 + log(1/planet_frequency/6, 2))
-- planet_frequency = 1 / 6 / 2 ^ (planet_radius * 6 / 10000 - 6)
data.raw.tile["out-of-map"].autoplace = {
  --FIXME feature was removed, can not manually specify point lists. needs rework or feature request?
  probability_expression = "10000 * (distance_from_nearest_point{\z
    x = x,\z
    y = y,\z
    points = starting_positions\z
    }\z
   - 10000 / 6 * (6 + log2(1/var('control:planet-size:frequency')/6)))",
}

-- add the fallback land
data.raw.tile[data_util.mod_prefix.."regolith"].autoplace = {
  probability_expression = "-10000"
}

-- space in space: --(1000 - 100) * 10000 = 9,000,00
-- otherwise -100 * 10000 = -1,000,00
data.raw.tile[data_util.mod_prefix.."space"].autoplace = {
  probability_expression = "(1 / var('control:planet-size:frequency') - 100) * 1000",
}

-- asteroids are mainly in asteroid belts and asteroid fields
-- asteroid belts have a band around X
-- asteroid fields are all over
--[[
noise.get_control_setting("planet-size").size_multiplier sets the width of the asteroid belt
asteroid field = 10000 width
asteroid belt = 200 width
planet ring is zone.parent.radius / 200
Sun is 50
spaceship is 1 <- this need to not be here
]]--
data.raw.tile[data_util.mod_prefix.."asteroid"].autoplace = {
  probability_expression = "(1 / var('control:planet-size:frequency') - 100) * 1000\z
  - 1\z
  + max(-25, min(0, var('control:planet-size:size') - 25))\z"..-- Anything below 25 starts to disappear
 "+ (min(y / var('control:planet-size:size'), 0 - y / var('control:planet-size:size'))\z"..--this is the ridge
    "+ max(multioctave_noise{x=x/5, y=y/5, persistence=0.7, seed0=map_seed, seed1=1, octaves=4, input_scale=1/6, output_scale=1},\z
           0 - multioctave_noise{x=x/5, y=y/5, persistence=0.7, seed0=map_seed, seed1=1, octaves=4, input_scale=1/6, output_scale=1}))", -- billows
}

-- we do need noise for asteroid spawning in space
-- unless that is all scripted

data.raw.planet["nauvis"].map_gen_settings.autoplace_controls["planet-size"] = {}
