pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
-- pico-sprint
-- by rylauchelmi

--todo:
-- uniformiser l'interface
-- perfs sur certaines maps=> nb de skidmarks adaptatifs
-- optim: ne redessiner le pont que si au mins une voiture est potentiellement en dessous

--bug:
-- oil qui appa/disparait sur les ponts

--flags
--0 : waypoints
--1 : bridge markers
--2 : lap flag pos
--3 : road w/ collidable border
--4 : trees
--5 : road
--6 : placeholder (w/ collision)
--7 : start tiles

-- game settings/state
reverse=false
nb_maps=2
cur_time=0
max_lap=2
difficulty=1

-- entities
car_colors={8,11,10,12}
car_colors_shadow={2,3,9,1}
champ={1,2,3,4}

-- tweaks
--max_speed=2.5
max_speed=1.5
min_speed=-1
--turn_factor=0.02
turn_factor=0.015
--turn_factor=0.0075
acceleration=0.1
deceleration=-0.1

-- scenery
scenery=
{
 {-- grass
  color=3,
  particle=11,
  trees=
  {
   {x=2,y=-2,c=29,s=61,o=-8,so=0,w=2},
   {x=-1,y=-2,c=27,s=59,o=0,so=0,w=2}
  }
 },
 {-- snow
  color=6,
  particle=7,
  trees=
  {
   {x=2,y=-2,c=25,s=57,o=-7,so=-7,w=2},
   {x=-1,y=-2,c=31,s=63,o=0,so=5,w=1}
  }
 }
}

bridge=
{
 nil,
 { --2
  box_startx=72,box_starty=40,
  box_endx=96,box_endy=80,
  col_mapx=56,col_mapy=54,
  shadow_startx=96,shadow_starty=40,
  shadow_width=4,shadow_height=40
 },
 { --3
  box_startx=32,box_starty=64,
  box_endx=96,box_endy=80,
  col_mapx=52,col_mapy=48,
  shadow_startx=32,shadow_starty=80,
  shadow_width=64,shadow_height=4
 },
 { --4
  box_startx=32,box_starty=64,
  box_endx=96,box_endy=80,
  col_mapx=52,col_mapy=48,
  shadow_startx=32,shadow_starty=80,
  shadow_width=64,shadow_height=4
 },
 nil,
 nil,
 { --7
  box_startx=24,box_starty=40,
  box_endx=48,box_endy=120,
  col_mapx=48,col_mapy=48,
  shadow_startx=48,shadow_starty=56,
  shadow_width=4,shadow_height=48
 },
 { --8
  box_startx=32,box_starty=40,
  box_endx=128,box_endy=56,
  col_mapx=52,col_mapy=51,
  shadow_startx=56,shadow_starty=56,
  shadow_width=48,shadow_height=4
 },
 { --9
  box_startx=56,box_starty=48,
  box_endx=80,box_endy=88,
  col_mapx=56,col_mapy=54,
  shadow_startx=80,shadow_starty=48,
  shadow_width=4,shadow_height=64
 },
 { --10
  box_startx=24,box_starty=72,
  box_endx=48,box_endy=88,
  col_mapx=56,col_mapy=54,
  shadow_startx=48,shadow_starty=56,
  shadow_width=4,shadow_height=48
 },
 { --11
  box_startx=64,box_starty=88,
  box_endx=88,box_endy=104,
  col_mapx=56,col_mapy=54,
  shadow_startx=88,shadow_starty=80,
  shadow_width=4,shadow_height=32
 },
 { --12
  box_startx=32,box_starty=64,
  box_endx=56,box_endy=96,
  col_mapx=65,col_mapy=48,
  shadow_startx=56,shadow_starty=64,
  shadow_width=4,shadow_height=40
 },
 { --13
  box_startx=72,box_starty=40,
  box_endx=96,box_endy=120,
  col_mapx=65,col_mapy=49,
  shadow_startx=96,shadow_starty=32,
  shadow_width=4,shadow_height=80
 },
 { --14
  box_startx=48,box_starty=24,
  box_endx=72,box_endy=64,
  col_mapx=60,col_mapy=54,
  shadow_startx=72,shadow_starty=40,
  shadow_width=4,shadow_height=24
 },
 { --15
  box_startx=72,box_starty=24,
  box_endx=96,box_endy=40,
  col_mapx=52,col_mapy=54,
  shadow_startx=64,shadow_starty=40,
  shadow_width=40,shadow_height=4
 }
}


-- maths

function dot(a,b)
	return a.x*b.x+a.y*b.y
end


function minus(a,b)
	return { x=a.x-b.x, y=a.y-b.y }
end


function plus(a,b)
	return { x=a.x+b.x, y=a.y+b.y }
end


function plus_in_place(a,b)
	a.x+=b.x
	a.y+=b.y
end


function muls(a,b)
	return { x=a.x*b, y=a.y*b }
end


function muls_in_place(a,b)
	a.x*=b
	a.y*=b
end


function unit(a)
 local len = max(sqrt(dot(a,a)),0.01)
	return { x=a.x/len, y=a.y/len }
end


function distance(a, b)
 local dx = a.x-b.x
 local dy = a.y-b.y
 dx*=dx
 dy*=dy
 local sum=dx+dy
 if (dx<0 or dy<0 or sum<0) return max_val
 return sqrt(sum)
end


function spawn_smoke(pos,color,size)
 local s = {
  -- relative to car sprite
  x=pos.x+4,
  y=pos.y+4,
  dx=rnd(2)-1,
  dy=rnd(0.25)+0.25,
  life=rnd(5)+5,
  color=color
 }
 s.lifestep = s.life/size
 add(smokes,s)
end


function update_smoke(s)
 s.life-=1
 s.x+=s.dx
 s.y-=s.dy
 if (s.life<=0) del(smokes,s)
end


function draw_smoke(s)
 palt(0,false)
 circfill(s.x,s.y,s.life/s.lifestep,s.color)
end


function flr_rnd(i)
 return flr(rnd(i))
end


function create_player()
 return
 {
  skills={0,0,0},
  selected_skill=1,
  nb_wrenches=0
 }
end

function create_car(col)
	local pos=start_tiles[max(col%(#start_tiles+1),1)]
	local wp=reverse and #waypoints or 1
	local start_dir=minus(waypoints[wp],pos)
	return
	{
  x=pos.x,
  y=pos.y,
  vel={x=0,y=0},
  speed=0,
  dir=start_dir,
  a=atan2(start_dir.y,start_dir.x),
  c=car_colors[col],
  cs=car_colors_shadow[col],
  s=0,
  f=false,
  ai=true,
  skid=1,
  waypoint=wp,
  dist_to_wp=1000,
  maybe_hidden=false,
 	lap_time=0,
  lap=0,
  can_lap=false,
  slipping=0,
  wp_time=0,
  i=col,
  on_bridge=true,
  wpc=0,
  score_pos=32*(col-1)+1,
  score_prev=32*(col-1)+1,
  missed=false,
  flag=0,
  flag_flip=0,
  finished=false,
  flag_timer=0,
  p=players[col]
 }
end


function hide_if_needed(c)
 if (not c.on_bridge and c.enter_bridge and should_hide(c,8)) c.on_bridge=true
 if (c.on_bridge) c.on_bridge=should_hide(c,8)
 c.maybe_hidden=not c.on_bridge and not c.enter_bridge
end


function draw_car_shadow(c)
  if (fget(c.s,6)) return
	 spr(c.s,c.x+1,c.y+1,1,1,c.f)
end


function draw_flag(c,pos)
 pal(8,c.c)
 -- spr(50+c.flag,pos.x+c.i,pos.y+c.i,1,1,c.flag_flip)
 spr(50+c.flag,pos.x,pos.y,1,1,c.flag_flip)
 c.flag+=0.5
 if (c.flag>=5) c.flag_flip=(not c.flag_flip) c.flag=0
end


function draw_car(c)
	hide_if_needed(c)
 pal(8,c.c)
 palt(0,false)
 palt(13,true)
 spr(c.s,c.x,c.y,1,1,c.f)

 -- car in shadow
	local	sz=bridge[cur_map]
	if sz!=nil and not c.on_bridge then
	 clip(sz.shadow_startx,sz.shadow_starty,sz.shadow_width,sz.shadow_height)
	 pal(8,c.cs)
	 spr(c.s,c.x,c.y,1,1,c.f)
  clip()
 end

 local wayp=waypoints[c.waypoint]
--	 line(c.x,c.y,wayp.x,wayp.y,9)
 if (c.missed) draw_flag(c,wayp) --draw_arrow(c,waypoints[c.waypoint])
 if (c.flag_timer>0) c.flag_timer-=1 draw_flag(c,flag_pos)
end


function draw_cars()
 foreach(cars, draw_car)

 local hz=bridge[cur_map]
 if hz!=nil then
  for c in all(cars) do
   if should_hide(c,8) and not c.on_bridge then
    clip(hz.box_startx,hz.box_starty-1,hz.box_endx-hz.box_startx,hz.box_endy-hz.box_starty+1)
    draw_map(false)
    pal()
    foreach(skidmarks_bridge,draw_skidmarks)
    foreach(placeholders,draw_placeholder) -- oil
    for i=1,4 do
     local c=cars[i]
     if (not c.maybe_hidden) car_shadows_state() draw_car_shadow(c) pal() draw_car(c)
    end
    clip()
    pal()
    return
   end
  end
 end
end


function screen_transition()
 if transition>0 then
  transition-=0.03
  if transition>0.25 then
   prev_screen.draw()
  else
   cur_screen.draw()
  end
  if (prev_screen!=cur_screen) circfill(64,64,-sin(transition)*92,0)
 else
  cur_screen.draw()
 end
end

function set_screen(s)
 transition=0.5
 prev_screen=cur_screen
 cur_screen=s
 s.init()
end


function _init()
 join_screen.init()
 cur_screen=start_screen
 set_screen(start_screen)
end


function map_index_to_coords(i)
 return flr(i%8),flr(i/8)
end


function read_map()
 skidmarks={}
 skidmarks_bridge={}
 skid_index=1
 skid_b_index=1
	waypoints={}
 start_tiles={}
 trees={}
 smokes={}
 placeholders={}
 puddles={}
 wrenches={}
 draw_ramp=false
 race_over=false
 last_lap=false
 finished={}
 lap=1

 cur_scenery=scenery[flr_rnd(#scenery)+1]

	for yy=0,14 do
 	for xx=0,15 do
   local x,y=map_index_to_coords(cur_map)
   local t=mget(xx+x*16,yy+y*15)
   local cur_pos={x=xx*8,y=yy*8}

   if (fget(t,0)) waypoints[t-239]=cur_pos t=128
   if (fget(t,2)) flag_pos=cur_pos
   if (fget(t,7)) add(start_tiles,cur_pos) 
   if (128==t) add(puddles,cur_pos)

   -- trees
   local is_tree=123<t and t<126
   if is_tree then
    local tree=cur_scenery.trees[t-123]
    add(trees,{x=cur_pos.x+tree.x,y=cur_pos.y+tree.y,c=tree.c,s=tree.s,o=tree.o,w=tree.w,so=tree.so})
   end

   -- placeholders
   local placeholder=fget(t,6)
   if (placeholder) add(placeholders,{x=cur_pos.x,y=cur_pos.y,s=t-1,f=false})
    
   local yyy=yy+48
   local xxx=xx+16
   mset(xx,yyy,0)
   mset(xxx,yyy,0)
   if fget(t,5) or placeholder or is_tree then
    mset(xx,yyy,t)
    mset(xxx,yyy,t)
    if (fget(t,3)) draw_ramp=true
   end

   local hz=bridge[cur_map]
   if should_hide(cur_pos,1) then
    x=xx-hz.box_startx/8
    y=yy-hz.box_starty/8
    t=mget(x+hz.col_mapx,y+hz.col_mapy)
    if (not fget(t,5)) t=128
    mset(xxx,yyy,t)
 		end
 	end
 end

 drop_puddles(2*difficulty-1, puddles, 34)
 drop_puddles(difficulty-1, puddles, 33)
end


function drop_puddles(nb,puddles,t)
 for i=1,min(nb,#puddles) do
  local pos=puddles[flr_rnd(#puddles)+1]
  del(puddles,pos)
  mset(pos.x/8,pos.y/8+48,t)
  if (not should_hide(pos,1)) mset(pos.x/8+16,pos.y/8+48,t)
  add(placeholders,{x=pos.x,y=pos.y,s=t})
 end
end


function drop_wrench()
 local pos=puddles[flr_rnd(#puddles)+1]
 del(puddles,pos)
 add(wrenches,{x=pos.x,y=pos.y,s=35,f=false})
end


function tileidx_to_spritecoord(s)
 local sx=(s%16)*8
 local sy=flr(s/16)*8
 return sx,sy
end


--place_holder_shadow=0
function draw_placeholder(p)
-- spr(p.s,p.x+place_holder_shadow,p.y+place_holder_shadow)
 spr(p.s,p.x,p.y)
end

function draw_map(first_pass)
 pal()
 
 local cx,cy,sx,sy,cw,ch,hz=0,0,0,0,16,15,bridge[cur_map]
 if (not first_pass) cx,cy,sx,sy,cw,ch=hz.box_startx/8, hz.box_starty/8, hz.box_startx, hz.box_starty, (hz.box_endx-hz.box_startx)/8, (hz.box_endy-hz.box_starty)/8

 --debug
-- map(16,48, 0,0, 16,15)
 -- map(0,48, 0,0, 16,15)
 -- if (true) return

 local x,y=map_index_to_coords(cur_map)
 x*=16
 y*=15

 -- dirt
 if not draw_ramp and first_pass then
 -- if not draw_ramp then
  palt(5,true)
  palt(15,true)
  pal(6,4)
  pal(8,4)
  pal(9,4)
  pal(13,4)

  map(x,y, 2,2, 16,15)
 -- map(x*16,y*15, 2,-2, 16,15)
 -- map(x*16,y*15, -2,2, 16,15)
  map(x,y, -2,-2, 16,15)

  --palt()
  pal()
 end

 pal(4,13)
 pal(5,13)
 pal(10,13)
 pal(3,13)
 pal(14,0)
 map(x+cx,y+cy, sx,sy, cw,ch)

 -- pal()
 -- palt()
 -- palt(13,true)
 -- palt(0,false)
 -- foreach(placeholders,draw_placeholder)

 -- col ramp
 if draw_ramp then
  palt(1,true)
  palt(2,true)
  palt(5,true)
  palt(6,true)
  palt(8,true)
  palt(9,true)
  palt(10,true)
  palt(11,true)
  palt(12,true)
  palt(13,true)
  pal(3,1)
  pal(4,1)
  pal(14,0)
  map(cx,48+cy, 1+sx,sy, cw,ch)
  palt(3,true)
  pal(4,6)
  pal(14,13)
  -- map(0,48, 0,-1, 16,15)
  map(cx,48+cy, sx,sy-1, cw,ch)
  palt()
 end

-- if (debug_wp) return
 -- hide waypoint sprites 
 for i in all(waypoints) do
  spr(128,i.x,i.y-1)
 end

 -- local hz=bridge[cur_map]
 -- if (hz!=nil) rect(hz.box_startx, hz.box_starty, hz.box_endx, hz.box_endy, 10)
end


function should_hide(p,start_offset)
	local	hz=bridge[cur_map]
	return hz!=nil and hz.box_startx-start_offset<p.x and p.x<hz.box_endx and hz.box_starty-start_offset<p.y and p.y<hz.box_endy
end


outout=""
engine_sfx_max=0
engine_sfx_timer=0
function engine_sfx(s)
 engine_sfx_timer-=1
 if (engine_sfx_timer<=0 or engine_sfx_max<s) sfx(4+flr(4*s/max_speed/2),2) engine_sfx_timer=20 engine_sfx_max=s outout=flr(4*s/max_speed/2)
end


skid_sfx_timer=0
function skid_sfx()
 skid_sfx_timer-=1
 if (skid_sfx_timer<=0) sfx(flr_rnd(2)+1,3) skid_sfx_timer=20
end


function add_skidmarks(c,n)
 if (rnd(3)<1) return
 local side={x=-c.dir.y, y=c.dir.x*0.5} -- perspective
 local offset=plus(muls(c.dir,-2),muls(side,2.5*c.skid))
 plus_in_place(offset,{x=4,y=6})
 c.skid*=-1
 local c2=plus(c,offset)
 local n2=plus(n,offset)
 
 if (abs(flr(c2.x)-flr(n2.x))+abs(flr(c2.y)-flr(n2.y))==0) return
 
 local skid={c2.x,c2.y,n2.x,n2.y}
 if should_hide(c2,1) or should_hide(n2,1) then
  if (c.maybe_hidden) return
  skidmarks_bridge[skid_b_index]=skid
  skid_b_index=skid_b_index%100+1
 else
  skidmarks[skid_index]=skid
  skid_index=skid_index%750+1
 end
 skid_sfx()
end


function draw_skidmarks(s)
 line(s[1],s[2],s[3],s[4],5)
end


function car_collide(c1,c2)
	local dist=distance(c1,c2)
	if (dist<7 and c1.maybe_hidden==c2.maybe_hidden) then
		-- local strength=8-dist
  -- local delta=unit(minus(c1,c2))
		-- muls_in_place(delta,strength*0.5)
		-- plus_in_place(c1.vel,delta)
		-- muls_in_place(delta,-1)
		-- plus_in_place(c2.vel,delta)
  -- local mid=plus(c1,c2)
  -- muls_in_place(mid,0.5)
  local delta=muls(unit(minus(c1,c2)),(8-dist)*0.5)
  plus_in_place(c1.vel,delta)
  plus_in_place(c2.vel,muls(delta,-1))
  local mid=muls(plus(c1,c2),0.5)
  spawn_smoke(mid,7,4)
	end
end

function wall_collide(c,new_pos)
 local test_points={{1,4},{2,2},{4,1},{5,2},{7,4},{6,6},{4,7},{2,6}}
 local push=false
 c.enter_bridge=false
-- local push_dir={x=0,y=0}
 local push_dir=muls(new_pos,0)
 for tp in all(test_points) do
  local npx=new_pos.x+tp[1]
  local npy=new_pos.y+tp[2]
  
  local offset=c.maybe_hidden and 16 or 0
  local t=mget(npx/8+offset,npy/8+48) 

  local sx,sy=tileidx_to_spritecoord(t)
  local p=sget(sx+npx%8,sy+npy%8)

  -- walls
  if 2<p and p<6 then
  	push=true
 	 plus_in_place(push_dir,{x=4-tp[1],y=4-tp[2]})
  end

  if (fget(t,1)) c.enter_bridge=true

  -- oil
  if (p==11 and c.slipping==0) c.slipping=flr(abs(c.speed)/max_speed*25)
  -- water
  if (p==12) c.speed=min(c.speed,0.5*max_speed) spawn_smoke(c,12,3)
  -- grass or snow
  -- if (t==0 and c.speed>0.25*max_speed) spawn_smoke(plus(c,muls(c.dir,-5)),11,2)
  if (t==0 and c.speed>0.25*max_speed) spawn_smoke(plus(c,muls(c.dir,-5)),cur_scenery.particle,2)
 end
 return push,unit(push_dir)
end


function car_physics(c)
 for j=c.i+1,4 do
  car_collide(c,cars[j])
 end

 local persp_vel={x=c.vel.x,y=c.vel.y*2/3}
-- local persp_vel={x=c.vel.x,y=c.vel.y*0.75}
 local new_pos=plus(c,persp_vel)

 local push,push_dir=wall_collide(c,new_pos)
 if push then
  plus_in_place(new_pos,push_dir)
  local n=dot(c.dir,push_dir)
--  if false and n<-0.5 then
--  	plus_in_place(c.vel, muls(push_dir,2))
  	plus_in_place(c.vel, push_dir)
   local smoke_pos=plus(c,muls(push_dir,-4))
   spawn_smoke(smoke_pos,7,4)
--  else
	 	local side={x=-c.dir.y, y=c.dir.x}
--   local n2=dot(side,push_dir)
  	local tu=turn_factor--*4
--   turn(c,n2>0 and tu or -tu)
   turn(c,dot(side,push_dir)>0 and tu or -tu)
--  end
 end

 -- water/oil
 if (c.slipping>0) c.slipping-=1 turn(c,0.05) spawn_smoke(c,0,3)

	-- screen borders
	if (new_pos.x<0) new_pos.x=0 c.vel.x=0
	if (new_pos.x>120) new_pos.x=120 c.vel.x=0
	if (new_pos.y<0) new_pos.y=0 c.vel.y=0
	if (new_pos.y>120) new_pos.y=120 c.vel.y=0

 c.speed*=0.95
 compute_velocity(c)

 if (c.speed>1 and dot(c.dir,unit(c.vel))<0.95) add_skidmarks(c, new_pos)

	c.x=new_pos.x
	c.y=new_pos.y
end


function skill_factor(c,s,v)
 return v+v*c.p.skills[s]*0.1
end


function accelerate(c,s)
 -- applying skill improvements, last racer bonus, and difficulty
 c.speed+=skill_factor(c,2,s)+(car_order[4]==c.i and s or 0)
 c.speed=max(min(c.speed, skill_factor(c,3,max_speed)*(c.ai and 1-0.1*(3-difficulty) or 1)), min_speed)
 compute_velocity(c)
 engine_sfx(c.speed) 
end


function compute_velocity(c)
	local wanted_vel=muls(c.dir, c.speed*0.05);
	muls_in_place(c.vel,0.95)
	plus_in_place(c.vel,wanted_vel)
end


function turn(c,d)
-- d*=min(abs(c.speed), 1)
 d*=min(c.speed, 1)
 c.a+=skill_factor(c,1,d)
 while c.a>1 do c.a-=1 end
 while c.a<0 do c.a+=1 end
 if c.slipping==0 then
  c.dir.x=sin(c.a)
  c.dir.y=cos(c.a)
 end
 compute_velocity(c)
 c.s = (1-2*abs(c.a-0.5))*12.99
 c.f = c.a>0.5
 c.speed*=0.95
 return c
end


function next_waypoint(w,r)
 if r then
  w-=1
  if (w==0) w=#waypoints
 else
  w=w%#waypoints+1
 end
 return w
end


function set_next_waypoint(c,r)
 c.waypoint=next_waypoint(c.waypoint,r)
end


function car_comp(a,b)
 local c1=cars[a]
 local c2=cars[b]
 return c1.wpc<c2.wpc
end


function score_comp(a,b)
 return scores[a]<scores[b]
end


function bubble_sort(a,c)
 local len=#a
 local active=true
 local tmp=nil
 while active do
  active=false
  for i=1,len-1 do
   if c(a[i],a[i+1]) then
    tmp=a[i]
    a[i]=a[i+1]
    a[i+1]=tmp
    active=true
   end
  end
 end
end


-- function near_waypoint(c,w)
--  local delta=minus(waypoints[w],c)
--  local min_dist=c.ai and 12 or 16
--  return abs(delta.x)<min_dist and abs(delta.y)<min_dist
-- end


function check_waypoint(c)
 local delta=minus(waypoints[c.waypoint],c)
 local min_dist=c.ai and 12 or 16
 --local min_dist=12
 local dist_to_wp=max(abs(delta.x),abs(delta.y))
 c.dist_to_wp=min(c.dist_to_wp,dist_to_wp)
 if dist_to_wp<min_dist then
--	if near_waypoint(c,c.waypoint) then
  c.dist_to_wp=1000
  c.wp_time=cur_time
  set_next_waypoint(c,reverse)
 	if ((reverse and c.waypoint==1) or (not reverse and c.waypoint==#waypoints)) c.can_lap=true
  if (not c.finished) c.wpc+=1
  c.missed=false
-- elseif near_waypoint(c,next_waypoint(c.waypoint,reverse)) then
 elseif not c.ai and dot(delta,c.dir)<0 and dist_to_wp>c.dist_to_wp then
  c.missed=true
 end
 --unblock
 if (c.ai and c.wp_time+180<cur_time) c.wp_time=cur_time set_next_waypoint(c,not reverse) c.wpc-=1
--wrench
 for w in all(wrenches) do
  delta=minus(w,c)
  dist_to_wp=max(abs(delta.x),abs(delta.y))
  if (dist_to_wp<6) del(wrenches,w)  players[c.i].nb_wrenches+=1
 end
 -- lap line
 local x,y=map_index_to_coords(cur_map)
 local t=mget(x*16+c.x/8,y*16+c.y/8)
 -- local x=flr(cur_map%8)*16
 -- local y=flr(cur_map/8)*16
 -- local t=mget(x+c.x/8,y+c.y/8)
 if c.can_lap and fget(t,7) then
  c.flag_timer=30
 	c.lap+=1
  if (c.lap==lap and max_lap>lap) drop_wrench()
  lap=min(max_lap,max(lap,c.lap+1))
 	c.lap_time=cur_time
 	c.can_lap=false
  c.wpc+=1
  if (not last_lap and c.lap==max_lap-1) last_lap=true last_lap_timer=60 
  if not c.finished and c.lap==max_lap then
   add(finished,c.i)
   c.finished=true
   scores[c.i]+=4-#finished
   --c.ai=true
   race_over=true
   race_over_timer=180
  end
 end
 return c.lap>=max_lap and 1 or 0
end


function drive(c)
	local wanted_dir=unit(minus(waypoints[c.waypoint],c))
	local d=dot(c.dir,wanted_dir)
 if d<0.995 then
 	local side={x=-c.dir.y, y=c.dir.x}
  -- if dot(side,wanted_dir)<0 then
	 -- 	turn(c,-turn_factor)
	 -- else
	 -- 	turn(c,turn_factor)
	 -- end
  turn(c,dot(side,wanted_dir)<0 and -turn_factor or turn_factor)
	end
	if (d>0.75 or c.speed<1) accelerate(c,acceleration)
end


function _update()
 cur_screen.update()
end


function print_outlined(t,x,y,c,oc)
	for i=x-1,x+1 do
	 for j=y-1,y+1 do
	  print(t,i,j,oc)
	 end
	end
 print(t,x,y,c)
end


function draw_tree(t)
 spr(t.c,t.x+t.o,t.y-8,t.w,2)
end


function draw_tree_shadow(t)
 spr(t.s,t.x+t.so,t.y+8,t.w,1)
end


function draw_tree_shadow_on_car(t)
 for i=1,4 do
  local c=cars[i]
--  if t.x-4<=c.x and c.x<=t.x+4 and t.y-4<=c.y and c.y<=t.y+4 then
--if true then
   pal(1,car_colors_shadow[i])
   clip(c.x+2,c.y+2,4,4)
--   spr(46,t.x-1,t.y+5,2,1)
   spr(t.s,t.x+t.so-1,t.y+5,t.w,1)
--  end
 end
end


function join(i)
 playing[i]=true set_screen(join_screen)
end


start_screen=
{
 init=function()
  -- timer=0
  demo_timer=150
--  for i=1,4 do
--   playing[i]=false
--  end
  playing={false,false,false,false}
  init_victory()
 end,

 update=function()
  demo_timer-=1
  if (demo_timer<=0) set_screen(demo_screen) return
  -- timer+=1
  update_victory()
  for i=1,4 do
--   if (btnp(4,i-1)) playing[i]=true set_screen(join_screen)
   if (btnp(4,i-1)) join(i)
  end
 end,

 draw=function()
  cls()

  map(0,30,0,16,16,2)
  map(16,30,0,32,16,2)
  map(32,30,0,48,16,2)
  map(48,30,0,64,16,2)
  map(64,30,0,80,16,2)
  map(80,30,0,96,16,2)

  print("press button to start",22,112,demo_timer)
  
  draw_victory()
 end
}


join_screen=
{
 init=function()
  timer=150
  scores={0,0,0,0}
  maps_done=0
  victory=false
  -- players={}
  -- for i=1,4 do
  --  add(players,create_player())
  -- end
  players={create_player(),create_player(),create_player(),create_player()}
 end,

 update=function()
  timer-=1
  local nb_playing=0
  for i=1,4 do
   if btnp(4,i-1) then
    if playing[i] then
     timer=max(0,timer-30)
    else
     playing[i]=true
     timer=150
    end
   end
   nb_playing+=(playing[i] and 1 or 0)
  end
  if (nb_playing==4) timer=0
  if (timer==0) set_screen(options_screen)
 end,

 draw=function()
  my_cls(13)
  for i=1,4 do
   local x,y=draw_player_corner(i)
--   local y=32+i*16
   x+=16
   print_outlined("player "..i,x,y+24,car_colors[i],0)
   y+=40
   if playing[i] then
    print_outlined(" ready!",x,y,car_colors[i],0)
   else
    print_outlined(" join?",x+2,y,car_colors_shadow[i],0)
   end
  end
  print_outlined(flr(timer/30)+1,62,62,7,0)
 end
}


-- circuit_screen=
-- {
--  init=function()
--  end,

--  update=function()
--   for i=1,4 do
--    if (btnp(4,i-1)) set_screen(garage_screen) --set_screen(game_screen)
--   end
--  end,

--  draw=function()
--   cls()
--   draw_all_circuits()
--  end
--  }

function my_cls(c)
  rectfill(0,0,127,127,c)
end

function draw_opt_go(o,sel)
 print_outlined(o.s,54,option_y+10,sel and 10 or 6)
end

function draw_opt(o,sel)
 local option_x=32
 print_outlined(o.s,option_x,option_y,sel and 10 or 6)
 if (sel) spr(48,option_x-8,option_y+option_l,1,1,true) spr(48,94,option_y+option_r)
end

function draw_opt_n(o,sel)
 draw_opt(o,sel)
 -- local value_x=90
 -- if (o.val>9) value_x-=4
 -- local value_x=(o.val>9) and 86 or 90
 print_outlined(o.val,(o.val>9) and 86 or 90,option_y,sel and 10 or 6)
 option_y+=10
end

function draw_opt_b(o,sel)
 draw_opt(o,sel)
 -- local value_x=90
 -- spr(o.val and 159 or 143,value_x-1,option_y)
 spr(o.val and 159 or 143,89,option_y)
 option_y+=10
end

function set_n(o,inc)
 o.val+=inc
 if (o.val>o.max) o.val=1
 if (o.val<1) o.val=o.max
end

function set_b(o)
 o.val=not o.val
end

function set_go()
 difficulty=options[1].val
 max_lap=options[2].val
 nb_maps=options[3].val
 -- reverse=options[4].val
 -- rnd_order=options[5].val
 -- tracks random order
 local all_circuits={}
 for i=0,15 do
  add(all_circuits,i)
 end
 circuits={}
 for i=0,nb_maps-1 do
  local c=all_circuits[flr_rnd(#all_circuits)+1]
  circuits[i]=c
  del(all_circuits,c)
 end
 cur_map=circuits[0]
 reverse=(flr_rnd(2)==1)
-- cur_map=4
-- reverse=true
 set_screen(game_screen)
end

options={
 {s="difficulty",val=2,max=3,set=set_n,d=draw_opt_n},
 {s="laps nb",val=4,max=12,set=set_n,d=draw_opt_n},
 {s="circuits nb",val=4,max=16,set=set_n,d=draw_opt_n},
 -- {s="reverse",val=false,set=set_b,d=draw_opt_b},
 -- {s="random order",val=false,set=set_b,d=draw_opt_b},
 {s="start",val="",set=set_go,d=draw_opt_go}
}

options_screen=
{
 init=function()
  -- cur_time=0
  -- selected=#options
  selected=1
 end,

 update=function()
  -- cur_time+=1
  option_l=0
  option_r=0
  local o=options[selected]
  if (btnp(0)) o:set(-1) option_l+=1
  if (btnp(1)) o:set(1) option_r+=1
  if (btnp(2)) selected-=1
  if (btnp(3)) selected+=1
  if (selected<1) selected=#options
  if (selected>#options) selected=1
--  selected=max(1,min(selected,#options))
  if (btnp(4) and selected==#options) set_go()
 end,

 draw=function()
  my_cls(13)
  print_outlined("settings",48,28,7)
  option_y=48
  for o in all(options) do
   o:d(o==options[selected])
  end
  -- if (cur_time>10) print_outlined("press a to continue",26,100,7)
  -- if (cur_time>20) cur_time=0
 end 
}


  -- local o=options[selected]
  -- if (btnp(0)) o:set(-1)
  -- if (btnp(1)) o:set(1)
  -- if (btnp(2)) selected-=1
  -- if (btnp(3)) selected+=1
  -- if (selected<1) selected=#options
  -- if (selected>#options) selected=1


--skills={"handling","acceleration","max speed","  continue"}
skills={"handling","acceleration","max speed"}

function draw_skill(x,y,i,p)
 local c=p.selected_skill==i and 9 or 5
 if (p.nb_wrenches>0) c+=1
 print_outlined(skills[i],x,y+i/4,c)
 if (i==4) return
 for w=0,4 do
  spr(w<p.skills[i] and 35 or 36,x+w*10,y+6)
 end
end


function draw_player_corner(i)
 local x=((i-1)%2)*64
 local y=flr((i-1)/2)*64
 rect(x,y,x+63,y+63,car_colors[i])
 return x,y
end


function draw_garage(i)
 local x,y=draw_player_corner(i)
 local p=players[i]
 skills[4]=timer>20 and "  continue" or "   "..p.nb_wrenches.." left"
 if (p.nb_wrenches==0) skills[4]="    done"
 for s=1,#skills do
  draw_skill(x+8,y+5,s,p)
  y+=16
 end
end


function spend(p)
 p.skills[p.selected_skill]+=1
 p.nb_wrenches-=1
end


garage_screen=
{
 init=function()
  done={}
  for i=1,4 do
   players[i].selected_skill=1
   done[i]=false
  end
 end,

 update=function()
  timer+=1
  if (timer>40) timer=0
  local nb_done=0
  for i=1,4 do
   local p=players[i]
   local all_maxed=p.handling==5 and p.acceleration==5 and p.max_speed==5
   if (p.nb_wrenches==0 or all_maxed) done[i]=true

   if done[i] then
    nb_done+=1
   elseif playing[i] then
    if (btnp(2,i-1)) p.selected_skill-=1
    if (btnp(3,i-1)) p.selected_skill+=1
    if (p.selected_skill<1) p.selected_skill=#skills
    if (p.selected_skill>#skills) p.selected_skill=1
    if btnp(4,i-1) then
     if p.selected_skill==#skills then
      done[i]=true
     elseif p.nb_wrenches>0 then
      spend(p)
     end
    end
   else
    p.selected_skill=flr_rnd(3)+1
    spend(p)
   end
  end
  if nb_done==4 then
   race_over_timer+=1
   if (race_over_timer>90) set_screen(game_screen)
  end
 end,

 draw=function()
  my_cls(13)
--  print_outlined("settings",48,20,7)
  for i=1,4 do
   draw_garage(i)
  end
 end 
}


function update_confetti(c)
 c.x+=(rnd(10)-2)/10
 if (c.x>127) c.x=-7
 c.y+=rnd(10)/5
 if (c.y>127) c.y=-7
-- c.f=rnd(10)>5
 c.f=flr_rnd(3)+16
end


function draw_confetti(c)
 pal(7,c.c)
-- spr(48,c.x,c.y,1,1,c.f)
 spr(c.f,c.x,c.y)
end


function init_victory()
 victory=true
 confetti={}
 for i=1,50 do
  add(confetti,{x=rnd(127),y=-rnd(127),f=flr_rnd(2),c=flr_rnd(9)+6})
 end
end


function update_victory()
 foreach(confetti,update_confetti)
end


function draw_victory()
 palt(13,true)
 foreach(confetti,draw_confetti)
 pal()
end


function draw_race_result()
 print_outlined("race over",46,40,7) 
 cnt={"1st","2nd","3rd","4th"}
 for i=1,#finished do
  print_outlined(cnt[i], 38, 40+10*i,7)
  print_outlined("p"..finished[i], 54, 40+10*i,car_colors[finished[i]])
  local score=4-i
  print_outlined("+"..score.." = "..scores[finished[i]], 66, 40+10*i,7)
 end
end


function draw_champ_result()
 bubble_sort(champ,score_comp)
 print_outlined("overall",48,40,7) 
 for i=1,4 do
  print_outlined(cnt[i], 38, 40+10*i,7)
  print_outlined("p"..champ[i], 54, 40+10*i,car_colors[champ[i]])
  print_outlined(scores[champ[i]].." pts", 66, 40+10*i,7)
 end
end

function car_shadows_state()
  palt(0,false)
  palt(13,true)
  for i=0,15 do 
   pal(i, 1)
  end
end

game_screen=
{
 init=function()
  cur_time=0
  timer=150
  race_over_timer=0
  read_map()
  cars={}
  car_order={}
  for i=1,4 do
   add(cars, turn(create_car(i),0))
   cars[i].ai=not playing[i]
   add(car_order,i)
  end
 end,

 draw=function()
  pal()

  my_cls(cur_scenery.color)

  draw_map(true)

  car_shadows_state()
  foreach(placeholders,draw_car_shadow)
  foreach(wrenches,draw_car_shadow)
  foreach(cars, draw_car_shadow)
  -- for c in all(cars) do
  --  spr(c.s,c.x+1,c.y+1,1,1,c.f)
  -- end

  pal()

  foreach(skidmarks,draw_skidmarks)
  foreach(skidmarks_bridge,draw_skidmarks)

  pal(11,0) --oil
 -- palt()
  palt(13,true)
  palt(0,false)
  foreach(placeholders,draw_placeholder)
  foreach(wrenches,draw_placeholder)
  
--  palt(13,true)
  foreach(trees,draw_tree_shadow)

  pal() --oil
  foreach(smokes, draw_smoke)

  draw_cars()

  pal()
 -- palt()
   palt(13,true)
  foreach(trees,draw_tree)
  foreach(trees,draw_tree_shadow_on_car)
  clip()

  -- foreach(smokes, draw_smoke)

--  pal()

  if (last_lap and last_lap_timer>0) last_lap_timer-=1 print_outlined("last lap",50,60,7)
  if race_over then
   if (victory) draw_victory()
   race_over_timer-=1
   if race_over_timer>90 then 
    draw_race_result()
    if (#finished<3) race_over_timer+=1
   else
    draw_champ_result()
--if (race_over_timer<2) race_over_timer=180 --debug
   end
  end

--  print("car_order[i] - cars[i].order",0,0,7)
--  for i=1,4 do print(cars[i].slipping,0,7*i,1) end

--  print_outlined("lap"..lap.."/"..max_lap,0,122,7,0)
  print_outlined("t:"..maps_done.."/"..nb_maps.." l:"..lap.."/"..max_lap,0,122,7,0)

  for i=1,4 do
   local c=cars[car_order[i]]
   c.score_pos=((16*(i-1)+60)+c.score_prev)/2
   c.score_prev=c.score_pos
   -- print_outlined("p"..c.i..":"..c.lap,c.score_pos,122,car_colors[c.i],c.ai and 5 or 0)
   print_outlined("l:"..c.lap,c.score_pos,122,car_colors[c.i],c.ai and 5 or 0)
  end

  -- debug bridge
 -- local sz=bridge[cur_map]
 -- if (sz!=nil) rect(sz.shadow_startx, sz.shadow_starty, sz.shadow_startx+sz.shadow_width, sz.shadow_starty+sz.shadow_height, 10)
 print(outout,0,0,7)

  if (timer>0) print_outlined(flr(timer/30)+1,62,60,7,0)

  if (race_over_timer<0) print_outlined("press button to continue",16,100,7,0)

--  if (pause) print_outlined("pause",54,60,7,0)
 end,

 update=function()
  if (timer>0) timer-=1 return
  cur_time+=1
  local nb_finished=0
  for i=0,3 do
   local c=cars[i+1]
   nb_finished+=check_waypoint(c)
   if not c.ai then
    if (btn(0,i)) turn(c,-turn_factor)
    if (btn(1,i)) turn(c,turn_factor)
    if btn(2,i) or btn(4,i) then
     accelerate(c,acceleration)
     if (race_over_timer<0) set_screen(start_screen)
    end
    if (btn(3,i)) accelerate(c,deceleration)
    if (btnp(5,i)) pause=true
   else
    drive(c)
   end
   car_physics(c)
   foreach(smokes, update_smoke)
  end

  bubble_sort(car_order,car_comp)

  if victory then
   update_victory()
--   if (race_over_timer<0) set_screen(start_screen)
  elseif nb_finished>=3 and race_over_timer<=0 then
   maps_done+=1
   if maps_done==nb_maps then
    init_victory()
    race_over_timer+=180
   else
    cur_map=circuits[maps_done]
    reverse=(flr_rnd(2)==1)
    set_screen(garage_screen)
   end
  end
 end,
}


demo_screen=
{
 init=function()
  demo_timer=300
  cur_map=flr_rnd(16)
  game_screen.init()
  timer=0
  victory=false
 end,

 update=function()
  demo_timer-=1
  if (demo_timer<=0) set_screen(start_screen) return
  game_screen.update()
  for i=0,3 do
   if (btnp(4,i)) join(i+1)
   end
 end,

 draw=function()
  game_screen.draw()
  print_outlined("demo",56,60,7)
  print_outlined("press a to start",32,112,demo_timer)
 end
}


result_screen=
{
 init=function()
 end,

 update=function()
 end,

 draw=function()

 end
}


function _draw()
 screen_transition()

 --perf
 --line(0,126,127*(stat(1)-1),127,8)
 --line(0,127,127*stat(1),127,9)
end
__gfx__
dd8888dddd8888dddd08888ddddd88ddddd88dddddd88dddddddddddddd88ddddddd88dddd88ddddd8888ddddd8888dddd8888dd45aaaaaaaaaaaa5400000000
dd8888ddd08888dddd88888ddd88888ddd88888ddd8888ddddd888ddddf888ddd888888dd88888ddd88880dddd88880ddd8888dd45aaaaaaaaaaaa5400077000
d0f88f0dd888f80ddd88880dd8888888df888f88df888888ddf888fd88f888fd88f8888d88f8888dd08f88ddd08f888dd088880d45aaaaaaaaaaaa54007d6500
d0ffff0ddffff80dd8ff8f0ddff8f8808ff8f8888ff8f88888f888f888ff88f888ff88f808f8888dd08f888dd088888dd088880d45aaaaaaaaaaaa5400764d00
dd8ff8ddd8ff88ddd8fff8dd88fff80088ff880288ff888288fff8888888f8888088ff88008f88f8dd88ff8ddd88ff8ddd8ff8dd45aaaaaaaaaaaa54006d5d00
dd8888dd08888ddd288888dd888888dd8888800d888880028888888880088888d0088888dd888f88dd888882ddd88880dd8888dd45aaaaaaaaaaaa540766ddd0
d088880d088880dd028880dd88880ddd8808dddd8008d00d80088002d00d8002dddd8082ddd08882dd088820dd088880d088880d45aaaaaaaaaaaa540766ddd0
d022220dd22280ddd22200ddd8800dddd00dddddd00dddddd00dd00dddddd00dddddd00dddd0082ddd00222ddd08222dd022220d45aaaaaaaaaaaa54006d5500
dddddddddddddddddddddddd1f1411f155555555f1f11f1455555555ddd00ddd00055000dddddddd6dddddddddddddddbb33dddddddddddddddddddddddddddd
ddd777dddddddddddddddddd2a1cd16155555555e191131855555555dd0550dd00555500dddddddd7dddddddddbbbddb33dddddddddddddddddbbbdddddddddd
dd77777dddd777ddddddddddf1f11f1f55555555141141f155555555d000000d05555550dddddddd7ddddddddb333bd3d3bbddddddddbbbdddb3333ddddd7ddd
dd77777ddd77777dddd777dd65826a94555555551d116171555555550550055055555555ddddddd765ddddddd33dd3b3bb33bbddddbb333b3b3d333ddddd7ddd
dd77777dddd777dddddddddd555555555555555511141411555555550000000055555555ddddddd766ddddddddddd33333dd33bddb33dd33333dddddddd76ddd
ddd777dddddddddddddddddd5555555555555555211cd611555555550000000055555555dddddd76665ddddddddd3bb4b3dddddddddddd3b4bb3ddddddd766dd
dddddddddddddddddddddddd5555555500000000f1411f1f555555550550055055555555dddddd7b636dddddddd3b3393b3dddddddddd3b3933b3ddddd7666dd
dddddddddddddddddddddddd11111111000000006582e194555555550000000055555555ddddd766b656dddddddb3d4dd3b3dddddddd3b3d4dd3bdddd66b636d
11111111dddddddddddddddddddddddddddddddd00000000000000000000000055555555dddd766b6365ddddddd3dd9dd333dddddddd3b3d9dd3bddd766b6363
11111111dddddddddddddddddddddddddddddddd00077000000550000550055055555555dddbb636b636bbdddddddd4ddd3bdddddddddbdd4dd3ddddb636b636
11111111ddbbbbddddccccddaa9ddaa9550dd550007d6500005555000000000055555555dddddbb6b6635ddddddddd9ddddddddddddddddd9ddddddddbb6b663
11111111dbbbbbbddccccccddaaaaa9dd555550d00764d00005555000000000055555555ddddddbb3b36ddddddddd44ddddddddddddddddd44ddddddddbb3b3d
11111111dbbbbbdddcccccddd999994dd555550d006d5d00005555000550055055555555dddddbddb5d3bdddddddd9ddddddddddddddddddd9dddddddbd4bdd3
11111111ddbbbdddddcccddd994dd994550dd5500766ddd0055555500000000055555555dddddddd45dddddddddd44ddddddddddddddddddd44dddddddd45ddd
11111111dddddddddddddddddddddddddddddddd0766ddd0055555500000000055555555dddddddd45dddddddddd99ddddddddddddddddddd99dddddddd45ddd
11111111dddddddddddddddddddddddddddddddd006d5500005555000550055055555555ddddddd4455ddddddddd44ddddddddddddddddddd44ddddddd4455dd
0007000000000000dd08dddddd80ddddd8880ddddd8880dddddd88dd0000000055555555ddddddd111dd111dddddd11dddddd1dddd11dddddddddddd111dd11d
0007700000000000d808dddd8880ddddd8880ddddd8880ddddd888800550055055555555dddddddd111111dddddddd11dddd11ddddd11ddddd11ddddd111111d
0007770000000000d880dddd88d0dddddddd0ddddddd0dddddddd80d0000000055555555ddddddd1111111ddddddddd11d111dddddddd1dd111ddddd1111111d
0007700000000000ddd0dddddddd0dddddd0dddddddd0dddddddd0dd0000000055555555ddddddd1111111dddddd11dd111dddddd11ddd11dddddddd1111111d
00070000000ff000dddd0ddddddd0dddddd0ddddddd0dddddddd0ddd0550055055555555dddddd111111111dddddd11111111dddddd111111dddddddd1111111
0000000000ffff00dddd0ddddddd0dddddd0ddddddd0ddddddd0dddd0000000055555555dddddddddd11111dddddddddd1dd1111dddddd1dd111dddddddd1111
00000000005ff500dddddddddddddddddddddddddddddddddddddddd0000000055555555dddddddddddd111dddddddd11d1dddddddd111dddddddddddddddd11
0000000000055000ddddddddddddddddddddddddddddddddddddddddd00dd00d05500550dddddddddddddd11ddddd11dddd11ddddddddddddddddddddddddddd
0000000440000000000000000000004444000000000000000000000000000000ddddddddddddddddddddddddddddddddeeeeeeee11111111ddd00ddd00055000
0000004554000000000000000000445555440000000000000000000000000000dddddddddddddddddddddddddddddddd3333333311111111dd0550dd00555500
0000045dd540000000000000004455dddd554400000000000000000000000000ddddddd55ddddddddddddddddddddddd1111111111111111dd0000dd00555500
000045dddd540000000000004455dddddddd5544000000000000000000000000ddddddd55dddddddddddddd55ddddddd1111111111111111d000000d05555550
00045dddddd540000000004455dddddddddddd55440000000000000440000000dddddd5445dddddddddddd5445dddddd11111111111111110550055055555555
0045dddddddd540000004455dddddddddddddddd554400000000000440000000dddddd5445dddddddddddd5445dddddd11111111111111110000000055555555
045dddddddddd540004455dddddddddddddddddddd5544000000004554000000dddddd5445dddddddddddd5445dddddd11111111333333330000000055555555
45dddddddddddd544455dddddddddddddddddddddddd55440000445dd5440000dddddd5445dddddddddddd5445dddddd11111111eeeeeeeed00dd00d05555550
45dddddddddddd544455dddddddddddddddddddddddd55440000445dd5440000dddddd5445dddddddddddd5445dddddde31111111111113ed00dd00d05500550
045dddddddddd540004455dddddddddddddddddddd5544000000004554000000dddddd5445dddddddddddd5445dddddde31111111111113e0550055055555555
0045dddddddd540000004455dddddddddddddddd554400000000000440000000dddddd5445dddddddddddd5445dddddde31111111111113e0000000055555555
00045dddddd540000000004455dddddddddddd55440000000000000440000000dddddd5445dddddddddddd5445dddddde31111111111113e0000000055555555
000045dddd540000000000004455dddddddd5544000000000000000000000000ddddddd55dddddddddddddd55ddddddde31111111111113e0550055055555555
0000045dd540000000000000004455dddd554400000000000000000000000000ddddddd55ddddddddddddddddddddddde31111111111113e0000000055555555
0000004554000000000000000000445555440000000000000000000000000000dddddddddddddddddddddddddddddddde31111111111113e0000000055555555
0000000440000000000000000000004444000000000000000000000000000000dddddddddddddddddddddddddddddddde31111111111113ed00dd00d05500550
0000000000000000000000044000000045dddddddddddd5444444444dddddddddddddddddddddddddddd55444455dddd4444444499dddd9945dddd9999dddd54
0000004444000000000000044000000045dddddddddddd5455555555dddddddddddddddddddddddddd554400004455dd555555559999dddd4599dddd9999dd54
00004455554400000000004554000000045dddddddddd540dddddddddddddddddddddddddddddddd5544000000004455dd9999dddd9999dd459999dddd999954
000455dddd5540000000004554000000045dddddddddd540dddddddddddddddddddddddddddddddd4400000000000044dddd9999dddd999945dd9999dddd9954
0045dddddddd54000000045dd54000000045dddddddd5400dddddddddddddddddddddddddddddddd440000000000004499dddd9999dddd9945dddd9999dddd54
0045dddddddd54000000045dd54000000045dddddddd5400dddddddddddddddddddddddddddddddd55440000000044559999dddd9999dddd4599dddd9999dd54
045dddddddddd540000045dddd54000000045dddddd54000dddddddd55555555dddd55555555dddddd554400004455dddd9999dd55555555459999dddd999954
045dddddddddd540000045dddd54000000045dddddd54000dddddddd44444444dd554444444455dddddd55444455dddddddd99994444444445dd9999dddd9954
045dddddddddd54000045dddddd54000000045dddd54000045dddddddddddd54dd554444444455dde311111de311dddd0000000000000000ddffffdd00000000
045dddddddddd54000045dddddd54000000045dddd54000045dddddddddddd54dddd55555555dddde311111de311dddd0000000000000000dffff55d00000000
0045dddddddd54000045dddddddd54000000045dd540000045dddddddddddd54dddddddddddddddde311111de311dddd0005500000005000fffff55505555550
0045dddddddd54000045dddddddd54000000045dd540000045dddddddddddd54dddddddddddddddde31111dde31ddddd0005500000055000ffff555505555550
000455dddd554000045dddddddddd540000000455400000045dddddddddddd54dddddddddddddddde31111dde31ddddd0055550000555000df55555100555500
0000445555440000045dddddddddd540000000455400000045dddddddddddd54dddddddddddddddde31111dde31ddddd0005500000055000d111111100000000
000000444400000045dddddddddddd54000000044000000045dddddddddddd54dddddddddddddddde3111ddde3dddddd0000000000000000dd11111100000000
000000000000000045dddddddddddd54000000044000000045dddddddddddd54dddddddddddddddde3111ddde3dddddd0000000000000000dddd111d00000000
dddddddd0000000680000000000000000000006688000000000000000000000000000000dddddddddddddddddddddddddddddddd22dd22dd1111111144444444
dddddddd000000886600000000000000000088dddd660000000000000000000000000000dddddddddddddddddddddddddddddddd111111111111111155555555
dddddddd0000066dd8800000000000000066dddddddd8800000000000000000000000000ddddddd68ddddddddddddddddddddddd1111111111111111aaaaaaaa
dddddddd000088dddd6600000000000088dddddddddddd66000000000000000000000000ddddddd86ddddddddddddddddddddddd1111111111111111aaaaaaaa
dddddddd00066dddddd8800000000066dddddddddddddddd880000000000000860000000dddddd6688ddddddddddddd68ddddddd1111111111111111aaaaaaaa
dddddddd0088dddddddd6600000088dddddddddddddddddddd6600000000000680000000dddddd8866dddddddddddd8866dddddd1111111111111111aaaaaaaa
dddddddd066dddddddddd8800066dddddddddddddddddddddddd88000000008866000000dddddd6688dddddddddddd6688dddddd1111111111111111aaaaaaaa
dddddddd88dddddddddddd6688dddddddddddddddddddddddddddd660000866dd8860000dddddd8866dddddddddddd8866dddddd11111111dd22dd22aaaaaaaa
1111111166dddddddddddd8866dddddddddddddddddddddddddddd880000688dd6680000dddddd6688dddddddddddd6688dddddd22111111111111ddaaaaaaaa
11111111088dddddddddd6600088dddddddddddddddddddddddd66000000006688000000dddddd8866dddddddddddd8866dddddddd11111111111122aaaaaaaa
111111110066dddddddd8800000066dddddddddddddddddddd8800000000000860000000dddddd6688dddddddddddd6688dddddd22111111111111ddaaaaaaaa
1111111100088dddddd6600000000088dddddddddddddddd660000000000000680000000dddddd8866ddddddddddddd86ddddddddd11111111111122aaaaaaaa
11111111000066dddd8800000000000066dddddddddddd88000000000000000000000000ddddddd68ddddddddddddddddddddddd22111111111111ddaaaaaaaa
111111110000088dd6600000000000000088dddddddd6600000000000000000000000000ddddddd86ddddddddddddddddddddddddd11111111111122aaaaaaaa
11111111000000668800000000000000000066dddd880000000000000000000000000000dddddddddddddddddddddddddddddddd22111111111111dd55555555
111111110000000860000000000000000000008866000000000000000000000000000000dddddddddddddddddddddddddddddddddd1111111111112244444444
000066dd0000000000000000000000068000000066dddddddddddd8888668866dddddddddddddddddddddddddddddd8866dddddd00066dddddddddddaaaaaaaa
0000088d0000006688000000000000086000000088dddddddddddd66dddddddddddddddddddddddddddddddddddd66000088dddd0088ddddddddddddaaaaaaaa
00000066000088dddd6600000000006688000000066dddddddddd880dddddddddddddddddddddddddddddddddd880000000066dd066dddddddddddddaaaaaaaa
0000000800066dddddd880000000008866000000088dddddddddd660dddddddddddddddddddddddddddddddd660000000000008888ddddddddddddddaaaaaaaa
000000000088dddddddd66000000066dd88000000066dddddddd8800dddddddddddddddddddddddddddddddd8800000000000066dddddddddddddd88aaaaaaaa
000000000066dddddddd88000000088dd66000000088dddddddd6600dddddddddddddddddddddddddddddddddd660000000088ddddddddddddddd660aaaaaaaa
00000000088dddddddddd660000066dddd88000000066dddddd88000dddddddddddddddddddddddddddddddddddd88000066dddddddddddddddd8800aaaaaaaa
00000000066dddddddddd880000088dddd66000000088dddddd66000dddddddd66886688dddd66886688dddddddddd6688ddddddddddddddddd66000aaaaaaaa
00000000088dddddddddd66000066dddddd88000000066dddd88000088dddddddddddd66dddd88668866dddd8866886699dddd9988dddd9999dddd6699dddd99
00000000066dddddddddd88000088dddddd66000000088dddd66000066dddddddddddd88dddddddddddddddd9999dddd9999dddd6699dddd9999dd889999dddd
000000000088dddddddd66000066dddddddd88000000066dd880000088dddddddddddd66dddddddddddddddddd9999dddd9999dd889999dddd999966dd9999dd
000000000066dddddddd88000088dddddddd66000000088dd660000066dddddddddddd88dddddddddddddddddddd9999dddd999966dd9999dddd9988dddd9999
0000000800088dddddd66000066dddddddddd880000000668800000088dddddddddddd66dddddddddddddddd99dddd9999dddd9988dddd9999dddd6699dddd99
00000066000066dddd880000088dddddddddd660000000886600000066dddddddddddd88dddddddddddddddd9999dddd9999dddd6699dddd9999dd889999dddd
0000088d000000886600000066dddddddddddd88000000068000000088dddddddddddd66dddddddddddddddddd9999dddd9999dd889999dddd999966dd9999dd
000066dd000000000000000088dddddddddddd66000000086000000066dddddddddddd88dddddddddddddddddddd99996688668866dd9999dddd9988dddd9999
0202020303030303030303030302020202020203030303030303030303020202020202030303030303030303030202020808770067088b00007b087700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020303030303030303030303030303020203030303030303030303030303030202030303030303030303030303030302080877006709e90000d9097700000000
00666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02030303030303030303030303030302020303030303030303030303030303020203030303030303030303030303030208080800000000000000000000000000
00080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030008080800080808080808080808080808
00080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030008080800767676080808080808767676
00080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030302020303020202030302020302020203020203030203020302020203020203030303030303030008080800000000000000000000000000
00080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030302000203020303030203030302030303020002030203020302030303020002030303030303030008080800670877006666660008087700
00080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030302020303020203030302030302020303020203030203020302020303020002030303030303030008080800670877007676760008087700
00080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030302030203020303030303020302030303020302030203020302030303020002030303030303030008087700000000000000000008080800
00080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030302030203020202030202030302020203020302030302030302020203020203030303030303030008087700000000006666660008080800
00670808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000007676760076767600
00670808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888dd
8887888d8877e88d8877788d8878888d8877788d88e7788d8877788d8877788d8877788d8788788d8878788d87877e8d8787778d8787888d8787778d878e778d
8887288d888e728d8887728d8872788d887e228d8872228d8882728d887e728d8877728d8727278d8872728d8728e72d8728772d8727278d8727e22d8727222d
8887288d887e228d888e728d8877728d888e788d8877788d888ee28d8877728d8882728d8727272d8872728d8727e22d8728e72d8727772d8728e78d8727778d
8887288d8877788d8877e28d8882728d8877e28d8877728d8887228d8877728d8877e28d8728782d8872728d8727778d87277e2d8728272d87277e2d8727772d
8888288d8882228d8882228d8888828d8882228d8882228d8888288d8882228d8882228d8828828d8882828d8828222d8828222d8828882d8828222d8828222d
d88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888ddd88888dd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
__gff__
000100000000000000000000002a2a000000000040004000400000000000000000404000000000004000000000000000000400000000000040000000000000002828282828282828282828282828004028282828282828282828282828280040282828282828282828282828a8a8a8a828282828282828282828282810104040
2020200020200000002020202020202a2020200020200000002020202020202a0020200000202020202020202020202a0020202020000020202020a0a0a0a0a000000000000000000000050000a438d8000000000000000000072d315b06f80a0000000000000000000531384303380a01010101010101010101010101010101
__map__
a1a7a7a7a7a7a7a7bbbba7a7a7a7a7a200000000007c00007d0000007c0000006066666666616066666666666666666100000000a1a7a7a7a7a7a7a200000000a1a7a7a7a7a7a20000a1a7a7a7a7a7a200a1a7a7a785868384a7a7a7a7a7a200a1a7a7a7a7a7a7a7bbbba7a7a7a7a7a2a1a7a7a7a7a7a7bbbba7a7a7a7a7a7a2
b780f0a9a8a8a8a8bcbca8a8aaf780b8a1a7a7a7a7a7a7a7bbbba7a7a7a7a7a27680f18080777680f667676767f7807700000000b780f4a8a8f580b8007c0000b780f5a880f6b8007cb780f9a880fab800b7f88080f78080fa80a8a8fb80b800b780f0a9a8a8a8a8bcbca8a8aaf980b8b780f0a9a8a8a8bcbca8a8a8a880fbb8
b78089980000001616163100978a80b8b780f0a9a8a8a8a8bcbca8a8aa80fab876804849807776807700007c0076807700007c00b780b87c00b780b8007d0000b780b84fb780b87d00b780b84fb780b800b780b8ac80808080ab004fb780b800b780899800000000317c0000978a80b8b7808998007c007f3100007c00b780b8
b780b87d00000014141400007fb780b8b78089987d000000315f004f978a80b87680777680777680776066666680807700000000b780b8007db780b800007d00b780b800b780f7a7a780f8b800b780b800b7f980808080aa8080a200b780b800b780b87d007c0000000000007cb780b8b780b87d0000007d0000a1a7a78080b8
b780b8007c0000000000000000b780b8b780998800000000000000007db780b876807776f2777680770dafaf6767677100007d00b780b80000b780b8007c0000b780b87cb1a8a8a8a8a8a8b25fb780b800b1a8a8a89596978c80b800b780b800b780b88384a7a7a20000007f00b780b8b780b800000000000000b7fa80676771
b7f1b8007d000000007c000000b780b8b780f1b9a7a7a7a7a7a7a7a200b780b87680777680777680f576f8774c666661007c0000b780b8007fb780b800000000b7f480a7a7a7a2007ca1a7a7a7fb80b8b084a7a7a7a7a7a780f6b800b780b800b780f180808080b800007d0000b780b8b7f1b86066668fa7a7a2b78080666661
b780b800007c007d0000000000b780b8b1a8a8a8a8a8a8a8a880f2b800b780b87680777680777067677680774d80807700000000b780b80000b780b800000000b1a8a8a8f380b87d00b78080a8a8a8b2b38080a8a8a8a8a8a8a8b200b7808082b7808080958cf2b800a1a7a7a7f880b8b780b876f5809f80f4b8b1a8a88080b8
b780b87c0000008384a7a7a200b7f6b8007d000000005f5f5fb780b87cb780b87680777680777c000076807720768077004f5f4fb7f3b83100b7f6b84f5f5f0000000000b780b80031b7fcb800000000b7f5b85f7d007c000000007d918080b8b1a8959600b780b800b78080a8a8a8b2b780b876807790b780b800007db7f9b8
b780b87d0083848080f380b800b780b8000000000000000000b780b800b780b87680777680f36666667680774c80f477a1a7a78f6666666c6c6666668fa7a7a26066668f6666666c6c6666668f666661a5808085868384a7a7a7a7a200b7fcb85f5f7c83848080b87cb7f7b87d5f5f00b780b876807790b780b8a1a7a78080b8
b780b88384808080958c80b800b780b8a1a7a7a7a78586838480f3b800b780b876807770676767676776f9774d676771b7f0809f6767676d6d6767679f80f9b87680f09f6767676d6d6767679fff8077a094808080808080a880f2b800b780b800838480f38080b200b78080a7a7a7a2b780f27680778d80f3b8b78080676771
b780f280808095967cb780b818b780b8b7f680a880f780808080959600b780b876808041007c7d00000dafaf66666661b780b8209d909e20209d909e20b780b8768077209d909e20209d909e207680770000ac8080f180ab7cb780b831b780b8a18080808095960000b1a8a8aaf680b8b1a8a87680778ea8a8b2b7f880666661
b78080809596000000b780b828b780b8b780b87dac80808080ab4f7d00b780b876808080410000007f70676767808077b780b87db780b80000b780b87cb780b876807700b780b80000b780b800768077b08480808080f480a780f3b800b780b8b780809596007f000000007d978c80b800000076807790000000b1a8a88080b8
b1a89596007d007c00b780b87db780b8b7f580a780f48080808085865fb780b8768077508041007c000031007d768077b780b87cb780b81800b780b87db780b8b780b87cb780b8007db780b85fb780b8b3808095969394a8a8a8a8b25fb780b8b780b800007d007c007c0000879c80b87c0000768077900000007c007db780b8
7c0000000000000000b780f4a7f580b8b1a8a8a8a895969394f88080a7f980b87680f0668080666666666c6c6680fa77b780f1a780f2b82800b780f7a780f8b8b780f1a780f2b87c00b780fda780feb8b780f0a7a7a7666c6c66a7a7a7fd80b8b780f4a7a7a7a7a7a7a7a7a7baf580b8007d007680f68fa7a7a7a7a7a780f7b8
000000000000000000b1a8a8a8a8a8b20000000000007c00009394a8a8a8a8b2706767676767676767676d6d67676771b1a8a8a8a8a8b23800b1a8a8a8a8a8b2b1a8a8a8a8a8b20000b1a8a8a8a8a8b2b1a8a8a8a8a8676d6d67a8a8a8a8a8b2b1a8a8a8a8a8a8a8a8a8a8a8a8a8a8b20000007067679fa8a8a8a8a8a8a8a8b2
a1a7a7a7a7a7a7a7a7a7a200000000000000000000406666666666666666666160666666666c6c66666666666666666100007f0018a1a7a7a7a7a7a7a7a7a200a1a7a7bbbba782000081a7a7a7a7a7a2a1a7a7a7a7a7a7a7a7a7a7a2000000007c008384a7a7a7a7a7a7a7a7a7a7a7a2a1a7a7a7a7a7a7a200a1a7a7a7a7a7a2
b780f6a9a8a8a8aaf580b8007c007d000000007d4080fb676767676767fc80777680f067676d6d676767fe8067808077007d000038b780f2a8a8a8a8f180b800b780f0bcbcff80828180fda8a8fc80b8b780fba8a8a8a8a8a8fc80b8007d00007f818080fca8a8a8a8a8a8a8a8fd80b8b780f9a9aaf880b87db7f480a8f580b8
b7808998007c00978a80b87d007f000060666666fa805100000000007d76807776807700007d31007c0050804176807700a1a7a7a7808080a7a7a27cb780b800b780b8315f9180fe808092004fb780b8a5808085868384a7a7808080a7a7a7a2a38080ae96000000007d000000b780b8b7808b98978c807700b780b87f7680b8
b780b87c7d00007db780b800007c000076f98067675100606666666666fd8077768077007c000000000000508080807700b780f7a880f68080f5b800b7f0b800b780b800007d91a8a8927c0000b780b8a09480808080f780a8808080a8f880b8b380fbb67d006066668f666661b780b8b780b80018b780f78f6666668ff680b8
b780b80000000000b780b80000000000768080666641007680fe67676767677176807700000000000000000050fd807700b780b800b780777680b800b780b800b780b87c00000000000000005fb780b8007cac80808080ab7d0daf0e20b780b8b780b80000007680f79f80f877b7feb8b780b80028b1a8a89f6767679fa8a8b2
b780b80060666666666666666666666170676767f880410daf0e20007d007c0076f1776066666666666641000076807700b780b87db7f38080f4b800b780b87db780f1a7a7a7a20000a1a7a7a7fb80b8b08480808080fa80a776fd778df980b8b780b8007c0076807720b78077b780b8b7809b8800000000009d909e00000000
b780b8007680f2676767676767f18077007d00005080f77680774c66666666617680777680f7676767f880417d76807700b780b800b1a8a8a8a8b24fbdbfbe00b1a8a8a880f2b80000b78080a8a8a8b2b3808095969394a8a87680778ea8a8b2b780faa7a7a77680778df98077bdbfbeb780fab9a785868384f380b800000000
b7f7b8000daf0e209d909e20200daf0e000000000050677680774d6767f6807776807776807720007c5080804176fc7700b780b80000000000000031bdbfbe00000000000daf0e0000b7fab800000000b7f6b85f7d007c00316ebf6f2000007db1a8a8a8a8a87680778ea8a871bdbfbeb1a8a8a88080808080809596007d0000
b780b80076807700b780b800007680770000007c0000316ebf6f207c007680777680770daf0e2000000076f97776807700b7f8b8006066666666617db7ffb80000000000768077007db780b87c000000a5808085868384a7a76ebf6f8da7a7a2a1a7a7a7a7a20daf0e285f5f31b780b80000007cac8080f280ab7d0000000000
b780b800b780b800b780b80000b780b8606666666666666ebf6f4c66617680777680f27680774c66666176807776807700b780b80076fc8080fb7700b780b800a1a7a7a77680778da7808080a7a7a7a2a0948080808080f2a87680778ef380b8b7f38080f4b8b780b828000000b780b8a1a7a7a780808080fb80a7a7a7a7a7a2
b780b87cb780f3a780f4b80018b780b87680f26767676776807720f37776807770676776f6774df380777680777680777cb780b8007680770daf0e4fb780b87cb780f5a87680778ea8f68080a8f780b87d00ac80808080ab7c7680777cb780b8b780b8b780b8b780b85f00007cb780b8b780f1a9a895969394a8a8a8aafc80b8
b780b87db1a8a8a8a8a8b20028b780b8768077007d00000daf0e5c8077768077007c000daf0e2076807776807776807700b780b80076fd807680774cfe80b800b780b8007680770000b780b87db780b8b08480808080f580a77680778df480b8b780b8b780f580f6b8007d00a3f080a6b7808b9800007c0000000000978c80b8
b7809b88007c007d31000000879c80b876807700007c007680777a807776f5777d00007680772076807776807776807700b780b87c7067670daf774da8a8b200b780b87c0daf0e0000b780b85fb780b8b3808095969394a8a87680778ea8a8b2b780b8b1a8a8a8a8b2000083ad8080b6b7809b887c7d00317c007d00879c80b8
b780f8b9a7a7a7bbbba7a7a7baf080b87680f166666666f080777b80f4808077007c007680f566f4807776fa8080fb7700b780f9a7666666faaf0e00005f5f00b780f4a780f3b80000b7f980a7f880b8b780f1a7a76666668ff0807700000000b780f2a7a7a7a7a7a7a7a7f180809200b780f0b9a7a7a7bbbba7a7a7bafd80b8
b1a8a8a8a8a8676d6d67a8a8a8a8a8b2706767676767676767717067676767710000007067676767677170676767677100b1a8a8a86767676767710000000000b1a8a8a8a8a8b25f00b1a8a8a8a8a8b2b1a8a8a8a86767679f67677100000000b1a8a8a8a8a8a8a8a8a8a8a895967d00b1a8a8a8a8a8676d6d67a8a8a8a8a8b2
0000b7a7a7a2b7a1a7a7a1a7a7a200000000b70087b8b7b70000b70000b800000000b7000000b7b1a8a8b1a8a8b20000a1a7a7b7a7a2b7a7a2b7b7a4b8a7a7a7b1a7a2b787b8b7a9b2b7b7a5b800b700a8a8b2b70000b7b5b4b7b700a500b7000000000000000000000000000000000000000000000000000000000000000000
0000b70097b800b79800b79897b800000000b7a8a8b2b7b78800b78887b8000000000000000000000000000000000000b79800b797b8b797b800b7b4b800b7000097b8b7a8b2b7a5a4b7b7b5b800b700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400000244002440034400444006450084600846008450074500545003440024400144001440014400144001440014400144001440024400344005450074600946008450064500545004440034400144001440
000100003611036110361103611036110371103711037110371103711037110371103711037110371103811038110361103611036110361103711037110371103711036110351103511035110361103611037110
000100003611037110371103511036110371103711037110361103511035110361103611035110361103711037110361103611037110371103611036110371103711036110351103511035110351103611037110
000400000243002430024300243003430034300343003430044300443004430044300543005430064300743007430054300243002430024300343003430034300343004430044300443004430054300543004430
000100000143001430014300143002430024300243002430034300343003430034300143001430014300143001430014300143001430014300143001430014300143001430014300143001430014300143001430
000100000243002430024300243003430034300343003430044300443004430044300243002430024300243002430024300243002430024300243002430024300243002430024300243002430024300243002430
000100000343003430034300343004430044300443004430054300543005430054300343003430034300343003430034300343003430034300343003430034300343003430034300343003430034300343003430
000100000443004430044300443005430054300543005430064300643006430064300443004430044300443004430044300443004430044300443004430044300443004430044300443004430044300443004430
000100000543005430054300543006430064300643006430074300743007430074300543005430054300543005430054300543005430054300543005430054300543005430054300543005430054300543005430
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
