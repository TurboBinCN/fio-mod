require ("control.dugwater.control")
require ("control.inserter.control")
require ("control.trees.control")

local loader_snapping = require("scripts.loader-snapping")
for event_name, handler in pairs(loader_snapping.events) do
  script.on_event(event_name, handler)
end