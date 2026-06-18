local data_util = require("data_util")

-- Spidertron
data_util.remove_ingredient("spidertron", "kr-ai-core")
data_util.remove_ingredient("spidertron", "kr-fusion-reactor-equipment")
data_util.replace_or_add_ingredient("spidertron", "se-rtg-equipment", "fission-reactor-equipment", 2)

-- Sheild Projector
-- Include K2 Advanced Tech Card and Lithium Sulfur Battery instead of Base battery.
data_util.replace_or_add_ingredient("shield-projector","battery","kr-lithium-sulfur-battery",160)

---- Shields
-- Clean up unused K2 alternate recipes and techs.
data.raw.recipe["kr-energy-shield-mk3-equipment"] = nil
data.raw.recipe["kr-energy-shield-mk4-equipment"] = nil
data.raw.recipe["kr-crush-kr-energy-shield-mk3-equipment"] = nil
data.raw.recipe["kr-crush-kr-energy-shield-mk4-equipment"] = nil
data.raw.recipe["kr-energy-shield-mk3-equipment-recycling"] = nil
data.raw.recipe["kr-energy-shield-mk4-equipment-recycling"] = nil

---- Batteries
-- Personal Battery Mk2
data_util.replace_or_add_ingredient("battery-mk2-equipment", nil, "se-holmium-cable", 2)
data_util.replace_or_add_ingredient("kr-big-battery-mk2-equipment", nil, "se-holmium-cable", 4)

-- Personal Battery Mk3
data_util.replace_or_add_ingredient("kr-battery-mk3-equipment", nil, "se-superconductive-cable", 2)
data_util.replace_or_add_ingredient("kr-big-battery-mk3-equipment", nil, "se-superconductive-cable", 4)
data_util.replace_or_add_ingredient("kr-big-battery-mk3-equipment", "kr-lithium-sulfur-battery", "kr-lithium-sulfur-battery", 8)
