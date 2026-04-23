function plant_trees_at_position(surface, position, item_name)
  if item_name == "priyutils-tree-seedling" then
    -- 在放置位置生成一棵树
    local tree_types = {"tree-01", "tree-02", "tree-03", "tree-04", "tree-05", "tree-06", "tree-07"}
    local tree_type = tree_types[math.random(#tree_types)]
    surface.create_entity({
      name = tree_type,
      position = position
    })
  elseif item_name == "priyutils-tree-forest" then
    -- 在放置位置生成一片森林
    local tree_types = {"tree-01", "tree-02", "tree-03", "tree-04", "tree-05", "tree-06", "tree-07"}
    -- 生成主树
    local tree_type = tree_types[math.random(#tree_types)]
    surface.create_entity({
      name = tree_type,
      position = position
    })
    -- 在周围生成更多树木
    for dx = -1, 1 do
      for dy = -1, 1 do
        if dx ~= 0 or dy ~= 0 then
          local pos = {x = position.x + dx, y = position.y + dy}
          -- 50%的概率生成树木
          if math.random() < 0.5 then
            local tree_type = tree_types[math.random(#tree_types)]
            surface.create_entity({
              name = tree_type,
              position = pos
            })
          end
        end
      end
    end
  end
  
  -- 将地形设为 grass-1，这样下次可以再次放置
  surface.set_tiles({{name = "grass-1", position = position}})
end

function plant_trees(entity, tiles, item)
  local surface = entity.surface
  local item_name = item
  -- 确保 item_name 是字符串
  if type(item) ~= "string" and item.name then
    item_name = item.name
  end
  -- 只对树木种植相关的物品执行操作
  if item_name == "priyutils-tree-seedling" or item_name == "priyutils-tree-forest" then
    for i,tile in pairs(tiles) do
      plant_trees_at_position(surface, tile.position, item_name)
    end
  end
end

script.on_event(defines.events.on_player_built_tile, function(event)
  if event.item ~= nil then
    plant_trees(game.players[event.player_index], event.tiles, event.item)
  end
end)

script.on_event(defines.events.on_robot_built_tile, function(event)
  if event.item ~= nil then
    plant_trees(event.robot, event.tiles, event.item)
  end
end)