local Universe = {}

-- stellar cluster inflation code
-- universe-data.lua has base stellar cluster model and unassigned data
-- the model gets inflated by assigning the unassigned data in a deterministic-pseudo-random pattern based on nauvis's map gen seed

-- the list is used in control.lua for space mechanics
-- resource picker selects which core fragments the planet generates
-- the data gets saved to storage on init

-- A group of close in a stellar cluster, each with many planets, each with many moons

-- 30 ish stars
  -- 120-150 planets, min of 3 per star
    -- the rest are moons (350-380)

-- Nauvis is a planet
-- Nauvis orbits the star called... Calidus

-- general concepts:
--[[
star (inaccessable)
  star orbit
  asteroid belt
  planet
    planet orbit
    moon
      moon orbit
asteroid field
deep space

leaving a planet is hard
leaving a moon is less hard
leaving orbit is easy
leaving an asteroid belt is easy
leaving deep space / asteroid fields is free

travel from within a planetary system (planet-moon, moon-moon) is easy
travel from between a planetary systems (or to the star) is difficult
travel between solar systems is very hard
travel to-from deep space difficult

Of just have a generic asteroid field that is the deep space option and is the bridge between all.

it is easier to go from star to deep space to star than star to star
]]--


Universe.planet_max_radius = 10000
-- average is 4000
-- moon max_radius is 50% of it's own planet's actual radius
-- average is 1600

-- NOTE: there are limited numbers of names so more moons means less planets
Universe.average_moons_per_planet = 3
Universe.max_asteroid_belts = 2
Universe.stellar_average_separation = 50
Universe.stellar_min_separation = 25

Universe.temperature_tags = {"temperature_bland", "temperature_temperate", "temperature_midrange", "temperature_balanced", "temperature_wild", "temperature_extreme",
  "temperature_cool", "temperature_cold", "temperature_vcold", "temperature_frozen",
  "temperature_warm", "temperature_hot", "temperature_vhot", "temperature_volcanic"}
Universe.water_tags = {"water_none", "water_low", "water_med", "water_high", "water_max"}
Universe.moisture_tags = {"moisture_none", "moisture_low", "moisture_med", "moisture_high", "moisture_max"}
Universe.trees_tags = {"trees_none", "trees_low", "trees_med", "trees_high", "trees_max"}
Universe.aux_tags = {"aux_very_low", "aux_low", "aux_med", "aux_high", "aux_very_high"}
Universe.cliff_tags = {"cliff_none", "cliff_low", "cliff_med", "cliff_high", "cliff_max"}
Universe.enemy_tags = {"enemy_none", "enemy_very_low", "enemy_low", "enemy_med", "enemy_high", "enemy_very_high", "enemy_max"}

Universe.control_settings_from_tag = {
  ["temperature_bland"] = { hot = { frequency = 0.5, size = 0 }, cold = { frequency = 0.5, size = 0 } },
  ["temperature_temperate"] = { hot = { frequency = 1, size = 0.25 }, cold = { frequency = 1, size = 0.25 } },
  ["temperature_midrange"] = { hot = { frequency = 1, size = 0.65 }, cold = { frequency = 1, size = 0.65 } },
  ["temperature_balanced"] = { hot = { frequency = 1, size = 1 }, cold = { frequency = 1, size = 1 } },
  ["temperature_wild"] = { hot = { frequency = 1, size = 3 }, cold = { frequency = 1, size = 3 } },
  ["temperature_extreme"] = { hot = { frequency = 1, size = 6 }, cold = { frequency = 1, size = 6 } },

  ["temperature_cool"] = { hot = { frequency = 0.75, size = 0 }, cold = { frequency = 0.75, size = 0.5 } },
  ["temperature_cold"] = { hot = { frequency = 0.75, size = 0 }, cold = { frequency = 0.75, size = 1 } },
  ["temperature_vcold"] = { hot = { frequency = 0.75, size = 0 }, cold = { frequency = 0.75, size = 2.2 } },
  ["temperature_frozen"] = { hot = { frequency = 0.75, size = 0 }, cold = { frequency = 0.75, size = 6 } },

  ["temperature_warm"] = { hot = { frequency = 0.75, size = 0.5 }, cold = { frequency = 0.75, size = 0 } },
  ["temperature_hot"] = { hot = { frequency = 0.75, size = 1 }, cold = { frequency = 0.75, size = 0 } },
  ["temperature_vhot"] = { hot = { frequency = 0.75, size = 2.2 }, cold = { frequency = 0.75, size = 0 } },
  ["temperature_volcanic"] = { hot = { frequency = 0.75, size = 6 }, cold = { frequency = 0.75, size = 0 } },

  ["water_none"] = { water = { size = 0 } },
  ["water_low"] = { water = { frequency = 0.5, size = 0.3 } },
  ["water_med"] = { water = { frequency = 1, size = 1 } },
  ["water_high"] = { water = { frequency = 1, size = 4 } },
  ["water_max"] = { water = { frequency = 0.5, size = 10 } },

  ["moisture_none"] = { moisture = { frequency = 2, bias = -1 } },
  ["moisture_low"] = { moisture = { frequency = 1, bias = -0.15 } },
  ["moisture_med"] = { moisture = { frequency = 1, bias = 0 } },
  ["moisture_high"] = { moisture = { frequency = 1, bias = 0.15 } },
  ["moisture_max"] = { moisture = { frequency = 2, bias = 0.5 } },

  ["trees_none"] = { trees = { frequency = 0.25, size = 0, richness = 0 } },
  ["trees_low"] = { trees = { frequency = 0.6, size = 0.35, richness = 0.8 } },
  ["trees_med"] = { trees = { frequency = 0.8, size = 0.66, richness = 1 } },
  ["trees_high"] = { trees = { frequency = 1, size = 1, richness = 1 } },
  ["trees_max"] = { trees = { frequency = 3, size = 1, richness = 1 } },

  ["aux_very_low"] = { aux = { frequency = 1, bias = -0.5 } },
  ["aux_low"] = { aux = { frequency = 1, bias = -0.3 } },
  ["aux_med"] = { aux = { frequency = 1, bias = -0.1 } },
  ["aux_high"] = { aux = { frequency = 1, bias = 0.2 } },
  ["aux_very_high"] = { aux = { frequency = 1, bias = 0.5 } },

  ["cliff_none"] = { cliff = { frequency = 0.01, richness = 0 } },
  ["cliff_low"] = { cliff = { frequency = 0.3, richness = 0.3 } },
  ["cliff_med"] = { cliff = { frequency = 1, richness = 1 } },
  ["cliff_high"] = { cliff = { frequency = 2, richness = 2 } },
  ["cliff_max"] = { cliff = { frequency = 6, richness = 2 } },

  ["enemy_none"] = { ["enemy-base"] = { frequency = 0.000001, size = 0, richness = 0 } },
  ["enemy_very_low"] = { ["enemy-base"] = { frequency = 0.1, size = 0.1, richness = 0.1 } },
  ["enemy_low"] = { ["enemy-base"] = { frequency = 0.2, size = 0.2, richness = 0.2 } },
  ["enemy_med"] = { ["enemy-base"] = { frequency = 0.5, size = 0.5, richness = 0.5 } },
  ["enemy_high"] = { ["enemy-base"] = { frequency = 1, size = 1, richness = 1 } },
  ["enemy_very_high"] = { ["enemy-base"] = { frequency = 1.5, size = 2, richness = 1.5 } },
  ["enemy_max"] = { ["enemy-base"] = { frequency = 2, size = 6, richness = 2 } },
}

Universe.default_resource_order = {
  "iron-ore", "copper-ore", "uranium-ore",
  "coal",  "crude-oil",  "stone",
  mod_prefix.."vulcanite", mod_prefix.."cryonite", mod_prefix.."vitamelange",
  mod_prefix.."naquium-ore", mod_prefix.."methane-ice", mod_prefix.."water-ice",
  mod_prefix.."beryllium-ore", mod_prefix.."iridium-ore", mod_prefix.."holmium-ore"
}

Universe.resource_word_rules = {
  not_space = {
    "oil", "coal", "bio", "wood", "petro", -- anything biological
    "gas", "vent", "water", "liquid", "hydro", "thermal", -- anything liquid, gas, or hot
    "menarite", -- krastorio
    "vitamelange", "vulcanite", "cryonite", "iridium", "holmium"
  },
  not_orbit = {
    "naquium", "beryllium"
  },
  not_asteroid_belt = {
    "naquium"
  },
  not_asteroid_field = {
    "beryllium"
  },
  not_planet = {
    "helium", "space", "asteroid",
    mod_prefix.."water-ice", mod_prefix.."methane-ice", mod_prefix.."naquium-ore"
  },
  not_homeworld = {
    "vitamelange", "vulcanite", "cryonite", "beryllium", "iridium", "holmium", "naquium",
    "gold-ore", "rich-copper-ore" -- BZ
  }
}

Universe.resource_setting_overrides = {
  [mod_prefix.."water-ice"] = { -- becuase water keyword gets excluded from space
    allowed_for_zone = {
      ["asteroid-orbit"] = true,
      ["asteroid-belt"] = true,
      ["asteroid-field"] = true,
      ["orbit"] = true,
    }
  },
  [mod_prefix.."vulcanite"] = {
    tags_required_for_presence = {"temperature_extreme", "temperature_warm", "temperature_hot", "temperature_vhot", "temperature_volcanic"},
    tags_required_for_primary = {"temperature_vhot", "temperature_volcanic"},
    yeild_affected_by = {temperature = 1}
  },
  [mod_prefix.."cryonite"] = {
    tags_required_for_presence = {"temperature_extreme", "temperature_cool", "temperature_cold", "temperature_vcold", "temperature_frozen"},
    tags_required_for_primary = {"temperature_vcold", "temperature_frozen"},
    yeild_affected_by = {temperature = -1}
  },
  [mod_prefix.."vitamelange"] = {
    tags_required_for_presence = {"moisture_med", "moisture_high", "moisture_max"},
    tags_required_for_primary = {"moisture_high", "moisture_max"},
    yeild_affected_by = {moisture = 1},
    excludes = {mod_prefix .. "beryllium-ore", mod_prefix .. "iridium-ore", mod_prefix .. "holmium-ore"}, -- excludes should mutually agree exclusion
  },
  [mod_prefix.."beryllium-ore"] = {
    excludes = {mod_prefix .. "iridium-ore", mod_prefix .. "holmium-ore", mod_prefix .. "vitamelange"}, -- excludes should mutually agree exclusion
  },
  [mod_prefix.."iridium-ore"] = {
    excludes = {mod_prefix .. "beryllium-ore", mod_prefix .. "holmium-ore", mod_prefix .. "vitamelange"}, -- excludes should mutually agree exclusion
  },
  [mod_prefix.."holmium-ore"] = {
    excludes = {mod_prefix .. "beryllium-ore", mod_prefix .. "iridium-ore", mod_prefix .. "vitamelange"}, -- excludes should mutually agree exclusion
  },
}

--

Universe.resource_min_change_to_regenerate = 0.1
Universe.resource_max_change_to_regenerate = 10

Universe.resource_primary_boost = 0.5 -- added to the base bias of 100%. Applied before resource power.
Universe.resource_secondary_irregularity = 0.75
Universe.resource_power = 1.5 -- the curve of resource bias. the resource value is put to this power.

-- Note: These ranges apply based on 0% being the first value, 100% being the second value
-- The primary resource is oevr 100%, based on Universe.resource_primary_boost
Universe.category_resource_properties = {
  homeworld = {
    primary_boost = Universe.resource_primary_boost,
    secondary_irregularity = Universe.resource_secondary_irregularity,
    power = Universe.resource_power,
    frequency = {0.2, 1},
    size = {0, 2},
    richness = {0.1, 2},
  },
  planet = {
    primary_boost = Universe.resource_primary_boost,
    secondary_irregularity = Universe.resource_secondary_irregularity,
    power = Universe.resource_power,
    frequency = {0.2, 1},
    size = {0, 2},
    richness = {0.1, 2},
  },
  ["asteroid-belt"] = {
    primary_boost = Universe.resource_primary_boost,
    secondary_irregularity = Universe.resource_secondary_irregularity,
    power = Universe.resource_power,
    frequency = {1, 10},
    size = {0, 10},
    richness = {0.2, 10},
  },
  anomaly = {
    primary_boost = Universe.resource_primary_boost,
    secondary_irregularity = Universe.resource_secondary_irregularity,
    power = Universe.resource_power,
    frequency = {1, 4},
    size = {0, 4},
    richness = {0.2, 2},
  },
  ["asteroid-field"] = {
    primary_boost = Universe.resource_primary_boost,
    secondary_irregularity = Universe.resource_secondary_irregularity,
    power = Universe.resource_power,
    frequency = {1, 4},
    size = {0, 4},
    richness = {0.2, 2},
  },
  orbit = {
    primary_boost = Universe.resource_primary_boost,
    secondary_irregularity = Universe.resource_secondary_irregularity,
    power = Universe.resource_power,
    frequency = {1, 4},
    size = {0, 4},
    richness = {0.2, 2},
  },
}

function Universe.rebuild_resource_assignments()
  storage.resources_and_controls_compare_string = nil
  Universe.load_resource_data()
end

-- Add restrictions on where resources with a certain word in their name can appear in the Universe.
-- For a mods resources to be added to this restriction table, only call this inside compatibility scripts conditioned on script.active_mods[<mod>]
---@param resource_word string Any substring of the complete resource name to have a restriction on
---@param rule {forbid_space:true|nil, forbid_orbit:true|nil, forbid_belt:true|nil, forbid_field:true|nil, forbid_planet:true|nil, forbid_homeworld:true|nil} Table of restrictions to set
function Universe.add_resource_word_rule(resource_word, rule)
   if rule.forbid_space then
    table.insert(Universe.resource_word_rules.not_space, resource_word)
  end
  if rule.forbid_orbit then
    table.insert(Universe.resource_word_rules.not_orbit, resource_word)
  end
  if rule.forbid_belt then
    table.insert(Universe.resource_word_rules.not_asteroid_belt, resource_word)
  end
  if rule.forbid_field then
    table.insert(Universe.resource_word_rules.not_asteroid_field, resource_word)
  end
  if rule.forbid_planet then
    table.insert(Universe.resource_word_rules.not_planet, resource_word)
  end
  if rule.forbid_homeworld then
    table.insert(Universe.resource_word_rules.not_homeworld, resource_word)
  end
end

-- Adds new resource settings, resulting in the Universe needing to be rebuilt.
-- For a mods resources to be added to the controls, only call this inside compatibility scripts conditioned on script.active_mods[<mod>]
---@param new_setting any
function Universe.add_resource_setting_override(new_setting)
  local control_resource = new_setting.resource
  new_setting.resource = nil
  if Universe.resource_setting_overrides[control_resource] == nil then
    Universe.resource_setting_overrides[control_resource] = new_setting
    if new_setting.excludes then
      -- excludes should mutually agree exclusion, so update other settings here
      for _, resource in pairs(new_setting.excludes) do
        Universe.resource_setting_overrides[resource] = Universe.resource_setting_overrides[resource] or {}
      end
      for resource, settings in pairs(Universe.resource_setting_overrides) do
        if Util.table_contains(new_setting.excludes, resource) then
          settings.excludes = settings.excludes or {}
          table.insert(settings.excludes,control_resource)
        end
      end
    end
  end
end

---@param zone_index (AnyZoneType|StarType)[]
---@param zones_by_name {[string]:AnyZoneType|StarType}
---@param zone AnyZoneType|StarType
function Universe.add_zone(zone_index, zones_by_name, zone)
  Log.debug_log("Adding zone: " ..zone.name)
  table.insert(zone_index, zone)
  zone.index = #zone_index
  zones_by_name[zone.name] = zone
end

function Universe.build ()
  log("Building Universe.")

  storage.universe_rng = game.create_random_generator()
  -- Creates a deterministic standalone random generator with the given seed or if a seed is not provided the initial map seed is used.
  -- rng()
    -- If no parameters are given a number in the [0, 1) range is returned.
    -- If a single parameter is given a floored number in the [0, N] range is returned.
    -- If 2 parameters are given a floored number in the [N1, N2] range is returned.

  ------------------------------------------------------------------------------
  -- structure variables

  local protouniverse = table.deepcopy(UniverseRaw.universe)
  storage.universe = protouniverse

  local unassigned_planets = table.deepcopy(UniverseRaw.unassigned_planets)
  local unassigned_moons = table.deepcopy(UniverseRaw.unassigned_moons)
  local unassigned_planets_or_moons = table.deepcopy(UniverseRaw.unassigned_planets_or_moons)

  local n_stars = #protouniverse.stars
  local npm_names = #unassigned_planets + #unassigned_moons + #unassigned_planets_or_moons

  local average_planets_per_star = npm_names / (Universe.average_moons_per_planet + 1) / n_stars

  local requested_planets = storage.universe_rng(math.floor(average_planets_per_star * 0.9 * n_stars), math.ceil(average_planets_per_star * 1.1 * n_stars))
  local requested_moons = #unassigned_moons + #unassigned_planets_or_moons - requested_planets

  local min_planets_per_star = math.max(2, math.floor(average_planets_per_star / 2))
  local high_planets_per_star = average_planets_per_star * 1.5 -- less likely to be above this
  local high_moons_per_planet = Universe.average_moons_per_planet * 1.5 -- less likely to be above this

  ------------------------------------------------------------------------------
  -- build srtucture

  local all_planets = {}
  table.insert(all_planets, protouniverse.stars[1].children[1]) -- nauvis
  protouniverse.stars[1].children[1].is_homeworld = true
  Log.debug_log("Universe.build protouniverse.stars[1].children[1].name=" .. protouniverse.stars[1].children[1].name, "universe")

  local all_moons = {}

  Universe.shuffle(unassigned_moons)
  Universe.shuffle(protouniverse.stars)
  Universe.shuffle(unassigned_planets)
  Universe.shuffle(unassigned_planets_or_moons)

  for _, star in pairs(protouniverse.stars) do
    star.children = star.children or {}
  end

  -- add the unassigned planets to random stars
  for _, proto_planet in pairs(unassigned_planets) do
    local planet = {name = proto_planet.name}
    table.insert(protouniverse.stars[storage.universe_rng(1, #protouniverse.stars)].children, planet)
    table.insert(all_planets, planet)
  end
  unassigned_planets = {}

  -- fill minimum of # planets per star
  for _, star in pairs(protouniverse.stars) do
    while #star.children < min_planets_per_star and next(unassigned_planets_or_moons) do
      local proto_planet = unassigned_planets_or_moons[#unassigned_planets_or_moons]
      unassigned_planets_or_moons[#unassigned_planets_or_moons] = nil
      local planet = {name = proto_planet.name}
      table.insert(star.children, planet)
      table.insert(all_planets, planet)
    end
  end

  -- build remaining planets
  while #all_planets < requested_planets and next(unassigned_planets_or_moons) do
    local star = protouniverse.stars[storage.universe_rng(1, #protouniverse.stars)]
    if #star.children < high_planets_per_star or storage.universe_rng() < 0.25 then -- 25% to ignore limit
      local proto_planet = unassigned_planets_or_moons[#unassigned_planets_or_moons]
      unassigned_planets_or_moons[#unassigned_planets_or_moons] = nil
      local planet = {name = proto_planet.name}
      table.insert(star.children, planet)
      table.insert(all_planets, planet)
    end
  end

  -- add the unassigned moons to random planets
  for _, proto_moon in pairs(unassigned_moons) do
    local planet = all_planets[storage.universe_rng(1, #all_planets)]
    planet.children = planet.children or {}
    local moon = {name = proto_moon.name}
    table.insert(planet.children, moon)
    table.insert(all_moons, moon)
  end
  unassigned_moons = {}

  -- min 1 moon per planet
  for _, planet in pairs(all_planets) do
    planet.children = planet.children or {}
    if #planet.children < high_moons_per_planet then
      local proto_moon = unassigned_planets_or_moons[#unassigned_planets_or_moons]
      unassigned_planets_or_moons[#unassigned_planets_or_moons] = nil
      local moon = {name = proto_moon.name}
      table.insert(planet.children, moon)
      table.insert(all_moons, moon)
    end
  end


  -- make planets with patrons more likely to appear
  for i, planet_or_moon in pairs(unassigned_planets_or_moons) do
    planet_or_moon.sort = i
    if planet_or_moon.patron then
      planet_or_moon.sort = planet_or_moon.sort + 10000
    end
    if planet_or_moon.biome_replacements then
      planet_or_moon.sort = planet_or_moon.sort + 5000
    end
    if planet_or_moon.tags then
      planet_or_moon.sort = planet_or_moon.sort + 1000
    end
    if planet_or_moon.primary_resource then
      planet_or_moon.sort = planet_or_moon.sort + 500
    end
  end
  table.sort(unassigned_planets_or_moons, function(a, b) return a.sort < b.sort end)
  for _, planet_or_moon in pairs(unassigned_planets_or_moons) do
    planet_or_moon.sort = nil
  end

  -- build remaining moons
  while #all_moons < requested_moons and next(unassigned_planets_or_moons) do
    local planet = all_planets[storage.universe_rng(1, #all_planets)]
    planet.children = planet.children or {}
    if #planet.children < high_moons_per_planet or storage.universe_rng() < 0.25 then -- 25% to ignore limit
      local proto_moon = unassigned_planets_or_moons[#unassigned_planets_or_moons]
      unassigned_planets_or_moons[#unassigned_planets_or_moons] = nil
      local moon = {name = proto_moon.name}
      table.insert(planet.children, moon)
      table.insert(all_moons, moon)
    end
  end

  if is_debug_mode then
    Log.debug_log("Universe:unassigned_planets_or_moons")
    Log.debug_log(serpent.block(unassigned_planets_or_moons))
  end

  -- position the stars
  -- storage.universe_scale is effectivly the width of the universe
  storage.universe_scale = (#protouniverse.stars + #protouniverse.space_zones) ^ 0.5 * Universe.stellar_average_separation

  ---@param zone AnyZoneType|StarType
  ---@param distance_multiplier? float
  local function random_stellar_position(zone, distance_multiplier)
    distance_multiplier = distance_multiplier or 1
    local orientation = storage.universe_rng()
    local distance = storage.universe_rng() * storage.universe_scale * distance_multiplier
    zone.stellar_position = Util.orientation_to_vector(orientation, distance)
  end

  local zone_index = {}
  storage.zone_index = zone_index
  local zones_by_name = {}
  storage.zones_by_name = zones_by_name

  Universe.add_zone(zone_index, zones_by_name, protouniverse.anomaly)

  -- stellar cluster seeded, now shuffle and build:
  for s, star in pairs(protouniverse.stars) do

    star.type = "star"
    if star.name == "Calidus" then
      random_stellar_position(star, 0.1)
    else
      random_stellar_position(star)
    end
    star.orbit = {
      type = "orbit",
      name = star.name .. " Orbit",
      parent = star
    }

    Universe.add_zone(zone_index, zones_by_name, star)
    Universe.add_zone(zone_index, zones_by_name, star.orbit)

    -- Insert asteroid belts
    local add_asteroid_belts = storage.universe_rng(1, Universe.max_asteroid_belts)
    star.star_gravity_well = 10 + #star.children + add_asteroid_belts

    Universe.shuffle(star.children)

    for i = 1, add_asteroid_belts do
      table.insert(star.children, math.floor(0.4 + storage.universe_rng() + #star.children * i / add_asteroid_belts),
      {
        type = "asteroid-belt",
        name = star.name .. " Asteroid Belt " .. i -- Warning, must be updated after shuffle
      })
    end

    for p, planet in pairs(star.children) do -- make Nauvis the first planet
      if planet.name == "Nauvis" and p > 1 then -- swap positions
        local was_index = p
        local other = star.children[1]
        star.children[1] = planet
        star.children[was_index] = other
      end
    end

    local asteroid_belts = 0
    for p, planet in pairs(star.children) do
      if planet.name == "Nauvis" then
        Log.debug_log("Nauvis is homeworld","universe")
        planet.is_homeworld = true
        planet.surface_index = 1
      end

      Universe.add_zone(zone_index, zones_by_name, planet)

      if planet.type == "asteroid-belt" then
        ---@cast planet AsteroidBeltType
        asteroid_belts = asteroid_belts + 1
        planet.name = star.name .. " Asteroid Belt " .. asteroid_belts
        planet.parent = star
      else
        ---@cast planet -AsteroidBeltType
        local planet_prototype = Universe.get_zone_prototype(planet.name)
        planet.children = planet.children or {}
        planet.type = "planet"
        planet.radius_multiplier = 0.4 + 0.6 * storage.universe_rng() ^ 2 -- need to consistently call rng even if prototype.radius_multiplier is defined
        if planet_prototype and planet_prototype.radius_multiplier then
          planet.radius_multiplier = planet_prototype.radius_multiplier
        end
        planet.radius = Universe.planet_max_radius * planet.radius_multiplier
        planet.climate = planet.climate or {}
        planet.parent = star
        planet.orbit = {
          type = "orbit",
          name = planet.name .. " Orbit",
          parent = planet
        }

        Universe.add_zone(zone_index, zones_by_name, planet.orbit)

        Universe.shuffle(planet.children)
        for m, moon in pairs(planet.children) do
          local moon_prototype = Universe.get_zone_prototype(moon.name)
          moon.type = "moon"
          moon.radius_multiplier = 0.2 + 0.8 * storage.universe_rng() ^ 2
          if moon_prototype and moon_prototype.radius_multiplier then
            moon.radius_multiplier = moon_prototype.radius_multiplier
          end
          moon.radius = planet.radius / 2 * moon.radius_multiplier
          moon.climate = moon.climate or {}
          moon.parent = planet
          moon.orbit = {
            type = "orbit",
            name = moon.name .. " Orbit",
            parent = moon
          }

          Universe.add_zone(zone_index, zones_by_name, moon)
          Universe.add_zone(zone_index, zones_by_name, moon.orbit)
        end
      end
    end
  end

  Universe.shuffle(protouniverse.space_zones)
  for z, zone in pairs(protouniverse.space_zones) do
    zone.type = zone.type or "asteroid-field"
    Universe.add_zone(zone_index, zones_by_name, zone)
    random_stellar_position(zone)
  end

  -- Assign seeds and climates
  for _, zone in pairs(zone_index) do
    zone.seed = storage.universe_rng(4294967295)
    Universe.inflate_climate_controls(zone)
  end

  --log("Compiled universe Data: " .. serpent.block( protouniverse, {comment = false, numformat = '%1.8g' } ))

  -- Nauvis stuff
  local nauvis = Zone.from_name("Nauvis") --[[@as PlanetType]]
  nauvis.fragment_name = "se-core-fragment-omni"
  nauvis.surface_index = 1
  nauvis.inflated = true
  nauvis.resources = {}
  nauvis.ticks_per_day = 25000

  storage.zones_by_surface[nauvis.surface_index] = nauvis
  local nauvis_map_gen_settings = game.get_surface(1).map_gen_settings
  if nauvis_map_gen_settings.autoplace_controls["planet-size"] then
    -- planet_radius = 10000 / 6 * (6 + log(1/planet_frequency/6, 2))
    -- planet_frequency = 1 / 6 / 2 ^ (planet_radius * 6 / 10000 - 6)
    --zone.radius = 10000 / 6 * game.get_surface(1).map_gen_settings.autoplace_controls["planet-size"].frequency
    nauvis.radius = 10000 / 6 * (6 + util.math_log(1/nauvis_map_gen_settings.autoplace_controls["planet-size"].frequency/6, 2))
  else
    nauvis.radius = 10000 / 6 * (6 + util.math_log(1/1/6, 2))
  end

  -- Adjust map gen width and height to values appropriate for Nauvis' radius
  if not is_testing_game() then
    local old_width = nauvis_map_gen_settings.width
    local old_height = nauvis_map_gen_settings.height

    nauvis_map_gen_settings.width = (nauvis.radius * 2) + 32
    nauvis_map_gen_settings.height = (nauvis.radius * 2) + 32
    game.get_surface(1).map_gen_settings = nauvis_map_gen_settings

    -- Trim Nauvis if the original width and height values were very low
    if (old_width < 600 or old_height < 600) and (old_width >= 64 and old_height >= 64) then
      Zone.trim_surface_to_bounding_box(nauvis, -old_width/2, -old_height/2, old_width/2, old_height/2)
    end
  end

  ---Table of meteor zones, indexed by zone index
  ---@type IndexMap<AnyZoneType>
  storage.meteor_zones[nauvis.index] = nauvis
  Meteor.schedule_meteor_shower{zone=nauvis, tick=game.tick+1800}

  game.get_surface(1).solar_power_multiplier = Zone.solar_multiplier
  Zone.set_solar_and_daytime(nauvis)


  Universe.separate_stellar_position()

  -- once the above is done do the remaining home system validation. This is so the same code can be used for multipleyer home system initialisation.
  UniverseHomesystem.make_validate_homesystem(storage.zones_by_name["Nauvis"])

  -- resource assignment
  storage.resources_and_controls_compare_string = nil -- force udpate
  Universe.load_resource_data()

  -- more Nauvis stuff
  local surface = game.get_surface(1) --[[@as LuaSurface]]
  surface.localised_name = Zone.get_default_localised_name_for_surface(nauvis) -- technically not shown since planet takes priority
  for resource_name, resource_setting in pairs(storage.resources_and_controls.resource_settings) do
    surface.regenerate_entity(resource_name)
  end
  if settings.startup[mod_prefix.."spawn-small-resources"].value then
    Zone.spawn_small_resources(surface)
  end
  -- generate core seams after normal resources so normal resources can exist under the edges of the core seam
  CoreMiner.generate_core_seam_positions(nauvis)


  for _, star in pairs(storage.universe.stars) do
    Universe.star_gravity_well_distribute(star)
  end

  -- Make sure to do this after `Universe.star_gravity_well_distribute`
  Log.debug_log("Calculating and saving bot attrition for all zones")
  for _, zone in pairs(storage.zone_index) do
    Zone.calculate_base_bot_attrition(zone)
  end

  Universe.set_hierarchy_values()

  log("Building Universe complete.")
end

function Universe.separate_stellar_position()

  local stellar_positions = {}
  for _, zone in pairs(storage.zone_index) do
    if zone.type == "star" or zone.type == "asteroid-field" then
      ---@cast zone StarType|AsteroidFieldType
      table.insert(stellar_positions, zone.stellar_position)
    end
  end
  stellar_positions = Util.separate_points(stellar_positions, Universe.stellar_min_separation)
  local i = 0
  for _, zone in pairs(storage.zone_index) do
    if zone.type == "star" or zone.type == "asteroid-field" then
      ---@cast zone StarType|AsteroidFieldType
      i = i + 1
      if zone.stellar_position.x ~= stellar_positions[i].x or zone.stellar_position.y ~= stellar_positions[i].y then
        -- if spaceship positions are not also changed they end up in a virtual gravity well.
        for _, spaceship in pairs(storage.spaceships) do
          if spaceship.stellar_position and spaceship.stellar_position.x == zone.stellar_position.x and spaceship.stellar_position.y == zone.stellar_position.y then
            spaceship.stellar_position = table.deepcopy(stellar_positions[i])
          end
        end
        log(zone.name .." moved from "..zone.stellar_position.x..", "..zone.stellar_position.y.." to "..stellar_positions[i].x..", "..stellar_positions[i].y)
        zone.stellar_position = stellar_positions[i]
      end
    end
  end
end

function Universe.get_resource_settings_and_order()
  -- Define a set resource processing order for less variablity on data changes.
  -- Order is the secondary sorting order.
  -- resources have selection priority if they have criteria, they will choose zones first.
  --The resource rolling order should start with all vanilla and SE resources first so their values are most consistent.
  if Universe.resource_order then return storage.resources_and_controls.resource_settings, Universe.resource_order end
  local resource_order = table.deepcopy(Universe.default_resource_order)
  for resource_name, resource_setting in pairs(storage.resources_and_controls.resource_settings) do
    if not util.table_contains(resource_order, resource_name) then
      table.insert(resource_order, resource_name)
    end
  end
  Universe.resource_order = resource_order
  return storage.resources_and_controls.resource_settings, Universe.resource_order
end

function Universe.build_resources()
  Log.debug_log("build_resources: start.", "universe")

  -- Don't affect zone.controls, zone.resource_controls, or zone.primary_resource, zone.fragment_name
  -- use zone.new_controls, zone.new_resource_controls zone.new_primary_resource, zone.new_fragment_name
  -- need to separate controls and resource controls.

  local resource_settings, resource_order = Universe.get_resource_settings_and_order()
  Log.debug_log("build_resources: resource_order is:", "universe")
  Log.debug_log(serpent.block(resource_order), "universe")

  -- make a rng for any missing zone seeds
  -- all zones need seeds
  -- can't be consecutive do to similar map gen seeds having nearly identical results.
  local zone_seed_rng = game.create_random_generator(storage.seed)
  for _, zone in pairs(storage.zone_index) do
    Zone.validate_controls(zone.controls) -- somehow non-string keys ended up in previous versions, they cause errors later
    if not zone.seed then
      zone.seed = zone_seed_rng(4294967295)
    end
    Zone.delete_surface(zone) -- try
    Universe.inflate_climate_controls(zone)
    zone.new_primary_resource = nil
    zone.new_fragment_name = nil
    zone.strong_claims = {}
  end

  -- Calculate random resource bias (0-1) values for each resource type on each zone. Still roll even for invalid resources so if settings change it wont skew everything.
  -- Make an ordered bias value set whwere the resources are ordered based on base bias and the divided evenly over the 1-0 range, then add the original bias at 1/100 as a minor factor.
  for _, zone in pairs(storage.zone_index) do
    Universe.generate_zone_resource_bias(zone)
  end
  Log.debug_log("build_resources: example of zone.ordered_resource_bias:", "universe")
  Log.debug_log(serpent.block(storage.zone_index[1].ordered_resource_bias), "universe")
  -- Mark each resource's claim. The major part is if it is part of resource requirements, the minor part is the random fsr.


  -- build the list of resource categories
  storage.zones_by_resource_balance_categories = {
    homeworld = {},
    planet = {}, -- and moons, not homeworlds
    anomaly = {},
    ["asteroid-belt"] = {},
    ["asteroid-field"] = {},
    orbit = {}, -- any orbit type or star
  }
  Log.debug_log("build_resources: resource_balance_categories are:", "universe")
  Log.debug_log(serpent.block(storage.zones_by_resource_balance_categories), "universe")
  for category_name, zrbc in pairs(storage.zones_by_resource_balance_categories) do
    zrbc.quota = {} -- zone count targets per resource are added here
    zrbc.assigned = {} -- zones qith valid primay resources get put here in a subtable of the resource
    zrbc.assigned_special = {} -- special assignement is ignored by the whole assigment system.
    zrbc.unassigned = {} -- zones needing a primary resource go here
    zrbc.zones_normal_total = 0
    zrbc.primary_resource_options = {}
    if category_name == "homeworld" or category_name == "anomaly"  then
      zrbc.primary_resource_options = {"stone"}
      zrbc.assigned["stone"] = {}
      zrbc.assigned_special["stone"] = {}
    else
      for resource_name, resource_setting in pairs(resource_settings) do
        if resource_setting.can_be_primary and resource_setting.allowed_for_zone[category_name] and (resource_setting.core_fragment or category_name ~= "planet") then
          table.insert(zrbc.primary_resource_options, resource_name)
          zrbc.quota[resource_name] = 0
          zrbc.assigned[resource_name] = {}
          zrbc.assigned_special[resource_name] = {}
        end
      end
    end
  end

  -- split all zones into their resource_balance_categories
  -- if a zone has a fixed primary resource, set that and put into an assigned pile.
  for _, zone in pairs(storage.zone_index) do
    local resource_balance_category = Universe.get_zone_resource_balance_category(zone)
    local zrbc = storage.zones_by_resource_balance_categories[resource_balance_category]
    local assigned_by_special = false
    if resource_balance_category == "anomaly" then
      zone.new_primary_resource = "stone"
      Log.debug_log("build_resources: zone "..zone.name.." ("..resource_balance_category..") is locked to primary: "..zone.new_primary_resource , "universe")
    elseif resource_balance_category == "homeworld" then
      zone.new_primary_resource = "stone"
      Log.debug_log("build_resources: zone "..zone.name.." ("..resource_balance_category..") is locked to primary: "..zone.new_primary_resource , "universe")
    else
      if zone.special_type then -- note: this is mainly for the beryllium asteroid belt, the moons already have the resource in the prototype
        local special_type_requirements = UniverseHomesystem.guaranteed_special_types[zone.special_type]
        --
        if special_type_requirements then
          local resource = special_type_requirements.primary_resource
          if util.table_contains(zrbc.primary_resource_options, resource) then
            assigned_by_special = true
            zone.new_primary_resource = resource
            Log.debug_log("build_resources: zone "..zone.name.." ("..resource_balance_category..") has special link to primary: "..zone.new_primary_resource , "universe")
          else
            Log.debug_log("build_resources: zone "..zone.name.." ("..resource_balance_category..") has special link to primary ("..resource..") but the resource is not valid", "universe")
          end
        end
      end
      if not assigned_by_special then
        local prototype = Universe.get_zone_prototype(zone.name)
        if prototype and prototype.primary_resource then
          if util.table_contains(zrbc.primary_resource_options, prototype.primary_resource) then
            zone.new_primary_resource = prototype.primary_resource
            Log.debug_log("build_resources: zone "..zone.name.." ("..resource_balance_category..") is prototyped to primary: "..zone.new_primary_resource , "universe")
          else
            Log.debug_log("build_resources: zone "..zone.name.." ("..resource_balance_category..") is prototyped to primary ("..prototype.primary_resource ..") but the resource is not valid", "universe")
          end
        end
      end
    end
    if resource_balance_category == "homeworld" then
      zone.new_fragment_name = util.mod_prefix .. "core-fragment-omni"
      Log.debug_log("build_resources: zone "..zone.name.." ("..resource_balance_category..") is locked to fragment: "..zone.new_fragment_name , "universe")
    end
    if not assigned_by_special then
      zrbc.zones_normal_total = zrbc.zones_normal_total + 1 -- exclude special
    end
    -- either add to the an assigned pool or the unassigned pool
    if zone.new_primary_resource then
      if not assigned_by_special then
        table.insert(zrbc.assigned[zone.new_primary_resource], zone)
      else
        table.insert(zrbc.assigned_special[zone.new_primary_resource], zone)
      end
    else
      table.insert(zrbc.unassigned, zone)
    end
  end

  -- Zone-Resource assignement
  for resource_balance_category, zrbc in pairs(storage.zones_by_resource_balance_categories) do

    Log.debug_log( "build_resources: begin for zone resource_balance_category (zrbc): " .. resource_balance_category, "universe")
    Log.debug_log( "build_resources: " .. resource_balance_category.." total zones in category: ("..zrbc.zones_normal_total..")", "universe")
    --Log.debug_log( "build_resources: " .. resource_balance_category.." list of unassigned zones: ("..#zrbc.unassigned..")", "universe")
    --for _, zone in pairs(zrbc.unassigned) do
    --  Log.debug_log( "build_resources: " .. resource_balance_category.." unassigned zone "..zone.name, "universe")
    --end

    -- anomaly and homeworld already should have all zones assigned
    if resource_balance_category ~= "anomaly" and resource_balance_category ~= "homeworld" then

      -- Next decide how many zones get each resource type.
      local zones_per_resource_min = math.floor(zrbc.zones_normal_total / #zrbc.primary_resource_options)
      Log.debug_log( "build_resources: " .. resource_balance_category.." min zones per resource : "..zones_per_resource_min, "universe")
      local remainder = zrbc.zones_normal_total % #zrbc.primary_resource_options
      Log.debug_log( "build_resources: " .. resource_balance_category.." remainder : "..remainder, "universe")

      local quotas_total = 0
      local quota_index = 0
      for i, resource_name in pairs(resource_order) do
        if zrbc.quota[resource_name] then
          quota_index = quota_index + 1
          zrbc.quota[resource_name] = zones_per_resource_min + (quota_index <= remainder and 1 or 0)
          quotas_total = quotas_total + zrbc.quota[resource_name]
          Log.debug_log( "build_resources: "..resource_balance_category.." quota for " .. resource_name.." = " .. zrbc.quota[resource_name], "universe")

          -- First, if any resource is above quota, drop resources.
          if #zrbc.assigned[resource_name] > zrbc.quota[resource_name] then
            Log.debug_log( "build_resources: "..resource_balance_category.." has " .. resource_name.." assigned: " .. #zrbc.assigned[resource_name], "universe")
            local resource_assigned =  zrbc.assigned[resource_name]
            table.sort(resource_assigned, function(a,b) return a.resource_bias[resource_name].ordered_bias > b.resource_bias[resource_name].ordered_bias end) -- lowest bias is last
            while #zrbc.assigned[resource_name] > zrbc.quota[resource_name] do
              local last_zone = resource_assigned[#resource_assigned]
              Log.debug_log( "build_resources: "..resource_balance_category.." unassign " .. resource_name.." from: " .. last_zone.name, "universe")
              table.remove(resource_assigned, #resource_assigned)
              table.insert(zrbc.unassigned, last_zone)
            end
          end
        end
      end


      Log.debug_log( "build_resources: " .. resource_balance_category.." quotas total : "..quotas_total, "universe")
      if quotas_total ~= zrbc.zones_normal_total then
        error("build_resources: " .. resource_balance_category.." quotas total : "..quotas_total.." does not equal "..zrbc.zones_normal_total)
      end

      Log.debug_log( "build_resources: " .. resource_balance_category.." currently unassigned: "..#zrbc.unassigned, "universe")
      for resource_name, quota in pairs(zrbc.quota) do
        Log.debug_log( "build_resources: " .. resource_balance_category.." "..resource_name.." "..#zrbc.assigned[resource_name].." / "..quota, "universe")
      end

      Log.debug_log( "build_resources: begin assign uncontested strong claims", "universe")
      --On the first pass. do only resources with strict requirements. Only assign based on uncontested major claims.
      local has_strong_claims = false
      local uncontested_claimed_zones = {} -- split by resource name
      local all_strong_claims = {} -- single list of zones

      for _, zone in pairs(zrbc.unassigned) do
        -- make strong claims
        for _, resource_name in pairs(resource_order) do
          local resource_setting = resource_settings[resource_name]
          if zrbc.assigned[resource_name] and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] then -- validates resource_name
            -- don't bother with resources already at quota
            local tags_required = resource_setting.tags_required_for_primary or resource_setting.tags_required_for_presence
            if tags_required then
              local has_required_tag = false
              if zone.tags then
                for _, tag in pairs(tags_required) do
                  if Util.table_contains(zone.tags, tag) then
                    has_required_tag = true
                    break
                  end
                end
              -- Homeworlds do not have tags
              elseif resource_setting.allowed_for_zone["homeworld"] and zone.is_homeworld then
                has_required_tag = true
              end
              if has_required_tag then
                zone.strong_claims = zone.strong_claims or {}
                zone.strong_claims[resource_name] = 1 -- TODO maybe can weight this more,
                has_strong_claims = true
                Log.debug_log( "build_resources: "..resource_balance_category.." has strong claim " .. resource_name.." for: " .. zone.name, "universe")
              end
            end
          end
        end
        if zone.strong_claims then
          if table_size(zone.strong_claims) == 1 then
            for resource_name, weight in pairs(zone.strong_claims) do
              uncontested_claimed_zones[resource_name] = uncontested_claimed_zones[resource_name] or {}
              table.insert(uncontested_claimed_zones[resource_name], zone)
              Log.debug_log( "build_resources: "..resource_balance_category.." has uncontested claim " .. resource_name.." for: " .. zone.name, "universe")
            end
          end
          if table_size(zone.strong_claims) > 0 then
            table.insert(all_strong_claims, zone)
          end
        end
      end

      if has_strong_claims then
        Log.debug_log( "build_resources: "..resource_balance_category.." # strong claims: "..#all_strong_claims, "universe")
        for resource_name, zones in pairs(uncontested_claimed_zones) do
          table.sort(zones, function(a,b) return a.resource_bias[resource_name].ordered_bias > b.resource_bias[resource_name].ordered_bias end) -- highest first
          while next(zones) and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] do
            local zone = zones[1]
            zone.new_primary_resource = resource_name
            if resource_balance_category == "planet" then
              zone.new_fragment_name = resource_settings[resource_name].core_fragment
            end
            table.remove(zones, 1)
            util.remove_from_table(zrbc.unassigned, zone)
            util.remove_from_table(all_strong_claims, zone)
            table.insert(zrbc.assigned[resource_name], zone)
            Log.debug_log( "build_resources: "..resource_balance_category.." assign " .. resource_name.." to: " .. zone.name .. " (uncontested)", "universe")
          end
        end

      end

      Log.debug_log( "build_resources: end assign uncontested strong claims", "universe")

      Log.debug_log( "build_resources: " .. resource_balance_category.." currently unassigned: "..#zrbc.unassigned, "universe")
      for resource_name, quota in pairs(zrbc.quota) do
        Log.debug_log( "build_resources: " .. resource_balance_category.." "..resource_name.." "..#zrbc.assigned[resource_name].." / "..quota, "universe")
      end
      --On the 2nd pass. do only resources with strict requirements. Do the contested major claims.
      --  loop repeatedly beased on whichever resource has the fewest assigned zones so far. Go with yout highest claim.
      Log.debug_log( "build_resources: begin assign strong claims", "universe")

      if has_strong_claims then
        if next(all_strong_claims) then
          local max_zones = 0
          local resource_pointer = 1
          while next(all_strong_claims) and max_zones <= zones_per_resource_min do
            local resource_name = resource_order[resource_pointer]
            local resource_setting = resource_settings[resource_name]
            if resource_setting and (resource_setting.tags_required_for_primary or resource_setting.tags_required_for_presence)
                and zrbc.assigned[resource_name] and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] and #zrbc.assigned[resource_name] <= max_zones then
              table.sort(all_strong_claims, function(a,b) return a.resource_bias[resource_name].ordered_bias > b.resource_bias[resource_name].ordered_bias end) -- highest bias is first
              local zone = all_strong_claims[1]
              zone.new_primary_resource = resource_name
              if resource_balance_category == "planet" then
                zone.new_fragment_name = resource_settings[resource_name].core_fragment
              end
              table.remove(all_strong_claims, 1)
              util.remove_from_table(zrbc.unassigned, zone)
              table.insert(zrbc.assigned[resource_name], zone)
              Log.debug_log( "build_resources: "..resource_balance_category.." assign " .. resource_name.." to: " .. zone.name .. " (contested strong claim)", "universe")
            end
            resource_pointer = resource_pointer + 1
            if resource_pointer > #resource_order then
              resource_pointer = 1
              max_zones = max_zones + 1
            end
          end
        else
          Log.debug_log( "build_resources: "..resource_balance_category.." have no remaining strong claims.", "universe")
        end

      end

      Log.debug_log( "build_resources: end assign strong claims", "universe")

      Log.debug_log( "build_resources: " .. resource_balance_category.." currently unassigned: "..#zrbc.unassigned, "universe")
      for resource_name, quota in pairs(zrbc.quota) do
        Log.debug_log( "build_resources: " .. resource_balance_category.." "..resource_name.." "..#zrbc.assigned[resource_name].." / "..quota, "universe")
      end

      Log.debug_log( "build_resources: begin assign resources with strict requirement", "universe")
      --On the 3rd pass, if there are resources with strict requirements that still need to meet a quota, climate needs to be changed.
      --  Make a pool of all the zones with no fixed climate tags.
      --  Find the zone with the highest rolled bias. Change that ones climate to fill the quota.
      local max_zones = zones_per_resource_min + 1
      local criteria_resources_lacking_zones = {} -- resource_names
      for _, resource_name in pairs(resource_order) do
        local resource_setting = resource_settings[resource_name]
        if resource_setting and (resource_setting.tags_required_for_primary or resource_setting.tags_required_for_presence)
          and zrbc.assigned[resource_name] and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] then
          table.insert(criteria_resources_lacking_zones, resource_name)
          max_zones = math.min(max_zones, #zrbc.assigned[resource_name])
        end
      end

      local resource_pointer = 1
      while next(all_strong_claims) and max_zones <= zones_per_resource_min do
        local resource_name = criteria_resources_lacking_zones[resource_pointer]
        if #zrbc.assigned[resource_name] <= max_zones and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] then
          -- try to add
          table.sort(zrbc.unassigned, function(a,b) return a.resource_bias[resource_name].ordered_bias > b.resource_bias[resource_name].ordered_bias end) -- highest bias is first
          local zone = zrbc.unassigned[1]
          zone.new_primary_resource = resource_name
          if resource_balance_category == "planet" then
            zone.new_fragment_name = resource_settings[resource_name].core_fragment
          end
          util.remove_from_table(zrbc.unassigned, zone)
          table.insert(zrbc.assigned[resource_name], zone)
          Log.debug_log( "build_resources: "..resource_balance_category.." assign " .. resource_name.." to: " .. zone.name .. " (forced climate change)", "universe")
          Universe.fit_climate_to_primary_resource(zone)
        end
        resource_pointer = resource_pointer + 1
        if resource_pointer > #criteria_resources_lacking_zones then
          resource_pointer = 1
          max_zones = max_zones + 1
        end
      end

      local resources_below_quota = {}
      for _, resource_name in pairs(resource_order) do
        if zrbc.assigned[resource_name] and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] then
          table.insert(resources_below_quota, resource_name)
        end
      end

      Log.debug_log( "build_resources: end assign resources with strict requirement", "universe")

      Log.debug_log( "build_resources: " .. resource_balance_category.." currently unassigned: "..#zrbc.unassigned, "universe")
      for resource_name, quota in pairs(zrbc.quota) do
        Log.debug_log( "build_resources: " .. resource_balance_category.." "..resource_name.." "..#zrbc.assigned[resource_name].." / "..quota, "universe")
      end

      Log.debug_log( "build_resources: begin assign resources based on bias winners", "universe")
      --On the 4th pass, for each resource, get all the zones where the bias wins over all other. Sort them based on bias value. Assign up to quota as the limit.
      for _, resource_name in pairs(resource_order) do
        if zrbc.assigned[resource_name] and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] then
          local zones_where_resource_won = {}
          for _, zone in pairs(zrbc.unassigned) do
            if zone.ordered_resource_bias[1].resource_name == resource_name then
              table.insert(zones_where_resource_won, zone)
            end
          end
          table.sort(zones_where_resource_won, function(a,b) return a.resource_bias[resource_name].ordered_bias > b.resource_bias[resource_name].ordered_bias end) -- highest bias is first
          while next(zones_where_resource_won) and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] do
            local zone = zones_where_resource_won[1]
            zone.new_primary_resource = resource_name
            if resource_balance_category == "planet" then
              zone.new_fragment_name = resource_settings[resource_name].core_fragment
            end
            table.remove(zones_where_resource_won, 1)
            util.remove_from_table(zrbc.unassigned, zone)
            table.insert(zrbc.assigned[resource_name], zone)
            Log.debug_log( "build_resources: "..resource_balance_category.." assign " .. resource_name.." to: " .. zone.name .. " (bias won)", "universe")
          end
        end
      end
      Log.debug_log( "build_resources: end assign resources based on bias winners", "universe")

      Log.debug_log( "build_resources: " .. resource_balance_category.." currently unassigned: "..#zrbc.unassigned, "universe")
      for resource_name, quota in pairs(zrbc.quota) do
        Log.debug_log( "build_resources: " .. resource_balance_category.." "..resource_name.." "..#zrbc.assigned[resource_name].." / "..quota, "universe")
      end

      Log.debug_log( "build_resources: begin assign resources in turns by highest remaining bias", "universe")
      --On the 5th pass, loop through resources based on the fewest assigned zones. Choose the available zone with the highest bias.
      local max_zones = zones_per_resource_min + 1
      local resources_lacking_zones = {} -- resource_names
      for _, resource_name in pairs(resource_order) do
        if zrbc.assigned[resource_name] and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] then
          table.insert(resources_lacking_zones, resource_name)
          max_zones = math.min(max_zones, #zrbc.assigned[resource_name])
          Log.debug_log( "build_resources: " .. resource_balance_category.." "..resource_name.." still needs "..(zrbc.quota[resource_name]-#zrbc.assigned[resource_name]).." zones", "universe")
        end
      end

      local resource_pointer = 1
      while next(zrbc.unassigned) and max_zones <= zones_per_resource_min + 1 do
        local resource_name = resources_lacking_zones[resource_pointer]
        if resource_name and #zrbc.assigned[resource_name] <= max_zones and #zrbc.assigned[resource_name] < zrbc.quota[resource_name] then
          -- try to add
          local _, zone_index = util.find_max_from_table(zrbc.unassigned, function(zone) return zone.resource_bias[resource_name].ordered_bias end)
          local zone = zrbc.unassigned[zone_index]
          zone.new_primary_resource = resource_name
          if resource_balance_category == "planet" then
            zone.new_fragment_name = resource_settings[resource_name].core_fragment
          end
          table.remove(zrbc.unassigned, zone_index)
          table.insert(zrbc.assigned[resource_name], zone)
          Log.debug_log( "build_resources: "..resource_balance_category.." assign " .. resource_name.." to: " .. zone.name .. " (highest remaining bias)", "universe")
        end
        resource_pointer = resource_pointer + 1
        if resource_pointer > #resources_lacking_zones then
          resource_pointer = 1
          max_zones = max_zones + 1
        end
      end
      Log.debug_log( "build_resources: end assign resources in turns by highest remaining bias", "universe")

      Log.debug_log( "build_resources: " .. resource_balance_category.." currently unassigned: "..#zrbc.unassigned, "universe")
      for resource_name, quota in pairs(zrbc.quota) do
        Log.debug_log( "build_resources: " .. resource_balance_category.." "..resource_name.." "..#zrbc.assigned[resource_name].." / "..quota, "universe")
      end

      -- Primary resource assignment complete
      if next(zrbc.unassigned) then
        error("build_resources: "..resource_balance_category.." assign resources failed: "..#zrbc.unassigned.." are unassigned")
      end
      Log.debug_log( "build_resources: "..resource_balance_category.." assign resources complete: "..#zrbc.unassigned.." are unassigned", "universe")
    end

  end

  Log.debug_log( "build_resources: update zones based on assignments", "universe")

  for _, zone in pairs(storage.zone_index) do
    Universe.apply_zone_resource_assignments(zone)
  end
  Log.debug_log("build_resources: end.", "universe")
end

---@param zone AnyZoneType|StarType
function Universe.generate_zone_resource_bias(zone)
  local resource_settings, resource_order = Universe.get_resource_settings_and_order()
  local zone_resource_bias_nrg = game.create_random_generator(zone.seed)
  zone.ordered_resource_bias = {} -- indexed
  zone.resource_bias = {} -- named
  -- DO NOT skip resources that aren't needed otherwise turning on/off a resource changes the results of others.
  -- DO NOT check if vanilla/SE resource are still valid is that will also affect other rolls.
  for _, resource_name in pairs(resource_order) do
    local bias = {
      resource_name = resource_name,
      base_bias = zone_resource_bias_nrg(),
    }
    table.insert(zone.ordered_resource_bias, bias)
    zone.resource_bias[resource_name] = bias
    local prototype = Universe.get_zone_prototype(zone.name)
    if prototype and prototype.preset_resource_bias and prototype.preset_resource_bias[resource_name] then
      Log.debug_log("build_resources: "..zone.name.." has preset bias for "..resource_name.." " ..prototype.preset_resource_bias[resource_name], "universe")
      bias.base_bias = prototype.preset_resource_bias[resource_name]
    end
  end
  table.sort(zone.ordered_resource_bias, function(a,b) return a.base_bias > b.base_bias end)
  -- zone.resource_bias sorted highest first
  for i, bias in pairs(zone.ordered_resource_bias) do
    bias.ordered_bias = 1 + (bias.base_bias - i) / #zone.ordered_resource_bias
    -- ordered_bias means less variablity during later selection step
    -- ordered_bias is the minor basis for resource claiming zone
    -- major basis is whether it qualifies based on tags.
  end
end

---@param zone AnyZoneType
function Universe.apply_zone_resource_assignments(zone)
  -- the zone as modified by universe resource assignments with temporary data such as zone.new_primary_resource
  local resource_settings, resource_order = Universe.get_resource_settings_and_order()

  local resource_balance_category = Universe.get_zone_resource_balance_category(zone)
  Log.debug_log( "build_resources: update zone based on assignments: "..zone.name.."("..resource_balance_category..")", "universe")
  if zone.new_fragment_name then
    if zone.fragment_name ~= zone.new_fragment_name then
      Log.debug_log( "build_resources: zone fragment changed from "..(zone.fragment_name or "nil").. " to ".. zone.new_fragment_name, "universe")
      zone.fragment_name = zone.new_fragment_name
      CoreMiner.update_zone_fragment_resources(zone)
    end
  end

  local resource_to_regenerate = {} -- list of resource_name
  local resource_to_rescale = {} -- dictionary of resource_name = multiplier
  -- If zone.new_primary_resource is nil, this zone doesn't have a resource yet, we're not changing it from an existing resource, we're only setting zone.controls.
  if zone.new_primary_resource and zone.new_primary_resource ~= zone.primary_resource then
    Log.debug_log( "build_resources: zone primary_resource changed from "..(zone.primary_resource or "nil").. " to ".. zone.new_primary_resource, "universe resource_changed")
    zone.primary_resource = zone.new_primary_resource
  end

  if not zone.resource_bias then
    -- this would normally be done in Universe.build_resources()
    Universe.generate_zone_resource_bias(zone)
  end

  -- Recalculate the biases list using the new primary and excluded resourecs information.
  -- Get the list of all excluded resources, including excluded by type.
  -- specify 0 controls for excluded.
  -- update controls for others.
  -- compare with existng fsr if any.
  zone.ordered_resource_bias = {}
  local invalid_resources = {}

  for _, resource_bias in pairs(zone.resource_bias) do
    local resource_name = resource_bias.resource_name
    local resource_setting = resource_settings[resource_name]
     -- check if it is valid
    if resource_setting and resource_setting.allowed_for_zone[resource_balance_category] then
      local allowed = true
      if resource_name == "se-vitamelange" and zone.special_type and zone.special_type ~= "vitamelange" then
        -- Remove vitamelange from guaranteed biter-less zones
        allowed = false
        Log.debug_log( "build_resources: secondary resource "..resource_name.." excluded by special type requirements from "..zone.name, "universe")
      elseif resource_name ~= zone.primary_resource then
        --  Apply strict resources restrictions
        if resource_setting.tags_required_for_presence then
          local has_required_tag = false
          local tags_required = resource_setting.tags_required_for_presence
          if zone.tags then
            for _, tag in pairs(tags_required) do
              if Util.table_contains(zone.tags, tag) then
                has_required_tag = true
                break
              end
            end
          -- Homeworlds do not have tags
          elseif resource_setting.allowed_for_zone["homeworld"] and zone.is_homeworld then
            has_required_tag = true
          end
          if not has_required_tag then
            allowed = false
            Log.debug_log( "build_resources: secondary resource "..resource_name.." excluded by tag requirements from "..zone.name, "universe")
          end
        end
      end
      if allowed then
        table.insert(zone.ordered_resource_bias, resource_bias) -- important that this is only valid ones now
        resource_bias.ordered_bias = resource_bias.base_bias
        if resource_name == zone.primary_resource then
          resource_bias.ordered_bias = resource_bias.ordered_bias + 1 -- puts at the top
        end
      else
        table.insert(invalid_resources, resource_name)
      end
    else
      table.insert(invalid_resources, resource_name)
    end
  end
  table.sort(zone.ordered_resource_bias, function(a,b) return a.ordered_bias > b.ordered_bias end)

  -- Apply incompatible resources exclusions
  for i = 1, #zone.ordered_resource_bias do
    if zone.ordered_resource_bias[i] then
      local resource_name = zone.ordered_resource_bias[i].resource_name
      local resource_setting = resource_settings[resource_name]
      if resource_setting.excludes then
        for _, exclude in pairs(resource_setting.excludes) do
          for j = i+1, #zone.ordered_resource_bias do
            if zone.ordered_resource_bias[j] then
              if zone.ordered_resource_bias[j].resource_name == exclude then
                Log.debug_log( "build_resources: secondary resource "..exclude.." excluded by higher resource "..resource_name.." from "..zone.name, "universe")
                table.insert(invalid_resources, exclude)
                table.remove(zone.ordered_resource_bias, j)
                j = j - 1
              end
            end
          end
        end
      end
    end
  end


  local surface = Zone.get_surface(zone)

  if resource_balance_category ~= "homeworld" then
    for i, bias in pairs(zone.ordered_resource_bias) do
      local category_resource_properties = Universe.category_resource_properties[resource_balance_category]
      local resource_name = bias.resource_name
      local base_bias = bias.base_bias
      if i == 1 then
        base_bias = 1
      end
      local ordered_bias = (#zone.ordered_resource_bias-i)/#zone.ordered_resource_bias
      local resource_value = category_resource_properties.secondary_irregularity * base_bias + (1 - category_resource_properties.secondary_irregularity) * ordered_bias
      if i == 1 then
        resource_value = 1 + category_resource_properties.primary_boost
      end
      resource_value = resource_value ^ category_resource_properties.power
      bias.resource_value = resource_value
      local old_fsr
      if surface and zone.controls[resource_name] then
        old_fsr = zone.controls[resource_name].frequency * zone.controls[resource_name].size * zone.controls[resource_name].richness
      end
      zone.controls[resource_name] = {
        frequency = category_resource_properties.frequency[1] + resource_value * (category_resource_properties.frequency[2] - category_resource_properties.frequency[1]),
        size = category_resource_properties.size[1] + resource_value * (category_resource_properties.size[2] - category_resource_properties.size[1]),
        richness = category_resource_properties.richness[1] + resource_value * (category_resource_properties.richness[2] - category_resource_properties.richness[1])
      }
      if surface then
        if old_fsr == nil then
          table.insert(resource_to_regenerate, resource_name)
        else
          local new_fsr = zone.controls[resource_name].frequency * zone.controls[resource_name].size * zone.controls[resource_name].richness
          local fsr_multiplier = new_fsr / old_fsr
          if fsr_multiplier ~= 1 then
            Log.debug_log( "build_resources: resource changed "..zone.name .." ("..resource_balance_category..") "..resource_name.." multiplier = "..fsr_multiplier, "universe")
            if fsr_multiplier > Universe.resource_max_change_to_regenerate or fsr_multiplier < Universe.resource_min_change_to_regenerate then
              table.insert(resource_to_regenerate, resource_name)
            else
              -- close enough to rescale
              resource_to_rescale[resource_name] = fsr_multiplier
            end
          end
        end
      end
    end
  else -- homeworlds only
    -- Save the mapgen settings to controls for quick reading
    zone.controls = {}
    if surface then
      local mapgen = surface.map_gen_settings
      for _, resource_name in pairs(resource_order) do
        local resource_setting = resource_settings[resource_name]
        if resource_setting and resource_setting.allowed_for_zone[resource_balance_category] then
          if mapgen.autoplace_controls and mapgen.autoplace_controls[resource_name] then
            zone.controls[resource_name] = mapgen.autoplace_controls[resource_name]
          end
        else
          if not util.table_contains(invalid_resources, resource_name) then
            error("Homeworld ("..zone.name..") has invalid resource: " .. resource_name)
          end
        end
      end
    else
      error("Homeworld ("..zone.name..") has no surface")
    end
  end
  --Log.debug_log( "build_resources: resource values for: "..zone.name, "universe")
  --Log.debug_log( serpent.block(zone.ordered_resource_bias), "universe")

  -- remove all invalid
  zone.controls = zone.controls or {}
  for _, resource_name in pairs(invalid_resources) do
    zone.controls[resource_name] = {frequency = 1, size = 0, richness = 0}
    --Log.debug_log( "build_resources: invalid resource " .. resource_name.." on "..resource_balance_category.." "..zone.name, "universe")
    Universe.remove_resource_from_zone_surface(zone, resource_name)
  end

  if zone.plague_used then
    if zone.controls["se-vitamelange"] and zone.controls["se-vitamelange"].richness > 0 then
      zone.controls["se-vitamelange"] = {frequency = 1, size = 0, richness = 0}
      Universe.remove_resource_from_zone_surface(zone, "se-vitamelange")
    end
    zone.controls["enemy-base"] = {frequency = 1, size = 0, richness = 0}
    zone.controls["trees"] = {frequency = 1, size = 0, richness = 0}
    if zone.primary_resource == "se-vitamelange" then
      zone.primary_resource = "coal"
      zone.fragment_name = CoreMiner.resource_to_fragment_name(zone.primary_resource)
      CoreMiner.update_zone_fragment_resources(zone)
    end
  end

  Universe.update_zone_minimum_threat(zone)

  -- if there's still a surface, regenerate those that need it (found earlier)
  if surface then
    local mapgen = surface.map_gen_settings
    Log.debug_log( "build_resources: apply controls to " ..zone.name.." mapgen", "universe")
    Log.debug_log( serpent.block(zone.controls), "universe")
    Zone.apply_controls_to_mapgen(zone, zone.controls, mapgen)
    --Log.debug_log( serpent.block(mapgen), "universe")
    surface.map_gen_settings = mapgen
    if game.tick < 2 then
      for _, resource_name in pairs(resource_order) do
        Universe.remove_resource_from_zone_surface(zone, resource_name)
        surface.regenerate_entity(resource_name)
      end
    else
      for resource_name, fsr_multiplier in pairs(resource_to_rescale) do
        Log.debug_log( "build_resourcess: rescale resource " .. resource_name.." on "..resource_balance_category.." "..zone.name, "universe")
        Universe.rescale_or_regenerate_resource(zone, resource_name, fsr_multiplier)
      end
      for _, resource_name in pairs(resource_to_regenerate) do
        Log.debug_log( "build_resourcess: regenerate resource " .. resource_name.." on "..resource_balance_category.." "..zone.name, "universe")
        if resource_name ~= "se-water-ice" or not zone.ruins then -- exception for nauvis orbit ruin
          for _, resource in pairs(surface.find_entities_filtered{name = resource_name}) do
            resource.destroy()
          end
        end
        surface.regenerate_entity(resource_name)
      end
    end
  end

  zone.new_primary_resource = nil
  zone.new_fragment_name = nil
  zone.resource_bias = nil
  zone.ordered_resource_bias = nil
  zone.strong_claims = nil

end


function Universe.load_resource_data()
  -- called during Universe.build() as part of initial setup
  -- calles as part of on_configuration_changed to see if resource settings have changed.
  -- load data and save to storage for reuse and tracking changes

  -- Gather mod overrides prior to validating homesystem and loading resource data
  Log.debug_log("Triggering on_resource_setting_load event for listeners", "universe")
  Event.trigger("on_resource_setting_load", {})
  for word, rules in pairs(prototypes.mod_data[mod_prefix .. "universe-resource-word-rules"].data) do
    Universe.add_resource_word_rule(word, rules)
  end

  local resources_and_controls = {
    resource_controls = Universe.list_resource_controls(),
    core_fragments = Universe.list_core_fragments(),
    resource_settings = Universe.load_resource_settings(),
    category_resource_properties = table.deepcopy(Universe.category_resource_properties)
  }
  local compare_string = util.table_to_string(resources_and_controls)

  if storage.resources_and_controls_compare_string ~= compare_string then
      if storage.resources_and_controls -- if there are no old settings don't display the message
        --or (storage.resources_and_controls and storage.resources_and_controls.planet_resources) -- change is expected, old settings are legacy
        then
          game.print({"space-exploration.universe-resources-changed-warning"})
      end
      log( "Resource settings mismatch: Resource rebuild required. (Destructive)")
      Log.debug_log( "Old settings: " .. (storage.resources_and_controls_compare_string or "nil"),"universe")
      Log.debug_log( "New settings: " .. compare_string,"universe")

      --helpers.write_file("space-exploration.old_resources_and_controls_compare_string.lua", serpent.dump(storage.resources_and_controls_compare_string, {comment=false, sparse=true, indent = "\t", nocode=true, name="old_resources_and_controls_compare_string"}), false)

      --helpers.write_file("space-exploration.new_resources_and_controls.lua", serpent.dump(resources_and_controls, {comment=false, sparse=true, indent = "\t", nocode=true, name="storage"}), false)

      -- keep a record of old value for comparison
      local old_resources_and_controls = storage.resources_and_controls
      local old_resources_and_controls_compare_string = storage.resources_and_controls_compare_string
      storage.resources_and_controls = resources_and_controls
      storage.resources_and_controls_compare_string = compare_string

      Universe.build_resources()
  else
    storage.resources_and_controls = resources_and_controls
    storage.resources_and_controls_compare_string = compare_string
  end

end

---@param zone_control AutoplaceControl
---@return integer
function Universe.estimate_resource_fsr(zone_control)
  -- estimate the resource yeild.
  local f = zone_control.frequency or 1
  local s = zone_control.size or 1
  local r = zone_control.richness or 1
  return f * s * r
end

---@param zone_tags Tags
---@param new_tag string
---@param override boolean
function Universe.add_tag(zone_tags, new_tag, override)
  local u = string.find(new_tag, "_")
  local tag_domain = string.sub(new_tag, 1, u-1)
  if override or not zone_tags[tag_domain] then
    zone_tags[tag_domain] = new_tag
  end
end

---@param controls {[string]:AutoplaceControl}
---@param tags string[]
---@return {[string]:AutoplaceControl}
function Universe.apply_control_tags(controls, tags)
  if not tags then return controls end
  for _, tag in pairs(tags) do
    local control_settings = Universe.control_settings_from_tag[tag]
    if control_settings then
      for setting_key, setting_value in pairs(control_settings) do
        controls[setting_key] = util.deep_copy(setting_value) -- Deep copy as these can sometimes be modified later e.g. vitamelange affects enemy-base
      end
    else
      error("Invalid tag: " .. tag)
    end
  end
  return controls
end

---@param unorded_tags table
---@return Tags
function Universe.process_unordered_tags(unorded_tags)
  local ordered_tags = {}
  for _, tag in pairs(unorded_tags) do
    local u = string.find(tag, "_")
    local tag_domain = string.sub(tag, 1, u-1)
    ordered_tags[tag_domain] = tag
  end
  return ordered_tags
end

---unused
---@param control AutoplaceControl
---@param fsr_multiplier number
function Universe.multiply_sfr(control, fsr_multiplier)
  local split_mult = fsr_multiplier ^ 0.5
  control.size = control.size * split_mult
  control.richness = control.richness * split_mult
end

---@param zone AnyZoneType|StarType
---@return string
function Universe.get_zone_resource_balance_category(zone) -- used to balance resource specilisations within zones that can support them
  if zone.is_homeworld then return "homeworld" end
  if Zone.is_solid(zone) then return "planet" end
  if zone.type == "orbit" or zone.type == "star" then return "orbit" end
  if zone.type == "anomaly" then return "anomaly" end
  if zone.type == "asteroid-belt" then return "asteroid-belt" end
  if zone.type == "asteroid-field" then return "asteroid-field" end
  error("unknown zone_resource_balance_category for zone.type: " .. zone.type)
end

---@param name string
---@return AnyZoneType
function Universe.get_zone_prototype(name)
  return UniverseRaw.prototypes_by_name[name] or {}
end

---@param zone AnyZoneType|StarType
function Universe.inflate_climate_controls(zone)
  -- avoid resource stuff here.
  if not zone.seed then zone.seed = storage.universe_rng(4294967295) end
  local crng = game.create_random_generator(zone.seed)

  if zone.is_homeworld then return end

  if zone.type == "planet" or zone.type == "moon" then
    ---@cast zone PlanetType|MoonType

    local prototype = Universe.get_zone_prototype(zone.name)

    -- nauvis is 25000
    if not zone.ticks_per_day then
      zone.ticks_per_day = 25000 -- nauvis
      if (zone.name ~= "Nauvis" and zone.is_homeworld ~= true) then
        if crng() < 0.5 then
          zone.ticks_per_day = 60*60 + crng(60*60*59) -- 1 - 60 minutes
        else
          zone.ticks_per_day = 60*60 + crng(60*60*19) -- 1 - 20 minutes
        end
      end
    end

    if not zone.biome_replacements then
      zone.biome_replacements = prototype.biome_replacements and table.deepcopy(prototype.biome_replacements) or {}
    end
    if zone.biome_replacements and not zone.tile_replacements then
      Zone.build_tile_replacements(zone)
    end


    -- apply prototype settings
    if not (zone.tags and zone.tags.temperature) then -- not new format
      if zone.tags and zone.tags[0] then -- has tags in new format
        zone.tags = Universe.process_unordered_tags(zone.tags)
      elseif prototype.tags then
        zone.tags = Universe.process_unordered_tags(table.deepcopy(prototype.tags))
      else
        zone.tags = {}
      end
    end

    if not zone.tags.temperature then
      zone.tags.temperature = Universe.temperature_tags[crng(#Universe.temperature_tags)]
    end
    if not (zone.tags.water and zone.tags.moisture and zone.tags.trees) then

      -- water, moisture and trees are usually linked but not always
      local rng_water = 1
      local rng_moisture = 1
      local rng_trees = 1
      if crng() < 0.75 then
        rng_water = crng(1, 5)
        rng_moisture = rng_water
        if crng() < 0.5 then
          rng_moisture = crng(1, 5)
        end
        rng_trees = rng_moisture
        if crng() < 0.5 then
          rng_trees = crng(1, 5)
        end
      end
      rng_trees = math.min(rng_trees, crng(1, 5))

      if not zone.tags.water then
        zone.tags.water = Universe.water_tags[rng_water]
      end
      if not zone.tags.moisture then
        zone.tags.moisture = Universe.moisture_tags[rng_moisture]
      end
      if not zone.tags.trees then
        zone.tags.trees = Universe.trees_tags[rng_trees]
      end
    end
    if not zone.tags.enemy then
      zone.tags.enemy = Universe.enemy_tags[crng(#Universe.enemy_tags)]
    end
    if not zone.tags.aux then
      zone.tags.aux = Universe.aux_tags[crng(#Universe.aux_tags)]
    end
    if not zone.tags.cliff then
      zone.tags.cliff = Universe.cliff_tags[crng(#Universe.cliff_tags)]
    end

    if not zone.controls then
      zone.controls = {}
    end
    local tag_controls = Universe.apply_control_tags({}, zone.tags)
    zone.controls = util.overwrite_table(zone.controls, tag_controls) -- climate controls win
    if prototype.controls then
      util.overwrite_table(zone.controls, table.deepcopy(prototype.controls)) -- prototype controls win
    end

    -- fallback
    for _, control in pairs(prototypes.autoplace_control) do
      if control.category == "resource" and not zone.controls[control] then
        zone.controls[control] = {frequency = 1, size = 0, richness = 0}
      end
    end

  else -- some sort of space place
    ------------------------------------------------------------------------------
    local prototype = Universe.get_zone_prototype(zone.name)
    if zone.type == "orbit" then
      ---@cast zone OrbitType
      prototype = Universe.get_zone_prototype(zone.parent.name)
    end

    if not zone.controls then
      zone.controls = prototype.controls and table.deepcopy(prototype.controls) or {}
    end
    local tag_controls = Universe.apply_control_tags({}, zone.tags)
    zone.controls = util.overwrite_table(tag_controls, zone.controls) -- exisitng controls win
    zone.controls.tree = {frequency = 1, size = 0, richness = 0}

    -- fallback
    for _, control in pairs(prototypes.autoplace_control) do
      if control.category == "resource" and not zone.controls[control] then
        zone.controls[control] = {frequency = 1, size = 0, richness = 0}
      end
    end

  end

end

---@return string[]
function Universe.list_resource_controls()
  local resource_controls = {}
  for _, control in pairs(prototypes.autoplace_control) do
    if control.category == "resource" then
      table.insert(resource_controls, control.name)
    end
  end
  return resource_controls
end

---@return string[]
function Universe.list_core_fragments()
  local core_fragments = {}
  for name, proto in pairs(prototypes.item) do
    if proto.localised_name and proto.localised_name[1]
      and proto.localised_name[1] == "item-name.core-fragment" then
      table.insert(core_fragments, name)
    end
  end
  table.sort(core_fragments)
  return core_fragments
end

---@return {[string]:table}
function Universe.load_resource_settings()
  local resource_settings = {}
  local resource_prototypes = prototypes.get_entity_filtered({{filter="type", type="resource"}, {mode="and", filter="autoplace"}})
  for _, resource_proto in pairs(resource_prototypes) do
    if not Shared.resources_with_shared_controls[resource_proto.name] -- pretend it is not here if based on something else
      then -- not disabled

        if not prototypes.autoplace_control[resource_proto.name] then
          error("Error: autoplace_control not found for " .. resource_proto.name .. ".")
        end

        local resource_setting = {
            name = resource_proto.name,
            allowed_for_zone = {
              ["homeworld"] = true,
              ["planet"] = true, -- includes moons
              ["orbit"] = true,
              ["asteroid-belt"] = true,
              ["asteroid-field"] = true
            },
            core_fragment = nil, -- fragment name if matches pattern
            can_be_primary = true, --provided by override. -- only false for things like water pools
            tags_required_for_presence = nil, --provided by override.
            tags_required_for_primary = nil, --provided by override.
            yeild_affected_by = nil --provided by override. if climate affects yeild (eg. only appears on snow)
        }

        for _, word in pairs(Universe.resource_word_rules.not_space) do
          if string.find(resource_proto.name, word, 1, true) then
            resource_setting.allowed_for_zone["orbit"] = false
            resource_setting.allowed_for_zone["asteroid-belt"] = false
            resource_setting.allowed_for_zone["asteroid-field"] = false
          end
        end
        if resource_setting.allowed_for_zone["orbit"] then
          for _, word in pairs(Universe.resource_word_rules.not_orbit) do
            if string.find(resource_proto.name, word, 1, true) then
              resource_setting.allowed_for_zone["orbit"] = false
            end
          end
        end
        if resource_setting.allowed_for_zone["asteroid-belt"] then
          for _, word in pairs(Universe.resource_word_rules.not_asteroid_belt) do
            if string.find(resource_proto.name, word, 1, true) then
              resource_setting.allowed_for_zone["asteroid-belt"] = false
            end
          end
        end
        if resource_setting.allowed_for_zone["asteroid-field"] then
          for _, word in pairs(Universe.resource_word_rules.not_asteroid_field) do
            if string.find(resource_proto.name, word, 1, true) then
              resource_setting.allowed_for_zone["asteroid-field"] = false
            end
          end
        end

        for _, word in pairs(Universe.resource_word_rules.not_planet) do
          if string.find(resource_proto.name, word, 1, true) then
            resource_setting.allowed_for_zone["planet"] = false
            resource_setting.allowed_for_zone["homeworld"] = false
          end
        end
        if resource_setting.allowed_for_zone["homeworld"] then
          for _, word in pairs(Universe.resource_word_rules.not_homeworld) do
            if string.find(resource_proto.name, word, 1, true) then
              resource_setting.allowed_for_zone["homeworld"] = false
            end
          end
        end

        if prototypes.item[util.mod_prefix .. "core-fragment-" .. resource_setting.name] then
          resource_setting.core_fragment = util.mod_prefix .. "core-fragment-" .. resource_setting.name
        end

        if Universe.resource_setting_overrides[resource_setting.name] then
          for key, override in pairs(Universe.resource_setting_overrides[resource_setting.name]) do
            if key == "allowed_for_zone" then -- don't overwite table with partial table
              for key2, override2 in pairs(override) do
                resource_setting[key][key2] = override2
              end
            else
              resource_setting[key] = override
            end
          end
        end

        resource_settings[resource_setting.name] = resource_setting
    end
  end
  return resource_settings
end

---@param zone AnyZoneType
---@param resource string
function Universe.remove_resource_from_zone_surface(zone, resource)
  if resource and prototypes.entity[resource] then
    local surface = Zone.get_surface(zone)
    if surface then
      Log.debug_log("remove_resource_from_zone_surface: " .. zone.name .. " (" .. zone.type .. ") ".. resource,"universe")
      for _, resource in pairs(surface.find_entities_filtered{name = resource}) do
        resource.destroy()
      end
    end
  end
end

---@param zone AnyZoneType
---@param resource_name string
---@param fsr_multiplier float
function Universe.rescale_or_regenerate_resource(zone, resource_name, fsr_multiplier)
  local surface = Zone.get_surface(zone)
  if not surface and resource_name then
    Log.debug_log("rescale_or_regenerate_resource: " .. zone.name .. " (" .. zone.type .. ") " .. resource_name .. " (no surface to update)","universe")
    return
  end

  local entities = surface.find_entities_filtered{type = "resource", name=resource_name}
  if next(entities) then
    Log.debug_log("rescale_or_regenerate_resource: ".. zone.name .. " (" .. zone.type .. ") " .. resource_name .. " * " .. fsr_multiplier,"universe")
    for _, entity in pairs(entities) do
      local amount = math.ceil(entity.amount * fsr_multiplier)
      if amount > 0 then
        entity.amount = amount
      else
        entity.destroy()
      end
    end
  else
    Log.debug_log("rescale_or_regenerate_resource: " .. zone.name .. " (" .. zone.type .. ") " .. resource_name .. " (regenerate)","universe")
    surface.regenerate_entity(resource_name)
  end
end

---@param tbl table[]
function Universe.shuffle(tbl)
  -- storage.universe_rng should always be re-assigned at the start of Universe.build
  util.shuffle_with_generator(tbl, storage.universe_rng)
end

---@param zone AnyZoneType
function Universe.fit_climate_to_primary_resource(zone)
  local crng = game.create_random_generator(zone.seed)
  local resource_setting = storage.resources_and_controls.resource_settings[zone.primary_resource]
  local tags_required = resource_setting.tags_required_for_primary or resource_setting.tags_required_for_presence
  local new_tag = tags_required[crng(#tags_required)]
  Universe.add_tag(zone.tags, new_tag, true)
  local override_climate_tags = {}
  Universe.add_tag(override_climate_tags, new_tag, true)
  local tag_controls = Universe.apply_control_tags({}, override_climate_tags)
  zone.controls = util.overwrite_table(zone.controls, tag_controls) -- climate controls win
  local surface = Zone.get_surface(zone)
  if surface then
    Zone.delete_surface(zone)
    surface = Zone.get_surface(zone)
    if surface then -- can't delete
      local mapgen = surface.map_gen_settings
      Zone.apply_controls_to_mapgen(zone, tag_controls, mapgen)
      surface.map_gen_settings = mapgen
      game.print(zone.name.." primary resource changed and the climate has been affected. If hard edges appear in the terrain generation use the Regenerate Terrain mod on the surface.")
    end
  end
end

---@param star StarType
function Universe.star_gravity_well_distribute(star)
  star.star_gravity_well = 10 + #star.children + star.index / 1000
  Zone.calculate_base_bot_attrition(star.orbit) -- Recalculate orbit attrition after changing gravity wells
  Log.debug_log("star_gravity_well_distribute " .. star.name .." star_gravity_well "..star.star_gravity_well, "universe")
  for c, child in pairs(star.children) do
    child.star_gravity_well = star.star_gravity_well * (0.05 + 0.8 * (#star.children - c) / #star.children)
    Log.debug_log("star_gravity_well_distribute " .. child.name .." star_gravity_well "..child.star_gravity_well , "universe")
    if child.children then
      Universe.planet_gravity_well_distribute(child)
    end
  end
end

---@param planet PlanetType
function Universe.planet_gravity_well_distribute(planet)
  planet.planet_gravity_well = 10 * (1 + planet.radius_multiplier) + #planet.children -- 12-20 + n_children = 13 to 26
  Zone.calculate_base_bot_attrition(planet.orbit) -- Recalculate orbit attrition after changing gravity wells
  for m, moon in pairs(planet.children) do
    moon.star_gravity_well = planet.star_gravity_well
    moon.planet_gravity_well = planet.planet_gravity_well * (#planet.children - m + 1) / (#planet.children + 2)
    Zone.calculate_base_bot_attrition(moon.orbit)
  end
end

function Universe.set_hierarchy_values()
  -- zone.hierarchy_index for quick sorting in zone lists
  local list = {}
  table.insert(list, storage.universe.anomaly)
  local temp = {}
  for _, star in pairs(storage.universe.stars) do
    table.insert(temp, star)
  end
  table.sort(temp, function(a,b) return a.name < b.name end)
  for _, star in pairs(temp) do
    table.insert(list, star)
    table.insert(list, star.orbit)
    for _, planet_or_belt in pairs(star.children) do
      table.insert(list, planet_or_belt)
      if planet_or_belt.orbit then
        table.insert(list, planet_or_belt.orbit)
      end
      if planet_or_belt.children then
        for _, moon in pairs(planet_or_belt.children) do
          table.insert(list, moon)
          table.insert(list, moon.orbit)
        end
      end
    end
  end
  temp = {}
  for _, zone in pairs(storage.universe.space_zones) do
    table.insert(temp, zone)
  end
  table.sort(temp, function(a,b) return a.name < b.name end)
  for _, zone in pairs(temp) do
    table.insert(list, zone)
  end
  for i, zone in pairs(list) do
    zone.hierarchy_index = i
  end
end

---Updates a given zone's minimum threat if it contains vitamelange, also applies to existing surface if any
---@param zone AnyZoneType|StarType
function Universe.update_zone_minimum_threat(zone)
  if zone.controls["se-vitamelange"] and zone.controls["se-vitamelange"].richness > 0 then
    -- min threat, they like the spice
    zone.controls["enemy-base"]=zone.controls["enemy-base"] or {frequency=0.5, size=0.5, richness = 0.5}
    zone.controls["enemy-base"].frequency = math.max(zone.controls["enemy-base"].frequency, 0.5)
    zone.controls["enemy-base"].size = math.max(zone.controls["enemy-base"].size, 0.5)
    zone.controls["enemy-base"].richness = math.max(zone.controls["enemy-base"].richness, 0.5)
  end
  Zone.apply_controls_to_mapgen_if_existing_surface(zone)
end

---@param update_existing_surfaces false
function Universe.update_zones_minimum_threat(update_existing_surfaces)
  for _, zone in pairs(storage.zone_index) do
    if update_existing_surfaces ~= false or not zone.surface_index then
      Universe.update_zone_minimum_threat(zone)
    end
  end
end

return Universe
