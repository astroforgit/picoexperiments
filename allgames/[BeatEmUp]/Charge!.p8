pico-8 cartridge // http://www.pico-8.com
version 15
__lua__

-- animation specs are:
--  1) spritesheet location
--  2) frame duration (in frames)
--  3) sprite width (in tiles)
player_anims = {}
player_anims.run = {
	{6, 15, 2},
	{8, 15, 2}
}
player_anims.shield = {
	{10, 15, 2},
	{12, 15, 2}
}
player_anims.attack = {
	{128, 5, 2},
	{130, 10, 3}
}
player_anims.die = {
	{137, 10, 2},
	{139, -1, 2}
}
player_anims.trip = {
	{133, 10, 2},
	{135, -1, 2}
}


priest_anims = {}
priest_anims.run = {
	{64, 15, 1},
	{65, 15, 1}
}
priest_anims.die = {
	{96, 10, 2},
	{98, -1, 2}
}

archer_anims = {}
archer_anims.aim = {
	{160, -1, 2}
}
archer_anims.fire = {
	{162, -1, 2}
}
archer_anims.die = {
	{164, 10, 2},
	{166, -1, 2}
}

swordsman_anims = {}
swordsman_anims.run = {
	{192, 15, 2},
	{194, 15, 2}
}
swordsman_anims.die = {
	{196, 10, 2},
	{166, -1, 2}
}

arrow_anims = {}
arrow_anims.fly = {
	{16, -1, 1}
}
arrow_anims.collide = {
	{32, 5, 1},
	{48, -1, 1}
}

p = "priest"
a = "archer"
s = "swordsman"

patterns = {
	-- easy - 1
	{
		{{5, p}},
		{{5, a}},
		{
			{5, p},
			{7, p},
			{9, p}
		}
	},
	-- still easy - 2
	{
		{
			{5, p},
			{6, p},
			{7, p}
		},
		{
			{5, a},
			{10, a}
		},
		{
			{5, p},
			{10, a}
		}
	},
	-- medium - 3
	{
		{
			{5, p},
			{8, a},
			{10, a}
		},
		{
			{5, a},
			{7, a}
		},
		{
			{5, s},
			{6, a}
		},
		{
			{5, a},
			{7, a},
			{7, p}
		},
		{
			{5, a},
			{7, a},
			{7, p},
			{8, p}
		}
	},
	-- hard
	{
		{
			{5, a},
			{7, a},
			{9, s}
		},
		{
			{5, s},
			{6, s}
		},
		{
			{5, s},
			{6, s},
			{7, s}
		},
		{
			{5, s},
			{6, a},
			{8, s},
			{9, a}
		}
	}
}

wave_length = 60
wave_patterns = {
	{6, 1},
	{1, 6, 1},
	{0, 2, 6},
	{0, 1, 8},
	{0, 0, 9},
	{0, 0, 5, 5},
	{0, 0, 0, 9}
}
waves = {
	{
		{10, p},
		{20, s},
		{30, s},
		{31, s},
		{32, p},
		{33, p},
		{35, p},
		{40, p},
		{45, p},
		{50, p}
	},
	{
		{10, p},
		{20, a},
		{25, p},
		{30, a},
		{35, a},
		{40, a},
		{45, p},
		{50, p},
		{52, p},
		{53, p},
		{55, p}
	},
	{
		{10, a},
		{11, p},
		{15, a},
		{16, p},
		{20, a},
		{21, p},
		{30, a},
		{31, p},
		{35, a},
		{36, p},
		{40, a},
		{41, p},
		{50, a},
		{51, p}
	},
	{
		{10, a},
		{11, p},
		{15, a},
		{16, p},
		{20, a},
		{21, p},
		{30, a},
		{31, p},
		{35, a},
		{37, a},
		{40, a},
		{41, p},
		{50, a},
		{51, p}
	},
}

bone_tiles = {45, 46, 47, 67, 83}
grass_tiles = {14, 15}
light_poppy_tiles = {14, 15, 44}
medium_poppy_tiles = {14, 15, 44, 30, 31}
heavy_poppy_tiles = {44, 30, 31}

title_colours = {2, 15}

player_colours = {}
player_colours[3] = {5, 2, 0, 4, 7, 10}
player_colours[1] = {5, 2, 0, 1}
-- shield colours
player_colours[9] = {5, 4, 2, 1, 13, 0}
player_colours[14] = {5, 4, 2, 1, 13, 0, 8, 9, 12}

priest_colours = {}
-- hair
priest_colours[3] = {0, 4, 5, 6, 7, 2}
-- tunic
priest_colours[1] = {5, 2, 0, 1}
-- cloak
priest_colours[2] = {5, 2, 0, 1}

archer_colours = {}
archer_colours[0] = {0, 5, 1}

swordsman_colours = {}
swordsman_colours[0] = {0, 5, 1}

shield_tiles = {
	142, 143,
	157, 158, 159,
	172, 173, 174, 175,
	188, 189, 190, 191,
	204, 205, 206, 207,
	220, 221, 222, 223,
	236, 237, 238, 239,
	252, 253, 254, 255
}

function _init()
	cart_data_loaded = cartdata("hyh_charge_data")
	previous_high_score = 0
	high_score = 0
 -- possible states:
 --  1) menu
 --  2) play
 --  3) death_wait
 --  4) report
	game_state = "menu"
	state_timer = -1
	
	attack_released = true
	shield_released = true

	battlecry = ""
	battlecry_timer = -1
	--generate_battlecry()
	
	feedback = ""
	
	title_colour_index = 1
	title_colour = 2
	title_timer = 15

	plax_offset = {0,0,0,0,0}
	plax_speed = {0.25, 0.5, 1, 1.5, 2}
	--plax_speed = {0.1, 0.25, 0.5, 1, 1.5}
	plax_multiplier = 1
	plax_multiplier_timer = -1

	shake_timer = -1
	shake_amount = 1

	enemies = {}
	current_wave = {}
	--create_enemy("priest")
	projectiles = {}
	environment = {}
	environment_timer = 6
	environment_spawn_rate = 6
	blood_splatter = {}

	player = {}
	reset_player(true)
	-- not sure about the channels
	-- here - sfx and music seem
	-- to be clashing
	music(0, 1 + 2 + 8)
end

function reset_player(change_colours)
	player.alive = true
	player.animation = "run"
	player.frame = 1
	player.frame_timer = 0
	player.state_timer = -1
	player.distance = 0
	player.wave = 1
	player.current_enemy = 1

	if change_colours then
		player.selected_colours = {}
		select_player_colours()
	end
end

function select_player_colours()
	player.shield = shield_tiles[flr(rnd(#shield_tiles)) + 1]
	local beard_index = flr(rnd(#player_colours[3])) + 1
	player.selected_colours[3] = player_colours[3][beard_index]
	player.selected_colours[1] = -1
	while player.selected_colours[1] == -1 do
		local tunic_index = flr(rnd(#player_colours[1])) + 1
		if tunic_index > 3 or tunic_index ~= beard_index then
			player.selected_colours[1] = player_colours[1][tunic_index]
		end
	end
	local shield_index = flr(rnd(#player_colours[9])) + 1
	player.selected_colours[9] = player_colours[9][shield_index]
	player.selected_colours[14] = -1
	while player.selected_colours[14] == -1 do
		local secondary_index = flr(rnd(#player_colours[14])) + 1
		if secondary_index > 6 or secondary_index ~= shield_index then
			player.selected_colours[14] = player_colours[14][secondary_index]
		end
	end
end

function reset_game(change_colours)
	reset_player(change_colours)
	current_wave = generate_wave(1, 5)
	enemies = {}
	projectiles = {}
	environment = {}
	plax_multiplier = 1
	plax_multiplier_timer = -1
	game_state = "play"
	state_timer = -1
	generate_battlecry()
end

function select_priest_colours()
	local selected_colours = {}
	local hair_index = flr(rnd(#priest_colours[3])) + 1
	selected_colours[3] = priest_colours[3][hair_index]
	
	local tunic_index = flr(rnd(#priest_colours[3])) + 1
	selected_colours[1] = priest_colours[1][tunic_index]
	
	selected_colours[2] = -1
	while selected_colours[2] == -1 do
		local cloak_index = flr(rnd(#priest_colours[2])) + 1
		if cloak_index ~= tunic_index then
			selected_colours[2] = priest_colours[2][cloak_index]
		end
	end
	
	return selected_colours
end

function select_archer_colours()
	local selected_colours = {}
	local armor_index = flr(rnd(#archer_colours[0])) + 1
	selected_colours[0] = archer_colours[0][armor_index]
	
	return selected_colours
end

function select_swordsman_colours()
	local selected_colours = {}
	local armor_index = flr(rnd(#swordsman_colours[0])) + 1
	selected_colours[0] = swordsman_colours[0][armor_index]
	
	return selected_colours
end

function create_enemy(t)
	local enemy = {}
	enemy.type = t
	if t == "priest" then
		enemy.animations = priest_anims
		enemy.animation = "run"
		enemy.speed = 0.5
		enemy.selected_colours = select_priest_colours()
	elseif t == "archer" then
		enemy.animations = archer_anims
		enemy.animation = "aim"
		enemy.speed = 0
		enemy.selected_colours = select_archer_colours()
	elseif t == "swordsman" then
		enemy.animations = swordsman_anims
		enemy.animation = "run"
		enemy.speed = -0.7
		enemy.selected_colours = select_swordsman_colours()
	end
	enemy.y = 72
	enemy.x = 136
	enemy.alive = true
	
	enemy.frame = 1
	enemy.frame_timer = 0
	add(enemies, enemy)
end

function remove_enemy(e)
	del(enemies, e)
end

function remove_projectile(p)
	del(projectiles, p)
end

function remove_environment(e)
	del(environment, e)
end

function create_projectile(x)
	local projectile = {}
	projectile.y = 72
	projectile.x = x
	projectile.type = "arrow"
	projectile.animations = arrow_anims
	projectile.animation = "fly"
	projectile.frame = 1
	projectile.frame_timer = 0
	projectile.speed = 2
	projectile.alive = true
	
	add(projectiles, projectile)
end

function create_environments()
	local create_ground
	if player.distance < 120 then
		-- create one vegetation every
		-- 4 tiles
		create_ground = flr(rnd(4)) == 1
	elseif player.distance < 240 then
		create_ground = flr(rnd(3)) == 1
	elseif player.distance < 480 then
		create_ground = flr(rnd(2)) == 1
	else
		create_ground = true
	end
	if create_ground then
 	local e_ground = {}
 	e_ground.y = 80
 	e_ground.x = 136
 	e_ground.foreground = false
 	
 	-- determine tile selection
 	local tiles = grass_tiles
 	if player.distance > 360 then
 		tiles = heavy_poppy_tiles
 	elseif player.distance > 200 then
 		tiles = medium_poppy_tiles
 	elseif player.distance > 60 then
 		tiles = light_poppy_tiles
 	end
 	
 	e_ground.tile = tiles[flr(rnd(#tiles)) + 1]
 	add(environment, e_ground)
 end
 
 local create_bones = false
 if player.distance > 800 then
 	create_bones = flr(rnd(3)) == 1
 elseif player.distance > 600 then
 	create_bones = flr(rnd(6)) == 1
 elseif player.distance > 300 then
 	create_bones = flr(rnd(9)) == 1
 elseif player.distance > 100 then
 	create_bones = flr(rnd(16)) == 1
 end
 --create_bones = flr(rnd(3)) == 1
 if create_bones then
 	local e_bones = {}
 	e_bones.y = 90 + flr(rnd(20))
 	e_bones.x = 136
 	e_bones.foreground = true
 	
 	e_bones.tile = bone_tiles[flr(rnd(#bone_tiles)) + 1]
 	add(environment, e_bones)
 end
end

function die(anim)
	player.alive = false
	player.animation = anim
	player.frame_timer = 0
	player.frame = 1
	player.state_timer = -1
	plax_multiplier = 0
	if anim == "trip" then
		set_small_shake()
		sfx(10)
	else
		set_large_shake()
		sfx(6)
	end
	game_state = "death_wait"
	state_timer = 120
	handle_high_score()
end

function handle_high_score()
	if cart_data_loaded then
		previous_high_score = dget(0)
		if player.distance > previous_high_score then
			high_score = player.distance
			dset(0, high_score)
		end
	else
		-- not sure why this would occur
		-- but will deal by using session
		-- scores only
		previous_high_score = high_score
		if player.distance > previous_high_score then
			high_score = player.distance
		end
	end
end

function update_projectiles()
	for p in all(projectiles) do
		if p.alive then
			p.x -= (plax_speed[4] * plax_multiplier) + p.speed
		else
			p.x -= plax_speed[4] * plax_multiplier
		end
	
 	-- update animation
 	update_animation(p)
 	
 	if p.x < -16 then
 		remove_projectile(p)
 	else
 	
  	-- check for player contact
  	if p.alive and player.alive then
  		if p.x < 24 and player.animation == "shield" then
  			p.alive = false
  			p.animation = "collide"
  			p.frame_timer = 0
  			p.frame = 1
  			sfx(6, 2)
  			set_small_shake()
  		elseif p.x < 24 then
  			die("die")
  			create_blood(p.x + 4, 78)
  		end
  	end
  end
 end
end

function update_environment()
	for e in all(environment) do
		e.x -= plax_speed[4] * plax_multiplier
		
 	if e.x < -16 then
 		remove_environment(e)
 	end
 end
end

function update_enemies()
	for enemy in all(enemies) do
		if enemy.alive then
			-- todo: need a way to disable plax
			-- on player death that allows
			-- enemies to keep moving
			enemy.x -= (plax_speed[4] * plax_multiplier) - enemy.speed
		else
			enemy.x -= plax_speed[4] * plax_multiplier
		end
	
 	-- update animation
 	update_animation(enemy)
 	
 	if enemy.x < -16 then
 		remove_enemy(enemy)
 	else
 		
 		-- for the archer, check if
 		-- it is time to fire
 		if enemy.type == "archer" then
 			if enemy.animation == "aim" and enemy.x < 100 then
 				enemy.animation = "fire"
 				create_projectile(enemy.x)
 				sfx(11)
 			end
 		end
 	
  	-- check for player contact
  	if enemy.alive and player.alive then
  		if enemy.x < 28 and player.animation == "attack" then
  			enemy.alive = false
  			enemy.animation = "die"
  			enemy.frame_timer = 0
  			enemy.frame = 1
  			sfx(6, 2)
  			set_large_shake()
  			create_blood(enemy.x + 8, 78)
  			plax_multiplier = 0.5
  			plax_multiplier_timer = 15
  		elseif enemy.x < 20 then
  			die("trip")
  		end
  	end
  end
 end
end

function update_animation(a)
	local animations = a.animations
	if animations[a.animation][a.frame][2] ~= -1 then
 	a.frame_timer += 1
 	if a.frame_timer >= animations[a.animation][a.frame][2] then
 		a.frame_timer = 0
 		a.frame += 1
 		if a.frame > #animations[a.animation] then
 			a.frame = 1
 		end
 	end
 end
end

function generate_wave(num, start)
	local wave = {}
	local length = 0
	local pattern
	if num > #wave_patterns then
		pattern = wave_patterns[#wave_patterns]
	else
		pattern = wave_patterns[num]
	end
	-- this adds he patterns in
	-- order of difficulty
	-- would prefer random
	for i, count in pairs(pattern) do
		if count > 0 then
			for dif = 1, count do
				local pat = patterns[i][ceil(rnd(#patterns[i]))]
				local newlength
				for ei, e in pairs(pat) do
					add(wave, {length + e[1], e[2]})
					newlength = length + e[1]
				end
				length = newlength
			end
		end
	end
	wave.length = length + 5
	wave.start = start
	return wave
end

function spawn_wave()
	if player.alive then
		
		if player.current_enemy <= #current_wave - 1 then
			if player.distance >= current_wave.start + current_wave[player.current_enemy][1] then
				create_enemy(current_wave[player.current_enemy][2])
				if current_wave[player.current_enemy][2] == "swordsman" then
					sfx(12, 2)
				end
				player.current_enemy += 1
			end
		end		
		
		if player.distance >= current_wave.start + current_wave.length then
			player.wave += 1
			player.current_enemy = 1
			current_wave = generate_wave(player.wave, player.distance + 5)
			generate_battlecry()
		end
	end
end

function _update60()
	-- update parallax
	for p=1,5 do
		plax_offset[p] += plax_speed[p] * plax_multiplier
		if plax_offset[p] > 384 then
			plax_offset[p] -= 384
		end
	end
	
	if plax_multiplier_timer == 0 then
		plax_multiplier = 1
	end
	if plax_multiplier_timer > -1 then
		plax_multiplier_timer -= 1
	end
	
	if battlecry_timer > -1 then
		battlecry_timer -= 1
	end
	
	-- update state
	if player.state_timer == 0 then
		-- reset state to run
		player.animation = "run"
		--player.frame_timer = 0
		--player.frame = 1
	end
	
	-- update game_state
	if state_timer > -1 then
		state_timer -= 1
		if state_timer == 0 then
			if game_state == "death_wait" then
				game_state = "report"
				determine_feedback()
			end
		end
	end
	
	if game_state == "play" then
 	if player.alive then
 		player.distance += 1/30
 	end
 	
 	if player.state_timer > -1 then
 		player.state_timer -= 1
 	end
 	
 	if btn(—) == false then
 		shield_released = true
 	end
 	if btn(Ž) == false then
 		attack_released = true
 	end
 	
 	if player.alive then
  	if btnp(—) and shield_released then
				--select_player_colours()
  		if player.animation == "run" then
  			shield_released = false
  			player.animation = "shield"
  			--player.frame_timer = 0
  		 --player.frame = 1
  			player.state_timer = 45
  			sfx(8)
  		end
  		--generate_battlecry()
  	end
  	
  	if btnp(Ž) and attack_released then
  		--select_player_colours()
  		if player.animation ~= "attack" then
  			attack_released = false
  			player.animation = "attack"
  			player.state_timer = 15
  			player.frame = 1
  			player.frame_timer = 0
  			sfx(9)
  			set_small_shake()
  		end
  	end
  end
 elseif game_state == "report" or game_state == "menu" then
 	if btnp(—) or btnp(Ž) then
 		reset_game(game_state == "report")
 	end
 	if game_state == "menu" then
 		title_timer -= 1
 		if title_timer == 0 then
 			title_colour_index += 1
 			if title_colour_index > #title_colours then
 				title_colour_index = 1
 			end
 			title_colour = title_colours[title_colour_index]
 			title_timer = 15
 		end
 	end
	end
	
	-- update animation
	if player_anims[player.animation][player.frame][2] ~= -1 then
 	player.frame_timer += 1
 	if player.frame_timer >= player_anims[player.animation][player.frame][2] then
 		player.frame_timer = 0
 		player.frame += 1
 		if player.frame > #player_anims[player.animation] then
 			player.frame = 1
 		end
 	end
	end
	
	if game_state ~= "menu" then
		spawn_wave()
	end
	
	-- enemies
	update_enemies()
	
	-- projectiles
	update_projectiles()
	
	-- blood
	update_blood()
	
	-- environment
	if environment_timer == 0 then
		environment_timer = environment_spawn_rate
		create_environments()
	else
		environment_timer -= 1
	end
	update_environment()
	
	-- perform camera shake
	shake_camera()
end

function set_small_shake()
	shake_timer = 10
	shake_amount = 2
end

function set_large_shake()
	shake_timer = 15
	shake_amount = 3
end

function shake_camera()
	if shake_timer > -1 then
		shake_timer -= 1
		if shake_timer == -1 then
			camera()
		else
			camera(flr(rnd(shake_amount)), flr(rnd(shake_amount)))
		end
	end	
end

function draw_background()
	draw_plax_1()
	draw_plax_2()
	draw_plax_3()
	draw_plax_4()
	draw_environment(false)
end

function draw_plax_1()
	local offset = plax_offset[1]
	local basex = -offset
	local limitx = 512 - offset
	local basey = 64
	local limity = 87
	
	-- base pink
	rectfill(basex, basey, limitx, limity, 15)
	
	-- upper pink
	rectfill(basex, basey, limitx, limity - 8, 14)
	
	-- lines
	line(basex, 78, limitx, 78, 15)

	line(basex, 76, (512 / 2 - 8) - offset, 76, 15)
	line((512 / 2 + 8) - offset, 76, limitx, 76, 15)

	for x=0,3 do
		line(((512/4) * x) + 16 - offset, 73, (512/4) * (x + 1) - 16 - offset, 73, 15)		
		line(((512/4) * x) + 48 - offset, 69, (512/4) * (x + 1) - 24 - offset, 69, 15)		
		line(((512/4) * x) + 24 - offset, 64, (512/4) * (x + 1) - 64 - offset, 64, 15)		
	end
end

function draw_plax_2()
	local offset = plax_offset[2]
	-- far mountains
	for i=0,7 do
		local x = (512/8) * i - offset
		spr(1, x, 64, 3, 3)
		spr(1, x + (8*3), 64, 3, 3, true)
	end
end

function draw_plax_3()
	local offset = plax_offset[3]
	local basex = -offset
	local limitx = 512 - offset
	local basey = 32
	local limity = 63
	
	-- base pink
	rectfill(basex, basey, limitx, limity, 14)
	
	-- upper red
	rectfill(basex, basey, limitx, 49, 8)
	
	-- lines
	line(basex, 58, limitx, 58, 8)
	line(basex, 55, limitx, 55, 8)
	line(basex, 53, limitx, 53, 8)
	line(basex, 51, limitx, 51, 8)

	line(basex, 47, (512 / 2 - 8) - offset, 47, 14)
	line((512 / 2 + 8) - offset, 47, limitx, 47, 14)

	for x=0,3 do
		line(((512/4) * x) + 16 - offset, 44, (512/4) * (x + 1) - 16 - offset, 44, 14)		
		line(((512/4) * x) + 48 - offset, 41, (512/4) * (x + 1) - 24 - offset, 41, 14)		
		line(((512/4) * x) + 24 - offset, 37, (512/4) * (x + 1) - 64 - offset, 37, 14)		
	end
	
	for x=0,7 do
		line(((512/8) * x) + 21 - offset, 33, (512/8) * (x+1) - 8 - offset, 33, 14)
	end
	
	-- near mountains
	for i=0,3 do
		local x = (512/4) * i - offset
		spr(53, x, 48, 11, 5)
		--spr(, x + (8*3), 64, 3, 3, true)
	end
end

function draw_plax_4()
	local offset = plax_offset[4]
	local basex = -offset
	local limitx = 512 - offset
	local basey = 0
	local limity = 31
	
	-- base red
	rectfill(basex, basey, limitx, limity, 8)
	
	-- upper maroon
	rectfill(basex, basey, limitx, 1, 2)
	
	-- lines
	--line(basex, 4, limitx, 4, 2)
	line(basex, 4, (512 / 2 - 8) - offset, 4, 2)
	line((512 / 2 + 8) - offset, 4, limitx, 4, 2)

	for x=0,7 do
		line(((512/8) * x) + 24 - offset, 28, (512/8) * (x+1) - 8 - offset, 28, 14)

		line(((512/8) * x) + 48 - offset, 23, (512/8) * (x+1) - 32 - offset, 23, 14)
	end

	--line(basex, 76, (512 / 2 - 8) - plax_offset[1], 76, 15)
	--line((512 / 2 + 8) - plax_offset[1], 76, limitx, 76, 15)

	--for x=0,3 do
	--	line(((512/4) * x) + 16 - plax_offset[1], 73, (512/4) * (x + 1) - 16 - plax_offset[1], 73, 15)		
	--	line(((512/4) * x) + 48 - plax_offset[1], 69, (512/4) * (x + 1) - 24 - plax_offset[1], 69, 15)		
	--	line(((512/4) * x) + 24 - plax_offset[1], 64, (512/4) * (x + 1) - 64 - plax_offset[1], 64, 15)		
	--end
end

function draw_ground()
	-- maroon
	rectfill(0, 88, 132, 105, 2)

	-- navy
	rectfill(0, 106, 132, 119, 1)
	
	-- black
	rectfill(0, 124, 132, 128, 0)
	
	-- lines
	
	line(0, 108, 132, 108, 2)
	line(0, 111, 132, 111, 2)
	line(0, 102, 132, 102, 1)
	line(0, 116, 132, 116, 0)
	line(0, 120, 132, 120, 0)
	line(0, 122, 132, 122, 0)
	
	local offset = plax_offset[4]
	local basex = -offset
	map(0, 0, basex, 0, 128, 32)
end

function draw_player()
	palt(0, false)
	palt(11, true)
	
	for original, new in pairs(player.selected_colours) do
		pal(original, new)
	end
	
 spr(
 	player_anims[player.animation][player.frame][1],
 	8,
 	72,
 	player_anims[player.animation][player.frame][3],
 	2
 )
 
 if player.animation == "shield" then
 	local shield_x = 8 + 10
 	local shield_y = 72 + 6
 	if player.frame == 2 then
 		shield_y += 1
 	end
 	spr(
  	player.shield,
  	shield_x,
  	shield_y,
  	1,
  	1
  )
 end
 
 pal()
	palt(0, true)
	palt(11, false)
end

function draw_distance()
	local dist = flr(player.distance)
	print("distance: "..dist.."m", 4, 95, 7)
end

function draw_enemies()
	for enemy in all(enemies) do
		palt(0, false)
		palt(11, true)
		for original, new in pairs(enemy.selected_colours) do
 		pal(original, new)
 	end
  spr(
  	enemy.animations[enemy.animation][enemy.frame][1],
  	enemy.x,
  	enemy.y,
  	enemy.animations[enemy.animation][enemy.frame][3],
  	2
  )
  pal()
 end
	palt(0, true)
	palt(11, false)
end

function draw_projectiles()
	for p in all(projectiles) do
  spr(
  	p.animations[p.animation][p.frame][1],
  	p.x,
  	p.y,
  	p.animations[p.animation][p.frame][3],
  	1
  )
 end
end

function draw_environment(foreground)
	for e in all(environment) do
		if e.foreground == foreground then
   spr(
   	e.tile,
   	e.x,
   	e.y,
   	1,
   	1
   )
  end
 end
end

function draw_report()
	print_centred("you charged "..flr(player.distance).."m", 16, 15, 1, true)
	if player.distance > previous_high_score then
		print_centred("new best!", 24, 11, 1, true)
	else
		print_centred("best: "..flr(previous_high_score).."m", 24, 8, 1, true)
	end
	print_centred(feedback, 40, 15, 1, true)
	print_centred("press — to retry", 56, 12, 1, true)
end

function draw_menu()
	--print_centred("charge!", 16, 14, 1, true)
	pal(14, title_colour)
	spr(37, 38, 12, 7, 1)
	pal()
	print_centred("Ž (z/c) to attack", 32, 15, 1, true)
	print_centred("— (x/v) to shield", 40, 15, 1, true)
	print_centred("press any key to start", 56, 12, 1, true)
	spr(141, 1, 120, 1, 1)
	print("hyperlink your heart", 12, 121, 14)
end

function _draw()
	cls()
	draw_background()
	draw_ground()
	draw_environment(true)
	draw_enemies()
	draw_player()
	draw_projectiles()
	draw_blood()
	if game_state == "play" then
		draw_distance()
		draw_battlecry()
	elseif game_state == "report" then
		draw_report()
	elseif game_state == "menu" then
		draw_menu()
	end
end
-->8
-- battlecries

gods = {
	"loki",
	"thor",
	"freya",
	"odin",
	"frey",
	"idun",
	"sif",
	"ragnar",
	"heimdall",
	"frigg",
	"baldr",
	"fenrir"
}

body_parts = {
	"fingers",
	"toes",
	"nose",
	"nostrils",
	"nipples",
	"knees",
	"buttocks",
	"elbows",
	"eyeballs",
	"beard",
	"lips",
	"teeth",
	"ears",
	"feet",
	"thighs",
	"thumb"
}

terrible_deaths = {
	"pathetic",
	"your children will be ashamed",
	"you will be forgotten"
}

poor_deaths = {
	"songs about you will be short",
	"i could've thrown you this far",
	"more plunder for the rest of us"
}

good_deaths = {
	"one ticket to valhalla",
	"a warrior is you",
	"your family will be proud"
}

great_deaths = {
	"odin himself will kneel to you",
	"you will feast in valhalla"
}

feedback_strings = {
	{0, terrible_deaths},
	{120, poor_deaths},
	{340, good_deaths},
	{540, great_deaths}
}

function get_text_width(t)
	local len = #t
	return len * 4
end

function draw_battlecry()
	if battlecry_timer > -1 then
		draw_textbox(battlecry, 8, 56)
	end
end

function draw_textbox(t, x, y)
	local twidth = get_text_width(t)
	local box_width = twidth + 4
	local box_height = 10
	
	draw_box(x + 1, y + 1, box_width, box_height, 1)
	draw_box(x, y, box_width, box_height, 7)		
	spr(21, x + 18, y + box_height + 1)

	print(t, x + 3, y + 3, 1)
end

function print_centred(t, y, colour, shadow, outline)
	local width = get_text_width(t)
	local x = flr((128 - width) / 2)
	if shadow ~= -1 then
		
		if outline then
			print(t, x, y-1, shadow)
			print(t, x-1, y, shadow)
			print(t, x+1, y, shadow)
			print(t, x, y+1, shadow)
			print(t, x-1, y-1, shadow)
			print(t, x+1, y+1, shadow)
			print(t, x-1, y+1, shadow)
			print(t, x+1, y-1, shadow)
		else
			print(t, x+1, y+1, shadow)
		end
	end
	print(t, x, y, colour)
end

function draw_box(x, y, w, h, colour)
	rectfill(x + 1, y, x + w - 1, y + h, colour)
	rectfill(x, y + 1, x + w, y + h -1, colour)
end

function generate_battlecry()
	battlecry_timer = 60 * 5
	battlecry =
		"by "..
		gods[flr(rnd(#gods)) + 1]..
		"'s "..
		body_parts[flr(rnd(#body_parts)) + 1]..
		"!!"
end

function determine_feedback()
	for choice in all(feedback_strings) do
		if player.distance > choice[1] then
			feedback = choice[2][flr(rnd(#choice[2])) + 1]
		else
			return
		end
	end
end
-->8
-- effects

function create_blood(x, y)
	for i = 0, 20 do
 	local blood = {}
 	blood.x = x
 	blood.y = y
 	blood.speed = {}
 	blood.speed.x = flr(rnd(6) - 1)
 	blood.speed.y = -flr(rnd(5) + 1)
 	blood.accel = {}
 	blood.accel.x = -0.1
 	blood.accel.y = 0.5
 	blood.size = flr(rnd(2))
 	add(blood_splatter, blood)
	end
end

function update_blood()
	for blood in all(blood_splatter) do
		blood.x += blood.speed.x
		blood.y += blood.speed.y
		blood.speed.x += blood.accel.x
		blood.speed.y += blood.accel.y
		if blood.x < -1 or blood.y > 88 then
			del(blood_splatter, blood)
		end
	end
end

function draw_blood()
	for blood in all(blood_splatter) do
		rectfill(blood.x, blood.y, blood.x + blood.size, blood.y + blood.size, 8)
	end
end
__gfx__
000000000000000000000000000000000000000611111111bbbbbbbbbbbbb5bbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000
000000000000000000000000000000000000006611221222bbbbb8bb7bb111bbbbbbb868bbbbb5bbbbbbbbbbbbbbb5bbbbbbb8bbbbbbbbbb0000000000010000
007007000000000000000000000000000000066622222221bbbbb8687771111bbbbbb8867bb111bbbbbbb8bb7bb111bbbbbbb868bbbbb5bb0000000001100000
000770000000000000000000000000000000666622212222bbbbb886b71111cbbbbbb8b27771111bbbbbb8687771111bbbbbb8867bb111bb0000000000100100
000770000000000000000000000000000006666622222222bbbbb8b2bb11cffbbbbbbbb2b71111cbbbbbb886b71111cbbbbbb8b27771111b0000010000101000
007007000000000000000000000000000066666622222222bbbbbb323333f03bbbbbbbbffb11cffbbbbbb8b2bb77777bbbbbbbb2b71111cb0100100001111000
000000000000000000000000000000000666666622222222bbbbbbbff333303bbbbbbb3f4333f03bbbbbbb3237999997bbbbbb3ff377777b0010101010111010
000000000000000000000000000000006666666622222222bbbbbbbf40333312bbbbbbb11333333bbbbbbbbff6999997bbbbbbbf479999970010101001111110
000000000000000000000000000000066666666677777771bbbbbbb111100102bbbbbbb111333312bbbbbbbf47997997bbbbbbb1169999970000000008800000
000000000000000000000000000000666666666677777711bbbbbbbb11110142bbbbbbbb11100102bbbbbbb116999997bbbbbbbb179979970000000008180000
000000000000000000000000000006666666666677777110bbbbb67701111142bbbb776601110142bbbbb67706999997bbbb7766069999970000880000880000
000000000000000000000000000066666666666677771100bbbb66666000022bbbb6665600011142bbbb66666067677bbbb66656069999970880818000188000
000000000000000000000000000666666666666677711000bbbb66666670bbbbbbb666665600022bbbbb66666670bbbbbbb666665667677b8180088088181800
070000000000000000000000006666666666666677110000bbb65655667bbbbbbb6666665660bbbbbbb65655667bbbbbbb6666665660bbbb8810110081818801
722222220000000000000000066666666666666671100000b6666656666bbbbb6bb66666667bbbbbb6666656666bbbbb6bb66666667bbbbb0010010108810010
070000000000000000000000666666666666666601000000b6666666666bbbbb66b6665667bbbbbbb6666666666bbbbb66b6665667bbbbbb0010010101110010
00000000000000000000000666666666666666660111111111111111001111001111111001111110111111111111000000000000000000000000000000000000
000000000000000000000066666666666666666611eeeee11ee11ee1011ee1101eeeee1111eeee101eeeeee11ee100000000000000000000004ff00000f00000
00000000000000000000066666666666666666661ee111111ee11ee111e11e111ee11ee11ee111101ee111111ee10000000000000f0000f0004f000004f00000
000f00f0000000000000666666666666666666661ee100001ee11ee11ee11ee11ee11ee11ee111111eeee1001ee100000008800104ffff44000f0000004f0000
077f0f02000000000006666666666666666666661ee111111eeeeee11eeeeee11eeeee111ee11ee11ee111111ee100001081801000400040000f00000004f000
072fff20000000000066666666666666666666661eeeeee11ee11ee11ee11ee11ee11ee11eeeeee11eeeeee1111100000188001000000000004f000000004ff0
0002f2000000000006666666666666666666666611eeeee11ee11ee11ee11ee11ee11ee111eeeee11eeeeee11ee1000001011010000000000044f00000000400
0f0f0f0f000000006666666666666666666666660111111111111111111111111111111101111111111111111111000001010010000000000000000000000000
00000000000000066666666666666666666666660000000000000000000000000000000000000000000006000000000000000000000000000000000000000000
000000000000006666666666666666666666666600000000000000000000000000000000000000000000dd600000000000000000000000000000000000000000
00000000000006666666666666666666666666660000000000000000000000000000000000000000000dddd60000000000000000000000000000000000000000
0000000000006666666666666666666666666666000000000000000000000000000000000000000000dddddd6000000000000000000000000000000000000000
077000020006666666666666666666666666666600000000000000000000000000000000000000000dddddddd600000000000000000000000000000000000000
07200020006666666666666666666666666666660000000000000000000000000000000000000000dddddddddd60000000000000000000000000000000000000
0002020006666666666666666666666666666666000000000000000000000000000000000000000dddddddddddd6000000000000000000000000000000000000
000000006666666666666666666666666666666600000000000000000000000000000000000000dddddddddddddd600000000000000000000000000000000000
bbbbbbbbbbfffbbb0000000000000000000000000000000000000000000000000000000000000dddddddddddddddd60000000000000000000000000000000000
bbfffbbbb33333bb00000000000fff0000000000000000000000000000000000000000000000dddddddddddddddddd6000000000000000000000000000000000
b33333bbb33cfcbb000000000041f1f00000000000000000000000000000000000000000000dddddddddddddddddddd600000000000000000000000000000000
b33cfcbbb3ff0fbb000000000041f1f0000000000000000000000000000000000000000000ddddddd66666dddddddddd60000000000000000000000000000000
b3ff0fbbbbff0bbb000000000044f4f000000000000000000000000000000000000000000ddddddddddddd6dddddddddd6000000000000000000000000000000
bbfffbbbbb117bbb0000000000040f000000000000000000000000000000000000000000ddddddddddddddd6dddddddddd600000000000000000000000000000
bb117bbbb22202bb0000000000000000000000000000000000000000000000000000000ddddddddddddddddd6ddddd6666666666000000000000000000000000
b22202b4b22201bb000000000000000000000000000000000000000000000000000000ddddddddddddddddddd6ddddd666666666600000000000000000000000
b2220124b22ff1b400000000000000000000000000000000000000000000000000000ddddddddddddddddddddd6ddddd66666666660000000000000000000000
b2ff0124b22ff1240000000000000000000000000000000000000000000000000000ddddddddddddddddddddddd6ddddd6666666666000000000000000000000
b2ff01bb22110124000000000000000000000000000000000000000000000000000ddddddddddddddddddddddddd6ddddd666666666600000000000000000000
222201bb222201bb00000000000fff000000000000000000000000000000000000ddddddddddddddddddddddddddd6ddddd66666666660000000000000000000
222011bb222011bb0000000000f11ff0000000000000000000000000000000000ddddddddddddddddddddddddddddd6666666666666666000000000000000000
222111bb220111bb0000000000444f00000000000000000000000000006666666666666666666666666666ddddddddddddddd666666666600000000000000000
220b11bb201b11bb0000000000411ff00000000000000000000000000ddddddddddddddddddddddddddddd6ddddddddddddddd66666666660000000000000000
201bbbbbbbbb11bb0000000000044400000000000000000000000000ddddddddddddddddddddddddddddddd6ddddddddddddddd6666666666000000000000000
bbbfffbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000ddddddddddddddddddddddddddddddddd6ddddddddddddddd666666666600000000000000
bb33333bbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000ddddddddddddddddddddddddddddddddddd6ddddddddddddddd66666666660000000000000
bb333f8bbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000ddddddddddddddddddddddddddddddddddddd6ddddddddddddddd6666666666000000000000
b833f8fbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000ddddddddddddddddddddddddddddddddddddddd6ddddddddddddddd666666666600000000000
bb8888bbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000ddddddddddddddddddddddddddddddddddddddddd6ddddddddddddddd66666666660000000000
bbb887bbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000ddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd6666666666000000000
b882212bbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000ddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd666666666600000000
bb22012bbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000ddddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd66666666660000000
bb22012bbbbbbbbbbbbbbbbbbbbbbbbb000000000000000ddddddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd6666666666000000
bb220124bbbbbbbbbbbbbbbbbbbbbbbb00000000000000ddddddddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd666666666600000
b22ff124bbbbbbbbbbbbbbbbbbbbbbbb0000000000000ddddddddddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd66666666660000
b22ff124bbbbbbbbbbbbbbbbbbbbbbbb000000000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd6666666666000
b22011bbbbbbbbbbbb22222228bb333b00000000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd666666666600
b20111bbbbbbbbbbb22222222288333f0000000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd66666666660
b0111bbbbbbbbbbb1222ff222888f33f000000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd6666666666
bbb11bbbbbbbbbbb1222ff888888888800000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd66666ddddddddddd666666666
bbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000099999bbb99999bbb
bbb868bbbbbb5bbbbbbbbbbbbb5bbbbbbbbbbbbbbbb8bbbbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000ff0099999bbb9e9e9bbb
bbb886b7bb111bbbbbbbb7bb111bbbbbbbbbbbbbbbb8687bb111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000f00f099e99bbb99e99bbb
bbb8b2b7771111bbbbbbb7771111bbbbbbbbbbbbbbb8867771111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00f00f0099999bbb9e9e9bbb
bbbbb2bb71111cbbbb7bbb71111cbbbbbbbbbbbbbbb8b2b71111cbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbb8bbbbbbbbbbbbbbbbb000f00f099999bbb99999bbb
bbbbbffbb11cffbbbbb7bbb11cffbbbbbbbbbbbbbbbbbffb11cffbbbbbbbbbbbbbbbbbbbbbbbbb2282bb8bbbbbbbbbbbbbbbbbbb0000ff00bbbbbbbbbbbbbbbb
bbbbbf43333f03bbbbb773333f032bbbbbbbbbbbbbbb3f43330032bbbbbbbbbbbbbbbbbbbbb1cf338828bbbbbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbb
bbbbb1113333332bbbbb7773333322bb8888bbbbbbbbb113330032bbbbbbbbbbbbbbbbbbb5111f003888bbbbbbbbbbbbbbbbbbbb00fffff0bbbbbbbbbbbbbbbb
bbbbbb1113333122bbbbbb77777722bbb86bbbbbbbbbbb10333312bbbbbbbbbbbbbbbbbbbb111c0030080bbbbbbbbbbbbbbbbbbb99999bbb99999bbbe999ebbb
bbbbbbb111001022bbbbbb117777ff72768bbbbbbbbbbb11100102bbbbbbbbbbbbbb77bbbb111133381180bbbbbbbbbbbbbbbbbb99e99bbb9eee9bbb9e9e9bbb
bbbb776611101442bbbbb67711107777777bbbbbbbbbbb1111012bbbbbbbbbbbbbb77bbbbbb711333111011bbbbbbbbbbbbbbbbb999e9bbb9e9e9bbb99e99bbb
bbb6665600111442bbbb666660112bbbbbbbbbbbbbbbb1011111bbbbbbbbbbb333b771bbbbb77b3301110111bbf3333bbbbbbbbb9eee9bbb9eee9bbb9e9e9bbb
bbb666665600022bbbbb66666670bbbbbbbbbbbbbbb22110000bbbbbbbbbbb1133311115bb77bf4111101122bcfff3388bbbbbbb99999bbb99999bbbe999ebbb
bb6666665660bbbbbbb65655667bbbbbbbbbbbbbbbb2111110bbbbbbbb1111111331111bbb862ff1bbb111b2111c333388811bbbbbbbbbbbbbbbbbbbbbbbbbbb
6bb66666667bbbbbb6666656666bbbbbbbbbbbbbbbbbbb211bbbbbbbb2111ff13333c11bbb68bb3bbbbb21bb111713388ff11222bbbbbbbbbbbbbbbbbbbbbbbb
66b6665667bbbbbbb6666666666bbbbbbbbbbbbbbbbbb221bbbbbbbb22211ff00333ffcbb8888bbbbbbb22bb177773388ff8882bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb7bbbbbbbbbbbbbbb7bbbbbbbbbb22bbbb0007bbbbbbbbbbbbbbbbb0000000000000000000000000000000099999bbb99e99bbb99e99bbb99e99bbb
bbbbbbbbb007bbbbbbbbb2bbb007bbbbbbbb2b7bbbfc007bbbbbbbbbbbbbbbbb000000000000000000000000000000009eee9bbb99999bbb99e99bbb9e9e9bbb
bbbbb22b00007bbbbbbb27bb00007bbbbbb2b7bb8b0fc07bbbbbbbbbbbbbbbbb0000000000000000000000000000000099999bbbe9e9ebbbeeeeebbbe999ebbb
bbbb2bb7c0c07bbbbbb2b7bbc0c07bbbbbb2b744b80ff07bbbbbbbbbbbbbbbbb000000000000000000000000000000009eee9bbb99999bbb99e99bbb99e99bbb
bbb2bbbb7ff00bbbbbb2b7bbfff00bbbbb2b7b44bb8800bbbbbbbbbbbbbbbbbb0000000000000000000000000000000099999bbb99e99bbb99e99bbb9e9e9bbb
b7b2bbbbb7ffbbbbbbb2b7bbbfffbffbbb2b7b111888888bbbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
722222222270bbbbbbb2b7bbb000bffbb2b7bb1880000bbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b7b44000007ff7bbbbb447000002011bb2b7bbbb00020bb8bbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb44111070ff1bbbbb447110020011bb27bbbb0022001bbbbbbbbbbbbbbbbbb0000000000000000000000000000000099999bbbee9eebbb99999bbb99999bbb
bbb2bbbb70200bbbbbb2b7bb00200bbbb27bbbb1200ff1bbbbbbbbbbbbbbbbbb000000000000000000000000000000009e9e9bbbe999ebbb99e99bbb9e999bbb
bbbb2bb702007bbbbbb2b7bb02007bbbb2bbbb00100ff1bbbbbbbbbbbbbbbbbb000000000000000000000000000000009eee9bbb99999bbb9eee9bbb99ee9bbb
bbbbb22b11111bbbbbbb27bb11111bbbbbbbb102011bbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000009e9e9bbbe999ebbb99e99bbb99e99bbb
bbbbbbbb02007bbbbbbbb2bb02007bbbbbbbb110007bbbbbbbbbb0088bbfc0bb0000000000000000000000000000000099999bbbee9eebbb99999bbb99999bbb
bbbbbbbb02007bbbbbbbbbbb02007bbbbbbbb11b17bbbbbbbb221200088f000b00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb11b11bbbbbbbbbbb11b11bbbbbbbbbbb11bbbbbb11001022008fc00700000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb11b11bbbbbbbbbbb11b11bbbbbbbbbbb11bbbbbb110010088888007b00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb7bbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbb0007b00000000000000000000000000000000000000000000000099999bbbe999ebbbeeeeebbbe9999bbb
bbbb7bbbb67bbbbbbbb007bbbb7bbbbbbbb2222bbbfc007b0000000000000000000000000000000000000000000000009e9e9bbb99999bbb9999ebbbe9eeebbb
bbb007bbb67bbbbbbb00007bb67bbbbbbb2222228b0fc07b0000000000000000000000000000000000000000000000009e9e9bbb99e99bbbeee9ebbbe9e9ebbb
bb00007bb66bbbbbbbc0c07bb67bbbbbbb222244b80ff07b0000000000000000000000000000000000000000000000009e9e9bbb99999bbbe999ebbbe999ebbb
bbc0c07bb67bbbbbbbfff00bb66bbbbbbb222244bb88006700000000000000000000000000000000000000000000000099999bbbe999ebbbeeeeebbbeeeeebbb
bbfff00bb66bbbbbbbb7ffbbb67bbbbbbb22221118888677000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb77fbb2222bbbbb22000bbb66bbbbbbbb222188000066b000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b22000bbbffbbbbb2200020b2222bbbbbbbbbbbb000267b8000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
220002011ffbbbbb220002011ffbbbbbbbbbbbb0022266bb00000000000000000000000000000000000000000000000099999bbb99ee9bbb99999bbb9e999bbb
2200020111bbbbbb244020011ffbbbbbbbbbbbb1200f22bb0000000000000000000000000000000000000000000000009e9e9bbb9e99ebbb99e99bbb99e99bbb
24402006677bbbbb2442000776bbbbbbbbbbbb00100ff1bb0000000000000000000000000000000000000000000000009ee99bbbe99e9bbb9e9e9bbb999e9bbb
244200065666bbbbb2211166666bbbbbbbbbb102011bbbbb0000000000000000000000000000000000000000000000009e9e9bbb9e99ebbbe999ebbb99e99bbb
b22116566666bbbbbbb17666666bbbbbbbbbb110007bbbbb00000000000000000000000000000000000000000000000099999bbb99ee9bbb99999bbb9e999bbb
bbbb665666666bbbbbbb76655656bbbbbbbbb11b17bbbbbb000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb76666666bb6bbbbb6666566666bbbbbbbbbb11bbbbbb000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb7665666b66bbbbb6666666666bbbbbbbbbb11bbbbbb000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999bbb99e99bbb99999bbb99e99bbb
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009eee9bbb99e99bbb9e9e9bbb99e99bbb
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099e99bbbe999ebbbe999ebbb9e9e9bbb
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009e9e9bbb9eee9bbb9eee9bbb99e99bbb
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999bbb99999bbb99999bbb99e99bbb
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999bbbeeeeebbbee9eebbb99999bbb
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099e99bbbe999ebbb99999bbb9eee9bbb
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009eee9bbbe9e9ebbbee9eebbb99e99bbb
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009e9e9bbbe999ebbbe999ebbb9eee9bbb
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999bbbeeeeebbbee9eebbb99999bbb
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
0505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010d00000c053150430000000000246400000000000000000c053000000000000000246450000000000000000c053150430000000000246400000000000000000c05300000000000000024645000000000000000
010d00000c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c2120c212
010d00003002230022300223002230022300223002230022320223202239022390222d5002d500320223202239022390223402234021300213002229500245003502235022350223502235022350223502235022
010d000013211132101321013210102101021010210102110e2110e2100e2100e2100e2100e2100e2100e2111c2211c2201c2201c2201c2201c2201c2201c2211121111210112101121011210112101121011211
010d00000000000000000000000000000000000000000000152101521015210152101521015210152101521111211112101121011210112101121011210112101121011210112101121011210112101121011211
010d00003002230022300223002230022300223002230022390223902234022340220000000000300223002235022350223502235022350223502235022350223002230022300223002230022300223002230022
000a00000c07318670166001560015600116000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000200512005120051200511f0511f0411e0411d0411c0411a0411904117031150311403112031100310d0210b0210901107011000000000000000000000000000000000000000000000000000000000000
00030000020610a041160312902101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001416115151171411b131221212f1113e0003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c07300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000215411f53119531145210c511035110360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000b053000000a053000000b053000000a0530b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 01 42 00 03
00 01 02 00 03
00 01 02 00 03
00 01 05 00 04
02 01 05 00 04
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
