-- 仓库定义
local sounds = require("__base__/prototypes/entity/sounds")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")

-- 1x3 仓库的物品槽数量
local tiny_warehouse_slots = 80
-- 1x2 仓库的物品槽数量
local small_warehouse_slots = 60
-- 2x1 仓库的物品槽数量
local balanced_tiny_warehouse_slots = 60
-- 2x2 仓库的物品槽数量
local balanced_small_warehouse_slots = 80
-- 4x1 仓库的物品槽数量
local long_tiny_warehouse_slots = 100
-- 4x2 仓库的物品槽数量
local long_small_warehouse_slots = 150

-- 图标缩放
local tiny_warehouse_icon_spec = {scale = 0.7, scale_for_many = 1, shift = {0, -1.1}}
-- 1x2 仓库的图标缩放
local small_warehouse_icon_spec = {scale = 0.7, scale_for_many = 1, shift = {0, -0.6}}
-- 2x1 仓库的图标缩放
local medium_warehouse_icon_spec = {scale = 0.7, scale_for_many = 1, shift = {0, 0}}
-- 2x2 仓库的图标缩放
local large_warehouse_icon_spec = {scale = 0.7, scale_for_many = 1, shift = {0, 0}}
-- 4x1 仓库的图标缩放
local long_tiny_warehouse_icon_spec = {scale = 0.7, scale_for_many = 1, shift = {0, 0}}
-- 4x2 仓库的图标缩放
local long_small_warehouse_icon_spec = {scale = 0.7, scale_for_many = 1, shift = {0, -0.5}}

-- 使用 Factorio 内置的 chest 电路连接器定义

-- 定义 1x3 仓库
data:extend({
	{
		type = "container",
		name = "warehouse-basic-tiny",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-basic-tiny-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 1.5, result = "warehouse-basic-tiny"},
		max_health = 300,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		resistances =
		{
			{
				type = "fire",
				percent = 90
			},
			{
			  type = "impact",
				percent = 60
			}
		},
		-- 1x3 大小的碰撞盒和选择盒
		collision_box = {{-0.4, -1.4}, {0.4, 1.4}},
		selection_box = { { -0.4, -1.4}, { 0.4, 1.4 } },
		landing_location_offset = {0.0, 0.0},
		damaged_trigger_effect = hit_effects.entity(),
		fast_replaceable_group = "container",
		inventory_size = tiny_warehouse_slots,
		impact_category = "metal",
		icon_draw_specification = tiny_warehouse_icon_spec,
		picture = {
			layers = {
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-basic-tiny.png",
					width = 62,
					height = 216,
					scale = 0.5, -- 缩小到 1x3 大小
					shift = {0, 0},
					direction_count = 4, -- 支持 4 个方向
				},
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-basic-tiny-shadow.png",
					width = 104,
					height = 116,
					shift = {0.5, 0},
					scale = 0.5, -- 缩小到 1x3 大小
					draw_as_shadow = true,
				},
			},
		},
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		circuit_connector = circuit_connector_definitions["chest"]
	},
	{
		type = "item",
		name = "warehouse-basic-tiny",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-basic-tiny-icon.png",
		icon_size = 64,
		inventory_move_sound = sounds.metal_chest_inventory_move,
		pick_sound = sounds.metal_chest_inventory_pickup,
		drop_sound = sounds.metal_chest_inventory_move,
		subgroup = "storage",
		order = "a[items]-c[warehouse]",
		place_result = "warehouse-basic-tiny",
		stack_size = 50,
	},
	{
		type = "recipe",
		name = "warehouse-basic-tiny",
		enabled = true, -- 不需要科技解锁
		ingredients =
		{
			{ type = "item", name = "stone-brick", amount = 50 },
			{ type = "item", name = "wood",        amount = 50 },
		},
		energy_required = 5,
		results = {{type="item", name="warehouse-basic-tiny", amount = 1}},
	},
	-- 1x2 大小的仓库
	{
		type = "container",
		name = "warehouse-basic-small",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-basic-tiny-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 1.0, result = "warehouse-basic-small"},
		max_health = 250,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		resistances =
		{
			{
				type = "fire",
				percent = 90
			},
			{
			  type = "impact",
				percent = 60
			}
		},
		-- 1x2 大小的碰撞盒和选择盒
		collision_box = {{-0.4, -0.9}, {0.4, 0.9}},
		selection_box = {{-0.5, -0.9}, {0.5, 0.9}},
		landing_location_offset = {0.0, 0.0},
		damaged_trigger_effect = hit_effects.entity(),
		fast_replaceable_group = "container",
		inventory_size = small_warehouse_slots,
		impact_category = "metal",
		icon_draw_specification = small_warehouse_icon_spec,
		picture = {
			layers = {
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-basic-small.png",
					width = 62,
					height = 114,
					scale = 0.5, -- 缩小到 1x2 大小的仓库定义
					shift = {0, 0},
					direction_count = 4, -- 支持 4 个方向
				},
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-basic-small-shadow.png",
					width = 104,
					height = 116,
					shift = {0.5, 0},
					scale = 0.5, -- 缩小到 1x2 大小的仓库定义
					draw_as_shadow = true,
				},
			},
		},
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		circuit_connector = circuit_connector_definitions["chest"]
	},
	{
		type = "item",
		name = "warehouse-basic-small",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-basic-tiny-icon.png",
		icon_size = 64,
		inventory_move_sound = sounds.metal_chest_inventory_move,
		pick_sound = sounds.metal_chest_inventory_pickup,
		drop_sound = sounds.metal_chest_inventory_move,
		subgroup = "storage",
		order = "a[items]-c[warehouse]-small",
		place_result = "warehouse-basic-small",
		stack_size = 50,
	},
	{
		type = "recipe",
		name = "warehouse-basic-small",
		enabled = true, -- 不需要科技解锁
		ingredients =
		{
			{ type = "item", name = "stone-brick", amount = 30 },
			{ type = "item", name = "wood",        amount = 30 },
		},
		energy_required = 3,
		results = {{type="item", name="warehouse-basic-small", amount = 1}},
	},
	-- 2x1 大小的仓库
	{
		type = "container",
		name = "warehouse-balanced-tiny",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 1.5, result = "warehouse-balanced-tiny"},
		max_health = 350,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		resistances =
		{
			{
				type = "fire",
				percent = 90
			},
			{
			  type = "impact",
				percent = 60
			}
		},
		-- 2x1 大小的碰撞盒和选择盒
		collision_box = {{-0.9, -0.4}, {0.9, 0.4}},
		selection_box = {{-0.9, -0.5}, {0.9, 0.5}},
		landing_location_offset = {0.0, 0.0},
		damaged_trigger_effect = hit_effects.entity(),
		fast_replaceable_group = "container",
		inventory_size = balanced_tiny_warehouse_slots,
		impact_category = "metal",
		icon_draw_specification = medium_warehouse_icon_spec,
		picture = {
			layers = {
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-tiny.png",
					width = 124,
					height = 72,
					scale = 0.5, -- 缩小到 2x1 大小的仓库定义
					shift = {0, 0},
				},
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-tiny-shadow.png",
					width = 104,
					height = 40,
					shift = {0.5, 0},
					scale = 0.5, -- 缩小到 2x1 大小的仓库定义
					draw_as_shadow = true,
				},
			},
		},
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		circuit_connector = circuit_connector_definitions["chest"]
	},
	{
		type = "item",
		name = "warehouse-balanced-tiny",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-icon.png",
		icon_size = 64,
		inventory_move_sound = sounds.metal_chest_inventory_move,
		pick_sound = sounds.metal_chest_inventory_pickup,
		drop_sound = sounds.metal_chest_inventory_move,
		subgroup = "storage",
		order = "a[items]-c[warehouse]-tiny",
		place_result = "warehouse-balanced-tiny",
		stack_size = 50,
	},
	{
		type = "recipe",
		name = "warehouse-balanced-tiny",
		enabled = true, -- 不需要科技解锁
		ingredients =
		{
			{ type = "item", name = "stone-brick", amount = 30 },
			{ type = "item", name = "wood",        amount = 30 },
		},
		energy_required = 3,
		results = {{type="item", name="warehouse-balanced-tiny", amount = 1}},
	},
	-- 2x2 大小的仓库
	{
		type = "container",
		name = "warehouse-balanced-small",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 2.0, result = "warehouse-balanced-small"},
		max_health = 400,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		resistances =
		{
			{
				type = "fire",
				percent = 90
			},
			{
			  type = "impact",
				percent = 60
			}
		},
		-- 2x2 大小的碰撞盒和选择盒
		collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
		selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
		landing_location_offset = {0.0, 0.0},
		damaged_trigger_effect = hit_effects.entity(),
		fast_replaceable_group = "container",
		inventory_size = balanced_small_warehouse_slots,
		impact_category = "metal",
		icon_draw_specification = large_warehouse_icon_spec,
		picture = {
			layers = {
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-small.png",
					width = 144,
					height = 144,
					scale = 0.4, -- 缩小到 2x2 大小的仓库定义
					shift = {0, 0},
				},
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-small-shadow.png",
					width = 104,
					height = 40,
					shift = {0.5, 0},
					scale = 0.5, -- 缩小到 2x2 大小的仓库定义
					draw_as_shadow = true,
				},
			},
		},
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		circuit_connector = circuit_connector_definitions["chest"]
	},
	{
		type = "item",
		name = "warehouse-balanced-small",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-icon.png",
		icon_size = 64,
		inventory_move_sound = sounds.metal_chest_inventory_move,
		pick_sound = sounds.metal_chest_inventory_pickup,
		drop_sound = sounds.metal_chest_inventory_move,
		subgroup = "storage",
		order = "a[items]-c[warehouse]-small",
		place_result = "warehouse-balanced-small",
		stack_size = 50,
	},
	{
		type = "recipe",
		name = "warehouse-balanced-small",
		enabled = true, -- 不需要科技解锁
		ingredients =
		{
			{ type = "item", name = "stone-brick", amount = 50 },
			{ type = "item", name = "wood",        amount = 50 },
		},
		energy_required = 5,
		results = {{type="item", name="warehouse-balanced-small", amount = 1}},
	},
	-- 4x1 大小的仓库
	{
		type = "container",
		name = "warehouse-balanced-4x1",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = { mining_time = 2.0, result = "warehouse-balanced-4x1" },
		max_health = 350,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		resistances =
		{
			{
				type = "fire",
				percent = 90
			},
			{
			  type = "impact",
				percent = 60
			}
		},
		-- 4x1 大小的碰撞盒和选择盒
		collision_box = {{-1.9, -0.4}, {1.9, 0.4}},
		selection_box = {{-1.9, -0.5}, {1.9, 0.5}},
		landing_location_offset = {0.0, 0.0},
		damaged_trigger_effect = hit_effects.entity(),
		fast_replaceable_group = "container",
		inventory_size = long_tiny_warehouse_slots,
		impact_category = "metal",
		icon_draw_specification = long_tiny_warehouse_icon_spec,
		picture = {
			layers = {
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-1x4.png",
					width = 248,
					height = 72,
					scale = 0.5, -- 缩小到 4x1 大小
					shift = {0, 0},
				},
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-shadow.png",
					width = 104,
					height = 120,
					shift = {0.5, 0},
					scale = 0.5, -- 缩小到 4x1 大小
					draw_as_shadow = true,
				},
			},
		},
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		circuit_connector = circuit_connector_definitions["chest"]
	},
	{
		type = "item",
		name = "warehouse-balanced-4x1",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-icon.png",
		icon_size = 64,
		inventory_move_sound = sounds.metal_chest_inventory_move,
		pick_sound = sounds.metal_chest_inventory_pickup,
		drop_sound = sounds.metal_chest_inventory_move,
		subgroup = "storage",
		order = "a[items]-c[warehouse]-long-tiny",
		place_result = "warehouse-balanced-4x1",
		stack_size = 50,
	},
	{
		type = "recipe",
		name = "warehouse-balanced-4x1",
		enabled = true, -- 不需要科技解锁
		ingredients =
		{
			{ type = "item", name = "stone-brick", amount = 60 },
			{ type = "item", name = "wood",        amount = 60 },
		},
		energy_required = 6,
		results = { { type = "item", name = "warehouse-balanced-4x1", amount = 1 } },
	},
	-- 4x2 大小的仓库
	{
		type = "container",
		name = "warehouse-balanced-4x2",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-icon.png",
		icon_size = 64,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 3.0, result = "warehouse-balanced-4x2"},
		max_health = 450,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		resistances =
		{
			{
				type = "fire",
				percent = 90
			},
			{
			  type = "impact",
				percent = 60
			}
		},
		-- 4x2 大小的碰撞盒和选择盒
		collision_box = {{-1.9, -0.9}, {1.9, 0.9}},
		selection_box = {{-1.9, -0.9}, {1.9, 0.9}},
		landing_location_offset = {0.0, 0.0},
		damaged_trigger_effect = hit_effects.entity(),
		fast_replaceable_group = "container",
		inventory_size = long_small_warehouse_slots,
		impact_category = "metal",
		icon_draw_specification = long_small_warehouse_icon_spec,
		picture = {
			layers = {
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-2x4.png",
					width = 288,
					height = 144,
					scale = 0.4, -- 缩小到 4x2 大小
					shift = {0, 0},
				},
				{
					filename = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-shadow.png",
					width = 104,
					height = 120,
					shift = {0.5, 0},
					scale = 0.4, -- 缩小到 4x2 大小
					draw_as_shadow = true,
				},
			},
		},
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		circuit_connector = circuit_connector_definitions["chest"]
	},
	{
		type = "item",
		name = "warehouse-balanced-4x2",
		icon = "__PriyUtils__/graphics/entity/warehouse/warehouse-balanced-icon.png",
		icon_size = 64,
		inventory_move_sound = sounds.metal_chest_inventory_move,
		pick_sound = sounds.metal_chest_inventory_pickup,
		drop_sound = sounds.metal_chest_inventory_move,
		subgroup = "storage",
		order = "a[items]-c[warehouse]-long-small",
		place_result = "warehouse-balanced-4x2",
		stack_size = 50,
	},
	{
		type = "recipe",
		name = "warehouse-balanced-4x2",
		enabled = true, -- 不需要科技解锁
		ingredients =
		{
			{ type = "item", name = "stone-brick", amount = 100 },
			{ type = "item", name = "wood",        amount = 100 },
		},
		energy_required = 10,
		results = {{type="item", name="warehouse-balanced-4x2", amount = 1}},
	},
})
