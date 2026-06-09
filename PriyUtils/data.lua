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

-- LOADER
require("prototypes.buildings.loader")
require("prototypes.buildings.fast-loader")
require("prototypes.buildings.express-loader")
require("prototypes.buildings.advanced-loader")
require("prototypes.buildings.superior-loader")
require("prototypes.buildings.technology-loader")
