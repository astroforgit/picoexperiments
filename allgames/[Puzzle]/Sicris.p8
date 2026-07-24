pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- sicris v1.12
-- by gyt

-------------------------------
--                           --
--      ÄÄ                 --
--     Ä                    --
--       Ä p o i l e r s    --
--    ÄÄ   b e l o w       --
--                           --
-------------------------------

lev_cols = {1,2,3,4,5,6,6,6,7,7,8,9,9,9,10,10,11,12,13,14}

function _init()
 cartdata("gyt_sicris")
 start_menu()
end

function start_menu()
 mode = mode or 0
 level = level or 1
 state,phi,left_key,right_key,up_key,down_key,rotated,particles = 0,0,0,1,2,3,false,{}
 hiscore,maxlevel,finscore = dget(0),max(dget(1), 1),dget(2)
 music(0)
 code = {2,2,3,3,0,1,0,1,5,4,
         cur = max(dget(3), 1)
        }
end

function one_or_minus()
 return 1 - 2*flr(rnd(2))
end

function new_figbag(add_size)
 local add_size = add_size or 0
	for i=1,7+add_size do
	 add(figbag,i)
	end
end

function add_color()
	c = add_colors[1+flr(rnd(#add_colors))]
 add(cur_colors,c)
 del(add_colors,c)
end

function new_colors_bag()
 for i=1,#cur_colors do
  add(colors_bag, cur_colors[i])
 end
end

function bang_need()
	return min(5,level)+max(0,flr(level/2-3+0.6))
end

function new_box(wd)
 wd = wd or 60
 box, box_w, box_h = {}, wd/cell, 120/cell
 for y=1,box_h do
  box[y] = {}
  for x=1,box_w do
   box[y][x] = 15
  end
 end
end

function game_start()
 menuitem(1, "restart level", game_start)
 menuitem(2, "back to menu", start_menu)
 bang_box,figbag,fig,nextfig,holdfig,add_colors,cur_colors,colors_bag = {},{},{},{},{},{},{},{}
 new_figbag()
 timer,d_time,score,state,cell,bang_size,can_use_hold = 0,0,0,1,6,10,true
 if level >= 12 then
  cell = 4
 elseif level >= 6 then
 	cell = 5
 end
 new_box()
 bang_needed = bang_need()
 if (level >= 4) bang_size = 9 + flr(level/2)
	for c=1,14 do
	 add(add_colors,c)
	end
	for c=1,lev_cols[min(level,20)] do
	 add_color()
	end
	new_colors_bag()
 fig, holdfig = create_fig(), create_fig()
 if fig.spd < 0 then
  fig.spd = 1
 	fig_to_edge(true)
 end
 for i=1,4 do
	 nextfig[i] = create_fig()
 end
 music(-1)
 if (mode==1) bang_needed = 0
 if (mode==2) boss_fight()
end

function wall_x(left)
 if left then
  fig.x = -cell*(fig_left_x()-2)
 else
  holdfig.x = box_w*cell-cell*fig_right_x(holdfig)
 end
end

function game_over()
 music(-1)   
 if state==2 then
  sfx(36)
 else 
  sfx(5)
 end
 new_box()
 state,mode,fig,holdfig  = 2,3,create_fig(),create_fig()
 fig.spd = one_or_minus()
 fig_to_start()
 wall_x(true)
 holdfig.spd = -fig.spd
 fig_to_start(holdfig)
 wall_x(false)
end

function box_bottom_full()
 for x=1,box_w do
  if (box[box_h][x] ~= 15) return true
 end
 return false
end

function box_top_full()
 for x=1,box_w do
  if (box[1][x] ~= 15) return true
 end
 return false
end

function rnd_col()
 local c, used = colors[flr(rnd(#colors)+1)], false
 for i=1,#used_colors do
  if used_colors[i]==c then
   used = true
   break
  end
 end
 if not used then
  add(used_colors, c) 
 end
 return c
end

function new_fig_matrix(matr, col_nums)
 local try = 0
 while try < 4 and #used_colors < col_nums do
  used_colors = {}
  try += 1
  for y=1,#matr do
   for x=1,#matr do
    if (matr[y][x] != 0) matr[y][x] = rnd_col() 
   end
  end
 end
 return matr
end

function create_fig(t)
 colors,used_colors = {},{}
 local col_nums, newfig = rnd(100), {}
 if not t then
 	if (#figbag == 0) new_figbag(min(4,max(0,level-2)))
 	t = figbag[1+flr(rnd(#figbag))]
 	del(figbag,t)
 end
 if col_nums < 8 then
  col_nums = 1
 elseif col_nums < 80-min(24,level-1) then
  col_nums = 2
 elseif col_nums < 94-min(8,flr(level/3)) then
  col_nums = 3
 else
  col_nums = 4
 end
 col_nums = min(level,col_nums)
 if t == 11 then
  col_nums = 1
 elseif t == 10 then
  col_nums = min(col_nums, 2)
 elseif t == 9 or t == 8 then
  col_nums = min(col_nums, 3)
 end
 for i=1,col_nums do
  local c = 1+flr(rnd(#colors_bag))
  add(colors,colors_bag[c])
  del(colors_bag,colors_bag[c])
  if (#colors_bag == 0) new_colors_bag()
 end
 if t == 1 then
	 newfig = new_fig_matrix({{rnd_col(),0,0},{rnd_col(),rnd_col(),rnd_col()},{0,0,0}},col_nums)
 elseif t == 2 then
  newfig = new_fig_matrix({{0,rnd_col(),0},{rnd_col(),rnd_col(),rnd_col()},{0,0,0}},col_nums)
 elseif t == 3 then
  newfig = new_fig_matrix({{0,0,rnd_col()},{rnd_col(),rnd_col(),rnd_col()},{0,0,0}},col_nums)
	elseif t == 4 then
	 newfig = new_fig_matrix({{0,rnd_col(),rnd_col(colors)},{rnd_col(),rnd_col(),0},{0,0,0}},col_nums)
 elseif t == 5 then
  newfig = new_fig_matrix({{rnd_col(),rnd_col(),0},{0,rnd_col(),rnd_col()},{0,0,0}},col_nums)
 elseif t == 6 then
  newfig = new_fig_matrix({{rnd_col(),rnd_col()},{rnd_col(),rnd_col()}},col_nums)
 elseif t == 7 then
  newfig = new_fig_matrix({{0,0,0,0},{rnd_col(),rnd_col(),rnd_col(),rnd_col()},{0,0,0,0},{0,0,0,0}},col_nums)
 elseif t == 8 then
  newfig = new_fig_matrix({{0,0,0},{rnd_col(),rnd_col(),rnd_col()},{0,0,0}},col_nums)
 elseif t == 9 then
  newfig = new_fig_matrix({{rnd_col(),rnd_col()},{rnd_col(),0}},col_nums)
 elseif t == 10 then
  newfig = new_fig_matrix({{rnd_col(),rnd_col()},{0,0}},col_nums)
 elseif t == 11 then
  newfig = {{rnd_col()}}
 end
 newfig.m = #newfig
 for i=0,flr(rnd(3)) do
  matrix_rotate(true,newfig)
 end
 for i=1,#colors do
  local unused = true
  for j=1,#used_colors do
   if colors[i] == used_colors[j] then
    del(used_colors,used_colors[j])
    unused = false
    break
   end
  end
  if (unused) add(colors_bag,colors[i])
 end
 newfig.t = t
 local bottom_full, top_full = box_bottom_full(), box_top_full()
 if state == 1 and bottom_full and not top_full then
  newfig.spd = 1
 elseif state == 1 and top_full and not bottom_full then
  newfig.spd = -1
 else
 	newfig.spd = one_or_minus()
 end
 --if (cell<=4) newfig.spd *= cell
 fig_to_start(newfig)
 return newfig
end

function rotate_box()
  rotated = not rotated
  if rotated then
   left_key,right_key,up_key,down_key=2,3,0,1
	 else
	  left_key,right_key,up_key,down_key=0,1,2,3
	 end
end

function matrix_rotate(clock,fg)
 fg = fg or fig
 for y=2,fg.m do
  for x=1,y-1 do
   if x != y then
   	fg[x][y],fg[y][x] = fg[y][x],fg[x][y]
   end
  end
 end
 if clock then
	 for x=1,fg.m/2 do
	  for y=1,fg.m do
	   	fg[y][x],fg[y][fg.m+1-x] = fg[y][fg.m+1-x],fg[y][x]
	  end
	 end
	else
	 for x=1,fg.m do
	  for y=1,fg.m/2 do
	   	fg[y][x],fg[fg.m+1-y][x] = fg[fg.m+1-y][x],fg[y][x]
	  end
	 end
	end
end

function rotate(clock,fg)
 local fx, fy
 local dr,bad_d = {{0,0},{1,0},{-1,0},{0,1},{0,-1}},false
 fg = fg or fig 
 matrix_rotate(clock, fg)
 
	for d in all(dr) do
	 bad_d = false
	 for y=1,fg.m do
	  fy = y+fg.y/cell+d[2]
	  for x=1,fg.m do
	   if fg[y][x] != 0 then
	    fx = x+fg.x/cell+d[1]
			  if fx < 1 or
			     fx > box_w then
			   bad_d = true
			   break
			  elseif fy >= 1 and
			     fy <= box_h and
			     box[fy][fx]!=15 then
			   bad_d = true
			   break
	    end
	   end
	  end
	  if (bad_d) break
	 end
	 if not bad_d then
	  fg.x+=d[1]*cell
	  fg.y+=d[2]*cell
	  break
	 end
	end 
 if bad_d then
  rotate(not clock)
 else
  wait_before_place()
 end
end

function fig_to_start(fg)
 fg = fg or fig
 fg.x = cell*(flr(box_w/2)-flr(fg.m/2+rnd(1)))
	fig_to_edge(fg.spd>0, fg)
end

function fig_to_edge(top,fg)
 fg = fg or fig
 if top then
 	fg.y = -fig_bottom_y(fg)*cell
 else
  fg.y = 120+(2-fig_top_y(fg))*cell
 end
end

function fig_left_x(fg)
 fg = fg or fig
 for x=1,fg.m do
  for y=1,fg.m do
   if fg[y][x] != 0 then
   	return x
   end
  end
 end
end

function fig_right_x(fg)
 fg = fg or fig
 for x=fg.m,1,-1 do
  for y=1,fg.m do
   if fg[y][x] != 0 then
   	return x+1
   end
  end
 end
end

function fig_bottom_y(fg)
 fg = fg or fig
 for y=fg.m,1,-1 do
  for x=1,fg.m do
   if fg[y][x] != 0 then
   	return y+1
   end
  end
 end
end

function fig_top_y(fg)
 fg = fg or fig 
 for y=1,fg.m do
  for x=1,fg.m do
   if fg[y][x] != 0 then
   	return y
   end
  end
 end
end

function fig_bottom_free(fg)
 fg = fg or fig
 local fx, fy
 for x=1,fg.m do
  fx = x+fg.x/cell
  for y=fg.m,1,-1 do
   if fg[y][x] != 0 then
    fy = y+1+fg.y/cell
		  if fy == box_h+2 and
		     box[1][fx]!=15 then
		     return "full"
		  end
    if fy >= 1 and
       fy <= box_h and
       box[fy][fx]!=15 then
       return false
    end
   	break
   end
  end
 end
 return true
end

function fig_top_free(fg)
 fg = fg or fig
 local fx, fy
 for x=1,fg.m do
  fx = x+fg.x/cell
  for y=1,fg.m do
   if fg[y][x] != 0 then
    fy = y-1+fg.y/cell
		  if fy == -1 and
		     box[box_h][fx]!=15 then
		   return "full"
		  end
    if fy >= 1 and
       fy <= box_h and
       box[fy][fx]!=15 then
       return false
    end
   	break
   end
  end
 end
 return true
end

function fig_left_free()
 local fy
 for y=1,fig.m do
  fy = y+fig.y/cell
  for x=1,fig.m do
   if fig[y][x] != 0 then
    if fy >= 1 and
       fy <= box_h and
       box[fy][x+fig.x/cell-1]!=15 then
       return false
    end
   	break
   end
  end
 end
 return true
end

function fig_right_free()
 local fy
 for y=1,fig.m do
  fy = y+fig.y/cell
  for x=fig.m,1,-1 do
   if fig[y][x] != 0 then
    if fy >= 1 and
       fy <= box_h and
       box[fy][x+fig.x/cell+1]!=15 then
       return false
    end
   	break
   end
  end
 end
 return true
end

function has_value(tab, val)
 for value in all(tab) do
  if value[1] == val[1] and
     value[2] == val[2] then
   return true
  end
 end
 return false
end

function has_val(tab, val)
 for value in all(tab) do
  if value == val then
   return true
  end
 end
 return false
end

function same_cell_chain(cx,cy,col,same,way)
 for d in all(way) do
 	if cx+d[1] <= box_w and 
 	   cx+d[1] >= 1 and 
 	   cy+d[2] <= box_h and 
 	   cy+d[2] >= 1 and not 
 	   has_value(same, {cx+d[1],cy+d[2]}) then
   if type(col) == 'table' and box[cy+d[2]][cx+d[1]]!=15 and not has_val(col, box[cy+d[2]][cx+d[1]]) then
    if ((level==7 and #col<2) or
       (level==13 and #col<3)) then
     add(col,box[cy+d[2]][cx+d[1]])
    else
     return same
    end
   end
   if ((type(col) == 'table' and has_val(col, box[cy+d[2]][cx+d[1]])) or
      (col == 15 and box[cy+d[2]][cx+d[1]]!=col) or
      (col != 15 and box[cy+d[2]][cx+d[1]]==col)) then
    add(same,{cx+d[1],cy+d[2]})
    same=same_cell_chain(cx+d[1],cy+d[2],col,same,way)
   end
  end
 end
 return same
end

function decrease_cell()
 cell-=1
	local new_box_w,new_box_h = 120/(2*cell), 120/(cell)
	for by=1,box_h do
	 for bx=box_w+1,new_box_w do
	  box[by][bx]=15
	 end
	end
	for by=box_h+1,new_box_h do
	 box[by]={}
	 for bx=1,new_box_w do
	  box[by][bx]=15
	 end
	end
	box_w, box_h = new_box_w, new_box_h
	fig_to_start(nextfig[1])
 fig_to_start(holdfig)
end

function check_edge(b_full, t_full, fg)
 if b_full and fg.spd < 0 then
  fg.spd = 1
  fig_to_edge(true, fg)
 elseif t_full and fg.spd > 0 then
  fg.spd = -1
  fig_to_edge(false, fg)
 end
end

function add_junk()
 local bx,by
 for i=1,4 do
  by = 1 + flr(box_w/2 + rnd(box_w))
  bx = 1+flr(rnd(box_w))
  if box[by][bx] == 15 then
   box[by][bx] = 0
   break
  end
 end
end

function fig_to_box(fg)
 sfx(1)
 fg = fg or fig
 local x_now, y_now, c_now
 local same_cells, bangs, overval, is_line, way = {}, 0, 2, has_val({1,2,6,7,12,13}, level), {{1,0},{-1,0},{0,1},{0,-1}}
 for y=1,fg.m do
  y_now = y+fg.y/cell
  for x=1,fg.m do
   if fg[y][x] != 0 then
	   if y_now < 1 or y_now > box_h then
	    if state == 4 and score > level*100 then
	     score -= level*100
	     music(-1)
	     state = 7
	     sfx(23)
     else
      if state == 2 then
      	overval = 22
      	break
      else
       timer = 10
	      game_over()
	     end
	    end
	    return 
	   end
   	box[y_now][x+fg.x/cell]=fg[y][x]
   end
  end
 end
	if state==2 or (mode==0 and state==1 and box_top_full() and box_bottom_full()) then
 	for y=1,fg.m do
		 y_now = y+fg.y/cell
  	for x=1,fg.m do
	   if fg[y][x] != 0 then
		   x_now = x+fg.x/cell
					same_cells = same_cell_chain(x_now,y_now,15,{{x_now,y_now}},{{0,1},{0,-1}})
					if #same_cells >= box_h then
						super_bang()
					 return
					end
				end
			end
		end
	end
	if state==2 then
	 timer = 10
	 if overval != 2 then
	  game_over()
	 end
	 return overval
	end
 --search = true
 --while search do
 --again = false
	if is_line then
	 way = {{1,0},{-1,0}}
	elseif level == 3 then
	 way = {{1,1},{1,-1},{-1,1},{-1,-1}}
	elseif level == 9 or level == 15 then
	 way = {{1,0},{-1,0},{0,1},{0,-1},{1,1},{1,-1},{-1,1},{-1,-1}}
 end
 for x=1,fig.m do
  x_now = x+fig.x/cell
  for y=1,fig.m do
   if fig[y][x] != 0 then
	   y_now = y+fig.y/cell
	   c_now = box[y_now][x_now]
	   if c_now != 15 then
					if (level==6 or level==12) c_now = 15
					if (level==7 or level==13) c_now = {c_now}
	    same_cells = same_cell_chain(x_now,y_now,c_now,{{x_now,y_now}},way)
	    if is_line and #same_cells < bang_size then
	     same_cells = same_cell_chain(x_now,y_now,c_now,{{x_now,y_now}},{{0,1},{0,-1}})
	    end
	    if #same_cells >= bang_size then
	     bangs += 1
	     score += #same_cells
	     for c in all(same_cells) do
	      for i=0,1+flr(rnd(3)) do
	      	add(bang_box, {c[1],c[2],box[c[2]][c[1]], 0, 0, cos(rnd())*(rnd(2)+1), -(1+rnd(2)), 30+flr(rnd(30))})
	      end
	      box[c[2]][c[1]] = 15
	     end
	     --gain = true
	     --break
	    end
	   end
	  end
  end
  --if (again) break
  --search = false
 end
	--end
 if bangs > 0 then
  sfx(4)
  if state == 4 or mode==1 then
	  bang_needed+=bangs
	  local n = 4
			if has_val({1,6,12}, level) then
	   n = 2
	  elseif level < 10 or level==15 then
	   n = 3
	  end
	  if mode==1 and bang_needed>=5 and rnd(n)<1 then
	   sfx(0)
	   for i=1,flr(bang_needed/5) do
	   	add_junk()
	   end
	  end
	 else
	  bang_needed-=bangs
	 end
  if (bangs > 1) score+=flr(bangs*bangs/2)*bang_size
  if bang_needed <= 0 then
   sfx(6)
   score+=50*level
   if (level <= 19 and lev_cols[level+1]>lev_cols[level]) add_color()
  	level+=1
  	bang_needed = bang_need()
  	if level > maxlevel then
    maxlevel = level
    dset(1, maxlevel)
  	end
  	if (level >=5 and level%2!=0) bang_needed+=1
  	if (level >=4 and level%2==0) bang_size+=1
  	if level==6 or level==12 then
    decrease_cell()
   end
   if (level==10) rotate_box()
   for i=2,#nextfig do
   	nextfig[i] = create_fig(nextfig[i].t)
   end
  end
 end
 local bottom_full, top_full = box_bottom_full(), box_top_full()
 if not bottom_full or not top_full then
	 for i=1,#nextfig do
	 	check_edge(bottom_full, top_full, nextfig[i])
  end
 end
 fig = nextfig[1]
 for i=1,#nextfig-1 do
 	nextfig[i] = nextfig[i+1]
 end
 nextfig[#nextfig] = create_fig()
	score += 1
	can_use_hold,d_time,timer = true,0,15
 if mode==0 and score > hiscore then 
  hiscore = score
  dset(0, hiscore)
 end
 local box_c = box_h/2
 local xc3,yc3 = box_c+1,box_c-1
 if (rotated) xc3,yc3 = yc3,xc3
 if state == 4 and
    box[box_c][box_c] == 15 and
    box[box_c+1][box_c+1] == 15 and
    box[xc3][yc3] == 15 then
  if mode==0 and score > finscore then
   dset(2,score)
  end
  music(-1)
  sfx(25)
  score+=level*100
  state = 6
 end
end

function b_col()
 return cur_colors[flr(rnd(#cur_colors)+1)]
end

function new_boss()
 boss = {{0,0,0,0,0,b_col(),b_col(),0,0,0,0,0,0,0},
         {0,0,0,0,0,0,b_col(),0,b_col(),b_col(),0,0,0,0},
         {0,0,0,b_col(),b_col(),0,b_col(),0,b_col(),b_col(),0,b_col(),0,0},
         {0,0,0,0,b_col(),b_col(),0,b_col(),0,0,b_col(),b_col(),0,b_col()},
         {b_col(),b_col(),b_col(),b_col(),0,0,b_col(),0,b_col(),b_col(),0,0,b_col(),b_col()},
         {0,0,0,0,b_col(),b_col(),0,b_col(),0,0,b_col(),b_col(),0,b_col()},
         {0,0,0,b_col(),b_col(),0,b_col(),0,b_col(),b_col(),0,b_col(),0,0},
         {0,0,0,0,0,0,b_col(),0,b_col(),b_col(),0,0,0,0},
         {0,0,0,0,0,b_col(),b_col(),0,0,0,0,0,0,0}
        }
 boss_x = 4+flr(60/cell-5.5)*cell
 boss_y = 22*cell
end

function super_bang()
 local spd = 2
 if state == 2 then
  spd = 1
 end
	state,bang_box = 3,{}
	for y=1,box_h do
	 bang_box[y] = {}
	 for x=1,box_w do
	  bang_box[y][x] = {box[y][x], 0, 0, rnd(spd)+0.2, rnd(spd)+0.2}
	 end
	end
	sfx(31)
	new_boss()
end

-- cheetahmen music from:
-- http://www.lexaloffle.com/bbs/?pid=33777

function boss_fight()
 if (not boss) new_boss()
 bang_needed,bull_time,state,bullets,bang_box = 0,0,4,{},{}
 new_box(120)
 fig = create_fig()
 for i=1,#nextfig do
 	nextfig[i] = create_fig()
 end
 holdfig = create_fig()
 local yc,xc = 1+flr(box_h/2-5), 1+flr(box_w/2-7)
 for y = yc,yc+8 do
  for x = xc,xc+13 do
   if (boss[y-yc+1][x-xc+1]!=0) box[x][y] = boss[y-yc+1][x-xc+1]
  end
 end
 music(22)
end

function wait_before_place()
	if ((fig.spd > 0 and fig_bottom_free()!=true) or
	   (fig.spd < 0 and fig_top_free()!=true)) then
	 d_time = 0
	end
end

function fig_controls()
 if (btnp(4,1) or btnp(4) and btnp(5)) and can_use_hold then
  sfx(36)
  fig_to_start()
  fig, holdfig = holdfig, fig
  if holdfig.y > box_h/2 then
   fig.spd = -1
  	fig_to_edge(false)
  else
   fig.spd = 1
  	fig_to_edge(true)
  end
  d_time,can_use_hold = 0,false
  return
 elseif btnp(4) then
  rotate(false)
  sfx(2)
 elseif btnp(5) then
  rotate(true)
  sfx(3)
 end
 if btnp(left_key) then
  if state == 4 and fig.x+cell*fig_left_x() == cell then
   fig_wrap(fig.x,(box_w-fig_right_x()+1)*cell)
  elseif fig.x+cell*fig_left_x() > cell
     and fig_left_free() then 
   wait_before_place()
   fig.x-=cell
  elseif fig.y/cell+fig_bottom_y() <= box_h+1 and
         fig.y/cell+fig_top_y() >= 1 then
   fig_to_box() 
  end
 end
 if btnp(right_key) then
  if state == 4 and fig.x+cell*fig_right_x() == box_w*cell+cell then
   fig_wrap(fig.x,0)
  elseif fig.x+cell*fig_right_x() <= box_w*cell
     and fig_right_free() then 
   wait_before_place()
   fig.x+=cell
  elseif fig.y/cell+fig_bottom_y() <= box_h+1 and
         fig.y/cell+fig_top_y() >= 1 then
   fig_to_box() 
  end
 end
	if fig.spd > 0 and fig.y > 120+cell-fig_top_y()*cell then
  fig_to_edge(true)
 end
 if fig.spd < 0 and fig.y < cell-fig_bottom_y()*cell then
  fig_to_edge(false)
 end
 if btn(up_key) then
  if fig.spd == -1 and timer == 0 then
   	fig.spd = -2*cell
  end
 elseif fig.spd == -2*cell then
  fig.spd = -1
 end
 if btn(down_key) then
  if fig.spd == 1 and timer == 0 then
   	fig.spd = 2*cell
  end
 elseif fig.spd == 2*cell then
  fig.spd = 1
 end
 if btnp(up_key) then
   if fig.spd > 0 and 
      fig.y > -fig_bottom_y()*cell and
      fig.y < 120+2*cell-fig_top_y()*cell then
     fig.spd = 0
   elseif fig.spd == 0 then
    fig.spd = -1
    d_time = 4*cell-1
    timer = 8
   end
 end
 if btnp(down_key) then
   if fig.spd < 0 and 
      fig.y > -fig_bottom_y()*cell and
      fig.y < 120+2*cell-fig_top_y()*cell then
     fig.spd = 0
   elseif fig.spd == 0 then
    fig.spd = 1
    d_time = 4*cell-1
    timer = 8
   end
 end
end

function fig_wrap(orig_x,new_x)
 fig.x = new_x
 for y=1,fig.m do
  fy = y+fig.y/cell
  for x=1,fig.m do
   fx = x+fig.x/cell
   if fy>0 and fy<box_h and fig[y][x] != 0 and box[fy][fx]!=15 then
		  fig.x = orig_x
		  return
		 end
		end
	end
end

function auto_move()
  d_time=(d_time+1)%(4*cell/abs(fig.spd))
  if state~=3 then
   for bang in all(bang_box) do
    if rotated then
    	bang[4] += bang[7]
    	bang[5] += bang[6]
    else
    	bang[4] += bang[6]
    	bang[5] += bang[7]
    end
    bang[7] += 0.1
    bang[8] -= 1
    if bang[8]==0 then
     del(bang_box, bang)
    end
   end
  end
  if (timer > 0) timer -= 1
  if d_time == 0 then
		 if fig.spd > 0 then
		  local free = fig_bottom_free()
		  if free == "full" then
		   fig.y -= cell*sgn(fig.spd)
		   fig.spd *= -1
			 elseif free == true then
			  fig.y += cell*sgn(fig.spd)
			 else
			  fig_to_box()
			 end
			else
			 local free = fig_top_free()
		  if free == "full" then
		   fig.y -= cell*sgn(fig.spd)
		   fig.spd *= -1
			 elseif free == true then
			  fig.y += cell*sgn(fig.spd)
			 else
			  fig_to_box()
			 end
			end
		end
end

function over_fig(fg,left_wall)
  if timer == 0 and (btnp(up_key) or btnp(down_key)) then
  	fig_to_up(fg)
  	fg.spd=sgn(fg.spd)*cell
  end
  if btn(left_key) or btn(right_key) then
  	if btnp(right_key) then
    sfx(2)
  	 fig_to_up(fg)
  	 rotate(true,fg)
  	elseif btnp(left_key) then
    sfx(3)
  	 fig_to_up(fg)
  	 rotate(false,fg)
  	end
  else
			if ((fg.spd > 0 and fg.y+cell*(fig_bottom_y(fg)-1) == box_h*cell or fg.y%cell==0 and not fig_bottom_free(fg)) or
			   (fg.spd < 0 and fg.y+cell*(fig_top_y(fg)-1) == 0 or fg.y%cell==0 and not fig_top_free(fg))) then
	   if fig_to_box(fg)==2 then
				 local spd = sgn(fg.spd)
				 if left_wall then
			  	fig = create_fig()
			  	fg = fig
			  else
			   holdfig = create_fig()
			   fg = holdfig
			  end
			  fg.spd = spd
			  fig_to_start(fg)
			  wall_x(left_wall)
			 end
		 end
		 fg.y+=fg.spd
  end
end

function fig_to_up(fg)
 while fg.y%cell!=0 do
  fg.y -= sgn(fg.spd)
 end
end

function _update()
 if state == 1 then
  fig_controls()
  auto_move()
 elseif state == 0 then
  if btnp(4,1) or (btnp(4) and btnp(5)) then
   rotate_box()
   sfx(0)
  elseif code.cur != 9 and code.cur != 10 and (btnp(4) or btnp(5)) then
   game_start()
   return
  end
  if code.cur < 11 then
   if btnp(code[code.cur]) then
   	code.cur += 1
    if code.cur == 11 then
     dset(3,11)
     sfx(24)
    end
   elseif btnp() > 0 then
    code.cur = 1
   end
  end
  if btnp(1) then
   sfx(3)
   level = level%maxlevel + 1
  end
  if btnp(0) then
   sfx(2)
   level = (level-2+maxlevel)%maxlevel + 1
  end
  if rotated then
   phi=(phi-0.007)%1
  else
	  phi=(phi+0.007)%1
	 end
  local maxmode = 0
  if code.cur == 11 then
   maxmode = 3
  elseif maxlevel > 5 then
   maxmode = 2
  end
  if maxmode > 0 then
	  if btnp(2) then
	   sfx(6)
	   mode = (mode+1)%maxmode
	  end
	  if btnp(3) then
	   sfx(6)
	   mode = (mode-1)%maxmode
	  end
  end
	elseif state == 2 then
  if btnp(4) or btnp(5) then
   start_menu()
   return
  end
  if (timer > 0) timer -= 1
  over_fig(fig,true)
	 over_fig(holdfig,false)
	elseif state == 3 then
	 for x=1,box_w do
	  for y=1,box_h do
	   if x < flr(box_w/2) then
	   	bang_box[y][x][2] -= bang_box[y][x][4]
	   else
	    bang_box[y][x][2] += bang_box[y][x][4] 
	   end
	   if y < flr(box_h/2) then
	   	bang_box[y][x][3] -= bang_box[y][x][5]
	   else
	    bang_box[y][x][3] += bang_box[y][x][5] 
	   end
	  end
	 end
	 timer+=1
	 if (boss_y>4+flr((box_h-15)/2)*cell) boss_y-=1
	 if timer == 150 then
	  timer = 0
	  if mode == 3 then
	   start_menu()
	  else
	  	boss_fight()
	  end
	 end
	elseif state == 4 then
  fig_controls()
	 auto_move()
  foreach(bullets, move_bull)
  bull_time = (bull_time+1)%30
  if bull_time==0 and #bullets<8+bang_needed/10 and rnd(2-bang_needed/100)<1 then
  	local ang = rnd(1)
  	if (rnd(2-bang_needed/200)<1) ang = atan2(fig.x+cell*fig.m/2-61,fig.y+cell*fig.m/2-67)
  	add(bullets,{61,67,ang,0.2+rnd(0.8)})
	  sfx(26)
	 end
	elseif state == 5 then
  if btnp(4) or btnp(5) then
   start_menu()
   return
  end
	 timer+=1
	 if timer%(10+flr(rnd(40)))==0 then
	  timer = 0
	  boom(rnd(128),rnd(128))
	  sfx(32)
	 end
	 updateparticles()
	else
	 phi=(phi+0.01+0.0002*timer)%1
	 timer+=1
	 if timer == 150 then
	  timer = 0
	  if state == 6 then
		  state = 5
		  music(16, 3)
		 else
		  boss_fight()
		 end
	 end
	end
end

function move_bull(bull)
 bull[1]+=cos(bull[3])*bull[4]
 bull[2]+=sin(bull[3])*bull[4]
 for x=1,fig.m do
  fx = 4+fig.x+x*cell-cell
  for y=1,fig.m do
   if fig[y][x] != 0 then
    fy = 4+fig.y+y*cell-cell
    if bull[1] > fx-1 and bull[1] < fx+cell+1 and
    	bull[2] > fy-1 and bull[2] < fy+cell+1 then
  			if fig.y/cell+fig_bottom_y() > box_h+1 then
	     fig_to_edge(true)
	     fig.spd = 1
	    elseif fig.y/cell+fig_top_y() < 1 then
	     fig_to_edge(false)
	     fig.spd = -1
	    else  
  				fig_to_box()
  			end
  			sfx(27)
  			score=score-level-1
  			del(bullets,bull)
  			return
  		end
   end
  end
 end
 if bull[1] > 128 or bull[1] < 0 or
    bull[2] > 128 or bull[2] < 0 then
  del(bullets,bull)
 end
end

function _draw()
 cls()
 local bx,by,fx,fy,col,str
 if state == 1 then
  draw_box()
	 draw_fig()
	 draw_bangs(34,4)
	 for i,n in pairs(nextfig) do
		 local cell,next_left,next_right = 7-i, fig_left_x(n), fig_right_x(n)
		 for x=1,n.m do
		  fx = x*cell+111-(next_left+next_right)*cell/2
		  for y=1,n.m do
		   if n[y][x] != 0 then
		    if nextfig[1].spd > 0 then
		    	fy = 36*i-32-(fig_top_y(n)-y)*cell
		    else
		     fy = 160-36*i-(fig_bottom_y(n)-y)*cell
		    end
		    draw_cell(x,y,fx,fy,n,cell)
		   end
		  end
		 end
		end
	 local next_left,next_right,next_top,next_bottom = fig_left_x(holdfig),fig_right_x(holdfig),fig_top_y(holdfig),fig_bottom_y(holdfig)
	 local next_h, hold_str = (next_bottom-next_top)*2, 'ë  ë'
	 for x=1,holdfig.m do
	  fx = x*4+17-(next_right+next_left)*2
	  for y=1,holdfig.m do
	   if holdfig[y][x] != 0 then
	    fy = 42+y*4-next_top*4-next_h
	    draw_cell(x,y,fx,fy,holdfig,4)
	   end
	  end
	 end
	 if (rotated) hold_str = 'É  É'
	 if (not can_use_hold) hold_str = 'ì  ì'
	 draw_level_score()
	 draw_cur_goal()
	 if rotated then
	  print('ó  é', 30, 2, 9)
	  print('+', 40, 2, 10)
		 print(hold_str, 30, 25, 9)
		 print('ê', 38, 25, 10)
		 print('Ü   Ü', 70, 2, 9)
		 print(bang_size, 80, 2, 10)
		 print(bang_needed, 84-#(''..bang_needed)*2, 25, 10)
		 print('í   í', 70, 25, 9)
	 else
	  print('ó  é', 5, 33-next_h, 9)
	  print('+', 15, 33-next_h, 10)
		 print(hold_str, 5, 45+next_h, 9)
		 print('ê', 13, 45+next_h, 10)
		 print('Ü   Ü', 3, 68, 9)
		 print(bang_size, 13, 68, 10)
		 print(bang_needed, 17-2*#(""..bang_needed), 94, 10)
		 --local space = ' '
		 --while #space <= #(""..bang_needed) do
		 -- space = space..' '
		 --end
		 print('í   í', 3, 94, 9)
  end
	elseif state == 0 then
	 for i,char in pairs({"s","i","c","r","i","s"}) do
	  local rad = abs(42-i*12)
	  if i <= 3 then
	   col=flr(1+rnd(21-6*i))
	   for p=phi,0.25+phi,0.25 do
	    print(char,54+2*i+rad*cos(p),44+2*i+rad*sin(p), col)
	   end
	  else
	   col=flr(1+rnd(5*i-20))
	   for p=0.5+phi,0.75+phi,0.25 do
	   	print(char,54+2*i+rad*cos(p),44+2*i+rad*sin(p), col)
	   end
	  end
	 end
	 local add = 0 
	 if finscore != 0 then
	 	str = 'hÉgh scÉre: '..hiscore
	  add = 4
	 else
	  str = 'high score: '..hiscore
	 end
	 print(str, 64-add-#str*2, 98, 9)
	 if maxlevel == 1 then
	  str = 'start level: '..level
	  print(str, 64-#str*2, 108, 10)
	 else
	 	str = '2tart level: ã '..level..' ë'
	 	print(str, 60-#str*2, 108, 10)
	 end
	 if maxlevel > 5 then
	  if mode==0 then
	   col= 1
	   str = "norm mode"
	  elseif mode==1 then
	   col = 1+rnd(2)
	   str = "loop mode"
	  else
	   col = 2+rnd(4)
	   str = "boss mode"
	  end
		 for i=1,#str do
		  print(sub(str,i,i),120,2+i*10,col)
		 end
	 end
	 if finscore != 0 then
	  str = 'best fînal scîre: '..finscore
	  print(str, 60-#str*2, 4, 5+9*phi)
	  col = 1
	  str = "welcome to"
	  for i=1,#str do
	   if flr(8*phi+0.8)==i then
	    if(rnd(1.1)<1) col= i+7
	   else
	    col = 1
	   end
	   print(sub(str,i,i),4,8+i*8,col)
	  end
	 else 
	  print('welcome to', 42, 4, 5+9*phi)
	 end
	 print('press ó or é to 5tart', 18, 118, 15)
	elseif state == 2 then
	 draw_box()
	 draw_fig()
	 draw_fig(34,4,holdfig)
  draw_level_score()
  str = "game over"
	 for i=1,#str do
	  if i <= 5 then
	   col=flr(1+rnd(9-2*i))
	  else
	   col=flr(1+rnd(2*i-12))
	  end
	  if rotated then
	   print(sub(str,i,i), i*12+1, 111, col)
	  else
	  	print(sub(str,i,i), 111, i*12+1, col)
	  end
	 end
	 str = "íÇóîÉéåá"
	 for i=1,#str do
	  if i <= 4 then
	   col=flr(1+rnd(8-2*i))
	  else
	   col=flr(1+rnd(i*2-9))
	  end
	  if rotated then
	  	print(sub(str,i,i), 16+i*10, 13, col)
	  else
	  	print(sub(str,i,i), 13, 16+i*10, col)
	  end
	 end
	elseif state == 3 then
	 if mode != 3 then
		 for i=1,#boss[1] do
		  by = boss_y+i*cell
		  for j=1,#boss do
		   bx = boss_x+j*cell
		   draw_cell(i,j,bx,by,boss)
		  end
		 end
		end
	 for x=1,box_w do
	  for y=1,box_h do
	   bx = 34+x*cell+bang_box[y][x][2]
	   by = 4+y*cell+bang_box[y][x][3]
	   if (rotated) bx,by=by,bx
	   if (mode != 3 or bang_box[y][x][1]!=15) rectfill(bx,by,bx+cell-1,by+cell-1,bang_box[y][x][1])
	  end
	 end
	elseif state == 4 then
	 draw_box(4,4)
		--rect(0,0,1,128,15)
		--rect(127,0,127,128,15)
  local box_c = box_h/2
  local box_cc = 4+cell*box_c-cell
	 if (box[box_c][box_c] != 15) rect(box_cc-1,box_cc-1,box_cc+cell-1,box_cc+cell-1,2+rnd(4))
  if (box[box_c+1][box_c+1] != 15) rect(box_cc+cell-1,box_cc+cell-1,box_cc+2*cell-1,box_cc+2*cell-1,2+rnd(4))
  draw_fig(4,4)
  if rotated then
   if (box[box_c-1][box_c+1] != 15) rect(box_cc+cell-1,box_cc-cell-1,box_cc+2*cell-1,box_cc-1,2+rnd(4))
   print('Ü   Ü', 98, 2, 9)
		 print(bang_size, 108, 2, 10)
  else
   if (box[box_c+1][box_c-1] != 15) rect(box_cc-cell-1,box_cc+cell-1,box_cc-1,box_cc+2*cell-1,2+rnd(4))
	  print('Ü   Ü', 0, 121, 9)
		 print(bang_size, 10, 121, 10)
	 end
	 print(score, 2, 2, 9)
	 draw_bangs(4,4)
	 for b in all(bullets) do
	  if rotated then
	   circfill(b[2],b[1],2,1+rnd(16))
	  else
	  	circfill(b[1],b[2],2,1+rnd(16))
	  end
	 end
	 local cell,next_f,next_left,next_right = 3,nextfig[1],fig_left_x(next_f),fig_right_x(next_f)
	 for x=1,next_f.m do
	  fx = x*cell+126-next_right*cell
	  for y=1,next_f.m do
	   if next_f[y][x] != 0 then
	    if next_f.spd > 0 then
	    	fy = 2-fig_top_y(next_f)*cell+y*cell
	    else
	     fy = 126-fig_bottom_y(next_f)*cell+y*cell
	    end
	    draw_cell(x,y,fx,fy,next_f,cell)
	   end
	  end
	 end
	elseif state==5 then
	 print("congratulations!", 32, 18, 9)
	 local str = "you are the"
	 for i=1,#str do
	  col=flr(1+i+rnd(3))
	  print(sub(str,i,i), i*10+1, 46, col)
	 end
	 str = "winner"
	 for i=1,#str do
	  if i <= 3 then
	   col=flr(1+rnd(10-5*i))
	  else
	   col=flr(1+rnd(3*i-11))
	  end
	  print(sub(str,i,i), 19+i*12, 64, col)
	 end
	 print("final sc  re", 40, 94, 10)
	 print("Ü", 72, 94, 9)
	 print(score, 64-2*#(""..score), 106 , 1+flr(rnd(15)))
	 drawparticles()
	else
		for y=1,box_h do
	  for x=1,box_w do
	   by = 4+y*cell-cell
	   bx = 4+x*cell-cell
	   local rad = sqrt((60-bx)^2+(64-by)^2)
	   if state == 6 then 
	    rad -= rad*timer/150
	   else
	    rad += rad*timer/75
	   end
	   local ang = atan2(bx-60, by-64)
	   local cell = max(1,cell-cell*timer/150)
	   by = 64+sin(ang+phi)*rad
	   bx = 60+cos(ang+phi)*rad
	   if (rotated) by,bx=bx,by
	   if (box[y][x]!=15) rectfill(bx,by,bx+cell-1,by+cell-1,box[y][x])
	  end
	 end
	end
end

function draw_bangs(xs,ys)
 local bx,by
 for b in all(bang_box) do
  bx = xs+b[1]*cell - cell/2 - 1 + b[4]
  by = ys+b[2]*cell - cell/2 - 1 + b[5]
  if (rotated) bx,by = by,bx
  rectfill(bx,by,bx+1,by+1,b[3])
 end
end

function draw_level_score()
 local score_size, lev_size = 2*#(""..score), 2*#(""..level)
 local col
 if score == hiscore and score>100 then
  col = 11
 else
  col = 10
 end
 if rotated then
 	print('score', 0, 10, 9)
 	print(score, 10-score_size, 18, col)
 	print('level', 108, 10, 9)
 	print(level, 118-lev_size, 18, 10)
 else
 	print('score', 7, 4, 9)
 	print(score, 17-score_size, 12, col)
 	print('level', 7, 119, 9)
 	print(level, 17-lev_size, 111, 10)
 end
end

function draw_box(xs,ys)
 xs = xs or 34
 ys = ys or 4
 local bx,by
 for x=1,box_w do
  for y=1,box_h do
   bx = xs+x*cell-cell
   by = ys+y*cell-cell
   if (rotated) bx,by = by,bx
   if box[y][x]<=0 then
    rectfill(bx,by,bx+cell-1,by+cell-1,1+flr(rnd(14)))
    box[y][x] -= 1
    if (box[y][x] < -30) box[y][x]=cur_colors[1+flr(rnd(#cur_colors))]
   elseif state==1 or box[y][x]!=15 then
    rectfill(bx,by,bx+cell-1,by+cell-1,box[y][x])
   end
   if (box[y][x]!=15) rect(bx-1,by-1,bx+cell-1,by+cell-1,0)
  end
 end
end

function draw_fig(xs,ys,fg)
 xs = xs or 34
 ys = ys or 4
 fg = fg or fig 
 local fx,fy
 for x=1,fg.m do
  fx = xs+fg.x+x*cell-cell
  for y=1,fg.m do
   if fg[y][x] != 0 then
    fy = ys+fg.y+y*cell-cell
    draw_cell(x,y,fx,fy,fg)
   end
  end
 end
end

function draw_cell(x,y,cx,cy,fg,cel)
	cel = cel or cell
	fg = fg or fig
	if (rotated) cx,cy = cy,cx
	rectfill(cx,cy,cx+cel-1,cy+cel-1,fg[y][x])
	rect(cx-1,cy-1,cx+cel-1,cy+cel-1,0)
end

function draw_cur_goal()
  local col
	 col = cur_colors[#cur_colors]
	 if level <= 2 then
	  draw_goal({{15,15,15,15,15},{col,col,col,col,col},{15,15,15,15,15}})
	 elseif level == 3 then
	  draw_goal({{15,col,15,col,15},{col,15,col,15,col},{15,col,15,col,15}})
	 elseif level == 6 or level == 12 then
		 draw_goal({{15,15,15,15,15},{col,cur_colors[2],cur_colors[3],cur_colors[4],cur_colors[5]},{15,15,15,15,15}})
		elseif level == 7 then
		 draw_goal({{15,15,15,15,15},{col,cur_colors[2],col,cur_colors[2],col},{15,15,15,15,15}})
		elseif level == 13 then
		 draw_goal({{15,15,15,15,15},{col,cur_colors[2],cur_colors[3],cur_colors[2],col},{15,15,15,15,15}})
		elseif level == 9 or level == 15 then
		 draw_goal({{col,col,15,col,15},{15,col,col,15,col},{col,col,15,col,15}})
		else
		 draw_goal({{col,col,15,col,15},{15,col,col,col,col},{col,col,15,col,15}})
		end
end

function draw_goal(goal)
 local fx,fy
 if rotated then
	 for y=1,3 do
	  fy = 7+y*4
	  for x=1,5 do
	   fx = 70+x*4
	   draw_cell(x,y,fy,fx,goal,4)
	  end
	 end
 else
	 for y=1,3 do
	  fy = 74+y*4
	  for x=1,5 do
	   fx = 3+x*4
	   draw_cell(x,y,fx,fy,goal,4)
	  end
	 end
	end
end

-- fireworks code from krystman, thanks!
-- http://www.lexaloffle.com/bbs/?tid=28260

function boom(_x,_y)
 -- crate 100 particles at a location
 for i=0,100 do
  spawn_particle(_x,_y)
 end
end

function spawn_particle(_x,_y)
 -- create a new particle
 -- generate a random angle
 -- and speed
 local new, angle, speed = {}, rnd(), 1+rnd(2)
 
 --set start position
 --set start position
 -- set velocity based on
 -- speed and angle
 new.x,new.dx=_x,sin(angle)*speed
 new.y,new.dy=_y,cos(angle)*speed
 
 --add a random starting age
 --to add more variety
 new.age=flr(rnd(25))
 
 --add the particle to the list
 add(particles,new)
end

function updateparticles()
 --iterate trough all particles
 for p in all(particles) do
  --delete old particles
  --or if particle left 
  --the screen 
  if p.age > 80 
   or p.y > 128
   or p.y < 0
   or p.x > 128
   or p.x < 0
   then
   del(particles,p)
  else
  
   --move particle
   p.x+=p.dx
   p.y+=p.dy
   
   --age particle
   p.age+=1
   
   --add gravity
   p.dy+=0.15
  end
 end
end

function drawparticles() 
--iterate trough all particles
 local col
 for p in all(particles) do
  --change color depending on age
  if p.age > 60 then col=8
  elseif p.age > 40 then col=9
  elseif p.age > 20 then col=10  
  else col=7 end
  
  --actually draw particle
  line(p.x,p.y,p.x+p.dx,p.y+p.dy,col)
  
  --you can also draw simpler
  --particles like this
  --pset(p.x,p.y,col)

 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000500001e14510145101451b14509000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000955006550035500355000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000145300f5300a5300a53000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000a5300a5300f5301453000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000564304633036230262301613016030160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00002844228442284422844216442164421644216442074420744207442074420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000097510b7510c7510e751137511c751247513c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000d552000020000216502195521650211552165020b5520f5020b50203502195520350212552135020d5520b5020d5020000203502000020b5520a502145520c502135021650219552000021055219502
011000000955211502065020650203502165020b5520d502145520b5020b50214502105520000213502000020c55212502125020d50207552125020d502045020255200002145020c502025020f5021250212502
00100000125520d5021250212502125021250212552125021a5521a502175020350217552175020e5520e50206552065020650213502135021c50213552135021c5521c502145020b50214552145020d5520d502
0110000006552065020d502000020f5020f5020f55215502155521a5021e502115021155215502000020c5020c552065020b50206502065520a5020250202502025520b5020b5020000214502000020d50200000
011000000d555000050000516505195551650511555165050b5550f5050b50503505195550350512555135050d5550b5050d5050000503505000050b5550a505145550c505135051650519555000051055519502
011000000955511505065050650503505165050b5550d505145550b5050b50514505105550000513504000040c55512505125050d50507555125050d505045050255500002145020c502025020f5021250212502
01100000125550d5051250512505125051250512555125051a5551a505175050350517555175050e5550e50506555065050650513505135051c50513555135051c5551c505145050b50514555145050d5550d502
001000000955511505065050650503505165050b5550d505145550b5050b50514505105550000513505000050c55512505125050d50507555125050d505045050255500004145020c502025020f5021250212502
011000000d554000040000416504195541650411554165040b5540f5040b50403504195540350412554135040d5540b5040d5040000403504000040b5540a504145540c504135041650419554000041055419502
011000000955411504065040650403504165040b5540d504145540b5040b50414504105540000413504000040c55412504125040d50407554125040d504045040255400002145020c502025020f5021250212502
01100000125540d5041250412504125041250412554125041a5541a504175040350417554175040e5540e50406554065040650413504135041c50413554135041c5541c504145040b50414554145040d5540d502
001000000955411504065040650403504165040b5540d504145540b5040b50414504105540000413504000040c55412504125040d50407554125040d504045040255400004145020c502025020f5021250212502
001000000d555000050d555165051955513505115550a5550b5550f5051255503505195550e55512555155550d5550b505085550455506555000050b5550e555145550c5050e555165051955515555105550c555
001000000955511505095050650510555165050b55509555145550b5050b5051450510555000050e5550c5040c55512505055550d505075551250501555045050255500002145020c502025020f5021250212502
00100000125550d50512555085051250512505125550d5551a5551a505175050350517555125550e555095550655506505065550a505135051c505135550e5551c5551c505145050b505145550b5550d5550b555
001000000955511505095550650503505165050b55508555145550b5050b5051450510555000050e555000050c55512505065550d505075551250504555045050255500004145020c502025020f5021250212502
00100000110501305000000000001d0502205000000000001c0501805000000000001b0501c050000000000020050165502150019550185501d55022500225001b550185501b5501c5501f550235001450018550
0004000007760077600b7600f7601376017760177601b7601d76023760257602576023760207001f7002976029760297602976001700177001770024760247602476024760057001d70012760127601276012760
001000001b5521b5521b55219552195521b5521b5521b5521b5521b55219552195521955203502175021b5521e5521f552215021b552195021a55220552205520e5021d5521a55218552155021d5521a55216552
0004000001131031310113112100181021810215102121020f102241021f1021a1020b10211102091020b1020b1020b10209102031020b102091020b1020b1020b1020a1020e1020e10201102111021310213102
000400001015111151111510f1510e151084050b407184070d407095070e5070f50711507125000c5000a5000a5000c50000000000000f50011500115000e5000f50013500095000650006500085000850000000
001000000755008550085500455000000000000b55000000000000b550085500855003550000000750015050135000f500130501505015050095000000008500075500855008550045500b500000000c55000000
00100000000000c550095500955004550000000000013050000001400012050100501005000000000000a50009550075500755004550000000d5000c5500000000000095500c5500c5500e550000000000013050
011000000e0000e0000e05013050130500f0001a00017000170501605016050110001105011050160001605016050180501a0501a0501e05000000135001355010550105500c5500955009550075000000000000
010a0000026630266302663056530565305653096430d64312643186431e64323643286332d633306333463336633386333863339623396233862336623326232e6232a623246131d613156130e6130761301613
00080000086530864308643096430963309633086330762306623056230461303613026130160301603016030160301603116030f6030b60304603276031f6030060200600000000000000000000000000000000
011000000715208152081520415200102001020b15200102001020b152081520815203152001020710215152131020f102131521515215152091020010208100071520815208152041520b102001020c15200102
01100000000000c152091520915204152001000010013152001001410012152101521015210100000000a50009152071520715204152001020d1020c1520010200102091520c1520c1520e152001020020213152
011000000e1020e1020e15213152131520f1021a10217102171521615216152111021115211152161021615216152181521a1521a1521e15200102131021315210152101520c1520915209152075000000000000
00040000090520d0520e0520a0520605201052050520b05210052102020a204052040110400106001040000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001103000000000001103000000000001103000000000000000011030000001103000000120300000011030000000000011030000000000011030000000f0300c0300f0300c03016030140301603014030
000c00003013030130001002c130001000010029130001000010000100001000010000100001001b1301b1301d1301d1300010000100001000010029130001003113031130001000010030130001000010000100
010c00003013030130000002c1300000000000291300000000000000001b1301b1301d1301d1301b1301b1301d1301d1300000000000000000000029130000003113000000301300000031130000003013000000
010c00001103000000000001103000000000001103000000000000000011030000001103000000120300000011030000000000011030000000000011030000000f0300c0300f0300c03016030140301603014035
010c000014030000000000014030000000000014030000000000000000000000000000000000000f0300000013030130300000013030000000000013030130300000000000000000000000000000001403000000
010c00000000000000000000000000000000003013530130311353113030130000002e130000002c130000002e13000000000002c130000000000029130000000000000000000000000000000000000000000000
010c000011030110300000011030000000000011030110300000000000000000000000000000000f0300000011030110300000011030110300000011030110300000000000000000000011030000001303000000
010c00000000000000000000000000000000003013530130311353113030130000002e130000002c130000002e130000000000031130000000000030130301300000000000000000000000000000000000000000
010c00001403000000000001403000000000001403000000000000000014030000001303000000140300000016030000000000016030000000000016030000000000000000160300000000000140301603000000
010c00000000000000000000000000000000003013530130311300000030130000002e130000002c130000002e13000000000000000000000000002e1352e1352e130000002e130000002c130000002e13000000
010c00001803000000000001803000000000001803000000000000000018030000001803000000190300000018030000000000018030000000000018030000000000000000180300000018030000001803000000
010c00003013000000000000000000000000003013530130311300000030130000003113000000301300000035135351300000035130000003513000000351303413034130341303413034130000000000000000
010c00001103511035110351103511030000001103000000000001103000000110351103000000120300000011035110351103511035110300000011030000000000011030000000000011030000000f03000000
010c00001103511035110351103511030000001103000000000001103000000110351103000000120300000011035110351103511035110300000011030000000000011030000001103511030110300f03000000
000c00000000000000241302013024130000002513000000271300000025130000002413000000251302413000000201300000000000000000000000000201302413020130000001d13000000000002013000000
000c00003523000000302300000035230000003823035230000000000000000000000000000000000000000035230000003023000000352300000038230352300000000000302300000035230000003823035230
010c00000000000000241302013024130000002513000000271300000025130000002413000000251302413000000000000000000000000000000000000241302513024130000002513000000000002413000000
010c00000000000000302300000035230000003823035230000000000000000000000000000000000000000035230000003023000000352300000038230352300000000000000000000000000000000000000000
010c00001103511035110351103014030110351103511035110351103014030110351103511030140301103000000100351003000000140300000010030000000000000000100300000014030000001003000000
010c00002913000000291300000000000000003013000000000000000000000000000000000000291300000028130000002813000000000000000028130000003113000000000000000030130000000000000000
010c00000f0350f0350f0350f030140300f0350f0350f0350f0350f030140300f0350f0350f030140300f030000000e0350e0300000014030000000e0300000000000000000e0300000014030000000e03000000
010c00002713000000271300000000000000003013000000000000000000000000000000000000271300000026130000002613000000000000000026130000003113000000000000000030130000000000000000
010c00000d0350d0350d0350d030140300d0350d0350d0350d0350d030140300d0350d0350d030140300d0300c030000000c0300000014030000000c0350c030000000c030000000c03000000140300c03000000
010c00002513000000251300000000000000003013000000000000000000000000000000000000251300000024130000002413000000000000000024130000003113000000000000000030130000002413000000
010c00000d0350d0350d0350d030140300d0350d0350d0350d0350d030140300d0350d0350d030140300d0300f030000000f030000000f030000000f030100300000010030000001003014030000001003000000
010c00002513000000251300000000000000003013000000000000000000000000000000000000251300000027130000002713000000000000000027130000002813000000281300000031130000003013000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 07 42 43 44
00 08 42 43 44
00 09 42 43 44
00 0a 42 43 44
00 0b 42 43 44
00 0c 42 43 44
00 0d 42 43 44
00 0e 42 43 44
00 0f 42 43 44
00 10 42 43 44
00 11 42 43 44
00 12 42 43 44
00 13 42 43 44
00 14 42 43 44
00 15 42 43 44
02 16 42 43 44
01 41 42 43 1c
00 41 42 43 1d
00 41 42 43 1e
00 41 42 43 21
00 41 42 43 22
02 41 42 43 23
01 25 42 43 44
00 25 42 43 44
00 25 42 43 44
00 25 42 43 44
00 25 26 43 44
00 25 27 43 44
00 25 26 43 44
00 28 27 43 44
00 29 2a 43 44
00 2b 2c 43 44
00 2d 2e 43 44
00 2f 30 43 44
00 31 42 43 44
00 32 42 43 44
00 31 42 43 44
00 32 42 43 44
00 31 33 34 44
00 32 35 36 44
00 31 33 34 44
00 32 35 36 44
00 25 26 43 44
00 25 27 43 44
00 25 26 43 44
00 28 27 43 44
00 29 2a 43 44
00 2b 2c 43 44
00 2d 2e 43 44
00 2f 30 43 44
00 37 38 43 44
00 39 3a 43 44
00 3b 3c 43 44
00 3d 3e 43 44
00 37 38 43 44
00 39 3a 43 44
00 3b 3c 43 44
00 3d 3e 43 44
00 31 33 34 44
00 32 35 36 44
00 31 33 34 44
02 32 35 36 44
00 00 00 00 00
00 00 00 00 00
