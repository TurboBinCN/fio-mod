local data_util = require("data_util")


-- New separate achievements instead of overwriting the vanilla achievement values, just to avoid conflicts.

local speedrun1 = table.deepcopy(data.raw["complete-objective-achievement"]["no-time-for-chitchat"])
speedrun1.localised_name = {"", {"achievement-name." ..speedrun1.name}, " (", {"space-exploration.space-exploration"}, ")"}
speedrun1.name = data_util.mod_prefix..speedrun1.name
speedrun1.localised_description = {"achievement-description.speedrun", "300"}
speedrun1.within = 60 * 60 * 60 * 300 -- 300 hours
speedrun1.objective_condition = "game-finished"

local speedrun2 = table.deepcopy(data.raw["complete-objective-achievement"]["there-is-no-spoon"])
speedrun2.localised_name = {"", {"achievement-name." ..speedrun2.name}, " (", {"space-exploration.space-exploration"}, ")"}
speedrun2.name = data_util.mod_prefix..speedrun2.name
speedrun2.localised_description = {"achievement-description.speedrun", "200"}
speedrun2.within = 60 * 60 * 60 * 200 -- 200 hours
speedrun2.objective_condition = "game-finished"


data:extend{
  speedrun1, speedrun2
}

data.raw["complete-objective-achievement"]["no-time-for-chitchat"] = nil
data.raw["complete-objective-achievement"]["there-is-no-spoon"] = nil
