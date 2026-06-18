local data_util = require("data_util")

if mods["quality"] then

  data.raw.item["recycler"].subgroup = "mechanical" -- recycling facility, mechanical facility & pulverizer
  data.raw.item["recycler"].order = "z-b-recycler" -- at the end of those 3
  data.raw.furnace["recycler"].se_allow_in_space = true
  data_util.tech_remove_prerequisites("recycling", {"production-science-pack"})
  data_util.tech_remove_ingredients("recycling", {"space-science-pack", "production-science-pack"})
  data_util.tech_add_prerequisites("recycling", {data_util.mod_prefix .. "recycling-facility"})
  data.raw.technology["recycling"].unit.time = 30
  data.raw.technology["recycling"].unit.count = 400

end
