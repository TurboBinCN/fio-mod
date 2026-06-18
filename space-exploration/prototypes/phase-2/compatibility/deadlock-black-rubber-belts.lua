local data_util = require("data_util")
local funcs = require("__DeadlockBlackRubberBelts__/code/functions")

-- Update space belt item icon
local space_belt_item_name = data_util.mod_prefix .. "space-transport-belt"

funcs.replace_item_icon(space_belt_item_name, "rubber-belt-steel")
funcs.add_mask_to_item_icon(space_belt_item_name, "rubber-belt-mask", {1, 1, 1, 0.2})
funcs.copy_item_icons_to_entity("transport-belt", space_belt_item_name)

-- Update space belt entities' animation sets
local space_belt = data.raw["transport-belt"][data_util.mod_prefix .. "space-transport-belt"]
local space_ug_belt = data.raw["underground-belt"][data_util.mod_prefix .. "space-underground-belt"]
local space_splitter = data.raw["splitter"][data_util.mod_prefix .. "space-splitter"]

space_belt.belt_animation_set.animation_set = funcs.get_belt_animation_set({1, 1, 1, 0.2}, "steel")
space_ug_belt.belt_animation_set.animation_set = funcs.get_belt_animation_set({1, 1, 1, 0.2}, "steel")
space_splitter.belt_animation_set.animation_set = funcs.get_belt_animation_set({1, 1, 1, 0.2}, "steel")
