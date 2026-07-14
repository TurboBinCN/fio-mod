local function dug(entity, tiles, item)
  local surface = entity.surface
  local item_name = item
  if type(item) ~= "string" and item.name then
    item_name = item.name
  end
  if item_name == "priyutils-dug-water" or item_name == "priyutils-dug-water-super" then
    for i,tile in pairs(tiles) do
      surface.set_tiles({{name="water", position=tile.position}})
    end
  end
end

local function on_player_built_tile(event)
  if event.item ~= nil then
    dug(game.players[event.player_index], event.tiles, event.item)
  end
end

local function on_robot_built_tile(event)
  if event.item ~= nil then
    dug(event.robot, event.tiles, event.item)
  end
end

return {
    on_player_built_tile = on_player_built_tile,
    on_robot_built_tile = on_robot_built_tile
}