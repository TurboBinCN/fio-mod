local LaunchpadGUI = {}

LaunchpadGUI.name_rocket_launch_pad_gui_root = mod_prefix.."rocket-launch-pad-gui"
LaunchpadGUI.name_window_close = "launchpad_close_button"

---@param player LuaPlayer
function LaunchpadGUI.gui_close(player)
  RelativeGUI.gui_close(player, LaunchpadGUI.name_rocket_launch_pad_gui_root)
end

---Creates the launchpad gui for a given player.
---@param player LuaPlayer Player
---@param launch_pad RocketLaunchPadInfo Lanuch pad data
function LaunchpadGUI.gui_open(player, launch_pad)
  LaunchpadGUI.gui_close(player)
  if not launch_pad then Log.debug('LaunchpadGUI.gui_open launch_pad not found') return end

  local struct = launch_pad
  local gui = player.gui.relative
  local playerdata = get_make_playerdata(player)

  local anchor = {gui=defines.relative_gui_type.container_gui, position=defines.relative_gui_position.left}
  local container = gui.add{
    type="frame",
    name=LaunchpadGUI.name_rocket_launch_pad_gui_root,
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

  -- Progressbars
  subheader_frame.add{type="progressbar", name="crew_capsules_progress", size=300, value=0, caption={"space-exploration.label_space_capsule", ""}, style="se_launchpad_progressbar_capsule"}
  subheader_frame.add{type="progressbar", name="rocket_sections_progress", size=300, value=0, caption={"space-exploration.label_rocket_sections", ""}, style="se_launchpad_progressbar_sections"}
  subheader_frame.add{type="progressbar", name="fuel_capacity_progress", size=300, value=0, caption={"space-exploration.label_liquid_rocket_fuel", ""}, style="se_launchpad_progressbar_fuel"}
  subheader_frame.add{type="progressbar", name="cargo_capacity_progress", size=300, value=0, caption={"space-exploration.label_cargo", ""}, style="se_launchpad_progressbar_cargo"}

  subheader_frame.add{type="empty-widget", style="se_relative_vertical_spacer"}

  -- Properties
  local property_flow = subheader_frame.add{type="flow", direction="horizontal"}
  property_flow.add{type="label", caption={"space-exploration.launchpad_cargo_safety_label"}, tooltip={"space-exploration.cargo_loss_tooltip"}, style="se_relative_properties_label"}
  property_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
  property_flow.add{type="label", name="cargo_loss", caption={"space-exploration.label_cargo_safety", ""}}
  property_flow = subheader_frame.add{type="flow", direction="horizontal"}
  property_flow.add{type="label", caption={"space-exploration.launchpad_landing_chance_label"}, tooltip={"space-exploration.survivability_loss_tooltip"}, style="se_relative_properties_label"}
  property_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
  property_flow.add{type="label", name="survivability_loss", caption={"space-exploration.label_landing_chance", ""}}
  property_flow = subheader_frame.add{type="flow", direction="horizontal"}
  property_flow.add{type="label", caption={"space-exploration.launchpad_status_label"}, style="se_relative_properties_label"}
  property_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
  local status = property_flow.add{type="label", name="status", caption={"space-exploration.label_status", ""}}
  status.style.single_line = false

  -- Content flow
  local launchpad_gui_inner = launchpad_gui_frame.add{ type="flow", name="launchpad_gui_inner", direction="vertical"}
  launchpad_gui_inner.style.padding = 12

  launchpad_gui_inner.add{type="label", name="destination-label", caption={"space-exploration.heading-destination", ""}, style="heading_3_label"}
  launchpad_gui_inner.add{type="checkbox", name="list-zones-alphabetical", caption={"space-exploration.list-destinations-alphabetically"}, state=playerdata.zones_alphabetical and true or false}
  local list, selected_index, values = LaunchpadGUI.get_zone_dropdown_values(player, struct)
  GuiCommon.create_filter(launchpad_gui_inner, player, {
    list = list,
    selected_index = selected_index,
    values = values,
    dropdown_name = "launchpad-list-zones"
  })

  launchpad_gui_inner.add{type="line", style="space_platform_line_divider"}

  launchpad_gui_inner.add{type="label", name="destination-location-label", caption={"space-exploration.heading-destination-pad-position", ""}, style="heading_3_label"}
  local list, selected_index, values = LaunchpadGUI.get_landingpad_name_dropdown_values(struct)
  GuiCommon.create_filter(launchpad_gui_inner, player, {
    list = list,
    selected_index = selected_index,
    values = values,
    dropdown_name = "launchpad-list-landing-pad-names",
    suffix = "2"
  })

  launchpad_gui_inner.add{type="line", style="space_platform_line_divider"}

  launchpad_gui_inner.add{type="label", name="trigger-label", caption={"space-exploration.heading-launch-trigger"}, style="heading_3_label"}

  local list, selected_index = dropdown_from_preset(Launchpad.trigger_options, struct.launch_trigger)
  local trigger_dropdown = launchpad_gui_inner.add{ type="drop-down", name="trigger", items=list, selected_index = selected_index}
  trigger_dropdown.style.horizontally_stretchable  = true

  LaunchpadGUI.gui_update(player)
end

---@param player LuaPlayer
---@param struct RocketLaunchPadInfo
---@param filter? string
---@return string[] list
---@return uint selected_index
---@return LocationReference[] values
function LaunchpadGUI.get_zone_dropdown_values(player, struct, filter)
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

---@param struct RocketLaunchPadInfo
---@param filter? string
---@return string[] list
---@return uint selected_index
---@return string[] values
function LaunchpadGUI.get_landingpad_name_dropdown_values(struct, filter)
  local destination_pad_name = struct.destination.landing_pad_name
  local destination_zone = struct.destination.zone
  if destination_zone then
    return Landingpad.dropdown_list_zone_landing_pad_names(struct.force_name, destination_zone, destination_pad_name, filter)
  else
    return Landingpad.dropdown_list_force_landing_pad_names(struct.force_name, destination_pad_name, filter)
  end
end

---@param player LuaPlayer
---@param inv_used uint
---@param struct RocketLaunchPadInfo
---@return LocalisedString message
---@return "ready"|"disabled"|"delayed" ready
function LaunchpadGUI.get_launch_message_ready(player, inv_used, struct)
  ---@type LocalisedString
  local message = ""
  local ready = "disabled"
  if not (storage.forces[player.force.name] and storage.forces[player.force.name].satellites_launched >= 2) then
    -- needs 1 launch to unlock nav view and a 2nd launch to generate Nauvis Orbit
    message = {"space-exploration.launchpad_requires_satellite"}
  elseif struct.launch_status > -1 then
    message = {"space-exploration.launchpad_launching_rocket"}
  elseif struct.rocket_sections < Launchpad.rocket_sections_per_rocket then
    message = {"space-exploration.launchpad_constructing_rocket"}
  elseif struct.crew_capsules < Launchpad.crew_capsules_per_rocket then
    message = {"space-exploration.launchpad_space_capsule_required"}
  elseif not struct.required_fuel then
    message = {"space-exploration.launchpad_invalid_destination"}
  elseif struct.total_fuel < struct.required_fuel then
    message = {"space-exploration.launchpad_loading_fuel"}
  elseif inv_used < Launchpad.rocket_capacity then
    message = {"space-exploration.launchpad_ready_loading_cargo"}
    ready = "ready"
  else
    message = {"space-exploration.launchpad_ready_cargo_full"}
    ready = "ready"
  end
  if ready == "ready" and struct.destination.landing_pad_name then
    if struct.destination.zone then
      local landing_pads = Landingpad.get_zone_landing_pads_availability(struct.force_name, struct.destination.zone, struct.destination.landing_pad_name)
      if not next(landing_pads.empty_landing_pads) then
        message = {"space-exploration.launchpad_waiting_for_empty_pad"}
        ready = "delayed"
        if not next(landing_pads.filled_landing_pads) then
          message = {"space-exploration.launchpad_waiting_for_pad"}
          ready = "disabled"
          if not next(landing_pads.blocked_landing_pads) then
            message = {"space-exploration.launchpad_no_pad_matches"}
          end
        end
      end
    else
      local landing_pads = Landingpad.get_force_landing_pads_availability(struct.force_name, struct.destination.landing_pad_name)
      if not next(landing_pads.empty_landing_pads) then
        message = {"space-exploration.launchpad_waiting_for_empty_pad"}
        ready = "delayed"
        if not next(landing_pads.filled_landing_pads) then
          message = {"space-exploration.launchpad_waiting_for_pad"}
          ready = "disabled"
          if not next(landing_pads.blocked_landing_pads) then
            message = {"space-exploration.launchpad_no_pad_matches"}
          end
        end
      end
    end
  end
  return message, ready
end

---@param event EventData.CustomInputEvent Event data
function LaunchpadGUI.focus_search(event)
  local root = game.get_player(event.player_index).gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not root then return end
  local textfield = util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  if not textfield then return end
  textfield.focus()
end
Event.addListener(mod_prefix.."focus-search", LaunchpadGUI.focus_search)

---@param player LuaPlayer
function LaunchpadGUI.gui_update(player)
  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local struct = Launchpad.from_unit_number(root.tags.unit_number)
  if not (struct and struct.valid) then return LaunchpadGUI.gui_close(player) end

  Launchpad.prep(struct)

  local inv = struct.container.get_inventory(defines.inventory.chest)
  local empty_stacks = struct.empty_stacks or 0
  local unbarred_inventory_size = inv.get_bar() - 1
  local inv_used = unbarred_inventory_size - empty_stacks
  struct.crew_capsules = struct.crew_capsules or 0
  struct.rocket_sections = struct.rocket_sections or 0

  local crew_capsules_progress = Util.find_first_descendant_by_name(root, "crew_capsules_progress")
  local rocket_sections_progress = Util.find_first_descendant_by_name(root, "rocket_sections_progress")
  local fuel_capacity_progress = Util.find_first_descendant_by_name(root, "fuel_capacity_progress")
  local cargo_capacity_progress = Util.find_first_descendant_by_name(root, "cargo_capacity_progress")
  local cargo_loss_text = Util.find_first_descendant_by_name(root, "cargo_loss")
  local survivability_loss_text = Util.find_first_descendant_by_name(root, "survivability_loss")
  local status_text = Util.find_first_descendant_by_name(root, "status")
  local launch_button = Util.find_first_descendant_by_name(root, "launch")
  local launch_disabled_button = Util.find_first_descendant_by_name(root, "launch-disabled")

  if crew_capsules_progress then
    crew_capsules_progress.caption = {"space-exploration.label_space_capsule", {"space-exploration.simple-a-b-divide", struct.crew_capsules, Launchpad.crew_capsules_per_rocket}}
    crew_capsules_progress.value = struct.crew_capsules / Launchpad.crew_capsules_per_rocket
  end
  if rocket_sections_progress then
    rocket_sections_progress.caption={"space-exploration.label_cargo_rocket_sections", {"space-exploration.simple-a-b-divide", struct.rocket_sections, Launchpad.rocket_sections_per_rocket}}
    rocket_sections_progress.value = struct.rocket_sections / Launchpad.rocket_sections_per_rocket
  end

  if fuel_capacity_progress then
    if struct.required_fuel then
      local shown_fuel_level = struct.total_fuel
      -- if the fuel requirement is met and within one tank capacity/cycle of the required fuel, round it down. otherwise show all.
      if struct.total_fuel >= struct.required_fuel and struct.total_fuel - Launchpad.get_tank_capacity() < struct.required_fuel then
        shown_fuel_level = struct.required_fuel
      end
      fuel_capacity_progress.caption={"space-exploration.label_liquid_rocket_fuel", {"space-exploration.simple-a-b-divide",
        Util.format_fuel(shown_fuel_level),
        Util.format_fuel(struct.required_fuel)}}
      fuel_capacity_progress.value=math.min(struct.total_fuel, struct.required_fuel) / (struct.required_fuel)
    else
      fuel_capacity_progress.caption={"space-exploration.label_liquid_rocket_fuel", {"space-exploration.simple-a-b-divide",
        Util.format_fuel(math.floor(struct.total_fuel)),
        "?"}}
      fuel_capacity_progress.value=0
    end
  end

  if cargo_capacity_progress then
    cargo_capacity_progress.caption={"space-exploration.label_cargo", {"space-exploration.simple-a-b-divide", math.min(inv_used, Launchpad.rocket_capacity), Launchpad.rocket_capacity}}
    cargo_capacity_progress.value=math.min(inv_used, Launchpad.rocket_capacity) / Launchpad.rocket_capacity
  end

  local message, ready = LaunchpadGUI.get_launch_message_ready(player, inv_used, struct)
  local delta_v = Zone.get_travel_delta_v(struct.zone, struct.destination.zone)

  if cargo_loss_text then
    local cargo_loss = Launchpad.get_cargo_loss(game.forces[struct.force_name], struct.destination.zone, delta_v)
    if struct.destination and struct.destination.landing_pad_name then
      cargo_loss = cargo_loss / 2
    end
    if struct.destination.zone then
      cargo_loss_text.caption = string.format("%.2f", (1-cargo_loss)*100).."%"
    else
      cargo_loss_text.caption = {"space-exploration.variable"}
    end
  end

  if survivability_loss_text then
    local survivability_loss = Launchpad.get_survivability_loss(game.forces[struct.force_name], struct.destination.zone, delta_v)
    if struct.destination and struct.destination.landing_pad_name then
      if struct.destination.zone then
        survivability_loss_text.caption = string.format("%.2f", (1-survivability_loss)*100).."%"
      else
        survivability_loss_text.caption = {"space-exploration.variable"}
      end
      survivability_loss_text.tooltip = {"space-exploration.survivability_loss_tooltip"}
    else
      survivability_loss_text.caption = {"space-exploration.requires_landing_pad"}
      survivability_loss_text.tooltip = {"space-exploration.survivability_loss_no_pad_tooltip"}
    end
  end

  if status_text then
    status_text.caption = message
  end

  if ready == "ready" or ready == "delayed" then
    if launch_disabled_button then launch_disabled_button.destroy() end
    if not launch_button then
      local launch_button
      if ready == "delayed" then
        launch_button = root.add{ type="button", name="launch", caption={"space-exploration.launchpad_launch_delayed"}, style="confirm_button",
          tooltip={"space-exploration.launchpad_launch_delayed_tooltip"}}
      else
        launch_button = root.add{ type="button", name="launch", caption={"space-exploration.button-launch"}, style="confirm_button"}
      end
      launch_button.style.top_margin = 10
      launch_button.style.horizontally_stretchable  = true
      launch_button.style.horizontal_align = "left"
    end
  else
    if launch_button then launch_button.destroy() end
    if not launch_disabled_button then
      launch_disabled_button = root.add{ type="button", name="launch-disabled", caption={"space-exploration.button-launch-disabled"}, style="red_confirm_button"}
      launch_disabled_button.style.top_margin = 10
      launch_disabled_button.style.horizontally_stretchable  = true
      launch_disabled_button.style.horizontal_align = "left"
    end
    if struct.launch_status > -1 then
      launch_disabled_button.caption = {"space-exploration.launchpad_launch_in_progress"}
    else
      launch_disabled_button.caption = {"space-exploration.button-launch-disabled"}
    end
  end
end

---@param event EventData.on_gui_click Event data
function LaunchpadGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Launchpad.from_unit_number(root.tags.unit_number)
  if not struct then return end

  if element.name == "launch" then
    Launchpad.launch(struct, false, true)
  elseif element.name == GuiCommon.filter_clear_name then
    element.parent[GuiCommon.filter_textfield_name].text = ""
    LaunchpadGUI.gui_update_destinations_list(root, player, struct)
  elseif element.name == GuiCommon.filter_clear_name.."2" then
    element.parent[GuiCommon.filter_textfield_name.."2"].text = ""
    LaunchpadGUI.gui_update_landingpad_list(root, player, struct)
  end
end
Event.addListener(defines.events.on_gui_click, LaunchpadGUI.on_gui_click)

---@param player LuaPlayer
---@param struct RocketLaunchPadInfo
---@param dropdown_element LuaGuiElement
local function on_landing_pad_name_dropdown_changed(player, struct, dropdown_element)
  local value = player_get_dropdown_value(player, dropdown_element.name, dropdown_element.selected_index)
  local landing_pad_name = value
  Launchpad.set_destination(struct, landing_pad_name)
  -- When changing destination, reset trigger to prevent accidental launches
  LaunchpadGUI.reset_launch_trigger_to_manual(player, struct)
  LaunchpadGUI.gui_update(player)
end

---@param player LuaPlayer
---@param struct RocketLaunchPadInfo
---@param zone_list_dropdown_element LuaGuiElement
local function set_landing_pad_dropdown_values(player, struct, zone_list_dropdown_element)
  local list, selected_index, values
  local current_destination_pad_name = struct.destination.landing_pad_name

  if struct.destination.zone == nil then -- "Any pad with name"
    list, selected_index, values = Landingpad.dropdown_list_force_landing_pad_names(struct.force_name, current_destination_pad_name)
  else
    list, selected_index, values = Landingpad.dropdown_list_zone_landing_pad_names(struct.force_name, struct.destination.zone, current_destination_pad_name)
  end
  local pad_names_dropdown_element = zone_list_dropdown_element.parent["launchpad-list-landing-pad-names"]
  pad_names_dropdown_element.items = list
  pad_names_dropdown_element.selected_index = selected_index
  player_set_dropdown_values(player, "launchpad-list-landing-pad-names", values)

  on_landing_pad_name_dropdown_changed(player, struct, pad_names_dropdown_element)
end

---@param event EventData.on_gui_selection_state_changed Event data
function LaunchpadGUI.on_selection_state_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Launchpad.from_unit_number(root.tags.unit_number)
  if not struct then return end

  if element.name == "trigger" then

    struct.launch_trigger = selected_name_from_dropdown_preset(element, Launchpad.trigger_options) or "none"

  elseif element.name == "launchpad-list-zones" then

    local value = player_get_dropdown_value(player, element.name, element.selected_index)
    if type(value) == "table" then
      if value.type == "zone" then
        local zone_index = value.index
        local zone = Zone.from_zone_index(zone_index)
        if zone then
          struct.destination.zone = zone
          Log.debug("set destination to location: " .. zone.name )
        end
        set_landing_pad_dropdown_values(player, struct, element)
      elseif value.type == "spaceship" then
        local spaceship_index = value.index
        local spaceship = Spaceship.from_index(spaceship_index)
        if spaceship then
          struct.destination.zone = spaceship
          Log.debug("set destination to spaceship : " .. spaceship.name )
        end
        set_landing_pad_dropdown_values(player, struct, element)
      elseif value.type == "any" then
        struct.destination.zone = nil
        Log.debug("set destination to location: any")
        set_landing_pad_dropdown_values(player, struct, element)
      end
    else
      LaunchpadGUI.gui_close(player)
      Log.debug("Error: Non-table value ")
    end

  elseif element.name == "launchpad-list-landing-pad-names" then
    on_landing_pad_name_dropdown_changed(player, struct, element)
  end
end
Event.addListener(defines.events.on_gui_selection_state_changed, LaunchpadGUI.on_selection_state_changed)

---@param player LuaPlayer
---@param struct RocketLaunchPadInfo
function LaunchpadGUI.reset_launch_trigger_to_manual(player, struct)
  struct.launch_trigger = "none"
  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  local trigger = Util.find_first_descendant_by_name(root, "trigger")
  trigger.selected_index = 1
end

---@param root LuaGuiElement
---@param player LuaPlayer
---@param struct RocketLaunchPadInfo
function LaunchpadGUI.gui_update_destinations_list(root, player, struct)
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end
  local list, selected_index, values = LaunchpadGUI.get_zone_dropdown_values(player, struct, filter)
  local launchpad_list_zones = Util.find_first_descendant_by_name(root, "launchpad-list-zones")
  launchpad_list_zones.items = list
  launchpad_list_zones.selected_index = selected_index
  player_set_dropdown_values(player, "launchpad-list-zones", values)
end

---@param root LuaGuiElement
---@param player LuaPlayer
---@param struct RocketLaunchPadInfo
function LaunchpadGUI.gui_update_landingpad_list(root, player, struct)
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name.."2")
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end
  local list, selected_index, values = LaunchpadGUI.get_landingpad_name_dropdown_values(struct, filter)
  local landingpads_dropdown = Util.find_first_descendant_by_name(root, "launchpad-list-landing-pad-names")
  landingpads_dropdown.items = list
  landingpads_dropdown.selected_index = selected_index
  player_set_dropdown_values(player, "launchpad-list-landing-pad-names", values)
end

---@param event EventData.on_gui_checked_state_changed Event data
function LaunchpadGUI.on_gui_checked_state_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Launchpad.from_unit_number(root.tags.unit_number)
  if not struct then return end

  if element.name == "list-zones-alphabetical" then
    local playerdata = get_make_playerdata(player)
    playerdata.zones_alphabetical = element.state
    LaunchpadGUI.gui_update_destinations_list(root, player, struct)
  end
end
Event.addListener(defines.events.on_gui_checked_state_changed, LaunchpadGUI.on_gui_checked_state_changed)

---@param event EventData.on_gui_text_changed Event data
function LaunchpadGUI.on_gui_text_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local struct = Launchpad.from_unit_number(root.tags.unit_number)
  if not struct then return end

  if element.name == GuiCommon.filter_textfield_name then
    LaunchpadGUI.gui_update_destinations_list(root, player, struct)
  elseif element.name == GuiCommon.filter_textfield_name.."2" then
    LaunchpadGUI.gui_update_landingpad_list(root, player, struct)
  end
end
Event.addListener(defines.events.on_gui_text_changed, LaunchpadGUI.on_gui_text_changed)

RelativeGUI.register_relative_gui(
  LaunchpadGUI.name_rocket_launch_pad_gui_root,
  Launchpad.name_rocket_launch_pad,
  LaunchpadGUI.gui_open,
  Launchpad.from_entity
)

--- Respond to the main entity GUI being closed by destroying the relative GUI
---@param event EventData.on_gui_closed Event data
function LaunchpadGUI.on_gui_closed(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if player and event.entity and event.entity.name == Launchpad.name_rocket_launch_pad then
    LaunchpadGUI.gui_close(player)
  end
end
Event.addListener(defines.events.on_gui_closed, LaunchpadGUI.on_gui_closed)

--- Opens the launchpad gui when a launchpad is clicked or vehicle button is pressed from a seat
--- Closes the launchpad gui when another gui is opened
---@param event EventData.on_gui_opened Event data
function LaunchpadGUI.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if event.entity and event.entity.valid then
    local entity_name = event.entity.name
    if entity_name == Launchpad.name_rocket_launch_pad then
      LaunchpadGUI.gui_open(player, Launchpad.from_entity(event.entity))
    elseif entity_name == Launchpad.name_rocket_launch_pad_seat then
      --find which silo has this seat
      local silo  = event.entity.surface.find_entities_filtered{
        position=util.vectors_add(event.entity.position, {x=0, y=-Launchpad.seat_y_offset}),
        name=Launchpad.name_rocket_launch_pad,
        limit=1
      }[1]
      local launchpad = Launchpad.from_unit_number(silo.unit_number)
      if launchpad then
        player.opened = launchpad.container
      end
    else
      LaunchpadGUI.gui_close(player)
    end
  else
    LaunchpadGUI.gui_close(player)
  end
end
Event.addListener(defines.events.on_gui_opened, LaunchpadGUI.on_gui_opened)

return LaunchpadGUI
