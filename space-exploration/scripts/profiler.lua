--[[

Profiler functions

LuaProfiler is desync unsafe so you cannot use it in multiplayer.

Prints summary to log file and to console every 5 seconds.


Example 1:
Profiler.start('test1')
  ...code...
Profiler.split('test1','chunk1') -- optional
  ...code...
Profiler.split('test1','chunk2') -- optional
  ...code...
Profiler.stop('test1')

Example 2:
Profiler.start('test2', table_size(items))
for _, item in pairs(items) do
  ...code...
end
Profiler.stop('test2')

Example 3:
Profiler.count('counter1')

]]--

local Profiler = {
  enabled = false,
  print_to_console = true
}

if is_debug_mode and Profiler.enabled then
  local active_profilers = {}
  local active_splits = {}
  local active_counters = {}

  -- LuaProfiler makes the game slower as more and more profilers are created,
  -- thus we create a pool of profilers to mitigate the issue
  local profilers_pool = {}
  local profilers_used = {}

  local function get_make_profiler()
    local profiler
    if table_size(profilers_pool) > 0 then
      profiler = table.remove(profilers_pool)
      profiler.reset()
    else
      profiler = game.create_profiler(true)
    end
    table.insert(profilers_used, profiler)
    return profiler
  end

  local function recycle_profilers()
    for _, profiler in pairs(profilers_used) do
      table.insert(profilers_pool, profiler)
    end
    profilers_used = {}
  end

  local function dup_profiler(profiler)
    local new_profiler = get_make_profiler()
    new_profiler.reset()
    new_profiler.stop()
    new_profiler.add(profiler)
    return new_profiler
  end


  function Profiler.start(name, unit_count)
    if not active_profilers[name] then
      active_profilers[name] = {
        profiler = get_make_profiler(),
        tick = game.tick,
        count = 0
      }
    end
    if unit_count == nil then unit_count = 1 end
    active_profilers[name].count = active_profilers[name].count + unit_count
    active_profilers[name].profiler.restart()
  end

  function Profiler.stop(name)
    if active_profilers[name] then
      if active_splits[name] then
        Profiler.stop(active_splits[name])
        active_splits[name] = nil
      end
      active_profilers[name].profiler.stop()
    end
  end

  function Profiler.split(name, part)
    if active_profilers[name] then
      if active_splits[name] then
        Profiler.stop(active_splits[name])
        active_splits[name] = nil
      end
      if part then
        local split_name = name .. "--" .. part
        Profiler.start(split_name)
        active_splits[name] = split_name
      end
    end
  end


  function Profiler.count(name, value)
    if not active_counters[name] then
      active_counters[name] = {
        counter = 0,
        tick = game.tick
      }
    end
    if value == nil then value = 1 end
    active_counters[name].counter = active_counters[name].counter + value
  end

  function Profiler.collect_print()
    local results = {}
    for name, entry in pairs(active_profilers) do
      entry.profiler.stop()
      if entry.count == 0 then
        entry.profiler.divide(game.tick - entry.tick + 1)
        results[name] = { "", "PerTick ", entry.profiler }
      else
        local per_tick_count = entry.count / (game.tick - entry.tick + 1)
        local per_unit_profiler = dup_profiler(entry.profiler)
        per_unit_profiler.divide(entry.count)
        entry.profiler.divide(game.tick - entry.tick + 1)
        results[name] = { "", "PerUnit (", per_tick_count, "/", entry.count, ") ", per_unit_profiler,
                          " / PerTick ", entry.profiler }
      end
    end
    for name, entry in pairs(active_counters) do
      local value = entry.counter / (game.tick - entry.tick + 1)
      local key = results[name] and (name .. "-count") or name
      results[key] = { "", "Count: ", value }
    end

    -- sort the results
    local keys = {}
    for k in pairs(results) do table.insert(keys, k) end
    table.sort(keys)
    -- print
    Log.debug('---')
    for _, name in pairs(keys) do
      Log.debug({ "", name, ": ", results[name]})
    end
    -- cleanup
    active_profilers = {}
    active_splits = {}
    active_counters = {}
    recycle_profilers()
  end
  Event.addListener("on_nth_tick_301", Profiler.collect_print) -- 5 seconds
else
  Profiler.start = function() end
  Profiler.stop = function() end
  Profiler.split = function() end
  Profiler.count = function() end
  Profiler.collect_print = function() end
end

return Profiler
