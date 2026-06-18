local Log = {}

Log.debug_prints = is_debug_mode -- does debug_log() do game.print()?
Log.print_trace = is_debug_mode -- does trace() do game.print()?
Log.debug_logs = is_debug_mode -- does debug_log() do log()?
Log.tags_populate_events = false -- do tags populate with the calling event name? REQUIRES Factorio to be launched with '--enable-unsafe-lua-debug-api' command line option.
Log.print_tags = false -- are tags printed as well with any other print?
Log.debug_big_logs = false -- the big file outputs (astro)

--Array of strings for white/black list logging based on tags
--tags auto populate with source filename, function name, and event name
--for a set of message tags to pass the filter, one tag must exist in the tag_whitelist (if not empty) and no tag may exist in the tag_blacklist
--ex. {"zone.lua", "on_tick"}
Log.tag_whitelist = {}
Log.tag_blacklist = {}

Log.event_name_map = {} --used to map uint `event.name` to a human readable string
for name, id in pairs(defines.events) do
  Log.event_name_map[id] = name
end

---logs a message to the factorio log file
---@param message? string|number|boolean|table message to log
---@param tags? string|string[] string or array of strings to be checked against white/black list
function Log.debug_log(message, tags)
  if (not Log.debug_logs) or script.level.is_simulation then return end
  if not Log.check_tags(tags) then return end
  if type(message) == "number" or type(message) == "boolean" or type(message) == "nil" then
    message = tostring(message)
  end
  message = {"", "Debug: ", message}
  log(message)
  if Log.debug_prints and game then game.print(message, {sound = defines.print_sound.never}) end
end
Log.log = Log.debug_log --aliases
Log.debug = Log.debug_log

---logs a message to just the factorio log file
---@param message? string|number|boolean|table message to log
function Log.debug_log_without_print(message)
  local debug_prints = Log.debug_prints
  Log.debug_prints = false
  Log.debug_log(message)
  Log.debug_prints = debug_prints
end

---Prints and logs a message with source path, filename, and line number where this function is called
---@param message? string|number|boolean|table message to print
---@param tags? string|string[] string or array of strings to be checked against white/black list
function Log.trace(message, tags)
  if (not Log.debug_logs) or script.level.is_simulation then return end
  if not Log.check_tags(tags) then return end
  local debuginfo = debug.getinfo(2, "Sl")
  local source = string.match(debuginfo.source, "^.*__(/.*)$") or "???" -- source filename
  if type(message) == "number" or type(message) == "boolean" or type(message) == "nil" then
    message = tostring(message)
  end
  message = {"", "Debug: ", source, ":", debuginfo.currentline, ": ", message}
  log(message) if Log.print_trace and game then game.print(message) end
end

---Prints and logs a message including entire call stack up to point where this function is called
---@param message? string|number|boolean|table message to print
---@param tags? string|string[] string or array of strings to be checked against white/black list
function Log.trace_full(message, tags)
  if (not Log.debug_logs) or script.level.is_simulation then return end
  if not Log.check_tags(tags) then return end
  if type(message) == "number" or type(message) == "boolean" or type(message) == "nil" then
    message = tostring(message)
  elseif type(message) == "table" then
    message = serpent.line(message)
  end
  local msg = debug.traceback("Debug "..message, 2)
  log(msg) if Log.print_trace and game then game.print(msg) end
end

---assert condition is true else print an error. DOES NOT HALT!!
---@param condition boolean condition that will cause failure if false
---@param message? string error message to be printed
function Log.assert(condition, message)
  if condition then return end
  if __DebugAdapter then __DebugAdapter.breakpoint("Assertion failed!") end -- cause a debugger breakpoint
  local msg = "Assertion failed!"
  log(msg) if game then game.print(msg) end
  if type(message) == "string" then
    local msg = message
    log(msg) if game then game.print(msg) end
  end
  local msg = debug.traceback(nil, 2)
  log(msg) if game then game.print(msg) end
end

---Used internally to auto generate tags and check against white/black list
---@param tags? string|string[] array of tags to be checked against white/black list
---@return boolean allowed if the tags pass the white/black list
function Log.check_tags(tags)
  --populate tags table
  tags = tags or {}
  if type(tags) == "string" then tags = {tags} end
  local debuginfo = debug.getinfo(3, "Sn") -- level 1 is this function, 2 is the Log.x() calling function, level 3 is the original calling function
  table.insert(tags, string.match(debuginfo.source, "^.*/(.*%.lua)$")) --source filename
  table.insert(tags, debuginfo.name) --function name (may not always be as expected)
  if Log.tags_populate_events then
    ---@diagnostic disable-next-line deprecated
    if not debug.getlocal then
      local msg = "WARNING: Log.tags_population_events == true but Factorio was not launched with the --enable-unsafe-lua-debug-api command line option. Disabling Log.tags_population_events"
      log(msg) if Log.print.trace and game then game.print(msg) end
      Log.tags_populate_events = false
    else
      --find top level call
      local level = 3 -- start at calling function
      local dinfo = debug.getinfo(level, "S")
      while dinfo and dinfo.source ~= "=[C]" do -- find either the top level call or the last entry via C code
        level = level + 1
        dinfo = debug.getinfo(level, "S")
      end
    ---@diagnostic disable-next-line deprecated
      local _, value = debug.getlocal(level-1, 1) -- the first parameter is always index 1 and EventData is always the first parameter
      if type(value) == "table" and value.tick and value.name then -- these are always included in EventData
        local event_name = value.nth_tick and "on_nth_tick_"..value.nth_tick or value.name
        if Log.event_name_map[event_name] then
          event_name = Log.event_name_map[event_name]
        end
        table.insert(tags, event_name) --event name
      end
    end
  end

  --check if tag is white/black listed
  local found = next(Log.tag_whitelist) == nil
  for _, tag in pairs(tags) do
    if not found and Util.table_contains(Log.tag_whitelist, tag) then
      found = true
    end
    if Util.table_contains(Log.tag_blacklist, tag) then
      return false
    end
  end
  if found and Log.print_tags then game.print("⬐ tags: "..serpent.line(tags)) end
  return found
end

---Dumps the entire Lua variable environment to a file
function Log.dump_env()
  local msg = "dumping environment..."
  log(msg)
  game.print(msg)

  helpers.write_file("space-exploration.environment.lua", serpent.dump(_ENV, {comment=false, sparse=true, indent = "\t", nocode=true, name="_ENV"}), false)

  local msg = "finished dumping environment."
  log(msg)
  game.print(msg)
end

function Log.log_global()
  helpers.write_file("space-exploration.storage.lua", serpent.dump(storage, {comment=false, sparse=true, indent = "\t", nocode=true, name="storage"}), false)
end

function Log.log_universe()
  helpers.write_file("space-exploration.universe.lua", serpent.dump(storage.universe, {comment=false, sparse=true, indent = "\t", nocode=true, name="universe"}), false)
end

function Log.log_spaceships()
  helpers.write_file("space-exploration.spaceships.lua", serpent.dump(storage.spaceships, {comment=false, sparse=true, indent = "\t", nocode=true, name="spaceships"}), false)
end

function Log.log_universe_simplified()
  local string = ""
  for s, star in pairs(storage.universe.stars) do
    string = string .. star.name .. " ("..star.stellar_position.x.." "..star.stellar_position.y..")\n"
    for p, planet in pairs(star.children) do
      if planet.orbit then
        string = string .. star.name .. " > "..planet.name ..": ".. (planet.resources and Util.values_to_string(planet.resources) or "")..
          ". Orbit: "..(planet.orbit.resources and Util.values_to_string(planet.orbit.resources) or "") .."\n"
      else
        string = string .. star.name .. " > "..planet.name ..": ".. (planet.resources and Util.values_to_string(planet.resources) or "") .."\n"
      end
      if planet.children then
        for m, moon in pairs(planet.children) do
          string = string .. star.name .. " > "..planet.name .. " > "..moon.name  ..": ".. (moon.resources and Util.values_to_string(moon.resources) or "") ..
           ". Orbit: "..(moon.orbit.resources and Util.values_to_string(moon.orbit.resources) or "") .."\n"
        end
      end
    end
  end
  for z, zone in pairs(storage.universe.space_zones) do
    string = string .. zone.name .. " ("..zone.stellar_position.x.." "..zone.stellar_position.y..") "..(zone.resources and Util.values_to_string(zone.resources) or "").."\n"
  end
  helpers.write_file("space-exploration.universe_simplified.lua", string, false)
end

function Log.log_forces()
  helpers.write_file("space-exploration.forces.lua", serpent.dump(storage.forces, {comment=false, sparse=true, indent = "\t", nocode=true, name="forces"}), false)
end

function Log.log_map_gen()
  local map_gens = {}
  for surface_name, surface in pairs(game.surfaces) do
    map_gens[surface_name] = surface.map_gen_settings
  end
  helpers.write_file("space-exploration.map_gen.lua", serpent.dump(map_gens, {comment=false, sparse=true, indent = "\t", nocode=true, name="map_gens"}), false)
end

return Log
