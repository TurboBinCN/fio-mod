local message_panel = {}

local LOG_LEVEL = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    NONE = 5
}

local current_log_level = LOG_LEVEL.DEBUG
local enable_game_print = true
local enable_log_file = true

function message_panel.set_log_level(level)
    if LOG_LEVEL[level:upper()] then
        current_log_level = LOG_LEVEL[level:upper()]
    end
end

function message_panel.set_game_print(enabled)
    enable_game_print = enabled
end

function message_panel.set_log_file(enabled)
    enable_log_file = enabled
end

function message_panel.get_log_level()
    for name, level in pairs(LOG_LEVEL) do
        if level == current_log_level then
            return name
        end
    end
    return "UNKNOWN"
end

local function should_log(level)
    return level >= current_log_level
end

local function format_message(level, msg, ...)
    local level_str
    local color_code
    if level == LOG_LEVEL.DEBUG then
        level_str = "[DEBUG]"
        color_code = ""
    elseif level == LOG_LEVEL.INFO then
        level_str = "[INFO]"
        color_code = "[color=blue]"
    elseif level == LOG_LEVEL.WARN then
        level_str = "[WARN]"
        color_code = "[color=yellow]"
    elseif level == LOG_LEVEL.ERROR then
        level_str = "[ERROR]"
        color_code = "[color=red]"
    else
        level_str = "[UNKNOWN]"
        color_code = ""
    end
    
    local timestamp = game and game.tick or "N/A"
    local formatted = string.format("[PriyUtils] [%s] %s: %s", timestamp, level_str, string.format(msg, ...))
    
    return formatted, color_code
end

function message_panel.debug(msg, ...)
    if not should_log(LOG_LEVEL.DEBUG) then return end
    local formatted, _ = format_message(LOG_LEVEL.DEBUG, msg, ...)
    if enable_log_file then
        log(formatted)
    end
    if enable_game_print and game then
        game.print(formatted)
    end
end

function message_panel.info(msg, ...)
    if not should_log(LOG_LEVEL.INFO) then return end
    local formatted, color_code = format_message(LOG_LEVEL.INFO, msg, ...)
    if enable_log_file then
        log(formatted)
    end
    if enable_game_print and game then
        game.print(color_code .. formatted .. "[/color]")
    end
end

function message_panel.warn(msg, ...)
    if not should_log(LOG_LEVEL.WARN) then return end
    local formatted, color_code = format_message(LOG_LEVEL.WARN, msg, ...)
    if enable_log_file then
        log(formatted)
    end
    if enable_game_print and game then
        game.print(color_code .. formatted .. "[/color]")
    end
end

function message_panel.error(msg, ...)
    if not should_log(LOG_LEVEL.ERROR) then return end
    local formatted, color_code = format_message(LOG_LEVEL.ERROR, msg, ...)
    if enable_log_file then
        log(formatted)
    end
    if enable_game_print and game then
        game.print(color_code .. formatted .. "[/color]")
    end
end

function message_panel.log_and_print(msg, ...)
    message_panel.info(msg, ...)
end

function message_panel.say(entity, text, color, duration)
    if not entity or not entity.valid then return end
    if not entity.surface or not entity.surface.valid then return end
    
    color = color or { r = 1, g = 0, b = 0 }
    duration = duration or 120
    
    rendering.draw_text {
        surface = entity.surface,
        target = entity,
        text = text,
        color = color,
        alignment = "center",
        scale = 1.2,
        time_to_live = duration
    }
end

function message_panel.notify_player(player_index, msg, ...)
    local player = game.get_player(player_index)
    if not player then return end
    
    local formatted = string.format(msg, ...)
    player.print(formatted)
end

function message_panel.notify_all_players(msg, ...)
    local formatted = string.format(msg, ...)
    game.print(formatted)
end

function message_panel.show_floating_text(entity, text, color, offset)
    if not entity or not entity.valid then return end
    if not entity.surface or not entity.surface.valid then return end
    
    color = color or { r = 1, g = 1, b = 1 }
    offset = offset or { x = 0, y = -1 }
    
    rendering.draw_text {
        surface = entity.surface,
        target = { entity = entity, offset = offset },
        text = text,
        color = color,
        alignment = "center",
        scale = 1.0,
        time_to_live = 60
    }
end

function message_panel.show_progress(entity, progress, duration)
    if not entity or not entity.valid then return end
    if not entity.surface or not entity.surface.valid then return end
    
    duration = duration or 120
    local text = string.format("Progress: %.0f%%", progress * 100)
    
    rendering.draw_text {
        surface = entity.surface,
        target = { entity = entity, offset = { 0, -1.5 } },
        text = text,
        color = { r = 0, g = 1, b = 0 },
        alignment = "center",
        scale = 1.0,
        time_to_live = duration
    }
end

function message_panel.table_to_string(tbl, indent)
    indent = indent or 0
    local str = ""
    local spaces = string.rep("  ", indent)
    
    if type(tbl) == "table" then
        str = str .. "{\n"
        for k, v in pairs(tbl) do
            str = str .. spaces .. "  " .. tostring(k) .. " = "
            if type(v) == "table" then
                str = str .. message_panel.table_to_string(v, indent + 1)
            elseif type(v) == "string" then
                str = str .. '"' .. v .. '"\n'
            else
                str = str .. tostring(v) .. "\n"
            end
        end
        str = str .. spaces .. "}"
    else
        str = tostring(tbl)
    end
    
    return str
end

function message_panel.dump_table(tbl, name)
    name = name or "table"
    message_panel.debug("%s = %s", name, message_panel.table_to_string(tbl))
end

return message_panel