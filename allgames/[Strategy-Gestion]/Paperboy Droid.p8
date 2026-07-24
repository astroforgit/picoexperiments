pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- paperboy droid
-- by not even games
-- translation by ~firefly~
-- complete translation by dw817

prog_x = 52
prog_y = 1
ident_width = 4
ident_col = 12
act_col = 10
cond_col = 13
max_instr = 16
ticks = 15
tu_speed = 1

levels = {
 -- level 1
 {
  {1, 0, 0, 0},
  {1, 0, 0, 0}
 },
 -- level 2
 {
  {1, 0, 0, 0},
  {1, 0, 0, 0}
 },
 -- level 3
 {
  {0, 0, 0, 0},
  {0, 0, 0, 0},
  {1, 0, 0, 0},
  {0, 0, 0, 0},
  {1, 0, 0, 0}
 },
 -- level 4
 {
  {1, 1, 1, 0},
  {0, 0, 1, 0},
  {1, 0, 0, 0},
  {0, 1, 1, 0},
  {1, 0, 0, 0}
 },
 -- level 5
 {
  {1, 1, 1, 0},
  {0, 0, 1, 0},
  {1, 0, 0, 1},
  {0, 1, 1, 0},
  {1, 0, 0, 1}
 }
}

tutos = {
 -- level 1
 {
  {"welcome to paperboy droid!", 1, 24},
  {"start by writing a", 1, 31},
  {"program to distribute", 1, 38},
  {"the newspapers in the", 1, 45},
  {"mailboxes.", 1, 52},
  {"< click commands", 38, 8},
  {"to add them", 46, 15},
  {"drag&drop commands", 51, 60},
  {"to move them", 51, 67},
  {"< click the cross", 46, 75},
  {"to delete", 54, 82},
  {"a command and", 54, 89},
  {"the play button", 54, 96},
  {"to execute the", 54, 103},
  {"program when ready", 54, 110},
  {"the droid", 1, 103},
  {"moves here", 1, 110},
  {"level 1: deliver 2 newspapers", 8, 120}
 },
 -- level 2
 {
  {"yeah! you have finished level 1!", 1, 60},
  {"don't get too excited", 1, 67},
  {"it was a tutorial...", 1, 74},
  {"for level 2 you have to", 1, 81},
  {"deliver 5 newspapers", 1, 88},
  {"< to assist you, the", 38, 8},
  {"command repeat", 46, 15},
  {"repeats commands", 46, 22},
  {"that you slide", 46, 29},
  {"inside", 46, 36}
 },
 -- level 3
 {
  {"look who's making progress!", 1, 60},
  {"watch out, in level 3", 1, 67},
  {"there are houses without", 1, 74},
  {"mailboxes. save your", 1, 81},
  {"newspapers!", 1, 88},
  {"< the command 'if'", 38, 8},
  {"allows to test", 46, 15},
  {"if the droid is in front", 46, 22},
  {"of a mailbox.", 46, 29},
  {"nifty, right ?", 46, 36}
 },
 -- level 4
 {
  {"good good but... let's get serious!", 1, 60},
  {"now you'll have to pick up", 1, 67},
  {"piles of newspapers", 1, 74},
  {"to increase your stock,", 1, 81},
  {"but also avoid the", 1, 88},
  {"barriers to avoid ending up", 1, 95},
  {"as a heap of rubbish!!!", 1, 102},
  {"< plenty of new", 38, 8},
  {"commands :)", 46, 15},
  {"the command `if' can", 46, 22},
  {"detect piles of", 46, 29},
  {"newspapers!", 46, 36}
 },
 -- level 5
 {
  {"well... you have come a long", 1, 60},
  {"way. for the last level,", 1, 67},
  {"i'll leave you on your own.", 1, 74},
  {"best of luck!", 1, 81}
 },
 -- fin (6)
 {
  {"many thanks to you !!!", 1, 60},
  {"it's sad but it's over,", 1, 67},
  {"at least for now...", 1, 74},
  {"to follow what i do:", 1, 81},
  {"twitter: @notevengamesfr", 1, 88},
  {"site: https://notevengames.com", 1, 95},
  {"don't hesitate to leave a", 1, 102},
  {"comment, it would make me", 1, 109},
  {"super mega happy!", 1, 116},
  {"hope you enjoyed it, cya....", 1, 1}
 },
 -- echec - journaux (7)
 {
  {"you haven't delivered enough", 1, 60},
  {"newspapers, try again...", 1, 67},
 },
 -- echec - crash (8)
 {
  {"you have destroyed the droid :(", 1, 60},
  {"try again...", 1, 67}
 }
}

english_commands = {}
english_commands["if"] = "if"
english_commands["fin"] = "end"
english_commands["pick up"] = "pick up"
english_commands["throw"] = "throw"
english_commands["repeat"] = "repeat"
english_commands["forward"] = "forward"
english_commands["left"] = "left"
english_commands["right"] = "right"
english_commands["box"] = "mailbox"
english_commands["journal"] = "newspaper"
english_commands["barrier"] = "barrier"
english_commands["car"] = "car"

goals = {2, 5, 5, 10, 10}

function in_box(x1, y1, x2, y2)
 return mouse_x >= x1 and mouse_x < x2 and mouse_y >= y1 and mouse_y < y2
end

function init_level()
 init_play()
 help_data = tutos[lvl]
 mode = "help"
 sfx(5,1)
 help_lock = true
 tutime = 0
 _update() -- update once before draw
 _draw() -- to fill the coord tables
end

function init_play()
 lvl_cur = 1
 next_cur = 1
 d_lane = 0
 d_state = 0
 tick = 0
 play_l = 1
 score = 0
 goal = goals[lvl]
 papers = 5
 lvl_data = {}
 for i=1,#levels[lvl] do
  local data = {levels[lvl][i][1], levels[lvl][i][2], levels[lvl][i][3], levels[lvl][i][4]}
  add(lvl_data, data)
 end
end

function nxt_lvl()
 if lvl < #levels then
  lvl += 1
  init_level()
 else
  the_end = true
  help_data = tutos[6]
  sfx(5,1)
  mode = "help"
  help_lock = true
  tutime = 0
 end
end

function _init()
 poke(0x5f2d, 1)
 palt(0, false)
 palt(15, true)
 the_end = false
 lvl = 1
 wait_unclick = false
 l_coords = {}
 c_coords = {}
 a_coords = {}
 prog = {
 }
 init_level()
end

-->8
function rm_instr(l)
 for i=l,#prog-1 do
  prog[i] = prog[i+1]
 end
 prog[#prog] = nil
end

function remove_instr(l)
 local ident = 0
 local i = l
 if ident_instr(prog[l]) == 1 then
  -- boucle
  while ident >= 0 do
   i += 1
   ident += ident_instr(prog[i])
  end
  rm_instr(i)
  rm_instr(l)
 elseif ident_instr(prog[l]) == -1 then
  -- fin
  while ident <= 0 do
   i -= 1
   ident += ident_instr(prog[i])
  end
  rm_instr(l)
  rm_instr(i)
 else
  rm_instr(l)
 end
 _draw() -- to update coords
end

function find_l()
 for i=1,#l_coords do
  if in_box(l_coords[i][1], l_coords[i][2], l_coords[i][3], l_coords[i][4]) then
   return i
  end
 end
 return nil
end

function find_c()
 for i=1,#c_coords do
  if in_box(c_coords[i][1], c_coords[i][2], c_coords[i][3], c_coords[i][4]) then
   return c_coords[i][5]
  end
 end
 return nil
end

function move_prog_l(old, new)
 if old == new then return end
 local step = 1
 local instr = prog[old]
 if old > new then step = -1 end
 while old != new do
  prog[old] = prog[old+step]
  old += step
 end
 prog[new] = instr
end

function ident_instr(instr)
 if instr[1] == "if" or instr[1] == "repeat" then
  return 1
 elseif instr[1] == "fin" then
  return -1
 else return 0 end
end

function sum_ident(a, b)
 local s = 0
 for i=a,b do
  s += ident_instr(prog[i])
 end
 return s
end

function find_min_l(l)
 local ident = sum_ident(1, l-1)
 while ident > 0 do
  l -= 1
  ident -= ident_instr(prog[l])
 end
 return l+1
end

function find_max_l(l)
 local ident = sum_ident(l+1, #prog)
 while ident < 0 do
  l += 1
  ident -= ident_instr(prog[l])
 end
 return l-1
end

function add_instr(instr)
 if instr == "if" then
  add(prog, {instr, "box"})
  add(prog, {"fin"})
 elseif instr == "repeat" then
  add(prog, {instr})
  add(prog, {"fin"})
 else
  add(prog, {instr})
 end
end

function play_step()
 if play_l > #prog then
  help_data = tutos[7]
  help_lock = true
  tutime = 0
  sfx(5,1)
  mode = "help"
  return
 end
 local front = lvl_data[lvl_cur%#lvl_data+1]
 if prog[play_l][1] == "fin" then
  local ident = 0
  local i = play_l
  while ident <= 0 do
   i -= 1
   ident += ident_instr(prog[i])
  end
  if prog[i][1] == "if" then
   play_l += 1
  else
   play_l = i
  end
 elseif prog[play_l][1] == "if" then
  if (prog[play_l][2] == "box" and front[1] >= 1) or (prog[play_l][2] == "journal" and front[2] == 1) or (prog[play_l][2] == "car" and front[4] == 1) or (prog[play_l][2] == "fence" and front[3] == 1) then
   -- true
   play_l += 1
  else -- false
   local ident = 0
   local i = play_l
   while ident >= 0 do
    i += 1
    ident += ident_instr(prog[i])
   end
   play_l = i+1
  end
 elseif prog[play_l][1] == "repeat" then
  play_l += 1
 elseif prog[play_l][1] == "left" then
  d_lane = 0
  play_l += 1
 elseif prog[play_l][1] == "right" then
  d_lane = 1
  play_l += 1
 elseif prog[play_l][1] == "pick up" then
  if d_lane == 0 and front[2] == 1 then
   papers += 5
   front[2] = 0
  end
  play_l += 1
 elseif prog[play_l][1] == "throw" then
  if papers > 0 then
   papers -= 1
   if front[1] == 1 then
    sfx(3)
    front[1] = 2
    score += 1
    if score == goal then
     nxt_lvl()
    end
   else
    sfx(4)
   end
  end
  play_l += 1
 elseif prog[play_l][1] == "forward" then
  if (d_lane == 0 and front[3] == 1) or (d_lane == 1 and front[4] == 1) then
   -- crash
   sfx(1)
   d_state = 2
   help_data = tutos[8]
   help_lock = true
   tutime = 0
   sfx(5,1)
   mode = "help"
  else
   sfx(0)
   if front[1] == 2 then
    -- init mailbox for next time
    front[1] = 1
   end
   lvl_cur += 1
   play_l += 1
  end
 end
 if prog[play_l] and prog[play_l][1] == "throw" and papers > 0 then
  sfx(2)
 end
end

function _update()
 mouse_x = stat(32)
 mouse_y = stat(33)
 clicked = stat(34) % 2

 if wait_unclick then
  if clicked == 0 then
   wait_unclick = false
  end
  return
 end

 if mode == "help" then
  if clicked == 1 and not help_lock and not the_end then
   mode = "code"
   wait_unclick = true
  end
 elseif mode == "play" then
  if clicked == 1 and in_box(22, 81, 30, 89) then
   mode = "code"
   wait_unclick = true
  else
   tick += 1
   if tick == ticks then
    play_step()
    tick = 0
   end
  end
 elseif mode == "code" then
  if clicked == 1 then
   local l = find_l(mouse_x, mouse_y)
   local c = find_c(mouse_x, mouse_y)
   if in_box(22, 81, 30, 89) then
    mode = "play"
    init_play()
    wait_unclick = true
   elseif in_box(41, 73, 49, 81) then
    mode = "remove"
    wait_unclick = true
   elseif c != nil then
    if prog[c][2] == "box" then prog[c][2] = "journal"
    elseif prog[c][2] == "journal" then prog[c][2] = "fence"
    elseif prog[c][2] == "fence" then prog[c][2] = "car"
    elseif prog[c][2] == "car" then prog[c][2] = "box" end
    wait_unclick = true
   elseif l != nil then
    mode = "move"
    move_l = l
    move_min = 1
    move_max = #prog
    if prog[l][1] == "fin" then
     move_min = find_min_l(l)
    elseif ident_instr(prog[l]) == 1 then
     move_max = find_max_l(l)
    end
   else
    for i=1,#a_coords do
     if in_box(a_coords[i][1], a_coords[i][2], a_coords[i][3], a_coords[i][4]) then
      add_instr(a_coords[i][5])
      wait_unclick = true
     end
    end 
   end
  end
 elseif mode == "move" then
  if clicked == 0 then
   mode = "code"
  else
   local l = flr((mouse_y - prog_y) / 8) + 1
   if l < move_min then l = move_min
   elseif l > move_max then l = move_max end
   move_prog_l(move_l, l)
   move_l = l
  end
 elseif mode == "remove" then
  if clicked == 1 then
   local l = find_l(mouse_x, mouse_y)
   if l != nil then
    remove_instr(l)
   end
   mode = "code"
   wait_unclick = true
  end
 end
end

-->8
function draw_ident(l, ident)
 for i = 1,ident do
  local x = prog_x+(i-1)*ident_width
  local y = prog_y+(l-1)*8-1
  rectfill(x, y, x+ident_width-2, y+9, ident_col)
 end
end

function r_rect(x, y, w, h, col, a, b, c, d)
 -- a b
 -- c d -> 0 = round, 1 = sharp
 rectfill(x+1, y, x+w-2, y+h-1, col)
 line(x, y+1-a, x, y+h-2+c, col)
 line(x+w-1, y+1-b, x+w-1, y+h-2+d, col)
end

function draw_instr(l, ident, instr)
 local txt, col, nident
 local a, b, c, d = 0, 0, 0, 0
 local cond = nil
 nident = ident
 if ident_instr(instr) == 1 then
  if instr[1] == "if" then
   txt = "if "..english_command[instr[2]]
   cond = instr[2]
  else
   txt = english_command[instr[1]]
  end
  col = ident_col
  nident += 1
  c = 1
 elseif instr[1] == "fin" then
  txt = "end"
  col = ident_col
  a = 1
 else
  txt = english_command[instr[1]]
  col = act_col
 end
 local box_x = prog_x+ident*ident_width
 local box_y = prog_y+(l-1)*8
 local box_w = #txt*4+4
 r_rect(box_x, box_y, box_w, 7, col, a, b, c, d)
 nl_coords[l] = {box_x, box_y, box_x+box_w, box_y+7}
 if instr[1] == "fin" then
  line(box_x, box_y-1, box_x+ident_width-2, box_y-1, ident_col)
 end
 if cond != nil then
  local cond_w = #cond*4-1
  local cond_x = box_x+box_w-cond_w-3
  r_rect(cond_x, box_y, cond_w, 7, cond_col, 1, 1, 1, 1)
  add(nc_coords, {cond_x, box_y, cond_x+cond_w, box_y+7, l})
 end
 print(txt, box_x+2, box_y+1, 0)
 return nident
end

function sprs(c, r, w, h, x, y)
 for i=0,w-1 do
  for j=0,h-1 do
   spr((r+j)*16+c+i, x+i*8, y+j*8)
  end
 end
end

function draw_bg()
 sprs(0, 12, 6, 4, 1, 95)
end

function draw_ft()
 local front = lvl_data[lvl_cur%#lvl_data+1]
 local back = lvl_data[(lvl_cur+1)%#lvl_data+1]
 if back[1] == 1 then spr(9, 19, 99) end
 if front[1] == 1 then spr(8, 0, 113) end
 if front[1] == 2 then spr(20, 0, 113) end
 if back[2] == 1 then spr(18, 30, 101) end
 if front[2] == 1 then spr(19, 20, 116) end
 if back[3] == 1 then spr(4, 29, 96) end
 if front[3] == 1 then sprs(5, 0, 3, 1, 10, 109) end
 if back[4] == 1 then spr(3, 40, 98) end
 if front[4] == 1 then spr(2, 35, 110) end

 if mode == "play" and prog[play_l] and prog[play_l][1] == "throw" and papers > 0 then
  d_state = 1
  if d_lane == 0 then
   spr(13, 8, 113)
  else
   spr(13, 17, 114)
  end
 end
 if d_lane == 0 and d_state == 0 then spr(10, 16, 117)
 elseif d_lane == 0 and d_state == 1 then spr(11, 16, 117)
 elseif d_lane == 0 and d_state == 2 then spr(12, 21, 112)
 elseif d_lane == 1 and d_state == 0 then spr(10, 32, 117)
 elseif d_lane == 1 and d_state == 1 then spr(11, 32, 117)
 elseif d_lane == 1 and d_state == 2 then spr(12, 34, 113) end
 if d_state == 1 then d_state = 0 end
end

function draw_instr_btn(instr, x, y)
 local col
 if instr == "if" or instr == "repeat" then
  col = ident_col
 else
  col = act_col
 end
 local box_w = #instr*4+4
 r_rect(x, y, box_w, 7, col, 0, 0, 0, 0)
 add(na_coords, {x, y, x+box_w, y+7, instr})
 print(english_commands[instr], x+2, y+1, 0)
end

function _draw()
 cls()
 hand = false

 print("program", 91, 2, 7)

 if mode == "code" or mode == "help" then
  if #prog < max_instr then
   print("add:", 2, 2, 7)
   na_coords = {}
   draw_instr_btn("throw", 2, 8)
   draw_instr_btn("forward", 2, 8*2)
   if lvl >= 2 then
    draw_instr_btn("repeat", 2, 8*3)
   end
   if lvl >= 3 then
    draw_instr_btn("if", 2, 8*4)
   end
   if lvl >= 4 then
    draw_instr_btn("left", 2, 8*5)
    draw_instr_btn("right", 2, 8*6)
    draw_instr_btn("pick up", 2, 8*7)
   end
   a_coords = na_coords
  else
   print("reached max", 2, 2, 7)
   print("program", 2, 10, 7)
   print("size", 2, 18, 7)
  end

  print("delete:", 2, 2+8+8*8, 7)
  print("play:", 2, 2+8+8*8+8, 7)
 end

 if mode == "remove" then
  print("choose what", 2, 10, 7)
  print("to remove", 2, 18, 7)
  print("from your", 2, 26, 7)
  print("program", 2, 34, 7)
 end

 if mode == "play" then
  rectfill(prog_x, prog_y+(play_l-1)*8-1, 128, prog_y+(play_l-1)*8+7, 8)
 end

 rect(prog_x-1, prog_y-1, 127, 127, 7)
 rect(0, 94, 49, 127, 10)

 nl_coords = {}
 nc_coords = {}
 ident = 0
 for l=1,#prog do
  local instr = prog[l]
  if instr[1] == "fin" then ident -= 1 end
  draw_ident(l, ident)
  ident = draw_instr(l, ident, instr)
 end
 l_coords = nl_coords
 c_coords = nc_coords

 draw_bg()
 draw_ft()

 if mode == "code" or mode == "help" then
  spr(14, 22, 81)
  spr(29, 41, 73)
 elseif mode == "play" then
  spr(15, 22, 81) 
 end

 if in_box(22, 81, 30, 89) and (mode == "code" or mode == "play") then
  hand = true
 elseif mode == "code" and in_box(41, 73, 49, 81) then
  hand = true
 elseif mode == "code" or mode == "remove" then
  for i=1,#l_coords do
   if in_box(l_coords[i][1], l_coords[i][2], l_coords[i][3], l_coords[i][4]) then
    hand = true
   end
  end
 end
 if mode == "code" then
  for i=1,#a_coords do
   if in_box(a_coords[i][1], a_coords[i][2], a_coords[i][3], a_coords[i][4]) then
    hand = true
   end
  end 
 end

 if mode == "play" then
  print("score: "..score.."/"..goal, 2, 50, 7)
  local col = 7
  if papers == 0 then
   col = 8
  end
  print("stock: "..papers, 2, 60, col)
 end

 if hand then
  spr(17, mouse_x-1, mouse_y)
 else
  spr(1, mouse_x-1, mouse_y)
 end

 if mode == "help" then
  tutime += 1
  local nc = flr(tutime/tu_speed)
  for i=1,#help_data do
   local txt = help_data[i][1]
   if #txt > nc then
    txt = sub(txt, 1, nc)
   end
   rectfill(help_data[i][2], help_data[i][3], help_data[i][2]+#txt*4, help_data[i][3]+6, 2)
   print(txt, help_data[i][2]+1, help_data[i][3]+1, 7)
   nc -= #txt
   if nc <= 0 then break end
  end
  if nc > 0 then
   sfx(-1,1)
   help_lock = false
  end
 end
end
-->8
function rm_instr(l)
 for i=l,#prog-1 do
  prog[i] = prog[i+1]
 end
 prog[#prog] = nil
end

function remove_instr(l)
 local ident = 0
 local i = l
 if ident_instr(prog[l]) == 1 then
  -- boucle
  while ident >= 0 do
   i += 1
   ident += ident_instr(prog[i])
  end
  rm_instr(i)
  rm_instr(l)
 elseif ident_instr(prog[l]) == -1 then
  -- fin
  while ident <= 0 do
   i -= 1
   ident += ident_instr(prog[i])
  end
  rm_instr(l)
  rm_instr(i)
 else
  rm_instr(l)
 end
 _draw() -- to update coords
end

function find_l()
 for i=1,#l_coords do
  if in_box(l_coords[i][1], l_coords[i][2], l_coords[i][3], l_coords[i][4]) then
   return i
  end
 end
 return nil
end

function find_c()
 for i=1,#c_coords do
  if in_box(c_coords[i][1], c_coords[i][2], c_coords[i][3], c_coords[i][4]) then
   return c_coords[i][5]
  end
 end
 return nil
end

function move_prog_l(old, new)
 if old == new then return end
 local step = 1
 local instr = prog[old]
 if old > new then step = -1 end
 while old != new do
  prog[old] = prog[old+step]
  old += step
 end
 prog[new] = instr
end

function ident_instr(instr)
 if instr[1] == "if" or instr[1] == "repeat" then
  return 1
 elseif instr[1] == "fin" then
  return -1
 else return 0 end
end

function sum_ident(a, b)
 local s = 0
 for i=a,b do
  s += ident_instr(prog[i])
 end
 return s
end

function find_min_l(l)
 local ident = sum_ident(1, l-1)
 while ident > 0 do
  l -= 1
  ident -= ident_instr(prog[l])
 end
 return l+1
end

function find_max_l(l)
 local ident = sum_ident(l+1, #prog)
 while ident < 0 do
  l += 1
  ident -= ident_instr(prog[l])
 end
 return l-1
end

function add_instr(instr)
 if instr == "if" then
  add(prog, {instr, "box"})
  add(prog, {"fin"})
 elseif instr == "repeat" then
  add(prog, {instr})
  add(prog, {"fin"})
 else
  add(prog, {instr})
 end
end

function play_step()
 if play_l > #prog then
  help_data = tutos[7]
  help_lock = true
  tutime = 0
  sfx(5,1)
  mode = "help"
  return
 end
 local front = lvl_data[lvl_cur%#lvl_data+1]
 if prog[play_l][1] == "fin" then
  local ident = 0
  local i = play_l
  while ident <= 0 do
   i -= 1
   ident += ident_instr(prog[i])
  end
  if prog[i][1] == "if" then
   play_l += 1
  else
   play_l = i
  end
 elseif prog[play_l][1] == "if" then
  if (prog[play_l][2] == "box" and front[1] >= 1) or (prog[play_l][2] == "journal" and front[2] == 1) or (prog[play_l][2] == "car" and front[4] == 1) or (prog[play_l][2] == "fence" and front[3] == 1) then
   -- true
   play_l += 1
  else -- false
   local ident = 0
   local i = play_l
   while ident >= 0 do
    i += 1
    ident += ident_instr(prog[i])
   end
   play_l = i+1
  end
 elseif prog[play_l][1] == "repeat" then
  play_l += 1
 elseif prog[play_l][1] == "left" then
  d_lane = 0
  play_l += 1
 elseif prog[play_l][1] == "right" then
  d_lane = 1
  play_l += 1
 elseif prog[play_l][1] == "pick up" then
  if d_lane == 0 and front[2] == 1 then
   papers += 5
   front[2] = 0
  end
  play_l += 1
 elseif prog[play_l][1] == "throw" then
  if papers > 0 then
   papers -= 1
   if front[1] == 1 then
    sfx(3)
    front[1] = 2
    score += 1
    if score == goal then
     nxt_lvl()
    end
   else
    sfx(4)
   end
  end
  play_l += 1
 elseif prog[play_l][1] == "forward" then
  if (d_lane == 0 and front[3] == 1) or (d_lane == 1 and front[4] == 1) then
   -- crash
   sfx(1)
   d_state = 2
   help_data = tutos[8]
   help_lock = true
   tutime = 0
   sfx(5,1)
   mode = "help"
  else
   sfx(0)
   if front[1] == 2 then
    -- init mailbox for next time
    front[1] = 1
   end
   lvl_cur += 1
   play_l += 1
  end
 end
 if prog[play_l] and prog[play_l][1] == "throw" and papers > 0 then
  sfx(2)
 end
end

function _update()
 mouse_x = stat(32)
 mouse_y = stat(33)
 clicked = stat(34) % 2
 
 if wait_unclick then
  if clicked == 0 then
   wait_unclick = false
  end
  return
 end
 
 if mode == "help" then
  if clicked == 1 and not help_lock and not the_end then
   mode = "code"
   wait_unclick = true
  end
 elseif mode == "play" then
  if clicked == 1 and in_box(22, 81, 30, 89) then
   mode = "code"
   wait_unclick = true
  else
   tick += 1
   if tick == ticks then
    play_step()
    tick = 0
   end
  end
 elseif mode == "code" then
  if clicked == 1 then
   local l = find_l(mouse_x, mouse_y)
   local c = find_c(mouse_x, mouse_y)
   if in_box(22, 81, 30, 89) then
    mode = "play"
    init_play()
    wait_unclick = true
   elseif in_box(41, 73, 49, 81) then
    mode = "remove"
    wait_unclick = true
   elseif c != nil then
    if prog[c][2] == "box" then prog[c][2] = "journal"
    elseif prog[c][2] == "journal" then prog[c][2] = "fence"
    elseif prog[c][2] == "fence" then prog[c][2] = "car"
    elseif prog[c][2] == "car" then prog[c][2] = "box" end
    wait_unclick = true
   elseif l != nil then
    mode = "move"
    move_l = l
    move_min = 1
    move_max = #prog
    if prog[l][1] == "fin" then
     move_min = find_min_l(l)
    elseif ident_instr(prog[l]) == 1 then
     move_max = find_max_l(l)
    end
   else
    for i=1,#a_coords do
     if in_box(a_coords[i][1], a_coords[i][2], a_coords[i][3], a_coords[i][4]) then
      add_instr(a_coords[i][5])
      wait_unclick = true
     end
    end 
   end
  end
 elseif mode == "move" then
  if clicked == 0 then
   mode = "code"
  else
   local l = flr((mouse_y - prog_y) / 8) + 1
   if l < move_min then l = move_min
   elseif l > move_max then l = move_max end
   move_prog_l(move_l, l)
   move_l = l
  end
 elseif mode == "remove" then
  if clicked == 1 then
   local l = find_l(mouse_x, mouse_y)
   if l != nil then
    remove_instr(l)
   end
   mode = "code"
   wait_unclick = true
  end
 end
end

-->8
function draw_ident(l, ident)
 for i = 1,ident do
  local x = prog_x+(i-1)*ident_width
  local y = prog_y+(l-1)*8-1
  rectfill(x, y, x+ident_width-2, y+9, ident_col)
 end
end

function r_rect(x, y, w, h, col, a, b, c, d)
 -- a b
 -- c d -> 0 = round, 1 = sharp
 rectfill(x+1, y, x+w-2, y+h-1, col)
 line(x, y+1-a, x, y+h-2+c, col)
 line(x+w-1, y+1-b, x+w-1, y+h-2+d, col)
end

function draw_instr(l, ident, instr)
 local txt, col, nident
 local a, b, c, d = 0, 0, 0, 0
 local cond = nil
 nident = ident
 if ident_instr(instr) == 1 then
  if instr[1] == "if" then
   txt = instr[1].." "..instr[2]
   cond = instr[2]
  else
   txt = instr[1]
  end
  col = ident_col
  nident += 1
  c = 1
 elseif instr[1] == "fin" then
  txt = instr[1]
  col = ident_col
  a = 1
 else
  txt = instr[1]
  col = act_col
 end
 local box_x = prog_x+ident*ident_width
 local box_y = prog_y+(l-1)*8
 local box_w = #txt*4+4
 r_rect(box_x, box_y, box_w, 7, col, a, b, c, d)
 nl_coords[l] = {box_x, box_y, box_x+box_w, box_y+7}
 if instr[1] == "fin" then
  line(box_x, box_y-1, box_x+ident_width-2, box_y-1, ident_col)
 end
 if cond != nil then
  local cond_w = #cond*4-1
  local cond_x = box_x+box_w-cond_w-3
  r_rect(cond_x, box_y, cond_w, 7, cond_col, 1, 1, 1, 1)
  add(nc_coords, {cond_x, box_y, cond_x+cond_w, box_y+7, l})
 end
 print(txt, box_x+2, box_y+1, 0)
 return nident
end

function sprs(c, r, w, h, x, y)
 for i=0,w-1 do
  for j=0,h-1 do
   spr((r+j)*16+c+i, x+i*8, y+j*8)
  end
 end
end

function draw_bg()
 sprs(0, 12, 6, 4, 1, 95)
end

function draw_ft()
 local front = lvl_data[lvl_cur%#lvl_data+1]
 local back = lvl_data[(lvl_cur+1)%#lvl_data+1]
 if back[1] == 1 then spr(9, 19, 99) end
 if front[1] == 1 then spr(8, 0, 113) end
 if front[1] == 2 then spr(20, 0, 113) end
 if back[2] == 1 then spr(18, 30, 101) end
 if front[2] == 1 then spr(19, 20, 116) end
 if back[3] == 1 then spr(4, 29, 96) end
 if front[3] == 1 then sprs(5, 0, 3, 1, 10, 109) end
 if back[4] == 1 then spr(3, 40, 98) end
 if front[4] == 1 then spr(2, 35, 110) end

 if mode == "play" and prog[play_l] and prog[play_l][1] == "throw" and papers > 0 then
  d_state = 1
  if d_lane == 0 then
   spr(13, 8, 113)
  else
   spr(13, 17, 114)
  end
 end
 if d_lane == 0 and d_state == 0 then spr(10, 16, 117)
 elseif d_lane == 0 and d_state == 1 then spr(11, 16, 117)
 elseif d_lane == 0 and d_state == 2 then spr(12, 21, 112)
 elseif d_lane == 1 and d_state == 0 then spr(10, 32, 117)
 elseif d_lane == 1 and d_state == 1 then spr(11, 32, 117)
 elseif d_lane == 1 and d_state == 2 then spr(12, 34, 113) end
 if d_state == 1 then d_state = 0 end
end

function draw_instr_btn(instr, x, y)
 local col
 if instr == "if" or instr == "repeat" then
  col = ident_col
 else
  col = act_col
 end
 local box_w = #instr*4+4
 r_rect(x, y, box_w, 7, col, 0, 0, 0, 0)
 add(na_coords, {x, y, x+box_w, y+7, instr})
 print(instr, x+2, y+1, 0)
end

function _draw()
 cls()
 hand = false

 print("program", 91, 2, 7)

 if mode == "code" or mode == "help" then
  if #prog < max_instr then
   print("add:", 2, 2, 7)
   na_coords = {}
   draw_instr_btn("throw", 2, 8)
   draw_instr_btn("forward", 2, 8*2)
   if lvl >= 2 then
    draw_instr_btn("repeat", 2, 8*3)
   end
   if lvl >= 3 then
    draw_instr_btn("if", 2, 8*4)
   end
   if lvl >= 4 then
    draw_instr_btn("left", 2, 8*5)
    draw_instr_btn("right", 2, 8*6)
    draw_instr_btn("pick up", 2, 8*7)
   end
   a_coords = na_coords
  else
   print("program", 2, 2, 7)
   print("size max", 2, 10, 7)
   print("reached", 2, 18, 7)
  end
  
  print("remove:", 2, 2+8+8*8, 7)
  print("play:", 2, 2+8+8*8+8, 7)
 end
 
 if mode == "remove" then
  print("choose what", 2, 10, 7)
  print("to remove", 2, 18, 7)
  print("from your", 2, 26, 7)
  print("program", 2, 34, 7)
 end
  
 if mode == "play" then
  rectfill(prog_x, prog_y+(play_l-1)*8-1, 128, prog_y+(play_l-1)*8+7, 8)
 end

 rect(prog_x-1, prog_y-1, 127, 127, 7)
 rect(0, 94, 49, 127, 10)

 nl_coords = {}
 nc_coords = {}
 ident = 0
 for l=1,#prog do
  local instr = prog[l]
  if instr[1] == "fin" then ident -= 1 end
  draw_ident(l, ident)
  ident = draw_instr(l, ident, instr)
 end
 l_coords = nl_coords
 c_coords = nc_coords
 
 draw_bg()
 draw_ft()
 
 if mode == "code" or mode == "help" then
  spr(14, 22, 81)
  spr(29, 41, 73)
 elseif mode == "play" then
  spr(15, 22, 81) 
 end
 
 if in_box(22, 81, 30, 89) and (mode == "code" or mode == "play") then
  hand = true
 elseif mode == "code" and in_box(41, 73, 49, 81) then
  hand = true
 elseif mode == "code" or mode == "remove" then
  for i=1,#l_coords do
   if in_box(l_coords[i][1], l_coords[i][2], l_coords[i][3], l_coords[i][4]) then
    hand = true
   end
  end
 end
 if mode == "code" then
  for i=1,#a_coords do
   if in_box(a_coords[i][1], a_coords[i][2], a_coords[i][3], a_coords[i][4]) then
    hand = true
   end
  end 
 end
 
 if mode == "play" then
  print("score: "..score.."/"..goal, 2, 50, 7)
  local col = 7
  if papers == 0 then
   col = 8
  end
  print("stock: "..papers, 2, 60, col)
 end
 
 if hand then
  spr(17, mouse_x-1, mouse_y)
 else
  spr(1, mouse_x-1, mouse_y)
 end
 
 if mode == "help" then
  tutime += 1
  local nc = flr(tutime/tu_speed)
  for i=1,#help_data do
   local txt = help_data[i][1]
   if #txt > nc then
    txt = sub(txt, 1, nc)
   end
   rectfill(help_data[i][2], help_data[i][3], help_data[i][2]+#txt*4, help_data[i][3]+6, 2)
   print(txt, help_data[i][2]+1, help_data[i][3]+1, 7)
   nc -= #txt
   if nc <= 0 then break end
  end
  if nc > 0 then
   sfx(-1,1)
   help_lock = false
  end
 end
end
__gfx__
01234567575fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbffff8888888f
89abcdef5775ffffff88888ffff888fffffffffffffffffffffffffffffffffffffffffffffffffffff9f9fff9ffffffffffffffffffffffffbbbfff88888882
0000000057775ffffccccc88ffcccc8ffffffffffff4f4f4f4f4f4f4f4f4fffffff444ffffffffffffff9fffff95ffffffffffffffffffffffbbbbff88888882
00000000577775fffccccc80fa888a0ffffffffffff44444444444444444fffffff444ffffff44ffffff5ffff9ff5fffffff59fffffff7ffffbbbbbf88888882
000000005777775fa8888a8ff88888ff44444444fff4f4f4f4f4f4f4f4f4fffffff4ffffffff4ffffff555fffff555fff55f9f9ffff777ffffbbbb3f88888882
00000000ff575fff8888888ff0fff0ff4f4f44f4fff4f4f4f4f4f4f4f4f4fffffff4ffffffff4ffffff595fffff595fff5950ffffff7ffffffbbb3ff88888882
00000000ff5775ff00fff00ffffffffffffffffffffffffffffffffffffffffffff4fffffffffffffff555fffff555fff5f555ffffffffffffbb3fff88888882
00000000fff575ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0fffffff0fffffffffffffffffffffb3fffff2222222
ffffffff575fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff88ffff88ffffffffffffffff
ffffffff5757575fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff888ff882ffffffffffffffff
ffffffff5757575fffffffffffff7ffffff44777fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff888882fffffffffffffffff
ffffffff57777775fff7ffffff777ffffff4477fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8882ffffffffffffffffff
ffffffff57777775fff77ffffff777fffff4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8888ffffffffffffffffff
ffffffff57777775fffffffffff77ffffff4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff882888fffffffffffffffff
fffffffff577775ffffffffffffffffffff4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff882ff888ffffffffffffffff
fffffffff577775fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff82ffff88ffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
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
33333333333333333333333333333333333333dd6666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333344442222233333333333ddd6666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333444444444a2233333333ddd66666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444aaaaa3333333dddd66666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333334444444aaacac333333dddd666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333999999aacccaa33333ddddd666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333999999aacccaabbbbbdddd6666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333999999aacccabbbbbddddd6666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333999999aaccbbbbbbddddd66666666666700000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333999999aacbbbbbbdddddd66666666666700000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333999999abbbbbbbdddddd666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
444222222233333333333bbbbbbbddddddd666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
444444aaa2223333333333333333dddddd6666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
4444aaaaaaa3333333333333333ddddddd6666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
444aaaaaaca333333333333333ddddddd66666666666667600000000000000000000000000000000000000000000000000000000000000000000000000000000
44aaaaccaca33333333333333dddddddd66666666666667600000000000000000000000000000000000000000000000000000000000000000000000000000000
4aaaccccaaa3333333333333dddddddd666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
aaacccccaaa333333333333ddddddddd666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
aaacccccaaabbbbbbbbbbbddddddddd6666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
aaacccccaabbbbbbbbbbbbddddddddd6666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
aaacccccabbbbbbbbbbbbddddddddd66666666666666676600000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaccccbbbbbbbbbbbbbdddddddddd66666666666666676600000000000000000000000000000000000000000000000000000000000000000000000000000000
aaacccbbbbbbbbbbbbbdddddddddd666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
aaacbbbbbbbbbbbbbbddddddddddd666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
aaabbbbbbbbbbbbbbddddddddddd6666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
aabbbbbbbbbbbbbbbddddddddddd6666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbddddddddddd66666666666666666766600000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbdddddddddddd66666666666666666766600000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbdddddddddddd666666666666666666766600000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333ddddddddddddd666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333ddddddddddddd6666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333ddddddddddddd6666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001535010400123001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000333501e35018350133500d3500a3500935007350063500635000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000193301b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002233021200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001043015400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060006090000b100091000d100151001610007100082000d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
