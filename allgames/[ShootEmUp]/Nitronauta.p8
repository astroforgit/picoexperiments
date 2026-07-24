pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function game_init()

	particle_systems = {}

	array_letters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}

	al_length = 26

	game_step = 0

	menu_steps = 0
	title_x = 130
	title_y = 10
	title_move_step = 5
	title_toggle = true
	title_dir = 1
	title_text_toggle = true
	timer_flash_on = true
	text_flash_time = 0.5
	trans_maze_on = false
	trans_timer = true

	select_time = 0
	select_time_on = true
	select_time_sec = 5

	function countdown_reset()
		p_select_timer = 0
		p_select_timer_pos_x_5 = 134
		p_select_timer_pos_x_4 = -6
		p_select_timer_pos_y_3 = -6
		p_select_timer_pos_y_2 = 134
		p_select_timer_pos_x_1 = -6
	end

	countdown_reset()

	p_select_timer_pos_steps_5 = -10
	p_select_timer_pos_steps_4 = 10
	p_select_timer_pos_steps_3 = 10
	p_select_timer_pos_steps_2 = -10
	p_select_timer_pos_steps_1 = 10
	timer_on = false

	p1_x = 20
	p1_y = 100
	p1_active_char = 1
	p1_name = ""
	p1_name_count = 0
	p1_name_index = {}
	p1_money_flash = false
	p1_money_timer = true
	p1_flash_count = 0
	p1_char_pos_x = -5
	p1_char_pos_y = 40
	p1_char_pos_steps_x = 1
	p1_char_pos_steps_y = 0
	p1_bounce_x = 0
	p1_bounce_y = 0

	bounce_amount = 3

	p2_x = 40
	p2_y = 100
	p2_active_char = 1
	p2_name = ""
	p2_name_count = 0
	p2_name_index = {}
	p2_money_flash = false
	p2_money_timer = true
	p2_flash_count = 0
	p2_char_pos_x = 132
	p2_char_pos_y = 40
	p2_char_pos_steps_x = -1
	p2_char_pos_steps_y = 0
	p2_bounce_x = 0
	p2_bounce_y = 0

	p3_x = 60
	p3_y = 100
	p3_active_char = 1
	p3_name = ""
	p3_name_count = 0
	p3_name_index = {}
	p3_money_flash = false
	p3_money_timer = true
	p3_flash_count = 0
	p3_char_pos_x = -5
	p3_char_pos_y = 99
	p3_char_pos_steps_x = 1
	p3_char_pos_steps_y = 0
	p3_bounce_x = 0
	p3_bounce_y = 0

	p4_x = 80
	p4_y = 100
	p4_active_char = 1
	p4_name = ""
	p4_name_count = 0
	p4_name_index = {}
	p4_money_flash = false
	p4_money_timer = true
	p4_flash_count = 0
	p4_char_pos_x = 132
	p4_char_pos_y = 99
	p4_char_pos_steps_x = -1
	p4_char_pos_steps_y = 0
	p4_bounce_x = 0
	p4_bounce_y = 0

	p1_active = true

	p2_active = false

	p3_active = false

	p4_active = false

	p1_only = false

	player_winner = 0

	timer_winner = true

	intro_timer = true

	explosion_on = 0
	explosion_p1_x = 0
	explosion_p1_y = 150

	explosion_p2_y = 0
	explosion_p2_y = 150

	explosion_p3_x = 0
	explosion_p3_y = 150

	explosion_p4_x = 0
	explosion_p4_y = 150
	create_players = true

	gameplay_steps = 0
	players_ready = false
	new_enemy_tutorial = true
	new_money_tutorial = true
	tutorial_timer = true

	enemy_array = {}
	enemy_array_index = 0
	enemy_new = true
	enemy_timer = 1
	enemy_create_index = 0
	enemy_move_index = 0
	enemy_vis_index = 0
	enemy_speed = 1

	money_array = {}
	money_array_index = 0
	money_new = true
	money_event_new = true
	money_timer = 3
	money_create_index = 0
	money_move_index = 0
	money_vis_index = 0
	money_speed = 1

	event_new = true
	event_timer_range = 10
	event_timer_min = 10
	event_running = false
	event_timer_finish = 5
	event_timer_finish_on = true
	event_type = 2
	enemy_event_new = true
	event_text_count = 0

	cam_pos_x = 0
	cam_pos_y = 0

	p1_score_move_step = 0
	p2_score_move_step = 0
	p3_score_move_step = 0
	p4_score_move_step = 0
end

function title_move()
	if title_toggle then
		if title_y < 15 then
			title_dir = 1
		else
			title_toggle = false
		end
	else
		if title_y > 10 then
			title_dir = -1
		else
			title_toggle = true
		end
	end

	title_y += title_dir * 30/90
	spr(162, title_x, title_y, 14, 4)
	spr(209, title_x-7, title_y+24, 14, 3)

end

function title_text_flash(textlabel, text_x, text_y, text_color)

	if title_text_toggle then

		print(textlabel, text_x, text_y, text_color)

		if timer_flash_on then

			last_int = 0

			add_timer(
 				"timer_flash",
 				text_flash_time,
 				function(dt, elapsed, length)
 					local i = flr(elapsed)
 					if i > last_int then
 						last_int = i
 					end
 				end,
 				function()
 					title_text_toggle = false
 					timer_flash_on = true
 				end
 			)

			timer_flash_on = false
		end
	else

		if timer_flash_on then

			last_int = 0

			add_timer(
 				"timer_flash",
 				text_flash_time,
 				function(dt, elapsed, length)
 					local i = flr(elapsed)
 					if i > last_int then
 						last_int = i
 					end
 				end,
 				function()
 					title_text_toggle = true
 					timer_flash_on = true
 				end
 			)

			timer_flash_on = false
		end
	end


end

entity = {}
entity.__index = entity

function entity.create(x,y,w,h,sprite, speed)
	local new_entity = {}
	setmetatable(new_entity, entity)

	new_entity.x = x
	new_entity.y = y
	new_entity.h = h
	new_entity.w = w
	new_entity.speed = speed
	new_entity.speed_x = 0.1
	new_entity.speed_y = 0.1
	new_entity.accel = 0.2
	new_entity.sprite = sprite
	new_entity.score = 0

	return new_entity
end

function entity:collide(other_entity)
	return other_entity.x < self.x + self.w and self.x < other_entity.x + other_entity.w
        and other_entity.y < self.y + self.h and self.y < other_entity.y + other_entity.h
end

function enemy_create(enemy_index)

	if enemy_type == 0 then
		if gameplay_steps == 1 then
			enemy_array[enemy_index] = entity.create(64, -20, 8, 8, (flr(rnd(3))*16)+160, enemy_speed)
		else
			enemy_array[enemy_index] = entity.create(rnd(110)+10, -20, 8, 8, (flr(rnd(3))*16)+160, enemy_speed+rnd(4))
		end
	elseif enemy_type == 1 then
		if gameplay_steps == 1 then
			enemy_array[enemy_index] = entity.create(64, -20, 16, 16, 99, enemy_speed)
		else
			enemy_array[enemy_index] = entity.create(rnd(110)+10, -20, 16, 16, 99, enemy_speed+rnd(4))
		end
	elseif enemy_type == 2 then
		if gameplay_steps == 1 then
			enemy_array[enemy_index] = entity.create(64, -20, 32, 16, 131, enemy_speed)
		else
			enemy_array[enemy_index] = entity.create(rnd(110)+10, -20, 32, 16, 131, enemy_speed+rnd(4))
		end
	end

	enemy_type = 4

	enemy_array_index += 1
end

function money_create(money_index)

	if money_type == 0 then
		if gameplay_steps == 2 then
			money_array[money_index] = entity.create(64, -20, 8, 8, 96, money_speed)
		else
			money_array[money_index] = entity.create(rnd(110)+10, -20, 8, 8, 96, money_speed)
		end
	elseif money_type == 1 then
		if gameplay_steps == 2 then
			money_array[money_index] = entity.create(64, -20, 8, 8, 112, money_speed)
		else
			money_array[money_index] = entity.create(rnd(110)+10, -20, 8, 8, 112, money_speed)
		end
	elseif money_type == 2 then
		if gameplay_steps == 2 then
			money_array[money_index] = entity.create(64, -20, 8, 8, 128, money_speed)
		else
			money_array[money_index] = entity.create(rnd(110)+10, -20, 8, 8, 128, money_speed)
		end
	elseif money_type == 3 then
		if gameplay_steps == 2 then
			money_array[money_index] = entity.create(64, -20, 8, 8, 144, money_speed)
		else
			money_array[money_index] = entity.create(rnd(110)+10, -20, 8, 8, 144, money_speed)
		end
	end

	money_type = 5

	money_array_index += 1

end

function event_run(type)

	if type == 0 then
		if enemy_event_new then
			enemy_type = 0

			enemy_create_index = 0

			while enemy_array[enemy_create_index] != nil do
				enemy_create_index += 1
			end

			last_int = 0

			add_timer(
						"timer_enemy",
						rnd(1),
						function(dt, elapsed, length)
							local i = flr(elapsed)
							if i > last_int then
								--sfx(4)
								last_int = i
							end
						end,
						function()
							enemy_create(enemy_create_index)
							enemy_event_new = true
						end
					)

			enemy_event_new = false
		end

	elseif type == 1 then

		if money_event_new then
			money_type = flr(rnd(4))

			money_create_index = 0

			while money_array[money_create_index] != nil do
				money_create_index += 1
			end

	 		last_int_money_event = 0

	 		add_timer(
	 					"timer_money_event",
	 					1,
	 					function(dt, elapsed, length)
	 						local i = flr(elapsed)
	 						if i > last_int_money_event then
	 							last_int_money_event = i
	 						end
	 					end,
	 					function()
							money_create(money_create_index)
	 						money_event_new = true
	 					end
	 				)

			money_event_new = false
		end
	end

	if event_timer_finish_on then

		last_int_finish_event = 0

		add_timer(
				"timer_finish_event",
				rnd(event_timer_range)+event_timer_min,
				function(dt, elapsed, length)
					local i = flr(elapsed)
					if i > last_int_finish_event then
						last_int_finish_event = i
					end
				end,
				function()
					event_type = 2
					event_running = false
					event_new = true
					enemy_new = true
				end
			)

		event_timer_finish_on = false
	end
end

function p1_text_input()

	if btnp(1, 0) then
 	if p1_active_char < al_length then
 		p1_active_char += 1
 	else
 		p1_active_char = 1
 	end
 elseif btnp(0, 0) then
 	if p1_active_char > 1 then
 		p1_active_char -= 1
 	else
 		p1_active_char = al_length
 	end
 end

 if btnp(3, 0) and p1_char_pos_steps_x == 0 then
 	if p1_name_count < 3 then
 		p1_name = p1_name .. array_letters[p1_active_char]
		p1_name_index[p1_name_count+1] = p1_active_char
 		p1_name_count += 1
 	end
 end
end

function p2_text_input()

	if btnp(1, 1) then
 	if p2_active_char < al_length then
 		p2_active_char += 1
 	else
 		p2_active_char = 1
 	end
 elseif btnp(0, 1) then
 	if p2_active_char > 1 then
 		p2_active_char -= 1
 	else
 		p2_active_char = al_length
 	end
 end

 if btnp(3, 1) and p2_char_pos_steps_x == 0 then
 	if p2_name_count < 3 then
 		p2_name = p2_name .. array_letters[p2_active_char]
		p2_name_index[p2_name_count+1] = p2_active_char
 		p2_name_count += 1
 	end
 end
end

function p3_text_input()

	if btnp(1, 2) then
 	if p3_active_char < al_length then
 		p3_active_char += 1
 	else
 		p3_active_char = 1
 	end
 elseif btnp(0, 2) then
 	if p3_active_char > 1 then
 		p3_active_char -= 1
 	else
 		p3_active_char = al_length
 	end
 end

 if btnp(3, 2) and p3_char_pos_steps_x == 0 then
 	if p3_name_count < 3 then
 		p3_name = p3_name .. array_letters[p3_active_char]
		p3_name_index[p3_name_count+1] = p3_active_char
 		p3_name_count += 1
 	end
 end
end

function p4_text_input()

	if btnp(1, 3) then
 	if p4_active_char < al_length then
 		p4_active_char += 1
 	else
 		p4_active_char = 1
 	end
 elseif btnp(0, 3) then
 	if p4_active_char > 1 then
 		p4_active_char -= 1
 	else
 		p4_active_char = al_length
 	end
 end

 if btnp(3, 3)  and p4_char_pos_steps_x == 0 then
 	if p4_name_count < 3 then
 		p4_name = p4_name .. array_letters[p4_active_char]
		p4_name_index[p4_name_count+1] = p4_active_char
 		p4_name_count += 1
 	end
 end
end

function p1_move()

	local lx=player_p1.x -- last x
	local ly=player_p1.y -- last y

	if btn(0, 0) then
		if player_p1.speed_x > -player_p1.speed then
			player_p1.speed_x -= player_p1.accel
		end
	elseif btn(1, 0) then
		if player_p1.speed_x < player_p1.speed then
		 player_p1.speed_x += player_p1.accel
		end
	else

		if player_p1.speed_x > 0.5 then
			player_p1.speed_x -= player_p1.accel
		elseif player_p1.speed_x < -0.5 then
			player_p1.speed_x += player_p1.accel
		end

	end

	if btn(2, 0) then
		if player_p1.speed_y > -player_p1.speed then
			player_p1.speed_y -= player_p1.accel
		end
	elseif btn(3, 0) then
		if player_p1.speed_y < player_p1.speed then
		 player_p1.speed_y += player_p1.accel
		end
	else

		if player_p1.speed_y > 0 then
			player_p1.speed_y -= player_p1.accel
		elseif player_p1.speed_y < 0 then
			player_p1.speed_y += player_p1.accel
		end

	end

	player_p1.x += player_p1.speed_x + p1_bounce_x
	player_p1.y += player_p1.speed_y + p1_bounce_y

	if p1_bounce_x > 0 then
		p1_bounce_x -= 0.5
	elseif p1_bounce_x < 0 then
		p1_bounce_x += 0.5
	end

	if p1_bounce_y > 0 then
		p1_bounce_y -= 0.5
	elseif p1_bounce_y < 0 then
		p1_bounce_y += 0.5
	end

	if (p2_active and player_p1:collide(player_p2)) or (p3_active and player_p1:collide(player_p3)) or (p4_active and player_p1:collide(player_p4)) then
			p1_bounce_x = (sgn(player_p1.speed_x)*-1)*bounce_amount
			p1_bounce_y = (sgn(player_p1.speed_y)*-1)*bounce_amount
	end

	if player_p1.x<-1 or player_p1.x>115 then
	 player_p1.x = lx

		 if player_p1.speed_x > 0 then
	 		player_p1.speed_x -= player_p1.accel
	 	else
	 		player_p1.speed_x += player_p1.accel
	 	end
	end

	if player_p1.y<-1 or player_p1.y>115 then
	 player_p1.y = ly

	 if player_p1.speed_y > 0 then
		 player_p1.speed_y -= player_p1.accel
	 else
		 player_p1.speed_y += player_p1.accel
	 end
	end

end

function p2_move()

	local lx=player_p2.x -- last x
	local ly=player_p2.y -- last y

		if btn(0, 1) then
			if player_p2.speed_x > -player_p2.speed then
				player_p2.speed_x -= player_p2.accel
			end
		elseif btn(1, 1) then
			if player_p2.speed_x < player_p2.speed then
			 player_p2.speed_x += player_p2.accel
			end
		else

			if player_p2.speed_x > 0.5 then
				player_p2.speed_x -= player_p2.accel
			elseif player_p2.speed_x < -0.5 then
				player_p2.speed_x += player_p2.accel
			end

		end

		if btn(2, 1) then
			if player_p2.speed_y > -player_p2.speed then
				player_p2.speed_y -= player_p2.accel
			end
		elseif btn(3, 1) then
			if player_p2.speed_y < player_p2.speed then
			 player_p2.speed_y += player_p2.accel
			end
		else

			if player_p2.speed_y > 0.5 then
				player_p2.speed_y -= player_p2.accel
			elseif player_p2.speed_y < -0.5 then
				player_p2.speed_y += player_p2.accel
			end

		end

		player_p2.x += player_p2.speed_x + p2_bounce_x
		player_p2.y += player_p2.speed_y + p2_bounce_y

		if p2_bounce_x > 0 then
			p2_bounce_x -= 0.5
		elseif p2_bounce_x < 0 then
			p2_bounce_x += 0.5
		end

		if p2_bounce_y > 0 then
			p2_bounce_y -= 0.5
		elseif p2_bounce_y < 0 then
			p2_bounce_y += 0.5
		end

		if (p1_active and player_p2:collide(player_p1)) or (p3_active and player_p2:collide(player_p3)) or (p4_active and player_p2:collide(player_p4)) then
				p2_bounce_x = (sgn(player_p2.speed_x)*-1)*bounce_amount
				p2_bounce_y = (sgn(player_p2.speed_y)*-1)*bounce_amount
		end

		if player_p2.x<-1 or player_p2.x>115 then
		 player_p2.x = lx

		 if player_p2.speed_x > 0 then
 		 player_p2.speed_x -= player_p2.accel
 	 else
 		 player_p2.speed_x += player_p2.accel
 	 end
		end

		if player_p2.y<-1 or player_p2.y>115 then
		 player_p2.y = ly

		 if player_p2.speed_y > 0 then
 		 player_p2.speed_y -= player_p2.accel
 	 else
 		 player_p2.speed_y += player_p2.accel
 	 end
		end

end

function p3_move()

	local lx=player_p3.x -- last x
	local ly=player_p3.y -- last y

		if btn(0, 2) then
			if player_p3.speed_x > -player_p3.speed then
				player_p3.speed_x -= player_p3.accel
			end
		elseif btn(1, 2) then
			if player_p3.speed_x < player_p3.speed then
			 player_p3.speed_x += player_p3.accel
			end
		else

			if player_p3.speed_x > 0.5 then
				player_p3.speed_x -= player_p3.accel
			elseif player_p3.speed_x < -0.5 then
				player_p3.speed_x += player_p3.accel
			end

		end

		if btn(2, 2) then
			if player_p3.speed_y > -player_p3.speed then
				player_p3.speed_y -= player_p3.accel
			end
		elseif btn(3, 2) then
			if player_p3.speed_y < player_p3.speed then
			 player_p3.speed_y += player_p3.accel
			end
		else

			if player_p3.speed_y > 0.5 then
				player_p3.speed_y -= player_p3.accel
			elseif player_p3.speed_y < -0.5 then
				player_p3.speed_y += player_p3.accel
			end

		end

		player_p3.x += player_p3.speed_x + p3_bounce_x
		player_p3.y += player_p3.speed_y + p3_bounce_y

		if p3_bounce_x > 0 then
			p3_bounce_x -= 0.5
		elseif p3_bounce_x < 0 then
			p3_bounce_x += 0.5
		end

		if p3_bounce_y > 0 then
			p3_bounce_y -= 0.5
		elseif p3_bounce_y < 0 then
			p3_bounce_y += 0.5
		end

		if (p1_active and player_p3:collide(player_p1)) or (p2_active and player_p3:collide(player_p2)) or (p4_active and player_p3:collide(player_p4)) then
				p3_bounce_x = (sgn(player_p3.speed_x)*-1)*bounce_amount
				p3_bounce_y = (sgn(player_p3.speed_y)*-1)*bounce_amount
		end

		if player_p3.x<-1 or player_p3.x>115 then
		 player_p3.x = lx

		 if player_p3.speed_x > 0 then
		 player_p3.speed_x -= player_p3.accel
	 else
		 player_p3.speed_x += player_p3.accel
	 end
		end

		if player_p3.y<-1 or player_p3.y>115 then
		 player_p3.y = ly

		 if player_p3.speed_y > 0 then
			player_p3.speed_y -= player_p3.accel
		else
			player_p3.speed_y += player_p3.accel
		end
		end

end

function p4_move()

	local lx=player_p4.x -- last x
	local ly=player_p4.y -- last y

		if btn(0, 3) then
			if player_p4.speed_x > -player_p4.speed then
				player_p4.speed_x -= player_p4.accel
			end
		elseif btn(1, 3) then
			if player_p4.speed_x < player_p4.speed then
			 player_p4.speed_x += player_p4.accel
			end
		else

			if player_p4.speed_x > 0.5 then
				player_p4.speed_x -= player_p4.accel
			elseif player_p4.speed_x < -0.5 then
				player_p4.speed_x += player_p4.accel
			end

		end

		if btn(2, 3) then
			if player_p4.speed_y > -player_p4.speed then
				player_p4.speed_y -= player_p4.accel
			end
		elseif btn(3, 3) then
			if player_p4.speed_y < player_p4.speed then
			 player_p4.speed_y += player_p4.accel
			end
		else

			if player_p4.speed_y > 0.5 then
				player_p4.speed_y -= player_p4.accel
			elseif player_p4.speed_y < -0.5 then
				player_p4.speed_y += player_p4.accel
			end

		end

		player_p4.x += player_p4.speed_x + p4_bounce_x
		player_p4.y += player_p4.speed_y + p4_bounce_y

		if p4_bounce_x > 0 then
			p4_bounce_x -= 0.5
		elseif p4_bounce_x < 0 then
			p4_bounce_x += 0.5
		end

		if p4_bounce_y > 0 then
			p4_bounce_y -= 0.5
		elseif p4_bounce_y < 0 then
			p4_bounce_y += 0.5
		end

		if (p1_active and player_p4:collide(player_p1)) or (p2_active and player_p4:collide(player_p2)) or (p3_active and player_p4:collide(player_p3)) then
				p4_bounce_x = (sgn(player_p4.speed_x)*-1)*bounce_amount
				p4_bounce_y = (sgn(player_p4.speed_y)*-1)*bounce_amount
		end

		if player_p4.x<-1 or player_p4.x>115 then
		 player_p4.x = lx

			if player_p4.speed_x > 0 then
				player_p4.speed_x -= player_p4.accel
			else
				player_p4.speed_x += player_p4.accel
			end
		end

		if player_p4.y<-1 or player_p4.y>115 then
		 player_p4.y = ly

		 if player_p4.speed_y > 0 then
			 player_p4.speed_y -= player_p4.accel
		 else
			 player_p4.speed_y += player_p4.accel
		 end
		end

end

function hcenter(s)
  return 64-#s*2
end

function init_timers ()
  last_time = time()
end

function add_timer (name,
    length, step_fn, end_fn,
    start_paused)
  local timer = {
    length=length,
    elapsed=0,
    active=not start_paused,
    step_fn=step_fn,
    end_fn=end_fn
  }
  timers[name] = timer
  return timer
end

function update_timers ()
  local t = time()
  local dt = t - last_time
  last_time = t
  for name,timer in pairs(timers) do
    if timer.active then
      timer.elapsed += dt
      local elapsed = timer.elapsed
      local length = timer.length
      if elapsed < length then
        if timer.step_fn then
          timer.step_fn(dt,elapsed,length,timer)
        end
    else
        timer.active = false
        if timer.end_fn then
          timer.end_fn(dt,elapsed,length,timer)
        end
      end
    end
  end
end

function pause_timer (name)
  local timer = timers[name]
  if (timer) timer.active = false
end

function animator(o, sf, nf, sp, fl, sz)
	if(not o.a_ct) o.a_ct = 0
	if(not o.a_st) o.a_st = 0

	o.a_ct += 1

	if(o.a_ct%(30/sp)==0) then
		if sz == 8 then
			o.a_st += 1
		elseif sz == 16 then
			o.a_st += 2
		elseif sz == 32 then
			o.a_st += 4
		end

		if(o.a_st == nf) o.a_st = 0
	end

	o.a_fr = sf+o.a_st
	if sz == 8 then
		spr(o.a_fr, o.x, o.y, 1, 1, fl)
	elseif sz == 16 then
		spr(o.a_fr, o.x, o.y, 2, 2, fl)
	elseif sz == 32 then
		spr(o.a_fr, o.x, o.y, 4, 2, fl)
	end
end

stars = {}
initial_stars_count = 40

function create_star()
	starx = rnd(100) - 50
	stary = rnd(100) - 50
	starz = rnd(3)
	star = { starx, stary, starz }
	return star
end

function get_2d_coords(star)
	return { (star[1] / star[3]) + 64, 64 - (star[2] / star[3]) }
end

function space_effect()
	for i = 1, #stars do
		coords = get_2d_coords(stars[i])
		dx = coords[1]
		dy = coords[2]
		x = stars[i][1]
		y = stars[i][2]
		pset(dx, dy, 6)
		if (dx > 128 or dy > 128) then
			stars[i] = create_star()
		else
			stars[i][3] = stars[i][3] - 0.04
		end
	end
end

function trans_maze_init()
	pi_x = 64
	pi_y = 64
	pi_off = 8
	pi_speed = 5
	pi_color = 0
	pi_radius = 30
end

function trans_maze()

	circfill(pi_x, pi_y-pi_off, pi_radius, pi_color)
	circfill(pi_x, pi_y+pi_off, pi_radius, pi_color)
	circfill(pi_x-pi_off, pi_y, pi_radius, pi_color)
	circfill(pi_x+pi_off, pi_y, pi_radius, pi_color)
	circfill(pi_x+pi_off, pi_y-pi_off, pi_radius, pi_color)
	circfill(pi_x-pi_off, pi_y-pi_off, pi_radius, pi_color)
	circfill(pi_x+pi_off, pi_y+pi_off, pi_radius, pi_color)
	circfill(pi_x-pi_off, pi_y+pi_off, pi_radius, pi_color)
	pi_off += pi_speed

end

function trans_maze_run()
	trans_maze_init()
	trans_maze_on = true
	trans_timer = true
	sfx(5)
end

function make_psystem(minlife, maxlife, minstartsize, maxstartsize, minendsize, maxendsize)
	local ps = {}
	ps.autoremove = true

	ps.minlife = minlife
	ps.maxlife = maxlife

	ps.minstartsize = minstartsize
	ps.maxstartsize = maxstartsize
	ps.minendsize = minendsize
	ps.maxendsize = maxendsize

	ps.particles = {}

	ps.emittimers = {}

	ps.emitters = {}

	ps.drawfuncs = {}

	ps.affectors = {}

	add(particle_systems, ps)

	return ps
end

function update_psystems()
	local timenow = time()
	for ps in all(particle_systems) do
		update_ps(ps, timenow)
	end
end

function update_ps(ps, timenow)
	for et in all(ps.emittimers) do
		local keep = et.timerfunc(ps, et.params)
		if (keep==false) then
			del(ps.emittimers, et)
		end
	end

	for p in all(ps.particles) do
		p.phase = (timenow-p.starttime)/(p.deathtime-p.starttime)

		for a in all(ps.affectors) do
			a.affectfunc(p, a.params)
		end

		p.x += p.vx
		p.y += p.vy

		local dead = false
		if (p.x<0 or p.x>127 or p.y<0 or p.y>127) then
			dead = true
		end

		if (timenow>=p.deathtime) then
			dead = true
		end

		if (dead==true) then
			del(ps.particles, p)
		end
	end

	if (ps.autoremove==true and count(ps.particles)<=0) then
		del(particle_systems, ps)
	end
end

function draw_ps(ps, params)
	for df in all(ps.drawfuncs) do
		df.drawfunc(ps, df.params)
	end
end

function emittimer_burst(ps, params)
	for i=1,params.num do
		emit_particle(ps)
	end
	return false
end

function emittimer_constant(ps, params)
	if (params.nextemittime<=time()) then
		emit_particle(ps)
		params.nextemittime += params.speed
	end
	return true
end

function emit_particle(psystem)
	local p = {}

	local e = psystem.emitters[flr(rnd(#(psystem.emitters)))+1]
	e.emitfunc(p, e.params)

	p.phase = 0
	p.starttime = time()
	p.deathtime = time()+rnd(psystem.maxlife-psystem.minlife)+psystem.minlife

	p.startsize = rnd(psystem.maxstartsize-psystem.minstartsize)+psystem.minstartsize
	p.endsize = rnd(psystem.maxendsize-psystem.minendsize)+psystem.minendsize

	add(psystem.particles, p)
end

function emitter_point(p, params)
	p.x = params.x
	p.y = params.y

	p.vx = rnd(params.maxstartvx-params.minstartvx)+params.minstartvx
	p.vy = rnd(params.maxstartvy-params.minstartvy)+params.minstartvy
end

function emitter_box(p, params)
	p.x = rnd(params.maxx-params.minx)+params.minx
	p.y = rnd(params.maxy-params.miny)+params.miny

	p.vx = rnd(params.maxstartvx-params.minstartvx)+params.minstartvx
	p.vy = rnd(params.maxstartvy-params.minstartvy)+params.minstartvy
end

function draw_ps_fillcirc(ps, params)
	for p in all(ps.particles) do
		c = flr(p.phase*count(params.colors))+1
		r = (1-p.phase)*p.startsize+p.phase*p.endsize
		circfill(p.x,p.y,r,params.colors[c])
	end
end

function draw_ps_pixel(ps, params)
	for p in all(ps.particles) do
		c = flr(p.phase*count(params.colors))+1
		pset(p.x,p.y,params.colors[c])
	end
end

function make_explosion_ps(ex,ey)
	local ps = make_psystem(0.1,0.5, 9,14,1,3)

	add(ps.emittimers,
		{
			timerfunc = emittimer_burst,
			params = { num = 4 }
		}
	)
	add(ps.emitters,
		{
			emitfunc = emitter_box,
			params = { minx = ex-4, maxx = ex+4, miny = ey-4, maxy= ey+4, minstartvx = 0, maxstartvx = 0, minstartvy = 0, maxstartvy=0 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_fillcirc,
			params = { colors = {7,0,10,9,9,4} }
		}
	)
end

function make_starfield_ps()
	local ps = make_psystem(4,6, 1,2,0.5,0.5)
	ps.autoremove = false
	add(ps.emittimers,
		{
			timerfunc = emittimer_constant,
			params = {nextemittime = time(), speed = 0.01}
		}
	)
	add(ps.emitters,
		{
			emitfunc = emitter_box,
			params = { minx = 0, maxx = 127, miny = 0, maxy= 10, minstartvx = 0, maxstartvx = 0, minstartvy = 0, maxstartvy=1 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_pixel,
			params = { colors = {7,6,7,6,7,6,6,7,6,7,7,6,6,7} }
		}
	)
end

function save_score(score)
		poke4(0x5e00, score)
end

function load_score()
		return peek4(0x5e00)
end

function save_score_single(score)
		poke4(0x5e09, score)
end

function load_score_single()
		return peek4(0x5e09)
end

function save_winner_name(winner)

	for k=1, 3, 1 do
		if winner == 1 then
				poke(0x5e03+k, p1_name_index[k])
		elseif winner == 2 then
				poke(0x5e03+k, p2_name_index[k])
		elseif winner == 3 then
				poke(0x5e03+k, p3_name_index[k])
		elseif winner == 4 then
				poke(0x5e03+k, p4_name_index[k])
		end
	end

end

function save_winner_name_single(winner)

	for k=1, 3, 1 do
				poke(0x5e12+k, p1_name_index[k])
	end

end

function save_winner_color(winner)
	if winner == 1 then
			poke(0x5e07, 8)
	elseif winner == 2 then
			poke(0x5e07, 11)
	elseif winner == 3 then
			poke(0x5e07, 10)
	elseif winner == 4 then
			poke(0x5e07, 2)
	end
end

function save_winner_color_single(winner)
			poke(0x5e16, 8)
end

p1_screenshake_amount = 10

p1_screenshake_on = false

function p1_camera_screenshake()
		camera(cam_pos_x+rnd(p1_screenshake_amount), cam_pos_y+rnd(p1_screenshake_amount))

		if p1_screenshake_amount > 0 then
			p1_screenshake_amount -= 0.5
		else
			p1_screenshake_on = false
		end

end

p2_screenshake_amount = 10

p2_screenshake_on = false

function p2_camera_screenshake()

		camera(cam_pos_x+rnd(p2_screenshake_amount), cam_pos_y+rnd(p2_screenshake_amount))

		if p2_screenshake_amount > 0 then
			p2_screenshake_amount -= 0.5
		else
			p2_screenshake_on = false
		end

end

p3_screenshake_amount = 10

p3_screenshake_on = false

function p3_camera_screenshake()

		camera(cam_pos_x+rnd(p3_screenshake_amount), cam_pos_y+rnd(p3_screenshake_amount))

		if p3_screenshake_amount > 0 then
			p3_screenshake_amount -= 0.5
		else
			p3_screenshake_on = false
		end

end

p4_screenshake_amount = 10

p4_screenshake_on = false

function p4_camera_screenshake()

		camera(cam_pos_x+rnd(p4_screenshake_amount), cam_pos_y+rnd(p4_screenshake_amount))

		if p4_screenshake_amount > 0 then
			p4_screenshake_amount -= 0.5
		else
			p4_screenshake_on = false
		end

end

function cmap(o)
	local ct=false
	local cb=false

 	cb=(o.x<1 or o.x+16>127 or
						o.y<1 or o.y+16>127)

 return ct or cb
end

function _init()

	game_init()

	w = 128
	h = 128

	cls()

	timers = {}
	last_time = nil

	init_timers()

	for x = 1, initial_stars_count do
		 stars[x] = create_star()
	end

	trans_maze_init()


end

function _update()
	update_psystems()

	update_timers()

	if game_step == 0 then
		if menu_steps == 0 then
 		if title_x > 14 then
 			title_x -= title_move_step
 		else
 			sfx(0)
 			menu_steps += 1
 		end
 	elseif menu_steps == 2 then
 	 menu_steps += 1
 	elseif menu_steps == 3 then
 		if btn(2, 0) then

 		 menu_steps += 1
 		end

		if btn(3, 0) and (load_score_single() != 0 or load_score() != 0) then
			save_score(0)
			save_score_single(0)
			_init()
		end
 	end
	elseif game_step == 1 then

			if p1_name_count < 3 then
				p1_text_input()
				select_time_on = true
			end

		if p2_active then
			if p2_name_count < 3 then
				p2_text_input()
				select_time_on = true
			else
			 if timer_on then
 				select_time_on = true

 				timer_on = false
				end
			end
		else
			if btn(2, 1) then

				p2_active = true
				sfx(12)
				pause_timer("timer_select")

				countdown_reset()

				timer_on = true
			end
		end

		if p3_active then
			if p3_name_count < 3 then
				p3_text_input()
				select_time_on = true
			else
 				if timer_on then
 				select_time_on = true

 				timer_on = false
				end
			end
		else
			if btn(2, 2) then

				p3_active = true
				sfx(13)
				pause_timer("timer_select")

				countdown_reset()

				timer_on = true
			end
		end

		if p4_active then
			if p4_name_count < 3 then
				p4_text_input()
				select_time_on = true
			else
 				if timer_on then

 				select_time_on = true

 				timer_on = false
				end
			end
		else
			if btn(2, 3) then

				p4_active = true
				sfx(14)
				pause_timer("timer_select")

				countdown_reset()

				timer_on = true
			end
		end

		if p1_name_count >= 3 or p2_name_count >= 3 or p3_name_count >= 3 or p4_name_count >= 3 then
			if select_time_on then

				last_int = 0

 			add_timer(
  				"timer_select",
  				5,
  				function(dt, elapsed, length)
  					local i = flr(elapsed)
  					if i > last_int then
  						p_select_timer = i
  						sfx(4)
  						last_int = i
  					end
  				end,
  				function()

						if p1_active == true and p2_active == false and p3_active == false and p4_active == false then
							p1_only = true
						end

						trans_maze_run()
  				end
  			)

 			select_time_on = false
			end
		end
	elseif game_step == 2 then
		cls()
		print("we want to find out why", 20, 55, 7)
		print("the stars are watching us", 16, 66, 7)

		if intro_timer then
			last_int = 0

			add_timer(
					"timer_intro",
					2,
					function(dt, elapsed, length)
						local i = flr(elapsed)
						if i > last_int then
							last_int = i
						end
					end,
					function()
						trans_maze_run()
					end
				)

			intro_timer = false
		end
	elseif game_step == 3 then

	 if enemy_speed < 10 then
			enemy_speed += 0.0005
	 end

	 if money_speed < 10 then
			money_speed += 0.0005
	 end

	if create_players then
	 if p1_active then
		 player_p1 = entity.create(10, 150, 12, 12, 0, 3)
		 explosion_p1_y = 0
	 end

	 if p2_active then
		 player_p2 = entity.create(30, 150, 12, 12, 8, 3)
		 explosion_p2_y = 0
	 end

	 if p3_active then
		 player_p3 = entity.create(50, 150, 12, 12, 32, 3)
		 explosion_p3_y = 0
	 end

	 if p4_active then
		 player_p4 = entity.create(70, 150, 12, 12, 40, 3)
		 explosion_p4_y = 0
	 end

	 create_players = false
	end

 if p1_active then
	 p1_move()
 end

 if p2_active then
	 p2_move()
 end

 if p3_active then
	 p3_move()
 end

 if p4_active then
	 p4_move()
 end

 enemy_move_index = 0

 while enemy_move_index <= enemy_array_index do
 	if enemy_array[enemy_move_index] != nil then
 		if enemy_array[enemy_move_index].y < 127 then
 			enemy_array[enemy_move_index].y += enemy_array[enemy_move_index].speed

 			if enemy_array[enemy_move_index]:collide(player_p1) then
 				p1_active = false
 				explosion_p1_x = player_p1.x
 				explosion_p1_y = player_p1.y

				p1_screenshake_on = true
				sfx(11)
			end

			if p2_active then
 				if enemy_array[enemy_move_index]:collide(player_p2) then
 					p2_active = false
 					explosion_p2_x = player_p2.x
 					explosion_p2_y = player_p2.y

					p2_screenshake_on = true
					sfx(11)
 				end
			end

			if p3_active then
 				if enemy_array[enemy_move_index]:collide(player_p3) then
 					p3_active = false
 					explosion_p3_x = player_p3.x
 					explosion_p3_y = player_p3.y

					p3_screenshake_on = true
					sfx(11)
 				end
			end

			if p4_active then
 				if enemy_array[enemy_move_index]:collide(player_p4) then
 					p4_active = false
 					explosion_p4_x = player_p4.x
 					explosion_p4_y = player_p4.y

					p4_screenshake_on = true
					sfx(11)
 				end
 			end
 		else
 			enemy_array[enemy_move_index] = nil

			if gameplay_steps == 1 then
				gameplay_steps += 1
			end
 		end
 	end

 	enemy_move_index += 1
 end

 money_move_index = 0

 while money_move_index <= money_array_index do
	 if money_array[money_move_index] != nil then
		 if money_array[money_move_index].y < 127 then
			 money_array[money_move_index].y += money_array[money_move_index].speed

			if money_array[money_move_index] != nil then
			 if money_array[money_move_index]:collide(player_p1) then

				sfx(flr(rnd(3)+6))

				 if money_array[money_move_index].sprite == 96 then
				 	player_p1.score += 50
					p1_money_flash = true
				 else
					player_p1.score += 5
				 end

				 p1_score_move_step = 5

				 money_array[money_move_index] = nil

				 if gameplay_steps == 2 then
						gameplay_steps += 1
				 end
			 end
			end

			 if p2_active and money_array[money_move_index] != nil then
				 if money_array[money_move_index]:collide(player_p2) then
						sfx(flr(rnd(3)+6))
					 if money_array[money_move_index].sprite == 128 then
					 	player_p2.score += 50
						p2_money_flash = true
					 else
						player_p2.score += 5
					 end

					 p2_score_move_step = 5

					 money_array[money_move_index] = nil

					 if gameplay_steps == 2 then
  						gameplay_steps += 1
  				 end
				 end
			 end


			 if p3_active  and money_array[money_move_index] != nil then
				 if money_array[money_move_index]:collide(player_p3) then
						sfx(flr(rnd(3)+6))
					 if money_array[money_move_index].sprite == 112 then
					 	player_p3.score += 50
						p3_money_flash = true
					 else
						player_p3.score += 5
					 end

					 p3_score_move_step = 5

					 money_array[money_move_index] = nil

					 if gameplay_steps == 2 then
  						gameplay_steps += 1
  				 end

				 end
       end



			if p4_active and money_array[money_move_index] != nil then
				 if money_array[money_move_index]:collide(player_p4) then
						sfx(flr(rnd(3)+6))
					 if money_array[money_move_index].sprite == 144 then
					  player_p4.score += 50
						p4_money_flash = true
					 else
					  player_p4.score += 5
					 end

					p4_score_move_step = 5

					 money_array[money_move_index] = nil

					 if gameplay_steps == 2 then
  						gameplay_steps += 1
  				 end
				 end
			 end
		 else
			 money_array[money_move_index] = nil

			 if gameplay_steps == 2 then
				 gameplay_steps += 1
			 end
		 end
	 end

	 money_move_index += 1
 end

 if p1_score_move_step > 0 then
	 p1_score_move_step -= 1
 end

 if p2_score_move_step > 0 then
	 p2_score_move_step -= 1
 end

 if p3_score_move_step > 0 then
	 p3_score_move_step -= 1
 end

 if p4_score_move_step > 0 then
	 p4_score_move_step -= 1
 end

 if p1_only == false then
	 if p1_active == true and p2_active == false and p3_active == false and p4_active == false then
		 player_winner = 1
		 	save_score(player_p1.score)
			save_winner_name(player_winner)
			save_winner_color(player_winner)
		if explosion_p2_y >= 150 and explosion_p3_y >= 150 and explosion_p4_y >= 150 then
			game_step += 1
			sfx(9)
		end
	 elseif p1_active == false and p2_active == true and p3_active == false and p4_active == false then
		 player_winner = 2
		 	save_score(player_p2.score)
			save_winner_name(player_winner)
			save_winner_color(player_winner)
		 if explosion_p1_y >= 150 and explosion_p3_y >= 150 and explosion_p4_y >= 150 then
 			game_step += 1
 		end
	 elseif p1_active == false and p2_active == false and p3_active == true and p4_active == false then
		 player_winner = 3
		 	save_score(player_p3.score)
			save_winner_name(player_winner)
			save_winner_color(player_winner)
		 if explosion_p1_y >= 150 and explosion_p2_y >= 150 and explosion_p4_y >= 150 then
 			game_step += 1
 		end
	 elseif p1_active == false and p2_active == false and p3_active == false and p4_active == true then
		 player_winner = 4
		 	save_score(player_p4.score)
			save_winner_name(player_winner)
			save_winner_color(player_winner)
		 if explosion_p1_y >= 150 and explosion_p2_y >= 150 and explosion_p3_y >= 150 then
 			game_step += 1
 		 end
	 elseif p1_active == false and p2_active == false and p3_active == false and p4_active == false then
			player_winner = 0
			if explosion_p1_y >= 150 and explosion_p2_y >= 150 and explosion_p3_y >= 150 and explosion_p4_y >= 150 then
  			game_step += 1
  		end
	 end
 else
	if p1_active == false then
		player_winner = 1
		if player_p1.score > load_score_single() then
		 save_score_single(player_p1.score)
		 save_winner_name_single(player_winner)
		 save_winner_color_single(player_winner)
		end
		if explosion_p1_y >= 150 then
			game_step += 1
		end
	end
 end

		if gameplay_steps == 0 then
			if p1_active then
				if player_p1.y > 90 then
					player_p1.y -= 1
					players_ready = false
				else
					players_ready = true
				end
			end

			if p2_active then
				if player_p2.y > 90 then
					player_p2.y -= 1
					players_ready = false
				else
					players_ready = true
				end
			end

			if p3_active then
				if player_p3.y > 90 then
					player_p3.y -= 1
					players_ready = false
				else
					players_ready = true
				end
			end

			if p4_active then
				if player_p4.y > 90 then
					player_p4.y -= 1
					players_ready = false
				else
					players_ready = true
				end
			end

			if players_ready == true then
				gameplay_steps += 1
			end

		elseif gameplay_steps == 1 then
			if new_enemy_tutorial then
				enemy_type = flr(rnd(3))

				enemy_create_index = 0

				while enemy_array[enemy_create_index] != nil do
					enemy_create_index += 1
				end

				enemy_create(enemy_create_index)

				new_enemy_tutorial = false
			end



		elseif gameplay_steps == 2 then
			if new_money_tutorial then
				money_type = flr(rnd(4))

				money_create_index = 0

				while money_array[money_create_index] != nil do
					money_create_index += 1
				end

				money_create(money_create_index)

				new_money_tutorial = false
			end
		elseif gameplay_steps == 3 then
			if tutorial_timer then

				last_int = 0

				add_timer(
						"timer_partenza",
						3,
						function(dt, elapsed, length)
							local i = flr(elapsed)
							if i > last_int then
								last_int = i
							end
						end,
						function()
							gameplay_steps += 1
						end
					)

				tutorial_timer = false
			end
		elseif gameplay_steps == 4 then
		elseif gameplay_steps == 5 then

		if event_running == false then
		 	if enemy_new then
		 		enemy_type = flr(rnd(3))

		 		enemy_create_index = 0

		 		while enemy_array[enemy_create_index] != nil do
		 			enemy_create_index += 1
		 		end


		 		last_int = 0

		 		add_timer(
		 					"timer_en",
		 					rnd(enemy_timer)+1,
		 					function(dt, elapsed, length)
		 						local i = flr(elapsed)
		 						if i > last_int then
		 							last_int = i
		 						end
		 					end,
		 					function()
								enemy_create(enemy_create_index)
		 						enemy_new = true
		 					end
		 				)

		 		enemy_new = false
			end
		else
			event_run(event_type)
		end

		if money_new then
			money_type = flr(rnd(4))

			money_create_index = 0

			while money_array[money_create_index] != nil do
				money_create_index += 1
			end

	 		last_int_money = 0

	 		add_timer(
	 					"timer_mo",
	 					rnd(money_timer)+1,
	 					function(dt, elapsed, length)
	 						local i = flr(elapsed)
	 						if i > last_int_money then
	 							last_int_money = i
	 						end
	 					end,
	 					function()
							money_create(money_create_index)
	 						money_new = true
	 					end
	 				)

			money_new = false
		end

		if event_new then

			event_text_count = 0

			last_int_event = 0

	 		add_timer(
	 					"timer_ev",
	 					5,
	 					function(dt, elapsed, length)
	 						local i = flr(elapsed)
	 						if i > last_int_event then
	 							last_int_event = i
	 						end
	 					end,
	 					function()
							event_type = flr(rnd(2))
							event_running = true
							event_timer_finish_on = true
	 					end
	 				)

			event_new = false
		end
	end

	elseif game_step == 4 then
	elseif game_step == 5 then
		if timer_winner then

			sfx(9)

			last_int = 0

	 		add_timer(
	 					"timer_win",
	 					5,
	 					function(dt, elapsed, length)
	 						local i = flr(elapsed)
	 						if i > last_int then
	 							last_int = i
	 						end
	 					end,
	 					function()
							game_step += 1
	 					end
	 				)

			timer_winner = false
		end
	end
end

function _draw()
	if game_step == 0 then
		if menu_steps == 0 then
 		spr(162, title_x, title_y, 127, 32)
		spr(209, title_x-7, title_y+25, 127, 32)
 	elseif menu_steps == 1 then
			rectfill(0, 0, 128, 128, 7)
			menu_steps += 1
		elseif menu_steps == 3 then
			cls(1)
		 space_effect()

			title_move()

		 title_text_flash("press ” to start", hcenter("press ” to start")-4, 95, 8)

			print("made by eternium galaxy", 21, 5, 8)

			if load_score_single() != 0 or load_score() != 0 then
				print("press ƒ to reset your data", hcenter("press ƒ to reset your data")-3, 113, 5)
			end

			if load_score_single() != 0 then
				print("solo best: ", 27, 70, 7)
				for k=1, 3, 1 do
					print(array_letters[peek(0x5e12+k)], 68+(k*5), 70, peek(0x5e16))
				end
				print(load_score_single(), 90, 70, 7)
			end

			if load_score() != 0 then
				print("multi best: ", 27, 80, 7)
				for k=1, 3, 1 do
					print(array_letters[peek(0x5e03+k)], 68+(k*5), 80, peek(0x5e07))
				end
				print(load_score(), 90, 80, 7)
			end

		elseif menu_steps == 4 then

			trans_maze_run()

			sfx(5)

			music(-1, 500)

			menu_steps += 1

		end
 elseif game_step == 1 then

		if trans_maze_on == false then
	 	cls(1)

			print("join the adventure!", 27, 7, 8)
				if p1_name_count < 3 then
					print("p1 online!", 20, 20, 8)
					print("‹ ", 20, 30, 7)
					print(array_letters[p1_active_char], 32, 30, 8)
					print(" ‘", 36, 30, 7)

					if p1_char_pos_x > 40 then
						if p1_char_pos_steps_x > 0 then
							p1_char_pos_steps_x -= 0.1
						else
							p1_char_pos_steps_x = 0
							print("ƒ", 30, 40, 7)
						end
					end
				else
					print("p1 ready!", 20, 20, 10)

					if p1_char_pos_x > 31 then
							p1_char_pos_steps_x = -1
					else
							if p1_char_pos_steps_x < 0 then
								p1_char_pos_steps_x += 0.1
							else
								p1_char_pos_steps_x = 0
							end
					end

					if p1_char_pos_y > 33 then
						p1_char_pos_steps_y -= 0.1
					else
						if p1_char_pos_steps_y > 0 then
							p1_char_pos_steps_y -= 0.1
						else
							p1_char_pos_steps_y = 0
						end
					end
				end
				print(p1_name, 28, 50, 8)

				spr(0, p1_char_pos_x, p1_char_pos_y, 2, 2)

				p1_char_pos_x += p1_char_pos_steps_x
				p1_char_pos_y += p1_char_pos_steps_y

			if p2_active then
				if p2_name_count < 3 then
					print("p2 online!", 70, 20, 11)
					print("s ", 70, 30, 7)
					print(array_letters[p2_active_char], 78, 30, 11)
					print(" f", 82, 30, 7)

					if p2_char_pos_x < 95 then
						if p2_char_pos_steps_x < 0 then
							p2_char_pos_steps_x += 0.1
						else
							p2_char_pos_steps_x = 0
							print("d", 78, 40, 7)
						end
					end
				else
					print("p2 ready!", 70, 20, 10)

					if p2_char_pos_x > 77 then
							p2_char_pos_steps_x = -1
					else
							if p2_char_pos_steps_x < 0 then
								p2_char_pos_steps_x += 0.1
							else
								p2_char_pos_steps_x = 0
							end
					end

					if p2_char_pos_y > 33 then
						p2_char_pos_steps_y -= 0.1
					else
						if p2_char_pos_steps_y > 0 then
							p2_char_pos_steps_y -= 0.1
						else
							p2_char_pos_steps_y = 0
						end
					end
				end
				print(p2_name, 74, 50, 11)

				spr(8, p2_char_pos_x, p2_char_pos_y, 2, 2)

				p2_char_pos_x += p2_char_pos_steps_x
				p2_char_pos_y += p2_char_pos_steps_y
			else
				print("p2 offline", 70, 20, 5)

				print("press 'e'", 73, 35, 11)
				print("to join!", 74, 45, 11)
			end

			if p3_active then
				if p3_name_count < 3 then
					print("p3 online!", 20, 78, 10)
					print("‹ ", 20, 88, 7)
					print(array_letters[p3_active_char], 32, 88, 10)
					print(" ‘", 36, 88, 7)

					if p3_char_pos_x > 40 then
						if p3_char_pos_steps_x > 0 then
							p3_char_pos_steps_x -= 0.1
						else
							p3_char_pos_steps_x = 0
							print("ƒ", 30, 98, 7)
						end
					end
				else
					print("p3 ready!", 20, 78, 10)

					if p3_char_pos_x > 31 then
							p3_char_pos_steps_x = -1
					else
							if p3_char_pos_steps_x < 0 then
								p3_char_pos_steps_x += 0.1
							else
								p3_char_pos_steps_x = 0
							end
					end

					if p3_char_pos_y > 90 then
						p3_char_pos_steps_y -= 0.1
					else
						if p3_char_pos_steps_y > 0 then
							p3_char_pos_steps_y -= 0.1
						else
							p3_char_pos_steps_y = 0
						end
					end
				end
				print(p3_name, 28, 107, 10)

				spr(32, p3_char_pos_x, p3_char_pos_y, 2, 2)

				p3_char_pos_x += p3_char_pos_steps_x
				p3_char_pos_y += p3_char_pos_steps_y
			else
				print("p3 offline", 20, 78, 5)

				print("press '”'", 23, 93, 10)
				print("to join!", 24, 103, 10)
			end

			if p4_active then
				if p4_name_count < 3 then
					print("p4 online!", 70, 78, 2)
					print("‹ ", 70, 88, 7)
					print(array_letters[p4_active_char], 82, 88, 2)
					print(" ‘", 86, 88, 7)

					if p4_char_pos_x < 95 then
						if p4_char_pos_steps_x < 0 then
							p4_char_pos_steps_x += 0.1
						else
							p4_char_pos_steps_x = 0
							print("ƒ", 80, 98, 7)
						end
					end
				else
					print("p4 ready!", 70, 78, 10)

					if p4_char_pos_x > 77 then
							p4_char_pos_steps_x = -1
					else
							if p4_char_pos_steps_x < 0 then
								p4_char_pos_steps_x += 0.1
							else
								p4_char_pos_steps_x = 0
							end
					end

					if p4_char_pos_y > 90 then
						p4_char_pos_steps_y -= 0.1
					else
						if p4_char_pos_steps_y > 0 then
							p4_char_pos_steps_y -= 0.1
						else
							p4_char_pos_steps_y = 0
						end
					end
				end
				print(p4_name, 74, 107, 2)

				spr(40, p4_char_pos_x, p4_char_pos_y, 2, 2)

				p4_char_pos_x += p4_char_pos_steps_x
				p4_char_pos_y += p4_char_pos_steps_y
			else
				print("p4 offline", 70, 78, 5)

				print("press '”'", 73, 93, 2)
				print("to join!", 74, 103, 2)
			end

			if p1_name_count >= 3 or p2_name_count >= 3 or p3_name_count >= 3 or p4_name_count >= 3 then
				if p_select_timer == 0 then
					print(5, p_select_timer_pos_x_5, 64, 8)

					if p_select_timer_pos_x_5 > 64 then
						p_select_timer_pos_x_5 += p_select_timer_pos_steps_5
					end
				elseif p_select_timer == 1 then
					print(4, p_select_timer_pos_x_4, 64, 8)

					if p_select_timer_pos_x_4 < 64 then
						p_select_timer_pos_x_4 += p_select_timer_pos_steps_4
					end
				elseif p_select_timer == 2 then
					print(3, 64, p_select_timer_pos_y_3, 8)

					if p_select_timer_pos_y_3 < 64 then
						p_select_timer_pos_y_3 += p_select_timer_pos_steps_3
					end
				elseif p_select_timer == 3 then
					print(2, 64, p_select_timer_pos_y_2, 8)

					if p_select_timer_pos_y_2 > 64 then
						p_select_timer_pos_y_2 += p_select_timer_pos_steps_2
					end
				elseif p_select_timer == 4 then
					print(1, p_select_timer_pos_x_1, 64, 8)

					if p_select_timer_pos_x_1 < 64 then
						p_select_timer_pos_x_1 += p_select_timer_pos_steps_1
					end
				end

			end
		end
	elseif game_step == 3 then

			if gameplay_steps < 5 then
				cls()
			else
				cls(1)
			end
			 if gameplay_steps == 1 and enemy_array[0] != nil then
				 title_text_flash("avoid these!", 45, 64, 10)
			 end

			 if gameplay_steps == 2 and money_array[0] != nil then
				title_text_flash("collect these!", 40, 64, 10)
			 end

			if gameplay_steps == 3 then
				print("now you are ready...", 25, 64, 7)
			end

			if gameplay_steps == 4 then
				rectfill(0, 0, 127, 127, 7)

				make_starfield_ps()

				gameplay_steps += 1
			end

			for ps in all(particle_systems) do
				draw_ps(ps)
			end

			if p1_active then

				if p1_money_flash then
					if p1_flash_count % 2 == 0 then
						spr(0, player_p1.x, player_p1.y, 2, 2)
					else
						spr(70, player_p1.x, player_p1.y, 2, 2)
					end

					if p1_money_timer then

						last_int_p1_flash_timer = 0

				 		add_timer(
				   				"timer_p1_flash",
				   				0.2,
				   				function(dt, elapsed, length)
				   					local i = flr(elapsed)
				   					if i > last_int_p1_flash_timer then
				   						last_int_p1_flash_timer = i
				   					end
				   				end,
				   				function()
										if p1_flash_count < 10 then
											p1_flash_count += 1
											p1_money_timer = true
										else
											p1_money_flash = false
											p1_money_timer = true
											p1_flash_count = 0
										end
				   				end
				   			)

						p1_money_timer = false
					end
				else
					if btn(0, 0) or btn(1, 0) or btn(2, 0) or btn(3, 0) then
						animator(player_p1, 0, 8, 2, false, 16)
					else
						player_p1.a_ct = 0
						player_p1.a_st = 0
						spr(0, player_p1.x, player_p1.y, 2, 2)
					end
				end

				print(p1_name, 0, 0, 7)
				print(tostr(player_p1.score), 0+p1_score_move_step, 5, 8)

			end

			if p2_active then
				if p2_money_flash then
					if p2_flash_count % 2 == 0 then
						spr(8, player_p2.x, player_p2.y, 2, 2)
					else
						spr(66, player_p2.x, player_p2.y, 2, 2)
					end

					if p2_money_timer then

						last_int_p2_flash_timer = 0

				 		add_timer(
				   				"timer_p2_flash",
				   				0.2,
				   				function(dt, elapsed, length)
				   					local i = flr(elapsed)
				   					if i > last_int_p2_flash_timer then
				   						last_int_p2_flash_timer = i
				   					end
				   				end,
				   				function()
										if p2_flash_count < 10 then
											p2_flash_count += 1
											p2_money_timer = true
										else
											p2_money_flash = false
											p2_money_timer = true
											p2_flash_count = 0
										end
				   				end
				   			)

						p2_money_timer = false
					end
				else
					if btn(0, 1) or btn(1, 1) or btn(2, 1) or btn(3, 1) then
						animator(player_p2, 8, 8, 2, false, 16)
					else
						player_p2.a_ct = 0
						player_p2.a_st = 0
						spr(8, player_p2.x, player_p2.y, 2, 2)
					end
				end

				print(p2_name, 115, 0, 7)
				if player_p2.score < 1000 then
					print(tostr(player_p2.score), 115+p2_score_move_step, 5, 11)
				else
					print(tostr(player_p2.score), 112+p2_score_move_step, 5, 11)
				end

			end

			if p3_active then
				if p3_money_flash then
					if p3_flash_count % 2 == 0 then
						spr(32, player_p3.x, player_p3.y, 2, 2)
					else
						spr(68, player_p3.x, player_p3.y, 2, 2)
					end

					if p3_money_timer then

						last_int_p3_flash_timer = 0

				 		add_timer(
				   				"timer_p3_flash",
				   				0.2,
				   				function(dt, elapsed, length)
				   					local i = flr(elapsed)
				   					if i > last_int_p3_flash_timer then
				   						last_int_p3_flash_timer = i
				   					end
				   				end,
				   				function()
										if p3_flash_count < 10 then
											p3_flash_count += 1
											p3_money_timer = true
										else
											p3_money_flash = false
											p3_money_timer = true
											p3_flash_count = 0
										end
				   				end
				   			)

						p3_money_timer = false
					end
				else
					if btn(0, 2) or btn(1, 2) or btn(2, 2) or btn(3, 2) then
						animator(player_p3, 32, 8, 2, false, 16)
					else
						player_p3.a_ct = 0
						player_p3.a_st = 0
						spr(32, player_p3.x, player_p3.y, 2, 2)
					end
				end

				print(p3_name, 0, 115, 7)
				print(tostr(player_p3.score), 0+p3_score_move_step, 120, 10)

			end

			if p4_active then
				if p4_money_flash then
					if p4_flash_count % 2 == 0 then
						spr(40, player_p4.x, player_p4.y, 2, 2)
					else
						spr(64, player_p4.x, player_p4.y, 2, 2)
					end

					if p4_money_timer then

						last_int_p4_flash_timer = 0

				 		add_timer(
				   				"timer_p4_flash",
				   				0.2,
				   				function(dt, elapsed, length)
				   					local i = flr(elapsed)
				   					if i > last_int_p4_flash_timer then
				   						last_int_p4_flash_timer = i
				   					end
				   				end,
				   				function()
										if p4_flash_count < 10 then
											p4_flash_count += 1
											p4_money_timer = true
										else
											p4_money_flash = false
											p4_money_timer = true
											p4_flash_count = 0
										end
				   				end
				   			)

						p4_money_timer = false
					end
				else
					if btn(0, 3) or btn(1, 3) or btn(2, 3) or btn(3, 3) then
						animator(player_p4, 40, 8, 2, false, 16)
					else
						player_p4.a_ct = 0
						player_p4.a_st = 0
						spr(40, player_p4.x, player_p4.y, 2, 2)
					end
				end

				print(p4_name, 115, 115, 7)
				if player_p4.score < 1000 then
					print(tostr(player_p4.score), 115+p4_score_move_step, 120, 2)
				else
					print(tostr(player_p4.score), 112+p4_score_move_step, 120, 2)
				end

			end

			if event_running then
				if event_text_count == 0 then
					sfx(10)
				end

				if event_type == 0 then
						if event_text_count % 5 == 0 then
							print("asteroids storm!", 135-event_text_count, 64, 8)
						else
							print("asteroids storm!", 135-event_text_count, 64, 7)
						end

						event_text_count+=1
				elseif event_type == 1 then
						if event_text_count % 5 == 0 then
							print("money fever!", 135-event_text_count, 64, 8)
						else
							print("money fever!", 135-event_text_count, 64, 7)
						end
						event_text_count+=1
				end
			end

			enemy_vis_index = 0
			while enemy_vis_index <= enemy_array_index do
				if enemy_array[enemy_vis_index] != nil then

					if enemy_array[enemy_vis_index].sprite == 160 or enemy_array[enemy_vis_index].sprite == 176 or enemy_array[enemy_vis_index].sprite == 192 then
						animator(enemy_array[enemy_vis_index], enemy_array[enemy_vis_index].sprite, 2, 5, false, 8)
					elseif enemy_array[enemy_vis_index].sprite == 99 then
						animator(enemy_array[enemy_vis_index], enemy_array[enemy_vis_index].sprite, 4, 5, false, 16)
					elseif enemy_array[enemy_vis_index].sprite == 131 then
						animator(enemy_array[enemy_vis_index], enemy_array[enemy_vis_index].sprite, 8, 5, false, 32)
					end
				end

				enemy_vis_index += 1
			end

			money_vis_index = 0
			while money_vis_index <= money_array_index do
				if money_array[money_vis_index] != nil then

					animator(money_array[money_vis_index], money_array[money_vis_index].sprite, 3, 3, false, 8)
				end

				money_vis_index += 1
			end

			if p1_active == false and player_p1 != nil then
				make_explosion_ps(explosion_p1_x,explosion_p1_y)
				player_p1.x = 140
				if explosion_p1_y < 150 then
					explosion_p1_y += 2
				end
			end

			if p2_active == false and player_p2 != nil then
				make_explosion_ps(explosion_p2_x,explosion_p2_y)
				player_p2.x = 140
				if explosion_p2_y < 150 then
					explosion_p2_y += 2
				end
			end

			if p3_active == false and player_p3 != nil  then
				make_explosion_ps(explosion_p3_x,explosion_p3_y)
				player_p3.x = 140
				if explosion_p3_y < 150 then
					explosion_p3_y += 2
				end
			end

			if p4_active == false and player_p4 != nil  then
				make_explosion_ps(explosion_p4_x,explosion_p4_y)
				player_p4.x = 140
				if explosion_p4_y < 150 then
					explosion_p4_y += 2
				end
			end


	elseif game_step == 4 then
		rectfill(0, 0, 127, 127, 7)
		game_step += 1
	elseif game_step == 5 then
		cls(1)

			if player_winner != 0 then
				print(" found the purpose of", 28, 50, 7)
				print(" stars", 53, 77, 14)
			end

			if player_winner == 1 then
				print(p1_name, 16, 50, 8)
				print(player_p1.score, 64, 64, 14)
			elseif player_winner == 2 then
				print(p2_name, 16, 50, 11)
				print(player_p2.score, 64, 64, 14)
			elseif player_winner == 3 then
				print(p3_name, 16, 50, 10)
				print(player_p3.score, 64, 64, 14)
			elseif player_winner == 4 then
				print(p4_name, 16, 50, 2)
				print(player_p4.score, 64, 64, 14)
			else
				print("nobody found", 40, 50, 7)
				print("the purpose of", 35, 64, 7)
				print("the stars", 44, 78, 7)
			end
	elseif game_step == 6 then
		rectfill(0, 0, 127, 127, 7)
		game_step += 1
	elseif game_step == 7 then
		_init()
end

	if trans_maze_on then

		if trans_timer then

			last_int = 0

 		add_timer(
   				"timer_trans",
   				0.21,
   				function(dt, elapsed, length)
   					local i = flr(elapsed)
   					if i > last_int then
   						sfx(4)
   						last_int = i
   					end
   				end,
   				function()
						trans_maze_on = false
   					game_step += 1
   				end
   			)

   trans_timer = false
  end

		trans_maze()
	end

	if p1_screenshake_on then
		p1_camera_screenshake()
	end

	if p2_screenshake_on then
		p2_camera_screenshake()
	end

	if p3_screenshake_on then
		p3_camera_screenshake()
	end

	if p4_screenshake_on then
		p4_camera_screenshake()
	end


end
__gfx__
00000668866000000000066886600000000006688660000000000668866000000000066bb66000000000066bb66000000000066bb66000000000066bb6600000
0000d668866d00000000d668866d00000000d668866d00000000d668866d00000000d66bb66d00000000d66bb66d00000000d66bb66d00000000d66bb66d0000
000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000
00086dffffd6800000086dffffd6800000086dffffd6800000086dffffd68000000b6dffffd6b000000b6dffffd6b000000b6dffffd6b000000b6dffffd6b000
000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000
0000deffffed00000000deffffed00000000deffffed00000000deffffed00000000deffffed00000000deffffed00000000deffffed00000000deffffed0000
00000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd00000
00006d6566d6000000006d6566d6000000006d6566d6000000006d6566d6000000006d6566d6000000006d6566d6000000006d6566d6000000006d6566d60000
00006665666600000000666566660000000066656666000000006665666600000000666566660000000066656666000000006665666600000000666566660000
00008666566800000000866656680000000086665668000000008666566800000000b666566b00000000b666566b00000000b666566b00000000b666566b0000
00000666566000000000066656600000000006665660000000000666566000000000066656600000000006665660000000000666566000000000066656600000
00000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d00000
000000d00d000000000000d00d000000000000d00d000000000000d00d000000000000d00d000000000000d00d000000000000d00d000000000000d00d000000
00000000000000000000008008000000000000800800000000000080080000000000000000000000000000b00b000000000000b00b000000000000b00b000000
000000000000000000000000000000000000008008000000000000800800000000000000000000000000000000000000000000b00b000000000000b00b000000
0000000000000000000000000000000000000000000000000000008008000000000000000000000000000000000000000000000000000000000000b00b000000
0000066aa66000000000066aa66000000000066aa66000000000066aa66000000000066226600000000006622660000000000662266000000000066226600000
0000d66aa66d00000000d66aa66d00000000d66aa66d00000000d66aa66d00000000d662266d00000000d662266d00000000d662266d00000000d662266d0000
000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000000d66dddd66d000
000a6dffffd6a000000a6dffffd6a000000a6dffffd6a000000a6dffffd6a00000026dffffd6200000026dffffd6200000026dffffd6200000026dffffd62000
000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000000d6f5ff5f6d000
0000deffffed00000000deffffed00000000deffffed00000000deffffed00000000deffffed00000000deffffed00000000deffffed00000000deffffed0000
00000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd0000000000ddd5dd00000
00006d6566d6000000006d6566d6000000006d6566d6000000006d6566d6000000006d6566d6000000006d6566d6000000006d6566d6000000006d6566d60000
00006665666600000000666566660000000066656666000000006665666600000000666566660000000066656666000000006665666600000000666566660000
0000a666566a00000000a666566a00000000a666566a00000000a666566a00000000266656620000000026665662000000002666566200000000266656620000
00000666566000000000066656600000000006665660000000000666566000000000066656600000000006665660000000000666566000000000066656600000
00000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d0000000000d6dd6d00000
000000d00d000000000000d00d000000000000d00d000000000000d00d000000000000d00d000000000000d00d000000000000d00d000000000000d00d000000
0000000000000000000000a00a000000000000a00a000000000000a00a0000000000000000000000000000200200000000000020020000000000002002000000
00000000000000000000000000000000000000a00a000000000000a00a0000000000000000000000000000000000000000000020020000000000002002000000
000000000000000000000000000000000000000000000000000000a00a0000000000000000000000000000000000000000000000000000000000002002000000
00002662266200000000b66bb66b00000000a66aa66a000000008668866800000000000000000000000000000000000000000000000000000000000000000000
0002d662266d2000000bd66bb66db000000ad66aa66da0000008d668866d80000000000000000000000000000000000000000000000000000000000000000000
002d66dddd66d20000bd66dddd66db0000ad66dddd66da00008d66dddd66d8000000000000000000000000000000000000000000000000000000000000000000
00226dffffd6220000bb6dffffd6bb0000aa6dffffd6aa0000886dffffd688000000000000000000000000000000000000000000000000000000000000000000
002d6f5ff5f6d20000bd6f5ff5f6db0000ad6f5ff5f6da00008d6f5ff5f6d8000000000000000000000000000000000000000000000000000000000000000000
0002deffffed2000000bdeffffedb000000adeffffeda0000008deffffed80000000000000000000000000000000000000000000000000000000000000000000
00002ddd5dd200000000bddd5ddb00000000addd5dda000000008ddd5dd800000000000000000000000000000000000000000000000000000000000000000000
00026d6566d62000000b6d6566d6b000000a6d6566d6a00000086d6566d680000000000000000000000000000000000000000000000000000000000000000000
0002666566662000000b66656666b000000a66656666a00000086665666680000000000000000000000000000000000000000000000000000000000000000000
0002266656622000000bb666566bb000000aa666566aa00000088666566880000000000000000000000000000000000000000000000000000000000000000000
00002666566200000000b666566b00000000a666566a000000008666566800000000000000000000000000000000000000000000000000000000000000000000
00002d6dd6d200000000bd6dd6db00000000ad6dd6da000000008d6dd6d800000000000000000000000000000000000000000000000000000000000000000000
000002d22d20000000000bdbbdb0000000000adaada00000000008d88d8000000000000000000000000000000000000000000000000000000000000000000000
0000002002000000000000b00b000000000000a00a00000000000080080000000000000000000000000000000000000000000000000000000000000000000000
0000002002000000000000b00b000000000000a00a00000000000080080000000000000000000000000000000000000000000000000000000000000000000000
0000002002000000000000b00b000000000000a00a00000000000080080000000000000000000000000000000000000000000000000000000000000000000000
0008700000078000000880000000000005005d500000777007075d57000000000000000000000000000000000000000000000000000000000000000000000000
000870000007800000088000000055d00005d5d5007755d70075d5d5000000000000000000000000000000000000000000000000000000000000000000000000
00888700007778000088880000555dd500075d7007555dd570075d77000000000000000000000000000000000000000000000000000000000000000000000000
0088870000877800008888000055ddd7000057700755ddd770075770000000000000000000000000000000000000000000000000000000000000000000000000
088888700887788007888880055d5ddd70000000755d5ddd70007000000000000000000000000000000000000000000000000000000000000000000000000000
08888870088877800778888005d5ddd57000000575d5ddd570070007000000000000000000000000000000000000000000000000000000000000000000000000
888887778888778887788888055d5d5d50057000755d5d5d70757700000000000000000000000000000000000000000000000000000000000000000000000000
08787770088887700877888005d5d5d0005d550075d5d5d7075d5570000000000000000000000000000000000000000000000000000000000000000000000000
000a70000007a000000aa00000555500005557000755557007555700000000000000000000000000000000000000000000000000000000000000000000000000
000a70000007a000000aa00000000005000007000077770700777700000000000000000000000000000000000000000000000000000000000000000000000000
00aaa70000777a0000aaaa0000500000000000000757700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa70000a77a0000aaaa0005d570000000000075d5770000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaa700aa77aa007aaaaa0055d5d0000050000755d5d7000070000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaa700aaa77a0077aaaa00055d700000000000755d70000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaa777aaaa77aaa77aaaaa005d570000000000075d570000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a7a77700aaaa7700a77aaa05005d000000000007075d70000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b70000007b000000bb00000000000000000001ddd111111000007000000000000000077777777770000070000000000000000000000000000000000000000
000b70000007b000000bb0000000000700000011d1177dddd11107000000000700000077d117777dd17707000000000000000000000000000000000000000000
00bbb70000777b0000bbbb0000000000000011dd1111d1ddd711100000000000000077dd1111d1ddd71170000000000000000000000000000000000000000000
00bbb70000b77b0000bbbb00000000000111171151515d1ddd711100000000000777171151515d1ddd7117000000000000000000000000000000000000000000
0bbbbb700bb77bb007bbbbb00000000111dd1111151515d1ddd711100000000771dd1111151515d1ddd711700000000000000000000000000000000000000000
0bbbbb700bbb77b0077bbbb0000001117dd111155555515d1ddd7111000007717dd111155555515d1ddd71170000000000000000000000000000000000000000
bbbbb777bbbb77bbb77bbbbb07001117dd151555555555d1d1dd711007007117dd151555555555d1d1dd71700000000000000000000000000000000000000000
0b7b77700bbbb7700b77bbb00001117dd1d155555555515d71dd11000007117dd1d155555555515d71dd17000000000000000000000000000000000000000000
000270000007200000022000001d17dd1d151555551515d1ddd11000007d17dd1d151555551515d1ddd170000000000000000000000000000000000000000000
00027000000720000002200001d1ddd1d1d155555151111ddd11000007d1ddd1d1d155555151111ddd1700000000000000000000000000000000000000000000
00222700007772000022220011d11ddd1d1d15151511dd1dd110000071d11ddd1d1d15151511dd1dd77000000000000000000000000000000000000000000000
002227000027720000222200011d11ddd1d1d1d1111d111110000000071d11ddd1d1d1d1111d1177700000000000000000000000000000000000000000000000
0222227002277220072222200011d11ddddd1d1dddd11100000000000077d11ddddd1d1dddd17700000000000000000000000000000000000000000000000000
02222270022277200772222000001dd1111ddddd1111000000000070000077d1111ddddd11770000000000700000000000000000000000000000000000000000
22222777222277222772222200000011111111111100700000000000000000771111111177007000000000000000000000000000000000000000000000000000
02727770022227700277222070000000171ddd110000000000000000700000007777777700000000000000000000000000000000000000000000000000000000
05d70000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d5d70007d5d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55ddd77075ddd7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d5dddd07d5ddd700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55d5ddd775d5ddd70000000000077777700000077777700007777770077777777777777777777000077777777777770000000007777777777777777700000000
5d5d5d5d7d5d5d5700000000007888887770007ddddd77707ddddd7777ddddddddddddddddddd77007dddddddddddd770000077dddddddddddddddd777000000
05d5d55507d5d57700000000007888887770007ddddd77707888dd77707888888dddddddddddd77707888888ddddddd770000788888888888dddddd777777000
005555000077770000000000007888887770007ddddd77707888dd77777888888dddddddddddd777078888888ddddddd77000788888888888ddddd7777000000
00777d00007777000000000007888888877707ddddd77777888dd7777007888888dddddddddddd77788888877ddddddd7770078888888888dddddd7777777777
07ddd57507ddd5770000000007888888887707ddddd77707888dd7770007888888dddddddddddd777888887777dddddd7770078888888888dddddd7770000000
7ddddd557ddddd570000000007888888887777ddddd77707888dd7770000778888ddd7777777777778888777707ddddd7770788888877788dddddd7770000000
55d5d5d575d5d5d70000000007888888887777ddddd77707888dd7777777707888dd77777777777788888777007ddddd777078888877777dddddd77770000000
5d5d5d557d5d5d570000000078888888888777dddd77777888dd7777000007888dd77770000000078888877707dddddd777078888877707dddddd77777700000
55d5d55575d5d557000000007888888888887ddddd77707888dd7777777777888dd7777777777007888888777dddddd7777078888877707dddddd77700000000
5555555575555557000000007888888888888ddddd77707888dd7770000007888dd77700000000788888888dddddddd777078888877777ddddddd77700000000
05555550077777700000000788888d7d8888ddddd77777888dd7777000007888dd77770000000078888888dddddddd7777078888877707dddddd777777777777
0000070000000700000000078888d777d88dddddd77707888dd7770000007888dd7770000000007888888dddd777777770078888877707dddddd777000000000
000075d000007570000000078888d777ddddddddd77707888dd7777777777888dd77777777000788888dddddd777777700078888877707dddddd777000000000
0007dd550007dd57000000078888d7777dddddddd77707888dd7770000007888dd7770000000078888d777ddddd770000078888888777dddddd7777777700000
00ddd5d5007dd5d700000078888d77777ddddddd77777888dd7777777777888dd77777777777778888d7777dddd77777707888888888ddddddd7770000000000
07dd5d5507dd5d5700000078888d777007dddddd77707888dd7770000007888dd7770000000078888d77777dddd77700007888888888ddddddd7777777777700
75d5d55075d5d57000000078888d777007dddddd77707888dd7770000007888dd7770000000078888d777007dddd7700007888888888ddddddd7770000000000
555d5d50755d5d7000000078888d777777dddddd77707888dd7777777777888dd7777770000078888d777007dddd777007d8888888888ddddd77770000000000
0555550007777700000007888dd7777007ddddd77777888dd7777000007888dd7777000000078888d77770007dddd77007d8888888888ddddd77700000000000
0000000000000000000007ddddd7770007ddddd77707ddddd7777770007ddddd777000000007ddddd77700007dddd777077ddddddddddddddd77777770000000
00000000000000000000077777777700077777777707777777770000007777777770000000077777777700007777777707777777777777777777700000000000
00000000000000077777700777777777700777777777777777700000007777777707777777707777777777777777777700077777777777777777777777777700
000000000000007666667770007ddddd77707dddddddddd77700000077dddd777707dddddd777ddddddddddddddddddd77007dddddddddd77700000000000000
000000000000007666667770007ddddd7770766666ddddd77700000076666d77707ddddddd7777666666dddddddddddd7770766666ddddd77700000000000000
000000000000007666667770007ddddd7770766666ddddd77700000076666d77707dddddd77777666666dddddddddddd7770766666ddddd77777770000000000
00000000000007666666677707ddddd777776666666dddd77700000076666d77707dddddd777007666666dddddddddddd7776666666dddd77700000000000000
00000000000007666666667707ddddd777076666d76dddd77777777776666d7777ddddddd777007666666dddddddddddd7776666d76dddd77700000000000000
00000000000007666666667777ddddd77707666d777ddddd7700000766666d7777ddddddd777000777666ddd777777777777666d777ddddd7777777770000000
00000000000007666666667777dddd677707666d777ddddd777777776666677777dddddd7777777777666dd7777777777777666d777ddddd7770000000000000
00000000000076666666666777dddd77777666d77777dddd777000076666677707dddddd777000007666dd7777000000007666d77777dddd7777777777777700
0000000000007666666666667ddddd77707666d77707dddd777000076666677707dddddd777777777666dd7770000000007666d77707dddd7770000000000000
0000000000007666666666666ddddd77707666d77777dddd77700076666677777ddddddd777000007666dd7770000000007666d77777dddd7770000000000000
00000000000766666d7d6666ddddd777776666666666ddddd7777776666677707dddddd777700007666dd77770000000076666666666ddddd770000000000000
0000000000076666d777d66dddddd777076666666666ddddd7770076666677707dddddd777777777666dd77777777777776666666666ddddd777000000000000
0000000000076666d777ddddddddd7770766666dddddddddd7770076666677707dddddd777000007666dd777000000000766666dddddddddd777777777700000
0000000000076666d7777dddddddd777076666d777777dddd777076666666777dddddd7777777777666dd77777000000076666d777777dddd777000000000000
000000000076666d77777ddddddd777776666d7777777dddd77707666666666ddddddd777000007666dd77770000000076666d7777777dddd777777777777700
000000000076666d777007dddddd777076666d7770007ddddd7707666666666ddddddd777000007666dd77700000000076666d7770007ddddd77000000000000
000000000076666d777007dddddd777076666d7770007ddddd7777666666666ddddddd777777707666dd77777777777076666d7777777ddddd77700000000000
000000000076666d777777dddddd777776666d77777007dddd777d6666666666ddddd7777000007666dd77700000000076666d77700007dddd77700000000000
0000000007666dd7777007ddddd777776666d777700007dddd777d6666666666ddddd777777777666dd77777777700076666d777777777dddd77777777777777
0000000007ddddd7770007ddddd77707ddddd777000007dddd7777ddddddddddddddd777000007ddddd7770000000007ddddd777000007dddd77700000000000
00000000077777777777777777777777777777777777777777777777777777777777777700000777777777000000000777777777000007777777700000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003c60218502195521955219552195521a5521a5521b5521c552185021f552215521a500265501f5002b5501750034550375502f5003c5503d55025500295002c500315003450036500286002e6002e600
011000001a0740000000000000001d074000000000000000000000000000000000001f074210740000000000000000000000000000001f0741d0740000000000000001f074000000000000000230740000000000
010100003f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f6503f650
01100000000000000000000000000000000000000001d17100000000000000000000000001d1710000000000000001f171000000000021171000000000000000231710000000000000001a171000000000000000
0002000000000136000f7500f7500f750107500b700117500000000000137500000015750000001875000000000001b750000001f7500000023750277502e750000003575037750397503b750000000000000000
00040000000000b6500a6500a650000001865019650000001a65000000046501c6501e65000000206500000007650236500000026650046502a6502c6502e65030650356503a650246501a650166501465013650
00060000175501a5501d5502155026550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001e55022550265502b55030550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002e55031550355503a5503c550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000033750285502c5503975033550386003c7503c7003c7500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002b3542b3512b3512b3512b3552d3002c4002c4002c4002c4002b3542b3512b3512b3512b35500000000003230000000000002b3542b3512b3512b3512b355000000000000000000002b3002b3002b300
000600003d657386573465735657372573b25732257332573525738252216521f6521e65213652202521c2501a252192521825217250066500565003650036500265006250052500425003250012500125001255
000400000b4500c4500e45011450154501a45020450264502b45031450354503d4503e250392503e250392003e200000000000000000000000000000000000000000000000000000000000000000000000000000
000500000c3500d3500e3501035014350163501b3502035024350293503035034350000003b1503c1503b15000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000072500a25012250182501e25022250282502e250352503c25031250371503125037150311500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
02 01 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
