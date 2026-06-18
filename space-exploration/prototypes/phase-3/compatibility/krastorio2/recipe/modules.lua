local data_util = require("data_util")

-- This source is dedicated to integrating K2 and SEs competing changes to Speed/Production/efficiency Modules 1-3

-- Speed Module 1
data_util.replace_or_add_ingredient("speed-module", "electronic-circuit", "electronic-circuit", 12) -- 20 in SE, 5 in K2
data_util.replace_or_add_ingredient("speed-module", "kr-electronic-components", "kr-electronic-components", 8) -- 10 in K2
data_util.replace_or_add_ingredient("speed-module", nil, "solid-fuel", 10) -- 10 in SE

-- Speed Module 2
data_util.replace_or_add_ingredient("speed-module-2", "advanced-circuit", "advanced-circuit", 12) -- 20 in SE, 5 in K2
data_util.replace_or_add_ingredient("speed-module-2", "electronic-circuit", "electronic-circuit", 8) -- 5 in K2
data_util.replace_or_add_ingredient("speed-module-2", nil, "electric-motor", 20) -- 20 in SE

-- Speed Module 3
data_util.replace_or_add_ingredient("speed-module-3", "processing-unit", "processing-unit", 12) -- 20 in SE
data_util.replace_or_add_ingredient("speed-module-3", "advanced-circuit", "advanced-circuit", 8) -- 5 in K2
data_util.replace_or_add_ingredient("speed-module-3", "electric-engine-unit", "kr-imersite-crystal", 40) -- 20 in SE, Crystals are now easier to make


-- Productivity Module 1
data_util.replace_or_add_ingredient("productivity-module", "electronic-circuit", "electronic-circuit", 15) -- 25 in SE, 5 in K2
data_util.replace_or_add_ingredient("productivity-module", "kr-electronic-components", "kr-electronic-components", 10) -- 10 in K2
data_util.replace_or_add_ingredient("productivity-module", nil, SEItemNames.get_glass_name(), 25) -- 25 in SE

-- Productivity Module 2
data_util.replace_or_add_ingredient("productivity-module-2", "advanced-circuit", "advanced-circuit", 15) -- 25 in SE, 5 in K2
data_util.replace_or_add_ingredient("productivity-module-2", "electronic-circuit", "electronic-circuit", 10) -- 5 in K2
data_util.replace_or_add_ingredient("productivity-module-2", nil, "sulfur", 50) -- 50 in SE

-- Productivity Module 3
data_util.replace_or_add_ingredient("productivity-module-3", "processing-unit", "processing-unit", 15) -- 25 in SE, 5 in K2
data_util.replace_or_add_ingredient("productivity-module-3", "advanced-circuit", "advanced-circuit", 10) -- 5 in K2
data_util.replace_or_add_ingredient("productivity-module-3", nil, "se-vulcanite-block", 50) -- 50 in SE

-- efficiency Module
data_util.replace_or_add_ingredient("efficiency-module", "electronic-circuit", "electronic-circuit", 10) -- 15 in SE, 5 in K2
data_util.replace_or_add_ingredient("efficiency-module", "kr-electronic-components", "kr-electronic-components", 5) -- 10 in K2
data_util.replace_or_add_ingredient("efficiency-module", nil, "copper-cable", 15) -- 15 in SE

-- efficiency Module 2
data_util.replace_or_add_ingredient("efficiency-module-2", "advanced-circuit", "advanced-circuit", 10) -- 15 in SE, 5 in K2
data_util.replace_or_add_ingredient("efficiency-module-2", "electronic-circuit", "electronic-circuit", 5) -- 5 in K2
data_util.replace_or_add_ingredient("efficiency-module-2", nil, "battery", 15) -- 15 in SE

-- efficiency Module 3
data_util.replace_or_add_ingredient("efficiency-module-3", "processing-unit", "processing-unit", 10) -- 15 in SE
data_util.replace_or_add_ingredient("efficiency-module-3", "advanced-circuit", "advanced-circuit", 5) -- 5 in K2
data_util.replace_or_add_ingredient("efficiency-module-3", nil, "se-cryonite-rod", 30) -- 30 in SE
