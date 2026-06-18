local SpaceshipIntegrity = {}

SpaceshipIntegrity.names_tech_integrity = {
  {name = mod_prefix.."spaceship-integrity", bonus_per_level = 100, infinite = false},
  {name = mod_prefix.."factory-spaceship", bonus_per_level = 500, infinite = true}
}
SpaceshipIntegrity.integrity_base = 300
SpaceshipIntegrity.integrity_cost_per_container_slot = 0.5
SpaceshipIntegrity.integrity_cost_per_fluid_capacity = 0.0005 -- 2000 fluid per integrity point
SpaceshipIntegrity.integrity_cost_per_phantom_tile = 0.25
SpaceshipIntegrity.integrity_credit_per_wall = 0.75
SpaceshipIntegrity.integrity_cost_per_equipment_type = {
  ["default"] = 1,
  ["belt-immunity-equipment"] = 0,
  ["movement-bonus-equipment"] = 0,
  ["night-vision-equipment"] = 0,
}

SpaceshipIntegrity.overweight_generator_names = nil -- cache of generator names that add stress
SpaceshipIntegrity.cache_generator_stress = nil -- cache of generator entities that add stress

SpaceshipIntegrity.integrity_affecting_types = {
  {type=""} -- This table cannot be empty. Remove this line when adding an entry.
}
SpaceshipIntegrity.integrity_affecting_names = {
  {name = mod_prefix.."nexus", integrity_stress_container = 2000},
  {name = mod_prefix.."linked-container", integrity_stress_container = 1000},
  {mod = "Krastorio2", name = "kr-antimatter-reactor", integrity_stress_structure = 100, integrity_stress_container = 100, max_speed_multiplier = 0.5},
}

---Cache of some entity's with inventory space where the inventory causes stress to the spaceship.
---We also store it per quality level so that otherwise quality chests are broken on ships, even
---though quality is not officially supported
---@type table<string, defines.inventory>
SpaceshipIntegrity.containers_causing_stress_to_inventory_map = {
  ["container"] = defines.inventory.chest,
  ["logistic-container"] = defines.inventory.chest,
  ["car"] = defines.inventory.car_trunk,
  ["spider-vehicle"] = defines.inventory.spider_trunk,
  ["locomotive"] = defines.inventory.cargo_wagon,
  ["cargo-wagon"] = defines.inventory.cargo_wagon,
  ["temporary-container"] = defines.inventory.chest, -- Dropped cargo pods
}
SpaceshipIntegrity.containers_causing_stress = Util.map_to_keys(SpaceshipIntegrity.containers_causing_stress_to_inventory_map)

---Cache of entity's fluid capacity according to the prototype for stress calculations.
---If the entity is not in this cache it can be ignored for stress calculations.
---@type table<string, double>
SpaceshipIntegrity.cache_fluid_container_capacities_for_stress = {}
for _, prototype in pairs(prototypes.get_entity_filtered({{filter = "type", type = {"storage-tank", "fluid-wagon"}}})) do
  if not prototype.selectable_in_game then goto continue end
  if string.starts(prototype.name, "se-space-pipe") then goto continue end
  if string.ends(prototype.name, "-loader-pipe") then goto continue end
  if prototype.fluid_capacity < 1 then goto continue end

  SpaceshipIntegrity.cache_fluid_container_capacities_for_stress[prototype.name] = prototype.fluid_capacity

  ::continue::
end

---Cache of the fluid capacity stress multiplier for each entity type.
---If the entity is not in this cache it can be ignored for stress calculations.
---@type table<string, double>
SpaceshipIntegrity.cache_fluid_container_stress_multiplier = {}
for prototype_name in pairs(SpaceshipIntegrity.cache_fluid_container_capacities_for_stress) do
  local prototype = prototypes.entity[prototype_name]
  local multiplier = 2
  if prototype.type == "fluid-wagon" then
    multiplier = 0.1
  else
    if string.find(prototype_name, "booster", 1, true) then multiplier = 0.5 end
    if prototype_name == "storage-tank" then multiplier = 1 end
  end
  SpaceshipIntegrity.cache_fluid_container_stress_multiplier[prototype_name] = multiplier
end

---@param force LuaForce
function SpaceshipIntegrity.update_integrity_limit(force)
  local force_data = storage.forces[force.name]
  if not force_data then return end -- Not a force we care about
  local technologies = force.technologies

  local integrity = SpaceshipIntegrity.integrity_base
  for _, tech_branch in pairs(SpaceshipIntegrity.names_tech_integrity) do
    local i = 1
    while i > 0 do
      local tech = technologies[tech_branch.name.."-"..i]
      if (not tech) and i == 1 then
        tech = technologies[tech_branch.name]
      end
      if not tech then
        i = -1
      else
        local levels = tech.level - tech.prototype.level + (tech.researched and 1 or 0)
        integrity = integrity + levels * tech_branch.bonus_per_level
        i = i + 1
      end
    end
  end
  force_data.integrity_limit = integrity
end
Event.addListener(defines.events.on_research_finished, function(event) SpaceshipIntegrity.update_integrity_limit(event.research.force) end)
Event.addListener(defines.events.on_research_reversed, function(event) SpaceshipIntegrity.update_integrity_limit(event.research.force) end)
Event.addListener(defines.events.on_technology_effects_reset, function(event) SpaceshipIntegrity.update_integrity_limit(event.force) end)
Event.addListener(defines.events.on_force_reset, function(event) SpaceshipIntegrity.update_integrity_limit(event.force) end)

---@param force_name string
---@return integer integrity_limit
function SpaceshipIntegrity.get_integrity_limit(force_name)
  local force_data = storage.forces[force_name]
  if not force_data then return SpaceshipIntegrity.integrity_base end
  return force_data.integrity_limit or SpaceshipIntegrity.integrity_base
end


---@param entity_name string
---@return number
function SpaceshipIntegrity.stress_for_generator_name(entity_name)
  if not SpaceshipIntegrity.cache_generator_stress then
    SpaceshipIntegrity.cache_generator_stress = {}
  end
  if SpaceshipIntegrity.cache_generator_stress[entity_name] then
    return SpaceshipIntegrity.cache_generator_stress[entity_name]
  end
  return SpaceshipIntegrity.stress_for_generator_prototype(prototypes.entity[entity_name])
end

---@param prototype LuaEntityPrototype
---@return number
function SpaceshipIntegrity.stress_for_generator_prototype(prototype)
  if not SpaceshipIntegrity.cache_generator_stress then
    SpaceshipIntegrity.cache_generator_stress = {}
  end
  if SpaceshipIntegrity.cache_generator_stress[prototype.name] then
    return SpaceshipIntegrity.cache_generator_stress[prototype.name]
  end
  local max_power = prototype.get_max_energy_production() -- W per tick
  local is_void = prototype.void_energy_source_prototype ~= nil
  local is_burner = prototype.burner_prototype ~= nil
  local is_fluid = prototype.fluid_energy_source_prototype ~= nil
  local is_heat = prototype.heat_energy_source_prototype ~= nil
  local collision_box = prototype.collision_box
  local min_x = math.floor(collision_box.left_top.x * 2) / 2
  local max_x = math.ceil(collision_box.right_bottom.x * 2) / 2
  local min_y = math.floor(collision_box.left_top.y * 2) / 2
  local max_y = math.ceil(collision_box.right_bottom.y * 2) / 2
  local area = (max_x - min_x) * (max_y - min_y)
  local power_per_area = max_power / area
  local multiplier = 1
  if is_burner then
    multiplier = 2
  end
  if is_void then
    multiplier = 100
  end
  local base_cost = power_per_area * multiplier / 1000
  local cost = math.max(0, base_cost - 265)
  -- floor to nearest 5
  cost = 5 * math.floor(cost / 5)
  --Log.debug("generator_cost "..prototype.name.." "..cost)
  SpaceshipIntegrity.cache_generator_stress[prototype.name] = cost
  return cost
end

---@return string[]
function SpaceshipIntegrity.get_overweight_generator_names()
  if SpaceshipIntegrity.overweight_generator_names then return SpaceshipIntegrity.overweight_generator_names end
  local overweights = {}
  local prototypes = prototypes.get_entity_filtered({{filter = "type", type = "generator", mode = "or"}, {filter = "type", type = "burner-generator", mode = "or"}})
  for _, prototype in pairs(prototypes) do
    local cost = SpaceshipIntegrity.stress_for_generator_prototype(prototype)
    if cost > 0 then
      table.insert(overweights, prototype.name)
    end
  end
  SpaceshipIntegrity.overweight_generator_names = overweights
  return overweights
end

---@param breakdown_table {[string]:SpaceshipIntegrityStressBreakdownInfo}
---@param breakdown_key string
---@param added_values SpaceshipIntegrityStressBreakdownInfo
local function add_to_breakdown(breakdown_table, breakdown_key, added_values)
  if not breakdown_table[breakdown_key] then breakdown_table[breakdown_key] = {} end
  for key, value in pairs(added_values) do
    if type(value) == "number" then
      if not breakdown_table[breakdown_key][key] then breakdown_table[breakdown_key][key] = 0 end
      breakdown_table[breakdown_key][key] = breakdown_table[breakdown_key][key] + value
    else
      breakdown_table[breakdown_key][key] = value
    end
  end
end

---@param spaceship SpaceshipType
---@param area? BoundingBox.0
function SpaceshipIntegrity.calculate_integrity_stress(spaceship, area)

  spaceship.integrity_stress_structure = 0
  spaceship.integrity_stress_container = 0
  spaceship.integrity_stress_structure_breakdown = {}
  spaceship.integrity_stress_container_breakdown = {}
  spaceship.integrity_stress_structure_breakdown_string = nil
  spaceship.integrity_stress_container_breakdown_string = nil

  -- use all tiles for the cost even if they are not connected
  -- get walls for an integrity discount
  local surface = Spaceship.get_current_surface(spaceship)
  if not surface then surface = spaceship.console.surface end
  local spaceship_known_tiles = spaceship.known_tiles

  if not area then --- whole surface
    spaceship.tile_count = surface.count_tiles_filtered{name = Spaceship.names_spaceship_floors}
    spaceship.wall_count = surface.count_entities_filtered{name = Spaceship.names_spaceship_walls}
  else
    spaceship.tile_count = spaceship.known_floor_tiles + spaceship.known_bulkhead_tiles
    spaceship.wall_count = 0
    local walls = surface.find_entities_filtered{name = Spaceship.names_spaceship_walls, area = area}
    for _, wall in pairs(walls) do
      local tile_pos = Util.position_to_tile(wall.position)
      if spaceship_known_tiles[tile_pos.x] and spaceship_known_tiles[tile_pos.x][tile_pos.y] == "bulkhead_console_connected"  then
        spaceship.wall_count = spaceship.wall_count + 1
      end
    end
  end

  -- Find weakpoints in the design
  -- If very narrow sections are used in the middle those are not strong,
  -- so we need to increase the cost not decrease it if it gets too narrow.
  -- Scan from front and back so decorative pointy bits are not a problem
  -- don't increase width in jump, follow the edge more loosely.
  -- phantom tiles start at the 50% reduced with mark.
  -- They should not have full effect immediatly.
  local widths = {}
  for x, x_tiles in pairs(spaceship_known_tiles) do
    for y, state in pairs(x_tiles) do
      if state == "floor_console_connected" or state == "bulkhead_console_connected" then
        widths[y] = (widths[y] or 0) + 1
      end
    end
  end
  local front_y = spaceship.known_bounds.left_top.y
  local back_y = spaceship.known_bounds.right_bottom.y

  local front_max_width = 0
  local back_max_width = 0

  local phantom_tiles = 0
  local thin_section_count = 0

  while front_y <= back_y do
    if front_max_width <= back_max_width then
      if widths[front_y] then
        local width = widths[front_y]
        if front_max_width < width then
          front_max_width = math.min(width, front_max_width + 2)
        end
        if width < front_max_width / 2 then
          -- tiles in more extreme hollows count more
          local hollow = (front_max_width / 2 - width)
          phantom_tiles = phantom_tiles + hollow * hollow / (front_max_width / 2)
          thin_section_count = thin_section_count + 1
        end
      end
      front_y = front_y + 1
    else
      if widths[back_y] then
        local width = widths[back_y]
        if back_max_width < width then
          back_max_width = math.min(width, back_max_width + 2)
        end
        if width < back_max_width / 2 then
          local hollow = (back_max_width / 2 - width)
          phantom_tiles = phantom_tiles + hollow * hollow / (front_max_width / 2)
          thin_section_count = thin_section_count + 1
        end
      end
      back_y = back_y - 1
    end
  end
  if phantom_tiles > 0 then
    Log.debug("phantom_tiles " .. phantom_tiles)
  end

  spaceship.container_slot_count = 0

  for _, container in pairs(surface.find_entities_filtered{ type = SpaceshipIntegrity.containers_causing_stress, area = area}) do
    local tile_pos = Util.position_to_tile(container.position)
    if area == nil or (spaceship_known_tiles[tile_pos.x] and spaceship_known_tiles[tile_pos.x][tile_pos.y] == "floor_console_connected") then
      -- We get the container size straight from the inventory to account for inventory override, cargo-pods having dynamic size, and quality
      local inventory = container.get_inventory(SpaceshipIntegrity.containers_causing_stress_to_inventory_map[container.type])
      local container_size = inventory and #inventory or 0

      local mult = 1
      if container.type == "locomotive" or container.type == "cargo-wagon" then
        mult = 0.1 -- 90% discount for trains
      end
      spaceship.container_slot_count = spaceship.container_slot_count + container_size * mult
      local breakdown_order = "a"

      -- Vehicle grids
      if container.type == "car" or container.type == "spider-vehicle" or container.type == "locomotive" or container.type == "cargo-wagon" then
        breakdown_order = "b"
        if container.grid then
          local grid_usage = 0
          for _, equipment in pairs(container.grid.equipment) do
            if equipment and equipment.shape and equipment.shape.width and equipment.shape.height then
              if SpaceshipIntegrity.integrity_cost_per_equipment_type[equipment.type] then
                grid_usage = grid_usage + (SpaceshipIntegrity.integrity_cost_per_equipment_type[equipment.type] * (equipment.shape.width * equipment.shape.height))
              else
                grid_usage = grid_usage + (SpaceshipIntegrity.integrity_cost_per_equipment_type["default"] * (equipment.shape.width * equipment.shape.height))
              end
            end
          end
          if grid_usage > 0 then
            spaceship.integrity_stress_structure = spaceship.integrity_stress_structure + grid_usage
            spaceship.integrity_stress_container = spaceship.integrity_stress_container + grid_usage
            add_to_breakdown(spaceship.integrity_stress_structure_breakdown, container.name, {grid_usage = grid_usage, cost = grid_usage, order = breakdown_order})
            add_to_breakdown(spaceship.integrity_stress_container_breakdown, container.name, {grid_usage = grid_usage, cost = grid_usage, order = breakdown_order})
          end
        end
      end

      if container_size > 0 then
        add_to_breakdown(spaceship.integrity_stress_container_breakdown, container.name,
          {slot_count = container_size, cost = container_size * mult * SpaceshipIntegrity.integrity_cost_per_container_slot, order = breakdown_order})
      end
    end
  end

  spaceship.container_fluid_capacity = 0

  local fluid_containers = surface.find_entities_filtered{type = {"storage-tank", "fluid-wagon"}, area = area}
  for _, container in pairs(fluid_containers) do
    -- Do we care about this container?
    local container_capacity = SpaceshipIntegrity.cache_fluid_container_capacities_for_stress[container.name]
    if not container_capacity then goto continue end

    -- Ensure container is on the ship (if area is not nil)
    if area then
      local tile_pos = Util.position_to_tile(container.position)
      if not spaceship.known_tiles[tile_pos.x] then goto continue end
      if spaceship.known_tiles[tile_pos.x][tile_pos.y] ~= "floor_console_connected" then goto continue end
    end

    local entity_type_multiplier = SpaceshipIntegrity.cache_fluid_container_stress_multiplier[container.name]
    if not entity_type_multiplier then goto continue end -- Should never happen, but just in case

    local breakdown_key = container.name

    local fluid_type_multiplier = 1

    local booster_config = Spaceship.booster_types[container.name]
    if booster_config then -- This is a booster tank
      local fluid = container.get_fluid(1) -- All boosters are storage tanks which always have only one fluidbox
      if fluid and fluid.name ~= booster_config.allowed_fluid then
        -- This booster contains the wrong fluid! We cannot prevent this due to filters on storage tanks not working.
        -- So disincentivize it by making the container stress much higher. Thematically if you put the wrong fluid
        -- in a rocket booster it might not handle it well.
        fluid_type_multiplier = 10 -- big number
        breakdown_key = container.name .."+".. fluid.name
      end
    end

    if fluid_type_multiplier == 1 then
      -- Only look for other multipliers if there are nothing already applied.
      for fluid_name, multiplier in pairs({["steam"] = 2}) do
        if container.get_fluid_count(fluid_name) > 0 then
          fluid_type_multiplier = multiplier
          breakdown_key = container.name .."+".. fluid_name -- + separates container name and fluid name, used for string formatting
          break -- Storage tanks and fluid wagons can only hold one fluid at a time
        end
      end
    end

    local container_cost = fluid_type_multiplier * entity_type_multiplier * container_capacity
    spaceship.container_fluid_capacity = spaceship.container_fluid_capacity + container_cost
    add_to_breakdown(spaceship.integrity_stress_container_breakdown, breakdown_key, {fluid_capacity = container_capacity,
      cost = container_cost * SpaceshipIntegrity.integrity_cost_per_fluid_capacity, order = "c"})

    ::continue::
  end

  spaceship.speed_multiplier = 1

  -- name-based entity modifiers
  local names = {}
  local name_effects = {}
  for _, ia_name in pairs(SpaceshipIntegrity.integrity_affecting_names) do
    table.insert(names, ia_name.name)
    name_effects[ia_name.name] = ia_name
  end
  local entities = surface.find_entities_filtered{name = names, area = area}
  for _, entity in pairs(entities) do
    local tile_pos = Util.position_to_tile(entity.position)
    if area == nil or (spaceship_known_tiles[tile_pos.x] and spaceship_known_tiles[tile_pos.x][tile_pos.y] == "floor_console_connected") then
      local name_effect_set = name_effects[entity.name]
      if name_effect_set.integrity_stress_container then
        spaceship.integrity_stress_container = spaceship.integrity_stress_container + name_effect_set.integrity_stress_container
        add_to_breakdown(spaceship.integrity_stress_container_breakdown, entity.name, {count = 1, cost = name_effect_set.integrity_stress_container, order = "d"})
      end
      if name_effect_set.integrity_stress_structure then
        spaceship.integrity_stress_structure = spaceship.integrity_stress_structure + name_effect_set.integrity_stress_structure
        add_to_breakdown(spaceship.integrity_stress_structure_breakdown, entity.name, {count = 1, cost = name_effect_set.integrity_stress_structure , order = "d"})
      end
      if name_effect_set.max_speed_multiplier then
        spaceship.speed_multiplier = math.min(spaceship.speed_multiplier, name_effect_set.max_speed_multiplier)
      end
    end
  end

  -- type-based entity modifiers
  local types = {}
  local type_effects = {}
  for _, ia_type in pairs(SpaceshipIntegrity.integrity_affecting_types) do
    table.insert(types, ia_type.type)
    type_effects[ia_type.type] = ia_type
  end
  local entities = surface.find_entities_filtered{type = types, area = area}
  for _, entity in pairs(entities) do
    local tile_pos = Util.position_to_tile(entity.position)
    if area == nil or (spaceship_known_tiles[tile_pos.x] and spaceship_known_tiles[tile_pos.x][tile_pos.y] == "floor_console_connected") then
      local type_effect_set = type_effects[entity.type]
      if type_effect_set.integrity_stress_container then
        spaceship.integrity_stress_container = spaceship.integrity_stress_container + type_effect_set.integrity_stress_container
        add_to_breakdown(spaceship.integrity_stress_container_breakdown, entity.name, {count = 1, cost = type_effect_set.integrity_stress_container, order = "d"})
      end
      if type_effect_set.integrity_stress_structure then
        spaceship.integrity_stress_structure = spaceship.integrity_stress_structure + type_effect_set.integrity_stress_structure
        add_to_breakdown(spaceship.integrity_stress_structure_breakdown, entity.name, {count = 1, cost = type_effect_set.integrity_stress_structure, order = "d"})
      end
      if type_effect_set.max_speed_multiplier then
        spaceship.speed_multiplier = math.min(spaceship.speed_multiplier, type_effect_set.max_speed_multiplier)
      end
    end
  end

  local overweight_generator_names = SpaceshipIntegrity.get_overweight_generator_names()
  if next(overweight_generator_names) then
    -- Generators
    --local entities = surface.find_entities_filtered{type = "generator", area = area}
    local entities = surface.find_entities_filtered{name = overweight_generator_names, area = area}
    for _, entity in pairs(entities) do
      local tile_pos = Util.position_to_tile(entity.position)
      if area == nil or (spaceship_known_tiles[tile_pos.x] and spaceship_known_tiles[tile_pos.x][tile_pos.y] == "floor_console_connected") then
        local added_stress = SpaceshipIntegrity.stress_for_generator_name(entity.name)
        spaceship.integrity_stress_structure = spaceship.integrity_stress_structure + added_stress
        spaceship.integrity_stress_container = spaceship.integrity_stress_container + added_stress
        add_to_breakdown(spaceship.integrity_stress_structure_breakdown, entity.name, {count = 1, cost = added_stress, order = "e"})
        add_to_breakdown(spaceship.integrity_stress_container_breakdown, entity.name, {count = 1, cost = added_stress, order = "e"})
      end
    end
  end

  -- container slot is 0.5 or 24 for a normal container 4800 ish items. Cost is 24
  -- container can caryy 48 * 10 barrels = 24k fluid
  -- storage tank is 5, 25k fluids = 250 effective items. Cost is 12.5 (50% discount)
  -- booster tanks cost50% less
  spaceship.integrity_stress_structure =
    spaceship.integrity_stress_structure
    + spaceship.tile_count
    + phantom_tiles * SpaceshipIntegrity.integrity_cost_per_phantom_tile
    - spaceship.wall_count * SpaceshipIntegrity.integrity_credit_per_wall

  add_to_breakdown(spaceship.integrity_stress_structure_breakdown, mod_prefix .. "spaceship-floor", {count = spaceship.tile_count, cost = spaceship.tile_count, order="a-a"})
  add_to_breakdown(spaceship.integrity_stress_structure_breakdown, mod_prefix .. "spaceship-wall", {count = spaceship.wall_count, cost = - spaceship.wall_count * SpaceshipIntegrity.integrity_credit_per_wall, order="a-b"})
  if phantom_tiles > 0 then
    add_to_breakdown(spaceship.integrity_stress_structure_breakdown, "phantom-tiles",
      {count = thin_section_count, cost = phantom_tiles * SpaceshipIntegrity.integrity_cost_per_phantom_tile, order="z-a"})
  end

  spaceship.integrity_stress_container =
    spaceship.integrity_stress_container
    + spaceship.container_slot_count * SpaceshipIntegrity.integrity_cost_per_container_slot
    + spaceship.container_fluid_capacity * SpaceshipIntegrity.integrity_cost_per_fluid_capacity
  -- Already added to breakdown during container check

  -- if the ship is very long and thin start taking integrity penalties.
  local widths_total = 0
  for _, width in pairs(widths) do
    widths_total = widths_total + width
  end
  local width_average = widths_total / table_size(widths)
  local length = spaceship.known_bounds.right_bottom.y - spaceship.known_bounds.left_top.y
  -- over 4:1 length gets a penalty of 5% per additional length
  local integrity_multiplier = 1 + 0.05 * (length / width_average - 4)
  if integrity_multiplier > 1 then
    add_to_breakdown(spaceship.integrity_stress_structure_breakdown, "long-ship", {percentage = integrity_multiplier - 1,
      cost = spaceship.integrity_stress_structure * (integrity_multiplier - 1), order="z-b"})
    spaceship.integrity_stress_structure = spaceship.integrity_stress_structure * integrity_multiplier
  end

  -- corridor allowance
  local empty_tiles = spaceship.count_empty_tiles or 0
  --Log.debug((spaceship.count_empty_tiles or 0) .." / "..(spaceship.tile_count - spaceship.wall_count))
  spaceship.integrity_stress_structure_max = spaceship.integrity_stress_structure
  -- this encourages keeping 10% of the total size empty.
  local effective_empty_tiles = math.min(spaceship.tile_count * 0.1, empty_tiles)
  -- this encourages keeping 20% of the internal space empty.
  -- math.min((spaceship.tile_count - spaceship.wall_count) * 0.2, empty_tiles)
  -- this has the first empty tile discounted by 1, the last by 0, if 20% of the ship is empty they are discouted by 80%
  -- empty_tiles * math.max(0, 1 - empty_tiles / (spaceship.tile_count - spaceship.wall_count))
  spaceship.integrity_stress_structure = spaceship.integrity_stress_structure_max - effective_empty_tiles
  add_to_breakdown(spaceship.integrity_stress_structure_breakdown, "empty-tiles",
    {min = empty_tiles, max = spaceship.tile_count * 0.1, cost = - effective_empty_tiles, order="z-d"})

  spaceship.integrity_stress = math.max(spaceship.integrity_stress_structure, spaceship.integrity_stress_container)

  if spaceship.integrity_stress > spaceship.integrity_limit then
    spaceship.integrity_valid = false
    spaceship.check_message = {"space-exploration.spaceship-check-message-failed-stress"}
  end
end

---@param spaceship SpaceshipType
function SpaceshipIntegrity.check_integrity_stress(spaceship)
  spaceship.integrity_limit = SpaceshipIntegrity.get_integrity_limit(spaceship.force_name)
  if Spaceship.is_on_own_surface(spaceship) then
    -- use all tiles
    SpaceshipIntegrity.calculate_integrity_stress(spaceship, nil) -- whole area
  elseif not (spaceship.console and spaceship.console.valid) then
    spaceship.integrity_valid = false
    spaceship.check_message= {"space-exploration.spaceship-check-message-no-console"}
  elseif not spaceship.integrity_valid then
    -- already invalid
  elseif not spaceship.known_bounds then
    spaceship.integrity_valid = false
    spaceship.check_message= {"space-exploration.spaceship-check-message-failed-unknown-bounds"}
  elseif spaceship.integrity_valid and spaceship.known_bounds and spaceship.known_tiles then
    SpaceshipIntegrity.calculate_integrity_stress(spaceship, spaceship.known_bounds) -- limited area

    --[[ TODO: use improved know tiles approach
    and spaceship.known_tile_count and spaceship.known_wall_count then
    spaceship.integrity_stress = spaceship.known_tile_count - spaceship.known_wall_count / 2
    if spaceship.integrity_stress > spaceship.integrity_limit then
      spaceship.integrity_valid = false
      spaceship.check_message = "Fail: Structural integrity stress exceeds technology limit."
    end
    ]]--
  end

end

---@param spaceship SpaceshipType
---@param alpha? unknown unused
function SpaceshipIntegrity.start_slow_integrity_check(spaceship, alpha)
  spaceship.is_doing_check_slowly = true
  SpaceshipIntegrity.start_integrity_check(spaceship, alpha)
end

---@param spaceship SpaceshipType
---@param alpha? number
function SpaceshipIntegrity.start_integrity_check(spaceship, alpha)
  if alpha then
    spaceship.check_flash_alpha = alpha
  end
  spaceship.is_doing_check = true
end

---@param surface LuaSurface
function SpaceshipIntegrity.restart_integrity_checks_on_surface(surface)
  local zone = Zone.from_surface(surface)
  if not zone then return end
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.zone_index == zone.index and spaceship.is_doing_check then
      SpaceshipIntegrity.restart_integrity_check(spaceship)
    end
  end
end

---@param spaceship SpaceshipType
function SpaceshipIntegrity.restart_integrity_check(spaceship)
  spaceship.check_stage = nil
end

---Called to complete an integrity check.
---@param spaceship SpaceshipType
function SpaceshipIntegrity.stop_integrity_check(spaceship)
  spaceship.check_flash_alpha = nil
  spaceship.is_doing_check = nil
  spaceship.is_doing_check_slowly = nil
  spaceship.check_stage = nil
  spaceship.pending_tiles = nil
  spaceship.streamline = nil
  if spaceship.integrity_valid and spaceship.check_tiles then
    -- success
    spaceship.count_empty_tiles = spaceship.check_count_empty_tiles
    spaceship.check_count_empty_tiles = nil

    spaceship.known_tiles = spaceship.check_tiles
    spaceship.check_tiles = nil

    -- get the average for surface transfer
    local min_x = nil
    local max_x = nil
    local min_y = nil
    local max_y = nil
    local floor_tiles = 0
    local bulkhead_tiles = 0
    local front_tiles = {} -- x:y
    for x, x_tiles in pairs(spaceship.known_tiles) do
      if min_x == nil or x < min_x then min_x = x end
      if max_x == nil or x > max_x then max_x = x end
      for y, status in pairs(x_tiles) do
        if status == "floor_console_connected" or status == "bulkhead_console_connected" then
            if min_y == nil or y < min_y then min_y = y end
            if max_y == nil or y > max_y then max_y = y end
            if status == "floor_console_connected" then
              floor_tiles = floor_tiles + 1
            else
              bulkhead_tiles = bulkhead_tiles + 1
            end
            if (not front_tiles[x]) or y < front_tiles[x] then
               front_tiles[x] = y
            end
        end
      end
    end
    max_x = max_x + 1 -- whole tile
    max_y = max_y + 1 -- whole tile
    spaceship.known_floor_tiles = floor_tiles
    spaceship.known_bulkhead_tiles = bulkhead_tiles
    spaceship.known_bounds = {left_top = {x = min_x, y = min_y}, right_bottom={x = max_x, y = max_y}}
    spaceship.known_tiles_average_x = math.floor((min_x + max_x)/2)
    spaceship.known_tiles_average_y = math.floor((min_y + max_y)/2)
    local front_tiles_by_y = {} -- y:count
    local front_tiles_by_y_left = {} -- y:count
    local front_tiles_by_y_right = {} -- y:count
    local max_flat = 0
    for x, y in pairs(front_tiles) do
      front_tiles_by_y[y] = (front_tiles_by_y[y] or 0) + 1
      if front_tiles_by_y[y] > max_flat then
        max_flat = front_tiles_by_y[y]
      end
      if x < spaceship.known_tiles_average_x then
        front_tiles_by_y_left[y] = (front_tiles_by_y_left[y] or 0) + 1
      else
        front_tiles_by_y_right[y] = (front_tiles_by_y_right[y] or 0) + 1
      end
    end
    local width = max_x - min_x
    -- max_flat == width = 0
    -- max_flat == width / 3 = 1
    local streamline_flatness = math.min(1, (1 - (max_flat-2) / (width-2)) * 1.5)
    local streamline_left = math.min(1, 2 * (table_size(front_tiles_by_y_left)-1) / (math.max(0.5, (width-1) / 2.5)))
    local streamline_right = math.min(1, 2 * (table_size(front_tiles_by_y_right)-1) / (math.max(0.5, (width-1) / 2.5)))
    spaceship.streamline = (streamline_flatness + streamline_left + streamline_right
      + 3 * math.min(streamline_flatness, math.min(streamline_left, streamline_right))) / 6
    --spaceship.streamline = math.min(1, 3.5 * (table_size(front_tiles_by_y)-1) / width)
    -- if it is symetrical then 1/2 would be max (excluding the -1)
    -- use 1/3.5 as max so there can be a few flat areas
    -- Log.debug_log("streamline flat "..streamline_flatness.." left "..streamline_left.." right "..streamline_right)
    --Log.debug("streamline "..spaceship.streamline )
    if Spaceship.is_on_own_surface(spaceship) then
      Spaceship.find_own_surface_engines(spaceship)
    end
  else
    spaceship.integrity_valid = false
    spaceship.check_tiles = nil
    spaceship.check_message = {"space-exploration.spaceship-check-message-failed-empty"}
  end

  --spaceship.check_message = nil
  if spaceship.console and spaceship.console.valid then
    --spaceship.console.force.print("Spaceship integrity check complete.")
  end

  SpaceshipIntegrity.check_integrity_stress(spaceship)

  if spaceship.is_launching then
    Spaceship.launch(spaceship)
  end
end

---@param spaceship SpaceshipType
function SpaceshipIntegrity.integrity_check_tick(spaceship)
  if not(spaceship.console and spaceship.console.valid) then
    spaceship.check_message= {"space-exploration.spaceship-check-message-no-console"}
    spaceship.integrity_valid = false
    SpaceshipIntegrity.stop_integrity_check(spaceship)
    return
  end

  local surface = spaceship.console.surface
  -- check if the player is around
  local player_is_here = not SpaceshipObstacles.surface_has_no_players(surface)

  ---@param surface LuaSurface
  ---@param position MapPosition
  ---@param color Color
  ---@param time uint
  local function flash_tile_if_needed(surface, position, color, time)
    if player_is_here and not spaceship.is_doing_check_slowly then
      Spaceship.flash_tile(surface, position, color, time)
    end
  end

  if not (spaceship.check_stage and spaceship.check_tiles and spaceship.pending_tiles) then
    local start_tile = surface.get_tile(spaceship.console.position)
    if Spaceship.names_spaceship_floors_map[start_tile.name] then
      -- floor tiles is a 2d array x then y
      spaceship.check_count_empty_tiles = 0
      spaceship.check_tiles = {}
      spaceship.check_tiles[start_tile.position.x] = {}
      spaceship.check_tiles[start_tile.position.x][start_tile.position.y] = "floor"
      spaceship.pending_tiles = {}
      spaceship.pending_tiles[start_tile.position.x] = {}
      spaceship.pending_tiles[start_tile.position.x][start_tile.position.y] = true
      spaceship.check_stage = "floor-connectivity"
      spaceship.check_message = {"space-exploration.spaceship-check-message-checking-console-floor"}
    else
      spaceship.check_message = {"space-exploration.spaceship-check-message-failed-console-floor"}
      spaceship.integrity_valid = false
      SpaceshipIntegrity.stop_integrity_check(spaceship)
      return
    end
  end
  if not (spaceship.check_tiles and spaceship.pending_tiles) then return end

  local alpha = spaceship.check_flash_alpha or 0.05
  local spaceship_pending_tiles = spaceship.pending_tiles
  local spaceship_check_tiles = spaceship.check_tiles

  -- do a round of checking
  -- check_tiles. List of tiles to check this tick.

  -- pending_tiles should always exists in check_tiles
  -- it basically justs keeps a lst of which ones to search

  local next_pending_tiles = {}
  local changed = false

  -- floor-connectivity: Starting from console tile, find and mark the type of every tile in the spaceship. Put it in spaceship.check_tiles. This step cannot fail. Also includes the exterior tiles right next to the spaceship.
  if spaceship.check_stage == "floor-connectivity" then
    local position_table = {}
    for x, x_tiles in pairs(spaceship_pending_tiles) do
      for y, _ in pairs(x_tiles) do
        local value = spaceship_check_tiles[x][y]
        if value == "floor" or value == "bulkhead" then
          for d = 1, 4 do -- 4 way direction
            local cx = x + (d == 2 and 1 or (d == 4 and -1 or 0))
            local cy = y + (d == 1 and -1 or (d == 3 and 1 or 0))
            if not (spaceship_check_tiles[cx] and spaceship_check_tiles[cx][cy]) then -- unknown tile
              changed = true
              local tile = surface.get_tile({cx, cy})
              position_table.x = cx + 0.5
              position_table.y = cy + 0.5
              local wall_count = surface.count_entities_filtered{
                position = position_table,
                name = Spaceship.names_spaceship_bulkheads
              }
              if tile.valid and Spaceship.names_spaceship_floors_map[tile.name] then
                spaceship_check_tiles[cx] = spaceship_check_tiles[cx] or {}
                if wall_count > 0 then
                  -- Wall on floor
                  spaceship_check_tiles[cx][cy] = "bulkhead"
                  flash_tile_if_needed(surface, {cx, cy}, {r = 0, g = 0, b = 1, a = alpha}, 5)
                else
                  -- Floor
                  spaceship_check_tiles[cx][cy] = "floor"
                  flash_tile_if_needed(surface, {cx, cy}, {r = 0, g = 1, b = 0, a = alpha}, 5)
                end
                next_pending_tiles[cx] = next_pending_tiles[cx] or {}
                next_pending_tiles[cx][cy] = true
              else
                spaceship_check_tiles[cx] = spaceship_check_tiles[cx] or {}
                if wall_count > 0 then
                  local clamps = surface.count_entities_filtered{
                    position = position_table,
                    name = SpaceshipClamp.name_spaceship_clamp_keep
                  }
                  if clamps > 0 then
                    -- if it is a clamp sticking out of the craft treat it as exterior,
                    -- otherwise it is treated as unstable bulkhead and takes damage
                    spaceship_check_tiles[cx][cy] = "exterior"
                    flash_tile_if_needed(surface, {cx, cy}, {r = 1, g = 0, b = 1, a = alpha}, 5)
                  else
                    -- Wall not on floor
                    spaceship_check_tiles[cx][cy] = "bulkhead_exterior"
                    flash_tile_if_needed(surface, {cx, cy}, {r = 1, g = 0, b = 0, a = alpha}, 5)
                  end
                else
                  -- Empty space just outside the spaceship
                  spaceship_check_tiles[cx][cy] = "exterior"
                  flash_tile_if_needed(surface, {cx, cy}, {r = 1, g = 0, b = 1, a = alpha}, 5)
                end
              end
            end
          end
        end
      end
    end
    if changed == false then
      -- all connected tiles have been found
      -- if in space and if moving detach disconnected tiles
      if spaceship.is_moving then
        local surface = Spaceship.get_own_surface(spaceship)
        if surface then
          local set_tiles = {}
          local all_tiles = surface.find_tiles_filtered{name=Spaceship.names_spaceship_floors}
          for _, tile in pairs(all_tiles) do
            if not (spaceship_check_tiles[tile.position.x] and spaceship_check_tiles[tile.position.x][tile.position.y]) then
              local stack = tile.prototype.items_to_place_this[1]
              table.insert(set_tiles, {name = name_space_tile, position = tile.position, ghost_name = tile.name, stack = stack})
              if player_is_here then
                Spaceship.flash_tile(surface, tile.position, {r = 1, g = 0, b = 0, a = alpha}, 120)
              end
            end
          end
          if next(set_tiles) then
            surface.set_tiles(set_tiles)
            for _, tile in pairs(set_tiles) do
              if Util.table_contains(Spaceship.names_spaceship_floors, tile.ghost_name) then
                surface.create_entity{name = "tile-ghost", inner_name = tile.ghost_name, force = spaceship.force_name, position=tile.position}
              end
            end
          end
        end
      end

      changed = true
      spaceship.check_stage = "containment"
      spaceship.check_message = {"space-exploration.spaceship-check-message-checking-containment"}
      for x, x_tiles in pairs(spaceship_check_tiles) do
        for y, status in pairs(x_tiles) do
          if status == "exterior" or status == "bulkhead_exterior" then
            next_pending_tiles[x] = next_pending_tiles[x] or {}
            next_pending_tiles[x][y] = true
          end
        end
      end
    end

  -- containment: For each exterior tile, find floor touching it, and mark it as exterior floor. All floor touching exterior floor is also exterior floor. Fails if the console is on an exterior floor.
  elseif spaceship.check_stage == "containment" then
    for x, x_tiles in pairs(spaceship_pending_tiles) do
      for y, _ in pairs(x_tiles) do
        local value = spaceship_check_tiles[x][y]
        if value == "exterior" or value == "bulkhead_exterior" or value == "floor_exterior" then
          for cx = x-1, x+1 do -- 8 way direction
            for cy = y-1, y+1 do
              local check_status = spaceship_check_tiles[cx] and spaceship_check_tiles[cx][cy] or nil
              if check_status == "floor" then
                spaceship_check_tiles[cx][cy] = "floor_exterior"
                changed = true
                next_pending_tiles[cx] = next_pending_tiles[cx] or {}
                next_pending_tiles[cx][cy] = true
                flash_tile_if_needed(surface, {cx, cy}, {r = 1, g = 1, b = 0, a = alpha}, 30)
              end
            end
          end
        end
      end
    end
    if changed == false then
      changed = true
      -- convert non-exterior floor to interior
      for x, x_tiles in pairs(spaceship_check_tiles) do
        for y, status in pairs(x_tiles) do
          if status == "floor" then
            x_tiles[y] = "floor_interior"
            flash_tile_if_needed(surface, {x, y}, {r = 0, g = 0, b = 1, a = alpha}, 40)
          end
        end
      end
      local console_tile_x = math.floor(spaceship.console.position.x)
      local console_tile_y = math.floor(spaceship.console.position.y)
      if spaceship_check_tiles[console_tile_x] and spaceship_check_tiles[console_tile_x][console_tile_y] == "floor_interior" then
        spaceship_check_tiles[console_tile_x][console_tile_y] = "floor_console_connected"
        next_pending_tiles[console_tile_x] = {}
        next_pending_tiles[console_tile_x][console_tile_y] = true
        spaceship.check_stage = "console-connectivity"
        spaceship.check_message = {"space-exploration.spaceship-check-message-checking-connectivity"}
      else
        if player_is_here and not spaceship.is_doing_check_slowly then -- same check as in `flash_tile_if_needed`
          for x, x_tiles in pairs(spaceship_check_tiles) do
            for y, status in pairs(x_tiles) do
              if status == "exterior" or status == "bulkhead_exterior" then
                flash_tile_if_needed(surface, {x, y}, {r = 1, g = 0, b = 0, a = alpha}, 120)
              end
            end
          end
        end
        spaceship.integrity_valid = false
        spaceship.check_message =  {"space-exploration.spaceship-check-message-failed-containment"}
        return SpaceshipIntegrity.stop_integrity_check(spaceship)
      end
    end

  -- console-connectivity: There may be several "contained" areas, connected by exterior floor. Mark only the one with the console inside as the spaceship. Also populate check_count_empty_tiles (for corridor integrity bonus later).
  elseif spaceship.check_stage == "console-connectivity" then
    for x, x_tiles in pairs(spaceship_pending_tiles) do
      for y, _ in pairs(x_tiles) do
        local value = spaceship_check_tiles[x][y]
        if value == "floor_console_connected" then
          local blockers = surface.count_entities_filtered{
            position = {x + 0.5, y + 0.5},
            collision_mask = {"object"},
            limit = 1
          }
          if blockers == 0 then -- this tile is clear, add to corridor allowance.
            spaceship.check_count_empty_tiles = (spaceship.check_count_empty_tiles or 0) + 1
          end
        end
        if value == "floor_console_connected"
         or value == "bulkhead_console_connected" then

          for d = 1, 4 do -- 4 way direction
            local cx = x + (d == 2 and 1 or (d == 4 and -1 or 0))
            local cy = y + (d == 1 and -1 or (d == 3 and 1 or 0))
            local check_status = spaceship_check_tiles[cx] and spaceship_check_tiles[cx][cy] or nil
            if check_status == "floor_interior" or check_status == "bulkhead" then
              if check_status == "floor_interior" then
                  spaceship_check_tiles[cx][cy] = "floor_console_connected"
              else
                  spaceship_check_tiles[cx][cy] = "bulkhead_console_connected"
              end
              flash_tile_if_needed(surface, {cx, cy}, {r = 0, g = 1, b = 1, a = alpha}, 5)
              changed = true
              next_pending_tiles[cx] = next_pending_tiles[cx] or {}
              next_pending_tiles[cx][cy] = true
            end
          end
        end
      end
    end
    if changed == false then
      -- completed the check

      spaceship.check_message = nil -- No tooltip required
      spaceship.integrity_valid = true
      local set_tiles = {}
      local reset = false
      for x, x_tiles in pairs(spaceship_check_tiles) do
        for y, status in pairs(x_tiles) do
          if not (status == "floor_console_connected"
              or status == "bulkhead_console_connected"
              or status == "exterior") then
              spaceship.check_message = {"space-exploration.spaceship-check-message-unstable"}
              if player_is_here then
                Spaceship.flash_tile(surface, {x, y}, {r = 1, g = 0, b = 0, a = alpha}, 120)
              end
              -- detatch
              if Spaceship.is_on_own_surface(spaceship) and spaceship.is_moving then
                local support = 1 -- it will count self
                for cx = x-1, x+1 do
                  for cy = y-1, y+1 do
                    if spaceship_check_tiles[cx] and spaceship_check_tiles[cx][cy] then
                      if spaceship_check_tiles[cx][cy] ~= "exterior" then
                        support = support + 1
                        if spaceship_check_tiles[cx][cy] == "bulkhead_console_connected" then
                          support = support + 2
                        end
                      end
                    end
                  end
                end
                if support <= 6 then -- has a chance to be removed
                  reset = true
                  if support - math.random(2) <= 4 then
                    local entities = surface.find_entities({{x,y}, {x+1,y+1}})
                    local remove = true
                    for _, entity in pairs(entities) do
                      if entity and entity.valid and entity.type ~= "character" and entity.health then
                        entity.damage(150, "neutral", "explosion")
                        remove = false
                      end
                    end
                    if remove then
                      local tile = surface.get_tile(x,y)
                      table.insert(set_tiles, {name = name_space_tile, ghost_name=tile.name, position = {x,y}})
                    end
                  end
                end
              end
          end
        end
      end
      if next(set_tiles) then
        spaceship.check_message = {"space-exploration.spaceship-check-message-valid-but-disconnecting"}
        surface.print({"space-exploration.spaceship-warning-sections-disconnecting"})
        surface.set_tiles(set_tiles)
        for _, tile in pairs(set_tiles) do
          if Spaceship.names_spaceship_floors_map[tile.ghost_name] then
            surface.create_entity{name = "tile-ghost", inner_name = tile.ghost_name, force = spaceship.force_name, position=tile.position}
          end
        end
      end

      SpaceshipIntegrity.stop_integrity_check(spaceship)

      if reset then
        SpaceshipIntegrity.start_integrity_check(spaceship)
        return
      else
        Spaceship.get_compute_launch_energy(spaceship)
        return
      end
    end

  end

  if changed then
    spaceship.pending_tiles = next_pending_tiles
  else
    spaceship.integrity_valid = false
    spaceship.check_message = {"space-exploration.spaceship-check-message-did-not-complete"}
    return SpaceshipIntegrity.stop_integrity_check(spaceship)
  end
end


function SpaceshipIntegrity.clean_integrity_affecting_tables()
  for ia_idx, ia_name in pairs(SpaceshipIntegrity.integrity_affecting_names) do
    if ia_name.mod ~= nil and not script.active_mods[ia_name.mod] then
      SpaceshipIntegrity.integrity_affecting_names[ia_idx] = nil
    end
  end
  for ia_idx, ia_type in pairs(SpaceshipIntegrity.integrity_affecting_types) do
    if ia_type.mod ~= nil and not script.active_mods[ia_type.mod] then
      SpaceshipIntegrity.integrity_affecting_types[ia_idx] = nil
    end
  end
end

--- When an equipment grid is changed, we have to recalculate integrity costs
---@param event EventData.on_player_placed_equipment|EventData.on_player_removed_equipment Event data
function SpaceshipIntegrity.on_equipment_grid_changed(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local spaceship = Spaceship.from_own_surface_index(player.surface.index)
  if spaceship then
    SpaceshipIntegrity.start_integrity_check(spaceship)
  end
end
Event.addListener(defines.events.on_player_placed_equipment, SpaceshipIntegrity.on_equipment_grid_changed)
Event.addListener(defines.events.on_player_removed_equipment, SpaceshipIntegrity.on_equipment_grid_changed)

---@param event EventData.on_player_built_tile|EventData.on_robot_built_tile|EventData.on_robot_mined_tile|EventData.on_player_mined_tile
function SpaceshipIntegrity.on_tile_changed(event)
  local surface = game.get_surface(event.surface_index)
  if surface and string.find(surface.name, "spaceship-") then
    local spaceship = Spaceship.from_own_surface_index(surface.index)
    if spaceship and not spaceship.is_cloning then
      SpaceshipIntegrity.check_integrity_stress(spaceship)
      spaceship.check_stage = nil -- reset
      SpaceshipIntegrity.start_integrity_check(spaceship)
    end
  else
    -- Fix remove tiles during check exploit
    if event.tiles then
      local zone = Zone.from_surface_index(event.surface_index)
      if zone then
        for _, old_tile_and_position in pairs(event.tiles) do
          if Spaceship.names_spaceship_floors_map[old_tile_and_position.old_tile.name] then
            -- find spaceships on this surface.
            for _, spaceship in pairs(storage.spaceships) do
              if spaceship.zone_index == zone.index and spaceship.is_doing_check then
                if spaceship.check_tiles and
                  spaceship.check_tiles[old_tile_and_position.position.x] and
                  spaceship.check_tiles[old_tile_and_position.position.x][old_tile_and_position.position.y] then
                    spaceship.integrity_valid = false
                    SpaceshipIntegrity.stop_integrity_check(spaceship)
                    SpaceshipIntegrity.start_integrity_check(spaceship)
                end
              end
            end
          end
        end
      end
    end
  end
end
Event.addListener(defines.events.on_player_built_tile, SpaceshipIntegrity.on_tile_changed)
Event.addListener(defines.events.on_robot_built_tile, SpaceshipIntegrity.on_tile_changed)
Event.addListener(defines.events.on_robot_mined_tile, SpaceshipIntegrity.on_tile_changed)
Event.addListener(defines.events.on_player_mined_tile, SpaceshipIntegrity.on_tile_changed)

return SpaceshipIntegrity
