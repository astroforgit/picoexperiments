pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

function frnd(n)
	return flr(rnd(n))
end

function frnda(n, o)
	local addval = o or 1
	return frnd(n)+addval
end

function wrap(value, min, max)

	if value < min then
		return max
	elseif value > max then
		return min
	else
		return value
	end
end

function table_clear(t, start_value)
	local index_start = start_value or 1
	local count = #t
	for i=index_start, count do t[i]=nil end
end

function get_index_in_table(table, entry)
	for i=1, #table do
		if table[i] == entry then
			return i
		end
	end
end

function printc(str, y, col, x)
	print(str, (x or 66)-(#str*4)/2, y, col or 7)
end

function convert_string_to_list(target_list, string_index)
	local value_string = target_list[string_index]
	target_list[string_index] = nil
	for i=0, -1+#value_string/2 do
		add(target_list, tonum(sub(value_string, 1+i*2, 2+i*2)))
	end
	return target_list
end

function get_square_offset(location)
	return c_size_border_ext+c_size_squareborder*location
end

g_list_themes = {

{"custom [editable]", "040905100814000507121009010706020001"},
{"digital grid",  	  "031102070814000210141009081000070010"},
{"classic rock",      "040905100814000507131009030706030005"},
{"good vs. evil",  	  "020800100113000107131009050706060013"},
{"bubblegum pop",			"081402121301001407131009220706220207"},
{"citrus burst",			"091004070814001103120802030311170208"},
{"super shobu",       "000102100813001009041009350908341108"},
{"i want to believe", "000103110814000506031111360700370300"},
{"king of monsters",  "000201100814000310031008421109430605"},
{"20,000 leagues",    "011200100813000112071009300706310208"},
{"night in the city",	"051301100814000107121009230009240708"},
{"freezer burn",   		"131201100814000112071009110706110006"},
{"hole in one",  		  "030905101408000410091009030706290008"},
{"all the feels",     "000201111408000113021009180802191004"},
{"natural selection",	"040305100814000410091009320712330008"},
{"a dog's breakfast", "050300110814000904151008380409391504"},
{"taco vs. hotdog",   "010300100814000410081008400911411508"},
{"the floor is lava", "090802071415000810091009121002130214"}
}

g_list_theme_entry_names = {"title", "board dark", "board light", "board edge", "highlight", "invalid", "invalid2", "background", "menu", "text", "text2", "particle 1", "particle 2", "icon", "color", "color2", "icon", "color", "color2"}
g_list_piece_sprites = {"01020304050607080910111213141516171819202122232425262728293031323334353637383940414243"}
g_list_colors = {"00010203040506070809101112131415"}

function m_move(team, sect, pos_prev, pos_cur, pos_movedpiece_prev, pos_movedpiece_cur)
	local m =
	{
		team=team,
		sect=sect,
		pos_prev=pos_prev,
		pos_cur=pos_cur,
		pos_movedpiece_prev=pos_movedpiece_prev,
		pos_movedpiece_cur=pos_movedpiece_cur,


		play=function(self)
			local target_sect = board.sects[self.sect[1]][self.sect[2]]
			-- if we moved a piece
			if pos_movedpiece_cur then
				-- if the piece is moved off the board, remove it from remaining count
				if self.pos_movedpiece_cur[1] == 0 then
					target_sect.pieces_remaining[3-self.team] -= 1
					g_cap_pieces[self.team] += 1
				else
				-- set the piece's new location to be their team (can only push opposite team)
					target_sect.squares[self.pos_movedpiece_cur[1]][self.pos_movedpiece_cur[2]] = 3-self.team
				end
			end
			-- if we moved a piece
			if pos_movedpiece_prev then
				-- set the piece's prev location to no team (if we moved into it, that will get handled below)
				target_sect.squares[self.pos_movedpiece_prev[1]][self.pos_movedpiece_prev[2]] = 0
			end

			-- set the target spot to our team's color
			target_sect.squares[self.pos_cur[1]][self.pos_cur[2]] = self.team
			-- empty out our old position
			target_sect.squares[self.pos_prev[1]][self.pos_prev[2]] = 0

			board.sects[self.sect[1]][self.sect[2]] = target_sect
		end,

		undo=function(self)
			local target_sect = board.sects[self.sect[1]][self.sect[2]]
			-- set the place we moved back to 0 (if it had a piece on it, that will get fixed below)
			target_sect.squares[self.pos_cur[1]][self.pos_cur[2]] = 0
			-- set our original position back to our team fill
			target_sect.squares[self.pos_prev[1]][self.pos_prev[2]] = self.team
			-- check if we actually moved a piece
			if pos_movedpiece_cur then
				-- use 0 position to mark a scored piece vs. just no move
				if self.pos_movedpiece_cur[1] == 0 then
					-- if we moved a piece off of the board, return the score for it
					target_sect.pieces_remaining[3-self.team] += 1
					g_cap_pieces[self.team] -= 1
				else
					-- otherwise just remove it from its new location
					target_sect.squares[self.pos_movedpiece_cur[1]][self.pos_movedpiece_cur[2]] = 0
				end
			end
			-- check if we actually moved a piece
			if pos_movedpiece_prev then
				-- place it back in its prev location
				target_sect.squares[self.pos_movedpiece_prev[1]][self.pos_movedpiece_prev[2]] = 3-self.team
			end

			board.sects[self.sect[1]][self.sect[2]] = target_sect
		end,
	}
	return m
end

list_undo_moves = {}

function undo_add(move)
	-- if we're adding a new move in the middle of the move list, clear out the old moves past this point, as they are now invalid
	if g_turn <= #list_undo_moves then
		table_clear(list_undo_moves, g_turn)
	end
	add(list_undo_moves, move)
	g_turn += 1
end

function set_row_restrict()
	if g_team_move_turn == 2 then
		g_team_move_sect_row_restrict = 0
	else
		g_team_move_sect_row_restrict = 3-g_team_active
	end
end

function undo_forward()
	-- if we're at the end of the list, return out
	if g_turn > #list_undo_moves then
		sfx(8)
		return
	end

	sfx(7)
	list_undo_moves[g_turn]:play()

	-- if this move takes us to active part of the turn, set up column restrictions and o_riginal place
	if g_team_move_turn == 1 then
		g_team_move_turn = 2

		local cur_move = list_undo_moves[g_turn]
		g_team_move_sect_column_restrict = cur_move.sect[2]
	else
		g_team_move_turn, g_team_active, g_team_move_sect_column_restrict =
			1, 3-g_team_active, 0
	end
	set_row_restrict()
	g_turn += 1
end

function undo_back()

	-- special handling if we're undoing from post-game
	if g_flow_state == c_flow_state_game_end then
		g_flow_state, g_game_winner = c_flow_state_game, 0
		m_transition({get_color(c_color_menu), get_color(c_color_menu), get_color(c_color_menu)}, 20)

		board:focus()
		-- if we forfeited, don't actually pop the last move, as there was no "decisive" move to undo
		if g_game_was_forfeited then
			g_game_was_forfeited = false
			sfx(7)
			return
		end
	end

	-- if there's not any moves to undo, return out
	if g_turn == 1 then
		sfx(8)
		return
	end
	sfx(7)
	-- if we were in the middle of moving a piece, cancel that sect
	if board:highlighted_sect():is_moving_piece() then
		board:highlighted_sect():select_cancel()
	end
	-- if we were in the first phase of a move, we need to do a bit more work to set up the state properly
	if g_team_move_turn == 1 then
		g_team_move_turn, g_team_active = 2, 3-g_team_active
		-- we need to go back to the prev first turn move
		-- to set the sect restriction and offsets
		if #list_undo_moves > 1 then
			local move_prev = list_undo_moves[g_turn-2]
			g_team_move_sect_column_restrict = move_prev.sect[2]
		end
	else
	-- otherwise just roll back to the first phase and undo the move
		g_team_move_turn = 1
		g_team_move_sect_column_restrict = 0
	end
	g_turn -= 1
	set_row_restrict()
	list_undo_moves[g_turn]:undo()
end

function sfx_get_piece()
	if g_team_move_turn == 1 then
		sfx(2)
	else
		sfx(10)
	end
end

function sfx_place_piece()
	if g_team_move_turn == 1 then
		sfx(0)
	else
		sfx(9)
	end
end

function sfx_square_move(selected_value)
	if selected_value > 0 then
		sfx(1)
	else
		sfx(11)
	end
end

function m_sect(parent, sect_id, x_off, y_off, is_color_light, list_setup)
	local s =
	{
		parent=parent,
		sect_id=sect_id,
		x_off=x_off,
		y_off=y_off,
		shake_offset_x=0,
		shake_offset_y=0,
		shake_duration=0,
		shake_intensity=0,
		x=0,
		y=0,
		is_color_light = is_color_light or false,
		squares={},
		pieces_remaining={4,4},
		cursor_row=1,
		cursor_column=1,
		selected_row=0,
		selected_column=0,
		selected_value=0,
		is_focused=false,
		is_highlighted=false,

		init=function(self, list_setup)
			table_clear(self.squares)
			for row=1, c_square_count do
				self.squares[row]={}
				for column=1, c_square_count do
					local valueToSet = 0
					if list_setup ~= nil then
						valueToSet = list_setup[row][column]
					else
						if row == 1 then
							valueToSet = 1
						elseif row == c_square_count then
							valueToSet = 2
						end
					end
					self.squares[row][column] = valueToSet
				end
			end
		end,

		select_cancel=function(self)
			set_selstate(c_selstate_sect)
			if self:is_moving_piece() then
				self.squares[self.selected_row][self.selected_column], self.selected_value, self.selected_row, self.selected_column =
				self.selected_value, 0, 0, 0
				return false
			end
			return true
		end,

		select_square=function(self)
			local piece = self.squares[self.cursor_row][self.cursor_column]
			local pieceToSet = piece
			-- If we don't have something selected already
			if self.selected_value == 0 then
				if piece ~= 0 then
					if piece == g_team_active then
						sfx_get_piece()
						set_selstate(c_selstate_square)
						self.selected_value, self.selected_row, self.selected_column, pieceToSet = piece, self.cursor_row, self.cursor_column, 0
					else
						sfx(8)
					end
				else
					sfx(8)
				end
			else
				-- if we had a piece selected, check if it can be placed here
				if self:is_move_valid(self.selected_row, self.selected_column, self.cursor_row, self.cursor_column, true) then
					pieceToSet = self.selected_value
					self.selected_value = 0
					-- only count it as an end turn if placed it in a different location than it came from
					if self.selected_row ~= self.cursor_row or self.selected_column ~= self.cursor_column then
						handle_piece_moved()
					end
					self.selected_row = 0
					self.selected_column = 0
				else
					sfx(8)
				end
			end
			self.squares[self.cursor_row][self.cursor_column] = pieceToSet
		end,

		adjust_push=function(self, x_off, y_off)
			self.x_off, self.y_off = x_off, y_off
		end,

		focus=function(self)
			self.is_focused = true
			set_selstate(c_selstate_sect)
		end,

		unfocus=function(self)
			self.is_focused = false
			set_selstate(c_selstate_board)
		end,

		handle_button=function(self, button)
			if button == 0 then
				self.cursor_column -= 1
				sfx_square_move(self.selected_value)
			end
			if button == 1 then
				self.cursor_column += 1
				sfx_square_move(self.selected_value)
			end
			if button == 2 then
				self.cursor_row -= 1
				sfx_square_move(self.selected_value)
			end
			if button == 3 then
				self.cursor_row += 1
				sfx_square_move(self.selected_value)
			end

			self.cursor_row, self.cursor_column =
			wrap(self.cursor_row, 1, c_square_count),
			wrap(self.cursor_column, 1, c_square_count)

			if button == 4 then
				if self:select_cancel() then
					sfx(6)
					self:unfocus()
				else
					sfx_place_piece()
				end
			elseif button == 5 then
				self:select_square()
			end
		end,

		is_moving_piece=function(self)
			if self.selected_value > 0 then
				return true
			else
				return false
			end
		end,

		piece_was_pushed=function(self, row, column)
			self:shake(5,1)
			m_particle_circle(self.x+c_size_square/2+get_square_offset(column-1),
			self.y+c_size_square/2+get_square_offset(row-1))
			sfx(3)
		end,

		piece_remove=function(self)
			self.pieces_remaining[3-g_team_active] -= 1
			g_cap_pieces[g_team_active] += 1
			self:shake(5,2)
			sfx(4)
			self:piece_was_pushed(self.cursor_row, self.cursor_column)
			m_particle_square_explosion(self.x+c_size_square/2+get_square_offset(self.cursor_column-1),
			self.y+c_size_square/2+get_square_offset(self.cursor_row-1))
			if self.pieces_remaining[3-g_team_active] == 0 then
				g_game_winner = g_team_active
			end
		end,

		shake=function(self, duration, intensity)
			self.shake_duration, self.shake_intensity = duration, intensity
		end,

		update=function(self)
			if g_ticks % 2 == 0 and self.shake_duration > 0 then
				self.shake_duration -= 1
				self.shake_offset_x,self.shake_offset_y =
				-self.shake_intensity+frnd(2*self.shake_intensity),
			  -self.shake_intensity+frnd(2*self.shake_intensity)
			else
				self.shake_offset_x, self.shake_offset_y = 0, 0
			end

			self.x, self.y = self.parent.x+self.x_off+self.shake_offset_x, self.parent.y+self.y_off+self.shake_offset_y
		end,

		is_move_valid=function(self, r_start, c_start, r_end, c_end, do_move)
			local do_move = do_move or false
			local targetpiece, offset_row, offset_column =
						self.squares[r_end][c_end],
						r_end - r_start,
						c_end - c_start

			-- we can always move onto the same square we started on
			if offset_row == 0 and offset_column == 0 then
				if do_move then
					sfx_place_piece()
				end
				return true
			end

			-- if we're in second turn of player's move, then we must match last turn's move
			if g_team_move_turn == 2 then
				local last_move = list_undo_moves[g_turn-1]

				if menu_info.is_open then
					last_move = g_info_last_move
				end

				if offset_row ~= last_move.pos_cur[1]-last_move.pos_prev[1] or offset_column ~= last_move.pos_cur[2]-last_move.pos_prev[2] then
					return false
				end
			end

			-- we can never move directly on another of our pieces
			if targetpiece == g_team_active then
				return false
			-- if we're in first turn of the player's move, can't move onto any other piece
			elseif g_team_move_turn == 1 and targetpiece ~= 0 then
				return false
			-- if either move is outside the range we can move, automatically fail
			elseif abs(offset_row) > 2 or abs(offset_column) > 2 then
				return false
			-- if we're only moving 1 space,
			elseif abs(offset_row) < 2 and abs(offset_column) < 2 then
				-- moves where no one is there are always fine
				if targetpiece == 0 then
					if do_move then
						undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, nil, nil))
						sfx_place_piece()
					end
					return true
				end

				-- get the location we'd push to
				local push_row, push_column = r_end+offset_row, c_end+offset_column

				-- if it pushes off the sect, then it's always safe
				if push_row < 1 or push_row > c_square_count or push_column < 1 or push_column > c_square_count then
					if do_move then
						-- a piece was moved off, so remove it from sect count
						self:piece_remove()
						undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, {r_end, c_end}, {0,0}))
					end
					return true
				-- if it pushes into empty square, then it's safe
				elseif self.squares[push_row][push_column] == 0 then
					if do_move then
						self.squares[push_row][push_column] = 3-g_team_active
						self:piece_was_pushed(push_row, push_column)
						undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, {r_end, c_end}, {push_row, push_column}))
					end
					return true
				else
				-- can't push into another piece, so fail
					return false
				end
			-- this is a 2 move on at least one axis
			else
				-- We don't allow (2, 1) moves so fail those out
				if (abs(offset_row) == 2 and abs(offset_column) == 1) or (abs(offset_row) == 1 and abs(offset_column) == 2) then
					return false
				end
				-- now only 2,2 and 2,0 type moves exist
				local push_intermediate_row, push_intermediate_column, push_row, push_column =
							r_end-offset_row/2, c_end-offset_column/2, r_end+offset_row/2, c_end+offset_column/2

				-- if there was a piece on the way to our move, we need to deal with it
				if self.squares[push_intermediate_row][push_intermediate_column] ~= 0 then
					-- if we're in turn 1 where no pushes are allowed, or the piece is our team, fail out immediately
					if g_team_move_turn == 1 or self.squares[push_intermediate_row][push_intermediate_column] == g_team_active then
						return false
					end
					-- if the place we're moving is empty, could be valid to push intermediate piece past it
					if self.squares[r_end][c_end] == 0 then
						-- if we'd push the intermediate piece off the sect, move is always good
						if push_row < 1 or push_row > c_square_count or push_column < 1 or push_column > c_square_count then
							if do_move then
								-- clear the intermediate piece
								self.squares[push_intermediate_row][push_intermediate_column] = 0
								-- remove the piece from board
								self:piece_remove()
								undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, {push_intermediate_row, push_intermediate_column}, {0, 0}))
							end
							return true
						-- if we'd push intermediate piece into an empty, move is good
						elseif self.squares[push_row][push_column] == 0 then
							if do_move then
								-- clear the intermediate piece & and set it to the pushed location
								self.squares[push_intermediate_row][push_intermediate_column], self.squares[push_row][push_column] =
								0, 3-g_team_active
								self:piece_was_pushed(push_row, push_column)
								undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, {push_intermediate_row, push_intermediate_column}, {push_row, push_column}))
							end
							return true
						-- otherwise we're trying to push intermediate into another piece, which is not allowed
						else
							return false
						end
					-- if we have to deal with pushing a piece in target location, need to check some stuff
					else
						-- if we have an intermediate piece, we can't do the move (can't push two pieces in a move)
						if self.squares[push_intermediate_row][push_intermediate_column] ~= 0 then
							return false
						-- otherwise if we'd move the piece off the sect, move is always good
						elseif push_row < 1 or push_row > c_square_count or push_column < 1 or push_column > c_square_count then
							if do_move then
								self:piece_remove()
								undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, {r_end, c_end}, {0, 0}))
							end
							return true
						-- if we'd push into empty, move is also good
						elseif self.squares[push_row][push_column] == 0 then
							if do_move then
								self.squares[push_row][push_column] = 3-g_team_active
								self:piece_was_pushed(push_row, push_column)
								undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, {r_end, c_end}, {push_row, push_column}))
							end
							return true
						-- otherwise we're pushing into an occupied space, which can't be done
						else
							return false
						end
					end
				-- if there was no intermediate piece along the way to our move, just check if we have to push a piece
				else
					-- if the place we're going is empty then it's all good
					if self.squares[r_end][c_end] == 0 then
						if do_move then
							undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, nil, nil))
							sfx_place_piece()
						end
						return true
					-- if we'd push off the sect, move is always good
					elseif push_row < 1 or push_row > c_square_count or push_column < 1 or push_column > c_square_count then
						if do_move then
							self:piece_remove()
							undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, {r_end, c_end}, {0, 0}))
						end
						return true
					-- if we'd push into a free space, move is good
					elseif self.squares[push_row][push_column] == 0 then
						if do_move then
							self.squares[push_row][push_column] = 3-g_team_active
							self:piece_was_pushed(push_row, push_column)
							undo_add(m_move(g_team_active, self.sect_id, {r_start, c_start}, {r_end, c_end}, {r_end, c_end}, {push_row, push_column}))
						end
						return true
					else
						-- since we're landing on a piece and pushing it, if the place we're pushing it is filled, we can't make that move
						return false
					end
				end
			end
			return true
		end,

		draw=function(self, color_override)
			rectfill(self.x, self.y, self.x+c_size_sect, self.y+c_size_sect, get_color(c_color_sect_edge))

			-- draw all the squarebackgrounds
			for row=1, c_square_count do
				for column=1, c_square_count do
					local x_offset, y_offset, color =
								get_square_offset(column-1),
								get_square_offset(row-1),
								get_color(c_color_sect_dark)
					if is_color_light then
						color = get_color(c_color_sect_light)
					end
					if self:is_moving_piece() then
						if not self:is_move_valid(self.selected_row, self.selected_column, row, column) then
							color = get_color(c_color_invalid)
						end
					end
					rectfill(self.x+x_offset, self.y+y_offset, self.x+x_offset+c_size_square-1, self.y+y_offset+c_size_square-1, color)
					-- if the square has apiece in it, draw it
					if self.squares[row][column] ~= 0 then
						local piece_offset = (c_size_square-8)/2
						draw_piece(self.x+x_offset+piece_offset, self.y+y_offset+piece_offset, self.squares[row][column])
					end
					pal()
				end
			end
			-- highlight the sect we're on
			if self.is_highlighted and not self.is_focused and not menu_undo.is_open then
				local color = color_override or get_color(c_color_highlight)
				rect(self.x, self.y, self.x+c_size_sect, self.y+c_size_sect, color)
			end

			-- highlight the square we have selected
			local x_cursor_offset, y_cursor_offset, cursor_color =
				get_square_offset(self.cursor_column-1),
			 	get_square_offset(self.cursor_row-1),
				get_color(c_color_highlight)

			-- if we're moving a piece, also draw the piece highlighted and a line from our old position to new
			if self:is_moving_piece() then
				local x_org_offset, y_org_offset, piece_offset, center_offset =
							get_square_offset(self.selected_column-1),
							get_square_offset(self.selected_row-1),
							(c_size_square-8)/2,
							c_size_square/2

				if not self:is_move_valid(self.selected_row, self.selected_column, self.cursor_row, self.cursor_column) then
					cursor_color = get_color(c_color_invalid_sec)
				end

				line(self.x+x_cursor_offset+center_offset, self.y+y_cursor_offset+center_offset, self.x+x_org_offset+center_offset, self.y+y_org_offset+center_offset, cursor_color) --get_team_color(g_team_active))
				circfill(self.x+x_org_offset+center_offset, self.y+y_org_offset+center_offset, 1, get_team_color(g_team_active))
				draw_piece(self.x+x_cursor_offset+piece_offset, self.y+y_cursor_offset+piece_offset, self.selected_value, cursor_color)

				-- highlight the square we have focused based on whether we're moving to a good location
				rect(self.x+x_cursor_offset, self.y+y_cursor_offset, self.x+x_cursor_offset+c_size_square-1, self.y+y_cursor_offset+c_size_square-1, cursor_color)
			else
				-- if we're not yet moving a piece, but this sect is in focus, highlight the square we have focused based on if we can move the piece underneath us
				if self.is_highlighted and self.is_focused and not menu_undo.is_open then
					if self.squares[self.cursor_row][self.cursor_column] == 0 or self.squares[self.cursor_row][self.cursor_column] == 3-g_team_active then
						cursor_color = get_color(c_color_invalid)
					end
					rect(self.x+x_cursor_offset, self.y+y_cursor_offset, self.x+x_cursor_offset+c_size_square-1, self.y+y_cursor_offset+c_size_square-1, cursor_color)

				end
			end

			-- if we're in the active state of a turn, show a line indicating the Passive move we just did in the other side
			if g_team_move_turn == 2 then
				local last_move = list_undo_moves[g_turn-1]
				if menu_info.is_open then
					last_move = g_info_last_move
				end
				if last_move.sect[1] == self.sect_id[1] and last_move.sect[2] == self.sect_id[2] then
					local x_cursor_offset, y_cursor_offset, x_org_offset, y_org_offset =
								get_square_offset(last_move.pos_cur[2]-1),
								get_square_offset(last_move.pos_cur[1]-1),
								get_square_offset(last_move.pos_prev[2]-1),
								get_square_offset(last_move.pos_prev[1]-1)

					local center_offset = c_size_square/2
					circfill(self.x+x_org_offset+center_offset, self.y+y_org_offset+center_offset, 1, get_team_color(last_move.team))

					line(self.x+x_cursor_offset+center_offset, self.y+y_cursor_offset+center_offset, self.x+x_org_offset+center_offset, self.y+y_org_offset+center_offset, get_team_color(last_move.team)) --get_team_color(g_team_active))
				end
			end
		end,
	}
	s:init(list_setup)
	return s
end

list_particles = {}

function m_particle(x,y, angle, speed, friction, radius, lifetime, color, color_decay)
  local p =
  {
    x=x,
    y=y,
    angle=angle,
    speed=speed,
		friction=friction,
    radius=radius,
		lifetime=lifetime,
		lifetime_max=lifetime,
    color=color,
		color_decay=color_decay,

    update=function(self)
			self.lifetime -= 1
			if self.lifetime <= 0 then
				del(list_particles, self)
				return
			end

			self.x += cos(self.angle) * self.speed
			self.y += sin(self.angle) * self.speed
			self.speed = self.speed*self.friction
    end,

    draw=function(self)
			local color = self.color
			if self.lifetime/self.lifetime_max < .5 then
				color = self.color_decay
			end
   		rectfill(self.x,self.y, self.x+self.radius, self.y+self.radius, color)
    end,
  }
	add(list_particles, p)
  return p
end

function m_particle_square_explosion(x,y)

	for i=1, 20 do
		local color = get_color(c_color_particle)
		local color_decay = get_color(c_color_particle_sec)
		if frnd(100) < 25 then
			color, color_decay = 7, 5
		end
		m_particle(x, y, rnd(1), 1+rnd(1), .95, rnd(1), 15+frnd(15), color, color_decay)
	end

end

function m_particle_circle(x,y)
	local p =
	{
		x=x,
		y=y,
		radius_cur=0,

		update=function(self)
			if g_ticks % 1 == 0 then
				self.radius_cur += 1
				if self.radius_cur > 10 then
					del(list_particles, self)
					return
				end
			end
		end,

		draw=function(self)
			local circle_color = get_color(c_color_particle)
			if self.radius_cur/10 > .5 then
			circle_color = get_color(c_color_particle_sec)
			end
			circ(self.x, self.y, self.radius_cur, circle_color)
		end,
	}
	add(list_particles, p)
	return p
end

function get_team_index(team)
	if team == 1 then
		return c_color_piece_teamone
	else
		return c_color_piece_teamtwo
	end
end

function get_team_color(team, issecondary)
	if team == 1 then
		if issecondary then
			return get_color(c_color_piece_teamone_sec)
		else
			return get_color(c_color_piece_teamone)
		end
	else
		if issecondary then
			return get_color(c_color_piece_teamtwo_sec)
		else
			return get_color(c_color_piece_teamtwo)
		end
	end
end

function draw_piece(x, y, team, override_color)
	if team == 0 then
		return
	end
	if override_color then
		pal(7, override_color)
		pal(8, override_color)
	else
		pal(7, get_team_color(team))
		pal(8, get_team_color(team, true))
	end
	local team_index = i_piece_teamone
	if team == 2 then
		team_index = i_piece_teamtwo
	end
	spr(g_list_piece_sprites[g_list_themes[g_theme][team_index]], x, y)
	pal()
end

function m_board()
  local b =
  {
    x=0,
    y=0,
		sects={},
		cursor_column=1,
		cursor_row=1,
		is_focused=false,

		init=function(self)
			for row=1, 2 do
				self.sects[row]={}
				for column=1, 2 do
					self.sects[row][column] = m_sect(self, {row,column}, 0, 0, column == 2)
				end
			end
			self:adjust_push()
		end,

		adjust_push=function(self)
			local total_size = c_size_sect*2+c_size_sect_separation
      self.x = (127-total_size)/2
      self.y = self.x
			for row=1, 2 do
				for column=1,2 do
					local target_x, target_y, color = 0, 0, get_color(c_color_sect_dark)
					if column == 2 then
						target_x = c_size_sect+c_size_sect_separation+1
						color = get_color(c_color_sect_light)
					end
					if row == 2 then
						target_y = c_size_sect+c_size_sect_separation+1
					end
					self.sects[row][column]:adjust_push(target_x, target_y, c_square_count, c_size_square, c_size_border_int, c_size_border_ext)
				end
			end
		end,

		highlighted_sect=function(self)
			return self.sects[self.cursor_row][self.cursor_column]
		end,

		focus=function(self)
			self.is_focused, self.sects[self.cursor_row][self.cursor_column].is_highlighted = true, true
			set_selstate(c_selstate_board)
			sfx(5)
		end,

		unfocus=function(self)
			self.is_focused, self.sects[self.cursor_row][self.cursor_column].is_highlighted = false, false
			set_selstate(c_selstate_main)
		end,

		handle_button=function(self, button)
			self.sects[self.cursor_row][self.cursor_column].is_highlighted = false
			if button == 0 then
				self.cursor_column -= 1
				sfx(11)
			end
			if button == 1 then
				self.cursor_column += 1
				sfx(11)
			end
			if button == 2 then
				self.cursor_row -= 1
				sfx(11)
			end
			if button == 3 then
				self.cursor_row += 1
				sfx(11)
			end

			self.cursor_row = wrap(self.cursor_row, 1, 2)
			self.cursor_column = wrap(self.cursor_column, 1, 2)

			self.sects[self.cursor_row][self.cursor_column].is_highlighted = true

			if button == 4 then
				sfx(8)
			end
			if button == 5 then
				if self.cursor_column ~= g_team_move_sect_column_restrict and self.cursor_row ~= g_team_move_sect_row_restrict then
					sfx(5)
					self.sects[self.cursor_row][self.cursor_column]:focus()
				else
					sfx(8)
				end
			end

		end,

    update=function(self)
			for row=1, 2 do
				for column=1, 2 do
					self.sects[row][column]:update()
				end
			end
    end,

    draw=function(self)
			for row=1, 2 do
				for column=1, 2 do
					if column ~= g_team_move_sect_column_restrict and row ~= g_team_move_sect_row_restrict then
						self.sects[row][column]:draw()
					else
						self.sects[row][column]:draw(get_color(c_color_invalid))
					end
				end
			end

			-- trays and labels

			if g_draw_labels then
				local abc = "abcdefgh"
				for k=0, 1 do
					for i=0, 7 do
						local sect_offset = 0
						if i > 3 then
							sect_offset = 7
						end
						print(i+1, 11+k*103, 21+sect_offset+i*11, get_color(c_color_text_secondary))
						print(sub(abc, i+1, i+1), 21+sect_offset+i*11, 10+k*103, get_color(c_color_text_secondary))
					end
				end
			else
				rectfill(0, 9, 127, 12, get_color(c_color_piece_teamone))
				rectfill(0, 115, 127, 118, get_color(c_color_piece_teamtwo))


				for team=1, 2 do
					local teamoff = 13+101*(team-1)
					line(0, teamoff, 127, teamoff, get_color(c_color_menu))
					if team == 2 then
						teamoff += 5
					end
					for i=0, g_cap_pieces[team]-1 do
						pal(7, get_team_color(3-team))
						spr(0, 60-((g_cap_pieces[team]-1)*4)+8*i, -6+teamoff)
						pal()
					end
				end
			end
    end,
  }
  b:init()
  return b
end

function menu_forfeit()
	if g_flow_state == c_flow_state_game_end or g_selstate == c_selstate_main then
		sfx(8)
		return
	end
	sfx(5)
	menu_options:close()
	menu_undo:close_cancel()

	g_game_was_forfeited = true
	g_game_winner = 3-g_team_active
end

function menu_toggle_labels()
	sfx(5)
	g_draw_labels = not g_draw_labels
	board:adjust_push()
end

function handle_move_clear()
	set_row_restrict()
	board:highlighted_sect():unfocus()
end

function handle_turn_swap()
	g_team_active, g_team_move_turn, g_team_move_sect_column_restrict = 3-g_team_active, 1, 0
	handle_move_clear()
end

function handle_piece_moved()
	if g_team_move_turn == 2 then
		handle_turn_swap()
	else
		g_team_move_sect_column_restrict, g_team_move_turn = board.cursor_column, 2
		handle_move_clear()
	end
end

function do_game_end()
	board:highlighted_sect():select_cancel()
	board:highlighted_sect():unfocus()
	board:unfocus()
	g_ticks_banner, g_banner_offset, g_flow_state = 0, 0, c_flow_state_game_end
	set_selstate(c_selstate_game_end)
	m_transition({7, 12, 1}, 20)
end

function setup()
	convert_string_to_list(g_list_piece_sprites, 1)
	convert_string_to_list(g_list_colors,1)

	foreach(g_list_themes, function(theme)
		convert_string_to_list(theme, 2)
	end)
	savedata_load()

	c_square_count,
	c_size_square,
	c_size_border_int,
	c_size_border_ext,
	c_size_sect_separation,

	c_color_sect_dark,
	c_color_sect_light,
	c_color_sect_edge,
	c_color_highlight,
	c_color_invalid,
	c_color_invalid_sec,

	c_color_background,
	c_color_menu,
	c_color_text,
	c_color_text_secondary,

	c_color_particle,
	c_color_particle_sec,

	i_piece_teamone,
	c_color_piece_teamone,
	c_color_piece_teamone_sec,
	i_piece_teamtwo,
	c_color_piece_teamtwo,
	c_color_piece_teamtwo_sec,

	c_flow_state_game,
	c_flow_state_game_end,

	c_selstate_main,
	c_selstate_game_end,
	c_selstate_board,
	c_selstate_sect,
	c_selstate_square,

	c_selstate_menu_undo,
	c_selstate_menu_options,
	c_selstate_menu_options_selected,
	c_selstate_menu_info,
	g_draw_labels

	= 4, 10, 1, 2, 2,
		2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
	  1, 2,
	  1, 2, 3, 4, 5, 6, 7, 8, 9,
		false

	c_size_sect = c_size_square*c_square_count+
		c_size_border_int*(c_square_count-1)+
		c_size_border_ext*2
		-1

	c_size_squareborder = c_size_border_int+c_size_square

	menu_options = m_menu_options()
	menu_undo = m_menu_undo()
	header = m_header()
	menu_info = m_menu_info()
	menuitem(1, "undo", menu_undo_open)
	menuitem(2, "toggle labels", menu_toggle_labels)
	menuitem(3, "themes", menu_options_open)
	menuitem(4, "instructions", menu_info_open)
	menuitem(5, "forfeit", menu_forfeit)
  reset()
end

function reset()
	header = m_header()
	g_ticks,
	g_ticks_banner,
	g_turn,
	g_team_active,
	g_team_move_turn,
	g_team_move_sect_column_restrict,
	g_team_move_sect_row_restrict,
	g_flow_state,
	g_selstate,

	g_cap_pieces,

	g_game_winner,
	g_game_was_forfeited,
	g_banner_offset

	= 0, 0,
	  1, 1, 1, 0, 0,
		c_flow_state_game,
		c_selstate_main,

		{0, 0},

		0,
		false,
		0

  board = m_board()
	table_clear(list_undo_moves)
	table_clear(list_particles)
	m_transition({get_color(c_color_menu), get_color(c_color_menu), get_color(c_color_menu)}, 20)
	set_row_restrict()
end

list_transitions = {}

function m_transition(list_transition_colors, duration)
	local t =
	{
		list_transition_colors = list_transition_colors,
		duration_initial = duration,
		duration_remaining = duration,

		update=function(self)
			self.duration_remaining -= 1
			if self.duration_remaining == 0 then
				del(list_transitions, self)
			end
		end,

		draw=function(self)
			local duration_percent = self.duration_remaining/self.duration_initial
			local color = self.list_transition_colors[1]
			fillp(0b0000000000000000)
			if duration_percent < .3 then
				color = self.list_transition_colors[3]
				fillp(0b0101111001011011.1)
			elseif duration_percent < .6 then
				color = self.list_transition_colors[2]
				fillp(0b1010010110100101.1)
			end
			rectfill(0, 0, 127, 127, color)
			fillp(0b0000000000000000)
		end,
	}
	add(list_transitions, t)
	return t
end

function savedata_save()
	dset(0, g_theme)
	for i=2, #g_list_themes[1] do
		dset(i,	g_list_themes[1][i])
	end
end

function savedata_load()
	cartdata("tmirobot_shobu_v1")

	g_theme = dget(0)
	if g_theme == 0 then
		g_theme = 2
	else
		for i=2, #g_list_themes[1] do
			local loadvalue = dget(i)
			g_list_themes[1][i] = loadvalue
		end
	end
end

function _init()
	setup()
end


function get_color(color_to_get)
	return g_list_themes[g_theme][color_to_get]
end

function _update60()
	g_ticks += 1
	foreach(list_transitions, function(transition)
		transition:update()
	end)

	local button = 999
	if btnp(0) then
		button = 0
	elseif btnp(1) then
		button = 1
	elseif btnp(2) then
		button = 2
	elseif btnp(3) then
		button = 3
	elseif btnp(4) then
		button = 4
	elseif btnp(5) then
		button = 5
	end

	if button ~= 999 then
		if g_selstate == c_selstate_main then
			if button == 5 then
				m_transition({7, 12, 1}, 20)
				sfx(13, -2)
				board:focus()
			elseif button == 4 then
				sfx(8)
			end
		elseif g_selstate == c_selstate_game_end then
			if button == 4 then
				undo_back()
			end
			if button == 5 then
				sfx(5)
				reset()
			end
		elseif g_selstate == c_selstate_board then
			board:handle_button(button)
		elseif g_selstate == c_selstate_sect then
			board:highlighted_sect():handle_button(button)
		elseif g_selstate == c_selstate_square then
			board:highlighted_sect():handle_button(button)
		elseif g_selstate == c_selstate_menu_options then
			menu_options:handle_button(button)
		elseif g_selstate == c_selstate_menu_undo then
			menu_undo:handle_button(button)
		elseif g_selstate == c_selstate_menu_info then
			menu_info:handle_button(button)
		end
	end

	if g_flow_state == c_flow_state_game_end or g_selstate == c_selstate_main then
		g_ticks_banner += 1
		if (g_ticks_banner > 32 and g_ticks_banner <= 74) or (g_flow_state == c_flow_state_game_end and (g_ticks_banner > 100 and g_ticks_banner <= 200)) then
			if g_ticks_banner == 40 then
		   	if g_selstate == c_selstate_main then
					sfx(13)
				else
					sfx(12)
				end
			end
			if g_ticks_banner > 59 and g_ticks_banner < 110 then
				if g_ticks_banner > 68 and g_ticks_banner < 107 then
					g_banner_offset += 1
				else
					g_banner_offset += 2
				end
			else
				g_banner_offset += 4
			end
		end
	elseif g_game_winner > 0 then
		do_game_end()
	end

	menu_options:update()
	menu_undo:update()
	board:update()
	menu_info:update()
	foreach(list_particles, function(p)
		p:update()
	end)
end

function draw_banner_shobu()
	local color_back = get_color(c_color_background)
	local color_front = get_color(c_color_text)
	pal(7, color_front)

	rectfill(-1, -83+g_banner_offset, 128, -54+g_banner_offset, color_front)
	rectfill(-1, -82+g_banner_offset, 128, -55+g_banner_offset, color_back)
	spr(160, 24, -80+g_banner_offset, 10, 2)
	print("by @tmi_robot", 38, -61+g_banner_offset, color_front)
	pal()
end

function draw_banner_win()
	local color_back = get_team_color(g_game_winner)
	local color_front = get_team_color(3-g_game_winner)


	rectfill(131-g_banner_offset, 39, 128-g_banner_offset+132, 62, color_front)
	rectfill(132-g_banner_offset, 40, 128-g_banner_offset+131, 61, color_back)

	rectfill(-133+g_banner_offset, 66, -128+g_banner_offset+124, 89, color_front)
	rectfill(-132+g_banner_offset, 67, -128+g_banner_offset+123, 88, color_back)

	pal(7, color_front)
	spr(64, 145-g_banner_offset, 43, 12, 2)
	spr(96, -111+g_banner_offset, 70, 8, 2)
	spr(104+2*g_game_winner, -31+g_banner_offset, 70, 2, 2)

	pal()
end

function _draw()

	cls(get_color(c_color_background))
	board:draw()
	header:draw()
	menu_options:draw()
	menu_info:draw()
	foreach(list_particles, function(p)
		p:draw()
	end)

	if g_selstate == c_selstate_game_end then
		draw_banner_win()
	end

	if g_selstate == c_selstate_main then
		draw_banner_shobu()
	end

	foreach(list_transitions, function(transition)
		transition:draw()
	end)
end

function get_header_text_for_movement()
	local turn = "passive"
	if g_team_move_turn == 2 then
		turn = "active"
	end
	if g_team_active == 1 then
		return "team 1: "..turn, c_color_piece_teamone
	else
		return "team 2: "..turn, c_color_piece_teamtwo
	end
end

function m_header()
	local h =
	{
		text = "",
		keyprompts = "\151play | [start] options",
		color = c_color_text,
		offset = 0,

		draw=function(self)
			rectfill(0, 0, 127, 8, get_color(c_color_menu))
			local team_to_draw = g_team_active
			if g_selstate == c_selstate_game_end then
				team_to_draw = g_game_winner
			end

			if g_selstate > c_selstate_main and g_selstate <= c_selstate_menu_undo then
				draw_piece(20, 0, team_to_draw)
				draw_piece(102, 0, team_to_draw)
			end
			rectfill(0, 119, 127, 127, get_color(c_color_menu))

			printc(self.keyprompts, 121, get_color(c_color_text), 64-self.offset)

			if (menu_undo.is_open and g_turn > 1) or (menu_info.is_open and menu_info.page_cur > 1) then
				print("\139", 2, 2, get_color(c_color_text))
			end
			if (menu_undo.is_open and g_turn <= #list_undo_moves) or (menu_info.is_open and menu_info.page_cur < menu_info.page_max) then
				print("\145", 119, 2, get_color(c_color_text))
			end
			printc(self.text, 2, get_color(self.color))
		end,

		set=function(self, text, color, keyprompts, offset)
			self.text = text
			self.color = color
			self.keyprompts = keyprompts
			self.offset = offset
		end,
	}
	return h
end

function set_selstate(selstate)

	if menu_undo.is_open then
		menu_undo.original_selstate = selstate
	else
		local team_header_text, team_header_color = get_header_text_for_movement()
		if selstate ~= c_selstate_menu_options_selected then
			g_selstate = selstate
		end
		if g_selstate == c_selstate_main then
			header:set("", c_color_text, "\151play | [start] options", 0)
		elseif g_selstate == c_selstate_game_end then
			header:set("winner: team "..g_game_winner, get_team_index(g_game_winner), "\142 undo | \151 restart", 3)
		elseif selstate == c_selstate_board then
			header:set(team_header_text, team_header_color, "\139\145\131\148 | \151select", 8)
		elseif selstate == c_selstate_sect then
			header:set(team_header_text, team_header_color, "\139\145\131\148 | \151select | \142back ", 11)
		elseif selstate == c_selstate_square then
			header:set(team_header_text, team_header_color,"\139\145\131\148 | \151place | \142cancel", 11)
		elseif selstate == c_selstate_menu_options then
			if menu_options.row_cur > 1 then
				header:set("themes", c_color_text, "\139\145\131\148 | \151select | \142back", 12)
			else
				if menu_options_theme_is_editable() then
					header:set("themes", c_color_text, "\139\145 | \151edit | \142save", 6)
				else
					header:set("themes", c_color_text, "\139\145 | \142save", 0)
				end
			end
		elseif selstate == c_selstate_menu_options_selected then
			header:set("themes", c_color_text, "\139\145 | \151confirm | \142cancel", 8)
		elseif selstate == c_selstate_menu_undo then
			header:set("undo moves", team_header_color, "\139\145 | \151confirm | \142cancel ", 6)
		elseif selstate == c_selstate_menu_info then
			header:set("instructions", c_color_text, "\139\145 | \142close", 4)
		end
	end
end

function m_menu_options_entry(parent, name, offset_x, offset_y, theme_index, list_choices)
	local e =
	{
		parent = parent,
		name = name,
		offset_x = offset_x,
		offset_y = offset_y,
		x = 0,
		y = 0,
		is_highlighted = false,
		is_selected = false,
		is_category_row = false,
		choice_cur = 1,
		choice_original = 1,
		theme_index = theme_index,
		list_choices = list_choices,

		update_value=function(self)
		end,

		init_value=function(self)
		end,

		update=function(self)
			self.x = self.parent.x+self.offset_x
			self.y = self.parent.y+self.offset_y
		end,

		highlight=function(self)
			self.is_highlighted = true
		end,

		unhighlight=function(self)
			self.is_highlighted = false
		end,

		select=function(self)
			self.is_selected = true
			set_selstate(c_selstate_menu_options_selected)
			self.choice_original = self.choice_cur
		end,

		unselect=function(self)
			self.is_selected = false
			set_selstate(c_selstate_menu_options)
		end,

		cancel=function(self)
			if self.is_selected == false then
				return
			end
			self.choice_cur = self.choice_original
			self:update_value()
			self:unselect()
		end,

		adjust_choice=function(self, amount)
			sfx(7)
			self.choice_cur += amount
			self.choice_cur = wrap(self.choice_cur, 1, #self.list_choices)
			if self.is_category_row then
				set_selstate(c_selstate_menu_options)
			end
			self:update_value()
		end,

		handle_button=function(self, button)
			if self.is_selected or self.is_category_row then
				if button == 0 then
					self:adjust_choice(-1)
				elseif button == 1 then
					self:adjust_choice(1)
				elseif button == 2 or button == 3 then
					sfx(8)
				elseif button == 4 then
					sfx(6)
					if self.is_category_row then
						return false
					end
					self:cancel()
				elseif button == 5 then
					if self.is_category_row then
						if menu_options_theme_is_editable() then
							menu_options:row_adjust(1)
							if not self.is_selected then
								set_selstate(c_selstate_menu_options)
							end
							sfx(5)
							return true
						else
							sfx(8)
							return true
						end
					end
					sfx(5)
					self:unselect()

				end
				return true
			else
				if button == 5 then
					sfx(5)
					self:select()
					return true
				end
			end
			return false
		end,
	}
	return e
end

function m_menu_options_entry_theme(parent, name, offset_x, offset_y, theme_index, list_choices)
	local e = m_menu_options_entry(parent, name, offset_x, offset_y, theme_index, list_choices)

	e.choice_cur = g_theme

	e.is_category_row = true

	e.update_value=function(self)
		g_theme = self.choice_cur
		menu_options:refresh()
	end

	e.draw=function(self)
		local color = get_color(c_color_text_secondary)
		if self.is_selected then
			color = get_color(c_color_invalid)
		elseif self.is_highlighted then
			color = get_color(c_color_highlight)
		end

		print(self.list_choices[self.choice_cur], self.x, self.y, color)
	end

	return e
end

function m_menu_options_entry_color(parent, name, offset_x, offset_y, theme_index)
	local e = m_menu_options_entry(parent, name, offset_x, offset_y, theme_index, g_list_colors)

	e.init_value=function(self)
		self.choice_cur = get_index_in_table(g_list_colors, g_list_themes[g_theme][theme_index])
	end

	e:init_value()

	e.update_value=function(self)
		g_list_themes[g_theme][theme_index]=g_list_colors[self.choice_cur]
	end

	e.draw=function(self)
		local color = get_color(c_color_menu)
		if self.is_selected then
			color = get_color(c_color_invalid)
		elseif self.is_highlighted then
			color = get_color(c_color_highlight)
		end
		rectfill(self.x, self.y, self.x+9, self.y+9, self.list_choices[self.choice_cur])
		rect(self.x, self.y, self.x+9, self.y+9, color)
	end

	return e
end

function m_menu_options_entry_piece(parent, name, offset_x, offset_y, theme_index, whichteam)
	local e = m_menu_options_entry(parent, name, offset_x, offset_y, theme_index, g_list_piece_sprites)

	e.team = whichteam

	e.init_value=function(self)
		self.choice_cur = g_list_themes[g_theme][theme_index]
	end

	e:init_value()

	e.update_value=function(self)
		g_list_themes[g_theme][theme_index]=self.choice_cur
	end

	e.draw=function(self)
		local color = get_color(c_color_menu)
		if self.is_selected then
			color = get_color(c_color_invalid)
		elseif self.is_highlighted then
			color = get_color(c_color_highlight)
		end
		rectfill(self.x, self.y, self.x+9, self.y+9, g_list_themes[g_theme][c_color_sect_dark])
		rect(self.x, self.y, self.x+9, self.y+9, color)

		draw_piece(self.x+1, self.y+1, self.team)
	end

	return e
end

function menu_options_theme_is_editable()
	if menu_options.rows[1].list_entries[1].choice_cur == 1 then
		return true
	end
  return false
end

function m_menu_options_row(parent, offset_x, offset_y, title, list_entries, is_grid)
	local r =
	{
		parent = parent,
		offset_x = offset_x,
		offset_y = offset_y,
		x = 0,
		y = 0,
		title = title,
		list_entries = list_entries,
		is_grid = is_grid or false,
		entry_row = 1,
		entry_column = 1,
		is_highlighted = false,


		refresh=function(self)
			if self.is_grid then
				for column=1, #self.list_entries do
					for row=1, #self.list_entries[column] do
						self.list_entries[column][row]:init_value()
					end
				end
			else
				foreach(self.list_entries, function(entry)
					entry:init_value()
				end)
			end
		end,

		highlight=function(self)
			self.is_highlighted = true
			self.entry_column = 1
			if self.is_grid then
				self.list_entries[self.entry_column][self.entry_row]:highlight()
			else
				self.list_entries[self.entry_column]:highlight()
			end
		end,

		unhighlight=function(self)
			self.is_highlighted = false
			if self.is_grid then
				self.list_entries[self.entry_column][self.entry_row]:unhighlight()
			else
				self.list_entries[self.entry_column]:unhighlight()
			end
		end,

		get_cur_entry=function(self)
			if self.is_grid then
				return self.list_entries[self.entry_column][self.entry_row]
			else
				return self.list_entries[self.entry_column]
			end
		end,


		handle_button=function(self, button)
			if button >= 0 and button <= 3 then
				self:get_cur_entry():unhighlight()
			end
			if button == 0 then
				if not self:get_cur_entry():handle_button(0) then
					if #self.list_entries == 1 then
						sfx(8)
					else
						self.entry_column -= 1
						sfx(7)
					end
				end
				self.entry_column = wrap(self.entry_column, 1, #self.list_entries)
				self:get_cur_entry():highlight()
				return true
			end
			if button == 1 then
				if not self:get_cur_entry():handle_button(1) then
					if #self.list_entries == 1 then
						sfx(8)
					else
						self.entry_column += 1
						sfx(7)
					end
				end
				self.entry_column = wrap(self.entry_column, 1, #self.list_entries)
				self:get_cur_entry():highlight()
				return true
			end

			if button == 4 then
				if not self:get_cur_entry():handle_button(4) then
					return false
				end
				return true
			end
			if button == 5 then
				if not self:get_cur_entry():handle_button(5) then
					return false
				end
				return true
			end

			if self.is_grid then
				if button == 2 then
					if not self:get_cur_entry():handle_button(2) then
						self.entry_row -= 1
						if self.entry_row < 1 then
							self.entry_row = #self.list_entries[self.entry_column]
							return false
						end
						sfx(7)
					end
				end
				if button == 3 then
					if not self:get_cur_entry():handle_button(3) then
						self.entry_row += 1
						if self.entry_row > #self.list_entries[self.entry_column] then
							self.entry_row = 1
							return false
						end
						sfx(7)
					end
				end
				self:get_cur_entry():highlight()
				return true
			else
				if button == 2 or button == 3 then
					if self:get_cur_entry():handle_button(button) then
						self:get_cur_entry():highlight()
						return true
					end
				end
			end
			return false
		end,

		update=function(self)
			self.x = self.parent.x+self.offset_x
			self.y = self.parent.y+self.offset_y
			if self.is_grid then
				for column=1, #self.list_entries do
					for row=1, #self.list_entries[column] do
						self.list_entries[column][row]:update()
					end
				end
			else
				foreach(self.list_entries, function(entry)
					entry:update()
				end)
			end
		end,

		draw=function(self)
			rectfill(self.x, self.y, self.x+75, self.y+6, get_color(c_color_menu))
			local title = self.title
			if self.is_highlighted and self:get_cur_entry().name ~= "" then
				title = title..": "..self:get_cur_entry().name
			end
			print(title, self.x+2, self.y+1, get_color(c_color_text))
			if self.is_grid then
				for column=1, #self.list_entries do
					for row=1, #self.list_entries[column] do
						self.list_entries[column][row]:draw()
					end
				end
			else
				foreach(self.list_entries, function(entry)
					entry:draw()
				end)
			end
		end,
	}
	return r
end

g_info_sect_one = nil
g_info_sect_two = nil

function m_menu_info()
	local m =
	{
		x=0,
		y=0,
		is_open = false,
		original_selstate=0,
		page_cur = 1,
		page_max = 11,
		page_text = "",
		page_text_highlight = "",
		original_team = 0,
		original_turn_move = 0,

		init=function(self, page)
			if page == 1 then
				self.page_text =           "overview\n\nin shobu, the play area is\ndivided into four boards.\n\nthe goal of the game is to\npush all of your opponent's\npieces off of any one of the\nfour boards.\n\nthe two boards on your side of\nthe play area are known as\nyour home boards."
				self.page_text_highlight = "overview\n\n   shobu\n                  boards\n\n\n     all\n              any one\n\n\n\n\n     home boards"
			elseif page == 2 then
				self.page_text           = "turns\n\non your turn, you must\nmake two moves:\n\nfirst, a [passive] move, and\nthen an [active] move."
				self.page_text_highlight = "turns\n\n                  must\n     two\n\n         [passive]\n        [active]"
			elseif page == 3 then
				self.page_text           = "passive move\n\nfor your [passive] move, you\nmay only select a piece from \nyour home boards.\n\nyou may move this piece up\nto 2 spaces in any direction."
				self.page_text_highlight = "passive move\n\n         [passive]\n\n     home boards"
			elseif page == 4 then
				self.page_text 					 = "passive move (cont'd)\n\nduring your [passive] move,\nyou may not push any other\npieces."
				self.page_text_highlight = "passive move (cont'd)\n\n            [passive]\n        not"
			elseif page == 5 then
				self.page_text =           "active move\n\nfor your [active] move, you\nmust repeat your [passive]\nmove with one of your pieces\non an opposite-colored board."
				self.page_text_highlight = "active move\n\n         [active]\n                 [passive]\n\n      opposite-colored"
			elseif page == 6 or page == 7 then
				self.page_text =					 "active move (cont'd)\n\nduring your [active] move,\nyou may push your opponent's\npieces."
				self.page_text_highlight = "active move (cont'd)\n\n            [active]\n    may"
			elseif page == 8 then
				self.page_text =					 "illegal moves\n\nif you cannot replicate your\n[passive] move on an opposite-\ncolored board, your [passive]\nmove is not allowed, and must \nbe undone using the undo menu."
				self.page_text_highlight = "illegal moves\n\n\n[passive]\n                    [passive]\n\n                    undo menu"
			elseif page == 9 then
				self.page_text = 					 "strategies\n\n- make moves on every board to\n  optimize your opportunities.\n- secure two goals in a single\n  turn. attack and protect.\n- pieces positioned between\n  two enemy pieces are safe\n  and a threat to both pieces.\n- avoid bunching your pieces\n  on a single side, as it\n  limits your potential moves.\n- blocking an enemy's passive\n  move is better than running\n  from their active moves."
				self.page_text_highlight = "strategies"
			elseif page == 10 then
				self.page_text =					 "menus\n\npress the [start] button to\naccess:\n\n- undo: roll back bad moves\n    and make a new decision.\n- toggle labels: toggle\n    row & column labels.\n- themes: select game visuals\n    or edit a custom theme.\n- instructions: this manual.\n- forfeit: give up the current\n    game."
				self.page_text_highlight = "menus\n\n          [start]\n\n\n  undo\n\n  toggle labels\n\n  themes\n\n  instructions\n  forfeit"
			elseif page == 11 then
				self.page_text =					 "\n\n\n          based on the\n       original boardgame\n\n             shobu\n\n       by  manolis vranas\n         & jamie sajdak\n\n           (c) 2020\n     smirk & laughter games"
				self.page_text_highlight = "\n\n\n\n\n\n             shobu"
			end
			if page == 7 then
				self.page_text = self.page_text.."\n\npieces pushed off of the board\nare lost forever."
			end

			if self.is_open then
				g_team_move_turn, g_team_active = 1, 1
			end

			g_info_sect_one, g_info_sect_two =
			  m_sect(self, {1,1}, 16, 65, false, {{0, 1, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 2}, {2, 1, 0, 0}}),
			  m_sect(self, {1,2}, 65, 65, true, {{1, 0, 2, 0}, {1, 0, 0, 0}, {2, 0, 1, 1}, {0, 0, 2, 0}})

			if page == 1 or page == 2 then
				g_info_sect_one.squares[2][1] = 1
			end
			if page == 3 or page == 4 then
				g_info_sect_one.selected_row,
				g_info_sect_one.selected_column,
				g_info_sect_one.selected_value,
				g_info_sect_one.cursor_row,
				g_info_sect_one.cursor_column =
				2, 1, 1, 2, 1
			end

			if page == 4 then

				g_info_sect_one.cursor_row,
				g_info_sect_one.cursor_column =
				4, 3
			end
			if page == 5 or page == 6 then
				g_team_move_turn,
				g_info_last_move,
				g_info_sect_one.squares[4][3],
				g_info_sect_two.selected_row,
				g_info_sect_two.selected_column,
				g_info_sect_two.selected_value,
				g_info_sect_two.cursor_row,
				g_info_sect_two.cursor_column =
				2, m_move(1, {1,1}, {2, 1}, {4, 3}, {0, 0}, {0,0 }), 1, 2, 1, 1, 2, 1
			end

			if page == 6 then
				g_info_sect_two.cursor_row,
				g_info_sect_two.cursor_column =
				4, 3
			end

			if page > 6 and page < 9 then
				g_info_sect_one.squares[4][3],
				g_info_sect_two.squares[4][3],
				g_info_sect_two.squares[2][1] =
				1, 1, 0
			end

			if page == 7 then
				g_info_sect_two:shake(5,2)
				m_particle_square_explosion(92, 106)
			else
				table_clear(list_particles)
			end

			if page == 8 then
				g_team_active,
				g_team_move_turn,
				g_info_last_move,
				g_info_sect_two.squares[3][1],
				g_info_sect_two.squares[3][2],
				g_info_sect_one.selected_row,
				g_info_sect_one.selected_column,
				g_info_sect_one.selected_value,
				g_info_sect_one.cursor_row,
				g_info_sect_one.cursor_column =

				2, 2, m_move(2, {1, 2}, {3, 1}, {3, 2}, {0, 0}, {0, 0}), 0, 2, 3, 4, 2, 3, 4
			end
		end,

		page_adjust=function(self, adjust)
			self.page_cur += adjust
			if self.page_cur > self.page_max then
				sfx(8)
				self.page_cur = self.page_max
			elseif self.page_cur < 1 then
				sfx(8)
				self.page_cur = 1
			else
				sfx(7)
			end

			self:init(self.page_cur)
		end,

		handle_button=function(self, button)
			if not self.is_open then
				return
			end
			if button == 0 then
				self:page_adjust(-1)
			elseif button == 1 then
				self:page_adjust(1)
			elseif button == 4 then
				sfx(6)
				self:close()
			end
		end,

		open=function(self)
			sfx(5)
			menu_undo:close_cancel()
			menu_options:close()

			self.original_team = g_team_active
			self.original_turn_move = g_team_move_turn

			self.original_selstate = g_selstate
			set_selstate(c_selstate_menu_info)
			self.is_open = true
			self.page_cur = 1
			self:init(1)
		end,

		close=function(self)
			if not self.is_open then
				return
			end
			self.is_open = false
			g_team_active = self.original_team
			g_team_move_turn = self.original_turn_move

			set_selstate(self.original_selstate)
			return true
		end,

		draw=function(self)
			if not self.is_open then
				return
			end
			rectfill(0, 9, 127, 118, get_color(c_color_background))
			print(self.page_text, 4, 13, get_color(c_color_text_secondary))
			print(self.page_text_highlight, 4, 13, get_color(c_color_text))

			if self.page_cur > 1 and self.page_cur < 9 then
				g_info_sect_one:draw()
				g_info_sect_two:draw()
			end
		end,

		update=function(self)
			g_info_sect_one:update()
			g_info_sect_two:update()
		end,
	}
	m:init(1)
	return m
end

function m_menu_options()
	local m =
	{
		x=0,
		y=0,
		is_open=false,
		original_selstate=0,
		rows={},
		row_cur=1,
		sects={},
		settings_prev={},

		refresh=function(self)
			foreach(self.rows, function(row)
				row:refresh()
			end)
		end,

		init=function(self)
			add(self.sects, m_sect(self, {5,5}, 79, 16, false))
			add(self.sects, m_sect(self, {6,6}, 79, 66, true))
			self.sects[1].is_focused=false
			self.sects[1].is_highlighted=true


			add(self.rows, m_menu_options_row(self, 0, 16, "current theme", {}))
			add(self.rows[1].list_entries, m_menu_options_entry_theme(self.rows[1], "", 2, 10, g_theme, {}))

			local list_theme_names = {}
			for i=1, #g_list_themes do
				add(list_theme_names, g_list_themes[i][1])
			end
			self.rows[1].list_entries[1].list_choices = list_theme_names


			add(self.rows, m_menu_options_row(self, 0, 34, "color", {}, true))
			for column=1, 6 do
				self.rows[2].list_entries[column] = {}
				for row=1, 2 do
					local which_color = 1+6*(row-1)+column
					self.rows[2].list_entries[column][row] = m_menu_options_entry_color(self.rows[2], g_list_theme_entry_names[which_color], 2+(column-1)*12, 10+(row-1)*12, which_color)
				end
			end

			add(self.rows, m_menu_options_row(self, 0, 69, "team 1", {}))
			add(self.rows[3].list_entries, m_menu_options_entry_piece(self.rows[3], g_list_theme_entry_names[i_piece_teamone], 2, 10, i_piece_teamone, 1))
			add(self.rows[3].list_entries, m_menu_options_entry_color(self.rows[3], g_list_theme_entry_names[c_color_piece_teamone], 14, 10, c_color_piece_teamone))
			add(self.rows[3].list_entries, m_menu_options_entry_color(self.rows[3], g_list_theme_entry_names[c_color_piece_teamone_sec], 26, 10, c_color_piece_teamone_sec))


			add(self.rows, m_menu_options_row(self, 0, 92, "team 2", {}))
			add(self.rows[4].list_entries, m_menu_options_entry_piece(self.rows[4], g_list_theme_entry_names[i_piece_teamtwo], 2, 10, i_piece_teamtwo, 2))
			add(self.rows[4].list_entries, m_menu_options_entry_color(self.rows[4], g_list_theme_entry_names[c_color_piece_teamtwo], 14, 10, c_color_piece_teamtwo))
			add(self.rows[4].list_entries, m_menu_options_entry_color(self.rows[4], g_list_theme_entry_names[c_color_piece_teamtwo_sec], 26, 10, c_color_piece_teamtwo_sec))
		end,

		draw=function(self)
			if self.is_open == false then
				return
			end
			rectfill(0, 15, 127, 112, get_color(c_color_background))

			foreach(self.rows, function(row)
				row:draw()
			end)
			self.sects[1]:draw()
			self.sects[2]:draw()
		end,

		update=function(self)
			foreach(self.rows, function(row)
				row:update()
			end)
			self.sects[1]:update()
			self.sects[2]:update()
		end,

		open=function(self)
			sfx(5)
			menu_undo:close_cancel()
			menu_info:close()

			self.rows[self.row_cur]:highlight()
			self.original_selstate = g_selstate
			set_selstate(c_selstate_menu_options)
			self.is_open = true
		end,

		close=function(self)
			if not self.is_open then
				return false
			end
			self.rows[self.row_cur]:unhighlight()
			self.rows[self.row_cur]:get_cur_entry():cancel()
			self:row_set(1)
			self.is_open = false
			set_selstate(self.original_selstate)
			savedata_save()
			return true
		end,

		row_set=function(self, row_target)
			self.rows[self.row_cur]:unhighlight()
			self.rows[self.row_cur]:get_cur_entry():unhighlight()
			self.row_cur = row_target
			set_selstate(c_selstate_menu_options)
		end,

		row_adjust=function(self, adjust)
			sfx(7)
			local row_target = self.row_cur + adjust
			row_target = wrap(row_target, 2, #self.rows)

			self:row_set(row_target)

			local cur_row = self.rows[self.row_cur]
			cur_row:get_cur_entry():unhighlight()
			if adjust < 0 then
				cur_row.entry_row = #cur_row.list_entries[self.rows[self.row_cur].entry_column]
			else
				cur_row.entry_row = 1
			end

			self.rows[self.row_cur]:highlight()
		end,

		handle_button=function(self, button)
			if not self.is_open then
				return
			end

			if button == 0 then
				self.rows[self.row_cur]:handle_button(0)
			end
			if button == 1 then
				self.rows[self.row_cur]:handle_button(1)
			end
			if button == 2 then
				-- true means row has let us cycle to next row
				if not self.rows[self.row_cur]:handle_button(2) then
					-- only allow editing settings for Custom theme
					if self.row_cur ~= 1 then
						self:row_adjust(-1)
					else
						-- handle fallout from being unhighlighted by the row handler, thinking we'd take care of it
						self.rows[self.row_cur]:highlight()
						sfx(8)
					end
				end
			end
			if button == 3 then
				if not self.rows[self.row_cur]:handle_button(3) then
					-- only allow editing settings for Custom theme
					if self.row_cur ~= 1 then
						self:row_adjust(1)
					else
						-- handle fallout from being unhighlighted by the row handler, thinking we'd take care of it
						sfx(8)
						self.rows[self.row_cur]:highlight()
					end
				end
			end
			if button == 4 then
				if not self.rows[self.row_cur]:handle_button(4) then
					if self.row_cur == 1 then
						self:close()
					else
						self:row_set(1)
						self.rows[self.row_cur]:highlight()
						sfx(6)
					end
				end
			end
			if button == 5 then
				if not self.rows[self.row_cur]:handle_button(5) then
				end
			end
		end,
	}
	m:init()
	return m
end

function m_menu_undo()
	local m =
	{
		x=0,
		y=16,
		is_open=false,
		original_selstate=0,
		original_turn=0,

		open=function(self)
			sfx(5)
			menu_options:close()
			menu_info:close()
			self.original_turn = g_turn
			self.original_selstate = g_selstate
			set_selstate(c_selstate_menu_undo)
			self.is_open = true
		end,

		close=function(self)
			self.is_open = false
			set_selstate(self.original_selstate)
		end,

		close_confirm=function(self)
			if not self.is_open then
				return
			end
			self:close()
		end,

		close_cancel=function(self)
			if not self.is_open then
				return
			end
			-- if we have rolled back some turns, go back to the original turn we rewound from
			local turn_diff = self.original_turn - g_turn
			if turn_diff > 0 then
				for i=1, turn_diff do
					undo_forward()
				end
			end
			g_turn = self.original_turn
			self:close()
		end,

		handle_button=function(self, button)
			if button == 0 then
				undo_back()
			elseif button == 1 then
				undo_forward()
			elseif button == 4 then
				sfx(6)
				self:close_cancel()
			elseif button == 5 then
				sfx(5)
				self:close_confirm()
			end
		end,

		update=function(self)
			if self.is_open then
				local turn_type = "-p"
				if g_turn % 2 == 0 then
					turn_type = "-a"
				end
				header.text = "turn: "..ceil(g_turn/2)..""..turn_type
				local header_color = c_color_piece_teamone
				if g_team_active == 2 then
					header_color = c_color_piece_teamtwo
				end
				header.color = header_color
			end
		end,
	}
	return m
end

function menu_shared_open()
	if board:highlighted_sect():is_moving_piece() then
		board:highlighted_sect():select_cancel()
	end

	board:highlighted_sect():unfocus()
end

function menu_info_open()
	if menu_info.is_open then
		return
	end
	menu_shared_open()
	menu_info:open()
end

function menu_options_open()
	if menu_options.is_open then
		return
	end
	menu_shared_open()
	menu_options:open()
end

function menu_undo_open()
	if menu_undo.is_open then
		return
	end
	menu_shared_open()

	if g_flow_state == c_flow_state_game_end then
		menu_options:close()
		menu_info:close()
		undo_back()
	else
		menu_undo:open()
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000777700000000000070070000700700007777000077770000000000007007000000000000007000000000000000000000000000
00000000000770000070070007778770007007000770077000700700007777000070070007777770077007700077770000077000007777000770077007700770
00077000007777000077770007777870077777700777777000777700007777000077770000777700007777000077770000777700077787700077770007777770
00077000007777000077770007777770077777700077770000777700007777000077770007777770007777000077770007788770077778700077770000777700
00000000008888000088880007777770008888000088880000888800008888000088880000888800008888000088880007888870077777700088880000888800
00000000007777000077770000777700007777000077770000777700007777000077770000777700007777000077770000777700007777000077770000777700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000070000077770000777700007007000077770000000000007007000770077007788770077777700770000000000700000780000000000000777700
00777700007787000777777007877870007777000077770000000000007777000777777007788770077777700770777007707770000788000077000000777700
00788700077778700787787007777770008778000087780000777700008778000087780008888880077887700777777007700700000700000007007000877800
00788700077777700777777007877870007777000077770007778770007777000077770008888880077887700787787007777700000700000887777000077000
00777700077777700788887007788770007777000077770007777870007777000077770007788770077777700777777007878700000700000887777007077070
00000000007777000077770000777700007007000070070007777770077777000777770007788770077777700787787007777700000700000777777007700770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000707000000000000000000070000700007700000000000087777800000000000000000078707000000000000000000000000000000000000000000
00700700000707000077770000777700007007000007700000007000877777780008880007777770077770000000000000000000000000000000000000000000
00777700077878000778877000777700077777700007700000078000878778780787877087777778000777700077777000000000000000000000000000000000
00877800000777000787787007888870770770770777777000777700877887787777777787777778007777000077700000000000000000000000000000000000
00777700007777000777777007788770777777777777777707888870077777707777777707777770000777000777777000000000000000000000000000000000
07777700000777000707707000777700707007077777777707777770007887007777777700000000000777770787878000000000000000000000000000000000
00000000000000000000000000000000700770077777777700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77770000007777007777777777777700777700000077770077770000007777000007777777777700777777777700000000000000000000000000000000000000
77770000007777007777777777777700777700000077770077770000007777000077777777777700777777777777000000000000000000000000000000000000
77770000007777007777777777777700777770000077770077777000007777000777777777777700777777777777700000000000000000000000000000000000
77770000007777007777777777777700777777000077770077777700007777000777777777777700777777777777770000000000000000000000000000000000
77770000007777000000077770000000777777700077770077777770007777007777700000000000777700000777770000000000000000000000000000000000
77770000007777000000077770000000777777770077770077777777007777007777700000000000777700000777770000000000000000000000000000000000
77770000007777000000077770000000777777777077770077777777707777007777777770000000777777777777770000000000000000000000000000000000
77770777707777000000077770000000777777777777770077777777777777007777777770000000777777777777770000000000000000000000000000000000
77770777707777000000077770000000777707777777770077770777777777007777777770000000777777777777700000000000000000000000000000000000
77770777707777000000077770000000777700777777770077770077777777007777777770000000777777777777000000000000000000000000000000000000
77770777707777000000077770000000777700077777770077770007777777007777700000000000777700007777000000000000000000000000000000000000
77770777707777000000077770000000777700007777770077770000777777007777700000000000777700007777700000000000000000000000000000000000
77777777777777007777777777777700777700000777770077770000077777000777777777777700777700000777700000000000000000000000000000000000
07777777777770007777777777777700777700000077770077770000007777000777777777777700777700000777770000000000000000000000000000000000
00777777777700007777777777777700777700000077770077770000007777000077777777777700777700000077770000000000000000000000000000000000
00007777770000007777777777777700777700000077770077770000007777000007777777777700777700000077770000000000000000000000000000000000
77777777777777000007777777777700000777777770000000077777777000000000000000000000777777770000000077777777777700000000000000000000
77777777777777000077777777777700007777777777000000777777777700000000000000000000777777777000000077777777777770000000000000000000
77777777777777000777777777777700077777777777700007777777777770000000000000000000777777777000000077777777777770000000000000000000
77777777777777000777777777777700077777777777700007777777777770000000000000000000777777777000000077777777777777000000000000000000
00000777700000007777700000000000777770000777770077777777777777000000000000000000000007777000000000000000077777000000000000000000
00000777700000007777700000000000777770000777770077777777777777000000000000000000000007777000000000000000077777000000000000000000
00000777700000007777777770000000777777777777770077770777707777000000000000000000000007777000000007777777777777000000000000000000
00000777700000007777777770000000777777777777770077770777707777000000000000000000000007777000000077777777777770000000000000000000
00000777700000007777777770000000777777777777770077770777707777000000000000000000000007777000000077777777777770000000000000000000
00000777700000007777777770000000777777777777770077770777707777000000000000000000000007777000000077777777777700000000000000000000
00000777700000007777700000000000777700000077770077770777707777000000000000000000000007777000000077770000000000000000000000000000
00000777700000007777700000000000777700000077770077770777707777000000000000000000000007777000000077770000000000000000000000000000
00000777700000000777777777777700777700000077770077770000007777000000000000000000777777777777770077777777777777000000000000000000
00000777700000000777777777777700777700000077770077770000007777000000000000000000777777777777770077777777777777000000000000000000
00000777700000000077777777777700777700000077770077770000007777000000000000000000777777777777770077777777777777000000000000000000
00000777700000000007777777777700777700000077770077770000007777000000000000000000777777777777770077777777777777000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777700007777777777777700007777777777770000777777777700000000000000000000000000000000000000000000000000000000000000000000
77777777777770007777777777777700077777777777770007777777777770000000000000000000000000000000000000000000000000000000000000000000
77777777777777007777777777777700777777777777770077777777777777000000000000000000000000000000000000000000000000000000000000000000
77777777777777007777777777777700777777777777770077777777777777000000000000000000000000000000000000000000000000000000000000000000
77770000077777000000077770000000777770000000000077777777777777000000000000000000000000000000000000000000000000000000000000000000
77777777777777000000077770000000777700000000000077770000007777000000000000000000000000000000000000000000000000000000000000000000
77777777777777000000077770000000777700000000000077777777777777000000000000000000000000000000000000000000000000000000000000000000
77777777777770000000077770000000777770000000000077777777777777000000000000000000000000000000000000000000000000000000000000000000
77777777777700007777777777777700777777777777770077777777777777000000000000000000000000000000000000000000000000000000000000000000
77770000000000007777777777777700777777777777770077777777777777000000000000000000000000000000000000000000000000000000000000000000
77770000000000007777777777777700077777777777770007777777777770000000000000000000000000000000000000000000000000000000000000000000
77770000000000007777777777777700007777777777770000777777777700000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777777770007777700007777700007777777777000077777777777700007777700007777700000000000000000000000000000000000000000000000000
07777777777770007777700007777700077777777777700077777777777770007777700007777700000000000000000000000000000000000000000000000000
07777777777770007777700007777700777777777777770077777777777777007777700007777700000000000000000000000000000000000000000000000000
77777000000000007777700007777700777777777777770077777777777777007777700007777700000000000000000000000000000000000000000000000000
77777777777770007777777777777700777770000777770077770000077777007777700007777700000000000000000000000000000000000000000000000000
77777777777777007777777777777700777700000077770077777777777770007777700007777700000000000000000000000000000000000000000000000000
07777777777777007777777777777700777700000077770077777777777777007777700007777700000000000000000000000000000000000000000000000000
00777777777777007777777777777700777770000777770077777777777777007777700007777700000000000000000000000000000000000000000000000000
00000000077777007777700007777700777777777777770077770000077777007777777777777700000000000000000000000000000000000000000000000000
07777777777777007777700007777700777777777777770077777777777777007777777777777700000000000000000000000000000000000000000000000000
07777777777770007777700007777700077777777777700077777777777770000777777777777000000000000000000000000000000000000000000000000000
07777777777700007777700007777700007777777777000077777777777700000077777777770000000000000000000000000000000000000000000000000000
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
000100001113012130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f41000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c1300e130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002204023040250402704000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001204014040100401804027040290401d0400a040060400504004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000087500f750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000875004750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f41000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000024300d60002430084001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001413016130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001013012130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000941000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000014150021000a000131500a0000b0000d1500d1000f0000a15012000130000e15014000130000e1500f0000d000081500b0000b000081500e70009700131500c70014150191500a500121500f1000d150
0004000002150021000a000061500a0000b0000d1500d1000f0000a1501200013000061501400013000061500f0000d000081500b0000b000081500e70009700051500c70018700051500a500165000115000100
0004000014150021000a000131500a0000b0000d1500d1000f0000a15012000130000e15014000130000e1500f0000d000081500b0000b000081500e70009700131500c70014150191500a500121500f1000d150
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
