local DeliveryCannon = {}

DeliveryCannon.variants = {
  ["logistic"] = {
    name = mod_prefix.."delivery-cannon",
    name_energy_interface = mod_prefix.."delivery-cannon-energy-interface",
    name_beam = mod_prefix.."delivery-cannon-beam",
    beam_offset = {x = -0.5, y = -5},
    name_capsule = mod_prefix.."delivery-cannon-capsule",
    name_capsule_projectile = mod_prefix.."delivery-cannon-capsule-artillery-projectile",
    energy_per_delta_v = 50000,
  },
  ["weapon"] = {
    name = mod_prefix.."delivery-cannon-weapon",
    name_energy_interface = mod_prefix.."delivery-cannon-weapon-energy-interface",
    name_beam = mod_prefix.."delivery-cannon-weapon-beam",
    beam_offset = {x = -1, y = -5},
    name_capsule = mod_prefix.."delivery-cannon-weapon-capsule",
    name_capsule_projectile = mod_prefix.."delivery-cannon-weapon-capsule-artillery-projectile",
    energy_per_delta_v = 500000,
  }
}

DeliveryCannon.name_delivery_cannon_chest = mod_prefix.."delivery-cannon-chest"

DeliveryCannon.name_delivery_cannon_capsule_shadow = mod_prefix.."delivery-cannon-capsule-shadow"
DeliveryCannon.name_delivery_cannon_capsule_explosion = mod_prefix.."delivery-cannon-capsule-explosion"

DeliveryCannon.name_delivery_cannon_targeter = mod_prefix.."delivery-cannon-targeter"

DeliveryCannon.capsule_fall_altitude = 100
DeliveryCannon.capsule_fall_time = 2 * 60

DeliveryCannon.mode_off = "off"
DeliveryCannon.mode_single_target = "single-target"
DeliveryCannon.mode_automatic_retarget = "automatic-retarget"
DeliveryCannon.mode_artillery = "artillery"

DeliveryCannon.weapon_delivery_cannon_electric_buffer_size = 10000000000 -- same as energy_source.buffer_capacity in the prototype
DeliveryCannon.ammo_prefix_len_payload = string.len(mod_prefix.."delivery-cannon-weapon-package-")
DeliveryCannon.ammo_prefix_len_recipe = string.len(mod_prefix.."delivery-cannon-weapon-pack-")
DeliveryCannon.ammo_prefix_targeter = mod_prefix.."delivery-cannon-artillery-targeter-"
DeliveryCannon.ammo_prefix_len_targeter = string.len(mod_prefix.."delivery-cannon-artillery-targeter-")
-- note that timeout_artillery_requests should be less than the early_death_ticks specified on the artillery flare,
-- so the flare does not visually disappear before we time it out in the script
DeliveryCannon.timeout_artillery_requests = 60 * settings.startup[mod_prefix.."delivery-cannon-artillery-timeout"].value
DeliveryCannon.tick_interval_remove_delayed_artillery_requests = 60 * 60
DeliveryCannon.name_event_copy_entity_settings = mod_prefix.."copy-entity-settings"

---Gets the DeliveryCannonInfo for given unit_number.
---@param unit_number uint
---@return DeliveryCannonInfo?
function DeliveryCannon.from_unit_number (unit_number)
  if not unit_number then Log.debug("DeliveryCannon.from_unit_number: invalid unit_number: nil") return end
  unit_number = tonumber(unit_number)
  -- NOTE: only supports container as the entity
  if storage.delivery_cannons[unit_number] then
    return storage.delivery_cannons[unit_number]
  else
    Log.debug("DeliveryCannon.from_unit_number: invalid unit_number: " .. unit_number)
  end
end

---Gets the DeliveryCannonInfo for given entity.
---@param entity LuaEntity
function DeliveryCannon.from_entity (entity)
  if not(entity and entity.valid) then
    Log.debug("DeliveryCannon.from_entity: invalid entity")
    return
  end
  -- NOTE: only supports container as the entity
  return DeliveryCannon.from_unit_number(entity.unit_number)
end

---Computes the cost to launch a delivery cannon.
---@param origin AnyZoneType Launch zone
---@param destination AnyZoneType Destination zone
function DeliveryCannon.get_delta_v(origin, destination)
  if origin and destination then
    return Zone.get_launch_delta_v(origin) + Zone.get_travel_delta_v(origin, destination)
  end
end

---Gets the coordinate the delivery cannon is targetting.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
function DeliveryCannon.get_coordinate(delivery_cannon)
  if delivery_cannon.destination and delivery_cannon.destination.coordinate then
    return delivery_cannon.destination.coordinate
  end
  return nil
end

---Does the delivery cannon have a destination set?
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
---@return boolean has_destination
function DeliveryCannon.has_destination(delivery_cannon)
  return (delivery_cannon and delivery_cannon.destination and delivery_cannon.destination.coordinate and delivery_cannon.destination.zone) ~= nil
end

---Returns whether this delivery cannon is valid.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
---@return boolean is_valid
function DeliveryCannon.is_valid(delivery_cannon)
  return delivery_cannon and delivery_cannon.main and delivery_cannon.main.valid
  and delivery_cannon.energy_interface and delivery_cannon.energy_interface.valid
end

---Returns whether the destination zone is reachable for a given delivery cannon.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
---@param dest? AnyZoneType Zone in which candidate target is located
---@return boolean is_reachable
function DeliveryCannon.is_reachable_destination(delivery_cannon, dest)
  if not dest then return false end

  local source = delivery_cannon.zone
  local is_reachable

  if source == dest then
    -- Delivery within the same zone is always valid
    is_reachable = true
  elseif source.type == "anomaly" or dest.type == "anomaly" or dest.type == "asteroid-field" then
    -- Delivery cannons can't deliver to or from anomaly, or to an asteroid field
    is_reachable = false
  elseif source.type == "asteroid-field" then
    -- Delivery cannons on asteroid fields can only deliver to zones within their nearest star system
    is_reachable = Zone.get_star_from_child(dest) == Zone.find_nearest_star(source.stellar_position) and true or false
  else
    -- Only zone types left are directly associated with a star; parent stars have to match
    is_reachable = Zone.get_star_from_child(source) == Zone.get_star_from_child(dest) and true or false
  end

  return is_reachable
end

---Returns if this delivery cannon can fire.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
function DeliveryCannon.can_fire(delivery_cannon)
  return delivery_cannon and (delivery_cannon.mode ~= DeliveryCannon.mode_off)
  and delivery_cannon.energy and delivery_cannon.required_energy
  and delivery_cannon.energy >= delivery_cannon.required_energy
end

local get_stack_from_filled_capsule_name = {}
for _, recipe in pairs(prototypes.recipe) do
  local product = recipe.products[1]
  if string.find(recipe.name, "se-delivery-cannon-pack-", 1, true) then
    for _, ingredient in pairs(recipe.ingredients) do
      if ingredient.name ~= DeliveryCannon.variants["logistic"].name_capsule then
        get_stack_from_filled_capsule_name[product.name] = {name = ingredient.name, count = ingredient.amount}
      end
    end
  elseif string.find(recipe.name, "se-delivery-cannon-weapon-pack-", 1, true) then
    local ammo_name = Util.replace(recipe.name, "se-delivery-cannon-weapon-pack-", "")
    assert(prototypes.item[ammo_name]) -- scream test, was an if before but why?
    get_stack_from_filled_capsule_name[product.name] = {name = ammo_name, count = 1}
  end
end

---Gets the stack that this delivery cannon is ready to fire.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
---@return ItemStackDefinition? stack
function DeliveryCannon.get_stack(delivery_cannon)
  local stack = delivery_cannon.main.get_inventory(defines.inventory.crafter_output)[1]
  if not stack.valid_for_read then return end

  local item = get_stack_from_filled_capsule_name[stack.name]
  if not item then return end -- a non-capsule is in the output slot (like spoiled ingredients)

  return {
    name = item.name,
    count = item.count,
    quality = stack.quality,
    spoil_percent = stack.spoil_percent, -- spoil percentage unintentionally paused during transit, but lets attribute it to the coldness of space.
  }
end

---Displays a message that the delivery cannon projectile was destroyed by an opposing force.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
---@param defence_data {[string]:MeteorDefenceShootingInfo} Info about the destruction
---@param target_zone AnyZoneType Zone the delivery cannon was firing at
function DeliveryCannon.display_destroyed_projectile_message(delivery_cannon, defence_data, target_zone)
  game.forces[delivery_cannon.force_name].print({
    "space-exploration.delivery_cannon_canister_destroyed_by",
      Zone.get_print_name(delivery_cannon.zone), Zone.get_print_name(target_zone)})
  for force_name, shots_fired in pairs(defence_data) do
    game.forces[force_name].print({"space-exploration.delivery_cannon_defended_canister",
      Zone.get_print_name(target_zone), shots_fired.defence_shots, shots_fired.point_defence_shots})
  end
end

---Displays a message that the delivery cannon projectile was not destroyed by an opposing force.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
---@param defence_data {[string]:MeteorDefenceShootingInfo} Info about the (failed) destruction
---@param target_zone AnyZoneType Zone the delivery cannon was firing at
function DeliveryCannon.display_not_destroyed_projectile_message(delivery_cannon, defence_data, target_zone)
  for force_name, shots_fired in pairs(defence_data) do
    game.forces[force_name].print({"space-exploration.delivery_cannon_defended_canister_failed",
      Zone.get_print_name(target_zone), shots_fired.defence_shots, shots_fired.point_defence_shots})
  end
end

---Sets delivery cannon target to `coordinates` in `target_zone` and updates its required energy.
---If a non-nil zone is passed, validates it for the given delivery cannon and prints outs a
---message for the player that triggered the action if it was invalid.
---Returns true if the function modified the cannon's zone (including setting it to nil)
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
---@param player LuaPlayer|nil player who should receive a message if target zone is not valid
---@param target_zone? AnyZoneType Zone table or nil to set no destination
---@param coordinates? MapPosition Coordinates table if available
---@return boolean is_successful
function DeliveryCannon.set_target(delivery_cannon, player, target_zone, coordinates)
  local is_successful

  if target_zone then
    -- Check if zone is reachable from the given delivery cannon
    if DeliveryCannon.is_reachable_destination(delivery_cannon, target_zone) then
      --Check if coordinates are out of bound
      if coordinates and target_zone.radius and util.vector_length(coordinates) > target_zone.radius then
        if player then
          player.print({"space-exploration.target-out-of-bounds",
            "item/" .. DeliveryCannon.variants[delivery_cannon.variant].name,
            Zone.get_print_name(target_zone),
            math.floor(coordinates.x),
            math.floor(coordinates.y)})
        end
        return false
      end

      -- Set the delivery cannon properties accordingly and calculate its required_energy
      delivery_cannon.destination.zone = target_zone
      delivery_cannon.destination.coordinate = coordinates
      delivery_cannon.required_energy =
        (DeliveryCannon.variants[delivery_cannon.variant].energy_per_delta_v *
        DeliveryCannon.get_delta_v(delivery_cannon.zone, target_zone))

      is_successful = true
      Log.debug("set destination to location: " .. target_zone.name )
    else
      -- Inform the player that the chosen target_zone was not reachable
      if player then
        player.print({"space-exploration.delivery-cannon-invalid-destination",
          Zone.get_print_name(delivery_cannon.zone), Zone.get_print_name(target_zone)})
      end

      is_successful = false
      Log.debug("attempted to set unreachable destination: " .. target_zone.name)
    end
  else
    -- This executes if a nil target_zone was passed to the function
    delivery_cannon.destination.zone = nil
    delivery_cannon.destination.coordinate = nil
    delivery_cannon.required_energy = nil

    is_successful = true
  end

  return is_successful
end

---Picks a new target for a delivery cannon.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
---@param target_zone AnyZoneType Zone to pick a target from
---@param target_surface LuaSurface Surface to pick a target from
function DeliveryCannon.pick_new_target(delivery_cannon, target_zone, target_surface)
  local random_chunk = target_surface.get_random_chunk()
  local position = {x = (random_chunk.x + math.random()) * 32, y = (random_chunk.y + math.random()) * 32}
  if target_zone.radius and Util.vector_length(position) > target_zone.radius then
     position = Util.vector_set_length(position, target_zone.radius * math.random())
  end
  if math.random() < 0.99 then
    local enemy = find_enemy(game.forces[delivery_cannon.force_name], target_surface, position)
    if enemy then
      position = enemy.position
    else
      delivery_cannon.mode = DeliveryCannon.mode_off

      game.forces[delivery_cannon.force_name].print({
        "space-exploration.delivery-cannon-no-enemies-found",
        "[gps="..math.floor(delivery_cannon.main.position.x)..","..math.floor(delivery_cannon.main.position.y)..","..delivery_cannon.main.surface.name.."]"
        })
    end
  end
  delivery_cannon.destination.coordinate = position
end

---Clears the target from the delivery cannon.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
function DeliveryCannon.clear_target(delivery_cannon)
  DeliveryCannon.set_target(delivery_cannon, nil, nil, nil)
end

---Adds a delivery cannon to a force's zone assets.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
function DeliveryCannon.add_delivery_cannon_to_table(delivery_cannon)
  local type_table = DeliveryCannon.get_delivery_cannon_type_table(delivery_cannon)
  type_table[delivery_cannon.unit_number] = delivery_cannon
end

---Gets the delivery cannon zone assets.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
function DeliveryCannon.get_delivery_cannon_type_table(delivery_cannon)
  local zone_assets = Zone.get_force_assets(delivery_cannon.force_name, delivery_cannon.zone.index)
  zone_assets.delivery_cannons = zone_assets.delivery_cannons or {}
  return zone_assets.delivery_cannons
end

---Removes a delivery cannon from a force's zone assets.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
function DeliveryCannon.remove_delivery_cannon_from_table(delivery_cannon)
  local type_table = DeliveryCannon.get_delivery_cannon_type_table(delivery_cannon)
  if not type_table[delivery_cannon.unit_number] then return end
  type_table[delivery_cannon.unit_number] = nil
end

---Checks whether there are no delivery cannons of a particular force in range of a taret zone.
---The delivery cannons must have the same ammo type and be within their maximum range of the target zone.
---@param target_zone AnyZoneType Zone the delivery cannons should fire at
---@param force_name string The name of the force for which this target should be enqueued
---@param ammo_type string The name of the ammo type we want to target this spot with
---@return boolean success Whether the target could be enqueued
function DeliveryCannon.none_in_range_of_target(target_zone, force_name, ammo_type)
  local surface = Zone.get_surface(target_zone)
  if not surface then return false end

  local force_assets = Zone.get_all_force_assets(force_name)
  if not force_assets then return true end

  for zone_index, zone_assets in pairs(force_assets) do
    local required_energy_from_zone = nil
    if zone_assets.delivery_cannons then
      for unit_number, delivery_cannon in pairs(zone_assets.delivery_cannons) do
        if delivery_cannon.main and delivery_cannon.main.valid and delivery_cannon.energy_interface and delivery_cannon.energy_interface.valid and delivery_cannon.mode == DeliveryCannon.mode_artillery then
          -- only calculate the energy required to fire from the delivery cannon's zone to the target zone once per zone
          if not required_energy_from_zone then
            required_energy_from_zone = DeliveryCannon.variants[delivery_cannon.variant].energy_per_delta_v * DeliveryCannon.get_delta_v(delivery_cannon.zone, target_zone)
          end
          if required_energy_from_zone < DeliveryCannon.weapon_delivery_cannon_electric_buffer_size then
            local recipe = delivery_cannon.main.get_recipe()
            if recipe then
              local recipe_ammo_type = string.sub(recipe.name, DeliveryCannon.ammo_prefix_len_recipe + 1)
              if recipe_ammo_type == ammo_type then
                return false
              end
            end
          end
        end
      end
    end
  end

  return true
end

---Enqueues a target for the delivery cannons of a particular force.
---@param target_zone AnyZoneType Zone the delivery cannons should fire at
---@param coordinates MapPosition Coordinates the delivery cannons should fire at
---@param force_name string The name of the force for which this target should be enqueued
---@param ammo_type string The name of the ammo type we want to target this spot with
---@return boolean success Whether the target was successfully enqueued
function DeliveryCannon.enqueue_target(target_zone, coordinates, force_name, ammo_type)
  storage.delivery_cannon_queues[force_name] = storage.delivery_cannon_queues[force_name] or {}
  storage.delivery_cannon_queues[force_name][ammo_type] = storage.delivery_cannon_queues[force_name][ammo_type] or {}
  storage.delivery_cannon_queues[force_name][ammo_type][target_zone.index] = storage.delivery_cannon_queues[force_name][ammo_type][target_zone.index] or Queue.new()
  local surface = Zone.get_surface(target_zone)
  if surface then
    -- create the artillery flare (visual only)
    local flare = surface.create_entity{
      name = mod_prefix.."dummy-artillery-flare-"..ammo_type,
      position = coordinates,
      force = game.forces[force_name],
      movement = {0.0,0.0},
      height = 0.0,
      vertical_speed = 0.0,
      frame_speed = 1.0
    }
    ---@cast flare -?
    -- store the target in the appropriate queue
    Queue.push_right(storage.delivery_cannon_queues[force_name][ammo_type][target_zone.index], {
      zone = target_zone,
      coordinate = coordinates,
      flare = flare, -- maintain a reference to the flare so it can be destroyed at the correct time
      end_tick = game.tick + DeliveryCannon.timeout_artillery_requests -- if no weapon delivery cannon fires at this target before end_tick, it may be cleaned up by remove_stale_artillery_targets
    })
  end

  return true
end

---Dequeues and cleans up all artillery targets that have passed their end_tick
---@param event EventData.on_tick
function DeliveryCannon.remove_stale_artillery_targets(event)
  for force_name, queues_by_ammo_type_by_zone_index in pairs(storage.delivery_cannon_queues) do
    -- per force removal stats for use in displaying a message to notify the player of timed out artillery requests
    local removed_count = 0
    local last_removed = nil
    for _, queues_by_zone_index in pairs(queues_by_ammo_type_by_zone_index) do
      for zone_index, queue in pairs(queues_by_zone_index) do
        if not Queue.is_empty(queue) then
          local node = Queue.head(queue)
          while node do
            -- save the next before removing from the list
            local next = node.next
            if event.tick >= node.value.end_tick then
              Queue.remove(queue, node)
              last_removed = node.value
              -- cleanup the flare and map tag if the artillery request expires
              if last_removed.flare and last_removed.flare.valid then
                last_removed.flare.destroy()
              end
              removed_count = removed_count + 1
            end
            node = next
          end
          -- make empty queues available for garbage collection
          if Queue.is_empty(queue) then
            Log.debug("set queue for "..zone_index.." to nil")
            queues_by_zone_index[zone_index] = nil
          end
        end
      end
    end
    if removed_count > 0 then
      -- displays detailed info only about the last_removed target so if there were multiple targets removed in the same cleanup only one of them
      -- will be shown to the player force - this prevents chat spam because this cleanup only runs very periodically so it can grab multiple
      -- at once - however, the removed_count is still shown so the player is aware of how many timed out
      game.forces[force_name].print({"space-exploration.delivery-cannon-artillery-target-timed-out",
        "item/" .. DeliveryCannon.variants["weapon"].name,
        Zone.get_print_name(last_removed.zone),
        math.floor(last_removed.coordinate.x),
        math.floor(last_removed.coordinate.y),
        (removed_count > 1) and {"space-exploration.delivery-cannon-artillery-target-timed-out-extras", removed_count - 1} or ""
      })
    end
  end
end

---Fires a delivery cannon if it's ready to fire.
---@param delivery_cannon DeliveryCannonInfo Delivery cannon data
function DeliveryCannon.attempt_fire(delivery_cannon)
  -- only fire cannons that are valid
  if not DeliveryCannon.is_valid(delivery_cannon) then DeliveryCannon.destroy(delivery_cannon) return end
  delivery_cannon.energy = delivery_cannon.energy_interface.energy

  -- get payload_name for use in gui
  local cannon_inv = delivery_cannon.main.get_output_inventory()
  delivery_cannon.payload_name = nil
  delivery_cannon.payload_count = 0
  for _, item in pairs(cannon_inv.get_contents()) do -- should only be 1
    delivery_cannon.payload_name = item.name
    delivery_cannon.payload_count = item.count
  end

  -- cannons that aren't in artillery mode must also have a valid destination, and have enough energy to fire at that destination
  if delivery_cannon.mode ~= DeliveryCannon.mode_artillery then
    if not DeliveryCannon.has_destination(delivery_cannon) then return end
    if not delivery_cannon.required_energy then
      delivery_cannon.required_energy = DeliveryCannon.variants[delivery_cannon.variant].energy_per_delta_v * DeliveryCannon.get_delta_v(delivery_cannon.zone, delivery_cannon.destination.zone)
    end
    if not DeliveryCannon.can_fire(delivery_cannon) then return end
  end

  -- only fire cannons with a valid payload ready
  if not (delivery_cannon.payload_count > 0) then return end

  -- artillery mode cannons must be able to be assigned something from their force's queues
  local flare = nil
  if delivery_cannon.mode == DeliveryCannon.mode_artillery then
    storage.delivery_cannon_queues[delivery_cannon.force_name] = storage.delivery_cannon_queues[delivery_cannon.force_name] or {}
    local ammo_type = string.sub(delivery_cannon.payload_name, DeliveryCannon.ammo_prefix_len_payload + 1)
    storage.delivery_cannon_queues[delivery_cannon.force_name][ammo_type] = storage.delivery_cannon_queues[delivery_cannon.force_name][ammo_type] or {}
    local success = false
    -- go through all zone's queues in an arbitrary order - this means that the weapon delivery cannons
    -- don't guarantee that *all* targets are fired upon in chronological order - just that *all* targets
    -- in the same zone are fired upon in chronological order
    local queues_by_zone_index = storage.delivery_cannon_queues[delivery_cannon.force_name][ammo_type]
    for zone_index, queue in pairs(queues_by_zone_index) do
      -- only examine the head of each queue since if the first item in the queue cannot be reached by this cannon
      -- none of the items in the queue can be reached by this cannon (since whether it is reachable or not
      -- can be decideded exclusively based on the target's zone and all items in this queue are in the same zone)
      if queue and not Queue.is_empty(queue) then
        local node = Queue.head(queue)
        local target = node.value
        delivery_cannon.destination = {
          zone = target.zone,
          coordinate = target.coordinate
        }
        flare = target.flare
        delivery_cannon.required_energy = DeliveryCannon.variants[delivery_cannon.variant].energy_per_delta_v * DeliveryCannon.get_delta_v(delivery_cannon.zone, delivery_cannon.destination.zone)
        if DeliveryCannon.can_fire(delivery_cannon) then
          -- remove this element from the queue and break the loop early
          -- because we saved the destination to the delivery_cannon for the purpose of checking can_fire
          -- everything is already set for the remainder of attempt_fire
          Queue.remove(queue, node)
          success = true

          -- also clean up the queue if it is completely emptied
          if Queue.is_empty(queue) then
            Log.debug("set queue for "..zone_index.." to nil")
            queues_by_zone_index[zone_index] = nil
          end
          break
        else
          -- if a target cannot be found, clear the temporary targets set for the purpose of checking can_fire
          DeliveryCannon.clear_target(delivery_cannon)
        end
      end
    end
    -- if we could not find a target for the artillery mode cannon, then return early since we cannot fire anything
    if not success then return end
  end

  -- fire the cannon
  local target_zone = delivery_cannon.destination.zone
  local target_surface = Zone.get_surface(target_zone)
  if not target_surface then -- Surface was deleted
    delivery_cannon.mode = DeliveryCannon.mode_off
    DeliveryCannon.clear_target(delivery_cannon)
    return
  end
  local target_position = DeliveryCannon.get_coordinate(delivery_cannon)
  local stack = DeliveryCannon.get_stack(delivery_cannon)
  if not stack then return end -- abort firing
  cannon_inv[1].count = cannon_inv[1].count - 1
  if delivery_cannon.force_name then
    local force = game.forces[delivery_cannon.force_name]
    force.chart(target_surface, Util.position_to_area(target_position, 64))
    force.get_item_production_statistics(delivery_cannon.main.surface).on_flow(delivery_cannon.payload_name, -1)
  end
  delivery_cannon.energy_interface.energy = delivery_cannon.energy_interface.energy - delivery_cannon.required_energy
  delivery_cannon.main.surface.create_entity{
    name = DeliveryCannon.variants[delivery_cannon.variant].name_beam,
    position = Util.vectors_add(delivery_cannon.main.position, DeliveryCannon.variants[delivery_cannon.variant].beam_offset ),
    target = Util.vectors_add(delivery_cannon.main.position, {x = 0, y = -100})
  }
  delivery_cannon.main.create_build_effect_smoke()

  ---@type DeliveryCannonPayloadInfo
  local payload = {
    variant = delivery_cannon.variant,
    stack = stack,
    target_zone = target_zone,
    target_position = target_position,
    force_name = delivery_cannon.force_name,
    eta = game.tick + DeliveryCannon.capsule_fall_time,
    health = 1
  }

  -- transfer the artillery flare to the payload if present
  if flare then
    payload.flare = flare
  end

  -- give opposing force's meteor defence a chance to destroy the projectile
  local defence_data = Meteor.defence_vs_projectile(payload)
  if payload.health <= 0 then
    DeliveryCannon.display_destroyed_projectile_message(delivery_cannon, defence_data, target_zone)
    -- cleanup the artillery flare if the projectile is destroyed
    if payload.flare and payload.flare.valid then
      payload.flare.destroy()
    end
    return
  end

  -- the projectile went through
  DeliveryCannon.display_not_destroyed_projectile_message(delivery_cannon, defence_data, target_zone)
  table.insert(storage.delivery_cannon_payloads, payload)

  local projectile_start_position = Util.vectors_add(target_position, {x = 0, y = -DeliveryCannon.capsule_fall_altitude})
  local shadow_start_position = Util.vectors_add(target_position, {x = DeliveryCannon.capsule_fall_altitude, y = 0})
  target_surface.create_entity{
    name = DeliveryCannon.variants[delivery_cannon.variant].name_capsule_projectile,
    position = projectile_start_position,
    target = target_position,
    force = delivery_cannon.force_name,
    speed = DeliveryCannon.capsule_fall_altitude/DeliveryCannon.capsule_fall_time
  }
  target_surface.create_entity{
    name = DeliveryCannon.name_delivery_cannon_capsule_shadow,
    position = shadow_start_position,
    target = target_position,
    force = delivery_cannon.force_name,
    speed = DeliveryCannon.capsule_fall_altitude/DeliveryCannon.capsule_fall_time
  }
  target_surface.request_to_generate_chunks(projectile_start_position)
  target_surface.request_to_generate_chunks(shadow_start_position)
  target_surface.request_to_generate_chunks(target_position)

  -- select a new target if it is automatic mode
  if delivery_cannon.mode == DeliveryCannon.mode_automatic_retarget then
    DeliveryCannon.pick_new_target(delivery_cannon, target_zone, target_surface)
  end

  -- clear the target if it is artillery mode
  if delivery_cannon.mode == DeliveryCannon.mode_artillery then
    DeliveryCannon.clear_target(delivery_cannon)
  end
end

---Performs the effect of a payload landing.
---If there is a delivery chest at the landing location, try to insert the payload item,
---otherwise causes an explosion at the target and spills the items on the ground
---@param payload DeliveryCannonPayloadInfo the payload that is landing
function DeliveryCannon.do_payload_effect(payload)
  local surface = Zone.get_surface(payload.target_zone)
  if not surface then -- Surface was deleted
    return
  end
  local spill = payload.stack.count
  local chest = surface.find_entities_filtered({
    name = DeliveryCannon.name_delivery_cannon_chest,
    position = payload.target_position,
    limit = 1,
  })[1]
  if chest then
    spill = spill - chest.insert(payload.stack)
  end
  if spill > 0 then

    surface.create_entity{
      name = DeliveryCannon.name_delivery_cannon_capsule_explosion,
      position = payload.target_position,
      force = payload.force_name
    }
    if payload.stack.name == "explosives" then -- double damage
      surface.create_entity{
        name = DeliveryCannon.name_delivery_cannon_capsule_explosion,
        position = payload.target_position,
        force = payload.force_name
      }
    end
    -- cleanup the flare for this payload now that it has arrived
    if payload.flare and payload.flare.valid then
      payload.flare.destroy()
    end

    local proto = prototypes.item[payload.stack.name]
    local projectiles = {}
    local ammo_type = nil
    if proto.type == "ammo" then
      ammo_type = proto.get_ammo_type()
    elseif proto.type == "capsule" then
      ammo_type = proto.capsule_action.attack_parameters.ammo_type
    end
    if ammo_type then
      for _, action in pairs(ammo_type.action) do
        for _, action_delivery in pairs(action.action_delivery) do
          if action_delivery.type == "projectile" or action_delivery.type == "artillery" then
            projectiles[action_delivery.projectile] = (projectiles[action_delivery.projectile] or 0) + 1
          end
        end
      end
    end
    local no_items = false
    for projectile_name, projectile_count in pairs(projectiles) do
      no_items = true
      surface.create_entity{
        name = projectile_name,
        position = payload.target_position,
        target = payload.target_position,
        speed = 0.1,
        force = payload.force_name
      }
    end
    if not no_items then
      local spill_stack = table.deepcopy(payload.stack)
      spill_stack.count = math.ceil(spill/4)
      surface.spill_item_stack{position = payload.target_position, stack = spill_stack, enable_looted = true, force = payload.force_name, allow_belts = true, max_radius = 20}
    end
  end
end

---Updates all delivery cannons, potentially firing them or updating their guis. Checks are done
---infrequently, but still frequently enough that the cannon will never get backed up while
---assembling at full speed. Updates all cannon payloads, causing their effect when they hit.
---@param event EventData.on_tick Event data
function DeliveryCannon.on_tick(event)
  -- fire cannons
  for _, delivery_cannon in pairs(storage.delivery_cannons) do
    if (event.tick + delivery_cannon.unit_number) % 60 == 0 then
      DeliveryCannon.attempt_fire(delivery_cannon)
    end
  end

  -- update guis
  if event.tick % 60 == 0 then
    for _, player in pairs(game.connected_players) do
      DeliveryCannonGUI.gui_update(player)
    end
  end

  -- process payloads
  for i = #storage.delivery_cannon_payloads, 1, -1 do
    local payload = storage.delivery_cannon_payloads[i]
    if payload then
      if event.tick >= payload.eta then
        DeliveryCannon.do_payload_effect(payload)
        table.remove(storage.delivery_cannon_payloads, i)
      end
    end
  end

  -- remove timed out artillery requests
  if event.tick % DeliveryCannon.tick_interval_remove_delayed_artillery_requests == 0 then
    DeliveryCannon.remove_stale_artillery_targets(event)
  end
end
Event.addListener(defines.events.on_tick, DeliveryCannon.on_tick)

---Handles the player picking a delivery cannon target using the delivery cannon targeter.
---@param event EventData.CustomInputEvent Event data
function DeliveryCannon.on_targeter(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if not player then return end
  local cursor_item = player.cursor_stack
  if not (cursor_item and cursor_item.valid_for_read) then cursor_item = player.cursor_ghost and player.cursor_ghost.name end
  if not (cursor_item and cursor_item.valid) then return end
  if (cursor_item.name == DeliveryCannon.name_delivery_cannon_targeter) then
    local remote_view_activity = RemoteView.get_activity(player, "delivery-cannon")
    if not remote_view_activity then return end
    local delivery_cannon = remote_view_activity.delivery_cannon
    local destination_zone = Zone.from_surface(player.surface)
    if not (delivery_cannon and delivery_cannon.main and delivery_cannon.main.valid and destination_zone) then return end
    local coordinates = event.cursor_position
    local is_successful = DeliveryCannon.set_target(delivery_cannon, player, destination_zone, coordinates)
    if is_successful then
      local coordinates_label
      if delivery_cannon.variant == "logistic" then
        coordinates_label = "delivery-cannon"
      else
        coordinates_label = "delivery-cannon-weapon"
      end
      player.print({"space-exploration.target-set",
        "item/" .. DeliveryCannon.variants[delivery_cannon.variant].name,
        {"space-exploration.target-label-" .. coordinates_label},
        Zone.get_print_name(destination_zone),
        math.floor(delivery_cannon.destination.coordinate.x),
        math.floor(delivery_cannon.destination.coordinate.y)})
    end
  elseif (string.starts(cursor_item.name, DeliveryCannon.ammo_prefix_targeter)) then
    local destination_zone = Zone.from_surface(player.surface) -- CustomInputEvent does not have a surface so grab it from the player
    if not destination_zone then return end
    local coordinates = event.cursor_position
    local ammo_type = string.sub(cursor_item.name, DeliveryCannon.ammo_prefix_len_targeter + 1)
    if DeliveryCannon.none_in_range_of_target(destination_zone, player.force.name, ammo_type) then
      player.play_sound{ path = "utility/cannot_build" }
      return player.create_local_flying_text{create_at_cursor = true,
        text = {"space-exploration.delivery-cannon-artillery-none-in-range", {"", "[color=cyan]", {"item-name."..ammo_type}, "[/color]"}},
      }
    end
    local is_successful = DeliveryCannon.enqueue_target(destination_zone, coordinates, player.force.name, ammo_type)
    if not is_successful then
      player.print({"space-exploration.delivery-cannon-artillery-target-not-set",
        "item/" .. DeliveryCannon.variants["weapon"].name,
        Zone.get_print_name(destination_zone),
        math.floor(coordinates.x),
        math.floor(coordinates.y)})
    end
  end
end
Event.addListener(mod_prefix .. "-targeter", DeliveryCannon.on_targeter)

---@param name string item name
---@return boolean
function DeliveryCannon.is_targeter(name)
  return name == DeliveryCannon.name_delivery_cannon_targeter or string.starts(name, DeliveryCannon.ammo_prefix_targeter)
end

---@param event EntityCreationEvent|EventData.on_entity_cloned|{entity:LuaEntity} Event data
function DeliveryCannon.on_entity_created(event)
  local entity = util.get_entity_from_event(event)

  if not entity then return end
  if entity.name == DeliveryCannon.variants["logistic"].name or entity.name == DeliveryCannon.variants["weapon"].name then
    local zone = Zone.from_surface(entity.surface)
    if cancel_creation_when_invalid(zone, entity, event) then return end
    ---@cast zone -?

    if not RemoteView.is_unlocked_force(entity.force.name) then
      cancel_entity_creation(entity, event.player_index, {"space-exploration.generic-requires-satellite"}, event)
      return
    end
    local force_name = entity.force.name

    ---@type DeliveryCannonInfo
    local delivery_cannon = {
      type = entity.name,
      variant = entity.name == DeliveryCannon.variants["logistic"].name and "logistic" or "weapon",
      valid = true,
      force_name = force_name,
      unit_number = entity.unit_number,
      main = entity,
      zone = zone,
      position = entity.position,
      mode = DeliveryCannon.mode_off,
      destination = {
        zone = nil
      },
      launch_status = -1
    }

    storage.delivery_cannons[entity.unit_number] = delivery_cannon
    Log.debug("DeliveryCannon: delivery_cannon added")

    DeliveryCannon.add_delivery_cannon_to_table(delivery_cannon) -- assigns to zone_assets

    -- spawn energy interface
    delivery_cannon.energy_interface = util.find_entity_or_revive_ghost(entity.surface, DeliveryCannon.variants[delivery_cannon.variant].name_energy_interface, entity.position)
    if not delivery_cannon.energy_interface then
      delivery_cannon.energy_interface = entity.surface.create_entity{
        name = DeliveryCannon.variants[delivery_cannon.variant].name_energy_interface,
        force = entity.force,
        position = {entity.position.x, entity.position.y}
      }
    end
    delivery_cannon.energy_interface.destructible = false

    -- set settings
    local tags = util.get_tags_from_event(event, DeliveryCannon.serialize)
    if tags then
      DeliveryCannon.deserialize(entity, tags)
    end
  end
end
Event.addListener(defines.events.on_entity_cloned, DeliveryCannon.on_entity_created)
Event.addOnEntityCreatedListeners(DeliveryCannon.on_entity_created)

---@param delivery_cannon DeliveryCannonInfo
---@param key string
function DeliveryCannon.destroy_sub(delivery_cannon, key)
  if delivery_cannon[key] and delivery_cannon[key].valid then
    delivery_cannon[key].destroy()
    delivery_cannon[key] = nil
  end
end

---@param delivery_cannon DeliveryCannonInfo
---@param event? EntityRemovalEvent the event that triggered the destruction if it was caused by an event
function DeliveryCannon.destroy(delivery_cannon, event)
  if not delivery_cannon then
    Log.debug("delivery_cannon_destroy: no delivery_cannon")
    return
  end

  delivery_cannon.valid = false

  DeliveryCannon.destroy_sub(delivery_cannon, 'energy_interface')

  DeliveryCannon.remove_delivery_cannon_from_table(delivery_cannon)

  if not event then -- If event is supplied then it will already be destroyed
    DeliveryCannon.destroy_sub(delivery_cannon, 'main')
  end

  if not event or event.name ~= defines.events.on_entity_died then
    -- For died it will be cleaned in post_died event
    storage.delivery_cannons[delivery_cannon.unit_number] = nil
  end

  -- if a player has this gui open then close it
  local gui_name = DeliveryCannonGUI.name_delivery_cannon_gui_root
  for _, player in pairs(game.connected_players) do
    local root = player.gui.relative[gui_name]
    if root and root.tags and root.tags.unit_number == delivery_cannon.unit_number then
      root.destroy()
    end
  end
end

---@param event EntityRemovalEvent Event data
function DeliveryCannon.on_entity_removed(event)
  local entity = event.entity
  if entity and entity.valid and
    (entity.name == DeliveryCannon.variants["logistic"].name or entity.name == DeliveryCannon.variants["weapon"].name) then
      DeliveryCannon.destroy(DeliveryCannon.from_entity(entity), event )
  end
end
Event.addOnEntityRemovedListeners(DeliveryCannon.on_entity_removed)

---@param event EventData.on_post_entity_died
local function on_post_entity_died(event)
  local ghost = event.ghost
  local unit_number = event.unit_number
  if not (ghost and unit_number) then return end
  local prototype_name = event.prototype.name
  if prototype_name ~= DeliveryCannon.variants["logistic"].name and prototype_name ~= DeliveryCannon.variants["weapon"].name then return end
  ghost.tags = DeliveryCannon.serialize_from_struct(storage.delivery_cannons[unit_number])
  storage.delivery_cannons[unit_number] = nil
end
Event.addListener(defines.events.on_post_entity_died, on_post_entity_died)

---@param delivery_cannon DeliveryCannonInfo?
---@return Tags?
function DeliveryCannon.serialize_from_struct(delivery_cannon)
  if delivery_cannon then
    local tags = {}
    if delivery_cannon.destination then
      tags.destination = {
        coordinate = delivery_cannon.destination.coordinate,
        zone_name = delivery_cannon.destination.zone and delivery_cannon.destination.zone.name
      }
    end
    tags.mode = delivery_cannon.mode
    return tags
  end
end

---@param entity LuaEntity
---@return Tags?
function DeliveryCannon.serialize(entity)
  return DeliveryCannon.serialize_from_struct(DeliveryCannon.from_entity(entity))
end

--- Converts the individual delivery cannon mode settings into a single mode enum
---@param is_off boolean Is cannon turned on - deprecated - replaced by mode
---@param auto_select_targets boolean Is cannon set to auto-select targets - deprecated - replaced by mode
---@return string mode
function DeliveryCannon.mode_for_individual_settings(is_off, auto_select_targets)
  -- Cannons that are off get the off mode regardless of auto_select_targets
  if is_off then
    return DeliveryCannon.mode_off
  -- Otherwise either automatic retarget or single target based off of auto_select_targets value
  elseif auto_select_targets then
    return DeliveryCannon.mode_automatic_retarget
  else
    return DeliveryCannon.mode_single_target
  end
end

---@param entity LuaEntity
---@param tags Tags
function DeliveryCannon.deserialize(entity, tags)
  local delivery_cannon = DeliveryCannon.from_entity(entity)

  if delivery_cannon then
    if tags.destination then
      local destination_zone = Zone.from_name(tags.destination.zone_name)
      local coordinates = table.deepcopy(tags.destination.coordinate)

      DeliveryCannon.set_target(delivery_cannon, entity.last_user, destination_zone, coordinates)
    end

    -- if the blueprint is from an older version it might have is_off or auto_select_targets instead of mode
    -- since the blueprint entity tags weren't migrated
    if tags.is_off or tags.auto_select_targets then
      delivery_cannon.mode = DeliveryCannon.mode_for_individual_settings(tags.is_off, tags.auto_select_targets)
    else
      delivery_cannon.mode = tags.mode
    end
  end
end

--- Handles the player creating a blueprint by setting tags to store the state of delivery cannons
---@param event EventData.on_player_setup_blueprint Event data
function DeliveryCannon.on_player_setup_blueprint(event)
  util.setup_blueprint(event, {DeliveryCannon.variants["logistic"].name, DeliveryCannon.variants["weapon"].name}, DeliveryCannon.serialize)
end
Event.addListener(defines.events.on_player_setup_blueprint, DeliveryCannon.on_player_setup_blueprint)

--- Handles the player copy/pasting settings between delivery cannons
---@param event EventData.on_entity_settings_pasted Event data
function DeliveryCannon.on_entity_settings_pasted(event)
  util.settings_pasted(event, {DeliveryCannon.variants["logistic"].name, DeliveryCannon.variants["weapon"].name}, DeliveryCannon.serialize, DeliveryCannon.deserialize,
    function(entity, player_index)
      local delivery_cannon = DeliveryCannon.from_entity(entity)
      local player = game.get_player(player_index)
      if delivery_cannon and delivery_cannon.destination and delivery_cannon.destination.coordinate then
        local coordinates_label
        if delivery_cannon.variant == "logistic" then
          coordinates_label = "delivery-cannon"
        else
          coordinates_label = "delivery-cannon-weapon"
        end
        -- when copying from weapon to logistic, any mode other than off/single target should be converted back to single target
        if delivery_cannon.variant == "logistic" and (delivery_cannon.mode == DeliveryCannon.mode_automatic_retarget or delivery_cannon.mode == DeliveryCannon.mode_artillery) then
          delivery_cannon.mode = DeliveryCannon.mode_single_target
        end
        player.print({"space-exploration.target-pasted",
          "item/" .. DeliveryCannon.variants[delivery_cannon.variant].name,
          {"space-exploration.target-label-" .. coordinates_label},
          Zone.get_print_name(delivery_cannon.destination.zone),
          math.floor(delivery_cannon.destination.coordinate.x),
          math.floor(delivery_cannon.destination.coordinate.y)})
      end
    end)
end
Event.addListener(defines.events.on_entity_settings_pasted, DeliveryCannon.on_entity_settings_pasted)

function DeliveryCannon.on_init()
  storage.delivery_cannons = {}
  storage.delivery_cannon_queues = {}
  storage.delivery_cannon_payloads = {}
end
Event.addListener("on_init", DeliveryCannon.on_init, true)

---@param event ConfigurationChangedData
function DeliveryCannon.on_configuration_changed(event)
  if not event.migrations.item then return end

  --migrate any migrated items within the payload struct
  if storage.delivery_cannon_payloads then
    for i = #storage.delivery_cannon_payloads, 1, -1 do
      local payload = storage.delivery_cannon_payloads[i]
      local new_name = event.migrations.item[payload.stack.name]
      if new_name then
        if new_name == "" then
          log("Removed delivery cannon payload for non-existant item: "..payload.stack.name)
          table.remove(storage.delivery_cannon_payloads, i)
        else
          log("Delivery cannon payload item renamed from "..payload.stack.name.." to "..new_name)
          payload.stack.name = new_name
        end
      end
    end
  end

  if storage.delivery_cannons then
    for unit_number, delivery_cannon in pairs(storage.delivery_cannons) do
      local new_name = event.migrations.item[delivery_cannon.payload_name]
      if new_name then
        if new_name == "" then
          log("Removed delivery cannon payload for non-existant item: "..delivery_cannon.payload_name)
          storage.delivery_cannons[unit_number] = nil
        else
          log("Delivery cannon payload item renamed from "..delivery_cannon.payload_name.." to "..new_name)
          delivery_cannon.payload_name = new_name
        end
      end
    end
  end
end
Event.addListener("on_configuration_changed", DeliveryCannon.on_configuration_changed, true)


return DeliveryCannon
