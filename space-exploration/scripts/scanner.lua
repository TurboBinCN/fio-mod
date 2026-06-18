local Scanner = {}

-- Chunk limit is 32767 but charting a chunk generates the next 2 chunks
Scanner.range_limit = 32764 * 32

---Create a state for a circle of given radius.
---@param radius integer Circle radius
---@return ScannerCircleData
function Scanner.init_circle(radius)
  return {
    radius = radius,
    octant = Scanner.calc_circle_octant(radius),
    octant_n = 0,
    index = 0
  }
end

---Calculates circle octant.
---@param radius integer Circle radius
---@return {[1]:int, [2]:int}[] octant Chunk positions
function Scanner.calc_circle_octant(radius)
  if radius < 1 then return {{0,0}} end
  -- Calculate the coordinates of the points located on one-eighth of the circle.
  local x = 0
  local y = radius
  local d = 3 - 2 * y
  -- The second arc is needed to fill in the gaps between adjacent circles.
  -- (this trick can be used to draw a circle with a thickness greater than 1 pixel)
  local y0 = radius - 1
  local d0 = 3 - 2 * y0
  local octant = {}
  local insert = table.insert
  while x < y do
    insert(octant, {x, y})
    if (y - y0) == 2 then
      -- Fill in the gap.
      insert(octant, {x, y - 1})
    end
    if d < 0 then
      d = d + 4 * x + 6
    else
      d = d + 4 * (x - y) + 10
      y = y - 1
    end
    if d0 < 0 then
      d0 = d0 + 4 * x + 6
    else
      d0 = d0 + 4 * (x - y0) + 10
      y0 = y0 - 1
    end
    x = x + 1
  end
  if x == y then insert(octant, {x, y}) end
  return octant
end

---Gets the next chunk to be scanned using a circular pattern.
---@param state ScannerCircleData Circle state
---@return ChunkPosition.0
function Scanner.circle_next(state)
  local band = bit32.band
  local octant_n = state.octant_n
  local index = state.index
  -- Determine the next state.
  if band(octant_n, 1) == 0 then
    -- index is increasing
    if index == #state.octant then
      octant_n = octant_n + 1
      state.octant_n = octant_n
      local c = state.octant[index]
      if c[1] == c[2] then
        index = index - 1
        if index <= 0 then index = 1 end
      end
    else
      index = index + 1
    end
  else
    -- index is decreasing
    if index == 1 then
      if octant_n < 7 then
        octant_n = octant_n + 1
        state.octant_n = octant_n
      else
        -- New round.
        octant_n = 0
        local r = state.radius + 1 --[[@as integer]]
        state.radius = r
        state.octant = Scanner.calc_circle_octant(r)
        state.octant_n = 0
      end
    else
      index = index - 1
    end
  end
  state.index = index

  -- Get the coordinates.
  local cursor = state.octant[index]
  local x = cursor[1]
  local y = cursor[2]
  -- Transpose coordinates to the current octant.
  if band(octant_n, 1) == 0 then
    -- For odd octants, swap x and y.
    local t = x
    x = y
    y = t
  end
  if band(octant_n, 2) == 0 then
    -- For odd quarters, swap x and y, change the sign y.
    local t = x
    x = y
    y = -t
  end
  if octant_n > 3 then
    -- For the left half, change both signs and move left by 1.
    x = -x - 1
    y = -y
  end
  if (octant_n < 2) or (octant_n > 5) then
    -- For the upper half, move up by 1.
    y = y - 1
  end
  return {x = x, y = y}
end

---Gets the next chunk to be scanned using a spiral pattern.
---@param input ChunkPosition.0 Current cursor position
---@return ChunkPosition.0 output
function Scanner.spiral_next(input)
  local x = input.x
  local y = input.y
  local output = {x = x, y = y}

  if x > y and x >= -y then
    output.y = y + 1
  elseif -y >= -x and -y > x then
    output.x = x + 1
  elseif -x > y and -x > -y then
    output.y = y - 1
  elseif y >= -x and y > x then
    output.x = x - 1
  else
    output.x = x - 1
  end

  return output
end

---Gets the next chunk to be scanned using the zig-zag pattern.
---@param input ChunkPosition.0 Chunk position
---@param y_limit integer Upper limit of y value to be scanned
---@return ChunkPosition.0 output
function Scanner.zigzag_next(input, y_limit)
  local x = input.x
  local y = input.y
  local output = table.deepcopy(input)

  if y > -y_limit then
    output.y = y - 1
  elseif x >= 0 then
    output.x = -x - 1
    output.y = y_limit
  else
    output.x = -x
    output.y = y_limit
  end

  return output
end

---Charts a given position on a given surface for a given force.
---@param force LuaForce Force to chart surface for
---@param surface LuaSurface Surface to be charted
---@param position ChunkPosition.0 Chunk position to be charted
function Scanner.chart_position(force, surface, position)
  force.chart(surface, {
    {
      x = position.x * 32,
      y = position.y * 32
    },
    {
      x = (position.x + 0.5) * 32, -- +1 actually scans 4 chunks
      y = (position.y + 0.5) * 32 -- +1 actually scans 4 chunks
    }
  })
end

---Returns the maximum range that can be scanned for a given zone.
---@param zone AnyZoneType Zone being evaluated
---@return integer max_range
function Scanner.get_max_range_for_zone(zone)
  local max_range = settings.global["se-scan-max-range"].value --[[@as integer]]
  if zone.radius then
    -- +32 to make sure we get the last chunk after rounding down
    max_range = math.min(max_range, zone.radius + 32)
  end
  max_range = math.min(max_range, Scanner.range_limit)
  return max_range
end

---Returns true if scanning cursor is outside given `max_range`.
---@param cursor ChunkPosition.0 Chunk position of scanning cursor
---@param max_range integer Maximum tile range for scan
---@return boolean
function Scanner.is_cursor_outside_range(cursor, max_range)
  return (math.abs(cursor.x) - 1.5) * 32 > max_range
    or (math.abs(cursor.y) - 1.5) * 32 > max_range
end

---Processes scanning step for a given force.
---@param forcedata ForceData Force data
---@param force LuaForce Force being processed
---@param tick integer Event tick
function Scanner.process_force_scanning(forcedata, force, tick)
  -- Exit if force is not currently scanning any zones
  if not (forcedata.is_scanning and forcedata.scanning_zone) then return end

  local y_limit
  local circle_state = forcedata.scanning_circle_state

  if forcedata.scanning_zone.type == "asteroid-belt" or forcedata.scanning_zone.type == "orbit" then
    y_limit = 8 -- changes spiral pattern to different method
    if not forcedata.scanning_cursor then
      forcedata.scanning_cursor = {x=0, y=8}
    end
  else
    if not forcedata.scanning_cursor then
      forcedata.scanning_cursor = {x=0, y=0}
      circle_state = Scanner.init_circle(0)
    end
  end

  local surface = Zone.get_surface(forcedata.scanning_zone)
  if not surface then return Scanner.stop_scanning(force.name) end

  local max_range = Scanner.get_max_range_for_zone(forcedata.scanning_zone)
  local search_budget = settings.global["se-scan-search-budget"].value -- 1000
  local searched = 0
  local chart_budget = settings.global["se-scan-chart-budget"].value -- 10
  local charted = 0
  local cursor = forcedata.scanning_cursor --[[@as ChunkPosition.0]]

  while searched < search_budget and charted < chart_budget do
  -- Abort scan if outside scanning range
  if Scanner.is_cursor_outside_range(cursor, max_range) then
    if forcedata.scanning_zone.radius and
      forcedata.scanning_zone.radius < settings.global["se-scan-max-range"].value then
      force.print({"space-exploration.scan-complete-body",
        Zone.get_print_name(forcedata.scanning_zone)})
    else
      force.print({"space-exploration.scan-complete-range",
        Zone.get_print_name(forcedata.scanning_zone), math.floor(max_range)})
    end

    return Scanner.stop_scanning(force.name)
  end

  -- Count chunk as searched
  searched = searched + 1

  -- Chart chunk if it is not charted
  if (not forcedata.scanning_zone.radius) or
    (Util.vector_length(cursor) - 1.5) * 32 < forcedata.scanning_zone.radius then
    if not force.is_chunk_charted(surface, cursor) then
      Scanner.chart_position(force, surface, cursor)
      charted = charted + 1
      end
    end

    if y_limit then
      cursor = Scanner.zigzag_next(cursor, y_limit)
    elseif circle_state then
      cursor = Scanner.circle_next(circle_state)
    else
      cursor = Scanner.spiral_next(cursor)
    end
  end

  forcedata.scanning_cursor = cursor
  forcedata.scanning_circle_state = circle_state

  local alert_interval = settings.global["se-scan-alert-interval"].value --[[@as integer]]

  if alert_interval > 0 then
    if tick % (60 * alert_interval) == 0 then
      if circle_state then
        force.print({"space-exploration.scan-progress-update-circle",
          Zone.get_print_name(forcedata.scanning_zone), cursor.x, cursor.y,
          circle_state.radius * 32, circle_state.octant_n})
      else
        force.print({"space-exploration.scan-progress-update",
          Zone.get_print_name(forcedata.scanning_zone), cursor.x, cursor.y})
      end
    end
  end
end

---Calls `process_force_scanning` for each ForceData.
---@param tick integer Event tick
function Scanner.process_forces_scanning(tick)
  for force_name, forcedata in pairs(storage.forces) do
    local force = game.forces[force_name]
    if not force then
      storage.forces[force_name] = nil
    else
      Scanner.process_force_scanning(forcedata, force, tick)
    end
  end
end

---Attempts to create tags in the tag buffer.
function Scanner.process_chart_tag_buffer()
  for key, tag in pairs(storage.chart_tag_buffer) do
    local surface = tag.surface
    local force_name = tag.force_name
    local force = game.forces[force_name]

    if force then
      local chart_tag = force.add_chart_tag(surface, {
        icon = {type = tag.icon_type, name = tag.icon_name},
        position = tag.position,
        text = tag.text
      })
      if chart_tag then
        storage.chart_tag_buffer[key] = nil
      end
    else
      storage.chart_tag_buffer[key] = nil
    end
  end
end

---Triggers periodic surfae scanning and charting function.
---@param event NthTickEventData Event data
function Scanner.on_nth_tick_60(event)
  Scanner.process_forces_scanning(event.tick)
  Scanner.process_chart_tag_buffer()
end
Event.addListener("on_nth_tick_60", Scanner.on_nth_tick_60)

---Begins scanning a given zone, charting it for the given force.
---@param force_name string Force name
---@param zone AnyZoneType Zone to be scanned
---@param by string Who or what started the scan
function Scanner.start_scanning(force_name, zone, by)
  if not zone.surface_index then Zone.create_surface(zone) end

  local force = game.forces[force_name]
  local forcedata = storage.forces[force_name] --[[@as ForceData]]

  -- Cancel any pending charting requests for this force for all surfaces
  force.cancel_charting()

  -- Save scanning data to forcedata
  forcedata.is_scanning = true
  forcedata.scanning_zone = zone
  forcedata.scanning_cursor = nil
  forcedata.scanning_started_by = by

  -- Update GUis of connected players
  for _, player in pairs(force.connected_players) do
    Zonelist.update(player)
    MapView.gui_update(player)
  end
end

---Stops any active scan for a given force.
---@param force_name string Force name
---@param cancel_charting? boolean Whether or not to cancel charting requests for this force
function Scanner.stop_scanning(force_name, cancel_charting)
  local force = game.forces[force_name]
  local forcedata = storage.forces[force_name]

  if cancel_charting then
    force.cancel_charting()
  end

  -- Update forcedata scanning information
  forcedata.is_scanning = false
  forcedata.scanning_zone = nil
  forcedata.scanning_cursor = nil
  forcedata.scanning_started_by = nil

  -- Update GUIs
  for _, player in pairs(game.connected_players) do
    Zonelist.update(player)
    MapView.gui_update(player)
  end
end

function Scanner.on_init()
  storage.chart_tag_buffer = {}
  storage.chart_tag_next_id = 0
end
Event.addListener("on_init", Scanner.on_init, true)

return Scanner
