local DeliveryCannonGUI = {}

DeliveryCannonGUI.name_delivery_cannon_gui_root = mod_prefix.."delivery-cannon"
DeliveryCannonGUI.dropdown_options = {
  ["logistic"] = {
    {caption={"space-exploration.delivery_cannon_label_off"},tooltip={"space-exploration.delivery_cannon_tooltip_off"}},
    {caption={"space-exploration.delivery_cannon_label_single_target"},tooltip={"space-exploration.delivery_cannon_tooltip_single_target"}}
  },
  ["weapon"] = {
    {caption={"space-exploration.delivery_cannon_label_off"},tooltip={"space-exploration.delivery_cannon_tooltip_off"}},
    {caption={"space-exploration.delivery_cannon_label_single_target"},tooltip={"space-exploration.delivery_cannon_tooltip_single_target"}},
    {caption={"space-exploration.delivery_cannon_label_automatic_retarget"},tooltip={"space-exploration.delivery_cannon_tooltip_automatic_retarget"}},
    {caption={"space-exploration.delivery_cannon_label_artillery"},tooltip={"space-exploration.delivery_cannon_tooltip_artillery"}}
  }
}
DeliveryCannonGUI.dropdown_idxs = {
  ["logistic"] = {
    DeliveryCannon.mode_off,
    DeliveryCannon.mode_single_target
  },
  ["weapon"] = {
    DeliveryCannon.mode_off,
    DeliveryCannon.mode_single_target,
    DeliveryCannon.mode_automatic_retarget,
    DeliveryCannon.mode_artillery
  }
}

---@param player LuaPlayer
function DeliveryCannonGUI.gui_close(player)
  RelativeGUI.gui_close(player, DeliveryCannonGUI.name_delivery_cannon_gui_root)
end

--- Create the delivery cannon gui for a player
---@param player LuaPlayer
---@param delivery_cannon DeliveryCannonInfo
function DeliveryCannonGUI.gui_open(player, delivery_cannon)
  DeliveryCannonGUI.gui_close(player)
  if not delivery_cannon then Log.debug('DeliveryCannonGUI.gui_open delivery_cannon not found') return end

  local gui = player.gui.relative
  local playerdata = get_make_playerdata(player)

  local anchor = {gui=defines.relative_gui_type.assembling_machine_gui, position=defines.relative_gui_position.right}
  local container = gui.add{
    type = "frame",
    name = DeliveryCannonGUI.name_delivery_cannon_gui_root,
    style="space_platform_container",
    direction="vertical",
    anchor = anchor,
    -- use gui element tags to store a reference to what delivery cannon this gui is displaying/controls
    tags = {
      unit_number = delivery_cannon.unit_number
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
    tags={se_action="goto-informatron", informatron_page="delivery_cannons"}
  }

  local cannon_gui_inner = container.add{ type="frame", name="cannon_gui_inner", direction="vertical", style="b_inner_frame"}
  cannon_gui_inner.style.padding = 10

  cannon_gui_inner.add{ type="progressbar", name="energy_progress", size = 300, value=0, caption="Energy: ", style="space_platform_progressbar_capsule"}

  cannon_gui_inner.add{ type="label", name="payload", caption="Payload: "}

  local active_container = cannon_gui_inner.add{ type="flow", name="active_container", direction="horizontal"}
  active_container.style.vertical_align = "center"

  local dropdown_tooltip_merged = {}
  local dropdown_items = {}
  for _, option in pairs(DeliveryCannonGUI.dropdown_options[delivery_cannon.variant]) do
    local option_tooltip = {"space-exploration.simple-a-b-colon", {"space-exploration.simple-bold", option.caption}, option.tooltip}
    if not next(dropdown_tooltip_merged) then
      dropdown_tooltip_merged = option_tooltip
    else
      dropdown_tooltip_merged = {"space-exploration.simple-a-b-break", dropdown_tooltip_merged, option_tooltip}
    end
    table.insert(dropdown_items, option.caption)
  end

  local dropdown = active_container.add{
    type = "drop-down",
    tooltip=dropdown_tooltip_merged,
    name = DeliveryCannonGUI.name_delivery_cannon_gui_root.."_dropdown",
    items = dropdown_items,
    selected_index = 1 -- start with off selected
  }

  cannon_gui_inner.add{ type="line", name="line"}

  cannon_gui_inner.add{ type="label", name="destination-label", caption={"space-exploration.heading-destination", ""}, style="heading_3_label" }
  cannon_gui_inner.add{type="checkbox", name="list-zones-alphabetical", caption={"space-exploration.list-destinations-alphabetically"}, state=playerdata.zones_alphabetical and true or false}
  local list, selected_index, values = DeliveryCannonGUI.get_zone_dropdown_values(player, delivery_cannon)
  GuiCommon.create_filter(cannon_gui_inner, player,  {
    list = list,
    selected_index = selected_index,
    values = values,
    dropdown_name =  "delivery-cannon-list-zones",
  })

  cannon_gui_inner.add{ type="label", name="destination-location-label", caption={"space-exploration.label_destination_position", ""}}

  local destination_location_table = cannon_gui_inner.add{type="table", name="destination_location_table", column_count=3, draw_horizontal_lines=false}
  destination_location_table.style.horizontally_stretchable = true
  destination_location_table.style.column_alignments[1] = "left" -- title, search, zone list table
  destination_location_table.style.column_alignments[2] = "right" -- starmap, close, selected zone info

  destination_location_table.add{ type="sprite-button", name="destination_location_button",
    sprite="item/"..mod_prefix.."delivery-cannon-targeter", tooltip = {"space-exploration.choose_coordinates"}}
  destination_location_table.destination_location_button.style.right_margin = 10
  destination_location_table.add{ type="label", name="destination_location_coordinates", caption=""}

  if settings.get_player_settings(player)["se-show-zone-preview"].value then
    cannon_gui_inner.add{ type="label", name="destination-location-preview-label", caption={"space-exploration.destination_preview"}}
    local preview_frame = cannon_gui_inner.add{type="frame", name="destination-location-preview-frame", style="informatron_inside_deep_frame"}
    preview_frame.style.horizontally_stretchable = true
    preview_frame.style.vertically_stretchable = true
    preview_frame.style.top_margin = 10
    preview_frame.style.minimal_height = 200
  end
  DeliveryCannonGUI.gui_update(player)
end

---@param player LuaPlayer
---@param delivery_cannon DeliveryCannonInfo
---@param filter? string
---@return string[]
---@return uint
---@return LocationReference[]
function DeliveryCannonGUI.get_zone_dropdown_values(player, delivery_cannon, filter)
  local destination_zone = delivery_cannon.destination and delivery_cannon.destination.zone
  local playerdata = get_make_playerdata(player)
  local list, selected_index, values
  if delivery_cannon.zone.type == "anomaly" or (delivery_cannon.zone.space_distortion and delivery_cannon.zone.space_distortion > 0) then -- only target none or self
    list = {{"space-exploration.none"},  Zone.dropdown_name_from_zone(delivery_cannon.zone)}
    values = { {type = "none"}, {type = (delivery_cannon.zone.type == "spaceship") and "spaceship" or "zone", index = delivery_cannon.zone.index}}
    selected_index = destination_zone and 2 or 1
  else
    local star = Zone.get_star_from_child(delivery_cannon.zone) or Zone.find_nearest_star(delivery_cannon.zone.stellar_position)
    list, selected_index, values = Zone.dropdown_list_zone_destinations(
      player,
      delivery_cannon.force_name,
      destination_zone,
      {
        alphabetical = playerdata.zones_alphabetical,
        filter = filter,
        wildcard = {list = {"space-exploration.none"}, value = {type = "none"}},
        star_restriction = star,
        excluded_types = {"spaceship"},
      }
    )
    if selected_index == 1 then selected_index = 2 end
    selected_index = selected_index or 2
    if selected_index > #list then selected_index = 1 end
  end
  return list, selected_index, values
end

---@param event EventData.CustomInputEvent Event data
function DeliveryCannonGUI.focus_search(event)
  local root = game.get_player(event.player_index).gui.relative[DeliveryCannonGUI.name_delivery_cannon_gui_root]
  if not root then return end
  local textfield = util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  if not textfield then return end
  textfield.focus()
end
Event.addListener(mod_prefix.."focus-search", DeliveryCannonGUI.focus_search)

---@param preview_frame LuaGuiElement
---@param delivery_cannon DeliveryCannonInfo
function DeliveryCannonGUI.preview_frame_update(preview_frame, delivery_cannon)
  local surface = nil
  if DeliveryCannon.has_destination(delivery_cannon) then
    surface = Zone.get_surface(delivery_cannon.destination.zone)
  end
  preview_frame.clear()
  if surface then
    local camera = preview_frame.add{type="camera", name="preview_camera", position=delivery_cannon.destination.coordinate, zoom=0.5, surface_index=surface.index}
    camera.style.vertically_stretchable = true
    camera.style.horizontally_stretchable = true
  end
end

---@param player LuaPlayer
---@return string?
function DeliveryCannonGUI.gui_update(player)
  local root = player.gui.relative[DeliveryCannonGUI.name_delivery_cannon_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local delivery_cannon = DeliveryCannon.from_unit_number(root.tags.unit_number)
  if not delivery_cannon then return DeliveryCannonGUI.gui_close(player) end

  if not DeliveryCannon.is_valid(delivery_cannon) then return DeliveryCannonGUI.gui_close(player) end

  ---@param energy number
  ---@return string
  local format_energy = function(energy)
    return string.format("%.2f",energy/1000000) .. "MJ"
  end

  local energy_bar = Util.find_first_descendant_by_name(root, "energy_progress")
  local payload_text = Util.find_first_descendant_by_name(root, "payload")
  local mode_dropdown = Util.find_first_descendant_by_name(root, DeliveryCannonGUI.name_delivery_cannon_gui_root.."_dropdown")
  local coordinates_text = Util.find_first_descendant_by_name(root, "destination_location_coordinates")
  local preview_frame = Util.find_first_descendant_by_name(root, "destination-location-preview-frame")

  if energy_bar then
    energy_bar.caption={
      "space-exploration.delivery_cannon_label_energy",
      format_energy(delivery_cannon.energy_interface.energy) .. " / " .. (delivery_cannon.required_energy and format_energy(delivery_cannon.required_energy) or "?")
    }
    energy_bar.value = delivery_cannon.required_energy and ((delivery_cannon.energy_interface.energy or 0) / delivery_cannon.required_energy) or 0
  end
  if payload_text then
    payload_text.caption={
      "space-exploration.delivery_cannon_label_payload",
      delivery_cannon.payload_name and (prototypes.item[delivery_cannon.payload_name].localised_name) or {"space-exploration.empty"}
    }
  end

  local mode = delivery_cannon.mode or DeliveryCannon.mode_off
  if mode_dropdown then
    for idx, item in pairs(DeliveryCannonGUI.dropdown_idxs[delivery_cannon.variant]) do
      if mode == item then
        mode_dropdown.selected_index = idx
      end
    end
  end

  if coordinates_text then
    local coordinate = DeliveryCannon.get_coordinate(delivery_cannon)
    if coordinate then
      coordinates_text.caption = {"space-exploration.delivery-cannon-valid-coordinates",
        math.floor(coordinate.x), math.floor(coordinate.y)}
    else
      coordinates_text.caption = {"space-exploration.space-capsule-no-target-coordinates"}
    end
  end

  if preview_frame then
    DeliveryCannonGUI.preview_frame_update(preview_frame, delivery_cannon)
  end
end

---@param root LuaGuiElement
---@param player LuaPlayer
---@param delivery_cannon DeliveryCannonInfo
function DeliveryCannonGUI.gui_update_destinations_list(root, player, delivery_cannon)
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end
  local list, selected_index, values = DeliveryCannonGUI.get_zone_dropdown_values(player, delivery_cannon, filter)
  local delivery_cannon_list_zones = Util.find_first_descendant_by_name(root, "delivery-cannon-list-zones")
  delivery_cannon_list_zones.items = list
  delivery_cannon_list_zones.selected_index = selected_index
  player_set_dropdown_values(player, "delivery-cannon-list-zones", values)
end

---@param event EventData.on_gui_click|EventData.on_gui_selection_state_changed Event data
function DeliveryCannonGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[DeliveryCannonGUI.name_delivery_cannon_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local delivery_cannon = DeliveryCannon.from_unit_number(root.tags.unit_number)
  if not delivery_cannon then return end

  if element.name == "delivery-cannon-list-zones" then
    local value = player_get_dropdown_value(player, element.name, element.selected_index)
    if type(value) == "table" then
      if value.type == "zone" then
        local zone = Zone.from_zone_index(value.index)
        local is_successful

        -- Attempt to set new destination zone if different from existing one
        if not delivery_cannon.destination or zone ~= delivery_cannon.destination.zone then
          is_successful = DeliveryCannon.set_target(delivery_cannon, player, zone)
        end

        -- If setting target was attempted and failed, revalidate existing destination if set
        if is_successful == false then
          -- Set target to nil if existing target is also not reachable
          if delivery_cannon.destination.zone and
            not DeliveryCannon.is_reachable_destination(delivery_cannon, delivery_cannon.destination.zone) then
            DeliveryCannon.set_target(delivery_cannon, player, nil)
          end

          -- Refresh the destinations list as unreachable destinations shouln't be selectable
          DeliveryCannonGUI.gui_update_destinations_list(root, player, delivery_cannon)
        end
      else
        DeliveryCannon.set_target(delivery_cannon, nil)
      end
      DeliveryCannonGUI.gui_update(player)
    else
      DeliveryCannonGUI.gui_close(player)
      Log.debug("Error: Non-table value ")
    end
  elseif element.name == GuiCommon.filter_clear_name then
    element.parent[GuiCommon.filter_textfield_name].text = ""
    DeliveryCannonGUI.gui_update_destinations_list(root, player, delivery_cannon)
  elseif element.name == "destination_location_button" then
    local player_zone = Zone.from_surface(player.surface)
    RemoteView.add_history_current(player) --Save history point
    -- only change the player's position to that of the delivery cannon if its on a different surface
    -- this lets the player keep updating the position of the delivery cannon as long as they stay in nav
    -- view on the targeted surface
    local position =
      (delivery_cannon.destination.coordinate and (not player.character) and player_zone ~= delivery_cannon.destination.zone)
      and DeliveryCannon.get_coordinate(delivery_cannon) or nil
    RemoteView.start_activity(player, {
      type = "delivery-cannon",
      delivery_cannon = delivery_cannon,
    }, delivery_cannon.destination.zone, position)
    player.cursor_stack.set_stack({name = DeliveryCannon.name_delivery_cannon_targeter, count = 1})
    player.opened = nil
    RemoteViewGUI.show_entity_back_button(player, delivery_cannon.main)
  elseif element.name == "goto_informatron_delivery_cannons" then
    remote.call("informatron", "informatron_open_to_page", {
      player_index = event.player_index,
      interface = "space-exploration",
      page_name = "delivery_cannons"
    })
  elseif element.name == DeliveryCannonGUI.name_delivery_cannon_gui_root.."_dropdown" then
    delivery_cannon.mode = DeliveryCannonGUI.dropdown_idxs[delivery_cannon.variant][element.selected_index]
    DeliveryCannonGUI.gui_update(player)
    Log.debug(delivery_cannon.mode)
  end
end
Event.addListener(defines.events.on_gui_click, DeliveryCannonGUI.on_gui_click)
Event.addListener(defines.events.on_gui_selection_state_changed, DeliveryCannonGUI.on_gui_click)

---@param event EventData.on_gui_checked_state_changed Event data
function DeliveryCannonGUI.on_gui_checked_state_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[DeliveryCannonGUI.name_delivery_cannon_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local delivery_cannon = DeliveryCannon.from_unit_number(root.tags.unit_number)
  if not delivery_cannon then return end

  if element.name == "list-zones-alphabetical" then
    local playerdata = get_make_playerdata(player)
    playerdata.zones_alphabetical = element.state
    DeliveryCannonGUI.gui_update_destinations_list(root, player, delivery_cannon)
  end
end
Event.addListener(defines.events.on_gui_checked_state_changed, DeliveryCannonGUI.on_gui_checked_state_changed)

---@param event EventData.on_gui_text_changed Event data
function DeliveryCannonGUI.on_gui_text_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = player.gui.relative[DeliveryCannonGUI.name_delivery_cannon_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end
  local delivery_cannon = DeliveryCannon.from_unit_number(root.tags.unit_number)
  if not delivery_cannon then return end

  if element.name == GuiCommon.filter_textfield_name then
    DeliveryCannonGUI.gui_update_destinations_list(root, player, delivery_cannon)
  end
end
Event.addListener(defines.events.on_gui_text_changed, DeliveryCannonGUI.on_gui_text_changed)

---@param player LuaPlayer
---@param delivery_cannon DeliveryCannonInfo
function DeliveryCannonGUI.pre_gui_open(player, delivery_cannon)
  if RemoteView.is_unlocked(player) then
    DeliveryCannonGUI.gui_open(player, delivery_cannon)
  else
    player.print({"space-exploration.remote-view-requires-satellite"})
  end
end

RelativeGUI.register_relative_gui(
  DeliveryCannonGUI.name_delivery_cannon_gui_root,
  DeliveryCannon.variants["logistic"].name,
  DeliveryCannonGUI.pre_gui_open,
  DeliveryCannon.from_entity
)
RelativeGUI.register_relative_gui(
  DeliveryCannonGUI.name_delivery_cannon_gui_root,
  DeliveryCannon.variants["weapon"].name,
  DeliveryCannonGUI.pre_gui_open,
  DeliveryCannon.from_entity
)

return DeliveryCannonGUI
