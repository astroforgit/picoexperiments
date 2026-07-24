pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--fly a helicopter, get high
--and make the band happy

max_x = 915
max_y = 190
global_step = 0
player = {}
pickupables = {}

counterstart=false
lasttime = 0
deltatime = 0
maxtime = 180
timer = 180

points = 0

offset=0
offset_x = 0
offset_y = 0
cam = {}
cam_speed = 0.025
player_speed = 0.5
player_slodown = 0.025
istakingdrugs = false
time_to_take_drugs = 130
drug_txt = ""
mode = "intro"
damage_timer = 120
damage_timer_counter = 0
candamage = true
game_over_fadetime = 240
game_over_fade_counter = 0
gameoverstate = "success"

function _init()	
	init_cam()
	if (mode == "intro") _init_menu()
	if (mode == "start") _init_main()	
end



function _update60()			
	delta_time = time() - lasttime	
	check_timer()		
	if (mode == "intro") _update_menu()	
	if (mode == "start") _update_main()	
	if (mode == "gameover") _update_gameover() 	
end
 
function _draw()
  cls(0)
  if(mode=="intro") _draw_menu()
  if(mode=="start") _draw_main()  
		if(mode=="gameover") _draw_gameover()
		lasttime = time()
end

function _update_gameover()
	if(btnp(5)) then		
		reset()
		mode="intro"		
		sfx(19)
	end 
end

function _draw_gameover()
	
	if(gameoverstate == "success") then
		print("you survived",cam.x + 12,cam.y + 3,11)
	end
	if(gameoverstate == "fail") then
		print("you died in an accident",cam.x + 12,cam.y + 3,8)
	end
	
	print("you smoked "..drugs.weed.." joints.", 
						cam.x+12, 
						cam.y+20,7
						)
	spr(41, cam.x+2,cam.y+17)					
						
	print("you took "..drugs.coke.." lines of blow.", 
						cam.x+12, 
						cam.y+30,7
						)
	spr(42, cam.x+2,cam.y+27)					
						
	print("you drank "..drugs.alc.." bottles of booze.", 
						cam.x+12, 
						cam.y+40,7
						)
	spr(43, cam.x+2,cam.y+37)
						
	print("you killed "..#dead_bodies_sprites.." by accident.", 
						cam.x+12, 
						cam.y+50,7
						)
	spr(35, cam.x+2,cam.y+47)
						
	print("you carried "..points.." people", 
						cam.x+12, 
						cam.y+60,7
						)
	
	
	if(points <= 0) then
		print("you don't rock at all",cam.x + 12,cam.y + 75,8)
	end
	if(points > 0 and points < 3) then
		print("at least the band has",cam.x + 12,cam.y + 75,9)
		print("some audience",cam.x + 12,cam.y + 85,9)
	end
	if(points > 3 and points < 5) then
		print("better than no one",cam.x + 12,cam.y + 75,9)
	end
	if(points >= 5) then
		print("the band is excited",cam.x + 12,cam.y + 75,11)
	end
	
						
	print("press — to return to menu", 
						cam.x+12, 
						cam.y+97,7
						)

end

function reset()
	counterstart = false
	timer = maxtime
	points = 0
	player.x = 17*8
	player.y = 15*8
	cam.x = 0
	cam.y = 0
	cam_speed = 0.025
	player_speed = 0.5
	player_slodown = 0.025
	
	drugs_arr = {}
	dead_bodies_sprites  = {}
	particle_systems = {}
	pickupables = {}	
	
	drugs.weed = 0
	drugs.coke = 0
	drugs.alc 	= 0
	
	intro_counter = 1	
end

function check_timer()
	if(counterstart and 
				mode == "start") then
  timer -= (delta_time)
  
  
  if(timer < 0) then
  	timer = 0 
  	game_over_fade_counter += 1
  	if (game_over_fade_counter > game_over_fadetime) then
  	 mode="gameover"
  	 game_over_fade_counter = 0  	 
  	end
  end
	end
end
-->8
--core gameplay

function move_camera()	
	if(mode=="start") then
 	if(player.canmove) then
 		cam.targetx = player.x - cam.width/2 + player.width/2 + offset_x
 		cam.targety = player.y - cam.height/2 + player.height/2 + offset_y
 	end
 	
 	cam.x += (cam.targetx - cam.x) * cam_speed
		cam.y += (cam.targety - cam.y) * cam_speed
 end
	
	
	
	camera(cam.x, cam.y)	end

function move_player()
	if(player.canmove) then
		local oldpos = {
		x = player.x,
		y = player.y
		}
		
		add(last_positions, oldpos)
		
		if(#last_positions > 100) then
			del(last_positions,last_positions[1])
		end		
		
		player.sprx = 8
		player.spry = 0
		
			--left
			if (btn(0) and 
   	 	player.targetx > 64) then
    		player.targetx -= player_speed
   			player.sprx = 8
  				player.spry = 10 
  				player.right = false
   end  
  
  	--right
  	if (btn(1) and 
   			player.targetx < max_x) then   
   			player.targetx += player_speed
  				player.sprx = 8
  				player.spry = 10 
  				player.right = true
  	end    
  
  	--up
  	if (btn(2) and 
     	player.targety > 0) then
   			player.targety -= player_speed
  				player.sprx = 8
  				player.spry = 10  				
  	end
 	 	
 	 --down	
 	 if (btn(3) and 
  				player.targety < max_y) then
   			player.targety += player_speed
  				player.sprx = 8
  				player.spry = 0  	
  	end  	
  	
  	player.x += (player.targetx - player.x) * player_slodown 
  	player.y += (player.targety - player.y) * player_slodown 
    	
   if(not candamage) then
   	damage_timer_counter += 1
   end 	
   if(damage_timer_counter > damage_timer) then
   	damage_timer_counter = 0
   	candamage = true
   end
    	
  	if (spr_collision(player, 0)) then
  			player.targetx = last_positions[1].x
  			player.targety = last_positions[1].y
  			sfx(14)
  	
  		if(candamage) then
  			player.currenthealth -= 20
   		candamage = false
   	end
   	
  			
  	sparkling_particles()		
			cam.isshaking = true  			
  	end
  end
end

function update_grabber()
	grabber = {
			x = ((player.x + player.width/2)),
			y = ((player.y + player.height)	+	7),
			width = 1,
			height= 1
			}	
end

function check_inputs()
		
	if btnp(4) then		
		
		if(not player.iscarrying) then
 		 check_cargo(grabber)	
 	end	
	end
	
	if(btnp(5)) then
		if(player.iscarrying) then		
			player.iscarrying = false
			drop_cargo()		
		end
	end
end

function drop_cargo()	
				foreach (pickupables, 
  		function(obj) 		
  			if(obj.iscarried) then
  				obj.isgrounded = false
  				obj.iscarried = false
  				sfx(8,2,0,20)
  			end 			
  		end)	
end

function check_cargo(hook)
			foreach (pickupables, 
 		function(obj) 		
 			if(box_collision(obj, hook)) then
 				player.iscarrying = true
 				obj.isgrounded = true
 				obj.iscarried = true 				
 				sfx(7,2,0,20)
 			else
 				sfx(6,2,0,5)
 			end 			
 		end)	
end

function check_dudemovement()
	foreach(pickupables, 
		function(obj) 
			if(obj.isgrounded) and
						not obj.iscarried  then
				obj.x = obj.x
				obj.y = obj.y				
			end
			
			if(not obj.isgrounded) and
					(not obj.iscarried) then
				
				check_target(obj)
				
				obj.x = obj.x
				obj.y += obj.gravity
				if spr_collision(obj, 0) then
					obj.isgrounded = true
				end
			end  
			
			if(obj.iscarried) then
				obj.x = player.x + player.width/2 - obj.width/2
				obj.y = player.y + player.height
			
				if(spr_collision(obj,0)) then
					splatter_dude(obj)
					player.iscarrying = false
				end
			
			end	
			
			if(box_collision(obj, player)) then
				splatter_dude(obj)
			end
			
			obj.distance = calcdist(obj.x,obj.y,player.x,player.y)
			
		end)	
		--end foreach
end

iconheight = 0
ihmax = false
ihmin = true

function draw_dudes()
	
	if(iconheight == 0) then
		ihmin = true
		ihmax = false
	end
	if(iconheight > 3) then
		ihmin = false
		ihmax = true
	end
	
	if(ihmin) iconheight += 0.2
	if(ihmax) iconheight -= 0.2
	
	foreach(pickupables, 
		function(obj) 				
			draw_spr(obj) 
			if(obj.iscarried) obj.iconvisible = false
			if(obj.iconvisible) then
				i = obj.drugtype
				circfill(obj.x+obj.width/2+1, obj.y-4+iconheight+1, 4, 0)
				circfill(obj.x+obj.width/2, obj.y-4+iconheight, 4, 6)
				spr(41+i, obj.x, obj.y-8+iconheight)
			end
		end)	
end

function draw_spr(obj)	
 	sspr(
 	obj.sprx, 
 	obj.spry, 
 	obj.sprwidth, 
 	obj.sprheight, 
 	obj.x , 
 	obj.y)
end

function draw_player()	
 	if(player.visible) then
  	sspr(
  	player.sprx, 
  	player.spry, 
  	player.sprwidth, 
  	player.sprheight, 
  	player.x , 
  	player.y,
  	player.sprwidth,
  	player.sprheight,
  	not player.right)
 	end
end

function take_drugs(drugtype)
	--drugtype = flr(rnd(3))
	
	add(drugs_arr, drugtype)
	play_drugs_fx(drugtype)
	
	--weed
	if(drugtype == 0) then
		drugs.weed += 1
		if(player_speed > 1) then
			player_speed -= 1			
		end		
		
		if(player_slodown > 0.01) then
			player_slodown -= 0.01
		end
		
		if(cam_speed > 0.01) then
			cam_speed -= 0.01
		end
	end
	
	--coke
	if(drugtype == 1) then
		drugs.coke += 1
		player_speed += 1		
	end	
	
	--alc
	if(drugtype == 2) then
		drugs.alc += 1
		player_speed += 1
		player_slodown += 0.01
		cam_speed += 0.01		
	end	
end

function check_dead()
	if(player.currenthealth <= 0) then
  if(mode=="start") then
   player.currenthealth = 0
   player.canmove = false   
  end
  
  game_over_fade_counter += 1
  player.visible = false
  
  
  foreach(pickupables, 
		function(obj) 				
			if(obj.iscarried) then
				obj.isgrounded = false
				splatter_dude(obj)
			end
		end)	
  
  
  local interval = game_over_fadetime/15
  	if(explosion_counter > interval) then
  		anim = copy(die_anim)
  		anim.x = player.x + player.width/2 + rnd(20)-10
 			anim.y = player.y + player.height/2 + rnd(20)-10
  		anim.sprno += flr(rnd(2))
  		sfx(22)
  		add(die_anim, anim)
  		
  		explosion_counter = 0
  	else
  		explosion_counter+=1
  	end
  
  if(game_over_fade_counter > game_over_fadetime) then
  	
  	mode="gameover"
  	gameoverstate = "fail"
  	set_music(4)
  	game_over_fade_counter = 0
  end
 end
end
-->8
--calculations
--flag: 0 for emvironment collision

function spr_collision(colobject, flag)	
	collision = false
	
	--initialize rect	
	local _rect = {
		{colobject.x,colobject.y},
		{colobject.x + colobject.width, colobject.y},
		{colobject.x, colobject.y + colobject.height},
		{colobject.x + colobject.width,colobject.y + colobject.height}}
	
	for key, value in pairs(_rect) do
		tile = mget(flr(value[1]/8), flr(value[2]/8))		
		if fget(tile,flag) then 
			collision = true						
			break		
		end
	end		
	return collision	
end

function box_collision(obj, other)
	 if obj.x < other.x + other.width and
     obj.x + obj.width > other.x and
     obj.y < other.y + other.height and
					obj.y + obj.height >other.y then
			return true				
		else
			return false
		end					
end


function splatter_dude(obj)
	body = copy(dead_bodies_sprites)
	body.dx = obj.x
	body.dy = obj.y + 8
	if(obj.isgrounded)	add(dead_bodies_sprites, body)
	if(obj.is_at_target) points -= 1
	del(pickupables, obj)
	killdude_particles = init_particlesystem("blood", 25)
	killdude_particles.origin_x = body.dx
	killdude_particles.origin_y = body.dy
	add(particle_systems,killdude_particles)
	sfx(4)
end

function check_target(obj)
	if(box_collision(obj, tar_area)) then
		if(not obj.is_at_target) then
			points += 1
			obj.is_at_target = true			
			take_drugs(obj.drugtype)			
		end
	end
end

function calcdist(x0,y0,x1,y1)
				
		local dx=x0/1000-x1/1000
  local dy=y0/1000-y1/1000
  local dsq=dx^2+dy^2
 	local distance
 
  if dsq>0 then
    distance = sqrt(dsq)
  elseif dsq==0 then
    distance = 0
  else
    --shouldn't happen
    distance = 32727
  end	
		
		return distance*1000		
end


-->8
--modes menus and dialogue

function _init_menu()
	set_music(4)
end

function _update_menu()	
	cam.x = 20
	cam.y = 20
	move_camera()
	if(btnp(5)) then
		mode = "start"
		_init_main()
		sfx(19)
	end
end

function _draw_menu()
	
	print("rock 'n' roll", 60, 35,7)
	print("helicopter", 65, 45,7)
	print("of", 80, 55,7)		
	sspr(
	96,8,
	32,24,
	68,60	
	)	
		
	print("press — to start", 50, 120,7)


end

dialogue = {
 {line1 = "mayday, mayday...‘",
 	line2 = ""},
 	
 {line1 = "mayday, mayday...‘",
 	line2 = ""},
 	
 {line1 = "rock 'n' roll helicopter?",
  line2 = "do you copy? ... ‘" },
  
 {line1 = "we have a concert going on",
  line2 = "but no one's here. ‘"},
  
  {line1 = "please bring all the people",
  line2 = "to the green dance floor. ‘"},
  
  {line1 = "but be careful ... ‘",
  line2 = ""},
  
  {line1 = "they might have some",
  line2 = "special gifts for you ... ‘"},
  
  {line1 = "the show starts in",
  line2 = timer.." seconds"},
  
  {line1 = "party on!",
  line2 = ""}
  
 }
 
 
intro_counter = 1

function _init_main()
 init_player()
 place_dudes()	
 set_music(0)
 init_deco()
end

function _update_main()	
	global_step += 1			
	if(intro_counter <= #dialogue) then 
	 
	 if(intro_counter == 5) then
	 	cam.targetx = 20*8
	 	cam.targety = 10*8
	 else
	 	cam.targetx = 10*8
	 	cam.targety = 10*8
	 end
	 
		player.canmove = false
		if(btnp(5)) then
			sfx(18)
			intro_counter += 1
		end
	else
		if(timer > 0) player.canmove = true
		counterstart = true
	end	
	
	check_dead()
	check_drug_fx()	
	update_grabber()
	move_player()
	if(timer <= 0) player.canmove = false
	check_inputs()
	check_dudemovement()
	move_particles()		
 move_camera()  
 check_screenshake()
 move_bg()	
 update_deco() 	
 update_hud()
 distance_beep()
end

function _draw_main()

	draw_maps()			
	draw_dudes()
	draw_dead_bodies()
	draw_deco()
	draw_particles()
	draw_grabber()
	draw_player()	
	draw_target_area()
	draw_hud()	
	draw_drug_fx()	
	draw_die_anim()
	if(intro_counter <= #dialogue) then
		draw_intro_text()
	end
end

function draw_intro_text()
	rectfill(cam.x + 0, cam.y+110,cam.x+128,cam.y+128,0)
	
	print
	 (dialogue[intro_counter].line1,
	 	cam.x + 10,
	 	cam.y + 111,
	 	7
	 )
		print
	 (dialogue[intro_counter].line2,
	 	cam.x + 10,
	 	cam.y + 118,
	 	7
	 )

end
-->8
--object definitions
dude = {}
grabber = {}
deco = {}
dead_bodies_sprites = {}
particles = {}
particle_systems = {}


function copy(o)
  local c
  if type(o) == 'table' then
    c = {}
    for k, v in pairs(o) do
      c[k] = copy(v)
    end
  else
    c = o
  end
  return c
end

--animated deco
deco.x = 0
deco.y = 0
deco.width = 8
deco.height = 8
deco.frame = 0
deco.sprheight = 2
deco.sprwidth = 1
deco.step = 0
deco.counter = 0
deco.timer = 30
deco.startframe = 0

--dude
dude = {}
dude.iscarried = false
dude.isgrounded = true
dude.gravity = 0.5
dude.x = 0
dude.y = 0
dude.sprwidth = 8
dude.sprheight = 16
dude.width = 8
dude.height = 16
dude.sprx = 24
dude.spry = 0	
dude.is_at_target = false
dude.distance = 0
dude.drugtype = 0
dude.iconvisible = true


--dead bodies
dead_bodies_sprites.sx = 24
dead_bodies_sprites.sy = 16
dead_bodies_sprites.sw = 8
dead_bodies_sprites.sh = 8
dead_bodies_sprites.dx = 0
dead_bodies_sprites.dy = 0
dead_bodies_sprites.width = 8
dead_bodies_sprites.height = 8
dead_bodies_sprites.x = 0
dead_bodies_sprites.y = 0

--particles
particles.col = 8
particles.height = 1
particles.width = 1
particles.speed = 1
particles.x = 0
particles.y = 0
particles.gravity = 0
particles.tgravity = 1
particles.force = 1
particles.tforce = 0
particles.dead_counter = 250
particles.canmove = true


--particle_systems
particle_systems.origin_x = 0
particle_systems.origin_y = 0
particle_systems._type = ""

function init_player()
	player.x = 17*8
	player.y = 15*8
	player.sprx = 8
	player.spry = 0
	player.sprwidth = 16 	--16
	player.sprheight = 10 --10
	player.width = 16
	player.height= 8	
	player.targetx = player.x
	player.targety = player.y
	player.iscarrying = false
	player.canmove = true
	player.right = true	
	player.maxhealth = 100
	player.currenthealth = 100
	player.visible = true
end

last_positions = {}

grabber.height = 10

--drugs
drugs = {}
drugs.weed = 0
drugs.coke = 0
drugs.alc 	= 0
drugs_arr = {}

function init_cam()
	cam.width = 128
	cam.height = 128
	cam.x = 0
	cam.y = 0
	cam.targetx = cam.x
	cam.targety = cam.y
	cam.isshaking = false
	cam.shakeduration = 10
	cam.shaketimer = 0
end


function place_dudes()	
	d3 = copy(dude)
	d3.drugtype = flr(rnd(3))
	d3.x = 10*8
	d3.y = 6*8
	add(pickupables, d3)
	
	d4 = copy(dude)
	d4.drugtype = flr(rnd(3))
	d4.x = 41*8
	d4.y = 7*8
	add(pickupables, d4)
	
	d5 = copy(dude)
	d5.drugtype = flr(rnd(3))
	d5.x = 39*8
	d5.y = 7*8
	add(pickupables, d5)
	
	d6 = copy(dude)
	d6.drugtype = flr(rnd(3))
	d6.x = 38*8
	d6.y = 12*8
	add(pickupables, d6)
	
	d7 = copy(dude)
	d7.drugtype = flr(rnd(3))
	d7.x = 60*8
	d7.y = 21*8
	add(pickupables, d7)
	
	
	d8 = copy(dude)
	d8.drugtype = flr(rnd(3))
	d8.x = 60*8
	d8.y = 12*8
	add(pickupables, d8)
	
	d9 = copy(dude)
	d9.drugtype = flr(rnd(3))
	d9.x = 77*8
	d9.y = 6*8
	add(pickupables, d9)
	
	d10 = copy(dude)
	d10.drugtype = flr(rnd(3))
	d10.x = 115*8
	d10.y = 9*8
	add(pickupables, d10)
	
	d11 = copy(dude)
	d11.drugtype = flr(rnd(3))
	d11.x = 87*8
	d11.y = 18*8
	add(pickupables, d11)
	
	d99 = copy(dude)
	d99.drugtype = flr(rnd(3))
	d99.x = 89*8
	d99.y = 18*8
	add(pickupables, d99)
	
	d11 = copy(dude)
	d11.drugtype = flr(rnd(3))
	d11.x = 53*8
	d11.y = 2*8
	add(pickupables, d11)
	
	d12 = copy(dude)
	d12.drugtype = flr(rnd(3))
	d12.x = 50*8
	d12.y = 7*8
	add(pickupables, d12)	
	
	d14 = copy(dude)
	d14.drugtype = flr(rnd(3))
	d14.x = 33*8
	d14.y = 18*8
	add(pickupables, d14)
	
	d15 = copy(dude)
	d15.drugtype = flr(rnd(3))
	d15.x = 68*8
	d15.y = 12*8
	add(pickupables, d15)
	
	d16 = copy(dude)
	d16.drugtype = flr(rnd(3))
	d16.x = 96*8
	d16.y = 12*8
	add(pickupables, d16)
end

--target area
tar_area = {}
tar_area.x = 24*8
tar_area.y = 21 *8
tar_area.width = 64
tar_area.height = 8
tar_area.frame = 0
-->8
--map & special effects

--bg_consts
--bg_far
bg_far_x = 0
bg_far_y = 0
bg_far_speed = -0.

bg_near_x = 0
bg_near_y = 0
bg_near_speed = -0.25

function move_bg()
	
		bg_far_x = (cam.x - 5) * bg_far_speed
		bg_far_y = cam.y * bg_far_speed
		bg_far2_x = (cam.x- 5) * bg_far_speed
		bg_far2_y = cam.y * bg_far_speed
		
		bg_near_x = (cam.x - 5) * bg_near_speed
		bg_near_y = cam.y * bg_near_speed
		bg_near2_x = (cam.x - 5) * bg_near_speed
		bg_near2_y = cam.y * bg_near_speed
end

function draw_maps()
	--draw moon
	circfill(250, 90, 32, 7)
	circfill(275, 90, 32, 0)
	
	--bg-layers
	map(0, 32, bg_far_x, bg_far_y, 64, 32) 
	map(0, 32, bg_far_x+64*8, bg_far_y, 64, 32) 
	
	map(64, 32, bg_near_x, bg_near_y, 64, 32) 
	map(64, 32, bg_near_x+64*8, bg_near_y, 64, 32) 
	map(64, 32, bg_near_x+128*8, bg_near_y, 64, 32) 
	--level
	map(0, 0, 0, 0, 128, 64) 
	
	
end

function draw_dead_bodies()
	foreach(dead_bodies_sprites, 
		function(obj) 
			sspr(
			obj.sx,
			obj.sy,
			obj.sw,
			obj.sh,
			obj.dx,
			obj.dy) 
		end)	
end

function draw_particles()
	foreach(particle_systems, 
		function(ps) 			
			foreach(ps, 
				function(particle) 				
					local origin = 
							{x = ps.origin_x,
								y = ps.origin_y}	
        rectfill(particle.x + origin.x,
        particle.y + origin.y,
        particle.x + origin.x + particle.width + particle.height,
        particle.y + origin.y + particle.width + particle.height,
        particle.col)				
				end)			 
		end)
end

function sparkling_particles()	
	sparkling = init_particlesystem("sparkling", 10)
	sparkling.origin_x = player.x
	sparkling.origin_y = player.y	
	add(particle_systems,sparkling)
end


function move_particles()
foreach(particle_systems, 
	function(ps) 			
		foreach(ps, 
		function(p) 	
			oldpos = {x = p.x, y = p.y}
			
			if(p.canmove) then
 			if(ps._type == "blood") then
 				p.x += 1 + p.speed					
 				p.gravity += (p.tgravity - p.gravity) * 0.2
 				p.force += (p.tforce - p.force) * 0.2
 				p.y += 5 + (p.gravity	* p.force)							
 			end	
 			
 			if(ps._type == "sparkling") then
 				p.x += 1 + p.speed					
 				p.gravity += (p.tgravity - p.gravity) * 0.2
 				p.force += (p.tforce - p.force) * 0.2
 				p.y += 5 + (p.gravity	* p.force)							
 			end				
			end			
			
			--destroy particle systems
			p.dead_counter -= 1			
			if(p.dead_counter < 0) then
				del(particle_systems,ps)
			end
			
			--endif
		end)			 
	end)
end



function init_particlesystem(_type,max_particles)
	
	local ps ={}
	ps._type = _type	
	for i = 0, max_particles do		
		
		if(ps._type == "blood") then
 		particle = copy(particles)
 		particle.width = rnd(2)
 		particle.height = rnd(2)	
 		particle.speed = rnd(6)	- 3
 		particle.tforce = 0
 		particle.force = -10 + (rnd(1))
 		particle.gravity = 0
 		particle.tgravity = 4 - (rnd(1))
			particle.col = 8
		end
		
		if(ps._type == "sparkling") then
 		particle = copy(particles)
 		particle.width = 1
 		particle.height = 1	
 		particle.speed = rnd(6)	- 3
 		particle.tforce = 0
 		particle.force = -10 + (rnd(1))
 		particle.gravity = 0
 		particle.tgravity = 4 - (rnd(1))
			particle.col = flr(rnd(2))+9
		end
		add(ps, particle)
	end
	
	return ps
end

function init_deco()
	
	--guitarist
	guitar = copy(deco)
	guitar.x = 15*8
	guitar.y =	19* 8
	guitar.frame = 5
	guitar.sprheight = 2
	guitar.sprwidth = 1
	guitar.startframe = guitar.frame
	add(deco, guitar)

	--drummer
	drummer = copy(deco)
	drummer.x = 17*8
	drummer.y =	19* 8
	drummer.frame = 7
	drummer.sprheight = 2
	drummer.sprwidth = 2
	drummer.startframe = drummer.frame
	add(deco, drummer)
	
		--singer
	singer = copy(deco)
	singer.x = 19*8
	singer.y =	19* 8
	singer.frame = 37
	singer.sprheight = 2
	singer.sprwidth = 2
	singer.startframe = singer.frame
	add(deco, singer)
end

function update_deco()
	foreach (deco, 
  		function(obj) 		
  			obj.step += 1 
  			if(obj.step%20==0) obj.frame+=obj.sprwidth
  			if(obj.frame > obj.startframe + obj.sprwidth) obj.frame = obj.startframe 			
  		end)
end

function draw_deco()
				foreach (deco, 
  		function(obj) 		
  			spr(obj.frame, 
  							obj.x, 
  							obj.y,
  							obj.sprwidth,
  							obj.sprheight)    			
  		end)
end

--target area
function draw_target_area()
	
	c = 11
	
	if(global_step%10==0) tar_area.frame += 1
 if (tar_area.frame > 1) tar_area.frame = 0 	
	
	if(tar_area.frame == 0) c = 3
	if(tar_area.frame == 1) c = 11
	
	
	line(tar_area.x,
						tar_area.y + tar_area.height - 1,
						tar_area.x+tar_area.width,
						tar_area.y+tar_area.height  - 1,
						c)
	
	line(tar_area.x,
						tar_area.y + tar_area.height/2,
						tar_area.x,
						tar_area.y + tar_area.height - 1,
						c)
						
	line(tar_area.x + tar_area.width,
						tar_area.y + tar_area.height/2,
						tar_area.x + tar_area.width,
						tar_area.y + tar_area.height - 1,
						c)						
end

function play_drugs_fx(mtype)
	istakingdrugs = true
	music(mtype+1,0,12)
	
	--weed
	if(mtype == 0) then
		drug_txt = "smoke da ganja"
	end
	
	--coke
	if(mtype == 1) then
		drug_txt = "snow in the summer"
	end
	
	--alc
	if(mtype == 2) then
		drug_txt = "thats a tasty beverage"
	end
end

function check_drug_fx()
	if istakingdrugs then
		time_to_take_drugs -= 1
	end
	if time_to_take_drugs < 0 then
		music_start()
		istakingdrugs = false
		time_to_take_drugs = 130
	end
end

function draw_drug_fx()
	if istakingdrugs then
		print(drug_txt, player.x-25, player.y - 8)
	end	
end



function screen_shake()
 local fade = 2
 offset_x=16-rnd(32)
 offset_y=16-rnd(32)
 offset_x*=offset
 offset_y*=offset 
 
 offset*=fade
 if offset<0.05 then
   offset=0
 end
end

function check_screenshake()
	if(cam.isshaking) then
		offset=10
		cam.shaketimer += 1
	end
	
	if(cam.shaketimer > cam.shakeduration) then
		offset = 0
		cam.shaketimer = 0
		cam.isshaking = false
	end
	
	screen_shake()	
end

die_anim = {}
die_anim.sprno = 13
die_anim.x = 0
die_anim.y = 0
die_anim.lifetime = 60

function draw_die_anim()
	
	foreach(die_anim, 
		function(obj) 			
			obj.lifetime -= 1
			spr(obj.sprno, obj.x, obj.y)			
			if(obj.lifetime < 0) then
				del(die_anim, obj)
			end
		end)		
end

explosion_counter = 0


-->8
--music and sound

function music_start()
	music(0,0,12)	
end

current_music = 0
function set_music(p)
	music(p,0,12)
end

--beep sound

function distance_beep()
	sm_dist = 2000
	if(player.canmove and
				player.iscarrying == false) then
 	for i=1, #pickupables do
 		if not(pickupables[i].iscarried) and
 					not(pickupables[i].is_at_target)
 		then
 			sm_dist = min(sm_dist, pickupables[i].distance)
 		end
 	end	
	end
	
	if(sm_dist < 200) then
			local i = flr(sm_dist/4)
			if(global_step%i==0) then
				sfx(5,3,0,5)
			end
	end	
end


-->8
--hud
function update_hud()

end

function draw_hud()
	local x = 80
	local y = 5
	local entries = 5	
	draw_healthbar()
	draw_timer()
	draw_points()
--	draw_left_people()
	--draw_timeleft()
	--draw left corners
	spr(11,cam.x + x,cam.y + y)
	spr(11,cam.x + x,cam.y + y + 8,1,1,false,true)
	
	--draw lines
	for i=1, 4 do
		spr(12,cam.x + x + 8 * i,cam.y + y)
		spr(12,cam.x + x + 8 * i,cam.y + y + 8, 1,1,false,true)
	end
	
	--draw right corner
	spr(11,cam.x + x + 40,cam.y + y,1,1,true,false)
	spr(11,cam.x + x + 40,cam.y + y + 8,1,1,true,true)

	--draw items
	local spr_start = 41	
	
	for d = 1,#drugs_arr do 		
 			yoffset = 0
 			xoffset = d-1
 			if(d > 5) then
 				yoffset = 8
 				xoffset = d-6
 			end
 			
 			spr(spr_start+drugs_arr[d],
				cam.x + x + (xoffset)*8,
				cam.y + y + yoffset) 			 		
 end 
 print("drug-o-meter:",
 						cam.x + 81,
 						cam.y + 2,
 						0)
 print("drug-o-meter:",
 						cam.x + 80,
 						cam.y + 1,
 						7)
end

function draw_healthbar()
	print("’ shield", cam.x + 6, cam.y+3, 0)
	print("’ shield", cam.x + 5, cam.y+2, 7)
	
	rectfill(cam.x + 5,
										cam.y +10,
										cam.x + (player.currenthealth/player.maxhealth)*60,
										cam.y + 12, 8)
	rect(cam.x + 4,
						cam.y + 9,
						cam.x + 61,
						cam.y + 13, 5)
end

function draw_grabber()
	if(not player.iscarrying) and
				player.visible then
			line(player.x + player.width/2,
						player.y + player.height,
						grabber.x,
						grabber.y,
						9)
	end
end

function draw_timer()
	spr(57, cam.x + 5, cam.y+15)
	print("time: "..flr(timer), cam.x + 21, cam.y + 18, 0)
	print("time: "..flr(timer), cam.x + 20, cam.y + 17, 7)
end

function draw_points()
 print("‰  audience: "..points,cam.x + 6, cam.y + 28, 0)
 print("‰  audience: "..points,cam.x + 5, cam.y + 27, 7)
end
__gfx__
00000000000000000000000000dddd0000dddd000004440000044400000002222222000000002222222200000055555555555555008888800000000000088000
000000000000055555555555011111d0011111d00044444000444440000002fffff22000000022fffff2200005766666666666660887778800088800088a8800
007007005600000000550000011111100111111004fffff404fffff400000233333320000000223333332000571111111111111108a77778008aaa8008a7a880
00077000650000000544dd0001f11f1001f11f1004f1ff1404f1ff1450000fbbfbbf200500002ffbbfbb200056111111111111118aa7777808a777a88a777a80
0007700005555555544111d00f1ff1f00f1ff1f004fffff404fffff405000fffffff225000002fffffff200056111111111111118a7777a808aa77a888a7a880
00700700000000055444111d0ffffff0ffffffff04feeff004ffeef000500ffeeff2250000002ffffee2200056111111111111118aaaaaa8008aaaa8088a8800
00000000000000005444411d00f55f0040f55f04044ee440044fee40000f022eeff2f2000005f22ffee2f000561111111111111108aaaa880008888000088000
000000000000000005554440004ff400904ff40900444400004444000aa0555555552aa00a505555555525a05611111111111111008888000000000000000000
000000000000000500055005099aaaa0099aaaa000fff00500fff0009999d111d11199999599d111d11199590000000000000000000000000000000000088000
00000000000000005555555090999a0a00999a000fcccf55ffcccf000500d111d11105000500d111d11105050000000000088800000000000000000880088000
00000000000005555550000040444404004444000faaa5f0f0aaaf55050000555500050005000055550005000000000008888888000000000000000880088000
000000005600000000055555f04ddd0f00dd44000aff9c00aff99550050005dd11500500050005dd115005000000000088880088800000000000000880088000
00000000650000000055000000ddd50000dddd000a99cc00aa99c0f005005dd11115050005005dd1111505000000000000880008880000000000008888088000
00000000055555500544dd0000d0050000d00d0009900c009990cc0005005dd11115050005005dd1111505000000000000880000880000000088800880088880
0000000000000005544111d0005005000050050000c00c0000c00c00050005dd11500500050005dd115005000000000000880000880000000088880880088880
00000000000000005444111d04400440044004400044044000440440505000555500505050500055550050500000000000880000880088880800880880088808
00000000000000005444411d0000000000000000000000bbbb000000000000bbbb00000000000000000000000000000000880000880880080800880888088808
000000000000000005554440000000000000000000000bbbbbb0000000000bbbbbb0000000000000000000000000000000880088880800880800880088008008
00000000000000050005500500070077000000000000bbffffbb00000000bbffffb0000000000000000000000000004008888888888888000888880088008008
00000000000000005555555000770070000000000000b2222222000000002222222b000000003000000009000000440088888800008000008800088088008008
0000000000000000000555550088888000000000000bb222f2220000000b222f222b000000303030000090000007440000000000008800088000000088008008
00000000000005555555000008d111180000000000bbbffbbbf00000000bbfbbbffb000000033300000767000047700000000000000888880000000088008000
00000000000000000054dd0088555518000000000bb0bfb77b550000000bbfbeeb55b00000303030007676700004000000000000000000000000000088008000
0000000056000000054111d08440084800000000bb00bffeef55655000bbbffeef55655000000000000000000000000000000000000000000000000088008000
00000000650555555444111d0000000000000000000b0affff0005000bb0faffffbbb5b000555500000000000000000000000000000000000000000088008000
00000000055000055444411d000000000000000000bff9a9a9ff050000fff9a9a9fff5b005717750000000000000000000000000000000000000000008008000
00000000000000005444544400000000000000000bb0fa9a9af0050000000a9a9a00050057717775000000000000000000000000000000000000000008000000
00000000000000000055550000000000000000000b0009a9a9000500000009a9a900050057717775000000000000000000000000000000000000000008000000
00000000000000005000555500000000000000000000044544000500000004454400050057771115000000000000000000000000000000000000000008000000
000000000000000005550000000000000000000000000a90a900050000000a90a900050057777775000000000000000000000000000000000000000008000000
0000000000000000000000000000000000000000000009a09a000500000499000aa4050005777750000000000000000000000000000000000000000008000000
000000000000000000000000000000000000000000000a44a4405050000049000040505000555500000000000000000000000000000000000000000000000000
00011000111111111111111100000000888888880000000000000000000000000000000000000000000000000000000044404440777777771212121201010101
00111100171717111771177100008000888888880000000000000000000000000000000000000000000000000000000044440444777777772121212110101010
0111111011111111177117710000100088000088000000000000000000000000006666660000000000000000000000004404444477777777121212120101a101
1111111111171711111111110000100008800880000000000000000000000066666666660000000000000000000000000400444477777777212121211019a910
11711711111111111111111100001000008888000000000000000000000000666666666666000000000000000000000044444444777777771212121201aa7aa1
1171171117171111177117710000100000888800000000000000000000666666666666666666666600000000000000004444444077777777212121211019a910
1171171111111111177117710000100008800880000000000000000000666666666666666666666666666660000000004440444077777777121212120101a101
11111111111717111111111100001000888888880000000000000000066666666666666666666666666666600000000000444444777777772121212110101010
1111111111111111111111110000100066666666555555550000000006666666666666666666666666666660ddddddddeeeeeeee666666662222222211111111
1111171111171111111111110000100055556555444445440000000000666666666666666666666666666600ddddddddeeeeeeee666666662222222211111111
1111171111111111111111110000100055556555444445440000000000000000066666666666666666000000ddddddddeeeeeeee666666662222222211111111
1111171117171711111111110011110055556555444445440000000000000000006666666666666660000000ddddddddeeeeeeee666666662222222211111111
1111111111111111111111110111111066666666555555550000000000000000000066666666600000000000ddddddddeeeeeeee666666662222222211111111
1111111111171711111117711111111155655555445444440000000000000000000000666660000000000000ddddddddeeeeeeee666666662222222211111111
1111111111111111111117711111111155655555445444440000000000000000000000000000000000000000ddddddddeeeeeeee666666662222222211111111
1111111111111711111111111111111155655555445444440000000000000000000000000000000000000000ddddddddeeeeeeee666666662222222211111111
11111111111111111111111100011110000598000000000000000000000000000000000000000000000000000000000000000000010101011111111111111111
117111111717171117771111001111100005988000000000000000000000000000000000000000000000000000000000000000001010a0101111a11111111111
1171111111111111111111111111111100059888000000000000000000000000000000000000000000000000000000000000000001017101111171111111a111
11711111111717111777177117171711000598800000000000000000000000000000666666666600000000000000000000000000101a7a10111a7a111119a911
117111111111111111111111111111110005980000000000000000000000666666666666666666666000000000000000000000000a77777a1a77777a11aa7aa1
11111111171711111777177117111111000500000000000000000000000066666666666666666666666660000000000000000000101a7a10111a7a111119a911
1111111111111111111111111711111100050000000000000000000000666666666666666666666666666000000000000000000001017101111171111111a111
111111111117111111111111111111110005000000000000000000000066666666666666666666666666666600000000000000001010a0101111a11111111111
11111111111111111111111100100000111111111111111111111111000066666666666666666666666666660000000000000000000000000000000001010101
111111111717171117117111011001001171111111171111111111110000666666666666666666666666666600000000000000000000a0000000000010101010
11711711111111111711711101100100111111111111111117111111000000066666666666666666666000000000000000000000000070000000a00001010101
11711711111111111711711101100100111111111111111111111111000000000006666666666666000000000000000000000000000a7a000009a90010101010
117117111111111111111111011011001111111111111111111111110000000000066666666666600000000000000000000000000a77777a00aa7aa001010101
11711711111111111177711101101100111111111111111111111111000000000000000066666000000000000000000000000000000a7a000009a90010101010
11111111111111111177711101101110171111111111171111111711000000000000000000000000000000000000000000000000000070000000a00001010101
111111111111111111777111111111111111111111111111111111110000000000000000000000000000000000000000000000000000a0000000000010101010
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f5f5f6f5f5f5f5f5f5f5f5f5f5e6f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f6f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f5f5f5f5f5f5f5f5f5f6f5f5f5f5f5f5f5f6f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f5f5f5f5e6f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
0000000000000000000000000000000000000000000000000000768696a600000000000000000000000000000000000000000000000000000000000000000000
f5f5f5f5f5f5f5f5f7f7f4f7f7f7f7f7f7f7d6f7f7f7f7f7f7f7f7f4f7f7f7f7f7f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
00000000000000748494a4000000000000000000000000000000778797a700000000000000000000000000000000000000000000000000000000000000000000
f7d6f7f7f7f7f7f7f7f7f7d6f7f7f4f7f7f7f7f7f4f7f7f4f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f5f5f5f5f5
00000000000000758595a500000000000000000000000000000000000000000000000000768696a6000000000000000000000000000000000000000000000000
f7f7f7f7f7f7f7f7f4f7f7f7f7f7f7f7f4f7f7f7f7f7f7f7f7d6f7f7f7f7f7f7f7f7f7f7f7f7f7f7d6f7f7f7f7f7f7f7f7f7f7f7d6f7f7f7f7f7f7f7f7f7f7f5
000000000000000000000000000000000000000000000000000000000000000000000000778797a700000000748494a400000000000000000000000000000000
f7f7f7f7f4f7f7f7f7f7e4e4e4e4e4e4e4e4e4e4e4e4e4f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000758595a500000000000000000000000000000000
e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f7f7f7f7f7f7f7f7f7f7e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f7f7f7f7f7f7
000000000000000000000000000000000000000000000000000000768696a6000000000000000000000000000000000000000000000000000000000000000000
e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f7f7f7f7f7f7f7e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f7f7f7f7
0000000000000000000000748494a400000000768696a600000000778797a70000000000000000000000000000000000000000768696a6000000000000000000
e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f7f7f7f7f7f7f7f7f7e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f7f7f7f7e4e4e4e4e4e4e4e4e4
0000000000000000000000758595a500000000778797a7000000000000000000768696a6000000000000000000000000000000778797a700000000748494a400
e4e4e4e4e4e4e4e4e4c5c5c5c5c5e4e4e4e4e4e4e4e4f7e4e4f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f4f7f7f7f7f7f7f7f7f7f7f7f7d6f7f7f7e4e4e4e4e4e4e4
0000748494a4000000000000000000000000000000000000748494a400000000778797a700000000000000768696a6000000000000000000000000758595a500
c5c5e4c5c5c5c5e4e4c5c5c5c5c5c5c5e4c5c5c5e4e4f7f7f7f7f7f7f7f7f7f7f7f7f7f7f4f7f7f7f7f7f7d6f7f7f7f7f7f4f7f7f7f7f7f7f7f4e4e4e4e4e4e4
0000758595a50000768696a6000000000000000000000000758595a5000000000000000000000000000000778797a70000000000000000000000000000000000
c5c5c5c5c5c5c5e4e4e4e4c5c5c5c5c5c5c5c5c5c5e4e4f7f7f7f7e4e4e4e4f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
0000000034000000778797a7000000000000000000000000000000000000000000000000748494a4000000000000000000000000000000000000000000000000
c5c5c5c5c5c5c5c5c5c5e4e4e4c5c5c5c5c5c5c5c5e4e4f7f7c5c5c5c5c5e4f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7e4e4e4e4f7f7f7f7d6f7f7f4f7f7
000000000400003400000000000000000000000000000000000000000000000000000000758595a500000000000000000000748494a400000000000000000000
c5c5c5c5c5c5c5c5c5e4e4e4e4e4e4e4e4e4c5c5e4e4e4e4c5c5c5c5c5c5e4e4f7f7f7f7f7f7f7e4e4e4e4e4f7f7f7f7f7e4c5c5c5e4f7f7f7f7f7c5c5c5f7e4
0400000014000004000000000000000000000000000000000000000000000000000000000000000000003400000000000000758595a500000000000000000000
c5c5c5c5e4e4e4e4e4e4e4e4e4e4e4e4e4e4c5c5c5e4e4c5c5c5c5c5c5e4e4e4e4e4e4e4e4e4e4e4c5c5c5e4f7e4e4e4e4c5c5c5c5c5e4e4e4e4e4c5c5c5c5e4
07000000143700143700343600748494a4000000768696a600000000768696a60000000000000000003604000004000000000000000000370034000000000000
c5c5c5e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4c5c5c5c5c5c5e4e4e4e4e4e4e4e4e4e4e4c5c5c5e4e4e4d5e4e4e4c5c5c5c5e4e4e4e4e4e4e4c5c5e4
07140000150605051517240600758595a5000000778797a700000000778797a700000000000000000014050014260037003400000000001437360000768696a6
e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4c5c5c5c5e4e4d5d5d5e4e4e4e4c5c5e4e4e4e4e4c5c5c5c5c5e4
071717170514142615152406000000000000000000003400000000000000000000000000000000000014063714070024243500768696a61415060000778797a7
e4e4e4e4e4e4e4e4e4d5d5d5d5d5d5d5d5d5d5d5d5d5e4e4e4e4e4e4e4e4e4e4e4e4d5e4e4e4d5d5d5d5d5d5d5d5d5d5e4e4e4e4e4e4d5e4e4c5c5c5c5c5d5d5
0757575717141414161625060400000000748494a43604000004000000000000748494a4003400000015071516060024251500778797a7152607000000003500
d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5e4e4e4e4e4e4e4d5d5e4e4d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5e4c5c5c5d5d5d5d5d5
4747474747475724571705150604000000758595a51405001426003700340000758595a50024240000160615250500242414000000043715272600003736f535
d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5e4e4e4d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5
674767474747575757570616060637370034340000140637140700242435000000000000002525000015071424073625241600000015160607051426f5f5f547
d5d4d4d4d4d4d4d4d4d4d4d4d4d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5
4747674767474757570706142625162637363500001507151606002425150000000000000024240000140516262726242515373737141547f5471525f55757f5
d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d5d5d4d4d4d4d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d4d4d4d4d4d4d4d4d4d4d4d4d4
476747474747475705050715152616f547f5240000160615250500242414003400370034002524003614f5f5f5f5f5f5571526262616f5f5f5f5f5f5476757f5
d4d4d4d4d4d4d4f5f5d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4
f5f5f5f5f547f5f5f54757f5f557f5f5f5571600001507142407362524160036001437360024250015f557f5f557f5f5f5f547f5f5f557f5f567f5f5f5f5f5f5
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
f5f5f567f5f5f5f5f5f5f5f5f5f5f5f567f515000014051626272624251500140014150616f524f567f5f5f567f5f547f5f5f5f547f5f567f5476757f567f5f5
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
f567f5f5f557f5f557f5f5f567f5f5f5f5f524373614f5f5f5f5f5f5571500150015260767f55747f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
47f5f547f5f5f5f5f567f5f5f5f557f547f5f56715f557f5f557f5f5f5f54705f5152726f5f5f547f5f5f547f5f5f567f5f557f5f557f5f5f557f5f5f5f5f5f5
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
47f5f5f5f5f5f5f5f557f5f5f5f5f5f56747f5f567f5f5f567f5f547f5f5f557f547f557f547f5f557f5f5f5f557f5f5f547f5f5f5f5f5f5f5f5f5f567f5f5f5
__gff__
0080800202020202020000000000000000808000020202020200000000000000008080000000000000000000000000000080800000000000000000000000000000000000010000000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5454545454545400000000000000000000000000000000000000000000000000545400000000000000005454540000000000000000000000000044000000000000000000000000000000440000000000000000000000000000000000004400000000000000000000000000000000000000000000000000004400000000545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000005454540000000000000000000000000044000000000000000000000000000000440000000000000000000000000000000000004400000000000000000000000000000000000000000000000000004400000000545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000005454540000000000000000000000000044000000000000000000000000000000440000000000000000000000000000000000004400000000000000000000000000000000000000000000000000004400000000545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000005454540000000000000000000000000044000000000000000000000000000000440000000000000000000000000000000000004400000000000000000000000000000000000000000000000000004400000000545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000005454540000000000000044444444444444545454545454545400000000000000440000000000000000000000000000000000004400000000000000000000000000000000000000000000000000004400000000545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000005454540000000000000000000000000000000000000000000000000000000000440000000000000000000000000000000000004400000000000000000000000000000000000000000000000000004400000000545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000005454540000000000000000000000000000000000000000000000000000000000440000000000000000000000000000000000004400000000000000000000000000000000000000000000000000004400000000545454
5454545454545400000000000000000000000000000000000000000000000000000000000000000000005454540000000000000000000000000000000000000000000000000000000000440000000000000000000000000000000000004400000000000000000000000000000000000000000000000000005454545454545454
5454545454545444444444444444444444440000000000000000000000000000000000000000000000005454540000000000000000000000000000000000000000000000000000000000444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000005454545454545454
5454545454545400000000000000000000000000000000000000000000000000545444444400004444444444444444440000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005454545454545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054545454545454545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005454545454545400000000000000000000000000000000000000000000000054545454545454545454545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005454545454545400000000000000000000000000000000000000000000000054545454545454545454545454
5454545454545400000000000000000000000000000000000000000000000000545400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005454545454545400000000000000000000000000000000000000000000000054545454545454545454545454
5454545454545400000000000000000000000000000000000000000000000000545444444444444444444444000000000000000000000054545444545454545454545454545454545454540000000000000000005454545454545454545454444444444444000000000000000000000000000054545454545454545454545454
5454545454545400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054545454545454545454545454
5454545454545400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054545454545454545454545454
5454545454545400000000000044444444444444444444000000000000000000000000000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054545454545454545454545454
5454545454545400000000000000446e6f6f6e6f6e4400000000000000000000000000000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054545454545454545454545454
5454545454545400000000000000445f5f5f5f5f5f4400000000000000000000000000000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000000000006565656565656565656565650065000000000000000000000054545454545454545454545454
5454545454545400000000000000445f5f5f5f5f5f4400000000000000000000545454000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000545454545454545454545454656565656565654444444444444444444444444454545454545454545454545454
5454545454545400000000000000444444444444444400000000000000000000545454000000000000000000000000000000000000000000000044000000000000000000000000000000000000000054545454545454545454545454545454656565656565654465000000000000000000000054545454545454545454545454
5454545454545454545454545454545454545454545454544444444444444444545454000000000000000000000000000000000000000000000044000000000000000000000000000000005454545454545454545454444444444444444444444444444444444465000000000000000000000054545454545454545454545454
5454545454545454545454545454000000000000545454540000000000000000545454000000000000000000000000000000000000545454545454545444444444444444444444444444445454545454545454545454000000006565656565656565656500004465000000000000000000000054545454545454545454545454
5454545454545454545454545454000000000000545454540000000000000000545454444444444444444444444444444444444444545454545454545400000000000000000000000000445454545454545454545454000000006565656500000000000000004400000000000000000000000054545454545454545454545454
5454545454545454545454545454000000000000545454540000000000000000545454000000000000000000000000000000000000545454545454545400000000000000000000000000445454545454545454545454000000006565656565656565656565654465656500000000000000000054545454545454545454545454
5454545454545454545454545454000000000000545454540000000000000000545454000000000000000000000000000000000000545454545454545400000000000000000000000000445454545454545454545454000000006565656565656565656565654465656500000000000000000054545454545454545454545454
5454545454545454545454545454000000000000545454540000000000000000545454000000000000000000000000000000000000545454545454545400000000000000000000000000445454545454545454545454000000006565656565656565656565654465656500000000000000000054545454545454545454545454
5454545454545454545454545454000000000000545454540000000000000000545454000000000000000000000000000000000000545454545454545400000000000000000000000000445454545454545454545454000000000000000000000000000000004400000000000000000000000054545454545454545454545454
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
__sfx__
001400001d000000000b35002350023500b350023500000010450180001a100121001410002000020000200010250010000100001000010000100003000010001025000000000000000000000000000000000000
0014000000000000000b00002250021500b2500215004100041700425004150042500415004350041500425004170042500415004250041500435004150042500417004250041500425004150043500415004250
0014000001600157000160004600036000360003600000000c630000000000000000000000000000000000000c630000000000000000000000000000000000000c6303a600386000000000000000000000000000
001400000167001500000000000000000000000000000000266500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000191501665014150136501115010650101500e6500e1500c6500c1500b6500b1500a650091500765007150056500615004650041500260002600026000260002600026000260001600016000160001600
000101003505035050360503705037050370503705038050390503a0503b0503c0503d0503d0503e0503e0503e0503f0500430003300023000230002300023000230002300023000230001300013000130001300
000100000c1503165029650236501d65017650126500c650076500465001650381003710036100341002f1002910020100191000e100021000b1000b1000b1000f0000a1000a1000910009100081000810007100
000200000e3500f350103501035011350133501335014350153501635016350173501835018350193501a3501b3501c3501d3501f350223502335026350283502a3502d3502e3503035033350343503635038350
000400003c75035750307502c75029750267502475022750207501f7501d7501c7501b7501a750197501875018750177501675016750157501575015750147501475013710137501375013750137501275012750
0006000001150011500215003150031500415007150011500215002150031500515006150081500915002150031500415005150061500715008150021500215004150051500615007150091500a1500c1500d150
0006000010650106501165011650116501265012650126501265012650126501265013650136501365013650146501565017650196501a6501c6501d6501f650216502365026650296502f65033650386503f650
00140000090500910009050210002155021000210002100009050120000905018000215501a00018000120000b0000a0000c00012000190001a000160000d0000b0000c0000f000160001c0001b000160000e000
001400001c00002600000000260018550016000160001600016000160001600026001855002600026000260002600026000260002600026000260002600026000260002600026000360003600036000360003600
001400001f0000000000000000001c550000000000000000000000000000000116001c55012600126001260011600116001160011600116001060010600106001060011600116001160011600106000f6000e600
00020000396503965039650196501a6501865013650106500f6500d6500d6500b1500b1500b1500b1500b1500b1500c1500d1500e150101501315015150171501815018150181501715014150101500b1500a150
00070000396503b65005350053500435035650326502e650053500a3500d35031650346500b3500b3503c6500935009350356500835008350083502f6500b3500c35039650083503a6500635008350073502b650
001000000000008350083501a6501d65021650216500835017650196501d6500b35000000206502165009350000001c6501b6501a6500935009350000001a6501c6501d6501d6500735020650206502065000000
000d00002a6502b6502a65004350123501235006350053501e6501d6501b6501a6501a65019650053500635006350133501335006350186501a6501b6500a3500e35012350143502565026650276500000000000
0001000026050220501f0501d0501c0501b0501a0501a0501805018050170501605015050140501305012050120501205012050120501305013050140501505017050190501a0501c0501f050210502305025050
000100000b0500d0500f05015050170501a0501c0501f0502105023050270502a0502c0502f0503305035050380503c0503f0503f050010002b0002d0002f00031000330003400036000380003a0003b0003d000
011400000c043306003f3153060030615306003f3150c0000c043000003f3153060030615000003f3150c0000c043000003f3153060030615000003f3150c0000c043000003f3153060030615306003f3153f315
011400000a1540a1551015510154181551815514155111550d1500d1510f1521115213152141511415114151141551415514155121550e1550d1550f156131562015120152201522015213152131521315213153
010100000d1500d1500e7300e7200e7200615006150071501163007150106300f7300f7200115001150011500f6000f6000110001100011000e6000e6000e600011000e6000e6000e60002100021000110001100
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 00 01 02 44
03 0b 0c 0d 44
03 0a 42 43 44
03 09 42 43 44
03 14 15 43 44
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
