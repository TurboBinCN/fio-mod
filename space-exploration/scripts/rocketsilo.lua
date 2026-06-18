
--/c pod = game.player.surface.create_entity{name="se-space-capsule-pod", position={30,0}} pod.cargo_pod_destination = {type = defines.cargo_destination.station, station=game.player.surface.find_entities_filtered{name="cargo-landing-pad"}[1]}

local Rocketsilo = {}

Rocketsilo.type_basic_rocket_silo = "basic-rocket-silo"
Rocketsilo.name_rocket_silos = {
  "rocket-silo",
  mod_prefix.."space-probe-rocket-silo"
}

--[[
---@param event EventData.on_rocket_launched Event data
function Rocketsilo.on_rocket_launched(event)
  if event.rocket and event.rocket.valid then
    local silo = event.rocket_silo
    Log.debug("Rocketsilo.on_rocket_launched: " .. silo.unit_number)
  end
end
Event.addListener(defines.events.on_rocket_launched, Rocketsilo.on_rocket_launched)
]]

---@param cargo_pod LuaEntity
---@return boolean
function Rocketsilo.may_override_destination(cargo_pod)
  local destination = cargo_pod.cargo_pod_destination

  if destination.type == defines.cargo_destination.space_platform then
    return false -- starter pack
  end

  if destination.type == defines.cargo_destination.station and destination.station and destination.station.type == "space-platform-hub" then
    return false -- for platform
  end

  return true
end

---@param event EventData.on_rocket_launch_ordered Event data
function Rocketsilo.on_rocket_launch_ordered(event)
  local rocket = event.rocket
  if rocket.valid and Rocketsilo.may_override_destination(rocket.cargo_pod) and util.table_contains(Rocketsilo.name_rocket_silos, event.rocket_silo.name) then
    local rocket_silo = Rocketsilo.from_entity(event.rocket_silo) -- struct
    if rocket_silo then
      Rocketsilo.rocket_require_destination(rocket_silo)
    end
  end
end
Event.addListener(defines.events.on_rocket_launch_ordered, Rocketsilo.on_rocket_launch_ordered)

---@param rocket_silo RocketSiloInfo
function Rocketsilo.tick(rocket_silo)
  if not rocket_silo.entity.valid then
    return Rocketsilo.destroy(rocket_silo)
  end
  local rocket = rocket_silo.entity.rocket
  if rocket and not rocket.active then
    -- the rocket was paused waiting for a landing spot.
    Rocketsilo.rocket_require_destination(rocket_silo)
  end
end


--[[
---@param event EventData.on_cargo_pod_finished_ascending  Event data
function Rocketsilo.on_cargo_pod_finished_ascending (event)
  if event.cargo_pod and event.cargo_pod.valid and event.launched_by_rocket then
    local rocket = event.cargo_pod.rocket
    local silo = event.rocket_silo
    Log.debug("Rocketsilo.on_cargo_pod_finished_ascending : " .. silo.unit_number)
  end
end
Event.addListener(defines.events.on_cargo_pod_finished_ascending , Rocketsilo.on_cargo_pod_finished_ascending )
]]

---Find a landing spot for the rocket and reserve it, otherwise deactivate the rocket.
---@param rocket_silo RocketSiloInfo
function Rocketsilo.rocket_require_destination(rocket_silo)
  local landing_pad_name = rocket_silo.destination and rocket_silo.destination.landing_pad_name
  local landing_pad
  local inbound_type = "cargo-pod"
  if not landing_pad_name then
    rocket_silo.entity.rocket.cargo_pod.cargo_pod_destination = {
      type = defines.cargo_destination.surface,
      surface = rocket_silo.entity.surface,
      position = rocket_silo.entity.surface.find_non_colliding_position("cargo-pod-container", rocket_silo.entity.position, 32, 0.5),
      transform_launch_products = true
    }
    Log.debug("Rocketsilo.on_rocket_launch_ordered: send results to close to silo")
    rocket_silo.entity.rocket.active = true
    local force_name = rocket_silo.entity.force.name
    if storage.forces[force_name] then
      storage.forces[force_name].basic_rocket_launches = (storage.forces[force_name].basic_rocket_launches or 0) + 1
    end
    return
  else
    local landing_pads = Landingpad.get_zone_landing_pads_availability(rocket_silo.force_name, rocket_silo.zone, landing_pad_name)
    -- try to go to an empty one
    if #landing_pads.empty_landing_pads > 0 then
      landing_pad = landing_pads.empty_landing_pads[math.random(#landing_pads.empty_landing_pads)]
    end
    -- else check for space in one without and inboud rocket
    if not landing_pad then
      if #landing_pads.filled_landing_pads > 0 then
        Util.shuffle(landing_pads.filled_landing_pads)
        for _, try_landingpad in pairs(landing_pads.filled_landing_pads) do
          if Landingpad.has_space_for_inbound(try_landingpad, inbound_type) then
            landing_pad = try_landingpad
            break
          end
        end
      end
    end
    -- else check for space in one with an inbound rocket
    if not landing_pad then
      if #landing_pads.blocked_landing_pads > 0 then
        Util.shuffle(landing_pads.blocked_landing_pads)
        for _, try_landingpad in pairs(landing_pads.blocked_landing_pads) do
          if Landingpad.has_space_for_inbound(try_landingpad, inbound_type) then
            landing_pad = try_landingpad
            break
          end
        end
      end
    end
  end
  if landing_pad then
    Landingpad.add_inbound(landing_pad, inbound_type)
    rocket_silo.entity.rocket.cargo_pod.cargo_pod_destination = {
      type = defines.cargo_destination.station,
      station = landing_pad.container,
      transform_launch_products = true
    }
    Log.debug("Rocketsilo.on_rocket_launch_ordered: send results to landing pad " .. landing_pad.container.unit_number)
    rocket_silo.entity.rocket.active = true
    local force_name = rocket_silo.entity.force.name
    if storage.forces[force_name] then
      storage.forces[force_name].basic_rocket_launches = (storage.forces[force_name].basic_rocket_launches or 0) + 1
      storage.forces[force_name].any_basic_rocket_launched_targeting_a_landing_pad = true
    end
  else
    rocket_silo.entity.rocket.active = false
  end
end


--- Gets the Rocketsilo for this unit_number
---@param unit_number number
---@return RocketSiloInfo? rocket_silo
function Rocketsilo.from_unit_number (unit_number)
  if not unit_number then Log.debug("Rocketsilo.from_unit_number: invalid unit_number: nil") return end
  unit_number = tonumber(unit_number) --[[@as number]]
  if storage.basic_rocket_silos[unit_number] then
    return storage.basic_rocket_silos[unit_number]
  else
    Log.debug("Rocketsilo.from_unit_number: invalid unit_number: " .. unit_number)
  end
end

--- Gets the Rocketsilo for this entity
---@param entity LuaEntity
function Rocketsilo.from_entity (entity)
  if not(entity and entity.valid) then
    Log.debug("Rocketsilo.from_entity: invalid entity")
    return
  end
  return Rocketsilo.from_unit_number(entity.unit_number)
end

---@param event EntityCreationEvent|EventData.on_entity_cloned Event data
function Rocketsilo.on_entity_created(event)
  local entity = event.entity or event.destination
  if not entity.valid then return end

  if script.active_mods["space-age"] then
    if entity.name == "rocket-silo" then
      if Zone.from_surface(entity.surface) == nil then
        local new_entity = entity.surface.create_entity{
          name = "sa-rocket-silo",
          force = entity.force,
          position = entity.position,
          raise_built = true,
        }
        if entity.item_request_proxy then
          entity.surface.create_entity{
            name = "item-request-proxy",
            force = entity.force,
            position = entity.position,
            target = new_entity,
            modules = entity.item_request_proxy.insert_plan,
          }
        end
        entity.destroy()
        return
      end
    elseif entity.name == "sa-rocket-silo" then
      if Zone.from_surface(entity.surface) ~= nil then
        local new_entity = entity.surface.create_entity{
          name = "rocket-silo",
          force = entity.force,
          position = entity.position,
          raise_built = true,
        }
        if entity.item_request_proxy then
          entity.surface.create_entity{
            name = "item-request-proxy",
            force = entity.force,
            position = entity.position,
            target = new_entity,
            modules = entity.item_request_proxy.insert_plan,
          }
        end
        entity.destroy()
        return
      end
    end
  end

  if not util.table_contains(Rocketsilo.name_rocket_silos, entity.name) then return end

  local force_name = entity.force.name
  local surface = entity.surface
  local zone = Zone.from_surface(surface)
  local position = entity.position

  if cancel_creation_when_invalid(zone, entity, event) then return end

  --[[
  -- This was from when a landingpad on the surface was an engine requirement.
  local default_destination_zone = zone

  if zone.orbit then
    ---@type OrbitType
    default_destination_zone = zone.orbit
  elseif zone.parent and zone.parent.type ~= "star" then
    ---@type PlanetType|MoonType
    default_destination_zone = zone.parent
  end
  local destination {
    landing_pad_name = zone.name .. " Landing Pad"
  }
  ]]

  ---@type RocketSiloInfo
  local struct = {
    type = Rocketsilo.type_basic_rocket_silo,
    valid = true,
    force_name = force_name,
    unit_number = entity.unit_number,
    entity = entity,
    zone = zone,
    --destination = destination
  }

  storage.basic_rocket_silos[entity.unit_number] = struct
  --Log.debug("Rocketsilo: basic rocket silo added")

  local tags = util.get_tags_from_event(event, Rocketsilo.serialize)
  if tags then
    Rocketsilo.deserialize(entity, tags)
  end

  -- Open GUI
  if event.player_index then
    local player = game.get_player(event.player_index)
    ---@cast player -?
    RocketsiloGUI.gui_open(player, struct)
  end

  -- First time hint
  if storage.forces[force_name] and storage.forces[force_name].basic_rocket_launches == 0 then
    game.forces[force_name].print({"space-exploration.rocket-silo-first-hint"})
  end
end
Event.addListener(defines.events.on_entity_cloned, Rocketsilo.on_entity_created)
Event.addOnEntityCreatedListeners(Rocketsilo.on_entity_created)

---@param struct RocketSiloInfo
---@param event? EntityRemovalEvent the event that triggered the destruction if it was caused by an event
function Rocketsilo.destroy(struct, event)
  if not struct then
    Log.debug("struct_destroy: no struct")
    return
  end

  struct.valid = false

  if struct.entity and struct.entity.valid and struct.entity.rocket and struct.entity.rocket.active == false then
    struct.entity.rocket.destroy()
  end

  if not event or event.name ~= defines.events.on_entity_died then
    -- For died it will be cleaned in post_died event
    storage.basic_rocket_silos[struct.unit_number] = nil
  end

  -- if a player has this gui open then close it
  local gui_name = RocketsiloGUI.name_rocket_silo_gui_root
  for _, player in pairs(game.connected_players) do
    local root = player.gui.relative[gui_name]
    if root and root.tags and root.tags.unit_number ==  struct.unit_number then
      root.destroy()
    end
  end
end

---@param struct RocketSiloInfo
---@param landing_pad_name string
function Rocketsilo.set_destination(struct, landing_pad_name)
  if landing_pad_name and landing_pad_name ~= "" then
    struct.destination = {landing_pad_name = landing_pad_name}
    Log.debug("set destination to landing_pad " .. landing_pad_name )
  else
    struct.destination = nil
  end
end

---A best guess attempt wether the cargo pod got requested by the destination or is merely landing there
---(this initial version only very crudely checks if none of the items in the pod show up in the logistic sections AT ALL, ignoring disabled & satisfied)
---@return boolean
local function is_trash_delivery(cargo_pod)
  local contents = cargo_pod.get_inventory(defines.inventory.cargo_unit).get_contents()
  local requests = cargo_pod.cargo_pod_destination.station.get_logistic_point(defines.logistic_member_index.cargo_landing_pad_requester)

  local item_name_map = {}
  for _, item in ipairs(contents) do
    item_name_map[item.name] = true
  end

  for _, section in ipairs(requests.sections) do
    for _, filter in ipairs(section.filters) do
      if filter.value and filter.value.type == "item" and item_name_map[filter.value.name] and filter.max ~= 0 then
        return false
      end
    end
  end

  return true
end

---Prevents space platform trash from showing up in renamed cargo landing pads (note: event does not trigger for rocket launches)
---@param event EventData.on_cargo_pod_started_ascending
function Rocketsilo.on_cargo_pod_started_ascending(event)
  local cargo_pod = event.cargo_pod
  if not cargo_pod.valid then return end
  if not cargo_pod.surface.platform then return end

  if cargo_pod.cargo_pod_destination.type == defines.cargo_destination.station then
    local station = cargo_pod.cargo_pod_destination.station
    local landing_pad = Landingpad.from_entity(station)
    if not landing_pad then return end

    local default_name = Landingpad.get_default_name(landing_pad.zone)
    if landing_pad.name == default_name then
      return -- the cargo pod from the platform is already targeting a (random) landing pad with the default name
    end

    -- only trash deliveries should get rerouted at all
    if not is_trash_delivery(cargo_pod) then return end

    -- try to find a cargo landing pad with the default name to send it to instead
    local zone = landing_pad.zone
    local rocket_landing_pad_names = Zone.get_force_assets(cargo_pod.force.name, zone.index)["rocket_landing_pad_names"]
    local rocket_landing_pads = rocket_landing_pad_names[default_name] or {}
    for _, rocket_landing_pad in pairs(rocket_landing_pads) do -- todo: random order here too
      if rocket_landing_pad.container.valid then -- if the chosen landing pad is full the items will spill around it automatically
        Log.debug_log_without_print(string.format("Rocketsilo.on_cargo_pod_started_ascending: rerouting cargo pod for \"%s\" from \"%s\" to \"%s\".", zone.name, landing_pad.name, default_name))
        cargo_pod.cargo_pod_destination = {
          type = defines.cargo_destination.station,
          station = rocket_landing_pad.container,
        }
        return
      end
    end

    -- fallback to landing near spawn
    Log.debug_log_without_print(string.format("Rocketsilo.on_cargo_pod_started_ascending: rerouting cargo pod for \"%s\" from \"%s\" to {0, 0}.", zone.name, landing_pad.name))
    cargo_pod.cargo_pod_destination = {
      type = defines.cargo_destination.surface,
      surface = station.surface,
      position = {0, 0}, -- if the position is nil the game still assigns a cargo landing pad
    }
  end
end
Event.addListener(defines.events.on_cargo_pod_started_ascending, Rocketsilo.on_cargo_pod_started_ascending)

---@param event EntityRemovalEvent Event data
function Rocketsilo.on_entity_removed(event)
  local entity = event.entity
  if entity and entity.valid and util.table_contains(Rocketsilo.name_rocket_silos, entity.name) then
    Rocketsilo.destroy(Rocketsilo.from_entity(entity), event)
  end
end
Event.addOnEntityRemovedListeners(Rocketsilo.on_entity_removed)

---@param event EventData.on_post_entity_died
local function on_post_entity_died(event)
  local ghost = event.ghost
  local unit_number = event.unit_number
  if not (ghost and unit_number) then return end
  if not util.table_contains(Rocketsilo.name_rocket_silos, event.prototype.name) then return end
  ghost.tags = Rocketsilo.serialize_from_struct(storage.basic_rocket_silos[unit_number])
  storage.basic_rocket_silos[unit_number] = nil
end
Event.addListener(defines.events.on_post_entity_died, on_post_entity_died)

---@param rocket_silo RocketSiloInfo?
---@return Tags?
function Rocketsilo.serialize_from_struct(rocket_silo)
  if rocket_silo then
    local tags = {}
    tags.landing_pad_name = rocket_silo.destination and rocket_silo.destination.landing_pad_name
    return tags
  end
end

---@param entity LuaEntity
---@return Tags?
function Rocketsilo.serialize(entity)
  return Rocketsilo.serialize_from_struct(Rocketsilo.from_entity(entity))
end

---@param entity LuaEntity
---@param tags Tags
function Rocketsilo.deserialize(entity, tags)
  local rocket_silo = Rocketsilo.from_entity(entity)
  if rocket_silo then
    rocket_silo.destination = rocket_silo.destination or {}
    if tags.landing_pad_name then
      rocket_silo.destination.landing_pad_name = tags.landing_pad_name
    else
      rocket_silo.destination.landing_pad_name = nil
    end
  end
end

--- Handles the player creating a blueprint by setting tags to store the state of rocket silos
---@param event EventData.on_player_setup_blueprint Event data
function Rocketsilo.on_player_setup_blueprint(event)
  util.setup_blueprint(event, Rocketsilo.name_rocket_silos, Rocketsilo.serialize)
end
Event.addListener(defines.events.on_player_setup_blueprint, Rocketsilo.on_player_setup_blueprint)

--- Handles the player copy/pasting settings between rocket silos
---@param event EventData.on_entity_settings_pasted Event data
function Rocketsilo.on_entity_settings_pasted(event)
  util.settings_pasted(event, Rocketsilo.name_rocket_silos, Rocketsilo.serialize, Rocketsilo.deserialize)
end
Event.addListener(defines.events.on_entity_settings_pasted, Rocketsilo.on_entity_settings_pasted)

function Rocketsilo.on_init()
  storage.basic_rocket_silos = {}
end
Event.addListener("on_init", Rocketsilo.on_init, true)

function Rocketsilo.on_nth_tick_60(event)
  for _, struct in pairs(storage.basic_rocket_silos) do
    Rocketsilo.tick(struct)
  end

  -- update guis
  for _, player in pairs(game.connected_players) do
    RocketsiloGUI.gui_update(player)
  end
end
Event.addListener("on_nth_tick_60", Rocketsilo.on_nth_tick_60)


return Rocketsilo
