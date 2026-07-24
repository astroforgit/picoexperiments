pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- tetrachess
-- by: ville111 (5.4.2020)
-- ver 1.0.2

input_— = false
input_—_last_frame = false
input_Ž = false
input_‹ = false
input_‹_last_frame = false
input_‘ = false
input_‘_last_frame = false
input_” = false
input_”_last_frame = false
input_ƒ = false

grid_height = 16
grid_width = 8
grid_offset_x = -7+(128-8*grid_width)/3
grid = {}
current_tetrimino = {}

soft_drop = false
hard_dropping = false
timer = 0
freeze_frames = 0

move_interval = 4
freeze_delay = 0
max_freeze_delay = 20
fall_interval = 20

phase = "tetris"

king_alive = true
game_over = false

moved_piece = 0
start_x = -1
start_y = -1
target_x = -1
target_y = -1
animation_frames = 0
max_animation_frames = 15
max_freeze_frames = 15

enemy_movement_delay = 0
max_enemy_movement_delay = 20

line_numbers = {}

--pieces
-- 2 = pawn (sotilas)
-- 3 = knight (ratsu)
-- 4 = bishop (lahetti)
-- 5 = rook (torni)
-- 6 = king (kuningas)
-- 7 = queen (kuningatar)

selected_piece = {-1, -1}
reticle = {4, 11}
score = 0
promote_selection = 1
hiscore = 0
move_cooldown = 0

rubble = {}
rubble_counter = 0

bag = {}
second_bag = {}

function _init()
	cartdata("ville111_tetrachess")
	hiscore = dget(0)
	pal(14, 128+4, 1)
	pal(15, 128+1, 1)
	pal(13, 0, 1)
	pal(11, 128+14, 1)
	pal(12, 128+15, 1)
	for i=1,grid_width do
		grid[i] = {}
		for j=1,grid_height do
			--if((j%2==0 and i%2!=0) or (j%2!=0 and i%2==0)) then
				grid[i][j] = 0
			--else
			--	grid[i][j] = 1
			--end
		end
		
		--t = rnd({1,2,3,4,5,6,7})
		--e = rnd({8,9,10,11,12,13})
		--current_tetrimino = new_tetrimino(4, 3, t, e)
		
		bag = new_bag()
		second_bag = new_bag()
		current_tetrimino = bag[1]
	
	end
	
	-- 2 = pawn (sotilas)
	-- 3 = knight (ratsu)
	-- 4 = bishop (lahetti)
	-- 5 = rook (torni)
	-- 6 = king (kuningas)
	-- 7 = queen (kuningatar)
	for i=1,8 do
		grid[i][15] = 2
	end
	grid[1][16] = 5
	grid[2][16] = 3
	grid[3][16] = 4
	grid[4][16] = 7
	grid[5][16] = 6
	grid[6][16] = 4
	grid[7][16] = 3
	grid[8][16] = 5
	
	start_game = false
	
	selected_piece = {-1, -1}
	reticle = {4, 11}
	score = 0
	promote_selection = 1
	freeze_delay = max_freeze_delay	
	ghost_image = {-1, -1, 0}
end

function _update()	
	handle_inputs()
	if(freeze_frames > 0) then
		freeze_frames -= 1
		return
	end
	
	if(start_game == false) then
		if(btn(Ž) and input_—_last_frame == false) then
			start_game = true
		end
		return
	end
	
	if(game_over) then
		if(btn(—)) then
			input_—_last_frame = true
			reset_game()
		end
		return
	end
	
	update_rubble()
	
	if(phase == "tetris") then
		timer += 1
	
		if(btnp(‹)) then
			move_tetrimino(current_tetrimino, -1, 0)
			move_cooldown = 4
		elseif(input_‹) then
			if(move_cooldown > 0) then
				move_cooldown -= 1
			end
			if(move_cooldown == 0) then
				move_current_tetrimino(-1, 0)
			end
		end
		if(btnp(‘)) then
			move_tetrimino(current_tetrimino, 1, 0)
			move_cooldown = 4
		elseif(input_‘) then
			if(move_cooldown > 0) then
				move_cooldown -= 1
			end
			if(move_cooldown == 0) then
				move_current_tetrimino(1, 0)
			end
		end
		
		if(btnp(—)) then
			rotate(-0.25)
		end
		if(btnp(Ž)) then
			rotate(0.25)	
		end
		
		if(input_ƒ) then
			soft_drop = true
		else
			soft_drop = false
		end
		
		if(input_”) then
			hard_drop()
			freeze_delay = 0
		end
		
		if(timer%fall_interval == 0 or (soft_drop == true)) then
			fall_tetrimino()
		end
		
		if(check_grounded()) then
			if(freeze_delay <= 0) then
				freeze_tetrimino()
				del(bag, bag[1])
				if(#bag == 0) then
					bag = second_bag
					second_bag = {}
				end
				current_tetrimino = bag[1]
				
				--t = rnd({1,2,3,4,5,6,7})
				--e = rnd({8,9,10,11,12,13})
				--current_tetrimino = new_tetrimino(4, 2, t, e)
				freeze_delay = max_freeze_delay
			else
				freeze_delay -= 1
			end
		end
		
		if(#bag == 3 and #second_bag == 0) then
			second_bag = new_bag()
		end
		delete_lines()
		
	elseif(phase == "chess") then
		if(btnp(‘) and reticle[1] < grid_width) then
			reticle = {reticle[1]+1, reticle[2]}
		elseif(btnp(‹) and reticle[1] > 1) then
			reticle = {reticle[1]-1, reticle[2]}
		end
		if(btnp(ƒ) and reticle[2] < grid_height) then
			reticle = {reticle[1], reticle[2]+1}
		elseif(btnp(”) and reticle[2] > 3) then
			reticle = {reticle[1], reticle[2]-1}
		end
		
		if(btnp(—) and grid[reticle[1]][reticle[2]] >= 2 and grid[reticle[1]][reticle[2]] <= 7) then
			selected_piece = {reticle[1], reticle[2]}
		end
		if(selected_piece[1] != -1 and btnp(—)) then
			move_chess_piece()
			enemy_movement_delay = max_enemy_movement_delay
		end
	elseif(phase == "promote") then
		if(btnp(”) and promote_selection > 1) then
				promote_selection -= 1
		end
		if(btnp(ƒ) and promote_selection < 5) then
				promote_selection += 1
		end
		if(btnp(—)) then
			-- the promotion
			grid[selected_piece[1]][selected_piece[2]] = promote_selection + 2
			phase = "enemy"
			enemy_movement_delay = max_enemy_movement_delay
			promote_selection = 1
			selected_piece = {-1, -1}
			_draw()
			freeze_frames = 15
		end
	elseif(phase == "enemy") then
		if(enemy_movement_delay > 0) then
			enemy_movement_delay -= 1
			return
		end
		enemy_movement()
		phase = "tetris"
	end
	
	loop_over_pieces()
	--update_rubble()
end

function _draw()
	if(freeze_frames > 0 and animation_frames == 0) then
		return
	end
	cls(1)
	
	
	if(start_game == true) then
		--safety line
		fillp(™)
		color(7)
		line(10, 104, 118, 104, 7)
		line(10, 40, 118, 40, 7)
		fillp()
		print("promote", 96, 43, 15)
		print("promote", 95, 42, 7)
		print("safety", 96, 107, 15)
		print("safety", 95, 106, 7)
	end
	
	-- draw grid and pieces
	rect(grid_offset_x+9, 9, grid_offset_x+72, 120, 15)
	for i=1,grid_width do
		for j=3,grid_height do
			if((j%2==0 and i%2!=0) or (j%2!=0 and i%2==0)) then
				spr(0, grid_offset_x+i*8, j*8-16)
				--if(phase == "chess" and selected_piece[1]!=-1) then
				--	spr(32, grid_offset_x+i*8, j*8-16)
				--end
			else
				spr(1, grid_offset_x+i*8, j*8-16)
			end
			
			if(ghost_image[1] != -1 or ghost_image[2] != -1) then
				spr(ghost_image[3], grid_offset_x+ghost_image[1]*8, ghost_image[2]*8-16)
			end
			
			if(grid[i][j] != 0 and ((i!=target_x or j!=target_y) or animation_frames <= 0)) then
				spr(grid[i][j], grid_offset_x+i*8, j*8-16)
			end
		end
	end
	
	--print("next", 59, 57, 12)
		--ircfill(104, 18, 12, 6)
		--circ(104, 18, 12, 5)
		
		rectfill(94, 1, 129, 33, 5)
		rectfill(93, 0, 128, 32, 15)
		print("next: ", 98, 4, 5)
		print("next: ", 97, 3, 7)
		if(phase == "chess") then
			copy = copy_tetrimino(current_tetrimino)
		else
			if(#bag > 1) then
			copy = copy_tetrimino(bag[2])
			else
			 copy = copy_tetrimino(second_bag[1])
			end
		end
		for i=1,4 do
			--pset(36+2*current_tetrimino[i][1], 10+2*(current_tetrimino[i][2]-3), 13)
			--rectfill(102+5*(copy[i][1]-copy[5][1]), 32+5*(copy[i][2]-copy[5][2]-3), 102+5*(copy[i][1]-copy[5][1])+4, 32+5*(copy[i][2]-copy[5][2]-3)+4, copy.col)
			spr(15, 107+8*(copy[i][1]-copy[5][1]), 19+8*(copy[i][2]-copy[5][2]))
			spr(copy.enemy_piece[3], 106+8*(copy.enemy_piece[1]-copy[5][1]), 19+8*(copy.enemy_piece[2]-copy[5][2]))
		
		end
		
		--circfill(104, 46, 12, 6)
		--circ(104, 46, 12, 5)
		--[[
		if(#bag >= 3) then
			copy = copy_tetrimino(bag[3])
		elseif(#bag >= 2) then
			copy = copy_tetrimino(second_bag[1])
		elseif(#bag == 1) then
			copy = copy_tetrimino(second_bag[2])
		end
		
		for i=1,4 do
			--pset(36+2*current_tetrimino[i][1], 10+2*(current_tetrimino[i][2]-3), 13)
			--rectfill(102+5*(copy[i][1]-copy[5][1]), 60+5*(copy[i][2]-copy[5][2]-3), 102+5*(copy[i][1]-copy[5][1])+4, 60+5*(copy[i][2]-copy[5][2]-3)+4, copy.col)
			spr(15, 80+8*copy[i][1], 10+8*copy[i][2])
		end
		]]--
	
	if(freeze_frames > 0 and #line_numbers > 0) then
		h = freeze_frames/max_freeze_frames
		for i=1,#line_numbers do
			rectfill(grid_offset_x+8, 8*(line_numbers[i])-12-4*h, grid_offset_x+72, 8*(line_numbers[i])-12+4*h, 6)
		end
	elseif(freeze_frames == 0) then
		line_numbers = {}
	end	
	
	if(animation_frames > 0) then
		animation_frames -= 1
		dx = 8*(target_x-start_x)
		dy = 8*(target_y-start_y)
		
		a_minus = max_animation_frames - animation_frames
		
		--fillp()
		ovalfill(grid_offset_x+(start_x+0.5)*8+((max_animation_frames-animation_frames)/max_animation_frames)*dx - 3, (start_y-1.5)*8+((max_animation_frames-animation_frames)/max_animation_frames)*dy -1.5, grid_offset_x+(start_x+0.5)*8+((max_animation_frames-animation_frames)/max_animation_frames)*dx + 3, (start_y-1.5)*8+((max_animation_frames-animation_frames)/max_animation_frames)*dy + 1.5, 1)
		
		--fillp()
		spr(moved_piece, grid_offset_x+start_x*8+((max_animation_frames-animation_frames)/max_animation_frames)*dx, (start_y-2)*8+((max_animation_frames-animation_frames)/max_animation_frames)*dy + (animation_frames - max_animation_frames/2)*(animation_frames - max_animation_frames/2)/4 - max_animation_frames)
		
		if(animation_frames == 1 and (start_x != -1 or start_y != -1)) then
			sfx(0)
		end
	else
		ghost_image = {-1, -1, 0}
		start_x = -1
		start_y = -1
		target_x = -1
		target_y = -1
		moved_piece = 0
	end
	
	if(start_game == true) then
		print(score, 2, 2, 15)
		print(score, 1, 1, 7)
	end
	
	if(freeze_frames > 0) then
		return
	end
	
	for i=1,#rubble do
		if(rubble[i].delay == 0) then
			spr(rubble[i].rubble_type, rubble[i].x, rubble[i].y)
		end
	end
	
	if(start_game == false) then
		rectfill(22, 30, 85, 92, 0)
		print("tetrachess", 34, 41, 5)
		print("tetrachess", 33, 40, 7)
		print("press Ž to", 31, 60, 7)
		print("start game", 31, 66, 7)
		
		print("hiscore: "..hiscore, 31, 80)
		
		print("by: ville111", 2, 122)
		print("1.0.2", 108, 122)
		return
	end
	
	
	if(phase == "tetris") then
		-- draw falling tetrimino
		for i=1,4 do
			spr(15, grid_offset_x+8*current_tetrimino[i][1], 8*current_tetrimino[i][2]-16)
			--rect(grid_offset_x+8*current_tetrimino[i][1], 8*(current_tetrimino[i][2]), 8+grid_offset_x+8*current_tetrimino[i][1], 8+8*(current_tetrimino[i][2]), 10)
			spr(current_tetrimino.enemy_piece[3], grid_offset_x+8*current_tetrimino.enemy_piece[1], 8*current_tetrimino.enemy_piece[2]-16)
		end
	
	elseif(phase == "chess") then
		spr(16, grid_offset_x+8*reticle[1], 8*reticle[2]-16)
		
		spr(17, grid_offset_x+8*selected_piece[1], 8*selected_piece[2]-16)
	elseif(phase == "promote") then
		rectfill(50, 30, 80, 100, 0)
		print("promote", 52, 33, 7)
		for i=1,5 do
			spr(2+i, 60, 33+i*9)
		end
		rect(59, 33+promote_selection*9, 68, 41+promote_selection*9, 7)
	end
	
	if(game_over) then
		rectfill(22, 30, 85, 80, 0)
		print("game over", 35, 34, 7)
		print("press — to", 31, 46, 7)
		print("continue", 31, 53, 7)
		
		print("hiscore: "..hiscore, 31, 66)
	end
	
	
	--print(score, 2, 2, 15)
	--print(score, 1, 1, 7)
	
	
	
	--print(current_tetrimino.enemy_piece[3], 10, 100)
	::end_of_draw::
end

function reset_game()
	king_alive = true
	game_over = false
	phase = "tetris"
	hiscore = dget(0)
	grid = {}
	for i=1,grid_width do
		grid[i] = {}
		for j=1,grid_height do
				grid[i][j] = 0
		end
		
		t = rnd({1,2,3,4,5,6,7})
		e = rnd({8,9,10,11,12,13})
		current_tetrimino = new_tetrimino(4, 3, t, e)
		
	end
	
	for i=1,8 do
		grid[i][15] = 2
	end
	grid[1][16] = 5
	grid[2][16] = 3
	grid[3][16] = 4
	grid[4][16] = 7
	grid[5][16] = 6
	grid[6][16] = 4
	grid[7][16] = 3
	grid[8][16] = 5
	
	start_game = false
	
	selected_piece = {-1, -1}
	reticle = {4, 11}
	score = 0
	promote_selection = 1
	freeze_delay = max_freeze_delay	
end

function restart_game()
	reset_game()
	start_game = true
end

menuitem(1, "restart", restart_game)
-->8
-- tetris logic
function new_bag()
	local temp_bag = {}
	available_pieces = {8, 8, 9, 10, 11, 12, 13}
	available_numbers = {1, 2, 3, 4, 5, 6, 7}
	for j=1,7 do
		nmb = rnd(available_numbers)
		pc = rnd(available_pieces)
		del(available_numbers, nmb)
		del(available_pieces, pc)
		--e = rnd({8,9,10,11,12,13})
		temp_bag[j] = new_tetrimino(4, 2, nmb, pc)
	end
	return temp_bag
end

function new_tetrimino(x, y, t, e)
	-- rng stuff
	local tetr_type = t
	local tetrimino = {}
	
	if(tetr_type == 1) then
		-- o
		tetrimino = {
	  {x, y},
	  {x+1, y},
	  {x, y+1},
	  {x+1, y+1},
	  {x+0.5, y+0.5},
	  tetr_type = 1,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  } 
	elseif(tetr_type == 2) then
		-- i
		tetrimino = {
		 {x, y},
	  {x+1, y},
	  {x+2, y},
	  {x+3, y},
	  {x+1.5, y},
	  tetr_type = 2,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr_type == 3) then
		-- s
		tetrimino = {
		 {x, y},
	  {x+1, y},
	  {x, y+1},
	  {x-1, y+1},
	  {x, y+0.5},
	  tetr_type = 3,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr_type == 4) then
		-- z
		tetrimino = {
		 {x, y},
	  {x-1, y},
	  {x, y+1},
	  {x+1, y+1},
	  {x, y+0.5},
	  tetr_type = 4,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr_type == 5) then
		-- t
		tetrimino = {
		 {x, y},
	  {x+1, y},
	  {x-1, y},
	  {x, y-1},
	  {x, y},
	  tetr_type = 5,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr_type == 6) then
		-- l
		tetrimino = {
		 {x, y},
	  {x-1, y},
	  {x+1, y},
	  {x+1, y-1},
	  {x, y},
	  tetr_type = 6,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr_type == 7) then
		-- j
		tetrimino = {
		 {x, y},
	  {x-1, y},
	  {x+1, y},
	  {x-1, y-1},
	  {x, y},
	  tetr_type = 7,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	end
	
	local tr = copy_tetrimino(tetrimino)
	tetrimino.enemy_piece = rnd({tr[1], tr[2], tr[3], tr[4]})
	tetrimino.enemy_piece[3] = e
	
	return tetrimino
end

function rotate(angle)
	if(current_tetrimino.tetr_type == 1) then
		local px = current_tetrimino[5][1]
		local py = current_tetrimino[5][2]
		current_tetrimino.enemy_piece = {round((current_tetrimino.enemy_piece[1]-px)*cos(angle)-(current_tetrimino.enemy_piece[2]-py)*sin(angle)+px), round((current_tetrimino.enemy_piece[1]-px)*sin(angle)+(current_tetrimino.enemy_piece[2]-py)*cos(angle)+py), current_tetrimino.enemy_piece[3]}
		return
	end
	
	local temp = {{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}}
	local px = current_tetrimino[5][1]
	local py = current_tetrimino[5][2]
	
	for i=1,5 do
	 x = current_tetrimino[i][1]-px
	 y = current_tetrimino[i][2]-py
		
		temp[i][1] = round(x*cos(angle)-y*sin(angle)+px)
		temp[i][2] = round(x*sin(angle)+y*cos(angle)+py)
	end
		
	temp.tetr_type = current_tetrimino.tetr_type
	temp.enemy_piece = {round((current_tetrimino.enemy_piece[1]-px)*cos(angle)-(current_tetrimino.enemy_piece[2]-py)*sin(angle)+px), round((current_tetrimino.enemy_piece[1]-px)*sin(angle)+(current_tetrimino.enemy_piece[2]-py)*cos(angle)+py), current_tetrimino.enemy_piece[3]}
	
	
	intersects = check_intersection(temp)
	
	if(intersects == false) then
		current_tetrimino = temp
	elseif(intersects) then
		-- try if moving the piece left or right works
		copy = copy_tetrimino(temp)
		move_tetrimino(copy, -1, 0)
		inters = check_intersection(copy)
		if(inters == false) then
			current_tetrimino = copy
		elseif(inters == true) then
			copy = copy_tetrimino(temp)
			move_tetrimino(copy, 1, 0)
			inters = check_intersection(copy)
			if(inters == false) then
				current_tetrimino = copy
			elseif(inters == true) then
				copy = copy_tetrimino(temp)
				move_tetrimino(copy, -1, 1)
				inters = check_intersection(copy)
				if(inters == false) then
					current_tetrimino = copy
				elseif(inters == true) then
					copy = copy_tetrimino(temp)
					move_tetrimino(copy, 0, 1)
					inters = check_intersection(copy)
					if(inters == false) then
						current_tetrimino = copy
					elseif(inters == true) then
						copy = copy_tetrimino(temp)
						move_tetrimino(copy, 1, 1)
						inters = check_intersection(copy)
						if(inters == false) then
							current_tetrimino = copy
						elseif(inters == true) then
							copy = copy_tetrimino(temp)
							move_tetrimino(copy, -2, 0)
							inters = check_intersection(copy)
							if(inters == false) then
								current_tetrimino = copy
							elseif(inters == true) then
								copy = copy_tetrimino(temp)
								move_tetrimino(copy, 2, 0)
								inters = check_intersection(copy)
								if(inters == false) then
									current_tetrimino = copy
								end
							end
						end
					end
				end
			end
		end
	end
end

function round(x) 
	return flr(x+0.5)
end

function freeze_tetrimino()
	for i=1,4 do
		if(current_tetrimino[i][1]!=current_tetrimino.enemy_piece[1] or current_tetrimino[i][2]!=current_tetrimino.enemy_piece[2]) then
			grid[current_tetrimino[i][1]][current_tetrimino[i][2]] = 14
		else
			grid[current_tetrimino[i][1]][current_tetrimino[i][2]] = current_tetrimino.enemy_piece[3]
		end
	end
	
	phase = "chess"
end

function check_grounded()
	grounded = false
	
	for i=1,4 do
		if(current_tetrimino[i][2]+1 > grid_height or grid[current_tetrimino[i][1]][current_tetrimino[i][2]+1] != 0) then
			grounded = true
		end
	end
	return grounded
end

function move_current_tetrimino(dx, dy)
	allow_move = true
	
	if(soft_drop == false and hard_dropping == false and timer%move_interval != 0) then
		return false
	end
	
	for i=1,4 do
		if(current_tetrimino[i][1]+dx <= 0 or current_tetrimino[i][1]+dx > grid_width or current_tetrimino[i][2]+dy > grid_height or grid[current_tetrimino[i][1]+dx][current_tetrimino[i][2]+dy] != 0) then
			allow_move = false
		end
	end
	
	if(allow_move) then
		for i=1,5 do
			current_tetrimino[i][1] += dx
			current_tetrimino[i][2] += dy
		end
		current_tetrimino.enemy_piece[1] += dx
		current_tetrimino.enemy_piece[2] += dy
		
	end
	
	return allow_move
end

function move_tetrimino(tetr, dx, dy)
	allow_move = true
	
	for i=1,4 do
		if(tetr[i][1]+dx <= 0 or tetr[i][1]+dx > grid_width or tetr[i][2]+dy > grid_height or grid[tetr[i][1]+dx][tetr[i][2]+dy] != 0) then
			allow_move = false
		end
	end
	
	if(allow_move) then
		for i=1,5 do
			tetr[i][1] += dx
			tetr[i][2] += dy
		end
		tetr.enemy_piece[1] += dx
		tetr.enemy_piece[2] += dy
	end
	
	return allow_move
end

function copy_tetrimino(tetr)
	-- make a copy of tetrimino
	temp = {}
	for i=1,5 do
		k1 = tetr[i][1]
		k2 = tetr[i][2]
	 temp[i] = {k1, k2}
	end
	
	temp.tetr_type = tetr.tetr_type
	temp.enemy_piece = {tetr.enemy_piece[1],tetr.enemy_piece[2],tetr.enemy_piece[3]} 
	
	return temp
end

function check_intersection(tetr)
	intersects = false
	for i=1,4 do
	 if(tetr[i][1] > 0 and tetr[i][1] <= grid_width and tetr[i][2] <= grid_height) then
	 	if(grid[tetr[i][1]][tetr[i][2]] != 0) then
				intersects = true
			end
	 else
	 	intersects = true
	 end
	end
	
	return intersects
end

--[[
function reset_position(tetr, x, y)
	e = tetr.enemy_piece[3]

	if(tetr.tetr_type == 1) then
		-- o
		tetr = {
	  {x, y},
	  {x+1, y},
	  {x, y+1},
	  {x+1, y+1},
	  {x+0.5, y+0.5},
	  tetr_type = 1,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr.tetr_type == 2) then
		-- i
		tetr = {
		 {x, y},
	  {x+1, y},
	  {x+2, y},
	  {x+3, y},
	  {x+1.5, y},
	  tetr_type = 2,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr.tetr_type == 3) then
		-- s
		tetr = {
		 {x, y},
	  {x+1, y},
	  {x, y+1},
	  {x-1, y+1},
	  {x, y+0.5},
	  tetr_type = 3,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr.tetr_type == 4) then
		-- z
		tetr = {
		 {x, y},
	  {x-1, y},
	  {x, y+1},
	  {x+1, y+1},
	  {x, y+0.5},
	  tetr_type = 4,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr.tetr_type == 5) then
		-- t
		tetr = {
		 {x, y},
	  {x+1, y},
	  {x-1, y},
	  {x, y-1},
	  {x, y},
	  tetr_type = 5,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr.tetr_type == 6) then
		-- l
		tetr = {
		 {x, y},
	  {x-1, y},
	  {x+1, y},
	  {x+1, y-1},
	  {x, y},
	  tetr_type = 6,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	elseif(tetr.tetr_type == 7) then
		-- j
		tetr = {
		 {x, y},
	  {x-1, y},
	  {x+1, y},
	  {x-1, y-1},
	  {x, y},
	  tetr_type = 7,
	  enemy_piece = {x, y, e} //position x, y and finally the enemy type
	  }
	end
	
	return tetr
end
]]--

function fall_tetrimino()
	allow_move = true
	
	for i=1,4 do
		if(current_tetrimino[i][2]+1 > grid_height or grid[current_tetrimino[i][1]][current_tetrimino[i][2]+1] != 0) then
			allow_move = false
		end
	end
	
	if(allow_move) then
		for i=1,5 do
			current_tetrimino[i][2] += 1
		end
		current_tetrimino.enemy_piece[2] += 1
	end
	
	return allow_move
end

function delete_lines()
	lines_deleted = 0
	line_numbers = {}
	
	for j=3,grid_height-2 do
		all_slots_taken = true
		for i=1,grid_width do
			if(grid[i][j]==0) then
				all_slots_taken = false
				break 
			end
		end
		if(all_slots_taken) then
			delete_line(j, true)
			lines_deleted += 1
		end
	end
	
	--for i=1,#line_numbers do
	--	rectfill(grid_offset_x+8, 8*(line_numbers[i])-16, grid_offset_x+72, 8*(line_numbers[i])-8, 6)
	--	freeze_frames = 15
	--	_draw()
	--end
end

function delete_line(j, woosh)
	add(line_numbers, j)
	chess_score = 0
	
	for i=1,grid_width do
		if(grid[i][j] == 8) then
			chess_score += 1
		elseif(grid[i][j] == 9) then
			chess_score += 2
		elseif(grid[i][j] == 10) then
			chess_score += 3
		elseif(grid[i][j] == 11) then
			chess_score += 3
		elseif(grid[i][j] == 12) then
			chess_score += 4
		elseif(grid[i][j] == 13) then
			chess_score += 4
		end
		grid[i][j] = 0
	end
	
	for i=1,grid_width do
		for k=j,3,-1 do
			grid[i][k] = grid[i][k-1]
		end
	end
	
	if(woosh == true) then
		freeze_frames = 15
		animation_frames = 15
		h = freeze_frames/max_freeze_frames
		rectfill(grid_offset_x+8, 8*(j)-12-4*h, grid_offset_x+72, 8*(j)-12+4*h, 6)
		sfx(1)
	end
	
	score += chess_score
end

-->8
function handle_inputs()
	-- input handling
	if(btn(—) or btnp(—)) then
		input_— = true
		if(input_—_last_frame == true) then
			input_— = false
		end
		input_—_last_frame = true
	else
		input_— = false
		if(input_—_last_frame == true) then
			input_—_last_frame = false
		end
	end
	if(btn(Ž) or btnp(Ž)) then
		input_Ž = true
		if(input_Ž_last_frame == true) then
			input_Ž = false
		end
		input_Ž_last_frame = true
	else
		input_Ž = false
		if(input_Ž_last_frame == true) then
			input_Ž_last_frame = false
		end
	end

	if(btn(‹)) then
		input_‹ = true
	else
		input_‹ = false
	end
	if(btn(‘)) then
		input_‘ = true
	else
		input_‘ = false
	end

	if(btn(”)) then
		input_” = true
		if(input_”_last_frame == true) then
			input_” = false
		end
		input_”_last_frame = true
	else
		input_” = false
		if(input_”_last_frame == true) then
			input_”_last_frame = false
		end
	end
	if(btn(ƒ)) then
		input_ƒ = true
	else
		input_ƒ = false
	end
end

function hard_drop()
 hard_dropping = true
	moved = true
	while(moved == true) do
		moved = move_current_tetrimino(0, 1)
	end
	hard_dropping = false
	_draw()
end
-->8
-- chess logic

function move_chess_piece()	
	local piece = grid[selected_piece[1]][selected_piece[2]]
	local eating = true
	local legal_move = true
	local sp = selected_piece
	local val = grid[reticle[1]][reticle[2]]
	if(piece < 2 or piece > 7) then
		return
	end

	if(val < 8 or val > 14) then
		eating = false -- move is used for moving only
	end
	
	move = false
	
	if(piece == 2) then
		if(selected_piece[2] == 15) then
			if(eating and (reticle[1] == sp[1]-1 or reticle[1] == sp[1]+1) and reticle[2] == sp[2]-1) then
				move = true
			elseif(eating == false and reticle[1] == sp[1] and (reticle[2] == sp[2] - 1 or reticle[2] == sp[2] - 2) and grid[reticle[1]][reticle[2]] == 0) then
				move = true
			end
		else
			if(eating and (reticle[1] == sp[1]-1 or reticle[1] == sp[1]+1) and reticle[2] == sp[2]-1) then
				move = true
			elseif(eating == false and reticle[1] == sp[1] and reticle[2] == sp[2] - 1 and grid[reticle[1]][reticle[2]] == 0) then
				move = true
			end
		end
	elseif(piece == 3) then
		if((reticle[1] == sp[1]-1 and reticle[2] == sp[2]-2)
		or (reticle[1] == sp[1]+1 and reticle[2] == sp[2]-2)
		or (reticle[1] == sp[1]-2 and reticle[2] == sp[2]-1)
		or (reticle[1] == sp[1]+2 and reticle[2] == sp[2]-1)
		or (reticle[1] == sp[1]+1 and reticle[2] == sp[2]+2)
		or (reticle[1] == sp[1]-1 and reticle[2] == sp[2]+2)
		or (reticle[1] == sp[1]+2 and reticle[2] == sp[2]+1)
		or (reticle[1] == sp[1]-2 and reticle[2] == sp[2]+1)) then
			
			if((val >= 8 and val <= 14) or val == 0) then
				move = true
			end
		end
	elseif(piece == 4) then
		if((reticle[1] == sp[1] and reticle[2] == sp[2]) or abs(reticle[1]-sp[1]) != abs(reticle[2]-sp[2])) then
			return
		end
		free = true
		
		for i=1,abs(reticle[1]-sp[1])-1 do
			local val2 = grid[sp[1]+i*sgn(reticle[1]-sp[1])][sp[2]+i*sgn(reticle[2]-sp[2])]
			if(val2 != 0) then
				free = false
			end
		end
		
		if(free == true and (eating == true or val == 0)) then
			move = true
		end
	elseif(piece == 5) then
		if((reticle[1] == sp[1] and reticle[2] == sp[2]) or (abs(reticle[1]-sp[1]) != 0 and abs(reticle[2]-sp[2])!=0)) then
			return
		end
		free = true
		
		if(reticle[1]-sp[1] != 0) then
			for i=1,abs(reticle[1]-sp[1])-1 do
				local val2 = grid[sp[1]+i*sgn(reticle[1]-sp[1])][sp[2]]
				if(val2 != 0) then
					free = false
				end
			end
		elseif(reticle[2]-sp[2] != 0) then
			for i=1,abs(reticle[2]-sp[2])-1 do
				local val2 = grid[sp[1]][sp[2]+i*sgn(reticle[2]-sp[2])]
				if(val2 != 0) then
					free = false
				end
			end
		end
		
		if(free == true and (eating == true or val == 0)) then
			move = true
		end
	elseif(piece == 6) then
	 if(reticle[1] == sp[1] and reticle[2] == sp[2]-1)
	 or(reticle[1] == sp[1]-1 and reticle[2] == sp[2]-1)
		or(reticle[1] == sp[1]+1 and reticle[2] == sp[2]-1)
		or(reticle[1] == sp[1]-1 and reticle[2] == sp[2])
		or(reticle[1] == sp[1]+1 and reticle[2] == sp[2])
		or(reticle[1] == sp[1] and reticle[2] == sp[2]+1)
	 or(reticle[1] == sp[1]-1 and reticle[2] == sp[2]+1)
		or(reticle[1] == sp[1]+1 and reticle[2] == sp[2]+1) then
			if((val >= 8 and val <= 14) or val==0) then
				move = true
			end
		end
	elseif(piece == 7) then
		if(reticle[1] == sp[1] and reticle[2] == sp[2]) then
			return
		end
		
		free = true
		
		if(reticle[1]-sp[1] != 0 and (reticle[2]-sp[2] == 0)) then
			for i=1,abs(reticle[1]-sp[1])-1 do
				local val2 = grid[sp[1]+i*sgn(reticle[1]-sp[1])][sp[2]]
				if(val2 != 0) then
					free = false
				end
			end
		elseif(reticle[2]-sp[2] != 0 and (reticle[1]-sp[1] == 0)) then
			for i=1,abs(reticle[2]-sp[2])-1 do
				local val3 = grid[sp[1]][sp[2]+i*sgn(reticle[2]-sp[2])]
				if(val3 != 0) then
					free = false
				end
			end
		elseif(abs(reticle[1]-sp[1]) == abs(reticle[2]-sp[2])) then
			for i=1,abs(reticle[1]-sp[1])-1 do
				local val4 = grid[sp[1]+i*sgn(reticle[1]-sp[1])][sp[2]+i*sgn(reticle[2]-sp[2])]
				if(val4 != 0) then
					free = false
				end
			end
		else
			free = false
		end
		
		if(free == true and (eating == true or val == 0)) then
			move = true
		end
	end
	
	if(move == true) then
		grid[selected_piece[1]][selected_piece[2]] = 0
		grid[reticle[1]][reticle[2]] = piece
		
		animation_frames = max_animation_frames
		start_x = selected_piece[1]
		start_y = selected_piece[2]
		target_x = reticle[1]
		target_y = reticle[2]
		moved_piece = piece
		
		if(eating == true) then
			for i=1,4 do
				if(val == 14) then
					new_rubble(grid_offset_x+reticle[1]*8, reticle[2]*8-16, "ground", 0)
				else
					new_rubble(grid_offset_x+reticle[1]*8, reticle[2]*8-16, "enemy", 0)			
				end
			end
			ghost_image = {reticle[1], reticle[2], val}
	
			if(val == 8) then
				score += 1
			elseif(val == 9) then
				score += 2
			elseif(val == 10) then
				score += 3
			elseif(val == 11) then
				score += 3
			elseif(val == 12) then
				score += 4
			elseif(val == 13) then
				score += 4
			end
		end	
		
		delete_lines()
		if(piece == 2 and reticle[2] < 7) then
			phase = "promote"
			selected_piece = {reticle[1], reticle[2]}
		else
			phase = "enemy"
			selected_piece = {-1, -1}
			_draw()
			freeze_frames = 15
		end
	end
end

function loop_over_pieces()
	king_alive = false
	top_rows_free = true
	first_piece_found = false
	first_piece_line = 15
	
	for j=2,grid_height do
	 if(first_piece_found and j > first_piece_line) then
	 	all_empty = true 
	 end
	 
		for i=1,grid_width do
			if(grid[i][j] == 6) then
				king_alive = true
			end
			if(j == 2 and grid[i][j] != 0) then
				game_over = true
				if(score > hiscore) then
					hiscore = score
					dset(0, score)
				end
			end
			
			if(grid[i][j] != 0) then
				all_empty = false
			end
			
			if(first_piece_found == false and grid[i][j] != 0) then
				first_piece_found = true
				first_piece_line = j
			end
		end
		if(all_empty) then
			delete_line(j, false)
		end
		
	end
	
	if(king_alive == false) then
		game_over = true
		if(score > hiscore) then
			hiscore = score
			dset(0, score)
		end
	end
end

function enemy_movement()
	local enemies = {}
	
	for j=3,grid_height do
		for i=1,grid_width do
			local val = grid[i][j]
			
			if(val >= 8 and val <= 13) then
				add(enemies, {val, i, j})
			end
		end
	end
	
	shuffle(enemies)
	for k=1,#enemies do
	 if(enemy_move(enemies[k][1], enemies[k][2], enemies[k][3])) then
			animation_frames = max_animation_frames
			moved_piece = enemies[k][1]
			start_x = enemies[k][2]
			start_y = enemies[k][3]
			return true
		end
	end
	
	return false
end

function enemy_move(pc, x, y)
	-- all of the pieces follow similar
	-- structure:
	-- first, they attempt to eat
	-- player's pieces if possible
	-- if not, then they will
	-- try to eat anything (garbageblocks)
	-- if this fails, they attempt
	-- to move
	
	if(pc == 8) then
			if(legal_eat_pieces(x+1, y+1)) then
				enemy_moves(pc, x, y, x+1, y+1)
				return true
			elseif(legal_eat_pieces(x-1, y+1)) then
				enemy_moves(pc, x, y, x-1, y+1)
				return true
			elseif(legal_eat(x+1, y+1)) then
				enemy_moves(pc, x, y, x+1, y+1)
				return true
			elseif(legal_eat(x-1, y+1)) then
				enemy_moves(pc, x, y, x-1, y+1)
				return true
			elseif(legal_empty(x, y+1)) then
				enemy_moves(pc, x, y, x, y+1)
				return true
			end
	elseif(pc == 9) then
		if(legal_eat_pieces(x-1,y+2)) then
			enemy_moves(pc, x, y, x-1, y+2)
			return true
		elseif(legal_eat_pieces(x+1,y+2)) then
			enemy_moves(pc, x, y, x+1, y+2)
			return true
		elseif(legal_eat_pieces(x-2,y+1)) then
			enemy_moves(pc, x, y, x-2, y+1)
			return true
		elseif(legal_eat_pieces(x+2,y+1)) then
			enemy_moves(pc, x, y, x+2, y+1)
			return true
		elseif(legal_eat_pieces(x-1,y-2)) then
			enemy_moves(pc, x, y, x-1, y-2)
			return true
		elseif(legal_eat_pieces(x+1,y-2)) then
			enemy_moves(pc, x, y, x+1, y-2)
			return true
		elseif(legal_eat_pieces(x-2,y-1)) then
			enemy_moves(pc, x, y, x-2, y-1)
			return true
		elseif(legal_eat_pieces(x+2,y-1)) then
			enemy_moves(pc, x, y, x+2, y-1)
			return true
		elseif(legal_eat(x-1,y+2)) then
			enemy_moves(pc, x, y, x-1, y+2)
			return true
		elseif(legal_eat(x+1,y+2)) then
			enemy_moves(pc, x, y, x+1, y+2)
			return true
		elseif(legal_eat(x-2,y+1)) then
			enemy_moves(pc, x, y, x-2, y+1)
			return true
		elseif(legal_eat(x+2,y+1)) then
			enemy_moves(pc, x, y, x+2, y+1)
			return true
		elseif(legal_eat(x-1,y-2)) then
			enemy_moves(pc, x, y, x-1, y-2)
			return true
		elseif(legal_eat(x+1,y-2)) then
			enemy_moves(pc, x, y, x+1, y-2)
			return true
		elseif(legal_eat(x-2,y-1)) then
			enemy_moves(pc, x, y, x-2, y-1)
			return true
		elseif(legal_eat(x+2,y-1)) then
			enemy_moves(pc, x, y, x+2, y-1)
			return true
		end

		if(legal_move(x-1,y+2)) then
			enemy_moves(pc, x, y, x-1, y+2)
			return true
		elseif(legal_move(x+1,y+2)) then
			enemy_moves(pc, x, y, x+1, y+2)
			return true
		elseif(legal_move(x-2,y+1)) then
			enemy_moves(pc, x, y, x-2, y+1)
			return true
		elseif(legal_move(x+2,y+1)) then
			enemy_moves(pc, x, y, x+2, y+1)
			return true
		elseif(legal_move(x-1,y-2)) then
			enemy_moves(pc, x, y, x-1, y-2)
			return true
		elseif(legal_move(x+1,y-2)) then
			enemy_moves(pc, x, y, x+1, y-2)
			return true
		elseif(legal_move(x-2,y-1)) then
			enemy_moves(pc, x, y, x-2, y-1)
			return true
		elseif(legal_move(x+2,y-1)) then
			enemy_moves(pc, x, y, x+2, y-1)
			return true
		end
	elseif(pc == 10) then
		min_dist = 0
		
		::bishop_loop::
		
		-- down right
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x+i, y+i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x+(max_dist+1), y+(max_dist+1))) then
				enemy_moves(pc, x, y, x+(max_dist+1), y+(max_dist+1))
				return true
			end
		end
		-- down left
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x-i, y+i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x-(max_dist+1), y+(max_dist+1))) then
				enemy_moves(pc, x, y, x-(max_dist+1), y+(max_dist+1))
				return true
			end
		end
		-- up right
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x+i, y-i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x+(max_dist+1), y-(max_dist+1))) then
				enemy_moves(pc, x, y, x+(max_dist+1), y-(max_dist+1))
				
				return true
			end
		end
		-- up left
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x-i, y-i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x-(max_dist-1), y-(max_dist+1))) then
				enemy_moves(pc, x, y, x-(max_dist+1), y-(max_dist+1))
				
				return true
			end
		end
		
		if(min_dist == 0) then
			min_dist = -1
			goto bishop_loop
		end
	elseif(pc == 11) then
		min_dist = 0
		
		::rook_loop::
		
		-- down
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x, y+i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x, y+(max_dist+1))) then
				enemy_moves(pc, x, y, x, y+(max_dist+1))
				
				return true
			end
		end
		-- left
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x-i, y)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x-(max_dist+1), y)) then
				enemy_moves(pc, x, y, x-(max_dist+1), y)
				
				return true
			end
		end
		-- right
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x+i, y)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x+(max_dist+1), y)) then
				enemy_moves(pc, x, y, x+(max_dist+1), y)
				
				return true
			end
		end
		-- up
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x, y-i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x, y-(max_dist+1))) then
				enemy_moves(pc, x, y, x, y-(max_dist+1))
				
				return true
			end
		end
		
		if(min_dist == 0) then
			min_dist = -1
			goto rook_loop
		end
		
	elseif(pc == 12) then
	 if(legal_eat(x-1,y)) then
	 	enemy_moves(pc, x, y, x-1, y)
			return true
	 elseif(legal_eat(x+1,y)) then
	 	enemy_moves(pc, x, y, x+1, y)
			
			return true
	 elseif(legal_eat(x-1,y+1)) then
	 	enemy_moves(pc, x, y, x-1, y+1)
			
			return true
	 elseif(legal_eat(x+1,y+1)) then
	 	enemy_moves(pc, x, y, x+1, y+1)
			
			return true
	 elseif(legal_eat(x,y+1)) then
	 	enemy_moves(pc, x, y, x, y+1)
			
			return true
	 elseif(legal_eat(x,y-1)) then
	 	enemy_moves(pc, x, y, x, y-1)
			
			return true
	 elseif(legal_eat(x-1,y-1)) then
	 	enemy_moves(pc, x, y, x-1, y-1)
			
			return true
	 elseif(legal_eat(x+1,y-1)) then
			enemy_moves(pc, x, y, x+1, y-1)
			
			return true
		elseif(legal_move(x-1,y)) then
	 	enemy_moves(pc, x, y, x-1, y)
			
			return true
	 elseif(legal_move(x+1,y)) then
	 	enemy_moves(pc, x, y, x+1, y)
			
			return true
	 elseif(legal_move(x-1,y+1)) then
	 	enemy_moves(pc, x, y, x-1, y+1)
			
			return true
	 elseif(legal_move(x+1,y+1)) then
	 	enemy_moves(pc, x, y, x+1, y+1)
			
			return true
	 elseif(legal_move(x,y+1)) then
	 	enemy_moves(pc, x, y, x, y+1)
			
			return true
	 elseif(legal_move(x,y-1)) then
	 	enemy_moves(pc, x, y, x, y-1)
			
			return true
	 elseif(legal_move(x-1,y-1)) then
	 	enemy_moves(pc, x, y, x-1, y-1)
			
			return true
	 elseif(legal_move(x+1,y-1)) then
			enemy_moves(pc, x, y, x+1, y-1)
			
			return true
		end
	elseif(pc == 13) then
		min_dist = 0
			
		::queen_loop::
		
		-- down right
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x+i, y+i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x+(max_dist+1), y+(max_dist+1))) then
				enemy_moves(pc, x, y, x+(max_dist+1), y+(max_dist+1))
			
				return true
			end
		end
		-- down left
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x-i, y+i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x-(max_dist+1), y+(max_dist+1))) then
				enemy_moves(pc, x, y, x-(max_dist+1), y+(max_dist+1))
				return true
			end
		end
		-- up right
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x+i, y-i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x+(max_dist+1), y-(max_dist+1))) then
				enemy_moves(pc, x, y, x+(max_dist+1), y-(max_dist+1))
				return true
			end
		end
		-- up left
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x-i, y-i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x-(max_dist+1), y-(max_dist+1))) then
				enemy_moves(pc, x, y, x-(max_dist+1), y-(max_dist+1))
				return true
			end
		end
		-- down
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x, y+i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x, y+(max_dist+1))) then
				enemy_moves(pc, x, y, x, y+(max_dist+1))
				return true
			end
		end
		-- left
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x-i, y)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x-(max_dist+1), y)) then
				enemy_moves(pc, x, y, x-(max_dist+1), y)
				return true
			end
		end
		-- right
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x+i, y)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x+(max_dist+1), y)) then
				enemy_moves(pc, x, y, x+(max_dist+1), y)
				return true
			end
		end
		-- up
		max_dist = 0
		for i=1,8 do
			if(legal_empty(x, y-i)) then
				max_dist +=1
			else
				break
			end
		end
		if(max_dist > min_dist) then
			if(legal_eat(x, y-(max_dist+1))) then
				enemy_moves(pc, x, y, x, y-(max_dist+1))
				return true
			end
		end
	
		if(min_dist == 0) then
			min_dist = -1
			goto queen_loop
		end
	end
	
	return false
end

-- for enemy
function legal_eat(x, y)
	if((x > 0 and y>2 and x <= grid_width and y<= grid_height) and ((grid[x][y] >= 2 and grid[x][y]<=7) or grid[x][y]==14)) then
		return true
	else
		return false
	end
end

function legal_eat_pieces(x,y)
	if((x > 0 and y>2 and x <= grid_width and y<= grid_height) and ((grid[x][y] >= 2 and grid[x][y]<=7))) then
		return true
	else
		return false
	end
end

function legal_empty(x,y)
	if((x > 0 and y>2 and x <= grid_width and y<= grid_height) and grid[x][y]==0) then
		return true
	else
		return false
	end
end

function legal_move(x,y)
	if((x > 0 and y>2 and x <= grid_width and y<= grid_height) and ((grid[x][y] >= 2 and grid[x][y]<=7) or grid[x][y]==14 or grid[x][y]==0)) then
		return true
	else
		return false
	end
end

-- by @kittenm4ster
function shuffle(t)
  -- do a fisher-yates shuffle
  for i = #t, 1, -1 do
    local j = flr(rnd(i)) + 1
    t[i], t[j] = t[j], t[i]
  end
end

function enemy_moves(p, x, y, tx, ty)
	if(tx > grid_width or tx <= 0 or ty>grid_height or ty <= 0) then
		return
	end
	
	if(grid[tx][ty] >= 2 and grid[tx][ty] <= 7) then
		for i=1,4 do 
			new_rubble(grid_offset_x+tx*8, ty*8-16, "player", 15)
		end
	elseif(grid[tx][ty] == 14) then
		for i=1,4 do 
			new_rubble(grid_offset_x+tx*8, ty*8-16, "ground", 15)
		end
	end
	ghost_image = {tx, ty, grid[tx][ty]}
	grid[x][y] = 0
	grid[tx][ty] = p
	target_x = tx
	target_y = ty
end


-->8
function new_rubble(x, y, typ, delay)
	rb_type = 0
	if(typ == "enemy") then
		rb_type = rnd({52, 53, 54})
	elseif(typ == "player") then
		rb_type = rnd({36, 37, 38})
	else
		rb_type = rnd({39, 40, 41})
	end
	
	local rub = {
		x = x,
		y = y,
		rubble_type = rb_type,
		speed_x = rnd(2)-1,
		speed_y = rnd(2)-1,
		lifecounter = 10,
		delay = delay
	}
	
	add(rubble, rub)
end

function update_rubble()
	tbd_rubble = {}
	for i=1,#rubble do
		if(rubble[i].delay <= 0) then
			rubble[i].x += rubble[i].speed_x
			rubble[i].y += rubble[i].speed_y
			rubble[i].speed_y += 0.05
			rubble[i].lifecounter -= 1
		end
		
		if(rubble[i].delay > 0) then
			rubble[i].delay -= 1
		elseif(rubble[i].lifecounter <= 0) then
			add(tbd_rubble, i)
		end
	end
	
	for i=1,#tbd_rubble do
		del(rubble, rubble[tbd_rubble[i]])
	end
	

end
__gfx__
555555557777777700000000000000000000000000000000000e40000000000000000000000000000000000000000000000f100000000000eecc55eeeebb55ee
555555557777777700000000000e4000000e40000e04404000e444000e04404000000000000f1000000f10000f01101000f111000f011010ecccdcceebbbdbbe
5555555577777777000e400000e44440000e40000e44444000e4440000e44400000f100000f11110000f10000f11111000f1110000f11100ccc5ccccbbb5bbbb
555555557777777700e4440000e4444000e444000e444440000e400000e4440000f1110000f1111000f111000f111110000f100000f11100cc55ccccbb55bbbb
555555557777777700e4440000e4440000e4440000e44400000e4000000e400000f1110000f1110000f1110000f11100000f1000000f1000d55cccccd55bbbbb
5555555577777777000e4000000e4000000e400000e44400000e4000000e4000000f1000000f1000000f100000f11100000f1000000f10005cccccc55bbbbbb5
555555557777777700e4440000e4440000e4440000e4440000e4440000e4440000f1110000f1110000f1110000f1110000f1110000f11100ecc5ccdeebb5bbde
55555555777777770e4444400e4444400e4444400e4444400e4444400e4444400f1111100f1111100f1111100f1111100f1111100f111110ee5ccceeee5bbbee
88888888999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007677667765665566
8000000890000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000677757775666d666
80000008900000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007776777766656666
80000008900000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007766777766556666
800000089000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056677777d5566666
80000008900000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006777777656666665
800000089000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077767756666566d5
88888888999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007767776766566656
888888887777667744444444444ee444000000000000000000000000000000000000000000000000555576755555767500000000000000005555767500000000
888888887776677744eeee4444eeee44000000000000000000000000000000000000000000000000555767555557675500000000000000005557675500000000
88888888776677774eee4ee44eeeeee4000000000000000000000000000000000000000000000000557675555576755500000000000000005576755500000000
88888888776777774ee4eee4eeeeeeee00e400000000040000044000004c000000000c00000cc000576755555767555500000000000000005767555500000000
88888888756777774e4ee4e4eeeeeeee0044000000004e000044400000cc00000000c40000ccc000767555557675555500000000000000007675555500000000
88888888667777764eee4ee44eeeeee4000000000004e00000e4000000000000000c4000004c0000675555576755555700000000000000006755555700000000
888888887777765644eeee4444eeee44000000000000000000000000000000000000000000000000755555767555557600000000000000007555557600000000
888888887777657744444444444e4444000000000000000000000000000000000000000000000000555557675555576700000000000000005555576700000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000555576755555767500000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000555767555557675500000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000557675555576755500000000000000000000000000000000
9999999900000000000000000000000000f100000000010000011000000000000000000000000000576755555767555500000000000000000000000000000000
999999990000000000000000000000000011000000001f0000111000000000000000000000000000767555557675555500000000000000000000000000000000
99999999000000000000000000000000000000000001f00000f10000000000000000000000000000675555576755555700000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000755555767555557600000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000555557675555576700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001605014050110500f0500d0500b0500b0500b0500b0500b0500c0500e0500f05012050130501505017050170501570013700117000c700077000170026700297003070034700397003d7000140001400
0001000006650096500c65010650126501565017650196501a6501b6501c6501d6501e6501e6501d6501d6501b6501a6501765015650126500e6500c650096500665001650000000000000000000000000000000
00020000237502575027750297502b7502c7502e75030750317001e3001e3001c3001b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
