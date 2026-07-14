local function plant_trees_at_position(surface, position, item_name)
  if item_name == "priyutils-tree-seedling" then
    local tree_types = {"tree-01", "tree-02", "tree-03", "tree-04", "tree-05", "tree-06", "tree-07"}
    local tree_type = tree_types[math.random(#tree_types)]
    surface.create_entity({
      name = tree_type,
      position = position
    })
  elseif item_name == "priyutils-tree-forest" then
    local tree_types = {"tree-01", "tree-02", "tree-03", "tree-04", "tree-05", "tree-06", "tree-07"}
    local tree_type = tree_types[math.random(#tree_types)]
    surface.create_entity({
      name = tree_type,
      position = position
    })
    for dx = -1, 1 do
      for dy = -1, 1 do
        if dx ~= 0 or dy ~= 0 then
          local pos = {x = position.x + dx, y = position.y + dy}
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
  surface.set_tiles({{name = "grass-1", position = position}})
end

local function plant_trees(entity, tiles, item)
  local surface = entity.surface
  local item_name = item
  if type(item) ~= "string" and item.name then
    item_name = item.name
  end
  if item_name == "priyutils-tree-seedling" or item_name == "priyutils-tree-forest" then
    for i,tile in pairs(tiles) do
      plant_trees_at_position(surface, tile.position, item_name)
    end
  end
end

local function on_player_built_tile(event)
  if event.item ~= nil then
    plant_trees(game.players[event.player_index], event.tiles, event.item)
  end
end

local function on_robot_built_tile(event)
  if event.item ~= nil then
    plant_trees(event.robot, event.tiles, event.item)
  end
end

return {
    on_player_built_tile = on_player_built_tile,
    on_robot_built_tile = on_robot_built_tile
}