-- 机械臂行为修改：当目标已满时，不要让机械臂持有物品

-- 全局数据存储
local storage = {}

-- 初始化全局数据
local function init_storage()
    if not global.priyutils_inserter_behavior then
        global.priyutils_inserter_behavior = {
            inserters = {}
        }
    end
    storage = global.priyutils_inserter_behavior
end

-- 检查机械臂是否持有物品且目标已满
local function check_inserter_behavior()
    -- 获取所有机械臂
    local inserters = game.surfaces
    for _, surface in pairs(inserters) do
        local surface_inserters = surface.find_entities_filtered{type = "inserter"}
        for _, inserter in pairs(surface_inserters) do
            -- 检查机械臂是否持有物品
            if inserter.held_stack and inserter.held_stack.valid and inserter.held_stack.count > 0 then
                -- 获取目标位置的实体
                local target_position = inserter.insert_position
                local target_entities = surface.find_entities_filtered{
                    area = {{target_position.x - 0.5, target_position.y - 0.5}, {target_position.x + 0.5, target_position.y + 0.5}},
                    type = {"container", "logistic-container", "assembling-machine", "furnace", "lab", "reactor", "rocket-silo"}
                }
                
                -- 检查目标是否已满
                local target_full = true
                for _, target in pairs(target_entities) do
                    if target.can_insert(inserter.held_stack) then
                        target_full = false
                        break
                    end
                end
                
                -- 如果目标已满，尝试将物品返回源位置
                if target_full then
                    local source_position = inserter.pickup_position
                    local source_entities = surface.find_entities_filtered{
                        area = {{source_position.x - 0.5, source_position.y - 0.5}, {source_position.x + 0.5, source_position.y + 0.5}},
                        type = {"container", "logistic-container", "assembling-machine", "furnace", "lab", "reactor", "rocket-silo"}
                    }
                    
                    -- 尝试将物品返回源位置
                    for _, source in pairs(source_entities) do
                        if source.can_insert(inserter.held_stack) then
                            local inserted = source.insert(inserter.held_stack)
                            if inserted > 0 then
                                -- 物品成功返回源位置，清空机械臂的持有物品
                                inserter.held_stack.clear()
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 注册事件处理器
script.on_init(init_storage)
script.on_load(init_storage)
script.on_configuration_changed(init_storage)

-- 每帧检查机械臂行为
script.on_nth_tick(60, check_inserter_behavior)
