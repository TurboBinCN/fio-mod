-- this code is just hiding out here, it does not generate through the ruin system.
local testing = {}

testing.build_on_nauvis = function()
  local surface = game.get_surface(1)

  local margin = 7
  local gap = margin * 2
  local offset = 50 + gap

  local diameter = margin + 50 + gap + 50 + gap + 50 + margin
  local map_gen_settings = surface.map_gen_settings
  map_gen_settings.width = diameter
  map_gen_settings.height = diameter
  surface.map_gen_settings = map_gen_settings

  local tiles = {}
  testing.tiles_add_rectangle(tiles, {-25 -offset -margin, -25 -offset -margin}, {25 +offset +margin, 25 +offset +margin}, mod_prefix .. "space")

  testing.tiles_add_rectangle(tiles, {-25 -offset, -25 -offset}, {25 -offset, 25 -offset}, mod_prefix .. "asteroid")
  testing.tiles_add_rectangle(tiles, {-25        , -25 -offset}, {25        , 25 -offset}, mod_prefix .. "space-platform-scaffold")
  testing.tiles_add_rectangle(tiles, {-15        , -15 -offset}, {15        , 15 -offset}, mod_prefix .. "space-platform-plating")
  testing.tiles_add_rectangle(tiles, {-25 +offset, -25 -offset}, {25 +offset, 25 -offset}, mod_prefix .. "spaceship-floor")

  testing.tiles_add_rectangle(tiles, {-25 -offset, -25}, {25 -offset, 25}, "water")
  testing.tiles_sub_rectangle(tiles, {-25, -25}, {25, 25})
  testing.tiles_add_rectangle(tiles, {-25 +offset, -25}, {25 +offset, 25}, "landfill")

  surface.set_tiles(tiles)
end

testing.tiles_add_rectangle = function(tiles, left_top, right_bottom, tile_name)
  for x = left_top[1], right_bottom[1] - 1 do
    for y = left_top[2], right_bottom[2] - 1 do
      local position = {x, y}
      local key = core_util.positiontostr(position)
      tiles[key] = {position = position, name = tile_name}
    end
  end
end

testing.tiles_sub_rectangle = function(tiles, left_top, right_bottom)
  for x = left_top[1], right_bottom[1] - 1 do
    for y = left_top[2], right_bottom[2] - 1 do
      local position = {x, y}
      local key = core_util.positiontostr(position)
      tiles[key] = nil
    end
  end
end

return testing
