local Spaceship = {}

Spaceship.name_spaceship_console = mod_prefix .. "spaceship-console"
Spaceship.name_spaceship_console_output = mod_prefix .. "spaceship-console-output"
Spaceship.console_output_offset = {x = 1.5, y = -1}

Spaceship.engine_efficiency_blocked = 0.60
Spaceship.engine_efficiency_unblocked = 1
Spaceship.engine_efficiency_unblocked_taper = 20
Spaceship.engine_efficiency_side = 0.01
Spaceship.engines = {
  [mod_prefix .. "spaceship-rocket-engine"] = { name = mod_prefix .. "spaceship-rocket-engine", thrust = 100 / 5, max_energy = 1837, smoke_trigger = mod_prefix .. "spaceship-engine-smoke" },
  [mod_prefix .. "spaceship-ion-engine"] = { name = mod_prefix .. "spaceship-ion-engine", thrust = 250 / 5, max_energy = 183700, smoke_trigger = mod_prefix .. "spaceship-engine-smoke" },
  [mod_prefix .. "spaceship-antimatter-engine"]= { name = mod_prefix .. "spaceship-antimatter-engine", thrust = 500 / 5, max_energy = 18370, smoke_trigger = mod_prefix .. "spaceship-engine-smoke" }
}
Spaceship.names_engines = {}
Spaceship.names_engines_map = {}
Spaceship.names_smoke_trigger = {}

Spaceship.booster_types = Shared.spaceship_booster_types

Spaceship.names_booster_tanks = {}
Spaceship.names_planet_booster_tanks = {}
for booster_name, booster_config in pairs(Spaceship.booster_types) do
  table.insert(Spaceship.names_booster_tanks, booster_name)
  if not booster_config.only_in_space then
    table.insert(Spaceship.names_planet_booster_tanks, booster_name)
  end
end

Spaceship.names_spaceship_floors = {mod_prefix .. "spaceship-floor"}
Spaceship.names_spaceship_floors_map = core_util.list_to_map(Spaceship.names_spaceship_floors)
Spaceship.names_spaceship_walls = {mod_prefix .. "spaceship-wall"}
Spaceship.names_spaceship_walls_map = core_util.list_to_map(Spaceship.names_spaceship_walls)
Spaceship.names_spaceship_gates = {mod_prefix .. "spaceship-gate"}
Spaceship.names_spaceship_gates_map = core_util.list_to_map(Spaceship.names_spaceship_gates)
Spaceship.names_spaceship_bulkheads = {
  mod_prefix .. "spaceship-wall",
  mod_prefix .. "spaceship-gate",
  SpaceshipClamp.name_spaceship_clamp_keep,
}
for _, engine in pairs(Spaceship.engines) do
  table.insert(Spaceship.names_engines, engine.name)
  Spaceship.names_engines_map[engine.name] = true
  table.insert(Spaceship.names_spaceship_bulkheads, engine.name)
  if engine.smoke_trigger then
    table.insert(Spaceship.names_smoke_trigger, engine.smoke_trigger)
  end
end
Spaceship.names_spaceship_bulkheads_map = core_util.list_to_map(Spaceship.names_spaceship_bulkheads)

Spaceship.signal_for_own_spaceship_id = {type = "item", name = Spaceship.name_spaceship_console, quality="normal"}
Spaceship.signal_for_destination_spaceship = {type = "virtual", name = mod_prefix.."spaceship", quality="normal"}
Spaceship.signal_for_speed = {type = "virtual", name = "signal-speed", quality="normal"}
Spaceship.signal_for_distance = {type = "virtual", name = "signal-distance", quality="normal"}
Spaceship.signal_for_launch = {type = "virtual", name = mod_prefix.."spaceship-launch"}
Spaceship.signal_for_anchor_using_left = {type = "virtual", name = mod_prefix.."anchor-using-left-clamp"}
Spaceship.signal_for_anchor_using_right = {type = "virtual", name = mod_prefix.."anchor-using-right-clamp"}
Spaceship.signal_for_anchor_to_left = {type = "virtual", name = mod_prefix.."anchor-to-left-clamp"}
Spaceship.signal_for_anchor_to_right = {type = "virtual", name = mod_prefix.."anchor-to-right-clamp"}

Spaceship.energy_per_launch_integrity_delta_v = 135 * 1000
Spaceship.tick_interval_density = 60 -- must coincide with %60
Spaceship.tick_interval_move = 20 -- must coincide with %60
Spaceship.tick_interval_anchor = 5 -- must coincide with %60
Spaceship.tick_interval_gui = 5 -- must coincide with %60
Spaceship.tick_interval_output = 60

Spaceship.tick_max_await = 60 * 10 -- 10 seconds

Spaceship.types_to_restore = {-- after surface change/area clone
  "inserter",
  "pump",
  --"transport-belt" -- entity.active does not work on belts
}

-- Note: production machines should NOT be included as some are supposed to be disabled on specific surfaces.
Spaceship.time_to_restore = 1

Spaceship.particle_speed_power = 0.75 -- 0.5 would be sqrt, 0 is static, 1 is linear with speed.
Spaceship.space_drag = 0.00135
Spaceship.minimum_impulse = 1/100
Spaceship.minimum_mass = 100
Spaceship.speed_taper = 250
Spaceship.travel_speed_multiplier = 1/200
Spaceship.integrity_pulse_interval = 60 * 60 * 10

--[[
change to:
{
  outer = 0 or 1. outer skin of tiles including diagonals
  floor = 0 or 1, has floor otherwise exterior
  exposed = 0 for contained, or higher for any tile exposed to space
  wall = 0 or 1, walls only
  bulkhead = 0 or 1, any bulkhead
  connection nil or distance to console.
}

]]--


--[[
console sends out a pule over all connected spaceship tiles (with a max based on tech)
then consider all tiles with wall or gate.
divide tiles into groups, ones that touch the outside are not part of the ship.
]]--

Spaceship.names = {
  "Abaddon", "Ackbar", "Aegis", "Albatross", "Alchemist", "Albion", "Alexander",
    "Angler", "Apparition", "ArchAngel", "Assassin", "Avenger", "Axe",
  "Bade", "Bardiche", "Battleth", "Blackbird", "Bounty Hunter", "Breaker",
    "Brigandine","Bullfinch", "Buzzard",
  "Cartographer", "Catface", "Calamari", "Canary", "Caravel", "Carrak", "Citadel", "Clockwerk",
    "Chimera", "Coot", "Cormorant", "Crane", "Crossbill", "Crow", "Cuckoo",
  "Darkstar", "Dauntless", "Desby", "Dragon", "Drake", "Dream", "Doombringer",
    "Dolphin", "Devourer", "Dunn",
  "Eagle", "Earthshaker", "Earl Grey", "Egret", "Eider", "Ember", "Enigma", "Eris", "Excalibur",
  "Falcon", "Falx", "Feral Pigeon", "Firecrest", "Firefly", "Flying Duckman",
    "Fountain", "Fulmar",
  "Gadwall", "Gannet", "Garganey", "Gigantosaurus", "Ghast", "Ghoul", "Ghost",
    "Glaive", "Goldcrest", "Goldeneye", "Goldfinch", "Goosander", "Goose",
    "Goshawk", "Grasshopper", "Greenfinch", "Griffon", "Grouse", "Guillemot",
  "Halberd", "Hammer", "Hammerhead", "Harrier", "Hawk", "Harking", "Heron", "Hippogryph", "Honeybadger", "Honeybear",
  "Iron Cordon", "Ingot", "Intrepid", "Invoker", "Isabella",
  "Jack Snipe", "Jackdaw", "Jay",
  "Kamsta", "Katherine", "Kestrel", "Kingfisher", "Kite", "Knight", "Kraken",
  "Lapwing", "Lance", "Lancer", "Lick", "Linnet", "Lucas",
  "Magi", "Magpie", "Mallard",  "Mangonel", "Medusa", "Memento", "Merlin",
    "Mistress", "Mocking Jay", "Monstrosity", "Moorhen", "Musk",
  "Naga", "Narwhal", "Nebulon", "Nemesis", "Newton", "Nexela", "Nial", "Nicholas",
    "Nightjar", "Nissa", "Nightingale", "Night Stalker",
  "Oracle", "Orca", "Ostricth", "Outrider", "Owl",
  "Partridge", "Pangolin", "Penguin", "Peregrine", "Petrel", "Phantom",
    "Pheasant", "Phoenix", "Piccard", "Pintail", "Pioneer",
    "Pipit", "Plover", "Prophet", "Prowler", "Pochard", "Puffin",
  "Quail",
  "Radiance", "Raptor", "Raven", "Razor", "Razorbill", "Red Kite", "Redshank",
    "Redstart", "Redwing", "Requiem",
    "Riccardo", "Robin", "Roc", "Rook", "Rossi", "Rogue", "Ruff",
  "Sanderling", "Sawfish", "Scythe", "Seraph", "Serenity", "Sickle", "Shadow",
    "Shag", "Sharknado", "Shelduck", "Sherrif", "Shoveler", "Sin Eater", "Siren",
    "Siskin",  "Skylark", "Skyshark", "Skywalker", "Skywrath", "Smew", "Snek",
    "Snipe",  "Sparrowhawk", "Spear", "Spectre", "Spinosaur", "Spynx",
    "Starchaser", "Starling", "Stonechat", "Swallow", "Swan", "Swift", "Swordfish",
  "Tachyon", "Tali", "Tantive", "Teal", "Templar", "Terrorblade", "Tesla", "Thanatos",
    "Throne", "Thrush", "Tigress", "Tin Can", "Titan", "Trebuchet",
    "Trimaran", "Turnstone", "Turing", "Tusk", "Twite",
  "Ursa", "Undertaker", "Undying Dodo", "Underlord",
  "Vengeance", "Viper", "Virtue", "Visage", "Void Hunter", "Volt", "Vulture",
  "Wagtail", "Warbird", "Warbler", "Warcry", "Warden", "Warlock", "Warlord", "Warrunner",
    "Waxwing", "Weaver", "Wheatear", "Whimbrel", "Whinchat", "Whitestar",
    "Wigeon", "Windranger", "Woodcock", "Wraith", "Wrath", "Wren", "Wyvern", "Wyrm",
  "Xena", "Xenon", "Xylem",
  "Yacht", "Yellowhammer", "Yettie",
  "Zenith", "Zilla", "Zombie", "Zweihander"
}

--[[========================================================================================
Calculate some values on load
]]--

---@type table<string, double>
Spaceship.cache_fluid_fuel_values = {}
for prototype_name, prototype in pairs(prototypes.fluid) do
  Spaceship.cache_fluid_fuel_values[prototype_name] = prototype.fuel_value
end

--[[========================================================================================
Helper functions for getting spaceship references.
]]--

---@param spaceship_index uint
---@return SpaceshipType?
function Spaceship.from_index(spaceship_index)
  return storage.spaceships[tonumber(spaceship_index)]
end

---@param entity LuaEntity
---@return SpaceshipType?
function Spaceship.from_entity(entity)
  if not entity then return end
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.console and spaceship.console.valid and spaceship.console.unit_number == entity.unit_number then
      return spaceship
    end
  end
end

---@param name string
---@return SpaceshipType?
function Spaceship.from_name(name)
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.name == name then
      return spaceship
    end
  end
end

---@param surface_index uint
---@return SpaceshipType?
function Spaceship.from_own_surface_index(surface_index) -- can't be a zone
  if storage.simulation_spaceships then
    for _, spaceship in pairs(storage.simulation_spaceships) do
      if spaceship.own_surface.index == surface_index then
        return spaceship
      end
    end
  end
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.own_surface and spaceship.own_surface.index == surface_index then
      return spaceship
    end
  end
end

---@param surface LuaSurface
---@param position MapPosition
---@return SpaceshipType?
function Spaceship.from_surface_position(surface, position)
  local x = math.floor(position.x or position[1])
  local y = math.floor(position.y or position[2])
  -- TODO allow multiple spaceships per surface
  for _, spaceship in pairs(storage.spaceships) do
    if spaceship.own_surface then
      if spaceship.own_surface.index == surface.index then
        return spaceship
      end
    elseif spaceship.console and spaceship.console.valid and spaceship.console.surface == surface then
      -- check tiles
      if spaceship.known_tiles and spaceship.known_tiles[x] and spaceship.known_tiles[x][y] and
        (spaceship.known_tiles[x][y] == "floor_console_connected"
        or spaceship.known_tiles[x][y] == "bulkhead_console_connected") then
          return spaceship
      end
    end
  end
end

--[[========================================================================================
Helper functions for spaceship states
]]

---Returns true if the spaceship is flying and not in the processing
---of landing
---@param spaceship SpaceshipType
---@return boolean
function Spaceship.is_on_own_surface(spaceship)
  return spaceship.on_own_surface == true and not spaceship.awaiting_requests
end

---@param spaceship SpaceshipType
---@return boolean
function Spaceship.is_in_invalid_zone(spaceship)
  return spaceship.zone_index == nil and spaceship.space_distortion == nil and spaceship.stellar_position == nil
end

---Returns whether a given position is within a ship's "console-connected" floor bounds.
---@param position MapPosition Position to evaluate
---@param spaceship SpaceshipType Spaceship to check against
---@param interior_only? boolean If false, also allows `bulkhead_console_connected` tiles. Defaults to true.
---@return boolean
function Spaceship.is_position_on_spaceship(position, spaceship, interior_only)
  local x = math.floor((position.x or position[1]))
  local y = math.floor((position.y or position[2]))
  local value = spaceship.known_tiles[x] and spaceship.known_tiles[x][y]

  return (value == "floor_console_connected" or
    (interior_only == false and value == "bulkhead_console_connected"))
end

---@param spaceship SpaceshipType
---@param name string
function Spaceship.rename(spaceship, name)
  spaceship.name = name
  if spaceship.own_surface and spaceship.own_surface.valid then
    spaceship.own_surface.localised_name = Zone.get_default_localised_name_for_surface(spaceship)
  end
end

--[[========================================================================================
Helper functions for getting the surfaces a spaceship cares about.
]]

---@param spaceship SpaceshipType
---@return LuaSurface?
function Spaceship.get_own_surface(spaceship)
  local surface = spaceship.own_surface
  if surface and surface.valid then return surface end

  if spaceship.own_surface_name then -- Used for custom spaceship surfaces e.g. simulations
    spaceship.own_surface = game.get_surface(spaceship.own_surface_name)
  else
    spaceship.own_surface = game.get_surface("spaceship-"..spaceship.index)
  end

  return spaceship.own_surface
end

---@param spaceship SpaceshipType
---@return LuaSurface
function Spaceship.get_current_surface(spaceship)

  -- During transitions the most accurate place to look is
  -- where the console is currently.
  if spaceship.console and spaceship.console.valid then
    return spaceship.console.surface
  end

  -- Otherwise we use the data stored on the spacehip, which
  -- might be outdated in some rare situations, like just after cloning.

  if spaceship.zone_index then
    -- Spaceship has landed somewhere
    local zone = Zone.from_zone_index(spaceship.zone_index)
    if zone then
      return Zone.get_make_surface(zone)
    end
  end

  -- Spaceship is flying
  --TODO: This function can return nil, but not all callers expect that.
  return Spaceship.get_own_surface(spaceship)
end

--[[
Computes the cost (in fuel) of launching a spaceship from its current surface.
]]

---@param spaceship SpaceshipType
---@return number?
function Spaceship.get_launch_energy_cost(spaceship)
  if spaceship.zone_index and spaceship.integrity_stress then
    local zone = Zone.from_zone_index(spaceship.zone_index)
    if zone then
      if Zone.is_space(zone) then
        ---@cast zone -PlanetType, -MoonType
        return 250 * spaceship.integrity_stress * Spaceship.energy_per_launch_integrity_delta_v
      end
      ---@cast zone PlanetType|MoonType
      local delta_v = Zone.get_launch_delta_v(zone)
      local energy_cost = delta_v * spaceship.integrity_stress * Spaceship.energy_per_launch_integrity_delta_v
      return energy_cost
    end
  end
end

---Computes the launch energy needed for a given spaceship, updating its `launch_energy` property.
---Returns launch energy as well as an array of all the booster tank lua entities on board.
---@param spaceship SpaceshipType Spaceship data
---@param spaceship_is_attempting_launch boolean? True if the spaceship is busy launching
---@return float launch_energy Spaceship launch energy
---@return table<uint64, {entity:LuaEntity, amount:number, fluid_name:string, fuel_value:number}> tanks_meta_data
---@return LuaEntity[]? booster_tanks Booster tanks
function Spaceship.get_compute_launch_energy(spaceship, spaceship_is_attempting_launch)
  spaceship.launch_energy = nil
  local tanks = nil
  local zone
  if spaceship.zone_index then
    zone = Zone.from_zone_index(spaceship.zone_index)
  end
  local tanks_meta_data = {}
  if spaceship.zone_index and spaceship.console and spaceship.console.valid and spaceship.known_tiles then
    spaceship.launch_energy = 0
    local surface = spaceship.console.surface
    tanks = surface.find_entities_filtered{name = Spaceship.names_booster_tanks, area = spaceship.known_bounds}
    for _, tank in pairs(tanks) do
      local tank_x = math.floor(tank.position.x)
      local tank_y = math.floor(tank.position.y)

      if not spaceship.known_tiles[tank_x] then goto continue end
      if spaceship.known_tiles[tank_x][tank_y] ~= "floor_console_connected" then goto continue end

      -- This gets the fluid contained in the entity itself, not the entire extent's.
      local fluid = tank.fluidbox[1]
      if not fluid then goto continue end
      local amount = fluid.amount
      if amount == 0 then goto continue end

      local booster_config = Spaceship.booster_types[tank.name]
      if spaceship_is_attempting_launch and fluid.name ~= booster_config.allowed_fluid then
        -- Only the correct fuel in the correct booster tank counts as available launch energy.
        -- This is disincentivized using integrity
        goto continue
      end

      local fuel_value = booster_config.fuel_value_override or Spaceship.cache_fluid_fuel_values[fluid.name]
      if not fuel_value or fuel_value == 0 then goto continue end

      if booster_config.only_in_space and zone and not Zone.is_space(zone) then
        goto continue
      end

      spaceship.launch_energy = spaceship.launch_energy + amount * fuel_value
      tanks_meta_data[tank.unit_number] = {
        entity = tank,
        amount = amount,
        fluid_name = fluid.name,
        fuel_value = fuel_value, -- Takes into account the ion stream energy in space
      }

      ::continue::
    end
  end
  return spaceship.launch_energy, tanks_meta_data
end

---This function assumes that there's enough energy on the ship. It only drains the energy
---from the tanks equaly
---@param spaceship SpaceshipType
---@param energy_to_drain number?
---@param tanks_meta_data table<uint64, {entity:LuaEntity, amount:number, fluid_name:string, fuel_value:number}>
function Spaceship.drain_launch_energy(spaceship, energy_to_drain, tanks_meta_data)
  if not energy_to_drain or energy_to_drain == 0 then return end

  local total_energy = 0
  local number_of_tanks = 0
  for _, tank_meta_data in pairs(tanks_meta_data) do
    number_of_tanks = number_of_tanks + 1
    total_energy = total_energy + tank_meta_data.amount * tank_meta_data.fuel_value
  end
  if total_energy == 0 then return end -- Should never happen, but just in case

  -- NOTE: There's still a slight inefficiency here where every extent will be drained multiple
  -- time whereas it could've been done all at once.
  local percent_required = energy_to_drain / total_energy -- Remove x% from all valid booster tanks
  for _, tank_meta_data in pairs(tanks_meta_data) do
    local tank = tank_meta_data.entity
    local fluid_name = tank_meta_data.fluid_name
    local amount_in_tank = tank_meta_data.amount

    local consume = math.min(amount_in_tank, math.ceil(percent_required * amount_in_tank))

    -- Include consumed fuel in force's consumption statistics
    game.forces[spaceship.force_name].get_fluid_production_statistics(tank.surface).on_flow(fluid_name, -consume)

    if amount_in_tank > 0 then
      tank.remove_fluid({name = fluid_name, amount = consume})
    else
      tank.set_fluid(1, nil)
    end
  end
end

---@param spaceship SpaceshipType
---@return MapPosition.0?
function Spaceship.get_console_or_middle_position(spaceship)
  if spaceship.console and spaceship.console.valid then
    return spaceship.console.position
  end
  if spaceship.known_tiles_average_x and spaceship.known_tiles_average_y then
    return {x = spaceship.known_tiles_average_x, y = spaceship.known_tiles_average_y}
  end
end

---@param spaceship SpaceshipType
---@return MapPosition.0?
function Spaceship.get_boarding_position(spaceship)
  if spaceship.known_tiles_average_x and spaceship.known_bounds then
    return {
      x = spaceship.known_bounds.left_top.x + math.random() * (spaceship.known_bounds.right_bottom.x - spaceship.known_bounds.left_top.x),
      y = spaceship.known_bounds.right_bottom.y + 32
    }
  end
  if spaceship.console and spaceship.console.valid then
    return Util.vectors_add(spaceship.console.position, {x = 64 * ( math.random() - 0.5), y = 64})
  end
end

---@param spaceship SpaceshipType
function Spaceship.destroy(spaceship)
  SpaceshipScheduler.deactivate(spaceship) -- Remove spaceship from reservation tables
  SpaceshipScheduler.remove_spaceship_from_schedule_group(spaceship)

  storage.spaceships[spaceship.index]  = nil
  spaceship.valid = false

  -- if a player has this gui open then close it
  local gui_name = SpaceshipGUI.name_spaceship_gui_root
  for _, player in pairs(game.connected_players) do
    local root = player.gui.left[gui_name]
    if root and root.tags and root.tags.index == spaceship.index then
      root.destroy()
    end
  end
  if spaceship.own_surface then
    game.delete_surface(spaceship.own_surface)
    spaceship.own_surface = nil
  end
  -- make sure that history references to this spaceship are cleaned up
  for _, player in pairs(game.players) do
    RemoteView.make_history_valid(player)
  end
end

--[[========================================================================================
Helper functions for getting information about a spaceship's target destination
]]

---@param spaceship SpaceshipType
---@return (AnyZoneType|SpaceshipType)?
function Spaceship.get_destination_zone(spaceship)
  if spaceship.destination then
    if spaceship.destination.type == "spaceship" then
      return Spaceship.from_index(spaceship.destination.index)
    else
      return Zone.from_zone_index(spaceship.destination.index)
    end
  end
end

---@param spaceship SpaceshipType
---@return boolean
function Spaceship.is_near_destination(spaceship)
  if spaceship.near then
    if not spaceship.destination then
      return true
    elseif spaceship.near.type == spaceship.destination.type
     and spaceship.near.index == spaceship.destination.index then
       return true
    end
  end
  return false
end

---@param spaceship SpaceshipType
---@return boolean
function Spaceship.is_at_destination(spaceship)
  if spaceship.destination and spaceship.destination.type ~= "spaceship" and spaceship.zone_index and spaceship.zone_index == spaceship.destination.index then
     return true
  end
  return false
end

---Gets or makes the spaceship's own surface.
---@param spaceship SpaceshipType Spaceship data
---@return LuaSurface ship_surface
function Spaceship.get_make_spaceship_surface(spaceship)
  local current_surface = spaceship.console.surface
  local ship_surface
  if spaceship.own_surface then
    ship_surface = spaceship.own_surface
  end
  if not ship_surface then
    local map_gen_settings = {
      autoplace_controls = {
        ["planet-size"] = { frequency = 1/1000, size = 1 }
      },
      width = 0,
      height = 0
    }
    map_gen_settings.autoplace_settings={
      ["decorative"]={
        treat_missing_as_default=false,
        settings={
        }
      },
      ["entity"]={
        treat_missing_as_default=false,
        settings={
        }
      },
      ["tile"]={
        treat_missing_as_default=false,
        settings={
          ["se-space"]={}
        }
      },
    }
    ship_surface = game.create_surface("spaceship-"..spaceship.index, map_gen_settings)

    ship_surface.freeze_daytime = true
    ship_surface.daytime = 0.4 -- dark but not midnight
    -- normally this daylight shouldn't be used since Spaceship.set_light is called during launch, right after surface creation
    spaceship.own_surface = ship_surface
  end
  if not ship_surface then
    game.print("Error creating ship surface")
  elseif current_surface == ship_surface then
    Log.debug("Same surface")
  end
  return ship_surface
end

---@param character LuaEntity
---@return boolean
local function find_and_warn_banned_items_in_character(character)
  local banned_items = find_items_banned_from_transport_in_character(character)
  if next(banned_items) then
    local name = character.player and character.player.name or "Character"
    character.force.print({"space-exploration.banned-items-in-character", name, serpent.line(banned_items)})
    return true
  else
    return false
  end
end

---@param vehicle LuaEntity
---@return boolean
local function find_and_warn_banned_items_in_passengers(vehicle)
  local has_banned_items = false
  local driver = vehicle.get_driver()
  local passenger = vehicle.get_passenger()
  if driver and driver.object_name ~= "LuaPlayer" then
    has_banned_items = has_banned_items or find_and_warn_banned_items_in_character(driver)
  end
  if passenger and passenger.object_name ~= "LuaPlayer" then
    has_banned_items = has_banned_items or find_and_warn_banned_items_in_character(passenger)
  end
  return has_banned_items
end

---Exectute final tests if this ship is allowed to launch or not.
---@param spaceship SpaceshipType
---@return boolean? passed a truthy value
---@return boolean? automated_launch if this is an automated launch (i.e. combinator or scheduler driven)
---@return number? required_energy for this luanch
local function do_final_launch_checks(spaceship)
  if not spaceship.is_launching then Log.debug("Abort launch not is_launching") return end
  if spaceship.is_doing_check or game.tick <= (spaceship.surface_lock_timeout or 0) then return end

  local automated_launch = spaceship.is_launching_automatically
  spaceship.is_launching = false
  spaceship.is_launching_automatically = false

  if not spaceship.zone_index then Log.debug("Abort launch no zone_index") return end
  if not spaceship.integrity_valid then Log.debug("Abort launch not integrity_valid") return end
  if not spaceship.known_tiles then Log.debug("Abort launch not known_tiles") return end
  if not spaceship.console and spaceship.console.valid then Log.debug("Abort launch not known_tiles") return end

  local required_energy = Spaceship.get_launch_energy_cost(spaceship)
  if not (required_energy and spaceship.launch_energy and spaceship.launch_energy >= required_energy) then return end

  -- Check for banned items
  local current_surface = spaceship.console.surface
  if next(storage.items_banned_from_transport) then -- If there's any banned item
    local has_banned_items = false
    local banned_items_cargo = {}
    local containers = current_surface.find_entities_filtered({ type = {"container", "logistic-container", "car", "spider-vehicle", "cargo-wagon", "character", "temporary-container"}, area = spaceship.known_bounds})
    for _, container in pairs(containers) do
      local tile_pos = Util.position_to_tile(container.position)
      if spaceship.known_tiles[tile_pos.x] and spaceship.known_tiles[tile_pos.x][tile_pos.y] == "floor_console_connected" then
        if container.type == "character" then
          has_banned_items = has_banned_items or find_and_warn_banned_items_in_character(container)
        else
          local inventory_name
          if container.type == "container" or container.type == "logistic-container" or container.type == "temporary-container" then
            inventory_name = defines.inventory.chest
          elseif container.type == "cargo-wagon" then
            inventory_name = defines.inventory.cargo_wagon
          elseif container.type == "car" then
            inventory_name = defines.inventory.car_trunk
            has_banned_items = has_banned_items or find_and_warn_banned_items_in_passengers(container)
          elseif container.type == "spider-vehicle" then
            inventory_name = defines.inventory.spider_trunk
            has_banned_items = has_banned_items or find_and_warn_banned_items_in_passengers(container)
          end
          local inventory = container.get_inventory(inventory_name)
          util.concatenate_tables(banned_items_cargo, find_items_banned_from_transport(inventory))
        end
      end
    end

    if next(banned_items_cargo) then
      game.forces[spaceship.force_name].print({"space-exploration.banned-items-in-spaceship", Zone.get_print_name(spaceship), serpent.line(banned_items_cargo)})
      has_banned_items = true
    end

    if has_banned_items then return end
  end

  return true, automated_launch, required_energy
end

---Launches a spaceship. This call does not trigger the integrity check.
---Checks if the shapeship has enough energy to launch and if it doesn't contain
---any banned items. And then it starts the launch/clone process.
---Note: it does not trigger an integrity check, but ensures it's valid.
---@param spaceship SpaceshipType the spaceship data
function Spaceship.launch(spaceship)

  local _, tanks_meta_data = Spaceship.get_compute_launch_energy(spaceship, true)

  local passed, automated_launch, required_energy = do_final_launch_checks(spaceship)
  if not passed then
    Event.trigger("on_spaceship_launch_failed", {spaceship_index=spaceship.index})
    return
  end

  local current_surface = spaceship.console.surface
  local zone = Zone.from_zone_index(spaceship.zone_index) --[[@cast zone -?]]
  local current_zone = Zone.from_surface(current_surface)

  -- point of no return. After this point the spaceship _will_ launch.
  Log.debug("spaceship launch start")
  local ship_surface = Spaceship.get_make_spaceship_surface(spaceship)
  spaceship.on_own_surface = true -- Not technically true until clone event, but is what state machine expects.

  local linked_containers = current_surface.find_entities_filtered{
    area=spaceship.known_bounds,
    name="se-linked-container"
  }
  for _, linked_container in pairs(linked_containers) do
    linked_container.link_id = 0
  end

  Spaceship.drain_launch_energy(spaceship, required_energy, tanks_meta_data)

  -- set the ship's location to the new statuses
  spaceship.near = {type="zone", index= spaceship.zone_index} -- Ideally the `on_spaceship_near` event should be triggered here, but it should always happen after `on_spaceship_launched`.
  spaceship.stopped = true
  spaceship.zone_index = nil -- TODO: This is nilled prematurely during automated launches, and some other mechanisms rely on this.
  spaceship.near_star = Zone.get_star_from_child(current_zone) or Zone.get_star_from_position(spaceship)
  Spaceship.set_light(spaceship, ship_surface)

  -- start generating chunks at the destination
  spaceship.requests_made = SpaceshipClone.enqueue_generate_clone_to_area(spaceship, current_surface, ship_surface, {dx=0,dy=0})

  if automated_launch then
    -- await chunk generation before completing the launch
    spaceship.await_start_tick = game.tick
    spaceship.awaiting_requests = true
    spaceship.clone_params = {
      clone_from = current_surface,
      clone_to = ship_surface,
      clone_delta = {dx=0,dy=0}
    }
  else
    -- immediate launch
    SpaceshipClone.clone(spaceship, current_surface, ship_surface, {dx=0,dy=0}, nil)
    Event.trigger("on_spaceship_launched", {spaceship_index=spaceship.index})
    Event.trigger("on_spaceship_near_zone", {spaceship_index=spaceship.index, zone_index=spaceship.near.index})
  end
  Log.debug("spaceship launch end")
end

---Stops a spaceship launch. Or more specifically, stops an automated launch after
---the next integrity check finishes. Does nothing otherwise.
---@param spaceship SpaceshipType
function Spaceship.stop_launch(spaceship)
  if spaceship.is_launching or spaceship.is_launching_automatically then
    Event.trigger("on_spaceship_launch_failed", {spaceship_index=spaceship.index})
  end

  spaceship.is_launching = false
  spaceship.is_launching_automatically = false
end

---Attempt to anchor a spaceship. It will find spaceship and destination clamps
---based on if it's travelling by scheduler or combinator. And if it finds a
---valid match it will initiate the `land_at_position` function.
---Anchoring using the left clamp is prefered, but tries both
---@param spaceship SpaceshipType
function Spaceship.attempt_anchor_spaceship(spaceship)

  local spaceship_clamp --[[@as SpaceshipClampInfo?]]
  local destination_clamp --[[@as SpaceshipClampInfo?]]

  -- Get the destination surface so long
  local destination_zone = Zone.from_zone_index(spaceship.destination.index)
  if not destination_zone then return end
  local destination_surface = Zone.get_surface(destination_zone)
  if not destination_surface then return end

  if spaceship.scheduler.active then
    local record = SpaceshipScheduler.can_land(spaceship)
    if record then -- Allowed to land according to scheduler!
      -- If the scheduler is flying the ship then the current record in the schedule
      -- should specify the spaceship clamp to achor with.
      local reservation = spaceship.scheduler.future_reservation
      if not (reservation and reservation.valid) then return end -- Reservation is no longer valid. Will be handled by scheduler.
      destination_clamp = storage.spaceship_clamps[reservation.clamp_unit_number]
      if not destination_clamp then return end -- Clamp somehow no longer exists. Will be handled by scheduler
      if SpaceshipSchedulerReservations.clamp_ready_for_anchor(destination_clamp) then return end -- To not spam cannot land log
      spaceship_clamp = SpaceshipClamp.find_clamp_on_spaceship(spaceship, record.spaceship_clamp)
      if not spaceship_clamp then return end -- Couldn't find a valid clamp on the spaceship to land with
    end

  else
    -- If flying by combinator then we need to find clamps based on console signals

    local console = spaceship.console
    if not console then return end -- This might happening when the console is destroyed?

    -- The signals specifying the clamps on the spaceship
    local using_left = console.get_signal(Spaceship.signal_for_anchor_using_left, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
    local using_right = console.get_signal(Spaceship.signal_for_anchor_using_right, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
    if using_left == 0 and using_right == 0 then return end -- No signals specified

    -- The signals specifing the clamps to dock with
    local to_right = console.get_signal(Spaceship.signal_for_anchor_to_right, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
    local to_left = console.get_signal(Spaceship.signal_for_anchor_to_left, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
    if to_left == 0 and to_right == 0 then return end -- No signals specified

    if not ((using_left ~= 0 and to_right ~= 0) or (using_right ~= 0 and to_left ~= 0)) then return end -- No valid combination found

    -- See if we have sufficient clamps to dock using left
    if using_left ~= 0 and to_right ~= 0 then
      spaceship_clamp = SpaceshipClamp.find_clamp_on_spaceship(spaceship, {direction=defines.direction.west, id=using_left})
      if spaceship_clamp then
        destination_clamp = SpaceshipClamp.find_unoccupied_destination_clamps(
          destination_surface,
          spaceship.force_name,
          {direction = defines.direction.east, id = to_right}
        )
      end
    end

    if not (spaceship_clamp and destination_clamp) then
      -- No valid clamps found to anchor using left. Lets try using right this time
      spaceship_clamp = nil
      destination_clamp = nil

      if using_right ~= 0 and to_left ~= 0 then
        spaceship_clamp = SpaceshipClamp.find_clamp_on_spaceship(spaceship, {direction=defines.direction.east, id=using_right})
        if not spaceship_clamp then return end
        destination_clamp = SpaceshipClamp.find_unoccupied_destination_clamps(
          destination_surface,
          spaceship.force_name,
          {direction = defines.direction.west, id = to_left}
        )
      end
    end

  end

  if not (spaceship_clamp and destination_clamp) then return end

  -- Found valid spaceship and destination combinations. Now calculate the position
  -- the spaceship should land at and start the sequence. Also, if we reach here we
  -- know the clamp structs are valid.
  local position = {
    x = -1 * spaceship_clamp.main.position.x + (spaceship_clamp.direction == defines.direction.west and 2 or -2),
    y = -1 * spaceship_clamp.main.position.y
  }
  position = util.vectors_add(position, destination_clamp.main.position)
  Spaceship.land_at_position(spaceship, position, true)
end

---Lands a spaceship a specific position.
---@param spaceship SpaceshipType Spaceship data
---@param position MapPosition Position at which to land
---@param ignore_average? boolean If we are cloning based on the corner of the ship or its center
function Spaceship.land_at_position(spaceship, position, ignore_average)
  if spaceship.is_doing_check or
    not (
      Spaceship.is_on_own_surface(spaceship) and
      spaceship.near and spaceship.near.type == "zone" and
      spaceship.known_tiles and
      game.tick > (spaceship.surface_lock_timeout or 0)
    ) then return end
  local destination_zone = Zone.from_zone_index(spaceship.near.index)
  if not destination_zone then return end

  local ship_surface = game.get_surface("spaceship-" .. spaceship.index)
  local target_surface = Zone.get_make_surface(destination_zone)
  local spaceship_known_tiles = spaceship.known_tiles

  local offset_x = util.to_rail_grid(position.x - spaceship.known_tiles_average_x)
  local offset_y = util.to_rail_grid(position.y - spaceship.known_tiles_average_y)
  if ignore_average then
    offset_x = util.to_rail_grid(position.x)
    offset_y = util.to_rail_grid(position.y)
  end

  local destination_area = {
    left_top = {
      x = spaceship.known_bounds.left_top.x + offset_x,
      y = spaceship.known_bounds.left_top.y + offset_y
    },
    right_bottom = {
      x = spaceship.known_bounds.right_bottom.x + offset_x,
      y = spaceship.known_bounds.right_bottom.y + offset_y
    },
  }

  if target_surface.count_tiles_filtered{name = name_out_of_map_tile, area = destination_area, limit = 1} > 0 then
    ship_surface.print({"space-exploration.spaceship-cannot-land-out-of-map"})
    return
  end

  local dont_land_on = table.deepcopy(Ancient.vault_entrance_structures)
  table.insert(dont_land_on, Ancient.name_gate_blocker)
  table.insert(dont_land_on, Ancient.name_gate_blocker_void)
  for name, stuff in pairs(Ancient.gate_fragments) do
    table.insert(dont_land_on, name)
  end

  local dont_land_on_entity = target_surface.find_entities_filtered{name = dont_land_on, area = destination_area, limit = 1}
  if dont_land_on_entity and dont_land_on_entity[1] then
    ship_surface.print({"", {"space-exploration.spaceship-land-fail-entity-in-the-way", {"space-exploration.ruin"}}, " "..util.gps_tag(target_surface.name, dont_land_on_entity[1].position)})
    return
  end

  if destination_zone.fragment_name then
    local resource_names = {
      destination_zone.fragment_name,
      destination_zone.fragment_name .. CoreMiner.name_core_seam_sealed_suffix
    }
    local core_seam = target_surface.find_entities_filtered{name=resource_names, area=destination_area, limit=1}
    if core_seam and core_seam[1]  then
      ship_surface.print({"", {"space-exploration.spaceship-land-fail-entity-in-the-way", {"entity-name.se-core-seam"}}, " "..util.gps_tag(target_surface.name, core_seam[1].position)})
      return
    end
  end

  local landing_area_entities = {}
  for x = spaceship.known_bounds.left_top.x, spaceship.known_bounds.right_bottom.x do
    for y = spaceship.known_bounds.left_top.y, spaceship.known_bounds.right_bottom.y do
      local value = spaceship_known_tiles[x] and spaceship_known_tiles[x][y]
      if value == "floor_console_connected" or value == "bulkhead_console_connected" then
        local area = {
          left_top = {
            x = x + offset_x,
            y = y + offset_y
          },
          right_bottom = {
            x = x + 31/32 + offset_x,
            y = y + 31/32 + offset_y
          }
        }
        local entities = target_surface.find_entities_filtered{area = area}
        for _, entity in pairs(entities) do
          local entity_type = entity.type
          if entity.force.name ~= "neutral" and entity_type ~= "entity-ghost" and entity_type ~= "tile-ghost"
            and entity_type ~= "logistic-robot" and entity_type ~= "construction-robot" and entity_type ~= "deconstructible-tile-proxy"
            and entity_type ~= "rocket-silo-rocket" then
            ship_surface.print({"", {"space-exploration.spaceship-land-fail-entity-in-the-way", entity.prototype.localised_name}, " "..util.gps_tag(target_surface.name, entity.position)})
            return
          end
          table.insert(landing_area_entities, entity)
        end
      end
    end
  end

  -- point of no return
  Log.debug_log('spaceship land start')
  Spaceship.deactivate_engines(spaceship)

  local linked_containers = ship_surface.find_entities_filtered{
    area=spaceship.known_bounds,
    name="se-linked-container"
  }
  for _, linked_container in pairs(linked_containers) do
    linked_container.link_id = 0
  end

  Spaceship.destroy_all_smoke_triggers(ship_surface)
  SpaceshipObstacles.destroy(spaceship, ship_surface) -- destroy all the obstacles on the ship's surface
  Zone.apply_markers(destination_zone) -- in case the surface exists

  -- clear the target area
  for _, entity in pairs(landing_area_entities) do
    if entity.valid then
      if entity.type == "character" then
        entity.health = entity.health * 0.1
      elseif entity.type ~= "spider-leg" then
        util.safe_destroy(entity)-- maybe use die?
      end
    end
  end

  -- request chunk generation at destination and then immediately land there
  local clone_delta = {dx=offset_x,dy=offset_y}
  SpaceshipClone.enqueue_generate_clone_to_area(spaceship, ship_surface, target_surface, clone_delta)
  SpaceshipClone.clone(spaceship, ship_surface, target_surface, clone_delta, Spaceship.post_land_at_position)
  Log.debug_log('spaceship land end')
  Event.trigger("on_spaceship_anchored", {spaceship_index=spaceship.index})
end

---Finishes landing the spaceship after the cloning procedure is complete.
---@param spaceship SpaceshipType Spaceship data
---@param clone_from LuaSurface Surface to clone from
---@param clone_to LuaSurface Surface to clone to
---@param clone_delta Delta
function Spaceship.post_land_at_position(spaceship, clone_from, clone_to, clone_delta)
  -- Before deleting the surface, complete any capsule launches that were in progress
  for _, tick_task in pairs(storage.tick_tasks) do
    ---@cast tick_task CapsuleTickTask
    if tick_task.type == "capsule-journey" and tick_task.origin == spaceship then
      Capsule.truncate_ascent(tick_task)
    end
  end

  -- Find leftover characters and any vehicles they may be stashed in
  local entities = clone_from.find_entities_filtered{type = {"character", "car", "spider-vehicle"}}
  local clone_to_zone = Zone.from_surface(clone_to) --[[@as AnyZoneType|SpaceshipType]]

  if next(entities) then
    local target_zone = Spaceship.determine_stranded_player_target_zone(spaceship, clone_to_zone)

    -- Teleport any characters to the `target_zone`
    for _, entity in pairs(entities) do
      local entity_type = entity.type

      if entity_type == "character" then
        -- Teleport characters. This includes:
        -- 1) Players on the ship (also while using Remote View)
        -- 2) Players on the ship viewing the star map, which has a character stashed.
        -- 3) Players scouting an anchor location for (any) spaceship.
        Spaceship.clean_up_leftover_character(entity, spaceship, target_zone)
      else -- entity is a car or spidertron
        local driver = entity.get_driver()
        local passenger = entity.get_passenger()

        if driver and not driver.is_player() then
          ---@cast driver -LuaPlayer
          entity.set_driver(nil)
          Spaceship.clean_up_leftover_character(driver, spaceship, target_zone)
        end

        if passenger and not passenger.is_player() then
          ---@cast passenger -LuaPlayer
          entity.set_passenger(nil)
          Spaceship.clean_up_leftover_character(passenger, spaceship, target_zone)
        end
      end
    end
  end

  -- Now also need to handle any players which do not have characters, such as offline players.
  -- Online players would already have been teleported by the code above.
  for _, player in pairs(game.players) do
    if player.physical_surface ~= clone_from then goto continue end
    local position = player.physical_position

    if Spaceship.is_position_on_spaceship(position, spaceship, false) then
      -- Player was riding the ship. Teleport to new surface at same relative position.
      player.teleport({
        x = position.x + clone_delta.dx,
        y = position.y + clone_delta.dy,
      }, clone_to)
    else
      -- Player was silly and floated outside the spaceship. Will be teleported to orbit close by.
      -- This is also done during Spaceship.post_land_at_position, but at that point only characters
      -- stashed will be handled (scouting and map-viewing players).
      local target_zone = Spaceship.determine_stranded_player_target_zone(spaceship, clone_to_zone)
      local surface = Zone.get_make_surface(target_zone)
      local chunk_position = surface.get_random_chunk()
      local target_position = {
        x = chunk_position.x * 32 + math.random(32),
        y = chunk_position.y * 32 + math.random(32)
      } --[[@as MapPosition.0]]
      player.teleport(target_position, surface)

      -- This will only print if the player joins fast enough again, otherwise they will never see it.
      player.print({"space-exploration.spaceship-character-stranded",
        Zone.get_print_name(spaceship), Zone.get_print_name(target_zone)})
    end

    ::continue::
  end

  -- Clear the surface, and not destroy, so that it doesn't have to be recreated when
  -- the spaceship launches again. The surface is only cleared in a future tick, but that's
  -- okay because its not possible to launch again within a second.
  -- This has the added benefit of not destroying the production statistics of this surface.
  clone_from.clear()

  -- Set the ship's location to the new statuses
  spaceship.on_own_surface = false
  spaceship.particles = {}
  spaceship.mineables = {}
  spaceship.zone_index = spaceship.near.index
  spaceship.near = nil
  spaceship.stopped = true
  spaceship.is_moving = false
  spaceship.speed = 0
end

---Determine zone a player should drift to when spaceship lands while player is silly
---and floating around outside the spaceship.
---@param spaceship SpaceshipType the spaceship that landed
---@param zone AnyZoneType the spaceship landed on
---@return AnyZoneType target_zone
function Spaceship.determine_stranded_player_target_zone(spaceship, zone)
    local target_zone = Zone.find_nearest_zone(spaceship.space_distortion,
      Zone.get_stellar_position(zone), Zone.get_star_gravity_well(zone),
      Zone.get_planet_gravity_well(zone))

    -- Target zone must be a space zone
    if target_zone.orbit then target_zone = target_zone.orbit end
    ---@cast target_zone -StarType|-PlanetType|-MoonType

    return target_zone
end

---Teleports the character from the to-be-deleted spaceship surface to the `target-zone`.
---@param character LuaEntity Character to be teleported
---@param spaceship SpaceshipType Spaceship the character was on board
---@param target_zone AnyZoneType Zone the character should be teleported to
function Spaceship.clean_up_leftover_character(character, spaceship, target_zone)
  local matching_playerdata, matching_player_index

  -- Find the player/playerdata whose character this is
  for player_index, playerdata in pairs(storage.playerdata) do
    if character == playerdata.character then
      matching_playerdata = playerdata
      matching_player_index = player_index
      break
    end
  end

  -- Disable jetpack, since cross-surface teleportation will invalidate jetpack's character refs
  if character.name:find("jetpack", 1, true) then
    local landing_character = remote.call("jetpack", "stop_jetpack_immediate", {character=character}) --[[@as LuaEntity]]
    if landing_character then character = landing_character end
  end

  local surface = Zone.get_make_surface(target_zone)
  local chunk_position = surface.get_random_chunk()
  local target_position = {
    x = chunk_position.x * 32 + math.random(32),
    y = chunk_position.y * 32 + math.random(32)
  } --[[@as MapPosition.0]]

  local new_character, _ =
    teleport_character_to_surface_2(character, Zone.get_make_surface(target_zone), target_position)

  -- Update `character` ref in `PlayerData` table
  if matching_playerdata then
    matching_playerdata.character = new_character

    local player = game.get_player(matching_player_index)
    if player then
      RemoteView.stop(player)
      player.print({"space-exploration.spaceship-character-stranded",
        Zone.get_print_name(spaceship), Zone.get_print_name(target_zone)})
    end
  end
end

--- Decrements the number of requests being waited upon for a spaceship surface transfer whenever a chunk is generated
---@param event EventData.on_chunk_generated Event data
function Spaceship.on_chunk_generated(event)
  if event.surface and string.find(event.surface.name, "spaceship-") then
    for _, spaceship in pairs(storage.spaceships) do
      if spaceship.clone_params and spaceship.requests_made and spaceship.clone_params.clone_to == event.surface then
        spaceship.requests_made = spaceship.requests_made - 1
      end
    end
  end
end
Event.addListener(defines.events.on_chunk_generated, Spaceship.on_chunk_generated)

function Spaceship.on_remote_view_started(event)
  local player = event.player --[[@as LuaPlayer]]
  local playerdata = get_make_playerdata(player)

  local zone = event.zone
  if not zone then return end
  local spaceship = zone.type == "spaceship" and zone or nil --[[@as SpaceshipType?]]

  if spaceship then
    -- When the player opens remote view on a spaceship they're watching will not
    -- have been charted until manually charted with our Remote View. So to prevent
    -- the screen from being black for a moment we chart the entire surface here.
    local surface = Spaceship.get_own_surface(spaceship)
    if surface then player.force.chart_all(surface) end
  end

  if not (spaceship and spaceship.index == playerdata.watching_spaceship) then
    -- The player doesn't have the watch-spaceship toggled on this spaceship
    -- or not even watching a spaceship, so the toggle is no longer valid.
    playerdata.watching_spaceship = nil
  end
end
Event.addListener("on_remote_view_started", Spaceship.on_remote_view_started, true)

function Spaceship.on_remote_view_stopped(event)
  local player = event.player
  local playerdata = get_make_playerdata(player)
  playerdata.watching_spaceship = nil
end
Event.addListener("on_remote_view_stopped", Spaceship.on_remote_view_stopped, true)

---Determines the rectangles necessary to somewhat quickly draw an image of the spaceship that this
---player is anchor scouting. Necessary because drawing each individual tile as a separate rectangle
---lags the game.
---@param spaceship SpaceshipType Spaceship data
---@param scouting_activity RemoteViewActivityAnchorScouting
function Spaceship.get_make_anchor_scouting_cache(spaceship, scouting_activity)
  if not scouting_activity.footprint_cache then
    scouting_activity.footprint_cache = {}

    if spaceship.known_tiles and spaceship.known_bounds then
      local aabb
      for x = spaceship.known_bounds.left_top.x, spaceship.known_bounds.right_bottom.x do
        for y = spaceship.known_bounds.left_top.y, spaceship.known_bounds.right_bottom.y do
          local value = spaceship.known_tiles[x] and spaceship.known_tiles[x][y]
          if value == "floor_console_connected"
          or value == "bulkhead_console_connected" then
            if not aabb then
               aabb = {min_x=x,max_x=x+1,min_y=y,max_y=y+1}
            else
              aabb.max_y = aabb.max_y + 1
            end
          else
            if aabb then
              table.insert(scouting_activity.footprint_cache, aabb)
              aabb = nil
            end
          end
        end
        if aabb then
          table.insert(scouting_activity.footprint_cache, aabb)
          aabb = nil
        end
      end
    end
  end
  return scouting_activity.footprint_cache
end

---Draws the rectangles where the ship would land during anchor scouting.
---@param player LuaPlayer
function Spaceship.anchor_scouting_tick(player)
  local remote_view_activity = RemoteView.get_activity(player, "spaceship-anchor-scouting")
  if not remote_view_activity then return end
  local spaceship = storage.spaceships[remote_view_activity.anchor_scouting.spaceship_index]
  if not spaceship then return end

  local anchor_scouting_cache = Spaceship.get_make_anchor_scouting_cache(spaceship, remote_view_activity.anchor_scouting)
  if anchor_scouting_cache then
    local offset_x = util.to_rail_grid(player.position.x - spaceship.known_tiles_average_x)
    local offset_y = util.to_rail_grid(player.position.y - spaceship.known_tiles_average_y)
    for _, aabb in pairs(anchor_scouting_cache) do
      rendering.draw_rectangle{
        color = {r = 0.125, g = 0.125, b = 0, a = 0.01},
          filled = true,
          left_top = {x=aabb.min_x+offset_x,y=aabb.min_y+offset_y},
          right_bottom = {x=aabb.max_x+offset_x,y=aabb.max_y+offset_y},
          surface = player.surface,
          time_to_live = Spaceship.tick_interval_anchor,
      }
    end
    -- Note: This approach is only valid while spaceships can't anchor to other spaceships. When that's implemented
    -- change the code to check for clamps during `start_anchor_scouting`, similar to `find_own_surface_engines`.
    for _, clamp_info in pairs(storage.spaceship_clamps_by_surface["spaceship-"..spaceship.index] or { }) do
      local clamp = clamp_info.main
      if clamp.valid then
        rendering.draw_rectangle{
          color = {r = 0, g = 0, b = 0.125, a = 0.01},
          filled = true,
          left_top = {x=clamp.position.x+offset_x+1,y=clamp.position.y+offset_y+1},
          right_bottom = {x=clamp.position.x+offset_x-1,y=clamp.position.y+offset_y-1},
          surface = player.surface,
          time_to_live = Spaceship.tick_interval_anchor,
        }
      end
    end
  end
end

---Return a warning string if the spaceship is attempting to anchor to a solid zone without planet boosters. Return nil otherwise.
---@param spaceship SpaceshipType Spaceship data
---@param zone AnyZoneType|SpaceshipType Zone the spaceship is trying to anchor to
---@return LocalisedString?
function Spaceship.get_booster_warning_string(spaceship, zone)
  local ship_surface = Spaceship.get_own_surface(spaceship)
  if Zone.is_solid(zone) and ship_surface.count_entities_filtered{name = Spaceship.names_planet_booster_tanks, area = spaceship.known_bounds, limit = 1} == 0 then
    ---@cast zone PlanetType|MoonType
    if ship_surface.count_entities_filtered{name = mod_prefix .. "spaceship-ion-booster-tank", area = spaceship.known_bounds, limit = 1} > 0 then
      return {"space-exploration.spaceship-no-planet-boosters-warning-ion"}
    else
      return {"space-exploration.spaceship-no-planet-boosters-warning"}
    end
  end
  return nil
end

---Starts anchor scouting at the location the spaceship is currently at.
---@param spaceship SpaceshipType Spaceship data
---@param player LuaPlayer
function Spaceship.start_anchor_scouting(spaceship, player)
  if not spaceship.near and spaceship.near.type == "zone" then return end
  local zone = Zone.from_zone_index(spaceship.near.index)
  if not zone then return end

  ---Position where to start the scouting. Use the last position the player was on that
  ---surface if possible.
  ---@type MapPosition
  local position = { x = 0, y = 0 }
  local playerdata = get_make_playerdata(player)
  local surface = Zone.get_make_surface(zone) -- Make sure the surface exists too
  if playerdata.surface_positions and playerdata.surface_positions[surface.index] then
    position = playerdata.surface_positions[surface.index]
  end

  RemoteView.start_activity(player, {
    type = "spaceship-anchor-scouting",
    anchor_scouting = {spaceship_index = spaceship.index, remote_before_scouting = RemoteView.is_active(player)},
  }, zone, position)

  -- warn player if they don't have booster tanks to escape.
  local booster_warning_string = Spaceship.get_booster_warning_string(spaceship, zone)
  if booster_warning_string then
    player.print(booster_warning_string)
  end
end

--- Stops any in progress anchor scouting for the given player
---@param player LuaPlayer
function Spaceship.stop_anchor_scouting(player)
  local remote_view_activity = RemoteView.get_activity(player, "spaceship-anchor-scouting")
  if not remote_view_activity then return end
  local spaceship = storage.spaceships[remote_view_activity.anchor_scouting.spaceship_index]

  if spaceship and remote_view_activity.anchor_scouting.remote_before_scouting then
    RemoteView.start(player, spaceship)
  else
    RemoteView.get_data(player).activity = nil -- to prevent recursive calls
    RemoteView.stop(player)
  end
end

---Handles a number of spaceship-spacific entities getting built. Clone is deliberately not handled.
---@param event EntityCreationEvent Event data
function Spaceship.on_entity_created(event)
  local entity = event.entity
  if not entity.valid then return end

  -- Ignore ghost entities/tiles
  local entity_type = entity.type
  if entity_type == "entity-ghost" or entity_type == "tile-ghost" then return end

  local surface_index = entity.surface.index
  local spaceship = Spaceship.from_own_surface_index(surface_index)

  if spaceship and not spaceship.is_cloning then
    SpaceshipIntegrity.start_integrity_check(spaceship)
  end

  local entity_name = entity.name

  if Spaceship.names_engines_map[entity_name] then
    if spaceship and spaceship.is_moving then
        -- Sets smoke
        Spaceship.find_own_surface_engines(spaceship)
      else
        entity.active = false
      end
  end

  if entity_name == Spaceship.name_spaceship_console then

    if spaceship then
      if not (spaceship.console and spaceship.console.valid) then
        spaceship.console = entity
        spaceship.last_console_unit_number = entity.unit_number
        spaceship.console_output = nil

        SpaceshipIntegrity.start_integrity_check(spaceship, 0.1)
      end
    else -- Console getting built anywhere that is _not_ a spaceship surface
      local zone = Zone.from_surface_index(surface_index)
      if cancel_creation_when_invalid(zone, entity, event, true) then return end
      ---@cast zone -?

      local spaceship_index = storage.next_spaceship_index
      storage.next_spaceship_index = spaceship_index + 1

      local name
      do -- Pick a name for the new spaceship
        local available_names = {}
        local found

        for _, candidate in pairs(Spaceship.names) do
          found = false

          for _, ship in pairs(storage.spaceships) do
            if candidate == ship.name then
              found = true
              break
            end
          end

          if not found then
            table.insert(available_names, candidate)
          end
        end

        if next(available_names) then
          name = available_names[math.random(#available_names)]
        else
          name = "Spaceship " .. spaceship_index
        end
      end

      ---@type SpaceshipType
      spaceship = {
        type = "spaceship",
        index = spaceship_index,
        valid = true,
        force_name = entity.force.name,
        unit_number = entity.unit_number,
        console = entity,
        last_console_unit_number = entity.unit_number,
        name = name,
        speed = 1,
      }

      -- For now all spaceships have 0 attrition but who knows
      Zone.calculate_base_bot_attrition(spaceship)

      if zone then
        spaceship.zone_index = zone.index -- this is dynamic and can be nil
        spaceship.destination_zone_index = zone.index
        spaceship.space_distortion = Zone.get_space_distortion(zone)
        spaceship.stellar_position = Zone.get_stellar_position(zone)
        spaceship.star_gravity_well = Zone.get_star_gravity_well(zone)
        spaceship.planet_gravity_well = Zone.get_planet_gravity_well(zone)
        spaceship.near_star = Zone.get_star_from_position(spaceship)
        spaceship.near_stellar_object = Zone.get_stellar_object_from_child(zone)
      end

      storage.spaceships[spaceship_index] = spaceship
      SpaceshipScheduler.add_to_spaceship(spaceship) -- Do after creating entry in storage

      -- Deserialize tags after adding spaceship to storage
      local tags = util.get_tags_from_event(event, Spaceship.serialize)
      if tags then
        Spaceship.deserialize(entity, tags)
      end

      SpaceshipIntegrity.start_integrity_check(spaceship, 0.1)
    end

    if event.player_index then
      SpaceshipGUI.gui_open(game.get_player(event.player_index), spaceship)
    end

  end

  if spaceship then
    SpaceshipIntegrity.check_integrity_stress(spaceship)
  end
end
Event.addOnEntityCreatedListeners(Spaceship.on_entity_created)

---@param event EntityRemovalEvent Event data
function Spaceship.on_entity_removed(event)
  if event.entity and event.entity.valid then
    if event.entity.name == Spaceship.name_spaceship_console then
      -- simulations don't have real player
      if event.player_index then
        SpaceshipGUI.gui_close(game.get_player(event.player_index))
      end
      local outputs = event.entity.surface.find_entities_filtered{name = Spaceship.name_spaceship_console_output, area = util.position_to_area(event.entity.position, 2)}
      for _, output in pairs(outputs) do
        output.destroy()
      end
    elseif event.entity.surface and Spaceship.names_spaceship_bulkheads_map[event.entity.name] then
      -- this check is *not* appropriate if we can have multiple spaceships on a spaceship surface
      -- when implementing multiple ships per spaceship surface, the way of handling not responding to events raised by cloning must be changed to work with that
      if string.find(event.entity.surface.name, "spaceship-") then
        local spaceship = Spaceship.from_own_surface_index(event.entity.surface.index)
        if spaceship and not spaceship.is_cloning then
          spaceship.speed = spaceship.speed * 0.9
          Spaceship.destroy_all_smoke_triggers(event.entity.surface)
          SpaceshipIntegrity.check_integrity_stress(spaceship)
          SpaceshipIntegrity.start_integrity_check(spaceship)
        end
      end
    end
  end
end
Event.addOnEntityRemovedListeners(Spaceship.on_entity_removed)

---@param event EventData.on_post_entity_died
local function on_post_entity_died(event)
  local ghost = event.ghost
  local unit_number = event.unit_number
  if not (ghost and unit_number) then return end
  if event.prototype.name ~= Spaceship.name_spaceship_console then return end

  -- The spaceship is only removed from global on the next tick update, and
  -- when the spaceship is landed. This means this function will always
  -- run before `Spaceship.destroy(...)`. There is a small chance that the
  -- `last_console_unit_number` wasn't set during migration due to the rare
  -- case of landed console being destroyed, and migration running before next
  -- update. If this happens this loop won't find the spaceship, and just silently
  -- return.

  local spaceship --[[@as SpaceshipType? ]]
  for _, this_spaceship in pairs(storage.spaceships) do
    if this_spaceship.last_console_unit_number == unit_number then
      spaceship = this_spaceship
      break
    end
  end
  if not (spaceship and spaceship.valid) then return end

  -- If the spaceship is on its own surface then the spaceship struct is not destroyed
  if spaceship.on_own_surface then return end

  ghost.tags = Spaceship.serialize_from_struct(spaceship)
end
Event.addListener(defines.events.on_post_entity_died, on_post_entity_died)

---@param spaceship SpaceshipType
---@return number? distance
function Spaceship.get_distance_to_destination(spaceship)
  if (not spaceship.destination) or Spaceship.is_near_destination(spaceship) then
    return 0
  end

  local target_zone = Spaceship.get_destination_zone(spaceship)
  if target_zone then

    local destination_space_distorion = Zone.get_space_distortion(target_zone)
    local destination_stellar_position = Zone.get_stellar_position(target_zone)
    local destination_star_gravity_well = Zone.get_star_gravity_well(target_zone)
    local destination_planet_gravity_well = Zone.get_planet_gravity_well(target_zone)

    local distortion_distance = 0
    local interstellar_distance = 0
    local star_gravity_distance = 0
    local planet_gravity_distance = 0

    distortion_distance = math.abs(spaceship.space_distortion - destination_space_distorion)

    interstellar_distance = Util.vectors_delta_length(spaceship.stellar_position, destination_stellar_position)
    --if distortion_distance == 1 then
    if distortion_distance >= 1 or (spaceship.space_distortion == 1 and destination_space_distorion == 1) then
      interstellar_distance = 0
    end
    if interstellar_distance == 0 then
      -- same solar system
      star_gravity_distance = math.abs(spaceship.star_gravity_well - destination_star_gravity_well)
    else
      star_gravity_distance = spaceship.star_gravity_well + destination_star_gravity_well
    end

    if star_gravity_distance == 0 then
      -- same solar system
      planet_gravity_distance = math.abs(spaceship.planet_gravity_well - destination_planet_gravity_well)
    else
      planet_gravity_distance = spaceship.planet_gravity_well + destination_planet_gravity_well
    end

    if target_zone.type == "anomaly" and star_gravity_distance == 0 and planet_gravity_distance == 0 and distortion_distance > 0 then
      ---@cast target_zone AnomalyType
      return math.random(Zone.travel_cost_space_distortion - 1000) * 4 + 1000
      -- actual distance calculation: return distortion_distance * Zone.travel_cost_space_distortion
    else
      return distortion_distance * Zone.travel_cost_space_distortion
      + interstellar_distance * Zone.travel_cost_interstellar
      + star_gravity_distance * Zone.travel_cost_star_gravity
      + planet_gravity_distance * Zone.travel_cost_planet_gravity
    end
  end
end

---Gets the number of spaceship tiles behind a given starting position.
---@param spaceship SpaceshipType Spaceship data
---@param start_position TilePosition "{x=int, y=int}"
---@return uint space_behind
function Spaceship.get_space_behind(spaceship, start_position)
  -- spaceship must be on own surface
  local space_behind = math.huge
  local spaceship_known_column = spaceship.known_tiles and spaceship.known_tiles[start_position.x] or nil
  if spaceship_known_column then
    -- there's no way this is efficient but it needs to be profiled to see if this actually
    -- meaningfully contributes to the UPS cost of ships (probably contributes more to integrity
    -- checks than anything else)
    for y = start_position.y, spaceship.known_bounds.right_bottom.y, 1 do
      if spaceship_known_column[y] == "floor_console_connected" or spaceship_known_column[y] == "bulkhead_console_connected" then
          space_behind = y - start_position.y
          break
      end
    end
  end
  return space_behind
end

---@param spaceship SpaceshipType
---@param engine SpaceshipEngineType
function Spaceship.show_engine_efficiency(spaceship, engine)
  if spaceship.type == "simulation-spaceship" then return end

  local color
  if engine.efficiency <= 0.6 then
    color = "red"
  elseif engine.efficiency < 0.9 then
    color = "yellow"
  else -- >= 0.9
    color = "green"
  end
  local efficiency_string = "[color="..color.."]" .. math.ceil(engine.efficiency*100).."%" .. "[/color]"

  rendering.draw_text{
    text = efficiency_string,
    surface = engine.entity.surface,
    target = engine.entity,
    color = {1,1,1},
    time_to_live = 80,
    forces = engine.entity.force,
    use_rich_text = true,
  }
end

---@param spaceship SpaceshipType the spaceship data
---@param engine SpaceshipEngineType engine
function Spaceship.update_smoke(spaceship, engine)
  if engine.entity.active then
    if (not engine.smoke_trigger) and Spaceship.engines[engine.entity.name].smoke_trigger then
      engine.smoke_trigger = engine.entity.surface.create_entity{
        name = Spaceship.engines[engine.entity.name].smoke_trigger,
        position = {x = engine.entity.position.x, y = engine.entity.bounding_box.right_bottom.y}
      }
    end
  elseif engine.smoke_trigger and engine.smoke_trigger.valid then
    engine.smoke_trigger.destroy()
    engine.smoke_trigger = nil
  end
end

---@param surface LuaSurface
function Spaceship.destroy_all_smoke_triggers(surface)
  local smoke_triggers = surface.find_entities_filtered{
    type = "smoke-with-trigger",
    name = Spaceship.names_smoke_trigger
    -- do not restrict area,
  }
  for _, smoke_trigger in pairs(smoke_triggers) do
    smoke_trigger.destroy()
  end
end

---Finds the engines for this spaceship.
---@param spaceship SpaceshipType Spaceship data
function Spaceship.find_own_surface_engines(spaceship)
  spaceship.engines = nil
  local surface = Spaceship.get_own_surface(spaceship)
  if surface then
    Spaceship.destroy_all_smoke_triggers(surface)
  end
  if surface and spaceship.known_tiles and spaceship.known_bounds then
    spaceship.engines = {}
    local engines = surface.find_entities_filtered{
      name = Spaceship.names_engines,
      area = spaceship.known_bounds
    }
    local y_engines = {} -- thrust harmonics
    for _, entity in pairs(engines) do
      local efficiency = Spaceship.engine_efficiency_blocked
      local box = entity.bounding_box
      local engine_y_behind = math.floor(box.right_bottom.y) + 1
      local engine_x = math.floor((box.left_top.x + box.right_bottom.x)/2)
      local space_behind
      if entity.position.x % 1 < 0.25 or entity.position.x % 1 > 0.75 then
        -- 2-wide trail
        space_behind = math.min(
          Spaceship.get_space_behind(spaceship, {x = engine_x - 1, y = engine_y_behind}),
          Spaceship.get_space_behind(spaceship, {x = engine_x, y = engine_y_behind})
        )
      else
        -- 1-wide trail
        space_behind = Spaceship.get_space_behind(spaceship, {x = engine_x, y = engine_y_behind})
      end
      if space_behind < 0 then
        efficiency = Spaceship.engine_efficiency_unblocked
      else
        efficiency = 1-(1-Spaceship.engine_efficiency_blocked) / (space_behind + Spaceship.engine_efficiency_unblocked_taper) * Spaceship.engine_efficiency_unblocked_taper
      end
      efficiency = efficiency - Spaceship.engine_efficiency_side
      local engine =  {entity = entity, efficiency = efficiency}
      if not y_engines[engine_y_behind] then
        y_engines[engine_y_behind] = {left = engine, right = engine}
      else
        if entity.position.x < y_engines[engine_y_behind].left.entity.position.x then
           y_engines[engine_y_behind].left = engine
        end
        if entity.position.x > y_engines[engine_y_behind].right.entity.position.x then
           y_engines[engine_y_behind].right = engine
        end
      end
      table.insert(spaceship.engines, engine)
    end

     -- thrust harmonics
     -- the left-most and right-most engines get a bonus
     -- there is a 1% incentive to have engines on different Y values.
     -- You waste integrity building this way, but it means more interesting designs are penalised less by the forced grid.
    for y, left_right in pairs(y_engines) do
      left_right.left.efficiency = left_right.left.efficiency + Spaceship.engine_efficiency_side
      if left_right.left ~= left_right.right then
        left_right.right.efficiency = left_right.right.efficiency + Spaceship.engine_efficiency_side
      end
    end

    -- Show the result
    local player_is_here = not SpaceshipObstacles.surface_has_no_players(surface)
    for _, engine in pairs(spaceship.engines) do
      if player_is_here then
        Spaceship.show_engine_efficiency(spaceship, engine)
      end
      Spaceship.update_smoke(spaceship, engine)
    end
  end
end

---Activates the engines on given spaceship.
---@param spaceship SpaceshipType Spaceship data
function Spaceship.activate_engines(spaceship)
  if not spaceship.engines then
    Spaceship.find_own_surface_engines(spaceship)
  end
  if spaceship.engines then
    for _, engine in pairs(spaceship.engines) do
      if engine.entity and engine.entity.valid then
        engine.entity.active = true
        Spaceship.update_smoke(spaceship, engine)
      else
        spaceship.engines = nil
        Spaceship.activate_engines(spaceship)
        return
      end
    end
  end
end

---Deactivates the engines on this spaceship.
---@param spaceship SpaceshipType Spaceship data
function Spaceship.deactivate_engines(spaceship)
  if not spaceship.engines then
    Spaceship.find_own_surface_engines(spaceship)
  end
  if spaceship.engines then
    for _, engine in pairs(spaceship.engines) do
      if engine.smoke_trigger and engine.smoke_trigger.valid then
        engine.smoke_trigger.destroy()
        engine.smoke_trigger = nil
      end
      if engine.entity and engine.entity.valid then
        engine.entity.active = false
        Spaceship.update_smoke(spaceship, engine)
      else
        spaceship.engines = nil
        Spaceship.deactivate_engines(spaceship)
        return
      end
    end
  end
end

---@param spaceship SpaceshipType
---@param time_passed integer
function Spaceship.surface_tick(spaceship, time_passed)
  -- actions that apply to maintaining a spaceship surface
  spaceship.speed = spaceship.speed or 0
  local surface = Spaceship.get_own_surface(spaceship)
  if spaceship.speed > 1 then
    surface.wind_orientation = 0.5
  end

  local speed_factor = SpaceshipObstacles.particle_speed_factor(spaceship.speed)
  surface.wind_speed = 0.01 + 0.005 * speed_factor

  -- floating characters
  for _, jetpack in pairs(remote.call("jetpack", "get_jetpacks", {surface_index = spaceship.own_surface.index})) do
    jetpack.velocity.y = jetpack.velocity.y +
      0.000005 * time_passed * (spaceship.speed / Spaceship.speed_taper) ^ Spaceship.particle_speed_power * Spaceship.speed_taper
    remote.call("jetpack", "set_velocity", {unit_number = jetpack.unit_number, velocity = jetpack.velocity})
  end

  -- obstacles
  SpaceshipObstacles.tick_obstacles(spaceship, surface, time_passed)
end

---Sets the lighting of a spaceship surface. This dictates both how bright the player's screen is
---and solar power.
---@param spaceship SpaceshipType Spaceship data
---@param surface LuaSurface the spaceship's surface
function Spaceship.set_light(spaceship, surface)
    -- expect 15 is the max, 10 + 5 planets but reduced start position
    local light_percent = Zone.get_solar(spaceship)
    Zone.set_solar_and_daytime_for_space_zone(surface, light_percent)
end

-- Apply engines to speed.
---@param spaceship SpaceshipType
---@param time_passed integer
function Spaceship.apply_engine_thust(spaceship, time_passed)
  if spaceship.engines then
    for i = #spaceship.engines, 1, -1 do -- Reverse iteration for safe removal
      local engine_table = spaceship.engines[i]
      local engine = engine_table.entity
      if engine and engine.valid then
        if engine.active and engine.is_crafting() then
          local engine_proto = Spaceship.engines[engine.name]
          spaceship.speed = spaceship.speed
            + (spaceship.speed_multiplier or 1) * engine_table.efficiency * engine_proto.thrust * engine.crafting_speed
            * (engine.energy / engine_proto.max_energy) / (Spaceship.minimum_mass + spaceship.integrity_stress)
            * (Spaceship.speed_taper / (Spaceship.speed_taper + spaceship.speed))
            * time_passed
        end
      else
        table.remove(spaceship.engines, i)
      end
    end
  end

end

---@param spaceship SpaceshipType
---@param time_passed integer
function Spaceship.apply_drag(spaceship, time_passed)
  -- space_drag from imperfect vacuum
  -- streamline 0 = 110.45
  -- streamline 1 = 181.25
  local drag = Spaceship.space_drag * (2 - (spaceship.streamline or 0)) * time_passed
  spaceship.speed = spaceship.speed * (1 - drag) + Spaceship.minimum_impulse

  -- brake
  if spaceship.target_speed and spaceship.speed > spaceship.target_speed then
    spaceship.speed = math.min(spaceship.speed, math.max(spaceship.target_speed + 1, spaceship.speed - 0.001 * time_passed))
    spaceship.speed = math.min(spaceship.speed, math.max(spaceship.target_speed + 0.5, spaceship.speed - (spaceship.speed + 0.5 - spaceship.target_speed) * (1 - math.pow(0.999, time_passed))))
  end
  spaceship.max_speed = math.max(spaceship.speed, spaceship.max_speed or 0)
end

---Moves spaceship away from the current planet.
---@param spaceship SpaceshipType Spaceship data
---@param travel_speed number Speed at which to move
function Spaceship.move_from_planet(spaceship, travel_speed)
  spaceship.planet_gravity_well = math.max(0, spaceship.planet_gravity_well - travel_speed / Zone.travel_cost_planet_gravity)
  spaceship.travel_message = {"space-exploration.spaceship-travel-message-exiting-planet-gravity"}
end

---Moves given spaceship away from the current star at given speed.
---@param spaceship SpaceshipType Spaceship data
---@param travel_speed number Speed at which to move
function Spaceship.move_from_star(spaceship, travel_speed)
  spaceship.star_gravity_well = math.max(0, spaceship.star_gravity_well - travel_speed / Zone.travel_cost_star_gravity)
  spaceship.travel_message = {"space-exploration.spaceship-travel-message-exiting-star-gravity"}
end

---Moves a given spaceship towards a given position in intestellar space at a given speed.
---@param spaceship SpaceshipType Spaceship data
---@param travel_speed number Speed at which to move
---@param destination_stellar_position StellarPosition Target stellar position
function Spaceship.move_towards_interstellar_position(spaceship, travel_speed, destination_stellar_position)
  spaceship.near_stellar_object = nil
  spaceship.stellar_position = Util.move_to(spaceship.stellar_position, destination_stellar_position,
    travel_speed / Zone.travel_cost_interstellar)
  spaceship.travel_message = {"space-exploration.spaceship-travel-message-navigating-interstellar"}
end

---Moves a given spaceship towards a given position in intestellar space instantly.
---@param spaceship SpaceshipType Spaceship data
---@param travel_speed number Speed at which to move
---@param destination_stellar_position StellarPosition Target stellar position
function Spaceship.move_instant_interstellar_position(spaceship, travel_speed, destination_stellar_position)
  spaceship.stellar_position = table.deepcopy(destination_stellar_position)
  spaceship.space_distortion = 1 - travel_speed / Zone.travel_cost_space_distortion
  spaceship.travel_message = {"space-exploration.spaceship-travel-message-spatial-distortions"}
end

---Moves a given ship towards the a given space distortion at a given speed.
---@param spaceship SpaceshipType Spaceship data
---@param travel_speed number Speed at which to move
---@param destination_space_distorion number the distortion of the target (does not have to be 1 / at the anomaly)
function Spaceship.move_to_anomaly(spaceship, travel_speed, destination_space_distorion)
  spaceship.near_stellar_object = nil
  local delta_space_distortion = destination_space_distorion - spaceship.space_distortion
  if delta_space_distortion == 0 then
    spaceship.near = table.deepcopy(spaceship.destination)
    if spaceship.type == "spaceship" then Event.trigger("on_spaceship_near_zone", {spaceship_index=spaceship.index, zone_index=spaceship.near.index}) end
    spaceship.stopped = true
  else
    local space_distortion_travel = travel_speed / Zone.travel_cost_space_distortion
    -- step towards destination
    spaceship.space_distortion = spaceship.space_distortion
      + math.min(math.max(delta_space_distortion, -space_distortion_travel), space_distortion_travel)
    spaceship.travel_message = {"space-exploration.spaceship-travel-message-spatial-distortions"}
  end
end

---Moves a given spaceship away from the anomaly at a given speed.
---@param spaceship SpaceshipType the spaceship
---@param travel_speed number speed at which to move
function Spaceship.move_from_anomaly(spaceship, travel_speed)
  spaceship.space_distortion = math.max(0, spaceship.space_distortion - travel_speed / Zone.travel_cost_space_distortion)
  spaceship.travel_message = {"space-exploration.spaceship-travel-message-spatial-distortions"}
end

--- Move the spaceship through space conventionally (i.e. no teleportation/spatial distortion)
---@param spaceship SpaceshipType Spaceship data
---@param travel_speed number speed at which to move
---@param target_zone AnyZoneType|SpaceshipType
---@param destination_stellar_position StellarPosition
---@param destination_star_gravity_well integer
---@param destination_planet_gravity_well integer
function Spaceship.move_conventional(spaceship, travel_speed, target_zone, destination_stellar_position, destination_star_gravity_well, destination_planet_gravity_well)
  local interstellar_distance = Util.vectors_delta_length(spaceship.stellar_position, destination_stellar_position)
  if interstellar_distance == 0 then -- same system
    if spaceship.type == "spaceship" then -- not needed on spaceship-lookahead
      spaceship.near_star = Zone.get_star_from_child(target_zone) or Zone.get_star_from_position(target_zone)
      spaceship.near_stellar_object = Zone.get_stellar_object_from_child(target_zone) or Zone.get_stellar_object_from_position(target_zone)
    end
    if spaceship.star_gravity_well == destination_star_gravity_well then -- same planet system
      if spaceship.planet_gravity_well == destination_planet_gravity_well then -- we're here
        spaceship.near = table.deepcopy(spaceship.destination)
        if spaceship.type == "spaceship" then Event.trigger("on_spaceship_near_zone", {spaceship_index=spaceship.index, zone_index=spaceship.near.index}) end
        spaceship.stopped = true
      else
        local delta_planet_gravity = destination_planet_gravity_well - spaceship.planet_gravity_well
        local planet_gravity_travel = travel_speed / Zone.travel_cost_planet_gravity
        spaceship.planet_gravity_well = spaceship.planet_gravity_well
          + math.min(math.max(delta_planet_gravity, -planet_gravity_travel), planet_gravity_travel)
        spaceship.travel_message = {"space-exploration.spaceship-travel-message-navigating-planet-gravity"}
      end
    else
      if spaceship.planet_gravity_well > 0 then
        spaceship.planet_gravity_well = math.max(0, spaceship.planet_gravity_well - travel_speed / Zone.travel_cost_planet_gravity)
        spaceship.travel_message = {"space-exploration.spaceship-travel-message-exiting-planet-gravity"}
      else
        local delta_star_gravity = destination_star_gravity_well - spaceship.star_gravity_well
        local star_gravity_travel = travel_speed / Zone.travel_cost_star_gravity
        spaceship.star_gravity_well = spaceship.star_gravity_well
          + math.min(math.max(delta_star_gravity, -star_gravity_travel), star_gravity_travel)
        spaceship.travel_message = {"space-exploration.spaceship-travel-message-navigating-star-gravity"}
      end
    end
  else -- different systems
    if spaceship.planet_gravity_well > 0 then -- leave the planet gravity well
      Spaceship.move_from_planet(spaceship, travel_speed)
    elseif spaceship.star_gravity_well > 0 then -- leave the star gravity well
      Spaceship.move_from_star(spaceship, travel_speed)
    else -- match interstellar position
      Spaceship.move_towards_interstellar_position(spaceship, travel_speed, destination_stellar_position)
    end
  end
end

---Moves a given spaceship from its current position towards its destination.
---@param spaceship SpaceshipType Spaceship data
---@param time_passed number amount of time passed since the position of the spaceship was last updated
function Spaceship.move_to_destination(spaceship, time_passed)
  if not spaceship.destination then return end

  local target_zone = Spaceship.get_destination_zone(spaceship)
  if not target_zone then
    spaceship.destination = nil
    spaceship.travel_message = "No destination."
    Log.debug("Spaceship destination invalid")
    return
  end

  --Log.debug(game.tick .. " moving to destination.")
  -- move away from current zone
  if spaceship.near and not Spaceship.is_near_destination(spaceship) then
    --Log.debug(game.tick .. "Leaving zone.")
    spaceship.near = nil
    -- close any scouting views
    for _, player in pairs(game.connected_players) do
      local remote_view_activity = RemoteView.get_activity(player, "spaceship-anchor-scouting")
      if remote_view_activity and remote_view_activity.anchor_scouting.spaceship_index == spaceship.index then
        Spaceship.stop_anchor_scouting(player)
        player.print("Cannot anchor, spaceship has departed for a different destination.")
      end
    end
  end

  Spaceship.move_to_destination_basic(spaceship, target_zone, time_passed)

  local ship_surface = Spaceship.get_own_surface(spaceship)
  Spaceship.set_light(spaceship, ship_surface)
end

---Moves a spaceship or spaceship-lookahead.
---@param spaceship SpaceshipType Spaceship or spaceship-lookahead
---@param target_zone AnyZoneType|SpaceshipType Zone or spaceship
---@param time_passed number Time passed since the position of the spaceship was last updated
function Spaceship.move_to_destination_basic(spaceship, target_zone, time_passed)

  -- step towards destination
  local travel_speed = spaceship.speed * Spaceship.travel_speed_multiplier * time_passed
  local destination_space_distorion = Zone.get_space_distortion(target_zone)
  local destination_stellar_position = Zone.get_stellar_position(target_zone)
  local destination_star_gravity_well = Zone.get_star_gravity_well(target_zone)
  local destination_planet_gravity_well = Zone.get_planet_gravity_well(target_zone)

  spaceship.near_star = nil -- Currently recalculated every time anyway. Will (hopefully) be improved in #537

  if destination_space_distorion == 1 then -- target is anomaly (or spaceship at anomaly)
    if spaceship.planet_gravity_well > 0 then -- leave the planet gravity well
      Spaceship.move_from_planet(spaceship, travel_speed)
    elseif spaceship.star_gravity_well > 0 then -- leave the star gravity well
      Spaceship.move_from_star(spaceship, travel_speed)
    else -- move towards the anomaly
      Spaceship.move_to_anomaly(spaceship, travel_speed, destination_space_distorion)
    end
  elseif spaceship.space_distortion == 1 then -- at the anomaly so the stellar position can be anywhere instantly
    Spaceship.move_instant_interstellar_position(spaceship, travel_speed, destination_stellar_position)
  elseif destination_space_distorion > 0 then -- target is spaceship on way to/from anomaly
    local interstellar_distance = Util.vectors_delta_length(spaceship.stellar_position, destination_stellar_position)
    if spaceship.planet_gravity_well > 0 then -- leave the planet gravity well
      Spaceship.move_from_planet(spaceship, travel_speed)
    elseif spaceship.star_gravity_well > 0 then -- leave the star gravity well
      Spaceship.move_from_star(spaceship, travel_speed)
    elseif interstellar_distance > 0 then -- match interstellar position
      Spaceship.move_towards_interstellar_position(spaceship, travel_speed, destination_stellar_position)
    else -- move towards the anomaly
      Spaceship.move_to_anomaly(spaceship, travel_speed, destination_space_distorion)
    end
  elseif spaceship.space_distortion > 0 then -- leaving the anomaly
    Spaceship.move_from_anomaly(spaceship, travel_speed)
  else -- conventional travel to planet/star/spaceship
    Spaceship.move_conventional(spaceship, travel_speed, target_zone, destination_stellar_position, destination_star_gravity_well, destination_planet_gravity_well)
  end

end

---@param spaceship SpaceshipType
---@param event EventData.on_tick Event data
function Spaceship.spaceship_tick(spaceship, event)
  local valid_console = (spaceship.console and spaceship.console.valid) or false
  local update_tick_count = (valid_console and spaceship.console.unit_number + event.tick) or nil
  local should_service_spaceship_surface = Spaceship.is_on_own_surface(spaceship)

  -- update asteroid density
  if valid_console and should_service_spaceship_surface then
    if update_tick_count % Spaceship.tick_interval_density == 0 then
      spaceship.asteroid_density = 0
      if spaceship.speed > 5 then
        local target_zone = Spaceship.get_destination_zone(spaceship)
        if target_zone then
          local spaceship_lookahead = {
            type = "spaceship-lookahead",
            speed = spaceship.speed,
            stellar_position = spaceship.stellar_position,
            space_distortion = spaceship.space_distortion,
            star_gravity_well = spaceship.star_gravity_well,
            planet_gravity_well = spaceship.planet_gravity_well,
          }
          Spaceship.move_to_destination_basic(spaceship_lookahead, target_zone, 5 * 60) -- 5 seconds
          spaceship.future_asteroid_density = SpaceshipObstacles.get_asteroid_density(spaceship_lookahead)
        end
      end
      spaceship.asteroid_density = SpaceshipObstacles.get_asteroid_density(spaceship)
    end
  end

  if not valid_console then
    spaceship.check_message= {"space-exploration.spaceship-check-message-no-console"}
    spaceship.integrity_valid = false
  end

  -- Pause inserters, workaround for https://forums.factorio.com/viewtopic.php?f=58&t=89035
  -- Note: production machines should NOT be included as some are supposed to be disabled on specific surfaces.
  if spaceship.entities_to_restore and spaceship.entities_to_restore_tick < event.tick then
    for _, storedState in pairs(spaceship.entities_to_restore) do
      if storedState.entity and storedState.entity.valid then
        storedState.entity.active = storedState.active
      end
    end
    spaceship.entities_to_restore = nil
  end

  if valid_console or should_service_spaceship_surface then
    -- integrity check
    if spaceship.is_doing_check then
      if should_service_spaceship_surface and spaceship.known_floor_tiles and not spaceship.is_doing_check_slowly then
        -- need to tick faster on bigger ships
        for i = 0, math.ceil(spaceship.known_floor_tiles / 1000) do
          -- tick once for each 1000 tiles
          if spaceship.is_doing_check then
            SpaceshipIntegrity.integrity_check_tick(spaceship)
          end
        end
      else
        SpaceshipIntegrity.integrity_check_tick(spaceship)
      end
    elseif valid_console and update_tick_count % Spaceship.integrity_pulse_interval == 0 and spaceship.console.energy > 0 then
      SpaceshipIntegrity.start_slow_integrity_check(spaceship)
    end

    if valid_console and update_tick_count % 60 == 0 then

      -- Only tick the schedule if this spaceship can actually fly.
      SpaceshipScheduler.tick_schedule(spaceship, event.tick)

      -- set speed
      if spaceship.target_speed_source ~= "manual-override" then
        local signal_target_speed = spaceship.console.get_signal(Spaceship.signal_for_speed, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
        if signal_target_speed > 0 then
          spaceship.target_speed = signal_target_speed + 0.5
          spaceship.target_speed_source = "circuit"
        elseif signal_target_speed < 0 then
          spaceship.stopped = true
          spaceship.target_speed = nil
          spaceship.target_speed_source = "circuit"
        elseif not spaceship.stopped then
          -- 0 means use set targets
          local last_target_speed = spaceship.target_speed
          local asteroid_density = spaceship.asteroid_density or SpaceshipObstacles.default_asteroid_density
          if spaceship.future_asteroid_density and spaceship.future_asteroid_density > asteroid_density then
            asteroid_density = spaceship.future_asteroid_density
          end
          if asteroid_density == SpaceshipObstacles.default_asteroid_density then
            spaceship.target_speed = spaceship.target_speed_normal
            spaceship.target_speed_source = "normal"
          elseif asteroid_density == SpaceshipObstacles.asteroid_density_by_zone_type['asteroid-belt'] then
            spaceship.target_speed = spaceship.target_speed_belt or spaceship.target_speed_normal
            spaceship.target_speed_source = "asteroid-belt"
          elseif asteroid_density == SpaceshipObstacles.asteroid_density_by_zone_type['asteroid-field'] then
            spaceship.target_speed = spaceship.target_speed_field or spaceship.target_speed_belt or spaceship.target_speed_normal
            spaceship.target_speed_source = "asteroid-field"
          end
          -- target speed was set to nil which means the fields are empty and target speed should be unlimited
          if not spaceship.target_speed then
            if last_target_speed and spaceship.is_moving then Spaceship.activate_engines(spaceship) end -- if spaceship was being speed throttled then need to fire all engines now that it's unlimited (but only once)
            spaceship.target_speed_source = nil
          end
        end
      end

      if not spaceship.scheduler.active then
        -- Set the current destination through circuit.
        -- This is only done when the scheduler is not active.This allows the player
        -- to use destination signals as circuit wait conditions if required.
        for signal_name, type in pairs(Zone.signal_to_zone_type) do
          local value = spaceship.console.get_signal({type = "virtual", name = signal_name}, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
          if value > 0 then
            local zone = Zone.from_zone_index(value)
            if zone and zone.type == type then
              if Zone.is_visible_to_force(zone, spaceship.force_name) or storage.debug_view_all_zones then
                if (not spaceship.destination) or (spaceship.destination.type == "zone" and spaceship.destination.index ~= value) then
                  spaceship.destination = { type = "zone", index = value }
                  Spaceship.update_output_combinator(spaceship, event.tick)
                end
                break
              end
            end
          end
        end
        -- TODO: allow spaceship as destination

        -- Launch the spaceship if the signal is received
        -- This is only done when the scheduler is not active. This allows the player
        -- to use launch signal as circuit wait conditions if required.
        if not spaceship.on_own_surface and not spaceship.entities_to_restore then
          local value = spaceship.console.get_signal(Spaceship.signal_for_launch, defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red)
          if value > 0 then
            spaceship.stopped = false
            spaceship.is_launching = true
            spaceship.is_launching_automatically = true
            spaceship.is_landing = false
            SpaceshipIntegrity.start_integrity_check(spaceship)
          end
        end
      end

      -- land
      if should_service_spaceship_surface
       and not spaceship.entities_to_restore
       and spaceship.destination
       and spaceship.destination.type == "zone"
       and Spaceship.is_near_destination(spaceship) then
        Spaceship.attempt_anchor_spaceship(spaceship)
        should_service_spaceship_surface = Spaceship.is_on_own_surface(spaceship)
      end

    end

    -- delayed launch (either until the number of waiting chunk requests is finished or a maximum delay is reached)
    if spaceship.awaiting_requests and (spaceship.requests_made <= 0 or (event.tick - spaceship.await_start_tick) >= Spaceship.tick_max_await) then
      local params = spaceship.clone_params
      SpaceshipClone.clone(spaceship, params.clone_from, params.clone_to, params.clone_delta, nil)
      spaceship.awaiting_requests = false
      should_service_spaceship_surface = Spaceship.is_on_own_surface(spaceship)
      spaceship.clone_params = nil
      Event.trigger("on_spaceship_launched", {spaceship_index=spaceship.index})
      Event.trigger("on_spaceship_near_zone", {spaceship_index=spaceship.index, zone_index=spaceship.near.index})
    end

    -- don't upkeep the ship as if it is in-transit until it has actually cloned to the flying surface
    if should_service_spaceship_surface then
      -- space upkeep
      if event.tick % Spaceship.tick_interval_move == 0 then
        Spaceship.surface_tick(spaceship, Spaceship.tick_interval_move)
      end

      if spaceship.target_speed and spaceship.is_moving ~= true and spaceship.stopped then -- don't use == false
        spaceship.stopped = false
      end

      -- this has to be done every tick for seamless movement
      local surface = Spaceship.get_own_surface(spaceship)
      SpaceshipObstacles.tick_entity_obstacles(spaceship, surface)

      -- navigation
      if spaceship.integrity_valid
        and spaceship.destination
        and not spaceship.stopped
        and not Spaceship.is_near_destination(spaceship) then
          -- wants to move and can move
          if not spaceship.is_moving then
            spaceship.is_moving = true
            Spaceship.activate_engines(spaceship)
            SpaceshipIntegrity.start_integrity_check(spaceship)
          end

          if (event.tick % 6) == 0 then
            Spaceship.toggle_engines_for_target_speed(spaceship)
          end

          if event.tick % Spaceship.tick_interval_move == 0 then
            Spaceship.apply_engine_thust(spaceship, Spaceship.tick_interval_move)
            Spaceship.apply_drag(spaceship, Spaceship.tick_interval_move)
            Spaceship.move_to_destination(spaceship, Spaceship.tick_interval_move)
          end
      else
        -- can't move
        if spaceship.is_moving then
          spaceship.is_moving = false
          Spaceship.deactivate_engines(spaceship)
        end
        if Spaceship.is_near_destination(spaceship) then
          spaceship.speed = 0
          spaceship.travel_message = {"space-exploration.spaceship-travel-message-at-destination"}
        end
        if spaceship.speed > 0 then
          -- local drag = Spaceship.space_drag * (2 - (spaceship.streamline or 0)) -- Previous commit message was "This seems worse", and this variable is unused
          spaceship.speed = math.max(0, spaceship.speed * (1 - Spaceship.space_drag) - (spaceship.stopped and 0.1 or 0.02))
        end
      end
    end


  else
    -- Destroy the spaceship struct if the console is missing AND the spaceship is not flying
    Spaceship.destroy(spaceship)
    return
  end

  if valid_console and update_tick_count % Spaceship.tick_interval_output == 0 then
    Spaceship.update_output_combinator(spaceship, event.tick)
  end

end

---@param spaceship SpaceshipType
function Spaceship.toggle_engines_for_target_speed(spaceship)
  if spaceship.target_speed and spaceship.is_moving and spaceship.engines then
    local engine_probability = 1 / table_size(spaceship.engines)
    if spaceship.speed > spaceship.target_speed then
      for _, engine in pairs(spaceship.engines) do
        if engine.entity.valid and math.random() < engine_probability then
          engine.entity.active = false
          Spaceship.update_smoke(spaceship, engine)
        end
      end
    else
      for _, engine in pairs(spaceship.engines) do
        if engine.entity.valid and math.random() < engine_probability then
          engine.entity.active = true
          Spaceship.update_smoke(spaceship, engine)
        end
      end
    end
  end
end

---@param tick uint Current tick
function Spaceship.update_output_combinator(spaceship, tick)

  if not (spaceship.console and spaceship.console.valid) then return end
  if not (spaceship.console_output and spaceship.console_output.valid) then
    -- spawn the console output
    local console = spaceship.console
    local output_position = util.vectors_add(console.position, Spaceship.console_output_offset)
    local output = util.find_entity_or_revive_ghost(console.surface, Spaceship.name_spaceship_console_output, output_position)
    if not output then
      output = console.surface.create_entity{
        name = Spaceship.name_spaceship_console_output,
        position = util.vectors_add(console.position, Spaceship.console_output_offset),
        force = console.force,
        create_build_effect_smoke = false,
      }
      ---@cast output -?
    end
    spaceship.console_output = output
  end
  if spaceship.console_output and spaceship.console_output.valid then
    local ctrl = spaceship.console_output.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]

    if not ctrl.get_section(1) then
      ctrl.add_section()
    end

    local slot = 1
    -- Spaceship ID
    ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_own_spaceship_id, min=spaceship.index})
    slot = slot + 1
    -- Speed
    if spaceship.is_moving and spaceship.speed > 0 then
      ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_speed, min=math.max(1, spaceship.speed)})
    elseif Spaceship.is_on_own_surface(spaceship) then
      ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_speed, min=-1}) -- stopped
    else
      ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_speed, min=-2}) -- anchored
    end
    slot = slot + 1

    -- Distance
    if (not spaceship.distance_to_destination_tick) or spaceship.distance_to_destination_tick + 60 < tick then
      spaceship.distance_to_destination = Spaceship.get_distance_to_destination(spaceship)
      spaceship.distance_to_destination_tick = tick
    end

    if spaceship.destination and Spaceship.is_near_destination(spaceship) then
      ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_distance, min=-1})
    elseif spaceship.destination and Spaceship.is_at_destination(spaceship)  then
      ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_distance, min=-2})
    elseif spaceship.distance_to_destination and spaceship.distance_to_destination > 0 then
      ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_distance, min=math.max(1, spaceship.distance_to_destination)})
    else --no destination
      ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_distance, min=-3})
    end
    slot = slot + 1

    -- Destination
    if spaceship.destination then
      if spaceship.destination.type == "spaceship" then
        ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_destination_spaceship, min=spaceship.destination.index})
      elseif spaceship.destination.type == "zone" then
        local zone = Spaceship.get_destination_zone(spaceship)
        local signal_name = Zone.get_signal_name(zone)
        ctrl.get_section(1).set_slot(slot, {value={type="virtual", name=signal_name, quality="normal"}, min=zone.index})
      else
        ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_destination_spaceship, min=0})
      end
    else
      ctrl.get_section(1).set_slot(slot, {value=Spaceship.signal_for_destination_spaceship, min=0})
    end
    slot = slot + 1

    -- Asteroid Density
    if spaceship.asteroid_density then
      ctrl.get_section(1).set_slot(slot, {value={type = "virtual", name = "signal-D", quality="normal"}, min=spaceship.asteroid_density * 100})
    else
      ctrl.get_section(1).set_slot(slot, {value={type = "virtual", name = "signal-D", quality="normal"}, min=SpaceshipObstacles.default_asteroid_density * 100})
    end
    slot = slot + 1

    -- Anchor (only change if the ship is not in the middle of launching)
    if not spaceship.awaiting_requests then
      if spaceship.zone_index then
        ctrl.get_section(1).set_slot(slot, {value={type = "virtual", name = "signal-A", quality="normal"}, min=spaceship.zone_index})
      else
        ctrl.get_section(1).set_slot(slot, {value={type = "virtual", name = "signal-A", quality="normal"}, min=0})
      end
      slot = slot + 1
    end
  end
end

--- Updates all spaceships, potentially launching/landing them or spawning/destroying/changing speed of obstacles
--- or updating their guis or updating anchor scoutin
---@param event EventData.on_tick Event data
function Spaceship.on_tick(event)
  -- update spaceships
  for _, spaceship in pairs(storage.spaceships) do
    Spaceship.spaceship_tick(spaceship, event)
  end

  -- update guis
  if event.tick % Spaceship.tick_interval_gui == 0 then
    for _, player in pairs(game.connected_players) do
      SpaceshipGUI.gui_update(player, event.tick)
    end
  end

  -- update obstacles
  SpaceshipObstacles.tick_projectile_speeds()

  -- update anchoring
  if event.tick % Spaceship.tick_interval_anchor == 0 then
    for _, player in pairs(game.connected_players) do
      Spaceship.anchor_scouting_tick(player)
    end
  end
end
Event.addListener(defines.events.on_tick, Spaceship.on_tick)

---@param surface LuaSurface
---@param position MapPosition
---@param color Color
---@param time uint
function Spaceship.flash_tile(surface, position, color, time)
  local a = (color.a or 1)
  rendering.draw_rectangle{
    color = {r = color.r * a, g = color.g * a, b = color.b * a, a = a},
    filled = true,
    left_top = position,
    right_bottom = {(position.x or position[1])+1, (position.y or position[2])+1},
    surface = surface,
    time_to_live = time
  }
end

--[[========================================================================================
Blueprinting and copy/pasting settings
]]--

---@param spaceship SpaceshipType?
---@return Tags?
function Spaceship.serialize_from_struct(spaceship)
  if not spaceship then return end

  local tags = {}

  tags.name = spaceship.name

  tags.target_speed_normal = spaceship.target_speed_normal
  tags.target_speed_field = spaceship.target_speed_field
  tags.target_speed_belt = spaceship.target_speed_belt

  tags.scheduler = {
    -- Only copy over the schedule group name, because there is no guarentee that
    -- zone indexes will be the same across different saves.
    -- Also only copy over the schedule group name if the current spaceship is unassigned
    schedule_group_name = (not SpaceshipScheduler.is_unassigned(spaceship)) and spaceship.scheduler.schedule_group_name or nil,
  }

  return tags
end

---@param entity LuaEntity
---@return Tags?
function Spaceship.serialize(entity)
  return Spaceship.serialize_from_struct(Spaceship.from_entity(entity))
end

---@param entity LuaEntity
---@param tags Tags
function Spaceship.deserialize(entity, tags)
  local spaceship = Spaceship.from_entity(entity)
  if not spaceship then return end

  if tags.name then -- Guard against old blueprints not containing this tag
    Spaceship.rename(spaceship, tostring(tags.name))
  end

  spaceship.target_speed_normal = tonumber(tags.target_speed_normal)
  spaceship.target_speed_field = tonumber(tags.target_speed_field)
  spaceship.target_speed_belt = tonumber(tags.target_speed_belt)

  if tags.scheduler then -- Guard against old blueprints not containing this tag
    local scheduler = spaceship.scheduler

    -- Set the new spaceship to use the other spaceships group.
    -- If the other spaceship was unassigned then the new spaceship should also be unassigned.
    local new_group_name = tags.scheduler.schedule_group_name or SpaceshipScheduler.get_unassigned_group_name(spaceship)
    SpaceshipScheduler.change_spaceship_schedule_group(spaceship, new_group_name)
  end

end

---@param event EventData.on_player_pipette
local function on_player_pipette(event)
  local player = game.get_player(event.player_index) --[[@cast player -?]]

  -- Fix the case where the player pipette's the console output and end
  -- up with a hidden entity in their cursor. The expected behavior would
  -- be having the console itself.
  local item = event.item
  if not (item and item.valid) then return end
  if item.name == "se-struct-generic-output" then
    -- Player pipette'd the console output, so we need to redirect to the console!
    local selected = player.selected -- Should be the hidden external pole entity
    if not selected then return end
    local console = selected.surface.find_entity(Spaceship.name_spaceship_console, selected.position)
    if not console then return end -- Should never happen. The console output should always have an assosiated console.
    -- Remove the console output item stack from the cursor
    player.cursor_stack.clear()
    player.pipette_entity(console)
  end
end
Event.addListener(defines.events.on_player_pipette, on_player_pipette)

---@param event EventData.on_player_setup_blueprint
local function on_player_setup_blueprint(event)
  util.setup_blueprint(event, {Spaceship.name_spaceship_console}, Spaceship.serialize)
end
Event.addListener(defines.events.on_player_setup_blueprint, on_player_setup_blueprint)

---@param event EventData.on_entity_settings_pasted
local function on_entity_settings_pasted(event)
  util.settings_pasted(event, {Spaceship.name_spaceship_console}, Spaceship.serialize, Spaceship.deserialize)
  local spaceship = Spaceship.from_entity(event.destination)
  if spaceship then
    SpaceshipScheduler.deactivate(spaceship)
    SpaceshipSchedulerGUI.rebuild(spaceship)
  end
end
Event.addListener(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)

--[[========================================================================================
Initialization
]]--

function Spaceship.on_init()
    storage.spaceships = {}
    SpaceshipIntegrity.clean_integrity_affecting_tables()
    storage.next_spaceship_index = 1
end
Event.addListener("on_init", Spaceship.on_init, true)

function Spaceship.on_load()
  SpaceshipIntegrity.clean_integrity_affecting_tables()
end
Event.addListener("on_load", Spaceship.on_load, true)


return Spaceship
