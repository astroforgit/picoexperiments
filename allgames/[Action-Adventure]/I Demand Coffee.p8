pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- a coffee filled platformer
-- by sebastian lind

music_t="ç music:"
camera_anim_t="> anim cam:"
function _init()
	--font by mangagore
	poke(0x5600,4,4,7)
	poke4(0x5700,unpack(split"0x0000.0000,0x0000.0000,0x0202.0202,0x0000.0200,0x0000.0505,0x0000.0000,0x0505.0705,0x0000.0507,0x0407.0106,0x0000.0203,0x0204.0100,0x0000.0401,0x0102.0502,0x0000.0305,0x0000.0102,0x0000.0000,0x0101.0102,0x0000.0201,0x0202.0201,0x0000.0102,0x0205.0000,0x0000.0005,0x0702.0000,0x0000.0002,0x0000.0000,0x0000.0102,0x0700.0000,0x0000.0000,0x0000.0000,0x0000.0200,0x0202.0404,0x0000.0101,0x0505.0506,0x0000.0305,0x0202.0302,0x0000.0702,0x0204.0403,0x0000.0701,0x0403.0403,0x0000.0304,0x0406.0505,0x0000.0404,0x0403.0107,0x0000.0304,0x0503.0106,0x0000.0605,0x0204.0407,0x0000.0202,0x0502.0506,0x0000.0305,0x0605.0503,0x0000.0304,0x0002.0000,0x0000.0002,0x0002.0000,0x0000.0102,0x0102.0400,0x0000.0402,0x0007.0000,0x0000.0007,0x0402.0100,0x0000.0102,0x0204.0403,0x0000.0200,0x0505.0506,0x0000.0601,0x0604.0300,0x0000.0705,0x0505.0301,0x0000.0705,0x0101.0600,0x0000.0701,0x0505.0604,0x0000.0705,0x0705.0600,0x0000.0601,0x0702.0204,0x0000.0202,0x0705.0600,0x0000.0304,0x0505.0301,0x0000.0505,0x0202.0002,0x0000.0202,0x0202.0002,0x0000.0102,0x0305.0101,0x0000.0505,0x0202.0202,0x0000.0402,0x0707.0300,0x0000.0507,0x0505.0300,0x0000.0505,0x0505.0600,0x0000.0305,0x0305.0700,0x0000.0101,0x0705.0600,0x0000.0404,0x0101.0600,0x0000.0101,0x0701.0600,0x0000.0304,0x0207.0202,0x0000.0202,0x0505.0500,0x0000.0705,0x0505.0500,0x0000.0205,0x0705.0500,0x0000.0507,0x0205.0500,0x0000.0505,0x0605.0500,0x0000.0304,0x0204.0700,0x0000.0701,0x0101.0103,0x0000.0301,0x0202.0101,0x0000.0404,0x0202.0203,0x0000.0302,0x0000.0502,0x0000.0000,0x0000.0000,0x0000.0403,0x0000.0201,0x0000.0000,0x0507.0506,0x0000.0505,0x0507.0503,0x0000.0705,0x0101.0106,0x0000.0701,0x0505.0503,0x0000.0305,0x0103.0107,0x0000.0701,0x0301.0106,0x0000.0101,0x0501.0106,0x0000.0705,0x0507.0505,0x0000.0505,0x0202.0207,0x0000.0702,0x0404.0407,0x0000.0304,0x0503.0505,0x0000.0505,0x0101.0101,0x0000.0701,0x0507.0705,0x0000.0505,0x0505.0503,0x0000.0505,0x0505.0506,0x0000.0305,0x0103.0507,0x0000.0101,0x0505.0506,0x0000.0403,0x0503.0507,0x0000.0505,0x0407.0106,0x0000.0304,0x0202.0207,0x0000.0202,0x0505.0505,0x0000.0705,0x0505.0505,0x0000.0205,0x0705.0505,0x0000.0507,0x0202.0505,0x0000.0505,0x0205.0505,0x0000.0202,0x0202.0407,0x0000.0701,0x0302.0204,0x0000.0402,0x0202.0202,0x0000.0202,0x0602.0201,0x0000.0102,0x0704.0000,0x0000.0001,0x0205.0200,0x0000.0000"))
	poke(0x5f58,0x81)

	palt(14, true) -- dark brown is transparent
 	palt(0, false)
	--setup palette
	pal(1, 130, 1)
	pal(5, 133, 1)
	pal(13, 141, 1)
	pal(6, 134, 1)
	pal(11, 139, 1)

	cartdata("elstiskalinjen_coffee")
	music_store = dget(1)
	if (music_store == 1) then music_on = false else music_on = true end
	animate_camera_store = dget(2)
	if (animate_camera_store == 1) then animate_camera = false else animate_camera = true end

	menuitem(1, music_t..is_on(music_on), function() toggle_music_on() end)
	menuitem(2, "Ü reset player", function() reset_to_checkpoint() end)
	menuitem(3, camera_anim_t..is_on(animate_camera), function() toggle_animate_camera() end)
	set_music(music_on and 3 or -1, 200)

	music_channel = 2
	coffee_found = 0
	
	init_start_screen()
	--start_game()
	--game_state = 2
	--init_game_won()
end

function toggle_music_on()
	music_on = not music_on
	music_store = music_on and 0 or 1
	dset(1, music_store)
	menuitem(1, music_t..is_on(music_on), function() toggle_music_on() end)
	sfx(16)
	if not music_on then 
		set_music(-1, 0)
	else
		if game_state == 1 then 
			set_music(0,200)
		else
			set_music(3,200)
		end
	end
end

function toggle_animate_camera()
	animate_camera = not animate_camera
	animate_camera_store = animate_camera and 0 or 1
	dset(2, animate_camera_store)
	menuitem(3, camera_anim_t..is_on(animate_camera), function() toggle_animate_camera() end)
	sfx(16)

	return false
end

function reset_to_checkpoint()
	destroy_player()
end

function start_game()
	game_state = 1
	t=0
	set_music(0, 300)

	--TODO UNCOMMENT IN THE END
	--find_and_spawn_player(2*8,14*8)
	init_player(2*8,14*8)

	shake+=0.075
	for i=0,4 do init_particle(rnd(8), 120,0.25,0.2 +rnd(1),3,13) end
	
	shazam_timer = -1
	init_camera(0, 0)
	laser_c = 0
	laser_t = 60 + flr(rnd(90))

	missile_c = 0
	machines_on = false
	game_won = false
	game_won_r = 0
end

-- for debug / testing
function find_and_spawn_player()
	for x=0, 128 do 
		for y=0, 128 do 
			if mget(x,y) == 1 then 
				init_player(x*8,y*8)
				mset(x,y,0)
				break
			end
		end
	end
end

function _update60()
	foreach(particles, update_particle)

	if game_state == 0 then 
		update_start_screen()
	elseif game_state == 1 then
		t+=1
		if (not game_won and not move_camera)update_player()
		update_camera()
		foreach(pickups, update_pickup)
		
		foreach(texts, update_text)
		foreach(lightblocks, update_lightblock)
		foreach(lightbulbs, update_lightbulb)
		foreach(missiles, update_missile)
		laser_animation()

		if shazam_timer > 0 then 
			shazam_timer -= 1 
			if shazam_timer == 0 then
				sfx(15)
				shazam_timer = -1
				set_wall_button(false)
			end
		end
		if machines_on and not game_won and p1x > 1016 then 
			game_won = true
			sfx(23)
		end

		if game_won then 
			game_won_r=lerp(game_won_r, 200, 0.06)
			if game_won_r > 194 then 
				game_state = 2
				init_game_won()
			end
		end
	elseif game_state == 2 then 
		update_game_won()
	end
end

function _draw()
	cls(1)
	if game_state == 0 then 
		draw_start_screen()
	elseif game_state == 1 then 
		camera_w_shake()
		draw_camera()
		map(0,0,0,0,128,128)
		foreach(lightbulbs, draw_lightbulb)
		draw_player()
		foreach(pickups,draw_pickup)
		foreach(particles,draw_particle)
		foreach(missiles, draw_missile)
		foreach(fogroundtiles, draw_sprite)
		foreach(texts, draw_text)
		if game_won then
			fillp(Å)
			circfill(p1x,p1y, game_won_r, 0)
			fillp()
			circfill(p1x,p1y, game_won_r-16, 0)
		end
		if cam_x == 0 and cam_y == 0 and coffee_found == 0 then 
			print("jump with  z/up/", 10, 10, 6)
			spr(121, 74, 9)
		elseif cam_x == 128 and cam_y == 0 and coffee_found < 2 then 
			print("hold x/   to float", 128 + 18, 10, 7)
			spr(122, 128 + 47, 9)
		end
	elseif game_state == 2 then 
		draw_game_won()
	end
end

function laser_animation()
	if laser_c < laser_t then 
		laser_c+=1
	else 
		laser_c = 0
		laser_t = 50 + flr(rnd(80))
		for x=0,15 do 
			for y=0,15 do
				local gx = cam_x + x * 8
				local gy = cam_y + y * 8
				if is_flag(gx, gy, 5) then
					local dice = rnd(1)
					if dice < 0.25 then
						init_particle(gx+rnd(8), gy+rnd(7),0.2+rnd(1)/10,rnd(1)-0.1,3,8)	
					end
					if dice < 0.5 then 
						--animate "lava"
						local tile = get_tile(gx, gy)
						if tile == 102 or tile == 118 then 
							set_tile(gx,gy, tile == 102 and 118 or 102)
						end
					end
				end
			end
		end
	end
end

-->8
-- player

function init_player(x,y)
	p1ox=x
	p1oy=y
	p1x=x
	p1y=y
	check_point_x = x
	check_point_y = y
	
	p1ground=true
	p1falling=false
	p1stick=false
	p1jumping=false
	p1haskey=false
	p1goldenkey=false
	p1dead=false
	p1launching=false
	p1swimming=0
	p1swimtargspeed=0
	p1swimspeed=0
	p1swima = 0.25
	p1fallc=0

	p1deadc=0
	
	p1a=0
	p1speed=0
	
	p1aa=0
	p1aspeed=0

	p1jumpbonus=0
	
	p1maxspeed=1.2
	p1maxairspeed=1

	p1attack_range=0
	p1flip=true

	p1spr=1
	p1animc=0
	jumpl=false
	jumpc = 0
	
	p1launcha = 0
	p1launchspeed = 0
	p1jumpsc = 0
	p1force_effect=false
end

function update_player()
	p1ox=p1x
	p1oy=p1y

	if(p1jumpsc > 0)p1jumpsc-=1

	if p1dead then 
		if p1deadc < 40 then 
			p1deadc+=1
		else 
			p1deadc=0
			p1fallc=0
			-- no need to reset everything if it is the same room
			if is_checkpoint_in_another_room() then 
				reset_camera_to_checkpoint()
			else 
				p1x = check_point_x
				p1y = check_point_y
			end
			p1ground=true
			p1falling=false
			p1stick=false
			p1jumping=false
			p1launching=false
			p1launchspeed=0
			p1dead=false
			p1swimming=0
			p1swimtargspeed=0
			p1swimspeed=0
			for i=0,3 do init_particle(p1x+rnd(8),p1y+rnd(8),0.25,rnd(1),3,11) end
			shake+=0.075
			sfx(18)
		end
		return
	end

	player_animate()
	
	if p1ground then
		movement_on_ground()
	else
		p1speed-=0.065 --fall
		movement_in_air()
	end

	if p1launching then 
		p1x+=cos(p1launcha)*p1launchspeed
		p1y+=sin(p1launcha)*p1launchspeed
		
		if p1launchspeed > 0 then 
			p1launchspeed-=0.25
		else 
			p1launching = false
		end
	end

	if p1swimming > 0 then 
		p1x+=cos(p1swima)*p1swimspeed
		p1y+=sin(p1swima)*p1swimspeed

		if p1swimming == 1 then 
			p1swimspeed = lerp(p1swimspeed, p1swimtargspeed, 0.1)
			if (t % 4 == 0)init_particle(p1x+rnd(8),p1y+rnd(8),0,0,4,4)
		elseif p1swimming == 2 then 
			if p1swimspeed > 0 then 
				p1swimspeed -= 0.04
			else 
				p1swimming = 0
			end
		end
	end

	if p1ground then
		player_collision_on_floor()
	else
		player_collision_in_air()
	end

	if (p1ground or p1stick) and p1swimming == 0 and (btn(î) or btn(4)) then
		player_jump()
	end

	if not p1ground and p1jumping and not p1falling then
		player_air_jump_control()
	end

	if p1falling and p1fallc > 0 then 
		p1fallc-=1
	end

	player_attack()
	player_door_button_collision()
	player_wall_button_collision()
	player_checkpoint_collision()
	player_laser_collision()
	player_line_collision()
	key_collision()
	key_door_collision()
	player_coffee_water_collision()
	player_last_door_collision()

	p1aspeed = max(p1aspeed, 0)
	p1aspeed = min(p1aspeed, p1maxairspeed)

	p1speed = max(p1speed, p1ground and 0 or -5)
	p1speed = min(p1speed, p1maxspeed)

	p1attack_range = max(p1attack_range,  0)
	p1attack_range = min(p1attack_range, 12)
	
	p1x+=cos(p1a)*p1speed
	p1y+=sin(p1a)*p1speed

	if not p1ground and not p1falling then
		p1x+=cos(p1aa)*p1aspeed
		p1y+=sin(p1aa)*p1aspeed
	end

	-- if in some rare instances when the player goes outside of the world, reset to checkpoint
	if p1y > 620 or p1y < -4 or p1x < -4 or (p1x > 1024 and not machines_on) then 
		reset_to_checkpoint()
	end
end

function destroy_player()
	for i=0,8 do 
		init_particle(p1x+rnd(8), p1y+rnd(8),i/8,0.4+rnd(1),3,8+flr(rnd(2)))
	end
	p1dead = true
	init_text("ops",9,2,24)
	sfx(11)
end

function player_door_button_collision()
	if is_tile(p1x+4, p1y+4, 18) then 
		set_tile(p1x+4, p1y+4, 19)
		init_text("click",12,2,24)
		find_doors(false)
		sfx(6)
	end
end

function find_doors(isKeyDoor)
	-- find doors
	for x=0,15 do 
		for y=0,15 do
			local gx = cam_x + x * 8
			local gy = cam_y + y * 8
			if is_flag(gx, gy, isKeyDoor and 2 or 1) then 
				set_tile(gx, gy, 0)
				init_particle(gx+rnd(8), gy+8,0.25,1.25 -rnd(1),3,isKeyDoor and 10 or 5)			
			end
		end
	end
end

function player_coffee_water_collision()
	local movedir = p1aa == 0 and 8 or -1 
	local tile = get_tile(p1x+movedir,p1y+4)
	if tile > 97 and tile < 102 then
		if p1swimming ~= 1 then 
			sfx(22)
			for i=0,4 do init_particle(p1x+rnd(8),p1y+3,0.2+rnd(1)/10,0.2+rnd(1),4,4) end
		end 
		p1swimming = 1
		if p1attack_range > 4 then 
			p1swimtargspeed = 2
			p1speed*=0.98
		else 
			p1speed*=0.89
			p1swimtargspeed = 0
		end
	else 
		if (p1swimming == 1)p1swimming = 2
	end
end

function player_wall_button_collision()
	if is_tile(p1x+4, p1y+4, 51) then 
		set_tile(p1x+4, p1y+4, 52)
		shazam_timer = 600 
		init_text("chazam",11,1,24)
		sfx(12)
		set_wall_button(true)
	end
end

function set_wall_button(isOn)
	-- find walls
	for x=0,15 do 
		for y=0,15 do
			local gx = cam_x + x * 8
			local gy = cam_y + y * 8
			if is_tile(gx, gy, isOn and 50 or 55) then 
				set_tile(gx, gy, isOn and 55 or 50)
				init_particle(gx+4, gy+4,0.25,1.25 -rnd(1),3,isOn and 11 or 3)
			end
			if not isOn then 
				if is_tile(gx, gy, 52) then 
					set_tile(gx, gy, 51)
					init_particle(gx+4, gy+4,0.25,0.25,3, 3)
				end
			end
		end
	end
end

function key_collision()
	if is_tile(p1x+4, p1y+4, 54) then 
		set_tile(p1x+4, p1y+4, 0)
		init_text("key",10,9,40)
		p1haskey=true
		check_point_x = p1x+4
		check_point_y = p1y-1
		sfx(13)
		set_camera_checkpoint()
	elseif is_tile(p1x+4, p1y+4, 74) then 
		set_tile(p1x+4, p1y+4, 0)
		init_text("wow",10,9,40)
		p1goldenkey=true
		check_point_x = p1x+4
		check_point_y = p1y-1
		sfx(17)
		set_camera_checkpoint()
	end
end

function key_door_collision()
	local movedir = p1aa == 0 and 8 or -1 
	if p1haskey and is_tile(p1x+movedir, p1y+4, 48) then
		p1haskey = false
		find_doors(true)
		sfx(14)
	elseif p1goldenkey and is_tile(p1x+movedir, p1y+4, 75) then
		p1goldenkey = false
		find_doors(true)
		sfx(14)
	end
end

function player_checkpoint_collision()
	if is_tile(p1x+4, p1y+4, 30) then 
		set_tile(p1x+4, p1y+4, 46)
		init_text("phew",3,2,24)
		init_particle(p1x+4, p1y,0.25,1.25-rnd(1),3,11)
		check_point_x = p1x
		check_point_y = p1y
		sfx(7)
		set_camera_checkpoint()
	end
end

function player_laser_collision()
	if not p1dead and is_flag(p1x+4, p1y+4, 5) then 
		destroy_player()
	end
end

function player_last_door_collision()
	if not machines_on and is_tile(p1x+4, p1y+4, 103) then
		machines_on = true
		mset(127,12,0)
		mset(127,13,0)
		mset(127,14,0)
		mset(127,14,0)
		mset(122,5,115)
		mset(123,5,116)
		set_machine_on(112,3)
		set_machine_on(116,3)
		set_machine_on(116,7)
		for i=0,8 do 
			init_particle(127*8+rnd(8), 12*8 + rnd(24),0.25,0.4+rnd(1),3,0)
		end
		shake+=0.09
		init_text("there!",9,2,40)
		sfx(24)
	end
end

function set_machine_on(tx,ty)
	mset(tx,ty,108)
	mset(tx+1,ty,109)
	mset(tx,ty+1,124)
	mset(tx+1,ty+1,125)
	init_particle((tx+1)*8+rnd(4),(ty+1)*8,0.25,rnd(1),3+rnd(2),4)
end

function movement_on_ground()
	if btn(ã) then
		p1a=0.5
		p1speed+=0.07
	elseif btn(ë) then
		p1a=0
		p1speed+=0.07
	else
		p1speed-=0.3
	end
end

function movement_in_air()
	if not p1falling then
		if btn(ë) then
			p1aa=0
		end
		if btn(ã) then
			p1aa=0.5
		end
		if btn(ã) or btn(ë) then 
			p1aspeed+=0.09
		else
			if(p1stick)p1stick=false
			p1aspeed-=0.06
		end
	end
end

function player_air_jump_control()
	if btn(î) or btn(4) then 
		if p1jumpbonus < 1.8 then 
			p1jumpbonus += 0.2
			p1speed+=0.08
		else 
			p1jumping = false
		end
	else
		p1jumping = false
	end
end

function player_jump()
	if not p1stick and p1jumpsc == 0 then
		sfx(3+flr(rnd(2)))
		p1jumpsc=4 -- fix double sound ...
		init_particle(p1x+rnd(8), p1y+8,0.25,0.2 +rnd(1),2.5,7)
	end
	p1ground=false
	p1falling=false
	p1stick=false
	p1jumping=true
	p1aa=p1a
	p1aspeed=abs(p1speed)

	--fake anim
	if jumpc < 4 then 
		jumpc+=1
	else 
		jumpc = 0
		jumpl = not jumpl
	end
	p1spr = jumpl and 13 or 12 
	
	p1speed=0.8
	p1jumpbonus=0
	p1a=0.25
end

function player_attack()
	if btn(5) then
		p1attack_range+=1
		p1speed*=0.9
		if (t % 8 == 0)init_particle(p1x+5-p1attack_range+rnd((p1attack_range-2)*2), p1y+5-p1attack_range+rnd((p1attack_range-2)*2),0,0,2.5,9+flr(rnd(2)))
		if p1attack_range < 3 then
		shake=0.00025
		end
		if t % 15 == 0 then 
			sfx(p1force_effect and 8 or 9)
			p1force_effect = not p1force_effect
		end
		-- remove headache
		if p1falling and p1fallc <= 0 then 
			p1falling=false
		end
	else
		p1attack_range-=1.5
	end
end

function player_collision_on_floor()
	local movedir = p1a == 0 and 8 or -1 
	--side
	if is_wall(p1x+movedir,p1y+4) then
		if(p1speed > 0)p1speed = 0
		p1x=p1ox
		p1y=p1oy
	end

	--bot
	if not is_wall(p1x,p1y+8) and not is_wall(p1x+8,p1y+8) and not is_wall(p1x+4, p1y+8) then
		p1ground = false
		p1jumping = false
		p1aa = p1a
		p1a = 0.25 --flipped as jump is negative...
		p1aspeed = (p1speed / p1maxspeed) * p1maxairspeed
		p1speed = 0.3
		p1spr=5
	end
end

function player_collision_in_air()
	local movedir = p1aa == 0 and 8 or -1 
	--top
	if (is_wall(p1x,p1y) and is_wall(p1x+8,p1y)) or is_wall(p1x+4,p1y) then
		p1x=p1ox
		p1y=p1oy
		if (p1speed > 0)p1speed=0
		if not p1falling then 
			init_particle(p1x+4,p1y,0.65+rnd(2)/10, 0.2+rnd(1),3,6)
			sfx(10)
		end
		p1falling=true
		p1fallc = 4
		init_text("!?",9,2,12)
		
		reset_launch()
	end

	--side
	if not p1falling then
		if is_wall(p1x + movedir, p1y + 4) then
			stop_player(false)
			p1y = p1oy
			reset_launch()
			local newPosX = p1x - flr(p1x) % 8
			if not is_wall(newPosX, p1y+4) then
				p1x = newPosX
			end
			p1stick = true
		end
	end
	
	--bot
	if (is_wall(p1x,p1y+8) and is_wall(p1x+8,p1y+8)) or is_wall(p1x+4,p1y+8) then
		player_land_on_floor()
	end
end

function player_line_collision()
	if p1attack_range > 4 and is_tile(p1x+4,p1y, 88) then 
		p1speed=0
		if(t % 7 == 0)init_particle(p1x+4,p1y+4,0.25,rnd(1),2.5,10)
	elseif p1attack_range > 4 and is_tile(p1x+4,p1y+4,89) then
		p1speed=0.75
		p1aspeed=0
		if(t % 7 == 0)init_particle(p1x+4,p1y+4,0.25,rnd(1),2.5,10)
	end
end

function player_land_on_floor()
		stop_player(true)
		init_particle(p1x+rnd(8), p1y+8,0.25,0.2 +rnd(1),2.5,13)
		p1y -= flr(p1y) % 8
		p1fallc=0
		p1ground=true
		p1falling=false
		p1stick=false
		p1jumping=false
		reset_launch()
end

function is_wall(x,y)
	return fget(mget(x/8,y/8),0)
end

function is_tile(x,y,tile)
	return mget(x/8,y/8) == tile
end

function is_flag(x,y,flag)
	return fget(mget(x/8,y/8),flag)
end

function set_tile(x,y,id)
	mset(x/8,y/8,id)
end

function get_tile(x,y)
	return mget(x/8,y/8)
end

function stop_player(revert)
	if p1swimming == 0 then 
		p1aspeed = 0
		p1speed = 0
	end
	p1jumpbonus = 0
	if revert then
		p1x=p1ox
		p1y=p1oy
	end
	if(p1swimming > 0)p1swimspeed*=0.1
end

function reset_launch()
	p1launching=false 
	p1launchspeed=0
end

function player_animate()
	if btn(ë) then
		p1flip=true
		if p1ground then 
			animate_ground(4)
		elseif not p1stick and not p1falling then
			animate_air()
		end
	end
	if btn(ã) then
		p1flip=false
		if p1ground then 
			animate_ground(4)
		elseif not p1stick and not p1falling then
			animate_air()
		end
	end

	if p1falling then
		animate_fall()
	end
end

function animate_ground(threshold)
	if p1animc < threshold then 
		p1animc+=1
	else
		p1animc=0
		if p1spr < 4 then 
			p1spr+=1
		else 
			p1spr=1
		end
	end
end

function animate_air()
	if p1animc < 5 then 
		p1animc+=1
	else
		p1animc=0
		if p1spr < 8 then 
			p1spr+=1
		else 
			p1spr=5
		end
	end
end

function animate_fall()
	if p1animc < 5 then 
		p1animc+=1
	else
		p1animc=0
		if p1spr < 11 then 
			p1spr+= 1
		else 
			p1spr=9
		end
	end
end

debug = false
function draw_player()
	if p1dead then 
		return
	end
	circ(p1x+4,p1y+4, p1attack_range, 10)
	if p1attack_range > 4 then 
		circ(p1x+4,p1y+4, p1attack_range-sin(t/60)*1.1 - 4, 9)
	end
	spr(p1spr,p1x,p1y,1,1,p1flip)
	
	--print(fget(mget((p1x+4)/8,(p1y+4)/8)), p1x,p1y-12,2)
	--print(p1swimming, cam_x + 4, cam_y + 4, 8)
	--print(p1x, p1x, p1y-12, 8)
end

-->8
--entities

pickups={}
function init_pickup(x, y, type)
	local p={
		x=x,
		y=y,
		sy=y,
		spr = type == 0 and 32 or 70,
		c=0,
		flip=false,
		type=type,
		hide = false,
	}
	add(pickups,p)
end

function update_pickup(p)
	p.y = p.sy + sin(t/72)*1.1

	if not p.hide then
		if p.c < 10 then 
			p.c+=1
		else
			p.c=0
			if p.spr < (p.type == 0 and 34 or 72) then 
				p.spr += 1
			else 
				p.spr = p.type == 0 and 32 or 70
				p.flip = not p.flip
			end
		end
	else 
		if p.c < 90 then 
			p.c+=1
		else
			p.c = 0
			p.hide = false 
			init_particle(p.x+4,p.y+4,0.25,0.7,3, 10)
		end
	end

	if not p.hide and collision(p.x+4,p.y+4,4, p1x+4, p1y+4, 5) then 
		for i=0,3 do init_particle(p.x+rnd(8),p.y+rnd(8),0.25,0.7,3, 4) end
		if p.type == 0 then
			del(pickups,p)
			set_tile(p.x,p.sy,0)
			init_text("yum",9,4,24)
			coffee_found+=1
			sfx(5)
		else 
			init_text("jump",9,5,24)
			p1stick = true
			--p1jumping = false
			p.hide = true
			sfx(16)
		end
	end
end

function draw_pickup(p)
	if (not p.hide)spr(p.spr, p.x, p.y,1,1,p.flip)
end

lightblocks={}
function init_lightblock(x, y)
	local b={
		x=x,
		y=y,
		spr=60,
		active=0,
		c=0,
	}
	add(lightblocks,b)
end

function update_lightblock(p)
	if p.active == 2 then
		if p.c < 40 then 
			p.c+=1
		else
			p.c=0
			p.active = 0
			set_tile(p.x,p.y,60)
		end
	end

	if p.active <= 1 and p1attack_range > 2 and collision(p.x+4, p.y+4, 4, p1x+4, p1y+4, p1attack_range) then 
		p.active = 1
		set_tile(p.x,p.y,61)
	else
		if p.active == 1 then 
			p.active = 2
		end 
	end
end

missiles={} -- beans...
function init_missile(x,y,dir)
	local m={
		sx=x,
		sy=y,
		x=x, 
		y=y,
		dir=dir,
		speed=0,
		spr = dir and 94 or 93,
		destroyed=false,
		c=0,
	}
	add(missiles, m)
end

function update_missile(m)
	if not m.destroyed then
		if (m.speed < 1.75)m.speed+=0.05
		if m.dir then 
			m.y -= m.speed
		else 
			m.x -= m.speed
		end
		if (t % 8 == 0)init_particle(m.x+4,m.y+4,0,0,2.5,5)
	else 
		if m.c < 50 then 
			m.c+=1
		else 
			m.destroyed = false 
			m.x = m.sx 
			m.y = m.sy 
			m.speed = 0
			m.c = 0
		end
	end 

	if not m.destroyed and is_wall(m.x+4,m.y+4) then 
		destroy_missile(m)
		sfx(21)
	end

	if not p1launching and not p1dead and not m.destroyed and collision(m.x+4, m.y + 4, 3, p1x+4,p1y+4, 4) then 
		p1dead = true
		for i=0,8 do 
			init_particle(p1x+rnd(8), p1y+rnd(8),i/8,0.4+rnd(1),3,2)
		end
		sfx(20)
		init_text("oww",9,2,24)
		destroy_missile(m)
	end
end

function destroy_missile(m)
	init_particle(m.x+4, m.y+4,0,0,5,5)
	m.destroyed = true
	shake += 0.04
end

function draw_missile(m)
	if(not m.destroyed)spr(m.spr, m.x, m.y)
end

fogroundtiles={}
function init_forground_tile(x,y,spr)
	local f={
		x=x,
		y=y, 
		spr=spr
	}
	add(fogroundtiles, f)
end

function draw_sprite(s)
	spr(s.spr, s.x, s.y)
end

lightbulbs={}
function init_lightbulb(x,y,spr)
	local ox,oy = light_bulb_xy_offset(spr)
	local b={
		x=x,
		y=y,
		spr=spr,
		orientation=orientation,
		r=7,
		is_light=false,
		ofx=ox,
		ofy=oy,
		light_c=0,
	}

	add(lightbulbs, b)
end

function update_lightbulb(b)
	if not p1launching and p1attack_range > 2 and collision(b.x + b.ofx, b.y + b.ofy, b.r, p1x+4,p1y+4, 5) then 
		p1launching = true
		p1launcha = angle(p1x+4,p1y+4,b.x + b.ofx, b.y + b.ofy)
		init_particle(p1x+4,p1y+4, p1launcha, 1, 2+rnd(3), 9)
		p1launchspeed = 6
		b.is_light = true
		b.light_c = 40
		shake += 0.075
		sfx(19)
	end
	if b.is_light then 
		if b.light_c > 20 then 
			b.light_c-=0.5
		elseif b.light_c > 0 then
			b.light_c-=1
		else
			b.is_light = false
		end
	end
end

function draw_lightbulb(b)
	if b.is_light then
		fillp(ñ)
		circfill(b.x + b.ofx, b.y + b.ofy, b.light_c / 5, 9) 
		fillp()
		circfill(b.x + b.ofx, b.y + b.ofy, b.light_c / 8, 9)
	end
	circ(b.x + b.ofx, b.y + b.ofy, b.r,  b.light_c / 6 > b.r / 1.5 and 9 or 6)
end

function light_bulb_xy_offset(spr)
	local ofx = 0
	local ofy = 0
	if spr == 84 then 
		ofy = -6
		ofx = 4
	elseif spr == 85 then 
		ofx = 13
		ofy = 4
	elseif spr == 86 then 
		ofx = 4
		ofy = 13
	elseif spr == 87 then 
		ofx = -6
		ofy = 4
	end

	return ofx,ofy
end

-->8
--camera

function init_camera(x, y)
	cam_x = x
	cam_y = y
	cam_new_x = x
	cam_new_y = y
	cam_checkpoint_x = x 
	cam_checkpoint_y = y
	
	load_room()
	move_camera = false

	for x=0, 5 do 
		for y=0, 5 do 
			init_dot(4+x*24,4+y*24)
		end
	end
end

function update_camera()
	foreach(dots, update_dot)

	if not move_camera then
		if p1x + 4 > cam_x + 128 then 
			reset_room()
			cam_new_x = cam_x + 128
			move_camera = true
		elseif p1y + 4 > cam_y + 128 then 
			reset_room()
			cam_new_y = cam_y + 128
			move_camera = true
		elseif p1x + 4 < cam_x then 
			reset_room()
			cam_new_x = cam_x - 128
			move_camera = true
		elseif p1y + 4 < cam_y then 
			reset_room()
			cam_new_y = cam_y - 128
			move_camera = true
		end
	else
		if animate_camera then 
			cam_x = lerp(cam_x, cam_new_x, 0.3)
			cam_y = lerp(cam_y, cam_new_y, 0.3)
			if abs(cam_x - cam_new_x) < 1 and abs(cam_y - cam_new_y) < 1 then 
				cam_x = cam_new_x
				cam_y = cam_new_y
				load_room()
				move_camera = false
			end
		else
			cam_x = cam_new_x
			cam_y = cam_new_y
			load_room()
			move_camera = false
		end
	end
end

function set_camera_checkpoint()
	cam_checkpoint_x = cam_x
	cam_checkpoint_y = cam_y
end

function is_checkpoint_in_another_room()
 	return cam_x ~= cam_checkpoint_x or cam_y ~= cam_checkpoint_y
end

function reset_camera_to_checkpoint()
	reset_room()
	p1x = check_point_x
	p1y = check_point_y
	cam_x = cam_checkpoint_x
	cam_y = cam_checkpoint_y
	cam_new_x = cam_x
	cam_new_y = cam_y
	load_room()
	move_camera = false
end

function draw_camera() 
	foreach(dots, draw_dot)
end

dots={}
function init_dot(x,y)
	d={
		x=x,
		sy=y,
		y=y,
		s=4,
		ss=12,
		t=-#dots/32
	}
	add(dots,d)
end

function update_dot(d)
	d.t += 0.0025
	d.s = d.ss + sin(d.t)*0.95
end

function draw_dot(d)
	--fillp(ï) --default
	fillp(0B1111111110110111.1) -- tiny beans
	--fillp(0B1111111110010011.1) --bigger beans
	circfill(cam_x + d.x, cam_y + d.y, d.s, 0)
	fillp()
end

function reset_room()
	shazam_timer = -1
	
	--reset some tiles
	for x=0,15 do 
		for y=0,15 do
			local gx = cam_x + x * 8
			local gy = cam_y + y * 8
			
			if is_tile(gx, gy, 55) then 
				set_tile(gx, gy, 50)
			elseif is_tile(gx, gy, 52) then 
				set_tile(gx, gy, 51)
			elseif is_tile(gx, gy, 61) then 
				set_tile(gx, gy, 60)
			end
		end
	end
end

function load_room()
	for k,v in pairs(pickups) do pickups[k]=nil end
	for k,v in pairs(fogroundtiles) do fogroundtiles[k]=nil end
	for k,v in pairs(texts) do texts[k]=nil end
	for k,v in pairs(lightblocks) do lightblocks[k]=nil end
	for k,v in pairs(lightbulbs) do lightbulbs[k]=nil end
	for k,v in pairs(missiles) do missiles[k]=nil end

	for x=0,15 do 
		for y=0,15 do
			local gx = cam_x + x * 8
			local gy = cam_y + y * 8
			local tile = get_tile(gx,gy) 
			
			if is_flag(gx, gy, 3) then --coffee 
				set_tile(gx, gy, 35) -- hide 
				init_pickup(gx, gy, 0)
			elseif is_flag(gx, gy, 4) then 
				init_forground_tile(gx, gy, mget(gx/8,gy/8))
			elseif is_tile(gx,gy,60) then 
				init_lightblock(gx,gy)
			elseif is_flag(gx, gy, 6) then -- jump
				set_tile(gx, gy, 73) -- hide 
				init_pickup(gx, gy, 1)
			elseif tile >= 84 and tile <= 87 then
				init_lightbulb(gx, gy, tile)
			elseif tile == 91 or tile == 92 then 
				init_missile(gx, gy, tile == 91)
			end
		end
	end
end

-->8
--particle

particles={}
function init_particle(x,y,a,sp,r,c)
	local p={
			x=x,
			y=y,
			a=a,
			sp=sp,
			r=r,
			c=c
		}
		add(particles,p)
end

function update_particle(p)
	p.r-=0.15
	p.sp-=0.05
	
	p.sp=max(p.sp,0)
	
	p.x+=cos(p.a)*p.sp
	p.y+=sin(p.a)*p.sp
	
	if(p.r < 0)del(particles,p)
end

function draw_particle(p)
	circfill(p.x,p.y,p.r,p.c) 
end

texts={}
function init_text(text,c1,c2,c)
	local t={
		text=text,
		rc=c1,
		c2=c2,
		sc=c,
		c=c,
	}
	add(texts, t)
end

function update_text(t)
	if t.c > 0 then 
		t.c -= 1
		if t.rc ~= t.c2 and t.rc ~= 0 and t.c < t.sc / 2 then 
			t.rc = t.c2
		elseif t.c < t.sc / 3 then 
			t.rc = 0
		end
	else
		del(texts, t)
	end
end

function draw_text(t)
	print(t.text, p1x - flr(#t.text/1.25), p1y-7, t.rc)
end

-->8
--help

function lerp(var,target,pow)
	return var+pow*(target-var)
end

shake=0
function camera_w_shake()
	local shakex=16-rnd(32)
 	local shakey=16-rnd(32)

	shakex*=shake
	shakey*=shake
	camera(cam_x+shakex,cam_y+shakey)
	shake=shake*0.95
	if(shake < 0.05)shake=0
	if(shake >= 0.3)shake=0.25
end

function collision(x1,y1,rad1,x2,y2,rad2)
	return distance(x1,y1,x2,y2) < (rad1+rad2)
end

function distance(x1,y1,x2,y2)
	return sqrt(((x2-x1)/10)^2+((y2-y1)/10)^2)*10
end

function angle(x1,y1,x2,y2)
 	return atan2(x1-x2,y1-y2)
end

function is_on(state) 
	return state and "on" or "off"
end

function set_music(id, fade)
	if (music_on or id == -1)music(id, fade, music_channel)
end

-->8
--start

function init_start_screen()
	game_state=0
	t=0
	init_player(56,64)
	sun_x=128
	sun_y=12
	camera_x = 0
	t=0
	st_transition_s=0
	start_transition=false
	for i=0,20 do
		if i % 2 == 0 then 
			init_mountain(-16+i*24, 72)
			init_stone(-40+i*76 + rnd(12), 74)
		end
		init_tree(12+i*36 + rnd(6), 72)
	end
end

function update_start_screen()
	t+=1
	if p1x > -11 and not start_transition then
		if btn(ã) then 
			p1x-=1
			p1flip=false
			if(p1x > -9 and p1x < 790)sun_x-=0.9
			animate_ground(7)
			if (t % 13 == 0)init_particle(p1x+8-rnd(2),p1y+8,0.25,rnd(1)-0.2,1,1)
			if (t % 16 == 0)sfx(1)
		elseif btn(ë) then 
			p1x+=1
			p1flip=true
			if(p1x > -9 and p1x < 790)sun_x+=0.9
			animate_ground(7)
			if (t % 13 == 0)init_particle(p1x+rnd(2),p1y+8,0.25,rnd(1)-0.2,1,1)
			if (t % 16 == 0)sfx(1)
		end

		if (t % 9 == 0 and p1x < 70)init_particle(-10+rnd(8),0,0.10+rnd(1)/23,0.75+rnd(1),6+rnd(2),6)
	end

	p1x = max(p1x, -10)

	if not start_transition and p1x > 840 then 
		sfx(2)
		start_transition = true
	end
	
	foreach(mountains, update_mountain)
	foreach(stones, update_stone)

	if p1x > -32 and p1x < 790 then 
		camera_x = p1x - 64
	end

	if start_transition then 
		st_transition_s+=3

		if st_transition_s > 184 then 
			for k,v in pairs(mountains) do mountains[k]=nil end
			for k,v in pairs(trees) do trees[k]=nil end
			for k,v in pairs(stones) do stones[k]=nil end
			start_game()
		end
	end
end

function draw_start_screen()
	cls(2)
	camera()
	--sunrise
	fillp(ï)
	rectfill(0,56-sin(t/80)*2.1,128,128,1)
	fillp()

	camera(camera_x,-48)
	fillp(á)
	circfill(sun_x, sun_y, 40 + sin(t/120)*2.1, 14)
	fillp()
	circ(sun_x, sun_y, 40 + sin(t/120)*2.1, 14)
	foreach(mountains, draw_mountain)

	-- entry
	circfill(812,72, 40, 13)
	circfill(840,72, 64, 13)
	circfill(840,72, 32, 1)

	foreach(trees, draw_tree)
	
	foreach(particles, draw_particle)
	if p1x < 70 then
		draw_house()
	end
	spr(107,790,64)
	
	draw_player()

	-- fake hole
	fillp(Å)
	circfill(850,72, 26, 1)
	fillp()
	circfill(854,72, 19, 1)

	foreach(stones, draw_stone)

	for i=0,18 do 
		spr(106, -16 + i * 40, 64)
	end
	spr(110,76,19,2,2)
	print("i demand coffee",13,27,0)
	print("i demand coffee",12,25+sin(t/50)*0.9,7)
	print("a game made by sebastian lind @elastiskalinjen",240,-46,14)

	print("if no one will fix the coffee factory then i will...",600,25+sin(t/50)*0.9+st_transition_s/2,7)

	if(p1x < 72)print("< >",72,64,1)
	
	fillp(Å)
	circfill(854,72, 19+st_transition_s, 1)
	fillp()
	circfill(854,72, st_transition_s, 1)

	camera()
	rectfill(0,120,128,128,1)
end

function draw_house()
	draw_skottsten(-10,16)
	rectfill(-62,14,6,29,4)
	rect(-62,14,6,29,6)
	rectfill(-60,30,4,72,8)
	fillp(Å)
	rectfill(-62,14,6,29,2)
	fillp()
	rectfill(-60,30,4,72,8)
	fillp(ô)
	rectfill(-60,30,4,72,2)
	fillp()
	rect(-60,30,4,72,7)

	draw_door(-33,72)
	draw_window(-12,44)
	draw_window(-56,44)
end

function draw_skottsten(x,y)
	rectfill(x,y-12,x+8,y,1)
end

function draw_window(x,y)
	rectfill(x,y,x+12,y+12,2)
	rect(x,y,x+12,y+12,7)
	rect(x+6,y,x,y+12,7)
	rect(x,y+6,x+12,y+12,7)
end

function draw_door(x,y)
	rectfill(x,y-16,x+10,y,1)
	rect(x,y-16,x+10,y,7)
	circfill(x+7,y-7,1,2)
end

trees={}
function init_tree(x,y)
	local t={
		x=x, 
		y=y,
		w=2+flr(rnd(3)),
		h=10+flr(rnd(9))
	}
	local tb={}
	for i=0,2 do 
		add(tb, init_treebush(x-4+i*4, y - t.h+2))
	end
	t.treebushes = tb
	add(trees, t)
end

function init_treebush(x,y)
		local t={
		x=x, 
		y=y,
		r=6+flr(rnd(6)),
		bo=30+flr(rnd(30)),
	}
	return t
end

function draw_tree(t)
	if t.x < p1x+128 then
		rectfill(t.x, t.y, t.x + t.w, t.y - t.h, 13)
		fillp(ô)
		fillp()
		foreach(t.treebushes, draw_treebush)
	end
end

function draw_treebush(b)
	circfill(b.x+b.r/2, b.y - b.r + 1 + sin(t/b.bo/1.5)*1.1, b.r+sin(t/b.bo/2)*0.9, 3)
end

mountains={}
function init_mountain(x,y)
	local m={
		x=x, 
		y=y,
		r=32+flr(rnd(24)),
	}
	add(mountains, m)
end

function update_mountain(m)
	if p1x > -9 and p1x < 790 then
		if btn(ã) then 
			m.x-=0.5
		elseif btn(ë) then 
			m.x+=0.5
		end
	end
end

function draw_mountain(m)
	circfill(m.x, m.y-m.r/2, m.r+(sin(t/90))*1.1, 5)
end

stones={}
function init_stone(x,y)
	local s={
		x=x,
		y=y+rnd(5),
		r=9+rnd(9)
	}
	add(stones, s)
end

function update_stone(s)
	if p1x > -9 and p1x < 790 then
		if btn(ã) then 
			s.x+=1
		elseif btn(ë) then 
			s.x-=1
		end
	end
end

function draw_stone(s)
	if (s.x < p1x+128)circfill(s.x,s.y-s.r/2,s.r+(sin(t/160))*1.1,1)
end

-->8
-- game won 

function init_game_won()
	t=0
	for i=0,6 do
		if i % 2 == 0 then 
			init_mountain(-16+i*24, 128)
		end
		init_tree(8+i*36, 128)
	end

	p1x=74
	p1y=120
	p1c=0
	p1spr=14
end

function update_game_won()
	t+=1
	foreach(mountains, update_mountain)
	foreach(fumes, update_fume)
	if p1c < 60 then 
		p1c+=1
	else 
		p1c=0
		p1spr = p1spr == 14 and 15 or 14 
	end

	if (t % 110 == 0)init_fume(67+rnd(4), 121)
end

function draw_game_won()
	cls(1)
	camera()
	fillp(ï)
	rectfill(0,56-sin(t/120)*2.1,128,128,0)
	fillp()

	fillp(á)
	circfill(120, 32, 40 + sin(t/120)*2.1, 2)
	fillp()
	circ(120, 32, 40 + sin(t/120)*2.1, 2)
	foreach(mountains, draw_mountain)

	foreach(trees, draw_tree)
	foreach(fumes, draw_fume)
	spr(32, 65, 122)
	spr(p1spr, p1x, p1y)

	print("time for a cup of coffee...",4,5,0)
	print("time for a cup of coffee...",5,3,7)
	print("thank you for playing!",4,16,14)

	spr(32, 13, 28)
	print("" .. coffee_found, 4,28,6)
end

fumes={}
function init_fume(x,y)
	sfx(25)
	local f={
		sx=x,
		x=x,
		y=y,
		r=1.9,
	}
	add(fumes,f)
end

function update_fume(f)
	f.x = f.sx + sin(t/160)*1.1
	f.y-=0.1
	if f.r > 0 then 
		f.r-=0.05
	else 
		del(fumes, f)
	end
end

function draw_fume(f)
	circfill(f.x, f.y, f.r, 7)
end
__gfx__
eeeeeeeee9e9ee9ee9e99e9ee9e99e9ee9e99e9ee9999eeeeeeeeeeeeee9179ee9e99e9ee9e99e9eee9999eee9e99e9ee9e99e9eee9e99e9eeeeeeeeeeeeeeee
eeeeeeee99999999999999999999999979997799999999eeee9999eeee9291999999999999999999999999999999999999999999e999999eee9e9ee9eeeeeeee
ee7ee7ee79997799999999997999779919991199e979999ee999999ee992999e799977997999779979997799799977997999779ee7999779e9999999ee9e9ee9
eee77eee199911997999779919991199922299999971999e99992229e99299991999119979997799799977991999119919991199e1999119e7999779e9999999
eee77eee922299991999119992229999922299999919299e99991119e9999799922299991222119912221199922299999222999ee9222999e1999119e7999779
ee7ee7eeee99999e9222999eee9999eee999999ee999299e99779997e999179ee999999e92229999e999999ee999999eee2999eeee99999ee9222999e1999119
eeeeeeeee99999eeee9999eeee99999eee9999ee999929ee99999999ee999199ee9999eee999999eee9999eeeee99eeeeee9999eeeee999eeee99999e9222999
eeeeeeeeeeeee9eeee9ee9eeee9eeeeeee9ee9eee9719eeee9e99e9eeee9999eeeeeeeeeee9ee9eeee9ee9eeee9ee9eeeeee9eeeeee9e9eeee99999eee99999e
e666666eddddddddeeeeeeeeeeeeeeeee055550eeeeeeeeeeeeeedeededde5ddddddddddeeeeeeeeeeeeeeeeee22ee2ee5ee5e5eeddddddeee6666eeeeee6eee
d666666dd61dd16deeeeeeeeeeeeeeeee057c505eeeeeeeeeeeee6eeede5ee5ed61dd16deeeeeeeeeeeeeeeeee2eee2e00050505dd6666dde600006eeeeedeee
66611666d1dddd1deeeeeeeeeeeeeeeee05cc50eeeeeeeeeeee6deeeeeeeedeed1dddd1deeeeeeee22eeeeeeeee2ee2e55505050d6d11d6de600006eeeee6eee
66d11d66ddddddddeeeeeeeeeeeeeeee5505505eeeeeeeee6d6eeeeeeeeeeeeed6d66d6deeeeeeeeeeeeeeeeeee2eeee57c50050d61dd16de600006eeeeedeee
ddd66dddddd11dddee77cceeeeeeeeeee0500505eeeeeeeeeeeeeeeeeeeeeeeedd6dd6ddeeeeeeeeeeeeeeeeee2eeeee5cc50050d61dd16de6000066eeeee6ee
d1dddd1dd1dddd1de7ccccceeeddddee5500005eeeeeeeeeeeeeeeeeeeeeeeee6dd11dd6eeeeeeee2eeeeeeeeeeeeeee55505050d6d11d6de666666deeeeeed6
d611116dd61dd16decccccceeddddddee0555505e2eee2eeeeeeeeeeeeeeeeeeddddddddeeeeee2ee2eeeeeeeeeeeeee00050505dd6666dde686226eeeeeeeee
dddddddddddddddde000000ee000000ee500005ee2ee22eeeeeeeeeeeeeeeeee66666666eee2e2eeeeeeeeeeeeeeeeeeeee5e5eeeddddddee666666eeeeeeeee
ee66666eee66666eee66666eeeeeeeee5555555555eeeeeeeeeeeee5eeeeeeee5555555555555555eeeeeeeee888888e5eeeeeee55555555ee6666eeeeeeeeee
e666766ee666766eee66766eeeeeeeee555e5e55555eeeeeeeeeee55eeeeeeeee5e5555555555e5e88888888e888888e52888888e222222ee633336ee8888ee5
6e66666ee666666eee66766eeeeeeeee55eeeee555eeeeeeeeee55e5eeeeeeeeeee5555555555eee88888888e888888e52888888e888888ee63b336e88888815
6e66766ee666766eee66666eeeeeeeee5eee55555e55eeeeeeeee555eeeeeeeeeeee5e5555e5eeee88888888e888888e52888888e888888ee6b33b6e88888815
e666666ee666766eee66766eeeeeeeee55555ee55555eeeeeee55e55eeeeeeeeeeee5e5555e5eeee88888888e888888e52888888e888888ee633b36688888815
ee66666eee66666eee66666eeeeeeeee55eeee5555ee55eee5e5e555eeeeeeeeeeeee5e55e5eeeee88888888e888888e52888888e888888ee666666d88888815
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5e5e5ee55555555e55555555eeeeeeeeeeeeeeeeeeeeeeee88888888e888888e52888888e888888ee6b6336ee8888ee5
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555555555555555555555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888e5eeeeeeee888888ee666666eeeeeeeee
eddddddeeeeeeeeededededeeeeeeeeeeeeeeeeee555555eeeeeeeeeeddddddeed5555dedddddddd88888888eeeeeeee2e2e2e2e2222222eee2222eeeeeeeeee
ed9999de5ee8888eeeeeeeedeeeeeeeeeeeeeeeeee1111eee999999edeeeeeeded5525ded61dd16d88888888eeeeeeeeeeeeeee222a2a2a2e288882eeedeedee
e900009e51888888deeddeeeeeeeeeeeeeeeeeeeee8888eee922229edee66eeded52555dd1dedd1d88888888d6eeeeee2ee22eee2a22222228888882ededdede
e900009e51888888eedb3dedeeeeeeeeeeeeeeeee888888ee999999ede67b6eded5555deddeddedd88888888eed6eeeeee2a92e22227a2a228888882eed10dee
e190091e51888888ded33deeee77bbeeeeeeeeeee888888eeeee9eeede6bb6edd55525deddd11ded88888888eeedeeee2e2992ee292aa22228888882eed00dee
ed9009de51888888eeeddeede7bbbbbeee3333eee888888eeeee9eeedee66eeded5255ded1dded1d88888888eeee6eeeeee22ee22222229228888882ededdede
ed1991de5ee8888edeeeeeeeebbbbbbee333333ee888888eeee99eeedeeeeeeded5555ded61dd16d88888888eeeeed6e2eeeeeee29292922e288882eeedeedee
edd11ddeeeeeeeeeedededede000000ee000000eee8888eee9999eeeeddddddeed5555dedddddddd88888888eeeeeedee2e2e2e2e2222222ee2222eeeeeeeeee
eee22eeeeeeeeeeeeeeeeeeeeeeeeeeeeee22eeeeee22eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee22eeeeeeeeeeeeeeeeeeeeeeeeeeeeee22eeeeee22eeeeee444eeeeee14eeeeeee4eeeeeeeeeeea9a9a9eed9a9adeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeee
eee22eeeeeeeeeeeeeeeeeeeeeeeeeeeeee22eeeeee22eeeee44114eeee1444eeee4444eeeeeeeeee93b33aeea33339eeeeeee22eeeeeeeeeeeeeeeeeeeeeeee
eee22eeeeee2222222222eee22222222eee2222222222eeee441144eee14444eee4444eeeeeeeeeeea9a9a9ee9bbbbaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee22eeeeee2222222222eee22222222eee2222222222eeee411444ee44444eeee4444eeeeeeeeeeeeeeaeeee1abb91eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee22eeeeee22eeeeee22eeeeeeeeeeeeeeeeeeeeeeeeeeee44444eee4444eeee4444eeeeeeeeeeeeeee9eeeed9bbadeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee22eeeeee22eeeeee22eeeeeeeeeeeeeeeeeeeeeeeeeeeee444eeeee44eeeeee4eeeeeeeeeeeeeeee9aeeeed1a91deeeeeeee2eeeeeeeeeeeeeeeeeeeeeeee
eee22eeeeee22eeeeee22eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeea9a9eeeedd11ddeeeeeee2eeeeeeeeeeeeeeeeeeeeeeeee
eeeee000000eeeeeeee22eeeeeeeeeeeeeeeeeeeeeeee6eeee1111eeee6eeeeeeeeeeeeeee5d5eeeeeeeeeeeee0000eeee0000eeeeeeeeeeeee1eeeeeeeeeeee
eee0000000000eeeee666e66666666eeeeeeeeeee62626eee666666eee62626eeeee6eeeee595eeeeeeeeeeee001100ee001100eeeeeeeeeee4014eeeeeeeeee
ee000001100000eee60006000100006e6666666616d6d6eee2dd222eee6d6d6155555555ee5d5eeeeeeeeeee0001100000010000e444444eee4414eeeeeeeeee
e00000011000000ee61000000010006ee2dd222e16d6d6eee666666eee6d6d61d9d99d9de6595eee000000000110011001100000e1100044ee4404eeeeeeeeee
e00000111100000ee60100000000005ee666666e162626eee2dd222eee62626155555555ee5956ee00000000010000100110000010444444ee4404eeeeeeeeee
0000010000100000e66666666566666ee2dd222e162626ee66666666ee626261eee6eeeeee5d5eeeeeeeeeee0000000000010000e444444eee4404eeeeeeeeee
0000100000010000e68622666622586ee666666ee62626eeeeeeeeeeee62626eeeeeeeeeee595eeeeeeeeeeee000000ee001100eeeeeeeeeee4444eeeeeeeeee
0011100000011100e66666662666666eee1111eeeeeee6eeeeeeeeeeee6eeeeeeeeeeeeeee5d5eeeeeeeeeeeee0000eeee0000eeeeeeeeeeeee44eeeeeeeeeee
001110000001110044e44444eeeeeeee44444444444444448ee88eeeeee22eeeeeeeeeeee500005eeeeeeeee22222222eeeee222222eeeeeeeeeeeeeeeeeeeee
00001000000100004ee44e44e44e44e44411114444444444888888e8ee666666666666ee5050050eeeeeeeee22244122eee2200000022eeeeee6666666eeeeee
0000010000100000ee44ee4444444444411141144444444488888888e60000100000006ee5000055eeeeeeee22441422ee200001100002eeee622222226eeeee
e00000111100000e444ee44444444444411444144444444488888888e61001001000106e5050050eeeeeeeee22444422e20110011001102eed2444444426eeee
e00000011000000e44ee44e444444444414441144444444488888888e60100000101006ee5044055eeeeeeee22444222e20111111111102eed4444444446eeee
ee000001100000ee4ee44ee444e44e4441141114dddddddd88888888e66666666666666ee047840eeeeeeeee222222222000110000110002edd4444444666eee
eee0000000000eee4e44ee444e44e44444111144d611116d88888888e66633bb6622666e5048840eeee1ee1eeee22eee2000100000010002edd64444466666ee
eeeee000000eeeee444444444444444444444444dddddddd88888888e66666666666666ee004400ee1e1e1eeeee22eee2011140404011102edd666666766666e
eeeeeeeeeeeeeeeeeeeeeeeeeee22eeeeeeeeeeeeeeeeeeeeeee8ee8eddddddeee9e9eeeee6666eeee7777eeeeeeeeee2011144444411102edd666666666e66e
eeee000eeee0eeeee00eeeeeee666666666666eeeeeeeeee8e8e8888dd666eddee9999eee622226ee799997eeeeeeeee2000124444210002edd666666766ee6e
eee0000eee00eeeee000eeeee63333b33333336ee88ee88e88888888d6e11d6de979997e6226622679799797eeeeeeee2000112222110002edd666666766e66e
ee00e0eeee0eeeeee000eeeee6b33b33b333b36ee888888e88888888d61dd16de919991e6262262679977997eeeeeeeee20111111111102eedd666666666666e
e0e00eeeeeeee0eeee0eeeeee63b33333b3b336ee888888e88888888d61de16de999229e6262262679977997eeeeeeeee20110011001102eedd66666666666ee
e000eeeeeee0eeeeeeeee00ee66666666666666ee888888e88888888d1d11d6de99999ee6226622679799797eeeeeeeeee200001100002eee0d666666660eeee
e00eeeeeee000eeeeeee000ee66633bb6611666eee8888ee88888888dd66661dee9ee9eee622226ee799997eeeeeeeeeeee2200000022eeeee066666660eeeee
eeeeeeeeeeeeeeeeeeeeeeeee66666666666666eeeeeeeee88888888eddddddeeeeeeeeeee6666eeee7777eeeeeeeeeeeeeee222222eeeeeeee0000000eeeeee
11111111111111111111111111111111000000000000000000001100000000818181420000000000000000008100008181b100000000b10000830000b1004200
81818181818181818181d1d1d1d1d1d161717111000000000000f2d100000000d1d100000000000000000000000000d201010100000000000000000000950011
11424204004434c3040004000400000000c3c3000000000000001100000000b18242420000d100000000000042000042b1000000000000000003000000004200
00004292000000000000004242d1d1d10200001100000000000000d100f300c4d1d12400e100000000000000000000b2d1429200000000000000000000950011
11429204000002c304000400442400000004000000000000f3001142424200000000424242920000000000004200004200000000000000000083000000004200
0000420000000017000000004242d1d10100001113000000000000d100000002d1d1d1d1d1d1c2a2a2a2a201520000b2d1420000000000000000000000950011
110000c3c3c3c30044244424004434343454000000c3c30000001100004200000000420000000000910000004200004200000000910000510083000000004200
0000420000000000000000000042b1000000c41100000000000000d1c3c3c301d200b1006500000000000000824242d142920000858585858500000000950011
11342400000000000004000400000000000000000000443434341113004200000000420000006201010101010101010101010101010101010101010101010101
0100420000000000000000020042000000000011000000000000007500000011b20000051500000000000000051500d142330085000000000000000000950011
11004434240000000004004424000000000000000000000000001100514201010101010101010111111111818181818181818181818181818181818111111111
1101010100000000000000000042000000000011d1000000000000d100f30011b20000061600000000000000061600d101010100000000000000000000000011
110000000400000000040000c3c3000000c300f300000014343411010101818181811111111111118181816100000000040000b100000000000000f181811111
1111111101910000000000006242000000000011d200c3c3000000b200000011b20000000000000000000000000014d1d1d1a2a2a2a2a2a2d1000000000000d2
11000000c3c3000000e3000000000000000400000000000400008111118161000071811111111181610000000014343454000000000515000005150000f18111
1111111111010000000000004200000000000011b2000000000000b200000011b2000000000000d1c2a2a2a2a2a2d1d2d22300000000000000000000000000b2
1134342400000000000000000000000000040000000000c30000008181000000000000818181810000d1d1342404000000f3020000061600000616000000f111
1111111111110100510000004200000000000011b2000000000000b20000f211b20000000000004200000000000000b2b22300000000000000000000000000b2
110000040000000000000000e300000000443424000000c300000000000000000000000071000000000515004454000014d1d13434d1d13434d1d13424000011
111100f111931101010000624252e10000000011b2000000000000d100f300d2b20000051500004200000000051500b2b22300000000000000000000000000b2
110000e300000014343434345400000000000004000000c30000f3000000000000000000f3f3000000061600000000000400000000000000000000000400c411
1193270011119311110101010101010100000011d100000000000000000000b2b20000061600004200000000061600b2b223000000000000000000000075d1b2
110000000000000400000000000000000000000400000000000000000000000000000000f3f30000000000000000000004051500000515000005150004000011
11110101111111931193111111111111000000110000000000000000000000b2b20000000000004200000000000000b2b2230000000000000000000000000011
11000000000000040000000000000000000000040000000000000000000000000000000000000000000000000000000004061600000616000006160044240011
11111111119311111111111111931111000000110000000000000000000000b2b20000000000004200000000000014d1b200000000d1a2a2a2a2a2d1d1d1d111
111300c3c3c3c301c2a2a2a2a2a2a2a2a2a2a20101c3c3c3c3c3c3c3c3c301010101010000000001010101010100000044d1d13434d1d13434d1d10000253511
1193617111116171111161001111931100000011010000000000005100000001b2000000000075d142424252000044d1d10000d14100000000000000000000d1
11000000000000040000000000000000d1d1d10134540000000000000004f18181111100f3f30011931181610000000000000051000000005100000000d1d111
11110000111101001111000011931111a1000011110124451401010101010111b20000000000000000000082424242d1000000f14100210000000000009500d2
1100000000000004000000000000000000f1d10100000000000000000044343434d11100f3f30011938161000000000001010101010101010101010101010111
1111010111111101111101011111111100000081818101010181818181818111b20000000000000000000000000014d100000000d1d1d177d1000000009500b2
110000000000000400000000143434343434d10100000000000000000100000000001100000000931161000000f3000111000000b1000000000000420000b100
00000000b10000b1000000d1d1000000000000000000008300b1000000000011b20000000000000000000000000044d10000000000d177d1d1000000009500b2
11342400f300000400f30000040000000000d1d20000000000f30000420000000000111300000011110000e10000001111000000000000000000004200000000
000000000000000000000000b100000000000000000000b40000000000000011b20000051500000000000000051500d10101010000d16100d1000000009500b2
11000400000000e300000000e30000005102d1b20000000000000000420000000002110000000011110101010101011111210000000000000000004200000000
0000000000000000000000000000000000000000000000830000000000000011b200000616000000000000000616000000f1d14242d1000000000000009500b2
11c3c3c3c3c3c3c3c3c3c3c3c3c30000d1d1d1b200f30000000100004200f3000001110000000081818181818181818181014242520000000062429200000000
0000000000000000000000000000000000000000000000830000510000000011d15200000000000000000000000000910002d14242d1210000000000009500b2
11c2a2a2a2a2a2a2a2a2a2a2a2d10000d1d1d1b200000000004200004200000000421100000000000083000000000000000000004200624242d1000000000000
0062d10000000000000000d10000000000000001010101d1d17777d100000011d24200000000000000000000000000d1d177610000d1d10000000000009500b2
11000000f3000000f3000000f3000000d1d1d1b200000000004200004200010000421100000000000003000000000000000000004200420000d1000000000000
0042000000000000000000420000000000000011118181610000000000000011b24200010100000000000000000000d1d20000000000000000000000009500b2
11000000000000005100000000000091d1d1d1b20001000000420000420042000042110000000000008300000000000000000000424292000042000000000000
0042424242424242425200010101a2a2a2a2a211810000000000000000000011b24242429200000000000000000075d1b200000515a5a5a505150000009500b2
11000000d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1b20042005162420000420042520042110091000000518300005100000000000000000000000042000000000000
0000000000000000004242d1d1d1000000000011610000f30000020000f30011b20000000000000000000000000000d2b200000616a5a5a506160000009500b2
11000000000000b100000000000000b10044d1010101010101010101010101010101110101010101010101010101010101000000000000000042000000010101
01c2a2a2a2a2a2a2a2a2a2d1610000000000001113000000000000000000c411b20000051500000000000000051500b2b20000000000000000000000000000b2
11000000000000000000000000000000000000b1d161000000000000d16100b10000004242424200000042010101010101000000d1c1c1c1c1d1000000d19393
d100000000000000000000000000000000000011000000000000000000000011b20000061600000000000000061600b2b20000000000000000000000000000b2
11000000f3000000f3000000f3000000f3000000f3000000f3000000f3000000f300000042424200e10042410000000000000000d1130200f2d1000000d1d1d1
d100000000000000000000000000000000630011000000d1a2a2a2a2a2a2a211b20000000000000000000000000000b2b200000515a5a5a5051500d1c1c1d1b2
11520000000000000000000000000000000000000000000000000000000000000000000000420042d14292410000000000000000000000000000000023004242
000000000000000000000000000000d1d1d10011a1000000000000000000008101000000000000000000000000000001b200000616a5a5a506160041000041b2
11425200000064000000000000000000000000000000000000000000000000000000000000824242c39200410000000000000000000000000000000023004242
520000170000000000000000000000824252001100000000000000000000000000000000000100000000000000000011b20000000000000000000041000041b2
11004200000000000000000000006400000000000000000000000000000000000000000000000000c30000410000000000000000000000000000000000004242
420000000000000000000000000000008242421101000000000000000000000000000000011100000000000000000011b20000000000000000000041516341b2
11e1420000000000000000000000000000000000000064000000000000006400000000002100a400c30000410051000000330000000051000000000000000042
42000000003300000027002300000000000082111101010000000051e100000000510001931114342445000000140193b20045000000000000c3c3c30101c3b2
1101010177c2a2a2d1c2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2010101010101010101010101010101c2a2a2010101c2a2a2a2a2a2d1
d1d1c2a2a2d1d1c2a2a2a2a2a2a2a2a2a2a2a21193111101010101010101010101010111111101010101010101011111d1a3d1a2a2a2a2a2a2a2a2a2a2a2a2d1
__gff__
0000000000000000000000000000000001010000030000000100000003010000080000081010101010102020202000200520000000200001050120000001200000000000000040404040000500000000000000000000000000000000000000000000100010002000000100000000000000000000002020010000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1118181818181818181818181811111111111818181818181818181818181811111111111118181818181818111111111818181818181818181818181818181818181818181818181811111111181818181818111111111111113911111818181818181818181811391111111139111118181818181818181818181818181811
11000000001b0000001b000000181111111100000000001b00000000000000111111111118241b001b001b2418111111160000003c001b000000001b000000441d2c2a2a2a2a2a2a2a11111118162400002400181139111139111111180024000000242400001f181111391111111818161b0041434343431d1d1d1d1d1d1d11
110000000000000000000000001f111111110000720000000000001500201911111111180024000000000024291811114a0000003c0000000000000000000000000000000000000000111118160024000024000018181818181818180000240000002424000000001818111139181600000000400000000038004000001f1d11
110020150000000000000000120011111111120000000000000000101010101111181800002424240024242400001811101000003c000000000000000000000000000000000000004c11181600002420002400000000000000000000000024000000242400000000002818181829000050510044505100003800400000001d11
1110101000000019000000101010111111181000000000000000001400001f1111160000000000240024000000001f11160000003c000000000000000000000000000000000000000011000000002810102824242424242424242424242429000000242400000000000024242400000060614343606100004b00400000001d11
111816000000001010000017001811111100000019000000000000140000001111000000000010240024100000000011000000003c000000000000000000000000000000007100000011000000000000000000000000000000000000000000000000242400000000000024242400000000400000000000003800676800001d11
111700000000002417000000000018111100000010100000000000140000001111000000000039391139110000000011000000003c00003c3c0000000000000000000000000000000011000000000000000000000000000000000000000015000000242400000000000024242400000000401d00000000001010101010101011
112500261010242400000000000000181824242424290000000010101c1c1c1111000000000018181818110000000011003c3c5b66666666666666666600000000000000000000004c11000000000000000000000000000000000000000010101010101010000000000024242400000000402400505100002400000000002411
112424101118000000000071000000141b00000000000000000028110000001111000000000000240024110000000011660000661d1d1d1d1d1d1d1d1d00000000000000000000000011000000000000000000000000000000000000000011111818181811000000000010101000001541452400606100002400000000002411
1100002418000000000000000000001400000000000000001900001100000011110000000000002470241100000000113a3a3a3a1d0000000000000000000000000000544143420000110000001d0000000000000000000000000000005c111100001b0011000000001011391110101010102400004000002424242424242411
110000241700000070000000000000140000000000000010100000111c1c1c11110000000000002420241100000000111d1d1d1d160000000000000071000000000000444500400000110000001d1d1d1d1d00000000000000000000000011110020000011242424101139111111111111111010414519002400000000002411
1810002400000000000000000000001010100000000000002400001100000011112c2a2a2a2a102400241100000000112424242900000000000000000000000000000000000044434311000000001f11000000000000000000000000000011110059000011242424181818181818181818181811101010102400000000002418
69000024000000000010100000002611111b00000000000024000011000000111100000000001010101018000000001124242900000000000000000000000000000000000000000000110000000000111a0000005858585858585858000011110059004c11000000003800001b00000000000018181818112424242424242469
690000242500000000001700002624111100000000710000242500111c1c1c11112424242424242400242424242424112429000063636363630000006363636363636363636300000011000000000011000000000000000000005b0000001111005900001100000000300000000000000000000000001f112400000000002469
69000024101000001900001526242411111000001010002624241011000000111100000000000000000000000000001129000000626462646200000062646264626264626462100015115b5b5b00001100000000005b000000000000000011110059000011001e15003800000000000000000000000000112400150000002469
101010101111101010101010101010111111101011111010101011110000001111101000000000000000000000000011000000006565656565005b00656565656565656565651d10101100000000001100001d1d2a2a2a2a2a2a2a2a2a2a11111a59000011101010101010100000000000000000000000111010101010101010
112d00000000000024000024000024000000000011290000002824110000001111111110000000000000000000000011000000000000000000000000000000000000000000001f1818180000000000110000000018111111111111111111111100590000000000000000001d0000000000000000000000181818181818181811
112b00000000000024001e2400002400000000001100000000002811000000002424242900001200000000000000001100000000000000000000000000000000000000000000000000000000000000111a0000000018391111181818181818180059000000003f0000003f770000005858585858580000242429000000001f11
112b0000003300101010101010101010100000001100331500000011001500000028240000001d0000000000000000115a5a50515a5a5a50515a5a5a50515a5a5a50515a5a5a50515a5a00000000001100000000001f1d1d1d001b000000000000590000000000000000001f1d00150000000000000024240000000000002f11
112b000000101024000000001711180000000000111010101000001110100000000028242424290000007200001500115a5a60615a5a5a60615a5a5a60615a5a5a60615a5a5a60615a5a0015001e00114200190020001d1d00000000000000000059000000000000000000001f1d1d0000000000001d24290058585858000011
11100000001124290000153600111b000000000032001b111124242411110000000000000000000000000000101010111000000000000000005c1d000000000000000000000000000000101010101d1d1d1d1d1d1d1d1d0000000000000000000000000000005858585858000000000000000000000000000000000000000011
111b00000011000000001d1d1d1d00000032000032000000110000001111000000000000000000000000000014001b11116363636363636363632d636363636363636363636363636363111818181600004000444343434343420000000000000015000019000000000000000000000000000000000000000000000000590011
1100000000110000000000000000000000320000000000000000000011390000001e0000000000000071000014000011116262626262626262622b626262626262626262626262626262111600000000414500000000005051400000101010101010101010000000000000005858585858585858000000000000000000590011
1131000026110000000000000000000000320000000000000000000011111010101010101000000000000000140000111162626262623e6262622b62626262626262646262626262626211003f3f0000400000000000006061400010181818181818181818100000000000000000000000000000000000000000000000590011
11000000101800002f1d2c2a2a2a2a1000000000000000000000000024292f1111111818290000000000001010000011116262626462626262622b62626262626262626262646262626211420000000040191e000000000041450011000000000000000000110000000000000000000000000000000000000000000000590011
110000003532000000000000000000110000001d0000000000001e00240000111118000000000000000000112d000011116262623e62626262622b626262626262626262626262626462114443434310101010101010150052531011000000000000000000110000000000000000000000000000000000000000100000590011
110000000032000000000000000000112c2a2a2a2a2a2a2a2a101000282424111100000071000000000010112b00001111623e626262626264622b62626262626262626262626262626211003f3f0018181818181811101010101111000000000000000000110000000000000000000000000000000000540000110000590011
110000000000000000000032000000110000000000000000001f1100000000111100000000000000000000112b000011116462626262626262622b626262626262626462626262626262114200000000004000004418181111111111000000000000000000116666766666660000000000000000000000444343110000590011
110000000000000000000032000000111a000000000000002000113100000011112c2a2a2a2a2a2a2a2a2a112b000011111010101064626262622b6264626262626262626262626462621110000000000040000000000018181818110000001d1d000000001818181811113a7666667666666666766666766666110000590011
11150000000000000000000000002011000000000000000000001100000000111100000000000000000000112b000011111600400062626262622b626262626262626262646262626262111110000000004442000000000000004411003f001b1d0000000000171b001818181818111d1d1d1d1d771d1d1d771d1d0000590011
111000000000003232320000000032111a00001d24242424101011000000001111202500000000000000001110000011112071525362626262622b6262626262626262626262626262621111110015001900400000000000000000111a0000001d00000000000000000000001b00181d24000000000000000000000000590011
1111102c2a2a2a2a2a2a2a2a2a2a2a1100000000000000000028110000000011111024000000000000000018110000111110101010101010101010101010101010101010101010101010111111101010101010100000000000000011000000001d00000000000000000000000000001d241e2558585858585858585800590011
__sfx__
020400000104400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
0b0200000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6010000003024070340c034110540a054000540f05409054160540f0541f03421004210641300415004150041a004260040000400004000040000400004000040000400004000040000400004000040000400004
08030000040470b557005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507
080300000104706557005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507
590a00000153506545170550000514555000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
500c00000107501635030351b0550700500705000050f005180050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
5c0e0000040550e05518055000551f055000050205515055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
c00800000104403044000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
c00800000204400044000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
54030000070530403300003000030d003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
99090000076100f04005050040000070014700057000f700337000070002700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
6c0e00000103503035065550b55511545000251f03522055005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
50080000060550e505165552755500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
500a00000f04524055136350a05507015000050400504005150050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
c10c00000105505055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
20060000130251d0352c0050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
980e000007025030350c055040551f035000050000500005220050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
d10a00000102400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
950600000405103051090111200117001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
90100000036330e043080030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
500200000604501115087050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
5905000000b401ab3012b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b00
a110000003025070350c035110550a055000550c05500055160550b0551f03521055000051705527005150051a005260050000500005000050000500005000050000500005000050000500005000050000500005
8010000002655000551405500605020551b0550060505055230550060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
4805000000d3500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d0500d05
ad2a0000030140d014180040801410014180040f01418004030140d014180040801410014180040c01418004030140d014180040801410014180040f01418004030140d014180040801410014180040c01418004
b12a0000000000000000000000000000000000000000f0140000000000000000000000000000000501400000000000000000000000000000000000000000f0140000000000000000000000000000000501400000
be2a00000001500005000150001500005000050671505715000150000500015000150000500005067150671500015000050001500015000050000505715067150001500005000150001500005000050671506715
672a00000000500005000050000500005000050000505715000050000500005000050000500005067150000500715000050000500005000050000505715000050001500005000050000500005000050670506705
ad2a0000030040d004180040800410004180040f0040a01403004030040f0140800410004180040c0040a01403004030040f0140800410004180040f0040a01403004030040f0140800410004180040c00418004
ad2a0000031140d01418004080141001418004061141d004021140d014180040801410014180040c01418004031140d014180040801410014180040711418004031140d014051040801410014180040c01418004
672a00000000500005000050000500005010150000503005000050000500005000050101500005000050000500705000150000500005000050101503005000050000500015000050000500005010150670506705
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
01 1c 42 43 44
00 1c 1d 43 44
02 1c 42 20 44
01 1a 42 43 44
00 1a 1b 43 44
00 1a 42 1e 44
02 41 1f 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
