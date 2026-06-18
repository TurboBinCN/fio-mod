local data_util = require("data_util")

-- N.B. The DSS and Matter Science Packs both require 2 fluid inputs, base K2 prototypes for the Server buildings only has 1 input, but can support 2
local fluid_box_1 = table.deepcopy(data.raw["assembling-machine"]["kr-research-server"].fluid_boxes[1])
local fluid_box_2 = table.deepcopy(data.raw["assembling-machine"]["kr-research-server"].fluid_boxes[2])
fluid_box_1.pipe_connections = { { flow_direction = "input", position = { -1, 0 }, direction = defines.direction.west } }
fluid_box_2.pipe_connections = { { flow_direction = "output", position = { 1, 0 }, direction = defines.direction.east } }

table.insert(data.raw["assembling-machine"]["kr-research-server"].fluid_boxes, fluid_box_1)
table.insert(data.raw["assembling-machine"]["kr-research-server"].fluid_boxes, fluid_box_2)

local fluid_box_3 = table.deepcopy(data.raw["assembling-machine"]["kr-quantum-computer"].fluid_boxes[1])
local fluid_box_4 = table.deepcopy(data.raw["assembling-machine"]["kr-quantum-computer"].fluid_boxes[2])
fluid_box_3.pipe_connections = { { flow_direction = "input", position = { -2.5, 0.5 }, direction = defines.direction.west } }
fluid_box_4.pipe_connections = { { flow_direction = "output", position = { 2.5, -0.5 }, direction = defines.direction.east } }

table.insert(data.raw["assembling-machine"]["kr-quantum-computer"].fluid_boxes, fluid_box_3)
table.insert(data.raw["assembling-machine"]["kr-quantum-computer"].fluid_boxes, fluid_box_4)

-- Research Server
local exclude_categories = {"research-data","t2-tech-cards","t3-tech-cards"}
local research_server_categories = {"catalogue-creation-1","science-pack-creation-1"}
local quantum_computer_categories = {"catalogue-creation-1","catalogue-creation-2","science-pack-creation-1","science-pack-creation-2"}

for _, category in pairs(data.raw["assembling-machine"]["kr-research-server"].crafting_categories) do
  if not data_util.table_contains(exclude_categories,category) then
    table.insert(research_server_categories, category)
  end
end
data.raw["assembling-machine"]["kr-research-server"].crafting_categories = research_server_categories

for _, category in pairs(data.raw["assembling-machine"]["kr-quantum-computer"].crafting_categories) do
  if not data_util.table_contains(exclude_categories,category) then
    table.insert(quantum_computer_categories, category)
  end
end
data.raw["assembling-machine"]["kr-quantum-computer"].crafting_categories = quantum_computer_categories
