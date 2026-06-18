local data_util = require("data_util")

data_util.replace_or_add_ingredient("memory-unit", nil, data_util.mod_prefix .. "teleportation-data", 1) -- Does wormhole data make more sense?
data_util.tech_add_prerequisites("memory-unit", {data_util.mod_prefix .. "deep-space-science-pack-4"})
data_util.tech_add_ingredients("memory-unit", {data_util.mod_prefix .. "deep-space-science-pack-4"})

data_util.replace_or_add_ingredient("fluid-memory-unit", nil, data_util.mod_prefix .. "teleportation-data", 1)
data_util.tech_add_prerequisites("fluid-memory-storage", {data_util.mod_prefix .. "deep-space-science-pack-4"})
data_util.tech_add_ingredients("fluid-memory-storage", {data_util.mod_prefix .. "deep-space-science-pack-4"})
