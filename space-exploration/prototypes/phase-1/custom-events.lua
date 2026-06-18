local data_util = require("data_util")

local custom_event_names = {
  -- space-elevator.lua
  "on_train_teleport_started",
  "on_train_teleport_finished",
  "on_space_elevator_changed_state",

  -- zone.lua
  "on_zone_surface_created",

  -- launchpad.lua
  "on_cargo_rocket_launched",
  "on_cargo_rocket_padless",

  -- respawn.lua 
  "on_player_respawned",

  -- zonelist.lua
  "on_zonelist_gui_opened",
}

for _, custom_event_name in ipairs(custom_event_names) do
  data:extend{{
    type = "custom-event",
    name = data_util.mod_prefix_snake_case .. custom_event_name
  }}
end
