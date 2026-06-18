local RocketsiloGUI = {}

RocketsiloGUI.name_rocket_silo_gui_root = mod_prefix.."rocket-silo-gui"
RocketsiloGUI.name_window_close = "rocket_silo_close_button"

---@param player LuaPlayer
function RocketsiloGUI.gui_close(player)
  RelativeGUI.gui_close(player, RocketsiloGUI.name_rocket_silo_gui_root)
end

---Creates the launchpad gui for a given player.
---@param player LuaPlayer Player
---@param rocket_silo RocketSiloInfo Lanuch pad data
function RocketsiloGUI.gui_open(player, rocket_silo)
  RocketsiloGUI.gui_close(player)
  if not rocket_silo then Log.debug('RocketsiloGUI.gui_open rocket_silo not found') return end

  local struct = rocket_silo
  local gui = player.gui.relative
  local playerdata = get_make_playerdata(player)

  local anchor = {gui=defines.relative_gui_type.rocket_silo_gui, position=defines.relative_gui_position.left}
  local container = gui.add{
    type="frame",
    name=RocketsiloGUI.name_rocket_silo_gui_root,
    anchor=anchor,
    style="space_platform_container",
    direction="vertical",
    tags={unit_number=struct.unit_number} -- store unit_number in tag
  }

  local titlebar_flow = container.add{  -- Titlebar flow
    type="flow",
    direction="horizontal",
    style="se_relative_titlebar_flow"
  }

  titlebar_flow.add{  -- GUI label
    type="label",
    caption={"space-exploration.relative-window-settings"},
    style="frame_title"
  }

  titlebar_flow.add{  -- Spacer
    type="empty-widget",
    ignored_by_interaction=true,
    style="se_relative_titlebar_nondraggable_spacer"
  }

  titlebar_flow.add{  -- Informatron button
    type="sprite-button",
    sprite="virtual-signal/informatron",
    style="frame_action_button",
    tooltip={"space-exploration.informatron-open-help"},
    tags={se_action="goto-informatron", informatron_page="cargo_rockets"}
  }


  local launchpad_gui_frame = container.add{type="frame", direction="vertical", style="inside_shallow_frame"}

  local subheader_frame = launchpad_gui_frame.add{type="frame", direction="vertical", style="space_platform_subheader_frame"}

  local property_flow = subheader_frame.add{type="flow", direction="horizontal"}
  property_flow.add{type="label", caption={"space-exploration.launchpad_status_label"}, style="se_relative_properties_label"}
  property_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
  local status = property_flow.add{type="label", name="status", caption={"space-exploration.label_status", ""}}
  status.style.single_line = false

  -- Content flow
  local launchpad_gui_inner = launchpad_gui_frame.add{ type="flow", name="launchpad_gui_inner", direction="vertical"}
  launchpad_gui_inner.style.padding = 12

  launchpad_gui_inner.add{type="label", name="destination-location-label", caption={"space-exploration.heading-destination-position", ""}, style="heading_3_label"}
  local list, selected_index, values = RocketsiloGUI.get_landingpad_name_dropdown_values(struct)
  GuiCommon.create_filter(launchpad_gui_inner, player, {
    list = list,
    selected_index = selected_index,
    values = values,
    dropdown_name = "launchpad-list-landing-pad-names",
    suffix = "2"
  })

  RocketsiloGUI.gui_update(player)
end

---@param player LuaPlayer
---@param struct RocketSiloInfo
---@param filter? string
---@return string[] list
---@return uint selected_index
---@return LocationReference[] values
function RocketsiloGUI.get_zone_dropdown_values(player, struct, filter)
  local destination_zone = struct.destination and struct.destination.zone
  local playerdata = get_make_playerdata(player)
  local list, selected_index, values = Zone.dropdown_list_zone_destinations(
    player,
    struct.force_name,
    destination_zone,
    {
      alphabetical = playerdata.zones_alphabetical,
      filter = filter,
      wildcard = {list = {"space-exploration.any_landing_pad_with_name"}, value = {type = "any"}},
    }
  )
  if selected_index == 1 then selected_index = 2 end
  selected_index = selected_index or 2
  if selected_index > #list then selected_index = 1 end
  return list, selected_index, values
end

---@param struct RocketSiloInfo
---@param filter? string
---@return string[] list
---@return uint selected_index
---@return string[] values
function RocketsiloGUI.get_landingpad_name_dropdown_values(struct, filter)
  local destination_pad_name = struct.destination and struct.destination.landing_pad_name or nil
  local destination_zone = struct.zone
  return Landingpad.dropdown_list_zone_landing_pad_names(struct.force_name, destination_zone, destination_pad_name, filter)
end

---@param event EventData.CustomInputEvent Event data
function RocketsiloGUI.focus_search(event)
  local root = game.get_player(event.player_index).gui.relative[RocketsiloGUI.name_rocket_silo_gui_root]
  if not root then return end
  local textfield = util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  if not textfield then return end
  textfield.focus()
end
Event.addListener(mod_prefix.."focus-search", RocketsiloGUI.focus_search)



---@param player LuaPlayer
---@param struct RocketSiloInfo
---@return LocalisedString message
function RocketsiloGUI.get_launch_message_ready(player, struct)

  if ((struct.entity.rocket and struct.entity.rocket.active) or not struct.entity.rocket) and struct.entity.rocket_silo_status ~= defines.rocket_silo_status.rocket_ready then
    return {"space-exploration.launchpad_constructing_rocket"}
  end

  if (struct.entity.rocket and struct.entity.rocket.active) and struct.entity.get_inventory(defines.inventory.rocket_silo_rocket).is_empty() then
    return {"space-exploration.launchpad_waiting_for_payload"}
  end

  if struct.destination and struct.destination.landing_pad_name then
    local landing_pads = Landingpad.get_zone_landing_pads_availability(struct.force_name, struct.zone, struct.destination.landing_pad_name)
    if not next(landing_pads.empty_landing_pads) then
      message = {"space-exploration.launchpad_waiting_for_space_in_pad"}
      --message = {"space-exploration.launchpad_waiting_for_empty_pad"}
      if not next(landing_pads.filled_landing_pads) then
        message = {"space-exploration.launchpad_waiting_for_pad"}
        if not next(landing_pads.blocked_landing_pads) then
          message = {"space-exploration.launchpad_no_pad_matches"}
        end
      end
    end
    return message
  end

  if (struct.entity.rocket and struct.entity.rocket.active) and struct.entity.rocket_silo_status ~= defines.rocket_silo_status.rocket_ready then
    return {"space-exploration.launchpad_ready_to_launch"}
  end

end

---@param player LuaPlayer
function RocketsiloGUI.gui_update(player)
  local root = player.gui.relative[RocketsiloGUI.name_rocket_silo_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local struct = Rocketsilo.from_unit_number(root.tags.unit_number)
  if not (struct and struct.valid) then return RocketsiloGUI.gui_close(player) end

  -- TODO: Add some explanation for the current status, landing pad availability, etc.
  local status_text = Util.find_first_descendant_by_name(root, "status")
  if status_text then
    status_text.caption = RocketsiloGUI.get_launch_message_ready(player, struct)
  end

end

---@param event EventData.on_gui_click Event data
function RocketsiloGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[RocketsiloGUI.name_rocket_silo_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Rocketsilo.from_unit_number(root.tags.unit_number)
  if not struct then return end

  if element.name == GuiCommon.filter_clear_name then
    element.parent[GuiCommon.filter_textfield_name].text = ""
    RocketsiloGUI.gui_update_landingpad_list(root, player, struct)
  end
end
Event.addListener(defines.events.on_gui_click, RocketsiloGUI.on_gui_click)

---@param player LuaPlayer
---@param struct RocketSiloInfo
---@param dropdown_element LuaGuiElement
local function on_landing_pad_name_dropdown_changed(player, struct, dropdown_element)
  local value = player_get_dropdown_value(player, dropdown_element.name, dropdown_element.selected_index)
  local landing_pad_name = value
  Rocketsilo.set_destination(struct, landing_pad_name)
  RocketsiloGUI.gui_update(player)
end

---@param player LuaPlayer
---@param struct RocketSiloInfo
---@param zone_list_dropdown_element LuaGuiElement
local function set_landing_pad_dropdown_values(player, struct, zone_list_dropdown_element)
  local list, selected_index, player_get_dropdown_values

  list, selected_index, values = Landingpad.dropdown_list_zone_landing_pad_names(struct.force_name, struct.zone, struct.destination and struct.destination.landing_pad_name or nil)

  local pad_names_dropdown_element = zone_list_dropdown_element.parent["launchpad-list-landing-pad-names"]
  pad_names_dropdown_element.items = list
  pad_names_dropdown_element.selected_index = selected_index
  player_set_dropdown_values(player, "launchpad-list-landing-pad-names", values)

  on_landing_pad_name_dropdown_changed(player, struct, pad_names_dropdown_element)
end

---@param event EventData.on_gui_selection_state_changed Event data
function RocketsiloGUI.on_selection_state_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[RocketsiloGUI.name_rocket_silo_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Rocketsilo.from_unit_number(root.tags.unit_number)
  if not struct then return end

  if element.name == "launchpad-list-landing-pad-names" then
    on_landing_pad_name_dropdown_changed(player, struct, element)
  end
end
Event.addListener(defines.events.on_gui_selection_state_changed, RocketsiloGUI.on_selection_state_changed)

---@param root LuaGuiElement
---@param player LuaPlayer
---@param struct RocketSiloInfo
function RocketsiloGUI.gui_update_landingpad_list(root, player, struct)
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name.."2")
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end
  local list, selected_index, values = RocketsiloGUI.get_landingpad_name_dropdown_values(struct, filter)
  local landingpads_dropdown = Util.find_first_descendant_by_name(root, "launchpad-list-landing-pad-names")
  landingpads_dropdown.items = list
  landingpads_dropdown.selected_index = selected_index
  player_set_dropdown_values(player, "launchpad-list-landing-pad-names", values)
end

---@param event EventData.on_gui_text_changed Event data
function RocketsiloGUI.on_gui_text_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[RocketsiloGUI.name_rocket_silo_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Rocketsilo.from_unit_number(root.tags.unit_number)
  if not struct then return end

  RocketsiloGUI.gui_update_landingpad_list(root, player, struct)
end
Event.addListener(defines.events.on_gui_text_changed, RocketsiloGUI.on_gui_text_changed)

for _, entity_name in pairs(Rocketsilo.name_rocket_silos) do
  RelativeGUI.register_relative_gui(
    RocketsiloGUI.name_rocket_silo_gui_root,
    entity_name,
    RocketsiloGUI.gui_open,
    Rocketsilo.from_entity
  )
end

--- Respond to the main entity GUI being closed by destroying the relative GUI
---@param event EventData.on_gui_closed Event data
function RocketsiloGUI.on_gui_closed(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if player and event.entity and util.table_contains(Rocketsilo.name_rocket_silos, event.entity.name) then
    RocketsiloGUI.gui_close(player)
  end
end
Event.addListener(defines.events.on_gui_closed, RocketsiloGUI.on_gui_closed)

--- Opens the silo gui when a silo is clicked or vehicle button is pressed from a seat
--- Closes the silo gui when another gui is opened
---@param event EventData.on_gui_opened Event data
function RocketsiloGUI.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if event.entity and event.entity.valid then
    local entity_name = event.entity.name
    if util.table_contains(Rocketsilo.name_rocket_silos, entity_name) then
      RocketsiloGUI.gui_open(player, Rocketsilo.from_entity(event.entity))
    else
      RocketsiloGUI.gui_close(player)
    end
  else
    RocketsiloGUI.gui_close(player)
  end
end
Event.addListener(defines.events.on_gui_opened, RocketsiloGUI.on_gui_opened)

return RocketsiloGUI
