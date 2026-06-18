local data_util = require("data_util")
local path = "prototypes/phase-3/compatibility/krastorio2/"

if mods["Krastorio2"] then

  -- Certain changes made by Krastorio 2 to Vanilla items and recipes occur in the data-update lifecycle phase (phase-2) and we can only adjust them here or in postprocess.
  -- Changes should only be made in this phase if those changes cannot be made in data (phase-1) or data-update (phase-2)
  require(path .. "item/item_compat")
  require(path .. "entity/entity_compat")
  require(path .. "fluid/fluid_compat")
  require(path .. "recipe/recipe_compat")
  require(path .. "technology/technology_compat")

  -- Enforce aspects of Rocekt Fuel balance
  require(path .. "rocket-fuel")

  -- Enforce aspects of voiding items.
  require(path .. "voiding")

  -- Specific changes relating to the path to victory in SE-K2
  require(path .. "victory")

  -- Specifc ordering changes that require phase-3
  require(path .. "ordering")

  -- Change the autoplace control for Imersite to show it has no effect on Nauvis
  local imersite_control = data.raw["autoplace-control"]["kr-imersite"]
  imersite_control.hidden = true

  -- Change the Space Exploration default to disable Imersite
  data.raw["map-gen-presets"].default["space-exploration"].basic_settings.autoplace_controls["kr-imersite"] = {size = 0}
end
