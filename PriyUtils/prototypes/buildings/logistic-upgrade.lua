if data.raw["transport-belt"]["express-transport-belt"] then
    data.raw["transport-belt"]["express-transport-belt"].next_upgrade = "kr-advanced-transport-belt"
end
if data.raw["underground-belt"]["express-underground-belt"] then
    data.raw["underground-belt"]["express-underground-belt"].next_upgrade = "kr-advanced-underground-belt"
end
if data.raw["splitter"]["express-splitter"] then
    data.raw["splitter"]["express-splitter"].next_upgrade = "kr-advanced-splitter"
end


if mods["space-exploration"] then
    data.raw["transport-belt"]["se-space-transport-belt"].next_upgrade = "se-deep-space-transport-belt-black"
    data.raw["underground-belt"]["se-space-underground-belt"].next_upgrade = "se-deep-space-underground-belt-black"
    data.raw["splitter"]["se-space-splitter"].next_upgrade = "se-deep-space-splitter-black"
end
