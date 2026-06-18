-- Make MK3 miner an upgrade to the Area Miner
local miner_mk3 = data.raw["mining-drill"]["kr-electric-mining-drill-mk3"]
table.insert(miner_mk3.resource_categories, "hard-resource")
miner_mk3.module_slots = 5
miner_mk3.energy_usage = "500kW"
miner_mk3.mining_speed = 1.2
