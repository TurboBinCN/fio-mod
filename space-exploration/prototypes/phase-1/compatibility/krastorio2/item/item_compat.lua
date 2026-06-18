local data_util = require("data_util")

local path = "prototypes/phase-1/compatibility/krastorio2/item/"

-- Change the name of the K2 Antimatter to be K2 Singularity
data.raw.item["kr-empty-antimatter-fuel-cell"].localised_name = {"item-name.empty-singularity-fuel-cell"}
data.raw.item["kr-charged-antimatter-fuel-cell"].localised_name = {"item-name.charged-singularity-fuel-cell"}

require(path .. "resources")
require(path .. "military")
require(path .. "power")
require(path .. "science")
require(path .. "matter")
