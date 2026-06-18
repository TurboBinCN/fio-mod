local Interburbulator = {}
--[[
-- have 4 shield projectors.
-- have 1 laser turet.
-- have n input addon?
A group of 3 bots are on a planet.
Antikythera / Aigilia / Eunomia
Tritan Aurum 1.6180339
Tritan Argent 2.41421356
Tritan Brontion 3.3027756
Plectrum Princeps 2.4450076
Plectrum Aurum 0.6180339
Plectrum Argent 1.41421356
Plectrum Brontion 2.3027756

Brontion Burble 33027756
The bots ask for numbers.
The bots move into a triangle and project a hololographic grid.

Interburbulator bots move to intersection points.

Hovering an Interburbulator makes them say their numbers.

-- The grid resolution is controlled by A coordinate interface.
-- need an associated ruin.
]]
Interburbulator.display_width_tiles = 16

Interburbulator.threshold = 0.000000000000001
Interburbulator.name_interburbulator_gui_root = mod_prefix.."interburbulator-control"
Interburbulator.robot_color = {r=1, g=1, b=1, a=0.1}
Interburbulator.attempts_locked_timeout = 60*15 -- 15 seconds, claimed to reset after 20s but assume lower UPS

Interburbulator.challenges = {
  { -- 1
    grid = 3,
    target = {2,2},
    set = { {1,0,0}, {1,1,0}, {1,0,1}},
    prize = {name = "raw-fish", count = 1},
    attempts = 7,
    success_text_prize = {"space-exploration.interburbulator_success_prize_1"}
  },
  { -- 2
    grid = 4,
    target = {2,3},
    set = { {1,0,0}, {0,1,0}, {0,0,1}},
    prize = {name =  mod_prefix.."machine-learning-data", count = 100},
    attempts = 6,
    success_text_prize = {"space-exploration.interburbulator_success_prize_2"}
  },
  { -- 3
    grid = 5,
    target = {3,1},
    set = { {1,1,1}, {0,1,0}, {0,0,1}},
    prize = {name = mod_prefix.."significant-data", count = 100},
    attempts = 6,
    success_text_prize = {"space-exploration.interburbulator_success_prize_3"}
  },
  { -- 4
    grid = 6,
    target = {4,4},
    set = { {-1,0,0}, {0,1,0}, {0,0,1}},
    prize = {name = "spidertron", count = 1},
    attempts = 5,
    success_text_prize = {"space-exploration.interburbulator_success_prize_4"}
  },
  { -- 5
    grid = 7,
    target = {2,4},
    set = { {1,0,0}, {0,2,0}, {0,0,7}},
    attempts = 5,
    prize = {name = "efficiency-module-9", count = 1},
    success_text_prize = {"space-exploration.interburbulator_success_prize_5"}
  },
  { -- 6
    grid = 8,
    target = {7,7},
    set = { {1,6,1}, {8,0,3}, {3,9,8}},
    prize = {name = "speed-module-9", count = 1},
    attempts = 4,
    success_text_prize = {"space-exploration.interburbulator_success_prize_6"}
  },
  { -- 7
    grid = 10,
    target = {3,6},
    set = { {0.1,0.6,0.1}, {0.8,-0.1,0.3}, {0.3,0.9,0.8}},
    prize = {name = "productivity-module-9", count = 1},
    attempts = 4,
    success_text_prize = {"space-exploration.interburbulator_success_prize_7"}
  },
  { -- 8
    grid = 15,
    target = {13,15},
    set = { {0.87,0.49,0.89}, {0.48,0.48,0.2}, {0.45,0.86,0.83}},
    prize = {name = mod_prefix.."wide-beacon-2", count = 4},
    attempts = 3,
    success_text_prize = {"space-exploration.interburbulator_success_prize_8"}
  },
  { -- 9
    grid = 20,
    target = {17,2},
    set = { {-436,563,-811}, {772,30,917}, {980,576,286}},
    prize = {name = mod_prefix.."naquium-processor", count = 8},
    attempts = 3,
    success_text_prize = {"space-exploration.interburbulator_success_prize_9"}
  },
  { -- 10
    grid = 50,
    target = {33,44},
    set = { {1.618033,0.9887498,0.48204586}, {2.414213,0.5623730,0.9504880}, {3.302775,0.6377319,0.9464655}},
    prize = {name = mod_prefix.."arcosphere", count = 10},
    attempts = 2,
    success_text_prize = {"space-exploration.interburbulator_success_prize_10"}
  },
}
Interburbulator.success_freeplay = {}
for i = 1, 5 do
  table.insert(Interburbulator.success_freeplay, "interburbulator_success_freeplay_"..i)
end
Interburbulator.success_repeat = {}
for i = 1, 6 do
  table.insert(Interburbulator.success_repeat, "interburbulator_success_repeat_"..i)
end
Interburbulator.fail_text = {}
Interburbulator.fail_bad_text = {}
for i = 1, 39 do
  table.insert(Interburbulator.fail_text, "interburbulator_fail_easy_"..i)
end
for i = 1, 10 do
  table.insert(Interburbulator.fail_bad_text, "interburbulator_fail_offgrid_"..i)
end
for i = 1, 9 do
  table.insert(Interburbulator.fail_text, "interburbulator_fail_mixed_"..i)
  table.insert(Interburbulator.fail_bad_text, "interburbulator_fail_mixed_"..i)
end
Interburbulator.locked_text = {}
for i = 1, 6 do
  table.insert(Interburbulator.locked_text, "interburbulator_challenge_locked_"..i)
end

---@param player LuaPlayer
---@param text LocalisedString
function Interburbulator.message(player, text)
  player.print({"space-exploration.interburbulator_speak", text})
end

---@param zone AnyZoneType
---@param position? MapPosition
function Interburbulator.make_interburbulator(zone, position)
  if storage.interburbulator then return end -- don't make 2
  storage.interburbulator = {
    zone = zone,
    position = position or {x=0, y=0},
    challenge_index = 1,
    challenge_set = nil, -- only used when you set a custom/random challenge.
    challenge_grid_size = nil, -- only used when you set a custom/random challenge.
    challenge_cell = nil, -- only used when you set a custom/random challenge.
    guessed_vector = nil, -- shown after a guess
    guessed_position = nil, -- shown after a guess
    guessed_cell = nil, -- shown after a guess
    guessed_player_index = nil,
    shape_ids = {},
    prizes_won = {}, -- could be indexed by player-challenge but for now just challenge
    freeplay_unlocked = false
  }
  zone.interburbulator = storage.interburbulator
  Interburbulator.build_platform()
end

function Interburbulator.build_platform()
  if storage.interburbulator.robot and storage.interburbulator.robot.valid and storage.interburbulator.interface and storage.interburbulator.interface.valid then return end
  local surface = Zone.get_surface(storage.interburbulator.zone)
  if surface then
    surface.request_to_generate_chunks(storage.interburbulator.position)
    surface.force_generate_chunk_requests()
    Ruin.build({ruin_name = "interburbulator-platform", surface_index = surface.index, position = storage.interburbulator.position})
    storage.interburbulator.light = rendering.draw_light{
      sprite = mod_prefix.."interburbulator-light",
      surface = surface,
      target = storage.interburbulator.position,
      intesity = 2,
    }
    storage.interburbulator.grid  = rendering.draw_sprite{
      sprite = mod_prefix.."interburbulator-grid",
      surface = surface,
      target = storage.interburbulator.position,
      tint = {r=0.5,b=0.5,g=0.5},
      draw_on_ground = true,
      alignment = "center"
    }
    storage.interburbulator.robot = surface.find_entities_filtered{name=mod_prefix.."burbulator"}[1]
    storage.interburbulator.interface = surface.find_entities_filtered{name=mod_prefix.."interburbulator-control"}[1]
    storage.interburbulator.robot.color = Interburbulator.robot_color
    storage.interburbulator.robot_text = rendering.draw_text{
      surface = surface,
      target = {entity = storage.interburbulator.robot, offset = {0, -3.5}},
      text = {"space-exploration.interburbulator_robot_name"},
      color = {r=0.6,g=0,b=0},
      alignment = "center"
    }
    game.print({"space-exploration.interburbulator_speak",
      {"space-exploration.interburbulator_greeting",
        Zone.get_print_name(storage.interburbulator.zone),
        Zone.get_print_name(Zone.get_star_from_child(storage.interburbulator.zone))}})
  end
end

function Interburbulator.on_nth_tick_300()
  if storage.interburbulator and storage.interburbulator.robot and storage.interburbulator.robot.valid then
    local orientation = Util.orientation_from_to(storage.interburbulator.position, storage.interburbulator.robot.position) + 0.25 -- why is this 0.25 off?
    if orientation > 0.5 then orientation = orientation - 1 end -- -0.5 to 0.5
    orientation = orientation * 0.8 - 0.2 + 0.4 * math.random()
    local pos = Util.orientation_to_vector(orientation, math.random(12,15))
    storage.interburbulator.robot.autopilot_destination = Util.vectors_add(storage.interburbulator.position, pos)
    if math.random() < 0.1 then
      storage.interburbulator.robot.autopilot_destination = Util.vectors_add(storage.interburbulator.position, {x = 0, y = -10})
    end
    storage.interburbulator.robot.insert({name="rocket", count = 10})
    storage.interburbulator.robot.color = Interburbulator.robot_color
  end
end
Event.addListener("on_nth_tick_300", Interburbulator.on_nth_tick_300) -- 5s

function Interburbulator.clear_display()
  if storage.interburbulator.shape_ids then
    for _, shape_id in pairs(storage.interburbulator.shape_ids) do
      if shape_id.valid then shape_id.destroy() end
    end
  end
  storage.interburbulator.shape_ids = {}
end

---@param challenge_index integer
---@return {attempts:uint, tick:uint}
function Interburbulator.get_attempts(challenge_index)
  storage.interburbulator.challenge_attempts = storage.interburbulator.challenge_attempts or {}
  storage.interburbulator.challenge_attempts[challenge_index] = storage.interburbulator.challenge_attempts[challenge_index] or {
    attempts = 0,
    tick = game.tick
  }
  -- reset
  if storage.interburbulator.challenge_attempts[challenge_index].attempts >= Interburbulator.challenges[challenge_index].attempts and game.tick > storage.interburbulator.challenge_attempts[challenge_index].tick + Interburbulator.attempts_locked_timeout then
    storage.interburbulator.challenge_attempts[challenge_index].attempts = 0
    storage.interburbulator.challenge_attempts[challenge_index].tick = game.tick
  end
  return storage.interburbulator.challenge_attempts[challenge_index]
end

---@param challenge_index integer
function Interburbulator.increase_attempts(challenge_index)
  Interburbulator.get_attempts(challenge_index)
  storage.interburbulator.challenge_attempts[challenge_index].attempts =
    storage.interburbulator.challenge_attempts[challenge_index].attempts + 1
  storage.interburbulator.challenge_attempts[challenge_index].tick = game.tick
end

---@param player? LuaPlayer
function Interburbulator.update(player)
  if not storage.interburbulator then return end
  Interburbulator.clear_display()
  local surface = Zone.get_surface(storage.interburbulator.zone)
  if not surface then return end

  local vs_abc = storage.interburbulator.challenge_set -- vector set: points a, b, and c. Point d is inferred to complete the square
  local cells_w = storage.interburbulator.challenge_grid_size
  local target_cell = storage.interburbulator.challenge_cell
  local width
  if storage.interburbulator.challenge_index then
    vs_abc = Interburbulator.challenges[storage.interburbulator.challenge_index].set
    cells_w = Interburbulator.challenges[storage.interburbulator.challenge_index].grid
    target_cell = Interburbulator.challenges[storage.interburbulator.challenge_index].target
  end

  if cells_w then
    Interburbulator.draw_grid(surface, cells_w)
    width = Interburbulator.display_width_tiles * cells_w/(cells_w+2)
    if target_cell then
      local box = {
        {(target_cell[1]-1)/cells_w, (target_cell[2]-1)/cells_w},
        {target_cell[1]/cells_w, target_cell[2]/cells_w}
      }
      table.insert(storage.interburbulator.shape_ids, rendering.draw_rectangle{
        surface = surface,
        color = {r=0.4,b=0,g=0,a=0.4},
        filled = true,
        left_top = { x = storage.interburbulator.position.x -width/2 + box[1][1] * width, y = storage.interburbulator.position.y -width/2 + box[1][2] * width },
        right_bottom = { x = storage.interburbulator.position.x -width/2 + box[2][1] * width, y = storage.interburbulator.position.y -width/2 + box[2][2] * width },
        draw_on_ground = true,
      })
    end
  else
    return
  end

  local v_e = storage.interburbulator.guessed_vector
  if v_e and v_e[1] == 0 and v_e[2] == 0 and v_e[3] == 0 then
    v_e = nil
  end
  if not (vs_abc and v_e) then return end

  local v_a2b = {} -- a to b
  local v_a2c = {} -- a to c
  local n_e = Util.nvector_normalise(v_e) -- the normal of point e

  local v_bc = {} -- the bc midpoint
  local v_abc = {} -- the abc midpoint
  for i = 1, #v_e do
    v_bc[i] = (vs_abc[2][i]+vs_abc[3][i])/2
    v_a2b[i] = vs_abc[2][i]-vs_abc[1][i]
    v_a2c[i] = vs_abc[3][i]-vs_abc[1][i]
    v_abc[i] = (vs_abc[1][i] + vs_abc[2][i] + vs_abc[3][i]) / 3
  end

  local n_abc = Util.nvector_normalise(v_abc) -- the normal of the abc mid point

  local n_abc_cross = Util.vector_cross(v_a2b, v_a2c)
  local n_abc_cross = {n_abc_cross.x, n_abc_cross.y, n_abc_cross.z}

  -- m_i: the magnitude multiplier for vector e where it would intersect with the abc plane
  local m_i = Util.nvector_dot(n_abc_cross, Util.nvector_multiply(vs_abc[1], -1)) / Util.nvector_dot(Util.nvector_multiply(v_e, -1), n_abc_cross)

  local v_i = Util.nvector_multiply(v_e, m_i) -- i, the point on the abc plane where e intersects

  local v_a2i = {} -- bc_mid to a
  local v_bc2a = {} -- bc_mid to a
  local v_bc2b = {} -- bc_mid to b (to c is negative this vector)
  local v_bc2i = {} -- bc_mid to the i intersection
  for i = 1, #v_e do
    v_a2i[i] = v_i[i]-vs_abc[1][i]
    v_bc2a[i] = vs_abc[1][i]-v_bc[i]
    v_bc2b[i] = vs_abc[2][i]-v_bc[i]
    v_bc2i[i] = v_i[i]-v_bc[i]
  end

  -- need to de-skew the space
  local sets = {{1,2},{1,3},{2,3}}
  local mi_a2b
  local mi_a2c
  for _, set in pairs(sets) do
    local u = set[1]
    local v = set[2]
    if mi_a2b == nil or tostring(mi_a2b) == "nan" then
      mi_a2b = (v_a2i[v]*v_a2c[u]-v_a2i[u]*v_a2c[v])/(v_a2c[u]*v_a2b[v]-v_a2c[v]*v_a2b[u])
    end
    if mi_a2c == nil or tostring(mi_a2c) == "nan"  then
      mi_a2c = (v_a2i[v]*v_a2b[u]-v_a2i[u]*v_a2b[v])/(v_a2b[u]*v_a2c[v]-v_a2b[v]*v_a2c[u])
    end
  end

  local cursor_point_2d = {
    mi_a2b,
    mi_a2c,
  }
  -- handle innacuracy
  if cursor_point_2d[1] < 0 and cursor_point_2d[1] > -Interburbulator.threshold then
    cursor_point_2d[1] = 0
  end
  if cursor_point_2d[2] < 0 and cursor_point_2d[2] > -Interburbulator.threshold then
    cursor_point_2d[2] = 0
  end

  local best_box
  local best_cell
  for k = 0, cells_w do
    for j = 0, cells_w do
      local  box
      if not best_box then
        box = {{k/cells_w, j/cells_w}, {(k+1)/cells_w, (j+1)/cells_w}}
        if cursor_point_2d[1] >= box[1][1]
          and cursor_point_2d[1] <= box[2][1]
          and cursor_point_2d[2] >= box[1][2]
          and cursor_point_2d[2] <= box[2][2] then
            best_box = box
            best_cell = {k+1, j+1}
        end
      end
    end
  end

  local challenge_index = storage.interburbulator.challenge_index
  local attempts = 0
  local allow = true
  if challenge_index then
    attempts = Interburbulator.get_attempts(challenge_index).attempts
    if attempts >= Interburbulator.challenges[challenge_index].attempts then
      allow = false
      if player then
        Interburbulator.message(player, {"space-exploration."..Interburbulator.locked_text[math.random(#Interburbulator.locked_text)]})
      end
    end
  end
  if allow then
    if cursor_point_2d and cursor_point_2d[1] > -0.1 and cursor_point_2d[1] < 1.1
      and cursor_point_2d[2] > -0.1 and cursor_point_2d[2] < 1.1 then
      table.insert(storage.interburbulator.shape_ids, rendering.draw_circle{
        surface = surface,
        color = {r=1,b=0,g=1},
        filled = true,
        radius = 0.2,
        target = {x = storage.interburbulator.position.x -width/2 + width * cursor_point_2d[1], y = storage.interburbulator.position.y -width/2 + width * cursor_point_2d[2]},
        draw_on_ground = true,
      })
    end
    if best_box then
      table.insert(storage.interburbulator.shape_ids, rendering.draw_rectangle{
        surface = surface,
        color = {r=0.4,b=0,g=0.4,a=0.4},
        filled = true,
        left_top = { x = storage.interburbulator.position.x -width/2 + best_box[1][1] * width, y = storage.interburbulator.position.y -width/2 + best_box[1][2] * width },
        right_bottom = { x = storage.interburbulator.position.x -width/2 + best_box[2][1] * width, y = storage.interburbulator.position.y -width/2 + best_box[2][2] * width },
        draw_on_ground = true,
      })
      table.insert(storage.interburbulator.shape_ids, rendering.draw_rectangle{
        surface = surface,
        color = {r=1,b=0,g=1,a=0.4},
        filled = false,
        left_top = { x = storage.interburbulator.position.x -width/2 + best_box[1][1] * width, y = storage.interburbulator.position.y -width/2 + best_box[1][2] * width },
        right_bottom = { x = storage.interburbulator.position.x -width/2 + best_box[2][1] * width, y = storage.interburbulator.position.y -width/2 + best_box[2][2] * width },
        draw_on_ground = true,
      })
    end
    if player and storage.interburbulator.challenge_index then
      if best_cell and target_cell and best_cell[1] == target_cell[1] and best_cell[2] == target_cell[2] then
        storage.interburbulator.prizes_won = storage.interburbulator.prizes_won or {}
        if not storage.interburbulator.prizes_won[storage.interburbulator.challenge_index] then
          storage.interburbulator.prizes_won[storage.interburbulator.challenge_index] = player.index
          local prize = Interburbulator.challenges[storage.interburbulator.challenge_index].prize
          local inserted = 0
          if player.character and player.character.surface == surface then
            inserted = player.insert(prize)
          end
          local remain = (prize.count or 1) - inserted
          if remain > 0 then
            surface.spill_item_stack{
              position = Util.vectors_add({x=0,y=2.25}, storage.interburbulator.interface.position),
              stack = {name = prize.name, count = remain},
              enable_looted = true,
              force = player.force,
              allow_belts = false
            }
          end
          Interburbulator.message(player, {
            "space-exploration.simple-a-b-space",
            Interburbulator.challenges[storage.interburbulator.challenge_index].success_text_prize or Interburbulator.success_text_prize,
            {"space-exploration.simple-a-b-space", (prize.count or 1) .." [img=item/"..prize.name.."] ", {"item-name."..prize.name}}
          })
        else
          Interburbulator.message(player, {"space-exploration."..Interburbulator.success_repeat[math.random(#Interburbulator.success_repeat)]})
        end
        if table_size(storage.interburbulator.prizes_won) >= 5 and not storage.interburbulator.freeplay_unlocked then
          storage.interburbulator.freeplay_unlocked = true
          Interburbulator.message(player, {"space-exploration.interburbulator_freeplay_unlocked"})
        end
      else
        Interburbulator.increase_attempts(storage.interburbulator.challenge_index)
        if best_box then
          Interburbulator.message(player, {"space-exploration."..Interburbulator.fail_text[math.random(#Interburbulator.fail_text)]})
        else
          Interburbulator.message(player, {"space-exploration."..Interburbulator.fail_bad_text[math.random(#Interburbulator.fail_bad_text)]})
        end

        if player and challenge_index then
          attempts = Interburbulator.get_attempts(challenge_index).attempts
          if attempts >= Interburbulator.challenges[challenge_index].attempts then
            Interburbulator.message(player, {"space-exploration."..Interburbulator.locked_text[math.random(#Interburbulator.locked_text)]})
          end
        end

      end
    end
  end
end

---@param surface LuaSurface
---@param cells_w integer
function Interburbulator.draw_grid(surface, cells_w)
  local pos = storage.interburbulator.position
  local width = Interburbulator.display_width_tiles * cells_w/(cells_w+2)
  for i = 1, cells_w+1 do
    local p = (i-1)/(cells_w)
    table.insert(storage.interburbulator.shape_ids, rendering.draw_line{
      surface = surface,
      from = {x = pos.x - width/2, y = pos.y - width/2 + p * width},
      to = {x = pos.x + width/2, y = pos.y - width/2 + p * width},
      color = {r=0.5,b=0,g=0,a=0.5},
      width = 1,
      draw_on_ground = true
    })
    table.insert(storage.interburbulator.shape_ids, rendering.draw_line{
      surface = surface,
      from = {x = pos.x - width/2 + p * width, y = pos.y - width/2},
      to = {x = pos.x - width/2 + p * width, y = pos.y + width/2},
      color = {r=0.5,b=0,g=0,a=0.5},
      width = 1,
      draw_on_ground = true
    })
  end
end

---@param player LuaPlayer
function Interburbulator.gui_close(player)
  local gui = player.gui.screen
  local root = gui[Interburbulator.name_interburbulator_gui_root]
  if root then root.destroy() end
end

---@param player LuaPlayer
function Interburbulator.gui_update(player)
  local root = player.gui.screen[Interburbulator.name_interburbulator_gui_root]
  if not root then return end

  local vs_abc = storage.interburbulator.challenge_set
  local cells_w = storage.interburbulator.challenge_grid_size
  local target_cell = storage.interburbulator.challenge_cell
  if storage.interburbulator.challenge_index then
    vs_abc = Interburbulator.challenges[storage.interburbulator.challenge_index].set
    cells_w = Interburbulator.challenges[storage.interburbulator.challenge_index].grid
    target_cell = Interburbulator.challenges[storage.interburbulator.challenge_index].target
  end
  if target_cell then
    target_cell = target_cell[1]..","..target_cell[2]
  end

  local challenge = util.find_first_descendant_by_name(root, "challenges")
  local active_name
  --if storage.interburbulator.challenge_set then active_name = "challenge_random" end -- need to be able to click multiple times
  if storage.interburbulator.challenge_index then active_name = "challenge_"..storage.interburbulator.challenge_index end
  for _, button in pairs(challenge.children) do
    button.enabled = true
    if button.name == active_name then
      button.enabled = false
    end
  end

  if cells_w then util.find_first_descendant_by_name(root, "grid_textbox").text = ""..cells_w end
  if target_cell then util.find_first_descendant_by_name(root, "target_textbox").text = ""..target_cell end
  local prize_lab = util.find_first_descendant_by_name(root, "prize_lab")
  if prize_lab then
    if storage.interburbulator.challenge_index then
      local prize = Interburbulator.challenges[storage.interburbulator.challenge_index].prize
      local claimed = storage.interburbulator.prizes_won and storage.interburbulator.prizes_won[storage.interburbulator.challenge_index]
      local caption = {
        "space-exploration.interburbulator_caption_prize",
        (prize.count or 1),
        "[img=item/"..prize.name.."]",
        {"item-name."..prize.name},
        claimed and {"", " ", {"space-exploration.interburbulator_caption_claimed"}} or ""
      }
      prize_lab.caption = caption
    else
      prize_lab.caption = ""
    end
  end

  if vs_abc then
    local top_left = util.find_first_descendant_by_name(root, "top_left")
    top_left.x.textbox.text = ""..vs_abc[1][1]
    top_left.y.textbox.text = ""..vs_abc[1][2]
    top_left.z.textbox.text = ""..vs_abc[1][3]

    local top_right = util.find_first_descendant_by_name(root, "top_right")
    top_right.x.textbox.text = ""..vs_abc[2][1]
    top_right.y.textbox.text = ""..vs_abc[2][2]
    top_right.z.textbox.text = ""..vs_abc[2][3]

    local bottom_left = util.find_first_descendant_by_name(root, "bottom_left")
    bottom_left.x.textbox.text = ""..vs_abc[3][1]
    bottom_left.y.textbox.text = ""..vs_abc[3][2]
    bottom_left.z.textbox.text = ""..vs_abc[3][3]
  end

  if storage.interburbulator.challenge_index then
    local attempts = Interburbulator.get_attempts(storage.interburbulator.challenge_index).attempts
    local attempts_max = Interburbulator.challenges[storage.interburbulator.challenge_index].attempts
    if attempts < attempts_max then
      util.find_first_descendant_by_name(root, "attempt").caption = {"space-exploration.interburbulator_attempt_limited", attempts, attempts_max }
    else
      util.find_first_descendant_by_name(root, "attempt").caption = {"space-exploration.interburbulator_attempt_locked"}
    end
  else
    util.find_first_descendant_by_name(root, "attempt").caption = {"space-exploration.interburbulator_attempt"}
  end

  if storage.interburbulator.guessed_vector then
    local attempt = util.find_first_descendant_by_name(root, "attempt")
    if attempt.x.textbox.text == "" then attempt.x.textbox.text = ""..storage.interburbulator.guessed_vector[1] end
    if attempt.y.textbox.text == "" then attempt.y.textbox.text = ""..storage.interburbulator.guessed_vector[2] end
    if attempt.z.textbox.text == "" then attempt.z.textbox.text = ""..storage.interburbulator.guessed_vector[3] end
  end

  local challenge_random = util.find_first_descendant_by_name(root, "challenge_random")
  if challenge_random then
    challenge_random.caption = {storage.interburbulator.freeplay_unlocked and "space-exploration.interburbulator_freeplay" or "space-exploration.interburbulator_random"}
  end

end

--- unused
---@param element LuaGuiElement
---@param enabled boolean
function Interburbulator.enable_textfields(element, enabled)
  if element.type == "textfield" then
    element.enabled = enabled
  else
    for _, child in pairs(element.children) do
      if child.name ~= "attempt" then
        Interburbulator.enable_textfields(child, enabled)
      end
    end
  end
end

---@param player LuaPlayer
function Interburbulator.gui_open(player)
  Interburbulator.gui_close(player)
  local gui = player.gui.screen

  local container = gui.add{ type = "frame", name = Interburbulator.name_interburbulator_gui_root, direction="vertical"}
  player.opened = container

  local title_flow = container.add{ type="flow", name="unit_number", direction="horizontal"}
  local title = title_flow.add{ type="label", name="title", caption={"space-exploration.interburbulator_game_title"}, style="heading_1_label"}
  title.ignored_by_interaction = true

  -- Trying to make the fancy "Drag me" vertical bars...
  local drag_handle = title_flow.add{type = "empty-widget", style = "draggable_space_header", direction="horizontal"}
  drag_handle.drag_target = container
  drag_handle.style.minimal_width = 20
  drag_handle.style.horizontally_stretchable = true
  drag_handle.style.vertically_stretchable = true

  local close = title_flow.add{type="sprite-button", name=mod_prefix .. "-interburbulator-close", sprite = "utility/close", style="informatron_close_button"}
  close.style.width = 28
  close.style.height = 28
  close.style.top_margin = 0

  local intro = container.add{type="label", name="intro", caption={"space-exploration.interburbulator_introduction"}}
  intro.style.single_line = false
  intro.style.width = 500
  intro.style.top_margin = 10
  intro.style.bottom_margin = 10

  local challenges = container.add{type="flow", name="challenges", direction="horizontal"}
  challenges.style.bottom_margin = 10
  for i = 1, 10 do
    local button = challenges.add{type = "button", name = "challenge_"..i, caption = i}
    button.style.minimal_width = 32
  end
  local button = challenges.add{type = "button", name = "challenge_random", caption = {
    storage.interburbulator.freeplay_unlocked and "space-exploration.interburbulator_freeplay" or "space-exploration.interburbulator_random"
  }}

  local grid = container.add{type="flow", name="grid_target", direction="horizontal"}
  grid.style.vertical_align = "center"
  local grid_lab = grid.add{type="label", name="grid_lab", caption={"space-exploration.interburbulator_grid_size"}}
  local grid_textbox = grid.add{type="textfield", name="grid_textbox", numeric = true, allow_decimal = false, allow_negative = false}
  grid_textbox.style.width = 100
  local target_lab = grid.add{type="label", name="target_lab", caption={"space-exploration.interburbulator_target_cell"}}
  target_lab.style.left_margin = 10
  local target_textbox = grid.add{type="textfield", name="target_textbox"}
  target_textbox.style.width = 100

  local settings_flow1 = container.add{type = "flow", name="settings_flow1", direction = "horizontal"} settings_flow1.style.top_margin = 10
  local settings_flow2 = container.add{type = "flow", name="settings_flow2", direction = "horizontal"}

  local top_left = settings_flow1.add{type = "frame", name="top_left", direction="vertical", caption = {"space-exploration.interburbulator_top_left"}} top_left.style.width = 250
  local top_right = settings_flow1.add{type = "frame", name="top_right", direction="vertical", caption = {"space-exploration.interburbulator_top_right"}} top_right.style.width = 250
  local bottom_left = settings_flow2.add{type = "frame", name="bottom_left", direction="vertical", caption = {"space-exploration.interburbulator_bottom_left"}} bottom_left.style.width = 250
  local attempt = settings_flow2.add{type = "frame", name="attempt", direction="vertical", caption = {"space-exploration.interburbulator_attempt"}} attempt.style.width = 250

  for _, frame in pairs({top_left, top_right, bottom_left, attempt}) do
    local x = frame.add{type="flow", name="x", direction="horizontal"} x.add{type="label", name="lab", caption="X: "} x.add{type="textfield", name="textbox", numeric = true, allow_decimal = true, allow_negative = true}
    local y = frame.add{type="flow", name="y", direction="horizontal"} y.add{type="label", name="lab", caption="Y: "} y.add{type="textfield", name="textbox", numeric = true, allow_decimal = true, allow_negative = true}
    local z = frame.add{type="flow", name="z", direction="horizontal"} z.add{type="label", name="lab", caption="Z: "} z.add{type="textfield", name="textbox", numeric = true, allow_decimal = true, allow_negative = true}
  end

  local bottom_table = container.add{ type="table", name="bottom_table", column_count=2, draw_horizontal_lines=false}
  bottom_table.style.horizontally_stretchable = true
  bottom_table.style.vertical_align = "bottom"
  bottom_table.style.column_alignments[1] = "left" -- title, search, zone list table
  bottom_table.style.column_alignments[2] = "right" -- starmap, close, selected zone info

  local prize_lab = bottom_table.add{type="label", name="prize_lab"}
  prize_lab.style.horizontally_stretchable = true

  local submit = bottom_table.add{type="button", name=mod_prefix .. "-interburbulator-submit", style="confirm_button", caption={"space-exploration.interburbulator_submit"}}
  submit.style.top_margin = 10

  --Interburbulator.enable_textfields(container, false)
  Interburbulator.gui_update(player)

  player.play_sound{path = "entity-open/constant-combinator"}

  --container.force_auto_center()
end

---@param player LuaPlayer
---@param skip_warnings? boolean
function Interburbulator.submit(player, skip_warnings)
  local root = player.gui.screen[Interburbulator.name_interburbulator_gui_root]
  if not root then return end

  if storage.interburbulator.freeplay_unlocked and not storage.interburbulator.challenge_index then
    Interburbulator.challenge_from_gui(player)
  end

  local attempt = util.find_first_descendant_by_name(root, "attempt")
  local attempt_x = tonumber(attempt.x.textbox.text)
  local attempt_y = tonumber(attempt.y.textbox.text)
  local attempt_z = tonumber(attempt.z.textbox.text)
  if attempt_x and attempt_y and attempt_z and not(attempt_x==0 and attempt_y==0 and attempt_z==0) then
    storage.interburbulator.guessed_vector = {attempt_x,attempt_y,attempt_z} -- shown after a guess
  else
    if not skip_warnings then
      Interburbulator.message(player, "Invalid attempt vector")
    end
  end
  storage.interburbulator.guessed_player_index = player.index

  Interburbulator.update(player)
  Interburbulator.gui_update(player)
end

---@param challenge_index integer
---@param player LuaPlayer
function Interburbulator.activate_challenge(challenge_index, player)
  storage.interburbulator.guessed_vector = nil
  storage.interburbulator.guessed_position = nil
  storage.interburbulator.guessed_cell = nil
  storage.interburbulator.guessed_player_index = nil
  if Interburbulator.challenges[challenge_index] then
    storage.interburbulator.challenge_index = challenge_index
    storage.interburbulator.challenge_set = nil
    storage.interburbulator.challenge_grid_size = nil
    storage.interburbulator.challenge_cell = nil
  else -- assume random
    storage.interburbulator.challenge_index = nil
    storage.interburbulator.challenge_grid_size = math.random(5,50)
    storage.interburbulator.challenge_cell = {math.random(2,storage.interburbulator.challenge_grid_size-1), math.random(2,storage.interburbulator.challenge_grid_size-1)}

    local multiplier = 1
    if math.random() < 0.23 then
      multiplier = math.random() * 1000
    end
    storage.interburbulator.challenge_set = {
      {(-1+math.random()*2) *multiplier,(-1+math.random()*2) *multiplier,(-1+math.random()*2) *multiplier},
      {(-1+math.random()*2) *multiplier,(-1+math.random()*2) *multiplier,(-1+math.random()*2) *multiplier},
      {(-1+math.random()*2) *multiplier,(-1+math.random()*2) *multiplier,(-1+math.random()*2) *multiplier},
    }
  end
  Interburbulator.update(player)
  Interburbulator.gui_update(player)
end

---@param player LuaPlayer
function Interburbulator.challenge_from_gui(player)
  local root = player.gui.screen[Interburbulator.name_interburbulator_gui_root]
  if not root then return end

  local grid_textbox = util.find_first_descendant_by_name(root, "grid_textbox")
  local target_textbox = util.find_first_descendant_by_name(root, "target_textbox")
  local top_left = util.find_first_descendant_by_name(root, "top_left")
  local top_right = util.find_first_descendant_by_name(root, "top_right")
  local bottom_left = util.find_first_descendant_by_name(root, "bottom_left")

  ---@param inp? string
  ---@return number
  local function number_or_random(inp)
    return tonumber(inp) or math.random()
  end
  storage.interburbulator.challenge_set = {
    {number_or_random(top_left.x.textbox.text),number_or_random(top_left.y.textbox.text),number_or_random(top_left.z.textbox.text)},
    {number_or_random(top_right.x.textbox.text),number_or_random(top_right.y.textbox.text),number_or_random(top_right.z.textbox.text)},
    {number_or_random(bottom_left.x.textbox.text),number_or_random(bottom_left.y.textbox.text),number_or_random(bottom_left.z.textbox.text)},
  }

  local cells_w = tonumber(grid_textbox.text) or 5
  cells_w = math.min(50, math.max(5, cells_w))
  storage.interburbulator.challenge_grid_size = cells_w
  local target_cell = target_textbox.text
  local parts = Util.split(target_cell, ",")
  local x = 2
  local y = 2
  if #parts == 2 then
    x = math.min(cells_w, math.max(1, Util.string_to_number(parts[1]) or 2))
    y = math.min(cells_w, math.max(1, Util.string_to_number(parts[2]) or 2))
  end
  storage.interburbulator.challenge_cell = {x, y}
end

---@param event EventData.on_gui_click Event data
function Interburbulator.on_gui_click(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, Interburbulator.name_interburbulator_gui_root)
  if element.parent and element.parent.name == "challenges" then
    if element.name == "challenge_random" then
      Interburbulator.activate_challenge("random", player)
    else
      local challenge_index = Util.string_to_number(Util.replace(element.name, "challenge_", ""))
      Interburbulator.activate_challenge(challenge_index, player)
    end
  elseif element.name == mod_prefix .. "-interburbulator-close" then
    Interburbulator.gui_close(player)
  elseif element.name == mod_prefix .. "-interburbulator-submit" then
    Interburbulator.submit(player)
  end
end
Event.addListener(defines.events.on_gui_click, Interburbulator.on_gui_click)

---@param event EventData.on_gui_opened Event data
function Interburbulator.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if event.entity and event.entity.valid and event.entity.name == mod_prefix.."interburbulator-control" then
    player.opened = nil
    if player.character and player.character.surface == event.entity.surface and Util.vectors_delta_length(player.character.position, event.entity.position) < 5 then
      Interburbulator.gui_open(player)
      Interburbulator.update() --Interburbulator.update(player)
    else
      player.create_local_flying_text{
        position = event.entity.position,
        text = {"space-exploration.out_of_reach"},
      }
    end
  end
end
Event.addListener(defines.events.on_gui_opened, Interburbulator.on_gui_opened)

---@param event EventData.on_gui_text_changed Event data
function Interburbulator.on_gui_text_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, Interburbulator.name_interburbulator_gui_root)
  if not (root and storage.interburbulator) then return end
  if element.parent and element.parent.parent and element.parent.parent.name == "attempt" then
    -- always allowed
  else
    if not storage.interburbulator.freeplay_unlocked then
      Interburbulator.message(player, {"space-exploration.interburbulator_deny_freeplay_"..(event.tick%6+1)})
      Interburbulator.gui_update(player)
    end
  end
end
Event.addListener(defines.events.on_gui_text_changed, Interburbulator.on_gui_text_changed)

---@param event EventData.on_gui_confirmed Event data
function Interburbulator.on_gui_confirmed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  ---@cast player -?
  local root = gui_element_or_parent(element, Interburbulator.name_interburbulator_gui_root)
  if not (root and storage.interburbulator) then return end
  Interburbulator.submit(player, true)
end
Event.addListener(defines.events.on_gui_confirmed, Interburbulator.on_gui_confirmed)

return Interburbulator
