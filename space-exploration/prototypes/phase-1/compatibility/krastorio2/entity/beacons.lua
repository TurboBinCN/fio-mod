local data_util = require("data_util")

-- Combine/Update the Singularity Beacon and Compact Beacon 2

---- Production ----
-- Basic Beacon       = 0.5  *  8 modules =  4.0 module equivalent over 9*9 area
---- Energy 2 ----
-- Compact Beacon     = 0.75 * 10 modules =  7.5 module equivalent over 6*6 area
-- Wide Area Beacon   = 0.5  * 15 modules =  7.5 module equivalent over 32*32 area
---- DSS 2 ----
-- Compact Beacon 2   = 1.0  * 10 modules = 10.0 module equivalent over 6*6 area
-- Wide Area Beacon 2 = 0.5  * 20 modules = 10.0 module equivalent over 32*32 area

if data.raw.beacon["kr-singularity-beacon"] then
  ---- Graphics Conversion ----
  local adv_beacon = data.raw.beacon["kr-singularity-beacon"]
  local adv_beacon_item = data.raw.item["kr-singularity-beacon"]
  local compact_beacon_2 = data.raw.beacon["se-compact-beacon-2"]
  local compact_beacon_2_item = data.raw.item["se-compact-beacon-2"]

  -- Set Compact Beacon 2 graphics to the Advanced Beacon from K2
  compact_beacon_2.icon = adv_beacon.icon
  compact_beacon_2.icon_size = adv_beacon.icon_size
  compact_beacon_2.base_picture = adv_beacon.base_picture
  compact_beacon_2.animation = adv_beacon.animation
  compact_beacon_2.animation_shadow = adv_beacon.animation_shadow
  compact_beacon_2.water_reflection = adv_beacon.water_reflection
  compact_beacon_2.open_sound = adv_beacon.open_sound
  compact_beacon_2.close_sound = adv_beacon.close_sound

  -- Hide Adv Beacon
  adv_beacon.hidden = true
  adv_beacon_item.hidden = true

  -- Set Adv Beacon module definition to have 15 modules to allow the migration to work correctly
  adv_beacon.module_slots = 15

  -- Set item graphics
  compact_beacon_2_item.icon = adv_beacon_item.icon

  -- Set recipe graphics
  data.raw.recipe["se-compact-beacon-2"].icon = data.raw.recipe["kr-singularity-beacon"].icon

  -- Make the Advanced Beacon item place the Compact Beacon 1 entity
  adv_beacon_item.place_result = "se-compact-beacon"

  -- Prevent the Advanced Beacon from being used to build Compact Beacon 1 in blueprints
  local compact_beacon_item = data.raw.item["se-compact-beacon"]
  if compact_beacon_item.flags == nil then
    compact_beacon_item.flags = {}
  end
  table.insert(compact_beacon_item.flags, "primary-place-result")

  -- Remove Advanced Beacon recipe.
  data_util.delete_recipe("kr-singularity-beacon")

  ---- Beacon Recipes ----
  -- Compact Beacon
  data_util.replace_or_add_ingredient("se-compact-beacon", "processing-unit", "processing-unit", 15)
  data_util.replace_or_add_ingredient("se-compact-beacon", "low-density-structure", "low-density-structure", 15)
  data_util.replace_or_add_ingredient("se-compact-beacon", "se-holmium-cable", "se-holmium-cable", 60)
  data_util.replace_or_add_ingredient("se-compact-beacon", nil, "kr-energy-control-unit", 5)
  data_util.replace_or_add_ingredient("se-compact-beacon", nil, "kr-imersium-plate", 10)

  -- Wide Area Beacon
  data_util.replace_or_add_ingredient("se-wide-beacon", "processing-unit", "processing-unit", 30)
  data_util.replace_or_add_ingredient("se-wide-beacon", "low-density-structure", "low-density-structure", 30)
  data_util.replace_or_add_ingredient("se-wide-beacon", "se-holmium-cable", "se-holmium-cable", 120)
  data_util.replace_or_add_ingredient("se-wide-beacon", nil, "kr-energy-control-unit", 10)
  data_util.replace_or_add_ingredient("se-wide-beacon", nil, "kr-imersium-plate", 20)

  ---- Beacon Technologies ----
  -- Compact Beacon
  data_util.tech_add_prerequisites("se-compact-beacon",{"kr-energy-control-unit"})

  -- Wide Area Beacon
  data_util.tech_add_prerequisites("se-wide-beacon",{"kr-energy-control-unit"})

  -- -- Compact Beacon 2
  local compact_beacon_2_tech = data.raw.technology["se-compact-beacon-2"]
  local adv_beacon_tech = data.raw.technology["kr-singularity-beacon"]
  -- Set technology graphics
  compact_beacon_2_tech.icon = adv_beacon_tech.icon
  compact_beacon_2_tech.icon_size = adv_beacon_tech.icon_size
  -- Remove Advanced Beacon tech.
  data.raw.technology["kr-singularity-beacon"] = nil

end
