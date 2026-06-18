local data_util = require("data_util")

require("prototypes/phase-multi/no-recycle")

require("prototypes/phase-2/recipe-update")
require("prototypes/phase-2/generic-recycling")

require("prototypes/phase-2/delivery-cannon-barrels")

require("prototypes/phase-2/modules")

require("prototypes/phase-2/capsules")

require("prototypes/phase-2/interior-divider")

require("prototypes/phase-2/compatibility/general")
require("prototypes/phase-2/compatibility/krastorio2/krastorio2")
require("prototypes/phase-2/compatibility/recycling")
require("prototypes/phase-2/compatibility/quality")

require("prototypes/phase-2/core-fragments")

if mods["DeadlockBlackRubberBelts"] then
  require("prototypes/phase-2/compatibility/deadlock-black-rubber-belts")
end

-- Give burner lamp space collision, because it's a one line fix and getting it done here is easier than trying to get it done in the owner's mod
if data.raw["assembling-machine"]["deadlock-copper-lamp"] then
   data.raw["assembling-machine"]["deadlock-copper-lamp"].se_allow_in_space = true
end

if data.raw["electric-turret"]["laser-turret"] then
  data.raw["electric-turret"]["laser-turret"].prepare_range = data.raw["electric-turret"]["laser-turret"].attack_parameters.range + 8
end

table.insert(data.raw["fluid-turret"]["flamethrower-turret"].attack_parameters.fluids, {type = data_util.mod_prefix.."pyroflux", damage_modifier = 1.2})
