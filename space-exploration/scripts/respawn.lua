local Respawn = {}

--custon event
--/c remote.call("space-exploration", "get_on_player_respawned_event")
--script.on_event(remote.call("space-exploration", "get_on_player_respawned_event"), my_event_handler)
Respawn.on_player_respawned_event = script.generate_event_name()

-- constants
Respawn.name_gui = mod_prefix.."respawn-gui"
Respawn.name_shortcut = mod_prefix.."respawn"
Respawn.name_button_event = mod_prefix.."respawn"
Respawn.keep_percent = 0.9
Respawn.corpse_inventory_size_buffer = 100
Respawn.non_colliding_search_radius = 128

---@param player LuaPlayer
---@param surface LuaSurface
---@param position? MapPosition
function Respawn.at(player, surface, position)
  Log.debug_log("Respawning " .. player.name .. " on " .. surface.name .. " at " .. serpent.line(position))
  position = position or player.force.get_spawn_position(surface) or {0,0}
  player.teleport(position, surface)

  local character = surface.create_entity{name="character", position=position, force=player.force, raise_built=true}
  local playerdata = get_make_playerdata(player)

  -- If character creation failed, create a new one without raising any events.
  -- Fixes factorio-mods#180.
  if not character then
    character = surface.create_entity{name="character", position=position, force=player.force, raise_built=false}
    ---@cast character -?
  end

  playerdata.death_surface = nil
  playerdata.death_position = nil
  Respawn.set_data(playerdata, character)
  player.set_controller{type = defines.controllers.character, character = character}
  teleport_non_colliding_player(player, position, nil, nil, 0.25)
  Respawn.close_gui(player)
  RemoteView.stop(player)
  --script.raise_event(defines.events.on_player_respawned, {player_index=player.index}) -- crashes in 0.18.27
  script.raise_event(Respawn.on_player_respawned_event, {player_index = player.index, cause=playerdata.death_cause})
  playerdata.death_cause = nil
  on_player_spawned({player_index=player.index})
end

---@param player LuaPlayer
---@param zone AnyZoneType
---@param position? MapPosition
function Respawn.at_zone(player, zone, position)
  Respawn.at(player, Zone.get_make_surface(zone), position)
end

---@param player LuaPlayer
---@param entity LuaEntity
function Respawn.at_entity(player, entity)
  if not entity or not entity.valid then
    return -- Do nothing, GUI won't close if we don't use Respawn.at
  end
  local surface = entity.surface
  local position = {0,0}
  if entity.position then
    position = entity.position
    if entity.bounding_box then
      local entity_height = entity.bounding_box.right_bottom.y - entity.bounding_box.left_top.y
      position.y = position.y + entity_height / 2 -- Spawn south of the entity
    end
  end
  Respawn.at(player, surface, position)
end

---@param player LuaPlayer
---@return boolean
local function physically_on_a_space_age_planet(player)
  return player.physical_surface.planet ~= nil and player.physical_surface.name ~= "nauvis"
end

---@param force_name string
---@return boolean
local function force_has_a_landing_pad(force_name)
  local all_zone_assets = Zone.get_all_force_assets(force_name)
  for _zone_index, zone_assets in pairs(all_zone_assets) do
    if zone_assets.rocket_landing_pad_names and next(zone_assets.rocket_landing_pad_names) then
      return true
    end
  end
  return false
end

---@param force_name string
---@return boolean
local function force_has_a_spaceship(force_name)
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.force_name == force_name then
      return true
    end
  end
  return false
end

---@param player LuaPlayer
---@return {home_zone:boolean, sa_planet:boolean, closest_rocket_landing_pad:boolean, closest_spaceship:boolean}
function Respawn.get_options(player)
  local force_name = player.force.name
  return {
    home_zone = true,
    sa_planet = physically_on_a_space_age_planet(player),
    closest_rocket_landing_pad = force_has_a_landing_pad(force_name),
    closest_spaceship = force_has_a_spaceship(force_name),
  }
end

---@param player LuaPlayer
---@return LocationReference
local function get_death_info(player)
  local playerdata = get_make_playerdata(player)
  local death_info = {} -- zone, surface, position

  -- Zone & surface
  local death_zone
  if playerdata.death_surface and playerdata.death_surface.valid then
    death_info.surface = playerdata.death_surface
    local vault = Ancient.vault_from_surface(playerdata.death_surface)
    if vault then
      death_zone = Zone.from_zone_index(vault.zone_index)
    else
      death_zone = Zone.from_surface(playerdata.death_surface)
    end
  end
  if not death_zone then death_zone = Zone.get_force_home_zone(player.force.name) end
  death_info.zone = death_zone

  -- Position
  if playerdata.death_position then
    death_info.position = playerdata.death_position
  else
    death_info.position = {0, 0}
  end
  return death_info
end

---@param entity_list LuaEntity[]
---@param zone AnyZoneType
---@param position MapPosition
---@param pick_random boolean
---@return LuaEntity?
local function pick_from_entities(entity_list, zone, position, pick_random)
  if #entity_list == 1 then
    return entity_list[1]
  elseif #entity_list >= 2 then
    if pick_random then
      return Util.random_from_array(entity_list)
    else
      return Zone.get_surface(zone).get_closest(position, entity_list)
    end
  else
    return nil -- 0 found, could happen if the entities were removed between dying and clicking the respawn button
  end
end

---@return LuaEntity?
local function closest_rocket_landing_pad(player)
  local force_name = player.force.name
  local death_info = get_death_info(player)

  local respawn_zone
  local all_zone_assets = Zone.get_all_force_assets(force_name)
  local death_zone_assets = all_zone_assets[death_info.zone.index]
  local pick_random = false
  if death_zone_assets and death_zone_assets.rocket_landing_pad_names and next(death_zone_assets.rocket_landing_pad_names) then
    -- Same zone
    respawn_zone = death_info.zone
  else
    -- Different zone
    pick_random = true
    local landing_pad_zones = {}
    for zone_index, zone_assets in pairs(all_zone_assets) do
      if zone_assets.rocket_landing_pad_names and next(zone_assets.rocket_landing_pad_names) then
        table.insert(landing_pad_zones, Zone.from_zone_index(zone_index))
      end
    end
    respawn_zone = Zone.get_closest_zone(death_info.zone, landing_pad_zones)
  end

  local zone_landing_pads = Zone.get_force_landing_pads(force_name, respawn_zone.index)
  local zone_landing_pads_containers = {}
  for _, zone_landing_pad in pairs(zone_landing_pads) do
    table.insert(zone_landing_pads_containers, zone_landing_pad.container)
  end
  return pick_from_entities(zone_landing_pads_containers, respawn_zone, death_info.position, pick_random)
end

---@return LuaEntity?
local function closest_spaceship_console(player)
  local death_info = get_death_info(player)
  local spaceship_zones = {}
  local spaceships_by_zone = {}
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.force_name == player.force.name and spaceship.console and spaceship.console.valid then
      local spaceship_zone = Zone.from_surface(Spaceship.get_current_surface(spaceship))
      if spaceship_zone then
        table.insert(spaceship_zones, spaceship_zone)
        spaceships_by_zone[spaceship_zone.index] = spaceships_by_zone[spaceship_zone.index] or {}
        table.insert(spaceships_by_zone[spaceship_zone.index], spaceship)
      end
    end
  end

  local respawn_zone = Zone.get_closest_zone(death_info.zone, spaceship_zones)
  local pick_random = respawn_zone.index ~= death_info.zone.index

  local zone_spaceship_consoles = {}
  for _, spaceship in pairs(spaceships_by_zone[respawn_zone.index]) do
    table.insert(zone_spaceship_consoles, spaceship.console)
  end
  return pick_from_entities(zone_spaceship_consoles, respawn_zone, death_info.position, pick_random)
end

---@param event EventData.on_gui_click Event data
function Respawn.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, Respawn.name_gui)
  if not root then return end

  if element.name == "planet" then
    Respawn.at_zone(player, Zone.get_force_home_zone(player.force.name))
  elseif element.name == "sa-planet" then
    Respawn.at(player, get_death_info(player).surface)
  elseif element.name == "rocket-landing-pad" then
    Respawn.at_entity(player, closest_rocket_landing_pad(player))
  elseif element.name == "spaceship" then
    Respawn.at_entity(player, closest_spaceship_console(player))
  end
end
Event.addListener(defines.events.on_gui_click, Respawn.on_gui_click)

---@param player LuaPlayer
function Respawn.close_gui (player)
  if player.character and player.gui.center[Respawn.name_gui] then
    player.gui.center[Respawn.name_gui].destroy()
  end
end

---@param player LuaPlayer
function Respawn.open_gui (player)
  local gui = player.gui.center
  gui.clear()
  local options = Respawn.get_options(player)
  local root = gui.add{ type = "frame", name = Respawn.name_gui, direction="vertical", caption={"space-exploration.respawn-options-title"}}
  local flow = root.add{ type="flow", name="respawn_options", direction="vertical"}
  if options.home_zone then
    flow.add{ type = "button", caption = {"space-exploration.respawn-button-homeworld"}, name = "planet"}
  end
  if options.sa_planet then
    flow.add{ type = "button", caption = {"space-exploration.respawn-button-sa-planet"}, name = "sa-planet"}
  end
  if options.closest_rocket_landing_pad then
    flow.add{ type = "button", caption = {"space-exploration.respawn-button-landing-pad"}, name = "rocket-landing-pad"}
  end
  if options.closest_spaceship then
    flow.add{ type = "button", caption = {"space-exploration.respawn-button-spaceship"}, name = "spaceship"}
  end
end

---@param playerdata PlayerData
---@param character LuaEntity
function Respawn.set_data(playerdata, character)

  if playerdata.personal_logistic_data then
    local new_logi_point = character.get_logistic_point(defines.logistic_member_index.character_requester)
    if new_logi_point then
      new_logi_point.enabled = false -- Always disable personal requests on respawn, to avoid bot swarm
      new_logi_point.trash_not_requested = playerdata.personal_logistic_data.trash_not_requested
      -- Ensure we are working from a clean slate. (New characters start with a default section)
      for i = 1, new_logi_point.sections_count do
        new_logi_point.remove_section(i)
      end
      for _, logi_section_data in pairs(playerdata.personal_logistic_data.sections) do
        local new_section
        if logi_section_data.group then
          new_section = new_logi_point.add_section(logi_section_data.group)
        else -- "[No group assigned]" section
          new_section = new_logi_point.add_section()
          new_section.filters = logi_section_data.filters
        end
        new_section.active = logi_section_data.active
        new_section.multiplier = logi_section_data.multiplier
      end
    end
  end

  if playerdata.inventory_type_filters then
    for inventory_type, inventory_filters in pairs(playerdata.inventory_type_filters) do
      local inventory = character.get_inventory(inventory_type)
      if inventory then
        for slot, string in pairs(inventory_filters) do
          if string and slot <= #inventory and prototypes.item[string] then
            inventory.set_filter(slot, string)
          end
        end
      end
    end
  end

end

---@param playerdata PlayerData
---@param character LuaEntity
function Respawn.record_data(playerdata, character)
  if not character or not character.valid then return end

  -- Record personal logistic requests
  local logi_point = character.get_logistic_point(defines.logistic_member_index.character_requester)
  if logi_point then
    playerdata.personal_logistic_data = {
      trash_not_requested = logi_point.trash_not_requested,
      sections = {}
    }
    for _, logi_section in pairs(logi_point.sections) do
      ---@type PlayerLogisticRequestsSection
      local saved_section = {
        active = logi_section.active,
        multiplier = logi_section.multiplier,
      }
      if logi_section.group and logi_section.group ~= "" then
        saved_section.group = logi_section.group
      else -- "[No group assigned]" section
        saved_section.filters = logi_section.filters
      end
      table.insert(playerdata.personal_logistic_data.sections, saved_section)
    end
  end

  -- Record inventory filters
  playerdata.inventory_type_filters = {}
  local inventories = {defines.inventory.character_main, defines.inventory.character_guns, defines.inventory.character_ammo}
  for _, inventory_type in pairs(inventories) do
    local inventory = character.get_inventory(inventory_type)
    if inventory then
      playerdata.inventory_type_filters[inventory_type] = playerdata.inventory_type_filters[inventory_type] or {}
      for i = 1, #inventory do
        playerdata.inventory_type_filters[inventory_type][i] = inventory.get_filter(i)
      end
    end
  end
end

---@param tick_task BindCorpseTickTask
function Respawn.tick_task_bind_corpse (tick_task)
  tick_task.valid = false
  local corpse = tick_task.corpse_surface.find_entity("character-corpse", tick_task.corpse_position)
  if corpse and corpse.valid then
    corpse.character_corpse_player_index = tick_task.player_index
  end
end

---@param player LuaPlayer
---@param character LuaEntity
function Respawn.mark_corpse (player, character)
  player.force.add_chart_tag(character.surface, {
    icon = {type = "virtual", name = mod_prefix .. "character-corpse"},
    position = character.position,
    text = player.name
  })
  local tick_task = new_tick_task("bind-corpse") --[[@as BindCorpseTickTask]]
  tick_task.corpse_position = character.position
  tick_task.corpse_surface = character.surface
  tick_task.player_index = player.index

end

---@param player LuaPlayer
---@param character? LuaEntity
---@param death_cause? LuaEntity
function Respawn.prepare_respawn(player, character, death_cause)
  if not (player and player.connected) then return end
  local playerdata = get_make_playerdata(player)

  RemoteView.stop(player)
  Spaceship.stop_anchor_scouting(player)

  if character then
    playerdata.death_surface = character.surface
    playerdata.death_position = character.position
    Respawn.mark_corpse(player, character)
    Respawn.record_data(playerdata, character)
  end

  playerdata.death_cause = death_cause -- Could be nil
  playerdata.character = nil

  close_own_guis(player)
  player.play_sound{path = "se-game-lost", volume = 1}

  player.print({"space-exploration.please-consider-patreon"})

  player.set_controller{type = defines.controllers.spectator}

  if playerdata.lock_respawn then
    if playerdata.lock_respawn.surface_name and game.get_surface(playerdata.lock_respawn.surface_name) then
      Respawn.at(player, game.get_surface(playerdata.lock_respawn.surface_name), playerdata.lock_respawn.position)
    end
    if playerdata.lock_respawn.zone_index then
      local zone = Zone.from_zone_index(playerdata.lock_respawn.zone_index)
      Respawn.at(player, Zone.get_make_surface(zone), playerdata.lock_respawn.position)
    end
    return
  end
  Respawn.open_gui(player)
end

---@param player LuaPlayer
function Respawn.die(player)

  RemoteView.stop(player)
  Spaceship.stop_anchor_scouting(player)

  if player.character then
    player.character.die(player.force, player.character) -- Will trigger on_pre_player_died
  else -- Somehow without a character even after remote view stop, try the character from playerdata.
    local playerdata = get_make_playerdata(player)
    if playerdata.character and playerdata.character.valid then
      playerdata.character.die(player.force, player.character) -- Will trigger on_entity_died
    else -- No character at all somehow... skip ahead to force respawn.
      Respawn.prepare_respawn(player, nil, nil)
    end
  end
end

---@param event EventData.on_pre_player_died Event data
function Respawn.on_pre_player_died(event)
  -- This does NOT trigger if the character died while the player is in remote view.
  -- That case is handled via on_entity_died.
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local character = nil
  if player then character = player.character end
  Respawn.prepare_respawn(player, character, event.cause)
end
Event.addListener(defines.events.on_pre_player_died, Respawn.on_pre_player_died)


---@param event EventData.on_entity_died Event data
function Respawn.on_entity_died(event)
  if not (event.entity and event.entity.valid) then return end
  if event.entity.type == "character" then
    local character = event.entity
    if not character.player then -- If this character has a player then we handled it already in on_pre_player_died
      for player_index, playerdata in pairs(storage.playerdata) do
        if playerdata.character == character then
          local player = game.get_player(player_index)
          if player then
            -- Because the character didn't have a player attached, Factorio won't show a message, so we show our own.
            local player_name = player.name or ("Player " .. player.index)
            local gps_tag = util.gps_tag(character.surface.name, character.position)
            if event.cause then
              local cause_name = (event.cause.type == "character" and event.cause.player) and event.cause.player.name or event.cause.localised_name
              game.print({"multiplayer.player-died-by", player_name, cause_name, gps_tag})
            else
              game.print({"multiplayer.player-died", player_name, gps_tag})
            end
            Respawn.prepare_respawn(player, character, event.cause)
          end
          return
        end
      end
    end
  end
end
Event.addListener(defines.events.on_entity_died, Respawn.on_entity_died)

---@param corpse LuaEntity
function Respawn.on_corpse_removed(corpse)

  for _, force in pairs(game.forces) do
    local tags = force.find_chart_tags(corpse.surface, Util.position_to_area( corpse.position, 1))
    for _, tag in pairs(tags) do
      if tag.icon and tag.icon.name == mod_prefix .. "character-corpse" then
        -- TODO: check that corpse matches the marker.
        -- will need to have the corpse know the player first.
        tag.destroy()
      end
    end
  end

end

---@param event EventData.on_character_corpse_expired Event data
function Respawn.on_character_corpse_expired(event)
  -- event.corpse LuaEntity
  -- Note: this is not called if the corpse is mined. See defines.events.on_pre_player_mined_item to detect that.
  -- remove corpse marker
  if not(event.corpse and event.corpse.valid) then return end
  Respawn.on_corpse_removed (event.corpse)

end
Event.addListener(defines.events.on_character_corpse_expired, Respawn.on_character_corpse_expired)

---@param event EventData.on_pre_player_mined_item Event data
function Respawn.on_pre_player_mined_item(event)
  -- event.entity
  -- event.player_index
  -- remove corpse marker
  if not(event.entity and event.entity.valid) then return end
  if event.entity.name == "character-corpse" then
      Respawn.on_corpse_removed (event.entity)
  end
end
Event.addListener(defines.events.on_pre_player_mined_item, Respawn.on_pre_player_mined_item)

---@param event EventData.on_lua_shortcut Event data
function Respawn.on_lua_shortcut(event)
  if event.prototype_name == Respawn.name_shortcut then
    --Respawn.die(game.get_player(event.player_index))
    Respawn.confirm.open_gui(game.get_player(event.player_index))
  end
end
Event.addListener(defines.events.on_lua_shortcut, Respawn.on_lua_shortcut)

---@param event EventData.CustomInputEvent Event data
function Respawn.on_respawn_keypress(event)
  if event.player_index
    and game.get_player(event.player_index)
    and game.get_player(event.player_index).connected
  then
      --Respawn.die(game.get_player(event.player_index))
      Respawn.confirm.open_gui(game.get_player(event.player_index))
  end
end
Event.addListener(Respawn.name_button_event, Respawn.on_respawn_keypress)

Respawn.confirm = {}
Respawn.confirm.name_gui = mod_prefix.."respawn-gui-confirm"
Respawn.confirm.buttons_container = 'confirm_button_container'
Respawn.confirm.button_yes = 'yes'
Respawn.confirm.button_no = 'no'

---@param player LuaPlayer
function Respawn.confirm.open_gui(player)
  local center = player.gui.center
  if (center[Respawn.confirm.name_gui]) then return end
  if (center[Respawn.name_gui]) then return end
    local popup = center.add {type = "frame", name = Respawn.confirm.name_gui, direction = "vertical", caption = {'space-exploration.respawn-confirm-title'}}

    local buttons_container = popup.add {type = "flow", name = Respawn.confirm.buttons_container, direction = "horizontal"}


  buttons_container.add {
    type = "button",
    name = Respawn.confirm.button_no,
    style="back_button",
    caption = {'space-exploration.respawn-confirm-no'}
  }

  local yes = buttons_container.add {
    type = "button",
    name = Respawn.confirm.button_yes,
    style="red_confirm_button",
    caption = {'space-exploration.respawn-confirm-yes'}
  }
  yes.style.left_margin = 10
end

---@param player LuaPlayer
function Respawn.confirm.close_gui(player)
  if player.gui.center[Respawn.confirm.name_gui] then
    player.gui.center[Respawn.confirm.name_gui].destroy()
  end
end

---@param event EventData.on_gui_click Event data
function Respawn.confirm.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, Respawn.confirm.name_gui)
  if not root then return end
  if element.name == Respawn.confirm.button_yes then
    Respawn.die(game.get_player(event.player_index))
  end
  Respawn.confirm.close_gui(game.get_player(event.player_index))
end
Event.addListener(defines.events.on_gui_click, Respawn.confirm.on_gui_click)


return Respawn
