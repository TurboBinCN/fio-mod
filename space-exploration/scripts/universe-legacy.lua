local UniverseLegacy = {}

local function add_zone(zone_index, zones_by_name, zone)
  Log.debug_log("Adding zone: " ..zone.name)
  table.insert(zone_index, zone)
  zone.index = #zone_index
  zones_by_name[zone.name] = zone
end

UniverseLegacy.special_type_to_resource = {
  beryllium = mod_prefix.."beryllium-ore",
  holmium = mod_prefix.."holmium-ore",
  iridium = mod_prefix.."iridium-ore",
  vitamelange = mod_prefix.."vitamelange",
  cryonite = mod_prefix.."cryonite",
  vulcanite = mod_prefix.."vulcanite",
  methane = mod_prefix.."methane-ice",
  haven = "crude-oil",
}

---@param planet PlanetType
function UniverseLegacy.make_validate_homesystem(planet)
  Log.debug_log("make_validate_homesystem - Planet: ".. planet.name, "universe")

  -- make sure planet is marked as homeworld
  planet.is_homeworld = true
  planet.special_type = "homeworld"

  -- make sure system is marked as home system
  local star = planet.parent
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

  local beryllium_asteroid_belt = nil
  local methane_asteroid_belt = nil
  local other_asteroid_belts = {}
  local belt_count = 0
  local vulcanite_planet = nil
  local vitamelange_parent_planet = nil
  local holmium_parent_planet = nil
  local iridium_parent_planet = nil
  local cryonite_parent_planet = nil
  local other_planets = {}
  local homeworld_index = nil
  for i, child in pairs(star.children) do
    if child.type == "asteroid-belt" then
      if child.special_type == "beryllium" then
        beryllium_asteroid_belt = child
        Log.debug_log("make_validate_homesystem - already has beryllium belt ".. child.name, "universe")
      elseif child.special_type == "methane" then
        methane_asteroid_belt = child
        Log.debug_log("make_validate_homesystem - already has methane ice belt ".. child.name, "universe")
      else
        table.insert(other_asteroid_belts, child)
        Log.debug_log("make_validate_homesystem - generic asteroid belt ".. child.name, "universe")
      end
      belt_count = belt_count + 1
    else
      if child.special_type == "vulcanite" then
        vulcanite_planet = child
        Log.debug_log("make_validate_homesystem - already has vulcanite planet ".. child.name, "universe")
      elseif child.children and child.children[1] and child.children[1].special_type == "vitamelange" then
        vitamelange_parent_planet = child
        Log.debug_log("make_validate_homesystem - already has vitamelange moon ".. child.name .. " > " .. child.children[1].name, "universe")
      elseif child.children and child.children[1] and child.children[1].special_type == "iridium" then
        iridium_parent_planet = child
        Log.debug_log("make_validate_homesystem - already has iridium moon ".. child.name .. " > " .. child.children[1].name, "universe")
      elseif child.children and child.children[1] and child.children[1].special_type == "holmium" then
        holmium_parent_planet = child
        Log.debug_log("make_validate_homesystem - already has holmium moon ".. child.name .. " > " .. child.children[1].name, "universe")
      elseif child.children and child.children[1] and child.children[1].special_type == "cryonite" then
        cryonite_parent_planet = child
        Log.debug_log("make_validate_homesystem - already has cryonite moon ".. child.name .. " > " .. child.children[1].name, "universe")
      elseif child.is_homeworld then
        Log.debug_log("make_validate_homesystem - homeworld located ".. child.name, "universe")
      else
        table.insert(other_planets, child)
        Log.debug_log("make_validate_homesystem - generic planet located ".. child.name, "universe")
      end
    end
  end

  -- make sure the planet has a safe haven moon to escape to
  local first_moon = planet.children[1]
  if first_moon.special_type == "haven" then
    Log.debug_log("make_validate_homesystem - homeworld has a haven moon.", "universe")
  else
    -- add a haven moon
    Log.debug_log("make_validate_homesystem - homeworld does not have a haven moon.", "universe")
    UniverseLegacy.add_special_moon(planet, "haven", UniverseRaw.haven_moons)
  end

  if not vulcanite_planet then
    -- make a new planet 1.
    Log.debug_log("make_validate_homesystem - homesystem does not have a vulcanite planet", "universe")
    local protoplanets = table.deepcopy(UniverseRaw.vulcanite_planets)
    Universe.shuffle(protoplanets)
    local new_planet = nil
    for i = 1, #protoplanets do
      if protoplanets[i] and not storage.zones_by_name[protoplanets[i].name] then
        new_planet = protoplanets[i]
      end
    end
    if new_planet then
      Log.debug_log("make_validate_homesystem - Making new planet for vulcanite", "universe")
      vulcanite_planet = new_planet
      table.insert(star.children, 1, new_planet)
      new_planet.type = "planet"
      new_planet.special_type = "vulcanite"
      new_planet.parent = star
      new_planet.radius_multiplier = new_planet.radius_multiplier or 0.3
      new_planet.radius = Universe.planet_max_radius * new_planet.radius_multiplier
      new_planet.climate = new_planet.climate or {}
      new_planet.seed = storage.universe_rng(4294967295)
      new_planet.children = {}
      add_zone(storage.zone_index, storage.zones_by_name, new_planet)

      new_planet.orbit = {
        type = "orbit",
        name = new_planet.name .. " Orbit",
        parent = new_planet,
        seed = storage.universe_rng(4294967295),
      }
      add_zone(storage.zone_index, storage.zones_by_name, new_planet.orbit)
    end
  end

  if not vitamelange_parent_planet then
    Log.debug_log("make_validate_homesystem - homesystem does not have a vitamelange moon", "universe")
    if #other_planets > 0 then
      vitamelange_parent_planet = other_planets[1]
      table.remove(other_planets, 1)
      Log.debug_log("make_validate_homesystem - Selecting existing planet for vitamelange moon: "..vitamelange_parent_planet.name, "universe")
    else
      Log.debug_log("make_validate_homesystem - No existing planet available for vitamelange moon, creating new one.", "universe")
      vitamelange_parent_planet = UniverseLegacy.make_generic_planet(star)
    end
    UniverseLegacy.add_special_moon(vitamelange_parent_planet, "vitamelange", UniverseRaw.vitamelange_moons)
  end

  if not iridium_parent_planet then
    Log.debug_log("make_validate_homesystem - homesystem does not have a iridium moon", "universe")
    if #other_planets > 0 then
      iridium_parent_planet = other_planets[1]
      table.remove(other_planets, 1)
      Log.debug_log("make_validate_homesystem - Selecting existing planet for iridium moon: "..iridium_parent_planet.name, "universe")
    else
      Log.debug_log("make_validate_homesystem - No existing planet available for iridium moon, creating new one.", "universe")
      iridium_parent_planet = UniverseLegacy.make_generic_planet(star)
    end
    UniverseLegacy.add_special_moon(iridium_parent_planet, "iridium", UniverseRaw.iridium_moons)
  end

  if not holmium_parent_planet then
    Log.debug_log("make_validate_homesystem - homesystem does not have a holmium moon", "universe")
    if #other_planets > 0 then
      holmium_parent_planet = other_planets[1]
      table.remove(other_planets, 1)
      Log.debug_log("make_validate_homesystem - Selecting existing planet for holmium moon: "..holmium_parent_planet.name, "universe")
    else
      Log.debug_log("make_validate_homesystem - No existing planet available for holmium moon, creating new one.", "universe")
      holmium_parent_planet = UniverseLegacy.make_generic_planet(star)
    end
    UniverseLegacy.add_special_moon(holmium_parent_planet, "holmium", UniverseRaw.holmium_moons)
  end

  if not cryonite_parent_planet then
    Log.debug_log("make_validate_homesystem - homesystem does not have a cryonite moon", "universe")
    if #other_planets > 0 then
      cryonite_parent_planet = other_planets[1]
      table.remove(other_planets, 1)
      Log.debug_log("make_validate_homesystem - Selecting existing planet for cryonite moon: "..cryonite_parent_planet.name, "universe")
    else
      Log.debug_log("make_validate_homesystem - No existing planet available for cryonite moon, creating new one.", "universe")
      cryonite_parent_planet = Universe.make_generic_planet(star)
    end
    UniverseLegacy.add_special_moon(cryonite_parent_planet, "cryonite", UniverseRaw.cryonite_moons)
  end

  while belt_count < 2 do
    Log.debug_log("make_validate_homesystem - Not enough asteroid belts, creating new one.", "universe")
    local new_belt = {
      type = "asteroid-belt",
      name = star.name .. " Asteroid Belt ".. (belt_count + 1),
      seed = storage.universe_rng(4294967295),
      parent = star
    }
    add_zone(storage.zone_index, storage.zones_by_name, new_belt)
    table.insert(other_asteroid_belts, new_belt)
    belt_count = belt_count + 1
  end
  if not beryllium_asteroid_belt then
    Log.debug_log("make_validate_homesystem - homesystem does not have a beryllium belt", "universe")
    beryllium_asteroid_belt = other_asteroid_belts[1]
    beryllium_asteroid_belt.special_type = "beryllium"
    if beryllium_asteroid_belt.primary_resource then -- do not proceed if universe resources are not inflated
      local resource = UniverseLegacy.special_type_to_resource[beryllium_asteroid_belt.special_type]
      if beryllium_asteroid_belt.primary_resource ~= resource then
        beryllium_asteroid_belt.new_primary_resource = resource
        Universe.apply_zone_resource_assignments(beryllium_asteroid_belt)
      end
    end
    table.remove(other_asteroid_belts, 1)
  end
  if not methane_asteroid_belt then
    Log.debug_log("make_validate_homesystem - homesystem does not have a methane ice belt", "universe")
    methane_asteroid_belt = other_asteroid_belts[1]
    methane_asteroid_belt.special_type = "methane"
    if methane_asteroid_belt.primary_resource then -- do not proceed if universe resources are not inflated
      local resource = UniverseLegacy.special_type_to_resource[methane_asteroid_belt.special_type]
      if methane_asteroid_belt.primary_resource ~= resource then
        methane_asteroid_belt.new_primary_resource = resource
        Universe.apply_zone_resource_assignments(methane_asteroid_belt)
      end
    end
    table.remove(other_asteroid_belts, 1)
  end

  -- put the solar system back together
  star.children = {}
  table.insert(star.children, vulcanite_planet)
  table.insert(star.children, planet)
  table.insert(star.children, vitamelange_parent_planet)
  table.insert(star.children, beryllium_asteroid_belt)
  table.insert(star.children, iridium_parent_planet)
  table.insert(star.children, holmium_parent_planet)
  for i, p in pairs(other_planets) do
    table.insert(star.children, p)
  end
  table.insert(star.children, cryonite_parent_planet)
  table.insert(star.children, methane_asteroid_belt)
  for i, b in pairs(other_asteroid_belts) do
    table.insert(star.children, b)
  end
  Universe.star_gravity_well_distribute(star)
end

---@param star StarType
---@param index? uint unused
---@return PlanetType?
function UniverseLegacy.make_generic_planet(star, index)
  Log.debug_log("make_generic_planet - New planet for star: "..star.name, "universe")
  local protoplanets = table.deepcopy(UniverseRaw.unassigned_planets_or_moons)
  Universe.shuffle(protoplanets)
  local new_planet = nil
  for i = 1, #protoplanets do
    if protoplanets[i] and not storage.zones_by_name[protoplanets[i].name] then
      new_planet = protoplanets[i]
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
    new_planet.radius_multiplier = 0.4 + 0.6 * math.pow(storage.universe_rng(), 2) -- need to consistently call rng even if prototype.radius_multiplier is defined
    if planet_prototype and planet_prototype.radius_multiplier then
      new_planet.radius_multiplier = planet_prototype.radius_multiplier
    end
    new_planet.radius = Universe.planet_max_radius * new_planet.radius_multiplier
    new_planet.climate = new_planet.climate or {}
    new_planet.seed = storage.universe_rng(4294967295)
    new_planet.children = {}
    add_zone(storage.zone_index, storage.zones_by_name, new_planet)
    Log.debug_log("make_generic_planet - New planet: "..new_planet.name.." index: "..new_planet.index, "universe")

    new_planet.orbit = {
      type = "orbit",
      name = new_planet.name .. " Orbit",
      parent = new_planet,
      seed = storage.universe_rng(4294967295),
    }
    add_zone(storage.zone_index, storage.zones_by_name, new_planet.orbit)
    Log.debug_log("make_generic_planet - New planet orbit: "..new_planet.orbit.name.." index: "..new_planet.orbit.index, "universe")

    Universe.star_gravity_well_distribute(star)
    return new_planet
  end
end

---@param parent_planet PlanetType
---@param special_type string
---@param special_list MoonType[]
function UniverseLegacy.add_special_moon(parent_planet, special_type, special_list)
  Log.debug_log("add_special_moon - New special moon for planet: "..parent_planet.name.." ("..special_type..")", "universe")
  local protomoons = table.deepcopy(special_list)
  Universe.shuffle(protomoons)
  local new_moon = nil
  for i = 1, #protomoons do
    if protomoons[i] and not storage.zones_by_name[protomoons[i].name] then
      new_moon = protomoons[i]
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
    add_zone(storage.zone_index, storage.zones_by_name, new_moon)
    Log.debug_log("add_special_moon - New special moon: "..new_moon.name.." index: "..new_moon.index, "universe")

    new_moon.orbit = {
      type = "orbit",
      name = new_moon.name .. " Orbit",
      parent = new_moon,
      seed = storage.universe_rng(4294967295),
    }
    add_zone(storage.zone_index, storage.zones_by_name, new_moon.orbit)
    Log.debug_log("add_special_moon - New special moon orbit "..new_moon.orbit.name.." index: "..new_moon.orbit.index, "universe")
    Universe.planet_gravity_well_distribute(parent_planet)
  end
end

return UniverseLegacy
