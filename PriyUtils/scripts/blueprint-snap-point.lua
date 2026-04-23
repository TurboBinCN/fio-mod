local flib_bounding_box = require("__flib__.bounding-box")
local table = require("__flib__.table")

local constants = {
  snap_points = {
    center = { name = "center" },
    top = { name = "top" },
    bottom = { name = "bottom" },
    left = { name = "left" },
    right = { name = "right" }
  }
}

local function get_blueprint(player)
  -- 首先尝试获取玩家的光标物品
  log("PriyUtils: Getting cursor stack for player " .. player.index)
  local cursor_stack = player.cursor_stack
  if not cursor_stack then
    log("PriyUtils: No cursor stack")
    return
  end
  
  log("PriyUtils: Cursor stack exists")
  if not cursor_stack.valid then
    log("PriyUtils: Cursor stack is not valid")
    return
  end
  
  log("PriyUtils: Cursor stack is valid")
  
  -- 检查光标是否有物品
  if cursor_stack.valid_for_read then
    log("PriyUtils: Cursor stack is valid for read")
    log("PriyUtils: Cursor stack name: " .. cursor_stack.name)
    
    -- 检查是否是蓝图或蓝图书
    if cursor_stack.name == "blueprint" then
      log("PriyUtils: Found blueprint")
      -- 检查是否有 get_blueprint_entities 方法
      if cursor_stack.get_blueprint_entities then
        local entities = cursor_stack.get_blueprint_entities()
        if entities and #entities > 0 then
          log("PriyUtils: Blueprint has entities")
          return cursor_stack
        else
          log("PriyUtils: Blueprint has no entities")
          return
        end
      else
        log("PriyUtils: get_blueprint_entities method not found")
        return
      end
    elseif cursor_stack.name == "blueprint-book" then
      log("PriyUtils: Found blueprint book")
      if cursor_stack.active_index then
        log("PriyUtils: Blueprint book has active index: " .. cursor_stack.active_index)
        local inventory = cursor_stack.get_inventory(defines.inventory.item_main)
        if not inventory then
          log("PriyUtils: No inventory in blueprint book")
          return
        end
        log("PriyUtils: Blueprint book has inventory")
        if inventory.is_empty() then
          log("PriyUtils: Blueprint book inventory is empty")
          return
        end
        log("PriyUtils: Blueprint book inventory is not empty")
        if cursor_stack.active_index > #inventory then
          log("PriyUtils: Active index is out of range")
          return
        end
        log("PriyUtils: Active index is in range")
        local blueprint = inventory[cursor_stack.active_index]
        if not blueprint then
          log("PriyUtils: No item at active index")
          return
        end
        log("PriyUtils: Item found at active index")
        log("PriyUtils: Item name: " .. blueprint.name)
        if blueprint.name ~= "blueprint" then
          log("PriyUtils: Item at active index is not a blueprint, name: " .. blueprint.name)
          return
        end
        log("PriyUtils: Item at active index is a blueprint")
        if blueprint.get_blueprint_entities then
          local entities = blueprint.get_blueprint_entities()
          if entities and #entities > 0 then
            log("PriyUtils: Blueprint in blueprint book has entities")
            return blueprint
          else
            log("PriyUtils: Blueprint in blueprint book has no entities")
            return
          end
        else
          log("PriyUtils: get_blueprint_entities method not found for blueprint in blueprint book")
          return
        end
      else
        log("PriyUtils: Blueprint book has no active index")
        return
      end
    else
      log("PriyUtils: Cursor stack is not a blueprint or blueprint book, name: " .. cursor_stack.name)
      return
    end
  else
    log("PriyUtils: Cursor stack is not valid for read, checking if player is holding a blueprint")
    -- 尝试获取玩家手中的蓝图
    local player_blueprint = player.get_blueprint_entities
    if player_blueprint then
      log("PriyUtils: Player is holding a blueprint")
      return player
    else
      log("PriyUtils: Player is not holding a blueprint")
      return
    end
  end
end

local function get_blueprint_bounds(blueprint)
  local entities = blueprint.get_blueprint_entities() or {}
  local tiles = blueprint.get_blueprint_tiles() or {}
  
  if #entities == 0 and #tiles == 0 then
    log("PriyUtils: Blueprint has no entities or tiles")
    return
  end
  
  local first_obj = entities[1] or tiles[1]
  local box = flib_bounding_box.from_position(first_obj.position)
  log("PriyUtils: Initial box: " .. serpent.line(box))
  
  for _, entity in pairs(entities) do
    box = flib_bounding_box.expand_to_contain_position(box, entity.position)
  end
  
  for _, tile in pairs(tiles) do
    box = flib_bounding_box.expand_to_contain_position(box, { x = tile.position.x + 0.5, y = tile.position.y + 0.5 })
  end
  
  log("PriyUtils: Final box: " .. serpent.line(box))
  return box
end

local function get_point_from_bounds(box, snap_point_name)
  if snap_point_name == "center" then
    return {
      x = (box.left_top.x + box.right_bottom.x) / 2,
      y = (box.left_top.y + box.right_bottom.y) / 2
    }
  elseif snap_point_name == "top" then
    return {
      x = (box.left_top.x + box.right_bottom.x) / 2,
      y = box.left_top.y
    }
  elseif snap_point_name == "bottom" then
    return {
      x = (box.left_top.x + box.right_bottom.x) / 2,
      y = box.right_bottom.y
    }
  elseif snap_point_name == "left" then
    return {
      x = box.left_top.x,
      y = (box.left_top.y + box.right_bottom.y) / 2
    }
  elseif snap_point_name == "right" then
    return {
      x = box.right_bottom.x,
      y = (box.left_top.y + box.right_bottom.y) / 2
    }
  else
    return {
      x = (box.left_top.x + box.right_bottom.x) / 2,
      y = (box.left_top.y + box.right_bottom.y) / 2
    }
  end
end

local function switch_snap_point(player)
  log("PriyUtils: switch_snap_point called for player " .. player.index)
  
  local blueprint = get_blueprint(player)
  if not blueprint then
    log("PriyUtils: No blueprint found")
    return
  end
  
  -- 检查 blueprint 是否是玩家对象
  local is_player_blueprint = (blueprint == player)
  log("PriyUtils: Is player blueprint: " .. tostring(is_player_blueprint))
  
  -- 获取原始实体位置
  local original_entities = blueprint.get_blueprint_entities() or {}
  log("PriyUtils: Original entities: " .. serpent.line(original_entities))
  
  local box = get_blueprint_bounds(blueprint)
  if not box then
    log("PriyUtils: No blueprint bounds found")
    return
  end
  
  if not storage.players then
    log("PriyUtils: Initializing storage.players")
    storage.players = {}
  end
  
  local player_table = storage.players[player.index]
  if not player_table then
    log("PriyUtils: Initializing player table for player " .. player.index)
    player_table = {}
    storage.players[player.index] = player_table
  end
  
  if not player_table.blueprint_snap_point then
    log("PriyUtils: Initializing snap point to center")
    player_table.blueprint_snap_point = "center"
  end
  
  -- 循环切换吸附点
  local snap_points = { "center", "top", "bottom", "left", "right" }
  local current_index = table.find(snap_points, player_table.blueprint_snap_point)
  local next_index = current_index % #snap_points + 1
  player_table.blueprint_snap_point = snap_points[next_index]
  log("PriyUtils: Switched snap point to " .. player_table.blueprint_snap_point)
  
  -- 获取新的吸附点位置
  local snap_point = constants.snap_points[player_table.blueprint_snap_point]
  local point = get_point_from_bounds(box, player_table.blueprint_snap_point)
  log("PriyUtils: Snap point position: " .. serpent.line(point))
  
  -- 计算偏移量（从原点到该点的反向量）
  local delta = { x = -point.x, y = -point.y }
  log("PriyUtils: Delta: " .. serpent.line(delta))
  
  -- 移动实体和瓦片
  local entities = blueprint.get_blueprint_entities() or {}
  log("PriyUtils: Number of entities: " .. #entities)
  for _, entity in pairs(entities) do
    log("PriyUtils: Original entity position: " .. serpent.line(entity.position))
    entity.position.x = entity.position.x + delta.x
    entity.position.y = entity.position.y + delta.y
    log("PriyUtils: New entity position: " .. serpent.line(entity.position))
  end
  
  local tiles = blueprint.get_blueprint_tiles() or {}
  log("PriyUtils: Number of tiles: " .. #tiles)
  for _, tile in pairs(tiles) do
    log("PriyUtils: Original tile position: " .. serpent.line(tile.position))
    tile.position.x = tile.position.x + delta.x
    tile.position.y = tile.position.y + delta.y
    log("PriyUtils: New tile position: " .. serpent.line(tile.position))
  end
  
  -- 更新蓝图
  blueprint.set_blueprint_entities(entities)
  blueprint.set_blueprint_tiles(tiles)
  log("PriyUtils: Updated blueprint")
  
  -- 验证更新是否成功
  local updated_entities = blueprint.get_blueprint_entities() or {}
  log("PriyUtils: Updated entities: " .. serpent.line(updated_entities))
  
  -- 显示通知
  player.create_local_flying_text({
    text = { "Blueprint snap point: " .. snap_point.name },
    create_at_cursor = true
  })
  log("PriyUtils: Displayed notification")
end

return switch_snap_point