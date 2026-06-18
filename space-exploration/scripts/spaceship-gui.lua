local SpaceshipGUI = {}

SpaceshipGUI.name_spaceship_gui_root = mod_prefix.."spaceship-gui"
SpaceshipGUI.name_window_close = "spaceship_close_button"

---@param player LuaPlayer
---@param spaceship SpaceshipType
---@param flow LuaGuiElement
---@param name string
function SpaceshipGUI.gui_open_panel(player, spaceship, flow, name)
  if name == "integrity" then
    SpaceshipGUI.gui_open_panel_integrity(player, spaceship, flow)
  elseif name == "speed" then
    SpaceshipGUI.gui_open_panel_speed(player, spaceship, flow)
  elseif name == "position" then
    SpaceshipGUI.gui_open_panel_position(player, spaceship, flow)
  elseif name == "destination" then
    SpaceshipGUI.gui_open_panel_destination(player, spaceship, flow)
  else
    Log.debug('SpaceshipGUI.gui_open_panel invalid name '..name)
  end
end

---@param player LuaPlayer unused
---@param spaceship SpaceshipType unused
---@param flow_integrity LuaGuiElement
function SpaceshipGUI.gui_open_panel_integrity(player, spaceship, flow_integrity)
  if flow_integrity['panel_integrity'] then return end

  local panel_integrity = flow_integrity.add{ type="frame", name="panel_integrity", direction="vertical", style="b_inner_frame"}
  panel_integrity.style.horizontally_stretchable = true

  panel_integrity.add{type="progressbar", name="structural_integrity_progress", size=300, value=0, caption={"space-exploration.spaceship-structural-stress-structure", ""}, style="spaceship_progressbar_integrity"}

  panel_integrity.add{type="progressbar", name="container_integrity_progress", size=300, value=0, caption={"space-exploration.spaceship-structural-stress-container", ""}, style="spaceship_progressbar_integrity"}

  local flow = panel_integrity.add{type = "flow", name = "check-flow", direction = "horizontal"}
  flow.style.horizontally_stretchable = true
  flow.style.vertical_align = "center"
  flow.style.top_padding = 4
  flow.add{ type="button", name="start-integrity-check", caption={"space-exploration.spaceship-button-start-integrity-check"}}.style.right_margin = 8
  flow.add{ type="label", name="integrity-status", caption="", style="se_spaceship_integrity_status_label"}
end

---@param player LuaPlayer unused
---@param spaceship SpaceshipType
---@param flow_speed LuaGuiElement
function SpaceshipGUI.gui_open_panel_speed(player, spaceship, flow_speed)
  if flow_speed['panel_speed'] then return end

  local panel_speed = flow_speed.add{ type="frame", name="panel_speed", direction="vertical", style="b_inner_frame"}
  panel_speed.style.horizontally_stretchable = true

  local target_speed_flow = panel_speed.add{ type="flow", name="target-speed-flow"}
  local label = target_speed_flow.add{type="label", name="target-speed-label", caption={"space-exploration.spaceship-target-speed"}}
  local target_speed_control_flow = panel_speed.add{ type="flow", name="target-speed-control-flow"}

  local textfield

  local normal_flow = target_speed_control_flow.add{type="flow", name="target-speed-normal-flow", direction="horizontal",
    tooltip={"space-exploration.spaceship-target-speed-normal-tooltip", SpaceshipObstacles.default_asteroid_density*100}}
  normal_flow.add{type="sprite", sprite="virtual-signal/se-star",
    tooltip={"space-exploration.spaceship-target-speed-normal-tooltip", SpaceshipObstacles.default_asteroid_density*100}}
  normal_flow.style.left_margin = 5
  textfield = normal_flow.add{type="textfield", name="normal-speed-textfield", numeric="true",
    tooltip={"space-exploration.spaceship-target-speed-normal-tooltip", SpaceshipObstacles.default_asteroid_density*100}}
  textfield.style.natural_width = 40
  textfield.style.width = 40

  local belt_flow = target_speed_control_flow.add{type="flow", name="target-speed-asteroid-belt-flow", direction="horizontal",
    tooltip={"space-exploration.spaceship-target-speed-asteroid-belt-tooltip", SpaceshipObstacles.asteroid_density_by_zone_type["asteroid-belt"]*100}}
  belt_flow.add{type="sprite", sprite="virtual-signal/se-asteroid-belt",
    tooltip={"space-exploration.spaceship-target-speed-asteroid-belt-tooltip", SpaceshipObstacles.asteroid_density_by_zone_type["asteroid-belt"]*100}}
  belt_flow.style.left_margin = 5
  textfield = belt_flow.add{type="textfield", name="belt-speed-textfield", numeric="true",
    tooltip={"space-exploration.spaceship-target-speed-asteroid-belt-tooltip", SpaceshipObstacles.asteroid_density_by_zone_type["asteroid-belt"]*100}}
  textfield.style.natural_width = 40
  textfield.style.width = 40

  local field_flow = target_speed_control_flow.add{type="flow", name="target-speed-asteroid-field-flow", direction="horizontal",
    tooltip={"space-exploration.spaceship-target-speed-asteroid-field-tooltip", SpaceshipObstacles.asteroid_density_by_zone_type["asteroid-field"]*100}}
  field_flow.add{type="sprite", sprite="virtual-signal/se-asteroid-field",
    tooltip={"space-exploration.spaceship-target-speed-asteroid-field-tooltip", SpaceshipObstacles.asteroid_density_by_zone_type["asteroid-field"]*100}}
  field_flow.style.left_margin = 5
  textfield = field_flow.add{type="textfield", name="field-speed-textfield", numeric="true",
    tooltip={"space-exploration.spaceship-target-speed-asteroid-field-tooltip", SpaceshipObstacles.asteroid_density_by_zone_type["asteroid-field"]*100}}
  textfield.style.natural_width = 40
  textfield.style.width = 40

  local root = panel_speed
  if spaceship.target_speed_normal and root['target-speed-control-flow'] and root['target-speed-control-flow']['target-speed-normal-flow'] and root['target-speed-control-flow']['target-speed-normal-flow']['normal-speed-textfield'] then
    root['target-speed-control-flow']['target-speed-normal-flow']['normal-speed-textfield'].text = tostring(spaceship.target_speed_normal)
  end
  if spaceship.target_speed_belt and root['target-speed-control-flow'] and root['target-speed-control-flow']['target-speed-asteroid-belt-flow'] and root['target-speed-control-flow']['target-speed-asteroid-belt-flow']['belt-speed-textfield'] then
    root['target-speed-control-flow']['target-speed-asteroid-belt-flow']['belt-speed-textfield'].text = tostring(spaceship.target_speed_belt)
  end
  if spaceship.target_speed_field and root['target-speed-control-flow'] and root['target-speed-control-flow']['target-speed-asteroid-field-flow'] and root['target-speed-control-flow']['target-speed-asteroid-field-flow']['field-speed-textfield'] then
    root['target-speed-control-flow']['target-speed-asteroid-field-flow']['field-speed-textfield'].text = tostring(spaceship.target_speed_field)
  end

  panel_speed.add{ type="progressbar", name="launch_energy_progress", size = 300, value=0, caption={"space-exploration.spaceship-launch-energy", ""}, style="spaceship_progressbar_energy"}
  panel_speed.add{ type="progressbar", name="streamline_progress", size = 300, value=0, caption={"space-exploration.spaceship-streamline", ""}, style="spaceship_progressbar_streamline"}
end

---@param player LuaPlayer
---@param spaceship SpaceshipType
---@param flow_position LuaGuiElement
function SpaceshipGUI.gui_open_panel_position(player, spaceship, flow_position)
  if flow_position['panel_position'] then return end

  local panel_position = flow_position.add{ type="frame", name="panel_position", direction="vertical", style="b_inner_frame"}
  panel_position.style.horizontally_stretchable = true

  local space_distortion = panel_position.add{ type="label", name="anomaly-distance", caption=""}
  space_distortion.style.width = 300
  space_distortion.style.single_line = false

  local stellar_x = panel_position.add{ type="label", name="stellar-x", caption=""}
  stellar_x.style.width = 300
  stellar_x.style.single_line = false

  local stellar_y = panel_position.add{ type="label", name="stellar-y", caption=""}
  stellar_y.style.width = 300
  stellar_y.style.single_line = false

  local star_gravity = panel_position.add{ type="label", name="star-gravity", caption=""}
  star_gravity.style.width = 300
  star_gravity.style.single_line = false

  local planet_gravity = panel_position.add{ type="label", name="planet-gravity", caption=""}
  planet_gravity.style.width = 300
  planet_gravity.style.single_line = false

  local closest_location = panel_position.add{ type="label", name="closest-location", caption=""}
  closest_location.style.width = 300
  closest_location.style.single_line = false

  local asteroid_density = panel_position.add{ type="label", name="asteroid-density", caption=""}
  asteroid_density.style.width = 300
  asteroid_density.style.single_line = false
end

---@param player LuaPlayer
---@param spaceship SpaceshipType
---@param flow_destination LuaGuiElement
function SpaceshipGUI.gui_open_panel_destination(player, spaceship, flow_destination)
  if flow_destination['panel_destination'] then return end

  local playerdata = get_make_playerdata(player)

  local panel_destination = flow_destination.add{ type="frame", name="panel_destination", direction="vertical", style="b_inner_frame"}
  panel_destination.style.horizontally_stretchable = true

  panel_destination.add{type="checkbox", name="list-zones-alphabetical", caption={"space-exploration.list-destinations-alphabetically"}, state=playerdata.zones_alphabetical and true or false}
  local list, selected_index, values = SpaceshipGUI.get_zone_dropdown_values(player, spaceship)
  GuiCommon.create_filter(panel_destination, player,  {
    list = list,
    selected_index = selected_index,
    values = values,
    dropdown_name = "spaceship-list-zones",
  })

  panel_destination.add{ type="label", name="travel-time", caption=""}

  local travel_status = panel_destination.add{ type="label", name="travel-status", caption=""}
  travel_status.style.width = 300
  travel_status.style.single_line = false

  spaceship.distance_to_destination = Spaceship.get_distance_to_destination(spaceship)
end

---@param player LuaPlayer
---@param spaceship SpaceshipType
---@param filter? string
---@return string[]
---@return uint
---@return LocationReference[]
function SpaceshipGUI.get_zone_dropdown_values(player, spaceship, filter)
  local destination_zone = Spaceship.get_destination_zone(spaceship)
  if not Spaceship.is_in_invalid_zone(spaceship) then
    if not destination_zone then destination_zone = Zone.from_zone_index(spaceship.zone_index) end
    if not destination_zone then destination_zone = Zone.find_nearest_zone(
      spaceship.space_distortion,
      spaceship.stellar_position,
      spaceship.star_gravity_well,
      spaceship.planet_gravity_well)
    end
  end
  local playerdata = get_make_playerdata(player)
  local list, selected_index, values = Zone.dropdown_list_zone_destinations(
    player,
    spaceship.force_name,
    destination_zone,
    {
      alphabetical = playerdata.zones_alphabetical,
      filter = filter
    }
  )
  selected_index = selected_index or 1
  if selected_index > #list then selected_index = 1 end
  return list, selected_index, values
end

---@param event EventData.CustomInputEvent Event data
function SpaceshipGUI.focus_search(event)
  local root = game.get_player(event.player_index).gui.left[SpaceshipGUI.name_spaceship_gui_root]
  if not root then return end
  local textfield = util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  if not textfield then return end
  textfield.focus()
end
Event.addListener(mod_prefix.."focus-search", SpaceshipGUI.focus_search)

---@param spaceship_title_flow LuaGuiElement
---@param spaceship_name string
local function fill_spaceship_title_flow(spaceship_title_flow, spaceship_name)
  local spaceship_icon = spaceship_title_flow.add {
    type = "label",
    caption = "[img=virtual-signal/se-spaceship]  ",
    style = "frame_title",
    ignored_by_interaction = true
  }
  local spaceship_title_label = spaceship_title_flow.add {
    type = "label",
    name = "show-name",
    caption = spaceship_name,
    style = "frame_title",
    ignored_by_interaction = true
  }
  spaceship_title_label.style.horizontally_squashable = true
  spaceship_title_label.style.padding = 0

  local spaceship_title_rename = spaceship_title_flow.add{
    type="sprite-button",
    name="rename",
    sprite = "utility/rename_icon",
    tooltip={"space-exploration.rename-something", {"space-exploration.spaceship"}},
    mouse_button_filter = { "left" },
    style = "mini_button_aligned_to_text_vertically_when_centered"
  }
end

--- Opens the spaceship gui for a player for a certain spaceship
---@param player LuaPlayer the player
---@param spaceship SpaceshipType the spaceship
function SpaceshipGUI.gui_open(player, spaceship)
  SpaceshipGUI.gui_close(player)
  if not spaceship then
    player.print({"space-exploration.spaceship_try_replace_console"})
    return
  end
  local gui = player.gui.left
  local playerdata = get_make_playerdata(player)

  local container = gui.add{
    type = "frame",
    name = SpaceshipGUI.name_spaceship_gui_root,
    style="space_platform_container",
    direction="vertical",
    -- use gui element tags to store a reference to what spaceship this gui is displaying/controls
    tags = {
      index = spaceship.index
    }
  }


  local spaceship_title_table = container.add {
    type = "table",
    name = "spaceship_title_table",
    column_count = 3,
    draw_horizontal_lines = false,
  }
  spaceship_title_table.style.horizontally_stretchable = true
  spaceship_title_table.style.column_alignments[1] = "left"
  spaceship_title_table.style.column_alignments[2] = "right"
  spaceship_title_table.style.column_alignments[3] = "right"

  local spaceship_title_flow = spaceship_title_table.add {
    type = "flow",
    name="spaceship_title_flow",
    direction = "horizontal"
  }
  spaceship_title_flow.style.vertically_stretchable = false
  spaceship_title_flow.style.vertical_align = "center"
  fill_spaceship_title_flow(spaceship_title_flow, spaceship.name)

  local spaceship_title_empty = spaceship_title_table.add {
    type = "empty-widget",
    ignored_by_interaction = true
  }
  spaceship_title_empty.style.horizontally_stretchable = true
  spaceship_title_empty.style.left_margin = 4
  spaceship_title_empty.style.right_margin = 0
  spaceship_title_empty.style.height = 24

  local spaceship_title_buttons = spaceship_title_table.add {
    type = "flow",
    name = "spaceship_title_buttons",
    direction = "horizontal"
  }

  spaceship_title_buttons.add {
    type="sprite-button",
    sprite = "virtual-signal/informatron",
    style="se_spaceship_frame_action_button",
    tooltip={"space-exploration.informatron-open-help"},
    tags={se_action="goto-informatron", informatron_page="spaceships"}
  }

  spaceship_title_buttons.add {
    type="sprite-button",
    name="watch-spaceship",
    sprite = "se-show-white",
    style="se_spaceship_frame_action_button",
    tooltip={"space-exploration.spaceship-button-watch-tooltip"},
  }

  spaceship_title_buttons.add {
    type="sprite-button",
    name=SpaceshipGUI.name_window_close,
    sprite = "utility/close",
    style="se_spaceship_frame_action_button",
    tooltip={"space-exploration.close-instruction-only-confirm"}
  }


  local scheduler_flow = container.add{type="frame", direction="horizontal", style="b_inner_frame"}
  scheduler_flow.style.vertical_align = "center"
  scheduler_flow.style.top_margin = 12
  scheduler_flow.style.top_padding = 10
  scheduler_flow.add{ type="button", name="spaceship-set-schedule", caption={"space-exploration.spaceship-scheduler"}}
  local e = scheduler_flow.add{type="empty-widget"}
  e.style.horizontally_stretchable = true
  local schedule_mode = scheduler_flow.add{ type="switch", name="spaceship-scheduler-state", allow_none_state=false, left_label_caption={"gui-train.automatic-mode"}, right_label_caption={"gui-train.manual-mode"} }
  schedule_mode.switch_state = spaceship.scheduler.active and "left" or "right"


  local flow_integrity = container.add{ type="flow", name="flow_integrity", direction="vertical"}
  local button_integrity = flow_integrity.add{ type="button", name="button_integrity", tags={collapse="panel_integrity"}, style = "se_generic_button"}
  button_integrity.style.horizontally_stretchable = true
  button_integrity.style.top_margin = 4
  button_integrity.style.padding = 0
  button_integrity.style.left_padding = 5
  button_integrity.style.horizontal_align = "left"


  local flow_speed = container.add{ type="flow", name="flow_speed", direction="vertical"}
  local button_speed = flow_speed.add{ type="button", name="button_speed", tags={collapse="panel_speed"}, style = "se_generic_button"}
  button_speed.style.horizontally_stretchable = true
  button_speed.style.top_margin = 4
  button_speed.style.padding = 0
  button_speed.style.left_padding = 5
  button_speed.style.horizontal_align = "left"

  local flow_position = container.add{ type="flow", name="flow_position", direction="vertical"}
  local button_position = flow_position.add{ type="button", name="button_position", tags={collapse="panel_position"}, style = "se_generic_button"}
  button_position.style.horizontally_stretchable = true
  button_position.style.top_margin = 4
  button_position.style.padding = 0
  button_position.style.left_padding = 5
  button_position.style.horizontal_align = "left"

  local flow_destination = container.add{ type="flow", name="flow_destination", direction="vertical"}
  local button_destination = flow_destination.add{ type="button", name="button_destination", tags={collapse="panel_destination"}, style = "se_generic_button"}
  button_destination.style.horizontally_stretchable = true
  button_destination.style.top_margin = 4
  button_destination.style.padding = 0
  button_destination.style.left_padding = 5
  button_destination.style.horizontal_align = "left"

  container.add{ type="flow", name="action-flow", direction="horizontal"}

  container.add{ type="flow", name="back-flow", direction="horizontal"}

  player.play_sound{path = "entity-open/constant-combinator"}

  -- If the scheduler GUI is open then make sure it's updated to this spaceship
  if SpaceshipSchedulerGUI.is_open(player) then
    SpaceshipSchedulerGUI.open(player, spaceship)
  end

  SpaceshipGUI.update_panel_states(player, spaceship, container)
  SpaceshipGUI.gui_update(player)
end

---@param breakdown_table {[string]:SpaceshipIntegrityStressBreakdownInfo}
---@return SpaceshipIntegrityStressBreakdownInfo[]
local function sort_breakdown(breakdown_table)
  local indexed_breakdown_table = {}
  for key, value in pairs(breakdown_table) do -- Turn to index-based table so it can be sorted
    local separator_position = string.find(key, "+") -- Split key into item_name and fluid_name
    if separator_position then
      value.item_name = string.sub(key, 1, separator_position - 1)
      value.fluid_name = string.sub(key, separator_position + 1)
    else
      value.item_name = key
      value.fluid_name = "" -- Must not be nil for sorting
    end
    table.insert(indexed_breakdown_table, value)
  end
  table.sort(indexed_breakdown_table, function(a,b)
    -- Order string then item_name then fluid_name
    return a.order < b.order or
      (a.order == b.order and a.item_name < b.item_name) or
      (a.order == b.order and a.item_name == b.item_name and a.fluid_name < b.fluid_name)
  end)
  return indexed_breakdown_table
end

---@param entity_name string
---@return LocalisedString
local function get_best_display_name(entity_name)
  local display_name
  local prototype = prototypes.entity[entity_name]
  if prototype then
    display_name = prototype.localised_name
  end
  if not display_name then
    display_name = {"entity-name."..entity_name}
  end
  return display_name
end

---@param breakdown_table {[string]:SpaceshipIntegrityStressBreakdownInfo}
---@return LocalisedString[]
local function create_breakdown_tooltip_string(breakdown_table)
  local final_string = {""}
  if breakdown_table then
    breakdown_table = sort_breakdown(breakdown_table)

    local sub_final_string
    for i, breakdown_item in pairs(breakdown_table) do
      -- Localised string limit is 20 parameters, add a new sub_final_string every 20 items
      if (i - 1) % 20 == 0 then
        sub_final_string = {""}
        table.insert(final_string, sub_final_string)
      end

      if breakdown_item.item_name == "phantom-tiles" or breakdown_item.item_name == "long-ship" or breakdown_item.item_name == "empty-tiles" then -- Unique entry
        breakdown_item.name = {"space-exploration.spaceship-integrity-breakdown-"..breakdown_item.item_name}
      elseif breakdown_item.item_name == mod_prefix.."spaceship-floor" then -- Tiles don't have entity-name
        breakdown_item.name = {"", "[img=item/"..breakdown_item.item_name.."] ", {"tile-name."..breakdown_item.item_name}} -- tile/spaceship-floor looks uglier than item/spaceship-floor
      else
        -- An entity
        local display_name = get_best_display_name(breakdown_item.item_name)
        if breakdown_item.fluid_name ~= "" then -- Container with special fluid
          breakdown_item.name = {"", "[img=entity/"..breakdown_item.item_name.."][img=fluid/"..breakdown_item.fluid_name.."] ", display_name, " (", {"fluid-name."..breakdown_item.fluid_name}, ")"}
        else -- Any other entity
          breakdown_item.name = {"", "[img=entity/"..breakdown_item.item_name.."] ", display_name}
        end
      end
      local item_string = {"", "[font=default-bold]", breakdown_item.name, "[/font]"}

      table.insert(item_string, " ")

      if breakdown_item.count and breakdown_item.count > 1 then -- "entity" type
        table.insert(item_string, {"space-exploration.spaceship-integrity-breakdown-count", breakdown_item.count})
      elseif breakdown_item.slot_count and breakdown_item.grid_usage then -- vehicle
        table.insert(item_string, {"space-exploration.spaceship-integrity-breakdown-slots-and-equipment", core_util.format_number(breakdown_item.slot_count), breakdown_item.grid_usage})
      elseif breakdown_item.slot_count then -- container or vehicle
        table.insert(item_string, {"space-exploration.spaceship-integrity-breakdown-container-slots", core_util.format_number(breakdown_item.slot_count, true)})
      elseif breakdown_item.grid_usage then -- vehicle
        table.insert(item_string, {"space-exploration.spaceship-integrity-breakdown-equipment", breakdown_item.grid_usage})
      elseif breakdown_item.fluid_capacity then -- fluid container
        table.insert(item_string, {"space-exploration.spaceship-integrity-breakdown-fluid-capacity", core_util.format_number(breakdown_item.fluid_capacity, true)})
      elseif breakdown_item.min and breakdown_item.max then -- (X / Y) subname
        table.insert(item_string, "("..breakdown_item.min.." / "..breakdown_item.max..")")
      elseif breakdown_item.percentage then -- (+X%) subname
        table.insert(item_string, string.format("(+%d%%)", breakdown_item.percentage * 100))
      end


      table.insert(item_string, ": ")
      breakdown_item.cost = math.floor(breakdown_item.cost * 100) / 100 -- Truncate to 2 decimals
      if breakdown_item.cost > 0 then
        table.insert(item_string, "[color=255,100,100]"..string.format("+%g", breakdown_item.cost).."[/color]")
      else
        table.insert(item_string, "[color=100,255,100]"..string.format("%g", breakdown_item.cost).."[/color]")
      end

      if i < table_size(breakdown_table) then -- Not for the last item
        table.insert(item_string, "\n")
      end
      table.insert(sub_final_string, item_string)
    end
  end
  return final_string
end

---@param spaceship SpaceshipType
---@param breakdown_type "structure"|"container"
---@return string
local function get_create_breakdown_tooltip_string(spaceship, breakdown_type)
  local breakdown_table_key = "integrity_stress_"..breakdown_type.."_breakdown"
  local breakdown_string_key = "integrity_stress_"..breakdown_type.."_breakdown_string"
  if spaceship[breakdown_string_key] then
    return spaceship[breakdown_string_key]
  elseif spaceship[breakdown_table_key] then
    spaceship[breakdown_string_key] = create_breakdown_tooltip_string(spaceship[breakdown_table_key])
    spaceship[breakdown_table_key] = nil
    return spaceship[breakdown_string_key]
  else
    return ""
  end
end

---@param progressbar_element LuaGuiElement
---@param spaceship SpaceshipType
---@param breakdown_type "structure"|"container"
local function update_integrity_progressbar(progressbar_element, spaceship, breakdown_type)
  if progressbar_element then
    local current_stress = spaceship["integrity_stress_" .. breakdown_type]
    if current_stress and spaceship.integrity_limit then
      progressbar_element.caption = {"space-exploration.spaceship-structural-stress-" .. breakdown_type, string.format("%.2f", current_stress).. " / " .. spaceship.integrity_limit}
      progressbar_element.value = math.min(1, current_stress / spaceship.integrity_limit)

      if current_stress > spaceship.integrity_limit then
        progressbar_element.style.color = {r=233/255, g=0, b=0}
      else
        progressbar_element.style.color = {r=0, g=200/255, b=0}
      end

      local tooltip = get_create_breakdown_tooltip_string(spaceship, breakdown_type)
      progressbar_element.tooltip=tooltip
    else
      progressbar_element.caption = {"space-exploration.spaceship-structural-stress-" ..breakdown_type.. "-invalid"}
      progressbar_element.value = 0
      progressbar_element.style.color = {r=233/255, g=0, b=0}
      progressbar_element.tooltip = ""
    end
  end
end

---@param tick? uint Current tick
function SpaceshipGUI.gui_update(player, tick)
  tick = tick or game.tick
  local root = player.gui.left[SpaceshipGUI.name_spaceship_gui_root]
  if root and root.tags and root.tags.index then
    local spaceship = Spaceship.from_index(root.tags.index)

    if spaceship then
      local playerdata = get_make_playerdata(player)
      local energy_required = Spaceship.get_launch_energy_cost(spaceship)

      local watching_spaceship = Util.find_first_descendant_by_name(root, "watch-spaceship") --[[@cast watching_spaceship -? ]]
      watching_spaceship.toggled = playerdata.watching_spaceship == spaceship.index

      local manual_mode_switch = Util.find_first_descendant_by_name(root, "spaceship-scheduler-state") --[[@cast manual_mode_switch -? ]]
      manual_mode_switch.switch_state = spaceship.scheduler.active and "left" or "right"

      if root["flow_integrity"] and root["flow_integrity"]["panel_integrity"] then
        local panel = root["flow_integrity"]["panel_integrity"]
        update_integrity_progressbar(panel["structural_integrity_progress"], spaceship, "structure")
        update_integrity_progressbar(panel["container_integrity_progress"], spaceship, "container")

        if panel["check-flow"] and panel["check-flow"]["integrity-status"] then
          local label = panel["check-flow"]["integrity-status"]
          if spaceship.is_doing_check or spaceship.is_doing_check_slowly then
            label.tooltip = ""
            label.caption = {"space-exploration.spaceship-integrity-status-in-progress"}
          elseif spaceship.integrity_valid then
            label.tooltip = ""
            label.caption = {"space-exploration.spaceship-integrity-status-valid"}
          else
            label.tooltip = spaceship.check_message or  ""
            label.caption = {"", {"space-exploration.spaceship-integrity-status-invalid"}, " [img=info]"}
          end
        end
      end

      if root["flow_speed"] and root["flow_speed"]["panel_speed"] then
        local panel = root["flow_speed"]["panel_speed"]

        if panel["target-speed-flow"] and panel["target-speed-flow"]["target-speed-label"] then
          if spaceship.target_speed_source == "manual-override" then
            panel["target-speed-flow"]["target-speed-label"].caption = {"space-exploration.spaceship-target-speed-manual-override", "0"}
          elseif not spaceship.target_speed then
            panel["target-speed-flow"]["target-speed-label"].caption = {"space-exploration.spaceship-target-speed-unlimited"}
          else
            if spaceship.target_speed_source == "circuit" then
              panel["target-speed-flow"]["target-speed-label"].caption = {"space-exploration.spaceship-target-speed-circuit", math.floor(spaceship.target_speed)}
            elseif spaceship.target_speed_source == "asteroid-belt" then
              panel["target-speed-flow"]["target-speed-label"].caption = {"space-exploration.spaceship-target-speed-asteroid-belt", spaceship.target_speed}
            elseif spaceship.target_speed_source == "asteroid-field" then
              panel["target-speed-flow"]["target-speed-label"].caption = {"space-exploration.spaceship-target-speed-asteroid-field", spaceship.target_speed}
            else
              panel["target-speed-flow"]["target-speed-label"].caption = {"space-exploration.spaceship-target-speed-normal", spaceship.target_speed}
            end
          end
        end
        if panel["target-speed-control-flow"] then
          if panel['target-speed-control-flow']['target-speed-normal-flow'] and panel['target-speed-control-flow']['target-speed-normal-flow']['normal-speed-textfield'] then
            local text = spaceship.target_speed_normal and tostring(spaceship.target_speed_normal) or ""
            if panel['target-speed-control-flow']['target-speed-normal-flow']['normal-speed-textfield'].text ~= text then
              panel['target-speed-control-flow']['target-speed-normal-flow']['normal-speed-textfield'].text = text
            end
          end
          if panel['target-speed-control-flow']['target-speed-asteroid-belt-flow'] and panel['target-speed-control-flow']['target-speed-asteroid-belt-flow']['belt-speed-textfield'] then
            local text = spaceship.target_speed_belt and tostring(spaceship.target_speed_belt) or ""
            if panel['target-speed-control-flow']['target-speed-asteroid-belt-flow']['belt-speed-textfield'].text ~= text then
              panel['target-speed-control-flow']['target-speed-asteroid-belt-flow']['belt-speed-textfield'].text = text
            end
          end
          if panel['target-speed-control-flow']['target-speed-asteroid-field-flow'] and panel['target-speed-control-flow']['target-speed-asteroid-field-flow']['field-speed-textfield'] then
            local text = spaceship.target_speed_field and tostring(spaceship.target_speed_field) or ""
            if panel['target-speed-control-flow']['target-speed-asteroid-field-flow']['field-speed-textfield'].text ~= text then
              panel['target-speed-control-flow']['target-speed-asteroid-field-flow']['field-speed-textfield'].text = text
            end
          end
        end

        if panel["launch_energy_progress"] then
          if Spaceship.is_in_invalid_zone(spaceship) then
            panel["launch_energy_progress"].caption={"space-exploration.invalid_launch_location"}
            panel["launch_energy_progress"].value = 0
            panel["launch_energy_progress"].tooltip=nil

          elseif spaceship.zone_index then
            if energy_required and spaceship.launch_energy then
              panel["launch_energy_progress"].caption={"space-exploration.spaceship-launch-energy", Util.format_energy(spaceship.launch_energy) .. " / " .. Util.format_energy(energy_required, true)}
              panel["launch_energy_progress"].value = math.min(1, spaceship.launch_energy / energy_required)
              panel["launch_energy_progress"].tooltip = {"space-exploration.spaceship-launch-energy-tooltip", Util.format_energy(spaceship.launch_energy), Util.format_energy(energy_required, true)}
            else
              panel["launch_energy_progress"].caption={"space-exploration.spaceship-launch-energy-invalid"}
              panel["launch_energy_progress"].value = 0
              panel["launch_energy_progress"].tooltip=nil
            end
          else
            -- repurpose for speed
            if spaceship.speed > 0 then
              panel["launch_energy_progress"].caption={"space-exploration.spaceship-speed", string.format("%.2f", spaceship.speed or 0) .. " / " .. string.format("%.2f", spaceship.max_speed or 0)}
              panel["launch_energy_progress"].value = math.min(1, spaceship.speed / (spaceship.max_speed or spaceship.speed))
            else
              panel["launch_energy_progress"].caption={"space-exploration.spaceship-speed", " 0 / " .. string.format("%.2f", spaceship.max_speed or 0)}
              panel["launch_energy_progress"].value = 0
            end
          end
        end
        if panel["streamline_progress"] then
          if spaceship.streamline then
            panel["streamline_progress"].caption={"space-exploration.spaceship-streamline", string.format("%.2f",(spaceship.streamline or 0) * 100).."%"}
            panel["streamline_progress"].value = spaceship.streamline or 0
            panel["streamline_progress"].tooltip = {"space-exploration.spaceship-streamline-tooltip", string.format("%.2f",(spaceship.streamline or 0) * 100).."%", "100.00%"}
          end
        end
      end

      if root["flow_position"] and root["flow_position"]["panel_position"] then
        local panel = root["flow_position"]["panel_position"]
        if Spaceship.is_in_invalid_zone(spaceship) then
          panel["anomaly-distance"].caption = ""
          panel["stellar-x"].caption = ""
          panel["stellar-y"].caption = ""
          panel["star-gravity"].caption = ""
          panel["planet-gravity"].caption = ""
          panel["asteroid-density"].caption = ""
          panel["closest-location"].caption = {"space-exploration.invalid_launch_location"}
        else
          if spaceship.space_distortion > 0 then
            --root["anomaly-distance"].caption = "Spacial Distortion: " .. string.format("%.2f", spaceship.space_distortion * Zone.travel_cost_space_distortion)
            panel["anomaly-distance"].caption = {"space-exploration.spaceship-location-spatial-distortion", string.format("%.2f", spaceship.space_distortion * Zone.travel_cost_space_distortion)}
          else
            panel["anomaly-distance"].caption = ""
          end
          if spaceship.space_distortion > 0.05 then
            panel["stellar-x"].caption = ""
            panel["stellar-y"].caption = ""
            panel["star-gravity"].caption = ""
            panel["planet-gravity"].caption = ""
          else
            --root["stellar-x"].caption = "Quadrant X: " .. string.format("%.2f", spaceship.stellar_position.x * Zone.travel_cost_interstellar)
            --root["stellar-y"].caption = "Quadrant Y: " .. string.format("%.2f", spaceship.stellar_position.y * Zone.travel_cost_interstellar)
            panel["stellar-x"].caption = {"space-exploration.spaceship-location-stellar-x", string.format("%.2f", spaceship.stellar_position.x * Zone.travel_cost_interstellar)}
            panel["stellar-y"].caption = {"space-exploration.spaceship-location-stellar-y", string.format("%.2f", spaceship.stellar_position.y * Zone.travel_cost_interstellar)}
            if spaceship.star_gravity_well > 0 then
              --root["star-gravity"].caption = "Star gravity well: " .. string.format("%.2f", spaceship.star_gravity_well * Zone.travel_cost_star_gravity)
              panel["star-gravity"].caption = {"space-exploration.spaceship-location-star-gravity-well", string.format("%.2f", spaceship.star_gravity_well * Zone.travel_cost_star_gravity)}
            else
              panel["star-gravity"].caption = ""
            end
            if spaceship.planet_gravity_well > 0 then
              --root["planet-gravity"].caption = "Planet gravity well: " .. string.format("%.2f", spaceship.planet_gravity_well * Zone.travel_cost_planet_gravity)
              panel["planet-gravity"].caption = {"space-exploration.spaceship-location-planet-gravity-well", string.format("%.2f", spaceship.planet_gravity_well * Zone.travel_cost_planet_gravity)}
            else
              panel["planet-gravity"].caption = ""
            end
          end

          if panel["closest-location"] and ((tick + 30) % 60 == 0  or panel["closest-location"].caption == "") then
            local closest = Zone.find_nearest_zone(
            spaceship.space_distortion,
            spaceship.stellar_position,
            spaceship.star_gravity_well,
            spaceship.planet_gravity_well)
            if Zone.is_visible_to_force(closest, player.force.name) then
              panel["closest-location"].caption = {"space-exploration.spaceship-closest-location", closest.name}
            else
              panel["closest-location"].caption = {"space-exploration.spaceship-closest-location-unknown", Zone.type_title(closest)}
            end
          end

          if spaceship.asteroid_density and panel["asteroid-density"] then
            panel["asteroid-density"].caption = {"space-exploration.spaceship-asteroid-density", SpaceshipObstacles.get_asteroid_density_caption(spaceship)}
          end
        end
      end

      if root["flow_destination"] and root["flow_destination"]["panel_destination"] then
        local panel = root["flow_destination"]["panel_destination"]
        if tick % 60 == 0 then
          SpaceshipGUI.gui_update_destinations_list(root, player, spaceship)
          spaceship.distance_to_destination = Spaceship.get_distance_to_destination(spaceship)
          spaceship.distance_to_destination_tick = tick
        end
        if spaceship.distance_to_destination and spaceship.speed then
          if spaceship.speed == 0 then
            if not spaceship.max_speed or spaceship.max_speed == 0 then
              --root["travel-time"].caption = "Travel time: Unknown. Test max speed for estimate."
              panel["travel-time"].caption = {"space-exploration.spaceship-travel-time-unknown"}
            else
              --root["travel-time"].caption = "Travel time: "..
              --  Util.seconds_to_clock(spaceship.distance_to_destination / ((spaceship.max_speed or 1) * Spaceship.travel_speed_multiplier) / 60)
              --  .. "s at max speed"
              panel["travel-time"].caption = {"space-exploration.spaceship-travel-time-max", Util.seconds_to_clock(spaceship.distance_to_destination / ((spaceship.max_speed or 1) * Spaceship.travel_speed_multiplier) / 60)}
            end
          else
            panel["travel-time"].caption = {"space-exploration.spaceship-travel-time-current", Util.seconds_to_clock(spaceship.distance_to_destination / ((spaceship.speed or 1) * Spaceship.travel_speed_multiplier) / 60)}
          end
        else
          panel["travel-time"].caption = {"space-exploration.spaceship-travel-time-current", 0}
        end

        if panel["travel-status"] then
          --root["travel-status"].caption="Travel Status: " .. (spaceship.travel_message or  "")
          panel["travel-status"].caption={"space-exploration.spaceship-travel-status", (spaceship.travel_message or  "")}
        end

      end


      -- button modes:
      --[[
      launch when on a surface
      Anchor when near a surface the is the destination
      Stop when moving.
      Engage when in space and:
        a destination is selected
        or not near a surface
      ]]--

      local button
      if Spaceship.is_in_invalid_zone(spaceship) or not is_player_force(player.force.name) then
        if not root["action-flow"]["launch"] then
          root["action-flow"].clear()
          root["action-flow"].add{ type="button", name="launch", caption={"space-exploration.spaceship-button-launch"}, style="confirm_button"}
        end
        button = root["action-flow"]["launch"]
        button.caption = {"space-exploration.spaceship-button-launch-disabled"}

      elseif spaceship.is_launching then
        -- launch in progress
        if not root["action-flow"]["launch"] then
          root["action-flow"].clear()
          root["action-flow"].add{ type="button", name="launch", caption={"space-exploration.spaceship-button-launching"}, style="confirm_button"}
        end
        button = root["action-flow"]["launch"]
        button.caption = {"space-exploration.spaceship-button-launching"}
        button.tooltip = {"space-exploration.spaceship-button-launching-tooltip"}
        button.style = "yellow_confirm_button"

      elseif spaceship.zone_index then
        -- launch
        if not root["action-flow"]["launch"] then
          root["action-flow"].clear()
          root["action-flow"].add{ type="button", name="launch", caption={"space-exploration.spaceship-button-launch"}, style="confirm_button"}
        end
        button = root["action-flow"]["launch"]
        if spaceship.integrity_valid then
          if energy_required and spaceship.launch_energy and spaceship.launch_energy >= energy_required then
            --button.caption = "Launch"
            button.caption = {"space-exploration.spaceship-button-launch"}
            --button.tooltip = "Ready to launch"
            button.tooltip = {"space-exploration.spaceship-button-launch-tooltip"}
            button.style = "confirm_button"
          else
            --button.caption = "Launch (disabled)"
            button.caption = {"space-exploration.spaceship-button-launch-disabled"}
            --button.tooltip = "Requires fuel in booster tanks"
            if spaceship.launch_energy and spaceship.launch_energy > 0 then
              button.tooltip = {"space-exploration.spaceship-button-launch-disabled-more-fuel-tooltip"}
            else
              button.tooltip = {"space-exploration.spaceship-button-launch-disabled-fuel-tooltip"}
            end
            button.style = "red_confirm_button"
          end
        else
          --button.caption = "Launch (disabled)"
          button.caption = {"space-exploration.spaceship-button-launch-disabled"}
          --button.tooltip = "Requires valid integrity check"
          button.tooltip = {"space-exploration.spaceship-button-launch-disabled-integrity-tooltip"}
          button.style = "red_confirm_button"
        end

      elseif spaceship.near and
       (spaceship.destination == nil
        or (spaceship.near.type == "zone" and spaceship.destination.index == spaceship.near.index)) then
          -- anchor
          local zone = Zone.from_zone_index(spaceship.near.index)
          if not root["action-flow"]["button_anchor"] then
            root["action-flow"].clear()
            root["action-flow"].add{ type="button", name="button_anchor", caption={"space-exploration.spaceship-button-anchor"}, style="confirm_button"}
          end
          button = root["action-flow"]["button_anchor"]
          if RemoteView.get_activity(player, "spaceship-anchor-scouting") then
            button.caption = {"space-exploration.spaceship-button-confirm-anchor"}
            button.style = "confirm_button"
          else
            if Zone.is_solid(zone) then
              ---@cast zone PlanetType|MoonType
              button.caption = {"space-exploration.spaceship-button-anchor-on", zone.name}
            else
              ---@cast zone -PlanetType, -MoonType
              button.caption = {"space-exploration.spaceship-button-anchor-to", zone.name}
            end
            button.style = "confirm_button"
          end

          -- Add warning icon and tooltip to "anchor" and "confirm anchor" buttons when ship has no planet boosters
          local booster_warning_string = Spaceship.get_booster_warning_string(spaceship, zone)
          if booster_warning_string then
            button.caption = {"", button.caption, " [img=utility/warning_icon]"}
            button.tooltip = booster_warning_string
          end

      elseif spaceship.near and spaceship.near.type == "spaceship" and spaceship.destination
        and spaceship.destination.type == "spaceship" and spaceship.destination.index == spaceship.near.index then

          -- board
          local othership = Spaceship.from_index(spaceship.near.index)
          if not othership then
            spaceship.destination = nil
          end
          local name = othership and othership.name or "MISSING"
          if not root["action-flow"]["board"] then
            root["action-flow"].clear()
            root["action-flow"].add{ type="button", name="board", caption={"space-exploration.spaceship-button-board", name}, style="confirm_button"}
          end
          button = root["action-flow"]["board"]


      elseif spaceship.destination and not spaceship.stopped then

        if not root["action-flow"]["stop"] then
          root["action-flow"].clear()
          root["action-flow"].add{ type="button", name="stop", caption={"space-exploration.spaceship-button-stop"}, style="confirm_button"}
        end
        button = root["action-flow"]["stop"]

      else

        if not root["action-flow"]["start"] then
          root["action-flow"].clear()
          root["action-flow"].add{ type="button", name="start", caption={"space-exploration.spaceship-button-start"}, style="confirm_button"}
        end
        button = root["action-flow"]["start"]

      end
      ---@cast button -?

      button.style.top_margin = 10
      button.style.horizontally_stretchable  = true
      button.style.horizontal_align = "left"

      if RemoteView.get_activity(player, "spaceship-anchor-scouting") then
        if not root["back-flow"]["cancel_anchor_scouting"] then
          local back = root["back-flow"].add{type = "button", name = "cancel_anchor_scouting",
            caption = {"space-exploration.spaceship-button-scouting-back"}, style="back_button", tooltip={"space-exploration.spaceship-button-scouting-back-tooltip"}}
          back.style.top_margin = 10
        end
      elseif root["back-flow"]["cancel_anchor_scouting"] then
        root["back-flow"]["cancel_anchor_scouting"].destroy()
      end
    end
  end
end

---Updates the state for a particular collapsible panel to reflect its state in playerdata.
---@param player LuaPlayer the player to modify the GUI for
---@param spaceship SpaceshipType Spaceship data
---@param root LuaGuiElement Root gui element in which the panel is
---@param name string Name of the panel
function SpaceshipGUI.update_panel_state(player, spaceship, root, name)
  local flow = root['flow_' .. name]
  if not flow then return end
  local element = flow['panel_' .. name]
  local button = flow['button_' .. name]
  local playerdata = get_make_playerdata(player)
  playerdata.collapse_map = playerdata.collapse_map or {position = true}
  if playerdata.collapse_map[name] then
    if element then element.destroy() end
    button.caption = {"space-exploration.panel-closed", {"space-exploration.panel-"..name.."-name"}}
    button.tooltip = "" -- nil doesn't work here
  else
    SpaceshipGUI.gui_open_panel(player, spaceship, flow, name)
    if name == "integrity" then
      button.caption = {"", {"space-exploration.panel-open", {"space-exploration.panel-"..name.."-name"}}, " [img=info]"}
      button.tooltip = {"space-exploration.panel-"..name.."-tooltip"}
    else
      button.caption = {"space-exploration.panel-open", {"space-exploration.panel-"..name.."-name"}}
    end
  end
end

--- Updates the state for all collapsible panels to reflect their states in playerdata
---@param player LuaPlayer
---@param spaceship SpaceshipType
---@param root LuaGuiElement
function SpaceshipGUI.update_panel_states(player, spaceship, root)
  SpaceshipGUI.update_panel_state(player, spaceship, root, "integrity")
  SpaceshipGUI.update_panel_state(player, spaceship, root, "speed")
  SpaceshipGUI.update_panel_state(player, spaceship, root, "position")
  SpaceshipGUI.update_panel_state(player, spaceship, root, "destination")
  SpaceshipGUI.gui_update(player) -- force GUI update immediately
end

---@param event EventData.on_gui_click|EventData.on_gui_confirmed|EventData.on_gui_selection_state_changed Event data
function SpaceshipGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, SpaceshipGUI.name_spaceship_gui_root)
  if not (root and root.tags and root.tags.index) then return end
  local playerdata = get_make_playerdata(player)
  local spaceship = Spaceship.from_index(root.tags.index)
  if not spaceship then
    Spaceship.stop_anchor_scouting(player)
    return
  end

  if element.tags and element.tags.collapse then
    playerdata.collapse_map = playerdata.collapse_map or {position = true}
    if element.tags.collapse == "panel_integrity" then
      playerdata.collapse_map['integrity'] = not playerdata.collapse_map['integrity']
    elseif element.tags.collapse == "panel_speed" then
      playerdata.collapse_map['speed'] = not playerdata.collapse_map['speed']
    elseif element.tags.collapse == "panel_position" then
      playerdata.collapse_map['position'] = not playerdata.collapse_map['position']
    elseif element.tags.collapse == "panel_destination" then
      playerdata.collapse_map['destination'] = not playerdata.collapse_map['destination']
    end
    SpaceshipGUI.update_panel_states(player, spaceship, root)
  end
  if element.name == "launch" then
    SpaceshipScheduler.deactivate(spaceship)

    if spaceship.zone_index and not spaceship.entities_to_restore then
      spaceship.is_launching = true
      spaceship.is_landing = false
      SpaceshipIntegrity.start_integrity_check(spaceship)
      spaceship.is_doing_check_slowly = nil -- never slowly if the player asks for the check
    end

  elseif element.name == "button_anchor" then
    SpaceshipScheduler.deactivate(spaceship)

    if spaceship.near and spaceship.near.type == "zone" and not spaceship.entities_to_restore then
      if RemoteView.get_activity(player, "spaceship-anchor-scouting") then
        if event.tick <= (spaceship.surface_lock_timeout or 0) or spaceship.is_doing_check then
          player.print({"space-exploration.wait-for-integrity-check"})
        else
          local position = table.deepcopy(player.position)
          player.print({"space-exploration.target-set",
            "virtual-signal/se-spaceship",
            {"space-exploration.target-label-spaceship"},
            Zone.get_print_name(Zone.from_zone_index(spaceship.near.index)),
            math.floor(position.x),
            math.floor(position.y)})

          Spaceship.stop_anchor_scouting(player)
          Spaceship.land_at_position(spaceship, position, nil)
        end
      else
        spaceship.is_launching = false
        spaceship.is_landing = true
        Spaceship.start_anchor_scouting(spaceship, player)
        SpaceshipIntegrity.start_integrity_check(spaceship)
      end
    else
        Spaceship.stop_anchor_scouting(player)
    end

  elseif element.name == "board" then
    SpaceshipScheduler.deactivate(spaceship)

    if spaceship.near and spaceship.near.type == "spaceship" then
      local othership = Spaceship.from_index(spaceship.near.index)
      if othership and Zone.get_travel_delta_v_sub(spaceship, othership) < 1 then
        if not othership.on_own_surface then
          player.print({"space-exploration.fail-board-target-anchored"})
        else
          local character = player.character
          if not character then
            local playerdata = get_make_playerdata(player)
            character = playerdata.character
          end
          if not character then
            player.print({"space-exploration.fail-board-no-character"})
          else
            if character.surface.index ~= spaceship.own_surface.index then
              player.print({"space-exploration.fail-board-remote-character"})
            else
              local surface = Spaceship.get_current_surface(othership)
              local boarding_position = Spaceship.get_boarding_position(othership)
              --teleport_non_colliding_player(player, boarding_position, surface)
              teleport_character_to_surface(character, surface, boarding_position)
              SpaceshipGUI.gui_close(player)
            end
          end
        end
      end
    end

  elseif element.name == "stop" then
    SpaceshipScheduler.deactivate(spaceship)

    spaceship.stopped = true
    spaceship.target_speed = nil
    spaceship.target_speed_source = "manual-override"

  elseif element.name == "start" then
    SpaceshipScheduler.deactivate(spaceship)

    spaceship.stopped = false
    spaceship.target_speed = nil
    spaceship.target_speed_source = nil
    SpaceshipIntegrity.start_integrity_check(spaceship)

  elseif element.name == "cancel_anchor_scouting" then
    SpaceshipScheduler.deactivate(spaceship)

    Spaceship.stop_anchor_scouting(player)

  elseif element.name == "start-integrity-check" then

    spaceship.max_speed = 0
    SpaceshipIntegrity.start_integrity_check(spaceship, 0.1)

  elseif element.name == "rename" then

    local spaceship_title_flow = root["spaceship_title_table"]["spaceship_title_flow"]
    if not spaceship_title_flow then
      SpaceshipGUI.gui_close(player)
      return
    end
    spaceship_title_flow.clear()
    GuiCommon.create_rename_textfield(spaceship_title_flow, spaceship.name)
    local confirm_rename_button = spaceship_title_flow.add {
      type="sprite-button",
      name="confirm-rename",
      sprite = "utility/enter",
      style="item_and_count_select_confirm",
      tooltip={"space-exploration.rename-confirm"},
    }

  elseif element.name == "confirm-rename" or (element.name == GuiCommon.rename_textfield_name and not event.button) then -- Clicked confirm button or pressed Enter on textbox

    local spaceship_title_flow = root["spaceship_title_table"]["spaceship_title_flow"]
    if not spaceship_title_flow then
      SpaceshipGUI.gui_close(player)
      return
    end
    local new_name = string.trim(spaceship_title_flow[GuiCommon.rename_textfield_name].text)
    if new_name ~= "" and new_name ~= spaceship.name then
      Spaceship.rename(spaceship, new_name)
    end
    spaceship_title_flow.clear()
    fill_spaceship_title_flow(spaceship_title_flow, spaceship.name)

  elseif element.name == "spaceship-list-zones" then

    local value = player_get_dropdown_value(player, element.name, element.selected_index)
    if type(value) == "table" then
      if value.type == "zone" then
        local zone_index = value.index
        local zone = Zone.from_zone_index(zone_index)
        if zone then
          spaceship.destination = {type = "zone", index = zone_index}
          spaceship.travel_message = {"space-exploration.spaceship-travel-message-new-course-plotted"}
          --spaceship.destination_zone_index = zone_index
          Log.debug("set destination to location: " .. zone.name )
          SpaceshipScheduler.deactivate(spaceship)
        end
        Log.debug(Spaceship.get_distance_to_destination(spaceship))
        if Spaceship.get_distance_to_destination(spaceship) <= 0.1 then
          spaceship.near = {type="zone", index= zone_index}
          Event.trigger("on_spaceship_near_zone", {spaceship_index=spaceship.index, zone_index=zone_index})
        end
      elseif value.type == "spaceship" then
        local spaceship_index = value.index
        local destination_spaceship = Spaceship.from_index(spaceship_index)
        if destination_spaceship == spaceship then
          player.print({"space-exploration.spaceship-cannot-set-destination-to-self"})
        else
          spaceship.destination = {type = "spaceship", index = spaceship_index}
          spaceship.travel_message = {"space-exploration.spaceship-travel-message-new-course-plotted"}
          Log.debug("set destination to spaceship : " .. spaceship.name )
          SpaceshipScheduler.deactivate(spaceship)
        end
        Log.debug(Spaceship.get_distance_to_destination(spaceship))
        if Spaceship.get_distance_to_destination(spaceship) <= 0.1 then
          spaceship.near = {type = "spaceship", index = spaceship_index}
        end
      end
      Spaceship.update_output_combinator(spaceship, event.tick)
    else
      SpaceshipGUI.gui_close(player)
      Log.debug("Error: Non-table value ")
    end

  elseif element.name == GuiCommon.filter_clear_name then
    element.parent[GuiCommon.filter_textfield_name].text = ""
    SpaceshipGUI.gui_update_destinations_list(root, player, spaceship)
  elseif element.name == SpaceshipGUI.name_window_close then
    SpaceshipGUI.gui_close(player)
  elseif element.name == "spaceship-set-schedule" then
    -- The scheduler gui itself will verify if the scheduler lock isn't already held by another player
    SpaceshipSchedulerGUI.open(player, spaceship)
  elseif element.name == "watch-spaceship" then
    if playerdata.watching_spaceship ~= spaceship.index then
      playerdata.watching_spaceship = spaceship.index
      element.toggled = true
      RemoteView.start(player, spaceship)
    else
      playerdata.watching_spaceship = nil
      element.toggled = false
    end
  end
end
Event.addListener(defines.events.on_gui_click, SpaceshipGUI.on_gui_click)
Event.addListener(defines.events.on_gui_confirmed, SpaceshipGUI.on_gui_click)
Event.addListener(defines.events.on_gui_selection_state_changed, SpaceshipGUI.on_gui_click)


---@param event EventData.on_gui_checked_state_changed Event data
function SpaceshipGUI.on_gui_checked_state_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, SpaceshipGUI.name_spaceship_gui_root)
  if not (root and root.tags and root.tags.index) then return end
  local spaceship = Spaceship.from_index(root.tags.index)
  if not spaceship then return end

  if element.name == "list-zones-alphabetical" then
    local playerdata = get_make_playerdata(player)
    playerdata.zones_alphabetical = element.state
    SpaceshipGUI.gui_update_destinations_list(root, player, spaceship)
  end
end
Event.addListener(defines.events.on_gui_checked_state_changed, SpaceshipGUI.on_gui_checked_state_changed)

---Toggle active state and start or stop the spaceship.
---@param event EventData.on_gui_switch_state_changed
function SpaceshipGUI.toggle_state(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, SpaceshipGUI.name_spaceship_gui_root)
  if not (root and root.tags and root.tags.index) then return end
  local spaceship = Spaceship.from_index(root.tags.index)
  if not spaceship then return end

  if element.name == "spaceship-scheduler-state" then
    if event.element.switch_state == "left" then
      SpaceshipScheduler.activate(spaceship)
    else
      SpaceshipScheduler.deactivate(spaceship)
    end
  end
end
Event.addListener(defines.events.on_gui_switch_state_changed, SpaceshipGUI.toggle_state)


---@param root LuaGuiElement
---@param player LuaPlayer
---@param spaceship SpaceshipType
function SpaceshipGUI.gui_update_destinations_list(root, player, spaceship)
  local panel = root["flow_destination"]["panel_destination"]
  if not panel then return end
  local filter_list = Util.find_first_descendant_by_name(root, GuiCommon.filter_textfield_name)
  local filter = nil
  if filter_list then
    filter = string.trim(filter_list.text)
    if filter == "" then
      filter = nil
    end
  end
  local list, selected_index, values = SpaceshipGUI.get_zone_dropdown_values(player, spaceship, filter)
  panel["spaceship-list-zones"].items = list
  panel["spaceship-list-zones"].selected_index = selected_index
  player_set_dropdown_values(player, "spaceship-list-zones", values)
end

---@param event EventData.on_gui_text_changed Event data
function SpaceshipGUI.on_gui_text_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, SpaceshipGUI.name_spaceship_gui_root)
  if not (root and root.tags and root.tags.index) then return end
  local spaceship = Spaceship.from_index(root.tags.index)
  if not spaceship then return end

  if element.name == GuiCommon.filter_textfield_name then
    SpaceshipGUI.gui_update_destinations_list(root, player, spaceship)
  elseif element.name == "normal-speed-textfield" then
    local target = 0
    if element.text and element.text ~= "" then
      target = tonumber(element.text) or 0
    end
    if target > 0 then
      spaceship.target_speed_normal = target
    else
      spaceship.target_speed_normal = nil
    end
  elseif element.name == "belt-speed-textfield" then
    local target = 0
    if element.text and element.text ~= "" then
      target = tonumber(element.text) or 0
    end
    if target > 0 then
      spaceship.target_speed_belt = target
    else
      spaceship.target_speed_belt = nil
    end
  elseif element.name == "field-speed-textfield" then
    local target = 0
    if element.text and element.text ~= "" then
      target = tonumber(element.text) or 0
    end
    if target > 0 then
      spaceship.target_speed_field = target
    else
      spaceship.target_speed_field = nil
    end
  end
end
Event.addListener(defines.events.on_gui_text_changed, SpaceshipGUI.on_gui_text_changed)

--- Close the spaceship gui for a player
---@param player LuaPlayer
function SpaceshipGUI.gui_close(player)
  if player.gui.left[SpaceshipGUI.name_spaceship_gui_root] then
    player.gui.left[SpaceshipGUI.name_spaceship_gui_root].destroy()
    player.play_sound{path = "entity-close/constant-combinator"}
  end
  Spaceship.stop_anchor_scouting(player)
  local playerdata = get_make_playerdata(player)
  playerdata.watching_spaceship = nil
end

--- Opens the spaceship gui when a spaceship console is clicked
--- Closes the spaceship gui when another gui is opened
---@param event EventData.on_gui_opened Event data
function SpaceshipGUI.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if event.entity and event.entity.valid and event.entity.name == Spaceship.name_spaceship_console then
    SpaceshipGUI.gui_open(player, Spaceship.from_entity(event.entity))
    player.opened = nil -- don't display the vanilla GUI for an accumulator
  else
    -- when the crafting menu is opened we close the gui and then close the crafting menu
    if player.gui.left[SpaceshipGUI.name_spaceship_gui_root] and player.opened_self then
      player.opened = nil
    end
    SpaceshipGUI.gui_close(player)
  end
end
Event.addListener(defines.events.on_gui_opened, SpaceshipGUI.on_gui_opened)

return SpaceshipGUI
