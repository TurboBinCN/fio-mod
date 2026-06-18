SimulationSpaceship = require('simulation-spaceship')

remote.add_interface("space-exploration-menu-simulations", {

  -- Allow placing space tiles and buildings on Nauvis
  -- /c remote.call("space-exploration-menu-simulations", "remove_placement_restrictions")
  remove_placement_restrictions = function(data)
    storage.remove_placement_restrictions = true
    game.print("Placement restrictions removed")
  end,

  -- /c remote.call("space-exploration-menu-simulations", "clean_global")
  clean_global = function(data)
    storage.spaceships = {}
    storage.delivery_cannons = {}
    storage.delivery_cannon_payloads = {}
    storage.delivery_cannon_queues = {}
    storage.rocket_launch_pads = {}
    storage.meteor_defences = {}
    storage.meteor_point_defences = {}
    storage.meteor_schedule = {}
    storage.tick_tasks = {}
    local zone = storage.zones_by_name.Nauvis
    zone.core_seam_resources = nil
  end,

  -- Cleanup menu simulation save files when creating new menu simulations
  -- /c remote.call("space-exploration-menu-simulations", "cleanup_menu_simulation")
  -- /c remote.call("space-exploration-menu-simulations", "cleanup_menu_simulation", {top_left_chunk = {x=-4, y=-3}, bottom_right_chunk = {x=3, y=2}})
  cleanup_menu_simulation = function(data)
    local surface = game.surfaces.nauvis
    if not data then
      data = {}
    end
    local chunks_width = 8
    local chunks_height = 6
    local top_left_chunk = data.top_left_chunk or {x = -chunks_width/2, y = -chunks_height/2}
    local bottom_right_chunk = data.bottom_right_chunk or {x = chunks_width/2 -1, y = chunks_height/2 -1}
    log("top left chunk: " .. serpent.line(top_left_chunk))
    log("bottom right chunk: " .. serpent.line(bottom_right_chunk))

    -- Set map limits to prevent chunks regenerating
    local map_gen_settings = game.surfaces.nauvis.map_gen_settings
    map_gen_settings.width = 1
    map_gen_settings.height = 1
    game.surfaces.nauvis.map_gen_settings = map_gen_settings

    -- Delete all unused chunks
    local in_area = function(c)
      return top_left_chunk.x <= c.x and c.x <= bottom_right_chunk.x and
             top_left_chunk.y <= c.y and c.y <= bottom_right_chunk.y
    end

    for chunk in surface.get_chunks() do
      if not in_area(chunk) then
        log("deleting chunk x:" .. chunk.x .. ", y:" .. chunk.y)
        surface.delete_chunk{x = chunk.x, y = chunk.y}
      end
    end

    -- Delete all other surfaces
    for surface_name, game_surface in pairs(game.surfaces) do
      if surface_name ~= "nauvis" then
        log("deleting surface:" .. surface_name)
        game.delete_surface(game_surface)
      end
    end

    -- Clear inventories
    game.player.get_inventory(defines.inventory.character_main).clear()
    game.player.get_inventory(defines.inventory.editor_main).clear()

    -- Clear quickbar filters
    for i=1, 100 do
      game.player.set_quick_bar_slot(i, nil)
    end

    -- Delete chat
    game.player.clear_console()
  end,

  -- /c remote.call("space-exploration-menu-simulations", "clear_chunks", {top_left_chunk = {x=-4, y=-4}, bottom_right_chunk = {x=3, y=-4}})
  clear_chunks = function(data)
    local surface = game.surfaces.nauvis
    local top_left_chunk = data.top_left_chunk
    local bottom_right_chunk = data.bottom_right_chunk
    log("top left chunk: " .. serpent.line(top_left_chunk))
    log("bottom right chunk: " .. serpent.line(bottom_right_chunk))

    -- Delete all unused chunks
    local in_area = function(c)
      return top_left_chunk.x <= c.x and c.x <= bottom_right_chunk.x and
             top_left_chunk.y <= c.y and c.y <= bottom_right_chunk.y
    end

    for chunk in surface.get_chunks() do
      if in_area(chunk) then
        log("deleting chunk x:" .. chunk.x .. ", y:" .. chunk.y)
        surface.delete_chunk{x = chunk.x, y = chunk.y}
      end
    end
  end,

  -- /c remote.call("space-exploration-menu-simulations", "find_and_enable_cannon", {position = {0, 0}, tags = {...}})
  find_and_enable_cannon = function(data)
    local entity = game.surfaces.nauvis.find_entities_filtered{
      name = {"se-delivery-cannon", "se-delivery-cannon-weapon"},
      position = data.position,
      limit = 1
    }[1]

    DeliveryCannon.on_entity_created({entity = entity})
    DeliveryCannon.deserialize(entity, data.tags)
  end,

  -- /c remote.call("space-exploration-menu-simulations", "find_and_create_simulation_spaceship", {position = {0, 0}})
  find_and_create_simulation_spaceship = function(data)
    local console_entity = game.surfaces.nauvis.find_entities_filtered{
      name = {"se-spaceship-console"},
      position = data.position,
      limit = 1
    }[1]

    SimulationSpaceship.create_simulation_spaceship(console_entity)
  end,

    -- /c remote.call("space-exploration-menu-simulations", "fly_simulation_spaceship", {spaceship_index_1 = 1, spaceship_index_2 = 2})
  merge_simulation_spaceships = function(data)
    local spaceship1 = storage.simulation_spaceships[data.spaceship_index_1]
    local spaceship2 = storage.simulation_spaceships[data.spaceship_index_2]
    if not spaceship1 or not spaceship2 then
      log("Couldn't find spaceship to merge! " .. serpent.line(storage.simulation_spaceships))
      return
    end

    SimulationSpaceship.merge_spaceships(spaceship1, spaceship2)
  end,

  -- /c remote.call("space-exploration-menu-simulations", "enable_simulation_spaceship_flying")
  enable_simulation_spaceship_flying = function()
    Event.addListener(defines.events.on_tick, SimulationSpaceship.on_tick)
  end,

  -- /c remote.call("space-exploration-menu-simulations", "fly_simulation_spaceship", {spaceship_index = 1, starting_speed = 60, target_speed = 60})
  fly_simulation_spaceship = function(data)
    local spaceship = storage.simulation_spaceships[data.spaceship_index]
    if not spaceship then
      log("Couldn't find spaceship to fly! " .. serpent.line(storage.simulation_spaceships))
      return
    end
    SimulationSpaceship.fly(spaceship, data.starting_speed, data.target_speed)
  end,

  -- remote.call("space-exploration-menu-simulations", "make_launchpad_journey_task", {position = {0, 0}, launch_timer = nil, contents = {{"spidertron", count = 1}}})
  make_launchpad_journey_task = function(data)
    local tick_task = new_tick_task("launchpad-journey") --[[@as CargoRocketTickTask]]
    tick_task.struct = nil
    tick_task.force_name = "player"
    tick_task.rocket_entity = nil
    tick_task.launch_timer = data.launch_timer
    tick_task.delta_v = 0
    tick_task.seated_passengers = {}

    local destination_zone = Zone.from_name("Nauvis") --[[@as PlanetType]]
    local landing_pad

    if data.landing_pad_position then
    local landing_pad_entity = game.surfaces.nauvis.find_entities_filtered{name = "cargo-landing-pad", limit = 1, position = data.landing_pad_position}[1]
    landing_pad = {
        type = Landingpad.name_rocket_landing_pad,
        valid = true,
        force_name = "player",
        unit_number = landing_pad_entity.unit_number,
        container = landing_pad_entity,
        name = "Default",
        zone = destination_zone
      }
    end

    tick_task.launching_to_destination = {
      zone = destination_zone,
      position = data.landing_pad_position or data.position,
      landing_pad = landing_pad,
      fixed_pod_offset = data.fixed_pod_offset
    }

    tick_task.launched_inventory = game.create_inventory(500)
    if data.spidertron then
      data.spidertron.mine{inventory=tick_task.launched_inventory} -- Inserts the ItemWithEntityData
    end
    for _, content in pairs(data.contents) do
      tick_task.launched_inventory.insert(content)
    end
    tick_task.launched_contents = tick_task.launched_inventory.get_contents()
  end
})
