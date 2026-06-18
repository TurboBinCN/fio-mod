Location = {}

---@param location_reference LocationReference
---@return LocationReference?
function Location.from_reference(location_reference)
  if not location_reference then return nil end
  if location_reference.type == "zone" then
    return {
      type = location_reference.type,
      zone = Zone.from_zone_index(location_reference.index),
      position = location_reference.position,
      name = location_reference.name
    }
  elseif location_reference.type == "spaceship" then
    local spaceship = Spaceship.from_index(location_reference.index)
    if not spaceship then return nil end
    local position = location_reference.position
    if position and spaceship.console and spaceship.console.valid then
      position = Util.vectors_add(location_reference.position, spaceship.console.position)
    end
    return {
      type = location_reference.type,
      zone = spaceship,
      position = position,
      name = location_reference.name
    }
  elseif location_reference.type == "system" then
    return {
      type = location_reference.type,
      zone = Zone.from_zone_index(location_reference.index),
      position = location_reference.position,
      name = location_reference.name,
    }
  elseif location_reference.type == "interstellar" then
    return {
      type = location_reference.type,
      position = location_reference.position,
      name = location_reference.name,
    }
  else
    return {
      type = location_reference.type,
      surface = game.get_surface(location_reference.index),
      position = location_reference.position,
      name = location_reference.name
    }
  end
end

---@param location_reference LocationReference
---@return LocalisedString
function Location.to_localised_string(location_reference)
  if not location_reference then return nil end
  local base
  if location_reference.type == "interstellar" then
    base = {"space-exploration.interstellar-map"}
  else
    local location = Location.from_reference(location_reference)
    if not location then return nil end
    if location.type == "system" then
      base = { "space-exploration.solar-system", location.zone.name }
    elseif location.type == "zone" then
      base = location.zone.name
    else
      base = location.surface.name
    end
  end
  if location_reference.name and location_reference.name ~= "" then
    return { "space-exploration.remote-view-history-item_named", base, location_reference.name }
  end
  return base
end

-- zone, spaceship, or starmap
---@param player? LuaPlayer
---@return LocationReference?
function Location.new_reference_from_player(player)
  if not player then return nil end
  local zone = Zone.from_surface(player.surface)
  if zone then
    return Location.make_reference(zone, player.position)
  end
  -- maybe starmap
  local map_info = MapView.get_player_map_info(player)
  if map_info then
    return {
      type = map_info.type,
      position = player.position,
      index = map_info.type == "system" and map_info.zone.index or nil
    }
  end

  return Location.make_reference(player.surface, player.position)
end

-- zone or spaceship,
---@param zone_or_surface AnyZoneType|SpaceshipType|Surface
---@param position MapPosition
---@param name? string
---@param entity? LuaEntity  Optional entity to open when going to this reference
---@param zoom? number  Optional zoom level for the location
---@return LocationReference?
function Location.make_reference(zone_or_surface, position, name, entity, zoom)
  if not zone_or_surface then return nil end
  local location_reference = {index = zone_or_surface.index, position = position, name = name, entity = entity, zoom = zoom}
  if type(zone_or_surface) == "userdata" then
    location_reference.type = "surface"
  elseif zone_or_surface.type == "spaceship" then
    ---@cast zone_or_surface SpaceshipType
    location_reference.type = "spaceship"
    if position and zone_or_surface.console and zone_or_surface.console.valid then
      location_reference.position = Util.vectors_delta(zone_or_surface.console.position, position)
    end
  else
    ---@cast zone_or_surface -SpaceshipType
    location_reference.type = "zone"
  end
  return location_reference
end

---@param location_reference LocationReference
---@param zone_or_surface AnyZoneType|SpaceshipType|Surface
---@param position MapPosition
---@return LocationReference?
function Location.update_reference_position(location_reference, zone_or_surface, position)
  if not location_reference then
    location_reference = {}
  end
  if not zone_or_surface then return nil end
  location_reference.index = zone_or_surface.index
  location_reference.position = position
  if type(zone_or_surface) == "userdata" then
    location_reference.type = "surface"
  elseif zone_or_surface.type == "spaceship" then
    ---@cast zone_or_surface SpaceshipType
    location_reference.type = "spaceship"
    if position and zone_or_surface.console and zone_or_surface.console.valid then
      location_reference.position = Util.vectors_delta(zone_or_surface.console.position, position)
    end
  else
    ---@cast zone_or_surface -SpaceshipType
    location_reference.type = "zone"
  end
  return location_reference
end

---@param location_reference LocationReference
---@param name string
---@return LocationReference
function Location.update_reference_name(location_reference, name)
  if not location_reference then
    location_reference = {}
  end
  location_reference.name = name
  return location_reference
end

---@param player LuaPlayer
---@param location_reference LocationReference
function Location.goto_reference(player, location_reference)
  local location = Location.from_reference(location_reference) -- expand zone or spaceship connection
  if not location then return end
  if location_reference.type == "zone" or location_reference.type == "spaceship" then
    RemoteView.start(player, location.zone, location.position)
  elseif location_reference.type == "interstellar" then
    MapView.start_interstellar_map(player)
    if location_reference.position then
      player.teleport(location_reference.position)
    end
  elseif location_reference.type == "system" then
    MapView.start_system_map(player, location.zone)
    player.teleport(location_reference.position)
  else
    player.set_controller{type = defines.controllers.remote, surface = location.surface}
  end
  if location_reference.zoom then player.zoom = location_reference.zoom end
  if location_reference.entity and location_reference.entity.valid then
    player.opened = location_reference.entity
  end
end

return Location
