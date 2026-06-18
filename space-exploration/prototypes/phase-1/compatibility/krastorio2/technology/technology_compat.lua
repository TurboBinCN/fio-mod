local data_util = require("data_util")

local path = "prototypes/phase-1/compatibility/krastorio2/technology/"


-- The following property of a technology prototypes tells K2 to not run it's
-- science pack coherance checks since SE-K2 has a different paradigm.
--
-- data.raw.technology[<tech-name>].kr_check_science_packs_incompatibilities = false

-- Handle science pack compatibility manually

-- This will exclude most of K2s techs from SEs procedural technology coherance checks
table.insert(se_prodecural_tech_exclusions, "kr-")

-- This will exclude most of SEs tech from the K2 technolody coherance checks
for tech_name, technology in pairs(data.raw.technology) do
  if string.sub(tech_name, 1, 3) == "se-" then
    technology.kr_check_science_packs_incompatibilities = false
  end
end

require(path .. "power")
require(path .. "military")
require(path .. "logistics")
require(path .. "miners")
require(path .. "assemblers")
require(path .. "intermediates")
require(path .. "science")
require(path .. "matter")
require(path .. "resources")

require(path .. "kr-optimization-tech-card")
require(path .. "kr-advanced-pickaxe")
