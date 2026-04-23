require ("control.dugwater.control")
require ("control.inserter.control")
require ("control.trees.control")
--require ("control.battery.control")

-- 蓝图吸附点切换
local switch_snap_point = require("scripts.blueprint-snap-point")

-- 初始化存储
script.on_init(function()
  log("PriyUtils: on_init called")
  storage.players = {}
end)

script.on_configuration_changed(function(e)
  log("PriyUtils: on_configuration_changed called")
  if not storage.players then
    storage.players = {}
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  log("PriyUtils: on_player_created called for player " .. e.player_index)
  if not storage.players then
    storage.players = {}
  end
  storage.players[e.player_index] = {}
end)

script.on_event(defines.events.on_player_removed, function(e)
  log("PriyUtils: on_player_removed called for player " .. e.player_index)
  if storage.players then
    storage.players[e.player_index] = nil
  end
end)

-- 处理自定义输入
script.on_event("priyutils-switch-blueprint-snap-point", function(e)
  log("PriyUtils: priyutils-switch-blueprint-snap-point event called for player " .. e.player_index)
  local player = game.get_player(e.player_index)
  if player then
    log("PriyUtils: Got player object")
    switch_snap_point(player)
  else
    log("PriyUtils: Could not get player object")
  end
end)