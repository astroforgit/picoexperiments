pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--confusing prison mansion
--cedric und lea
--game jam 2018

--if gamestate == "game over" and btnp(4) then

function _init()
	gamestate  = "menu"
	sfx(3)
	levelstate = "level1"
	
	frame = 0
	shake = 0
	go_timer = 60
	gotimer = false
	
	key1state = "floor"
	key2state = "floor"
	key3state = "floor"
	key4state = "floor"
	key5state = "floor"
	key6state = "floor"
	key7state = "floor"
		
	player_x=90
	player_y=110
	player = {v  = 1,
											d  = 1, --direction
											a  = 1, --animation index
											va = 5, --animation speed
											frames = {
          											{99,100,101},
          											{115,116,117},
          											{83,84,85},
          											{67,68,69}
          										},
          	m = 0
										}
	direction = 0
										
	enemy	= {x = {70,30,26,56,56,24,24},
										y = {44,15,40,64,44,96,56},
										maxx_left = {70,55,7,33},
										maxx_right = {110,75,33,56},
										maxy_up = {0,8,40,40,45},
										maxy_down = {0,24,72,112,112},
										v  = 0.78,
										a  = 1,
										va = 5,
										sprite = 80,
										dirr = false,
										dirl = false,
										diru = false,
										dird = false,
										frame = 0,
										frames_hori = {
																									{80,81,82},
																									{64,65,66}
																								},
										frames_vert = {
																									{96,97,98},
																									{112,113,114}
																								}
									}

	lightpoint = {x = {48,8,8,112,112,32,56},
															y =	{42,24,49,9,80,112,104},
															sp = 71,
															frame = 0,
															frames = {
																									{71,87},
																									{103,119}
																								}
														}
	explosions = {}
	expoframes = 0
	explosion_pcount = 30
end

function _update()
	if gamestate == "menu" then
		update_menu()
	elseif gamestate == "instructions" then
		update_instructions()
	elseif gamestate == "game over" then
		update_game_over()
	elseif gamestate == "win" then
		update_win()
	elseif gamestate == "playing" then
	frame += 1
	game_over_max()
		if levelstate == "level1" then
			if gotimer == false then 
				move_player()
			end
  	lightpoint_animation()
  	if gotimer == false then
   	move_enemy_hori()
   end
   pick_key1()
   use_key1()
  	catch1()
  	draw_key1()
  	update_level1()
  end
 	if levelstate == "level2" then
 		if gotimer == false then 
				move_player()
			end
			lightpoint_animation()
			if gotimer == false then
 			move_enemy2_vert()
 		end
 		pick_key2()
 		use_key2()
 		catch2_up()
 		catch2_down()
 		draw_level2()
 		update_level2()
 	end
 	if levelstate == "level3" then
 		if gotimer == false then 
				move_player()
			end
 		lightpoint_animation()
 		update_map_lvl3()
 		if gotimer == false then
  		move_enemy3_vert()
  	end
   pick_key3()
   use_key3()
   catch3_up()
   catch3_down()
   update_level3()
  end
  if levelstate == "level4" then
  	if gotimer == false then 
				move_player()
			end
  	lightpoint_animation()
  	update_map_lvl4()
  	if gotimer == false then
  		move_enemy4_vert()
  	end
  	pick_key4()
  	use_key4()
  	catch4_up()
  	catch4_down()
  	update_level4()
  end
  if levelstate == "level5" then
  	if gotimer == false then 
				move_player()
			end
  	lightpoint_animation()
  	if gotimer == false then
   	move_enemy5_hori()
   end
  	pick_key5()
  	use_key5()
   catch5_left()
   catch5_right()
  	update_level5()
  end
  if levelstate == "level6" then
  	if gotimer == false then 
				move_player()
			end
  	lightpoint_animation()
  	update_map_lvl6()
  	if gotimer == false then
   	move_enemy6_hori()
   end
  	pick_key6()
  	use_key6()
  	catch6_left()
  	catch6_right()
  	update_level6()
  end
  if levelstate == "level7" then
  	if gotimer == false then 
				move_player()
			end
  	lightpoint_animation()
  	update_map_lvl7()
  	if gotimer == false then
   	move_enemy7_hori()
   end
  	pick_key7()
  	use_key7()
  	catch7_left()
  	catch7_right()
  	update_level7()
  	mset(13,7,141)
  end
  if levelstate == "level8" then
  	if gotimer == false then 
				move_player()
			end
  	use_key7()
  end
 end
 if gamestate == "win" then
 	expoframes += 1
 	firework()
 end
end

function _draw()
	cls()
	palt(10,true)
	palt(0,false)
	if gamestate == "menu" then
		draw_menu()
	elseif gamestate == "instructions" then
		draw_instructions()
	elseif gamestate == "win" then
 	draw_win()
 	draw_firework()
 elseif gamestate == "game over" then
		draw_game_over()
	elseif gamestate == "playing" then
		map()
		doshake()
		if levelstate == "level1" then
 			draw_room_1()
 	 	draw_room_2()
   	draw_room_3()
   	draw_room_4()
   	draw_room_5()
   	draw_room_6()
 		draw_ground1()
 		draw_key1_inv()
 		draw_lightpoint1()
 		draw_enemy1()
 		draw_player()
 	end
 	if levelstate == "level2" then
 			draw_room_2()
   	draw_room_3()
   	draw_room_4()
   	draw_room_5()
   	draw_room_6()
 		draw_mansion_1()
 		--draw_level2()
 		draw_lightpoint2()
 		draw_key2()
 		draw_key2_inv()
 		draw_ground2()
 		del_key2()
 		draw_enemy2()
 		draw_player()
 	end
 	if levelstate == "level3" then
 			draw_room_2()
   	draw_room_3()
   	draw_room_5()
   	draw_room_6()
 			draw_mansion_1()
 			draw_mansion_4()
 		draw_lightpoint3()
 		draw_key3()
 		draw_key3_inv()
 		draw_ground3()
 		del_key3()
 		draw_enemy3()
 		draw_player()
 		doshake()
 	end
 	if levelstate == "level4" then
 			draw_room_2()
   	draw_room_5()
   	draw_room_6()
 			draw_mansion_1()
 			draw_mansion_3()
 			draw_mansion_4()
 		draw_level4()
 		draw_lightpoint4()
 		draw_key4()
 		draw_key4_inv()
 		draw_ground4()
 		del_key4()
 		pal(1, 8)
 		draw_enemy4()
 		pal(1, 1)
 		draw_player()
 		doshake()
 	end
 	if levelstate == "level5" then
 			draw_room_2()
   	draw_room_6()
 			draw_mansion_1()
 			draw_mansion_3()
 			draw_mansion_4()
 			draw_mansion_5()
 		draw_level5()
 		draw_lightpoint5()
 		draw_key5()
 		draw_key5_inv()
 		draw_ground5()
 		del_key5()
 		draw_enemy5()
 		draw_player()
 		doshake()
 	end
 	if levelstate == "level6" then
 			draw_room_2()
 			draw_mansion_1()
 			draw_mansion_3()
 			draw_mansion_4()
 			draw_mansion_5()
 			draw_mansion_6()
 		draw_level6()
 		draw_lightpoint6()
 		draw_key6()
 		draw_key6_inv()
 		draw_ground6()
 		del_key6()
 		pal(1,8)
 		draw_enemy6()
 		pal(1,1)
 		draw_player()
 		doshake()
 	end
 	if levelstate == "level7" then
 			draw_mansion_1()
 			draw_mansion_2()
 			draw_mansion_3()
 			draw_mansion_4()
 			draw_mansion_5()
 			draw_mansion_6()
 		draw_level7()
 		draw_lightpoint7()
 		draw_key7()
 		draw_key7_inv()
 		draw_ground7()
 		del_key7()
 		draw_enemy7()
 		draw_player()
 		doshake()
 	end
 	if levelstate == "level8" then
 		--draw_level8()
 		draw_key8_inv()
 			draw_mansion_1()
 			draw_mansion_2()
 			draw_mansion_3()
 			draw_mansion_4()
 			draw_mansion_5()
 			draw_mansion_6()
 			draw_player()
 			draw_mansion_end()
 	end
 end
	
	--print(#explosions)
	--print(expoframes)
	--draw debug
	--print(gamestate,1,16,8)
	--[[print(frame,1,7,8)
	print("x: "..player_x,1,13,8)
	print("y: "..player_y,1,19,8)
	print(key1state,1,25,8)
	print(direction,1,31,8)
	print(lightpoint.frame,1,43,8)
	print(levelstate,1,49,8)]]
end
-->8
--update functions

--player movement
function move_player()
 local old_x=player_x
	local old_y=player_y
	
	if btn(‹) then
		player_x -= player.v
		player.d = 3
		player_animation()
		direction = 1
	end
	
	if btn(‘) then
		player_x += player.v
		player.d = 4
		player_animation()
		direction = 2
	end
		
	if hitwall(player_x,player_y) then
		player_x = old_x
	end
	
	if btn(”) then
		player_y -= player.v
		player.d = 2
		player_animation()
		direction = 3
	end
	
	if btn(ƒ) then
		player_y += player.v
		player.d = 1
		player_animation()
		direction = 4
	end

	if hitwall(player_x,player_y) then
		player_y = old_y
	end
	
	if btn(‹) and btn(ƒ) then
		direction = 5
	end
	if btn(‘) and btn(ƒ) then
		direction = 6
	end
	if btn(‹) and btn(”) then
		direction = 7
	end
	if btn(‘) and btn(”) then
		direction = 8
	end
end

function player_animation()
	if frame%player.va == 0 then
  player.a += 1
  if player.a > #player.frames[player.d] then
   player.a -= #player.frames[player.d]
  end
 end
end

function hitwall(_x,_y)
	if (checkspot(_x+1,_y  ,0)) return true
 if (checkspot(_x+6,_y  ,0)) return true
 if (checkspot(_x+1,_y+7,0)) return true
 if (checkspot(_x+6,_y+7,0)) return true
 return false
end

function checkspot(_x,_y,_flag)
	local tilex=_x/8
	local tiley=_y/8
	
 local tile=mget(tilex,tiley)
 
 return fget(tile,_flag)
end

--level 1
function pick_key1()
	if btnp(4) and player_x >= 108 and player_x <= 113 and player_y == 104
 and key1state == "floor" and direction == 3
 or btnp(4) and player_y >= 96 and player_y <= 102 and player_x == 105 and key1state == "floor" 
 and direction == 2 then
 	key1state = "inventar"
 	sfx(1)
	end
end

function use_key1()
	if btnp(5) and player_x == 79
	and player_y >= 101 and player_y <= 108
 and key1state == "inventar" then
		key1state = "benutzt"
		mset(9,13,1)
		mset(9,14,21)
		sfx(6)
	end
end

--level 2
function pick_key2()
	if btnp(4) and player_x >= 7 and player_x <= 11
	and player_y == 88
	and key2state == "floor" and direction == 4
	or btnp(4) and player_y >= 92 and player_y <= 98
	and player_x == 15 
	and key2state == "floor" and direction == 1 then
		key2state = "inventar"
		sfx(1)
	end
end

function use_key2()
	if btnp(5) and player_y == 40
	and player_x <= 58 and player_x >= 52
	and key2state == "inventar" then
 	key2state = "benutzt"
		mset(7,4,1)
		mset(6,4,19)
		sfx(6)
	end
end

--level 3
function pick_key3()
	if btnp(4) and player_y == 72 and player_x >= 79 and player_x <= 83
 and direction == 4 and key3state == "floor"
 or btnp(4) and player_x == 87 and player_y >= 75 and player_y <= 80
 and direction == 1 and key3state == "floor" then
 	key3state = "inventar"
 	sfx(1)
	end
end

function use_key3()
	if btnp(5) and player_x == 47
	and player_y <= 60 and player_y >= 52
 and key3state == "inventar" then
		key3state = "benutzt"
		mset(5,7,1)
		mset(5,8,21)
		sfx(6)
	end
end

--level 4
function pick_key4()
	if btnp(4) and player_x == 87
	and player_y >= 96 and player_y <= 100
	and direction == 1 and key4state == "floor"
	or btnp(4) and player_y == 104
	and player_x >= 78 and player_x <= 82
	and direction == 3 and key4state == "floor" then
		key4state = "inventar"
		sfx(1)
	end
end

function use_key4()
	if btnp(5) and player_y == 40
	and player_x >= 77 and player_x <= 83
	and key4state == "inventar" then
		key4state = "benutzt"
		mset(10,4,1)
		mset(9,4,19)
		sfx(6)
	end
end

--level 5
function pick_key5()
	if btnp(4) and player_x == 15
	and player_y <= 24 and player_y >= 20
	and direction == 1 and key5state == "floor"
	or btnp(4) and player_y == 16
	and player_x <= 11 and player_x >= 7
	and direction == 4 and key5state == "floor" then
		key5state = "inventar"
		sfx(1)
	end
end

function use_key5()
	if btnp(5) and player_x == 65
	and player_y <= 75 and player_y >= 69
	and key5state == "inventar" then
		key5state = "benutzt"
		mset(9,9,1)
		mset(9,10,21)
		sfx(6)
	end
end

--level 6
function pick_key6()
	if btnp(4) and player_y == 64
	and player_x >= 29 and player_x <=33
	and direction == 4 and key6state == "floor"
	or btnp(4) and player_x == 25
	and player_y <= 72 and player_y >= 67
	and direction == 2 and key6state == "floor" then
		key6state = "inventar"
		sfx(1)
	end
end

function use_key6()
	if btnp(5) and player_x == 47
	and player_y <= 99 and player_y >= 91
	and key6state == "inventar" then
		key6state = "benutzt"
		mset(5,12,1)
		mset(5,13,21)
		sfx(6)
	end
end

--level 7
function pick_key7()
	if btnp(4) and player_x == 105
	and player_y >= 8 and player_y <= 12
	and direction == 2 and key7state == "floor"
	or btnp(4) and player_y == 16
	and player_x <= 113 and player_x >= 109
 and direction == 3 and key7state == "floor" then
		key7state = "inventar"
		sfx(1)
	end
end

--level 8
function use_key7()
	if btnp(5) and player_y == 112
	and player_x <= 65 and player_x >= 47 then
		sfx(6)
		gamestate = "win"
	end
end

--enemy functions

--horizontale bewegung
function move_enemy_hori()
	enemy.frame += 1
	enemy.x[1] -= enemy.v	
	if enemy.x[1] <= enemy.maxx_left[1] then
		enemy.v = -0.78
	elseif enemy.x[1] >= enemy.maxx_right[1] then
		enemy.v = 0.78
	end
 if enemy.v == 0.78 then
		enemy_animation_left()
	end
	if enemy.v == -0.78 then
		enemy_animation_right()
	end
end

function enemy_animation_left()
	if enemy.frame >= 5  then
		enemy.sprite = enemy.frames_hori[1][3]
	else
		enemy.sprite = enemy.frames_hori[1][2]
	end

	if enemy.frame >= 10 then
	 enemy.frame = 0
	end
	enemy.dirl = true
	enemy.dirr = false
end

function enemy_animation_right()
	if enemy.frame >= 5  then
		enemy.sprite = enemy.frames_hori[2][3]
	else
		enemy.sprite = enemy.frames_hori[2][2]
	end
	
	if enemy.frame >= 10 then
	 enemy.frame = 0
	end
	enemy.dirr = true
	enemy.dirl = false
end

--vertikale bewegung
function move_enemy2_vert()
	enemy.frame += 1
		enemy.y[2] -= enemy.v
		if enemy.y[2] <= enemy.maxy_up[2] then
			enemy.v = -0.78
		elseif enemy.y[2] >= enemy.maxy_down[2] then
			enemy.v = 0.78
		end
	if enemy.v == 0.78 then
		enemy_animation_up()
	end
	if enemy.v == -0.78 then
		enemy_animation_down()
	end
end

function enemy_animation_down()
	if enemy.frame >= 5  then
		enemy.sprite = enemy.frames_vert[1][3]
	else
		enemy.sprite = enemy.frames_vert[1][2]
	end

	if enemy.frame >= 10 then
	 enemy.frame = 0
	end
	enemy.diru = false
	enemy.dird = true
end

function enemy_animation_up()
	if enemy.frame >= 5  then
		enemy.sprite = enemy.frames_vert[2][3]
	else
		enemy.sprite = enemy.frames_vert[2][2]
	end

	if enemy.frame >= 10 then
	 enemy.frame = 0
	end
	enemy.diru = true
	enemy.dird = false
end

--den spieler erwischen
--level 1
function catch1()
	if player_y <= 51 and player_y >= 40 
	and enemy.dirl == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

function game_over_max()
	if gotimer == true then
		go_timer -= 1
		shake += 1
		if go_timer <= 0 then
			go_timer = 60
			gamestate = "game over"
			shake = 0
			gotimer = false
		end
	end 
end

--level 2
function catch2_up()
	if player_x <= 35 and player_x >= 25
	and player_y <= enemy.y[2] 
	and enemy.diru == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

function catch2_down()
	if player_x <= 35 and player_x >= 25
	and player_y <= 24 and player_y >= 8
	and player_y >= enemy.y[2] 
	and enemy.dird == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

--level 3
function move_enemy3_vert()
	enemy.frame += 1
		enemy.y[3] -= enemy.v
		if enemy.y[3] <= enemy.maxy_up[3] then
			enemy.v = -0.78
		elseif enemy.y[3] >= enemy.maxy_down[3] then
			enemy.v = 0.78
		end
	if enemy.v == 0.78 then
		enemy_animation_up()
	end
	if enemy.v == -0.78 then
		enemy_animation_down()
	end
end

function catch3_up()
	if player_x <= 31 and player_x >= 21
	and player_y <= 72 and player_y >= 40
	and player_y <= enemy.y[3] 
	and enemy.diru == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

function catch3_down()
	if player_x <= 31 and player_x >= 21
	and player_y <= 72 and player_y >= 40
	and player_y >= enemy.y[3] 
	and enemy.dird == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

--level 4
function move_enemy4_vert()
	enemy.frame += 1
		enemy.y[4] -= enemy.v
		if enemy.y[4] <= enemy.maxy_up[4] then
			enemy.v = -0.70
		elseif enemy.y[4] >= enemy.maxy_down[4] then
			enemy.v = 0.70
		end
	if enemy.v == 0.70 then
		enemy_animation_up()
	end
	if enemy.v == -0.70 then
		enemy_animation_down()
	end
end

function catch4_up()
	if player_x <= 70 and player_x >= 42
	and player_y <= 112 and player_y >= 40
	and player_y <= enemy.y[4] 
	and enemy.diru == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

function catch4_down()
	if player_x <= 70 and player_x >= 42
	and player_y <= 112 and player_y >= 40
	and player_y >= enemy.y[4] 
	and enemy.dird == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

--level 5
function move_enemy5_hori()
	enemy.frame += 1
	enemy.x[5] -= enemy.v	
	if enemy.x[5] <= enemy.maxx_left[2] then
		enemy.v = -0.78
	elseif enemy.x[5] >= enemy.maxx_right[2] then
		enemy.v = 0.78
	end
 if enemy.v == 0.78 then
		enemy_animation_left()
	end
	if enemy.v == -0.78 then
		enemy_animation_right()
	end
end

function catch5_left()
	if player_x <= 112 and player_x >= 47
	and player_y <= 51 and player_y >= 37
	and player_x <= enemy.x[5]
	and enemy.dirl == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

function catch5_right()
	if player_x <= 112 and player_x >= 47
	and player_y <= 51 and player_y >= 37
	and player_x >= enemy.x[5]
	and enemy.dirr == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

--level 6
function move_enemy6_hori()
	enemy.frame += 1
	enemy.x[6] -= enemy.v	
	if enemy.x[6] <= enemy.maxx_left[3] then
		enemy.v = -0.6
	elseif enemy.x[6] >= enemy.maxx_right[3] then
		enemy.v = 0.6
	end
 if enemy.v == 0.6 then
		enemy_animation_left()
	end
	if enemy.v == -0.6 then
		enemy_animation_right()
	end
end

function catch6_left()
	if player_x <= 65 and player_x >= 7
	and player_y <= 103 and player_y >= 89
	and player_x <= enemy.x[6]
	and enemy.dirl == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

function catch6_right()
	if player_x <= 65 and player_x >= 7
	and player_y <= 103 and player_y >= 89
	and player_x >= enemy.x[6]
	and enemy.dirr == true and key6state == "benutzt" then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

--level 7
function move_enemy7_hori()
	enemy.frame += 1
	enemy.x[7] -= enemy.v	
	if enemy.x[7] <= enemy.maxx_left[4] then
		enemy.v = -0.78
	elseif enemy.x[7] >= enemy.maxx_right[4] then
		enemy.v = 0.78
	end
 if enemy.v == 0.78 then
		enemy_animation_left()
	end
	if enemy.v == -0.78 then
		enemy_animation_right()
	end
end

function catch7_left()
	if player_x <= 56 and player_x >= 33
	and player_y <= 63 and player_y >= 49
	and player_x <= enemy.x[7]
	and enemy.dirl == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

function catch7_right()
	if player_x <= 65 and player_x >= 33
	and player_y <= 63 and player_y >= 49
	and player_x >= enemy.x[7]
	and enemy.dirr == true then
		sfx(2)
		music(-1)
		gotimer = true
	end
end

--animation der lichtpunkte 
function lightpoint_animation()
	lightpoint.frame += 1
	if lightpoint.frame <= 15 then
		lightpoint.sp = lightpoint.frames[1][1]
	else
		lightpoint.sp = lightpoint.frames[1][2]
	end
	if lightpoint.frame >= 30 and lightpoint.frame <= 45 then
		lightpoint.sp = lightpoint.frames[2][1]
	elseif lightpoint.frame >= 45 then
		lightpoint.sp = lightpoint.frames[2][2]
	end
	if lightpoint.frame >= 60 then
		lightpoint.frame = 0
	end
end

--update gamestates
function update_menu()
	if btnp(5) and gamestate == "menu" then
		gamestate = "playing"
		sfx(-1)
		music(1)
	end
	if btnp(4) then
		gamestate = "instructions"
	end
end

function update_instructions()
	if btnp(5) and gamestate == "instructions" then
		gamestate = "playing"
		sfx(-1)
		music(1)
	end
	if btnp(4) and gamestate == "instructions" then
		gamestate = "menu"
	end
end

function update_win()
	if gamestate == "win" then
		if btnp(5) then
			_init()
		end
	end
end

function update_game_over()
	if gamestate == "game over" then
		if btnp(5) then
			_init()
			mset(11,19,23)
			mset(5,14,23)
			mset(13,4,25)
			mset(13,7,25)
			mset(7,4,18)
			mset(10,4,18)
			mset(9,13,20)
			mset(5,12,20)
			mset(9,9,20)
			mset(5,7,20)
			mset(0,1,3)
			mset(0,2,3)
			mset(0,3,3)
			mset(0,4,3)
			mset(0,5,3)
			mset(0,6,3)
			mset(0,7,3)
			mset(0,8,3)
			mset(0,9,3)
			mset(0,11,3)
			mset(0,12,3)
			mset(0,13,3)
			mset(0,14,3)
			mset(8,1,3)
			mset(8,2,3)
			mset(8,3,3)
			mset(5,5,3)
			mset(5,6,3)
			mset(5,8,3)
			mset(5,10,3)
			mset(5,11,3)
			mset(5,13,3)
			mset(15,0,3)
			mset(15,1,3)
			mset(15,2,3)
			mset(15,3,3)
			mset(15,4,3)
			mset(15,5,3)
			mset(15,6,3)
			mset(15,7,3)
			mset(15,8,3)
			mset(15,9,3)
			mset(15,10,3)
			mset(15,11,3)
			mset(15,12,3)
			mset(15,13,3)
			mset(9,14,3)
			mset(9,12,3)
			mset(9,10,3)
			mset(9,8,3)
			mset(0,0,4)
			mset(8,0,4)
			mset(5,4,4)
			mset(9,7,4)
			mset(0,10,4)
			mset(9,11,4)
			mset(1,0,2)
			mset(2,0,2)
			mset(3,0,2)
			mset(4,0,2)
			mset(5,0,2)
			mset(6,0,2)
			mset(7,0,2)
			mset(9,0,2)
			mset(10,0,2)
			mset(11,0,2)
			mset(12,0,2)
			mset(13,0,2)
			mset(14,0,2)
			mset(1,4,2)
			mset(2,4,2)
			mset(3,4,2)
			mset(4,4,2)
			mset(6,4,2)
			mset(8,4,2)
			mset(9,4,2)
			mset(11,4,2)
			mset(12,4,2)
			mset(14,4,2)
			mset(1,10,2)
			mset(2,10,2)
			mset(3,10,2)
			mset(4,10,2)
			mset(10,7,2)
			mset(11,7,2)
			mset(12,7,2)
			mset(14,7,2)
			mset(10,11,2)
			mset(11,11,2)
			mset(12,11,2)
			mset(13,11,2)
			mset(14,11,2)
			mset(0,15,2)
			mset(1,15,2)
			mset(2,15,2)
			mset(3,15,2)
			mset(4,15,2)
			mset(5,15,2)
			mset(6,15,2)
			mset(7,15,2)
			mset(8,15,2)
			mset(9,15,2)
			mset(10,15,2)
			mset(11,15,2)
			mset(12,15,2)
			mset(13,15,2)
			mset(1,1,1)
			mset(1,2,1)
			mset(1,3,1)
			mset(2,1,1)
			mset(2,2,1)
			mset(2,3,1)
			mset(3,1,1)
			mset(3,2,1)
			mset(3,3,1)
			mset(4,1,1)
			mset(4,2,1)
			mset(4,3,1)
			mset(5,1,1)
			mset(5,2,1)
			mset(5,3,1)
			mset(6,1,1)
			mset(6,2,1)
			mset(6,3,1)
			mset(7,1,1)
			mset(7,2,1)
			mset(7,3,1)
			mset(9,1,1)
			mset(9,2,1)
			mset(9,3,1)
			mset(10,1,1)
			mset(10,2,1)
			mset(10,3,1)
			mset(11,1,1)
			mset(11,2,1)
			mset(11,3,1)
			mset(12,1,1)
			mset(12,2,1)
			mset(12,3,1)
			mset(13,1,1)
			mset(13,2,1)
			mset(13,3,1)
			mset(14,1,1)
			mset(14,2,1)
			mset(14,3,1)
			mset(1,5,1)
			mset(1,6,1)
			mset(1,7,1)
			mset(1,8,1)
			mset(1,9,1)
			mset(2,5,1)
			mset(2,6,1)
			mset(2,7,1)
			mset(2,8,1)
			mset(2,9,1)
			mset(3,5,1)
			mset(3,6,1)
			mset(3,7,1)
			mset(3,8,1)
			mset(3,9,1)
			mset(4,5,1)
			mset(4,6,1)
			mset(4,7,1)
			mset(4,8,1)
			mset(4,9,1)
			mset(3,2,1)
			mset(3,3,1)
			mset(4,1,1)
			mset(4,2,1)
			mset(4,3,1)
			mset(1,11,1)
			mset(1,12,1)
			mset(1,13,1)
			mset(1,14,1)
			mset(2,11,1)
			mset(2,12,1)
			mset(2,13,1)
			mset(2,14,1)
			mset(3,11,1)
			mset(3,12,1)
			mset(3,13,1)
			mset(3,14,1)
			mset(4,11,1)
			mset(4,12,1)
			mset(4,13,1)
			mset(4,14,1)
			mset(10,12,1)
			mset(10,13,1)
			mset(11,12,1)
			mset(11,13,1)
			mset(12,12,1)
			mset(12,13,1)
			mset(13,12,1)
			mset(13,13,1)
			mset(14,12,1)
			mset(14,13,1)
			mset(10,14,1)
			mset(11,14,1)
			mset(12,14,1)
			mset(13,14,1)
			mset(10,8,1)
			mset(10,9,1)
			mset(10,10,1)
			mset(11,8,1)
			mset(11,9,1)
			mset(11,10,1)
			mset(12,8,1)
			mset(12,9,1)
			mset(12,10,1)
			mset(13,8,1)
			mset(13,9,1)
			mset(13,10,1)
			mset(14,8,1)
			mset(14,9,1)
			mset(14,10,1)
			mset(6,5,1)
			mset(6,6,1)
			mset(7,5,1)
			mset(7,6,1)
			mset(8,5,1)
			mset(8,6,1)
			mset(9,5,1)
			mset(9,6,1)
			mset(10,5,1)
			mset(10,6,1)
			mset(11,5,1)
			mset(11,6,1)
			mset(12,5,1)
			mset(12,6,1)
			mset(13,5,1)
			mset(13,6,1)
			mset(14,5,1)
			mset(14,6,1)
			mset(6,7,1)
			mset(7,7,1)
			mset(8,7,1)
			mset(6,8,1)
			mset(7,8,1)
			mset(8,8,1)
			mset(6,9,1)
			mset(7,9,1)
			mset(8,9,1)
			mset(6,10,1)
			mset(7,10,1)
			mset(8,10,1)
			mset(6,11,1)
			mset(7,11,1)
			mset(8,11,1)
			mset(6,12,1)
			mset(7,12,1)
			mset(8,12,1)
			mset(6,13,1)
			mset(7,13,1)
			mset(8,13,1)
			mset(6,14,1)
			mset(7,14,1)
			mset(8,14,1)
			--mset(9,13,20)
  	--mset(9,14,3)
  	--mset(14,12,86)
  	fset(86,0,true)
		end
	end
end

--update levelstates
function update_level1()
	if player_x >= 47 and player_x <= 49 
	and player_y == 40 then
		levelstate = "level2"
	end
end

function update_level2()
	if player_x <= 9 and player_x >= 7 
	and player_y <= 24 and player_y >= 22 then
		levelstate = "level3"
	end
end

function update_level3()
	if player_y == 48
	and player_x >= 7 and player_x <= 9 then
		levelstate = "level4"
	end
end

function update_level4()
	if player_y == 8 
	and player_x >= 111 and player_x <= 113 then
		levelstate = "level5"
	end
end

function update_level5()
	if player_x <= 113 and player_x >= 110
 and	player_y <= 80 and player_y >= 78 then
		levelstate = "level6"
	end
end

function update_level6()
	if player_x <= 33 and player_x >= 31
	and player_y <= 112 and player_y >= 109 then
		levelstate = "level7"
	end
end

function update_level7()
	if player_x <= 57 and player_x >= 54
	and player_y == 102 and key7state == "inventar" then
		levelstate = "level8"
	end
end

--map updates

--level 3

function update_map_lvl3()
	mset(4,1,1)
	mset(4,2,1)
	mset(13,7,26)
	mset(5,14,23)
end

function update_map_lvl4()
	mset(2,9,1)
	mset(5,14,23)
	mset(14,3,79)
end

function update_map_lvl6()
	mset(13,7,141)
end

function update_map_lvl7()
	mset(4,13,1)
	mset(1,13,1)
	mset(1,14,1)
end

function firework()
	if expoframes%5 < 1 then
 		add_explosion(rnd(128), rnd(128))
 	end
 	for e in all(explosions) do
  e.t += 1
  for p in all(e.particles) do
   if e.t < 30 then
    p.x += p.vx
    p.y += p.vy
   else
    p.x -= p.vx * 2
    p.y -= p.vy * 2
   end
   if p.x < 0 or p.x > 128
   or p.y < 0 or p.y > 128
   --or ((p.x > e.x - 2 and p.x < e.x + 2)
   --and (p.y > e.y - 2 and p.y < e.y + 2))
   then
    del(e.particles, p)
   end
  end
  if #e.particles == 0 then
   del(explosions, e)
  end
 end
end

function add_explosion(_x, _y)
 local e = {
  x = _x,
  y = _y,
  particles = {},
  t = 0
 }
 
 for i=0, explosion_pcount do
  local p = {
   x  = _x,
   y  = _y,
   vx = rnd(8) - 4,
   vy = rnd(8) - 4,
   c  = 8
  }

  add(e.particles, p)
 end
 
 add(explosions, e)
end
-->8
--draw functions

--draws zu allen levels
function draw_menu()
	spr(128,40,40,7,5)
	print("press x to start the game",15,85,6)
	print("press c for instructions",15,95,6)
end

function draw_game_over()
	--cls()
	spr(203,50,45,4,4)
	print("press x to return to the menu",7,80,15)
end

function doshake()
	local shakex = rnd(1)
 local shakey = rnd(1)
 shakex *= shake
 shakey *= shake
 camera(shakex,shakey)
 shake = shake*0.5
 if shake < 0.05 then
 	shake=0
 end
end

function draw_instructions()
	--cls()
	print("press c to pick up a key",15,10,13)
	print("press x to unlock a door",15,20,6)
	print("you can move with the arrows",10,30,14)
	print("press c to return to the menu",8,100,15)
	print("press x to start the game",15,110,15)
end

function draw_win()
	cls()
	spr(199,50,45,4,4)
	print("press x to return to the menu",7,80,15)
end

function draw_player()
	spr(player.frames[player.d][player.a],
					player_x,player_y)
end


--alle draws zu level 1
function draw_enemy1()
		spr(enemy.sprite,
						enemy.x[1],enemy.y[1])
end

function draw_lightpoint1()
		spr(lightpoint.sp,
						lightpoint.x[1],
						lightpoint.y[1])
end

function draw_key1()
	if key1state == "floor" and levelstate == "level1" then
		mset(14,12,86)
	end
end

function draw_key1_inv() --malt key in inventar
	if key1state == "inventar" then
		spr(70,117,116)
	end
end

function draw_ground1() --ersetzt key durch boden
	if key1state == "inventar" or key1state == "benutzt" then
		spr(1,112,96)
		fset(86,0,false)
	end
end

function del_key1() --malt key aus inventar raus 
	if key1state == "benutzt" then
		spr(17,117,116)
	end
end


--alle draws zu level 2
function	draw_level2()
	mset(5,14,24)
	mset(14,12,1)
	mset(9,13,1)
	mset(9,14,21)
end

function draw_enemy2()
	spr(enemy.sprite,
					enemy.x[2],enemy.y[2])
end

function draw_lightpoint2()
		spr(lightpoint.sp,
						lightpoint.x[2],
						lightpoint.y[2])
end

function draw_key2() --malt key auf den boden
	if key2state == "floor" and levelstate == "level2" then
		mset(1,12,86)
		fset(86,0,true)
	end
end

function draw_key2_inv() --malt key in inventar
	if key2state == "inventar" then
		spr(70,117,116)
	end
end

function draw_ground2() --ersetzt key durch boden
	if key2state == "inventar" or key2state == "benutzt" then
		mset(1,12,1)
		fset(86,0,false)
	end
end

function del_key2() --malt key aus inventar raus 
	if key2state == "benutzt" then
		spr(17,117,116)
	end
end


--alle draws zu level 3
function draw_enemy3()
	spr(enemy.sprite,
					enemy.x[3],enemy.y[3])
end

function draw_lightpoint3()
		spr(lightpoint.sp,
						lightpoint.x[3],
						lightpoint.y[3])
end

function draw_key3() --malt key auf den boden
	if key3state == "floor" and levelstate == "level3" then
		mset(10,10,86)
		fset(86,0,true)
	end
end

function draw_key3_inv() --malt key in inventar
	if key3state == "inventar" then
		spr(70,117,116)
	end
end

function draw_ground3() --ersetzt key durch boden
	if key3state == "inventar" or key3state == "benutzt" then
		mset(10,10,1)
		fset(86,0,false)
	end
end

function del_key3() --malt key aus inventar raus 
	if key3state == "benutzt" then
		spr(17,117,116)
	end
end


--alle draws zu level 4
function	draw_level4()
	mset(7,4,1)
	mset(6,4,19)
	mset(13,7,25)
	mset(5,8,21)
	mset(5,7,1)
	mset(9,13,1)
	mset(9,14,21)
end

function draw_enemy4()
	spr(enemy.sprite,
					enemy.x[4],enemy.y[4])
end

function draw_lightpoint4()
		spr(lightpoint.sp,
						lightpoint.x[4],
						lightpoint.y[4])
end

function draw_key4() --malt key auf den boden
	if key4state == "floor" and levelstate == "level4" then
		mset(10,12,86)
		fset(86,0,true)
	end
end

function draw_key4_inv() --malt key in inventar
	if key4state == "inventar" then
		spr(70,117,116)
	end
end

function draw_ground4() --ersetzt key durch boden
	if key4state == "inventar" or key4state == "benutzt" then
		mset(10,12,1)
		fset(86,0,false)
	end
end

function del_key4() --malt key aus inventar raus 
	if key4state == "benutzt" then
		spr(17,117,116)
	end
end


--alle draws zu level 5
function	draw_level5()
	mset(7,4,1)
	mset(6,4,19)
	mset(13,7,25)
	mset(5,8,21)
	mset(5,7,1)
	mset(9,13,1)
	mset(9,14,21)
	mset(10,12,1)
end

function draw_enemy5()
	spr(enemy.sprite,
					enemy.x[5],enemy.y[5])
end

function draw_lightpoint5()
		spr(lightpoint.sp,
						lightpoint.x[5],
						lightpoint.y[5])
end

function draw_key5() --malt key auf den boden
	if key5state == "floor" and levelstate == "level5" then
		mset(1,3,86)
		fset(86,0,true)
	end
end

function draw_key5_inv() --malt key in inventar
	if key5state == "inventar" then
		spr(70,117,116)
	end
end

function draw_ground5() --ersetzt key durch boden
	if key5state == "inventar" or key5state == "benutzt" then
		mset(1,3,1)
		fset(86,0,false)
	end
end

function del_key5() --malt key aus inventar raus 
	if key5state == "benutzt" then
		spr(17,117,116)
	end
end

--alle draws zu level 6
function	draw_level6()
	mset(7,4,1)
	mset(6,4,19)
	mset(13,7,25)
	mset(5,8,21)
	mset(5,7,1)
	mset(9,13,1)
	mset(9,14,21)
	mset(10,12,1)
	mset(10,4,1)
	mset(9,4,19)
	mset(9,9,1)
	mset(9,10,21)
end

function draw_enemy6()
	spr(enemy.sprite,
					enemy.x[6],enemy.y[6])
end

function draw_lightpoint6()
		spr(lightpoint.sp,
						lightpoint.x[6],
						lightpoint.y[6])
end

function draw_key6() --malt key auf den boden
	if key6state == "floor" and levelstate == "level6" then
		mset(4,9,86)
		fset(86,0,true)
	end
end

function draw_key6_inv() --malt key in inventar
	if key6state == "inventar" then
		spr(70,117,116)
	end
end

function draw_ground6() --ersetzt key durch boden
	if key6state == "inventar" or key6state == "benutzt" then
		mset(4,9,1)
		fset(86,0,false)
	end
end

function del_key6() --malt key aus inventar raus 
	if key6state == "benutzt" then
		spr(17,117,116)
	end
end

--alle draws zu level 7
function	draw_level7()
	mset(7,4,1)
	mset(6,4,19)
	mset(13,7,25)
	mset(5,8,21)
	mset(5,7,1)
	mset(9,13,1)
	mset(9,14,21)
	mset(10,12,1)
	mset(10,4,1)
	mset(9,4,19)
	mset(9,9,1)
	mset(9,10,21)
	mset(5,12,1)
	mset(5,13,21)
end

function draw_enemy7()
	spr(enemy.sprite,
					enemy.x[7],enemy.y[7])
end

function draw_lightpoint7()
		spr(lightpoint.sp,
						lightpoint.x[7],
						lightpoint.y[7])
end

function draw_key7() --malt key auf den boden
	if key7state == "floor" and levelstate == "level7" then
		mset(14,1,86)
		fset(86,0,true)
	end
end

function draw_key7_inv() --malt key in inventar
	if key7state == "inventar" then
		spr(70,117,116)
	end
end

function draw_ground7() --ersetzt key durch boden
	if key7state == "inventar" or key7state == "benutzt" then
		mset(14,1,1)
		fset(86,0,false)
	end
end

function del_key7() --malt key aus inventar raus 
	if key7state == "benutzt" then
		spr(17,117,116)
	end
end

--alle draws zu level 8
function	draw_level8()
	mset(7,4,1)
	mset(6,4,19)
	mset(13,7,25)
	mset(5,8,21)
	mset(5,7,1)
	mset(9,13,1)
	mset(9,14,21)
	mset(10,12,1)
	mset(10,4,1)
	mset(9,4,19)
	mset(9,9,1)
	mset(9,10,21)
	mset(5,12,1)
	mset(5,13,21)
end

function draw_key8_inv() --malt key in inventar
	if key7state == "inventar" then
		spr(70,117,116)
	end
end

function del_key8() --malt key aus inventar raus 
	if key7state == "benutzt" then
		spr(17,117,116)
	end
end

function draw_firework()
	if expoframes%30 < 15 then
  pal(8,7)
 end
 	for e in all(explosions) do
  	for p in all(e.particles) do
   	pset(p.x, p.y, p.c)
  	end
 	end
 pal()
end
-->8
--checkliste

--[[
	spielermovement 
		+ animation 
		+ collision 
	enemymovement 
		+ animation 
	respawn polizist 
		+ animation 
	key 
		+respawn key 
		+pick up 
	doors 
		+ animation 
		+ funktion 
	inventar 
	lichtpunkte
		+ animation  
	 + respawn  
	states 
]]
-->8
--draw rooms

function draw_room_1()
 mset(13,13,75)
 mset(13,14,91)
 --spr(75,104,104)
 --spr(91,104,112)
 spr(76,80,92)
 spr(92,88,92)
end

function draw_room_2()
 spr(92,16,84)
 spr(76,8,84)
 spr(77,24,80)
 spr(78,32,80)
 spr(93,24,88)
 spr(94,32,88)
 --spr(75,8,104)
 --spr(91,8,112)
 mset(1,13,75)
 mset(1,14,91)
 --spr(79,32,104)
 mset(4,13,79)
end

function draw_room_3()
 --spr(75,8,36)
 --spr(91,8,44)
 mset(1,4,38)
 mset(1,5,54)
 mset(1,6,39)
 spr(76,32,36)
 spr(92,24,36)
 --spr(95,16,72)
 mset(2,9,95)
end

function draw_room_4()
 --spr(95,16,24)
 mset(2,3,95)
 spr(76,8,4)
 spr(92,16,4)
 --spr(75,30,4)
 --spr(91,30,12)
 --spr(75,56,4)
 --spr(91,56,12)
 mset(7,0,38)
 mset(7,1,54)
 mset(7,2,39)
 mset(4,0,38)
 mset(4,1,54)
 mset(4,2,39)
 spr(77,40,0)
 spr(78,48,0)
 spr(93,40,8)
 spr(94,48,8)
end

function draw_room_5()
 spr(76,112,4)
 spr(92,104,4)
 spr(77,72,0)
 spr(78,80,0)
 spr(93,72,8)
 spr(94,80,8)
 --spr(75,89,4)
 --spr(91,89,12)
 mset(11,0,38)
 mset(11,1,54)
 mset(11,2,39)
 spr(79,112,24)
end

function draw_room_6()
 --spr(75,112,60)
 --spr(91,112,68)
 mset(14,7,38)
 mset(14,8,54)
 mset(14,9,39)
 spr(76,80,60)
 spr(92,88,60)
 --spr(95,88,80)
 mset(11,10,95)
end

function draw_mansion_1()
 spr(9,80,88)
 --spr(9,88,88)
 --spr(9,96,88)
 spr(9,104,88)
 spr(9,112,88) 
 spr(11,72,88) 
 spr(10,72,96)
 spr(30,72,112)
 spr(1,72,104)
 spr(10,120,96)
 spr(10,120,104)
 spr(10,120,88)
 spr(9,104,120)
 spr(9,96,120)
 spr(9,88,120)
 spr(9,80,120)
 spr(9,72,120)
 --das bett weg
 mset(13,13,1)
 mset(13,14,1)
 --moeabel
 --spr(107,112,104)
 mset(14,13,107)
 --spr(105,88,92)
 --spr(106,96,92)
 --spr(121,88,100)
 --spr(122,96,100)
 mset(11,11,141)
 mset(12,11,142)
 mset(11,12,157)
 mset(12,12,158)
 mset(11,13,173)
 mset(12,13,174)
 spr(108,88,110)
 spr(109,96,110)
 spr(124,104,89)
end

function draw_mansion_2()
 spr(9,8,80)
 spr(9,16,80)
 spr(9,24,80)
 spr(9,32,80)
 spr(11,0,80)
 spr(9,0,120)
 spr(9,8,120)
 spr(9,16,120)
 spr(9,24,120)
 spr(9,32,120)
 spr(9,40,120)
 spr(10,0,88)
 spr(10,0,96)
 spr(10,0,104)
 spr(10,0,112)
 spr(10,40,80)
 spr(10,40,88)
 spr(10,40,112)
 spr(30,40,104)
 spr(1,40,96)
 --moebel
 spr(108,10,97)--t
 spr(109,18,97)--t
 --spr(105,16,104)--bett
 --spr(106,24,104)
 --spr(121,16,112)
 --spr(122,24,112)--
 mset(3,14,123)
 spr(110,24,80)--schrank
 spr(111,32,80)
 spr(126,24,88)
 spr(127,32,88)--
 --spr(107,16,87)
 mset(2,11,107)
 spr(125,10,81)

 end

function draw_mansion_3()
 spr(1,40,56)
 spr(10,40,72)
 spr(10,40,48)
 spr(10,40,40)
 spr(11,40,32)
 spr(10,0,40)
 spr(10,0,48)
 spr(10,0,56)
 spr(10,0,64)
 spr(10,0,72)
 spr(11,0,32)
 --spr(9,8,32)
 --spr(9,16,32)
 spr(9,24,32)
 spr(9,32,32)
 spr(30,40,64)
 --moebel
 spr(108,16,56)--t
 spr(109,24,56)--t
 --spr(105,8,36)--bett
 --spr(106,16,36)
 --spr(121,8,44)
 --spr(122,16,44)--
 mset(1,4,141)
 mset(2,4,142)
 mset(1,5,157)
 mset(2,5,158)
 mset(1,6,173)
 mset(2,6,174)
 --spr(107,32,48)
 mset(4,6,107)
 --spr(123,24,72)
 mset(3,9,123)
 spr(124,28,33)
end

function draw_mansion_4()
 --spr(9,8,0)
 --spr(9,16,0)
 spr(9,24,0)
 spr(9,32,0)
 spr(9,40,0)
 --spr(9,48,0)
 --spr(9,56,0)
 spr(11,0,0)
 spr(10,0,8)
 spr(10,0,16)
 spr(10,0,24)
 spr(28,48,32)
 spr(1,56,32)
 --moebel
 --spr(108,28,20)--t
 --spr(109,36,20)--t
 --spr(105,8,4)--bett
 --spr(106,16,4)
 --spr(121,8,12)
 --spr(122,16,12)--
 mset(1,0,141)
 mset(2,0,142)
 mset(1,1,157)
 mset(2,1,158)
 mset(1,2,173)
 mset(2,2,174)
 --spr(105,48,4)--bett
 --spr(106,56,4)
 --spr(121,48,12)
 --spr(122,56,12)--
 mset(6,0,141)
 mset(7,0,142)
 mset(6,1,157)
 mset(7,1,158)
 mset(6,2,173)
 mset(7,2,174)
 spr(110,28,0)--schrank
 spr(111,36,0)
 spr(126,28,8)
 spr(127,36,8)--
 --spr(123,16,24)
 mset(2,3,123)
end

function draw_mansion_5()
 spr(9,72,0)
 spr(9,80,0)
 --spr(9,88,0)
 --spr(9,96,0)
 spr(9,104,0)
 spr(9,112,0)
 spr(9,112,32)
 spr(9,104,32)
 spr(9,96,32)
 spr(9,88,32)
 spr(9,64,32)
 spr(10,64,8)
 spr(10,64,16)
 spr(10,64,24)
 spr(10,120,0)
 spr(10,120,8)
 spr(10,120,16)
 spr(10,120,24)
 spr(11,64,0)
 spr(28,72,32)
 spr(1,80,32)
 --moebel
 spr(108,80,22)--t
 spr(109,88,22)--t
 --spr(105,92,4)--bett
 --spr(106,100,4)
 --spr(121,92,12)
 --spr(122,100,12)--
 mset(11,0,141)
 mset(12,0,142)
 mset(11,1,157)
 mset(12,1,158)
 mset(11,2,173)
 mset(12,2,174)
 spr(110,72,0)--schrank
 spr(111,80,0)
 spr(126,72,8)
 spr(127,80,8)--
 --spr(107,112,24)
 mset(14,3,107)
 spr(125,110,1)
 spr(125,90,33)
 spr(124,110,33)

end

function draw_mansion_6()
 --spr(9,112,56)
 --spr(9,104,56)
 spr(9,96,56)
 spr(9,88,56)
 spr(9,80,56)
 spr(11,72,56)
 spr(10,72,64)
 spr(1,72,72)
 spr(30,72,80)
 spr(10,120,56)
 spr(10,120,64)
 spr(10,120,72)
 spr(10,120,80)
 --moebel
 --spr(106,112,60)
 --spr(105,104,60)
 --spr(122,112,68)
 --spr(121,104,68)
 mset(14,7,142)
 mset(13,8,157)
 mset(14,8,158)
 mset(13,9,173)
 mset(14,9,174)
 spr(110,80,56)--schrank
 spr(111,88,56)
 spr(126,80,64)
 spr(127,88,64)--
 --spr(123,88,80)
 mset(11,10,123)
 spr(108,103,78)
 spr(109,111,78)
 
end

function draw_mansion_end()
 spr(45,48,112)
 spr(46,56,112)
 spr(47,64,112)
 spr(61,48,120)
 spr(62,56,120)
 spr(63,64,120)
 spr(10,120,32)
 spr(10,120,40)
 spr(10,120,48)
 spr(15,40,120)
 spr(11,40,112)
 spr(31,72,120)
 spr(12,72,112)
end
__gfx__
aaaaaaaadddddddd555555555566666655555555555555555566666666666655556666666666666666ffffff666666666666666666ffffffffffff6666ffffff
aaaaaaaadddddddd555555555566666655555555555555555566666666666655556666666666666666ffffff666666666666666666ffffffffffff6666ffffff
aa7aa7aadddddddd66666666556666665556666666666655556666666666665566666666ffffffff66ffffff66ffffffffffff6666ffffffffffff66ffffffff
aaa77aaadddddddd66666666556666665565666666666655556666666666665566666666ffffffff66ffffff66ffffffffffff6666ffffffffffff66ffffffff
aaa77aaadddddddd66666666556666665566566666666655556666666666665566666666ffffffff66ffffff66ffffffffffff6666ffffffffffff66ffffffff
aa7aa7aadddddddd66666666556666665566656666666655556666666666665566666666ffffffff66ffffff66ffffffffffff6666ffffffffffff66ffffffff
aaaaaaaadddddddd66666666556666665566665666666655555555555555555566666666ffffffff66ffffff66ffffffffffff666666666666666666ffffffff
aaaaaaaadddddddd66666666556666665566666566666655555555555555555566666666ffffffff66ffffff66ffffffffffff666666666666666666ffffffff
aaaaaaaaaaaaaaaa000000005555550000559555000000005555555555dddddd55dddddd555555555555555566666666666644666644944466666666ffffff66
aaaaaaaaaaaaaaaa00000000555555000055555500000000555555555555555555ddddd5555555555555555566666666666644666644444466666666ffffff66
aaaaaaaaaaaaaaaa555555556666550000555555555955556666666655dddddd55dddddd6d5d5d5d6ddddddd44444444ffff44666644444444494444ffffffff
aaaaaaaaaaaaaaaa55555555666659000055555555555555666666665555555555ddddd56d5d5d5d6ddddddd44444444ffff49666644444444444444ffffffff
aaaaaaaaaaaaaaaa555555596666550000555555556666666666666655dddddd55dddddd6d5d5d5d6ddddddd44444449ffff44666644444466ffffffffffffff
aaaaaaaaaaaaaaaa55555555666655000055555555666666666666665555555555ddddd56d5d5d5d6ddddddd44444444ffff44666644444466ffffffffffffff
aaaaaaaaaaaaaaaa555555556666550000555555556666666666666655dddddd55dddddd6d5d5d5d6ddddddd44444444ffff44666644444466ffffffffffffff
aaaaaaaaaaaaaaaa555555556666550000555555556666666666666655666666556666666d5d5d5d6d5d5d5d44444444ffff44666644444466ffffffffffffff
aaaaaaaaaa1991aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5555555567777776aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa666666666666666666666666
aaaaaaaaa511115aaa1991aaaaaaaaaaaaaaaaaaaaaaaaaa5555555556777765aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa666666666666666666666666
aaaaaaaaa5f8f85aa511115aaaaaaaaaaaaaaaaaaaaaaaaa6666666655555555aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffffffffffffffffffffff
aaaaaaaaaff555faa5f8f85aaa1991aaaaaaaaaaaaaaaaaa666666665dddddd5aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffffff999999999fffffff
aaaaaaaaaaf5f5aaaff555faa511115aaaaaaaaaaaaaaaaa56666665ddddddddaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffffff99444544499ffffff
aaaaaaaaf111111ff0f5f50fa5f8f85aaaaaaaaaaaaaaaaa56777765ddddddddaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffffff94444544449ffffff
aaaaaaaaaa1111aa011111100ff555f0a019910aa000000a57777775ddddddddaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffff9944445444499fffff
aaaaaaaaa040040a0000000000000000000000000000000067777776ddddddddaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffff9444445444449fffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa66666666aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffff994444454444499ffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa66777766aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffff944444454444449ffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa67777776aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffff944444959444449ffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa67777776aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffff944444454444449ffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa67777776aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffff944444454444449ffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa67777776aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffff944444454444449ffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa67777776aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffff944444454444449ffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa67777776aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafffff944444454444449ffff
aaa1199aaaa1199aaaa1199aaa9999aaaa9999aaaa9999aaaa999aaaaabaaaaaaacaaaaa11111111111111115dddddd5a777777a00000000000000005ddddddd
a5511111a5511111a5511111a99fff9aa99fff9aa99fff9aa9aaa9aaaaaaaabaaaaaaaca11111111111111115d7777d5a777777a50000000000000055ddddddd
a5f8f8faa5f8f8faa5f8f8faa9f4f4faa9f4f4faa9f4f4faaa999aaaabaaaaaaacaaaaaa11cccccccccccc1157777775a755557a55555555055555555ddd6666
aff555faaff555faaff555faafe4f4eaafe4f4eaafe4f4eaaaa9aaaaa333b33aa111c11a11cfffffffffff1167777776a570075a55555555055555555777d555
aaf5f5aaaaf5f5aaaaf5f5aaaaffffaaaaffffaaaaffffaaaaa9aaaa33bbbb3311cccc1111cfffffffffff1166666666a570075a55555555055555555555d5d5
aa111aaaaa1f1aaaaa111aaaaa888aaaaa8f8aaaaa888aaaaaa9a9aa3bbbbbb31cccccc111cfffffffffff1166777766a555555a55555550055555555dd5d5d5
aaf11aaaaa411aaaaaf14aaaaaf88aaaaa288aaaaaf82aaaaaa99aaa33bbbb3311cccc1111cfffffffffff1167777776aaa77aaa55555550555555555dd5d5d5
aa4a4aaaaaaa4aaaaa4aaaaaaa2a2aaaaaaa2aaaaa2aaaaaaaa9a9aaa333333aa111111a11cfffffffffff1167777776aaa77aaa55555550555555555dd5d5d5
a9911aaaa9911aaaa9911aaaaa9999aaaa9999aaaa9999aadd999dddaaaaaabaaaaaaaca11cfffffffffff1167777776aaa55aaa5555595055955555dd5555dd
1111155a1111155a1111155aa9fff99aa9fff99aa9fff99ad9ddd9ddabaaaaaaacaaaaaa11cfffffffffff1167777776a1a5aa8a5555555055555555dd5555dd
af8f8f5aaf8f8f5aaf8f8f5aaf4f4f9aaf4f4f9aaf4f4f9add999dddaaaabaaaaaaacaaa11cfffffffffff1167777776776666775555555055555555dd5555dd
af555ffaaf555ffaaf555ffaae4f4efaae4f4efaae4f4efaddd9dddda3b3333aa1c1111a11cfffffffffff1167777776777667775555555005555555dd5555dd
aa5f5faaaa5f5faaaa5f5faaaaffffaaaaffffaaaaffffaaddd9dddd33bbbb3311cccc1111cfffffffffff1167777776a777777a555555550555555566666666
aaa111aaaaa1f1aaaaa111aaaaa888aaaaa8f8aaaaa888aaddd9d9dd3bbbbbb31cccccc111cfffffffffff1156777765aa7777aa555555550555555566666666
aaa11faaaaa114aaaaa41faaaaa88faaaaa882aaaaa28faaddd99ddd33bbbb3311cccc11111111111111111155555555aaa66aaa555555550555555566666666
aaa4a4aaaaa4aaaaaaaaa4aaaaa2a2aaaaa2aaaaaaaaa2aaddd9d9dda333333aa111111a11111111111111115dddddd5aaa66aaadddddddddddddddd66666666
aa1991aaaa1991aaaa1991aaaa9999aaaa9999aaaa9999aaaaaaaaaaabaaaaaaacaaaaaa4fff44444444fff44dddff8faaaa88888888aaaa0000000000000000
a511115aa511115aa511115aa9ffff9aa9ffff9aa9ffff9aaaaaaaaaaaaabaaaaaaacaaa4f444444444444f44dddfff8aa888888888888aa4000000000000004
a5f8f85aa5f8f85aa5f8f85aa9f4f4faa9f4f4faa9f4f4faaaaaaaaaaabaaaaaaacaaaaa444eee4444eee4444dddfff9888888888888888a4444444404444444
aff555faaff555faaff555faafe4f4eaafe4f4eaafe4f4eaaaaaaaaaa33333baa11111ca4feeeeeffeeeeef44eee4444888888888888888844fff444044fff44
aaf5f5aaaaf5f5aaaaf5f5aaaaffffaaaaffffaaaaffffaaaaaaaaaa33bbbb3311cccc114ffffffffffffff4444444d488888888888888884f444f4404f444f4
a111111aaf11111aa11111faa888888aaf88888aa88888faaaaaaaaa3bbbbbb31cccccc14ffeeeeeeeeeeff44dd444d4a88888888888888a4f444f4404f444f4
af1111faaa4111faaf1114aaaf8888faaa2888faaf8882aaaaaaaaaa33bbbb3311cccc11dfeeeeeeeeeeeefd4dd4d4d4aa888888888888aa4f444f4404f444f4
aa4aa4aaaaaaa4aaaa4aaaaaaa2aa2aaaaaaa2aaaa2aaaaaaaaaaaaaa333333aa111111adfeeeeeeeeeeeefd4dd4d4d4aaaa88888888aaaa4f444444044444f4
aa1111aaaa1111aaaa1111aaaa9999aaaa9999aaaa9999aaaaaaaaaaaaaabaaaaaaacaaadfeeeeeeeeeeeefddd4994ddaaaaaaaaaaaaaaaa4f444944049444f4
a511115aa511115aa511115aa999999aa999999aa999999aaaaaaaaaaabaaaaaaacaaaaadfeeeeeeeeeeeefddd9449dda444444aa999999a4f444444044444f4
a555555aa555555aa555555aa999999aa999999aa999999aaaaaaaaaaaaaaabaaaaaaacadfeeeeeeeeeeeefddd4994dda415c14aa915559a4f444f4404f444f4
af5555faaf5555faaf5555faaf9999faaf9999faaf9999faaaaaaaaaab33333aac11111adfee44444444eefddd4444dda4b3b34aa911cc9a4f444f4404f444f4
aaffffaaaaffffaaaaffffaaaaffffaaaaffffaaaaffffaaaaaaaaaa33bbbb3311cccc114f444444444444f4ffffffffa444444aa91cc79a4f444f4404f444f4
a111111aa111111aa111111aa888888aa888888aa888888aaaaaaaaa3bbbbbb31cccccc14444444444444444ffffffffaaaaaaaaa999999a4f444f4404f444f4
af1111faaf1114aaaa4111faaf8888faaf8882aaaa2888faaaaaaaaa33bbbb3311cccc114444444444444444ffffffffaaaaaaaaaaaaaaaa44fff444044fff44
aa4aa4aaaa4aaaaaaaaaa4aaaa2aa2aaaa2aaaaaaaaaa2aaaaaaaaaaa333333aa111111a4dddddddddddddd4ffffffffaaaaaaaaaaaaaaaadddddddddddddddd
aaaaaaaaaaaaaaaaaaaa000aaaaaaaaaaa000aaaaaaa000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4fff44444444fff46666666666666666aaaaaaaa
a11111a0111111aaaa111111111111111111111111111111110aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4f444444444444f46666666666666666aaaaaaaa
aa000000000000aaaa0000000000000000000000007000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa444eee4444eee444ffffffffffffffffaaaaaaaa
1111122220117011111111222211111111111111170711111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4feeeeeffeeeeef4ffffffffffffffffaaaaaaaa
a001222220070700000001222200000000000000007000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4ffffffffffffff44fff44444444fff4aaaaaaaa
1112221111117011111111221111111111111111111111111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4ffeeeeeeeeeeff44f444444444444f4aaaaaaaa
a01220000000000000001222200000000000122000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadfeeeeeeeeeeeefd444eee4444eee444aaaaaaaa
111221111111111111111222201111111111122011111111111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadfeeeeeeeeeeeefd4feeeeeffeeeeef4aaaaaaaa
001220000012220012220122012212212222000012220012222000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadfeeeeeeeeeeeefd4ffffffffffffff4aaaaaaaa
111221001122222122222122112212212222122122222122222000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadfeeeeeeeeeeeefd4ffeeeeeeeeeeff4aaaaaaaa
001220000122122122122122012212212200122122122122122000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadfeeeeeeeeeeeefddfeeeeeeeeeeeefdaaaaaaaa
111222110122122122122122112212212222122122122122122111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadfee44444444eefddfeeeeeeeeeeeefdaaaaaaaa
0001222221222221221221220122222001221221221221222220000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4f444444444444f4dfeeeeeeeeeeeefdaaaaaaaa
a0111222211222012212211111122211222212212212201222210011aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444dfeeeeeeeeeeeefdaaaaaaaa
aa00000000005666660000000000000000000000000000001220000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444dfeeeeeeeeeeeefdaaaaaaaa
aa11111111115666666111171111111111111111111111111220000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4dddddddddddddd4dfee44444444eefdaaaaaaaa
aaaaaa0000005660566600707000000000000070000001221220000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4f444444444444f4aaaaaaaa
aa111111111156611566111711111111111117171111012222211111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaa
aaaaa00700005660056600000056600000000070000000122200700aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaa
1111117171115660566611111116611111111111111111111107170aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4dddddddddddddd4aaaaaaaa
a0000007000056666660000000000000000000000000000000007000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaddddddddddddddddaaaaaaaa
11111111111156666611566511111156666156661156661111111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaddddddddddddddddaaaaaaaa
00dee00000dee6600000566666566056666566666566666000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaddddddddddddddddaaaaaaaa
11dee1110deee6611111566656566156110566566566566011111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaddddddddddddddddaaaaaaaa
00deeee0deeee6600000566000566056666566566566566000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
11deeeeeeeeee6611111566011566111156566666566566011111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00deedeeeedee6600000566000566056666056660566566000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
11dee1dee1dee0111111111111111111dee011111111111111111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00dee0dee0dee0000000000000000000dee000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
11dee11111dee0111111111111111111111111111111111111111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00dee00000dee00deedee0deee0deeeedee0deee00deee00000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
11dee11111deedeeeeeeedeedeedeeeedeedeeeeedeeeee0071111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00dee00000deedee0deeedeedeedee00deedeedeedeedee0717000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa166666aaa1666aa166aaa1661222eeeaaaaaaaa
11dee01111deedee1deeedeedeedeeeedeedeedeedeedee0071111aaaaaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa16666666a166666a1662a1e6612622eeaaaaaaaa
00dee00000deedeeeeeeedeedee00deedeedeeeeedeedee0000000aaa7aaaaaaaaaaaaa7a7aaaaaaaaaaaaaa166aa166166616661662eee661262a2eaaaaaaaa
11dee01111dee10deedeedeedeedeeeedee0deee0deedee0111111aa7a7aaaaaaaaaaaaa7aaaaaaaaaaaaaaa166aaaaa166aa166166226e66126aaaeaaaaaaaa
0000000000000000000000000000000000000000000000000000aaaaa7aaaaaaaaaaaaaaaaaaaaaaaaaa7aaa166aaaaa166aa1661662aae66126aaaaaaaaaaaa
1111111111111111111111111111111111111111111111111111aaaaaaa2eaa2eaaaaaaaaaaaaaaaaaa7a7aa166aaaaa1662ee661662aae6612622e6aaaaaaaa
a000000000000000aaaaa0000000000000000000aaa00000000aaaaaaaa2eaa2eaaaaaaaaaaaaaaaaaaa7aaa166a166616622e66166aaa1661262e66aaaaaaaa
aa11aa11111111aaaaaaaaaaaaa00aaa1111110aaaaa110aaaaaaaaaaaa2ee2eeaaaaaaaaaaaaaaaaaaaaaaa166a166616622166166aaa1661662aaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2eeeaaaaaaaaaaaaaaaaaaaaaaaa166aa1661662a166166aaa166166aaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2eaaaaaaaaaaaaaaaaaaaaaaaaa166eee661662a166166aaa1661662ee6aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2eaaaaaaaaaaaaaaaaaaaaaaaaaa222ee6a166aa166166aaa16616622e6aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2ea2eee2e2eaaaaaaaaaaaaaaaaa2222eeaaaaaaaaaaaaaaaaaaaaa2aeaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2ea2e2e2e2eaaaaaaaaaa7aaaaaa22a22eaaaaaaaaaaaaaaaaaaaaa2aeaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2ea2eee2eeeaaaaaaaaa777aaaaa25552e5a5555555a5555555a55555e5aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7aaaaa525555e5555555555555555555555555aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7aaaaaaaaaaaaaaaaaaaaaaaaaaaa55555aaa55555aaa55555aaa55555aaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa288777a288aaa28888aaa288aaa288aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa288a7aa288aa2888888aa2888aa288aa166666a166aa12e16662ee1662ee6aaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa288aaaa288a2888a2888a28888a288a16666666166aa12e166222e16626e66aaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2888aa2888a288aaa288a288288288a166aa166166aa16216622ae1662a1666aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa28828288aa288aaa288a288a28888a166aa166166aa1661662aae1662aa166aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa28828288aa288aaa288a288aa2888a166aa166166aa166166aaaa166aa1e66aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa28888888aa288aaa288a288aaa288a166aa166166aa16616622ee16622ee6aaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa288888aaa288aaa288a288aaa288a166aa166166aa16616626e61666ee6aaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa288288aaa2888a2888a288aaa288a166aa166166aa1661662aaa1666e6aaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa288288aaaa2888888aa288aaa288a166aa16616621e66166aaaa1661e66aaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2828aaaaaa28888aaa288aaa288a166eee66a162ee6a16622ee166ae666aaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa122ee6aaa122eaa166222e166aa1666aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7a7aaaaaaaaaaaaaaaaa7aaaaaaaaaaaaa2a2eaaaaa22eaaaaa2a2eaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7aaaaaaaaaaaaaaaaa7a7aaaaaaaaaaa5252e55a5525e55a55255e5a5555555aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7aaaaaaaaaaa5525255555555e555552555555555555aaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa55255aaa55555aaa55555aaa55555aaaaaaaaa
__gff__
0000010101010101010101010101010100000101010101010001000101010100000000000000010000000000000000000000000000000100000000000000000000000000000000000001010100010101000000000000010000010101000101010000000000000100000101010000010100000000000001000001010100000101
0000000000000000000000010101010000000000000000000000000101010100000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0402020202020202040202020202020304020202020202020402020202020203040202020202020204020202020202030402020202020202040202020202020311111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101010101030101010101010303010101010101010301010101010103030101010101010103010101010101030301010101010101030101010101010311111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101010101030101010101010303010101010101010301010101010103030101010101010103010101010101030301010101010101030101010101010311111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101010101030101010101010303010101010101010301010101010103030101010101010103010101010101030301010101010101030101010101010311111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0302020202040212020212020219020303020202020402120202120202190203030202020204021202021202021902030302020202040212020212020219020311111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101030101010101010101010303010101010301010101010101010103030101010103010101010101010101030301010101030101010101010101010311111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101030101010101010101010303010101010301010101010101010103030101010103010101010101010101030301010101030101010101010101010311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03010101011401010104020202190203030101010114010101040202021a0203030101010114010101040202021902030301010101140101010402020219020311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101030101010301010101010303010101010301010103010101010103030101010103010101030101010101030301010101030101010301010101010311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101170101011401010101010303010101011701010114010101010103030101010117010101140101010101030301010101170101011401010101010311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0402020202030101010301010101010304020202020301010103010101010103040202020203010101030101010101030402020202030101010301010101010311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101030101010402020202020303010101010301010104020202020203030101010103010101040202020202030301010101030101010402020202020311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
030101010114010101030101010101030301010101140101010101696a010103030101010114010101140101010101030301010101140101011401010101010311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
030101010103010101140101010101030301010101030101011e01797a016b03030101010103010101030101010101030301010101030101010301010101010311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101170101010301010101494a03010101011701010103016c6d01494a0301010101170101011701010101494a0301010101170101011701010101494a11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202595a0202020202020202020202020202595a0202020202020202020202020202595a0202020202020202020202020202595a11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0402020202020202040202020202020304020202020202020402020202020203040202020202020204020202020202030402020202020202040202020202020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101010101030101010101010303010101010101010301010101010103030101010101010103010101010101030301010101010101030101010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101010101030101010101010303010101010101010301010101010103030101010101010103010101010101030301010101010101030101010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101010101030101010101010303010101010101010301010101010103030101010101010103010101010101030301010101010101030101010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0302020202040212020212020219020303020202020402120202120202190203030202020204021202021202021902030302020202040212020212020219020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101030101010101010101010303010101010301010101010101010103030101010103010101010101010101030301010101030101010101010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101030101010101010101010303010101010301010101010101010103030101010103010101010101010101030301010101030101010101010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101140101010402020219020303010101011401010104020202190203030101010114010101040202021902030301010101140101010402020219020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101030101010301010101010303010101010301010103010101010103030101010103010101030101010101030301010101030101010301010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101170101011401010101010303010101011701010114010101010103030101010117010101140101010101030301010101170101011401010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0402020202030101010301010101010304020202020301010103010101010103040202020203010101030101010101030402020202030101010301010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101030101010402020202020303010101010301010104020202020203030101010103010101040202020202030301010101030101010402020202020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101140101011401010101010303010101011401010114010101010103030101010114010101140101010101030301010101140101011401010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101030101010301010101010303010101010301010103010101010103030101010103010101030101010101030301010101030101010301010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101170101011701010101494a0301010101170101011701010101494a0301010101170101011701010101494a0301010101170101011701010101494a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202595a0202020202020202020202020202595a0202020202020202020202020202595a0202020202020202020202020202595a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010c00000d5500d5500d5500d5500d5500d550085300853008530085300853002530025200252002520025200252002520025100250002500025000e7000e7000e7000e7000e7000e7000e7000e7000e70000000
01050000135451f5452b5453754500200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000001a1321a1321d1321d132171321713210132101321a1001a1001d1001d1001710017100101001010000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400200e1250e125151251512511125111250c1250c1250e1250e125151251512511125111250c1250c1251012510125171251712513125131250e1250e1251012510125171251712513125131250e1250e125
011400200213502135071350713505135051350013500135021350213507135071350513505135001350013504135041350913509135071350713504135041350413504135091350913507135071350413504135
012800200007328615000732861500073286150007328615000732861500073286150007328615000732861500073286150007328615000732861500073286150007328615000732861500073286150007328615
00010000296122c6123b6623b6602d6102b610166101b61021610336603366019610106100e650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 03 42 43 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 03 04 05 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
