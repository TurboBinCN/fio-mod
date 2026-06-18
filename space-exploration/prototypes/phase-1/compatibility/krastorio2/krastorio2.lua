local data_util = require("data_util")
local path = "prototypes/phase-1/compatibility/krastorio2/"

if mods["Krastorio2"] then
  -- Progression in base K2 had Production and Utility sciences before Rocket Science prior to v0_6
  -- Now that SE pushes Production and Utility to after Rocket Science but before the Specialist Sciences
  -- we need to adjust the tech progression in SE-K2.
  --
  -- Pre-Rocket Sciences
  -- Rocket Science
  -- Production/Utility/Optimization 1
  -- Material/Biological/Astronomic/Energy 1
  -- Material/Biological/Astronomic/Energy 2
  -- Material/Biological/Astronomic/Energy 3
  -- Optimization 2 (Advanced) / Matter 1
  -- Material/Biological/Astronomic/Energy 4
  -- Deep Space 1
  -- Deep Space 2
  -- Deep Space 3/Matter 2
  -- Optimisation 3 (Singularity)
  -- Deep Space 4

  -- Suggested Philosophy for Singularity in K2SE context:
  -- Singularity Tech is the improvements of current technology with Arcosphere physics bending insights

  -- New Catagories
  require(path .. "categories.lua")

  -- Changes to Entities
  require(path .. "entity/entity_compat")

  -- Changes to Items
  require(path .. "item/item_compat")

  -- Changes to Recipes
  require(path .. "recipe/recipe_compat")

  -- Changes to Technologies
  require(path .. "technology/technology_compat")

  -- K2 has the option to disable the K2 Advanced Lab, as such we have specifc compat for this
  require(path .. "kr-advanced-lab")

  -- Specific creation of the Space and Deep Space loaders in SE-K2
  require(path .. "loaders")

  -- Bring the K2 stack sizes into alignment
  require(path .. "stack-sizes")

  -- Handle Resource generation parameters
  require(path .. "resource-gen")

  -- Handle Ordering
  require(path .. "ordering")

  -- Handle Mod-data
  require(path .. "mod-data")
end
