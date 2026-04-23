-- 电池充电控制脚本

-- 全局数据初始化
local function init_global()
  if global and not global.battery_charging then
    global.battery_charging = {}
  end
end

-- 检查实体是否在 roboport 的充电范围内并获取充电功率
local function get_charge_power(entity)
  if not entity or not entity.valid then return 0 end
  
  local surface = entity.surface
  local position = entity.position
  
  -- 减少搜索区域的大小，从 25x25 减少到 20x20，减少遍历的格子数
  local search_radius = 10
  local roboports = surface.find_entities_filtered({
    type = "roboport",
    area = {
      {position.x - search_radius, position.y - search_radius},
      {position.x + search_radius, position.y + search_radius}
    }
  })
  
  -- 限制处理的 roboport 数量，最多处理 5 个
  local max_roboports = 5
  local count = 0
  
  for _, roboport in pairs(roboports) do
    if count >= max_roboports then break end
    
    if roboport.valid and roboport.energy > 0 then
      -- 计算距离
      local dx = position.x - roboport.position.x
      local dy = position.y - roboport.position.y
      local distance_squared = dx * dx + dy * dy
      
      if distance_squared <= 625 then -- 25^2，roboport 的充电半径
        -- 每个 roboport 提供 500kW 的充电功率
        return 500000
      end
    end
    
    count = count + 1
  end
  
  return 0
end

-- 为 spidertron 中的电池组充电
local function charge_spidertron_batteries()
  if not game then return end
  
  -- 限制每次处理的 spidertron 数量，避免卡顿
  local max_spidertrons_per_tick = 5
  local processed_count = 0
  
  for _, surface in pairs(game.surfaces) do
    local spidertrons = surface.find_entities_filtered({type = "spider-vehicle"})
    
    for _, spidertron in pairs(spidertrons) do
      -- 达到处理数量限制，退出循环
      if processed_count >= max_spidertrons_per_tick then
        break
      end
      
      if spidertron.valid then
        local equipment_grid = spidertron.grid
        if equipment_grid then
          local batteries = equipment_grid.equipment
          
          -- 检查电池是否已经满电
          local is_full = true
          for _, equipment in pairs(batteries) do
            if equipment.name == "battery-mk2-equipment" then
              local energy_source = nil
              local success = pcall(function()
                energy_source = equipment.energy_source
              end)
              
              if success and energy_source then
                local energy = nil
                local buffer_capacity = nil
                local success_energy = pcall(function()
                  energy = energy_source.energy
                  buffer_capacity = energy_source.buffer_capacity
                end)
                
                if success_energy and energy and buffer_capacity and energy < buffer_capacity then
                  is_full = false
                  break -- 只要有一个电池未满，就需要充电
                end
              end
            end
          end
          
          -- 只有当电池未满时，才检查 roboport 并充电
          if not is_full then
            local charging_power = get_charge_power(spidertron)
            if charging_power > 0 then -- 只有在充电范围内才充电
              local total_charging_power = math.min(charging_power, 5000000) -- 最大充电功率 5MW
            
              for _, equipment in pairs(batteries) do
                if equipment.name == "battery-mk2-equipment" then
                  local energy_source = nil
                  local success = pcall(function()
                    energy_source = equipment.energy_source
                  end)
                  
                  if success and energy_source then
                    local energy = nil
                    local buffer_capacity = nil
                    local success_energy = pcall(function()
                      energy = energy_source.energy
                      buffer_capacity = energy_source.buffer_capacity
                    end)
                    
                    if success_energy and energy and buffer_capacity and energy < buffer_capacity then
                      local charging_power = math.min(total_charging_power, buffer_capacity - energy)
                      energy_source.energy = energy + charging_power
                      total_charging_power = total_charging_power - charging_power
                    end
                  end
                end
              end
            end
          end
        end
      end
      
      processed_count = processed_count + 1
    end
    
    -- 达到处理数量限制，退出表面循环
    if processed_count >= max_spidertrons_per_tick then
      break
    end
  end
end

-- 游戏加载时初始化
script.on_init(function()
  init_global()
end)

-- 游戏配置变化时初始化
script.on_configuration_changed(function()
  init_global()
end)

-- 每帧执行充电逻辑
script.on_nth_tick(180, function() -- 每3秒执行一次，减少性能消耗
  charge_spidertron_batteries()
end)
