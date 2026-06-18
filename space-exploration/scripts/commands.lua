local Command = {}

---Checks if a given player is allowed to use commands. Prints a message to the player if they were
---not allowed.
---@param player LuaPlayer Player who input the command
---@param check_cheat_mode boolean Whether or not to cheack if cheat mode is enabled
---@return boolean is_allowed
function Command.is_allowed(player, check_cheat_mode)
  -- Check if player is an admin
  if not player.admin then
    player.print({"space-exploration.command-admin-required"})
    return false
  end

  -- Optional cheat-mode check
  if not check_cheat_mode or player.cheat_mode then
    return true
  else
    player.print({"space-exploration.command-not-permitted"})
    return false
  end
end

---Launches a navigation satellite for the player's force from the surface they're currently on.
---@param command CustomCommandData Command data
function Command.launch_satellite(command)
  if not command.player_index then
    game.print({"space-exploration.command-must-be-entered-by-player"})
    return
  end

  local player = game.get_player(command.player_index)
  ---@cast player -?
  if not Command.is_allowed(player, true) then return end

  for _ = 1, command.parameter and math.min(tonumber(command.parameter) or 1, 100) or 1 do
    on_satellite_launched(player.force.name, player.surface)
  end
end
commands.add_command("se-launch-satellite", {"space-exploration.command-help-launch-satellite"}, Command.launch_satellite)

---Toggles debug mode on or off.
---@param command CustomCommandData Command data
function Command.toggle_debug_mode(command)
  if not command.player_index then
    game.print({"space-exploration.command-must-be-entered-by-player"})
    return
  end

  local player = game.get_player(command.player_index)
  ---@cast player -?
  if not Command.is_allowed(player, true) then return end

  if command.parameter == "on" then
    storage.debug_view_all_zones = true
    player.print({"space-exploration.command-debug-mode-enabled"})
  elseif command.parameter == "off" then
    storage.debug_view_all_zones = false
    player.print({"space-exploration.command-debug-mode-disabled"})
  elseif not command.parameter then
    storage.debug_view_all_zones = not storage.debug_view_all_zones
    if storage.debug_view_all_zones then
      player.print({"space-exploration.command-debug-mode-enabled"})
    else
      player.print({"space-exploration.command-debug-mode-disabled"})
    end
  else
    player.print({"space-exploration.command-invalid-argument"})
  end
end
commands.add_command("se-debug", {"space-exploration.command-help-toggle-debug-mode"}, Command.toggle_debug_mode)

---Teleports the player to a specified zone.
---@param command CustomCommandData Command data
function Command.teleport_to_zone(command)
  if not command.player_index then
    game.print({"space-exploration.command-must-be-entered-by-player"})
    return
  end

  local player = game.get_player(command.player_index)
  ---@cast player -?
  if not Command.is_allowed(player, true) then return end

  local zone = Zone.from_name(command.parameter)
  if not zone then
    player.print({"space-exploration.command-invalid-zone-name"})
    return
  end

  Zone.discover(player.force.name, zone)
  player.teleport({0, 0}, Zone.get_make_surface(zone))
  player.print({"space-exploration.command-teleport-to-zone-success", Zone.get_print_name(zone)})
end
commands.add_command("se-teleport-to-zone", {"space-exploration.command-help-teleport-to-zone"}, Command.teleport_to_zone)

---Equips the player with the highest tier space suit and other essentials.
---@param command CustomCommandData Command data
function Command.suit_up(command)
  if not command.player_index then
    game.print({"space-exploration.command-must-be-entered-by-player"})
    return
  end

  local player = game.get_player(command.player_index)
  ---@cast player -?
  if not Command.is_allowed(player, true) then return end

  local character = player.character
  if not character then return end

  -- Insert armor if armor slot is empty
  local armor_inventory = character.get_inventory(defines.inventory.character_armor)
  ---@cast armor_inventory -?
  if command.parameter == "force" then armor_inventory.clear() end
  if armor_inventory.is_empty() then
    local inserted = armor_inventory.insert({name=mod_prefix .. "thruster-suit-4"})

    -- Insertion could fail if slot was reserved for player's cursor stack
    if inserted < 1 then return end

    local grid = armor_inventory[1].grid
    local equipment = {
      ["personal-roboport-mk2-equipment"] = 4,
      ["jetpack-4"] = 4,
      ["se-lifesupport-equipment-4"] = 2,
      ["battery-mk2-equipment"] = 8,
      ["energy-shield-mk6-equipment"] = 2,
      ["personal-laser-defense-equipment"] = 8,
      ["se-antimatter-reactor-equipment"] = 8,
    }

    for name, count in pairs(equipment) do
      if prototypes.equipment[name] then
        for _ = 1, count do grid.put{name=name} end
      end
    end
    for _, grid_equipment in pairs(grid.equipment) do
      grid_equipment.energy = grid_equipment.max_energy
      if grid_equipment.max_shield > 0 then
        grid_equipment.shield = grid_equipment.max_shield
      end
    end
  end

  -- Insert construction bots, rocket fuel, and lifesupport canisters
  local character_inventory = character.get_main_inventory()
  ---@cast character_inventory -?
  local items = {
    ["construction-robot"] = 100,
    ["rocket-fuel"] = 10,
    ["se-lifesupport-canister"] = 100
  }

  for name, count in pairs(items) do
    if prototypes.item[name] then
      character_inventory.insert({name=name, count=count})
    end
  end
end
commands.add_command("se-suit-up", {"space-exploration.command-help-suit-up"}, Command.suit_up)

---Removes the seam selected by the player.
---@param command CustomCommandData Command data
function Command.remove_seam(command)
  if not command.player_index then
    game.print({"space-exploration.command-must-be-entered-by-player"})
    return
  end

  local player = game.get_player(command.player_index)
  ---@cast player -?
  if not Command.is_allowed(player, false) then return end

  local zone = Zone.from_surface(player.surface)

  -- Exit if player is located on a non-SE zone surface
  if not zone then
    player.print({"space-exploration.command-invalid-zone-name"})
    return
  end

  -- Exit if not planet or moon
  if zone.type ~= "planet" and zone.type ~= "moon" then
    ---@cast zone -PlanetType, -MoonType
    player.print({"space-exploration.command-remove-seam-wrong-zone-type",
        Zone.get_print_name(zone)})
    return
  end

  ---@cast zone PlanetType|MoonType
  CoreMiner.default_fragment_name(zone)

  -- Exit if player has not selected any entity
  local selected_name = player.selected and player.selected.name or nil
  local fragment_name = zone.fragment_name
  if not selected_name then
    player.print({"space-exploration.command-remove-seam-no-entity-selected"})
    return
  end

  -- Selected entity is not the correct resource (sealed or not) for this zone
  if selected_name ~= fragment_name and
      selected_name ~= fragment_name .. CoreMiner.name_core_seam_sealed_suffix then
    player.print({"space-exploration.command-remove-seam-wrong-entity-selected"})
    return
  end

  -- Actually try to remove the resource
  local resource_index = CoreMiner.get_resource_index(zone, player.selected.position)
  if resource_index then
    local resource_set = zone.core_seam_resources[resource_index]
    CoreMiner.remove_seam(resource_set)
    player.print({"space-exploration.command-remove-seam-success"})
  else
    player.print({"space-exploration.command-remove-seam-resource-not-found"})
    return
  end
end
commands.add_command("se-remove-seam", {"space-exploration.command-help-remove-seam"},
    Command.remove_seam)

---Removes all core seams of a given zone.
---@param command CustomCommandData Command data
function Command.remove_all_seams(command)
  if not command.player_index then
    game.print({"space-exploration.command-must-be-entered-by-player"})
    return
  end

  local player = game.players[command.player_index]
  if not Command.is_allowed(player, false) then return end

  local zone

  if command.parameter then
    zone = Zone.from_name(command.parameter)
  else
    zone = Zone.from_surface(player.surface)
  end

  -- Exit if zone name is invalid or player is located on a non-SE zone surface
  if not zone then
    player.print({"space-exploration.command-invalid-zone-name"})
    return
  end

  if zone.type == "planet" or zone.type == "moon" then
    ---@cast zone PlanetType|MoonType
    CoreMiner.remove_seams(zone)
    player.print({"space-exploration.command-remove-all-seams-success", Zone.get_print_name(zone)})
  else
    player.print({"space-exploration.command-remove-all-seams-failed", Zone.get_print_name(zone)})
  end
end
commands.add_command("se-remove-all-seams", {"space-exploration.command-help-remove-all-seams"},
    Command.remove_all_seams)

---Resets the core seams of a given zone.
---@param command CustomCommandData Command data
function Command.reset_seams(command)
  if not command.player_index then
    game.print({"space-exploration.command-must-be-entered-by-player"})
    return
  end

  local player = game.get_player(command.player_index)
  ---@cast player -?
  if not Command.is_allowed(player, false) then return end

  local zone

  if command.parameter then
    zone = Zone.from_name(command.parameter)
  else
    zone = Zone.from_surface(player.surface)
  end

  -- Exit if zone name is invalid or player is located on a non-SE zone surface
  if not zone then
    player.print({"space-exploration.command-invalid-zone-name"})
    return
  end

  if zone.type == "planet" or zone.type == "moon" then
    ---@cast zone PlanetType|MoonType
    CoreMiner.reset_seams(zone)
    player.print({"space-exploration.command-reset-seams-success", Zone.get_print_name(zone)})
  else
    player.print({"space-exploration.command-reset-seams-failed", Zone.get_print_name(zone)})
  end
end
commands.add_command("se-reset-seams", {"space-exploration.command-help-reset-seams"}, Command.reset_seams)


-- Re-tag all core seams
--/c remote.call("space-exploration", "reset_seam_tags")
---@param command CustomCommandData Command data
function Command.reset_seam_tags(command)
  if not command.player_index then
    game.print({"space-exploration.command-must-be-entered-by-player"})
    return
  end

  local player = game.get_player(command.player_index)
  ---@cast player -?
  if not Command.is_allowed(player, false) then return end

  for _,surface in pairs(game.surfaces) do
    local zone = Zone.from_surface(surface)
    if zone and zone.core_seam_positions then
      for resource_index,_ in pairs(zone.core_seam_positions) do
        for _, force in pairs(game.forces) do
          CoreMiner.create_tag(zone, force, resource_index)
        end
      end
    end
  end
end
commands.add_command("se-reset-seam-tags", {"space-exploration.command-help-reset-seam-tags"}, Command.reset_seam_tags)

---Force adds a planet or moon of a given name. Name must be a valid but unassigned SE planet/moon
---name.
---@param command CustomCommandData Command data
function Command.add_planet_or_moon(command)
  if not command.player_index then
    game.print({"space-exploration.command-must-be-entered-by-player"})
    return
  end

  local player = game.get_player(command.player_index)
  ---@cast player -?
  if not Command.is_allowed(player, false) then return end

  local result =
    remote.call("space-exploration", "force_add_planet_or_moon",
        {zone_name=command.parameter}) --[[@as table]]

  if result.failed then
    if result.message == "zone-exists" then
      player.print({"space-exploration.command-add-planet-or-moon-zone-exists",
        Zone.get_print_name(Zone.from_name(command.parameter) --[[@as AnyZoneType]])})
    elseif result.message == "invalid-planet-or-moon-name" then
      player.print({"space-exploration.command-add-planet-or-moon-invalid-name",
          command.parameter or "\"\""})
    end
  else
    if result.type == "planet" then
      player.print({"space-exploration.command-add-planet-or-moon-success-planet",
        Zone.get_print_name(Zone.from_name(command.parameter) --[[@as PlanetType]]),
        Zone.get_print_name(Zone.from_name(result.star) --[[@as StarType]])
      })
    elseif result.type == "moon" then
      player.print({"space-exploration.command-add-planet-or-moon-success-moon",
        Zone.get_print_name(Zone.from_name(command.parameter) --[[@as MoonType]]),
        Zone.get_print_name(Zone.from_name(result.planet)  --[[@as PlanetType]]),
        Zone.get_print_name(Zone.from_name(result.star) --[[@as StarType]])
      })
    end
  end
end
commands.add_command("se-add-planet-or-moon", {"space-exploration.command-help-add-planet-or-moon"},
  Command.add_planet_or_moon)

--- Prints checksum for universe distribution
--- This command will return the same value when using the same map settings and map seed
--- Use it to see if your changes have affected universe generation
--- NOTE: WILL CHANGE WHEN A SURFACE IS CREATED
function Command.print_universe_checksum()
  -- Make a shallow version of storage.zones_by_name
  local shallow_zones_by_name = {}
  for zone_name, zone in pairs(storage.zones_by_name) do
    local shallow_zone = Zone.shallow_table(zone)
    -- Remove all fields that can change unpredictably after universe creation
    shallow_zone.core_mining = nil
    shallow_zone.core_seam_chunks = nil
    shallow_zone.core_seam_resources = nil
    shallow_zone.core_seam_positions = nil
    shallow_zone.inflated = nil
    shallow_zone.deleted_surface = nil
    shallow_zone.inhabited_chunks = nil
    shallow_zone.meteor_defences = nil
    shallow_zone.meteor_point_defences = nil
    shallow_zone.next_meteor_shower = nil
    shallow_zone.plague_used = nil
    shallow_zone.hostiles_extinct = nil
    shallow_zone.surface_index = nil
    shallow_zone.looted_items = nil
    shallow_zone.plague_tick_task = nil
    shallow_zone.energy_transmitters = nil
    shallow_zone.energy_beam_pressures = nil
    shallow_zone.resources = nil
    -- Set, or changed, when zone is discovered
    shallow_zone.biome_replacements = nil
    shallow_zone.tile_replacements = nil
    shallow_zone.glyph = nil
    shallow_zone.fragment_name = nil

    -- Seed is set as part of homesystem generation, and relies on storage.universe_rng
    -- Keeping it as part of the checksum allows us to know when we have changed the number/placement of calls to storage.universe_rng
    -- which is relevant as this has knock on effects to the rest of universe generation.
    --shallow_zone.seed = nil

    -- Ideally tags and controls would be set during universe creation...
    -- But they get changed/applied during surface creation
    -- We want the checksum to include tags and controls so we can't nil those
    -- Therfore the checksum wil change when surfaces are created
    -- shallow_zone.tags = nil
    -- shallow_zone.controls = nil
    shallow_zones_by_name[zone_name] = shallow_zone
  end
  local universe_string = serpent.line(shallow_zones_by_name)
  local checksum = util.crc32(universe_string)
  log("Universe checksum: " .. checksum)
  game.print(checksum)
  log(serpent.block(shallow_zones_by_name))
end
commands.add_command("se-debug-print-universe-checksum", "", Command.print_universe_checksum)

--- Optional migration to fix bug that could add vitamelange to biter-free special zones
--- Safe to remove after 0.7
---@param command CustomCommandData
function Command.migration_remove_vita_from_special_zones(command)
  local player = game.get_player(command.player_index)
  ---@cast player -?
  if not Command.is_allowed(player, false) then return end

  for _, zone in pairs(storage.zone_index) do
    if zone.special_type and zone.special_type ~= "vitamelange" then

      local surface = Zone.get_surface(zone)
      if surface then
        local mapgen = surface.map_gen_settings
        mapgen.autoplace_controls["se-vitamelange"] = {frequency = 1, size = 0, richness = 0}
        surface.map_gen_settings = mapgen
      end

      zone.controls["se-vitamelange"] = {frequency = 1, size = 0, richness = 0}
      Universe.remove_resource_from_zone_surface(zone, "se-vitamelange")
    end
  end

  game.print("Removed vitamelange from biter-free special zones")
end
commands.add_command("se-migration-remove-vita-from-special-zones", "- Removes vitamelange (and biter meteors) from homeworld special zones that are meant to be guaranteed biter-free. Fix for a bug introduced in 0.6.109.", Command.migration_remove_vita_from_special_zones)

function Command.on_console_command(event)
  if not game.console_command_used then return end
  if event.command ~= "cheat" then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if not player then return end

  if not Command.is_allowed(player, false) then return end -- i wonder if the code even gets this far for non-admins to begin with, failsafe.

  if event.parameters == "" then
    -- nothing
  elseif event.parameters == "all" then
    Command.suit_up({player_index = player.index, parameter = "force"})
    Command.launch_satellite({player_index = player.index, parameter = "4"}) -- 2 for the star map + universe explorer, oil moon & asteroid belt
  -- elseif Zone.from_name(event.parameters) then
  --   local zone = Zone.from_name(event.parameters)
  --   if not zone.surface_index then
  --     Zone.create_surface(zone)
  --   end
  --   player.teleport({0, 0}, zone.surface_index)
  end
end
Event.addListener(defines.events.on_console_command, Command.on_console_command)

return Command
