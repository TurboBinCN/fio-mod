local data_util = require("data_util")

local function move_to_specialist_science_packs(tech_name, science_packs, require_imersium)
  data_util.tech_remove_ingredients(tech_name, {"kr-optimization-tech-card", "kr-matter-tech-card", "kr-advanced-tech-card", "se-deep-space-science-pack-1"})
  data_util.tech_remove_prerequisites(tech_name, {"kr-optimization-tech-card", "kr-matter-tech-card", "kr-advanced-tech-card", "se-deep-space-science-pack-1"})
  data_util.tech_add_ingredients(tech_name, science_packs)
  data_util.tech_add_prerequisites(tech_name, science_packs)
  if require_imersium then
    data_util.tech_add_prerequisites(tech_name, {"kr-imersium-processing"})
  end
end

-- Rebalancing the K2 Fusion Reactor
data_util.tech_add_prerequisites("kr-fusion-energy", {"se-space-particle-collider"})
move_to_specialist_science_packs("kr-fusion-energy", {"se-energy-science-pack-2"})
data_util.tech_add_prerequisites("kr-fusion-energy", {"se-heavy-bearing","se-holmium-solenoid"})
data_util.tech_add_ingredients("kr-fusion-energy", {"se-material-science-pack-2"})
data_util.tech_lock_recipes("kr-fusion-energy",{"se-kr-advanced-condenser-turbine","kr-heavy-water","kr-tritium","kr-empty-dt-fuel-cell","kr-dt-fuel-cell"})

-- Accumulator 2
data_util.tech_add_prerequisites("se-space-accumulator",{"kr-energy-control-unit"})

-- Add Advanced Tech Card tech as cost for Radar Construction Pylon
data.raw.technology["se-pylon-construction-radar"].kr_check_science_packs_incompatibilities = false
data_util.tech_add_prerequisites("se-pylon-construction-radar",{"kr-advanced-tech-card"})
data_util.tech_add_ingredients("se-pylon-construction-radar",{"kr-advanced-tech-card"})

-- Move K2 Energy Storage Tech to after Naquium Accumulator
data.raw.technology["kr-energy-storage"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-energy-storage",{"electric-energy-accumulators","kr-energy-control-unit","kr-matter-tech-card"})
data_util.tech_add_prerequisites("kr-energy-storage",{"se-space-accumulator-2","se-naquium-processor"})
data_util.tech_add_ingredients("kr-energy-storage",{"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-advanced-tech-card","se-astronomic-science-pack-4","se-energy-science-pack-4","se-material-science-pack-4","se-deep-space-science-pack-3"})

-- Adjust techs so that K2 Solar Panel has the correct costs for it's position in the tech tree.
data.raw.technology["kr-advanced-solar-panel"].kr_check_science_packs_incompatibilities = false
data_util.tech_add_prerequisites("kr-advanced-solar-panel",{"kr-optimization-tech-card"})
data_util.tech_add_ingredients("kr-advanced-solar-panel", {"space-science-pack","kr-optimization-tech-card"})
data_util.tech_remove_ingredients("kr-advanced-solar-panel",{"production-science-pack"})

-- Adjust techs so that K2 Solar Panel is required for Flat Solar Panel
data.raw.technology["se-space-solar-panel"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("se-space-solar-panel", {"space-science-pack"})
data_util.tech_add_prerequisites("se-space-solar-panel",{"kr-advanced-solar-panel","se-holmium-cable"})
data_util.tech_add_ingredients("se-space-solar-panel", {"se-energy-science-pack-1"})

-- Adjust costs and tech requirement of Flat Solar Panel 2
data_util.tech_remove_prerequisites("se-space-solar-planel-2", {"se-holmium-cable"})
data_util.tech_remove_ingredients("se-space-solar-panel-2", {"se-energy-science-pack-1"})
data_util.tech_add_prerequisites("se-space-solar-panel-2", {"se-holmium-solenoid","se-aeroframe-scaffold"})
data_util.tech_add_ingredients("se-space-solar-panel-2", {"se-energy-science-pack-2","se-astronomic-science-pack-2"})

-- K2 Antimatter reactor, renamed to Singularity Reactor in locale
data.raw.technology["kr-antimatter-reactor"].kr_check_science_packs_incompatibilities = false
data_util.tech_add_prerequisites("kr-antimatter-reactor", {"se-antimatter-reactor"})
data_util.tech_add_ingredients("kr-antimatter-reactor", {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-energy-science-pack-4","se-material-science-pack-4","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"})
data_util.tech_remove_ingredients("kr-antimatter-reactor", {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"})
