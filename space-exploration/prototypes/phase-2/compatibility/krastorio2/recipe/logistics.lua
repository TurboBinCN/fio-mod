local data_util = require("data_util")

-- Burner Inserter
if data.raw.recipe["burner-inserter"] then
  -- 1 x Single Cylinder Engine
  -- 1 x Inserter Parts
  data_util.replace_or_add_ingredient("burner-inserter","iron-plate","motor",1)
end

-- Inserter
if data.raw.recipe["inserter"] then
  -- 1 x Small Electric Motor
  -- 1 x Burner Inserter
  -- 1 x Automation Core
  data_util.replace_or_add_ingredient("inserter","kr-inserter-parts","burner-inserter",1)
  data_util.replace_or_add_ingredient("inserter",nil,"electric-motor",1)
end

-- Long Handed Inserter
if data.raw.recipe["long-handed-inserter"] then
  -- 2 x Iron Stick
  -- 1 x Inserter
  data_util.replace_or_add_ingredient("long-handed-inserter","kr-inserter-parts","inserter",1)
  data_util.remove_ingredient("long-handed-inserter","kr-automation-core")
end

-- Fast Inserter
if data.raw.recipe["fast-inserter"] then
  -- 2 x Electronic Circuit
  -- 1 x Inserter
  -- 1 x Steel Plate
  data_util.replace_or_add_ingredient("fast-inserter","kr-inserter-parts","inserter",1)
  data_util.replace_or_add_ingredient("fast-inserter","electronic-circuit","electronic-circuit",2)
end

-- Filter Inserter
if data.raw.recipe["filter-inserter"] then
  -- 2 x Electronic Circuit
  -- 1 x Fast Inserter
  -- 1 x Steel Plate
  data_util.replace_or_add_ingredient("filter-inserter","kr-inserter-parts","fast-inserter",1)
  data_util.replace_or_add_ingredient("filter-inserter","electronic-circuit","electronic-circuit",2)
end

-- Stack Inserter
if data.raw.recipe["bulk-inserter"] then
  -- 2 x Advanced Circuit
  -- 2 x Electronic Circuit
  -- 4 x Inserter Parts
  -- 1 x Fast Inserter
  -- 2 x Steel Gear Wheel
  data_util.replace_or_add_ingredient("bulk-inserter","kr-inserter-parts","kr-inserter-parts",4)
  data_util.replace_or_add_ingredient("bulk-inserter","steel-plate","fast-inserter",1)
  data_util.replace_or_add_ingredient("bulk-inserter",nil,"electronic-circuit",2)
end

-- Stack Filter Inserter
if data.raw.recipe["stack-filter-inserter"] then
  -- 2 x Advanced Circuits
  -- 2 x Electronic Circuits
  -- 1 x Stack Inserter
  -- 2 x Steel Gear Wheel
  data_util.replace_or_add_ingredient("stack-filter-inserter","kr-inserter-parts","bulk-inserter",1)
  data_util.replace_or_add_ingredient("stack-filter-inserter","steel-plate","electronic-circuit",2)
  data_util.replace_or_add_ingredient("stack-filter-inserter","advanced-circuit","advanced-circuit",2)
end

-- AAI Loaders has compatibility for both SE and K2 but not both at the same time.
-- Additionally it does not change the K2 loader costs either so we make them
-- as expensive as the non-lubricated AAI versions
if settings.startup["kr-loaders"].value then
  --kr-loader
  data_util.replace_or_add_ingredient("kr-loader","iron-gear-wheel","iron-gear-wheel",100)
  data_util.replace_or_add_ingredient("kr-loader","kr-iron-beam","electronic-circuit",50)

  --kr-fast-loader
  data_util.replace_or_add_ingredient("kr-fast-loader","iron-gear-wheel","electric-motor",50)
  data_util.replace_or_add_ingredient("kr-fast-loader",nil,"advanced-circuit",50)
  data_util.replace_or_add_ingredient("kr-fast-loader","kr-loader","kr-loader",1)

  --kr-express-loader
  data.raw.recipe["kr-express-loader"].category = "crafting-with-fluid"
  data_util.replace_or_add_ingredient("kr-express-loader","kr-steel-gear-wheel","electric-engine-unit",50)
  data_util.replace_or_add_ingredient("kr-express-loader",nil,"processing-unit",50)
  data_util.replace_or_add_ingredient("kr-express-loader","kr-fast-loader","kr-fast-loader",1)
  data_util.replace_or_add_ingredient("kr-express-loader",nil,"lubricant",500,true)

  --kr-advanced-loader
  data_util.replace_or_add_ingredient("kr-advanced-loader","kr-rare-metals","kr-rare-metals",50)
  data_util.replace_or_add_ingredient("kr-advanced-loader",nil,"kr-imersium-gear-wheel",50)
  data_util.replace_or_add_ingredient("kr-advanced-loader","kr-express-loader","kr-express-loader",1)

  --kr-superior-loader
  data_util.replace_or_add_ingredient("kr-superior-loader","kr-imersium-gear-wheel","kr-imersium-gear-wheel",50)
  data_util.replace_or_add_ingredient("kr-superior-loader",nil,"kr-imersium-plate",50)
  data_util.replace_or_add_ingredient("kr-superior-loader",nil,"se-heavy-bearing",50)
  data_util.replace_or_add_ingredient("kr-superior-loader","kr-advanced-loader","kr-advanced-loader",1)
end

if mods["aai-loaders"] then
  -- Lock the K2 Loaders behind the AAI techs.
  if settings.startup["kr-containers"].value then
    data_util.tech_lock_recipes("aai-loader",{"kr-loader"})
    data_util.tech_lock_recipes("aai-fast-loader",{"kr-fast-loader"})
    data_util.tech_lock_recipes("aai-express-loader",{"kr-express-loader"})
    data_util.tech_lock_recipes("aai-kr-advanced-loader",{"kr-advanced-loader"})
    data_util.tech_lock_recipes("aai-kr-superior-loader",{"kr-superior-loader"})
    data_util.tech_lock_recipes("aai-se-space-loader",{"kr-se-loader"})
    data_util.tech_lock_recipes("aai-se-deep-space-loader",{"kr-se-deep-space-loader-black"})
  end

  --aai-loader
  -- Don't need to add a belt, it already has one

  --aai-fast-loader
  data_util.replace_or_add_ingredient("aai-fast-loader",nil,"fast-transport-belt",1)

  --aai-express-loader
  data_util.replace_or_add_ingredient("aai-express-loader",nil,"express-transport-belt",1)

  --aai-se-deep-space-black-loader
  data_util.replace_or_add_ingredient("aai-se-deep-space-black-loader",nil,"aai-se-space-loader",1)

  if settings.startup["aai-loaders-mode"].value == "lubricated" then
    --aai-kr-advanced-loader
    data_util.replace_or_add_ingredient("aai-kr-advanced-loader","kr-steel-gear-wheel","kr-imersium-gear-wheel",5)

    --aai-kr-superior-loader
    data_util.replace_or_add_ingredient("aai-kr-superior-loader","kr-imersium-gear-wheel","kr-imersium-gear-wheel",5)
    data_util.replace_or_add_ingredient("aai-kr-superior-loader",nil,"se-heavy-bearing",5)

    --aai-se-deep-space-black-loader
    data_util.replace_or_add_ingredient("aai-se-deep-space-black-loader",nil,"kr-imersium-gear-wheel",1)
  else
    --aai-kr-advanced-loader
    data_util.replace_or_add_ingredient("aai-kr-advanced-loader","kr-steel-gear-wheel","kr-imersium-gear-wheel",50)

    --aai-kr-superior-loader
    data_util.replace_or_add_ingredient("aai-kr-superior-loader","kr-imersium-gear-wheel","kr-imersium-gear-wheel",50)
    data_util.replace_or_add_ingredient("aai-kr-superior-loader",nil,"se-heavy-bearing",50)

    --aai-se-deep-space-black-loader
    data_util.replace_or_add_ingredient("aai-se-deep-space-black-loader",nil,"kr-imersium-gear-wheel",10)
  end

end
