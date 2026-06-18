local data_util = require("data_util")

local function move_technology(tech_name, techs_to_add, ingredients_to_add, techs_to_remove, ingredients_to_remove)
    if ingredients_to_remove then
      data_util.tech_remove_ingredients(tech_name, ingredients_to_remove)
    end
    if techs_to_remove then
      data_util.tech_remove_prerequisites(tech_name, techs_to_remove)
    end
    if ingredients_to_add then
      data_util.tech_add_ingredients(tech_name, ingredients_to_add)
    end
    if techs_to_add then
      data_util.tech_add_prerequisites(tech_name, techs_to_add)
    end
  end

-- Effect Transmission
-- K2 sets this research cost to 500, we return it to SEs value
data.raw.technology["effect-transmission"].unit.count = 75

-- Needs to be done here to prevent recursive removal of utility from all parent techs due to being more integrated in the tech tree
move_technology(
  "inserter-capacity-bonus-7",
  {"kr-superior-inserters"},
  {"utility-science-pack","kr-optimization-tech-card","se-astronomic-science-pack-2"}
)
