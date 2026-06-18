local data_util = require("data_util")

-- Make the Area Mining Drill require K2s Electric Miner MK2
data_util.tech_add_prerequisites("area-mining-drill", {"kr-electric-mining-drill-mk2"})

-- Make MK3 miner an upgrade to the Area Miner
data.raw.technology["kr-electric-mining-drill-mk3"].kr_check_science_packs_incompatibilities = false
data_util.tech_add_prerequisites("kr-electric-mining-drill-mk3", {"kr-advanced-tech-card","area-mining-drill","se-dynamic-emitter","se-heavy-composite"})
data_util.tech_add_ingredients("kr-electric-mining-drill-mk3", {"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-advanced-tech-card","se-material-science-pack-3","se-energy-science-pack-4"})
