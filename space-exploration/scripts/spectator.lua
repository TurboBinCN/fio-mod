local Spectator = {}
-- Player and character helpers
-- TODO:
--  Make sure that a reconnecting player is not treated as dead if detatched due to spectating an event when disconnecting.
--  If a player's character was in a capsule and the capsule is launching while they reconnect, make sure they go into spectator mode.
--  Move player and character stuff from control.lua here

Spectator.name_seat = mod_prefix .. "character-_-seat"

---Cancels any crafting in progress by a given character.
---@param character LuaEntity Character entity
function Spectator.cancel_crafting(character)
  if character.crafting_queue_size == 0 then return end
  for _, queue_item in pairs(character.crafting_queue) do
    character.cancel_crafting{index=queue_item.index, count=queue_item.count}
  end
end

---Creates an invisible seat vehicle entity and sets the given character as the driver.
---@param character LuaEntity Character entity
---@return LuaEntity seat Vehicle entity
function Spectator.make_spectator_seat(character)
  local seat = character.surface.create_entity{
    name=Spectator.name_seat,
    position=character.position,
    force=character.force
  }
  ---@cast seat -?
  seat.destructible = false
  seat.operable = false
  seat.minable = false
  seat.rotatable = false
  seat.active = false
  seat.set_driver(character)

  -- If the character was in a different vehicle without enough space to dismount, the previous
  -- `set_driver` call will silently fail. They need to be forced out of the vehicle they were in
  -- before being set as the driver of the spectator vehicle.
  if seat.get_driver() ~= character and character.vehicle then
    if character.vehicle.get_driver() == character then
      character.vehicle.set_driver(nil)
    elseif character.vehicle.get_passenger() == character then
      character.vehicle.set_passenger(nil)
    end

    seat.set_driver(character)
  end

  return seat
end

---Creates and returns a spectator seat (vehicle) occupied by the given character.
---@param player LuaPlayer Player
---@param character LuaEntity Character entity
---@param force_spectate? boolean Whether tracking should ignore remote view status
---@return SpectatorInfo seat_data Spectator seat data
function Spectator.make_spectator(player, character, force_spectate)
    return {
      player=player,
      character=character,
      seat=Spectator.make_spectator_seat(character),
      force_spectate=force_spectate,
      valid=true
    }
end

---Makes the given `character` and optionally an attached player start spectating a given `spectator_controller`.
---Returns a `SpectatorInfo` object, which is also saved to the playerdata table.
---@param character LuaEntity Player
---@param spectator_controller CargoRocketTickTask|CapsuleTickTask Tick task being spectated
---@param force_spectate? boolean Whether this should close remote view if it's open
---@return SpectatorInfo
function Spectator.start(character, spectator_controller, force_spectate)
  local player = character.player
  if not player then
    for index, playerdata in pairs(storage.playerdata) do
      if playerdata.character == character then
        player = game.get_player(index)
      end
    end
  end

  local spectator = Spectator.make_spectator(player, character, force_spectate)

  if character then
    -- Stop the character from continuing any input action (running to doom)
    character.walking_state = {walking=false, direction = defines.direction.south}
    character.riding_state = {acceleration=defines.riding.acceleration.braking, direction = defines.riding.direction.straight}
    character.shooting_state = {state = defines.shooting.not_shooting, position = character.position}
    character.mining_state = {mining = false}
    character.picking_state = false
    character.repair_state = {repairing = false, position = character.position}

    -- Block jetpack
    remote.call("jetpack", "block_jetpack", {character=character})
  end

  if player then
    local playerdata = get_make_playerdata(player)
    character = character or player_get_character(player)
    playerdata.character = character

    CapsuleGUI.gui_close(player)
    if player.opened_gui_type == defines.gui_type.entity and player.opened.name == Capsule.name_space_capsule_container then
      player.opened = nil
    end

    -- Abort if player is spectating something else already
    if playerdata.spectator_of or playerdata.spectator then return spectator end

    playerdata.spectator = spectator
    playerdata.spectator_of = spectator_controller

    if force_spectate then
      RemoteView.stop(player)
    end

    -- Change player controller if they're not already in remote view
    if (not RemoteView.is_active(player)) then
      player.set_controller{type=defines.controllers.ghost}
    end
  end

  return spectator
end

---Stops spectator mode for a given player.
---@param spectator SpectatorInfo Spectator data
function Spectator.stop(spectator)
  local player = spectator.player

  -- Destroy spectator vehicle
  if spectator.seat.valid then
    spectator.seat.set_driver(nil)
    spectator.seat.destroy()
  end

  if player and player.valid then

    local playerdata = get_make_playerdata(player)
    if spectator.character and spectator.character.valid then
      -- Unblock jetpack
      remote.call("jetpack", "unblock_jetpack", {character=spectator.character})

      -- Restore character controller if appropriate
      if not RemoteView.is_active(player) then
        RemoteView.stop(player)

        -- Teleport the player to character's position first since they must be on the same surface
        player.teleport(spectator.character.position, spectator.character.surface)
        player.set_controller{type=defines.controllers.character, character=spectator.character}
      end
    else
      Respawn.die(player)
    end

    if playerdata then
      playerdata.spectator_of = nil
      playerdata.spectator = nil
    end

  end

end

---Moves the seat and character inside a `SpectatorInfo` to a given surface and position.
---@param spectator SpectatorInfo Spectator data
---@param target_surface LuaSurface Target surface
---@param target_position MapPosition Target coordinates
function Spectator.track_seat(spectator, target_surface, target_position)
  if not spectator.valid then return end

  -- If the character became invalid, mark this entire spectator table as invalid, ultimately
  -- trigger player respawn
  if not spectator.character.valid then
    spectator.valid = false
    Spectator.stop(spectator)
    return
  end

  -- If the seat became invalid, just recreate it
  if not spectator.seat.valid then
    spectator.seat = Spectator.make_spectator_seat(spectator.character)
  end

  -- Ensure that the driver of the seat vehicle is the intended character
  if spectator.seat.get_driver() ~= spectator.character then
    spectator.seat.set_driver(nil)
    spectator.seat.set_driver(spectator.character)
  end

  -- Kick out any passenger that might have snuck in
  if spectator.seat.get_passenger() then spectator.seat.set_passenger(nil) end

  -- Determine whether this is a cross-surface teleport _before_ moving the vehicle
  local is_different_surface = spectator.seat.surface ~= target_surface

  -- Update character references in spectator and playerdata if a cross-surface teleport was done
  if not is_different_surface then
    -- Move the spectator vehicle
    spectator.seat.teleport(target_position)
  else

    if spectator.character.player and spectator.character.player.controller_type == defines.controllers.remote then
      -- There's a bug where if you're in remote view while you'r character's vechile changes surface then the player view changes too
      spectator.seat.set_driver(nil)
      spectator.seat.teleport(target_position, target_surface)
      spectator.character.teleport(target_position, target_surface)
      spectator.seat.set_driver(spectator.character)
    else
      spectator.seat.teleport(target_position, target_surface)
    end
    spectator.character = spectator.seat.get_driver() -- needs new reference after cross-surface teleport

    local cursor_stack = spectator.character.cursor_stack
    --put away any held item. Prevents cross surface linking of wires.
    if cursor_stack and cursor_stack.valid_for_read then
      for i = 1, spectator.character.get_max_inventory_index() do
        local inventory = spectator.character.get_inventory(i)
        if inventory and inventory.can_insert(cursor_stack) then
          inventory.insert(cursor_stack)
          cursor_stack.clear()
          break
        end
      end
    end

    if spectator.player and spectator.player.valid then
      local playerdata = get_make_playerdata(spectator.player)
      playerdata.character = spectator.character
    end
  end
end

---Moves the player inside a `SpectatorInfo` object to a given surface and position.
---@param spectator SpectatorInfo Spectator data
---@param target_surface LuaSurface Target surface
---@param target_position MapPosition Target coordinates
function Spectator.track_player(spectator, target_surface, target_position)
  if not spectator.valid then return end
  if not spectator.player or not spectator.player.valid then return end

  -- Adjust target_position to allow smooth movement from current player position
  local adjusted_position = spectator.player.surface ~= target_surface and target_position
    or util.lerp_vectors(spectator.player.position, target_position, 0.1)

  -- Move player to adjusted position, if appropriate
  local is_remote_view_active = RemoteView.is_active(spectator.player)
  if not is_remote_view_active then
    if spectator.player.controller_type ~= defines.controllers.ghost then
      spectator.player.set_controller{type = defines.controllers.ghost}
    end
    spectator.player.teleport(adjusted_position, target_surface)
  end
end

---Moves the player and character inside a `SpectatorInfo` object to a given surface and position.
---For more fine-grained control, you can call `track_seat` and `track_player` separately with
---different arguments.
---@param spectator SpectatorInfo Spectator data
---@param target_surface LuaSurface Target surface
---@param target_position MapPosition Target coordinates
function Spectator.track(spectator, target_surface, target_position)
  Spectator.track_seat(spectator, target_surface, target_position)
  Spectator.track_player(spectator, target_surface, target_position)
end

return Spectator
