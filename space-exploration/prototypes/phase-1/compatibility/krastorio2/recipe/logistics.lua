local data_util = require("data_util")

-- Belts & Stuff
data_util.replace_or_add_ingredient("kr-advanced-splitter","kr-steel-gear-wheel","kr-imersium-gear-wheel",4)
data_util.replace_or_add_ingredient("kr-advanced-transport-belt","kr-steel-gear-wheel","kr-imersium-gear-wheel",4)

data_util.replace_or_add_ingredient("kr-superior-splitter",nil,"se-heavy-bearing",4)
data_util.replace_or_add_ingredient("kr-superior-transport-belt",nil,"se-heavy-bearing",4)

-- Include SE Resources in Advanced Roboport Recipes
data_util.replace_or_add_ingredient("kr-big-roboport","kr-rare-metals","kr-rare-metals",40)
data_util.replace_or_add_ingredient("kr-big-roboport",nil,"se-aeroframe-scaffold",20)
data_util.replace_or_add_ingredient("kr-big-roboport",nil,"se-heavy-composite",20)

data_util.replace_or_add_ingredient("kr-small-roboport","kr-rare-metals","kr-rare-metals",10)
data_util.replace_or_add_ingredient("kr-small-roboport",nil,"se-aeroframe-scaffold",5)
data_util.replace_or_add_ingredient("kr-small-roboport",nil,"se-heavy-composite",5)

-- Bring K2 Planetary Teleporter recipe closer in line with Arcolink Chest
-- No arcospheres due to same-surface restriction that currently exists?
data.raw.recipe["kr-planetary-teleporter"].ingredients = { -- this needs to change too much to make item by item changes
  {type = "item", name = "se-nanomaterial", amount = 10},
  {type = "item", name = "se-lattice-pressure-vessel",amount = 10},
  {type = "item", name = "se-heavy-assembly", amount = 10},
  {type = "item", name = "se-self-sealing-gel", amount = 10},
  {type = "item", name = "kr-energy-control-unit", amount = 10},
  {type = "item", name = "se-dynamic-emitter", amount = 10},
  {type = "item", name = "se-naquium-processor", amount = 10},
  {type = "item", name = "kr-teleportation-gps-module", amount = 1}
}

-- Superior Inserter
if data.raw.recipe["kr-superior-inserter"] then
  -- 1 x Stack Inserter
  -- 1 x Processing Unit
  -- 1 x Imersium Plate
  -- 2 x Imersium Gear Wheel
  -- 2 x Heavy Bearing
  data_util.replace_or_add_ingredient("kr-superior-inserter","kr-inserter-parts","bulk-inserter",1)
  data_util.replace_or_add_ingredient("kr-superior-inserter","kr-imersium-gear-wheel","kr-imersium-gear-wheel",2)
  data_util.replace_or_add_ingredient("kr-superior-inserter",nil,"se-heavy-bearing",2)
end

-- Superior Long Inserter
if data.raw.recipe["kr-superior-long-inserter"] then
  -- 1 x Stack Inserter
  -- 1 x Processing Unit
  -- 1 x Imersium Plate
  -- 2 x Imersium Gear Wheel
  -- 1 x Heavy Bearing
  -- 1 x Aeroframe Scaffold
  data_util.replace_or_add_ingredient("kr-superior-long-inserter","kr-inserter-parts","bulk-inserter",1)
  data_util.replace_or_add_ingredient("kr-superior-long-inserter","kr-imersium-gear-wheel","kr-imersium-gear-wheel",2)
  data_util.replace_or_add_ingredient("kr-superior-long-inserter",nil,"se-heavy-bearing",1)
  data_util.replace_or_add_ingredient("kr-superior-long-inserter",nil,"se-aeroframe-scaffold",1)
end

-- Superior Filter Inserter
if data.raw.recipe["kr-superior-inserter"] then
  -- 1 x Stack Inserter
  -- 2 x Processing Unit
  -- 1 x Imersium Plate
  -- 2 x Imersium Gear Wheel
  -- 2 x Heavy Bearing
  data_util.replace_or_add_ingredient("kr-superior-inserter","kr-inserter-parts","bulk-inserter",1)
  data_util.replace_or_add_ingredient("kr-superior-inserter","kr-imersium-gear-wheel","kr-imersium-gear-wheel",2)
  data_util.replace_or_add_ingredient("kr-superior-inserter",nil,"se-heavy-bearing",2)
end

-- Superior Long Filter Inserter
if data.raw.recipe["kr-superior-long-inserter"] then
  -- 1 x Stack Inserter
  -- 2 x Processing Unit
  -- 1 x Imersium Plate
  -- 2 x Imersium Gear Wheel
  -- 1 x Heavy Bearing
  -- 1 x Aeroframe Scaffold
  data_util.replace_or_add_ingredient("kr-superior-long-inserter","kr-inserter-parts","bulk-inserter",1)
  data_util.replace_or_add_ingredient("kr-superior-long-inserter","kr-imersium-gear-wheel","kr-imersium-gear-wheel",2)
  data_util.replace_or_add_ingredient("kr-superior-long-inserter",nil,"se-heavy-bearing",1)
  data_util.replace_or_add_ingredient("kr-superior-long-inserter",nil,"se-aeroframe-scaffold",1)
end
