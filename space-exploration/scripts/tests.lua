if not is_debug_mode then return end

-- util.lua
assert(string.count("starmap-1", "-") == 1)
assert(string.count("starmap-1-transformer", "-") == 2)

-- map-view.lua
assert(MapView.is_surface_starmap({name = "starmap-1"}) == true)
assert(MapView.is_surface_starmap({name = "starmap-1-transformer"}) == false)

assert(MapView.get_player_index_from_surface({name = "starmap-1"}) == 1)
assert(MapView.get_player_index_from_surface({name = "starmap-1-transformer"}) == nil)
