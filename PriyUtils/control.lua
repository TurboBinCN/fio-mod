local Event = { listeners = {} }

function Event.addListener(event_key, callback)
    if not Event.listeners[event_key] then
        Event.listeners[event_key] = {}
        Event.listeners[event_key].callbacks = {}
        Event.listeners[event_key].sequence = function(event)
            for _, cb in pairs(Event.listeners[event_key].callbacks) do
                local status, err = pcall(function() cb(event) end)
                if not status then
                    game.print("PriyUtils: Event error for " .. event_key .. ": " .. err)
                    log(err)
                end
            end
        end
        script.on_event(event_key, Event.listeners[event_key].sequence)
    end
    table.insert(Event.listeners[event_key].callbacks, callback)
end

local loader_snapping = require("scripts.loader-snapping")
for event_name, handler in pairs(loader_snapping.events) do
    Event.addListener(event_name, handler)
end

local dugwater = require("control.dugwater.control")
Event.addListener(defines.events.on_player_built_tile, dugwater.on_player_built_tile)
Event.addListener(defines.events.on_robot_built_tile, dugwater.on_robot_built_tile)

require("control.inserter.control")

local trees = require("control.trees.control")
Event.addListener(defines.events.on_player_built_tile, trees.on_player_built_tile)
Event.addListener(defines.events.on_robot_built_tile, trees.on_robot_built_tile)

local void_storage = require("control.void-storage.control")
void_storage.register_with_event_system(Event)

script.on_init(function()
    void_storage.on_init()
end)

script.on_load(function()
    void_storage.on_load()
end)

script.on_configuration_changed(function(data)
    void_storage.on_configuration_changed(data)
end)