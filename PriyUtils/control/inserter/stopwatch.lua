local floor = math.floor
local abs = math.abs

local function new(inserter)
    return {
        inserter = inserter,
        pickup_position = inserter.pickup_position,
        drop_position = inserter.drop_position,
        tick = game.tick,
        items = 0,
        state = 0, -- 0=idle, 1=grabbed, 2=dropped
    }
end

local function tick(entry, tick)
    local inserter = entry.inserter
    local held = inserter.held_stack.valid_for_read
    local changed = false
    
    if entry.state == 0 then
        if held then
            entry.state = 1
            entry.tick = tick
            changed = true
        end
    elseif entry.state == 1 then
        if not held then
            entry.state = 2
            entry.items = entry.items + 1
            entry.tick = tick
            changed = true
        end
    elseif entry.state == 2 then
        if held then
            entry.state = 1
            entry.tick = tick
            changed = true
        end
    end
    
    return false, changed
end

local function get_throughput(entry)
    local items = entry.items
    local time = game.tick - entry.tick
    if time <= 0 then time = 1 end
    return {
        throughput = items / time * 60,
        items = items,
        ticks = time,
        stable = true,
    }
end

return {
    new = new,
    tick = tick,
    get_throughput = get_throughput,
}