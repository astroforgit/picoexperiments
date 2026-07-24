pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico tanks
-- by sorrow wolf

version = "v1.0"
cartdata_id = "pico_tanks_236d9adc"
debug_menu = false
enable_stageselect = true
_lvb = 0x2000 -- in map
_lvs = 91
_x0 = 6
_y0 = 8
sproffset_env = 0
sproffset_tank = 32
sproffset_hq = 62
sproffset_bullet = 24
sproffset_birth = 58
sproffset_armor = 60
sproffset_smalltank = 61
sproffset_bonus = 50
maxplayers = 2
maxtanks = 8
maxbullets = 2
maxenemies = 20
mapsize = 26
maxlevels = 35
stage = 1
hq_alive = true
hiscore = 0
is_hiscore = false
ticks = 0
waterframe = 0
blinkframe = 0
wintimer = 0
tanks = {}
player_lives = {}
player_stars = {}
player_spots = {{8, 24}, {16, 24}}
enemy_spots = {{12,0}, {24,0}, {0,0}}
player_colors = {9,3}
player_shooting = {}
player_score = {}
player_frags = {}
enemies_onscreen = {4, 6}
speeds = {3/32, 3/32, 3/32, 3/32, 1/16, 1/8, 1/16, 1/16, 1/8}
armors = {1, 1, 1, 1, 1, 1, 1, 4, 4}
bullet_speeds = {1/4, 1/2, 1/2}
bullet_ap = {false, false, true}
bullet_types = {0, 1, 1, 2, 0, 0, 1, 0, 1}
bullet_max = {1, 1, 2, 2, 1, 1, 1, 1, 1}
bullet_coords = {{1, 1/4}, {1/4, 1}, {1, 7/4}, {7/4, 1}}
bullet_breakmask = {{12, 12, 3, 3}, {10, 5, 10, 5}}
event_none = 0
event_birth = 1
event_death = 2
event_armor = 3
event_blink = 4
bonus_armor = 0
bonus_clock = 1
bonus_shovel = 2
bonus_star = 3
bonus_bomb = 4
bonus_life = 5
bonus = {present = false}

btype_empty = 0
btype_halfbrick_low = 1
btype_halfbrick_high = 14
btype_brick = 15
btype_armor = 16
btype_water = 17
btype_grass = 18
btype_ice = 19
btype_hq = 20

btn_left = 0
btn_right = 1
btn_up = 2
btn_down = 3
btn_z = 4
btn_x = 5      
dir_up = 0
dir_left = 1
dir_down = 2
dir_right = 3
ai_dirs = {dir_up, dir_up, dir_up, dir_left, dir_up, dir_right, dir_down, dir_down, dir_down, dir_left, dir_up, dir_right, dir_left, dir_up, dir_right, dir_left, dir_down, dir_right}
armor_colors = {13, 4, 9, 3}
numplayers = 2
spawnperiod = 200
spawntimer = 0
clocktimer = 0
shoveltimer = 0
gameover_timer = 0
hqx = 12
hqy = 24
level_enemies = {{{4,18},{5,2}},{{7,2},{5,4},{4,14}},{{4,14},{5,4},{7,2}},{{6,10},{5,5},{4,2},{7,3}},{{6,5},{7,2},{4,8},{5,5}},{{6,7},{5,2},{4,9},{7,2}},{{4,3},{5,4},{6,6},{4,7}},{{6,7},{7,2},{5,4},{4,7}},{{4,6},{5,4},{6,7},{7,3}},{{4,12},{5,2},{6,4},{7,2}},{{5,5},{7,6},{6,4},{5,5}},{{6,8},{5,6},{7,6}},{{6,8},{5,8},{7,4}},{{6,10},{5,4},{7,6}},{{4,2},{5,10},{7,8}},{{4,16},{5,2},{7,2}},{{7,2},{5,2},{7,8},{4,8}},{{7,4},{4,2},{6,6},{5,8}},{{5,4},{7,8},{4,4},{6,4}},{{5,8},{4,2},{6,2},{7,8}},{{6,8},{5,2},{4,6},{7,4}},{{5,8},{4,6},{6,2},{7,4}},{{7,6},{6,4},{5,10}},{{6,4},{7,2},{5,4},{4,10}},{{6,2},{5,8},{7,10}},{{5,6},{7,6},{4,4},{6,4}},{{6,2},{7,8},{5,8},{4,2}},{{5,2},{7,1},{4,15},{6,2}},{{6,10},{5,4},{7,6}},{{4,4},{5,8},{6,4},{7,4}},{{6,3},{5,8},{7,6},{6,3}},{{7,8},{4,6},{6,2},{5,4}},{{5,4},{7,8},{6,4},{5,4}},{{6,4},{5,10},{7,6}},{{6,4},{5,6},{7,10}}}
randomblocks = {{0,1},{2,3},{4,6},{0,4},{5,8},{9,12}}
enemy_types = {}
current_enemy = 0
randomlevels = false
menu_blocks = {btype_empty,btype_armor,btype_brick,btype_grass}
menu_coords = {0,31,32,47}
gameover_coords = {32,63,32,47}
hiscore_coords = {64,127,32,39}
digit_coords = {64,66,40,45}
gameover_pal = {0,0,0,0,5,5,5,6,5,5,5,5,5,5,5,6}
secret_pal = {0,1,128+4,3,4,5,6,7,128+8,9,10,11,12,13,14,15}
drug_pal = {4,2,6,5,12,1,7,6}
menu_counter = 0
menu_strings = {"continue last game", "1 player  normal", "2 players normal", "1 player  random", "2 players random"}
menu_item = 0
menu_first = 1
menu_last = #menu_strings
kcode_state = 0
kcode_keys = {btn_up, btn_up, btn_down, btn_down, btn_left, btn_right, btn_left, btn_right}
no_secretpal = 0
ending_gameover_ticks = 180
ending_hiscore_ticks = 380

persistent_active = 0
persistent_numplayers = 1
persistent_stage = 2
persistent_randomlevels = 3
persistent_hiscore = 4
persistent_pal = 5
persistent_playerinfo = 16
persistent_playersize = 8
persistent_p_lives = 0
persistent_p_stars = 1
persistent_p_score = 2

sfx_shot = 0
sfx_blast = 1
sfx_blast_pl = 2
sfx_blast_hq = 3
sfx_hit_brick = 4
sfx_hit_wall = 5
sfx_bonus_appear = 6
sfx_bonus_take = 7
sfx_bonus_life = 8
sfx_move = 9
sfx_hit_armor = 10
music_start = 0
music_gameover = 1
music_hiscore = 2
sfx_pts = 17
sfx_pts_bonus = 18

gamestate_menu = 0
gamestate_game = 1
gamestate_gameover = 2
gamestate_stageselect = 3
gamestate_score = 4
gamestate_ending = 5


-- 0 - empty, 1..14 half broken brick, 15 - full brick, 16 - armor, 17 - water, 18 - grass, 19 - ice
-- 20 - eagle for collision test (see btype_* consts)
map2blocks = {{btype_empty,btype_brick,btype_empty,btype_brick}, {btype_empty,btype_empty,btype_brick,btype_brick}, {btype_brick,btype_empty,btype_brick,btype_empty}, {btype_brick,btype_brick,btype_empty,btype_empty}, btype_brick, {btype_empty,btype_armor,btype_empty,btype_armor}, {btype_empty,btype_empty,btype_armor,btype_armor}, {btype_armor,btype_empty,btype_armor,btype_empty}, {btype_armor,btype_armor,btype_empty,btype_empty}, btype_armor, btype_water, btype_grass, btype_ice, btype_empty, btype_empty, btype_empty}
-- init maptbl with zero
maptbl = {}
for i=0, (mapsize*mapsize-1) do
  maptbl[i] = 0
end

function inrange(x, minx, maxx)
  return (x >= minx) and (x <= maxx)
end

function inrangexy(x, y, minx, maxx, miny, maxy)
  return inrange(x, minx, maxx) and inrange(y, miny, maxy)
end

function put1(x, y, b)
  assert(b != nil)
  if inrangexy(x, y, 0, mapsize-1, 0, mapsize-1) then maptbl[mapsize*y+x] = b end
end

function put4(x, y, b1, b2, b3, b4)
  put1(x, y, b1)
  put1(x+1, y, b2)
  put1(x, y+1, b3)
  put1(x+1, y+1, b4)
end

function round(x)
  return flr(x+0.5)
end

function round25(x)
  return flr(4*x + 0.5) / 4
end

function isint(x)
  return x == flr(x)
end

function rndint(upper)
  return flr(rnd(upper))
end

function bool2int(x)
  return x and 1 or 0
end

function fortify(b)
  put4(hqx-2, hqy-2, 0, 0, 0, b)
  put4(hqx, hqy-2, 0, 0, b, b)
  put4(hqx+2, hqy-2, 0, 0, b, 0)
  put4(hqx-2, hqy, 0, b, 0, b)
  put4(hqx, hqy, btype_hq, btype_hq, btype_hq, btype_hq) --put eagle here
  put4(hqx+2, hqy, b, 0, b, 0)
end

function reset_tanks(initial)
  for i = 0, maxtanks-1 do
    if (initial) then
      tanks[i] = {}
      tanks[i].type = 0
      tanks[i].bullets = {}
      tanks[i].bullets[0] = {present = false}
      tanks[i].bullets[1] = {present = false}
    end
    tanks[i].present = false
    tanks[i].alive = false
    tanks[i].x = 0
    tanks[i].y = 0
    tanks[i].armor = i-1
    tanks[i].dir = dir_up
    tanks[i].idx = i
    tanks[i].timer = 0
    tanks[i].event = 0
    tanks[i].icetimer = 0
    tanks[i].reloadtimer = 0
    for j = 0, maxbullets-1 do
      tanks[i].bullets[j].present = false
    end
  end
end

function respawn(tank, x, y, dir, type)
  if (tank.present) return
  tank.present = true
  tank.x = x
  tank.y = y
  tank.dir = dir
  tank.type = type
  tank.alive = false
  tank.event = event_birth
  tank.timer = 64
  tank.icetimer = 0
  tank.reloadtimer = 0
  tank.armor = armors[tank.type+1]
  put4(x, y, 0, 0, 0, 0)
end

function tryrespawn()
  local cnt = 0
  local tank
  for i = maxplayers, maxtanks-1 do
    if (tanks[i].present) then
      cnt += 1
    else
      tank = tanks[i]
    end
  end
  if (current_enemy >= maxenemies) return
  if (cnt >= enemies_onscreen[numplayers]) return
  spawntimer = spawnperiod
  respawn(tank, enemy_spots[(current_enemy % 3) + 1][1], enemy_spots[(current_enemy % 3) + 1][2], dir_down, enemy_types[current_enemy])
  tank.bonus = ((current_enemy + 4) % 7 == 0)
  current_enemy += 1;
  if (tank.bonus) bonus.present = false -- hide bonus if red tank spawns
end

function respawn_player(idx)
  if (tanks[idx].present or player_lives[idx] <= 0) return
  player_shooting[idx] = false
  respawn(tanks[idx], player_spots[idx+1][1], player_spots[idx+1][2], 0, player_stars[idx])
end

function load_map (idx)
  ticks = 0
  blinkframe = 0
  seconds = 0
  spawnperiod = 190 - stage*4 - (numplayers-1)*20
  if (spawnperiod <= 0) spawnperiod = 1
  idx = idx % maxlevels
  for rx=4,6 do
    for ry=1,3 do
      if (randomlevels) idx = rndint(maxlevels-1)
      for y=randomblocks[rx][1],randomblocks[rx][2] do
        for j=randomblocks[ry][1],randomblocks[ry][2] do
          local cell = peek(_lvb+idx*_lvs+y*7+j)
          local arr = {flr(cell/16), cell%16}
          for xoff = 1,2 do
            local c = arr[xoff]
            local blocks = map2blocks[c+1]
            if (type(blocks) == "table") then
              put4(2*(j*2+xoff-1), y*2, blocks[1], blocks[2], blocks[3], blocks[4])
            else
              put4(2*(j*2+xoff-1), y*2, blocks, blocks, blocks, blocks)
            end
          end
        end
      end
    end
  end
  local eidx = 0
  if stage > 70 then
    for i = 0,maxenemies-1 do
      enemy_types[i] = 8
    end
  elseif randomlevels then
    for i = 0,maxenemies-1 do
      enemy_types[i] = 4 + rndint(4) 
    end
  else
    if (stage > maxlevels) idx = maxlevels-1
    for i = 1, #level_enemies[idx+1] do
      for j = 1, level_enemies[idx+1][i][2] do
        enemy_types[eidx] = level_enemies[idx+1][i][1]
        eidx += 1
      end
    end
  end
  current_enemy = 0
  fortify(btype_brick)
  hq_alive = true
  reset_tanks(false)
  spawntimer = 0
  clocktimer = 0
  shoveltimer = 0
  wintimer = 0
  bonus.present = false
  for i = 0,numplayers-1 do
    if (player_frags[i] == nil) player_frags[i] = {}
    for j = 4,8 do
      player_frags[i][j] = 0
    end
  end
end

function tank_pal(c1, c2, c3)
  pal(9, c1)
  pal(10, c2)
  if (c3 != nil) then
    pal(5, c3)
  else
    pal(5, 5)
  end
end

function draw_tank (tank)
  if (not tank.present) return
  local s = sproffset_tank + tank.type*2
  if (tank.event == event_birth) then
    s = sproffset_birth + blinkframe
    spr(s, 4*tank.x, 4*tank.y)
    return
  end
  if (tank.event == event_blink and blinkframe == 0) return
  if ((tank.dir % 2) == 1) s += 1
  local flipx = (tank.dir == dir_left)
  local flipy = (tank.dir == dir_down)
  if (tank.idx == 0) tank_pal(9, 10)
  if (tank.idx == 1) tank_pal(3, 11)
  if (tank.idx >= maxplayers) tank_pal(7, armor_colors[tank.armor])
  if (tank.bonus and blinkframe == 0) tank_pal(15, 8)
  if (tank.event == event_death) then
    if (tank.timer < 16) then tank_pal(1, 2, 2)
    elseif (tank.timer < 24) then tank_pal(8, 9, 2)
    else tank_pal(9, 8, 2) end 
  end
  spr(s, 4*tank.x, 4*tank.y, 1, 1, flipx, flipy)
  if (tank.event == event_armor) spr(sproffset_armor, 4*tank.x, 4*tank.y, 1, 1, blinkframe == 1)
end

function draw_bullet(bullet)
  if (not bullet.present) return
  local s = sproffset_bullet + bullet.type*2
  if ((bullet.dir % 2) == 1) s += 1
  spr(s, 4*bullet.x-1, 4*bullet.y-1)
end

function draw_game()
  if (seconds > 0) draw_map()
  draw_hud()
end

function reset_draw(clean)
  pal()
  if (no_secretpal != 1) then
    for i = 0,15 do
      pal(i, secret_pal[i+1], 1)
    end
  end
  clip()
  camera()
  if (clean == true) cls()
end

function draw_map()
  reset_draw(true)
  rectfill(0,0,127,127,5)
  clip(_x0, _y0, 4*mapsize, 4*mapsize)
  rectfill(0,0,127,127,0)
  camera(-_x0, -_y0)
  if (gamestate == gamestate_gameover) then
    for i=0,15 do
      pal(i, gameover_pal[i+1])
    end
  end
  for x = 0, mapsize-1 do
    for y = 0, mapsize-1 do
      local s = maptbl[mapsize*y+x]
      if (s == 17) then
        clip(_x0+4*x, _y0+4*y, 4, 4)
        spr(sproffset_env + s, 4*x+waterframe-3, 4*y, 1, 0.5)
        clip()
      elseif (s != 18) then
        spr(sproffset_env + s, 4*x, 4*y, 0.5, 0.5)
      end
    end
  end
  for i = 0, maxtanks-1 do
    if (not tanks[i].alive) draw_tank(tanks[i])
  end
  for i = 0, maxtanks-1 do
    for j = 0, maxbullets-1 do
      draw_bullet(tanks[i].bullets[j])
    end
  end
  for i = 0, maxtanks-1 do
    if (tanks[i].alive) draw_tank(tanks[i])
  end
  
  for x = 0, mapsize-1 do
    for y = 0, mapsize-1 do
      if (maptbl[mapsize*y+x] == 18) spr(sproffset_env + 18, 4*x, 4*y, 0.5, 0.5)
    end
  end
  
  if (bonus.present and blinkframe == 1) spr(sproffset_bonus + bonus.type, 4*bonus.x, 4*bonus.y)
  local s = sproffset_hq
  if (not hq_alive) then s += 1 end
  spr(s, 4*hqx, 4*hqy)
end

function print_center(s, x, y, c)
  print(s, x-2*#(s..""), y, c)
end

function print_right(s, x, y, c)
  print(s, x-4*#(s..""), y, c)
end


function draw_hud()
  reset_draw()
  if (seconds == 0) then
    rectfill(0,0,127,127,5)
    print_center("stage "..stage, 63, 60, 0)
    return
  elseif (seconds == 1 and ticks < 92) then
    local c = _y0 + 2*mapsize
    rectfill(0,0,127,c-(ticks-64)*2,5)
    rectfill(0,c+(ticks-64)*2,127,127,5)
    return
  end
  print_center("stage "..stage, _x0+2*mapsize+1, _y0+4*(mapsize+1), 0)
  palt(0, false)
  for i = 0, maxenemies-current_enemy-1 do
    spr(sproffset_smalltank, 4*mapsize+_x0 + 2 + 7*flr(i%2), _y0 + 8*flr(i/2))
  end
  for i = 0,numplayers-1 do
    print((i+1).."p ", 4*mapsize+_x0 + 4, _y0 + 20 + 8*8 + 16*i, 0)
    if (player_lives[i] > 0) then
      pal(0, player_colors[i+1])
      spr(sproffset_smalltank, 4*mapsize+_x0 + 2, _y0 + 18 + 9*8 + 16*i, 1, 1, false, true)
      pal(0, 0)
      print(player_lives[i]-1, 4*mapsize+_x0 + 10, _y0 + 20 + 9*8 + 16*i, 0)
    else
      print("rip", 4*mapsize+_x0 + 3, _y0 + 20 + 9*8 + 16*i, 0)
    end 
  end
  palt(0, true)
end

function passable(tank, x, y)
  if (not inrangexy(x, y, 0, mapsize-1, 0, mapsize-1)) return false
  local type = maptbl[mapsize*y+x]
  if (not ((type == 0) or inrange(type, 18, 19))) return false
  for i = 0, maxtanks-1 do
    if ((i != tank.idx) and (tanks[i].alive)) then
      if (inrangexy(x, y, round(tanks[i].x), round(tanks[i].x+1), round(tanks[i].y), round(tanks[i].y+1))) return false
    end
  end
  return true
end

function passable2(idx, x1, y1, x2, y2)
  return passable(idx, x1, y1) and passable(idx, x2, y2)
end

function passableinfront(tank)
  local rx = round(tank.x)
  local ry = round(tank.y)
  local speed = speeds[tank.type+1]
  if (tank.dir == dir_up   ) return passable2(tank, rx, flr(tank.y-speed), rx+1, flr(tank.y-speed))
  if (tank.dir == dir_left ) return passable2(tank, flr(tank.x-speed), ry, flr(tank.x-speed), ry+1)
  if (tank.dir == dir_down ) return passable2(tank, rx, flr(tank.y+2), rx+1, flr(tank.y+2))
  if (tank.dir == dir_right) return passable2(tank, flr(tank.x+2), ry, flr(tank.x+2), ry+1)
end

function onice(tank)
  local rx = round(tank.x)
  local ry = round(tank.y)
  for x = rx,rx+1 do
    for y = ry,ry+1 do
      if (inrangexy(x, y, 0, mapsize-1, 0, mapsize-1) and maptbl[mapsize*y+x] == btype_ice) return true
    end
  end
  return false
end

function movetank(tank, dir)
  if (tank.event == event_blink) return
  if (dir >= 0) tank.dir = dir
  local speed = speeds[tank.type+1]
  if (tank.dir == dir_up) then
    tank.x = round(tank.x)
    local newy = flr(tank.y-speed)
    if (passable2(tank, tank.x, newy, tank.x+1, newy)) tank.y -= speed
  elseif (tank.dir == dir_left) then
    tank.y = round(tank.y)
    local newx = flr(tank.x-speed)
    if (passable2(tank, newx, tank.y, newx, tank.y+1)) tank.x -= speed
  elseif (tank.dir == dir_down) then
    tank.x = round(tank.x)
    local newy = flr(tank.y+2)
    if (passable2(tank, tank.x, newy, tank.x+1, newy)) tank.y += speed
  elseif (tank.dir == dir_right) then
    tank.y = round(tank.y)
    local newx = flr(tank.x+2)
    if (passable2(tank, newx, tank.y, newx, tank.y+1)) tank.x += speed
  end
  if (tank.idx < maxplayers and bonus.present and inrangexy(tank.x, tank.y, bonus.x-1.75, bonus.x+1.75, bonus.y-1.75, bonus.y+1.75)) take_bonus(tank)
  if (tank.idx < maxplayers) then
    if (tank.icetimer == 0) then
      sfx(sfx_move) 
      if (onice(tank)) tank.icetimer = 28
    end
  end
end

function shoot(tank)
  local n = 0
  local bullet
  for i = 0, maxbullets-1 do
    if (tank.bullets[i].present) then
      n += 1
    else
      bullet = tank.bullets[i]
    end
  end
  if (tank.reloadtimer > 0) return
  -- check if max bullets reached
  if (n >= bullet_max[tank.type+1]) return
  tank.reloadtimer = 8
  bullet.present = true
  bullet.sfx = 0
  bullet.x = round25(tank.x) + bullet_coords[tank.dir+1][1]
  bullet.y = round25(tank.y) + bullet_coords[tank.dir+1][2]
  bullet.dir = tank.dir
  bullet.type = bullet_types[tank.type+1]
  bullet.ap = bullet_ap[bullet.type+1]
  bullet.ap = bullet_ap[bullet.type+1]
  bullet.speed = bullet_speeds[bullet.type+1]
  bullet.owner = tank.idx
  if (tank.idx < maxplayers) sfx(sfx_shot)
end

-- ai from here: https://habrahabr.ru/post/142126/
function ai_changedirection(tank)
  local period = spawnperiod / 8;
  --seconds = 254
  if (seconds < period) then
    tank.dir = rndint(4)
  elseif (seconds < period*2) then
    if (not tanks[1].alive or (tanks[0].alive and (tank.idx % 2 == 0)) ) then
      ai_aim(tank, round(tanks[0].x), round(tanks[0].y))
    else
      ai_aim(tank, round(tanks[1].x), round(tanks[1].y))
    end
  else
    ai_aim(tank, hqx, hqy)
  end
end

function ai_checktilereach(tank)
  if (isint(tank.x) and isint(tank.y) and (rndint(16) == 0)) then
    ai_changedirection(tank)
  elseif (not passableinfront(tank) and (rndint(4) == 0)) then
    if (isint(tank.x) and isint(tank.y)) then
      if (rndint(4) != 0) then
        ai_changedirection(tank)
      else
        tank.dir = (tank.dir + 1 + 2 * rndint(2)) % 4
      end  
    else
      tank.dir = (tank.dir + 2) % 4
    end
  end
end

function diff012(x1, x2)
  if (x1 == x2) return 1
  if (x1 < x2) return 0
  return 2
end

function ai_aim(tank, x, y)
  local newdir = ai_dirs[diff012(x, tank.x) + 3*diff012(y, tank.y) + rndint(2)*9 + 1]
  tank.dir = newdir
end

function ai_update(tank)
  if (clocktimer > 0) return
  movetank(tank, -1)
  if (rndint(32) == 0) shoot(tank)
  ai_checktilereach(tank)
end

function game_over()
  if (gamestate != gamestate_game) return
  dset(persistent_active, 0)
  gameover_timer = 100
  hq_alive = false
  gamestate = gamestate_gameover
end

function tank_event(tank)
  -- fires when current event stops working
  if (tank.event == event_birth) then
    tank.alive = true
    if (tank.idx < maxplayers) then
      tank.armor = 32000
      tank.event = event_armor
      tank.timer = 128
      return
    end
  elseif (tank.event == event_death) then
    tank.present = false
    local idx = tank.idx
    if (idx < maxplayers) then
      player_lives[idx] -= 1
      player_stars[idx] = 0
      -- yes, it will be unfair not to save them
      local poffset = persistent_playerinfo + idx*persistent_playersize
      dset(poffset + persistent_p_lives, player_lives[idx])
      dset(poffset + persistent_p_stars, player_stars[idx])
      local nlives = 0
      for i=0,numplayers-1 do
        nlives += player_lives[i]
      end
      if (nlives <= 0) game_over()
      return
    end
    if (check_win()) wintimer = 128
  elseif (tank.event == event_armor) then
    tank.armor = 1
  end
  tank.event = event_none
end

function process_tank(tank)
  if (tank.timer > 0) then
    tank.timer -= 1
    if (tank.timer == 0) tank_event(tank)
  end
  if (tank.reloadtimer > 0) tank.reloadtimer -= 1
end

function process_players()
  for i = 0, numplayers-1 do
    local tank = tanks[i]
    if tank.alive and hq_alive then
      -- check ice
      if (tank.icetimer > 0) then
        tank.icetimer -= 1
        if (tank.icetimer > 0) movetank(tank, -1)
      else
        if (btn(btn_left,  i)) movetank(tank, dir_left)
        if (btn(btn_right, i)) movetank(tank, dir_right)
        if (btn(btn_up,    i)) movetank(tank, dir_up)
        if (btn(btn_down,  i)) movetank(tank, dir_down)
      end
      if (btn(btn_z, i)) shoot(tank)
      local player_btnx = btn(btn_x, i)
      if (player_btnx and not player_shooting[i]) shoot(tank)
      player_shooting[i] = player_btnx
    end
    process_tank(tank)
  end
end

function process_ai()
  for i = maxplayers, maxtanks-1 do
    local tank = tanks[i]
    if (tank.alive) ai_update(tank)
    process_tank(tank)
  end
end

function spawn_bonus()
  bonus.present = true
  bonus.x = 3 + 6*rndint(4)
  bonus.y = 3 + 6*rndint(4)
  bonus.type = rndint(6)
  sfx(sfx_bonus_appear)
end

function take_bonus(tank)
  bonus.present = false
  if (bonus.type != bonus_life) sfx(sfx_bonus_take)
  add_score(tank.idx, 5)
  if (bonus.type == bonus_star and (player_stars[tank.idx] < 3)) then
    player_stars[tank.idx] += 1
    tank.type += 1
  elseif (bonus.type == bonus_life) then
    player_lives[tank.idx] += 1
    sfx(sfx_bonus_life)
  elseif (bonus.type == bonus_armor) then
    tank.event = event_armor
    tank.armor = 32000
    tank.timer = 640
  elseif (bonus.type == bonus_bomb) then
    for i = maxplayers, maxtanks-1 do
      tanks[i].bonus = false
      if (tanks[i].alive) destroy_tank(tanks[i])
    end
  elseif (bonus.type == bonus_clock) then
    clocktimer = 640
  elseif (bonus.type == bonus_shovel) then
    shoveltimer = 1280
    fortify(btype_armor)
  end
end

function destroy_hq()
  hq_alive = false
  sfx(sfx_blast_hq)
  game_over()
end

function check_win()
  if (gamestate != gamestate_game) return false
  if (current_enemy < maxenemies) return false
  for i = maxplayers, maxtanks-1 do
    if (tanks[i].present) return false
  end
  return true
end

function add_score(player, score)
  local oldscore = player_score[player]
  local newscore = oldscore + score
  if oldscore < 200 and newscore >= 200 then
    sfx(sfx_bonus_life)
    player_lives[player] += 1
  end
  player_score[player] = newscore
end

function destroy_tank(tank, killer)
  tank.alive = false
  tank.event = event_death
  tank.timer = 32
  if (tank.idx < maxplayers) then sfx(sfx_blast_pl)
  else sfx(sfx_blast) end
  if (killer != nil and killer < numplayers and player_frags[killer][tank.type] != nil) then
    player_frags[killer][tank.type] += 1
    add_score(killer, tank.type - 3)

  end
end

function bullet_collide_terrain(bullet, x, y)
  local bx = flr(x)
  local by = flr(y)
  if (not inrangexy(bx, by, 0, mapsize-1, 0, mapsize-1)) return
  local block = maptbl[mapsize*by+bx]
  if (hq_alive and block == btype_hq) then
    bullet.present = false
    destroy_hq()
    return
  end
  if (block == btype_armor) then
    bullet.present = false
    if (bullet.ap) then
      maptbl[mapsize*by+bx] = btype_empty
      bullet.sfx = sfx_hit_brick
    else
      bullet.sfx = sfx_hit_wall
    end
    return
  end
  if (inrange(block, btype_halfbrick_low, btype_brick)) then
    local sbx = flr((x - bx) * 2) -- 0..1
    local sby = flr((y - by) * 2) -- 0..1
    local bit = shl(1, 2*sby + sbx)
    if (band(bit, block) > 0) then
      bullet.present = false
      if (bullet.ap) then
        maptbl[mapsize*by+bx] = btype_empty
      else
        maptbl[mapsize*by+bx] = band(block, bullet_breakmask[(bullet.dir % 2) + 1][2*sby + sbx + 1])
      end
      bullet.sfx = sfx_hit_brick
    end
  end
end

function bullet_collide_tank(bullet, tank)
  if (bullet.owner == tank.idx) return
  if (not inrangexy(bullet.x, bullet.y, tank.x - 0.25, tank.x + 2.25, tank.y - 0.25, tank.y + 2.25)) return false
  if ((bullet.owner >= maxplayers) and (tank.idx >= maxplayers)) return false -- enemy tanks
  if ((bullet.owner < maxplayers) and (tank.idx < maxplayers)) then
    if (tank.event == event_none) then
      tank.event = event_blink
      tank.timer = 192
    end
    bullet.present = false
    return
  end
  tank.armor -= 1
  if (tank.bonus) spawn_bonus()
  tank.bonus = false
  if (tank.armor <= 0) then
    destroy_tank(tank, bullet.owner)
  else
    if (tank.armor < 255) sfx(sfx_hit_armor)
  end
  bullet.present = false
end

function process_bullets()
  for i = 0, maxtanks-1 do
    for j = 0, maxbullets-1 do
      local bullet = tanks[i].bullets[j]
      if (bullet.present) then
        -- fly
        if (bullet.dir == dir_up) then
          bullet.y = bullet.y - bullet.speed
        elseif (bullet.dir == dir_left) then
          bullet.x = bullet.x - bullet.speed
        elseif (bullet.dir == dir_down) then
          bullet.y = bullet.y + bullet.speed
        elseif (bullet.dir == dir_right) then
          bullet.x = bullet.x + bullet.speed
        end
        -- check borders
        if (not inrangexy(bullet.x, bullet.y, 0, mapsize, 0, mapsize)) then
          bullet.present = false
          bullet.sfx = sfx_hit_wall
        end
        -- terrain collision
        -- each bullet has 4 corners (maybe it's enough 2 points per each rotation, but i'm lazy) 
        bullet_collide_terrain(bullet, bullet.x - 0.125, bullet.y - 0.125)
        bullet_collide_terrain(bullet, bullet.x + 0.125, bullet.y - 0.125)
        bullet_collide_terrain(bullet, bullet.x - 0.125, bullet.y + 0.125)
        bullet_collide_terrain(bullet, bullet.x + 0.125, bullet.y + 0.125)
        -- tanks & bullets collision
        for t = 0, maxtanks-1 do
          if ((t != i) and tanks[t].alive) bullet_collide_tank(bullet, tanks[t])
          for u = 0, maxbullets-1 do
            local bullet2 = tanks[t].bullets[u]
            if ((t != i) and bullet2.present and inrangexy(bullet.x, bullet.y, bullet2.x - 0.25, bullet2.x + 0.25, bullet2.y - 0.25, bullet2.y + 0.25)) then
              bullet.present = false
              bullet2.present = false
            end
          end
        end
        if (bullet.owner < maxplayers and bullet.sfx > 0) sfx(bullet.sfx)
      end
    end
  end
end

function win_level()
  if (gamestate != gamestate_game) return
  save_game()
  dset(persistent_stage, stage+1)
  start_score()
end

function update_game()
  ticks += 1
  if (ticks % 20 == 0) then
    waterframe += 1
    if (waterframe > 3) waterframe = 0
  end
  if (ticks % 16 == 0) blinkframe = 1 - blinkframe
  if (ticks > 255) ticks -= 256
  if (ticks % 64 == 0) seconds += 1
  if (spawntimer > 0) spawntimer -= 1
  if (seconds > 0) then
    if (spawntimer == 0) tryrespawn()
    for i = 0, numplayers-1 do
      respawn_player(i)
    end
  end
  if (clocktimer > 0) clocktimer -= 1
  if (shoveltimer > 0) then
    shoveltimer -= 1
    if (shoveltimer <= 256) then
      if (shoveltimer % 16 == 0) then
        if (blinkframe == 0) then
          fortify(btype_brick)
        else
          fortify(btype_armor)
        end
      end
      if (shoveltimer == 0) fortify(btype_brick)
    end
  end
  if (wintimer > 0) then
    wintimer -= 1
    if (wintimer == 0) win_level()
  end
  process_players()
  process_ai()
  process_bullets()
end

function debug_prevlevel()
  stage-=1
  if stage < 1 then
    stage=1
  else
    start_level()
  end
end

function debug_nextlevel()
  stage+=1
  start_level()
end

function debug_icylevel()
  stage = 17
  start_level()
end

function debug_lastlevel()
  stage = 71
  start_level()
end


function act_debug(i)
  player_stars[i] += 1
  if (player_stars[i] == 8) player_stars[i] = 0
  tanks[i].type = player_stars[i]
--  ai_aim(tanks[i], round(tanks[1-i].x), round(tanks[1-i].y))
end

function debug_addstar()
  player_stars[0] += 1
  if (player_stars[0] == 4) player_stars[0] = 0
  tanks[0].type = player_stars[0]
end

function load_game()
  if (dget(persistent_active) == 0) return
  numplayers = dget(persistent_numplayers)
  stage = dget(persistent_stage)
  randomlevels = dget(persistent_randomlevels) != 0
  for i = 0,numplayers-1 do
    local poffset = persistent_playerinfo + i*persistent_playersize
    player_lives[i] = dget(poffset + persistent_p_lives)
    player_stars[i] = dget(poffset + persistent_p_stars)
    player_score[i] = dget(poffset + persistent_p_score)
  end
  start_level()
end

function save_game()
  dset(persistent_active, bool2int(hq_alive))
  dset(persistent_numplayers, numplayers)
  dset(persistent_stage, stage)
  dset(persistent_randomlevels, bool2int(randomlevels))
  dset(persistent_hiscore, hiscore)
  for i = 0,numplayers-1 do
    local poffset = persistent_playerinfo + i*persistent_playersize
    dset(poffset + persistent_p_lives, player_lives[i])
    dset(poffset + persistent_p_stars, player_stars[i])
    dset(poffset + persistent_p_score, player_score[i])
  end
end

function start_level()
  load_map(stage-1)
  music(music_start)
  save_game() -- autosave on level start
  gamestate = gamestate_game
end

function new_game(opt_numplayers, opt_randomlevels, opt_stage)
  if (opt_numplayers != nil) numplayers = opt_numplayers
  if (opt_randomlevels != nil) randomlevels = opt_randomlevels
  if (opt_stage != nil) stage = opt_stage
  for i = 0, numplayers-1 do
    player_lives[i] = 3
    player_stars[i] = 0
    player_score[i] = 0
  end
  start_level()
end

function print_brick(spr_coords, pos_x, pos_y)
  for i = spr_coords[1], spr_coords[2] do
    for j = spr_coords[3], spr_coords[4] do
      local block = menu_blocks[sget(i,j)+1]
      spr(sproffset_env + block, pos_x + 4*(i-spr_coords[1]), pos_y + 4*(j-spr_coords[3]))
    end
  end
end

function draw_menu()
  reset_draw(true)
  print_brick(menu_coords, 0, menu_counter)
  if (menu_counter > 0) return
  for i = menu_first, #menu_strings do
    local color = 6
    if (menu_item == i) color = 7
    print(menu_strings[i], 32, 64 + i*9, color)
  end
  local s = sproffset_tank+1
  if (kcode_state > #kcode_keys) s = sproffset_tank+17
  spr(s, 20, 63+menu_item*9)
  print(version, 126-4*#version, 120, 6);
  --print(kcode_state, 0, 120, 6);
end

function draw_gameover()
  draw_map()
  draw_hud()
  if (gameover_timer < 20) then
    pal(2, 0)
    spr(68, _x0+2*mapsize-15, _y0+2*mapsize-8 + gameover_timer, 4, 2)
  end
  pal(2, 8)
  spr(68, _x0+2*mapsize-16, _y0+2*mapsize-9 + gameover_timer, 4, 2)
end

function update_menu()
  local lastkey = -1
  if menu_counter > 0 then
    menu_counter -= 1
    if (btnp() > 0)  menu_counter = 0
    return
  end
  if btnp(btn_down, 0) then
    menu_item += 1
    if (menu_item > menu_last) menu_item = menu_first
    lastkey = btn_down
  elseif btnp(btn_up, 0) then
    menu_item -= 1
    if (menu_item < menu_first) menu_item = menu_last
    lastkey = btn_up
  elseif btnp(btn_z, 0) or btnp(btn_x, 0) then
    menu_activate(menu_item)
  elseif btnp(btn_left, 0) then
    lastkey = btn_left
  elseif btnp(btn_right, 0) then
    lastkey = btn_right
  end
  if (lastkey >= 0) and (kcode_state <= #kcode_keys) then
    if kcode_keys[kcode_state] == lastkey then
      kcode_state += 1
    else
      kcode_state = 1
    end
  end
end

function start_stageselect()
  seconds = 0
  ticks = 0
  gamestate = gamestate_stageselect
end

function update_stageselect()
  if (ticks < 7) then
    ticks += 1
  end
  if btnp(btn_right, 0) then
    stage += 1
  elseif btnp(btn_left, 0) and (stage > 1) then
    stage -= 1
  elseif btnp(btn_z, 0) or btnp(btn_x, 0) then
    new_game()
  end
end

function update_gameover()
  ticks += 1
  if (ticks % 16 == 0) then
    blinkframe = 1 - blinkframe
  end
  if (ticks > 255) ticks -= 256
  if gameover_timer > 0 then
    --if gameover_timer == 64 then
    --  music(music_gameover)
    --end
    gameover_timer -= 1
    return
  end
  if (btnp(btn_z, 0) or btnp(btn_x, 0)) start_score()
end

function start_score()
  ticks = 0
  gamestate = gamestate_score
  for i = 0, numplayers-1 do
    player_frags[i].t = 0
    for j = 4, 8 do
      player_frags[i].t += player_frags[i][j]
    end
  end
  bonus_owner = nil
  if (hq_alive and numplayers > 1) then
    if (player_frags[0].t > player_frags[1].t) bonus_owner = 0
    if (player_frags[1].t > player_frags[0].t) bonus_owner = 1
  end
  is_hiscore = false
end


function update_score()
  if ticks < 119 then
    ticks += 1
    if ticks == 119 then
      if bonus_owner != nil then
        sfx(sfx_pts_bonus)
        add_score(bonus_owner, 10)
      end
      if not hq_alive then
        for i = 0, numplayers-1 do
          if player_score[i] > hiscore then
            hiscore = player_score[i]
            is_hiscore = true
          end
        end
        if is_hiscore then
          dset(persistent_hiscore, hiscore)
          sfx(sfx_pts_bonus)
        end
      end
    end
    if (ticks % 20 == 0) sfx(sfx_pts)
  elseif btnp() > 0 then
    if hq_alive then
      stage += 1
      start_level()
    else
      init_ending()
    end
  end
end

function str00(x)
  return (x == 0) and x or x.."00"
end

function draw_score()
  reset_draw(true)
  print("hi-score", 32, 8, 4)
  print_right(str00(hiscore), 96, 8, 9)
  print_center("stage "..stage, 64, 18, 7)
  for i = 0, numplayers - 1 do
    local x = 44 + 72*i
    print_right((i+1).."-player", x, 28, 4)
    print_right(str00(player_score[i]), x, 38, 9)
  end
  tank_pal(7, armor_colors[1])
  for i = 0, 3 do
    spr(sproffset_tank + 8 + i*2, 60, 12*i + 50)
  end
  pal()
  for i = 0, 3 do
    if (ticks < 20 + 20*i) return
    local y =  12*i + 52
    local t = player_frags[0][i+4]
    print_right(t, 56, y, 7)
    print_right(str00(t*(i+1)).." pts", 44, y, 7)
    if (numplayers > 1) then
      local t = player_frags[1][i+4]
      print(t, 72, y, 7)
      print_right(str00(t*(i+1)).." pts", 116, y, 7)
    end
  end
  if (ticks < 100) return
  rectfill(47, 99, 79, 100, 7)
  print_right("total", 44, 104, 7)
  print_right(player_frags[0].t, 56, 104, 7)
  if (numplayers > 1) print(player_frags[1].t, 72, 104, 7)
  if (ticks < 119) return
  if (bonus_owner != nil) print("bonus 1000 pts", 4 + 64*bonus_owner, 116, 9)
end

function menu_activate(item)
  if (item == 1) then
    load_game()
  elseif (inrange(item, 2, 5)) then
    numplayers = (item % 2) + 1
    randomlevels = item > 3
    stage = (kcode_state > #kcode_keys) and 71 or 1
    if (enable_stageselect) then
      start_stageselect()
    else
      new_game()
    end
  end
end

function toggle_palette()
  no_secretpal = 1 - no_secretpal
  dset(persistent_pal, no_secretpal)
end

function init_menu()
  menu_counter = 128
  menu_first = 2
  if (dget(persistent_active) != 0) menu_first = 1
  menu_item = menu_first
  kcode_state = 1
  stage = 1
  gamestate = gamestate_menu
end

function init_ending()
  ticks = 0
  blinkframe = 0
  gamestate = gamestate_ending
end

function update_ending()
  if (ticks == 0) music(music_gameover)
  if (ticks == ending_gameover_ticks) then
    if (is_hiscore) then
      music(music_hiscore)
    else
      init_menu()
    end
  end
  if (ticks == ending_gameover_ticks + ending_hiscore_ticks) init_menu()
  ticks += 1
  if (ticks % 2 == 0) blinkframe += 1
end

function draw_ending()
  local coords_map = gameover_coords
  local hiscorestr = hiscore .. "00"
  reset_draw(true)
  if (ticks > ending_gameover_ticks) then
    -- hiscore
    coords_map = hiscore_coords
    pal(4, drug_pal[(blinkframe % 4)*2 + 1])
    pal(2, drug_pal[(blinkframe % 4)*2 + 2])
    for i = 1, #hiscorestr do
      local digit = tonum(sub(hiscorestr, i, i))
      if (digit == nil) digit = 0
      print_brick({digit_coords[1] + digit*4, digit_coords[2] + digit*4, digit_coords[3], digit_coords[4]}, (i-1)*16 + (136-#hiscorestr*16)/2, 68)
    end
  end
  print_brick(coords_map, 2, 30)
end

function _draw()
  gamestate_router_draw[gamestate+1]()
  local cpu = stat(1)
  if cpu > 0.9 then
    print("!cpu: "..cpu, 0, 122, 8)
  end 
end

function _update60()
  --print(gamestate_router_update[gamestate+1])
  gamestate_router_update[gamestate+1]()
end

gamestate_router_update = {update_menu, update_game, update_gameover, update_stageselect, update_score, update_ending}
gamestate_router_draw = {draw_menu, draw_game, draw_gameover, draw_hud, draw_score, draw_ending}

function _init()
  cartdata(cartdata_id)
  hiscore = dget(persistent_hiscore)
  no_secretpal = dget(persistent_pal)
  if (hiscore == 0) hiscore = 200
  menuitem(1, "toggle palette", toggle_palette)
  if (debug_menu) then
    menuitem(2, "debug prev level", debug_prevlevel)
    menuitem(3, "debug next level", debug_nextlevel)
    menuitem(4, "debug win", win_level)
    --menuitem(3, "debug icy level", debug_icylevel)
    --menuitem(4, "debug last level", debug_lastlevel)
    --menuitem(5, "debug spawn bonus", spawn_bonus)
    --menuitem(5, "debug addstar", debug_addstar)
  end
  reset_tanks(true)
  init_menu()
end



__gfx__
00000000440000000024000044240000000000004400000000240000442400000000000044000000002400004424000000000000440000000024000044240000
00000000220000000022000022220000000000002200000000220000222200000000000022000000002200002222000000000000220000000022000022220000
00000000000000000000000000000000240000002400000024000000240000000044000000440000004400000044000024440000244400002444000024440000
00000000000000000000000000000000220000002200000022000000220000000022000000220000002200000022000022220000222200002222000022220000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666d00001c111c103bb0000077f60000000000000000000000000000000000007500000070000000750000007700000076000000760000000000000000000000
6775000011cc11c0bb3300007f670000000000000000000000000000000000000000000050000000750000005500000066000000660000000000000000000000
677500001c111c10b3b30000f6770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5550000c11cc11003330000677f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900009999999000090000999999900099900099999990000990009a9a9a900009000099999990550a00555505505500999000999999900009000099999990
95090095559995509509009559999550950900955999955099099099999999909509009559999550599a99555999999595090095599995509509009559999950
95999095099a99009599909509aa99009599909509aa9909a999999a09aaa9009599909599aa9900099a995009aaa9909599909599aa99099999999509aaa900
999a999509aaa999999a999509aaa999999a999509aaa99999aaaa9909a9a999999a99959aaaa99959aaa95509a9aaaa999a99959aaaa99999a9a99509aa9999
99aaa995099a990099aaa99509aa990099aaa99509aa9909a9a99a9a09a9a99999aaa99599aa990059a9a95509aaa99099aaa99599aa990999aaa99509aaa900
999a99950099900099aaa9950999900099aaa9950999900099aaaa9909aaa90099aaa9950999900009aaa9500999999099aaa9950999900099aaa99509999900
959990959999999099999995999999909999999599999990a999999a99999990999a9995999999905999995555555555999a9995999999909999999599999990
950000955555555095000095555555509500009555555550990000999a9a9a909599909555555550550000555505505595999095555555509500009555555550
590aa095550550555555555555555555555555555555555555555555555555550000000000000000000000000006000060606060555555550000500000020000
599aa995999999995000000550066005500650055000000550000005500600050000000000000000000600000006000000000006505050550505200500255000
09aaaa9059aaaa905006600550666605500650055006000550066005560606050000000000000000000600000066600060000000500000555550505502555500
59a9aa9509aa9aaa5066660556060065500650055666660550656505566666050000000000000000066666006666666000000006500200550525552525555555
59aaaa9509aaaaaa5066660556066065506666055066600550665605566566050000000000000000000600000066600060000000500000550052525025555555
09aaaa9059aaaa905666666556000065506666055066600550656505566666050000000000000000000600000006000000000006505050550000500025555505
59999995999999995000000550666605500660055660660550065005560006050000000000000000000000000006000060000000555055550005550020055000
59500595550550555555555555555555555555555555555555555555555555550000000000000000000000000000000006060606555555550050505000005000
00000000000000000000000000000000002222000022200022000220222222200000000000000000000000000000000000000000000000000000000000000000
00002222002222002222000222200000022002200220220022202220220002202002022200220002200022002220022200000000000000000000000000000000
00002202200220022002202200220000220000002200022022222220220000002002002002002020020200202002020000000000000000000000000000000000
00002202200220022000002200220000220022202200022022020220222220002222002000200020000200202002022200000000000000000000000000000000
00002222000220022000002200220000220002202222222022000220220000002002002000020020000200202220020000000000000000000000000000000000
00002200000220022000002200220000022002202200022022000220220002202002002002002020020200202002020000000000000000000000000000000000
00002200000220022002202200220000002222002200022022000220222222202002022200220002200022002002022200000000000000000000000000000000
00002200002222002222000222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002220220022202220202022202220222022202220000000000000000000000000
00000000000000000000000000000000002220002200022022222220222222002020020000200020202020002000002020202020000000000000000000000000
02222220020002200220220020022200022022002200022022000220220022202020020002202220222022202220022022202220000000000000000000000000
02022020202000200200020200220020220002202200022022000000220002202020020022000020002000202020020020200020000000000000000000000000
00022000202000220200022000022000220002202200022022222000220022002020020020000020002000202020020020200020000000000000000000000000
00022000222000222200020200000220220002200220220022000000222220002220222022202220002022202220020022202220000000000000000000000000
00022002202200202200020020220220022022000022200022000220220022000000000000000000000000000000000000000000000000000000000000000000
00222202202202200220220020022200002220000002000022222220220002200000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
ddddddddddddddd4d4d4d4d4d4ddd4d4d4d4d4d4ddd4d4d494d4d4ddd4d4d3d3d4d4ddd3d3d1d1d3d3dd1d11d3d3d11d1d8d33d1d1d33d8dd1d1d444d1d1ddd4d4d4d4d4d4ddd4d4d3d3d4d4ddd4d4ddddd4d4ddddddddddddddddddd9ddd9ddddddd4d9ddd4d4d4ddd4dddd44d494ddddd4ddddd9ddddbdd4dd9dd4b49dbbdd
d4dd9dbdddd444bbb9ddb4ddddd9b4d4d4d4dd94d9d4d4ddd4ddd4d4d444d494ddd4d4d444ddddddd4ddddddd4d4ddd4d4ddddd444dddddd4ddd4ddddddbbb4ddddd666d4bbbddddddddddbbbbddd4d4442dbbbb4443d4d0ddbbbbdd4dddd0dddbdddd999ddbddd1d1dddddbbbbd420420333bbbbdddddd4d11bbbbd4dd7ddd3
3bbbdd44d7dddddbbbdd944dddddd4dddddbbddddddddbddbbdd14411dddbdbdd04444441d8d8dd444444442dddd03ddd344d2ddad0d7d7d42dddddd4d11dd42daaddd44444444ddddd0444444442dddd3344444433dddd4413443144dbdbd33dddd33dbbd9bddddddddbb9ddddd444ddddddd6d1d4ddd889ddd9d4ddd4ddddd
dd4d444d44daadad3ddd3ddddadddddd1daadaaad44d44dda4d42dddddddddaddddd57ddaaadad9d4d5dddddd11ddddd544ddddd433341dddd443dddddd34ddd3dddddddddddddddddd0d2bbddddd25d2ddd0b20bdd25d2d4d0b20bdd4dd4d9d4bd4bdddd08d4d37dbbd442ddb4bdd044ddddd0bbb2ddddd944d3bbb30449d88
8d1dbd1d888dd4dd4ddd4dddddd42dd3d3dd04bddd3dddddddbbbddd1ddddddd1bbdddddddd88ddddddd9888dddd9ddddd9dddbd899dddd9dddb9ddd9dddddddb99ddd89ddd9db999d9dddddd5d99ddd99dddd7ddd9d999dd5ddd59ddd99bdd9ddd9dddd9bdd99ddd889ddbdd9ddddddddddddd8d69d66dddddddddddddd4dd4
d1d4ddddb444d4d6d42dddbbbdd3d4d3d02dbaaaaaaaaaadadd4dddd11dddddddd4dd04434388d44d4d044b4664dddd9d6dbbbbdddaadaaaaadaaaadbbd0dd11ddddddbb4d2dd0d614ddb64d2dddd3d4ddddddddddd1d3ddddd4ddddd6bddd4ddddd6b597d4dddd6b597d8bddddd597d8bddddddddd8bddddddddddddb6bdb6b
dddd94d597d597d49ddddb8bdb8bdddddddd6ddd6ddddd4dd597d597dd4d4ddb8bdb8bdd4ddd1ddddddd1ddddd44ddddd44dddddddddddddddddd034dddddd432d03dd4dbbd4dd0d4ddd4bbbb4dd0d4dd04b99b42d4d0114aaaaaa444dd444994994442ddd449d4d9442dddd4444444442dd4b333993333b4d4bbbbbbbbbbb4d
ddbbb111bbbbddddd2d4d4dd2dddddddd9d4d44dddd04444d4ddddddddd2d4d44dbbbdd0ddddd9dbbbbdd0d444944bb39dd3339dd4dbbd0d0444d9bbbbbdddddd9ddbbbbb4dd94dbbbb9bbb4dd04bbbbbdddd42dd4bbdddd8444ddddbbddddd4d0ddd1bbdddddddddddddddd4444ddddd4441d1dd4dddddddd4d3dddd44ddaaa
aad42dd48ddd666ad4d974dd4d444aaada44dddddd9addda8dddaaadaa44daddddddddd488daaadd444ddddddddddddd4d88ddd44d0d4dddddddd4dd4ddddddddddddddddddd1ddd1dddddd4444ddd4444ddd4dddd4dddd9ddd9d43ddd34d44dd4d2b696b0d94dd3ddbbbbbdd84d46ddbbbbbdd14d49d2b898b0d4dd44d41ddd
14d9dd49dddd4dddd4dd44444ddd44499d44dd3ddd3dd4dd44ddddddddddddddddddddddddddbbdd14441ddbbdbdd0444442ddbdddd44b4b44ddddddd4bb4bb4ddddbdd4444444ddbdbbdd4b4b4ddbbdaaad44444daaaddddd00000ddddddddd22222ddddd555ddddddd777d222ddddddd000d7775ddddd7555ddddd44dd4ddd
dddbb44ddd4dddddbbbbbbbb44ddddb84b444bbbb49dbb4bbb8bb474dddbb46bbbb4d4ddd44444bb442bbd5844ddd43dddbdd4d4d613bb42bdd4dd043bb4ddbdd44203bb1b4bbddd4dbddd4b3bdddd3dbddddbbbdddddddddddddddddd9b9ddddddddddddbdb6ddddddddbddddb1dddddddbbddbdb6ddddddbdbdbddb1dddddb
ddbdddbb6dddddbddddbbbb1dddddbddbdbbbbdd4dddddbddbbb9d44dddddbdbbbbd944dddddbdbbbd9944ddddbddbbddddd1ddddd1dddd4d44ddccc44ddd4dd4d9cccccddccc74dd4ccccddcccccc4402dddddd5cccc402d88d4444ccccccc44dddd44cccc7ddddd444dccc44d4ddccc4cdddd4d4ddccccc8d8dd14dd4ccccd
ddd4dddd447dddddd4d4dddddddddd999bddd4dddddd9dd9dd4b4ddd4444d9ddd4b4dd4db499dddd4db94bd4dddddddd9d4944dddddd4494d9dddddddd4db49bdddddd999bd4dd44dddd9d4444dd499ddd9dd9ddddd944ddb999dddddd499dddddddddddd99dd4d4d4d4d4d4ddd4d4d4d4d4d4ddd8d8d8d8d8d8dd1d1d4ddd4d
1d1d4d434d4d434d4d8d8d9d8d9d8d8dbbdd4dbd4ddbbdbbbb43b34bbbbdbbbbbbbbbbbbbd1d1d4bbb4d1d1dd4d4ddbdd4d4ddd4d4ddddd4d4ddd3d3ddddd3d3dddddad4dd4d4ddddddddddd4d9ddddddad19d4d4ddd8d4ad9d13d4ddddd4addd4dddddd4d4aadaaaadd4dddd1dddbdad88d4404d9bbbad11d3d0dd4bbbad4dd
d6ddd4dbdadbddd4d6d333ddbbbdd4d4dddddabbbddddddddddadbddddd111dd1dddddd144444444dddddbbbbbbbb44dddbbddddddbb44ddbd9dd9dddbbbddbd9dd9dddbbbddbddbddddbb442dbbbbbbbbb4442d4bb44bbb4444ddd4444444444d9d9d494444442d9dd943944444999ddddddddddddddddddddbdddddddddddd
b9bdddddddddbddbddbbdddddb4bdddb44bdddddb4bdddbbddbdbddbddbddddb9d4bdddb9bddbdbd94bdddbddb9bdd4bddbdddbdbdddbddb4bdb4bdddddddb4bddbddbdddbddbdddddb9bdb9bddddddb4bddddddddddddddddddddd99ddddddddddddd9dddddddd99bb494bb99ddddd9bb9bb9ddddbddd9bbb9dddbd9bdddbbb
dddb9dbddd68b86dddbddddd9d6d9dddddddd9dd9dd9dddddddddddddddddddddddddddddddddd9ddddddd9ddddd9d48dddd0ddddd4d4bd3444ddddbbd4b02ddd99dbbbbbb444d04ddddbb1184d0430d48d133ddd43d0d0d14cccccccccd0d3dcccccccccddd9dcccccccccd4d4dcccccccccd0d4dcccccccccd0d4dddddcccc
cddd3ddddddccccdddd9d4d4d4d9ddd4d4ddddd9ddddd4d4dd9dd9d99dd4ddd4d94ddd9ddddd44d44d9ddddd9d4dd44d44dd9d9dd4d9dd94dddd44d4ddd49dddd944d44d44dd4dd4ddd49dddd44dddd4d449d9dd4d4d44ddddd49ddd4d4dddddd444ddddaadddddddddd6ddabd2dddddddb6dddd7d2daaddbbd810dd7badddbb
bdd910dddd6dbb86d0d91dd6bdb8dd39d0d8dbbdddddd239ddbbbdddab5dd2368bbddaad0d5dddddbddddddd0dbadd8d9ddddddddaaddd99dddddddddd9ddddd9ddddddddd99dd9dd99dddddd9dd9ddd9d99bdd9dd999dbd9dddd4dddd9d999dddb99d94944ddddddd9b9bdd4dd99ddd9ddbdd9dd9dddd4dd9dd9949ddb999bb
499d49ddddd4ddddbbd4ddddd9dddddbd4ddddd9ddddd9d4dddddddddddd57dddddddd6ddd9dddddddd1b1d42ddddddd6bbb642dddddd1bbcbb42ddddd6bbcccbb2dddd1bbcccccbb1dd6bbcccccccbb6dbbcccccccccbbddbcccccccccbdddbcccccccccbdddbcccdddcccbdddbccdddddccbdddddddddddd4dddd4aad9d4dd
ddddddaa4bbbaad9dddddddbbbaa4dddd9ddaadbddddddbb4daa9dddd4ddbbbdddddd9dd9dd4aad4dddddddd9daabbaabbd4ddddddbdaabbaaddddd9bdddbbaadddd4d4ddddddddd4dddddddd49dddddddddddddddddddddd11ddd6dddd66d1bb6d1b1dd1bb1bbbb1bbb1dbbbbbbbbbbbbbd9babbbbbabbbbdbbaaabbbaaab9d
bbbbab9bbbabbdbbbbbbbbbbbbbdbbbbb33bbbbb8d8bbb3dd3bbb8ddd833dddd333ddddddddddddddddddddaddddadddddaadadaaaadaaadbb4dd4ddadabadbaaaad9dd4bbbdbbdaddadaaaabdaadadaaddadddddd4b4d4bdaddaddaabaaaadb4dad4dd4ddadbbadadaadaada4aaaddddd4dbbddbaddaddaaabddddadaaddadd
ddddddddddcccccccccccccdcccccccccccccdccc4ccccc4cccdc4d4d4c4d4d4cdc334ddddd433cdccc4149414cccd9cccd8d8dccc9dccccd1d1dccccdccccd4d4dccccdccc4dd1dd4cccdc4c4d888d4c4cdd414ddddd414ddd3ddddddddd3dddddd9dddd9ddddd9ddd9dd9bbddddd9dddd9b67dddddd9dbbbbbd5ddd7dd9bb9
bdd9ddd87bd9bb9dd5ddddbbbbbdd9ddddd67bd9bddd9ddddbbb9d9d6dd9ddbbb9dddd5ddddddd9dddddddd59dddddddddd67ddd7d6ddddddddddddddd20dddddddd2220d2dd22dddd22244ddd242ddd00d42dd0244dddd2d402d2444dddd20dd424004dddd2dd0442d24dddd0dd2442d24dddd033d444d2234dd0dd02402220
0ddd2d40244dd0dddd202ddd42d2dddd20ddddd44ddddddddddddddddddddd4d4dddddddbddb4b4bddbddd4bb44444bb4bdd44449494444bddaaa44444aaabdda444444444aabd444a444a444bbd44aaa4aaa44aadbaabbbbbaababddbbdddddbbdbdddddddddddddddddddddddddddddddddddddddddddd6ddddd6ddddd6ddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddbdddddddddddbdbbdddddddddbbd9bbdddddddbb9d99bbdddddbb99d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0102000024350203501a3501235008350123000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000500002a6502b6502d6502e650306502d6502b650266502b6001660010600106000b60005600016000160002600026000160001600016000160005600046000160002600016000960002600006000060000600
000300001765117661196611b6611c6611e6611f67120671216712267122671226712267121661206611e6611c6611b661186611766116661136611366111661106610f6610d6610b6510a641076310562101611
000300001b65121661266612a6612d661306613367135671376713767137671376713767135661336612d66128661246611f661126610a6611066113661146611666117661176611465112641106310b62107611
010200000e740167400e7400e74000700007000070022700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
01040000303303c320003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010800001f3501c3501f350213501f3502135023350243501c30029300293002b3002430026300283000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010600001f35024350283502b3501e35023350273502a35024350283502b350303503435000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010800003035728357343572b35730357283572b357243573035728357343572b3573935730357373572f357373572f3353731500000100000000000000000000000000000000000000000000000000000000000
000100000e310063100e310063100e300063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003443034440344403444034440344401d4001b400184001840018400184001840018400024000b4000140008400054000040000400004000040000400004000040000400004000040000400004000c400
0110000024355263552735524355263552735527355293552b35527355293552b355293552b3552d355293552b3552d3552c3552e355303552c3552e35530355303553b305303053035530355303553035530305
011000000c0550c0050c0050c0550c0550c0550f0550c0050c0050f0550f0550f055110550c0050c005110551105511055140551405514055160551605516055130550c0050c0051305513055130551305513005
0110000013355183000c300133551335513355163550c3000c3001635516355163551835518300183001835518355183551b3551b3551b3551d3551d3551d3551c3551c305183001c3551c3551c3551c35518300
0110000024455224552445501405154051f4551d4551b455184551845518455184551844518435024050b40501405084050540500405004050040500405004050040500405004050040500405004050040500405
011000001f3551f3551f35500300003001b3551a35517355183551835518355183551834518335003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
011000001c0551b0551c0550000000000180551605513055130551305513055130551304513035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003245000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
010800002b3503035028350343502b350373500030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010800002e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b350
010800002935027350293502735029350273502935027350293502735029350273502935027350293502735029350273502935027350293502735029350273502935027350293502735029350273502935027350
010800002e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b3502e3502b35033350313503335031350333503135033350313503335031350333503135033350313503335031350
01080000293502735029350273502935027350293502735029350273502935027350293502735029350273502f3502a3502f3502a3502f3502a3502f3502a3502f3502a3502f3502a3502f3502a3502f3502a350
010800001675000700167500070016750007001b7501b750007001d7501f7501f7501f750007000070000700007001d750007001b750007001f75000700177501775000700197501b7501b7501b7500070000700
010800003135031350313503135031350313503135031350313503135031350313503135031350313503135031350313503135031350373553735537355373453733537335373253732537315373153730537305
0108000003350073500a3500e3500f35013350163501a3501b3501f3502235026350273502b3502e3503235532355323553235532345323453233532335323253232532315323153230532305323053230032300
0108000000000000001905000000170500000012050000000f0500f0500f0500f0500f0500f0500f0500f0500f0500f0500f0500f0400f0300f0200f010000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
04 0b 0c 0d 44
04 0e 0f 10 44
00 13 14 43 44
00 15 16 17 44
04 18 19 1a 44
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
