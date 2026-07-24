pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--bullet hell with a sword
--made for s&t acm arcade jam

--variables

--[[
  naming conventions
  p = player
  k = knife
  b = bullet
]]

--stats
start_time=0
finish_time=0
bullet_count=0
deaths=0
kills=0

krot = 0 -- spin angle
kdeg = 0 -- turn angle
kdist= 16 -- distance from p
--ks   =.66-- scale
--kspin_spd=0 --rotation
--kturn_spd=0 --position

kpos_x=0 --knife position
kpos_y=0 --updated each frame
klen  --=11*ks
						=7.26
ktip_x=0
ktip_y=0 
kend_x=0 
kend_y=0

khit_delay=3 -- how often k hits
---- delays for focus / normal
--khit_delay_n = 3
--khit_delay_f = 3

--kdmg = 4
--kdmg_n = 4
--kdmg_f = 4

-- player

p_x=64
p_y=64
--p_mvspd=2.2
p_flpx=false
p_lives=3
p_inv=0 -- invincibility

p_sp_n=1
p_sp_f=17
mvspd_n=2.2
mvspd_f=1.0
focus = false --if p is focusing
p_hitrad = 0.2 --radius of hitbox
p_iframes = 45
show_hitbox=true

bg_items={}
bg_timer1=0
bg_col=0

wave_offset = 0
--wave_speed = -1

-- used by level to track time
l_time=0
l_time_last=0
cur_level=0

-- holds level info
--set by init_l#()
--l={}

-- highest level unlocked
max_level=0
-- if we're in the level select
lv_select_active=false
lv_select=1

-- used by gameover
--go_timer=0

-- you get the idea
--intro_timer=0
--intro_fcounter=0 -- counts focus time
--intro_state=1
--intro_s_state=0
intro_completed=false

--whether to make the help page the win screen
win_screen=false

-- screenshake vars
shake_x=0
shake_y=0
shake=0
do_shake=false

-- particle list
pa_list = {}

-- enemy list
e_list = {}

-- bullet list
b_list = {}

-- pattern list
pt_list = {}

-- pickups list
pu_list = {}

-- init to menu
function _init()
 start_music(true)
 
 toggle_scrsh()
 toggle_hitbox()
 menuitem(3,"unlock all lvl", unlocc)
 
 --unlocc() --the monado's power
 
 init_menu()
end

-->8
--utilities

-- euclidean distance
function dst(x1,y1,x2,y2)
 
 local a,b=abs(x1-x2),abs(y1-y2)
 
 -- approximate
 return max(a,b)*0.9609+min(a,b)*0.3984
 
 -- exact
 --return sqrt(a*a+b*b)
end

-- random vector
function rand_dir()
 return rnd(2)-1, rnd(2)-1
end

-- rand int
function randi(h) --inclusive
 return flr(rnd(h+1))
end

-- normalized dx,dy between points
function dir(x1,y1,x2,y2)
 local a = atan2(x2-x1,y2-y1)
 return cos(a),sin(a)
end

-- rotates x,y by and angle a
-- around screen center
function rotated(x,y,a)
 local s,c = sin(a),cos(a)
 local xx,yy=x-64,y-64
 return xx*c-yy*s+64,xx*s+yy*c+64
end

function toggle_scrsh()
 do_shake = not do_shake
 menuitem(1,do_shake and "scrnshake off" or "scrnshake on",toggle_scrsh)
 shake=0
end

function toggle_hitbox()
 show_hitbox = not show_hitbox
 menuitem(2,show_hitbox and "hide hitbox" or "show hitbox",toggle_hitbox)
end

function unlocc()
 start_time=-1
 max_level=3
 intro_completed=true
 poke(0x311d, peek(0x311d)^^128)
end

function start_music(loop)
 music(4,0,6)
 if loop==true then
  poke(0x311d, peek(0x311d)|128)
 end
end
-->8
--menu/credits/cutscenes

function init_menu()
 _update = update_menu
 _draw = draw_menu
 
 wave_speed=-1
 if max_level==1 then
  init_bg(11)
 elseif max_level==2 then
  init_bg(12)
 elseif max_level==3 then
  init_bg(0)
 end
 
 win_screen=false
 
 p_x = 64
 p_y = 84
 -- controls trans location
 
 intro_s_state=0
 lv_select_active=false
 
 trans_open(nil,65)
end

function restart()
 music(-1)
 start_music()
 -- set loop point again
 --poke(0x311d, peek(0x311d) | 128)
 p_sp_n=1
 go_timer=-1
 init_menu()
end

function init_help()
 _update = update_help
 _draw = draw_help
 
 --needed for winscreen
 if stat(24)==-1 then
  start_music() end
 
 trans_open(nil,65)
end

function update_menu()
 --process transitions
 process_transition()
 
 if btnp(Ž) and trans_func==nil then
  if intro_completed==false then
   sfx(60)
   music(-1,1200)
   init_intro()
  elseif lv_select_active == false then
   lv_select_active=true
  else
   trans_close(3,-20)
   trans_func = init_game
  end
 end
 
 if btnp(ƒ) and lv_select_active and trans_func==nil then
  lv_select=mid(1,lv_select+1,max_level) end
 if btnp(”) and lv_select_active and trans_func==nil then
  lv_select=mid(1,lv_select-1,max_level) end
 
 -- just to be safe
 lv_select=mid(1,lv_select,3)
 
 if btnp(—) and trans_func==nil then
  if lv_select_active==false then
   trans_close(nil,-20)
   trans_func = init_help
  else
   lv_select_active=false
  end
 end

end

function update_help()
 --process transitions
 process_transition()
 
 if btn(—) and trans_func==nil then
  trans_close(nil,-30)
  trans_func = init_menu
 end

end

function draw_menu()
 cls()
 --rectfill(0,0,127,127,0)
 
 if max_level>=1 then
  draw_bg()
 end
 
 if max_level == 0 then
  map(0,0)
 else
  draw_carpet()
 end
 
 draw_logo(13,25)
 
 if lv_select_active==false then
	 print("press Ž to start", 30, 100,7)
	 rectfill(46,112,81,118,1)
	 print("— help/credits", 34, 113,12)
 else
  rectfill(46,112,81,118,1)
  for i=1,3 do
   local col
   if i<=max_level then col=6
   else col=13 end
   if i==lv_select then col=7 end
   print("level "..i, 51, 86+8*i,col)
  end
  print(">         <", 43, 86+8*lv_select,7)
 end
 
 spr(103,60,60,1,1) --pedestal
 draw_intro_sword()
 draw_player()
 
 -- draw transition last
 draw_trans_overlay()
end

function draw_help()
 cls(1)
 
 -- credits
 local textcol = 13
 palt(0, false)
 palt(9, true)
 spr(138,10,4+stat(20)%16/8,2,2)  --fred
 print("a game by",30,10,textcol)
 print("athakaspen",70,10,8)
 
 spr(142,104,22,2,2) --arcade
 rectfill(108,28,115,31,stat(20)/4+7)
 print("made in 1 week for an",14,25,textcol)
 print("s&t acm arcade",6,31,11)
 print("game jam",66,31,textcol)
 
 sspr(96,64,16,16,7,45) --moon 
 local amt=flr(time()*7.24%14)-7
 spr(174-abs(amt)*2,7,44,2,2,amt>0,amt>0) --moon 
 
 print("music is adapted from",30,44,textcol)
 print("\"jack of all trades\"",30,50,12)
 print("by",30,56,textcol)
 print("casejackal",42,56,10)
 palt(0, true)
 palt(9, false)
 
 
 
 if not win_screen then
  
  draw_focus_tutorial(100,82)
  print("hold Ž to focus", 6, 72,7)
	 print(" - faster spin", 6, 84,7)
	 print(" - slower movement", 6, 96,7)
	 
	 print("green", 6, 108,11)
	 print("is your hitbox", 29, 108,7)
	 
 else
  print("thanks for playing!",26,70,7)                                                          if deaths==0 and start_time>0 then color(10) end
  print("- deaths: "..deaths,38,80)
  print("- kill count: "..kills,28,88)
  print("- bullets dodged: "..bullet_count,18,96)
  
  if start_time>0 then
   tim=flr(finish_time-start_time)
   print("- total time: "..tim\60 .."m "..tim%60 .."s",22,108)
  end
 end

 print("— main menu", 38, 120,12)
 
 -- draw transition last
 draw_trans_overlay()
end

function init_intro()
 _draw = draw_intro
 _update = update_intro
 intro_timer=0
 intro_fcounter=0
 intro_state=1
 ped_state=0
 start_time=time()
end

function init_gameover()
 go_timer=0
 _update = update_go
 _draw = draw_go
 
 wave_speed=0
 
 -- mute music
 music(-1)
 
 --make sure player is visible
 p_inv=0
end

function update_intro()
 intro_timer += 1
 
 --process transitions
 process_transition()
 
 update_particles()
 
 if intro_timer > 5 then
		-- check for focus mode 
		check_focus()
		p_move()
 end
 
 if intro_state == 1 and 
 dst(p_x,p_y,64,58) < 22 and
 focus==true then
  --scripted sword pulls
  intro_fcounter+=1
  if intro_fcounter%5==0 then
	  newp_simple(64,64)
	  --play sound if free channel
	  if stat(19)==-1 then
		  sfx(57,3,0,1)
		 end
	 end
	 if intro_fcounter==50 
	 or intro_fcounter==110
	 or intro_fcounter==170 then 
	  intro_s_state+=1
	  shake=1
	  sfx(58,3,0,1)
	  
	 elseif intro_fcounter==182 then
	  intro_s_state=4
	  intro_state=2
	  shake=2
	  sfx(59,3,0,1)
	  for i=1,10 do
	   newp_scloud(64,64)
	  end
	  intro_timer=100 --bad code alert
   music(7,0,6)
   poke(0x311d, peek(0x311d)^^128)
	 end
 elseif intro_state==2 then
  if intro_timer == 186 then
   sfx(60)
   intro_state=3
   krot=0.5
   kdeg=atan2(64-p_x,45-p_y)
   trans_close()
   trans_func=init_game
   lv_select=1
   intro_completed=true
  end 
 end
 
 if intro_state==3 then
  update_kpos()
 end

end

function draw_intro()
 cls()
 --rectfill(0,0,127,127,0)
 
 --processes screenshake. 
 --called even when not shaking
 draw_shake()
 
 if intro_state<2 then
  map(0,0)
 else
  draw_carpet()
 end
 draw_logo(13,25-intro_timer)
 
 print("press Ž to start", 30, 100+intro_timer,7)
 if intro_timer < 8 then 
  rectfill(48,120,79,112+intro_timer,1)
 end
 print("— help/credits", 34, 113+intro_timer,12)
 
 if intro_state == 1 and 
 dst(p_x,p_y,64,58) < 22 and
 focus==false then
  rectfill(48,120,79,112,1)
  print("hold Ž to focus", 33, 113,12)
 end

 if intro_state==1 then
  spr(103,60,60,1,1) --pedestal
 end
 draw_particles()
 draw_player()
 if intro_state<3 then
  draw_intro_sword()
 else
  draw_knife()
 end
 
 -- draw transition last
 draw_trans_overlay()
end

function draw_intro_sword()
 if intro_s_state <= 3 then
  sspr(56,32,8,9+intro_s_state,60,55-intro_s_state)
 else
  spr(71,60,45+sin(time()*0.9)*2.9,1,2)
 end
end

function draw_shake()
 if do_shake then
	 shake_x=1-rnd(2)
	 shake_y=1-rnd(2)
	 shake_x*=shake
	 shake_y*=shake
	 camera(shake_x,shake_y)
	 
	 shake *= 0.90
	 if shake < 0.25 then
	  shake=0
	 end
	else
	 camera(0,0)
	end
end

function update_go()
 process_transition()

 go_timer += 1

 if go_timer == 1 then
  sfx(9)
 elseif go_timer == 40 then
  sfx(56)
  p_sp_n=33
  focus=false
  heart_explode(p_x,p_y)
  shake=1
 elseif go_timer == 80 then
  --sfx(40)
 elseif go_timer == 60 then
  trans_close()
  trans_func = restart
 end
 
 update_particles()
 draw_game()
end

function draw_go()

 --processes screenshake. 
 --called even when not shaking
 draw_shake()
 
 -- draw transition last
 draw_trans_overlay()
end



function draw_logo(x,y)
 -- sword
 for i=0,10 do
  spr(137,x+7+i*8,y+6)
 end
 spr(153,x+94,y+6) --tip
 spr(136,x,y+6) -- hilt last
 
 --letters
 for i=0,7 do
  spr(128+i,x+12+10*i,y+2.5+sin(-time()/2.4+i/8)*2.48,1,2)
 end
 
 --bit of the sword on letters
 --very inefficient but saves tokens
 for i=0,22 do
  spr(137,x+47+i,y+6)
 end
end

function draw_focus_tutorial(x,y)
 p_x=x p_y=y
 
 check_focus()
 update_kpos()

 --circfill(p_x-1,p_y-1,kdist,1)
 circ(p_x-1,p_y-1,kdist,7)
 --circ(p_x,p_y,kdist,0)
 
 draw_player()
 draw_knife()
 
 --draw_kpoints(8)
 
 -- hitbox
 rect(p_x,p_y,p_x-1,p_y-1,11)
end

-- transitions
trans_amount = -70
trans_delta = 0
-- func to call at trans end
trans_func = nil 

function process_transition()
 --trans_amount+=trans_delta
 trans_amount=mid(-100,trans_amount+trans_delta,100)
 if abs(trans_amount) > 70 and trans_func then
  trans_func()
  trans_func=nil
 end
end

function trans_open(spd,start)
 trans_amount = start or 69
 if not spd then spd=-5 end
 trans_delta = spd
end

function trans_close(spd,start)
 trans_amount = start or -69
 trans_delta = spd or 3
end

function draw_trans_overlay()
 --player offset x/y
 local po_x = p_x-64
 local po_y = p_y-64
 rectfill(-1,-1,128,trans_amount+po_y,0)
 rectfill(-1,-1,trans_amount+po_x,128,0)
 rectfill(128,128,-1,127-trans_amount+po_y,0)
 rectfill(128,128,127-trans_amount+po_x,-1,0)
 
end
-->8
--game

--inits level in lv_select var
function init_game()
 _update = update_game
 _draw = drawdelay
 p_x = 64
 p_y = 64
 p_lives = max(p_lives,3)
 
 go_timer=0
 wave_speed=-1
 l_time=0
 l_time_last=0
 
 cur_level=lv_select
 if cur_level==1 then
  init_l1()
 elseif cur_level==2 then
  init_l2()
 elseif cur_level==3 then
  init_l3()
 end
 
 -- clear lists
 e_list= {}
 b_list= {}
 pt_list={}
 pu_list={}
 
 if stat(24)==-1 then
  start_music()
 end
 
 trans_open()
end
-- drawdelay prevents draw_game
-- from running too early
function drawdelay() 
 _draw = draw_game
end

function init_l1()
 init_bg(11)
 
 -- setup
 l = {
    { 200,"boss1"},
  l1_swoop_group(2),
  l1_sentry(0,-.25),
  l1_sentry(50,.25),
  l1_swoop_group(0),
  l1_sentry(0,-.25),
  l1_sentry(50,.25),
  l1_swoop_group(2),
  l1_sentry(0,-.25),
  l1_sentry(50,.25),
  l1_swoop_group(0),
  l1_sentry(0,-.25),
  l1_sentry(160,.25),
    {0 ,"heavy",{true,"ring",32,22,1,20,1,10,4,0.42,-.25},{},40,36,0,40,60},
    {80,"heavy",{true,"ring",38,20,1,20,1,10,4,0.42,-.25},{},88,36,0,40,60},
  { 0,"sentry",{false,"simple",-1,1},{},108,1.1,0.5,10},
  {40,"sentry",{false,"simple",1,-1},{},108,1.1,0,10},
  { 0,"sentry",{false,"simple",-1,-1},{},20,1.1,0.5,10},
  {65,"sentry",{false,"simple",1,1},{},20,1.1,0,10},
 
  l1_swoop_group(11),
  l1_swoop_group(10),
  l1_swoop_group(9),
  l1_swoop_group(8),
  l1_swoop_group(7),
  l1_swoop_group(6),
  l1_swoop_group(5),
  l1_swoop_group(4),
  l1_swoop_group(3),
  l1_swoop_group(2),
  l1_swoop_group(1), 
  l1_swoop_group(0), 
  {95},
  
  {  0,"swoop",{},{},1,0.25,4},
  { 80,"swoop",{},{},-1,-0.25,4},
  l1_swoop_group(0),
  {60},
  { 60,"sentry",{false,"simple",0,-1,200,36,22},{},100,0.75,0,6},
  {35}
	}
end
function l1_swoop_group(i)
 return {25,"swoop",{false,"aimed",1.5,200,32+i%4*2,20},{},1.2,-0.25*i,3}
end
function l1_sentry(d,a)
 return {d,"sentry",{false,"simple",-sin(a),cos(a)},{},20,1.1,a,6}
end

function init_l2()
 init_bg(12)
 
 -- setup
 l = {
  {120, "boss2"},
  l2_ring_sentry(0, 20,.875),
  l2_ring_sentry(0, 20,.625),
  l2_ring_sentry(0, 20,.375),
  l2_ring_sentry(140,20,.125),
  l2_ring_sentry(0, 20,.75),
  l2_ring_sentry(0, 20,.5),
  l2_ring_sentry(0, 20,.25),
  l2_ring_sentry(90,20, 0),
  l2_swoop(0,-1,.5),
  l2_swoop(0,1,.5),
  l2_swoop(0,-1,0),
  l2_swoop(70,1,0),
  l2_laser_heavy(6,84,37,.75),
  l2_laser_heavy(80,44,38,.25),
  l2_laser_heavy(6,84,30,0),
  l2_laser_heavy(80,44,30,0),
  l2_ring_sentry(60,104,0),
  l2_ring_sentry(160,24,0),
  {120,"heavy",{true,"spi",48,20,2,12,10,5,1.3,0.04},{},64,56,0,50,140},
  l2_sentry(0,.8),
  l2_sentry(0,.6),
  l2_sentry(0,.4),
  l2_sentry(0,.2),
  l2_sentry(120,0),
  l2_swoop(0, -1,.25),
  l2_swoop(60,-1,.75),
  l2_swoop(0, 1,.25),
  l2_swoop(60,1,.75),
  l2_swoop(0,-1,.5),
  l2_swoop(60,1,.5),
  l2_swoop(0,-1,0),
  l2_swoop(60,1,0),
	}
end
function l2_sentry(d,a)
 return {d,"sentry",{false,"simple",-sin(a),cos(a),200},{7,23},16,1.2,a,7}
end
function l2_swoop(d,dx,a)
 return {d,"swoop",{},{11,27},dx,a,3}
end
function l2_ring_sentry(d,h,a,spd,spx)
 return {d,"sentry",{true,"ring",spx or 34,20,1,12,0.9,2,2,0},{7,23},h,spd or 1.3,a,2}
end
function l2_laser_heavy(d,x,y,a)
 return {d,"heavy",{true,"exp_line",52,20,2,7,true,1.3},{},x,y,a,50,80}
end

--l3 uses l2 and l1 funcs because tokenzz
function init_l3()
 init_bg(0)
 
 -- setup
 l = {
  {500, "boss3"},
  
  {0 ,"heavy",{true,"spi",36,22,1,30,6,7,.95,.01},{},40,36,0,72,300},
  {150,"heavy",{true,"spi",34,20,1,30,6,7,.95,-.01},{},88,36,0,72,300},
  l3_ring_heavy(20,43,.25),
  l3_ring_heavy(20,43,.5),
  l3_ring_heavy(20,43,.75),
  l3_ring_heavy(70,43, 0),
  l1_swoop_group(15),
  l1_swoop_group(14),
  l1_swoop_group(13),
  l1_swoop_group(12),
  l1_sentry(0,-.25),
  l1_sentry(0,.25),
  l1_swoop_group(11),
  l1_swoop_group(10),
  l1_swoop_group(9),
  l1_swoop_group(8),
  l1_sentry(0,.5),
  l1_sentry(0,0),
  l1_swoop_group(7),
  l1_swoop_group(6),
  l1_swoop_group(5),
  l1_swoop_group(4),
  l1_sentry(0,-.25),
  l1_sentry(0,.25),
  l1_swoop_group(3),
  l1_swoop_group(2),
  l1_swoop_group(1),
  l1_swoop_group(0),
  {100},
  l3_ring_heavy(20,43,.25),
  l3_ring_heavy(20,43,.5),
  l3_ring_heavy(20,43,.75),
  l3_ring_heavy(70,43, 0),
  l2_ring_sentry( 0,104,-.25,1.2,36),
  l2_ring_sentry(40,24,-.25,1.2,36),
  l2_ring_sentry( 0,84,-.25,1.2,36),
  l2_ring_sentry(40,44,-.25,1.2,36),
  l2_ring_sentry(60,64,-.25,1.2,36)
	}
end
function l3_ring_heavy(d,x,a)
 return {d,"heavy",{true,"ring",24+randi(1)*4,24+randi(1)*4,2,18,0.6,10,6,0.42,0,true,6,6},{},x,37.5,a,50,80}
end

function update_game()
 
 --processes screenshake. 
 --called even when not shaking
 draw_shake()

	-- check for focus mode 
	check_focus()
	
	p_move()
 
 update_kpos()	
 
 process_level()
 
 --only do damage when not inv
 if p_inv<=0 then
  check_khit()
 end
 update_enemys()
 
 update_patterns()
 
 check_pickups()
 
 -- update bullets and
 -- check bullet collisions
 if update_bullets() then
  handle_bhit()
 end
 	
 update_particles()
 
 --process transitions
 process_transition()
 
end

function draw_game()
 cls()
 
 draw_bg()
 draw_carpet()

 --map(0)

 draw_pickups()

 draw_player()
 
 draw_enemys()
 
 draw_bullets()

 draw_knife()
 
 -- testing
 --draw_kpoints(8)
 
 draw_particles()
 
 --draw warp effect for boss 3
 -- i have to do it here so it
 -- draws over bullets
 local e=e_list[1]
 if e and e.warp_rad then
  warp(e.x,e.y,e.warp_rad)
 end
 
 draw_ui()
 
 -- draw transition last
 draw_trans_overlay()
 
 -- stats for nerds
-- print(stat(1),10,10,10)
-- print(#b_list)
-- print(stat(0))

end



function process_level()
 l_time+=1
 while next(l) and l_time-l_time_last>=l[#l][1] do
  deli(l[#l],1)
  new_enemy(unpack(l[#l]))
  l_time_last=l_time
  deli(l,#l)
 end
 
 -- boss death
 if not next(l) and not next(e_list) then
 	p_inv=1
  if l_time-l_time_last>200 then
	  l_time_last=l_time
	 elseif l_time-l_time_last==40 then
	  music(0,0,7)
	 elseif l_time-l_time_last==120 then
	  trans_close()
	  trans_func=init_game
	  lv_select=min(cur_level+1,3)
	  max_level=mid(max_level,cur_level+1,3)
	  if cur_level==3 then
	   trans_func=init_help
	   win_screen=true
	   finish_time=time()
	  end
	 end
 end
end

function draw_ui()
 local x=1
 for i=1,p_lives do
  spr(16,x,1)
  x+=9
 end
end

-- new bg functions
function new_cloud() 
 add(bg_items, {x=rnd(148)-26,y=-32,dy=1.3,spx=0,spy=96,w=32,h=32})
 bg_timer1 = randi(10)+20
end

function new_tree()
 add(bg_items, {x=rnd(138)-7,y=-16,dy=1.1,spx=32+randi(2)*8,spy=96,w=8,h=16})
 if rnd()<.05 then
  add(bg_items, {x=rnd(138)-7,y=-16,dy=1.1,spx=32,spy=112,w=16,h=16})
 end
 bg_timer1 = randi(2)+2
end

function new_s_star()
 add(bg_items, {x=rnd(129)-1,y=-2,dy=1.4,spx=64+randi(3)*2,spy=96+randi(3)*2,w=2,h=2})
 if rnd()<.25 then
  add(bg_items, {x=rnd(130)-2,y=-4,dy=1.6,spx=64+randi(3)*4,spy=104+randi(3)*4,w=4,h=4})
 elseif rnd()<.004 then
  add(bg_items, {x=rnd(132)-4,y=-8,dy=1.8,spx=72,spy=96,w=8,h=8})
 end
 bg_timer1 = randi(1)+1
end

function init_bg(col)
 bg_items={}
 bg_col=col
end

function draw_bg()
 -- sky
 cls(bg_col)
 
 bg_timer1-=1
 if bg_timer1 <= 0 then
  if bg_col==11 then
   new_tree()
  elseif bg_col==12 then
   new_cloud()--also resets timer
  else
   new_s_star()
  end
 end
 
 for i=#bg_items,1,-1 do
  local item=bg_items[i]
  if go_timer==0 then
   item.y+=item.dy
  end
  if item.y > 128 then
   deli(bg_items,i)
  else
   sspr(item.spx,item.spy,item.w,item.h,item.x,item.y)
  end
 end
end


function draw_carpet()
 for i=0,127 do
  local offset = flr(sin((i+wave_offset)/32)*0.99)/8
  offset -= flr(sin((i+wave_offset)/69)*0.99)/8
  tline(0,i,127,i,offset,i/8)
  x = 1-abs((i*8)%2-1)
 end
 wave_offset+=wave_speed
end


-->8
--player/knife

function check_focus()
 if btn(Ž) then
		focus=true
		kspin_spd= 0.08
		kturn_spd=-0.01
		--kdmg = kdmg_f
		p_mvspd = mvspd_f
	else
		focus=false
		kspin_spd= 0.04
		kturn_spd=-0.03
		--kdmg = kdmg_n
		p_mvspd = mvspd_n
	end
end

function p_move() 
 if btn(‘) then 
  p_x+=p_mvspd
  p_flpx = false
 end
 if btn(‹) then 
  p_x-=p_mvspd
  p_flpx = true
 end
 if btn(”) then p_y-=p_mvspd end
 if btn(ƒ) then p_y+=p_mvspd end
 p_x = mid(9,p_x,119)
 p_y = mid(11,p_y,119)
 
 p_inv-=1
end

function update_kpos()
 krot += kspin_spd
 kdeg += kturn_spd
 -- updates kpos x and y
 local x = cos(kdeg)*kdist
 local y = sin(kdeg)*kdist
 kpos_x = p_x+x
 kpos_y = p_y+y
 -- also update the tip/end pos
 ktip_x=kpos_x+cos(krot+.25)*klen 
 ktip_y=kpos_y+sin(krot+.25)*klen 
 kend_x=kpos_x+cos(krot-.25)*klen*.7 
 kend_y=kpos_y+sin(krot-.25)*klen*.7
end

-- checks for knife-enemy collis
-- once per khit_delay
function check_khit()
 khit_delay-=1
 if khit_delay <= 0 then
 	
 	-- check collisions
 	for i,e in ipairs(e_list) do
	  if dst(kpos_x, kpos_y, e.x, e.y) < e.w/2+1
	  or dst(ktip_x, ktip_y, e.x, e.y) < e.w/2+1
	  or dst(kend_x, kend_y, e.x, e.y) < e.w/2 
	  then
    --e.dohit(e,kmg)
	   e.dohit(e,4) 
	   -- reset hit delay
 	  khit_delay=3
 	  --khit_delay=focus and khit_delay_f or khit_delay_n
	  end
	 end
 end
end

function handle_bhit()
 if p_inv <= 0 then
	 p_inv=p_iframes
	 p_lives-=1
	 deaths+=1
	 sfx(8)
	 if p_lives >= 0 then 
	  heart_explode(5+9*p_lives,4)
	  shake=2
	 else
	  init_gameover()
	 end
	end
end

function draw_player()
 palt(0, false)
 palt(11, true)
 
 -- outer loop is for iframes
 if p_inv <= 0 or
    p_inv < 30 and p_inv%2==0 or
    p_inv\3%2==0 then
	 if focus then 
	  spr(p_sp_f, p_x-4, p_y-5, 1,1,p_flpx)
	 else 
	  spr(p_sp_n, p_x-4, p_y-5, 1,1,p_flpx)
	 end
 end
 
 palt(0, true)
 palt(11,false)
 
 if show_hitbox then
  rect(p_x,p_y,p_x-1,p_y-1,11)
 end

end

function draw_knife()
 -- draw knife, and time it
 --local start = stat(1)
 if p_inv <= 0 or
    p_inv < 10 and p_inv%2==0 or
    p_inv\3%2==0 then
  draw_rotated(17,1,5,23,kpos_x,kpos_y,krot,0.66)
 end
 --print(stat(1)-start, 0, 0,3)
end

function heart_explode(x,y)
 for i=0,8 do
  newp_simple(x,y,40+randi(10),8,2)
 end
 for i=0,5 do
  newp_scloud(x,y,30+randi(10),8)
 end
end

--[[
 // quick and dirty way of rotating a sprite
 sx = spritesheet x-coord
 sy = spritesheet y-coord
 sw = pixel width of source sprite
 sh = pixel height of source sprite
 px = x-coord of where to draw rotated sprite on screen
 py = x-coord of where to draw rotated sprite on screen
 r = amount to rotate (radians)
 s = 1.0 for normal scale, 0.5 for half, etc
]]
function draw_rotated(sx,sy,sw,sh,px,py,r,s)
 --circ(px, py, sw*s/2, 1)
 -- loop through all the pixels
 for y=sy,sy+sh-1,1 do
  for x=sx,sx+sw-1,1 do
   -- get source pixel color
   col = sget(x,y)
   -- skip transparent pixel (zero in this case)
   if (col != 0) then
    -- rotate pixel around center
    local xx = (x-sx)-sw/2
    local yy = (y-sy)-sh/2
--    local x2 = (xx*cos(r) - yy*sin(r))*s
--    local y2 = (yy*cos(r) + xx*sin(r))*s
    -- translate rotated pixel to where we want to draw it on screen
    local x3 = flr((xx*cos(r) - yy*sin(r))*s+px)
    local y3 = flr((yy*cos(r) + xx*sin(r))*s+py)
    -- just pixel it
    pset(x3,y3,col)
   end
  end
 end
end
-->8
--enemy(s)

--[[
 all enemys have:
 x,y (x and y is centered)
 w,h
 spr
 health
 update = update function
 draw = draw function
 dohit(e,dmg) = hit function
 die = death function
]]


function draw_enemys()
 for i,e in ipairs(e_list) do
  e.draw(e)
 end
end

function update_enemys()
 --go backwards to remove safely
 for i=#e_list,1,-1 do
  
  local e=e_list[i]
  
  e.update(e)
  
  -- remove or move
  if e.hlt <= 0 then
   e.die(e)
   deli(e_list,i)
   sfx(1)   
  end
  
  --enemy removing self
  if e.done then
   deli(e_list,i)
  end
 end
end

--[[
 master enemy function
 
 swoop = arc from top of 
   screen, aimed bullets
 a1: dx (left or right)
 ƒoptionalƒ
 a2: angle around center
 a3: num bullets to shoot
 a4: health
 sp_n
 sp_h
 drops
 
 sentry = linear across screen,
    shoots aimed rings
 a1: height to cross scr at
 a2: speed
 ƒoptionalƒ
 a3: angle
 a4:num shots
 a5:health 

 heavy = come in, do pattern,
    leave
 a1: x to come in at
 a2: height to stop
 ƒoptionalƒ
 a3: angle
 a4: health
 a5: wait time before return
 
 boss1, boss2, and boss3 can
 be created here (no args)
 
 b_info has the form
 {is_pattern, name, args}
]]

function new_enemy(name,b_info,sp_info,a1,a2,a3,a4,a5,a6,a7,a8)
	if b_info==nil or next(b_info)==nil then
	 b_info = {false,"aimed"}
	end
	if name=="swoop" then
	 if a1>0 then
	  flp=false else flp=true end
	 if next(sp_info)==nil then
	  sp_info={41,57} end
	 add(e_list,
	 {
	  done = false,
	  b_info=b_info,
	  sp=0,
		 sp_n=sp_info[1], --normal spr
		 sp_h=sp_info[2], --damage spr
		 pos=0,
		 x=0,
		 y=0,
		 spd=abs(a1),
		 flp=flp,
		 angle=a2 or 0,
		 bcount=a3 or 3, -- to shoot
		 bshot = 0, 	-- already shot
		 w=8,
		 h=8,
		 hlt=a4 or 10,    -- cur health
		 max_hlt=a4 or 10,-- max health
		 draw=draw_enemy,
		 update=update_swoop,
		 dohit=dohit_enemy,
		 die=die_enemy,
		 hit_timer=0-- time til spr reset 
	 })
	elseif name=="sentry" then
	 if next(sp_info)==nil then
	  sp_info={39,55} end
	 add(e_list,
	 {
	  done = false,
	  b_info=b_info,
	  sp=0,
		 sp_n=sp_info[1], --normal spr
		 sp_h=sp_info[2], --damage spr
		 x=0,
		 y=0,
		 alt=a1, -- height to go across screen
		 pos=-8,
		 spd=a2,
		 angle=a3 or 0,
		 bcount=a4 or 3, -- to shoot
		 bshot = 0, 	-- already shot
		 w=8,
		 h=8,
		 hlt=a5 or 15,    -- cur health
		 max_hlt=a5 or 15,-- max health
		 draw=draw_enemy,
		 update=update_sentry,
		 dohit=dohit_enemy,
		 die=die_enemy,
		 hit_timer=0-- time til spr reset 
	 })
	elseif name=="heavy" then
	 if next(sp_info)==nil then
	  sp_info={9,25} end
	 if a4==-1 then a4=30 end
	 add(e_list,
	 {
	  done = false,
	  b_info=b_info,
	  sp=0,
		 sp_n=sp_info[1], --normal spr
		 sp_h=sp_info[2], --damage spr
		 x=0,
		 y=0,
		 fx=a1,
		 fy=a2,
		 cy=-8,
		 movdur=33,
		 wait1=40, --until shoot
		 wait2=a5 or 120, --until return
		 angle=a3 or 0,
		 timer=0,
		 w=8,
		 h=8,
		 hlt=a4 or 30,    -- cur health
		 max_hlt=a4 or 30,-- max health
		 draw=draw_heavy,
		 update=update_heavy,
		 dohit=dohit_enemy,
		 die=die_enemy,
		 hit_timer=0-- time til spr reset 
	 })
	elseif name=="boss1" then
	 add(e_list,
	 {
	  done = false,
	  phase=1,
		 timer=0,
		 x=randi(64)+32,
		 y=-16,
		 gx=64,
		 gy=40, --goal x/y for phase1
		 wait=17,
		 w=14,
		 hlt=380,    -- cur health
		 max_hlt=400,-- max health
		 --health of each card
		 draw=draw_b1,
		 update=update_b1,
		 dohit=dohit_enemy,
		 die=die_b1,
		 hit_timer=0-- time til spr reset 
	 })
	elseif name=="boss2" then
	 add(e_list,
	 {
	  done = false,
	  phase=0,
		 timer=0,
		 blink_timer=0,
		 x=64,
		 y=-16,
		 gx=64,
		 gy=30, --goal x/y for phase1
		 rot=.25,
		 rotspd=0.008,
		 wait=0,
		 w=16,
		 hlt=450,    -- cur health
		 max_hlt=450,-- max health

		 draw=draw_b2,
		 update=update_b2,
		 dohit=dohit_enemy,
		 die=die_b1,
		 hit_timer=0-- time til spr reset 
	 })
	elseif name=="boss3" then
	 add(e_list,
	 {
	  done = false,
	  phase=0,
		 timer=0,
		 x=64,
		 y=-16,
		 gx=64,
		 gy=64, --goal x/y for phase1
		 wait=0,
		 w=16,
		 hlt=600,    -- cur health
		 max_hlt=600,-- max health
   warp_rad=0,
		 draw=draw_b3,
		 update=update_b3,
		 dohit=dohit_enemy,
		 die=die_b1,
		 hit_timer=0-- time til spr reset 
	 })
	end
end

function update_b3(e)
 e.timer+=1
 e.wait-=1
 
 --phase 1
 if e.hlt < 300 and e.phase==1 then
  e.phase=3
  e.gx=64
  e.gy=40
 end
 if e.hlt < 1 then
  e.hlt=1000 -- cheat death to explode
  e.phase=4
  pt_list={}
  e.wait=60
  music(-1,1200)
 end
 
 if e.phase==0 then
  e.x += (e.gx-e.x)*0.1
  e.y += (e.gy-e.y)*0.1
  if dst(e.x,e.y,e.gx,e.gy)<2 then
   e.phase+=1
   e.wait=-50
   e.gx=64
   e.gy=64
  end
 
 elseif e.phase==1 then
  if e.wait==-80 then
   sfx(3)
  elseif e.wait<-90 and e.wait>-120 then
   new_bullet(e.x,e.y,"simple",rnd(4)-2,rnd(4)-2,200,104+rnd(16),rnd(24),4)
   sfx(53)
  elseif e.wait < -130 then
   e.wait=-30-randi(20)
  end
  
 --phase 3
 elseif e.phase==3 then
  e.x += (e.gx-e.x)*0.1
  e.y += (e.gy-e.y)*0.1
  if dst(e.x,e.y,e.gx,e.gy)<2 and e.wait<-50 then
   e.wait=28
  end
  if e.wait>=-28 then
   e.warp_rad=28-abs(e.wait)
  end
  if e.wait>0 then
	  for i,b in pairs(b_list) do
	   if dst(b.x,b.y,e.x,e.y)<e.warp_rad then
	    b.dx=0 b.dy=0
	   end
	  end
	 end
	 if e.wait==0 then
	  for i=#b_list,1,-1 do
	   local b=b_list[i]
	   if dst(b.x,b.y,e.x,e.y)<e.warp_rad then
	    new_bullet(b.x,b.y,"aimed",2.5,200,b.sx,b.sy,b.rad)
	    b.dx,b.dy=dir(0,0,rnd(2)-1,rnd(2)-1)
	   end
	  end
	 end
	 if e.wait==-50 then
	  e.gx=randi(100)+14
	  e.gy=randi(100)+14
	 end
	 if e.timer%25==0 then
	  new_pattern(0,0,"rand_line")
	 end
 
 elseif e.phase==4 then
 	p_inv=1
  e.warp_rad=abs((e.wait+3)%20-10)*2
  if e.wait<=0 then
   e.hlt=0 --die
  elseif e.wait%20==0 then
   heart_explode(e.x,e.y)
		 sfx(48)
		end
 end
end

function draw_b3(e)
 --warp(e.x,e.y,e.warp_rad)
 for i=0,14 do
  for j=0,14 do
   if abs((i-7)*(j-7))<4+e.hlt/e.max_hlt*3 then
	   if e.hit_timer>0 and rnd()<.6 then
	    pset(e.x-7+i,e.y-7+j,8)
	   else
	    pset(e.x-7+i,e.y-7+j,randi(15))
	   end
	  end
  end
 end
 e.hit_timer-=1
end

function warp(x,y,rad)
 for i=x-rad,x+rad,1.5 do
 for j=y-rad,y+rad do
  if dst(i,j,x,y) < rad then
   pset(i,j,pget(i,j)+4+rad/4)
  end
 end
 end
end

function update_b2(e)
 e.timer+=1
 e.wait-=1
 
 --phase 1
 if e.hlt < 250 and e.phase==1 then
  e.phase=2
  e.gx=64
  e.gy=40
 end
 if e.hlt < 1 then
  e.hlt=1000 -- cheat death to explode
  e.phase=4
  pt_list={}
  e.wait=60
  music(-1,1200)
 end
 
 if e.phase==0 or e.phase==2 then
  e.x += (e.gx-e.x)*0.1
  e.y += (e.gy-e.y)*0.1
  if dst(e.x,e.y,e.gx,e.gy)<2 then
   e.phase+=1
   e.wait=0
  end
 
 elseif e.phase==1 then
  if e.wait>0 then
   e.x=cos(e.rot)*36+64
   e.y=sin(e.rot)*36+64
   e.rot+=e.rotspd
   if e.wait%25==0 then
    new_pattern(e.x,e.y,"exp_line",40,16,4,8,true,1.4)
   end
  elseif e.wait==-15 then
   sfx(3)
  elseif e.wait==-45 then
   new_pattern(e.x,e.y,"spi",40,16,4,5,12,4,1.5,1/28)
   sfx(54)
  elseif e.wait < -145 then
   e.wait=140+randi(9)
   e.rotspd= rnd()<.5 and -.008 or .008
  end
  
 --phase 3
 elseif e.phase==3 then
  if e.wait==-26 then
   sfx(3)
  elseif e.wait==-50 then
   new_pattern(e.x,e.y,"spi",32,22,1,33,6,6,1.05,0.01042,0)
   new_pattern(e.x,e.y,"spi",38,20,1,33,6,6,1.05,-0.01042,0)
   new_pattern(e.x,e.y,"ring",48,16,2,24,1,0,0,0,0)
   sfx(62)
  elseif e.wait==-146
      or e.wait==-242 then
   new_pattern(e.x,e.y,"ring",48,16,2,24,1,0,0,0,0)
  elseif e.wait==-270 then
   e.wait=40
  end
 
 elseif e.phase==4 then
  p_inv=1
  if e.wait<=0 then
   e.hlt=0 --die
  elseif e.wait%20==0 then
   heart_explode(e.x,e.y)
		 sfx(48)
		end
 end
end

function draw_b2(e)
 palt(0,false) palt(11,true)
 if e.hit_timer > 0 then
  e.hit_timer-=1
  pal(8,14) pal(12,14)
 end
 e.blink_timer-=4
 if e.blink_timer < -80 and rnd()<0.07 then
  e.blink_timer=20
 end
 
 spr(104 + min(abs(e.blink_timer)\2, 6),e.x-8,e.y-8,2,2)
 --line(e.x-e.w/2-1,e.y-10,e.x-e.w/2-1+e.w*(e.hlt/e.max_hlt),e.y-10,11)
 pal()
end

function update_b1(e)
 e.timer+=1
 e.wait-=1
-- if dst(p_x,p_y,e.x,e.y)<6 then
--  handle_bhit()
-- end
 
 --phase 1
 if e.hlt < 260 and e.phase==1 then
  e.phase=2
  e.gx=64
  e.gy=40
 end
 if e.hlt < 1 then
  e.hlt=1000 -- cheat death to explode
  e.phase=4
  pt_list={}
  e.wait=60
  music(-1,1200)
 end
 
 if e.phase==1 and dst(e.x,e.y,e.gx,e.gy)<3 then
  e.gx=randi(64)+32
  e.gy=randi(64)+32
  e.wait=80
 end
 if e.phase<=2 then
 	if e.wait==16 then
 		sfx(3)
  elseif e.wait<=0 then
   local xx,yy=dir(e.x,e.y,e.gx,e.gy)
   e.x+=xx*0.9
   e.y+=yy*0.9
   if e.wait%8==0 and e.phase==1 then
    new_pattern(e.x,e.y,"ring",35,20,1,12,1.1,2,5,0.1,0)
    sfx(61)
   end
  end
 end
 --phase 2
 if e.phase==2 and dst(e.x,e.y,e.gx,e.gy)<3 then
  e.phase=3
  e.wait=40
  
 --phase 3
 elseif e.phase==3 then
  if e.wait==24 then
   sfx(3)
  elseif e.wait==0 then
   new_pattern(e.x,e.y,"spi",48,16,2,10,6,6,1.4, 0.018,0)
   sfx(62)
  elseif e.wait==-60 then
   new_pattern(e.x,e.y,"spi",52,16,2,15,6,4,1.4,-0.012,.18)
   e.wait=randi(1)*80+60
  end
 
 elseif e.phase==4 then
  p_inv=1
  if e.wait<=0 then
   e.hlt=0 --die
  elseif e.wait%20==0 then
   heart_explode(e.x,e.y)
		 sfx(48)
		end
 end
end

function draw_b1(e)
 if e.hit_timer > 0 then
  e.hit_timer-=1
  pal(9,10) pal(10,9)
 end
 
 spr(72+flr(e.timer/4)%4*2,e.x-8,e.y-10,2,2)
 --circ(e.x,e.y,e.w/2,7)
 --line(e.x-e.w/2-1,e.y-10,e.x-e.w/2-1+e.w*(e.hlt/e.max_hlt),e.y-10,11)
 
 pal() -- reset
end

function die_b1(e)
 kills+=1
 sfx(49)
 heart_explode(e.x,e.y)
 heart_explode(e.x,e.y)
 new_pickup("heart",e.x,e.y,120)
end

function update_swoop(e)
 -- reset sprite after hit
 e.hit_timer-=1
 if e.hit_timer <= 0 then
  e.sp=e.sp_n
 end
 
 e.pos += e.spd
 e.x,e.y = 
  get_swoop_pos(e.pos,e.angle,e.flp)

 if (e.pos-32)/64-1/e.bcount/2 >= e.bshot/e.bcount 
 and e.bshot < e.bcount then
  if e.b_info[1] == true then   
   new_pattern(e.x,e.y,unpack(e.b_info,2))
  else
   new_bullet(e.x,e.y,unpack(e.b_info,2))
  end
  e.bshot+=1
  sfx(5)
 end
 
 if e.pos >= 128 then
  e.done=true
 end
end

function get_swoop_pos(pos,a,flp)
 local temp = (pos-64)/8
 local y = -temp*temp+40
 if flp then pos = -(pos-64)+64 end
 return rotated(pos,y,a)
end

function update_sentry(e)
 -- reset sprite after hit
 e.hit_timer-=1
 if e.hit_timer <= 0 then
  e.sp=e.sp_n
 end
 
 e.pos += e.spd
 e.x,e.y = 
  rotated(e.pos,e.alt,e.angle)
 
 if (e.pos-16)/96-1/e.bcount/2 >= e.bshot/e.bcount 
 and e.bshot < e.bcount then
  if e.b_info[1] == true then   
   new_pattern(e.x,e.y,unpack(e.b_info,2))
  else
   new_bullet(e.x,e.y,unpack(e.b_info,2))
  end
  e.bshot+=1
  sfx(5)
 end
 
 if e.pos > 136 then
  e.done=true
 end
end

function update_heavy(e)
 -- reset sprite after hit
 e.hit_timer-=1
 if e.hit_timer <= 0 then
  e.sp=e.sp_n
 end
 
 e.timer += 1
 
 if e.timer < e.movdur then
  e.cy += (e.movdur-e.timer)*((e.fy+18)/(e.movdur*(e.movdur+1)/2))
 elseif e.timer > e.movdur+e.wait1+e.wait2 then
  e.cy -= (e.timer-e.movdur-e.wait1-e.wait2)*((e.fy+18)/(e.movdur*(e.movdur+1)/2))
 end
 
 e.x,e.y = 
  rotated(e.fx,e.cy,e.angle)
 
 -- charging sound
 if e.timer == e.movdur+e.wait1-30 then
  sfx(3)
 end
 
 -- shoot
 if e.timer == e.movdur+e.wait1 then
  sfx(5)
  if e.b_info[1] == true then   
   new_pattern(e.x,e.y,unpack(e.b_info,2))
  else
   new_bullet(e.x,e.y,unpack(e.b_info,2))
  end
  e.hasshot=true
 end
 
 if e.cy < -8 then
  e.done=true
 end
end

function draw_heavy(e)
 local sp_o = 0
 if e.timer>=e.movdur+e.wait1 then
  sp_o=1
 end
 palt(1,true)
 spr(e.sp+sp_o, e.x-e.w/2, e.y-e.h/2, e.w/8, e.h/8, e.flpx, e.flpy)
 pal()
 --line(e.x-e.w/2-1,e.y-e.h/2-2,e.x-e.w/2-1+e.w*(e.hlt/e.max_hlt),e.y-e.h/2-2,11)
end

-- generic draw func
function draw_enemy(e)
 palt(1,true)
 spr(e.sp+l_time/16%2, e.x-e.w/2, e.y-e.h/2, e.w/8, e.h/8, e.flpx, e.flpy)
 pal()
 --line(e.x-e.w/2-1,e.y-e.h/2-2,e.x-e.w/2-1+e.w*(e.hlt/e.max_hlt),e.y-e.h/2-2,11)
end

-- generic hit func
function dohit_enemy(e,dmg)
 e.hlt-=dmg
 e.sp = e.sp_h -- set dmg sprite
 e.hit_timer = 5 -- frames til spr reset
 
 -- particles
 newp_simple(e.x,e.y)
 
 -- play sound if open channel
 if stat(19)==-1 then
  sfx(0,3,0,1)
 end
end

-- generic death func
function die_enemy(e)
 kills+=1
 -- particles
 if rnd()<.4 then
  new_pickup("heart",e.x,e.y)
 end
 for i=0,5 do
  newp_scloud(e.x,e.y)
  newp_simple(e.x,e.y)
 end
end


-->8
--particles

-- pa = particle

--[[
 all particles have:
 move = movement function
 draw = draw function
 life = frames til deletion
 
 paricle types
 simple: single pixel
 scloud: 3x3 dust cloud
]]

function update_particles()
 --go backwards to remove safely
 for i=#pa_list,1,-1 do
  
  local pa=pa_list[i]
  pa.life-=1
  
  pa_move(pa)
  
  -- remove or move
  if pa.life <= 0 then
   deli(pa_list,i)
  end
 end
end

function draw_particles()
 for i,pa in ipairs(pa_list) do
  pa.draw(pa)
 end
end

function newp_simple(x,y,life,c1,c2)
 add(pa_list,
  {
  x=x,y=y,
  c1=c1 or 6,
  c2=c2 or 13,
  life=life or 20+randi(5),
  name="simple",
  draw=pdraw_simple,
  dx=(rnd(2)-1)*0.8,
  dy=(rnd(2)-1)*0.8
  })
end

function newp_scloud(x,y,life,s_offset)
 if s_offset==nil then s_offset=0 end
 add(pa_list,
 {
 x=x,y=y,
 life=life or 20+randi(20),
 name="scloud",
 draw=pdraw_scloud,
 dx=(rnd(2)-1)*1.5,
 dy=(rnd(2)-1)*1.5,
 sx=32+randi(1)*4,
 sy=s_offset+randi(1)*4
 })
end

function pa_move(pa)
 pa.x+=pa.dx
 pa.y+=pa.dy
 pa.dx*=0.90
 pa.dy*=0.90
 if pa.sx and (pa.life==20 or pa.life==10) then 
  pa.sx += 8
 end
end

function pdraw_simple(pa)
  pset(pa.x,pa.y,pa.life>10 and pa.c1 or pa.c2)
end

function pdraw_scloud(pa)
 sspr(pa.sx,pa.sy,3,3,pa.x,pa.y)
end
-->8
--bullets

--[[
 all bullets have:
 move = movement function
 draw = draw function
 life = frames til deletion
 hitcheck = collsion func
 
 bullet types
 simple: linear, no acc
 aimed:  linear, no acc, goto p
0]]

-- returns bool hit_player
function update_bullets()
 local hit_player = false
 --go backwards to remove safely
 for i=#b_list,1,-1 do
  
  local b=b_list[i]
  b.life-=1
  
  -- remove or move
  if b.life <= 0 then
   deli(b_list,i)
   bullet_count+=1
  else
   b.move(b)
  end
  
  -- collision with player
  if b.hitcheck(b) then
   hit_player=true
  end
 end
 return hit_player
end

function draw_bullets()
 for i,b in ipairs(b_list) do
  bdraw_simple(b)
 end
end

function new_bullet(x,y,name,a1,a2,a3,a4,a5,a6,a7)
 if name=="simple" then
  add(b_list,
	 {
	  x=x,y=y,
	  dx=a1 or 0,dy=a2 or 0,
	  life=a3 or 200,
	  sx=a4 or 38,
	  sy=a5 or 18,
	  rad=a6 or 1,
	  move=bmove_simple,
	  hitcheck=bhit_simple
	 })
 elseif name=="aimed" then
	 if a1==nil then a1=1 end
	 local dx,dy = dir(x,y,p_x,p_y)
	 dx*=a1 dy*=a1
	 add(b_list,
	 {
	  x=x,y=y,
	  dx=dx,dy=dy,
	  life=a2 or 200,
	  sx=a3 or 38,
	  sy=a4 or 18,
	  rad=a5 or 1,
	  move=bmove_simple,
	  hitcheck=bhit_simple
	 })
 elseif name=="staging" then
  add(b_list,
	 {
	  x=x,y=y,
	  fx=a1,fy=a2,
	  dur=a3, -- frames til arrival
	  life=a4,
	  sx=a5 or 38,
	  sy=a6 or 18,
	  rad=a7 or 1,
	  move=bmove_staging,
	  hitcheck=bhit_simple
	 })
 end
end

-- basic linear bullet mov func
function bmove_simple(b)
 b.x += b.dx
 b.y += b.dy
 -- kill offscreen
 if abs(b.x-64) > 76
 or abs(b.x-64) > 76 then
  b.life = 0
 end
end

-- basic bullet draw func
function bdraw_simple(b)
 sspr(b.sx,b.sy,b.rad*2,b.rad*2,b.x-b.rad,b.y-b.rad)
end

function bhit_simple(b)
 return dst(b.x,b.y,p_x,p_y) < b.rad+p_hitrad
end

-- basic linear bullet mov func
function bmove_staging(b)
 if b.dur > 0 then
	 b.x += (b.fx-b.x)/b.dur
	 b.y += (b.fy-b.y)/b.dur
	 b.dur-=1
	end
end
-->8
--patterns

--pt=pattern

--[[
 patterns spawn bullets.
 it exists until it marks
 itself as done.
 
 all patterns have:
 done = is pattern finished
 process = update function
 
 pattern types:
 spi = outward spiral
]]

function update_patterns()
 for i=#pt_list,1,-1 do
  
  local pt=pt_list[i]
  
  pt.process(pt)
  
  -- remove
  if pt.done == true then
   deli(pt_list,i)

  end
 end
end

--[[ pattern master list

 spi = spiral
 sx,sy,rad = bullet sprite
 a1: duration (in shots)
 ƒoptionalƒ
 a2: num spokes
 a3: fire delay
 a4: bullet speed
 a5: rot speed
 a6: starting angle
 (todo) a8: rot acc func
 new_pattern("spi",38,18,1,e.x,e.y,60,6,5,1,0.0171,nil)
 
 ring = ring expanding out
 sx,sy,rad = bullet sprite
 ƒoptionalƒ
 a1: bullets in ring
 a2: bullet speed
 a3: time to wait before explode
 a4: wait ring radius
 a5: "spin factor"
 a6: starting angle
 a7: staging (bool)
 a8: staging dur
 a9: staging spd
 new_pattern(e.x,e.y,"ring",32,22,1,28,1,6,8,0.4,nil,true,20,8)
 
 line = long bullet
 sx,sy,rad = bullet sprite
 a1: length
 a2: aimed (bool)
 a3: dx (n) or spd (aimed)
 a4: dy (n)
 new_pattern(40,16,"line",4,e.x,e.y,6,false,1,2)
 
 exp_line = expanding line
 sx,sy,rad = bullet sprite
 a1: length
 a2: aimed (bool)
 a3: dx (n) or start spd (aimed)
 a4: dy (n)
 --------new_pattern("exp_line",40,16,4,e.x,e.y,6,false,1,2)
 
]]

function new_pattern(x,y,name,sx,sy,rad,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11)
 if name=="spi" then
  add(pt_list,
  {
   done=false,
   process=pt_spiral,
   sx=sx, sy=sy, rad=rad,
   x=x+.5,
   y=y+.5,
   dur=a1,
   spokes=a2 or 6,
   delay=a3 or 5,
   timer=0,
   bspd=a4 or 1,
   rotspd=a5 or 0.0171,
   rot=a6 or 0
  })
 elseif name == "ring" then
  local processf
  local delaytime
  if a7 == true then
   processf=pt_ring_staged
   delaytime=a8+a9+a3
  else
   processf=pt_ring
   delaytime=a3
  end
  add(pt_list,
  {
   done=false,
   process=processf,
   sx=sx, sy=sy, rad=rad,
   x=x+.5,
   y=y+.5,
   bcount=a1 or 16,
   bspd=a2 or 1,
   delay=delaytime,
   timer=delaytime,
   ring_rad=a4 or 16,
   rot=a6 or rnd(),
   angle=a5 or 0,
   stg_dur=a8 or nil,
   stg_spd=a9 or nil,
   stg_prog=0
  })
 elseif name=="rand_line" then
  add(pt_list,
  {
   done=false,
   process=pt_rand_line,
  })
 elseif name=="exp_line" then
  local dx,dy
  if a2 == true then
   dx,dy = dir(x,y,p_x,p_y)
   dx*=a3
   dy*=a3
  else
   dx=a3
   dy=a4
  end
  sfx(54)
  add(pt_list,
  {
   done=false,
   process=pt_exp_line,
   sx=sx, sy=sy, rad=rad,
   x=x,
   y=y,
   len=a1,
   dx=dx,
   dy=dy,
  })
 end
end

function pt_spiral(pt)
 pt.timer-=1
 
 -- shoot
 if pt.timer <= 0 then
  for i=1,pt.spokes do
   local a = i/pt.spokes+pt.rot
   local dx = cos(a)*pt.bspd
   local dy = sin(a)*pt.bspd
   new_bullet(pt.x,pt.y,"simple",dx,dy,200,pt.sx,pt.sy,pt.rad)
  end
  pt.timer = pt.delay
  pt.dur-=1
  pt.rot+=pt.rotspd
 end
 
 -- finished?
 if pt.dur <= 0 then
  pt.done = true
 end
end

function pt_ring(pt)
 -- make stationary bullets
 if pt.timer == pt.delay then
  for i=1,pt.bcount do
   local a = i/pt.bcount+pt.rot
   local ox=cos(a)*pt.ring_rad
   local oy=sin(a)*pt.ring_rad
   new_bullet(pt.x+ox,pt.y+oy,"simple",0,0,pt.delay,pt.sx,pt.sy,pt.rad)
  end
 end
 pt.new = false
 
 pt.timer-=1
 
 -- shoot (makes new bullets)
 if pt.timer <= 0 then
  for i=1,pt.bcount do
   local a = i/pt.bcount+pt.rot
   local ox=cos(a)*pt.ring_rad
   local oy=sin(a)*pt.ring_rad
   local dx = cos(a+pt.angle)*pt.bspd
   local dy = sin(a+pt.angle)*pt.bspd
   new_bullet(pt.x+ox,pt.y+oy,"simple",dx,dy,200,pt.sx,pt.sy,pt.rad)
  end
  pt.done = true
 end
end

function pt_ring_staged(pt)
 -- make staging bullets
 while (pt.delay-pt.timer)/pt.stg_dur > pt.stg_prog/pt.bcount
   and (pt.delay-pt.timer) <= pt.stg_dur do
  pt.stg_prog += 1
  local a = pt.stg_prog/pt.bcount+pt.rot
  local ox=cos(a)*pt.ring_rad
  local oy=sin(a)*pt.ring_rad
  new_bullet(pt.x,pt.y,"staging",pt.x+ox,pt.y+oy,pt.stg_spd,pt.timer,pt.sx,pt.sy,pt.rad)
 end
 pt.new = false
 
 pt.timer-=1
 
 -- shoot (makes new bullets)
 if pt.timer <= 0 then
  for i=1,pt.bcount do
   local a = i/pt.bcount+pt.rot
   local ox=cos(a)*pt.ring_rad
   local oy=sin(a)*pt.ring_rad
   local dx = cos(a+pt.angle)*pt.bspd
   local dy = sin(a+pt.angle)*pt.bspd
   new_bullet(pt.x+ox,pt.y+oy,"simple",dx,dy,200,pt.sx,pt.sy,pt.rad)
  end
  sfx(5)
  pt.done = true
 end
end

function pt_rand_line(pt)
 local a,x1,y1,x2,y2,cnt,spd=randi(3)/4,rnd(128),-rnd(10),rnd(128),-rnd(10),randi(6)+3,rnd(.5)+.8
 x1,y1=rotated(x1,y1,a)
 x2,y2=rotated(x2,y2,a)
 local sp_inf
 if rnd()<.65 then
  sp_inf={32+randi(3)*2,18+randi(2)*2,1}
 else
  sp_inf={48+randi(1)*4,16+randi(1)*4,2}
 end
 for i=0,cnt do
  new_bullet(
   x1+(x2-x1)*(i/cnt),
   y1+(y2-y1)*(i/cnt),
   "simple",-sin(a)*spd,cos(a)*spd,200,unpack(sp_inf))
 end
 pt.done=true
end

function pt_exp_line(pt)
 
 while pt.len > 0 do
  new_bullet(pt.x,pt.y,"simple",pt.dx,pt.dy,200,pt.sx,pt.sy,pt.rad)
  pt.dx*=1.1 pt.dy*=1.1
  pt.len-=1
 end 
 
 pt.done=true
end
-->8
--pickups

--[[
 all pickups have
 
 name: pickup type
 life: time til removal
 spr: sprite
 
]]

function new_pickup(name,x,y,life)
 add(pu_list, {
  name=name,
  sp=16,
  x=x,
  y=y,
  life=life or 110
 })
end

-- picks up pickups
function check_pickups()
 for i=#pu_list,1,-1 do
  local pu = pu_list[i]
  if dst(p_x,p_y,pu.x,pu.y) < 6 then
   if pu.name == "heart" then
    p_lives += 1
    sfx(4)
   end
   deli(pu_list,i)
  end
 end
end

function draw_pickups()
 for i=#pu_list,1,-1 do
  if pu_list[i].life <= 0 then
   deli(pu_list,i)
  else
   draw_pu(pu_list[i])
  end
 end
end

function draw_pu(pu)
 pu.life-=1
 if pu.life > 30 and pu.life\2%2==0
 or pu.life%2==0 then
  spr(pu.sp,pu.x-4,pu.y-4)
 end
end
__gfx__
00000000bbb2bbbb33333330333333307070707060606060d000d000177777111777771111dddd1111dddd111131111111131111888888882222222233333333
00000000bb282bbb300060303000203007007770000000000d00000077777771767776711dddddd11dddddd111b33111111b3111888888882222222233333333
000000002288822b3006603030022030707007006000060000000d007677767170676071dddddddddd5555dd111bb1b3111bb111888888882222222233333333
00000000bbd0f0bb30066030300220300000000000000000000000007067607170070071ddddddddd589985d13b22b3113b22bb3888888882222222233333333
00000000bbd666bb306660303022203007007770060060600d0000d07007007177777771d5dddd5dd889988d13b22b313bb22b31888888882222222233333333
00000000bf2662fb306d6030302820307770707000600060000000001777771116161611dd5555dddd8888dd3b1bb111111bb111888888882222222233333333
00000000bb2628bb30dd6030308820307000070060000600d0000d0016161611111111111dddddd11dddddd111133b111113b111888888882222222233333333
00000000b22288bb30dd603030882030000000000000000000000000111111111111111111dddd1111dddd111111131111113111888888882222222233333333
02200220bbb2bbbb30dd6030308820308080808080208080200020001eeeee111eeeee1111666611116666111311111113111111555555556666666677777777
28822882bb282bbb30dd603030882030080088800000000002000000eeeeeee1eeeeeee1166666611666666111b3111311b31113555555556666666677777777
28888e822288822b30dd603030882030808008008000020000000200eeeeeee1e1eee1e16666666666dddd66111bb1b1111bb1b1555555556666666677777777
2888ee82bb69f9bb30dd603030882030000000000000000000000000e1eee1e1e11e11e1666666666de99ed611b88b3111b88b31555555556666666677777777
0288e820bf6777fb30dd603030882030080088800200808002000020e11e11e1eeeeeee16d6666d66ee99ee613b88b1113b88b11555555556666666677777777
00288200bb2772bb30dd6030308820308880808000800080000000001eeeee111e1e1e1166dddd6666eeee661b1bb1111b1bb111555555556666666677777777
00022000bb2728bb30dd6030308820308000080080000200200002001e1e1e1111111111166666611666666131113b1131113b11555555556666666677777777
00000000b22288bb30dd603030882030000000000000000000000000111111111111111111666611116666111111113111111131555555556666666677777777
00000000bbbbbbbb30dd60303088203000112233003333000880099011888811118888111111191111119111110000111100001199999999aaaaaaaabbbbbbbb
00000000bbbbbbbb30dd6030308820300011223303cccc3089989aa91888888118888881111991111199111110b7bb0110b7bb0199999999aaaaaaaabbbbbbbb
00000000bbbbbbbb3aaaa9303aaaa93066ee66773cc00cc389989aa98828828888288288119a991119a991110bb7b3b00bb7b3b099999999aaaaaaaabbbbbbbb
00000000bbbbbbbb3aaaa9303aaaa93066ee66773c0000c308800990882882888828828819aaa91119aa99110b3b7bb00bb7b3b099999999aaaaaaaabbbbbbbb
00000000bbbbbbbb30aa903030aa90308899aabb3c0000c30cc00bb0888888888888888819a8a89119a8a8910b3b7bb00b3b7bb099999999aaaaaaaabbbbbbbb
00000000bbbbbbbb30aa903030aa90308899aabb3cc00cc3c00cbccb888888888888888819aaaa9119aaaa910bbb7bb00bbb7bb099999999aaaaaaaabbbbbbbb
00000000bbbbbbbb30aa903030aa9030ccaaeeff03cccc30c00cbccb881881888881188819aaa911119aa991100770011007700199999999aaaaaaaabbbbbbbb
00000000bbbbbbbb30aa903030aa9030ccaaeeff003333000cc00bb081111118181111811199911111199911110000111100001199999999aaaaaaaabbbbbbbb
00000000000000000000000008800cc0a0a0a0a0a090a0a090009000118888111188881111111a111111a1111122221111222211ddddddddeeeeeeeecccccccc
0000000000000000000000008dd8cddc0a00aaa000000000090000001888888118888881111aa11111aa1111128e8821128e8821ddddddddeeeeeeeecccccccc
0000000000000000000000008dd8cddca0a00a00a000090000000900822882288228822811a9aa111a9aa111288e8982288e8982ddddddddeeeeeeeecccccccc
00000000000000000000000008800cc000000000000000000000000082288228822882281a999a111a99aa112898e882288e8982ddddddddeeeeeeeecccccccc
0000000000000000000000000aa00bb00a00aaa00900a0a00900009088888888888888881a9292a11a9292a12898e8822898e882ddddddddeeeeeeeecccccccc
000000000000000000000000addabddbaaa0a0a000a000a00000000088888888888888881a9999a11a9999a12888e8822888e882ddddddddeeeeeeeecccccccc
000000000000000000000000addabddba0000a00a00009009000090088188188888118881a999a1111a99aa1122ee221122ee221ddddddddeeeeeeeecccccccc
0000000000000000000000000aa00bb0000000000000000000000000811111181811118111aaa111111aaa111122221111222211ddddddddeeeeeeeecccccccc
111111111111111111111111111111110000000000000000000000000009a0000000000000090000000000009900000000000009000000000000000000000000
111111111111111111111111111111110000000000000000000000000009a0000000000000990000000000009900000000000099000000000000000000000000
11c11111ccc1111cc1111ccc11111c110000000000000000000000000009a0000000000000990000000000000990000000000090000000000000000000900000
111ccc1c111c1cc11cc1c111c1ccc111000000200000000002000000009aaa000000000099990000000000009990000000000099000000000000000099990000
111c11c11c11c111111c11c11c11c1110000022200000000222000000006d000000009999a900000000000099a9900000000099990000000000009999a990000
111c111c11c1111111111c11c111c1110000222222222222222200000006d000000999aaaa90000000000009aaa90000000009aa999900000009999aaaa99000
1111c11c1c111111111111c1c11c11110002222222222222222220000006d0000009aaaaaa99000000000999aaa99000000099aaaaa990000099aaaaaaaa9900
111c1cc1c11111111111111c1cc1c1110000222111111111122200000006d0000099aaaaaaa99000000999aaaaaa990000099aaaaaaa9900009aa8aaa8aaa990
11c1111c11111111c111c111c1111c110000022111111111122000000006d000009aa8aaa8aa99000099a8aaa8aaa9000099a8aaa8aaa900009aa8aaa8aaa900
11c1c1c111111111c111c1111c1c1c110000022111111111122000000006d000099aa8aaa8aaa900099aa8aaa8aaa900099aa8aaa8aaa900099aa8aaa8aaa900
11c11c1111cccc111c1c1c1111c11c110000022111111111122000000006d00009aaa8aaa8aaa99009aaa8aaa8aaa99009aaa8aaa8aaa99009aaaaaaaaaaa990
111c1111cc1111cc11c11c111111c1110000022111111111122000000006d00009aaaaaaaaaaaa9009aaaaaaaaaaaa9009aaaaaaaaaaaa9009aaaaaaaaaaaa90
1111c11111c11c1111c11c11111c11110000022111111111122000000006d00009aaaaaaaaaaaa9009aaaaaaaaaaaa9009aaaaaaaaaaaa9009aaaaaaaaaaaa90
111c1111111cc1111c1c1c111111c1110000022111111111122000000006000009aaaaaaaaaaaa9009aaaaaaaaaaaa9009aaaaaaaaaaaa9009aaaaaaaaaaaa90
111c111111c11c11c111c1111111c11100000221111111111220000000000000099aaaaaaaaaa990099aaaaaaaaaa990099aaaaaaaaaa990099aaaaaaaaaa990
11c11111cc1111ccc111c11111111c11000002211111111112200000000000000099999999999900009999999999990000999999999999000099999999999900
11c11111111c111ccc1111cc11111c1100002221111111111222000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
111c1111111c111c11c11c111111c11100022222222222222222200000555500bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
111c111111c1c1c1111cc1111111c11100002222222222222222000005555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb888888bbbbb
1111c11111c11c1111c11c11111c111100000222000000002220000005555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8878777888bbb
111c111111c11c11cc1111cc1111c11100000020000000000200000005555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88888888bbbbbb887877777778bb
11c11c1111c1c1c111cccc1111c11c1100000000000000000000000005555550bbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbb8877cccc7788bbb87877cccc77778b
11c1c1c1111c111c111111111c1c1c110000000000000000000000000d5555d0bbbbbbbbbbbbbbbbbb88888cc88888bbb8778cccccc7778b87777cccccc78778
11c1111c111c111c11111111c1111c1100000000000000000000000000dddd00888888888888888888877cc00cc7778887877cc00cc7877887777cc00cc77878
111c1cc1c11111111111111c1cc1c11100000000000000000000000000000000888888888888888888787cc00cc7878887778cc00cc7787887778cc00cc77788
1111c11c1c111111111111c1c11c111100000000000000000000000000000000bbbbbbbbbbbbbbbbbb88888cc88888bbb8787cccccc7878b87787cccccc77878
111c111c11c1111111111c11c111c11100000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbb88bbbbbbbbb8877cccc7788bbb88777cccc77778b
111c11c11c11c111111c11c11c11c11100000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88888888bbbbbb877778778778bb
111ccc1c111c1cc11cc1c111c1ccc11100000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8878777888bbb
11c11111ccc1111cc1111ccc11111c1100000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb888888bbbbb
1111111111111111111111111111111100000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
1111111111111111111111111111111100000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00aaaa00aaaaaa00aaaaaaaa00aaaa00aaaaaa00aaaaaaaaaa0000aa00aaaaaa0000000000000000999099909999999999999999999999999900000000000099
00aaaa00aaaaaaa0aaaaaaaa0aaaaaa0aaaaaaa0aaaaaaaaaa0000aa0aaaaaaa000000aa0000000090000000000999999999999999999999906666666666dd09
0aaaaaa0aa999aaa999aa999aaa99aaaaa999aaa999aa999aa0000aaaaa999990a0000aa6666666608888888888099999999999999999999906363633636ddd0
0aa99aa0aa0009aa000aa000aa9009aaaa0009aa000aa000aa0000aaaa900000aaaaaaaadddddddd08800888008099999999999999999999906366663666ddd0
0aa00aa0aa0000aa000aa000aa0000aaaa0000aa000aa000aa0000aaaa000000aaaaaaaadddddddd088008880080999999999999999999999907777777777dd0
aaa00aaaaa000aaa000aa000aa0000aaaa000aaa000aa000aa0000aaaaa000009a9999aadddddddd088888888880999999999999999999999906666666666dd0
aa9009aaaaaaaaa9000aa000aa0000aaaaaaaaa9000aa000aa0000aa9aaaaa00090000aa00000000900000000009999999999999999999999906222222226dd0
aa0000aaaaaaaa90000aa000aa0000aaaaaaaa90000aa000aa0000aa09aaaaa00000009900000000999088880999999999999999999999999906222222226dd0
aa0000aaaaaaa900000aa000aa0000aaaaaaa900000aa000aa0000aa00999aaa0000000000000000990888888099999999999999999999999906222222226dd0
aaaaaaaaaa9aaa00000aa000aa0000aaaa9aaa00000aa000aa0000aa000009aa0000000000000000990888888099999999999999999999999906222222226dd0
aaaaaaaaaa09aa00000aa000aa0000aaaa09aa00000aa000aa0000aa000000aa0000000066666666990888888099999909999999999999909906666666666dd0
aa9999aaaa00aaa0000aa000aa0000aaaa00aaa0000aa000aa0000aa000000aa00000000ddddd660990888888099999999999999999999999907bb77777b7dd0
aa0000aaaa009aa0000aa000aaa00aaaaa009aa0000aa000aaa00aaa00000aaa00000000dd666000990888888099999990999999999999099077bb777b77ddd0
aa0000aaaa000aaa000aa0009aaaaaa9aa000aaaaaaaaaaa9aaaaaa9aaaaaaa900000000660000009990000009999999990999999999909906666666666ddd09
aa0000aaaa0009aa000aa00009aaaa90aa0009aaaaaaaaaa09aaaa90aaaaaa9000000000000000009999099099999999999009999990099906666666666dd099
99000099990000990009900000999900990000999999999900999900999999000000000000000000999909909999999999999000000999990000000000000999
99999dddddd9999999999dddddd9999999999dddddd9999999999dddddd9999999999dddddd9999999999dddddd9999999999dddddd9999999999dddddd99999
999dd111111dd999999ddaaaaaadd999999ddaaaaaadd999999ddaaaaaadd999999ddaaaaaadd999999ddaaaaaadd999999ddaaaaaadd999999ddaaaaaadd999
99d1111111111d9999daa1111aaaad9999daaaaaaaaaad9999daaaaaaaaaad9999daaaaaaaaaad9999daaaaaaaaaad9999daaaaaaaaaad9999daaaaaaaaaad99
9d111111111111d99d111111111aaad99d11111aaaaaaad99d11aaaaaaaaaad99d1aaaaaaaaaaad99d1aaaaaaaaaaad99d1aaaaaaaaaaad99daaaaaaaaaaaad9
9d111111111111d99d1111111111aad99d11111111aaaad99d1111aaaaaaaad99d11aaaaaaaaaad99d1aaaaaaaaaaad99d1aaaaaaaaaaad99daaaaaaaaaaaad9
d11111111111111dd111111111111aadd1111111111aaaadd1111111aaaaaaadd111aaaaaaaaaaadd11aaaaaaaaaaaadd1aaaaaaaaaaaaaddaaaaaaaaaaaaaad
d11111111111111dd111111111111aadd11111111111aaadd11111111aaaaaadd1111aaaaaaaaaadd11aaaaaaaaaaaadd1aaaaaaaaaaaaaddaaaaaaaaaaaaaad
d11111111111111dd1111111111111add11111111111aaadd111111111aaaaadd1111aaaaaaaaaadd111aaaaaaaaaaadd1aaaaaaaaaaaaaddaaaaaaaaaaaaaad
d11111111111111dd1111111111111add11111111111aaadd1111111111aaaadd11111aaaaaaaaadd111aaaaaaaaaaadd1aaaaaaaaaaaaaddaaaaaaaaaaaaaad
d11111111111111dd1111111111111add111111111111aadd1111111111aaaadd111111aaaaaaaadd111aaaaaaaaaaadd11aaaaaaaaaaaaddaaaaaaaaaaaaaad
d11111111111111dd1111111111111add111111111111aadd11111111111aaadd1111111aaaaaaadd1111aaaaaaaaaadd11aaaaaaaaaaaaddaaaaaaaaaaaaaad
9d111111111111d99d11111111111ad99d11111111111ad99d1111111111aad99d11111111aaaad99d1111aaaaaaaad99d11aaaaaaaaaad99daaaaaaaaaaaad9
9d111111111111d99d11111111111ad99d11111111111ad99d11111111111ad99d1111111111aad99d1111111aaaaad99d111aaaaaaaaad99daaaaaaaaaaaad9
99d1111111111d9999d1111111111d9999d1111111111d9999d1111111111d9999d1111111111d9999d1111111111d9999d1111aaaa11d9999daaaaaaaaaad99
999dd111111dd999999dd111111dd999999dd111111dd999999dd111111dd999999dd111111dd999999dd111111dd999999dd111111dd999999ddaaaaaadd999
99999dddddd9999999999dddddd9999999999dddddd9999999999dddddd9999999999dddddd9999999999dddddd9999999999dddddd9999999999dddddd99999
0000000000000000000000007700000000033000000000000003300000000000aaa0001100000000000000000000000099999000000999990000000000000000
0000000000000000000000777777000000033000000330000033333000000000aa00101100888880000000000000000000000000000000000000000000000000
0000000077777700000077777777700000033000000330000333383300000000ddd0001100876660000000000000000000000000000000000000000000000000
0000007777777777700777777777777000333300000330003383333300000000dd00d01100866660000000000000000000000000000000000000000000000000
00077777777777777777777777777777003333000033330033333333000000002220000108888880000000000000000000000000000000000000000000000000
00077777777777777777777777777777003333000033330003333830000000002200700008888800000000000000000000000000000000000000000000000000
00777777777777777777777777777776033333300033330000333300000000006660000000888800000000000000000000000000000000000000000000000000
77777777777777777777777777777770033333300333333000044000000000006600601000800800000000000000000000000000000000000000000000000000
77777777777777777777777666777770033333300333333000000000000000006006100106000200000000000000000000000000000000000000000000000000
77777777777777777777777000677760333333333333333300000000000000000660011006660222000000000000000000000000000000000000000000000000
77777777777777777777776000066600333333333335533300000000000000000660011066602220000000000777070707770000077070707770777077000000
67777777777777777777770000000000000440003305503300000000000000006006100100600020000000000070070707000000700070707070707070700000
06777777777777777777770000000000000440000005500000000000000000002002d00d01000d00000000000070077707700000777070707070770070700000
006777777777777777777600000000000004400000055000000000000000000002200dd001110ddd000000000070070707000000007077707070707070700000
000777777777777777777000000000000004400000055000000000000000000002200dd01110ddd0000000000070070707770000770077707770707077700000
00077777777777777766600000000000000440000005500000000000000000002002d00d001000d0000000000000000000000000000000000000000000000000
000677777777777776000000000000000000000000ccccc000000000000000006060a0a0006000a0000000000000000000000000000000000000000000000000
0000777777777777700000000000000000000ccccccccccc000000000000000006000a006660aaa0000000000007770077000007700070077707770770000000
000077777777777777700000000000000000cccccccccccc00000000000000006060a0a006660aaa000000000000700700000007070707077707000707000000
0000777777777777777777000000000000cccccccccccccc00000000000000000000000006000a00000000000000700777000007070777070707700707000000
000077777777777777777770000000000cccccccccccccc00000000000000000d0d0101000200010000000000000700007000007070707070707000707000000
000077777777777777777777000000000cccccccccccccc000000000000000000d00010022201110000000000007770770000007070707070707770777000000
000077777777777777777777700000000cccccccccccccc00000000000000000d0d0101002220111000000000000000000000000000000000000000000000000
0000677777777777777777777000000000ccccccccccccc000000000000000000000000002000100000000000000000000000000000000000000000000000000
0000067777777777777777777000000000ccccccccccccc000000000000000000000000000000000000000000000000007777007007070077777770000000000
0000006667777777777777777000000000cccccccccccc0000000000000000000000000000000000000000000000000070000007777777000070070000000000
0000000007777777777777777000000000cccccccccccc0000000000000000000000000000000000000000000000000777777700070007007770070000000000
000000000777777777777777600000000000cccccccccc0000000000000000000000000000000000000000000000000070070007077777000070070000000000
000000000677777777777666000000000000cccccccccc0000000000000000000000000000000000000000000000000070070000007070000707070000000000
0000000000666777766660000000000000000ccccccccc0000000000000000000000000000000000000000000000000070707007707070007000070000000000
000000000000066660000000000000000000000ccccccc0000000000000000000000000000000000000000000000000077770707770077070000770000000000
0000000000000000000000000000000000000000ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4445454545454545454545454545454600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5440415555554251514155555542435600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5450555555555555555555555555535600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455555555555555555555555555555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455555555555555555555555555555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455555555555555555555555555555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5460555555555555555555555555635600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5461555555555555555555555555525600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5461555555555555555555555555525600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5450555555555555555555555555535600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455555555555555555555555555555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455555555555555555555555555555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455555555555555555555555555555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5460555555555555555555555555635600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5470715555557262627155555572735600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6465656565656565656565656565656600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
900700001814300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
500500001c660136600f650106500d640096300662002610006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001f1651e1611d1511c1511a1511915117151161411414112131101310f1310e1310d1220c1220b1220a122091120811206112041000210000100001000010000100001000010000100001000010000100
0003000012571105710d5610c5610c5510c5510c5510d5510d5510d5510d5510d5610d5610d5610e5610e5610e5610f5610f5710f5711057110571105711057112571125711457116571185711b5711e57122571
000300000b0510d05111041180411e041230312903130021390213f0213e0013f00132001370013d0013f0013f0011000118001190011a0011b0011b0011b0011c0011c0011d0011e0011f0011f0012000121001
01020000235501b550125500f5500a550065500255000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00011a55018500185001850018500185001850018500185001850018500185000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000
110b00011a7700c7000c7000c7000c7000c7000c7000c700006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
9003000038275322752f275002052626524265202650e205182651525514255232051e2050b245112050a2450923531205092350822509205042050722506215062053920004200292002320029200232000e200
100200001c2741d2501e24020250212503f2003f2023f2023f2053f2023f2023f2023f2043f2023f2053f2023f2023f2023f2043f2023f2053f2023f2023f2023f2043f2023f2023f2023f2023f2023f2023f205
110b000010f6010f5010f5510f0010f6010f5010f5500f0010f6010f5010f5510f0010f0010f0010f0013f0012f0012f0012f0012f0015f6015f5015f5510f0015f6015f5015f5515f0015f6015f5015f5500f00
110b000012f6012f5012f5500f0012f6012f5012f5500f0012f6012f5012f5500f0012f0012f0012f0000f0000f0000f0000f0000f0013f6013f5013f5500f0013f6013f5013f5500f0013f6013f5013f5500f00
110b000010f6010f5010f5510f0010f6010f5010f5500f0010f6010f5010f5510f0010f0010f0010f0013f0012f0012f0012f0012f0013f6013f5013f5510f0013f6013f5013f5515f0013f6013f5013f5500f00
110b002012f6012f5012f5512f0000f0000f0000f0000f0012f0012f0012f0012f0010f0012f0013f0000f0012f6012f5012f5010f5010f6410f5010f5012f5013f6013f5013f500bf500ef600ef500ef5012f50
010b0000180730c0000cd000c0000c0000cd000cd000c0000c6550c0000c0000c0000c0000c0000c0000c000180730c0000c0000c0000c0000c0000c0000c0000c6550c0000c0000c0000c0000c0000c0000c000
010b0000180730c0000c0000c0000c0000c0000c0000c0000c6550c0000c0000c0000c0000c0000c0001a063180730c0000c0000c000180730c0000c0000c0000c6550c0000c0000c0000c0000c0000c0000c000
010b0000180730c0000c0000c0000c0000c0000c0000c0000c6550c0000c0000c0000c0000c0000c0000e000180730c0000c0000c000180730c0000c0000c0000c6550c0000c0000c0000c6550c0000c00018000
010b000028e3028e2128e2028e2028e2028e2028e2028e201fe311fe211fe201fe201fe201fe201fe201fe201ce311ce211ce201ce201ce201ce201ce201ce201fe311fe211fe201fe201fe201fe201fe201fe20
010b002026e3026e2126e2026e2026e2026e2026e2026e201fe311fe211fe201fe201fe201fe201fe201fe201ce311ce211ce201ce201ce201ce201ce201ce201fe311fe211fe201fe201fe201fe201fe201fe20
010b000026e3026e2126e2026e2026e2026e2026e2026e201fe311fe211fe201fe201fe201fe201fe201fe201ce311ce211ce201ce201ce201ce201ce201ce201ce111ce101ce101ce152be002be002be002be00
010b0000180730c0000c0000c0000c0000c0000c0000c0000c6550c0000c0000c0000c0000c0000c0001a063180730c0000c0000c000180730c0000c0000c0000c60000000000000000000000000000000000000
110b002012f5012f4112f4512f0000f0000f0000f0000f0012f5012f4112f4512f0010f0012f0013f0000f0012f5012f4112f4510f0010f0010f0010f0012f0013f0013f0013f000bf000ef000ef000ef0012f00
110b000010f6010f5110f5510f0010f6010f5110f5500f0010f6010f5110f5510f0010f6010f5110f5513f0010f6010f5110f5015f5015f6015f5115f5510f0015f6015f5115f5515f0015f6015f5115f5500f00
110b000012f6012f5112f5510f0012f6012f5112f5500f0012f6012f5112f5510f0012f6012f5112f5513f0012f6012f5112f5017f6317f6017f5117f5510f0017f6017f5117f5515f0017f6017f5117f5500f00
110b000012f6012f5112f5512f0000f0000f0000f0000f0012f6012f5112f5512f0010f0012f0013f0000f0012f6012f6012f5112f5012f4112f4012f3112f3012f2112f2012f1112f150ef000ef000ef0012f00
010b000026e3026e2126e2026e2026e2026e2026e2026e201fe311fe201fe201fe201fe201fe201fe201fe2027e3127e2000e0000e0027e3027e201fe001fe0027e3027e2027e0027e0027e3027e2023e0023e00
010b000028e4028e3528e0026e0028e4128e3028e3028e301fe401fe301fe301fe301ce411ce301ce301ce3022e4022e3522e0021e0023e4123e3023e3023e301fe401fe301fe301fe301ce411ce301ce301ce30
010b00001ae401ae3528e001ae001ce401ce301ce301ce351fe541fe301fe301fe301ce411ce301ce301ce3521e5421e3021e3021e301ce411ce301ce301ce3524e5424e3024e3024e301ce411ce301ce301ce30
010b000021e4021e3028e0420e0022e4122e3022e3022e301fe401fe301fe301fe301ce401ce301ce301ce301ae401ae301ae041ae001ce401ce301ce001ce001ce401ce301ce301ce301ce201ce251ce001ce00
010b000028e4028e3528e0027e0028e4028e3128e3028e301ce401ce311ce301ce301ce211ce221ce221ce2222e4022e3522e0022e0023e4023e3123e3023e301ce401ce311ce301ce301ce211ce221ce221ce22
000b00001ae401ae3528e001be001ce401ce311ce301ce301fe401fe311fe301fe301ce311ce301ce301ce3021e4021e3121e0021e0021e4021e3121e3021e3022e4022e3122e3022e3023e2123e2223e2223e22
010b00001ae401ae311ae041be001ce401ce311ce301ce301ae401ae311ae041be001ce401ce311ce301ce301ae401ae311ae0418e001ce411ce311ce001ce001ce401ce311ce321ce221ce221ce221ce001ce00
110b000010f6010f5110f5510f0010f6010f5110f5500f0010f6010f5110f5510f0010f6010f5110f5513f0012f0012f0012f0012f0015f6015f5115f5510f0015f6015f5115f5515f0015f6015f5115f5500f00
110b000012f6012f5112f5500f0012f6012f5112f5500f0012f6012f5112f5500f0012f6012f5112f5500f0000f0000f0000f0000f0013f6013f5113f5500f0013f6013f5113f5500f0013f6013f5113f5500f00
110b000010f6010f5110f5510f0010f6010f5110f5500f0010f6010f5110f5510f0010f6010f5110f5510f0012f0012f0012f0012f0013f6013f5113f5510f0013f6013f5113f5515f0013f6013f5113f5500f00
110b000012f6012f5112f5512f0000f0000f0000f0000f0012f6012f5112f5512f0010f0012f0013f0000f0012f6012f5112f5010f4010f6010f5010f5012f5013f6013f5013f500bf500ef600ef500ef5012f50
010b000021e4021e3028e0420e0022e4122e3022e3022e301fe401fe301fe301fe301ce401ce301ce301ce301ae401ae301ae041ae001ce411ce301ce001ce001ce401ce301ce301ce301ce211ce201ce111ce15
010b0000180730c0000c0000c0000c0000c0000c0000c0000c6550c0000c0000c0000c0000c0000c0001a063180730c0000c0000c000180730c0000c0001a0630c6550c0000c0000c0001a0630e0000e0000e000
100b000012f0012f0012f0012f0000f0000f0000f0000f0012f0012f0012f0012f0010f0012f0013f0000f0012f0012f0012f0010f0010f0010f0010f0012f0013f0013f0013f000bf000ef000ef000ef0012f00
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
510e00003903039035380003800038030380353600036000370303703500000320003603136032360223602236022360153600000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002d66027640226301e6301b63017620136200e6100a6100761005610036100261001610006000360001600006000060000600006000060000600006000060000600006000060000600006000060000600
01040000356602f65028650236501f6501b6401764014630126300f6300c6300a6200862006620046200361001610006100060000600006000060000600006000060000600006000060000600006000060000600
010b00001905019050000001b00019040190401d0501d050000001d0001d0401d0402005020050200502005020050200501d0501d0501c0002000020040200402505025050250502505125041250412503125025
010b0000180730c000180000c00018073180000c6550c0000c6000c0000c6550c0000c0000c0000c0001a000180730c0000c6550c0000c6000c000180730c000180730c0000c0000c0000c0000c0000000000000
490b00000d0700d0600d0600d0600d0600d0651107011060110601106011060110651407014060140601406014060140601406014065140000c0000c0000c0001907019060190601906019060190650c0000c000
000200002e0502b0502905027040240302202020010200001b000190001c0001f0002600028000270001f0001a0001700017000190001c0001c0001c0001900018000190001900015000120000e0000600005000
010200002e0502c0512a050270502405122051200501d0401b040180401604014040120310f0300c0300a03008030060300402101010000100000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000181521515210145181020b1020b102181421513210135171020e102121021813215122101251610214102171021812215115141121211211112101150010000100001000000000000000000000000000
900700001815300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910e00001f17300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
911400002117300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000071500a1500c1500e15010150131501415015155151001510010140131401414015145000000000010130131301413015135000000000010120131201412015125000000000010110131101411015115
c5020000390403603033020320153d0003e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
180400001f5651e5611d5511c5511a5511955117551165411454112531105310f5310e5310d5220c5220b5220a522095120851206512045000250000500005000050000500005000050000500005000050000500
00040000356502f65028650236501f6501b6401764014630126300f6300c6300a6200862006620046200361001610006100060000600006000060000600006000060000600006000060000600006000060000600
__music__
04 33 34 32 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 0e 0a 43 44
00 0f 0b 43 44
00 0e 0c 43 44
00 10 0d 43 44
01 0e 20 11 44
00 0f 21 12 44
00 0e 22 11 44
00 25 0d 13 44
00 0e 16 11 44
00 0f 17 12 44
00 0e 16 11 44
00 0f 18 19 44
00 0e 20 1d 44
00 0f 21 1e 44
00 0e 22 1d 44
00 0f 23 1f 44
00 0e 20 1a 44
00 0f 21 1b 44
00 0e 22 1a 44
00 25 18 1c 44
00 0e 16 43 44
00 0f 17 43 44
00 0e 16 43 44
02 10 0d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
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
