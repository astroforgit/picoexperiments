pico-8 cartridge // http://www.pico-8.com
version 5
__lua__
--     copyright (c) 2015
--        chris dawson
--    all rights reserved
--
--    (www.chrisdawson.ca)
--

function is_even(v)
  local h = v/2
  return (h == flr(h))
end

function v2_equal(a,b)
  return (a[1] == b[1]) and (a[2] == b[2])
end

function print_center(s, y, colr)
  local x = #s / 2 * 4
  print(s,64-x,y,colr)
end

function print_right(s, x, y, colr)
  print(s,x-(#s * 4),y,colr)
end

function grid_2_pixel(c, p, offset)
  offset = offset or {0,0}
  p[1] = -19 + (c[1] * 11) + offset[1]
  p[2] = 6 + (c[2] * 12) + offset[2]
end

function pixel_2_grid(p, c, offset)
  offset = offset or {0,0}
  c[1] = flr((p[1] + 19 + offset[1]) / 11)
  c[2] = flr((p[2] - 6 + offset[2]) / 12)
end

function set_grid_cell(c, dir, blocked)
  local dirbit = 2^dir
  grid[c[2]][c[1]] = (blocked) and (bor(grid[c[2]][c[1]], dirbit)) or (band(grid[c[2]][c[1]], bnot(dirbit)))
end

function get_speed(sfx)
  return peek(0x3200 + 68*sfx + 65)
end

function set_speed(sfx, speed)
  poke(0x3200 + 68*sfx + 65, speed)
end

function add_score(score, value)
  score[2] = score[2] + value
  if (score[2] >= 1000) then
    local t = flr(score[2] / 1000)
    score[2] = score[2] - t * 1000
    score[1] = score[1] + t
  end
end

function _fscore(s)
  local r = ""
  for i=1,3-#s do r = r .. "0" end
  return r .. s
end

function format_score(score)
  return _fscore("" .. score[1]) .. _fscore("" .. score[2])
end

-- maps
--
num_maps = 12

level = 0
ready_level = nil
game_over = nil
screen = 0
p1_hscore = {0,0}
p2_hscore = {0,0}
doublescore = false
multiplier = 1
grid = {}
keep_door_open = false
door_open = false
door_left = {1,3}
door_right = {13,3}
msg = "radar"
entity_offset = {2,3}

players = {}
monsters = {}
stars = {} -- of {x,y,color}
ctrls = {}

tempo = {spd=175,min=175,max=15,cnt=0,sound=11}
speed = 0.125

-- animation {hs,vs,a,delay,sound}
--   a: frame sequence; use frame# -1 to stop playback
--   delay: #updates per frame (30 updates / sec)
-- state {animation, frame, delay}
sprite = {}

pts = {
  beast=100,
  lizard=200,
  manticore=500,
  warrior=1000,
  imp=1000,
  wizard=2500
}

-- character sprite flags:
-- bit 0: true == facing left
--
-- dir {0,1,2,3} == left,right,up,down

function new_sprite(_sprite, _cell, _points, _speed)
  local p = {0,0}
  grid_2_pixel(_cell, p, entity_offset)
  return {
    sprite = _sprite,
    state = {nil,0,0},
    cell = {_cell[1],_cell[2]},
    cell_default = {_cell[1], _cell[2]},
    pos = p,
    points = _points,
    speed = _speed or 1,
    max_speed = 3,
  }
end

-- call with sprite.laser1 or sprite.laser2
function new_laser(_sprite, _parent, _pos, _dir, _speed)
  local c = {0,0}
  pixel_2_grid(_pos, c, {3,3})
  return {
    sprite = _sprite,
    parent = _parent,
    state = {nil,0,0},
    cell = c,
    pos = {_pos[1], _pos[2]},
    dir = _dir,
    steer = _dir,
    speed = _speed or 6,
    max_speed = 6,
    is_laser = true,
  }
end

function set_cell(e, cell)
  local c = cell or e.cell_default
  if c then
    e.cell[1] = c[1]
    e.cell[2] = c[2]
    grid_2_pixel(c, e.pos, entity_offset)
  end
end

timers = {}
processing_timers = false
function clear_timers()
  if (processing_timers) then assert() end
  timers = {}
end
function add_timer_secs(nsec, clbk, times)
  add_timer(nsec*30, clbk, times)
end
function add_timer(cnt, clbk, times)
  timers[#timers+1] = {cnt, cnt, clbk, times}
end
function update_timers()
  processing_timers = true
  local i = 1
  while (i <= #timers) do
    if (timers[i]) then
      timers[i][2] -= 1
      if (timers[i][2] <= 0) then
        timers[i][3]()
        if (timers[i][4]) then timers[i][4] -= 1 end
        if (timers[i][4]) and (timers[i][4] <= 0) then
          timers[i] = timers[#timers]
          timers[#timers] = nil
          i -= 1
        else
          timers[i][2] = timers[i][1] -- reset the timer
        end
      end
    end
    i += 1
  end
  processing_timers = false
end

function draw_stars()
  for s in all(stars) do
    if rnd(1) < 0.05 then
      s[3] = 5 + flr(rnd(2)) -- color 5-6
    end
    line(s[1],s[2],s[1],s[2],s[3])
  end
end

function draw_bgnd()
  rectfill(0,0,127,127,0)
  draw_stars()
  spr(96,4,0,15,2) -- marquee
end

function draw_map(colr)
  local cell
  local neighbor
  local p = {0,0}
  for row = 1,7 do
    for col = 1,13 do
      grid_2_pixel({col,row}, p)
      cell = grid[row][col]
      neighbor = (col > 1) and (grid[row][col-1]) or (nil)
      if (band(cell, 1) == 1) and ((not neighbor) or (band(neighbor,2) == 2)) then
        line(p[1],p[2],p[1],p[2]+12,colr)
      end
      neighbor = (col < 13) and (grid[row][col+1]) or (nil)
      if (band(cell, 2) == 2) and ((not neighbor) or (band(neighbor,1) == 1)) then
        line(p[1]+11,p[2],p[1]+11,p[2]+12,colr)
      end
      neighbor = (row > 1) and (grid[row-1][col]) or (nil)
      if (band(cell, 4) == 4) and ((not neighbor) or (band(neighbor,8) == 8)) then
        line(p[1],p[2],p[1]+11,p[2],colr)
      end
      neighbor = (row < 7) and (grid[row+1][col]) or (nil)
      if (band(cell, 8) == 8) and ((not neighbor) or (band(neighbor,4) == 4)) then
        line(p[1],p[2]+12,p[1]+11,p[2]+12,colr)
      end
    end
  end

  if door_open then
    spr(17,-4,45,1,1,not fget(17,0))
    spr(17,124,45,1,1,fget(17,0))
  end
end

-- 2x2 cells with 1 pxl spacing
function draw_radar()
  rect(63-17,102,63+18,102+20,1) -- 14x11 cells
end

function draw_radar_entity(e)
  if e and e.sprite then
    local p = {e.cell[1], e.cell[2]}
    p[1] = ((p[1]-2)*3)+1
    p[2] = ((p[2]-1)*3)+1
    rect(63-16+p[1],103+p[2],63-16+p[1]+1,103+p[2]+1,e.sprite.colr)
  end
end

function draw_score()
  rectfill(0,103,32,115,sprite.warrior_blue.colr)
  rectfill(3,106,29,112,0)
  print(format_score(players[2].score),5,107,sprite.warrior_blue.colr)
  rectfill(95,103,127,115,sprite.warrior_yellow.colr)
  rectfill(98,106,124,112,0)
  print(format_score(players[1].score),100,107,sprite.warrior_yellow.colr)
end

function _draw_lives(p, sprite)
  local pos = {0,0}
  grid_2_pixel(p.cell_default, pos, entity_offset)
  if (p.lives > 0) then
    local s = sprite.hs
    if p == players[1] then
      spr(s,pos[1],pos[2],1,1,not fget(s,0))
      if (p.door_closed_in and p.door_closed_in > 0 and p.door_closed_in < 6) then
        print("(" .. p.door_closed_in .. ")", pos[1]-16, pos[2]+2, sprite.colr)
      elseif (p.lives > 1) then
        print("" .. p.lives .. " x", pos[1]-16, pos[2]+2, sprite.colr)
      end
    else
      spr(s,pos[1],pos[2],1,1,fget(s,0))
      if (p.door_closed_in and p.door_closed_in > 0 and p.door_closed_in < 6) then
        print("(" .. p.door_closed_in .. ")", pos[1]+13, pos[2]+2, sprite.colr)
      elseif (p.lives > 1) then
        print("x " .. p.lives, pos[1]+13, pos[2]+2, sprite.colr)
      end
    end
  end
end

function draw_lives()
  _draw_lives(players[1], sprite.warrior_yellow)
  _draw_lives(players[2], sprite.warrior_blue)
end

function draw_msg(name)
  msg = (doublescore) and "double score" or name or msg
  print_center(msg,95,10)
end

function draw_entities()
  for i=1,#monsters do
    draw_entity(monsters[i].laser)
    if (not monsters[i].invisible or can_see(monsters[i], players[1]) or can_see(monsters[i], players[2])) then draw_entity(monsters[i]) end
    draw_radar_entity(monsters[i])
  end

  for i=1,2 do
    draw_entity(players[i].laser)
    draw_entity(players[i])
  end
end

function draw_entity(e)
  if (e and e.pos ~= nil) then
    local hs = e.sprite and e.sprite.hs
    local vs = e.sprite and e.sprite.vs
    local s_offset = 0
    local anim = e.state
    if (anim[1] ~= nil and anim[1].a[anim[2]] ~= -1) then
      hs = anim[1].hs
      vs = anim[1].vs
      s_offset = anim[1].a[anim[2]]
    end
    if (hs) then
      local flipx = false
      local flipy = false
      local s = hs + s_offset
      if (vs) then
        if ((e.dir == 2) or (e.dir == 3)) then s = vs + s_offset end
        flipx = ((e.dir == 0) and not fget(s,0)) or ((e.dir == 1) and fget(s,0))
        flipy = ((e.dir == 2) and not fget(s,0)) or ((e.dir == 3) and fget(s,0))
      end
      spr(s,e.pos[1],e.pos[2],1,1,flipx,flipy)
    end
  end
end

function door(open)
  door_open = open
  set_grid_cell({1,3}, 1, not open)
  set_grid_cell({2,3}, 0, not open)
  set_grid_cell({12,3}, 1, not open)
  set_grid_cell({13,3}, 0, not open)
end

function dist2target(start_cell, target_cell)
  local dx = abs(start_cell[1] - target_cell[1])
  local dy = abs(start_cell[2] - target_cell[2])
  return (dx * dx) + (dy * dy)
end

function dir2target(start_cell, target_cell)
  local dir = nil
  if target_cell then
    local dx = start_cell[1] - target_cell[1]
    local dy = start_cell[2] - target_cell[2]
    dir = (abs(dx) > abs(dy)) and ((dx < 0) and 1 or 0) or ((dy < 0) and 3 or 2)
  end
  return dir
end

function nearest_target(start_cell, r_sqrd, t1, t2)
  local d_p1 = t1 and dist2target(start_cell, t1) or 1000
  local d_p2 = t2 and dist2target(start_cell, t2) or 1000
  local m = min(d_p1, d_p2)
  return (m <= r_sqrd) and ((m == d_p1) and t1 or t2) or nil
end

-- t1, t2 are target cells
function steer(e, blocked, t1, t2)
  local back = (e.dir == 0) and 1 or ((e.dir == 1) and 0 or ((e.dir == 2) and 3 or 2))
  local dir2 = (e.dir == 0) and 3 or ((e.dir == 1) and 2 or ((e.dir == 2) and 0 or 1))
  local dir3 = (e.dir == 0) and 2 or ((e.dir == 1) and 3 or ((e.dir == 2) and 1 or 0))

  local go_dir2 = (band(grid[e.cell[2]][e.cell[1]], 2^dir2) == 0) and 100 or 0
  local go_dir3 = (band(grid[e.cell[2]][e.cell[1]], 2^dir3) == 0) and 100 or 0

  if (blocked or (go_dir2 > 0) or (go_dir3 > 0)) then
    local targetdir = dir2target(e.cell, nearest_target(e.cell, 36, t1, t2)) or e.dir
    if ((go_dir2 > 0) and (go_dir3 > 0)) then
      go_dir2 = (targetdir == dir2) and 75 or ((targetdir == dir3) and 25 or 50)
      go_dir3 = 100 - go_dir2
    end

    local changedir = blocked and 100 or ((targetdir == e.dir) and 10 or 90)
    if (rnd(100) < changedir) then
      if (blocked and rnd(100) < 5) then
        e.steer = back
      elseif (rnd(100) < go_dir2) then
        e.steer = dir2
      elseif (go_dir3 > 0) then
        e.steer = dir3
      else
        e.steer = back
      end
    end
  end
end

function remove_wizard(m, killed)
  if (m.spawntype == 5) then
    if killed then
      sfx(19,1)
    else
      add_timer(1, function() kill(m) end, 1)
    end
  end
end

function update_entities()
  local i = 1
  while i <= #monsters do
    local m = monsters[i]
    if (m) then
      m.speed = min(m.max_speed, max(m.speed, speed))
      update_animation(m)
      if not is_alive(m) then
        if not m.state[1] then -- wait for death animation to complete
          monsters[i] = monsters[#monsters]
          monsters[#monsters] = respawn(m) -- or nil
          i -= 1
        end
      else
        local prev_cell = {m.cell[1],m.cell[2]}
        local moved = update_entity(m)
        if (not moved) or (not v2_equal(m.cell, prev_cell)) then
          steer(m,
                not moved,
                is_alive(players[1]) and players[1].cell or door_left,
                is_alive(players[2]) and players[2].cell or door_right)
        end

        if collision_test(m, players, nil, function(p) if is_alive(p) then kill(p, p.sprite.die); clear_game_ctrls(p) end end) then
          remove_wizard(m)
        end

        if (m.laser) then
          if not update_entity(m.laser) then
            m.laser = nil
          else
            if collision_test(m.laser, players, nil, function(p) if is_alive(p) then kill(p, p.sprite.die); clear_game_ctrls(p) end end) then
              m.laser = nil
              remove_wizard(m)
            end
          end
--        elseif ((m.speed <= 1) and (rnd(100) <= 1) and (can_see(m, players[1]) or can_see(m, players[2]))) then
        elseif (m.can_fire and (not m.reloading) and (not m.invisible) and (m.speed < 1.5)) then
          m.reloading = m.can_fire
          if (rnd(100) <= 50) then
            m.laser = new_laser(sprite.laser2, m, m.pos, m.dir, 2)
            sfx(14,1)
          end
        end
      end
    end
    i += 1
  end

  i = 1
  while i <= #players do
    update_animation(players[i])
    if not is_alive(players[i]) then
      if not players[i].state[1] then -- wait for death animation to complete
        next_up(players[i])
      end
    else
      update_entity(players[i])
      if (players[i].laser) then
        if not update_entity(players[i].laser) then
          players[i].laser = nil
        else
          if collision_test(players[i].laser, monsters, nil, function(m) if is_alive(m) then m.invisible = nil; kill(m, sprite.explosion.explode); remove_wizard(m, true); add_score(players[i].score, m.points * multiplier); doublescore = doublescore or (m.spawntype == 4) end end) then
            players[i].laser = nil
          else
            if collision_test(players[i].laser, players, {[players[i]]=true}, function(p) if is_alive(p) then kill(p, p.sprite.die); add_score(players[i].score, p.points * multiplier); clear_game_ctrls(p) end end) then
              players[i].laser = nil
            end
          end
        end
      end
    end
    i += 1
  end
end

function update_entity(e)
  local moved = false
  if (e and e.steer) then
    if move(e, e.steer) then
      e.dir = e.steer
      moved = true
    elseif (e.dir and (e.dir ~= e.steer)) then
      if move(e, e.dir) then
        moved = true
      end
    end
  end

  if moved then
    -- only start walk anim when no other is playing
    if (e.state[1] == nil) then set_animation(e, e.sprite.walk) end
  else
    if (e.state[1] == e.sprite.walk) then e.state[1] = nil end
  end

  if (e.turn_invisible and e.turn_invisible > 0) then
    e.turn_invisible -= 1
    if (e.turn_invisible <= 0) then
      e.turn_invisible = 60
      e.invisible = (rnd(100) <= 75)
    end
  end

  if (e.can_fire and e.reloading) then
    e.reloading -= 1
    if (e.reloading <= 0) then
      e.reloading = nil
    end
  end

  if (e.can_teleport) then
    e.can_teleport -= 1
    if (e.can_teleport <= 0) then
      e.can_teleport = 30
      if (rnd(100) <= 33) then
        set_cell(e, rnd_cell())
        moved = true
      end
    end
  end

  return moved
end

function update_animation(e)
  local anim = e.state
  if (anim[1] ~= nil) then
    if (anim[1].a[anim[2]] == -1) then
      anim[1] = nil
    else
      anim[3] -= 1
      if (anim[3] <= 0) then
        anim[3] = anim[1].delay - e.speed
        anim[3] = anim[1].delay
        anim[2] = (anim[2] < #anim[1].a) and (anim[2]+1) or 1
      end
    end
  end
end

function is_alive(e)
  return e.sprite
end

function kill(e, death)
  if is_alive(e) then
    set_animation(e, death)
    if (death) then
      sfx(death.sound,2)
    end
    e.sprite = nil
    e.laser = nil
  end
end

function player_game_over(p)
  return (not is_alive(p)) and (p.lives <= 0)
end

function next_up(p)
  if not p.next_up then
    p.next_up = true
    set_cell(p) -- default
    if (p.lives > 0) then
      setup_push(p)
    else
      if player_game_over(players[1]) and player_game_over(players[2]) then
        add_timer_secs(3, function() game_over = true end, 1)
      end
    end
  end
end

-- return all targets colliding with e
function collision_test(e, targets, exclude, fn)
  local result = {}
  for i=1,#targets do
    local t = targets[i]
    if (not exclude or not exclude[t]) then
      if (abs(e.pos[1] - t.pos[1]) < 7) and (abs(e.pos[2] - t.pos[2]) < 7) then
        result[#result+1] = t
      end
    end
  end
  foreach(result, fn)
  return (#result > 0) and result or nil
end

function process_btn(b)
  for bit=1,16 do
    if (band(b,shl(1,bit-1)) > 0) then
      if ctrls[bit] then ctrls[bit]() end
    end
  end
end

-- update e's pos and cell if can move
-- return false if can't move
function move(e, dir)
  local dirbit = 2^dir
  local move_axis = ((dir == 0) or (dir == 1)) and 1 or 2
  local perp_axis = (move_axis == 1) and 2 or 1
  local pos = e.pos
  local cell = e.cell
  local cell_pos = {0,0}
  grid_2_pixel(cell, cell_pos, entity_offset)

  -- snap
  if (abs(pos[perp_axis] - cell_pos[perp_axis]) <= 3) then
    if (band(grid[cell[2]][cell[1]], dirbit) == 0) then
      pos[perp_axis] = cell_pos[perp_axis]
    end
  end
  if (pos[perp_axis] ~= cell_pos[perp_axis]) then
    return false
  end

  if (band(grid[cell[2]][cell[1]], dirbit) == dirbit) then
    local d = cell_pos[move_axis] - pos[move_axis]
    local m = (d >= 0) and 1 or -1
    d = min(abs(d), e.speed)
    if (d > 0) then
      pos[move_axis] += (d * m)
      return true
    end
  else
    local spd = (band(dirbit, 10) > 0) and e.speed or -e.speed
    pos[move_axis] += spd

    -- teleport
    if door_open and ((pos[1] < 3) or (pos[1] > 117)) then
      if (e.spawntype and e.spawntype == 4) then
        add_timer(1, function() kill(e); msg = "escaped" end, 1)
        sfx(16,1)
        return true
      elseif e.is_laser then
        return false
      else
        pos[1] = (pos[1] < 3) and 115 or 5
        if (not keep_door_open) then
          door(false)
          add_timer_secs(10, function() door(true) end, 1)
        end
      end
    end

    pixel_2_grid(pos, cell, {3,3})
    return true
  end
end

-- state = {animation,frame-index,delay}
function set_animation(e, a)
  local anim = e.state
  if (anim[1] ~= a) then
    anim[1] = a
    anim[2] = 1
    anim[3] = (a) and a.delay or 0
  end
end

-- return true if e1 & e2 in same row/col & not separated by a wall
function can_see(e1, e2)
  local e1_cell = e1.cell
  local e2_cell = e2.cell
  if (e1_cell[1] == e2_cell[1]) then
    if (e1_cell[2] == e2_cell[2]) then return true end

    local top,bottom = e1_cell,e2_cell
    if (e1_cell[2] > e2_cell[2]) then
      top,bottom = e2_cell,e1_cell
    end
    for y = top[2], bottom[2]-1 do
      if (band(grid[y][top[1]], 8) == 8) then
        return false -- blocked
      end
    end
    return true
  elseif (e1_cell[2] == e2_cell[2]) then
    local left,right = e1_cell,e2_cell
    if (e1_cell[1] > e2_cell[1]) then
      left,right = e2_cell,e1_cell
    end
    for x = left[1], right[1]-1 do
      if (band(grid[left[2]][x], 2) == 2) then
        return false -- blocked
      end
    end
    return true
  end
  return false
end

function clear_game_ctrls(p)
  local shift = (p == players[2]) and 8 or 0
  for i=1,5 do
    ctrls[i + shift] = nil
  end
end

function set_game_ctrls(p)
  local s = p.sprite
  local shift = (p == players[2]) and 8 or 0
  ctrls[1 + shift] = function() p.steer = 0 end
  ctrls[2 + shift] = function() p.steer = 1 end
  ctrls[3 + shift] = function() p.steer = 2 end
  ctrls[4 + shift] = function() p.steer = 3 end
  ctrls[5 + shift] = function() if (s and not p.laser) then p.laser = new_laser(sprite.laser1, p, p.pos, p.dir); set_animation(p, s.fire); sfx(s.fire.sound,3) end end
end

function push(e)
  e.lives -= 1
  e.door_closed_in = -1
  e.sprite = (e == players[1]) and sprite.warrior_yellow or sprite.warrior_blue
  e.next_up = nil
  add_timer(12, function() set_grid_cell(e.cell_default, 2, true); set_game_ctrls(e) end, 1)
  add_timer(1, function() e.pos[2] -= 1; pixel_2_grid(e.pos, e.cell, {3,3}) end, 12)
end

function setup_push(e)
  local shift = (e == players[2]) and 8 or 0
  e.dir = (e == players[1]) and 0 or 1
  e.door_closed_in = 10
  ctrls[3 + shift] = function() p.steer = 2 end
  add_timer_secs(1, function() e.door_closed_in -= 1; if (e.door_closed_in == 0) then ctrls[3+shift] = nil; push(e) end; end, e.door_closed_in)
  ctrls[3+shift] = function() ctrls[3+shift] = nil; push(e) end
  set_grid_cell(e.cell_default, 2, false)
end

function rnd_cell(cell)
  cell = (cell) or {0,0}
  cell[1] = flr(rnd(11)+2)
  cell[2] = flr(rnd(6)+1)
  while nearest_target(cell,
                       9,
                       is_alive(players[1]) and players[1].cell or nil,
                       is_alive(players[2]) and players[2].cell or nil) do
    cell[1] = flr(rnd(11)+2)
    cell[2] = flr(rnd(6)+1)
  end
  return cell
end

spawn_cnt=0 -- at most 6
spawn2_cnt=0
spawn2_pending=0
spawn4_pending=0
function spawn()
  spawn_cnt = 6
  spawn2_cnt = min(level,6)
  spawn2_pending = spawn2_cnt
  spawn4_pending = (level > 1) and 1 or 0
  local cell = {0,0}
  for i=#monsters+1,#monsters+6 do
    rnd_cell(cell)
    monsters[i] = new_sprite(sprite.beast, cell, pts.beast, speed)
    monsters[i].max_speed = 1.5
    monsters[i].spawntype = 1
    monsters[i].can_fire = 150
    monsters[i].reloading = monsters[i].can_fire
    set_animation(monsters[i], monsters[i].sprite.walk)
  end
end

function respawn(e)
  local result = nil
  if (e.spawntype == 4 and doublescore) then
    if (rnd(100) <= 40) then
      result = new_sprite(sprite.wizard, rnd_cell(), pts.wizard, 1.45)
      result.max_speed = 1.45
      result.can_fire = 4
      result.can_teleport = 30
      set_speed(15,1)
    else
      sfx(17,1)
      spawn_cnt -= 1
    end
  elseif (e.spawntype == 2) then
    result = new_sprite(sprite.manticore, rnd_cell(), pts.manticore, speed)
    result.max_speed = 2.5
    result.can_fire = 90
    result.turn_invisible = 60
  elseif (e.spawntype == 1) and (spawn_cnt <= spawn2_cnt) and (spawn2_pending > 0) then
    spawn2_pending -= 1
    result = new_sprite(sprite.lizard, rnd_cell(), pts.lizard, speed)
    result.max_speed = 2
    result.can_fire = 90
    result.turn_invisible = 60
  else
    spawn_cnt -= 1
  end

  if result then
    result.spawntype = e.spawntype + 1
    result.reloading = result.can_fire
  end

  if (spawn_cnt <= 0) then -- next level or imp
    if (spawn4_pending >= 1) then
      spawn4_pending -= 1
      spawn_cnt += 1
      result = new_sprite(sprite.imp, rnd_cell(), pts.imp, 2.25)
      result.max_speed = 2.25
      result.spawntype = 4
      if (door_open) then
        door(false)
        add_timer_secs(5, function() door(true) end, 1)
      end
      keep_door_open = true
      set_speed(15,3)
      sfx(15,0)
    else
      sfx(-2,0)
      add_timer_secs(2, function() if is_alive(players[1]) then players[1].lives += 1 end; if is_alive(players[2]) then players[2].lives += 1 end; ready_level = level+1 end, 1)
    end
  end

  if result then set_animation(result, result.sprite.walk) end
  return result
end

function loadmap()
  local num = ((level-1) % num_maps) + 1
  local mapinfo = get_mapinfo(num)
  msg = mapinfo[1]
  to_grid(mapinfo[2])
  door_open = true
  keep_door_open = false
  multiplier = (doublescore) and 2 or 1
  doublescore = false

  for i=1,2 do
    players[i].laser = nil
    players[i].door_closed_in = nil
    players[i].next_up = nil
    next_up(players[i])
  end

  speed = 0.125 + min(((level-1) / 10), 1)
  spawn()

  tempo.spd = tempo.min
  set_speed(tempo.sound,tempo.spd)
  sfx(tempo.sound,0)
  add_timer(7, function() tempo.spd = max(tempo.max, tempo.spd - 1); set_speed(tempo.sound,tempo.spd); speed = min(3, speed + 0.001) end)
end

function reset_game()
  -- players
  for i=1,2 do
    players[i] = new_sprite(nil, {12-((i-1)*10),7}, pts.warrior)
    players[i].score = {0,0}
    players[i].lives = 0
  end
  monsters={}
  level = 0
  msg = "radar"
  clear_grid()
  door_open = false
  keep_door_open = false
  set_screen(1)
end

function set_screen(n)
  ctrls = {}
  screen = n
  if screen == 1 then
    add_timer_secs(4, function() set_screen(3) end, 1)
    ctrls[3] = function() sfx(12,3); players[1].lives = 3; clear_timers(); set_screen(2) end
  elseif screen == 2 then
    ctrls[3] = function() sfx(12,3); players[1].lives = 7; if (players[2].lives > 0) then players[2].lives = players[1].lives end; ctrls[3] = nil end
    ctrls[5] = function() ctrls = {}; draw_bgnd(); ready_level = 1; set_screen(20) end
    ctrls[13] = function() sfx(sprite.warrior_blue.fire.sound,3); players[2].lives = players[1].lives; ctrls[13] = nil end
  elseif screen == 3 then
    add_timer_secs(4, function() set_screen(1) end, 1)
    ctrls[3] = function() sfx(12,3); players[1].lives = 3; clear_timers(); set_screen(2) end
  end
end

function clear_grid()
  for row=1,7 do grid[row] = {} end
end

function set_hscore(hscore, score)
  if (score[1] > hscore[1]) or ((score[1] == hscore[1]) and (score[2] > hscore[2])) then
    hscore[1] = score[1]
    hscore[2] = score[2]
  end
end

function _init()
  load_table(10823, sprite) -- sprite data from cart
	for i=1,75 do stars[i] = {flr(rnd(128)),flr(rnd(128)),5} end
  camera(0,0)
  reset_game()
end

function _update()
  update_timers()
  if screen == 20 then
    if game_over then
      game_over = nil
      clear_timers()
      sfx(-2, 0) -- release sound from looping
      set_screen(13)
      add_timer_secs(1, function() music(2,0,7); print_center("game over", 47, 8) end, 1)
      add_timer_secs(9, function() reset_game() end, 1)
      set_hscore(p1_hscore, players[1].score)
      set_hscore(p2_hscore, players[2].score)
    elseif ready_level then
      level = ready_level
      ready_level = nil
      clear_timers()
      sfx(-2, 0) -- release sound from looping
      set_screen(10)
      add_timer_secs(1, function() music(0,0,7); print_center("get ready", 47, 10) end, 1)
      add_timer_secs(3, function() print_center("go", 57, 10) end, 1)
      add_timer_secs(4.5, function() set_screen(20); loadmap(); end, 1)
    else
      players[1].steer = nil
      players[2].steer = nil
      process_btn(btn())
      update_entities()
    end
  else
    process_btn(btnp())
  end
end

function _draw()
  if screen == 1 then
    draw_bgnd()
    to_screen(2)
    print_right(format_score(p2_hscore), 42, 62, 12)
    print_right(format_score(p1_hscore), 110, 62, 10)
  elseif screen == 2 then
    draw_bgnd()
    draw_lives()
    if (players[2].lives <= 0) then
      to_screen(3)
    else
      to_screen(4)
    end
    if (players[1].lives == 3) then
      to_screen(5)
    else
      to_screen(6)
    end
  elseif screen == 3 then
    draw_bgnd()
    to_screen(1) -- roster
  elseif screen == 20 then
    draw_bgnd()
    draw_map(8)
    draw_radar()
    draw_score()
    draw_lives()
    draw_msg()
    draw_entities()
  end
end

-- default : returned if no result
function get_map_cell(base_addr, x, y, default)
  local result = default
  if (x >= 1 and x <= 25 and y >= 1 and y <= 15) then
    local bit_num = ((y-1)*25)+(x-1)
    local byte = peek(base_addr + flr(bit_num / 8))
    local bit_pos = 8 - (bit_num % 8)
    local mask = shl(1,bit_pos-1)
    result = band(byte,mask)
  end
  return result
end

-- create a 7x13 {row,col} nav grid
-- cell bits:
--   1 : left blocked
--   2 : right blocked
--   4 : up blocked
--   8 : down blocked
function to_grid(addr)
  local row = 1
  local y = 2
  while (y <= 14) do
    local col = 1
    local x = 1
    while (x <= 25) do
      local l = (get_map_cell(addr, x-1, y, 0) == 0) and 0 or 1
      local r = (get_map_cell(addr, x+1, y, 0) == 0) and 0 or 2
      local u = (get_map_cell(addr, x, y-1, 0) == 0) and 0 or 4
      local d = (get_map_cell(addr, x, y+1, 0) == 0) and 0 or 8
      grid[row][col] = bor(l, bor(r, bor(u, d)))
      col += 1
      x += 2
    end
    row += 1
    y += 2
  end
end

function get_mapinfo(num)
  local addr = 8756 + ((num-1) * 12) -- indices start addr == 8756
  return {decode(addr+2,10), bor(shl(peek(addr),8), peek(addr+1))}
end

-- menu screens
--
cipher = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","'","_"}
screens = {
  {10240, 22}, -- roster
  {10507, 6},  -- hscores
  {10598, 3},  -- credits1
  {10682, 2},  -- credits2
  {10732, 4},  -- credits3
  {10809, 1},  -- credits4
}

function to_screen(num)
  local addr = screens[num][1]
  for i=1,screens[num][2] do
    if peek(addr) == 1 then -- print command
      print(decode(addr+5,peek(addr+3)),peek(addr+1),peek(addr+2),peek(addr+4))
      addr += peek(addr+3) + 5
    elseif peek(addr) == 2 then -- spr command
      spr(peek(addr+1),peek(addr+2),peek(addr+3),peek(addr+4),peek(addr+5),(peek(addr+6)==1),(peek(addr+7)==1))
      addr += 8
    end
  end
end

function decode(addr, cnt)
  local s = ""
  for i=0,cnt-1 do
    s = s .. (cipher[peek(addr+i)] or " ")
  end
  return s
end

function load_table(addr, t)
  local size = 0
  local key
  if peek(addr) == 3 then
    size = peek(addr+1)
    addr += 2
    for i=1,size do
      -- key
      key = decode(addr+1, peek(addr))
      addr += peek(addr) + 1

      -- value
      local value = nil
      if peek(addr) == 3 then
        value = {}
        addr = load_table(addr, value)
      elseif peek(addr) == 4 then
        value = {}
        addr = load_array(addr, value)
      elseif peek(addr) == 5 then
        value = decode(addr+2, peek(addr+1))
        addr += peek(addr) + 2
      elseif peek(addr) == 6 then
        value = bor(shl(peek(addr+1),8), peek(addr+2))
        addr += 3
      end
      t[key] = value
    end
  end
  return addr
end

function load_array(addr, a)
  local size = 0
  if peek(addr) == 4 then
    size = peek(addr+1)
    addr += 2
    for i=1,size do
      local value = nil
      if peek(addr) == 6 then
        value = bor(shl(peek(addr+1),8), peek(addr+2))
        addr += 3
      end
      a[i] = value
    end
  end
  return addr
end
__gfx__
700000070000aa000000aa000000aa0000cc000000cc000000cc000000cc000000cc000000cc000080000aa000800aa00800000000000aa00000000000000000
07000070000085a0000085a0000085a00c5800000c5800000c580000000cc000000cc000000cc0000880088a0880088a80000aa00000085a0008000000000000
00700700000aaaa0000aaaa0000aaaa00cccc0000cccc0000cccc00000caa00000caa00000caa000008088c0080088c08800088a0000aaaa000a000000000000
0007700000005a8a00005a8a00005a8ac8c50000c8c50000c8c500000c0c0c000c0c0c000c0c0c000800888808008888080088c008a8888a000800a000000000
000770008a88888a8a88888a8a88888ac88888c8c88888c8c88888c8c0ccc0c0c0ccc0c0c0ccc0c008888566088885660888888800000a8a00a80aa000000000
007007000000aa0a0000aaaa000aaa0ac0cc0000cccc0000c0ccc00080ccc00880cccc0880ccc0080888888808888888088888880000aa0aa8a8aa0a00000000
07000070000aa0a000000aa000aa00a00c0cc0000cc000000c00cc000cccc0000cc0cc0000cccc00080808000808080008080800000aa0a0a5a880aa00000000
7000000700aa0aa00000aa0000000aa00cc0cc0000cc00000cc00000ccccc0000c0ccc0000ccccc000c0c0c00c0c0c00c0c0c0c000000aa00aaaaa0000000000
800000000000000000008000000080000000800000ccc00000ccc00000ccc000c08c0000008c0000008c00000008000800000000c0000880000000000000a000
80000000080000000000a0000000a0000000a000cc088cc00cc88cc0cc088cc0cc00c000cc00c0000000c00008808080c888888008888808000000000000a000
80000000008000000000800a00008000000080a0c0c8cc5cccc8cc5cc0c8cc5ccccc0c0c0ccc0c0ccccc0c0cc088088000880088c088000000009000000a8a00
800000008888000000a080aa00a0800000a08aa00cc85c8cc0c85c8c00c85c8ccccccaccc0cccacccccccacc08880000c88800000888000000a9880000098900
8000000000800000a8a58aa0a8a58a0aa8a58a00cc080c0000080c000cc80c00cccc0ac0cccc0ac0cccc0ac0c088880000888800c0888000aa88888000988890
8000000008000000a5aa8a0aa5aa8aaaa5aa8a0ac0080000000800000c0800000000c000ccc0c000cc00c0000885888ac885888a088888a000a9880000088800
80000000000000000aa880aa0aa88aa00aa880aa000c0000000c0000000c0000000c0000000c0000c00c0000c0868c8a00868c8ac088c8a00000900000008000
0000000000000000000aaa00000aaa00000aaa00000800000008000000080000008000000080000000800000008680a0008680a000880a000000000000000000
aacc0caa00cc0c0000cc0c000c00000000000000c00c0c00080aa000800aa000800000000cc0000000ccccc00000000000000000000000a0000000a000000000
aaaacaaa000aca000aaacaa0cc0c0c000c000000cc0c88cc800aca00800aca00080aa000c5800000cc088c5c0000000000c00c00a0a00aa0a080000000800000
0aa8a8aa00a8a8a0aaa8a8aacc0c88cccc0c0c00cc0ccc00a0aaaaa0a0aaaaa00a0aca00cccc0000c0cc8c8c000800000cccc0000aa88a000000080000000800
000aca000aaacaaaaaaacaaa0cc0cccccc0c88cc0cc0c0cca0aaa880a0aaa880a0aaaaa0c8888c800cc08c00008c800000888cc00a8888a00ac0a0a000000000
0cccccccaccccccc0ccccccc00ccc0000cc0cccc00cccc000aaaaa800aaaaa080aaaa800c8c000000c008000008cc80000c888c000a888a000080c0000080000
0c0ccc0cacacccac0c0ccc0c0cccccc000ccc00000cccc0000aa00000aaa000000aaaa00c0cc00000000c000000880000c0c88c00aa888a00c0080a00c0000a0
00c0c0c00ac0c0ca00c0c0c00c0cc0c00cccccc00cc00cc00a0aa0000a0a000000a0a0000c0cc000000080000000000000c0cc0000aaaa0a00a00c0c00a00000
0cc000cc0cc000cc0cc000cccc0000cccc0cc0cc000000000aa0aa00000aa00000aa00000cc00000000000000000000000000c00a0a00a00a080000000000000
0000000000000000000000aa00aa00000000aa00c0000cc0c000cc0000000ccc0000aa800000aa880000a0080000000000000000000000000000000000000000
0000000000000000c0cc0aaacacca000c0ccaaa0ccc0cccccc0cccc00c00ccc0aa0a00080aaa0000000a0a800000000000000000000000000000000000000000
000000000000b000cc0c0aacccacaa0ccc0caaac00ccc0000ccc00000cccc000a0aaaa0000aaaa00aaaaa0000000000000000000000000000000000000000000
000000000000b00000cca8ac00cca8ac00cca8ac0ccc0cc0ccc0cc0000cc0ccc0aaaaaaaaaaaaaaaa0aaaaa00000000000000000000000000000000000000000
00bbbb000000b0000ccccac00ccccac00ccccac00cccc800cccc800000cccc80aa0aaacaa00aaaca0aaaaca00000000000000000000000000000000000000000
000000000000b00000cca8ac00cca8ac00cca8ac00c0c8c00c0c8c000ccc0c8ca00a8aa0000a8aa000a8aa000000000000000000000000000000000000000000
0000000000000000cc0c0aaaccacaa00cc0caaa0ccc0cc00cc0cc0000c00c0c000088a0000008a000000a0000000000000000000000000000000000000000000
0000000000000000c0cc0aaacacca000c0ccaa00c000cc00c00cc0000000c0c00000000000080000000000000000000000000000000000000000000000000000
0000cc0000008800000caa0000000000000080000000a000000000000000000000aa00000088000000cca0000000000000aaa0000088800000000cc000000000
000088c00000aa800a008a0a000008000000c000000080000a000aa000000a000a88000008cc0000c0c800c000800000aa088aa0880cc88000cc080000c00000
000cccc00008888000a0aa8a008000000000800c0000a00800a00a80008000000aaaa00008888000c8cc0c0000000800a0a8aa8a808c88c800c80ccc0a000080
00008c8c0000a8a8000aa0000000000000c080cc0080a088c00a800000000000a8a800008c8c0000000cc000000000000aa88a8a088cc8c8000ccc8c00080000
8c88888ca8aaaaa80008a8a000008000c8c88cc08a8aa880a8aaa00000008000a88888a88ccccc8c0c8c800000080000aa080a00880c08000008c00a00000000
0000cc0c000088080aa00aa00a0000c0c8cc8c0c8a88a808aaa08a00080000a0a0aa0000808800000cc00cc00c0000a0a0080000800c000008c00c0000000800
000cc0c0000880800a80000000000a000cc880cc088aa0880080aa0000000c000a0aa00008088000000008c000a00000000a0000000800000cc000c000a00000
00cc0cc0008808800000000000000000000ccc00000888000aa00000000000000aa0aa0008808800000000000000000000080000000c00000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001400000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000043000000003200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000030000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000040000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000400000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000100000
00000000000000000000000000000aaaaaaaaaa0000000000000000aaaa00000000000000000000aa00000000000000000000000000000000000000000000000
0000000000000000000aaaaa00aaaaaaaaaaaa0000000aaaaaa000aaaaaaaa00000aaa0000000aaa00aa0000000aaaaa0000aaaa000000000000000000000000
0000aa0000aaaa00aaaaaaaaaaaaaaaaaaaaa000aaaaaaaaaaaa0aaaaaaaaaaa0aaaaaa0aaaaaaaa00aaaa00aaaaaaaa00aaaaaaaa0000000000ccc010000001
00aaaaaaaaaaaaaaaaaaaaaa88aaaaaaaaaaaaaaaaaaaaaaaaaaaa8aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000a0000000cc00004000020
00000aaaaaaaaaaaaaaaaaaaa88aaaaaaaaaaaaaaaaaaaaaaaaaa888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000aaa00000ccc00000400200
0000aaaaaaaa8aaa8aaaa8aaaaaaaaaaaaaaaaaaa8aaaa8aaaaaaa888aaaaaaaaaaaa888888aaaaaaaaaaa8aaaaaaaaaaaaaaaaaa000000000aa000000033000
0000000aaaa888a888aa888aa8aaaa8888888aaa888aa888a8aaaaa888aa88aaaaaaaa88a888a88aa88aa888aaaa8888aaaaaa00000aaa080000000000000000
0000000aaaaa88aa88aaa88a888aa8888888aaaaa888aa88888aa88a88aaa88aaaaaaa88aa88aa88aa88aa88aaa888888aaaaaaaaaaaa080c0ccc00000000000
0000aaaaaaaaa88aa88aaa8aa88aaaaaa88aaaa88a88aa88a88a888a88aaa888aaaaaa888a8aaa88aa88aa88aaa88aa88aaaaaaaaaaa000c0ccc000000100000
000000aa0aaaa88aa88aaa8aa88aaa888888aa88aaa8aa88aaaa88aa88aa88a88aaaaa8888aaaa88aa88aa88aaa88a88aaaaaaa000000000ccccc00000020000
0000000a00aaa88aa88aa88aa88aaaa88aaaaa888aa8aa88aaaa88aa88a88aaa88aaaa88a88aaa888a88aa88aaa88aaaaaaaaaaaaa00000000ccc00000002000
00000a000aaaa88aa88a88aaa88aaa8888888aa888a88a888aaa888a888888a888aaaa88aa88aaa88888aa8888a88888aaaa00aa000000000ccccc0000000300
00000aaaaaaaaa88aa88aaaaa888a8888888aaaa8aa88aa8aaaaa888888a88888aaaa888aa888aaa88a88a88888a88888aaa0000a00000000ccccc0000000300
000aaaaa00aaaaa88aa88aaaaa8aaaaaaaaaaaaaaaaaaaaaaa00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0a000000000cc0ccc000004000
00000000000aaaaaaaaaaaaaaaaaaaaaaaaaa000aa00aaaaaa000000aaaaaaa0aaaaaaaaaaaaaaaa00aaaaaaaaaaaaaa00aaaaa0000000000c0ccccc00040000
000000000000aaaaaaa00000000aaaaaaa000000000000aaaaa0000000aaaa0000000aaaaaaaaa000000aaaaaaaaaa0000000000000000000000000000100000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010100000000000000000001010000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7fffff208020975dd74800002dd555d80aaa03dd55de8882225dd5dd208a2097d55f48082027fffff2800029d5555c7fffff208020975dd74a0000ad5f7d5820a0835757568a00a25d775d280a0295d55d48082027fffff2800029d5555c7fffff208020975dd74a0000ad77775820a083d5555e82aa825d555d202080977577
48028027fffff2800029d5555c7fffff200000977df74820082df557d8000003755576880022577f7528000295575548882227fffff2800029d5555c7fffff20000097d75f4808202dddddd8080203d5dd5e8882225d555d288a2295d55d48082027fffff2800029d5555c7fffff20208097d55f4a0280ad7d5f58200083d5dd
5e8a00a2557f55280002955dd548200827fffff2800029d5555c7fffff2000009555554aaaaaad55555808a203d7575e880022575575288a22955dd548800227fffff2800029d5555c7fffff200000955dd54882822df557d822088357df56a0820a5d555d22000895f57d48000027fffff2800029d5555c7fffff2000009755
574882822d7777580a0a03555556828282577775220a0897555748000027fffff2800029d5555c7fffff208020975dd74802802df557d8020803dd55de8228825d775d20802097575748082027fffff2800029d5555c7fffff2200089577754a2008ad57755828a283f7577e80280257d5f528000295575548882227fffff280
0029d5555c7fffff2000009555554800002d55555800000355555680000255555520000095555548000027fffff2800029d5555c200004150e07050f0e001c00202f04150e07050f0e001d00205e04150e07050f0e001e00208d140805000112050e010020bc04150e07050f0e00200020eb04150e07050f0e002100211a0415
0e07050f0e002200214904150e07050f0e002300217804150e07050f0e00240021a704150e07050f0e001c1b21d604150e07050f0e001c1c220500140805001009140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01191e050c020501131401152a060a0c091a01120401093609080d010e1409030f1205011142070c17011212090f1201114e070a17011212090f1201215a0308090d10011570060a17091a01120401461e0b0c1c1b1b0000100f090e141301462a0b0a1d1b1b0000100f090e14130146360b08201b1b0000100f090e14130142
420c0c1c1b1b1b0000100f090e141301424e0c0a1c1b1b1b0000100f090e141301425a0c081c1b1b1b0000100f090e14130142620c08040f15020c050013030f12050142700c0a1d201b1b0000100f090e14130223321c010101000226322801010100020a32340101010002043240010101000201324c010100000220325801
0101000207326e01010100012a1e0b08080907080013030f12051302041a320101000002015d320101000001265f0d0a1012051313002515102500140f012a670b0a090e1305121400030f090e01187614050d01040500021900030812091300040117130f0e01066e1d0c100c01190512001d00101205131300250609120525
00140f000a0f090e010e30190a100c01190512001c0010120513130025060912052500060f120122380f0a0f0e0500100c011905120007010d05010e30190a100c01190512001c0010120513130025060912052500060f120122380f0a14170f00100c011905120007010d0501301e08081c00031205040914013442060a0000
0f120000010e4c190a1012051313002515102500140f00090e1305121400030f090e011c54120a060f120005181412010017011212090f1213012e1e09081d0003120504091413030a060c011305121c0302020813060030021613060031060c011305121d030202081306001e02161306001f090518100c0f13090f0e030302
081306002b02161306002b070518100c0f0405030502081306002b02161306002b0101040606000006000106000206000306000406ffff0504050c011906000205130f150e0406000d0e17011212090f122619050c0c0f17030602081306000102161306001204030f0c1206000a0417010c0b03040208130600010216130600
12010104030600000600010600020504050c01190600030406091205030502081306000d02161306000e0101040206000006ffff0504050c011906000505130f150e040600090304090503050208130600400216130600440101040d060000060001060000060001060000060001060000060001060000060001060002060003
06ffff0504050c011906000505130f150e0406000a0c17011212090f1226020c1505030602081306000402161306001504030f0c1206000c0417010c0b0304020813060004021613060015010104030600000600010600020504050c01190600030406091205030502081306002902161306002a0101040206000006ffff0504
050c011906000505130f150e0406000903040905030502081306004802161306004c0101040d06000006000106000006000106000006000106000006000106000006000106000206000306ffff0504050c011906000505130f150e0406000a050205011314030402081306002302161306003504030f0c1206000c0417010c0b
0304020813060023021613060035010104060600000600000600000600010600020600020504050c0119060003060c091a011204030402081306002602161306003804030f0c1206000a0417010c0b0304020813060026021613060038010104030600000600010600020504050c0119060005090d010e1409030f1205030402
081306000a02161306001b04030f0c120600080417010c0b030402081306000a02161306001b010104030600000600010600020504050c011906000503090d10030302081306002004030f0c1206000a0417010c0b0303020813060020010104030600000600010600020504050c01190600030617091a011204030402081306
000702161306001804030f0c1206000c0417010c0b0304020813060007021613060018010104030600000600010600020504050c01190600050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010c00001952019520195201952019520195201952019520195201952019520195201b5201b5201b5201b5201c5201c5201c5201c5201c5201c5201c5201c5201952019520195201952019520195201952019520
010c00000157001570015700157001570015700157001570015700157001570015700157001570015700157004570045700457004570045700457004570045700157001570015700157001570015700157001570
010c00000d5720d5720d5720d5720d5720d5720d5720d5720d5720d5720d5720d5720f5720f5720f5720f57210572105721057210572105721057210572105720d5720d5720d5720d5720d5720d5720d5720d572
010c00001457214572145721457214572145721457214572145721457214572145721457214572145721457214572145721457214572145721457214572145720000000000000000000000000000000000000000
010c00000857008570085700857008570085700857008570085700857008570085700857008570085700857008570085700857008570085700857008570085700000000000000000000000000000000000000000
010c00002052020520205202052020520205202052020520205202052020520205202052020520205202052020520205202052020520205202052020520205202050000000000000000000000000000000000000
010c00001c5201c5201c5201c5201c5201c5201c5201c5201c5201c5201c5201c5201c5201c5201c5201c5201b5201b5201b5201b5201b5201b5201b5201b5201b5201b5201b5201b5201b5201b5201b5201b520
010c00000457004570045700457004570045700457004570045700457004570045700457004570045700457003570035700357003570035700357003570035700357003570035700357003570035700357003570
010c0000105721057210572105721057210572105721057210572105721057210572105721057210572105720f5720f5720f5720f5720f5720f5720f5720f5720f5720f5720f5720f5720f5720f5720f5720f572
0104000004371063710637109371333712f3712c3712937127371213711d3711a371123710e371093710637103371013710d3010a301053010130102301013010130101301013010130101301013010130101301
000d000024376283762b3762e37624376283762c3762f37624376283762d3763037624376283762e376313761c65034650286501c65010650153062d3062e3063030631306003060030600306003060030600306
01af00030831507315063150700507000070000600506000060000000000000120001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001c07528575380000760513000070000660506000120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003e3533c6333e3533c6333e3533c6333e3533c6333e3533c6333e3533c6333e3533c6333e3533c6333960039600396003860007600386003860037600376000860028600286002860027600276002e400
010a000010644106401063010630106201061010610106150f6050f6050f6050f6050f6050f6050f6050f6051a60017600156001460013600106000f6000e6000d6000d600006000060000600006000060000000
000301200107101071010710107101071010710207103071040710507107071090710b0710c0710e0710f0710f0710f0710e0710c0710a0710707105071030710207101071010710107101071010710107101071
011000003c1053c1053c1053c1053c2050000000000000003c1353c1353c1353c1350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018200
000a000001273122730127323273011733e273011732c1730117324173011731b1730106311063010530a05301043070430103306033010230402301013010130100301003010030100301003010030100301003
011200000415204152041520415204155061020315203152031520315203155051020215202152021520215202152021550210200152001520015200152001520015200152001520015200152001520015500102
010c0000081730b173131731b273254732e473353733b3733f6703a674346742d674226741a674126740d67407674076740a6640c6640f6541265412644106440c63408634056240462402614016140161401614
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800100070500270007330073200703007040027300732001330027200733007320023300733002330073000400004000040000400004000040000400004000040000400004000040000400051060040000400
011800200c0000c0200c0200c0200c0200c0200c02018020180201602016020160201602014020140201302011020130201302013020130201302013020130202300022000210001800018000180001800018000
011800002410211112111121111211112111121111211112111110c1110c1120c1120c11214112141121411214112181121811218112181121811218112181111611116112161121611216112161121611216112
011800201c70235702357023570235702357023570235702357013570235702357023570235702357023570235702111121111211112111121111211112111110c1110c1120c1120c1120c1120c1120c1120c112
011800100060524655006050063500100246530065524605001000065507100006550510000600006002463500301003010a30103301003010330100301043010030100301003010a3010a30103301073010a301
010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800000c0020c0220c0220c0220c0220c0220c0220c0220c0211402114022140221402214022140221402214022110221102211022110221102211022110221102113021130221302213022130221302213022
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
05 00 01 02 44
04 03 04 05 44
02 06 07 08 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 18 42 43 44
00 1d 42 43 44
00 18 1c 43 44
01 18 19 1c 1b
00 18 1c 19 1b
02 18 1c 1a 1e
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
