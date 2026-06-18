local data_util = require("data_util")

--Add various K2 products to the delivery cannon.
se_delivery_cannon_recipes = se_delivery_cannon_recipes or {}

local function cannonize(recipe_name, item_name)
  se_delivery_cannon_recipes[recipe_name] = {name=item_name}
end

cannonize("kr-imersite"            ,"kr-imersite")
cannonize("kr-imersite-powder"     ,"kr-imersite-powder")
cannonize("fine-imersite-powder"   ,"se-kr-fine-imersite-powder")
cannonize("kr-imersium-plate"      ,"kr-imersium-plate")
cannonize("kr-imersite-crystal"    ,"kr-imersite-crystal")
cannonize("kr-coke"                ,"kr-coke")
cannonize("kr-quartz"              ,"kr-quartz")
cannonize("kr-silicon"             ,"kr-silicon")
cannonize("kr-enriched-iron"       ,"kr-enriched-iron")
cannonize("kr-enriched-copper"     ,"kr-enriched-copper")
cannonize("kr-enriched-rare-metals","kr-enriched-rare-metals")
cannonize("kr-rare-metal-ore"      ,"kr-rare-metal-ore")
cannonize("kr-rare-metals"         ,"kr-rare-metals")
cannonize("kr-lithium"             ,"kr-lithium")
cannonize("kr-lithium-chloride"    ,"kr-lithium-chloride")
cannonize("kr-tritium"             ,"kr-tritium")
cannonize("kr-fuel"                ,"kr-fuel")
cannonize("kr-biofuel"             ,"kr-biofuel")
cannonize("kr-advanced-fuel"       ,"kr-advanced-fuel")
cannonize("kr-fertilizer"          ,"kr-fertilizer")
