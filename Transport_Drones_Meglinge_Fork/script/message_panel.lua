local DEBUG_MODE = true -- 设置为 true 开启日志，false 关闭日志
local message_panel = {}
function message_panel:log_and_print(msg)
    if DEBUG_MODE then
        log(msg)
        game.print(msg)
    end
end
function message_panel:say(entity,text)
    if entity.surface and entity.surface.valid then
        rendering.draw_text {
            surface = entity.surface.index,
            target = entity,
            text = text,
            color = { r = 1, g = 0, b = 0 },
            alignment = "center",
            scale = 1.2,
            time_to_live = 120
        }
    end
end
return message_panel
