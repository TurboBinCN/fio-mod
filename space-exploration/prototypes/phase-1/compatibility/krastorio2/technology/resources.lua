local data_util = require("data_util")

local adv_condensation = table.deepcopy(data.raw.technology["kr-atmosphere-condensation"])
adv_condensation.name = "se-kr-catalysed-condensation"
adv_condensation.prerequisites = {}
adv_condensation.effects = {}
adv_condensation.icons = {
  {icon = "__Krastorio2Assets__/technologies/atmospheric-condenser.png", icon_size = 256},
  {icon = data.raw.item["se-cryonite-rod"].icon, icon_size = data.raw.item["se-cryonite-rod"].icon_size, scale = 1.5, shift = {-70,-70}}
}
data:extend({adv_condensation})

data_util.tech_add_prerequisites("se-kr-catalysed-condensation", {"se-energy-science-pack-1"})
data_util.tech_add_ingredients("se-kr-catalysed-condensation", {"se-rocket-science-pack","space-science-pack","utility-science-pack","se-energy-science-pack-1"})
data_util.tech_lock_recipes("se-kr-catalysed-condensation", {"se-kr-liquid-air","se-kr-liquid-purified-air","se-kr-air-separation"})

local adv_electrolysis = table.deepcopy(data.raw.technology["kr-fluids-chemistry"])
adv_electrolysis.name = "se-kr-catalysed-electrolysis"
adv_electrolysis.prerequisites = {}
adv_electrolysis.effects = {}
adv_electrolysis.icons = {
  {icon = "__space-exploration-graphics__/graphics/blank.png", icon_size = 64, scale = 1.5},
  {icon = "__Krastorio2Assets__/icons/entities/electrolysis-plant.png", icon_size = 64, scale = 1.25, shift = {12,12}},
  {icon = data.raw.item["se-iridium-plate"].icon, icon_size = data.raw.item["se-iridium-plate"].icon_size, scale = 0.75, shift = {-12,-12}}
}
data:extend({adv_electrolysis})

data_util.tech_add_prerequisites("se-kr-catalysed-electrolysis", {"se-material-science-pack-1"})
data_util.tech_remove_ingredients("se-kr-catalysed-electrolysis", {"kr-basic-tech-card"})
data_util.tech_add_ingredients("se-kr-catalysed-electrolysis", {"logistic-science-pack","chemical-science-pack","se-rocket-science-pack","space-science-pack","production-science-pack","se-material-science-pack-1"})
data_util.tech_lock_recipes("se-kr-catalysed-electrolysis", {"se-kr-catalysed-water-electrolysis", "se-kr-catalysed-water-separation"})
