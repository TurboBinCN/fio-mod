--[[ NOTE: The multiplayer support commnads are designed so that multiplayer mods can use them, but individuals can use use commands to to get multiplayer working without relying on mods.]]

remote.add_interface(
    "space-exploration",
    {

-- remote interface for train teleportation through Space elevator
-- defines.events.se_on_train_teleport_started
--[[
Event data:
      {
        train = carriage_new_train, -- newly created train consisting of the first carriage to be transferred
        old_train_id_1 = struct.old_train_id, -- id of train behind which is about to be invalidated
        old_surface_index = struct.surface.index,
        teleporter = struct.main -- space elevator entity doing the transferring
      })
]]
        get_on_train_teleport_started_event = function() return util.get_custom_event_id("on_train_teleport_started") end,

-- defines.events.se_on_train_teleport_finished
--[[
Event data:
      {
        train = carriage_ahead.train, -- fully built newly created train post transfer
        old_train_id_1 = struct.old_train_id, -- id of the train prior to transer start
        stranded = elevator.train_behind, --optional: only if train is split due to incomplete transfer
        old_surface_index = struct.surface.index,
        teleporter = struct.main, -- space elevator entity doing the transferring
      })
]]
        get_on_train_teleport_finished_event = function() return util.get_custom_event_id("on_train_teleport_finished") end,

-- defines.events.se_on_space_elevator_changed_state
--[[
Event data:
  {
    primary = primary.main,
    constructed = true/false,
    powered = true/false
  }
]]
        get_on_space_elevator_changed_state_event = function() return util.get_custom_event_id("on_space_elevator_changed_state") end,

-- returns info about the space elevator
--/c remote.call("space-exploration", "get_space_elevator_info", {unit_number=23})
--[[
  return {
    main = elevator.main,
    train_stop = elevator.station,
    opposite = elevator.opposite_elevator.main,
    constructed = elevator.elevator_struct.constructed,
    powered = elevator.elevator_struct.total_energy >= SpaceElevator.energy_min
  }
]]
        get_space_elevator_info = function(data)
          if data and type(data.unit_number) == "number" then
            local export_info = SpaceElevator.get_export_info(data.unit_number)
            if export_info then return export_info end
          end
        end,

-- returns the current name of the cargo landing pad
--/c remote.call("space-exploration", "get_landing_pad_name", {unit_number=76})
        get_landing_pad_name = function(data)
            if data and type(data.unit_number) == "number" then
                local landing_pad = Landingpad.from_unit_number(data.unit_number)
                if landing_pad then return landing_pad.name end
            end
        end,

-- allows cargo landing pad name to be changed
--/c remote.call("space-exploration", "set_landing_pad_name", {unit_number=76, name="[img=item/iron-ore] iron-ore"})
        set_landing_pad_name = function(data)
            if data and data.name and type(data.unit_number) == "number" then
                local landing_pad_name = tostring(data.name)
                local landing_pad = Landingpad.from_unit_number(data.unit_number)
                if landing_pad then
                    Landingpad.rename(landing_pad, landing_pad_name, true)
                    return true
                else
                    return false
                end
            end
            return false
        end,

--/c remote.call("space-exploration", "lock_player_respawn_location", {player = game.player, position = game.player.position, zone_name = "Nauvis"})
-- or
--/c remote.call("space-exploration", "lock_player_respawn_location", {player = game.player, position = game.player.position, surface_name = "nauvis"})
        lock_player_respawn_location = function(data)
          if data.player and data.player.valid and data.position and data.position.x and data.position.y then
            local playerdata = get_make_playerdata(data.player)
            if data.zone_name then
              local zone = Zone.from_name(data.zone_name)
              if not zone then game.print("Invalid zone name: "..data.zone_name) return end
              playerdata.lock_respawn = {zone_index = zone.index, position = data.position}
              game.print(data.player.name.." respawn location locked")
            elseif data.surface_name then
              if not game.get_surface(data.surface_name) then  game.print("Invalid surface name: "..data.surface_name) end
              playerdata.lock_respawn = {surface_name = data.surface_name, position = data.position}
              game.print(data.player.name.." respawn location locked")
            end
          end
        end,

--/c remote.call("space-exploration", "unlock_player_respawn_location", {player = game.player})
        unlock_player_respawn_location = function(data)
          if data.player and data.player.valid then
            local playerdata = get_make_playerdata(data.player)
            playerdata.lock_respawn = nil
          end
        end,

--/c remote.call("space-exploration", "get_player_character", {player = game.player})
        get_player_character = function(data)
          if data.player and data.player.valid then
            if data.player.character then return data.player.character end
            local playerdata = get_make_playerdata(data.player)
            return playerdata.character
          end
        end,

--/c remote.call("space-exploration", "spawn_small_resources", {surface = game.player.surface})
        spawn_small_resources = function(data)
          Zone.spawn_small_resources(data.surface)
        end,

--Can multiply resources on nauvis. It should not be used unless you are sure the available resources on nauvis are insufficient to set up a few moon mining bases.
--/c remote.call("space-exploration", "multiply_nauvis_resource", {surface = game.player.surface, resource_name = "iron-ore", multiplier=0.9})
        multiply_nauvis_resource = function(data)
          if data.multiplier > 0 and data.multiplier ~= 1 and data.surface then
            for _, entity in pairs(data.surface.find_entities_filtered{type = "resource", name=data.resource_name}) do
              local amount = math.ceil(entity.amount * data.multiplier)
              if amount > 0 then
                entity.amount = amount
              else
                entity.destroy()
              end
            end
          end
        end,

-- set the target zone to be a homeworld
--/c remote.call("space-exploration", "set_zone_as_homeworld", {zone_name = "Arendel", match_nauvis_seed = false, reset_surface = true})
        set_zone_as_homeworld = function(data)
          return Zone.set_zone_as_homeworld(data)
        end,

-- set a force's homeworld (needed for later functions) and sets their respawn location
--/c remote.call("space-exploration", "set_force_homeworld", {zone_name = "Arendel", force_name = "player-2", spawn_position = {x = 0, y = 0}, reset_discoveries = true})
        set_force_homeworld  = function(data)
          return set_force_homeworld(data)
        end,

-- reset a force's discovered locations.
--/c remote.call("space-exploration", "force_reset_discoveries", { force_name = "player-2"})
        force_reset_discoveries  = function(data)
          force_reset_discoveries(data.force_name)
        end,

--/c remote.call("space-exploration", "get_zone_index", {})
        get_zone_index = function(data)
          local zone_index = {}
          for i, zone in pairs(storage.zone_index) do
             table.insert(zone_index, Zone.export_zone(zone))
          end
          return zone_index
        end,

-- defines.events.se_on_zone_surface_created
        get_on_zone_surface_created_event = function() return util.get_custom_event_id("on_zone_surface_created") end,

--/c remote.call("space-exploration", "get_zone_from_name", {zone_name = "Nauvis"})
        get_zone_from_name = function(data) return Zone.export_zone(Zone.from_name(data.zone_name)) end,

--/c remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = 2})
        get_zone_from_zone_index = function(data) return Zone.export_zone(Zone.from_zone_index(data.zone_index)) end,

--/c remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = game.player.surface.index})
        get_zone_from_surface_index = function(data) return Zone.export_zone(Zone.from_surface_index(data.surface_index)) end,

--/c remote.call("space-exploration", "get_surface_type", {surface_index = game.player.surface.index})
        get_surface_type = function(data)
          local surface = game.get_surface(data.surface_index)

          local zone = Zone.from_surface(surface)
          if zone then return zone.type end

          local vault = Ancient.vault_from_surface(surface)
          if vault then return "vault" end

          if MapView.is_surface_starmap(surface) then return "starmap" end
        end,

--/c remote.call("space-exploration", "get_zone_icon", {zone_index = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = game.player.surface.index}).index})
        get_zone_icon = function(data) return Zone.get_icon(Zone.from_zone_index(data.zone_index)) end,

--/c remote.call("space-exploration", "get_zone_is_solid", {zone_index = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = game.player.surface.index}).index})
        get_zone_is_solid = function(data) return Zone.is_solid(Zone.from_zone_index(data.zone_index)) end,

--/c remote.call("space-exploration", "get_zone_is_space", {zone_index = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = game.player.surface.index}).index})
        get_zone_is_space = function(data) return Zone.is_space(Zone.from_zone_index(data.zone_index)) end,

--/c remote.call("space-exploration", "zone_get_surface", {zone_index =  remote.call("space-exploration", "get_zone_from_name", {zone_name = "Arendel"}).index})
        zone_get_surface = function(data) return Zone.get_surface(Zone.from_zone_index(data.zone_index)) end,

--/c remote.call("space-exploration", "zone_get_make_surface", {zone_index =  remote.call("space-exploration", "get_zone_from_name", {zone_name = "Arendel"}).index})
        zone_get_make_surface = function(data) return Zone.get_make_surface(Zone.from_zone_index(data.zone_index)) end,

--/c remote.call("space-exploration", "get_cargo_loss", {force = game.player.force})
        get_cargo_loss = function(data) return Launchpad.get_force_cargo_loss_modifier(data.force) end,

--/c remote.call("space-exploration", "get_reusability", {force = game.player.force})
        get_reusability = function(data) return Launchpad.get_reusability(data.force) end,

--/c remote.call("space-exploration", "get_survivability_loss", {force = game.player.force})
--/c game.print(remote.call("space-exploration", "get_survivability_loss", {force = game.player.force}))
        get_survivability_loss = function(data) return Launchpad.get_force_survivability_loss_modifier(data.force) end,

--/c game.print(remote.call("space-exploration", "get_satellites_launched", {force = game.player.force}))
        get_satellites_launched = function(data) return storage.forces[data.force.name].satellites_launched end,

--/c game.print(remote.call("space-exploration", "get_rockets_launched", {force = game.player.force}))
        get_rockets_launched = function(data) return storage.forces[data.force.name].cargo_rockets_launched end,

--/c game.print(serpent.line(remote.call("space-exploration", "get_solar_flares")))
        get_solar_flares = function(data)
          local solar_flares = {}
          for force_name, forcedata in pairs(storage.forces) do
            if forcedata.solar_flare then
              solar_flares[forcedata.solar_flare.zone.name] = solar_flares[forcedata.solar_flare.zone.name] or {}
              table.insert(solar_flares[forcedata.solar_flare.zone.name], {
                force = force_name,
                tick = forcedata.solar_flare.tick,
                peak_power = SolarFlare.base_power * SolarFlare.default_flare_power(forcedata.solar_flare.zone), -- In Watts
                energy = 160 * SolarFlare.default_flare_power(forcedata.solar_flare.zone) * 1000000000 -- In Joules
              })
            end
          end
          return solar_flares
        end,

--/c remote.call("space-exploration", "launch_satellite", {force_name = game.player.force.name, surface=game.player.surface, count=1})
        launch_satellite = function(data)
          local rep = data.count or 1
          for i = 1, rep, 1 do
            on_satellite_launched(data.force_name, data.surface)
          end
        end,

--/c remote.call("space-exploration", "build_satellite", {force_name = game.player.force.name})
        build_satellite = function(data) build_satellite(data.force_name) end,

--/c remote.call("space-exploration", "build_ruin", {ruin_name = "satellite2", surface_index = game.player.surface.index, position = game.player.position})
        build_ruin = function(data)
          Ruin.build(data)
        end,

--/c pl = game.player p = pl.position remote.call("space-exploration", "ruin_log_tiles", {capture_name = "temp", surface = pl.surface, registration_point = p, left_top = {p.x - 11, p.y - 11}, right_bottom = {p.x + 11, p.y + 11}})
        ruin_log_tiles = function(data)
          Ruin.log_tiles(data)
        end,

--/c pl = game.player p = pl.position remote.call("space-exploration", "ruin_log_entities", {capture_name = "temp", surface = pl.surface, registration_point = p, left_top = {p.x - 11, p.y - 11}, right_bottom = {p.x + 11, p.y + 11}})
        ruin_log_entities = function(data)
          Ruin.log_entities(data)
        end,

--/c remote.call("space-exploration", "replace_in_blueprint", {name="filename", blueprint="...", entities={{name="in-name", new_name="out-name", shift={0,0}}, tiles={["in_name"]="out-name"}})
        replace_in_blueprint = function(data)
          Blueprint.replace_in_blueprint(data)
        end,

--/c remote.call("space-exploration", "make_interburbulator", {position = {x=game.player.position.x, y = game.player.position.y - 10}, zone_index = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = game.player.surface.index}).index})
        make_interburbulator = function(data)
          Interburbulator.make_interburbulator(Zone.from_zone_index(data.zone_index), data.position)
        end,

--/c remote.call("space-exploration", "discover_zone", {force_name = game.player.force.name, surface=game.player.surface, zone_name="Arendel"})
        discover_zone = function(data)
          if not storage.forces[data.force_name].satellites_launched or storage.forces[data.force_name].satellites_launched == 0 then
            on_satellite_launched(data.force_name, data.surface)
            on_satellite_launched(data.force_name, data.surface)
          elseif storage.forces[data.force_name].satellites_launched == 1 then
            on_satellite_launched(data.force_name, data.surface)
          end
          Zone.discover(data.force_name, Zone.from_name(data.zone_name))
        end,

--/c remote.call("space-exploration", "discover_zones_by_type", {force_name = game.player.force.name, types={"star", "planet", "moon"}})
        discover_zones_by_type = function(data)
          for _, zone in pairs(storage.zone_index) do
            if util.table_contains(data.types, zone.type) then
              Zone.discover(data.force_name, zone)
            end
          end
        end,

--/c remote.call("space-exploration", "show_all_zones")
        show_all_zones = function(data)
          storage.debug_view_all_zones = true
        end,

--/c remote.call("space-exploration", "unshow_all_zones")
        unshow_all_zones = function(data)
          storage.debug_view_all_zones = false
        end,

--/c remote.call("space-exploration", "debug_set_global", {debug_view_all_zones = true})
--        debug_set_global = function(data)  for k, v in pairs(data) do  storage[k] = v end end,

--/c remote.call("space-exploration", "enqueue_weapon_delivery_cannon_artillery_request", {zone_name = "Nauvis", coordinates={x=0,y=0}, force_name="player", ammo_type="atomic-bomb"})
        enqueue_weapon_delivery_cannon_artillery_request = function(data)
          local zone = Zone.from_name(data.zone_name)
          local coordinates = data.coordinates
          local force_name = data.force_name
          local ammo_type = data.ammo_type
          if zone then
            DeliveryCannon.enqueue_target(zone, coordinates, force_name, ammo_type)
          end
        end,

--/c remote.call("space-exploration", "teleport_to_zone", {zone_name = "Nauvis", player=game.player})
        teleport_to_zone = function(data)
          local zone = Zone.from_name(data.zone_name)
          if zone and data.player then
            local surface = Zone.get_make_surface(zone)
            if data.player.character then
              teleport_character_to_surface(data.player.character, surface, {0,0})
            else
              data.player.teleport({0,0}, surface)
            end
          end
        end,

-- /c remote.call("space-exploration", "remote_view_is_active", {player=game.player})
        remote_view_is_active = function(data)
          if data.player then
            return RemoteView.is_active(data.player)
          end
        end,

-- /c remote.call("space-exploration", "remote_view_is_unlocked", {player=game.player})
        remote_view_is_unlocked = function(data)
          if data.player then
            return RemoteView.is_unlocked(data.player)
          end
        end,

-- /c remote.call("space-exploration", "remote_view_is_intersurface_unlocked", {player=game.player})
        remote_view_is_intersurface_unlocked = function(data)
          if data.player then
            return RemoteView.is_intersurface_unlocked_force(data.player)
          end
        end,

-- /c remote.call("space-exploration", "remote_view_start", {player=game.player, zone_name = "Nauvis", position={x=100,y=200}})
        remote_view_start = function(data)
          local zone = Zone.from_name(data.zone_name)
          if zone and data.player then
            RemoteView.start(data.player, zone, data.position)
          end
        end,

-- /c remote.call("space-exploration", "remote_view_stop", {player=game.player})
        remote_view_stop = function(data)
          if data.player then
            RemoteView.stop(data.player)
          end
        end,

--/c remote.call("space-exploration", "begin_meteor_shower", {target_entity = game.player, meteors = 10})
--/c remote.call("space-exploration", "begin_meteor_shower", {target_entity = game.player.selected or game.player})
--/c remote.call("space-exploration", "begin_meteor_shower", {zone_name = "Nauvis", position = {x=0,y=0}, range = 1, meteors = 100})
--/c for i = 1, 10 do remote.call("space-exploration", "begin_meteor_shower", {target_entity = game.player, meteors = 100}) end
        begin_meteor_shower = function(data)
          local entity = data.target_entity
          if entity then
            local zone = Zone.from_surface(entity.surface)
            if zone and zone.type ~= "spaceship" then
              ---@cast zone -SpaceshipType
              Meteor.begin_meteor_shower(zone, entity.position, data.range, data.meteors)
            end
          elseif data.zone_name then
            local zone = Zone.from_name(data.zone_name)
            if zone and zone.type ~= "spaceship" then
              ---@cast zone -SpaceshipType
              local position = data.position or {x = 0, y = 0}
              Meteor.begin_meteor_shower(zone, position, data.range, data.meteors)
            end
          end

        end,

--/c remote.call("space-exploration", "begin_solar_flare", {zone_name = "Nauvis", targeting="basic"})
        begin_solar_flare = function(data)
          if data.zone_name then
            local zone = Zone.from_name(data.zone_name)
            if zone and zone.type ~= "spaceship" then
              ---@cast zone -SpaceshipType
              SolarFlare.begin_flare(zone, data.targeting) -- zone, targeting, power_multiplier, delay, max_age
            end
          end

        end,


--/c remote.call("space-exploration", "fuel_rocket_silos", {})
        fuel_rocket_silos = function()
          for _, launch_pad in pairs(storage.rocket_launch_pads) do
            launch_pad.lua_fuel = (launch_pad.lua_fuel or 0) + 100000000
          end
        end,

--/c remote.call("space-exploration", "get_known_zones", {force_name = game.player.force.name})
        get_known_zones = function(data)
          if data.force_name and storage.forces[data.force_name] then
            -- return a list of known zone indexes.
            return storage.forces[data.force_name].zones_discovered
          end
        end,

--/c remote.call("space-exploration", "show_only_zones", {zone_names = {"Nauvis", "Sandro", "Zomble", "Foenestra", "Kamsta"}})
        show_only_zones = function(data)
          for force_name, force_data in pairs(storage.forces) do
            force_data.zones_discovered = {}
            force_data.zones_discovered_count = 0
            force_data.satellites_launched = 1
            for _, zone_name in pairs(data.zone_names) do
              local zone = Zone.from_name(zone_name)
              if zone then
                Zone.discover(force_name, zone, "Command")
              else
                game.print("Invalid zone name: "..zone_name)
              end
            end
          end
        end,

--/c remote.call("space-exploration", "rebuild_surface_index", {})
        rebuild_surface_index = Zone.rebuild_surface_index,

--/c remote.call("space-exploration", "rebuild_universe_resource_assignments", {})
        rebuild_universe_resource_assignments = Universe.rebuild_resource_assignments,

-- defines.events.se_on_cargo_rocket_launched
        get_on_cargo_rocket_launched_event = function() return util.get_custom_event_id("on_cargo_rocket_launched") end,

-- returns event ID for when cargo rocket land without a landing pad
-- defines.events.se_on_cargo_rocket_padless
        get_on_cargo_rocket_padless_event = function() return util.get_custom_event_id("on_cargo_rocket_padless") end,

-- defines.events.se_on_player_respawned
        get_on_player_respawned_event = function() return util.get_custom_event_id("on_player_respawned") end,

--/c remote.call("space-exploration", "robot_attrition_for_surface", {surface_index = surface_index})
        robot_attrition_for_surface = function(data)
          local surface_index = data.surface_index
          local zone = Zone.from_surface_index(surface_index)
          if zone then
            return Zone.get_bot_attrition(zone)
          else
            return data.default_rate or Zone.attrition_factor_setting -- Default value for non-zone surfaces
          end
        end,

--/c remote.call("space-exploration", "threat_for_surface", {surface_index = surface_index})
        threat_for_surface = function(data)
          local surface_index = data.surface_index
          local zone = Zone.from_surface_index(surface_index)
          if zone then
            return Zone.get_threat(zone)
          else
            return data.default_threat or 1.0 -- Default value for non-zone surfaces
          end
        end,

--/c remote.call("space-exploration", "hazards_for_surface", {surface_index = surface_index})
        hazards_for_surface = function(data)
          local surface_index = data.surface_index
          local zone = Zone.from_surface_index(surface_index)
          if zone then
            return Zone.get_hazards(zone)
          else
            return {}
          end
        end,

--/c remote.call("space-exploration", "solar_for_surface", {surface_index = surface_index})
        solar_for_surface = function(data)
          local surface_index = data.surface_index
          local zone = Zone.from_surface_index(surface_index)
          if zone then
            return Zone.get_solar(zone)
          else
            return data.default_solar or 1.0 -- Default value for non-zone surfaces
          end
        end,

--/c remote.call("space-exploration", "cancel_entity_creation", {entity=game.player.selected, player_index=1, message={"space-exploration.construction-denied"}}, event)
        cancel_entity_creation = function(data)
          cancel_entity_creation(data.entity, data.player_index, data.message, data)
          return
        end,

--/c remote.call("space-exploration", "update_zones_minimum_threat", { update_existing_surfaces = true})
        update_zones_minimum_threat = function(data)
          Universe.update_zones_minimum_threat(data.update_existing_surfaces)
        end,


-- Force in a missing planet
--/c remote.call("space-exploration", "force_add_planet_or_moon", { zone_name="Arendel"} )
        force_add_planet_or_moon = function(data)
          -- Exit if zone already exists
          if storage.zones_by_name[data.zone_name] then
            return {failed=true, message="zone-exists"}
          end

          -- Search for name in table of unassigned planets/moons
          local planet_or_moon
          for _, try_zone in pairs(UniverseRaw.unassigned_planets_or_moons) do
            if try_zone.name == data.zone_name then
              planet_or_moon = try_zone
              break
            end
          end
          if not planet_or_moon then
            return {failed=true, message="invalid-planet-or-moon-name"}
          end

          local star = nil
          local planet_count = 0

          -- Find a star with the lowest number of children (planets + asteroid belts)
          for _, try_star in pairs(storage.universe.stars) do
            if star == nil or #try_star.children < planet_count then
              star = try_star
              planet_count = #try_star.children
            end
          end

          local planet = nil
          local moon_count = 0

          -- Find a planet with the lowest number of moons
          for _, try_planet in pairs(star.children) do
            if try_planet.type == "planet" and (planet == nil or #try_planet.children < moon_count) then
              planet = try_planet
              moon_count = #try_planet.children
            end
          end

          local return_table

          -- Conditionally add as either a moon or planet
          if moon_count < 5 then
            local parent_planet = planet
            local new_moon = planet_or_moon
            table.insert(parent_planet.children, new_moon)

            new_moon.type = "moon"
            new_moon.special_type = "command"
            new_moon.parent = parent_planet
            new_moon.radius_multiplier = new_moon.radius_multiplier or 0.3
            new_moon.radius = (0.5 * parent_planet.radius + math.min(parent_planet.radius, Universe.planet_max_radius / 2)) * new_moon.radius_multiplier
            new_moon.index = #storage.zone_index + 1
            new_moon.climate = new_moon.climate or {}
            new_moon.seed = storage.universe_rng(4294967295)
            storage.zone_index[new_moon.index] = new_moon
            storage.zones_by_name[new_moon.name] = new_moon
            Log.debug_log("force-added new moon "..new_moon.name.." index: "..new_moon.index, "universe")

            new_moon.orbit = {
              type = "orbit",
              name = new_moon.name .. " Orbit",
              parent = new_moon,
              seed = storage.universe_rng(4294967295),
              index = #storage.zone_index + 1
            }
            storage.zone_index[new_moon.orbit.index] = new_moon.orbit
            storage.zones_by_name[new_moon.orbit.name] = new_moon.orbit
            Log.debug_log("force-added new moon orbit "..new_moon.orbit.name.." index: "..new_moon.orbit.index, "universe")

            Universe.planet_gravity_well_distribute(parent_planet)

            return_table = {type="moon", planet=planet.name, star=star.name, failed=false}
          else -- add to star
            local parent_star = star
            local new_planet = planet_or_moon
            table.insert(parent_star.children, new_planet)

            new_planet.type = "planet"
            new_planet.special_type = "command"
            new_planet.parent = parent_star
            new_planet.radius_multiplier = 0.4 + 0.6 * math.random() ^ 2
            new_planet.radius = Universe.planet_max_radius * new_planet.radius_multiplier
            new_planet.index = #storage.zone_index + 1
            new_planet.climate = new_planet.climate or {}
            new_planet.seed = storage.universe_rng(4294967295)
            new_planet.children = {}
            storage.zone_index[new_planet.index] = new_planet
            storage.zones_by_name[new_planet.name] = new_planet
            Log.debug_log("force-added new planet "..new_planet.name.." index: "..new_planet.index, "universe")

            new_planet.orbit = {
              type = "orbit",
              name = new_planet.name .. " Orbit",
              parent = new_planet,
              seed = storage.universe_rng(4294967295),
              index = #storage.zone_index + 1
            }
            storage.zone_index[new_planet.orbit.index] = new_planet.orbit
            storage.zones_by_name[new_planet.orbit.name] = new_planet.orbit
            Log.debug_log("force-added new planet orbit "..new_planet.orbit.name.." index: "..new_planet.orbit.index, "universe")

            Universe.star_gravity_well_distribute(parent_star)

            return_table = {type="planet", star=star.name, failed=false}
          end

          storage.resources_and_controls_compare_string = nil -- force udpate resources
          Universe.load_resource_data()
          Universe.set_hierarchy_values()

          return return_table
        end,

-- Quick setup multiplayer test
--/c remote.call("space-exploration", "setup_multiplayer_test", { force_name = "player-2", players = {game.player}, match_nauvis_seed = false})
        setup_multiplayer_test = function(data)

          -- make the force
          local force_name = data.force_name
          if not game.forces[force_name] then
            game.create_force(force_name)
          end
          if not game.forces[force_name] then
            game.print("Error creating force with name: "..(force_name or "nil")..", aborting.")
            return
          end

          -- select the planet
          local planet

          for _, star in pairs(storage.universe.stars) do
            if planet == nil then
              if star.special_type == "homesystem" then
                -- taken
              else
                for _, child in pairs(star.children) do
                  if child.type == "planet" and (not child.ruins) and (not child.interburbulator) and (not child.glyph) then
                    planet = child
                    game.print("Selected planet: "..child.name.." for " .. force_name ..  " homeworld.")
                    break
                  end
                end
              end
            end
          end
          if not planet then
            game.print("Error finding a planet, aborting.")
            return
          end

          -- change the player forces
          for _, player in pairs(data.players) do
            player.force = game.forces[force_name]
          end

          local match_nauvis_seed = data.match_nauvis_seed == nil and true or data.match_nauvis_seed
          -- make the homeworld
          Zone.set_zone_as_homeworld({ zone_name = planet.name, match_nauvis_seed = match_nauvis_seed, reset_surface = true})

          -- move the players
          local surface = Zone.get_make_surface(planet)
          for _, player in pairs(data.players) do
            if player.character then
              teleport_character_to_surface(player.character, surface, {0,0}) -- prevents overlapping players
            else
              player.teleport({0,0}, surface)
            end
          end

          -- assign the force to the homeworld (a homeworld can have multiple forces)
          -- also resets discoveries
          set_force_homeworld({zone_name = planet.name, force_name = force_name, spawn_position = {x = 0, y = 0}, reset_discoveries = true})

          Universe.set_hierarchy_values()

          -- TODO: trigger AAI crash sequence?

        end,

--/c remote.call("space-exploration", "log_map_gen", {})
        log_map_gen = Log.log_map_gen,
        log_global = Log.log_global,
        log_universe_simplified = Log.log_universe_simplified,
        log_universe = Log.log_universe,
        log_forces = Log.log_forces,
        log_spaceships = Log.log_spaceships,

-- informatron implementation
        informatron_menu = function(data)
          return Informatron.menu(data.player_index)
        end,

        informatron_page_content = function(data)
          return Informatron.page_content(data.page_name, data.player_index, data.element)
        end,

        informatron_page_content_update = function(data)
          return Informatron.page_content_update(data.page_name, data.player_index, data.element)
        end,

-- jetpack implementation
        on_character_swapped = function(event)
          if event.new_character and event.old_character then
            local player = event.new_character.player
            if player then
              local playerdata = get_make_playerdata(player)
              if playerdata.character == event.old_character then
                playerdata.character = event.new_character
              end
              playerdata.preserve_buffer_next_armor_change = true
            else
              for _, playerdata in pairs(storage.playerdata) do
                if playerdata.character == event.old_character then
                  playerdata.character = event.new_character
                  playerdata.preserve_buffer_next_armor_change = true
                end
              end
            end
          end
        end,

-- AAI vehicles miner vehicle
        aai_vehicles_miner_disallowed_resource_categories = function(event) return {mod_prefix .. "core-mining"} end,

-- AAI programmable vehicles
        aai_programmable_vehicles_non_combat_whitelist = function(event) return {
          Capsule.name_space_capsule,
          Capsule.name_space_capsule_container,
          Capsule.name_space_capsule_vehicle,
          Capsule.name_space_capsule_scorched,
          Capsule.name_space_capsule_scorched_container,
          Capsule.name_space_capsule_scorched_vehicle,
          Launchpad.name_cargo_pod,
          Spectator.name_seat,
          "character",
          "character-jetpack"
        } end,

        ---Other mods can call this function after they activate an entity if they want that entity
        ---to be revalidated based on SE's becaon overload rules.
        ---@param data {mod: string, entity: LuaEntity, ignore_count?: uint}
        on_entity_activated = function(data)
          if type(data) ~= "table" then return end
          if data.mod ~= "space-exploration" and data.entity and data.entity.valid then
            Beacon.validate_entity(data.entity, data.ignore_count)
          end
        end,

-- Milestones compatibility
        milestones_presets = Milestones.milestones_presets,

-- Better Victory Screen
--[==[ **FIXME** temporarily disabled for 2.0
force.item_production_statistics is now force.get_item_production_statistics(surface)
API request to get global statistcs: https://forums.factorio.com/viewtopic.php?f=28&t=116080

        ["better-victory-screen-statistics"] = function(winning_force, forces)

          -- Get all names ahead of time
          local core_names = {}
          for name, _ in pairs(prototypes.get_entity_filtered({{filter = "type", type = "resource"}})) do
            if string.starts(name, mod_prefix.."core-fragment") and not string.ends(name, "sealed") then
              table.insert(core_names, name)
            end
          end

          local stats_by_force = {}
          local stats_by_player = {}
          for _, force_name in pairs(get_player_forces()) do
            local force = game.forces[force_name]
            local forcedata = storage.forces[force_name]
            local item_prod_stats = force.item_production_statistics
            local kill_stats = force.kill_count_statistics

            -- Spaceships
            local spaceship_count = 0
            local spaceship_max_speed = 0
            for _, spaceship in pairs(storage.spaceships) do
              if spaceship.force_name == force_name then
                spaceship_count = spaceship_count + 1
                if spaceship.max_speed and spaceship.max_speed > spaceship_max_speed then
                  spaceship_max_speed = spaceship.max_speed
                end
              end
            end

            -- Zones
            local zones_plagued = 0
            local zones_colonized = 0
            for zone_index, zone in pairs(storage.zone_index) do
              local force_assets = Zone.get_force_assets(force_name, zone_index)
              if zone.plague_used then
                zones_plagued = zones_plagued + 1
              end
              if force_assets and next(force_assets.rocket_launch_pad_names) then
                zones_colonized = zones_colonized + 1
              end
            end

            -- Modules
            local max_module_tier = 9
            local max_tier_module_count
            while max_module_tier > 0 do
              local suffix = max_module_tier > 1 and "-"..max_module_tier or ""
              max_tier_module_count = util.get_production_count(item_prod_stats, {"productivity-module" .. suffix, "speed-module" .. suffix, "efficiency-module" .. suffix})
              if max_tier_module_count > 0 then
                break
              end
              max_module_tier = max_module_tier - 1
            end

            -- Production graph stats
            local arcosphere_count = util.get_production_count(item_prod_stats, {mod_prefix .. "arcosphere"})
            local core_count = util.get_production_count(item_prod_stats, core_names)

            -- Technically counts capsules still in cannons, but close enough
            local delivery_cannon_capsule_count = util.get_consumption_count(item_prod_stats, {mod_prefix .. "delivery-cannon-capsule"})
            local weapon_cannon_capsule_count = util.get_consumption_count(item_prod_stats, {mod_prefix .. "delivery-cannon-weapon-capsule"})
            weapon_cannon_capsule_count = weapon_cannon_capsule_count + util.get_production_count(item_prod_stats, {mod_prefix .. "iridium-piledriver"})

            local meteor_kill_count = util.get_production_count(kill_stats, {mod_prefix .. "static-meteor-01"})
            local asteroid_kill_count = util.get_production_count(kill_stats, {mod_prefix .. "spaceship-obstacle-small-vehicle", mod_prefix .. "spaceship-obstacle-medium-vehicle", mod_prefix .. "spaceship-obstacle-large-vehicle"})

            -- Final table
            stats_by_force[force_name] = {
              ["space-exploration"] = { order = "a", stats = {
                ["delivery-cannon-shots"] =        { value = delivery_cannon_capsule_count,    order="a" },
                ["cargo-rockets-launched"] =       { value = forcedata.cargo_rockets_launched, order="b" },
                ["spaceship-count"] =              { value = spaceship_count,                  order="c" },
                ["spaceship-max-speed-achieved"] = { value = spaceship_max_speed,              order="d", has_tooltip=true },
                ["cores-mined"] =                  { value = core_count,                       order="e" },
                ["arcospheres-collected"] =        { value = arcosphere_count,                 order="f" },
                ["max-tier-modules-made"] =        { value = max_tier_module_count,            order="g", localised_name={"bvs-stats.max-tier-modules-made", max_module_tier} },
                -- zones-visited (player stat)
                ["zones-colonized"] =              { value = zones_colonized,                  order="i", has_tooltip=true },
                ["zones-plagued"] =                { value = zones_plagued,                    order="j" },
                ["weapon-delivery-cannon-shots"] = { value = weapon_cannon_capsule_count,      order="k" },
                ["meteors-destroyed"] =            { value = meteor_kill_count,                order="l" },
                ["asteroids-destroyed"] =          { value = asteroid_kill_count,              order="m" },
              }}
            }

            for player_name, player in pairs(force.players) do
              local playerdata = get_make_playerdata(player)

              local zones_visited = playerdata.visited_zone and table_size(playerdata.visited_zone) or 0

              stats_by_player[player_name] = {
                ["space-exploration"] = { order = "a", stats = {
                  ["zones-visited"] = { value = zones_visited, order="h" },
                }}
              }
            end
          end

          return {
            by_force = stats_by_force,
            by_player = stats_by_player,
          }
        end,
        ]==]
      }
)

--[[
Below are remote interface functions that SE will search for in _other_ mods and execute when
appropriate.

---on_entity_activated
---
---This function will get called right after an entity is enabled, after having been disabled due
---to beacon overload. No return value is expected.
---@param args table {entity=<LuaEntity>, mod="space-exploration"}
on_entity_activated = function(args)
  if entity.valid and entity.unit_number == ENTITY_THAT_SHOULD_REMAIN_INACTIVE.unit_number then
    entity.active = false
  end
end

---space_exploration_delete_surface
---
---This function will get called right before a surface belonging to a zone gets deleted by a player
---using the Universe Explorer. It can be used to prevent a surface that is important to your mod
---from getting deleted by the player. This will only get called if the surface has passed all the
---internal checks in SE that would allow it to be deleted. Note that the message you return will
---only be shown to the player if deletion was forbidden by your mod.
---
---The `event` table passed will contain the following:
---surface_index uint Index of surface about to be deleted
---zone_index uint SE zone index
---zone_name string SE zone name
---player_index uint|nil _Optional_, Index of player who initiated surface deletion, if any
---
---@return table? result {allow_delete=<boolean>, message=<LocalisedString|string>}
space_exploration_delete_surface = function(event)
  if event.surface_index == IMPORTANT_SURFACE.index then
    return {
      allow_delete=false,
      message={"mod-name.surface-deletion-forbidden"}
    }
  end
end
]]
