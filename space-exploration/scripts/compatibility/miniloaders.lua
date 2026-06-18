-- NOTE: Always use the Event object for events otherwise it replaces other event handlers.
if script.active_mods["miniloader"] then
  local miniloader_util = require("__miniloader__/lualib/util.lua")

  ---@param ev EventData.on_area_cloned|{destination_surface:LuaSurface, destination_area:BoundingBox} Event data
  local function miniloader_on_area_cloned(ev)
    local miniloaders = miniloader_util.find_miniloaders{
      surface = ev.destination_surface,
      area = ev.destination_area,
      }
    for _, loader in ipairs(miniloaders) do
      miniloader_util.update_inserters(loader)
    end
  end
  Event.addListener(defines.events.on_area_cloned, miniloader_on_area_cloned)

  ---@param ev EventData.on_brush_cloned Event data
  local function miniloader_on_brush_cloned(ev)
    local xmin = nil
    local xmax = nil
    local ymin = nil
    local ymax = nil
    for _, source_position in pairs(ev.source_positions) do
      local x = source_position.x
      local y = source_position.y
      if xmin == nil or x < xmin then xmin = x end
      if xmax == nil or x > xmax then xmax = x end
      if ymin == nil or y < ymin then ymin = y end
      if ymax == nil or y > ymax then ymax = y end
    end
    xmin = xmin + ev.destination_offset.x
    xmax = xmax + 1 + ev.destination_offset.x
    ymin = ymin + ev.destination_offset.y
    ymax = ymax + 1 + ev.destination_offset.y
    local ev2 = {
      destination_surface = ev.destination_surface,
      destination_area = {left_top={xmin,ymin},right_bottom={xmax,ymax}}
    }
    miniloader_on_area_cloned(ev2)
  end
  Event.addListener(defines.events.on_brush_cloned, miniloader_on_brush_cloned)

end
