local data_util = require("data_util")

-- This source is dedicated to ensuring a coherant and spaced out progression of the labs provided in SE-K2.
-- 1. Burner Lab (Ground Only)
--    -- Basic Tech Card
--    -- Automation Tech Card
-- 2. Electric Lab (Ground Only)
--    -- As Burner Lab, plus
--    -- Logistic Tech Card
--    -- Military Tech Card
--    -- Chemical Tech Card
--    -- Rocket Tech Card
-- 3. Advanced Lab (Space Only)
--    -- As Electric Lab, plus
--    -- Space Science Pack
--    -- Production Science Pack
--    -- Utility Science Pack
--    -- Optimization Tech Card
-- 4. Space Lab (Space Only)
--    -- As Advanced Lab, plus
--    -- Astronomic Science Pack 1-4
--    -- Energy Science Pack 1-4
--    -- Material Science Pack 1-4
--    -- Biological Science Pack 1-4
--    -- Matter Science Pack 1
--    -- Advanced Tech Card
-- 5. Singularity Lab (Space Only)
--    -- As Space Lab, plus
--    -- Matter Science Pack 2
--    -- Deep Space Science Pack 1-4
--    -- Singularity Tech Card

if data.raw["lab"]["burner-lab"] then
  local burn_lab = data.raw["lab"]["burner-lab"]
  local prev_inputs = burn_lab.inputs
  local burn_lab_inputs = {
    "kr-basic-tech-card",
    "automation-science-pack",
  }

  -- Ensure other packs that are available in this lab are still availabe
  for _, pack in pairs(prev_inputs) do
    if not data_util.table_contains(burn_lab_inputs, pack) then
      table.insert(burn_lab_inputs, pack)
    end
  end

  burn_lab.inputs = burn_lab_inputs
end

if data.raw["lab"]["lab"] then
  local lab = data.raw["lab"]["lab"]
  local prev_inputs = lab.inputs
  local lab_inputs = {
    "kr-basic-tech-card",
    "automation-science-pack",
    "logistic-science-pack",
    "military-science-pack",
    "chemical-science-pack",
    "se-rocket-science-pack",
  }

  -- Ensure other packs that are available in this lab are still availabe
  for _, pack in pairs(prev_inputs) do
    if not data_util.table_contains(lab_inputs, pack) then
      table.insert(lab_inputs, pack)
    end
  end

  lab.inputs = lab_inputs
  lab.next_upgrade = nil
end

-- Advanced Lab Tech
data_util.tech_remove_prerequisites("kr-advanced-lab", {"chemical-science-pack"})
data_util.tech_add_prerequisites("kr-advanced-lab", {"se-space-belt"})
data_util.tech_add_ingredients("kr-advanced-lab", {"se-rocket-science-pack"})

-- Advanced Lab Input
if data.raw["lab"]["kr-advanced-lab"] then
  local adv_lab = data.raw["lab"]["kr-advanced-lab"]
  local prev_inputs = adv_lab.inputs
  local adv_lab_inputs = {
    "kr-basic-tech-card",
    "automation-science-pack",
    "logistic-science-pack",
    "military-science-pack",
    "chemical-science-pack",
    "se-rocket-science-pack",
    "space-science-pack",
    "production-science-pack",
    "utility-science-pack",
    "kr-optimization-tech-card",
  }

  -- Ensure other packs that are available in this lab are still availabe
  for _, pack in pairs(prev_inputs) do
    if not data_util.table_contains(adv_lab_inputs, pack) then
      table.insert(adv_lab_inputs, pack)
    end
  end

  adv_lab.researching_speed = 2.5 -- was 1
  adv_lab.module_slots = 3 -- was 2
  adv_lab.inputs = adv_lab_inputs
  -- Make space only
  adv_lab.collision_mask = data.raw["lab"]["se-space-science-lab"].collision_mask
  adv_lab.localised_description = {"entity-description."..adv_lab.name}
end

-- Adjust other technologies that had Space Lab as a prereq to point to the Advanced Lab
data_util.tech_remove_prerequisites("space-science-pack", {"se-space-science-lab"})
data_util.tech_add_prerequisites("space-science-pack", {"kr-advanced-lab"})

-- Add Space Science Lab tech as prerequisites for the space sciences
data_util.tech_add_prerequisites("se-astronomic-science-pack-1",{"se-space-science-lab"})
data_util.tech_add_prerequisites("se-biological-science-pack-1",{"se-space-science-lab"})
data_util.tech_add_prerequisites("se-energy-science-pack-1",{"se-space-science-lab"})
data_util.tech_add_prerequisites("se-material-science-pack-1",{"se-space-science-lab"})

-- Space Lab Inputs
if data.raw["lab"]["se-space-science-lab"] and data.raw["lab"]["kr-advanced-lab"] then -- Advanced lab must exist for this to be done.
  local se_lab = data.raw["lab"]["se-space-science-lab"]
  local prev_inputs = se_lab.inputs
  local se_lab_inputs = {
    "kr-basic-tech-card",
    "automation-science-pack",
    "logistic-science-pack",
    "military-science-pack",
    "chemical-science-pack",
    "se-rocket-science-pack",
    "space-science-pack",
    "production-science-pack",
    "utility-science-pack",
    "kr-optimization-tech-card",
    "kr-advanced-tech-card",
    "se-astronomic-science-pack-1",
    "se-astronomic-science-pack-2",
    "se-astronomic-science-pack-3",
    "se-astronomic-science-pack-4",
    "se-biological-science-pack-1",
    "se-biological-science-pack-2",
    "se-biological-science-pack-3",
    "se-biological-science-pack-4",
    "se-energy-science-pack-1",
    "se-energy-science-pack-2",
    "se-energy-science-pack-3",
    "se-energy-science-pack-4",
    "se-material-science-pack-1",
    "se-material-science-pack-2",
    "se-material-science-pack-3",
    "se-material-science-pack-4",
    "kr-matter-tech-card",
  }
  local se_lab_excluded = {
    "kr-singularity-tech-card",
    "se-kr-matter-science-pack-2",
    "se-deep-space-science-pack-1",
    "se-deep-space-science-pack-2",
    "se-deep-space-science-pack-3",
    "se-deep-space-science-pack-4",
  }

  -- Ensure other packs that are available in this lab are still availabe
  for _, pack in pairs(prev_inputs) do
    if    not data_util.table_contains(se_lab_inputs, pack)
      and not data_util.table_contains(se_lab_excluded, pack)
    then
      table.insert(se_lab_inputs, pack)
    end
  end

  se_lab.researching_speed = 5 -- was 10
  se_lab.module_slots = 6 -- was 6
  se_lab.inputs = se_lab_inputs

  --log("EDW Space Lab inputs: " .. serpent.block(se_lab_inputs))
end

-- Singularity Lab Tech
data.raw.technology["kr-singularity-lab"].kr_check_science_packs_incompatibilities = false
data_util.tech_remove_prerequisites("kr-singularity-lab",{"kr-quantum-computer"})
data_util.tech_remove_ingredients("kr-singularity-lab",{"kr-deep-space-science-pack-1"})
data_util.tech_add_prerequisites("kr-singularity-lab",{"se-nanomaterial","kr-advanced-tech-card"})
data_util.tech_add_ingredients("kr-singularity-lab",{"kr-advanced-tech-card","se-astronomic-science-pack-4","se-energy-science-pack-4","se-material-science-pack-4","se-biological-science-pack-4","kr-matter-tech-card"})

data_util.tech_add_prerequisites("se-deep-catalogue-1",{"kr-singularity-lab"})
data_util.tech_add_ingredients("se-deep-catalogue-1",{"kr-advanced-tech-card","kr-matter-tech-card"})

data_util.tech_add_ingredients("se-deep-space-science-pack-1",{"production-science-pack","kr-advanced-tech-card","kr-matter-tech-card"})

-- Singularity Lab Inputs
if data.raw["lab"]["kr-singularity-lab"] then
  local k2_lab = data.raw["lab"]["kr-singularity-lab"]
  local prev_inputs = k2_lab.inputs
  local k2_lab_inputs = {
    "kr-basic-tech-card",
    "automation-science-pack",
    "logistic-science-pack",
    "military-science-pack",
    "chemical-science-pack",
    "se-rocket-science-pack",
    "space-science-pack",
    "production-science-pack",
    "utility-science-pack",
    "kr-optimization-tech-card",
    "kr-advanced-tech-card",
    "kr-singularity-tech-card",
    "se-astronomic-science-pack-1",
    "se-astronomic-science-pack-2",
    "se-astronomic-science-pack-3",
    "se-astronomic-science-pack-4",
    "se-biological-science-pack-1",
    "se-biological-science-pack-2",
    "se-biological-science-pack-3",
    "se-biological-science-pack-4",
    "se-energy-science-pack-1",
    "se-energy-science-pack-2",
    "se-energy-science-pack-3",
    "se-energy-science-pack-4",
    "se-material-science-pack-1",
    "se-material-science-pack-2",
    "se-material-science-pack-3",
    "se-material-science-pack-4",
    "kr-matter-tech-card",
    "se-kr-matter-science-pack-2",
    "se-deep-space-science-pack-1",
    "se-deep-space-science-pack-2",
    "se-deep-space-science-pack-3",
    "se-deep-space-science-pack-4",
  }

  -- Ensure other packs that are available in this lab are still availabe
  for _, pack in pairs(prev_inputs) do
    if not data_util.table_contains(k2_lab_inputs, pack) then
      table.insert(k2_lab_inputs, pack)
    end
  end

  -- Stagger lab stats
  k2_lab.researching_speed = 10 -- 2x SE version
  k2_lab.module_slots = 8 -- was 4
  k2_lab.inputs = k2_lab_inputs

  k2_lab.collision_mask = data.raw["lab"]["se-space-science-lab"].collision_mask
  k2_lab.localised_description = {"entity-description."..k2_lab.name}
end
