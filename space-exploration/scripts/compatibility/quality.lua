local Quality = {}

-- we cannot assume the technologies exist or the unlock method is as expected
Quality.use_console_capture_research_trigger_for_epic = false
Quality.use_console_capture_research_trigger_for_legendary = false

Quality.all_module_names_map = {}
for _, item in pairs(prototypes.item) do
  if item.type == "module" then
    Quality.all_module_names_map[item.name] = true
  end
end

do
  local tech_e = prototypes.technology["epic-quality"]
  if tech_e and tech_e.research_trigger and tech_e.research_trigger.type == "capture-spawner" and tech_e.research_trigger.entity == mod_prefix .. "spaceship-console" then
    Quality.use_console_capture_research_trigger_for_epic = true
  end

  local tech_l = prototypes.technology["legendary-quality"]
  if tech_l and tech_l.research_trigger and tech_l.research_trigger.type == "capture-spawner" and tech_l.research_trigger.entity == mod_prefix .. "spaceship-console-alt" then
    Quality.use_console_capture_research_trigger_for_legendary = true
  end
end

Quality.research_trigger_tech = function(force, technology_name)
  local technology = force.technologies[technology_name]
  if technology.researched == false then
    technology.researched = true
    force.print({"technology-researched", string.format("[technology=%s]", technology.name)}, {
      sound_path = "utility/research_completed"
    })
  end
end

Quality.player_visited_zone = function(player, zone)
  if Quality.use_console_capture_research_trigger_for_epic and zone.ruins and zone.ruins["asteroid-belt-ship"] then
    Quality.research_trigger_tech(player.force, "epic-quality")
  end

  if Quality.use_console_capture_research_trigger_for_legendary and zone.type == "anomaly" then
    Quality.research_trigger_tech(player.force, "legendary-quality")
  end
end

-- whilst it would be prettiest if the technology triggers only when you stand near the console it would require extra checks,
-- since this is all just unofficial i am taking the shortcut of having visited the zone the console is supposed to generate in.
Quality.on_player_visited_zone = function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local zone = Zone.from_zone_index(event.zone_index)

  Quality.player_visited_zone(player, zone)
end

Quality.loses_quality_when_placed_name_map = {}
for _, entity in ipairs(prototypes.mod_data[mod_prefix .. "loses-quality-when-placed"].data.entities) do
  Quality.loses_quality_when_placed_name_map[entity.name] = true
end

Quality.on_entity_created = function(event)
  local entity = event.entity or event.destination
  if not entity.valid then return end

  if entity.quality.name == "normal" then return end

  local entity_name = entity.type == "entity-ghost" and entity.ghost_name or entity.name
  if not Quality.loses_quality_when_placed_name_map[entity_name] then return end

  local pretty_print = string.format("%s (%s)", entity.name, entity.type)

  local marked_for_upgrade = entity.order_upgrade{
    target = {name = entity_name, quality = "normal"},
    force = entity.force,
    player = event.player_index,
  }
  assert(marked_for_upgrade, pretty_print) -- find another way if the entity is not allowed to be marked for upgrade.

  if entity.valid and entity.type ~= "entity-ghost" then -- editor mode could have upgraded the old entity instantly.
    assert(entity.apply_upgrade(), pretty_print) -- upgrade and check if it succeeded, might fail if it got canceled?
  end
end

if script.feature_flags["quality"] then

  if Quality.use_console_capture_research_trigger_for_epic or Quality.use_console_capture_research_trigger_for_legendary then
    Event.addListener("on_player_visited_zone", Quality.on_player_visited_zone, true)
    Event.addListener("on_configuration_changed", function()
      for _, player in pairs(game.players) do
        local playerdata = get_make_playerdata(player)
        for zone_index, _ in pairs(playerdata.visited_zone or {}) do
          local zone = Zone.from_zone_index(zone_index)
          Quality.player_visited_zone(player, zone)
        end
      end
    end, true)
  end

  Event.addOnEntityCreatedListeners(Quality.on_entity_created)
end

return Quality


