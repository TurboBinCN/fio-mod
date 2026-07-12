local VoidStorage = {}

local message_panel = require("scripts.message_panel")

local CHANNEL_TYPE = {
    CONTAINER = "container",
    TANK = "tank",
    PIPE_TO_GROUND = "pipe_to_ground"
}

local CHANNEL_MODE = {
    LOCAL = "local",
    GLOBAL = "global"
}

local LINK_ID_OFFSET = 1000000

local function get_channel_key(channel_type, channel_mode, channel_name, surface_name)
    if channel_mode == CHANNEL_MODE.LOCAL and surface_name then
        return channel_type .. ":" .. channel_mode .. ":" .. surface_name .. ":" .. channel_name
    end
    return channel_type .. ":" .. channel_mode .. ":" .. channel_name
end

local function get_channel_key_prefix(channel_type, channel_mode, surface_name)
    if channel_mode == CHANNEL_MODE.LOCAL and surface_name then
        return channel_type .. ":" .. channel_mode .. ":" .. surface_name .. ":"
    end
    return channel_type .. ":" .. channel_mode .. ":"
end

local function hash_string(str)
    local hash = 0
    for i = 1, #str do
        local char = string.byte(str, i)
        hash = (hash * 31 + char) % 1000000000
    end
    return hash
end

local function get_link_id_for_channel(channel_key)
    return LINK_ID_OFFSET + hash_string(channel_key)
end

local function init_storage()
    if not storage.priyutils_void_storage then
        storage.priyutils_void_storage = {
            containers = {},
            tanks = {},
            container_channels = {},
            tank_channels = {},
            channel_fluid_inventories = {}
        }
        message_panel.debug("VoidStorage: initialized global storage")
    end
end

local function get_entity_storage_type(entity)
    if entity.name == "priyutils-void-container" then
        return CHANNEL_TYPE.CONTAINER
    elseif entity.name == "priyutils-void-tank" then
        return CHANNEL_TYPE.TANK
    end
    return nil
end

local function get_default_channel(entity)
    local surface_name = entity.surface.name
    return CHANNEL_MODE.LOCAL, surface_name
end

local function parse_channel_key(key)
    local parts = {}
    for part in string.gmatch(key, "([^:]+)") do
        table.insert(parts, part)
    end
    if #parts >= 3 then
        if parts[2] == CHANNEL_MODE.LOCAL and #parts >= 4 then
            return parts[1], parts[2], parts[4], parts[3]
        end
        return parts[1], parts[2], parts[3], nil
    end
    return nil, nil, nil, nil
end

local function add_entity_to_channel(entity, channel_mode, channel_name)
    if not storage or not storage.priyutils_void_storage then return end
    
    local storage_type = get_entity_storage_type(entity)
    if not storage_type then return end

    local channels = storage_type == CHANNEL_TYPE.CONTAINER 
        and storage.priyutils_void_storage.container_channels
        or storage.priyutils_void_storage.tank_channels

    local entities = storage_type == CHANNEL_TYPE.CONTAINER
        and storage.priyutils_void_storage.containers
        or storage.priyutils_void_storage.tanks

    local surface_name = channel_mode == CHANNEL_MODE.LOCAL and entity.surface.name or nil
    local channel_key = get_channel_key(storage_type, channel_mode, channel_name, surface_name)
    
    if not channels[channel_key] then
        channels[channel_key] = {}
    end

    local already_in_channel = false
    for _, unit in ipairs(channels[channel_key]) do
        if unit == entity.unit_number then
            already_in_channel = true
            break
        end
    end
    if not already_in_channel then
        table.insert(channels[channel_key], entity.unit_number)
    end

    local link_id = nil
    if storage_type == CHANNEL_TYPE.CONTAINER then
        link_id = get_link_id_for_channel(channel_key)
        local previous_link_id = entity.link_id
        entity.link_id = link_id
        local current_link_id = entity.link_id
        
        message_panel.debug("VoidStorage: container %d - channel_key: '%s', computed link_id: %d, previous: %s, current: %s", 
            entity.unit_number, channel_key, link_id, 
            previous_link_id and tostring(previous_link_id) or "nil", 
            current_link_id and tostring(current_link_id) or "nil")
    end

    entities[entity.unit_number] = {
        entity = entity,
        channel_mode = channel_mode,
        channel_name = channel_name,
        channel_key = channel_key,
        surface_name = surface_name,
        link_id = link_id
    }
    
    message_panel.debug("VoidStorage: entity %d added to channel '%s:%s'", entity.unit_number, channel_mode, channel_name)
end

local function remove_entity_from_channel(entity)
    if not storage or not storage.priyutils_void_storage then return end
    
    local storage_type = get_entity_storage_type(entity)
    if not storage_type then return end

    local channels = storage_type == CHANNEL_TYPE.CONTAINER 
        and storage.priyutils_void_storage.container_channels
        or storage.priyutils_void_storage.tank_channels

    local entities = storage_type == CHANNEL_TYPE.CONTAINER
        and storage.priyutils_void_storage.containers
        or storage.priyutils_void_storage.tanks

    local entity_data = entities[entity.unit_number]
    if not entity_data then return end

    local channel_key = entity_data.channel_key
    if channels[channel_key] then
        for i, unit in ipairs(channels[channel_key]) do
            if unit == entity.unit_number then
                table.remove(channels[channel_key], i)
                break
            end
        end
        if #channels[channel_key] == 0 then
            channels[channel_key] = nil
            if storage.priyutils_void_storage.channel_fluid_inventories then
                storage.priyutils_void_storage.channel_fluid_inventories[channel_key] = nil
            end
        end
    end

    if storage_type == CHANNEL_TYPE.CONTAINER and entity.valid then
        entity.link_id = 0
        message_panel.debug("VoidStorage: container %d link_id reset to 0", entity.unit_number)
    end
    
    entities[entity.unit_number] = nil
    message_panel.debug("VoidStorage: entity %d removed from channel '%s'", entity.unit_number, entity_data.channel_name)
end

local function sync_tank_channel(channel_key)
    if not storage or not storage.priyutils_void_storage then return end
    local channels = storage.priyutils_void_storage.tank_channels
    local entities = storage.priyutils_void_storage.tanks

    local channel_units = channels[channel_key]
    if not channel_units or #channel_units < 2 then return end

    local valid_units = {}
    for _, unit_number in ipairs(channel_units) do
        local entity_data = entities[unit_number]
        if entity_data and entity_data.entity and entity_data.entity.valid then
            table.insert(valid_units, {unit_number = unit_number, entity_data = entity_data, entity = entity_data.entity})
        end
    end

    if #valid_units < 2 then return end

    -- ========== [Debug Log] 1. 记录同步前所有罐子的状态 ==========
    local pre_sync_total = 0
    message_panel.debug("===== [Sync Start] Channel: " .. channel_key .. " =====")
    for _, unit_data in ipairs(valid_units) do
        local entity = unit_data.entity
        local fb = entity.fluidbox[1]
        local name = fb and entity.name or "nil"
        local amount = fb and fb.amount or 0
        local max_cap = entity.prototype.fluid_capacity or 0
        
        pre_sync_total = pre_sync_total + amount
        message_panel.debug(string.format(
            "[Pre-Sync] Unit: %d | Fluid: %s | Amount: %.2f | MaxCap: %.2f", 
            unit_data.unit_number, name, amount, max_cap
        ))
    end
    message_panel.debug("[Pre-Sync Total] Channel " .. channel_key .. " = " .. pre_sync_total)
    -- ===========================================================

    -- 1. 收集频道内所有罐子的液体信息
    local total_amount = 0
    local fluid_type = nil
    local fluid_count = 0 

    for _, unit_data in ipairs(valid_units) do
        local fluid_data = unit_data.entity.fluidbox[1]
        if fluid_data and fluid_data.amount > 0 then
            fluid_count = fluid_count + 1
            total_amount = total_amount + fluid_data.amount
            if not fluid_type then
                fluid_type = fluid_data.name
            end
        end
    end

    -- 2. 如果没有液体，则清空所有罐子并返回
    if fluid_count == 0 then
        for _, unit_data in ipairs(valid_units) do
            unit_data.entity.fluidbox[1] = nil
            unit_data.entity_data.last_known_fluid = nil
        end
        if storage.priyutils_void_storage.channel_fluid_inventories then
            storage.priyutils_void_storage.channel_fluid_inventories[channel_key] = nil
        end
        message_panel.debug("===== [Sync End] Channel cleared =====")
        return
    end

    -- 3. 计算平均量
    local average_amount = total_amount / fluid_count
    
    -- 🚀 新增：定义一个差异阈值。只有当罐子液位与平均值的差距超过这个值时，才进行同步。
    -- 这个值需要根据你的管道长度和罐子大小来调整，100 是一个不错的起点。
    local threshold = 1000.0 

    -- 4. 将平均量“推送”给频道内的每一个罐子
    local has_changes = false -- 标记本次是否真的进行了修改
    for _, unit_data in ipairs(valid_units) do
        local entity = unit_data.entity
        local current_fluid_data = entity.fluidbox[1]
        local current_fluid_name = current_fluid_data and current_fluid_data.name or nil
        local current_amount = current_fluid_data and current_fluid_data.amount or 0

        -- 只有当罐子为空，或者罐子里的流体与主导流体一致时，才考虑进行平均分配
        if not current_fluid_name or current_fluid_name == fluid_type then
            -- 🚀 核心修改：增加差异判断
            if math.abs(current_amount - average_amount) > threshold then
                if average_amount > 0 then
                    entity.fluidbox[1] = {name = fluid_type, amount = average_amount}
                else
                    entity.fluidbox[1] = nil
                end
                has_changes = true
                message_panel.debug(string.format("[Sync Action] Unit %d: %.2f -> %.2f", unit_data.unit_number, current_amount, average_amount))
            end
        end
    end
    
    -- 如果本次没有进行任何修改，说明所有罐子液位已经足够接近，可以提前结束，避免不必要的日志输出
    if not has_changes then
         message_panel.debug("[Sync Skipped] Levels are balanced within threshold.")
         message_panel.debug("===== [Sync End] Channel: " .. channel_key .. " =====")
         return
    end
    
    -- ========== [Debug Log] 2. 记录同步后所有罐子的状态 ==========
    local post_sync_total = 0
    for _, unit_data in ipairs(valid_units) do
        local entity = unit_data.entity
        local fb = entity.fluidbox[1]
        local name = fb and entity.name or "nil"
        local amount = fb and fb.amount or 0
        
        post_sync_total = post_sync_total + amount
        message_panel.debug(string.format(
            "[Post-Sync] Unit: %d | Fluid: %s | Amount: %.2f", 
            unit_data.unit_number, name, amount
        ))
    end
    message_panel.debug(string.format(
        "[Sync Result] Total: %.2f -> %.2f | Avg: %.2f | Count: %d", 
        pre_sync_total, post_sync_total, average_amount, fluid_count
    ))
    message_panel.debug("===== [Sync End] Channel: " .. channel_key .. " =====")
    -- ===========================================================

    -- 更新频道级别的缓存
    if not storage.priyutils_void_storage.channel_fluid_inventories then
        storage.priyutils_void_storage.channel_fluid_inventories = {}
    end
    storage.priyutils_void_storage.channel_fluid_inventories[channel_key] = {
        fluid = fluid_type,
        amount = total_amount 
    }
end

local function on_entity_created(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end

    local storage_type = get_entity_storage_type(entity)
    if not storage_type then return end

    local default_mode, default_name = get_default_channel(entity)
    add_entity_to_channel(entity, default_mode, default_name)
end

local function on_entity_removed(event)
    local entity = event.entity
    if not entity or not entity.valid then return end

    local storage_type = get_entity_storage_type(entity)
    if not storage_type then return end

    remove_entity_from_channel(entity)
end

local function create_channel_gui(player, entity)
    local window = player.gui.relative.priyutils_void_storage_window
    if window then
        window.destroy()
    end

    local storage_type = get_entity_storage_type(entity)
    if not storage_type then return end

    local entities = storage_type == CHANNEL_TYPE.CONTAINER
        and storage.priyutils_void_storage.containers
        or storage.priyutils_void_storage.tanks

    local entity_data = entities[entity.unit_number]
    if not entity_data then
        local default_mode, default_name = get_default_channel(entity)
        add_entity_to_channel(entity, default_mode, default_name)
        entity_data = entities[entity.unit_number]
    end

    local current_mode = entity_data.channel_mode or CHANNEL_MODE.LOCAL
    local current_channel = entity_data.channel_name
    local channels = storage_type == CHANNEL_TYPE.CONTAINER
        and storage.priyutils_void_storage.container_channels
        or storage.priyutils_void_storage.tank_channels

    local existing_channels = {}
    local surface_name = entity.surface.name
    local prefix = get_channel_key_prefix(storage_type, current_mode, surface_name)
    for key, _ in pairs(channels) do
        if key:sub(1, #prefix) == prefix then
            local _, _, channel_name = parse_channel_key(key)
            if channel_name then
                table.insert(existing_channels, channel_name)
            end
        end
    end

    local relative_gui_type
    if storage_type == CHANNEL_TYPE.CONTAINER then
        relative_gui_type = defines.relative_gui_type.linked_container_gui
    elseif storage_type == CHANNEL_TYPE.TANK then
        relative_gui_type = defines.relative_gui_type.storage_tank_gui
    else
        relative_gui_type = defines.relative_gui_type.container_gui
    end

    player.gui.relative.add{
        type = "frame",
        name = "priyutils_void_storage_window",
        caption = storage_type == CHANNEL_TYPE.CONTAINER and {"gui.priyutils-void-container-gui-title"} or {"gui.priyutils-void-tank-gui-title"},
        anchor = {
            gui = relative_gui_type,
            position = defines.relative_gui_position.right,
        },
        direction = "vertical"
    }

    local window = player.gui.relative.priyutils_void_storage_window
    window.style.width = 260
    window.style.minimal_height = 300

    local inner_frame = window.add{
        type = "frame",
        name = "priyutils_void_storage_inner_frame",
        direction = "vertical",
        style = "inside_shallow_frame_with_padding"
    }

    local mode_switch = inner_frame.add{
        type = "switch",
        name = "priyutils_void_storage_mode_switch",
        left_label_caption = {"gui.priyutils-void-storage-local-mode"},
        right_label_caption = {"gui.priyutils-void-storage-global-mode"},
        switch_state = current_mode == CHANNEL_MODE.GLOBAL and "right" or "left"
    }

    local channel_label = inner_frame.add{type = "label", caption = {"gui.priyutils-void-storage-channel-label"}}
    channel_label.style.font = "heading-2"

    local channel_list = inner_frame.add{
        type = "list-box",
        name = "priyutils_channel_list",
        items = existing_channels
    }
    channel_list.style.width = 230
    channel_list.style.height = 120

    for i, name in ipairs(existing_channels) do
        if name == current_channel then
            channel_list.selected_index = i
            break
        end
    end

    local new_channel_frame = inner_frame.add{
        type = "flow", 
        name = "priyutils_new_channel_flow",
        direction = "horizontal"
    }

    local new_channel_textfield = new_channel_frame.add{
        type = "textfield",
        name = "priyutils_new_channel_textfield",
        placeholder_text = {"gui.priyutils-void-storage-new-channel-placeholder"}
    }
    new_channel_textfield.style.width = 150

    local add_channel_button = new_channel_frame.add{
        type = "button",
        name = "priyutils_add_channel_button",
        caption = {"gui.priyutils-void-storage-add-channel-button"}
    }
    add_channel_button.style.width = 60

    local button_frame = inner_frame.add{
        type = "flow",
        name = "priyutils_void_storage_button_frame",
        direction = "horizontal"
    }
    button_frame.style.horizontal_align = "right"
    button_frame.style.top_padding = 8

    local ok_button = button_frame.add{
        type = "button",
        name = "priyutils_void_storage_ok_button",
        caption = {"gui.priyutils-void-storage-ok"}
    }
    ok_button.style.width = 60

    local cancel_button = button_frame.add{
        type = "button",
        name = "priyutils_void_storage_cancel_button",
        caption = {"gui.priyutils-void-storage-cancel"}
    }
    cancel_button.style.width = 60

    storage.priyutils_void_storage_open_gui = storage.priyutils_void_storage_open_gui or {}
    storage.priyutils_void_storage_open_gui[player.index] = {
        entity = entity,
        storage_type = storage_type
    }
end

local function on_gui_opened(event)
    if not storage then storage = {} end
    if not storage.priyutils_void_storage then init_storage() end
    
    local player = game.get_player(event.player_index)
    if not player then return end

    if player.opened_gui_type ~= defines.gui_type.entity then
        return
    end

    local entity = player.opened
    if not entity or not entity.valid then return end

    local storage_type = get_entity_storage_type(entity)
    if not storage_type then return end

    create_channel_gui(player, entity)
end

local function on_gui_closed(event)
    if not storage then return end
    
    local player = game.get_player(event.player_index)
    if not player then return end

    if player.gui.relative.priyutils_void_storage_window then
        player.gui.relative.priyutils_void_storage_window.destroy()
    end

    if storage.priyutils_void_storage_open_gui and storage.priyutils_void_storage_open_gui[player.index] then
        storage.priyutils_void_storage_open_gui[player.index] = nil
    end
end

local function on_gui_click(event)
    if not storage or not storage.priyutils_void_storage then return end
    
    local player = game.get_player(event.player_index)
    if not player then return end

    local gui_data = storage.priyutils_void_storage_open_gui and storage.priyutils_void_storage_open_gui[player.index]
    if not gui_data then return end

    local entity = gui_data.entity
    local storage_type = gui_data.storage_type

    local clicked_element = event.element
    if not clicked_element then return end

    if clicked_element.name == "priyutils_add_channel_button" then
        message_panel.debug("VoidStorage: add_channel_button clicked")
        
        local window = player.gui.relative.priyutils_void_storage_window
        if not window then 
            message_panel.debug("VoidStorage: window not found")
            return 
        end
        
        local inner_frame = window.priyutils_void_storage_inner_frame
        if not inner_frame then 
            message_panel.debug("VoidStorage: inner_frame not found")
            return 
        end
        
        local mode_switch = inner_frame.priyutils_void_storage_mode_switch
        local channel_mode = mode_switch and mode_switch.switch_state == "right" and CHANNEL_MODE.GLOBAL or CHANNEL_MODE.LOCAL
        
        local new_channel_flow = inner_frame.priyutils_new_channel_flow
        if not new_channel_flow then 
            message_panel.debug("VoidStorage: new_channel_flow not found")
            return 
        end
        
        local textfield = new_channel_flow.priyutils_new_channel_textfield
        if not textfield then 
            message_panel.debug("VoidStorage: textfield not found")
            return 
        end
        
        local new_channel_name = textfield.text:gsub("^%s*(.-)%s*$", "%1")
        message_panel.debug("VoidStorage: new_channel_name = '" .. (new_channel_name or "") .. "', mode = " .. channel_mode)
        
        if new_channel_name and new_channel_name ~= "" then
            remove_entity_from_channel(entity)
            add_entity_to_channel(entity, channel_mode, new_channel_name)
            message_panel.debug("VoidStorage: entity added to new channel '" .. channel_mode .. ":" .. new_channel_name .. "'")

            local channels = storage_type == CHANNEL_TYPE.CONTAINER
                and storage.priyutils_void_storage.container_channels
                or storage.priyutils_void_storage.tank_channels

            local channel_list = inner_frame.priyutils_channel_list
            if channel_list then
                local existing_channels = {}
                local surface_name = entity and entity.surface and entity.surface.name or nil
                local prefix = get_channel_key_prefix(storage_type, channel_mode, surface_name)
                for key, _ in pairs(channels) do
                    if key:sub(1, #prefix) == prefix then
                        local _, _, channel_name = parse_channel_key(key)
                        if channel_name then
                            table.insert(existing_channels, channel_name)
                        end
                    end
                end
                message_panel.debug("VoidStorage: refreshing channel list, total channels: " .. #existing_channels)
                channel_list.items = existing_channels
                
                for i, name in ipairs(existing_channels) do
                    if name == new_channel_name then
                        channel_list.selected_index = i
                        message_panel.debug("VoidStorage: selected_index set to " .. i)
                        break
                    end
                end
            else
                message_panel.debug("VoidStorage: channel_list not found")
            end

            textfield.text = ""
            message_panel.debug("VoidStorage: textfield cleared")
        else
            message_panel.debug("VoidStorage: new_channel_name is empty")
        end
    elseif clicked_element.name == "priyutils_void_storage_ok_button" then
        if player.gui.relative.priyutils_void_storage_window then
            player.gui.relative.priyutils_void_storage_window.destroy()
        end
        if storage.priyutils_void_storage_open_gui and storage.priyutils_void_storage_open_gui[player.index] then
            storage.priyutils_void_storage_open_gui[player.index] = nil
        end
    elseif clicked_element.name == "priyutils_void_storage_cancel_button" then
        if player.gui.relative.priyutils_void_storage_window then
            player.gui.relative.priyutils_void_storage_window.destroy()
        end
        if storage.priyutils_void_storage_open_gui and storage.priyutils_void_storage_open_gui[player.index] then
            storage.priyutils_void_storage_open_gui[player.index] = nil
        end
    end
end

local function on_gui_switch_state_changed(event)
    if not storage or not storage.priyutils_void_storage then return end
    
    local player = game.get_player(event.player_index)
    if not player then return end

    local gui_data = storage.priyutils_void_storage_open_gui and storage.priyutils_void_storage_open_gui[player.index]
    if not gui_data then return end

    local entity = gui_data.entity
    local storage_type = gui_data.storage_type

    local clicked_element = event.element
    if not clicked_element then return end

    if clicked_element.name == "priyutils_void_storage_mode_switch" then
        local window = player.gui.relative.priyutils_void_storage_window
        if not window then return end
        
        local inner_frame = window.priyutils_void_storage_inner_frame
        if not inner_frame then return end
        
        local channel_mode = clicked_element.switch_state == "right" and CHANNEL_MODE.GLOBAL or CHANNEL_MODE.LOCAL
        local channels = storage_type == CHANNEL_TYPE.CONTAINER
            and storage.priyutils_void_storage.container_channels
            or storage.priyutils_void_storage.tank_channels
        
        local existing_channels = {}
        local surface_name = entity and entity.surface and entity.surface.name or nil
        local prefix = get_channel_key_prefix(storage_type, channel_mode, surface_name)
        for key, _ in pairs(channels) do
            if key:sub(1, #prefix) == prefix then
                local _, _, channel_name = parse_channel_key(key)
                if channel_name then
                    table.insert(existing_channels, channel_name)
                end
            end
        end
        
        local channel_list = inner_frame.priyutils_channel_list
        if channel_list then
            channel_list.items = existing_channels
            channel_list.selected_index = 0
        end
        
        message_panel.debug("VoidStorage: mode switched to " .. channel_mode)
    end
end

local function on_gui_selection_state_changed(event)
    if not storage or not storage.priyutils_void_storage then return end
    
    local player = game.get_player(event.player_index)
    if not player then return end

    local gui_data = storage.priyutils_void_storage_open_gui and storage.priyutils_void_storage_open_gui[player.index]
    if not gui_data then return end

    local entity = gui_data.entity
    local storage_type = gui_data.storage_type

    local clicked_element = event.element
    if not clicked_element then return end

    if clicked_element.name == "priyutils_channel_list" then
        local selected_index = clicked_element.selected_index
        if not selected_index or selected_index == 0 then return end
        
        local selected_channel = clicked_element.items[selected_index]
        if selected_channel then
            local window = player.gui.relative.priyutils_void_storage_window
            if not window then return end
            
            local inner_frame = window.priyutils_void_storage_inner_frame
            if not inner_frame then return end
            
            local mode_switch = inner_frame.priyutils_void_storage_mode_switch
            local channel_mode = mode_switch and mode_switch.switch_state == "right" and CHANNEL_MODE.GLOBAL or CHANNEL_MODE.LOCAL
            
            local entities = storage_type == CHANNEL_TYPE.CONTAINER
                and storage.priyutils_void_storage.containers
                or storage.priyutils_void_storage.tanks
            local entity_data = entities[entity.unit_number]
            if entity_data and (entity_data.channel_name ~= selected_channel or entity_data.channel_mode ~= channel_mode) then
                local saved_items = nil
                if storage_type == CHANNEL_TYPE.CONTAINER then
                    local inv = entity.get_inventory(defines.inventory.chest)
                    if inv and inv.valid then
                        saved_items = {}
                        for slot = 1, #inv do
                            local stack = inv[slot]
                            if stack and stack.valid and stack.valid_for_read then
                                table.insert(saved_items, {name = stack.name, count = stack.count})
                            end
                        end
                    end
                end
                
                remove_entity_from_channel(entity)
                add_entity_to_channel(entity, channel_mode, selected_channel)
                
                if saved_items and #saved_items > 0 then
                    local inv = entity.get_inventory(defines.inventory.chest)
                    if inv and inv.valid then
                        for _, item in ipairs(saved_items) do
                            inv.insert({name = item.name, count = item.count})
                        end
                        message_panel.debug("VoidStorage: transferred %d item types to new channel", #saved_items)
                    end
                end
            end
        end
    end
end

local function on_tick(event)
    if event.tick % 60 ~= 0 then return end

    if not storage or not storage.priyutils_void_storage then return end

    for key, _ in pairs(storage.priyutils_void_storage.tank_channels) do
        sync_tank_channel(key)
    end
end

local function on_init()
    init_storage()
    storage.priyutils_void_storage_open_gui = {}
end

local function on_load()
    if not storage or not storage.priyutils_void_storage then return end
    
    for unit_number, entity_data in pairs(storage.priyutils_void_storage.containers) do
        if entity_data.entity and entity_data.entity.valid then
            local engine_link_id = entity_data.entity.link_id
            local saved_link_id = entity_data.link_id
            
            message_panel.debug("VoidStorage: on_load container %d - engine link_id: %s, saved link_id: %s", 
                unit_number, engine_link_id and tostring(engine_link_id) or "nil", 
                saved_link_id and tostring(saved_link_id) or "nil")
            
            if saved_link_id and (not engine_link_id or engine_link_id ~= saved_link_id) then
                entity_data.entity.link_id = saved_link_id
                message_panel.debug("VoidStorage: restored link_id %d for container %d", saved_link_id, unit_number)
            end
        end
    end
end

local function on_configuration_changed(data)
    if not storage then storage = {} end
    if not storage.priyutils_void_storage then
        init_storage()
    end
end

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)

script.on_event(defines.events.on_built_entity, on_entity_created)
script.on_event(defines.events.on_robot_built_entity, on_entity_created)
script.on_event(defines.events.script_raised_built, on_entity_created)
script.on_event(defines.events.on_entity_died, on_entity_removed)
script.on_event(defines.events.on_player_mined_entity, on_entity_removed)
script.on_event(defines.events.on_robot_mined_entity, on_entity_removed)
script.on_event(defines.events.script_raised_destroy, on_entity_removed)

script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)
script.on_event(defines.events.on_gui_switch_state_changed, on_gui_switch_state_changed)

script.on_event(defines.events.on_tick, on_tick)

return VoidStorage