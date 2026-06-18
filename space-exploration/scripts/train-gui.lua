local TrainGUI = {}

TrainGUI.name_train_gui_root = mod_prefix.."train-gui"

TrainGUI.name_train_gui_targeter = mod_prefix.."train-gui-targeter"

TrainGUI.screen_location = {x = 452, y = 40}
TrainGUI.screen_location_remote_view = {x = TrainGUI.screen_location.x + 80, y = TrainGUI.screen_location.y}

---@param train LuaEntity
---@return {main:LuaEntity, zone?:AnyZoneType|SpaceshipType}
function TrainGUI.save_train(train)
  local struct = storage.train_gui_trains[train.unit_number] or {
    main = train,
    zone = nil
  }
  storage.train_gui_trains[train.unit_number] = struct
  return struct
end

---@param unit_number? uint|string
---@return {main:LuaEntity, zone?:AnyZoneType|SpaceshipType}?
function TrainGUI.from_unit_number(unit_number)
  if not unit_number then Log.debug("TrainGUI.from_unit_number: invalid unit_number: nil") return end
  unit_number = tonumber(unit_number)
  if storage.train_gui_trains[unit_number] then
    return storage.train_gui_trains[unit_number]
  else
    Log.debug("TrainGUI.from_unit_number: invalid unit_number: " .. unit_number)
  end
end

---@param player LuaPlayer
---@param force_name string unused
---@param destination_zone AnyZoneType
---@param filter? string
---@return string[]
function TrainGUI.get_train_stops(player, force_name, destination_zone, filter)  local list = {}
  local train_stops = {}
  if destination_zone then
    local destination_surface = Zone.get_surface(destination_zone)
    if destination_surface then
      train_stops = game.train_manager.get_train_stops{surface = destination_surface, force = player.force}
    end
  else
    train_stops = game.train_manager.get_train_stops{force = player.force}
  end
  for _, train_stop in pairs(train_stops) do
    table.insert(list, train_stop.backer_name)
  end

  table.sort(list, function(a,b) return a < b end)

  local set_filtered = {}
  for _, backer_name in pairs(list) do
    if not filter or string.find(string.lower(backer_name), string.lower(filter), 1, true) then
      set_filtered[backer_name] = true
    end
  end
  local stop_list = {}
  for station, _ in pairs(set_filtered) do
    table.insert(stop_list, station)
  end
  return stop_list
end

--- Create the train gui for a player
---@param player LuaPlayer
---@param train LuaEntity
function TrainGUI.gui_open(player, train)
  TrainGUI.gui_close(player)
  local struct = TrainGUI.save_train(train)

  local gui = player.gui.screen
  local playerdata = get_make_playerdata(player)

  local container = gui.add{
    type = "frame",
    name = TrainGUI.name_train_gui_root,
    style="space_platform_container",
    direction="vertical",
    -- use gui element tags to store a reference to what train this gui is displaying/controls
    tags = {
      unit_number = train.unit_number
    }
  }
  container.style.vertically_stretchable = true

  storage.train_gui_opened[player.index] = true

  local title_flow = container.add{type = "flow", "train-title-flow", direction = "horizontal"}
  title_flow.add{type = "label", name = "train-title-label", style = "frame_title", caption = {"space-exploration.relative-window-station-picker"}, ignored_by_interaction = true}
  local title_empty = title_flow.add {
    type = "empty-widget",
    style = "draggable_space",
    ignored_by_interaction = true
  }
  title_flow.drag_target = container
  title_empty.style.horizontally_stretchable = true
  title_empty.style.left_margin = 4
  title_empty.style.right_margin = 0
  title_empty.style.height = 24

  local inner_frame = container.add{
    type = "frame",
    name = "inner_frame",
    style="b_inner_frame",
    direction="vertical",
  }

  inner_frame.add{ type="label", name="destination-label", caption={"space-exploration.label_destination", ""}}
  inner_frame.add{type="checkbox", name="list-zones-alphabetical", caption={"space-exploration.list-destinations-alphabetically"}, state=playerdata.zones_alphabetical and true or false}

  local filter_container = inner_frame.add{ type="flow", name="filter_flow", direction="horizontal"}
  local filter_field = filter_container.add{ type="textfield", name="filter_list"}
  filter_field.style.width = 275
  local filter_button = filter_container.add{ type = "sprite-button", name="clear_filter", sprite="se-search-close-white", hovered_sprite="se-search-close-black", clicked_sprite="se-search-close-black", tooltip={"space-exploration.clear-filter"},}
  filter_button.style.left_margin = 5
  filter_button.style.width = 28
  filter_button.style.height = 28

  local destination_zone = struct.zone
  local list, selected_index, values = Zone.dropdown_list_zone_destinations(player, player.force.name, destination_zone,
    {
      alphabetical = playerdata.zones_alphabetical,
      wildcard = {list = {"space-exploration.all_location"}, value={type = "any"}},
      only_with_train_stops = true
    }
  )
  if selected_index == 1 then selected_index = 2 end
  local zones_dropdown = inner_frame.add{ type="drop-down", name="train-gui-list-zones", items=list, selected_index=selected_index or 1}
  zones_dropdown.style.horizontally_stretchable  = true
  player_set_dropdown_values(player, "train-gui-list-zones", values)

  inner_frame.add{ type="label", name="stop-label", caption={"space-exploration.label_station", ""}}
  local filter_container2 = inner_frame.add{ type="flow", name="filter_flow2", direction="horizontal"}
  local filter_field2 = filter_container2.add{ type="textfield", name="filter_list2"}
  filter_field2.style.width = 275
  local filter_button2 = filter_container2.add{ type = "sprite-button", name="clear_filter2", sprite="se-search-close-white", hovered_sprite="se-search-close-black", clicked_sprite="se-search-close-black", tooltip={"space-exploration.clear-filter"},}
  filter_button2.style.left_margin = 5
  filter_button2.style.width = 28
  filter_button2.style.height = 28
  filter_button2.style.bottom_margin = 5

  local stop_list = TrainGUI.get_train_stops(player, player.force.name, destination_zone, nil)
  local list_box = inner_frame.add{
    type = "list-box",
    name = "list_box"
  }
  list_box.style.vertically_stretchable = true
  list_box.items = stop_list
  inner_frame.add{ type="sprite-button", name="stop_picker_button",
  sprite="item/train-stop", tooltip = {"space-exploration.choose_station"}}

  local scale = player.display_scale
  local screen_location = RemoteView.is_active(player) and TrainGUI.screen_location_remote_view or TrainGUI.screen_location
  container.location = util.vector_multiply(screen_location, scale)
end

---@param event EventData.CustomInputEvent Event data
function TrainGUI.focus_search(event)
  local root = game.get_player(event.player_index).gui.screen[TrainGUI.name_train_gui_root]
  if not root then return end
  local textfield = util.find_first_descendant_by_name(root, "filter_list")
  textfield.focus()
end
Event.addListener(mod_prefix.."focus-search", TrainGUI.focus_search)


---@param event EventData.on_gui_click|EventData.on_gui_selection_state_changed Event data
function TrainGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, TrainGUI.name_train_gui_root)
  if not root then return end
  local struct = TrainGUI.from_unit_number(root and root.tags and root.tags.unit_number)
  if not (struct and struct.main.valid) then return end

  if element.name == "train-gui-list-zones" then
    local value = player_get_dropdown_value(player, element.name, element.selected_index)
    if type(value) == "table" then
      if value.type == "zone" then
        local zone_index = value.index
        local zone = Zone.from_zone_index(zone_index)
        if zone then
          struct.zone = zone
          Log.debug("set destination to location: " .. zone.name )
        end
      elseif value.type == "spaceship" then
        local spaceship_index = value.index
        local spaceship = Spaceship.from_index(spaceship_index)
        if spaceship then
          struct.zone = spaceship
          Log.debug("set destination to spaceship : " .. spaceship.name )
        end
      elseif value.type == "any" then
        struct.zone = nil
        Log.debug("set destination to location: any")
      end
      TrainGUI.gui_update_destinations_and_stops_list(player)
    else
      TrainGUI.gui_close(player)
      Log.debug("Error: Non-table value ")
    end
  elseif element.name == "clear_filter" then
    element.parent.filter_list.text = ""
    TrainGUI.gui_update_destinations_and_stops_list(player)
  elseif element.name == "clear_filter2" then
    element.parent.filter_list2.text = ""
    TrainGUI.gui_update_destinations_and_stops_list(player)
  elseif element.name == "stop_picker_button" then
    local playerdata = get_make_playerdata(player)
    RemoteView.add_history_current(player) --Save history point
    RemoteView.start_activity(player, {
      type = "train-gui",
      train = struct,
    }, struct.zone)
    player.cursor_stack.set_stack({name = TrainGUI.name_train_gui_targeter, count = 1})
    player.opened = nil
    RemoteViewGUI.show_entity_back_button(player, struct.main)
  end
end
Event.addListener(defines.events.on_gui_click, TrainGUI.on_gui_click)
Event.addListener(defines.events.on_gui_selection_state_changed, TrainGUI.on_gui_click)

---@param player LuaPlayer
function TrainGUI.gui_update_destinations_and_stops_list(player)
  local playerdata = get_make_playerdata(player)
  local root = player.gui.screen[TrainGUI.name_train_gui_root]
  if root then
    local struct = TrainGUI.from_unit_number(root and root.tags and root.tags.unit_number)
    if not struct then return end

    local textfield = util.find_first_descendant_by_name(root, "filter_list")
    local filter = nil
    if textfield then
      filter = string.trim(textfield.text)
      if filter == "" then
        filter = nil
      end
    end

    -- update the list
    local destination_zone = struct.zone
    local list, selected_index, values = Zone.dropdown_list_zone_destinations(player, player.force.name, destination_zone,
      {
        alphabetical = playerdata.zones_alphabetical,
        filter = filter,
        wildcard = {list = {"space-exploration.all_location"}, value={type = "any"}},
        only_with_train_stops = true
      }
    )
    if selected_index == 1 then selected_index = 2 end
    local dropdown = util.find_first_descendant_by_name(root, "train-gui-list-zones")
    dropdown.items = list
    dropdown.selected_index = selected_index or 1
    player_set_dropdown_values(player, "train-gui-list-zones", values)

    local textfield2 = util.find_first_descendant_by_name(root, "filter_list2")
    local filter2 = nil
    if textfield2 then
      filter2 = string.trim(textfield2.text)
      if filter2 == "" then
        filter2 = nil
      end
    end

    local stop_list = TrainGUI.get_train_stops(player, player.force.name, destination_zone, filter2)
    local list_box = util.find_first_descendant_by_name(root, "list_box")
    list_box.items = stop_list
  end
end

---@param event EventData.on_gui_checked_state_changed Event data
function TrainGUI.on_gui_checked_state_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, TrainGUI.name_train_gui_root)
  if not root then return end
  local struct = TrainGUI.from_unit_number(root and root.tags and root.tags.unit_number)
  if not struct then return end
  if element.name == "list-zones-alphabetical" then
    local playerdata = get_make_playerdata(player)
    playerdata.zones_alphabetical = element.state
    TrainGUI.gui_update_destinations_and_stops_list(player)
  end
end
Event.addListener(defines.events.on_gui_checked_state_changed, TrainGUI.on_gui_checked_state_changed)

---@param event EventData.on_gui_selection_state_changed Event data
function TrainGUI.on_gui_selection_state_changed(event)
  local element = event.element
  if not (element and element.valid and element.name == "list_box") then return end
  local root = gui_element_or_parent(element, TrainGUI.name_train_gui_root)
  if not root then return end
  local struct = TrainGUI.from_unit_number(root and root.tags and root.tags.unit_number)
  if not struct then return end

  if struct.main and struct.main.valid and struct.main.train and struct.main.train.valid then
    local schedule = struct.main.train.schedule
    if schedule then
      table.insert(schedule.records, {station=element.items[element.selected_index]})
      struct.main.train.schedule = schedule
    else
      struct.main.train.schedule = {
        current = 1,
        records = {{station=element.items[element.selected_index]}}
      }
    end
    element.selected_index = 0 -- Deselect immediately
  end
end
Event.addListener(defines.events.on_gui_selection_state_changed, TrainGUI.on_gui_selection_state_changed)

---@param event EventData.on_gui_text_changed Event data
function TrainGUI.on_gui_text_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, TrainGUI.name_train_gui_root)
  if root then -- remote view
    if element.name == "filter_list" or element.name == "filter_list2" then
      TrainGUI.gui_update_destinations_and_stops_list(player)
    end
  end
end
Event.addListener(defines.events.on_gui_text_changed, TrainGUI.on_gui_text_changed)

---Handles the player setting a station target using the targetting selection tool.
---@param event EventData.CustomInputEvent Event data
function TrainGUI.on_targeter(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if not player then return end
  local cursor_item = player.cursor_stack
  if not (cursor_item and cursor_item.valid_for_read) then return end
  if cursor_item.name ~= TrainGUI.name_train_gui_targeter then return end
  local remote_view_activity = RemoteView.get_activity(player, "train-gui")
  if not remote_view_activity then return end
  local struct = remote_view_activity.train
  local destination_zone = Zone.from_surface(player.surface)
  if not (struct and struct.main and struct.main.valid and destination_zone) then return player.cursor_stack.clear() end
  local coordinates = event.cursor_position
  local stops = player.surface.find_entities_filtered{
    position = coordinates,
    radius = 10,
    type = "train-stop",
  }
  local found_stop = false
  local min_dist = math.huge
  local min_dist_stop
  for _, stop in pairs(stops) do
    local euclidean_squared_distance = ((stop.position.x - coordinates.x)^2 + (stop.position.y - coordinates.y)^2)
    if euclidean_squared_distance < min_dist then
      min_dist = euclidean_squared_distance
      min_dist_stop = stop
    end
    found_stop = true
  end
  if found_stop then
    local schedule = struct.main.train.schedule
    if schedule then
      table.insert(schedule.records, {station=min_dist_stop.backer_name})
      struct.main.train.schedule = schedule
    else
      struct.main.train.schedule = {
        current = 1,
        records = {{station=min_dist_stop.backer_name}}
      }
    end
  end
  if not found_stop then
    local elevators = player.surface.find_entities_filtered{
      position = coordinates,
      radius = 20,
      name = mod_prefix.."space-elevator",
      limit = 1
    }
    for _, elevator in pairs(elevators) do
      local ev_struct = storage.space_elevators[elevator.unit_number]
      if ev_struct and ev_struct.station and ev_struct.station.valid then
        local schedule = struct.main.train.schedule
        if schedule then
          table.insert(schedule.records, {station=ev_struct.station.backer_name})
          struct.main.train.schedule = schedule
        else
          struct.main.train.schedule = {
            current = 1,
            records = {{station=ev_struct.station.backer_name}}
          }
        end
        found_stop = true
      end
    end
  end
  local train_zone = Zone.from_surface(struct.main.surface)
  if train_zone then
    RemoteView.start(player, train_zone, struct.main.position)
    player.opened = struct.main
  end
end
Event.addListener(mod_prefix .. "-targeter", TrainGUI.on_targeter)

--- Close the train gui for a player
---@param player LuaPlayer
function TrainGUI.gui_close(player)
  if player.gui.screen[TrainGUI.name_train_gui_root] then
    player.gui.screen[TrainGUI.name_train_gui_root].destroy()
  end
  storage.train_gui_opened[player.index] = nil
end

--- Opens the train gui when a train is clicked
--- Closes the train gui when another gui is opened
---@param event EventData.on_gui_opened Event data
function TrainGUI.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if event.gui_type == defines.gui_type.entity then
    local entity = event.entity
    if entity and entity.valid and entity.type == "locomotive" then
      local techs = player.force.technologies
      if is_player_force(player.force.name) and RemoteView.is_unlocked(player) and (techs[mod_prefix.."space-elevator"].researched or techs[mod_prefix.."spaceship"].researched) then
        if not settings.get_player_settings(player)["se-never-show-train-gui"].value then
          TrainGUI.gui_open(player, event.entity)
          return
        end
      end
    end
  end
end
Event.addListener(defines.events.on_gui_opened, TrainGUI.on_gui_opened)

function TrainGUI.on_tick()
  --need to check for open guis on_tick as destroyed entities do not trigger on_gui_closed events
  for player_index in pairs(storage.train_gui_opened) do
    local player = game.get_player(player_index)
    if not player then
      storage.train_gui_opened[player_index] = nil
      return
    end
    if (not player.opened) or (player.opened_gui_type ~= defines.gui_type.entity) or (player.opened.type ~= "locomotive") then
      TrainGUI.gui_close(player)
    end
  end
end
Event.addListener(defines.events.on_tick, TrainGUI.on_tick)

function TrainGUI.on_init()
  storage.train_gui_trains = {}
  storage.train_gui_opened = {}
end
Event.addListener("on_init", TrainGUI.on_init, true)

return TrainGUI
