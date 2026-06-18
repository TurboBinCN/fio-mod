-- Dedicated solely to modifying Krastorio 2 item stack sizes to match with the expected logisitcal challenges presented by SE
local item = data.raw.item

-- Set the K2 global flag to false to stop it making huge stack sizes automatically
kr_adjust_stack_sizes = false

-- Logistics tab items
if settings.startup["kr-containers"].value then
  item["kr-strongbox"].stack_size = 35
  item["kr-passive-provider-strongbox"].stack_size = 35
  item["kr-active-provider-strongbox"].stack_size = 35
  item["kr-storage-strongbox"].stack_size = 35
  item["kr-buffer-strongbox"].stack_size = 35
  item["kr-requester-strongbox"].stack_size = 35

  item["kr-warehouse"].stack_size = 20
  item["kr-passive-provider-warehouse"].stack_size = 20
  item["kr-active-provider-warehouse"].stack_size = 20
  item["kr-storage-warehouse"].stack_size = 20
  item["kr-buffer-warehouse"].stack_size = 20
  item["kr-requester-warehouse"].stack_size = 20
end

item["kr-big-storage-tank"].stack_size = 40
item["kr-huge-storage-tank"].stack_size = 20

item["kr-small-roboport"].stack_size = 25
item["kr-big-roboport"].stack_size = 10

item["kr-black-reinforced-plate"].stack_size = 100
item["kr-white-reinforced-plate"].stack_size = 100

-- Production tab items
item["kr-advanced-steam-turbine"].stack_size = 10
item["kr-advanced-solar-panel"].stack_size = 20
item["kr-advanced-furnace"].stack_size = 20
item["kr-greenhouse"].stack_size = 25
item["kr-bio-lab"].stack_size = 25
item["kr-crusher"].stack_size = 25
item["kr-electrolysis-plant"].stack_size = 25
item["kr-filtration-plant"].stack_size = 25
item["kr-atmospheric-condenser"].stack_size = 25
item["kr-quantum-computer"].stack_size = 25

item["kr-matter-associator"].stack_size = 10
item["kr-stabilizer-charging-station"].stack_size = 10

item["kr-advanced-lab"].stack_size = 10
item["kr-singularity-lab"].stack_size = 1

-- Resources tab items
item["kr-imersite"].stack_size = 50
item["kr-rare-metal-ore"].stack_size = 50
item["kr-coke"].stack_size = 50
item["kr-fertilizer"].stack_size = 50
item["kr-biomass"].stack_size = 100
item["kr-quartz"].stack_size = 50
item["kr-silicon"].stack_size = 50
item["kr-rare-metals"].stack_size = 100
item["kr-imersite-powder"].stack_size = 100
item["kr-imersium-plate"].stack_size = 100
item["kr-enriched-iron"].stack_size = 50
item["kr-enriched-copper"].stack_size = 50
item["kr-enriched-rare-metals"].stack_size = 50
item["kr-lithium-chloride"].stack_size = 50
item["kr-lithium"].stack_size = 50
item["kr-lithium-sulfur-battery"].stack_size = 50
item["kr-tritium"].stack_size = 50
item["kr-fuel"].stack_size = 100
item["kr-biofuel"].stack_size = 100
item["kr-advanced-fuel"].stack_size = 100
item["uranium-fuel-cell"].stack_size = 10

-- Manufacturing tab items
item["kr-matter-cube"].stack_size = 25
item["kr-iron-beam"].stack_size = 100
item["kr-steel-beam"].stack_size = 100
item["kr-imersium-beam"].stack_size = 100
item["kr-steel-gear-wheel"].stack_size = 100
item["kr-imersium-gear-wheel"].stack_size = 100
item["kr-inserter-parts"].stack_size = 100
item["kr-electronic-components"].stack_size = 100
item["kr-automation-core"].stack_size = 50
item["kr-ai-core"].stack_size = 50
item["kr-charged-matter-stabilizer"].stack_size = 20

-- Science tab items
item["kr-biter-research-data"].stack_size = 50
item["kr-space-research-data"].stack_size = 50
data.raw.tool["kr-optimization-tech-card"].stack_size = 200

-- Equipment & Combat tab items

data.raw.ammo["artillery-shell"].stack_size = 25 -- This is the only item we increase the stack size of, due to the ridiculousness of a stack size of 1 for ammo.

item["fission-reactor-equipment"].stack_size = 20
item["kr-big-solar-panel-equipment"].stack_size = 20
item["kr-superior-solar-panel-equipment"].stack_size = 20
item["kr-big-superior-solar-panel-equipment"].stack_size = 20
item["kr-laser-artillery-turret"].stack_size = 10
item["kr-railgun-turret"].stack_size = 10
item["kr-rocket-turret"].stack_size = 10
