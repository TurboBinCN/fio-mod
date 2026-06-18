local Launchpad = {}
-- launchpad, cargo rocket, and rocket landing / crashing sequences

--custom event
Launchpad.on_cargo_rocket_launched_event = util.get_custom_event("on_cargo_rocket_launched")
Launchpad.on_cargo_rocket_padless_event = util.get_custom_event("on_cargo_rocket_padless")

-- constants
Launchpad.name_rocket_launch_pad = mod_prefix.."rocket-launch-pad"
Launchpad.name_rocket_launch_pad_tank = mod_prefix.."rocket-launch-pad-tank"
Launchpad.name_rocket_launch_pad_combinator = mod_prefix.."rocket-launch-pad-combinator"
Launchpad.name_rocket_launch_pad_silo = mod_prefix.."rocket-launch-pad-silo"
Launchpad.name_rocket_launch_pad_silo_dummy = mod_prefix.."rocket-launch-pad-silo-dummy-ingredient-item"
Launchpad.name_rocket_launch_pad_seat = mod_prefix.."rocket-launch-pad-_-seat"
Launchpad.name_rocket_section = mod_prefix.."cargo-rocket-section"

Launchpad.name_cargo_rocket = mod_prefix.."cargo-rocket"
Launchpad.name_cargo_pod = mod_prefix.."cargo-rocket-cargo-pod"

Launchpad.name_tech_rocket_cargo_safety = mod_prefix.."rocket-cargo-safety"
Launchpad.name_tech_rocket_reusability = mod_prefix.."rocket-reusability"
Launchpad.name_tech_rocket_survivability = mod_prefix.."rocket-survivability"

Launchpad.rocket_capacity = 500
Launchpad.fuel_per_delta_v = 8 -- maybe this should be an energy value?
Launchpad.rocket_sections_per_rocket = 100
Launchpad.crew_capsules_per_rocket = 1
Launchpad.signal_for_launch = {type = "virtual", name = "signal-green"}
Launchpad.signal_for_rocket_complete = {type = "virtual", name = mod_prefix.."cargo-rocket", quality="normal"}
Launchpad.seat_y_offset = 4.9

---@type {name:RocketLaunchTriggerType, display:LocalisedString}
Launchpad.trigger_options = {
  { name = "none", display = {"space-exploration.trigger-none"}},
  { name = "fuel-full", display = {"space-exploration.trigger-fuel-full"}},
  { name = "cargo-full", display = {"space-exploration.trigger-cargo-full"}},
  { name = "fuel-full-signal", display = {"space-exploration.trigger-fuel-full-signal"}},
  { name = "cargo-full-signal", display = {"space-exploration.trigger-cargo-full-signal"}},
  { name = "cargo-full-or-signal", display = {"space-exploration.trigger-cargo-full-or-signal"}},
}

Launchpad.time_takeoff = 440 -- the delay before the rocket gets going
Launchpad.time_takeoff_finish_ascent = 1100 --1164 -- just before the rocket launch event would fire

Launchpad.time_landing_capsule_touchdown = 6 * 60 -- when the capsule lands
Launchpad.time_landing_cargopod_first = 3 * 60 -- when the first cargopod lands
Launchpad.time_landing_cargopod_last = 5 * 60 -- when the last cargopod lands
Launchpad.time_landing_debris_first = 2 * 60 -- when the first debris lands
Launchpad.time_landing_debris_last = 7 * 60 -- when the last debris lands
Launchpad.landing_start_altitude = 128

Launchpad.safety_delta_v_base = 1000
Launchpad.safety_delta_v_factor = 100000

Launchpad.names_cargo_fragment = { -- these are the base names, actual names are "se-falling-"
  "cargo-fragment-a",
  "cargo-fragment-b",
  "cargo-fragment-c",
  "cargo-fragment-d",
}

Launchpad.rocket_fragments_large = 4
Launchpad.names_rocket_fragments_large = {
  "rocket-fragment-big-d",
  "rocket-fragment-big-a",
  "rocket-fragment-big-b",
  "rocket-fragment-big-c"
}
Launchpad.rocket_fragments_medium = 6
Launchpad.names_rocket_fragments_medium = {
  "rocket-fragment-medium-a",
  "rocket-fragment-medium-b",
  "rocket-fragment-medium-c"
}
Launchpad.rocket_fragments_small = 20
Launchpad.names_rocket_fragments_small = {
  "rocket-fragment-small-a",
  "rocket-fragment-small-b",
  "rocket-fragment-small-c",
  "rocket-fragment-small-d",
  "rocket-fragment-small-e",
  "rocket-fragment-small-f",
  "rocket-fragment-small-g",
  "rocket-fragment-small-h",
  "rocket-fragment-small-i",
  "rocket-fragment-small-j"
}
Launchpad.rocket_fragments_tiny = 20
Launchpad.names_rocket_fragments_tiny = {
  "rocket-fragment-tiny-a",
  "rocket-fragment-tiny-b",
  "rocket-fragment-tiny-c",
  "rocket-fragment-tiny-d",
  "rocket-fragment-tiny-e",
  "rocket-fragment-tiny-f"
}

---Returns the cargo loss modifier for a given force.
---@param force LuaForce Force to be evaluated
---@return number modifier
function Launchpad.get_force_cargo_loss_modifier(force)
  local researched_levels = 0
  local i = 1
  local techs = force.technologies
  local current_level = techs[Launchpad.name_tech_rocket_cargo_safety .. "-" .. i]

  while current_level and (current_level.researched or current_level.level > i) do
    if current_level.level > i then
      researched_levels = current_level.level - 1
      break
    else
      researched_levels = researched_levels + 1
      i = i + 1
      current_level = techs[Launchpad.name_tech_rocket_cargo_safety .. "-" .. i]
    end
  end

  return 0.9 ^ researched_levels
end

---@param force LuaForce
---@param target_zone AnyZoneType
---@param delta_v number
---@return number
function Launchpad.get_cargo_loss(force, target_zone, delta_v) -- percentage of cargo lost
  delta_v = (delta_v or Launchpad.safety_delta_v_factor) + Launchpad.safety_delta_v_base -- 50%
  local loss = delta_v/(delta_v+Launchpad.safety_delta_v_factor)
  --local loss = 0.5 * storage.forces[force.name].cargo_rockets_launched / (storage.forces[force.name].cargo_rockets_launched + 500)
  if target_zone then
    if target_zone.type == "anomaly" then
      ---@cast target_zone AnomalyType
      loss = 1
    elseif target_zone.type == "asteroid-field" then
      ---@cast target_zone AsteroidFieldType
      loss = loss + (1 - loss) * 0.5
    elseif target_zone.type == "asteroid-belt" then
      ---@cast target_zone AsteroidBeltType
      loss = loss + (1 - loss) * 0.1
    end
  end
  return loss *Launchpad.get_force_cargo_loss_modifier(force)
end

---Gets the cargo rocket section recoverability rate for a given force.
---@param force LuaForce Force
---@return number
function Launchpad.get_reusability(force)
  local recovery = 0.2
  local i = 1
  local current_level = force.technologies[Launchpad.name_tech_rocket_reusability.."-"..i]
  while current_level and (current_level.researched or current_level.level > i)  do
    local more_levels = (current_level.researched and current_level.level or current_level.level-1) - i
    i = i + 1 + more_levels
    recovery = recovery + 0.04 * (1 + more_levels)
    current_level = force.technologies[Launchpad.name_tech_rocket_reusability.."-"..i]
  end
  return recovery
end

---Returns the survivability loss modifier (base chance to fail when targeting a landing pad) for
---a given force.
---@param force LuaForce Force to be evaluated
---@return number modifier
function Launchpad.get_force_survivability_loss_modifier(force)
  local researched_levels = 0
  local i = 1
  local techs = force.technologies
  local current_level = techs[Launchpad.name_tech_rocket_survivability .. "-" .. i]

  while current_level and (current_level.researched or current_level.level > i) do
    if current_level.level > i then
      researched_levels = current_level.level - 1
      break
    else
      researched_levels = researched_levels + 1
      i = i + 1
      current_level = techs[Launchpad.name_tech_rocket_survivability .. "-" .. i]
    end
  end

  return 0.9 ^ researched_levels
end

---@param force LuaForce
---@param target_zone AnyZoneType
---@param delta_v number
---@return number
function Launchpad.get_survivability_loss(force, target_zone, delta_v) -- chance to fail to land on rocket launch pad
  delta_v = (delta_v or Launchpad.safety_delta_v_factor) + Launchpad.safety_delta_v_base -- 50%
  local loss = delta_v/(delta_v+Launchpad.safety_delta_v_factor)
  --local loss = 0.5 * storage.forces[force.name].cargo_rockets_launched / (storage.forces[force.name].cargo_rockets_launched + 500)
  if target_zone then
    if target_zone.type == "anomaly" then
      ---@cast target_zone AnomalyType
      loss = loss + (1 - loss) * 0.5
    elseif target_zone.type == "asteroid-field" then
      ---@cast target_zone AsteroidFieldType
      loss = loss + (1 - loss) * 0.1
    elseif target_zone.type == "asteroid-belt" then
      ---@cast target_zone AsteroidBeltType
      loss = loss + (1 - loss) * 0.05
    end
  end
  return loss * Launchpad.get_force_survivability_loss_modifier(force)
end

--- Gets the Launchpad for this unit_number
---@param unit_number number
---@return RocketLaunchPadInfo? launch_pad
function Launchpad.from_unit_number (unit_number)
  if not unit_number then Log.debug("Launchpad.from_unit_number: invalid unit_number: nil") return end
  unit_number = tonumber(unit_number)
  -- NOTE: only supports container as the entity
  if storage.rocket_launch_pads[unit_number] then
    return storage.rocket_launch_pads[unit_number]
  else
    Log.debug("Launchpad.from_unit_number: invalid unit_number: " .. unit_number)
  end
end

--- Gets the Launchpad for this entity
---@param entity LuaEntity
function Launchpad.from_entity (entity)
  if not(entity and entity.valid) then
    Log.debug("Launchpad.from_entity: invalid entity")
    return
  end
  -- NOTE: only supports container as the entity
  return Launchpad.from_unit_number(entity.unit_number)
end

--- Computes the cost to launch a rocket
---@param origin AnyZoneType launch zone
---@param destination AnyZoneType|SpaceshipType destination zone
---@return number? fuel_cost
function Launchpad.get_fuel_cost(origin, destination)
  if not (origin and destination) then return end
  if destination.type == "spaceship" then
    return Launchpad.fuel_per_delta_v * (Zone.get_launch_delta_v(origin) + Zone.get_travel_delta_v(origin, destination))
  end
  storage.cache_rocket_fuel_cost[origin.index] = storage.cache_rocket_fuel_cost[origin.index] or {}
  if not storage.cache_rocket_fuel_cost[origin.index][destination.index] then
    storage.cache_rocket_fuel_cost[origin.index][destination.index] = Launchpad.fuel_per_delta_v * (Zone.get_launch_delta_v(origin) + Zone.get_travel_delta_v(origin, destination))
  end
  return storage.cache_rocket_fuel_cost[origin.index][destination.index]
end

--[[
Input the destination as either:
  { type = "zone", zone_index = name }
  { type = "landing-pad", zone_index = name, landing_pad_name = name }
Output the destination as:
  { type = "zone", zone_index = name, zone = Zone, position = {x=#,y=#} }
  { type = "landing-pad", landing_pad_name = name, landing_pad = rocket_landing_pad}
]]--
---@param struct RocketLaunchPadInfo
---@param allow_non_empty? boolean
---@return CargoRocketLockedDestinationInfo|false
function Launchpad.lock_destination (struct, allow_non_empty)
  -- force launch can go to non-empty landings

  if struct.destination then
    if struct.destination.zone then
      -- can't have people changing destination mid-launch
      local force_name = struct.force_name
      -- destination to locked destination
      local locked_destination = { -- don't use deepcopy be
        zone = struct.destination.zone,
        landing_pad_name = struct.destination.landing_pad_name,
      }

      local zone = locked_destination.zone
      if not zone then return false end

      if locked_destination.landing_pad_name then

        local landing_pads = Landingpad.get_zone_landing_pads_availability(force_name, zone, locked_destination.landing_pad_name)

        if next(landing_pads.empty_landing_pads) then
          local landing_pad = landing_pads.empty_landing_pads[math.random(#landing_pads.empty_landing_pads)]
          locked_destination.landing_pad = landing_pad
          Zone.get_make_surface(zone)
          return locked_destination
        elseif allow_non_empty and next(landing_pads.filled_landing_pads) then
          local landing_pad = landing_pads.filled_landing_pads[math.random(#landing_pads.filled_landing_pads)]
          locked_destination.landing_pad = landing_pad
          Zone.get_make_surface(zone)
          return locked_destination
        end

      else -- not landing pad name

        Zone.get_make_surface(zone)
        locked_destination.position = Zone.find_zone_landing_position(zone)

        --this is the first cargo rocket to space, go to the space platform satellite
        if zone.type == "orbit" and zone.ruins and zone.ruins["satellite2"] then
          ---@cast zone OrbitType
          if (storage.forces[force_name].cargo_rockets_launched or 0) == 0 then
            local satellite_blueprint = Ruin.ruins["satellite2"]
            locked_destination.position = {
              x = zone.ruins["satellite2"].x
                + (satellite_blueprint.landing_offset.x or satellite_blueprint.landing_offset[1])
                - (satellite_blueprint.center.x or satellite_blueprint.center[1]),
              y = zone.ruins["satellite2"].y
                + (satellite_blueprint.landing_offset.y or satellite_blueprint.landing_offset[2])
                - (satellite_blueprint.center.y or satellite_blueprint.center[2])
            }
          end
        end
        return locked_destination
      end
    elseif struct.destination.landing_pad_name then
      -- can't have people changing destination mid-launch
      local force_name = struct.force_name

      local locked_destination = { -- don't use deepcopy be
        landing_pad_name = struct.destination.landing_pad_name,
      }

      local landing_pads = Landingpad.get_force_landing_pads_availability(force_name, locked_destination.landing_pad_name)

      if next(landing_pads.empty_landing_pads) then
        local landing_pad = landing_pads.empty_landing_pads[math.random(#landing_pads.empty_landing_pads)]
        locked_destination.zone = landing_pad.zone
        locked_destination.landing_pad = landing_pad
        return locked_destination
      elseif allow_non_empty and next(landing_pads.filled_landing_pads) then
        local landing_pad = landing_pads.filled_landing_pads[math.random(#landing_pads.filled_landing_pads)]
        locked_destination.zone = landing_pad.zone
        locked_destination.landing_pad = landing_pad
        return locked_destination
      end

    end
  end
  return false
end

---@param struct RocketLaunchPadInfo
---@param main_inv LuaInventory
function Launchpad.update_combinator(struct, main_inv)
  if struct.combinator then
    local comb = struct.combinator.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
    local empty_stacks = struct.empty_stacks or 0
    local unbarred_inventory_size = main_inv.get_bar() - 1
    local rocket_complete = struct.rocket_sections >= Launchpad.rocket_sections_per_rocket and struct.crew_capsules >= Launchpad.crew_capsules_per_rocket
    comb.get_section(1).filters = {
      {value={type="fluid", name=name_fluid_rocket_fuel, quality="normal"}, min=struct.lua_fuel},
      {value={type="item", name=Launchpad.name_rocket_section, quality="normal"}, min=struct.rocket_sections},
      {value={type="item", name=Capsule.name_space_capsule, quality="normal"}, min=struct.crew_capsules},
      {value=Launchpad.signal_for_rocket_complete, min=rocket_complete and 1 or 0},
      {value={type="virtual", name="signal-E", quality="normal"}, min=empty_stacks},
      {value={type="virtual", name="signal-F", quality="normal"}, min=unbarred_inventory_size - empty_stacks},
      {value={type="virtual", name="signal-L", quality="normal"}, min=struct.required_fuel or 0},
    }
  end
end

---@param struct RocketLaunchPadInfo
function Launchpad.prep(struct)
  if not (struct.container and struct.container.valid) then
    return Launchpad.destroy(struct)
  end

  struct.required_fuel = nil -- invalid
  if struct.destination then
    local origin_zone = struct.zone
    if struct.destination.landing_pad_name and not struct.destination.zone then

      if storage.forces[struct.force_name]
      and storage.forces[struct.force_name].rocket_landing_pad_names
      and storage.forces[struct.force_name].rocket_landing_pad_names[struct.destination.landing_pad_name] then
        local required_fuel_max = 0
        local landing_pads_list = storage.forces[struct.force_name].rocket_landing_pad_names[struct.destination.landing_pad_name]
        -- TODO: This required_fuel_max calculation is a non-negligible part of the average SE performance cost.
        -- We should set it only when it changes, instead of every second like this.
        for _, landing_pad in pairs(landing_pads_list) do
          required_fuel_max = math.max(required_fuel_max, Launchpad.get_fuel_cost(origin_zone, landing_pad.zone))
        end
        if required_fuel_max > 0 then
          struct.required_fuel = required_fuel_max
        end
      end
    else
      local destination_zone = struct.destination.zone
      struct.required_fuel = Launchpad.get_fuel_cost(origin_zone, destination_zone); -- self-validates
    end
  else
    struct.required_fuel = nil -- invalid
  end

  -- balance tank fuel and lua fuel
  -- fuel tank % should match total %
  local required_fuel = struct.required_fuel or 0
  if not (struct.tank and struct.tank.valid) then
    struct.tank = struct.container.surface.create_entity{
      name = Launchpad.name_rocket_launch_pad_tank,
      force = struct.container.force,
      position = {struct.container.position.x, struct.container.position.y + 1}} -- 1 tile down to be in front of silo
    local wirecon_green = struct.container.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    local wirecon_red = struct.container.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    wirecon_green.connect_to(struct.tank.get_wire_connector(defines.wire_connector_id.circuit_green, true), false, defines.wire_origin.script)
    wirecon_red.connect_to(struct.tank.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script)
    struct.tank.destructible = false
  end

  local fluid = struct.tank.get_fluid(1) or {name = name_fluid_rocket_fuel, amount = 0}
  local is_valid_fuel = fluid.name == name_fluid_rocket_fuel
  struct.total_fuel = (struct.lua_fuel or 0) + (is_valid_fuel and fluid.amount or 0)
  if is_valid_fuel and struct.total_fuel > 0 then
    -- Only do balancing if we have a valid fuel type and there is fuel to balance
    local percent_of_required = (required_fuel ~= 0) and (struct.total_fuel / required_fuel) or 1
    if percent_of_required < 1 then -- If we have full fuel or above, do not balance. Let the buffer accumulate or spread to output pipes..
      fluid.amount = math.min(struct.total_fuel, percent_of_required * Shared.cargo_rocket_launch_pad_tank_nonbuffer)
    end
    if fluid.amount < 1 then
      fluid.amount = 1
    end
    struct.lua_fuel = struct.total_fuel - fluid.amount
    struct.tank.set_fluid(1, fluid)
  end

  local main_inv = struct.container.get_inventory(defines.inventory.chest)

  struct.crew_capsules = struct.crew_capsules or 0
  struct.rocket_sections = struct.rocket_sections or 0

  -- Take capsule from main container
  if (struct.crew_capsules or 0) < Launchpad.crew_capsules_per_rocket then
    local items = main_inv.get_item_count(Capsule.name_space_capsule)
    if items > 0 then
      local take = math.min(items, Launchpad.crew_capsules_per_rocket - struct.crew_capsules)
      main_inv.remove({name=Capsule.name_space_capsule, count=take})
      struct.crew_capsules = struct.crew_capsules + take
    end
  end

  -- Take sections from main container
  if struct.rocket_sections < Launchpad.rocket_sections_per_rocket then
    local items = main_inv.get_item_count(Launchpad.name_rocket_section)
    if items > 0 then
      local take = math.min(items, Launchpad.rocket_sections_per_rocket - struct.rocket_sections)
      main_inv.remove({name=Launchpad.name_rocket_section, count=take})
      struct.rocket_sections = struct.rocket_sections + take
    end
  end

  struct.empty_stacks = main_inv.count_empty_stacks(true, false) -- Count filtered slots, don't count barred slots.
  Launchpad.update_combinator(struct, main_inv)

  if struct.rocket_sections >= Launchpad.rocket_sections_per_rocket and
      struct.crew_capsules >= Launchpad.crew_capsules_per_rocket and
      not struct.has_inserted_dummy then
    local inserted = struct.silo.insert{name = Launchpad.name_rocket_launch_pad_silo_dummy, count = 1}
    if inserted == 1 then
      struct.has_inserted_dummy = true
      -- Clear SE-added inventory filters
      main_inv.set_filter(Launchpad.rocket_capacity - 1, nil)
      main_inv.set_filter(Launchpad.rocket_capacity, nil)
    end
  end
end

---@param character LuaEntity
---@return boolean
local function find_and_warn_banned_items_in_character(character)
  local banned_items = find_items_banned_from_transport_in_character(character)
  if next(banned_items) then
    local name = character.player and character.player.name or "Character"
    character.force.print({"space-exploration.banned-items-in-character", name, serpent.line(banned_items)})
    return true
  end
  return false
end

---@param struct RocketLaunchPadInfo
---@param skip_prep boolean
---@param allow_non_empty? boolean
function Launchpad.launch(struct, skip_prep, allow_non_empty)

  if struct.launch_status > -1 then return end -- already launching
  if skip_prep ~= true then
    Launchpad.prep(struct)
  end

  local has_banned_items = false
  local main_inv = struct.container.get_inventory(defines.inventory.chest)
  if next(storage.items_banned_from_transport) then -- If there's any banned item
    local banned_items = find_items_banned_from_transport(main_inv)
    if next(banned_items) then
      has_banned_items = true
      local gps_tag = util.gps_tag(struct.container.surface.name, struct.container.position)
      game.forces[struct.force_name].print({"space-exploration.banned-items-in-cargo-rocket", gps_tag, serpent.line(banned_items)})
    end

    for _, seat in pairs(Launchpad.get_make_seats(struct)) do
      local driver = seat.get_driver()
      if driver then
        local character_has_banned_items = find_and_warn_banned_items_in_character(driver)
        has_banned_items = has_banned_items or character_has_banned_items
      end
      local passenger = seat.get_passenger()
      if passenger then
        local character_has_banned_items = find_and_warn_banned_items_in_character(passenger)
        has_banned_items = has_banned_items or character_has_banned_items
      end
    end
  end

  if has_banned_items then
    return -- Cancel launch
  end

  local destination = Launchpad.lock_destination(struct, allow_non_empty)

  if destination then
    local current_zone = struct.zone
    local destination_zone = destination.zone
    struct.launching_to_destination = destination

    local required_fuel = Launchpad.get_fuel_cost(current_zone, destination_zone)
    struct.required_fuel = required_fuel

    -- the destination is locked so let's go
    if destination.landing_pad then
      destination.position = Util.vectors_add(destination.landing_pad.container.position, {x = 0, y = 2})
      Landingpad.add_inbound(destination.landing_pad, "cargo-rocket")
    end

    -- set the contents
    local slots_free =  main_inv.count_empty_stacks(true)
    local slots_used = #main_inv - slots_free
    local slots_used_p = slots_used / #main_inv
    local rocket_cost_p = 0.5 + 0.5 * slots_used_p

    required_fuel = required_fuel * rocket_cost_p
    struct.rocket_sections_used = math.ceil(Launchpad.rocket_sections_per_rocket * rocket_cost_p)

    local main_contents = main_inv.get_contents()
    struct.launched_contents = main_contents
    -- make a global temp inventory.
    -- swap items to that inventory.
    -- make sure to destroy later
    struct.launched_inventory = game.create_inventory(#main_inv --[[@as uint16]])
    Util.swap_inventories(main_inv, struct.launched_inventory)
    main_inv.clear() -- chould already be empty anyway.
    Log.debug("make launched_inventory with size" .. #struct.launched_inventory)

    -- Set inventory filters
    main_inv.set_filter(Launchpad.rocket_capacity - 1, Launchpad.name_rocket_section)
    main_inv.set_filter(Launchpad.rocket_capacity, Capsule.name_space_capsule)

    -- consume the fuel
    local lua_fuel_consumed = math.min(struct.lua_fuel, required_fuel)
    struct.lua_fuel = struct.lua_fuel - lua_fuel_consumed
    if lua_fuel_consumed < required_fuel then
      local fluid = struct.tank.get_fluid(1)
      if fluid and fluid.name == name_fluid_rocket_fuel then
        local tank_fuel_consumed = math.min(required_fuel - lua_fuel_consumed, fluid.amount)
        fluid.amount = math.max(1, fluid.amount - tank_fuel_consumed)
        struct.tank.set_fluid(1, fluid)
        struct.total_fuel = struct.lua_fuel + fluid.amount
      end
    end
    if struct.tank and struct.tank.fluidbox and struct.tank.get_fluid(1) and struct.tank.get_fluid(1).name then
      struct.container.force.get_fluid_production_statistics(struct.tank.surface).on_flow(struct.tank.get_fluid(1).name, -required_fuel)
    end

    -- consume rocket parts
     struct.rocket_sections = struct.rocket_sections - struct.rocket_sections_used
--     struct.container.force.get_item_production_statistics(**needs surface**).on_flow(Launchpad.name_rocket_section, -Launchpad.rocket_sections_per_rocket)

    -- consume crew capsule
     struct.crew_capsules = struct.crew_capsules - Launchpad.crew_capsules_per_rocket
--     struct.container.force.get_item_production_statistics(**needs surface**).on_flow(Capsule.name_space_capsule, -Launchpad.crew_capsules_per_rocket)

    -- start charting the landing
    if destination_zone.type ~= "spaceship" then
      ---@cast destination_zone -SpaceshipType
      local range = Zone.discovery_scan_radius
      struct.container.force.chart(Zone.get_make_surface(destination_zone), {
        {destination.position.x - range, destination.position.y - range - Launchpad.landing_start_altitude},
        {destination.position.x + range, destination.position.y + range}
      })
    end
    -- set launch status
    struct.launch_status = 1

    script.raise_event(Launchpad.on_cargo_rocket_launched_event, Launchpad.export_launchpad(struct))

    Launchpad.update_combinator(struct, main_inv)
  end
end

---Creates a small and shallow representation of the data in a launch pad struct to be passed in the
---custom cargo rocket launch event raised by SE.
---@param struct RocketLaunchPadInfo Launch pad data
function Launchpad.export_launchpad(struct)
  local data =  {
    unit_number = struct.unit_number,
    launchpad = struct.container,
    force_name = struct.force_name,
    zone_index = struct.zone.index,
    zone_name = struct.zone.name,
    launched_contents = struct.launched_contents
  }

  if struct.destination and struct.destination.zone then
    data.destination_zone_index = struct.destination.zone.index
    data.destination_zone_name = struct.destination.zone.name
  end

  if struct.launching_to_destination then
    data.destination_zone_index = struct.launching_to_destination.zone.index
    data.destination_zone_name = struct.launching_to_destination.zone.name
    data.destination_position = struct.launching_to_destination.position
    data.landing_pad = struct.launching_to_destination.landing_pad
      and struct.launching_to_destination.landing_pad.container or nil
    data.landing_pad_name = struct.launching_to_destination.landing_pad_name
  end

  return data
end

---@param struct RocketLaunchPadInfo
function Launchpad.tick(struct)
  -- this should only be called once per 60 ticks during prep and every tick during launch
  -- actually, launch should be handles seperatly.
  -- make launches and capsule launches in to tick tasks
  -- Launchpad.prep can be called every tick for gui updates
  if not (struct.container and struct.container.valid) then
    return Launchpad.destroy(struct)
  end

  if struct.launch_status < 1 then

    Launchpad.prep(struct)

    -- if struct.required_fuel then the destination must be valid
    if struct.required_fuel and struct.total_fuel >= struct.required_fuel
     and struct.rocket_sections >= Launchpad.rocket_sections_per_rocket
     and struct.crew_capsules >= Launchpad.crew_capsules_per_rocket then
      -- can launch
      -- TRIGGERS

      if struct.launch_trigger == "fuel-full" then
        -- we already know fuel is full so launch
        Launchpad.launch(struct, true)
      elseif struct.launch_trigger == "cargo-full" then
        -- cargo is full so try launch
        if struct.empty_stacks == 0 then Launchpad.launch(struct, true) end
      elseif struct.launch_trigger == "fuel-full-signal" then
        if struct.container.get_signal(Launchpad.signal_for_launch, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red) > 0 then
          Launchpad.launch(struct, true)
        end
      elseif struct.launch_trigger == "cargo-full-signal" then
        if struct.empty_stacks == 0 and struct.container.get_signal(Launchpad.signal_for_launch, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red) > 0 then
          Launchpad.launch(struct, true)
        end
      elseif struct.launch_trigger == "cargo-full-or-signal" then
        if struct.empty_stacks == 0 then
          -- cargo is full so try launch
          Launchpad.launch(struct, true)
        elseif struct.container.get_signal(Launchpad.signal_for_launch, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red) > 0 then
          -- signal so try launch
          Launchpad.launch(struct, true)
        end
      end

    end
  elseif struct.launch_status == 1 then
    -- the rocket should be ready
    if struct.silo.launch_rocket() then
      --Log.debug("launching")
      struct.launch_status = 2
      struct.rocket_entity = struct.container.surface.find_entities_filtered{name=Launchpad.name_cargo_rocket, area=util.position_to_area(struct.container.position, 0.5)}[1]
      -- the launch pad could get removed at this point and the rocket would need to keep going.
      local tick_task = new_tick_task("launchpad-journey") --[[@as CargoRocketTickTask]]
      tick_task.struct = struct
      tick_task.force_name = struct.force_name
      tick_task.rocket_entity = struct.rocket_entity
      tick_task.launch_timer = 0
      tick_task.launched_contents = struct.launched_contents
      tick_task.launched_inventory = struct.launched_inventory
      tick_task.rocket_sections_used = struct.rocket_sections_used
      tick_task.seated_passengers = {}
      Log.debug("Move launched_inventory to tick task " .. #tick_task.launched_inventory)
      struct.launched_inventory = nil
      tick_task.launching_to_destination = struct.launching_to_destination
      tick_task.delta_v = Zone.get_travel_delta_v(tick_task.struct.zone, tick_task.launching_to_destination.zone)

      local target_surface = Zone.get_make_surface(tick_task.launching_to_destination.zone)
      target_surface.request_to_generate_chunks(Util.vectors_add(tick_task.launching_to_destination.position, {x = 0, y = Launchpad.landing_start_altitude}),
         Launchpad.landing_start_altitude / 32 / 2)
      -- start the launch animation
      -- move the player seats over the rocket
      -- follow rocket launch
      -- if not landing_pad clear destination: remove biters
      -- teleport over landing zone
      -- if not landing_pad start descent / crash sequence
      -- place landfill, place scaffold, place cargo Pods
      -- place recoverable sections
      -- destroy the seats to release the players
    end
  else
    -- stays at struct.launch_status 2 until tick_task sets it back to -1
  end
end

---@param zone AnyZoneType
---@param size uint
---@param name string
---@param position MapPosition
---@param start_position_x_offset number
function Launchpad.drop_rocket_fragment(zone, size, name, position, start_position_x_offset)
  local target_surface = Zone.get_make_surface(zone)
    local falling_time
    if math.random() < 0.5 then -- biggest first
      falling_time = Launchpad.time_landing_debris_first
        + (size - math.random()) / 4 * (Launchpad.time_landing_debris_last - Launchpad.time_landing_debris_first)
    else -- or just random
      falling_time = Launchpad.time_landing_debris_first + math.random() * (Launchpad.time_landing_debris_last - Launchpad.time_landing_debris_first)
    end
    local landing_start_altitude = Launchpad.landing_start_altitude
    if Zone.is_space(zone) then
      ---@cast zone -PlanetType, -MoonType
      landing_start_altitude = landing_start_altitude * 0.5
    end
    local random_start_offset = {x = 8 * (math.random() - 0.5), y = 8 * (math.random() - 0.5)}
    local start_position = Util.vectors_add(position, {
      x = random_start_offset.x + start_position_x_offset,
      y = random_start_offset.y - landing_start_altitude})
    local start_position_shadow = Util.vectors_add(position, {
      x = random_start_offset.x + landing_start_altitude + start_position_x_offset,
      y = random_start_offset.y})

    local land_position = Util.vectors_add(position, {
        x = random_start_offset.x + 32 * (math.random() - 0.5),
        y = random_start_offset.y + 32 * (math.random() - 0.5)})

    local flat_distance = Util.vectors_delta_length(start_position, land_position)
    local flat_distance_shadow = Util.vectors_delta_length(start_position_shadow, land_position)
    local speed = flat_distance / falling_time
    local speed_shadow = flat_distance_shadow / falling_time

    if Zone.is_space(zone) then
      ---@cast zone -PlanetType, -MoonType
      target_surface.create_entity{
        name = mod_prefix .. "space-" ..name,
        position = start_position,
        target = land_position,
        speed = speed,
      }
    else
      ---@cast zone PlanetType|MoonType
      target_surface.create_entity{
        name = mod_prefix .. "falling-" ..name,
        position = start_position,
        target = land_position,
        speed = speed,
      }
      target_surface.create_entity{
        name = mod_prefix .. "shadow-" ..name,
        position = start_position_shadow,
        target = land_position,
        speed = speed_shadow,
      }
    end
end

-- Phase 1
---@param tick_task CargoRocketTickTask
function Launchpad.tick_journey_ascend(tick_task)
  tick_task.launch_timer = tick_task.launch_timer + 1

  local struct = tick_task.struct


  if struct and struct.valid then
    if tick_task.launch_timer <= Launchpad.time_takeoff then
      -- collect passengers while rocket is low
      for _, seat in pairs(Launchpad.get_make_seats(struct)) do
        if seat.get_driver() then
          local spectator = Spectator.start(seat.get_driver(), tick_task)
          if spectator then
            table.insert(tick_task.seated_passengers, spectator)
          end
        end
        if seat.get_passenger() then
          local spectator = Spectator.start(seat.get_passenger(), tick_task)
          if spectator then
            table.insert(tick_task.seated_passengers, spectator)
          end
        end
      end
    end
  end

  if tick_task.rocket_entity and tick_task.rocket_entity.valid then
    -- move passengers with the rocket
    if next(tick_task.seated_passengers) then
      local surface = tick_task.rocket_entity.surface
      local track_position = {
        x = tick_task.rocket_entity.position.x,
        y = tick_task.rocket_entity.position.y - 2 - math.max(0, tick_task.launch_timer - Launchpad.time_takeoff) / 64}
      for _, seated_passenger in pairs(tick_task.seated_passengers) do
        Spectator.track_seat(seated_passenger, surface, tick_task.rocket_entity.position)
        Spectator.track_player(seated_passenger, surface, track_position)
      end
    end

    if tick_task.launch_timer >= Launchpad.time_takeoff_finish_ascent then
      -- skip to next phase
      tick_task.launch_timer = nil
    end

  else
    -- skip to next phase
    tick_task.launch_timer = nil
  end
end

-- Phase 2, transition to descent
---@param tick_task CargoRocketTickTask
function Launchpad.tick_journey_transition(tick_task)
  tick_task.land_timer = 0
  -- setup next landing sequence

  local from_surface

  if tick_task.rocket_entity and tick_task.rocket_entity.valid then
    from_surface = tick_task.rocket_entity.surface
    tick_task.rocket_entity.destroy()
    tick_task.rocket_entity = nil
    tick_task.struct.rocket_entity = nil
  end
  -- reset the landing pad
  local struct = tick_task.struct
  if struct and struct.valid then
    struct.launched_contents = nil
    if struct.launched_inventory and struct.launched_inventory.valid then
      struct.launched_inventory.destroy()
      struct.launched_inventory = nil
    end
    struct.launch_status = -1
    struct.launching_to_destination = nil
    struct.has_inserted_dummy = nil
    storage.forces[tick_task.force_name].cargo_rockets_launched = (storage.forces[tick_task.force_name].cargo_rockets_launched or 0) + 1
  end

  --game.print("Dev note: Show capsule landing sequence and discarded rocket part debris falling from the sky.")

  -- determine success rate

  -- for landing pad:
  -- show capsule descent over the pad, then put capsule inside the pad and player outside.
  -- show up to 10 cargo pods the fly past to the landing pad first.
  -- failed cargo pods are added to crash debris.
  -- crash debris based on recovery tech.
  -- put some recovered parts in the landing pad based on recovery tech.
  -- no fire from spilt fuel

  --for general location or guidance failure
  -- show capsule descent at random locaiton then put player outside.
  -- show up to 10 cargo pods the fly past to random locations
  -- failed cargo pods are added to crash debris.
  -- all rocket parts added to crash debris regardless of recovery tech.
  -- add fire from spilt fuel
  -- add some wider area explosive damage

  local is_landingpad = (tick_task.launching_to_destination.landing_pad and tick_task.launching_to_destination.landing_pad.container and tick_task.launching_to_destination.landing_pad.container.valid)
  if is_landingpad then
    local error_chance = Launchpad.get_survivability_loss(game.forces[tick_task.force_name], tick_task.launching_to_destination.zone, tick_task.delta_v)
    if math.random() < error_chance then
      -- off course
      is_landingpad = false
      local force = tick_task.launching_to_destination.landing_pad.container.force
      if from_surface then --surface may have been deleted already
        force.get_item_production_statistics(from_surface).on_flow(Launchpad.name_rocket_section, -Launchpad.rocket_sections_per_rocket)
      end
      Landingpad.remove_inbound(tick_task.launching_to_destination.landing_pad, "cargo-rocket")
      tick_task.launching_to_destination.attempted_position = tick_task.launching_to_destination.landing_pad.container.position
      tick_task.launching_to_destination.attempted_landing_pad = tick_task.launching_to_destination.landing_pad
      tick_task.launching_to_destination.landing_pad = nil
      local new_pos = tick_task.launching_to_destination.position
      new_pos.x = new_pos.x + (math.random() - 0.5) * 150
      new_pos.y = new_pos.y + (math.random() - 0.5) * 128
      tick_task.launching_to_destination.position = Zone.find_zone_landing_position(tick_task.launching_to_destination.zone, new_pos)
      force.print({"space-exploration.rocket_survivability_fail", "[gps="..math.floor(new_pos.x)..","..math.floor(new_pos.y)..","..Zone.get_surface_name(tick_task.launching_to_destination.zone).."]"})

    end
  end

  local cargo_loss = Launchpad.get_cargo_loss(game.forces[tick_task.force_name],  tick_task.launching_to_destination.zone, tick_task.delta_v)
  if is_landingpad then
    cargo_loss = cargo_loss / 2
  end
  local keep_percent = 1 - cargo_loss
  if tick_task.launched_inventory and tick_task.launched_inventory.valid then
    Log.debug("Loss launched_inventory")
    -- remove items from the inventory directly

    for _, item in pairs(tick_task.launched_contents) do
      local item_type = prototypes.item[item.name]
      if item_type and item.count > 1 and item_type.stack_size > 1 then
        local loss = cargo_loss * 2 * math.random() -- +/- 100%
        local lost_items = math.floor(item.count * loss)
        if lost_items > 0 then
          tick_task.launched_inventory.remove({name = item.name, count = lost_items, quality=item.quality})
        end
      end
    end
  end

  if (not is_landingpad) and tick_task.struct then
      -- Raise an event on padless landing
      local padless_struct = Launchpad.export_launchpad(tick_task.struct)
      padless_struct.destination_position = tick_task.launching_to_destination.position
      script.raise_event(Launchpad.on_cargo_rocket_padless_event, padless_struct)
  end

  -- cargo loss should never go above 90%, it can be below 10% round up for number of crashing pods.
  local total_pods = 10
  local crashing_pods = math.floor(total_pods * cargo_loss + 0.49)
  local safe_pods = total_pods - crashing_pods
  local pods = {}

  local target_surface = Zone.get_make_surface(tick_task.launching_to_destination.zone)
  Zone.apply_markers(tick_task.launching_to_destination.zone) -- in case the surface exists

  for i = 1, safe_pods do
    table.insert(pods, {type = "safe"})
  end
  for i = 1, crashing_pods do
    table.insert(pods, {type = "crash"})
  end
  pods = Util.shuffle(pods)

  local landing_start_altitude = Launchpad.landing_start_altitude
  if Zone.is_space(tick_task.launching_to_destination.zone) then
    landing_start_altitude = landing_start_altitude * 0.5
  end

  local target_pos = Landingpad.get_target_pos(tick_task.launching_to_destination)

  local start_position_x_offset = landing_start_altitude * (math.random() - 0.5) -- gives an angle to all pieces
  local start_position = Util.vectors_add(target_pos, {
    x = start_position_x_offset,
    y = - landing_start_altitude})
  local start_position_shadow = Util.vectors_add(target_pos, {
    x = start_position_x_offset + landing_start_altitude,
    y = 0})

  tick_task.safe_pods = {}
  for i, pod in pairs(pods) do

    local falling_time = Launchpad.time_landing_cargopod_first
      + (Launchpad.time_landing_cargopod_last - Launchpad.time_landing_cargopod_first) * (i - 1) / (total_pods - 1)
    local land_position
    if pod.type == "safe" and is_landingpad then
      land_position = target_pos
    else
      local offset
      if tick_task.launching_to_destination.fixed_pod_offset and tick_task.launching_to_destination.fixed_pod_offset[i] then
        offset = tick_task.launching_to_destination.fixed_pod_offset[i]
      else
        offset = {x = 32 * (math.random() - 0.5), y = 32 * (math.random() - 0.5)}
        --don't land pods directly on top of capsule
        if offset.x ^ 2 + offset.y ^ 2 <= 2 then
          offset = util.vector_set_length(offset, 2)
        end
      end
      land_position = Util.vectors_add(tick_task.launching_to_destination.position, offset)
    end
    local flat_distance = Util.vectors_delta_length(start_position, land_position)
    local flat_distance_shadow = Util.vectors_delta_length(start_position_shadow, land_position)
    local speed = flat_distance / falling_time
    local speed_shadow = flat_distance_shadow / falling_time

    if pod.type == "safe" then
      -- track the safe ones for adding items
      local entity = target_surface.create_entity{
        name = mod_prefix .. "falling-cargo-pod",
        position = start_position,
        target = land_position,
        speed = speed,
        max_rage = flat_distance,
      }
      ---@cast entity -?
      entity.orientation = 0
      table.insert(tick_task.safe_pods, {falling_entity=entity, land_position = land_position})
      target_surface.create_entity{
        name = mod_prefix .. "shadow-cargo-pod",
        position = start_position_shadow,
        target = land_position,
        speed = speed_shadow,
        max_rage = flat_distance_shadow,
      }
    else
      target_surface.create_entity{
        name = mod_prefix .. "falling-" .. Launchpad.names_cargo_fragment[(i % #Launchpad.names_cargo_fragment) + 1],
        position = start_position,
        target = land_position,
        speed = speed,
        max_rage = flat_distance,
      }
      target_surface.create_entity{
        name = mod_prefix .. "shadow-" .. Launchpad.names_cargo_fragment[(i % #Launchpad.names_cargo_fragment) + 1],
        position = start_position_shadow,
        target = land_position,
        speed = speed_shadow,
        max_rage = flat_distance_shadow,
      }
    end
  end

  if not is_landingpad then
    for i = 1, Launchpad.rocket_fragments_large do
      Launchpad.drop_rocket_fragment(tick_task.launching_to_destination.zone, 4, Launchpad.names_rocket_fragments_large[(i % #Launchpad.names_rocket_fragments_large) + 1],
        tick_task.launching_to_destination.position,
        start_position_x_offset)
    end
    for i = 1, Launchpad.rocket_fragments_medium do
      Launchpad.drop_rocket_fragment(tick_task.launching_to_destination.zone, 3, Launchpad.names_rocket_fragments_medium[(i % #Launchpad.names_rocket_fragments_medium) + 1],
        tick_task.launching_to_destination.position,
        start_position_x_offset)
    end
    for i = 1, Launchpad.rocket_fragments_small do
      Launchpad.drop_rocket_fragment(tick_task.launching_to_destination.zone, 2, Launchpad.names_rocket_fragments_small[(i % #Launchpad.names_rocket_fragments_small) + 1],
        tick_task.launching_to_destination.position,
        start_position_x_offset)
    end
    for i = 1, Launchpad.rocket_fragments_tiny do
      Launchpad.drop_rocket_fragment(tick_task.launching_to_destination.zone, 1, Launchpad.names_rocket_fragments_tiny[(i % #Launchpad.names_rocket_fragments_tiny) + 1],
        tick_task.launching_to_destination.position,
        start_position_x_offset)
    end
  end

  -- capsule
  tick_task.capsule = target_surface.create_entity{
    name = Capsule.name_space_capsule_vehicle,
    position=start_position,
    force = tick_task.force_name,
    raise_built = false,
  }
  tick_task.capsule.destructible = false
  tick_task.capsule_shadow = target_surface.create_entity{name = Capsule.name_space_capsule_vehicle_shadow, position=start_position_shadow, force = "neutral"}
  tick_task.capsule_light = target_surface.create_entity{name = Capsule.name_space_capsule_vehicle_light, position=start_position,
    speed = 0, target = tick_task.capsule}


  for _, seated_passenger in pairs(tick_task.seated_passengers) do
    Spectator.track(seated_passenger, target_surface, tick_task.capsule.position)
  end
  -- end landing sequence setup
end

-- Phase 3, descent
---@param tick_task CargoRocketTickTask
function Launchpad.tick_journey_descend(tick_task)
  -- continuation for landing sqequence
  tick_task.land_timer = tick_task.land_timer + 1

  local time_remaining = math.max(1, Launchpad.time_landing_capsule_touchdown - tick_task.land_timer)
  local target_pos = Landingpad.get_target_pos(tick_task.launching_to_destination)

  --local capsule_target_pos = tick_task.launching_to_destination.attempted_position or target_pos
  -- when capsule were not deconstructible they would always go to the landing pad.
  local capsule_target_pos = target_pos

  --local travel = Util.vector_multiply(Util.vectors_delta(tick_task.capsule.position, target_pos), 1 / time_remaining)
  --local travel_shadow = Util.vector_multiply(Util.vectors_delta(tick_task.capsule_shadow.position, target_pos), 1 / time_remaining)

  if not(tick_task.capsule and tick_task.capsule.valid) then
    local target_surface = Zone.get_make_surface(tick_task.launching_to_destination.zone)
    tick_task.capsule = target_surface.create_entity{
      name = Capsule.name_space_capsule_vehicle,
      position={x = capsule_target_pos.x, y = capsule_target_pos.y - Launchpad.landing_start_altitude * time_remaining / Launchpad.time_landing_capsule_touchdown},
      force = tick_task.force_name,
      raise_built = true,
    }
  end
  tick_task.capsule.destructible = true

  local travel = Util.vector_multiply(Util.vectors_delta(tick_task.capsule.position, capsule_target_pos), math.min(0.9, 2 / time_remaining))
  local animation_speed = 1/3
  local animation_frames = 24
  local animation_frame = math.max(math.min(math.floor(time_remaining * animation_speed), animation_frames), 1)

  tick_task.capsule.teleport(Util.vectors_add(tick_task.capsule.position, travel))
  tick_task.capsule.orientation = (animation_frame - 1) / animation_frames --[[@as float]]

  if tick_task.capsule_light and tick_task.capsule_light.valid then
    tick_task.capsule_light.teleport(tick_task.capsule.position)
  end

  if tick_task.capsule_shadow and tick_task.capsule_shadow.valid then
    local travel_shadow = Util.vector_multiply(Util.vectors_delta(tick_task.capsule_shadow.position, capsule_target_pos), math.min(0.9, 2 / time_remaining))
    tick_task.capsule_shadow.teleport(Util.vectors_add(tick_task.capsule_shadow.position, travel_shadow))
    tick_task.capsule_shadow.graphics_variation = animation_frame
  end

  for _, safe_pod in pairs(tick_task.safe_pods) do
    if safe_pod.falling_entity then
      if not safe_pod.falling_entity.valid then
        safe_pod.falling_entity = nil
        if tick_task.launching_to_destination.landing_pad and tick_task.launching_to_destination.landing_pad.valid then
          --tick_task.launching_to_destination.landing_pad.container.insert{name = Launchpad.name_cargo_pod, count = 1} -- we have rocket parts instead
          --tick_task.launching_to_destination.landing_pad.container.force.get_item_production_statistics(**needs surface**).on_flow(Launchpad.name_cargo_pod, 1)
        else
          safe_pod.cargo_entity = tick_task.capsule.surface.create_entity{
            name = Launchpad.name_cargo_pod,
            position = safe_pod.land_position,
            force = tick_task.force_name,
            preserve_ghosts_and_corpses = true
          }
        end
      end
    end
  end

  for _, seated_passenger in pairs(tick_task.seated_passengers) do
    Spectator.track_seat(seated_passenger, tick_task.capsule.surface, tick_task.capsule.position)
    Spectator.track_player(seated_passenger, tick_task.capsule.surface, {x = tick_task.capsule.position.x, y = tick_task.capsule.position.y + 0.5})
  end

end

local item_contains_spidertron = core_util.list_to_map(util.get_item_names_for_entity_types("spider-vehicle"))

-- Phase 4, landing
---@param tick_task CargoRocketTickTask
function Launchpad.tick_journey_land(tick_task)
  for _, seated_passenger in pairs(tick_task.seated_passengers) do
    Spectator.stop(seated_passenger)

    if seated_passenger.character.valid then
      if seated_passenger.character and seated_passenger.character.valid then
        local position = (tick_task.capsule and tick_task.capsule.valid) and tick_task.capsule.position or seated_passenger.character.position
        position.y = position.y + 1
        teleport_non_colliding(seated_passenger.character, position)
      end
      if seated_passenger.player and seated_passenger.player.valid then
        local playerdata = get_make_playerdata(seated_passenger.player)
        playerdata.zero_velocity = true
        seated_passenger.player.print({"space-exploration.respawn-if-stranded"})
      end
    end
  end

  if tick_task.launching_to_destination.landing_pad and tick_task.launching_to_destination.landing_pad.valid then
    -- going to a landing pad
    tick_task.capsule.destroy()
    if tick_task.capsule_light and tick_task.capsule_light.valid then
      tick_task.capsule_light.destroy()
    end
    if tick_task.capsule_shadow and tick_task.capsule_shadow.valid then
      tick_task.capsule_shadow.destroy()
    end

    local launched_inventory = tick_task.launched_inventory
    if launched_inventory and launched_inventory.valid then
      local pad_inventory = tick_task.launching_to_destination.landing_pad.container.get_inventory(defines.inventory.chest) ---@cast pad_inventory -?
      local min_slots = math.min(#launched_inventory, #pad_inventory)
      if pad_inventory.is_empty() then -- Most common case, use the faster transfer_stack()
        Log.debug("Landing pad transfer_stack")
        for i = 1, min_slots do
          pad_inventory[i].transfer_stack(launched_inventory[i])
        end
        pad_inventory.insert{name = Capsule.name_space_capsule, count = 1}
      else -- Can only happen for manual launches, use insert() which is much slower but won't overwrite existing inventory
        Log.debug("Landing pad insert")
        pad_inventory.insert{name = Capsule.name_space_capsule, count = 1} -- Priority to the capsule, in case there's not enough space
        for i = 1, min_slots do
          pad_inventory.insert(launched_inventory[i])
        end
      end
      launched_inventory.clear()
      launched_inventory.destroy()
      tick_task.launched_inventory = nil
    end

    local reusability = Launchpad.get_reusability(game.forces[tick_task.force_name])
    local sections_used = tick_task.rocket_sections_used or Launchpad.rocket_sections_per_rocket
    local reusable_parts = math.floor(math.min(sections_used, sections_used * reusability * ( 0.9 + 0.2 * math.random())))
    if reusable_parts > 0 then
      tick_task.launching_to_destination.landing_pad.container.insert{name = Launchpad.name_rocket_section, count = reusable_parts}
      -- tick_task.launching_to_destination.landing_pad.container.force.get_item_production_statistics(**needs surface**).on_flow(Launchpad.name_rocket_section, reusable_parts)
    end
    if reusable_parts < Launchpad.rocket_sections_per_rocket then
      tick_task.launching_to_destination.landing_pad.container.force.get_item_production_statistics(tick_task.launching_to_destination.landing_pad.container.surface).on_flow(Launchpad.name_rocket_section, -(Launchpad.rocket_sections_per_rocket - reusable_parts))
    end
    Landingpad.remove_inbound(tick_task.launching_to_destination.landing_pad, "cargo-rocket")
  else
    if tick_task.launched_inventory and tick_task.launched_inventory.valid then
      Log.debug("Distribute to pods launched_inventory")


      local valid_spidertrons = {}

      for idx, item in pairs(tick_task.launched_contents) do
        if item_contains_spidertron[item.name] then
          table.insert(valid_spidertrons, {item=item, idx=idx})
        end
      end

      if next(valid_spidertrons) and next(tick_task.safe_pods) then
        local spidertron_item = util.random_from_array(valid_spidertrons)
        local spidertron_name = spidertron_item.item.name -- If several spidertron types, pick a random one
        local spider_item = tick_task.launched_inventory.find_item_stack(spidertron_name)
        local pod = tick_task.safe_pods[#tick_task.safe_pods]
        local spider = pod.cargo_entity.surface.create_entity{
          name = spider_item.prototype.place_result.name,
          position = pod.cargo_entity.position,
          force = pod.cargo_entity.force,
          raise_built = true,
          item = spider_item -- Keep spidertron name, color, grid, and filters
        }

        if spider then
          tick_task.launched_contents[spidertron_item.idx].count = tick_task.launched_contents[spidertron_item.idx].count - 1
          if spider_item.count == 1 then
            tick_task.launched_inventory.remove(spider_item)
          else
            -- Stackable spidertron from another mod. Should not be able to have entity data, so we can delete any in the stack.
            tick_task.launched_inventory.remove{name = spidertron_name, count = 1}
          end

          -- the auto-deconstruction is a problem for the spider, clear nearby deconstruction orders.
          tick_task.spider = spider

          local inventory = spider.get_inventory(defines.inventory.car_trunk)
          if inventory then
            local take_item_stacks = {}

            if inventory.is_filtered() then
              -- This spidertron has filters already set, take items to fill the filters
              for i = 1, #inventory do
                local filter = inventory.get_filter(i)
                if filter then
                  table.insert(take_item_stacks, filter)
                end
              end
            else
              -- This spidertron has no filters set, set filters and take items that are both in the rocket and in the default filter list
              local inventory_slot_i = 1
              local inventory_size = #inventory
              for _, item in pairs(storage.spidertron_default_item_filters) do
                for _, content in pairs(tick_task.launched_contents) do
                  if content.name == item and content.count > 0 and inventory_slot_i <= inventory_size then
                    inventory.set_filter(inventory_slot_i, item)
                    inventory_slot_i = inventory_slot_i + 1
                    table.insert(take_item_stacks, item)
                    break
                  end
                end
              end
            end

            -- If the spidertron needs fuel, attempt to take it
            if spider.burner then
              local filter = {}
              for fuel_category, _ in pairs(spider.burner.fuel_categories) do
                table.insert(filter, {filter = "fuel-category", ["fuel-category"]=fuel_category})
              end
              local fuel_items = prototypes.get_item_filtered(filter)
              for fuel_name, _ in pairs(fuel_items) do
                table.insert(take_item_stacks, fuel_name)
              end
            end

            Log.debug_log("Spidertron deployment: take_item_stacks = " .. serpent.line(take_item_stacks))

            -- Attempt to take 1 stack from the rocket for each item in take_item_stacks list
            for _, item in pairs(take_item_stacks) do
              for _, content in pairs(tick_task.launched_contents) do
                if content.name == item and content.count > 0 then
                  local stack_size = prototypes.item[item].stack_size
                  local remove = math.min(content.count, stack_size)
                  content.count = content.count - remove
                  tick_task.launched_inventory.remove{name = item, count = remove}
                  spider.insert{name = item, count = remove} -- This will automatically insert fuel/ammo into the fuel/weapon slots if needed
                  break
                end
              end
            end
          end
        end
      end

      for i = 1, #tick_task.launched_inventory do
        for j = 0, #tick_task.safe_pods do
          local pod = tick_task.safe_pods[((i + j) % #tick_task.safe_pods) + 1]
          local stack = tick_task.launched_inventory[i]
          if pod and pod.cargo_entity and pod.cargo_entity.valid and stack and stack.valid and stack.valid_for_read and stack.count then
            local inserted = pod.cargo_entity.insert(tick_task.launched_inventory[i])
            if inserted == stack.count then
              tick_task.launched_inventory[i].clear()
            else
              tick_task.launched_inventory[i].count = stack.count - inserted
            end
          end
        end
      end
      tick_task.launched_inventory.clear()
      tick_task.launched_inventory.destroy()
      tick_task.launched_inventory = nil
    end

    for _, pod in pairs(tick_task.safe_pods) do
      if pod and pod.cargo_entity and pod.cargo_entity.valid and not tick_task.spider then
        pod.cargo_entity.order_deconstruction(tick_task.force_name)
      end
    end

    -- Ensure shadow gets found by the space capsule container's creation handler
    if tick_task.capsule_shadow.valid then
      tick_task.capsule_shadow.teleport(tick_task.capsule.position)
    end

    -- on ground
    local container = tick_task.capsule.surface.create_entity{
      name=Capsule.name_space_capsule_container,
      position=tick_task.capsule.position,
      force=tick_task.capsule.force,
      raise_built=true,
      preserve_ghosts_and_corpses=true
    }
    --**FIXME** need nil check here since raise_built = true
    if not tick_task.spider then
      container.order_deconstruction(tick_task.force_name)
    end
  end

  tick_task.capsule.destroy()

  tick_task.launched_contents = nil
  if tick_task.launched_inventory and tick_task.launched_inventory.valid then
    tick_task.launched_inventory.destroy()
  end
  tick_task.launched_inventory = nil

  tick_task.valid = false -- close tick task
end

---@param tick_task CargoRocketTickTask
function Launchpad.tick_journey(tick_task)
  -- from tick_task.type = "launchpad-journey"
  if tick_task.launch_timer then
    Launchpad.tick_journey_ascend(tick_task)
  else
    -- Phase 2 (+)
    if not tick_task.land_timer then
      Launchpad.tick_journey_transition(tick_task)
    else
      if tick_task.land_timer <= Launchpad.time_landing_capsule_touchdown then
        Launchpad.tick_journey_descend(tick_task)
      else
        Launchpad.tick_journey_land(tick_task)
      end
    end

  end

end

---@param event EventData.on_player_driving_changed_state Event data
function Launchpad.on_player_driving_changed_state(event)
  local player = game.get_player(event.player_index)
  if player then
    local open = false
    if player.vehicle and player.vehicle.name == Launchpad.name_rocket_launch_pad_seat then

      if player.character then
        remote.call("jetpack", "stop_jetpack_immediate", {character = player.character})
      end

      local armor_inv = player.get_inventory(defines.inventory.character_armor)
      if not(armor_inv and armor_inv[1] and armor_inv[1].valid_for_read and Util.table_contains(name_thruster_suits, armor_inv[1].name)) then
        player.print({"space-exploration.launch-suit-warning"})
      end

      local launch_pad_entity = player.surface.find_entities_filtered{
        limit = 1,
        position=util.vectors_add(event.entity.position, {x=0, y=-Launchpad.seat_y_offset}),
        name = Launchpad.name_rocket_launch_pad
      }[1]
      if launch_pad_entity then
        player.opened = Launchpad.from_entity(launch_pad_entity).container
        open = true
      end
    end
    if not open then
      LaunchpadGUI.gui_close(player)
      if player.opened_gui_type == defines.gui_type.entity and player.opened and player.opened.name == Launchpad.name_rocket_launch_pad then
        player.opened = nil
      end
    end
  end
end
Event.addListener(defines.events.on_player_driving_changed_state, Launchpad.on_player_driving_changed_state)

--- Creates the composite entity when the launch pad is made
--- Does not handle clone_area in any acceptable manner
--- (it doesn't listen to on_cloned and even if it did it
--- would start duplicated entities)
--- TODO: maybe make it support cloning by get_make the entities
--- instead of making them every time
---@param event EntityCreationEvent|EventData.on_entity_cloned Event data
function Launchpad.on_entity_created(event)
  local entity = event.entity or event.destination
  if not entity.valid or entity.name ~= Launchpad.name_rocket_launch_pad then return end

  local force_name = entity.force.name
  local surface = entity.surface
  local zone = Zone.from_surface(surface)
  local position = entity.position

  if cancel_creation_when_invalid(zone, entity, event) then return end
  ---@cast zone -?

  local default_name = zone.name
  local default_destination_zone = zone

  if zone.orbit then
    ---@type OrbitType
    default_destination_zone = zone.orbit
  elseif zone.parent and zone.parent.type ~= "star" then
    ---@type PlanetType|MoonType
    default_destination_zone = zone.parent
  end

  ---@type RocketLaunchPadInfo
  local struct = {
    type = Launchpad.name_rocket_launch_pad,
    valid = true,
    force_name = force_name,
    unit_number = entity.unit_number,
    container = entity,
    name = default_name,
    rocket_sections = 0,
    crew_capsules = 0,
    launch_trigger = "none",
    lua_fuel = 0,
    total_fuel = 0,
    zone = zone,
    destination = {
      zone = default_destination_zone
    },
    launch_status = -1
  }

  storage.rocket_launch_pads[entity.unit_number] = struct
  Log.debug("Launchpad: launch_pad added")

  Launchpad.name(struct) -- assigns to zone_assets

  -- Set inventory filters
  local inv = entity.get_inventory(defines.inventory.chest) --[[@as LuaInventory]]
  if event.name ~= defines.events.on_entity_cloned then
    inv.set_filter(Launchpad.rocket_capacity - 1, Launchpad.name_rocket_section)
    inv.set_filter(Launchpad.rocket_capacity, Capsule.name_space_capsule)
  end

  -- Constant combinator
  struct.combinator = util.find_entity_or_revive_ghost(surface,
      Launchpad.name_rocket_launch_pad_combinator, position) or
    surface.create_entity{
      name = Launchpad.name_rocket_launch_pad_combinator,
      force = entity.force,
      position = position
    }
    local wirecon_green = entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    local wirecon_red = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    wirecon_green.connect_to(struct.combinator.get_wire_connector(defines.wire_connector_id.circuit_green, true), false, defines.wire_origin.script)
    wirecon_red.connect_to(struct.combinator.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script)
    struct.combinator.destructible = false

  -- Rocket silo
  local silo_position = {position.x, position.y + 1/32} -- 1 px down to be in front of container
  struct.silo = util.find_entity_or_revive_ghost(surface,
      Launchpad.name_rocket_launch_pad_silo, silo_position, 0.1) or
    surface.create_entity{
      name = Launchpad.name_rocket_launch_pad_silo,
      force = entity.force,
      position = silo_position
    }
  struct.silo.destructible = false

  -- Storage tank
  local tank_position = {position.x, position.y + 1} -- 1 tile down to be in front of silo
  struct.tank = util.find_entity_or_revive_ghost(entity.surface,
      Launchpad.name_rocket_launch_pad_tank, tank_position) or
    surface.create_entity{
      name = Launchpad.name_rocket_launch_pad_tank,
      force = entity.force,
      position = tank_position
    }
  local wirecon_green = entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
  local wirecon_red = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  wirecon_green.connect_to(struct.tank.get_wire_connector(defines.wire_connector_id.circuit_green, true), false, defines.wire_origin.script)
  wirecon_red.connect_to(struct.tank.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script)
  struct.tank.destructible = false

  -- Seat vehicles
  Launchpad.get_make_seats(struct)

  -- Set settings
  local tags = util.get_tags_from_event(event, Launchpad.serialize)
  if tags then Launchpad.deserialize(entity, tags) end

  -- Open GUI
  if event.player_index then
    local player = game.get_player(event.player_index)
    ---@cast player -?
    LaunchpadGUI.gui_open(player, struct)
  end

  -- First time hint
  if storage.forces[force_name] and (storage.forces[force_name].cargo_rockets_launched or 0) == 0 then
    game.forces[force_name].print({"space-exploration.cargo-rocket-first-hint"})
  end
end
Event.addListener(defines.events.on_entity_cloned, Launchpad.on_entity_created)
Event.addOnEntityCreatedListeners(Launchpad.on_entity_created)

---@param struct RocketLaunchPadInfo
---@return LuaEntity[]
function Launchpad.get_make_seats(struct)
  struct.seats = struct.seats or {}
  local entity = struct.container
  for i = 1, 5 do
    local x = i - 3
    local seat_position = {entity.position.x + x, entity.position.y + Launchpad.seat_y_offset}
    local seat = util.find_entity_or_revive_ghost(entity.surface, Launchpad.name_rocket_launch_pad_seat, seat_position)
    if (not seat) and struct.seats[i] and struct.seats[i].valid then
      -- there is a seat but not in the correct place
      struct.seats[i].destroy()
    end
    if not (seat and seat.valid) then
      seat = entity.surface.create_entity{
        name = Launchpad.name_rocket_launch_pad_seat,
        force = entity.force,
        position = seat_position,
        direction = defines.direction.east
      }
      ---@cast seat -?
    end
    seat.destructible = false
    struct.seats[i] = seat
  end
  return struct.seats
end

---@param struct RocketLaunchPadInfo
---@return table<string, IndexMap<RocketLaunchPadInfo>>?
function Launchpad.get_struct_type_table(struct)
  local zone_assets = Zone.get_force_assets(struct.force_name, struct.zone.index)
  if struct.type == Launchpad.name_rocket_launch_pad then
    zone_assets.rocket_launch_pad_names = zone_assets.rocket_launch_pad_names or {}
    return zone_assets.rocket_launch_pad_names
  end
end

function Launchpad.get_tank_capacity()
  if not Launchpad.tank_capacity then
    local fluidbox_prototype = prototypes.entity[Launchpad.name_rocket_launch_pad_tank].fluidbox_prototypes[1]
    Launchpad.tank_capacity = fluidbox_prototype.volume
  end
  return Launchpad.tank_capacity
end

local fragment_names = { -- todo: lookup automatically from prototypes
  [mod_prefix .. "static-" .. "rocket-fragment-big-a"] =     true,
  [mod_prefix .. "static-" .. "rocket-fragment-big-b"] =     true,
  [mod_prefix .. "static-" .. "rocket-fragment-big-c"] =     true,
  [mod_prefix .. "static-" .. "rocket-fragment-big-d"] =     true,
  [mod_prefix .. "static-" .. "rocket-fragment-medium-a"] =  true,
  [mod_prefix .. "static-" .. "rocket-fragment-medium-b"] =  true,
  [mod_prefix .. "static-" .. "rocket-fragment-medium-c"] =  true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-a"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-b"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-c"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-d"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-e"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-f"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-g"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-h"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-i"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-small-j"] =   true,
  [mod_prefix .. "static-" .. "rocket-fragment-tiny-a"] =    true,
  [mod_prefix .. "static-" .. "rocket-fragment-tiny-b"] =    true,
  [mod_prefix .. "static-" .. "rocket-fragment-tiny-c"] =    true,
  [mod_prefix .. "static-" .. "rocket-fragment-tiny-d"] =    true,
  [mod_prefix .. "static-" .. "rocket-fragment-tiny-e"] =    true,
  [mod_prefix .. "static-" .. "rocket-fragment-tiny-f"] =    true,

  [mod_prefix .. "static-" .. "cargo-fragment-a"] =          true,
  [mod_prefix .. "static-" .. "cargo-fragment-b"] =          true,
  [mod_prefix .. "static-" .. "cargo-fragment-c"] =          true,
  [mod_prefix .. "static-" .. "cargo-fragment-d"] =          true,
}

---Mark fallen rocket fragments for deconstruction
---@param event EventData.on_script_trigger_effect Event data
function Launchpad.on_script_trigger_effect(event)
  if not fragment_names[event.effect_id] then return end

  local surface = game.get_surface(event.surface_index)
  local position = event.target_position
  local entity = surface.create_entity{
    name = event.effect_id,
    position = position,
    force = "neutral",
    preserve_ghosts_and_corpses = true, -- This little flag saves us from such a crazy hack!
  }

  -- Maybe mark it for deconstruction
  if entity then

    -- See if there's some entities or ghosts colliding with the created entity
    local colliding_entity --[[@as LuaEntity?]]
    for _, other_entity in pairs(surface.find_entities_filtered{area=entity.bounding_box}) do
        if not SystemForces.is_system_force(other_entity.force.name) then -- Also filters out created entity
          colliding_entity = other_entity
          break
        end
    end

    -- Always mark for deconstruction if there's a colliding entity or
    -- if inside a construction network
    if colliding_entity then
      entity.order_deconstruction(colliding_entity.force)
    else
      Util.conditional_mark_for_deconstruction({entity}, surface, position)
    end
  end
end
Event.addListener(defines.events.on_script_trigger_effect, Launchpad.on_script_trigger_effect)

---Removes this launchpad from the force assets
---@param struct table<string, IndexMap<RocketLaunchPadInfo>>
function Launchpad.remove_struct_from_table(struct)
  local type_table = Launchpad.get_struct_type_table(struct)
  if not (type_table and type_table[struct.name]) then return end
  type_table[struct.name][struct.unit_number] = nil
  if not next(type_table[struct.name]) then
    type_table[struct.name] = nil
  end
end

---@param struct RocketLaunchPadInfo
---@param key string
function Launchpad.destroy_sub(struct, key)
  if struct[key] and struct[key].valid then
    struct[key].destroy()
    struct[key] = nil
  end
end

---@param struct RocketLaunchPadInfo
---@param event? EntityRemovalEvent the event that triggered the destruction if it was caused by an event
function Launchpad.destroy(struct, event)
  if not struct then
    Log.debug("struct_destroy: no struct")
    return
  end

  struct.valid = false

  local capsules = struct.crew_capsules or 0
  local sections = struct.rocket_sections or 0

  if event and event.player_index then
    local player = game.get_player(event.player_index)
    if player and player.connected then
      if capsules > 0 then
          local inserted = player.insert{name = Capsule.name_space_capsule, count = capsules}
          capsules = capsules - inserted
      end
      if sections > 0 then
          local inserted = player.insert{name = Launchpad.name_rocket_section, count = sections}
          sections = sections - inserted
      end
    end
  end

  if struct.container and struct.container.valid then

    local position = struct.container.position
    local surface = struct.container.surface

    if capsules > 0 then
      surface.spill_item_stack{
        position = position,
        stack = {name = Capsule.name_space_capsule, count = capsules},
        enable_looted = true,
        force = struct.container.force,
        allow_belts = false
      }
    end

    if sections > 0 then
      surface.spill_item_stack{
        position = position,
        stack = {name = Launchpad.name_rocket_section, count = sections},
        enable_looted = true,
        force = struct.container.force,
        allow_belts = false
      }
    end
  end

  Launchpad.destroy_sub(struct, 'tank')
  Launchpad.destroy_sub(struct, 'silo')
  Launchpad.destroy_sub(struct, 'combinator')
  for _, seat in pairs(struct.seats or {}) do
    if seat and seat.valid then seat.destroy() end
  end
  struct.seats = nil
  Launchpad.remove_struct_from_table(struct)

  if not event then -- If event is supplied then it will already be destroyed
    Launchpad.destroy_sub(struct, 'container')
  end

  if not event or event.name ~= defines.events.on_entity_died then
    -- For died it will be cleaned in post_died event
    storage.rocket_launch_pads[struct.unit_number] = nil
  end

  -- if a player has this gui open then close it
  local gui_name = LaunchpadGUI.name_rocket_launch_pad_gui_root
  for _, player in pairs(game.connected_players) do
    local root = player.gui.relative[gui_name]
    if root and root.tags and root.tags.unit_number ==  struct.unit_number then
      root.destroy()
    end
  end
end

---@param struct RocketLaunchPadInfo
---@param new_name? string
function Launchpad.name(struct, new_name)
    struct.name = (new_name or struct.name)
    local type_table = Launchpad.get_struct_type_table(struct)
    type_table[struct.name] = type_table[struct.name] or {}
    type_table[struct.name][struct.unit_number] = struct
end

---@param struct RocketLaunchPadInfo
---@param new_name string
function Launchpad.rename(struct, new_name)
    Launchpad.remove_struct_from_table(struct)
    Launchpad.name(struct, new_name)
end

---@param struct RocketLaunchPadInfo
---@param landing_pad_name string
function Launchpad.set_destination(struct, landing_pad_name)
  if landing_pad_name and landing_pad_name ~= "" then
    struct.destination.landing_pad_name = landing_pad_name
    Log.debug("set destination to landing_pad " .. landing_pad_name )
  else
    struct.destination.landing_pad_name = nil
  end
end

---@param event EntityRemovalEvent Event data
function Launchpad.on_entity_removed(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == Launchpad.name_rocket_launch_pad then
    Launchpad.destroy(Launchpad.from_entity(entity), event )
  end
end
Event.addOnEntityRemovedListeners(Launchpad.on_entity_removed)

---@param event EventData.on_post_entity_died
local function on_post_entity_died(event)
  local ghost = event.ghost
  local unit_number = event.unit_number
  if not (ghost and unit_number) then return end
  if event.prototype.name ~= Launchpad.name_rocket_launch_pad then return end
  ghost.tags = Launchpad.serialize_from_struct(storage.rocket_launch_pads[unit_number])
  storage.rocket_launch_pads[unit_number] = nil
end
Event.addListener(defines.events.on_post_entity_died, on_post_entity_died)

---@param event EventData.on_tick Event data
function Launchpad.on_tick(event)
  -- handle launchpads
  for _, struct in pairs(storage.rocket_launch_pads) do
    if (struct.launch_status and struct.launch_status > 0) or (event.tick + struct.unit_number) % 60 == 0 then
      Launchpad.tick(struct)
    end
  end

  -- update guis
  if event.tick % 60 == 0 then
    for _, player in pairs(game.connected_players) do
      LaunchpadGUI.gui_update(player)
    end
  end
end
Event.addListener(defines.events.on_tick, Launchpad.on_tick)

---@param launch_pad RocketLaunchPadInfo?
---@return Tags?
function Launchpad.serialize_from_struct(launch_pad)
  if launch_pad then
    local tags = {}
    tags.name = launch_pad.name
    tags.launch_trigger = launch_pad.launch_trigger
    if launch_pad.destination.zone then
      tags.zone_name = launch_pad.destination.zone.name
    end
    if launch_pad.destination.landing_pad_name then
      tags.landing_pad_name = launch_pad.destination.landing_pad_name
    end
    return tags
  end
end

---@param entity LuaEntity
---@return Tags?
function Launchpad.serialize(entity)
  return Launchpad.serialize_from_struct(Launchpad.from_entity(entity))
end

---@param entity LuaEntity
---@param tags Tags
function Launchpad.deserialize(entity, tags)
  local launch_pad = Launchpad.from_entity(entity)
  if launch_pad then
    Launchpad.rename(launch_pad, tags.name)
    launch_pad.launch_trigger = tags.launch_trigger
    if tags.zone_name then
      launch_pad.destination.zone = Zone.from_name(tags.zone_name)
    else
      launch_pad.destination.zone = nil
    end
    if tags.landing_pad_name then
      launch_pad.destination.landing_pad_name = tags.landing_pad_name
    else
      launch_pad.destination.landing_pad_name = nil
    end
  end
end

--- Handles the player creating a blueprint by setting tags to store the state of launch pads
---@param event EventData.on_player_setup_blueprint Event data
function Launchpad.on_player_setup_blueprint(event)
  util.setup_blueprint(event, Launchpad.name_rocket_launch_pad, Launchpad.serialize)
end
Event.addListener(defines.events.on_player_setup_blueprint, Launchpad.on_player_setup_blueprint)

--- Handles the player copy/pasting settings between launch pads
---@param event EventData.on_entity_settings_pasted Event data
function Launchpad.on_entity_settings_pasted(event)
  util.settings_pasted(event, Launchpad.name_rocket_launch_pad, Launchpad.serialize, Launchpad.deserialize)
end
Event.addListener(defines.events.on_entity_settings_pasted, Launchpad.on_entity_settings_pasted)

function Launchpad.on_init()
    storage.rocket_launch_pads = {}
    storage.cache_rocket_fuel_cost = {}

end
Event.addListener("on_init", Launchpad.on_init, true)

return Launchpad
