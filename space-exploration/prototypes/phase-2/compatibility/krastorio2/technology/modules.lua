local data_util = require("data_util")

-- Module 1s require Electronic Components.
data_util.tech_add_prerequisites("modules",{"advanced-circuit"})

-- Speed Modules require Immersite
data_util.tech_add_prerequisites("speed-module-3", {"kr-quarry-minerals-extraction"})
