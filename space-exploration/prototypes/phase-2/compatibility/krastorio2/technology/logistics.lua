local data_util = require("data_util")

local kr_containers_enabled = settings.startup["kr-containers"].value

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

---- Train Braking Force ----
move_technology(
  "braking-force-1",
  {"se-heat-shielding"}
)

move_technology(
  "braking-force-3",
  data.raw["technology"]["kr-nuclear-locomotive"] and {"kr-nuclear-locomotive"} or {"se-processing-iridium"}
)

move_technology(
  "braking-force-6",
  {"kr-logistic-4"}
)

move_technology(
  "braking-force-7",
  {"kr-logistic-5"}
)

---- Inserter Capacity Bonus ----
  -- inserter capacity bonus is production science only

move_technology(
  "inserter-capacity-bonus-3",
  {"low-density-structure"}
)

move_technology(
  "inserter-capacity-bonus-4",
  {"space-science-pack"},
  nil,
  {"space-science-pack"}
)

move_technology(
  "inserter-capacity-bonus-5",
  {"logistics-3","production-science-pack"}
)

move_technology(
  "inserter-capacity-bonus-6",
  {"se-material-science-pack-1"}
)

-- Level 7 is modified in phase-3 due to interactions with /phase-3/tehcnology.lua

---- Toolbelt ----
-- looks to be production science only
move_technology(
  "toolbelt-3",
  {"low-density-structure"}
)

move_technology(
  "toolbelt-4",
  {"logistics-3"}
)

move_technology(
  "toolbelt-5",
  {"kr-optimization-tech-card"},
  {"automation-science-pack","logistic-science-pack","kr-optimization-tech-card"}
)
data.raw.technology["toolbelt-5"].kr_check_science_packs_incompatibilities = false

move_technology(
  "toolbelt-6",
  {"kr-logistic-4"},
  {"kr-optimization-tech-card"}
)
data.raw.technology["toolbelt-6"].kr_check_science_packs_incompatibilities = false

---- Worker Robot Cargo Size ----
-- Maintain release values currently
move_technology(
  "worker-robots-storage-1",
  {"logistics-3"},
  {"space-science-pack"},
  nil
)

move_technology(
  "worker-robots-storage-2",
  {"inserter-capacity-bonus-5", "kr-optimization-tech-card"},
  {"kr-optimization-tech-card"}
)
data.raw.technology["worker-robots-storage-2"].kr_check_science_packs_incompatibilities = false

move_technology(
  "worker-robots-storage-3",
  {"kr-logistic-4"},
  {"kr-optimization-tech-card"}
)
data.raw.technology["worker-robots-storage-3"].kr_check_science_packs_incompatibilities = false

data_util.tech_remove_prerequisites("worker-robots-speed-3",{"utility-science-pack"})
data_util.tech_add_prerequisites("worker-robots-speed-3",{"se-thruster-suit"})
data_util.tech_remove_prerequisites("worker-robots-speed-5",{"production-science-pack"})

--Integrate Material Science and its products into K2 Belts.
data.raw.technology["kr-logistic-4"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-logistic-4", {"utility-science-pack"})
data_util.tech_add_prerequisites("kr-logistic-4", {"kr-imersium-processing","se-material-science-pack-1"})
data_util.tech_add_ingredients("kr-logistic-4", {"se-material-science-pack-1","utility-science-pack"})

data.raw.technology["kr-logistic-5"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-logistic-5", {"kr-advanced-tech-card"})
data_util.tech_remove_ingredients("kr-logistic-5", {"kr-advanced-tech-card"})
data_util.tech_add_prerequisites("kr-logistic-5", {"kr-optimization-tech-card","se-heavy-bearing"})
data_util.tech_add_ingredients("kr-logistic-5", {"automation-science-pack","utility-science-pack","logistic-science-pack","chemical-science-pack","kr-optimization-tech-card","se-material-science-pack-2"})

-- AAI Loaders
if data.raw.technology["aai-kr-advanced-loader"] then
  data.raw.technology["aai-kr-advanced-loader"].kr_check_science_packs_incompatibilities = false
  data_util.tech_add_ingredients("aai-kr-advanced-loader", {"se-material-science-pack-1"})
  data_util.tech_remove_ingredients("aai-kr-advanced-loader", {"utility-science-pack"})
end
if data.raw.technology["aai-kr-superior-loader"] then
  data.raw.technology["aai-kr-superior-loader"].kr_check_science_packs_incompatibilities = false
  data_util.tech_add_ingredients("aai-kr-superior-loader", {"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-optimization-tech-card","se-material-science-pack-2"})
  data_util.tech_remove_ingredients("aai-kr-superior-loader", {"kr-advanced-tech-card"})
end
