--[[
Map View.

Is allows user to take a look at universe maps. Requires RemoteView to work.
Interconnects with Zonelist too.

Two maps are currently available:
  Interstellar map
  System map
]]--

local InterstellarMap = {}
local SystemMap = {}
local MapObjects = {}

local MapView = {
  InterstellarMap = InterstellarMap,
  SystemMap = SystemMap,
  MapObjects = MapObjects
}

MapView.name_shortcut = mod_prefix.."star-map"
MapView.name_event = mod_prefix.."star-map"
MapView.tech_spaceship = mod_prefix .. "spaceship"

-- constants
MapView.name_surface_prefix = "starmap-"
MapView.name_gui_zone_details_root = "se-map-view-zone-details"
MapView.name_gui_titlebar_flow = "titlebar-flow"
MapView.name_gui_titlebar_button_flow = "zone-button-flow"

MapView.action_close_button = "close-mapview-gui"
MapView.action_zone_button = "go-to-zone"

MapView.name_toggles = "map_view_toggles"
MapView.name_button_show_resources = "show_resources"
MapView.name_button_show_stats = "show_stats"
MapView.name_button_show_anchor_info = "show_anchor_info"
MapView.name_button_show_danger_zones = "show_danger_zones"
MapView.name_button_overhead_interstellar = mod_prefix .. "overhead_interstellar"
MapView.name_setting_overhead_interstellar = mod_prefix .. "show-overhead-button-interstellar-map"

MapView.name_clickable_interstellar_star = mod_prefix .. "interstellar-map-star"
MapView.name_clickable_interstellar_asteroid_field = mod_prefix .. "interstellar-map-asteroid-field"
MapView.name_clickable_interstellar_spaceship = mod_prefix .. "interstellar-map-spaceship"
MapView.name_clickable_system_star = mod_prefix .. "system-map-star"
MapView.name_clickable_system_planet_prefix = mod_prefix .. "system-map-planet"
MapView.name_clickable_system_moon_prefix = mod_prefix .. "system-map-moon"
MapView.name_clickable_system_asteroid_belt = mod_prefix .. "system-map-asteroid-belt"
MapView.name_clickable_system_spaceship = mod_prefix .. "system-map-spaceship"
MapView.name_clickable_system_interstellar_space = mod_prefix .. "system-map-interstellar-space"
MapView.clickable_steps = 20 -- the number of increments for clickable scale

MapView.nb_satellites_to_unlock = 2

InterstellarMap.scale = Shared.interstellar_map_scale
InterstellarMap.distance_scale = 0.25 * InterstellarMap.scale

InterstellarMap.star_scale = InterstellarMap.scale
InterstellarMap.asteroid_scale = InterstellarMap.scale
InterstellarMap.asteroid_scale_scatter = InterstellarMap.scale
InterstellarMap.spaceship_scale = 1 * InterstellarMap.scale

InterstellarMap.infobox_scale = 1 * InterstellarMap.scale

InterstellarMap.text_scale = 1 * InterstellarMap.scale
InterstellarMap.star_text_scale = 2.5 * InterstellarMap.text_scale
InterstellarMap.asteroid_field_text_scale = 2 * InterstellarMap.text_scale

InterstellarMap.spaceship_text_scale = 0.5 * InterstellarMap.text_scale
InterstellarMap.spaceship_text_offset = Util.vector_multiply({ x = -0.2, y = -0.2}, InterstellarMap.spaceship_scale)

InterstellarMap.danger_zone_from_delta_v_scale = 6.0 / 10350.0 -- magic number dictates how big the danger zone thickness should be from the delta_v used to indicate being near the field
InterstellarMap.field_danger_zone_circle_radius_scale = SpaceshipObstacles.near_enough_by_zone_type["asteroid-field"] * InterstellarMap.danger_zone_from_delta_v_scale * InterstellarMap.scale

-- update coefficients here to adjust solar system map scale and element sizes
-- NOTE: if you change graphics please adjust *_graphics_scale constants in RemoteView.render_solarmap_* functions first
SystemMap.scale = Shared.system_map_scale
SystemMap.distance_scale = 12 * SystemMap.scale -- star gravity well scale
SystemMap.star_scale = 16 * SystemMap.scale
SystemMap.planet_scale = 4 * SystemMap.scale
SystemMap.planet_min_multiplier = 0.05
SystemMap.belt_scale = 1 * SystemMap.scale
SystemMap.spaceship_scale = 0.4 * SystemMap.scale

-- draw_line(width=) in pixels
-- draw_arc(min_radius,max_radius=) in tiles
-- these thickness constants are in tiles so you need to multiply it by 32 if used in draw_line()
SystemMap.line_thickness_scale = 0.08 * SystemMap.scale
SystemMap.arc_thickness_scale = 0.08 * SystemMap.scale
SystemMap.belt_arc_thickness_scale = 0.05 * SystemMap.scale
SystemMap.danger_zone_from_delta_v_scale = 5.0 / 207.0 -- magic number dictates how big the danger zone thickness should be from the delta_v used to indicate being near the belt
SystemMap.belt_danger_zone_arc_thickness_scale = SpaceshipObstacles.near_enough_by_zone_type["asteroid-belt"] * SystemMap.danger_zone_from_delta_v_scale * SystemMap.scale
SystemMap.planet_offset = { x = 0, y = 0}
SystemMap.belt_offset = { x = 2 * SystemMap.scale, y = 0}

SystemMap.infobox_scale = 1 * SystemMap.scale
SystemMap.infobox_gradient_tint = { r = 128, b = 128, g = 128, a = 255 }

SystemMap.text_scale = 4 * SystemMap.scale
SystemMap.star_text_scale = 1.2 * SystemMap.text_scale
SystemMap.planet_text_scale = 1 * SystemMap.text_scale
SystemMap.orbit_text_scale = 0.8 * SystemMap.text_scale
SystemMap.belt_text_scale = 1 * SystemMap.text_scale
SystemMap.landed_spaceship_text_scale = 0.5 * SystemMap.text_scale

SystemMap.spaceship_text_scale = 0.5 * SystemMap.text_scale

SystemMap.star_text_offset = Util.vector_multiply({ x = 2, y = 0.5}, SystemMap.scale)
SystemMap.spaceship_text_offset = Util.vector_multiply({ x = -0.2, y = -0.2}, SystemMap.spaceship_scale)

---@param force_name string
---@return boolean
function MapView.is_unlocked_force(force_name)
  return storage.debug_view_all_zones or (storage.forces[force_name] and storage.forces[force_name].satellites_launched >= MapView.nb_satellites_to_unlock)
end

---@param player LuaPlayer
---@return boolean
function MapView.is_unlocked(player)
  return MapView.is_unlocked_force(player.force.name)
end

---@param player LuaPlayer
---@return LocalisedString
function MapView.unlock_requirement_string(player)
  if is_player_force(player.force.name) then
    return {"space-exploration.star-map-requires-satellite", MapView.nb_satellites_to_unlock - storage.forces[player.force.name].satellites_launched}
  else
    return {"space-exploration.cannot-use-with-force"}
  end
end

---Returns a table of all resource prototypes mapping their names to their map colors. Caches the
---resulting table in a storage variable.
---@return table<string, Color>
function MapView.get_resource_colors()
  if not SystemMap.resource_color_mapping then
    local resource_prototypes = prototypes.get_entity_filtered{{filter="type", type="resource"}}

    local mapping = {}
    for name, proto in pairs(resource_prototypes) do
      mapping[name] = proto.map_color
    end

    ---Table of resource colors, indexed by resource name
    ---@type table<string, Color>
    SystemMap.resource_color_mapping = mapping
  end

  return SystemMap.resource_color_mapping
end

---@param player LuaPlayer
---@return RemoteViewMapInfo? nil if player is not in a map view
function MapView.get_player_map_info(player)
  local remote_view_data = RemoteView.get_data(player)
  if not remote_view_data then return end -- Not in remote view
  local activity = remote_view_data.activity
  if not activity then return end -- No remote view activity
  if activity.type ~= "map" then return end -- Not in remote view map activity
  return activity.map_info
end

---@param player LuaPlayer
---@return boolean
function MapView.player_is_in_map(player)
  return MapView.get_player_map_info(player) ~= nil
end

---@param player LuaPlayer
---@return boolean
function MapView.player_is_in_interstellar_map(player)
  local map_info = MapView.get_player_map_info(player)
  if not map_info then return false end
  return map_info.type == "interstellar"
end

---@param player LuaPlayer
---@return boolean
function MapView.player_is_in_system_map(player)
  local map_info = MapView.get_player_map_info(player)
  if not map_info then return false end
  return map_info.type == "system"
end

---@param player LuaPlayer
---@return StarType?
function MapView.get_current_system(player)
  local map_info = MapView.get_player_map_info(player)
  if not map_info then return end
  if map_info.type ~= "system" then return end
  return map_info.zone
end

---@param player LuaPlayer
---@return string
function MapView.get_surface_name(player)
  return MapView.name_surface_prefix .. player.index
end

---@param player LuaPlayer
---@return LocalisedString
function MapView.get_surface_localised_name(player)
  return {"space-exploration.simple-a-b-space", "[img=se-map-gui-starmap]", {"space-exploration.starmap"}}
end

function MapView.reset_localised_starmap_surface_names()
  for _, surface in pairs(game.surfaces) do
    if MapView.is_surface_starmap(surface) then
      local player = game.get_player(MapView.get_player_index_from_surface(surface))
      surface.localised_name = MapView.get_surface_localised_name(player)
    end
  end
end

function MapView.is_surface_starmap(surface)
  return string.starts(surface.name, MapView.name_surface_prefix) and string.count(surface.name, "-") == 1
end

function MapView.get_player_index_from_surface(surface)
  return tonumber(string.sub(surface.name, string.len(MapView.name_surface_prefix)+1))
end

---@param player LuaPlayer
---@return LuaSurface mapview_surface
function MapView.get_make_surface(player)
  local surface_name = MapView.get_surface_name(player)

  if not game.get_surface(surface_name) then
    local mapgen_settings = {
      autoplace_controls = {
        ["planet-size"] = { frequency = 1/1000, size = 1 }
      }
    }
    mapgen_settings.autoplace_settings={
      ["decorative"]={
        treat_missing_as_default=false,
        settings={
        }
      },
      ["entity"]={
        treat_missing_as_default=false,
        settings={
        }
      },
      ["tile"]={
        treat_missing_as_default=false,
        settings={
          ["se-space"]={}
        }
      },
    }
    mapgen_settings.property_expression_names = {}
    mapgen_settings.property_expression_names["tile:out-of-map:probability"] = math.huge
    -- to prevent 50x50 testing worlds from breaking the starmap
    mapgen_settings.width = 0
    mapgen_settings.height = 0
    local surface = game.create_surface(surface_name, mapgen_settings)
    surface.localised_name = MapView.get_surface_localised_name(player)
    surface.daytime = 0
    surface.freeze_daytime = true
    surface.show_clouds = false

    -- Attemp to improve the experience of the first opening of the map better
    -- so that it's not darkness while it's charted. We don't know the exact position this will be, or
    -- if it will be a system or interstellar map, but we can quess. So we will chart the area around
    -- Calidus for the system map, and the area around the homeworld, which is usually the first location
    -- the system map will open to.
    local chart_area = {{ x = -100, y = -50 }, { x = 100, y = 50 }}
    player.force.chart(surface, chart_area) -- For intertellar map
    local homeworld = Zone.get_force_home_zone(player.force.name)
    assert(homeworld and homeworld.parent)
    local homeworld_position = SystemMap.get_zone_position(homeworld.parent, homeworld)
    player.force.chart(surface, util.area_add_position(chart_area, homeworld_position)) -- For system map
  end

  return game.get_surface(surface_name)
end

---@param player LuaPlayer
function MapView.starmap_view_cycle(player)
  -- Cycle through view modes.
  -- Open solar system map if in a system.
  -- Open interstellar map if not in a system or in a system map.
  -- Close the starmaps if in an interstellar map (go back to last-viewed location)

  if not is_player_force(player.force.name) then return player.print({"space-exploration.cannot-use-with-force"}) end
  if not MapView.is_unlocked(player) then return player.print(MapView.unlock_requirement_string(player)) end

  if not MapView.player_is_in_interstellar_map(player) then
    if MapView.get_current_system(player) then
      return MapView.start_interstellar_map(player)
    else
      local star
      if not MapView.player_is_in_system_map(player) and MapView.is_surface_starmap(player.surface) then
        -- Player is neither in Interstellar Map or System Map, but the surface
        -- is still the starmap surface. Suggests GPS Tag click that's already
        -- started moving their view away from their physical location.
        local gps_tag_data = get_make_playerdata(player).last_clicked_gps_tag
        if gps_tag_data and gps_tag_data.mapview_data then
          if gps_tag_data.mapview_data.type == "system" then
            star = gps_tag_data.mapview_data.zone
          end
        end
      else
        star = Zone.from_surface(player.surface)
      end
      if star then
        if star.type == "spaceship" then
          ---@cast star SpaceshipType
          if star.star_gravity_well and star.star_gravity_well > 0 then
            star = Zone.get_star_from_position(star)
          end
        else
          ---@cast star -SpaceshipType
          star = Zone.get_star_from_child(star)
        end
      end
      if star then
        return MapView.start_system_map(player, star)
      else
        return MapView.start_interstellar_map(player)
      end
    end
  else
    MapView.stop_map(player)
  end
  -- Do not stop remote view here, it is perfectly valid to return to remote view out of the starmap
end

---@param player LuaPlayer
function MapView.start_interstellar_map(player)
  if RemoteView.is_active(player) then
    RemoteView.add_history_current(player) --Save history point
  end
  MapView.internal_start_map(player, { type = "interstellar" })
  MapView.update_overhead_button(player.index)
end

---@param player LuaPlayer
---@param star StarType
function MapView.start_system_map(player, star)
  --local zone
  if RemoteView.is_active(player) then
    RemoteView.add_history_current(player) --Save history point
  end
  if (not star) or star.type ~= "star" then
    -- fallback if star is invalid
    MapView.start_interstellar_map(player)
    return
  end
  MapView.internal_start_map(player, {
    type = "system",
    zone = star,
  })
end

---@param player LuaPlayer
function MapView.internal_restart_map(player)
  local playerdata = get_make_playerdata(player)

  local map_info = MapView.get_player_map_info(player)
  assert(map_info) -- Can only restart if map already open

  -- DO NOT stop_map
  MapView.clear_map(player)
  playerdata.map_view_objects = {}
  playerdata.map_view_entities = {}

  if map_info.type == "interstellar" then
    --InterstellarMap.start(player, from_zone, true)
    InterstellarMap.render(player)
  elseif map_info.type == "system" then
    --SystemMap.start(player, map_data.zone, from_zone, true)
    SystemMap.render(player, map_info.zone)
  end

  RemoteViewGUI.update(player)
end

---@param player LuaPlayer
---@param map_data {type: RemoteViewMapType, zone?: AnyZoneType}
function MapView.internal_start_map(player, map_data)
  local playerdata = get_make_playerdata(player)

  local remote_view_data = RemoteView.get_data(player)
  local old_map_info = MapView.get_player_map_info(player)
  local previous_current_zone = remote_view_data and remote_view_data.current_zone

  local from_zone
  if old_map_info and old_map_info.zone then
    from_zone = old_map_info.zone
  else
    from_zone = playerdata.remote_view_current_zone or map_data.sub_zone or Zone.from_surface(player.surface)
  end

  -- DO NOT stop_map
  MapView.clear_map(player)
  playerdata.map_view_objects = {}
  playerdata.map_view_entities = {}

  if map_data.type == "interstellar" then
    InterstellarMap.start(player, from_zone)
    InterstellarMap.render(player)
  elseif map_data.type == "system" then
    SystemMap.start(player, map_data.zone, from_zone)
    SystemMap.render(player, map_data.zone)
  end

  RemoteViewGUI.open(player)
end

---@param player LuaPlayer
function MapView.stop_map(player)
  MapView.gui_close(player)
  RemoteView.stop(player)

  -- It could happen if the player is in editor mode, and teleport to location enabled,
  -- that they will get stuck in map view. Just teleport them home.
  if MapView.is_surface_starmap(player.surface) then
    local previous_location = RemoteView.history_previous(player, true)
    local zone = previous_location and previous_location.zone or Zone.get_force_home_zone(player.force.name)
    local position = previous_location and previous_location.zone and previous_location.position or {0,0}

    if player.controller_type == defines.controllers.editor then
      player.teleport(position, Zone.get_surface(zone))
    elseif player.character then
      -- Not sure how this will happen, but try to be safe
      teleport_non_colliding_player(player, position, Zone.get_surface(zone))
    end
  end
end

-- delete the starmap graphics for this player
---@param player LuaPlayer
function MapView.clear_map(player)
  local playerdata = get_make_playerdata(player)
  if playerdata.map_view_objects then
    for _, object_render in pairs(playerdata.map_view_objects) do
      object_render.destroy()
    end
  end
  playerdata.map_view_objects = nil

  local surface = game.get_surface(MapView.get_surface_name(player))
  if surface then
    for _, entity in pairs(surface.find_entities_filtered{}) do
      if entity.valid then -- Possible that stickers or something get invalidated during iteration
        entity.destroy()
      end
    end
  end
  playerdata.map_view_entities = nil
end



--[[

  INTERSTELLAR MAP

]]--

---@param player LuaPlayer
---@param from_zone AnyZoneType
---@param no_teleport? boolean
function InterstellarMap.start(player, from_zone, no_teleport)
  local start_stellar_position = {x=0, y=0} --[[@as StellarPosition]]
  if from_zone then
    start_stellar_position = Zone.get_stellar_position(from_zone) --[[@as StellarPosition]]
  end
  local surface = MapView.get_make_surface(player)
  if not no_teleport then
    local remote_view_activity = {
      type = "map",
      map_info = {
        type = "interstellar",
        map_surface = surface,
      },
    }
    RemoteView.start_activity(player,
                              remote_view_activity,
                              nil,
                              InterstellarMap.get_zone_position({stellar_position = start_stellar_position}))
  end
end

---@param player LuaPlayer
function InterstellarMap.render(player)
  local surface = MapView.get_make_surface(player)
  local playerdata = get_make_playerdata(player)
  local spaceships = InterstellarMap.get_spaceship_index(player)

  for _, star in pairs(storage.universe.stars) do
    InterstellarMap.render_star(player, surface, star, playerdata, spaceships.bound)
  end
  for _, zone in pairs(storage.universe.space_zones) do
    if Zone.is_visible_to_force(zone, player.force.name) then
      InterstellarMap.render_asteroid_field(player, surface, zone, playerdata, spaceships.bound)
    end
  end

  for _, spaceship in pairs(spaceships.flying) do
    InterstellarMap.render_spaceship(player, surface, spaceship, playerdata)
  end

end

---@param zone AsteroidFieldType|StarType|SpaceshipType
---@return Vector.0
function InterstellarMap.get_zone_position(zone)
  return Util.vector_multiply(zone.stellar_position, InterstellarMap.distance_scale)
end

---@param player LuaPlayer
---@return {flying: SpaceshipType[], bound: table<integer, SpaceshipType[]>}
function InterstellarMap.get_spaceship_index(player)
  local flying = {}
  local bound = {}
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.force_name == player.force.name then
      if spaceship.space_distortion < 0.05 then
         -- If near an asteroid field, make sure it's actually anchored to the field
        if spaceship.near_stellar_object
        and (spaceship.near_stellar_object.type ~= "asteroid-field" or spaceship.zone_index == spaceship.near_stellar_object.index) then
          bound[spaceship.near_stellar_object.index] = bound[spaceship.near_stellar_object.index] or {}
          table.insert(bound[spaceship.near_stellar_object.index], spaceship)
        else
          table.insert(flying, spaceship)
        end
      end
    end
  end

  return {flying = flying, bound = bound}
end

---@param player LuaPlayer
---@param surface LuaSurface
---@param star StarType
---@param playerdata PlayerData
---@param spaceships table<integer, SpaceshipType[]>
function InterstellarMap.render_star(player, surface, star, playerdata, spaceships)
  local map_object = MapObjects.create(player, surface,
          star, MapView.name_clickable_interstellar_star,
          InterstellarMap.get_zone_position(star))
  map_object.command = "system"

  local object_render = rendering.draw_sprite{
    sprite = mod_prefix.."map-star",
    surface = surface,
    target = map_object.entity,
    players = {player},
    x_scale = 0.1 * InterstellarMap.star_scale,
    y_scale = 0.1 * InterstellarMap.star_scale,
    render_layer = "decals",--28, -- just above decals
  }
  table.insert(playerdata.map_view_objects, object_render)
  local object_render = rendering.draw_animation{
    animation = mod_prefix.."map-star-cloud",
    surface = surface,
    target = map_object.entity,
    players = {player},
    x_scale = 0.1 * InterstellarMap.star_scale,
    y_scale = 0.1 * InterstellarMap.star_scale,
    animation_speed = -1,
    tint = {r=255/255, g=100/255, b=5/255}
  }
  table.insert(playerdata.map_view_objects, object_render)

  MapView.render_zone_caption(player, map_object, star, spaceships)
end

---@param player LuaPlayer
---@param surface LuaSurface
---@param zone AsteroidFieldType
---@param playerdata PlayerData
---@param spaceships table<integer, SpaceshipType[]>
function InterstellarMap.render_asteroid_field(player, surface, zone, playerdata, spaceships)
  local map_object = MapObjects.create(player, surface,
          zone, MapView.name_clickable_interstellar_asteroid_field,
          InterstellarMap.get_zone_position(zone))
  map_object.command = "details"

  local primary_resource = zone.primary_resource
  local tint = MapView.get_resource_colors()[primary_resource] or {r=0, g=0, b=0, a=0}

  local object_render = rendering.draw_sprite{
    sprite = mod_prefix.."map-asteroid-field-scatter",
    surface = surface,
    target = map_object.entity,
    x_scale = 0.3 * InterstellarMap.asteroid_scale_scatter,
    y_scale = 0.3 * InterstellarMap.asteroid_scale_scatter,
    players = {player}
  }
  table.insert(playerdata.map_view_objects, object_render)
  local object_render = rendering.draw_sprite{
    sprite = mod_prefix.."map-asteroid-field-scatter-detail",
    surface = surface,
    target = map_object.entity,
    x_scale = 0.3 * InterstellarMap.asteroid_scale_scatter,
    y_scale = 0.3 * InterstellarMap.asteroid_scale_scatter,
    players = {player},
    tint = tint
  }
  table.insert(playerdata.map_view_objects, object_render)
  local infobox_settings = MapView.get_settings(player)
  if infobox_settings.show_danger_zones then
    local object_render = rendering.draw_circle{
      color = {r=48, g=0, b=0, a=48},
      radius = InterstellarMap.field_danger_zone_circle_radius_scale,
      filled = true,
      target = map_object.entity,
      surface = surface,
      players = {player},
      draw_on_ground = true
    }
    table.insert(playerdata.map_view_objects, object_render)
  end
  MapView.render_zone_caption(player, map_object, zone, spaceships)
end

---@param player LuaPlayer
---@param surface LuaSurface
---@param spaceship SpaceshipType
---@param playerdata PlayerData
function InterstellarMap.render_spaceship(player, surface, spaceship, playerdata)
  local map_object = MapObjects.create(player, surface,
          spaceship, MapView.name_clickable_interstellar_spaceship,
          InterstellarMap.get_zone_position(spaceship))
  map_object.command = "details"

  local object_render = rendering.draw_sprite{
    sprite = mod_prefix.."map-spaceship",
    surface = surface,
    target = map_object.entity,
    orientation = MapView.get_spaceship_orientation(player, spaceship),
    x_scale = 0.0625 * InterstellarMap.spaceship_scale,
    y_scale = 0.0625 * InterstellarMap.spaceship_scale,
    players = {player},
  }
  table.insert(playerdata.map_view_objects, object_render)
  map_object.main_objects = {object_render}

  MapView.render_spaceship_caption(player, map_object, spaceship, nil)
end

--[[

  SYSTEM MAP

]]--

---@param player LuaPlayer
---@param star StarType
---@param from_zone AnyZoneType
---@param no_teleport? boolean
function SystemMap.start(player, star, from_zone, no_teleport)
  local start_solar_position = { x = 0, y = 0 }
  if from_zone then
    local star_stellar_position = star.stellar_position
    local from_zone_stellar_position = Zone.get_stellar_position(from_zone)
    if from_zone_stellar_position.x == star_stellar_position.x and from_zone_stellar_position.y == star_stellar_position.y then
      start_solar_position = SystemMap.get_zone_position(star, from_zone)
    end
  end

  local surface = MapView.get_make_surface(player)
  if not no_teleport then
    local remote_view_activity = {
      type = "map",
      map_info = {
        type = "system",
        map_surface = surface,
        zone = star,
      },
    }
    RemoteView.start_activity(player, remote_view_activity, nil, start_solar_position)
  end
end

---@param player LuaPlayer
---@param star StarType
function SystemMap.render(player, star)
  local surface = MapView.get_make_surface(player)
  local playerdata = get_make_playerdata(player)
  local spaceships = SystemMap.get_spaceship_index(player, star)

  -- line showing the star gravity well
  local object_render = rendering.draw_line{
    color = {r=128, g=128, b=128, a=255},
    width = 32 * SystemMap.line_thickness_scale,
    from = SystemMap.get_zone_position(star, {
      star_gravity_well = star.star_gravity_well,
      planet_gravity_well = Zone.get_planet_gravity_well(star.orbit)
    }),
    to = SystemMap.get_zone_position(star, { star_gravity_well = 0}),
    surface = surface,
    players = {player},
    draw_on_ground = true
  }
  table.insert(playerdata.map_view_objects, object_render)

  SystemMap.render_star(player, surface, star, playerdata, spaceships.bound)

  for _, planet_or_belt in pairs(star.children) do
    if Zone.is_visible_to_force(planet_or_belt, player.force.name) then
      if planet_or_belt.type == "planet" then
        local position_data = SystemMap.get_zone_position_data(star, planet_or_belt)
        local solar_distance = position_data.y
                * SystemMap.distance_scale
        local object_render = rendering.draw_arc{
          color = {r=128, g=128, b=128, a=255},
          max_radius = (solar_distance + 0.5 * SystemMap.arc_thickness_scale),
          min_radius = (solar_distance - 0.5 * SystemMap.arc_thickness_scale),
          start_angle = 0.5 * Util.pi - 2 * Util.pi * position_data.orientation,
          angle = 2 * Util.pi * position_data.orientation,
          target = {x=0, y=0},
          surface = surface,
          players = {player},
          draw_on_ground = true
        }
        table.insert(playerdata.map_view_objects, object_render)

        SystemMap.render_planet_or_moon(player, surface, star, planet_or_belt, playerdata, spaceships.bound)

        for _, moon in pairs(planet_or_belt.children) do
          SystemMap.render_planet_or_moon(player, surface, star, moon, playerdata, spaceships.bound)
        end

      elseif planet_or_belt.type == "asteroid-belt" then
        local position_data = SystemMap.get_zone_position_data(star, planet_or_belt)
        local solar_distance = position_data.y
                * SystemMap.distance_scale
        local primary_resource = planet_or_belt.primary_resource
        local tint = MapView.get_resource_colors()[primary_resource] or {r=0, g=0, b=0, a=0}

        local belt_graphics_scale = 0.5
        for i = 1, 36 do
          local object_render = rendering.draw_arc{
            color = {r=16, g=16, b=16, a=16},
            max_radius = (solar_distance + 2 * SystemMap.belt_arc_thickness_scale),
            min_radius = (solar_distance - 2 * SystemMap.belt_arc_thickness_scale),
            start_angle = (i - 1) / 36 * 2 * Util.pi,
            angle = (0.9) / 36 * 2 * Util.pi,
            target = {x=0, y=0},
            surface = surface,
            players = {player},
            draw_on_ground = true
          }
          table.insert(playerdata.map_view_objects, object_render)
          local object_render = rendering.draw_arc{
            color = {r=32, g=32, b=32, a=32},
            max_radius = (solar_distance + SystemMap.belt_arc_thickness_scale),
            min_radius = (solar_distance - SystemMap.belt_arc_thickness_scale),
            start_angle = (i - 1 + 0.01) / 36 * 2 * Util.pi,
            angle = (0.9 - 2 * 0.01) / 36 * 2 * Util.pi,
            target = {x=0, y=0},
            surface = surface,
            players = {player},
            draw_on_ground = true
          }
          table.insert(playerdata.map_view_objects, object_render)
        end

        -- asteroid belt scatter graphics
        local num_partitions = 3.2 * 36 * solar_distance / SystemMap.scale / 133 -- 133 is solar distance for first ring
        for i = 1, num_partitions+1 do
          local angle = (i - 1) / num_partitions * 2 * Util.pi
          local orientation = (i - 1) / num_partitions - 0.25 -- -0.25 rotates by 90 degrees
          local object_render = rendering.draw_sprite{
            sprite = mod_prefix.."map-asteroid-belt-scatter",
            x_scale = belt_graphics_scale * SystemMap.belt_scale,
            y_scale = belt_graphics_scale * SystemMap.belt_scale,
            orientation = orientation,
            target = {x=math.cos(angle)*solar_distance, y=math.sin(angle)*solar_distance},
            surface = surface,
            players = {player},
            draw_on_ground = true,
          }
          table.insert(playerdata.map_view_objects, object_render)
          local object_render = rendering.draw_sprite{
            sprite = mod_prefix.."map-asteroid-belt-scatter-detail",
            x_scale = belt_graphics_scale * SystemMap.belt_scale,
            y_scale = belt_graphics_scale * SystemMap.belt_scale,
            orientation = orientation,
            target = {x=math.cos(angle)*solar_distance, y=math.sin(angle)*solar_distance},
            surface = surface,
            players = {player},
            draw_on_ground = true,
            tint = tint
          }
          table.insert(playerdata.map_view_objects, object_render)
        end

        local infobox_settings = MapView.get_settings(player)
        if infobox_settings.show_danger_zones then
          local object_render = rendering.draw_arc{
            color = {r=48, g=0, b=0, a=48},
            max_radius = (solar_distance + SystemMap.belt_danger_zone_arc_thickness_scale),
            min_radius = (solar_distance - SystemMap.belt_danger_zone_arc_thickness_scale),
            start_angle = 0,
            angle = 2 * Util.pi,
            target = {x=0, y=0},
            surface = surface,
            players = {player},
            draw_on_ground = true
          }
          table.insert(playerdata.map_view_objects, object_render)
        end
        SystemMap.render_asteroid_belt(player, surface, star, planet_or_belt, playerdata, spaceships.bound)
      end
    end
  end

  for _, spaceship in pairs(spaceships.flying) do
    SystemMap.render_spaceship(player, surface, star, spaceship, playerdata)
  end

  SystemMap.render_interstellar_space(player, surface, star, playerdata)

end

---@param star StarType
---@return number
function SystemMap.get_rendered_star_size(star)
  local star_size = star.star_gravity_well / 26 -- 26 seems to be around max star_gravity_well
  return star_size * SystemMap.star_scale
end

---@param star StarType
---@param zone AnyZoneType|{star_gravity_well: number, planet_gravity_well: number}
---@return {x: number, y: number, orientation: number}
function SystemMap.get_zone_position_data(star, zone)
  -- zone may be just a table { star_gravity_well = ..., planet_gravity_well = ... }
  if zone and zone.type == "orbit" then
    ---@cast zone OrbitType
    zone = zone.parent
  end
  local position_data = {
    y = (SystemMap.get_rendered_star_size(star) + SystemMap.star_text_offset.x)
            / SystemMap.distance_scale
            + star.star_gravity_well - zone.star_gravity_well,
    x = 0,
    orientation = 0
  }
  if zone.planet_gravity_well and zone.planet_gravity_well > 0 then
    position_data.x = zone.planet_gravity_well * Zone.travel_cost_planet_gravity / Zone.travel_cost_star_gravity
    position_data.orientation = position_data.y and (position_data.x / (2 * Util.pi * position_data.y)) or 0
  end

  return position_data
end

---@param star StarType
---@param zone AnyZoneType|{star_gravity_well: number}
---@return Vector.0
function SystemMap.get_zone_position(star, zone)
  local position_data = SystemMap.get_zone_position_data(star, zone)

  return Util.vector_multiply(
          Util.rotate_vector(- position_data.orientation,
                  {x = 0, y = position_data.y}
          ),
          SystemMap.distance_scale)
end

---@param player LuaPlayer
---@param star StarType
---@return {flying: SpaceshipType[], bound: table<integer, SpaceshipType[]>}
function SystemMap.get_spaceship_index(player, star)
  local flying = {}
  local bound = {}
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.force_name == player.force.name then
      if spaceship.space_distortion < 0.05 then
        if spaceship.near_stellar_object and spaceship.near_stellar_object.index == star.index then
          if spaceship.zone_index then
            bound[spaceship.zone_index] = bound[spaceship.zone_index] or {}
            table.insert(bound[spaceship.zone_index], spaceship)
          else
            table.insert(flying, spaceship)
          end
        end
      end
    end
  end

  return {flying = flying, bound = bound}
end

---@param player LuaPlayer
---@param surface LuaSurface
---@param star StarType
---@param playerdata PlayerData
---@param spaceships table<integer, SpaceshipType[]>
function SystemMap.render_star(player, surface, star, playerdata, spaceships)
  local star_rendered_size = SystemMap.get_rendered_star_size(star)

  local map_object = MapObjects.create(player, surface,
          star, MapView.name_clickable_system_star, { x = 0, y = 0})
  map_object.command = "details"

  local star_graphics_scale = 1 / 8 -- update if changing sprite
  local object_render = rendering.draw_sprite{
    sprite = mod_prefix.."map-star", -- update star_graphics_scale above if you change it
    surface = surface,
    target = map_object.entity,
    players = {player},
    x_scale = star_graphics_scale * star_rendered_size,
    y_scale = star_graphics_scale * star_rendered_size,
    render_layer = "decals"-- 28, -- just above decals
  }
  table.insert(playerdata.map_view_objects, object_render)
  local object_render = rendering.draw_animation{
    animation = mod_prefix.."map-star-cloud",
    surface = surface,
    target = map_object.entity,
    players = {player},
    x_scale = star_graphics_scale * star_rendered_size,
    y_scale = star_graphics_scale * star_rendered_size,
    animation_speed = -1,
    tint = {r=255/255, g=100/255, b=5/255}
  }
  table.insert(playerdata.map_view_objects, object_render)

  MapView.render_zone_caption(player, map_object, star, spaceships)
end

---@param player LuaPlayer
---@param surface LuaSurface
---@param star StarType
---@param zone PlanetType|MoonType
---@param playerdata PlayerData
---@param spaceships table<integer, SpaceshipType[]>
function SystemMap.render_planet_or_moon(player, surface, star, zone, playerdata, spaceships)
  if Zone.is_visible_to_force(zone, player.force.name) then
    local zone_size = zone.radius / Universe.planet_max_radius -- 0..1
    local zone_rendered_size = (SystemMap.planet_min_multiplier + (1 - SystemMap.planet_min_multiplier) * zone_size) * SystemMap.planet_scale
    local solar_position = SystemMap.get_zone_position(star, zone)
    solar_position = Util.vectors_add(solar_position, SystemMap.planet_offset)

    local entity_name_prefix = MapView.name_clickable_system_planet_prefix
    if zone.type == "moon" then
      ---@cast zone MoonType
      entity_name_prefix = MapView.name_clickable_system_moon_prefix
    end
    local entity_name_suffix = "-"..math.min(math.ceil(MapView.clickable_steps * zone.radius / Universe.planet_max_radius), MapView.clickable_steps)

    local map_object = MapObjects.create(player, surface,
            zone, entity_name_prefix .. entity_name_suffix, solar_position)
    map_object.command = "details"

    local planet_graphics_scale = 1 / 8 -- update if changing sprite
    local base_render_layer = 133

    local object_render = rendering.draw_sprite{ -- black out the star orbit like to make planets stand out more
      sprite =  mod_prefix.."map-planet",
      surface = surface,
      target = map_object.entity,
      players = {player},
      x_scale = planet_graphics_scale * zone_rendered_size + 0.01 * SystemMap.planet_scale,
      y_scale = planet_graphics_scale * zone_rendered_size + 0.01 * SystemMap.planet_scale,
      render_layer = "higher-object-under", -- base_render_layer-1,
      tint = {r=0,b=0,g=0,a=1}
    }
    table.insert(playerdata.map_view_objects, object_render)

    local tint = {r=1, b=1, g=1}
    if (not zone.tags) or (Util.table_contains(zone.tags, "aux_very_low") or Util.table_contains(zone.tags, "aux_low")) then
      tint = {r=1, b=0.8, g=0.9}
    end
    if zone.tags and (Util.table_contains(zone.tags, "aux_very_high") or Util.table_contains(zone.tags, "aux_high")) then
      tint = {r=1, b=1, g=0.9}
    end
    local object_render = rendering.draw_sprite{
      sprite =  mod_prefix.."map-planet",
      surface = surface,
      target = map_object.entity,
      players = {player},
      x_scale = planet_graphics_scale * zone_rendered_size,
      y_scale = planet_graphics_scale * zone_rendered_size,
      render_layer = "higher-object-above",--base_render_layer,
      tint = tint
    }
    table.insert(playerdata.map_view_objects, object_render)

    if not (zone.tags and Util.table_contains(zone.tags, "moisture_none")) then
      local tint = {r=1, b=1, g=1}
      if (not zone.tags) or (Util.table_contains(zone.tags, "aux_very_low") or Util.table_contains(zone.tags, "aux_low")) then
        tint = {r=0.5, b=0.5, g=1}
      end
      if zone.tags and (Util.table_contains(zone.tags, "aux_very_high") or Util.table_contains(zone.tags, "aux_high")) then
        tint = {r=1, b=1, g=0.5}
      end
      local object_render = rendering.draw_sprite{
        sprite =  mod_prefix.."map-planet-detail",
        surface = surface,
        target = map_object.entity,
        players = {player},
        x_scale = planet_graphics_scale * zone_rendered_size,
        y_scale = planet_graphics_scale * zone_rendered_size,
        render_layer = "item-in-inserter-hand", --base_render_layer + 1,
        tint = tint
      }
      table.insert(playerdata.map_view_objects, object_render)
    end

    if not (zone.tags and Util.table_contains(zone.tags, "water_none")) then
      local object_render = rendering.draw_sprite{
        sprite =  mod_prefix.."map-planet-water",
        surface = surface,
        target = map_object.entity,
        players = {player},
        x_scale = planet_graphics_scale * zone_rendered_size,
        y_scale = planet_graphics_scale * zone_rendered_size,
        render_layer = "wires",--base_render_layer + 2
      }
      table.insert(playerdata.map_view_objects, object_render)
    end

    local object_render = rendering.draw_sprite{
      sprite =  mod_prefix.."map-planet-cloud-ice",
      surface = surface,
      target = map_object.entity,
      players = {player},
      x_scale = planet_graphics_scale * zone_rendered_size,
      y_scale = planet_graphics_scale * zone_rendered_size,
      render_layer = "wires-above",--base_render_layer + 3
    }
    table.insert(playerdata.map_view_objects, object_render)

    local tint = {r = 0, g = 0.5, b = 1}
    -- TODO: try to estimate average temperature and  do a smooth transition from blue to red based on that.
    -- for now just make a few key values specific colors
    if zone.tags and Util.table_contains(zone.tags, "temperature_volcanic") then tint = {r = 1, g = 0, b = 0} end
    if zone.tags and Util.table_contains(zone.tags, "temperature_very_hot") then tint = {r = 1, g = 0.2, b = 0} end
    if zone.tags and Util.table_contains(zone.tags, "temperature_hot") then tint = {r = 1, g = 0.6, b = 0} end
    if zone.tags and Util.table_contains(zone.tags, "temperature_frozen") then tint = {r = 0, g = 0.2, b = 1} end
    local haze = 0.5 -- darken
    if zone.tags and Util.table_contains(zone.tags, "moisture_none") then haze = 0 end
    if zone.tags and Util.table_contains(zone.tags, "moisture_low") then haze = 0.1 end
    if zone.tags and Util.table_contains(zone.tags, "moisture_med") then haze = 0.3 end
    if zone.tags and Util.table_contains(zone.tags, "moisture_high") then haze = 0.5 end
    if zone.tags and Util.table_contains(zone.tags, "moisture_max") then haze = 1 end
    if haze > 0 then
      for k, v in pairs(tint) do tint[k] = v * 0.5 end -- darken
      local object_render = rendering.draw_sprite{
        sprite =  mod_prefix.."map-planet-haze",
        surface = surface,
        target = map_object.entity,
        players = {player},
        x_scale = planet_graphics_scale * zone_rendered_size,
        y_scale = planet_graphics_scale * zone_rendered_size,
        render_layer = "entity-info-icon",--base_render_layer + 4,
        tint = tint
      }
      table.insert(playerdata.map_view_objects, object_render)
    end

    if haze > 0 then
      tint = {r = 1, g = 1, b = 1}
      for k, v in pairs(tint) do tint[k] = v * 0.5 end -- darken
      local object_render = rendering.draw_sprite{
        sprite =  mod_prefix.."map-planet-atmosphere",
        surface = surface,
        target = map_object.entity,
        players = {player},
        x_scale = planet_graphics_scale * zone_rendered_size,
        y_scale = planet_graphics_scale * zone_rendered_size,
        render_layer = "entity-info-icon-above",--base_render_layer + 5,
        tint = tint
      }
      table.insert(playerdata.map_view_objects, object_render)
    end

    MapView.render_zone_caption(player, map_object, zone, spaceships)
  end
end

---@param player LuaPlayer
---@param surface LuaSurface
---@param star StarType
---@param belt AsteroidBeltType
---@param playerdata PlayerData
---@param spaceships table<integer, SpaceshipType[]>
function SystemMap.render_asteroid_belt(player, surface, star, belt, playerdata, spaceships)
  if Zone.is_visible_to_force(belt, player.force.name) then
    local solar_position = SystemMap.get_zone_position(star, belt)
    solar_position = Util.vectors_add(solar_position, SystemMap.belt_offset)

    local map_object = MapObjects.create(player, surface,
            belt, MapView.name_clickable_system_asteroid_belt, solar_position)
    map_object.command = "details"

    local primary_resource = belt.primary_resource
    local tint = MapView.get_resource_colors()[primary_resource] or {r=0, g=0, b=0, a=0}

    local belt_graphics_scale = 1 / 3
    local object_render = rendering.draw_sprite{
      sprite = mod_prefix.."map-asteroid-belt",
      surface = surface,
      target = map_object.entity,
      x_scale = belt_graphics_scale * SystemMap.belt_scale,
      y_scale = belt_graphics_scale * SystemMap.belt_scale,
      players = {player}
    }
    table.insert(playerdata.map_view_objects, object_render)
    local object_render = rendering.draw_sprite{
      sprite = mod_prefix.."map-asteroid-belt-detail",
      surface = surface,
      target = map_object.entity,
      x_scale = belt_graphics_scale * SystemMap.belt_scale,
      y_scale = belt_graphics_scale * SystemMap.belt_scale,
      players = {player},
      tint = tint
    }
    table.insert(playerdata.map_view_objects, object_render)
    MapView.render_zone_caption(player, map_object, belt, spaceships)
  end
end

---@param player LuaPlayer
---@param surface LuaSurface
---@param star StarType
---@param spaceship SpaceshipType
---@param playerdata PlayerData
function SystemMap.render_spaceship(player, surface, star, spaceship, playerdata)
  local solar_position = SystemMap.get_zone_position(star, spaceship)

  local map_object = MapObjects.create(player, surface,
          spaceship, MapView.name_clickable_system_spaceship, solar_position)
  map_object.command = "details"

  local spaceship_graphics_scale = 1 / 4
  local object_render = rendering.draw_sprite{
    sprite = mod_prefix.."map-spaceship",
    surface = surface,
    target = map_object.entity,
    orientation = MapView.get_spaceship_orientation(player, spaceship),
    x_scale = spaceship_graphics_scale * SystemMap.spaceship_scale,
    y_scale = spaceship_graphics_scale * SystemMap.spaceship_scale,
    players = {player}
  }
  table.insert(playerdata.map_view_objects, object_render)
  map_object.main_objects = {object_render}

  MapView.render_spaceship_caption(player, map_object, spaceship, nil)
end

---@param player LuaPlayer
---@param surface LuaSurface
---@param star StarType
---@param playerdata PlayerData
function SystemMap.render_interstellar_space(player, surface, star, playerdata)
  local solar_position = SystemMap.get_zone_position(star, {
    star_gravity_well = -0.5
  })

  local map_object = MapObjects.create(player, surface,
          "interstellar-space", MapView.name_clickable_system_interstellar_space, solar_position)
  map_object.command = "interstellar"


  local starmap_graphics_scale = 1 / 8
  table.insert(playerdata.map_view_objects,
          rendering.draw_sprite {
            sprite = mod_prefix .. "map-starmap", -- update star_graphics_scale above if you change it
            surface = surface,
            target = map_object.entity,
            players = { player },
            x_scale = starmap_graphics_scale * map_object.entity.prototype.selection_box.right_bottom.y,
            y_scale = starmap_graphics_scale * map_object.entity.prototype.selection_box.right_bottom.y,
            render_layer = "decals",--28, -- just above decals
          })

  local text_size = 3
  table.insert(playerdata.map_view_objects,
          rendering.draw_text {
            text = { "space-exploration.interstellar-map" },
            surface = surface,
            target = {entity = map_object.entity, offset = {x = 0, y = map_object.entity.prototype.selection_box.right_bottom.y}},
            alignment = "center",
            players = { player },
            color = { r = 224, g = 224, b = 224, a = 255 },
            scale = text_size,
            scale_with_zoom = false
          })

end

-- ZONE MAP POSITIONING --

---@param player LuaPlayer
---@param zone SpaceshipType
---@return Vector.0?
function MapView.get_zone_position(player, zone)
  local map_info = MapView.get_player_map_info(player)
  assert(map_info)

  if map_info.type == "interstellar" then
    return InterstellarMap.get_zone_position(zone)
  elseif map_info.type == "system" then
    return SystemMap.get_zone_position(map_info.zone, zone)
  end
end

--[[

  ZONE CAPTIONS

]]--

---@param line_props LuaRendering.draw_sprite_param|{from_offset:Coordinate.0, to_offset:Coordinate.0, from:LuaEntity, width:int, color:Color.0}
---@return LuaRenderObject
function MapView.draw_gradient_line(line_props)
  line_props = table.deepcopy(line_props)

  local line_vector = util.vectors_delta(line_props.from_offset, line_props.to_offset)
  local line_length = util.vectors_delta_length(line_props.from_offset, line_props.to_offset)

  -- gradient constants, gradient is oriented downwards
  local gradient_width = 4
  local gradient_height = 512

  line_props = table.deepcopy(line_props)

  line_props.sprite = mod_prefix .. "gradient-sprite"
  line_props.target = {entity = line_props.from, offset = util.lerp_vectors(line_props.from_offset, line_props.to_offset, 0.5)}
  line_props.x_scale = line_props.width / gradient_width
  line_props.y_scale = 32 * line_length / gradient_height
  line_props.orientation = 0.75 + util.vector_to_orientation(line_vector)
  line_props.tint = line_props.color

  return rendering.draw_sprite(line_props)
end

---@param player LuaPlayer
---@param zone AnyZoneType|StarType
---@param infobox_flags Flags
---@param spaceship_index table<integer, SpaceshipType[]>
---@param clamp_index unknown unused
---@return {sprite:string, sprite_tint?:Color, text?:string|integer, text_color?: Color, text_length?:uint}[][]
function MapView.get_zone_info(player, zone, infobox_flags, spaceship_index, clamp_index)
  local playerdata = get_make_playerdata(player)
  local force_name = player.force.name

  local zone_info = {}

  if infobox_flags.show_stats then
    local info_line = {}
    local threat = Zone.get_threat(zone)

    local priority = Zone.get_priority(zone, force_name)
    local priority_color = Zonelist.color_priority_zero
    if priority > 0 then
      priority_color = Zonelist.color_priority_positive
    elseif priority < 0 then
      priority_color = Zonelist.color_priority_negative
    end
    table.insert(info_line, {
      sprite = "virtual-signal/se-accolade",
      text = priority,
      text_color = priority_color
    })
    if threat > 0 then
      table.insert(info_line, {
        sprite = "virtual-signal/se-death",
        sprite_tint = {r = 255, g = 32, b = 32},
        text = string.format("%.0f", Zone.get_threat(zone)*100).."%",
        text_length = 4
      })
    end

    table.insert(info_line, {
      sprite = "item/solar-panel",
      text = string.format("%.0f", Zone.get_display_light_percent(zone) * 100).."%",
      text_length = 5
    })

    if Zone.is_solid(zone) and not (zone.tags and Util.table_contains(zone.tags, "water_none")) then
      ---@cast zone PlanetType|MoonType
      table.insert(info_line, {
        sprite = "fluid/water"
      })
    end

    if playerdata.visited_zone and playerdata.visited_zone[zone.index] then
      table.insert(info_line, {
        sprite = "entity/character"
      })
    end
    if storage.forces[force_name].zone_assets and storage.forces[force_name].zone_assets[zone.index] and table_size(storage.forces[force_name].zone_assets[zone.index].rocket_launch_pad_names) > 0 then
      table.insert(info_line, {
        sprite = "entity/"..Launchpad.name_rocket_launch_pad
      })
    end
    if storage.forces[force_name].zone_assets and storage.forces[force_name].zone_assets[zone.index] and table_size(storage.forces[force_name].zone_assets[zone.index].rocket_landing_pad_names) > 0 then
      table.insert(info_line, {
        sprite = "entity/"..Landingpad.name_rocket_landing_pad
      })
    end
    if playerdata.track_glyphs and (zone.glyph ~= nil) then
      table.insert(info_line, {
        sprite = "entity/se-pyramid-a"
      })
    end
    if zone.interburbulator or zone.ruins then
      table.insert(info_line, {
        sprite = "virtual-signal/se-ruin"
      })
    end
    table.insert(zone_info, info_line)
  end

  if infobox_flags.show_anchor_info then
    --local clamps_line = {}
    --local clamps_here = clamps_index and clamps_index[zone.index] or {}
    --table.insert(clamps_line, {
    --  sprite = "item/se-spaceship-clamp",
    --  text = { "space-exploration.remote-view-clamps", #clamps_here},
    --  text_color = #clamps_here > 0 and { r=255, g=255, b=255, a=196 } or { r=96, g=96, b=96, a=96 }
    --})
    --table.insert(zone_info, clamps_line)

    local spaceships_line = {}
    local spaceships_here = spaceship_index and spaceship_index[zone.index] or {}
    local spaceships_text
    local spaceships_text_color = { r=0, g=255, b=255, a=196 }
    local spaceships_string_key = "space-exploration.remote-view-spaceships-anchored"
    if MapView.player_is_in_interstellar_map(player) then
      ---@cast zone StarType
      spaceships_string_key = "space-exploration.remote-view-spaceships"
    end
    if next(spaceships_here) then
      spaceships_text = spaceships_here[1].name
      if #spaceships_here > 1 then
        spaceships_text = { spaceships_string_key, #spaceships_here}
      end
    else
      spaceships_text = { spaceships_string_key, 0}
      spaceships_text_color = { r=96, g=96, b=96, a=96 }
    end
    table.insert(spaceships_line, {
      sprite = "virtual-signal/se-spaceship",
      text = spaceships_text,
      text_color = spaceships_text_color
    })
    table.insert(zone_info, spaceships_line)
  end

  return zone_info
end

---@param player LuaPlayer
---@param map_object MapViewEntityInfo
---@param object_renders LuaRenderObject[]
---@param cursor Vector.0
---@param scale number
---@param zone AnyZoneType
---@param infobox_flags Flags
---@param spaceship_index table<integer, SpaceshipType[]>
---@param clamp_index? unknown unused
function MapView.render_zone_info(player, map_object, object_renders, cursor, scale, zone, infobox_flags, spaceship_index, clamp_index)
  local icon_offset = {x = 0.25 * scale, y = 0.325 * scale}
  local icon_size = {x = 0.6 * scale, y = 0}

  for _, info_row in pairs(MapView.get_zone_info(player, zone, infobox_flags, spaceship_index, clamp_index)) do
    local line_cursor = table.deepcopy(cursor)
    for _, info_item in pairs(info_row) do
      table.insert(object_renders,
              rendering.draw_sprite({
                surface = map_object.entity.surface,
                target = {entity = map_object.entity, offset = util.vectors_add(line_cursor, icon_offset)},
                players = {player},

                tint = info_item.sprite_tint,
                sprite = info_item.sprite,
                x_scale = scale / 2,
                y_scale = scale / 2,
              })
      )
      line_cursor = util.vectors_add(line_cursor, icon_size)

      if info_item.text then
        table.insert(object_renders,
                rendering.draw_text({
                  surface = map_object.entity.surface,
                  target = {entity = map_object.entity, offset = line_cursor},
                  players = {player},
                  text = info_item.text,
                  color = info_item.text_color or {r = 255, b = 255, g = 255, a = 255},
                  scale_with_zoom = false,
                  scale = scale,
                  use_rich_text = true,
                })
        )
        line_cursor.x = line_cursor.x + (info_item.text_length and (0.3 + 0.16 * info_item.text_length) or 0.5) * scale
      end
    end
    cursor.y = cursor.y + 0.6 * scale
  end
end

---@param player LuaPlayer
---@param map_object MapViewEntityInfo
---@param object_renders LuaRenderObject[]
---@param cursor Vector.0
---@param scale number
---@param zone AnyZoneType
---@param max_resources uint
function MapView.render_zone_resources(player, map_object, object_renders, cursor, scale, zone, max_resources)
  max_resources = max_resources or 7
  local icon_offset_left = {x = -0.25 * scale, y = 0.325 * scale}
  local icon_size_left = {x = -0.6 * scale, y = 0}

  local fsrs = {}
  local max_fsr = 0
  for resource_name, resource_settings in pairs(storage.resources_and_controls.resource_settings) do
    if zone.controls[resource_name] then
      local fsr = Universe.estimate_resource_fsr(zone.controls[resource_name])
      if fsr > 0 then
        max_fsr = math.max(max_fsr, fsr)
        table.insert(fsrs, {name=resource_name, fsr=fsr})
      end
    end
  end
  table.sort(fsrs, function(a,b) return a.fsr > b.fsr end)
  local mapgen
  if zone.surface_index then mapgen = Zone.get_make_surface(zone).map_gen_settings end

  for i = 1, math.min(#fsrs, max_resources), 1 do
    local resource_name = fsrs[i].name
    local percent = fsrs[i].fsr/max_fsr ^ (1/3)

    local line_cursor = table.deepcopy(cursor)
    table.insert(object_renders,
            rendering.draw_sprite({
              surface = map_object.entity.surface,
              target = {entity = map_object.entity, offset = util.vectors_add(line_cursor, icon_offset_left)},
              players = {player},
              sprite = "entity/"..resource_name,
              x_scale = scale / 2,
              y_scale = scale / 2,
            })
    )
    line_cursor = util.vectors_add(line_cursor, icon_size_left)

    local percent_text = string.format("%.0f", percent * 100)
    local percent_color = percent == 1 and {r = 255, b = 255, g = 255, a = 255} or {r = 128, b = 128, g = 128, a = 255}
    table.insert(object_renders,
            rendering.draw_text({
              surface = map_object.entity.surface,
              target = {entity = map_object.entity, offset = line_cursor},
              players = {player},
              text = percent_text,
              color = percent_color,
              scale_with_zoom = false,
              alignment = "right",
              scale = scale,
            })
    )
    cursor.y = cursor.y + 0.65 * scale

  end
end

---@param player LuaPlayer
---@param map_object MapViewEntityInfo
---@param zone AnyZoneType|StarType
---@param spaceship_index table<integer, SpaceshipType[]>
function MapView.render_zone_caption(player, map_object, zone, spaceship_index)
  if not Zone.is_visible_to_force(zone, player.force.name) then return end

  for _, object_render in pairs(map_object.text_objects or {}) do
    object_render.destroy()
  end
  local object_renders = {}
  map_object.text_objects = object_renders

  local infobox_flags = table.deepcopy(MapView.get_settings(player))

  local map_info = MapView.get_player_map_info(player)
  assert(map_info)

  local scale = map_info.type == "interstellar" and InterstellarMap.infobox_scale or SystemMap.infobox_scale
  local main_cursor = { x = 0, y = map_object.entity.prototype.selection_box.right_bottom.x}
  local cursor

  local name_alignment = "center" -- center/left
  local name_color = {r = 192, b = 192, g = 192, a = 192}
  local name_size = scale
  local short = zone.type == "star" or not zone.orbit

  if map_info.type == "interstellar" then
    if zone.type == "star" then
      ---@cast zone StarType
      name_color = {r=255, g=128, b=0, a=255}
      name_size = InterstellarMap.star_text_scale
      infobox_flags.show_resources = false
      infobox_flags.show_stats = false
    elseif zone.type == "asteroid-field" then
      ---@cast zone AsteroidFieldType
      name_color = {r=255, g=255, b=255, a=160}
      name_size = InterstellarMap.asteroid_field_text_scale
    end
  elseif map_info.type == "system" then
    if zone.type == "star" then
      ---@cast zone StarType
      name_color = {r=255, g=128, b=0, a=255}
      name_size = SystemMap.star_text_scale
      name_alignment = "left"
      main_cursor = util.vectors_add(main_cursor, { x = 3 * scale, y = 2 * scale})
      infobox_flags.show_resources = false
    elseif zone.type == "planet" then
      ---@cast zone PlanetType
      name_color = {r=255, g=255, b=255, a=224}
      name_size = SystemMap.planet_text_scale
    elseif zone.type == "moon" then
      ---@cast zone MoonType
      name_color = {r=255, g=255, b=255, a=224}
      name_size = SystemMap.planet_text_scale
    elseif zone.type == "asteroid-belt" then
      ---@cast zone AsteroidBeltType
      name_color = {r=255, g=255, b=255, a=128}
      name_size = SystemMap.belt_text_scale
      name_alignment = "left"
      main_cursor = util.vectors_add(main_cursor, { x = 1 * scale, y = 0})
    end
  end

  -- NAME AND LINES
  if name_alignment == "center" then
    table.insert(object_renders,
            rendering.draw_text({
              surface = map_object.entity.surface,
              target = {entity = map_object.entity, offset = main_cursor},
              players = {player},
              text = zone.name,
              color = name_color,
              scale_with_zoom = false,
              alignment = "center",
              scale = name_size,
            })
    )
  elseif name_alignment == "left" then
    table.insert(object_renders,
            rendering.draw_text({
              surface = map_object.entity.surface,
              target = {entity = map_object.entity, offset = util.vectors_add(main_cursor, { x=-1.7 * scale, y=0})},
              players = {player},
              text = zone.name,
              color = name_color,
              scale_with_zoom = false,
              alignment = "left",
              scale = name_size,
            })
    )
  end

  if not (infobox_flags.show_resources or infobox_flags.show_stats or infobox_flags.show_anchor_info) then
    return
  end

  main_cursor.y = main_cursor.y + 0.5 * name_size + 0.2 * scale
  local horiz_line_cursor = table.deepcopy(main_cursor)

  table.insert(object_renders,
          MapView.draw_gradient_line({
            surface = map_object.entity.surface,
            from = map_object.entity,
            to = map_object.entity,
            players = { player },

            from_offset = main_cursor,
            to_offset = util.vectors_add(main_cursor, { x = 2 * scale, y = 0 }),
            color = SystemMap.infobox_gradient_tint,
            width = 2 * scale,
          }))
  table.insert(object_renders,
          MapView.draw_gradient_line({
            surface = map_object.entity.surface,
            from = map_object.entity,
            to = map_object.entity,
            players = { player },

            from_offset = main_cursor,
            to_offset = util.vectors_add(main_cursor, { x = -2 * scale, y = 0 }),
            color = SystemMap.infobox_gradient_tint,
            width = 2 * scale,
          }))
  main_cursor.y = main_cursor.y + 0.1 * scale

  cursor = util.vectors_add(main_cursor, { x=0.3 * scale, y=0.1 * scale})

  if infobox_flags.show_stats or infobox_flags.show_anchor_info then
    local body_info_shown = false
    local show_orbit_info = true
    -- BODY INFO
    if zone.type == "star" then
      ---@cast zone StarType
      if map_info.type == "interstellar" then
        show_orbit_info = false
        MapView.render_zone_info(player, map_object, object_renders, cursor, scale, zone, { show_anchor_info = true }, spaceship_index)
      end
    else
      MapView.render_zone_info(player, map_object, object_renders, cursor, scale, zone, infobox_flags, spaceship_index)
      body_info_shown = true
    end

    if show_orbit_info and zone.orbit then
      -- ORBIT HEADER

      if body_info_shown then
        cursor.y = cursor.y + 0.25 * scale

        table.insert(object_renders,
                MapView.draw_gradient_line({
                  surface = map_object.entity.surface,
                  from = map_object.entity,
                  to = map_object.entity,
                  players = { player },

                  from_offset = util.vectors_add(cursor, { x = -0.3 * scale, y = 0 }),
                  to_offset = util.vectors_add(cursor, { x = 3.5 * scale, y = 0 }),
                  color = SystemMap.infobox_gradient_tint,
                  width = 2 * scale,
                }))
        cursor.y = cursor.y + 0.15 * scale
      end

      table.insert(object_renders,
              rendering.draw_text({
                surface = map_object.entity.surface,
                target = {entity = map_object.entity, offset = cursor},
                players = {player},
                text = "Orbit",
                color = {r = 128, b = 128, g = 128, a = 255},
                scale_with_zoom = false,
                scale = scale,
              })
      )
      cursor.y = cursor.y + 0.6 * scale

      -- ORBIT INFO

      MapView.render_zone_info(player, map_object, object_renders, cursor, scale, zone.orbit, infobox_flags, spaceship_index)

    end

  end

  local right_side_y = cursor.y


  -- RESOURCES
  cursor = util.vectors_add(main_cursor, { x=-0.3 * scale, y=0.1 * scale})
  if infobox_flags.show_resources and zone.type ~= "star" then
    ---@cast zone -StarType
    MapView.render_zone_resources(player, map_object, object_renders, cursor, scale, zone,
      short and 4 or 7)
  end

  local left_side_y = cursor.y

  -- VERTICAL LINE
  local line_height = (math.max(left_side_y, right_side_y) - horiz_line_cursor.y) * 0.95
  table.insert(object_renders,
          MapView.draw_gradient_line({
            surface = map_object.entity.surface,
            from = map_object.entity,
            to = map_object.entity,
            players = { player },

            from_offset = horiz_line_cursor,
            to_offset = util.vectors_add(horiz_line_cursor, { x = 0, y = line_height }),
            color = SystemMap.infobox_gradient_tint,
            width = 2 * scale,
          }))
end

---@param player LuaPlayer
---@param map_object MapViewEntityInfo
---@param zone SpaceshipType
---@param spaceship_index unknown unused
function MapView.render_spaceship_caption(player, map_object, zone, spaceship_index)
  local map_info = MapView.get_player_map_info(player)
  assert(map_info)

  local color = {r=0, g=196, b=196, a=255}
  local orientation = 0.125

  local size
  local target_offset
  if map_info.type == "interstellar" then
    size = InterstellarMap.spaceship_text_scale
    target_offset = InterstellarMap.spaceship_text_offset
  elseif map_info.type == "system" then
    size = SystemMap.spaceship_text_scale
    target_offset = SystemMap.spaceship_text_offset
  else
    return
  end
  local half_size = map_object.entity.prototype.selection_box.right_bottom.y
  target_offset = util.vectors_add(target_offset, { x = -half_size, y = -half_size })
  target_offset = util.vectors_add(target_offset, { x = 0, y = -0.5 * size })

  table.insert(map_object.text_objects,
          rendering.draw_text{
            text = zone.name,
            surface = MapView.get_make_surface(player),
            target = {entity = map_object.entity, offset = target_offset},
            players = {player},
            color = color,
            orientation = orientation,
            alignment = "right",
            scale = size,
            scale_with_zoom = false,
            use_rich_text = true
          }
  )
end

-- SPACESHIP UPDATES --

---@param player LuaPlayer
function MapView.update_view(player)
  local playerdata = get_make_playerdata(player)
  local map_info = MapView.get_player_map_info(player)
  if not map_info then return end -- Player not in map view
  if not playerdata.map_view_entities then return end

  local spaceship_index = {}
  if map_info.type == "interstellar" then
    spaceship_index = InterstellarMap.get_spaceship_index(player)
  elseif map_info.type == "system" then
    spaceship_index = SystemMap.get_spaceship_index(player, map_info.zone)
  end

  local bound_spaceships = spaceship_index.bound or {}
  local flying_spaceships = spaceship_index.flying or {}
  local flying_by_spaceship_index = {}
  for _, spaceship in pairs(flying_spaceships) do
    flying_by_spaceship_index[spaceship.index] = spaceship
  end

  local seen_flying = {}
  for _, map_object in pairs(playerdata.map_view_entities) do
    local entity = map_object.entity
    if entity and entity.valid and map_object.zone then
      if map_object.zone and map_object.zone.type == "spaceship" then
        local spaceship = map_object.zone --[[@as SpaceshipType]]
        seen_flying[spaceship.index] = true
        if not flying_by_spaceship_index[spaceship.index] then
          -- spaceship is no longer flying here
          MapObjects.destroy(player, map_object)
        else
          -- update spaceship position and orientation
          entity.teleport(MapView.get_zone_position(player, spaceship))
          MapObjects.set_orientation(map_object, MapView.get_spaceship_orientation(player, spaceship))
        end
      else
        -- not a spaceship, update zone caption to account for changes in anchored spaceships
        MapView.render_zone_caption(player, map_object, map_object.zone, bound_spaceships)
      end
    end
  end

  -- render new spaceships
  for _, spaceship in pairs(flying_spaceships) do
    if not seen_flying[spaceship.index] then
      -- render new spaceship
      MapView.render_spaceship(player, spaceship)
    end
  end

end

---@param player LuaPlayer
---@param spaceship SpaceshipType
function MapView.render_spaceship(player, spaceship)
  local surface = MapView.get_make_surface(player)
  local playerdata = get_make_playerdata(player)
  local map_info = MapView.get_player_map_info(player)
  assert(map_info)

  if map_info.type == "interstellar" then
    InterstellarMap.render_spaceship(player, surface, spaceship, playerdata)
  else
    local star = map_info.zone
    SystemMap.render_spaceship(player, surface, star, spaceship, playerdata)
  end
end

---@param player LuaPlayer
---@param spaceship SpaceshipType
---@return RealOrientation
function MapView.get_spaceship_orientation(player, spaceship)
  local map_info = MapView.get_player_map_info(player)
  assert(map_info)
  local destination_zone = Spaceship.get_destination_zone(spaceship)

  -- no destination set, or standing still near a zone
  if not destination_zone or spaceship.near or spaceship.stopped then
    return 0.625 -- oriented bottom left
  end

  if map_info.type == "interstellar" then
    local travel_vector = util.vectors_delta(spaceship.stellar_position, Zone.get_stellar_position(destination_zone))
    return 0.25 + util.vector_to_orientation(travel_vector)
  elseif map_info.type == "system" then
    local star = map_info.zone
    local destination_star_gravity_well = Zone.get_star_gravity_well(destination_zone)
    if util.vectors_delta_length(spaceship.stellar_position, Zone.get_stellar_position(destination_zone)) > 0
            or Zone.get_space_distortion(destination_zone) > 0 then
      -- destination in another system, you need to get out of the current system
      destination_star_gravity_well = -1
    end
    if spaceship.planet_gravity_well <= 0 and spaceship.star_gravity_well ~= destination_star_gravity_well then
      -- travelling through star_gravity_well
      if spaceship.star_gravity_well > destination_star_gravity_well then
        return 0.5
      else
        return 0
      end
    else
      local direction_offset = 0.75
      if spaceship.star_gravity_well == destination_star_gravity_well
              and spaceship.planet_gravity_well < Zone.get_planet_gravity_well(destination_zone) then
        direction_offset = 0.25
      end
      local solar_position_data = SystemMap.get_zone_position_data(star, spaceship)
      return direction_offset - solar_position_data.orientation
    end
  end

  -- everything should be covered but just in case return the default
  return 0.625
end



-- MAP OBJECTS MANAGEMENT --

---@param player LuaPlayer
---@param surface LuaSurface
---@param context AnyZoneType|StarType|SpaceshipType|"interstellar-space" either a zone, or a non-zone space (e.g. "interstellar-space")
---@param entity_name string
---@param position Vector.0
---@return MapViewEntityInfo
function MapObjects.create(player, surface, context, entity_name, position)
  local zone = nil
  if type(context) == "table" then
    zone = context
    context = "zone"
  end

  local playerdata = get_make_playerdata(player)

  local entity = surface.create_entity{
    name = entity_name,
    position = position,
    force = "neutral"
  }
  ---@cast entity -?
  entity.destructible = false

  ---@type MapViewEntityInfo
  local map_object = {
    entity = entity,
    context = context, -- "zone" or "interstellar-space"
    zone = zone,
    objects = {},
    text_objects = {}
  }

  playerdata.map_view_entities = playerdata.map_view_entities or {}
  playerdata.map_view_entities[entity.unit_number] = map_object

  return playerdata.map_view_entities[entity.unit_number]
end

---@param player LuaPlayer
---@param map_object MapViewEntityInfo
function MapObjects.destroy(player, map_object)
  if map_object and map_object.entity and map_object.entity.valid then
    local entity = map_object.entity
    local playerdata = get_make_playerdata(player)
    if not playerdata.map_view_entities[entity.unit_number] then
      return
    end

    playerdata.map_view_entities[entity.unit_number] = nil
    entity.destroy()
  end
end

---@param map_object MapViewEntityInfo
---@param orientation RealOrientation
function MapObjects.set_orientation(map_object, orientation)
  for _, rendering_object in pairs(map_object.main_objects or {}) do
    rendering_object.orientation = orientation
  end
end


-- EVENT HANDLERS --
---@param event EventData.on_tick Event data
function MapView.on_map_tick(event)
  if (event.tick % 60) == 40 then
    for _, player in pairs(game.connected_players) do
      MapView.update_view(player) -- Does nothing if player not in map view
    end
  end
end
Event.addListener(defines.events.on_tick, MapView.on_map_tick)

---Handles player interaction with proxy lamp entities, switching to the appropriate map or opening
---zone data GUI when appropriate
---@param event EventData.on_gui_opened Event data
function MapView.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if event.entity and event.entity.valid and event.entity.type == "lamp" then
    local playerdata = get_make_playerdata(player)
    if playerdata.map_view_entities then
      local map_object = playerdata.map_view_entities[event.entity.unit_number]
      if map_object then
        if map_object.command == "system" then
          player.opened = nil -- close
          if Zone.is_visible_to_force(map_object.zone, player.force.name ) then
            MapView.start_system_map(player, map_object.zone)
          else
            player.print({"space-exploration.interstellar_launch_satellite_to_see_star"})
          end
        elseif map_object.command == "interstellar" then
          player.opened = nil -- close
          MapView.start_interstellar_map(player)
        elseif map_object.command == "details" then
          MapView.gui_open(player, map_object.zone)
        end
      end
    end
  end
  if event.gui_type == defines.gui_type.controller then
    if MapView.player_is_in_map(player) then
      player.opened = nil
    end
  end
end
Event.addListener(defines.events.on_gui_opened, MapView.on_gui_opened)

---Closes the MapView zone data GUI in response to `Esc` and `E`.
---@param event EventData.on_gui_closed Event data
function MapView.on_gui_closed(event)
  if event.element and event.element.valid and event.element.name == MapView.name_gui_zone_details_root then
    MapView.gui_close(game.get_player(event.player_index) --[[@as LuaPlayer]])
  end
end
Event.addListener(defines.events.on_gui_closed, MapView.on_gui_closed)

---@param player LuaPlayer
---@return Flags?
function MapView.get_make_settings(player)
  local playerdata = get_make_playerdata(player)
  playerdata.starmap_settings = playerdata.starmap_settings or {
    show_resources = false,
    show_stats = false,
    show_anchor_info = false,
    show_danger_zones = true,
  }
  return playerdata.starmap_settings
end

---@param player LuaPlayer
---@return Flags?
function MapView.get_settings(player)
  local settings = MapView.get_make_settings(player)
  if not player.force.technologies[MapView.tech_spaceship].researched then
    settings = table.deepcopy(settings)
    settings["show_anchor_info"] = nil
  end
  return settings
end

---@param player LuaPlayer
---@param setting_name string
function MapView.toggle_setting(player, setting_name)
  local settings = MapView.get_make_settings(player)
  settings[setting_name] = not settings[setting_name]
  if setting_name == "show_danger_zones" then
    MapView.internal_restart_map(player)
  else
    MapView.update_view(player)
  end
end

-- ZONE DETAILS GUI --

---Returns a given player's MapView zone data GUI, if open.
---@param player LuaPlayer Player
---@return LuaGuiElement? root
function MapView.gui_get(player)
  return player.gui.screen[MapView.name_gui_zone_details_root]
end

---Opens the MapView GUI for the given player, showing the given zone's data.
---@param player LuaPlayer Player
---@param zone AnyZoneType|StarType|SpaceshipType Zone or spaceship
function MapView.gui_open(player, zone)
  local root = MapView.gui_get(player)
  if root then MapView.gui_update(player, zone) return end

  if not zone then return end
  if zone.type == "star" then zone = zone.orbit end
  ---@cast zone OrbitType

  local playerdata = get_make_playerdata(player)

  root = player.gui.screen.add{
    type = "frame",
    name = MapView.name_gui_zone_details_root,
    direction = "vertical",
    tags = {
      zone_type = zone.type,
      zone_index = zone.index
    },
    style = "se_zonelist_root_frame"
  }
  root.force_auto_center()

  do -- Titlebar
    local titlebar_flow = root.add{
      type = "flow",
      name = MapView.name_gui_titlebar_flow,
      direction = "horizontal",
      style = "se_relative_titlebar_flow"
    }
    titlebar_flow.drag_target = root
    titlebar_flow.style.bottom_padding = 4

    local button_flow = titlebar_flow.add{
      type = "flow",
      name = MapView.name_gui_titlebar_button_flow,
      direction = "horizontal",
      style = "se_relative_titlebar_flow"
    }

    button_flow.add{
      type = "sprite-button",
      tags = {action=MapView.action_zone_button},
      style = "frame_action_button"
    }
    button_flow.add{
      type = "sprite-button",
      tags = {action=MapView.action_zone_button},
      style = "frame_action_button"
    }

    titlebar_flow.add{
      type = "empty-widget",
      ignored_by_interaction = true,
      style = "se_titlebar_drag_handle"
    }

    titlebar_flow.add{ -- Show/hide surface preview
      type = "sprite-button",
      sprite = playerdata.zonelist_show_surface_preview and "se-show-black" or "se-show-white",
      hovered_sprite = "se-show-black",
      clicked_sprite = "se-show-black",
      style = playerdata.zonelist_show_surface_preview and "se_frame_action_button_active" or "frame_action_button",
      tooltip = {"space-exploration.zonelist-show-surface-preview"},
      tags = {action=Zonelist.action_show_preview_frame}
    }
    titlebar_flow.add{ -- Close button
      type = "sprite-button",
      sprite = "utility/close",
      tags = {action=MapView.action_close_button},
      style="close_button"
    }
  end

  Zonelist.make_zone_data_section(root)

  player.opened = root

  MapView.gui_update(player, zone)
end

---Updates the MapView GUI.
---@param player LuaPlayer Player
---@param zone? AnyZoneType|SpaceshipType Zone or spaceship
function MapView.gui_update(player, zone)
  local root = MapView.gui_get(player)
  if not root then return end

  if zone then
    util.update_tags(root, {zone_type=zone.type, zone_index=zone.index})
  else
    zone = util.get_zone_from_tags(root.tags)
  end
  if not zone then return end

  local button_flow = root[MapView.name_gui_titlebar_flow][MapView.name_gui_titlebar_button_flow]
  local solid_body = button_flow.children[1]
  local orbit = button_flow.children[2]

  -- Show/hide the titlebar buttons, updating their sprites, tags and tooltips if appropriate
  if zone.type == "planet" or zone.type == "moon" then
    ---@cast zone PlanetType|MoonType
    solid_body.sprite = Zone.get_icon(zone)
    orbit.sprite = Zone.get_icon(zone.orbit)

    util.update_tags(solid_body, {zone_type=zone.type, zone_index=zone.index})
    util.update_tags(orbit, {zone_type=zone.orbit.type, zone_index=zone.orbit.index})

    solid_body.tooltip = Zone.type_title(zone)
    orbit.tooltip = Zone.type_title(zone.orbit)

    solid_body.style = "se_frame_action_button_active"
    orbit.style = "frame_action_button"

    button_flow.visible = true
  elseif zone.type == "orbit" and zone.parent.type ~= "star" then
    ---@cast zone OrbitType
    solid_body.sprite = Zone.get_icon(zone.parent)
    orbit.sprite = Zone.get_icon(zone)

    util.update_tags(solid_body, {zone_type=zone.parent.type, zone_index=zone.parent.index})
    util.update_tags(orbit, {zone_type=zone.type, zone_index=zone.index})

    solid_body.tooltip = Zone.type_title(zone.parent)
    orbit.tooltip = Zone.type_title(zone)

    solid_body.style = "frame_action_button"
    orbit.style = "se_frame_action_button_active"

    button_flow.visible = true
  else
    button_flow.visible = false
  end

  Zonelist.update_zone_data(player, zone, root[Zonelist.name_right_flow])
end

---Closes the MapView GUI for the given player.
---@param player LuaPlayer Player
function MapView.gui_close(player)
  local root = MapView.gui_get(player)
  if root then root.destroy() end
end

---Handles clicks for the MapView GUI.
---@param event EventData.on_gui_click Event data
function MapView.on_gui_click(event)
  if not event.element.valid then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?

  if element.tags and element.tags.se_action == "starmap-cycle" then
    MapView.starmap_view_cycle(player)
    return
  end

  local root = gui_element_or_parent(element, MapView.name_gui_zone_details_root)
  local action = element.tags.action

  if root and action then
    if action == MapView.action_close_button then
      MapView.gui_close(player)
    elseif action == MapView.action_zone_button then
      local zone = util.get_zone_from_tags(element.tags)
      if zone then
        MapView.gui_update(player, zone)
      end
    end
  end
end
Event.addListener(defines.events.on_gui_click, MapView.on_gui_click)

---@param player_index uint
function MapView.update_overhead_button(player_index)
  local player = game.get_player(player_index)
  ---@cast player -?
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow then
    if settings.get_player_settings(player)[MapView.name_setting_overhead_interstellar].value == true then
      if not button_flow[MapView.name_button_overhead_interstellar] then
        button_flow.add{type="sprite-button", name=MapView.name_button_overhead_interstellar, sprite="se-map-gui-starmap", tags={se_action="starmap-cycle"}}
      end
      if MapView.is_unlocked(player) then
        button_flow[MapView.name_button_overhead_interstellar].enabled = true
        button_flow[MapView.name_button_overhead_interstellar].tooltip = {"space-exploration.star-map"}
      else
        button_flow[MapView.name_button_overhead_interstellar].enabled = false
        button_flow[MapView.name_button_overhead_interstellar].tooltip = MapView.unlock_requirement_string(player)
      end
    else
      if button_flow[MapView.name_button_overhead_interstellar] then
        button_flow[MapView.name_button_overhead_interstellar].destroy()
      end
    end
  end
end


---@param event EventData.on_lua_shortcut Event data
function MapView.on_lua_shortcut(event)
  if event.prototype_name == MapView.name_shortcut then
    return MapView.starmap_view_cycle(game.get_player(event.player_index))
  end
end
Event.addListener(defines.events.on_lua_shortcut, MapView.on_lua_shortcut)

---@param event EventData.CustomInputEvent Event data
function MapView.on_remote_view_keypress(event)
  if event.input_name == MapView.name_event then
    return MapView.starmap_view_cycle(game.get_player(event.player_index))
  end
end
Event.addListener(MapView.name_event, MapView.on_remote_view_keypress)

---@param event EventData.on_runtime_mod_setting_changed Event data
function MapView.on_runtime_mod_setting_changed(event)
  if event.player_index and event.setting == MapView.name_setting_overhead_interstellar then
      MapView.update_overhead_button(event.player_index)
  end
end
Event.addListener(defines.events.on_runtime_mod_setting_changed, MapView.on_runtime_mod_setting_changed)

function MapView.on_configuration_changed()
  for _, player in pairs(game.connected_players) do
    MapView.update_overhead_button(player.index)
  end
end
Event.addListener("on_configuration_changed", MapView.on_configuration_changed, true)

---@param event EventData.on_player_changed_force Event data
function MapView.on_player_changed_force(event)
  MapView.update_overhead_button(event.player_index)
end
Event.addListener(defines.events.on_player_changed_force, MapView.on_player_changed_force)

---@param event EventData.on_player_created
function MapView.on_player_created(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  if RemoteView.is_intersurface_unlocked(player) then
    MapView.get_make_surface(player) -- Cache the map surface so long
  end
end
Event.addListener(defines.events.on_player_created, MapView.on_player_created)

return MapView
