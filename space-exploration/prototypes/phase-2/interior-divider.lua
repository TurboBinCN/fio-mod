local tile = table.deepcopy(data.raw.tile["mineral-black-dirt-1"])
tile.name = "interior-divider"
tile.layer = 0
--tile.collision_mask.layers[spaceship_collision_layer] = true
-- prevents nukes from removing but also prevents ruin walls from spawning.
-- instead add extra limitation to nukes tile change.
tile.collision_mask.layers[flying_collision_layer] = true
tile.autoplace = nil
tile.localised_name = nil

data:extend(
{
  tile
})
