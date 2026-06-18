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

-- Advanced Chemical Plant
-- Tell K2 to not check science pack coherance since SE-K2 has a different paradigm
data.raw.technology["kr-advanced-chemical-plant"].kr_check_science_packs_incompatibilities = false
--Make Changes
move_to_specialist_science_packs("kr-advanced-chemical-plant", {"se-biological-science-pack-2","kr-optimization-tech-card"})
data_util.tech_add_ingredients("kr-advanced-chemical-plant", {"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-optimization-tech-card"})

-- Advanced Furnace
-- Tell K2 to not check science pack coherance since SE-K2 has a different paradigm
data.raw.technology["kr-advanced-furnace"].kr_check_science_packs_incompatibilities = false
--Make Changes
move_to_specialist_science_packs("kr-advanced-furnace", {"se-material-science-pack-1"})
data_util.tech_add_ingredients("kr-advanced-furnace", {"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-optimization-tech-card","se-energy-science-pack-1"})

-- Advanced Assembler
-- Tell K2 to not check science pack coherance since SE-K2 has a different paradigm
data.raw.technology["kr-automation"].kr_check_science_packs_incompatibilities = false
-- Make changes
move_to_specialist_science_packs("kr-automation", {"se-material-science-pack-2","kr-optimization-tech-card"})
data_util.tech_add_ingredients("kr-automation", {"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-optimization-tech-card"})
data_util.tech_add_prerequisites("kr-automation", {"se-heavy-bearing"})
data_util.tech_remove_prerequisites("kr-automation", {"kr-energy-control-unit"})

-- Supercomputer 3
data_util.tech_add_prerequisites("se-space-supercomputer-3",{"kr-ai-core"})

-- Supercomputer 4
data.raw.technology["se-space-supercomputer-4"].kr_check_science_packs_incompatibilities = false
data_util.tech_add_ingredients("se-space-supercomputer-4", {"automation-science-pack","logistic-science-pack","chemical-science-pack","kr-matter-tech-card"})

data_util.tech_remove_prerequisites("se-space-decontamination-facility", {"space-science-pack"})

-- Move the Research Server technology
data_util.tech_add_prerequisites("kr-research-server",{"se-space-supercomputer-1"})
data_util.tech_add_ingredients("kr-research-server",{"se-rocket-science-pack","space-science-pack"})
data_util.tech_remove_prerequisites("kr-research-server",{"chemical-science-pack"})

-- Move the Advanced Research Server technology
data_util.tech_add_prerequisites("kr-quantum-computer",{"se-space-supercomputer-2","se-material-science-pack-3"})
data_util.tech_add_ingredients("kr-quantum-computer",{"se-biological-science-pack-3","se-energy-science-pack-3","se-material-science-pack-3"})
