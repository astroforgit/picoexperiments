pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

// room faff. 
// 16 x 16 tiles (8x8)
// screen 128 pixels

// == sounds == //
// 0: door clunk
// 1: hurt
// 2: bump/miss
// 3: pickup
// 4: hit
// 5: critical
// 6: ƒeath
// 7: ship takeoff
// 8: health alarm
// 10: beep
// 11: closebeep

map_size = 16*4
current_map={}
map_frontiers={}
frontier_dir={}
spawn_floors={}
room_count=0
i=0
x=0
y=0
turnanim=0
msgs={}

// station definitions
// 1 - scount station
// 2 - research station
// 3 - military installation
// 4 - solar farm
// 5 - habitat
// 6 - mining colony
map_roomcounts={15,25,40,15,50,20}

// map selection
map_selections={}
show_map_screen=false
selected_map=0
showing_exit_ceremony=false
showing_open_ceremony=false
exit_ceremony_time=0
open_ceremony_time=1

map_names={"scout station",
           "research station",
           "military base",
           "solar farm",
           "habitat",
           "mining colony",
           "stargate"}
map_description={"basic supplies expected",
                 "high medical supplies",
                 "automated defenses, equipment",
                 "many power sources detected",
                 "well stocked with food",
                 "basic supplies expected",
                 "your final destination!"}
fuel_costs={25,75,100,75,50,50,200}
           
random_names={"andromeda","beteljuice","calimari","dominion","enigma","farron","garak","hope","indiana","jackal","klaxon","laureline","maxos","nether","ophelia","picard","quark","rimmer","storm","texas","universe","verse","xenon","yonder","zephyr"}
random_number={"i","ii","iii","iv","v","vi","vii","viii","ix","x"}


sx=map_size/2-16
sy=map_size/2-16

map_has_windows={false,true,false,true,true,true}
wall_vars_h={3,11,13}
wall_vars_v={4,12,14}
wall_vars_h_win={3,11,13,74}
wall_vars_v_win={4,12,14,75}
floors_eng={18,2,17,55}
floors_res={32,33,34,56}
floors_med={48,49,50,57}
floors_han={58,42,41,16}

// == frames
frames_blob={19,20,19,21}
frames_hackwing={22,23,24,23}
frames_turret={25,27,26,27}
frames_grungus={28,29,30,29}
frames_zydd={35,36,37,36}
frames_crate={38,39}
//

actors={}
enemies={}
items={}
crates={}
splats={}
splosions={}
stars={}

shake=0

// == create map selections == //
function generate_new_locations()
 map_selections={}
 
 if level>=9 then
  local typ=7
  local name=map_names[typ]
  local desc=map_description[typ]
  local fuel=fuel_costs[typ]+flr(rnd(25))
  
  local mp={typ=typ,
            name=name,
            desc=desc,
            fuel=fuel,
            name2="utopia"}
  add(map_selections,mp)
  return
 end
 for i=0,3 do
  local typ=flr(rnd(6))+1
  local name=map_names[typ]
  local desc=map_description[typ]
  local fuel=fuel_costs[typ]+flr(rnd(25))
  
  local mp={typ=typ,
            name=name,
            desc=desc,
            fuel=fuel,
            name2=get_random_name()}
  add(map_selections,mp)
 end
end

function get_random_name()
 return rndin(random_names).." "..rndin(random_number)
end

// == utility functions == //

function rndin(list)
 if #list==0 then
  return nil
 end
 return list[flr(rnd(#list))+1]
end

function lineplot(x0,y0,x1,y1,plot)
 local dx=abs(x1-x0)
 local dy=abs(y1-y0)
 x=x0
 y=y0
 local xi0,xi1,yi0,yi1
 if x1>=x0 then
  xi0=1
  xi1=1
 else
  xi0=-1
  xi1=-1
 end
 
 if y1>y0 then
  yi0=1
  yi1=1
 else
  yi0=-1
  yi1=-1
 end
 
 local den  
 local num
 local numadd
 local numpixels
 
 if dx >= dy then
  xi0=0
  yi1=0
  den=dx
  num=dx/2
  numadd=dy
  numpixels=dx
 else
  xi1=0
  yi0=0
  den=dy
  num=dy/2
  numadd=dx
  numpixels=dy
 end
 
 local onemoreround=0
 local roundnum=0
 while(true) do
  roundnum+=1
  if onemoreround==1 and roundnum>2 then return false end
  if(roundnum!=1) and not plot(x,y) then onemoreround=1 end
  if x==x1 and y==y1 then return true end
  
  num = num+numadd
  if(num>=den) then
   num=num-den
   x+=xi0
   y+=yi0
  end
  x+=xi1
  y+=yi1
 end
end

function dist(x0,y0,x1,y1)
 local dx=x1-x0
 local dy=y1-y0
 return sqrt((dx*dx)+(dy*dy))
end

// messages
function initmsgs()
 max_msgs=3
 for i=0,max_msgs+1 do
  local msg={}
  msg.txt=""
  msg.i=i
  msg.active=false
  msg.y=0
  msg.ty=0
  msg.col=7
  msg.length=0
  msg.count=0
  add(msgs, msg)
 end
 next_msg=1
end

function post_msg(txt,col)

 // nudge all messages down
 for i in all(msgs) do
  if i.active then
  	i.i+=1
  	i.ty+=8
  	if(i.i>=4) then
  	 i.active = false
  	end
  end
 end
 
 local msg=msgs[next_msg]
 
 msg.txt=txt
 msg.col=col
 msg.active=true
 msg.y=0
 msg.ty=0
 msg.length=#txt
 msg.count=0
 msg.i=0
 
 next_msg+=1
 if(next_msg >= #msgs) then
  next_msg=1
 end
end

function update_msgs()
 for i in all(msgs) do
  if i.active then
  
   if i.y<i.ty then
    i.y+=(i.ty-i.y)/2
   end
   if i.count<i.length then
    i.count+=2
   else
    i.count=i.length
   end
   
  end
 end
end

function draw_msgs()
 local starty=128-8*max_msgs
 rectfill(0,starty-1,128,starty+8*max_msgs,0)

 for i in all(msgs) do
  if i.active then
   local str=sub(i.txt,0,i.count)
   print(str,1,starty+i.y,i.col)
  end
 end
end

// == items == //
function init_items()
 items={}
end

function create_item(ox,oy,fr)
 local item={}
 item.x=ox
 item.y=oy
 item.active=true
 item.f=fr
 add(items,item)
 return item
end

function create_food(ox,oy)
 local item = create_item(ox,oy,6)
 item.pickup=pickup_food
end

function create_nothing(ox,oy)
end

function create_health(ox,oy)
 local item = create_item(ox,oy,8)
 item.pickup=pickup_health
end

function create_power(ox,oy)
 local item=create_item(ox,oy,9)
 item.pickup=pickup_power
 
end

function create_random_weapon(ox,oy)
 local roll=flr(rnd(5))+1
 
 // don't give too powerful stuff too early
 if roll>level then
  roll=level
 end
 create_weapon(ox,oy,roll)
end

function create_random_armor(ox,oy)
 local roll=flr(rnd(5))+1
 
 // don't give too powerful stuff too early
 if roll>level then
  roll=level
 end
 create_armor(ox,oy,roll)
end

function create_weapon(ox,oy,typ)

 // first
 local w1={hit=0.5, 
           crit=0.95, 
           pow=1,
           name="fists",
           verb="punch",
           f=65}
 
 // crowbar
 local w2={hit=0.45,
 				      crit=0.92,
 				      pow=2,
 				      name="crowbar",
 				      verb="thwap",
 				      f=66}
 				      
 // laser sword
 local w3={hit=0.35,
           crit=0.8,
           pow=4,
           name="pblade",
           verb="stab",
           f=67}
 
 // pistol
 local w4={hit=0.55,
           crit=0.8,
           pow=5,
           name="pistol",
           verb="shoot",
           f=68}
           
 // rifle
 local w5={hit=0.25,
           crit=0.65,
           pow=6,
           name="rifle",
           verb="blast",
           f=69}
 
 local ws={w1,w2,w3,w4,w5}
 local w=ws[typ]
 local item=create_item(ox,oy,w.f)
 item.w=w
 item.pickup=pickup_weapon
end

function create_armor(ox,oy,typ)

 local a1={name="suit",
           def=0,
           f=80}
 local a2={name="lt. armor",
           def=1,
           f=81}
 local a3={name="med. armor",
           def=2,
           f=82}
 local a4={name="hv. armor",
           def=4,
           f=83}
 local a5={name="z. suit",
           def=1,
           f=88}
           
 local types={a1,a2,a3,a4,a5}
 local a=types[typ]
 local item=create_item(ox,oy,a.f)
 item.a=a
 item.pickup=pickup_armor
          
end

function pickup_food(item)
 player.hunger-=10+flr(rnd(10))
 sfx(9,3)
 post_msg("Œ *nom* *nom* Œ",10)
 if player.hunger<=0 then
  player.hunger=0
  post_msg("Œ you are full Œ",10)
 end 
end

function pickup_health(item)
 local hp=5+flr(rnd(5))
 if(player.health==player.maxhealth) then
  player.maxhealth+=1
  player.health=player.maxhealth
  post_msg("’max ‡ increased!!’",9)
 else
  player.health+=hp
  if(player.health>player.maxhealth) then
   player.health=player.maxhealth
  end
  post_msg("you heal "..hp.."‡ !!",11)
 end
 
end

function pickup_power(item)
 local power=10+flr(rnd(30))
 post_msg("– gained "..power.." – !!", 11)
 player.power+=power
 sfx(13,3)
end

function pickup_weapon(item)
 player.w=item.w
 post_msg("…equipped "..item.w.name.." !!…",9)
end

function pickup_armor(item)
 player.a=item.a
 post_msg("‰equipped "..item.a.name.." !!‰",9)
end

function draw_items()
 for i in all(items) do
  if i.active and cansee(i) then
   spr(i.f,i.x*8,i.y*8)
  end
 end
end

// == crates == //
function init_crates()
 crates={}
 
end

function spawn_crates(count)
 for i=0,count do
	 local ti=get_spawn_point()
	 local crate={}
	 crate.x=ti[1]
	 crate.y=ti[2]
	 crate.opened=false
	 crate.loot=create_crateloot
	 add(crates,crate)
 end
end

function create_crateloot(ox,oy)
 sfx(0,3)
 // different rules for each thing
 local loot_table={}
 local total_roll=0
 
 add(loot_table,{create_nothing,2})
 add(loot_table,{create_food,1})
 add(loot_table,{create_health,0.5})
 add(loot_table,{create_power,2})
 total_roll+=5.5
 
 add(loot_table,{create_random_weapon,0.1})
 add(loot_table,{create_random_armor,0.1})
 total_roll+=0.2
 
 if current_map_type==2 then
  add(loot_table,{create_health,2})
  add(loot_table,{create_random_armor,0.25})
  total_roll+=2.25
 elseif current_map_type==3 then
  add(loot_table,{create_random_weapon,1.5})
  add(loot_table,{create_random_armor,2})
  total_roll+=3.5
 elseif current_map_type==4 then
  add(loot_table,{create_power,3})
  total_roll+=3
 elseif current_map_type==5 then
  add(loot_table,{create_food,4})
  total_roll+=4
 end
 
 local roll=rnd(total_roll)
 local loot=nil
 for i in all(loot_table) do
  roll-=i[2]
  if roll<=0 then
   i[1](ox,oy)
   return
  end
 end
end

function draw_crates()
 for i in all(crates) do
  if cansee(i) then
   if i.opened then
    spr(39,i.x*8,i.y*8)
   else
    spr(38,i.x*8,i.y*8)
   end
  end
 end
end

// == splats == //
function init_splats()
 splat_frames={51,52,53,54}
 
end

function splat(tx,ty,col)
 splats[ty*map_size+tx]={f=rndin(splat_frames),c=col}
end

function bigsplat(tx,ty,col)
 for x=tx-1,tx+1 do
  for y=ty-1,ty+1 do
   if (tx==x and ty==ty) or rnd()>0.5 then
    splat(x,y,col)
   end
  end
 end
end

// == splosions == //

function init_splosions()
 max_splosions=8
 splosions={}
 next_splosion=1
 for i=0,max_splosions do
  local splosion={}
  splosion.x=-10
  splosion.y=-10
  splosion.frames={45,46,47,61,62,63}
  splosion.t=0
  splosion.active=false
  splosion.f=45
  add(splosions,splosion)
 end
end

function create_splosion(ox,oy)
 local splosion=splosions[next_splosion]
 splosion.active=true
 splosion.t=0
 splosion.mt=0.5
 splosion.x=ox
 splosion.y=oy
 splosion.f=45
 
 next_splosion+=1
 if next_splosion>=max_splosions then
  next_splosion=1
 end
end

function update_splosions(dt)
 for i in all(splosions) do
  if i.active then
   i.t+=dt
   i.f = i.frames[flr(i.t/i.mt*6)+1]
   if i.t>=i.mt then
    i.active=false
   end
  end
 end
end

function draw_splosions()
 for i in all(splosions) do
  if i.active then
   spr(i.f,i.x*8,i.y*8)
  end
 end
end

// == stars == //

function init_stars()
 max_stars=32
 for i=0,max_stars do
  local star={}
  star.x=rnd(128)
  star.y=rnd(128)
  star.dist=0.1+rnd()*0.9
  local coldex=flr(star.dist*5)%5
  local cols={1,5,13,6,7}
  star.col=cols[coldex+1]
  add(stars,star)
 end
end

function update_stars()
 for i in all(stars) do
  i.x -= 0.033*32*i.dist
  if(i.x<0) then i.x+=128 end
 end
end

function draw_stars()
 for i in all(stars) do
  pset(i.x,i.y,i.col)
 end
end

// room construction
function buildmap(typ)
 current_map_type=typ
 spawn_floors={}
 local roomcount=map_roomcounts[typ]
 while room_count<roomcount do
  buildroom(room_count==roomcount-1)
 end
 
 // put some items down
 local health_count=5
 local power_count=3
 local crate_count=2
 if current_map_type==2 then
  health_count=15
  power_count=3+flr(rnd(3))
  crate_count=4
 elseif current_map_type==3 then
  power_count=2
  crate_count=8
  if rnd()>0.5 then
   spawn_weapon(flr(rnd(5))+1)
  else
   spawn_armor(flr(rnd(5))+1)
  end
 elseif current_map_type==4 then
  power_count=6+flr(rnd(6))
  crate_count=2
 elseif current_map_type==5 then
  health_count=10
  power_count=2
  crate_count=10
 elseif current_map_type==6 then
  power_count=3
  crate_count=5
 end
 
 if level%3==0 then
  if rnd()>0.5 then
   spawn_weapon(flr(rnd(5))+1)
  else
   spawn_armor(flr(rnd(5))+1)
  end
 end
 
 spawn_things(create_health, health_count)
 spawn_things(create_power, power_count)

 spawn_crates(crate_count)
end

function spawn_weapon(typ)
 local point=get_spawn_point()
 create_weapon(point[1],point[2],typ)
end

function spawn_armor(typ)
 local point=get_spawn_point()
 create_armor(point[1],point[2],typ)
end

function spawn_things(create,count)
 for i=0,count do
  local point=get_spawn_point()
  create(point[1],point[2])
 end
end

function get_spawn_point()
 local floor=rndin(spawn_floors)
 local oy=flr(floor/map_size)
 local ox=floor-(oy*map_size)
 del(spawn_floors,floor)
 return {ox,oy}
end

function buildroom(is_hanger)
 local frontier=rndin(map_frontiers)
 local rorigin={map_size/2, map_size/2}
 local rdir=1
 local floors=floors_eng
 
 if(rnd(10)> 5) then
  if(rnd(10)>5) then
   floors=floors_med
  else
   floors=floors_res
  end
 end


 if #map_frontiers!=0 then
  // set new origin
  local ry=flr(frontier/map_size)
  local rx=frontier-ry*map_size
  rorigin={rx,ry}
  rdir=frontier_dir[ry*map_size+rx]
 end
 
 // rdir is horizontal or vertical
 local rdir_h=false
 local rdir_v=false
 if rdir==0 or rdir==2 then rdir_v = true
 elseif rdir==1 or rdir==3 then rdir_h = true
 end
 
 local is_corridor=rnd(10)>7
 local w = flr(4+rnd(8))
 local h = flr(4+rnd(8))
 if is_corridor then
  floors=floors_eng
  if rdir_h then
  	w = flr(5+rnd(10))
  	h = flr(3+rnd(2))
  elseif rdir_v then
   h = flr(5+rnd(10))
   w = flr(3+rnd(2))
  end
 end
 

 // habiitats
 if current_map_type==5 then
  floors=floors_res
  if not is_corridor then
   w=8
   h=8
  end
 elseif current_map_type==3 then
  floors=floors_han
 elseif current_map_type==2 then
  floors=floors_med
 end
 
 if is_hanger then
  floors=floors_han
  is_corridor=false
  w=8
  h=8
 end
 
 //local tile_floor=2
 //local tile_floor_shadow=18
 //local tile_wall_h=3
 //local tile_wall_v=4
 local tile_wall=5
 local tile_door=10
 local tile_id=0
 local ox=rorigin[1]
 local oy=rorigin[2]
 local tile_dir=0


 local ex=ox+w-1
 local ey=oy+h-1
 local dx=1
 local dy=1
 
 if rdir_v then
  ox=ox-flr(w/2)
  ex=ox+w-1
 elseif rdir_h then
  oy=oy-flr(h/2)
  ey=oy+h-1
 end
 
 if rdir==0 then
  ey=oy-h+1
  dy=-1
 elseif rdir==3 then
  ex=ox-w+1
  dx=-1
 end
 
 // test if it fits
 for x=ox+dx,ex-dx,dx do
  for y=oy+dy,ey-dy,dy do
   if x<0 or y<0 or x>=map_size or y>=map_size then
    return false
   elseif mget(x,y)!=0 then
    return false
   end
  end
 end
 
 for x=ox,ex,dx do
  for y=oy,ey,dy do
   local iswall = false
 		local iscorner=false
   tile_id=floors[2+flr(rnd(3))]
   if is_hanger or current_map_type==3 then
    tile_id=floors[2]
    if x==ex-dx or x==ox+dx or y==ey-dy or y==oy+dy then
     tile_id=floors[3]
    end
    
    if is_hanger then
     // start pos
	    start_x=ox+dx*2
	    start_y=oy+dy*2
	    
	    // ship pos
	    shipstart_x=ox+dx*4
	    shipstart_y=oy+dy*4
    end
   end
   
   local wallvarsh=wall_vars_h
   local wallvarsv=wall_vars_v
   if map_has_windows[current_map_type] then
    wallvarsh=wall_vars_h_win
    wallvarsv=wall_vars_v_win
   end
   
   if x==ox or y==oy or y==ey or x==ex then
    tile_id=tile_wall
    if (x!=ox and x!=ex) and (y==oy or y==ey) then
 			 tile_id=rndin(wallvarsh)
 			 if(y==oy) then tile_dir=0
 			 elseif(y==ey) then tile_dir=2
 			 end
 			elseif (y!=oy and y!=ey) and (x==ox or x==ex) then
 			 tile_id=rndin(wallvarsv)
 			 if(x==ox) then tile_dir=3
 			 elseif(x==ex) then tile_dir=1
 			 end
 			end
 			iswall=true
 			
 			// frontier dirs
 			if (x==ox and y==oy) or
 			   (x==ox and y==ey) or
 			   (y==oy and x==ex) or
 			   (x==ex and y==ey) then
 			 iscorner=true
 			end
   end
   
   if iswall and not iscorner then
    add(map_frontiers,y*map_size+x)
    frontier_dir[y*map_size+x] = tile_dir
   end
   
   if not iswall and (y==oy+1 or (y==ey+1 and rdir==0)) then
    tile_id = floors[1]
   end
   
   mset(x,y,tile_id)
   
   if not is_hanger and not iswall then
    add(spawn_floors,y*map_size+x)
   end
   
  end
 end
 
 // connecting door
 if(room_count>0) then
 	mset(rorigin[1],rorigin[2],tile_door)
 end
 
 room_count+=1

	return true
end

function create_actor(ox,oy)
 local actor={}
 actor.x=flr(ox)
 actor.y=flr(oy)
 actor.dx=0
 actor.dy=0
 actor.ax=0
 actor.ay=0
 actor.ax0=actor.x
 actor.ax1=actor.x
 actor.ay0=actor.y
 actor.ay1=actor.y
 actor.flp=false
 
 actor.w={} // weapon
 actor.a={} // armor
 
 add(actors, actor)
 return actor
end

function create_player(ox,oy)
 player=create_actor(ox,oy)
 player.health=10
 player.maxhealth=10
 player.level=1
 player.fr={1}
 player.ft=0
 player.f=1
 player.name="you"
 player.active=true
 
 player.w.hit=0.5
 player.w.crit=0.95
 player.w.pow=1
 player.w.name="fists"
 player.w.verb="punch"
 player.a.def=0
 player.a.name="suit"
 player.w.f=65
 player.a.f=80
 player.blood=8
 
 player.turns=0
 
 player.mapknown={}
 player.fov={}
 
 player.hunger=0
 player.maxhunger=100
 player.power=100
 
 player.bad=false
 
end

function move_player(ox,oy)
 player.mapknown={}
 player.fov={}
 player.turns=0
 player.x=ox
 player.y=oy
 stand(player)
end

function create_enemies(count)
 for i=0,count do
  spawn_enemy(get_enemy_for_map())
 end
end

function get_enemy_for_map()
 // enemy choice is based on
 // level and map type
 local enemies={1}
 // blob,bat,turret,grung,zydd
 
 if level>=2 then
  add(enemies,2)
 end
 
 // turrets, always on military bases
 if level>=3 or current_map_type==3 then
  add(enemies,3)
 end
 
 if level>=5 or current_map_type==2 then
  add(enemies,4)
 end 
 
 if level >=7 then
  add(enemies,5)
 end
 
 return rndin(enemies)
end

function spawn_enemy(typ)
 // select random floor
 local tindex=rndin(spawn_floors)
 local oy=flr(tindex/map_size)
 local ox=tindex-(oy*map_size)
 del(spawn_floors,tindex)
 
 create_enemy(ox,oy,typ)
end

function create_enemy(ox,oy,typ)

 enemy = create_actor(ox,oy)
 enemy.active=true
 
 // ’pecific enemy logic
 if typ==1 then
  // blob
  enemy.update = update_blob
  enemy.d=0
  enemy.name="blob"
  enemy.a.def=0
  enemy.w.hit=0.6
  enemy.w.crit=1
  enemy.w.pow=1
  enemy.w.verb="slimes"
  enemy.health=2
  enemy.blood=11
  enemy.drops=create_food
  enemy.fr=frames_blob
  if(rnd(10)>5) then
   enemy.d=1
  end
 elseif typ==2 then
  // hackwing
  enemy.update=update_hackwing
  enemy.name="hackwing"
  enemy.a.def=0
  enemy.w.hit=0.5
  enemy.w.crit=0.95
  enemy.w.pow=2
  enemy.w.verb="bites"
  enemy.health=4
  enemy.blood=11
  enemy.drops=create_food
  enemy.fr=frames_hackwing
 elseif typ==3 then
  // turret
  enemy.update=update_turret
  enemy.name="turret"
  enemy.a.def=2
  enemy.w.hit=0.65
  enemy.w.crit=0.9
  enemy.w.pow=3
  enemy.w.verb="shoots"
  enemy.health=8
  enemy.blood=4
  enemy.drops=create_power
  enemy.fr=frames_turret
 elseif typ==4 then
  // grungus
  enemy.update=update_grungus
  enemy.name="gizoid"
  enemy.a.def=1
  enemy.w.hit=0.2
  enemy.w.crit=1
  enemy.w.pow=1
  enemy.w.verb="absorbs"
  enemy.health=10
  enemy.blood=2
  enemy.drops=create_nothing
  enemy.fr=frames_grungus
  enemy.growth=0
  enemy.grown=false
 elseif typ==5 then
  // zydd
  enemy.update=update_zydd
  enemy.name="zydd"
  enemy.a.def=3
  enemy.w.hit=0.4
  enemy.w.crit=0.7
  enemy.w.pow=3
  enemy.w.verb="slices"
  enemy.health=10
  enemy.blood=10
  enemy.drops=create_food
  enemy.fr=frames_zydd
 end
 
 enemy.ft=0
 enemy.f=enemy.fr[1]
 enemy.flp=false
 
 enemy.bad=true
 add(actors,enemy)
 add(enemies,enemy)
 
end

function _init()
 level=0
 dead=false
 win=false
 death_reason=""
 
 init_splats()
 init_splosions()
 init_stars()
 init_items()
 
 initmsgs()
 
 // ‚reate new map
 create_new_level(1)
 
end

function clear_old()
 //destroy all
 // enemies
 enemies={}
 actors={}
 add(actors,player)
 
 // splats
 splats={}
 crates={}
 
 // items
 items={}
 
 // map
 for x=0,map_size do
  for y=0,map_size do
   mset(x,y,0)
  end
 end
 current_map={}
 map_frontiers={}
 frontier_dir={}
 spawn_floors={}
 room_count=0
 
end

function create_new_level(typ)
 clear_old()
 
 level+=1
 if level>=10 then
  win=true
  sfx(14,3)
  return
 end
 
 buildmap(typ)
 if player==nil then
  create_player(start_x, start_y)
 else
  move_player(start_x, start_y)
 end
 create_enemies(8+level*2)
 update_fov()
 generate_new_locations()
 showing_open_ceremony=true
 open_ceremony_time=0
 sfx(15,3)
end


// === update == //

function trymove(actor)
 local dx=actor.x+actor.dx
 local dy=actor.y+actor.dy
 local tile=mget(dx,dy)
 
 // isdoor
 if tile==10 then
  mset(dx,dy,17)
  if actor==player then
  	shake+=1.5
   sfx(0,3)
  end
  return false
 end
 
 //iscrate
 for i in all(crates) do
  if i.x==dx and i.y==dy then
   if not i.opened then
    i.opened=true
    i.loot(dx,dy)
    return false
   end
  end
 end
 
 // solid
 if fget(tile,0) then
  if actor==player then
   sfx(2,3)
  end
  return false
 end
 
 // attacking?
 for i in all(actors) do
  if i!=actor then
   if i.x==dx and i.y==dy then
    attack(actor,i)
    return false
   end
  end
 end
 
 return true
 
end

function attack(attacker,target)
 
 local roll=rnd()
 local hits=roll>=attacker.w.hit
 local crit=roll>=attacker.w.crit
 
 local dmg=0
 if hits then
  local pow=attacker.w.pow
  if crit then pow*=2 end
  dmg=max(pow-target.a.def,0)
  
  if crit then pow*=2 end
  target.health-=dmg
  splat(target.x,target.y,target.blood)
 end
 
 local col=11
   
 if attacker==player or (target!=player and cansee(target)) then
  if hits then
   if crit then
    col=9
    post_msg("’!!critical hit!!’",col)
   end
   if attacker==player then
    col=11
    shake=2
    if crit then col=9 end
    if crit then
     sfx(5,3)
    else
     sfx(4,3)
    end
   elseif target==player then
    col=8
    shake=4
    sfx(1,3)
   else
    col=2
   end
  	post_msg(attacker.name.." "..attacker.w.verb.." "..target.name.." for "..dmg.."hp!",col)
 	elseif attacker==player then
 	 sfx(2,3)
 	 post_msg("you miss!", 13)
 	end
 elseif target==player then
  col=8
  if hits then
   post_msg(attacker.name.." hits you for "..dmg.."hp!",col)
   shake=4
   sfx(1,3)
  else
   post_msg(attacker.name.." misses you!",13)
  end
 end
 
 // resolve death
 if target.health<=0 then
  kill(target, "killed by a "..attacker.name)
 end
end

function kill(actor, how)
 actor.health=0
 actor.active=false
 
 bigsplat(actor.x,actor.y,actor.blood)
 
 if actor!=player then
  actor.drops(actor.x,actor.y)
 else
  // uhoh, you died
  dead=true
  death_reason=how
 end
 
 create_splosion(actor.x,actor.y)
 
 actor.x=-10
 actor.y=-10
 
 
 if actor!=player then
  post_msg(actor.name.." dies!",8)
  sfx(6,3)
 end
 
 // drop thing
end

function move(actor)
 actor.ax0=actor.x
 actor.ax1=actor.x+actor.dx
 actor.ay0=actor.y
 actor.ay1=actor.y+actor.dy
 actor.x+=actor.dx
 actor.y+=actor.dy
 actor.dx=0
 actor.dy=0
end

function stand(actor)
 actor.ax0=actor.x
 actor.ax1=actor.x
 actor.ay0=actor.y
 actor.ay1=actor.y
 actor.dx=0
 actor.dy=0
end

function select_map(nmap)
 post_msg("you arrive at "..map_selections[selected_map+1].name2, 13)
end

function updateplayer()
 if show_map_screen then
  
  if btnp(0) then fuel_warning=false sfx(10,3) selected_map-=1 end
  if btnp(1) then fuel_warning=false sfx(10,3) selected_map+=1 end
  selected_map=selected_map%(#map_selections)
  
  if btnp(4) then
   if map_selections[selected_map+1].fuel<player.power then
   
   	select_map(map_selections[selected_map+1])
   	sfx(7,3)
   	player.power-=map_selections[selected_map+1].fuel
   	show_map_screen=false
   	showing_exit_ceremony=true
   else
    sfx(8,3)
    fuel_warning=true
   end
  end
  
  // close
  if btnp(5) then
   sfx(11,3)
   show_map_screen=false
  end
  return
 end
 
 // opening map screen
 if btnp(4) and
    player.x>=shipstart_x-1 and
    player.x<=shipstart_x and
    player.y>=shipstart_y-1 and
    player.y<=shipstart_y then
  show_map_screen=true
  fuel_warning=false
  sfx(12,3)
 end

 if btn(0) then player.dx-=1
 elseif btn(1) then player.dx+=1
 elseif btn(2) then player.dy-=1
 elseif btn(3) then player.dy+=1
 end
 
 if player.dx!=0 then
  player.flp=player.dx<0
 end
 
 local turntaken=false
 if(player.dx!=0 or player.dy!=0) then
 	turntaken=true
 	turnanim=0.0
 	if trymove(player) then
 	 move(player)
 	else
 	 stand(player)
 	end
 end
 
 // Œessing with items
 if not turntaken and btnp(4) then
  // is there an item?
  for i in all(items) do
   if i.active and i.x==player.x and i.y==player.y then
    sfx(3,3)
    i.pickup(i)
    del(items,i)
   end
  end
  
  turnanim=0.0
  stand(player)
  turntaken=true
 end
 
 if(turntaken) then
  update_fov()
  
  // update enemies
  for i in all(enemies) do
   if i.active then
    i.update(i)
   end
  end
  
  // ”pdate turns and hunger
  player.turns+=1
  
  if player.turns>=100 then
   player.turns-=100
  end
  
  if player.turns%5==0 then
   player.hunger+=1
   if player.hunger>=player.maxhunger then
    player.hunger=player.maxhunger
    player.health-=1
    sfx(1,3)
    post_msg("you are starving!!",8)
    if player.health<=0 then
     kill(player, "starved to death")
    end
   end
  end
  
  if player.turns%10==0 then
   player.power-=1
   if player.power<=0 then
    player.power=0
    sfx(1,3)
    post_msg("no –!! o2 low!!",8) 
    player.health-=1
    if player.health<=0 then
     kill(player, "asphyxiated")
    end
   end
  end
  
  // supersuit
  if player.a.name=="z. suit" then
   if player.turns%10==0 then
    player.hunger-=1
   end
   if player.turns%20==0 and player.health<player.maxhealth then
    player.health+=1
   end
  end
 end
 
end

// enemy turn logic

function update_blob(actor)
 local dx=0
 local dy=0
 if actor.d == 0 then
  dy=-1
 elseif actor.d==1 then
  dx=1
 elseif actor.d==2 then
  dy=1
 else
  dx=-1
 end
 
 actor.dx=dx
 actor.dy=dy
 if(trymove(actor)) then
  move(actor)
 else
  stand(actor)
  actor.d=(actor.d+2)%4
 end
 
end


function update_hackwing(actor)
 local dx=-1+flr(rnd(3))
 local dy=-1+flr(rnd(3))
 actor.dx=dx
 actor.dy=dy
 if dx<0 then 
  actor.flp=true
 elseif dx>0 then
  actor.flp=false
 end
 if(trymove(actor)) then
  move(actor)
 else
  stand(actor)
 end
end

function update_turret(actor)
 // it doesn't move
 local xrng=abs(player.x-actor.x)
 local yrng=abs(player.y-actor.y)
 if xrng <=1 and yrng <=1 then
  // target aquired!!
  actor.dx=player.x-actor.x
  actor.dy=player.y-actor.y
  if actor.dx<0 then 
   actor.flp=false
  elseif actor.dx>0 then
   actor.flp=true
  end
  trymove(actor)
  stand(actor)
 end
end

function update_grungus(actor)
 local dx=-1+flr(rnd(3))
 local dy=-1+flr(rnd(3))
 actor.dx=dx
 actor.dy=dy
 if cansee(actor) then
  actor.dx=0
  actor.dy=0
  if actor.x<player.x then actor.dx=1 elseif actor.x>player.x then actor.dx=-1 end
  if actor.y<player.y then actor.dy=1 elseif actor.y>player.y then actor.dy=-1 end  
 end
 if dx<0 then 
  actor.flp=true
 elseif dx>0 then
  actor.flp=false
 end
 if(trymove(actor)) then
  move(actor)
  splat(actor.x,actor.y,2)
 else
  stand(actor)
 end
end

function update_zydd(actor)
 actor.dx=0
 actor.dy=0
 if cansee(actor) then
  actor.dx=0
  actor.dy=0
  if actor.x<player.x then actor.dx=1 elseif actor.x>player.x then actor.dx=-1 end
  if actor.y<player.y then actor.dy=1 elseif actor.y>player.y then actor.dy=-1 end  
 end
 if actor.dx<0 then 
  actor.flp=true
 elseif actor.dx>0 then
  actor.flp=false
 end
 if(trymove(actor)) then
  move(actor)
 else
  stand(actor)
 end
end

function update_fov()
 // noddy fov
	local range=5
	local dx=0
	local dy=0

	player.fov={}

 for x=player.x-range,player.x+range do
  for y=player.y-range, player.y+range do
   if dist(player.x, player.y, x, y) <= range and lineplot(player.x,player.y,x,y,is_visible) then
   	add(player.fov, {x,y})
   end
  end
 end
end

function is_visible(tx,ty)
 local tile=mget(tx,ty)
 local solid=fget(tile,0)
 local clear=fget(tile,1)
 if solid and not clear then
  return false
 else
  for i in all(crates) do
   if i.x==tx and i.y==ty and not i.opened then
    return false
   end
  end
 end
 
 return true
end

function _update()
//function _update60()

 //local dt=0.0166
 local dt=0.033
 
 if dead or win then
  if btn(4) and btn(5) then
   run()
  end 
  return
 end
 
 if showing_exit_ceremony then
  
  exit_ceremony_time+=dt
  if exit_ceremony_time>=1.0 then
   create_new_level(map_selections[selected_map+1].typ)
   exit_ceremony_time=0
   showing_exit_ceremony=false
  end
  return
 elseif showing_open_ceremony then
  open_ceremony_time+=dt
  if open_ceremony_time>=1.0 then
   open_ceremony_time=1.0
   showing_open_ceremony=false
  end 
 end
 
 // wait for player input.
 local canturn = true 
 if turnanim<1.0 then
  canturn=false
 end
 
 if canturn then
 	if updateplayer() then
  
 	end
 	// update enemies.
 end
 
 if turnanim<1.0 then
  turnanim+=dt*6
 end
 if turnanim>1.0 then
 	turnanim=1.0
 end
 
 for i in all(actors) do
  i.ax=(i.ax0+(i.ax1-i.ax0)*turnanim)*8
  i.ay=(i.ay0+(i.ay1-i.ay0)*turnanim)*8
  i.ft+=dt*4
  i.f=i.fr[flr(i.ft%(#i.fr))+1]
 end
 
 update_msgs()
 update_stars()
 update_splosions(dt)
 
 if shake>0 then
  shake*=0.95
 end
end

function cansee(actor)
 for i in all(player.fov) do
  if i[1]==actor.x and i[2]==actor.y then return true end
 end
 return false
end

// == draw == //

function _draw()

 cls()
 
 sx=player.ax-64
 sy=player.ay-64
 
	camera(0,0)
	draw_stars()

 
 local shakex=rnd(shake)
 local shakey=rnd(shake)
 camera(sx+shakex,sy+shakey)
 
 for i=1,16 do
  pal(i,1)
 end
 
 palt(0,false)
 pal(0,0)
 map(0,0,0,0,map_size,map_size)
 palt()
	pal()
	
	// draw map
 for i in all(player.fov) do
  
  local t=mget(i[1],i[2])
  if t!=0 then
 	 spr(t,i[1]*8,i[2]*8)
 	end
 	
 	// draw splats
 	local sp=splats[i[2]*map_size+i[1]]
 	if sp!=nil then
 	 pal(2,sp.c)
 	 spr(sp.f,i[1]*8,i[2]*8)
 	end
 	
  pal()
 end
 
// items
 draw_crates()
 draw_items()
 
 // ship shadow
 for i=1,15 do
  pal(i,1)
 end
 sspr(88,16,16,16,shipstart_x*8-8-2, shipstart_y*8-8+4)
 pal()
 
 // ƒraw actors
 if not showing_open_ceremony and not showing_exit_ceremony then
	local wobble=abs(sin(turnanim/2))*2
	for i in all(actors) do
	 if i.active and (i==player or cansee(i)) then
	  spr(31,i.ax,i.ay+1)
	  spr(i.f,i.ax,i.ay-wobble,1,1,i.flp)
	 end
	end
	end
	
	draw_splosions()
	
	// draw shadey bits
	for i in all(player.fov) do
	 if dist(player.x,player.y,i[1],i[2])>4 then
	  spr(15,i[1]*8,i[2]*8)
	 end
	end
	
	// draw ship
	sspr(88,16,16,16,shipstart_x*8-8, shipstart_y*8-8-(exit_ceremony_time*32)-(1.0-open_ceremony_time)*32)
 
 
	camera(0,0)
	draw_stats()
	
	if show_map_screen then
	 draw_map_screen()
	end
	
	if showing_exit_ceremony then
  fade_scr(exit_ceremony_time)
 elseif showing_open_ceremony then
  fade_scr(1.0-open_ceremony_time)
 else
  pal()
 end
 
 	
	if dead then
	 draw_death_sceen()
	elseif win then
	 draw_win_screen()
	end
 
end

function draw_stats()
 palt(0,false)
 pal(0,0)
 rectfill(0,0,128,6,0)
 pal()
 print("‡"..player.health.."/"..player.maxhealth,1,1,8)
 print("Œ"..player.hunger.."/"..player.maxhunger,48,1,10)
 print("–"..player.power,96,1,11)

 draw_msgs()
 draw_gear()
end

function draw_gear()
 draw_gear_back(2,8)
 spr(player.w.f,4,10)
 print("wpn",3,21,8)
 
 draw_gear_back(22,8)
 spr(player.a.f,24,10)
 print("arm",23,21,8)
end

function draw_gear_back(ox,oy)
 palt(0,false)
 pal(0,0)
 rectfill(ox,oy,ox+12,oy+18,0)
 rect(ox,oy,ox+12,oy+11,9)
 pal()
end

function draw_map_screen()
 palt(0,false)
 pal(0,0)
 
 rectfill(0,32,128,128-32,0)
 rect(0,32,127,128-32,9)
 
 pal()
 palt()
 
 // level
 for i=1,10 do
  if i<10 then
  	spr(71,8+(i-1)*10,52)
  	spr(70,8+(i-1)*10+5,52)
  else
   spr(72,8+(i-1)*10,52)
  end
  if level==i then
   spr(73,8+(i-1)*10,52)
  end
 end
 print("end",110,53,8)
 
 for i=0,(#map_selections)-1 do
  local mp=map_selections[i+1]
  local sx=16+i*40
  local sy=40
  spr(96+mp.typ-1,sx,sy)
  
  if selected_map==i then
   rect(sx-3,sy-3,sx+10,sy+10,10)
  
   local cola=10
   if fuel_warning then cola=8 end
   print("– cost:",8,62,3)
   print("–"..mp.fuel,40,62,cola)
   
   print("name:",8,70,3)
   print(mp.name2,32,70,11)
   
   print("class:",8,78,3)
   print(mp.name,32,78,10)
   
   print(mp.desc,8,86,9)
  end
 end
end

function fade_scr(fa)

	fa=max(min(1,fa),0)

	local fn=8
	local pn=15
	local fc=1/fn
	local fi=flr(fa/fc)+1

	local fades={
		{1,1,1,1,0,0,0,0},
		{2,2,2,1,1,0,0,0},
		{3,3,4,5,2,1,1,0},
		{4,4,2,2,1,1,1,0},
		{5,5,2,2,1,1,1,0},
		{6,6,13,5,2,1,1,0},
		{7,7,6,13,5,2,1,0},
		{8,8,9,4,5,2,1,0},
		{9,9,4,5,2,1,1,0},
		{10,15,9,4,5,2,1,0},
		{11,11,3,4,5,2,1,0},
		{12,12,13,5,5,2,1,0},
		{13,13,5,5,2,1,1,0},
		{14,9,9,4,5,2,1,0},
		{15,14,9,4,5,2,1,0}
	}

	for n=1,pn do
		pal(n,fades[n][fi],1)
	end

end

function draw_death_sceen()
 palt(0,false)
 pal(0,0)
 
 rectfill(0,32,128,128-32,0)
 rect(0,32,127,128-32,9)
 
 pal()
 palt()
 
 print(" you died ",36,40,8)
 print(death_reason,24,48,8)
 
 print("only "..(10-level).." jumps to go!",26,64,9)
 
 print("press z+x to restart!",24,80,10)
end

function draw_win_screen()
 palt(0,false)
 pal(0,0)
 
 rectfill(0,32,128,128-32,0)
 rect(0,32,127,128-32,9)
 
 pal()
 palt()
 
 print(" you won ",36,40,11)
 print("you have reached utopia!",24,48,11)
 
 print("!! congratulations !!",26,64,9)
 
 print("press z+x to restart!",24,80,10)
end
if(_update60)_update=function()_update60()_update_buttons()_update60()end
__gfx__
00000000044888405ddddddd00000000041111900000000000000000001c100000000000003bb300000000000000000004111190000000000211119010101010
0000000004f888801555555d9955995504155190025995500000000001c6c1000288882003b1db30015555109950001500155190945049550411519001010101
00700700028222201555555d11111111021111500211115004aaaaa40cd66c10286666820b499ab00d5cc5d01111401100411150111111110215511010101010
00077000022f1f101555555d1515515102155150041551904ae4447a0c5664c0867787780b155db0055cc5501515115102151400155151510211510001010101
00077000002ffff01555555d151551510415519004155190aeee446a0c566c10867888780b1955b00d5555d01515515104114000151111110045519010101010
00700700005884001555555d111111110411119002111150aeee442a0c5d6c00867787780b1595b0019911901111111404111100142121210411114001010101
00000000005225001555555d4422442202155150022442204a4222a40c55dc00866666680b1111b0099119904422440002155110400541220211515010101010
00000000000202001111111500000000021111500000000004aaaa4001ccc1002888888203bbbb30000000000000000002211150000000000211115001010101
5111111555d5d5d51111111100000000000000000001100000000000000000000000000000001100000011000000110001111110001111000001100000000000
151515111151515d111111150001100000000000001bb1000011110000000000110000100001661000016d1000016d10112222d101122d100011110000000000
111111511515151511111115001bb1000001100001bbbb1001222210111111112210012101166dd10001d1100011ddd11222ee211122e2d101122d1000000000
151551111151515d1111111501bbbb10011bb11001bbdb10122b2b21222222221221122118ddddd100191110018ddd111222ee211222ee210122e21000000000
11155151151515151555555d13bdbb311bbbdbb1013bb31012212121122b2b21012222100111111000011100001111101222222112222221112ee21100000000
151111111151515d1555555d133bb33133bbbb33013333101210112101112110001b2b100000dd000000dd000000dd0012222221122ee221122ee22100111100
115151511515151d1555555d0133331013333331001331000100001000001000000121000001111000011110000111101eeffee112effe21122ff22101111110
51111115111111151111111500111100011111100001100000000000000000000000100000000000000000000000000001111110011111100111111000111100
1111222255554445555555553bb1b1b00111011000011000aaaaaa77499114aa044888401aaddadd511111150000000000000000000000000000000000000000
111122225555444454444445133bbb311bbb113111111110499999974900009a04f888804955995d151515110011155ddd666d00000000000000000000099000
1111222255554444545445453bb3333113bb3b3111b3b33149e9ee9a490000aa028222204559955911515151005111111555110000000000000aa00040999904
111122225555444454444445133b8b813bb333313b3315114999999a4a0000aa022f1f1015995599151515110011155ddd666d0000007000000aaa004449a904
4444555544445555544444453313bb31131b8b811315111049a9a99a4a0000aa002ffff01995599d11515151000511111551100000007007a0aaaa0a444aa944
4444555544445555545445451113311033133310331115004949499a490000aa00dc60004955995d15151511222222222244444407077070aaaa7aaa049aaa90
4444555544445555544444450013310011133100111331004999999a4900009a00dcc00045599559115151512444244499949994007777700aa77aa0049aa940
444455555444555555555555001313100013131000131310444444444441144a000d0d00114411445111111502442424949499400007770000a77a0000499400
11551155cc66cc66cc66cc66020000000000020000020000000000001ddddddd55554445cc66cc66111111110024245566949400400400004000000400000004
11551155cc66cc66cc66cc6600000000000000000000002000200000155d555d55454554cc66cc664411441100022511cd644000940940044000404040004000
5511551166cc66cc666ee6cc0220220000000000020220000222002015d555dd5555445466cccccc4114411400002511cd640000940990490004400000000000
5511551166cc66cc66eeeecc000220000000200000000000020000001555555d4555444466cccccc1144114400222451d6944400400490400004000000000000
cc66cc66cc66cc66cceeee66002220000002000000200000000000001555555d44445455cccccc661995599d00244451d6999400000494000000000000000000
cc66cc66cc66cc66cc6ee666022220000020020000220000000000001155155d45545555cccccc664955995d0052244569944d00004944000000000000000000
66cc66cc66cc66cc66cc66cc000200000220000002022000002000001115515d4554555566cc66cc45599559005d022494405d00004440000004040000000000
66cc66cc66cc66cc66cc66cc00000002000000000000220000000000111111114544554566cc66cc114411440000000240000000000440000000000000000000
0000000004999400000049940000499000000000915518880000000000000000000000000a0000a0000000000d1001c000000000000000000000000000000000
00000000498889940004955900049cc90499999049119940000000000000000000222200aa0000aac6ccc66c0d1001c000000000000000000000000000000000
0000000098888289004952890049c7c9495dd5189d1ddd9400000000000990000220022000000000111111110d10016000000000000000000000000000000000
000000009288828904952929049c7c9491550518155555890044440000999900020000200000000000000000061001c000000000000000000000000000000000
0000000092288889495299294967c940491111909111115900444400009999000200002000000000000000000d1001c000000000000000000000000000000000
00000000492552949529409496559400915199409199199400000000000990000220022000000000111111110d10016000000000000000000000000000000000
000000000495594092940000955940009119400091119400000000000000000000222200aa0000aadd6d6ddd0d10016000000000000000000000000000000000
0000000000499400494000004994000049940000499940000000000000000000000000000a0000a000000000061001c000000000000000000000000000000000
00000000001cc10001cccc1005dcc5d001cccc100299992001dddd10013333100049940000000000000000000000000000000000000000000000000000000000
001cc10001cddc101cd99dc1158498d11c1111c1294444921d7777d1131bb131049cc94000000000000000000000000000000000000000000000000000000000
01c55c101c5dddc1cd5885dcc222888cc1d22d1c94499449d778877d31b1111349dccc9400000000000000000000000000000000000000000000000000000000
1c2542c1c555dddcc512815c21122988c12dd21c949aa949d788887d31bbb1139d9dd9c900000000000000000000000000000000000000000000000000000000
c225522cc5c55cdcc1c99c1c21112228d12cc21d82a77a285622226512233321499dd99400000000000000000000000000000000000000000000000000000000
c5c19c5c01cd9cc11cc88cc12c4499c2d1c22c1d822aa228566226651222232109d99d9000000000000000000000000000000000000000000000000000000000
1c1cc1c10c5555c00c2288c01c2288c11d1111d118222281156666510123321009d99d9000000000000000000000000000000000000000000000000000000000
000000000c5cc5c00c2cc8c0c211288c01dddd100188881001555510001111000494494000000000000000000000000000000000000000000000000000000000
00050000008cc800000552800000800000d666000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011d55000050050002259000000510000ddd11600005922000650560000000000000000000000000000000000000000000000000000000000000000000000000
00050000055005501049590200455000ddddd6660441500006500056000000000000000000000000000000000000000000000000000000000000000000000000
000515801595545412555582d11511d15544195a2421100005001005000000000000000000000000000000000000000000000000000000000000000000000000
011d500014545595122288821d151d1d5a114595224244000001d100000000000000000000000000000000000000000000000000000000000000000000000000
009d90000115511012929a820001000066dddd660224420005001005000000000000000000000000000000000000000000000000000000000000000000000000
001d50000011110001228820d1151d1d066dddd00022220001500051000000000000000000000000000000000000000000000000000000000000000000000000
0001000000011000001122001d1011d10066dd000002200000150510000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000101010000000001010101010000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0003000022620226200a6200962021600096000260001600086000760028000250002300000000000000000000000000000000000000000000000000000016000160002600000000000000000000000000000000
00030000350503504036040350403303030030275201a5100b5100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001475012740107300f7500d7500b7500974007720057100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800003005027050300202702030010270100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a7502975027750227501b7501375007650086400a6300a63005620056100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a7502875026750237501c750147500d1501012013120161501a1401e140201402313026120271100d6400b6400e6400e6300b6200961005610000000000000000000000000000000000000000000000
000300001f7601d750197401574012730117201c720187201571013710107100f710147100d710077100370004300013000000000000000000000000000000000000000000000000000000000000000000000000
000900001a6402a6403064031640306302e6302c63029630266302463021630206301f6301c62017620126200f6200a6100661005610036100161001610016102560027600296002b6002e600316003460035600
000700002b2502b2402225022250117000c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001c75015750107500e7500b7500475006750087500e7501275000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700002e05036050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000350502b050180500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000019050220502d0503505036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a2500d2501b2500c2501d2400c240202400a240282300822031220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400002405220052220522605224052180522405218032240321802224012180122401518015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000031630316302e6402b64027640246402264020630196200365003650036500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002476010200247401520024720132002471017200182000000000000000000000000000000000000027760000002774000000277200000027710000002b760000002b740000002b720000002b71000000
011000002c760000002c740000002c720000002c71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002b760000002b740000002b720000002b71000000287600000028740000002872000000287100000024760000002474000000247200000024710000001f760000001f740000001f720000001f71000000
01100000207600000020740000002072000000207100000020710000002071000000207100000020710000001f760000001f740000001f720000001f710000001f710000001f710000001f710000001f71000000
011000000314003140021400214003140031400014000140031400314002140021400314003140001400014003140031400714007140031400314002140021400314003140071400714003140031400714007140
010f000008140081400714007140081400814005140051400814008140071400714008140081400c1400c14000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 10 14 43 44
00 11 15 43 44
00 12 42 43 44
00 13 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
