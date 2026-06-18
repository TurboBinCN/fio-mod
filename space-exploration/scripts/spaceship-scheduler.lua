local SpaceshipScheduler = { }

--[[
  This is a scheduler for spaceships that allows managing them like trains with stops, wait-conditions, etc.
]]

SpaceshipScheduler.wait_for_launch_success_timeout = 2 * 60 * 60
SpaceshipScheduler.max_name_length = 200 -- Used for schedule groups and interrupt groups
SpaceshipScheduler.launch_to_next_retry_time = 5 * 60   -- This seems reasonable. Combinator ships might even take 10 seconds to launch

------------------------------------------------
-- UTIL
------------------------------------------------

---Create a new empty schedule where the spaceship is set to "Manual"
---It will always start by creating a new schedule_group for this specific spaceship.
---@param spaceship SpaceshipType
function SpaceshipScheduler.add_to_spaceship(spaceship)
  -- New spaceships are always unassigned, similar to trains.
  local schedule_group_name = SpaceshipScheduler.get_unassigned_group_name(spaceship)

  spaceship.scheduler = {
    active = false,
    schedule_group_name = schedule_group_name,
    schedule_index = 0,
    current_interrupts = { },
    state = "idle",
    record_satisfactions = { },
  }

  -- Create the new schedule_group
  SpaceshipScheduler.change_spaceship_schedule_group(spaceship, schedule_group_name)
end

---@param tick uint
---@param spaceship SpaceshipType
---@param state SpaceshipSchedulerState
function SpaceshipScheduler.change_state(tick, spaceship, state)
  assert(state)
  local scheduler = spaceship.scheduler
  scheduler.state = state
  scheduler.state_ticked = tick
  scheduler.first_time_in_state = true
  scheduler.no_existing_clamp = nil
  spaceship.scheduler.wait_until = nil -- Reset on every state change
  spaceship.scheduler.record_satisfactions = { } -- To make sure there's nothing cached
end

---Convenience function to get schedule of spaceship
---Be careful, don't change the table this function returns!
---@param spaceship SpaceshipType
---@return SpaceshipSchedule
function SpaceshipScheduler.get_schedule(spaceship)
  local scheduler = spaceship.scheduler
  local schedule_group = storage.spaceship_scheduler_groups[spaceship.force_name][scheduler.schedule_group_name]
  return schedule_group.schedule -- Should probably deep-copy to be safe, but this function will be used a lot
end

---Convenience function to get the current record that the scheduler
---is servicing. This can either be a record in the schedule or
---an interrupt that is currently active.
---@param spaceship SpaceshipType
---@return SpaceshipSchedulerRecord
function SpaceshipScheduler.get_current_record(spaceship)
  local scheduler = spaceship.scheduler
  local current_interrupt_target = scheduler.current_interrupts and next(scheduler.current_interrupts)
  if current_interrupt_target then
    return scheduler.current_interrupts[current_interrupt_target]
  end

  assert(scheduler.schedule_index ~= 0, "Code should never access a regular record when schedule_index is 0") -- It means there's a bug somewhere.
  return SpaceshipScheduler.get_schedule(spaceship)[scheduler.schedule_index]
end

---@param spaceship SpaceshipType
---@return SpaceshipSchedulerRecord? record if the spaceship is allowed to land
function SpaceshipScheduler.can_land(spaceship)
  local scheduler = spaceship.scheduler
  if not (scheduler.active and scheduler.state == "on-route") then return end
  local record = SpaceshipScheduler.get_current_record(spaceship)
  if record.slingshot then return end
  -- TODO As a fail-safe, make sure we are at the correct zone, and force a repath if we are not.
  return record
end

---Iterates this spaceships schedule smartly by including any potential
---interrupts and which record is currently active.
---@param spaceship SpaceshipType
---@param fn fun(record_index:uint, target_number:uint?, record:SpaceshipSchedulerRecord, is_current_record:boolean)
function SpaceshipScheduler.for_record_in_schedule(spaceship, fn)
  local scheduler = spaceship.scheduler
  local schedule = SpaceshipScheduler.get_schedule(spaceship)

  local current_interrupts = scheduler.current_interrupts or { }
  local active_interrupt_target = next(current_interrupts)

  if next(schedule) then
    for schedule_index, record in pairs(schedule) do

      local is_current_record = scheduler.active and not active_interrupt_target and schedule_index == scheduler.schedule_index
      fn(schedule_index, nil, record, is_current_record and scheduler.active)

      if schedule_index == scheduler.schedule_index and active_interrupt_target then
        -- Interrupts are always inserted after the current index
        for target_number, target in pairs(current_interrupts) do
          fn(schedule_index, target_number, target, target_number == active_interrupt_target and scheduler.active)
        end
      end
    end
  else
    for target_number, target in pairs(current_interrupts) do
      fn(1, target_number, target, target_number == active_interrupt_target and scheduler.active)
    end
  end
end

---@param spaceship SpaceshipType
---@return StarType? star_system the spaceship is restricted to
function SpaceshipScheduler.restricted_to_star_system(spaceship)
  local scheduler = spaceship.scheduler
  local schedule_group = storage.spaceship_scheduler_groups[spaceship.force_name][scheduler.schedule_group_name]
  if not schedule_group.restrict_to_star_system then return end
  local star = Zone.from_zone_index(schedule_group.restrict_to_star_system)
  assert(star and star.type == "star", "Invalid star-system index "..schedule_group.restrict_to_star_system)
  return star --[[@as StarType]]
end

------------------------------------------------
-- LOGIC
------------------------------------------------

---Activates the scheduler for a spaceship
---@param spaceship SpaceshipType
---@return boolean success
function SpaceshipScheduler.activate(spaceship)
  local scheduler = spaceship.scheduler
  if scheduler.active then return true end
  scheduler.active = true

  -- Reset some of the spaceship state
  spaceship.destination = nil
  SpaceshipScheduler.remove_current_interrupt_targets(spaceship)

  if scheduler.schedule_index == 0 then
    -- There are no records. Start idling
    SpaceshipScheduler.change_state(game.tick, spaceship, "idle")
  else
    -- We need to launch to the next destination. The scheduler will
    -- determine on the next update if this spaceship is already anchored
    -- at this stop, and in that case switch to `wait-at-stop`.
    SpaceshipScheduler.change_state(game.tick, spaceship, "launch-to-next")
  end

  return spaceship.scheduler.active
end

---Deactivates and stops the spaceship.
---@param spaceship SpaceshipType
function SpaceshipScheduler.deactivate(spaceship)
  if not spaceship.scheduler.active then return end -- Do nothing if it's already deactivated

  spaceship.scheduler.active = false
  spaceship.travel_message = nil

  SpaceshipScheduler.remove_current_interrupt_targets(spaceship)

  -- Make sure this ship is not reserved anywhere. Let's not take chances
  -- on it being left behind somewhere so we do a brutal remove.
  SpaceshipSchedulerReservations.forcibly_remove_all_reservations(spaceship)
  spaceship.scheduler.anchored_reservation = nil
  spaceship.scheduler.future_reservation = nil

  -- Stop spaceship. If the interaction that caused the deactivation requires the
  -- the spaceship to continue flying then it should be done after the deactivate command.
  spaceship.stopped = true
end

---Forces a repath of a spaceship. This will allow the spaceship to
---re-choose the best destination to go to. It will also correctly
---handle any reservations the spaceship might have.
---Used for example when the player clicks on a record in the GUI to go to.
---Note: Currently might result in a different spaceship taking the reservation this spaceship gave up.
---@param spaceship SpaceshipType
---@param record_index uint? if supplied will direct the spaceship to this new schedule (or interrupt) index
---@param temporary boolean? if the record index is a schedule index or interrupt index
function SpaceshipScheduler.force_repath(spaceship, record_index, temporary)
  local scheduler = spaceship.scheduler
  assert(not record_index or record_index > 0)

  -- We cannot currently reliably redirect a spaceship while it's waiting for launch success.
  -- The launch might happen, it might not. So we stop the launch first so that we have a known state.
  -- NOTE: This could trigger the "on_spaceship_launch_failed" event.
  Spaceship.stop_launch(spaceship)

  -- Conditionally remove current reservation
  if scheduler.future_reservation then
    -- Always remove the reservation the spaceship was on route to.
    SpaceshipSchedulerReservations.remove_reservation(scheduler.future_reservation)
    scheduler.future_reservation = nil
  end

  -- We never give up the anchored reservation unless the spaceship launches
  ---@TODO We could give it up here, and recheck if the spaceship is currently anchored?

  -- Set the new record index
  if record_index ~= nil then
    if not temporary then
      -- Forcing going to a different schedule record will always clear
      -- all interrupts
      SpaceshipScheduler.remove_current_interrupt_targets(spaceship)
      scheduler.schedule_index = record_index

    else
      -- If setting to a later interrupt target then earlier targets
      -- will be removed.
      SpaceshipScheduler.progress_interrupt_targets(spaceship, record_index)
    end
  end

  -- Force the repath. If there's an interrupt or valid records then we will launch to next
  if scheduler.schedule_index > 0 or (scheduler.current_interrupts and next(scheduler.current_interrupts)) then
    SpaceshipScheduler.change_state(game.tick, spaceship, "launch-to-next")
  else
    -- Otherwise set the ship to idle
    SpaceshipScheduler.change_state(game.tick, spaceship, "idle")
  end
end

---Starts the launch sequence for a spaceships towards a specific zone.
---Handles the all cases where the spaceship is currently landed, busy launching/landing,
---or already flying.
---@param spaceship SpaceshipType
---@param zone_index uint
---@return "already-launched"|"awaiting-launch"|"near"|"failed" launch_status
function SpaceshipScheduler.launch_spaceship_towards_zone(spaceship, zone_index)

  if Spaceship.is_on_own_surface(spaceship) then
    spaceship.stopped = false
    spaceship.target_speed = nil
    spaceship.target_speed_source = nil
    spaceship.destination = {type="zone", index=zone_index}

    -- The `near` field can also be set while the spaceship is landed.
    if spaceship.near and spaceship.near.type == "zone" and spaceship.near.index == zone_index then
      -- We are already near the zone we want to go to. Aim the ship to that zone
      -- and make sure it can move.
      return "near"

    else
      -- The spaceship is currently flying! Just change the destination I guess?
      return "already-launched"
    end

  elseif spaceship.awaiting_requests then
    --- The ship is busy launching. Can't do anything now.
    return "failed"

  else
    -- The spaceship is currently landed somewhere so we need to launch it!
    spaceship.travel_message = {"space-exploration.spaceship-travel-message-new-course-plotted"}
    spaceship.is_launching = true
    spaceship.is_landing = false
    spaceship.target_speed = nil
    spaceship.target_speed_source = nil
    spaceship.stopped = false

    -- We set the spaceship to launch automatically, similar to a combinator setup. This means
    -- that the launch will be delayed for one second to ensure the chunks are generated.
    -- Which means a scheduler launch will never be instantly.
    spaceship.is_launching_automatically = true

    spaceship.destination = {type="zone", index=zone_index}

    -- Technically the integrity could already be valid. However, maybe a player (**cough** BurninSun **cough**) did
    -- something weird which invalidates the integrity without triggering a recheck. Therefore always do it first to
    -- be safe, even though it costs a more UPS.
    SpaceshipIntegrity.start_integrity_check(spaceship)

    return "awaiting-launch"
  end
end

---Executes a function with each serviceable zone that this spaceship could reach
---@param spaceship SpaceshipType
---@param fn fun(zone_pointer:ZonePointer)
function SpaceshipScheduler.apply_for_each_serviceable_zone(spaceship, fn)
  local star_restriction = SpaceshipScheduler.restricted_to_star_system(spaceship)
  if star_restriction then

    Zone.apply_for_each_child_and_orbit(star_restriction, function(zone)
      fn(zone.index)
    end)

  else
    -- This spaceship can service any zone in the known universe

    for surface_name in pairs(storage.spaceship_clamps_by_surface) do
      local zone = Zone.from_surface_name(surface_name)
      if zone then fn(zone.index) end
    end

  end
end

---Find a destination zone that the scheduler can direct a ship to.
---It uses the reservation system to loop through zones and finds
---the best one dv-wise that fits the destination designation,
---with the prioritizing the highest priority.
---This function will likely only be called by the scheduler when a ship is looking for a destination.
---@param spaceship SpaceshipType
---@param destination_decriptor SpaceshipSchedulerDestinationDescriptor
---@return "success"|"doesnt-exist"|"occupied"
---@return SpaceshipClampInfo? (only when "success")
function SpaceshipScheduler.find_destination(spaceship, destination_decriptor)

  if destination_decriptor.zone_pointer then
    -- We are targetting a specific zone. So it would be a quick check if there is a open slot

    if destination_decriptor.zone_pointer <= 0 then
      return "doesnt-exist" -- Don't currently support flying to spaceships
    end

    -- First just double check that this zone exist
    local zone = Zone.from_zone_index(destination_decriptor.zone_pointer)
    if not zone then return "doesnt-exist" end -- Somehow this zone doesn't exist.

    -- Check the reservations for this zone
    local clamp_info, at_least_one_clamp =
        SpaceshipSchedulerReservations.zone_has_open_slot(spaceship, destination_decriptor, nil --[[minimum priority]])
    if not at_least_one_clamp then
      return "doesnt-exist"
    elseif not clamp_info then
      return "occupied"
    else
      return "success", clamp_info
    end

  else

    -- This spaceship can service multiple zones, so we will have to loop over all of them
    -- and find the best one to go to.

    local lowest_dv             --[[@as uint]]
    local highest_priority = 0  --[[@as uint]]
    local best_clamp            --[[@as SpaceshipClampInfo?]]
    local found_a_valid_clamp = false

    SpaceshipScheduler.apply_for_each_serviceable_zone(spaceship, function(zone_pointer)
      if zone_pointer <= 0 then return end -- Do not support spaceships yet

      destination_decriptor.zone_pointer = zone_pointer -- Useful for searching. Remember to revert.
      local clamp_info, found_a_valid_clamp_in_zone =
          SpaceshipSchedulerReservations.zone_has_open_slot(spaceship, destination_decriptor, highest_priority)
      if not found_a_valid_clamp_in_zone then return end
      found_a_valid_clamp = true
      if not clamp_info then return end

      -- Only ignoring lower priorities. Equal priorities will be compared later using dv
      if highest_priority > clamp_info.priority then return end

      -- Calculate the dv required to get to this zone
      -- If we ensure that as origin we use the surface zone and not the spaceship's zone (when possible)
      -- then the distance calculation will be cached. Nice! That means this operation will
      -- be fairly cheap in the steady state.
      local zone = storage.zone_index[zone_pointer]
      if not zone then return end -- Should never happen
      ---@cast zone -StarType
      local origin_zone = spaceship.zone_index and Zone.from_zone_index(spaceship.zone_index) or nil --[[@as AnyZoneType|SpaceshipType]]
      if not origin_zone then origin_zone = spaceship end -- Fall back to spaceship zone
      local dv = Zone.get_travel_delta_v(origin_zone, zone)

      -- If we reach here then this clamp has either the same or higher priority than the current best.
      -- We should go to the highest priority clamp always, regardless of distance. Therefore only
      -- check if this clamp is closer and discard if not _if_ the priorities are the same.
      if highest_priority == clamp_info.priority then
        if lowest_dv and dv > lowest_dv then return end -- This clamp is further away, ignore it
      end

      -- If we get here then we found a new best destination to go to.
      best_clamp = clamp_info
      lowest_dv = dv
      highest_priority = clamp_info.priority

    end)

    destination_decriptor.zone_pointer = nil -- Ensure it's reset to nil
    if not best_clamp then return found_a_valid_clamp and "occupied" or "doesnt-exist" end
    return "success", best_clamp
  end
end

---Basically calculates how much close the value is to the desired value based
---on the initial difference. It works regardless of a > b or not. It will always
---return zero on the first call when there is no cache yet. Note: This is just a
---best guess, as knowing what the numbers mean is impossible.
---@param a integer
---@param b integer
---@param satisfaction_cache {reference:integer?}? Only used if satisfaction is required for the GUI
---@return float satisfaction
local function fractional_circuit_satisfaction(a, b, satisfaction_cache)
  if not satisfaction_cache then return 0 end
  if not satisfaction_cache.reference then
    -- Cache will store the initial difference to that it can be used later as measuring stick
    satisfaction_cache.reference = math.abs(b - a)
    return 0
  elseif satisfaction_cache.reference == 0 then
    -- If condition starts near satisfied, and ends up getting worse then the cache will near infinity
    -- which means the fraction returned later will near zero, which is fine because there's
    -- nothing better to compare against.
    return 0
  end

  return 1 - math.min((math.abs(b - a) / satisfaction_cache.reference), 1)
end

---Convenient lookup table calculating the satisfaction level of a circuit condition
---@type table<string, fun(a:integer, b:integer, satisfaction_cache:{reference:integer?}):float>
local circuit_comparator_handlers = {
  ["="] = function(a, b, cache) return a == b and 1 or fractional_circuit_satisfaction(a, b, cache) end,
  ["≠"] = function(a, b, cache) return a ~= b and 1 or 0 end, -- Fractional doesn't make sense here
  [">"] = function(a, b, cache) return a  > b and 1 or fractional_circuit_satisfaction(a, b, cache) end,
  ["≥"] = function(a, b, cache) return a >= b and 1 or fractional_circuit_satisfaction(a, b, cache) end,
  ["<"] = function(a, b, cache) return a  < b and 1 or fractional_circuit_satisfaction(a, b, cache) end,
  ["≤"] = function(a, b, cache) return a <= b and 1 or fractional_circuit_satisfaction(a, b, cache) end,
}

---Resolve a circuit condition just like it's done in vanilla. It will also calculate
---the satisfaction level of the condition to be shown in the GUI. Currently this is calculated
---every time, even when the GUI is not shown.
---@param spaceship SpaceshipType
---@param condition CircuitCondition
---@param satisfaction_cache {reference:integer?}
---@return float satisfaction
local function resolve_circuit_condition(spaceship, condition, satisfaction_cache)
  local console = spaceship.console
  if not console then return 0 end

  if not condition.first_signal then return 0 end -- First signal wasn't specified
  local left = console.get_signal(condition.first_signal, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)

  local right = 0 -- Default
  if condition.second_signal then
    right = console.get_signal(condition.second_signal, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
  elseif condition.constant ~= nil then
    right = condition.constant
  else
    -- Neither a signal or constant was specified as the right term. Can therefore never be true
    return 0
  end
  --[[@cast right -? ]]

  return circuit_comparator_handlers[condition.comparator](left, right, satisfaction_cache)
end

---Determines if the wait conditions have been satisfied for the stop the
---spaceship is currently anchored at.
---@param tick uint the current tick
---@param spaceship SpaceshipType
---@param conditions WaitCondition[]?
---@param satisfaction_cache { satisfaction: number, reference: integer? }[]? Only used for GUI progress visualization
---@return boolean
local function conditions_satisfied(tick, spaceship, conditions, satisfaction_cache)

  -- If there are no wait conditions then it's always satisfied.
  if not (conditions and next(conditions)) then return true end

  local terms = { }
  for condition_index, condition in pairs(conditions) do

    -- If a satisfaction cache is given then this wait condition is shown in the main
    -- gui, meaning we will calculate the satisfaction level of the condition. If this is not
    -- supplied then it will be ignored
    local record_satisfaction_cache --[[@as { satisfaction: number, reference: integer? }[]?]]
    if satisfaction_cache then
      record_satisfaction_cache = satisfaction_cache[condition_index]
      if not record_satisfaction_cache then
        satisfaction_cache[condition_index] = { satisfaction = 0 }
        record_satisfaction_cache = satisfaction_cache[condition_index]
      end
    end

    local satisfied = false
    if condition.type == "time" then
      local end_tick = spaceship.scheduler.state_ticked + condition.ticks
      if tick > end_tick then
        satisfied = true
        if satisfaction_cache then satisfaction_cache[condition_index] = {satisfaction = 1} end
      else
        if record_satisfaction_cache then record_satisfaction_cache.satisfaction = 1 - (end_tick - tick) / condition.ticks end
      end
    elseif condition.type == "circuit" then
      local satisfaction = resolve_circuit_condition(spaceship, condition.condition, record_satisfaction_cache)
      if record_satisfaction_cache then record_satisfaction_cache.satisfaction = satisfaction end
      satisfied = satisfaction >= 1
    else
      error("Unexpected condition type "..condition.type)
    end

    if condition_index == 1 or condition.compare_type == "or" then
      -- First condition's compare_type is ignored
      table.insert(terms, satisfied)
    else
      terms[#terms] = terms[#terms] and satisfied
    end
  end

  for _, term in pairs(terms) do
    if term then return true end
  end
  return false
end

---Determines if the spaceship is allowed to go to the destination,
---depending on a possible star system restriction. We do not care
---where the spaceship is currently.
---@param spaceship SpaceshipType
---@param destination_zone_index uint? if spaceship targets a specific zone
---@return boolean?
local function is_valid_spaceship_and_destination(spaceship, destination_zone_index)

  -- If not restricted then we don't care where the spaceship/destination is located.
  local star_restriction = SpaceshipScheduler.restricted_to_star_system(spaceship)
  if not star_restriction then return true end

  if not destination_zone_index then return true end -- Not checking the destination zone now. It's filtered during search
  local destination_zone = Zone.from_zone_index(destination_zone_index)
  if not destination_zone then return end -- Zone doesn't exist for some reason

  local destination_parent_star = Zone.get_star_from_child(destination_zone) -- TODO This will not work with destinations on moving spaceships
  if not destination_parent_star then return end -- Destination is not within a star system

  if destination_parent_star.index ~= star_restriction.index then
    return -- Destination is in a different star system than the spaceship
  end

  return true
end


---Checks if the spaceship is at a destination clamp that is sufficient.
---This function assumes the clamp is already in a sufficient zone.
---This means it has the same identification and priority.
---@note This function assumes the ship is already in the correct zone
---@param spaceship SpaceshipType
---@param record SpaceshipSchedulerRecord
---@param target_clamp SpaceshipClampInfo
---@return SpaceshipClampInfo? connected_clamp
function SpaceshipScheduler.is_at_sufficient_destination_clamp(spaceship, record, target_clamp)
  assert(spaceship.zone_index)
  assert(not record.slingshot)
  local target_clamp_descriptor = record.destination_descriptor.clamp
  assert(target_clamp_descriptor)

  local spaceship_target_clamp = SpaceshipClamp.find_clamp_on_spaceship(spaceship, record.spaceship_clamp)
  if not spaceship_target_clamp then return end -- Spaceship has no clamp. What could have happened?

  local connected_spaceship_target_clamp = SpaceshipClamp.find_connected_clamp(spaceship_target_clamp)
  if not connected_spaceship_target_clamp then return end -- Spaceship isn't anchored to a clamp

  if connected_spaceship_target_clamp.unit_number == target_clamp.unit_number then
    return connected_spaceship_target_clamp -- Best case scenario, we are at the clamp the scheduler chose!
  end

  -- Now check if the clamp we're connected to a clamp that is good enough
  if target_clamp_descriptor.tag and target_clamp.tag ~= connected_spaceship_target_clamp.tag then return end
  if target_clamp.direction ~= connected_spaceship_target_clamp.direction then return end
  if target_clamp.priority ~= connected_spaceship_target_clamp.priority then return end
  if not SpaceshipSchedulerReservations.clamp_has_open_slot(connected_spaceship_target_clamp, spaceship) then return end

  if target_clamp_descriptor.id then
    local target_id = SpaceshipClamp.read_id(target_clamp)
    if not target_id then return end
    local connected_id = SpaceshipClamp.read_id(connected_spaceship_target_clamp)
    if not (connected_id and connected_id == target_id) then return end
  end

  -- TODO: Make sure the clamp is not disabled.

  return connected_spaceship_target_clamp -- This clamp is good enough to stay at
end

---Looks through all applicable interrupts to find
---if one's conditions are met. Will return the first match.
---@param spaceship SpaceshipType
---@return uint? interrupt_index
local function attempt_trigger_interrupt(spaceship)
  local schedule_group = storage.spaceship_scheduler_groups[spaceship.force_name][spaceship.scheduler.schedule_group_name]
  local interrupt_names = schedule_group.interrupts
  if not (interrupt_names and next(interrupt_names)) then return end

  local tick = game.tick
  local interrupts = storage.spaceship_scheduler_interrupts[spaceship.force_name]
  for interrupt_index, interrupt_name in pairs(interrupt_names) do
    local interrupt = interrupts[interrupt_name]

    -- Handle the case where an incomplete interrupt was added through the GUI
    -- that has no conditions or no targets. Such an interrupt doesn't make sense.
    if not (next(interrupt.conditions) and next(interrupt.targets)) then goto continue end

    if conditions_satisfied(tick, spaceship, interrupt.conditions) then
      return interrupt_index
    end

    ::continue::
  end
end

---Progress the schedule to the next record after waiting-at-stop
---has completed. Attempts to trigger any interrupts, or finish
---an already triggered interrupts targets, first.
---It will also update the spaceship state
---@param spaceship SpaceshipType
---@param suppress_new_interrupts boolean? if true then no new interrupts will be triggered
---@return boolean? should_continue_waiting true if the spaceship should continue waiting, like when only one record is in the schedule
function SpaceshipScheduler.progress_scheduler(spaceship, suppress_new_interrupts)
  local scheduler = spaceship.scheduler

  local from_interrupt = (scheduler.current_interrupts and next(scheduler.current_interrupts))
  if from_interrupt and SpaceshipScheduler.progress_interrupt_targets(spaceship) then
    -- There is still an queued interrupt target to service. Don't incement the
    -- current_record and don't allow triggering another interrupt.
    SpaceshipScheduler.change_state(game.tick, spaceship, "launch-to-next")
    return
  end

  if not suppress_new_interrupts then
    local interrupt_index = attempt_trigger_interrupt(spaceship)
    if interrupt_index then
      -- An interrupt was triggered! The next record will be an interrupt target
      -- Do not progress the current_record
      SpaceshipScheduler.change_state(game.tick, spaceship, "launch-to-next")
      SpaceshipScheduler.trigger_interrupt(spaceship, interrupt_index)
      return
    end
  end

  if scheduler.schedule_index > 0 then
    -- There are other records to go to!
    local schedule = SpaceshipScheduler.get_schedule(spaceship)

    if not from_interrupt and #schedule == 1 then

      -- There is only one record in the schedule, and the spaceship just satisfied its launch conditions.
      -- This is a special case where the spaceship will not progress.
      -- This is so that a spaceship can wait at the one entry in it's schedule without repeatedly launching landing.
      -- This is similar to how trains work, with the usecase shown in a picture in FFF#395.

      if scheduler.state == "on-route" then
        -- The only record is a slingshot, so change it to wait at stop. It can
        -- safely wait without wait conditions.
        SpaceshipScheduler.change_state(game.tick, spaceship, "wait-at-stop")
      end

      return true

    else

      -- This is the normal use case, where the scheduler will just direct the spaceship to the next record
      -- and wrap around if it reached the end of the schedule.
      scheduler.schedule_index = scheduler.schedule_index + 1
      if not schedule[scheduler.schedule_index] then scheduler.schedule_index = 1 end -- Wrap around
      SpaceshipScheduler.change_state(game.tick, spaceship, "launch-to-next")

    end
  else
    -- There are no regular records in the schedule. The spaceship will idle
    if scheduler.state ~= "idle" then
      SpaceshipScheduler.change_state(game.tick, spaceship, "idle")
    end
  end
end

---Processes the schedule of a spaceship. Should be called periodically
---@param spaceship SpaceshipType
---@param tick uint
function SpaceshipScheduler.tick_schedule(spaceship, tick)
  if not spaceship.valid then return end -- Spaceship was destroyed (should never happen)
  local scheduler = spaceship.scheduler
  if not scheduler.active then return end -- Any clean up should be handled during deactivation
  local state = scheduler.state

  if scheduler.wait_until and tick < scheduler.wait_until then return end

  local first_time_in_state = scheduler.first_time_in_state
  scheduler.first_time_in_state = false -- Reset here to better handle early returns

  if state == "on-route" then
    -- We are on route to a stop. We
    -- We will rely on Spaceship to send the appropriate event when the anchorring occurs to go to the next state.

    -- Don't immdiately check if the spaceship clamp still exists
    if first_time_in_state then return end

    -- Check if the destination clamp still exist. We're not doing this event
    -- driven to keep the clamp's on_removed event from being too expensive.
    -- And checking it here is efficient, and it doesn't have to happen often.
    -- Only applicable if has a future reservation (meaning not a slingshot)
    local future_reservation = scheduler.future_reservation
    if future_reservation then
      -- This will verify the reservation still exists and automatically reroute
      if
        not future_reservation.valid
        or not storage.spaceship_clamps[future_reservation.clamp_unit_number]
      then
        SpaceshipScheduler.force_repath(spaceship)

      elseif future_reservation.status == "near" then
        -- Every now again again swap this reservation for a similar clamp in the same zone
        -- if the other clamp is still waiting for it's ship to arrive.
        SpaceshipSchedulerReservations.smart_zonal_reroute(future_reservation)
      end
    end


  elseif state == "wait-at-stop" then
    -- Spaceship needs to wait at stop until all wait conditions are satisfied
    -- This is likely the the state the spaceship will also be in very often, so it's handled early.
    -- We do not handle the case where the anchor the ship docked to might be removed.

    spaceship.travel_message = {"space-exploration.spaceship-travel-message-waiting-at-anchor"}

    local record = SpaceshipScheduler.get_current_record(spaceship)
    if conditions_satisfied(tick, spaceship, record.wait_conditions, scheduler.record_satisfactions) then

      -- Find the next record to go to and update the state
      if SpaceshipScheduler.progress_scheduler(spaceship) then

        -- The spaceship should continue waiting at the stop, likely because there's only one record in the schedule
        -- To void still doing the expensive wait condition checks every second we will only update every 5 seconds.
        scheduler.wait_until = tick + SpaceshipScheduler.launch_to_next_retry_time

      end
    end


  elseif state == "launch-to-next" then
    -- This state will route a spaceship to a next destination. It will do sanity checks if it's
    -- possible, make the reservations, and launch the spaceship.
    -- The scheduler should also be set to this state to re-route to a different destination,
    -- for example when the player clicks on a different record in the UI.

    spaceship.travel_message = {"space-exploration.spaceship-travel-message-finding-destination"}

    -- We could check if it's even possible for the spaceship to launch before we
    -- look for potential destination. However that check requries looking for entities
    -- on the spaceship and checking their inventories, which sound expensive. It might
    -- even be cheaper for the scheduler to find a destination first. So for now, ignore
    -- if the spaceship can launch or not. We will abort later if not possible.

    local record = SpaceshipScheduler.get_current_record(spaceship) -- There schedule should never be empty here
    local destination_descriptor = record.destination_descriptor

    -- Do some once of sanity checks
    if first_time_in_state then

      -- Verify that the spaceship can actually reach this destination
      if not is_valid_spaceship_and_destination(spaceship, destination_descriptor.zone_pointer) then
        Util.spawn_flying_text_at_entity(spaceship.console, {"space-exploration.spaceship-scheduler-wrong-system"})
        SpaceshipScheduler.deactivate(spaceship) -- TODO Maybe this is too harsh
        return
      end

      -- Make sure the spaceship and destination clamp will fit to each other
      if not record.slingshot then
        if record.spaceship_clamp.direction == destination_descriptor.clamp.direction then
          -- Invalid combination of spaceship/destination signals. Should never happen.
          Util.spawn_flying_text_at_entity(spaceship.console, {"space-exploration.spaceship-scheduler-invalid-clamp-combo"})
          SpaceshipScheduler.deactivate(spaceship)
          return
        end
      end
    end

    -- The current assumption is that the spaceship has no reservation to a clamp that it's not currently
    -- anchored to. This is simply not handled because it's not really required, because a spaceship will
    -- never repath by itself. It's always player-induced, for example by deleting records in the schedule.
    -- It can be changed to support this in the future, but then the reservation system will need
    -- to be updated to take this into account, and probably some other things.
    assert(not scheduler.future_reservation, "Cannot have a future reservation when attempting launch-to-next")

    -- Find a destination to fly to!
    local target_clamp --[[@as SpaceshipClampInfo? only used if not a slingshot ]]
    local target_zone_index --[[@as ZonePointer?]]
    if not record.slingshot then

      -- Ensure there are clamps on this spaceship. We do this every time, because things might change.
      local spaceship_clamp = SpaceshipClamp.find_clamp_on_spaceship(spaceship, record.spaceship_clamp)
      if not spaceship_clamp then
        if not first_time_in_state then
          -- It might be that the first integrity check is still running, so there might be clamps we don't know about
          -- Suppressing it the first time might reduce some confusion.
          -- Note: technically this message should also contain the clamp direction, but the player can figure that out.
          Util.spawn_flying_text_at_entity(spaceship.console, {"space-exploration.spaceship-no-clamps-on-spaceship", record.spaceship_clamp.tag})
        end

        -- Currently we can only find clamps on spaceship if an integrity check has been run
        ---@TODO Maybe there's a better way, integrity checks are UPS expensive.
        spaceship.is_launching = false
        SpaceshipIntegrity.start_integrity_check(spaceship)

        scheduler.wait_until = tick + SpaceshipScheduler.launch_to_next_retry_time
        return
      end -- Could not find a clamp to possibly anchor with. Prevent departure

      -- Try to find a clamp to launch towards
      local result, clamp_info = SpaceshipScheduler.find_destination(spaceship, destination_descriptor)
      if result == "doesnt-exist" then
        -- The destination doesn't exist. This could be because the zone doesn't exist, or there are no clamps on the zone.
        scheduler.no_existing_clamp = true
        Util.spawn_flying_text_at_entity(spaceship.console, {"space-exploration.spaceship-scheduler-no-clamps-exist"})
        scheduler.wait_until = tick + SpaceshipScheduler.launch_to_next_retry_time
        return
      elseif result == "occupied" then
        -- The destination is occupied. We can't go there.
        scheduler.no_existing_clamp = nil
        Util.spawn_flying_text_at_entity(spaceship.console, {"space-exploration.spaceship-scheduler-destination-full"})
        scheduler.wait_until = tick + SpaceshipScheduler.launch_to_next_retry_time
        return
      elseif result == "success" then
        -- Found a valid destination to fly to!
        scheduler.no_existing_clamp = nil
        assert(clamp_info)
        target_clamp = clamp_info
        local target_zone = Zone.from_surface_name(clamp_info.surface_name)
        assert(target_zone, "No zone found with name "..clamp_info.surface_name)
        target_zone_index = target_zone.index
      else
        error("Unexpected result from find_destination: "..result)
      end

    else

      -- Don't need any clamps or anything when doing a slingshot. Just fly towards the zone.
      assert(destination_descriptor.zone_pointer)
      target_zone_index = destination_descriptor.zone_pointer

    end

    -- We found a destination we can fly to! Now we should attempt to launch!
    assert(target_zone_index)
    assert(target_zone_index > 0)

    -- If we are already at the destination clamp then we can skip most of the rest. We need to
    -- take care here that we are indeed at the correct clamp, with the highest priority, and
    -- that the reservation is taken correctly.
    if
      not record.slingshot
      and target_clamp
      and spaceship.zone_index
      and spaceship.zone_index == target_zone_index
    then
      -- We are in the correct zone. Now check if we are at the correct clamp
      local connected_clamp = SpaceshipScheduler.is_at_sufficient_destination_clamp(spaceship, record, target_clamp)
      if connected_clamp then

        -- Make sure the spaceship has the correct reservation. It might be that it has none, or in rare
        -- cases a different reservation.
        if
          not (scheduler.anchored_reservation and scheduler.anchored_reservation.valid)
          or scheduler.anchored_reservation.clamp_unit_number ~= connected_clamp.unit_number
        then
          if scheduler.anchored_reservation then
            SpaceshipSchedulerReservations.remove_reservation(scheduler.anchored_reservation)
            scheduler.anchored_reservation = nil
          end

          -- Take the correct reservation
          scheduler.anchored_reservation = SpaceshipSchedulerReservations.make_reservation(spaceship, connected_clamp, "anchored")
          assert(scheduler.anchored_reservation, "Failed taking reservation which should have been free!")
        end

        -- Now that we have the reservation we can start with the next state
        SpaceshipScheduler.change_state(tick, spaceship, "wait-at-stop")
        return
      end
    end

    -- We've got everything we need! Lets try and launch
    SpaceshipScheduler.change_state(tick, spaceship, "wait-for-launch-success")
    local launch_result = SpaceshipScheduler.launch_spaceship_towards_zone(spaceship, target_zone_index)
    if launch_result == "failed" then
      -- We could not launch for some reason (like not enough fuel). Safe to stop because we haven't made a booking.
      SpaceshipScheduler.change_state(tick, spaceship, "launch-to-next") -- Revert state cause it failed
      Util.spawn_flying_text_at_entity(spaceship.console, {"space-exploration.spaceship-launch-failed"})
      scheduler.wait_until = tick + SpaceshipScheduler.launch_to_next_retry_time
      return
    end

    spaceship.travel_message = {"space-exploration.spaceship-travel-message-waiting-for-launch"}

    if not record.slingshot then
      -- Now makes the reservation as the launch will probably succeed.
      -- This will be a temporary reservation until we've launched successfully to
      -- ensure we don't unbook the the previous reservation prematurely
      scheduler.future_reservation = SpaceshipSchedulerReservations.make_reservation(spaceship, target_clamp, "on-route")
      assert(scheduler.future_reservation, "Tried to make spaceship reservation in an non-existant zone.")
    end

    -- We will not release the current reservation until we've verified that we launched successfully.
    -- That means at this point the stored reservation in the spaceship will still point to the previous reservation.

    if launch_result == "already-launched" then
      -- The spaceship was already flying. So no events are expected so we will just call it ourselve
      SpaceshipScheduler.on_spaceship_launched({spaceship_index=spaceship.index})

    elseif launch_result == "near" then
      -- These events will not trigger because they already triggered before. So we will call them ourselves
      SpaceshipScheduler.on_spaceship_launched({spaceship_index=spaceship.index})
      SpaceshipScheduler.on_spaceship_near_zone({spaceship_index=spaceship.index, zone_index=target_zone_index})

    else
      -- Still waiting for launch success
    end


  elseif state == "wait-for-launch-success" then
    -- Ensure the launch suceeded. If it didn't revert the booking and go back to `launch-to-next`
    -- This state waits for a launch-succeeded or failed event. However, here we need to handle
    -- the case that neither is called for some reason, the spaceship code is complicated.

    if tick > scheduler.state_ticked + SpaceshipScheduler.wait_for_launch_success_timeout then
      -- The launch timed out and we are still on the ground.
      -- Ideally this would never happen as we would
      -- detect the launch state earlier. Anyway, go back.

      -- Remove the reservation for the destination we were targetting. This ship will
      -- still contain a reservation to the stop it was located at (if any).
      if scheduler.future_reservation then
        SpaceshipSchedulerReservations.remove_reservation(scheduler.future_reservation)
        scheduler.future_reservation = nil
      end

      -- Start the launch sequence again
      SpaceshipScheduler.change_state(tick, spaceship, "launch-to-next")
    end


  elseif state == "idle" then
    -- We will only be in this state when there are no records (or active interrupts) in the schedule.
    -- The spaceship will remain here until a new record is added to the schedule, or until
    -- an interrupt is triggered, even if the spaceship is in space somewhere.

    -- We don't have to check interrupt conditions too often here.
    scheduler.wait_until = tick + SpaceshipScheduler.launch_to_next_retry_time

    -- Try to at least trigger an interrupt. If an interrupt is triggered the state will change
    -- which will also clear the `scheduler.wait_until` variable.
    SpaceshipScheduler.progress_scheduler(spaceship)

  else
    error("Unknown spaceship scheduler state: "..state)
  end
end

------------------------------------------------
-- SPACESHIP EVENTS
------------------------------------------------

---When the spaceship reaches the "near" position of the current destination
---@param event {spaceship_index:uint, zone_index:uint}
function SpaceshipScheduler.on_spaceship_near_zone(event)
  local spaceship = storage.spaceships[event.spaceship_index]
  if not spaceship then return end
  local scheduler = spaceship.scheduler
  if not scheduler.active then return end
  if scheduler.state ~= "on-route" then return end

  -- We need to determine if this is the near event after the initial launch,
  -- or near the destination. When this is a slingshot destination_descriptor needs
  -- to be populated, but if not it _might_ be populated. Therefore in the latter case
  -- we will also check the reservation's zone.

  local record = SpaceshipScheduler.get_current_record(spaceship)
  if record.slingshot then

    assert(record.destination_descriptor.zone_pointer)
    if record.destination_descriptor.zone_pointer ~= event.zone_index then return end -- Not at destination
    SpaceshipScheduler.progress_scheduler(spaceship)

  else

    assert(scheduler.future_reservation)
    if scheduler.future_reservation.zone_pointer ~= event.zone_index then return end -- Not at destination
    SpaceshipSchedulerReservations.update_reservation(scheduler.future_reservation, "near")

  end
end
Event.addListener("on_spaceship_near_zone", SpaceshipScheduler.on_spaceship_near_zone, true)

---When the spaceship successfully anchored at its destination
---It's assumed that the destination of the ship is set correctly
---@param event {spaceship_index:uint}
function SpaceshipScheduler.on_spaceship_anchored(event)
  local spaceship = storage.spaceships[event.spaceship_index]
  if not spaceship then return end
  local scheduler = spaceship.scheduler
  if not scheduler.active then return end
  if scheduler.state ~= "on-route" then return end

  -- Change the reservation type to landed
  assert(scheduler.future_reservation)
  scheduler.anchored_reservation = scheduler.future_reservation
  scheduler.future_reservation = nil
  SpaceshipSchedulerReservations.update_reservation(scheduler.anchored_reservation, "anchored")

  SpaceshipScheduler.change_state(game.tick, spaceship, "wait-at-stop")
end
Event.addListener("on_spaceship_anchored", SpaceshipScheduler.on_spaceship_anchored, true)

---Should be called after a spaceship launched successfully.
---@param event {spaceship_index:uint}
function SpaceshipScheduler.on_spaceship_launched(event)
  local spaceship = storage.spaceships[event.spaceship_index]
  if not spaceship then return end
  local scheduler = spaceship.scheduler
  if not scheduler.active then return end
  if scheduler.state ~= "wait-for-launch-success" then return end

  -- A launch triggered by the scheduler was successful! Ensure it starts flying immediately.
  -- This is not handled like normal flying where the player first has to click `Engage`, because
  -- starting the scheduler is `always` regular manual intervention anyway.
  spaceship.stopped = false

  -- Could be that the spaceship wasn't landed by the scheduler, thus no reservation. Or this is a slingshot
  if scheduler.anchored_reservation then
    -- We can release the anchored reservation
    SpaceshipSchedulerReservations.remove_reservation(scheduler.anchored_reservation)
    scheduler.anchored_reservation = nil
  end

  SpaceshipScheduler.change_state(game.tick, spaceship, "on-route")
end
Event.addListener("on_spaceship_launched", SpaceshipScheduler.on_spaceship_launched, true)

---Should be called if a spaceship launch failed
---@param event {spaceship_index:uint}
function SpaceshipScheduler.on_spaceship_launch_failed(event)
  local spaceship = storage.spaceships[event.spaceship_index]
  if not spaceship then return end
  local scheduler = spaceship.scheduler
  if not scheduler.active then return end
  if scheduler.state ~= "wait-for-launch-success" then return end
  Util.spawn_flying_text_at_entity(spaceship.console, {"space-exploration.spaceship-launch-failed"})

  -- We need to remove the reservation at the zone we were attempting to launch to
  -- Could be that there was no resevation if we're doing a slingshot
  if scheduler.future_reservation then
    SpaceshipSchedulerReservations.remove_reservation(scheduler.future_reservation)
    scheduler.future_reservation = nil
  end

  SpaceshipScheduler.change_state(game.tick, spaceship, "launch-to-next")
  scheduler.wait_until = game.tick + SpaceshipScheduler.launch_to_next_retry_time -- Needs to be declare after change_status, in which it's reset
end
Event.addListener("on_spaceship_launch_failed", SpaceshipScheduler.on_spaceship_launch_failed, true)

------------------------------------------------
-- SCHEDULE GROUP HANDLING
------------------------------------------------

---Get the name used for unassigned spaceship schedule groups
---@param spaceship SpaceshipType
---@return string
function SpaceshipScheduler.get_unassigned_group_name(spaceship)
  return "spaceship-"..spaceship.index
end

---@param spaceship SpaceshipType
---@return boolean
function SpaceshipScheduler.is_unassigned(spaceship)
  local scheduler = spaceship.scheduler
  return scheduler.schedule_group_name == SpaceshipScheduler.get_unassigned_group_name(spaceship)
end

---@param group_name string
---@return boolean if the given name is of an unasigned group
function SpaceshipScheduler.is_unassigned_group_name(group_name)
  return group_name:match("^spaceship%-%d+$") ~= nil
end

---Sanitizes a scheduler to ensure all references are valid.
---@param spaceship SpaceshipType
function SpaceshipScheduler.assert_scheduler(spaceship)
  local scheduler = spaceship.scheduler
  local groups = storage.spaceship_scheduler_groups[spaceship.force_name]
  assert(groups, "No scheduler group exists for force: "..spaceship.force_name)
  local schedule_group = groups[scheduler.schedule_group_name]
  assert(schedule_group, "Schedule group with name '"..scheduler.schedule_group_name.."' does not exist")
  assert(schedule_group.spaceships[spaceship.index], "Expected reference of spaceship '"..spaceship.name.." in scheduler group '"..scheduler.schedule_group_name.."'")
  local number_of_records = #schedule_group.schedule
  if scheduler.schedule_index == 0 then
    assert(number_of_records == 0, "Expect no records when schedule index is zero")
  else
    assert(number_of_records > 0, "Expect records when schedule index is not zero")
    assert(scheduler.schedule_index <= number_of_records, "Invalid schedule index "..scheduler.schedule_index.." for "..number_of_records.." records")
  end

  if SpaceshipScheduler.is_unassigned(spaceship) then
    assert(scheduler.schedule_group_name == SpaceshipScheduler.get_unassigned_group_name(spaceship), "Unexpected name: "..scheduler.schedule_group_name.." for index "..spaceship.index)
    assert(table_size(schedule_group.spaceships) == 1, "Unassigned group '"..scheduler.schedule_group_name.."' should always contain one spaceship")
  end
end

---Sanitizes an interrupt by ensuring all schedules referencing
---this interrupt still exists. This should never be neccesary,
---but we do it for safety.
---@param force_name string
---@param interrupt SpaceshipSchedulerInterrupt
---@param interrupt_name string of this interrupt
local function assert_interrupt(force_name, interrupt, interrupt_name)
  local schedules_for_force = storage.spaceship_scheduler_groups[force_name]
  for schedule_group_name, _ in pairs(interrupt.schedules) do
    if not (schedules_for_force and interrupt.schedules[schedule_group_name]) then
      error("Invalid schedule reference `"..schedule_group_name.."` in interrupt `"..interrupt_name.."`")
    else
      local schedule_group = schedules_for_force[schedule_group_name]
      if not schedule_group then
        error("Schedule group `"..schedule_group_name.."` does not exist as referenced in interrupt `"..interrupt_name.."`")
      elseif not Util.table_contains(schedule_group.interrupts, interrupt_name) then
        error("Schedule group `"..schedule_group_name.."` does not contain expected reference to interrupt `"..interrupt_name.."`")
      end
    end
  end
end

---Sanitizes an schedule group by ensuring all spaceships using
---this group still exists. This should never be neccesary,
---but we do it for safety.
---@param force_name string
---@param schedule_group_name string of this interrupt
---@param ignore_spaceship_count boolean? Ignore the amount of spaceships currently using this schedule
---@return SpaceshipScheduleGroup
function SpaceshipScheduler.assert_schedule_group(force_name, schedule_group_name, ignore_spaceship_count)
  local schedule_group = storage.spaceship_scheduler_groups[force_name][schedule_group_name]

  assert(ignore_spaceship_count or next(schedule_group.spaceships), "Expect at least one spaceship in schedule group")
  for spaceship_index, _ in pairs(schedule_group.spaceships) do
    local spaceship = storage.spaceships[spaceship_index]
    assert(spaceship, "Invalid spaceship index ("..spaceship_index..") in group ("..schedule_group_name..")")
    assert(spaceship.scheduler.schedule_group_name == schedule_group_name, "Spaceship ("..spaceship.name..") does not reference schedule group "..schedule_group_name)
  end

  for i = #schedule_group.interrupts, 1, -1 do -- Iterate in reverse for save removal
    local interrupt_name = schedule_group.interrupts[i]
    local interrupt = storage.spaceship_scheduler_interrupts[force_name][interrupt_name]
    assert(interrupt, "Non-existant interrupt name '"..interrupt_name.."' in schedule group '"..schedule_group_name.."'")
    assert_interrupt(force_name, interrupt, interrupt_name)
  end

  return schedule_group
end

---Create a new empty schedule group
---@param spaceship SpaceshipType (might not have valid schedule yet)
---@return SpaceshipScheduleGroup
function SpaceshipScheduler.create_schedule_group(spaceship)
  -- Attempt to have on by default.
  -- Better for UPS and for spaceships running out of fuel accidentally
  local star_restriction = spaceship.near_star and spaceship.near_star.index or nil

  ---@type SpaceshipScheduleGroup
  return {
    schedule = { },
    interrupts = { },
    spaceships = { },
    restrict_to_star_system = star_restriction,
  }
end

---Deletes a schedule group. The group can have no spaceships currently using it
---@param force_name string
---@param group_name string
function SpaceshipScheduler.delete_schedule_group(force_name, group_name)
  local group =  SpaceshipScheduler.assert_schedule_group(force_name, group_name, true) -- Will assert if doens't exist
  assert(next(group.spaceships) == nil, "Cannot delete scheduler group "..group_name.." that's used by spaceships")

  -- First clean up some interrupts which might have a reference to this group
  for i=#group.interrupts,1,-1 do -- iterate in reverse to not break iterator
    local interrupt_name = group.interrupts[i]
    SpaceshipScheduler.remove_interrupt_from_schedule_group(force_name, group_name, interrupt_name)
  end

  storage.spaceship_scheduler_groups[force_name][group_name] = nil
end

---Changes the spaceship to use a different schedule group. If the new
---schedule group does not yet exist then it creates it, possibly using
---the old schedule as starting point.
---@param spaceship SpaceshipType could be a spaceship that has no schedule group yet
---@param new_group_name string
---@return SpaceshipScheduleGroup
function SpaceshipScheduler.change_spaceship_schedule_group(spaceship, new_group_name)
  local scheduler = spaceship.scheduler

  -- Always deactivate the scheduler first. This will remove this spaceship from
  -- any reservations it might have. If this spaceship is anchored somewhere it
  -- will lose that reservation too, but will try to take it again if required
  -- by the new schedule. Just like trains.
  SpaceshipScheduler.deactivate(spaceship)

  storage.spaceship_scheduler_groups[spaceship.force_name] = storage.spaceship_scheduler_groups[spaceship.force_name] or { }
  local groups_for_force = storage.spaceship_scheduler_groups[spaceship.force_name]

  local old_schedule_group_name = scheduler.schedule_group_name
  local old_schedule_group = groups_for_force[old_schedule_group_name] --[[@as SpaceshipScheduleGroup? ]]

  if old_schedule_group and old_schedule_group_name == new_group_name then
    -- Nothing to do, group already exists too
    SpaceshipScheduler.assert_schedule_group(spaceship.force_name, new_group_name)
    SpaceshipScheduler.assert_scheduler(spaceship)
    return old_schedule_group
  end

  local new_schedule_group = groups_for_force[new_group_name] --[[@as SpaceshipScheduleGroup? ]]
  if not new_schedule_group then
    -- The new schedule group name doesn't exist yet. Create it now

    groups_for_force[new_group_name] = SpaceshipScheduler.create_schedule_group(spaceship)
    new_schedule_group = groups_for_force[new_group_name]

    if old_schedule_group then -- We are copying the old schedule group
      new_schedule_group.schedule = util.deep_copy(old_schedule_group.schedule)
      new_schedule_group.interrupts = util.deep_copy(old_schedule_group.interrupts)

      -- Update the interrupts to also point to this new schedule group
      for _, interrupt_name in pairs(new_schedule_group.interrupts) do
        local interrupt = storage.spaceship_scheduler_interrupts[spaceship.force_name][interrupt_name]
        interrupt.schedules[new_group_name] = game.tick
      end
    end
  end

  -- Remove references of this spaceship in old schedule group
  if old_schedule_group then
    old_schedule_group.spaceships[spaceship.index] = nil

    -- Delete up this group if there are no more spaceships in it
    if not next(old_schedule_group.spaceships) then
      SpaceshipScheduler.delete_schedule_group(spaceship.force_name, old_schedule_group_name)
      old_schedule_group = nil
    end
  end

  -- Change spaceship to use new schedule group
  new_schedule_group.spaceships[spaceship.index] = game.tick
  scheduler.schedule_group_name = new_group_name
  scheduler.schedule_index = next(new_schedule_group.schedule) and 1 or 0

  -- Make sure we didn't break anything.
  SpaceshipScheduler.assert_schedule_group(spaceship.force_name, new_group_name)
  if old_schedule_group then SpaceshipScheduler.assert_schedule_group(spaceship.force_name, old_schedule_group_name) end
  SpaceshipScheduler.assert_scheduler(spaceship)

  return new_schedule_group
end

---Adds a record to the end of a schedule_group
---@param force_name string of this schedule group
---@param group_name string of the schedule group to modify
---@param record SpaceshipSchedulerRecord
function SpaceshipScheduler.add_record_to_schedule_group(force_name, group_name, record)
  SpaceshipScheduler.assert_schedule_group(force_name, group_name)

  local schedule_group = storage.spaceship_scheduler_groups[force_name][group_name]
  local schedule = schedule_group.schedule

  if not record.slingshot then
    assert(record.spaceship_clamp)
    assert(record.destination_descriptor.clamp)
  else
    assert(record.destination_descriptor.zone_pointer)
  end

  -- Appending the new record at the end of the schedule doesn't need any changes
  -- to spaceships using this schedule
  table.insert(schedule, record)

  if #schedule == 1 then
    -- This is the first record in the schedule. Make sure all spaceships update their schedule indexes
    for spaceship_index, _ in pairs(schedule_group.spaceships) do
      local spaceship = storage.spaceships[spaceship_index]
      if spaceship then
        local scheduler = spaceship.scheduler
        assert(scheduler.schedule_index == 0, "Expected schedule index to be 0 while there was no records")
        scheduler.schedule_index = 1

        if scheduler.current_interrupts and next(scheduler.current_interrupts) then
          assert(scheduler.state ~= "idle") -- Spaceship is still busy
        else
          SpaceshipScheduler.force_repath(spaceship) -- will also clear any future reservations
        end

        SpaceshipScheduler.assert_scheduler(spaceship)
      end
    end
  end

  SpaceshipScheduler.assert_schedule_group(force_name, group_name)
end

---Removes a record from a schedule_group and update all spaceships using this schedule_group
---This does not remove interrupts! For interrupts `remove_interrupt_from_schedule_group` should be used
---@param force_name string of this schedule group
---@param group_name string of the schedule group to modify
---@param record_index uint record index to remove
function SpaceshipScheduler.remove_record_from_schedule_group(force_name, group_name, record_index)
  local schedule_group = storage.spaceship_scheduler_groups[force_name][group_name]
  SpaceshipScheduler.assert_schedule_group(force_name, group_name)
  local schedule = schedule_group.schedule
  local schedule_length = #schedule

  assert(record_index <= #schedule, "Invalid index "..record_index.." to remove from schedule of length "..schedule_length)
  table.remove(schedule, record_index)
  schedule_length = schedule_length - 1

  for spaceship_index, _ in pairs(schedule_group.spaceships) do
    local spaceship = storage.spaceships[spaceship_index]
    if not spaceship then goto continue end
    local scheduler = spaceship.scheduler

    -- We always stop any automated launches when any record is removed. This simplifies the handling of reservations
    -- significantly. Most specifically if a record is removed while a spaceship is launching, it makes it hard to
    -- determine if the anchored_reservation should be kept or not because we don't know yet the result of the launch.
    -- This simplifies it a lot. And automated launches will just try again.
    Spaceship.stop_launch(spaceship)

    if schedule_length > 0 then

      -- Repath the spaceship if we were servicing this record.
      if scheduler.active
        and not (scheduler.current_interrupts and next(scheduler.current_interrupts))   -- Ignore if we're servicing an interrupt
        and scheduler.schedule_index == record_index
      then
        SpaceshipScheduler.force_repath(spaceship)
      end

      if record_index < scheduler.schedule_index then
        scheduler.schedule_index = scheduler.schedule_index - 1
      end

      -- Clamp index between 1 and the number of records
      scheduler.schedule_index = math.min(schedule_length, math.max(1, scheduler.schedule_index))

    else
      -- There are no more records in the schedule
      scheduler.schedule_index = 0 -- Index should always be zero when there are no records left (exluding interrupts)

      if scheduler.current_interrupts and next(scheduler.current_interrupts) then
        assert(scheduler.state ~= "idle") -- Spaceship is still busy with interrupts
      else
        SpaceshipScheduler.change_state(game.tick, spaceship, "idle")

        -- We will only clear the future reservation here, and keep the anchored reservation
        -- so that no other spaceships try to land at that clamp.
        ---@TODO What do trains do in this sitation?
        if scheduler.future_reservation then
          SpaceshipSchedulerReservations.remove_reservation(scheduler.future_reservation)
          scheduler.future_reservation = nil
        end

      end
    end

    SpaceshipScheduler.assert_scheduler(spaceship)
    ::continue::
  end

  SpaceshipScheduler.assert_schedule_group(force_name, group_name)
end

---Adds a record to a schedule_group and update all spaceships using this schedule_group.
---Doesn't do anything if it's not a valid move.
---@param force_name string of this schedule group
---@param group_name string of the schedule group to modify
---@param record_index uint record index to remove
---@param direction "up"|"down"
---@return boolean? changed true if the movement was sucessful
function SpaceshipScheduler.move_record_in_schedule_group(force_name, group_name, record_index, direction)
  local schedule_group = storage.spaceship_scheduler_groups[force_name][group_name]
  SpaceshipScheduler.assert_schedule_group(force_name, group_name)
  local schedule = schedule_group.schedule

  assert((not record_index) or (record_index <= #schedule))
  assert(direction == "up" or direction == "down")

  local index_to_swap = record_index + (direction == "up" and -1 or 1)
  if index_to_swap < 1 or index_to_swap > #schedule then return end -- Ignore invalid move

  -- Do the swap!
  schedule[index_to_swap], schedule[record_index] = schedule[record_index], schedule[index_to_swap]

  for spaceship_index, _ in pairs(schedule_group.spaceships) do
    local spaceship = storage.spaceships[spaceship_index]
    if spaceship then
      SpaceshipScheduler.assert_scheduler(spaceship)
      local scheduler = spaceship.scheduler
      if scheduler.schedule_index == record_index then
        scheduler.schedule_index = index_to_swap
      elseif scheduler.schedule_index == index_to_swap then
        scheduler.schedule_index = record_index
      end
      SpaceshipScheduler.assert_scheduler(spaceship)
    end
  end

  return true
end

---Add an interrupt to a schedule group. It will always be appended at the end
---It's assumed that this scheduled group still exists. It will only succeed
---if this interrupt is not yet part of the schedule group, because it doesn't
---make sense to add it more than once.
---@param force_name string
---@param group_name string
---@param interrupt_name string
---@return boolean success
function SpaceshipScheduler.add_interrupt_to_schedule_group(force_name, group_name, interrupt_name)
  -- Add reference to schedule group
  local schedule_group = storage.spaceship_scheduler_groups[force_name][group_name]
  if util.table_contains(schedule_group.interrupts, interrupt_name) then
    return false
  end
  table.insert(schedule_group.interrupts, interrupt_name)
  SpaceshipScheduler.assert_schedule_group(force_name, group_name)

  -- Add reference to interrupt
  local interrupt = storage.spaceship_scheduler_interrupts[force_name][interrupt_name]
  interrupt.schedules[group_name] = game.tick
  assert_interrupt(force_name, interrupt, interrupt_name)

  return true
end

---Remove an interrupt from a schedule group. Does not affect
---any spaceships that might be servicing this interrupt,
---and they will complete the added temporary stops.
---@param force_name string
---@param group_name string
---@param interrupt_name string
function SpaceshipScheduler.remove_interrupt_from_schedule_group(force_name, group_name, interrupt_name)
  -- Remove reference from schedule group
  local schedule_group = SpaceshipScheduler.assert_schedule_group(force_name, group_name, true)
  util.remove_from_table(schedule_group.interrupts, interrupt_name)

  -- Remove reference from interrupt
  local interrupts = storage.spaceship_scheduler_interrupts[force_name]
  local interrupt = interrupts[interrupt_name]
  if interrupt then -- We don't care if the interrupt doesn't exist
    interrupt.schedules[group_name] = nil
    if not next(interrupt.schedules) then
      -- There's no more schedules that use this interrupt. Remove it
      interrupts[interrupt_name] = nil
    else
      assert_interrupt(force_name, interrupt, interrupt_name)
    end
  end
end

---Moves an interrupt in schedule_group. Does not effect any spaceships.
---Doesn't do anything if it's not a valid move.
---@param force_name string of this schedule group
---@param group_name string of the schedule group to modify
---@param interrupt_index uint
---@param direction "up"|"down"
---@return boolean? changed true if the movement was sucessful
function SpaceshipScheduler.move_interrupt_in_schedule_group(force_name, group_name, interrupt_index, direction)
  local schedule_group = storage.spaceship_scheduler_groups[force_name][group_name]
  local interrupts = schedule_group.interrupts

  assert((not interrupt_index) or (interrupt_index <= #interrupts))
  assert(direction == "up" or direction == "down")

  local index_to_swap = interrupt_index + (direction == "up" and -1 or 1)
  if index_to_swap < 1 or index_to_swap > #interrupts then return end -- Ignore invalid move

  -- Do the swap!
  local temp = interrupts[index_to_swap]
  interrupts[index_to_swap] = interrupts[interrupt_index]
  interrupts[interrupt_index] = temp

  return true
end

---Remove a spaceship from it's current group. Should only be used when
---then spaceship is destroyed, because a spaceship needs a scheduler group
---to properly function (it will crash if not)
---@param spaceship SpaceshipType
function SpaceshipScheduler.remove_spaceship_from_schedule_group(spaceship)
  SpaceshipScheduler.assert_scheduler(spaceship)
  local force_groups = storage.spaceship_scheduler_groups[spaceship.force_name]
  if not force_groups then return end     -- Will be caught by sanitization
  local schedule_group_name = spaceship.scheduler.schedule_group_name
  local group = force_groups[schedule_group_name]
  if not group then return end            -- Will be caught by sanitization

  SpaceshipScheduler.assert_schedule_group(spaceship.force_name, schedule_group_name)
  assert(group.spaceships[spaceship.index], "Spaceship "..spaceship.name.." is not part of group "..schedule_group_name)

  group.spaceships[spaceship.index] = nil

  if not next(group.spaceships) then
    SpaceshipScheduler.delete_schedule_group(spaceship.force_name, schedule_group_name)
  end
end

---Sets a schedule group to restrict to a star system or not. This will not
---cause an immediate reroute in any spaceships part of this group that might
---be travelling interstellar. It will only affect new paths.
---@param force_name string
---@param group_name string
---@param star StarType?
function SpaceshipScheduler.set_restrict_to_star_system(force_name, group_name, star)
  local schedule_group = storage.spaceship_scheduler_groups[force_name][group_name]
  SpaceshipScheduler.assert_schedule_group(force_name, group_name)
  assert(not star or star.type == "star")
  local star_index = star and star.index or nil
  if schedule_group.restrict_to_star_system == star_index then return end -- Nothing to do

  schedule_group.restrict_to_star_system = star_index
  for spaceship_index in pairs(schedule_group.spaceships) do
    local spaceship = storage.spaceships[spaceship_index]
    if spaceship then
      -- Repath all spaceships since they might not be able to go
      -- to their current destinations anymore.
      SpaceshipScheduler.force_repath(spaceship)
    end
  end
end

------------------------------------------------
-- INTERRUPT HANDLING
------------------------------------------------

---@param interrupt SpaceshipSchedulerInterrupt? to base it off
---@return SpaceshipSchedulerInterrupt
function SpaceshipScheduler.create_interrupt(interrupt)
  return {
    conditions = interrupt and interrupt.conditions or { },
    targets = interrupt and interrupt.targets or { },
    schedules = { },
  } --[[@as SpaceshipSchedulerInterrupt ]]
end

---Find unique scheduler group name for spaceship
---@param force_name string
function SpaceshipScheduler.find_unique_interrupt_name(force_name)
  local base = "Interrupt "
  local number = 1
  local name = base .. number

  storage.spaceship_scheduler_interrupts[force_name] = storage.spaceship_scheduler_interrupts[force_name] or { }
  while storage.spaceship_scheduler_interrupts[force_name][name] do
    number = number + 1
    name = base .. number
  end

  return name
end

---@param force_name string
---@param interrupt_name string
---@param interrupt SpaceshipSchedulerInterrupt
---@return boolean? success and it fails if it already exists
function SpaceshipScheduler.add_interrupt_to_force(force_name, interrupt_name, interrupt)
  storage.spaceship_scheduler_interrupts[force_name] = storage.spaceship_scheduler_interrupts[force_name] or { }
  local interrupts = storage.spaceship_scheduler_interrupts[force_name]
  if interrupts[interrupt_name] then return end
  interrupts[interrupt_name] = interrupt
  return true
end

---Changes the name of an existing interrupt inside a schedule group. This will not affect
---any other schedules that use the interrupt. Handles the case where the old interrupt
---might not exist anymore.
---@param force_name string
---@param old_name string
---@param new_name string
---@param schedule_group_name string where this interrupt is currently being changed from
function SpaceshipScheduler.change_interrupt_name_in_schedule(force_name, old_name, new_name, schedule_group_name)
  assert(old_name ~= new_name)
  local old_interrupt = storage.spaceship_scheduler_interrupts[force_name][old_name]
  if old_interrupt then assert_interrupt(force_name, old_interrupt, old_name) end -- Old interrupt might have been removed
  SpaceshipScheduler.remove_interrupt_from_schedule_group(force_name, schedule_group_name, old_name)
  SpaceshipScheduler.add_interrupt_to_schedule_group(force_name, schedule_group_name, new_name)
end

---Trigger an interrupt on a spaceship. This will "copy"
---the interrupt's targets into the schedule. We copy the targets
---so that it's disconnected from the global interrupt, meaning the player
---can change it in the schedule without it affecting other spaceships.
---IMO that's what the player will find intuitive.
---Overwrites a possible previous interrupt.
---@param spaceship SpaceshipType
---@param interrupt_index uint
---@param preemptive boolean? add the interrupt before the current record (used for manual triggering)
function SpaceshipScheduler.trigger_interrupt(spaceship, interrupt_index, preemptive)
  local scheduler = spaceship.scheduler
  local schedule_group = storage.spaceship_scheduler_groups[spaceship.force_name][scheduler.schedule_group_name]
  local interrupt_name = schedule_group.interrupts[interrupt_index]
  assert(interrupt_index)
  local interrupt = storage.spaceship_scheduler_interrupts[spaceship.force_name][interrupt_name]
  assert(interrupt)

  if scheduler.current_interrupts then -- Remove any interrupts currently active
    SpaceshipScheduler.remove_current_interrupt_targets(spaceship)
  end

  if preemptive and scheduler.schedule_index > 0 then
    -- To place the interrupt before the current record we will
    -- just roll back the index by 1. Don't have to do anything
    -- if there are nothing in the schedule.
    scheduler.schedule_index = scheduler.schedule_index - 1
    if scheduler.schedule_index == 0 then scheduler.schedule_index = #schedule_group.schedule end
  end

  scheduler.current_interrupts = Util.deep_copy(interrupt.targets)

  SpaceshipSchedulerGUI.add_interrupt_targets(spaceship,
                                              scheduler.current_interrupts,
                                              scheduler.schedule_index + 1)

  SpaceshipScheduler.force_repath(spaceship)
end

---Increments the target of a triggered interrupt. Should be called
---when the scheduler needs to find the next record to service. It
---will remove the current target from the copied "queue", as
---well as forcing an update on all players who might have this GUI open.
---@param spaceship SpaceshipType
---@param to_number uint? if supplied will increment up until (not including) this number
---@return boolean? active if there is still another interrupt target to service
function SpaceshipScheduler.progress_interrupt_targets(spaceship, to_number)
  local current_interrupts = spaceship.scheduler.current_interrupts
  if not (current_interrupts and next(current_interrupts)) then return end -- Not currently in an interrupt
  if to_number then assert(current_interrupts[to_number]) end

  -- Pop the front off the interrupt "stack". The goal is to maintain the original
  -- target number for every target so that they are unique entries, which makes
  -- updating the GUI much more reliable.
  local target_numbers_to_remove = { }
  local target_number = next(current_interrupts)
  if not to_number then
    current_interrupts[target_number] = nil
    table.insert(target_numbers_to_remove, target_number)

  else
    while target_number and target_number ~= to_number do
      current_interrupts[target_number] = nil
      table.insert(target_numbers_to_remove, target_number)
      target_number = next(current_interrupts)
    end
    if not next(current_interrupts) then spaceship.scheduler.current_interrupts = nil end
  end

  SpaceshipSchedulerGUI.remove_interrupt_targets(spaceship, target_numbers_to_remove)

  -- Return true if there's another target still in the queue to service
  return next(current_interrupts) ~= nil
end

---Clears the current interrupt and make sure it's no longer in the GUI.
---This function should be use when the player manually deletes the entries.
---@param spaceship SpaceshipType
---@param targets uint[]? to remove. Remove all if not supplied
function SpaceshipScheduler.remove_current_interrupt_targets(spaceship, targets)
  local scheduler = spaceship.scheduler
  if not (scheduler.current_interrupts and next(scheduler.current_interrupts)) then return end
  local rerouted = false

  if not targets then
    scheduler.current_interrupts = nil
    -- Spaceship was flying to an interrupt target. Reroute
    SpaceshipScheduler.force_repath(spaceship)
  else
    local current_target_number = next(scheduler.current_interrupts)
    for _, target_number in pairs(targets) do
      scheduler.current_interrupts[target_number] = nil
      if not rerouted and target_number <= current_target_number then
        SpaceshipScheduler.force_repath(spaceship)
        rerouted = true -- Make sure to only do it once
      end
    end
  end

  if not (scheduler.current_interrupts and next(scheduler.current_interrupts)) then
    -- The player manually cleared the last interrupt. The spaceship should then
    -- go to the next record, and not fall back to the previous. In normal operation
    -- this occurs during `progress_schedule`, so we will have to call it here manually.
    SpaceshipScheduler.progress_scheduler(spaceship, true --[[ suppress new interrupts ]])
  end

  -- Always force remove all entries from the GUI. It will be rebuilt.
  SpaceshipSchedulerGUI.remove_interrupt_targets(spaceship, targets)
end

------------------------------------------------
-- EVENTS
------------------------------------------------

---@param event ConfigurationChangedData
function SpaceshipScheduler.migrate_conditions(event)

  -- Make sure all conditions (interrupt and wait) are still referencing valid prototypes.
  -- We can just nil the invalid entries, the logic can handle that.
  local migrations = event.migrations or { }
  do
    ---@param signal_id SignalID
    ---@return boolean
    local function is_valid_signal(signal_id)
      if signal_id.name == "" then return false end -- prototype was removed
      signal_id.type = signal_id.type or "item"
      local signal_prototypes = Util.signal_id_type_to_prototype[signal_id.type]
      if not signal_prototypes then return false end
      return signal_prototypes[signal_id.name] ~= nil
    end

    ---Update the signal. First check if any migrations were applied. And after
    ---that check that the signal is still valid. If it's not, then clear it.
    ---@param container table
    ---@param signal string name of signal in container
    local function update_signal(container, signal)
      local signal_id = container[signal]
      if not signal_id then return end -- There's nothing here
      signal_id.type = signal_id.type or "item"

      -- First try a migration
      local new_name = migrations[signal_id.type] and migrations[signal_id.type][signal_id.name] or nil
      if new_name then
        signal_id.name = new_name -- Note: new name might be "" if prototype is removed. Handled during validity check
      end

      if not is_valid_signal(signal_id) then
        -- The signal is no longer valid, clear it
        container[signal] = nil
      end
    end

    ---@param conditions WaitCondition[]?
    local function sanitize_conditions(conditions)
      if not conditions then return end
      for _, condition in pairs(conditions) do
        local circuit_condition = condition.condition
        if circuit_condition then
          update_signal(circuit_condition, "first_signal")
          update_signal(circuit_condition, "second_signal")
        end
      end
    end

    for _, force_groups in pairs(storage.spaceship_scheduler_groups) do
      for _, group in pairs(force_groups) do
        for _, record in pairs(group.schedule) do
          sanitize_conditions(record.wait_conditions)
        end
      end
    end
    for _, force_interrupts in pairs(storage.spaceship_scheduler_interrupts) do
      for _, interrupt in pairs(force_interrupts) do
        sanitize_conditions(interrupt.conditions)
        for _, target in pairs(interrupt.targets) do
          sanitize_conditions(target.wait_conditions)
        end
      end
    end
    for _, spaceship in pairs(storage.spaceships) do
      if spaceship.scheduler then -- This is required for the canary bug, and this event runs before the migration that fixes it
        for _, target in pairs(spaceship.scheduler.current_interrupts or { }) do
          sanitize_conditions(target.wait_conditions)
        end
      end
    end
  end
end

---@param event EventData.on_forces_merging
local function on_forces_merging(event)
  local from_force_name = event.source.name
  local to_force_name = event.destination.name
  local count = 0 -- of spaceships forced to manual

  do -- Interrupts --
    local to_data = storage.spaceship_scheduler_interrupts[to_force_name] or { }
    storage.spaceship_scheduler_interrupts[to_force_name] = to_data

    for interrupt_name, interrupt in pairs(storage.spaceship_scheduler_interrupts[from_force_name] or { }) do
      assert_interrupt(from_force_name, interrupt, interrupt_name)

      -- First check if we can safely transfer the interrupt. We are very careful and only merge if we are sure there are no problems.
      local can_merge_safely = true
      if to_data[interrupt_name] then
        can_merge_safely = false -- This interrupt name already exists in the new force!
      end
      if can_merge_safely then
        -- See if this interrupt is used by schedule groups which share a name with a group
        -- in the destination force. Don't want to deal with non-conflicting interrupts
        -- which connect to conflicting schedule group names.
        local to_groups = storage.spaceship_scheduler_groups[to_force_name] or { }
        for schedule_group_names in pairs(interrupt.schedules) do
          if to_groups[schedule_group_names] then
            can_merge_safely = false
          end
        end
      end

      if can_merge_safely then
        to_data[interrupt_name] = interrupt
      else
        -- This interrupt is not safe to merge!
        -- We will remove it completely and set all spaceships that used such an interrupt to manual
        for schedule_group_name in pairs(interrupt.schedules) do
          SpaceshipScheduler.remove_interrupt_from_schedule_group(from_force_name, schedule_group_name, interrupt_name)

          local schedule_group = storage.spaceship_scheduler_groups[from_force_name][schedule_group_name] -- Groups have not been migrated yet
          for spaceship_index in pairs(schedule_group and schedule_group.spaceships or { }) do
            local spaceship = storage.spaceships[spaceship_index]
            if spaceship and spaceship.scheduler.active then
              count = count + 1
              SpaceshipScheduler.deactivate(spaceship)
              log("Merging forces: Forced spaceship `" .. spaceship.name .. "` [Index: "..spaceship.index.."] to manual")
            end
          end
        end
      end
    end

    storage.spaceship_scheduler_interrupts[from_force_name] = nil
  end

  do -- Schedule Groups --
    local from_data = storage.spaceship_scheduler_groups[from_force_name] or { }
    storage.spaceship_scheduler_groups[to_force_name] = storage.spaceship_scheduler_groups[to_force_name] or { }
    local to_data = storage.spaceship_scheduler_groups[to_force_name]

    for schedule_name, schedule_group in pairs(from_data) do
      if not to_data[schedule_name] then
        to_data[schedule_name] = schedule_group
      else
        -- This group_name already exists in the destination force. Let's
        -- use the destination force as trutnd disable scheduler on
        -- all eships. They will already be pointing to the new schedule
        -- Also assign them to the destination group
        for spaceship_index, v in pairs(schedule_group.spaceships) do
          to_data[schedule_name].spaceships[spaceship_index] = v

          local spaceship = storage.spaceships[spaceship_index]
          if spaceship and spaceship.scheduler.active then
            count = count + 1
            SpaceshipScheduler.deactivate(spaceship)
            log("Merging forces: Forced spaceship `" .. spaceship.name .. "` to manual")
          end
        end
      end
    end
    storage.spaceship_scheduler_groups[from_force_name] = nil
  end

  -- Make sure we didn't break anything
  for schedule_name in pairs(storage.spaceship_scheduler_groups[to_force_name]) do
    SpaceshipScheduler.assert_schedule_group(to_force_name, schedule_name)
  end
  for interrupt_name, interrupt in pairs(storage.spaceship_scheduler_interrupts[to_force_name]) do
    assert_interrupt(to_force_name, interrupt, interrupt_name)
  end
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.force_name == to_force_name then
      SpaceshipScheduler.assert_scheduler(spaceship)
    end
  end

  if count > 0 then
    -- Don't know if can print for a specific force due to it being deleted soon.
    game.print("Merging forces forced "..count.." spaceship(s) to manual due to conflicting schedule groups and interrupts! See game log.")
  end
end
Event.addListener(defines.events.on_forces_merging, on_forces_merging)

function SpaceshipScheduler.on_init()
  storage.spaceship_scheduler_groups = { }
  storage.spaceship_scheduler_interrupts = { }
end
Event.addListener("on_init", SpaceshipScheduler.on_init, true)

---@param event ConfigurationChangedData
function SpaceshipScheduler.on_post_migrations(event)
  -- This is run here, because the migratio scrips are run after the local on_configuration_changed

  SpaceshipScheduler.migrate_conditions(event)

  -- Make sure nothing is broken after all migrations are run.
  for force_name, schedule_groups in pairs(storage.spaceship_scheduler_groups or { }) do
    for group_name, _ in pairs(schedule_groups) do
      SpaceshipScheduler.assert_schedule_group(force_name, group_name)
    end
  end
end
Event.addListener("on_post_migrations", SpaceshipScheduler.on_post_migrations, true)

return SpaceshipScheduler
