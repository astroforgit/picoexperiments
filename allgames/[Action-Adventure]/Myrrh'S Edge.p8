pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- myrrh's edge
-- by three unwise men
-- a religious parkour game
-------------------------------
-- design/sfx: that tom hall
-- code: squirrel eiserloh
-- art / anims: toby hefflin
-- also featuring
--  music: gruber
-------------------------------

cls(0)

spr_player = 64
spr_key = 47
spr_myrrh = 44
spr_star = 27
spr_fire = 106
spr_stairs_up = 31
spr_stairs_down = 20
spr_door_open = 22
spr_door_locked = 23
spr_wire = 10
spr_wire_end = 13
spr_zip_top = 11
spr_zip_bottom = 12
spr_zip_end = 13
spr_slide1 = 116
spr_slide2 = 117
spr_melee_idle = 95
spr_sheep_idle = 101
spr_mouse_idle = 76

sfx_title = 54
sfx_jump = 5
sfx_getkey = 53
sfx_getmyrrh = 6
sfx_open_y = 7
sfx_open_n = 1
sfx_door = 46
sfx_zip = 7
sfx_wire = 7
sfx_charge = 49
sfx_hit = 45

bit_solid_u = 0
bit_solid_r = 1
bit_solid_l = 2
bit_solid_d = 3
bit_ladder = 5

g_pr = 3
g_grab_ladder_dist_x = 3
g_walk_vx = 1
g_wjump_vx = 50
g_wjump_vy = 65
g_wjump_dist = 4
g_max_wally_vy = 60
g_max_speed = 0.95 * g_pr * 60
g_zip_vx = 70
g_zip_vy = 35
g_zip_jump_vx = 50
g_zip_jump_vy = 65
g_awn_vx = 75
g_awn_vy = 75
g_air_friction_x = 1.0
g_air_control = 0.5
g_slide_min_vx = 40
g_slide_max_vx = 70
g_wall_jump_delay = 10
g_player_max_runx = 50
g_melee_see_x = 60
g_melee_see_y = 3
g_melee_walk_dx = 0.3
g_melee_charge_dx = 1.2
g_min_myrrh = 50
g_hs_myrrh = 0
g_hs_time = 9999.9

g_state = "title"
g_actordefs = {}
g_actors = {}
g_layers = { fg={}, mid={}, bg={} }
g_buckets = {}
g_nbuckets = 6
g_player = nil
g_time = 0.0
g_frame = 0
g_sign = { fr=0, msg1="", msg2="", wx=0, wy=0 }
g_track_col = 12

g_signs = {
 { 20,46,"bethlehem inn","no vacancy" },
 { 39,46,"sunshade market","sheep 4 cheap!" },
 { 35,23,"guard watchtower","watch guards beat thieves!" },
 { 125,7,"grain silo","hayyyyyy" },
 { 17,36,"tenements","much better than ninements" },
 { 125,51,"king herod sux","" },
 { 126,42,"town myrrh storage","do not take" },
 { 2,51,"cave","of souls" },
 { 54,61,"cave of","the lost" },
 { 79,62,"cave of","gentle winds" },
 { 87,62,"tomb of","zombie bill myrrhy" },
 { 100,32,"manger","(that's a feeding trough, btw)" },
 { 73,9,"getting good at","wall-jumping, huh?" },
 { 111,30,"baby jesus's xmas wish:","50 myrrh"}
}

g_snarkers = { "caspar", "melchior", "mary", "joseph", "jesus", "sheep", "fruit" }
g_snark_xys = { {113,30}, {114,30}, {116.7,30.25}, {117.3,30.25}, {116,30}, {119,29}, {110,29.25} }
g_snarks = {
 {1,"gold, frankincense, and"      ,"a heartfelt apology"},
 {2,"what happened, did your"      ,"sundial break again?"},
 {1,"you had one job, bal."        ,"one.  job."},
 {2,"i'm sure next time a savior"  ,"is born you'll make it on time"},
 {1,"it's cool, we put a crown on" ,"a sheep and said it was you."},
 {2,"ladies and gentlemen,"        ,"the king of punctuality"},
 {1,"sheep here for the birth: 2"  ,"kings of tarse and egypt: 0"},
 {2,"apologize to the lovely"      ,"couple, bal..."},
 {1,"missed the print deadline:"   ,"two wise men at savior's birth"},
 {2,"we put this hay bale there...","cuz hay, you bailed on us"},
 {1,"nice, bal, real classy-like." ,"guess you won't be in the song"},
 {3,"i gave birth to the one true" ,"god's kid, and you overslept?"},
 {3,"baby jesus' first word was:"  ,"'late'"},
 {4,"jesus,"                       ,"this guy's late."},
 {4,"hey, thanks for showin' up...","you know, eventually..."},
 {6,"baaaaad job,"                 ,"baaaaal"},
 {7,"i have no limbs, and"        ,"even *i* made it to the birth"}
}

g_spr_best={89,121,59,51,50,89,24,52,59}
g_spr_title={54,55,56,56,57,58,59,50,121,120,62,121}
g_rainbow1={3,11,1,0,12,15,4,9,10,7,6,5,14,13}

-------------------------------
function _init()
 load_hs()
 init_anims()
 init_defs()
-- init_map()
 if(init_debug) init_debug()
 init_buttons()
 set_pal()
 sfx(8, 3)

 g_fakebal = spawn_actor(g_actordefs[spr_player],64,61,true)
end


-------------------------------
function load_hs()
 cartdata("myrrhs_edge")
 g_hs_time = dget(0)
 if(g_hs_time==0) g_hs_time = 9999.9
 g_hs_myrrh = dget(1)
end


-------------------------------
function save_hs()
 dset(0, g_hs_time)
 dset(1, g_hs_myrrh)
end


-------------------------------
function _update60()
  start_frame()

 if g_state=="title" then
  update_title()
 elseif g_state=="story" then
  update_story()
 elseif g_state=="game" then
  tick_actors()
  if gd_noclip then
   noclip_actor(g_player)
  else
   move_actor(g_player)
   world_push_actor(g_player)
  end
  update_state(g_player)
  anim_player(g_player)
  anim_buckets()
 elseif g_state=="endgame" then
  g_endfr += 1
  update_end()
  anim_player(g_player)
  anim_buckets()
 end

end


-------------------------------
function update_title()
 if btnp(Ž) then
  g_state="story"
  g_frame = 0
 end
end


-------------------------------
function update_story()
 if btnp(Ž) then
  g_state="game"
  sfx(8, -2)
  music(0, 100)
  init_map()
 end
end


-------------------------------
function _draw()
 cls(0)
 if g_state=="title" then
  draw_title()
 elseif g_state=="story" then
  draw_story()  
 elseif g_state=="game" then
  cam_world()
  draw_world()
  camera()
  draw_ui()
  if(gd_stats) draw_stats()
 elseif g_state=="endgame" then
  cam_end()
  draw_world()
  draw_endworld()
  camera()
  draw_endui()
  if(gd_stats) draw_stats()
 end
end


-------------------------------
function draw_title()

 -- title blocks
 local t = .5 * time()
 for i=1,#g_spr_title do
  local s = sin( t + i/30 )
  local x = 10+i*8
  local y = 10 + 5*s*s*s*s*s*s*s*s
  spr(g_spr_title[i],x,y)
 end

 print("a",62,25,5)
 print("christmas speedrun parkour game",3,32,5)

 -- moving ground (repeating)
 xofs = g_frame % 232
 map(17,0, -xofs,40, 29,4)
 map(17,0, 232-xofs,40, 29,4)

 -- running bal
 local bal = g_fakebal
 bal.wy = 61
 bal.state = "walk"
 bal.direction = 1
 bal.vx = 20
 local len=40
 local jmp=128
 local t = mid( (xofs-jmp)/len, 0,1 )
 if t>0 and t<1 then
  bal.wy = 61 - 7 + 7 * cos( t )
  bal.state = "jump"
  if(t>.5) bal.state="fall"
 end
 anim_player( bal )
 draw_actor( bal )

 -- credits
 local r = g_rainbow1
 local f = flr(g_frame / 8)
 local c1=r[4+(f+3)%11]
 local c2=r[4+(f+2)%11]
 local c3=r[4+(f+1)%11]
 local c4=r[4+(f+0)%11]
 print( "design/sfx: that tom hall", 13,105-24, c1 )
 print( "code and such: squirrel eiserloh", 1,105-16, c2 )
 print( "art and anims: toby hefflin", 1,105-8, c3 )
 print( "music by: gruber", 21,105, c4 )

 print("press Ž to begin",21,120,5)
end


-------------------------------
function draw_story()
 sspr(112,48,16,16,48,5,32,32)
 print("balthazar",47,38,14)
 print("bal:",16,54,7)
 print_t("i woke up late!",34,54, 9, 0)
 print_t("gotta get to",41,62, 9, 35)
 print_t("the manger, fast!",36,70, 9, 45)
 print_t("(and pick up some",30,90, 4, 80)
 print_t("myrrh on the way!)",32,98, 4, 95)
 print("press Ž to continue",25,120,5)
end


-------------------------------
function draw_world()
  if(gd_track and gd_track>0) debug_draw_tracking()
  draw_map()
  draw_actors("bg")
  draw_actors("mid")
  draw_map(128) -- fg tiles
  draw_actors("fg")
  draw_signs()
  if(gd_stats) debug_draw_points()
end


-------------------------------
function update_end()
 local p = g_player

 if(g_endfr > 100 and btn(—) and btn(Ž)) run()

 local lerp = mid((g_endfr-20) / 50, 0, 1)
 p.wx = g_lastbalx + lerp * (924 - g_lastbalx)
 p.wy = 245
 if lerp == 1 then
  p.direction = 1
  p.spr_mirror = false
  p.state = "idle"
  p.vx = 2
 else
  p.direction = -1
  p.spr_mirror = true
  p.state = "walk"
  p.vx = -2
 end

end


-------------------------------
function cam_end()
 local t = smoothstep(mid(g_endfr / 30, 0, 1))
 g_camx = g_ocamx + t * (840 - g_ocamx)
 g_camy = g_ocamy + t * (122 - g_ocamy)
 camera(g_camx, g_camy)
end


-------------------------------
function draw_endworld()
 if(g_endfr>150) draw_snark(g_snark1,0,6,5)
 if(g_endfr>300) draw_snark(g_snark2,1,10,9)
end


-------------------------------
function fit(amin,amax,bmin,bmax)
 if amax > bmax then
  amin -= amax-bmax
  amax = bmax
 end
 if amin < bmin then
  amax += bmin-amin
  amin = bmin
 end
 return amin,amax
end


-------------------------------
function draw_snark( s,n,edge,fill )
 local p=g_snarkers[s[1]]
 local sxy=g_snark_xys[s[1]]
 local sx,sy=sxy[1]*8+4,sxy[2]*8-1
 local len = max(#s[2],#s[3])
 local minx = sx-2*len-1
 local maxx = sx+2*len+1
 local miny = 194+n*18
 local maxy = miny+15
 minx,maxx = fit(minx,maxx,841,966)
 line(sx-1,sy-1, sx-8,maxy,edge)
 line(sx,sy-1, sx-7,maxy,edge)
 rectfill(minx,miny,maxx,maxy,edge)
 rect(minx,miny,maxx,maxy,fill)
 print(s[2],minx+2,miny+2,0)
 print(s[3],minx+2,miny+8,0)
end


-------------------------------
function draw_endui()

 spr(40, 12,12)
 spr(40, 108,12)
 for i=1,#g_spr_best do spr(g_spr_best[i],20+i*8,12) end
 for i=1,#g_spr_title do spr(g_spr_title[i],10+i*8,0) end

 p1 = g_rainbow1[ 4 + flr(g_frame/5) % 11 ]
 local tcol,mcol = 6,10
 if g_hs_time == g_sc_time then
  print_o("new record!", 10,54, p1, 0 )
  tcol = p1
 end
 if g_player.myrrh >= 200 then
  print_o("perfect!", 81,54, p1, 0 )
  mcol = p1
 elseif g_hs_myrrh == g_player.myrrh then
  print_o("new record!", 75,54, p1, 0 )
  mcol = p1
 end

 print_o("best time       most myrrh", 12,22, 9, 0)
 print_o(g_hs_time.."", 20,28, tcol, 0)
 print_o(g_hs_myrrh.."", 90,28, mcol, 0)

 print_o("your time       your myrrh", 12,40, 3, 0)
 print_o(g_sc_time.."", 20,46, tcol, 0)
 print_o(g_player.myrrh.."", 90,46, mcol, 0)

 print_o("(—+Ž to try again!)", 2,62, 5, 0)
end

-------------------------------
function start_frame()

 g_dt = 1 / 60 -- deltaseconds
 g_time += g_dt
 g_frame = (g_frame + 1) % 28800 -- mods nicely by everything
 foreach(g_buttons, update_btn)
 if g_state == "game" then
  local ptx = flr(g_player.wx / 8)
  local pty = flr(g_player.wy / 8)
  if(mget(ptx,pty)==123 and g_player.myrrh >= g_min_myrrh) end_game()

 end
 if(g_sign) g_sign.fr += 1
 
end


-------------------------------
function init_buttons()
 g_button_keys = {‹,‘,”,ƒ,—,Ž}
 g_buttons = {}
 for k in all(g_button_keys) do
  g_buttons[k] = { key=k, isdown=false, was=false }
 end
end


-------------------------------
function update_btn(button)
 button.was = button.is
 button.is = btn(button.key)
end


-------------------------------
-- a more-useful version of btnp() which ignores repeats
function btnpp(key)
 local bs = g_buttons[ key ]
 return bs.is and not bs.was
end


-------------------------------
function set_pal()
 pal()
 pal(1,129,1)
 pal(10,135,1)
 pal(11,131,1)
 pal(12,128,1)
 pal(13,130,1)
 pal(14,133,1)
 pal(15,132,1)
 poke(0x5f2e,1) --keep pal after exit
end


-------------------------------
function init_map()

 for ty = 0,3 do
  for tx = 17,46 do
   mset(tx,ty,0)
  end
 end

 -- spawn actors
 for ty = 0,63 do
  for tx = 0,127 do

   local tile = mget(tx,ty)

   -- tile corrections (for multiple tiles representing the same thing)
   if(tile==107 or tile==108)  tile = spr_fire
   if(tile==28 or tile==29)    tile = spr_star
   if(tile==45)                tile = spr_myrrh
   if(tile==77)                tile = spr_mouse_idle
   if(tile==73 or tile==102)   tile = spr_sheep_idle
   if(tile==94)                tile = spr_melee_idle

   if tile==38 then
    get_sign(tx,ty)
   end

   local def = g_actordefs[ tile ]
   if def != nil then
    local wx = 4 + (8 * tx)
    local wy = 4 + (8 * ty)
    local a = spawn_actor(def, wx,wy)
    local default_spawntile = 8
    if( ty > 47 ) default_spawntile = 26
    local replacetile = def.spawntile or default_spawntile
    mset(tx,ty, replacetile)
    if def.category=="player" then
     g_player = a
    end
   end
   
  end
 end

 g_player.fr_since_air_jump = 0

end


-------------------------------
function end_game()
 g_state = "endgame"
 g_endfr = 0
 g_lastbalx = g_player.wx
 g_ocamx = g_camx
 g_ocamy = g_camy
 g_snark1 = 1+flr(rnd(#g_snarks))
 g_snark2 = g_snark1
 while g_snark2==g_snark1 do
  g_snark2 = 1+flr(rnd(#g_snarks))
 end
 g_snark1 = g_snarks[g_snark1]
 g_snark2 = g_snarks[g_snark2]

 -- scoring
 g_sc_time = flr(g_time*10)/10
 g_new_hs_time = false
 g_new_hs_myrrh = false
 if g_sc_time < g_hs_time then
  g_hs_time = g_sc_time
  g_new_hs_time = true
 end
 if g_player.myrrh > g_hs_myrrh then
  g_hs_myrrh = g_player.myrrh
  g_new_hs_myrrh = true
 end
 save_hs()

end


-------------------------------
function cam_world()
 local goalx = flr(g_player.wx) - 64
 local goaly = flr(g_player.wy) - 64

 if g_camx==nil then
   g_camx = goalx
   g_camy = goaly
 end

 local d = 9
 if(g_camx < goalx-d) g_camx = goalx-d
 if(g_camx > goalx+d) g_camx = goalx+d
 if(g_camy < goaly-d) g_camy = goaly-d
 if(g_camy > goaly+d) g_camy = goaly+d

 if(g_camx < 0) g_camx = 0
 if(g_camy < 0) g_camy = 0
 if(g_camx > 896) g_camx = 896
 if(g_camy > 384) g_camy = 384
  
 camera(g_camx, g_camy)
end


-------------------------------
function draw_map(layer_bits_value)
 map(0,0, 0,0, 128,64, layer_bits_value)
end


-------------------------------
function draw_signs()
 local s = g_sign
 if s.fr < 60 then
  w1 = #s.msg1
  w2 = #s.msg2
  x1 = s.wx - 2*w1
  x2 = s.wx - 2*w2
  w = max(w1, w2)
  minx = min(x1, x2) - 3
  maxx = minx + 4*w + 4
  y1 = s.wy - 40
  y2 = y1 + 6
  miny = y1 - 2
  maxy = y2 + 6
  if minx < 0 then
   local over = -minx
   minx = 0
   maxx += over
   x1 += over
   x2 += over
  end
  if maxx > 1023 then
   local over = maxx - 1023
   minx -= over
   maxx -= over
   x1 -= over
   x2 -= over
  end
  rectfill(minx,miny, maxx,maxy, 9)
  print(s.msg1, x1,y1, 0)
  print(s.msg2, x2,y2, 0)
  line(minx+1,miny, maxx-1,miny, 10)
  line(minx,miny+1, minx,maxy-1, 10)
  line(minx+1,maxy, maxx-1,maxy, 4)
  line(maxx,miny+1, maxx,maxy-1, 4)
  pset(minx,miny, 7)
  pset(maxx,maxy, 15)

 end
end


-------------------------------
function draw_actors(layer)
 local actors_in_layer = g_layers[ layer ]
 for a in all(actors_in_layer) do
  draw_actor(a)
 end
end


-------------------------------
function init_anims()
 for i=1,g_nbuckets do
  add(g_buckets, {})
 end
end


-------------------------------
function init_defs()

 local def = new_actordef("player", spr_player)
 def.category = "player"
 def.tick = tick_player
 def.anim = anim_player
 def.jump_vel = 68
 def.jump_sustain = 3.0
 def.can_climb = true
 def.can_zip = true
 def.climb_down_speed = 30
 def.climb_up_speed = 30
 def.radius = g_pr
 def.health = 3
 def.draw_ofs_x = 0 -- -1
 def.draw_ofs_y = -1
 def.does_physics = true

 local def = new_actordef("melee", spr_melee_idle)
 def.category = "npc"
 def.tick = tick_melee

 local def = new_actordef("sheep", spr_sheep_idle)
 def.category = "npc"
 def.tick = tick_sheep
 def.anim = anim_sheep
 def.sfx_die = sfx_sheep_died

 local def = new_actordef("mouse", spr_mouse_idle)
 def.category = "npc"
 def.tick = tick_mouse
 def.anim = anim_mouse
 def.sfx_die = sfx_mouse_died

 local def = new_actordef("myrrh", spr_myrrh)
 def.category = "pickup"
 def.tick = tick_pickup
 def.anim = anim_myrrh
 def.radius = 5
 def.myrrh = 1
 def.sfx_die = sfx_getmyrrh

 local def = new_actordef("key", spr_key)
 def.category = "pickup"
 def.tick = tick_pickup
 def.radius = 5
 def.keys = 1
 def.sfx_die = sfx_getkey

 local def = new_actordef("fire", spr_fire)
 def.anim = anim_fire
 def.draw_layer = "bg"

 local def = new_actordef("star", spr_star)
 def.anim = anim_star
 def.spawntile = 0
 def.draw_layer = "bg"

 local def = new_actordef("pillarbottom", 48)
 def.spawntile = 48
 def.draw_layer = "fg"
 def.draw_spr = 49

 local def = new_actordef("pillarmid", 71)
 def.spawntile = 71
 def.draw_layer = "fg"
 def.draw_spr = 72

 local def = new_actordef("pillartop", 32)
 def.spawntile = 32
 def.draw_layer = "fg"
 def.draw_spr = 33

end


-------------------------------
function spawn_actor(def, wx,wy, is_fake)
 local a = {}
 a.def = def
 def.count += 1
 def.spawncount += 1
 a.sprite = def.draw_spr
 a.spr_frames = 0
 a.spr_mirror = false
 a.wx = wx
 a.wy = wy
 a.vx = 0
 a.vx_max = a.def.vx_max
 a.vy = 0
 a.direction = 1
 a.radius = def.radius
 a.state = "idle"
 a.on_ground = false
 a.on_rwall = false
 a.on_lwall = false
 a.on_ladder = false
 a.head_on_ladder = false
 a.on_zip = false
 a.on_wire = false
 a.on_awn = false
 a.awn_dir = 0
 a.on_slide = false
 a.keys = def.keys
 a.myrrh = def.myrrh
 a.is_atk = false
 a.cool = 0

 if not is_fake then
  add(g_actors, a)
  local draw_layer_list = g_layers[ def.draw_layer ]
  add(draw_layer_list, a)
  local dc = def.category
  if dc=="pickup" or dc=="decoration" or dc=="npc" then
   next_bucket = next_bucket or 0
   next_bucket = 1 + (next_bucket % g_nbuckets)
   local bucket = g_buckets[ next_bucket ]
   add(bucket, a)
  end
 end

 return a
end


-------------------------------
function new_actordef(name, spawn_spr)
 local def = {}
 def.count = 0 -- current count
 def.spawncount = 0 -- spawned count
 def.spawn_spr = spawn_spr
 def.draw_spr = spawn_spr
-- def.spawntile = -1 -- open bricks
 def.name = name
 def.health = 1
 def.radius = 4
 def.accelx = 1000
 def.vx_max = g_player_max_runx
 def.does_physics = false
 def.gravity = 300
 def.jump_vel = 0
 def.jump_sustain = 0
 def.category = "decoration"
 def.tick = nil
 def.can_climb = false
 def.can_zip = false
 def.climb_down_speed = 0
 def.climb_up_speed = 0
 def.draw_layer = "mid"
 def.draw_ofs_x = 0
 def.draw_ofs_y = 0
 def.keys = 0
 def.myrrh = 0

 if spawn_spr > 0 then
  -- file in map under spawn sprite #
  g_actordefs[ spawn_spr ] = def
 else
  -- file in map under def name
  g_actordefs[ name ] = def
 end

 return def
end


-------------------------------
function delete_actor(a)
 a.def.count -= 1
 del(g_actors, a)
 local draw_layer_list = g_layers[ a.def.draw_layer ];
 del(draw_layer_list, a)
 for i=1,g_nbuckets do
  del(g_buckets[ i ], a)
 end
end


-------------------------------
function tick_actors()
 for a in all(g_actors) do
  if(a and a.def.tick) a.def.tick(a)
 end
end


-------------------------------
function tick_melee(a)

 a.cool -= 1

 local dx = g_melee_walk_dx
 local p = g_player

 -- check if charging and hit player
 if a.is_atk then
  if a.cool < -70 then
    a.is_atk = false
    a.cool = 50
  elseif a.wy > p.wy - p.radius and a.wy < p.wy + p.radius then
   local dmgx = a.wx + (a.direction * 3)
   if dmgx > p.wx - p.radius and dmgx < p.wx + p.radius then
    p.vy = -82
    p.vx = (a.direction * 120)
    p.vx_max = abs(p.vx)
    p.state = "jump"
    sfx(sfx_hit)
    a.is_atk = false
    a.cool = 50
   end
  end
 end

 -- check to start charging
 if not a.is_atk and a.cool <= 0 then
  local miny = a.wy-g_melee_see_y
  local maxy = a.wy+g_melee_see_y
  if p.wy > miny and p.wy < maxy then
   local minx = a.wx - (a.direction * 5)
   local maxx = minx + (a.direction * g_melee_see_x)
   if minx > maxx then
    local tempswap = minx
    minx = maxx
    maxx = tempswap
   end
   if p.wx > minx and p.wx < maxx then
    if((p.wx - a.wx) * a.direction < 0) a.direction = -a.direction
    a.is_atk = true
    a.cool = 50
    sfx(sfx_charge)
   end
  end
 end

-- if(a.is_atk and a.cool < 1*60) a.is_atk = false
 if(a.is_atk) dx = g_melee_charge_dx

 -- check for turn-around
 local nx = a.wx + (dx * a.direction)
 local tx = flr(nx / 8)
 local ty = flr(a.wy / 8)
 local next_tile = mget(tx,ty)
 local next_tile_below = mget(tx,ty+1)
 local turn_around = false
 if(fget(next_tile, bit_solid_r) or fget(next_tile, bit_solid_l)) turn_around = true
 if(not fget(next_tile_below, bit_ladder) and not fget(next_tile_below, bit_solid_u)) turn_around = true
 if turn_around then
  a.direction = -a.direction
  a.is_atk = false
 else
  a.wx = nx
 end

 anim_melee(a)
end


-------------------------------
function anim_melee(a)
 a.sprite = spr_melee_idle
 a.spr_mirror = (a.direction < 0)

 if a.is_atk or a.cool > 40 then
  a.sprite = 94
  a.spr_mirror = (a.direction > 0)
 end
end


-------------------------------
function tick_sheep(a)
 local speedx_wander = 0.2
 local speedx = speedx_wander
 local direction = -1
 if a.spr_mirror then
  direction = 1
 end

 local nx = a.wx + (speedx * direction)
 local tx = flr(nx / 8)
 local ty = flr(a.wy / 8)
 local next_tile = mget(tx,ty)
 local next_tile_below = mget(tx,ty+1)
 local turn_around = false
 if(fget(next_tile, bit_ladder) or fget(next_tile, bit_solid_r) or fget(next_tile, bit_solid_l)) turn_around = true
 if(not fget(next_tile_below, bit_ladder) and not fget(next_tile_below, bit_solid_u)) turn_around = true
 if turn_around then
  a.spr_mirror = not a.spr_mirror
 else
  a.wx = nx
 end

-- anim_sheep(a)
end


-------------------------------
function anim_sheep(a)
 a.spr_frames = (a.spr_frames + 1) % 6
 a.sprite = spr_sheep_idle
 if(a.spr_frames < 3) a.sprite = spr_sheep_idle+1
end


-------------------------------
function tick_mouse(a)
 local speedx_wander = 0.5
 local speedx = speedx_wander
 local direction = -1
 if a.spr_mirror then
  direction = 1
 end

 local nx = a.wx + (speedx * direction)
 local tx = flr(nx / 8)
 local ty = flr(a.wy / 8)
 local next_tile = mget(tx,ty)
 local next_tile_below = mget(tx,ty+1)
 local turn_around = false
 if(fget(next_tile, bit_ladder) or fget(next_tile, bit_solid_r) or fget(next_tile, bit_solid_l)) turn_around = true
 if(next_tile==spr_slide1 or next_tile==spr_slide2) turn_around = false
 if(not fget(next_tile_below, bit_ladder) and not fget(next_tile_below, bit_solid_u)) turn_around = true
 if turn_around then
  a.spr_mirror = not a.spr_mirror
 else
  a.wx = nx
 end
end


-------------------------------
function anim_mouse(a)
 a.spr_frames = (a.spr_frames + 1) % 2
 a.sprite = spr_mouse_idle
 if(a.spr_frames < 1) a.sprite = spr_mouse_idle+1
end


-------------------------------
function tick_pickup(a)
 local p = g_player
 if do_actors_overlap(a,p) then
  p.keys += a.keys
  p.myrrh += a.myrrh
  sfx(a.def.sfx_die)
  delete_actor(a)
 end 
end


-------------------------------
function anim_fire(a)
 local fr_adv = 0 + flr(rnd(3))
 a.sprite = spr_fire + (fr_adv + a.sprite - spr_fire) % 3
end


-------------------------------
function anim_star(a)
 a.spr_frames = (a.spr_frames + 1) % 4
 a.sprite = spr_star + a.spr_frames
 if(a.spr_frames==3) a.sprite = 28
end


-------------------------------
function anim_myrrh(a)
 a.spr_frames -= 1  
 if a.spr_frames <= 0 then
  a.sprite = 44 + (1 + a.sprite - 44) % 2
  a.spr_frames = 1 + rnd(5)
 end
end


-------------------------------
function tick_player(p)

 p.vx_max -= 1
 if(p.vx_max < g_player_max_runx) p.vx_max = g_player_max_runx

 p.fr_since_air_jump += 1

 local tx = flr(p.wx / 8)
 local ty = flr(p.wy / 8)
 local tile_here = mget(tx,ty)

 local gs = g_sign
-- gs.fr += 1
 if tile_here==38 then
  local sign = get_sign(tx,ty)
  gs.msg1 = sign[3]
  gs.msg2 = sign[4]
  gs.wx = 8 * tx + 4
  gs.wy = 8 * ty
  gs.fr = 0
 end

 if p.state=="slide" and is_slide(tile_here) then
  return
 end

 local movex = 0
 if(btn(‘)) movex += 1
 if(btn(‹)) movex -= 1

 -- awning
 if p.on_awn and not p.on_ground and p.vy > 0 then
  p.vx = p.awn_dir * g_awn_vx
  p.vy = -g_awn_vy
  p.state = "jump"
  sfx(sfx_jump)
 end

 -- spikes
 if tile_here==118 and p.vy >= 0 then
  p.vx = -p.vx
  p.vx_max = abs(p.vx)
  p.vy = -65
  p.state = "fall"
  sfx(45)
 end

 -- use
 if btnpp(—) then
  if(tile_here==spr_door_locked) try_unlock(tx,ty)
  if(tile_here==spr_door_open) try_portal(tx,ty)
 end

 -- end zip/wire
 if(p.state=="zipline" and ((btn(ƒ) and btn(Ž)) or (not p.on_zip or not btn(—)))) p.state = "fall"
 if(p.state=="brachiate" and ((btn(ƒ) and btn(Ž)) or (not p.on_wire or not btn(—)))) p.state = "fall"

 -- start zip/wire
 if btn(—) and not btn(Ž) and not btn(ƒ) then
  if p.state ~= "zipline" and p.on_zip then
   p.state = "zipline"
   p.on_ground = false
   p.vx = g_zip_vx
   p.vy = g_zip_vy
   snap_to_zip(p)
   sfx(sfx_zip)
  elseif p.state ~= "brachiate" and p.on_wire then
   p.state = "brachiate"
   p.on_ground = false
   p.vy = 0
   snap_to_wire(p)
   sfx(sfx_wire)
  end
 end

 -- start climb
 local is_ud = btn(”) or btn(ƒ)
 if p.on_ladder and btn(ƒ) then
  p.state = "climb"
 elseif p.head_on_ladder and btn(”) and p.state ~= "slide" then
  p.state = "climb"
 end

 -- end climb
 if p.state=="climb" then
  if((p.on_ground and not is_ud) or (not p.on_ladder) or (not is_ud and (btn(‹) or btn(‘)))) p.state = "fall"
 end

 -- climbing
 if p.state=="climb" then
  p.vy = 0
  if is_ud then
   p.wx = p.ladderx
   p.vx = 0
  end
 end

 -- check for jump from slide
 if p.state=="slide" and movex ~= 0 and btnpp(Ž) then
   if(p.vy > 0) p.vy = 0
   p.vy -= p.def.jump_vel
   p.state = "jump"
   p.on_ground = false
   sfx(sfx_jump)
 end

 -- check for jump
 if btnpp(Ž) and not btn(ƒ) then -- can't jump if pushing down since that's for semi-solid fall-through...
  if p.state=="zipline" then
   -- jump off zipline
   p.vx = g_zip_jump_vx
   p.vy = -g_zip_jump_vy
   p.state = "jump"
   p.on_ground = false
   sfx(sfx_jump)
  elseif p.state=="brachiate" then
   -- jump off brachiate wire
   p.vy = -g_zip_jump_vy
   p.state = "jump"
   p.on_ground = false
   sfx(sfx_jump)
  else
   -- normal ground (or stairs) jump attempt
   local jump_ok = p.on_ground
   if not jump_ok and p.vy > 0 then
    -- falling toward stairs close under?
    local r = p.radius
    local ltx = flr((p.wx - r) / 8)
    local rtx = flr((p.wx + r) / 8)
    local fty = flr((p.wy + r + 3) / 8)
    local lftile = mget(ltx,fty)
    local rftile = mget(rtx,fty)
    if(lftile==20 or lftile==31 or rftile==20 or rftile==31) jump_ok = true
   end
   if jump_ok then
    if(p.vy > 0) p.vy = 0
    p.vy -= p.def.jump_vel
    p.state = "jump"
    p.on_ground = false
    sfx(sfx_jump)
   end
  end
 elseif btn(Ž) and p.state=="jump" then
  p.vy -= p.def.jump_sustain -- sustain higher jump as we hold the button
 end

 -- reset frames-since-air-jump counter
 if btnpp(Ž) and p.on_ground==false then
  p.fr_since_air_jump = 0
 end

 -- check for wall jump
 if p.on_ground==false and p.vy > 0 and movex ~= 0 and p.fr_since_air_jump < g_wall_jump_delay then
   local footy = p.wy - (p.radius / 2)
   local wall_ty = flr(footy / 8)
   local can_wall_jump = false
   if movex > 0 then
    -- check for wall-jump-off-left-to-right
    local footx = p.wx - p.radius - g_wjump_dist
    local wall_tx = flr(footx / 8)
    local wall_tile = mget(wall_tx, wall_ty)
    can_wall_jump = fget(wall_tile, bit_solid_r)
   elseif movex < 0 then
    -- check for wall-jump-off-right-to-left
    local footx = p.wx + p.radius + g_wjump_dist
    local wall_tx = flr(footx / 8)
    local wall_tile = mget(wall_tx, wall_ty)
    can_wall_jump = fget(wall_tile, bit_solid_l)
   end
   if can_wall_jump then
    if(p.vy > 0) p.vy = 0
    p.vy -= g_wjump_vy
    p.vx = movex * g_wjump_vx
    p.state = "jump"
    p.on_ground = false
    sfx(sfx_jump)
   end   
 end

 -- check for slide begin
 if p.state=="walk" and btn(ƒ) and abs(p.vx) > g_slide_min_vx then
  p.state = "slide"
  p.vx /= abs(p.vx)
  p.vx *= g_slide_max_vx
 end

 -- check for slide end
 if p.state=="slide" then
  if not btn(ƒ) or btn(”) or abs(p.vx) < g_slide_min_vx then
   p.state = "idle"
  end
  if (p.vx > 0 and movex <= 0) or (p.vx < 0 and movex >= 0) then
   p.state = "walk"
  end
  if movex==0 and btn(ƒ) and btn(Ž) then
   p.state = "fall" -- drop through semi-solid from slide
  end
 end

 -- compute u/d move intentions - apply climb y-velocity directly (not acceleration-based)
 if p.state=="climb" then
  if btn(ƒ) then
   p.vy = p.def.climb_down_speed
  end
  if btn(”) then
   p.vy = -p.def.climb_up_speed
  end
 end

 -- apply friction if on ground
 if p.state=="slide" then
  local friction = 0.01
  if (p.vx > 0 and btn(‘)) or (p.vx < 0 and btn(‹)) then
   friction = 0
   p.vx /= abs(p.vx)
   p.vx *= g_slide_max_vx
  end
  if (p.vx > 0 and btn(‹)) or (p.vx < 0 and btn(‘)) then
   friction = 0.3
  end
  p.vx *= (1 - friction)
 else
  local friction = 1 - abs(movex)
  local f = friction * 0.05
  if(p.on_ground or p.state=="brachiate") f = friction * 0.3
  p.vx *= (1 - f)
 end

 -- apply horizontal movement acceleration
 if(not p.on_ground) movex *= g_air_control
 local vx_limit = p.vx_max -- max(p.def.vx_max, abs(p.vx)) 
 if(p.state=="zipline") vx_limit = g_zip_vx
 local accelx = movex * p.def.accelx
 if p.vx * movex < p.def.vx_max then
  p.vx += accelx * g_dt
 end

 -- apply speed limit (anti-tunneling, corrective physics)
 if abs(p.vx) > vx_limit then
  local old = p.vx
  p.vx /= abs(p.vx)
  p.vx *= vx_limit
 end

 if(p.vy < -100) p.vy = -100
 
end


-------------------------------
function set_mirror(a)
 if(a.vx >  2) a.spr_mirror = false
 if(a.vx < -2) a.spr_mirror = true
end


-------------------------------
function anim_player(a)

 local fr = g_frame
 local s = a.state
 if s=="idle" then
  a.sprite = 64
  a.spr_frames += 1
  if(a.spr_frames > 20 + rnd(1000)) a.spr_frames = 0
  if(a.spr_frames < 10) a.sprite = 65
  if(g_state ~= "endgame" and rnd() < 0.01) a.spr_mirror = not a.spr_mirror

 elseif s=="walk" then
  a.sprite = 80 + flr(fr / 8) % 4
  set_mirror(a)

 elseif s=="slide" then
  a.sprite = 86
  set_mirror(a)

 elseif s=="climb" then
  if abs(a.vy) > 1 then
   local fr = flr(fr / 4) % 4
   a.sprite = 96 + (fr % 2)
   a.spr_mirror = fr < 2
  end

 elseif s=="jump" then
  a.sprite = 67
 
 elseif s=="fall" then
  a.sprite = 66
  if a.vy > 125 then
   a.sprite = 99 + flr(fr / 3) % 2
  end

 elseif s=="lwally" then
  a.sprite = 98
  a.spr_mirror = false
 
 elseif s=="rwally" then
  a.sprite = 98
  a.spr_mirror = true

 elseif s=="zipline" then
  a.sprite = 103
  if(fr%6 < 3) a.sprite = 104

 elseif s=="brachiate" then
  if( abs(a.vx) > 10 ) a.spr_frames += 1
  a.sprite = 112 + flr( a.spr_frames / 5 ) % 4
  set_mirror(a)
 
 end
end


-------------------------------
function snap_to_zip(a)
 -- asdf
end


-------------------------------
function snap_to_wire(a)
 local ty = flr(a.wy / 8)
 a.wy = (ty*8) + 4
end


-------------------------------
function is_slide(tile)
 return tile==spr_slide1 or tile==spr_slide2
end


-------------------------------
function try_unlock(tx,ty)

 local tile = mget(tx,ty)

 if tile==spr_door_locked and g_player.keys > 0 then
  g_player.keys -= 1
  mset(tx,ty, spr_door_open)
  ox,oy = find_door_twin(tx,ty)
  if(ox ~= nil) mset(ox,oy, spr_door_open) -- unlock twin
  sfx(sfx_open_y)
 else
  sfx(sfx_open_n)
 end
end


-------------------------------
function try_portal(tx,ty)

 local tile = mget(tx,ty)

 if tile==spr_door_open then
  ox,oy = find_door_twin(tx,ty)
  if ox==nil then
   err("door at "..tx..","..ty.." had no glyph-twin!")
  end

  g_player.wx += ((ox - tx) * 8)
  g_player.wy += ((oy - ty) * 8)
  sfx(sfx_door)
 end

end


-------------------------------
function find_door_twin(tx,ty)

 local this_glyph = mget(tx,ty-1) -- glyph above door
 for oy = 0,63 do
  for ox = 0,127 do

   if (ox ~= tx) or (oy ~= ty) then
    local twin_door = mget(ox,oy)
    if (twin_door==spr_door_open) or (twin_door==spr_door_locked) then
     local twin_glyph = mget(ox,oy-1) -- above twin door
     if twin_glyph==this_glyph then
      return ox,oy
     end
    end
   end

  end
 end

 return nil
end


-------------------------------
function anim_buckets()
 local bucket = 1 + (g_frame % g_nbuckets)
 local anim_list = g_buckets[ bucket ]
 for a in all(anim_list) do
  if(a.def.anim) a.def.anim(a)
 end
end


-------------------------------
function draw_actor(a, layer)
 local minx = a.wx - 4
 local miny = a.wy - 4
 local dx = minx + a.def.draw_ofs_x
 local dy = miny + a.def.draw_ofs_y
 spr(a.sprite, dx,dy, 1,1, a.spr_mirror)
end


-------------------------------
function do_actors_overlap(a, b)
 local ar = a.radius
 local br = b.radius
 return (a.wx - ar < b.wx + br) and
        (a.wx + ar > b.wx - br) and
        (a.wy - ar < b.wy + br) and
        (a.wy + ar > b.wy - br)
end


-------------------------------
function update_states()
 for i = 1,#g_actors do
  local a = g_actors[ i ]
  update_state(a)
 end
end


-------------------------------
function update_state(a)
 local s = a.state

 if (s=="jump" and a.vy >= 0) a.state = "fall"
 
 if not a.on_ground and
  (s=="idle" or
   s=="walk" or
   s=="duck" or
   s=="slide" or
   s=="use") then
  a.state = "fall"
 end
 
 if (s=="fall" and a.on_lwall) a.state = "lwally"
 if (s=="fall" and a.on_rwall) a.state = "rwally"
 if ((s=="lwally" and not a.on_lwall) or (s=="rwally" and not a.on_rwall)) a.state = "fall"
    
 if a.on_ground and
  (s=="jump" or
   s=="fall" or
   s=="lwally" or
   s=="rwally" or
   s=="brachiate" or
   s=="zipline") then
  a.state = "walk" 
 end
 
 if (s=="walk" and abs(a.vx) < g_walk_vx) a.state = "idle"
 if (s=="idle" and abs(a.vx) > g_walk_vx) a.state = "walk"

end


-------------------------------
function menu_reset()
 g_hs_time = 9999.9
 g_hs_myrrh = 0
 save_hs()
end 

-------------------------------
function noclip_actor(a)
 if(btn(‘)) a.wx += 2
 if(btn(‹)) a.wx -= 2
 if(btn(ƒ)) a.wy += 2
 if(btn(”)) a.wy -= 2
end


-------------------------------
function move_actor(a)

 if(not a or not a.def.does_physics) return

 if a.state ~= "climb" then
  a.vy += (a.def.gravity * g_dt)
  if a.state=="lwally" or a.state=="rwally" then
   if(a.vy > g_max_wally_vy) a.vy = g_max_wally_vy
  end
 end

 -- anti-tunneling vel clamp
 a.vx = mid(a.vx, -g_max_speed, g_max_speed)
 a.vy = mid(a.vy, -g_max_speed, g_max_speed)

 if a.state=="zipline" then
  a.vx = g_zip_vx
  a.vy = g_zip_vy
 end

 if a.state=="brachiate" then
  a.vy = 0
 end

 a.wx += (a.vx * g_dt)
 a.wy += (a.vy * g_dt)

end


-------------------------------
function is_semi_solid(s)
 return fget(s, bit_solid_u) and not fget(s, bit_solid_l) and not fget(s, bit_solid_r) and not fget(s, bit_solid_d)
end


-------------------------------
function world_push_actor(a)
  local tx = flr(a.wx / 8)
  local ty = flr(a.wy / 8)
  
  a.on_ground = false
  a.on_rwall = false
  a.on_lwall = false

  push_up_out_of_stairs(a, tx,ty)

  pushtile_s(a, tx,ty+1) -- south tile (push up)
  pushtile_n(a, tx,ty-1)
  pushtile_e(a, tx+1,ty)
  pushtile_w(a, tx-1,ty)
  
  pushtile_ne(a, tx+1,ty-1)
  pushtile_nw(a, tx-1,ty-1)
  pushtile_se(a, tx+1,ty+1)
  pushtile_sw(a, tx-1,ty+1)

  update_ons(a)
end


-------------------------------
function pushtile_s(a, tx,ty)

 local s = a.state
 local tile = mget(tx,ty)
 if(s=="slide" and is_slide(tile)) return
 push_up_out_of_stairs(a, tx,ty)
 if(a.vy < 0) return

 local is_ladder = fget(tile, bit_ladder)
 local is_solid_ladder = is_ladder and s ~= "climb" and not a.head_on_ladder
 if(not fget(tile, bit_solid_u) and not is_solid_ladder) return

 -- fall-through semi-solid if down + jump
 if(btn(ƒ) and btn(Ž) and is_semi_solid(tile)) return

 -- overlapping?
 local tminy = ty * 8
 if(a.wy + a.radius <= tminy) return
 
 -- push out & kill v
 a.wy = tminy - a.radius
 if(a.vy > 0) a.vy = 0
 
 a.on_ground = true
 a.on_lwall = false
 a.on_rwall = false
 if(s=="fall") a.state = "walk"
 
end


-------------------------------
function pushtile_e(a, tx,ty)

 local tile = mget(tx,ty)
 if (a.state=="slide" and is_slide(tile)) return
 push_up_out_of_stairs(a, tx,ty)
 if (not fget(tile,bit_solid_l)) return

 -- overlapping?
 local rx = a.wx + a.radius
 local tminx = tx * 8
 if(rx <= tminx) return
 
 -- push & kill v
 a.wx = tminx - a.radius
 if(a.vx > 0) a.vx = 0
 if(not a.on_ground) a.on_rwall = true -- pushed left!
 
end


-------------------------------
function pushtile_w(a, tx,ty)

 local tile = mget(tx,ty)
 if(a.state=="slide" and is_slide(tile)) return
 push_up_out_of_stairs(a, tx,ty)
 if(not fget(tile,bit_solid_r)) return

 -- overlapping?
 local tmaxx = tx*8 + 8
 if(a.wx - a.radius >= tmaxx) return
 
 -- push & kill v
 a.wx = tmaxx + a.radius
 if(a.vx < 0) a.vx = 0
 if(not a.on_ground) a.on_lwall = true -- pushed right!
 
end


-------------------------------
function pushtile_n(a, tx,ty)

 local s = a.state
 local tile = mget(tx,ty)
 if(s=="slide" and is_slide(tile)) return
 if(not fget(tile,bit_solid_d)) return

 local tmaxy = ty*8 + 8
 if(a.wy - a.radius >= tmaxy) return
 
 -- push & kill v
 a.wy = tmaxy + a.radius
 if(a.vy < 0) a.vy= 0
 if(s=="lwally" or s=="rwally" or s=="jump") a.state = "fall"
 
end


-------------------------------
function pushtile_nw(a, tx,ty)
 local tile = mget(tx,ty)
 if(a.state=="slide" and is_slide(tile)) return
 if(not fget(tile,bit_solid_d) and not fget(tile,bit_solid_r)) return
 push_out_of(a, tx*8 + 8,ty*8 + 8, false, true)
end


-------------------------------
function pushtile_ne(a, tx,ty)
 local tile = mget(tx,ty)
 if(a.state=="slide" and is_slide(tile)) return
 if(not fget(tile,bit_solid_d) and not fget(tile,bit_solid_l)) return
 push_out_of(a, tx*8,ty*8+8, false, true) 
end


-------------------------------
function pushtile_se(a, tx,ty)

 local tile = mget(tx,ty)
 if(a.state=="slide" and is_slide(tile)) return
 push_up_out_of_stairs(a, tx,ty)
 if(a.vy < 0) return

 local is_climbing = (a.state=="climb")
 local is_ladder = fget(tile, bit_ladder)
 local is_solid_ladder = is_ladder and not is_climbing and not a.head_on_ladder
 if(not fget(tile, bit_solid_u) and not is_solid_ladder) return

 -- fall-through semi-solid (solid on top only) if holding down + jump
 if(btn(ƒ) and btn(Ž) and is_semi_solid(tile)) return

 push_out_of(a, tx*8,ty*8)

end


-------------------------------
function pushtile_sw(a, tx,ty)

 local tile = mget(tx,ty)
 if(a.state=="slide" and is_slide(tile)) return
 push_up_out_of_stairs(a, tx,ty)
 if(a.vy < 0) return

 local is_climbing = (a.state=="climb")
 local is_ladder = fget(tile, bit_ladder)
 local is_solid_ladder = is_ladder and not is_climbing and not a.head_on_ladder
 if(not fget(tile, bit_solid_u) and not is_solid_ladder) return

 -- fall-through semi-solid (solid on top only) if holding down + jump
 if(btn(ƒ) and btn(Ž) and is_semi_solid(tile)) return

 push_out_of(a, tx*8 + 8,ty*8)

end


-------------------------------
function push_up_out_of_stairs(a, tx,ty)

 local tile = mget(tx,ty)
 if(tile ~= spr_stairs_up and tile ~= spr_stairs_down) return

 local r = a.radius
 local a_minx = a.wx - r
 local a_maxx = a.wx + r
 local a_miny = a.wy - r
 local a_maxy = a.wy + r

 local t_minx = 8 * tx
 local t_maxx = t_minx + 8 -- or is 7, or 7.99 more appropriate?
 local t_miny = 8 * ty
 local t_maxy = t_miny + 8 -- ditto

 if(a_minx > t_maxx or a_maxx < t_minx or a_miny > t_maxy or a_maxy < t_miny) return

 local tile = mget(tx,ty)
 if tile==spr_stairs_up then
  local px = min(a_maxx, t_maxx)
  local dx = px - t_minx
  local dy = dx
  local py = t_maxy - dy
  if a_maxy > py then
   push_out_of(a, px-.01,py, true)
  end
 elseif tile==spr_stairs_down then
  local px = max(a_minx, t_minx)
  local dx = px - t_minx
  local dy = 8-dx
  local py = t_maxy - dy
  if a_maxy > py then
   push_out_of(a, px+.01,py, true)
  end
 end

end


-------------------------------
function push_out_of(a, px,py, up_only, prefer_x)

 local r = a.radius
 if(px<=a.wx-r or px>=a.wx+r or py<=a.wy-r or py>=a.wy+r) return false
 
 -- push and kill v
  local dx = a.wx - px
  local dy = a.wy - py
  if not up_only and (prefer_x==true or abs(dx) > abs(dy)) then
    -- push out horiz. (x)
    if dx > 0 then
      a.wx += (r-dx)
      if(a.vx < 0) a.vx = 0
     a.on_ground = false
     a.on_lwall = true 
     a.on_rwall = false
    else
      a.wx -= (r+dx)
      if(a.vx > 0) a.vx = 0
     a.on_ground = false
     a.on_lwall = false
     a.on_rwall = true
    end
  else
    -- push out vertically (y)
    local push_down = (up_only ~= true)

    if push_down and dy > 0 then
      a.wy += (r-dy)
      if(a.vy < 0) a.vy = 0
    else
      a.wy -= (r+dy)
      if(a.vy > 0) a.vy = 0
     a.on_ground = true -- pushed up! 
     a.on_lwall = false
     a.on_rwall = false
     if(a.state=="fall") a.state = "walk"
    end
  end

 return true -- was pushed!
end


-------------------------------
function update_ons(a)
 a.on_ladder = false
 a.head_on_ladder = false
 a.on_zip = false
 a.on_wire = false
 a.on_ow = false
 a.on_awn = false
 a.awn_dir = 0
 a.on_slide = false

 local r = a.radius
 local min_wx = a.wx - r
 local max_wx = a.wx + r
 local min_wy = a.wy - r
 local mid_wy = a.wy
 local max_wy = a.wy + r

 local min_tx = flr(min_wx / 8)
 local max_tx = flr(max_wx / 8)
 local min_ty = flr(min_wy / 8)
 local mid_ty = flr(mid_wy / 8)
 local max_ty = flr(max_wy / 8)

 local dist_x_to_closest_ladder = g_grab_ladder_dist_x
 for ty = min_ty,max_ty do
  for tx = min_tx,max_tx do
   local tile = mget(tx,ty)

   -- on ladder?
   if fget(tile, bit_ladder) then
    local tile_center_wx = (tx * 8) + 4
    local dist_x_to_ladder = abs(tile_center_wx - a.wx)
    if ty <= mid_ty then
     a.head_on_ladder = true
    end
    if dist_x_to_ladder < dist_x_to_closest_ladder then
     a.on_ladder = true -- at least one tile i overlap is climbable
     dist_x_to_closest_ladder = dist_x_to_ladder -- this is closest ladder
     a.ladderx = tile_center_wx - 0.01 -- snap x to here if climbing
    end -- if closest ladder
   end -- if ladder

   -- zip, wire, slide, spikes?
   if (tile==spr_zip_top or tile==spr_zip_bottom) a.on_zip = true
   if ((tile==spr_wire or tile==spr_wire_end) and a.wy >= ty*8+2 and a.wy <= ty*8+6) a.on_wire = true
   if (is_slide(tile)) a.on_slide = true 

   -- on awning?
   if a.wy>=ty*8+2 and a.wy<=ty*8+6 then
    if tile==36 or tile==35 then
     a.on_awn = true
     a.awn_dir += 1
    elseif tile==15 or tile==14 then
     a.on_awn = true
     a.awn_dir -= 1
    end
   end
 
   if(abs(a.awn_dir) > 1) a.awn_dir /= abs(a.awn_dir)

  end
 end
end


-------------------------------
function cam_ui()
 camera(0,0)
end


-------------------------------
function draw_ui()

 local k = g_player.keys
 spr_o(spr_key, 0,0, 0)
 print_o(k.."", 8,1, 10, 0)

 local m = g_player.myrrh
 local mc,oc = 10,0
 if m >= g_min_myrrh and g_state=="game" then
  print_o("get to the manger!", 21,1, 3, 0)
  mc = 3
  oc = 3
 end
 spr_o(spr_myrrh, 94,0, oc)
 print_o(m.."/"..g_min_myrrh, 104,1, mc, 0)

 if g_state=="game" then
  local tm = flr(g_time/60)
  local sec = g_time - (tm*60)
  local tsec = flr(sec/10)
  sec -= (tsec*10)
  secf = flr(10*(sec-flr(sec)))
  sec = flr(sec)
  if tm > 9 then
   print_o(tm..":"..tsec..sec, 104,8, 6, 0)
  else
   print_o(tm..":"..tsec..sec.."."..secf, 104,8, 6, 0)
  end
 end
 
 if(gd_msg and #gd_msg>0) print_o(gd_msg, 0,0, 8, 0)
 
end


-------------------------------
function get_sign(tx,ty)
 for sign in all(g_signs) do
  if(sign[1]==tx and sign[2]==ty) return sign
 end
 err("sign at "..tx..","..ty.." was unlisted!")
end


-------------------------------
function spr_o(s, x,y, outline_color)
 pal()
 for c=1,15 do
  pal(c, outline_color)
 end
 spr(s,x+1,y+1)
 spr(s,x+0,y+1)
 spr(s,x-1,y+1)
 spr(s,x+1,y+0)
 spr(s,x-1,y+0)
 spr(s,x+1,y-1)
 spr(s,x+0,y-1)
 spr(s,x-1,y-1)
 set_pal()
 spr(s, x,y)
end


-------------------------------
-- print string s at x,y with
-- color c and outline optional
function print_o(s,x,y,c,o)
 if o ~= nil then
  print(s,x+1,y+1,o)
  print(s,x+0,y+1,o)
  print(s,x-1,y+1,o)
  print(s,x+1,y+0,o)
  print(s,x-1,y+0,o)
  print(s,x+1,y-1,o)
  print(s,x+0,y-1,o)
  print(s,x-1,y-1,o)
 end
 print(s,x,y,c)
end


-------------------------------
function print_t( s,x,y,c,t )
 local l = mid(flr(g_frame/2) - t,0,#s)
 print( sub(s,1,l),x,y,c )
end


-------------------------------
function smoothstep(t)
 return t * t * (3 - 2*t)
end

--#include dev.p8
__gfx__
7600007600cccc0000cccc000cccc00c000cc0000cccccc00000000000cc000000ccccc03d0cc03dbbbbbbbbbb00000000000000bb000000000000033333333b
6760076500c00c0000c00c0000ccc0c000cffc00cc0000cc0ccc0000000000cc00ccccc04f33334fcc000ccc00bbccc0cccc000000bbbbb0000000333333333b
0676765000c00c0000c00c0000cc0c000cf99fc0c000000c0ccc00000000000000000000bc0000bccc000ccc0000bb00cccc00000bbbb1b000000333333333b0
0067650000c00c0000c00c0000c00c000cfaafc0c000000c00000000ccc00000ccccc0003d00003d000000000cccccbb0000cccc01bbbb100000333333333b00
0076760000c00c0000c00c0000c00c000cf99fc0c000000c0000000000000000ccccc0cc3dc0003d000ccc00c00ccc00bb00cccc0111110b00333333333bb000
0765676000cc0c0000c00c0000c00c000cffffc0c000000c00000000000cccc0ccccc0004333334fc00ccc0cccc00c0000bb00000000000bbbbbbbbbbbb00000
7650067600ccc0c000c00c0000c00c000cccccc0c000000c00000cc0000cccc00000ccccbc0000bcc00ccc0cccccc0000000bbc000c000000b000000000b0000
650000650cccc00c00c00c0000cccc0000000000cccccccc00000000000000000000cccc3d00003d0000000000000000000000bb00c00c0000b000000000b000
c0ccc00c5555555f55d555f56666666666000000dddfffff9a7a99a977a77aaa9444444fefffcffeb000000e0009000000040000000f0000fffffddd00000066
0c000000ddffffff5ddd5ffffdddfdddff0cccc0ddfdddff5ffffff575c5c5c74f7a9cfdfdffffff0be0b0000009000000090000000f0000ffdddfdd0cccc0ff
c0cccc0055dfffff5ddd5fff54445444ff66ccc000dddfdd5dddddd5aa77a9aa47cff7cdfedfffdf00000b0b090a09000409040004040400ddfddd000ccc66ff
0c0000c0ff5fffff5dddffff54445444ffff000000ddfddd500000057505050a4a9a7acdffeffdcf000b000000a7a000009a9000009a9000dddfdd000000ffff
ccc0cc0c5ffffdddf555555f54445444ffff66cc0000dddf50000005750a940949cff9cdfdfffeff0e0ce0b09a777a9049a7a940f4aaa4f0fddd0000cc66ffff
0c000000fffffdd55fff5fff54445444ffffff00c000ddfd500cc005a509fd094a7c9acdffeffffd0000000e00a7a000009a9000009a9000dfdd000c00ffffff
00cccc0c5ffff55fffffffffd555d555ffffff6600c000dd50dddd05a505050afeeeeeecdfffeffe000be0c1090a09000409040004040400dd0000c066ffffff
c00000c05fffffff5fffffffddddddddffffffff000c00dd5eeeeee59a7a99a90c0c0c0cefffdcef0b0000b10009000000040000000f0000dd00c000ffffffff
cd6dd22c0d6dd22055555552b33333333000000056676650a9999994b000000ea7a999946765676567656765b0dede0e0047a400005445000a3a3a390007a900
00dd220000dd220012511522b333333333000000677077659cc4c4cf0b00b000049444f0fddffddf5dd55dd50be55dd00477aa400547a4500bbbbbbb000a0000
cccd2cc0000d2000551111520b33333333300000677077659444444f00eee00b097999400440044044f99f440e5555dd4777aaa45477aa4500ffdfd0000aa900
00062000000620002511115200b3333333330000700077769ccc4ccfce55ddc009a99940c00cc000df4444fdce55d5dd7777aaaa4777aaa4055ffffe000a0000
ccc620cc0006200055111151000bb33333333300677777659444444fe5555edc049a94f0ccccccccf4fccf4fe5ed55de4aaa999454aa99450511111e000a0000
0c062000000620002511115500000bbbbbbbbbbb677777654fffffffe5ed5edc00494f00ccccc000cfccc0f0e555555d04aa9940054a9450053bbbbe007aa900
ccc62cc000062000555555520000b000000000b0566766500005e000de55edcc000a40000000cccc0000ccccd55555de004a940000544500005eeee000a00a00
ccc62cc00006200052222222000b000000000b0005565500cc0640cccdeedccc07a994f0cc00cccccc00cccccdeedccc0004400000055000003bbbb0009aa900
c0c620cc000620009444444f9444444e9444444f9444444f9444444f9444444f9444444f9444444f9444444e9444444f9444444e9444444f9444444f9444444f
00062000000620004ffffffd4a7a9ace4a7acffe4a7a9acd4acffacd4acffacd4a7a9cfd4a7c9acd4ffa9cfe4f7a9acd4f7a9cfe4fff9acd4f7a9acd4acffacd
ccc62cc0000620004ffffffd47c9c7ce4facfffe4f7cf7cd47aca7cd4facacfd47cff7cd47cff7cd4fffaffe47cffffd4ff9cffe4ffff7cd47cffffd47cfacfd
00062000000620004ffffffd4ffacffe4f9cfffe4fa9acfd4acafacd4ffacffd4a9a7cfd4a9a7acd4ffacffe4f9a7cfd4ffacffe4ffffacd4acf7acd4a9acffd
0cc62ccc000620004ffffffd4ff7cffe4facf9ce4f9cfffd49cff9cd4ff7cffd49cff9cd49cff9cd4ffffffe4ffff9cd4ff7cffe49cff9cd49cff9cd49cf7cfd
00062000000620004ffffffd4f7a9cfe4a7a9ace4aa7cffd4a7c9acd4f7a9cfd4a7c9acd4a7c9acd4ffffffe4a7a9cfd4f7a9cfe4f7a9cfd4f7a9cfd4acffacd
ccd6220c00d62200feeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeecfeeeeeec
0d6dd2200d6dd2200c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c
077777760777777607700076005666e077777600000000e000000000c0c620cc0006200007777770949494949494949f00000000000000004ffffffccc000ccc
066666660666666606677766075dfde76666660076000e00000000000006200000062000766677769d444dffffd444df0000000000000000fccccccccc000ccc
00ffdfd000fffff000666660065fffe66fdfdeee76ffe00076000000ccc62cc00006200065a5a777d4f4f4dffd4fff4d00000000000000060f0000f000820000
055ffffe055ffffe55ffdfd0005eeee05555e00076dfe10076fe000000062cc000062000666667774fc4cf4ee4f4c4f400000065000000060fcffff00a43b940
0511111e0511111e505ffff0001111105e1110006fffe10076fe10000cc62ccc000620006c6667774444444ff4fc4cf400677506006775060f0000f099944fee
0582222e0582222e0011111000822220512222226d5512226ffe12000cc620000006200006cc77704fc4cf4ee4f4c4f487c7665687c766560f0000f0044fffe0
00822220008222200088222200822220088222006f5552226f551222ccc62c0c000620005c7777c5d4f4f4d00d4fff4d07667756066677600fcffff00944fee0
0082222000822220008222200082222000080000000008886f55188800062000000620000005050c0d444d0000d444d076576565076576560f0000f00094fe00
07777770000000760777777000000076007777700000000000000000fefdfceffefffcef9444444f0000004f00000000ff0000000099990000aaa900009aaa06
06666666077777660666666607777766006665550800000000777000edfedefefdfedefd4a7a9cfd000004fc00000000cff0000009444fe0009999000099990b
eefffdf50666666000ffdfd60666666000055d6608805076777777600edefffdefdedfdf47cff7cd00004fc0000000000cff000009ffffe0001f1f0000f1f10b
e05555550efffdf0555ffffe00ffdfd00011ffde2221e57666666660000edf000fecffde4a9a7cfd0004fc000004400000cff0009444fffe6b4444000044440b
00111100055ffff050111110005ffff000811ff0221ee5760ffdfd000000e0000f0cdffc49cff9cd004fc0c0004fff000c0cff009ffffffe0fbb4ff404f444ff
8288220000111110002882200055111008222100001e5f76055fff0000000000000ecfdc4a7a9cfd04fc0c0004fccff000c0cff00444fff004f4bb4004ff440b
08222220008828000222282000882250082200000ee5fd6608151120000be0c0b0000fc0feeeeeec4fc00c004fc00cff00c00cff04ffffe0000aaabb04aaaa0b
0000002200028000000002800008200000220000e000d660082052200b0000b100e000000c0c0c0cfcc00c00fc0000cf00c00ccf004ffe00000999990099990b
0007770000000000566666600000000000000000077777000777770007665e0077665e009444444f00cc800000cc0000009c08000aaaaaa0111d555555555555
007777760007770065666660000e6000000e6000766677707666777676d5de0066d5de004f7a9cfd009090cc00800acc0800908ca9a9a9a9111d555550000055
056666660077777605fdfd0050776000507760006c6c6776656567776f5ffe006f5ffe0047cff7cd000008000909009000000000aa9a9a99111d555000000005
055eee50056666660effff005766008057660800666667776666677765fffe0005fffe004acffffdc8900000c0000000c090a900a9a9a994111d555000000000
00111150055eee50011eee0056fd028256fd08226c6667776c566777011110000111100049cff9cd00897980098008000009900099999444111d555444444000
0022220000111150088110e05fdf18225fdf1282065677770666777008822220008222204f7a9cfd04a44ff004a44ff004a44ff0aa9a9944111d555766444440
0022000000222220882200000ef182200ef1228000777750057777500008222200288222feeeeeec004affc0004affc0004affc0a9a9a494111d554616476644
00200000002222000220000000e1220000e12200050505055050505000000000000000000c0c0c0c0004f0000004f0000004f000099944401122224664461644
577777760000e000e777777500050000effcfffe55f555f5b000000e000000009444444f9444444f00c9f000000000000000eeee099999901222204444466640
05666666077777760666665607757776cfffffdf5fff5fff0b60b00000ffff004a7a9cfd4a7a9acd000a40cc000000000000ffff9955554fd244200422444440
05ffdfde066666660efffd5006656666fdfffdef5fff5fff107000610f4444f047cff7cd47cff7cd0009f0000000ccc07776ecec959554efdd44400002444400
005ffffe00ffd5d000fff5f000f5fdf0fcdffefc5fffdfff06700e70f499994f4acffacd4a9afffdccc4f00009aaeceaece6cccc95594eefdddddd0000000002
0011111000f555f00011111000f5fff0ffefcfdd55555555e776b57149aaaa9449cff9cd49cff9cd0009f000aaaacccaccc6feef9554feefdddddddd00000022
00822220001111100022822000111110dffffccf5dff5dff077706759a9999a94a7a9cfd4a7a9acd000a4cc009aaaaaa5556feef954eefefddddddddddd24442
00082220002822220008222200882222effedffd5ffd5ffd57675767a944449afeeeeeecfeeeeeec0009fcc00a9a9a9a5556feef94eeeeff5ddddddddddd4444
00028200008222200082222000822220fefdddfe555555557656765694c00c490c0c0c0c0c0c0c0c00a94f000eeeeeee5556feef0ffffff05555ddddddddd44d
118080f580806080608060808050808080805080708080f55070508050708070808060808080800240400240400280608080c280111111112191e180808080f1
1111114180f11111114180808080808080801180806080a77180a7808080806080808003620380f11111211111902111111111e1c2c2c2511111111111212111
11601111112111211190112111111160808011218080801121111190111180808080808060808003e4f50360e40380808080808011e1c25111e180608080f111
e17051119011e170511190808080c270e0f011c280809031313131b0c0808080803131313131111111111121e1905121111121c2c2c2c2c22111111121212111
117070c2708080c28090808080c28080c280808080708080511111901111a0a0a0a0a0a0a0d01131313131313131318060806080118080801180608080f11111
70c28070908080c270119080608080808080118080809011111121c280b0c0801080f2111111e1c25050c2606070d557575757c2c2c2c2c21111112111111111
11704070408040804090c67040804080408040a68080c2708051e19051e17070c27070c270705111111111111191e18080808060578060801190111111111111
80807080907080f580119080806080c280601180806090112211118070c280b0c080201111117070505070d6d6d611111111111141c2f111e180808080805111
11707070708080808090a7508050f550806280a780708080808080908080808080808080808080112240c21122e1808080119011111111111190808060808011
90111111111111111111908080808080808011608080901111f57480808020c280d031111111a292929292a2111111e1c2f2c251111111e18080c280f370c611
113131313131313131313131313131313131313180808080e0f03131319080708080808080e0f01111c47057d580808060809080808080801180408080408011
9080408080808040800280806080c270e0f011c280609021112211114180808080c21111f5747080505080801111e14080408040511111a6408080807170a711
11a681b64080401122112211221122112211221180807080708011111190807070808080808080511111221111903180806090807080c280116080f580808011
90808050d6d550808003f580808080808080118080809011111111111111808011111111313131c25050e0f0111180808080f580801111a780f1111111111111
11a771a7808070575757575757575770c27011113242808070801122119080807080c280c28080205111111111901160803131807080806011a2111111119011
111190111111111111111111324280c27060118080609011221121e1808080708080511111111180505080801111901111111111111111219011111111111111
11111111119011111111221122112211229022118080807080701111119080808080808080808070202020205190e18060112180808080802180808080809080
801190808060808080808011808080808080118080809011112111a0a0a0a0a0a0a0d0116074f58050508080111190707050708080111111901111e180c25111
11e180511190408080801111111111f260705757807080c2808011221190807080e0f03132428020c220c28070902060802111d65680606011c2806080809080
801190a64080b68040c680118080c270e0f011f280809074f5221180c270c2c270c28011313131324250c2801111908070707080801111219011e180c2808011
1180c2801190807080808011221122112211221170808080e0f011111190808080808002707080202020202080202080801121d6d65680801180808080809080
601190a75650a75056a78011808080808070117080809011211111808080808080808011111111805050808011119011a0a0a0a0a01111e1901170c280806291
114180805770708040807070112111211121111180808080808011221190807080808074808080e0f03132422070208080111111111111902180808080608080
801111111111111111119011324280c280801180806090112221118070c28070c280801111111180505080801111902080c280c2800202809011c28080f19191
11919191919191418070808022112211221122213242807080801111118080808080807480708070200220202020208080304080808080901180608080806060
80028070c27080c27080900280808080807011d680809021111121808080808080808011111111805050e0f0111111118050808080030380d657c480f1919191
91919191919191914180408011111102707070028080808080700270028040d6d6804074d6d640204074d7d720d5d5808020f480568080902180d6d680808080
8074608080f4d6808080907480808080d62011d6d68090119630024080808080d680400280800280d550808002303002808080f1111111111191919191919191
919191e175857551914180805757570380500403628060d656800370038080a4b4d65603a4b4f462f403a4b410a4b480d510e450d6d580901180a4b480d66680
8003808060a4b48080809003808056d6111111d6d6f5901171100350d5d58080d6d65003808003d5d5d5808003101003c480f191919191919191919191919191
9191e1a1a1a1a1a15191919111111111111111111111111111111190111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111919191919191e175855191919191
9191a1a1a101a1c2a17551919191e175c2757585758575855191e19051e1758585758551e175519191e18575519191919191e1758575855191919191e1758590
758575855191919191e175855191919191919191919191919191919191919191919191919191919191e17585758551919191919191919075c2b6c2a185519191
91e1a1a1a1a1a1a1a1b6a1919191a1c6a1a6a1a1a1a1a1a1a1a1a190a1a1a1a1a1a1a1a1a1c2014747c2a1c2f19191e17585a1a1a10101a151e17585a1a1a190
a1a1a1a1a151e17585a1a1e3a1919191919191919191919191e153758551e17551e15191919191e175a1f201f5a1a1755191919191e190a1a101a1a1f2a15191
9181a101a1a1a1a172a1f191919141a1a1a1a1f141a1010172a1a190a1a101a1f5a1a101a1a1f1919141c2f1917585a1a1c6d3a6a1a10101a1a1a1a1a1010190
a1a1a1c2a1a1a1a1a1a1a171a111919191e1905191919191914171a1a1a1a1c2a1a1a1519191e1a1a1519091e1c2a1c2a19051e175a190a15191e1a101a1a191
917162a1a1901191119191919191919111919191919111919191119191919191119111911191919191919191e1a1a172b2a171a1a1a1a101a1a1a1a10101a190
a1a1a172a1f572b2a1a1111111119191e1a190a151e151919191919141a1a1a1a1a1a1a17585a1a1a1a190b6a1a101a1a190a1a1c2a190010185a1a1a162b291
919191a1a190519191e175857575519191e175f2755191919191e17585855191e175855191e1755191919191a1a1909191119111e1a1a1a1d601a1a6a1a1a190
a1a15111911191e1a1a15191919191e1a10190c2a1a1a175519191919141a1f19141a1a19701a1a1a1a190a1b2a1a1a1a190a1a1a1a190a1010101a151911191
9191e1a1a190a17575a1a1a1a1c2019001a1a1a1a1a1519191e1a101b6a1a17501a1a1a175a1a19591919191a1a19075855191e1a1a1a1d6d6d6a1a156a1a1f2
a1a1a15191e185a101a1a1519191e1a1a1a19001a1c2a1a1a1519191919111919191417271b2a1a1f1919191e1a1a1a1a190a101010190a1a1a1a1a1a1519191
9191a1a1a190a1a1c6a1a1a601010190a1a1919091a1a151e1a1a1a1a1a10101a1a1a101b6a1a1719191919101a190a1a1a101a1a1a101519191119011e1a101
a1a1a1a175a1a1a1a1c2a1a19191a1a1a1a190a10101a1a1a10175519191919191919111919141f1919191e101a101b6a190010156a190a1a1a1a1a101a15191
9191b2a1a190a1a1a1f57201a1a1a190a1a6759075c6a1a1a1a1f19191e101b6a1a1a1a1a172f19191919191a1a190a1a1a1a1a1a1a1a1a175855190e1a1a1a1
0101a1a1a1c6c2b6a1a1a1f191e1a1a1a1a1a1a1a1a1a1b6a1a101a175857585519191919191911191919101a1a1a1a1a101a151e1a190a101a1a1a1a1a10191
91919101a1c2a15191119191e1010190a1f5a190a1a1b272a1f191e175a1a156a101a1519191e17585519191a1a1900101a1a1a101a1a1a1a1a1a190a1a1a1a1
a1a101a1a1f5a1a1a1a1a19191a1a1c201a1a1a1a1a1b272f5a1a1a1a1a1a1a1c2755191919191e15191e1a1a1a15190e1a1a1a1a1a1c2a1a1a1a6a187a1a191
9191e1a1a1a1a1a175858575a1a1a10101519191909191919191e10101a15191e1a1a1a17585a1c201a19191a1a1f201a1a1a10101b6a1a1c2a1a190a1a1a1a1
c2a1a1a151919191e1a1f191e101a1a1a1a1a1a1a1f111911141a1a10101a1a1a101a151e17585c2a185a101a1a1a190a1a1a1a1a10101a1a1a1a1a17172f591
91e1a1a1a1a101a1a1a1a1a1a1a1a1a101a17575907585758575a1a10101a685a1a1a1b2a172a1a101c3919141a101a1a1a10101a1a1a1a1a1010190a1a1a1a1
a1a1a1a1a1857585a1a19191a10101a1a1a1a1a1f1919191919141a1a1a1a1a1a1a1a1a1a1a1a1a601a1a1a1a1a1a190a1a1a1a101a1a1a1a151919191919191
91a1a1c2a1a1a101a1a1a101c2a1c2a1a1a1a1a190a1a1a1f2a1a1a1a1f501a1a1a151919091e1a1a171919191a1a1a1c201a1a15190e1a1a1a15191e1a1a1a1
a1a1a1a1a1a10101a1f19191a1a101a1a1a1a1f19191e17551919141a1a1a1c2f5c2a1a1c6a1a1a1a10101a1a1a1a690c6a1a1a1c2f5c2a101a1857575519191
91a1a1a1a1a1a1a1a1a1a1a1a1a6a1a1a1a1a1a690c601a1a1a101a1f191919141010175c285a1a1f19191919141a1a1a1a1a193a190a1a1a1a1a185a1a1a1f1
9141a1a1a10101a1a1919191f3a1a1a1a1a1f19191e1a1c2a151919141a1a15191e1a1a1a1b2f19141a10101a1a1a190a1a1a1a15191e1a1a1a1a1a1c2a19191
9101a1a1a1a156a1a101a1a1a1f5a1a1a1a1a1a19001a1a1a1a101f19191919191416767676767f1919191919191a1a1a1a1a171a19062a1a1a1a1a1a1a1f191
919141a1a1c3a1a1f191919171a1a1a1a1f19191e1a1c2a1c2a151919141a1a175a1a1f1919191919141a1a1a1a1f590a1a1a1a1a175a1a1a1a101a1a1f19191
91676767671121116767679121112191676767119191676767676791919191919191919191919191919191919191416767671191219111676767676767f19191
91919141a171a1f1919191919141a162a1474747a1c2a162a1c2a1474747c4a172a1f19191919191919141a1a1f191919141a172a172b2f5a1a172f111919191
919191919191919191919191919191919191919191919191919191919191e15191919191919191919191e1519191919191919191919191919191919191919191
919191919191919191e1519191919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191
__gff__
00000000000000000020000000000000008f8f0f1c830000008f00000000851a00818f0000000000010101000000000000800000000000000000000000000000000000000000000000000101000001000000000000000081810000000001000000000000000000000000000000010001000000008f8f100000000000000f0000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
11000800080008001111000800080008110802232410102000080608070906060708081a1a1a1a151e1a1a1a1a081100000000000000000000110011001100110000000000082c2c0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080808080000000011
1108080808082c081111080808080808110602080406104707084f080609080608041a1a1a041a1a1a1a041a1a081100000000082c08000000111111111111110808080000110808110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c2c2c08080000000011
115908060808080602020b0c080608081108020805070630104e4e086d09060708061a1a1a5d5d1a1a1a1a7d1a1a11000000000808080000000308691111112c08080800001111111107000000000000000000000000000000000000000000000000000000000000000000000000000000000000001108080811080808082c11
11170806060911111111082c0b0c06081111111111111111111111111111112a29292a57585757580957575857581100000000080608000000010817111111086a396c00000811110707070807080708000000000000000000000000000000000000000000000000000000000000000000000000001111111111080202080811
111111060709060611110606082c0d081108080800080808000808080000000808080808000000000000000000000000000000111111000000091111111111087a177a08080811112c07080708080807000000000000000000000000000000000000000000000000000000000000000000000000000011111108080202082c11
111211070609064f111106060606010811082c0800082c0800082c080000000808080808000000000000000000000000000000082008080808091111111111111111111111091111070708082c2c0707000000000000000000000000000000000000000000000000000000000000000000000000000011111108080202080811
1111112c07095f4e110606060606111111080308004f03080008030800000008060606080000000000000000000000000000002c470608060809474f5f074708082c0808080911112c0707080808070800000000000000000000000000000000000000000000000000000000000000000000000000001111116a350202076a11
1122110607111111112a2929292a12111108014e4e4e015f0806010800000008080808060808080608080608000000000808060847080808080911111109112a0808080808091111070708110807110800000000000000000000000000000000000000000000000000000000000000000000000000001111117a170101267a11
111111060711121108085f082c0811111109111111111111111111110608060806060808080806080608080808080808060808083008080608091111060911080808086d6d0911112c07081111111107000000000000000000000000000000000000000000000000000000000000000000000000000011111111121112110911
1112110706202c1108112a2929292a1112090808082c0608081108080806080808080808080808080808080806080806081f1111112a292a111111112f09115f08086d6d6d6d75750826080811110808000000000000000000000000000000000000000000000000000000000000000000000000000015121111111112110911
1111112c07300711080808082c085f11110904080408040804200a0a0a0a0a0a0a0a0a0a0a0a0a2004080408040808081f1e060606080608081511111111111109111111111111111111111111112c08080800000000000008060808000000000000000000000000000000000000000000000000000008151111112c08080911
1112110808111111111211112a292a12110908050605080508300808060808086a2c2c6b0806083008055f050805081f1e080808080808082c080608086d20080908082c08080008082c080011110808060800000000000008062c2c000000000000000000000000000000000000000000000000000008081511110804080911
111111080811111108082c082c080811110911111111111111111111090807087a08087a08060913131313131313111e0808082c08080808080808087d7d470809080408040804080408044f1111082f08080608080000000811080811070000000000000000000000000000000000000000000000000808081511086d6d0911
1111110808030803080408040804070303096a082c0807082c086b110908080811111111080809111111111111111e08082c080608080608085f087d7d7d300809080805080508055f05084e75754f08080608080800000008111212110700000000000000000000000000070707070000000000000008080807110911111111
1111110808010801080808080708080101097a080708080807087a11090607081511111e08080920042f2004072008080808080808061313131313131313131313131313131313131313131311114e085f080806080808080808111107070000000000000000000000000007393c070000000000000008080808110908082c11
11111111111112111112111111121111111111111111111111111111090807070811110808080930050630055f30080806080808060815121111121111121e0808082015121e2008111111111111111111110908082c0806062c11112c070000000008070808080800000007070707000000000000000808082c110908046d11
111e08042008044f2004080820080704080711111e2c1511080808755f08080808111108060813131313131313132a292a1309080808081511121112111e0808060847082f084708111e2c1511111e0608080906080806060806111107070000000008080807080800000007070808080800000000000808080811096d6d6d11
11060808306d084e30085f083008080808080807080808112c042c1111112a292a11110608061111111111111111060806080908082c0808202c207d2006082c080847080208470711080808111108080608080808080808080811112c080806080807082c2c0808000000070708080808000000000008080808111111110911
1108080913131313132a2a11110a0a0a0a0a0a0a0a0a0d11080808112211080808111108080811112211221122110808080608086a0806084708477d47082c082c084708020847081109080811114f0408040804087d080879081111080808080806081108081108080808080807070707000000000008080808112c08080911
11060809111111121e0808151e0808082c08111109080811110911111111060608111108060611111111111111110808060808087a0808083007307d3008080808084708020847081108080911114e5f080808087d7d7d081708111108060808080808111111110808080707080708070700000000000808082c1108046d0911
110806091111121e08060802020806080808111109080711080908110808080608111108080808200407200406200b0c08080608132a292a130913131308064f06084708070847061178080811111111111109111111111111111111080808060408040811112f0807080808080707080707000000000808080811086d6d0911
1108080911121e0808082c02020608062c08111109080811080808110808080808111106060808300705305f0530082c0b0c080808080808150901010108084e5f083008010830071117080808080808060809082c08202c11110608080808080808062c11110808080807080807070707070000000008080808110911111111
1106080604080808060808020208080804061111090708200704082008046d040820200808081f131313131313130806082c0b0c08080608081111111111111111111111091111111111111408080608060409040608305f111108066a3e6c060408040811112c0808080808080808080808070000000807080811096d082c11
112a0808085d08085f0808020208085d0608757509075d3008080830084a4b085f303026081f121111111111111108080808082c0b0c08080711110808080808060808080906080808080815140808080808090808111111111106087a177a080808082c121111080806080808080806080707001b000808082c11096d046d11
110806111112112a2929292929292a12111211111111111111111111111111111111111111111111221122112211080708060808062c0b0c081111080807060808080708090808080807080815140806080409040806080411110809111111090408040811112c0608080806060807080807080000000808060811096d6d6d11
11082a11121e080806080808060808080608080707080808070608060808080808060807080808111111111111110808080806080708082c0d111108080808080708080809080708080807080815140808060906080805081111080915111109085f0808111211080606080808080806080608085b0808080708111111110911
110806111e06060808062c0806062c07070707070707080708080807082c0807080808082c080820030320030320080608080808074f08060808200804080408082c08080908082c080708080808151408040904081f110911110808081511111111091111112c0808080606080806080606085a5b5c08060806112211220911
112a08110606060604060606040606070407040707086a086b080808040804080408070808070830010130015d300808085f08085d4e5d5d080830086d6508080808086a096c08080808080808060815140809081f1111091e080808080808030803091112111106080808080808070608085a0205025c080808111111110911
110606060606060605060606050606075f05070707087a087a080708085f08050808080807081f131313131313132a292a1313131313131313131313131313145f08087a097a0808085f080408040808151111111e08080908080606082c04020402091111112c080606080808060808085a02020202025c08082002026d0911
110911111106060911110809111211091112110808091111110808111111111111111408081f12111111111111110808070807080815121112191919191112112a292a1313132a292a131408650808080815111e080608090806080806085f0108010911121111060808086d5d084f086a020202770202656c0647026d6d0911
1109060606060609062c0609062c06090707070707090808080808080808070815111111111111112211221122110a0a0a0a0a0a0a0d1122111919191e08080808080815111e080808151111111111060808110806080809080808081111112a292a0912111208080808084a4b085d267a2e2e017b7c016d7a08305d6d6d0911
11090408040808090804080908040809080804080809080704080407040808080808080808061511111111111111080808080808060815111119191e082c08081f1114082c081f111408151112111e08080611060808066a3d086c0815111e0806080820032008081f1313131309131313131313131313131313111111111111
__sfx__
000100010c17000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0101000017241043412f6302f6202f6102461018300184000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c100
011000000c07300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800020c317183170c0001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000011842018420184201842000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000300000a750137501b7302770030700377003c7003f7001d7001670000700007003450034500345003450000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000e7501970016750317001d750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000240100f740046101c0000962000600006000e620000001662000000000001961000000000001361000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000140a8500a8000a0250a8500a0250a815118400a035118300a8000a850168150a0250a8500a8000a850128301103503050088250a8000a8000a8000a8000a8000a8000a8000a8000a8000a8000a8000a800
011000140c9131a7141a7141a7140c923197141a714197140c91312704197141d7140c9231171414714197140c913227141c7141b714000000d90000900009000090000900009000090000900009000090000000
0110001418a40167141671418a400c900127140c930127141271419a2018a40167140c900167140c9301271418a40197141971418a20000000d90000900009000090000900009000090000900009000090000000
000600002410325103251032410324103241032410300003000030000300003000000000018a03000030000318a03000030000300003000030000318a03000030000300003000030000000000000000000000000
01100014197241971416716197141672416714177161671416714197151972419714197141971417714177141d7241d714197161d714000000000000000000000000000000000000000000000000000000000000
0110001416c4011c3014c2014c1516c4011c3014c2014c1214c1214c1214c150dc300fc3511c3212c3014c3516c3617c3219c351bc301dc001dc001dc001dc000dc0000c0000c0000c0000c0000c0000c0000c00
011000141dc4019c301bc201bc151dc4019c301bc201bc101bc101bc101bc121bc1519c3518c3016c3020c301ec301dc351bc3619c301bc000000000000000000000000000000000000000000000000000000000
011000140785007800070250785007025118350684006035108500a800058501181505025058500a8000c8300b8500b03517830178250a8000a8000a8000a8000a8000a8000a8000a8000a8000a8000a8000a800
0110001418a401671416714167140c930127141271412714127141271418a40167140c900167140c9301271418a40197141971418a20000000d90000900009000090000900009000090000900009000090000000
0110001417c3017c3017c3017c3017c2217c2217c2217c1217c1217c1215c3015c3015c3015c3015c2215c2215c2215c2215c1215c12000000000000000000000000000000000000000000000000000000000000
0110001416c3016c3016c3016c3016c2216c2216c2216c1216c1216c121972419714197141971417714177141d7241d714197161d714000000000000000000000000000000000000000000000000000000000000
011000141dc4020c301dc201dc151dc4020c301dc201dc101dc101dc101dc121dc1519c3518c3016c3020c301ec301dc351ec3625c301bc000000000000000000000000000000000000000000000000000000000
0110001423c3023c3023c2123c2023c2223c1223c1223c1223c1223c1224c3124c3024c3024c3024c2224c2224c2224c2224c1221c120c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000
0110001422c3022c3022c3022c3022c2222c2222c2222c1222c1222c121972419714197141971417714177141d7241d714197161d714000000000000000000000000000000000000000000000000000000000000
011000140a8400a8210a8110f8550f0550f815168400f03516830168110a8400a8210a0550f8400f8210f045178300a030080550f8250f8000f8000f8000f8000f8000f8000f8000f8000f8000f8000f8000f800
0110001418a402271422712227120c930287122a7122e7122e7122e71218a402c7122a712287120c9302871220712227120000000000000000000000000000000000000000000000000000000000000000000000
0110001428c402ac3628c2727c1028c402ac3628c2727c2027c2027c2027c2027c1227c1227c1227c1228705257052770518a2019a300c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000
001000140b8400b8210b8110b8550b0550b815128400b03512830128110684006821060550b8400b8210b0451383006030040550b8250b8000b8000b8000b8000b8000b8000b8000b8000b8000b8000b8000b800
010e001418a401e7151e7151e7150c930227151b7152e702227151b71518a401b7151e7151b7150c930257152071522715207051b715000000000000000000000000000000000000000000000000000000000000
0110001428c402ac3628c2727c1028c402ac3628c2727c2027c2027c2027c2027c1227c1227c1227c12317052c7052e70518a2019a30180001800018000180001800018000180001800018000180001800018000
0110001422c4023c3622c2720c1022c4023c3622c2720c2020c2020c2020c2020c1220c1220c1220c1225705207052270518a2019a30000000000000000000000000000000000000000000000000000000000000
011000140d8400d8210d8110d8550d0550d815148400d03514830080100884008821080550d8400d8210d0451583008030060550d8250d8000d8000d8000d8000d8000d8000d8000d8000d8000d8000d8000d800
0110001418a401d7151d7151d7150c93022715197152e702227151771518a401b7151d7151b7150c93025715207152271518a0019a00000000000000000000000000000000000000000000000000000000000000
011000140a8400a8210a8110a8550a0550a815118400a03511830050100584005821050550a8400a8210a0451283005030030550a8250a8000a8000a8000a8000a8000a8000a8000a8000a8000a8000a8000a800
0110001418a401a7151b7151a7150c930227151c7152e702227151a71518a401b7151d7151b7150c9301c715207152271518a0019a00000000000000000000000000000000000000000000000000000000000000
0110001418a401e71220712277150c9301e712207121b7121b7151b70518a40287122a712277120c930287122571227712257121e712000000000000000000000000000000000000000000000000000000000000
011000141cc401ec361cc271bc101cc401ec361cc271bc201bc201bc201bc201bc121bc121bc121bc1228705257052770518a2019a300c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000
0110001418a402971227712297120c9302f7122e7122c7122c7122c71518a402971223712227120c9302771222712207121b71217712000000000000000000000000000000000000000000000000000000000000
010d00142ec402fc362ec272cc102ec402fc362ec272cc202cc202cc202cc202cc122cc122cc122cc12317052c7052e70518a2019a300c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000
011000140a8400a8210a8110a8550a0550a815118400a03511830050100a8400a8210a8110a8400a8210a0451783016030140550a825008000a8000a8000a8000a8000a8000a8000a8000a8000a8000a8000a800
011000140f8500f8000f0250f8500f0250f815168400f035168300f8000f8501b8150f0250f8500f8000f8501783016035080500d8250f8000f8000f8000f8000f8000f8000f8000f8000f8000f8000f8000f800
0110001418a402971229712297120c930267122371222712227151b71518a402f7122c7122e7120c93025715207152271518a0019a00000000000000000000000000000000000000000000000000000000000000
001000141e7241e7141b7161e7141b7241b7141c7161b7141b7141e7151e7241e7141e7141e7141c7141c71422724227141e71622714050000500005000050000500005000050000500005000050000500005000
010100002f65018650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000473004730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000973004730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000873011720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000207101c71019720316202d61028620246202261022610236001b710187101f60017710166100d61008610056200261000700000000000000000000000000000000000000000000000000000000000000
000500000474005740000000000004720037200000000000037100071002700000000000000100001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000013220232301a7401b240162300b7301172008720077100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b7302973027730257202572022720207201e7201c7201c7201b7201a7201972018720177201572013710107100e7100a7100a7100971008710067100371002710007100000000000000000000000000
00010000117401475017760187601a7601b7601b7601a760187601576012760107500c74006720047100171000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001f12014120151200b03009030040301513014120060200401004010091100811003010020100811007110000000000000000000000000000000000000000000000000000000000000000000000000000
0003000002120041200012000120111201a1202012000000000001112017120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003e52000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000023020000002902000000000002e0200000034000330200000000000380200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 08 10 43 0b
00 08 10 43 0b
01 08 10 0c 0b
00 08 10 0c 0b
00 08 10 0d 0b
00 08 10 0e 0b
00 0f 0a 11 0b
00 08 10 12 0b
00 08 10 0d 0b
00 08 10 13 0b
00 0f 0a 14 0b
00 08 10 15 0b
00 16 1a 22 0b
00 19 1a 22 0b
00 1d 1e 1c 0b
00 1f 20 1c 0b
00 16 17 18 0b
00 19 21 1b 0b
00 1d 23 24 0b
00 25 27 24 0b
00 26 10 28 0b
02 26 10 28 0b
01 08 42 43 44
03 41 1d 43 44
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
