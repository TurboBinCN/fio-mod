local Informatron = {} -- informatron pages implementation.

---Returns the menu items that should be shown in Informatron for a given player.
---@param player_index uint Player index
function Informatron.menu(player_index)
  local player = game.get_player(player_index)
  ---@cast player -?
  local playerdata = get_make_playerdata(player)
  local force = player.force
  local menu = {
    meteor_defence = 1,
    coremining = 1,
    beacons = 1,
    launching_satellites = 1,
    pinned_locations = 1,
    zone_discovery = 1,
    space_capsule = 1,
    cargo_rockets = 1,
    delivery_cannons = 1,
    steam_power = 1,
    lifesupport = 1,
    space_sciences = 1,
    space_elevators = 1,
    energy_beams = 1,
    spaceships = {
      spaceship_construction = 1,
      spaceship_automation_scheduler = 1,
      spaceship_automation_circuits = 1,
    },
    arcospheres = 1,
    exploration_journal = 1,
  }
  if playerdata.track_glyphs then
    menu["archeology"] = 1 -- shhh
  end
  if force.technologies[Ancient.name_tech_coordinates].enabled then
    menu["starmapping"] = 1 -- shhh
  end
  if storage.forces[force.name] and storage.forces[force.name].coordinate_logs then
    menu["coordinate_logs"] = 1 -- shhh
  end
  return menu
end

---@param warnings LuaGuiElement
---@param force ForceID
function Informatron.set_warnings(warnings, force)
  warnings.clear()
  for force_name, forcedata in pairs(storage.forces) do
    if forcedata.solar_flare then
      if Zone.is_visible_to_force(forcedata.solar_flare.zone, force.name) then
        local warning = warnings.add{type="label", name="warning_"..force_name, caption={
            "space-exploration.page_energy_beam_warning_text",
            Zone.get_print_name(forcedata.solar_flare.zone),
            Util.seconds_to_clock((forcedata.solar_flare.tick - game.tick)/60, true),
            string.format("%.2f", SolarFlare.base_power / 1000000000 * SolarFlare.default_flare_power(forcedata.solar_flare.zone) ),
            math.floor(160 * SolarFlare.default_flare_power(forcedata.solar_flare.zone))
          }
        }
        warning.style.bottom_margin = 20
        warning.style.single_line = false
      end
    end
  end
end

---@param page_name string
---@param player_index uint
---@param element LuaGuiElement
function Informatron.page_content_update(page_name, player_index, element)
  if page_name == "energy_beams" then
    local player = game.get_player(player_index)
    ---@cast player -?
    local force = player.force
    local force_data = storage.forces[force.name]
    if element.warnings then
      Informatron.set_warnings(element.warnings, force)
    end
  end
end

---@param page_name string
---@param player_index uint
---@param element LuaGuiElement
function Informatron.page_content(page_name, player_index, element)
  local player = game.get_player(player_index)
  ---@cast player -?
  local player_data = get_make_playerdata(player)

  local force = player.force --[[@as LuaForce]]
  if not is_player_force(force.name) then return end
  local force_data = storage.forces[force.name]
  if page_name == "space-exploration" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_space_exploration_text_1"}}

  elseif page_name == "meteor_defence" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_meteor_defence_text_1"}}

  elseif page_name == "coremining" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_coremining_text_1"}}

  elseif page_name == "beacons" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_beacons_text_1"}}

  elseif page_name == "launching_satellites" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_launching_satellites_text_1", force_data.satellites_launched or 0}}

  elseif page_name == "pinned_locations" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_pinned_locations_text_1"}}

  elseif page_name == "zone_discovery" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_zone_discovery_text_1"}}

    local any_button_table = element.add{type="table", name="any_button_table", column_count=5, draw_horizontal_lines=false}
    any_button_table.style.horizontally_stretchable = true
    any_button_table.style.column_alignments[1] = "middle-center"
    any_button_table.style.column_alignments[2] = "middle-center"
    any_button_table.style.column_alignments[3] = "middle-center"
    any_button_table.style.top_margin = 30
    any_button_table.add{type = "flow", name="cell_left"}
    local any_button = any_button_table.add{type="button", name="any_resource",
      caption={"space-exploration.discovery_look_for_no_preference"},
      style=force_data.search_for_resource == nil and "se_button_discovery_any_active" or "se_button_discovery_any"
    }
    any_button_table.add{type = "flow", name="cell_right"}

    local r_table = element.add{type="table", name="discover_resource_table", column_count=5, draw_horizontal_lines=false}
    r_table.style.horizontally_stretchable = true
    r_table.style.column_alignments[1] = "middle-center"
    r_table.style.column_alignments[2] = "middle-center"
    r_table.style.column_alignments[3] = "middle-center"
    r_table.style.column_alignments[4] = "middle-center"
    r_table.style.column_alignments[5] = "middle-center"
    r_table.style.horizontal_spacing  = 10
    r_table.style.vertical_spacing = 30
    r_table.style.top_margin = 30

    local resources_settings = storage.resources_and_controls.resource_settings
    for _, resource in pairs(resources_settings) do
      if resource.name ~= mod_prefix.."naquium-ore" then
        local button = r_table.add{type="button", name=resource.name,
          style=force_data.search_for_resource == resource.name and "se_button_discovery_active" or "se_button_discovery"
        }

        local l = button.add{type = "label", name = "l",
          caption={"space-exploration.discovery_look_for_resource_caption", "[img=entity/"..resource.name.."]", {"entity-name."..resource.name} },
          tooltip={"space-exploration.discovery_look_for_resource_tooltip", {"entity-name."..resource.name}}
        }
        --button.style.horizontally_stretchable = true
        --button.style.width = 165
        --button.style.height = 90
        --button.style.top_padding = 20
        --button.style.bottom_padding = 20
        --button.style.horizontal_align = "center"
        --button.style.vertical_align = "center"
        --l.style.horizontally_stretchable = true
        --l.style.vertically_stretchable = true
        l.ignored_by_interaction = true
        l.style.single_line = false
        l.style.width = 155
        l.style.horizontal_align = "center"
        l.style.vertical_align = "center"
        l.style.font="heading-2"
      end
    end

  elseif page_name == "space_capsule" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_space_capsule_text_1"}}

  elseif page_name == "cargo_rockets" then
    element.add{type="label", name="text_1", caption={
      "space-exploration.page_cargo_rockets_text_1",
      force_data.cargo_rockets_launched or 0,
      string.format("%.2f",100-100*Launchpad.get_force_cargo_loss_modifier(force)),
      string.format("%.2f",100-100*Launchpad.get_force_survivability_loss_modifier(force)),
      100 * Launchpad.get_reusability(force),
    }}

  elseif page_name == "delivery_cannons" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_delivery_cannons_text_1", {"space-exploration.delivery_cannon_label_automatic_retarget"}, {"space-exploration.delivery_cannon_label_artillery"}}}

  elseif page_name == "steam_power" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_steam_power_text_1"}}

  elseif page_name == "lifesupport" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_lifesupport_text_1"}}

  elseif page_name == "space_sciences" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_space_sciences_text_1"}}

  elseif page_name == "space_elevators" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_space_elevators_text_1"}}

  elseif page_name == "energy_beams" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_energy_beams_text_1"}}
    element.text_1.style.bottom_margin = 20

    element.add{type = "flow", name="warnings", direction = "vertical"}
    Informatron.set_warnings(element.warnings, force)
    element.add{type="label", name="text_2", caption={"space-exploration.page_energy_beams_text_2"}}

  elseif page_name == "spaceships" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_spaceships_text_1"}}

    local spaceship_count = 0
    local spaceship_max_speed = 0
    for _, spaceship in pairs(storage.spaceships) do
      if spaceship.force_name == force.name then
        spaceship_count = spaceship_count + 1
        if spaceship.max_speed and spaceship.max_speed > spaceship_max_speed then
          spaceship_max_speed = spaceship.max_speed
        end
      end
    end
    element.add{type="label", name="text_2", caption={"space-exploration.page_spaceships_text_2",
                                                      SpaceshipIntegrity.get_integrity_limit(player.force.name),
                                                      spaceship_count,
                                                      string.format("%.2f", spaceship_max_speed)}}

    element.add{type="line", direction="horizontal"}.style.padding = {4, 0, 4, 0}
    element.add{type="label", name="text_3", caption={"space-exploration.page_spaceships_automation_text_1"}}

  elseif page_name == "spaceship_construction" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_spaceships_construction_text_1"}}

  elseif page_name == "spaceship_automation_scheduler" then
    element.add{type="label", name="text_2", caption={"space-exploration.page_spaceships_automation_scheduler_text_1"}}

  elseif page_name == "spaceship_automation_circuits" then
    element.add{type="label", name="text_3", caption={"space-exploration.page_spaceships_automation_circuits_text_1"}}

  elseif page_name == "arcospheres" then
    element.add{type="label", name="text_1", caption={"space-exploration.page_arcospheres_text_1"}}
    element.add{type="label", name="text_arco_deep", caption={"space-exploration.page_arcospheres_text_deep", force_data.arcospheres_collected or 0, force_data.arcosphere_collectors_launched or 0}}
    if force_data.zone_arcospheres then
      local arco_zones_indexes = {} -- Will be an alphabetically sorted table
      for zone_index, _ in pairs(force_data.zone_arcospheres) do
        table.insert(arco_zones_indexes, zone_index)
      end
      table.sort(arco_zones_indexes, function(a,b) return Zone.from_zone_index(a).name < Zone.from_zone_index(b).name end )

      for _, zone_index in pairs(arco_zones_indexes) do
        local zone = Zone.from_zone_index(zone_index) --[[@as AsteroidFieldType]]
        local zone_stats = force_data.zone_arcospheres[zone_index]
        element.add{type="label", name="text_arco_zone_"..zone_index, caption={"space-exploration.page_arcospheres_text_zone", zone.name, zone_stats.arcospheres_collected or 0, zone_stats.arcosphere_collectors_launched or 0}}
      end
    end
  elseif page_name == "exploration_journal" then
    local text
    element.add{type="label", name="page_journal_title_backstory", caption={"space-exploration.page_journal_title_backstory"}, style="heading_2_label"}
    text = element.add{type="label", name="page_journal_text_backstory", caption={"space-exploration.page_journal_text_backstory"}}
    text.style.bottom_margin = 20

    if force_data.satellites_launched and force_data.satellites_launched > 0 then
      element.add{type="label", name="page_journal_title_satellite_launch", caption={"space-exploration.page_journal_title_satellite_launch"}, style="heading_2_label"}
      text = element.add{type="label", name="page_journal_text_satellite_launch", caption={"space-exploration.page_journal_text_satellite_launch"}}
      text.style.bottom_margin = 20
    end

    if force_data.weapons_cache then
      text = element.add{
        type="label", name="page_journal_text_weapons-cache-found", caption={"space-exploration.page_journal_text_weapons_cache",
          "[gps="..math.floor(force_data.weapons_cache.position.x)..","..math.floor(force_data.weapons_cache.position.y)..","..force_data.weapons_cache.surface.name.."]"},
        tags = {
          gps_surface_index = force_data.weapons_cache.surface.index,
          gps_position = force_data.weapons_cache.position
        }
      }
      text.style.bottom_margin = 20
    end

    if force_data.cargo_rockets_launched and force_data.cargo_rockets_launched > 0 then
      element.add{type="label", name="page_journal_title_cargo_launch", caption={"space-exploration.page_journal_title_cargo_launch"}, style="heading_2_label"}
      text = element.add{type="label", name="page_journal_text_cargo_launch", caption={"space-exploration.page_journal_text_cargo_launch"}}
      text.style.bottom_margin = 20
    end

    if player_data.first_entered_vault then
      element.add{type="label", name="page_journal_title_entered_vault", caption={"space-exploration.page_journal_title_entered_vault"}, style="heading_2_label"}
      text = element.add{type="label", name="page_journal_text_entered_vault", caption={"space-exploration.page_journal_text_entered_vault", player_data.first_entered_vault.name}}
      text.style.bottom_margin = 20

      if not player_data.track_glyphs then
        local button = element.add{type = "button", name=Ancient.name_button_player_track_glyphs, caption={"space-exploration.player_track_glyphs"}}
        button.style.bottom_margin = 20
      end
    end

    local anomaly = Zone.from_name("Foenestra") --[[@as AnomalyType]]
    if force_data.zones_discovered[anomaly.index] then
      element.add{type="label", name="page_journal_title_found_gate", caption={"space-exploration.page_journal_title_found_gate"}, style="heading_2_label"}
      text = element.add{type="label", name="page_journal_text_found_gate", caption={"space-exploration.page_journal_text_found_gate"}}
      text.style.bottom_margin = 20
    end
    if storage.gate then
      Ancient.cryptf6()

      if player_data.has_entered_anomaly then
        element.add{type="label", name="page_journal_title_found_gate_ship", caption={"space-exploration.page_journal_title_found_gate_ship"}, style="heading_2_label"}
        text = element.add{type="label", name="page_journal_text_found_gate_ship", caption={"space-exploration.page_journal_text_found_gate_ship"}}
        text.style.bottom_margin = 20

        element.add{type="label", name="page_journal_title_found_gate_ship_authenticated", caption={"space-exploration.page_journal_title_found_gate_ship_authenticated"}, style="heading_2_label"}
        text = element.add{type="label", name="page_journal_text_found_gate_ship_authenticated", caption={"space-exploration.page_journal_text_found_gate_ship_authenticated"}}
        text.style.bottom_margin = 20

        --local player_name = player.name or "Engineer"
        --local id = 2236067977 - player.index * 13
        --local sub_id = 5 + player.index
        local player_name = game.get_player(1).name or "Engineer"
        local id = 2236067964
        local sub_id = 5 + 1
        local fcoord = Ancient.cryptf7(storage.hcoord)

        element.add{type="label", name="page_journal_title_found_gate_ship_log", caption={"space-exploration.page_journal_title_found_gate_ship_log"}, style="heading_2_label"}
        local text_found_gate_ship_log_intro = element.add{type="label", name="page_journal_text_found_gate_ship_log_intro", caption={"space-exploration.page_journal_text_found_gate_ship_log_intro"}}
        local log_frame = element.add{type="frame", name="log_frame", style="a_inner_frame"}
        log_frame.style.vertically_stretchable = true
        local text_found_gate_ship_log = log_frame.add{
          type="label",
          name="page_journal_text_found_gate_ship_log",
          caption={"space-exploration.page_journal_text_found_gate_ship_log",
            id .. "."..sub_id.." (".. player_name.."_"..sub_id..")",
            Ancient.coordinate_to_string(fcoord)
          }
        }
        text_found_gate_ship_log.style.single_line = false
        text_found_gate_ship_log.style.font_color = {r=0.6,g=0.7,b=0.8}
        log_frame.style.bottom_margin = 20
      end
    end

    if    script.active_mods["Krastorio2"]
      and force.technologies["se-spaceship-victory"].enabled
    then
      element.add{type="label", name="page_journal_title_distress_message", caption={"space-exploration.page_journal_title_distress_message"}, style="heading_2_label"}
      text = element.add{type="label", name="page_journal_text_distress_message", caption={"space-exploration.page_journal_text_distress_message"}}
      text.style.bottom_margin = 20
    end

    if player_data.gate_victory then
      element.add{type="label", name="page_journal_title_gate_victory", caption={"space-exploration.page_journal_title_gate_victory"}, style="heading_2_label"}
      text = element.add{type="label", name="page_journal_gate_victory", caption={"space-exploration.page_journal_gate_victory"}}
      text.style.bottom_margin = 20
    end

    if player_data.spaceship_victory then
      element.add{type="label", name="page_journal_title_spaceship_victory", caption={"space-exploration.page_journal_title_spaceship_victory"}, style="heading_2_label"}
      text = element.add{type="label", name="page_journal_spaceship_victory", caption={"space-exploration.page_journal_spaceship_victory"}}
      text.style.bottom_margin = 20
    end

  elseif page_name == "archeology" then

    local count = 0
    local text_1 = element.add{type="label", name="text_1", caption={"space-exploration.page_archeology_text_1", count}}
    text_1.style.bottom_margin = 20
    for _, zone in pairs(storage.zone_index) do
      if zone.glyph and (force_data.zones_discovered[zone.index] or storage.debug_view_all_zones) then
        count = count + 1
        local item = element.add{type="label", name="link_vault_"..zone.index, caption={"space-exploration.page_archeology_pyramid_link", "[img="..Zone.get_icon(zone).."]", zone.name} }
        item.style.bottom_margin = 20
      end
    end
    text_1.caption={"space-exploration.page_archeology_text_1", count}
    local text_2 = element.add{type="label", name="text_2", caption={"space-exploration.page_archeology_text_2", count}}
    text_2.style.bottom_margin = 20
    text_2.style.top_margin = 20


  elseif page_name == "starmapping" then
    local text_1 = element.add{type="label", name="text_1", caption={"space-exploration.page_starmapping_text_1", 0}, }
    if force_data.coordinates_discovered then
      local count = 0
      for i, glyph_id in pairs(force_data.coordinates_discovered) do
        count = count + 1
        local coordinate = Ancient.cryptf4b({glyph_id})
        local label = element.add{type="label", name="glyph_"..glyph_id,
          caption={"space-exploration.starmapping-found-constellation-informatron", "[img=entity/"..mod_prefix .. "glyph-a-energy-"..glyph_id.."]", Ancient.coordinate_to_string(coordinate)}
        }
        label.style.height = 32
      end
      text_1.caption = {"space-exploration.page_starmapping_text_1", count}
      text_1.style.bottom_margin = 20
      text_1.style.vertical_align = "center"
    end

  elseif page_name == "coordinate_logs" then
    local log_description = element.add{type="label", name="text_1", caption={"space-exploration.page_coordinate_logs_text_1"}}
    log_description.style.bottom_margin = 16
    local log_list

    if force_data.coordinate_logs then
      if not next(force_data.coordinate_logs) then
        local log_empty = element.add{type="label", name="log_empty", caption={"space-exploration.page_coordinate_logs_text_empty"}}
        log_empty.style.font_color = {r=1,g=1}
      else
        log_list = element.add{type = "flow", name="log_list", direction = "vertical"}
        log_list.style.bottom_margin = 30
        local log_entry
        local glyph_entry
        local coordinate_entry
        for i = #force_data.coordinate_logs, 1, -1 do
          log_entry = log_list.add{type = "flow", name="log_entry"..i, direction = "horizontal"}
          glyph_entry = log_entry.add{type="label", name="glyph_entry_"..i, caption={"space-exploration.page_coordinate_logs_glyph_entry", force_data.coordinate_logs[i].glyph_string}}
          coordinate_entry = log_entry.add{type="text-box", name="coordinate_entry_"..i, text=force_data.coordinate_logs[i].coordinate_string}
          log_entry.style.height = 32
          glyph_entry.style.top_margin = 5
          coordinate_entry.read_only = true
          coordinate_entry.style.horizontally_stretchable = true
          coordinate_entry.style.minimal_width = 450
        end
        local clear_button = element.add{type="button", name="log_clear", style="red_button", mouse_button_filter={"left"}, caption={"space-exploration.page_coordinate_logs_button_clear_caption"}}
      end
    end
  end

end


---@param event EventData.on_gui_click Event data
function Informatron.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?

  if element.tags and element.tags.se_action == "goto-informatron" then
    remote.call("informatron", "informatron_open_to_page", {
      player_index = event.player_index,
      interface = "space-exploration",
      page_name = element.tags.informatron_page,
    })
    return
  end

  local root = gui_element_or_parent(element, "informatron") or gui_element_or_parent(element, "informatron_main")
  if root then -- informatron
    if element.name == Ancient.name_button_player_track_glyphs then
      local player_data = get_make_playerdata(player)
      player_data.track_glyphs = true
      remote.call("informatron", "informatron_open_to_page", {player_index = player.index, interface="space-exploration", page_name="archeology"})
    elseif element.tags and element.tags.gps_surface_index then
      local zone = Zone.from_surface_index(element.tags.gps_surface_index)
      local tag = element.tags
      if zone then
        RemoteView.start(player, zone)
        -- Executing player.set_controller in RemoteView.start makes LuaGuiElement element invalid.
        player.teleport(tag.gps_position)
        player.gui.center.clear()
      end
    elseif string.find(element.name, "link_vault_", 1, true) then
      local zone_index = util.string_to_number(util.replace(element.name, "link_vault_", "")) --[[@as uint]]
      local zone = Zone.from_zone_index(zone_index)
      if zone and zone.glyph then
        local surface = Zone.get_make_surface(zone)
        RemoteView.start(player, zone)
        if zone.vault_pyramid and zone.vault_pyramid.valid then
          player.teleport(zone.vault_pyramid.position)
          player.gui.center.clear()
        end
      end
    elseif element.parent.name == "discover_resource_table" then
      local force_data = storage.forces[player.force.name]
      force_data.search_for_resource = element.name
      for _, child in pairs(util.find_first_descendant_by_name(root, "discover_resource_table").children) do
        child.style = "se_button_discovery"
      end
      element.style = "se_button_discovery_active"
      local any_button = util.find_first_descendant_by_name(root, "any_resource")
      any_button.style = "se_button_discovery_any"
    elseif element.name == "any_resource" then
      local force_data = storage.forces[player.force.name]
      force_data.search_for_resource = nil
      element.style = "se_button_discovery_any_active"
      for _, child in pairs(util.find_first_descendant_by_name(root, "discover_resource_table").children) do
        child.style = "se_button_discovery"
      end
    elseif element.name == "log_clear" then
      local force_data = storage.forces[player.force.name]
      force_data.coordinate_logs = {}
      local log_list = util.find_first_descendant_by_name(root, "log_list")
      if log_list then log_list.destroy() end
    end
    return
  end
end
Event.addListener(defines.events.on_gui_click, Informatron.on_gui_click)


return Informatron
