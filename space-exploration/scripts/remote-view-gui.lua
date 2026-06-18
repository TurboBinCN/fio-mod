local RemoteViewGUI = {
  name_root = "se-remote-view",
  name_left_frame = "left-frame",
  name_zone_name_frame = "zone-name-frame",
  name_zone_name_flow = "zone-name-flow",
  name_zone_name_label = "zone-name-label",
  name_back_to_entity_button = "back-to-entity-button",
  name_hierarchy_flow = "hierarchy-flow",
  name_flags_flow = "flags-flow",
  name_side_button_frame = "side-button-frame",
  name_side_button_top_flow = "side-button-top-flow",
  name_side_button_bottom_flow = "side-button-bottom-flow",
  name_pins_add_button = "pins-add",
  name_pins_list_button = "pins-list",
  name_pins_frame = "pins-frame",
  name_pins_scroll_pane = "pins-scroll-pane",
  name_pins_table = "pins-table",
  name_open_expanded_gui_button = "open-expanded-gui",

  action_stop_remote_view = "stop-remote-view",
  action_go_back_to_entity = "go-back-to-entity",
  action_interstellar_map_button = "go-to-interstellar-map",
  action_system_map_button = "go-to-system-map",
  action_hierarchy_zone_button = "go-to-zone",
  action_flag_button = "toggle-flag",
  action_pins_add = "add-pin",
  action_pins_list = "list-pins",

  root_width = 320,
  root_height = 96
}

do -- GUI element paths
  RemoteViewGUI.path_back_to_entity_button = {
    RemoteViewGUI.name_left_frame,
    RemoteViewGUI.name_zone_name_frame,
    RemoteViewGUI.name_zone_name_flow,
    RemoteViewGUI.name_back_to_entity_button
  }
  RemoteViewGUI.path_zone_name_label = {
    RemoteViewGUI.name_left_frame,
    RemoteViewGUI.name_zone_name_frame,
    RemoteViewGUI.name_zone_name_flow,
    RemoteViewGUI.name_zone_name_label
  }
  RemoteViewGUI.path_hierarchy_flow = {
    RemoteViewGUI.name_left_frame,
    RemoteViewGUI.name_hierarchy_flow
  }
  RemoteViewGUI.path_flags_flow = {
    RemoteViewGUI.name_left_frame,
    RemoteViewGUI.name_flags_flow
  }
  RemoteViewGUI.path_pins_add_button = {
    RemoteViewGUI.name_side_button_frame,
    RemoteViewGUI.name_side_button_bottom_flow,
    RemoteViewGUI.name_pins_add_button
  }
  RemoteViewGUI.path_pins_list_button = {
    RemoteViewGUI.name_side_button_frame,
    RemoteViewGUI.name_side_button_bottom_flow,
    RemoteViewGUI.name_pins_list_button
  }
  RemoteViewGUI.path_pins_scroll_pane = {
    RemoteViewGUI.name_pins_frame,
    RemoteViewGUI.name_pins_scroll_pane
  }
end

---Estimates the maximum number of pin columns that can be displayed in the remote view GUI.
---@param player LuaPlayer Player
---@return uint max_columns 0–5
function RemoteViewGUI.get_max_pins_columns(player)
  local half_width = (player.display_resolution.width / player.display_scale) / 2
  return core_util.clamp(math.ceil((half_width - 790) / 40), 0, 5)
end

---Returns the remote view GUI for a given player, if it is open.
---@param player LuaPlayer Player
---@return LuaGuiElement? root Root gui element, if open
function RemoteViewGUI.get_gui(player)
  return player.gui.screen[RemoteViewGUI.name_root]
end

---Opens the remote view GUI for a given player.
---@param player LuaPlayer Player
function RemoteViewGUI.open(player)
  if RemoteViewGUI.get_gui(player) then RemoteViewGUI.update(player) return end

  local root = player.gui.screen.add{
    type = "frame",
    name = RemoteViewGUI.name_root,
    direction = "horizontal",
    style = "se_remote_view_root_frame"
  }

  do -- Move GUI to player's previously saved location or bottom left corner.
    local resolution = player.display_resolution
    local scaling = player.display_scale
    local playerdata = get_make_playerdata(player)
    local gui_location = playerdata.remote_view_gui_location
    local width = RemoteViewGUI.root_width
    local height = RemoteViewGUI.root_height

    -- Check if saved gui location is within player's existing screen resolution
    if gui_location and (gui_location.x > resolution.width - (width * scaling) or
          gui_location.y > resolution.height - (height * scaling)) then
      gui_location = nil
    end

    if not gui_location then
      gui_location = { 0, (resolution.height) - (height * scaling) }
    end

    root.location = gui_location
  end

  -- Left frame
  local left_frame = root.add{
    type = "frame",
    name = RemoteViewGUI.name_left_frame,
    direction = "vertical",
    style = "se_remote_view_left_frame"
  }

  local zone_name_frame = left_frame.add{
    type = "frame",
    name = RemoteViewGUI.name_zone_name_frame,
    direction = "vertical",
    style = "se_remote_view_name_frame"
  }

  local zone_name_flow = zone_name_frame.add{
    type = "flow",
    name = RemoteViewGUI.name_zone_name_flow,
    direction="horizontal",
    style = "se_remote_view_content_flow"
  }

  zone_name_flow.add{
    type = "label",
    name = RemoteViewGUI.name_zone_name_label,
    caption = "",
    style = "se_remote_view_name_label"
  }
  zone_name_flow.add{ type = "empty-widget", style = "se_relative_properties_spacer" }
  local back_to_entity_button = zone_name_flow.add{
    type = "sprite-button",
    name = RemoteViewGUI.name_back_to_entity_button,
    style = "se_remote_view_name_button"
  }
  back_to_entity_button.visible = false

  left_frame.add{
    type = "flow",
    name = RemoteViewGUI.name_hierarchy_flow,
    direction = "horizontal",
    style = "se_remote_view_content_flow"
  }

  local flags = left_frame.add{
    type = "flow",
    name = RemoteViewGUI.name_flags_flow,
    direction = "horizontal",
    style = "se_remote_view_content_flow"
  }
  flags.visible = false
  do -- Add flag buttons
    flags.add{
      type = "sprite-button",
      name = MapView.name_button_show_resources,
      sprite = "entity/stone",
      tooltip = {"space-exploration.remote-view-show-hide-resources"},
      tags = {action = RemoteViewGUI.action_flag_button},
      style = "se_remote_view_hierarchy_button"
    }
    flags.add{
      type = "sprite-button",
      name = MapView.name_button_show_stats,
      sprite = "entity/" .. Landingpad.name_rocket_landing_pad,
      tooltip = {"space-exploration.remote-view-show-hide-stats"},
      tags = {action = RemoteViewGUI.action_flag_button},
      style = "se_remote_view_hierarchy_button"
    }
    flags.add{
      type = "sprite-button",
      name = MapView.name_button_show_anchor_info,
      sprite = "virtual-signal/se-spaceship",
      tooltip = {"space-exploration.remote-view-show-hide-anchor-info"},
      tags = {action = RemoteViewGUI.action_flag_button},
      style = "se_remote_view_hierarchy_button"
    }
    flags.add{
      type = "sprite-button",
      name = MapView.name_button_show_danger_zones,
      sprite = "utility/warning_icon",
      tooltip = {"space-exploration.remote-view-show-hide-danger-zones"},
      tags = {action = RemoteViewGUI.action_flag_button},
      style = "se_remote_view_hierarchy_button"
    }
  end

  -- Side-button frame
  local side_button_frame = root.add{
    type = "frame",
    name = RemoteViewGUI.name_side_button_frame,
    direction = "vertical",
    style = "se_remote_view_side_button_frame"
  }

  local top_side_button_flow = side_button_frame.add{
    type = "flow",
    name = RemoteViewGUI.name_side_button_top_flow,
    direction = "horizontal",
    style = "se_remote_view_side_flow"
  }
  local bottom_side_button_flow = side_button_frame.add{
    type = "flow",
    name = RemoteViewGUI.name_side_button_bottom_flow,
    direction = "horizontal",
    style = "se_remote_view_side_flow"
  }
  top_side_button_flow.add{
    type = "sprite-button",
    name = RemoteViewGUI.name_pins_add_button,
    sprite = "se-pin-add-white",
    hovered_sprite = "se-pin-add-black",
    clicked_sprite = "se-pin-add-black",
    tags = {action=RemoteViewGUI.action_pins_add},
    tooltip = {"space-exploration.remote-view-add-pin"},
    mouse_button_filter = {"left"},
    style = "se_remote_view_side_button"
  }
  bottom_side_button_flow.add{
    type = "sprite-button",
    name = RemoteViewGUI.name_pins_list_button,
    sprite = "se-pin-list-white",
    hovered_sprite = "se-pin-list-black",
    clicked_sprite = "se-pin-list-black",
    tags = {action=RemoteViewGUI.action_pins_list},
    tooltip={"space-exploration.open-pins-remote-view"},
    style = "se_remote_view_side_button"
  }

  -- Pins frame
  local pins_frame = root.add{
    type = "frame",
    name = RemoteViewGUI.name_pins_frame,
    direction = "vertical",
    style = "se_remote_view_pins_frame"
  }
  pins_frame.add{
    type = "scroll-pane",
    name = RemoteViewGUI.name_pins_scroll_pane,
    direction = "vertical",
    style = "se_remote_view_pins_scroll_pane"
  }

  local edge_flow = root.add{type="flow", direction="vertical"}
  local drag_handle = edge_flow.add{type="empty-widget", style="se_lifesupport_draggable_space"}
  drag_handle.drag_target = root

  RemoteViewGUI.update(player)
end

---Updates the contents of the remote view GUI.
---@param player LuaPlayer Player
function RemoteViewGUI.update(player)
  local root = RemoteViewGUI.get_gui(player)
  if not root then return end

  local zone = Zone.from_surface(player.surface)
  local is_map
  local new_caption

  local zone_name_label = util.get_gui_element(root, RemoteViewGUI.path_zone_name_label)
  local zone_hierarchy_flow = util.get_gui_element(root, RemoteViewGUI.path_hierarchy_flow)
  local flags_flow = util.get_gui_element(root, RemoteViewGUI.path_flags_flow)
  local pins_add_button = util.get_gui_element(root, RemoteViewGUI.path_pins_add_button)

  -- Get zone name caption
  if zone then
    new_caption = Zone.get_print_name(zone, true)
  elseif MapView.player_is_in_interstellar_map(player) then
    new_caption = {"space-exploration.interstellar-map"}
    is_map = true
  else
    local current_system = MapView.get_current_system(player)
    if current_system then
      new_caption = {"space-exploration.solar-system", Zone.get_print_name(current_system, true)}
      is_map = true
    end
  end

  -- Update hierarchy/flags
  if zone_name_label then zone_name_label.caption = new_caption end
  if zone_hierarchy_flow and flags_flow then
    if zone then
      zone_hierarchy_flow.visible = true
      flags_flow.visible = false
      RemoteViewGUI.update_hierarchy_flow(zone, zone_hierarchy_flow)
    elseif is_map then
      zone_hierarchy_flow.visible = false
      flags_flow.visible = true
      RemoteViewGUI.update_map_flags(flags_flow)
    else
      zone_hierarchy_flow.visible = true
      flags_flow.visible = false
      zone_hierarchy_flow.clear()
    end
  end

  -- Enable/disable "add-pins" button as appropriate
  if pins_add_button then
    pins_add_button.enabled = zone and true or false
  end

  -- Update pins in pins frame
  Pin.gui_update(player)
end

---Closes the remote view GUI in addition to any pin GUIs that are open.
---@param player LuaPlayer Player
function RemoteViewGUI.close(player)
  local root = RemoteViewGUI.get_gui(player)
  if root then
    -- Save gui location
    local playerdata = get_make_playerdata(player)
    playerdata.remote_view_gui_location = root.location --[[@as GuiLocation]]

    -- Close main GUI
    root.destroy()
  end

  -- Close any pin windows that might be open
  Pin.modal_close(player)
  Pin.window_close(player)
end

---Changes the remote view sprite button to the given entity's icon, and makes the button
---go back to that entity.
---@param player LuaPlayer Player
---@param entity LuaEntity Entity to go back to, _must_ be valid
function RemoteViewGUI.show_entity_back_button(player, entity)
  local root = RemoteViewGUI.get_gui(player)
  if not root then return end

  local button = util.get_gui_element(root, RemoteViewGUI.path_back_to_entity_button)
  if not button then return end

  button.sprite = "entity/" .. entity.name
  button.tooltip = {"space-exploration.simple-a-b-space",
    {"space-exploration.back-to"}, entity.localised_name}
  button.tags = {
    action = RemoteViewGUI.action_go_back_to_entity,
    name = entity.name,
    surface_index = entity.surface.index,
    position = entity.position
  }
  button.visible = true
end

---Restores the nav-sat icon to its default state.
---@param player LuaPlayer Player
function RemoteViewGUI.hide_entity_back_button(player)
  local root = RemoteViewGUI.get_gui(player)
  if not root then return end

  local button = util.get_gui_element(root, RemoteViewGUI.path_back_to_entity_button)
  if not button then return end

  button.visible = false
  button.sprite = nil
  button.tooltip = nil
  button.tags = {}
end

---Updates the hierarchy flow with the appropriate hierarchy for a given zone.
---@param zone AnyZoneType|StarType|SpaceshipType Zone being viewed
---@param flow LuaGuiElement Hierarchy flow
function RemoteViewGUI.update_hierarchy_flow(zone, flow)
  flow.clear()

  local iter_zone = zone
  local found_star = false
  local parent_chain = {}

  -- Make a table of this zone's parents
  while iter_zone do
    if not (iter_zone.type == "orbit" and iter_zone.parent.type == "star") then
      ---@cast iter_zone  OrbitType
      table.insert(parent_chain, iter_zone)
    end
    found_star = iter_zone.type == "star" and true or found_star
    iter_zone = iter_zone.parent
  end

  -- Add orbit to (beginning of) table if zone is a planet or moon
  if zone.type ~= "star" and zone.orbit then
    ---@cast zone -StarType
    table.insert(parent_chain, 1, zone.orbit)
  end

  local parent_chain_length = #parent_chain

  -- Add starmap sprite if no star parent
  if zone.type ~= "spaceship" then
    ---@cast zone -SpaceshipType
    local star = Zone.get_star_from_child(zone)
    if not star or zone.type == "orbit" and zone.parent.type == "star" then
      flow.add{
        type = "sprite-button",
        sprite = "se-map-gui-starmap",
        tooltip = {"space-exploration.interstellar-space"},
        tags = {action = RemoteViewGUI.action_interstellar_map_button},
        style = "se_remote_view_hierarchy_button"
      }
      flow.add{type = "sprite", sprite = "se-breadcrumb-right-dark", style = "se_remote_view_breadcrumb_sprite"}
    end
    if star then
      flow.add{
        type = "sprite-button",
        sprite = "se-map-gui-system",
        tooltip = {"space-exploration.planetary-system", Zone.get_print_name(star)},
        tags = {
          action = RemoteViewGUI.action_system_map_button,
          zone_type = star.type,
          zone_index = star.index
        },
        style = "se_remote_view_hierarchy_button"
      }
      flow.add{type = "sprite", sprite = "se-breadcrumb-right-dark", style = "se_remote_view_breadcrumb_sprite"}
    end
  end

  -- Add the hierarchy buttons
  for i = parent_chain_length, 1, -1 do
    local selected_zone = parent_chain[i]
    if selected_zone.type == "star" then
      ---@cast selected_zone StarType
      selected_zone = selected_zone.orbit
    end

    if i < parent_chain_length then
      flow.add{type = "sprite", sprite = "se-breadcrumb-right-dark", style = "se_remote_view_breadcrumb_sprite"}
    end

    flow.add{
      type = "sprite-button",
      sprite = Zone.get_icon(selected_zone),
      tooltip = Zone.get_print_name(selected_zone),
      tags = {
        action = RemoteViewGUI.action_hierarchy_zone_button,
        zone_index = selected_zone.index,
        zone_type = selected_zone.type
      },
      style = (zone == selected_zone) and "se_remote_view_hierarchy_button_active" or "se_remote_view_hierarchy_button"
    }
  end
end

---Updates the flag buttons' `enabled` states.
---@param flow LuaGuiElement Flags flow
function RemoteViewGUI.update_map_flags(flow)
  local player = game.get_player(flow.player_index)
  ---@cast player -?
  local starmap_settings = MapView.get_settings(player)

  for _, element in pairs(flow.children) do
    local element_name = element.name
    element.visible = (starmap_settings[element_name] ~= nil) and true or false
    element.style = starmap_settings[element_name] and
      "se_remote_view_hierarchy_button_active" or "se_remote_view_hierarchy_button"
  end
end

---Handles clicks for remote view GUI elements.
---@param event EventData.on_gui_click Event data
function RemoteViewGUI.on_gui_click(event)
  if not event.element or not event.element.valid then return end
  local root = gui_element_or_parent(event.element, RemoteViewGUI.name_root)
  if not root or not event.element.tags then return end

  local player = game.get_player(event.player_index)
  local intersurface_unlocked = RemoteView.is_intersurface_unlocked(player)
  ---@cast player -?
  local tags = event.element.tags --[[@as Tags]]
  local action = tags.action

  if action == RemoteViewGUI.action_stop_remote_view then
    RemoteView.stop(player)
  elseif action == RemoteViewGUI.action_go_back_to_entity then
    local surface = game.get_surface(tags.surface_index --[[@as uint]])
    local zone = surface and Zone.from_surface(surface) or nil
    if zone then
      ---@cast surface -?
      player.clear_cursor()
      RemoteView.start(player, zone, tags.position --[[@as MapPosition]])
      local entity = surface.find_entity(
        tags.name --[[@as string]],
        tags.position --[[@as MapPosition]]
      )
      if entity then player.opened = entity end
    end
    RemoteViewGUI.hide_entity_back_button(player)
  elseif action == RemoteViewGUI.action_hierarchy_zone_button then
    if not intersurface_unlocked then
      player.create_local_flying_text{
        text = RemoteView.intersurface_unlock_requirement_string(player),
        create_at_cursor = true
      }
      return
    end
    local zone = (tags.zone_type == "spaceship") and
      Spaceship.from_index(tags.zone_index --[[@as uint]]) or
      Zone.from_zone_index(tags.zone_index --[[@as uint]])
    if zone then RemoteView.start(player, zone) end
  elseif action == RemoteViewGUI.action_system_map_button then
    if not intersurface_unlocked then
      player.create_local_flying_text{
        text = RemoteView.intersurface_unlock_requirement_string(player),
        create_at_cursor = true
      }
      return
    end
    local zone = util.get_zone_from_tags(tags)
    if zone then MapView.start_system_map(player, zone) end
  elseif action == RemoteViewGUI.action_interstellar_map_button then
    if not intersurface_unlocked then
      player.create_local_flying_text{
        text = RemoteView.intersurface_unlock_requirement_string(player),
        create_at_cursor = true
      }
      return
    end
    MapView.start_interstellar_map(player)
  elseif action == RemoteViewGUI.action_flag_button then
    MapView.toggle_setting(player, event.element.name)
    RemoteViewGUI.update(player)
  elseif action == RemoteViewGUI.action_pins_add then
    local playerdata = Pin.get_make_pin_playerdata(player)
    local id = playerdata.saved_pins.id
    local item_name = "pin-button-prefix-" .. id
    playerdata.saved_pins.id = playerdata.saved_pins.id + 1
    Pin.modal_open(player, item_name) return true
  elseif action == RemoteViewGUI.action_pins_list then
    Pin.window_toggle(player)
  elseif action == Pin.tag_pin_button then
    Pin.on_gui_pin_button_click(player, event)
  end
end
Event.addListener(defines.events.on_gui_click, RemoteViewGUI.on_gui_click)

---Handles the player moving the remote view GUI.
---@param event EventData.on_gui_location_changed Event data
function RemoteViewGUI.on_gui_location_changed(event)
  if not event.element.valid or event.element.name ~= RemoteViewGUI.name_root then return end

  local player = game.get_player(event.player_index)
  ---@cast player -?
  local resolution = player.display_resolution
  local scaling = player.display_scale
  local location = event.element.location --[[@as GuiLocation]]
  local element_height = RemoteViewGUI.root_height
  local x = location.x
  local y = location.y
  local anchors = {
    { -- Bottom left
      x = 0,
      x_range = 10,
      x_snap = true,
      y = resolution.height - (element_height * scaling),
      y_range = 10,
      y_snap = true
    },
    { -- Left
      x = 0,
      x_range = 10,
      x_snap = true,
      y = resolution.height / 2,
      y_range = resolution.height / 2,
      y_snap = false
    },
    { -- Top
      x = resolution.width / 2,
      x_range = resolution.width / 2,
      x_snap = false,
      y = 0,
      y_range = 10,
      y_snap = true
    },
    { --  Bottom
      x = resolution.width / 2,
      x_range = resolution.width / 2,
      x_snap = false,
      y = resolution.height - (element_height * scaling),
      y_range = 10,
      y_snap = true
    },
  }

  for _, anchor in pairs(anchors) do
    if math.abs(x - anchor.x) <= anchor.x_range and math.abs(y - anchor.y) <= anchor.y_range then
      event.element.location = {
        anchor.x_snap and anchor.x or x,
        anchor.y_snap and anchor.y or y
      }
      break
    end
  end
end
Event.addListener(defines.events.on_gui_location_changed, RemoteViewGUI.on_gui_location_changed)

---Refreshes the remote view GUI upon resolution/scale changes in case max number of pins has
---changed.
---@param event EventData.on_player_display_resolution_changed|EventData.on_player_display_scale_changed Event data
function RemoteViewGUI.on_player_display_changed(event)
  RemoteViewGUI.update(game.get_player(event.player_index) --[[@as LuaPlayer]])
end
Event.addListener(defines.events.on_player_display_resolution_changed, RemoteViewGUI.on_player_display_changed)
Event.addListener(defines.events.on_player_display_scale_changed, RemoteViewGUI.on_player_display_changed)

return RemoteViewGUI
