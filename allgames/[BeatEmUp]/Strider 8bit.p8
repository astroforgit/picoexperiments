pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- strider 8 bit
-- by alonm10

-- vars
-- start 1x30
-- ev 1 96x10
-- ev 2 125x6

-- tele1 73*15
-- tele3 29*1

-- end game 116*56

st_x = 8*8
st_y = 24*8

disclaimer_timer = 0

block_map={}

add(block_map,
 {
  open={
	 	{x=97, y=8},
	 	{x=97, y=9},
	 	{x=97, y=10},
	 	{x=97, y=11},
  },
 
  close={
  	{x=98,  y=12},
  	{x=99,  y=12},
  	{x=100, y=12},
  	{x=101, y=12},
  },
  trigger_id=1,
  spawns={
   {x=105,y=8,type=2},
   {x=104,y=11,type=2},
   {x=103,y=8,type=1},
   {x=102,y=11,type=1},
  },
 }
)

add(block_map,
 {
  open={
	 	{x=126, y=8},
	 	{x=127, y=8},
  },
 
  close={
  	{x=113,  y=29},
  	{x=113, y=30},
  },
  trigger_id=2,
  spawns={
   {x=122,y=30,type=1},
   {x=123,y=30,type=1},
   {x=124,y=30,type=1},
   {x=125,y=30,type=1},
   {x=114,y=30,type=2},
   {x=115,y=30,type=2},
   {x=116,y=30,type=2},
  },
 }
)

add(block_map,
 {
  open={
   {x=89, y=25},
	 	{x=89, y=26},
	 	{x=89, y=27},
	 	{x=89, y=28},
	 	{x=89, y=29},
	 	{x=89, y=30},
  },
 
  close={
  	{x=76, y=26},
	 	{x=76, y=27},
	 	{x=76, y=28},
	 	{x=76, y=29},
	 	{x=76, y=30},
  },
  trigger_id=3,
  spawns={
   {x=77,y=29,type=10},
  },
 }
)

portals = {}
add(portals, {x=72, y=15, t_x=3*8, t_y=2*8, cam_ovr_x=0, cam_ovr_y=0, boss=false})
add(portals, {x=14, y=12, t_x=18*8, t_y=12*8, cam_ovr_x=17*8, cam_ovr_y=0, boss=false})
add(portals, {x=30, y=1, t_x=113*8, t_y=39*8, cam_ovr_x=112*8, cam_ovr_y=32*8, boss=true})
add(portals, {x=-1, y=-1, t_x=121*8, t_y=56*8, cam_ovr_x=110*8, cam_ovr_y=49*8, boss=false})
boss_lines = {}

add(boss_lines, "i shall raise the city ")
add(boss_lines, "upto the sky and rid ")
add(boss_lines, "the earth of all creatures. ")
add(boss_lines, "i will create a race ")
add(boss_lines, "to fill the new earth. ")
add(boss_lines, "all sons of old gods die!!")

--add(boss_lines, "echhh") -- test

boss_flow_pause = false
boss_line_index = 1
speech_text = -1
speech_letter = -1
speech_letter_spacing = 0
speech_next_line_cd=0

boss_flow_death_seq=-1
boss_flow_death_seq_timer=0

background_flicker=false
background_flicker_timer=0

fading=0
fadespeed=30

distance_offset_far = 2
distance_offset_buildings = 3
distance_offset_closer = 4
bg_x=0
bg_x_buildings=0
bg_y_buildings=0

spot_light_state=1
spot_light_state_timer=0

event_tracker=
{
	event_in_progress=0,
	num_of_enemies=0,
	done_events={},
}

tile_timer=0
tile_state=0

hangglider = {
 sp=108,
 x=0,
 y=st_y,
 w=16,
 h=8
}

show_hg = false

function _init()
 player={
 	sp=2,
 	att_sp=16,
 	att_first_sp=17,
 	att_last_sp=21,
 	att_x=0,
 	att_y=0,
 	att_w=8,
 	att_h=2,
 	att_tw=1,
 	att_flp=false,
 	weapon_timer=0,
 	att_offset=4,
 	climb_dir="n",
 	clmb_y=0,
 	clmb_x=0,
 	clmb_cooldown=0,
 	x=st_x,
 	y=st_y,
 	w=8,
 	h=8,
 	flp=false,
 	dx=0,
 	dy=0,
 	max_dx=3,
 	max_dy=3,
 	acc=0.35,
 	boost=3,
 	anim=0,
 	attack_anim=0,
 	running=false,
 	jumping=false,
 	falling=false,
 	landed=false,
 	slashing=false,
 	climbing=false,
 	attacking=false,
 	paused=false,
 	pause_timer=0,
 	is_hit=false,
 	hit_cooldown=0,
 	iit_cooldown=0,
 	attack_rg=false,
 	blink=false,
 	health=3,
 	max_health=6,
 	orbrs=0,
 	orbrs_cooldown=0,
 }
 
 cls()
 init_disclaimer()
 
end

function init_disclaimer()
 cls()
 flow_state="disclaimer"
end

function init_menu()
 cls()
 flow_state="menu"
end

function init_game_over()
 cls()
 flow_state="gameover"
end

function init_level()

flow_state="game"

cls()
print("loading")
 
 -- global physics
 gravity = 0.13
 friction= 0.55
 
 --simple camera
 cam_x=0
 cam_y=0
 cam_ovr_x = -1
 cam_ovr_y = -1
 
 map_start=0
 map_end=1024
 map_end_y=33*8
 
 -- effects
 shake=0
 shakex=0
 shakey=0
 -- level data
 spawn_enemies()
 spawn_pickups()
 
 attack1_first_sp=17
 attack1_last_sp=21
 attack1_w=8
 attack1_h=4
 attack1_tw=1
 
 attack2_first_sp=22
 attack2_last_sp=30
 attack2_w=16
 attack2_h=4
 attack2_tw=2
 
 siren=false
 siren_bs=false
 siren_bm=0
 --set_weapon(2) -- test
 --add_orbrs()
 --remove_orbrs()
 
 -- test
 x1r=0 y1r=0 x2r=0 y2r=0
 col_l="no"
 col_r="no"
 col_u="no"
 col_d="no"
 
 move_order_debug = "l"
 intro_timer = 0
 is_in_intro = true
 
 music(14)
 -- test as well
 --start_siren()
 
 -- test end game
 --teleport(player, portals[4])
end

function spawn_enemies()
	for i=0,128 do
		for n=0,128 do
			local tile = mget(i,n)
			if tile == 49 then
			 fix_tile(i,n)
				create_enemy(i*8,n*8, 1)
			elseif tile == 50 then
			 fix_tile(i,n)
				create_enemy(i*8,n*8, 2) 
			elseif tile == 39 then
			 fix_tile(i,n)
				create_enemy(i*8,n*8, 10)
			end 
		end
	end
end

function spawn_pickups()
	for i=0,128 do
		for n=0,128 do
			local tile = mget(i,n)
			if tile == 33 then
			 fix_tile(i,n)
				create_pickup(i*8,n*8)
			end 
		end
	end
end

function start_siren(silent)
 siren=true
 siren_bs=false
 siren_bm=0
 
 if not silent then
 	sfx(6, 2)
 end
 
end

function stop_siren(silent)
 siren=false
 siren_bs=false
 siren_bm=0
 
 if not silent then
  sfx(-1, 2)
 end
end

function start_boss_flow()
 boss_flow_pause = true
 local text = boss_lines[1]
 speech_text = text
 speech_letter=1
end
-->8
-- game logic

function _update60()
  if flow_state == "disclaimer" then
			disclaimer_loop()
		end
		if flow_state == "menu" then
			menu_loop()
		end
  if flow_state == "game" then
			main_game_loop()
		end
		if flow_state == "gameover" then
			game_over_loop()
		end
		if flow_state == "win" then
			win_loop()
		end
end

function disclaimer_loop()
 disclaimer_timer+=1
 if disclaimer_timer >= 240 then
  fadeout(init_menu)
  --init_menu()
 end
end

function menu_loop()
 if btn(—) and fading <= 0 then
  fadeout(init_level)
  sfx(9)
 end
end

function game_over_loop()
 if btn(—) then
  --init_menu()
  run()
 end
end

function win_loop()
 main_game_loop()
 
 if btnp(—) then
  --init_menu()
  run()
 end
end

function main_game_loop()
 
 update_intro()
 player_update()
	player_animate()
	update_hg()
	update_enemies()
	animate_enemies()
	update_orbrs()
	update_projectiles()
	update_e_projectiles()
	update_hitsparks()
	animate_hitsparks()
	update_worldfx()
	update_camera()
	update_shake()
	update_speech()
	update_animation_tile()
end

function update_intro()
 if is_in_intro then
	 intro_timer+=1
	 if intro_timer == 340 then
	  -- add the hang glider
	  show_hg=true
	 end
	 if intro_timer >= 400 then
	  is_in_intro = false
	  player.x = st_x
	  player.y = st_y
	  music(0)
	 end
 end
end

function update_worldfx()
 siren_bm+=1
 if siren_bm >= 5 then
  siren_bs = not siren_bs
  siren_bm = 0
 end
 
 bg_x = cam_x/distance_offset_far
 bg_x_buildings = cam_x/distance_offset_buildings
 bg_y_buildings = cam_y/distance_offset_buildings
end

function update_speech()
 if boss_flow_pause then
  if speech_next_line_cd >= 30 then
   speech_next_line_cd = 0
   boss_line_index+=1
   if #boss_lines >= boss_line_index then
	   speech_text = boss_lines[boss_line_index]
	   speech_letter_spacing = 0
	   speech_letter = 1
	  else
	   boss_flow_pause = false
	   start_boss_battle()
	  end
  end
  speech_letter_spacing+=1
  if speech_letter_spacing >= 3 then
	  if #speech_text > speech_letter then
	   speech_letter+=1
	   sfx(7)
	  else
	   speech_next_line_cd+=1
	  end
	  speech_letter_spacing = 0
	 end
 end
end


function update_camera()
		
		if cam_ovr_x == -1 and cam_ovr_y == -1 then
	  cam_x = player.x-64+(player.w/2)
			cam_y = player.y-64+(player.h/2)
			if cam_x<map_start then
				cam_x=map_start
			elseif cam_x>map_end-128 then
				cam_x=map_end-128
			end
			if cam_y<map_start then
				cam_y=map_start
			elseif cam_y>map_end_y-128 then
				cam_y=map_end_y-128
			end
		else
		 cam_x = cam_ovr_x
			cam_y = cam_ovr_y
		end
		
		camera(cam_x,cam_y)
		
		if shake > 0 then
			shake-=0.1
			shakex=cam_x+(rnd(8)-4)
  	shakey=cam_y+(rnd(8)-4)

  	camera(shakex,shakey)
 
  	shake = shake*0.95
  	if (shake<0.05) then
  		shake=0
  	end
		end
		
  
end

function fix_tile(tile_x, tile_y)
 target_tile_id=-1
 local tile_right = mget(tile_x+1, tile_y)
 local tile_left = mget(tile_x-1, tile_y)
 local tile_up = mget(tile_x, tile_y-1)
 
 if fget(tile_right) == 0 then
  target_tile_id = tile_right
 elseif fget(tile_left) == 0 then
  target_tile_id = tile_left
 elseif fget(tile_up) == 0 then
  target_tile_id = tile_up 
 end
 
 if target_tile_id != -1 then
  mset(tile_x, tile_y,target_tile_id)
 end
  
  
end

function update_shake()

end

function _draw()
 
 
 if (fading>0) fadeout()
  if fading<0 then
    fading=0
  end
  
 if flow_state == "disclaimer" then
	 draw_disclaimer()
	end
  
	if flow_state == "menu" then
	 draw_menu()
	end
	
	if flow_state == "game" then
	 draw_game()
	end
 
 if flow_state == "gameover" then
	 draw_game_over()
	end

 if flow_state == "win" then
	 draw_win()
	end
	
end

function draw_disclaimer()
 print("strider is a capcom and ", 0, 64)
 print("moto kikaku ip.", 0, 76)
 print("this is a fan game.", 0, 88)
end

function draw_menu()
 camera(0,0)
 print("strider", 48, 64)
 print("press — to start", 30, 76)
 
 spr(43,50,40,3,2)
end

function draw_game_over()
 camera(0,0)
 print("game over", 48, 64)
 print("press — to restart", 30, 76)
end

function draw_win()

 draw_game()
 
 print("the end", cam_x + 20, cam_y + 10, 7)
 print("made by alon mizrahi", cam_x + 20, cam_y + 22, 7)
 print("press — to restart", cam_x + 20, cam_y + 34, 7)
 
end

function draw_background()
	-- draw paralex
	
	map(0,33,bg_x,cam_y,128,128)
	map(0,50,bg_x_buildings,bg_y_buildings + 135 ,128,128)
	
	draw_skylight(80)
	draw_skylight(200)
	draw_skylight(300)
	
	background_flicker_timer+=1
	spot_light_state_timer+=1
	
	if background_flicker_timer >= 1 then
	 background_flicker = not background_flicker
	end
	
	if spot_light_state_timer >= 60 then
	 spot_light_state_timer = 0
	 spot_light_state+=1
	end
	
	if spot_light_state > 3 then
	 spot_light_state = 1
	end
	
end

function draw_skylight(x_offset)
 if background_flicker then
	 if spot_light_state == 1 then
			circfill(x_offset + (cam_x + 30)/distance_offset_closer,cam_y + 30,10,10)
			--rectfill(cam_x, cam_y + 90, cam_x + 45, cam_y + 30, 10)
			line(x_offset + (cam_x/distance_offset_closer) ,cam_y + 128 ,(x_offset + (cam_x + 15)/distance_offset_closer), cam_y + 30, 10)
			line(x_offset + ((cam_x + 5)/distance_offset_closer),cam_y + 128 ,x_offset + ((cam_x + 45)/distance_offset_closer), cam_y + 30, 10)
		elseif spot_light_state == 2 then
		 circfill(x_offset + (cam_x + 60)/distance_offset_closer,cam_y + 30,10,10)
			--rectfill(cam_x, cam_y + 90, cam_x + 45, cam_y + 30, 10)
			line(x_offset + (cam_x/distance_offset_closer),cam_y + 128 ,x_offset + ((cam_x + 45)/distance_offset_closer), cam_y + 30, 10)
			line(x_offset + ((cam_x + 5)/distance_offset_closer),cam_y + 128 ,(x_offset + (cam_x + 75)/distance_offset_closer), cam_y + 30, 10)
		elseif spot_light_state == 3 then
		 circfill(x_offset + ((cam_x + 60)/distance_offset_closer),cam_y + 60,10,10)
			--rectfill(cam_x, cam_y + 90, cam_x + 45, cam_y + 30, 10)
			line(x_offset + (cam_x/distance_offset_closer),cam_y + 128 ,x_offset + ((cam_x + 45)/distance_offset_closer), cam_y + 60, 10)
			line(x_offset + ((cam_x + 5)/distance_offset_closer),cam_y + 128 ,x_offset + ((cam_x + 75)/distance_offset_closer), cam_y + 60, 10)
		end
	end
end

function update_animation_tile()

 tile_timer+= 1
 
 if  tile_timer < 30 then
  return
 else
  tile_timer = 0
 end
 
 -- animated tiles
 for i=108,128 do
  for n=50,64 do
   local sp_n = mget(i,n)
   if sp_n == 121 then
    mset(i,n, 122)
   elseif sp_n == 122 then
    mset(i,n, 121)
   elseif sp_n == 106 then
    mset(i,n, 105)
   elseif sp_n == 105 then
    mset(i,n, 106)
   end
  end
 end
end

function draw_game()
	cls(0)
 
	draw_background()
 
 -- main map
	map(0,0,0,0,128,128)
	
	for e in all(pickups) do
		spr(e.sp,e.x,e.y,1,1)
	end
	
	for e in all(powerups) do
		spr(e.sp,e.x,e.y,1,1)
	end
	
	for e in all(orbrs) do
		spr(e.sp,e.x,e.y,1,1)
	end
	
	for e in all(projct) do
		spr(e.sp,e.x,e.y,1,1)
	end
	
	for e in all(e_projct) do
		spr(e.sp,e.x,e.y,1,1)
	end
	
	if player.blink==false then
		spr(player.sp,player.x,player.y,1,1,player.flp)
	end
	if player.attacking then
		spr(player.att_sp,player.att_x,player.att_y,player.att_tw,1,player.att_flp)
	end
	
	if show_hg then
	 spr(hangglider.sp,hangglider.x,hangglider.y,2,1)
	end
	
	for e in all(enemies) do
	 if e.flashing then
	  for i=0,12 do
    pal(i,7, 1)
   end
	 end
	 if e.v == true then
			spr(e.sp,e.x,e.y,e.w/8,e.h/8,e.flp)
		end
	end
	
	if fading == 0 then
		pal()
 end
 
	for e in all(sparks) do
		spr(e.sp,e.x,e.y,1,1)
	end
	
 -- global fx
 pal(1, 0)
	
	if siren then
  if siren_bs then
  	pal(1, 8)
  else
   pal(1, 0)
  end
 end
 
 -- intro text
 if is_in_intro then
 	print("eurasia a.d.2048", cam_x + 32, cam_y + 32, 12)
 end
 
 -- draw speech
 if boss_flow_pause then
  local current_print =  sub(speech_text, 1, speech_letter)
 	print(current_print, cam_x + 10, cam_y + 80, 10)
 end
	draw_ui()
	
	-- debug
	--rect(x1r,y1r,x2r,y2r,7)
	--rect(hitdet_x1, hitdet_y1, hitdet_x2, hitdet_y2)
	--rect(hitdet_t_x1, hitdet_t_y1, hitdet_t_x2, hitdet_t_y2)
	--rect(debug_x1, debug_y1, debug_x2, debug_y2)
	--print("‹= " ..col_l, player.x, player.y - 10)
	--print("‘= " ..col_r, player.x, player.y - 16)
	--print("”= " ..col_u, player.x, player.y - 22)
	--print("ƒ= " ..col_d, player.x, player.y - 28)
	--print("move_order_debug" ..move_order_debug, player.x, player.y - 10)
	--print("cam_x " ..cam_x, cam_x, cam_y, 7)
	--print("cam_y " ..cam_y, cam_x, cam_y + 10, 7)
	--print("cam_ovr_x " ..cam_ovr_x, cam_x, cam_y + 20, 7)
	--print("cam_ovr_y " ..cam_ovr_y, cam_x, cam_y + 30, 7)
	--print("bx_x " ..bg_x, cam_x, cam_y + 30, 7)
	
end

function draw_ui()

  -- back
	--rectfill(cam_x + 0,cam_y + 120,cam_x + 128,cam_y + 128,6)
	
	// draw life
	for i=0,player.health - 1 do 
	 local hloffset = 0
	 spr(124,cam_x + hloffset + (8*i), cam_y + 120)
	end
	
	// draw power ups
	if player.weapon_timer > 0 then
		print("power up= " ..flr(player.weapon_timer/60), cam_x + 70, cam_y + 120, 11)
	end
end

function fadeout(callback)
if callback != nil then
 _callback = callback
end
local fade,c,p={[0]=0,17,18,19,20,16,22,6,24,25,9,27,28,29,29,31,0,0,16,17,16,16,5,0,2,4,0,3,1,18,2,4}
  fading+=1
  if fading%fadespeed==1 then
    for i=0,15 do
      c=peek(24336+i)
      if (c>=128) c-=112
      p=fade[c]
      if (p>=16) p+=112
      pal(i,p,1)
    end
    if fading==7*fadespeed+1 then
      cls()
      pal()
      fading=-1
      if _callback != nil then
       _callback()
       _callback = nil
      end
    end
  end
end
-->8
--collusion


function collide_map(obj,aim,flag)
		--obj = needs x,y,w,h
		--aim = left,right,up,down
		local x=obj.x local y=obj.y
		local w=obj.w local h=obj.h
		
		local x1=0 local y1=0
		local x2=0 local y2=0
		
		if aim=="left" then
			x1=x     y1=y+1
			x2=x+1   y2=y+h-2
			
		elseif aim=="right" then
			x1=x+w-1	y1=y+1
			x2=x+w	  y2=y+h-2
			
		elseif aim=="up" then
			x1=x+2	  y1=y-1
			x2=x+w-3	y2=y
			
		elseif aim=="down" then
			x1=x+2   y1=y+h
			x2=x+w-3 y2=y+h
		
		elseif aim=="none" then
			x1=x   y1=y
			x2=x+w y2=y+h
		end
		
		x1r = x1
		y1r = y1
		x2r = x2
		y2r = y2
		
		--pixels to tiles
		x1/=8
		y1/=8
		x2/=8
		y2/=8
		
		
		
		if fget(mget(x1, y1), flag)
		or fget(mget(x1, y2), flag)
		or fget(mget(x2, y1), flag)
		or fget(mget(x2, y2), flag) then
			return true
		else 
			return false
		end
		
end

function check_for_weapon_hit(attacker, obj)
	local x=attacker.att_x local y=attacker.att_y
	local w=attacker.att_w local h=attacker.att_h
	
	local t_x=obj.x local t_y=obj.y
	local t_w=obj.w local t_h=obj.h
	
	return check_for_collustion(x,y,w,h,t_x,t_y,t_w,t_h)

end

function check_for_enemy_hit(obj1, obj2)
	local x=obj1.x local y=obj1.y
	local w=obj1.w local h=obj1.h
	
	local t_x=obj2.x local t_y=obj2.y
	local t_w=obj2.w local t_h=obj2.h
	
 return check_for_collustion(x,y,w,h,t_x,t_y,t_w,t_h)
end

function check_for_collustion(x,y,w,h,t_x,t_y,t_w,t_h)
	local x1=x   local y1=y
	local x2=x+w local y2=y+h
	
	local t_x1=t_x   local t_y1=t_y
	local t_x2=t_x+t_w local t_y2=t_y+t_h
	
	hitdet_x1=x1
	hitdet_y1=y1
	hitdet_x2=x2
	hitdet_y2=y2
	
	hitdet_t_x1=t_x1
	hitdet_t_y1=t_y1
	hitdet_t_x2=t_x2
	hitdet_t_y2=t_y2
	
	-- if rect intersect
	 // if one rectangle is on left side of other  
  if x1 >= t_x2 or t_x1 >= x2 then
   return false
  end
  
  // if one rectangle is above other  
  if y1 >= t_y2 or t_y1 >= y2 then
   return false
  end 
	
	return true
	
end


-->8
-- player

function update_player_timers()
  if player.weapon_timer > 0 then
  player.weapon_timer-=1
 else
  set_weapon(1)
 end
 
 if player.orbrs_cooldown > 0 then
  player.orbrs_cooldown-=1
 end
 
 if player.paused == true then
 	player.pause_timer+=1
 	
 	if player.pause_timer >= 8 then
 		player.paused = false
 	else
 		return
 	end
 end
end

function player_update()
 if is_in_intro then
  return
 end
 
 if boss_flow_pause or boss_flow_death_seq > -1 then
  -- lock player input
 	player.iit_cooldown=2
 	player.climbing = false
 end
 
 if player.health <= 0 then
  music(-1)
  init_game_over()
 end
 
 if boss_flow_pause == false then
 	update_player_timers()
 end
 
	player.dy+=gravity
	player.dx*=friction
	
	-- cooldowns
	if player.clmb_cooldown >0 then
		player.clmb_cooldown-=1
	end
	
	if player.iit_cooldown > 0 then
 	player.iit_cooldown-=1
 end
 
	if player.hit_cooldown > 0 then
 	player.hit_cooldown-=1
 	player.blink = not player.blink
 else
 	player.is_hit = false
 	player.blink = false
	end
	 
	
	local is_moving = false
	
	-- climb handling
	handle_climbing(player)
	
	-- handle getting hit
	handle_world_obj_coll(player)
	
	if btn(0) and player.iit_cooldown==0 then
		if player.climbing and player.climb_dir == "r" then
			clear_climb(player)
		elseif player.climbing and player.climb_dir == "u" then
			-- do noting
			player.flp=true
		else
			player.dx-=player.acc
			player.running=true
			player.flp=true
			is_moving=true
		end
	end
	
	if btn(1) and player.iit_cooldown==0 then
		if player.climbing and player.climb_dir == "l" then
			clear_climb(player)
		elseif player.climbing and player.climb_dir == "u" then
			-- do noting
			player.flp=false
		else
			player.dx+=player.acc
			player.running=true
			player.flp=false
			is_moving=true
		end
	end
	
	if is_moving == false then
		player.running=false
	end
	
	-- attack
	local dirc = "r"
	if player.climbing and player.climb_dir == "r" then
	 if btn(1) then
	  dirc = "r"
	 else
	  dirc = "l"
	 end
	elseif player.climbing and player.climb_dir == "l" then
	 if btn(0) then
	  dirc = "l"
	 else
	  dirc = "r"
	 end
	elseif player.flp then
	 dirc = "l"
	end
	
 handle_attack(player, dirc)
 
 -- handle projectiles
 handle_projectiles()
 
 -- only what is in view
 local sc_x1 = cam_x
 local sc_x2 = cam_x + 128
 local sc_y1 = cam_y
 local sc_y2 = cam_y + 128
 
 debug_x1 = sc_x1
 debug_x2 = sc_x2
 debug_y1 = sc_y1
 debug_y2 = sc_y2
 
 handle_activity(sc_x1,sc_x2,sc_y1,sc_y2)
 
 -- trigger volume check
 if collide_map(player,"none",3) then
 	start_event(1)
 end
 
 if collide_map(player,"none",4) then
 	start_event(2)
 end
 
 if collide_map(player,"none",5) then
 	start_event(3)
 end
 
 for p in all(portals) do
  if check_for_collustion(player.x, player.y, player.w, player.h, p.x*8, p.y*8, 8, 8) then
   teleport(player, p)
  end
 end
 
 track_event()
 
	-- jump
	if btnp(4) then
	 if player.iit_cooldown==0 and player.landed then
			player.dy-=player.boost
			player.landed=false
			player.clmb_cooldown=3
		end
		if player.climbing == true then
		 local last_dir = player.climb_dir
			clear_climb(player)
			player.dy-=player.boost/2
			player.landed=false
			player.clmb_cooldown=6
			if last_dir == "r" then
			 player.dx=-4
			else
			 player.dx=4
			end
		end
	end
	
	if player.dy>0 then
		player.falling=true
		player.landed=false
		player.jumping=false
		
		player.dy=limit_speed(player.dy,player.max_dy)
		
		if collide_map(player,"down",0) then
			player.landed=true
			player.falling=false
			player.dy=0
			player.y-=(player.y+player.h)%8
			
			-- test
			col_d="yes"
		else col_d="no"
			
		end
	elseif player.dy<0 then
			player.jumping=true
			if collide_map(player,"up",0) then
				player.dy=0
				
				if player.is_hit == false then
				 player.climbing=true
				 player.climb_dir="u"
				 player.clmb_x=0
				 player.clmb_y=0
				 
				 --player.y-=(player.y+player.h)%8
				end
				
				-- test
				col_u="yes"
			else col_u="no"
			end
	end
	
	if player.dx<0 then
	
		player.dx=limit_speed(player.dx,player.max_dx)
		
		if collide_map(player,"left",0) then
			player.dx=0
			
			if player.clmb_cooldown==0 and player.climb_dir != "l" and (player.jumping or player.falling) then
				player.climbing=true
				player.jumping=false
				player.falling=false
				player.climb_dir="l"
				player.clmb_y=0
				player.clmb_x=0
				--player.x+=(player.x+player.w)%8
		
				sfx(1)
			end
			
				-- test
			col_l="yes"
			else col_l="no"
		end
	end
	
	if player.dx>0 then
	
	 player.dx=limit_speed(player.dx,player.max_dx)
	 
		if collide_map(player,"right",0) then
			player.dx=0
			
			if player.clmb_cooldown==0 and player.climb_dir != "r" and (player.jumping or player.falling) then
				player.climbing=true
				player.jumping=false
				player.falling=false
				player.climb_dir="r"
				player.clmb_y=0
				player.clmb_x=0
				--player.x-=(player.x+player.w)%8
				
				sfx(1)
			end
			
			 -- test
			col_r="yes"
			else col_r="no"
		end
	end
	
	if player.climbing then
		player.dy = player.clmb_y
		player.dx = player.clmb_x
	end
	player.x+=player.dx;
	player.y+=player.dy;
	
	if player.x<map_start then
		player.x=map_start
	end
	
	if player.x>map_end-player.w then
		player.x=map_end-player.w
	end
	
end

function handle_climbing(player)
 -- climb handling
	local is_moving_on_wall = false
	
	if btn(‹) and player.climbing and player.climb_dir=="u" then
			player.clmb_x=-0.5
			is_moving_on_wall = true
	end
	
	if btn(‘) and player.climbing and player.climb_dir=="u" then
			player.clmb_x=0.5
			is_moving_on_wall = true
	end
	
	if btn(”) and player.climbing and player.climb_dir!="u" then
	  if not collide_map(player,"up",0) then
				player.clmb_y=-0.5
				is_moving_on_wall = true
			end
	end
	
	if btn(ƒ) and player.climbing and player.climb_dir!="u" then
			player.clmb_y=0.5
			is_moving_on_wall = true
	end
	
	if is_moving_on_wall == false then
		player.clmb_y=0
		player.clmb_x=0
	end
	
		if btn(ƒ) and player.climbing and player.climb_dir =="u" then
			clear_climb(player)
	end
	
	if player.climbing and player.climb_dir == "l" then
		if is_done_climbing(player,"left") then 
			clear_climb(player)
			--push player after climb done
			--player.dx=-2
			--player.dy=-1 -- short hop for ceiling climb
		end
	end
	if player.climbing and player.climb_dir == "r" then
		if is_done_climbing(player,"right") then 
			clear_climb(player)
			--push player after climb done
			--player.dx=2
			--player.dy=-1 -- short hop for ceiling climb
		end
	end
	if player.climbing and player.climb_dir == "u" then
		if is_done_climbing(player,"up") then 
			clear_climb(player)
			--push player after climb done
			--player.dy=-1
		end
	end
end

function start_event(id)
  -- find if event was used
 local event_done = false
 for de in all(event_tracker.done_events) do
  if de == id then
   event_done = true
  end
 end
 
 for bm in all(block_map) do

  if bm.trigger_id == id and not event_done and event_tracker.event_in_progress != id then
  	
  	-- start the event
  	start_siren(false)
  	music(8)
  	event_tracker.event_in_progress = id
  	
  	-- change all open blocks to locked
  	for tile in all(bm.open) do
  	 mset(tile.x, tile.y, 80)
  	end
  	
  	for spwn in all(bm.spawns) do
  	 enemy = create_enemy(spwn.x*8, spwn.y*8, spwn.type)
  	 enemy.is_event = true
  	 event_tracker.num_of_enemies+=1
  	end
  	
  	--for tile in all(bm.close) do
  	 --mset(tile.x, tile.y, 0)
  	--end
  end
 end
end

function track_event()
 if event_tracker.num_of_enemies == 0 and event_tracker.event_in_progress != 0 then
  --wrap up event
  
  add(event_tracker.done_events,event_tracker.event_in_progress)
  music(0)
  for bm in all(block_map) do
  	if bm.trigger_id == event_tracker.event_in_progress then
  	 for tile in all(bm.close) do
  	  mset(tile.x, tile.y, 0)
  	  create_explosion(tile.x*8, tile.y*8)
  	  stop_siren(false)
  	 end
   end
  end
  event_tracker.event_in_progress = 0
  
 end
end
function set_weapon(weapon_number)
 if weapon_number == 1 then
  player.att_first_sp = attack1_first_sp
  player.att_last_sp = attack1_last_sp
  player.att_w = attack1_w
  player.att_h = attack1_h
  player.att_tw = attack1_tw
 end
 if weapon_number == 2 then
  player.att_first_sp = attack2_first_sp
  player.att_last_sp = attack2_last_sp
  player.att_w = attack2_w
  player.att_h = attack2_h
  player.att_tw = attack2_tw
 end
end

function add_orbrs()
 create_orbrs()
 player.orbrs+=1
end

function clear_orbrs()
 o = get_orbrs(player.orbrs)
 remove_orbrs(o)
 player.orbrs-=1
end

function clear_climb(player)
	player.climbing = false
	player.climb_dir = "n"
end

function is_done_climbing(player, coll_dir)
	if collide_map(player,coll_dir,0) == false then
		return true
	end
	return false
end

function handle_projectiles()
	for p in all(projct) do
 	for e in all(enemies) do
 		local hit_found = check_for_enemy_hit(p, e)
	 	if hit_found then
	 	 handle_hit(player, e)
	 	 remove_projectile(p)
	 	end
 	end
 	for e in all(pickups) do
 		local hit_found = check_for_enemy_hit(p, e)
	 	if hit_found then
	 	 handle_hit(player, e)
	 	 remove_projectile(p)
	 	end
 	end
 end
end


function handle_attack(player, dirc)
-- attack direction
 
	if dirc=="l" then
		player.att_x = player.x - ((player.att_tw - 1) * 8) - player.att_offset - (player.w/2)
		player.att_flp = true
	elseif dirc=="r" then
		player.att_x = player.x + player.att_offset + (player.w/2)
		player.att_flp = false
	end
	player.att_y = player.y
	
 if btnp(5) and player.attacking == false and player.iit_cooldown == 0 then
		player.attacking = true
		player.att_sp=player.att_first_sp
		sfx(0)
		
		-- shoot from orbrs
		if player.orbrs > 0 then
		 if player.orbrs_cooldown <= 0 then
			 for e in all(orbrs) do 
					create_projectile(e.x,e.y,dirc)
				end
				player.orbrs_cooldown = 30
			end
		end
	end
	
	-- while animation is playing
	if player.attacking and time()-player.attack_anim>.02 then
		 
		 for e in all(enemies) do
		 	local hit_found = check_for_weapon_hit(player, e)
		 	if hit_found and player.attack_rg == false then
		 	 handle_hit(player, e)
		 	end
		 end
		 
		 for e in all(pickups) do
		 	local hit_found = check_for_weapon_hit(player, e)
		 	if hit_found then
		 	 handle_hit(player, e)
		 	end
		 end
		 
		 player.attack_anim=time()
			player.att_sp+=player.att_tw
			if player.att_sp>player.att_last_sp then
				player.att_sp=16
				player.attacking = false
				player.attack_rg = false
			end
	end
end

function create_explosion(x,y)
 --hit effects
	create_hitspark(x, y, 1, -1)
	create_hitspark(x, y, 0, -1)
	create_hitspark(x, y, -1,-1)
	create_hitspark(x, y, 1, 0)
	create_hitspark(x, y, 0, 0)
	create_hitspark(x, y, -1, 0)
end

function handle_hit(player, enemy)
	sfx(2)
 create_explosion(enemy.x + (enemy.w/2) ,enemy.y + (enemy.h/2))
	if enemy.type == "enemy" then
	 if enemy.health > 0 then
	  enemy.health-=1
	  enemy.flashing=true
	  enemy.flashing_timer = 4
	 end
	 
	 player.attack_rg = true
	 
	 if enemy.health <= 0 then
	  if enemy.enemy_type != 20 then --
			 if enemy.is_event then
			  event_tracker.num_of_enemies-=1
			 end
			 remove_enemy(enemy)
		 else
		 
		  -- boss death sequence
		  boss_flow_death_seq=0
		  boss_flow_death_seq_timer=0
		  music(-1)
		  
		  		  -- remove all enemies that are not boss
		  for e in all(enemies) do
		   if e.enemy_type != 20 then
		    remove_enemy(e)
		   end
		  end
		  
		   -- remove all projectiles
		  for e in all(e_projct) do
		    remove_e_projectile(e)
		  end
		  
		 end
		 
		end
	elseif enemy.type == "pickup" then
	 pickup = flr(rnd(3)) + 1
	 create_powerup(enemy.x, enemy.y, pickup)
		remove_pickup(enemy)
	end
	shake+=0.2
	
	-- pause player and pause enemy
	player.paused = true
	player.pause_timer=0
end

function handle_world_obj_coll(player)
 for e in all(powerups) do
  local hit_found = check_for_enemy_hit(player, e)
  if hit_found then
	  if e.type == 1 then
	  	set_weapon(2)
	  	player.weapon_timer+=60*20
	  	sfx(3)
	  end
	  if e.type == 2 then
	   if player.health < player.max_health then
	  		player.health+=1
	  	end
	  	sfx(3)
	  end
	  if e.type == 3 then
	   if player.orbrs < 2 then
	   	add_orbrs()
	   end
	  	sfx(3)
	  end
	  remove_powerup(e)
  end
 end
	for e in all(enemies) do
 	hurt_player(player, e)
 end
 for e in all(e_projct) do
 	hurt_player(player, e)
 end
end

function hurt_player(player,e )
if boss_flow_death_seq > -1 then
	return
end

local hit_found = check_for_enemy_hit(player, e)
	if hit_found and player.is_hit == false then
	 -- damage player
	 
	 sfx(4)
	 -- remove orbs if exits
	 if player.orbrs > 0 then
	 	clear_orbrs()
	 end
	 player.is_hit = true
	 player.hit_cooldown = 90
	 player.iit_cooldown = 30
	 clear_climb(player)
	 player.health-=1
 	if player.flp==false then
 		player.dx=-4
 	else
 	 player.dx=4
 	end
	 
	 player.dy=-2
	end
end

function player_animate()
 if is_in_intro then
  player.sp=16
  return
 end
 
 if player.climbing then
  local stop_sprite = 8
		local end_sprite = 10
		if player.climb_dir=="u" then
			stop_sprite = 11
			end_sprite = 13
		end
		if player.clmb_y != 0 or player.clmb_x != 0 then
			-- animate
			if time()-player.anim>.05 then
				player.anim=time()
				player.sp+=1
				if player.sp>end_sprite then
					player.sp=stop_sprite 
				end
			end
		else
			player.sp=stop_sprite
		end
	elseif player.jumping then
		player.sp=6
	elseif player.falling then
		player.sp=7
	elseif player.running then
		if time()-player.anim>.05 then
			player.anim=time()
			player.sp+=1
			if player.sp>5 then
				player.sp=4
			end
		end
	else -- idle
		if time()-player.anim>.3 then
			player.anim=time()
			player.sp+=1
			if player.sp>3 then
				player.sp=1
			end
		end
	end
end

function limit_speed(num, maximum)
	return mid(-maximum,num,maximum)
end

function start_boss_battle()
 music(9)
end

function teleport(player, p)
-- teleport
  player.x = p.t_x
  player.y = p.t_y
  if p.cam_ovr_x != -1 and p.cam_ovr_y != -1 then
   cam_ovr_x = p.cam_ovr_x
   cam_ovr_y = p.cam_ovr_y
  else
   cam_ovr_x = -1
   cam_ovr_y = -1 
  end
  
  if p.boss == true then
   music(-1)
   -- spawn boss
   create_enemy(119*8, 35*8, 20)
   --start_siren()
   
   start_boss_flow()
  end
end

function update_hg()
 if show_hg then
  hangglider.x+=1
 end
end
-->8
-- enemies

enemies={}
function create_enemy(x,y, type)
 local enemy_type = 49
 local health=1
 local h=8
 local w=8
 local ws=0.25
 local dw=40
 local shoot_countdown=3*60
 local move_order = {}
 if type == 1 then
 	enemy_type = 49
 elseif type == 2 then
  enemy_type = 50
 elseif type == 10 then
  enemy_type = 39
  health=30
  h=16
  ws=0.2
  dw=80
  shoot_countdown=1*60
 elseif type == 20 then
  enemy_type = 41
  health=50
  --health=1
  h=16
  w=16
  move_order={"l","d","u","r","d","u","r","d","u","l","d","u"}
 end
 
 enemy = {x=x,
	  y=y,
	  dx=0,
	  dy=0,
	  max_dy=3,
	  max_dx=3,
	  w=w,
	  h=h,
	  ws=ws,
	  dw=dw,
	  anim=0,
	  sp=enemy_type,
	  flp=false,
	  dist=0,
	  rot_f=0, 
	  m_dir="l",
	  paused=false,
 	 pause_timer=0,
 	 type="enemy",
 	 state="scan",
 	 scs=shoot_countdown,
 	 shoot_countdown=shoot_countdown,
 	 enemy_type=type,
 	 is_event=false,
 	 health=health,
 	 flashing=false,
 	 flashing_timer=0,
 	 active=false,
 	 move_order=move_order,
 	 move_order_index=1,
 	 v=true}
 	 
 	 
	add(enemies,enemy)
	
	return enemy
end

function remove_enemy(enemy)
	del(enemies, enemy)
end

function update_enemies()
 if boss_flow_pause then
 	return
 end
 
	for e in all(enemies) do
	 if e.flashing then
	  e.flashing_timer-=1
	 end
	 
	 if e.flashing_timer == 0 then
	  e.flashing = false
	 end
	 
	 if boss_flow_death_seq > -1 then
		 e.active = false
		 handle_death_seq(e)
		end
	 
	 if e.active == false then
	 end
	 -- floaters
	 if e.enemy_type == 1 and e.active then
		 local direction_mod = 0.25
		 if e.m_dir == "l" then
		 	direction_mod = -0.25
		 end
			e.x+=direction_mod
			e.y+=(sin(e.rot_f))*0.6
		 e.dist+=abs(direction_mod)
		 e.rot_f+=0.015
		 if e.dist >= 40 then
		  e.dist = 0
		  --e.rot_f = 0
		  if e.m_dir == "l" then
		 		e.m_dir = "r"
		 	else
		 		e.m_dir = "l"
		 	end
		 end
		 
		 
		-- boss!!!
		elseif e.enemy_type == 20 and e.active then
		 if e.shoot_countdown > 0 then
	  	e.shoot_countdown-=1
	  end	
	  
		 local move_dir = e.move_order[e.move_order_index]
		 e.m_dir = move_dir
		 local direction_mod_x = 0
		 local direction_mod_y = 0
		 if e.m_dir == "l" then
		 	direction_mod_x = -0.25
		 elseif e.m_dir == "r" then
		 	direction_mod_x = 0.25
		 elseif e.m_dir == "d" then
		 	direction_mod_y = 0.25
		 elseif e.m_dir == "u" then
		 	direction_mod_y = -0.25
		 end
		 
		
		 move_order_debug = e.m_dir
		 
		 if e.shoot_countdown == 0 then
	  	e.shoot_countdown = 5*60
	  	create_e_projectile(e.x + (e.w/2),e.y + (e.w/2),"d", 2)
	  else	
				e.x+=direction_mod_x
				e.y+=direction_mod_y + (sin(e.rot_f))*0.6
			 e.dist+=abs(direction_mod_x + direction_mod_y)
			 e.rot_f+=0.015
			 if e.dist >= 40 then
			  e.dist = 0
			  --e.rot_f = 0
			  e.move_order_index+=1
			  if e.move_order_index > #e.move_order then
			   e.move_order_index = 1
			  end
			 end
		 end
		 
	 elseif (e.enemy_type == 2 or e.enemy_type == 10) and e.active then
	  e.dy+=gravity
	  
	  if e.shoot_countdown > 0 then
	  		e.shoot_countdown-=1
	  else
	   if e.state == "scan" then
	    e.state = "preshoot"
	    e.shoot_countdown=1*60
	   elseif e.state == "preshoot" then
	    e.state = "scan"
	    e.shoot_countdown=e.scs
	    
	    if player.x < e.x then
	    	e.m_dir = "l"
	    end
	    if player.x > e.x then
	    	e.m_dir = "r"
	    end
	    
	    create_e_projectile(e.x,e.y,e.m_dir)
	    sfx(5) 
	   end
	   
	  end
	  
	  -- physics, will encapsulate this better later
	  if e.dy>0 then
		  e.dy=limit_speed(e.dy,e.max_dy)
				if collide_map(e,"down",0) then
					e.dy=0
					e.y-=(e.y+e.h)%8
				end
		 end
	 	local direction_mod = e.ws
	 	e.flp = false
		 if e.m_dir == "l" then
		 	direction_mod = -e.ws
		 	e.flp = true
		 end
		 
		 if e.state == "preshoot" then
		  direction_mod = 0
		 end
		 
			e.dx=direction_mod
		 e.dist+=abs(direction_mod)
		 
	 if e.dx<0 then
			e.dx=limit_speed(e.dx,e.max_dx)
			if collide_map(e,"left",0) then
				e.dx=0
				e.dist = e.dw
			end
	 end
	
	if e.dx>0 then
	 e.dx=limit_speed(e.dx,e.max_dx)
		if collide_map(e,"right",0) then
			e.dx=0
			e.dist = 40
		end
	end
	
		 if e.dist >= 40 then
		  e.dist = 0
		  --e.rot_f = 0
		  if e.m_dir == "l" then
		 		e.m_dir = "r"
		 	else
		 		e.m_dir = "l"
		 	end
		 end
		 
		 e.y+=e.dy;
		 e.x+=e.dx;
	 end
			 
	end
end

function handle_death_seq(e)
 boss_flow_death_seq_timer+=1
 local timeoffs = 60
 local st = boss_flow_death_seq_timer
 if st >= 120 and st < 260 then
  timeoffs = 30
 end
 if st >= 261 and st < 500 then
  timeoffs = 15
 end
 if st >= 500 and st < 800 then
  timeoffs = 5
 end
 if st%timeoffs == 0 and e.v then
  local sp_x=rnd_dir()
  local sp_y=rnd_dir()
  create_hitspark(e.x + (e.w/2), e.y + (e.h/2),sp_x, sp_y)
  sfx(2)
  shake+=0.2
 end
 
 if boss_flow_death_seq_timer == 800 then
  --remove_enemy(e)
  -- just hid
  e.v = false
  start_siren(true)
  sfx(8)
 end
 
 if boss_flow_death_seq_timer == 1000 then
  stop_siren(true)
 end
 
 if boss_flow_death_seq_timer == 1200 then
  music(14)
  fadeout()
 end
 
 if boss_flow_death_seq_timer == 1400 then
  --flow_state="win"
  teleport(player, portals[4])
  flow_state="win"
  
 end
end

function rnd_dir()
 local val = rnd(1)
 if val > 0.66 then
  return 1
 elseif val > 0.33 then
  return 0
 else 
  return -1
 end
end

function animate_enemies()

for e in all(enemies) do

 if e.enemy_type == 2 then
		if time()-e.anim>.05 then
				e.anim=time()
				e.sp+=1
				if e.sp>51 then
					e.sp=50
				end
			end
		end
	
	if e.enemy_type == 20 then
		if time()-e.anim>.60 then
				e.anim=time()
				e.flp = not e.flp
			end
		end
		
	end
	
end

function handle_activity(x1, x2, y1, y2)
 for e in all(enemies) do
  if e.x >= x1 and e.x<= x2 and e.y >= y1 and e.y <= y2 then
   e.active=true
  else
   e.active=false
  end
	end
end
-->8
--fx

sparks={}

function create_hitspark(x,y,dir_x,dir_y)
	add(sparks,
	 {x=x,
	  y=y,
	  sp=76,
	  dir_x=dir_x,
	  dir_y=dir_y,
	  anim=0,
	  })
end

function remove_hitspark(hitspark)
	del(sparks, hitspark)
end

function update_hitsparks()
	for e in all(sparks) do
		e.x+=e.dir_x
		e.y+=e.dir_y
	end
end

function animate_hitsparks()
 for e in all(sparks) do
		if time()-e.anim>.05 then
			e.anim=time()
			e.sp+=1
			if e.sp>78 then
				remove_hitspark(e)
			end
		end
	end
end
-->8
--pick ups

pickups={}
function create_pickup(x,y)
	add(pickups,
	 {x=x,
	  y=y,
	  sp=33,
	  w=8,
	  h=8,
	  type="pickup"})
end

function remove_pickup(p)
	del(pickups, p)
end
-->8
--power ups

powerups={}
function create_powerup(x,y, type)
 local power_up_sp = 34
 if type == 1 then
 	power_up_sp = 34
 end
 if type == 2 then
 	power_up_sp = 35
 end
 if type == 3 then
 	power_up_sp = 36
 end
	add(powerups,
	 {x=x,
	  y=y,
	  sp=power_up_sp,
	  w=8,
	  h=8,
	  type=type})
end

function remove_powerup(p)
	del(powerups, p)
end
-->8
-- orbrs

orbrs = {}
function create_orbrs()

 if get_orbrs(1) != nil then
	 local first_orbs = get_orbrs(1)
	 first_orbs.x=0
	 first_orbs.y=0
	 first_orbs.dir_x=0
	 first_orbs.dir_y=9
	 first_orbs.flp_x=false
	 first_orbs.flp_y=false
	 first_orbs.max_x=9
	 first_orbs.max_y=9
	 first_orbs.x=0
	 first_orbs.y=0
	end
	
 add(orbrs,
	 {x=0, -- will be controlled from player
	  y=0,
	  sp=36,
	  w=4,
	  h=4,
	  dir_x=9,
	  dir_y=0,
	  max_x=9,
	  max_y=9,
	  flp_x=true,
	  flp_y=false,})
end

function get_orbrs(index)
 return orbrs[index]
end

function remove_orbrs(o)
	del(orbrs, o)
end

function update_orbrs()
	for e in all(orbrs) do
		e.x = player.x + e.dir_x
		e.y = player.y + e.dir_y
		
		local mod_x = 0.5
		local mod_y = 0.5
		
		if e.flp_x == true then
			mod_x = -mod_x
		end
		
		if e.flp_y == false then
			mod_y = -mod_y
		end
		
		e.dir_x+=mod_x
		e.dir_y+=mod_y
		
		if abs(e.dir_x) >= e.max_x then
			e.flp_x = not e.flp_x
		end
		
		if abs(e.dir_y) >= e.max_y then
			e.flp_y = not e.flp_y
		end
		
	end
end
-->8
-- projctelies

projct={}

function create_projectile(x,y,dirction)
	add(projct, {
	x=x,
	y=y,
	h=4,
	w=4,
	sp=14,
	speed=2,
	flp=false,
	lft=40,
	dirc=dirction})
end

function remove_projectile(p)
	del(projct, p)
end

function update_projectiles()
	for e in all(projct) do
	 e.lft-=1
	 
		if e.dirc == "r" then
			e.x += e.speed
		else
			e.x -= e.speed
		end
		
		if e.lft <= 0 then
	  remove_projectile(e)
	 end
	end
end
-->8
-- enemy projctelies

e_projct={}

function create_e_projectile(x,y,dirction,type)
	local sp=15
	local l_type = type
	local lt=100
	if type == 2 then
	 sp=47
	 lt=50
	end
	
	add(e_projct, {
	x=x,
	y=y,
	h=1,
	w=1,
	sp=sp,
	speed=1,
	flp=false,
	lft=lt,
	type=l_type,
	dirc=dirction})
end

function remove_e_projectile(p)
	del(e_projct, p)
end

function update_e_projectiles()
	for e in all(e_projct) do
	 e.lft-=1
	 
		if e.dirc == "r" then
			e.x += e.speed
		elseif e.dirc == "l" then
			e.x -= e.speed
		elseif e.dirc == "d" then
			e.y += e.speed
		end
		
		
		if e.lft <= 0 then
		 if e.type == 2 then
		  create_enemy(e.x,e.y,2)
		 end
	  remove_e_projectile(e)
	 end
	end
end
__gfx__
0000000000044400000444000004440000004440000044400004440008044400000444560004440000044400056544000056540000f456500000000000000000
000000000804ff000004ff000004ff0008004ff008004ff00004ff000084ff00000f44f5000f4405000f440000f4ff00000f4f0000f44f00000cc00000000000
007007000088820008888200008882000088882000888820008882000f08820f00888200008882f60088820000f8820f000f88f000088f0000c00c0000000000
00077000000f2800000f2800080f280000fff28000fff280080f280000ff280f000f2800000f2805000f28f5008f280f008f28f000882f000c0000c000099000
00077000000f22f0000f22f0000f22f00000f22f0000f22f80f022f0000022f0000f2288000f2288000f2286008022f0008022f0008022000c0000c000099000
00700700000022000000220000002200000002200000022000002200000022000000f2000000f2000000f20500002200000022000000220000c00c0000000000
0000000000020200000202000002020000002020000020200002020000020200000202000002020000020200000202000002020000020200000cc00000000000
00000000002202200022022000220220000200200000202000202000002000200020020000200200002002000020002000200020002000200000000000000000
00000000000000000000000077700000777700007777000000000000000000000000000007777000777777777777700077777777777770007777777000000000
00000000000000000000700000077700007777000079990000000000000000000000000000007700000777777777770000077777777799000007777700000000
00000000000000000000070000000770000078980000900000000000000000700000000000007770000000000007777000000000000899800000007700000000
00000000000000000000007000000077000000970000000000000000007777000000000000777700000000000077777000000000008888800000007700000000
00000000000007000000070000000977000008980000000000000000777700000000000099770000000000008899777000000000888888800000000000000000
00000000077770000899700008888970000888800000000000000077777000000000008999700000000000888997770000000088888008000000000000000000
00000000970000008800000088999000000000000000000000077777770000000008888997000000000888899977700000000008888800000000000000000000
00000000000000000000000080000000000000000000000009770000000000000888880000000000088888000000000000000000000000000000000000000000
0000000000555500000550000900809000000000000000000000000000444000004440000000005555500000000000000000000000000000000000000000c000
000000000566665000057000090080900000000000000000000000000045350000444500000000588850000000000565000000000000000000000000000c0000
00000000665cc5660005700009008099000dd000000000000000000000435300004443000000005fff5000000000004000000000000000000000000000c00000
000000009a5cc5a9000570009988008000dddd00000000000000000000bbbb0000bbbb000000555fff55500000000040000000000000000000000000000c0000
0000000066666666000570000880008000d88d0000000000000000005bb44bb50bbb53530008522222225800000000400000000000000000000000000000c000
000000009a5cc5a90005700009998899000dd00000000000000000003b4bb4b30bbbbbb0888852222222588800000045000000000000000000000000000c0000
00000000555cc555008888000008008000000000000000000000000050b44b0500bbbb008d44f2222222f4d80000004555550000000000000000000000cc0000
00000000055cc550000440000088008000000000000000000000000030bbbb0300bbbb000dd4fffff222f4d0500000468866d55555555550000000000000c000
0000000000cccc00000444000004440000000000000000000000000050bbbb0500000000005dd22ff222fd506444445688888888888888850000000000000000
0000000099c00c990054ff000074ff0000000000000000000000000050bbbb05000000000005dd22fffff500500000068866d555555555500000000000000000
000000009c5555c900573300007733000000000000000000000000000bbbbbb0000005550000dd22ff2dd5000000000555550000000000000000000000000000
000000009d5005d9005fbb00007fbb000000000000000000000000000bb00bb00000055500005dd2222d50000000000500000000000000000000000000000000
0000000099cccc9900055556000777760000000000000000000000000bb00bb053535353000005d222dd00000000000000000000000000000000000000000000
0000000000c55c0000005300000073000000000000000000000000000bb00bb000000555000005d222d500000000000000000000000000000000000000000000
000000000c0550c000030300000033000000000000000000000000000bb00bb0000005550000005d22d000000000000000000000000000000000000000000000
000000000d5555d000330330000330300000000000000000000000000bb00bb00000000000000005555000000000000000000000000000000000000000000000
444444444444444444444444444444444444444400000000000000000055c555555c550000000999999000009999999900000000000000000000000000000000
444444444444444444444444444444444444444400000050000000600055c555555c5500000092cccc290000cccccccc00000000000000000700007000000000
222222222222222222222222422222222222222405000575006000000055c555555c550000092555555290005555555500000000007007000070070000000000
555555555555555525555555455555555555555400000050000050000055c55cc55c5500009255c55c5529005555555500077000000070000000000000000000
555555555656555655555656455556566565555400050000000565000055c555555c550009255c5555c552905555555500077000000700000000000000000000
555555555555655555565555455565555556555400000000000050000055c555555c55009255c555555c55295555555500000000007007000070070000000000
555555555655556556555555555555555555555500000000000000000055c555555c550025555cccccc55552cccccccc00000000000000000700007000000000
555555555555555555555555555555555555555500000000000000000055c555555c550055555555555555555555555500000000000000000000000000000000
44444444444444444444444400000000000000001111111111111111111111110000000000000000000000005555555500080000000000000000000000000000
42222224455555544333333400000000000000001111111111111111111111110000000000000000000000005555555500880000000000000000000000000000
42444424454444544344443400000000000000001111111111111111111111110000000000000000000000005555555508888888000000000000000000000000
4242242445488454434884340000000000000000111111111111111111111111000000000000000000000000cc5555cc88888888000000000000000000000000
42422424454884544348843400000000000000001111111111111111111111110000000000000000000000005555555588888888000000000000000000000000
42444424454444544344443400000000000000001111111111111111111111110000000000000000000000005555555508888888000000000000000000000000
42222224455555544333333400000000000000001111111111111111111111110000000000000000000000005555555500880000000000000000000000000000
44444444444444444444444400000000000000001111111111111111111111110000000000000000000000005555555500080000000000000000000000000000
555555550066600000000000c0cccc0c55555555111111111111111115666651cccccccccccccccccc1c1c1c6665566690000000000000000000000000000000
777777770655560000000000050cc05066666666111111111111111155555555ccccccccccccccccccc101cc6666666699000055550000000000000000000000
55555555655655600000000005500550cccccccc111111111111111155666655ccccccccccccccccc110001166666666999aa555555555550000000000000000
777777776566656000000000c055550ccccccccc111111111115551115655651ccccccccccccccccccc101cc5666666509ddccc8888888850000000000000000
555555556556556000000000c055550c11111111111111115555d55115555551cccccccccccccccccc1c1c1c5666666509999550000500a00000000000000000
777777770655560000000000c055550c1111111111111111dd66665155666655cccccccccccccccccccc1ccc6666666699000500000500a00000000000000000
555555550066600000000000c055550c1111111111111111dda6a65555555555cccccccccccccccccccc1ccc6666666690005500000500000000000000000000
777777770000000000000000cc0555501111111111111111dda6666515666651cccccccccccccccccccc1ccc6665566600000000000500000000000000000000
222222220000000000000000cccc0000000000000000cccc0000000015666651111111111c1cc1c11c11c1cc0000000000000000000000000000000000000000
222222220000000000066000ccc055555555555555550ccc00000000155555511111111111c1711c11c11c170000000000000000000000000000000000000000
222222220000000000777700cc05555555555555555550cc0000000055666655111111111c11c1111111c11c0000000044444444000000000000000000000000
2222222200000000007dd700cc05555555555555555550cc000555001565565111111111c71117c17c1c711100000000476eeee4000000000000000000000000
2222222200000000007dd700cc05555555555555555550cc5555d550155885511111111111c1111c11c11c110000000046eeeee4000000000000000000000000
222222220000000077dccd77c0555555555555555555550cdd8666501566665111111111111cc1c11c1111cc000000004eeeeee4000000000000000000000000
2222222200000000dddccddd055555555555555555555550dd6686551155551111111111c17c1c11c11c17c10000000048888884000000000000000000000000
2222222200000000dddccddd055555555555555555555550dd86666511111111111111111c1111c11c11c1110000000044444444000000000000000000000000
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040505050505050505050505050505050505
00006400000000006400000000640000000000000000000000000000000000006400000000006400000000640000000000000000000000000000000000006400
00000000006400000000006400000000640000000000000000000000000000000000000000000000000000000000000505565656565656565656565656565605
54000000000064000000640000000000006400000000006400000000640054000000000064000000640000000000006400000000006400000000640054000000
00000054000000000064000000640000000000000000000000000000000000000000000000000000000000000000000505565612565656565656565612565605
00000000000064000000640000000000006400000000006400000000640054000000640000000000000000000054000000000064000000640000000000000000
64540000000000640000000000000000000000000000000000000000000000000000000000000000000000000000000505565625565656565656565625565605
00000000640000000000000000000054000000000064000000640000000000000000000054000054000000640000000000640000000000000000000000005400
00000000005400000054000054000000640000000000000000000000000000000000000000000000000000000000000505565625565656565656565625565605
00000000000064000000640000000000006400000000006400000000640054000000005400000000000000000000005400000054000054000000640000000000
00000000000000005400000000000000000000000000000000000000000000000000000000000000000000000000000505565656125656565656561256565605
64000000640000000000000000000054000000000064000000640000000000000000640000000000006400000000000000005400000000000000000064000000
64000064000000640000000000006400000000000000000000000000000000000000000000000000000000000000000505565656055656565656560556565605
00005400000054000054000000640000000000640000000000000000000000005400000000640000000000000064000000640000000000000000000000000000
00640000000000000000640000000000000000000000000000000000000000000000000000000000000000000000000505565656561556565656155656565605
00000000005400000000000000000000005400000054000054000000640000000000000000000000000000000000000000000000640000006400000000006400
00000000000000006400000000000000000000000000000000000000000000000000000000000000000000000000000505565656565656565656565656565605
00000000640000000000006400000000000000005400000000000000000000000000000000000000000000000000000000000000000054000000000064000000
64000000006400000000640000000000000000000000000000000000000000000000000000000000000000000000000505565656565656150556565656565605
00000000000000640000000000000000000000640000000000000000000000000000000000000000000000000000000000000000000000000000640000000000
00000000000000640000000000000000000000000000000000000000000000000000000000000000000000000000000505565656565656051556565656565605
00005400000000000000000000000000000000000000640000000000000000000000000000000000000000000000000000000000000000005400000054000054
00000064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505565656565656150556565656565605
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005400000000
00000000000054000000640000000000000000000000000000000000000000000000000000000000000000000000000505565656565656051556565656565605
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000640000000000
00640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000504040404040404040404040404040404
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000640000
00000000000000006400000000000000000000000000000000000000000000000000000000000000000000000000000504040404040404040404040404040404
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868686868686868686868686868686868686
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868686868686868686868686868686868686
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000094a4000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868686868686868686868686868686868686
000094b4b4b4b4a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007484000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868686868686868686868686868686868686
000074b5b5b5b58400000094a4000000000094a40000000000000094a400000000000094a494a400000094a40094a4000000000094b4b4a40000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868686868686868686868686868686868686
000074b5b5b5b584000000748400000000007484000000000094b4b4b4a400000000007484748400000074840074840000000000748474840000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868686868686868686868686868686868686
000074b5b5b5b5840000007484000000000074840000000094b4b4b4b4b4a40000000074847484000000748400748400000000007484748400000094b4a40000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868686868686868686868686868686868686
000074b5b5b5b58400000074840000000000748400000094b4b4b4b4b4b4b4a4000000748474840000007484007484000000000074847484000094b4b4b4a400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868686868686868686868686868686868686
000074b5b5b5b58400000074840000000000748400000074b5b5b5b5b5b5b584000000748474840000007484007484000000000074847484000074b5b5b58400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868686868686868686868686a68686868686
000074b5b5b5b58400000074840000000000748400000074b5b5b5b5b5b5b584000000748474840000007484007484000000000074847484000074b5b5b58400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008686868636863747474747474747475786868686
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000009797979797979797979797979797979797979787
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000009797979797979797979797979797979797979787
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000009797979797979797979797979797979797979787
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000009797979797979797979797979797979797979787
__gff__
0000000000000000000000000000000000000000000000000000000000000000000400000000008000800000000000000080800000000000000000000000000001010101010000000000000000000000010101010008102000000000000000000040010000000000000000000000000001010101010100000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051500000000000000051000000000000000000000000000000000000000000
5000000000000000000000000000005050500000000000000000000000006150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050500000000000000051000000000000000000000000000000000000000000
5000000000000000000000000000005050500000000000005051505151505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051500000000000000051000000000000000000000000000000000000000000
5000000000000000000000000000005050500000000000000000000000003150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050500000000000000050000000000000000000000000000000000000000000
5000000000000000000000000000005050500000000000000000000000000051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051000000000000000051000000000000000000000000000000000000000000
5000000000000031000000000000005050502700000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000050000000000000000000000000000000000000000000
5000000000000000000000003100005050500000000000000000000031000051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000052000000000000000051000000000000000000000000000000000000000000
5064646464646464646464646464645050505050424040404140404044646450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000515151515100000000000050525052505250525050505051000000000000000000504341414141440000
5065655121656565652165656565655050505050515050515050515050656550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000500000000000000000000000000060655567656567676765656550000000000000000000500000000000506060
5065655151653165656565656565655050506565656565656565656565652750000000000000000000000000000000000000000000000000000000000000000000000000000000000000434040404040404044000000000000003100000000000060655567656577777765656550525251000000000000500000000000516565
5065215151656565656565656565655050506521656565656565656565656550000000000000000000000000000000000000000000000000000000000000000000000000000000505051216b6b51216b6b6b51310000000000000000000000000060655567656565656565656550000000000000000000503100000000505656
50655151516565656565656565656550505065656565654340404140414040500000000000000000000000000000000000000000000000000000000000000000000000000000000000516b6b6b516b6b6b6b51000000000000003232000000000060655577656665656565656550000000000000000000500000000000516565
50655100516565656532653265656150505065656565655050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000516b6b6b6b6b6b6b6b6b000000004340404040515051525151505250515051505051505050000000005152515251500000000000506565
40404040404040404040404040404040404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000002100005050500000216b6b6b6b6b6b6b6b6b320051515151000000000000000050000000000000000050210000000000000000000000503100000000516565
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000043404040404040404040404040404040405151515151000000000000000000000050000000000000000050515051520000000031000000500000000000506565
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051000000000000506100000000005c000000005c000000005c0000005c0000500052000000000000000050515152515151000000000000502100000000516565
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051003100000000505051525051525051525051525051525051525051525000520050000000000021000050505050505050505000000000504040440000506565
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000210000000000003100002100310000003100000000500052000000000050004600000000000000000000000000500000000000516565
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051000000000000000000000000000000000000000000000000000000000000503150000000000000000000003200000000320000005151500000000000506565
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000031000000000000000000000000000000000000000000000000000000520050000076000076000076000000320000000000515151500000000000516565
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051000050000000000000000000000000000000000000000000000000000000500043404040414042404040404040404040404450505050505151510000506565
0000000000000000000000000000000000000000000000000000000000000000000000000050404040404040500000000000000000000000000000000000005151000051005050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000516565
0000000000000000000000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000000000000000515151000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000506565
0000000000000000000000000000000000000000000000000000000000000000000000000031000000000000000000000000000000000000000000000050510000000051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000052506565
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002100000000000000003232000000005051510000005252000000000000000051505150515051505150515051500000000000000000000000000000000000000000000000000000000000000000000051656565
0000000000000000000000000000000000000000000000000000004340404040404040404044000000000000434041414040404040414241440000505051000000005251000000000000000050655050675050506750505765600000000000000000000000000000000000000000000000434040414041404400000052656565
0000000000000000000000000000000000000000000000000000005000000000000000000050000000000000000000000000005000000000500000510000000000005152000000000000000051656565676565656765655765600000000000000052000021000000000000000000000000506565656765655021000051656565
0000000000000000000000000000000000000000000000000000005000000000000000000050000000000000000000000000005000000000504040510000000000005251000000000000000050656565776565657765655765600000000000000031000050000000000000000000000000516565656765655021000052656565
0000000000000000000000000000000000000000000000000000005100000000000000000051000000000000000000000000005000000000505152510000000000005252000000000000000051656565656565656565655765600000000000510000000000000000000000000000000000505165656777656550515051656565
0000000000000000434041414240440000000000000000000000005100000000000000000051000000000000000000000000005000000000505152510000000000005252000000000000000050656565656565656565655765600000000000000000000031000000002100000000000000516565657765656551505165656565
0000004340404044505050505050500000000000213221005000005100000000000000000051000000000000000000000000005000000000505152510021210000005050000000000000000051656565656565656565655765600000000000000000003200434040404040404400000000506565655065656565656521656565
4142424141424241414242414242414142424141424241414142424141424241414242414242414142424141424241414242414242414142424141424241414242414242414142424141424241414242414242414142424141424241414242414242414142424141424241414242414242414142424141424241414242414242
__sfx__
0001000024650246502465023650226502165021650206501f6501e6501d6501c6501b6501b6501b6502335023350233502335023350233502334023330233602335023350233402334023330233302332023315
000600001b100101501e1500710005100031000100002100011000e10014100131001a1000e10001100011001d100021000210002100011000010000100131001310013100131001310013100141001410014100
000100001a4501b4501b4501a4501a4501a4501945016450194501945016460164600046016470164500040016450164500040016450154500040014450004001345012450124501145010450004001045010450
00010000133500a3500b3500b35011350163501b3501d350223502835030350343503d3503f3503f3500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003b570395703857036550325702e5702857023550215701d5701a5701757016570115700d5702e6702f6703067031670326703267032670336702b670296701b670266502367010650206701c67018670
000100002a6702867027670256702367024670206701f6701c6701b650196701767017670166701567024050230702207020070200701f0701e0701c0701c0701b0701907018070160701407011070100700f070
010300200c7000f7000f7541175011750117501175013750137541675216752187521b7521b7521f7522275223752237522375223752237422374223732237322372223712237102371023710237252370523700
000100000415005150051500515004100041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000012650136501665017650196501b6501d6501f650226502665027650296502b6502c6502e65030650326503465035650316502b65025650216501f6501d6501a650176501465013650116501165010650
000600001a0331b0431a0631b0731a0631b0631a0631b0631a0631b0531a0431b0431a0431b0331a0331b0331a0331b0231a0231b0231a0131b0131a0131b0131a0131b0131a0131b0131a0131b0131f00320003
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
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f0020001700d600006000017000670116000017013600001701560000600001700067019600006001b600001701d6000060000170006702160000170236000017000600006000017000670006000017000600
010f00000a1500a1500a1500a1000a150051000a1500a1500a150061000a150061000a150061000a150061000a150051000a150051000a1500a1500a150031000c150031000d150031000f15003100111500f100
010f00001d4311d4311d4311d4311d4311d4311e4321e4321e4311e4311e4311e4311e4321e4321e4321e4321d4311d4311d4311d4311d4311d4311b4321b4321b4321b4321b4321b4321b4321b4321b4321b432
010f0000161001610016150161501d1501d1501b1501b1501b150000001815018150000000000019132191500000000000161301615000000000001815218152181521815219150191501b1501b1501b1501b150
010f0000161001610016150161701d1701d1701b1701b1701b15000000181301815000000000001913019150000000000016130161500000000000201522015220152201521e1501e1501d1521d1501d15000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c000000355003550535505355003550035500355033550035500355053550735505355053550535505355033550335516355033550c3550335503355033551f35524355003550035500355073550335500355
000b00000c0530c0530c0530c053156530c0530c0530c0530c0530c0530c0530c053156530c0530c0530c0530c0530c0530c0530c053156530c0530c0530c0530c0530c0530c0530c053156530c0530c0530c053
010b0000105021050210502105021c5521c5521c5521c5521b5521b5521b5521b5521555215552155521555214552145521455214552145521455214552145521455214552145521455214552145521455214552
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000021150211501f1501c1502415024150231501f15028150281502615023150241502415028150281502d1502d1502b15028150291502915028150241502615026150281502815029150291502b1502b150
001000002d1522d1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1522f1422f1422f1422f1422f1322f1322f1322f1022f102
010f00000020000200002000020021250212501f2501c250242502425024250242502425024250242502425029250292502825024250262502625024250212502325023250242502425026250262502825028250
001000002925229252282522825228252282522825228252282522825228252282522825228252282522825228252282522825228252282522825228252282422824228232282322823228222282122820228202
010f000000300003000030000300003000030000300003002d3002d3002b30028300293002930028300243002d3522d3522b35228352293522935228352243522d3522d3522b3522b35229352293522835228352
001000002f3002f3002f3522f3522d3522d3522c3522a3522c3522c3522c3522c3522c3522c3522c3522c3522c3522c3522c3522c3522c3522c3522c3522c3422c3422c3322c3322c3322c3222c3122c3122c302
000f00001535215352153521535215352153521535215352133521335213352133521135211352113521135210352103521035210352103521035210352103521a3521a3521a3521a35218352183521835218352
001000001735217352173521735217352173521735217352103521035210352103521035210352103521035210352103521035210352103521035210352103521035210342103421033210322103021030210302
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
01 15 16 17 44
00 15 16 17 44
00 15 16 17 44
00 15 16 17 44
00 15 16 18 44
00 15 16 19 44
00 15 16 18 44
02 15 16 19 44
03 1f 42 43 44
01 20 21 43 44
02 20 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 24 26 28 2a
00 25 27 29 2b
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
