local Capsule = {}

Capsule.name_space_capsule = mod_prefix.."space-capsule"
Capsule.name_space_capsule_container = mod_prefix.."space-capsule"
Capsule.name_space_capsule_vehicle = mod_prefix.."space-capsule-_-vehicle"
Capsule.name_space_capsule_scorched = mod_prefix.."space-capsule-scorched"
Capsule.name_space_capsule_scorched_container = mod_prefix.."space-capsule-scorched"
Capsule.name_space_capsule_scorched_vehicle = mod_prefix.."space-capsule-scorched-_-vehicle"
Capsule.name_space_capsule_vehicle_shadow = mod_prefix.."space-capsule-_-vehicle-shadow"
Capsule.name_space_capsule_vehicle_light = mod_prefix.."light-space-capsule"
Capsule.name_space_capsule_vehicle_light_launch = mod_prefix.."light-space-capsule-launch"
Capsule.name_capsule_targeter = mod_prefix .. "space-capsule-targeter"
Capsule.name_tech_capsule_navigation = mod_prefix .. "space-capsule-navigation"
Capsule.hop_fuel_cost_energy_coefficient = 50000
Capsule.max_stacks = 20
Capsule.max_stacks_infinite = 10000
Capsule.stack_fuel_multiplier = 0.1
Capsule.base_weight = 10
Capsule.time_launch_capsule_flight = 5 * 60 -- Note: animation time is before this
Capsule.time_landing_capsule_touchdown = 6 * 60
Capsule.time_landing_capsule_end = 6 * 60 + 10 -- estimate of the end time of the audio
Capsule.landing_start_altitude = 128
Capsule.animation_speed = 1/3
Capsule.animation_move_frame = 19
Capsule.emergency_burn_player_inventory_loss_multiplier = 0.5

---Returns if a player can launch a capsule.
---@param force_name string The name of the force trying to launch the capsule
function Capsule.can_launch_capsule(force_name)

  ---Requires remote view to be unlocked for the force to launch the capsule
  -- return RemoteView.is_unlocked_force(force_name)

  ---Requires the space capsule tech to be unlocked for the force to launch the capsule
  return game.forces[force_name].technologies[Capsule.name_tech_capsule_navigation].researched

  ---Requires a cargo rocket to be launched for the force to launch the capsule
  -- local forcedata = storage.forces[force_name]
  -- if not forcedata then return false end
  -- return (forcedata.cargo_rockets_launched or 0) == 0
end

---Returns a `CapsuleInfo` table based on the given space capsule entity. Does _not_ itself create
---any entities.
---@param vehicle LuaEntity Can be a normal or scorched space capsule vehicle
---@param container? LuaEntity Can be a normal or scorched space capsule container
---@return CapsuleInfo? capsule_info
function Capsule.make_capsule_info(vehicle, container)
  local name = vehicle.name

  if name ~= Capsule.name_space_capsule_vehicle
  and name ~= Capsule.name_space_capsule_scorched_vehicle then
    return
  end

  return {
    type = name == Capsule.name_space_capsule_vehicle and "space-capsule" or "space-capsule-scorched",
    vehicle = vehicle,
    container = container,
    unit_number = vehicle.unit_number,
    force_name = vehicle.force.name,
    current_zone = Zone.from_surface(vehicle.surface),
    start_position = vehicle.position,
    jump_zone = nil,
    shadow = nil,
    light = nil,
    tick_task = nil
  }
end

---Gets the `CapsuleInfo` table for a given `unit_number`.
---@param unit_number uint Unit number of space capsule vehicle
---@return CapsuleInfo? space_capsule
function Capsule.from_unit_number(unit_number)
  if not unit_number then Log.debug("Capsule.from_unit_number: invalid unit_number: nil") return end
  if storage.space_capsules[unit_number] then
    return storage.space_capsules[unit_number]
  else
    Log.debug("Capsule.from_unit_number: invalid unit_number: " .. unit_number)
  end
end

---Gets the `CapsuleInfo` for a given space capsule vehicle.
---@param entity LuaEntity Space capsule vehicle
---@return CapsuleInfo?
function Capsule.from_vehicle(entity)
  if not(entity and entity.valid) then
    Log.debug("Capsule.from_entity: nil or invalid entity")
    return
  end
  return Capsule.from_unit_number(entity.unit_number)
end

---Gets the `CapsuleInfo` for a given space capsule container.
---@param entity LuaEntity Space capsule container, _must_ be valid
---@return CapsuleInfo?
function Capsule.from_container(entity)
  local vehicle = entity.surface.find_entity(Capsule.name_space_capsule_vehicle, entity.position)
  if vehicle then return Capsule.from_unit_number(vehicle.unit_number) end
end

---Handles creation of a space capsule container by creating an appropriately typed vehicle as well
---as making shadow and light entities. Creates a `CapsuleInfo` table and saves it to
---`storage.space_capsules`.
---@param event EntityCreationEvent|EventData.on_entity_cloned Event data
function Capsule.on_entity_created(event)
  ---@type LuaEntity
  local entity = event.entity or event.destination
  if not entity.valid then return end

  local entity_name = entity.name

  if not (entity_name == Capsule.name_space_capsule
    or entity_name == Capsule.name_space_capsule_scorched) then
    return
  end

  -- Abort placement if force has yet to launch a satellite
  --if not RemoteView.is_unlocked_force(entity.force.name) then
  --  return cancel_entity_creation(entity, event.player_index,
  --    {"space-exploration.generic-requires-satellite"}, event)
  --end

  -- Abort placement if attempted placement it not within an SE zone
  local zone = Zone.from_surface(entity.surface)
  if cancel_creation_when_invalid(zone, entity, event) then return end
  ---@cast zone -?

  local container = entity
  local vehicle
  local vehicle_name = (container.name == Capsule.name_space_capsule_container)
    and Capsule.name_space_capsule_vehicle or Capsule.name_space_capsule_scorched_vehicle

  -- If this was a cloning event, try to find the associated vehicle that was probably also cloned
  if event.name == defines.events.on_entity_cloned then
    vehicle = util.find_entity_or_revive_ghost(
      entity.surface,
      vehicle_name,
      entity.position
    )
  end

  if not vehicle then
    vehicle = entity.surface.create_entity{
      name = vehicle_name,
      position = container.position,
      force = container.force,
      -- quality = container.quality, -- would hide it from the current find_entity code
    }
    ---@cast vehicle -?
    vehicle.orientation = 0
    vehicle.destructible = false
  end

  -- Ensure `storage.space_capsules` can be cleaned up if vehicle got destroyed without events
  if container.name == Capsule.name_space_capsule_container then
    script.register_on_object_destroyed(vehicle)
  end

  -- Create the associated `CapsuleInfo` data structure
  local space_capsule = Capsule.make_capsule_info(vehicle, container)

  -- Create the capsule's light (if not scorched) and shadow
  Capsule.get_make_capsule_shadow(space_capsule)
  if vehicle_name == Capsule.name_space_capsule_vehicle then
    Capsule.get_make_capsule_light(space_capsule)
  end

  -- Set a default jump zone for the capsule, if possible
  local jump_zones = Zone.get_space_jumps(zone, entity.force, 4, true)
  space_capsule.jump_zone = next(jump_zones) and jump_zones[1] or nil

  storage.space_capsules[space_capsule.unit_number] = space_capsule
end
Event.addListener(defines.events.on_entity_cloned, Capsule.on_entity_created)
Event.addOnEntityCreatedListeners(Capsule.on_entity_created)

---Handles removal of space capsule entities by deleting any associated lights or shadows. Deletes
---associated `CapsuleInfo` object from `storage` table.
---@param event EntityRemovalEvent Event data
function Capsule.on_entity_removed(event)
  local entity = event.entity
  if not entity.valid then return end

  local entity_name = entity.name

  -- Vehicle, search for `CapsuleInfo` table
  if entity_name == Capsule.name_space_capsule_vehicle then
    local space_capsule = Capsule.from_unit_number(entity.unit_number)
    if not space_capsule then return end

    if space_capsule.light.valid then space_capsule.light.destroy() end
    if space_capsule.shadow.valid then space_capsule.shadow.destroy() end

    -- In case vehicle was destroyed directly, make sure container entity is destroyed too
    if space_capsule.container and space_capsule.container.valid then space_capsule.container.destroy() end

    storage.space_capsules[entity.unit_number] = nil
  elseif entity_name == Capsule.name_space_capsule_scorched_vehicle then
    local shadow = entity.surface.find_entity(Capsule.name_space_capsule_vehicle_shadow, entity.position)
    if shadow then shadow.destroy() end
  end

  -- Container, search for the associated vehicle and destroy it
  if entity_name == Capsule.name_space_capsule_container then
    local entity_position = entity.position
    local vehicle = entity.surface.find_entity(Capsule.name_space_capsule_vehicle, entity_position)
    if vehicle then
      vehicle.destroy({raise_destroy=true})  -- raise event to trigger above
    else
      local light = entity.surface.find_entity(Capsule.name_space_capsule_vehicle_light, entity_position)
      if light then light.destroy() end
      local shadow = entity.surface.find_entity(Capsule.name_space_capsule_vehicle_shadow, entity.position)
      if shadow then shadow.destroy() end
    end
  elseif entity_name == Capsule.name_space_capsule_scorched_container then
    local vehicle = entity.surface.find_entity(Capsule.name_space_capsule_scorched_vehicle, entity.position)
    if vehicle then
      vehicle.destroy({raise_destroy=true}) -- raise event to trigger above
    else
      local shadow = entity.surface.find_entity(Capsule.name_space_capsule_vehicle_shadow, entity.position)
      if shadow then shadow.destroy() end
    end
  end
end
Event.addOnEntityRemovedListeners(Capsule.on_entity_removed)

---Handles the destruction of space capsule vehicles, in case it was done _without_ raising events.
---Searches for the `CapsuleInfo` table the vehicle belonged to and cleans up leftover entities
---before deleting that table from `storage.space_capsules`.
---@param event EventData.on_object_destroyed Event data
function Capsule.on_object_destroyed(event)
  if not storage.space_capsules[event.useful_id] then return end
  if event.type ~= defines.target_type.entity then return end

  local capsule = storage.space_capsules[event.useful_id]

  -- Destroy container
  if capsule.container and capsule.container.valid then capsule.container.destroy() end

  -- Remove lights and shadows
  if capsule.light.valid then capsule.light.destroy() end
  if capsule.shadow.valid then capsule.shadow.destroy() end

  --Dereference from `storage.space_capsules`
  storage.space_capsules[event.useful_id] = nil
end
Event.addListener(defines.events.on_object_destroyed, Capsule.on_object_destroyed)

---@return integer
function Capsule.get_rocket_fuel_stack_size()
  if not Capsule.rocket_fuel_stack_size then
    Capsule.rocket_fuel_stack_size = prototypes.item["rocket-fuel"].stack_size
  end
  return Capsule.rocket_fuel_stack_size
end

---@return integer
function Capsule.get_rocket_fuel_fuel_value()
  if not Capsule.rocket_fuel_fuel_value then
    Capsule.rocket_fuel_fuel_value = prototypes.item["rocket-fuel"].fuel_value
  end
  return Capsule.rocket_fuel_fuel_value
end

---Calculates and returns the total fuel and cargo rocket sections costs of a capsule launch.
---@param current_zone AnyZoneType Zone capsule would be launching from
---@param jump_zone JumpZoneInfo Jump zone the capsule would be heading to
---@param stacks uint Number of item stacks in capsule and passenger inventories
---@return uint total_fuel_cost
---@return uint sections_cost
function Capsule.get_launch_costs(current_zone, jump_zone, stacks)
  local fuel_cost = 0
  local sections_cost = 0
  local interstellar_distance = Zone.get_stellar_distance(current_zone, jump_zone.zone) or 0

  local effective_weight = stacks + Capsule.base_weight
  if jump_zone.field == "homeworld-emergency" then
    fuel_cost = 0
    sections_cost = 0
  elseif jump_zone.field == "land" or jump_zone.field == "homeworld" then
    fuel_cost = Zone.get_launch_delta_v(current_zone) + Zone.get_travel_delta_v(current_zone, jump_zone.zone)
    sections_cost = 0
  elseif Zone.is_solid(current_zone) then
    ---@cast current_zone PlanetType|MoonType
    -- capsule should not have an easy time leaving planets or moons
    -- with this setting you can JUST about leave 10k radius planet. (13 sections, 269 fuel stacks 13+27 slots = full)
    local radius_multiplier = current_zone.radius / 10000
    fuel_cost = Zone.get_launch_delta_v(current_zone) + Zone.get_travel_delta_v(current_zone, jump_zone.zone)
    sections_cost = 4 + 5 * radius_multiplier + math.max(1, stacks) / (5 - 3 * radius_multiplier)
  elseif interstellar_distance > 0 then
    fuel_cost = Zone.get_launch_delta_v(current_zone) + 2 * Zone.get_travel_delta_v(current_zone, jump_zone.zone)
    sections_cost = 1 + math.max(1, stacks) / 5
  else
    fuel_cost = Zone.get_launch_delta_v(current_zone) + Zone.get_travel_delta_v(current_zone, jump_zone.zone)
    sections_cost = math.max(1, stacks) / 10
  end

  local total_fuel_cost = fuel_cost * effective_weight * Capsule.hop_fuel_cost_energy_coefficient

  -- compensate for stack size.
  local normal_stack_Size = 10
  total_fuel_cost = total_fuel_cost * Capsule.get_rocket_fuel_stack_size() / normal_stack_Size
  -- add 1 stack per required section
  total_fuel_cost = total_fuel_cost + sections_cost * Capsule.get_rocket_fuel_fuel_value() * Capsule.get_rocket_fuel_stack_size()
  total_fuel_cost = math.ceil(total_fuel_cost)
  sections_cost = math.ceil(sections_cost)
  return total_fuel_cost, sections_cost
end

---Calculates and returns the total fuel and cargo rocket sections costs of a capsule launch including excess items.
---@param current_zone AnyZoneType Zone capsule would be launching from
---@param jump_zone JumpZoneInfo Jump zone the capsule would be heading to
---@param stacks uint Number of item stacks in capsule and passenger inventories
---@param fuel_items uint Number of fuel items in capsule inventory
---@param sections uint Number of sections items in capsule inventory
---@return uint total_fuel_cost
---@return uint sections_cost
---@return uint cargo_stacks
---@return uint base_stacks
---@return uint excess_sections
function Capsule.get_launch_costs_adv(current_zone, jump_zone, stacks, fuel_items, sections)
  local base_stacks = stacks
  local max_stacks = Zone.is_solid(jump_zone.zone) and Capsule.max_stacks_infinite or Capsule.max_stacks -- todo: take quality bonus into account?
  local fuel_cost, sections_cost = Capsule.get_launch_costs(current_zone, jump_zone, math.min(max_stacks, stacks))
  local excess_sections = 0
  local excess_fuel_stacks = 0
  -- sections cost should not be increased by adding fuel, just do sections first
  local changed = true
  local limit = 0
  while changed do
    changed = false
    limit = limit + 1
    excess_sections = math.max(0, sections - sections_cost)
    if stacks < base_stacks + excess_sections then
      stacks = base_stacks + excess_sections
      changed = true
      fuel_cost, sections_cost = Capsule.get_launch_costs(current_zone, jump_zone, math.min(max_stacks, stacks))
    end
    if limit > 100 then
      changed = false
      Log.debug("Limit hit")
    end
  end
  excess_sections = math.max(0, sections - sections_cost)
  stacks = base_stacks + excess_sections
  local sections_base_stacks = stacks
  --[[
  changed = true
  limit = 0
  local required_fuel_items = 0
  local required_fuel_stacks = 0
  local total_fuel_stacks = 0
  while changed do
    changed = false
    limit = limit + 1
    required_fuel_items = math.ceil(fuel_cost/Capsule.get_rocket_fuel_fuel_value())
    required_fuel_stacks = math.ceil(required_fuel_items/Capsule.get_rocket_fuel_stack_size())
    total_fuel_stacks = math.ceil(fuel_items/Capsule.get_rocket_fuel_stack_size())
    excess_fuel_stacks = math.max(0, total_fuel_stacks - required_fuel_stacks)
    if stacks < sections_base_stacks + excess_fuel_stacks then
      stacks = sections_base_stacks + excess_fuel_stacks
      changed = true
      fuel_cost = Capsule.get_launch_costs(current_zone, jump_zone, math.min(max_stacks, stacks))
    end
    if limit > 100 then
      changed = false
      Log.debug("Limit hit")
    end
  end
  required_fuel_items = math.ceil(fuel_cost/Capsule.get_rocket_fuel_fuel_value())
  required_fuel_stacks = math.ceil(required_fuel_items/Capsule.get_rocket_fuel_stack_size())
  total_fuel_stacks = math.ceil(fuel_items/Capsule.get_rocket_fuel_stack_size())
  excess_fuel_stacks = math.max(0, total_fuel_stacks - required_fuel_stacks)
  stacks = sections_base_stacks + excess_fuel_stacks
  ]]

  return fuel_cost, sections_cost, stacks, base_stacks, excess_sections--, excess_fuel_stacks
end

---Gets an array of all _characters_ aboard a space capsule vehicle.
---@param vehicle LuaEntity Space capsule vehicle, _must_ be valid vehicle entity
---@return LuaEntity[] passengers Array of characters on board a space capsule
function Capsule.get_vehicle_passengers(vehicle)
  return {vehicle.get_driver(), vehicle.get_passenger()}
end

---Gets the inventory contents of a given space capsule, including those of its passengers. Returns
---the total number of item stacks as well the the capsule's LuaInventory.
---@param container LuaEntity Space capsule container, _must_ be valid
---@param passengers LuaEntity[] Array of characters on board space capsule, _must_ be valid
---@return uint stacks Number of stacks in capsule and passenger inventories
---@return LuaInventory capsule_inv Capsule inventory
function Capsule.get_inventory_stacks(container, passengers)
  local capsule_inv = container.get_inventory(defines.inventory.chest)
  --local stacks = #capsule_inv - capsule_inv.count_empty_stacks(true)
  local stacks = 0
  for i = 1, #capsule_inv do
    local stack = capsule_inv[i]
    if stack.valid_for_read then
      if stack.name ~= "rocket-fuel" and stack.name ~= "se-cargo-rocket-section" then
        stacks = stacks + 1
      end
    end
  end
  for _, passenger in pairs(passengers) do
    for _, inventory_type in pairs({defines.inventory.character_main, defines.inventory.character_trash}) do
      local inv = passenger.get_inventory(inventory_type)
      stacks = stacks + #inv - inv.count_empty_stacks(true)
    end
    if passenger.cursor_stack and passenger.cursor_stack.valid_for_read then
      stacks = stacks + 1
    end
  end
  return stacks, capsule_inv
end

---Evaluates rocket fuel contents of a given inventory and returns the the number of rocket fuel
---items, the per-unit fuel value, and the total fuel energy available
---@param inventory LuaInventory Space capsule vehicle inventory, _must_ be valid
---@return uint fuel_items Number of solid rocket fuel items in inventory
---@return float fuel_value Per-unit fuel value of a single rocket fuel item
---@return float fuel_energy Total energy value of solid rocket fuel on board
function Capsule.get_fuel_info(inventory)
  local fuel_items = inventory.get_item_count("rocket-fuel")
  local fuel_value = Capsule.get_rocket_fuel_fuel_value()
  local fuel_energy = fuel_items * fuel_value
  return fuel_items, fuel_value, fuel_energy
end

---Returns the number of cargo rocket sections inside a given space capsule inventory.
---@param inventory LuaInventory Space capsule container inventory, _must_ be valid
---@return uint item_count
function Capsule.get_section_info(inventory)
  return inventory.get_item_count(Launchpad.name_rocket_section)
end

---Validates and sets the target zone as the jump_zone of a given `CapsuleInfo` table. Returns true
---if successful.
---@param player LuaPlayer Player attempting to set target
---@param space_capsule CapsuleInfo Space capsule data
---@param target_zone? AnyZoneType Zone data
---@param coordinates? MapPosition Coordinates set by player, if any
---@param print_message? boolean Whether to print a message to console
---@return boolean is_successful
function Capsule.set_target(player, space_capsule, target_zone, coordinates, print_message)
  if not target_zone then
    space_capsule.jump_zone = nil
    return true
  end

  local force = game.forces[space_capsule.force_name]
  local allowed_jump_zones = Zone.get_space_jumps(space_capsule.current_zone, force, 4, true)
  for _, allowed_jump_zone in pairs(allowed_jump_zones) do
    if allowed_jump_zone.zone == target_zone then
      -- Check if target coordinates are out of planet/moon bounds, abort if true
      if coordinates and target_zone.radius and util.vector_length(coordinates) > target_zone.radius then
        if print_message then
          player.print({"space-exploration.target-out-of-bounds",
          "item/" .. Capsule.name_space_capsule,
            Zone.get_print_name(target_zone), coordinates.x, coordinates.y})
        end
        return false
      end

      -- Set capsule jump zone
      space_capsule.jump_zone = allowed_jump_zone

      -- Set capsule coordinates if not a homeworld emergency
      if allowed_jump_zone.field ~= "homeworld-emergency" then
        space_capsule.jump_zone.coordinates = coordinates
        if print_message then
          if coordinates then
            player.print({
              "space-exploration.target-set",
              "item/" .. Capsule.name_space_capsule,
              {"space-exploration.target-label-space-capsule"},
              Zone.get_print_name(target_zone),
              coordinates.x,
              coordinates.y
            })
          else
            player.print({
              "space-exploration.target-set-zone-only",
              "item/" .. Capsule.name_space_capsule,
              {"space-exploration.target-label-space-capsule"},
              Zone.get_print_name(target_zone)
            })
          end
        end
      elseif print_message then
        -- Emergency burn
        player.print({"space-exploration.space-capsule-target-homeworld-emergency",
          Zone.get_print_name(target_zone)})
      end
      return true
    end
  end

  if print_message then
    player.print({"space-exploration.space-capsule-invalid-jump-zone-set",
      Zone.get_print_name(target_zone)})
  end

  return false
end

---Launches a given space capsule
---@param space_capsule CapsuleInfo Space capsule to be launched
function Capsule.launch(space_capsule)
  local vehicle = space_capsule.vehicle
  if not (vehicle and vehicle.valid) then return end

  local container = space_capsule.container
  if not (container and container.valid) then return end

  local jump_zone = space_capsule.jump_zone
  if not (jump_zone and jump_zone.zone and jump_zone.field) then return end

  -- Don't allow launch if this vehicle is already in a launch (indicated by having a tick task)
  if space_capsule.tick_task then return end

  -- Make sure jump zone is still reachable, since a spaceship-type origin zone may have moved
  local is_reachable_jump_zone = false
  local jump_zones = Zone.get_space_jumps(space_capsule.current_zone,
    game.forces[space_capsule.force_name], 4, true)
  for _, allowed in pairs(jump_zones) do
    if jump_zone.zone == allowed.zone and jump_zone.field == allowed.field then
      is_reachable_jump_zone = true
      break
    end
  end
  if not is_reachable_jump_zone then
    local src = space_capsule.current_zone
    local dst = jump_zone.zone

    return {fail_message={"space-exploration.space-capsule-no-longer-reachable-jump-zone",
      Zone.get_print_name(src),
      Zone.get_print_name(dst) }}
  end

  -- Get capsule passengers; abort if there are none
  local passengers = Capsule.get_vehicle_passengers(vehicle)
  if not next(passengers) then return end

  -- Abort if attempting to launch from a surface that is not an SE zone
  local current_zone = Zone.from_surface(vehicle.surface)
  if not current_zone then -- Can't launch if surface is not an SE zone
    for _, passenger in pairs(passengers) do
      if passenger.player then
        passenger.player.print({"space-exploration.capsule_invalid_launch_location"})
      end
    end
    return {fail_message = {"space-exploration.capsule_invalid_launch_location"}}
  end

  -- validation
  ---@type AnyZoneType|StarType
  local target_zone = jump_zone.zone
  local force_name = vehicle.force.name
  local emergency_burn_flag = false

  -- Abort if cargo or passengers have banned items
  if next(storage.items_banned_from_transport) then -- If there's any banned item
    local banned_items_cargo = find_items_banned_from_transport(container.get_inventory(defines.inventory.chest))
    if next(banned_items_cargo) then
      return {fail_message = {"space-exploration.banned-items-in-capsule", serpent.line(banned_items_cargo)}}
    end

    for _, passenger in pairs(passengers) do
      local banned_items = find_items_banned_from_transport_in_character(passenger)
      if next(banned_items) then
        local name = passenger.player and passenger.player.name or "Character"
        return {fail_message = {"space-exploration.banned-items-in-character", name, serpent.line(banned_items)}}
      end
    end
  end

  if jump_zone.field == "homeworld-emergency" then
    emergency_burn_flag = true
  else
    -- Abort if force has yet to launch any cargo rockets (and launch is not an emergency burn)
    if not Capsule.can_launch_capsule(force_name) then return {fail_message={"space-exploration.space-capsule-must-research-navigation"}} end
    --{fail_message={"space-exploration.space-capsule-must-launch-cargo-rockets"}}

    -- Abort if any passenger is crafting
    for _, passenger in pairs(passengers) do
      if passenger.crafting_queue_size  > 0 then
        for _, passenger in pairs(passengers) do
          if passenger.player then
            passenger.player.print({"space-exploration.space-capsule-stop-launch-crafting"})
          end
        end
        return {fail_message = {"space-exploration.space-capsule-stop-launch-crafting"}}
      end
    end

    local stacks, capsule_inv = Capsule.get_inventory_stacks(container, passengers)
    local base_stacks = stacks
    local max_stacks = Zone.is_solid(target_zone) and Capsule.max_stacks_infinite or #container.get_inventory(defines.inventory.chest)

    local sections = Capsule.get_section_info(capsule_inv)
    local fuel_items, fuel_value, fuel_energy = Capsule.get_fuel_info(capsule_inv)
    -- Get launch costs, abort if not met
    local fuel_cost, sections_cost
    fuel_cost, sections_cost, stacks = Capsule.get_launch_costs_adv(current_zone, jump_zone, stacks, fuel_items, sections)

    -- Abort if item stacks on board exceed maximum allowed
    if stacks > max_stacks then
      for _, passenger in pairs(passengers) do
        if passenger.player then
          passenger.player.print({"space-exploration.space-capsule-stop-launch-stacks", stacks, max_stacks})
        end
      end
      return {fail_message = {"space-exploration.space-capsule-stop-launch-stacks", stacks, max_stacks}}
    end

    if sections < sections_cost then
      for _, passenger in pairs(passengers) do
        if passenger.player then
          passenger.player.print({"space-exploration.space-capsule-stop-launch-sections", sections, sections_cost})
        end
      end
      return {fail_message = {"space-exploration.space-capsule-stop-launch-sections", sections, sections_cost}}
    end
    if fuel_energy < fuel_cost then
      for _, passenger in pairs(passengers) do
        if passenger.player then
          passenger.player.print({"space-exploration.space-capsule-stop-launch-fuel", fuel_items, math.ceil(fuel_cost / fuel_value)})
        end
      end
      return {fail_message = {"space-exploration.space-capsule-stop-launch-fuel", fuel_items, math.ceil(fuel_cost / fuel_value)}}
    end

    -- Checks passed; consume sections and fuel from vehicle inventory
    if sections_cost > 0 then
      capsule_inv.remove({name=Launchpad.name_rocket_section, count=sections_cost})
    end
    if fuel_cost > 0 then
      capsule_inv.remove({name="rocket-fuel", count=math.ceil(fuel_cost / fuel_value)})
    end

    for _, passenger in pairs(passengers) do
      Spectator.cancel_crafting(passenger)
    end
  end

  -- Create a tick task for the launch
  local tick_task = new_tick_task("capsule-journey") --[[@as CapsuleTickTask]]
  tick_task.space_capsule = space_capsule
  tick_task.origin = current_zone
  tick_task.start_position = vehicle.position
  tick_task.phase = 1
  tick_task.launch_progress = 1
  tick_task.landing_progress = 1
  tick_task.container_quality = space_capsule.container.quality

  -- Transfer container contents to a script inventory and save it in the tick task
  tick_task.lua_inventory = game.create_inventory(#(space_capsule.container.get_inventory(defines.inventory.chest)))
  util.swap_inventories(tick_task.lua_inventory, space_capsule.container.get_inventory(defines.inventory.chest))
  space_capsule.container.destroy() -- don't fire events

  space_capsule.tick_task = tick_task

  -- Make sure the capsule has a valid shadow
  Capsule.get_make_capsule_shadow(space_capsule)

  -- Recreate the light, so that a launch version of the light is used
  if space_capsule.light.valid then space_capsule.light.destroy() end
  Capsule.get_make_capsule_light(space_capsule)

  -- Create a SpectatorInfo object for each passenger
  tick_task.seated_passengers = {}
  for _, passenger in pairs(passengers) do
    local spectator = Spectator.start(passenger, tick_task)
    if spectator then
      table.insert(tick_task.seated_passengers, spectator)
    end
  end

  local navigation_error = false
  local is_interstellar = Zone.is_interstellar(current_zone, target_zone)
  if jump_zone.undiscovered or is_interstellar then
    navigation_error = true

    ---@param zone AnyZoneType|StarType
    local function random_in_star(zone)
      local star = Zone.find_nearest_star(Zone.get_stellar_position(zone))
      local zones = {star.orbit}
      for _, child in pairs(star.children) do
        table.insert(zones, child)
        if child.orbit then table.insert(zones, child.orbit) end
        if child.children and Zone.is_visible_to_force(child, force_name) then
            for _, child2 in pairs(child.children) do
              table.insert(zones, child2)
              table.insert(zones, child2.orbit)
            end
        end
      end
      target_zone = zones[math.random(#zones)]
    end
    local r = math.random()
    if r < 0.001 then -- any random zone.
      target_zone = storage.zone_index[math.random(#storage.zone_index)]
      if target_zone.type == "star" then
        ---@cast target_zone StarType
        target_zone = target_zone.orbit
      end
    elseif r < 0.1 then
      random_in_star(target_zone)
      if target_zone.type == "orbit" and (not target_zone.parent.type == "star") and math.random() < 0.5 then
        ---@cast target_zone OrbitType
        target_zone = target_zone.parent
      end
    elseif r < 0.5 then
      if target_zone.planet_gravity_well then -- random in planet
        local planet = Zone.get_planet_from_child(target_zone)
        if Zone.is_visible_to_force(planet, force_name) then
          local r2 = math.random()
          if r2 < 0.1 then
            target_zone = math.random() < 0.8 and planet or planet.orbit
          else
            local moon = planet.children[math.random(#planet.children)]
            target_zone = math.random() < 0.8 and moon or moon.orbit
          end
        else
          target_zone = math.random() < 0.8 and planet or planet.orbit
        end
      else
        random_in_star(target_zone)
      end
    else
      -- should be on course... but can't go to a moon of an undiscovered planet.
      if target_zone.type == "orbit" and target_zone.parent.type == "moon" and not Zone.is_visible_to_force(target_zone.parent.parent, force_name) then
        ---@cast target_zone OrbitType
        target_zone = math.random() < 0.8 and target_zone.parent.parent or target_zone.parent.parent.orbit
      else
        navigation_error = false
      end
    end
  end
  Zone.get_make_surface(target_zone)

  local destination_position
  local coordinates = space_capsule.jump_zone.coordinates
  if coordinates then
    local surface = Zone.get_make_surface(target_zone)
    if surface.find_entity(Landingpad.name_rocket_landing_pad, coordinates) then
      destination_position = coordinates
    else
      local displacement = math.random() ^ 3 * 256
      local angle = math.random() * 2 * math.pi
      destination_position = {
        x=coordinates.x + (displacement * math.cos(angle)),
        y=coordinates.y + (displacement * math.sin(angle))
      }
      if target_zone.radius and util.vector_length(destination_position) > target_zone.radius then
        destination_position = util.vector_set_length(destination_position, target_zone.radius)
      end
    end
    destination_position = surface.find_non_colliding_position(Capsule.name_space_capsule_container, destination_position, 32, 1)
  end

  if not destination_position then
    local zone_assets = Zone.get_force_assets(vehicle.force.name, target_zone.index)

    local landing_pads = {}
    if zone_assets.rocket_landing_pad_names then
      for name, pads in pairs(zone_assets.rocket_landing_pad_names) do
        for _, pad in pairs(pads) do
          table.insert(landing_pads, pad)
        end
      end
    end
    if next(landing_pads) then
      local pad = landing_pads[math.random(#landing_pads)]
      if pad and pad.container and pad.container.valid then
        local surface = Zone.get_make_surface(target_zone)
        destination_position = surface.find_non_colliding_position(Capsule.name_space_capsule_container, pad.container.position, 32, 1) or pad.container.position
      end
    end
  end
  if not destination_position then
    destination_position = Zone.find_zone_landing_position(target_zone)
  end

  tick_task.destination_zone = target_zone
  tick_task.destination_position = destination_position
  tick_task.emergency_burn = emergency_burn_flag
  tick_task.navigation_error = navigation_error
end

---Phase 1: Close capsule and launch.
---@param tick_task CapsuleTickTask
function Capsule.tick_journey_ascend(tick_task)
  local space_capsule = tick_task.space_capsule
  local animation_frames = 24
  local animation_frame = math.max(math.min(math.floor(tick_task.launch_progress * Capsule.animation_speed), animation_frames), 1)

  -- the original passengers should be in seats.
  -- if there are new passengers they got in during the animation
  -- remove new passengers from the vehicle
  space_capsule.vehicle.set_driver(nil)
  space_capsule.vehicle.set_passenger(nil)

  if animation_frame == 1 and not tick_task.sounds_frame_1 then
    tick_task.sounds_frame_1 = true
    tick_task.rocket_sound = space_capsule.vehicle.surface.create_entity{
      name=mod_prefix.."sound-continous-silo-rocket", position=space_capsule.vehicle.position, target=space_capsule.vehicle, speed=0}
    space_capsule.vehicle.surface.create_entity{
      name=mod_prefix.."sound-silo-clamps-on", position=space_capsule.vehicle.position, target=space_capsule.vehicle, speed=0}
    space_capsule.vehicle.surface.create_entity{
      name=mod_prefix.."sound-machine-close", position=space_capsule.vehicle.position, target=space_capsule.vehicle, speed=0}
  end

  if animation_frame == 19 and not tick_task.sounds_frame_19 then
    tick_task.sounds_frame_19 = true
    space_capsule.vehicle.surface.create_entity{
      name=mod_prefix.."sound-train-breaks", position=space_capsule.vehicle.position, target=space_capsule.vehicle, speed=0}
  end

  local move_progress = math.max(0, tick_task.launch_progress - (Capsule.animation_move_frame / Capsule.animation_speed))
  local move_y = math.max(0, move_progress) ^ 1.5 / 100
  local position = {
    x = tick_task.start_position.x,
    y = tick_task.start_position.y - move_y
  }

  if space_capsule.vehicle.valid then
    space_capsule.vehicle.teleport(position)
    space_capsule.vehicle.orientation = (animation_frame - 1) / animation_frames
  end
  if space_capsule.light.valid then
    space_capsule.light.teleport({x=position.x, y=position.y + 1})
  end
  if space_capsule.shadow.valid then
    space_capsule.shadow.graphics_variation = animation_frame
    space_capsule.shadow.teleport({x=tick_task.start_position.x + move_y, y=tick_task.start_position.y})
  end

  if tick_task.rocket_sound and tick_task.rocket_sound.valid then
    tick_task.rocket_sound.teleport(position)
  end

  Capsule.track_seats(space_capsule)
end

---Phase 2: Transition capsule from launching to landing
---@param tick_task CapsuleTickTask Capsule tick task data
function Capsule.tick_journey_transition(tick_task)
  local launch_capsule = tick_task.space_capsule
  local target_surface = Zone.get_make_surface(tick_task.destination_zone)

  if tick_task.rocket_sound and tick_task.rocket_sound.valid then tick_task.rocket_sound.destroy() end

  -- Find a safe position to land and force generate chunks if needed
  local safe_pos = target_surface.find_non_colliding_position(Capsule.name_space_capsule_container, tick_task.destination_position, 32, 1)
  safe_pos = safe_pos or tick_task.destination_position
  tick_task.destination_position = safe_pos
  target_surface.request_to_generate_chunks(safe_pos, 1)
  target_surface.force_generate_chunk_requests()
  launch_capsule.vehicle.force.chart(target_surface, {{safe_pos.x-32, safe_pos.y-32}, {safe_pos.x+32, safe_pos.y+32}})

  -- Calculate position that capsule should start landing from
  local position = {x=safe_pos.x, y=safe_pos.y - Launchpad.landing_start_altitude}

  -- Destroy lights and shadows, since they cannot be teleported across surfaces
  if launch_capsule.light.valid then launch_capsule.light.destroy() end
  if launch_capsule.shadow.valid then launch_capsule.shadow.destroy() end

  ---@type CapsuleInfo
  local landing_capsule

  if not tick_task.emergency_burn then
    -- Capsule only needs to be teleported to the `target_surface` if not in emergency burn
    if launch_capsule.vehicle.valid then
      launch_capsule.vehicle.teleport(position, target_surface)
      landing_capsule = launch_capsule
    end

    -- Remake capsule light and shadow
    Capsule.get_make_capsule_light(landing_capsule)
    Capsule.get_make_capsule_shadow(landing_capsule)
  else
    -- Damage character inventories now, before teleport
    local inventories = {} -- don't damage items in capsule cargo
    for _, seated_passenger in pairs(tick_task.seated_passengers) do
      if seated_passenger.character and seated_passenger.character.valid then
        for _, inventory_type in pairs({defines.inventory.character_main, defines.inventory.character_trash}) do
          table.insert(inventories, seated_passenger.character.get_inventory(inventory_type))
        end
      end
    end
    for _, inv in pairs(inventories) do
      local contents = inv.get_contents()
      for _, item in pairs(contents) do
        local item_type = prototypes.item[item.name]
        if item_type and item.count > 1 and item_type.stack_size > 1 then
          local lost_items = math.floor(item.count * Capsule.emergency_burn_player_inventory_loss_multiplier)
          if lost_items > 0 then
            inv.remove({name=item.name, count=lost_items, quality=item.quality})
          end
        end
      end
    end

    -- Create a new vehicle (scorched type)
    local scorched_vehicle = target_surface.create_entity{
      name=Capsule.name_space_capsule_scorched_vehicle,
      position=position,
      force=launch_capsule.vehicle.force,
      raise_built=true
    }
    --**FIXME** need nil check here with raise_built = true
    scorched_vehicle.destructible = false

    -- Make a new CapsuleInfo object for the scorched vehicle
    landing_capsule = Capsule.make_capsule_info(scorched_vehicle)
    landing_capsule.tick_task = tick_task

    -- Create a shadow
    Capsule.get_make_capsule_shadow(landing_capsule)
    landing_capsule.shadow.graphics_variation = 1

    -- Destroy the launch capsule; note that this will trigger destruction of its light and shadow
    launch_capsule.vehicle.destroy{raise_destroy=true}
  end

  tick_task.rocket_sound = landing_capsule.vehicle.surface.create_entity{
    name=mod_prefix.."sound-continous-space-capsule-land", position=landing_capsule.vehicle.position, target=landing_capsule.vehicle, speed=0}

  -- Move landing capsule shadow to appropriate starting position
  landing_capsule.shadow.teleport({safe_pos.x + Launchpad.landing_start_altitude, safe_pos.y})

  -- Move seated passengers along with the capsule
  Capsule.track_seats(landing_capsule)
  for _, seated_passenger in pairs(tick_task.seated_passengers) do
    if seated_passenger.player and tick_task.navigation_error then
      seated_passenger.player.print({"space-exploration.space-capsule-navigation-error"})
    end
  end

  -- Trigger zone discovery if appropriate
  if landing_capsule.jump_zone and landing_capsule.jump_zone.undiscovered then
    Zone.discover(landing_capsule.force_name, tick_task.destination_zone)
  end

  tick_task.space_capsule = landing_capsule
end

---Phase 3: Landing and opening
---@param tick_task CapsuleTickTask
function Capsule.tick_journey_descend(tick_task)
  local space_capsule = tick_task.space_capsule
  local time_remaining = math.max(1, Capsule.time_landing_capsule_touchdown - tick_task.landing_progress)
  local capsule_target_pos = tick_task.destination_position

  local travel = Util.vector_multiply(Util.vectors_delta(space_capsule.vehicle.position, capsule_target_pos), math.min(0.9, 2 / time_remaining))
  local animation_speed = 1/3
  local animation_frames = 24
  local animation_frame = math.max(math.min(math.floor(time_remaining * animation_speed), animation_frames), 1)
  local position = Util.vectors_add(space_capsule.vehicle.position, travel)

  if space_capsule.vehicle.valid then
    space_capsule.vehicle.teleport(position)
    space_capsule.vehicle.orientation = (animation_frame - 1) / animation_frames
  end

  if space_capsule.light and space_capsule.light.valid then space_capsule.light.teleport(position) end

  if space_capsule.shadow.valid then
    local travel_shadow = Util.vector_multiply(Util.vectors_delta(space_capsule.shadow.position, capsule_target_pos), math.min(0.9, 2 / time_remaining))
    space_capsule.shadow.teleport(Util.vectors_add(space_capsule.shadow.position, travel_shadow))
    space_capsule.shadow.graphics_variation = animation_frame
  end

  if tick_task.rocket_sound and tick_task.rocket_sound.valid then
    tick_task.rocket_sound.teleport(position)
  end

  Capsule.track_seats(space_capsule)
end

---Phase 4: Landing shutdown
---@param tick_task CapsuleTickTask
function Capsule.tick_journey_land(tick_task)
  local space_capsule = tick_task.space_capsule

  -- Force move vehicle to it's expected position (to deal with occasional imprecision)
  space_capsule.vehicle.teleport(tick_task.destination_position)

  if space_capsule.shadow.valid then
    space_capsule.shadow.teleport(tick_task.destination_position)
  end

  if space_capsule.light and space_capsule.light.valid then
    space_capsule.light.destroy()
    if space_capsule.vehicle.name ~= Capsule.name_space_capsule_scorched_vehicle then
      Capsule.get_make_capsule_light(space_capsule)
    end
  end

  -- Landing complete
  space_capsule.start_position = space_capsule.vehicle.position
  space_capsule.current_zone = tick_task.destination_zone

  local jump_zones = Zone.get_space_jumps(space_capsule.current_zone, space_capsule.vehicle.force, 4, true)
  space_capsule.jump_zone = next(jump_zones) and jump_zones[1] or nil
  space_capsule.tick_task = nil

  -- Unseat any passengers, put in the real vehicle
  for _, seated_passenger in pairs(tick_task.seated_passengers) do
    Spectator.stop(seated_passenger)

    if seated_passenger.character.valid then
      if seated_passenger.player and seated_passenger.player.valid then
        local playerdata = get_make_playerdata(seated_passenger.player)
        playerdata.zero_velocity = true
        seated_passenger.player.print({"space-exploration.respawn-if-stranded"})
      end
      if not space_capsule.vehicle.get_driver() then
        space_capsule.vehicle.set_driver(seated_passenger.character)
      elseif not space_capsule.vehicle.get_passenger() then
        space_capsule.vehicle.set_passenger(seated_passenger.character)
      end
    end
  end
  tick_task.seated_passengers = nil

  -- Create a capsule container and restore the capsule's inventory
  space_capsule.container = space_capsule.vehicle.surface.create_entity{
    name = (space_capsule.vehicle.name == Capsule.name_space_capsule_scorched_vehicle)
      and Capsule.name_space_capsule_scorched_container or Capsule.name_space_capsule_container,
    position = space_capsule.vehicle.position,
    force = space_capsule.vehicle.force,
    preserve_ghosts_and_corpses=true,
    quality = (tick_task.container_quality and tick_task.container_quality.valid) and tick_task.container_quality or nil,
  }
  util.swap_inventories(tick_task.lua_inventory, space_capsule.container.get_inventory(defines.inventory.chest))
  tick_task.lua_inventory.destroy()
  tick_task.lua_inventory = nil
end

---Updates the launch/landing of a space capsule. The tick task has five phases:
---1: Capsule ascent
---2: Surface transition
---3: Capsule descent
---4: Complete capsule landing
---5: Waiting to destroy landing sound
---@param tick_task CapsuleTickTask Tick task data
function Capsule.tick_journey(tick_task)
  local space_capsule = tick_task.space_capsule

  -- If the vehicle was destroyed without raising events, clean up associated entities, release
  -- seated passengers and mark the tick task as invalid
  if not space_capsule.vehicle.valid then
    if space_capsule.light and space_capsule.light.valid == true then space_capsule.light.destroy() end
    if space_capsule.shadow and space_capsule.shadow.valid == true then space_capsule.shadow.destroy() end

    if tick_task.phase <= 4 then -- Passengers get released during phase 4, no more passengers after that.
      for _, seated_passenger in pairs(tick_task.seated_passengers) do
        Spectator.stop(seated_passenger)
      end
    end

    storage.space_capsules[space_capsule.unit_number] = nil
    if tick_task.lua_inventory and tick_task.lua_inventory.valid then tick_task.lua_inventory.destroy() end
    if tick_task.rocket_sound and tick_task.rocket_sound.valid then tick_task.rocket_sound.destroy() end
    tick_task.valid = false
    return
  end

  -- Ensure the capsule cannot be destroyed while it is launching/landing
  space_capsule.vehicle.destructible = false

  -- Reserve a few frames pre-launch for the animation. Remaining animation is 5 seconds.
  if tick_task.phase == 1 then
    -- Launching sequence
    Capsule.tick_journey_ascend(tick_task)
    -- Update the launch progress counter so we continue forward in launch each tick
    tick_task.launch_progress = tick_task.launch_progress + 1
    -- Advance to surface transition if appropriate
    if tick_task.launch_progress >= (Capsule.animation_move_frame / Capsule.animation_speed) + Capsule.time_launch_capsule_flight then
      tick_task.phase = 2
    end
  elseif tick_task.phase == 2 then
    -- Launch is done, surface transition
    Capsule.tick_journey_transition(tick_task)
    -- Begin descent in the next tick
    tick_task.phase = 3
  else -- phase > 2
    if tick_task.phase == 3 then
      Capsule.tick_journey_descend(tick_task)
      if tick_task.landing_progress >= Capsule.time_landing_capsule_touchdown then
        tick_task.phase = 4
      end
    elseif tick_task.phase == 4 then
      Capsule.tick_journey_land(tick_task)
      tick_task.phase = 5
    elseif tick_task.phase == 5 then
      if tick_task.landing_progress == Capsule.time_landing_capsule_end then
        if tick_task.rocket_sound.valid then tick_task.rocket_sound.destroy() end
        tick_task.valid = false -- close tick task
      end
    end

    -- Progress landing
    tick_task.landing_progress = tick_task.landing_progress + 1
  end
end

---Progresses immediately within a capsule tick task to the surface transition point.
---@param tick_task CapsuleTickTask Tick task data
function Capsule.truncate_ascent(tick_task)
  if tick_task.phase < 3 and tick_task.space_capsule.vehicle.valid then
    Capsule.tick_journey_transition(tick_task)
    tick_task.phase = 3
  end
end

---Moves seated passengers on board the capsule.
---@param space_capsule CapsuleInfo
function Capsule.track_seats(space_capsule)
  for _, seated_passenger in pairs(space_capsule.tick_task.seated_passengers) do
    Spectator.track(seated_passenger, space_capsule.vehicle.surface, space_capsule.vehicle.position)
  end
end

---Teleports the given space capsule vehicle to a given position and (optionally) surface. Does
---if given capsule vehicle is in the middle of a launch/landing sequence.
---@param vehicle LuaEntity Normal or scorched space capsule vehicle
---@param surface LuaSurface Surface to teleport vehicle to, if different from current surface
---@param position MapPosition Position to teleport vehicle to
function Capsule.teleport_to_surface(vehicle, surface, position)
  local vehicle_name = vehicle.name
  local current_surface = vehicle.surface
  local current_position = vehicle.position
  local container, light, shadow

  if vehicle_name == Capsule.name_space_capsule_vehicle then
    local space_capsule = Capsule.from_vehicle(vehicle)
    if not space_capsule then
      teleport_vehicle_to_surface(vehicle, surface, position)
      return Log.debug("Space capsule vehicle without CapsuleInfo table")
    end

    -- Don't attempt teleportation during launch/landing sequence
    if space_capsule.tick_task then return end

    if space_capsule.container and space_capsule.container.valid then
      container = space_capsule.container
    else
      container = current_surface.find_entity(Capsule.name_space_capsule_container, current_position)
    end

    light = Capsule.get_make_capsule_light(space_capsule)
    shadow = Capsule.get_make_capsule_shadow(space_capsule)

    if current_surface == surface then
      vehicle.teleport(position)
      if container then container.teleport(position) end
      light.teleport(position)
      shadow.teleport(position)
    else
      teleport_vehicle_to_surface(vehicle, surface, position)

      -- Create new container at new surface/position without raising events
      space_capsule.container = surface.create_entity{
        name = Capsule.name_space_capsule_container,
        position = position,
        force = vehicle.force
      }

      if container then
        Util.swap_entity_inventories(container, space_capsule.container, defines.inventory.chest, true)
        container.destroy()
      end

      -- Destroy old light and shadow then make new ones
      light.destroy()
      shadow.destroy()

      Capsule.get_make_capsule_light(space_capsule)
      Capsule.get_make_capsule_shadow(space_capsule)

      space_capsule.current_zone = Zone.from_surface(surface) --[[@as AnyZoneType|SpaceshipType]]
    end
  elseif vehicle_name == Capsule.name_space_capsule_scorched_vehicle then
    container = current_surface.find_entity(Capsule.name_space_capsule_scorched_container, current_position)

    -- No superimposed container implies an active landing sequence; don't teleport
    if not container then return end

    shadow = Capsule.get_make_entity_shadow(vehicle)

    if current_surface == surface then
      vehicle.teleport(position)
      if container then container.teleport(position) end

      shadow.teleport(position)
    else
      teleport_vehicle_to_surface(vehicle, surface, position)

      -- Create new container at new surface/position without raising events
      local new_container = surface.create_entity{
        name = Capsule.name_space_capsule_scorched_container,
        position = position,
        force = vehicle.force
      }
      ---@cast new_container -?

      -- Destroy old container silently
      if container then
        Util.swap_entity_inventories(container, new_container, defines.inventory.chest, true)
        container.destroy()
      end

      -- Destroy old shadow then make a new one
      shadow.destroy()
      Capsule.get_make_entity_shadow(vehicle)
    end
  end
end

---Opens the capsule GUI whenever the player gets in a capsule
---Closes the capsule GUI whenever the player gets into a different vehicle (or gets out)
---@param event EventData.on_player_driving_changed_state|{player_index:uint} Event data
function Capsule.on_player_driving_changed_state(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if player then
    local open = false
    if player.vehicle and player.vehicle.name == Capsule.name_space_capsule_vehicle then
      local vehicle = player.vehicle
      remote.call("jetpack", "stop_jetpack_immediate", {character = player.character})
      local space_capsule = Capsule.from_vehicle(vehicle)
      if space_capsule and space_capsule.container and space_capsule.container.valid then
        player.opened = space_capsule.container
        CapsuleGUI.gui_update(player)
        open = true
      end
    end
    if not open then
      CapsuleGUI.gui_close(player)
      if player.opened_gui_type == defines.gui_type.entity and player.opened and player.opened.name == Capsule.name_space_capsule_container then
        player.opened = nil
      end
    end
  end
end
Event.addListener(defines.events.on_player_driving_changed_state, Capsule.on_player_driving_changed_state)

---Gets or indirectly creates the shadow of a space capsule.
---@param space_capsule CapsuleInfo Space capsule data
---@return LuaEntity
function Capsule.get_make_capsule_shadow(space_capsule)
  if space_capsule.shadow and space_capsule.shadow.valid then return space_capsule.shadow end
  space_capsule.shadow = Capsule.get_make_entity_shadow(space_capsule.vehicle)
  return space_capsule.shadow
end

---Searches for the space capsule shadow, or creates a new shadow if it couldn't find it on surface.
---@param entity LuaEntity Space capsule entity
---@return LuaEntity
function Capsule.get_make_entity_shadow(entity)
  local shadow = entity.surface.find_entity(Capsule.name_space_capsule_vehicle_shadow, entity.position)
  if shadow then return shadow end
  local shadow_ghosts = entity.surface.find_entities_filtered{
    ghost_name = Capsule.name_space_capsule_vehicle_shadow,
    position = entity.position
  }
  if shadow_ghosts[1] and shadow_ghosts[1].valid then
    local _, shadow = shadow_ghosts[1].revive({})
    if shadow then return shadow end
  end
  shadow = entity.surface.create_entity{
    name = Capsule.name_space_capsule_vehicle_shadow,
    force = entity.force,
    position = entity.position
  }
  ---@cast shadow -?
  shadow.destructible = false
  return shadow
end

---Gets or makes the light associated with a space capsule that is stationary.
---@param space_capsule CapsuleInfo
---@return LuaEntity
function Capsule.get_make_capsule_light(space_capsule)
  if space_capsule.light and space_capsule.light.valid then return space_capsule.light end
  space_capsule.light = Capsule.get_make_entity_light(space_capsule.vehicle, space_capsule.tick_task ~= nil)
  return space_capsule.light
end

---Gets or makes the light associated with a space capsule.
---@param entity LuaEntity Space capsule entity
---@param launch boolean Is the capsule launching or otherwise on its journey?
---@return LuaEntity light
function Capsule.get_make_entity_light(entity, launch)
  local light = entity.surface.find_entity(launch and Capsule.name_space_capsule_vehicle_light_launch or Capsule.name_space_capsule_vehicle_light, entity.position)
  if light then return light end

  local light_ghosts = entity.surface.find_entities_filtered{
    ghost_name=Capsule.name_space_capsule_vehicle_light,
    position=entity.position
  }

  if light_ghosts[1] then
    local _, light = light_ghosts[1].revive({})
    if light then return light end
  end

  light = entity.surface.create_entity{
    name = launch and Capsule.name_space_capsule_vehicle_light_launch or Capsule.name_space_capsule_vehicle_light,
    position = entity.position,
    speed = 0,
    target = entity
  }
  ---@cast light -?
  return light
end

---Handles player selecting a target for the capsule.
---@param event EventData.CustomInputEvent Event data
function Capsule.on_targeter(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if not player then return end
  local cursor_item = player.cursor_stack
  if not (cursor_item and cursor_item.valid_for_read) then return end
  if cursor_item.name ~= Capsule.name_capsule_targeter then return end
  local remote_view_activity = RemoteView.get_activity(player, "space-capsule")
  if not remote_view_activity then return end
  local space_capsule = remote_view_activity.space_capsule
  local destination_zone = Zone.from_surface(player.surface)
  if not destination_zone then return end
  local coordinates = event.cursor_position
  Capsule.set_target(player, space_capsule, destination_zone, coordinates, true)
end
Event.addListener(mod_prefix .. "-targeter", Capsule.on_targeter)

function Capsule.on_init()
  storage.space_capsules = {}
end
Event.addListener("on_init", Capsule.on_init, true)

return Capsule
