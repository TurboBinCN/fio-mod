local SpaceElevatorGUI = {}

SpaceElevatorGUI.name_space_elevator_gui_root = mod_prefix.."space-elevator"
SpaceElevatorGUI.cache_costs_strings = {}

--- get prototype list of wagon entities and their costs, then format them nicely
---@param struct SpaceElevatorStruct
---@return {parts_string: LocalisedString, energy_string: LocalisedString}
function SpaceElevatorGUI.get_format_wagon_list(struct)
  local primary = struct.primary
  local secondary = struct.secondary
  --get the prototypes
  local wagon_prototypes = prototypes.get_entity_filtered({
    {filter = "type", type = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}},
    {filter = "hidden", invert = true, mode = "and"}
  })
  --format the prototypes in a nice string
  local special_character = " " --invisible character which shows up in factorio as the same width as a number
  local energy_up_lengths = {}
  local energy_down_lengths = {}
  local parts_strings = {}
  local energy_strings = {}

  for name, _ in pairs(wagon_prototypes) do
    local inventory_size = SpaceElevator.inventory_size[name]
    local energy_up_cost = string.format("%.2f", primary.energy_per_stack * inventory_size / 1000000)
    local energy_down_cost = string.format("%.2f", secondary.energy_per_stack * inventory_size / 1000000)
    table.insert(energy_up_lengths, string.len(energy_up_cost))
    table.insert(energy_down_lengths, string.len(energy_down_cost))
    local energy_line = {
      "space-exploration.space-elevator-wagon-energy-list",
      name,
      "", --placeholder for padding to be added below
      energy_up_cost,
      "", --placeholder for padding to be added below
      energy_down_cost
    }
    local parts_line = {
      "space-exploration.space-elevator-wagon-parts-list",
      name,
      string.format("%.4f", primary.maintenance_per_stack * inventory_size),
      string.format("%.4f", secondary.maintenance_per_stack * inventory_size)
    }
    table.insert(energy_strings, energy_line)
    table.insert(parts_strings, parts_line)
  end
  local longest_up = math.max(table.unpack(energy_up_lengths))
  local longest_down = math.max(table.unpack(energy_down_lengths))
  for i, energy_line in pairs(energy_strings) do
    energy_line[3] = string.rep(special_character, longest_up - energy_up_lengths[i])
    energy_line[5] = string.rep(special_character, longest_down - energy_down_lengths[i])
  end

  local formatted_parts_string = {""}
  local formatted_energy_string = {""}
  local full_formatted_parts_string = {
    "space-exploration.space-elevator-parts-consumption-info",
    string.format("%.4f", struct.parts_per_second * 60),
    formatted_parts_string
  }
  local full_formatted_energy_string = {
    "space-exploration.space-elevator-energy-consumption-info",
    string.format("%.0f", SpaceElevator.energy_passive_draw / 1000000).."MW",
    string.format("%.0f", SpaceElevator.energy_min / 1000000).."MJ",
    formatted_energy_string
  }

  while #energy_strings > 20 do --only 20 parameters per localisation string
    local energy_string = {""} --start with generic concatenation identifier
    local parts_string = {""}
    for _ = 1, 20 do
      table.insert(energy_string, table.remove(energy_strings, 1))
      table.insert(parts_string, table.remove(parts_strings, 1))
    end
    table.insert(formatted_energy_string, energy_string)
    table.insert(formatted_parts_string, parts_string)
  end
  table.insert(energy_strings, 1, "") --insert generic concatenation identifier
  table.insert(parts_strings, 1, "")
  table.insert(formatted_energy_string, energy_strings)
  table.insert(formatted_parts_string, parts_strings)

  return {parts_string = full_formatted_parts_string, energy_string = full_formatted_energy_string}
end

---@param struct SpaceElevatorStruct
---@return {parts_string: LocalisedString, energy_string: LocalisedString}
function SpaceElevatorGUI.get_costs_strings(struct)
  local costs_strings = SpaceElevatorGUI.cache_costs_strings[struct.primary.zone.index]
  if costs_strings then
    return costs_strings
  else
    costs_strings = SpaceElevatorGUI.get_format_wagon_list(struct)
    SpaceElevatorGUI.cache_costs_strings[struct.primary.zone.index] = costs_strings
  end
  return costs_strings
end

--- Create the space elevator gui for a player
---@param player LuaPlayer
---@param elevator SpaceElevatorInfo
function SpaceElevatorGUI.gui_open(player, elevator)
  SpaceElevatorGUI.gui_close(player)
  if not elevator then Log.debug('SpaceElevatorGUI.gui_open elevator not found') return end
  local struct = elevator.elevator_struct

  local gui = player.gui.relative
  local playerdata = get_make_playerdata(player)

  local anchor = {gui=defines.relative_gui_type.assembling_machine_gui, position=defines.relative_gui_position.right}
  local container = gui.add{
    type = "frame",
    name = SpaceElevatorGUI.name_space_elevator_gui_root,
    style="space_platform_container",
    direction="vertical",
    anchor = anchor,
    -- use gui element tags to store a reference to what space elevator this gui is displaying/controls
    tags = {
      unit_number = elevator.unit_number
    }
  }
  container.style.vertically_stretchable = true

  local title_flow = container.add{type = "flow", name = "elevator-title-flow", direction = "horizontal", style = "se_relative_titlebar_flow"}
  title_flow.add{type = "label", name = "elevator-title-label", style = "frame_title", caption = {"space-exploration.relative-window-settings"}, ignored_by_interaction = true}
  local title_empty = title_flow.add {
    type = "empty-widget",
    style = "se_titlebar_drag_handle",
    ignored_by_interaction = true,
  }
  local title_informatron = title_flow.add {
    type = "sprite-button",
    name = "goto_informatron_space_elevators",
    sprite = "virtual-signal/informatron",
    style = "frame_action_button",
    tooltip = {"space-exploration.informatron-open-help"},
    tags = {se_action = "goto-informatron", informatron_page = "space_elevators"}
  }

  local inner_frame = container.add{
    type = "frame",
    name = "inner_frame",
    style = "inside_shallow_frame",
    direction = "vertical",
  }

  --[[
    Contruction/maintenance info
    Station name
    Station name edit button
    ]]
  local subheader_frame = inner_frame.add{
    type = "frame",
    name = "name-flow",
    direction = "horizontal",
    style = "se_stretchable_subheader_frame",
  }
  SpaceElevatorGUI.make_change_name_button_flow(struct, subheader_frame)

  local content_flow = inner_frame.add{
    type = "flow",
    direction = "vertical",
  }
  content_flow.style.padding = 12
  local bar, label

  local status = content_flow.add{ type="label", name="status", caption={"space-exploration.label_status", ""}}
  status.style.bottom_margin = 10

  local costs_strings = SpaceElevatorGUI.get_costs_strings(struct)

  bar = content_flow.add{ type="progressbar", name="parts_progress", size = 300, value=0, style="spaceship_progressbar_integrity"}
  bar.style.horizontally_stretchable = true
  bar.style.bar_width = 24
  bar.tooltip = costs_strings.parts_string
  local parts_flow = content_flow.add{type="flow", name="parts_flow", direction="horizontal", ignored_by_interaction = true,}
  parts_flow.style.top_margin = -26
  label = parts_flow.add{ type="label", name="parts", caption={"space-exploration.label_parts", ""}, ignored_by_interaction = true,}
  label.style.left_margin = 5
  label.style.font = "default-bold"
  label.style.font_color = {1,1,1}
  label.style.bottom_margin = 4
  local spacer = parts_flow.add{type="flow", name="parts_flow", direction="horizontal", ignored_by_interaction = true,}
  spacer.style.horizontally_stretchable = true
  label = parts_flow.add{ type="label", name="parts_per_minute", caption={"space-exploration.label_parts_per_minute", ""}, ignored_by_interaction = true,}
  label.style.right_margin = 5
  label.style.font = "default-bold"
  label.style.font_color = {1,1,1}
  label.style.bottom_margin = 4

  bar = content_flow.add{ type="progressbar", name="energy_progress", size = 300, value=0, style="spaceship_progressbar_energy"}
  bar.style.horizontally_stretchable  = true
  bar.style.bar_width = 24
  bar.tooltip = costs_strings.energy_string
  label = content_flow.add{ type="label", name="energy", caption={"space-exploration.label_energy", ""}, ignored_by_interaction = true,}
  label.style.top_margin = -26
  label.style.left_margin = 5
  label.style.font = "default-bold"
  label.style.font_color = {1,1,1}
  label.style.bottom_margin = 14

  local button_flow = content_flow.add { type="flow", name="button_flow"}
  local view_opposite_button = button_flow.add{ type="button", name="view_opposite", caption = {"space-exploration.space-elevator-view-opposite"}}
  view_opposite_button.style.horizontally_stretchable = true
  local travel_button = button_flow.add {type="button", name="travel", caption = {"space-exploration.space-elevator-travel"}}
  travel_button.style.horizontally_stretchable = true

  if settings.get_player_settings(player)["se-show-zone-preview"].value then
    --inner_frame.add{ type="label", name="destination-location-preview-label", caption={"space-exploration.destination_preview"}}
    local preview_frame = container.add{type="frame", name="destination-location-preview-frame", style="inside_shallow_frame"}
    preview_frame.style.horizontally_stretchable = true
    preview_frame.style.vertically_stretchable = true
    --[[preview_frame.style.top_margin = 10
    preview_frame.style.left_margin = -10
    preview_frame.style.bottom_margin = -10
    preview_frame.style.right_margin = -10]]
    preview_frame.style.top_margin = 12
    preview_frame.style.minimal_height = 200
    local camera = preview_frame.add{
      type="camera",
      name="preview_camera",
      position=struct.position,
      zoom=0.25,
      surface_index=elevator.opposite_elevator.surface.index,
    }
    camera.style.vertically_stretchable = true
    camera.style.horizontally_stretchable = true
  end

  SpaceElevatorGUI.gui_update(player)
end

---@param player LuaPlayer
function SpaceElevatorGUI.gui_update(player)
  local root = player.gui.relative[SpaceElevatorGUI.name_space_elevator_gui_root]
  if root and root.tags then
    local elevator = storage.space_elevators[root.tags.unit_number]
    if elevator then
      local inner_frame = root.inner_frame
      -- Update the things
      local struct = elevator.elevator_struct
      local status = util.find_first_descendant_by_name(inner_frame, "status")

      if struct.constructed then
        if elevator.main.active then
          status.caption = {"space-exploration.space-elevator-status-maintenance-ongoing"}
        else
          status.caption = {"space-exploration.space-elevator-status-maintenance-paused"}
        end
      else
        status.caption = {"space-exploration.space-elevator-status-under-construction"}
      end

      local parts_needed = struct.parts_needed
      --local str_parts = string.format("%.0f", primary.parts)
      local str_parts = struct.parts <= 0 and "0" or string.format("%.0f", struct.parts)
      local str_parts_needed = string.format("%.0f", parts_needed)

      local parts = util.find_first_descendant_by_name(inner_frame, "parts")
      parts.caption = {"space-exploration.label_parts", {"space-exploration.simple-a-b-divide",
        string.format("%.0f", str_parts),
        string.format("%.0f", str_parts_needed)}}
      local parts_costs = util.find_first_descendant_by_name(inner_frame, "parts_per_minute")
      parts_costs.caption = {"space-exploration.label_parts_per_minute",
        string.format("%.4f",struct.parts_per_second * 60)}
      local parts_progress = util.find_first_descendant_by_name(inner_frame, "parts_progress")
      parts_progress.value = struct.parts/parts_needed
      parts_progress.style.color = {
        r=1-math.max(0, math.min(1, struct.parts/parts_needed)),
        g=0.3 * math.max(0, math.min(1, struct.parts/parts_needed)),
        b=math.max(0, math.min(1, struct.parts/parts_needed))}

      local energy = util.find_first_descendant_by_name(inner_frame, "energy")
      local report_energy = struct.total_energy/1000000
        --report_energy = math.min(SpaceElevator.energy_buffer, primary.total_energy)/1000000
      energy.caption = {"space-exploration.label_energy", {"space-exploration.simple-a-b-divide",
        string.format("%.0f", report_energy).."MJ",
        string.format("%.0f", SpaceElevator.energy_buffer/1000000).."MJ"}}

      local energy_progress = util.find_first_descendant_by_name(inner_frame, "energy_progress")
      energy_progress.value = math.min(SpaceElevator.energy_buffer, struct.total_energy)/(SpaceElevator.energy_buffer)
      if struct.total_energy >= SpaceElevator.energy_buffer then
        energy_progress.style.color = {r=0, g=200/255, b=0}
      elseif struct.total_energy > SpaceElevator.energy_min then
        energy_progress.style.color = {r=1, g=0.6, b=0}
      else
        energy_progress.style.color = {r=1, g=0, b=0}
      end
    end
  end
end

---@param struct SpaceElevatorStruct
---@param subheader_frame LuaGuiElement
function SpaceElevatorGUI.make_change_name_button_flow(struct, subheader_frame)
  subheader_frame.clear()
  subheader_frame.add {
    type = "label",
    name = "show-name",
    caption = struct.name,
    style = "subheader_caption_label",
  }
  subheader_frame.add {
    type = "sprite-button",
    name = "rename",
    sprite = "utility/rename_icon",
    tooltip = {
      "space-exploration.rename-something", {"entity-name." .. SpaceElevator.name_space_elevator}
    },
    style = "mini_button_aligned_to_text_vertically_when_centered"
  }
end

---@param struct SpaceElevatorStruct
---@param subheader_frame LuaGuiElement
function SpaceElevatorGUI.make_change_name_confirm_flow(struct, subheader_frame)
  subheader_frame.clear()
  GuiCommon.create_rename_textfield(subheader_frame, struct.name)
  local rename_button = subheader_frame.add {
    type = "sprite-button",
    name = "rename-confirm",
    sprite = "utility/enter",
    tooltip = {"space-exploration.rename-confirm"},
    style = "item_and_count_select_confirm"
  }
end

---@param event EventData.on_gui_click|EventData.on_gui_confirmed Event data
function SpaceElevatorGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, SpaceElevatorGUI.name_space_elevator_gui_root)
  if not (root and root.tags) then return end
  local elevator = storage.space_elevators[root.tags.unit_number]
  if not elevator then return end

  local struct = elevator.elevator_struct
  if element.name == "rename" then
    local subheader_frame = element.parent
    SpaceElevatorGUI.make_change_name_confirm_flow(struct, subheader_frame)
  elseif element.name == "rename-confirm" or (element.name == GuiCommon.rename_textfield_name and not event.button) then -- don't confirm by clicking the textbox
    local subheader_frame = element.parent
    local new_name = string.trim(element.parent[GuiCommon.rename_textfield_name].text)
    if new_name ~= "" and new_name ~= struct.name then
      -- do change name stuff
      SpaceElevator.rename(struct, new_name)
    end
    SpaceElevatorGUI.make_change_name_button_flow(struct, subheader_frame)
  elseif element.name == "view_opposite" then
    if RemoteView.is_unlocked(player) then
      RemoteView.add_history_current(player) --Save history point
      RemoteView.start_activity(player, {
          type = "space-elevator",
          space_elevator = elevator
        }, elevator.opposite_elevator.zone, elevator.opposite_elevator.main.position)
      -- only change the player's position to that of the space elevator if its on a different surface
      -- this lets the player keep updating the position of the space elevator as long as they stay in nav
      -- view on the targeted surface
      player.teleport(struct.position)
      player.opened = nil
      RemoteViewGUI.show_entity_back_button(player, elevator.main)
    else
      player.print({"space-exploration.satellite-required"})
    end
  elseif element.name == "travel" and elevator.main and elevator.main.valid then
    local distance_x = math.abs(player.position.x - struct.position.x)
    local distance_y = math.abs(player.position.y - struct.position.y)
    local distance = math.max(distance_x, distance_y) -- box not radius
    if RemoteView.is_active(player) then
      player.print({"space-exploration.space-elevator-travel-failed-remote-view"})
    elseif distance < SpaceElevator.player_teleport_distance then
      -- player transfer costs
      local inventory_size = 10 + #player.get_main_inventory()
      local parts_cost = inventory_size * elevator.maintenance_per_stack
      local energy_change = inventory_size * elevator.energy_per_stack
      if not struct.constructed then
        return player.print({"space-exploration.space-elevator-travel-failed-built"})
      end
      if parts_cost > struct.parts then
        return player.print({"space-exploration.space-elevator-travel-failed-parts"})
      end
      if energy_change > struct.total_energy - SpaceElevator.energy_min then
        return player.print({"space-exploration.space-elevator-travel-failed-energy"})
      end
      player.teleport(player.position, elevator.opposite_elevator.surface)
      struct.parts = struct.parts - parts_cost
      struct.lua_energy = struct.lua_energy + energy_change
      elevator.opposite_elevator.surface.create_entity{
        name = SpaceElevator.name_sound_train_up,
        position = player.position
      }
    else
      player.print({"space-exploration.space-elevator-travel-failed-too-far", string.format("%.2f", distance), SpaceElevator.player_teleport_distance})
    end
  end
end
Event.addListener(defines.events.on_gui_click, SpaceElevatorGUI.on_gui_click)
Event.addListener(defines.events.on_gui_confirmed, SpaceElevatorGUI.on_gui_click)

function SpaceElevatorGUI.on_nth_tick_30()
  for _, player in pairs(game.connected_players) do
    SpaceElevatorGUI.gui_update(player)
  end
end
Event.addListener("on_nth_tick_30", SpaceElevatorGUI.on_nth_tick_30)

--- Close the space elevator gui for a player
---@param player LuaPlayer
function SpaceElevatorGUI.gui_close(player)
  if player.gui.relative[SpaceElevatorGUI.name_space_elevator_gui_root] then
    player.gui.relative[SpaceElevatorGUI.name_space_elevator_gui_root].destroy()
  end
end

--- Respond to the main entity GUI being closed by destroying the relative GUI
---@param event EventData.on_gui_closed Event data
function SpaceElevatorGUI.on_gui_closed(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if player and event.entity and event.entity.name == SpaceElevator.name_space_elevator then
    SpaceElevatorGUI.gui_close(player)
  end
end
Event.addListener(defines.events.on_gui_closed, SpaceElevatorGUI.on_gui_closed)

--- Opens the space elevator gui when a space elevator is clicked
--- Closes the space elevator gui when another gui is opened
---@param event EventData.on_gui_opened Event data
function SpaceElevatorGUI.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if event.entity and event.entity.valid and event.entity.name == SpaceElevator.name_space_elevator then
    if RemoteView.is_intersurface_unlocked(player) then
      SpaceElevatorGUI.gui_open(player, storage.space_elevators[event.entity.unit_number])
    else
      player.print({"space-exploration.remote-view-requires-satellite"})
    end
  else
    SpaceElevatorGUI.gui_close(player)
  end
end
Event.addListener(defines.events.on_gui_opened, SpaceElevatorGUI.on_gui_opened)

return SpaceElevatorGUI
