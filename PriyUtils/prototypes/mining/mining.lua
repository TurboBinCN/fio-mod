local function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local function append_list(destination, source)
    for _, value in pairs(source) do
        table.insert(destination, value)
    end
end

local function address_not_nil(t, ...)
    for i = 1, select("#", ...) do
        if t == nil then return nil end
        t = t[select(i, ...)]
    end
    return t
end

local function string_to_list(string, separator)
    local substrings = {}
    if string ~= nil and string ~= '' then
        for substring in string.gmatch(string, '[^'..separator..']+') do
            table.insert(substrings, substring)
        end
    end
    return substrings
end

local SETTING = {
    DrillSpeedFactor = settings.startup['priyutils-mining-drill-output-speed-factor'].value,
    DrillAreaFactor  = settings.startup['priyutils-mining-drill-mining-area-size'].value,
    PumpSpeedFactor  = settings.startup['priyutils-pumpjack-output-speed-factor'].value,
    ExtraModuleSlots = settings.startup['priyutils-extra-module-slots'].value,
    CustomExclusions = settings.startup['priyutils-parameter-change-exclusions'].value
}

local exclusions = {speed = {}, area = {}, slots = {}}

local function drill_exists(input)
    local exists = false
    for _, extractor in pairs(data.raw['mining-drill']) do
        if input == extractor.name then exists = true break end
    end
    return exists
end

for _, entry in pairs(string_to_list(SETTING.CustomExclusions, ',')) do
    local prefix_table =
        {['s'] = exclusions.speed, ['a'] = exclusions.area, ['m'] = exclusions.slots}
    if string.match(entry, ':[^:]') then
        local prefix, name = string.match(entry, '([^:]-):([^:]+)')
        for id, list in pairs(prefix_table) do
            if drill_exists(name) and string.match(prefix, id) then table.insert(list, name) end
        end
    else
        if drill_exists(entry) then
            for id, list in pairs(prefix_table) do table.insert(list, entry) end
        end
    end
end

local exp_area_exclusions = {
    ['tinyminingdrill'] = {'tiny-electric-mining-drill-3','tiny-electric-mining-drill-5'}
}
for mod_name, drills in pairs(exp_area_exclusions) do
    if mods[mod_name] then append_list(exclusions.area, drills) end
end

local function cursed(ex_list)
    local output = {}
    for _, ex_drill in pairs(ex_list) do
        for _, extractor in pairs(data.raw['mining-drill']) do
            if string.match(extractor.name, '[^;];[^;]') then
                local name = string.match(extractor.name, '([^;]+);[^;]+')
                if name == ex_drill then table.insert(output, extractor.name) end
            end
        end
    end
    append_list(ex_list, output)
end

if mods['Cursed-FMD'] then
    for _, ex_list in pairs(exclusions) do cursed(ex_list) end
end

for _, extractor in pairs(data.raw['mining-drill']) do
    local factor = extractor.output_fluid_box and SETTING.PumpSpeedFactor
    or SETTING.DrillSpeedFactor

    if not table_contains(exclusions.speed, extractor.name) then
        extractor.mining_speed = extractor.mining_speed * factor

        -- local energy_use = extractor.energy_usage
        -- if type(energy_use) == 'string' then
        --     local function extract(pattern) return string.match(energy_use, pattern) end
        --     local value, unit = tonumber(extract('%d+.%d+') or extract('%d+')), extract('%a+')
        --     extractor.energy_usage = (value * factor) .. unit
        -- elseif type(energy_use) == 'number' then
        --     extractor.energy_usage = energy_use * factor
        -- end

        -- if address_not_nil(extractor, 'energy_source', 'emissions_per_minute', 'pollution') then
        --     local pollution = extractor.energy_source.emissions_per_minute.pollution
        --     extractor.energy_source.emissions_per_minute.pollution =
        --         pollution > 0 and pollution * factor
        -- end

    end

    if extractor.output_fluid_box == nil then
        local radius = extractor.resource_searching_radius
        if not table_contains(exclusions.area, extractor.name) and radius > 0.5 then
            local num = math.floor(SETTING.DrillAreaFactor * math.ceil(radius * 2))
            local adj = math.ceil(radius * 2) % 2 == 0 and (num - num % 2) or (num - 1 + num % 2)
            extractor.resource_searching_radius = adj/2 - 0.01
        end
        if extractor.radius_visualisation_picture == nil
        and extractor.resource_searching_radius > radius then
            extractor.radius_visualisation_picture = {
                filename = '__base__/graphics/entity/electric-mining-drill/'
                    .. 'electric-mining-drill-radius-visualization.png',
                width = 12, height = 12}
        end
    end

    if not table_contains(exclusions.slots, extractor.name) then
        if extractor.module_slots ~= nil and extractor.module_slots > 0 then
            local slots = extractor.module_slots
            extractor.module_slots = math.min(slots + SETTING.ExtraModuleSlots, 20)
        end
    end

end

local pumpSpeedMultiplier = settings.startup['priyutils-pumpjack-output-speed-factor'].value
if data.raw['pump']['pump'] then
    data.raw['pump']['pump'].pumping_speed = 1200 * pumpSpeedMultiplier
end
