--[[
  This file contains all code regarding the custom spaceship scheduler's GUI.
  The initial styling template for the records/conditions was created by _CodeGreen.
  This main scheduler GUI will be operated dynamically. Meaning when it refreshes
  only the required elements are updated, instead of destroying/rebuilding the
  entire thing. This is so that you can easily still interact with the elements
  even while it's being refreshed.
]]

local SpaceshipSchedulerGUI = { }

SpaceshipSchedulerGUI.gui_main_root_name = mod_prefix.."spaceship-scheduler"
SpaceshipSchedulerGUI.gui_destination_popup_root_name = mod_prefix.."spaceship-scheduler-add-destination-popup"
SpaceshipSchedulerGUI.gui_interrupt_popup_root_name = mod_prefix.."spaceship-scheduler-interrupt-popup"
SpaceshipSchedulerGUI.gui_backdrop_root_name = mod_prefix.."spaceship-scheduler-backdrop"
SpaceshipSchedulerGUI.gui_handler_name = SpaceshipSchedulerGUI.gui_main_root_name

local main_gui_width = 450
local default_wait_condition_time = 30 * 60

------------------------------------------------
-- UTILITY
------------------------------------------------

---@param container LuaGuiElement
---@param name string
---@param tags table?
local function create_movement_buttons(container, name, tags)
  local flow = container.add{type = "flow", direction = "vertical"}
  flow.style.vertical_spacing = 0
  local negative_margin = -10 -- So that the arrow sprite is not super tiny
  local button = flow.add{type = "sprite-button",
    name = name .. "-move-up",
    sprite = "se-arrow-up-white-small",
    hovered_sprite = "se-arrow-up-white-small",
    clicked_sprite = "se-arrow-up-white-small",
    style = "control_settings_section_button",
    tags=tags,
  }
  button.style.height = 14
  button.style.top_padding = negative_margin
  button.style.bottom_padding = negative_margin
  button = flow.add{type = "sprite-button",
    name = name .. "-move-down",
    sprite = "se-arrow-down-white-small",
    hovered_sprite = "se-arrow-down-white-small",
    clicked_sprite = "se-arrow-down-white-small",
    style = "control_settings_section_button",
    tags=tags,
  }
  button.style.height = 14
  button.style.top_padding = negative_margin
  button.style.bottom_padding = negative_margin
end

local comparator_items = {">", "<", "=", "≥", "≤", "≠"}
---@param conditions_container LuaGuiElement
---@param wait_condition WaitCondition
---@param tags table to add to all interactible elements
local function create_condition_element(conditions_container, wait_condition, tags)
  local and_or_frame = conditions_container.and_or.add{type = "frame", style = "se_spacehip_scheduler_comparison_type_frame"}
  local condition_index = and_or_frame.get_index_in_parent()
  and_or_frame.visible = condition_index ~= 1
  and_or_frame.style.top_margin = 0
  and_or_frame.style.bottom_margin = 0
  if wait_condition.compare_type == "and" then
    and_or_frame.style.left_margin = 24
  end

  and_or_frame.add{
    type = "button", name = "and-or-button", tags = tags,
    style = "train_schedule_comparison_type_button", caption = {"gui-train-wait-condition-description." .. wait_condition.compare_type},
  }

  local condition_frame = conditions_container.conditions.list.add{type = "frame", style = "train_schedule_condition_frame"}
  condition_frame.style.bottom_margin = 4
  condition_frame.style.width = main_gui_width - 112

  -- This is where the cursed stuff happens in order to have a progress bar for each condition
  local progress = condition_frame.add{type = "progressbar", name = "progress", style = "se_spaceship_schedule_condition_progress_bar", value = 0}
  progress.ignored_by_interaction = true
  progress.style.width = main_gui_width - 112
  progress.style.right_margin = -292 + 400 - main_gui_width

  local input_flow = condition_frame.add{type = "flow", style = "player_input_horizontal_flow"}
  input_flow.style.width = main_gui_width - 180

  if wait_condition.type == "time" then
      input_flow.add{type = "button", name = "time_button", tags = tags,
      style = "train_schedule_condition_time_selection_button", caption = wait_condition.ticks / 60 .. " s",
    }
    progress.caption = {"gui-train.passed"} -- Add the "passed" caption to the progress bar so that it changes colour

    input_flow.add{type = "textfield", name = "time_textfield", style = "slider_value_textfield", text = tostring(wait_condition.ticks / 60),
      numeric = true, clear_and_focus_on_right_click = true, visible = false, tags = tags,
    }.style.width = 84
    input_flow.add{type = "sprite-button", name = "time_confirm", style = "item_and_count_select_confirm", sprite = "utility/check_mark", visible = false,
      tags = tags,
    }.style.top_margin = 0
  else
    -- We create one flow with all the possible elements we might need in it. Then we
    -- can dynamically make some visible, and others not, to show the player what they
    -- need to see. Takes a little bit of fiddling, but makes managing it more intuitive.

    local is_circuit = true -- whether the first signal is compared to a signal or constant
    local constant = 0
    local first_signal, second_signal
    local comparator_index = 2
    if wait_condition and wait_condition.condition then
      first_signal = wait_condition.condition.first_signal
      second_signal = wait_condition.condition.second_signal
      comparator_index = util.find_index_in_array(comparator_items, wait_condition.condition.comparator) or 2
      if wait_condition.condition.constant then
        constant = wait_condition.condition.constant
        is_circuit = false
      end
    end
    input_flow.add{type = "button", name = "circuit_swap", style = "train_schedule_condition_time_selection_button", caption = is_circuit and {"gui-train.circuit"} or {"space-exploration.constant"}, tags = tags, }
    local circuit_condition = input_flow.add{type = "flow", name = "circuit_condition"}
    circuit_condition.style.vertical_align = "center"
    circuit_condition.add{type = "choose-elem-button", name = "first_signal", style = "train_schedule_item_select_button", signal=first_signal, elem_type = "signal", tags = tags}
    circuit_condition.add{type = "drop-down", name = "circuit-comparator", style = "se_spaceship_scheduler_comparator_dropdown", items=comparator_items, selected_index = comparator_index, tags = tags }
    circuit_condition.add{type = "choose-elem-button", name = "second_signal", style = "train_schedule_item_select_button", signal=second_signal, elem_type = "signal", visible=is_circuit, tags = tags,
      tooltip = {"space-exploration.spaceship-scheduler-change-condition-circuit-tooltip", {"space-exploration.constant"}, {"gui-train.circuit"}},
    }
    local constant_button = circuit_condition.add{type = "button", name = "constant_button", caption = core_util.format_number(constant, true), style = "train_schedule_item_select_button", visible = not is_circuit, tags = tags,
      tooltip = {"space-exploration.spaceship-scheduler-change-condition-circuit-tooltip", {"gui-train.circuit"}, {"space-exploration.constant"}}
    }
    constant_button.style.width = 96
    constant_button.style.font_color = {1, 1, 1, 1}
    circuit_condition.add{type = "textfield", name = "constant_textfield", style = "slider_value_textfield", text = tostring(constant),
      clear_and_focus_on_right_click = true, visible = false, tags = tags
    }.style.width = 72
    circuit_condition.add{type = "sprite-button", name = "constant_confirm", style = "item_and_count_select_confirm",
      sprite = "utility/check_mark", visible = false, tags = tags
    }.style.top_margin = 0
    input_flow.circuit_swap.tooltip = is_circuit and circuit_condition.second_signal.tooltip or circuit_condition.constant_button.tooltip
  end

  create_movement_buttons(condition_frame, "condition", tags)

  condition_frame.add{type = "sprite-button", name = "remove-wait-condition", style = "train_schedule_delete_button", sprite = "utility/close", tags = tags }
end

---@param flow LuaGuiElement
---@param record SpaceshipSchedulerRecord
---@param record_index uint of this record (either in the schedule, or the interrupt's targets)
---@param current boolean
---@param temporary boolean if this is interrupt created record
---@param tags table to add to every interactible element
---@param gui_index uint? if supplied it will be placed at given index in the flow
local function create_record_element(flow, record, record_index, current, temporary, tags, gui_index)
  local is_target = tags.is_target
  tags = core_util.merge{tags, {record_index = record_index, temporary = temporary}}

  local record_frame = flow.add{type = "flow", direction = "vertical", tags = tags, index = gui_index}
  record_frame.style.horizontal_align = "right"
  record_frame.style.width = main_gui_width - 20
  record_frame.style.bottom_margin = 4

  local record_header = record_frame.add{type = "frame", direction = "horizontal", style = temporary and "train_schedule_temporary_station_frame" or "train_schedule_station_frame"}
  record_header.style.width = main_gui_width - 20

  if not is_target then
    local select_button = record_header.add{type = "sprite-button", name = "action-button", style = "train_schedule_action_button", sprite = "utility/play", tags = tags }
    select_button.toggled = current
  end

  local destination_descriptor = record.destination_descriptor

  local record_description_flow = record_header.add{type = "flow", name = "destination-flow", direction = "horizontal"}
  record_description_flow.style.maximal_width = main_gui_width - 210
  record_description_flow.style.vertical_align = "center"
  local zone_name
  if destination_descriptor.zone_pointer then
    local zone = Zone.from_zone_index(destination_descriptor.zone_pointer)
    if zone then
      zone_name = Zone.get_print_name(zone, false, true)
    else zone_name = {"space-exploration.unknown-of-type", "space-exploration.zone"} end
  else
    zone_name = {"space-exploration.any-zone"}
  end
  local label = record_description_flow.add{type = "label", name = "destination-label", caption = zone_name}
  if temporary then label.style.font_color = {} --[[ black ]] end

  local line = record_description_flow.add{type="line", direction="vertical"}
  line.style.height = 28
  line.style.vertically_stretchable = false

  if not record.slingshot then
    label = record_description_flow.add{type = "label", caption = destination_descriptor.clamp.tag, tooltip = destination_descriptor.clamp.tag}
    if temporary then label.style.font_color = {} --[[ black ]] end
  end

  record_header.add{type = "empty-widget"}.style.horizontally_stretchable = true

  if record.slingshot then
    local sprite = record_header.add{type="sprite", sprite="se-slingshot", tooltip = {"space-exploration.spaceship-scheduler-enable-slingshot-tooltip"}}
    sprite.style.width = 28
    sprite.style.height = 28
    sprite.style.right_margin = -4
    sprite.style.right_padding = -10
  else
    local signal_name = SpaceshipClamp.signal_names_from_direction[record.spaceship_clamp.direction][1]
    local direction_name = {"space-exploration.spaceship-scheduler-"..(record.spaceship_clamp.direction == defines.direction.east and "right" or "left")}
    local sprite = record_header.add{type="sprite", sprite="virtual-signal/"..signal_name,
      tooltip = {"space-exploration.spaceship-scheduler-used-spaceship-clamp", direction_name, record.spaceship_clamp.tag }}
    sprite.style.width = 28
    sprite.style.height = 28
    sprite.style.right_margin = -4
    sprite.style.right_padding = -10
  end

  create_movement_buttons(record_header, "record", tags)

  record_header.add{type = "sprite-button", name = "remove_record", style = "train_schedule_delete_button", sprite = "utility/close", tags = tags, }

  if not record.slingshot then -- Conditions are not required for fly-bys

    local conditions_container = record_frame.add{type = "flow", name = "conditions-container", direction = "horizontal"}
    conditions_container.style.horizontal_spacing = 0
    conditions_container.style.padding = 0

    local and_or = conditions_container.add{type = "flow", name = "and_or", direction = "vertical"}
    and_or.style.top_padding = 20
    and_or.style.width = 92

    local conditions = conditions_container.add{type = "flow", name = "conditions", direction = "vertical"}
    conditions.style.vertical_spacing = 0

    local list = conditions.add{type = "flow", name = "list", direction = "vertical"}
    list.style.vertical_spacing = 0

    if record.wait_conditions then
      for _, wait_condition in pairs(record.wait_conditions) do
        create_condition_element(conditions_container, wait_condition, tags)
      end
    end

    local add_wait_condition = conditions.add{type = "drop-down", name = "add-condition", tags = tags,
    items = {{"gui-train.add-time-condition"}, {"gui-train.add-circuit-condition"}}}
    add_wait_condition.style.width = main_gui_width - 112
    add_wait_condition.style.height = 36

    -- THIS IS INCREDIBLY CURSED!!! DO NOT ADD CHILDREN TO NON-CONTAINER ELEMENTS!!! (Except here I guess...)
    label = add_wait_condition.add{type = "flow", ignored_by_interaction = true}.add{type = "label",
      style = "heading_3_label", caption = {"gui-train.add-wait-condition"}}
    label.style.top_margin = 4
    label.style.font_color = {} -- black
  end
end

---This function provides a mechanism that allows some actions to have to be confirmed
---first. This is only required when there are multiple spaceships in the ship's schedule group.
---@param spaceship SpaceshipType
---@param event EventData.on_gui_click
---@param player LuaPlayer
---@return boolean?
local function action_is_allowed_after_confirmation(spaceship, event, player)
  local schedule_group = storage.spaceship_scheduler_groups[spaceship.force_name][spaceship.scheduler.schedule_group_name]
  if not schedule_group then return false end
  if table_size(schedule_group.spaceships) <= 1 then
    -- Action is always allowed.
    return true
  end

  --- Get the element and do some sanity checks
  if event.name ~= defines.events.on_gui_click then return end
  local element = event.element
  if not (element and element.valid) then return end

  -- Ignore clicks with control to allow the action always
  if not event.control and (element.tags.clicks or 0) < 1 then
    -- Change the button to a red confirmation button
    -- but only if it was the left click. This is to prevent
    -- accidental removing while right-clicking for cancel

    if event.button ~= defines.mouse_button_type.right then
      element.sprite = "utility/check_mark"
      element.tooltip = {"space-exploration.spaceship-scheduler-big-group-needs-confirm"}
      element.style = "se_train_schedule_delete_button_red"
      util.update_tags(element, { clicks = 1 })
    end

    return false -- The action is not yet allowed
  end

  if event.button == defines.mouse_button_type.right then
    -- The button already turned red, but then the player
    -- cancelled the action. So revert to normal state
    element.style = "train_schedule_delete_button"
    element.sprite = "utility/close"
    element.tooltip = ""
    util.update_tags(element, { clicks = 0 })
    return false
  end

  if not event.control then
    player.play_sound{ path = "utility/cannot_build" }
    return false
  end

  -- If we reach here then the action is allowed
  return true
end

------------------------------------------------
-- MAIN GUI
------------------------------------------------

SpaceshipSchedulerGUI.gui_schedule_group_name_frame = "schedule-group-name-frame"
SpaceshipSchedulerGUI.gui_schedule_name_flow = "schedule-group-name-flow"
SpaceshipSchedulerGUI.gui_schedule_name_dropdown = "schedule-group-names-dropdown"
SpaceshipSchedulerGUI.gui_interrupt_name_frame = "interrupt-name-frame"
SpaceshipSchedulerGUI.gui_interrupt_name_flow = "interrupt-name-flow"
SpaceshipSchedulerGUI.gui_interrupt_name_dropdown = "interrupt-names-dropdown"

---@param spaceship SpaceshipType
---@param groups table<string, SpaceshipScheduleGroup>
---@param current string
---@param filter string?
---@return string[] list
---@return uint? selected_index
---@return string[] values
local function label_and_sort_schedule_group_names(spaceship, groups, current, filter)
  local list = {} -- names with optional [count]
  local values = {} -- raw names
  local selected_index
  local list_value_pairs = {} -- Keep them together for sorting

  if groups then
    for name, group in pairs(groups) do
      if filter and not string.find(string.lower(name), string.lower(filter), 1, true) then goto continue end
      if SpaceshipScheduler.is_unassigned_group_name(name) then goto continue end

      local count = table_size(group.spaceships)
      local display_name = name
      if count == 0 then
        group[name] = nil -- Sneak in some sanitization
      else
        if count > 1 then
          display_name = name .. " [font=default-bold][color=blue]["..count.."][/color][/font]"
        end
        table.insert(list_value_pairs, {display_name, name})
      end

      ::continue::
    end

    table.sort(list_value_pairs, function(a,b) return a[1] < b[1] end)

    -- The first entry will always be the unassigned entry
    local unassigned_group_localized = {"", "[color=#585858]", {"gui-train.empty-train-group"}, "[/color]"}
    table.insert(list_value_pairs, 1, {unassigned_group_localized, SpaceshipScheduler.get_unassigned_group_name(spaceship)})

    for i, list_value_pair in pairs(list_value_pairs) do
      table.insert(list, list_value_pair[1])
      table.insert(values, list_value_pair[2])
      if list_value_pair[2] == current then
        selected_index = i
      end
    end
  end

  return list, selected_index, values
end

---@param spaceship SpaceshipType
---@param current string
---@param filter string?
---@return string[] list
---@return uint selected_index
---@return string[] values
local function get_schedule_group_names_dropdown_values(spaceship, current, filter)
  local groups = storage.spaceship_scheduler_groups[spaceship.force_name]
  local list, selected_index, values = label_and_sort_schedule_group_names(spaceship, groups, current, filter)
  return list, (selected_index or 1), values
end

---@param player LuaPlayer
---@param spaceship SpaceshipType
---@return string[]
---@return uint
---@return LocationReference[]
local function get_star_restriction_dropdown_values(player, spaceship)
  local list, selected_index, values = Zone.dropdown_list_zone_destinations(
    player,
    spaceship.force_name,
    SpaceshipScheduler.restricted_to_star_system(spaceship),
    {
      alphabetical = true, -- Always for now, since we don't have a filter
      wildcard = {list = {"space-exploration.spaceship-scheduler-no-restriction"}, value = {type = "no-restriction"}, ignore_when_empty_list=true},
      excluded_types = {"spaceship", "orbit", "moon", "planet", "asteroid-belt", "asteroid-field", "anomaly"},
      allow_stars = true,
    }
  )
  if selected_index == 1 then selected_index = 2 end
  selected_index = selected_index or 2
  if selected_index > #list then selected_index = 1 end

  return list, selected_index, values
end

---@param root LuaGuiElement
---@param player LuaPlayer
---@param spaceship SpaceshipType
local function update_star_restriction_dropdown_values(root, player, spaceship)
  local list, selected_index, values = get_star_restriction_dropdown_values(player, spaceship)
  local list_zones = Util.find_first_descendant_by_name(root, "star-restriction")
  list_zones.items = list
  list_zones.selected_index = selected_index
  player_set_dropdown_values(player, "spaceship-scheduler-star-restriction", values)
end

---@param subheader LuaGuiElement where it should be added
---@param player LuaPlayer
---@param spaceship SpaceshipType
---@param tags table to add to all interactible elements
---@param editable boolean if this is the editable version or not
local function make_change_group_confirm_flow(subheader, player, spaceship, tags, editable)
  subheader.clear()

  local group = storage.spaceship_scheduler_groups[spaceship.force_name][spaceship.scheduler.schedule_group_name]
  local spaceship_count = 0
  local spaceship_list = ""
  for spaceship_index, _ in pairs(group and group.spaceships or { }) do
    if spaceship_index ~= spaceship.index then
      local other_spaceship = storage.spaceships[spaceship_index]
      if other_spaceship then
        spaceship_count = spaceship_count + 1
        spaceship_list = spaceship_list.."\n\t"..other_spaceship.name.." ["..other_spaceship.index.."]"
      end
    end
  end

  if editable then
    local frame_dark = subheader.add{ index=1, type="frame",
      name = SpaceshipSchedulerGUI.gui_schedule_group_name_frame,
      direction = "vertical",
      style = "space_platform_subheader_frame"
    }
    frame_dark.style.vertically_stretchable = true
    local name_flow = frame_dark.add{type = "flow", name = SpaceshipSchedulerGUI.gui_schedule_name_flow, direction = "horizontal", }

    local schedule_group_name = spaceship.scheduler.schedule_group_name
    GuiCommon.create_rename_textfield(name_flow, (not SpaceshipScheduler.is_unassigned(spaceship)) and schedule_group_name or nil, tags)
    name_flow.add{ type = "sprite-button", name = "change-schedule-group-cancel", sprite = "utility/close", tags = tags,
    tooltip = { "gui.cancel" }, mouse_button_filter = { "left" }, style = "tool_button_red", }
    name_flow.add {type = "sprite-button", name = "change-schedule-group-confirm", sprite = "utility/enter",
      tooltip = {"space-exploration.rename-confirm"}, style = "item_and_count_select_confirm",
      tags = tags
    }
    local list, selected_index, values = get_schedule_group_names_dropdown_values(spaceship, schedule_group_name)
    local dropdown = frame_dark.add{type = "drop-down", name = SpaceshipSchedulerGUI.gui_schedule_name_dropdown,
      items = list, selected_index = selected_index, tags = tags
    }
    dropdown.style.horizontally_stretchable = true
    player_set_dropdown_values(player, SpaceshipSchedulerGUI.gui_schedule_name_dropdown, values)

  else
    local used_in_tooltip = {"", {"space-exploration.spaceship-scheduler-schedule-used-in-spaceships", spaceship_count}, spaceship_list}

    local t = subheader.add{type="table", column_count=1}
    t.style.margin = {0, 4, 0, 4}

    local flow = t.add{type="flow", direction="horizontal"}
    flow.style.vertical_align = "center"
    flow.add{type = "label", caption = {"", {"space-exploration.spaceship-schedule-group"}, " [img=info]:"}, style="se_relative_properties_label", tooltip=used_in_tooltip}

    if SpaceshipScheduler.is_unassigned(spaceship) then
      local name_label = flow.add{type = "label", caption = {"", "[font=default-bold]", {"gui-train.empty-train-group"}, "[/font]"}, style="se_relative_properties_label"}
      name_label.style.horizontally_squashable = true
      name_label.style.maximal_width = 290
    else
      local name_label = flow.add{type = "label", caption = spaceship.scheduler.schedule_group_name.." [color=blue]["..(spaceship_count+1).."][/color]", style="heading_3_label", tooltip=used_in_tooltip}
      name_label.style.horizontally_squashable = true
      name_label.style.maximal_width = 290
    end

    flow.add{ type = "sprite-button", name = "change-schedule-group", sprite = "utility/rename_icon",
      tooltip = { "space-exploration.rename-something", "Spaceship Scheduler" }, mouse_button_filter = { "left" }, style = "frame_action_button",
      tags = { root_name=SpaceshipSchedulerGUI.gui_main_root_name }
    }.style.size = {18, 18}
    flow.add{type="empty-widget", style="se_relative_titlebar_nondraggable_spacer"}
    flow.add{type="label", caption={"", {"space-exploration.restrict-to-star-system"}, " [img=info]"},
    tooltip={"space-exploration.spaceship-scheduler-restrict-to-star-system-tooltip"}}

    flow = t.add{type="flow", direction="horizontal"}
    flow.add{type = "switch", name = "manual-mode", switch_state = spaceship.scheduler.active and "left" or "right",
      left_label_caption = {"gui-train.automatic-mode"}, right_label_caption = {"gui-train.manual-mode"}, tags = tags, }
    flow.add{type="empty-widget", style="se_relative_titlebar_nondraggable_spacer"}

    local list, selected_index, values = get_star_restriction_dropdown_values(player, spaceship)
    flow.add{type = "drop-down", name = "star-restriction", items = list,
      selected_index = selected_index, tags = tags,
    }.style.width = 160
    player_set_dropdown_values(player, "scheduler-star-restriction", values)
  end
end

---@param root LuaGuiElement
---@param player LuaPlayer
---@param spaceship SpaceshipType
function SpaceshipSchedulerGUI.gui_update_group_names_list(root, player, spaceship)
  local schedule_group_name = spaceship.scheduler.schedule_group_name

  --- Extract filter
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.rename_textfield_name)
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end

  local list, selected_index, values = get_schedule_group_names_dropdown_values(spaceship, schedule_group_name, filter)
  local group_names = Util.find_first_descendant_by_name(root, SpaceshipSchedulerGUI.gui_schedule_name_dropdown)
  group_names.items = list
  group_names.selected_index = selected_index
  player_set_dropdown_values(player, SpaceshipSchedulerGUI.gui_schedule_name_dropdown, values)
end

---(Re)builds the schedule GUI for all players that either have this
---spaceship's schedule open, or this schedule group.
---@param for_spaceship SpaceshipType will be determined automatically if not given
---@param player_filter LuaPlayer? optional filter to only build for this player
function SpaceshipSchedulerGUI.rebuild(for_spaceship, player_filter)
  local schedule_group_name_filter = for_spaceship.scheduler.schedule_group_name
  for _, player in pairs((player_filter and {player_filter}) or game.forces[for_spaceship.force_name].players) do
    local root = player.gui.screen[SpaceshipSchedulerGUI.gui_main_root_name]
    if not root then goto continue end
    local tags = { root_name = SpaceshipSchedulerGUI.gui_main_root_name }

    if not (root.tags and root.tags.spaceship_index) then SpaceshipSchedulerGUI.close(player) goto continue end
    local spaceship = storage.spaceships[root.tags.spaceship_index]
    if not spaceship then SpaceshipSchedulerGUI.close(player) goto continue end
    local scheduler = spaceship.scheduler

    if spaceship.index ~= for_spaceship.index and scheduler.schedule_group_name ~= schedule_group_name_filter then goto continue end

    -- Some meta info to overwrite. Mainly for other players that might also have the GUI open
    local scheduler_group = storage.spaceship_scheduler_groups[spaceship.force_name][scheduler.schedule_group_name]
    local subheader = Util.find_first_descendant_by_name(root, "subheader") --[[@cast subheader -? ]]
    make_change_group_confirm_flow(subheader, player, spaceship, tags, false) -- Always rebuild it non-editable
    update_star_restriction_dropdown_values(root, player, spaceship)

    -- Redraw schedule
    local records_flow = Util.find_first_descendant_by_name(root, "records") --[[@cast records_flow -? ]]
    records_flow.clear()
    SpaceshipScheduler.for_record_in_schedule(spaceship, function (record_index, target_number, record, is_current_record)
      create_record_element(records_flow, record, target_number or record_index, is_current_record, target_number ~= nil, tags)
    end)
    SpaceshipSchedulerGUI.update(player) -- For selected record and highlighted wait conditions

    -- Redraw Interrupts
    local interrupts_flow = Util.find_first_descendant_by_name(root, "interrupts") --[[@cast interrupts_flow -? ]]
    interrupts_flow.clear()
    for _, interrupt_name in pairs(scheduler_group.interrupts) do
      assert(storage.spaceship_scheduler_interrupts[spaceship.force_name][interrupt_name])

      local interrupt_frame = interrupts_flow.add{type = "flow", direction = "vertical"}
      interrupt_frame.style.horizontal_align = "right"
      interrupt_frame.style.width = main_gui_width - 20
      interrupt_frame.style.bottom_margin = 4

      local interrupt_header = interrupt_frame.add{type = "frame", direction = "horizontal", style = "train_schedule_station_frame"}
      interrupt_header.style.width = main_gui_width - 20

      interrupt_header.add{type = "sprite-button", name = "interrupt-action-button", style = "train_schedule_action_button", sprite = "utility/play", tags = tags }
      interrupt_header.add{type = "label", caption = interrupt_name}
      interrupt_header.add{type = "empty-widget"}.style.horizontally_stretchable = true
      interrupt_header.add{ type = "sprite-button", name = "edit-interrupt", sprite = "utility/rename_icon", tags = tags,
        tooltip = {"space-exploration.spaceship-scheduler-edit-interrupt"}, mouse_button_filter = { "left" }, style = "frame_action_button",}
      create_movement_buttons(interrupt_header, "interrupt", tags)
      interrupt_header.add{type = "sprite-button", name = "remove-interrupt", style = "train_schedule_delete_button", sprite = "utility/close",
        tags = core_util.merge{tags, {interrupt_name = interrupt_name}}
      }
    end

    SpaceshipSchedulerGUI.update(player)
    ::continue::
  end
end

---@param player LuaPlayer
function SpaceshipSchedulerGUI.is_open(player)
  return player.gui.screen[SpaceshipSchedulerGUI.gui_main_root_name] ~= nil
end

---@param player LuaPlayer
---@param spaceship SpaceshipType
function SpaceshipSchedulerGUI.open(player, spaceship)
  SpaceshipSchedulerGUI.close(player)
  if not spaceship then Log.debug('SpaceshipSchedulerGUI.open spaceship not found') return end

  -- Make sure that all the data is correct before we start building the GUI so it doesn't crash with a weird erroe
  SpaceshipScheduler.assert_scheduler(spaceship)
  SpaceshipScheduler.assert_schedule_group(spaceship.force_name, spaceship.scheduler.schedule_group_name)

  local root = player.gui.screen.add{type="frame", name=SpaceshipSchedulerGUI.gui_main_root_name, direction="vertical",
    tags = { spaceship_index = spaceship.index }
  }
  local tags = { root_name = SpaceshipSchedulerGUI.gui_main_root_name } -- To add to all interactible elements

  local title_bar = root.add{type="flow", style="se_relative_titlebar_flow"}
  title_bar.drag_target = root
  title_bar.add{type="label", caption={"space-exploration.spaceship-scheduler"}, style="frame_title", ignored_by_interaction=true}
  local name_label = title_bar.add{type="label", caption="[color=blue]["..spaceship.name.."][/color]", style="frame_title", ignored_by_interaction=true}
  name_label.style.horizontally_squashable = true
  name_label.style.maximal_width = 320
  title_bar.add{type="empty-widget", style = "se_titlebar_drag_handle", ignored_by_interaction=true}
  title_bar.add{type="sprite-button", sprite = "virtual-signal/informatron", style="frame_action_button",
    tooltip={"space-exploration.informatron-open-help"}, tags={se_action="goto-informatron", informatron_page="spaceship_automation_scheduler"}
  }
  title_bar.add{type="sprite-button", name="exit", style="frame_action_button", sprite="utility/close",
    mouse_button_filter={"left"}, tags = tags}

  local subheader_root = root.add{type = "frame", name = "subheader_root", direction = "vertical", style = "inside_shallow_frame"}
  local subheader = subheader_root.add{type = "frame", name = "subheader", style = "se_stretchable_subheader_frame", direction = "vertical"}
  subheader.style.left_margin = 0
  subheader.style.maximal_height = 72
  make_change_group_confirm_flow(subheader, player, spaceship, tags, false)

  local body = subheader_root.add{type="frame", direction="vertical", style="window_content_frame_packed"}
  body.style.padding = {0, 12, 12, 12}
  body.style.horizontally_stretchable = true
  body.style.height = 680 -- Hard coded height so that the records/interrupts can dynamically share vertical space.

  -- Schedule
  -----------------------------------------------------------
  body.add{type = "label", caption = {"gui-train.schedule"}, style="heading_3_label"}.style.padding = {8, 8, 8, 8}
  local records_frame = body.add{type = "frame", direction = "vertical", style = "deep_frame_in_shallow_frame"}.add{type = "scroll-pane", style = "se_spaceship_scheduler_records_scroll_pane"}
  records_frame.style.width = main_gui_width
  records_frame.style.maximal_height = 11 * 40 + 4 -- first number is the number of elements that can fit vertically

  local records_container = records_frame.add{type = "flow", direction = "vertical"}
  records_container.style.vertical_spacing = 0

  local records_flow = records_container.add{type = "flow", name = "records", direction = "vertical"}
  records_flow.style.vertical_spacing = 0

  local add_record = records_container.add{ type = "button", name = "add-record", caption = {"", "+ ", {"space-exploration.spaceship-scheduler-add-record"}}, tags = tags }
  add_record.style.width = main_gui_width - 20
  add_record.style.height = 36
  add_record.style.horizontal_align = "left"
  add_record.style.top_margin = 4
  add_record.style.font_color = {} -- black

  -- Interrupts
  -----------------------------------------------------------
  body.add{type = "label", caption = {"space-exploration.spaceship-scheduler-interrupts"}, style="heading_3_label"}.style.padding = {8, 8, 8, 8}
  local interrupts_frame = body.add{type = "frame", direction = "vertical", style = "deep_frame_in_shallow_frame"}.add{type = "scroll-pane", style = "se_spaceship_scheduler_records_scroll_pane"}
  interrupts_frame.style.width = main_gui_width
  interrupts_frame.style.vertically_stretchable = true -- Take the rest of the vertical space

  local interrupts_container = interrupts_frame.add{type = "flow", direction = "vertical"}
  interrupts_container.style.vertical_spacing = 0

  local interrupts_flow = interrupts_container.add{type = "flow", name = "interrupts", direction = "vertical"}
  interrupts_flow.style.vertical_spacing = 0

  local add_interrupt = interrupts_container.add{ type = "button", name = "add-interrupt", caption = {"", "+ ", {"space-exploration.spaceship-scheduler-add-interrupt"}}, tags = tags }
  add_interrupt.style.width = main_gui_width - 20
  add_interrupt.style.height = 36
  add_interrupt.style.horizontal_align = "left"
  add_interrupt.style.top_margin = 4
  add_interrupt.style.font_color = {} -- blacks

  SpaceshipSchedulerGUI.rebuild(spaceship, player)
  root.force_auto_center()
end

---Adds a triggered interrupt's targets to the schedule at a given location for
---all players that has this spaceship's GUI open. This could have been done
---with the rebuild function, but it might be annoying if you're busy setting
---up a condition in-flight, an interrupt is triggered, and your progress is lost.
---@param spaceship SpaceshipType
---@param targets table<uint, SpaceshipSchedulerRecord>
---@param index uint to insert it at
function SpaceshipSchedulerGUI.add_interrupt_targets(spaceship, targets, index)
  for _, player in pairs(game.connected_players) do
    local root = player.gui.screen[SpaceshipSchedulerGUI.gui_main_root_name]
    if not root then goto continue end
    if not (root.tags and root.tags.spaceship_index) then SpaceshipSchedulerGUI.close(player) goto continue end
    local this_spaceship = storage.spaceships[tonumber(root.tags.spaceship_index)] --[[@as SpaceshipType ]]
    if not this_spaceship then SpaceshipSchedulerGUI.close(player) goto continue end
    if this_spaceship.index ~= spaceship.index then goto continue end

    -- We need to update this GUI
    local index_to_insert_at = index
    local tags = { root_name = SpaceshipSchedulerGUI.gui_main_root_name }
    local records_flow = Util.find_first_descendant_by_name(root, "records") --[[@as LuaGuiElement ]]
    for target_number, target in pairs(targets) do
      create_record_element(records_flow, target, target_number, false, true, tags, index_to_insert_at)
      index_to_insert_at = index_to_insert_at + 1
    end

    ::continue::
  end
end

---Removes a triggered interrupt targets from the schedule for every playaer that has it open
---for this spaceship. This could have been done
---with the rebuild function, but it might be annoying if you're busy setting
---up a condition in-flight, an interrupt is triggered, and your progress is lost.
---@param spaceship SpaceshipType
---@param targets uint[]? target numbers. If not specified will remove all
function SpaceshipSchedulerGUI.remove_interrupt_targets(spaceship, targets)
  local target_map = targets and core_util.list_to_map(targets) or nil
  for _, player in pairs(game.connected_players) do
    local root = player.gui.screen[SpaceshipSchedulerGUI.gui_main_root_name]
    if not root then goto continue end
    if not (root.tags and root.tags.spaceship_index) then SpaceshipSchedulerGUI.close(player) goto continue end
    local this_spaceship = storage.spaceships[tonumber(root.tags.spaceship_index)] --[[@as SpaceshipType ]]
    if not this_spaceship then SpaceshipSchedulerGUI.close(player) goto continue end
    if this_spaceship.index ~= spaceship.index then goto continue end

    -- We need to update this GUI
    local records_flow = Util.find_first_descendant_by_name(root, "records") --[[@as LuaGuiElement ]]
    local index_in_gui = 1
    while index_in_gui <= #records_flow.children do
      local record_frame = records_flow.children[index_in_gui]
      local target_number = record_frame.tags.record_index   --[[@as uint? ]]
      local element_temporary = record_frame.tags.temporary  --[[@as boolean? ]]

      if element_temporary and (not target_map or target_map[target_number]) then
        record_frame.destroy()
      else
        index_in_gui = index_in_gui + 1
      end
    end

    ::continue::
  end
end

---Updates the scheduler GUI. Does the following:
--- * Some styling depending on which record is active, etc.
--- * Makes sure the any intterupt record are shown when they should (or not)
---@param player LuaPlayer
---@param filter_spaceship SpaceshipType? if supplied will only update if the GUI is of this spaceship index
function SpaceshipSchedulerGUI.update(player, filter_spaceship)
  local root = player.gui.screen[SpaceshipSchedulerGUI.gui_main_root_name]
  if not root then return end
  if not (root.tags and root.tags.spaceship_index) then SpaceshipSchedulerGUI.close(player) return end
  local spaceship = storage.spaceships[tonumber(root.tags.spaceship_index)] --[[@as SpaceshipType ]]
  if not spaceship then SpaceshipSchedulerGUI.close(player) return end
  if filter_spaceship and (filter_spaceship.index ~= spaceship.index) then return end
  local scheduler = spaceship.scheduler

  local manual_mode_switch = Util.find_first_descendant_by_name(root.subheader_root.subheader, "manual-mode") --[[@cast manual_mode_switch -? ]]
  if manual_mode_switch then manual_mode_switch.switch_state = scheduler.active and "left" or "right" end

  local records_flow_children = Util.find_first_descendant_by_name(root, "records").children
  local index_in_gui = 0
  SpaceshipScheduler.for_record_in_schedule(spaceship, function (record_index, target_number, record, is_current_record)
    -- This assumes the GUI and the state of the schedule is perfectly in sync. If it's not
    -- then it should be fix during the event that creates the discrepency

    index_in_gui = index_in_gui + 1
    local record_frame = records_flow_children[index_in_gui]

    -- Verify that this GUI is in sync. Rather crash early than letting
    -- the player's changes be different than what they expect.
    assert(record_frame, "No record entry in GUI found for index "..index_in_gui..". Schedule and GUI out of sync!")
    local element_record_index = record_frame.tags.record_index  --[[@as uint? index in schedule or created interrupt stack]]
    local element_temporary = record_frame.tags.temporary  --[[@as boolean? if this record is temporary]]
    assert(element_record_index == target_number or record_index)
    assert((target_number ~= nil) == (element_temporary),
      "A existing target_number expects that the current gui element record is tagged as temporary. [Target: "..(target_number or "nil")..", Element Temporary?: "..(element_temporary and "yes" or "no").."]")

    -- Highlight the record currently active
    local record_header = record_frame.children[1]
    local action_button = record_header["action-button"]
    action_button.toggled = is_current_record
    if is_current_record and scheduler.no_existing_clamp then
      action_button.sprite = "utility/not_available"
      action_button.tooltip = {"space-exploration.spaceship-scheduler-no-clamps-exist"}
    else
      action_button.sprite = "utility/play"
      action_button.tooltip = ""
    end

    -- Set a tooltip to show to which zone the spaceship is actually flying
    if is_current_record then
      local zone = Spaceship.get_destination_zone(spaceship)
      record_header["destination-flow"]["destination-label"].tooltip =
      zone and {"space-exploration.spaceship-scheduler-heading-to-tooltip", Zone.get_print_name(zone)} or ""
    else
      record_header["destination-flow"]["destination-label"].tooltip = ""
    end

    -- Set the progress of each condition (and clear for other records)
    if not record.slingshot then
      local conditions_flow_children = record_frame.children[2]["conditions"].children[1].children
      for condition_index, condition in pairs(record.wait_conditions or {}) do
        local progress_bar = conditions_flow_children[condition_index].progress
        if is_current_record and scheduler.state == "wait-at-stop" then
          -- We are currently waiting at this record so show the progress
          local satisfaction_cache = scheduler.record_satisfactions[condition_index]
          progress_bar.value = satisfaction_cache and satisfaction_cache.satisfaction or 0
          local required_style = "se_spaceship_schedule_condition_progress_bar"
          if progress_bar.value ~= 1 then required_style = required_style .. "_partial" end
          -- Not sure what's best for UPS, my gut says this way.
          if progress_bar.style.name ~= required_style then progress_bar.style = required_style end
        else
          progress_bar.value = 0  -- Always reset to zero
        end
      end
    end
  end)

  assert(records_flow_children[index_in_gui + 1] == nil, "There are more records in the UI than in actual schedule")

end

---@param player LuaPlayer
function SpaceshipSchedulerGUI.close(player)
  local root = player.gui.screen[SpaceshipSchedulerGUI.gui_main_root_name]
  if root then root.destroy() end

  -- Close these GUIs always, regardless of root exists or not
  SpaceshipSchedulerGUI.close_add_destination_popup(player)
  SpaceshipSchedulerGUI.close_interrupt_popup(player)
end

---@param event EventData.on_gui_click|EventData.on_gui_confirmed|EventData.on_gui_selection_state_changed|EventData.on_gui_switch_state_changed|EventData.on_gui_elem_changed|EventData.on_gui_checked_state_changed|EventData.on_gui_text_changed
---@param element LuaGuiElement
---@param root LuaGuiElement
local function on_main_gui_event(event, element, root)
  local player = game.get_player(event.player_index) --[[@cast player -?]]
  local element_name = element.name

  local tags = root.tags
  assert(tags and tags.spaceship_index)
  local spaceship = Spaceship.from_index(tags.spaceship_index --[[@as integer]])
  if not spaceship then SpaceshipSchedulerGUI.close_add_destination_popup(player) return end
  local scheduler = spaceship.scheduler

  local record_index = element.tags.record_index  --[[@as uint? index in schedule or created interrupt stack]]
  local temporary = element.tags.temporary        --[[@as boolean? means created by interrupt ]]

  if element_name == "exit" then
    SpaceshipSchedulerGUI.close(player)


  elseif element_name == "manual-mode" then
    if event.name ~= defines.events.on_gui_switch_state_changed then return end
    if event.element.switch_state == "left" then
      SpaceshipScheduler.activate(spaceship)
    else
      SpaceshipScheduler.deactivate(spaceship)
    end


  elseif element_name == "add-condition" then
    if event.name ~= defines.events.on_gui_selection_state_changed then return end

    local is_time = element.selected_index == 1
    local wait_condition = {
      type = is_time and "time" or "circuit",
      compare_type = "and",
      ticks = is_time and default_wait_condition_time or nil,
      condition = (not is_time) and {
        comparator = "<",
        constant = 0, -- Default to comparing to a constant and not a signal, which would be more common
      } or nil,
    } --[[@as WaitCondition]]

    local record
    if temporary then
      record = scheduler.current_interrupts[record_index]
    else
      record = SpaceshipScheduler.get_schedule(spaceship)[record_index]
    end

    record.wait_conditions = record.wait_conditions or { }
    table.insert(record.wait_conditions, wait_condition)

    local conditions_container = element.parent.parent --[[@as LuaGuiElement]]
    create_condition_element(conditions_container, wait_condition, element.tags)
    element.selected_index = 0
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "condition-move-up" then

    local condition_frame = element.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()
    if condition_index == 1 then return end

    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?

    Util.swap_elements(wait_conditions, condition_index, condition_index - 1)
    scheduler.record_satisfactions = { } -- Reset so the progress bars are not incorrect
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "condition-move-down" then
    local condition_frame = element.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?

    if condition_index >= #wait_conditions then return end
    Util.swap_elements(wait_conditions, condition_index, condition_index + 1)
    scheduler.record_satisfactions = { } -- Reset so the progress bars are not incorrect
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "remove-wait-condition" then
    ---@diagnostic disable-next-line: param-type-mismatch
    if not action_is_allowed_after_confirmation(spaceship, event, player) then return end

    local condition_frame = element.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?

    table.remove(wait_conditions, condition_index)
    scheduler.record_satisfactions = { } -- Reset so the progress bars are not incorrect
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "and-or-button" then
    local and_or_frame = element.parent --[[@as LuaGuiElement]]
    local condition_index = and_or_frame.get_index_in_parent()

    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?

    local condition = wait_conditions[condition_index]
    condition.compare_type = condition.compare_type == "and" and "or" or "and"
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "record-move-up" then
    assert(record_index)
    if not temporary then
      if SpaceshipScheduler.move_record_in_schedule_group(spaceship.force_name,
                                                          scheduler.schedule_group_name,
                                                          record_index,
                                                          "up") then
        -- We rebuild the entire schedule to correctly handle the moving
        -- over the entire stack of interrupts.
        SpaceshipSchedulerGUI.rebuild(spaceship)
      end
    else
      -- Cannot move temporary records yet
      player.create_local_flying_text{ text = {"space-exploration.spaceship-scheduler-cannot-move-interrupt-targets"}, create_at_cursor = true }
    end


  elseif element_name == "record-move-down" then
    assert(record_index)
    if not temporary then
      if SpaceshipScheduler.move_record_in_schedule_group(spaceship.force_name,
                                                          scheduler.schedule_group_name,
                                                          record_index,
                                                          "down") then
        -- We rebuild the entire schedule to correctly handle the moving
        -- over the entire stack of interrupts.
        SpaceshipSchedulerGUI.rebuild(spaceship)
      end
    else
      -- Cannot move temporary records yet
      player.create_local_flying_text{ text = {"space-exploration.spaceship-scheduler-cannot-move-interrupt-targets"}, create_at_cursor = true }
    end


  elseif element_name == "add-record" then
    SpaceshipSchedulerGUI.open_add_destination_popup(player, spaceship)


  elseif element_name == "remove_record" then
    assert(record_index)

    ---@diagnostic disable-next-line: param-type-mismatch
    if not action_is_allowed_after_confirmation(spaceship, event, player) then return end

    if not temporary then
      SpaceshipScheduler.remove_record_from_schedule_group(spaceship.force_name, scheduler.schedule_group_name, record_index)
      SpaceshipSchedulerGUI.rebuild(spaceship)
    else
      SpaceshipScheduler.remove_current_interrupt_targets(spaceship, {record_index})
      SpaceshipSchedulerGUI.rebuild(spaceship)
      -- This will automatically update the GUI
    end


  elseif element_name == "circuit_swap" then -- Changes comparing between signal or constant
    local condition_frame = element.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?

    local circuit_condition = wait_conditions[condition_index].condition --[[@cast circuit_condition -? ]]
    if circuit_condition.constant == nil then
      -- Changed to comparing to constant
      element.caption = {"space-exploration.constant"}
      element.tooltip = element.parent.circuit_condition.second_signal.tooltip
      circuit_condition.second_signal = nil
      circuit_condition.constant = 0
    else
      -- Changed to comparing to circuit
      element.caption = {"gui-train.circuit"}
      element.tooltip = element.parent.circuit_condition.constant_button.tooltip
      circuit_condition.second_signal = nil
      circuit_condition.constant = nil
    end

    scheduler.record_satisfactions = { } -- Reset so the progress bars are not incorrect
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "time_button" then
    local input_flow = element.parent --[[@as LuaGuiElement]]
    element.visible = false
    input_flow.time_textfield.visible = true
    input_flow.time_confirm.visible = true

    input_flow.time_textfield.focus()
    input_flow.time_textfield.select_all()


  elseif element_name == "time_confirm" or (element_name == "time_textfield" and event.name == defines.events.on_gui_confirmed) then
    local condition_frame = element.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()
    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?
    wait_conditions[condition_index].ticks = (tonumber(element.parent.time_textfield.text) or 0) * 60
    scheduler.record_satisfactions = { } -- Reset so the progress bars are not incorrect
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "constant_button" then
    local input_flow = element.parent --[[@as LuaGuiElement]]
    element.visible = false
    input_flow.constant_textfield.visible = true
    input_flow.constant_confirm.visible = true

    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()
    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?
    local condition = wait_conditions[condition_index]

    input_flow.constant_textfield.text = tostring(condition.condition.constant)
    input_flow.constant_textfield.focus()
    input_flow.constant_textfield.select_all()


  elseif element_name == "constant_confirm" or (element_name == "constant_textfield" and event.name == defines.events.on_gui_confirmed) then
    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()
    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?
    local condition = wait_conditions[condition_index]
    local constant = util.number_from_string(element.parent.constant_textfield.text)
    condition.condition = condition.condition or { }
    condition.condition.constant = constant
    scheduler.record_satisfactions = { } -- Reset so the progress bars are not incorrect
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "first_signal" then
    if event.name ~= defines.events.on_gui_elem_changed then return end

    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()
    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?
    local circuit_condition = wait_conditions[condition_index].condition

    circuit_condition.first_signal = element.elem_value --[[@as SignalID ]]
    scheduler.record_satisfactions = { } -- Reset so the progress bars are not incorrect
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "second_signal" then
    if event.name ~= defines.events.on_gui_elem_changed then return end
    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()
    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?
    local circuit_condition = wait_conditions[condition_index].condition
    circuit_condition.second_signal = element.elem_value --[[@as SignalID ]]
    scheduler.record_satisfactions = { } -- Reset so the progress bars are not incorrect
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "circuit-comparator" then
    if event.name ~= defines.events.on_gui_selection_state_changed then return end

    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()
    local wait_conditions
    if temporary then
      wait_conditions = scheduler.current_interrupts[record_index].wait_conditions
    else
      wait_conditions = SpaceshipScheduler.get_schedule(spaceship)[record_index].wait_conditions
    end
    ---@cast wait_conditions -?
    local circuit_condition = wait_conditions[condition_index].condition
    circuit_condition.comparator = element.get_item(element.selected_index) --[[@as string ]]
    scheduler.record_satisfactions = { } -- Reset so the progress bars are not incorrect
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "action-button" then

    if scheduler.state == "wait-for-launch-success" then
      -- The launch sequence already started, we can't reliably stop the spaceship from launching.
      -- So we just stop the player from doing it.
      player.create_local_flying_text{
        text = {"space-exploration.spaceship-scheduler-cannot-redirect-while-waiting-for-launch"},
        create_at_cursor = true
      }
      return
    end

    ---@TODO Do nothing is spaceship is already flying here
    SpaceshipScheduler.activate(spaceship)
    SpaceshipScheduler.force_repath(spaceship, record_index, temporary)
    SpaceshipSchedulerGUI.update(player, spaceship) -- So that the current record sprite changes immediately


  elseif element_name == "star-restriction" and event.name == defines.events.on_gui_selection_state_changed then
    local value = player_get_dropdown_value(player, "scheduler-star-restriction", element.selected_index)
    local star --[[@as StarType?]]
    if value.type == "zone" then
      star = Zone.from_zone_index(value.index)
      assert(star and star.type == "star")
      ---@cast star StarType
    end
    SpaceshipScheduler.set_restrict_to_star_system(spaceship.force_name, scheduler.schedule_group_name, star)
    SpaceshipSchedulerGUI.rebuild(spaceship) -- Will also update the dropdown


  elseif element_name == "change-schedule-group" then
    local subheader = element.parent.parent --[[@cast subheader -? ]]
    make_change_group_confirm_flow(subheader, player, spaceship, {root_name = SpaceshipSchedulerGUI.gui_main_root_name}, true)


  elseif element_name == SpaceshipSchedulerGUI.gui_schedule_name_dropdown and event.name == defines.events.on_gui_selection_state_changed then
    local new_group_name = player_get_dropdown_value(player, element.name, element.selected_index)
    if new_group_name == SpaceshipScheduler.get_unassigned_group_name(spaceship) then
      element.parent.children[1][GuiCommon.rename_textfield_name].text = ""
    else
      element.parent.children[1][GuiCommon.rename_textfield_name].text = new_group_name
    end


  elseif element_name == "change-schedule-group-cancel" then
    local subheader = element.parent.parent.parent --[[@cast subheader -? ]]
    make_change_group_confirm_flow(subheader, player, spaceship, {root_name = SpaceshipSchedulerGUI.gui_main_root_name}, false)


  elseif element_name == "change-schedule-group-confirm" or element_name == GuiCommon.rename_textfield_name and event.name == defines.events.on_gui_confirmed then
    local new_group_name --[[@as string ]]

    if element_name == "change-schedule-group-confirm" then
      new_group_name = string.trim(event.element.parent[GuiCommon.rename_textfield_name].text)
    else
      new_group_name = element.text
    end

    if new_group_name == "" then
      -- Could be that it's unassigned. Then textfield will be empty and unnassigned group will be selected.
      local dropdown_element = Util.find_first_descendant_by_name(element.parent.parent, SpaceshipSchedulerGUI.gui_schedule_name_dropdown)
      assert(dropdown_element)
      new_group_name = player_get_dropdown_value(player, dropdown_element.name, dropdown_element.selected_index)
      if new_group_name ~= SpaceshipScheduler.get_unassigned_group_name(spaceship) then
        player.print({"space-exploration.spaceship-scheduler-group-name-cannot-be-empty"})
        return
      end
    elseif SpaceshipScheduler.is_unassigned_group_name(new_group_name) then
      -- Ensure don't create new groups with the hidden unassigned name
      player.print({"space-exploration.spaceship-scheduler-group-name-invalid"})
      return
    end

    if new_group_name ~= spaceship.scheduler.schedule_group_name then
      if string.len(new_group_name) > SpaceshipScheduler.max_name_length then
        player.print({"space-exploration.spaceship-scheduler-group-name-too-long", SpaceshipScheduler.max_name_length})
        return
      end

      -- do change name stuff
      SpaceshipScheduler.change_spaceship_schedule_group(spaceship, new_group_name)
      SpaceshipSchedulerGUI.rebuild(spaceship)
    else
      -- Nothing was changed
      local subheader = element.parent.parent.parent --[[@cast subheader -? ]]
      make_change_group_confirm_flow(subheader, player, spaceship, {root_name = SpaceshipSchedulerGUI.gui_main_root_name}, false)
    end


  elseif element_name == "add-interrupt" then
    SpaceshipSchedulerGUI.open_interrupt_popup(player, spaceship)

  elseif element_name == "edit-interrupt" then
    local interrupt_frame = element.parent.parent --[[@cast interrupt_frame -? ]]
    local interrupt_index = interrupt_frame.get_index_in_parent()
    local schedule_group = storage.spaceship_scheduler_groups[spaceship.force_name][scheduler.schedule_group_name]
    local interrupt_name = schedule_group.interrupts[interrupt_index]
    SpaceshipSchedulerGUI.open_interrupt_popup(player, spaceship, interrupt_name)


  elseif element_name == "interrupt-move-up" then
    local interrupt_frame = element.parent.parent.parent --[[@cast interrupt_frame -? ]]
    local interrupt_index = interrupt_frame.get_index_in_parent()
    local schedule_group = storage.spaceship_scheduler_groups[spaceship.force_name][scheduler.schedule_group_name]
    if interrupt_index == 1 then return end
    Util.swap_elements(schedule_group.interrupts, interrupt_index, interrupt_index - 1)
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "interrupt-move-down" then
    local interrupt_frame = element.parent.parent.parent --[[@cast interrupt_frame -? ]]
    local interrupt_index = interrupt_frame.get_index_in_parent()
    local schedule_group = storage.spaceship_scheduler_groups[spaceship.force_name][scheduler.schedule_group_name]
    if interrupt_index == #schedule_group.interrupts then return end
    Util.swap_elements(schedule_group.interrupts, interrupt_index, interrupt_index + 1)
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "remove-interrupt" then
    ---@diagnostic disable-next-line: param-type-mismatch
    if not action_is_allowed_after_confirmation(spaceship, event, player) then return end

    local interrupt_name = element.tags.interrupt_name --[[@as string? ]]
    assert(interrupt_name)
    SpaceshipScheduler.remove_interrupt_from_schedule_group(spaceship.force_name, scheduler.schedule_group_name, interrupt_name)
    SpaceshipSchedulerGUI.rebuild(spaceship)


  elseif element_name == "interrupt-action-button" then
    local interrupt_frame = element.parent.parent --[[@cast interrupt_frame -? ]]
    local interrupt_index = interrupt_frame.get_index_in_parent()
    SpaceshipScheduler.activate(spaceship) -- Needs to happen before trigger.
    SpaceshipScheduler.trigger_interrupt(spaceship, interrupt_index, true --[[ preemptive ]])


  end
end

------------------------------------------------
-- ADD DESTINATION POPUP
------------------------------------------------

---@param player LuaPlayer
---@param spaceship SpaceshipType
---@param record SpaceshipSchedulerRecord
---@param filter? string
---@return string[]
---@return uint
---@return LocationReference[]
function SpaceshipSchedulerGUI.get_popup_zone_dropdown_values(player, spaceship, record, filter)

  -- Find the current destination of the spaceship. Prefer to the zone it's currently anchored at.
  local location = spaceship.zone_index and Zone.from_surface_index(spaceship.zone_index) or Zone.find_nearest_zone(
    spaceship.space_distortion, spaceship.stellar_position, spaceship.star_gravity_well, spaceship.planet_gravity_well
  )
  assert(location)
  local zone_pointer = record.destination_descriptor.zone_pointer
  assert(not zone_pointer or zone_pointer > 0, "This function does support spaceships yet")
  local current_destination = zone_pointer and Zone.from_zone_index(zone_pointer) --[[@as AnyZoneType? ]]

  local playerdata = get_make_playerdata(player)
  local list, selected_index, values

  list, selected_index, values = Zone.dropdown_list_zone_destinations(
    player,
    spaceship.force_name,
    current_destination,
    {
      alphabetical = playerdata.zones_alphabetical,
      filter = filter,
      wildcard = {list = {"space-exploration.list-destination-any"}, value = {type = "any"}, ignore_when_empty_list=true},
      star_restriction = SpaceshipScheduler.restricted_to_star_system(spaceship),
      excluded_types = {"spaceship", "star"},
      only_with_spaceship_clamps = not record.slingshot -- If a slingshot spaceship can fly to any zone
    }
  )
  if selected_index == 1 then selected_index = 2 end
  selected_index = selected_index or 2
  if selected_index > #list then selected_index = 1 end

  return list, selected_index, values
end

---@param root LuaGuiElement
---@param player LuaPlayer
---@param spaceship SpaceshipType
---@param record SpaceshipSchedulerRecord
function SpaceshipSchedulerGUI.update_popup_zone_dropdown_values(root, player, spaceship, record)
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end
  local list, selected_index, values = SpaceshipSchedulerGUI.get_popup_zone_dropdown_values(player, spaceship, record, filter)
  local list_zones = Util.find_first_descendant_by_name(root, "destination-zone-dropdown")
  list_zones.items = list
  list_zones.selected_index = selected_index
  player_set_dropdown_values(player, "destination-zone-dropdown", values)
end

---Opens the GUI to add a destination. This GUI will store the destination descriptor currently being
---configured as tags in the root. And once confirmed that tag will be added to the actual schedule group.
---@param player LuaPlayer
---@param spaceship SpaceshipType
---@param for_interrupt boolean? if this popup was opened from the interrupt popup
function SpaceshipSchedulerGUI.open_add_destination_popup(player, spaceship, for_interrupt)
  SpaceshipSchedulerGUI.close_add_destination_popup(player) -- Always rebuild

  local record = { destination_descriptor = { } } --[[@as SpaceshipSchedulerRecord]]
  local root = player.gui.screen.add{type="frame", name=SpaceshipSchedulerGUI.gui_destination_popup_root_name, direction="vertical",
    tags = { spaceship_index = spaceship.index, record = record, for_interrupt = for_interrupt or false }
  }

  -- Title Bar
  -----------------------------------------------------------

  local title_bar = root.add{type="flow", style="se_relative_titlebar_flow"}
  title_bar.drag_target = root
  title_bar.add{type="label", style="frame_title", caption={"space-exploration.spaceship-scheduler-add-destination"}, ignored_by_interaction=true}
  title_bar.add{type="empty-widget", style = "se_titlebar_drag_handle", ignored_by_interaction=true}
  title_bar.add{type="sprite-button", sprite = "virtual-signal/informatron", style="frame_action_button",
    tooltip={"space-exploration.informatron-open-help"}, tags={se_action="goto-informatron", informatron_page="spaceship_automation_scheduler"}
  }
  title_bar.add{type="sprite-button", name="cancel", style="frame_action_button", sprite="utility/close", mouse_button_filter={"left"},
    tags = { root_name=SpaceshipSchedulerGUI.gui_destination_popup_root_name }
  }

  local body_flow = root.add{type="flow", direction="horizontal"}
  local left_flow = body_flow.add{type="flow", direction="vertical"}
  local right_flow = body_flow.add{type="flow", direction="vertical"}

  -- Destination Zone
  -----------------------------------------------------------
  do
    local body = left_flow.add{type = "frame", direction = "vertical", style = "inside_deep_frame"}

    local subheader = body.add{type = "frame", style = "subheader_frame"}
    subheader.style.width = 360
    subheader.style.vertically_stretchable = true
    subheader.style.height = 32

    local subheader_flow = subheader.add{type = "flow", style = "train_schedule_mode_switch_horizontal_flow"}
    subheader_flow.add{type = "label", caption={"space-exploration.spaceship-scheduler-destination-zone"}, style="heading_3_label"}
    subheader_flow.add{type="empty-widget", style="se_relative_properties_spacer"}
    subheader_flow.add{type="checkbox", name="enable-slingshot", caption={"space-exploration.spaceship-scheduler-enable-slingshot"}, state = false,
      tooltip = {"space-exploration.spaceship-scheduler-enable-slingshot-tooltip"},
      tags = {  root_name = SpaceshipSchedulerGUI.gui_destination_popup_root_name },
    }.style.right_margin = 4

    local content_root = body.add{type="frame", direction="vertical", style="window_content_frame_packed"}
    local content = content_root.add{type="frame", direction="vertical", style="b_inner_frame"}
    content.style.padding = 10

    local playerdata = get_make_playerdata(player)
    content.add{type="checkbox", name="list-zones-alphabetical", caption={"space-exploration.list-destinations-alphabetically"},
    state=playerdata.zones_alphabetical and true or false, tags = { root_name = SpaceshipSchedulerGUI.gui_destination_popup_root_name },}
    local list, selected_index, values = SpaceshipSchedulerGUI.get_popup_zone_dropdown_values(player, spaceship, record)
    GuiCommon.create_filter(content, player,  {
      list = list,
      selected_index = selected_index,
      values = values,
      dropdown_name =  "destination-zone-dropdown",
      tags = { root_name = SpaceshipSchedulerGUI.gui_destination_popup_root_name, },
    })

    local shown_zones = content.add{type="label", name="shown-zones-label", caption="", style="se_relative_properties_label"}
    shown_zones.style.width = 320
    shown_zones.style.single_line = false
  end

  -- Spaceship Clamp
  -----------------------------------------------------------
  do
    local body = left_flow.add{type = "frame", name="spaceship_clamp_frame", direction = "vertical", style = "inside_deep_frame"}
    body.style.top_margin = 12

    local subheader = body.add{type = "frame", style = "subheader_frame"}
    subheader.style.height = 32
    subheader.style.horizontally_stretchable = true
    subheader.add{type = "flow", style = "train_schedule_mode_switch_horizontal_flow"}.add{
      type = "label", caption={"", {"space-exploration.spaceship-scheduler-select-spaceship-clamp"}, " [img=info]"},
      style="heading_3_label", tooltip = {"space-exploration.spaceship-scheduler-select-spaceship-clamp-tooltip"}
    }

    local tag_list = body.add{type = "list-box", name = "spaceship-clamp-list-box", tags = { root_name = SpaceshipSchedulerGUI.gui_destination_popup_root_name }}
    tag_list.style.height = 200
    tag_list.style.horizontally_stretchable = true
  end

  -- Destination Clamp
  -----------------------------------------------------------
  do
    local body = right_flow.add{type = "frame", name="destination_clamp_frame", direction = "vertical", style = "inside_deep_frame"}
    body.style.left_margin = 12

    local subheader = body.add{type = "frame", style = "subheader_frame"}
    subheader.style.height = 32
    subheader.style.width = 360
    subheader.add{type = "flow", style = "train_schedule_mode_switch_horizontal_flow"}.add{
      type = "label", caption={"", {"space-exploration.spaceship-scheduler-select-destination-clamp"}, " [img=info]"}, style="heading_3_label",
      tooltip = {"space-exploration.spaceship-scheduler-select-destination-clamp-tooltip"}
    }

    local tag_list = body.add{type = "list-box", name = "destination-clamp-list-box", tags = { root_name = SpaceshipSchedulerGUI.gui_destination_popup_root_name }}
    tag_list.style.horizontally_stretchable = true
    tag_list.style.vertically_stretchable = true
  end

  -- Bottom Buttons
  -----------------------------------------------------------

  local confirm_cancel_flow = root.add{type="flow", direction="horizontal", style = "dialog_buttons_horizontal_flow"}
  confirm_cancel_flow.add{type="sprite-button", name="cancel", caption={"space-exploration.spaceship-scheduler-cancel"}, style="red_back_button", mouse_button_filter={"left"},
    tags = { root_name = SpaceshipSchedulerGUI.gui_destination_popup_root_name, }
  }
  local empty = confirm_cancel_flow.add{type="empty-widget"}
  empty.style.horizontally_stretchable = true
  confirm_cancel_flow.add{type="sprite-button", name="confirm", caption={"space-exploration.spaceship-scheduler-add-destination"}, style="confirm_button_without_tooltip", mouse_button_filter={"left"},
    tags = { root_name = SpaceshipSchedulerGUI.gui_destination_popup_root_name, }
  }

  root.force_auto_center()
  SpaceshipSchedulerGUI.update_add_destination_popup(player) -- Do after, as it might destroy the root
end

---Update the destination popup to correctly show the state currently stored in the tags
---@param player LuaPlayer
function SpaceshipSchedulerGUI.update_add_destination_popup(player)
  local root = player.gui.screen[SpaceshipSchedulerGUI.gui_destination_popup_root_name]
  if not root then return end
  if not (root.tags and root.tags.spaceship_index) then SpaceshipSchedulerGUI.close_add_destination_popup(player) end
  local spaceship = Spaceship.from_index(root.tags.spaceship_index --[[@as number ]])
  if not spaceship then SpaceshipSchedulerGUI.close_add_destination_popup(player) return end

  local record = root.tags.record --[[@as SpaceshipSchedulerRecord ]]
  assert(record)
  local destination_descriptor = record.destination_descriptor

  -- Zone ----------------------------------
  do
    local label = Util.find_first_descendant_by_name(root, "shown-zones-label") --[[@cast label -? ]]
    local shown_zones_label = {""}

    local star_restriction = SpaceshipScheduler.restricted_to_star_system(spaceship)
    if record.slingshot then
      if star_restriction then
        shown_zones_label = {"space-exploration.spaceship-scheduler-showing-zones-system", Zone.get_print_name(star_restriction, true, false)}
      else
        shown_zones_label = {"space-exploration.spaceship-scheduler-showing-all-zones"}
      end
    else
      if star_restriction then
        shown_zones_label = {"space-exploration.spaceship-scheduler-showing-anchorable-zones-system", Zone.get_print_name(star_restriction, true, false)}
      else
        shown_zones_label = {"space-exploration.spaceship-scheduler-showing-all-anchorable-zones"}
      end
    end
    label.caption = shown_zones_label
  end

  -- Spaceship Clamp Tag ----------------------------------
  local spaceship_clamp_frame = Util.find_first_descendant_by_name(root, "spaceship_clamp_frame") --[[@cast spaceship_clamp_frame -? ]]
  local spaceship_clamp_listbox = Util.find_first_descendant_by_name(spaceship_clamp_frame, "spaceship-clamp-list-box") --[[@cast spaceship_clamp_listbox -? ]]
  if record.slingshot then
    spaceship_clamp_listbox.enabled = false
    spaceship_clamp_listbox.items = { }
  else
    spaceship_clamp_listbox.enabled = true

    if not record.spaceship_clamp then
      record.spaceship_clamp = { direction = defines.direction.west }
    end

    -- Gather all direction/tags on the spaceship
    local clamps = { } ---@type SpaceshipClampDescriptor[]
    for _, clamp_info in pairs(SpaceshipClamp.get_clamps_on_spaceship(spaceship)) do

      local already_exists = false
      for _, existing_clamp in pairs(clamps) do
        if existing_clamp.direction == clamp_info.direction and existing_clamp.tag == clamp_info.tag then
          already_exists = true
          break
        end
      end

      if not already_exists then
        table.insert(clamps, {direction = clamp_info.direction, tag = clamp_info.tag})
      end
    end

    -- Sort clamps by tags. We ignore direction because it makes it harder to find your clamp
    table.sort(clamps, function (a, b) return a.tag < b.tag end)

    -- Select the first tag if nothing selected yet
    if not record.spaceship_clamp.tag and clamps[1] then
      record.spaceship_clamp = clamps[1] -- The lingering reference is fine
      Util.update_tags(root, {record = record})
    end

    -- Display the tags
    local list_items = { } ---@type string[]
    for _, clamp in pairs(clamps) do
      local signal_name = SpaceshipClamp.signal_names_from_direction[clamp.direction][1]
      table.insert(list_items, "[img=virtual-signal/"..signal_name.."]  [font=heading-2][color=black]|[/color][/font]  "..clamp.tag)
    end
    spaceship_clamp_listbox.items = list_items
    util.update_tags(spaceship_clamp_listbox, { clamps = clamps })

    -- Try to select the current selection, or update current selection if no longer exists
    local found_selection = false
    if record.spaceship_clamp.tag then
      for index, clamp in pairs(clamps) do
        if record.spaceship_clamp.direction == clamp.direction and record.spaceship_clamp.tag == clamp.tag then
          found_selection = true
          spaceship_clamp_listbox.selected_index = index
          break
        end
      end
    end
    if not found_selection then
      -- The previous tag selection is no longer valid. Overwrite it
      record.spaceship_clamp.tag = nil
      if clamps[1] then
        spaceship_clamp_listbox.selected_index = 1
        record.spaceship_clamp = clamps[1] -- The lingering reference is fine
      end
      util.update_tags(root, {record = record})
    end

    -- If there's nothing in the list, then add a dummy entry to show what's up.
    if not clamps[1] then
      spaceship_clamp_listbox.items = { {"space-exploration.spaceship-scheduler-no-available-spaceship-clamps"} }
      spaceship_clamp_listbox.enabled = false
      spaceship_clamp_listbox.selected_index = 0
    end
  end

  -- Destination Clamp Tag ----------------------------------
  local destination_clamp_frame = Util.find_first_descendant_by_name(root, "destination_clamp_frame") --[[@cast destination_clamp_frame -? ]]
  local destination_clamp_listbox = Util.find_first_descendant_by_name(destination_clamp_frame, "destination-clamp-list-box") --[[@cast destination_clamp_listbox -? ]]
  if record.slingshot then
    destination_clamp_listbox.enabled = false
    destination_clamp_listbox.items = { }
  else
    destination_clamp_listbox.enabled = true

    if not destination_descriptor.clamp then
      destination_descriptor.clamp = { direction = core_util.oppositedirection(record.spaceship_clamp.direction) }
    end

    local tag_list = SpaceshipSchedulerReservations.get_all_tags_for_destination_descriptor(spaceship.force_name,
                                                                                            destination_descriptor,
                                                                                            SpaceshipScheduler.restricted_to_star_system(spaceship),
                                                                                            spaceship)
    table.sort(tag_list)
    destination_clamp_listbox.items = tag_list

    -- Try to select the current selection, or update current selection if no longer exists
    local found_selection = false
    if destination_descriptor.clamp.tag then
      for index, tag in pairs(tag_list) do
        if destination_descriptor.clamp.tag == tag then
          found_selection = true
          destination_clamp_listbox.selected_index = index
          break
        end
      end
    end
    if not found_selection then
      -- Zone or destination clamp changed, and the previous tag selection is no longer valid. Overwrite it
      destination_descriptor.clamp.tag = nil
      if #tag_list >= 1 then
        destination_clamp_listbox.selected_index = 1
        destination_descriptor.clamp.tag = tostring(tag_list[1])
      end
      util.update_tags(root, {record = record})
    end

    -- If there's nothing in the list, then add a dummy entry to show what's up.
    if not tag_list[1] then
      destination_clamp_listbox.items = { {"space-exploration.spaceship-scheduler-no-available-destination-clamps"} }
      destination_clamp_listbox.enabled = false
      destination_clamp_listbox.selected_index = 0
    end
  end

end

---@param player LuaPlayer
function SpaceshipSchedulerGUI.close_add_destination_popup(player)
  local root = player.gui.screen[SpaceshipSchedulerGUI.gui_destination_popup_root_name]
  if root then root.destroy() end
end

---@param event EventData.on_gui_click|EventData.on_gui_confirmed|EventData.on_gui_selection_state_changed|EventData.on_gui_switch_state_changed|EventData.on_gui_elem_changed|EventData.on_gui_checked_state_changed|EventData.on_gui_text_changed
---@param element LuaGuiElement
---@param root LuaGuiElement
local function on_gui_click_add_destination(event, element, root)
  local player = game.get_player(event.player_index) --[[@cast player -?]]

  local tags = root.tags
  if not (tags and tags.record and tags.spaceship_index) then SpaceshipSchedulerGUI.close_add_destination_popup(player) return end
  local record = tags.record --[[@as SpaceshipSchedulerRecord ]]
  local destination_descriptor = record.destination_descriptor
  local spaceship = Spaceship.from_index(tags.spaceship_index --[[@as integer]])
  if not spaceship then SpaceshipSchedulerGUI.close_add_destination_popup(player) return end

  if element.name == "cancel" then
    SpaceshipSchedulerGUI.close_add_destination_popup(player)


  elseif element.name == "confirm" then
    if record.slingshot then
      if not destination_descriptor.zone_pointer then
        player.create_local_flying_text{ text = {"space-exploration.spaceship-scheduler-slingshot-requires-zone"}, create_at_cursor = true }
        return
      end

      -- Clean up the record to only what we need
      record = {
        slingshot = true,
        destination_descriptor = {
          zone_pointer = destination_descriptor.zone_pointer,
        }
      }
    else
      if not destination_descriptor.zone_pointer then
        -- Make sure the selection was indeed "Any"
        local dropdown = Util.find_first_descendant_by_name(root, "destination-zone-dropdown") --[[@cast dropdown -?]]
        local selected_value = player_get_dropdown_value(player, dropdown.name, dropdown.selected_index)
        if not selected_value or not selected_value.type or selected_value.type ~= "any" then
          player.create_local_flying_text{ text = {"space-exploration.no_zone_found"}, create_at_cursor = true }
          return
        end
      end

      if not (record.spaceship_clamp and record.spaceship_clamp.tag) then
        player.create_local_flying_text{ text = {"space-exploration.spaceship-scheduler-need-spaceship-clamp"}, create_at_cursor = true }
        return
      elseif not destination_descriptor.clamp.tag then
        player.create_local_flying_text{ text = {"space-exploration.spaceship-scheduler-need-destination-clamp"}, create_at_cursor = true }
        return
      end
      if destination_descriptor.clamp.tag == "" then destination_descriptor.clamp.tag = nil end
    end

    if root.tags.for_interrupt then
      SpaceshipSchedulerGUI.add_new_target_to_interrupt(player, record)
    else
      SpaceshipScheduler.add_record_to_schedule_group(spaceship.force_name, spaceship.scheduler.schedule_group_name, record)
      SpaceshipSchedulerGUI.rebuild(spaceship)
    end
    SpaceshipSchedulerGUI.close_add_destination_popup(player)


  elseif element.name == "spaceship-clamp-list-box" then
    if event.name ~= defines.events.on_gui_selection_state_changed then return end
    if element.selected_index == 0 or not element.enabled then -- Listboxes don't really respect enabled
      record.spaceship_clamp = nil
    else
      record.spaceship_clamp = element.tags.clamps[element.selected_index]
    end

    -- If this changes the direction to be incompatible with a current selected destination clamp
    -- then we need to invalidate the selection so the GUI can refresh it.
    if
      record.spaceship_clamp and
      destination_descriptor.clamp and
      destination_descriptor.clamp.direction == record.spaceship_clamp.direction
    then
      destination_descriptor.clamp = nil
    end

    util.update_tags(root, {record = record})
    SpaceshipSchedulerGUI.update_add_destination_popup(player) -- To update destination clamps


  elseif element.name == "destination-clamp-list-box" then
    if event.name ~= defines.events.on_gui_selection_state_changed then return end
    if element.selected_index == 0 or not element.enabled then -- Listboxes don't really respect enabled
      destination_descriptor.clamp.tag = nil
    else
      destination_descriptor.clamp.tag = tostring(element.items[element.selected_index])
    end
    util.update_tags(root, {record = record})
    SpaceshipSchedulerGUI.update_add_destination_popup(player)


  elseif element.name == "destination-zone-dropdown" and event.name == defines.events.on_gui_selection_state_changed then
    local value = player_get_dropdown_value(player, element.name, element.selected_index)
    if type(value) == "table" then
      if value.type == "any" then
        destination_descriptor.zone_pointer = nil
      elseif value.type == "zone" then
        local zone = Zone.from_zone_index(value.index)
        if not zone then return end
        destination_descriptor.zone_pointer = zone.index
      end
      util.update_tags(root, {record = record})
      SpaceshipSchedulerGUI.update_popup_zone_dropdown_values(root, player, spaceship, record)
      SpaceshipSchedulerGUI.update_add_destination_popup(player)
    else
      SpaceshipSchedulerGUI.close_add_destination_popup(player)
    end


  elseif element.name == "enable-slingshot" then
    record.slingshot = element.state
    record.spaceship_clamp = nil
    record.destination_descriptor = { zone_pointer=  record.destination_descriptor.zone_pointer }
    util.update_tags(root, {record = record})
    SpaceshipSchedulerGUI.update_add_destination_popup(player)
    SpaceshipSchedulerGUI.update_popup_zone_dropdown_values(root, player, spaceship, record)


  elseif element.name == "list-zones-alphabetical" then
    if event.name ~= defines.events.on_gui_checked_state_changed then return end
    local playerdata = get_make_playerdata(player)
    playerdata.zones_alphabetical = element.state
    SpaceshipSchedulerGUI.update_popup_zone_dropdown_values(root, player, spaceship, record)


  elseif element.name == GuiCommon.filter_textfield_name then
    if event.name ~= defines.events.on_gui_text_changed then return end
    SpaceshipSchedulerGUI.update_popup_zone_dropdown_values(root, player, spaceship, record)


  elseif element.name == GuiCommon.filter_clear_name then
    element.parent[GuiCommon.filter_textfield_name].text = ""
    SpaceshipSchedulerGUI.update_popup_zone_dropdown_values(root, player, spaceship, record)


  end
end

------------------------------------------------
-- ADD/EDIT INTERRUPT POPUP
------------------------------------------------

---@param force_name string
---@param interrupt_name string
---@param filter string?
---@return string[] list
---@return uint? selected_index
---@return string[] values
local function get_interrupt_names_dropdown_values(force_name, interrupt_name, filter)
  local names = storage.spaceship_scheduler_interrupts[force_name]

  local list = {} -- names with optional [count]
  local values = {} -- raw names
  local selected_index
  local list_value_pairs = {} -- Keep them together for sorting
  local found_current_name = false

  if names then
    for name, interrupt in pairs(names) do
      if (not filter) or string.find(string.lower(name), string.lower(filter), 1, true) then
        local count = table_size(interrupt.schedules)
        local display_name = name .. " [font=default-bold][color=34,181,255]["..count.."][/color][/font]"
        table.insert(list_value_pairs, {display_name, name})

        if name == interrupt_name then found_current_name = true end
      end
    end

    table.sort(list_value_pairs, function(a,b) return a[1] < b[1] end)

    if not found_current_name then
      -- Empty top index so that the player needs to explictly select a different interrupt
      table.insert(list_value_pairs, 1, {"", ""})
    end

    for i, list_value_pair in pairs(list_value_pairs) do
      table.insert(list, list_value_pair[1])
      table.insert(values, list_value_pair[2])
      if list_value_pair[2] == interrupt_name then
        selected_index = i
      end
    end
  end
  if #list > 1 and not selected_index then selected_index = 1 end
  return list, selected_index, values
end

---@param root LuaGuiElement
---@param player LuaPlayer
---@param interrupt_name string the current interrupt name selected
---@param spaceship SpaceshipType
function SpaceshipSchedulerGUI.update_interrupt_names_dropdown_values(root, player, interrupt_name, spaceship)
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.rename_textfield_name)
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end
  local list, selected_index, values = get_interrupt_names_dropdown_values(spaceship.force_name, interrupt_name, filter)
  local list_names = Util.find_first_descendant_by_name(root, SpaceshipSchedulerGUI.gui_interrupt_name_dropdown)
  list_names.items = list
  list_names.selected_index = selected_index or 1
  player_set_dropdown_values(player, SpaceshipSchedulerGUI.gui_interrupt_name_dropdown, values)
end

---@param subheader LuaGuiElement where it should be added
---@param player LuaPlayer
---@param current_interrupt_name string
---@param tags table to add to all interactible elements
---@param editable boolean if this is the editable version or not
---@param spaceship SpaceshipType
local function make_change_interrupt_name_flow(subheader, player, current_interrupt_name, tags, editable, spaceship)
  subheader.clear()

  if editable then
    local frame_dark = subheader.add{ index=1, type="frame",
      name = SpaceshipSchedulerGUI.gui_interrupt_name_frame,
      direction = "vertical",
      style = "space_platform_subheader_frame"
    }
    frame_dark.style.vertically_stretchable = true
    local name_flow = frame_dark.add{
      type = "flow",
      name = SpaceshipSchedulerGUI.gui_interrupt_name_flow,
      direction = "horizontal",
    }

    GuiCommon.create_rename_textfield(name_flow, current_interrupt_name, tags)
    name_flow.add{ type = "sprite-button", name = "rename-cancel", sprite = "utility/close",
      tooltip = { "gui.cancel" }, mouse_button_filter = { "left" }, style = "tool_button_red", tags = tags,
    }
    name_flow.add {
      type = "sprite-button",
      name = "change-interrupt-name-confirm",
      sprite = "utility/enter",
      tooltip = {"space-exploration.rename-confirm"},
      style = "item_and_count_select_confirm",
      tags = tags
    }
    local list, selected_index, values = get_interrupt_names_dropdown_values(spaceship.force_name, current_interrupt_name)
    local dropdown = frame_dark.add{
      type = "drop-down",
      name = SpaceshipSchedulerGUI.gui_interrupt_name_dropdown,
      items = list,
      selected_index = selected_index,
      tags = tags,
    }
    dropdown.style.horizontally_stretchable = true
    player_set_dropdown_values(player, SpaceshipSchedulerGUI.gui_interrupt_name_dropdown, values)

  else

    local interrupt = storage.spaceship_scheduler_interrupts[spaceship.force_name][current_interrupt_name]
    local count = 0
    local schedule_list = ""
    for schedule_name, _ in pairs(interrupt and interrupt.schedules or { }) do
      count = count + 1
      schedule_list = schedule_list.."\n\t"..schedule_name
    end
    local used_in_tooltip = {"", {"space-exploration.spaceship-scheduler-interrupt-used-in-schedules", count}, schedule_list}

    subheader.style.height = 32
    subheader.add{type = "label", caption = {"", {"space-exploration.spaceship-scheduler-interrupt-name"}, "[img=info]:"}, tooltip=used_in_tooltip, style="se_relative_properties_label"}
    subheader.add{type = "label", caption = current_interrupt_name, tooltip=used_in_tooltip, style="heading_3_label"}
    subheader.add{ type = "sprite-button", name = "change-interrupt-name", sprite = "utility/rename_icon",
      tooltip = { "space-exploration.rename-something", {"space-exploration.spaceship-scheduler-interrupt"} }, mouse_button_filter = { "left" }, style = "frame_action_button",
      tags = { root_name=SpaceshipSchedulerGUI.gui_interrupt_popup_root_name }
    }
  end
end

---Open the GUI that adds an interrupt or edits an existing one. The state of the GUI will be stored
---in the root-tags. That means editing an existing interrupt will only apply it's changes once
---the "save interrupt" button is clicked, which is more intuitive for the player.
---@param player LuaPlayer
---@param spaceship SpaceshipType will not modify spaceship directly, but it's group instead
---@param interrupt_name string? if we are editing an existing interrupt
---@param args {original_interrupt_name:string?, suppress_original_interrupt_name:boolean?}? optional arguments
function SpaceshipSchedulerGUI.open_interrupt_popup(player, spaceship, interrupt_name, args)
  SpaceshipSchedulerGUI.close_interrupt_popup(player)

  local original_interrupt_name = (args and args.original_interrupt_name) or interrupt_name
  if args and args.suppress_original_interrupt_name then original_interrupt_name = nil end

  local interrupt
  if interrupt_name then
    interrupt = storage.spaceship_scheduler_interrupts[spaceship.force_name][interrupt_name]
  else
    interrupt = SpaceshipScheduler.create_interrupt()
    interrupt_name = SpaceshipScheduler.find_unique_interrupt_name(spaceship.force_name)
  end
  assert(interrupt)

  local schedule_group_name = spaceship.scheduler.schedule_group_name
  local root = player.gui.screen.add{type="frame", name=SpaceshipSchedulerGUI.gui_interrupt_popup_root_name, direction="vertical",
    tags = {
      spaceship_index = spaceship.index,
      schedule_group_name = schedule_group_name,
      interrupt_name = interrupt_name,
      original_interrupt_name = original_interrupt_name, ---@diagnostic disable-line: assign-type-mismatch
      interrupt = interrupt,
    }
  }

  tags = { root_name = SpaceshipSchedulerGUI.gui_interrupt_popup_root_name } -- To add to all interactible elements

  -- Title Bar
  -----------------------------------------------------------
  local title = original_interrupt_name and {"space-exploration.spaceship-scheduler-edit-interrupt"} or {"space-exploration.spaceship-scheduler-add-interrupt"}
  local title_bar = root.add{type="flow", style="se_relative_titlebar_flow"}
  title_bar.drag_target = root
  title_bar.add{type="label", style="frame_title", caption=title, ignored_by_interaction=true}
  title_bar.add{type="empty-widget", style = "se_titlebar_drag_handle", ignored_by_interaction=true}
  title_bar.add{type="sprite-button", name="exit", style="frame_action_button", sprite="utility/close",
  hovered_sprite="utility/close_black", clicked_sprite="utility/close_black", mouse_button_filter={"left"}, tags = tags}

  local subheader_root = root.add{type = "frame", direction = "vertical", style = "inside_deep_frame"}
  local subheader = subheader_root.add{type = "frame", name="subheader", style = "se_stretchable_subheader_frame", direction = "horizontal"}
  make_change_interrupt_name_flow(subheader, player, interrupt_name, tags, false, spaceship)

  local body = subheader_root.add{type="frame", direction="vertical", style="window_content_frame_packed"}
  body.style.padding = {0, 12, 12, 12}
  body.style.horizontally_stretchable = true

  -- Conditions
  -----------------------------------------------------------
  body.add{type = "label", caption = {"space-exploration.spaceship-scheduler-conditions"}, style="heading_3_label"}.style.padding = {8, 8, 8, 8}
  local conditions_frame = body.add{type = "frame", direction = "vertical", style = "deep_frame_in_shallow_frame"}
      .add{type = "scroll-pane", style = "se_spaceship_scheduler_records_scroll_pane"}
  conditions_frame.style.width = main_gui_width
  local conditions_container = conditions_frame.add{type = "flow", name = "conditions-container", direction = "horizontal"}
  conditions_container.style.horizontal_spacing = 0
  conditions_container.style.padding = 0

  local and_or = conditions_container.add{type = "flow", name = "and_or", direction = "vertical"}
  and_or.style.top_padding = 20
  and_or.style.width = 92

  local conditions_flow = conditions_container.add{type = "flow", name = "conditions", direction = "vertical"}
  conditions_flow.style.vertical_spacing = 0

  local list = conditions_flow.add{type = "flow", name = "list", direction = "vertical"}
  list.style.vertical_spacing = 0

  for _, condition in pairs(interrupt.conditions or {}) do
    create_condition_element(conditions_container, condition, tags)
  end

  local add_condition = conditions_flow.add{ type = "drop-down", name = "add-condition", items = {{"gui-train.add-circuit-condition"}}, tags = tags}
  add_condition.style.width = main_gui_width - 112
  add_condition.style.height = 36

  -- THIS IS INCREDIBLY CURSED!!! DO NOT ADD CHILDREN TO NON-CONTAINER ELEMENTS!!! (Except here I guess...)
  local label = add_condition.add{type = "flow", ignored_by_interaction = true}
    .add{type = "label", style = "heading_3_label", caption = {"space-exploration.spaceship-scheduler-add-interrupt-condition"}}
  label.style.top_margin = 4
  label.style.font_color = {} -- black

  -- Targets
  -----------------------------------------------------------

  body.add{type = "label", caption = {"space-exploration.spaceship-scheduler-targets"}, style="heading_3_label"}.style.padding = {8, 8, 8, 8}
  local targets_frame = body.add{type = "frame", direction = "vertical", style = "deep_frame_in_shallow_frame"
    }.add{type = "scroll-pane", style = "se_spaceship_scheduler_records_scroll_pane"}
  targets_frame.style.width = main_gui_width
  local targets_container = targets_frame.add{type = "flow", direction = "vertical"}
  targets_container.style.vertical_spacing = 0
  local targets_flow = targets_container.add{type = "flow", name = "targets", direction = "vertical"}
  targets_flow.style.vertical_spacing = 0

  for _, target in pairs(interrupt.targets or {}) do
    create_record_element(targets_flow, target, -1, false, false, core_util.merge{tags, {is_target = true}})
  end

  local add_target = targets_container.add{ type = "button", name = "add-target", caption = {"space-exploration.spaceship-scheduler-add-target"}, tags = tags }
  add_target.style.width = main_gui_width - 20
  add_target.style.height = 36
  add_target.style.horizontal_align = "left"
  add_target.style.top_margin = 4
  add_target.style.font_color = {} -- black


  -- Bottom Buttons
  -----------------------------------------------------------
  local buttons_flow = root.add{type="flow", direction="horizontal", style = "dialog_buttons_horizontal_flow"}
  local empty = buttons_flow.add{type="empty-widget"}
  empty.style.horizontally_stretchable = true
  local button_name = {"space-exploration."..(interrupt_name and "spaceship-scheduler-save-interrupt" or "spaceship-scheduler-add-interrupt")}
  buttons_flow.add{type="sprite-button", name="confirm", caption=button_name, style="confirm_button_without_tooltip", mouse_button_filter={"left"}, tags = tags }

  root.force_auto_center()
end

---@param player LuaPlayer
function SpaceshipSchedulerGUI.close_interrupt_popup(player)
  local root = player.gui.screen[SpaceshipSchedulerGUI.gui_interrupt_popup_root_name]
  if root then root.destroy() end
end

---This function is called from the add destination gui after
---a new target/destination/record has been configured.
---@param player LuaPlayer
---@param record SpaceshipSchedulerRecord
function SpaceshipSchedulerGUI.add_new_target_to_interrupt(player, record)
  local root = player.gui.screen[SpaceshipSchedulerGUI.gui_interrupt_popup_root_name]
  if not root then return end -- Something went wrong. Player should have this GUI open.

  -- Add the target
  local interrupt = root.tags.interrupt --[[@as SpaceshipSchedulerInterrupt ]]
  table.insert(interrupt.targets, record) -- Allways appended at the end
  util.update_tags(root, {interrupt = interrupt})

  -- Add it to this GUI
  local targets = Util.find_first_descendant_by_name(root, "targets") --[[@cast targets -? ]]
  create_record_element(targets, record, -1, false, false, {
    root_name = SpaceshipSchedulerGUI.gui_interrupt_popup_root_name,
    is_target = true,
  })
end

---@param event EventData.on_gui_click|EventData.on_gui_confirmed|EventData.on_gui_selection_state_changed|EventData.on_gui_switch_state_changed|EventData.on_gui_elem_changed|EventData.on_gui_checked_state_changed|EventData.on_gui_text_changed
---@param element LuaGuiElement
---@param root LuaGuiElement
local function on_gui_click_interrupt(event, element, root)
  local player = game.get_player(event.player_index) --[[@cast player -?]]
  local element_name = element.name

  -- Unpack data from tags
  local original_interrupt_name = root.tags.original_interrupt_name --[[@as string? ]]
  local editing_existing = original_interrupt_name ~= nil
  local schedule_group_name = root.tags.schedule_group_name --[[@as string]]
  local interrupt_name = root.tags.interrupt_name --[[@as string ]]
  local interrupt = root.tags.interrupt --[[@as SpaceshipSchedulerInterrupt]]
  local spaceship = storage.spaceships[root.tags.spaceship_index] --[[@as SpaceshipType? ]]
  if not spaceship then SpaceshipSchedulerGUI.close_interrupt_popup(player) return end
  assert(interrupt and schedule_group_name and interrupt_name)
  local is_target = element.tags.is_target --[[@as boolean? is this condition in the conditions or targets section?]]

  ---@param flow LuaGuiElement
  ---@return uint time in ticks
  local function set_time(flow)
    flow.time_textfield.visible = false
    flow.time_confirm.visible = false
    flow.time_button.visible = true
    local text = flow.time_textfield.text
    if text == "" then text = "0" end
    local ticks = tonumber(text) * 60
    flow.time_button.caption = text .. " s"
    return ticks
  end

  ---@param flow LuaGuiElement
  ---@return uint integer
  local function set_constant(flow)
    flow.constant_textfield.visible = false
    flow.constant_confirm.visible = false
    flow.constant_button.visible = true
    local constant = util.number_from_string(flow.constant_textfield.text)
    flow.constant_button.caption = core_util.format_number(constant, true)
    return constant --[[@as integer ]]
  end

  if element_name == "exit" then
    SpaceshipSchedulerGUI.close_interrupt_popup(player)


  elseif element_name == "add-condition" then
    if event.name ~= defines.events.on_gui_selection_state_changed then return end

    local selected = element.get_item(element.selected_index) --[[@cast selected -? ]]
    local is_time = string.find(selected[1] --[[@as string]], "circuit") == nil
    local condition = {
      type = is_time and "time" or "circuit",
      compare_type = "and",
      ticks = is_time and default_wait_condition_time or nil,
      condition = (not is_time) and {
        comparator = "<",
        constant = 0, -- Default to comparing to a constant and not a signal, which would be more common
      } or nil,
    } --[[@as WaitCondition]]

    local conditions_container
    if is_target then
      local record_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      interrupt.targets[record_index].wait_conditions = interrupt.targets[record_index].wait_conditions or { }
      table.insert(interrupt.targets[record_index].wait_conditions, condition)
    else
      table.insert(interrupt.conditions, condition)
    end
    util.update_tags(root, {interrupt = interrupt})
    conditions_container = element.parent.parent --[[@as LuaGuiElement]]
    create_condition_element(conditions_container, condition, element.tags)
    element.selected_index = 0


  elseif element_name == "condition-move-up" then
    local condition_frame = element.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()
    if condition_index == 1 then return end

    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end

    ---@cast conditions -?
    Util.swap_elements(conditions, condition_index, condition_index - 1)
    util.update_tags(root, {interrupt = interrupt})

    local and_or = condition_frame.parent.parent.parent.and_or
    condition_frame.parent.swap_children(condition_index, condition_index - 1)
    and_or.swap_children(condition_index, condition_index - 1)

    and_or.children[1].visible = false
    local second = and_or.children[2]
    if second then second.visible = true end


  elseif element_name == "condition-move-down" then
    local condition_frame = element.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?

    if condition_index >= #conditions then return end
    Util.swap_elements(conditions, condition_index, condition_index + 1)
    util.update_tags(root, {interrupt = interrupt})

    local and_or = condition_frame.parent.parent.parent.and_or
    condition_frame.parent.swap_children(condition_index, condition_index + 1)
    and_or.swap_children(condition_index, condition_index + 1)

    and_or.children[1].visible = false
    local second = and_or.children[2]
    if second then second.visible = true end


  elseif element_name == "remove-wait-condition" then
    local condition_frame = element.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?

    table.remove(conditions, condition_index)
    util.update_tags(root, {interrupt = interrupt})

    local and_or = element.parent.parent.parent.parent.and_or
    and_or.children[condition_index].destroy()
    if and_or.children[1] then
      and_or.children[1].visible = false
    end
    element.parent.destroy()


  elseif element_name == "and-or-button" then
    local and_or_frame = element.parent --[[@as LuaGuiElement]]
    local condition_index = and_or_frame.get_index_in_parent()

    local conditions
    if is_target then
      local record_frame = and_or_frame.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?

    local condition = conditions[condition_index]
    condition.compare_type = condition.compare_type == "and" and "or" or "and"
    util.update_tags(root, {interrupt = interrupt})

    -- I decided to not care about shifting ORs over if there are no ANDs, since it would involve touching a bunch of elements
    -- you can also just redraw the whole station in the schedule if you wanted to do that. - _CodeGreen
    if condition.compare_type == "and" then
      and_or_frame.style.left_margin = 24
      element.caption = {"gui-train-wait-condition-description.and"}
    else
      and_or_frame.style.left_margin = 0
      element.caption = {"gui-train-wait-condition-description.or"}
    end


  elseif element_name == "circuit_swap" then -- Switches between comparing with constant or signal
    local condition_frame = element.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?

    local circuit_condition = conditions[condition_index].condition --[[@cast circuit_condition -? ]]

    local condition_flow = element.parent.circuit_condition
    if circuit_condition.constant == nil then
      element.caption = {"space-exploration.constant"}
      circuit_condition.second_signal = nil
      circuit_condition.constant = 0
      condition_flow.second_signal.visible = false
      condition_flow.constant_button.visible = true
    else
      element.caption = {"gui-train.circuit"}
      circuit_condition.second_signal = nil
      circuit_condition.constant = nil
      condition_flow.second_signal.elem_value = nil
      condition_flow.second_signal.visible = true
      condition_flow.constant_button.visible = false
      condition_flow.constant_button.caption = "0"
      condition_flow.constant_textfield.visible = false
      condition_flow.constant_confirm.visible = false
    end

    util.update_tags(root, {interrupt = interrupt})


  elseif element_name == "time_button" then
    local input_flow = element.parent --[[@as LuaGuiElement]]
    element.visible = false
    input_flow.time_textfield.visible = true
    input_flow.time_confirm.visible = true
    input_flow.time_textfield.focus()
    input_flow.time_textfield.select_all()


  elseif element_name == "time_confirm" or (element_name == "time_textfield" and event.name == defines.events.on_gui_confirmed) then
    local condition_frame = element.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?

    conditions[condition_index].ticks = set_time(element.parent)
    util.update_tags(root, {interrupt = interrupt})


  elseif element_name == "constant_button" then
    local input_flow = element.parent --[[@as LuaGuiElement]]
    element.visible = false
    input_flow.constant_textfield.visible = true
    input_flow.constant_confirm.visible = true

    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()
    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?
    local condition = conditions[condition_index]

    input_flow.constant_textfield.text = tostring(condition.condition.constant or 0)
    input_flow.constant_textfield.focus()
    input_flow.constant_textfield.select_all()

  elseif element_name == "constant_confirm" or (element_name == "constant_textfield" and event.name == defines.events.on_gui_confirmed) then
    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?

    local condition = conditions[condition_index]
    local constant = set_constant(element.parent)

    condition.condition = condition.condition or { }
    condition.condition.constant = constant
    util.update_tags(root, {interrupt = interrupt})


  elseif element_name == "first_signal" then
    if event.name ~= defines.events.on_gui_elem_changed then return end
    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?

    local circuit_condition = conditions[condition_index].condition
    circuit_condition.first_signal = element.elem_value --[[@as SignalID ]]
    util.update_tags(root, {interrupt = interrupt})


  elseif element_name == "second_signal" then
    if event.name ~= defines.events.on_gui_elem_changed then return end
    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?

    local circuit_condition = conditions[condition_index].condition
    circuit_condition.second_signal = element.elem_value --[[@as SignalID ]]
    util.update_tags(root, {interrupt = interrupt})


  elseif element_name == "circuit-comparator" then
    if event.name ~= defines.events.on_gui_selection_state_changed then return end
    local condition_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local condition_index = condition_frame.get_index_in_parent()

    local conditions
    if is_target then
      local record_frame = condition_frame.parent.parent.parent.parent --[[@as LuaGuiElement]]
      local record_index = record_frame.get_index_in_parent()
      conditions = interrupt.targets[record_index].wait_conditions
    else
      conditions = interrupt.conditions
    end
    ---@cast conditions -?

    local circuit_condition = conditions[condition_index].condition
    circuit_condition.comparator = element.get_item(element.selected_index) --[[@as string ]]
    util.update_tags(root, {interrupt = interrupt})


  elseif element_name == "confirm" then

    if not next(interrupt.conditions) then
      player.create_local_flying_text{text = {"space-exploration.spaceship-scheduler-interrupt-need-at-least-one-condition"}, create_at_cursor = true }
      return
    elseif not next(interrupt.targets) then
      player.create_local_flying_text{text = {"space-exploration.spaceship-scheduler-interrupt-need-at-least-one-target"}, create_at_cursor = true }
      return
    end

    -- This could use a proper error message at some point, when someone actually somehow reaches this limit.
    -- This is important because the iteration through triggered interrupts is based on insertion order
    -- which is only sequential in Factorio with less than 1024 elements.
    assert(table_size(interrupt.targets) < 1024, "Interrupts can only have a maximum of 1024 targets")

    -- Update the stored interrupt (or create it if it was destroyed in the mean time)
    local interrupts = storage.spaceship_scheduler_interrupts[spaceship.force_name]
    if not interrupts[interrupt_name] then
      interrupts[interrupt_name] = SpaceshipScheduler.create_interrupt(interrupt)
    else
      interrupts[interrupt_name] = interrupt
    end

    if editing_existing then

      if interrupt_name ~= original_interrupt_name then
        -- If we changed the name then we will change the name only in the schedule group that we were editing,
        -- and the original interrupt will still exist
        SpaceshipScheduler.change_interrupt_name_in_schedule(spaceship.force_name,
                                                             original_interrupt_name or interrupt_name,
                                                             interrupt_name,
                                                             schedule_group_name)
      end

    else
      -- We were creating a new interrupt. This will only work if it
      -- doesn't exist yet
      assert(interrupt and interrupt_name)

      -- New interrupt is created. Now add it to the scheduler group
      SpaceshipScheduler.add_interrupt_to_schedule_group(spaceship.force_name, schedule_group_name, interrupt_name)

    end

    SpaceshipSchedulerGUI.rebuild(spaceship) -- Will rebuild it for all players
    SpaceshipSchedulerGUI.close_interrupt_popup(player)


  elseif element_name == SpaceshipSchedulerGUI.gui_interrupt_name_dropdown then
    if event.name ~= defines.events.on_gui_selection_state_changed then return end
    interrupt_name = player_get_dropdown_value(player, SpaceshipSchedulerGUI.gui_interrupt_name_dropdown, element.selected_index)
    local textfield = Util.find_first_descendant_by_name(element.parent, GuiCommon.rename_textfield_name) --[[@cast textfield -? ]]
    textfield.text = interrupt_name


  elseif element_name == GuiCommon.rename_textfield_name and event.name == defines.events.on_gui_text_changed then
    SpaceshipSchedulerGUI.update_interrupt_names_dropdown_values(root, player, interrupt_name, spaceship)


  elseif element_name == "change-interrupt-name" then
    local subheader = element.parent --[[@cast subheader -? ]]
    subheader.style.height = 80
    make_change_interrupt_name_flow(subheader, player, interrupt_name, element.tags, true, spaceship)


  elseif element_name == "change-interrupt-name-confirm" or (element_name == GuiCommon.rename_textfield_name and event.name == defines.events.on_gui_confirmed) then

    local new_interrupt_name = string.trim(event.element.parent[GuiCommon.rename_textfield_name].text)
    if new_interrupt_name ~= "" then
      local do_complete_rebuild = false
      if new_interrupt_name ~= interrupt_name then

        if string.len(new_interrupt_name) > SpaceshipScheduler.max_name_length then
          player.print({"space-exploration.spaceship-scheduler-interrupt-name-too-long", SpaceshipScheduler.max_name_length})
          return
        end

        -- If the new name already exist then we treat this like selecting a different interrupt
        local interrupts = storage.spaceship_scheduler_interrupts[spaceship.force_name]
        if interrupts[new_interrupt_name] then
          do_complete_rebuild = true
          interrupt = interrupts[new_interrupt_name]
        end

        interrupt_name = new_interrupt_name
        util.update_tags(root, {interrupt_name = interrupt_name, interrupt = interrupt})

      end

      if do_complete_rebuild then
        SpaceshipSchedulerGUI.open_interrupt_popup(player, spaceship, interrupt_name, {
          original_interrupt_name = original_interrupt_name, -- Should be nil if not editing interrupt
          suppress_original_interrupt_name = not original_interrupt_name
        }) -- Rebuild GUI
      else
        local subheader = element.parent.parent.parent --[[@cast subheader -? ]]
        make_change_interrupt_name_flow(subheader, player, interrupt_name, element.tags, false, spaceship)
      end
    end


  elseif element_name == "rename-cancel" then
    local subheader = element.parent.parent.parent --[[@cast subheader -? ]]
    make_change_interrupt_name_flow(subheader, player, interrupt_name, element.tags, false, spaceship)


  elseif element_name == "add-target" then
    SpaceshipSchedulerGUI.open_add_destination_popup(player, spaceship, true)


  elseif element_name == "record-move-up" then
    local record_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local record_index = record_frame.get_index_in_parent()
    if record_index == 1 then return end
    Util.swap_elements(interrupt.targets, record_index, record_index - 1)
    record_frame.parent.swap_children(record_index, record_index - 1)
    util.update_tags(root, {interrupt = interrupt})


  elseif element_name == "record-move-down" then
    local record_frame = element.parent.parent.parent --[[@as LuaGuiElement]]
    local record_index = record_frame.get_index_in_parent()
    if record_index == #interrupt.targets then return end
    Util.swap_elements(interrupt.targets, record_index, record_index + 1)
    record_frame.parent.swap_children(record_index, record_index + 1)
    util.update_tags(root, {interrupt = interrupt})


  elseif element_name == "remove_record" then
    local record_frame = element.parent.parent --[[@as LuaGuiElement]]
    local record_index = record_frame.get_index_in_parent()
    table.remove(interrupt.targets, record_index)
    util.update_tags(root, {interrupt = interrupt})
    record_frame.destroy()


  end
end

------------------------------------------------
-- EVENTS
------------------------------------------------
---@TODO Add focus search for zone selector. Nice

---@param event EventData.on_forces_merging
local function on_forces_merging(event)
  for _, player in pairs(event.source.players) do
    SpaceshipSchedulerGUI.close(player)
  end
  for _, player in pairs(event.destination.players) do
    SpaceshipSchedulerGUI.close(player)
  end
end
Event.addListener(defines.events.on_forces_merging, on_forces_merging)

---This handler will redirect events to the appropriate gui handlers
---for the different windows, depending on the tags.
---@param event EventData.on_gui_click|EventData.on_gui_confirmed|EventData.on_gui_selection_state_changed|EventData.on_gui_switch_state_changed|EventData.on_gui_elem_changed|EventData.on_gui_checked_state_changed|EventData.on_gui_text_changed
local function on_gui_event(event)
  local element = event.element
  if not (element and element.valid) then return end
  local tags = element.tags
  if not (tags and tags.root_name) then return end
  local root_name = tags.root_name --[[@as string]]

  -- Direct the handler to the correct GUI
  if root_name == SpaceshipSchedulerGUI.gui_main_root_name then
    local root = gui_element_or_parent(element, root_name)
    if not root then return end
    on_main_gui_event(event, element, root)
  elseif root_name == SpaceshipSchedulerGUI.gui_destination_popup_root_name then
    local root = gui_element_or_parent(element, root_name)
    if not root then return end
    on_gui_click_add_destination(event, element, root)
  elseif root_name == SpaceshipSchedulerGUI.gui_interrupt_popup_root_name then
    local root = gui_element_or_parent(element, root_name)
    if not root then return end
    on_gui_click_interrupt(event, element, root)
  end
end
Event.addListener(defines.events.on_gui_click, on_gui_event)
Event.addListener(defines.events.on_gui_confirmed, on_gui_event)
Event.addListener(defines.events.on_gui_selection_state_changed, on_gui_event)
Event.addListener(defines.events.on_gui_switch_state_changed, on_gui_event)
Event.addListener(defines.events.on_gui_elem_changed, on_gui_event)
Event.addListener(defines.events.on_gui_checked_state_changed, on_gui_event)
Event.addListener(defines.events.on_gui_text_changed, on_gui_event)

local function on_nth_tick_60()
  for _, player in pairs(game.connected_players) do
    SpaceshipSchedulerGUI.update(player)
  end
end
Event.addListener("on_nth_tick_60", on_nth_tick_60)

---Handles GUI closed events. Can also be used to close the GUI manually
local function close_gui(event)
  if (event.entity and event.entity.valid and event.entity.name == Spaceship.name_spaceship_console) then
    return -- Don't close when when opening another spaceship console
  end

  local player = game.players[event.player_index] --[[@cast player -?]]
  SpaceshipSchedulerGUI.close(player) -- Will also close interrupt and add-destination GUIs
end
Event.addListener(defines.events.on_gui_closed, close_gui)

---@TODO Close GUIs for all players that leave, and on config changed

return SpaceshipSchedulerGUI
