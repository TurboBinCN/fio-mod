local data_util = require("data_util")

local path = "prototypes/phase-1/compatibility/krastorio2/entity/"

-- This source is dedicated to making changes to K2 and SE entities

-- Ensure space collisisons are appropriate.
require(path .. "collisions")

require(path .. "assemblers")
require(path .. "beacons")
require(path .. "power")
require(path .. "meteors")
require(path .. "military")
require(path .. "science")

require(path .. "kr-electric-mining-drill-mk3")
