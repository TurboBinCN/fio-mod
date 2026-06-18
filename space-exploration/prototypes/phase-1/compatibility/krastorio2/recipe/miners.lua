local data_util = require("data_util")

-- Make the Area Mining Drill require K2s Electric Miner MK2
data_util.replace_or_add_ingredient("area-mining-drill", "electric-mining-drill", "kr-electric-mining-drill-mk2", 1)

-- Make MK3 miner an upgrade to the Area Miner
data_util.replace_or_add_ingredient("kr-electric-mining-drill-mk3", "kr-electric-mining-drill-mk2", "area-mining-drill", 1)
data_util.replace_or_add_ingredient("kr-electric-mining-drill-mk3", "kr-ai-core", "se-heavy-bearing", 10)
data_util.replace_or_add_ingredient("kr-electric-mining-drill-mk3", "kr-imersite-crystal", "se-dynamic-emitter", 2)
data_util.replace_or_add_ingredient("kr-electric-mining-drill-mk3", nil, "se-heavy-composite", 4)
