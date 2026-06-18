local data_util = require("data_util")


data_util.enable_recipe("kr-first-aid-kit")

-- Alt First Aid Kit
local first_aid_kit_2 = table.deepcopy(data.raw.recipe["kr-first-aid-kit"])
first_aid_kit_2.name = "se-kr-first-aid-kit-fish"
first_aid_kit_2.localised_name = {"item-name.kr-first-aid-kit"}
data:extend({first_aid_kit_2})
data_util.replace_or_add_ingredient("se-kr-first-aid-kit-fish", "kr-biomass", "raw-fish", 1)
