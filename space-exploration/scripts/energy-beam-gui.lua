local EnergyBeamGUI = {}

EnergyBeamGUI.name_transmitter_gui_root = "energy_transmitter"
EnergyBeamGUI.dropdown_options = {
  {caption={"space-exploration.energy_transmitter_label_off"},tooltip={"space-exploration.energy_transmitter_tooltip_off"}},
  {caption={"space-exploration.energy_transmitter_label_energise"},tooltip={"space-exploration.energy_transmitter_tooltip_energise"}},
  {caption={"space-exploration.energy_transmitter_label_glaive"},tooltip={"space-exploration.energy_transmitter_tooltip_glaive"}},
  {caption={"space-exploration.energy_transmitter_label_auto_glaive"},tooltip={"space-exploration.energy_transmitter_tooltip_auto_glaive"}}
}
EnergyBeamGUI.dropdown_idxs = {
  "off",
  "energise",
  "glaive",
  "auto-glaive"
}

---@param player LuaPlayer
function EnergyBeamGUI.gui_close(player)
  RelativeGUI.gui_close(player, EnergyBeamGUI.name_transmitter_gui_root)
end

--- Creates the energy beamer gui for a player
---@param player LuaPlayer
---@param tree EnergyBeamEmitterInfo
function EnergyBeamGUI.gui_open(player, tree)
  EnergyBeamGUI.gui_close(player)
  if not tree then
    Log.debug('EnergyBeamGUI.gui_open tree not found')
    return
  end

  local gui = player.gui.relative
  local playerdata = get_make_playerdata(player)

  local anchor = {gui=defines.relative_gui_type.assembling_machine_gui, position=defines.relative_gui_position.right}
  local container = gui.add{
    type = "frame",
    name = EnergyBeamGUI.name_transmitter_gui_root,
    direction="vertical",
    anchor = anchor,
    -- use gui element tags to store a reference to what energy beam transmitter thhis gui is displaying/controls
    tags = {
      unit_number = tree.unit_number
    }
  }
  container.style.vertically_stretchable = true

  local titlebar_flow = container.add{
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
    tags={se_action="goto-informatron", informatron_page="energy_beams"}
  }

  local beamer_gui_inner = container.add{ type="frame", name="beamer_gui_inner", direction="vertical", style="b_inner_frame"}
  beamer_gui_inner.style.padding = 10

  beamer_gui_inner.add{ type="label", name="energy", caption={"space-exploration.label_energy", ""}}
  beamer_gui_inner.add{ type="label", name="efficiency", caption={"space-exploration.label_efficiency", ""}}

  local active_container = beamer_gui_inner.add{ type="flow", name="active_container", direction="horizontal"}
  active_container.style.vertical_align = "center"

  local dropdown_tooltip_merged = {}
  for _, option in pairs(EnergyBeamGUI.dropdown_options) do
    local option_tooltip = {"space-exploration.simple-a-b-colon", {"space-exploration.simple-bold", option.caption}, option.tooltip}
    if not next(dropdown_tooltip_merged) then
      dropdown_tooltip_merged = option_tooltip
    else
      dropdown_tooltip_merged = {"space-exploration.simple-a-b-break", dropdown_tooltip_merged, option_tooltip}
    end
  end

  local dropdown = active_container.add{
    type = "drop-down",
    tooltip=dropdown_tooltip_merged,
    name = EnergyBeamGUI.name_transmitter_gui_root.."_dropdown",
    items = {
      {"space-exploration.energy_transmitter_label_off"},
      {"space-exploration.energy_transmitter_label_energise"},
      {"space-exploration.energy_transmitter_label_glaive"},
      {"space-exploration.energy_transmitter_label_auto_glaive"}
    },
    selected_index = 1 -- start with off selected
  }

  beamer_gui_inner.add{ type="line", name="line"}

  beamer_gui_inner.add{ type="label", name="destination-label", caption={"space-exploration.heading-destination", ""}, style="heading_3_label" }
  beamer_gui_inner.add{type="checkbox", name="list-zones-alphabetical", caption={"space-exploration.list-destinations-alphabetically"}, state=playerdata.zones_alphabetical and true or false}
  local list, selected_index, values = EnergyBeamGUI.get_zone_dropdown_values(player, tree)
  GuiCommon.create_filter(beamer_gui_inner, player, {
    list = list,
    selected_index = selected_index,
    values = values,
    dropdown_name = "energy-transmitter-list-zones"
  })

  beamer_gui_inner.add{ type="label", name="destination-location-label", caption={"space-exploration.label_destination_position", ""}}

  local destination_location_table = beamer_gui_inner.add{type="table", name="destination_location_table", column_count=2, draw_horizontal_lines=false}
  destination_location_table.style.horizontally_stretchable = true
  destination_location_table.style.column_alignments[1] = "left" -- title, search, zone list table
  destination_location_table.style.column_alignments[2] = "right" -- starmap, close, selected zone info

  destination_location_table.add{ type="sprite-button", name="destination_location_button",
    sprite="item/"..mod_prefix.."energy-transmitter-targeter", tooltip = {"space-exploration.choose_coordinates"}}
  destination_location_table.destination_location_button.style.right_margin = 10
  destination_location_table.add{ type="label", name="destination_location_coordinates", caption=""}

  if settings.get_player_settings(player)["se-show-zone-preview"].value then
    beamer_gui_inner.add{ type="label", name="destination-location-preview-label", caption={"space-exploration.destination_preview"}}
    local preview_frame = beamer_gui_inner.add{type="frame", name="destination-location-preview-frame", style="informatron_inside_deep_frame"}
    preview_frame.style.horizontally_stretchable = true
    preview_frame.style.vertically_stretchable = true
    preview_frame.style.top_margin = 10
    preview_frame.style.minimal_height = 200
  end

  EnergyBeamGUI.gui_update(player)
end

---@param player LuaPlayer
---@param tree EnergyBeamEmitterInfo
---@param filter? string
---@return string[]
---@return uint
---@return LocationReference[]
function EnergyBeamGUI.get_zone_dropdown_values(player, tree, filter)
  local destination_zone = tree.destination and tree.destination.zone
  local playerdata = get_make_playerdata(player)
  local list, selected_index, values = Zone.dropdown_list_zone_destinations(
    player,
    tree.force_name,
    destination_zone,
    {
      alphabetical = playerdata.zones_alphabetical,
      filter = filter,
      wildcard = {list = "None", value = {type = "none"}},
      excluded_types = {"spaceship"},
    }
  )
  if selected_index == 1 then selected_index = 2 end
  selected_index = selected_index or 2
  if selected_index > #list then selected_index = 1 end
  return list, selected_index, values
end

---@param event EventData.CustomInputEvent Event data
function EnergyBeamGUI.focus_search(event)
  local root = game.get_player(event.player_index).gui.relative[EnergyBeamGUI.name_transmitter_gui_root]
  if not root then return end
  local textfield = util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  if not textfield then return end
  textfield.focus()
end
Event.addListener(mod_prefix.."focus-search", EnergyBeamGUI.focus_search)

---@param preview_frame LuaGuiElement
---@param tree EnergyBeamEmitterInfo
function EnergyBeamGUI.preview_frame_update(preview_frame, tree)
  local surface = nil
  if EnergyBeam.has_destination(tree) then
    surface = Zone.get_surface(tree.destination.zone)
  end
  preview_frame.clear()
  if surface then
    local camera
    if tree.glaive_beam and tree.glaive_beam.valid then
      camera = preview_frame.add{type="camera", name="preview_camera", position=tree.destination.coordinate, zoom=0.5, surface_index=surface.index}
      camera.entity = tree.glaive_beam
    else
      camera = preview_frame.add{type="camera", name="preview_camera", position=tree.destination.coordinate, zoom=0.5, surface_index=surface.index}
    end
    camera.style.vertically_stretchable = true
    camera.style.horizontally_stretchable = true
  end
end

---@param player LuaPlayer
function EnergyBeamGUI.gui_update(player)
  local root = player.gui.relative[EnergyBeamGUI.name_transmitter_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local tree = EnergyBeam.from_unit_number(root.tags.unit_number)
  if not tree then return EnergyBeamGUI.gui_close(player) end

  local transfer_per_tick = (tree.last_temperature or 0) / EnergyBeam.transfer_interval
  local energy_per_tick = transfer_per_tick * EnergyBeam.specific_heat

  ---@param energy number
  ---@return string
  local format_energy = function(energy)
    return string.format("%.2f",energy*60/1000000000) .. "GW"
  end

  local energy_text = Util.find_first_descendant_by_name(root, "energy")
  local efficiency_text = Util.find_first_descendant_by_name(root, "efficiency")
  local mode_dropdown = Util.find_first_descendant_by_name(root, EnergyBeamGUI.name_transmitter_gui_root.."_dropdown")
  local coordinates_text = Util.find_first_descendant_by_name(root, "destination_location_coordinates")
  local preview_frame = Util.find_first_descendant_by_name(root, "destination-location-preview-frame")

  if energy_text then
    energy_text.caption={
      "space-exploration.energy_transmitter_label_transfer",
      format_energy(energy_per_tick)
    }
  end
  if efficiency_text then
    if Zone.is_solid(tree.zone) then
      efficiency_text.caption={
        "space-exploration.energy_transmitter_label_efficiency_atmo",
        string.format("%.2f", (tree.last_efficiency or 0) * 100).."%"
      }
    else
      efficiency_text.caption={
        "space-exploration.energy_transmitter_label_efficiency",
        string.format("%.2f", (tree.last_efficiency or 0) * 100).."%"
      }
    end
  end

  local mode = tree.mode or "off"
  if mode_dropdown then
    for idx, item in pairs(EnergyBeamGUI.dropdown_idxs) do
      if mode == item then
        mode_dropdown.selected_index = idx
      end
    end
  end

  if coordinates_text then
    local coordinate = EnergyBeam.get_coordinate(tree)
    if coordinate then
      coordinates_text.caption = {"space-exploration.delivery-cannon-valid-coordinates",
        math.floor(coordinate.x), math.floor(coordinate.y)}
    else
      coordinates_text.caption = {"space-exploration.space-capsule-no-target-coordinates"}
    end
  end

  if preview_frame then
    EnergyBeamGUI.preview_frame_update(preview_frame, tree)
  end
end


---@param event EventData.on_gui_click|EventData.on_gui_selection_state_changed Event data
function EnergyBeamGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[EnergyBeamGUI.name_transmitter_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local tree = EnergyBeam.from_unit_number(root.tags.unit_number)
  if not tree then return end

  if element.name == "energy-transmitter-list-zones" then
    local value = player_get_dropdown_value(player, element.name, element.selected_index)
    if type(value) == "table" then
      if value.type == "zone" then
        local zone_index = value.index
        local zone = Zone.from_zone_index(zone_index)
        if zone then
          tree.destination.zone = zone
          tree.destination.coordinate = nil
          Log.debug("set destination to location: " .. zone.name )
        else
          tree.destination.zone = nil
        end
      else
        tree.destination.zone = nil
      end
      EnergyBeamGUI.gui_update(player)
    else
      EnergyBeamGUI.gui_close(player)
      Log.debug("Error: Non-table value ")
    end
  elseif element.name == GuiCommon.filter_clear_name then
    element.parent[GuiCommon.filter_textfield_name].text = ""
    EnergyBeamGUI.gui_update_destinations_list(root, player, tree)
  elseif element.name == "destination_location_button" then
    if RemoteView.is_unlocked(player) then
      if not player.cursor_stack then
        player.print("Error, invalid player control mode. Cannot set player.cursor_stack")
      else
        local player_zone = Zone.from_surface(player.surface)
        RemoteView.add_history_current(player) --Save history point
        -- only change the player's position to that of the energy emitter if its on a different surface
        -- this lets the player keep updating the position of the energy emitter as long as they stay in nav
        -- view on the targeted surface
        local position =
          (EnergyBeam.get_coordinate(tree) and (not player.character) and player_zone ~= tree.destination.zone)
          and EnergyBeam.get_coordinate(tree) or nil
        RemoteView.start_activity(player, {
          type = "energy-beam-emitter",
          tree = tree
        }, tree.destination and tree.destination.zone)
        player.cursor_stack.set_stack({name = EnergyBeam.name_transmitter_targeter, count = 1})
        player.opened = nil
        RemoteViewGUI.show_entity_back_button(player, tree.emitter)
      end
    else
      player.print({"space-exploration.satellite-required"})
    end
  elseif element.name == EnergyBeamGUI.name_transmitter_gui_root.."_dropdown" then
    tree.mode = EnergyBeamGUI.dropdown_idxs[element.selected_index]
    tree.destination.enemy = nil
    EnergyBeamGUI.gui_update(player)
    Log.debug(tree.mode)
  end
end
Event.addListener(defines.events.on_gui_click, EnergyBeamGUI.on_gui_click)
Event.addListener(defines.events.on_gui_selection_state_changed, EnergyBeamGUI.on_gui_click)

---@param root LuaGuiElement
---@param player LuaPlayer
---@param tree EnergyBeamEmitterInfo
function EnergyBeamGUI.gui_update_destinations_list(root, player, tree)
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end
  local list, selected_index, values = EnergyBeamGUI.get_zone_dropdown_values(player, tree, filter)
  local energy_transmitter_list_zones = Util.find_first_descendant_by_name(root, "energy-transmitter-list-zones")
  energy_transmitter_list_zones.items = list
  energy_transmitter_list_zones.selected_index = selected_index
  player_set_dropdown_values(player, "energy-transmitter-list-zones", values)
end

---@param event EventData.on_gui_checked_state_changed Event data
function EnergyBeamGUI.on_gui_checked_state_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[EnergyBeamGUI.name_transmitter_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local tree = EnergyBeam.from_unit_number(root.tags.unit_number)
  if not tree then return end

  if element.name == "list-zones-alphabetical" then
    local playerdata = get_make_playerdata(player)
    playerdata.zones_alphabetical = element.state
    EnergyBeamGUI.gui_update_destinations_list(root, player, tree)
  end
end
Event.addListener(defines.events.on_gui_checked_state_changed, EnergyBeamGUI.on_gui_checked_state_changed)

---@param event EventData.on_gui_text_changed Event data
function EnergyBeamGUI.on_gui_text_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[EnergyBeamGUI.name_transmitter_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local tree = EnergyBeam.from_unit_number(root.tags.unit_number)
  if not tree then return end

  if element.name == GuiCommon.filter_textfield_name then
    EnergyBeamGUI.gui_update_destinations_list(root, player, tree)
  end
end
Event.addListener(defines.events.on_gui_text_changed, EnergyBeamGUI.on_gui_text_changed)

RelativeGUI.register_relative_gui(
  EnergyBeamGUI.name_transmitter_gui_root,
  EnergyBeam.name_emitter,
  EnergyBeamGUI.gui_open,
  EnergyBeam.from_entity
)

return EnergyBeamGUI
