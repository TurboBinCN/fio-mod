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

-- CUSTOM INPUTS
data:extend({
  {
    type = "custom-input",
    name = "priyutils-switch-blueprint-snap-point",
    key_sequence = "SHIFT + S",
    consuming = "none"
  }
})