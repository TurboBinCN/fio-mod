local data_util = require("data_util")

-- This source is dedicated to integrating the SE and K2 victory conditions
-- E.G.
--  - Making the Intergalactic Transceiver required for the Spaceship Victory technology.

-- Adjust the Intergalactic Transciever technology
local intergalactic_transceiver_tech = data.raw.technology["kr-intergalactic-transceiver"]
intergalactic_transceiver_tech.kr_check_science_packs_incompatibilities = false
intergalactic_transceiver_tech.icon = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver.png"
intergalactic_transceiver_tech.icon_size = 800
data_util.tech_remove_ingredients("kr-intergalactic-transceiver", {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"})
data_util.tech_add_ingredients("kr-intergalactic-transceiver",{"automation-science-pack","logistic-science-pack","chemical-science-pack","se-energy-science-pack-4","se-astronomic-science-pack-4","se-material-science-pack-4","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"})

local transceiver_item = data.raw.item["kr-intergalactic-transceiver"]
transceiver_item.icon = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver.png"
transceiver_item.icon_size = 800

-- Create dummy science pack for the trigger tech
local dummy_pack = {
  type = "tool",
  name = "se-kr-intergalactic-transceiver-activation",
  subgroup = "science-pack",
  durability = 1,
  icon = "__Krastorio2Assets__/icons/entities/intergalactic-transceiver.png",
  icon_size = 64,
  order = "zzz-dummy-pack",
  stack_size = 1,
  flags = {},
  hidden = true,
}

local intergalactic_transceiver_trigger_tech = {
  type = "technology",
  name = "se-kr-transceiver-trigger",
  effects = {}, -- No effects, this tech will be triggered by the activation of the transceiver
  icon = "__Krastorio2Assets__/technologies/intergalactic-transceiver.png",
  icon_size = 256,
  order = "e-g",
  prerequisites = {"kr-intergalactic-transceiver"},
  research_trigger = {type = "craft-item", item = "se-kr-intergalactic-transceiver-activation"},
  kr_check_science_packs_incompatibilities = false
}
data:extend({dummy_pack,intergalactic_transceiver_trigger_tech})

-- Disable SE Spaceship Victory tech. Enabled via script in space-explortation/scripts/compatibility/krastorio2
if data.raw.technology["se-spaceship-victory"] then
  data_util.tech_add_prerequisites("se-spaceship-victory",{"se-kr-transceiver-trigger"})
end

-- Replace Battery with Lithium-Sulfur Battery in a secret recipe.
data_util.replace_or_add_ingredient("se-gate-platform","battery","kr-lithium-sulfur-battery",100)
