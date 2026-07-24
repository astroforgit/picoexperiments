pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--help yug  get to work while
--teleporting and jumping!

--[[

credits (code i borrowed):

nerdyteachers - basics of pico 8
  the youtube tutorials from
  nerdyteachers are responsible
  for this game being a reality
  i still use a lot of the 
  things i learned from those
  tutorials, such as the
  collision system.

docrobs - particle system
  cart: lightweight particle
        system
  this system was also adapted
  for like every object in my
  game.
  
krystman - logo fade in/out
  cart: cherry bomb
  aka "lazy devs academy",
  the logo fade in and out that
  is seen in a lot of krystman
  games was used here.
  
amacdougall - music sync
  they posted on the forums
  about a system for syncing
  animation with the bpm of
  the music. that system is
  responsible for the spikes
  and such dancing to the music.

??? - sprite collision
  i am so sorry but i cannot
  remember where i found the
  sprite collision functions.
  if anybody recognizes it
  please let me know where it is
  from so i can properly credit
  the author.
  
captain rektbeard - various
  captain helped me fix the
  wipe save bug, and helped
  with implementation of 
  auto splitter.
  
--]]

--[[
patch notes

patch 1.1: 6/27/23

 -fixed wipe save sometimes not
  working (hopefully)
 -fixed wipe save not working
  on fake08 (hopefully)
 -made the show time selection
  not reset on wipe save
  or cart reload
 -added show level menu option
 -overhaul of map object system
 -added ranks
 -changed rank requirments to
  match intended route
 
--]]

--variables

wipe_flag_addr=0x4b4b
wipe_flag_val_timer=0xabcd
function _init()

 music(18)
 
 p={
  sp=1,
  --game start: 4,8
  startx=4*8-4,
  starty=8*8-12,
  y=0,
  x=0,
  w=8,
  h=8,
  flp=false,
  dx=0,
  dy=0,
  max_dx=1.5,
  max_dy=3,
  acc=0.6,
  boost=3.7,
  anim=0,
  running=false,
  init_jumping=false,
  jumping=false,
  landed=false,
  landed_flip=true,
  cstart=0.2,
  ctime=0,
  jbreq=false,
  jbstart=0,
  jbtime=0,
  trans=false,
  trans_time=0,
  trans_end=0,
  can_tele=false,
 }
 
 t={
  x=70*8,
  y=80*8,
  x_adj=0,
  y_adj=0,
  w=8,
  h=8,
  left=false,
  right=false,
  down=false,
  up=false
 }
 
 t2={
  x=60*8+3,
  y=80*8,
  sp=33
 }
 
 gravity=.6
 friction=0.5

 --map limits
	map_start=0
	map_end=1024
	map_endy=256+128
	mapx=0
	mapy=0

	update_screen=true
	offscreen=false

	shake=0
	shakex=0
	shakey=0
	p_shake=false

	spike_anim=0
	spikeball_anim=0
	orange_anim=0

	clock_anim_time=0
	has_clock=false
	clockx=0
	clocky=0
	clocksp=119
	
	coins={}
	add_all_coins()
	
	env_dust={}
	
	dust={}
	run_dust_time=0
	
	switches={}
	rocks={}
	feathers={}
	platforms={}
	keys={}
	
	switch="red"
	green=true
	
	--rock hitbox
	left=false
	right=false
	down=false
	up=false
	inside_rock=false
	
	inside_spike=false
	
	feather_down_collide=false
	feather_down=false
	
	--platform hitbox
	plat_left=false
	plat_right=false
	plat_down=false
	plat_up=false
	plat_inside=false
	
	load_lvl=true
	
	cutscene=true
	
	start_game=true
	
	start_game_timer=0
	start_game_time=0
	p_move=0
	p_move_max=0
	
	end_game=false
	end_game_timer=0
 end_game_time=0
 blink_sp=1 --32
 blink_amt=0
 blink_time=0
 idle_blink_time=0
	
	timer=0
	timer_time=0
	timer_prev=time()
	timer_format="0:00"
	deaths=0
	teleports=0
	
	show_timer=0
	show_deaths=0
	
	current_level=1
	show_level=0
	
	restart=false
	restart_count=0
	
	start_music=false
	started=false
	
	sync.on(8,function()
  replace_tiles_anim(78,0,79)
 end)
 
 sync.on(16,function()
  clock_anim()
  orange_tile_anim()
  replace_tiles_anim(93,94,95)
 end)
 
 if cartdata("blumakesgames_porter") then
 	if (peek2(wipe_flag_addr)==wipe_flag_val) then 
   wipe_save()
   poke(wipe_flag_addr,0)
  end
 	p.startx=dget(0)
 	p.starty=dget(1)
  deaths=dget(2)
  teleports=dget(3)
  timer=dget(4)
  current_level=dget(5)
  
  show_timer=dget(6)
  show_level=dget(7)
  show_deaths=dget(8)
  
  if p.startx!=4*8-4 then
  	cutscene=false
	  start_game=false
	 else
	 	timer=0
  end
 end
 
 p.x=p.startx
 p.y=p.starty
 
 logo()
	--------test-----------
		--x1r=0 y1r=0 x2r=0 y2r=0
		--collide_l="no"
		--collide_r="no"
		--collide_u="no"
		--collide_d="no"
		
		--highest_usage=0
		--dropped_frames=0
		
		--t_test=0
	-----------------------
end

function logo()
	 -- logo ani --
 fadetable={{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{1,1,129,129,129,129,129,129,129,129,0,0,0,0,0},{2,2,2,130,130,130,130,130,128,128,128,128,128,0,0},{3,3,3,131,131,131,131,129,129,129,129,129,0,0,0},{4,4,132,132,132,132,132,132,130,128,128,128,128,0,0},{5,5,133,133,133,133,130,130,128,128,128,128,128,0,0},{6,6,134,13,13,13,141,5,5,5,133,130,128,128,0},{7,6,6,6,134,134,134,134,5,5,5,133,130,128,0},{8,8,136,136,136,136,132,132,132,130,128,128,128,128,0},{9,9,9,4,4,4,4,132,132,132,128,128,128,128,0},{10,10,138,138,138,4,4,4,132,132,133,128,128,128,0},{11,139,139,139,139,3,3,3,3,129,129,129,0,0,0},{12,12,12,140,140,140,140,131,131,131,1,129,129,129,0},{13,13,141,141,5,5,5,133,133,130,129,129,128,128,0},{14,14,14,134,134,141,141,2,2,133,130,130,128,128,0},{15,143,143,134,134,134,134,5,5,5,133,133,128,128,0}}

 cls(15)
 spr(13,52,44,3,2)
 print("makes games",42,62,12)
 
 fadeperc=1
 
 repeat
  dofade()
  fadeperc-=0.07
  flip()
 until( fadeperc<=0 )
 
 fadeperc=0
 dofade()
 for i=0,30 do
  flip()
 end
 
 repeat
  dofade()
  fadeperc+=0.07
  flip()
 until( fadeperc>=1 )
 fadeperc=0
 cls()
 dofade()
 for i=0,10 do
  flip()
 end
end

function dofade()
 fadeperc=min(fadeperc,1)
 for c=0,15 do
  pal(c,fadetable[c+1][flr(fadeperc*16+1)],1)
 end
end
-->8

-->8
--menu

menuitem(2,"show timer",function()
 if show_timer==0 then
	 show_timer=1
 else
  show_timer=0
 end
end)

menuitem(3,"show deaths",function()
 if show_deaths==0 then
	 show_deaths=1
 else
  show_deaths=0
 end
end)

menuitem(4,"show level",function()
 if show_level==0 then
	 show_level=1
 else
  show_level=0
 end
end)

menuitem(5,"wipe save",function()
 dset(0,4*8-4)
	dset(1,8*8-12)
 dset(2,0)
 dset(3,0)
 dset(4,0)
 dset(5,1)
 poke2(wipe_flag_addr,wipe_flag_val)
 run()
end)

-->8
--game

function _update()
 if not cutscene then
  save_game()
 end
 
 sync.update()

 if p.landed then
 	start_music=true
 end

 if not started
 and start_music then
 	music(0,nil,3)
 	started=true
 end

 start_sequence_update()

 end_sequence_update()
 
 if not cutscene then
 	player_update()
 end
 
 
 for c in all(coins) do
  c:update()
 end
 
 for s in all(switches) do
  s:update()
 end
 
 for r in all(rocks) do
  r:update()
 end
 
 for f in all(feathers) do
  f:update()
 end
 
 for pl in all(platforms) do
  pl:update()
 end
 
 for k in all(keys) do
  k:update()
 end
 
 for e in all(env_dust) do
  e:update()
 end
 
 for d in all(dust) do
  d:update()
 end
 
 if not cutscene then
	 delta=time()-timer_prev
  timer+=delta
  if timer%60<10 then
   timer_format=flr(timer/60)..":".."0"..flr(timer%60)
  else
   timer_format=flr(timer/60)..":"..flr(timer%60)
  end
 end
 timer_prev=time()
end

function _draw()
 cls()
 --camera tile
 if not p.trans
 and not update_screen then
  if p.x>mapx*8+128
  or p.x<mapx*8
  or p.y>mapy*8+128
  or p.y<mapy*8 then
   offscreen=true
  else
   offscreen=false
  end
 end
 if update_screen then
  mapx=flr((p.x/16/8))*16
  mapy=flr((p.y/16)/8)*16
  update_screen=false
 end
 camera(mapx*8+shakex,mapy*8+shakey)
 add_env_dust()
 
 
 start_sequence_draw()
 end_sequence_draw()
 secret()
 
 check_for_clock()
 
 map(0,0)
 if not cutscene then
  spr(p.sp,p.x,p.y,1,1,p.flp)
 end
 
 new_screen()
 
 --test cpu--
 --print(stat(1),mapx*8+16,mapy*8+16,14)
 --if stat(1)>=0.9 then
 -- dropped_frames+=1
 --end
 --print(dropped_frames,mapx*8+16,mapy*8+24,14)
 --if stat(1)>highest_usage then
 --	highest_usage=stat(1)
 --end
 --print(highest_usage,mapx*8+16,mapy*8+32,14)
 
 --print(t_test,mapx*8+16,mapy*8+40,14)
 --------
 
 if not p.trans
 and not cutscene then
  if not collide_map(p,"inside",4) then
   spr(t2.sp,t2.x,t2.y,1,1,false)
   spr(16,t.x,t.y,1,1,false)
  else
   spr(t2.sp,t2.x,t2.y,1,1,false)
   spr(17,t.x,t.y,1,1,false)
  end
 end
 
 for c in all(coins) do
  c:draw()
 end
 
 for s in all(switches) do
  s:draw()
 end
 
 for r in all(rocks) do
  r:draw()
 end
 
 for f in all(feathers) do
  f:draw()
 end
 
 for pl in all(platforms) do
  pl:draw()
 end
 
 for k in all(keys) do
  k:draw()
 end
 
 for e in all(env_dust) do
  e:draw()
 end
 
 for d in all(dust) do
  d:draw()
 end
 
 do_shake()
 
 --------test-----------
  --print(current_level,p.x,p.y,8)
		--rect(x1r,y1r,x2r,y2r,3)
	-----------------------
	
	--menu options
	if show_timer==1
	and not cutscene then
		print("time: "..timer_format,mapx*8+8,mapy*8+8,13)
	end
	
	if show_teleports==1
	and not cutscene then
		print("teleports: "..teleports,mapx*8+8,mapy*8+24,13)
	end
	
	if show_deaths==1
	and not cutscene then
		print("deaths: "..deaths,mapx*8+8,mapy*8+16,13)
	end
	
	if show_level ==1
	and not cutscene then
		print("level: "..current_level,mapx*8+80,mapy*8+8,13)
	end
end
-->8
--player

function player_update()
 if not p.trans
 and p.can_tele then
  teleport()
 end
 player_animate()
 die()
 screen_transition()
 
 --physics
 p.dy+=gravity
 p.dx*=friction
 
 --controls
 if btn(‹) then
  p.dx-=p.acc
  p.running=true
  p.flp=true
  if time()-run_dust_time>0.2 then
   run_dust_time=time()
  end
 end
 if btn(‘) then
  p.dx+=p.acc
  p.running=true
  p.flp=false
  if time()-run_dust_time>0.2 then
   run_dust_time=time()
  end
 end
 
 if not btn(‹) 
 and not btn(‘) then
  p.running=false
 end
 
 --coyote time
  if not p.landed then
    if time()-p.cstart>.01 then
      p.cstart=time()
      p.ctime+=1
    end
  else
    p.ctime=0
  end
  
  --jump buffer
  if not p.landed
  and btnp(Ž)
  and not p.dead then
  	 p.jbreq=true
  end
  		
  if p.jbreq then
  		if time()-p.jbstart>.01 then
      p.jbstart=time()
      p.jbtime+=1
    end
    if p.jbtime>5 then
      p.jbreq=false
    end
  end
  
  --jump
  if btnp(Ž)
  and not p.dead
  and p.landed
  or btnp(Ž)
  and not p.dead
  and p.ctime<3
  or p.jbtime>0
  and p.jbtime<6
  and p.landed then
    if p.dy>-1 then
      sfx(42)
      p.init_jumping=true
      p.dy=0.3
      p.dy-=p.boost
      if p.flp then
       add_new_dust(p.x+4,p.y+8,0.5,-0.3,7,3,0,7)
      else
       add_new_dust(p.x+4,p.y+8,-0.5,-0.3,7,3,0,7)
      end
    end
    p.landed=false
    p.jbtime=0
    p.jbreq=false
  end
  
  if p.dy>0 then
  	p.init_jumping=false
  end
  
  if p.landed then
    p.jbtime=0
  end
  
  --landing
  if feather_down_collide
  or feather_down then
  	p.landed=false
  end
  
  if not p.landed_flip then
   if p.landed then
    p.landed_flip=true
    add_new_dust(p.x+4,p.y+8,1,-0.1,8,2,0,7)
    add_new_dust(p.x+4,p.y+8,-1,-0.1,8,2,0,7)
    add_new_dust(p.x+4,p.y+8,0.5,-0.1,8,2,0,7)
    add_new_dust(p.x+4,p.y+8,-0.5,-0.1,8,2,0,7)
    sfx(41)
   end
  end
  
  if p.dy>1
  or p.dy<-1 then
   p.landed_flip=false
  end
  
  --check sprite collision
  for r in all(rocks) do
   if collide_sprite(p,"left",r) then
    left=true
    if left==true then break end
   else
    left=false
   end
  end
   
  for r in all(rocks) do 
   if collide_sprite(p,"right",r) then
    right=true
    if right==true then break end
   else
    right=false
   end
  end
  
  for r in all(rocks) do
   if collide_sprite(p,"down",r) then
    down=true
    if down==true then break end
   else
    down=false
   end
  end
   
  for r in all(rocks) do
   if collide_sprite(p,"up",r) then
    up=true
    if up==true then break end
   else
    up=false
   end
  end
  
  --platforms
  for pl in all(platforms) do
  	if collide_sprite(p,"left",pl)
  	and pl.collide then
  	 plat_left=true
  		if plat_left==true then break end
  	else
  	 plat_left=false
			end
  end
  
  for pl in all(platforms) do
  	if collide_sprite(p,"right",pl)
  	and pl.collide then
  	 plat_right=true
  		if plat_right==true then break end
  	else
  	 plat_right=false
			end
  end
  
  for pl in all(platforms) do
  	if collide_sprite(p,"plat_down",pl)
  	and pl.collide then
  		plat_down=true
  		if plat_down==true then break end
  	else
  	 plat_down=false
			end
  end
  
  for pl in all(platforms) do
  	if collide_sprite(p,"plat_up",pl)
  	and pl.collide then
  		plat_up=true
  		if plat_up==true then break end
  	else
  	 plat_up=false
			end
  end
  
  --feathers
  for f in all(feathers) do
   if collide_sprite(p,"feather_down",f) then
    feather_down_collide=true
    feather_down=true
    p.landed=false
    if feather_down_collide==true then break end
   else
    feather_down_collide=false
    feather_down=false
   end
  end
  
  --check collision up and down
  local walljump_fix=false
  if collide_map(p,"up_right",0)
  and flr(p.x%8)==2 then
  	walljump_fix=true
  else
   walljump_fix=false
  end
  
  if p.dy>0 then
    p.falling=true
    p.landed=false
    p.jumping=false
    
    p.dy=limit_speed(p.dy,p.max_dy)
    
    if collide_map(p,"down",0)
    or down 
    or plat_down 
    or feather_down_collide then
     
      if not feather_down_collide
      and not feather_down
      and not walljump_fix then
       p.landed=true
       p.falling=false
       p.dy=0
      end
      p.can_tele=true
      if feather_down then
       p.landed=false
       if not collide_map(p,"tall_up",0) then
      	 p.dy=0
       end
      end
      if not feather_down_collide then
       if not down then
        if not collide_map(p,"up",0) then
         p.y-=((p.y+p.h+1)%8)-1
        end
       else
        p.y-=((p.y+p.h+1)%8)-3
       end
      end
      -------test----
      --collide_d="yes"
      --else collide_d="no"
      ---------------
    
     end
    elseif p.dy<0 then
  	 	p.jumping=true
  	 	if collide_map(p,"up",0)
  	 	or up 
  	 	or plat_up then
  		  if not walljump_fix then
  		  p.dy=0
  		  p.walljump=false
  		  
  		  -------test----
      --collide_u="yes"
      --else collide_u="no"
      ---------------
  	 	end
    end
   end
  --test
  --t_test=flr(p.y%8)
  
  --check collision left and right
  if p.dx<0 then
  
    p.dx=limit_speed(p.dx,p.max_dx)
  
  		if collide_map(p,"left",0)
  		or left 
  		or plat_left then
      p.dx=0
      
      if (p.x+p.w+1)%8>4 then
       if left then
        --p.x+=((p.x+p.w+1)%8)-1
       else
        p.x+=((p.x+p.w)%8)-6
       end
      end
      
      -------test----
      --collide_l="yes"
      --else collide_l="no"
      ---------------
    end
  elseif p.dx>0 then
  
    p.dx=limit_speed(p.dx,p.max_dx)
  
    if collide_map(p,"right",0)
    or right 
    or plat_right then
      p.dx=0
      
      if right then
       --p.x-=((p.x+p.w+1)%8)-3
      else
       p.x-=((p.x+p.w+1)%8)-2
      end
      
      
      -------test----
      --collide_r="yes"
      --else collide_r="no"
      ---------------
    end
  end
  
  p.x+=p.dx
  p.y+=p.dy
  
  --stop playing from sliding
  --very small distances
  if p.dx<0.5 
  and p.dx>-0.5 then
  	p.dx=0
  end
  
  --limit player to map
  if p.x<map_start then
    p.x=map_start
  end
  if p.x>map_end-p.w then
    p.x=map_end-p.w
  end
  if p.y<map_start then
    p.y=map_start
  end
  if p.y>map_end-p.w then
    p.y=map_end-p.w
  end
end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end

function teleport()
 if btn(”) then
  t.left=false
  t.right=false
  t.down=false
  t.up=true
  t.x=p.x
  t.y=p.y-32
  t2.x=p.x
  t2.y=p.y-27
  t2.sp=49
  t.x_adj=0
  t.y_adj=-32
 elseif btn(ƒ) then
  t.left=false
  t.right=false
  t.down=true
  t.up=false
  t.x=p.x
  t.y=p.y+32
  t2.x=p.x
  t2.y=p.y+26
  t2.sp=49
  t.x_adj=0
  t.y_adj=32
 elseif p.flp then
  t.left=true
  t.right=false
  t.down=false
  t.up=false
  t.x=p.x-32
  t.y=p.y
  t2.x=p.x-26
  t2.y=p.y
  t2.sp=33
  t.x_adj=-32
  t.y_adj=0
 else
  t.left=false
  t.right=true
  t.down=false
  t.up=false
  t.x=p.x+32
  t.y=p.y
  t2.x=p.x+27
  t2.y=p.y
  t2.sp=33
  t.x_adj=32
  t.y_adj=0
 end

 if btnp(—)
 and not collide_map(p,"inside",4) then
  if collide_map(t,"right",0) then
   if flr(t.x%8)==2 then
    t.x_adj-=1
   elseif flr(t.x%8)==3 then
    t.x_adj-=2
   elseif flr(t.x%8)==4 then
    t.x_adj-=3
   end
  end
  if collide_map(t,"left",0) then
   if flr(t.x%8)==4 then
    t.x_adj+=3
   elseif flr(t.x%8)==5 then
    t.x_adj+=2
   elseif flr(t.x%8)==6 then
    t.x_adj+=1
   end
  end
  if collide_map(t,"down",0) then
   if flr(t.y%8)==3 then
    t.y_adj-=1
   elseif flr(t.y%8)==4 then
    t.y_adj-=2
   end
  end
  if collide_map(t,"up",0) then
   if flr(t.y%8)==4 then
    t.y_adj+=1
   end
  end
  
  --test
  --t_test=flr(t.y%8)
  
  sfx(40)
  tele_part_bef()
  p.x+=t.x_adj
  p.y+=t.y_adj
  tele_part_aft()
  teleports+=1
 end
end

function tele_part_bef()
 local p_length=16
 for i=0,2 do
   add_new_dust(p.x+rnd(8),p.y+rnd(8),0,0,p_length,rnd(2)+2,0,12)
   p_length-=2
 end
end

function tele_part_aft()
 local p_length=6
 for i=0,2 do
  add_new_dust(p.x+rnd(8),p.y+rnd(8),0,0,p_length,1,0,12)
  p_length-=2
 end
end

local blink_time_anim=0
local blink_time=0
function player_animate()
 if p.jumping then
		p.sp=7
  idle_blink_time=0
	elseif p.falling then
		p.sp=8
  idle_blink_time=0
	elseif p.running then
		if time()-p.anim>.1 then
		 if not p.trans then
		  sfx(43)
		 end
		 p.anim=time()
		 p.sp+=1
			 if p.sp>6 then
			   p.sp=3
		  end
		end
  idle_blink_time=0
	else --player idle
		
		p.sp=1
		idle_blink_time+=1
		 
		if idle_blink_time>500 then
			if time()-blink_time_anim>0.5
 	 and blink_amt<2 then
 		 blink_time_anim=time()
 		 blink_sp=32
 	  blink_amt+=1
 			sfx(51)
			 blink_time=0
			else
			 blink_time+=1
			 if blink_time>3 then
			 	blink_sp=1
    end
   end
		 p.sp=blink_sp
		else
			if not cutscene then
				blink_sp=1 --32
    blink_amt=0
    blink_time=0
			end
		end
	end
end

local rx=38
function die()

 for r in all(rocks) do
  if collide_sprite(p,"inside",r) then
   inside_rock=true
   if inside_rock==true then break end
  else
   inside_rock=false
  end
 end

 if collide_map(p,"inside",2)
 or collide_map(p,"block",3)
 or up
 or offscreen
 or inside_rock then
  for i=0, 5 do
   add_new_dust(p.x+rnd(8),p.y+rnd(8),rnd(2)-1,rnd(2)-1,rx,rnd(2)+3,0,8)
   rx-=2
  end
  rx=38
 
  sfx(44)
  sfx(45)
  p.can_tele=false
  p.x=p.startx
  p.y=p.starty
  p.dx=0
  p.dy=0
  
  if not has_clock then
   switch="temp"
   green=true
   replace_tiles()
   switch="blue"
   replace_tiles()
  elseif switch=="blue" then
  	switch="temp"
   green=true
   replace_tiles()
   switch="blue"
  else
  	switch="temp"
   green=true
   replace_tiles()
   switch="red"
  end
  
		scan_and_place()
  
  shake+=0.1
  p.flp=false
  for r in all(rocks) do
   r.x=r.startx
   r.y=r.starty
  end
  for f in all(feathers) do
   f.x=f.startx
   f.y=f.starty
  end
  for pl in all(platforms) do
  	pl.sp=89
  	pl.collide=true
  end
  for k in all(keys) do
  	k.collected=false
  	k.sp=85
  end
  deaths+=1
 end
end

function new_start(x,y)
 p.startx=x
 p.starty=y
end

local d=16
function screen_transition()
 if p.trans then
  p.sp=9
  p.dx=0
  p.dy=0
  gravity=0
  if time()-p.trans_time>0.1 then
   p.trans_time=time()
   p.trans_end+=1
   if p.trans_end>6 then
    p.trans_end=0
    p.trans=false
    p.x=p.startx
    p.y=p.starty
    switch="temp"
    green=true
    replace_tiles()
    switch="blue"
    replace_tiles()
    load_lvl=true
    update_screen=true
    has_clock=false
    p.flp=false
    
    for i=0,3 do
     add_new_dust(p.x+rnd(8),p.y+rnd(8),0,0,d,3,0,10)
     d-=2
    end
    d=16
   end
  end
 else
  gravity=0.6
 end
end

local cutscene_num=0
function save_game()
 dset(0,p.startx)
 dset(1,p.starty)
 dset(2,deaths)
 dset(3,teleports)
 dset(4,timer)
 dset(5,current_level)
 dset(6,show_timer)
 dset(7,show_level)
 dset(8,show_deaths)
 if cutscene then
  cutscene_num=0
 else
 	cutscene_num=1
 end
 dset(9,cutscene_num)
end
-->8
--collision

function collide_map(obj,aim,flag)
  --obj = table needs x,y,w,h
  --aim = left,right,up,down
  
  local x=obj.x  local y=obj.y
  local w=obj.w  local h=obj.h
  
  local x1=0  local y1=0
  local x2=0  local y2=0
  
  if aim=="left" then
    x1=x       y1=y+3 
    x2=x+2      y2=y+h-1
    
  elseif aim=="up_right" then
    x1=x+w-3      y1=y+3 
    x2=x+w-1      y2=y+3
    
  elseif aim=="right" then
    x1=x+w-3    y1=y+3 --" "
    x2=x+w-1  y2=y+h-1
  
  elseif aim=="up" then
    x1=x+2    y1=y+1 
    x2=x+w-2  y2=y+2
    
  elseif aim=="tall_up" then
    x1=x+2    y1=y-1 
    x2=x+w-2  y2=y+2
  
  elseif aim=="down" then
    x1=x+2      y1=y+h
    x2=x+6    y2=y+h
    
  elseif aim=="inside" then
    x1=x+w-4      y1=y+h-5
    x2=x+w-4    y2=y+h-5
  
  elseif aim=="block" then
    x1=x+3      y1=y+h-4
    x2=x+w-3    y2=y+h-4
  end
  
  --------test-----------
		--x1r=x1 y1r=y1
		--x2r=x2 y2r=y2
		-----------------------
  
  --pixels to tiles
  x1/=8  y1/=8
  x2/=8  y2/=8
  
  if fget(mget(x1,y1), flag)
  or fget(mget(x1,y2), flag)
  or fget(mget(x2,y1), flag)
  or fget(mget(x2,y2), flag) then
    return true
  else
    return false
  end
  
  
end

--sprite collision
function intersect(min1, max1, min2, max2)
  return max(min1,max1) > min(min2,max2) and
         min(min1,max1) < max(min2,max2)
end

function sprcollide(spr1,spr2)
    return intersect(spr1.x+2, spr1.x+6,
        spr2.x+2, spr2.x+6) and
    intersect(spr1.y+2, spr1.y+6,
        spr2.y+2, spr2.y+6)
end

function collide_sprite(obj,aim,obj2)
  local x=obj.x  local y=obj.y
  local w=obj.w  local h=obj.h
  
  local x1=0  local y1=0
  local x2=0  local y2=0
  
  if aim=="left" then
    x1=x    y1=y+2
    x2=x+2      y2=y+7
    
  elseif aim=="right" then
    x1=x+5    y1=y+2
    x2=x+7  y2=y+7
  
  elseif aim=="up" then
    x1=x+2    y1=y
    x2=x+5  y2=y+1
    
  elseif aim=="tall_up" then
    x1=x+2    y1=y-1
    x2=x+7  y2=y+1  
  
  elseif aim=="down" then
    x1=x+2      y1=y+h
    x2=x+6    y2=y+h
   
  elseif aim=="feather_up" then
    x1=x    y1=y+1
    x2=x+w  y2=y+2
    
  elseif aim=="feather_down" then
    x1=x      y1=y+6
    x2=x+w    y2=y+6
    
  elseif aim=="switch" then
    x1=x+1      y1=y+6
    x2=x+7    y2=y+8
  
  elseif aim=="inside" then
    x1=x+2      y1=y+4
    x2=x+6    y2=y+4
    
  elseif aim=="plat_up" then
    x1=x+2    y1=y+5
    x2=x+5  y2=y+6  
    
  elseif aim=="plat_down" then
    x1=x+2      y1=y+10
    x2=x+6    y2=y+10
    
  elseif aim=="plat_left" then
    x1=x    y1=y+4
    x2=x+2      y2=y+6
    
  elseif aim=="plat_right" then
    x1=x+5    y1=y+4
    x2=x+7  y2=y+6  
  end
  
  return intersect(x1, x2,
        obj2.x+2, obj2.x+7) and
    intersect(y1, y2,
        obj2.y+1, obj2.y+8) 
end
-->8
--map

--add all objects
function add_all_coins()
 --level 1-8
 add_new_coin(13,7,19,9)
 add_new_coin(27,10,35,10)
 add_new_coin(44,6,51,3)
 add_new_coin(53,11,72,13)
 add_new_coin(74,3,83,6)
 add_new_coin(93,3,99,11)
 add_new_coin(98,2,115,10)
 add_new_coin(124,1,5,19)
 --level 9-16
 add_new_coin(14,22,19,26)
 add_new_coin(30,25,36,21)
 add_new_coin(38,28,49,28)
 add_new_coin(62,19,66,25)
 add_new_coin(66,30,82,24)
 add_new_coin(82,29,99,19)
 add_new_coin(109,18,114,26)
 add_new_coin(125,24,3,43)
 --level 7-24
 add_new_coin(3,33,18,45)
 add_new_coin(19,34,33,43)
 add_new_coin(33,33,50,44)
 add_new_coin(54,33,67,43)
 add_new_coin(67,35,81,35)
 add_new_coin(81,42,99,44)
 add_new_coin(98,38,115,44)
 add_new_coin(114,33,5,54)
 --level 25-28
 add_new_coin(5,58,18,56)
 add_new_coin(29,53,35,56)
 add_new_coin(35,61,51,52)
 add_new_coin(50,55,83,61)
end

function new_screen()
	if current!=(mapx+1)*(mapy+1) then
		scan_and_place()
		current=(mapx+1)*(mapy+1)
	end
end

local screenx=0
local screeny=0
local tilex=0
local tiley=0
function scan_and_place()
	for i=0,255 do
	 tilex=mapx+screenx
	 tiley=mapy+screeny
  if mget(tilex,tiley)==89 then
   add_new_platform(tilex,tiley)
   mset(tilex,tiley,0)
  end
   
  if mget(tilex,tiley)==69 then
   add_new_switch(tilex,tiley)
   mset(tilex,tiley,0)
  end
  
  if mget(tilex,tiley)==74 then
   add_new_rock(tilex,tiley)
   mset(tilex,tiley,0)
  end
  
  if mget(tilex,tiley)==75 then
   add_new_feather(tilex,tiley)
   mset(tilex,tiley,0)
  end
  
  if mget(tilex,tiley)==85 then
   add_new_key(tilex,tiley)
   mset(tilex,tiley,0)
  end
  
  screenx+=1
  if screenx>15 then
   screenx=0
   screeny+=1
  end
 end
 
 screenx=0
 screeny=0

end

--particle system
function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f)
 add(dust, {
  fade=_f,
  x=_x,
  y=_y,
  dx=_dx,
  dy=_dy,
  life=_l,
  orig_life=_l,
  rad=_s,
  col=7, --set to color
  grav=_g,
  draw=function(self)
   --this function takes care
   --of drawing the particle
        
   --clear the palette
   pal()
   palt()
        
   --draw the particle
   circfill(self.x,self.y,self.rad,self.col)
  end,
  update=function(self)
   --this is the update function
        
   --move the particle based on
   --the speed
   self.x+=self.dx
   self.y+=self.dy
   --and gravity
   self.dy+=self.grav
        
   --reduce the radius
   --this is set to 90%, but
   --could be altered
   self.rad*=0.9
        
   --reduce the life
   self.life-=1
        
   --set the color
   if type(self.fade)=="table" then
    --assign color from fade
    --this code works out how
    --far through the lifespan
    --the particle is and then
    --selects the color from the
    --table
    self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]
   else
    --just use a fixed color
    self.col=self.fade            
   end
         
    --if the dust has exceeded
   --its lifespan, delete it
   --from the table
   if self.life<0 then
    del(dust,self)
   end
  end
 })
end

function add_new_coin(_x,_y,_px,_py)
 add(coins,{
  x=_x*8,
  y=_y*8,
  px=_px*8,
  py=_py*8-8,
  draw=function(self)
   spr(48,self.x,self.y,1,1,false)
  end,
  update=function(self)
   if sprcollide(self,p) then
    del(coins,self)
    sfx(48)
    new_start(self.px,self.py)
    add_new_dust(self.x+3,self.y+4,0,0,10,10,0,10)
    p.trans=true
    current_level+=1
   end
  end
 })
end

function add_new_switch(_x,_y)
 add(switches, {
  x=_x*8,
  y=_y*8,
  h=8,
  w=8,
  sp=69,
  obj="switch",
  up=true,
  draw=function(self)
   spr(self.sp,self.x,self.y,1,1,false)
  end,
  update=function(self)
   if collide_sprite(self,"switch",p) then
    self.sp=70
    if self.up then
     replace_tiles()
     sfx(46)
    end
    self.up=false
   else
    self.sp=69
    if not self.up then
     sfx(47)
    end
    self.up=true
   end
  end
 })
end

local screenx=0
local screeny=0
local tilex=0
local tiley=0
function replace_tiles()
 for i=0,255 do
  tilex=mapx+screenx
  tiley=mapy+screeny
  if switch=="red" then
   if mget(tilex,tiley)==88 then
    mset(tilex,tiley,87)
   end
   
   if mget(tilex,tiley)==71 then
    mset(tilex,tiley,72)
   end
  elseif switch=="blue" then
   if mget(tilex,tiley)==87 then
    mset(tilex,tiley,88)
   end
  
   if mget(tilex,tiley)==72 then
    mset(tilex,tiley,71)
   end
  end
  
  if not green then
  	if mget(tilex,tiley)==104 then
    mset(tilex,tiley,103)
    for i=0,3 do
     add_new_dust((mapx*8+screenx*8)+rnd(8),(mapy*8+screeny*8)+rnd(8),rnd(1)-0.5,rnd(1)-0.5,rnd(20)+10,rnd(4)+1,0,11)
    end
    for i=0,2 do
     add_new_dust((mapx*8+screenx*8)+rnd(8),(mapy*8+screeny*8)+rnd(8),rnd(1)-0.5,rnd(1)-0.5,rnd(20)+10,rnd(2)+1,0,11)
    end
    for i=0,2 do
     add_new_dust((mapx*8+screenx*8)+rnd(8),(mapy*8+screeny*8)+rnd(8),rnd(1)-0.5,rnd(1)-0.5,rnd(10)+10,rnd(2)-1,0,11)
    end
   end
  elseif green then
  	if mget(tilex,tiley)==103 then
    mset(tilex,tiley,104)
   end
  end
  
  screenx+=1
  if screenx>15 then
   screenx=0
   screeny+=1
  end
 end
 
 screenx=0
 screeny=0
 
 if switch=="red" then
  switch="blue"
 elseif switch=="blue" then
  switch="red"
 end
end

function add_new_rock(_x,_y)
 add(rocks, {
  obj="rock",
  x=_x*8,
  y=_y*8,
  startx=_x*8,
  starty=_y*8,
  h=8,
  w=8,
  dy=0,
  max_dy=3,
  landed=true,
  landed_flip=false,
  do_landed_flip=false,
  landed_once=false,
  draw=function(self)
   spr(74,self.x,self.y,1,1,false)
   if self.do_landed_flip then
    if self.landed_once then
     add_new_dust(self.x+4,self.y+8,1,-0.1,12,3,0,7)
     add_new_dust(self.x+4,self.y+8,-1,-0.1,12,3,0,7)
     add_new_dust(self.x+4,self.y+6,0.5,-0.1,14,4,0,7)
     add_new_dust(self.x+4,self.y+6,-0.5,-0.1,14,4,0,7)
     shake+=0.2
     self.do_landed_flip=false
    end
    self.do_landed_flip=false
    self.landed_once=true
   end
  end,
  update=function(self)
   self.dy+=gravity
   if collide_map(self,"down",0) then
    self.dy=0
    self.landed=true
    self.y-=((self.y+self.h+1)%8)-1
    if not self.landed_flip then
     self.landed_flip=true
     sfx(49)
     self.do_landed_flip=true
    end
   else
    self.landed=false
    self.landed_flip=false
   end
   
   if self.dy>4 then
    self.dy=4
   end
   self.y+=self.dy
  end
 })
end

function add_new_feather(_x,_y)
 add(feathers, {
  obj="feather",
  x=_x*8,
  y=_y*8,
  startx=_x*8,
  starty=_y*8,
  h=10,
  w=8,
  dy=0,
  max_dy=-1,
  anim=0,
  anim_end=0,
  draw=function(self)
   spr(75,self.x,self.y,1,1,false)
  end,
  update=function(self)
   self.dy-=gravity
   if collide_map(self,"up",0) then
    self.dy=0
   end
   if self.dy<-1 then
    self.dy=-1
   end
   self.y+=self.dy
   if collide_sprite(self,"feather_up",p)
   and not collide_map(p,"up",0)
   and not p.init_jumping then
    p.dy+=self.dy
   end
   if time()-self.anim>((rnd(4))/10) then
    self.anim=time()
    if self.dy<-0.1 then
     add_new_dust(self.x+1+rnd(6),self.y+4,0,rnd(1)+self.dy,8,2,0.1,7)
    else
     add_new_dust(self.x+1+rnd(6),self.y+4,0,rnd(1),8,2,0.1,7)
    end
   end
  end
 })
end

function add_new_env_dust(_x,_y,_dx,_dy)
 add(env_dust, {
  x=_x,
  y=_y,
  dx=_dx,
  dy=_dy,
  rad=0.9,
  col=7, --set to color
  draw=function(self)
   --this function takes care
   --of drawing the particle
        
   --clear the palette
   pal()
   palt()
        
   --draw the particle
   circfill(self.x,self.y,self.rad,self.col)
  end,
  update=function(self)
   --this is the update function
        
   --move the particle based on
   --the speed
   self.x+=self.dx
   self.y+=self.dy
        
         
    --if the dust has exceeded
   --its lifespan, delete it
   --from the table
   if self.x<mapx then
    del(env_dust,self)
   end
  end
 })
end

local env_time=0
function add_env_dust()
 if time()-env_time>0.7 then
  env_time=time()
  add_new_env_dust(mapx*8+128,mapy*8+rnd(127),rnd(2)-2,1)
  add_new_env_dust(mapx*8+rnd(127),mapy*8,rnd(2)-2,1)
 end
 
 if load_lvl then
  --5
  for i=0,5 do
   add_new_env_dust(mapx*8+rnd(127),mapy*8+rnd(127),rnd(2)-2,1)
  end
  load_lvl=false
 end
end

function do_shake()
 shakex=16-rnd(32)
 shakey=16-rnd(32)
 

 shakex*=shake
 shakey*=shake
 
 shake = shake*0.9
 if (shake<0.05) shake=0
end

local screenx_anim=0
local screeny_anim=0
local current=0
local tilex=0
local tiley=0
function replace_tiles_anim(first,middle,last)
 for i=0,255 do
  tilex=mapx+screenx_anim
  tiley=mapy+screeny_anim
  if middle==0 then
   if mget(tilex,tiley)==first then
    mset(tilex,tiley,last)
   elseif mget(tilex,tiley)==last then
    mset(tilex,tiley,first)
   end
  else
   if mget(tilex,tiley)==first then
    mset(tilex,tiley,middle)
   elseif mget(tilex,tiley)==middle then
    mset(tilex,tiley,last)
   elseif mget(tilex,tiley)==last then
    mset(tilex,tiley,first)
   end
  end
  
  screenx_anim+=1
  if screenx_anim>15 then
   screenx_anim=0
   screeny_anim+=1
  end
 end
 
 screenx_anim=0
 screeny_anim=0
end

function add_new_platform(_x,_y)
	add(platforms, {
  obj="platform",
	 x=_x*8,
	 y=_y*8,
	 h=8,
	 w=8,
	 sp=89,
	 max_sp=92,
	 anim=0,
	 collide=true,
	 crumble=false,
	 draw=function(self)
	  spr(self.sp,self.x,self.y,1,1,false)
	 end,
	 update=function(self)
	  if collide_sprite(self,"tall_up",p) then
	  	self.crumble=true
	  	if time()-self.anim>0.15 then
	  		self.anim=time()
	  		self.sp+=1
	  		self.crumble=false
	  	 add_new_dust(self.x+1+rnd(6),self.y+4,0,rnd(1),12,2,0.1,4)
				end
			else
			 if self.crumble then
			  if self.sp<self.max_sp then
			 	 add_new_dust(self.x+1+rnd(6),self.y+4,0,rnd(1),12,2,0.1,4)
			 	 self.sp+=1
			 	end
			 	self.crumble=false
    end
			 self.anim=time()
   end
   if self.sp>=self.max_sp then
	  	self.sp=self.max_sp
	  	self.collide=false
	  else
	  	self.collide=true
	  end
	 end,
	})
end

function add_new_key(_x,_y)
	add(keys, {
  obj="key",
	 x=_x*8,
	 y=_y*8,
	 h=8,
	 w=8,
	 sp=85,
	 collected=false,
	 draw=function(self)
	  spr(self.sp,self.x,self.y,1,1,false)
	 end,
	 update=function(self)
	  if sprcollide(self,p)
	  and not self.collected then
    sfx(53)
     local p_length=16
     for i=0,2 do
      add_new_dust(self.x+rnd(8),self.y+rnd(8),0,0,p_length,rnd(2)+2,0,11)
      p_length-=2
     end
					self.collected=true
     green=false
    if switch=="blue" then
    	switch="temp"
    	replace_tiles()
    	switch="blue"
    elseif switch=="red" then
    	switch="temp"
    	replace_tiles()
    	switch="red"
    end
   end
   if self.collected then
   	self.sp=86
   end
	 end,
	})
end

local screenx_orange=0
local screeny_orange=0
function orange_tile_anim()
 for i=0,255 do
  
  if mget(mapx+screenx_orange,mapy+screeny_orange)==105 then
   add_new_dust((mapx*8+screenx_orange*8)+rnd(8),(mapy*8+screeny_orange*8)+rnd(8),0,0.2,20,rnd(2)-1,0,9)
  end
  
  screenx_orange+=1
  if screenx_orange>15 then
   screenx_orange=0
   screeny_orange+=1
  end
 end
 screenx_orange=0
 screeny_orange=0
end

local screenx_clock=0
local screeny_clock=0
function check_for_clock()
 for i=0,255 do
  
  if mget(mapx+screenx_clock,mapy+screeny_clock)==119 then
   has_clock=true
   clockx=mapx+screenx_clock
   clocky=mapy+screeny_clock
  end
  
  screenx_clock+=1
  if screenx_clock>15 then
   screenx_clock=0
   screeny_clock+=1
  end
 end
 screenx_clock=0
 screeny_clock=0
end

function clock_anim()
 if has_clock then
 	clocksp+=1
 	if clocksp>126 then
 		clocksp=119
		end
		mset(clockx,clocky,clocksp)
		if clocksp==119
		or clocksp==123 then
			replace_tiles()
   sfx(46)
		elseif clocksp==121
		or clocksp==125 then
		 sfx(50)
		end
 end
end

function secret()
	if p.x>91*8
	and p.x<93*8
	and p.y>27*8
	and p.y<29*8 then
		sfx(58)
		print("yug loves to hear the \nrushing of water \ncoming from the nearby \ncaves, its \nespecially calming \nthis early in the \nmorning...",85*8-1,26*8-1,3)
	end
end

sync = (function()
  local speed = 16 -- can be hardcoded for this project
  local prev_elapsed = 0 -- ticks elapsed in current note

  function execute(f) f() end

  local callbacks = {
    [16] = {}, [8] = {}
  }

  return {
    on = function(note_length, f)
      add(callbacks[note_length], f)
    end,

    off = function(note_length, f)
      del(callbacks[note_length], f)
    end,

    update = function()
      tick = stat(26)
      elapsed = tick % speed
      if elapsed < prev_elapsed then
        -- new beat has begun
        beats = flr(tick / speed)
        foreach(callbacks[32], execute)
        if (beats % 2 == 0) foreach(callbacks[16], execute)
        if (beats % 4 == 0) foreach(callbacks[8], execute)
        --if (beats % 8 == 0) foreach(callbacks[4], execute)
        --if (beats % 16 == 0) foreach(callbacks[2], execute)
        --if (beats % 32 == 0) foreach(callbacks[1], execute)
      end
      prev_elapsed = elapsed
    end
  }
end)()
-->8
--end sequence

local clock_in_anim=0
local clock_in_opt=false
local blink_time_anim=0
local blink_time=0
local do_once=true
function end_sequence_draw()
 if end_game then
 	end_player()
 	
 	if end_game_time>1 then
 		if time()-blink_time_anim>0.5
 		and blink_amt<2 then
 			blink_time_anim=time()
 			blink_sp=32
 			blink_amt+=1
 			sfx(51)
			 	blink_time=0
			else
			 blink_time+=1
			 if blink_time>3 then
			 	blink_sp=1
    end
			end
		end
 	
 	if end_game_time>3 then
 		if do_once 
 		and end_game_time<4 then
 			do_once=false
 			sfx(52)
			end
			if end_game_time>4
			and end_game_time<6 then
				do_once=true
			end
			if timer<30
			and deaths==0 then
			 print("first sub 30 deathless runner name here",80*8+4,49*8,14)
			elseif current_level<29
			and timer<120 then
				print("you must be cheating...",80*8+4,49*8,14)
			elseif timer<60
			and deaths==0
			and current_level==29 then
			 print("first sub 1 deathless/warpless runner name here",80*8+4,49*8,14)
			elseif timer<80
			and deaths==0
			and current_level==29 then
			 print("rank a",80*8+4,49*8,14)
			elseif timer<90
			and deaths==0
			and current_level==29 then
			 print("rank b",80*8+4,49*8,8)
			elseif timer<105
			and deaths==0
			and current_level==29 then
			 print("rank c",80*8+4,49*8,10)
			elseif timer<120
			and deaths==0 then
				print("i deserve a raise...",80*8+4,49*8,7)
			elseif timer<120 then
 		 print("ahhh, clocked in early...",80*8+4,49*8,7)
		 elseif deaths==0 then
		 	print("safe and sound...",80*8+4,49*8,7)
   else
    print("what a good start to the day...",80*8+4,49*8,7)
   end
		end
 	if end_game_time>6 then
 	 if do_once 
 		and end_game_time<7 then
 			do_once=false
 			sfx(52)
			end
			if end_game_time>6.5
			and end_game_time<7.5 then
				do_once=true
			end
 		print("time: "..timer_format,82*8+4,51*8,7)
 	end
 	if end_game_time>7 then
 	 if do_once 
 		and end_game_time<8 then
 			do_once=false
 			sfx(52)
			end
			if end_game_time>7.5
			and end_game_time<8.5 then
				do_once=true
			end
 		print("teleports: "..teleports,82*8+4,52*8,7)
 	end
 	if end_game_time>8 then
 	 if do_once 
 		and end_game_time<9 then
 			do_once=false
 			sfx(52)
			end
			if end_game_time>8.5
			and end_game_time<9.5 then
				do_once=true
			end
 		print("deaths: "..deaths,82*8+4,53*8,7)
 	end
 	if end_game_time>11 then
 	 --print("thanks for playing!",82*8+4,54*8,7)
 	end
 end

	if p.x/8>87
	and p.x/8<90
	and p.y/8>58
	and p.y/8<61 then
	 if not end_game then
	  if time()-clock_in_anim>0.5 then
	 	 clock_in_opt=not clock_in_opt
	 	 clock_in_anim=time()
   end
	  if clock_in_opt then
	  	print("press    to clock in",83*8+4,51*8,7)
    print("      —",83*8+4,51*8,6)
    print("      —",83*8+4,51*8-1,7)
   else
    print("      ’",83*8+4,51*8,6)
	   print("press — to clock in",83*8+4,51*8,7)
   end
  end
	end
end

function end_sequence_update()
 if end_game then
 	if time()-end_game_timer>0.5 then
 		end_game_timer=time()
 		end_game_time+=0.5
		end
 end

	if p.x/8>87
	and p.x/8<90
	and p.y/8>58
	and p.y/8<61 then
 	if btnp(—) then
   	end_game=true
   	cutscene=true
  end
 end
end

function end_player()
	spr(blink_sp,88*8+4,60*8,1,1,true)
end
-->8
--start sequence

local p_length=26
function start_sequence_update()
 if start_game then
  if time()-start_game_time>0.5 then
   start_game_time=time()
   start_game_timer+=0.5
  end
  
  if start_game_timer>9 then
  	cutscene=false
  	blink_sp=1 --32
   blink_amt=0
   blink_time=0
  	if not restart then
  	 start_game=false
  	end
  	sfx(40)
  	for i=0,9 do
  	add_new_dust(p.x+rnd(16)-4,p.y+rnd(16)-4,0,0,p_length,1,0,12)
   p_length-=2
   end
  end
 end
end

local sfx1=false
local sfx2=false
local sfx3=false
local sfx4=false
function start_sequence_draw()
	title_anim()
	if start_game then
	 
	 if start_game_timer>2.5 then
			spr(16,3*8+4,7*8+4,1,1)
			if not sfx1 then
			 sfx(54)
			 sfx1=true
		 end
		end
		if start_game_timer>3 then
			spr(58,3*8+4,7*8+4,1,1)
			if not sfx2 then
			 sfx(55)
			 sfx2=true
		 end
		end
		if start_game_timer>3.5 then
			spr(59,3*8+4,7*8+4,1,1)
			if not sfx3 then
			 sfx(56)
			 sfx3=true
		 end
		end
		if start_game_timer>4 then
			spr(60,3*8,7*8,2,1)
			if not sfx4 then
			 sfx(57)
			 sfx4=true
		 end
			if start_game_timer>5 then
				spr(blink_sp,3*8+2+p_move/2,8*8-2-p_move,1,1,false)
			 if p_move_max<5 then
			 	p_move_max+=1
			 	p_move+=1
    end
    
    if start_game_timer>7 then
    	if time()-blink_time_anim>0.5
 	   and blink_amt<2 then
 		  	blink_time_anim=time()
 		   blink_sp=32
 	   	blink_amt+=1
 			  sfx(51)
			  	blink_time=0
			  else
			   blink_time+=1
			  if blink_time>3 then
			  	blink_sp=1
     end
			 end
			end
		end
			spr(46,3*8,7*8,2,2)
		end
	end
end

local tx=-1
local ty=80
local ty1=0
local ty2=-40
local ty3=-80
local ty_anim=0
local ty_anim_count=0
function title_anim()
 
 ty*=0.95
 
 if start_game_timer<2 then
 	ty2*=0.95
 	ty3*=0.95
 end

 if time()-ty_anim>0.1
 and start_game_timer>1.5 then
  ty_anim_count+=1
  ty_anim=time()
  if ty_anim_count%20==1 then
  	ty1+=1
  	ty2-=1
  elseif ty_anim_count%20==3 then
  	ty1+=1
  	ty2-=1
  elseif ty_anim_count%20==6 then
  	ty3+=1
  elseif ty_anim_count%20==8 then
  	ty3+=1
  elseif ty_anim_count%20==11 then
  	ty1-=1
  	ty2+=1
  elseif ty_anim_count%20==13 then
  	ty1-=1
  	ty2+=1
  elseif ty_anim_count%20==16 then
  	ty3-=1
  elseif ty_anim_count%20==18 then
  	ty3-=1
  end
 end
 --p
	spr(18,32+tx,10-ty+ty1,2,2)
	spr(50,32+tx,26-ty+ty1)
 --o
 spr(20,47+tx,18-ty+ty2,2,2)
 --r
 spr(51,59+tx,25-ty+ty3,2,1)
 --t
 spr(22,69+tx,10-ty+ty1,1,3)
 --e
 spr(39,78+tx,16-ty+ty2,2,2)
 --r
 spr(51,89+tx,24-ty+ty3,2,1)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff
00700700007070000070700000707000007070000070700000707000070700000707000000000000000000000000000000000000fffc2fffffffffffffffffff
00077000007777000077770000777700007777000077770000777700007777700077770000000000000000000777770000000000ffcc2fffffffffffffffffff
00077000007707700077077000770770007707700077077000770770007707000077070000000000000000777777777770000000ffcc2fffffffffffffffffff
00700700007777000077770000777700007777000077770000777700007777000077777000000000000077777777777777700000ffcc2fffffffffffffffffff
00000000007777000077770000777700007777000077770000777700007777000077770000000000000777777770777777770000ffcc2ffffffc2fffffffffff
00000000007006000070060000067000006007000007600000700600006070000006070000000000007777770070700777777000ffcc2fffffcc2fffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000007777007070707007777000ffccccc2ffcc2ffcffcc2fff
00000000000000000000077777700000000000000000000000000000000000000000000000000000007700777070707770077000ffcccccc2fcc2fccffcc2fff
00000000000000000000777777777700000000000000000000000000000000000000000000000000007707777070707777077000ffcc2fcc2fcc2fccffcc2fff
000cc000000110000007777777777770000000000000000000000000000000000000000000000000007707777070707777077000ffcc2fcc2fcc2fccffcc2fff
000cc000000110000007777777777770000000000000000000000000000000000000000000000000007707777070707777077000ffcccccc2fcc2fcccccc2fff
00000000000000000077777700077777000000000000000000000000000000000000000000000000007700000070700000077000ffccccc2ffcc2fcccccc2fff
00000000000000000077777000007777000000000000000000000070000000000000000000000000007777777770777777777000fff2222ffff2fff22222ffff
00000000000000000077770000007777000777777000000000000770000000000000000000000000007777777770777777777000ffffffffffffffffffffffff
00000000000000000077770000007777007777777700000000000770000000000000000000000000007777000070700007777000000000000000000000000000
00000000000000000077770000077777077770077700000000007700000000000000000000000000007700777070707770077000000000000000000000000000
00707000000000000077777000777770077700007770000000007700000000000000000000000000007707777070707777077000000000000000c00000000000
0077770000100010077777777777777007700000777000000000770000000000000000000000000000770777707070777707700000000000000cc00000000000
007777701000100007777777777777707770000777700000000077000000000000000000000000000077077770707077770770000000000000ccc00000000000
007777000000000007777777777770007777007777000000000077000000000000000000000000000077000000707000000770000000000000ccc00000000000
00777700000000000777777777770000077777777000000077707700000000000000000000000000007777777770777777777000000000000ccccc0000000000
00700600000000000777777700000000007777770000000077777700000777770000000000000000007777777777777777777000000000000cccccc000000000
000000000000000077777700007700000000000000000000007777770077777770000000000000000000000000cccc0000000000000000000cccccccccccccc0
00000000000010007777770007777777000000000000000000077777077700007700000000000000000000000cccccc0000000cccc0000000cccccccccccccc0
000aa000000000007777770007777777700000000000000000077007077000077700000000000000000cc000cccccccc00000ccccccc000000cccccccccccc00
00a0aa0000010000777770000777007770000000000000000077700077777777700000000000000000cccc00cccccccc00000cccccccc00000cccccccccccc00
00aa0a0000000000777770007770000770000000000000000077000077077777000000000000000000cccc00cccccccc00000ccccccccc00000cccccccccc000
000aa000000010007777700077700000000000000000000000770000777000000000000000000000000cc000cccccccc00000ccccccccc000000cccccccc0000
00000000000000007777000077000000000000000000000000770000077777000000000000000000000000000cccccc0000000ccccccccc0000000cccc000000
000000000001000007700000770000000000000000000000007000000077777000000000000000000000000000cccc000000000cccccccc00000000000000000
00000000000000000000000000000000700000070000000000000000011111100cccccc000000000000000000000000000000000000000000000000000000000
0000000000000000000000000700000077070707000000000000000010000001c000000c00000000000000000000000700000000000000000000000000000000
0000000000000000000000000070000070700077000000000000000010000001c000000c00000000007777000000076500000000000000000000000000000000
0000000000000000000000000000000070007007000000000000000010010001c00c000c00000000077077605067675700000000000000000000008000800000
0000000000070070070000000000000070070007000000000000000010001001c000c00c00000000070777600555557000000000000000000080088008800080
0000007007000700000000000000070070000077000000000000000010000001c000000c00000000077776600076760000000000000000000880088008800880
0000707000700070077000000000007077000707066665500000000010000001c000000c00000000077776600000000000000000000000000880088008800880
00000007777777777000000000000000707000070666666006666550011111100cccccc000000000007766000000000000000000000000000880088008800880
00000007000000007000000000000000777777770000000000000000022222200888888004444440044444400444444000000000000000000000000000000000
00007077000000007070000000000000070000700000000000000000200000028000000844404444444044444040444400000000000080000000080000080000
00000707000000007700000000000000700007000bbb0b0000000000200000028000000844440444044404400004040000000000000880000880880000880800
00000007000000007007000000070000000700700b3bbbb000000000200200028008000804444440004040000000000000000000088888000088800000088880
00007007000000007000000000007000000070000bbb333000000000200020028000800800000000000000000000000000000000008888800008880008888000
00000077000000007070000000000000070000700333000000000000200000028000000800000000000000000000000000000000000880000088088000808800
00000707000000007707000000000000007007000000000000000000200000028000000800000000000000000000000000000000000800000080000000008000
00000007000000007000000000000000777777770000000000000000022222200888888000000000000000000000000000000000000000000000000000000000
00000007777777777000000077777777777777777777777777777777033333300bbbbbb000000000000000000000000000000000000000000000000000000000
0000077007000700070700007070070007000707707000700700070730000003b000000b00000090000000000000000000000000000000000000000000000000
0000000000700070070000007700007000700077770007000070007730000003b000000b00900900000000000000000000000000000000000000000000000000
0000007007007000000000007007070007007007700700700700700730030003b00b000b09000000000000000000000000000000000000000000000000000000
0000000000000000000000007000000000000007700070000007000730003003b000b00b00000000000000000000000000000000000000000000000000000000
0000000000000000000000007070000000007077770000700700007730000003b000000b00009000000000000000000000000000000000000000000000000000
0000000000000000000000007707000000000707707007000070070730000003b000000b00090000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000077777777777777777033333300bbbbbb000000000000000000000000000000000000000000000000000000000
00000000777777776666666670000000000000070000000770000000007770000077700000777000007770000077700000777000007770000077700000000000
0000000077777777666666667070000000007077000007700770000007080700070007000700070007000700070c070007000700070007000700070000000000
0000000077777777666666667707000000000707000000000000000070080070700000707000007070000070700c007070000070700000707000007000000000
0000000077777777666666667000000000000007000000700700000070080070700888707008007078880070700c0070700ccc70700c00707ccc007000000000
00000000777777776666666670070070007070070000000000000000700000707000007070080070700000707000007070000070700c00707000007000000000
00000000777777776666666677700700070000770000007007000000070007000700070007080700070007000700070007000700070c07000700070000000000
00000000777777776666666670000070007007070000707007070000007770000077700000777000007770000077700000777000007770000077700000000000
00000000777777776666666677777777777777770000000770000000000000000000000000000000000000000000000000000000000000000000000000000000
07070414142404141414240707070707070707070707070734070707070707070414140414141414141414141414142415151535150414142435041414241515
15151515341535151515151515351515151515153415151515151515351515153515151515151515151515153415001515041414142414141424153415151515
07070500002505000000250707073507070704141424041414240707070707070500004400000000000000000000002515151515150500002515050000251515
15041414141414141414241515151515041424041414142404141414141414241515151535150414141414141414142415050000004400000025041414142415
070705000025050000002507070707073507050000250500002507070707070705000044000000d5d50000000000002515041414240616162615050000253415
35050000000000000000251515341515050025050000002505000000000000251515151515150500000000000000002535050000004400000025050000002515
070706161626050000002507070707070707061616260500002504141424350706161605000000d5d5000000d5d5002515050055251515350414470000251515
15050000000000000000371414142415050025050000002505000000000000251515341515150500000000000055002515061616160500000025050000002515
0707070707070500000025070734070707070707070705000025050000250707070707050000000000000000d5d5002515050000251577150500000000251515
15050000000000000000000000002515061626050095002505000000000000251515151515150500000000000000002515151515150500950025050000002535
0707070735070500000025350707070707070707070705000025050000250707350707050000000000d5d5000000002534057400251515150500000000251515
15061616460000000000000000002515151515050000002505000095000000251504141424150500000000005645456715151515150500000025050074002515
0734070707070500000025070707070707070707350705d5d525061616260707070734050000000000d5d5000000002515050000251504144700000000251515
1515153505009500000000000000251515351505e4e4e42505e4e4e4e400002515050086251505000000000000000025151515771505e4e4e425050000002515
0707070707070500000025070707070707340707070705d5d5250707070707070707070500d5d5d5d50000000000002515050000253405000000000000251515
1515151505000000950000005645671515151506161616260616161646000025350586862515050000d500000000002515151515155745454567050000002515
07070707070705000000250414142407070707070707050000250414142407070707070500d5d5d5d50000000000002515050000251505000000000000251515
3404141447000000000000000000251504141414141414241414142405000025150616162615050000d500009500002515153415150500000025050000002515
07070414142405000000250500002507070707070707050000250500002507070414144700000000000000000000002515057400251505000000000000251515
1505000000000000000000000000251505000000000000440000002505000025151504141424050000d500000000002515041414140574747425061616162615
07070500002505000000250500542507070414142407050000250500002534070500000000000000000000000000002515050000251506164600000000251535
1505000000000000000000000000253505000000000000440000002505000025151505000037470000d500000000002515050000004400000025151515151515
07070500002505000000250616162607070500002507050000250616162607070500005400000000000000000000002535050000251515150500000000251515
1505000000000000000000000000251505000000000000440095002505000025351505000000000000d500000000002535050000004400000025151515341515
07070616162606468536260707070707070500542507050000250707070707070616164600858585858585858585002515050000251515150586868686251515
1506161646009500950095003616261506164600950000440000002505950025151505000000000000d500009500002515050000004400000025151515151515
07070707070707058525070707340707070500362607058585250734070707070707070500b4b4b4b4b4b4b4b4b40025150616162615151505b4b4b4b4251534
1515151505e4e4e4e4e4e4e425341515151505e4e4e4e444e4e4e42505e4e4251515061646009500000000000000002515061616160500950025151515151515
0707073507070705b42507070707070707061635070705b4b42507070735073407350705e4e4e4e4e4e4e4e4e4e4e425151515151535151505e4e4e4e4251515
15351515061616161616161626153515153506161616162616161626061616261515341505e4e4e4e4e4e4e4e4e4e425150000000005e4e4e425153515151515
07070707070707061626070707070707070707070707061616260707070707070707070616161616161616161616162615151515151515150616161616261515
15151515151535151515151515151515151515151534151515151515341515151515151506161616161616161616162615341515150616161626151515151515
07070707070707070707073507070707070707070707070707070707070707070707070707070707070707070707070707070707070707350707070707070707
07070707070707070707070707070707151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
07073507070707070707070707070707073507070707070707340707070707070707070707070707070735041414142407041414141414141414141414142407
07868686868686868686868686868607151515151515151515151515151515151586868686868686868686868686868615151515151515151515151515151515
07070707070735070707070707340707070707350707070707070707070707070707340707070707070707050055002507059696969696969696969696962534
07868686868686868686868686868607151515151515151515151515151515151586868686868686868686868686868615151515151515151515151515151515
07070704141414141414141424070707070414141414141414141414141424070707070707070707070707050000002507059696969696969696969696962507
07868686868686868686868686868607151515151515151515151515151515151586868686868686868686868686868615151515151515151515151515151515
07070705969696969696969625070707070500000000009696969696000025070707070707070735070707061616162607059696969696969696969696962507
07868686868686868686868686868607151515151515151515151515151515151586868686868686868686868686868615151515151515151515151515151515
07070705969696969696969625070707070500000000009696969696000025070704141414240704141414041414142407061616164696749685967496962507
07868686868686868686868686868607151515151515151515151515151515151586868686868686868686868686868615151515151515151515151515151515
07070705969696969696969625070707070500000000009696969696000025070705000000250705000000440000002534041414240596969696969696962535
07868686868686868686868686868607151515151515151515151515151515151586868686868686868686868686868615151515151515151515151515151515
070707061616161646969696250707073505000000000096969696963616260707050000002507050000004400000025070500002505e4e4e4e4e4e400002507
07868686868686868686868686868607151515351515151515153515151515151586868686868686868686868686868615151515151515151515151515151515
34070704141414240500000025073507070500000000009696969596250707070705000000253405000000449696962507050000250616161616164600002507
07868686868686868686868686868607151515151515041414141414141424151586868686868686868686868686868615151515151515151515151515151515
070707050000002505000000250707070706164600000096959696962507070735050036162607059696964496959625070445451414141414240705e4e42507
07868686868686868686868686868607150414141414470000000000000025351586868686868686868686868686868615151515151515151515151515151515
0707070500000025050000002507070707070705000000969696969625070707070500371414144796969644e4e4e42507050000969696969625775745456707
0786868686868686868686868686860715050000000000000000a0b0c00025151586868686868686868686868686868615151515151517151715151515151515
070707050000002505e4e4e42507070707340705e4e4e4e4e4e4e4e4250735070705000000000000969696251616162635050000969696969625070500002507
0786868686868686868686868686860715050000000000000000a1b1c10025151586868686868686868686868686868615151515151517171717151515151515
07070706161616260616161626070707070707061616161616161616260707070706468636161616161616260707070707050000969696969625070500002507
0786868686868686868686868686860735050000000000000000a2b2c20025151586868686868686868686868686868615151515151517171517171515151515
07070707340707070707070707070707070707070707350707070707070707070707050025073507070707070734070707050000859695968525070616162607
07868686868686868686868686868607150500000000000036161616161626151586868686868686868686868686868615151515151517171717151515151515
0735070707070707070707070707070707073507070707070707070734070707073506162607070707070707070707070705e4e4e4e4e4e4e425073507070707
07868686868686868686868686868607150616161616161626151515153415151586868686868686868686868686868615151515151517171717151515151500
07070707070707070707070707340707070707070707070707070707070707070000000000000007070707070707070707061616161616161626070707073407
07868686868686868686868686868607151515153515151515151515151515151586868686868686868686868686868615151515151517151527151515151515
__gff__
0000000000000000000000000000000000000808080808000000000000000000000008080808080000000000000000000000080808000808080000000000000009090909090000000900000000000404090809090900000009000000000404040909090909090900091000000000000009090909090909090909090909090900
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7070707070707070707070707070707070707070707070707070707070707070707053707070707070707070707070707070537070707070707070707070707070707070707070707070537070707070707070707070707070707051515151517053707070707043707070707070707070707070707053707070404141414270
7070537070707070707070704370707070704370707070707070705370707043704041414270705370707070707070707040414141414142534041427070707070707070537070707070707070707070707070707070707070707053707070707040414142704041414141414142705370707070707070707070500000005200
7070707070707070707070707070707070707070707070437070707070707070705000007341427070707043707070707050000000000052705000527070707070707070707070704041414142707070705370704370004041427040414142707050000052705000000000000052707070704370707070537070500000005270
537070707070707070707070707070537070404141414141427070707070707070504e4e4e4e527070707070707070707050000000000052705000527070707070707070707070705000000052707070707070707070005000527050000052707060616162705058580000000052707070707070707070707070606161616270
7070707070707070707070707070707070705000000000007341414141427070706061616161624041414141414142707060616161616162705000527043707070704370707070706061616162707070704041414142705000527050000052707070707070705000000000585852704370707070707070704370707070707070
7040414141414141414270707070707070705000000000000000000000527070707070707070705000000000000052707070707040414270705000527070707070707070707040414141414270707070705000000052705047524360616162707070705370705000000000000073414270537070707077707070404141414253
7050000000000000005270404141427043706061616164000000000000527070704041414141417400000000000052707070704074005270705000527070707070707070707050585858585270707070705000000052705000527070707053707070707070705000000000000000005270707070707070707070500000005270
705000000000000000527050000052707070404141426061616161616162537070500000000000000000000000005270704370504e4e5253705000527070707070704041427050585858585270707070705058585852705000527070707070707070707070705000000000000000455270404141414141414141744747475270
7050000000000000005270500000527070705000005270707040414141427070435000000000000000006561616162707070706061616270705000527070707070705000527050585858585270437070435000000052705000527040414142707040414141417400474700000063616270500000000000000000000000005270
7050000000000000636270606161627070705000005270707050000000527070705000000000000000000052707070707070704041414142705000527070707043706061627060616161616270707070705000000052705000527050000052704350000000000000000000000052707070500000000000000000000000005270
705000000000006362707070707070707070606161627070705000000052707070500000000000000000005270704370707070500000005270500052707070707040414142704041414142707070707070504e4e4e52705047527050004552707050000000000000000000000052705370500000000000000000000000005270
70606161616161627070707070707070707053007070705370606161616270707060616161644e4e4e636162707070707070705000000052705000527070707070500000525350474747527070707070706061616162705000527060616162707050000000450000474700000052707070606161616400585858004747475270
707070707070707070707070707070707070707070707070707070707070707070707070706061616162707040414270707070500000005270500052707070707050450052705047474752707053707070707070707053504e527053707070707060616161616400000000000052707070537070705000000000000000005270
0909097053707070704370707070707070707070707070707070437070707070707070707070707070707070504e5270707053606161616270504e52704370707060616162705047474752707070707070704370707070606162707070437070707043707070504e4e4e4e4e4e5270707070707070504e4e4e4e4e4e4e4e5270
7070703570707070707070707070707070707070705370707070707070707070707070437070707053707070606162707070707070707070706061627070707070707070707060616161627070707070707070705370707070707070707070707070707070706061616161616162707070705370706061616161616161616270
7070703570707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070515151515151515170705370707070707043707070707070707070707070707070707070707070707070707070707070705370707070707070707070707070707070707070437070
7070704041414141414270707070707070707070707070707070707070707070515151515351515151514041425151515151515151435151515151515151515151515151515151515151514041414251515151515153517070404141414142515151515153515151515151515151515151515151515151514041425151515151
705370500000000000527053707070437070707053707070707070537070707051515151515151515151504a52515351515153515151515151404142515143515151515153514041414251500055525151707070707070707050000000555251514041414141425340414141414142515151435151515151504a525151515151
707070500000000000527070707070707070707070707070404142707070707051435140414141414240745873425151515151515151515151504a524041414251515151515150000052435000005251514041414141414141740000000052515350000000005251506868680000525151515151515151515068520053515151
707070500000000000527070777070707043707070705370504a527070437070515151500000000052500000005200515351515151404142515058525000005251514351515150000052517554547651515068686868686868686868686852515150000000005251506868680000525151515151515153515000525151515151
7070706061616458585270707070707070707070707070705058527070707070515151500000450052500000005251515151515151504a52515000526061616251515151515150000052515000005251515000686868000068680000686852515160616161616251606161616161625351404141425151515058525151514351
7043707070705000005270704041414270707053707070705000527070707070515151606161616162500000005251515151515151745873427447734200000051515151535150000052515000005251535068686868686868680000686852435151404141425151515151535151515151500055525177515000525151515151
7070707070535000005270705000005270404141414141417400734270707070515151515151515151504e4e4e524351515151515000000044000000520051515151515151515000005251504e005251515068686868686868680000686852515140740000525151435151515151515151500000525151515047525151515151
70404141414174000052707060616162705000000000000000000052707070705151515151515143516064476362515151514351500000004400000052005151514041414251500000525175545476435150000068686868685d5d00686852515350680000734142514041414141414251606161625140417400734141414251
705000000000000000524370707070707050000000000000000000524041414251515151515151515151500052515151535151515000000044000000520051535150000052515000005251500000525151500000685d5d685d5d5d5d686852515150680000006852515000000000005251404141425150000000000000005251
7050474747474747475270704041414270500000000000000000005250000052515151515151515151515000525151515151515150450000440000005200515151500000525150000052515000005251516061616161616161616161616162515160640000006852515000000000005251500000525350000000006361616251
705000004e4e4e4e4e5270535000005270500000450000000000005260616162515153514041414142515000525151514041414275660000444e4e4e52005151516061616251500000525150004e5251515151515151515151515151515151515151505d0000636253500000000000525350000052515000005d005251515151
705000006361616161627070505858527060616161644e4e4e4e4e5270707070515151515000000052515000525151515000005250000000526161616251515153515151515150000073414154547651514041414251515151515151535151515151505d5d00525151500000004e555251606161625160640058005251515151
705000007341414141414141740000527070707070606161616161627070537051515151500000005251500052515151500045525000000052515151435151515140414142515000000000000000525151506868525151515151515300535151515160645d007341417400000063616251515151515151500000005251515151
70500000474758584747000000000052705370707070705370707070707070705143515150000000525150455251535160616162504e4e4e5251515151515151515068685253500000000000000052535150006852515151515151515351515151435160640000004e4e00000052515151515143515151504e4e4e5251435151
70500000474758584747000000000052707070707070707070707070437070705151515160616161625160616251515151515351606447636251515151515351515000685251504e4e4e4e0000005251516061616251515151515151515151515151515160616161616161616162435151515151515151606161616251515151
7060616161616161616161616161616270707070537070707070707070707070707051515151515151515151515151515151515151606162515151515151515151606161625160616161616161616251515151515151515151515151515151515151515151515153515151515151515151515151515151515151515151515151
__sfx__
351000000405004040040400403004032040220471204712040000400004000000000400004000040000400001050010400104001030010320102201722017120805008040080400803008032080220871208712
351000000605006040060400603006032060220671206712040000400004000000000400004000040000400008050080400804008030080320802208722087120605006040060400603006032060220671206712
cd1000002050020500205002050020540205302052220516235402353023522235162554025530255222551620500205002050020500205402053020522205162354023530235222351625540255302552225516
cd1000001e5001e5001e5001e5001e5401e5301e5221e516205402053020522205162154021530215222151621500215001e5001e5001e5401e5301e5221e516205402053020522205161c5401c5301c5221c516
271000001c7341c7301c7301c7301c7301c7301c7201c7201c7121c7121c7121c7132075120740207302073020722207222071620716197341973019730197301973019730197201972019712197121971219715
271000001c7341c7301c7301c7301c7301c7301c7201c7201c7121c7121c7121c7131975119740197301973019722197221971619716177341773017730177301773017730177201772017712177121771217715
a50a00000061100611006110261102621046210462104621046210562105621056210562105631076310763109631096310963109621096310762107621056210562104611046110461102611026110061104611
a50a00000061100611006110262104621056210562107621076210763105631046310462104621046210462102621026210262102621006210061100611006110061100611006110061100611006110061100611
c61000002802028012250202501228020280122c0202c0122802028012250202501228020280122c0202c0122802028012250202501228020280122c0202c0122802028012250202501228020280122c0202c012
c710000000000000002802028012250202501228020280122c0202c0122802028012250202501228020280122c0202c0122802028012250202501228020280122c0202c012280202801225020250122802028012
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
000100001d2401f230202302422027220292202a2202c21031210290000d0000d000060001300001000010000a00023000050000200023000230002300022000210001f0001e0001e00000000000000000000000
0001000004560035400053000560007002f3003d1003d100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000137301a7501f7602a76000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000105300d5300a5200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d0000035001e5501e5500355003550035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000286401f6301a6301663000620006500265000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000002750195501f55019550247502c7500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001c520225201a5100250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0000120301203017040170401c0501c0501c0501c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000955007540065400454003540025400154000530005000050002500015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002103003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003f7302b710137000310000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001335000300003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001b74034750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000172101a2101c2102420027200292002a2002c20031200290000d0000d000060001300001000010000a00023000050000200023000230002300022000210001f0001e0001e00000000000000000000000
000100001b2201c2201e2102221025210292002a2002c20031200290000d0000d000060001300001000010000a00023000050000200023000230002300022000210001f0001e0001e00000000000000000000000
000100001c2201e2201f2202321026210272102a2002c20031200290000d0000d000060001300001000010000a00023000050000200023000230002300022000210001f0001e0001e00000000000000000000000
000100001d2301f230202302422027220292102a2102c20031200290000d0000d000060001300001000010000a00023000050000200023000230002300022000210001f0001e0001e00000000000000000000000
001000000d6200d620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00 42 43 44
00 01 42 43 44
00 00 02 43 44
00 01 03 43 44
00 00 04 43 44
00 01 05 43 44
00 00 04 43 44
00 01 05 43 44
00 00 02 43 44
00 01 03 43 44
00 00 04 43 44
00 01 05 43 44
00 00 08 43 44
00 01 08 43 44
00 00 08 43 44
02 01 08 43 44
00 04 08 43 44
02 05 08 43 44
01 06 42 43 44
02 07 42 43 44
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
