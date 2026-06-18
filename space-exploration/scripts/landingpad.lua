local Landingpad = {}

-- constants
--Landingpad.name_rocket_landing_pad = mod_prefix.."rocket-landing-pad"
Landingpad.name_rocket_landing_pad = "cargo-landing-pad"
Landingpad.name_rocket_landing_pad_settings = mod_prefix.."rocket-landing-pad-settings"

Landingpad.grace_period = 5 * 60 -- delay the first send so there's time to rename.
--Landingpad.inventory_id = defines.inventory.chest
Landingpad.inventory_id = defines.inventory.cargo_landing_pad_main
Landingpad.hatch_offset = { x = 1.25, y = -4}
Landingpad.inbound_reserve = {
  ["cargo-pod"] = 20, -- max from probe
  ["cargo-rocket"] = Launchpad.rocket_capacity + 11 -- cargo + recovered parts + capsule
}

---Gets the RocketLandingPadInfo object for a given unit number.
---@param unit_number uint
---@return RocketLandingPadInfo?
function Landingpad.from_unit_number (unit_number)
  if not unit_number then Log.debug("Landingpad.from_unit_number: invalid unit_number: nil") return end
  unit_number = tonumber(unit_number)
  -- NOTE: only supports container as the entity
  if storage.rocket_landing_pads[unit_number] then
    return storage.rocket_landing_pads[unit_number]
  else
    Log.debug("Landingpad.from_unit_number: invalid unit_number: " .. unit_number)
  end
end

--- Gets the Landingpad for this entity
---@param entity LuaEntity
function Landingpad.from_entity (entity)
  if not(entity and entity.valid) then
    Log.debug("Landingpad.from_entity: invalid entity")
    return
  end
  -- NOTE: only suppors container as the entity
  return Landingpad.from_unit_number(entity.unit_number)
end

---Returns the available landing pads belonging to a given force in any zone.
---@param force_name string Force name
---@param landing_pad_name string Landing pad name to search for
---@return {empty_landing_pads: RocketLandingPadInfo[], filled_landing_pads: RocketLandingPadInfo[], blocked_landing_pads: RocketLandingPadInfo[]} grouped_landing_pads
function Landingpad.get_force_landing_pads_availability(force_name, landing_pad_name)

  local empty_landing_pads = {}
  local filled_landing_pads = {}
  local blocked_landing_pads = {}

  if storage.forces[force_name] and storage.forces[force_name].rocket_landing_pad_names and storage.forces[force_name].rocket_landing_pad_names[landing_pad_name] then
    local landing_pads = storage.forces[force_name].rocket_landing_pad_names[landing_pad_name]

    for _, landing_pad in pairs(landing_pads) do
      if landing_pad.container and landing_pad.container.valid then
        if landing_pad.inbound or landing_pad.container.to_be_deconstructed() then
          table.insert(blocked_landing_pads, landing_pad)
        elseif landing_pad.container.get_inventory(Landingpad.inventory_id).is_empty() then
          table.insert(empty_landing_pads, landing_pad)
        else
          table.insert(filled_landing_pads, landing_pad)
        end
      else
        Landingpad.destroy(landing_pad)
      end
    end

  end

  return {
    empty_landing_pads = empty_landing_pads,
    filled_landing_pads = filled_landing_pads,
    blocked_landing_pads = blocked_landing_pads,
  }

end

---Returns the available landing pads belonging to a given force _in a given zone_.
---@param force_name string Force name
---@param zone AnyZoneType Zone to search for landing pads
---@param landing_pad_name string Landing pad name to search for
---@return {empty_landing_pads: RocketLandingPadInfo[], filled_landing_pads: RocketLandingPadInfo[], blocked_landing_pads: RocketLandingPadInfo[]} grouped_landing_pads
function Landingpad.get_zone_landing_pads_availability(force_name, zone, landing_pad_name)

  local tick = game.tick

  local empty_landing_pads = {}
  local filled_landing_pads = {}
  local blocked_landing_pads = {}

  local zone_assets = Zone.get_force_assets(force_name, zone.index)
  if zone_assets.rocket_landing_pad_names and zone_assets.rocket_landing_pad_names[landing_pad_name] then
    local landing_pads = zone_assets.rocket_landing_pad_names[landing_pad_name]


    for _, landing_pad in pairs(landing_pads) do
      if landing_pad.container and landing_pad.container.valid then
        if landing_pad.inbound or landing_pad.container.to_be_deconstructed() or (landing_pad.grace_period_until and tick < landing_pad.grace_period_until) then
          table.insert(blocked_landing_pads, landing_pad)
        elseif landing_pad.container.get_inventory(Landingpad.inventory_id).is_empty() then
          table.insert(empty_landing_pads, landing_pad)
        else
          table.insert(filled_landing_pads, landing_pad)
        end
      else
        Landingpad.destroy(landing_pad)
      end
    end

  end

  return {
    empty_landing_pads = empty_landing_pads,
    filled_landing_pads = filled_landing_pads,
    blocked_landing_pads = blocked_landing_pads,
  }

end

---@param zone AnyZoneType
function Landingpad.get_default_name(zone)
  return zone.name .. " Landing Pad"
end

---Creates a RocketLandingPadInfo object upon creation of a landing pad by a force.
---@param event EntityCreationEvent|EventData.on_entity_cloned Event data
function Landingpad.on_entity_created(event)
  local entity = util.get_entity_from_event(event)
  if not entity then return end

  if script.active_mods["space-age"] then
    -- SE does not use cargo bay stuff
    if entity.name == "cargo-bay" then
      local zone = Zone.from_surface(entity.surface)
      if zone then
        cancel_entity_creation(entity, event.player_index, {"space-exploration.construction-denied-surface-with-zone"}, event)
        return
      end
    end

    -- swap SA landing pads for SE when in a zone
    if entity.name == "sa-cargo-landing-pad" then
      local zone = Zone.from_surface(entity.surface)
      if zone then
        entity.surface.create_entity{
          name = Landingpad.name_rocket_landing_pad,
          force = entity.force,
          position = entity.position,
          raise_built = true,
        }
        entity.destroy()
        return
      end
    end

    -- swap SE landing pads for SA when there is no zone here
    if entity.name == Landingpad.name_rocket_landing_pad then
      local zone = Zone.from_surface(entity.surface)
      if zone == nil then
        entity.surface.create_entity{
          name = "sa-cargo-landing-pad",
          force = entity.force,
          position = entity.position,
          raise_built = true,
        }
        entity.destroy()
        return
      end
    end
  end

  if entity.name == Landingpad.name_rocket_landing_pad then
    local zone = Zone.from_surface(entity.surface)
    if cancel_creation_when_invalid(zone, entity, event) then return end

    -- Prevent logistic robots from taking items out of the main inventory (allowing trash pickup and requesting from platforms)
    for _, logistic_point in pairs(entity.get_logistic_point() or {}) do
      if logistic_point.logistic_member_index == defines.logistic_member_index.cargo_landing_pad_provider then
        logistic_point.enabled = false
      end
    end

    if storage.rocket_landing_pads[entity.unit_number] then
      -- already exists
      --Log.debug("Landingpad: " .. entity.unit_number .. " already exists")
      return
     end

    --Log.debug("Landingpad: " .. entity.unit_number .. " adding new")
    ---@cast zone -?
    local force_name = entity.force.name

    ---@type RocketLandingPadInfo
    local struct = {
      type = Landingpad.name_rocket_landing_pad,
      valid = true,
      force_name = force_name,
      unit_number = entity.unit_number,
      container = entity,
      name = Landingpad.get_default_name(zone),
      zone = zone,
      position = entity.position,
      grace_period_until = game.tick + Landingpad.grace_period,
    }
    storage.rocket_landing_pads[entity.unit_number] = struct

    Landingpad.name(struct) -- assigns to zone_assets

    -- set settings
    local tags = util.get_tags_from_event(event, Landingpad.serialize)
    if tags then
      Landingpad.deserialize(entity, tags)
    end

    if event.player_index and game.get_player(event.player_index) and game.get_player(event.player_index).connected then
      game.get_player(event.player_index).opened = entity
      --LandingpadGUI.gui_open(game.get_player(event.player_index), struct)
    end

    -- First time hint
    if storage.forces[force_name] and (storage.forces[force_name].any_basic_rocket_launched_targeting_a_landing_pad or false) == false then
      game.forces[force_name].print({"space-exploration.cargo-landing-pad-first-hint"})
    end
  end
end
Event.addListener(defines.events.on_entity_cloned, Landingpad.on_entity_created)
Event.addOnEntityCreatedListeners(Landingpad.on_entity_created)

---@param struct RocketLandingPadInfo
function Landingpad.remove_struct_from_tables(struct)

  -- force
  local force_data = storage.forces[struct.force_name]
  force_data.rocket_landing_pad_names = force_data.rocket_landing_pad_names or {}
  local force_type_table = force_data.rocket_landing_pad_names

  if not force_type_table[struct.name] then return end
  force_type_table[struct.name][struct.unit_number] = nil
  if not next(force_type_table[struct.name]) then
    force_type_table[struct.name] = nil
  end

  -- zone
  local zone_assets = Zone.get_force_assets(struct.force_name, struct.zone.index)
  zone_assets.rocket_landing_pad_names = zone_assets.rocket_landing_pad_names or {}
  local zone_type_table = zone_assets.rocket_landing_pad_names

  if not zone_type_table[struct.name] then return end
  zone_type_table[struct.name][struct.unit_number] = nil
  if not next(zone_type_table[struct.name]) then
    zone_type_table[struct.name] = nil
  end

end

---@param struct RocketLandingPadInfo
---@param key string
function Landingpad.destroy_sub(struct, key)
  if struct[key] and struct[key].valid then
    struct[key].destroy()
    struct[key] = nil
  end
end

---@param struct RocketLandingPadInfo
---@param event? EntityRemovalEvent the event that triggered the destruction if it was caused by an event
function Landingpad.destroy(struct, event)
  if not struct then
    --Log.debug("Landingpad.destroy: no struct")
    return
  end
  struct.valid = false

  Landingpad.remove_struct_from_tables(struct)

  if not event then -- If event is supplied then it will already be destroyed
    Landingpad.destroy_sub(struct, "container")
  end

  if not event or event.name ~= defines.events.on_entity_died then
    -- For died it will be cleaned in post_died event
    storage.rocket_landing_pads[struct.unit_number] = nil
  end

  -- if a player has this gui open then close it
  local gui_name = LandingpadGUI.name_rocket_landing_pad_gui_root
  for _, player in pairs(game.connected_players) do
    local root = player.gui.relative[gui_name]
    if root and root.tags and root.tags.unit_number == struct.unit_number then
      player.gui.relative[gui_name].destroy()
    end
  end
end

---@param struct RocketLandingPadInfo
---@param new_name? string
function Landingpad.name(struct, new_name)
    struct.name = (new_name or struct.name)

    -- force
    local force_data = storage.forces[struct.force_name]
    force_data.rocket_landing_pad_names = force_data.rocket_landing_pad_names or {}
    local force_type_table = force_data.rocket_landing_pad_names

    force_type_table[struct.name] = force_type_table[struct.name] or {}
    force_type_table[struct.name][struct.unit_number] = struct

    local zone_assets = Zone.get_force_assets(struct.force_name, struct.zone.index)
    zone_assets.rocket_landing_pad_names = zone_assets.rocket_landing_pad_names or {}
    local zone_type_table = zone_assets.rocket_landing_pad_names

    zone_type_table[struct.name] = zone_type_table[struct.name] or {}
    zone_type_table[struct.name][struct.unit_number] = struct
end

---@param struct RocketLandingPadInfo
---@param new_name string
---@param retarget boolean
function Landingpad.rename(struct, new_name, retarget)
    local original_name = struct.name
    Landingpad.remove_struct_from_tables(struct)
    Landingpad.name(struct, new_name)
    if retarget then
      Landingpad.retarget_launchpads(struct, original_name)
    end
    struct.grace_period_until = game.tick + Landingpad.grace_period
end

---@param struct RocketLandingPadInfo
---@param original_name string
function Landingpad.retarget_launchpads(struct, original_name)
  Log.debug("Launchpad.renamed from " .. original_name .. " to " .. struct.name .. ", checking if retarget is possible.")
  local force_data = storage.forces[struct.force_name]
  local remaining_landingpads_with_original_name = force_data.rocket_landing_pad_names[original_name] or {}
  if not next(remaining_landingpads_with_original_name) then
    local launch_pads = storage.rocket_launch_pads or {}
    for _, launch_pad in pairs(launch_pads) do
      if (
        launch_pad.force_name == struct.force_name
        and launch_pad.destination
        and launch_pad.destination.landing_pad_name == original_name
      ) then
        Launchpad.set_destination(launch_pad, struct.name)
      end
    end
  end
end

---@param rocket_landing_pad_names table<string, IndexMap<RocketLandingPadInfo>>
---@param current string
---@param filter string
---@return string[] list
---@return uint? selected_index
---@return string[] values
local function label_and_sort_landing_pad_names(rocket_landing_pad_names, current, filter)
  local list = {} -- names with optional [count]
  local values = {} -- raw names
  local selected_index
  local list_value_pairs = {} -- Keep them together for sorting

  if rocket_landing_pad_names then
    for name, sites in pairs(rocket_landing_pad_names) do
      if (not filter) or string.find(string.lower(name), string.lower(filter), 1, true) then
        local count = table_size(sites)
        local display_name = name
        if count > 1 then
          display_name = name .. " ["..count.."]"
        end
        table.insert(list_value_pairs, {display_name, name})
      end
    end

    table.sort(list_value_pairs, function(a,b) return a[1] < b[1] end)

    for i, list_value_pair in pairs(list_value_pairs) do
      table.insert(list, list_value_pair[1])
      table.insert(values, list_value_pair[2])
      if list_value_pair[2] == current then
        selected_index = i
      end
    end
  end

  return list, selected_index, values
end

---@param force_name string
---@param zone AnyZoneType
---@param current string
---@param filter? string
---@return string[] list
---@return uint selected_index
---@return string[] values
function Landingpad.dropdown_list_zone_landing_pad_names(force_name, zone, current, filter, fallback_option)
  local list = {}
  local values = {}
  local selected_index

  if zone and zone.type ~= "spaceship" then
    ---@cast zone -SpaceshipType
    local zone_assets = Zone.get_force_assets(force_name, zone.index)
    local rocket_landing_pad_names = zone_assets["rocket_landing_pad_names"]
    if fallback_option and not rocket_landing_pad_names[fallback_option] then
      rocket_landing_pad_names[fallback_option] = {}
    end
    list, selected_index, values = label_and_sort_landing_pad_names(rocket_landing_pad_names, current, filter)
  end
  if not fallback_option then
    table.insert(list, 1, {"space-exploration.none_general_vicinity"})
    table.insert(values, 1, "") -- not sure if nil would work
    if selected_index then selected_index = selected_index + 1 end
  end
  return list, (selected_index or 1), values
end

---@param force_name string
---@param current string
---@param filter? string
---@return string[] list
---@return uint selected_index
---@return string[] values
function Landingpad.dropdown_list_force_landing_pad_names(force_name, current, filter)
  local force_data = storage.forces[force_name]
  local rocket_landing_pad_names = force_data.rocket_landing_pad_names
  local list, selected_index, values = label_and_sort_landing_pad_names(rocket_landing_pad_names, current, filter)

  table.insert(list, 1, {"space-exploration.none_cannot_launch"})
  table.insert(values, 1, "") -- not sure if nil would work
  if selected_index then selected_index = selected_index + 1 end
  return list, (selected_index or 1), values
end

---Handles a landing pad getting removed in any way.
---@param event EntityRemovalEvent Event data
function Landingpad.on_entity_removed(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == Landingpad.name_rocket_landing_pad then
    Landingpad.destroy(Landingpad.from_entity(entity), event)
  end
end
Event.addOnEntityRemovedListeners(Landingpad.on_entity_removed)

---@param event EventData.on_post_entity_died
local function on_post_entity_died(event)
  local ghost = event.ghost
  local unit_number = event.unit_number
  if not (ghost and unit_number) then return end
  if event.prototype.name ~= Landingpad.name_rocket_landing_pad then return end
  ghost.tags = Landingpad.serialize_from_struct(storage.rocket_landing_pads[unit_number])
  storage.rocket_landing_pads[unit_number] = nil
end
Event.addListener(defines.events.on_post_entity_died, on_post_entity_died)

-- NOTE: Landingpad.on_cargo_pod_delivered_cargo is at the end of the ascent

---Unblock the landing pad when a basic rocket silo cargo pod arrives
---@param event EventData.on_cargo_pod_delivered_cargo    Event data
function Landingpad.on_cargo_pod_delivered_cargo (event)
  --NOTE: can't use on_cargo_pod_finished_descending becuase it is 75 ticks before the cargo is inserted into the landing pad.
  --Log.debug("Landingpad.on_cargo_pod_delivered_cargo : pod landed.")
  if event.cargo_pod and event.cargo_pod.valid then
    local cargo_pod = event.cargo_pod
    -- for some reason this event doesn't specify the cargo pad when landing at a "station"
    if cargo_pod.name == "cargo-pod" then
      --Log.debug("Landingpad.on_cargo_pod_delivered_cargo : pod is correct name.")
      -- Only mark as available if this pod is from a basic rocket silo.
      local landing_pad_entity = cargo_pod.surface.find_entity(Landingpad.name_rocket_landing_pad, cargo_pod.position)
      if landing_pad_entity then
        --Log.debug("Landingpad.on_cargo_pod_delivered_cargo : Entity found.")
        local landing_pad = Landingpad.from_entity(landing_pad_entity)
        if landing_pad then
          --Log.debug("Landingpad.on_cargo_pod_delivered_cargo : Landing pad is unblocked.")
          Landingpad.remove_inbound(landing_pad, "cargo-pod")
          -- move_inventory_items won't work becuase landingpads don't accept insertion
        end
      else
        Log.debug("Landingpad.on_cargo_pod_delivered_cargo  : No entity found at " .. serpent.block(cargo_pod.position))
      end
    end
  end
end
Event.addListener(defines.events.on_cargo_pod_delivered_cargo , Landingpad.on_cargo_pod_delivered_cargo   )

function Landingpad.count_inbound_reserve(landing_pad)
  if not landing_pad.inbound then return 0 end
  local total = 0
  for inbound_type, count in pairs(landing_pad.inbound) do
    if Landingpad.inbound_reserve[inbound_type] then
      total = total + count * Landingpad.inbound_reserve[inbound_type]
    else
      Log.debug("Landingpad.count_inbound_reserve error: Invalid type: " .. inbound_type)
    end
  end
  return total
end

function Landingpad.add_inbound(landing_pad, inbound_type)
  if Landingpad.inbound_reserve[inbound_type] then
    landing_pad.inbound = landing_pad.inbound or {}
    landing_pad.inbound[inbound_type] = (landing_pad.inbound[inbound_type] or 0) + 1
  else
    Log.debug("Landingpad.add_inbound error: Invalid type: " .. inbound_type)
  end
end

function Landingpad.remove_inbound(landing_pad, inbound_type)
  if not landing_pad.inbound then return end
  --Log.debug("Landingpad.remove_inbound " .. inbound_type)
  if landing_pad.inbound and landing_pad.inbound[inbound_type] then
    landing_pad.inbound[inbound_type] = landing_pad.inbound[inbound_type] - 1
    if landing_pad.inbound[inbound_type] <= 0 then
      landing_pad.inbound[inbound_type] = nil
    end
    if table_size(landing_pad.inbound) == 0 then
      landing_pad.inbound = nil
    end
  end
  --Log.debug(serpent.block(landing_pad.inbound))
end

function Landingpad.has_space_for_inbound(landing_pad, inbound_type)
  local space_needed = Landingpad.inbound_reserve[inbound_type]
  if not space_needed then
    Log.debug("Landingpad.has_space_for_inbound error: Invalid type: " .. inbound_type)
    return
  end
  local inventory = landing_pad.container.get_inventory(Landingpad.inventory_id)
  local inbound = Landingpad.count_inbound_reserve(landing_pad)
  --Log.debug("Landingpad.has_space_for_inbound inbound: " .. inbound)
  local space = inventory.count_empty_stacks(false, false)
  --Log.debug("Landingpad.has_space_for_inbound space: " .. space)
  return space >= (space_needed + inbound)
end

---@param launching_to_destination CargoRocketLockedDestinationInfo
---@return MapPosition
function Landingpad.get_target_pos(launching_to_destination)
  if script.active_mods["se-legacy-cargo-landing-pad"] and launching_to_destination.landing_pad and launching_to_destination.landing_pad.container.valid then
    local proxy = launching_to_destination.landing_pad.container.surface.find_entities_filtered{
      name = "cargo-landing-pad-proxy",
      position = launching_to_destination.landing_pad.container.position,
      limit = 1,
    }[1]
    if proxy then
      return util.vectors_add(proxy.position, {x = 0, y = -1.5}) -- land capsule in the circle of the texture
    end
  end

  return util.vectors_add(launching_to_destination.position, Landingpad.hatch_offset)
end

---@param landing_pad RocketLandingPadInfo?
---@return Tags?
function Landingpad.serialize_from_struct(landing_pad)
  if landing_pad then
    local tags = {}
    tags.name = landing_pad.name
    return tags
  end
end

---@param entity LuaEntity
---@return Tags?
function Landingpad.serialize(entity)
  return Landingpad.serialize_from_struct(Landingpad.from_entity(entity))
end

---@param entity LuaEntity
---@param tags Tags
function Landingpad.deserialize(entity, tags)
  local landing_pad = Landingpad.from_entity(entity)
  if landing_pad then
    Landingpad.rename(landing_pad, tags.name, false)
  end
end

---Handles the player creating a blueprint by setting tags to store the state of landing pads.
---@param event EventData.on_player_setup_blueprint Event data
function Landingpad.on_player_setup_blueprint(event)
  util.setup_blueprint(event, Landingpad.name_rocket_landing_pad, Landingpad.serialize)
end
Event.addListener(defines.events.on_player_setup_blueprint, Landingpad.on_player_setup_blueprint)

---Handles the player copy/pasting settings between landing pads.
---@param event EventData.on_entity_settings_pasted Event data
function Landingpad.on_entity_settings_pasted(event)
  util.settings_pasted(event, Landingpad.name_rocket_landing_pad, Landingpad.serialize, Landingpad.deserialize)
end
Event.addListener(defines.events.on_entity_settings_pasted, Landingpad.on_entity_settings_pasted)

function Landingpad.on_init()
  storage.rocket_landing_pads = {}
end
Event.addListener("on_init", Landingpad.on_init, true)

return Landingpad
