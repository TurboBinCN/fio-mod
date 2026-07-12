local itemTypes = {
    "ammo",
    "armor",
    "item",
    "rail-planner",
    "gun",
    "capsule",
    "module",
    "tool",
    "repair-tool",
    "item-with-entity-data",
    "blueprint",
    "blueprint-book",
    "deconstruction-planner",
    "upgrade-planner",
    "selection-tool",
    "item-with-label"
}

for _, itemType in pairs(itemTypes) do
    if data.raw[itemType] then
        for name, item in pairs(data.raw[itemType]) do
            if name ~= "priyutils-trashcan" and name ~= "priyutils-advanced-trashcan" then
                data:extend({
                    {
                        type = "recipe",
                        name = "priyutils-trashcan-" .. name,
                        category = "trashcan",
                        icon = item.icon,
                        icon_size = item.icon_size or 64,
                        icons = item.icons,
                        icon_mipmaps = item.icon_mipmaps,
                        enabled = true,
                        hidden = true,
                        ingredients = {
                            { type = "item", name = name, amount = 1 }
                        },
                        results = {},
                        energy_required = 0.1
                    }
                })
            end
        end
    end
end

for name, fluid in pairs(data.raw.fluid) do
    data:extend({
        {
            type = "recipe",
            name = "priyutils-trashcan-fluid-" .. name,
            category = "trashcan-fluid",
            icon = fluid.icon,
            icon_size = fluid.icon_size or 64,
            icons = fluid.icons,
            icon_mipmaps = fluid.icon_mipmaps,
            enabled = true,
            hidden = true,
            ingredients = {
                { type = "fluid", name = name, amount = 100 }
            },
            results = {},
            energy_required = 0.1
        }
    })
end
