function dug(entity, tiles, item)
  local surface = entity.surface
  local item_name = item
  -- 确保 item_name 是字符串
  if type(item) ~= "string" and item.name then
    item_name = item.name
  end
  -- 只对挖水相关的物品执行操作
  if item_name == "priyutils-dug-water" or item_name == "priyutils-dug-water-super" then
    for i,tile in pairs(tiles) do
      surface.set_tiles({{name="water", position=tile.position}})
    end
  end
end

script.on_event(defines.events.on_player_built_tile, function(event)
  if event.item ~= nil then
    dug(game.players[event.player_index], event.tiles, event.item)
  end
end)

script.on_event(defines.events.on_robot_built_tile, function(event)
  if event.item ~= nil then
    dug(event.robot, event.tiles, event.item)
  end
end)