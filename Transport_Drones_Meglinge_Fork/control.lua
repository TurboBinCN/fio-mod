
shared = require("shared")
util = require("script/script_util")

local handler = require("event_handler")

local gui = require("script/gui")
handler.add_lib(gui)
handler.add_lib(require("script/road_network"))
handler.add_lib(require("script/depot_common"))
handler.add_lib(require("script/transport_drone"))
handler.add_lib(require("script/proxy_tile"))
handler.add_lib(require("script/transport_technologies"))

--require("script/remote_interface")

script.on_init(function()
  rendering.clear("Transport_Drones_Meglinge_Fork")
  for _, player in pairs(game.connected_players) do
    gui.update_overhead_button(player.index)
  end
end)

script.on_configuration_changed(function()
  rendering.clear("Transport_Drones_Meglinge_Fork")
  for _, player in pairs(game.connected_players) do
    gui.update_overhead_button(player.index)
  end
end)

script.on_nth_tick(1, function()
  rendering.clear("Transport_Drones_Meglinge_Fork")
  script.on_nth_tick(1, nil)
end)
