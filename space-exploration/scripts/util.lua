local util = require("__space-exploration__/shared_util")

---@note these tables are lazily evaluated, so won't take much space.
util.signal_id_type_to_prototype = {
  ["item"] = prototypes.item,
  ["fluid"] = prototypes.fluid,
  ["virtual"] = prototypes.virtual_signal,
  ["entity"] = prototypes.entity,
  ["recipe"] = prototypes.recipe,
  ["space-location"] = prototypes.space_location,
  ["asteroid-chunk"] = prototypes.asteroid_chunk,
  ["quality"] = prototypes.quality,
}

---@param a number
---@return integer
function math.round(a)
  return math.floor(a + 0.5)
end

---@param str string
---@return string
function string.trim(str)
  local trimmed = string.gsub(str, '^%s*(.-)%s*$', '%1')
  return trimmed
end

---@generic T
---@param t T
---@return T
function util.deep_copy(t)
  return table.deepcopy(t)
end

---@generic T
---@param t T
---@return T
function util.shallow_copy(t) -- shallow-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do target[k] = v end
    setmetatable(target, meta)
    return target
end

---@param t table
---@param a any
---@param b any
function util.swap_elements(t, a, b)
  if type(t) ~= "table" then return t end
  t[a], t[b] = t[b], t[a]
end

---@generic T
---@param tbl T[]
---@return T[]
function util.shuffle(tbl)
  return util.shuffle_with_generator(tbl, math.random)
end

-- Shuffle with specific random generator
---@generic T
---@param tbl T[]
---@param random_generator LuaRandomGenerator|fun(i:uint):uint
---@return T[]
function util.shuffle_with_generator(tbl, random_generator)
  -- Fisher–Yates shuffle
  for i = #tbl, 2, -1 do
    local rand = random_generator(i)
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
  return tbl
end

---@generic T
---@param tbl T[]
---@return T
function util.random_from_array(tbl)
  --return tbl[1 + math.floor(#tbl * (math.random() - 0.0000001))]
  return tbl[math.random(#tbl)]
end

---@generic K, V
---@param map table<K, V>
---@return K[]
function util.map_to_keys(map)
    local keys = {}
    for key, _ in pairs(map) do
        table.insert(keys, key)
    end
    return keys
end

---@generic K, V
---@param tbl {K:any, V:any}
---@param criteria_function fun(V):number function accepts value from input table and returns a number
---@return number max Max value returned by `criteria_function`
---@return K max_index Index referencing max value
function util.find_max_from_table(tbl, criteria_function)
  local max = -math.huge
  local max_index = nil
  for i, element in pairs(tbl) do
    if criteria_function(element) > max then
      max = criteria_function(element)
      max_index = i
    end
  end
  return max, max_index
end

---@param entity_a LuaEntity|LuaEquipment
---@param entity_b LuaEntity|LuaEquipment
function util.transfer_burner(entity_a, entity_b)
  if entity_a.burner and entity_b.burner then
    if entity_a.burner.currently_burning then
      entity_b.burner.currently_burning = entity_a.burner.currently_burning.name
      entity_b.burner.remaining_burning_fuel = entity_a.burner.remaining_burning_fuel
    end
    if entity_a.burner.inventory then
      util.move_inventory_items(entity_a.burner.inventory, entity_b.burner.inventory)
      if entity_a.burner.burnt_result_inventory then
        util.move_inventory_items(entity_a.burner.burnt_result_inventory, entity_b.burner.burnt_result_inventory)
      end
    end
  end
end

---@param inv_a LuaInventory
---@param inv_b LuaInventory
---@param probability? number Chance that item copy is successful [0,1]
function util.copy_inventory(inv_a, inv_b, probability)
    if not probability then probability = 1 end
    if inv_a and inv_b then
        local contents = inv_a.get_contents()
        for _, item in pairs(contents) do
            if probability == 1 or probability > math.random() then
              inv_b.insert({name=item.name, count=item.count, quality=item.quality})
            end
        end
    end
end

---@param inv_a LuaInventory inventory to transfer FROM
---@param inv_b LuaInventory inventory to transfer TO
function util.move_inventory_items(inv_a, inv_b)
  -- move all items from inv_a to inv_b
  -- preserves item data but inv_b MUST be able to accept the items or they are dropped on the ground.
  -- inventory A is cleared.
  if inv_a and inv_b then
    local inv_b_len = #inv_b
    for i = 1, #inv_a do
      if inv_a[i].valid_for_read then
        if inv_b_len >= i then
          if not inv_b[i].transfer_stack(inv_a[i]) then
            inv_b.insert(inv_a[i])
          end
        else
          inv_b.insert(inv_a[i])
        end
      end
    end
    if not inv_a.is_empty() then
      local entity = inv_b.entity_owner
      if entity then
        for i = 1, #inv_a do
          if inv_a[i].valid_for_read then
            entity.surface.spill_item_stack{
              position = entity.position,
              stack = inv_a[i],
              enable_looted = true,
              force = entity.force,
              allow_belts = false
            }
          end
        end
      end
    end
    inv_a.clear()
  end
end

---@param inv_a LuaInventory
---@param inv_b LuaInventory
function util.transfer_inventory_filters_direct(inv_a, inv_b)
  if inv_a and inv_b and inv_a.supports_filters() and inv_b.supports_filters() then
    for i = 1, util.min(#inv_a, #inv_b) do
      local filter = inv_a.get_filter(i)
      if filter then
        inv_b.set_filter(i, filter)
      end
    end

    if inv_a.supports_bar() and inv_b.supports_bar() then
      -- Only read the bar if it is supported
      local bar = inv_a.get_bar()
      if bar <= #inv_a then  -- Bar equals size+1 when it is unset
        inv_b.set_bar(bar)  -- Set the bar
      else
        inv_b.set_bar()  -- Reset bar to max size
      end
    end
  end
end

---@param entity_a LuaEntity
---@param entity_b LuaEntity
---@param inventory_type defines.inventory
function util.transfer_inventory_filters(entity_a, entity_b, inventory_type)
    local inv_a = entity_a.get_inventory(inventory_type)
    local inv_b = entity_b.get_inventory(inventory_type)
    util.transfer_inventory_filters_direct(inv_a, inv_b)
end

---@param entity_a LuaEntity
---@param entity_b LuaEntity
function util.transfer_equipment_grid(entity_a, entity_b) -- NOTE: entity can be an item
    if not (entity_a.grid and entity_b.grid) then return end
    local grid_a = entity_a.grid
    local grid_b = entity_b.grid
    local equipment = grid_a.equipment
    for _, item in pairs(equipment) do
      local item_name = item.type == "equipment-ghost" and item.ghost_name or item.name
        local new_item = grid_b.put({
                name=item_name,
                position=item.position,
                ghost = item.type == "equipment-ghost",
              })
        if new_item then
            if item.shield and item.shield > 0 then
                new_item.shield = item.shield
            end
            if item.energy and item.energy > 0 then
                new_item.energy = item.energy
            end
            util.transfer_burner(item, new_item)
        else
            game.print("SE: Error transferring "..item_name.." to the new equipment grid.")
        end
    end
end

---@param entity_a LuaEntity
---@param entity_b LuaEntity
function util.transfer_fluids (entity_a, entity_b)
  for i = 1, entity_a.fluids_count do
    entity_b.set_fluid(i, entity_a.get_fluid(i))
  end
end

---@param entity_a LuaEntity
---@param entity_b LuaEntity
function util.transfer_infinity_container(entity_a, entity_b)
  entity_b.infinity_container_filters = entity_a.infinity_container_filters
  entity_b.remove_unfiltered_items = entity_a.remove_unfiltered_items
end

---@param area BoundingBox
---@param position MapPosition
---@return boolean
function util.area_contains_position(area, position)
  local px = position.x or position[1]
  local py = position.y or position[2]
  for k1, v1 in pairs(area) do
    if k1 == 1 or k1 == "left_top" then
      for k2, v2 in pairs(v1) do
        if k2 == 1 or k2 == "x" then
          if px < v2 then return false end
        elseif k2 == 2 or k2 == "y" then
          if py < v2 then return false end
        end
      end
    elseif k1 == 2 or k1 == "right_bottom" then
      for k2, v2 in pairs(v1) do
        if k2 == 1 or k2 == "x" then
          if px > v2 then return false end
        elseif k2 == 2 or k2 == "y" then
          if py > v2 then return false end
        end
      end
    end
  end
  return true
end

---@param area BoundingBox
---@param position MapPosition
---@return BoundingBox
function util.area_add_position(area, position)
  local area2 = table.deepcopy(area)
  for _, corner in pairs(area2) do
    for axis_name, axis_value in pairs(corner) do
      if axis_name == 1 or axis_name == "x" then
        corner[axis_name] = axis_value + (position.x or position[1])
      elseif axis_name == 2 or axis_name == "y" then
        corner[axis_name] = axis_value + (position.y or position[2])
      end
    end
  end
  return area2
end

---@param area BoundingBox
---@param range number
---@return BoundingBox
function util.area_extend(area, range)
  local area2 = table.deepcopy(area)
  for k1, v1 in pairs(area2) do
    local m = 1
    if k1 == 1 or k1 == "left_top" then
      m = -1
    end
    for k2, v2 in pairs(v1) do
      v1[k2] = v2 + range * m
    end
  end
  return area2
end

---@alias Coordinate.0 Vector.0|MapPosition.0|TilePosition.0|StellarPosition
---@alias Coordinate.1 {[1]:number, [2]:number} Vector, MapPosition, TilePosition
---@alias Coordinate Coordinate.0|Coordinate.1

---@param position Coordinate.0
---@param radius number
---@return {[1]:MapPosition, [2]:MapPosition} BoundingBox
function util.position_to_area(position, radius, x_multiplier)
  x_multiplier = x_multiplier or 1
  return {{x = position.x - radius * x_multiplier, y = position.y - radius},
          {x = position.x + radius * x_multiplier, y = position.y + radius}}
end
---@param position Coordinate.0
---@param radius number
---@return BoundingBox.0
function util.position_to_rect(position, radius)
  return {left_top = {x = position.x - radius, y = position.y - radius},
          right_bottom = {x = position.x + radius, y = position.y + radius}}
end

---@param rect BoundingBox
---@param position Coordinate
---@return boolean
function util.position_in_rect(rect, position)
  local left_top = rect.left_top or rect[1]
  local right_bottom = rect.right_bottom or rect[2]
  return position.x >= left_top.x and position.y >= left_top.y
    and position.x <= right_bottom.x and position.y <= right_bottom.y
end

---@param position MapPosition
---@return TilePosition.0
function util.position_to_tile(position)
    return {x = math.floor(position.x or position[1]), y = math.floor(position.y or position[2])}
end

---@param tile_position TilePosition.0
---@return MapPosition.0
function util.tile_to_position(tile_position)
    return {x = math.floor(tile_position.x)+0.5, y = math.floor(tile_position.y)+0.5}
end

---@param tile_position TilePosition
---@param margin? number
---@return {[1]:MapPosition, [2]:MapPosition} BoundingBox
function util.tile_to_area(tile_position, margin)
  tile_position = {x = math.floor(tile_position.x or tile_position[1]), y = math.floor(tile_position.y or tile_position[2])}
  margin = margin or 0.01
  return {
    {tile_position.x+margin, tile_position.y+margin},
    {tile_position.x+1-margin, tile_position.y+1-margin}
  }
end

---@param position1 Coordinate.0
---@param position2 Coordinate.0
---@param epsilon? number
---@return boolean
function util.position_equal(position1, position2, epsilon)
  epsilon = epsilon or 1e-6
  if math.abs(position1.x - position2.x) > epsilon then return false end
  if math.abs(position1.y - position2.y) > epsilon then return false end
  return true
end

--[[
Compute a ray AABB intersection.
Algorithm from https://tavianator.com/2011/ray_box.html
"""
Axis-aligned bounding boxes (AABBs) are universally used to bound finite objects in ray-tracing.
Ray/AABB intersections are usually faster to calculate than exact ray/object intersections,
and allow the construction of bounding volume hierarchies (BVHs) which reduce the number of objects that need to be considered for each ray.
(More on BVHs in a later post.)
This means that a ray-tracer spends a lot of its time calculating ray/AABB intersections, and therefore this code ought to be highly optimised.

The fastest method for performing ray/AABB intersections is the slab method.
The idea is to treat the box as the space inside of three pairs of parallel planes.
The ray is clipped by each pair of parallel planes, and if any portion of the ray remains, it intersected the box.
"""
]]
---@param ray_origin Coordinate.0
---@param orientation RealOrientation
---@param aabb {min_x: number, min_y: number, max_x: number, max_y: number}
---@return boolean
function util.intersects_ray_aabb(ray_origin, orientation, aabb)
  -- ray_vector will never be the zero-vector
  local ray_vector = util.orientation_to_vector(orientation, 1)

  local tmin
  local tmax
  if (ray_vector.x ~= 0) then
    local tx1 = (aabb.min_x - ray_origin.x) / ray_vector.x
    local tx2 = (aabb.max_x - ray_origin.x) / ray_vector.x

    tmin = math.min(tx1, tx2)
    tmax = math.max(tx1, tx2)
  else -- ray is going exactly vertically
    return ray_origin.x >= aabb.min_x and ray_origin.x <= aabb.max_x
  end
  if (ray_vector.y ~= 0) then
    local ty1 = (aabb.min_y - ray_origin.y) / ray_vector.y
    local ty2 = (aabb.max_y - ray_origin.y) / ray_vector.y

    tmin = math.max(tmin, math.min(ty1, ty2))
    tmax = math.min(tmax, math.max(ty1, ty2))
  else -- ray is going exactly horizontally
    return ray_origin.y >= aabb.min_y and ray_origin.y <= aabb.max_y
  end
  return tmax >= tmin
end

---@param position Coordinate.0
---@return string
function util.position_to_xy_string(position)
    return util.xy_to_string(position.x, position.y)
end

---@param x number
---@param y number
---@return string
function util.xy_to_string(x, y)
    return util.floor(x) .. "_" .. util.floor(y)
end

---@param a number
---@param b number
---@param alpha number
---@return number
function util.lerp(a, b, alpha)
    return a + (b - a) * alpha
end

---@param a number
---@param b number
---@param alpha number
---@return number
function util.lerp_angles(a, b, alpha)
    local da = b - a

    if da < -0.5 then
        da = da + 1
    elseif da > 0.5 then
        da = da - 1
    end
    local na = a + da * alpha
    if na < 0 then
        na = na + 1
    elseif na > 1 then
        na = na - 1
    end
    return na
end

---@param array Coordinate.1
---@return Vector.0
function util.array_to_vector(array)
    return {x = array[1], y = array[2]}
end

---@generic T: Coordinate.0
---@param a T
---@param b Coordinate.0
---@return T
function util.vectors_delta(a, b) -- from a to b
  ---@cast a {x:number, y:number}
  ---@cast b {x:number, y:number}
  if not a and b then return 0 end
  return {x = b.x - a.x, y = b.y - a.y}
end

---@param a number[]
---@param b number[]
---@return number[]
function util.nvectors_delta(a, b) -- from a to b
  local delta = {}
  for i, coordinate in pairs(a) do
    delta[i] = b[i] - a[i]
  end
  return delta
end

---@param a Coordinate.0
---@param b Coordinate.0
---@return number
function util.vectors_delta_length(a, b)
    return util.vector_length_xy(b.x - a.x, b.y - a.y)
end

---Returns the square of the vector length.
---Useful for when the absolute length is not required,
---and relative lengths will be compared
---@param a Coordinate.0
---@param b Coordinate.0
---@return number
function util.vectors_delta_length_sq(a, b)
  return util.vector_length_xy_sq(b.x - a.x, b.y - a.y)
end


---@param a number[]
---@param b number[]
---@return number
function util.nvectors_delta_length(a, b)
    return util.nvector_length(util.nvectors_delta(a, b))
end

---@param a Coordinate.0|ChunkPosition.0
---@return number
function util.vector_length(a)
    return (a.x * a.x + a.y * a.y) ^ 0.5
end

---@param a number[]
---@return number
function util.nvector_length(a)
  local d = 0
  for _, c in pairs(a) do
    d = d + c * c
  end
  return util.sqrt(d)
end

---@param x number
---@param y number
---@return number
function util.vector_length_xy(x, y)
    return (x * x + y * y) ^ 0.5
end

---@param x number
---@param y number
---@return number
function util.vector_length_xy_sq(x, y)
  return x * x + y * y
end

---@param a Coordinate.0
---@param b Coordinate.0
---@return number
function util.vector_dot(a, b)
    return a.x * b.x + a.y * b.y
end

---@param a number[]
---@param b number[]
---@return number
function util.nvector_dot(a, b)
  local d = 0
  for i, c in pairs(a) do
    d = d + a[i] * b[i]
  end
  return d
end

---@generic T:Coordinate.0
---@param a T
---@param multiplier number
---@return T
function util.vector_multiply(a, multiplier)
  ---@cast a {x:number, y:number}
  return {x = a.x * multiplier, y = a.y * multiplier}
end

---@param a number[]
---@param multiplier number
---@return number[]
function util.nvector_multiply(a, multiplier)
  local d = {}
  for i, c in pairs(a) do
    d[i] = c*multiplier
  end
  return d
end

---@param a Coordinate.0
---@param b Coordinate.0
---@return Vector.0
function util.vector_dot_projection(a, b)
    local n = util.vector_normalise(a)
    local d = util.vector_dot(n, b)
    return {x = n.x * d, y = n.y * d}
end

---@generic T: Coordinate.0
---@param a T
---@return T
function util.vector_normalise(a)
  ---@cast a {x:number, y:number}
    local length = util.vector_length(a)
    return {x = a.x/length, y = a.y/length}
end

---@param a number[]
---@return number[]
function util.nvector_normalise(a)
    local length = util.nvector_length(a)
    local normalised = {}
    for i, coordinate in pairs(a) do
      normalised[i] = coordinate / length
    end
    return normalised
end

---@generic T: Coordinate.0
---@param a T
---@param length number
---@return T
function util.vector_set_length(a, length)
    ---@cast a {x:number, y:number}
    local old_length = util.vector_length(a)
    if old_length == 0 then return {x = 0, y = -length} end
    return {x = a.x/old_length*length, y = a.y/old_length*length}
end

---@param a {x:number, y:number, z:number}|{[1]:number, [2]:number, [3]:number}
---@param b {x:number, y:number, z:number}|{[1]:number, [2]:number, [3]:number}
---@return {x:number, y:number, z:number}
function util.vector_cross(a, b)
  -- N = i(a2b3 - a3b2) + j(a3b1 - a1b3) + k(a1b2 - a2b1)
  return {
    x = (a.y or a[2]) * (b.z or b[3]) - (a.z or a[3]) * (b.y or b[2]),
    y = (a.z or a[3]) * (b.x or b[1]) - (a.x or a[1]) * (b.z or b[3]),
    z = (a.x or a[1]) * (b.y or b[2]) - (a.y or a[2]) * (b.x or b[1]),
  }
end

---@param a Coordinate.0
---@param b Coordinate.0
---@return RealOrientation
function util.orientation_from_to(a, b)
    return util.vector_to_orientation_xy(b.x - a.x, b.y - a.y)
end

---@param orientation RealOrientation
---@param length number
---@return Vector.0
function util.orientation_to_vector(orientation, length)
    return {x = length * util.sin(orientation * 2 * util.pi), y = -length * util.cos(orientation * 2 * util.pi)}
end

---@generic T: Coordinate.0
---@param orientation RealOrientation
---@param a T
---@return T
function util.rotate_vector(orientation, a)
  ---@cast a {x:number, y:number}
    if orientation == 0 then
        return {x = a.x, y = a.y}
    else
        return {
            x = -a.y * util.sin(orientation * 2 * util.pi) + a.x * util.sin((orientation + 0.25) * 2 * util.pi),
            y = a.y * util.cos(orientation * 2 * util.pi) -a.x * util.cos((orientation + 0.25) * 2 * util.pi)}

    end
end

---Rotates a bounding box around a pivot point
---@param box BoundingBox.0
---@param pivot MapPosition.0
---@return table
function util.rotate_box(box, pivot)
  if (not box.orientation) or box.orientation == 0 then
    return box
  end
  local negative_pivot = util.vector_multiply(pivot, -1)
  local lt = util.vectors_add(box.left_top, negative_pivot)
  lt = util.rotate_vector(box.orientation, lt)
  lt = util.vectors_add(lt, pivot)
  local rb = util.vectors_add(box.right_bottom, negative_pivot)
  rb = util.rotate_vector(box.orientation, rb)
  rb = util.vectors_add(rb, pivot)

  if lt.x > rb.x then
    rb.x, lt.x = lt.x, rb.x
  end
  if lt.y < rb.y then
    rb.y, lt.y = lt.y, rb.y
  end

  return {left_top = lt, right_bottom=rb}

end

---@generic T:Coordinate.0
---@param a T
---@param b Coordinate.0
---@return T
function util.vectors_add(a, b)
  ---@cast a {x:number, y:number}
    return {x = a.x + b.x, y = a.y + b.y}
end


---@param a Coordinate.0
---@param b Coordinate.0
---@param c Coordinate.0
---@return Vector.0
function util.vectors_add3(a, b, c)
    return {x = a.x + b.x + c.x, y = a.y + b.y + c.y}
end

---@param a Coordinate.0
---@param b Coordinate.0
---@param alpha number
---@return Vector.0
function util.lerp_vectors(a, b, alpha)
    return {x = a.x + (b.x - a.x) * alpha, y = a.y + (b.y - a.y) * alpha}
end

---@generic T: Coordinate.0
---@param a T
---@param b Coordinate.0
---@param max_distance number
---@param eliptical? boolean
---@return T
function util.move_to(a, b, max_distance, eliptical)
    -- move from a to b with max_distance.
    -- if eliptical, reduce y change (i.e. turret muzzle flash offset)
    local eliptical_scale = 0.9
    local delta = util.vectors_delta(a, b)
    if eliptical then
        delta.y = delta.y / eliptical_scale
    end
    local length = util.vector_length(delta)
    if (length > max_distance) then
        local partial = max_distance / length
        delta = {x = delta.x * partial, y = delta.y * partial}
    end
    if eliptical then
        delta.y = delta.y * eliptical_scale
    end
    return {x = a.x + delta.x, y = a.y + delta.y}
end

---@param v Coordinate.0
---@return RealOrientation
function util.vector_to_orientation(v)
    return util.vector_to_orientation_xy(v.x, v.y)
end

---@param x number
---@param y number
---@return RealOrientation
function util.vector_to_orientation_xy(x, y)
    return util.atan2(y, x) / util.pi / 2
end

---@param direction defines.direction
---@return RealOrientation
function util.direction_to_orientation(direction)
    if direction == defines.direction.north then
        return 0
    elseif direction == defines.direction.northeast then
        return 0.125
    elseif direction == defines.direction.east then
        return 0.25
    elseif direction == defines.direction.southeast then
        return 0.375
    elseif direction == defines.direction.south then
        return 0.5
    elseif direction == defines.direction.southwest then
        return 0.625
    elseif direction == defines.direction.west then
        return 0.75
    elseif direction == defines.direction.northwest then
        return 0.875
    end
    return 0
end

---@param direction defines.direction
---@return string|0
function util.direction_to_string(direction)
    if direction == defines.direction.north then
        return "north"
    elseif direction == defines.direction.northeast then
        return "northeast"
    elseif direction == defines.direction.east then
        return "east"
    elseif direction == defines.direction.southeast then
        return "southeast"
    elseif direction == defines.direction.south then
        return "south"
    elseif direction == defines.direction.southwest then
        return "southwest"
    elseif direction == defines.direction.west then
        return "west"
    elseif direction == defines.direction.northwest then
        return "northwest"
    end
    return 0
end

util.char_to_multiplier = {
    m = 0.001,
    c = 0.01,
    d = 0.1,
    h = 100,
    k = 1000,
    M = 1000000,
    G = 1000000000,
    T = 1000000000000,
    P = 1000000000000000,
}

---@param str string
---@return number?
function util.string_to_number(str)
    str = ""..str
    local number_string = ""
    local last_char = nil
    for i = 1, #str do
        local c = str:sub(i,i)
        if c == "." or (c == "-" and i == 1) or tonumber(c) ~= nil then
            number_string = number_string .. c
        else
            last_char = c
            break
        end
    end
    if last_char and util.char_to_multiplier[last_char] then
        return tonumber(number_string) * util.char_to_multiplier[last_char]
    end
    return tonumber(number_string)
end

---@param s string
---@param delimiter string
---@return string[]
function util.split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

---@param str_table string[]
---@param sep string
---@return string
function util.string_join (str_table, sep)
  local str = ""
  for _, str_part in pairs(str_table) do
    if str ~= "" then
      str = str .. sep
    end
      str = str .. str_part
  end
  return str
end

---@param s string
---@param prefix string
---@return string?
function util.parse_with_prefix(s, prefix)
    if string.sub(s, 1, string.len(prefix)) == prefix then
        return string.sub(s, string.len(prefix)+1)
    end
end

---@param table_weak table
---@param table_strong table
---@return table
function util.overwrite_table(table_weak, table_strong)
  for k,v in pairs(table_strong) do table_weak[k] = v end
  return table_weak
end

---@param table table
---@return string
function util.table_to_string(table)
  return serpent.block( table, {comment = false, numformat = '%1.8g' } )
end

---@param table table<any, string|number|boolean>
---@return string
function util.values_to_string(table)
  local string = ""
  for _, value in pairs(table) do
    string = ((string == "") and "" or ", ") .. string .. value
  end
  return string
end

---@param value number
---@param base number
---@return number
function util.math_log(value, base)
  --logb(a) = logc(a) / logc(b)
  return math.log(value)/math.log(base)
end

---@param seconds number|string
---@param use_days? boolean
---@return string
function util.seconds_to_clock(seconds, use_days)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "0";
  else
    local days = 0
    if use_days then days = math.floor(seconds/3600/24) end
    local hours = math.floor(seconds/3600 - days*24)
    local mins = math.floor(seconds/60 - hours*60 - days*1440)
    local secs = math.floor(seconds - mins *60 - hours*3600  - days*86400)
    local s_hours = string.format("%02.f",hours);
    local s_mins = string.format("%02.f", mins);
    local s_secs = string.format("%02.f", secs);
    if days > 0 then
      return days.."d:"..s_hours..":"..s_mins..":"..s_secs
    end
    if hours > 0 then
      return s_hours..":"..s_mins..":"..s_secs
    end
    if mins > 0 then
      return s_mins..":"..s_secs
    end
    if secs == 0 then
      return "0"
    end
    return s_secs
  end
end

---@param number_or_position Vector.0|number
---@return Vector.0|number
function util.to_rail_grid(number_or_position)
  if type(number_or_position) == "table" then
    return {x = util.to_rail_grid(number_or_position.x), y = util.to_rail_grid(number_or_position.y)}
  end
  return math.floor(number_or_position / 2) * 2
end

---@param fuel number
---@param ceil? unknown unused
---@return string
function util.format_fuel(fuel, ceil)
  return string.format("%.2f",(fuel or 0) / 1000).."k"
end

---@param str string
---@return number
function util.number_from_string(str)
  local _, _, number, prefix = string.find(string.lower(str), "^(-?%d+%.?%d*)([kmg]?)$")
  local prefixes = {k = 1e3, m = 1e6, g = 1e9}
  return math.floor((tonumber(number) or 0) * (prefixes[prefix] or 1))
end

---@param fuel number
---@param ceil? boolean
---@return string
function util.format_energy(fuel, ceil)
  if ceil then
    return math.ceil((fuel or 0) / 1000000000).."GJ"
  else
    return math.floor((fuel or 0) / 1000000000).."GJ"
  end
end

---@param direction defines.direction
---@return Vector.0
function util.direction_to_vector (direction)
  if direction == defines.direction.east then return {x=1,y=0} end
  if direction == defines.direction.north then return {x=0,y=-1} end
  if direction == defines.direction.northeast then return {x=1,y=-1} end
  if direction == defines.direction.northwest then return {x=-1,y=-1} end
  if direction == defines.direction.south then return {x=0,y=1} end
  if direction == defines.direction.southeast then return {x=1,y=1} end
  if direction == defines.direction.southwest then return {x=-1,y=1} end
  if direction == defines.direction.west then return {x=-1,y=0} end
end

---Returns -1, 0, or 1 for a given negative, zero, or positive numeric argument.
---@param x number Number to evaluate
---@return 0|1|-1
function util.sign(x)
  if x < 0 then
    return -1
  elseif x > 0 then
    return 1
  end
  return 0
end

---@param gui_element LuaGuiElement
---@param name string
---@return LuaGuiElement?
function util.find_first_descendant_by_name(gui_element, name)
  for _, child in pairs(gui_element.children) do
    if child.name == name then
      return child
    end
    local found = util.find_first_descendant_by_name(child, name)
    if found then return found end
  end
end

---Traverses the children of a given parent safely, returning nil if a child is not found.
---@param parent LuaGuiElement Parent gui element to search in
---@param args string[] Array of gui element names to traverse
---@return LuaGuiElement? element
function util.get_gui_element(parent, args)
  if not parent then return end

  local element = parent
  for _, obj in pairs(args) do
    if element[obj] then
      element = element[obj]
    else
      return
    end
  end

  return element
end

---@param gui_element LuaGuiElement
---@param name string
---@param all_found table
---@return LuaGuiElement[]
function util.find_descendants_by_name(gui_element, name, all_found)
  local found = all_found or {}
  for _, child in pairs(gui_element.children)do
    if child.name == name then
      table.insert(found, child)
    end
    util.find_descendants_by_name(child, name, found)
  end
  return found
end

---@param entity_a LuaEntity
---@param entity_b LuaEntity
---@param inventory defines.inventory
---@param swap_bar? boolean
function util.swap_entity_inventories(entity_a, entity_b, inventory, swap_bar)
  util.swap_inventories(entity_a.get_inventory(inventory), entity_b.get_inventory(inventory), swap_bar)
end

---@param inv_a LuaInventory
---@param inv_b LuaInventory
---@param swap_bar? boolean
function util.swap_inventories(inv_a, inv_b, swap_bar)
  if inv_a.is_filtered() and inv_b.supports_filters() then
    for i = 1, math.min(#inv_a, #inv_b) do
      inv_b.set_filter(i, inv_a.get_filter(i))
    end
  end
  for i = 1, math.min(#inv_a, #inv_b)do
    inv_b[i].swap_stack(inv_a[i])
  end
  if swap_bar and inv_a.supports_bar() and inv_b.supports_bar() then
    local inv_a_bar = inv_a.get_bar()
    inv_a.set_bar(inv_b.get_bar())
    inv_b.set_bar(inv_a_bar)
  end
end

---@param positions Vector.0[]
---@param separation number
---@param max_iterations? uint
---@return Vector.0[]
function util.separate_points(positions, separation, max_iterations)
  positions = table.deepcopy(positions)
  --if true then return positions end
  if not max_iterations then max_iterations = 20 end
  local overshoot = 1.05 -- increse slightly to allow early finish
  local i = 1
  local continue = true
  while i <= max_iterations and continue do
    i = i + 1
    continue = false
    local forces = {}
    for a, pos_a in pairs(positions) do
      for b, pos_b in pairs(positions) do
        if a ~= b then
          local delta = Util.vectors_delta(pos_a, pos_b)
          local length = Util.vector_length(delta)
          if length < separation then
            local force = Util.vector_set_length(delta, (separation - length) / 2)
            if forces[a] then
              forces[a].x = forces[a].x + force.x
              forces[a].y = forces[a].y + force.y
            else
              forces[a] = force
            end
          end
        end
      end
    end
    for a, pos_a in pairs(positions) do
      local force = forces[a]
      if force then
        local length = Util.vector_length(force)
        if length > separation / 2 then
          force = Util.vector_set_length(force, separation / 2)
        end
        pos_a.x = pos_a.x - force.x * overshoot
        pos_a.y = pos_a.y - force.y * overshoot
        continue = true
      end
    end
  end
  return positions
end

---Marks a given table of entities for deconstruction if within range of a stationary roboport.
---Entities must be on the same surface and are expected to stacked to some degree, since each
---entity's individual position is not searched.
---@param entities LuaEntity[] Table of entities to mark for deconstruction
---@param surface LuaSurface Surface where entities are located
---@param position MapPosition Position to use for logistic network search
function util.conditional_mark_for_deconstruction(entities, surface, position)
  -- Marke the newly created entity for deconstruction if appropriate
  for name, force in pairs(game.forces) do
    if is_player_force(name) then
      local networks = surface.find_logistic_networks_by_construction_area(position, force)
      for _, network in pairs(networks) do
        if network.robot_limit > 1000000 then
          for _, entity in pairs(entities) do entity.order_deconstruction(force) end
          break
        end
      end
    end
  end
end

---@param entity LuaEntity
function util.safe_destroy(entity)
  if not entity.valid then return end
  if entity.name == "se-linked-container" then
    entity.link_id = 0
  end
  entity.destroy({raise_destroy=true})
end

---@param force LuaForce
---@param tech_name string
function util.safe_research_tech(force, tech_name)
  local tech = force.technologies[tech_name]
  if tech then
    tech.researched = true
  end
end

---@param hue number
---@param saturation number
---@param value number
---@return number?
---@return number?
---@return number?
function util.HSVToRGB( hue, saturation, value )
  --https://gist.github.com/GigsD4X/8513963
  -- Returns the RGB equivalent of the given HSV-defined color
  -- (adapted from some code found around the web)

  -- If it's achromatic, just return the value
  if saturation == 0 then
    return value;
  end;

  -- Get the hue sector
  local hue_sector = math.floor( hue / 60 );
  local hue_sector_offset = ( hue / 60 ) - hue_sector;

  local p = value * ( 1 - saturation );
  local q = value * ( 1 - saturation * hue_sector_offset );
  local t = value * ( 1 - saturation * ( 1 - hue_sector_offset ) );

  if hue_sector == 0 then
    return value, t, p;
  elseif hue_sector == 1 then
    return q, value, p;
  elseif hue_sector == 2 then
    return p, value, t;
  elseif hue_sector == 3 then
    return p, q, value;
  elseif hue_sector == 4 then
    return t, p, value;
  elseif hue_sector == 5 then
    return value, p, q;
  end;
end;

---@param event EventData.on_player_setup_blueprint
---@param names string|string[]
---@param serialize_fn fun(entity:LuaEntity):Tags
function util.setup_blueprint(event, names, serialize_fn)
  if type(names) == 'string' then names = {names} end
  local player_index = event.player_index
  if player_index and game.get_player(player_index) and game.get_player(player_index).connected  then
    local player = game.get_player(player_index)

    -- this setup code and checks is a workaround for the fact that the event doesn't specify the blueprint on the event
    -- and the player.blueprint_to_setup isn't actually set in the case of copy/paste or blueprint library or select new contents
    local blueprint = nil
    if player and player.blueprint_to_setup and player.blueprint_to_setup.valid_for_read then blueprint = player.blueprint_to_setup
    elseif player and player.cursor_stack.valid_for_read and player.cursor_stack.is_blueprint then blueprint = player.cursor_stack end
    if blueprint and blueprint.is_blueprint_setup() then


      local mapping = event.mapping.get()
      local blueprint_entities = blueprint.get_blueprint_entities()
      if blueprint_entities then
        for _, blueprint_entity in pairs(blueprint_entities) do
          if util.table_contains(names, blueprint_entity.name) then
            local entity = mapping[blueprint_entity.entity_number]
            if entity then
              local tags = serialize_fn(entity)
              if tags then
                blueprint.set_blueprint_entity_tags(blueprint_entity.entity_number, tags)
              end
            end
          end
        end
      end
    end
  end
end

---@param event EventData.on_entity_settings_pasted
---@param names string|string[]
---@param serialize_fn fun(entity:LuaEntity):Tags
---@param deserialize_fn fun(entity:LuaEntity, tags:Tags)
---@param cb? fun(entity:LuaEntity, player_index:uint)
function util.settings_pasted(event, names, serialize_fn, deserialize_fn, cb)
  if type(names) == 'string' then names = {names} end
  local player_index = event.player_index
  if player_index and game.get_player(player_index) and game.get_player(player_index).connected
  and event.source and event.source.valid and event.destination and event.destination.valid then
    if not util.table_contains(names, event.source.name) then return end
    if not util.table_contains(names, event.destination.name) then return end
    local tags = serialize_fn(event.source)
    if tags then
      deserialize_fn(event.destination, tags)
      if cb then cb(event.destination, player_index) end
    end
  end
end

---@param event EntityCreationEvent|EventData.on_entity_cloned
---@return LuaEntity
function util.get_entity_from_event(event)
  local entity
  if event.entity and event.entity.valid then
    entity = event.entity
  end
  if event.destination and event.destination.valid then
    entity = event.destination
  end
  return entity
end

---@param event EntityCreationEvent|EventData.on_entity_cloned
---@param serialize_fn fun(entity:LuaEntity):Tags
---@return Tags
function util.get_tags_from_event(event, serialize_fn)
  local tags = event.tags
  if not tags then
    if event.source and event.source.valid then
      tags = serialize_fn(event.source)
    end
  end
  return tags
end

---Returns the zone represented by given tags, if any.
---@param tags Tags Gui element tags
---@return AnyZoneType|StarType|SpaceshipType? Zone or spaceship
function util.get_zone_from_tags(tags)
  local type = tags.zone_type --[[@as string]]
  local index = tags.zone_index --[[@as uint]]

  if not index then return end

  if type == "spaceship" then
    return Spaceship.from_index(index)
  elseif type then
    return Zone.from_zone_index(index)
  end
end

---Adds/modifies a given gui element's tags with the given tags.
---@param element LuaGuiElement LuaGuiElement
---@param new_tags Tags New tags to add/overwrite
function util.update_tags(element, new_tags)
  local tags = element.tags
  for k, v in pairs(new_tags) do tags[k] = v end
  element.tags = tags
end

---Deletes the given tags from a gui element's tags.
---@param element LuaGuiElement Gui element whose tags to change
---@param tags_to_delete string[] Array of tags to delete
function util.delete_tags(element, tags_to_delete)
  local tags = element.tags
  for _, tag in pairs(tags_to_delete) do tags[tag] = nil end
  element.tags = tags
end

---Searches for a given entity or its ghost given the entity name (or table of names), surface, and
---position. Will atttempt to revive an entity ghost if one is found.
---@param surface LuaSurface Surface to search on
---@param name string|string[] Name or array of entity names to search for
---@param position MapPosition Position to search
---@param radius? float Search radius
---@return LuaEntity? entity
function util.find_entity_or_revive_ghost(surface, name, position, radius)
  local entities = surface.find_entities_filtered{
    name = name,
    position = position,
    radius = radius,
    limit = 1
  }
  if entities[1] then return entities[1] end

  local entity_ghosts = surface.find_entities_filtered{
    ghost_name = name,
    position = position,
    radius = radius,
    limit = 1
  }
  if entity_ghosts[1] then
    local _, entity = entity_ghosts[1].revive({})
    if entity then return entity end
  end
end

---@param surface_name string
---@param position MapPosition
---@return string
function util.gps_tag(surface_name, position)
  return "[gps="..math.floor(position.x or position[1])..","..math.floor(position.y or position[2])..","..surface_name.."]"
end

---@param types string[]
---@return string[]
function util.get_item_names_for_entity_types(types)
  local items = prototypes.get_item_filtered{
    {filter = "place-result" , elem_filters = {
      {filter = "type", type = types}
    }}
  }
  local item_names = {}
  for name, _ in pairs(items) do
    table.insert(item_names, name)
  end
  return item_names
end

---@param entity LuaEntity
---@param request LogisticFilter
function util.set_logistic_request(entity, request)
  local logistic_point = entity.get_logistic_point(defines.logistic_member_index.logistic_container)
  for i = logistic_point.sections_count, 1, -1 do
    logistic_point.remove_section(i)
  end
  util.add_logistic_request(entity, request)
end

---@param entity LuaEntity
---@param request LogisticFilter
function util.add_logistic_request(entity, request)
  local logistic_point = entity.get_logistic_point(defines.logistic_member_index.logistic_container)
  local logistic_section = logistic_point.add_section()
  logistic_section.set_slot(1, request)
end

---@param position MapPosition.0
---@return ChunkPosition.0
function util.position_to_chunk_position(position)
  return {x = math.floor(position.x/32), y = math.floor(position.y/32)}
end

--Fix for https://forums.factorio.com/viewtopic.php?f=47&t=104138
--Converts arbitrary float positions to tile centric positions
-- **FIXME** 0.7
-- Convert this calculated position to a real build position BEFORE using it for entity placement
-- fixes problem with build position rounding in game engine
--[[
function util.coordinate_to_build_coordinate(coordinate)
  return math.floor(coordinate) + 0.5
end
]] -- **FIXME** 0.7
---@param coordinate number
---@return number
function util.coordinate_to_build_coordinate(coordinate)
  return math.floor(coordinate + (coordinate >= 0 and 0 or 1/256)) + 0.5
end

--Fix for https://forums.factorio.com/viewtopic.php?f=47&t=104138
--Converts arbitrary float positions to tile centric positions
---@param position MapPosition.0|Vector.0
---@return MapPosition.0 build_position
function util.position_to_build_position(position)
  return {
    x = util.coordinate_to_build_coordinate(position.x),
    y = util.coordinate_to_build_coordinate(position.y)
  }
end

---@param recipe string|LuaRecipePrototype
---@param name string
---@return boolean
function util.has_product(recipe, name)
  if type(recipe) == "string" then recipe = prototypes.recipe[recipe] end
  if not recipe then return false end
  for _, product in pairs(recipe.products) do
    if product.name == name then return true end
  end
  return false
end

---@param production_statistics LuaFlowStatistics
---@param item_names table<string>
---@return int
function util.get_production_count(production_statistics, item_names)
  local count = 0
  for _, item_name in pairs(item_names) do
    count = count + production_statistics.get_input_count(item_name)
  end
  return count
end

---@param production_statistics LuaFlowStatistics
---@param item_names table<string>
---@return int
function util.get_consumption_count(production_statistics, item_names)
  local count = 0
  for _, item_name in pairs(item_names) do
    count = count + production_statistics.get_output_count(item_name)
  end
  return count
end

---Spawn the default flying text over an entity
---@param entity LuaEntity
---@param text string|LocalisedString
---@param color Color?
function util.spawn_flying_text_at_entity(entity, text, color)
  if not (entity and entity.valid) then return end
  rendering.draw_text{
    text = text,
    surface = entity.surface,
    target = entity,
    color = color or {1,1,1},
    time_to_live = 80,
    forces = entity.force
  }
end

util.circuit_signal_min = -2147483648
util.circuit_signal_max = 2147483647

---@param number number
---@return boolean
function util.valid_signal_count(number)
  return number >= util.circuit_signal_min and number <= util.circuit_signal_max
end

---@param bounding_box BoundingBox
---@return MapPosition[]
function util.get_tilebox(bounding_box)
  local left_top = {x = math.floor(bounding_box.left_top.x), y = math.floor(bounding_box.left_top.y)}
  local right_bottom = {x = math.ceil(bounding_box.right_bottom.x), y = math.ceil(bounding_box.right_bottom.y)}

  local positions = {}

  for y = left_top.y, right_bottom.y - 1 do
    for x = left_top.x, right_bottom.x - 1 do
      table.insert(positions, {x = x + 0.5, y = y + 0.5})
    end
  end

  return positions
end


---@param str string
---@param char string
---@return number
function string.count(str, char)
  local _, count = string.gsub(str, char, "")
  return count
end

---@param custom_event_name string
---@return LuaCustomEventPrototype
function util.get_custom_event(custom_event_name)
  return assert(prototypes.custom_event[mod_prefix_snake_case .. custom_event_name])
end

---@param custom_event_name string
---@return number
function util.get_custom_event_id(custom_event_name)
  log(string.format('Warning: remote.call("space-exploration", "get_%s_event") is deprecated, use defines.events.se_%s instead.', custom_event_name, custom_event_name))
  return util.get_custom_event(custom_event_name).event_id
end

return util
