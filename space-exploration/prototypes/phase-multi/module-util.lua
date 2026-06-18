local module_util = {}

--[[
Design Challenge: Make Earendel's star
Requirements:
  The build must make tier 9 modules.
  The build must have the assembling machine counts below.
  All machines must be within range of 4 wide area beacons without any overloads.
  Modules of tiers 1-8 can only be be moved from assembling machine to assembling machine,
  they cannot be put in containers or belts.
  The build cannot use bots or arcolink, all belt fed, but can use DSS belts.
  No loaders, 90 degree inserters, super reach inserter, etc.
]]

module_util.machine_counts = {
  [1] = 120,
  [2] = 60,
  [3] = 40,
  [4] = 20,
  [5] = 12,
  [6] = 8,
  [7] = 4,
  [8] = 2,
  [9] = 1
}
module_util.final_time = 32
module_util.modules_per_tier = 2

module_util.energy_required = function(tier)
  --return (10 - tier) * 2 ^ tier / 4
  --return module_util.final_time / module_util.machine_counts[tier]
  return module_util.final_time * module_util.machine_counts[tier] / module_util.modules_per_tier ^ (9 - tier)
end

module_util.module_name = function(base_name, tier)
  local name = base_name
  if tier > 1 then
    name = name .. "-"..tier
  end
  return name
end

return module_util
