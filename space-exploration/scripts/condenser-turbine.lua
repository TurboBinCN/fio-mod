local CondenserTurbine = {}

-- This file handles all compound entities that act as condensor turbines, taking steam and outputting water.

---List of all condenser turbine prototypes that this file will handle
---@type table<string, CondenserTurbineConfig>
CondenserTurbine.turbine_configs = {
  ["se-condenser-turbine"] = {
    name = "se-condenser-turbine",
    generator_names = {"se-condenser-turbine-generator"},
    get_generator_name = function() return "se-condenser-turbine-generator" end,
    tank_name = "se-condenser-turbine-tank",
    tank_offset = 2,
    rotatable = true,
  },
  ["se-big-turbine"] = {
    name = "se-big-turbine",
    generator_names = {"se-big-turbine-generator-NW", "se-big-turbine-generator-SE"},
    get_generator_name = function(entity)
      if entity.direction == defines.direction.north or entity.direction == defines.direction.west then
        return "se-big-turbine-generator-NW"
      else
        return "se-big-turbine-generator-SE"
      end
    end,
    tank_name = "se-big-turbine-tank",
    tank_offset = 4.5,
    rotatable = false, -- Not supported for now because of different generator prototypes
  }
}

if script.active_mods["Krastorio2"] then
  CondenserTurbine.turbine_configs["se-kr-advanced-condenser-turbine"] = {
    name = "se-kr-advanced-condenser-turbine",
    generator_names = {"se-kr-advanced-condenser-turbine-generator"},
    get_generator_name = function() return "se-kr-advanced-condenser-turbine-generator" end,
    tank_name = "se-kr-advanced-condenser-turbine-tank",
    tank_offset = 3,
    rotatable = true,
  }
end

---@param entity LuaEntity
---@param config CondenserTurbineConfig
---@return MapPosition.0
function CondenserTurbine.determine_tank_position(entity, config)
    local direction_vector = Util.vector_multiply(Util.direction_to_vector(entity.direction), -1)
    local tank_position_offset = Util.vector_multiply(direction_vector, config.tank_offset)
    return Util.vectors_add(entity.position, tank_position_offset)
end

---@param entity LuaEntity
---@return LuaEntity?
function CondenserTurbine.find_generator(entity)
  local config = CondenserTurbine.turbine_configs[entity.name]
  if not config then return end
  for _, generator in pairs(entity.surface.find_entities_filtered({
    name = config.generator_names,
    area = entity.bounding_box,
    limit = 1
  })) do
      return generator
  end
end

---@param event EntityCreationEvent Event data
function CondenserTurbine.on_entity_created(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local config = CondenserTurbine.turbine_configs[entity.name]
  if not config then return end

  entity.rotatable = config.rotatable

  local generator = entity.surface.create_entity{
    name = config.get_generator_name(entity),
    position = entity.position,
    direction = entity.direction,
    force = entity.force
  }
  ---@cast generator -?
  generator.destructible = false

  local tank = entity.surface.create_entity{
    name = config.tank_name,
    position = CondenserTurbine.determine_tank_position(entity, config),
    direction = entity.direction,
    force = entity.force
  }
  if tank then
    tank.destructible = false
  else
    game.print("condenser-turbine-tank error")
  end
end
Event.addOnEntityCreatedListeners(CondenserTurbine.on_entity_created)

---@param event EntityRemovalEvent Event data
function CondenserTurbine.on_entity_removed(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local config = CondenserTurbine.turbine_configs[entity.name]
  if not config then return end

  local generator = CondenserTurbine.find_generator(entity)
  if generator then generator.destroy() end

  for _, tank in pairs(entity.surface.find_entities_filtered({
    name= config.tank_name,
    area = entity.bounding_box
  })) do
   tank.destroy()
  end
end
Event.addOnEntityRemovedListeners(CondenserTurbine.on_entity_removed)

---@param event EventData.on_player_rotated_entity Event data
function CondenserTurbine.on_player_rotated_entity(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local config = CondenserTurbine.turbine_configs[entity.name]
  if not config then return end
  if not config.rotatable then return end

  for _, tank in pairs(entity.surface.find_entities_filtered({
    name = config.tank_name,
    area = entity.bounding_box,
    limit = 1
  })) do
    tank.teleport(CondenserTurbine.determine_tank_position(entity, config))
    tank.direction = entity.direction
  end
end
Event.addListener(defines.events.on_player_rotated_entity, CondenserTurbine.on_player_rotated_entity)

--- Ensures that all turbines in an area on a surface are valid
---@param surface LuaSurface
---@param area BoundingBox
function CondenserTurbine.reset_surface(surface, area)
  for _, config in pairs(CondenserTurbine.turbine_configs) do
    for _, entity in pairs(surface.find_entities_filtered{
      name = config.tank_name,
      area = area
    }) do
      -- TODO: What does this even do?
      entity.direction = entity.direction
    end
  end
end

return CondenserTurbine
