local util = {}

util.mod_prefix = "se-" -- update strings.cfg
util.mod_prefix_snake_case = "se_"

util.min = math.min
util.max = math.max
util.floor = math.floor
util.abs = math.abs
util.sqrt = math.sqrt
util.sin = math.sin
util.cos = math.cos
util.atan = math.atan
util.atan2 = math.atan2
util.pi = math.pi
util.half_pi = math.pi / 2
util.pi_div_16 = math.pi / 16
util.remove = table.remove
util.insert = table.insert
util.str_gsub = string.gsub
util.max_uint32 = 2^32-1

-- Strings

function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
  return string.sub(String,string.len(String) - string.len(End) + 1)==End
end

function util.replace(str, what, with)
  what = util.str_gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
  with = util.str_gsub(with, "[%%]", "%%%%") -- escape replacement
  str = util.str_gsub(str, what, with)
  return str --only return the first variable from str_gsub
end

-- Tables

function util.remove_from_table(list, item)
  local index = 0
  for k,v in ipairs(list) do
      if item == v then
          index = k
          break
      end
  end
  if index > 0 then
      util.remove(list, index)
  end
end

-- Add table2 at the end of table1
function util.concatenate_tables(table1, table2)
  for _, value in pairs(table2) do
    table.insert(table1, value)
  end
end

function util.table_contains(table, check)
  for k,v in pairs(table) do if v == check then return true end end
  return false
end

---@generic T
---@param t T[]
---@param check T
---@return uint?
function util.find_index_in_array(t, check)
  for k,v in pairs(t) do if v == check then return k end end
end

-- Originally from https://github.com/philanc/plc/blob/master/plc/checksum.lua (MIT License)
-- Adapted for Lua 5.2
-- return crc32 checksum of string as an integer
-- use lookup table lt if provided or create one on the fly
-- if lt is empty, it is initialized.
function util.crc32(s, lt)
  lt = lt or {}
  local b, crc, mask
  if not lt[1] then -- setup table
    for i = 1, 256 do
      crc = i - 1
      for _ = 1, 8 do --eight times
        mask = -bit32.band(crc, 1)
        crc = bit32.bxor(bit32.rshift(crc, 1), bit32.band(0xedb88320, mask))
      end
      lt[i] = crc
    end--for
  end--if
  -- compute the crc
  crc = 0xffffffff
  for i = 1, #s do
    b = string.byte(s, i)
    crc = bit32.bxor(bit32.rshift(crc, 8), lt[bit32.band(bit32.bxor(crc, b), 0xFF) + 1])
  end
  return bit32.band(bit32.bnot(crc), 0xffffffff)
end --crc32()

return util
