local LandingpadGUI = {}

LandingpadGUI.name_rocket_landing_pad_gui_root = mod_prefix .. "rocket-landing-pad-gui"
LandingpadGUI.name_dropdown = "landingpad-list-landing-pad-names"
LandingpadGUI.name_titlebar_flow = "landingpad-titlebar-flow"
LandingpadGUI.name_rename = "landingpad-rename"
LandingpadGUI.name_stop_rename = "landingpad-stop-rename"
LandingpadGUI.name_frame = "landingpad-gui-frame"
LandingpadGUI.name_frame_dark = "landingpad-gui-frame-dark"
LandingpadGUI.name_inner = "landingpad-gui-inner"
LandingpadGUI.name_name_flow  = "landingpad-name-flow"
--LandingpadGUI.relative_gui_type = defines.relative_gui_type.container_gui
LandingpadGUI.relative_gui_type = defines.relative_gui_type.cargo_landing_pad_gui

---@param player LuaPlayer
function LandingpadGUI.gui_close(player)
  RelativeGUI.gui_close(player, LandingpadGUI.name_rocket_landing_pad_gui_root)
end

--- Create the landing pad gui for a player
---@param player LuaPlayer
---@param struct RocketLandingPadInfo landing pad data
function LandingpadGUI.gui_open(player, struct)
  LandingpadGUI.gui_close(player)
  if not struct then Log.debug('LandingpadGUI.gui_open landing_pad not found') return end

  local gui = player.gui.relative
  local anchor = {gui=LandingpadGUI.relative_gui_type, position=defines.relative_gui_position.left}
  local container = gui.add {
    type = "frame",
    name = LandingpadGUI.name_rocket_landing_pad_gui_root,
    style = "space_platform_container",
    direction = "vertical",
    anchor = anchor,
    -- use gui element tags to store a reference to what landing pad this gui is displaying/controls
    tags = {
      unit_number = struct.unit_number
    }
  }

  local titlebar_flow = container.add{
    type="flow",
    name=LandingpadGUI.name_titlebar_flow,
    direction="horizontal",
    style="se_relative_titlebar_flow"
  }
  LandingpadGUI.make_titlebar_flow(struct, titlebar_flow, true)

  local landingpad_gui_frame = container.add{ type="frame", name=LandingpadGUI.name_frame, direction="vertical", style="inside_shallow_frame"}

  -- Content flow
  local landingpad_gui_inner = landingpad_gui_frame.add{ type="flow", name=LandingpadGUI.name_inner, direction="vertical"}
  landingpad_gui_inner.style.padding = 12

  -- Progressbars
  landingpad_gui_inner.add{type="progressbar", name="cargo_capacity_progress", size=300, value=0, caption={"space-exploration.label_cargo", ""}, style="se_launchpad_progressbar_cargo"}

  landingpad_gui_inner.add{type="empty-widget", style="se_relative_vertical_spacer"}

  -- Properties
  local property_flow = landingpad_gui_inner.add{type="flow", direction="horizontal"}
  property_flow.add{type="label", caption={"space-exploration.launchpad_status_label"}, style="se_relative_properties_label"}
  property_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
  local status = property_flow.add{type="label", name="status", caption={""}}
  status.style.single_line = false

  LandingpadGUI.gui_update(player)
end

---@param event EventData.CustomInputEvent Event data
function LandingpadGUI.focus_search(event)
  local root = game.get_player(event.player_index).gui.relative[LandingpadGUI.name_rocket_landing_pad_gui_root]
  if not root then return end
  local textfield = util.find_first_descendant_by_name(root, GuiCommon.rename_textfield_name)
  if not textfield then return end
  textfield.focus()
end
Event.addListener(mod_prefix.."focus-search", LandingpadGUI.focus_search)

---@param player LuaPlayer
function LandingpadGUI.gui_update(player)
  local root = player.gui.relative[LandingpadGUI.name_rocket_landing_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local struct = Landingpad.from_unit_number(root.tags.unit_number)
  if not (struct and struct.container and struct.container.valid) then return Landingpad.destroy(struct) end

  local inv = struct.container.get_inventory(defines.inventory.chest)
  local inv_used = count_inventory_slots_used(inv)

  local cargo_capacity_progress = Util.find_first_descendant_by_name(root, "cargo_capacity_progress")
  local status_text = Util.find_first_descendant_by_name(root, "status")

  if cargo_capacity_progress then
    cargo_capacity_progress.caption = {"space-exploration.label_cargo", {"space-exploration.simple-a-b-divide", math.min(inv_used, #inv), #inv}}
    cargo_capacity_progress.value = math.min(inv_used, #inv) / #inv
  end
  if status_text then
    local message = {""}
    if inv_used > 0 then
      message = {"space-exploration.landingpad_unloading_required"}
    else
      message = {"space-exploration.landingpad_ready"}
    end
    if struct.inbound then
      message = {"space-exploration.landingpad_rocket_inboud"}
    end
    status_text.caption = message
  end
end

---@param struct RocketLandingPadInfo
---@param titlebar_flow LuaGuiElement
---@param edit_button boolean
function LandingpadGUI.make_titlebar_flow(struct, titlebar_flow, edit_button)
  titlebar_flow.clear()
  local force_data = storage.forces[struct.force_name]
  local rocket_landing_pad_names = force_data.rocket_landing_pad_names
  local count = table_size(rocket_landing_pad_names[struct.name])
  local name_label = titlebar_flow.add {
    type = "label",
    name = "show-name",
    caption = struct.name,
    style = "label"
  }
  name_label.style.font = "heading-1"
  name_label.style.font_color = {r=255, g=230, b=192}
  name_label.style.top_padding = -3
  name_label.style.horizontally_squashable = true
  local name_label_count = titlebar_flow.add {
    type = "label",
    name = "show-name-count",
    caption = "["..count.."]",
    style = "label"
  }
  name_label_count.style.font = "heading-1"
  name_label_count.style.font_color = {r=34, g=181, b=255}
  name_label_count.style.top_padding = -3
  if edit_button then
    titlebar_flow.add{
      type = "sprite-button",
      name = LandingpadGUI.name_rename,
      sprite = "utility/rename_icon",
      tooltip = {
        "space-exploration.rename-something", {"entity-name." .. Landingpad.name_rocket_landing_pad}
      },
      mouse_button_filter = { "left" },
      style = "frame_action_button"
    }
  else
    titlebar_flow.add{
      type = "sprite-button",
      name = LandingpadGUI.name_stop_rename,
      sprite = "utility/close",
      tooltip = { "gui.cancel" },
      mouse_button_filter = { "left" },
      style = "frame_action_button"
    }
  end

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
end

---@param landingpad_gui_frame LuaGuiElement
---@param player LuaPlayer
---@param struct RocketLandingPadInfo
function LandingpadGUI.make_change_name_confirm_flow(landingpad_gui_frame, player, struct)
  local landingpad_gui_frame_dark = landingpad_gui_frame.add{ index=1, type="frame", name=LandingpadGUI.name_frame_dark, direction="vertical", style="space_platform_subheader_frame"}

  -- Rename flow
  local name_flow = landingpad_gui_frame_dark.add {
    type = "flow",
    name = LandingpadGUI.name_name_flow,
    direction = "vertical",
  }
  local name_horizontal_flow = name_flow.add{type="flow",direction="horizontal"}
  GuiCommon.create_rename_textfield(name_horizontal_flow, struct.name)
  name_horizontal_flow.add {
    type = "sprite-button",
    name = "rename-confirm",
    sprite = "utility/enter",
    tooltip = {"space-exploration.rename-confirm"},
    style = "item_and_count_select_confirm"
  }
  local list, selected_index, values = LandingpadGUI.get_names_dropdown_values(struct)
  local dropdown = name_flow.add{
    type = "drop-down",
    name = LandingpadGUI.name_dropdown,
    items = list,
    selected_index = selected_index
  }
  dropdown.style.horizontally_stretchable  = true
  player_set_dropdown_values(player, LandingpadGUI.name_dropdown, values)
end

---@param struct RocketLandingPadInfo
---@param filter? string
---@return string[] list
---@return uint selected_index
---@return string[] values
function LandingpadGUI.get_names_dropdown_values(struct, filter)
  local list, selected_index, values = Landingpad.dropdown_list_force_landing_pad_names(struct.force_name, struct.name, filter)
  -- there is a default value at the start of the list, we don't want it here since landing pads always have a valid name
  table.remove(list, 1)
  table.remove(values, 1)
  selected_index = selected_index - 1
  return list, selected_index, values
end

---@param root LuaGuiElement
---@param player LuaPlayer
---@param struct RocketLandingPadInfo
function LandingpadGUI.gui_update_names_list(root, player, struct)
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.rename_textfield_name)
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end
  local list, selected_index, values = LandingpadGUI.get_names_dropdown_values(struct, filter)
  local landingpad_list_landing_pad_names = Util.find_first_descendant_by_name(root, LandingpadGUI.name_dropdown)
  landingpad_list_landing_pad_names.items = list
  landingpad_list_landing_pad_names.selected_index = selected_index
  player_set_dropdown_values(player, LandingpadGUI.name_dropdown, values)
end

---@param event EventData.on_gui_selection_state_changed Event data
function LandingpadGUI.gui_selection_state_changed(event)
  if not (event.element and event.element.valid and event.element.name == LandingpadGUI.name_dropdown) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[LandingpadGUI.name_rocket_landing_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Landingpad.from_unit_number(root.tags.unit_number)
  if not (struct and struct.container and struct.container.valid) then return Landingpad.destroy(struct) end

  local value = player_get_dropdown_value(player, element.name, element.selected_index)
  local rename_textfield = Util.find_first_descendant_by_name(root, GuiCommon.rename_textfield_name)
  rename_textfield.text = value
end
Event.addListener(defines.events.on_gui_selection_state_changed, LandingpadGUI.gui_selection_state_changed)

---@param event EventData.on_gui_click|EventData.on_gui_confirmed Event data
function LandingpadGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[LandingpadGUI.name_rocket_landing_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Landingpad.from_unit_number(root.tags.unit_number)
  if not (struct and struct.container and struct.container.valid) then return Landingpad.destroy(struct) end

  if element.name == LandingpadGUI.name_rename then
    local titlebar_flow = Util.find_first_descendant_by_name(root, LandingpadGUI.name_titlebar_flow)
    LandingpadGUI.make_titlebar_flow(struct, titlebar_flow, false)
    local frame = Util.find_first_descendant_by_name(root, LandingpadGUI.name_frame)
    LandingpadGUI.make_change_name_confirm_flow(frame, player, struct)
  elseif element.name == LandingpadGUI.name_stop_rename then
    local titlebar_flow = Util.find_first_descendant_by_name(root, LandingpadGUI.name_titlebar_flow)
    LandingpadGUI.make_titlebar_flow(struct, titlebar_flow, true)
    local frame_dark = Util.find_first_descendant_by_name(root, LandingpadGUI.name_frame_dark)
    frame_dark.destroy()
  elseif element.name == "rename-confirm" or (element.name == GuiCommon.rename_textfield_name and not event.button) then -- don't confirm by clicking the textbox
    local new_name = string.trim(element.parent[GuiCommon.rename_textfield_name].text)
    if new_name ~= "" and new_name ~= struct.name then
      -- do change name stuff
      Landingpad.rename(struct, new_name, true)
    end
    local titlebar_flow = Util.find_first_descendant_by_name(root, LandingpadGUI.name_titlebar_flow)
    LandingpadGUI.make_titlebar_flow(struct, titlebar_flow, true)
    local frame_dark = Util.find_first_descendant_by_name(root, LandingpadGUI.name_frame_dark)
    frame_dark.destroy()
  end
end
Event.addListener(defines.events.on_gui_click, LandingpadGUI.on_gui_click)
Event.addListener(defines.events.on_gui_confirmed, LandingpadGUI.on_gui_click)

---@param event EventData.on_gui_text_changed Event data
function LandingpadGUI.on_gui_text_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[LandingpadGUI.name_rocket_landing_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Landingpad.from_unit_number(root.tags.unit_number)
  if not (struct and struct.container and struct.container.valid) then return Landingpad.destroy(struct) end

  if element.name == GuiCommon.rename_textfield_name then
    LandingpadGUI.gui_update_names_list(root, player, struct)
  end
end
Event.addListener(defines.events.on_gui_text_changed, LandingpadGUI.on_gui_text_changed)

local function update_guis()
  for _, player in pairs(game.connected_players) do
    LandingpadGUI.gui_update(player)
  end
end
Event.addListener("on_nth_tick_60", update_guis)

RelativeGUI.register_relative_gui(
  LandingpadGUI.name_rocket_landing_pad_gui_root,
  Landingpad.name_rocket_landing_pad,
  LandingpadGUI.gui_open,
  Landingpad.from_entity
)

return LandingpadGUI
