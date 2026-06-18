local SpaceshipClampGUI = { }

SpaceshipClampGUI.gui_main_root_name = mod_prefix.."spaceship-clamp"
SpaceshipClampGUI.gui_handler_name = SpaceshipClampGUI.gui_main_root_name
SpaceshipClampGUI.gui_tags_dropdown = mod_prefix.."spaceship-clamp-tags-dropdown"
SpaceshipClampGUI.gui_tags_dropdown_flow = mod_prefix.."spaceship-clamp-tags-dropdown-flow"

------------------------------------------------
-- UTILITY
------------------------------------------------

---@param tags string[]
---@param current string?
---@param filter string?
---@return string[] list
---@return uint? selected_index
---@return string[] values
local function label_and_sort_clamp_tags(tags, current, filter)
  local list = {} -- names with optional [count]
  local values = {} -- raw names
  local selected_index
  local list_value_pairs = {} -- Keep them together for sorting

  local filter_lower = filter and string.lower(filter) or nil
  for _, tag in pairs(tags) do
    if (not filter_lower) or string.find(string.lower(tag), filter_lower, 1, true) then
      if tag and tag ~= "" then
        local display_name = tag
        table.insert(list_value_pairs, {display_name, tag})
      end
    end
  end

  table.sort(list_value_pairs, function(a,b) return a[1] < b[1] end)

  for i, list_value_pair in pairs(list_value_pairs) do
    table.insert(list, list_value_pair[1])
    table.insert(values, list_value_pair[2])
    if list_value_pair[2] == current then
      selected_index = i
    end
  end

  return list, selected_index, values
end

---@param clamp_info SpaceshipClampInfo
---@param current string?
---@param filter string?
---@return string[] list
---@return uint? selected_index
---@return string[] values
local function get_clamp_tags_dropdown_values(clamp_info, current, filter)
  local tags = { } --[[@as table<string, uint> ]]

  local id = SpaceshipClamp.read_id(clamp_info)
  if id then
    tags = SpaceshipSchedulerReservations.get_all_tags_for_destination_descriptor(clamp_info.force_name, {
      clamp = {direction = clamp_info.direction, id = id }
    })
  end

  local list, selected_index, values = label_and_sort_clamp_tags(tags, current, filter)
  if not selected_index and next(list) then selected_index = 1 end
  return list, selected_index, values
end

---Function that will allow editing the tag on the next rebuild.
---@param root LuaGuiElement
---@param editable boolean? defaults to true
local function gui_set_tag_editable(root, editable)
  if editable == nil then editable = true end
  util.update_tags(root, {clamp_tags_editable = editable})
end

------------------------------------------------
-- GUI
------------------------------------------------

---@param player LuaPlayer
---@param clamp_info SpaceshipClampInfo
function SpaceshipClampGUI.open(player, clamp_info)
  SpaceshipClampGUI.close(player)
  if not clamp_info then Log.debug('SpaceshipClampGUI.open clamp_info not found') return end
  local clamp = clamp_info.main
  if not (clamp and clamp.valid) then return end

  local root = player.gui.screen.add{type="frame", name=SpaceshipClampGUI.gui_main_root_name, direction="vertical",
    tags = {clamp_unit_number = clamp_info.unit_number},
  }

  local title_bar = root.add{type="flow", style="se_relative_titlebar_flow"}
  title_bar.drag_target = root
  title_bar.add{type="label", style="frame_title", caption={"entity-name.se-spaceship-clamp"}, ignored_by_interaction=true}
  title_bar.add{type="empty-widget", style = "se_titlebar_drag_handle", ignored_by_interaction=true}
  title_bar.add{type="sprite-button", name="exit", style="frame_action_button", sprite="utility/close", mouse_button_filter={"left"},
    tags = { root_name = SpaceshipClampGUI.gui_main_root_name, }
  }

  local body_root = root.add{type="frame", direction="vertical", style="window_content_frame_packed"}
  local inner = body_root.add{type="frame", direction="vertical", style="b_inner_frame"}
  inner.style.padding = 10

  local status_flow = inner.add{type="flow", style="se_horizontal_flow_centered"}
  status_flow.style.bottom_padding = 10
  local status_sprite = status_flow.add{type="sprite", name="status-sprite", sprite="utility/status_working"}
  status_sprite.style.size = 16
  status_sprite.style.stretch_image_to_widget_size = true
  status_flow.add{type="label", name="status-label", caption={"entity-status.working"} }

  local entity_preview_frame = inner.add{type="frame", style="deep_frame_in_shallow_frame"}
  local entity_preview = entity_preview_frame.add{type="entity-preview", name = "entity-preview"}
  entity_preview.style.height = 148
  entity_preview.style.minimal_width = 400
  entity_preview.style.vertically_stretchable = true
  entity_preview.style.horizontally_stretchable = true

  -- Set signal name and count
  local top_flow = inner.add{type="flow", direction="horizontal"}
  top_flow.style.horizontal_align = "center"
  top_flow.style.horizontally_stretchable = true
  local inner_top_flow = top_flow.add{type="flow", direction="horizontal"}
  inner_top_flow.style.horizontal_spacing = 10
  inner_top_flow.style.vertical_align = "center"
  inner_top_flow.style.horizontal_align = "center"
  inner_top_flow.add{type="label", caption={"", {"space-exploration.spaceship-clamp-tag"}, ": [img=info]"}, tooltip={"space-exploration.spaceship-clamp-tag-tooltip"}, style="heading_3_label",
    tags = { root_name = SpaceshipClampGUI.gui_main_root_name }
  }
  local tag_flow = inner_top_flow.add{
    type = "flow",
    name = SpaceshipClampGUI.gui_tags_dropdown_flow,
    direction = "vertical",
  }
  tag_flow.style.horizontally_stretchable = false


  local anchor_info_root = root.add{type="frame", name="anchor-info-frame-root", direction="vertical", style="window_content_frame_packed"}
  anchor_info_root.style.top_margin = 12
  local top_bar = anchor_info_root.add{type="frame", style="subheader_frame",}
  top_bar.style.horizontally_stretchable = true
  top_bar.style.padding = {12, 24, 12, 12}
  top_bar.add{type = "label", caption = {"space-exploration.spaceship-clamp-anchor-properties"}}
  local anchor_info_body = anchor_info_root.add{type="frame", name="anchor-info-frame-body", direction="vertical", style="b_inner_frame"}
  anchor_info_body.style.padding = 10


  local property_table = anchor_info_body.add{type="table", column_count = 2}

  -- Limits
  local limit_checkbox_flow = property_table.add{type="flow", direction="horizontal"}
  limit_checkbox_flow.add{type="checkbox", name="enable-limits", caption={"", {"space-exploration.spaceship-clamp-limit"}, " [img=info]"}, state=false,
    tooltip = {"space-exploration.spaceship-clamp-limit-tooltip"},
    tags = { root_name = SpaceshipClampGUI.gui_main_root_name }
  }.style.right_padding = 16
  local limit_flow = property_table.add{type="flow", direction="horizontal"}
  limit_flow.style.horizontal_align = "right"
  limit_flow.style.vertical_align = "center"
  tf = limit_flow.add{type="textfield", name="limits-textfield", numeric=true, lose_focus_on_confirm=true, clear_and_focus_on_right_click=true, allow_negative=false, allow_decimal=false,
    tags = { root_name = SpaceshipClampGUI.gui_main_root_name }
  }
  tf.style.width = 90
  tf.style.horizontally_stretchable = false
  limit_flow.add{type="checkbox", name="enable-circuit-limits",  caption={"space-exploration.spaceship-clamp-via-circuit"}, state=false,
    tooltip = {"space-exploration.spaceship-clamp-via-circuit-limit-tooltip"},
    tags = { root_name = SpaceshipClampGUI.gui_main_root_name }
  }

  -- Priority
  property_table.add{type="label", caption={"", {"space-exploration.zonelist-heading-priority"}, " [img=info]"}, tooltip={"space-exploration.spaceship-clamp-priority-tooltip"}}
  local priority_flow = property_table.add{type="flow", direction="horizontal"}
  priority_flow.style.horizontal_align = "right"
  priority_flow.style.vertical_align = "center"
  tf = priority_flow.add{type="textfield", name="priority-textfield", numeric=true, lose_focus_on_confirm=true, clear_and_focus_on_right_click=true, allow_negative=false, allow_decimal=false,
    tags = { root_name = SpaceshipClampGUI.gui_main_root_name }
  }
  tf.style.width = 90
  tf.style.horizontally_stretchable = false
  priority_flow.add{type="checkbox", name="enable-circuit-priority", caption={"space-exploration.spaceship-clamp-via-circuit"}, state=false,
    tooltip = {"space-exploration.spaceship-clamp-via-circuit-priority-tooltip"},
    tags = { root_name = SpaceshipClampGUI.gui_main_root_name }
  }

  -- Circuit network ID
  property_table.add{type="label", caption={"", {"space-exploration.spaceship-clamp-id"}, " [img=info]"}, tooltip={"space-exploration.spaceship-clamp-id-tooltip"}}
  local id_flow = property_table.add{type="flow", direction="horizontal"}
  id_flow.style.horizontal_align = "right"
  id_flow.style.vertical_align = "center"
  tf = id_flow.add{type="textfield", name="signal_number_textfield", numeric=true, lose_focus_on_confirm=true, clear_and_focus_on_right_click=true, allow_negative=true, allow_decimal=false,
    tags = { root_name = SpaceshipClampGUI.gui_main_root_name }
  }
  tf.style.width = 90
  tf.style.horizontally_stretchable = false
  id_flow.add{  -- Spacer
    type="empty-widget",
    ignored_by_interaction=true,
    style="se_relative_titlebar_nondraggable_spacer"
  }

  -- Zone Info
  local zone_info_root = root.add{type="frame", name="zone-info-frame-root", direction="vertical", style="window_content_frame_packed"}
  zone_info_root.style.top_margin = 12
  top_bar = zone_info_root.add{type="frame", style="subheader_frame",}
  top_bar.style.horizontally_stretchable = true
  top_bar.style.padding = {12, 24, 12, 12}
  top_bar.add{type = "label", caption = {"space-exploration.spaceship-clamp-information"}}
  local zone_info_body = zone_info_root.add{type="frame", name="zone-info-frame-body", direction="vertical", style="b_inner_frame"}
  zone_info_body.style.padding = 10

  root.force_auto_center()
  player.opened = root
  SpaceshipClampGUI.update(player) -- Do after, as it might destroy the root
end

---@param player LuaPlayer
---@param ignore_inputs boolean? To prevent updating any input fields while player is working on it
function SpaceshipClampGUI.update(player, ignore_inputs)
  local root = player.gui.screen[SpaceshipClampGUI.gui_main_root_name]
  if not root then return end
  if not (root.tags and root.tags.clamp_unit_number) then SpaceshipClampGUI.close(player) return end
  local clamp_info = SpaceshipClamp.from_unit_number(root.tags.clamp_unit_number --[[@as integer]])
  if not clamp_info then SpaceshipClampGUI.close(player) return end
  local clamp = clamp_info.main
  if not (clamp and clamp.valid) then SpaceshipClampGUI.close(player) return end

  local clamp_tag_editable = root.tags.clamp_tags_editable == true
  local tags = { root_name = SpaceshipClampGUI.gui_main_root_name, }

  -- We refresh the GUI often and this will allow it to work seemlessly when changing surfaces
  local entity_preview = Util.find_first_descendant_by_name(root, "entity-preview")
  entity_preview.entity = clamp

  local status_label = Util.find_first_descendant_by_name(root, "status-label")
  local status_sprite = Util.find_first_descendant_by_name(root, "status-sprite")
  if status_label and status_sprite then
    local clamp_enabled = SpaceshipClamp.is_clamp_enabled(clamp_info)
    status_label.caption = clamp_enabled and {"entity-status.working"} or {"entity-status.closed-by-circuit-network"}
    status_sprite.sprite = clamp_enabled and "utility/status_working" or "utility/status_not_working"
  end

  if not ignore_inputs then
    local tag_flow = Util.find_first_descendant_by_name(root, SpaceshipClampGUI.gui_tags_dropdown_flow)
    assert(tag_flow)
    tag_flow.clear()
    if not clamp_tag_editable then
      local tag_flow_top = tag_flow.add{type="flow", direction="horizontal"}
      tag_flow_top.style.vertical_align = "center"
      tag_flow_top.style.horizontal_spacing = 10
      local label = tag_flow_top.add{type = "label", caption = clamp_info.tag}
      label.style.font = "heading-2"
      tag_flow_top.add{type = "sprite-button", name = "tag-rename", sprite = "utility/rename_icon",
      tooltip = { "space-exploration.rename-something", "tag" }, mouse_button_filter = { "left" },
        style = "frame_action_button", tags = { root_name = SpaceshipClampGUI.gui_main_root_name, }
      }
    else
      local tag_flow_top = tag_flow.add{type="flow", direction="horizontal"}
      local rename_textfield = GuiCommon.create_rename_textfield(tag_flow_top, clamp_info.tag, tags)
      rename_textfield.style.maximal_width = 150
      tag_flow_top.add{ type = "sprite-button", name = "rename-cancel", sprite = "utility/close", tags = tags,
        tooltip = { "gui.cancel" }, mouse_button_filter = { "left" }, style = "tool_button_red", }
      tag_flow_top.add { type = "sprite-button", name = "rename-confirm", sprite = "utility/enter", tags = tags,
        tooltip = {"space-exploration.rename-confirm"}, style = "item_and_count_select_confirm"}
      local list, selected_index, values = get_clamp_tags_dropdown_values(clamp_info, clamp_info.tag)
      local dropdown = tag_flow.add{ type = "drop-down", name = SpaceshipClampGUI.gui_tags_dropdown, items = list,
        selected_index = selected_index, tags = tags }
      dropdown.style.horizontally_stretchable = true
      player_set_dropdown_values(player, SpaceshipClampGUI.gui_tags_dropdown, values)
    end
  end

  -- Anchor Properties
  -----------------------------------------------------------
  local anchor_info_frame = Util.find_first_descendant_by_name(root, "anchor-info-frame-root")
  if anchor_info_frame then
    local enable_limits_checkbox = Util.find_first_descendant_by_name(anchor_info_frame, "enable-limits")
    if enable_limits_checkbox then enable_limits_checkbox.state = clamp_info.spaceship_limit ~= nil end
    local enable_limits_textbox = Util.find_first_descendant_by_name(anchor_info_frame, "limits-textfield")
    if enable_limits_textbox then
      enable_limits_textbox.enabled = clamp_info.spaceship_limit ~= nil and clamp_info.spaceship_limit_set_by_circuit ~= true

      if not enable_limits_textbox.enabled or not ignore_inputs then
        enable_limits_textbox.text = clamp_info.spaceship_limit and tostring(clamp_info.spaceship_limit) or "∞"
      end

      local enable_circuit_limits = Util.find_first_descendant_by_name(anchor_info_frame, "enable-circuit-limits")
      enable_circuit_limits.state = clamp_info.spaceship_limit_set_by_circuit == true
    end

    local priority_textbox = Util.find_first_descendant_by_name(anchor_info_frame, "priority-textfield")
    if priority_textbox then
      priority_textbox.enabled = not clamp_info.priority_set_by_circuit
      if not priority_textbox.enabled or not ignore_inputs then
        priority_textbox.text = tostring(clamp_info.priority)
      end
    end
    local enable_circuit_priority = Util.find_first_descendant_by_name(anchor_info_frame, "enable-circuit-priority")
    if enable_circuit_priority then enable_circuit_priority.state = clamp_info.priority_set_by_circuit == true end

    local id = SpaceshipClamp.read_id(clamp_info)
    if not id then return end -- Should never happen
    if not ignore_inputs then
      local signal_number_textfield = Util.find_first_descendant_by_name(root, "signal_number_textfield")
      if signal_number_textfield then
        signal_number_textfield.text = tostring(id)
      end
    end
  end

  -- Update the Zone Information if this is a "to" clamp
  -----------------------------------------------------------
  local zone_info_frame = Util.find_first_descendant_by_name(root, "zone-info-frame-root")
  if zone_info_frame then
    zone_info_frame.visible = true
    local body = Util.find_first_descendant_by_name(zone_info_frame, "zone-info-frame-body")
    assert(body)
    body.clear()

    local t = body.add{type="table", column_count=3}

    local zone = Zone.from_surface(clamp.surface)
    if not zone then
      t.add{type="label", text="Invalid Zone"}
    else
      local count_on_route = 0
      local count_near = 0
      local count_anchored = 0
      for _, reservation in pairs(clamp_info.spaceship_reservations) do
        if      reservation.status == "on-route"    then count_on_route = count_on_route + 1
        elseif  reservation.status == "near"        then count_near = count_near + 1
        elseif  reservation.status == "anchored"    then count_anchored = count_anchored + 1 end
      end
      local count_total = count_on_route + count_near + count_anchored

      local f = t.add{type="flow", direction="horizontal"}
      f.add{type="label", caption={"", {"space-exploration.zone"}, ":"}, style="se_relative_properties_label"}
      local e = f.add{type="empty-widget"}
      e.style.horizontally_stretchable = true
      f.add{type="label", caption=Zone.get_print_name(zone, nil, true)}

      e = t.add{type="empty-widget"}
      e.style.horizontally_stretchable = true

      f = t.add{type="flow", direction="horizontal"}
      f.add{type="label", caption={"", {"space-exploration.spaceship-clamp-zone-count-on-route"}, " [img=info]"}, tooltip={"space-exploration.spaceship-clamp-zone-count-on-route-tooltip"}, style="se_relative_properties_label"}
      e = f.add{type="empty-widget"}
      e.style.horizontally_stretchable = true
      f.add{type="label", caption=tostring(count_on_route)}

      f = t.add{type="flow", direction="horizontal"}
      f.add{type="label", caption={"", {"space-exploration.spaceship-clamp-limit"}, " [img=info]"}, tooltip={"space-exploration.spaceship-clamp-zone-spaceship-limit-tooltip"}, style="se_relative_properties_label"}
      e = f.add{type="empty-widget"}
      e.style.horizontally_stretchable = true
      f.add{type="label", caption=tostring(count_total) .. " / " .. tostring(clamp_info.spaceship_limit or "∞")}

      t.add{type="empty-widget"}
      e.style.horizontally_stretchable = true

      f = t.add{type="flow", direction="horizontal"}
      f.add{type="label", caption={"space-exploration.spaceship-clamp-zone-count-near"}, tooltip={"space-exploration.spaceship-clamp-zone-count-near-tooltip"}, style="se_relative_properties_label"}
      e = f.add{type="empty-widget"}
      e.style.horizontally_stretchable = true
      f.add{type="label", caption=tostring(count_near)}

      f = t.add{type="flow", direction="horizontal"}

      t.add{type="empty-widget"}
      e.style.horizontally_stretchable = true

      f = t.add{type="flow", direction="horizontal"}
      f.add{type="label", caption={"space-exploration.spaceship-clamp-zone-count-anchored"}, style="se_relative_properties_label"}
      e = f.add{type="empty-widget"}
      e.style.horizontally_stretchable = true
      f.add{type="label", caption=tostring(count_anchored)}

    end
  end
end

---@param player LuaPlayer
function SpaceshipClampGUI.close(player)
  local root = player.gui.screen[SpaceshipClampGUI.gui_main_root_name]
  if root then root.destroy() end
end

------------------------------------------------
-- EVENT DISTRIBUTION
------------------------------------------------

---This handler will redirect events to the appropriate gui handlers
---that's stored in the element tags.
---@param event EventData.on_gui_click|EventData.on_gui_confirmed
local function on_gui_event(event)
  local player = game.get_player(event.player_index) --[[@cast player -?]]

  local element = event.element
  if not (element and element.valid) then return end
  local tags = element.tags
  if not (tags and tags.root_name) then return end

  local root_name = tags.root_name --[[@as string?]]
  if root_name == nil or root_name ~= SpaceshipClampGUI.gui_main_root_name then return end
  local root = gui_element_or_parent(element, root_name)
  if not (root and root.tags and root.tags.clamp_unit_number) then SpaceshipClampGUI.close(player) return end
  local clamp_info = SpaceshipClamp.from_unit_number(root.tags.clamp_unit_number --[[@as integer]])
  if not clamp_info then return SpaceshipClampGUI.close(player) end
  local clamp = clamp_info.main
  if not (clamp and clamp.valid) then SpaceshipClampGUI.close(player) return end
  local element_name = element.name

  if element_name == "exit" then
    SpaceshipClampGUI.close(player)


  elseif element_name == "signal_number_textfield" then
    if not event.name == defines.events.on_gui_text_changed then return end

    local new_id = tonumber(element.text) --[[@as number?]]
    if not new_id then
      -- The textbox is empty, do nothing. If the player closes the window the last valid value will be used.
      return
    elseif new_id == 0 then
      player.create_local_flying_text{text = {"space-exploration.spaceship-clamp-id-not-zero"}, create_at_cursor = true }
      element.text = tostring(SpaceshipClamp.read_id(clamp_info)) -- Revert to previous value
    elseif not util.valid_signal_count(new_id) then
      player.create_local_flying_text{text = {"space-exploration.spaceship-clamp-id-invalid"}, create_at_cursor = true }
      element.text = tostring(SpaceshipClamp.read_id(clamp_info)) -- Revert to previous value
    else
      local id = SpaceshipClamp.read_id(clamp_info)
      if id and new_id ~= id then
        -- Overwrite current signal
        local signal_name = mod_prefix.."anchor-using-"..(clamp_info.direction == defines.direction.west and "left" or "right").."-clamp"
        SpaceshipClamp.write_id(clamp_info, new_id)
        clamp_info.grace_period_until = event.tick + SpaceshipClamp.grace_period
        SpaceshipClamp.invalidate_reservations(clamp_info)
        -- No need to refresh GUI
      end
    end


  elseif element_name == "tag-rename" then
    gui_set_tag_editable(root)
    SpaceshipClampGUI.update(player)


  elseif element_name == "rename-confirm" or
  (element_name == GuiCommon.rename_textfield_name and event.name == defines.events.on_gui_confirmed)
  then

    local new_tag --[[@as string ]]
    if element_name == "rename-confirm" then
      new_tag = string.trim(event.element.parent[GuiCommon.rename_textfield_name].text)
    else
      new_tag = element.text
    end

    if new_tag == "" then return end
    if string.len(new_tag) > SpaceshipClamp.max_tag_length then
      player.create_local_flying_text{text = {"space-exploration.spaceship-clamp-tag-max-length", SpaceshipClamp.max_tag_length}, create_at_cursor = true }
      return
    end
    if new_tag ~= clamp_info.tag then
      clamp_info.tag = new_tag
      gui_set_tag_editable(root, false)
      SpaceshipClamp.invalidate_reservations(clamp_info)
      clamp_info.grace_period_until = event.tick + SpaceshipClamp.grace_period
    end
    SpaceshipClampGUI.update(player)


  elseif element_name == "rename-cancel" then
    gui_set_tag_editable(root, false)
    SpaceshipClampGUI.update(player)


  elseif element_name == "enable-limits" then
    -- Follow how vanilla trains work
    clamp_info.spaceship_limit_set_by_circuit = false
    if not element.state then
      clamp_info.spaceship_limit = nil
    else
      clamp_info.spaceship_limit = 0
    end
    -- Do not reroute spaceships when priority change. It can do zonal-reroute at destination zone.
    SpaceshipClampGUI.update(player)


  elseif element_name == "limits-textfield" then
    if not event.name == defines.events.on_gui_text_changed then return end
    local new_limit = tonumber(element.text) or 0
    if new_limit < 0 or new_limit > SpaceshipClamp.max_spaceship_limit then
      player.create_local_flying_text{text = {"space-exploration.spaceship-clamp-max-spaceship-limit"}, create_at_cursor = true }
      element.text = tostring(clamp_info.spaceship_limit and clamp_info.spaceship_limit) or 0 -- Reset to previous valid limit
    else
      -- Do not reroute spaceships when priority change. It can do zonal-reroute at destination zone.
      clamp_info.spaceship_limit = new_limit
    end


  elseif element_name == "enable-circuit-limits" then
    clamp_info.spaceship_limit_set_by_circuit = element.state
    SpaceshipClamp.update_clamp_info(clamp_info) -- Updates the limit instantly for reactive UI
    SpaceshipClampGUI.update(player)


  elseif element_name == "priority-textfield" then
    if not event.name == defines.events.on_gui_text_changed then return end
    local new_priority = tonumber(element.text) or 0
    if new_priority < 0 or new_priority > SpaceshipClamp.max_priority then
      player.create_local_flying_text{text = {"space-exploration.spaceship-clamp-max-priority"}, create_at_cursor = true }
      element.text = tostring(clamp_info.priority) or SpaceshipClamp.default_priority -- Reset to previous valid priority
    elseif new_priority ~= clamp_info.priority then
      -- Do not reroute spaceships when priority change. It can do zonal-reroute at destination zone.
      clamp_info.priority = new_priority
    end


  elseif element_name == "enable-circuit-priority" then
    if not element.state and clamp_info.priority_set_by_circuit then
      -- Was just turned back on. Reset to default.
      clamp_info.priority = SpaceshipClamp.default_priority
    end
    clamp_info.priority_set_by_circuit = element.state
    SpaceshipClampGUI.update(player)
  end
end
Event.addListener(defines.events.on_gui_click, on_gui_event)
Event.addListener(defines.events.on_gui_confirmed, on_gui_event)
Event.addListener(defines.events.on_gui_text_changed, on_gui_event)

---@param event EventData.on_gui_selection_state_changed
local function gui_selection_state_changed(event)
  local player = game.get_player(event.player_index) --[[@cast player -?]]

  local element = event.element
  if not (element and element.valid) then return end
  local tags = element.tags
  if not (tags and tags.root_name) then return end

  local root_name = tags.root_name --[[@as string?]]
  if root_name == nil or root_name ~= SpaceshipClampGUI.gui_main_root_name then return end
  local root = gui_element_or_parent(element, root_name)
  if not root then SpaceshipClampGUI.close(player) return end

  local value = player_get_dropdown_value(player, element.name, element.selected_index)
  local rename_textfield = Util.find_first_descendant_by_name(root, GuiCommon.rename_textfield_name)
  rename_textfield.text = value
end
Event.addListener(defines.events.on_gui_selection_state_changed, gui_selection_state_changed)

---Opens the spaceship clamp gui when a clamp is clicked
---and closes it when another gui is opened
---@param event EventData.on_gui_opened
function SpaceshipClampGUI.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  -- Prevent recursion
  local element = event.element
  if element and element.name == SpaceshipClampGUI.gui_main_root_name then return end

  -- Handle event
  local entity = event.entity
  if entity and entity.valid and entity.name == SpaceshipClamp.name_spaceship_clamp_keep then
    local clamp_info = SpaceshipClamp.from_entity(entity)
    if not clamp_info then Log.debug('SpaceshipClampGUI.on_gui_opened clamp_info not found for '..entity.unit_number) return end
    player.opened = nil -- Close wrong gui first
    SpaceshipClampGUI.open(player, clamp_info)
  else
    --Some other GUI was opened. Make sure ours is closed.
    SpaceshipClampGUI.close(player)
  end
end
Event.addListener(defines.events.on_gui_opened, SpaceshipClampGUI.on_gui_opened)

---Handles GUI closed events. Can also be used to close the GUI manually
---@param event EventData.on_gui_closed
function SpaceshipClampGUI.close_gui(event)
  local player = game.players[event.player_index] --[[@cast player -?]]
  if player.gui.screen[SpaceshipClampGUI.gui_main_root_name] then
    SpaceshipClampGUI.close(player)
  end
end
Event.addListener(defines.events.on_gui_closed, SpaceshipClampGUI.close_gui)


return SpaceshipClampGUI
