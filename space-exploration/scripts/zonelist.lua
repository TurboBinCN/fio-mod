--[[
  Zonelist (Universe Explorer)
  Allows players to access zone information, as well as a number of functions.
]]

local Zonelist = {
  on_zonelist_gui_opened = util.get_custom_event("on_zonelist_gui_opened"),

  name_root = "se-zonelist",
  name_main_flow = "main-flow",

  name_left_flow = "left-flow",
  name_toolbar_flow = "toolbar-flow",
  name_priority_threshold_container = "priority-container-flow",
  name_priority_threshold_textfield = "priority-threshold-textfield",
  name_search_flow = "search-flow",
  name_search_textfield = "search-textfield",
  name_search_button = "search-button",
  name_list_container_frame = "list-container-frame",
  name_list_header_frame = "list-header-frame",
  name_list_rows_scroll_pane = "list-rows-scroll-pane",

  name_right_flow = "right-flow",
  name_zone_data_container_frame = "container-frame",
  name_zone_data_subheader_frame = "subheader-frame",
  name_zone_data_header_label = "header-label",
  name_zone_data_priority_flow = "priority-flow",
  name_zone_data_priority_textfield = "priority-textfield",
  name_zone_data_priority_sub_flow = "priority-sub-flow",
  name_zone_data_content_scroll_pane = "content-scroll-pane",
  name_zone_data_preview_frame = "preview-frame",
  name_zone_data_bottom_button_flow = "bottom-button-flow",
  name_zone_data_delete_surface_button = "delete-surface-button",
  name_zone_data_trim_surface_button = "trim-surface-button",
  name_zone_data_confirm_extinction_button = "confirm-extinction-button",
  name_zone_data_scan_surface_button = "scan-surface-button",
  name_zone_data_view_surface_button = "view-surface-button",

  action_close_button = "close-zonelist",
  action_show_preview_frame = "show-preview-frame",
  action_open_interstellar_map = "open-interstellar-map",
  action_zone_type_toggle_button = "toggle-zone-type",
  action_priority_threshold_toggle_button = "toggle-priority-threshold",
  action_priority_threshold_textfield = "set-priority-threshold",
  action_priority_threshold_change_button = "change-priority-threshold",
  action_flags_button = "toggle-flags-gui",
  action_search_button = "toggle-search-textfield",
  action_search_textfield = "search-zones",
  action_header_row_button = "sort-by-feature",
  action_zone_row_button = "select-zone",

  action_zone_priority_textfield = "set-zone-priority",
  action_zone_priority_change_button = "change-zone-priority",
  action_zone_data_content_header = "collapse-section",
  action_zone_link = "se-open-zone-in-zonelist",
  action_pin_button = "trigger-pin",
  action_delete_surface_button = "delete-surface",
  action_trim_surface_button = "trim-surface",
  action_confirm_extinction_button = "confirm-extinction",
  action_scan_surface_button = "scan-surface",
  action_view_surface_button = "view-surface",

  name_button_overhead_explorer = "se-overhead_explorer",
  name_setting_overhead_explorer = "se-show-overhead-button-universe-explorer",
  name_shortcut = "se-universe-explorer",
  name_event = "se-universe-explorer",

  nb_satellites_to_unlock = 2,
  priority_max = 999,
  color_priority_positive = {50, 250, 50},
  color_priority_zero = {255, 174, 0},
  color_priority_negative = {250, 20, 20},
  min_bar_brightness = 200
}

do
  Zonelist.path_priority_threshold_textfield = {
    Zonelist.name_main_flow,
    Zonelist.name_left_flow,
    Zonelist.name_toolbar_flow,
    Zonelist.name_priority_threshold_container,
    Zonelist.name_priority_threshold_textfield
  }
  Zonelist.path_search_textfield = {
    Zonelist.name_main_flow,
    Zonelist.name_left_flow,
    Zonelist.name_toolbar_flow,
    Zonelist.name_search_flow,
    Zonelist.name_search_textfield
  }
  Zonelist.path_list_header_frame = {
    Zonelist.name_main_flow,
    Zonelist.name_left_flow,
    Zonelist.name_list_container_frame,
    Zonelist.name_list_header_frame
  }
  Zonelist.path_list_rows_scroll_pane = {
    Zonelist.name_main_flow,
    Zonelist.name_left_flow,
    Zonelist.name_list_container_frame,
    Zonelist.name_list_rows_scroll_pane
  }
  Zonelist.path_zone_data_flow = {
    Zonelist.name_main_flow,
    Zonelist.name_right_flow
  }
  Zonelist.path_zone_data_subheader = {
    Zonelist.name_right_flow,
    Zonelist.name_zone_data_container_frame,
    Zonelist.name_zone_data_subheader_frame
  }
  Zonelist.path_zone_data_priority_textfield = {
    Zonelist.name_right_flow,
    Zonelist.name_zone_data_container_frame,
    Zonelist.name_zone_data_subheader_frame,
    Zonelist.name_zone_data_priority_flow,
    Zonelist.name_zone_data_priority_textfield
  }
  Zonelist.path_zone_data_view_surface_button = {
    Zonelist.name_zone_data_bottom_button_flow,
    Zonelist.name_zone_data_view_surface_button
  }
end

-- Sorting functions
local _sorting_functions = {
  hierarchy = function (a, b)
    if a.type == "spaceship" then
      if b.type == "spaceship" then
        return a.name < b.name
      else
        return false -- b first
      end
    elseif b.type == "spaceship" then
      return true -- a first
    end

    return a.hierarchy_index < b.hierarchy_index
  end,
  zone_type = function (a, b)
    if a.type == b.type and a.type == "orbit" then
      return a.parent.type < b.parent.type
    else
      return a.type < b.type
    end
  end,
  zone_name = function (a,b) return a.name < b.name end,
  radius = function (a,b) return (a.radius or math.huge) < (b.radius or math.huge) end,
  resource = function (a, b)
    return (a.is_homeworld and "1" or
        ((a.type ~= "orbit" and a.primary_resource) and a.primary_resource or "zzz")) <
        (b.is_homeworld and "1" or ((b.type ~= "orbit" and b.primary_resource) and
        b.primary_resource or "zzz")) end,
  attrition = function (a,b) return Zone.get_bot_attrition(a) < Zone.get_bot_attrition(b) end,
  threat = function (a,b) return Zone.get_threat(a) < Zone.get_threat(b) end,
  solar = function (a,b) return Zone.get_display_light_percent(a) <
      Zone.get_display_light_percent(b) end,
  -- "flags", "priority", and "delta_v" depend on forcedata, and have their own special case
}

-- Map of full-type to hierarchy string
local _hierarchy_strings = {
  ["anomaly"] = "  ?",
  ["star"] = "⬤",
  ["star-orbit"] = "⬤",
  ["planet"] = "   | - ●",
  ["planet-orbit"] = "   |    ○",
  ["moon"] = "   |      | - ●",
  ["moon-orbit"] = "   |      |    ○",
  ["asteroid-belt"] = "   | - ✖",
  ["asteroid-field"] = " ✖",
  ["spaceship"] = "  ▴"
}

-- Runtime cache, mapping resource names to the colors that should be used for them
local _resource_bar_colors = {}

---Returns a unique name for a given zone or spaceship.
---@param zone AnyZoneType|SpaceshipType Zone
---@return string name
local function _get_row_name(zone)
  return (zone.type == "spaceship" and "spaceship-" or "zone-") .. zone.index
end

---Returns the color appropriate for the given `priority` value.
---@param priority integer Priority value
---@return Color color
local function _get_priority_color(priority)
  if priority > 0 then
    return Zonelist.color_priority_positive
  elseif priority == 0 then
    return Zonelist.color_priority_zero
  else
    return Zonelist.color_priority_negative
  end
end

---Returns the color appropriate for the resource bar of a given resource.
---@param resource_name string Resource name
---@return Color color
local function _get_resource_bar_color(resource_name)
  -- First check runtime cache
  local color = _resource_bar_colors[resource_name]
  if color then return color end

  local proto = prototypes.entity[resource_name]

  if proto and proto.map_color then
    color = proto.map_color --[[@as Color]]
    local rgb = color.r + color.g + color.b
    if rgb < 150 then
      color.r = color.r + 1
      color.g = color.g + 1
      color.b = color.b + 1
      rgb = rgb + 3
    end

    local rgb_max = math.max(color.r, math.max(color.g, color.b))

    if rgb_max < Zonelist.min_bar_brightness then
      local rgb_m = Zonelist.min_bar_brightness / rgb_max

      color.r = math.min(255, color.r * rgb_m)
      color.g = math.min(255, color.g * rgb_m)
      color.b = math.min(255, color.b * rgb_m)
    end
  else
    color = Zonelist.color_priority_zero
  end

  _resource_bar_colors[resource_name] = color
  return color --[[@as Color]]
end

---Selects a given zone row in the GUI.
---@param parent LuaGuiElement Scroll-pane element
---@param zone AnyZoneType|SpaceshipType
local function _apply_selected_row_style(parent, zone)
  local row = parent[_get_row_name(zone)]
  if not row then return end

  row.style = "se_zonelist_row_button_selected"
  ---@type LuaGuiElement[]
  local elements = row.children[1].children
  for i = 3, (#elements) do
    elements[i].style.font_color = {0, 0, 0}
  end
end

---Unselects a given zone row in the GUI.
---@param parent LuaGuiElement Scroll-pane element
---@param zone? AnyZoneType|SpaceshipType Zone to unselect
local function _apply_unselected_row_style(parent, zone)
  if not zone then return end

  local row = parent[_get_row_name(zone)]
  if not row then return end

  row.style = "se_zonelist_row_button"
  ---@type LuaGuiElement[]
  local elements = row.children[1].children

  -- Color name label based on zone type
  elements[3].style.font_color = Zone.get_print_color(zone)

  -- Rest of the row cells (-priority) should have white text
  for i = 4, (#elements - 1) do
    elements[i].style.font_color = {1, 1, 1}
  end

  local priority_label = row.children[1].priority
  if priority_label then
    priority_label.style.font_color = _get_priority_color(tonumber(priority_label.caption) or 0)
  end
end

---Creates the header row for the Universe Explorer.
---@param parent LuaGuiElement Header row flow
---@param name string|LocalisedString Name to display to player
---@param feature string Name of associated criterion
---@param tooltip string|LocalisedString Tooltip
---@param width? uint Override width
---@param left_align? boolean Center aligns if nil/false
local function _make_zone_list_header_cell(parent, name, feature, tooltip, width, left_align)
  local flow = parent.add{
    type = "flow",
    name = feature,
    direction = "horizontal",
    style = "se_zonelist_header_cell_flow"
  }

  if width then flow.style.width = width end
  if left_align then flow.style.horizontal_align = "left" end

  flow.add{
    type = "checkbox",
    name = feature,
    caption = name,
    state = false,
    tags = {
      action = Zonelist.action_header_row_button,
      feature = feature
    },
    tooltip = tooltip,
    style = "se_zonelist_sort_checkbox_inactive"
  }
end

---Creates the flags caption for a given zone.
---@param playerdata PlayerData Player data table
---@param forcedata ForceData Force data
---@param zone AnyZoneType|SpaceshipType Zone or spaceship
local function _make_zone_list_flags_caption(playerdata, forcedata, zone)
  local flags = playerdata.zonelist_enabled_flags --[[@as Flags]]
  local caption = ""

  if flags.visited and playerdata.visited_zone and
      playerdata.visited_zone[zone.index] and zone.type ~= "spaceship" then
    ---@cast zone -SpaceshipType
    caption = caption .. "[img=entity/character]"
  end

  local zone_assets = forcedata.zone_assets and forcedata.zone_assets[zone.index]
  if zone_assets then
    if flags.launchpad and next(zone_assets.rocket_launch_pad_names) then
      caption = caption .. "[img=entity/" .. Launchpad.name_rocket_launch_pad .. "]"
    end
    if flags.landingpad and next(zone_assets.rocket_landing_pad_names) then
      caption = caption .. "[img=entity/" .. Landingpad.name_rocket_landing_pad .. "]"
    end
    if flags.energy_beam_defence and zone_assets.energy_beam_defence and
        next(zone_assets.energy_beam_defence) then
      caption = caption .. "[img=entity/" .. EnergyBeamDefence.name_energy_beam_defence .. "]"
    end
  end

  if flags.meteor_defence and zone.meteor_defences and next(zone.meteor_defences) then
    caption = caption .. "[img=entity/" .. Meteor.name_meteor_defence_container .. "]"
  end

  if flags.meteor_point_defence and zone.meteor_point_defences and
      next(zone.meteor_point_defences) then
    caption = caption .. "[img=entity/" .. Meteor.name_meteor_point_defence_container .. "]"
  end

  if flags.vault and playerdata.track_glyphs and (zone.glyph ~= nil) then
    caption = caption .. "[img=entity/se-pyramid-a]"
  end

  if flags.ruin and (zone.interburbulator or zone.ruins) then
    caption = caption .. "[img=virtual-signal/se-ruin]"
  end

  if flags.surface and zone.surface_index then
    caption = caption .. "[img=se-landfill-scaffold]"
  end

  return caption
end

---Creates a row button for a given zone in the Universe Explorer.
---@param playerdata PlayerData Player data
---@param force_name string name
---@param parent LuaGuiElement Gui element in which to place the zone row
---@param zone AnyZoneType|SpaceshipType Zone or spaceship to add
local function _make_zone_list_row(playerdata, force_name, parent, zone)
  local row_button = parent.add{
    type = "button",
    name = _get_row_name(zone),
    tags = {
      action = Zonelist.action_zone_row_button,
      zone_type = zone.type,
      zone_index = zone.index
    },
    style = (playerdata.zonelist_selected_zone == zone) and
      "se_zonelist_row_button_selected" or "se_zonelist_row_button"
  }

  local row_flow = row_button.add{ -- Flow
    type = "flow",
    name = "row_flow",
    direction = "horizontal",
    ignored_by_interaction = true
  }

  row_flow.add{ -- Hierarchy
    type = "label",
    caption = _hierarchy_strings[Zone.get_full_type(zone)] or " ✖",
    style = "se_zonelist_row_cell_heirarchy"
  }
  row_flow.add{ -- Zone icon
    type = "label",
    caption = "[img=" .. Zone.get_icon(zone) .. "]",
    style = "se_zonelist_row_cell_type"
  }
  row_flow.add{ -- Name
    type = "label",
    caption = Zone.get_print_name(zone, true, true),
    style = "se_zonelist_row_cell_name"
  }.style.font_color = Zone.get_print_color(zone)
  row_flow.add{ -- Radius
    type = "label",
    caption = zone.radius and (string.format("%.0f", zone.radius)) or "-",
    style = "se_zonelist_row_cell_numeric"
  }


  do -- Primary resource
    local caption = (zone.primary_resource and zone.type ~= "orbit") and
      "[img=entity/".. zone.primary_resource.."]" or "-"

    if zone.is_homeworld then
      caption = "[img=item/se-core-fragment-omni]"
    end

    row_flow.add{
      type="label",
      caption=caption,
      style="se_zonelist_row_cell_resource"
    }
  end

  row_flow.add{ -- Attrition
    type = "label",
    caption = string.format("%.2f", Zone.get_bot_attrition(zone)),
    style = "se_zonelist_row_cell_numeric"
  }
  row_flow.add{ -- Threat
    type = "label",
    caption = string.format("%.0f%%", Zone.get_threat(zone) * 100),
    style = "se_zonelist_row_cell_numeric"
  }
  row_flow.add{ -- Solar
    type = "label",
    caption = string.format("%.0f%%", Zone.get_display_light_percent(zone) * 100),
    style = "se_zonelist_row_cell_numeric"
  }

  row_flow.add{ -- Flags
    type = "label",
    name = "flags",
    caption = _make_zone_list_flags_caption(playerdata, storage.forces[force_name], zone),
    style = "se_zonelist_row_cell_flags"
  }

  local ref = playerdata.zonelist_reference_zone --[[@as AnyZoneType|SpaceshipType]]
  local delta_v_caption
  if ref == zone then
    delta_v_caption = "-"
  elseif ref.type == "anomaly" or zone.type == "anomaly" then
    delta_v_caption = "?"
  else
    delta_v_caption = string.format("%.0f", Zone.get_travel_delta_v(ref, zone))
  end
  row_flow.add{ -- Delta v
    type = "label",
    name = "delta_v",
    caption = delta_v_caption,
    style = "se_zonelist_row_cell_numeric"
  }

  local priority = Zone.get_priority(zone, force_name)
  row_flow.add{ -- Priority
    type = "label",
    name = "priority",
    caption = priority,
    style = "se_zonelist_row_cell_numeric"
  }.style.font_color = _get_priority_color(priority)

  -- Alter font color of child labels if this zone is selected
  if playerdata.zonelist_selected_zone == zone then
    local elements = row_button.children[1].children --[[@as LuaGuiElement[] ]]
    for i = 3, #elements do
      elements[i].style.font_color = {0, 0, 0}
    end
  end

  return row_button
end

---Creates label/value gui elements in the zone data details section.
---@param parent LuaGuiElement Parent element to create flow in
---@param label? string|LocalisedString Label caption
---@param value? string|LocalisedString Value caption
---@param tooltip? string|LocalisedString Tooltip for the value, if any
---@param tags? Tags Tags the value gui element should have
local function _make_zone_data_row(parent, label, value, tooltip, tags)
  local flow = parent.add{
    type = "flow",
    direction = "horizontal"
  }
  flow.add{
    type = "label",
    caption = label,
    style = "se_zonelist_zone_data_label"
  }
  flow.add{
    type = "empty-widget",
    style = "se_relative_properties_spacer"
  }
  flow.add{
    type = "label",
    caption = value,
    tooltip = tooltip,
    tags = tags,
    style = tags and "se_zonelist_zone_data_value_link" or "se_zonelist_zone_data_value"
  }
end

---Creates resource-icon/progressbar gui elements in the zone data resources section.
---@param parent LuaGuiElement Pareng gui element to place new elements in
---@param resource string Resource name, used to get sprite
---@param value number Passed on to progressbar
---@param tooltip string|LocalisedString Tooltip, if any
local function _make_zone_data_resource_row(parent, resource, value, tooltip)
  local flow = parent.add{
    type = "flow",
    direction = "horizontal",
    style = "se_horizontal_flow_centered"
  }
  flow.add{
    type = "sprite",
    sprite = "entity/" .. resource,
    style = "se_zonelist_zone_data_resource_icon"
  }
  flow.add{
    type = "progressbar",
    value = value,
    caption = {"entity-name." .. resource},
    tooltip = tooltip,
    style = "se_zonelist_zone_data_resource_bar"
  }.style.color = _get_resource_bar_color(resource)
end

---Updates the states/styles of the GUI's column headers.
---@param root LuaGuiElement
---@param sort_criteria {name:string, direction:integer}[]
local function _update_zone_list_header_states(root, sort_criteria)
  local frame = util.get_gui_element(root, Zonelist.path_list_header_frame) --[[@as LuaGuiElement]]

  local map = {}
  for _, criterion in pairs(sort_criteria) do
    map[criterion.name] = criterion.direction
  end

  local hierarchy = frame.hierarchy.hierarchy
  if map.hierarchy then
    hierarchy.state = map.hierarchy == -1 and true or false
    hierarchy.style = "se_zonelist_sort_checkbox"
  else
    hierarchy.style = "se_zonelist_sort_checkbox_inactive"
  end

  local zone_name = frame.zone_name.zone_name
  zone_name.style = "se_zonelist_sort_checkbox"
  if map.zone_name then
    zone_name.state = map.zone_name == 1 and true or false
  else
    zone_name.state = true
  end

  for i = 2, #frame.children do
    if i ~= 3 then -- skipm zone name, since it gets special handling
      local button = frame.children[i].children[1]
      local name = button.name

      if map[name] then
        button.state = map[name] == 1 and true or false
        button.style = "se_zonelist_sort_checkbox"
      else
        button.style = "se_zonelist_sort_checkbox_inactive"
      end
    end
  end
end

---Tries to update the preview frame without refreshing the entire zone data section if possible
---@param player LuaPlayer Player
---@param parent LuaGuiElement Parent of preview frame
---@param tags Tags
local function _update_preview_frame(player, parent, tags)
  local preview = parent[Zonelist.name_zone_data_preview_frame]
  if not tags.item_name then return end

  local pin = Pin.from_item_name(player, tags.item_name --[[@as string]])
  if not pin then return end

  local location = Location.from_reference(pin.location_reference)
  if not location or not location.zone then return end

  if preview.tags.item_name == tags.item_name then
    util.delete_tags(preview, {"item_name", "zone_type", "zone_index"})
    Zonelist.update_zone_data(player, location.zone)
    MapView.gui_update(player, location.zone)
  else
    util.update_tags(preview,
      {item_name=tags.item_name, zone_type=location.zone.type, zone_index=location.zone.index})

    -- Update view button tags
    local view_button = util.get_gui_element(parent, Zonelist.path_zone_data_view_surface_button)
    if view_button then util.update_tags(view_button, {item_name=tags.item_name}) end

    if preview.map then
      preview.map.position = location.position
      preview.map.zoom = pin.zoom and (pin.zoom * 4) or 0.75
    elseif preview.camera then
      preview.camera.position = location.position
      preview.camera.zoom = pin.zoom or 0.25
    else -- if surface preview had been disabled
      Zonelist.update_zone_data(player, location.zone)
      MapView.gui_update(player, location.zone)
    end
  end
end

---Toggles visibility of the search textfield.
---@param textfield LuaGuiElement Text field
---@param button LuaGuiElement Search button
---@param new_state? boolean true/false to show/hide; nil toggles to opposite of current state
local function _toggle_search_visibility(textfield, button, new_state)
  if new_state == nil then new_state = not textfield.visible end
  if new_state then
    textfield.visible = true
    button.style = "se_zonelist_search_button_down"
    button.sprite = "utility/search"
    textfield.focus()
    textfield.select_all()
  else
    textfield.text = ""
    textfield.visible = false
    button.style = "se_zonelist_search_button"
    button.sprite = "utility/search"
  end
end

---Returns whether a given force is able to use the Universe Explorer.
---@param force_name string Force name
---@return boolean is_unlocked
function Zonelist.is_unlocked(force_name)
  return storage.debug_view_all_zones or
    (storage.forces[force_name] and
      storage.forces[force_name].satellites_launched >= Zonelist.nb_satellites_to_unlock)
end

---Returns the the appropriate `LocalisedString` for why a given force cannot use the universe
---explorer.
---@param force_name string Force name
---@return LocalisedString reason
function Zonelist.get_unlock_requirement_string(force_name)
  if is_player_force(force_name) then
    return {"space-exploration.universe-explorer-requires-satellite",
      Zonelist.nb_satellites_to_unlock - storage.forces[force_name].satellites_launched}
  else
    return {"space-exploration.cannot-use-with-force"}
  end
end

---Returns the zonelist gui, if it is open.
---@param player LuaPlayer Player
---@return LuaGuiElement? root
function Zonelist.get(player)
  return player.gui.screen[Zonelist.name_root]
end

---Makes the zonelist and mapview zone data GUI elements.
---@param parent LuaGuiElement Parent element to insert section in
function Zonelist.make_zone_data_section(parent)
  local right_flow = parent.add{
    type = "flow",
    name = Zonelist.name_right_flow,
    direction = "vertical",
    style = "se_zonelist_right_flow"
  }

  local container_frame = right_flow.add{
    type = "frame",
    name = Zonelist.name_zone_data_container_frame,
    direction = "vertical",
    style = "se_zonelist_zone_data_main_frame"
  }
  do -- Subheader
    local subheader = container_frame.add{
      type = "frame",
      name = Zonelist.name_zone_data_subheader_frame,
      style = "se_zonelist_zone_data_subheader_frame"
    }
    subheader.add{
      type = "label",
      name = Zonelist.name_zone_data_header_label,
      caption = "",
      style = "se_zonelist_zone_data_header_label"
    }
    subheader.add{type="empty-widget", style="se_relative_properties_spacer"}
    subheader.add{
      type = "sprite",
      sprite = "virtual-signal/se-accolade",
      tooltip = {"space-exploration.priority-tooltip"},
      style = "se_zonelist_zone_data_priority_sprite"
    }
    local priority_flow = subheader.add{
      type = "flow",
      name = Zonelist.name_zone_data_priority_flow,
      direction = "horizontal",
      style = "se_zonelist_priority_threshold_flow"
    }
    priority_flow.add{
      type = "textfield",
      name = Zonelist.name_zone_data_priority_textfield,
      numeric = true,
      allow_negative = true,
      lose_focus_on_confirm = true,
      clear_and_focus_on_right_click = true,
      tags = {action = Zonelist.action_zone_priority_textfield},
      tooltip = {"space-exploration.priority-textfield-tooltip"},
      style = "se_zonelist_priority_textfield"
    }
    local priority_buttons_flow = priority_flow.add{
      type="flow",
      name = Zonelist.name_zone_data_priority_sub_flow,
      direction = "vertical",
      style = "se_zonelist_priority_small_button_flow"
    }
    priority_buttons_flow.add{
      type = "button",
      caption = "▲",
      tooltip = {"space-exploration.priority-increase-tooltip"},
      tags = {
        action = Zonelist.action_zone_priority_change_button,
        value = 1
      },
      style = "se_zonelist_priority_threshold_small_button"
    }
    priority_buttons_flow.add{
      type = "button",
      caption = "▼",
      tooltip = {"space-exploration.priority-decrease-tooltip"},
      tags = {
        action = Zonelist.action_zone_priority_change_button,
        value = -1
      },
      style = "se_zonelist_priority_threshold_small_button"
    }
  end

  do -- Scroll-pane
    local scroll_pane = container_frame.add{
      type = "scroll-pane",
      name = Zonelist.name_zone_data_content_scroll_pane,
      vertical_scroll_policy = "auto-and-reserve-space",
      horizontal_scroll_policy = "never",
      style = "se_zonelist_zone_data_content_scroll_pane"
    }

    scroll_pane.add{
      type = "checkbox",
      name = "details-header",
      caption = {"space-exploration.zonelist-details-header"},
      state = false,
      tags = {action=Zonelist.action_zone_data_content_header, name="details"},
      style = "se_zonelist_zone_data_header_checkbox"
    }
    scroll_pane.add{
      type = "flow",
      name = "details",
      direction = "vertical",
      style = "se_zonelist_zone_data_content_sub_flow"
    }

    scroll_pane.add{
      type = "checkbox",
      name = "resources-header",
      caption = {"space-exploration.zonelist-resources-header"},
      state = false,
      tags = {action=Zonelist.action_zone_data_content_header, name="resources"},
      style = "se_zonelist_zone_data_header_checkbox"
    }
    scroll_pane.add{
      type = "flow",
      name = "resources",
      direction = "vertical",
      style = "se_zonelist_zone_data_content_sub_flow"
    }

    scroll_pane.add{
      type = "checkbox",
      name = "environment-header",
      caption = {"space-exploration.zonelist-environment-header"},
      state = false,
      tags = {action=Zonelist.action_zone_data_content_header, name="environment"},
      style = "se_zonelist_zone_data_header_checkbox"
    }
    scroll_pane.add{
      type = "flow",
      name = "environment",
      direction = "vertical",
      style = "se_zonelist_zone_data_content_sub_flow"
    }

    scroll_pane.add{
      type = "checkbox",
      name = "spaceships-header",
      caption = {"space-exploration.zonelist-spaceships-header"},
      state = false,
      tags = {action=Zonelist.action_zone_data_content_header, name="spaceships"},
      style = "se_zonelist_zone_data_header_checkbox"
    }
    scroll_pane.add{
      type = "flow",
      name = "spaceships",
      direction = "vertical",
      style = "se_zonelist_zone_data_content_sub_flow"
    }

    scroll_pane.add{
      type = "checkbox",
      name = "pins-header",
      caption = {"space-exploration.zonelist-pins-header"},
      state = false,
      tags = {action=Zonelist.action_zone_data_content_header, name="pins"},
      style = "se_zonelist_zone_data_header_checkbox"
    }
    scroll_pane.add{
      type = "flow",
      name = "pins",
      direction = "vertical",
      style = "se_zonelist_zone_data_content_sub_flow"
    }.style.horizontal_align = "center"
  end

  -- Preview frame
  right_flow.add{
    type = "frame",
    name = Zonelist.name_zone_data_preview_frame,
    style = "se_zonelist_preview_frame"
  }

  do -- Buttons
    local button_flow = right_flow.add{
      type = "flow",
      name = Zonelist.name_zone_data_bottom_button_flow,
      direction = "horizontal"
    }
    button_flow.add{
      type = "sprite-button",
      name = Zonelist.name_zone_data_delete_surface_button,
      style = "se_zonelist_tool_button_red",
      tags = {action=Zonelist.action_delete_surface_button},
      sprite = "utility/trash"
    }
    button_flow.add{
      type = "sprite-button",
      name = Zonelist.name_zone_data_trim_surface_button,
      sprite = "se-cut",
      tags = {action=Zonelist.action_trim_surface_button},
      style = "se_zonelist_tool_button_red"
    }
    button_flow.add{
      type = "sprite-button",
      name = Zonelist.name_zone_data_confirm_extinction_button,
      sprite = "se-biter-white",
      tags = {action=Zonelist.action_confirm_extinction_button},
      style = "se_zonelist_tool_button_blue"
    }
    button_flow.add{
      type = "sprite-button",
      name = Zonelist.name_zone_data_scan_surface_button,
      sprite = "se-scan",
      tags = {action=Zonelist.action_scan_surface_button},
      style = "se_zonelist_tool_button_blue"
    }
    button_flow.add{
      type = "button",
      name = Zonelist.name_zone_data_view_surface_button,
      caption = {"space-exploration.zonelist-view-surface"},
      tooltip = {"space-exploration.zonelist-view-surface"},
      tags = {action=Zonelist.action_view_surface_button},
      style = "se_zonelist_view_button"
    }
  end
end

---Toggles the GUI on/off.
---@param player LuaPlayer Player
function Zonelist.toggle(player)
  local root = Zonelist.get(player)
  if root then
    Zonelist.close(player)
  else
    Zonelist.open(player)
  end
end

---Opens the universe explorer GUI for a given player. If passed a zone, will pre-select that zone.
---@param player LuaPlayer Player
---@param zone? AnyZoneType|SpaceshipType Zone or spaceship, assumed to be already validated
function Zonelist.open(player, zone)
  local playerdata = get_make_playerdata(player)
  local force_name = player.force.name
  local forcedata = storage.forces[force_name]

  -- Update zonelist if already open and given zone doesn't match current selection
  if Zonelist.get(player) then
    if zone and zone ~= playerdata.zonelist_selected_zone then
      Zonelist.update(player, zone)
    end

    return
  end

  if not is_player_force(force_name) then
    return player.print({"space-exploration.cannot-use-with-force"})
  end
  if not Zonelist.is_unlocked(force_name) then
    return player.print(Zonelist.get_unlock_requirement_string(force_name))
  end

  -- If previous selection was a spaceship, check if it's still valid
  local selected = playerdata.zonelist_selected_zone
  if selected and selected.type == "spaceship" and not selected.valid then
    playerdata.zonelist_selected_zone = nil
  end

  playerdata.zonelist_selected_zone = zone or
    playerdata.zonelist_selected_zone or
    Zone.from_surface(player.surface) or
    Zone.from_zone_index(forcedata.homeworld_index) or
    Zone.get_default()
  playerdata.zonelist_reference_zone = playerdata.zonelist_reference_zone or
    Zone.from_surface(player.surface) or
    Zone.from_zone_index(forcedata.homeworld_index) or
    Zone.get_default()
  playerdata.zonelist_sort_criteria = playerdata.zonelist_sort_criteria or
    {{name="hierarchy", direction=1}}
  playerdata.zonelist_filter_excludes = playerdata.zonelist_filter_excludes or {}
  playerdata.zonelist_priority_threshold = playerdata.zonelist_priority_threshold or 0
  playerdata.zonelist_show_surface_preview = (playerdata.zonelist_show_surface_preview == nil) and
    true or playerdata.zonelist_show_surface_preview
  playerdata.zonelist_enabled_flags = (playerdata.zonelist_enabled_flags == nil) and
    {visited=true, launchpad=true, landingpad=true, vault=true, ruin=true} or
    playerdata.zonelist_enabled_flags

  local root = player.gui.screen.add{
    type = "frame",
    name = Zonelist.name_root,
    direction = "vertical",
    tags = {
      zone_type = playerdata.zonelist_selected_zone.type,
      zone_index = playerdata.zonelist_selected_zone.index
    },
    style = "se_zonelist_root_frame"
  }
  root.force_auto_center()

  do -- Titlebar
    local titlebar_flow = root.add{
      type = "flow",
      direction = "horizontal",
      style = "se_relative_titlebar_flow"
    }
    titlebar_flow.drag_target = root
    titlebar_flow.add{
      type = "sprite",
      sprite = "se-map-gui-universe-explorer",
      ignored_by_interaction = true,
      style = "se_lifesupport_expanded_title_icon"
    }
    titlebar_flow.add{
      type = "label",
      caption = {"space-exploration.zonelist-window-title"},
      ignored_by_interaction = true,
      style = "frame_title"
    }
    titlebar_flow.add{
      type = "empty-widget",
      ignored_by_interaction = true,
      style = "se_titlebar_drag_handle"
    }

    titlebar_flow.add{ -- Starmap button
      type = "button",
      caption = {"space-exploration.simple-a-b-space", "[img=se-map-gui-starmap]",
        {"space-exploration.interstellar-map" }},
      style = "se_titlebar_frame_button",
      tooltip = {"space-exploration.interstellar-map"},
      tags = {action=Zonelist.action_open_interstellar_map}
    }
    titlebar_flow.add{ -- Show/hide surface preview
      type = "sprite-button",
      sprite = playerdata.zonelist_show_surface_preview and "se-show-black" or "se-show-white",
      hovered_sprite = "se-show-black",
      clicked_sprite = "se-show-black",
      style = playerdata.zonelist_show_surface_preview and
          "se_frame_action_button_active" or "frame_action_button",
      tooltip = {"space-exploration.zonelist-show-surface-preview"},
      tags = {action=Zonelist.action_show_preview_frame}
    }
    titlebar_flow.add{ -- Close button
      type = "sprite-button",
      sprite = "utility/close",
      tags = {action=Zonelist.action_close_button},
      style="close_button"
    }
  end

  local main_flow = root.add{
    type = "flow",
    name = Zonelist.name_main_flow,
    direction = "horizontal",
    style = "se_zonelist_main_flow"
  }
  local left_flow = main_flow.add{
    type = "flow",
    name = Zonelist.name_left_flow,
    direction = "vertical",
    style = "se_zonelist_left_flow"
  }

  do -- Toolbar
    local toolbar_flow = left_flow.add{
      type = "flow",
      name = Zonelist.name_toolbar_flow,
      direction = "horizontal",
      style = "se_zonelist_toolbar_flow"
    }

    local zone_type_filters_flow = toolbar_flow.add{
      type = "flow",
      direction = "horizontal",
      style = "se_zonelist_zone_type_filters_flow"
    }
    for _, zone_type in pairs({"star", "planet", "planet-orbit", "moon", "moon-orbit",
        "asteroid-belt", "asteroid-field", "anomaly", "spaceship"}) do
      if zone_type ~= "anomaly" or
          Zone.is_visible_to_force(Zone.from_name("Foenestra") --[[@as AnomalyType]], force_name) then
        zone_type_filters_flow.add{
          type = "sprite-button",
          sprite = "virtual-signal/se-" .. zone_type,
          tags = {
            action = Zonelist.action_zone_type_toggle_button,
            type = zone_type
          },
          tooltip = {"space-exploration.zonelist_filter_tooltip",
              {"space-exploration.zonelist_filter_" .. zone_type}},
          style = playerdata.zonelist_filter_excludes[zone_type] and
            "se_zonelist_filter_button" or "se_zonelist_filter_button_down"
        }
      end
    end

    toolbar_flow.add{type="empty-widget", style="se_zonelist_toolbar_separator"}

    local zone_priority_threshold_flow = toolbar_flow.add{
      type = "flow",
      name = Zonelist.name_priority_threshold_container,
      direction = "horizontal",
      style = "se_zonelist_priority_threshold_flow"
    }
    zone_priority_threshold_flow.add{
      type = "sprite-button",
      sprite = "virtual-signal/se-accolade",
      tooltip = {"space-exploration.zonelist_priority_threshold_toggle"},
      tags = {action = Zonelist.action_priority_threshold_toggle_button},
      style = playerdata.zonelist_filter_excludes["low-priority"] and
        "se_zonelist_filter_button_down" or "se_zonelist_filter_button"
    }
    zone_priority_threshold_flow.add{
      type = "textfield",
      name = Zonelist.name_priority_threshold_textfield,
      numeric = true,
      allow_negative = true,
      lose_focus_on_confirm = true,
      clear_and_focus_on_right_click = true,
      text = "" .. playerdata.zonelist_priority_threshold,
      tags = {action = Zonelist.action_priority_threshold_textfield},
      tooltip = {"space-exploration.zonelist_priority_threshold_field"},
      style = "se_zonelist_priority_textfield"
    }
    local priority_buttons_flow = zone_priority_threshold_flow.add{
      type="flow",
      direction = "vertical",
      style = "se_zonelist_priority_small_button_flow"
    }
    priority_buttons_flow.add{
      type = "button",
      caption = "▲",
      tooltip = {"space-exploration.zonelist_priority_threshold_plus_button"},
      tags = {
        action = Zonelist.action_priority_threshold_change_button,
        value = 1
      },
      style = "se_zonelist_priority_threshold_small_button"
    }
    priority_buttons_flow.add{
      type = "button",
      caption = "▼",
      tooltip = {"space-exploration.zonelist_priority_threshold_minus_button"},
      tags = {
        action = Zonelist.action_priority_threshold_change_button,
        value = -1
      },
      style = "se_zonelist_priority_threshold_small_button"
    }

    toolbar_flow.add{type="empty-widget", style="se_zonelist_toolbar_separator"}

    toolbar_flow.add{
      type = "sprite-button",
      sprite = "se-flag-settings-white",
      hovered_sprite = "se-flag-settings-black",
      clicked_sprite = "se-flag-settings-black",
      tags = {action=Zonelist.action_flags_button},
      tooltip = {"space-exploration.zonelist-configure-flags"},
      style = "se_zonelist_filter_button"
    }

    toolbar_flow.add{
      type = "empty-widget",
      style = "se_relative_properties_spacer"
    }

    local search_flow = toolbar_flow.add{
      type = "flow",
      name = Zonelist.name_search_flow,
      direction = "horizontal",
      style = "se_zonelist_search_flow"
    }
    local search_textfield = search_flow.add{
      type = "textfield",
      name = Zonelist.name_search_textfield,
      lose_focus_on_confirm = true,
      clear_and_focus_on_right_click = true,
      tags = {action = Zonelist.action_search_textfield},
      style = "se_zonelist_search_textfield"
    }
    search_textfield.visible = false

    search_flow.add{
      type = "sprite-button",
      name = Zonelist.name_search_button,
      sprite = "utility/search",
      tags = {action=Zonelist.action_search_button},
      tooltip = {"gui.search-with-focus", "__CONTROL__focus-search__"},
      style = "se_zonelist_filter_button"
    }
  end

  local list_frame = left_flow.add{
    type = "frame",
    name = Zonelist.name_list_container_frame,
    direction = "vertical",
    style = "se_zonelist_left_frame"
  }

  do -- Header row
    local header_frame = list_frame.add{
      type = "frame",
      name = Zonelist.name_list_header_frame,
      style = "se_zonelist_header_frame"
    }

    _make_zone_list_header_cell(header_frame, "[img=virtual-signal/se-hierarchy]", "hierarchy",
        {"space-exploration.zonelist-heading-hierarchy"})
    _make_zone_list_header_cell(header_frame, "[img=virtual-signal/se-planet]", "zone_type",
        {"space-exploration.zonelist-heading-type"}, 56)
    _make_zone_list_header_cell(header_frame, {"space-exploration.name"}, "zone_name",
        {"space-exploration.name"}, 210, true)
    _make_zone_list_header_cell(header_frame, "[img=virtual-signal/se-radius]", "radius",
        {"space-exploration.zonelist-heading-radius"})
    _make_zone_list_header_cell(header_frame, "[img=item/se-core-fragment-omni]", "resource",
        {"space-exploration.zonelist-heading-primary-resource"})
    _make_zone_list_header_cell(header_frame, "[img=item/logistic-robot]", "attrition",
        {"space-exploration.zonelist-heading-attrition"})
    _make_zone_list_header_cell(header_frame, "[img=item/artillery-targeting-remote]", "threat",
        {"space-exploration.zonelist-heading-threat"})
    _make_zone_list_header_cell(header_frame, "[img=item/solar-panel]", "solar",
        {"space-exploration.zonelist-heading-solar"})
    _make_zone_list_header_cell(header_frame, "[img=se-flag-white]", "flags",
        {"space-exploration.zonelist-heading-flags"}, 100)
    _make_zone_list_header_cell(header_frame, "Δv", "delta_v",
        {"space-exploration.zonelist-heading-delta-v"})
    _make_zone_list_header_cell(header_frame, "[img=virtual-signal/se-accolade]", "priority",
        {"space-exploration.zonelist-heading-priority"})
  end

  local scroll_pane = list_frame.add{
    type = "scroll-pane",
    name = Zonelist.name_list_rows_scroll_pane,
    vertical_scroll_policy = "always",
    style = "se_zonelist_scroll_pane"
  }

  if (forcedata.satellites_launched or 0) < 19 and not storage.debug_view_all_zones then
    list_frame.add{
      type = "frame",
      direction = "horizontal",
      style = "se_zonelist_instruction_frame"
    }.add{
      type = "label",
      caption = {"space-exploration.remote-view-instruction"},
      style = "se_zonelist_instruction_label"
    }
  end

  -- Right flow
  Zonelist.make_zone_data_section(main_flow)
  Zonelist.update_zone_data(player, playerdata.zonelist_selected_zone)

  -- Do this now, as it triggers an event, where other mods could destroy `root`.
  player.opened = root

  Zonelist.update(player)

  -- since the content is empty during on_gui_opened
  script.raise_event(Zonelist.on_zonelist_gui_opened, {
    player_index = player.index,
  })

  -- Scroll to selected zone
  if root.valid then
    local row = scroll_pane[_get_row_name(playerdata.zonelist_selected_zone)]
    if row and row.visible then
      scroll_pane.scroll_to_element(row, "top-third")
    end
  end
end

---Updates the flags cell for a given zone if specified, or for all zones if not specified.
---@param player LuaPlayer Player
---@param single_zone? AnyZoneType|SpaceshipType Zone or spaceship
function Zonelist.update_zone_flags(player, single_zone)
  local root = Zonelist.get(player)
  if not root then return end

  local scroll_pane = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  local playerdata = get_make_playerdata(player)
  local forcedata = storage.forces[player.force.name]
  local get_zone_from_tags = util.get_zone_from_tags

  if single_zone then
    local row = scroll_pane[_get_row_name(single_zone)]
    if row then
      row.row_flow.flags.caption =
          _make_zone_list_flags_caption(playerdata, forcedata, single_zone)
    end
  else
    for _, row in pairs(scroll_pane.children) do
      local flags = row.row_flow.flags
      local zone = get_zone_from_tags(row.tags)

      ---@cast zone -StarType
      if zone and flags then
        flags.caption = _make_zone_list_flags_caption(playerdata, forcedata, zone)
      end
    end
  end
end

---Updates a given zone's priority for a given force.
---@param force_name string Name of force
---@param zone AnyZoneType|SpaceshipType Zone or spaceship
---@param value integer Either new priority value, or desired change from existing value
---@param is_delta? boolean Whether `value` should be used as give, are added to existing priority
function Zonelist.update_zone_priority(force_name, zone, value, is_delta)
  local priority

  -- Actually update the priority in zone data
  local forcedata = storage.forces[force_name]
  if zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    forcedata.spaceship_priorities = forcedata.spaceship_priorities or {}
    forcedata.spaceship_priorities[zone.index] = core_util.clamp(
      is_delta and ((forcedata.spaceship_priorities[zone.index] or 0) + value) or value,
      -Zonelist.priority_max,
      Zonelist.priority_max
    )
    priority = forcedata.spaceship_priorities[zone.index]
  else
    ---@cast zone -SpaceshipType
    forcedata.zone_priorities = forcedata.zone_priorities or {}
    forcedata.zone_priorities[zone.index] = core_util.clamp(
      is_delta and ((forcedata.zone_priorities[zone.index] or 0) + value) or value,
      -Zonelist.priority_max,
      Zonelist.priority_max
    )
    priority = forcedata.zone_priorities[zone.index]
  end

  -- Update the GUI
  for _, player in pairs(game.forces[force_name].connected_players) do
    local root = Zonelist.get(player)
    if root then
      local zonelist_scroll =
          util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane) --[[@as LuaGuiElement]]
      local row = zonelist_scroll[_get_row_name(zone)]

      -- Update value in list
      local cell = row and row.row_flow and row.row_flow.priority or nil
      if cell then
        cell.caption = priority

        -- Only apply color if zone or is _not_ selected
        if zone ~= util.get_zone_from_tags(root.tags) then
          cell.style.font_color = _get_priority_color(priority)
        end
      end

      -- Update value in zone data section
      local textfield = util.get_gui_element(root[Zonelist.name_main_flow],
        Zonelist.path_zone_data_priority_textfield)

      if textfield and util.get_zone_from_tags(textfield.tags) == zone then
        textfield.text = tostring(priority)
      end
    end
    local map_gui = MapView.gui_get(player)
    if map_gui then
      local textfield = util.get_gui_element(map_gui, Zonelist.path_zone_data_priority_textfield)

      if textfield and util.get_zone_from_tags(textfield.tags) == zone then
        textfield.text = tostring(priority)
      end
    end
  end
end

---Updates the list of zones displayed in the Universe Explorer.
---@param player LuaPlayer Player
function Zonelist.update_list(player)
  local root = Zonelist.get(player)
  if not root then return end

  local force_name = player.force.name
  local playerdata = get_make_playerdata(player)

  local zones_list = {}
  local all_zones = zones_list

  -- Build list in the hierarchy order as it is the most dificult to sort
  Zone.insert_if_visible_to_force(zones_list, storage.universe.anomaly, force_name)
  for _, star in pairs(storage.universe.stars) do
    Zone.insert_if_visible_to_force(zones_list, star.orbit, force_name)
    for _, planet_or_belt in pairs(star.children) do
      Zone.insert_if_visible_to_force(zones_list, planet_or_belt, force_name)
      if planet_or_belt.orbit then
        Zone.insert_if_visible_to_force(zones_list, planet_or_belt.orbit, force_name)
      end
      if planet_or_belt.children then
        for _, moon in pairs(planet_or_belt.children) do
          Zone.insert_if_visible_to_force(zones_list, moon, force_name)
          Zone.insert_if_visible_to_force(zones_list, moon.orbit, force_name)
        end
      end
    end
  end

  -- Gather asteroid fields and the anomaly
  for _, zone in pairs(storage.universe.space_zones) do
    Zone.insert_if_visible_to_force(zones_list, zone, force_name)
  end

  -- Gather spaceships
  for _, spaceship in pairs(storage.spaceships) do
    Zone.insert_if_visible_to_force(zones_list, spaceship, force_name)
  end

  -- Apply filters selected by player
  if playerdata.zonelist_filter_excludes and next(playerdata.zonelist_filter_excludes) then
    local temp_list = zones_list
    zones_list = {}
    for _, zone in pairs(temp_list) do
      if not playerdata.zonelist_filter_excludes["low-priority"] or
        Zone.get_priority(zone, force_name) >= playerdata.zonelist_priority_threshold then
        if zone.type == "orbit" then
          ---@cast zone OrbitType
          if zone.parent.type == "star" then
            if not playerdata.zonelist_filter_excludes["star"] then
              table.insert(zones_list, zone)
            end
          elseif zone.parent.type == "planet" then
            if not playerdata.zonelist_filter_excludes["planet-orbit"] then
              table.insert(zones_list, zone)
            end
          elseif zone.parent.type == "moon" then
            if not playerdata.zonelist_filter_excludes["moon-orbit"] then
              table.insert(zones_list, zone)
            end
          end
        else
          if not playerdata.zonelist_filter_excludes[zone.type] then
            table.insert(zones_list, zone)
          end
        end
      end
    end
  end

  -- Get search text
  local zonelist_search_textfield = util.get_gui_element(root, Zonelist.path_search_textfield)
  local search

  if zonelist_search_textfield then
    search = string.trim(zonelist_search_textfield.text)
    if search == "" then search = nil end
  end


  -- Use search text to further refine selection
  if search then
    local search_number = tonumber(search)
    local search_is_number = search_number and (search_number .. "" == search)
    local resource_names = {}
    for resource_name, _ in pairs(storage.resources_and_controls.resource_settings) do
      if string.find(string.lower(resource_name), string.lower(search), 1, true) then
        table.insert(resource_names, resource_name)
      end
    end

    local temp_list = zones_list
    zones_list = {}
    for _, zone in pairs(temp_list) do
      if string.find(string.lower(zone.name), string.lower(search), 1, true) then
        table.insert(zones_list, zone)
      elseif search_is_number and search_number == zone.index then
        table.insert(zones_list, zone)
      elseif next(resource_names) and zone.type ~= "orbit" then
        ---@cast zone -OrbitType
        for _, resource_name in pairs(resource_names) do
          if zone.controls and zone.controls[resource_name] and
              zone.controls[resource_name].size > 0 and
              zone.controls[resource_name].richness > 0 then
            table.insert(zones_list, zone)
            break
          end
        end
      end

      if is_debug_mode then
        -- allow searching which (discovered) zone has a ruin by name
        for ruin_name, _ in pairs(zone.ruins or {}) do
          if string.find(ruin_name, string.lower(search), 1, true) then
            table.insert(zones_list, zone)
          end
        end
      end
    end
  end

  -- Sort
  -- We set criteria in reverse order.
  -- Eg {"name", "type"} = sort alphabetically then by type, so type has priority,
  -- then alphabetical within type,
  -- If "hierarchy" or "name" are there, then later ones are removed as they won't do anything.

  if not playerdata.zonelist_sort_criteria or not next(playerdata.zonelist_sort_criteria) then
    playerdata.zonelist_sort_criteria = {{name="hierarchy", direction=1}}
  end

  local sort_functions = {}
  for _, criterion in pairs(playerdata.zonelist_sort_criteria) do
    local sort_function

    if criterion.name == "flags" then
      sort_function = function (a,b)
        return Zone.get_flags_weight(a, force_name, playerdata) <
            Zone.get_flags_weight(b, force_name, playerdata)
      end
    elseif criterion.name == "delta_v" then
      sort_function = function (a, b)
        local ref = playerdata.zonelist_reference_zone --[[@as AnyZoneType|SpaceshipType]]
        local delta_v_ref_a = (ref.type == "anomaly" or a.type == "anomaly") and
            math.huge or Zone.get_travel_delta_v(ref, a)
        local delta_v_ref_b = (ref.type == "anomaly" or b.type == "anomaly") and
            math.huge or Zone.get_travel_delta_v(ref, b)
        return delta_v_ref_a < delta_v_ref_b
      end
    elseif criterion.name == "priority" then
      sort_function = function (a,b)
        return Zone.get_priority(a, force_name) < Zone.get_priority(b, force_name)
      end
    else
      sort_function = _sorting_functions[criterion.name]
    end

    local sort_function_with_direction = (criterion.direction == -1) and
        (function(a,b) return not sort_function(a,b) end) or sort_function

    -- Insert in regular order, primary sort criterion first
    table.insert(sort_functions, 1, sort_function_with_direction)
  end

  local combined_sort_function = function (a,b)
    for _, sort_f in pairs(sort_functions) do
      local sort_result = sort_f(a,b)
      if sort_result ~= sort_f(b,a) then -- If sort(a,b) == sort(b,a) then a == b
        return sort_result
      end
      -- If the two are equal, use the next method
    end
    return a.name < b.name -- Default to name if nothing else
  end

  table.sort(zones_list, combined_sort_function)

  local zonelist_scroll = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not zonelist_scroll then return end

  if not next(zonelist_scroll.children) then
    -- Since the scroll pane is empty, create every row that apears in `zones_list`
    for _, zone in pairs(zones_list) do
      _make_zone_list_row(playerdata, force_name, zonelist_scroll, zone)
    end
  else
    -- Gather visible zones into a table with easily searchable keys
    local visible_zones = {}
    for i, zone in pairs(zones_list) do visible_zones[_get_row_name(zone)] = i end

    -- Iterate over all zones, since we might need to hide some rows that should not be visible
    for _, zone in pairs(all_zones) do
      local id = _get_row_name(zone)
      local row = zonelist_scroll[id]
      local new_index = visible_zones[id]

      if new_index then
        row = row or _make_zone_list_row(playerdata, force_name, zonelist_scroll, zone)
        row.visible = true
        local old_index = row.get_index_in_parent()
        if new_index ~= old_index then zonelist_scroll.swap_children(new_index, old_index) end
      elseif row then
        row.visible = false
      end
    end
  end
end

---Updates the `delta_v` cells in the GUI, measured from the given `ref`.
---@param parent LuaGuiElement Zonelist Scroll-pane
---@param ref AnyZoneType|SpaceshipType Reference zone
function Zonelist.update_delta_v(parent, ref)
  local get_zone_from_tags = util.get_zone_from_tags
  for _, row in pairs(parent.children) do
    local zone = get_zone_from_tags(row.tags)
    local label = row.row_flow["delta_v"]

    ---@cast zone -StarType
    if zone and label then
      if zone == ref then
        label.caption = "-"
      elseif zone.type == "anomaly" or ref.type == "anomaly" then
        label.caption = "?"
      else
        label.caption = string.format("%.0f", Zone.get_travel_delta_v(ref, zone))
      end
    end
  end
end

---Deletes the row of a specific zone in the zone list.
---@param player LuaPlayer Player
---@param zone AnyZoneType|SpaceshipType Zone or spaceship
function Zonelist.delete_zone_in_list(player, zone)
  local root = Zonelist.get(player)
  if not root then return end

  local scroll_pane =
      util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane) --[[@as LuaGuiElement]]
  local row = scroll_pane[_get_row_name(zone)]

  if row then row.destroy() end
end

---Refreshes the info of a specific zone in the zone list. Call when zone info changes.
---@param player LuaPlayer Player
---@param zone AnyZoneType|SpaceshipType Zone or spaceship
function Zonelist.update_zone_in_list(player, zone)
  Zonelist.delete_zone_in_list(player, zone)
  Zonelist.update_list(player)
end

---Updates the given `LuaGuiElement` with data from the given zone.
---@param player LuaPlayer Player
---@param zone AnyZoneType|SpaceshipType Zone or spaceship
---@param parent? LuaGuiElement Parent flow of the zone data section
---@param scroll_to_top? boolean Whether to scroll to top or not
function Zonelist.update_zone_data(player, zone, parent, scroll_to_top)
  -- Get gui element if not specified
  if not parent then
    local root = Zonelist.get(player)
    if not root then return end

    parent = util.get_gui_element(root, Zonelist.path_zone_data_flow)
    if not parent then return end
  end

  local playerdata = get_make_playerdata(player)
  local force_name = player.force.name
  local forcedata = storage.forces[force_name]
  local force_assets = zone.type ~= "spaceship" and
    Zone.get_force_assets(force_name, zone.index) or nil

  local container = parent[Zonelist.name_zone_data_container_frame]
  local subheader = container[Zonelist.name_zone_data_subheader_frame]
  local name_label = subheader[Zonelist.name_zone_data_header_label]
  local priority_flow = subheader[Zonelist.name_zone_data_priority_flow]
  local priority_textfield = priority_flow[Zonelist.name_zone_data_priority_textfield]
  local priority_sub_flow = priority_flow[Zonelist.name_zone_data_priority_sub_flow]
  local priority_inc = priority_sub_flow.children[1]
  local priority_dec = priority_sub_flow.children[2]
  local content = container[Zonelist.name_zone_data_content_scroll_pane]
  local details = content.details
  local resources_header = content["resources-header"]
  local resources = content.resources
  local environment_header = content["environment-header"]
  local environment = content.environment
  local spaceships_header = content["spaceships-header"]
  local spaceships = content.spaceships
  local pins_header = content["pins-header"]
  local pins = content.pins
  local preview = parent[Zonelist.name_zone_data_preview_frame]
  local button_flow = parent[Zonelist.name_zone_data_bottom_button_flow]

  local pin_item_name, pin_position, pin_zoom

  do -- Get info about previous pin, if one was being previewed
    local preview_tags = preview.tags
    if zone == util.get_zone_from_tags(preview_tags) and preview_tags.item_name then
      local pin = Pin.from_item_name(player, preview_tags.item_name)

      if pin then
        local location = Location.from_reference(pin.location_reference)

        if location then
          pin_item_name = preview_tags.item_name
          pin_position = location.position
          pin_zoom = pin.zoom
        end
      end
    end
  end

  -- Scroll to top in scroll-pane, if showing a different zone from before
  if scroll_to_top then content.scroll_to_top() end

  -- Update selected zone name and priority
  name_label.caption = Zone.get_print_name(zone)

  do -- Priority
    priority_textfield.caption = "" .. Zone.get_priority(zone, force_name)
    util.update_tags(priority_textfield, {zone_type=zone.type, zone_index=zone.index})
    util.update_tags(priority_inc, {zone_type=zone.type, zone_index=zone.index})
    util.update_tags(priority_dec, {zone_type=zone.type, zone_index=zone.index})
  end

  do -- Details
    details.clear()

    _make_zone_data_row(details, {"space-exploration.zone-tooltip-type"},
      {"", "[img=", Zone.get_icon(zone), "] ", Zone.type_title(zone)})

    if zone.parent then
      _make_zone_data_row(
        details,
        {"space-exploration.zone-tooltip-parent"},
        Zone.get_print_name(zone.parent, true),
        nil,
        {
          action = Zonelist.action_zone_link,
          zone_type = zone.parent.type,
          zone_index = zone.parent.index
        }
      )
    end

    if zone.radius then
      _make_zone_data_row(details, {"space-exploration.zone-tooltip-radius"},
          string.format("%.0f", zone.radius))
    end

    if Zone.is_solid(zone) then
      ---@cast zone PlanetType|MoonType
      _make_zone_data_row(details,
        {"space-exploration.zone-tooltip-daynight"},
        {"time-symbol-minutes", string.format("%.2f", zone.ticks_per_day / 60 / 60 )},
        {"space-exploration.tick-time-unit", zone.ticks_per_day})
    end

    if zone.type ~= "spaceship" then
      ---@cast zone -SpaceshipType
      local interference_type = "radiation"
      if zone.type == "anomaly" then
        ---@cast zone AnomalyType
        interference_type = "spacial-distortion"
      elseif Zone.is_solid(zone) then
        ---@cast zone PlanetType|MoonType
        interference_type = "wind"
      end

      _make_zone_data_row(details, {"space-exploration.zone-tooltip-bot-attrition",
        {"space-exploration.attrition-type-" .. interference_type}},
        string.format("%.2f", Zone.get_bot_attrition(zone)))

      local threat = Zone.get_threat(zone)

      _make_zone_data_row(details, {"space-exploration.zone-tooltip-threat"},
          string.format("%.0f%%", threat * 100))

      local hazards = Zone.get_hazards(zone)
      if next(hazards) then
        local hazards_label = {"", "[img=utility/warning_icon] "}
        local hazards_tooltip = {""}
        for _, hazard in pairs(hazards) do
          table.insert(hazards_label, {"space-exploration.zone-hazard-" .. hazard})
          table.insert(hazards_label, ", ")
          table.insert(hazards_tooltip, {"space-exploration.zone-hazard-tooltip-" .. hazard})
          table.insert(hazards_tooltip, "\n")
        end
        -- Remove last comma and \n
        table.remove(hazards_label, #hazards_label)
        table.remove(hazards_tooltip, #hazards_tooltip)

        _make_zone_data_row(details, {"space-exploration.zone-tooltip-hazards"},
            hazards_label, hazards_tooltip)
      end
    end

    local origin = Zone.from_surface(player.surface)
    if (not origin) and playerdata and playerdata.character and playerdata.character.valid and
        playerdata.character.surface then
      origin = Zone.from_surface(playerdata.character.surface)
    end
    if origin and origin ~= zone then
      local delta_v = Zone.get_travel_delta_v(origin, zone)
      local value
      if delta_v > 0 then
        if origin.type == "anomaly" or zone.type == "anomaly" then
          value = "?"
        else
          value = string.format("%.0f", delta_v)
        end
        _make_zone_data_row(
          details,
          {"space-exploration.zone-tooltip-delta-v", origin.name},
          value
        )
      end
    end

    if zone.type == "spaceship" then
      ---@cast zone SpaceshipType
      local spaceship = zone
      local closest =
          Zone.find_nearest_zone(spaceship.space_distortion, spaceship.stellar_position,
          spaceship.star_gravity_well, spaceship.planet_gravity_well)

      if closest then
        if Zone.is_visible_to_force(closest, player.force.name) then
          _make_zone_data_row(
            details,
            {"space-exploration.zone-tooltip-closest"},
            Zone.get_print_name(closest),
            nil,
            {
              action = Zonelist.action_zone_link,
              zone_type = closest.type,
              zone_index = closest.index
            }
          )
        else
          _make_zone_data_row(
            details,
            {"space-exploration.zone-tooltip-closest"},
            {"", "[img=" .. Zone.get_icon(closest) .. "] ",
              {"space-exploration.unknown-of-type", Zone.type_title(closest)}}
          )
        end
      end

      local destination = Spaceship.get_destination_zone(spaceship)
      local tags
      if destination then
        tags = {
          action = Zonelist.action_zone_link,
          zone_type = destination.type,
          zone_index = destination.index
        }
      end
      _make_zone_data_row(details, {"space-exploration.zone-tooltip-destination"},
        destination and Zone.get_print_name(destination) or "-", nil, tags)
    end

    _make_zone_data_row(details, {"space-exploration.zone-tooltip-solar"},
      string.format("%.0f%%", Zone.get_display_light_percent(zone) * 100))

    if is_debug_mode or (table_size(storage.spaceships) > 0) then
      _make_zone_data_row(details, {"space-exploration.zone-tooltip-automation-signal"},
        "[img=" .. Zone.get_icon(zone) .. "] " .. zone.index,
        {"", {"space-exploration.simple-a-b", {"virtual-signal-name."..Zone.get_signal_name(zone)},
        " " .. zone.index }, "\n", {"space-exploration.zone-tooltip-automation-used"}})
    end
    -- Arcosphere information
    if zone.type == "asteroid-field" and forcedata.zone_arcospheres then
      ---@cast zone AsteroidFieldType
      local arcos_collected = 0
      local arcos_launched = 0
      if forcedata.zone_arcospheres[zone.index] then
        arcos_collected = forcedata.zone_arcospheres[zone.index].arcospheres_collected
        arcos_launched = forcedata.zone_arcospheres[zone.index].arcosphere_collectors_launched
      end
      _make_zone_data_row(details,
          {"space-exploration.zone-tooltip-arcospheres"}, arcos_collected .. "/" .. arcos_launched)
    end

    if zone.type ~= "spaceship" then
      ---@cast zone -SpaceshipType
      -- flags
      local has_glyph = playerdata.track_glyphs and (zone.glyph ~= nil)
      local has_ruin = zone.interburbulator or zone.ruins
      local has_visited = playerdata.visited_zone and playerdata.visited_zone[zone.index]
      local has_launchpad = force_assets and next(force_assets.rocket_launch_pad_names) or false
      local has_landingpad = force_assets and next(force_assets.rocket_landing_pad_names) or false
      local has_beam_defence = force_assets and force_assets.energy_beam_defence and
          next(force_assets.energy_beam_defence) or false
      local has_md = zone.meteor_defences and next(zone.meteor_defences)
      local has_mpd = zone.meteor_point_defences and next(zone.meteor_point_defences)
      local has_surface = zone.surface_index ~= nil

      if has_glyph or has_visited or has_launchpad or has_landingpad or has_beam_defence or
        has_md or has_mpd or has_ruin or has_surface then
        local flow = details.add{
          type = "flow",
          direction = "horizontal"
        }
        flow.add{
          type = "label",
          caption = {"space-exploration.zone-tooltip-flags"},
          style = "se_zonelist_zone_data_label"
        }
        flow.add{
          type = "empty-widget",
          style = "se_relative_properties_spacer"
        }
        local flags = {}
        if has_visited then
          flags["entity/character"] = {"space-exploration.zone-visited"}
        end
        if has_launchpad then
          flags["entity/" .. Launchpad.name_rocket_launch_pad] =
            {"entity-name." .. Launchpad.name_rocket_launch_pad}
        end
        if has_landingpad then
          flags["entity/" .. Landingpad.name_rocket_landing_pad] =
            {"entity-name." .. Landingpad.name_rocket_landing_pad}
        end
        if has_beam_defence then
          flags["entity/" .. EnergyBeamDefence.name_energy_beam_defence] =
            {"entity-name." .. EnergyBeamDefence.name_energy_beam_defence}
        end
        if has_md then
          flags["entity/" .. Meteor.name_meteor_defence_container] =
            {"entity-name." .. Meteor.name_meteor_defence_container}
        end
        if has_mpd then
          flags["entity/" .. Meteor.name_meteor_point_defence_container] =
            {"entity-name." .. Meteor.name_meteor_point_defence_container}
        end
        if has_glyph then
          flags["entity/se-pyramid-a"] = {"space-exploration.mysterious-structure"}
        end
        if has_ruin then
          flags["virtual-signal/se-ruin"] = {"space-exploration.ruin"}
        end
        if has_surface then
          flags["se-landfill-scaffold"] = {"space-exploration.zone-has-surface"}
        end

        for sprite, tooltip in pairs(flags) do
          flow.add{type = "sprite", sprite = sprite, tooltip = tooltip,
              style="se_zonelist_flag_icon"}
        end
      end
    end

    if is_debug_mode and zone.special_type then
      _make_zone_data_row(details, "Special type", zone.special_type)
    end

  end

  do -- Resources
    resources.clear()

    local has_resources = false
    local mapgen
    local surface = Zone.get_surface(zone)

    if surface then mapgen = surface.map_gen_settings end

    if zone.type ~= "spaceship" and zone.type ~= "orbit" then
      ---@cast zone -SpaceshipType, -OrbitType
      local fsrs = {}
      local max_fsr = 0

      for resource_name, _ in pairs(storage.resources_and_controls.resource_settings) do
        if mapgen then
          if mapgen.autoplace_controls[resource_name] then
            local fsr = Universe.estimate_resource_fsr(mapgen.autoplace_controls[resource_name])
            if fsr > 0 then
              max_fsr = math.max(max_fsr, fsr)
              table.insert(fsrs, {name=resource_name, fsr=fsr})
            end
          end
        else
          if zone.controls[resource_name] then
            local fsr = Universe.estimate_resource_fsr(zone.controls[resource_name])
            if fsr > 0 then
              max_fsr = math.max(max_fsr, fsr)
              table.insert(fsrs, {name=resource_name, fsr=fsr})
            end
          end
        end
      end

      if next(fsrs) then has_resources = true end

      table.sort(fsrs, function(a,b) return a.fsr > b.fsr end)

      for _, fsr in pairs(fsrs) do
        local resource_name = fsr.name
        local tooltip = {"space-exploration.zonelist-resource-bar-tooltip",
          "[img=entity/"..resource_name.."]", {"entity-name."..resource_name}}

        if mapgen then
          table.insert(tooltip, string.format("%.0f%%",
              mapgen.autoplace_controls[resource_name].frequency * 100))
          table.insert(tooltip, string.format("%.0f%%",
              mapgen.autoplace_controls[resource_name].size * 100))
          table.insert(tooltip, string.format("%.0f%%",
              mapgen.autoplace_controls[resource_name].richness * 100))
        else
          local frequency_multiplier = Zone.get_frequency_multiplier(zone)
          table.insert(tooltip, string.format("%.0f%%",
              zone.controls[resource_name].frequency * frequency_multiplier * 100))
          table.insert(tooltip, string.format("%.0f%%",
              zone.controls[resource_name].size * 100))
          table.insert(tooltip, string.format("%.0f%%",
              zone.controls[resource_name].richness * 100))
        end

        if resource_name == "se-cryonite" or resource_name == "se-vulcanite" or
            resource_name == "se-vitamelange" then
          tooltip[1] = "space-exploration.zonelist-resource-bar-tooltip-extended"
          table.insert(tooltip,
              {"space-exploration.resource-terrain-required-" .. resource_name})
        end

        local percentage = fsr.fsr/max_fsr ^ (1/3)

        _make_zone_data_resource_row(resources, resource_name, percentage, tooltip)
      end

      if Zone.is_solid(zone) then
        ---@cast zone PlanetType|MoonType
        resources.add{
          type = "label",
          name = "resources_disclaimer",
          caption = {"space-exploration.zonelist-resources-disclaimer"},
          tooltip = {"space-exploration.zonelist-resources-disclaimer-tooltip"}
        }.style.font_color = {0.5, 0.5, 0.5}
      end
    end

    if has_resources then
      resources_header.visible = true
      resources.visible = not resources_header.state and true or false
    else
      resources_header.visible = false
      resources.visible = false
    end
  end

  do -- Environment
    environment.clear()

    -- tags
    if zone.tags then
      environment_header.visible = true
      environment.visible = not environment_header.state and true or false

      local caption = nil
      for _, tag in pairs(zone.tags) do
        if not string.find(tag, "enemy", 1, true) then
          if caption == nil then
            caption = {"space-exploration.climate_" .. tag}
          else
            caption = {"space-exploration.simple-a-b-comma", caption,
                {"space-exploration.climate_" .. tag}}
          end
        end
      end
      if zone.is_homeworld then
        caption = {"space-exploration.climate_homeworld"}
      end
      environment.add{type="label", caption={"space-exploration.zone-tooltip-climate"},
          style="se_zonelist_zone_data_label"}
      environment.add{type="label", caption=caption, style="se_zonelist_zone_data_value_multiline"}
    else
      environment_header.visible = false
      environment.visible = false
    end
  end

  do -- Spaceships
    spaceships.clear()

    local zone_spaceships = {}

    -- Collect anchored spaceships
    if zone.surface_index then
      for _, spaceship in pairs(storage.spaceships) do
        if spaceship.zone_index == zone.index and spaceship.force_name == force_name then
          table.insert(zone_spaceships, spaceship)
        end
      end
    end

    if next(zone_spaceships) then
      spaceships_header.visible = true
      spaceships.visible = not spaceships_header.state and true or false

      for _, spaceship in pairs(zone_spaceships) do
        spaceships.add{
          type = "label",
          caption = Zone.get_print_name(spaceship),
          style = "se_zonelist_zone_data_value_link",
          tags = {
            action = Zonelist.action_zone_link,
            zone_type = spaceship.type,
            zone_index = spaceship.index
          }
        }.style.maximal_width = 256
      end
    else
      spaceships_header.visible = false
      spaceships.visible = false
    end
  end

  do -- Pins
    pins.clear()

    local zone_pins = Pin.get_zone_pins(player, zone)
    local tooltip_base = playerdata.zonelist_show_surface_preview and
      "space-exploration.zonelist-pin-tooltip" or
      "space-exploration.zonelist-pin-no-preview-tooltip"

    if next(zone_pins) then
      pins_header.visible = true
      pins.visible = not pins_header.state and true or false

      local frame = pins.add{
        type = "frame",
        style = "se_zonelist_zone_data_pins_frame"
      }

      local tbl = frame.add{
        type = "table",
        column_count = 6,
        style = "slot_table"
      }

      for k, pin in pairs(zone_pins) do
        local name = Location.from_reference(pin.location_reference).name or ""

        tbl.add{
          type = "sprite-button",
          sprite = Pin.signal_to_sprite_path(pin.signal),
          tooltip = {tooltip_base,
              {Pin.get_tooltip_for_pin(playerdata, k), Zone.get_print_name(zone), name}},
          tags = {
            action = Zonelist.action_pin_button,
            item_name = k
          },
          style = (k == pin_item_name) and "se_slot_button_active" or "slot_button"
        }
      end
    else
      pins_header.visible = false
      pins.visible = false
    end
  end

  do -- Map preview
    if preview then

      -- Clear preview frame tags if no pin was being viewed
      if not pin_item_name then preview.tags = {} end

      preview.clear()

      if playerdata.zonelist_show_surface_preview then
        preview.visible = true
        local surface = Zone.get_surface(zone)

        if surface then
          local position = {0, 0}
          local zoom

          if playerdata.surface_positions and playerdata.surface_positions[surface.index] then
            position = playerdata.surface_positions[surface.index]
          end
          if zone.type == "spaceship" then
            ---@cast zone SpaceshipType
            if zone.known_tiles_average_x and zone.known_tiles_average_y then
              position = {zone.known_tiles_average_x, zone.known_tiles_average_y}
            elseif zone.console and zone.console.valid then
              position = zone.console.position
            end
            if zone.known_bounds then
              local dims = util.vectors_delta(zone.known_bounds.left_top,
                  zone.known_bounds.right_bottom)
              zoom = core_util.clamp(7 / math.max(dims.x, dims.y), 0.04, 0.35)
            end
            preview.add{
              type = "camera",
              name = "camera",
              position = pin_position or position,
              zoom = pin_zoom or zoom or 0.25,
              surface_index = surface.index,
              style = "se_zonelist_preview_camera"
            }
          else
            ---@cast zone -SpaceshipType
            preview.add{
              type = "minimap",
              name = "map",
              position = pin_position or position,
              zoom = pin_zoom and (pin_zoom * 4) or 0.75,
              surface_index = surface.index,
              style = "se_zonelist_preview_minimap"
            }
          end
        else
          preview.add{
            type = "label",
            name = "preview_text",
            caption = {"space-exploration.zonelist-preview-no-surface"},
            style = "se_zonelist_preview_label"
          }
        end
      else
        preview.visible = false
      end
    end
  end

  do -- Buttons
    local view_button = button_flow[Zonelist.name_zone_data_view_surface_button]
    local scan_button = button_flow[Zonelist.name_zone_data_scan_surface_button]
    local confirm_extinction_button =
        button_flow[Zonelist.name_zone_data_confirm_extinction_button]
    local trim_button = button_flow[Zonelist.name_zone_data_trim_surface_button]
    local delete_button = button_flow[Zonelist.name_zone_data_delete_surface_button]

    local zone_tags = {zone_type=zone.type, zone_index=zone.index}
    local print_name = Zone.get_print_name(zone)

    -- Include position in tags for spaceships
    if zone.known_tiles_average_x and zone.known_tiles_average_y then
      zone_tags.position = {x=zone.known_tiles_average_x, y=zone.known_tiles_average_y}
    elseif zone.console and zone.console.valid then
      zone_tags.position = zone.console.position
    end

    -- Clear `position` tag in case there is one from the previously selected zone
    util.delete_tags(view_button, {"position"})

    util.update_tags(view_button, zone_tags)
    util.update_tags(scan_button, zone_tags)
    util.update_tags(confirm_extinction_button, zone_tags)
    util.update_tags(trim_button, zone_tags)
    util.update_tags(delete_button, zone_tags)

    -- Reset button clicks
    util.update_tags(trim_button, {clicks=0})
    util.update_tags(delete_button, {clicks=0})
    util.update_tags(delete_button, {abandon=false})

    -- Update view surface button with active pin information, if any
    if pin_item_name then
      util.update_tags(view_button, {item_name=pin_item_name})
    else
      util.delete_tags(view_button, {"item_name"})
    end

    -- View surface button
    view_button.tooltip = {"space-exploration.view-zone-surface-button-tooltip", print_name}

    do -- Scan surface button
      if forcedata.is_scanning then
        scan_button.enabled = true
        scan_button.sprite = "se-stop-white"
        scan_button.tooltip = {"space-exploration.stop-scan-zone-button",
          {"space-exploration.stop-scan-zone-button-tooltip", forcedata.scanning_started_by or "Herobrine"}}
      else
        scan_button.sprite = "se-scan"

        if not RemoteView.is_unlocked(player) then
          scan_button.enabled = false
          scan_button.tooltip = {"space-exploration.scan-zone-button",
            {"space-exploration.scan-zone-button-disabled-tooltip"}}
        elseif zone.type == "spaceship" then
          ---@cast zone SpaceshipType
          scan_button.enabled = false
          scan_button.tooltip = {"space-exploration.scan-zone-button",
            {"space-exploration.scan-zone-button-spaceship-tooltip"}}
        else
          ---@cast zone -SpaceshipType
          scan_button.enabled = true
          scan_button.tooltip = {"space-exploration.scan-zone-button",
            {"space-exploration.scan-zone-button-tooltip"}}
        end
      end
    end

    do -- Confirm extinction button
      local tooltip
      if Zone.is_solid(zone) then
        ---@cast zone PlanetType|MoonType
        if not zone.surface_index then
          confirm_extinction_button.enabled = false
          tooltip = {"space-exploration.generic-surface-doesnt-exist"}
        else
          confirm_extinction_button.enabled = true
          local threat = Zone.get_threat(zone)
          if threat == 0 then
            confirm_extinction_button.enabled = false
            tooltip = {"space-exploration.confirm-extinction-button-already-extinct"}
          elseif threat == 0.01 and Zone.is_biter_meteors_hazard(zone) then
            confirm_extinction_button.enabled = false
            tooltip = {"space-exploration.confirm-extinction-button-already-extinct-biter-meteors"}
          else
            tooltip = {"space-exploration.confirm-extinction-button-tooltip", print_name,
              Zone.is_biter_meteors_hazard(zone) and 1 or 0}
          end
        end
      else
        ---@cast zone -PlanetType, -MoonType
        confirm_extinction_button.enabled = false
        tooltip = {"space-exploration.confirm-extinction-button-not-applicable"}
      end
      confirm_extinction_button.tooltip = {"space-exploration.confirm-extinction-button", tooltip}
    end

    do -- Delete/trim surface buttons
      local trim_button_tooltip, delete_button_tooltip
      if zone.type == "spaceship" then
        ---@cast zone SpaceshipType
        trim_button.enabled = false
        trim_button_tooltip = {"space-exploration.trim-zone-not-applicable"}

        if Spaceship.is_on_own_surface(zone) then
          delete_button.enabled = true
          delete_button_tooltip = {"space-exploration.delete-zone-button-abandon-only", print_name}
        else
          delete_button.enabled = false
          delete_button_tooltip = {"space-exploration.delete-zone-fail-spaceship"}
        end
      else
        ---@cast zone -SpaceshipType
        if Zone.get_surface(zone) then
          trim_button.enabled = true
          trim_button_tooltip = {"space-exploration.trim-zone-button-tooltip", print_name}

          delete_button.enabled = true
          delete_button_tooltip = {"space-exploration.delete-zone-button-tooltip", print_name}
        else
          trim_button.enabled = false
          trim_button_tooltip = {"space-exploration.generic-surface-doesnt-exist"}

          delete_button.enabled = false
          delete_button_tooltip = {"space-exploration.generic-surface-doesnt-exist"}
        end
      end
      trim_button.sprite = "se-cut"
      trim_button.tooltip = {"space-exploration.trim-zone-button", trim_button_tooltip}

      delete_button.sprite = "utility/trash"
      delete_button.tooltip = {"space-exploration.delete-zone-button", delete_button_tooltip}
    end
  end
end

---Updates the Universe Explorer list and zone data sections.
---@param player LuaPlayer Player
---@param zone? AnyZoneType|SpaceshipType Zone or spaceship that will be selected after update
function Zonelist.update(player, zone)
  local root = Zonelist.get(player)
  if not root then return end

  local playerdata = get_make_playerdata(player)
  local selected = playerdata.zonelist_selected_zone --[[@as AnyZoneType|SpaceshipType]]
  local zone_data =
      util.get_gui_element(root, Zonelist.path_zone_data_flow) --[[@as LuaGuiElement]]
  local is_new_selection

  if zone and zone ~= selected then
    is_new_selection = true

    local scroll_pane =
        util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane) --[[@as LuaGuiElement]]
    local row = scroll_pane[_get_row_name(zone)]

    _apply_unselected_row_style(scroll_pane, playerdata.zonelist_selected_zone)

    if row then
      _apply_selected_row_style(scroll_pane, zone)
      if row.visible then scroll_pane.scroll_to_element(row) end
    end

    playerdata.zonelist_selected_zone = zone
    util.update_tags(root, {zone_type=zone.type, zone_index=zone.index})
  end

  _update_zone_list_header_states(root, playerdata.zonelist_sort_criteria)
  Zonelist.update_list(player)
  Zonelist.update_zone_data(player, zone or selected, zone_data, is_new_selection)
end

---Closes the universe explorer GUI for a given player..
---@param player LuaPlayer Player
function Zonelist.close(player)
  local root = Zonelist.get(player)
  if root then root.destroy() end

  Zonelist.Flags.close(player)
end

---Updates the Universe Explorer's overhead button.
---@param player LuaPlayer Player
function Zonelist.update_overhead_button(player)
  local button_flow = mod_gui.get_button_flow(player)
  if not button_flow then return end

  local button_name = Zonelist.name_button_overhead_explorer
  local button = button_flow[Zonelist.name_button_overhead_explorer]

  if player.mod_settings[Zonelist.name_setting_overhead_explorer].value == true then
    local force_name = player.force.name

    button = button or button_flow.add{
      type = "sprite-button",
      name = button_name,
      sprite = "se-map-gui-universe-explorer"
    }

    if Zonelist.is_unlocked(force_name) then
      button.enabled = true
      button.tooltip = {"space-exploration.zonelist-window-title"}
    else
      button.enabled = false
      button.tooltip = Zonelist.get_unlock_requirement_string(force_name)
    end
  elseif button then
    button.destroy()
  end
end

---Handles clicks on zonelist GUI elements as well as on some MapView Gui elements.
---@param event EventData.on_gui_click Event data
function Zonelist.on_gui_click(event)
  if not event.element.valid then return end

  -- Overhead button
  if event.element.name == Zonelist.name_button_overhead_explorer then
    Zonelist.toggle(game.get_player(event.player_index) --[[@as LuaPlayer]])
    return
  end

  local element = event.element
  local tags = element.tags --[[@as Tags]]
  local action = tags.action

  -- Handle zone links
  if action == Zonelist.action_zone_link then
    local player = game.get_player(event.player_index)
    ---@cast player -?
    local zone = util.get_zone_from_tags(tags)

    if zone and Zone.is_visible_to_force(zone, player.force.name) then
      if zone.type == "star" then
        ---@cast zone OrbitType
        zone = zone.orbit
      end
      ---@cast zone -StarType
      player.play_sound{path="utility/gui_click"}
      Zonelist.open(player, zone)
    end

    return
  end

  local root = gui_element_or_parent(event.element, Zonelist.name_root) or
    gui_element_or_parent(event.element, MapView.name_gui_zone_details_root)
  if not root or not event.element.tags.action then return end

  local player = game.get_player(event.player_index)
  ---@cast player -?
  local playerdata = get_make_playerdata(player)

  if action == Zonelist.action_zone_row_button then
    local zone = util.get_zone_from_tags(tags)
    local scroll_pane = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)

    ---@cast zone -StarType
    if zone and scroll_pane then
      if event.shift == true then
        playerdata.zonelist_reference_zone = zone
        player.print({"space-exploration.zonelist-reference-zone-set", Zone.get_print_name(zone)})
        Zonelist.update_delta_v(scroll_pane, zone)
        -- Update list only if "delta_v" is being used for sorting
        for _, criterion in pairs(playerdata.zonelist_sort_criteria or {}) do
          if criterion.name == "delta_v" then Zonelist.update_list(player) break end
        end
      else
        if tags.last_click and (event.tick - tags.last_click) < 20 then
          Zonelist.close(player)
          RemoteView.start(player, zone)
        else
          if scroll_pane then
            _apply_unselected_row_style(scroll_pane, playerdata.zonelist_selected_zone)
            _apply_selected_row_style(scroll_pane, zone)
          end

          playerdata.zonelist_selected_zone = zone
          util.update_tags(element, {last_click=event.tick})
          util.update_tags(root, {zone_type=zone.type, zone_index=zone.index})
          Zonelist.update_zone_data(player, zone, nil, true)
        end
      end
    end
  elseif action == Zonelist.action_close_button then
    Zonelist.close(player)
  elseif action == Zonelist.action_flags_button then
    if Zonelist.Flags.get(player) then
      Zonelist.Flags.close(player)
    else
      Zonelist.Flags.open(player)
    end
  elseif action == Zonelist.action_show_preview_frame then
    if playerdata.zonelist_show_surface_preview then
      playerdata.zonelist_show_surface_preview = false
      element.style = "frame_action_button"
      element.sprite = "se-show-white"
    else
      playerdata.zonelist_show_surface_preview = true
      element.style = "se_frame_action_button_active"
      element.sprite = "se-show-black"
    end

    local zone = util.get_zone_from_tags(root.tags)
    ---@cast zone -StarType
    if zone then
      Zonelist.update_zone_data(player, zone)
      MapView.gui_update(player, zone)
    end
  elseif action == Zonelist.action_open_interstellar_map then
    Zonelist.close(player)
    MapView.start_interstellar_map(player)
  elseif action == Zonelist.action_zone_type_toggle_button then
    if event.control then
      for _, elem in pairs(element.parent.children) do
        playerdata.zonelist_filter_excludes[elem.tags.type] = nil
        elem.style = "se_zonelist_filter_button_down"
      end
    elseif event.shift == true then
      if playerdata.zonelist_filter_excludes[tags.type] then
        playerdata.zonelist_filter_excludes[tags.type] = nil
        element.style = "se_zonelist_filter_button_down"
      end
      for _, elem in pairs(element.parent.children) do
        if elem.tags.type ~= tags.type then
          playerdata.zonelist_filter_excludes[elem.tags.type] = true
          elem.style = "se_zonelist_filter_button"
        end
      end
    else
      if playerdata.zonelist_filter_excludes[tags.type] then
        playerdata.zonelist_filter_excludes[tags.type] = nil
        element.style = "se_zonelist_filter_button_down"
      else
        playerdata.zonelist_filter_excludes[tags.type] = true
        element.style = "se_zonelist_filter_button"
      end
    end
    Zonelist.update_list(player)
  elseif action == Zonelist.action_priority_threshold_toggle_button then
    playerdata.zonelist_filter_excludes = playerdata.zonelist_filter_excludes or {}
    if playerdata.zonelist_filter_excludes["low-priority"] then
      playerdata.zonelist_filter_excludes["low-priority"] = nil
      element.style = "se_zonelist_filter_button"
    else
      playerdata.zonelist_filter_excludes["low-priority"] = true
      element.style = "se_zonelist_filter_button_down"
    end

    Zonelist.update_list(player)
  elseif action == Zonelist.action_search_button then
    local textfield = element.parent[Zonelist.name_search_textfield]
    _toggle_search_visibility(textfield, element)
    Zonelist.update_list(player)
  elseif action == Zonelist.action_header_row_button then
    local criteria = playerdata.zonelist_sort_criteria or {}
    local criterion = tags.feature

    if criteria[#criteria].name == criterion then
      criteria[#criteria].direction = -1 * (criteria[#criteria].direction or 1)
    else
      if criterion == "hierarchy" or criterion == "zone_name" then
        -- These criteria are unique, no need to remember all the secondary criteria
        criteria = {}
      else
        for i, c in pairs(criteria) do
          if c.name == criterion then
            table.remove(criteria, i)
            break
          end
        end
      end

      table.insert(criteria, {name=criterion, direction = 1})
    end

    playerdata.zonelist_sort_criteria = criteria

    _update_zone_list_header_states(root, playerdata.zonelist_sort_criteria)
    Zonelist.update_list(player)
  elseif action == Zonelist.action_priority_threshold_change_button then
    playerdata.zonelist_priority_threshold =
      core_util.clamp(
        playerdata.zonelist_priority_threshold + tags.value,
        -Zonelist.priority_max,
        Zonelist.priority_max
      )
    local textfield = util.get_gui_element(root, Zonelist.path_priority_threshold_textfield)
    textfield.text = tostring(playerdata.zonelist_priority_threshold)
    -- Only update list if low-priority filter is active
    if playerdata.zonelist_filter_excludes["low-priority"] then
      Zonelist.update_list(player)
    end
  elseif action == Zonelist.action_zone_priority_change_button then
    local value = tags.value --[[@as uint]]
    local zone = util.get_zone_from_tags(tags)
    ---@cast zone -StarType
    if zone then
      Zonelist.update_zone_priority(player.force.name, zone, value, true)
      Zonelist.update_list(player)
    end
  elseif action == Zonelist.action_zone_data_content_header then
    local flow = element.parent[tags.name]
    if flow then
      flow.visible = not element.state and true or false
    end
  elseif action == Zonelist.action_pin_button then
    if tags.item_name then
      if event.button == defines.mouse_button_type.left then
        if event.shift or not playerdata.zonelist_show_surface_preview then
          -- Go to pin in nav-mode
          Zonelist.close(player)
          MapView.gui_close(player)
          Pin.do_pin(player, tags.item_name)
        else
          local container = gui_element_or_parent(element, Zonelist.name_right_flow)
          if container then
            -- Change pin styling
            for _, elem in pairs(element.parent.children) do
              if elem == element then
                elem.style = "se_slot_button_active"
              else
                elem.style = "slot_button"
              end
            end

            -- Update preview
            _update_preview_frame(player, container, tags)
          end
        end
      else
        Pin.modal_open(player, tags.item_name, "zonelist")
      end
    end
  elseif action == Zonelist.action_view_surface_button then
    if RemoteView.is_unlocked(player) then
      if tags.item_name then
        Zonelist.close(player)
        MapView.stop_map(player)
        Pin.do_pin(player, tags.item_name)
      else
        local zone = util.get_zone_from_tags(tags)
        ---@cast zone -StarType
        if zone then
          Zonelist.close(player)
          MapView.stop_map(player)
          RemoteView.start(player, zone, tags.position --[[@as MapPosition?]])

          -- testing aid: hold ctrl while clicking "View surface" to instantly teleport with your character
          if event.control and player.cheat_mode and player.admin and player.character then
            player.character.teleport(player.position, player.surface)
            player.exit_remote_view()
            player.create_local_flying_text{text = "Teleported to zone", position = player.position}
          end
        end
      end
    else
      player.print({"space-exploration.remote-view-requires-satellite"})
    end
  elseif action == Zonelist.action_scan_surface_button then
    local forcedata = storage.forces[player.force.name]
    local zone = util.get_zone_from_tags(tags)

    ---@cast zone -StarType
    if forcedata.is_scanning then
      Scanner.stop_scanning(player.force.name)
    elseif zone then
      Scanner.start_scanning(player.force.name, zone, player.name)
      Zonelist.update_zone_flags(player, zone)
    end
  elseif action == Zonelist.action_confirm_extinction_button then
    local zone = util.get_zone_from_tags(tags)
    ---@cast zone -StarType
    if zone and Zone.is_solid(zone) then
      ---@cast zone PlanetType|MoonType
      Zone.confirm_extinction(zone, event.player_index)
    end
  elseif action == Zonelist.action_trim_surface_button then
    if event.button == defines.mouse_button_type.right then
      Zonelist.update(player)
      MapView.gui_update(player)
    elseif (tags.clicks or 0) < 1 then
      element.sprite = "utility/check_mark"
      element.tooltip = {"space-exploration.zonelist-confirmation-tooltip"}
      util.update_tags(element, {clicks=1})
    else
      local zone = util.get_zone_from_tags(tags)

      if zone then
        local forcedata = storage.forces[player.force.name]
        if forcedata.is_scanning and forcedata.scanning_zone == zone then
          Scanner.stop_scanning(player.force.name)
        end
        Zone.trim_surface(zone, event.player_index)
      end

      Zonelist.update(player)
      MapView.gui_update(player)
    end
  elseif action == Zonelist.action_delete_surface_button then
    if event.button == defines.mouse_button_type.right then
      Zonelist.update(player)
      MapView.gui_update(player)
    elseif (tags.clicks or 0) < 1 then
      local zone = util.get_zone_from_tags(tags)
      if zone then
        if event.control and not event.shift then -- Check NOT shift just to make sure people aren't mashing ctrl+shift+click without reading.
          element.sprite = "utility/warning_icon"
          element.tooltip = {"space-exploration.abandon-surface-confirmation-tooltip", Zone.get_print_name(zone)}
          util.update_tags(element, {abandon=true, clicks=1})
        elseif zone.type ~= "spaceship" then
          ---@cast zone -SpaceshipType
          element.sprite = "utility/check_mark"
          element.tooltip = {"space-exploration.zonelist-confirmation-tooltip"}
          util.update_tags(element, {abandon=false, clicks=1})
        else
          -- Spaceship but didn't ctrl+click
          player.print({"space-exploration.delete-zone-button-abandon-only", Zone.get_print_name(zone)})
        end
      end
    else
      local zone = util.get_zone_from_tags(tags)
      if zone then
        if zone.type == "spaceship" then
          ---@cast zone SpaceshipType
          if tags.abandon and event.control and event.shift then
            if not Spaceship.is_on_own_surface(zone) then
              player.print({"space-exploration.delete-zone-fail-spaceship"})
              return
            end
            if not player.admin then
              player.print({"space-exploration.abandon-surface-fail-admin-only"})
              return
            end

            Spaceship.destroy(zone)
            Zone.clean_global_after_surface_deletion(zone)

            -- Universe Explorer can't really be in a "selected nothing" state, so change selection to the current zone or a default.
            local new_selection = Zone.from_surface(player.surface) or
              Zone.from_zone_index(storage.forces[player.force.name].homeworld_index) or
              Zone.get_default()

            Zonelist.delete_zone_in_list(player, zone)
            Zonelist.update(player, new_selection)
            MapView.gui_close(player)
            player.force.print({"space-exploration.abandon-surface-success", Zone.get_print_name(zone)})
          end
        else
          ---@cast zone -SpaceshipType
          local force_name = player.force.name
          local forcedata = storage.forces[force_name]

          local ignore_entities_from_force = nil
          if tags.abandon and event.control and event.shift then
            if player.admin then
              ignore_entities_from_force = force_name
            else
              player.print({"space-exploration.abandon-surface-fail-admin-only"})
              return
            end
          end

          if forcedata.is_scanning and forcedata.scanning_zone == zone then
            Scanner.stop_scanning(force_name)
          end

          local success = Zone.delete_surface(zone, event.player_index, ignore_entities_from_force)
          if success then
            Zonelist.update_zone_flags(player, zone)
            if ignore_entities_from_force then -- abandon
              player.force.print({"space-exploration.abandon-surface-success", Zone.get_print_name(zone)})
            end
          end
          Zonelist.update(player)
          MapView.gui_update(player, zone)
        end
      end
    end
  end
end
Event.addListener(defines.events.on_gui_click, Zonelist.on_gui_click)

---Handles player input in the priority input/threshold fields and search bar.
---@param event EventData.on_gui_text_changed Event data
function Zonelist.on_gui_text_changed(event)
  if not event.element.valid then return end

  local root = gui_element_or_parent(event.element, Zonelist.name_root) or
    gui_element_or_parent(event.element, MapView.name_gui_zone_details_root)
  if not root or not event.element.tags.action then return end

  local player = game.get_player(event.player_index)
  ---@cast player -?
  local playerdata = get_make_playerdata(player)
  local tags = event.element.tags --[[@as Tags]]
  local action = tags.action

  if action == Zonelist.action_priority_threshold_textfield then
    local value = tonumber(event.element.text) or 0
    playerdata.zonelist_priority_threshold =
      core_util.clamp(value, -Zonelist.priority_max, Zonelist.priority_max)
    if math.abs(value) > Zonelist.priority_max then
      event.element.text = "" .. playerdata.zonelist_priority_threshold
    end
    Zonelist.update_list(player)
  elseif action == Zonelist.action_search_textfield then
    Zonelist.update_list(player)
  elseif action == Zonelist.action_zone_priority_textfield then
    local zone = util.get_zone_from_tags(tags)
    local priority = tonumber(event.element.text)
    ---@cast zone -StarType
    if zone and priority then
      Zonelist.update_zone_priority(player.force.name, zone, priority)
      Zonelist.update_list(player)
    end
  end
end
Event.addListener(defines.events.on_gui_text_changed, Zonelist.on_gui_text_changed)

---Handles the player confirming their changes in the zone priority field.
---@param event EventData.on_gui_confirmed Event data
function Zonelist.on_gui_confirmed(event)
  if not event.element.valid then return end

  local root = gui_element_or_parent(event.element, Zonelist.name_root)
  if not root or not event.element.tags.action then return end

  local player = game.get_player(event.player_index)
  ---@cast player -?
  local tags = event.element.tags --[[@as Tags]]
  local action = tags.action

  if action == Zonelist.action_zone_priority_textfield then
    local zone = util.get_zone_from_tags(tags)
    ---@cast zone -StarType
    if zone then
      Zonelist.update_zone_priority(player.force.name, zone, (tonumber(event.element.text) or 0))
    end
  end
end
Event.addListener(defines.events.on_gui_confirmed, Zonelist.on_gui_confirmed)

---Focuses on the Universe Explorer search bar when appropriately triggered.
---@param event EventData.CustomInputEvent Event data
function Zonelist.focus_search(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = Zonelist.get(player)
  if not root then return end

  local textfield =
      util.get_gui_element(root, Zonelist.path_search_textfield) --[[@as LuaGuiElement]]
  local button = textfield.parent[Zonelist.name_search_button]
  if textfield then _toggle_search_visibility(textfield, button, true) end
end
Event.addListener("se-focus-search", Zonelist.focus_search)

---Handles gui being closed.
---@param event EventData.on_gui_closed Event data
function Zonelist.on_gui_closed(event)
  local element = event.element
  if element and element.valid and element.name == Zonelist.name_root then
    Zonelist.close(game.get_player(event.player_index) --[[@as LuaPlayer]])
  end
end
Event.addListener(defines.events.on_gui_closed, Zonelist.on_gui_closed)

---Handles changes to the overhead button setting.
---@param event EventData.on_runtime_mod_setting_changed Event data
function Zonelist.on_runtime_mod_setting_changed(event)
  if event.player_index and event.setting == Zonelist.name_setting_overhead_explorer then
    Zonelist.update_overhead_button(game.get_player(event.player_index) --[[@as LuaPlayer]])
  end
end
Event.addListener(defines.events.on_runtime_mod_setting_changed, Zonelist.on_runtime_mod_setting_changed)

---Updates the overhead universe explorer button on player changing forces.
---@param event EventData.on_player_changed_force Event data
function Zonelist.on_player_changed_force(event)
  Zonelist.update_overhead_button(game.get_player(event.player_index) --[[@as LuaPlayer]])
end
Event.addListener(defines.events.on_player_changed_force, Zonelist.on_player_changed_force)

---Handles the player using the toolbar button (lua-shortcut) for the Universe Explorer.
---@param event EventData.on_lua_shortcut Event data
function Zonelist.on_lua_shortcut(event)
  if event.prototype_name == Zonelist.name_shortcut then
    Zonelist.toggle(game.get_player(event.player_index) --[[@as LuaPlayer]])
  end
end
Event.addListener(defines.events.on_lua_shortcut, Zonelist.on_lua_shortcut)

---Handles the keyboard shortcut for the Universe Explorer.
---@param event EventData.CustomInputEvent Event data
function Zonelist.on_keyboard_shortcut(event)
  Zonelist.toggle(game.get_player(event.player_index) --[[@as LuaPlayer]])
end
Event.addListener(Zonelist.name_event, Zonelist.on_keyboard_shortcut)

---Handles the arrow keys for navigation.
---@param event EventData.CustomInputEvent Event data
function Zonelist.on_arrow_key(event)
  local player = game.get_player(event.player_index)
  local zonelist = Zonelist.get(player)
  if not zonelist then return end
  local playerdata = get_make_playerdata(player)
  local selected = playerdata.zonelist_selected_zone
  if not selected then return end
  local scroll_pane = util.get_gui_element(zonelist, Zonelist.path_list_rows_scroll_pane)
  local row_index = scroll_pane[_get_row_name(selected)].get_index_in_parent()
  row_index = event.input_name == "se-next-zone" and math.min(row_index + 1, #scroll_pane.children) or math.max(row_index - 1, 1)
  local gui_element = scroll_pane.children[row_index]
  if gui_element.visible then
    local next_zone = gui_element.tags.zone_type == "spaceship" and Spaceship.from_index(gui_element.tags.zone_index) or Zone.from_zone_index(gui_element.tags.zone_index)
    Zonelist.update(player, next_zone)
  end
end
Event.addListener("se-next-zone", Zonelist.on_arrow_key)
Event.addListener("se-previous-zone", Zonelist.on_arrow_key)

-- Flags GUI

Zonelist.Flags = {
  name_root = "se-zonelist-flags",
  name_main_frame = "main-frame",
  name_flag_frame = "flag-frame",
  name_flag_table = "flag-table",

  action_close_button = "close-zonelist-flags",
  action_flag_button = "toggle-flag"
}

Zonelist.Flags.path_name_flag_table = {
  Zonelist.Flags.name_main_frame,
  Zonelist.Flags.name_flag_frame,
  Zonelist.Flags.name_flag_table
}

---Returns the Flags GUI if open.
---@param player LuaPlayer Player
---@return LuaGuiElement? root
function Zonelist.Flags.get(player)
  return player.gui.screen[Zonelist.Flags.name_root]
end

---Opens the Universe Explorer Flags GUI.
---@param player LuaPlayer Player
function Zonelist.Flags.open(player)
  if Zonelist.Flags.get(player) then return end

  local playerdata = get_make_playerdata(player)

  local root = player.gui.screen.add{
    type = "frame",
    name = Zonelist.Flags.name_root,
    direction = "vertical",
  }
  root.force_auto_center()

  do -- Titlebar
    local titlebar_flow = root.add{
      type = "flow",
      direction = "horizontal",
      style = "se_relative_titlebar_flow"
    }
    titlebar_flow.drag_target = root

    titlebar_flow.add{ -- Title
      type = "label",
      caption = {"space-exploration.zonelist-heading-flags"},
      ignored_by_interaction = true,
      style = "frame_title"
    }
    titlebar_flow.add{ -- Drag handle
      type = "empty-widget",
      ignored_by_interaction = true,
      style = "se_titlebar_drag_handle"
    }
    titlebar_flow.add{ -- Close button
      type = "sprite-button",
      sprite = "utility/close",
      tags = {action=Zonelist.Flags.action_close_button},
      tooltip = {"space-exploration.close"},
      style="close_button"
    }
  end

  local main_frame = root.add{
    type = "frame",
    name = Zonelist.Flags.name_main_frame,
    direction = "vertical",
    style = "inside_shallow_frame_with_padding",
  }

  main_frame.add{
    type = "label",
    caption = {"space-exploration.zonelist-flags-settings-label",
        playerdata.track_glyphs and 5 or 4}
  }.style.bottom_padding = 8

  local frame = main_frame.add{
    type = "frame",
    name = Zonelist.Flags.name_flag_frame,
    style = "slot_button_deep_frame"
  }

  local table = frame.add{ -- Table
    type = "table",
    name = Zonelist.Flags.name_flag_table,
    column_count = 5,
    style = "slot_table"
  }

  table.add{ -- Visited in person
    type = "sprite-button",
    sprite = "entity/character",
    tags = {action=Zonelist.Flags.action_flag_button, flag="visited"},
    tooltip = {"space-exploration.zone-visited"},
    style = "slot_button"
  }
  table.add{ -- Launchpad
    type = "sprite-button",
    sprite = "entity/" .. Launchpad.name_rocket_launch_pad,
    tags = {action=Zonelist.Flags.action_flag_button, flag="launchpad"},
    tooltip = {"entity-name." .. Launchpad.name_rocket_launch_pad},
    style = "slot_button"
  }
  table.add{ -- Landingpad
    type = "sprite-button",
    sprite = "entity/" .. Landingpad.name_rocket_landing_pad,
    tags = {action=Zonelist.Flags.action_flag_button, flag="landingpad"},
    tooltip = {"entity-name." .. Landingpad.name_rocket_landing_pad},
    style = "slot_button"
  }
  table.add{ -- Energy beam defence
    type = "sprite-button",
    sprite = "entity/" .. EnergyBeamDefence.name_energy_beam_defence,
    tags = {action=Zonelist.Flags.action_flag_button, flag="energy_beam_defence"},
    tooltip = {"entity-name." .. EnergyBeamDefence.name_energy_beam_defence},
    style = "slot_button"
  }
  table.add{ -- Meteor defence installation
    type = "sprite-button",
    sprite = "entity/" .. Meteor.name_meteor_defence_container,
    tags = {action=Zonelist.Flags.action_flag_button, flag="meteor_defence"},
    tooltip = {"entity-name." .. Meteor.name_meteor_defence_container},
    style = "slot_button"
  }
  table.add{ -- Meteor point defence
    type = "sprite-button",
    sprite = "entity/" .. Meteor.name_meteor_point_defence_container,
    tags = {action=Zonelist.Flags.action_flag_button, flag="meteor_point_defence"},
    tooltip = {"entity-name." .. Meteor.name_meteor_point_defence_container},
    style = "slot_button",
  }
  if playerdata.track_glyphs then
    table.add{ -- Vault
      type = "sprite-button",
      sprite = "entity/se-pyramid-a",
      tags = {action=Zonelist.Flags.action_flag_button, flag="vault"},
      tooltip = {"space-exploration.mysterious-structure"},
      style = "slot_button"
    }
  end
  table.add{ -- Ruin
    type = "sprite-button",
    sprite = "virtual-signal/se-ruin",
    tags = {action=Zonelist.Flags.action_flag_button, flag="ruin"},
    tooltip = {"space-exploration.ruin"},
    style = "slot_button"
  }
  table.add{ -- Has-surface
    type = "sprite-button",
    sprite = "se-landfill-scaffold",
    tags = {action=Zonelist.Flags.action_flag_button, flag="surface"},
    tooltip = {"space-exploration.zone-has-surface"},
    style = "slot_button"
  }

  Zonelist.Flags.update(player)
end

---Updates the states of the flag slot buttons.
---@param player LuaPlayer Player
function Zonelist.Flags.update(player)
  local root = Zonelist.Flags.get(player)
  if not root then return end

  local table = util.get_gui_element(root, Zonelist.Flags.path_name_flag_table)
  if table then
    local playerdata = get_make_playerdata(player)
    local flags = playerdata.zonelist_enabled_flags --[[@as Flags]]
    local enable_rest = table_size(flags) < 5 and true or false

    for _, button in pairs(table.children) do
      if flags[button.tags.flag] then
        button.enabled = true
        button.style = "se_slot_button_active"
      else
        button.enabled = enable_rest
        button.style = "slot_button"
      end
    end
  end
end

---Closes the Flags GUI.
---@param player LuaPlayer Player
function Zonelist.Flags.close(player)
  local root = Zonelist.Flags.get(player)
  if root then root.destroy() end
end

---Handle clicks for the zonelist Flags GUI
---@param event EventData.on_gui_click Event data
function Zonelist.Flags.on_gui_click(event)
  if not event.element.valid then return end

  local root = gui_element_or_parent(event.element, Zonelist.Flags.name_root)
  if not root or not event.element.tags.action then return end

  local player = game.get_player(event.player_index)
  ---@cast player -?
  local tags = event.element.tags --[[@as Tags]]
  local action = tags.action

  if action == Zonelist.Flags.action_close_button then
    Zonelist.Flags.close(player)
  elseif action == Zonelist.Flags.action_flag_button then
    local playerdata = get_make_playerdata(player)
    local flags = playerdata.zonelist_enabled_flags --[[@as Flags]]

    if flags[tags.flag] then
      flags[tags.flag] = nil
    elseif table_size(flags) < 5 then
      flags[tags.flag] = true
    end

    Zonelist.Flags.update(player)
    Zonelist.update_zone_flags(player)

    -- Update list if "flags" is being used for sorting
    for _, criterion in pairs(playerdata.zonelist_sort_criteria or {}) do
      if criterion.name == "flags" then Zonelist.update_list(player) break end
    end
  end
end
Event.addListener(defines.events.on_gui_click, Zonelist.Flags.on_gui_click)

return Zonelist
