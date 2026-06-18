local data_util = require("data_util")

-- Substation Mk2
-- Tell K2 to leave this alone
data.raw.technology["electric-energy-distribution-3"].kr_check_science_packs_incompatibilities = false
-- Make Changes
data_util.tech_remove_prerequisites("electric-energy-distribution-3", {"kr-advanced-tech-card"})
data_util.tech_remove_ingredients("electric-energy-distribution-3", {"kr-advanced-tech-card"})
data_util.tech_add_prerequisites("electric-energy-distribution-3", {"kr-optimization-tech-card","se-holmium-cable"})
data_util.tech_add_ingredients("electric-energy-distribution-3", {"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-optimization-tech-card","se-energy-science-pack-1"})

-- K2 Fuel Refinery unlock tech renaming
data.raw.technology["kr-fuel"].localised_name = {"technology-name.se-fuel-refining"}

-- Rename SE Fuel Refinery unlock tech
data.raw.technology["se-fuel-refining"].localised_name = {"technology-name.se-kr-fuel-refining"}
data.raw.technology["se-fuel-refining"].localised_description = {"technology-description.se-kr-fuel-refining"}
