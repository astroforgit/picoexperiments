pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--slimey, jump!
--by carlos pedroso


--tables (i actually now don't need most of this tables i could optimize this if i need tokens)
spikes = {}
canons = {}
stickys = {}
bullets = {}
bricks = {}
traps = {}
goal = {}
particles = {}
orbs = {}
flash = {}
sniper = {}
transition = {}
coins = {}
level_coins = {5,10,11,12,15,17,18,25,27,31} --for the level select
bosses = {}
computer = {}
eye = {}
sticker = {}
guardian = {}

--variables (this is a mess to read but i need tokens sorry!!)

--level
level_number, level_col, level_row, found_coin, credits_y, music_on, sfx_on, music_track = -1, 0, 0, false, 0, true, true, -1

--scene
splash, intro, ending, level_sel, boss_fight, boss_type, splash_a, message, message_time, selected_level = false, false, false, false, false, 0, false, 0, 0, 1

--player
player_x, player_y, player_dir, player_dead, player_sprite, gravity, jump_force, speed, sliding, player_sticky, hsp, vsp, jump, onground, onwall = 64, 64, 1, true, 16, 0.2, 2.5, 1, 0.5, false, 0, 0, 0, false, false

--transition
transition_r, transition_o, transition_i, transition_boss, transition_color = 0, false, true, false, 12

--guardian
gu_attack, gu_aphase, gu_tx, gu_ty, gu_at, notify, gu_x, gu_y, gu_hx, gu_hy = -1, 0, 0, 0, 0, false, 40, 24, 42, 0

--eye
ushadow, lshadow, ey, ang, hp = 0, 0, 61, 0, 2

--sticker
st_atx, st_aty, st_x, st_y, st_r1, st_r2, st_r3, st_r4 = 0, 0, 0, 0, true, true, true, true

--instance
death_delay, death_timer, brick_delay, canon_delay, bullet_speed, follow_speed, trap_delay, trap_speed, shake, tran_speed, timer, boss_phase, coin_t = 3, 0, 1.5, 5, 4, 0.8, 5, 0.5, 0, 5, 0, 0, 0

--help frames
ground_frames, wall_frames, counting_frames, frame_timer = 4, 8, false, 0

menuitem(1, "level select", function() delete_tables() play_music(9) level_sel, ending, transition_o, st_r1, st_r2, st_r3, st_r4 = true, false, false, true, true, true, true, true end)
menuitem(3, "toggle music", function()  if music_on then music(-1) else music(music_track) end music_on = not music_on end)
menuitem(4, "toggle sfx", function()  sfx_on = not sfx_on end)
menuitem(5, "reset progress", function() for i=0,36 do dset(i,0) end level_number = 0 delete_tables() transition_o = false splash = true  end)

------------------
------------------
------------------

function _init()
 cartdata("carlospedroso_slimeyjump_1")
 reset_palette()
 splash = true
 play_music(1)
end

function _update60()
 if not transition_o and not intro and not splash and not ending and not level_sel then
  if not player_dead then -- player update
   local jumped = false
   if counting_frames then
    frame_timer += 1
    if onground then
     if frame_timer >= ground_frames then
      frame_timer, counting_frames = 0, false
     end
    elseif onwall then
     if frame_timer >= wall_frames then
      frame_timer, counting_frames = 0, false
     end
    else
     frame_timer, counting_frames = 0, false
    end
   end
   if btnp(4) then
    if jump < 2 then
     player_sticky, vsp, jumped, counting_frames, frame_timer = false, -jump_force, true, false, 0
     if jump > 0 then
      for i=1,10 do
       create_particles(player_x+4,player_y+4,rnd(1.3),1.5,0.5,7)
      end
      play_sfx(1)
     else
      play_sfx(0)
     end
    end
    if onwall and not onground then
     player_dir = -player_dir
    end
   end
   if not counting_frames then
    hsp = speed * player_dir
   else
    if(not onwall) hsp = 0
   end
   --apply gravity
   if not onground and not jumped then
    if not onwall and vsp < 1.5 then
     vsp += gravity
    elseif onwall then
     if not counting_frames and not onground then
      vsp = sliding
     else
      vsp = 0
     end
    end
   end
   --horizontal collision
   if not collides((player_x + 3.5 + hsp), (player_y + 3.5),3.5,3.5) then
    onwall = false
    if(not player_sticky) player_x += hsp
   else --if colided
    if not onwall then
     onwall = true
     counting_frames = true
    end
    player_x = flr(player_x/8 +0.5)*8
    jump = 0
    if onground then
     player_dir = -player_dir
     counting_frames = false
    end
   end
   --vertical collision
   if not collides((player_x + 3.5), (player_y + 3.5 + vsp),3.5,3.5) then
    onground = false
    if(not player_sticky) player_y += vsp
   else --if colided
    if check_ground((player_x + 3.5), (player_y + 3.5 + vsp),3.5,3.5) then
     if not onground then
      onground = true
      counting_frames = true
     end
     player_y = flr(player_y/8 +0.5)*8 --we get the position on the grid then round it then *8
     jump = 0
     vsp = 1.5
     else
      vsp = 0
     end
    end
    if(jumped) jump += 1
    --set sprites
    if onwall and not onground then
     player_sprite = 8
    elseif vsp < 0 then
     player_sprite = 16
    elseif vsp > 1 and not onground then
     player_sprite = 24
    else
     player_sprite = 0
    end
   foreach(spikes,spike_collision)
  elseif not ending then
   death_timer -= 0.1
   if death_timer <= 0 then
    player_dead = false
    if(not boss_fight) restart_level()
   end
  end
  foreach(traps,trap_update)
  foreach(canons,shoot)
  foreach(coins,coin_update)
  foreach(bullets,bullet_update)
  foreach(orbs,orb_update)
  foreach(bricks,destroy_brick)
  foreach(sniper,sniper_update)
 elseif not splash and not ending then
  transition_update(transition)
 end
 foreach(particles,particle_update)
 foreach(goal,function(g) create_particles(g.x,g.y,rnd(3),5,0.25,1) end)
 foreach(bosses,boss_update)
 if message_time > 0 then
  message_time -= 0.025
 end

 if ending or intro then
  timer += 0.025
 elseif splash then
  timer += 0.025
  if btn(4) then
   particles = {}
   splash, level_sel = false, true
   play_music(9)
   if dget(0) <= 0 then
    intro = true
   end
  end
  elseif level_sel then
   if (btnp(0) and selected_level > 1) selected_level = selected_level - 1
   if (btnp(1) and selected_level < 32) selected_level = selected_level + 1
   if (btnp(2) and selected_level-8 >= 1) selected_level = selected_level - 8
   if btnp(3) then
     if selected_level+8 <= 32 then
      selected_level = selected_level + 8
     else
      selected_level = 33
    end
  end
   if btnp(4) then
    if selected_level-1 <= dget(0) then
     level_sel = false
     reset_boss(0)
     play_music(10)
     change_level(selected_level - 1)
     set_tables()
    elseif selected_level == 33 and dget(35) == 1 then
     ending, level_sel = true, false
     reset_boss(0)
    end
   end
 end
end

function reset_boss(phase)
 timer, boss_phase = 0, phase
end

function _draw()
 cls()
 if not ending and not intro and not splash and not level_sel then
  draw_background(12)
  foreach(particles,draw_particle)
  map(level_col, level_row,0,0, 16, 16,1)
  if not player_dead and not transition_o and level_number != 31 then
   draw_player()
   if message_time > 0 then -- draw message
    bprint(message, player_x - 4, player_y - 4, 9, 0)
   end
  elseif level_number != 31 then
   screen_shake()
  end

  foreach(coins,draw_coin)
  foreach(bullets,draw_instance)
  foreach(canons,draw_canon)
  foreach(orbs,draw_instance)
  foreach(stickys,draw_instance)
  foreach(bosses,draw_boss)
  foreach(sniper,draw_instance)
  foreach(flash,screen_flash)
  foreach(spikes,draw_instance)
  foreach(traps,draw_trap)

  if level_number == 0 then
   draw_z(36,60)
   draw_z(88,60)
  elseif level_number == 3 then
   draw_z(5,64)
   draw_z(24,64)
   spr(26,16,65)
  end
 elseif intro then -- draw intro
  if boss_phase == 0 then
   pal(11, 3 ,0)
   pal(3, 11 ,0)
   draw_background(1)
   rectfill(8,88,39,119,0)
   rectfill(8,89,38,119,3)
   rectfill(8,90,37,119,11)
   spr(27,27,80)
   sspr(16, 8, 8, 8, 80, 112,8,8,true,false)
   for i=0,15 do
    spr(38,i*8,56)
    spr(36,i*8,120)
    spr(39,0,(i+8)*8)
   end
   rectfill(0,0,128,55,11)
   reset_palette()
   dialogue("you know what?",5,72,1,3)
   dialogue("what?",76,104,3,5)
   dialogue("i feel like",10,72,5,7)
   dialogue("eating cake",10,72,7,9)
   dialogue("now me too",64,104,9,11)
   dialogue("can you go",11,72,12,14)
   dialogue("buy one?",15,72,14,16)
   dialogue("alright",72,104,16,18)
   dialogue("the shop is just",2,72,19,22)
   dialogue("around the corner",1,72,22,25)
   dialogue("cool",76,104,26,28)
   dialogue("it should be",6,72,28,30)
   dialogue("a cake walk ’",6,72,30,32)
   dialogue("urgh",76,104,32,34)
   if timer > 36 then
    intro = false
   end
  end
 elseif splash then -- draw splash
  draw_background(12)
  local y_offset = sin(timer) * 0.5
  create_particles(64,40+ y_offset,rnd(8),5,0.5,9)
  create_particles(64,40,rnd(8),5,0.5,10)
  foreach(particles,draw_particle)
  for i=1,5 do
   spr(111+i,36+i*8,32 + y_offset)
   spr(117+i,36+i*8,40 + y_offset)
  end
  bprint("slimey,",52,26,7,0)
  bprint("the quest for cake",29,51,9,0)
  if timer >= 1 then
   timer = 0
   splash_a = not splash_a
  end
  if splash_a then
   bprint("press    to play",32,80,7)
   draw_z(56,79)
  end

  line(0,106,128,106,0)
  line(0,107,128,107,3)
  rectfill(0,108,128,128,11)
  bprint(" by bibiki",40,110,7)
  bprint("carlos pedroso",38,120,7)
 elseif level_sel then -- draw level select
  draw_background(12)
  for i=0,7 do
   for j=0,3 do
    local i_16,lvl,x_off,c = i*16, i+1+j*8, 0, 6
    if(lvl-2 >= dget(0)) c = 1
    if(lvl == selected_level) c = 9
    rectfill(2+i_16,29+j*15,14+i_16,41+j*15,0)
    rectfill(3+i_16,30+j*15,13+i_16,40+j*15,c)
    if c == 6 then
     line(3+i_16,30+j*15,13+i_16,30+j*15,7)
     line(3+i_16,40+j*15,13+i_16,40+j*15,5)
    end
    for k=0,10 do if level_coins[k] == lvl then spr(64 - 55*dget(lvl-1),10+i_16,36+j*15) end end
    if lvl % 8 == 0 then
      bprint("‚",5+i*16,33+j*15,8,0)
    else
     if(lvl <= 9) x_off = 2
      bprint(lvl,x_off+5+i*16,33+j*15,7,0)
    end
   end
  end

  rectfill(0,0,128,16,11)
  line(0,16,128,16,3)
  line(0,17,128,17,0)


  rectfill(0,99,128,128,11)
  line(0,98,128,98,3)
  line(0,97,128,97,0)
  bprint("cake status:",4,106,7,0)
  bprint("deaths:"..dget(32),4,116,7,0)

  local c = 1
  if(dget(35) == 1) c = 7
  if(selected_level == 33) c = 9
  rectfill(112-1,107-1,121+1,116+1,0)
  rectfill(112,107,121,116,c)
  spr(79,113,107)

  if dget(34) != 1 then
   pal(7,1)
   pal(9,1)
   pal(8,1)
  end
   spr(79,52,103)

  reset_palette()

 else -- draw ending
  palt(2, false)
  draw_background(2)
  rectfill(0,0,128,37,4)
  line(0,38,128,38,9)
  line(0,39,128,39,0)
  rectfill(0,88,128,128,4)
  line(0,88,128,88,0)
  line(0,89,128,89,9)
  rectfill(104,80,128,88,0)
  rectfill(105,81,128,89,9)
  rectfill(106,82,128,89,4)
  rectfill(80,85,87,88,0)
  rectfill(81,86,86,88,9)
  rectfill(82,87,85,89,4)
  spr(25,89,80)
  spr(16,56,80)
  spr(79,105,73)
  spr(124,110,62)
  spr(111,118,62)
  reset_palette()
  if boss_phase == 0 then
   dialogue("hey",54,72,1,2)
   dialogue("hello!",85,72,3,4.5)
   dialogue("what a nice",70,72,6,8)
   dialogue("calm...",85,72,8,10)
   dialogue("day today",75,72,10,12)
   dialogue("isn't it?",75,72,12,14)
   dialogue("...",54,72,16,18)
   dialogue("i don't",47,72,18,19)
   dialogue("soooo...",85,72,19,22)
   dialogue("what cake do",69,72,25,27)
   dialogue("you want to buy?",60,72,27,29)
   dialogue("there's only one cake",20,72,30,32)
   dialogue("right",83,72,33,35)
   dialogue("that'll be...",65,72,35,37)
   dialogue("10",89,72,37,39)
   dialogue("okay let me just",30,72,40,41)
   dialogue("oh...",53,72,41,43)
   dialogue("no...",53,72,43,45)
   dialogue("what?",89,72,45,47)
    if timer > 47 then
     play_music(-1)
     draw_background(0)
     if timer > 50  and timer < 55 then
      for i=0,4 do
       for j=0,2 do
        local j_8 = j*8
        sspr((i*24)+ j_8 ,32, 8, 8, 40 + j_8, 48 + i*8, 8, 8, false, false)
        sspr((i*24)+16-j_8,32, 8, 8, j_8 + 64, 48 + i*8, 8, 8, true, false)
       end
       print("i forgot my wallet",29,96,7)
      end
     elseif timer > 55 then
      boss_phase = 3
      play_music(4)
      timer = 0
      if (total_coin_number() == 10) boss_phase = 2
     end
    end
   elseif boss_phase == 3 then
    draw_background(12)
    if timer > 3 then
     bprint("thank you for playing.",15,24,7,0)
     bprint("i hope you liked the game",15,32,7,0)
     bprint("i worked really hard on it",15,40,7,0)
     bprint("and i really appreciate ",15,48,7,0)
     bprint("all the plays and support!",15,56,7,0)
     bprint("you're cool",15,96,7,0)
     bprint("-cp",15,104,7,0)
    end
   elseif boss_phase == 2 then
    dialogue("fortunately",38,72,1,3)
    dialogue("i found these",33,72,3,5)
    dialogue("coins on the way",29,72,5,7)
    dialogue("well",84,72,8,9)
    dialogue("that's convenient",57,72,10,12)
    if timer > 14 then
     draw_background(1)
     bprint("you got the cake!",31,24,7,0)
     bprint("you are a pro!",38,32,7,0)
     spr(16,48,64)
     spr(79,56,64)
     spr(27,70,64)
     if timer > 25 then boss_phase = 3 dset(34,1) end
    end
   end
 end
 --draw transition
 if (transition_o) circfill(player_x,player_y,transition_r,transition_color)
 if not boss_fight then
  if transition_o and transition_r >= 150 and transition_r <= 400 then
   bprint((level_number + 1).."/32",56,61,7)
  elseif transition_o and transition_r >= 400 then
   bprint((level_number + 2).."/32",56,61,7)
   if(level_number + 1 > dget(0)) bprint("game saved",45,120,10)
   if(level_number == 6 or level_number == 14 or level_number == 22 or level_number == 30) bprint(("‚"),61,70,8)
  end
 end
end

function draw_z(x,y)
 line(x,y-1,x+7,y-1,0)
 spr(24,x,y)
end

------------------
------------------
------------------

function play_music(number)
 music_track = number
 if(music_on) music(number)
end

function play_sfx(number)
 if(sfx_on) sfx(number)
end

function display_message(text)
 message, message_time = text, 2
end

function guardian_attack(attack)
 gu_aphase, timer, gu_at, gu_attack = 0, 0, 0, attack
end

function reset_hands()
 gu_hy, gu_hx = 24, 42
end

function remove_cage(y)
 for i=0,3 do
  for j=0,2 do
   mset(118+i,y+j,127)
  end
 end
end

function guardian_start()
 stickys = {}
 remove_cage(60)
 for i=0,13 do
  mset(113+i,63,11)
  add(stickys,create_instance(8+i*8,120,11))
 end
 player_sticky = false
 reset_hands()
end

function create_instance(x, y,spr)
 i={}
 i.x, i.y, i.spr = x, y, spr
 return i
end

function set_transition(t,open)
 transition_r, transition_o, transition_i = 0, true, open
 if open then
  transition_r = 150
  play_sfx(4)
 end
end

function transition_update(t)
 if transition_i then
  transition_r -= tran_speed
  if (transition_boss) transition_r -= tran_speed * 0.5
  if transition_r <= 0 then
   transition_o = false
  end
 else
  transition_r += tran_speed
  if (transition_boss) transition_r += tran_speed * 0.3
  if transition_r >= 700 then
   transition_o = false
   if not transition_boss then
    next_level()
   else
    restart_level()
   end
  end
 end
end

function sniper_update(sn)
 sn.x += 0.8 * cos(sn.ang)
 sn.y += 0.8 * sin(sn.ang)
 create_particles(sn.x+4,sn.y+4,rnd(3),5,0.25,6)
 if simple_collision(sn.x,sn.y,4,4) then
  player_death()
 end

 if bullet_collision(sn.x, sn.y) or sn.x > 128 or sn.y > 128 then
  del(sniper,sn)
 end
end

function create_trap(x,y)
 local trap = add(traps,create_instance(x,y,13))
 trap.activated, trap.t, trap.d, trap.v = true, trap_delay, -1, true
 trap.s = create_instance(x,y,3)
 trap.s.x = x
 trap.s.y = y
 add(spikes,trap.s)
 return trap
end

function sticker_phase1()
 reset_boss(1)
 player_sticky = false
 stickys = {}

 for i=1,12 do
  create_trap(8 + i*8,112)
 end

 remove_cage(27)

 shake = 0.1
 flash_screen(false)

 for i=1,5 do
  create_particles(40 + i*8,108,rnd(6),5,0.25,7)
 end
end

function remove_rope()
 flash_screen(true)
 play_sfx(18)
 return false
end

function boss_update(boss)
 if boss_type == 1 then
  timer += 0.020
 elseif boss_type == 2 then
  timer += 0.025
  ang=atan2(-60+player_x,-60+player_y)
  ey = sin(ang)
  if ey < 0.1 then --get shadow
   lshadow, ushadow = 8, 0
  elseif ey > 0.4 then
   lshadow, ushadow = 0, 8
  else
   lshadow, ushadow = 0, 0
  end
 elseif boss_type == 3 then
  if boss_phase != 1 then
   timer += 0.020
  end

  if st_r1 and simple_collision(16, 16, 4, 4) then
   st_r1 = remove_rope()
  elseif st_r2 and simple_collision(104, 16, 4, 4) then
   st_r2 = remove_rope()
  elseif st_r3 and simple_collision(16, 64, 4, 4) then
   st_r3 = remove_rope()
  elseif st_r4 and simple_collision(104, 64, 4, 4) then
   st_r4 = remove_rope()
  elseif boss_phase != 2 and not st_r1 and not st_r2 and not st_r3 and not st_r4 then
   reset_boss(2)
   flash_screen(true)
   play_music(25)
   delete_instances()
   for i=0,11 do
    local s = create_instance(16+i*8,112,11)
    add(stickys,s)
    mset(114+i,30,11)
   end
  end
  st_atx += 0.010
  st_aty += 0.020
  st_x = (sin(st_atx) * 2) + 48
  st_y = (cos(st_aty) * 3) + 50
  if(st_atx >= 1) st_atx = 0
  if(st_aty >= 1) st_aty = 0

 elseif boss_type == 4 then -- guardian_update
  gu_tx += 0.01
  gu_ty += 0.03
  timer += 0.025

  if (gu_tx >= 1) gu_tx = 0
  if (gu_ty >= 1) gu_ty = 0

  gu_x = (sin(gu_tx) * 2) + 42
  gu_y = (cos(gu_ty) * 1) + 24

  if gu_attack == -1  then
   gu_hx = (sin(gu_ty) * 2) + 42
   gu_hy = (cos(gu_tx) * 2) + 24
  elseif gu_attack == 0 then
   gu_at += 0.02
   if gu_aphase == 0 then
    if gu_hy <= 72 then
     gu_hy += 3
    elseif gu_hx <= 74 then
     flash_screen(false)
     gu_hy = 73
     if (gu_at >= 0.6) notify = true
     if (gu_at >= 1.3) gu_hx += 3
    else
     gu_aphase = 1
     notify = false
     gu_at = 0
    end
   elseif gu_aphase == 1 then
    if (gu_at >= 0.6) notify = true
    if gu_hx >= 31 and gu_at >= 1.3 then
     gu_hx -= 3
     notify = false
     if gu_hx <= 30 then
      gu_at = 0
      gu_aphase = 2
      flash_screen(false)
     end
    end
   elseif gu_aphase == 2 then
    if (gu_at >= 0.6) notify = true
    if gu_hx <= 74 and gu_at >= 1.3 then
     notify = false
     gu_hx += 3
     if gu_hx >= 73 then
      gu_at = 0
      gu_aphase = 3
      flash_screen(false)
     end
    end
   elseif gu_aphase == 3 then
    if gu_at >= 1 then
     gu_attack = -1
     gu_aphase = 0
     gu_at = 0
     create_particles(64,72,rnd(2),1,0.25,6)
    end
   end
  elseif gu_attack == 1 then
   gu_at += 0.02
   if gu_at >= 1 then
    local sn = create_instance(gu_hx-16,gu_hy+40,9)
    sn.ang = atan2(player_x - sn.x,player_y - sn.y)
    add(sniper,sn)

    local sa = create_instance(gu_hx+52,gu_hy+40,9)
    sa.ang = atan2(player_x - sa.x,player_y - sa.y)
    add(sniper,sa)
    gu_at = 0
   end
  end

  --hands collision
  if gu_attack == 0 then
   if simple_collision(gu_hx - 18,gu_hy + 36,8,8) then
    player_death()
   end

   if simple_collision(138 - gu_hx,gu_hy + 36,8,8) then
    player_death()
   end
  end
 end
end

function dialogue(text,x,y,n1,n2)
 if timer > n1 and timer < n2 then
  bprint(text,x,y,7)
 end
end

function dialogue_red(text,x,y,n1,n2)
 if timer > n1 and timer < n2 then
  bprint(text,x,y,8)
 end
end

function create_goal(x,y)
 play_music(45)
 add(goal,create_instance(x,y,11))
end

function create_orb()
 local o={x=64,y=64,t=0,kill=false,spr=9}
 add(orbs,o)
end

function spawning_particle(x,y)
 create_particles(x,y,rnd(2),5,0.5,7)
end

function eye_fight()
 timer = 0
 remove_cage(44)
 stickys = {}
 player_sticky = false
end

function spike_collision(s)
 --this is pretty horrible but it works for what i want!
 --doesn't need to be perfect, player is pretty big
 if s.spr == 3 then
  if simple_collision(s.x,s.y+3,7,4)then
   player_death()
  elseif simple_collision(s.x,s.y-4,6,3) then
   player_death()
  end
 elseif s.spr == 4 then
  if simple_collision(s.x,s.y-5,7,4) then
   player_death()
  elseif simple_collision(s.x,s.y+3,6,3) then
   player_death()
  end
 elseif s.spr == 5 then
  if simple_collision(s.x-3,s.y-3,5,4) then
   player_death()
  elseif simple_collision(s.x,s.y+1,7,4) then
   player_death() --this needs work
  end
 elseif s.spr == 6 then
  if simple_collision(s.x + 4,s.y+2,5,4) then
   player_death()
  elseif simple_collision(s.x,s.y+1,7,4) then
   player_death() --this needs work
  end
 end
end

function destroy_brick(brick)
 brick.t = (brick.t-0.1)
 if (brick.t <= 0) then
  mset(brick.x, brick.y, 127) --empty sprite
  del(bricks,brick)
  play_sfx(5)
 end
end

function shoot(canon)
 canon.t = (canon.t-0.1)
 if (canon.t <= 0) then
  canon.t = canon_delay
  play_sfx(9)
  local bullet = {}

  bullet.x = canon.x
  bullet.y = canon.y
  bullet.hsp = 0
  bullet.vsp = 0
  bullet.spr = 9

  --add velocity according to rotation
  if canon.v == 0 then
   if canon.h then
    bullet.hsp = -bullet_speed --left
   else
    bullet.hsp = bullet_speed --right
   end
  else
   if canon.v then
    bullet.vsp = bullet_speed --down
   else
    bullet.vsp = -bullet_speed --up
   end
  end
  add(bullets,bullet)
 end
end

function bullet_update(bullet)
 bullet.x += bullet.hsp
 bullet.y += bullet.vsp
 create_particles(bullet.x+4,bullet.y+4,rnd(1),5,0.25,9)

 if simple_collision(bullet.x, bullet.y, 4, 4) then
  player_death()
 end

 if bullet_collision(bullet.x + bullet.hsp, bullet.y + bullet.vsp) then
  del(bullets,bullet)
 end
end

function trap_update(trap) --optimize this
 if trap.t > 0 then
  trap.t -= 0.1
  if trap.t <= 0 then
   trap.activated = not trap.activated
   if trap.activated then play_sfx(8) else play_sfx(7) end
  end
 else
  if(trap.activated) then
   if trap.v then
    trap.s.y -= trap_speed * trap.d
    if trap.d == 1 and trap.s.y <= trap.y then
     trap.s.y = trap.y
     trap.t = trap_delay
    elseif trap.d == -1 and trap.s.y >= trap.y then
     trap.s.y = trap.y
     trap.t = trap_delay
    end
   else
    trap.s.x -= trap_speed * trap.d
    if trap.d == 1 and trap.s.x <= trap.x then
     trap.s.x = trap.x
     trap.t = trap_delay
    elseif trap.d == -1 and trap.s.x >= trap.x then
     trap.s.x = trap.x
     trap.t = trap_delay
    end
   end
  else
   if trap.v then
    trap.s.y += trap_speed * trap.d
    if trap.d == 1 and trap.s.y >= trap.y + 8  then
     trap.s.y = trap.y + 8
     trap.t = trap_delay
    elseif trap.d == -1 and trap.s.y <= trap.y - 8 then
     trap.s.y = trap.y -8
     trap.t = trap_delay
    end
   else
    trap.s.x += trap_speed * trap.d
    if trap.d == 1 and trap.s.x >= trap.x + 8  then
     trap.s.x = trap.x + 8
     trap.t = trap_delay
    elseif trap.d == -1 and trap.s.x <= trap.x - 8 then
     trap.s.x = trap.x -8
     trap.t = trap_delay
    end
   end
  end
 end
end

function orb_update(orb)
 local angle = atan2(player_y-orb.y, player_x-orb.x)
 orb.x += sin(angle) * follow_speed
 orb.y += cos(angle) * follow_speed
 create_particles(orb.x+4,orb.y+4,rnd(3),5,0.25,8)

 if not orb.kill then --timer so the orb doesn't hit boss when spawned
  orb.t += 0.25
  if(orb.t >= 6) orb.kill = true
 end

 if boss_phase > 0 and orb.kill then
  if abs(orb.x - 59) < 8 and abs(orb.y - 59) < 8 then
   play_sfx(18)
   del(orbs,orb)
   reset_boss(boss_phase + 1)
   flash_screen(true)

   if boss_phase == 4 then
    delete_instances()
   elseif boss_phase == 6 then
    delete_instances()
    play_music(25)
    for i=0,11 do
     local s = create_instance(16+i*8,120,11)
     add(stickys,s)
     mset(114+i,47,11)
    end
   end
  end
 end

 if simple_collision(orb.x, orb.y, 4, 4) then
  del(orbs,orb)
  player_death()
 end
end

function flash_screen(white)
 shake = 0.1
 local f={}
 f.t = 0
 f.f = white
 add(flash,f)
end

function player_death()
 if not player_dead and not transition_o then
  shake = 0.1
  player_dead = true
  dset(32, dget(32) + 1);
  play_sfx(2)
  if boss_fight then --make a black transition
   transition_boss = true
   transition_color = 0
   set_transition(transition,false)
  else
   death_timer = death_delay
  end
  for i=1,10 do
   create_particles(player_x+4,player_y+4,rnd(2),3,0.5,10)
  end
 end
end

function collides(x,y,w,h)
 return
 is_solid(x-w,y-h) or
 is_solid(x+w,y-h) or
 is_solid(x-w,y+h) or
 is_solid(x+w,y+h)
end

function check_ground(x,y,w,h)
 local sx = (x/8) + level_col
 local sy = (y/8) + level_row
 return
 is_solid(x-w,y+h) or
 is_solid(x+w,y+h)
end

function bullet_collision(x,y)
 local sx = (x/8) + level_col
 local sy = (y/8) + level_row
 return fget(mget(sx, sy),0)
end

function is_solid(x, y)
 local sx = (x/8) + level_col
 local sy = (y/8) + level_row
 val = mget(sx, sy)

 if fget(val,3) then --goal
  mset(sx,sy,127)
  if level_number < 31 then
   transition_boss = false
   transition_color = 12
   if(boss_fight) play_music(10)
   boss_fight = false
   set_transition(transition, false)
  else
   reset_boss(0)
   ending = true
   play_music(9)
   delete_tables()
   dset(35,1)
  end
  play_sfx(3)
 end

 if(fget(val,4)) player_sticky = true

 if fget(val,5) then --bricks
  if not fget(val,7) then
   mset(sx, sy, 126) --we set a cloned sprite with flag7 so we don't add the same brick
   local brick = {}
   brick.x = sx
   brick.y = sy
   brick.t = brick_delay
   play_sfx(6)
   add(bricks,brick)
  end
 end

 return fget(val, 0) or fget(val, 6) --flag1 visible map solid flag6 invisible solid
end

function create_particles(x,y,r,l,spd,c)
 local p = {}
 p.x = x
 p.y = y
 p.r = r
 p.l = l * 0.01
 p.spd = spd
 p.c = c
 p.rx = rnd(spd*2) - spd
 p.ry = rnd(spd*2) - spd
 add(particles,p)
end

function particle_update(p)
 p.x += p.rx
 p.y += p.ry
 p.r -= p.l
 if(p.r <= 0) del(particles,p)
end

function delete_tables()
 delete_instances()
 goal = {}
 bosses = {}
 particles = {}
 boss_fight = false
 transition_boss = false
end

function delete_instances()
 canons = {}
 bricks = {}
 bullets = {}
 traps = {}
 spikes = {}
 coins = {}
 orbs = {}
 sniper = {}
 stickys = {}
end

function total_coin_number()
 local total = 0
 for i=1,30 do
  if(dget(i) == 1) total += 1
 end
 return total
end

--level functions
function set_tables() --use mget or fget??

 found_coin = false
 delete_tables()
 --find and set instances to tables

 for i=0,15 do
  for j=0,15 do

   local xx = level_col + i
   local yy = level_row + j
   local obj = mget(xx, yy)
   local i_8 = i*8
   local j_8 = j*8

   if fget(obj,7) then --player
    player_x, player_y, onground, counting_frames, frame_timer= i_8, j_8, true, true, 0
    vsp += 1

    if(mget(xx,yy+1)==11) player_sticky = true
    if(mget(xx-1,yy) == 63) player_dir = -1
   elseif fget(obj,2) then --spikes
    add(spikes,create_instance(i_8,j_8,obj))
   elseif fget(obj,1) then --canon
    local canon = create_instance(i_8,j_8,7)
    canon.t = canon_delay
    set_sprite_dir(xx,yy,canon)
    add(canons,canon)
   elseif fget(obj,4) then --sticky
    local sticky = create_instance(i_8,j_8,11)
    set_sprite_dir(xx,yy,sticky)
    add(stickys,sticky)
   elseif fget(obj,3) then --goal
    add(goal,create_instance(4+i_8,4+j_8,11))
   elseif mget(xx,yy) == 62 then --coin
    if(not got_coin()) add(coins, create_instance(i_8,j_8,62))
   elseif mget(xx,yy) == 13 then --trap
    local t = create_trap(i_8,j_8)
    if mget(xx+1,yy) == 63 then --right
     t.s.spr = 5
     t.v = false
     t.d = 1
    elseif mget(xx-1,yy) == 63 then --left
     t.s.spr = 6
     t.v = false
     t.d = -1
    elseif mget(xx,yy+1)==63 then --down
     t.s.spr = 4
     t.v = true
     t.d = 1
    elseif mget(xx,yy-1)==63 then --up
     t.s.spr = 3
     t.v = true
     t.d = -1
    end
   end
  end
 end

 --load bosses
 if level_number == 7 then
  boss_type = 1
  timer = 0
  boss_fight = true
  if boss_phase > 0 then
   computer_phase2(computer)
   destroy_floor()
  else
   boss_phase = 0
  end
  add(bosses,computer)
 elseif level_number == 15 then
  timer = 0
  boss_fight = true
  boss_type = 3

  if boss_phase > 0 then
   sticker_phase1()
  else
   boss_phase = 0
  end
  add(bosses,sticker)
 elseif level_number == 23 then
  boss_type = 2
  boss_fight = true
  if boss_phase == 1 then
   boss_phase = 1
   eye_fight()
   create_orb()
  elseif boss_phase == 3 then
   boss_phase = 2
   eye_fight()
  elseif boss_phase >= 5 then
   boss_phase = 4
   eye_fight()
  end
  add(bosses,eye)
 elseif level_number == 31 then
  sniper = {}
  boss_fight = true
  boss_type = 4
  if boss_phase == 1 then
   guardian_start()
   guardian_attack(0)
   boss_phase, notify = 1, false
  elseif boss_phase == 2 or boss_phase == 3 then
   guardian_start()
   guardian_attack(1)
   boss_phase = 2
  elseif boss_phase >= 4 then
   guardian_start()
   guardian_attack(0)
   notify, boss_phase = false, 4
  end
  add(bosses, guardian)
 end
 if(boss_fight and boss_phase == 0) play_music(25)
end

function set_sprite_dir(x,y,obj)
 if mget(x+1,y) == 63 then --right
  obj.spr += 1
  obj.h, obj.v = false, 0
 elseif mget(x-1,y) == 63 then --left
  obj.spr += 1
  obj.h, obj.v = true, 0
 elseif mget(x,y+1)==63 then --down
  obj.v, obj.h  = true, 0
 elseif mget(x,y-1)==63 then --up
  obj.v,  obj.h = false, 0
 end
end

function got_coin()
 if(dget(level_number) == 1) return true
 return false
end

function next_level()
 reset_boss(0)
 splash = false
 if not intro and not ending then
  particles = {}
  local next_level = level_number + 1
  if next_level < 32 then
   if found_coin then
    found_coin = false
    dset(level_number, 1)
   end
   if next_level > dget(0) then
    dset(0, level_number + 1)
   end
   if(boss_fight) play_music(10)
   change_level(next_level)
   set_tables()
   set_transition(transition,true)
  end
 end
end

function restart_level()
 change_level(level_number)
 set_tables()
 for i=1,5 do
  create_particles(player_x+4,player_y+4,rnd(2),3,0.5,7)
 end
end

function draw_background(color)
 rectfill(0,0,128,128,color)
end

function change_level(number)
 camera(0,0)
 if level_row <= 16 then
  reload(0x2000, 0x2000, 0x1000)
 else
  reload(0x1000, 0x1000, 0x1000)
 end

 if mget((player_x/8)-1,player_y/8) == 63 then
  player_dir = -1
 else
  player_dir = 1
 end
 player_sticky, hsp, vsp, jump, frame_timer, message_time, level_number = false, 0, 0, 0, 0, 0, number
 level_row = flr(number / 8)
 level_col = (number - level_row * 8) * 16
 level_row = level_row * 16
end

function screen_flash(f)
 f.t += 0.25
 screen_shake()
 if (f.t < 1 and f.f) draw_background(7)
 if f.t > 10 then
  del(flash,f)
  camera(0,0)
 end
end

function reset_palette()
 pal()
 palt(0, false)
 palt(2, true)
end

function draw_coin(c)
 local tet = c.y + sin(coin_t + 0.5)
 spr(c.spr,c.x,tet)
end

function simple_collision(x,y,size1,size2)
 return (abs(x - player_x) < size1 and abs(y - player_y) < size2)
end

function coin_update(c)
 coin_t += 0.015
 if(coin_t > 1) coin_t = 0
 if simple_collision(c.x,c.y,4,4) then
  display_message((total_coin_number()+1).."/10")
  found_coin = true
  play_sfx(19)
  del(coins,c)
  for i=1,10 do
   create_particles(c.x+4,c.y+4,rnd(3),8,0.25,10)
  end
 end
end

function draw_instance(i)
 sspr(i.spr * 8, 0, 8, 8, i.x, i.y, 8, 8, i.h, i.v)
end

function draw_canon(canon)
 if canon.t <= 1 then
  pal(6, 9 ,0)
  pal(5, 4 ,0)
 end
 draw_instance(canon)
 reset_palette()
end

function draw_trap(i)
 if i.t <= 0.8 then
  pal(6, 9 ,0)
  pal(5, 4 ,0)
 end
 spr(i.spr,i.x,i.y)
 reset_palette()
end

function draw_player()
 local flip = false
 local j_frames = 0
 if(player_dir < 0) flip = true
 if(jump > 1) j_frames = 32
 sspr(player_sprite + j_frames, 8, 8, 8, player_x, player_y, 8, 8, flip, false)
end

function draw_particle(p)
 circfill(p.x,p.y,p.r,p.c)
end

function draw_boss()
 if boss_type == 1 then -- draw computer
  rectfill(72,64,112,104,0)
  local p_y = player_y - 8
  if boss_phase == 0 then
   print("password",77,77,3)
   print("please",81,85,3)

   if timer < 3 then
    bprint("hum...",player_x - 4,p_y,7)
   elseif timer > 5 then
    bprint("open?",player_x - 4,p_y,7)
   end

   if timer > 8 then
    reset_boss(1)
    destroy_floor()
   end
  elseif boss_phase == 1 then
   if timer < 2 then
    bprint("great...",player_x - 4,p_y,7)
   end

   if timer < 5 then
    print("security",77,74,8)
    print("threat",81,82,8)
    print("level 1",80,90,8)
   else
    print("password",77,77,3)
    print("please",81,85,3)
   end

   if timer > 7 then
    bprint("cake?",player_x - 4,p_y,7)
    create_particles(20,116,rnd(2),5,0.5,7)
   end

   if timer > 10 then
    computer_phase2(boss)
   end
  elseif boss_phase == 2 then

   if timer < 5 then
    print("security",77,74,8)
    print("threat",81,82,8)
    print("level 2",80,90,8)
   elseif timer < 15 then
    print(-timer + 15,81,82,8)
   end

   dialogue("cmon!",player_x - 3,p_y,0.5,2.5)
   dialogue("really?",player_x - 8,p_y,2.5,5)
   dialogue("i dont!",player_x - 6,p_y,8,10)
   dialogue("know!",player_x - 4,p_y,11,13)
   dialogue("the!",player_x - 2,p_y,13,14)

   if timer > 15 and timer < 18 then
    print("password",77,77,3)
    print("please",81,85,3)
    bprint("password!",player_x - 12,p_y,7)
    canons = {}
    create_particles(20,116,rnd(5),5,0.5,7)
   end

   if timer > 18 then
    print("password",77,77,11)
    print("accepted",77,85,11)
   end

   if timer > 20 then
    play_sfx(18)
    reset_boss(3)
    mset(119,2, 127)
    mset(119,3, 127)
    mset(119,4, 127)
    play_music(40)
   end
  elseif boss_phase == 3 then

   print("password",77,74,3)
   print("is",88,82,3)
   print("password",77,90,3)

   if timer > 1  and timer < 3 then
    bprint("well...",player_x - 3,p_y,7)
   end
  end
 elseif boss_type == 2 then
  sspr(112+ushadow, 8, 8, 8, 56, 56, 8, 8, false, false)
  sspr(112+ushadow, 8, 8, 8, 64, 56, 8, 8, true, false)
  sspr(112+lshadow, 8, 8, 8, 64, 64, 8, 8, true, true)
  sspr(112+lshadow, 8, 8, 8, 56, 64, 8, 8, false, true)
  create_particles(64,64,rnd(5),5,0.25,8)
  spr(29,61+cos(ang)*3,61+ey*5)

  if boss_phase == 0 then
   local p_y = player_y - 8
   dialogue("little thing",41,32, 1, 4)
   dialogue("hi!",player_x,p_y, 2, 3)
   dialogue("where are you going?",27,32, 4, 6)
   dialogue("to the cake shop",player_x - 28,p_y, 6, 9)
   dialogue("cake?",54,32, 8, 10)
   dialogue("i hate cake",43,32, 10, 12)
   dialogue_red("prepare to suffer!",32,32, 12, 16)
   dialogue("welp",player_x - 3,p_y, 13, 16)

   if (timer > 12 and timer <= 12.1) flash_screen(false)
   if timer > 15 and timer < 16 then
    boss_phase = 1
    eye_fight()
    create_orb()
    play_music(30)
   end
  elseif boss_phase == 2 then
   dialogue("auch",56,32,1,4)
   if timer > 5 and timer < 9 then
    bprint("that wasn't nice",33,32,7)
    spawning_particle(8,116)
    spawning_particle(120,116)
    spawning_particle(8,72)
    spawning_particle(120,72)
   elseif timer > 9 then
    boss_phase = 3
    add(spikes,create_instance(8,64,5))
    add(spikes,create_instance(112,64,6))
    add(spikes,create_instance(8,112,3))
    add(spikes,create_instance(112,112,3))
    create_orb()
   end
  elseif boss_phase == 4 then
   if timer > 1 and timer < 4 then
    bprint("stop that!",45,32,7)
   elseif timer > 5 and timer < 9 then
    bprint("now i really hate cake",20,32,8)
    for i=0,1 do
     local mirror = 12 + 104*i
     spawning_particle(mirror,12,5 + i)
     spawning_particle(36 + 56*i,44,3)
     spawning_particle(60 + 8*i,12,4)
     spawning_particle(28 + 72*i,76,6 - i)
     spawning_particle(mirror,100,5 + i)
    end
   elseif  timer > 9 then
    for i=0,1 do
     local mirror = 8 + 104*i
     add(spikes,create_instance(mirror,8,5 + i))
     add(spikes,create_instance(32 + 56*i,40,3))
     add(spikes,create_instance(56 + 8*i,8,4))
     add(spikes,create_instance(24 + 72*i,72,6 - i))
     add(spikes,create_instance(mirror,96,5 + i))
    end

    for i=1,12 do
     create_trap(8 + i*8,120)
    end

    create_orb()
    reset_boss(5)
   end
  elseif boss_phase == 6 then
   local p_y = player_y - 8
   dialogue("for someone",43,32, 2, 4)
   dialogue("who likes cake",38,32, 4, 6)
   dialogue("you move a lot",38,32, 6, 8)
   dialogue("why do you",player_x - 17,p_y, 9, 11)
   dialogue("hate cake?!",player_x - 18,p_y, 11, 13)
   dialogue("i'm an eye",45,32, 14, 16)
   dialogue("i don't have a mouth",28,32, 16, 19)
   dialogue("oh",player_x - 2,p_y, 20, 21)
   dialogue("that makes sense",player_x - 28,p_y, 22, 24)
   dialogue("yep",60,32, 24, 26)
   dialogue("so...",player_x - 8,p_y, 26, 27)
   dialogue("what do you eat?",player_x - 28,p_y, 28, 30)
   dialogue("eye drops",47,32, 30, 32)
   dialogue("obviously...",44,32, 33, 35)

     if timer > 35 then
      create_goal(100,116)
      mset(124,46,15)
      boss_phase = 7
     end
    end
 elseif boss_type == 3 then
  create_particles(64,64,rnd(6),5,0.25,15)
  create_particles(64,64,rnd(6),5,0.25,14)
  if(st_r1) line(11,19,st_x+4,st_y+4,0)
  if(st_r2) line(116,19,st_x+30,st_y+4,0)
  if(st_r3) line(11,67,st_x+4,st_y+30,0)
  if(st_r4) line(116,67,st_x+28,st_y+30,0)

  for i=0,3 do
   for j=0,1 do
    local j_8 = j*8
    sspr(i*16+j_8,40, 8, 8, st_x+j_8, st_y+i*8, 8, 8, false, false)
    sspr(i*16+8-j_8,40, 8, 8, st_x +j_8+16, st_y +i*8, 8, 8, true, false)
   end
  end

  if boss_phase == 0 then
   dialogue("hello",player_x-5,player_y -8,2,4)
   dialogue("do you like cake?",30,40,4,6)
   dialogue("yep",player_x-1,player_y - 8,6,8)
   dialogue("me too",52,40,7,8,10)
   dialogue("cool",player_x-4,player_y -8,9,11)
   dialogue("welp",player_x-3,player_y -8,11,14)
   dialogue("hello",55,40,1,4)

   if timer > 10 and timer < 13 then
    bprint("but i dont like you!",27,40,8)
    flash_screen(false)
   elseif timer > 13 then
    play_music(30)
    sticker_phase1()
   end
  elseif boss_phase == 2 then
   if timer > 18 then
    sspr(24,40, 8, 8, st_x+8, st_y+8, 8, 8, false, true)
    sspr(24,40, 8, 8, st_x+16, st_y+8, 8, 8, true, true)
    sspr(40,40, 8, 8, st_x+8, st_y+16, 8, 8, false, true)
    sspr(40,40, 8, 8, st_x+16, st_y+16, 8, 8, true, true)
   end
   local p_y = player_y - 8
   dialogue("wait...",player_x-3,p_y,1,2)
   dialogue("are you flying?",player_x-25,p_y,2,4)
   dialogue("yes",58,40,5,6)
   dialogue("why the ropes then?",player_x-32,p_y,7,10)
   dialogue("it's called",43,40,10,12)
   dialogue("having a fashion sense",21,40,12,15)
   dialogue("oh",player_x, p_y,14,15)
   dialogue("they looked",player_x - 20,p_y,15,16)
   dialogue("good on you",player_x-20,p_y,16,18)
   dialogue("really? thank you!",30,40,18,20)
   dialogue("now i like you!",35,40,20,23)
   if timer > 23 and timer < 24 then
    timer = 25 --watever
    create_goal(100,108)
    mset(124,29,15)
   end
   if (timer >=25)timer = 25 --watever
  end
 elseif boss_type == 4 then
  line(82,84,64,64,0)
  line(46,84,64,64,0)
  circfill(64,66,21,0)
  circfill(64,66,20,1)
  circfill(64,64,20,5)
  draw_player()
  local gu_x24 = gu_x+24
  circfill(gu_x24,gu_y+21,24,0)
  circfill(gu_x24,gu_y+21,23,7)
  circfill(gu_x24,gu_y+25,24,0)
  circfill(gu_x24,gu_y+25,23,5)
  circfill(gu_x24,gu_y+23,23,6)
  create_particles(64,64,rnd(4),2,0.25,5)
  create_particles(gu_hx-16,gu_hy+40,rnd(4),3,0.25,6)
  create_particles(-gu_hx+142,gu_hy+40,rnd(4),3,0.25,6)
  for i=0,4 do
   for j=0,2 do
    local i_8 = i*8
    local j_8 = j*8
    sspr(i*24+j_8,48, 8, 8, gu_x+j_8, gu_y+i_8, 8, 8, false, false)
    sspr(i*24+16-j_8,48, 8, 8, gu_x +j_8+24, gu_y+i_8, 8, 8, true, false)
   end
  end
  if notify then
   pal(7, 10 ,0)
   pal(6, 9 ,0)
  end
  for i=0,1 do
   for j=0,1 do
    local i_8 = i*8
    local i_16 = i*16
    local j_8 = j*8
    if 1==1 then
     sspr(96+i_16+j_8,40, 8, 8, gu_hx -24+j_8, gu_hy + 32+i_8, 8, 8, false, false)
     sspr(96+i_16+8-j_8,40, 8, 8, -gu_hx+136+j_8, gu_hy+32+i_8, 8, 8, true, false)
    else
     sspr(64+i_16+j_8,40, 8, 8, gu_hx -24+j_8, gu_hy + 32+i_8, 8, 8, false, false)
     sspr(64+i_16+8-j_8,40, 8, 8, -gu_hx+136+j_8, gu_hy+32+i_8, 8, 8, true, false)
    end
   end
  end
  reset_palette()
  local player_y8 = player_y-8
  if boss_phase == 0 then
   dialogue("behold!",53,13,1,3)
   dialogue("i am the guardian of",28,13,3,7)
   dialogue_red("the cake shop!",38,13,7,11)
   dialogue("hum",player_x-1,player_y8,10,12)
   dialogue("i dont see how that's",player_x-34,player_y8,12,14)
   dialogue("good for business",player_x-29,player_y8,14,18)
   dialogue("yeah me neither",35,13,19,21)
   dialogue("sooo...",player_x-4,player_y8,23,25)
   dialogue_red("lets fight!",45,13,26,28)
   if (timer > 7 and timer < 7.5) flash_screen(false)
   if (timer > 26 and timer < 26.5) flash_screen(false)
   if timer > 28 then
    guardian_start()
    boss_phase = 1
    guardian_attack(0)
    play_music(30)
   end
  end
  if boss_phase == 1 then
   dialogue("not bad!",50,13,9,11.5)
   dialogue("piece of cake!",player_x-20,player_y8,11.5,13)
   dialogue("that's not funny",32,13,13,15.5)
   if  timer > 8 and timer < 8.1 then play_sfx(18) flash_screen(true) end
   if(timer > 15) notify = true
   if timer > 16 then
    boss_phase = 2
    guardian_attack(1)
   end
  elseif boss_phase == 2 then
   if timer > 10 then
    boss_phase = 3
    reset_hands()
    play_sfx(18)
    flash_screen(true)
    guardian_attack(-1)
    notify = false
   end
  elseif boss_phase == 3 then
   sniper = {}
   dialogue("stop moving!",43,13,4,6)
   dialogue("nope",player_x-4,player_y8,6,7)
   if(timer > 8) notify = true
   if timer > 10 then
    guardian_attack(0)
    notify = false
    boss_phase = 4
   end
  elseif boss_phase == 4 then
   if (timer > 9) notify = true
   if (timer > 10) guardian_attack(1)
   if gu_attack == 1 and timer > 9 then
    boss_phase = 5
    guardian_attack(-1)
    play_sfx(18)
    flash_screen(true)
    notify = false
    play_music(25)
   end
  elseif boss_phase == 5 then
   sniper = {}
   dialogue("okay",57,13,0,1)
   dialogue("you passed the trial",26,13,2,5)
   dialogue("that sounds",player_x-13,player_y8,5,6.5)
   dialogue("like an excuse",player_x-22,player_y8,6.5,8)
   dialogue_red("shut up!!",48,13,8,10)
   if (timer > 8 and timer < 8.5) flash_screen(false)
   dialogue("go buy your cake",32,13,11,13)
   dialogue_red("before i change my mind",20,13,13,16)
   if timer >= 17 then
    boss_phase = 6
    create_goal(100,116)
    mset(124,62,15)
   end
  end
 end
end

function destroy_floor()
 stickys = {}
 player_sticky = false
 for i=1,5 do
  mset(113+i,5, 127)
  mset(113+i,6, 127)
 end
end

function computer_phase2(boss)
 reset_boss(2)
 local canon = create_instance(16,112,7)
 canon.t = canon_delay
 set_sprite_dir(16,112,canon)
 add(canons,canon)
 mset(114,14, 127)
 mset(118,14, 127)
 play_music(30)
end

function screen_shake()
 local fade = 0.2
 local offset_x=16-rnd(32)
 local offset_y=16-rnd(32)
 offset_x*=shake
 offset_y*=shake
 camera(offset_x,offset_y)
 shake*=fade
end

function bprint(text,x,y,c)
 print(text,x-1,y,0)
 print(text,x+1,y,0)
 print(text,x,y-1,0)
 print(text,x,y+1,0)
 print(text,x,y,c)
end
__gfx__
00000000aaaaaaaabbbbbbbb222222220766665000222222222222002200002200002222222222220000000000000000bb300000000000000000000022222222
00000000aa888aaabbbbbbbb222002220766665077002222222200772076650255550202222222220aaaaa400eeeeee0b30fffe0077777500777775022222222
00700700aa8aa8aabbbbbbbb220750222076650266770022220077662207502266660050222002220a9999400ffffff0bb300fe0076666500766665022111122
00077000aa888aaabbbbbbbb220750222076650266667702207766662007500266665560220a90220a9999400f0ff0f0b30fffe0076666500766665021111112
00077000aa8aaaaabbbbbbbb207665022207502266665502205566660766665066667760220940220a9999400e0ee0e0b30fffe0076666500766665021111112
00700700aa8aaaaabbbbbbbb207665022207502266550022220055660766665066660070222002220a99994030300303bb300fe0076666500766665022111122
00000000aaaaaaaabbbbbbbb0766665022200222550022222222005507666650777702022222222204444440b3b33b3bb30fffe0055555500555555022222222
0000000099999999bbbbbbbb0766665022222222002222222222220007666650000022222222222200000000bbbbbbbbbb300000000000000000000022222222
22222222222220022222222222222222222222222222200222222222222222220777777022000022200022222202202203bbbb30220000222222200022222000
2200002222220aa022000022220000222200002222220990220000222200002205555750206666020070022220e00e0233bbbb30208888022220077722200666
20aaaa022220aaa020aaaa0220aaaa022099990222209990209999022099990200007500207777020777022220aeea02bbbbbb30088888802207777722066777
0aaaaaa022205a500aa5aa500aaaaaa009999990222059500995995009999990200750020aaaaaa0006002220aaaaaa0bbbbbb30088008802077777720677777
0aa5aa502220aaa00aaaaaa00aaaaaa0099599502220999009999990099999900075000005aa54a0200022220aa5aa50bbbbbb30088008802077777720677777
0aaaaaa02220aaa00aaaaaa00aa5aa50099999902220999009999990099599500777777004444aa0222222220aaaaaa0bbbbbb30088888800777777706777777
099999902222099009999990099999900444444022220440044444400444444005555550099999902222222209999990bbbbbb30208888020777777706777777
200000022222200220000002200000022000000222222002200000022000000200000000200000022222222220000002bbbbbb30220000220777777706777777
0000000000000000bbbbbb3003bbbbbb0000000003bbbbbbbbbbbbbbbbbbbb30bbbbbb3003bbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000
0333333333333330bbbbbb3003bbbbbb3333333303bbbbbbbbbbbbbbbbbbbb30bbbbbb3333bbbbbbbbbbbbbbbbbbbbbb03333333333333333333333003333330
03bbbbbbbbbbbb30bbbbbb3003bbbbbbbbbbbbbb03bbbbbbbbbbbbbbbbbbbb30bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb03bbbbbbbbbbbbbbbbbbbb3003bbbb30
03bbbbbbbbbbbb30bbbbbb3003bbbbbbbbbbbbbb03bbbbbbbbbbbbbbbbbbbb30bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb03bbbbbbbbbbbbbbbbbbbb3003bbbb30
03bbbbbbbbbbbb30bbbbbb3003bbbbbbbbbbbbbb03bbbbbbbbbbbbbbbbbbbb30bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb03bbbbbbbbbbbbbbbbbbbb3003bbbb30
03bbbbbbbbbbbb30bbbbbb3003bbbbbbbbbbbbbb03bbbbbbbbbbbbbbbbbbbb30bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb03bbbbbbbbbbbbbbbbbbbb3003bbbb30
03bbbbbbbbbbbb303333333003333333bbbbbbbb03bbbbbb33333333bbbbbb30bbbbbbbbbbbbbbbb33bbbbbbbbbbbb3303333333333333333333333003bbbb30
03bbbbbbbbbbbb300000000000000000bbbbbbbb03bbbbbb00000000bbbbbb30bbbbbbbbbbbbbbbb03bbbbbbbbbbbb3000000000000000000000000003bbbb30
03bbbb3003bbbb30bbbbbbbb03bbbb3000000000bbbbbb3003bbbbbb03bbbb3003bbbbbb00000000bbbbbb300000000003bbbbbb0000000022222222aaaaaaaa
03bbbb3003bbbb30bbbbbbbb33bbbb3303333330bbbbbb3333bbbbbb03bbbb3303bbbbbb33333333bbbbbb303333333033bbbbbb3333333322200222aa88aaaa
03bbbb3003bbbb30bbbbbbbbbbbbbbbb03bbbb30bbbbbbbbbbbbbbbb03bbbbbb03bbbbbbbbbbbbbbbbbbbb30bbbbbb30bbbbbbbbbbbbbbbb220aa022aa8a8aaa
03bbbb3003bbbb30bbbbbbbbbbbbbbbb03bbbb30bbbbbbbbbbbbbbbb03bbbbbb03bbbbbbbbbbbbbbbbbbbb30bbbbbb30bbbbbbbbbbbbbbbb20a99402aa8aa8aa
03bbbb3003bbbb30bbbbbbbbbbbbbbbb03bbbb30bbbbbbbbbbbbbbbb03bbbbbb03bbbbbbbbbbbbbbbbbbbb30bbbbbb30bbbbbbbbbbbbbbbb20a99402aa8aa8aa
03bbbb3003bbbb30bbbbbbbbbbbbbbbb03bbbb30bbbbbbbbbbbbbbbb03bbbbbb03bbbbbbbbbbbbbbbbbbbb30bbbbbb30bbbbbbbbbbbbbbbb22044022aa8a8aaa
03bbbb300333333033bbbb33bbbbbbbb03333330bbbbbb3333bbbbbb03bbbbbb03bbbb33bbbbbb3333bbbb3033bbbb303333333333bbbbbb22200222aa88aaaa
03bbbb300000000003bbbb30bbbbbbbb00000000bbbbbb3003bbbbbb03bbbbbb03bbbb30bbbbbb3003bbbb3003bbbb300000000003bbbbbb2222222222222222
2222222222222222220000002222220aaaaaaaaaaaaa555a20aaaaaaaaaaa5555aaaa0aa0aaaaaaaaaaaaaaaa00000002220aaaaa99999999aaaaaaa22222222
222222222222222000aaaaaa222220aaaaaaaaaaaaaaaa5520aaaaaaaaaaaaaaaaaaa0aa0aa99aaaaaaaa00000888877222200aaaaaaa9999999999922200222
2220022222222200aaaaaaaa22220aaaaaaaa00000aaaa5520aaaaaaaaaaaaaaaaaaa0aa0aa99aaaaaaaa0088888887722222000aaaaaaaaaaaaaaaa22088022
22011022222200aaaaaaaaaa2220aaaaaaaa0077700aaaa520aaaaaaaaaaaaaaaaaaa00a0aaa9aaaaaaaa9000000000022222220000aaaaaaaaaaaaa00088000
220110222220aaaaaaaaaaaa2220aaaaaaaa07755700aaaa00aaaaaaaaaaaaaaaaaaa9000aaa99aaaaaaaa999999999922222222200000000000000007777770
22200222200aaaaaaa5555a5220aaaaaaaaa07755770aaaa0aaaaaaaaaaaaaaaaaaaaa9900aaa99aaaaaaaaaaaaaaaaa22222222222222222222222209999990
222222220aaaaaaaaaaaa555220aaaaaaaaa00000000aaaa0aaaaaaaaaaaaaaaaaaaaaaa20aaaa99aaaaaaaaaaaaaaaa22222222222222222222222207777770
22222222aaaaaaaa5555aaaa220aaaaaaaaa99999999aaaa0aaaaaaaaaaaaaaaaaaaaaaa220aaaaa9aaaaaaaaaaaaaaa22222222222222222222222200000000
22222222222222222220ffff0006600f220ffffffddddfff222220ffffffffff2222222222222222207007077070702222222222200022222207777666670222
222222222222222222200ff00667760f2200ffffffffffff222200ffffffffff2222222002222222207007777770702222222222007022222200777777770222
222200000022222222220ff06777770f2220ffffffffff0022200fffffffffff2222220770222222207707777770702222222200077022222220077777770222
22200eeee002000222220ff07077770f22200fffffff000d2220dfffffffffff2222200770022222220777777777702222200066000022222220000770000222
2200effffe000e0022220ff05777750f222200fffff00ddf2220dfffffffffff2222070770702222220677777777602222007777666022222220060006600222
220effffffeeefee22200ff00577500f222220ffff0ddfff22200dffffffffff2222070770702222222067777776022222000777777002222222006666002222
220effffffffffff2220fffd005500df222220ffffffffff222200dddddddddd2222070770700222222206666666022222060000770002222222200000022222
2200ffffff0000ff220fffffd0000dff222220ffffffffff22222000000000002202070770707022222220000000222222076666000602222222222222222222
22222222222222222222222222220077777702222222222222067777777777777700222222220060aaaa0aaa0077777022222022222222222200a99922222222
222222222222222222222222222207777777002222222222220677777777777777702222222220009aaaaaaaa077777022222202222222222220aa9902020022
22222222222222222222222222207777777770022222222222067777700000777770022222222200099aaaaaa07777002222222022222222222200aa02020222
2222222222222222222222222220777777777700222222222206777700aaa00777770222222222220009999aa007700922222222002222222222200002020222
222222222222222222222222220077777777777002222222220677700aaaaa007777002222222222222000099900009922222222200022222222222200220022
22222222200002222222222222067777777777770022222222206770aaaaaaa07777702222222222222222000000999922222222222000022222222202020222
22222220007022222222222222067777777777777022222222206770aaaaaaa007777702222222222222222220a9999922222222222222000000222202020222
22222000777002222222222222067777777777777002222222220670aaaaaaaa077777002222022222222222200a999922222222222222222220000002020022
22002222222222222222222222222222222222222222222220022067007022070207670667020666670206602220222222222222222222220000000022222222
20770222222222222222222222200000022222022220222207702067020702070076060607020600002205502200222220022022222222220666665022222222
20667022222022202222222222077777702220702200222206702067020702070076060607020602222220022002202202220202222222220644445022222222
22066702220702070220222222207000770207702202222206702067020760702076060607020602222222222202202202220202222222220644445022222222
22206670220702070207022202207022070207702200022205660665020766702076055507020602222220022200002202220002222222220644445022222222
22220670207022070207022070207022077006702022202220566650220566502076000006020602222206702200200002220202222222220644445022222222
22222067007022070207702067007022207006602202002222055502222055002050222205020502222205502200002202220202222222220555555022222222
22222067007022070207700067020700077006602200022222200022222200222202222220222022222220022222222220020202222222220000000022222222
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
2020202020202020202020202020202020b2626262a2b26262626262626262a2202020202020b26262a2202020202020b26262626262626262626262626262a2
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202020202020202020b22240404032a30000000000000060522020202020207200f05220202020202072000000000000000000000000000052
202020202020b26262626262a22020202020b2626262626262626262a2202020202020202020202020202020202020202020202020202020202020b2626262a2
20202020202020202020202020202020725000000060030000000000000060522020202020207200005220202020202072000000000000000000000000000052
20202020202072000000000052202020202072000000000000000000522020202020202020202020202020202020202020202020202020202020207200000052
b262626262626262626262626262a22072500000f06013100000000000006052202020202020d0f3f3d020202020202072000000000000000000000000000052
20202020202072f0000000005220202020207200000000000000f00052202020202020b262d062d062d062d062a2202020202020202020202020207200f00052
7250000000000000000000000000522072500000000040b050000000000060522020202020207200005220202020202072000000000000000000000000000052
20202020202082421200000052202020202072000000000000000000522020202020207210f300f300f300f30052202020b26262626262626262622200000052
72000000000000000000000000005220725000000000004000000000000060522020202020207200005220202020202072000000000000000000000000000052
2020b2626262a2207200000052202020202072000000d050000002429220202020202082b042b042b042b0120052202020720000000000000000000000000052
72000000000000000000000000f0522072500000000000000000000000f3b0522020202020207200005220202020202072000000f2000000000000f200000052
20207200000032622200000052202020202072000000430000e3522020202020202020b262626262626262220052202020720000000000000000000000000052
7200000060d0d2d2d2d0d2d2d2d2632072b0f300000000000000000000006052202020202020d0f3f3d020202020202072000000030000000000000300000052
20207200000000000000000052202020202072000000000000605220202020202020207200000000000000000052202020720000000000000000000000000052
72000000000000000000000000605220725000000000003000000000000060522020202020207200005220202020202072000000030000000000000300000052
202072000000f3f3f300000052202020202072000000000000005220202020202020207200024242424242424292202020725000000000300000003000000052
7200000000000000000000000060522072500000000060f250000000000060522020202020207200005220202020202072000000030000000000000300000052
202072000000d0d0d0000000522020202020720000000000000052202020202020202072003262626262626262a220202072500000a060435043604350000052
7250100000000000000000000000522082123030b030027250000000000060522020202020207200005220202020202072000000130000000000001300000052
2020720000005220720000e352202020202072000060d05000005220202020202020207200000000000000000052202020725000000000400000004000000052
8242424242d0424242d042424242922020824242424292725000000000006052202020202020d0f3f3d020202020202072000000000000000000000000000052
2020720000005220723030305220202020207200000000000000522020202020202020720000000000000000f052202020725000000000000000000000000052
20202020202020202020202020202020202020202020207250000000000060522020202020207200005220202020202072000000000000d7d700000000000052
202072000000522082424242922020202020720010000000000052202020202020202082b0d0b0d0b0d0b0d04292202020725000000000100000000000000052
202020202020202020202020202020202020202020202082123030303030029220202020202072000052202020202020720000000000d71000d7000000000052
202072100000522020202020202020202020824242424242b0429220202020202020202020202020202020202020202020824242424242424242424242424292
20202020202020202020202020202020202020202020202082424242424292202020202020207210005220202020202072000000000043b0b043000000000052
202082b0424292202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
202020202020202020202020202020202020202020202020202020202020202020202020202082b0b09220202020202082424242424242424242424242424292
b26262626262626262626262626262a2202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202020202020202020202020202020202020202020202020202020202020b262626262a22020202020b26262626262626262626262626262a2
7200000000000000000000000000005220202020202020b262626262626262a220b2626262626262626262626262a2202020202020b26262d0d0d06262a22020
202020202020202020202020202020202020b262626262626262626262a220202020b26262224040404052202020202072000000000000000000000000000052
720000000000000000000000000000522020202020202072404040404040405220720000000000000000000000005220202020202072f3f3f3f3f3f3f3322020
b26262626262626262626262626262a22020720000000000000000000052202020b2224040400000000052202020202072000000000000000000000000000052
720000000000000000000000000000522020202020202072000000000000005220720000000000000000000000005220202020202072000000000000f3d02020
72000000000000000000000000000052202072000000000000000000005220202072500000000000000052202020202072000000000000000000000000000052
72000000000000000000303002120052202020202020b2220000000000000052207200f00000000000000000000052202020202020720000d0d0d000f3d02020
72000000000000000000000000000052202072100000000000000000004362a22072500000000000000052202020202072000000000000000000000000000052
721000000000000030300242927200522020202020207250000000000000005220720000000000000000000000005220202020202072000052207200f3d02020
72000000000000000000000000000052b26243a0a0a0a0a0a0a0a0a0a0f370522072000000000000000083626262a22072000000000000000000000000000052
8242424212303002424292202072005220202020202072e20000000000000052207200000000000000000000000052202020202020c0f3005220c0f3f3d02020
7200f0000000000000000000000000527270f3a0a0a0a0a0a0a0a0a0a043d2632072000000700000000013404040522072000000000000000000000000000052
20202020824242922020202020720052202020202020725000000000000000522072000000000000000060f200005220202020b2622200005220c0f3f3d02020
53d2d31200000000000000000000005253d243a0a0a0a0a0a0a0a0a0a0f370522072000000f20000000040000000522072000000000000000000000000000052
b262626262626262626262626222005220202020202072500000000000f310522072000000604350e30060130000522020202072000000005220d0f3f3d02020
721032220000000000000000000000527270f3a0a0a0a0a0a0a0a0a0a043d26320b0f30000030000000000000000522072000000000000000000000000000052
7200000000000000000000e30000005220b26262626222e2a0a0a0a0a0a0d0522072000000004000000000400000522020202072f000f3f35220d0f3f3d02020
7200000000000000000000000000005253d243a0a0a0a0a0a0a0a0a0a0f37052b222000000033000000000000000522072000000000000000000000000000052
720000000000000000000000000000522072000000000000000000000000005220721000000000000000000000005220202020824242d0d09220d0f3f3d02020
72a0a0a0a0a0d0a0a0a0d0a0a0a0a0527270f3a0a0a0a0a0a0a0a0a0a043429272f000000073125000000000f310522072000000000000000000000000000052
7200f000000000000000000000000052207200f00000000000000000000000522072a0a0a0a0a0a0a0a0a0a043a0522020b2626262d0d0d0d0d0d0f3f3d02020
72000000000000000000000000000052824243a0a0a0a0a0a0a0a0a0a05220208212d0d0d0527250007000e302b0922072000000000000000000000000000052
8242421230300000000000000000005220824242424212d0d0d0d0d0d0d0d0522072f3f3f3f3f300f3f3f3f3f3f352202072000000f3f3f3f3f3000000522020
72303030303030303030303030303052202072a0a0a0a0a0a0a0a0a0a0522020208242424292821230f250005220202072000000000000d7d700000000000052
20202082421230300000000000000052202020202020824242424242424242922072707070707030707070707070522020720010000000000000000000522020
82424242424242424242424242424292202072a0a0a0a0a0a0a0a0a0a052202020202020202020824233123052202020720000000000d71000d7000000000052
20202020208242421230300242424292202020202020202020202020202020202082424242424242424242424242922020824242b0d0d0d0d0d042b0b0922020
202020202020202020202020202020202020723030303030303000f0005220202020202020202020202082429220202072000000000043b0b043000000000052
20202020202020208242429220202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202020202020202020202082424242424242424242429220202020202020202020202020202020202082b0b0b0b0b0b0b0b0b0b0b0b0b0b092
__gff__
008001040404044242002150504041090101010101010101000000010100000001010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a100
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202020202022b2626262626262a2b26262626262626262626262626262a02020202020202020202020202020202022b26262626262626262a2b2626262a0202020202020202020202020202020202020202022b26262626262a0202020202020202020202020202020202020202
020202020202020202020202020202020202020202020202270000000000002527000000000000000000000000000025020202020202020202020202020202022b2204040404040404042527000f00250202020202020202020202020202020202020202022700000000002502020202022b2626262626262626262a02020202
020202020202020202020202020202020202020202020202270100000000002527000000000000000000000000000025020202022b2626262626262626262a022705000000003e000000232200000025022b2626262626262626262626262a02022b262a0227000f0000002502020202022700000000000e0000002502020202
020202020202020202020202020202022b26262626262626222d2d2d2e000025270000000000000000000000000000250202020227000000000000000000250227000000000000000000000000000025022700000000000000000000000025020227002502270000000000232a020202022700000000000e000f002502020202
020202020202020202020202020202022700000000000000000000000000002527000f0000000000000000000000002502020202270000000000000000002502270000000000000000000000000000250227000000000000000000000000250202270025022705000000000625020202022700000100000e0000002502020202
2b26262626262626262626262626262a27000000000000000000000000000025282424242424210303202421000000250202020227000000000000000f0025022700000000000000000000000000062502270001000000000000000000002502022700250227050000000006250202020227240b0b0b24202424242902020202
2700000000000000000000000000002527000000000000000000000000000025020202020202282424290227000000250202020227000000000000202424290227050000000000000000000000000025022824242f0a0a0a0a0a2f0000002502022700250227050a000000062502020202272626262626250202020202020202
270000000000000000000000000000252700002f000020210000202424242429020202020202020202020227000000250202020227000000000000250202020227050000000000000000000000000025020202023000000000003005000025020227002502270500000000062502020202270000000000250e0e0e0e0e0e0e02
27000000000000000000000000000025270000300303252703032502020202022b26262626262626262626220000002502020202270000000000002502020202270000000020242424210000000000250202020230030303030330050000250202270025022705000000002c2502020202270000000000250e00000000000e02
270000000000000000000000000000252700003024242928242429020202020227000000000000000000000000000025022b262622000000000000250202020227030303032502020227000000000025022b2626342d2d2d2d2d3400000025020227002502270500000000062502020202270000000000250e00000000000e02
27000000000000000000000000000025270000302626262a020202020202020227000000000000000000000000000025022700000000000000000025020202022824242424290202022700000000002502270000000000000000000000002502022700250227050a000000062502020202270000000000250e00000000000e02
27010000000000000000000000000f25270000310000002502020202020202022700000000000000000000000000002502270000000000000000002502020202020202020202020202270000000000250227000f0000000000000000000025020227002502270500000000062502020202270000000000250e00000000000e02
28240b2100002024242100000020242927000000000000250202020202020202270100000000000000000000000000250227010000000000000000250202020202020202020202020227000000000025022700000000000000000000000025020227072502270500000000202902020202270000000000250e00000000000e02
020202270303250202270303032502022700000000000025020202020202020228242421000020242100002024242429022824242100000000000025020202020202020202020202022700000000002502282421000000000a000000202429020228242902270000000000250202020202273f0000003f250e0e0e0e0e0e0e02
0202022824242902022824242429020227030300000f00250202020202020202020202270303250227030325020202020202020227030303030303250202020202020202020202020227000001000025020202270303030303030303250202020202020202270100000000250202020202270003030303250202020202020202
020202020202020202020202020202022824242424242429020202020202020202020228242429022824242902020202020202022824242424242429020202020202020202020202022824240b242429020202282424242424242424290202020202020202282424242424290202020202282424242424290202020202020202
020202020202022b2626262a020202022b26262626262626262626262626262a02020202020202020202020202020202022b2626262626262626262626262a0202022b262626262626262626262a020202020202020202020202020202020202020202020202022b2626262a020202022b2626262626262a2b2626262626262a
2b26262626262622070707232626262a270000000000000030000000000000250202022b262626262626262626262a0202270700000000000000000000002502020227000000000000000000002502022b26262626262626262626262626262a0202020202020227070407250202020227050000000000252700000000000625
27000000000000003f3f3f0000000025270000000000000f310000000000002502022b2204040404040404040404250202273f00000000000000000000002502020227000000000000000000002502022700000000000000000000000000002502020202020202273f003f2502020202280e0000000000232200000000000e29
27000000000000000000000000000025270000000000002f000000003f01002502022705000000000000000000002502022700000000003f3f000000000025020202270000000000000000000025020227000f000000000000000000000000250202020202020227000000250202020202270000000000040400000000002502
270000000000000000000000000000252700000000000331000000202424242902022700000000000000000000002502022700000000200b0b21000000002502020227000000202424210000002502022700000000000000000000000000002502020202022b2622003e00250202020202270000000000000000000000002502
270000000000000000000000000000252700000000002f0000000325020202022b26223e00000000000000000f00250202270000000025020227000000002502020227000000252b2622000000250202270000000000000000000000000000250202020202270000000000250202020202270000000000000000000000002502
27000000200b210000000000000f00252700000000003100000320290202020227000000000000000000000000002502022700000000250202270000000025020202270500002527000000000025020227000000062f050000000000000000250202020202270f00000000250202020202270500000000000000000000062502
270000002502270b0b0b0b0b2024242927000000002f000000202902020202022700000000000000000303030303250202270000000025020227000000002502020227000000252700000000002502022700000006310500000000000000002502020202022824213f003f0b02020202022700000000007d7d00000000002502
270000002502282424392d2d3c26262a270000000331000003250202020202022700002f0500002c2d2d2d2d2d2d3602022700000000250202270000000025020202270000002527000003030325020227000000000400000000000000000025020202020202020b3f003f0b02020202020e00000000007d7d00000000000e02
27000000232626262622000000000025270000002f00000320290202020202022700003000000004040404040404250202270000000025022b22000000002502020227000006252700002c2d2d36020227000000000000000000062f00000025020202020202020b3f003f0b02020202022700000000007d7d00000000002502
270000000000000000000000000000252700000031000020290202020202020227000031000000000000000000002502022700000000250227000000003e25020202270000002527000000000025020227000000000000000000063003030325020202020202020b3f003f0b0202020202270000000000000000000000002502
270000000000000000000000003f012527000000000003250202020202020202270000000000000000000000000025020227000000002502270f0000000025020202270000002527000000000025020227000000002f0000000006372424242902020202022b26223f003f0b02020202022700000000007d7d00000000002502
2700000000000000000000002c3d0b292700000000002029020202020202020227000000000000000000000000002502022700000000250228210000003f25020202270500002527030300000025020227000100003003030303032502020202020202020227000000003f0b020202020227000000007d01007d000000002502
27000000000000000000003f08250202273e00000003250202020202020202022700000000000000000000000000232a022700000000250202270000000725020202270000002528242100000025020228240b24243324242424242902020202020202020227000100003f0b02020202022700000000340b0b34000000002502
270b0b0b0b0b0b0b0b0b0b0b2029020227030303032029020202020202020202270100000000000000000000003f0725022821000100250202270303032029020202270001002502022703030f25020202020202020202020202020202020202020202020228240b0b0b0b020202020202280e0e0e0e0e0e0e0e0e0e0e0e2902
2824242424242424242424242902020228242424242902020202020202020202282424242424242424242424242424290202280b0b0b29020228242424290202020228240b2429020228242424290202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
__sfx__
010100000c2500d2500e2500f25010250112500050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000018250192501a2501b2501c2501d2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001d4501c4501b4501a450194501825011250102500f2500e2500d2500c2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000025001250032500425005250062500725008250092500a2500b2500c2500d2500e2500f2501025011250122501325014250152501625016250172501825019250192501a2501b2501c2501d2501f250
010100001b2501a2501a25019250182501725017250152501425013250122501125010250102500e2500d2500c2500b2500a25009250092500825008250072500725006250052500425003250032500225001250
0101000001630016300063000600006000b2000230009300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000545007450094500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000007250082500a25002400034000f25008200182501020010200222501b200002002d250362500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000016450164501545013450104500b2500625002250002500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000955003250030500705005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000029755247052470524705247052470524755247052475524705247552470524705247052d7552470524705247052470524705247052470524755247052475524705247052470524755247052470524705
00100000117101571011720157201173015730117401574011750157501174015740117301573011720157200c710157100c720157200c730157300c740157400c750157500c740157400c730157300c72015720
001000000c76301050050500c76318643080500c763010500105001050010500c763186430805006050050500c76308050080500c763186430105004050070500405004050000500c76318643040500c76300000
001000000505505055050550505505055050550505505055050550505505055050550505505055050550505505055050550505505055050550505505055050550505505055050550505505055050550505505055
001000000564500605006050060535625006050060535605056450060505645006053562500605006050560505645006050060500605356250060500605356050564500605056450060535625006050564500605
00100000297552470524705247052470524705247552470524755247052475524705247052470529755247052470524705247052470524705297052470524705297562d755307553575500000000000000000000
001000001171015710117201572011730157301174015740107501375010740137401073013730117301570011700157001170015700117001570011700157001170015700000000000000000000000000000000
001000000005500055000550005500055000550005500055000550005500055000550005500055050550503505035050350503505035050350503505035050350503505035050350503505035050350503505035
000100002e6502b650246501d65018650106500b65005650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000022150241502415025150261502e150361503a150372003400002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001d1501d1501d1501d1501d1501d1501d1501d150181501815018150181502215022150221502215021150211502115021150211502115021150211501d1501d1501d1501d1501d1501d1501d1501d150
0108000024353023553455529555375552d5552f5552f5452f5352f5252f515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001171015710117201572011730157301174015740117501675011740167401173016730117201672011710157101172015720117301573011740157401175013750117401374011730137301172013720
001000000505500005000050000500005000050a055000050a0550000500005000050000500005000050000505055000050000500005000050000500055000050005500005000550000502055000050405500005
001000000564500605006050060535625006050060500605056450060505645006053562500605006050060505645006050060500605356250060505645006050060500605056450060535625006050060500605
001000001d7561d755217552475500700007011d7510070018752187550070000700007000070018751187551975500700007000070000700007001975119755187521875500700007010c756187552475530755
001000001d7561d755217552475500700187011d751007001875218755007000070000700007001875118755247550070000700007000070000700257512575528752287551870018701107561c7552875534755
00100000050550000505055000050000500005000550000500055000050000500005000550000500005000050a055000050a05500005000050000500055000050005500005000050000500055000550205504055
00100000297561f75521755227551d7001d7001f7511f755217512175221752217551d7511d7521d7521d7552e7561a7551d7552175522751227551f7511f7552175121752217522175221752217522175221755
00100000157451574515745157450070500705167451674518745187451874518745157451574515745157451a7451a7451a7451a745187451874516745167451874518745187451874518745187451874518745
00100000297561f75521755227551d7001d7001f7511f755217512175221752217551d7511d7521d7521d7552e7561a7551d7552175522751227551f7511f7551d7511d7521d7521d7521d7521d7521d7521d755
00100000157451574515745157450070500705167451674518745187451874518745157451574515745157451a7451a7451a7451a74518745187451674516745157122d715157222d725157322d735157422d745
001000000505500005050550000500005000050005500005000550000500055000050000500005000550000501055000050105500005000050000501055000050005500005000550000502055000050405500005
001000001175500705117550070500705007050c755007050c755007050c7550070500705007050c755007050d755007050d7550070500705007050d755007050c755007050c755007050e755007051075500705
001000001575500705157550070500705007051075500705107550070510755007050070500705107550070511755007051175500705007050070511755007051075500705107550070511755007051375500705
0010000015755007051575500705007050070510755007051075500705107550070500705007051c755007051d755007050070500000000000000000000000000000000000000000000000000000000000000000
001000001175500705117550070500705007050c755007050c755007050c7550070500705007050c7550070511050000000000000000000000000000000000000000000000000000000000000000000000000000
001000000505500005050550000500005000050005500005000550000500055000050000500005000550000505055000050505500005000050000505055000050c05500005180550000516055000051305500005
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003561505625056250562535615056250562505625356150562505625056253561505625056250562535615056250562505625356150562505625056253561505625056250562535615056250562505625
001000000505500005050550000500055000050005500005010550000501055000050005500005000550000505055000050505500005000550000500055000050105500005010550000500055000050405500005
00100000111450010500105001050010500105111450010510145001050010500105001050010510145001050d14500105001050010500105001050d145001050c14500105001050010500105000000c14500000
00100000111450010500105001050010500105111450010510145001050010500105001050010510145001050d14500105001050010500105001050d145001051014500105001051005110150001051014000105
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000564500605356250060505645006053562500605056450060535625006050564505645356250564505645006053562500605056450060535625006050564500605356250060535625356353564535655
001000000505500005110550000505055000051105500005050550000511055000050505500005110550000505055000051105500005050550000511055000050505500005110550000505055000051105500005
011000001135514355113551435511355143551135514355113551335511355133551135513355113551335511355163551135516355113551635511355163551035516355103551635510355163551035516355
01100000183551825519355192551835518255193551925518355182551a3551a25518355182551a3551a25518355182551b3551b25518355182551b3551b25518355182551c3551c25518355182551c3551c255
001000001d3551d2551d3551d2551d3551d2551d3551d2551f3551f2551f3551f2551f3551f2551f3551f255203552025520355202551f3551f25520355202552235522255223552225522355222552235522255
001000002435524255243552425524355242552435524255223552225522355222552235522255223552225520355202552035520255203552025522355222551f3252b2251f3352b2351f3452b2451f3552b255
001000001105511055110551105111052110521105211051110551105500000110511105500000000000505500000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000113550c2551135515251113521525218352152511835511255007001d3511d25500700007001d35500700007000070000700007000070000700007000070000700007000070000700007000070000700
001000001535511255153551825115352182521d352182511d3552125500700213512125500700007002135500700007000070000700003000030000300003000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000110550c005110550c0050c0050c0050c0550c0050c0550c0050c0550c0050c0050c0050c05500005160550c005160550c0050c0050c005160550c005180550c0050c0550c0050e0500c0051005500005
001000001171411712117121171211712117121171211715137241372213722137221372213722137221372515734157321573215732157321573215732157351674416742167421674518754187521875218755
001000001571415712157121571215712157121571215715167241672216722167221672216722167221672518734187321873218732187321873218732187351a7441a7421a7421a7451c7541c7521c7521c755
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001105011050110500c0500c0500c0501105000000000001105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001d7501c7501d7501f7501d7501f7502173000700217002173000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00100000217501f750217502275021750247503573000700247003573000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 41 42 43 44
01 0a 0b 0d 0e
02 0f 10 11 0e
00 41 42 43 44
01 0e 17 43 2a
02 0e 17 43 2b
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 41 1b 18 0e
01 41 16 17 18
00 41 16 17 18
00 19 16 17 18
00 1a 16 17 18
00 1c 1d 1b 18
00 1e 1f 1b 18
00 22 21 20 18
00 23 24 25 18
00 41 38 37 18
02 39 38 37 18
01 41 42 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 41 2a 29 28
02 41 2b 29 28
00 41 42 43 44
00 41 42 03 04
00 41 42 43 44
01 41 2f 2e 2d
00 30 2f 2e 2d
00 31 2f 2e 2d
02 32 2f 2e 2d
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 35 34 33 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 3e 3d 3c 44
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
