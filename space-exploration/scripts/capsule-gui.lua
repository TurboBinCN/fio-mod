local CapsuleGUI = {}

CapsuleGUI.name_space_capsule_gui_root = mod_prefix.."space-capsule-gui"

---@param player LuaPlayer
function CapsuleGUI.gui_close(player)
  RelativeGUI.gui_close(player, CapsuleGUI.name_space_capsule_gui_root)
end

---Opens the gui of a given space capsule _entity_.
---@param player LuaPlayer Player to open GUI for
---@param capsule_container LuaEntity Actual space capsule container
function CapsuleGUI.gui_open(player, capsule_container)
  CapsuleGUI.gui_close(player)
  if not capsule_container then Log.debug('CapsuleGUI.gui_open capsule_container not found') return end

  local space_capsule = Capsule.from_container(capsule_container)
  if not space_capsule then return end

  local capsule_vehicle = space_capsule.vehicle

  -- The GUI is attached to the container. If there is no container then don't open.
  if not (space_capsule.container and space_capsule.container.valid) then return end

  if not (capsule_vehicle and capsule_vehicle.valid) then return end

  -- Don't open the GUI if a launch is in progress
  if space_capsule.tick_task then return end

  local gui = player.gui.relative
  local anchor = {gui=defines.relative_gui_type.container_gui, position=defines.relative_gui_position.right}

  -- Store capsule's unit number as a tag
  local container = gui.add{
    type="frame",
    name=CapsuleGUI.name_space_capsule_gui_root,
    direction="vertical",
    anchor=anchor,
    tags={unit_number=space_capsule.unit_number},
    style="se_entity_settings_frame"
  }

  local titlebar_flow = container.add{
    type="flow",
    direction="horizontal",
    style="se_relative_titlebar_flow"
  }

  titlebar_flow.add{  -- GUI label
    type="label",
    caption={"space-exploration.relative-window-navigation"},
    style="frame_title"
  }

  titlebar_flow.add{  -- Spacer
    type="empty-widget",
    ignored_by_interaction=true,
    style="se_relative_titlebar_nondraggable_spacer"
  }

  titlebar_flow.add{  -- Starmap button
    type="sprite-button",
    sprite="se-map-gui-starmap",
    tooltip={"space-exploration.star-map"},
    style="frame_action_button",
    tags={se_action="starmap-cycle"}
  }

  titlebar_flow.add{  -- Informatron button
    type="sprite-button",
    sprite="virtual-signal/informatron",
    style="frame_action_button",
    tooltip={"space-exploration.informatron-open-help"},
    tags={se_action="goto-informatron", informatron_page="space_capsule"}
  }

  local capsule_gui_frame = container.add{ type="frame", name="capsule_gui_inner", direction="vertical", style="inside_shallow_frame"}

  local subheader_frame = capsule_gui_frame.add{type="frame", direction="vertical", style="space_platform_subheader_frame"}

  -- Capacity
  local property_flow = subheader_frame.add{type="flow", direction="horizontal"}
  property_flow.add{type="label", caption={"space-exploration.space-capsule-capacity-label"}, tooltip={"space-exploration.space-capsule-capacity-tooltip"}, style="se_relative_properties_label"}
  property_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
  property_flow.add{type="label", name="capacity", caption=""}

  -- First stage
  property_flow = subheader_frame.add{type="flow", direction="horizontal"}
  property_flow.add{type="label", caption={"space-exploration.space-capsule-sections-label"}, tooltip={"space-exploration.space-capsule-sections-tooltip"},  style="se_relative_properties_label"}
  property_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
  property_flow.add{type="label", name="sections", caption=""}

  -- Fuel
  property_flow = subheader_frame.add{type="flow", direction="horizontal"}
  property_flow.add{type="label", caption={"space-exploration.space-capsule-fuel-label"}, tooltip={"space-exploration.space-capsule-fuel-tooltip"}, style="se_relative_properties_label"}
  property_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
  property_flow.add{type="label", name="fuel", caption=""}

  -- Status
  property_flow = subheader_frame.add{type="flow", direction="horizontal"}
  property_flow.add{type="label", caption={"space-exploration.space-capsule-status-label"}, style="se_relative_properties_label"}
  property_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
  local status_text = property_flow.add{type="label", name="status", caption=""}

  local capsule_gui_inner = capsule_gui_frame.add{type="flow", name="capsule_gui_inner", direction="vertical", style="se_entity_settings_inner_flow"}

  if not Capsule.can_launch_capsule(player.force.name) then
    capsule_gui_inner.add{type="label", name="must_launch_cargo_rocket", caption={"space-exploration.space-capsule-must-research-navigation-info"}, style="se_space_capsule_info_label"}
  end
  -- Destination heading
  capsule_gui_inner.add{type="label", name="destination", caption={"space-exploration.heading-destination"}, style="heading_3_label"}

  local zone = Zone.from_surface(capsule_vehicle.surface)

  if zone then
      -- Destination dropdown
      local dropdown = capsule_gui_inner.add{type="drop-down", name="space-capsule-list-zones", style="se_entity_settings_zones_dropdown"}
      CapsuleGUI.make_set_dropdown_items(player, dropdown, space_capsule)

      -- Destination targeting button and coordinates
      local position_flow = capsule_gui_inner.add{type="flow", direction="horizontal", style="se_entity_settings_target_coordinates_flow"}
      position_flow.add{type="sprite-button", name="set_target", sprite="item/artillery-targeting-remote", tooltip={"space-exploration.choose_coordinates"}}
      position_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
      position_flow.add{type="label", name="target_coordinates", caption="No target selected"}
  end

  capsule_gui_inner.add{type="line", style="space_platform_line_divider"}

  -- Info label
  capsule_gui_inner.add{type="label", name="info", caption={"space-exploration.space-capsule-info"}, style="se_space_capsule_info_label"}

  -- Launch button
  container.add{type="button", name="launch", caption={"space-exploration.button-launch"}, style="se_space_capsule_green_launch_button", tooltip={"space-exploration.button-launch"}}

  if not zone then
    status_text.caption={"space-exploration.space-capsule-status-invalid-source"}
  else
    CapsuleGUI.gui_update(player)
  end
end

---Updates the Space capsule GUI content
---@param player LuaPlayer Player
function CapsuleGUI.gui_update(player)
-- Validate GUI open, character and entities are valid, and data structures are available
  local root = player.gui.relative[CapsuleGUI.name_space_capsule_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local character = player_get_character(player)
  if not character then return CapsuleGUI.gui_close(player) end

  local space_capsule = Capsule.from_unit_number(root.tags.unit_number)
  if not space_capsule then return CapsuleGUI.gui_close(player) end

  local container = space_capsule.container
  if not (container and container.valid) then return CapsuleGUI.gui_close(player) end

  local vehicle = space_capsule.vehicle
  if not (vehicle and vehicle.valid) then return CapsuleGUI.gui_close(player) end

  -- Close GUI if Capsule is not within an SE zone
  local current_zone = Zone.from_surface(vehicle.surface)
  if not current_zone then return CapsuleGUI.gui_close(player) end

  local capacity_text = Util.find_first_descendant_by_name(root, "capacity")
  local sections_text = Util.find_first_descendant_by_name(root, "sections")
  local fuel_text = Util.find_first_descendant_by_name(root, "fuel")
  local status_text = Util.find_first_descendant_by_name(root, "status")
  local info_text = Util.find_first_descendant_by_name(root, "info")
  local dropdown = Util.find_first_descendant_by_name(root, "space-capsule-list-zones")
  local set_target_button = Util.find_first_descendant_by_name(root, "set_target")
  local coordinates = Util.find_first_descendant_by_name(root, "target_coordinates")
  local launch_button = Util.find_first_descendant_by_name(root, "launch")

  capacity_text.caption = "-"
  sections_text.caption = "-"
  fuel_text.caption = "-"
  status_text.caption = ""
  info_text.caption = ""
  coordinates.caption = ""

  if current_zone then
    -- If on board a moving spaceship, update the dropdown items
    if current_zone.is_moving and dropdown then
      CapsuleGUI.make_set_dropdown_items(player, dropdown, space_capsule)
    end

    local jump_zone = space_capsule.jump_zone

    if jump_zone and dropdown then
      local values = player_get_dropdown_values(player, "space-capsule-list-zones")
      local selected_index
      for i, value in pairs(values) do
        if value.zone == jump_zone.zone and value.field == jump_zone.field then
          selected_index = i
          break
        end
      end
      if selected_index then
        dropdown.selected_index = selected_index
      end
      dropdown.visible = true
    end

    if jump_zone and jump_zone.zone then
      local passengers = Capsule.get_vehicle_passengers(vehicle)

      -- Treat the player that opened the GUI as a passenger for calculations even if they're not inside
      local player_in_capsule = false
      for _, passenger in pairs(passengers) do
        if passenger == player_get_character(player) then
          player_in_capsule = true
        end
      end
      if not player_in_capsule then
        table.insert(passengers, player.character)
      end

      local stacks, capsule_inv = Capsule.get_inventory_stacks(container, passengers)

      local can_launch = true

      -- Cannot launch a capsule that's already in the middle of a launch
      if space_capsule.tick_task then can_launch = false end

      local max_stacks = #container.get_inventory(defines.inventory.chest)
      if Zone.is_solid(jump_zone.zone) then max_stacks = Capsule.max_stacks_infinite end

      local fuel_items, fuel_value, fuel_energy = Capsule.get_fuel_info(capsule_inv)
      local sections = Capsule.get_section_info(capsule_inv)
      local fuel_cost, sections_cost, base_stacks, excess_sections

      fuel_cost, sections_cost, stacks, base_stacks, excess_sections =
        Capsule.get_launch_costs_adv(current_zone, jump_zone, stacks, fuel_items, sections)

      if max_stacks == Capsule.max_stacks_infinite then
        capacity_text.caption = {"space-exploration.space-capsule-capacity-infinite", stacks}
      elseif stacks <= max_stacks then
        capacity_text.caption = {"space-exploration.space-capsule-capacity", stacks, max_stacks}
      else
        can_launch = false
        capacity_text.caption = {"space-exploration.space-capsule-capacity-over", stacks, max_stacks}
      end
      capacity_text.tooltip = {"space-exploration.space-capsule-capacity-breakdown", base_stacks, excess_sections}

      if jump_zone.field == "homeworld-emergency" then
        sections_text.caption = {"space-exploration.space-capsule-sections-na"}
        fuel_text.caption = {"space-exploration.space-capsule-fuel-emergency"}
        status_text.caption = {"space-exploration.space-capsule-status-ready-emergency"}
        info_text.caption = {"", {"space-exploration.space-capsule-info-emergency", Capsule.emergency_burn_player_inventory_loss_multiplier * 100}, {"space-exploration.space-capsule-info"}}
      else

        status_text.caption={"space-exploration.space-capsule-status-ready"}
        info_text.caption = {"space-exploration.space-capsule-info"}

        if stacks > max_stacks then
          status_text.caption={"space-exploration.space-capsule-status-overcapacity"}
        end

        if fuel_energy < fuel_cost then
          can_launch = false
          fuel_text.caption={"space-exploration.space-capsule-fuel-low", fuel_items, math.ceil(fuel_cost / fuel_value)}
          status_text.caption={"space-exploration.space-capsule-status-low-fuel"}
        else
          fuel_text.caption={"space-exploration.space-capsule-fuel", fuel_items, math.ceil(fuel_cost / fuel_value)}
        end

        if sections < sections_cost then
          can_launch = false
          sections_text.caption={"space-exploration.space-capsule-sections-low", sections, sections_cost}
          status_text.caption={"space-exploration.space-capsule-status-low-sections"}
        else
          sections_text.caption={"space-exploration.space-capsule-sections", sections, sections_cost}
        end
      end

      -- Disable targeting button for undiscoverd jump zones as well as homeworld emergency
      if jump_zone.undiscovered or jump_zone.field == "homeworld-emergency" then
        if set_target_button.enabled then set_target_button.enabled = false end
        coordinates.caption = {"space-exploration.space-capsule-target-coordinates-unsettable"}
      else
        if not set_target_button.enabled then set_target_button.enabled = true end
        if jump_zone.coordinates then
          coordinates.caption = {"space-exploration.space-capsule-target-coordinates", math.floor(jump_zone.coordinates.x), math.floor(jump_zone.coordinates.y)}
        else
          coordinates.caption = {"space-exploration.space-capsule-no-target-coordinates"}
        end
      end

      if jump_zone.undiscovered then
        info_text.caption = {"", {"space-exploration.space-capsule-destination-unknown"}, {"space-exploration.space-capsule-info"}}
      end

      if can_launch then
        if player_in_capsule then
          launch_button.caption = {"space-exploration.button-launch"}
          launch_button.style = "se_space_capsule_green_launch_button"
        else
          launch_button.caption = {"space-exploration.button-launch-no-passenger"}
          launch_button.style = "se_space_capsule_yellow_launch_button"
        end
      else
        launch_button.caption = {"space-exploration.button-launch-disabled"}
        launch_button.style = "se_space_capsule_red_launch_button"
      end
    else
      status_text.caption={"space-exploration.space-capsule-status-no-destinations"}
      info_text.caption = {"", {"space-exploration.space-capsule-info"}}
      -- dropdown.visible = false
    end
  else
    status_text.caption={"space-exploration.space-capsule-status-invalid-source"}
    info_text.caption = {"", {"space-exploration.space-capsule-info"}}
    -- dropdown.visible = false
  end
end

---Determines and sets the jump zone dropdown items accessible to a given space capsule.
---@param player LuaPlayer Player
---@param dropdown LuaGuiElement Jump zone dropdown
---@param space_capsule CapsuleInfo Capsule data
function CapsuleGUI.make_set_dropdown_items(player, dropdown, space_capsule)
  local zone = space_capsule.current_zone
  local force = game.forces[space_capsule.force_name]
  local jump_zones = Zone.get_space_jumps(zone, force, 4, true)

  local selected_index
  local list, values = {}, {}

  if next(jump_zones) then
    for i, jump_zone in pairs(jump_zones) do
      table.insert(list, Zone.space_jump_readout(jump_zone))
      table.insert(values, jump_zone)
      if space_capsule.jump_zone
        and space_capsule.jump_zone.zone == jump_zone.zone
        and space_capsule.jump_zone.field == jump_zone.field then
        selected_index = i
      end
    end

    -- If the capsule's currently set target is not one of the possible jump zones, reset the
    -- capsule's jump zone
    if not selected_index then
      selected_index = 1
      Capsule.set_target(player, space_capsule, jump_zones[1].zone)
    end

    -- Destination dropdown
    dropdown.items = list
    dropdown.selected_index = selected_index
    player_set_dropdown_values(player, "space-capsule-list-zones", values)
  else
    -- Remove currently set jump zone from capsule
    Capsule.set_target(player, space_capsule, nil)

    dropdown.clear_items()
    player_set_dropdown_values(player, "space-capsule-list-zones", values)
  end
end

---Updates capsule GUIs every 60 ticks, in case an inserter places items in the capsule.
function CapsuleGUI.on_nth_tick_60()
  for _, player in pairs(game.connected_players) do
    CapsuleGUI.gui_update(player)
  end
end
Event.addListener("on_nth_tick_60", CapsuleGUI.on_nth_tick_60)

---Handles mouse clicks on Space capsule GUI
---@param event EventData.on_gui_click Event data
function CapsuleGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  if element.name == "launch" then
    local root = gui_element_or_parent(element, CapsuleGUI.name_space_capsule_gui_root)
    if root then
      local player = game.get_player(event.player_index)
      ---@cast player -?
      local space_capsule = Capsule.from_unit_number(root.tags.unit_number)
      if not space_capsule then return CapsuleGUI.gui_close(player) end
      local result = Capsule.launch(space_capsule)
      if result and result.fail_message then
        player.print(result.fail_message)
      end
    end
  elseif element.name == "set_target" then
    local player = game.get_player(event.player_index)
    ---@cast player -?
    local root = gui_element_or_parent(element, CapsuleGUI.name_space_capsule_gui_root)
    if root then
      local space_capsule = Capsule.from_unit_number(root.tags.unit_number)
      if not space_capsule then return CapsuleGUI.gui_close(player) end
      if event.button == defines.mouse_button_type.left then
        if not RemoteView.is_unlocked(player) then
          return player.print(RemoteView.intersurface_unlock_requirement_string(player))
        end
        if not player.cursor_stack then return end
        RemoteView.add_history_current(player) --Save history point
        RemoteView.start_activity(player, {
          type = "space-capsule",
          space_capsule=space_capsule
        }, space_capsule.jump_zone and space_capsule.jump_zone.zone)
        player.cursor_stack.set_stack{name=Capsule.name_capsule_targeter, count=1}
        player.opened = nil
        RemoteViewGUI.show_entity_back_button(player, space_capsule.container)
      elseif event.button == defines.mouse_button_type.right then
        Capsule.set_target(player, space_capsule,
          space_capsule.jump_zone and space_capsule.jump_zone.zone)
        CapsuleGUI.gui_update(player)
      end
    end
  end
end
Event.addListener(defines.events.on_gui_click, CapsuleGUI.on_gui_click)

---Handles a player modifying the selected jump zone in the capsule navigation GUI.
---@param event EventData.on_gui_selection_state_changed Event data
function CapsuleGUI.on_gui_selection_state_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  if element.name == "space-capsule-list-zones" then
    local root = gui_element_or_parent(element, CapsuleGUI.name_space_capsule_gui_root)
    if root then
      local player = game.get_player(event.player_index)
      ---@cast player -?
      local space_capsule = Capsule.from_unit_number(root.tags.unit_number)
      if not space_capsule then return CapsuleGUI.gui_close(player) end

      space_capsule.jump_zone = player_get_dropdown_value(player, element.name, element.selected_index)
    end
    CapsuleGUI.gui_update(game.get_player(event.player_index))
  end
end
Event.addListener(defines.events.on_gui_selection_state_changed, CapsuleGUI.on_gui_selection_state_changed)

--- Update the Capsule GUI when the player inventory changes and they have the capsule GUI opened
---@param event EventData.on_player_main_inventory_changed Event data
function CapsuleGUI.on_player_main_inventory_changed(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if player and player.opened_gui_type == defines.gui_type.entity and player.opened.name == Capsule.name_space_capsule_container then
    CapsuleGUI.gui_update(player)
  end
end
Event.addListener(defines.events.on_player_main_inventory_changed, CapsuleGUI.on_player_main_inventory_changed)

--open the normal capsule GUI when attempting to open the vehicle
---@param event EventData.on_gui_opened Event data
function CapsuleGUI.on_gui_opened(event)
  if event.gui_type == defines.gui_type.entity then
    if event.entity.valid then
      local entity_name = event.entity.name
      if entity_name == Capsule.name_space_capsule_vehicle then
        local player = game.get_player(event.player_index)
        ---@cast player -?
        local space_capsule = Capsule.from_vehicle(event.entity)
        if space_capsule then
          if space_capsule.container.valid then
            player.opened = space_capsule.container
          else
            -- Destroy the vehicle; event handler will destroy anything else that's left
            event.entity.destroy{raise_destroy=true}
          end
        end
      elseif entity_name == Capsule.name_space_capsule_scorched_vehicle then
        local player = game.get_player(event.player_index)
        ---@cast player -?
        local container = event.entity.surface.find_entity(Capsule.name_space_capsule_scorched_container, event.entity.position)
        if container then
          player.opened = container
        else
          -- Destroy the vehicle; event handler will destroy anything else that's left
          event.entity.destroy{raise_destroy=true}
        end
      end
    end
  end
end
Event.addListener(defines.events.on_gui_opened, CapsuleGUI.on_gui_opened)

RelativeGUI.register_relative_gui(
  CapsuleGUI.name_space_capsule_gui_root,
  Capsule.name_space_capsule_container,
  CapsuleGUI.gui_open
)

return CapsuleGUI
