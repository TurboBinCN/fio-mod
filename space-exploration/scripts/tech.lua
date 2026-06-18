local Tech = {}
--[[
Record tech state, especially levels, so they can be restored by migrations
-- At the start of on_configuration_changed, tech_state is saved to old_tech_state, then removed after migrations
]]
--Tech.ignore_research_finished, set to true to disable the event during migration. Must be unset in the same function to not desync

---@param force LuaForce
function Tech.record_old_force_technologies(force)
  local forcedata = storage.forces[force.name]
  if not forcedata then return end
  if not forcedata.tech_state then return end
  forcedata.old_tech_state = forcedata.tech_state
  if is_debug_mode and false then
    Log.debug_log("Force " .. force.name .." old tech state:")
    Log.debug_log(serpent.block(forcedata.old_tech_state))
  end
end

function Tech.record_old_forces_technologies()
  for _, force in pairs(game.forces) do
    if is_player_force(force.name) then
      Tech.record_old_force_technologies(force)
    end
  end
end

---@param force LuaForce
function Tech.clear_old_force_technologies(force)
  local forcedata = storage.forces[force.name]
  if not forcedata then return end
  if not is_debug_mode then
    forcedata.old_tech_state = nil -- don't bloat savefile
  end
  Tech.record_force_technologies(force)
end

function Tech.clear_old_forces_technologies()
  for _, force in pairs(game.forces) do
    if is_player_force(force.name) then
      Tech.clear_old_force_technologies(force)
    end
  end
end

---@param force LuaForce
function Tech.record_force_technologies(force)
  local forcedata = storage.forces[force.name]
  if not forcedata then return end
  if not is_player_force(force.name) then return end
  forcedata.tech_state = {}

  for _, technology in pairs(force.technologies) do
    forcedata.tech_state[technology.name] = {
      researched = technology.researched,
      level = technology.level
    }
  end
end

---@param event EventData.on_research_finished Event data
function Tech.on_research_finished(event)
  if not Tech.ignore_research_finished then
    Tech.record_force_technologies(event.research.force)
  end
end
Event.addListener(defines.events.on_research_finished, Tech.on_research_finished)

---@param force_name string
---@param tech_name string
---@param use_old boolean
---@return integer
function Tech.read_tiered_level(force_name, tech_name, use_old)
  local force = game.forces[force_name]
  local forcedata = storage.forces[force.name]
  local technologies
  if use_old then
    technologies = forcedata.old_tech_state
  else
    technologies = force.technologies
  end
  local level = 0
  local continue = true
  while continue do
    local tech
    if level == 0 then
      tech = technologies[tech_name]
    end
    if not tech then
      tech = technologies[tech_name.."-"..level + 1]
    end
    if not tech then
      return level
    end
    level = tech.level - 1
    if tech.researched then
      level = level + 1
    end
    continue = false
    if tech.researched then
      continue = true
    end
  end
  return level
end

---@param force_name string
---@param tech_name string
---@param level uint
function Tech.write_tiered_level(force_name, tech_name, level)
  -- For now this only researches techs and does not unresearch them
  -- as it is designed to fix lost levels during tech migration
  local force = game.forces[force_name]
  local last_level
  for i = level, 0, -1 do
    local tech
    if i == 0 then
      tech = force.technologies[tech_name]
    end
    if not tech then
      tech = force.technologies[tech_name.."-"..i]
    end
    if tech then
      if last_level then
        tech.level = last_level - 1
        tech.researched = true
      else
        local max_level = tech.prototype.max_level
        if level == max_level then
          tech.level = level
          tech.researched = true
        else
          tech.level = level + 1
        end
      end
      last_level = i
    end
  end
end

---@param tech_name string
function Tech.restore_tech_levels(tech_name)
  for _, force in pairs(game.forces) do
    if is_player_force(force.name) then
      local forcedata = storage.forces[force.name]
      if forcedata.old_tech_state then
        local old_level = Tech.read_tiered_level(force.name, tech_name, true)
        if old_level and old_level > 0 then
          Tech.write_tiered_level(force.name, tech_name, old_level)
        end
      end
    end
  end
end

return Tech
