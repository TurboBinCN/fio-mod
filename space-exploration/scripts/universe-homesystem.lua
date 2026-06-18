local UniverseHomesystem = {}

UniverseHomesystem.guaranteed_special_types = {
  ["haven"] = {
    type = "moon",
    primary_resource = "crude-oil",
    restrictions = {
      "parent_is_homeworld",
      "first_moon"
    },
    fallback = function(requirement, homeworld, other_planets, other_asteroid_belts)
      Log.debug_log("make_validate_homesystem - homeworld does not have a haven moon.", "universe")
      UniverseHomesystem.add_special_moon(homeworld, "haven", UniverseRaw.haven_moons)
      return homeworld.children[1]
    end
  },
  ["vulcanite"] = {
    type = "planet",
    primary_resource = mod_prefix.."vulcanite",
    fallback = function(requirement, homeworld, other_planets, other_asteroid_belts)
      -- make a new planet 1.
      Log.debug_log("make_validate_homesystem - homesystem does not have a vulcanite planet", "universe")
      local protoplanets = table.deepcopy(UniverseRaw.vulcanite_planets)
      Universe.shuffle(protoplanets)
      local new_planet = nil
      for _, protoplanet in pairs(protoplanets) do
        if not storage.zones_by_name[protoplanet.name] then
          new_planet = protoplanet
        end
      end
      if new_planet then
        Log.debug_log("make_validate_homesystem - Making new planet for vulcanite", "universe")
        table.insert(homeworld.parent.children, 1, new_planet)
        new_planet.type = "planet"
        new_planet.special_type = "vulcanite"
        new_planet.parent = homeworld.parent
        new_planet.radius_multiplier = new_planet.radius_multiplier or 0.3
        new_planet.radius = Universe.planet_max_radius * new_planet.radius_multiplier
        new_planet.climate = new_planet.climate or {}
        new_planet.seed = storage.universe_rng(4294967295)
        new_planet.children = {}
        Universe.add_zone(storage.zone_index, storage.zones_by_name, new_planet)

        new_planet.orbit = {
          type = "orbit",
          name = new_planet.name .. " Orbit",
          parent = new_planet,
          seed = storage.universe_rng(4294967295),
        }
        Universe.add_zone(storage.zone_index, storage.zones_by_name, new_planet.orbit)
        return new_planet
      end
    end
  },
  ["vitamelange"] = {
    type = "moon",
    primary_resource = mod_prefix.."vitamelange",
    restrictions = {
      "parent_not_special",
      "first_moon"
    },
    fallback = function(requirement, homeworld, other_planets, other_asteroid_belts)
      Log.debug_log("make_validate_homesystem - homesystem does not have a vitamelange moon", "universe")
      local planet
      if next(other_planets) then
        planet = other_planets[1]
        table.remove(other_planets, 1)
        Log.debug_log("make_validate_homesystem - Selecting existing planet for vitamelange moon: "..planet.name, "universe")
      else
        Log.debug_log("make_validate_homesystem - No existing planet available for vitamelange moon, creating new one.", "universe")
        planet = UniverseHomesystem.make_generic_planet(homeworld.parent)
      end
      UniverseHomesystem.add_special_moon(planet, "vitamelange", UniverseRaw.vitamelange_moons)
      return planet.children[1]
    end
  },
  ["iridium"] = {
    type = "moon",
    primary_resource = mod_prefix.."iridium-ore",
    restrictions = {
      "parent_not_special",
      "first_moon"
    },
    fallback = function(requirement, homeworld, other_planets, other_asteroid_belts)
      Log.debug_log("make_validate_homesystem - homesystem does not have a iridium moon", "universe")
      local planet
      if next(other_planets) then
        planet = other_planets[1]
        table.remove(other_planets, 1)
        Log.debug_log("make_validate_homesystem - Selecting existing planet for iridium moon: "..planet.name, "universe")
      else
        Log.debug_log("make_validate_homesystem - No existing planet available for iridium moon, creating new one.", "universe")
        planet = UniverseHomesystem.make_generic_planet(homeworld.parent)
      end
      UniverseHomesystem.add_special_moon(planet, "iridium", UniverseRaw.iridium_moons)
      return planet.children[1]
    end
  },
  ["holmium"] = {
    type = "moon",
    primary_resource = mod_prefix.."holmium-ore",
    restrictions = {
      "parent_not_special",
      "first_moon"
    },
    fallback = function(requirement, homeworld, other_planets, other_asteroid_belts)
      Log.debug_log("make_validate_homesystem - homesystem does not have a holmium moon", "universe")
      local planet
      if next(other_planets) then
        planet = other_planets[1]
        table.remove(other_planets, 1)
        Log.debug_log("make_validate_homesystem - Selecting existing planet for holmium moon: "..planet.name, "universe")
      else
        Log.debug_log("make_validate_homesystem - No existing planet available for holmium moon, creating new one.", "universe")
        planet = UniverseHomesystem.make_generic_planet(homeworld.parent)
      end
      UniverseHomesystem.add_special_moon(planet, "holmium", UniverseRaw.holmium_moons)
      return planet.children[1]
    end
  },
  ["cryonite"] = {
    type = "moon",
    primary_resource = mod_prefix.."cryonite",
    restrictions = {
      "parent_not_special",
      "first_moon"
    },
    fallback = function(requirement, homeworld, other_planets, other_asteroid_belts)
      Log.debug_log("make_validate_homesystem - homesystem does not have a cryonite moon", "universe")
      local planet
      if next(other_planets) then
        planet = other_planets[1]
        table.remove(other_planets, 1)
        Log.debug_log("make_validate_homesystem - Selecting existing planet for cryonite moon: "..planet.name, "universe")
      else
        Log.debug_log("make_validate_homesystem - No existing planet available for cryonite moon, creating new one.", "universe")
        planet = UniverseHomesystem.make_generic_planet(homeworld.parent)
      end
      UniverseHomesystem.add_special_moon(planet, "cryonite", UniverseRaw.cryonite_moons)
      return planet.children[1]
    end
  },
  ["beryllium"] = {
    type = "asteroid-belt",
    primary_resource = mod_prefix.."beryllium-ore",
    fallback = function(requirement, homeworld, other_planets, other_asteroid_belts)
      Log.debug_log("make_validate_homesystem - homesystem does not have a beryllium belt", "universe")
      local belt
      if next(other_asteroid_belts) then
        belt = other_asteroid_belts[1]
        table.remove(other_asteroid_belts, 1)
        Log.debug_log("make_validate_homesystem - Selecting existing belt for beryllium belt: "..belt.name, "universe")
      else
        belt = UniverseHomesystem.make_generic_belt(homeworld.parent)
      end
      belt.special_type = "beryllium"
      if belt.primary_resource then -- do not proceed if universe resources are not inflated
        local resource = mod_prefix.."beryllium-ore"
        if belt.primary_resource ~= resource then
          belt.new_primary_resource = resource
          Universe.apply_zone_resource_assignments(belt)
        end
      end
      return belt
    end
  },
  ["methane"] = {
    type = "asteroid-belt",
    primary_resource = mod_prefix.."methane-ice",
    fallback = function(requirement, homeworld, other_planets, other_asteroid_belts)
      Log.debug_log("make_validate_homesystem - homesystem does not have a methane ice belt", "universe")
      local belt
      if next(other_asteroid_belts) then
        belt = other_asteroid_belts[1]
        table.remove(other_asteroid_belts, 1)
        Log.debug_log("make_validate_homesystem - Selecting existing belt for beryllium belt: "..belt.name, "universe")
      else
        belt = UniverseHomesystem.make_generic_belt(homeworld.parent)
      end
      belt.special_type = "methane"
      if belt.primary_resource then -- do not proceed if universe resources are not inflated
        local resource = mod_prefix.."methane-ice"
        if belt.primary_resource ~= resource then
          belt.new_primary_resource = resource
          Universe.apply_zone_resource_assignments(belt)
        end
      end
      return belt
    end
  },
}

-- Adds a new request for a homesystem body, used to guarantee a primary of a resource in the homesystem.
-- For a mods requests, only call this inside compatibility scripts conditioned on script.active_mods[<mod>]
---@param special_type string A entry from the special types table of resources. Must be unique.
---@param type "planet"|"moon"|"planet-or-moon" Whether the requested homesystem body should be a planet or a moon.
---@param fallback_function function A fallback function that creates a new zone to satisfy this request, it must have the signature function(requirement, homeworld, other_planets, other_asteroid_belts) and must set the zone field of the requirement input
-- The fallback function parameters in order:
-- - requirement: This is the table representation of the requirement created by this function and contains the special_type, type and zone fields
-- - homeworld: This is the homeworld of the homesystem this requirement if being checked against
-- - other_planets: This is a table of planets in the homesystem that have not been used to satisfy other requirements.
-- - other_asteroid_belts: This is a table of asteroid belts in the homesystem that have not been used to statisfy other requirements.
function UniverseHomesystem.add_guaranteed_special_type(special_type, primary_resource, type, fallback_function)
  local new_special_type_requirement = {
    type = type,
    primary_resource = primary_resource,
    -- Fallback function is passed the requriement itself, the homeworld planet, and planets in the homesystem not selected by other requriements
    fallback = fallback_function
  }
  if UniverseHomesystem.validate_special_type_requirement(special_type, new_special_type_requirement) then
    UniverseHomesystem.guaranteed_special_types[special_type] = new_special_type_requirement
  end
end


function UniverseHomesystem.validate_special_type_requirement(key, requirement)
  Log.debug_log("validate_special_type_requirement - Checking request " .. key)
  -- Check that any special type listed matches with an entry in the special type to resource table
  if not key then
    Log.debug_log("validate_special_type_requirement - Unable to accept additional homesystem requirement " .. key .. " due to lack of special_type definition", "universe")
    return false
  end

  -- Check that the type of zone exits and the one requested is one we accept
  if not requirement.type then
    Log.debug_log("validate_special_type_requirement - Unable to accept additional homesystem requirement " .. key .. " due to type not being set", "universe")
    return false
  elseif not (requirement.type == "moon" or requirement.type == "planet" or requirement.type == "planet-or-moon") then
    Log.debug_log("validate_special_type_requirement - Unable to accept additional homesystem requirement " .. key .. " due to type not being recognised", "universe")
    return false
  end

  if not requirement.primary_resource then
    Log.debug_log("validate_special_type_requirement - Unable to accept additional homesystem requirement " .. key .. " due to primary_resource not being set", "universe")
    return false
    -- TODO validate resource name exists?
  end

  if requirement.restrictions then
    for _, restriction in pairs(requirement.restrictions) do
      if not (
            restriction == "first_moon"
        or  restriction == "parent_not_special"
        or  restriction == "parent_is_homeworld"
      ) then
        Log.debug_log("validate_special_type_requirement - Unable to accept additional homesystem requirement " .. key .. " due to restriction not being recognised", "universe")
        return false
      end
    end
  end

  -- Check that a fallback exists
  if not requirement.fallback then
    Log.debug_log("validate_special_type_requirement - Unable to accept additional homesystem requirement " .. key .. " due to no fallback function being specified", "universe")
      return false
  end
  Log.debug_log("validate_special_type_requirement - Additional homesystem requirement " .. key .. " accepted.")
  return true
end

---@param zone AsteroidBeltType|PlanetType|MoonType
---@param requirement any
--- Currently unused, may be used in the future if we want to change the behavior of guaranteed_special_types
--- to try and use existing zones when suitable.
local function is_zone_suitable(zone, requirement_special_type, requirement)
  if not (requirement_special_type == zone.special_type) then -- THIS IS ALWAYS TRUE, what to do?
    return false
  end
  if requirement.type == "planet-or-moon" and zone.type ~= "planet" and zone.type ~= "moon" then
    return false
  elseif not (requirement.type == zone.type) then
    return false
  end
  if requirement.restrictions then
    for i, restriction in pairs(requirement.restrictions) do
      if restriction == "parent_not_special" then
        if zone.parent and zone.parent.special_type then
          return false
        end
      elseif restriction == "first_moon" then
        if not (zone.parent.children[1].name == zone.name) then
          return false
        end
      elseif restriction == "parent_is_homeworld" then
        if not zone.parent.is_homeworld then
          return false
        end
      end
    end
  end
  return true
end


---@param homeworld PlanetType
function UniverseHomesystem.make_validate_homesystem(homeworld)
  Log.debug_log("make_validate_homesystem - Planet: ".. homeworld.name, "universe")

  -- Gather mod overrides prior to validating homesystem
  Log.debug_log("Triggering on_homesystem_make event for listeners", "universe")
  Event.trigger("on_homesystem_make", {})

  -- make sure planet is marked as homeworld
  homeworld.is_homeworld = true
  homeworld.special_type = "homeworld"

  -- make sure system is marked as home system
  local star = homeworld.parent
  star.special_type = "homesystem"
  Log.debug_log("make_validate_homesystem - Star: ".. star.name, "universe")

  -- make sure there are at least 6 planets in the solar systems.
  -- first is small volcanic planet with no moons
  -- second is homeworld
  -- third has vitamelange moon
  -- beryllium asteroid belt
  -- fourth has iridium moon
  -- fifth has holmium moon
  -- RANDOM EXCESS
  -- last has a cryonite moon
  -- methane ice asteroid belt 2

  local chosen_zones = {}
  local available_zones = { -- Keyed by type
    ["planet"] = {},
    ["moon"] = {},  -- Unused yet
    ["asteroid-belt"] = {},
  }

  -- Step 1, Gather what we're working with: existing special_types, available planets/moons/belts
  for _, zone in pairs(star.children) do
    if zone.special_type then
      Log.debug_log("make_validate_homesystem - found  " .. zone.special_type .. ": " .. zone.name, "universe")
      chosen_zones[zone.special_type] = zone
    else
      table.insert(available_zones[zone.type], zone)
      -- if zone.children then
      --   for _, moon in pairs(zone.children) do
      --     if zone.special_type then
      --       Log.debug_log("make_validate_homesystem - found  " .. moon.special_type .. ": " .. moon.name, "universe")
      --       chosen_zones[moon.special_type] = moon
      --     else
      --       table.insert(available_zones[moon.type], moon)
      --     end
      --   end
      -- end
    end
  end

  -- Step 2, Find existing zones that may be suitable to become a special_type.
  -- Currently we skip this step, no existing zones are reused, except asteroid belts (inside their fallback functions).
  -- We may revisit this at the next opportunity that changes universe seed (e.g. Patron planet additions).

  -- Step 3, For each missing requirement, run the fallback function to create a new zone.
  -- Note belt fallback functions also check for existing belt suitability, this can be refactored when we implement Step 2.
  for requirement_special_type, requirement in pairs(UniverseHomesystem.guaranteed_special_types) do
    Log.debug_log("make_validate_homesystem - requirement " .. requirement_special_type .. " now being checked", "universe")
    if not chosen_zones[requirement_special_type] then
      if (requirement.fallback) then
        chosen_zones[requirement_special_type] = requirement.fallback(requirement, homeworld, available_zones["planet"], available_zones["asteroid-belt"])
      else
        Log.debug_log("make_validate_homesystem - requirement unsatisfied without fallback function ", "universe" )
      end
    end
  end

  -- put the solar system back together
  star.children = {}
  table.insert(star.children, chosen_zones["vulcanite"])
  table.insert(star.children, homeworld)
  table.insert(star.children, chosen_zones["vitamelange"].parent)
  table.insert(star.children, chosen_zones["beryllium"])
  table.insert(star.children, chosen_zones["iridium"].parent)
  table.insert(star.children, chosen_zones["holmium"].parent)
  for _, p in pairs(available_zones["planet"]) do
    table.insert(star.children, p)
  end
  table.insert(star.children, chosen_zones["cryonite"].parent)
  table.insert(star.children, chosen_zones["methane"])
  for _, b in pairs(available_zones["asteroid-belt"]) do
    table.insert(star.children, b)
  end
  Universe.star_gravity_well_distribute(star)
end


---@param star StarType
---@param index? uint unused
---@return PlanetType?
function UniverseHomesystem.make_generic_planet(star, index)
  Log.debug_log("make_generic_planet - New planet for star: "..star.name, "universe")
  local protoplanets = table.deepcopy(UniverseRaw.unassigned_planets_or_moons)
  Universe.shuffle(protoplanets) -- TODO: Constant reshuffling every new zone is not great
  local new_planet = nil
  for _, protoplanet in pairs(protoplanets) do
    if not storage.zones_by_name[protoplanet.name] then
      new_planet = protoplanet
    end
  end
  if new_planet then
    local planet_prototype = table.deepcopy(new_planet)
    if index then
      table.insert(star.children, index, new_planet)
    else
      table.insert(star.children, new_planet)
    end
    new_planet.type = "planet"
    new_planet.parent = star
    new_planet.radius_multiplier = 0.4 + 0.6 * storage.universe_rng() ^ 2 -- need to consistently call rng even if prototype.radius_multiplier is defined
    if planet_prototype and planet_prototype.radius_multiplier then
      new_planet.radius_multiplier = planet_prototype.radius_multiplier
    end
    new_planet.radius = Universe.planet_max_radius * new_planet.radius_multiplier
    new_planet.climate = new_planet.climate or {}
    new_planet.seed = storage.universe_rng(4294967295)
    new_planet.children = {}
    Universe.add_zone(storage.zone_index, storage.zones_by_name, new_planet)
    Log.debug_log("make_generic_planet - New planet: "..new_planet.name.." index: "..new_planet.index, "universe")

    new_planet.orbit = {
      type = "orbit",
      name = new_planet.name .. " Orbit",
      parent = new_planet,
      seed = storage.universe_rng(4294967295),
    }
    Universe.add_zone(storage.zone_index, storage.zones_by_name, new_planet.orbit)
    Log.debug_log("make_generic_planet - New planet orbit: "..new_planet.orbit.name.." index: "..new_planet.orbit.index, "universe")

    Universe.star_gravity_well_distribute(star)
    return new_planet
  end
end



---@param parent_planet PlanetType
---@param special_type string
---@param special_list MoonType[]
function UniverseHomesystem.add_special_moon(parent_planet, special_type, special_list)
  Log.debug_log("add_special_moon - New special moon for planet: "..parent_planet.name.." ("..special_type..")", "universe")
  local protomoons = table.deepcopy(special_list)
  Universe.shuffle(protomoons)
  local new_moon = nil
  for _, protomoon in pairs(protomoons) do
    if protomoon and not storage.zones_by_name[protomoon.name] then
      new_moon = protomoon
    end
  end
  if new_moon then
    table.insert(parent_planet.children, 1, new_moon)
    new_moon.type = "moon"
    new_moon.special_type = special_type
    new_moon.parent = parent_planet
    new_moon.radius_multiplier = new_moon.radius_multiplier or 0.3
    new_moon.radius = (0.5 * parent_planet.radius + math.min(parent_planet.radius, Universe.planet_max_radius / 2)) / 2 * new_moon.radius_multiplier -- special moons can't be as big
    new_moon.climate = new_moon.climate or {}
    new_moon.seed = storage.universe_rng(4294967295)
    Universe.add_zone(storage.zone_index, storage.zones_by_name, new_moon)
    Log.debug_log("add_special_moon - New special moon: "..new_moon.name.." index: "..new_moon.index, "universe")

    new_moon.orbit = {
      type = "orbit",
      name = new_moon.name .. " Orbit",
      parent = new_moon,
      seed = storage.universe_rng(4294967295),
    }
    Universe.add_zone(storage.zone_index, storage.zones_by_name, new_moon.orbit)
    Log.debug_log("add_special_moon - New special moon orbit "..new_moon.orbit.name.." index: "..new_moon.orbit.index, "universe")
    Universe.planet_gravity_well_distribute(parent_planet)
  end
end

function UniverseHomesystem.add_special_moon_from_unassigned(parent_planet, special_type)
  Log.debug_log("add_special_moon_from_unassigned - New special moon for planet: "..parent_planet.name.." ("..special_type..")", "universe")
  local protomoons = table.deepcopy(UniverseRaw.unassigned_planets_or_moons)
  Universe.shuffle(protomoons)
  local new_moon = nil
  for _, protomoon in pairs(protomoons) do
    if not storage.zones_by_name[protomoon.name] and not protomoon.primary_resource then
      new_moon = protomoon
      break
    end
  end

  if new_moon then
    table.insert(parent_planet.children, 1, new_moon)
    new_moon.type = "moon"
    new_moon.special_type = special_type
    new_moon.parent = parent_planet
    new_moon.radius_multiplier = new_moon.radius_multiplier or 0.3
    new_moon.radius = (0.5 * parent_planet.radius + math.min(parent_planet.radius, Universe.planet_max_radius / 2)) / 2 * new_moon.radius_multiplier * (storage.universe_rng(80,120)/100) -- special moons can't be as big
    new_moon.climate = new_moon.climate or {}
    new_moon.seed = storage.universe_rng(4294967295)
    Universe.add_zone(storage.zone_index, storage.zones_by_name, new_moon)
    Log.debug_log("add_special_moon_from_unassigned - New special moon: "..new_moon.name.." index: "..new_moon.index, "universe")

    new_moon.orbit = {
      type = "orbit",
      name = new_moon.name .. " Orbit",
      parent = new_moon,
      seed = storage.universe_rng(4294967295),
    }
    Universe.add_zone(storage.zone_index, storage.zones_by_name, new_moon.orbit)
    Log.debug_log("add_special_moon_from_unassigned - New special moon orbit "..new_moon.orbit.name.." index: "..new_moon.orbit.index, "universe")
    Universe.planet_gravity_well_distribute(parent_planet)
  else
    Log.debug_log("add_special_moon_from_unassigned - Failed to add new moon due to no available prototypes", "universe")
  end
end

local function nb_belts_in_system(star)
  local belt_prefix = star.name .. " Asteroid Belt "
  for i=1,99 do
    if not storage.zones_by_name[belt_prefix .. i] then
      return i - 1
    end
  end
  error("Couldn't find nb belts in system " .. star.name)
end

function UniverseHomesystem.make_generic_belt(star)
  local nb_belts = nb_belts_in_system(star)
  local belt = {
    type = "asteroid-belt",
    name = star.name .. " Asteroid Belt ".. (nb_belts + 1),
    seed = storage.universe_rng(4294967295),
    parent = star
  }
  Universe.add_zone(storage.zone_index, storage.zones_by_name, belt)
  return belt
end

return UniverseHomesystem
