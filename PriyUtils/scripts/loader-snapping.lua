local flib_direction = require("__flib__.direction")
local flib_position = require("__flib__.position")

local offsets = {
  [defines.direction.north] = { 0, -1 },
  [defines.direction.east] = { 1, 0 },
  [defines.direction.south] = { 0, 1 },
  [defines.direction.west] = { -1, 0 },
}

local belt_types = {
  "linked-belt",
  "loader",
  "loader-1x1",
  "splitter",
  "transport-belt",
  "underground-belt",
}

local container_types = {
  "assembling-machine",
  "beacon",
  "boiler",
  "burner-generator",
  "container",
  "curved-rail",
  "furnace",
  "infinity-container",
  "lab",
  "linked-container",
  "logistic-container",
  "mining-drill",
  "proxy-container",
  "rail",
  "reactor",
  "rocket-silo",
  "straight-rail",
}

local function flip_loader(entity)
  entity.direction = flib_direction.opposite(entity.direction)
  entity.loader_type = entity.loader_type == "output" and "input" or "output"
end

local function find_entities(surface, position, force, types)
  local entities = surface.find_entities_filtered({
    force = force,
    position = position,
    type = types,
  })
  local ghosts = surface.find_entities_filtered({
    force = force,
    ghost_type = types,
    position = position,
  })
  for i = 1, #ghosts do
    entities[#entities + 1] = ghosts[i]
  end
  return entities
end

local function snap_direction(entity)
  local offset_direction = entity.direction
  if entity.loader_type == "input" then
    offset_direction = flib_direction.opposite(offset_direction)
  end
  local container_position = flib_position.add(entity.position, offsets[offset_direction])

  local containers = find_entities(entity.surface, container_position, entity.force, container_types)
  if #containers > 0 then
    local is_composite = entity.surface.count_entities_filtered({
      force = entity.force,
      position = container_position,
      type = { "loader", "loader-1x1" },
    }) > 0
    if not is_composite then
      flip_loader(entity)
      return
    end
  end

  offset_direction = flib_direction.opposite(offset_direction)
  local belt_position = flib_position.add(entity.position, offsets[offset_direction])
  local belt = find_entities(entity.surface, belt_position, entity.force, belt_types)[1]
  if not belt then
    return
  end

  local belt_type = belt.type
  if belt_type == "entity-ghost" then
    belt_type = belt.ghost_type
  end
  if
    belt_type == "transport-belt"
    or belt_type == "underground-belt"
    or math.abs(offset_direction - belt.direction) % 4 == 0
  then
    flip_loader(entity)
  end
end

local function snap_to_belt(entity)
  local offset_direction = entity.direction
  if entity.loader_type == "input" then
    offset_direction = flib_direction.opposite(offset_direction)
  end
  local belt_position = flib_position.add(entity.position, offsets[offset_direction])

  local belt = find_entities(entity.surface, belt_position, entity.force, belt_types)[1]
  if not belt then
    return
  end

  local belt_direction = belt.direction
  local belt_type = belt.type
  if belt_type == "entity-ghost" then
    belt_type = belt.ghost_type
  end
  if entity.direction == belt_direction then
    -- Pass
  elseif entity.direction == flib_direction.opposite(belt_direction) then
    entity.loader_type = "input"
  elseif belt_type == "transport-belt" or belt_type == "underground-belt" then
    entity.loader_type = "output"
  end
end

local function on_entity_built(e)
  local entity = e.entity or e.destination
  if not entity.valid or not string.match(entity.name, "^priy.*-loader$") then
    return
  end

  entity.update_connections()
  if not entity.loader_container then
    snap_direction(entity)
  end

  snap_to_belt(entity)
end

local snap_loader = {}

local event_handlers = {}

function snap_loader.register_event(event_name, handler)
    if not event_handlers[event_name] then
        event_handlers[event_name] = {}
    end
    table.insert(event_handlers[event_name], handler)
end

snap_loader.register_event(defines.events.on_built_entity, on_entity_built)
snap_loader.register_event(defines.events.on_entity_cloned, on_entity_built)
snap_loader.register_event(defines.events.on_robot_built_entity, on_entity_built)
snap_loader.register_event(defines.events.script_raised_built, on_entity_built)
snap_loader.register_event(defines.events.script_raised_revive, on_entity_built)
snap_loader.register_event(defines.events.on_space_platform_built_entity, on_entity_built)

snap_loader.events = {}
for event_name, handlers in pairs(event_handlers) do
    snap_loader.events[event_name] = function(event)
        for _, handler in ipairs(handlers) do
            handler(event)
        end
    end
end

return snap_loader