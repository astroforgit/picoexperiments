pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- escacs battle royale rogue
-- by ximo
oo = "Ž"


KING = 1 
QUEEN = 2 
ROOK = 3 
BISHOP = 4 
KNIGHT = 5 
PAWN = 6 

BLACK = 123
WHITE = 321

PIECES = {
 k = {KING, WHITE},
 K = {KING, BLACK},
 q = {QUEEN, WHITE},
 Q = {QUEEN, BLACK},
 r = {ROOK, WHITE},
 R = {ROOK, BLACK},
 b = {BISHOP, WHITE},
 B = {BISHOP, BLACK},
 n = {KNIGHT, WHITE},
 N = {KNIGHT, BLACK},
 p = {PAWN, WHITE},
 P = {PAWN, BLACK}
}

PIECES = {KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN}
SPRITES = {9, 11, 3, 5, 7, 1}
PLAYER_1 = {'k', 'q', 'r', 'b', 'n', 'p'}
PLAYER_2 = {'K', 'Q', 'R', 'B', 'N', 'P'}


function set_scene(s)
 current_scene = s

 if s.init != nil then
  _init = s.init
 else
  _init = function() end
 end

 if s.update != nil then
  _update = s.update
 else
  _update = function() end
 end

 if s.draw != nil then
  _draw = function()
   pal() 
   s.draw()
   pal() 
   --color(1)
   --print(s.name, 0, 0)
  end
 else
  _draw = function() end
 end

  _init()
end



function printc(msg, y)
 local len = #msg
 print(msg, 64 - 4 * (len/2), y)
end



VALID = 1
ATTACK = 2

function compute_movement(b, x, y)
 local res = create_empty_board()
 local piece = b[y][x][1]
 local player = b[y][x][2]

 if piece == KING then
  move_king(b, res, x, y, player)
 elseif piece == PAWN then
  move_pawn(b, res, x, y, player)
 elseif piece == KNIGHT then
  move_knight(b, res, x, y, player)
 elseif piece == BISHOP then
  move_bishop(b, res, x, y, player)
 elseif piece == ROOK then
  move_rook(b, res, x, y, player)
 elseif piece == QUEEN then
  move_queen(b, res, x, y, player)
 end

 return res
end

function compute_all_moves(b, p)
 local moves = {}
 for i = 1,8 do
  for j = 1,8 do
   local s = b[i][j]
   if s != nil and s[2] == p then
			 local m = compute_movement(b, j, i)
				for ii = 1,8 do
				 for jj = 1,8 do
					 if m[ii][jj] != nil then
						 add(moves, {i, j, ii, jj, m[ii][jj]})
						end
					end
			 end
   end
  end
 end
	return moves
end

function move_king(b, r, x, y, p)
 for d in all({{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}) do
  local nx = x + d[1]
  local ny = y + d[2]
  if valid_pos(nx, ny) then
   r[ny][nx] = mark(b, nx, ny, p)
  end
 end
end


function move_knight(b, r, x, y, p)
 for d in all({{1, -2}, {1, 2}, {-1, 2}, {-1, -2}, {2, 1}, {2, -1}, {-2, 1}, {-2, -1}}) do
  local nx = x + d[1]
  local ny = y + d[2]
  if valid_pos(nx, ny) then
   r[ny][nx] = mark(b, nx, ny, p)
  end
 end
end

function mark(b, x, y, p)
 local dst = b[y][x]
 if dst == nil then
  return VALID
 elseif dst[2] != p then
  return ATTACK
 end
 return nil
end

function move_pawn(b, r, x, y, p)
 ny = y - 1
 if p == WHITE then
  ny = y + 1
 end
 if not valid_pos(x, ny) then
  return
 end
	if mark(b, x-1, ny, p) == ATTACK then
	 r[ny][x - 1] = ATTACK
 end
 if mark(b, x+1, ny, p) == ATTACK then
	 r[ny][x + 1] = ATTACK
 end
	if mark(b, x, ny, p) == VALID then
  r[ny][x] = VALID 
	end
end

function move_bishop(b, r, x, y, p)
 move_line(b, r, x, y, 1, 1, p)
 move_line(b, r, x, y, -1, 1, p)
 move_line(b, r, x, y, 1, -1, p)
 move_line(b, r, x, y, -1, -1, p)
end

function move_rook(b, r, x, y, p)
 move_line(b, r, x, y, 1, 0, p)
 move_line(b, r, x, y, -1, 0, p)
 move_line(b, r, x, y, 0, 1, p)
 move_line(b, r, x, y, 0, -1, p)
end

function move_queen(b, r, x, y, p)
 move_bishop(b, r, x, y, p)
 move_rook(b, r, x, y, p)
end

function valid_pos(x, y)
 if x < 1 or x > 8 then
  return false
 elseif y < 1 or y > 8 then
  return false
 end
 return true
end

function move_line(b, r, x, y, dx, dy, p)
 for i = 1,8 do
  local nx = x + i * dx
  local ny = y + i * dy
  if not valid_pos(nx, ny) then
   break
  end
  local outcome = mark(b, nx, ny, p)
  r[ny][nx] = outcome
  if outcome != VALID  then
   break
  end
 end
end




VS_CPU = 1
VS_2P = 2

function title_init()
 sfx(0)
 step = 0
 msg = {'vs cpu', '2 players', 'settings', 'credits'}
	selected = 1 

end

function title_update()
 step += 1
 local prev = selected
	if step > 60 then
	 if btnp(2) then
		 selected -= 1
  elseif btnp(3) then
		 selected += 1
  end
		selected = 1 + (selected + #msg - 1) % #msg

		if btnp(4) then
   if selected == 1 then
			 mode = VS_CPU
				set_scene(scene_create_board)
				sfx(2)
    return
   elseif selected == 2 then
			 mode = VS_2P
				set_scene(scene_create_board)
				sfx(2)
				return
   elseif selected == 3 then
				sfx(2)
			 set_scene(scene_settings)
				return
   elseif selected == 4 then
				sfx(2)
			 set_scene(scene_credits)
				return
   end
		end
 end

	if step == 15 then
	 sfx(2)
	end
	if step == 30 then
  sfx(2) 
 end
	if step == 45 then
  sfx(2) 
 end

	if step == 60 then
  sfx(2) 
 end

	if prev != selected then
  if selected == 1 then
		 sfx(3)
  elseif selected == 2 then
		 sfx(4)
  elseif selected == 3 then
		 sfx(5)
		elseif selected == 4 then
		 sfx(6)
  end
	end
end

function title_draw()
 cls()
 rectfill(0, 0, 128, 128, 1) 
	sspr(0, 80, 80, 40, 20, 80)
	sspr(80, 40, 40, 80, 0, 40)

	sspr(48, 24, 40, 16, 10, 0, 40*3, 16*3)
	pal(5, 6)

	if step >= 15 then
	 sspr(48, 16, 76, 8, 2, 25)
	end
	if step >= 30 then
	 sspr(16, 24, 32, 8, 90, 25)
 end
	if step >= 45 then
	 sspr(16, 16, 32, 8, 40, 33)
 end

	if step >= 60 then
  pal()
		for i = 1,#msg do
   local curr = msg[i]
		 color(5)
			if selected == i then
			 curr = '> '..curr..' <'
				color(6)
   end
			print(curr, 45 + i*10, 45 + i * 8)
		end
	end

 color(2)
	print('version 2', 1, 122)
end


scene_title = {
 name = 'title',
	init = title_init,
	update = title_update,
	draw = title_draw
}


EMPTY_BOARD_STR = (
 'XXXXXXXXXX'..
 'X........X'..
 'X........X'..
 'X........X'..
 'X........X'..
 'X........X'..
 'X........X'..
 'X........X'..
 'X........X'..
 'XXXXXXXXXX')

function create_empty_board()
 local b = {}
 for i = 1,8 do
  b[i] = {}
  for j = 1,8 do
   b[i][j] = nil 
  end
 end
 return b
end

function board_to_string(b)
 local res = 'XXXXXXXXXX'
 for i = 1,8 do
  local r = 'X'
  for j = 1,8 do
   local p = b[i][j]
   if p == nil then
    r = r..'.'
   else
    r = PIECES[p]
   end
  end
  r = r..'X'
 end
 res = res..'XXXXXXXXXX'
 return res
end

function create_board_init()
 step = 0
 board = create_empty_board()

 if board_type == BOARD_COOL then
  -- player 2
  random_row(board[1], WHITE)
  random_row(board[2], WHITE)
  add_king(board[1], board[2], WHITE)

  -- player 1
  random_row(board[7], BLACK)
  random_row(board[8], BLACK)
  add_king(board[7], board[8], BLACK)
 elseif board_type == BOARD_BORING then
  board[1][1] = {ROOK, WHITE}
  board[1][2] = {KNIGHT, WHITE}
  board[1][3] = {BISHOP, WHITE}
  board[1][4] = {QUEEN, WHITE}
  board[1][5] = {KING, WHITE}
  board[1][6] = {BISHOP, WHITE}
  board[1][7] = {KNIGHT, WHITE}
  board[1][8] = {ROOK, WHITE}

  for i = 1,8 do
   board[2][i] = {PAWN, WHITE}
   board[7][i] = {PAWN, BLACK}
  end 

  board[8][1] = {ROOK, BLACK}
  board[8][2] = {KNIGHT, BLACK}
  board[8][3] = {BISHOP, BLACK}
  board[8][4] = {QUEEN, BLACK}
  board[8][5] = {KING, BLACK}
  board[8][6] = {BISHOP, BLACK}
  board[8][7] = {KNIGHT, BLACK}
  board[8][8] = {ROOK, BLACK}
 
 end

 stats = {}
 stats.turns = 0
 stats.attacks_ok = 0
 stats.attacks = 0
 stats.black_turns = 0
 next_player = WHITE
end

function random_row(r, p)
 for i = 1,8 do
  local x = PIECES[flr(2 + rnd(5))]
  r[i] = {x, p}
 end
end

function add_king(r1, r2, p)
 local pos = 1 + flr(rnd(8))
 if rnd(1) > 0.5 then
  r1[pos] = {KING, p}
 else
  r2[pos] = {KING, p}
 end
end

function create_board_update()
 step += 1
 if step <= 160 and (step % 10) == 0 then
  sfx(8)
 end
 if btnp(4) then
  set_scene(scene_select_player)
 end
end

function copy_board(b)
 local nb = {}
 for i = 1, 8 do
  nb[i] = {}
  for j = 1, 8 do
   nb[i][j] = b[i][j]
  end
 end
 return nb
end

function create_board_draw()
 cls()
 
 local tmp = copy_board(board)
 for i = 1, 8 do
  for j = 1, 8 do
    local wait = j
    if i == 2 or i == 7 then
     wait += 8
    end
    wait *= 10
    if wait > step then
     board[i][j] = nil
    end
  end
 end
 draw_board()
 board = tmp

 rectfill(16, 32, 128-17, 64, 13)
 color(4)
 printc('generating board', 33) 
 printc("press "..oo.." to continue", 58)


end

scene_create_board = {
 name = 'create_board',
 init = create_board_init,
 update = create_board_update,
 draw = create_board_draw
}

function other(b)
 if b == WHITE then
  return BLACK
 else
  return WHITE
 end
end

function select_player_init()
 first_blink = true
 stats.turns += 1
 prev_player = next_player

 if player_prob == 10 then
  next_player = other(prev_player)
 else

  if rnd(10) < player_prob then
   next_player = other(prev_player)
  else
   next_player = prev_player
  end
 end

 actual_selected = 1 
 if next_player == BLACK then
  actual_selected = 0
  stats.black_turns += 1
 end

 rem_change = 1
 wait_change = 1
 selected = 0 
 blink = false
 show = true

 if player_prob == 10 then
  blink = true 
 end
end

function select_player_update()
 if blink and first_blink then
  first_blink = false
  sfx(1)
 end

 local prev_selected = selected
 if blink and btnp(4) then
  selected = actual_selected
  if next_player == BLACK then
   set_scene(scene_move_player)
  else
   if mode == VS_CPU then
    set_scene(scene_move_ai)
   elseif mode == VS_2P then
    set_scene(scene_move_player)
   end
  end
 end
 
 rem_change -= 1
 if blink then
  if rem_change <= 0 then
   rem_change = 15
   show = not show
  end 
 elseif rem_change <= 0 then
  selected = 1 - selected 
  wait_change *= 1.5 
  rem_change = wait_change
  if wait_change > 20 then
   selected = actual_selected
   blink = true
   show = true 
  end
 end

 if selected != prev_selected then
  sfx(8)
 end
end

function select_player_draw()
 cls()
 draw_board()

 rectfill(16, 32, 128-17, 64, 13)

 color(4)
 --print('next turn: '..nxt, 18 , 32) 
 printc('next turn ', 33) 

 local prev_prob = 10 * (10 - player_prob)
 local next_prob = player_prob * 10

 local left = tostr(prev_prob)..'%'
 local right = tostr(next_prob)..'%'
 if prev_player == WHITE then
  local tmp = left
  left = right
  right = tmp 
 end
 local msg = left..'                '..right
 printc(msg, 46)

 local rowy = 40 
 set_black()
 spr(9, 32, rowy, 2, 2)

 set_white()
 spr(9, 128 - 48, rowy, 2, 2)

 local nxt = "green"
 if show then
  if selected == 1 then
   nxt = 'orange' 
   rect(128-48, rowy, 128-48+15, rowy+16, 9)
  else
   rect(32, rowy, 32 + 15, rowy+16, 9)
  end
 end
 if blink then
  color(4)
  printc("press "..oo.." to continue", 58)
  draw_stats()
 end
end

scene_select_player = {
 name = 'select_player',
 init = select_player_init,
 update = select_player_update,
 draw = select_player_draw
}



function find_first_piece(p)
 for i = 1,8 do
  for j = 1,8 do
   if board[i][j] != nil and board[i][j][2] == p then
    return j, i
   end
  end
 end
end

function move_player_init()
 cx, cy = find_first_piece(next_player)
 selected = false
 movement = nil
end

function move_player_update()
 local prev_selected = selected
 local prev_x = cx
 local prev_y = cy

 if btnp(0) then
  cx -= 1
 end
 if btnp(1) then
  cx += 1
 end
 if btnp(2) then
  cy -= 1
 end
 if btnp(3) then
  cy += 1
 end

 cx = 1 + (cx - 1 + 8) % 8
 cy = 1 + (cy - 1 + 8) % 8

 if btnp(4) then
  if not selected then 
   
   if board[cy][cx] != nil then
    if board[cy][cx][2] == next_player then
     selected = true
     selected_pos = {cx, cy}
     movement = compute_movement(board, cx, cy)
    end 
   end
  else
   if selected_pos[1] == cx and selected_pos[2] == cy then
    selected = false
    movement = nil
    selected_pos = nil
   elseif movement[cy][cx] != nil then
    move = {selected_pos[1], selected_pos[2], cx, cy}
    set_scene(scene_resolution)
    return
   elseif board[cy][cx] != nil and board[cy][cx][2] == next_player then
    selected_pos = {cx, cy}
    movement = compute_movement(board, cx, cy)
   end
  end
 end

 if selected != prev_selected then
  sfx(0)
 end
 if cx != prev_x or cy != prev_y then
  sfx(8)
 end
end

function move_player_draw()
 draw_board()
 local sx = 12 
 local sy = 12 
 local ox = (128 - 8*sx)/2
 local oy = 2 
 
 if movement != nil then
  for i = 1,8 do 
   for j = 1,8 do 
    local t = movement[i][j]

    if t == VALID then
     rect(ox+(j-1)*sx, oy+(i-1)*sy, ox+j*sx-1, oy+i*sy-1, 3)
     --rect(j*8-2, i*8-2, j*8+4, i*8+6, 11)
    elseif t == ATTACK then 
     rect(ox+(j-1)*sx-1, oy+(i-1)*sy-1, ox+j*sx, oy+i*sy, 8)
     --rect(j*8-2, i*8-2, j*8+4, i*8+6, 8)
    end
   end
  end
 end

 --rect(cx*8-2, cy*8-2, cx*8+4, cy*8+6, c)
 rect(ox+(cx-1)*sx-1, oy+(cy-1)*sy-1, ox+cx*sx, oy+cy*sy, 2)

 draw_stats()
end

scene_move_player = {
 name = 'move_player',
 init = move_player_init,
 update = move_player_update,
 draw = move_player_draw
}


SUCCEED = 1
FAILED = 2

WHITE_WINS = 1
BLACK_WINS = 2
CONTINUE = 3


function resolution_init()
 local dst = board[move[4]][move[3]]
 is_combat = dst != nil

 if is_combat then
  stats.attacks += 1
  local src = board[move[2]][move[1]]
  player_1 = src[1]
  player_2 = dst[1]
  if src[2] == WHITE then
   player_2 = src[1]
   player_1 = dst[1]
  end
  player_1 = SPRITES[player_1]
  player_2 = SPRITES[player_2]

  rem_change = 1
  wait_change = 1
  selected = 0 
  blink = false
  show = true
  first_blink = is_combat 
 end

 move_result = resolve_move(board, move[1], move[2], move[3], move[4])

 combat_won = false 
 if is_combat then
  if board[move[4]][move[3]][2] != dst[2] then
   combat_won = true
   stats.attacks_ok += 1
   actual_selected = 0
   if dst[2] == BLACK then
    actual_selected = 1
   end
  else
   actual_selected = 0
   if dst[2] == WHITE then
    actual_selected = 1
   end
  end
 end

 if attack_prob == 10 then
  blink = true
 end  	

 if not is_combat then
  first_blink = false
 end

end

function resolution_update()
 if blink and first_blink then
  first_blink = false
  sfx(1)
 end

 local prev_selected = selected

 if (blink and btnp(4)) or not is_combat then
  local result = check_endgame(board)
  if result == CONTINUE then
   set_scene(scene_select_player)
  else
   winner = next_player
   if is_combat then
    if not combat_won then
     winner = WHITE
     if next_player == WHITE then
      winner = BLACK
     end
    end
   end 	
   set_scene(scene_finish)
  end
 end

 rem_change -= 1
 if blink then
  if rem_change <= 0 then
   rem_change = 15
   show = not show
  end 
 elseif rem_change <= 0 then
  selected = 1 - selected 
  wait_change *= 1.5 
  rem_change = wait_change
  if wait_change > 20 then
   selected = actual_selected
   blink = true
   show = true 
  end
 end

 if selected != prev_selected then
  sfx(8)
 end

end

function resolve_move(b, ox, oy, dx, dy)
 result = SUCCEED 
 if board[dy][dx] != nil then
  local win = false
  if attack_prob == 10 then
   win = true
  else
   win = rnd(10) < attack_prob
  end

  if win then
   board[dy][dx] = board[oy][ox]
  else
   result = FAILED
  end 
 else
  board[dy][dx] = board[oy][ox]
 end
 board[oy][ox] = nil
 return result
end

function check_endgame(b)
 local found_white = false
 local found_black = false
 for i = 1,8 do
  for j = 1,8 do
   if board[i][j] != nil then
    if board[i][j][1] == KING then
     if board[i][j][2] == WHITE then
      found_white = true
     end
     if board[i][j][2] == BLACK then
      found_black = true
     end
    end
   end
  end
 end

 if not found_white then
  return BLACK_WINS
 end
 if not found_black then
  return WHITE_WINS
 end
 return CONTINUE
end

function resolution_draw()

 if is_combat then
  cls()
  local dst = board[move[4]][move[3]]
  local src = board[move[2]][move[1]]
  board[move[4]][move[3]] = nil
  board[move[2]][move[1]] = nil
  draw_board()
  board[move[4]][move[3]] = dst 
  board[move[2]][move[1]] = src 

  rectfill(16, 32, 128-17, 64, 13)

  color(4)
  --print('next turn: '..nxt, 18 , 32) 
  printc('combat winner ', 33) 

  local rowy = 40 
  set_black()
  spr(player_1, 32, rowy, 2, 2)

  set_white()
  spr(player_2, 128 - 48, rowy, 2, 2)

 local prev_prob = 10 * (10 - attack_prob)
 local next_prob = attack_prob * 10

 local left = tostr(prev_prob)..'%'
 local right = tostr(next_prob)..'%'
 if next_player == BLACK then
  local tmp = left
  left = right
  right = tmp 
 end
 local msg = left..'                '..right
 printc(msg, 46)

  local nxt = "green"
  if show then
   if selected == 1 then
    nxt = 'orange' 
    rect(128-48, rowy, 128-48+15, rowy+16, 9)
   else
    rect(32, rowy, 32 + 15, rowy+16, 9)
   end
  end
  if blink then
   color(4)
   printc("press "..oo.." to continue", 58)
   draw_stats()
  end
 end
end

scene_resolution = {
 name = 'resolution',
 init = resolution_init,
 update = resolution_update,
 draw = resolution_draw
}


function finish_init()
 pieces = {}
 for i = 1,8 do 
  for j = 1,8 do
   local b = board[i][j]
   if b != nil then
    if b[2] == winner then
	 add(pieces, b)
    else
	 board[i][j] = nil
    end
   end
  end
 end
 sfx(9)
end

function finish_update()
 if btnp(4) then
  set_scene(scene_title)
 end
end

function finish_draw()
 cls()
 draw_board()

 rectfill(16, 32, 128-17, 48, 13)

 color(4)
 local msg = "orange wins!"
 if winner == BLACK then
  msg = "green wins!"
 end
 printc(msg, 33) 
 printc('press '..oo..' to continue', 42)
 draw_stats()
end

scene_finish = {
 name = 'finish',
 init = finish_init,
 update = finish_update,
 draw = finish_draw
}


function move_ai_init()
 possible = compute_all_moves(board, next_player)
 if #possible == 0 then
  return nil
 end
 local which = 1 + flr(rnd(#possible))
 selected = possible[which]
end

function move_ai_update()
 if #possible == 0 then
  set_scene(scene_select_player)
  return nil
 end
 if btnp(4) then
  local s = selected
  move = {s[2], s[1], s[4], s[3]} 
  --resolve_move(board, s[2], s[1], s[4], s[3])
  --set_scene(scene_select_player)
  set_scene(scene_resolution)
 end
end

function move_ai_draw()
 cls()
 draw_board()
 color(4)
 print("thinking...", 0, 100)
 print("possible moves: "..tostr(#possible), 0, 108)
 if #possible == 0 then
  return nil
 end
 local piece2 = board[selected[1]][selected[2]]
 local piece = piece2[1]
 local piece_str = PLAYER_1[piece]
 if next_player == WHITE then
  piece_str = PLAYER_2[piece]
 end
 local msg = "moving with "
 if selected[5] == ATTACK then
  msg = "attacking with "
 end
 msg = msg..piece_str.. " from "..tostr(selected[1])..","..tostr(selected[2]).." to "..tostr(selected[3])..","..tostr(selected[4])
 print(msg, 0, 116)

 local sx = 12 
 local sy = 12 
 local ox = (128 - 8*sx)/2
 local oy = 2
 local srcy = (selected[1]-1)*sy + oy + sy/2
 local srcx = (selected[2]-1)*sx + ox + sx/2
 local dsty = (selected[3]-1)*sy + oy + sy/2
 local dstx = (selected[4]-1)*sx + ox + sx/2
 line(srcx, srcy, dstx, dsty, 10) 
end

scene_move_ai = {
 name = "move_ai",
 init = move_ai_init,
 update = move_ai_update,
 draw = move_ai_draw
}



BOARD_BORING = 'classic'
BOARD_COOL = 'random'

player_prob = 5 
attack_prob = 5 
board_type = BOARD_COOL

DESCR = {
 classic = 'the old boring classic chess',
	random = 'generate a random board'
}

function settings_init()
 selected = 1
 
end

function settings_update()
 local prev = selected
	local prev_player_prob = player_prob
	local prev_attack_prob = attack_prob
	local prev_board = board_type
 if btnp(4) then
  set_scene(scene_title)
		return
	end

 if btnp(2) then
	 selected -= 1
 end
	if btnp(3) then
	 selected += 1
 end

 if selected == 1 then
  if btnp(0) or btnp(1) then
		 if board_type == BOARD_COOL then
			 board_type = BOARD_BORING
   else
			 board_type = BOARD_COOL
   end
  end
 elseif selected == 2 then
	 if btnp(0) then
   player_prob = max(1, player_prob - 1) 
		elseif btnp(1) then
		 player_prob = min(player_prob + 1, 10)
  end
 elseif selected == 3 then
	 if btnp(0) then
   attack_prob = max(1, attack_prob - 1) 
		elseif btnp(1) then
		 attack_prob = min(attack_prob + 1, 10)
  end
 
	end

	selected = 1 + (selected - 1 + 3)%3

	if selected != prev then
	 sfx(7)
 end
	if prev_player_prob != player_prob or prev_board != board_type or prev_attack_prob != attack_prob then
  sfx(8)
	end
end

function settings_draw()
 cls()
	rectfill(0, 0, 128, 128, 1)
 color(6)

	printc("[settings]", 2)

 local board = 'board: '..board_type
	if selected == 1 then
	 color(9)
	 board = ' > '..board..' < '
 end
	printc(board, 10)
	color(6)
	if selected == 1 then
	 printc(DESCR[board_type], 18)
 end
	color(6)

 local who_moves = 'player alternation: '..(10*player_prob)..'%'
	if selected == 2 then
	 color(9)
	 who_moves = ' > '..who_moves..' < '
 end
	printc(who_moves, 30)
	color(6)
	if selected == 2 then
	 printc('probability of the other', 38)
	 printc('player moving next', 46)
	 printc('use 100% for classic chess', 38+16)
	end	
	color(6)

	local attack = 'attack success: '..(10*attack_prob)..'%'
	if selected == 3 then
	 color(9)
	 attack = ' > '..attack..' <'
 end
	printc(attack, 65)
	color(6)
	if selected == 3 then
	 printc('probability of an attack', 65+8)
	 printc('capturing the piece', 65+8+8)
	 printc('use 100% for classic chess', 65+8+16)
	end	 

	color(6)
	printc('press '..oo..' to return', 120)
end

scene_settings = {
 name = 'settings',
	init = settings_init,
	update = settings_update,
	draw = settings_draw
}


function credits_init()

end

function credits_update()
 if btnp(4) then
  set_scene(scene_title)
	end
end

function credits_draw()
 cls()
	rectfill(0, 0, 128, 128, 1)
	color(6)
 printc("escacs", 2)
	printc("rogue battle royale chess", 9)

	printc("[design and implementation]", 20)
	printc("ximo", 27)
	printc("https://ximo.itch.io/", 27+7)

	printc("[title font]", 45)
	printc("heartbit by void", 45+7)
	printc("https://arcade.itch.io/heartbit", 45+7+7)

	printc("[chess original idea]", 70)
	printc("apparently someone in india", 77)
	printc("a long time ago", 77+7)

	printc("thanks for playing!", 100)

	printc('press '..oo..' to return', 120)

	spr(80, 1, 102, 3, 3)
end

scene_credits = {
 name = 'credits',
	init = credits_init,
	update = credits_update,
	draw = credits_draw
}



function set_black()
 pal()
 pal(1, 11)
	pal(5, 3)
end

function set_white()
 pal()
	pal(1, 9)
	pal(5, 8)
end

function draw_board()
 rectfill(0, 0, 128, 128, 2)

	local sx = 12 
	local sy = 12 
 local ox = (128 - 8*sx)/2
	local oy = 2 
 for i = 1,8 do
	 for j = 1,8 do
		 local x = ox + (j-1)*sx
			local y = oy + (i-1)*sy
			local cl = 6
		 if (i+j)%2 == 0 then
			 cl = 5
   end
   rectfill(x, y, x+sx-1, y+sy-1, cl)
  end
 end

 for i = 1,8 do
	 for j = 1,8 do
		 local x = ox + (j-1)*sx
			local y = oy + (i-1)*sy
   if board[i][j] != nil then
			 local p = board[i][j]
				if p[2] == BLACK then
				 set_black()
    else
				 set_white()
				end
    spr(SPRITES[p[1]], x - 2, y - 3, 2, 2)
			end
  end
 end
	pal()
end

function draw_stats()
 color(4)
	local oy = 105
	local p = 'playing: '
	if next_player == WHITE then
  p = p..'orange'
 else
	 p = p..'green'
	end
	print(p, 1, oy)
	local t = 'turns: '..stats.turns
	if stats.turns > 0 then 
  local gt = flr(100 * stats.black_turns / stats.turns)
	 local ot = 100 - gt
	 t = t..' (green '..gt.."%/orange "..ot.."%)"
	end
 print(t, 1, oy + 8)
	local at = 'combats: '..stats.attacks
	if stats.attacks > 0 then
  local sat = flr(100 * stats.attacks_ok / stats.attacks)
		at = at..' ('..sat..'% successful)'
	end
	print(at, 1, oy + 16)
end


--set_scene(scene_create_board)
set_scene(scene_title)

--#include scene_load.lua
--#include scene_play.lua
--#include scene_next.lua

--set_scene(scene_load)
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000100000000000000000000000000000001000000000000100100100000000000000000000000000000
00077000000000011100000000000101010000000000001110000000000000100000000000000011100000000000011115000000000000000000000000000000
00700700000000111110000000000111110000000000011101000000000001111100000000000001000000000000011551000000000000000000000000000000
00000000000000111110000000000111110000000000011011000000000015111110000000001111111000000000111111100000000000000000000000000000
00000000000000111150000000000111150000000000011115000000000111151110000000000111110000000000011115000000000000000000000000000000
00000000000000015500000000000015500000000000001550000000000111501100000000000011150000000000001550000000000000000000000000000000
00000000000000011100000000000011100000000000001110000000000010011100000000000015500000000000001110000000000000000000000000000000
00000000000000011100000000000011100000000000001110000000000000111000000000000011100000000000001110000000000000000000000000000000
00000000000000111150000000000111150000000000011115000000000001111500000000000111150000000000011115000000000000000000000000000000
00000000000001115511000000001115511000000000111551100000000011155110000000001115511000000000111551100000000000000000000000000000
00000000000001111111000000001111111000000000111111100000000011111110000000001111111000000000111111100000000000000000000000000000
00000000000000111110000000000111110000000000011111000000000001111100000000000111110000000000011111000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11511111111111150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15111111111111110055500500050055550055500055500055550005550055555055555050000055550000000555500055500500050055500500000055550000
51111111111111110500050500050500000500050500050050005050005000500000500050000500000000000500050500050500050500050500000500000000
11111111111111150500000500050500000500000500000050005050005000500000500050000500000000000500050500050050500500050500000500000000
11111111111111110500000555550555500055500055500055550055555000500000500050000555500000000555500500050005000555550500000555500000
11111111111111110500000500050500000000050000050050005050005000500000500050000500000000000500050500050005000500050500000500000000
11111111111111110500050500050500000500050500050050005050005000500000500050000500000000000500050500050005000500050500000500000000
11111111111111110055500500050055550055500055500055550050005000500000500005550055550000000500050055500005000500050055550055550000
11111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111110555500055500055550500050055550005555005550005550005550005550005550000000000000000000000000000000000000000000000
11111111111111110500050500050500000500050500000050000050005050005050005050005050005000000000000000000000000000000000000000000000
11111111111111110500050500050500000500050500000050000050000050000050005050000050000000000000000000000000000000000000000000000000
11111111111111110555500500050505550500050555500055550005550050000055555050000005550000000000000000000000000000000000000000000000
11111111111111110500050500050500050500050500000050000000005050000050005050000000005000000000000000000000000000000000000000000000
11111111111111110500050500050500050500050500000050000050005050005050005050005050005000000000000000000000000000000000000000000000
11111111111111110500050055500055500055500055550005555005550005550050005005550005550000000000000000000000000000000000000000000000
dddddddd77777777ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd77777777ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd77777777ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd77777777ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd77777777ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd77777777ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd77777777ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd77777777ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbb0000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb30000000000000000000000
0000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbb330000000000000000000000
0000000000004440000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb333330000000000000000000000
0000000000044f44000000000000000000000000000000000000000000000000000000000000000000000000000000000000b333000000000000000000000000
000000000444fff4400000000000000000000000000000000000000000000000000000000000000000000000000000000000b333000000000000000000000000
00000004444ffff4400000000000000000000000000000000000000000000000000000000000000000000000000000000000b333000000000000000000000000
000000444ffffff4400000000000000000000000000000000000000000000000000000000000000000000000000000000000b333000000000000000000000000
0000044ffffff4444400000000000000000000000000000000000000000000000000000000000000000000000b33333333333333333333333300000000000000
000044fffffffffff44000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbb33333000000000000
000044ffffffffffff4400000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbb3333000000000000
00044fffff4ff4ffff44000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbb33330000000000000
000444ffff4ff4ffff44000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbb3333b0000000000000
0044ff444ffffff444f4400000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbb333300000000000000
0044ffffffffffffffff4400000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbb3333300000000000000
0044fffff444444fffff4400000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbb33333b00000000000000
0044ffffff4444ffffff4400000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbb333333000000000000000
00044ffffff44ffffff440000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbb3333333b000000000000000
00044fffffffffffff44000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb333333330000000000000000
00004444444444444440000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb33333333330000000000000000
00000444444444444400000000000000000000000000000000000000000000000000000000000000000000000000bbb333333333333333330000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbb3333333333333333000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbb333333000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbb3333333300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbb33333333330000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbb333333333330000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbb3333333333330000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbb3333333333333330000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333333333333000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb3333333333333000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb3333333000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbb333330000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb33330000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbb33330000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb3330000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb3330000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb3330000000000000000000
0000000000009990000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbb330000000000000000000
0000000000099999900000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbb330000000000000000000
0000000000999999909999900000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbb330000000000000000000
0000000000999999899999990000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb3333000000000000000000
0000000009999998999999999000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb3333000000000000000000
000000009999998999999999990000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbb3333000000000000000000
000000009999998999999999999000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbb3333000000000000000000
000000099999989999999999999900000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb33333000000000000000000
000000099999989999999999999990000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb33333000000000000000000
000000999999899999999999999989900000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb33333000000000000000000
000000999999899999999999999889990000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb33333300000000000000000
000000999998999999999999998899999900000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb33333300000000000000000
000009999998999999999999998899999999000000000000000000000000000000000000000000000000000000000bbbbbbbbbbb333333300000000000000000
000009999998999999999999988999999999990000000000000000000000000000000000000000000000000000000bbbbbbbbbbb333333300000000000000000
00000999999899999999999998899999999999990000000000000000000000000000000000000000000000000000bbbbbbbbbbbb333333300000000000000000
00009999998999999999999998899999999999999900000000000000000000000000000000000000000000000000bbbbbbbbbbbb333333300000000000000000
00009999998999999999999998999999999999999999000000000000000000000000000000000000000000000000bbbbbbbbbbb3333333300000000000000000
00009999998999999999999988999999999999999999990000000000000000009999999000000000000000000000bbbbbbbbbbb3333333330000000000000000
00009999998999999999999988999999999999999999999990000000000000999999999990000000000000000000bbbbbbbbbb33333333330000000000000000
0000999998899999999999988999999999999999999999988990000000000999999999999900000000000000000bb33bbbbbb333333333330000000000000000
000099999888999999999998899999999999999999999988999999900009999999999999999900000000000000bbbb3333333333333333330000000000000000
00009999888899999999998889999999999999999999998899999999900999999999999999990000000000000bbbbbb333333333333333333000000000000000
0009999888889999999998888999999999999999999998899999999988999999999999999999900000000000bbbbbbb33b333333333333333300000000000000
000999988888999999999888899999999999999999999889999999998899999999999999999999000000000bbbbbbbbbbbbbbbbb333333333330000000000000
00099998888889999999888888999999999999999999989999999998899999999999999999999900000000bbbbbbbbbbbbbbbbbbbbbbb3333333000000000000
0009998888888999999888888889999999999999999998899999999889999999999999999999988000000bbbbbbbbbbbbbbbbbbbbbbbbbb33333300000000000
000998888888889999888888888888888888888899999889999999889999999999999999999998800000bbbbbbbbbbbbbbbbbbbbbbbbbbbb3333330000000000
00098888888888888888888888888888888888888888888888888888899999999999999999999880000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333300000000
00098888888888888888888888888888888888888888888888888888899999999999999999998880000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333300000000
00088888888888888888888888888888888888888888888888888888899999999999999999998880000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333300000000
00088888888888888888888888888888888888888888888888888888899899999999999999988880000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333300000000
00088888888888888888888888888888000000000000000000000888889888999999999999888880000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333300000000
000888888888888888888888880000000000000000000000000000000888889999999999988888000000bbbbbbbbbbbbbbbbbbbbbbbbbbb33333333000000000
000088888888888888880000000000000000000000000000000000000888888899999999888888000000bbbbbbbbbbbbbbbbbbbbbbbbbb333333333000000000
000088888888888888000000000000000000000000000000000000000088888888999988888880000000bbbbbbbbbbbbbbbbbbbbbbbb33333333333000000000
000000000008888800000000000000000000000000000000000000000008888888888888888800000000bbbbbbbbbbbbbbbbbbbbbb3333333333333000000000
000000000000000000000000000000000000000000000000000000000008888888888888888800000000bbbbbbbbbbbbbbb33333333333333333333000000000
000000000000000000000000000000000000000000000000000000000000088888888888880000000000bbbbbbbbb33333333333333333333333300000000000
00000000000000000000000000000000000000000000000000000000000000888888888880000000000000000333333333333333333333333000000000000000
00000000000000000000000000000000000000000000000000000000000000008888888000000000000000000000000003333333333333000000000000000000
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
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424250510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424260616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424270717200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000a00001f55318553005030650302503015030b50300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300500
01100000215201f5201d5201f52000000215201f52000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002261500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500000
001000002a51000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001000002351000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001000001b51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000851000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000070705757007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707
011000000453503505015050150503505035050350506505065050650506505065050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
01100000185551a555175551e555255551f5551a50528555235552655500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
