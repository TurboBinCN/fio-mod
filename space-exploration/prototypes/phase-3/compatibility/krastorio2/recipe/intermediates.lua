local data_util = require("data_util")

data_util.remove_recipe_from_effects(data.raw.technology["se-pulveriser"].effects, "se-pulverised-sand")
data_util.delete_recipe("se-pulverised-sand")
data_util.delete_recipe("glass-from-sand")

-- While not necessary when Peaceful Mode is off, having this alternative means deathworlds are perhaps a little easier to start with
-- military science not requring biters to be defeated.
local bio_lab_alt = table.deepcopy(data.raw.recipe["kr-bio-lab"])
bio_lab_alt.name = "kr-bio-lab-alt"
bio_lab_alt.localised_name = {"entity-name.kr-bio-lab"}
bio_lab_alt.category = "crafting-with-fluid"
data:extend({bio_lab_alt})
data_util.replace_or_add_ingredient("kr-bio-lab-alt", "kr-biomass", "petroleum-gas", 2000, true)
data_util.replace_or_add_ingredient("kr-bio-lab-alt", nil, "kr-oxygen-barrel", 40)
data_util.replace_or_add_result("kr-bio-lab-alt",nil,"barrel",40)
for _, result in pairs(data.raw.recipe["kr-bio-lab-alt"] and data.raw.recipe["kr-bio-lab-alt"].results or {}) do
  if result.name == "barrel" then
    result.ignored_by_stats = result.amount
  end
end
data_util.set_craft_time("kr-bio-lab-alt", 60)
data_util.tech_lock_recipes("kr-bio-processing",{"kr-bio-lab-alt"})
if data.raw.recipe["kr-bio-lab-alt"].ingredients then
  data.raw.recipe["kr-bio-lab-alt"].main_product = "kr-bio-lab"
end
