local item_names = {}

local sand_name = "sand"
local glass_name = "glass"
local add_sand = true
local add_glass = true

local sand_names_to_check = {
  "sand", -- AAI Industry
  "kr-sand", -- Krastorio 2
}

local glass_names_to_check = {
  "glass", -- AAI Industry
  "kr-glass", -- Krastorio 2
}

for _, item_name in pairs(sand_names_to_check) do
  if data.raw.item[item_name] then
    add_sand = false
    sand_name = item_name
    break
  end
end

for _, item_name in pairs(glass_names_to_check) do
  if data.raw.item[item_name] then
    add_glass = false
    glass_name = item_name
    break
  end
end

if add_sand then
  data:extend({
    {
      icon = "__space-exploration-graphics__/graphics/icons/sand.png",
      icon_size = 64,
      name = sand_name,
      order = "a[wood]-b-b",
      stack_size = 200,
      subgroup = "stone",
      type = "item"
    }
  })
end

if add_glass then
  data:extend({
    {
      icon = "__space-exploration-graphics__/graphics/icons/glass.png",
      icon_size = 64,
      name = glass_name,
      order = "a[wood]-b-c",
      stack_size = 100,
      subgroup = "stone",
      type = "item"
    }
  })
end

function item_names.get_sand_name()
  return sand_name
end

function item_names.get_glass_name()
  return glass_name
end

return item_names
