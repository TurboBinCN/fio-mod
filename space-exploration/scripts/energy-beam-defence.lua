local EnergyBeamDefence = {}

--[[
The defence has a base power use.
It starts with full charge.
When under attack energy usage is increased based on the attack strength.
If the buffer has not recoverd sufficently between ticks then the structure is not providing defence.


Make a list of defences per zone
When an attack comes in, disrtibute the load of the attack on all enemy defences weighted by the defences current energy vs energy max.
Update once per second?

zone.energy_beams = {}
zone.energy_beam_defences = {}
beam.stress_factores = {beams}
Apply a share of the load (energy)
]]

EnergyBeamDefence.name_energy_beam_defence = mod_prefix.."energy-beam-defence"
EnergyBeamDefence.name_energy_beam_defence_glow = mod_prefix.."energy-beam-defence-glow"
EnergyBeamDefence.beam_defence_passive_draw = 10000000 --10MW
EnergyBeamDefence.beam_defence_buffer = 1000000000 --1GJ
EnergyBeamDefence.beam_defence_efficiency = 10 -- takes 1/10th the power of the emitter
EnergyBeamDefence.beam_defence_peak_flare_power = 2000000000 -- 2GW
EnergyBeamDefence.beam_defence_required = 0.5 --

---@param zone AnyZoneType
---@param force_name string
---@param pressure_force_name? string unused
---@return boolean?
function EnergyBeamDefence.zone_is_defended_helper(zone, force_name, pressure_force_name)
  local zone_assets = Zone.get_force_assets(force_name, zone.index)
  if zone_assets and zone_assets.energy_beam_defence then
    for unit_number, defence in pairs(zone_assets.energy_beam_defence) do
      if defence.operational then
        return true
      end
    end
  end
end

---@param zone AnyZoneType
---@param pressure_force_name? string
---@return boolean
function EnergyBeamDefence.zone_is_defended(zone, pressure_force_name)
  -- force == nil == neutral
  for force_name, forcedata in pairs(storage.forces) do
    local force = game.forces[force_name]
    if pressure_force_name == nil or ((force_name ~= pressure_force_name) and (not (force.get_friend(pressure_force_name) or force.get_cease_fire(pressure_force_name)))) then
      if EnergyBeamDefence.zone_is_defended_helper(zone, force_name, pressure_force_name) then return true end
      local alternate_defence_zone = Zone.get_alternate_defence_zone(zone)
      if alternate_defence_zone and Zone.get_surface(alternate_defence_zone) then
        if EnergyBeamDefence.zone_is_defended_helper(alternate_defence_zone, force_name, pressure_force_name) then return true end
      end
    end
  end
  return false
end

---@param zone AnyZoneType
---@param pressure SolarFlareTickTask|EnergyBeamEmitterInfo
function EnergyBeamDefence.zone_add_pressure(zone, pressure)

  storage.energy_beam_target_zones[zone.index] = zone
  zone.energy_beam_pressures = zone.energy_beam_pressures or {
    solar = {},
    emitters = {},
  }

  if pressure.type == "solar-flare" then
    ---@cast pressure SolarFlareTickTask
    if not zone.energy_beam_pressures.solar[pressure.id] then
      --TODO: print message to defenecs
      zone.energy_beam_pressures.solar[pressure.id] = pressure
      EnergyBeamDefence.defences_apply_pressure(zone)
    end
  else --if pressure.type == "energy-beam-emitter-tree" then -- restore later, legacy test is missing this property
    ---@cast pressure EnergyBeamEmitterInfo
    if not zone.energy_beam_pressures.emitters[pressure.unit_number] then
      --TODO: print message to defenecs
      zone.energy_beam_pressures.emitters[pressure.unit_number] = pressure
      EnergyBeamDefence.defences_apply_pressure(zone)
    end
  end
end

---@param zone AnyZoneType
---@param force_name string
function EnergyBeamDefence.setup_defences(zone, force_name)
  local zone_assets = Zone.get_force_assets(force_name, zone.index)
  if zone_assets and zone_assets.energy_beam_defence then
    for unit_number, defence in pairs(zone_assets.energy_beam_defence) do
      if defence.entity and defence.entity.valid then
        defence.pressure = 0
        defence.operational = true
        defence.entity.power_usage = EnergyBeamDefence.beam_defence_passive_draw/60
        if defence.glow_sprite and defence.glow_sprite.valid then
          defence.glow_sprite.destroy()
          defence.glow_sprite = nil
        end
      else
        zone_assets.energy_beam_defence[unit_number] = nil
      end
    end
  end
end

---@param zone AnyZoneType
---@param defences EnergyBeamDefenceInfo[]
---@param force_name string
---@param pressure_force_name string
---@return number
function EnergyBeamDefence.put_defences_in_list(zone, defences, force_name, pressure_force_name)
  local force = game.forces[force_name]
  local defences_total_energy = 0
  if pressure_force_name == "-" or ((force_name ~= pressure_force_name) and (not (force.get_friend(pressure_force_name) or force.get_cease_fire(pressure_force_name)))) then
    local zone_assets = Zone.get_force_assets(force_name, zone.index)
    if zone_assets and zone_assets.energy_beam_defence then
      for unit_number, defence in pairs(zone_assets.energy_beam_defence) do
        table.insert(defences, defence)
        defences_total_energy = defences_total_energy + defence.entity.energy
      end
    end
  end
  return defences_total_energy
end

---@param zone AnyZoneType
---@param force_name string
function EnergyBeamDefence.update_defence_power_usage(zone, force_name)
  local zone_assets = Zone.get_force_assets(force_name, zone.index)
  if zone_assets and zone_assets.energy_beam_defence then
    for unit_number, defence in pairs(zone_assets.energy_beam_defence) do
      defence.entity.power_usage = (EnergyBeamDefence.beam_defence_passive_draw + defence.pressure)/60
      defence.operational = defence.entity.energy / EnergyBeamDefence.beam_defence_buffer > EnergyBeamDefence.beam_defence_required
      if defence.pressure > 0.001 then
        defence.glow_sprite = rendering.draw_sprite{
          sprite = EnergyBeamDefence.name_energy_beam_defence_glow,
          target = defence.entity,
          surface = defence.entity.surface
        }
      end
    end
  end
end

---@param zone AnyZoneType
function EnergyBeamDefence.defences_apply_pressure(zone)
  -- validate
  if not zone.energy_beam_pressures then
    storage.energy_beam_target_zones[zone.index] = nil
    return
  end

  -- gather and validate
  local pressures_count = 0
  local force_emitter_pressures = {}

  for id, tick_task in pairs(zone.energy_beam_pressures.solar) do
    if tick_task.valid then
      pressures_count = pressures_count + 1
      if not force_emitter_pressures["-"] then
        force_emitter_pressures["-"] = 0
      end
      force_emitter_pressures["-"] = force_emitter_pressures["-"] + (0.1 + 0.9 * (tick_task.age_peak or 0.0001)) * EnergyBeamDefence.beam_defence_peak_flare_power * tick_task.power_multiplier
    else
      zone.energy_beam_pressures.solar[id] = nil
    end
  end

  for unit_number, emitter_tree in pairs(zone.energy_beam_pressures.emitters) do
    if emitter_tree.destination and emitter_tree.destination.zone and emitter_tree.destination.zone.index == zone.index and emitter_tree.emitter.valid and (emitter_tree.mode == "glaive" or emitter_tree.mode == "auto-glaive") then
      pressures_count = pressures_count + 1
      if not force_emitter_pressures[emitter_tree.force_name] then
        force_emitter_pressures[emitter_tree.force_name] = 0
      end
      force_emitter_pressures[emitter_tree.force_name] = force_emitter_pressures[emitter_tree.force_name]
        + emitter_tree.last_temperature * emitter_tree.last_efficiency * EnergyBeam.specific_heat / EnergyBeamDefence.beam_defence_efficiency
    else
      zone.energy_beam_pressures.emitters[unit_number] = nil
    end
  end

  for force_name, forcedata in pairs(storage.forces) do
    EnergyBeamDefence.setup_defences(zone, force_name)
    local alternate_defence_zone = Zone.get_alternate_defence_zone(zone)
    if alternate_defence_zone and Zone.get_surface(alternate_defence_zone) then
      EnergyBeamDefence.setup_defences(alternate_defence_zone, force_name)
    end
  end

  if pressures_count == 0 then
    zone.energy_beam_pressures = nil
    return
  end

  -- equalise
  for pressure_force_name, pressure in pairs(force_emitter_pressures) do
    ---@type EnergyBeamDefenceInfo[]
    local defences = {}
    local defences_total_energy = 0
    for force_name, forcedata in pairs(storage.forces) do
      defences_total_energy = defences_total_energy + EnergyBeamDefence.put_defences_in_list(zone, defences, force_name, pressure_force_name)
      local alternate_defence_zone = Zone.get_alternate_defence_zone(zone)
      if alternate_defence_zone and Zone.get_surface(alternate_defence_zone) then
        defences_total_energy = defences_total_energy + EnergyBeamDefence.put_defences_in_list(alternate_defence_zone, defences, force_name, pressure_force_name)
      end
    end
    for _, defence in pairs(defences) do
      local defence_share = defences_total_energy > 0 and (defence.entity.energy / defences_total_energy) or 0.01
      defence.pressure = defence.pressure + pressure * defence_share
    end
  end

  for force_name, forcedata in pairs(storage.forces) do
    EnergyBeamDefence.update_defence_power_usage(zone, force_name)
    local alternate_defence_zone = Zone.get_alternate_defence_zone(zone)
    if alternate_defence_zone and Zone.get_surface(alternate_defence_zone) then
      EnergyBeamDefence.update_defence_power_usage(alternate_defence_zone, force_name)
    end
  end

end

---@param event EntityCreationEvent Event data
function EnergyBeamDefence.on_entity_created(event)
  local entity
  if event.entity and event.entity.valid then
    entity = event.entity
  end
  if not entity then return end
  if entity.name == EnergyBeamDefence.name_energy_beam_defence then
    local zone = Zone.from_surface(entity.surface)
    if cancel_creation_when_invalid(zone, entity, event) then return end
    ---@cast zone -?
    local force = entity.force
    local force_name = force.name
    local force_data = storage.forces[force.name]
    if force_data then
      local zone_assets = Zone.get_force_assets(force_name, zone.index)
      zone_assets.energy_beam_defence = zone_assets.energy_beam_defence or {}
      local defence = {
        type = "energy-beam-defence",
        unit_number = entity.unit_number,
        force_name = force_name,
        entity = entity,
        zone_index = zone.index,
        pressures = {
          solar = {},
          emitters = {},
        },
        operational = false
      }
      zone_assets.energy_beam_defence[defence.unit_number] = defence

      entity.power_usage = EnergyBeamDefence.beam_defence_passive_draw/60
      entity.electric_buffer_size = EnergyBeamDefence.beam_defence_buffer
    end
  end
end
Event.addOnEntityCreatedListeners(EnergyBeamDefence.on_entity_created)

function EnergyBeamDefence.on_nth_tick_60()
  for zone_index, zone in pairs(storage.energy_beam_target_zones) do
    EnergyBeamDefence.defences_apply_pressure(zone)
  end
end
Event.addListener("on_nth_tick_60", EnergyBeamDefence.on_nth_tick_60) -- 1 minute

function EnergyBeamDefence.on_init()
  storage.energy_beam_target_zones = {}
end
Event.addListener("on_init", EnergyBeamDefence.on_init, true)

return EnergyBeamDefence
