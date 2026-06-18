local Lifesupport = {}
--[[
Lifesupport mechanics:
Consume lifesupport canisters for food & air

Equipment boosts the lifesupport drain efficiency, stacks additively.
All thruster suits have some base level lifesupport efficiency, 1 module is built-in.

Non-thruster suits can have modules added but only function on land and efficiency benefits are
halved. Only useful on hostile planets. A proper spacesuit is required in space.
]]

Lifesupport.name_gui_root = mod_prefix .. "lifesupport"
Lifesupport.name_button_open_expanded_gui = "open_expanded_gui"
Lifesupport.name_sound_used_canister = mod_prefix .. "canister-breath"
Lifesupport.name_setting_hud_visibility = mod_prefix .. "lifesupport-hud-visibility"

Lifesupport.lifesupport_refill_threshold = 0
Lifesupport.lifesupport_bar_max = 100
Lifesupport.lifesupport_per_second = 1 -- at 100% hazard (space)
Lifesupport.nth_tick_interval = 240 / 60

Lifesupport.min_effective_efficiency = 0.25 -- acts as damage multiplier
Lifesupport.spacesuit_base_efficiency = 1
Lifesupport.non_spacesuit_base_efficiency = 0
Lifesupport.non_spacesuit_efficiency_multiplier = 0.5

Lifesupport.lifesupport_canisters = {
  {
    name = mod_prefix .. "lifesupport-canister",
    used = mod_prefix .. "used-lifesupport-canister",
    lifesupport = 100, -- seconds
  }
}

Lifesupport.lifesupport_equipment = {
  [mod_prefix .. "lifesupport-equipment-1"] = {efficiency = 1},
  [mod_prefix .. "lifesupport-equipment-2"] = {efficiency = 2},
  [mod_prefix .. "lifesupport-equipment-3"] = {efficiency = 4},
  [mod_prefix .. "lifesupport-equipment-4"] = {efficiency = 8},
}

--[[
  playerdata.user_opened_armor_gui -> flag that says user has armor gui open and we show life support gui
  playerdata.environment_hostile -> flag for hostile environment where air is used up
  playerdata.suit_thrust_bonused -> flag for thruster suit giving bonuses to thrusters
]]

---Converts a given number of seconds to HH:MM:SS (or MM:SS if number of hours is 0).
---@param seconds number Number of seconds to convert
---@return string
function Lifesupport.seconds_to_clock(seconds)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds / 60) - (h * 60))
  local s = math.floor(seconds - (m * 60) - (h * 3600))

  local str_h = string.format("%02d", h)
  local str_m_s = string.format("%02d:%02d", m, s)

  if h > 0 then
    return str_h .. ":" .. str_m_s
  else
    return str_m_s
  end
end

---Returns table containing the number of lifesupport canisters in a player's (character's)
---inventory. Returns nil if no character is found or no inventory is found.
---@param player LuaPlayer Player
---@return table<string, uint>? counts Canister counts, indexed by name
function Lifesupport.get_canister_counts(player)
  local character = player.character or player_get_character(player)
  if not character then return end

  local inventory = character.get_main_inventory()
  if not inventory or not inventory.valid then return end

  local counts = {}
  for _, lifesupport_canister in pairs(Lifesupport.lifesupport_canisters) do
    counts[lifesupport_canister.name] = inventory.get_item_count_filtered({name = lifesupport_canister.name})
  end

  return counts
end

---Updates a given player's inventory lifesupport reserves in their `PlayerData`.
---@param player LuaPlayer Player
function Lifesupport.check_inventory_reserve_lifesupport(player)
  local playerdata = get_make_playerdata(player)
  local character = player_get_character(player)
  local inv_reserve = 0

  if character then
    local inv = character.get_main_inventory()
    if inv and inv.valid then
      for _, canister in pairs(Lifesupport.lifesupport_canisters) do
        inv_reserve = inv_reserve + inv.get_item_count_filtered({name = canister.name}) * canister.lifesupport -- todo: quality bonus?
      end
    end

    local zone = Zone.from_surface(character.surface)
    if zone and Zone.is_space(zone) and not playerdata.has_spacesuit then
      ---@cast zone -PlanetType, -MoonType
      inv_reserve = 0
    end
  end

  playerdata.reserve_lifesupport = inv_reserve

  return inv_reserve
end

---Returns the current hazard level of the player, depending on the zone and position they're in. If
---the player is in a space zone or plagued surface, the returned hazard value will be 1, unless
---they're in a vehicle or on board a landed spaceship. Vaults and non-SE surfaces have a hazard
---level of 0.
---@param player LuaPlayer Player
---@return 0|1
function Lifesupport.get_current_hazard(player)
  local playerdata = get_make_playerdata(player)
  local character = player_get_character(player)
  if not character then
    playerdata.lifesupport_environment = "unknown"
    return 0
  end

  local position = Util.position_to_tile(character.position)
  local zone = Zone.from_surface(character.surface)
  local hazard

  if not zone then
    -- Vaults or non-SE surfaces
    playerdata.lifesupport_environment = "unknown"
    hazard = 0
  elseif zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    local spaceship = zone

    if spaceship.known_tiles
        and spaceship.known_tiles[position.x] and spaceship.known_tiles[position.x][position.y]
        and (spaceship.known_tiles[position.x][position.y] == "floor_interior"
          or spaceship.known_tiles[position.x][position.y] == "floor_console_connected"
          or spaceship.known_tiles[position.x][position.y] == "wall_console_connected"
          or spaceship.known_tiles[position.x][position.y] == "bulkhead_console_connected") then
      playerdata.lifesupport_environment = "spaceship-interior"
      hazard = 0
    else
      playerdata.lifesupport_environment = "space"
      hazard = 1
    end
  else
    ---@cast zone -SpaceshipType
    local tile = character.surface.get_tile(position)

    if Util.table_contains(Spaceship.names_spaceship_floors, tile.name) then
      playerdata.lifesupport_environment = "spaceship-interior"
      hazard = 0
    elseif Zone.is_space(zone) then
      ---@cast zone -PlanetType, -MoonType
      playerdata.lifesupport_environment = "space"
      hazard = 1
    else
      ---@cast zone PlanetType|MoonType
      if zone.plague_used then
        playerdata.lifesupport_environment = (zone.type == "moon") and "plague-moon" or "plague-planet"
        hazard = 1
      else
        playerdata.lifesupport_environment = (zone.type == "moon") and "moon" or "planet"
        hazard = 0
      end
    end
  end

  if character.vehicle then hazard = 0 end

  return hazard
end

---Evaluates the player's equipped armor and lifesupport equipment to calculate their lifesupport
---efficiency. This value is returned _and_ used to updated the player's `PlayerData`.
---@param player LuaPlayer
---@return number? lifesupport_efficiency
function Lifesupport.update_lifesupport_efficiency(player)
  local character = player_get_character(player)
  if not character then return end

  local playerdata = get_make_playerdata(player)
  local lifesupport_efficiency = 0
  local has_spacesuit = false

  local armor_inv = character.get_inventory(defines.inventory.character_armor)
  if armor_inv and armor_inv[1] and armor_inv[1].valid_for_read then
    if util.table_contains(name_thruster_suits, armor_inv[1].name) then
      lifesupport_efficiency = Lifesupport.spacesuit_base_efficiency
      has_spacesuit = true
    end

    -- get lifesupport equipment modules
    local grid_efficiency = 0
    if character.grid then
      for _, equipment in pairs(character.grid.get_contents()) do
        if Lifesupport.lifesupport_equipment[equipment.name] ~= nil then
          grid_efficiency = grid_efficiency + equipment.count * (Lifesupport.lifesupport_equipment[equipment.name].efficiency or 0)
        end
      end
    end
    lifesupport_efficiency = lifesupport_efficiency + grid_efficiency
  end

  -- Have lifesupport efficiency if player is not wearing a spacesuit
  if not has_spacesuit then
    lifesupport_efficiency = lifesupport_efficiency / 2
  end

  -- If player is in space and has no spacesuit, set lifesupport efficiency to 0
  local zone = Zone.from_surface(character.surface)
  if zone and Zone.is_space(zone) and not has_spacesuit then
    ---@cast zone -PlanetType, -MoonType
    lifesupport_efficiency = 0
  end

  playerdata.lifesupport_efficiency = lifesupport_efficiency --[[@as uint]]
  playerdata.has_spacesuit = has_spacesuit

  return lifesupport_efficiency
end

---Consumes lifesupport canisters if appropriate and updates the lifesupport HUD/GUI.
---@param event NthTickEventData Event data
function Lifesupport.on_nth_tick(event)
  local tick_interval = Lifesupport.nth_tick_interval
  for _, player in pairs(game.connected_players) do
    if (event.tick/60 + player.index) % tick_interval == 0 then
      Lifesupport.consume_lifesupport(player)
      local was_open, is_open = Lifesupport.assess_visibility(player)
      if was_open and is_open then Lifesupport.gui_update(player) end
      Lifesupport.expandedGUI.update(player)
    end
  end
end
Event.addListener("on_nth_tick_60", Lifesupport.on_nth_tick)

---Consumes lifesupport if the player is in a hazardous zone/space and has the necessary equipment
---and lifesupport canisters.
---@param player LuaPlayer
function Lifesupport.consume_lifesupport(player)
  local playerdata = get_make_playerdata(player)
  local character = player_get_character(player)
  if not character then return end

  local hazard = Lifesupport.get_current_hazard(player)
  local efficiency = Lifesupport.update_lifesupport_efficiency(player) --[[@as number]]

  if hazard > 0 then
    if efficiency > 0 and not playerdata.has_spacesuit then
      local zone = Zone.from_surface(character.surface) --[[@as AnyZoneType|SpaceshipType]]
      if Zone.is_space(zone) then
        ---@cast zone -PlanetType, -MoonType
        efficiency = 0
      end
    end

    local effective_efficiency = math.max(efficiency, Lifesupport.min_effective_efficiency)
    local hazard_use_rate_per_s = Lifesupport.lifesupport_per_second * hazard
    local effective_use_rate_per_s = hazard_use_rate_per_s / effective_efficiency
    local effective_use_per_interval = Lifesupport.nth_tick_interval * effective_use_rate_per_s --[[@as float]]

    if efficiency > 0 then
      -- consume lifesupport
      playerdata.lifesupport = (playerdata.lifesupport or 0) - effective_use_per_interval
      if playerdata.lifesupport <= Lifesupport.lifesupport_refill_threshold then
        Lifesupport.consume_canister(player, playerdata, character)
      end
      if playerdata.lifesupport < 0 then
        Lifesupport.damage_character(player, character, -playerdata.lifesupport)
        playerdata.lifesupport = 0
      end
    else
      -- Lifesupport is not funcitioning. Even if there is a lifesupport buffer it won't do anything
      -- (eg: non-space suit in space.)
      Lifesupport.damage_character(player, character, effective_use_per_interval)
    end
  elseif (playerdata.lifesupport or 0) < Lifesupport.lifesupport_refill_threshold and efficiency > 0 then
    Lifesupport.consume_canister(player, playerdata, character)
  end
end

---Consumes a lifesupport canister from the character's inventory, updating `lifesupport in the
---`PlayerData` table.
---@param player LuaPlayer Player
---@param playerdata PlayerData Playerdata
---@param character LuaEntity Character entity whose inventory to use
function Lifesupport.consume_canister(player, playerdata, character)
  local inventory = character.get_main_inventory()
  if inventory and inventory.valid then
    local prod_stats = player.force.get_item_production_statistics(character.surface)
    for _, lifesupport_canister in pairs(Lifesupport.lifesupport_canisters) do
      local counts = inventory.get_item_quality_counts(lifesupport_canister.name)
      for quality_name, count in pairs(counts) do
        inventory.remove({name=lifesupport_canister.name, count=1, quality=quality_name})
        local inserted = inventory.insert({name=lifesupport_canister.used, count=1, quality=quality_name})
        if inserted < 1 then
          local position = character.position
          character.surface.spill_item_stack{
            position = position,
            stack = {name=lifesupport_canister.used, count=1, quality=quality_name},
            enable_looted = true,
            force = character.force,
            allow_belts = false
          }
          player.create_local_flying_text{
            position = position,
            text = {
              "inventory-restriction.player-inventory-full",
              "[img=item/" .. lifesupport_canister.used .. "]",
              {"inventory-full-message.main"}
            },
          }
        end
        prod_stats.on_flow({name = lifesupport_canister.name, quality = quality_name}, -1)
        prod_stats.on_flow({name = lifesupport_canister.used, quality = quality_name},  1)
        playerdata.lifesupport = (playerdata.lifesupport or 0) + lifesupport_canister.lifesupport -- todo: quality bonus?
        player.play_sound { path = Lifesupport.name_sound_used_canister }
        return
      end
    end
  end
end

---Damages a given character and prints a warning to the player, alerting them that they are
---suffocating.
---@param player LuaPlayer Player
---@param character LuaEntity Character to be damaged
---@param damage float Damage to apply
function Lifesupport.damage_character(player, character, damage)
  if damage > character.health then
    player.print({"?", "[color=red]", {"space-exploration.suffocating-warning"}, "[/color]"})
    character.die("neutral")
    Lifesupport.gui_close(player)
    return
  end

  -- Set shields to 0.
  -- Don't use damage because that can trigger the "golem" achievement.
  local saved_grid_shields = {}
  if character.grid then
    for _, grid_equipment in pairs(character.grid.equipment) do
      if grid_equipment.max_shield > 0 then
        saved_grid_shields[grid_equipment] = grid_equipment.shield
        grid_equipment.shield = 0
      end
    end
    shield_damage = character.grid.shield
  end

  -- We use damage instead of setting health, so that the red screen effect happens.
  character.damage(damage, "neutral", "suffocation")

  -- Restore shields.
  for shield, shield_value in pairs(saved_grid_shields) do
    shield.shield = shield_value
  end

  player.print({"", "[color=red]", {"space-exploration.suffocating-warning"}, "[/color]"})
end

---Returns the player's Lifesupport HUD visibility setting.
---@param player LuaPlayer Player
---@return uint selected_option
function Lifesupport.get_visibility_setting(player)
  local playerdata = get_make_playerdata(player)
  local visibility = playerdata.lifesupport_hud_visibility_setting

  if visibility then
    return visibility
  else
    local str = player.mod_settings[Lifesupport.name_setting_hud_visibility].value --[[@as string]]
    playerdata.lifesupport_hud_visibility_setting = tonumber(str:sub(-1)) --[[@as uint]]
    return playerdata.lifesupport_hud_visibility_setting
  end
end

---Handles a change in the player settings related to the Lifesupport HUD's visibility
---@param event EventData.on_runtime_mod_setting_changed Event data
function Lifesupport.on_runtime_mod_setting_changed(event)
  if event.setting ~= Lifesupport.name_setting_hud_visibility then return end

  -- If a player made the change, update the value for that player alone
  if event.player_index then
    local player = game.get_player(event.player_index)
    ---@cast player -?
    local playerdata = get_make_playerdata(player)

    playerdata.lifesupport_hud_visibility_setting = nil
    Lifesupport.get_visibility_setting(player)
    Lifesupport.assess_visibility(player)
  else
    -- Otherwise, update the stored value for all players
    for _, player in pairs(game.players) do
      local playerdata = get_make_playerdata(player)

      playerdata.lifesupport_hud_visibility_setting = nil
      Lifesupport.get_visibility_setting(player)
      Lifesupport.assess_visibility(player)
    end
  end
end
Event.addListener(defines.events.on_runtime_mod_setting_changed, Lifesupport.on_runtime_mod_setting_changed)

---Handles equipment grid changes.
---@param event EventData.on_player_placed_equipment|EventData.on_player_removed_equipment Event data
function Lifesupport.on_equipment_changed(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?

  -- Recalculate lifesupport efficiency after equipment change
  Lifesupport.update_lifesupport_efficiency(player)

  local was_open, is_open = Lifesupport.assess_visibility(player)

  if was_open and is_open then Lifesupport.gui_update(player) end
  Lifesupport.expandedGUI.update(player)
end
Event.addListener(defines.events.on_player_placed_equipment, Lifesupport.on_equipment_changed)
Event.addListener(defines.events.on_player_removed_equipment, Lifesupport.on_equipment_changed)

---Updates lifesupport HUD in response to the player putting an an armor with lifesupport
---efficiency.
---@param event EventData.on_player_armor_inventory_changed Event data
function Lifesupport.on_armor_changed(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?

  -- Recalculate lifesupport efficiency using new armor
  Lifesupport.update_lifesupport_efficiency(player)

  local was_open, is_open = Lifesupport.assess_visibility(player)
  local playerdata = get_make_playerdata(player)

  --- Reset lifesupport if this was not related to a jetpack character swap
  if playerdata.preserve_buffer_next_armor_change then
    playerdata.preserve_buffer_next_armor_change = nil
  else
    playerdata.lifesupport = 0
  end

  --- Update GUIs
  if was_open and is_open then Lifesupport.gui_update(player) end
  Lifesupport.expandedGUI.update(player)
end
Event.addListener(defines.events.on_player_armor_inventory_changed, Lifesupport.on_armor_changed)

---Updates the lifesupport HUD in response to a surface change.
---@param event EventData.on_player_changed_surface Event data
function Lifesupport.on_player_changed_surface(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?

  -- Recalculate efficiency, taking into account player's new location
  Lifesupport.update_lifesupport_efficiency(player)

  local was_open, is_open = Lifesupport.assess_visibility(player)

  if was_open and is_open then Lifesupport.gui_update(player) end
  Lifesupport.expandedGUI.update(player)
end
Event.addListener(defines.events.on_player_changed_surface, Lifesupport.on_player_changed_surface)

---Handles the player getting into and out of vehicles.
---@param event EventData.on_player_driving_changed_state Event data
function Lifesupport.on_player_driving_changed_state(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local was_open, is_open = Lifesupport.assess_visibility(player)

  if was_open and is_open then Lifesupport.gui_update(player) end
  Lifesupport.expandedGUI.update(player)
end
Event.addListener(defines.events.on_player_driving_changed_state, Lifesupport.on_player_driving_changed_state)

---Returns the color that should be used for the lifesupport reserves label.
---@param reserves number Time reserves in seconds
---@param hazard 0|1 Hazard level
---@return Color color Color table
function Lifesupport.get_reserves_color(reserves, hazard)
  if hazard > 0 then
    if reserves < 300 then
      return {255, 80, 90}
    elseif reserves < 900 then
      return {255, 220, 50}
    else
      return {255, 255, 255}
    end
  else
    return {255, 255, 255}
  end
end

---Evaluates a player's current environment and GUI visibility setting to determine if GUI should be
---open or closed. Returns true if GUi was opened, false if it was closed, and nil if visibility was
---it was neither opened or closed.
---@param player LuaPlayer Player
---@return boolean old_state Whether GUI was previously open
---@return boolean new_state Whether GUI was previously closed
function Lifesupport.assess_visibility(player)
  local playerdata = get_make_playerdata(player)
  local visibility = Lifesupport.get_visibility_setting(player)
  local old_state = Lifesupport.get_gui(player) and true or false
  local new_state

  if visibility == 1 then
    new_state = true
  elseif visibility == 2 then
    local hazard = Lifesupport.get_current_hazard(player)
    local efficiency = playerdata.lifesupport_efficiency or Lifesupport.update_lifesupport_efficiency(player)

    if (hazard or 0) > 0 or (efficiency or 0) > 0 then
      new_state = true
    else
      new_state = false
    end
  elseif visibility == 3 then
    local hazard = Lifesupport.get_current_hazard(player)

    if (hazard or 0) > 0 then
      new_state = true
    else
      new_state = false
    end
  elseif visibility == 4 then
    new_state = false
  end

  -- Open or close GUI if needed
  if old_state ~= new_state then
    if new_state then
      Lifesupport.gui_open(player)
    else
      Lifesupport.gui_close(player)
    end
  end

  return old_state, new_state
end

---Returns the lifesupport HUD for a given player, if it is open.
---@param player LuaPlayer Player
---@return LuaGuiElement? root
function Lifesupport.get_gui(player)
  return player.gui.screen[Lifesupport.name_gui_root]
end

---Opens the lifesupport HUD for a given player
---@param player LuaPlayer Player
function Lifesupport.gui_open(player)
  if Lifesupport.get_gui(player) then return end

  local root = player.gui.screen.add{
    type = "frame",
    style = "se_lifesupport_frame",
    name = Lifesupport.name_gui_root,
    direction = "horizontal",
  }

  do -- Move GUI to player's previously saved location or find a new one.
    local resolution = player.display_resolution
    local scaling = player.display_scale
    local playerdata = get_make_playerdata(player)
    local gui_location = playerdata.lifesupport_hud_location

    -- Check if saved gui location is within player's existing screen resolution
    if gui_location and (gui_location.x > resolution.width - (150 * scaling) or
          gui_location.y > resolution.height - (96 * scaling)) then
      gui_location = nil
    end

    if not gui_location then
      gui_location = {
        (resolution.width / 2) - ((257 + 150) * scaling),
        (resolution.height) - (96 * scaling)
      }
    end

    root.location = gui_location
  end

  local left_flow = root.add{type="flow", direction="vertical"}
  left_flow.add {
    name = Lifesupport.name_button_open_expanded_gui,
    tooltip = {"space-exploration.lifesupport_hud_button_tooltip"},
    type = "sprite-button",
    sprite = "utility/expand_dots",
    style = "se_lifesupport_left_minimize_button"
  }
  local drag_handle = left_flow.add{type="empty-widget", style="se_lifesupport_draggable_space"}
  drag_handle.drag_target = root

  local inner_panel = root.add { type = "frame", name = "panel", direction = "vertical", style = "se_lifesupport_panel" }

  -- Progress bar
  inner_panel.add { type = "progressbar", name = "lifesupport_bar", size = 100, value = 0,
    style = "se_lifesupport_progressbar", tooltip = {"space-exploration.lifesupport_suit_tooltip"} }

  -- Lifesupport reserves flow
  local flow_reserves = inner_panel.add { type = "flow", name = "time_reserves_flow", direction = "horizontal",
    style = "se_lifesupport_text_flow" }
  flow_reserves.add { type = "sprite", name = "space_suit",
    sprite = "utility/character_inventory_slots_bonus_modifier_icon", style = "se_lifesupport_sprite",
    tooltip = { "space-exploration.lifesupport_reserves_duration_tooltip" } }
  flow_reserves.add { type = "label", name = "lifesupport_reserves", style = "se_lifesupport_label_reserves",
    tooltip = { "space-exploration.lifesupport_reserves_duration_tooltip" } }
  flow_reserves.add { type = "empty-widget", style = "se_relative_properties_spacer" }
  flow_reserves.add { type = "sprite", name = "info", sprite = "info_no_border", style = "se_lifesupport_sprite_info" }

  -- Lifesupport canisters flow
  local flow_canisters = inner_panel.add { type = "flow", name = "canister_reserves_flow", direction = "horizontal",
    style = "se_lifesupport_text_flow" }
  flow_canisters.add { type = "sprite", sprite = "item/se-lifesupport-canister", style = "se_lifesupport_sprite",
    tooltip = { "space-exploration.lifesupport_reserves_canisters_tooltip" } }
  flow_canisters.add { type = "label", name = "lifesupport_canisters",
    tooltip = { "space-exploration.lifesupport_reserves_canisters_tooltip" } }
  flow_canisters.add { type = "empty-widget", style = "se_relative_properties_spacer" }
  flow_canisters.add { type = "label", name = "lifesupport_efficiency",
    tooltip = { "space-exploration.lifesupport_efficiency_tooltip" } }
  Lifesupport.gui_update(player)
end

---Closes the Lifesupport HUD of the given player.
---@param player LuaPlayer Player
function Lifesupport.gui_close(player)
  local gui = Lifesupport.get_gui(player)

  if gui then
    local playerdata = get_make_playerdata(player)
    playerdata.lifesupport_hud_location = gui.location
    gui.destroy()
  end
end

---Prepares lifesupport information and returns a table that can be used to quickly update the
---different lifesupport GUIs.
---@param player LuaPlayer Player
---@return LifeSupportInfo?
function Lifesupport.prepare_update(player)
  local character = player_get_character(player)
  if not character then return end

  local playerdata = get_make_playerdata(player)
  Lifesupport.check_inventory_reserve_lifesupport(player)
  local hazard_actual = Lifesupport.get_current_hazard(player)
  if not playerdata.lifesupport_efficiency then
    Lifesupport.update_lifesupport_efficiency(player)
  end

  local efficiency = playerdata.lifesupport_efficiency
  if efficiency > 0 and not playerdata.has_spacesuit then
    local zone = Zone.from_surface(character.surface)
    if zone and Zone.is_space(zone) then
      ---@cast zone -PlanetType, -MoonType
      efficiency = 0
    end
  end

  local standard_hazard = 1
  local hazard_use_rate_per_s = Lifesupport.lifesupport_per_second * standard_hazard
  local lifesupport_suit_s = (playerdata.lifesupport or 0) * efficiency / hazard_use_rate_per_s
  local lifesupport_reserve_s = (playerdata.reserve_lifesupport or 0) * efficiency / hazard_use_rate_per_s
  local lifesupport_duration = Lifesupport.seconds_to_clock(lifesupport_suit_s)
  local lifesupport_reserve_duration = Lifesupport.seconds_to_clock(lifesupport_reserve_s)
  local counts = Lifesupport.get_canister_counts(player)

  return {
    suit_lifesupport_value = math.max(0, math.min(Lifesupport.lifesupport_bar_max, (playerdata.lifesupport or 0) / Lifesupport.lifesupport_bar_max)),
    suit_lifesupport_str = lifesupport_duration,
    inventory_lifesupport_str = lifesupport_reserve_duration,
    inventory_lifesupport_color = Lifesupport.get_reserves_color(lifesupport_reserve_s, hazard_actual),
    inventory_canisters = counts[Lifesupport.lifesupport_canisters[1].name],
    lifesupport_efficiency_str = string.format("×%.f%%", playerdata.lifesupport_efficiency * 100),
    hazard = hazard_actual,
    lifesupport_environment = playerdata.lifesupport_environment,
    has_spacesuit = playerdata.has_spacesuit
  }
end

---Updates the Lifesupport HUD of the given player, if it is open.
---@param player LuaPlayer Player
function Lifesupport.gui_update(player)
  local root = Lifesupport.get_gui(player)
  if not root then return end

  -- Close GUI if data is nil, as that happens when no character is found
  local data = Lifesupport.prepare_update(player)
  if not data then Lifesupport.gui_close(player) return end

  root.panel.lifesupport_bar.value = data.suit_lifesupport_value
  root.panel.lifesupport_bar.caption = data.suit_lifesupport_str
  root.panel.lifesupport_bar.style.color = (data.hazard == 0) and {0.8, 0.8, 0.8} or {70/255, 171/255, 255/255}

  root.panel.time_reserves_flow.lifesupport_reserves.caption = data.inventory_lifesupport_str
  root.panel.time_reserves_flow.lifesupport_reserves.style.font_color = data.inventory_lifesupport_color

  root.panel.canister_reserves_flow.lifesupport_canisters.caption = data.inventory_canisters
  root.panel.canister_reserves_flow.lifesupport_efficiency.caption = data.lifesupport_efficiency_str

  if data.has_spacesuit then
    root.panel.time_reserves_flow.info.sprite = "info_no_border"
    root.panel.time_reserves_flow.info.tooltip = {
      "",
      {"space-exploration.lifesupport_environment"},
      ": ",
      {"space-exploration.lifesupport_environment_" .. data.lifesupport_environment}
    }
  else
    root.panel.time_reserves_flow.info.sprite = "utility/warning_icon"
    root.panel.time_reserves_flow.info.tooltip = {"",
      {
        "",
        {"space-exploration.lifesupport_environment"},
        ": ",
        {"space-exploration.lifesupport_environment_" .. data.lifesupport_environment}},
      "\n\n",
      {"space-exploration.lifesupport_no_spacesuit"}
    }
  end
end

---Handles button clicks on the single lifesupport HUD button.
---@param event EventData.on_gui_click Event data
function Lifesupport.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local root = gui_element_or_parent(event.element, Lifesupport.name_gui_root)
  if not root then return end

  if event.element.name == Lifesupport.name_button_open_expanded_gui then
    local player = game.get_player(event.player_index)
    ---@cast player -?

    -- Close the expanded GUI if it's already open and vice versa
    if Lifesupport.expandedGUI.get(player) then
      Lifesupport.expandedGUI.close(player)
    else
      Lifesupport.expandedGUI.open(player)
    end
  end
end
Event.addListener(defines.events.on_gui_click, Lifesupport.on_gui_click)

---Handles the player moving the lifesupport HUD
---@param event EventData.on_gui_location_changed Event data
function Lifesupport.on_gui_location_changed(event)
  if not event.element.valid or event.element.name ~= Lifesupport.name_gui_root then return end

  local player = game.get_player(event.player_index)
  ---@cast player -?
  local resolution = player.display_resolution
  local scaling = player.display_scale
  local location = event.element.location
  local element_width = 150
  local element_height = 96
  local x = location.x
  local y = location.y
  local anchors = {
    { -- Left of quickbar
      x = (resolution.width / 2) - ((257 + element_width) * scaling),
      x_range = 10,
      x_snap = true,
      y = resolution.height - (element_height * scaling),
      y_range = 10,
      y_snap = true
    },
    { -- Left of tool window (with the "tool window next to quickbar" option on)
      x = (resolution.width / 2) - ((445 + element_width) * scaling),
      x_range = 10,
      x_snap = true,
      y = resolution.height - (element_height * scaling),
      y_range = 10,
      y_snap = true
    },
    { -- Bottom left
      x = 0,
      x_range = 10,
      x_snap = true,
      y = resolution.height - (element_height * scaling),
      y_range = 10,
      y_snap = true
    },
    { -- Bottom right
      x = resolution.width - (element_width * scaling),
      x_range = 10,
      x_snap = true,
      y = resolution.height - (element_height * scaling),
      y_range = 10,
      y_snap = true
    },
    { -- Left of minimap
      x = resolution.width - ((256 + element_width) * scaling),
      x_range = 10,
      x_snap = true,
      y = ((360 - element_height) * scaling) / 2,
      y_range = ((360 - element_height) * scaling) / 2,
      y_snap = false
    },
    { -- Left
      x = 0,
      x_range = 10,
      x_snap = true,
      y = resolution.height / 2,
      y_range = resolution.height / 2,
      y_snap = false
    },
    { -- Top
      x = resolution.width / 2,
      x_range = resolution.width / 2,
      x_snap = false,
      y = 0,
      y_range = 10,
      y_snap = true
    },
    { -- Right
      x = resolution.width - (element_width * scaling),
      x_range = 10,
      x_snap = true,
      y = resolution.height / 2,
      y_range = resolution.height / 2,
      y_snap = false
    },
    { --  Bottom
      x = resolution.width / 2,
      x_range = resolution.width / 2,
      x_snap = false,
      y = resolution.height - (element_height * scaling),
      y_range = 10,
      y_snap = true
    },
  }

  for _, anchor in pairs(anchors) do
    if math.abs(x - anchor.x) <= anchor.x_range and math.abs(y - anchor.y) <= anchor.y_range then
      event.element.location = {
        anchor.x_snap and anchor.x or x,
        anchor.y_snap and anchor.y or y
      }
      break
    end
  end
end
Event.addListener(defines.events.on_gui_location_changed, Lifesupport.on_gui_location_changed)

------------------
-- Expanded GUI --
------------------

Lifesupport.expandedGUI = {
  name_gui_root = mod_prefix .. "lifesupport-expanded",
  name_button_close = mod_prefix .. "lifesupport-expanded-button-close",
  name_dropdown_visibility = mod_prefix .. "lifesupport-hud-visibility",
  name_shortcut_toggle = mod_prefix .. "toggle-lifesupport"
}

---Returns the expanded Lifesupport GUI root `LuaGuiElement`, if it is open for a given player.
---@param player LuaPlayer Player
function Lifesupport.expandedGUI.get(player)
  return player.gui.screen[Lifesupport.expandedGUI.name_gui_root]
end

---Opens the Lifesupport expanded GUI
---@param player LuaPlayer Player
function Lifesupport.expandedGUI.open(player)
  if player.gui.screen[Lifesupport.expandedGUI.name_gui_root] then return end

  local root = player.gui.screen.add{
    type = "frame",
    style = "se_lifesupport_expanded_frame",
    name = Lifesupport.expandedGUI.name_gui_root,
    direction = "vertical"
  }
  root.force_auto_center()

  do -- Titlebar
    local titlebar = root.add{
      type = "flow",
      direction = "horizontal",
      style = "se_relative_titlebar_flow"
    }

    titlebar.add{  -- Icon
      type = "sprite",
      sprite = "se-lifesupport-icon",
      style = "se_lifesupport_expanded_title_icon"
    }

    local label = titlebar.add{  -- GUI label
      type="label",
      caption={"space-exploration.lifesupport_gui_expanded_title"},
      style="frame_title"
    }
    label.drag_target = root

    local spacer = titlebar.add{  -- Spacer
      type = "empty-widget",
      style = "se_relative_titlebar_draggable_spacer"
    }
    spacer.drag_target = root

    titlebar.add { -- Informatron button
      type = "sprite-button",
      sprite = "virtual-signal/informatron",
      style = "frame_action_button",
      tooltip = { "space-exploration.informatron-open-help" },
      tags = { se_action = "goto-informatron", informatron_page = "lifesupport" }
    }

    titlebar.add { -- Close button
      type = "sprite-button",
      name = Lifesupport.expandedGUI.name_button_close,
      sprite = "utility/close",
      style = "frame_action_button",
      tooltip = { "space-exploration.close" }
    }
  end

  local shallow_frame = root.add{
    type="frame",
    name="shallow_frame",
    direction="vertical",
    style="inside_shallow_frame"
  }

  local subheader_frame = shallow_frame.add{
    type="frame",
    name="subheader_frame",
    direction="vertical",
    style="se_lifesupport_expanded_subheader_frame"
  }

  do -- Add all labels
      -- Suit reserves
    local suit_reserves = subheader_frame.add{type="flow", direction="horizontal"}
    suit_reserves.add{type="label", caption={"space-exploration.lifesupport_suit"},
      style="se_relative_properties_label", tooltip={"space-exploration.lifesupport_suit_tooltip"}}
    suit_reserves.add{type="empty-widget", style="se_relative_properties_spacer"}
    suit_reserves.add{type="label", name="suit_reserves", caption=""}

    -- Inventory reserves duration
    local inventory_reserves = subheader_frame.add{type="flow", direction="horizontal"}
    inventory_reserves.add{type="label", caption={"space-exploration.lifesupport_reserves_duration"},
      style="se_relative_properties_label", tooltip={"space-exploration.lifesupport_reserves_duration_tooltip"}}
    inventory_reserves.add{type="empty-widget", style="se_relative_properties_spacer"}
    inventory_reserves.add{type="label", name="inventory_reserves", caption=""}

    -- Inventory reserves canisters
    local inventory_canisters = subheader_frame.add{type="flow", direction="horizontal"}
    inventory_canisters.add{type="label", caption={"space-exploration.lifesupport_reserves_canisters"},
      style="se_relative_properties_label", tooltip={"space-exploration.lifesupport_reserves_canisters_tooltip"}}
    inventory_canisters.add{type="empty-widget", style="se_relative_properties_spacer"}
    inventory_canisters.add{type="label", name="inventory_canisters", caption=""}

    -- Lifesupport efficiency
    local efficiency = subheader_frame.add{type="flow", direction="horizontal"}
    efficiency.add{type="label", caption={"space-exploration.lifesupport_efficiency"},
      style="se_relative_properties_label", tooltip={"space-exploration.lifesupport_efficiency_tooltip"}}
    efficiency.add{type="empty-widget", style="se_relative_properties_spacer"}
    efficiency.add{type="label", name="lifesupport_efficiency", caption=""}

    -- Lifesupport environment
    local environment = subheader_frame.add{type="flow", direction="horizontal"}
    environment.add{type="label", caption={"space-exploration.lifesupport_environment"},
      style="se_relative_properties_label", tooltip={"space-exploration.lifesupport_environment_tooltip"}}
    environment.add{type="empty-widget", style="se_relative_properties_spacer"}
    environment.add{type="label", name="lifesupport_environment", caption=""}

    -- Lifesupport hazard
    local hazard = subheader_frame.add{type="flow", direction="horizontal"}
    hazard.add{type="label", caption={"space-exploration.lifesupport_hazard"},
      style="se_relative_properties_label", tooltip={"space-exploration.lifesupport_hazard_tooltip"}}
    hazard.add{type="empty-widget", style="se_relative_properties_spacer"}
    hazard.add{type="label", name="lifesupport_hazard", caption=""}
  end

  local inner_frame = shallow_frame.add{
    type="flow", name="capsule_gui_inner",
    direction="vertical",
    style="se_entity_settings_inner_flow"}

  inner_frame.add{
    type = "label",
    caption = {"space-exploration.lifesupport_hud_visibility_dropdown_label"},
    tooltip = {"space-exploration.lifesupport_hud_visibility_dropdown_tooltip"}
  }

  inner_frame.add{
    type = "drop-down",
    name = Lifesupport.expandedGUI.name_dropdown_visibility,
    items = {
      {"string-mod-setting.se-lifesupport-hud-visibility-option-1"},
      {"string-mod-setting.se-lifesupport-hud-visibility-option-2"},
      {"string-mod-setting.se-lifesupport-hud-visibility-option-3"},
      {"string-mod-setting.se-lifesupport-hud-visibility-option-4"}
    },
    selected_index = Lifesupport.get_visibility_setting(player)
  }

  Lifesupport.expandedGUI.update(player)
end

---Updates the expanded GUI for a given player.
---@param player LuaPlayer Player
function Lifesupport.expandedGUI.update(player)
  local root = Lifesupport.expandedGUI.get(player)
  if not root then return end

  local data = Lifesupport.prepare_update(player)
  if not data then Lifesupport.expandedGUI.close(player) return end

  local subheader = root.shallow_frame.subheader_frame
  local suit_reserves = util.find_first_descendant_by_name(subheader, "suit_reserves")
  local inventory_reserves = util.find_first_descendant_by_name(subheader, "inventory_reserves")
  local inventory_canisters = util.find_first_descendant_by_name(subheader, "inventory_canisters")
  local lifesupport_efficiency = util.find_first_descendant_by_name(subheader, "lifesupport_efficiency")
  local lifesupport_environment = util.find_first_descendant_by_name(subheader, "lifesupport_environment")
  local lifesupport_hazard= util.find_first_descendant_by_name(subheader, "lifesupport_hazard")

  suit_reserves.caption = data.suit_lifesupport_str
  inventory_reserves.caption = data.inventory_lifesupport_str
  inventory_reserves.style.font_color = data.inventory_lifesupport_color
  inventory_canisters.caption = data.inventory_canisters .. string.format(" [img=item/%s]", Lifesupport.lifesupport_canisters[1].name)
  lifesupport_efficiency.caption = data.lifesupport_efficiency_str:sub(3)
  lifesupport_environment.caption = {"space-exploration.lifesupport_environment_" .. data.lifesupport_environment}
  lifesupport_hazard.caption = {"space-exploration.lifesupport_hazard_" .. ((data.hazard == 1) and "true" or "false")}
end

---Closes the expanded GUI for a given player.
---@param player LuaPlayer Player
function Lifesupport.expandedGUI.close(player)
  local root = player.gui.screen[Lifesupport.expandedGUI.name_gui_root]
  if root then root.destroy() end
end

---Handles the player clicking on elements in the Lifesupport GUI window.
---@param event EventData.on_gui_click Event data
function Lifesupport.expandedGUI.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local root = gui_element_or_parent(event.element, Lifesupport.expandedGUI.name_gui_root)
  if not root then return end

  if event.element.name == Lifesupport.expandedGUI.name_button_close then
    Lifesupport.expandedGUI.close(game.get_player(event.player_index) --[[@as LuaPlayer]])
  end
end
Event.addListener(defines.events.on_gui_click, Lifesupport.expandedGUI.on_gui_click)

---Handles the player modifying lifesupport HUD visibility setting using the expanded GUI.
---@param event EventData.on_gui_selection_state_changed Event data
function Lifesupport.expandedGUI.on_gui_selection_state_changed(event)
  local root = gui_element_or_parent(event.element, Lifesupport.expandedGUI.name_gui_root)
  if not root then return end

  if event.element.name == Lifesupport.expandedGUI.name_dropdown_visibility then
    local player = game.get_player(event.player_index)
    ---@cast player -?

    -- Update player setting; `<PlayerData>.lifesupport_hud_visibility_setting` will be updated
    -- by event handler.
    player.mod_settings[Lifesupport.name_setting_hud_visibility] =
      {value = "option-" .. event.element.selected_index}
  end
end
Event.addListener(defines.events.on_gui_selection_state_changed, Lifesupport.expandedGUI.on_gui_selection_state_changed)

---Handles the lifesupport GUI toggle shortcut.
---@param event EventData.on_lua_shortcut Event data
function Lifesupport.expandedGUI.on_lua_shortcut(event)
  if event.prototype_name ~= Lifesupport.expandedGUI.name_shortcut_toggle then return end

  local player = game.get_player(event.player_index)
  ---@cast player -?

  -- Close the expanded GUI if it's already open and vice versa
  if Lifesupport.expandedGUI.get(player) then
    Lifesupport.expandedGUI.close(player)
  else
    Lifesupport.expandedGUI.open(player)
  end
end
Event.addListener(defines.events.on_lua_shortcut, Lifesupport.expandedGUI.on_lua_shortcut)

return Lifesupport
