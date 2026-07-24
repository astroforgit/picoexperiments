pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- hydra
-- andrew krause

-- v1 2/7/16 - 4/4/16
-- v2 9/18/16

-- mute
--function sfx() end
--function music() end

-- constants --
---------------

dungeon_width=5
dungeon_height=4

-- misc routines --
-------------------

function reseed()
 srand(rseed)
 rseed=rnd()
end

function process(f)
 for x=1,w do
  for y=1,h do
   mset(x,y,f(x,y))
  end
 end
end

function set_res(hires)
 poke(0x5f2c,hires and 0 or 2)
 y_res=hires and 128 or 64
 --clip(0,0,128,y_res)
 cls()
 flip()
end

function distance(x1,y1,x2,y2)
 return sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
end

function scramble(a)
 for i=1,#a do
  index1=flr(rnd(#a))+1
  index2=flr(rnd(#a))+1
  local temp=a[index1]
  a[index1]=a[index2]
  a[index2]=temp
 end
end

function center_str(s,y,clr)
 local x=64-#s*2
 print(s,x,y+1,0)
 print(s,x+1,y+1,0)
 color(clr or 7)
 print(s,x,y)
end

function add_message(str)
 message,message_timer=str,60
end

function copy_tile(source)
 for x=0,7 do
  for y=0,7 do
   sset(x,y,sget(x+flr(source%16)*8,y+flr(source/16)*8))
  end
 end
 fset(0,false)
end

-- very, very cinematic
function cutscene(text)
 music(-1,1500)

 fade()
 set_res(true)
          
 center_str(text,60)
 delay(3.5)
 fade()
end

-- transitions --
-----------------

function flash()
 rectfill(0,0,128,64,7)
 delay(0.25)
end

function delay(seconds)
 for i=1,seconds*60 do
  flip()
 end
end

function draw_scan(x1,x2,y)
 if (y<0 or y>127) return
 x1=max(x1,0)
 x2=min(x2,127)
 local ofs1=flr((x1+1)/2)
 local ofs2=flr((x2+1)/2)
 memset(0x6000+y*64+ofs1,0,ofs2-ofs1)
end

function draw_mask(r)
 rectfill(0,0,128,32-flr(r),0)
 rectfill(0,32+r,128,64,0)
 for y=0,flr(r)-1 do
  x=sqrt(r*r-y*y)*2

  draw_scan(0,64-x,32-y)
  draw_scan(64+x,128,32-y)
  draw_scan(0,64-x,32+y)
  draw_scan(64+x,128,32+y)
 end
end

function circle_transition(callback)
 transition_state,transition_radius=1,48
 transition_callback=callback
end

function fade(steps)
 steps=steps or 30
 dpal={0,1,1,2,1,13,13,4,4,9,3,13,1,13,14}
  for i=0,steps do
   for j=1,15 do
    col=j
    for k=1,(i+j%5)/4 do
     col=dpal[col]
    end
    pal(j,col,1)
   end
  flip()
  flip()--added token for 60fps!  
 end
 pal()
 skip_render=true
 message_timer=0
end

-- initialization stuff --
--------------------------

function set_title()
 music(8,0,3)

 title=true
 cursor_pos=0
 y_res=128
 h=32
 w=32
 player={
  x=0,
  y=-200,
  a=0.625
 }

 saved=dget(0)~=0
end

function init_game(continue)
 master_seed=continue and dget(1) or rnd()
 rseed=master_seed
 srand(rseed)
 --printh("master random seed: "..rseed)
 
 dungeons={}
 for i=1,3 do
  dungeons[i]={
   seed=rnd(),
   map=0
  }
 end
 boss_door_opened=false

 title=false
 music(-1,1500)
 sfx(8)
 fade()
 cls()

 print("generating...",5,120,7)
 flip()

 -- clear map
 map_rect(0,0,127,31,0)

 player={
  orb={0,0},
  
  health=100,
  hurt_timer=0,

  frame=1,
  timer=1,

  walkanim={0,32,48,32,16,64,80,64,16},
  attackanim={96,112,96,96,96,96}
 }
 player.anim=player.walkanim

 -- current dungeon, 0=overworld
 dungeon=continue and dget(3) or 0
 orb_placed={false,false}
  
 overworld_seed=rnd()
 gen_overworld()

 if (dungeon>0) then
  w,h=17,17
  enter_dungeon()
  w,h=18,18
 else
  enter_overworld()
 end
 
 fade()
 set_res(false)

 if (continue) then
  player.health=dget(2)
  
  room_x=dget(4)
  room_y=dget(5)
  player.orb[1]=dget(6)
  player.orb[2]=dget(7)
  orb_placed[1]=dget(8)>0
  orb_placed[2]=dget(9)>0
  dungeons[1].map=dget(10)
  dungeons[2].map=dget(11)
  dungeons[3].map=dget(12)

  gen_room(room_x,room_y)
  set_player_at_save_point()
  add_message("dungeon "..dungeon)
 end
end

-- dungeon generation --
------------------------
function map_rect(x1,y1,x2,y2,v)
 for y=y1,y2 do
  for x=x1,x2 do
   mset(x,y,v)
  end
 end
end

function add_door(x,y,s)
 local door={
  x=x,
  y=y
 }
 door.open=distance(x,y,mx,my)<3
 if (s==12 and room_x==3 and room_y==4) door.open=true
 door.s=door.open and s-4 or s
 mset(x,y,door.s)
 add(doors,door)
end

function gen_room(x,y)
 srand(grid[x][y].seed)
 local n=grid[x][y].n
 local s=grid[x][y].s
 local e=grid[x][y].e
 local w=grid[x][y].w
 
 local exits=(n and 1 or 0)+
  (s and 1 or 0) +
  (e and 1 or 0) +
  (w and 1 or 0)

 map_rect(0,0,32,31,0)
 if (n) map_rect(7,1,10,8,16)
 if (e) map_rect(8,7,16,10,16)
 if (s) map_rect(7,8,10,16,16)
 if (w) map_rect(1,7,8,10,16)

 if (exits>1) then
  xs=flr(rnd(5))+2
  ys=flr(rnd(5))+2
 else
  xs=flr(rnd(2))+2
  ys=flr(rnd(2))+2
 end
 map_rect(8-xs,8-ys,8+xs+1,8+ys+1,16)

 -- lava
 if exits>1 and rnd()<=0.75 then
  if xs>=4 and ys>=4 then
   xs=flr(rnd(xs-4))+2
   ys=flr(rnd(ys-4))+2
   if (xs>=2 and ys>=2) map_rect(8-xs,8-ys,8+xs+1,8+ys+1,1)
  end
 end

 local flag=grid[x][y].flag

 -- statue room
 if flag==3 then
  map_rect(0,0,16,16,31)
  map_rect(7,1,10,16,16)
  map_rect(2,3,15,8,16)

  music(1,1000,3)
 end
 
 -- boss annex
 if flag==4 then
  map_rect(0,0,16,16,31)
  map_rect(7,1,10,2,16)
  map_rect(7,15,10,16,16)
  map_rect(2,2,15,15,16)
  map_rect(2,3,7,14,1)
  map_rect(10,3,16,14,1)
  music(-1,1000)
 end
 
 -- boss room
 if flag==5 then
  map_rect(2,2,15,15,16)
  
  map_rect(3,3,14,9,1)
  map_rect(3,3,5,14,1)
  map_rect(12,3,14,14,1)
 end

 march_squares(function(v)
  return v~=16
 end, function(v,nm)
  return not (v==1 and nm==15)
 end,16)

 -- scuff up the floor a bit
 process(function(x,y)
  return (mget(x,y)==16 and rnd()<0.2) and 166 or mget(x,y)
 end)
 
 mx=player.x/8
 my=player.y/8
 
 -- add doors
 doors={}
 if (n) add_door(9,1,10)
 if (e) add_door(17,9,11)
 if (s) add_door(9,17,12)
 if (w) add_door(1,9,13)

 -- add statues
 if flag==3 then
  for ty=0,2 do
   for tx=0,2 do
    mset(4+tx,4+ty,ty*16+138+tx)
    mset(12+tx,4+ty,ty*16+138+tx)
   end
  end
  
  if (orb_placed[1]) mset(5,5,186) mset(5,6,187)
  if (orb_placed[2]) mset(13,5,186) mset(13,6,187)
  
  if (not boss_door_opened) mset(9,1,141)
 end

 -- lock hydra room
 if flag==5 then
  doors={}
  mset(9,17,142)
  sfx(5)
 end 

 set_map_cell(x,y)

 -- save point
 save_point={}
 if flag==1 then
  for ty=0,2 do
   for tx=0,2 do
    mset(8+tx,8+ty,ty*16+tx+131)
   end
  end
  
  save_point={
   x=9,
   y=10,
   used=false,
   active=true,
  }
 end
   
 -- orb
 if (flag==2 and player.orb[dungeon]==0) mset(9,9,151)
 
 -- spawn monsters
 monsters={}
 if exits>1 and (room_x~=3 or room_y~=4) then
  potential={}
  for y=3,13 do
   for x=3,13 do
    if (not fget(mget(x,y),0)) add(potential,{x,y})
   end
  end
  
  if (rnd()<0.2) potential={}
  
  local nmonsters=#potential/16
  if (flag>0) nmonsters=0
  for i=1,nmonsters do
   local index=flr(rnd(#potential))+1
   add(monsters,{
    x=potential[index][1]*8+4,
    y=potential[index][2]*8+4,
    a=rnd(),
    hp=flr(rnd(2))+2,
    hurt_timer=0,
    t=dungeon==1 and 0 or (rnd()<0.3 and 1 or 0)
   })
   del(potential,potential[index])
  end
 end
 
 particles,fireballs={},{}
 
 reseed()
end

function visit(x, y)
 grid[x][y].visited=true
 grid[x][y].seed=rnd()
 
 repeat
  local potential={}
  if (x>1 and not grid[x-1][y].visited) add(potential,{x-1,y})
  if (x<dungeon_width and not grid[x+1][y].visited) add(potential,{x+1,y})
  if (y>1 and not grid[x][y-1].visited) add(potential,{x,y-1})
  if (y<dungeon_height and not grid[x][y+1].visited) add(potential,{x,y+1})

  if #potential>0 then
   local index=flr(rnd(#potential))+1
   nx=potential[index][1]
   ny=potential[index][2]

   if (nx<x) grid[x][y].w=true grid[nx][ny].e=true
   if (nx>x) grid[x][y].e=true grid[nx][ny].w=true
   if (ny<y) grid[x][y].n=true grid[nx][ny].s=true
   if (ny>y) grid[x][y].s=true grid[nx][ny].n=true

   visit(nx,ny)
  end
 until (#potential==0)
end

function gen_dungeon()
 srand(dungeons[dungeon].seed)
 
 repeat
  local ok=true
  
  grid={}
  for x=1,dungeon_width do
   grid[x]={}
   for y=1,dungeon_height do
    grid[x][y]={
     n,s,e,w,visited=false,
     flag=0
    }
   end
  end

  if (dungeon==3) dungeon_width-=1
  visit(flr(rnd(dungeon_width))+1,flr(rnd(dungeon_height))+1)

  -- knock out random walls
  potential={}
  for x=1,dungeon_width-1 do
   for y=1,dungeon_height-1 do
    if (not grid[x][y].s) add(potential,{x,y,0})
    if (not grid[x][y].e) add(potential,{x,y,1})
   end
  end
  
  for i=1,5 do
   index=flr(rnd(#potential))+1
   r=potential[index]
   if r[3]==0 then
    grid[r[1]][r[2]].s=true
    grid[r[1]][r[2]+1].n=true
   else
    grid[r[1]][r[2]].e=true
    grid[r[1]+1][r[2]].w=true
   end
   del(potential,r)
  end
   
  -- door to overworld
  grid[flr(dungeon_width/2)+1]
   [dungeon_height].s=true
  
  -- find dead ends
  potential={}
  for x=1,dungeon_width do
   for y=1,dungeon_height do
    local exits=(grid[x][y].n and 1 or 0)+
     (grid[x][y].s and 1 or 0) +
     (grid[x][y].e and 1 or 0) +
     (grid[x][y].w and 1 or 0)
    
    if (exits==1 and not (dungeon==3 and x==4 and y==4)) add(potential,{x,y})
   end
  end
  
  -- set up boss area
  if dungeon==3 then
   dungeon_width+=1
   grid[4][4].e=true

   grid[5][4].w=true
   grid[5][4].n=true
   
   grid[5][3].s=true
   grid[5][3].n=true
   grid[5][3].flag=3

   grid[5][2].s=true
   grid[5][2].n=true
   grid[5][2].flag=4
   
   grid[5][1].s=true
   grid[5][1].flag=5
  end

  -- regen if not enough dead ends
  if #potential<3 then
   ok=false
  else
   scramble(potential)
   
   grid[potential[1][1]][potential[1][2]].flag=1
   grid[potential[2][1]][potential[2][2]].flag=1
   if (dungeon~=3) grid[potential[3][1]][potential[3][2]].flag=2
  end
 until ok
  
 reseed()
end

-- dungeon map routines
-----------------------

function set_map_cell(x,y)
 local offset=(y-1)*dungeon_width+x-1
 local bit=offset%32-16

 local data=dungeons[dungeon].map
 data=bor(data,bit>=0 and shl(1,bit) or shr(1,abs(bit)))
--[[
we'll never need to clear a map
cell but i'm leaving it here in
case my future self ever needs
to reference it!
 
 if (v>0) then --set
  data=bor(data,bit>=0 and shl(1,bit) or shr(1,abs(bit)))
 else -- clear
  data=band(data,bnot((bit>=0 and shl(1,bit) or shr(1,abs(bit)))))
 end
]]
 dungeons[dungeon].map=data
 
 update_map()
end

function get_map_cell(x,y)
 local offset=(y-1)*dungeon_width+x-1
 local bit=offset%32-16

 local data=dungeons[dungeon].map
 return band(bit>=0 and shr(data,bit) or shl(data,abs(bit)),1)
end

function draw_map_cell(x,y,c)
 for py=1,2 do
  for px=1,3 do
   sset((x-1)*4+px,(y-1)*3+py+64,c)
  end
 end 
end

function update_map()
 for y=0,12 do
  for x=0,20 do
   sset(x,y+64,0)
  end
 end

 for y=1,4 do
  for x=1,5 do
   if get_map_cell(x,y)==1 then
    draw_map_cell(x,y,5)
    local g=grid[x][y]
    if (g.n) sset((x-1)*4+2,(y-1)*3+64,5)
    if (g.e) sset((x-1)*4+4,(y-1)*3+66,5)
    if (g.s) sset((x-1)*4+2,(y-1)*3+67,5)
    if (g.w) sset((x-1)*4,(y-1)*3+66,5)
   else
    draw_map_cell(x,y,1)
   end
  end
 end
 
 draw_map_cell(room_x,room_y,10)
end

-- overworld generation --
--------------------------

function seed_map(prob)
 process(function(x,y)
  return mget(x,y)~=2 and (rnd()<prob and 1 or 0) or 2
 end)
end

function floodfill(x,y,t,r)
 if (mget(x,y)==r) return
 if (mget(x,y)~=t) return
 mset(x,y,r)
 if (x>1) floodfill(x-1,y,t,r)
 if (y>1) floodfill(x,y-1,t,r)
 if (x<w) floodfill(x+1,y,t,r)
 if (y<h) floodfill(x,y+1,t,r)
end

function march_squares(check,canwrite,floor)
 newmap={}
 for x=1,w do
  newmap[x]={}
  for y=1,h do
   local v=0
   if (check(mget(x-1,y))) v+=1
   if (check(mget(x,y))) v+=2
   if (check(mget(x,y-1))) v+=4
   if (check(mget(x-1,y-1))) v+=8
   newmap[x][y]=v
  end
 end

 process(function(x,y)
  return canwrite(mget(x,y),newmap[x][y]) and newmap[x][y]+floor or mget(x,y)
 end)
end

function generation(iterations,f)
 for i=1,iterations do
  newmap={}
  for x=1,w do
   newmap[x]={}
  end
  
  for y=1,h do
   for x=1,w do
    c=0
    
    if (mget(x-1,y-1)==1) c+=1
    if (mget(x,y-1)==1) c+=1
    if (mget(x+1,y-1)==1) c+=1
    if (mget(x-1,y)==1) c+=1
    if (mget(x,y)==1) c+=1
    if (mget(x+1,y)==1) c+=1
    if (mget(x-1,y+1)==1) c+=1
    if (mget(x,y+1)==1) c+=1
    if (mget(x+1,y+1)==1) c+=1
    
    newmap[x][y]=f(c) and 1 or 0
   end
  end
  
  process(function(x,y)
   return (mget(x,y)~=2 and newmap[x][y] or 2)
  end)

  for y=1,h do
   if (mget(1,y)~=2) mset(1,y,1)
   if (mget(w,y)~=2) mset(w,y,1)
  end
  
  for x=1,w do
   if (mget(x,1)~=2) mset(x,1,1)
   if (mget(x,h)~=2) mset(x,h,1)
  end
 end
end

function gen_overworld()
 w=47 --overworld_width-1
 h=30 --overworld_height-1

 repeat
  ok=true
  srand(overworld_seed)

  -- trees
  seed_map(0.37)
  generation(3,function(c) return c>=5 end) 
  trees={}
  process(function(x,y)
   if mget(x,y)>0 and rnd()<0.3 then
    add(trees,{
     x=x*8+rnd(4)+2,
     y=y*8+rnd(4)+2,
     --hflip=rnd()<0.5,
     --vflip=rnd()<0.5,
     scale=rnd()/2+0.75
    })
   end
   return 0
  end)

  -- water
  seed_map(0.35)
  generation(3,function(c) return c>=5 end)
  floodfill(1,1,1,2)
  process(function(x,y)
   return (mget(x,y)==2 and 2 or 0)
  end)
  
  -- mountains
  seed_map(0.45)
  generation(2,function(c) return c>=5 or c<1 end)
  generation(4,function(c) return c>=5 end)

  -- check connectivity
  found=false
  for x=w/2,w do
   if mget(x,h/2)==0 then
    floodfill(x,h/2,0,3)
    found=true
    break
   end
  end
  if (found) then
   -- check enough open space
   c=0
   process(function(x,y)
    if (mget(x,y)==3) c+=1
    return mget(x,y)
   end)
   if (c/(w*h)<0.4) ok=false
   if (c/(w*h)>0.7) ok=false
  else
   ok=false
  end
  
  -- no mountains near shore!
  process(function(x,y)
   if mget(x,y)==1 or mget(x,y)==0 then
    for tx=x-2,x+2 do
     for ty=y-2,y+2 do
      if mget(tx,ty)==2 then
       return 3
      end
     end
    end
   end
   return mget(x,y)
  end)
  
  -- set tiles
  process(function(x,y)
   if (mget(x,y)==2) return 32
   if (mget(x,y)==3) return 48
   if (mget(x,y)==0) return 63
   if (mget(x,y)==1) return 63
  end) 

  march_squares(function(v)
   return v~=32
  end,function(v)
   return v~=63
  end,32)

  march_squares(function(v)
   return v==63
  end,function(v)
   return v>=47
  end,48)

  -- add dungeon entrances
  potential={}
  for x=1,w do
   for y=1,h do
    if mget(x-1,y)==60 and
     mget(x,y)==60 and
     mget(x+1,y)==60 and
     mget(x,y-1)==63 then
    
     add(potential,{x,y})
    end
   end
  end

  for i=1,3 do
   if (#potential<1) then
    ok=false
   else
    index=flr(rnd(#potential))+1
    mset(potential[index][1],potential[index][2],5)
    dungeons[i].x=potential[index][1]
    dungeons[i].y=potential[index][2]
    del(potential,potential[index])
    
    --check entrance distances
    for p in all(potential) do
     if (distance(p[1],p[2],dungeons[i].x,dungeons[i].y)<8) del(potential,p)
    end
   end
  end
  
  if (not ok) overworld_seed=rnd()
 until ok

 w+=1
 h+=1
 for y=1,h do
  mset(1,y,32)
  mset(w,y,32)
 end

 for x=1,w do
  mset(x,1,32)
  mset(x,h,32)
 end
 
 process(function(x,y)
  return mget(x,y)==47 and 48 or mget(x,y)
 end)

 -- no trees on water!
 foreach(trees,function(tree)
  tx=tree.x/8
  ty=tree.y/8
  if mget(tx,ty)~=48 and mget(tx,ty)~=63 then
   del(trees,tree)
  else
   -- or too close to dungeons!
   for i=1,3 do
    if distance(tx,ty,dungeons[i].x,dungeons[i].y)<4 then
     del(trees,tree)
     break
    end
   end
  end
 end)

  -- find most southeastern tile
  done=false
  mx=w
  my=h
  repeat
   if mget(mx,my)==48 then
    player.x=mx*8+4
    player.y=my*8+4
    player.a=-0.185
    done=true
    
    -- don't start under a tree!
    for tree in all(trees) do
     if (distance(mx,my,tree.x/8,tree.y/8)<3) del(trees,tree)
    end
   end
   mx-=1
   my-=1
  until done

 -- random grass
 process(function(x,y)
  return (mget(x,y)==48 and rnd()<0.3) and flr(rnd(2))+3 or mget(x,y)
 end)

 reseed()
end

function start()
 particles,hydra,fireballs={},{}
 set_title() 
 heads_killed,fireball_timer=-1,0
 
 reload(0x0,0x0,0x3100)
 set_res(true)
end

function _init()
 --printh("\n--- cartridge boot ---\n")
 cartdata("net_alienbug_hydra")
 --dset(0,0) -- clear save
 
 -- global timers
 t=0
 message_timer=0

 -- 0=idle,1=fade out,2=fade in
 transition_state=0
 transition_radius=0

 start()
end

function enter_dungeon()
 gen_dungeon()
  
 w,h=18,18

 -- clear overworld stuff
 trees={}
 
 player.x,player.y,player.a=76,132,0

 room_x=flr(dungeon_width/2)+1
 room_y=dungeon_height

 gen_room(room_x,room_y)
 copy_tile(31)
 
 music(-1,3000)
 music(1,3000,3)
 
 add_message("dungeon "..dungeon)
 transition_state,transition_radius=2,0

 update_map()
end

function enter_overworld()
 particles,fireballs,monsters={}

 copy_tile(2)

 fset(0,1,true)
 music(-1,3000)
 music(15,3000,1)
end

-- update routines --
---------------------

function spawn_particles(x,y,num,max_speed,colors,min_age,age_spread,health)
 for i=1,num do
  local angle=rnd()
  local speed=rnd()*max_speed
  add(particles,{
   x=x,
   y=y,
   px=x,
   py=y,
   dx=cos(angle)*speed,
   dy=sin(angle)*speed,
   age=rnd(age_spread)+min_age,
   clr=colors[flr(rnd(#colors))+1],
   health=health
  })
 end
end

function move_and_clip(x,y,dx,dy)
 local close_wall=1.5
 
 mx=flr(x/8)
 my=flr(y/8)
 
 local nx=x+dx
 local ny=y+dy

 -- xvel<0
 nmx=(nx-close_wall)/8
 if (fget(mget(nmx,my),0)) nx=mx*8+close_wall
 
 -- xvel>0
 nmx=(nx+close_wall)/8
 if (fget(mget(nmx,my),0)) nx=(mx+1)*8-close_wall
 
 -- yvel<0
 nmy=(ny-close_wall)/8
 if (fget(mget(mx,nmy),0)) ny=my*8+close_wall
 
 -- yvel>0
 nmy=(ny+close_wall)/8
 if (fget(mget(mx,nmy),0)) ny=(my+1)*8-close_wall

 if not fget(mget(nx/8,ny/8),0) and mget(nx/8,ny/8)>0 then
  return nx,ny
 else
  return x,y
 end
end

function place_orb(x,i1,i2)
 player.orb[i1]=2
 orb_placed[i2]=true
 mset(x,5,186)
 mset(x,6,187)
 delay(0.35)
 sfx(16)
 flash()
end

function set_player_at_save_point()
 player.x=76
 player.y=76
 if (grid[room_x][room_y].s) player.a=0.5
 if (grid[room_x][room_y].e) player.a=0.25
 if (grid[room_x][room_y].n) player.a=0.0
 if (grid[room_x][room_y].w) player.a=0.75

 save_point.used=true
end

function check_hit(entity)
 local a=1.0-atan2(entity.x-player.x,entity.y-player.y)
 local diff=((player.a%1.0+1.0)-a)%1.0
 return abs(diff)<0.5
end

function update_player()
 local speed=1.4

 if player.hurt_timer>0 then
  player.hurt_timer-=1
  if player.hurt_timer<=0 and player.health<=0 then
   cutscene("game over")
   start()
   return
  end
 end

 if (player.health<=0) return
 
 local dx=0
 local dy=0
 
 if btnp(5) then
  player.anim=player.attackanim
  player.timer=0
  player.frame=1
  sfx(1)
 end
 
 if btn(4) then
  if (btn(0)) dx+=sin(player.a+0.25)*speed dy+=cos(player.a+0.25)*speed
  if (btn(1)) dx+=sin(player.a-0.25)*speed dy+=cos(player.a-0.25)*speed
 else
  if (btn(0)) player.a-=0.0125
  if (btn(1)) player.a+=0.0125
 end 
 if (btn(2)) dx-=sin(player.a)*speed dy-=cos(player.a)*speed
 if (btn(3)) dx+=sin(player.a)*speed dy+=cos(player.a)*speed

 -- no strafe running!
 local mag=distance(dx,dy,0,0)
 if (mag>speed) dx=(dx/mag)*speed dy=(dy/mag)*speed

 -- player moves slower when attacking
 if (player.anim==player.attackanim and player.frame<4) dx/=2 dy/=2
 
 -- move and clip
 player.x,player.y=move_and_clip(player.x,player.y,dx,dy)
 
 if player.anim==player.walkanim then
  if dx~=0 or dy~=0 then
   player.timer+=1
   if player.timer>4 then
    player.timer-=4
    player.frame+=1
    -- footstep
    if (player.frame==3 or player.frame==7) sfx(0) 
    
    if (player.frame>#player.anim) player.frame=2
   end
  else
   player.timer=0
   player.frame=1
  end
 end

 if player.anim==player.attackanim then
  player.timer+=1
  if (player.timer>2) player.timer-=2 player.frame+=1
  
  -- check hits
  if player.frame<=3 then
   for monster in all(monsters) do
    if monster.dist<10
     and monster.hurt_timer==0
     and check_hit(monster) then
     
     monster.hurt_timer=15
     monster.hp-=1
     sfx(11)
    end
   end
   
   for fireball in all(fireballs) do
    if fireball.t==2
     and not fireball.deflected
     and distance(fireball.x,fireball.y,player.x,player.y)<10
     and check_hit(fireball) then
     
     fireball.deflected=true
     fireball.dx=-fireball.dx
     fireball.dy=-fireball.dy
    end   
   end
  end
  
  if (player.frame>6) player.anim=player.walkanim
 end
 
 mx=flr(player.x/8)
 my=flr(player.y/8)
 
 -- check dungeon entrance
 if dungeon==0 then
  for i=1,3 do
   if mx==dungeons[i].x and
    my==dungeons[i].y then

    sfx(6)
    music(-1,3000)
    fade()
    cls()
    skip_render=true
    
    dungeon=i   
    enter_dungeon()
   end
  end
 else -- in dungeon
  -- check orb pickup
  if grid[room_x][room_y].flag==2 and
   mx==9 and my==9 and player.orb[dungeon]==0 then
   
   sfx(13)
   flash()
   mset(9,9,16)
   player.orb[dungeon]=1
   add_message("dungeon complete")
  end
  
  -- check orb placement
  if grid[room_x][room_y].flag==3 then
   if mx==5 and my==7 and not orb_placed[1] then
    if player.orb[1]==1 then
     place_orb(5,1,1)
    elseif player.orb[2]==1 then
     place_orb(5,2,1)
    end
   end

   if mx==13 and my==7 and not orb_placed[2] then
    if player.orb[1]==1 then
     place_orb(13,1,2)
    elseif player.orb[2]==1 then
     place_orb(13,2,2)
    end
   end
  end
   
  -- check dungeon doors
  for door in all(doors) do
   if mx==door.x and my==door.y then
    -- west door
    if mx==1 then
     circle_transition(function()
      room_x-=1
      player.x=132
      player.y=76
      player.a=0.75
      gen_room(room_x,room_y)
     end)
    end
    -- east door
    if mx==17 then
     circle_transition(function()
      room_x+=1
      player.x=20
      player.y=76
      player.a=0.25
      gen_room(room_x,room_y)
     end)
    end
    -- north door
    if my==1 then
     if grid[room_x][room_y].flag~=3 or boss_door_opened then
      circle_transition(function()
       room_y-=1
       player.x=76
       player.y=132
       player.a=0.0
       gen_room(room_x,room_y)
      end)
     end
    end
    -- south mouth
    if my==17 and grid[room_x][room_y].flag~=5 then
     if room_y==dungeon_height then
      -- overworld
      music(-1,3000)
      sfx(6)
      fade()
      cls()
     
      gen_overworld()
      enter_overworld()
      player.x=dungeons[dungeon].x*8+4
      player.y=dungeons[dungeon].y*8+8
      player.a=0.4682
      dungeon=0
     else
      circle_transition(function()
       room_y+=1
       player.x=76
       player.y=20
       player.a=0.5
       gen_room(room_x,room_y)
      end)
     end
    end
   end
  end -- doors
  
  -- unlock boss door
  if grid[room_x][room_y].flag==3 and not boss_door_opened then
   if player.y<32 and orb_placed[1] and orb_placed[2] then
    music(-1)
    sfx(17)
    delay(1.75)
    flash()
    mset(16/2+1,1,10)
    boss_door_opened=true
    spawn_particles(76,12,60,5,{0,5,6,7},10,20)
    -- spawn_particles(76,12,100,0.5,{8},7,3,true)
    music(1,1500,3)
    sfx(18)
   end
  end
  
  -- spawn hydra
  if grid[room_x][room_y].flag==5 then
   if player.y<100 and heads_killed==-1 then
    flash()
    sfx(15)
    fade()
    cls()
    delay(0.75)
    sfx(15)
    delay(2.75)
    hydra,heads_killed={},0
    for i=1,3 do
     spawn_head(i)
    end

    fireball_next,fireball_timer,fireball_count=60,0,0
    
    music(12,0,3)
    flash()
   end
  end
 end -- in dungeon
end

function set_head_dest(head,hurt)
 head.tx=head.bx+rnd(10)-5
 head.ty=head.by+rnd(24)-(hurt and 64 or -8)
 local s=hurt and 10 or 30
 head.dx=(head.tx-head.hx)/s
 head.dy=(head.ty-head.hy)/s
end

--[[
 spawns a new hydra head
 
 bx,by body position
 hx,hy head position
 
 set_head_dest returns
  tx,ty target position
  dx,dy delta values
]]
function spawn_head(i)
 local head={
  --bx=i*20+36,
  bx=i*30+16,
  hx=i*30+16,
  by=56,
  seg={},
  hp=3,
  hurt_timer=0,
  frame=0
 }
 head.hy=head.by
 set_head_dest(head)
 add(hydra,head)

-- spawn_particles(head.bx,head.by,30,1.5,{0,2,8,10},40,10)
end

-- t=type: 0=small,1=big,2=deflectable
function spawn_fireball(x,y,t)
 local a=atan2(x-player.x,y-player.y)+0.5
 add(fireballs,{
  x=x,
  y=y,
  dx=cos(a)*1.85,
  dy=sin(a)*1.85,
  t=t,
  deflected=false
 })
 sfx(19)
end

function update_doors()
 for door in all(doors) do
  if door.open then
   if distance(mx,my,door.x,door.y)>2 then
    if door.s~=8 or room_x~=3 or room_y~=4 then
     door.s+=4
     mset(door.x,door.y,door.s)
     door.open=false
     sfx(5)
    end
   end
  else
   if distance(mx,my,door.x,door.y)<1.5 then
    if mget(door.x,door.y)~=141 then
     door.s-=4
     mset(door.x,door.y,door.s)
     door.open=true
     sfx(4)
    end
   end
  end
 end
end

function hurt_player(damage)
 if player.hurt_timer==0 then
  player.health-=damage
  player.hurt_timer=20

  if player.health<=0 then
   -- dead
   music(-1)
   sfx(14)
   player.hurt_timer=80
   player.health=0
   np=30
  else
   sfx(12)
   fade(2)
   np=6
  end

  spawn_particles(player.x,player.y,np,1.5,{6,7},player.health==0 and 60 or 3,7)
 end
end

--[[
function _update()
 _update60()
 _update_buttons()
 _update60()
end
]]

function _update60()
 t+=0.75
 if title then
  if btnp(2) or btnp(3) then
   cursor_pos=1-cursor_pos
   sfx(9)
  end
  if btnp(4) or btnp(5) then
   if cursor_pos==0 then
    init_game(false)
   else
    if saved then
     init_game(true)
    end
   end
  end
  return
 end

 -- circle transition
 if transition_state==1 then
  transition_radius-=2.25
  if transition_radius<=0 then
   --transition_radius=0
   transition_callback()
   transition_state=2
  end
  return
 end
 if transition_state==2 then
  transition_radius+=2.25
  if (transition_radius>48) transition_state=0
  if (transition_radius<24) return
 end

 -- bird sfx
 if (dungeon==0 and rnd()<=0.002) sfx(3)
 
 if (message_timer>0) message_timer-=1

 -- update monsters
 for monster in all(monsters) do
  monster.dist=distance(monster.x,monster.y,player.x,player.y)
  monster.a=atan2(monster.x-player.x,monster.y-player.y)+0.5
  if monster.dist<48 then
   local dx=cos(monster.a)*0.45 --0.65
   local dy=sin(monster.a)*0.45
   if (monster.hurt_timer>0) dx*=-3 dy*=-3
   
   -- mantain separation
   for other in all(monsters) do
    if other~=monster then
     local d=distance(monster.x,monster.y,other.x,other.y)
     if d<8 then
      local a=atan2(monster.x-other.x,monster.y-other.y)+0.5
      dx-=cos(a)*0.35
      dy-=sin(a)*0.35
     end
    end
   end
   
   monster.x,monster.y=move_and_clip(monster.x,monster.y,dx,dy)
   if (monster.t==1 and rnd()<0.007) spawn_fireball(monster.x,monster.y,0)
  end
  if (monster.dist<6) hurt_player(10)
  
  if monster.hurt_timer>0 then
   monster.hurt_timer-=1
   if monster.hurt_timer<=0 then
    if monster.hp<=0 then
     del(monsters,monster)
     spawn_particles(monster.x,monster.y,16,3,monster.t==1 and {0,1} or {0,11},7,3)
     -- random health drop
     if (rnd()<=0.2) spawn_particles(monster.x,monster.y,10,0.75,{8},7,3,true)
    end
   end
  end
 end  
 
 -- update hydra
 for head in all(hydra) do
  if (fireball_timer==15) head.frame=0
  head.hx+=head.dx
  head.hy+=head.dy
  if (distance(head.hx,head.hy,head.tx,head.ty)<5) set_head_dest(head)
  if (distance(head.hx,head.hy,player.x,player.y)<16) hurt_player(20)

  if head.hurt_timer>0 then
   head.hurt_timer-=1
   if head.hurt_timer<=0 then
    if head.hp<=0 then
     spawn_particles(head.hx,head.hy,150,3.5,{3,11},50,25)

     del(hydra,head)
     heads_killed+=1
     sfx(18)
    end
   end
  end
 end

 fireball_timer+=1
 if #hydra>0 and fireball_timer>=fireball_next then
  fireball_timer=0
  fireball_next=rnd()*40+20 --30+15
  local head=flr(rnd()*#hydra)+1
  if hydra[head].hurt_timer==0 then
   fireball_count+=1
   spawn_fireball(hydra[head].hx,hydra[head].hy,fireball_count%8==0 and 2 or 1)
   hydra[head].frame=1
  end
 end
 
 if heads_killed==3 then
  music(-1)
  if #particles==0 then
   _draw()
   sfx(32)
   delay(3)
   cutscene("the end")
   start()
   return
  end
 end
  
 update_player()

 -- update particles
 for particle in all(particles) do
  if particle.age>0 then
   particle.px=particle.x
   particle.py=particle.y
   particle.x+=particle.dx
   particle.y+=particle.dy
   particle.age-=1
  else
   if particle.health then
    local dist=distance(player.x,player.y,particle.x,particle.y)
    if dist<24 then
     local a=atan2(player.x-particle.x,player.y-particle.y)

     particle.px=particle.x
     particle.py=particle.y

     particle.x+=cos(a)/(dist/24)
     particle.y+=sin(a)/(dist/24)
    end
    
    if dist<4 then
     del(particles,particle)
     sfx(10)
     -- increase player health
     if (player.health>0) player.health=min(100,player.health+1)
    end
   else
    del(particles,particle)
   end
  end
 end
 
 -- update fireballs
 for fireball in all(fireballs) do
  fireball.x+=fireball.dx
  fireball.y+=fireball.dy

  if (fget(mget(fireball.x/8,fireball.y/8),2)) del(fireballs,fireball)
  --spawn_particles(fireball.x,fireball.y,16,3,fireball.t==2 and {1,7,12} or {0,8,10},7,3)
  
  -- check collision against player
  if distance(fireball.x,fireball.y,player.x,player.y)<4 then
   hurt_player(5)
   --if (fireball.t==0)
   del(fireballs,fireball)
  end

  -- check collision against
  -- hydra if deflected  
  if fireball.t==2 and fireball.deflected then
   for head in all(hydra) do
    if distance(fireball.x,fireball.y,head.hx,head.hy)<10 then
     head.hurt_timer=30
     set_head_dest(head,true)
     head.hp-=1
     sfx(40)
     del(fireballs,fireball)
    end
   end
  end
 end
  
 if dungeon~=0 then
  update_doors()

  -- update save point  
  if save_point.active then
   if not save_point.used then
    index=(t/4)%3+134
    mset(16/2+1,16/2+1,index)
   end
      
   -- check save point hit
   if save_point.active and not save_point.used then
    if abs(player.x/8-save_point.x)<1 and
     abs(player.y/8-save_point.y)<1 then

     -- save game
     dset(0,1) -- saved
     dset(1,master_seed)
     dset(2,flr(player.health))
     dset(3,dungeon)
     dset(4,room_x)
     dset(5,room_y)
     dset(6,player.orb[1])
     dset(7,player.orb[2])
     dset(8,orb_placed[1] and 1 or 0)
     dset(9,orb_placed[2] and 1 or 0)
     for i=1,3 do
      dset(i+9,dungeons[i].map)
     end
     
     mset(16/2+1,16/2+1,148)
     sfx(7)

     -- play the ocean wave sound to
     -- evoke feelings of nostalgia
     -- in the player's mind, dig?
     sfx(2)
     cutscene("you will be remembered")

     music(1,1500,3)
     set_res(false)

     transition_state=2
     transition_radius=0
     
     set_player_at_save_point()
    end
   end
  end
 end
end

-- rendering routines --
------------------------

function world_to_screen(x,y,finish)
 local vis=true
 local tx=(x-camx)*2
 local ty=(y-camy)*2
 if tx>96 or ty>96 then
  vis=false
  if (not finish) return false
 end
 
 local a=-player.a
  
 local sx=tx*cos(a)+ty*sin(a)
 local sy=tx*sin(a)-ty*cos(a)

 sx=64+sx
 sy=32-sy/2

 return vis,sx,sy
end

function draw_particle(particle)
 local vis1,sx1,sy1=world_to_screen(particle.px,particle.py)
 local vis2,sx2,sy2=world_to_screen(particle.x,particle.y)
 if vis1 and vis2 then
  if (distance(sx1,sy1,sx2,sy2)<64) line(sx1,sy1,sx2,sy2,particle.clr)
  rectfill(sx2,sy2,sx2+2,sy2+1,particle.clr)
 end
end

function render_map()
 local s=sin(1.0-player.a)
 local c=cos(1.0-player.a)

 local x1=(-32*c)-(-32*s)+camx
 local y1=(-32*s)+(-32*c)+camy
 local x2=32*c-(-32*s)+camx
 local y2=32*s+(-32*c)+camy
 local x4=(-32*c)-32*s+camx
 local y4=(-32*s)+32*c+camy
 
 local lxstep=(x4-x1)/64
 local lystep=(y4-y1)/64
 local lxpos=x1
 local lypos=y1
 
 local sxstep=(x2-x1)/64
 local systep=(y2-y1)/64

 local cp=0x6000

 for y=0,y_res-1 do
  local sxpos=lxpos
  local sypos=lypos
  
  for x=0,63 do
   local mx=min(sxpos/8,w)
   local my=min(sypos/8,h)
   local tile=mget(mx,my)
   local tilex=(tile%16)*8
   local tiley=flr(tile/16)*8
   
   if fget(tile,1) then
    -- lava! these numbers are
    -- pretty much arbitrary,
    -- don't go crazy!
    local u=(sxpos/1.8+(sin((t+sxpos)/270)*1.5))%8
    local v=(sypos/1.8+(cos((t+sypos)/130)*2.1))%8
    local clr=sget(u+tilex,v+tiley)
    poke(cp,clr+clr*16)
   else
    local clr=sget(sxpos%8+tilex,sypos%8+tiley)
    poke(cp,clr+clr*16)
   end
   
   cp+=1
   sxpos+=sxstep
   sypos+=systep
  end
  lxpos+=lxstep
  lypos+=lystep
 end
end

function set_flash()
 if (flr(t/3)%2==0) for c=0,15 do pal(c,7) end
end

function reset_pal()
 pal()
 palt(0,false)
 palt(14,true)
end

function _draw()
 if skip_render then
  skip_render=false
  return
 end
 
 reset_pal()
 camx=player.x-sin(player.a)*12
 camy=player.y-cos(player.a)*12

 render_map()

 if title then
  for y=0,31 do
   for x=0,127 do
    local c=mget(x,y)
    if (c~=14) pset(x,y+10,c)
   end
  end
  center_str("   new game",54,7)
  center_str("   continue",66,saved and 7 or 5)
   
  center_str("”ƒ‹‘ move, — to attack,    ",85,6)
  center_str("hold Ž to strafe",93,6)

  center_str("2016 andrew krause",107,5)
  center_str("contact  alienbug.net",115,5)
  sspr(122,0,6,7,51,114)
  sspr(21,64,3,4,46,55+cursor_pos*12)

  if t<=16 then
   rectfill(0,0,64-t*4,127,0)
   rectfill(64+t*4,0,127,127,0)
  end
  return
 end

 -- draw monsters
 for monster in all(monsters) do
  local vis,sx,sy=world_to_screen(monster.x,monster.y)

  local a=(monster.a-0.25+player.a+0.125)%1.0
  local fx=flr(a*4)
  local flp=false
  if (fx>=2) fx-=2 flp=true   
  if (flr(t/9)%2==0) fx+=2
  
  if (monster.t==1) fx+=4

  if (monster.hurt_timer>0) set_flash()
  if (vis) sspr(fx*16,48,16,16,sx-8,sy-8,16,16,flp,flp)
  reset_pal()
 end

 -- draw player
 if (player.hurt_timer>0) set_flash()
 if (player.health>0) sspr(player.anim[player.frame],32,16,16,56,36)
 reset_pal()

 -- draw hydra
 if dungeon==3 and grid[room_x][room_y].flag==5 then
  -- calc screen coords
  for head in all(hydra) do
   vis,head.bsx,head.bsy=world_to_screen(head.bx,head.by,true)
   vis,head.hsx,head.hsy=world_to_screen(head.hx,head.hy,true)
   local nx,ny=head.bsx,head.bsy
   for i=1,7 do
    nx-=(head.bsx-head.hsx)/8
    ny+=(head.hsy-head.bsy)/8
    head.seg[i]={nx+sin((i*7+t)/50)*5,ny}
   end
  end

  -- draw outlines
  for head in all(hydra) do
   for i=1,7 do
    sspr(61,96,12,13,head.seg[i][1]-12,head.seg[i][2]-7,24,13)
   end
  end

  -- draw segments
  for head in all(hydra) do
   if (head.hurt_timer>0) set_flash()
   for i=1,7 do
    sspr(61,112,10,11,head.seg[i][1]-10,head.seg[i][2]-6,20,11)
   end
   reset_pal()
  end
  
  -- draw heads
  for head in all(hydra) do
   if (head.hurt_timer>0) set_flash()
   sspr(head.frame*31,96,31,32,head.hsx-31,head.hsy-16,62,32)
   reset_pal()
  end
 end

 -- draw fireballs
 for fireball in all(fireballs) do
  local vis,sx,sy=world_to_screen(fireball.x,fireball.y)
  if (vis) sspr(104+fireball.t*8,72,8,8,sx-8,sy-4,16,8)
 end
 
 -- draw particles, duh  
 foreach(particles,draw_particle)
 
 -- draw trees
 for tree in all(trees) do
  local vis,sx,sy=world_to_screen(tree.x,tree.y)
  --if (vis) sspr(0,80,16,16,sx-(16*tree.scale),sy-(8*tree.scale),32*tree.scale,16*tree.scale,tree.hflip,tree.vflip)
  if (vis) sspr(0,80,16,16,sx-(16*tree.scale),sy-(8*tree.scale),32*tree.scale,16*tree.scale)
 end  
 
 -- hud stuff
 if (transition_state~=0) draw_mask(transition_radius)

 -- health
 rectfill(3,60,50,61,0)
 if player.health>0 then
  x=player.health/2
  line(3,60,x,60,8)
  line(3,61,x,61,2)
 end

 -- draw compass
 clip(40,0,48,5)
 local ofs=(-player.a*100)%100+62
 for i=1,3 do
  sspr(112,0,4,4,ofs,2)
  line(ofs+4,3,ofs+23,3,7)
  sspr(116,0,4,4,ofs+25,2)
  line(ofs+29,3,ofs+48,3,7)
  sspr(112,4,4,4,ofs+50,2)
  line(ofs+54,3,ofs+73,3,7)
  sspr(116,4,4,4,ofs+75,2)
  line(ofs+79,3,ofs+98,3,7)
  ofs-=100
 end
 clip(0,0,128,y_res)

 -- draw map
 if dungeon==0 then
  rectfill(106,56,124,61,5)
  mx=player.x/8
  my=player.y/8
  mx=mx/w*18+106
  my=my/h*5+56
  pset(mx,my,10)
 else
  sspr(0,64,21,13,105,50)
 end

 -- draw orbs
 rectfill(3,55,7,58,0)
 rectfill(10,55,14,58,0)
 rectfill(4,56,6,57,player.orb[1]==0 and 1 or 10)
 rectfill(11,56,13,57,player.orb[2]==0 and 1 or 10)

 -- draw message
 if message_timer>0 then
  rectfill(0,9,127,17,0)
  center_str(message,11)
 end
end
if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
000011112a82222a1011111033333333333333336555555d000000000511111001000010011111500000000005111110014554100111115077ee777e00e5555e
1000000122888aa81111100133b33333333333335505005511111111111000105100001501000111111111111114441051444415014441117070770000500050
0000011182228888ccc111113bbb333333333b335000000510000001000000101100001101000000145445414444451011451411015444447070777000505050
00011100282228821111111c33b3333333333bb35000000510000001000000101000000101000000144444415411441014451441014455450000000000505550
011000102a822822111ccc113333333333333333500000051000000100000010100000010100000014415441545544101444444101441145e77e7e7e00500000
10000011a82288221cc111c13333333333333333500000051100001100000010100000010100000011415411444445101454454101544444e700777000e5550e
0000000088288a22c111111c333333bb33333333333333335100001511100010111111110100011151444415111444101111111101444111770e777000ee000e
00110010228a22281110cc11333333b333333333333333330100001005111110000000000111115001455410051111100000000001111150000e000000000000
5550d5550000d5555550005500000000056566005550d555056566500565665500665650056656505550d555056656500000000055500055500505555550d555
5550d555555000555500555555555555056550005550d555055566505055665000055650056655505550d555556655055555555555005555555500555550d555
5550d555666650050000666665666656056500060000000005656650650066556000665005665650000000000566005666665666000066666666000000000000
0001000055550500000006665555555500550066dddddd0d05656650550005506600660005555650dddddd0d05500055666656660000066666600005dddddd0d
ddd01ddd660056000560005566656666505055555555550d056555506660000055550505056656505555550d000006665555555505600055550006505555550d
5550d555600056505566005666656666500656665555550d056566506665000066565005056656505555550d500066666566665655660056600066505555550d
5550d555000656505566500555555555550005550000000005556650555500555550005505665550000000005500655555555555556650055005665000000000
5550d55500665650056656500000000055550000ddd0dddd05656650050000550000555505665650ddd0dddd55000055000000000566565005656655ddd0dddd
1011111011111111111111c1111111111c1144331c1143331c1443331c114333334411c1333441c1333411c1333411c133333333333333333333333333333333
11111001c111111111111cc1ccccc1cc11c11443c1443333c1144333c144333334411cc1333441c13333411c3334441c33333333333333333333333335313333
ccc111111c11111111111c111111cc1111cc1143144333331c114433144433333411c111334411c13333441133333441443333333333333333333333333333b3
1111111c1cc111111111c11144411114111cc114144333441c11443314433333411c111133441c11443334413333344144443444333333444333333333333335
111ccc11411cc111111cc114444444441111cc11433333411cc143334433333311cc1111333441c1144333443333334411444441333334411443333333333353
1cc111c14411c11111c111433344433311111cc13333444111c14333333333331cc111113334411c1144333333333333cc111111333344411444333333353531
c111111c44411c111cc11443333333331111111c3333441c1c11443333333333cc1111113334111cc114333333333333c1ccc1cc3334441cc11433333353b333
1110cc1133441cc11c1144333333333311111111333411c11c1443333333333311111111333441c11c114333333333331111cc11333411c11c14433333333335
333333333333333333333333333333333330565d3b55565d3355565d3b55565d665503336655503366555503665555036655565d6655565d6655565d6655565d
35313333333333333333333333bbbbb3333305ddb55665dd3b5565dd355665dd55500333556650335566655355666553556665dd556665dd556665dd556665dd
333333b33333333333333333bb55555b33333555b555556533355565b5555565555033335d5555035d5555505d5555505d5555655d5555655d5555655d555565
33333335bb333333333333bb55555555333330555d5d6665333556655d5d666555003333dd5d5503dd5d6665dd5d6665dd5d5555dd5d6665dd5d6665dd5d6665
333333535533333333333b55566dd65533333300566dd65533355656566dd65600033333566d5503566dd656566dd65655555555566dd655566dd656566dd656
33353531d55b333333333556d5d65dd633333333d5d65d5033355dd6d5d65dd633333333d5d6503305d65dd6d5d65dd655000000d5d65d5055d65dd6d5d65dd6
3353b3335d5b33333333b5565dd65d56333333335dd6555033b55d565dd65d56333333335dd5503305565d565dd65d56003333335dd6555005565d565dd65d56
33333335d6d5b33333bb5665d6d5666533333333d6d555003b556665d6d5666533333333d6d5503330556665d6d5666533333333d6d5550333056665d6d56665
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77cccceeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeecc777cccceeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeecccc7777cccccee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeecccc7777cccce
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeee777eeeeeeeeeeeeeeeeeeeeeeecccc7777ccc
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeee777eeeeeeeeeeeeeeeeeeeeeeeeeccc7777cc
eeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeeee7eeeeee60eeeeeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeee66eeeeeeeeee9a4eeeeeeeeeee449477777e
eeeeee499a4eeeeeeeeeee449a4ee7eeee677e249a4ee7eeeee06e249a4eeeeeeeeeee449a4e776eeeeeee449a4e60eeeee70e249a9eeeeeeeeeee4499467e77
eeee064499a60eeeeeee064499a6077eeee66024999eee7eeee07044999eeeeeeeeeee449a4066eeeeeeee94999070eeee67604449460eeeeeeeee4949a6067e
ee6760294940676eee6760294440676eeeeee6294940667eeeee67494a46eeeeeee660294946eeeeeeeee62444476eeeeeee062946906eeeeeee066a464066ee
eeeeeeeeeeeeeeeeeeee067666760eeeeeeeee677660766eeeeee6644a007eeeee667066776eeeeeeeee70044466eeeeeeeeee766e7606eeee67607666760eee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66eeeeeeeeeeeee67777676eeeeeeeeee66eeeeeeeee67e67776eeeeeeeeeeeeeeee766eeeeee06eeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee70eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee07eeeeeeeeeeeeee7777eeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee60eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee06eeeeeeeeeee6666eeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeee00bb0eeeeeeeee0eeeeeeeeeeee0beee03b30eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
000eeeeeeeeee0eeeeeebbbb003eeeeeb0beeeeeeeeeb00beebbbbbb00eeeeeeeee0e00000eef0eeeeeeeeeeeeeeeeeeeee0eeeee0eeeeeeeeeeeeeeeeeeeeee
0b0b0eeeee00b0b0eeee00b03330eeeebbb00e333e00bbbbee00bb30333eeeeee1f000000110000eeeee00010eeeeeeeeee004fff410f10eeeee0e010eeeeeee
0bbb0e333000bbbbeeee0bb00000eeee0bb00e003300bb00eeebb300000eeeeee01014fff400100eeeef101010eeeeeee1f0104f4000110eeeeef01010eeeeee
00bb0000bb330bb0eeee300b30000eee0003000bb0030000eeee000b330eeeeee001004f40101000eee41000100eeeeee00100000010100eeeee4000101eeeee
e0003b0bb0033000eee030bbbbbb0eeee0003bbbbb033000eee00bbbbb30eeeee00000000100000eeeee00440000eeeee11111111100000eeeee04400000eeee
e0303bbbbb0b3330eee0333bbbb30eeee0303bbbbbbb3330eee33bbbbb30eeeeeee010011100eeeeeeee10ff4400eeeeeee010011100eeeeeeee1ff44000eeee
ee003b33bbbb3000eee030bbbbb30eeeeee00b3330b00000eee003bbb333eeeeeeeee000000eeeeeeeee00440000eeeeeeeeeeeeeeeeeeeeeeee04400100eeee
eee0003000000eeeeeee30033033eeeeeeee00000e00eeeeeeee00033030eeeeeeeeeeeeeeeeeeeeeee011000000eeeeeeeeeeeeeeeeeeeeeeee1100010eeeee
eeeee00eee00eeeeeeeb3333330eeeeeeeeeeeeeeeeeeeeeebbb3333330eeeeeeeeeeeeeeeeeeeeeeeef0100100eeeeeeeeeeeeeeeeeeeeeeeeef100100eeeee
eeeeeeeeeeeeeeeeeee00bb000eeeeeeeeeeeeeeeeeeeeeeee00bb3000eeeeeeeeeeeeeeeeeeeeeeeeeee01000eeeeeeeeeeeeeeeeeeeeeeeeeee0100eeeeeee
eeeeeeeeeeeeeeeeeeebb0003eeeeeeeeeeeeeeeeeeeeeeeeebbb0003eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0000000000000000000007ee5550d5555550d5555550d555006666000077770000cccc005550d5555550d555555055555550d55500000000017dd71000000000
01110111011101110111077e5550d5555550d5555550d55506677660077cc7700cc66cc05550d5555550d551001010001550d555111111115177771500000000
0111011101110111011107005550d5555550d5555550d5556677776677cccc77cc6666cc5550d55555505511015511101150d55517d77d711176671100000000
00000000000000000000000e000660000005500000066000677cc7767cc66cc7c667766c00055000000111dd56666665dd111000177777711776677100000000
011101110111011101110000ddd66dddddd55dddddd66ddd677cc7767cc66cc7c667766cddd55ddd515d66d567777776566dd115177667711777777100000000
0111011101110111011100005550d655656666565560d5556677776677cccc77cc6666cc5550d55551d666d56777777656666d151176671117d77d7100000000
0000000000000000000000005550d56d66000066d650d55506677660077cc7700cc66cc05550d555516666d5677777765d666d15517777151111111100000000
0111011101110111011107775550d5d6000000006d50d555006666000077770000cccc005550d55551d666d56777777656666d15017dd7100000000000000000
0111011101110111011107775550d660001111000660d5555550d5555550d5555550d5555550d555511d666d56777765d666d105eeeeeeeeee2222eeee1111ee
0000000000000000000007775550d56001cccc100650d55555500555555005555550d5555550d5555501dddd11677611d6dd1055ee2222eee228822ee1cccc1e
011101110111011101110eee5550d6001cccccc10060d55555066055550aa0555550d5555550d5555550155d00166101d5511555e228822e228998221c6666c1
011101110111011101110eee000556001cccccc1006550000067760000a77a00000550000005500000051d65100110015dd01000e28aa82e289aa9821c6776c1
000000000000000000000eeeddd556001cccccc100655dddd067760dd0a77a0dddd55dddddd55dddddd511d6d111111d6d115ddde28aa82e289aa9821c6776c1
000000000000000000000eee5550d6001cccccc10060d55555066055550aa0555550d5555550d5555550501dd111111dd100d555e228822e228998221c6666c1
000000000000000000000eee5550d56001cccc100650d55555500555555005555550d5555550d5555550500111666d111100d555ee2222eee228822ee1cccc1e
000000000000000000000eee5550d660001111000660d5555550d5555550d5555550d5555550d555555051d11d6556d11d10d555eeeeeeeeee2222eeee1111ee
eee33b3bbbb3e3ee5550d5555550d5d6000000006d50d55555555555101111100100000100000001555051dd165115656610d555000000000000000000000000
e3bbbbbb33ebbbee555005555550d56d66000066d650d55555505555111110010000011000000110555051665d5115656650d555000000000000000000000000
bbb3ebe3bbbbeb3b550aa0555550d655656666565560d55555505555000111111110000011000000555051dd5d6556656d10d555000000000000000000000000
ebeebbbbbebeebbb00a77a0000066000000550000006600055555550111111100000000100000001000550166566665661055000000000000000000000000000
e3bbeb4bbbbebbe3d0a77a0dddd66dddddd55dddddd66ddd55d55555111000110001110000011100ddd5551666511566d1555ddd000000000000000000000000
bbbeb33beb3bebbb550aa0555550d5555550d5555550d5555550d5551001110101100010011000105550d51d6dd01dddd150d555000000000000000000000000
33bbbebbebbb4bb3555005555550d5555550d5555550d555555055550111111010000001100000015550d511111051111150d555000000000000000000000000
ee3bbbb0b0bbbbeb5550d5555550d5555550d5555550d555555055551110001100011100000000005550d5555550d5555550d555000000000000000000000000
bebbeb0bbbbebb3e00000000006666000077770000cccc00000000000000000111111110000000005677776510a77a0500000000000000000000000000000000
e3bbbbbb03bbbbee0000000006677660077cc7700cc66cc0000000001000011101111000000000001167761150a77a0500000000000000000000000000000000
bbb3ebebbbbbeb3b000000006677776677cccc77cc6666cc00000000110000000011111100000000001661015d0aa06500000000000000000000000000000000
ebeebbbeb4beebbb00000000677cc7767cc66cc7c667766c00000000100000110111110000000000100110016560065600000000000000000000000000000000
3ebeebeebbbbbbe300000000677cc7767cc66cc7c667766c00000000000111101110000100000000d111111d6651156600000000000000000000000000000000
eee3b33bbb3bebbb000000006677776677cccc77cc6666cc00000000011100111000110000000000d111111d6dd01ddd00000000000000000000000000000000
eeebbe3bebbbbb3e0000000006677660077cc7700cc66cc00000000011000001001111100000000011600d111110511100000000000000000000000000000000
ee3e3bbeb3bb3eee00000000006666000077770000cccc00000000000000000011111111000000001d0aa0d15550d55500000000000000000000000000000000
0eeeee000eeeee000eeeee000eeeee0eeeeee000eeeeeeeeeeeee000eeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00eeee030eeee03330eeee030eeee00eeeeee030eeeeeeeeeeeee030eeeeeeee0000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0eeee03300ee03330eee03330eee0eeeeeee03300eeeeeeeeee03330eeeeee000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
000eee033330e0330eeee03b30ee000e00eee033330ee00eeeee03b30ee00e00000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00300e03bb3000330000033b300030000300e03bb3000330000033b3000300000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00330003bbb3303303333bb3303330000330003bbb3303333333bb33033300000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0033303b4bb333333bbbb33030300e00333303b4bb00303300b4330303300000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0330303bb4bbb33bbbb4b30030330e00330303bb4b30b33b0b4b300303300000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0030303b44bbb33bbb44b30330300ee0030303b44bb03330044b30330300e000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0330303b4a44bb3bbb4a430033330ee0330303b4a4430b30b4a430033330e000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0303303b4aa4bb3bbbaa430003030ee0303303b3334b0333b43330003030ee0000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0003033b44a4bbbbbbaa433003000ee00030333333333333333333003000eee0000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0003033bb4a44bbbbaa44b3033000ee00030033bbbbb33333bbb33033000eeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee0003bbb44a4b3bbaa4bb30000eeeeee00033bbb3bbb00bbbbbb30000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee0303bbbb4abb3ba44b3b30030eeeeee0300003bbbb0dddbbbbb03030eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee033033bb44bb3bb4bb3b30330eeeeee03300dd3330000dd3333d0330eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee03003333bbbbb3bbbbb330030eeeeee030200d0dd000000600000230eeeeee3333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee030033333bb3b3bbb3b330030eeeeee030220006600200066d000030eeee333b333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee0330333b33bbbbbb333303030eeeeee0330200006022222600002030eee333333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee00030333bbbbbbb3333303330eeeeee0003220006020022600022330eee33b333bb33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeee0330333bb3bbb33bb3303000eeeeeee03300d006200002600023000eee3bb3b3bbb3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeee00330b00bb3bb3b0bb30300eeeeeeee003300d0622000260062300eeee33b3b3bbb3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeee030bb0bb3bb3b00330300eeeeeeeeee030260220000222200300eeee333b333bb3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee00b3b3b3bb3bbb3030eeeeeeeeeeeee03022200200022d330eeeeee333b333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee0333bb3b33333300eeeeeeeeeeeeeee0300200220226300eeeeeee333333b333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeee033b3333b3330eeeeeeeeeeeeeeeeee03060d0226d30eeeeeeeeee3333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeee0333333333b30eeeeeeeeeeeeeeeeee03300d222d300eeeeeeeeeeee3333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeee0333b33b33b0eeeeeeeeeeeeeeeeeee033000dd0030eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeee03333b33330eeeeeeeeeeeeeeeeeeee03306600630eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeee003333330eeeeeeeeeeeeeeeeeeeeee003333330eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeee033330eeeeeeeeeeeeeeeeeeeeeeeee033330eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__gff__
0303030000000000000000000000000000010101010101010101010101010105030101010101010001010100010000000000000100010101000101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000001010101010000000000000000000000010101010101000000000000000303030101010000000000000000000003030001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e0e0e0e0e0e000000000e0e0e0e0e0e0e0e0e0000000000000000000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e000a0a00000000000000000000000a0a0a0a0a0a0a0a0a0a0000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000a0a09000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e000a090a0a0a0a0a0a0a0a0a0a0a0a04090409090a09090a0a0a00000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000a0a0a0000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e000000090a0a0a0a0a0a09040400000000000000040404090a0a09000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000a0a0a0a09000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0000000a0a0a0a09050000000e0e0e0e0e0000000004040404000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000a0a0a0a0a04000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a0a0405000e0e0e0e0e0e0e0e0e0e0000000505000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000a0a0905000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a040505000e0e0e0e0e0e0e0e0e0e0e0e000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000a0a0905000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a090505000e0e000000000000000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000a0a0904000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a090404000000000a0a0a0a0a0a0a0a0000000e0e0e0e0e0e0e0e0e0e000000000e0e0e0e0e0e0e0e000000000e0e0e0e0e0e0e0e00000000000000000a0a0904000e0e0e0e0e0e000000000e0e000000000000000e0e0e0e0e0e0e0e0e000000000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a090404000a0a0a09090409090a0a0a0a0a0000000e0e0e0e0e0e0000000a0a00000e0e0e0e0e0000000a0a00000e0e0e0e0e0e00000a0a0a0a0a09000a090905000e0e0e0e0000000a0a000000000a0a0a0a0a00000e0e0e0e0e0e0000000a0a0a0a0a0000000e000000000e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e00090a0a0405040909040000000000000404090a0a0a0a00000e0e0e0e00000a0a0a0a0a00000e0e0e00000a0a0a0a0a000e0e0e0e0000000a0a0a0a0a0a0a0a0a0a0905000e0e0e00000a0a0a0a0a00000a0a0a0a0a0904000e0e0e0e0e00000a0a090a0a0a0a0a0a0000000a09000e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a040505050000000e0e0e0e00000004090a0a0a0a00000e0e0e000a090a0a0a0a09000e0e0e000a0a0a0a0a04000e0e0e00000a0a090404040409090a0a0a0405000e0e0e000a0a0a0a0a090a0a0a090904040500000e0e0e0000000a000000040409090a0a0a0a0a0400000e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0904050000000e0e0e0e0e0e0e0e000009090a0a090a00000e0e000000000a0a0904000e0e0e00000009090405000e0e00000a0a0400000000000504090a090405000e0e0e000000090a0a0a0404000009040500000e0e0e00000a0a00000e0000000409090a0a090400000e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a0405000e0e0e0e0e0e0e0e0e0e0e00000a0a0a0a0909000e0e0e0e0e000a090404000e0e0e0e0e0000090405000e00000a0a0400000e0e0e0000000409090405000e0e0e0e0e00000a0a0905000000090500000e0e0e00000a0a04000e0e0e0e0000040409090400000e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a0405000e0e0e0e0e0e0e0e0e0e0e0e00090a0a09090900000e0e0e0e000a0a0905000e0e0e0e0e0e000a04000000000a0a0400000e0e0e0e0e0e00000a0a0405000e0e0e0e0e0e000a0a0905000e000400000e0e0e0e000a0a0900000e0e0e0e0e0000000a0904000e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a0405000e0e0e0e0e0e0e0e0e0e0e0e000a0a0a0a090909000e0e0e0e000a0a0905000e0e0e0e0e00000a04000e000a0a0a04000e0e0e0e0e0e0e0e000a0a0905000e0e0e0e0e0e000a0a0905000e0000000e0e0e0e00000a0a04000e0e0e0e0e0e0e00000a0a04000e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a0405000e0e0e0e0e0e0e0e0e0e0e0e000a0a0a0a090404000e0e0e0e000a0a0905000e0e0e0e0e000a0900000e000a0a0904000e0e0e0e0e0e0e0e000a0a0905000e0e0e0e0e0e00090a0904000e0e0e0e0e0e0e0e000a0a0a04000e0e0e0e0e0e0e000a0a0a04000e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a0405000e0e0e0e0e0e0e0e0e0e0e0e000a0a0a0a040505000e0e0e0e000a0a0905000e0e0e0e00000a04000e0e000a0a090900000e0e0e0e0e0e0e000a0a0905000e0e0e0e0e0e000a0a0904000e0e0e0e0e0e0e0e000a0a0a0900000e0e0e0e0e0e000a0a0a04000e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a090405000e0e0e0e0e0e0e0e0e0e0e0e000a0a0a04050505000e0e0e0e000a0a0904000e0e0e00000a0900000e0e000a0a0a0a0a00000e0e0e0e0e0e000a0a0905000e0e0e0e0e0e000a0a0404000e0e0e0e0e0e0e0e000a0a0a0a0a00000e0e0e0e0e000a0a0904000e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a0405000e0e0e0e0e0e0e0e0e0e0e0e000a0a0a05050505000e0e0e0e000a0a0a0400000e00000a0900000e0e0e000a0a0a0a0a0a0000000e0e0e00000a0a0904000e0e0e0e0e0e000a0a0904000e0e0e0e0e0e0e0e000a0a0a0a0a0a00000e0e0e0e000a0a0904000e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a0405000e0e0e0e0e0e0e0e0e0e0e0e000a0a0905050505000e0e0e0e000a0a0a0a0a0000000a0a00000e0e0e0e000a09090a0a0a0a0a00000000000a0a0a0404000e0e0e0e0e0e000a0a0904000e0e0e0e0e0e0e0e00000a0a0a0a0a0a00000e0e0000090a0a0900000e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e000a0a0a0405000e0e0e0e0e0e0e0e0e0e0e0e000a0a0405050000000e0e0e0e000a0a090a0a0a000a0904000e0e0e0e0e0000040404090a0a0a0a0a0a0a0a0a0a090904000e0e0e0e0e0e000a0a0905000e0e0e0e0e0e0e0e0e00090909090a0a0a000000000a0a0a0a090a0000000e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e00000a0a09040400000e0e0e0e0e0e0e0e0e0e0e00000a040500000e0e0e0e0e0e0000040404090a0a090400000e0e0e0e0e0e000005040409090a0a0a0a0904090a09040400000e0e0e0e0e000a090404000e0e0e0e0e0e0e0e0e0000040404040a090a0a0a0a0909090409090a0a00000e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e000a0a0405050404000e0e0e0e0e0e0e0e0e0e0e0e000909090000000e0e0e0e0e0e000004040409040500000e0e0e0e0e0e0e0e000000040404040404050500000404040404000e0e0e0e00000a04050400000e0e0e0e0e0e0e0e0e0000050504040404040400000004040505050004000e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0009040505050505000e0e0e0e0e0e0e0e0e0e0e0e00000409090a000e0e0e0e0e0e0e00000004040500000e0e0e0e0e0e0e0e0e0e0e00000505050505000000000405050505000e0e0e0e000a0400000404000e0e0e0e0e0e0e0e0e0e000000050505050000000e0000050500000000000e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0000000000000000000e0e0e0e0e0e0e0e0e0e0e0e0e0000000404000e0e0e0e0e0e0e0e0e00000905000e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000e0e000000000000000e0e0e0e00000000000000000e0e0e0e0e0e0e0e0e0e0e0e0000000000000e0e0e0e000000000e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000e0e0e0e0e0e0e0e00000a0a00000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000a0a0a00000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000a090a0a0000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00090404040909000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000405000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e
__sfx__
000100000d64010630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000b620206302e640366403f6503965035650326402e6402a64026640226401d640196401764015630126300f6300d6200c6200b6200a62009620086200762007610066100661004610046100261001610
001400000762108621096210d621106211362116621186211a6211c6211e6211f6211f6212062120621206211f6211f6211e6211d6211b62119621176211662114621126210f6210d6210b6210a6210862108621
000d00003f724016023f723016023f723026020260202602026020260203602046020660206602046020260202605046020360203602026020160201604016020160201602016020160238602046020160214602
00030000106530b3530c3530e35312353173531c35320353243532b6530c05332603226030c003256032460321603206031e6033f6031c603066033d6032a603076031c6033f6030960300003386030000309603
000300003f650000000b650000002a6500000021650000000b6500000036650000000965000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002c640296201d6001e6301b62000000116000f6200d6200f6000e600086200762007600086000760000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000a471144711e4712e4710b46115461204612e4610c45116451204512d4410d44118451204412b4210c42118421214110d411194111e4110b4110f4111341118411000010000100001000010000100001
0006000015573215732d57315563215632d56315553215532d55315543215432d54315533215332d53315523215232d52315523215232d52315513215132d51315513215132d5130050300503005030050300503
000800000d57318563205530000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
000500001255121541305310050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501
0002000004323073530b3730f373143431632315343173531a3732337333353393433e323333132531315313103730c3730737301373013730030300303003030030300303003030030300303003030030300303
000100002e2702a2602926028260252602326021260202601e2601c26019260182601526012250112500e2500c2500a2500925008250062500423004230032200222001210000100000000000000000000000000
000600000f7612576130761397610f7611976125761397610f7612576130761397610f76118761257612575125741257412574125731257312573100701007010070100701007010070100701007010070100701
00060000245612a561255611f5611a5611556128551215511c55116551115510d551215511c55116551125510d551155611b56117561135510e54116541115412054118541135310f521095210f5210952107501
0004000006223076330b2431065317263206732a27331673332733467332273316732e2732c6732827326673212731b6631826314663122530e6530c2430b6430924308643072330563304233036330323302633
001000000b7620e7621176214762177621a7621a7621a7521a7521a7421a7421a7321a7221a712007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702
00100000177621a7621d762207622376226762297622c7522c7522c7422c7422c7322c7222c712007020070234600296001c6030c603296031c6030c6031c6030c603056030c6030560303603016030d60208602
000e00003e670336702366314663296531a6530c6431a6430c633066330c623066230461303613026130161300000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000072400f2500c2501e250122502e250172601b26023260252601427024270222701f2701d27026270132700e2700b27017270092700826005260032500225002240022400023000230002200020000200
001400081c3342132424334283342d3242833424324213241c3041c3042130424304243041c304213040030400304003040030400304003040030400304003040030400304003040030400304003040030400304
011400081c344283342b334283342f3342b334283342b334003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304
001400081a334263342a334263342d3341f3342a33426334003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304
001400200453204532045320453204532045320453204532045320453204532045320453204532045320453202532025320253202532025320253202532025320253202532025320253202532025320253202532
001400100952209522095220952209522095220752207522025220252202522025220252202522025220252202502025020050200502005020050200502005020050200502005020050200502005020050200502
001000001c5621c5521c5421c5321c5321c5121c5121c5121c5121c5151c5001c5021c5021c5021c5021c5021c5021c5020050200502005020050200502005020050200502005020050200502005020050200502
011e00200147501465014550145504455044550345503455064550645506455064550645506455064630646301475014650145501455044550445503455034550645506455064550645505455054550546305463
001e002031640276301c62017610136100f6100a610056103e6202f620176100561002620056200b630116203d630306201e610166100f6100c6100861003610316302e620196101161003610026100100000000
0012002025765257242474524724217452172420745207241e7451e7241c7451c7241b7451b724197451972419765197241b7451b7241c7451c7241e7451e7242074520724217452172424745247242574525724
001200200174001720037200372004720047200672006720087200872009720097200c7200c7200d7200d7200d7400d7200c7200c720097200972008720087200672006720047200472003720037200172001720
001000001956525555195452553519535255251952525525195252552519525255251952525525195152551519515255151951525515195150050500505005050050500505005050050500505005050050500505
001e00000847508465084550845506455064550645506455094550945509455094550945509455094630946308475084650845508455064550645506455064550945509455094550945508455084550846308463
000a00000e5700b57007570105700c57009570125700e5700b57013570105700c57015570125700e570175701357010570133721f3722b3722b3722b302133001f373133001f3731f3732b3722b3722b3772b375
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000072730b27313273182731e273242732a273312733c273342733c2733b2733c2733b2733c2733b2733c2733b2733c27337273312732227310273062730227300003000030000300003000030000300003
00060000025720e5721a572265722f5722f5722f5721a572265722f5722f5722f5721a572265722f5722f5722f572265720050212572125721250212572125721250212572125720050223572235720050200502
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 14 17 43 44
01 14 17 43 44
00 16 18 43 44
00 14 42 43 44
00 15 18 43 44
00 17 19 43 44
02 17 42 43 44
01 1c 1d 43 44
00 1c 1d 43 44
00 1e 1d 43 44
02 1d 42 43 44
01 1a 1b 43 44
00 1a 1b 43 44
02 1f 1b 43 44
03 02 42 43 44
00 0a 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 14 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
