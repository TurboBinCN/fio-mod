local path = "__PriyUtils__/graphics/inserter/"

-- ICONS
data:extend{
    {
        type = "sprite",
        name = "priyutils-inserter-throughput-toggle-button",
        layers = {
            {
                filename = "__base__/graphics/icons/inserter.png",
                size = 64,
                mipmap_count = 4,
                flags = {"gui-icon"},
            },
            {
                filename = path .. "toggle-button.png",
                size = 64,
                flags = {"gui-icon"},
            },
        }
    },
}

-- INPUTS
data:extend{
    {
        type = "custom-input",
        name = "priyutils-inserter-throughput-toggle",
        key_sequence = "LALT + T",
        order = "a",
    },
}

-- TREES
require ("prototypes.trees.trees")

-- BURNER TURBINE
require("prototypes.burner-turbine.burner-turbine")

-- LOADER (only if Krastorio2 is not enabled)
if not mods["Krastorio2"] then
    require("prototypes.buildings.loader")
    require("prototypes.buildings.fast-loader")
    require("prototypes.buildings.express-loader")
    require("prototypes.buildings.advanced-loader")
    require("prototypes.buildings.superior-loader")
    require("prototypes.buildings.technology-loader")
end

-- BELT (only if Krastorio2 is not enabled)
if not mods["Krastorio2"] then
    require("prototypes.buildings.belt-remnants")
    require("prototypes.buildings.advanced-transport-belt")
    require("prototypes.buildings.superior-transport-belt")
    require("prototypes.buildings.advanced-underground-belt")
    require("prototypes.buildings.superior-underground-belt")
    require("prototypes.buildings.advanced-splitter")
    require("prototypes.buildings.superior-splitter")
    require("prototypes.buildings.technology-belt")
end

-- ROBOPORT (only if Krastorio2 is not enabled)
if not mods["Krastorio2"] then
    require("prototypes.roboport.kr-large-roboport")
    require("prototypes.roboport.kr-small-roboport")
    require("prototypes.roboport.items")
    require("prototypes.roboport.recipes")
    require("prototypes.roboport.remnants")
    require("prototypes.roboport.technology")
end

-- TRASHCAN
require("prototypes.trashcan.trashcan")
require("prototypes.trashcan.item")
require("prototypes.trashcan.recipe")
require("prototypes.trashcan.technology")
