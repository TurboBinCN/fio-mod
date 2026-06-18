local SpaceshipSchedulerReservations = { }

------------------------------------------------
-- INTERFACE
------------------------------------------------

---@param clamp_info SpaceshipClampInfo
---@param spaceship SpaceshipType?
---@return boolean has_open_slot or spaceship already has reservation
function SpaceshipSchedulerReservations.clamp_has_open_slot(clamp_info, spaceship)
  if spaceship and clamp_info.spaceship_reservations[spaceship.index] then return true end -- already has reservation
  return table_size(clamp_info.spaceship_reservations) < (clamp_info.spaceship_limit or math.huge)
end

---@param clamp_info SpaceshipClampInfo
---@return boolean occupied if an automated spaceship is currently holding an anchored reservation
function SpaceshipSchedulerReservations.clamp_ready_for_anchor(clamp_info)
  -- We don't care if the limit is zero. If the spaceship has a reservation
  -- it should be able to land.
  for _, reservation in pairs(clamp_info.spaceship_reservations) do
    if reservation.valid and reservation.status == "anchored" then
      return true
    end
  end
  return false
end

---@param spaceship SpaceshipType
---@param destination_descriptor SpaceshipSchedulerDestinationDescriptor
---@param minimum_priority uint? that will be considered
---@return SpaceshipClampInfo? clamp_indfo of the clamp found. Will choose a random clamp every time
---@return boolean? if at least one valid clamp was found in this zone
function SpaceshipSchedulerReservations.zone_has_open_slot(spaceship, destination_descriptor, minimum_priority)
  local best_priority = minimum_priority or -math.huge
  local found_at_least_one_clamp = false

  local viable_clamps = { } --[[@as SpaceshipClampInfo[] ]]

  local tick = game.tick
  local clamp_descriptor = destination_descriptor.clamp
  assert(clamp_descriptor)
  assert(destination_descriptor.zone_pointer)

  -- Get the surface name from the zone index.
  -- TODO Change spaceship clamp tables to also use zone pointers to make this lookup much faster
  local zone = storage.zone_index[destination_descriptor.zone_pointer] -- Assuming it's not a spaceship
  if not zone then return end
  local surface = Zone.get_surface(zone)
  if not surface then return end

  for _, clamp_info in pairs(storage.spaceship_clamps_by_surface[surface.name] or { }) do
    local clamp = clamp_info.main
    if not (clamp and clamp.valid) then goto continue end
    if clamp_info.force_name ~= spaceship.force_name then goto continue end
    if clamp_descriptor.direction ~= clamp_info.direction then goto continue end
    if clamp_descriptor.tag and clamp_descriptor.tag ~= clamp_info.tag then goto continue end
    if clamp_descriptor.id then
      local id = SpaceshipClamp.read_id(clamp_info)
      if not (id and id == clamp_descriptor.id) then goto continue end
    end
    if clamp.to_be_deconstructed() then goto continue end
    if clamp_info.grace_period_until and tick < clamp_info.grace_period_until then goto continue end

    found_at_least_one_clamp = true

    if clamp_info.priority < best_priority then goto continue end -- Don't check equality, because we want all possible clamps
    if not SpaceshipSchedulerReservations.clamp_has_open_slot(clamp_info, spaceship) then goto continue end

    if clamp_info.priority > best_priority then
      best_priority = clamp_info.priority
      viable_clamps = { clamp_info }
    else
      table.insert(viable_clamps, clamp_info)
    end

    ::continue::
  end

  local best_clamp = next(viable_clamps) and viable_clamps[math.random(#viable_clamps)] or nil
  return best_clamp, found_at_least_one_clamp
end

---Makes a reservation for a ship in a zone. This will not check if there
---is still space in the zone and increment the count regardless.
---Only links the reservation to the clamp. Linking spaceship should be done by caller.
---@param spaceship SpaceshipType
---@param clamp_info SpaceshipClampInfo
---@param status "on-route"|"near"|"anchored"
---@return SpaceshipSchedulerReservation? reservation if successful
function SpaceshipSchedulerReservations.make_reservation(spaceship, clamp_info, status)
  -- It's important to not simply overwrite a previous reservation. Reservations tables are shared
  -- by reference between spaceship and clamp so it's dangerous to simply overwrite something. And
  -- it's also not how the state machine is built.
  assert(not clamp_info.spaceship_reservations[spaceship.index], "spaceship `"..spaceship.name.."` already has a reservation at clamp '"..clamp_info.tag.."'")
  local zone = Zone.from_surface_name(clamp_info.surface_name)
  assert(zone)

  local reservation = {
    valid = true,
    spaceship_index = spaceship.index,
    status = status,
    clamp_unit_number = clamp_info.unit_number,
    zone_pointer = zone.index,
  } --[[@as SpaceshipSchedulerReservation]]

  clamp_info.spaceship_reservations[spaceship.index] = reservation
  return reservation
end

---Updates a reservation status. Will ensure that the new entry exists.
---@param reservation SpaceshipSchedulerReservation
---@param status "on-route"|"near"|"anchored"
---@return boolean success could fail if the clamp has been deleted or something
function SpaceshipSchedulerReservations.update_reservation(reservation, status)
  if not reservation.valid then return false end
  reservation.status = status
  return true
end

---Invalidates the reservation and removes the linkage in the spaceship clamp
---Remove the now invalid reservation from the spaceship should be done by the caller.
---@param reservation SpaceshipSchedulerReservation
function SpaceshipSchedulerReservations.remove_reservation(reservation)
  reservation.valid = false
  local clamp_info = storage.spaceship_clamps[reservation.clamp_unit_number]
  if clamp_info then
    clamp_info.spaceship_reservations[reservation.spaceship_index] = nil
  end
end

---Moves a reservation from one clamp to the other from the spaceship's perspective.
---Meaning the reservation tables will remain linked to the original spaceships,
---and we change which clamp it's linked to.
---@param from_clamp_info SpaceshipClampInfo
---@param to_clamp_info SpaceshipClampInfo
---@param reservation SpaceshipSchedulerReservation
function SpaceshipSchedulerReservations.move_reservation(from_clamp_info, to_clamp_info, reservation)
  assert(reservation.status ~= "anchored")
  local from_reservations = from_clamp_info.spaceship_reservations
  assert(from_reservations[reservation.spaceship_index] == reservation)
  assert(reservation.clamp_unit_number == from_clamp_info.unit_number)

  to_clamp_info.spaceship_reservations[reservation.spaceship_index] = reservation
  reservation.clamp_unit_number = to_clamp_info.unit_number
  from_reservations[reservation.spaceship_index] = nil

  assert(storage.spaceships[reservation.spaceship_index].scheduler.future_reservation == reservation)
  assert(storage.spaceship_clamps[reservation.clamp_unit_number].spaceship_reservations[reservation.spaceship_index] == reservation)
end

---Randomly move the supplied reservation to a similar clamp in the same zone.
---Useful to allow spaceships to randomize landing attempts to when an clamp
---is blocked.
---Only clamps are considered that:
---     - match exactly
---     - Has a spaceship limit of > 1
---     - Has the same priority or higher than the original clamp.
---     - Either has no anchored spaceship, or have an on-route reservation.
---@param reservation SpaceshipSchedulerReservation
function SpaceshipSchedulerReservations.smart_zonal_reroute(reservation)
  local clamp_info = storage.spaceship_clamps[reservation.clamp_unit_number]
  if not clamp_info then return end
  local id = SpaceshipClamp.read_id(clamp_info)
  if not id then return end

  local tick = game.tick
  local viable_clamps = { } --[[@as SpaceshipClampInfo[] ]]
  local best_priority = clamp_info.priority

  for _, other_clamp_info in pairs(storage.spaceship_clamps_by_surface[clamp_info.surface_name] or { }) do
    ---@cast other_clamp_info SpaceshipClampInfo
    if other_clamp_info.unit_number == clamp_info.unit_number then goto continue end
    local other_clamp = other_clamp_info.main
    if not (other_clamp and other_clamp.valid) then goto continue end
    if other_clamp_info.force_name ~= clamp_info.force_name then goto continue end
    if other_clamp_info.direction ~= clamp_info.direction then goto continue end
    if other_clamp_info.tag ~= clamp_info.tag then goto continue end
    if other_clamp_info.priority < clamp_info.priority then goto continue end -- We do equal breaker later
    if other_clamp_info.grace_period_until and tick < other_clamp_info.grace_period_until then goto continue end
    if other_clamp.to_be_deconstructed() then goto continue end
    local other_id = SpaceshipClamp.read_id(other_clamp_info)
    if not other_id or other_id ~= id then goto continue end

    -- This is a clamp that match our original clamp!

    if other_clamp_info.spaceship_limit == 0 then goto continue end -- Has no space anyway

    local has_on_route = false
    for _, other_reservation in pairs(other_clamp_info.spaceship_reservations) do
      if other_reservation.status == "anchored" then
        goto continue -- Already a ship docked here
      elseif other_reservation.status == "on-route" then
        has_on_route = true
        break
      end
    end

    -- Not a viable candidate if this clamp has no open slots, and there's no
    -- spaceships on route that we can swap reservations with
    if
      not has_on_route
      and not SpaceshipSchedulerReservations.clamp_has_open_slot(other_clamp_info)
    then goto continue end

    -- This is a viable candidate to move the reservation to!
    if other_clamp_info.priority > best_priority then
      best_priority = other_clamp_info.priority
      viable_clamps = { other_clamp_info }
    else
      table.insert(viable_clamps, other_clamp_info)
    end

    ::continue::
  end

  if not next(viable_clamps) then return end -- Nothing to swap with

  -- Choose the clamp that we will change our reservation too, and then move the reservation
  local other_clamp_info = viable_clamps[math.random(#viable_clamps)] --[[@cast other_clamp_info -?]]
  for _, other_reservation in pairs(other_clamp_info.spaceship_reservations) do
    if other_reservation.status == "on-route" then
      -- We might reach here even if this clamp has not reached it limit, so technically
      -- we don't have to move the reservation. But we can just as well do it now because
      -- this clamp might now be occupied, so it might have to move anyway.
      SpaceshipSchedulerReservations.move_reservation(other_clamp_info, clamp_info, other_reservation)
      break
    end
  end
  SpaceshipSchedulerReservations.move_reservation(clamp_info, other_clamp_info, reservation)
end

---Go through all reservation tables and ensure there's no booking for this
---spaceship. This call is non-trivial UPS-wise and should not be called often.
---@param spaceship SpaceshipType
function SpaceshipSchedulerReservations.forcibly_remove_all_reservations(spaceship)
  spaceship.scheduler.anchored_reservation = nil
  spaceship.scheduler.future_reservation = nil
  local spaceship_index = spaceship.index
  for _, clamp_info in pairs(storage.spaceship_clamps) do
    clamp_info.spaceship_reservations[spaceship_index] = nil
  end
end

---Executes a function with each zone with some reservation information
---@param fn fun(zone_pointer:ZonePointer)
---@param star_restriction StarType? If supplied only zones around this star will be considered
function SpaceshipSchedulerReservations.apply_for_each_zone_with_clamps(fn, star_restriction)
  if star_restriction then
    Zone.apply_for_each_child_and_orbit(star_restriction, function(zone)
      fn(zone.index)
    end)
  else
    for surface_name, _ in pairs(storage.spaceship_clamps_by_surface) do
      local zone = Zone.from_surface_name(surface_name)
      if zone then fn(zone.index) end
    end
  end
end

---Returns a unique list of all tags used by a specific clamp type across all tracked zones.
---This call is also non-trivial UPS wise, only used for UI.
---@param force_name string
---@param destination_descriptor SpaceshipSchedulerDestinationDescriptor
---@param star_restriction StarType? If supplied only zones around this star will be considered
---@param ignore_spaceship SpaceshipType? Any clamps registered to this spaceship will be ignored (only works if integrity check has been run)
---@return string[]
function SpaceshipSchedulerReservations.get_all_tags_for_destination_descriptor(force_name, destination_descriptor, star_restriction, ignore_spaceship)
  local clamp_descriptor = destination_descriptor.clamp
  assert(clamp_descriptor)

  local tags = { }        --[[@as string[] ]]
  local tags_map = { }    --[[@as table<string, boolean> ]]
  local count_tags = 0

  local unit_numbers_to_ignore = { } --[[@as table<uint, boolean> ]]
  if ignore_spaceship then
    for _, clamp_info in pairs(SpaceshipClamp.get_clamps_on_spaceship(ignore_spaceship)) do
      unit_numbers_to_ignore[clamp_info.unit_number] = true
    end
  end

  SpaceshipSchedulerReservations.apply_for_each_zone_with_clamps(function (zone_pointer)
    if destination_descriptor.zone_pointer and destination_descriptor.zone_pointer ~= zone_pointer then return end

    -- Get the surface name from the zone index.
    -- TODO Change spaceship clamp tables to also use zone pointers to make this lookup much faster
    local clamps_on_surface = { }
    local zone = storage.zone_index[zone_pointer] -- Assuming it's not a spaceship
    local surface = Zone.get_surface(zone)
    if surface then
      clamps_on_surface = storage.spaceship_clamps_by_surface[surface.name] or { }
    end

    for _, clamp_info in pairs(clamps_on_surface) do
      local clamp = clamp_info.main
      if not (clamp and clamp.valid) then goto continue end
      if clamp_info.force_name ~= force_name then goto continue end
      if clamp_descriptor.direction ~= clamp_info.direction then goto continue end
      if unit_numbers_to_ignore[clamp_info.unit_number] then goto continue end
      -- Note: We ignore the clamp tag, since we are looking for all tags
      if clamp_descriptor.id then
        local id = SpaceshipClamp.read_id(clamp_info)
        if not (id and id == clamp_descriptor.id) then goto continue end
      end

      local tag = clamp_info.tag
      if not tags_map[tag] then   -- Ensure we haven't added this tag to the list already
        count_tags = count_tags + 1
        tags[count_tags] = tag
        tags_map[tag] = true
      end

      ::continue::
    end
  end, star_restriction)

  return tags
end

return SpaceshipSchedulerReservations
