local Migrate = {}

-------------------------------------------------------
-- MOD SPECIFIC PARAMETERS
-- If you're copying this file to another mod,
-- make sure to modify the constants and methods below.
-------------------------------------------------------

local function added_to_existing_game()
  local tick_task = new_tick_task("game-message") --[[@as GameMessageTickTask]]
  tick_task.message = {"space-exploration.warn_added_to_existing_game"}
  tick_task.delay_until = game.tick + 180 --3s
end

-- ignore_techs don't cause their children to get locked.
-- Mainly used for newly added techs.
local ignore_techs = {
  mod_prefix.."rocket-science-pack",
  mod_prefix.."space-belt",
  mod_prefix.."space-pipe",
  mod_prefix.."pyroflux-smelting",
  mod_prefix.."condenser-turbine",
  "utility-science-pack",
  "production-science-pack",
  "space-science-pack",
  mod_prefix.."space-biochemical-laboratory",
}
Migrate.ignore_techs = {}
for _, tech in pairs(ignore_techs) do
  Migrate.ignore_techs[tech] = tech
end

-- chainbreak_techs are not locked by their prerequisites and don't propagate a tech locking chain
-- mainly used if a section of the tech tree has moved
local chainbreak_techs = {
  "utility-science-pack",
  "production-science-pack",
  mod_prefix.."space-solar-panel",
  mod_prefix.."space-data-card",
  mod_prefix.."space-radiator-1",
}
Migrate.chainbreak_techs = {}
for _, tech in pairs(chainbreak_techs) do
  Migrate.chainbreak_techs[tech] = tech
end

-- dont_lock_techs can't be locked by their prerequisites being locked.
local dont_lock_techs = {
  mod_prefix.."naquium-cube",
  mod_prefix.."naquium-tessaract",
  mod_prefix.."naquium-processor",
  mod_prefix.."space-accumulator-2",
  mod_prefix.."wide-beacon-2",
  mod_prefix.."antimatter-production",
  mod_prefix.."antimatter-reactor",
  mod_prefix.."space-solar-panel-3",
  mod_prefix.. "space-probe",
  mod_prefix.. "dimensional-anchor",
  mod_prefix.. "long-range-star-mapping",
  mod_prefix.. "factory-spaceship-1",
  mod_prefix.. "factory-spaceship-2",
  mod_prefix.. "factory-spaceship-3",
  mod_prefix.. "factory-spaceship-4",
  mod_prefix.. "factory-spaceship-5",
  mod_prefix.. "lifesupport-equipment-4",
  mod_prefix.. "bioscrubber",
  "energy-shield-mk6-equipment",
  mod_prefix.. "spaceship-victory",
  mod_prefix.. "antimatter-engine",
  mod_prefix.. "fluid-burner-generator",
}
Migrate.dont_lock_techs = {}
for _, tech in pairs(dont_lock_techs) do
  Migrate.dont_lock_techs[tech] = tech
end

function Migrate.always_do_migrations()
  if not storage.universe_scale then
    storage.universe_scale =  (#storage.universe.stars + #storage.universe.space_zones) ^ 0.5 * Universe.stellar_average_separation
    Universe.separate_stellar_position()
    for _, zone in pairs(storage.zone_index) do
      if zone.type == "planet" then
        Universe.planet_gravity_well_distribute(zone)
      end
    end
  end

  -- general cleaning
  for _, zone in pairs(storage.zone_index) do
    if zone.is_homeworld or zone.name == "Nauvis" then
      zone.tags = nil
    end
    if zone.tags then
      if zone.tags.moisture and zone.tags.moisture == "moisture_very_low" then
        -- was incorrect in universe.raw, if surface is genrated it is incorrect but don't change the terrain if already settled
        zone.tags.moisture = "moisture_low"
        Zone.delete_surface(zone) -- remove if unsettled
        log("Changed moisture tag from moisture_very_low to moisture_low.")
      end
    end
    Zone.set_solar_and_daytime(zone)
  end

  for _, player in pairs(game.players) do
    if player.character and player.permission_group and player.permission_group.name == RemoteView.name_permission_group then
      player.permission_group = nil
    end
  end

  for _, name in pairs({"se-remote-view", "se-remote-view_satellite"}) do
    local group = game.permissions.get_group(name)
    if group then group.destroy() end
  end

  for registration_number, resource_set in pairs(storage.core_seams_by_registration_number) do
    if not resource_set.resource.valid then
      CoreMiner.remove_seam(resource_set)
    end
  end

  Migrate.fill_tech_gaps(true)

  Ancient.update_unlocks()

  -- reset the localised names for surfaces in case other mods touched them (they will)
  Zone.reset_localised_names_of_zone_surfaces()
  MapView.reset_localised_starmap_surface_names()
end

---@param allow_whitelists boolean
function Migrate.fill_tech_gaps(allow_whitelists)
  local tech_children = {}
  for _, technology in pairs(prototypes.technology) do
    for _, prerequisite in pairs(technology.prerequisites) do
      tech_children[prerequisite.name] = tech_children[prerequisite.name] or {}
      table.insert(tech_children[prerequisite.name], technology.name)
    end
  end

  --first pass
  for _, force in pairs(game.forces) do
    if force.name ~= "enemy"
      and force.name ~= "neutral"
      and force.name ~= "capture"
      and force.name ~= "ignore"
      and force.name ~= "friendly"
      and force.name ~= "conquest" then

        if force.technologies[mod_prefix.."deep-space-science-pack-1"].researched then
          force.technologies[mod_prefix.."deep-catalogue-1"].researched = true
        end

        if force.technologies[mod_prefix.."space-assembling"].researched then
          force.technologies[mod_prefix.."space-belt"].researched = true
          force.technologies[mod_prefix.."space-pipe"].researched = true
        end

        if force.technologies[mod_prefix.."space-supercomputer-1"].researched then
          force.technologies[mod_prefix.."space-data-card"].researched = true
        end

        if force.technologies["uranium-processing"].researched then
          force.technologies[mod_prefix.."centrifuge"].researched = true
        end

        if force.technologies["nuclear-power"].researched then
          force.technologies["steam-turbine"].researched = true
        end

        local techs_done = {}
        local rocket_science = force.technologies[mod_prefix.."rocket-science-pack"]
        Migrate.fill_tech_gaps_rec(tech_children, techs_done, rocket_science, false, allow_whitelists)
    end
  end
end

---@param tech_children {[string]:string[]}
---@param techs_done Flags
---@param tech LuaTechnology
---@param lock boolean
---@param allow_whitelists boolean
function Migrate.fill_tech_gaps_rec(tech_children, techs_done, tech, lock, allow_whitelists)
  local change = false
  if allow_whitelists and Migrate.chainbreak_techs[tech.name] then
    -- break the lock chain
    lock = false
  end
  if not(tech.researched or tech.level > 1) then
    if (not allow_whitelists) or (not Migrate.dont_lock_techs[tech.name]) and (not Migrate.ignore_techs[tech.name]) then
      lock = true
    end
  end
  if lock then
    if tech.researched then
      change = true
    end
    if not (allow_whitelists and Migrate.dont_lock_techs[tech.name]) then
      if tech.researched then
        tech.researched = false
        Log.debug({"", "Unresearch ", "technology-name."..tech.name})
      end
    end
  end
  if tech_children[tech.name] and (change or not techs_done[tech.name]) then
    for _, child_name in pairs(tech_children[tech.name]) do
      Migrate.fill_tech_gaps_rec(tech_children, techs_done, tech.force.technologies[child_name], lock, allow_whitelists)
    end
  end
  techs_done[tech.name] = true
end

-- Find dummy recipes, reset the recipes, spill removed items
local function replace_dummy_recipes(entity_names)
  for _, surface in pairs(game.surfaces) do
    local machines = surface.find_entities_filtered({name=entity_names})
    for _, machine in pairs(machines) do
      local recipe = machine.get_recipe()
      if recipe and string.starts(recipe.name, Shared.dummy_migration_recipe_prefix) then
        local original_recipe_name = recipe.name:sub(string.len(Shared.dummy_migration_recipe_prefix)+1)
        local removed_items = machine.set_recipe(original_recipe_name)
        for item_name, count in pairs(removed_items) do
          surface.spill_item_stack{
            position = machine.position,
            stack = {name=item_name, count=count},
            enable_looted = true,
            force = machine.force,
            allow_belts = false
          }
        end
      end
    end
  end
end

---------------------------------------------------------------
-- Mod-specific parameters end here, migration code starts here
---------------------------------------------------------------


--Converts the default version string to one that can be lexographically compared using string comparisons
---@param ver string String in a version format of 'xxx.xxx.xxx' where each xxx is in the range 0-65535
---@return string version Version number with leading padded 0's for use in string comparisons
function Migrate.version_to_comparable_string(ver)
  return string.format("%05d.%05d.%05d", string.match(ver, "^(%d+)%.(%d+)%.(%d+)$"))
end

--Converts the lexographically coaprable version string to default, human readable format
---@param ver string String in a version format of 'xxxxx.xxxxx.xxxxx' where each xxxxx is a number with potential leading 0's
---@return string version Version number with leading 0's stripped
function Migrate.comparable_string_to_version(ver)
  return (string.gsub(ver, "^0*(%d-%d).0*(%d-%d).0*(%d-%d)$", "%1.%2.%3"))
end

---@param event ConfigurationChangedData
function Migrate.do_migrations(event)
  local mod_name = script.mod_name

  --check if we changed versions
  local mod_changes = event.mod_changes[mod_name]
  if mod_changes and mod_changes.old_version ~= mod_changes.new_version then
    if mod_changes.old_version == nil then
      added_to_existing_game()
      return
    end
    local old_ver_string = Migrate.version_to_comparable_string(mod_changes.old_version)
    local versions_to_migrate = {} --array of lexographically comparible migration version strings that need running
    local migrations = {} --migration version to migration function map
    --look for needed migrations
    for migrate_version, migration in pairs(Migrate.migrations) do
      local migrate_ver_string = Migrate.version_to_comparable_string(migrate_version)
      if migrate_ver_string > old_ver_string then
        table.insert(versions_to_migrate, migrate_ver_string)
        migrations[migrate_ver_string] = migration
      end
    end

    if next(versions_to_migrate) then
      log(mod_name.. ": Starting migrations from "..mod_changes.old_version.." to "..mod_changes.new_version.." " .. (script.level.is_simulation and "(simulation)" or ""))

      --ensure migrations run in the correct order
      table.sort(versions_to_migrate)

      --do migrations
      for _, version_to_migrate in pairs(versions_to_migrate) do
        log(mod_name..": Running migration "..Migrate.comparable_string_to_version(version_to_migrate))
        migrations[version_to_migrate](event)
      end
    end

    --do any test migrations
    for migration_name, migration in pairs(Migrate.test_migrations) do
      if not is_debug_mode then
        --there should never be any test migrations if not in debug mode
        local msg = "[color=red]WARNING:[/color] Test migration scripts exist while not in debug mode. These should be moved to live migrations with version labels prior to live release."
        log(msg)
        game.print(msg)
      end
      local msg = mod_name..": Running test migration: "..migration_name
      log(msg)
      game.print(msg)
      migration(event)
    end
  end
end

Migrate.migrations = {
  -- 0.6.146 is the last 0.6.x and Factorio 1.1 version released. It contains code that is required to migrate some entities into Factorio 2.0 / SE 0.7.
  -- Anyone migrating from 0.6 to 0.7 MUST first migrate to 0.6.146 in Factorio 1.1 before migrating to Factorio 2.0.
  -- The current version has removed all migrations prior to 0.7.0 and will warn anyone migrating from prior versions that they must do this double migration.
  ["0.6.146"] = function()
    local msg = "WARNING: Space Exploration does not support loading pre 0.7.0 saves directly into Factorio 2.0. Please load and resave this game using Space Exploration 0.6.146 and Factorio 1.1 before loading into Factorio 2.0"
    log(msg)
    error(msg)
  end,

  ["0.7.0"] = function()

    --["update-directions-define"] = function()
      -- In Factorio 2.0 the defines.direction changed from 8 to 16.
      local updated_direction = {
        [0] = defines.direction.north,
        [2] = defines.direction.east,
        [4] = defines.direction.south,
        [6] = defines.direction.west,
      }

      ---@param direction defines.direction
      ---@return defines.direction new_direction
      local function get_new_direction(direction)
        local new_direction = updated_direction[direction]
        assert(new_direction, "Unsupported old direction: "..direction)
        return new_direction
      end

      -- ELEVATORS ------------------------------------
      for _, elevator in pairs(storage.space_elevators) do
        elevator.direction = get_new_direction(elevator.direction)
      end

      -- CLAMPS ------------------------------------
      local fix_clamp_directions = false
      for _, clamp_info in pairs(storage.spaceship_clamps) do
        if clamp_info.direction ~= defines.direction.east and clamp_info.direction ~= defines.direction.west then
          -- We found a clamp with an old direction
          -- Therefore the 0.6.139 migration was already run, and we need to fix the directions
          fix_clamp_directions = true
          break
        end
      end
      if fix_clamp_directions then
        for _, clamp_info in pairs(storage.spaceship_clamps) do
          clamp_info.direction = get_new_direction(clamp_info.direction)
        end
      end

      -- SPACESHIP SCHEDULER ---------------------------------
      ---@param record SpaceshipSchedulerRecord
      local function update_scheduler_record(record)
        if record.spaceship_clamp and record.spaceship_clamp.direction then
          record.spaceship_clamp.direction = get_new_direction(record.spaceship_clamp.direction)
        end
        if record.destination_descriptor and record.destination_descriptor.clamp and record.destination_descriptor.clamp.direction then
          record.destination_descriptor.clamp.direction = get_new_direction(record.destination_descriptor.clamp.direction)
        end
      end

      for _, force_groups in pairs(storage.spaceship_scheduler_groups) do
        for _, group in pairs(force_groups) do
          for _, record in pairs(group.schedule) do
            update_scheduler_record(record)
          end
        end
      end
      for _, force_interrupts in pairs(storage.spaceship_scheduler_interrupts) do
        for _, interrupt in pairs(force_interrupts) do
          for _, target in pairs(interrupt.targets) do
            update_scheduler_record(target)
          end
        end
      end
      for _, spaceship in pairs(storage.spaceships) do
        for _, target in pairs(spaceship.scheduler.current_interrupts or { }) do
          update_scheduler_record(target)
        end
      end
    --end,

    --["render-objects"] = function()
      if storage.gate then
        if storage.gate.void_sprite then
          storage.gate.void_sprite = rendering.get_object_by_id(storage.gate.void_sprite)
        end
        if storage.gate.activation_fx then
          storage.gate.activation_fx.cloud_1 = rendering.get_object_by_id(storage.gate.activation_fx.cloud_1)
          storage.gate.activation_fx.cloud_2 = rendering.get_object_by_id(storage.gate.activation_fx.cloud_2)
        end
      end

      if storage.interburbulator then
        storage.interburbulator.light = rendering.get_object_by_id(storage.interburbulator.light)
        storage.interburbulator.grid = rendering.get_object_by_id(storage.interburbulator.grid)
        storage.interburbulator.robot_text = rendering.get_object_by_id(storage.interburbulator.robot_text)
      end

      for zone_index, dimensional_anchor in pairs(storage.dimensional_anchors) do
        dimensional_anchor.low_power_icon = rendering.get_object_by_id(dimensional_anchor.low_power_icon)
      end

      for unit_number, linked_container in pairs(storage.linked_containers) do
        if linked_container.text_id then
          ---@class LinkedContainerInfo
          ---@field package text_id any DEPRECATED
          linked_container.text_render = rendering.get_object_by_id(linked_container.text_id)
          linked_container.text_id = nil
        end
        if linked_container.effect_id then
          ---@class LinkedContainerInfo
          ---@field package effect_id any DEPRECATED
          linked_container.effect_render = rendering.get_object_by_id(linked_container.effect_id)
          linked_container.effect_id = nil
        end
      end

      for _, tick_task in pairs(storage.tick_tasks) do
        ---@cast tick_task SolarFlareTickTask
        if tick_task.beams then
          for _, beam in pairs(tick_task.beams) do
            ---@class SolarFlareBeamInfo
            ---@field package beam_sprite_id any DEPRECATED
            if beam.beam_sprite_id then
              beam.beam_sprite_render = rendering.get_object_by_id(beam.beam_sprite_id)
            end
          end
        end
      end

      for unit_number, tree in pairs(storage.energy_transmitters) do
        if tree.glaive_beam_sprite_id then
          ---@class EnergyBeamEmitterInfo
          ---@field package glaive_beam_sprite_id any DEPRECATED
          tree.glaive_beam_sprite_render = rendering.get_object_by_id(tree.glaive_beam_sprite_id)
          tree.glaive_beam_sprite_id = nil
        end
      end

      for unit_number, struct in pairs(storage.space_elevators) do
        if struct.text then
          struct.text = rendering.get_object_by_id(struct.text)
        end
        if struct.icon then
          struct.icon = rendering.get_object_by_id(struct.icon)
        end
      end

      for _, defences in pairs({storage.meteor_defences, storage.meteor_point_defences}) do
        for unit_number, defence in pairs(defences) do
          ---@class MeteorDefenceInfo
          ---@field package charging_shape_id any DEPRECATED
          ---@field package charging_text_id any DEPRECATED
          if defence.charging_shape_id then
            defence.charging_shape = rendering.get_object_by_id(defence.charging_shape_id)
            defence.charging_shape_id = nil
          end
          if defence.charging_text_id then
            defence.charging_text = rendering.get_object_by_id(defence.charging_text_id)
            defence.charging_text_id = nil
          end
        end
      end

      for unit_number, nexus in pairs(storage.nexus) do
        ---@class NexusInfo
        ---@field package countdown_id any DEPRECATED
        if nexus.countdown_id then
          nexus.countdown_render = rendering.get_object_by_id(nexus.countdown_id)
          nexus.countdown_id = nil
        end
      end

      for force_name, forcedata in pairs(storage.forces) do
        if forcedata.zone_assets then
          for zone_index, zone_assets in pairs(forcedata.zone_assets) do
            if zone_assets.energy_beam_defence then
              for unit_number, defence in pairs(zone_assets.energy_beam_defence) do
                if defence.glow_id then
                  defence.glow_sprite = rendering.get_object_by_id(defence.glow_id)
                end
              end
            end
          end
        end
      end

      for player_id, playerdata in pairs(storage.playerdata) do
        if playerdata.map_view_objects then
          for i, object in pairs(playerdata.map_view_objects) do
            playerdata.map_view_objects[i] = rendering.get_object_by_id(object)
          end
        end
        if playerdata.capture_text then
          playerdata.capture_text = rendering.get_object_by_id(playerdata.capture_text)
        end
      end

      for player_id, connected_playerdata in pairs(storage.connected_players_in_remote_view) do
        if connected_playerdata.satellite_light then
          connected_playerdata.satellite_light = rendering.get_object_by_id(connected_playerdata.satellite_light)
        end
      end

      ---@class SpaceshipType
      ---@field package particle_object_ids any DEPRECATED
      for _, spaceship in pairs(storage.spaceships) do
        if spaceship.particle_object_ids then
          spaceship.particle_objects = {}
          for anchor_unit_number, particle_object_ids in pairs(spaceship.particle_object_ids) do
            spaceship.particle_objects[anchor_unit_number] = {}
            for _, particle_object_id in pairs(particle_object_ids) do
              table.insert(spaceship.particle_objects[anchor_unit_number], rendering.get_object_by_id(particle_object_id))
            end
          end
          spaceship.particle_object_ids = nil
        end
      end
    --end,

    --["spaceship-updates"] = function()
      for _, spaceship in pairs(storage.spaceships) do
        ---@class SpaceshipType
        ---@field package circuits_to_restore any DEPRECATED
        ---@field package circuitstore_phase any DEPRECATED
        ---@field package circuits_to_restore_tick any DEPRECATED
        spaceship.circuits_to_restore = nil
        spaceship.circuitstore_phase = nil
        spaceship.circuits_to_restore_tick = nil
      end
    --end,

    --["uninvert-enemy-base-controls"] = function()
      -- Remove negative enemy base settings bacause it spawns enemies in F2.0
      for _, zone in pairs(storage.zone_index) do
        for _, control in pairs(zone.controls or {}) do
          if control.frequency and control.frequency <= 0 then
            control.frequency = 1
            control.size = 0
            control.richness = 0
          end
        end

       if zone.controls and zone.controls["enemy-base"] then
          if zone.controls["enemy-base"].size < 0 then
            zone.controls["enemy-base"].size = 0
          end
          if zone.controls["enemy-base"].richness < 0 then
            zone.controls["enemy-base"].richness = 0
          end
        end
      end
      for _, surface in pairs(game.surfaces) do
        local map_gen_settings = surface.map_gen_settings
        --Fix all mapgensettings with 0 frequencies
        for _, control in pairs(map_gen_settings.autoplace_controls or {}) do
          if control.frequency and control.frequency <= 0 then
            control.frequency = 1
            control.size = 0
            control.richness = 0
          end
        end
        if map_gen_settings.cliff_settings then
          if    map_gen_settings.cliff_settings.cliff_elevation_0
            and map_gen_settings.cliff_settings.cliff_elevation_0 == math.huge
          then
            map_gen_settings.cliff_settings.cliff_elevation_0 = 10
          end
          if    map_gen_settings.cliff_settings.cliff_elevation_interval
            and map_gen_settings.cliff_settings.cliff_elevation_interval == math.huge
          then
            map_gen_settings.cliff_settings.cliff_elevation_interval = 400
          end
        end
        surface.map_gen_settings = map_gen_settings

        if map_gen_settings.autoplace_controls and map_gen_settings.autoplace_controls["enemy-base"] then
          local changed = false
          if map_gen_settings.autoplace_controls["enemy-base"].size < 0 then
            map_gen_settings.autoplace_controls["enemy-base"].size = 0
            changed = true
          end
          if map_gen_settings.autoplace_controls["enemy-base"].richness < 0 then
            map_gen_settings.autoplace_controls["enemy-base"].richness = 0
            changed = true
          end
          if changed then
            surface.map_gen_settings = map_gen_settings
          end
        end
      end
    --end,

    --["restrict-planet-autoplace"] = function()
      for _, zone in pairs(storage.zone_index) do
        local surface = Zone.get_surface(zone)
        if surface then
          local map_gen_settings = surface.map_gen_settings
          if Zone.is_space(zone) then
            Zone.set_autoplace_settings_for_space(zone, map_gen_settings)
          else
            Zone.set_autoplace_settings_for_solid(zone, map_gen_settings)
          end
          if map_gen_settings.cliff_settings.cliff_elevation_0 == math.huge then
            map_gen_settings.cliff_settings.cliff_elevation_0 = 0
          end
          if map_gen_settings.cliff_settings.cliff_elevation_interval == math.huge then
            map_gen_settings.cliff_settings.cliff_elevation_interval = 0
          end
          surface.map_gen_settings = map_gen_settings
        end
      end
    --end,

    --["remote-view"] = function()
      for _, player_in_remote_view in pairs(storage.connected_players_in_remote_view) do
        if player_in_remote_view.satellite_light and type(player_in_remote_view.satellite_light) == "number" then
          local light = rendering.get_object_by_id(player_in_remote_view.satellite_light)
          if light then light.destroy() end
        end
        player_in_remote_view.satellite_light = nil

        -- Force player back to character controller.
        local player = player_in_remote_view.player
        local player_data = storage.playerdata[player.index]
        player.teleport(player_data.character.position, player_data.character.surface)
        player.set_controller{
          type = defines.controllers.character,
          character = player_data.character,
        }
      end

      for player_index, player_data in pairs(storage.playerdata) do

        -- IMORTANT: set to the correct permissions group
        local player = game.players[player_index]
        if player then
          if player_data.pre_nav_permission_group and player_data.pre_nav_permission_group.valid and player_data.pre_nav_permission_group.name ~= RemoteView.name_permission_group then
            player.permission_group = player_data.pre_nav_permission_group
          else
            player.permission_group = nil
          end
        end

        -- In 1.1 Nav Sat used the cheat mode, we don't anymore.
        -- Remove it from the player depending on the saved value.
        player.cheat_mode = player_data.saved_cheat_mode or false

        ---@class PlayerData
        ---@field package pre_nav_permission_group any DEPRECATED
        ---@field package saved_cheat_mode any DEPRECATED
        ---@field package remote_view_active_map any DEPRECATED
        player_data.pre_nav_permission_group = nil
        player_data.saved_cheat_mode = nil
        player_data.remote_view_active_map = nil
      end

      for _, player in pairs(game.players) do
        RemoteView.stop(player)
      end

      -- Clean up unused permissions groups.
      for _, permission_group in pairs(game.permissions.groups) do
        if permission_group.name == "satellite" or string.ends(permission_group.name, "_satellite") then
          permission_group.destroy()
        end
      end

      -- Remove naview top gui button if it exists
      for _, player in pairs(game.players) do
        local gui = player.gui.top["mod_gui_top_frame"]
        if gui then
          gui = gui["mod_gui_inner_frame"]
          if gui then
            gui = gui["se-overhead_satellite"]
            if gui then
              gui.destroy()
            end
          end
        end
      end
    --end,

    --["track-basic-rocket-silos"] = function()
      storage.basic_rocket_silos = {}
      for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered{name = Rocketsilo.name_rocket_silos}) do
          Rocketsilo.on_entity_created({entity = entity})
        end
      end

      local warned = false
      local old_landing_pads = util.shallow_copy(storage.rocket_landing_pads)
      for old_unit_number, landingpad in pairs(old_landing_pads) do
        local found = false
        if not landingpad.position then
          if not warned then
            warned = true
            game.print("[color=red]Missing landingpad position data. The game must be saved with a more recent version of SE0.6 on Factorio 1.1 before you load it in SE0.7.x on Factorio 2.0 otherwise the replaced landingpads won't have their old names.[/color]")
          end
        else
          local surface = Zone.get_surface(landingpad.zone)
          local entity = surface.find_entity(Landingpad.name_rocket_landing_pad, landingpad.position)
          if entity then
            found = true
            Landingpad.remove_struct_from_tables(landingpad) -- first
            storage.rocket_landing_pads[landingpad.unit_number] = nil
            storage.rocket_landing_pads[entity.unit_number] = landingpad
            landingpad.container = entity
            landingpad.unit_number = entity.unit_number
            Landingpad.name(landingpad)
            --Log.debug("Landingpad " .. landingpad.name .. " found at position " .. landingpad.position.x .. " " .. landingpad.position.y)
          else
            Log.debug("Landingpad " .. landingpad.name .. " not found at position " .. landingpad.position.x .. " " .. landingpad.position.y)
          end
        end
        if not found then
          Landingpad.destroy(landingpad)
        end
      end

      -- Make sure any remaining landingpads are captured
      for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered{name = Landingpad.name_rocket_landing_pad}) do
          Landingpad.on_entity_created({entity = entity})
        end
      end
    --end,

    --["migration vault loot bags"] = function()
      --effectivity modules are now named efficiency modules
      for _, forcedata in pairs(storage.forces) do
        for i, loot in pairs(forcedata.vaults_loot_bag or {}) do
          if loot == "effectivity-module-9" then
            forcedata.vaults_loot_bag[i] = "efficiency-module-9"
          end
        end
      end
    --end,

    --migrate Factorio 1.1 lua rocket inventories to Factorio 2.0
    for _, struct in pairs(storage.rocket_launch_pads or {}) do
      if struct.launched_contents and not struct.launched_contents[1] then
        --Factorio 1.1 was a dictionary, 2.0 is an array
        local launched_contents = {}
        for item, count in pairs(struct.launched_contents) do
          table.insert(launched_contents, {name=item, count = count, quality="normal"})
        end
        struct.launched_contents = launched_contents
      end
    end

    --migrate Factorio 1.1 lua rocket inventories to Factorio 2.0
    for _, tick_task in pairs(storage.tick_tasks or {}) do
      if tick_task.launched_contents and not tick_task.launched_contents[1] then
        ---@cast tick_task CargoRocketTickTask
        --Factorio 1.1 was a dictionary, 2.0 is an array
        local launched_contents = {}
        for item, count in pairs(tick_task.launched_contents) do
          table.insert(launched_contents, {name=item, count = count, quality="normal"})
        end
        tick_task.launched_contents = launched_contents
      end
    end
  end,

  ["0.7.8"] = function()
    --moves existing rocket launchpad seats to match new spawn location
    for _, forcedata in pairs(storage.forces or {}) do
      for _, zone_assets in pairs(forcedata.zone_assets or {}) do
        for _, launchpad_name in pairs(zone_assets.rocket_launch_pad_names or {}) do
          for _, launchpad_id in pairs(launchpad_name or {}) do
            for _, seat in pairs(launchpad_id.seats) do
              seat.teleport({seat.position.x, launchpad_id.silo.position.y + Launchpad.seat_y_offset})
              seat.orientation = 0.25
            end
          end
        end
      end
    end
  end,

  ["0.7.13"] = function()
    -- Fixes all clamps that might have had their circuit ids corrupted
    for _, clamp_info in pairs(storage.spaceship_clamps) do
      local entity = clamp_info.main
      if entity and entity.valid then
        SpaceshipClamp.validate_clamp_signal(clamp_info.main)
      end
    end

    --rebuild moveable train stop selector gui
    storage.train_gui_opened = storage.train_gui_opened or {}
    for _, player in pairs(game.players) do
      if player.gui.relative[TrainGUI.name_train_gui_root] then
        player.gui.relative[TrainGUI.name_train_gui_root].destroy()
      end
    end
  end,

  ["0.7.14"] = function()
    if storage.glyph_vaults then
      for _, vault in pairs(storage.glyph_vaults) do
        for vault, vault_infos in pairs(vault) do
          if vault_infos.surface_index then
            local surface = game.get_surface(vault_infos.surface_index)
            if surface then game.forces["enemy"].set_evolution_factor(1, surface.name) end
          end
        end
      end
    end
  end,

  ["0.7.17"] = function()
    for _, landing_pad in pairs(storage.rocket_landing_pads or {}) do
      local entity = landing_pad.container
      if entity and entity.valid then
        -- Disable any interaction with the logistics network
        for _, logistic_point in pairs(entity.get_logistic_point() or {}) do
          logistic_point.enabled = false
        end

        -- Make sure they are aligned to the 2x2 grid. The might not be after
        -- the migration from 1.1 to 2.0, and it really messes with the graphics
        -- Using `round` here move it makes the new 8x8 remain within the 9x9
        -- footprint of the old 1.1 landing pads.
        entity.teleport({
          math.round(entity.position.x / 2) * 2,
          math.round(entity.position.y / 2) * 2
        })
        end
    end
  end,

  ["0.7.18"] = function()
    for _, surface in pairs(game.surfaces) do
      for turbine_name, config in pairs(CondenserTurbine.turbine_configs) do
        -- First remove all orphan generators and tanks
        local destroy_if_orphan = function(entity)
          if not surface.find_entity(turbine_name, entity.position) then
            entity.destroy()
          end
        end
        for _, tank in pairs(surface.find_entities_filtered{name=config.tank_name}) do
          destroy_if_orphan(tank)
        end
        for _, generator in pairs(surface.find_entities_filtered{name=config.generator_names}) do
          destroy_if_orphan(generator)
        end

        -- Fix all turbines that might have their hidden tanks at the correct direction,
        -- and make the rotatable flag is set correctly
        for _, turbine in pairs(surface.find_entities_filtered{name=turbine_name}) do
          -- Ensure rotatable flag is correct
          turbine.rotatable = config.rotatable

          -- Ensure the tank is in the correct position and direction
          for _, tank in pairs(turbine.surface.find_entities_filtered({
            name = config.tank_name,
            area = turbine.bounding_box,
            limit = 1
          })) do
            tank.teleport(CondenserTurbine.determine_tank_position(turbine, config))
            tank.direction = turbine.direction
          end

          -- The big turbines might have their generators pointing the wrong way. Let's fix that.
          if turbine_name == "se-big-turbine" then
            local old_generator = CondenserTurbine.find_generator(turbine)
            if old_generator and old_generator.name ~= config.get_generator_name(turbine) then
              -- Delete NW entity
              local fluid_count = old_generator.remove_fluid({name = "se-decompressing-steam", amount = 10000})
              old_generator.destroy()

              -- Create new entity
              local new_generator = surface.create_entity({
                name = config.get_generator_name(turbine),
                position = turbine.position,
                force = turbine.force,
                direction = turbine.direction,
              })
              ---@cast new_generator -?
              new_generator.destructible = false
              if fluid_count ~= 0 then
                new_generator.insert_fluid({name = "se-decompressing-steam", amount = math.abs(fluid_count), temperature = 5000})
              end
            end
          end
        end
      end
    end

    for _, surface in pairs(game.surfaces) do
      local map_gen_settings = surface.map_gen_settings
      --Fix all mapgensettings with 0 frequencies
      for _, control in pairs(map_gen_settings.autoplace_controls or {}) do
        if control.frequency <= 0 then
          control.frequency = 1
          control.size = 0
          control.richness = 0
        end
      end
      surface.map_gen_settings = map_gen_settings
      for _, zone in pairs(storage.zone_index) do
        for _, control in pairs(zone.controls or {}) do
          if control.frequency and control.frequency <= 0 then
            control.frequency = 1
            control.size = 0
            control.richness = 0
          end
        end
      end
    end

    -- Update all spaceships with a localized surface name
    for _, spaceship in pairs(storage.spaceships) do
      Spaceship.rename(spaceship, spaceship.name)
    end
  end,

  ["0.7.20"] = function()
    local res_tbl = load("return "..storage.resources_and_controls_compare_string)()

    for index, fragment in pairs(res_tbl.core_fragments) do
      if fragment == "se-core-fragment-imersite" then
        res_tbl.core_fragments[index] = "se-core-fragment-kr-imersite"
      end
      if fragment == "se-core-fragment-mineral-water" then
        res_tbl.core_fragments[index] = "se-core-fragment-kr-mineral-water"
      end
      if fragment == "se-core-fragment-rare-metals" then
        res_tbl.core_fragments[index] = "se-core-fragment-kr-rare-metal-ore"
      end
    end
    table.sort(res_tbl.core_fragments)

    for index, control_name in pairs(res_tbl.resource_controls) do
      if control_name == "imersite" then
        res_tbl.resource_controls[index] = "kr-imersite"
      end
      if control_name == "mineral-water" then
        res_tbl.resource_controls[index] = "kr-mineral-water"
      end
      if control_name == "rare-metals" then
        res_tbl.resource_controls[index] = "kr-rare-metal-ore"
      end
    end

    for key, value in pairs(res_tbl.resource_settings) do
      if key == "imersite" then
        value.core_fragment = "se-core-fragment-kr-imersite"
        value.name = "kr-imersite"
        res_tbl.resource_settings["kr-imersite"] = value
        res_tbl.resource_settings[key] = nil
      end
      if key == "mineral-water" then
        value.core_fragment = "se-core-fragment-kr-mineral-water"
        value.name = "kr-mineral-water"
        res_tbl.resource_settings["kr-mineral-water"] = value
        res_tbl.resource_settings[key] = nil
      end
      if key == "rare-metals" then
        value.core_fragment = "se-core-fragment-kr-rare-metal-ore"
        value.name = "kr-rare-metal-ore"
        res_tbl.resource_settings["kr-rare-metal-ore"] = value
        res_tbl.resource_settings[key] = nil
      end
    end

    storage.resources_and_controls_compare_string = util.table_to_string(res_tbl)

    for _, zone in pairs(storage.zone_index) do
      if zone.controls then
        if zone.controls["imersite"] then
          zone.controls["kr-imersite"] = table.deepcopy(zone.controls["imersite"])
          zone.controls["imersite"] = nil
        end
        if zone.controls["mineral-water"] then
          zone.controls["kr-mineral-water"] = table.deepcopy(zone.controls["mineral-water"])
          zone.controls["mineral-water"] = nil
        end
        if zone.controls["rare-metals"] then
          zone.controls["kr-rare-metal-ore"] = table.deepcopy(zone.controls["rare-metals"])
          zone.controls["rare-metals"] = nil
        end
      end
      if zone.primary_resource then
        if zone.primary_resource == "imersite" then
          zone.primary_resource = "kr-imersite"
        end
        if zone.primary_resource == "mineral-water" then
          zone.primary_resource = "kr-mineral-water"
        end
        if zone.primary_resource == "rare-metals" then
          zone.primary_resource = "kr-rare-metal-ore"
        end
      end
      if zone.fragment_name then
        if zone.fragment_name == "se-core-fragment-imersite" then
          zone.fragment_name = "se-core-fragment-kr-imersite"
        end
        if zone.fragment_name == "se-core-fragment-mineral-water" then
          zone.fragment_name = "se-core-fragment-kr-mineral-water"
        end
        if zone.fragment_name == "se-core-fragment-rare-metals" then
          zone.fragment_name = "se-core-fragment-kr-rare-metal-ore"
        end
      end
    end
    ---@class storage
    ---@field package skip_resource_removal boolean Used only for migrations 0.6 -> 0.7

    storage.skip_resource_removal = true -- only used in 0.7.30 resource removal fix
  end,

  ["0.7.28"] = function()
    -- Stop special resources from appearing in migrated saves.
    for _, zone in pairs(storage.zone_index) do
      local surface = Zone.get_surface(zone)
      if surface then
        local map_gen_settings = surface.map_gen_settings
        if Zone.is_space(zone) then
          Zone.set_autoplace_settings_for_space(zone, map_gen_settings)
        else
          Zone.set_autoplace_settings_for_solid(zone, map_gen_settings)
        end
        surface.map_gen_settings = map_gen_settings
      end
    end
  end,

  ["0.7.30"] = function()
    -- in versions of 0.7 pre 0.7.28 there was the potential for resources to be added to autoplace_settings on surfaces where they shouldn't be
    -- if the version of "0.7.20" runs with skip_resource_removal, then the save is safe, but if it was run before "0.7.28", then the save may be contaminated
    -- so if storage.skip_resource_removal is not set then remove reosurces
    if not storage.skip_resource_removal then

      for _, zone in pairs(storage.zone_index) do
        local surface = Zone.get_surface(zone)
        if surface then
          local map_gen_settings = surface.map_gen_settings
          local resource_names = {}
          if Zone.is_space(zone) then
            -- remove space reosurces.
            resource_names ={"copper-ore", "iron-ore", "uranium-ore", "stone", "se-beryllium-ore", "se-water-ice", "se-methane-ice", "se-naquium-ore"}
          else
            -- remove land reosurces.
            resource_names = {"coal", "copper-ore", "iron-ore", "uranium-ore", "stone", "crude-oil",
            "se-vulcanite", "se-cryonite", "se-holmium-ore", "se-iridium-ore", "se-beryllium-ore", "se-vitamelange"}
          end
          local resources_to_remove = {}
          for _, resource_name in pairs(resource_names) do
            if not(map_gen_settings.autoplace_controls[resource_name] and map_gen_settings.autoplace_controls[resource_name].size > 0) then
              table.insert(resources_to_remove, resource_name)
            end
          end
          for _, entity in pairs(surface.find_entities_filtered{name = resources_to_remove}) do
            entity.destroy()
          end
        end
      end

    end
    storage.skip_resource_removal = nil -- clean up temp flag
  end,

  ["0.7.33"] = function()
    --Fix any potentially holey storage.delivery_cannon_payloads tables
    if not storage.delivery_cannon_payloads then return end
    local old_payloads = storage.delivery_cannon_payloads
    storage.delivery_cannon_payloads = {}
    for _, payload in pairs(old_payloads) do
      table.insert(storage.delivery_cannon_payloads, payload)
    end

    --remove orphaned deprecated glow_id that was converted in an earlier migration
    for force_name, forcedata in pairs(storage.forces or {}) do
      if forcedata.zone_assets then
        for zone_index, zone_assets in pairs(forcedata.zone_assets or {}) do
          if zone_assets.energy_beam_defence then
            for unit_number, defence in pairs(zone_assets.energy_beam_defence) do
              ---@class EnergyBeamDefenceInfo
              ---@field package glow_id any DEPRECATED
              if defence.glow_id then
                defence.glow_id = nil
              end
            end
          end
        end
      end
    end

    --remove orphaned deprecated beam_sprite_id that was converted in an earlier migration
    for _, tick_task in pairs(storage.tick_tasks or {}) do
      ---@cast tick_task SolarFlareTickTask
      for _, beam in pairs(tick_task.beams or {}) do
        if beam.beam_sprite_id then
          beam.beam_sprite_id = nil
        end
      end
    end

  end,

  ["0.7.34"] = function()
    for _, defences in pairs({storage.meteor_defences, storage.meteor_point_defences}) do
      for _, defence in pairs(defences) do
        if defence.charging_shape_id then
          defence.charging_shape = defence.charging_shape_id
          defence.charging_shape_id = nil
        end
        if defence.charging_text_id then
          defence.charging_text = defence.charging_text_id
          defence.charging_text_id = nil
        end
      end
    end

    local conquest_force = game.forces["conquest"]
    util.safe_research_tech(conquest_force, "repair-pack")

    -- Close spaceship gui for all players because we added another button
    -- They can open it again manually.
    for _, player in pairs(game.players) do
      SpaceshipGUI.gui_close(player)
    end
  end,

  ["0.7.35"] = function()
    local status_lookup = {
      [1] = "exterior",
      [2] = "wall_exterior",
      [3] = "bulkhead_exterior",
      [4] = "floor",
      [5] = "wall",
      [6] = "bulkhead",
      [7] = "floor_exterior",
      [8] = "floor_interior",
      [9] = "floor_console_disconnected",
      [10] = "wall_console_disconnected",
      [11] = "bulkhead_console_disconnected",
      [12] = "floor_console_connected",
      [13] = "wall_console_connected",
      [14] = "bulkhead_console_connected",
    }

    for _, force_data in pairs(storage.forces) do
      SpaceshipIntegrity.update_integrity_limit(game.forces[force_data.force_name])
    end

    for _, spaceships in pairs({
      storage.spaceships or {},
      storage.simulation_spaceships or { },
    }) do
      for _, spaceship in pairs(spaceships) do

        -- Update spaceship tile status
        for _, tiles_x in pairs(spaceship.check_tiles or { }) do
          for y, tile_status in pairs(tiles_x) do
            if type(tile_status) == "number" then
              local new_tile_status = status_lookup[tile_status]
              assert(new_tile_status, "Unknown tile status: " .. tile_status)
              tiles_x[y] = new_tile_status
            end
          end
        end
        for _, tiles_x in pairs(spaceship.known_tiles or { }) do
          for y, tile_status in pairs(tiles_x) do
            if type(tile_status) == "number" then
              local new_tile_status = status_lookup[tile_status]
              assert(new_tile_status, "Unknown tile status: " .. tile_status)
              tiles_x[y] = new_tile_status
            end
          end
        end

        -- Remove outdated fields
        spaceship.known_clamps = nil
        spaceship.check_clamps = nil

        -- Update surfce caching
        if spaceship.own_surface_index then
          spaceship.own_surface = game.get_surface(spaceship.own_surface_index)
          spaceship.on_own_surface = true
        end
        spaceship.own_surface_index = nil

        -- Remove deferred repath flag and force repath now
        if spaceship.scheduler.deferred_repath then
          SpaceshipScheduler.force_repath(spaceship)
          spaceship.scheduler.deferred_repath = nil
        end

      end
    end
  end,

  ["0.7.36"] = function()
    -- This is the 0.7.0 migration, but for some reason it was only applied
    -- when storage.gate was present. So now we redo it with a check first
    -- that it hasn't been done already.
    for entity_number, shape_id in pairs(storage.beacon_overloaded_shapes) do
      if type(shape_id) == "number" then
        storage.beacon_overloaded_shapes[entity_number] = rendering.get_object_by_id(shape_id)
      end
    end
  end,

  ["0.7.37"] = function()
    -- Remove orphan spaceship console outputs
    for _, surface in pairs(game.surfaces) do
      for _, console in pairs(surface.find_entities_filtered{name = Spaceship.name_spaceship_console_output}) do
        if surface.find_entity(Spaceship.name_spaceship_console, console.position) then
          goto continue
        end

        if #surface.find_entities_filtered{
          name = "entity-ghost",
          ghost_name = Spaceship.name_spaceship_console,
          position = console.position} > 0
        then
          goto continue
        end

        console.destroy()
        ::continue::
      end
    end
  end,

  ["0.7.40"] = function()
    for _, spaceship in pairs(storage.spaceships or {}) do
      SpaceshipSchedulerGUI.rebuild(spaceship)
    end

    for _, force in pairs(game.forces) do
      if not SystemForces.is_system_force(force.name) then
        force.technologies[mod_prefix .. "always-researched"].researched = true
      end
    end

    Zone.reset_localised_names_of_zone_surfaces() -- part always_do_migrations(), but this migrates testing worlds too
    Ancient.reset_localised_vault_surface_names() -- done just once since other mods have no good reason to touch this
    MapView.reset_localised_starmap_surface_names() -- ^^
  end,

  ["0.7.42"] = function()
    MapView.reset_localised_starmap_surface_names() -- refresh due to the vault localization hotfix

    -- storage.quality_exploration.surface = nil
    -- storage.quality_exploration.pole = nil

    if game.get_surface("se-quality-exploration") then
      game.delete_surface("se-quality-exploration")
    end

    -- ItemRequestProxy.on_init()
  end,


  ["0.7.43"] = function()
    -- Ensure there are no spaceship groups with reserved (unassigned) group name
    -- At this point there should be no unassigned spaceships

    ---@param groups table<string, SpaceshipScheduleGroup>
    ---@param old_name string
    ---@return string new_name
    local function new_unique_name(groups, old_name)
      local index = 1
      local new_name = old_name .. "-" .. index
      while groups[new_name] do
        index = index + 1
        new_name = old_name .. "-" .. index
      end
      return new_name
    end

    local new_groups_for_force = {} -- To work around issues with modifying table while iterating
    for force_name, schedule_groups in pairs(storage.spaceship_scheduler_groups or {}) do
      local new_schedule_groups = {}
      new_groups_for_force[force_name] = new_schedule_groups

      for group_name, group in pairs(schedule_groups) do
        local new_group_name = group_name

        if SpaceshipScheduler.is_unassigned_group_name(group_name) then
          new_group_name = new_unique_name(schedule_groups, group_name)

          -- Update existing spaceships
          for spaceship_index, _ in pairs(group.spaceships or {}) do
            local spaceship = storage.spaceships[spaceship_index]
            spaceship.scheduler.schedule_group_name = new_group_name
          end

          -- Update existing interrupts
          for _, interrupt_name in pairs(group.interrupts or {}) do
            local interrupt = storage.spaceship_scheduler_interrupts[force_name][interrupt_name]
            local value = interrupt.schedules[group_name]
            interrupt.schedules[group_name] = nil
            interrupt.schedules[new_group_name] = value
          end
        end

        assert(not new_schedule_groups[new_group_name])
        new_schedule_groups[new_group_name] = group
      end
    end
    storage.spaceship_scheduler_groups = new_groups_for_force

    -- Now rebuild all open spaceship scheduler GUIs
    for _, spaceship in pairs(storage.spaceships or { }) do
      SpaceshipSchedulerGUI.rebuild(spaceship)
    end

    for _, delivery_cannon in pairs(storage.delivery_cannons or {}) do
      if delivery_cannon.main.valid then
        delivery_cannon.position = delivery_cannon.main.position
      end
    end
  end,
  ["0.7.45"] = function()
    for _, player in pairs(game.players) do
      local playerdata = get_make_playerdata(player)
      ---@class PlayerData.old: PlayerData
      ---@field package location_history table []|{references:any} DEPRECATED
      ---@cast playerdata PlayerData.old
      if playerdata.location_history then playerdata.location_history.references = {} end
    end
  end,
  ["0.7.47"] = function()
    for _, player in pairs(game.players) do
      local playerdata = get_make_playerdata(player)
      playerdata.location_history  = {}
    end
  end,

  ["0.7.48"] = function()
    --rerun the 0.7.47 migration for testers that were on a 0.7.45-47 closed testing branch
    Migrate.migrations["0.7.47"]()

    --Space elevator migrations
    if storage.space_elevator_structs then return end -- don't rerun this migration

    ---@class SpaceElevatorInfo
    ---@field package type any DEPRECATED
    ---@field package watch_area any DEPRECATED
    ---@field package force_forward_area any DEPRECATED
    ---@field package force_forwards any DEPRECATED
    ---@field package valid any DEPRECATED
    ---@field package force_name any DEPRECATED
    ---@field package direction any DEPRECATED
    ---@field package collider_position any DEPRECATED
    ---@field package position any DEPRECATED
    ---@field package output_area any DEPRECATED
    ---@field package total_energy any DEPRECATED
    ---@field package built any DEPRECATED
    ---@field package name any DEPRECATED
    ---@field package lua_energy any DEPRECATED
    ---@field package parts_needed any DEPRECATED
    ---@field package parts any DEPRECATED
    ---@field package is_primary any DEPRECATED
    ---@field package opposite_struct any DEPRECATED

    storage.space_elevator_structs = {}
    storage.space_elevator_train_ahead = {}
    storage.space_elevator_train_behind = {}
    local struct_index = 1 --sequential index

    --setup struct and links
    for _, elevator in pairs(storage.space_elevators) do
      if elevator.is_primary then
        local struct = {}
        storage.space_elevator_structs[struct_index] = struct
        struct.index = struct_index
        struct_index = struct_index + 1

        elevator.opposite_elevator = elevator.opposite_struct
        elevator.opposite_elevator.opposite_elevator = elevator
        struct.primary = elevator
        struct.secondary = elevator.opposite_elevator
        elevator.elevator_struct = struct
        elevator.opposite_elevator.elevator_struct = struct
      end
    end

    -- create caches and migrate struct info
    for _, elevator in pairs(storage.space_elevators) do
      local struct = elevator.elevator_struct
      local maintenance_cost = (SpaceElevator.maintenance_min_multiplier + (1-SpaceElevator.maintenance_min_multiplier) * struct.primary.zone.radius / 10000)
      if elevator == struct.primary then
        --cache maintanence info
        elevator.maintenance_per_stack = SpaceElevator.maintenance_per_stack_up * maintenance_cost
        elevator.energy_per_stack = SpaceElevator.energy_per_stack_up * maintenance_cost
        struct.parts_per_second = SpaceElevator.maintenance_per_second * maintenance_cost
        struct.parts_needed = SpaceElevator.parts_per_radius * elevator.zone.radius
        --cache positions
        struct.direction = elevator.direction
        struct.direction_sign = struct.direction == defines.direction.west and 1 or -1
        struct.position = elevator.position
        struct.collider_position = Util.vectors_add(SpaceElevator.space_elevator_collider_position[struct.direction], struct.position)
        struct.rail_radius_multiplier = SpaceElevator.space_elevator_hypertrain_rail_radius * struct.direction_sign
        struct.output_rail_circle_offset = Util.vectors_add(SpaceElevator.output_rail_circle_offset[struct.direction], struct.position)
        struct.input_rail_circle_offset = Util.vectors_add(SpaceElevator.input_rail_circle_offset[struct.direction], struct.position)
        struct.output_area = Util.area_add_position(SpaceElevator.space_elevator_output_rect[struct.direction], struct.position)
        struct.blocker_position = Util.vectors_add(SpaceElevator.blocker_offset[struct.direction], struct.position)
        --cache remaining
        struct.force_name = elevator.force_name
        struct.constructed = elevator.built
        struct.name = elevator.name
        struct.total_energy = elevator.total_energy
        struct.lua_energy = elevator.lua_energy
        struct.parts = elevator.parts
        struct.disabled = elevator.main.disabled_by_script
        struct.parts_threshold = struct.parts_needed * SpaceElevator.parts_display_threshold
        struct.above_threshold = struct.parts > struct.parts_threshold
        struct.powered = struct.total_energy >= SpaceElevator.energy_min
      else
        --cache maintenance info
        elevator.maintenance_per_stack = SpaceElevator.maintenance_per_stack_down * maintenance_cost
        elevator.energy_per_stack = SpaceElevator.energy_per_stack_down * maintenance_cost
      end
    end
    
    -- RailSignalPlanner can destroy and replace our internal rail signals, invalidating them. Replace and rereference them.
    for _, elevator in pairs(storage.space_elevators) do
      local signal_count = 0
      local remove = {}
      for idx, sub_entity in pairs(elevator.sub_entities) do
        if sub_entity.valid then
          if sub_entity.name == "se-space-elevator-rail-signal" then
            signal_count = signal_count + 1
            table.insert(remove, idx)
          end
        else
          table.insert(remove, idx)
        end
      end
      if signal_count ~= 2 and #remove == 2 then
        --internal rail signals were destroyed (likely by RailSignalPlanner), replace them
        for _, entity in pairs(elevator.surface.find_entities_filtered{area = elevator.main.bounding_box, name = "se-space-elevator-rail-signal"}) do
          entity.destroy()
        end
        for idx = #remove, 1, -1 do
          table.remove(elevator.sub_entities, remove[idx])
        end

        local struct = elevator.elevator_struct
        for _, entity in pairs(SpaceElevator.internals[struct.direction]["se-space-elevator-rail-signal"]) do
          local sub_entity = elevator.surface.create_entity{
            name = "se-space-elevator-rail-signal",
            position = Util.vectors_add(struct.position, entity.position),
            direction = entity.direction,
            force = struct.force_name
          }
          table.insert(elevator.sub_entities, sub_entity)
        end
      end
    end

    -- migrate entity data
    for _, elevator in pairs(storage.space_elevators) do
      elevator.needs_tug = true -- safe to assume true for trains currently in transit
      if elevator.tug and not elevator.tug.valid then
        elevator.tug = nil
      end

      --get railends
      local struct = elevator.elevator_struct
      for _, sub_entity in pairs(elevator.sub_entities) do
        if sub_entity.name == "se-space-elevator-legacy-curved-rail" and (
            (sub_entity.direction == defines.direction.south and struct.direction == defines.direction.east) or
            (sub_entity.direction == defines.direction.southwest and struct.direction == defines.direction.west)
          )
        then
          elevator.opposite_struct.output_railend = sub_entity.get_rail_end(defines.rail_direction.front)
        elseif sub_entity.name == "se-space-elevator-legacy-straight-rail" and sub_entity.direction == defines.direction.north then
          elevator.input_railend = sub_entity.get_rail_end(defines.rail_direction.front)
        end
      end

      elevator.station_connected_rail = elevator.station.connected_rail

      --add existing peices to sub_entities
      table.insert(elevator.sub_entities, elevator.station)
      table.insert(elevator.sub_entities, elevator.energy_interface)
      table.insert(elevator.sub_entities, elevator.electric_pole)

      --cache circuit wire connectors
      elevator.electric_pole_copper = elevator.electric_pole.get_wire_connector(defines.wire_connector_id.pole_copper, true)
      elevator.electric_pole_red = elevator.electric_pole.get_wire_connector(defines.wire_connector_id.circuit_red, true)
      elevator.electric_pole_green = elevator.electric_pole.get_wire_connector(defines.wire_connector_id.circuit_green, true)
      ---@class SpaceElevatorInfo
      ---@field package power_switch any DEPRECATED
      if elevator == struct.primary then
        struct.power_switch = elevator.power_switch
        struct.power_switch_left = struct.power_switch.get_wire_connector(defines.wire_connector_id.power_switch_left_copper, true)
        struct.power_switch_right = struct.power_switch.get_wire_connector(defines.wire_connector_id.power_switch_right_copper, true)
        table.insert(elevator.sub_entities, struct.power_switch)
      end

      -- nil invalid rendering objects
      if elevator.text and not elevator.text.valid then
        elevator.text = nil
      end
      if elevator.icon and not elevator.icon.valid then
        elevator.icon = nil
      end

      script.register_on_object_destroyed(elevator.main)
    end

    --migrate trains currently traversing
    for _, elevator in pairs(storage.space_elevators) do
      if elevator.carriage_ahead and elevator.carriage_ahead.valid then
        elevator.train_ahead = elevator.carriage_ahead.train
        elevator.train_ahead_weight = elevator.train_ahead.weight
        elevator.train_ahead_id = elevator.train_ahead.id
        elevator.ahead_forward_sign = SpaceElevator.get_ahead_forward_sign(elevator)
        storage.space_elevator_train_ahead[elevator.train_ahead.id] = elevator
      else
        elevator.carriage_ahead = nil
      end
      if elevator.carriage_behind and elevator.carriage_behind.valid then
        elevator.train_behind = elevator.carriage_behind.train
        elevator.train_behind_weight = elevator.train_behind.weight
        elevator.train_behind_id = elevator.train_behind.id
        elevator.behind_forward_sign = SpaceElevator.get_behind_forward_sign(elevator)
        storage.space_elevator_train_behind[elevator.train_behind.id] = elevator
      else
        elevator.carriage_behind = nil
      end

      if elevator.carriage_behind then
        if elevator.collider and elevator.collider.valid then
          elevator.collider.destroy()
        end
        elevator.collider = nil
      else
        if not elevator.collider or not elevator.collider.valid then
          elevator.collider = elevator.surface.create_entity{
            name = SpaceElevator.name_space_elevator_train_collider,
            position = elevator.elevator_struct.collider_position,
            force = "neutral"
          }
        end
      end
    end

    -- cache train schedule information
    for _, elevator in pairs(storage.space_elevators) do
      if elevator.carriage_ahead then
        local schedule = elevator.train_ahead.get_schedule()
        elevator.schedule_group = schedule.group
        elevator.schedule_records = schedule.get_records()
        elevator.schedule_interrupts = schedule.get_interrupts()
        elevator.schedule_current = schedule.current
        -- do not attempt to migrate scheduling info on the train itself, it will traverse normally
      end
    end

    -- migrate colliders that might need shifted
    -- this is fine to teleport onto an about-to-traverse train
    for _, elevator in pairs(storage.space_elevators) do
      if elevator.collider and elevator.collider.valid then
        elevator.collider.teleport(elevator.elevator_struct.collider_position)
      end
    end

    -- create script inventory to hold the blocker blueprint
    local inv = game.create_inventory(1)
    inv.insert{name="blueprint", count = 1}
    local blueprint = inv[1]
    blueprint.set_blueprint_entities{{
      entity_number = 1,
      name = SpaceElevator.name_connection_blocker,
      position = {0, 0},
      orientation = 0.25,
      stock_connections = {stock = 1}
    }}
    storage.space_elevator_blocker_blueprint = blueprint

    -- remove unused fields
    for _, elevator in pairs(storage.space_elevators) do
      elevator.opposite_struct = nil
      elevator.is_primary = nil
      elevator.power_switch = nil
      elevator.type = nil
      elevator.watch_area = nil
      elevator.force_forward_area = nil
      elevator.force_forwards = nil
      elevator.valid = nil
      elevator.force_name = nil
      elevator.direction = nil
      elevator.collider_position = nil
      elevator.position = nil
      elevator.output_area = nil
      elevator.total_energy = nil
      elevator.built = nil
      elevator.name = nil
      elevator.lua_energy = nil
      elevator.parts_needed = nil
      elevator.parts = nil
    end
  end,

  ["0.7.49"] = function()
    ---@class SpaceElevatorStruct
    ---@field package output_creation_position any DEPRECATED
    for _, struct in pairs(storage.space_elevator_structs) do
      struct.output_creation_position = nil
    end

    ---@class storage
    ---@field package space_elevator_output_creation_distance any DEPRECATED
    storage.space_elevator_output_creation_distance = nil

    for _, elevator in pairs(storage.space_elevators) do
      if elevator.carriage_behind then
        --calculate max angle carriage for this train
        local max_angle = 0
        for _, carriage in pairs(elevator.train_behind.carriages) do
          half_angle = SpaceElevator.carriage_half_length_angle[carriage.name]
          if half_angle > max_angle then
            max_angle = half_angle
          end
        end
        --We need space for the full length of new stock, and full length of a tug
        local ahead_compensator_angle = 2 * max_angle + SpaceElevator.tug_length
        -- Solve for the angular distance between ahead and behind stocks to try to maintain
        elevator.carriage_compensator_angle = ahead_compensator_angle + SpaceElevator.behind_compensator_angle
      end
    end
  end,

  ["0.7.50"] = function()
    -- clear old blocker ghosts
    for _, surface in pairs(game.surfaces) do
      for _, entity in pairs(surface.find_entities_filtered{ghost_name=SpaceElevator.name_connection_blocker}) do
        entity.destroy()
      end
    end
  end,

  ["0.7.53"] = function()
    -- update to Factorio 2.0.76 stable
    storage.space_elevator_blocker_blueprint.set_blueprint_entities{{
      entity_number = 1,
      name = SpaceElevator.name_connection_blocker,
      position = {0, 0},
      orientation = 0.25,
      stock_connections = {stock = 1}
    }}
  end,

  ["0.7.54"] = function ()
    ---@class storage
    ---@field package connected_players_in_remote_view any DEPRECATED
    ---@field package item_request_proxy any DEPRECATED
    ---@field package quality_exploration any DEPRECATED
    storage.players_in_remote_view = nil
    storage.connected_players_in_remote_view = nil
    storage.item_request_proxy = nil
    storage.quality_exploration = nil

    ---@class PlayerData
    ---@field package anchor_scouting_for_spaceship_index any DEPRECATED
    ---@field package anchor_scouting_cache any DEPRECATED
    ---@field package remote_view_activity any DEPRECATED
    ---@field package remote_view_active any DEPRECATED
    ---@field package remote_view_current_zone any DEPRECATED
    ---@field package starmap_active_map any DEPRECATED
    ---@field package editor_character_data any DEPRECATED

    for _, player in pairs(game.players) do
      local playerdata = get_make_playerdata(player)

      if RemoteView.is_intersurface_unlocked(player) then
        MapView.get_make_surface(player) -- Force generate surface for first time viewing
      end

      ---@param player LuaPlayer
      ---@param playerdata PlayerData
      ---@return LuaEntity?
      local function get_character(player, playerdata)
        if playerdata.character and playerdata.character.valid then
          return playerdata.character
        end

        if player.character and player.character.valid then
          return player.character -- The old map view character won't be valid.
        end
      end

      ---@param player LuaPlayer
      ---@param playerdata PlayerData
      ---@return boolean? success
      local function return_to_character(player, playerdata)
        local character = get_character(player, playerdata)
        if character then
          player.teleport(character.position, character.surface)
          player.set_controller{type = defines.controllers.character, character = character}
        elseif playerdata.editor_character_data then
          player.teleport(playerdata.editor_character_data.position, playerdata.editor_character_data.surface)
          player.set_controller{type = defines.controllers.editor}
        else
          player.print("[Space Exploration] Could not find character to return to. Teleporting to spawn instead using respawn mechanism.")
          Respawn.die(player)
        end
      end

      if playerdata.remote_view_active then
        return_to_character(player, playerdata)
        RemoteView.stop(player)
      elseif MapView.is_surface_starmap(player.surface) then
        return_to_character(player, playerdata)
        MapView.stop_map(player)
        RemoteView.history_previous(player, true)
      elseif playerdata.anchor_scouting_for_spaceship_index then
        local success = return_to_character(player, playerdata)
        RemoteView.stop(player)
        if (success) then
          Spaceship.start_anchor_scouting(Spaceship.from_index(playerdata.anchor_scouting_for_spaceship_index), player)
        end
        playerdata.anchor_scouting_for_spaceship_index = nil
        playerdata.anchor_scouting_cache = nil
      end
      if playerdata.remote_view_activity then
        return_to_character(player, playerdata)
        playerdata.remote_view_activity = nil
        player.cursor_ghost = nil
        RemoteView.history_previous(player, true)
        RemoteView.history_previous(player, true)
      end

      playerdata.remote_view_active = nil
      playerdata.remote_view_current_zone = nil
      playerdata.starmap_active_map = nil
      playerdata.editor_character_data = nil
    end
  end,

  ["0.7.55"] = function()
    --reapply active settings to any elevator that may have been mined and cancelled
    for _, struct in pairs(storage.space_elevator_structs) do
      struct.disabled = struct.disabled or false
    end
    for _, elevator in pairs(storage.space_elevators) do
      script.register_on_object_destroyed(elevator.main)
      elevator.main.disabled_by_script = elevator.elevator_struct.disabled
    end
  end,

  ["0.7.56"] = function()
    -- remove any orphaned train ids
    for train_id, _ in pairs(storage.space_elevator_train_behind) do
      if not game.train_manager.get_train_by_id(train_id) then
        storage.space_elevator_train_behind[train_id] = nil
      end
    end
    -- init scan area
    for _, struct in pairs(storage.space_elevator_structs) do
      struct.output_scan_area = Util.area_add_position(SpaceElevator.space_elevator_output_scan_rect[struct.direction], struct.position)
    end
  end,
}

Migrate.test_migrations = {
  --[[
  --Add migrations for testing in the following format with a custom named key.
  --When ready for release, change the name to the current version number and move to Migration.migrations above.
  ["My debug migrations"] = function()
    do_stuff()
  end,
  --]]

  
}

return Migrate
