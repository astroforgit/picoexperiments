pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--init
function _init()
 dirx={-1,1,0,0}
 diry={0,0,-1,1}
 start_game()
 music(0,2000)
end

function start_game()
 gameover=false
 g_t=0
 b_t=0
 debug={}
 ents={}

 player=make_ent(1,32,32)
 player.floor=1
 player.level=1
 player.vis_dist=7
 player.items={}
 player.weapon={}
 player.armor={}

 items={}
 lmap=make_lmap()
 
 messages={}
 post_msg("welcome to the dungeon.",13)
 post_msg("you seek the infamous orb of")
 post_msg("elad. find it in the dungeon's")
 post_msg("deepest floor or die trying!")

 menus={}
 menu(8,7,15,5,"",{"inventory","map"},1)
 do_menus=false
 select=1

 showmap=false
-- showdistmap=false

 cursx,cursy=7,7
 showcurs=false

 _upd=update_startmenu
 _drw=draw_startmenu
end

-->8
--update
function _update()
 g_t+=1
 if g_t>20 then
  b_t+=1
  g_t=0
 end
-- debug[1]=player.x..","..player.y
 _upd()
 if gameover then
  _upd=start_over
 end
end

function update_manual()
 for j=0,5 do
  if btnp(j) then
   select+=1
  end
 end
 if select>#manual then
  select=1
  _upd=update_startmenu
  _drw=draw_startmenu
 end
end

function update_startmenu()
 if btnp(2) then --up
  if select>1 then
   select-=1
  else
   select=2
  end
 end
 if btnp(3) then --down
  if select< 2 then
   select+=1
  else
   select=1
  end 
 end
 if btnp(5) then
  if select==1 then
   _upd=update_game
   _drw=draw_game
  elseif select==2 then
   select=1
   _upd=update_manual
   _drw=draw_manual
  end
 end

end

function start_over()
 if btnp(5) then
  start_game()
 end
end

function ai_turn()
 do_dist_map(player.x,player.y) 
 for e in all(ents) do
  if e != player and 
   dist(player.x,player.y,e.x,e.y)<=player.vis_dist+2 then
--    los(player.x,player.y,e.x,e.y) then
   do_ai(e)
  end
 end
 _upd=update_game
end

function do_ai(e)
 local dx,dy,lowest=0,0,99
 for j=1,4 do
  if dmap[e.x+dirx[j]][e.y+diry[j]].d <=lowest then
   lowest=dmap[e.x+dirx[j]][e.y+diry[j]].d
   dx,dy=dirx[j],diry[j]
  end
 end
 if lowest<99 then
  move_ent(e,dx,dy)
 end
end

function update_target()
 for j=0,3 do
  if btnp(j) then
   move_curs(dirx[j+1],diry[j+1])
  end
 end
 if btnp(4) then
  showcurs=false
  _upd=update_game
 end
 if btnp(5) then
  if player.mp>=player.weapon.z then
   player.mp-=player.weapon.z
   for e in all(ents) do
    if e.x==cursx+player.x-7 and
       e.y==cursy+player.y-7 and
       e != player then
     zap(player,e)
    end   
   end
   showcurs=false
   _upd=ai_turn
  end
 end
end

function move_curs(dx,dy)
 if los(player.x,player.y,(cursx+player.x-7+dx),(cursy+player.y-7+dy),"checkmobs") and
    dist(player.x,player.y,(cursx+player.x-7+dx),(cursy+player.y-7+dy)) <= player.vis_dist then
  cursx+=dx
  cursy+=dy
 end
end

function update_map()
 for j=0,3 do
  if btnp(j) then
   move_map(dirx[j+1],diry[j+1])
  end
 end
 if btnp(4) then
  showmap=false
  _upd=update_game
  do_menus=false
 end
end

function move_map(dx,dy)
 mx+=dx
 my+=dy
end

function update_menu()
 if btnp(2) then --up
  if select>1 then
   select-=1
  else
   select=#menus[#menus].o
  end
 end
 if btnp(3) then --down
  if select< #menus[#menus].o then
   select+=1
  else
   select=1
  end 
 end
 if btnp(4) then --cancel
  while #menus>1 do
   del(menus,menus[#menus])
  end
  do_menus=false
  _upd=update_game	
 end
 if btnp(5) then --selects:
  --select,main menu
  if menus[#menus].a==1 then
   if select == 1 then
    local ilist={}
    for i in all(player.items) do
     add(ilist,i.n)
    end
    menu(3,1,25,17,"",ilist,2)
   elseif select == 2 then
    showmap=true
    mx,my=player.x,player.y
     _upd=update_map
   end
  --select,inventory menu
  elseif menus[#menus].a==2 then
   if #player.items > 0 then
    s_item=select
    select=1
    
    local use_word="use"
    if player.items[s_item].t==")" or
       player.items[s_item].t=="/" then
     use_word="wield"
    elseif player.items[s_item].t=="[" then
     use_word="wear"
    elseif player.items[s_item].t=="!" then
     use_word="drink"  
    end
    menu(8,7,16,5,"",{use_word,"drop"},3)
   end
  --select,item menu
  elseif menus[#menus].a==3 then
   if select==1 and #player.items<14 then
    --use/equip stuff
    if player.items[s_item].t==")" or 
       player.items[s_item].t=="/" then
     player.weapon=player.items[s_item]
     post_msg("wielded the "..player.weapon.n)
    end
    if player.items[s_item].t=="[" then
     player.armor=player.items[s_item]
     post_msg("put on the "..player.armor.n)
    end
    if player.items[s_item].t=="!" then
     sfx(23)
     --healing potion
     if player.items[s_item].n=="health potion" then
      local heal=flr(player.hp_max*.67)
      player.hp+=heal
      if player.hp>=player.hp_max then
       player.hp=player.hp_max
      end
     end
     --magic potion
     if player.items[s_item].n=="magic potion" then
      local magic=flr(player.mp_max*.67)
      player.mp+=magic
      if player.mp>=player.mp_max then
       player.mp=player.mp_max
      end
     end

     post_msg("drank the "..player.items[s_item].n,player.items[s_item].c)
     del(player.items,player.items[s_item])
    end
   elseif select==2 then
    --drop item
    if player.items[s_item]==player.weapon then
     player.weapon={}
    end
    if player.items[s_item]==player.armor then
     player.armor={}
    end
    post_msg("dropped the "..player.items[s_item].n)
    del(player.items,player.items[s_item])
    sfx(24)
   end
   while #menus>1 do
    del(menus,menus[#menus])
   end
   do_menus=false
   _upd=update_game	
  end
 end
end

function update_game()
 do_vis_ents()
 do_vis_items()
 do_auto_pickup()
 check_level()
 check_stairs()
 get_input()
end

function check_stairs()
 if lmap[player.x][player.y].t==">" then
  player.floor+=1
  lmap=make_lmap(player.floor)  
  player.x,player.y=32,32
  post_msg("descended to floor "..player.floor,13)
 end
end

function check_level()
 if player.xp >= 2^(player.level+3) then
  level_up()
 end
end

function level_up()
 player.level+=1
 post_msg("reached level "..player.level.."!",11)
 for j=1,3 do
  local r=rnd(99)+1
  if r < 34 then
   player.st+=1
  elseif r < 67 then
   player.dx+=1
  else
   player.int+=1 
  end
 end
 player.hp_max+=flr(rnd(3)+1)
 player.mp_max+=flr(rnd(2)+1)
end

function do_auto_pickup()
 for i in all(items) do
  if i.x==player.x and i.y==player.y then
   if i.t=="$" then
    player.gold+=i.q
    post_msg("gained "..i.q.." gold")
    del(items,i)
    sfx(21)
   else
    if #player.items<14 then
     sfx(22)
     add(player.items,i)
     if is_vowel(i.n) then
      post_msg("got an "..i.n)
     else
      post_msg("got a "..i.n)
     end
     del(items,i)
    end
   end
  end
 end
end

function do_vis_ents()
 vis_ents={}
 for e in all(ents) do
  if los(player.x,player.y,e.x,e.y) and 
     dist(player.x,player.y,e.x,e.y) <=player.vis_dist and
     player != e then
   if not e.s then
    if intable({"a"},sub(e.n,1,1)) then
     post_msg("an "..e.n.." draws near!",14)
      else
     post_msg("a "..e.n.." draws near!",14)
    end
   end
    add(vis_ents,e)
   e.s=true
  end
 end
end

function do_vis_items()
 vis_items={}
 for i in all(items) do
  if los(player.x,player.y,i.x,i.y) and 
     dist(player.x,player.y,i.x,i.y) <=player.vis_dist and
     player != i then
   if not i.s then
    if i.q and i.q <= 1 then
     if is_vowel(i.n) then
      post_msg("found an "..i.n)
     else
      post_msg("found a "..i.n)
     end
    else
     post_msg("found "..i.q.." "..i.n)
    end
   end
   add(vis_items,i)
   i.s=true
  end
 end
end

function get_input()
 for j=0,3 do
  if btnp(j) then
   move_ent(player,dirx[j+1],diry[j+1])
   _upd=ai_turn
  end
 end
 if btnp(4) then
  select=1
  do_menus=true
  _upd=update_menu
 end
 if btnp(5) then
  if player.weapon.t=="/" and 
     player.mp>=player.weapon.z then
   cursx,cursy=7,7
   showcurs=true
   _upd=update_target
  end
 end
end 

function win_game()
 post_msg("power surges through you as you",12)
 post_msg("grasp the infamous orb of elad",12)
 post_msg("victory is yours!",11)
end
-->8
--draw
function _draw()
 cls()
 _drw()
 print_debug()
end

function draw_manual()
 color(select+10)
-- color(13)
 for j in all(manual[select]) do
  print(j)
 end
end

function draw_startmenu()
 cls()
 color(1)
 print("\n################################")
 color(11)
 print("    ___ ___  __  __     ____ ")
 print("    |  \\|__)/  \\/ _`|  ||__  ")
 print("    |__/|  \\\\__/\\__>\\__/|___ ")
 color(12)
 print("\n    old school dungeon crawl")
 color(1)
 print("\n################################")
 print("\n")
 color(7)
 print("          start game\n")
 print("          instructions\n")
 print("")
 print("\n")
 color(13)
 print("  copyleft 2019 dale w. morris  ")
 color(14)
 print("         dalesworld.ga")
 if b_t % 2==0 then
  drchr(9,11+(select-1)*2,">",7)
 end

end

function draw_game()
 draw_bg()
 draw_items()
 draw_ents()
 if showcurs then
  draw_curs(cursx,cursy)
 end
 draw_bottom()
 draw_sidebar()
 if do_menus then
  draw_menus()
 end
 if showmap then
  show_map()
 end
 if showdistmap then
  show_dist_map()
 end
end

function draw_curs(x,y)
 if b_t % 2==0 then
  drawline(7,7,x,y,6)
  rectfill(x*4,y*6,x*4+3,y*6+5,player.weapon.c)
 end
end

function drawline(x,y,x2,y2,c)
	dx=abs(x2-x)
	dy=abs(y2-y)
	if x<=x2 then sx=1 else sx=-1 end
	if y<=y2 then sy=1 else sy=-1 end
	if dx > dy then
		err=dx/2.0
		while x != x2 do
  rectfill(x*4,y*6,x*4+3,y*6+5,c)
			err-=dy
			if err < 0 then 
				y+=sy
				err+=dx
			end
			x+=sx		
		end
	else
		err=dy/2.0
		while y != y2 do 
   rectfill(x*4,y*6,x*4+3,y*6+5,c)
			err-=dx
			if err < 0 then
				x+=sx
				err+=dy
			end
			y+=sy
		end
	end
end

--function show_dist_map()
-- local dx=7-player.x
-- local dy=7-player.y
-- for j=0,14 do
--  for k=0,14 do
--   if j-dx >= 1 and k-dy >= 1 then     
--   	drchr(j,k,tostr(dmap[j-dx][k-dy].d),
--   	1)
--   end
--  end
-- end
---- draw_ents()
--end

function do_dist_map(ax,ay)
 local cand,step={},0
 dmap=blank_dist_map()
 add(cand,{x=ax,y=ay})
 dmap[ax][ay].d=0
 repeat  
  step+=1
  candnew={}
  for c in all(cand) do
   for d=1,4 do
    local dx=c.x+dirx[d]
    local dy=c.y+diry[d]
    if dmap[dx][dy].d==99 and is_walkable(dx,dy,"checkmobs") then
     dmap[dx][dy].d=step
     if is_inbounds(dx,dy) then    
      add(candnew,{x=dx,y=dy})
     end
    end
   end
  end
  cand=candnew
 until #cand==0
end

function blank_dist_map()
 local d={}
 for j=1,72 do
  add(d,{})
  for k=1,72 do
   add(d[j],{d=99})
    if is_walkable(j,k,"checkmobs") then 
     d[j][k].d=99 
   end
  end
 end
 return d
end

function show_map()
 cls()
 local dx=7-mx
 local dy=7-my
	for j=0,31 do
		for k=0,19 do
   if is_inbounds(j-dx,k-dy) then
--   if j-dx >= 1 and k-dy >= 1 then     
--uncomment this and comment out
--next line to put map in player mode
    if lmap[j-dx][k-dy].s==1 then
--if lmap[j-dx][k-dy].t then
    	drchr(j,k,lmap[j-dx][k-dy].t,
    	1)
    end
   end
		end
 end
end

function draw_menus()
 for m in all(menus) do
  draw_menu(m)
 end
end

function draw_menu(m)
 rectfill(m.x*4,m.y*6,(m.x+m.w)*4+3,(m.y+m.h)*6+5,0)
 for i=m.y,m.y+m.h do
   drchr(m.x,i,"|",7)
   drchr(m.x+m.w,i,"|",7)
 end
 for i=m.x,m.x+m.w do
   drchr(i,m.y,"-",7)
   drchr(i,m.y+m.h,"-",7)
 end
 if m.t != "" then
  cursor(m.x*4+8,m.y*6+6)
  print(m.t)
 end
 cursor(m.x*4+8,m.y*6+6)
 print("")
 for o in all(m.o) do 
  print("  "..o)
 end
 local dy
 if b_t % 2==0 and #m.o > 0 
  and m==menus[#menus] then
  drchr(m.x+3,m.y+2+(select-1),">",7)
 end
end

--’ lots to optimize here
function draw_sidebar()
 cursor(4*15,0)
 color(7)
 print("level "..player.level.."  floor "..player.floor)
 color(13)
 print("xp "..player.xp)
 cursor(4*24,1*6)
 color(10)
 print("$$ "..player.gold)
 cursor(4*15,2*6)
 color(hpcolor(player))
 print("hp "..player.hp.."/"..player.hp_max)
 cursor(4*24,2*6)
 color(mpcolor(player))
 print("mp "..player.mp.."/"..player.mp_max)
 color(7)
 cursor(4*15,3*6)
 print("st "..player.st)
 cursor(4*21,3*6)
 print("dx "..player.dx)
 cursor(4*27,3*6)
 print("in "..player.int)
 cursor(4*15,4*6)
 print("dm "..e_dmg(player)) 
 cursor(4*21,4*6)
 print("ev "..e_ev(player))
 cursor(4*27,4*6)
 print("ac "..e_ac(player))
 cursor(4*15,5*6)
 color(6)
 if player.weapon.n then
  if player.weapon.t=="/" then
   print(player.weapon.n.." [x]")
  else
   print(player.weapon.n) 
  end
 else
  print("bare fists")
 end
 if player.armor.n then
  print(player.armor.n)
 else
  print("clothes")
 end
 draw_enemy_info()
end

function draw_enemy_info()
 local starty=8
 local i=0
 for e in all(vis_ents) do
  if i <=13 then
   local cx=15
   if i >= 6 then
    cx=24
    starty=0
   end 
   drchr(cx,starty+i,"*",hpcolor(e))
   drchr(cx+1,starty+i,e.n,e.c)
--   drchr(cx+1,starty+i,e.t,e.c)   
   i+=1
  end
 end
end

function draw_bottom()
 cursor(0,6*15)
 for i in all(messages) do
  color(i.c)
  print(i.t)
 end
end

function print_debug()
 for j=1,#debug do
  cursor(0,j*6)
  color(8)
  print(debug[j])
 end
end

function draw_ents()
 for e in all(ents) do
  draw_ent(e)
 end
end

function draw_items()
 for i in all(items) do
  draw_ent(i)
 end
end

function draw_ent(e)
 local dx=7-player.x
 local dy=7-player.y
 if los(player.x,player.y,e.x,e.y) or e==player then
  if e.x+dx <=21 and e.y+dy <= 19 then
   if dist(player.x,player.y,e.x,e.y) <=player.vis_dist then
    drchr(e.x+dx,e.y+dy,e.t,e.c)
   end
  end
 end
end

function draw_bg()
 local dx=7-player.x
 local dy=7-player.y
	for j=0,14 do
		for k=0,14 do
   if j-dx >= 1 and k-dy >= 1 then
    if dist(player.x,player.y,j-dx,k-dy) <=player.vis_dist and los(player.x,player.y,j-dx,k-dy) then
     	drchr(j,k,lmap[j-dx][k-dy].t,
     	lmap[j-dx][k-dy].c)
      lmap[j-dx][k-dy].s=1
    else
     if lmap[j-dx][k-dy].s==1 then
     	drchr(j,k,lmap[j-dx][k-dy].t,
     	1)
     end
    end
   end
		end
 end
end

function hpcolor(e)
 local d=e.hp/e.hp_max
 if d>= .67 then
  return 11
 elseif d>= .34 then
  return 10
 else
  return 8
 end 
end

function mpcolor(e)
 local d=e.mp/e.mp_max
 if d>= .67 then
  return 12
 elseif d>= .34 then
  return 13
 else
  return 14
 end 
end

function drchr(x,y,t,c)
 color(0)
 rectfill(x*4,y*6,x*4*#t+3,y*6+5)
 print(t,x*4,y*6,c)
end
-->8
--level map
--map tiles
bgts={".","#","+",">","0"}
bgcs={ 6  ,5 , 4 , 13,12}
bgws={ 1  ,0 , 0 ,  1,0}

--room vars
min_room_size=4
max_room_size=8
max_rooms=32

--placement vars
item_rate=67
is_gold_rate=42
monster_rate=42

function bgtile(t)
 local bgt={}
 bgt.t,bgt.c,bgt.w=bgts[t],bgcs[t],bgws[t]
 return bgt
end

function trig_bump(e,x,y)
 for j in all(ents) do
  if j.x==x and j.y==y then
   melee(e,j)
  end
 end 
 if lmap[x][y].t=="+" then
  lmap[x][y]=bgtile(1)
  sfx(17)
 end
 if lmap[x][y].t=="0" then
  player.x,player.y=x,y
  win_game()
 end
end

function room(x,y,w,h)
 local r={}
 r.x,r.y,r.w,r.h=x,y,w,h
 r.x2=x+w
 r.y2=y+h
 r.cx=flr((r.x+r.x2)/2)
 r.cy=flr((r.y+r.y2)/2)
 return r
end

function dig_room(r,l)
 for j=r.x+1,r.x2 do
  for k=r.y+1,r.y2 do
   if is_inbounds(j,k) then
    l[j][k]=bgtile(1)
   end
  end
 end
end

function add_door(r)
 local z=flr(rnd(4))
 if z==0 then
  x=r.x
  y=flr(rnd(r.h-1))+r.y+1
 elseif z==1 then
  x=r.x2+1 
  y=flr(rnd(r.h-1))+r.y+1  
 elseif z==2 then
  y=r.y
  x=flr(rnd(r.w-1))+r.x+1  
 else 
  y=r.y2+1
  x=flr(rnd(r.w-1))+r.x+1  
 end
 if is_inbounds(x,y) then
  return {x=x,y=y,z=z}
 end
end

function add_room(d)
 local x=0
 local y=0
 local h=flr(rnd(max_room_size-min_room_size)+min_room_size)
 local w=flr(rnd(max_room_size-min_room_size)+min_room_size) 
 if d.z==0 then
  x=d.x-w-1
  y=d.y-flr(h/2)
 elseif d.z==1 then
  x=d.x
  y=d.y-flr(h/2)
 elseif d.z==2 then
  x=d.x-flr(w/2)
  y=d.y-h-1
 else
  x=d.x-flr(w/2)
  y=d.y
 end
 return room(x,y,w,h)
end

function put_door(x,y,l)
 l[x][y]=bgtile(3)
end

function intersect(r1,r2)
 if r1.x<=r2.x2 and r1.x2>=r2.x and
    r1.y<=r2.y2 and r1.y2>=r2.y then
  return true
 else 
  return false
 end
end

function make_lmap()
--create the cells
 local l = {}
 for j=1,72 do
  add(l,{})
  for k=1,72 do
   add(l[j],bgtile(1))
   if k>=1 and k<=64 or j==1 or j==64 then
    l[j][k]=bgtile(2)
   end
  end
 end
--carve out the rooms
 rooms={}
 rooms[1]=room(29,29,6,6)
 
 for j=1,max_rooms do
  local q=false
  local n=flr(rnd(#rooms)+1)
  new_door=add_door(rooms[n])
  if new_door then
   new_room=add_room(new_door)
   for r in all(rooms) do
    if intersect(r,new_room) or hit_wall(new_room) then
     q=true   
    end
   end
   if not q then
    put_door(new_door.x,new_door.y,l)
    add(rooms,new_room)
   end
  end
 end  

 for r in all(rooms) do
  dig_room(r,l)
 end
--place down stairs floor 1-8
 lx,ly=rooms[#rooms].cx,rooms[#rooms].cy
 if player.floor<9 then
  l[lx][ly]=bgtile(4)
 else
--place the orb of elad
  l[lx][ly]=bgtile(5)
 end
--place items
 for r in all(rooms) do
  if r != rooms[1] then
   local cands={}
   if rnd(100)<item_rate then
    if rnd(100)<is_gold_rate then
     item(1,flr(rnd(r.w-1))+r.x+1,flr(rnd(r.h-1))+r.y+1,flr(rnd(player.floor*3)+1))
    else
     local inum=pick_inum()
      item(inum,flr(rnd(r.w-1))+r.x+1,flr(rnd(r.h-1))+r.y+1)
    end
 --  local roll=flr(rnd(6)+1)
 --   item(roll,flr(rnd(r.w-2))+r.x+2,flr(rnd(r.h-2))+r.y+2)
   end
  end
 end
--place monsters
 for r in all(rooms) do
  if r != rooms[1] then
   local enum=pick_enum()
    for j=1,qtys[enum] do
     if rnd(100) < monster_rate then
      make_ent(enum,flr(rnd(r.w-2))+r.x+2,flr(rnd(r.h-2))+r.y+2)   
     end
    end
  end
 end
--------
 return l
end

function pick_inum()
 local cands={}
 for j=2,#inames do
  if ifloors[j][1]<=player.floor and
     ifloors[j][2]>=player.floor then
   add(cands,j)
  end    
 end
 return cands[flr(rnd(#cands)+1)]
end

function hit_wall(r)
 if is_inbounds(r.x,r.y) and
    is_inbounds(r.x,r.y2) and
    is_inbounds(r.x2,r.y) and
    is_inbounds(r.x2,r.y2) then
  return false
 else
  return true
 end
end

function pick_enum()
 return player.floor*2+flr(rnd(2))
end
-->8
--entities
 names={"player","ant","bat","rat","imp","jackal","kobald","goblin","orc","snake","troll","phantom","zombie","mummy","vampire","wraith","lich","dragon","hydra"}
 tiles={ "@",    "a"  , "b" , "r" , "i" ,  "j"   ,  "k"   ,  "g"   , "o" ,  "s"  ,  "t"  ,   "p"   ,   "z"  ,  "m"  ,   "v"   ,   "w"  , "l"  ,  "d"   ,  "h"  }
 colors={ 7 ,     2   ,  13 ,  4  ,  8  ,   9    ,   12   ,   3    ,  6  ,   11  ,    5  ,    6    ,    7   ,   15  ,    8    ,    5   ,  7   ,   14   ,   8   }
 hps={    20,     3   ,  3  ,  6  ,  6  ,   9    ,   9    ,   12   ,  12 ,   15  ,    15 ,    18   ,    18  ,   21  ,    21   ,    24  ,  24  ,   27   ,   30  }
 mps={    10,     0   ,  0  ,  0  ,  0  ,   0    ,   0    ,   0    ,  0  ,   0   ,    0  ,    0    ,    0   ,   0   ,    0    ,    0   ,  0   ,   0    ,   0   }  
 xps={     0,     1   ,  2  ,  3  ,  4  ,   5    ,   6    ,   7    ,  8  ,   9   ,    10 ,    11   ,    12  ,   13  ,    14   ,    15  ,  16  ,   17   ,   18  }
 golds={   0,     0   ,  0  ,  0  ,  0  ,   0    ,   3    ,   5    ,  6  ,   0   ,    9  ,    0    ,    0   ,   0   ,    0    ,    0   ,  0   ,   24   ,   0   }
 sts={     8,     6   ,  6  ,  6  ,  6  ,   9    ,   6    ,   9    ,  9  ,   9   ,    12 ,    12   ,    15  ,   15  ,    15   ,    15  ,  18  ,   21   ,   21  } 
 dxs={     8,     6   ,  6  ,  6  ,  9  ,   9    ,   9    ,   12   ,  12 ,   15  ,    12 ,    15   ,    9   ,   12  ,    15   ,    18  ,  15  ,   15   ,   21  } 
 ins={     8,     1   ,  2  ,  2  ,  4  ,   3    ,   6    ,   8    ,  8  ,   4   ,    6  ,    6    ,    4   ,   5   ,    12   ,    12  ,  12  ,   12   ,   4   }  
 evs={     0,     1   ,  2  ,  1  ,  2  ,   1    ,   2    ,   2    ,  3  ,   3   ,    1  ,    4    ,    1   ,   3   ,    3    ,    4   ,  3   ,   3    ,   4   }  
 acs={     0,     0   ,  0  ,  1  ,  1  ,   1    ,   2    ,   2    ,  2  ,   3   ,    3  ,    0    ,    1   ,   1   ,    2    ,    3   ,  4   ,   5    ,   4   }  
 floors={  0,     1   ,  1  ,  2  ,  2  ,   3    ,   3    ,   4    ,  4  ,   5   ,    5  ,    6    ,    6   ,   7   ,    7    ,    8   ,  8   ,   9    ,   9   }   
 qtys={    1,     3   ,  2  ,  2  ,  2  ,   3    ,   2    ,   3    ,  2  ,   1   ,    1  ,    2    ,    3   ,   2   ,    2    ,    2   ,  2   ,   1    ,   1   }

--effective dx  
function e_dx(e)
 if e==player then
  return player.dx
 else
  return e.dx
 end
end
--effective ev
function e_ev(e)
 if e==player then
  if e.armor.n then
   return max(flr(player.dx/3+e.armor.ev),1)
  else
   return max(flr(player.dx/3),1)
  end
 else
  return e.ev
 end
end
--effective dm
function e_dmg(e)
 if e.weapon.n then
  return flr(e.st/3+e.weapon.d)
 else
  return flr(e.st/3)
 end
end
--effective ac
function e_ac(e)
 if e.armor.t then
  return e.armor.ac+e.ac
 else
  return e.ac
 end
end

function kill_ent(e)
 if e==player then
  post_msg("you are dead",8)
  post_msg("press [x] to continue")  
  gameover=true
 else
  post_msg("the "..e.n.." is slain",13)
  player.xp+=e.xp
  if e.gold>=1 then
   item(1,e.x,e.y,flr(rnd(e.gold)+1))
  end
  del(ents,e)
 end
end

function melee(atk,dfn)
 --max damage ever should be 99
 local to_hit=e_dx(atk)-e_ev(dfn)
 local dmg=flr(rnd(e_dmg(atk))+1)
 dmg-=e_ac(dfn)
 local roll=flr(rnd(e_dx(atk)))+1
 if roll < to_hit and dmg>=1 then
  dfn.hp-=dmg
  if atk==player then
   post_msg("hit the "..dfn.n.." for "..dmg.." damage",13)
   sfx(20)
  else
   post_msg("the "..atk.n.." hits for "..dmg.." damage",14)
   sfx(19)
  end
  if dfn.hp <= 0 then
   kill_ent(dfn)
  end
 else
  if atk==player then
   post_msg("missed the "..dfn.n)
  else
   post_msg("the "..atk.n.." misses")
  end
 end
end

function zap(atk,dfn)
 local dmg=flr(rnd((atk.int/3))+1)
 dfn.hp-=dmg
 if atk==player then
  post_msg("zapped the "..dfn.n.." for "..dmg.." damage",13)
 end
 if dfn.hp <= 0 then
  kill_ent(dfn)
 end
 showcurs=false
 _upd=ai_turn  
end

function make_ent(t,_x,_y)
 local e={x=_x,y=_y}
 e.t=tiles[t]
 e.c=colors[t]
 e.n=names[t]
 e.hp,e.hp_max=hps[t],hps[t]
 e.mp,e.mp_max=mps[t],mps[t]
 e.xp=xps[t]
 e.s=false
 e.xps,e.gold=xps[t],golds[t]
 e.st,e.dx,e.int=sts[t],dxs[t],ins[t]
 e.ev,e.ac=evs[t],acs[t]
 e.f,e.q=floors[t],qtys[t] --floor for monsters
 e.weapon={}
 e.armor={}
 add(ents,e)
 return e
end

function move_ent(e,dx,dy)
 if is_walkable(e.x+dx,e.y+dy,"checkmobs")
  and is_inbounds(e.x+dx,e.y+dy) then
  e.x+=dx
  e.y+=dy
  sfx(16)
 else
  trig_bump(e,e.x+dx,e.y+dy)
 end
end

-->8
--items
inames= {"gold","wooden club","bronze knife","iron knife","bronze sword","iron sword","leather armor","bronze mail","iron mail","bronze plate","iron plate","health potion","magic potion","fire wand"}
itiles= {  "$" ,     ")"     ,     ")"      ,    ")"     ,     ")"      ,    ")"     ,      "["      ,    "["      ,    "["    ,     "["      ,    "["     ,       "!"     ,     "!"      ,     "/"   }
icolors={   10 ,      4      ,      9       ,     6      ,      9       ,     6      ,      4        ,     9       ,     6     ,      9       ,     6      ,       11      ,     12       ,      8    }
idmgs=  {   0  ,      1      ,      2       ,     3      ,      4       ,     5      ,      0        ,     0       ,     0     ,      0       ,     0      ,       0       ,     0        ,      1    }
iacs=   {   0  ,      0      ,      0       ,     0      ,      0       ,     0      ,      1        ,     2       ,     3     ,      4       ,     5      ,       0       ,     0        ,      0    }
ievs=   {   0  ,      0      ,      0       ,     0      ,      0       ,     0      ,     -1        ,    -2       ,    -2     ,     -3       ,    -3      ,       0       ,     0        ,      0    }
izaps=  {   0  ,      0      ,      0       ,     0      ,      0       ,     0      ,      0        ,     0       ,     0     ,      0       ,     0      ,       0       ,     0        ,      1    } 
ifloors={{1,10},    {1,5}    ,    {2,6}     ,   {3,7}    ,    {4,8}     ,   {5,9}    ,    {1,5}      ,   {2,6}     ,   {3,7}   ,    {4,8}     ,   {5,9}    ,     {1,9}     ,   {2,9}      ,    {2,8}  }

-- 123456789
-- ***** 
--  *****
--   *****
--    *****
--     *****

function item(t,x,y,q)
 local i={}
 if q then i.q=q else i.q=1 end
 i.n=inames[t]
 i.c=icolors[t]
 i.t=itiles[t]
 i.d=idmgs[t]
 i.ac=iacs[t]
 i.ev=ievs[t]
 i.z=izaps[t]
 i.f=ifloors[t]
 i.x,i.y=x,y
 i.s=false
 add(items,i)
 return i
end


-->8
--utility

--creates a new menu screen
--t=intro text string
--o=options table of strings
--a=action number for x btn
function menu(x,y,w,h,t,o,a)
 local m={}
 m.x,m.y,m.w,m.h,m.t,m.o,m.a=
  x,y,w,h,t,o,a
 add(menus,m)
end

function is_vowel(s)
 c=sub(s,1,1)
 if intable({"a","e","i","o","u"},c) then
  return true
 else
  return false
 end
end

function intable(tab,elem)
 for j in all(tab) do
  if j==elem then
   return true
  else
   return false
  end
 end
end

function post_msg(t,c)
 local m={}
 if not c then
  m.c=7
 else
  m.c=c
 end
 m.t=t
 if #messages>=5 then
  del(messages,messages[1])
 end
 add(messages,m)
end

function is_inbounds(x,y)
 if x>1 and x<64 and y>1 and y<64 then
  return true
 else
  return false
 end
end

function is_walkable(x,y,mode)
 for e in all(ents) do
  if mode=="checkmobs" then
   if e.x==x and e.y==y then
    return false
   end
  end
 end
 return lmap[x][y].w == 1 
end

function dist(fx,fy,tx,ty)
 local dx,dy=fx-tx,fy-ty
 return sqrt(dx*dx+dy*dy)
end

function los(x1,y1,x2,y2,mode)
 local frst,sx,sy,_dx,_dy=true
 if dist(x1,y1,x2,y2)==1 then return true end
 if x1<x2 then
  sx=1
  dx=x2-x1
 else
  sx=-1
  dx=x1-x2
 end
 if y1<y2 then
  sy=1
  dy=y2-y1
 else
  sy=-1
  dy=y1-y2
 end  
 local err,e2 = dx-dy,nil
 while not(x1==x2 and y1==y2) do
  if not frst and not is_walkable(x1,y1,mode) then 
   return false 
  end
  frst=false
  e2=err+err
  if e2>-dy then
   err=err-dy
   x1=x1+sx
  end
  if e2<dx then
   err=err+dx
   y1=y1+sy
  end   
 end
 return true
end
-->8
--manual+notes

manual={{"1 intro",
" drogue is a minimalistic rogue-",
"like in the style of old-school",
"text-based displays. it uses a",
"32x20 grid of characters to rep-",
"resent all of the walls, floors,",
"monsters, stairs and treasure in",
"a nine floor dungeon. on the 9th",
"floor lies the orb of elad, the",
"ultimate object of your quest.",
"only by retrieving the orb on",
"the final floor can you claim",
"victory.",
"",
"2 stats",
" there are stats in the game",
"that define the player charact-",
"er's abilities. level is a rough",
"measure of all-around \"power\" of",
"a character. at each level hp,"},
{"mp, st, dx and in stats are all",
"raised. level is raised by xp",
"increase. xp is obtained by the",
"killing of monsters. hp measures",
"health, when it reaches 0 you",
"die and the game is over. mp",
"is the ability to cast spells",
"with wands, when it reaches 0",
"you cannot cast. st helps melee",
"damage, dx helps accuracy and",
"dodging, in helps casting. dm is",
"max melee damange, ev is ability",
"to dodge, ac is your capacity to",
"block damage.",
"",
"3 items",
" the items sprinkled throughout",
"the dungeon are classified as",
"armor, weapon, potion and wand.",
"armors boost ac, weapons boost"},
{"dm, potions restore hp or mp,", 
"and wands allow the casting of",
"spells. only one weapon and one",
"armor may be equiped at any",
"given time. gold can be spent",
"at any stores which appear, and",
"unspent gold is worth points",
"when the dungeon run is scored.",
"dropped items are gone forever,",
"so be careful.",
"",
"4 monsters",
" each monster's tile is a letter",
"of the alphabet. each lower",
"floor contains bigger, meaner", 
"and more evil inhabitants.  the",
"monster list on the right shows",
"each ones current hp color:",
"green for healthy, yellow for",
"wounded and red for critical."},
{"",
"5 exploration",
" when you start out, any tiles",
"you haven't yet seen are invis-",
"ible. once you have seen a tile",
"it is added to the game map,",
"which can be accessed on the",
"main menu.",
"",
"6 controls",
" on the main screen, the arrows", 
"move, [o] opens the menu, and",
"[x] aims your wand if you have",
"one. within menus and targeting",
"screens [o] cancels and [x]",
"selects.",
"",
"happy crawling!"}}

--xp table
--
-- new
--level- -xp- ==2^(old_l+3)
--  2     16    
--  3     32    
--  4     64
--  5     128
--  6     256
--  7     512
--  8     1024  
--  9     2048

---item types---
-- gold
-- weapon
-- armor
-- potion
-- wand

--weapons--   [+dmg] c
--wooden club   +1   4
--bronze knife  +2   9
--iron knife    +3   6
--bronze sword  +4   9
--iron sword    +5   6

--armors--    [+ac,-ev] c
--leather armor +1 -1   4
--bronze mail   +2 -2   9
--iron mail     +3 -2   6
--bronze plate  +4 -3   9
--iron plate    +5 -3   6

--potions
--health potion hp += .67*max_hp
--magic potion  mp += .67*max_mp

--wands     mp effect
--fire wand  1 flr(in/3) dmg

--monster table
    --      #  f  c
--a ant     1  1  2  
--b bat     2  1  1  
--r rat     3  2  4  
--i imp     4  2  8  
--j jackal  5  3  9  
--k kobold  6  3  12 
--g goblin  7  4  3
--o orc     8  4  6
--s snake   9  5  11
--t troll   10 5  5
--p phantom 11 6  6
--z zombie  12 6  7
--m mummy   13 7  15
--v vampire 14 7  8
--w wraith  15 8  5
--l lich    16 8  7
--d dragon  17 10 14
--h hydra   28 10 8

--credit to
--krystman
--dcss team
--rogue
--http://roguebasin.roguelikedevelopment.org/index.php?title=dungeon-building_algorithm
--https://github.com/lvictorino/pico8/blob/master/bresenham.p8
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
00010000100501005000000110500b050150500d050180501a0501b05019050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001800000005000050000500005000050000500005000050030500305003050030500305003050030500305008050080500805008050080500805008050080500705007050070500705007050070500705007050
001800000f0500f0500f0500f0500f0500f0500f0500f050130501305013050130501305013050130501305012050120501205012050120501205012050120500f0500f0500f0500f0500e0500e0500e0500e050
001800000f0500f0500f0500f0500f0500f0500f0500f05013050130501305013050130501305013050130501405014050140501405016050160501405014050130501305013050130500c0500c0500c0500c050
001800000061600616006160261600616006160061600616006160061600616006160161601616016160161600616006160261602616026160161600616006160161601616016160161601616016160161601616
001800000f0500f0500f0500f0500f0500f0500f0500f05013050130501305013050130501305013050130501405014050140501405016050160501405014050130501305013050130500e0500e0500e0500e050
001800002405024050240502405024050240502405024050220502205022050220502205022050220502205020050200502005020050200502005020050200501f0501f0501f0501f0501f0501f0501f0501f050
00180000000000000000000000001b0500000000000000001a0500000000000000001605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000011400094000940000000094001f400094000000008400074000717005170021701840008400094000a4000a4000a400000000000000000000000000000000000000000000000
0001000000000000000000000000000000000015150101500f1500a150061500715007150081500b15012150191501f1501c10019100151000000000000000000000000000000000000000000000000000000000
00010000000000000000000000000000000000291002910023300203001c30015300273501f35018350133500f3500f300103000f3000000015100111000b1000910000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000047000670006610086300b6400e6500d6400963007620076000830000000000000000000000000000000000000000000000000000
00010000000000000000000000000000000000000000000000000000001f0501f0501a050150501105011050120500c6000b6000b600000000000000000000000000000000000000000000000000000000000000
000100000000000000150001500015000290002b00034050340503305033050370503d050370503b050330503005031000310003700037000337003b70038700337002c700277003b00000000000000000000000
00010000000000000000000000000000000000000000000000000155001650017500195501b55021550265502a5502e5003150034500000000000000000000000000000000000000000000000000000000000000
00010000190400f04010040100501005010040100400f0500f05011050130601506016060170601806018070180701b05026050290402a0502b0502c0502c0402d0403106032070320002e000000000000000000
00020000000000000000000000000000000000320002e0002b0001300026000230502605018050150500d00011000120000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 01 02 43 44
00 01 03 43 44
00 01 02 43 44
02 01 05 43 44
00 01 02 07 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
