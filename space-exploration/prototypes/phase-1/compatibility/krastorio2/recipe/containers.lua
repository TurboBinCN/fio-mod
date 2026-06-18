local data_util = require("data_util")

if settings.startup["kr-containers"].value then
  -- Harmonize AAI Containers & Warehouses and Krastorio 2 versions
  -- Adjust recipes of all of them to be the same so that one isn't cheaper than the other, but keep them existing in case of aestheric choices by the player.
  data_util.replace_or_add_ingredient("kr-warehouse", "kr-strongbox", "concrete", 100)
  data_util.replace_or_add_ingredient("kr-warehouse", nil, "steel-plate", 100)
  data_util.replace_or_add_ingredient("kr-warehouse", "kr-steel-beam", "kr-steel-beam", 50)

  data_util.replace_or_add_ingredient("kr-passive-provider-warehouse", "advanced-circuit", "advanced-circuit", 20)
  data_util.replace_or_add_ingredient("kr-passive-provider-warehouse", nil, "electronic-circuit", 20)
  data_util.replace_or_add_ingredient("kr-active-provider-warehouse", "advanced-circuit", "advanced-circuit", 20)
  data_util.replace_or_add_ingredient("kr-active-provider-warehouse", nil, "electronic-circuit", 20)
  data_util.replace_or_add_ingredient("kr-storage-warehouse", "advanced-circuit", "advanced-circuit", 20)
  data_util.replace_or_add_ingredient("kr-storage-warehouse", nil, "electronic-circuit", 20)
  data_util.replace_or_add_ingredient("kr-buffer-warehouse", "advanced-circuit", "advanced-circuit", 20)
  data_util.replace_or_add_ingredient("kr-buffer-warehouse", nil, "electronic-circuit", 20)
  data_util.replace_or_add_ingredient("kr-requester-warehouse", "advanced-circuit", "advanced-circuit", 20)
  data_util.replace_or_add_ingredient("kr-requester-warehouse", nil, "electronic-circuit", 20)

  data_util.replace_or_add_ingredient("kr-strongbox", "steel-chest", "steel-plate", 15)
  data_util.replace_or_add_ingredient("kr-strongbox", "kr-steel-beam", "kr-steel-beam", 5)

  data_util.replace_or_add_ingredient("kr-passive-provider-strongbox", "advanced-circuit", "advanced-circuit", 4)
  data_util.replace_or_add_ingredient("kr-passive-provider-strongbox", nil, "electronic-circuit", 4)
  data_util.replace_or_add_ingredient("kr-active-provider-strongbox", "advanced-circuit", "advanced-circuit", 4)
  data_util.replace_or_add_ingredient("kr-active-provider-strongbox", nil, "electronic-circuit", 4)
  data_util.replace_or_add_ingredient("kr-storage-strongbox", "advanced-circuit", "advanced-circuit", 4)
  data_util.replace_or_add_ingredient("kr-storage-strongbox", nil, "electronic-circuit", 4)
  data_util.replace_or_add_ingredient("kr-buffer-strongbox", "advanced-circuit", "advanced-circuit", 4)
  data_util.replace_or_add_ingredient("kr-buffer-strongbox", nil, "electronic-circuit", 4)
  data_util.replace_or_add_ingredient("kr-requester-strongbox", "advanced-circuit", "advanced-circuit", 4)
  data_util.replace_or_add_ingredient("kr-requester-strongbox", nil, "electronic-circuit", 4)
end

-- Adjust cost of AAI Containers even if K2s Containers are disabled.
data_util.replace_or_add_ingredient("aai-strongbox", "steel-plate", "steel-plate", 15)
data_util.replace_or_add_ingredient("aai-strongbox", nil, "kr-steel-beam", 5)

data_util.replace_or_add_ingredient("aai-storehouse", "steel-plate", "steel-plate", 50)
data_util.replace_or_add_ingredient("aai-storehouse", nil, "kr-steel-beam", 25)

data_util.replace_or_add_ingredient("aai-warehouse", "steel-plate", "steel-plate", 100)
data_util.replace_or_add_ingredient("aai-warehouse", nil, "kr-steel-beam", 50)
