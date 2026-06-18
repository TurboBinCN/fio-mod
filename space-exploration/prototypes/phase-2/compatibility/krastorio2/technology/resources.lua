local data_util = require("data_util")

-- Merge the Sand/Glass recipes
data_util.tech_lock_recipes("kr-stone-processing",{"sand-from-stone"})
data_util.tech_lock_recipes("se-pulveriser",{"kr-sand"})

-- Add Enriched Ore as a prerequisite to vulcanie processing
table.insert(data.raw.technology["se-processing-vulcanite"].prerequisites, "kr-enriched-ores")
