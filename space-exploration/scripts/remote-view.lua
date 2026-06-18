local RemoteView = {}
--[[ Wrapper to the vanilla remote view ]]--

-- constants
RemoteView.name_shortcut = mod_prefix .. "remote-view"
RemoteView.name_event = mod_prefix .. "remote-view"
RemoteView.name_pins_event = mod_prefix .. "remote-view-pins"
RemoteView.name_setting_overhead_satellite = mod_prefix .. "show-overhead-button-satellite-mode"
RemoteView.name_satellite_light = mod_prefix .. "satellite-light"
RemoteView.max_history = 16 -- not visible to player, could be lower but no need
RemoteView.nb_satellites_to_unlock_intersurface = 2

---@type table<RemoteViewActivityType, ZoomLimits>
RemoteView.temporary_activity_zoom_limits = {
  ["map"] = {
    closest = { zoom = 3}, -- Same as normal character controller
    furthest = { zoom = 0.1}, -- Prevent zooming too far out (normal 0.04)
    furthest_game_view = { zoom = 0.1}, -- Same as furthest
  },
  ["spaceship-anchor-scouting"] = {
    closest = { zoom = 1}, -- Less than normal character controller
    furthest = { zoom = 0.1}, -- Prevent zooming too far out (normal 0.04)
    furthest_game_view = { zoom = 0.1}, -- Same as furthest
  },
}

---@param player LuaPlayer
---@return RemoteViewData?
function RemoteView.get_data(player)
  local playerdata = get_make_playerdata(player)
  return playerdata.remote_view_data
end

---@param player LuaPlayer
---@return RemoteViewData
function RemoteView.get_make_remote_view_data(player)
  local playerdata = get_make_playerdata(player)
  playerdata.remote_view_data = playerdata.remote_view_data or { }
  return playerdata.remote_view_data
end

---@param player LuaPlayer
---@param activity_type RemoteViewActivityType? Optionally filter by activity type
---@return RemoteViewActivity?
function RemoteView.get_activity(player, activity_type)
  local remote_view_data = RemoteView.get_data(player)
  if not remote_view_data then return end
  if not remote_view_data.activity then return end
  if activity_type and remote_view_data.activity.type ~= activity_type then return end
  return remote_view_data.activity
end

---destroys remote view satellite light
---@param player LuaPlayer
function RemoteView.destroy_light(player)
  local remote_view_data = RemoteView.get_data(player)
  if not remote_view_data then return end

  if remote_view_data.satellite_light then
    remote_view_data.satellite_light.destroy() -- Works even if invalid
  end

  remote_view_data.satellite_light = nil
end

---create satellite light for remote view players
---@param player LuaPlayer
function RemoteView.create_light(player)
  local remote_view_data = RemoteView.get_data(player)
  if not remote_view_data then return end

  RemoteView.destroy_light(player) -- Make sure there's no light
  remote_view_data.satellite_light = rendering.draw_light{
    sprite = RemoteView.name_satellite_light,
    surface = player.surface,
    target = player.position,
    scale = 4,
    players = {player}
  }
end

---@param player LuaPlayer
---@param force_exit boolean?
function RemoteView.stop(player, force_exit)
  local remote_view_data = RemoteView.get_data(player)
  if not remote_view_data then return end -- player was not in remote view. Prevents recursive call

  -- remove ghost targeters after exiting targeting modes
  if player.cursor_ghost and player.cursor_ghost.name and player.cursor_ghost.name.name
    and (EnergyBeam.is_targeter(player.cursor_ghost.name.name) or DeliveryCannon.is_targeter(player.cursor_ghost.name.name)) then
      player.cursor_ghost = nil
  end

  -- Abort if player is in a cutscene; fix for factorio-mods#182
  if not force_exit and player.controller_type == defines.controllers.cutscene then
    player.print({"space-exploration.remote-view-stop-in-cutscene"})
    return
  end

  -- exit remote view
  RemoteView.destroy_light(player)

  RemoteViewGUI.close(player)

  local playerdata = get_make_playerdata(player)
  Spaceship.stop_anchor_scouting(player)

  remote_view_data.activity = nil -- So that zoom limits can be reset properly
  RemoteView.update_zoom_limits(player, remote_view_data)
  playerdata.remote_view_data = nil
  player.exit_remote_view()

  -- Call this after completely ending the remote view to avoid recursive call  
  MapView.stop_map(player)
  Event.trigger("on_remote_view_stopped", {player=player})
end

---Adds the current position as a location reference to player's navigation history at index 1.
---@param player LuaPlayer Player
function RemoteView.add_history_current(player)
  local location_reference = Location.make_reference(Zone.from_surface(player.surface), player.position, nil, player.opened_gui_type == defines.gui_type.entity and player.opened or nil, player.zoom)
  RemoteView.add_history(player, location_reference)
end

---Adds a given location reference to player's navigation history.
---@param player LuaPlayer Player
---@param location_reference? LocationReference Location reference
function RemoteView.add_history(player, location_reference)
  if not location_reference then return end

  local playerdata = get_make_playerdata(player)
  if not playerdata.location_history then
    playerdata.location_history = {location_reference}
  else
    -- don't add duplicate
    if next(playerdata.location_history) then
      local last_ref = playerdata.location_history[1]
      if last_ref.type == location_reference.type and last_ref.index == location_reference.index then
        -- same zone, maybe have a setting to not have multiple history events on the same zone.
        if last_ref.position == nil or last_ref.name == nil then
          -- replace the postionless location
          playerdata.location_history[1] = location_reference
        elseif location_reference.position and Util.vectors_delta_length(last_ref.position, location_reference.position) > 1 then
          -- add different position
          table.insert(playerdata.location_history, 1, location_reference)
        end
      else -- different zone, always add
        table.insert(playerdata.location_history, 1, location_reference)
      end
    else
      table.insert(playerdata.location_history, 1, location_reference)
    end

    -- fit in max history
    while #playerdata.location_history > RemoteView.max_history do
      table.remove(playerdata.location_history, #playerdata.location_history)
    end
  end
end

--[[
Makes the data valid.
Deletes histories to deleted surfaces/spaceships
]]
---@param player LuaPlayer
function RemoteView.make_history_valid(player)
  local playerdata = get_make_playerdata(player)
  if playerdata.location_history then
    local old_history = playerdata.location_history
    playerdata.location_history = {}
    for _, location_reference in pairs(old_history) do
      if Location.from_reference(location_reference) then
        RemoteView.add_history(player, location_reference, true)
      end
    end
  end
end

---@param player LuaPlayer
---@param pop boolean? Whether to delete the returned history point from the history. Defaults to false.
---@return LocationReference?
function RemoteView.history_previous(player, pop)
  local playerdata = get_make_playerdata(player)
  if playerdata.location_history and playerdata.location_history[1] then
    local location_reference = playerdata.location_history[1]
    if pop then table.remove(playerdata.location_history, 1) end
    return location_reference
  end
end

---@param force_name string
---@return boolean
function RemoteView.is_unlocked_force(force_name)
  return storage.debug_view_all_zones or (storage.forces[force_name] and storage.forces[force_name].satellites_launched >= 1)
end

---@param player LuaPlayer
---@return boolean
function RemoteView.is_unlocked(player)
  -- Players can always use remote view. Unlocking it simply means that SE
  -- will automatically chart the area around the player while in remote view.
  -- The odd naming is due to legacy reasons.
  return RemoteView.is_unlocked_force(player.force.name)
end

---@param player LuaPlayer
---@return LocalisedString
function RemoteView.unlock_requirement_string(player)
  if is_player_force(player.force.name) then
    return {"space-exploration.remote-view-requires-satellite"}
  else
    return {"space-exploration.cannot-use-with-force"}
  end
end

---@param force_name string
---@return boolean
function RemoteView.is_intersurface_unlocked_force(force_name)
  return storage.debug_view_all_zones or (storage.forces[force_name] and storage.forces[force_name].satellites_launched >= RemoteView.nb_satellites_to_unlock_intersurface)
end

---@param player LuaPlayer
---@return boolean
function RemoteView.is_intersurface_unlocked(player)
  return RemoteView.is_intersurface_unlocked_force(player.force.name)
end

---@param player LuaPlayer
---@return LocalisedString
function RemoteView.intersurface_unlock_requirement_string(player)
  if is_player_force(player.force.name) then
    return {"space-exploration.remote-view-intersurface-requires-satellite", RemoteView.nb_satellites_to_unlock_intersurface - storage.forces[player.force.name].satellites_launched}
  else
    return {"space-exploration.cannot-use-with-force"}
  end
end

---@param force_name string
---@param err_str string
---@return LocalisedString
function RemoteView.intersurface_unlock_requirement_string_2(force_name, err_str)
  err_str = err_str or "space-exploration.remote-view-intersurface-requires-satellite"
  return {err_str, RemoteView.nb_satellites_to_unlock_intersurface - storage.forces[force_name].satellites_launched}
end

---@param player LuaPlayer
---@param remote_view_data RemoteViewData nil if going out of remote view
function RemoteView.update_zoom_limits(player, remote_view_data)

  local temporary_zoom_limits = remote_view_data.activity and RemoteView.temporary_activity_zoom_limits[remote_view_data.activity.type]
  if temporary_zoom_limits then

    -- Store the current zoom limits so they can be restored later. 
    -- Never override existing stashed zoom limits! It could be that we're coming
    -- from some other activity that also set custom zoom limits. So we make the assumption
    -- that if nothing is stashed then it's intended normal limits
    if not remote_view_data.stashed_zoom_limits then
      remote_view_data.stashed_zoom_limits = player.zoom_limits
    end

    player.set_zoom_limits(defines.controllers.remote, temporary_zoom_limits)

  elseif remote_view_data.stashed_zoom_limits then
    -- Previously some zoom limits were stashed after custom limits were set. Now we can reset it
    player.set_zoom_limits(defines.controllers.remote, remote_view_data.stashed_zoom_limits)
  end

end

---@param player LuaPlayer
---@param zone AnyZoneType|SpaceshipType?
---@param surface LuaSurface?
---@param position MapPosition?
---@param zoom number?
local function internal_remote_view_start(player, zone, surface, position, zoom)
  assert(not zone or not surface, "Either zone or surface must be provided, not both")

  if not surface then
    zone = zone or Zone.from_surface(player.surface)

    -- If in a vault, get the zone it belongs to
    if not zone then
      local vault = Ancient.vault_from_surface(player.surface)
      if vault then
        zone = Zone.from_zone_index(vault.zone_index)
      end
    end

    -- This probably should be changed for MP with multiple forces, as some may not know about Nauvis
    -- It should get the force's homeworld
    if not zone then
      zone = Zone.get_default()
    end
  end

  -- Start setting up actual remote view now
  local playerdata = get_make_playerdata(player)
  local remote_view_data = RemoteView.get_make_remote_view_data(player)
  remote_view_data.has_radar = RemoteView.is_unlocked(player)
  remote_view_data.current_zone = nil

  if zone then
    remote_view_data.current_zone = zone

    if zone.type == "spaceship" then
      ---@cast zone SpaceshipType
      local spaceship = zone
      surface = Spaceship.get_current_surface(zone)
      if position then
        -- Nothing to do
      elseif spaceship.known_tiles_average_x and spaceship.known_tiles_average_y then
        -- It's nicest to place the view in the middle of the spaceship, rather than at the console
        position = {x=spaceship.known_tiles_average_x,y=spaceship.known_tiles_average_y}
      elseif spaceship.console and spaceship.console.valid then
        position = spaceship.console.position
      else
        position = {x=0,y=0}
      end

      -- Nicely frame the spaceship zoom level so that the entire height is visible with some buffer
      if not zoom and spaceship.known_bounds then
        local height = spaceship.known_bounds.right_bottom.y - spaceship.known_bounds.left_top.y
        local screen_height_pixels = player.display_resolution.height / player.display_scale / player.display_density_scale
        zoom = (screen_height_pixels * 0.8) / (height * 32) -- 32 pixels per tile at zoom 1.0 with 20% padding
        zoom = math.max(0.1, math.min(zoom, 2.0)) -- Clamp zoom to reasonable bounds
      end

    else
      ---@cast zone -SpaceshipType
      surface = Zone.get_make_surface(zone)
      if not playerdata.surface_positions or not playerdata.surface_positions[surface.index] then
        player.force.chart(surface, util.position_to_area({x = 0, y = 0}, 64)) -- smaller region first
        player.force.chart(surface, util.position_to_area({x = 0, y = 0}, 256))
      elseif not position then
        position = playerdata.surface_positions[zone.surface_index]
      end
      if not position then
        position = {x = 0, y = 0}
      end
      Zone.apply_markers(zone) -- in case the surface exists
    end

    -- if we start remote view at the last saved history point, delete this point (e.g. go into starmap and select the same zone in explorer)
    if RemoteView.history_previous(player) then
      local location = Location.from_reference(RemoteView.history_previous(player))
      if location.zone and location.zone == zone then
        RemoteView.history_previous(player, true)
      end
    end
  end

  -- Hide SurfaceList from RemoteView
  local game_view_settings = player.game_view_settings
  game_view_settings.show_surface_list = (script.active_mods["space-age"] and settings.startup["se-space-age-mod-support"].value) == true
  player.game_view_settings = game_view_settings

  assert(position) -- Should be known by now

  -- local player_opened = player.opened
  if player.controller_type == defines.controllers.remote and player.surface == surface and util.vectors_delta_length_sq(player.position, position) < 1 then
    -- don't add an engine history point
    player.teleport(position)
  else
    player.set_controller{
      type = defines.controllers.remote,
      surface = surface,
      position = position,
    }
  end
  -- Executing player.set_controller{} makes the LuaGuiElement in player_opened invalid.
  --player.opened = player_opened

  RemoteView.update_zoom_limits(player, remote_view_data)
  if zoom then player.zoom = zoom end
  RemoteViewGUI.open(player) -- Should this be done for activities too?

  Event.trigger("on_remote_view_started", {player=player, zone=zone, surface=surface, position=position, zoom=zoom})
end

---Stop all activities
---@param player LuaPlayer
local function stop_activities(player)
  local remote_view_data = RemoteView.get_data(player)
  if not (remote_view_data and remote_view_data.activity) then return end -- nothing to stop

  --TODO(HW): Do smarter? What about other activities? Be careful of recursive calls
  remote_view_data.activity = nil
  Spaceship.stop_anchor_scouting(player)
end

---Starts regular remote view for a given player.
---@note This will stop any ongoing activities.
---@param player LuaPlayer Player
---@param zone? AnyZoneType|SpaceshipType Zone to open
---@param position? MapPosition Position to go to, if any
---@param zoom? number Zoom level, if any
function RemoteView.start(player, zone, position, zoom)
  if not is_player_force(player.force.name) then
    RemoteView.stop(player, true)
    return player.print({"space-exploration.cannot-use-with-force"})
  end

  if zone and zone.surface_index ~= player.surface.index then
    if not RemoteView.is_intersurface_unlocked(player) then
      return player.print(RemoteView.intersurface_unlock_requirement_string(player))
    end
  end

  stop_activities(player)
  internal_remote_view_start(player, zone, nil, position, zoom)

  player.enable_flashlight()
  RemoteView.create_light(player)
end

---@param player LuaPlayer
---@param activity RemoteViewActivity
---@param zone? AnyZoneType|SpaceshipType Zone to open
---@param position? MapPosition Position to go to
function RemoteView.start_activity(player, activity, zone, position)

  if activity.type == "map" then
    assert(activity.map_info)
    assert(activity.map_info.map_surface and activity.map_info.map_surface.valid)
    assert(position)
    local remote_view_data = RemoteView.get_make_remote_view_data(player)
    remote_view_data.activity = activity
    internal_remote_view_start(player, nil, activity.map_info.map_surface, position, 0.4)

    player.disable_flashlight() -- Of the remote view. Don't want it in maps.
    RemoteView.destroy_light(player)

    -- Chart the are around the player to prevent black screen
    player.force.chart(player.surface, util.position_to_area(player.position, 4 * 32, 1.25))

  else
    -- All other types, just pass throught to the normal remote view start
    local remote_view_data = RemoteView.get_make_remote_view_data(player)
    remote_view_data.activity = activity
    internal_remote_view_start(player, zone, nil, position)
    player.enable_flashlight()
    RemoteView.create_light(player)
  end
end

---@param player LuaPlayer
---@return boolean
function RemoteView.is_active(player)
  return get_make_playerdata(player).remote_view_data ~= nil
end

---@param player LuaPlayer
function RemoteView.toggle(player)
  if RemoteView.is_active(player) then
    RemoteView.stop(player)
  else
    RemoteView.start(player)
  end
end

---@param event EventData.on_player_controller_changed
function RemoteView.on_player_controller_changed(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local playerdata = get_make_playerdata(player)
  if playerdata.remote_view_data and not (player.controller_type == defines.controllers.remote) then
    RemoteView.stop(player) -- This will also stop all activities
  elseif player.controller_type == defines.controllers.remote and not playerdata.remote_view_data then
    if playerdata.last_clicked_gps_tag and playerdata.last_clicked_gps_tag.is_starmap_surface then
      MapView.stop_map(player)
      MapView.starmap_view_cycle(player)
      playerdata.last_clicked_gps_tag = nil
    else
      if Zone.from_surface(player.surface) or Ancient.vault_from_surface(player.surface) then
        RemoteView.start(player)
      end
    end
  end
end
Event.addListener(defines.events.on_player_controller_changed, RemoteView.on_player_controller_changed)

---@param event EventData.on_player_changed_surface Event data
function RemoteView.on_player_changed_surface(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  if player.controller_type == defines.controllers.character then
    -- if we pressed M to go back from remote to character, check if we have a history point to go
    local location = RemoteView.history_previous(player, true)
    if location then
      Location.goto_reference(player, location)
      return
    end
  end

  -- if this has gone to a starmap surface but we're not in starmap mode...
  if MapView.is_surface_starmap(player.surface) then
    if not MapView.player_is_in_map(player) then
      MapView.starmap_view_cycle(player)
    end
  end

  local zone = Zone.from_surface(player.surface)
  if not zone then
    local vault = Ancient.vault_from_surface(player.surface)
    if vault then
      zone = Zone.from_zone_index(vault.zone_index)
    end
  end

  -- RemoteView is already active, so check if playerdata.remote_view_data.current_zone
  -- matches with the current surface and if not we should trigger the update of
  -- that datastructure.
  local playerdata = get_make_playerdata(player)
  local remote_view_data = playerdata.remote_view_data
  if remote_view_data then
    local surface_index_to_view

    local current_zone = remote_view_data.current_zone
    if current_zone then
     surface_index_to_view = current_zone.surface_index

      if not surface_index_to_view and current_zone.type == "spaceship" then
        -- The `surface_index` property doesn't exist on spaceships.
        surface_index_to_view = Spaceship.get_current_surface(current_zone --[[@as SpaceshipType]]).index
      end
    end

    if surface_index_to_view ~= player.surface_index then
      if zone then
        RemoteView.start(player, zone)
      elseif not MapView.is_surface_starmap(player.surface) then
        -- Something went wrong, stop remote view. This can happen if a player uses
        -- back/forward history to go to a landed spaceship's cached surface.
        local previous_surface = player.surface
        local previous_position = player.position
        RemoteView.stop(player)
        if not Ancient.vault_from_surface(player.surface) then
          -- for non-zone and non-vault surfaces, stop remote view to reset all data and then start vanilla remote view
          RemoteView.history_previous(player, true)
          player.set_controller{type = defines.controllers.remote, surface = previous_surface, position = previous_position}
        end
      end
    end
    -- Move light with player when they change surfaces.
    RemoteView.create_light(player) -- Will also destroy the light if it exists
  elseif zone and player.controller_type == defines.controllers.remote then
    -- player viewed a non-SE surface before
    RemoteView.start(player, zone)
  end
end
Event.addListener(defines.events.on_player_changed_surface, RemoteView.on_player_changed_surface)

---Handles clicks for remote view.
---@param event EventData.on_gui_click Event data
function RemoteView.on_gui_click(event)
  if not (event.element and event.element.valid) then return end

  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?

  if element.tags and element.tags.se_action == "go_to_entity_and_select" then
    local surface = game.get_surface(element.tags.surface_index --[[@as uint]])
    if surface then
      local zone = Zone.from_surface(surface)
      if zone then
        player.clear_cursor()
        local entity = surface.find_entity(
          element.tags.name --[[@as string]],
          element.tags.position --[[@as MapPosition]]
        )
        RemoteView.start(player, zone, element.tags.position)
        if entity then player.opened = entity end
      else
        RemoteView.stop(player)
      end
    end
  end
end
Event.addListener(defines.events.on_gui_click, RemoteView.on_gui_click)

---@param event EventData.CustomInputEvent Event data
function RemoteView.on_remote_view_pins_keypress(event)
  if event.player_index
    and game.get_player(event.player_index)
    and game.get_player(event.player_index).connected
  then
    Pin.window_toggle(game.get_player(event.player_index))
  end
end
Event.addListener(RemoteView.name_pins_event, RemoteView.on_remote_view_pins_keypress)

---@param event EventData.on_player_clicked_gps_tag Event data
function RemoteView.on_player_clicked_gps_tag(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local playerdata = get_make_playerdata(player)
  if playerdata.spectator then return end
  local surface = game.get_surface(event.surface)
  if surface then
    local zone = Zone.from_surface(surface)
    if not zone then
      if event.surface ~= player.surface.name then
        return player.print({"space-exploration.gps_no_zone"})
      end
      if string.match(surface.name, "^spaceship%-.*") then
        -- This GPS points to a cached spaceship surface where the spaceship is currently landed
        -- We explicitly stop the remote view, which would stop remote view even if the player
        -- was in remote view. Otherwise it's possible to view the empty spaceship surface in some conditions.
        RemoteView.stop(player)
        return
      end
      if MapView.is_surface_starmap(surface) then
        local map_owner = MapView.get_player_index_from_surface(surface)
        local map_owner_playerdata = get_make_playerdata(game.get_player(map_owner))
        playerdata.last_clicked_gps_tag = {
          tick = event.tick,
          is_starmap_surface = true,
          position = table.deepcopy(event.position),
          mapview_data = table.deepcopy(map_owner_playerdata.last_made_gps_tag.starmap_active_map)
        }
      end
    else
      if not RemoteView.is_intersurface_unlocked(player) then
        if event.surface ~= player.surface.name then
          return player.print({"space-exploration.gps_requires_satellite"})
        else
          -- default to map shift with no message
        end
      else
        if Zone.is_visible_to_force(zone, player.force.name) then
          RemoteView.start(player, zone, event.position)
        else
          player.print({"space-exploration.gps_undiscovered"})
        end
      end
    end
  else
    player.print({"space-exploration.gps_invalid"})
  end
end
Event.addListener(defines.events.on_player_clicked_gps_tag, RemoteView.on_player_clicked_gps_tag)

---@param event EventData.on_console_chat Event data
function RemoteView.on_console_chat(event)
  local s = MapView.name_surface_prefix
  if not event.player_index then return end -- Was message from server console
  local starmap = string.sub(s,1,string.len(s)-1) .. "%-" .. event.player_index
  if string.find(event.message,"%[gps=[-]*%d+%.*%d+%,[-]*%d+%.*%d+%,"..starmap.."%]") then
    local player = game.get_player(event.player_index)
    ---@cast player LuaPlayer
    if MapView.player_is_in_map(player) then
      local playerdata = get_make_playerdata(player)
      local map_info = MapView.get_player_map_info(player)
      playerdata.last_made_gps_tag = {
        starmap_active_map = table.deepcopy(map_info),
      }
    end
  end
end
Event.addListener(defines.events.on_console_chat, RemoteView.on_console_chat)

function RemoteView.on_tick()
  --move light to follow player
  for _, player in pairs(game.connected_players) do
    local playerdata = get_make_playerdata(player)
    local remote_view_data = playerdata.remote_view_data
    if not remote_view_data then goto continue end -- Player is not in remote view

    local satellite_light = remote_view_data.satellite_light
    if satellite_light and satellite_light.valid then
      satellite_light.target = player.position
    else
      RemoteView.create_light(player)
    end

    ::continue::
  end
end
Event.addListener(defines.events.on_tick, RemoteView.on_tick)

function RemoteView.update_charting_for_players_in_remote_view()
  for _, player in pairs(game.connected_players) do
    local playerdata = get_make_playerdata(player)
    local remote_view_data = playerdata.remote_view_data
    if not remote_view_data then goto continue end -- Player is not in remote view
    if not remote_view_data.has_radar then goto continue end

    -- Don't chart if player is zoomed out far enough to see the chart view.
    if player.render_mode ~= defines.render_mode.chart_zoomed_in then goto continue end

    -- Chart!
    player.force.chart(
      player.surface,
      util.position_to_area(player.position, 4 * 32, 1.25)
    )

    ::continue::
  end
end
Event.addListener("on_nth_tick_60", RemoteView.update_charting_for_players_in_remote_view)

return RemoteView
