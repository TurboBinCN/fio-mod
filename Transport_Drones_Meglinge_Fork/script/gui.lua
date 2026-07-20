local road_network = require("script/road_network")
local depot_common = require("script/depot_common")
local mod_gui = require("mod-gui")
local transport_drone = require("script/transport_drone")
local message_panel = require("script/message_panel")

local name_button_overhead = "transport-drones-overhead"
local name_setting_overhead = "transport-drones-show-overhead-button"

local player_selected_networks = {}
local player_filter_values = {}

local network_colors = {
  {r=1, g=0, b=0},
  {r=0, g=1, b=0},
  {r=0, g=0, b=1},
  {r=1, g=1, b=0},
  {r=1, g=0, b=1},
  {r=0, g=1, b=1},
  {r=0.5, g=0, b=0.5},
  {r=0.5, g=0.5, b=0},
  {r=0, g=0.5, b=0.5},
  {r=0.75, g=0.25, b=0}
}

local get_network_color = function(index)
  return network_colors[(index - 1) % #network_colors + 1]
end

local count_network_nodes = function(network_id)
  local count = 0
  local node_map = road_network.get_node_map()
  for surface, surface_map in pairs(node_map) do
    for x, x_map in pairs(surface_map) do
      for y, node in pairs(x_map) do
        if node.id == network_id then
          count = count + 1
        end
      end
    end
  end
  return count
end

local count_network_depots = function(network)
  local count = 0
  for category, depots in pairs(network.depots) do
    for _ in pairs(depots) do
      count = count + 1
    end
  end
  return count
end

local count_network_drones = function(network)
  local count = 0
  for category, depots in pairs(network.depots) do
    for _, depot in pairs(depots) do
      if depot.get_drone_item_count then
        count = count + depot:get_drone_item_count()
      end
    end
  end
  return count
end

local network_size = function(network)

  local sum = 0

  for category, depots in pairs (network.depots) do
    sum = sum + table_size(depots)
  end

  return sum
end

local get_network_by_dropdown_index = function(selected_index)

  local networks = road_network.get_networks()

  local index, network
  for k = 1, selected_index do
    index, network = next(networks, index)
  end

  return network
end

local get_network_by_id = function(network_id)
  local networks = road_network.get_networks()
  return networks[network_id]
end

local get_network_surface_name = function(network, network_id)
  local surface_name = ""
  for category, depots in pairs(network.depots) do
    for _, depot in pairs(depots) do
      if depot.entity and depot.entity.valid then
        surface_name = depot.entity.surface.name
        break
      end
    end
    if surface_name ~= "" then break end
  end
  
  if surface_name == "" then
    local node_map = road_network.get_node_map()
    for surface_index, surface_map in pairs(node_map) do
      local surface_obj = game.surfaces[surface_index]
      for x, x_map in pairs(surface_map) do
        for y, node in pairs(x_map) do
          if node.id == network_id then
            surface_name = surface_obj.name
            break
          end
        end
        if surface_name ~= "" then break end
      end
      if surface_name ~= "" then break end
    end
  end
  return surface_name
end

local create_depot_row = function(parent, depot)
  local depot_frame = parent[depot.index]
  if not depot_frame then
    depot_frame = parent.add{type = "flow", name = depot.index, direction = "horizontal"}
    depot_frame.style.horizontally_stretchable = true
    depot_frame.style.vertical_align = "center"
    
    local map_button = depot_frame.add{
      type = "sprite-button",
      name = "open_depot_map_" .. depot.index,
      sprite = "utility/custom_tag_in_map_view"
    }
    map_button.style.width = 32
    map_button.style.height = 32
  end
  return depot_frame
end

local update_depot_tab = function(depots, gui, filter, update_func)
  if not depots then return end

  for index, depot in pairs(depots) do
    if depot.entity.valid then
      local depot_frame = create_depot_row(gui, depot)
      update_func(depot, depot_frame, filter)
    end
  end

  for k, gui_element in pairs(gui.children) do
    if not depots[gui_element.name] then
      gui_element.destroy()
    end
  end
end

local get_frame = function(player)
  local gui = player.gui.screen
  return gui.road_network_frame
end

local get_selected_network = function(player)
  local frame = get_frame(player)
  if not frame then return end
  
  local selected_id = player_selected_networks[player.index]
  if selected_id then
    local network = get_network_by_id(selected_id)
    if network then return network end
  end
  
  local networks = road_network.get_networks()
  for k, network in pairs(networks) do
    player_selected_networks[player.index] = k
    return network
  end
  
  return nil
end

local get_tab_pane = function(player)
  local frame = get_frame(player)
  if not frame then return end
  local inner_frame = frame.inner_frame
  if not inner_frame then return end
  return inner_frame.tab_pane
end

local get_tab = function(player, tab_name)
  local pane = get_tab_pane(player)
  if pane[tab_name] then 
    return pane[tab_name] 
  end
  for i, child in pairs(pane.children) do
    if child.name == tab_name then
      return child
    end
  end
  return nil
end

local get_selected_tab_index = function(player)
  local tab_pane = get_tab_pane(player)
  if tab_pane then return tab_pane.selected_tab_index end
end

local get_filter_value = function(player)
  local value = player_filter_values[player.index]
  return value
end

local cache = {}
local get_item_icon_and_locale = function(name)
  if cache[name] then
    return cache[name]
  end

  local fluids = prototypes.fluid
  if fluids[name] then
    local icon = "fluid/"..name
    local locale = fluids[name].localised_name
    local value = {icon = icon, locale = locale}
    cache[name] = value
    return value
  end

  local items = prototypes.item
  -- 新增：先直接匹配纯物品名（Request/Buff仓库专用）
  if items[name] then
    local icon = "item/" .. name
    local locale = items[name].localised_name
    local value = { icon = icon, locale = locale }
    cache[name] = value
    return value
  end
  local qualities = prototypes.quality
  
  for k, v in pairs(qualities) do
    if string.sub(name, 1 + string.len(name) - string.len(k), string.len(name)) == k then
	  local found_quality = k
	  local found_name = string.sub(name, 1, string.len(name) - string.len(found_quality))
	  if items[found_name] then
		local icon = "item/"..found_name
		local overlay = "quality/"..found_quality
		if not v.draw_sprite_by_default then overlay = nil end
		local locale = items[found_name].localised_name
		local value = {icon = icon, overlay = overlay, locale = locale}
		cache[name] = value
		return value
	  end
	end
  end
end

local signal_cache = {}
local get_signal_id = function(name)
  if signal_cache[name] then
    return signal_cache[name]
  end

  local items = prototypes.item
  if items[name] then
    local value = {type = "item", name = name}
    signal_cache[name] = value
    return value
  end

  local fluids = prototypes.fluid
  if fluids[name] then
    local value = {type = "fluid", name = name}
    signal_cache[name] = value
    return value
  end

end

local floor = math.floor
local update_contents_table = function(contents_table, network, filter, sort)

  local supply = network.item_supply

  if sort then
    local sorted_supply = {}
    local k = 1
    for name, counts in pairs(supply) do
      local sum = 0
      for depot_id, count in pairs (counts) do
        sum = sum + count
      end
      sorted_supply[k] = {name, sum, counts}
      k = k + 1
    end
    table.sort(sorted_supply, function(a, b) return a[2] > b[2] end)
    supply  = {}
    for k = 1, #sorted_supply do
      local entry = sorted_supply[k]
      supply[entry[1]] = entry[3]
    end
  end

  for name, counts in pairs (supply) do
    local item_locale = get_item_icon_and_locale(name)
    
    if item_locale then
      local filter_name = filter and filter.name
      local visible = not filter_name
      
      if filter_name then
        local item_base_name = name
        if string.sub(name, -6) == "normal" then
          item_base_name = string.sub(name, 1, -7)
        elseif string.sub(name, -8) == "perfect" then
          item_base_name = string.sub(name, 1, -9)
        elseif string.sub(name, -10) == "excellent" then
          item_base_name = string.sub(name, 1, -11)
        elseif string.sub(name, -5) == "good" then
          item_base_name = string.sub(name, 1, -6)
        end
        visible = filter_name == item_base_name or string.find(item_base_name, "^" .. filter_name) ~= nil
      end
      
      local flow = contents_table[name]
      if visible then
        local sum = 0
        for depot_id, count in pairs (counts) do
          sum = sum + count
        end

        sum = floor(sum)

        if sum > 0 then
          if not flow then
            flow = contents_table.add{type = "flow", name = name}
            flow.add
            {
              type = "sprite-button",
              sprite = item_locale.icon,
              number = sum,
              style = "transparent_slot",
              name = "count",
              tooltip = {"",item_locale.locale, " \n", sum }
            }
            flow.style.vertical_align = "center"
            flow.style.horizontally_stretchable = true
            local label = flow.add{type = "label", caption = item_locale.locale}
          else
            flow.count.number = sum
            flow.count.tooltip = sum
          end
        end
      end
      if flow then flow.visible = visible end
    end
  end
  for k, gui in pairs (contents_table.children) do
    if not network.item_supply[gui.name] then gui.destroy() end
  end
end

local refresh_contents_tab = function(player, force)

  if not force and get_selected_tab_index(player) ~= 1 then 
    return 
  end
  local contents_tab = get_tab(player, "contents_tab")
  if not contents_tab then 
    return 
  end
  local network = get_selected_network(player)
  if not network then 
    return 
  end
  update_contents_table(contents_tab.contents_table, network, get_filter_value(player))
end

local add_contents_tab = function(tabbed_pane, network, filter)
  local contents_tab = tabbed_pane.add{type = "tab", caption = {"contents"}}
  local contents = tabbed_pane.add{type = "scroll-pane",  name = "contents_tab", style = "naked_scroll_pane"}
  contents.style.maximal_width = 1900

  local contents_table = contents.add{type = "table", column_count = 4, style = "bordered_table", name = "contents_table"}
  contents_table.style.column_alignments[1] = "center"
  contents_table.style.column_alignments[2] = "center"
  contents_table.style.column_alignments[3] = "center"
  contents_table.style.column_alignments[4] = "center"

  update_contents_table(contents_table, network, filter, true)

  tabbed_pane.add_tab(contents_tab, contents)
end

local update_contents = function(gui, contents)

  local names = {}
  for key, itemWithQualityCounts in pairs (contents) do
    local name = itemWithQualityCounts.name .. itemWithQualityCounts.quality
    names[name] = true
    local item_locale = get_item_icon_and_locale(name)
    if item_locale then
	  local count = tostring(itemWithQualityCounts.count)
      local button = gui[name]
      if not button then
        button = gui.add
        {
          type = "sprite-button",
          sprite = item_locale.icon,
          number = count,
          style = "transparent_slot",
          name = name,
          tooltip = {"",item_locale.locale, " \n", count }
        }
      else
        button.number = count
        button.tooltip = {"",item_locale.locale, " \n", count }
      end
    end
  end

  for k, element in pairs (gui.children) do
    if not names[element.name] then
      element.destroy()
    end
  end

end


local add_depot_map_button = function(depot, gui, size)
  local button = gui.add{type = "button", name = "open_depot_map_"..depot.index}
  button.style.minimal_width = size + 8
  button.style.minimal_height = size + 8
  button.style.horizontal_align = "center"
  button.style.vertical_align = "center"
  button.style.padding = {0,0,0,0}
  --button.style.horizontally_stretchable = true
  local entity = depot.entity
  local map = button.add
  {
    type = "minimap",
    position = entity.position,
    surface_index = entity.surface.index,
    force = entity.force.name,
    zoom = 2,
    ignored_by_interaction = true
  }
  map.style.minimal_width = size
  map.style.minimal_height = size
  --map.style.horizontally_stretchable = true
  --local sprite_size = 32
  --local sprite = map.add{type = "sprite", sprite = "entity/"..depot.entity.name}
  --local padding = (size / 2) - (sprite_size / 2)
  --sprite.style.padding = {padding, padding, padding, padding}
  --sprite.style.width = sprite_size
  --sprite.style.height = sprite_size

end


local update_supply_depot_gui = function(depot, gui, filter)

  local holding_table = gui.table
  if not holding_table then
    holding_table = gui.add{type = "table", column_count = 5, name = "table"}
  end
  local visible = false
  if filter then
    for k, itemWithQualityCounts in pairs(depot.old_contents) do
      local item_name = itemWithQualityCounts.name .. itemWithQualityCounts.quality
      if itemWithQualityCounts.name == filter.name or string.find(item_name, "^" .. filter.name) ~= nil then 
        visible = true 
      end
	end
  else
    visible = true
  end
  if visible then
    update_contents(holding_table, depot.old_contents)
  end
  gui.visible = visible or false
end

local update_supply_tab = function(depots, gui, filter)
  update_depot_tab(depots, gui, filter, update_supply_depot_gui)
end

local refresh_supply_tab = function(player, force)
  if not force and get_selected_tab_index(player) ~= 2 then return end
  local contents_tab = get_tab(player, "supply_tab")
  if not contents_tab then return end
  local network = get_selected_network(player)
  update_supply_tab(network.depots.supply, contents_tab.depot_table, get_filter_value(player))
end

local refresh_fluid_tab = function(player, force)
  if not force and get_selected_tab_index(player) ~= 3 then return end
  local contents_tab = get_tab(player, "fluid_tab")
  if not contents_tab then return end
  local network = get_selected_network(player)
  update_supply_tab(network.depots.fluid, contents_tab.depot_table, get_filter_value(player))
end

local refresh_mining_tab = function(player, force)
  if not force and get_selected_tab_index(player) ~= 4 then return end
  local contents_tab = get_tab(player, "mining_tab")
  if not contents_tab then return end
  local network = get_selected_network(player)
  update_supply_tab(network.depots.mining, contents_tab.depot_table, get_filter_value(player))
end

local add_supply_tab = function(tabbed_pane, network, filter)
  local supply_tab = tabbed_pane.add{type = "tab", caption = {"supply-depots"}}
  local contents = tabbed_pane.add{type = "scroll-pane", name = "supply_tab", style = "naked_scroll_pane"}

  local depots = network.depots.supply

  if not depots then
    supply_tab.enabled = false
    tabbed_pane.add_tab(supply_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 4, style = "bordered_table", name = "depot_table"}
  depot_table.style.horizontally_stretchable = true

  update_supply_tab(depots, depot_table, filter)

  tabbed_pane.add_tab(supply_tab, contents)
end

local add_fluid_tab = function(tabbed_pane, network, filter)
  local fluid_tab = tabbed_pane.add{type = "tab", caption = {"fluid-depots"}}
  local contents = tabbed_pane.add{type = "scroll-pane", name = "fluid_tab", style = "naked_scroll_pane"}

  local depots = network.depots.fluid

  if not depots then
    fluid_tab.enabled = false
    tabbed_pane.add_tab(fluid_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 4, style = "bordered_table", name = "depot_table"}
  depot_table.style.horizontally_stretchable = true

  update_supply_tab(depots, depot_table, filter)

  tabbed_pane.add_tab(fluid_tab, contents)
end

local add_mining_tab = function(tabbed_pane, network, filter)
  local mining_tab = tabbed_pane.add{type = "tab", caption = {"mining-depots"}}
  local contents = tabbed_pane.add{type = "scroll-pane", name = "mining_tab", style = "naked_scroll_pane"}

  local depots = network.depots.mining

  if not depots then
    mining_tab.enabled = false
    tabbed_pane.add_tab(mining_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 4, style = "bordered_table", name = "depot_table"}
  depot_table.style.horizontally_stretchable = true

  update_supply_tab(depots, depot_table, filter)

  tabbed_pane.add_tab(mining_tab, contents)
end

local update_fuel_depot_gui = function(depot, gui)

  --local depot_frame = depot_table.add{type = "frame", style = "bordered_frame"}
  local flow = gui.table

  if not flow then
    flow = gui.add{type = "table", column_count = 2, style = "bordered_table", name = "table"}
    flow.style.horizontally_stretchable = true
  end

  local transport_drone = flow.transport_drone
  local caption = { "transport-drone-A-T", (depot:get_active_drone_count()), (depot:get_drone_item_count()) }
  if not transport_drone then
    transport_drone = flow.add { type = "label", caption = caption, name = "transport_drone" }
  else
    transport_drone.caption = caption
  end

  local fuel_label = flow.fuel_label
  if not fuel_label then
    fuel_label = flow.add{type = "label", caption = {"available-fuel", floor(depot:get_fuel_amount())}, name = "fuel_label"}
  else
    fuel_label.caption = {"available-fuel", floor(depot:get_fuel_amount())}
  end
end


local fuel_map_size = 64 * 3
local update_fuel_tab = function(depots, gui, filter)
  update_depot_tab(depots, gui, filter, function(depot, gui) update_fuel_depot_gui(depot, gui) end)
end

local refresh_fuel_tab = function(player, force)
  if not force and get_selected_tab_index(player) ~= 5 then return end
  local contents_tab = get_tab(player, "fuel_tab")
  if not contents_tab then return end
  local network = get_selected_network(player)
  update_fuel_tab(network.depots.fuel, contents_tab.depot_table)
end

local add_fuel_tab = function(tabbed_pane, network, filter)
  local fuel_tab = tabbed_pane.add{type = "tab", caption = {"fuel-depots-tab"}}
  local contents = tabbed_pane.add{type = "scroll-pane", name = "fuel_tab", style = "naked_scroll_pane"}

  local depots = network.depots.fuel

  if not depots then
    fuel_tab.enabled = false
    tabbed_pane.add_tab(fuel_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table", name = "depot_table"}
  depot_table.style.horizontally_stretchable = true

  update_fuel_tab(depots, depot_table, filter)

  tabbed_pane.add_tab(fuel_tab, contents)
end

local update_request_depot_gui = function(depot, gui, filter)

  local flow = gui.holding_flow
  if not flow then
    flow = gui.add{type = "table", column_count = 4, name = "holding_flow"}
    flow.style.horizontally_stretchable = true
  end

  local item = depot.item
  local visible = (not filter) or filter.name == item
  gui.visible = visible

  if not visible then return end
  
  if not item then
    if flow.current_item_flow then
      flow.clear()
      flow.add{type = "label", caption = {"no-request-set"}, name = "no_request_label"}
    end
  end

  if item then
    -- if flow.no_request_label then
    --   flow.clear()
    -- end

    local item_locale = get_item_icon_and_locale(item)
    if item_locale then

      local current_item_flow = flow.current_item_flow
      if not current_item_flow then
        current_item_flow = flow.add{type = "flow", name = "current_item_flow"}
        current_item_flow.style.vertical_align = "center"
      end

      local count = current_item_flow.count
      local current_count = depot:get_current_amount() or 0
      current_count = floor(current_count)
      if not count then
        count = current_item_flow.add
        {
          type = "sprite-button",
          sprite = item_locale.icon,
          number = current_count,
          tooltip = {"",item_locale.locale, " \n", current_count },
          style = "transparent_slot",
          name = "count"
        }
        current_item_flow.add{type = "label", caption =""}
      else
        count.tooltip = current_count
        count.number = current_count
      end

      --这个判断意义不大，请求数量算法有两种：
      -- 1. 请求数量 = 请求数量 * 无人机数量
      -- 2. 请求数量 = 写会回路设定数量
      -- local requested_item_flow = flow.requested_item_flow
      -- if not requested_item_flow then
      --   requested_item_flow = flow.add{type = "flow", name = "requested_item_flow"}
      --   requested_item_flow.style.vertical_align = "center"
      -- end
      -- local request_count = requested_item_flow.count
      -- local requested_count = depot:get_request_size() * depot:get_drone_item_count()
      -- if not request_count then
      --   request_count = requested_item_flow.add
      --   {
      --     type = "sprite-button",
      --     sprite = item_locale.icon,
      --     number = requested_count,
      --     tooltip = requested_count,
      --     style = "transparent_slot",
      --     name = "count"
      --   }
      -- else
      --   request_count.tooltip = requested_count
      --   request_count.number = requested_count
      -- end
    end
  end

  local transport_drone = flow.transport_drone
  local caption = { "transport-drone-A-T", (depot:get_active_drone_count()), (depot:get_drone_item_count()) }
  if not transport_drone then
    transport_drone = flow.add { type = "label", caption = caption, name = "transport_drone" }
  else
    transport_drone.caption = caption
  end

  local fuel_label = flow.fuel_label
  if not fuel_label then
    fuel_label = flow.add { type = "label", caption = { "available-fuel", floor(depot:get_fuel_amount()) }, name = "fuel_label" }
  else
    fuel_label.caption = { "available-fuel", floor(depot:get_fuel_amount()) }
  end

end

local update_request_tab = function(depots, gui, filter)
  update_depot_tab(depots, gui, filter, update_request_depot_gui)
end

local update_buffer_depot_gui = function(depot, gui, filter)

  local flow = gui.holding_flow
  if not flow then
    flow = gui.add{type = "table", column_count = 4, name = "holding_flow"}
    flow.style.horizontally_stretchable = true
  end

  local item = depot.item
  local visible = false
  if filter then
    if depot.item and depot.item == filter.name then
      visible = true
    end
  else
    visible = true
  end
  gui.visible = visible

  if not visible then return end

  if not item then
    if flow.current_item_flow then
      flow.clear()
      flow.add{type = "label", caption = {"no-buffer-set"}, name = "no_buffer_label"}
    end
  end

  if item then
    if flow.no_buffer_label then
      flow.clear()
    end

    local item_locale = get_item_icon_and_locale(item)

    if item_locale then

      local current_item_flow = flow.current_item_flow
      if not current_item_flow then
        current_item_flow = flow.add{type = "flow", name = "current_item_flow"}
        current_item_flow.style.vertical_align = "center"
      end

      local count = current_item_flow.count
      local current_count = depot:get_current_amount() or 0
      current_count = floor(current_count)
      if not count then
        count = current_item_flow.add
        {
          type = "sprite-button",
          sprite = item_locale.icon,
          number = current_count,
          tooltip = {"",item_locale.locale, " \n", current_count },
          style = "transparent_slot",
          name = "count"
        }
      else
        count.tooltip = current_count
        count.number = current_count
      end

    end
  end

  local transport_drone = flow.transport_drone
  local caption = { "transport-drone-A-T", (depot:get_active_drone_count()), (depot:get_drone_item_count()) }
  if not transport_drone then
    transport_drone = flow.add { type = "label", caption = caption, name = "transport_drone" }
  else
    transport_drone.caption = caption
  end

  local fuel_label = flow.fuel_label
  if not fuel_label then
    fuel_label = flow.add { type = "label", caption = { "available-fuel", floor(depot:get_fuel_amount()) }, name = "fuel_label" }
  else
    fuel_label.caption = { "available-fuel", floor(depot:get_fuel_amount()) }
  end

end

local update_buffer_tab = function(depots, gui, filter)
  update_depot_tab(depots, gui, filter, update_buffer_depot_gui)
end


local refresh_request_tab = function(player, force)
  if not force and get_selected_tab_index(player) ~= 6 then return end
  local contents_tab = get_tab(player, "request_tab")
  if not contents_tab then return end
  local network = get_selected_network(player)
  update_request_tab(network.depots.request, contents_tab.depot_table, get_filter_value(player))
end

local refresh_buffer_tab = function(player, force)
  if not force and get_selected_tab_index(player) ~= 7 then return end
  local contents_tab = get_tab(player, "buffer_tab")
  if not contents_tab then return end
  local network = get_selected_network(player)
  update_buffer_tab(network.depots.buffer, contents_tab.depot_table, get_filter_value(player))
end

local add_request_tab = function(tabbed_pane, network, filter)
  local request_tab = tabbed_pane.add{type = "tab", caption = {"request-depots"}}
  local contents = tabbed_pane.add{type = "scroll-pane", name = "request_tab", style = "naked_scroll_pane"}

  local depots = network.depots.request
  if not depots then
    request_tab.enabled = false
    tabbed_pane.add_tab(request_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table", name = "depot_table"}
  depot_table.style.horizontally_stretchable = true
  update_request_tab(depots, depot_table, filter)

  tabbed_pane.add_tab(request_tab, contents)
end

local buffer_map_size = 64 * 3
local add_buffer_tab = function(tabbed_pane, network, filter)
  local buffer_tab = tabbed_pane.add{type = "tab", caption = {"buffer-depots"}}
  local contents = tabbed_pane.add{type = "scroll-pane", name = "buffer_tab", style = "naked_scroll_pane"}

  local depots = network.depots.buffer
  if not depots then
    buffer_tab.enabled = false
    tabbed_pane.add_tab(buffer_tab, contents)
    return
  end

  local depot_table = contents.add{type = "table", column_count = 2, style = "bordered_table", name = "depot_table"}
  depot_table.style.horizontally_stretchable = true
  update_buffer_tab(depots, depot_table, filter)

  tabbed_pane.add_tab(buffer_tab, contents)
end

local make_network_gui = function(inner, network, filter)

  local tabbed_pane = inner.add{type = "tabbed-pane", name = "tab_pane"}
  add_contents_tab(tabbed_pane, network, filter)
  add_supply_tab(tabbed_pane, network, filter)
  add_fluid_tab(tabbed_pane, network, filter)
  -- add_mining_tab(tabbed_pane, network)
  add_fuel_tab(tabbed_pane, network, filter)
  add_request_tab(tabbed_pane, network, filter)
  add_buffer_tab(tabbed_pane, network, filter)
  tabbed_pane.selected_tab_index = 1

end

local refresh_network_gui = function(player, selected_index)

  local frame = get_frame(player)
  if not frame then return end

  local network = get_network_by_dropdown_index(selected_index)

  if not network then return end

  local inner = frame.add{type = "frame", style = "mod_gui_inside_deep_frame", name = "inner_frame", direction = "vertical"}
  local subheader = inner.add{type = "flow", name = "subheader_frame"}
  subheader.style.vertical_align = "center"
  local pusher = subheader.add{type = "empty-widget"}
  pusher.style.horizontally_stretchable = true
  subheader.add{type = "label", caption = {"filter"}}
  local filter = subheader.add{type = "choose-elem-button", name = "depot_filter_button", elem_type = "signal"}
  subheader.style.right_padding = 12

  make_network_gui(inner, network, nil)

end

local close_gui = function(player)

  local gui = player.gui.screen
  local frame = gui.road_network_frame

  if frame then
    frame.destroy()
  end
end

local refresh_gui = function(player, force)

  local frame = get_frame(player)

  local network = get_selected_network(player)
  
  if not network then
    local networks = road_network.get_networks()
    for k, net in pairs(networks) do
      network = net
      player_selected_networks[player.index] = k
      break
    end
    if not network then
      close_gui(player)
      return
    end
  end

  if force then
    
    local old_filter_value = player_filter_values[player.index]
    
    frame.clear()
    
    local title_flow = frame.add{type = "flow", name = "title_flow"}
    local title = title_flow.add{type = "label", caption = title_caption, style = "frame_title"}
    title.drag_target = frame
    local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
    pusher.style.vertically_stretchable = true
    pusher.style.horizontally_stretchable = true
    pusher.drag_target = frame
    local show_overlay_button = title_flow.add{
      type = "sprite-button",
      name = "toggle_network_overlay",
      sprite = "utility/map",
      tooltip = {"gui.toggle-network-overlay"}
    }
    title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close", name = "close_road_network_gui"}
    
    local main_flow = frame.add{type = "flow", direction = "horizontal"}
    
    local network_list_scroll = main_flow.add{
      type = "scroll-pane",
      name = "network_list_scroll",
      style = "naked_scroll_pane",
      horizontal_scroll_policy = "never",
      vertical_scroll_policy = "auto"
    }
    network_list_scroll.style.width = 250
    network_list_scroll.style.maximal_height = (player.display_resolution.height * 0.8) / player.display_scale
    
    local network_list = network_list_scroll.add{
      type = "table",
      name = "network_list",
      column_count = 1
    }
    
    local networks = road_network.get_networks()
    local net_count = 0
    for _ in pairs(networks) do net_count = net_count + 1 end
    
    local selected = player_selected_networks[player.index]
    local big = 0
    
    for k, net in pairs(networks) do
      if not selected then
        local size = network_size(net)
        if size > big then
          big = size
          selected = k
        end
      end
      
      local node_count = count_network_nodes(k)
      local depot_count = count_network_depots(net)
      local drone_count = count_network_drones(net)
      local color = get_network_color(k)
      local surface_name = get_network_surface_name(net, k)
      
      local network_row = network_list.add{
        type = "flow",
        direction = "horizontal",
        name = "network_row_" .. k
      }
      network_row.style.minimal_height = 40
      network_row.style.minimal_width = 230
      
      local color_indicator = network_row.add{
        type = "label",
        name = "network_color_" .. k,
        caption = "■",
        tooltip = {"", {"gui.network-id", k}}
      }
      color_indicator.style.minimal_height = 36
      color_indicator.style.minimal_width = 24
      color_indicator.style.font_color = {r=color.r, g=color.g, b=color.b}
      color_indicator.style.top_padding = 0
      color_indicator.style.bottom_padding = 0
      
      local network_button = network_row.add{
        type = "button",
        name = "network_button_" .. k,
        style = "slot_button",
        caption = {"gui.network_lable", k, node_count},
        tooltip = {"",
          {"gui.network-id", k}, "\n",
          {"gui.network-nodes", node_count}, "\n",
          {"gui.network-depots", depot_count}, "\n",
          {"gui.network-drones", drone_count}, "\n",
          {"gui.network-surface", surface_name}
        }
      }
      network_button.style.minimal_height = 36
      network_button.style.maximal_height = 36
      network_button.style.minimal_width = 160
      network_button.style.maximal_width = 160
      network_button.style.horizontal_align = "left"
      network_button.style.font_color = {r=1, g=1, b=1}
      
      local focus_button = network_row.add{
        type = "sprite-button",
        name = "network_focus_" .. k,
        sprite = "utility/go_to_arrow",
        tooltip = {"gui.focus-network"},
        style = "frame_action_button"
      }
      focus_button.style.minimal_height = 36
      focus_button.style.minimal_width = 36
    end
    
    if net_count > 0 then
      if not selected then
        for k, net in pairs(networks) do
          selected = k
          network = net
          break
        end
      end
      
      local network_by_id = get_network_by_id(selected)
      if network_by_id then
        network = network_by_id
      end
      
      player_selected_networks[player.index] = selected
      
      local selected_row = network_list["network_row_" .. selected]
      if selected_row then
        local selected_button = selected_row["network_button_" .. selected]
        if selected_button then
          selected_button.style.font_color = {r=0.2, g=0.8, b=0.2}
        end
      end
    end
    
    local inner = main_flow.add{type = "frame", style = "mod_gui_inside_deep_frame", name = "inner_frame", direction = "vertical"}
    local subheader = inner.add{type = "flow", name = "subheader_frame"}
    subheader.style.vertical_align = "center"
    local sub_pusher = subheader.add{type = "empty-widget"}
    sub_pusher.style.horizontally_stretchable = true
    subheader.add{type = "label", caption = {"filter"}}
    local filter = subheader.add{type = "choose-elem-button", name = "depot_filter_button", elem_type = "signal"}
    subheader.style.right_padding = 12
    
    if old_filter_value then
      filter.elem_value = old_filter_value
    end
    
    local tabbed_pane = inner.add{type = "tabbed-pane", name = "tab_pane"}
    add_contents_tab(tabbed_pane, network, old_filter_value)
    add_supply_tab(tabbed_pane, network, old_filter_value)
    add_fluid_tab(tabbed_pane, network, old_filter_value)
    add_fuel_tab(tabbed_pane, network, old_filter_value)
    add_request_tab(tabbed_pane, network, old_filter_value)
    add_buffer_tab(tabbed_pane, network, old_filter_value)
    tabbed_pane.selected_tab_index = 1
    
  else
    refresh_contents_tab(player, force)
    refresh_supply_tab(player, force)
    refresh_fluid_tab(player, force)
    refresh_mining_tab(player, force)
    refresh_fuel_tab(player, force)
    refresh_request_tab(player, force)
    refresh_buffer_tab(player, force)
  end

end

local title_caption = {"road-networks"}
local open_gui = function(player, network_index)
  
  local networks = road_network.get_networks()
  local net_count = 0
  for _ in pairs(networks) do net_count = net_count + 1 end
  
  if not next(networks) then
    player.print({"no-networks"})
    return
  end
  local gui = player.gui.screen

  local frame = gui.road_network_frame
  
  if frame then
    frame.clear()
  else
    frame = gui.add{type = "frame", direction = "vertical", name = "road_network_frame"}
  end
  frame.style.maximal_height = (player.display_resolution.height * 0.9) / player.display_scale
  frame.style.maximal_width = (player.display_resolution.width * 0.9) / player.display_scale

  local title_flow = frame.add{type = "flow", name = "title_flow"}

  local title = title_flow.add{type = "label", caption = title_caption, style = "frame_title"}
  title.drag_target = frame

  local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame

  local show_overlay_button = title_flow.add{
    type = "sprite-button",
    name = "toggle_network_overlay",
    sprite = "utility/map",
    tooltip = {"gui.toggle-network-overlay"}
  }

  title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close", name = "close_road_network_gui"}

  local main_flow = frame.add{type = "flow", direction = "horizontal"}

  local network_list_scroll = main_flow.add{
    type = "scroll-pane",
    name = "network_list_scroll",
    style = "naked_scroll_pane",
    horizontal_scroll_policy = "never",
    vertical_scroll_policy = "auto"
  }
  network_list_scroll.style.width = 250
  network_list_scroll.style.maximal_height = (player.display_resolution.height * 0.8) / player.display_scale

  local network_list = network_list_scroll.add{
    type = "table",
    name = "network_list",
    column_count = 1
  }

  local selected
  local big = 0

  for k, network in pairs(networks) do
    if not selected then selected = k end
    local size = network_size(network)
    if size > big then
      big = size
      selected = k
    end

    local node_count = count_network_nodes(k)
    local depot_count = count_network_depots(network)
    local drone_count = count_network_drones(network)
    local color = get_network_color(k)
    local surface_name = get_network_surface_name(network, k)

    local network_row = network_list.add{
      type = "flow",
      direction = "horizontal",
      name = "network_row_" .. k
    }
    network_row.style.minimal_height = 40
    network_row.style.minimal_width = 230

    local color_indicator = network_row.add{
      type = "label",
      name = "network_color_" .. k,
      caption = "■",
      tooltip = {"", {"gui.network-id", k}}
    }
    color_indicator.style.minimal_height = 36
    color_indicator.style.minimal_width = 24
    color_indicator.style.font_color = {r=color.r, g=color.g, b=color.b}
    color_indicator.style.top_padding = 0
    color_indicator.style.bottom_padding = 0

    local network_button = network_row.add{
      type = "button",
      name = "network_button_" .. k,
      style = "slot_button",
      caption = {"gui.network_lable", k, node_count},
      tooltip = {"",
        {"gui.network-id", k}, "\n",
        {"gui.network-nodes", node_count}, "\n",
        {"gui.network-depots", depot_count}, "\n",
        {"gui.network-drones", drone_count}, "\n",
        {"gui.network-surface", surface_name}
      }
    }
    network_button.style.minimal_height = 36
    network_button.style.maximal_height = 36
    network_button.style.minimal_width = 160
    network_button.style.maximal_width = 160
    network_button.style.horizontal_align = "left"
    network_button.style.font_color = {r=1, g=1, b=1}

    local focus_button = network_row.add{
      type = "sprite-button",
      name = "network_focus_" .. k,
      sprite = "utility/go_to_arrow",
      tooltip = {"gui.focus-network"},
      style = "frame_action_button"
    }
    focus_button.style.minimal_height = 36
    focus_button.style.minimal_width = 36
  end

  if not selected then return end

  if network_index then
    local network_by_index = get_network_by_id(network_index)
    if network_by_index then
      selected = network_index
    end
  end

  local network = get_network_by_id(selected)

  player_selected_networks[player.index] = selected

  local selected_row = network_list["network_row_" .. selected]
  if selected_row then
    local selected_button = selected_row["network_button_" .. selected]
    if selected_button then
      selected_button.style.font_color = {r=0.2, g=0.8, b=0.2}
    end
  end

  local inner = main_flow.add{type = "frame", style = "mod_gui_inside_deep_frame", name = "inner_frame", direction = "vertical"}
  inner.style.horizontally_stretchable = true
  inner.style.maximal_height = (player.display_resolution.height * 0.8) / player.display_scale

  local subheader = inner.add{type = "flow", name = "subheader_frame"}
  subheader.style.vertical_align = "center"
  local sub_pusher = subheader.add{type = "empty-widget"}
  sub_pusher.style.horizontally_stretchable = true
  subheader.add{type = "label", caption = {"filter"}}
  local filter = subheader.add{type = "choose-elem-button", name = "depot_filter_button", elem_type = "signal"}
  subheader.style.right_padding = 12

  make_network_gui(inner, network, nil)

  if not frame.auto_center then frame.auto_center = true end
  player.opened = frame

end

local split = function(str)
  local sep, fields = "/", {}
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(str, pattern, function(c) fields[#fields+1] = c end)
  return fields
end

local toggle_gui = function(event)
  
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then 
    return 
  end

  local frame = get_frame(player)
  if frame then
    frame.destroy()
    return
  end

  local nearby_network_id

  local nearby_road_tile = player.surface.find_tiles_filtered{name = "transport-drone-road", limit = 1, position = player.position, radius = 32}[1]

  if nearby_road_tile then
      local node = road_network.get_node(player.surface.index, nearby_road_tile.position.x, nearby_road_tile.position.y)
      if node then
        nearby_network_id = node.id
      end
  end

  open_gui(player, nearby_network_id)

end

local focus_on_network_node = function(player, network_id)
  
  local networks = road_network.get_networks()
  local node_map = road_network.get_node_map()
  
  local network = networks[network_id]
  if not network then
    return
  end
      
  for surface_index, surface_map in pairs(node_map) do
    local surface_obj = game.surfaces[surface_index]
    
    if surface_obj then
      for x, x_map in pairs(surface_map) do
        for y, node in pairs(x_map) do
          if node.id == network_id then
            
            player.set_controller{
              type = defines.controllers.remote,
              surface = surface_obj,
              position = {x, y}
            }
            player.zoom = 0.5
            
            local color = get_network_color(network_id)
            local label_id = rendering.draw_text{
              text = { "gui.network-id", network_id },
              target = {x, y + 1},
              surface = surface_obj,
              color = color,
              players = {player.index},
              time_to_live = 120
            }
            
            local circle_id = rendering.draw_circle{
              color = {r=color.r, g=color.g, b=color.b, a=0.8},
              radius = 1,
              width = 4,
              target = {x, y},
              surface = surface_obj,
              players = {player.index},
              time_to_live = 120,
              draw_on_ground = true
            }
            
            return
          end
        end
      end
    else
    end
  end
  
end

if not storage.player_network_overlays then
  storage.player_network_overlays = {}
end 

if not storage.player_network_overlay_enabled then
  storage.player_network_overlay_enabled = {}
end

-- 将版本变量移到 storage 中以持久化
if not storage.network_overlay_version then
  storage.network_overlay_version = 0
end

if not storage.player_network_overlay_version then
  storage.player_network_overlay_version = {}
end

local network_version = storage.network_overlay_version
local player_network_overlay_version = storage.player_network_overlay_version

-- ========== Network Overlay State Persistence ==========
-- Key design: rendering objects are destroyed on save/load, but storage persists.
-- The enabled state + version tracking ensures overlays are automatically recreated.
-- 
-- Storage variables (persist across save/load):
--   - player_network_overlay_enabled[player]: true/false - whether overlay should be shown
--   - network_overlay_version: global counter incremented when networks change
--   - player_network_overlay_version[player]: version when overlay was last created
--
-- Runtime variables (lost on save/load):
--   - player_network_overlays[player]: array of rendering objects (must be recreated)

local increment_network_version = function()
  network_version = network_version + 1
  storage.network_overlay_version = network_version
end

local hide_network_overlay = function(player)
  if not storage.player_network_overlays[player.index] then
    return
  end
  
  for _, obj in pairs(storage.player_network_overlays[player.index]) do
    if obj and obj.valid then
      obj.destroy()
    end
  end
  storage.player_network_overlays[player.index] = nil
end

local show_network_overlay = function(player)
  -- Early return if overlay already exists
  if storage.player_network_overlays[player.index] then
    return
  end
  
  -- Ensure enabled state is true
  storage.player_network_overlay_enabled[player.index] = true
  
  local networks = road_network.get_networks()
  local node_map = road_network.get_node_map()
  local overlay_objs = {}
  
  local count = 0
  for network_id, network in pairs(networks) do
    count = count + 1
    local color = get_network_color(count)
    
    for surface_index, surface_map in pairs(node_map) do
      local surface = game.surfaces[surface_index]
      if surface then
        for x, x_map in pairs(surface_map) do
          for y, node in pairs(x_map) do
            if node.id == network_id then
              local rect_obj = rendering.draw_rectangle{
                color = {r=color.r, g=color.g, b=color.b, a=0.4},
                left_top = {x - 0.5, y - 0.5},
                right_bottom = {x + 0.5, y + 0.5},
                surface = surface,
                players = {player.index},
                draw_on_ground = true,
                filled = true,
                render_mode = "game"
              }
              table.insert(overlay_objs, rect_obj)
            end
          end
        end
      end
    end
  end
  
  storage.player_network_overlays[player.index] = overlay_objs
  storage.player_network_overlay_version[player.index] = network_version
end

local update_network_overlay_for_player = function(player)
  -- Ensure storage tables exist (safety check)
  if not storage.player_network_overlays then
    storage.player_network_overlays = {}
  end
  if not storage.player_network_overlay_enabled then
    storage.player_network_overlay_enabled = {}
  end
  if not storage.player_network_overlay_version then
    storage.player_network_overlay_version = {}
  end
  
  local is_in_remote_view = player.controller_type == defines.controllers.remote
  local has_overlay = storage.player_network_overlays[player.index] ~= nil
  local enabled = storage.player_network_overlay_enabled[player.index]
  local current_version = storage.player_network_overlay_version[player.index]
  
  if is_in_remote_view then
    -- Default to enabled for remote view players
    if enabled == nil then
      storage.player_network_overlay_enabled[player.index] = true
      enabled = true
    end
    
    if enabled then
      if not has_overlay then
        -- Overlay missing (e.g., after save/load), recreate it
        show_network_overlay(player)
      elseif current_version ~= network_version then
        -- Network changed, refresh overlay to match current state
        hide_network_overlay(player)
        show_network_overlay(player)
      end
    end
  elseif has_overlay then
    -- Player left remote view, hide overlay
    hide_network_overlay(player)
  end
end

local toggle_network_overlay = function(player)
  if player.controller_type ~= defines.controllers.remote then
    player.print({"gui.network-overlay-only-remote"})
    return
  end
  
  if storage.player_network_overlays[player.index] then
    hide_network_overlay(player)
    storage.player_network_overlay_enabled[player.index] = false
    player.print({"gui.network-overlay-hidden"})
  else
    storage.player_network_overlay_enabled[player.index] = true
    show_network_overlay(player)
    player.print({"gui.network-overlay-shown"})
  end
end

local on_gui_click = function(event)
  local gui = event.element
  if not (gui and gui.valid) then return end

  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end

  if gui.name == name_button_overhead then
    toggle_gui(event)
    return
  end

  if not get_frame(player) then return end
  if gui.get_mod() ~= "Transport_Drones_Meglinge_Fork" then return end

  local button = gui
  while button and not button.name:find("open_depot_map_") do
    button = button.parent
  end
  if button then
    local depot_index = button.name:sub(("open_depot_map_"):len() + 1)
    
    local depot = depot_common.get_depot_by_index(depot_index)
    
    if depot then
      player.set_controller{
        type = defines.controllers.remote,
        surface = depot.entity.surface,
        position = depot.entity.position
      }
      player.zoom = 0.5
      
      local circle_id = rendering.draw_circle{
        color = {r=1, g=0.5, b=0, a=0.6},
        radius = 1.5,
        width = 6,
        target = depot.entity.position,
        surface = depot.entity.surface,
        players = {player.index},
        time_to_live = 120,
        filled = true,
        render_mode = "game"
      }
      
      close_gui(player)
    else
      local all_depots = {}
      for k, v in pairs(script_data.depots or {}) do
        table.insert(all_depots, tostring(k) .. ":" .. type(k))
      end
    end
    return
  end

  if gui.name == "close_road_network_gui" then
    close_gui(player)
    return
  end

  if gui.name == "toggle_network_overlay" then
    toggle_network_overlay(player)
    return
  end

  local network_match = gui.name:match("network_button_(%d+)")
  if network_match then
    local network_id = tonumber(network_match)
    player_selected_networks[player.index] = network_id
    open_gui(player, network_id)
    return
  end

  local focus_match = gui.name:match("network_focus_(%d+)")
  if focus_match then
    local network_id = tonumber(focus_match)

    focus_on_network_node(player, network_id)
    return
  end

  if gui.type == "sprite-button" then
    local sprite = gui.sprite
    if sprite and sprite ~= "" and sprite ~= "utility/custom_tag_in_map_view" then
      local result = split(sprite)
      local signal = {type = result[1], name = result[2]}
      player_filter_values[player.index] = signal
      refresh_gui(player, true)
      return
    end
  end

end

local on_gui_selection_state_changed = function(event)
  local gui = event.element
  if not (gui and gui.valid) then return end

  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end

  if gui.name == "road_network_drop_down" then
    open_gui(player, gui.selected_index)
    return
  end

end

local on_tick = function(event)
  if game.tick % 60 ~= 0 then return end
  for k, player in pairs (game.players) do
    if player.valid then
      refresh_gui(player)
      update_network_overlay_for_player(player)
    end
  end
end

local on_gui_elem_changed = function(event)

  local player = game.get_player(event.player_index)
  if not (player and player.valid) then 
    return 
  end

  local gui = event.element
  if not (gui and gui.valid) then 
    return 
  end


  if gui.name == "depot_filter_button" then
    local filter_value = gui.elem_value
    player_filter_values[player.index] = filter_value
    refresh_gui(player, true)
  end

end

local on_gui_selected_tab_changed = function(event)

  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end

  refresh_gui(player)

end

local on_gui_closed = function(event)
  local element = event.element
  if not (element and element.valid) then return end
  if element.name == "road_network_frame" then
    element.destroy()
    return
  end
end

local on_lua_shortcut = function(event)
  if event.prototype_name ~= "transport-drones-gui" then return end
  toggle_gui(event)
end

local update_overhead_button = function(player_index)
  local player = game.get_player(player_index)
  if not player then return end
  local button_flow = mod_gui.get_button_flow(player)
  if not button_flow then return end

  local button = button_flow[name_button_overhead]

  if player.mod_settings[name_setting_overhead].value == true then
    button = button or button_flow.add{
      type = "sprite-button",
      name = name_button_overhead,
      sprite = "item/transport-drone",
      tooltip = {"shortcut.transport-drones-gui"}
    }
    button.enabled = true
  elseif button then
    button.destroy()
  end
end

commands.add_command("toggle-transport-depot-gui", "idk",
function(command)
  local player = game.player
  if not player then return end
  open_gui(player)
end)

remote.add_interface("Transport_Drones_Meglinge_Fork", {
  increment_network_version = increment_network_version
})

local lib = {}

lib.update_overhead_button = update_overhead_button
lib.increment_network_version = increment_network_version

local on_runtime_mod_setting_changed = function(event)
  if event.player_index and event.setting == name_setting_overhead then
    update_overhead_button(event.player_index)
  end
end

local on_player_joined_game = function(event)
  update_overhead_button(event.player_index)
  
  local player = game.get_player(event.player_index)
  if not player then return end
  
  -- Initialize enabled state: default to true for remote view players
  if storage.player_network_overlay_enabled[player.index] == nil then
    storage.player_network_overlay_enabled[player.index] = player.controller_type == defines.controllers.remote
  end
end

local on_toggle_overlay_shortcut = function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  toggle_network_overlay(player)
end

lib.events =
{
  [defines.events.on_tick] = on_tick,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_gui_selection_state_changed] = on_gui_selection_state_changed,
  [defines.events.on_gui_selected_tab_changed] = on_gui_selected_tab_changed,
  [defines.events.on_gui_elem_changed] = on_gui_elem_changed,
  [defines.events.on_gui_closed] = on_gui_closed,
  ["toggle-road-network-gui"] = toggle_gui,
  ["toggle-transport-network-overlay"] = on_toggle_overlay_shortcut,
  [defines.events.on_lua_shortcut] = on_lua_shortcut,
  [defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
  [defines.events.on_player_joined_game] = on_player_joined_game
}

return lib
