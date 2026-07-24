pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--pinballvania
--by guerragames
poke(0x5f2d,1)

one_frame=1/60
cpu=stat(1)

game_time=0

--
cartdata("pinballvania")

game_saved=0
show_gameover=false

--
function game_load()
 game_time,current_level,new_game_plus=dget(0),dget(1),dget(2)
 current_level=max(1,current_level)
end

--
function game_save()
 dset(0,game_time)
 dset(1,current_level)
 dset(2,new_game_plus)
 
 game_saved=2
end

--
function game_reset()
 game_time,current_level,new_game_plus=0,1,0
 
 game_save()
 run()
end

--
align_l,align_r=1,2

function print_outline(t,x,y,c,bc,a)
 local ox=#t*2 
 if a==align_l then
  ox=0
 elseif a==align_r then
  ox=#t*4
 end
 local tx=x-ox
 color(bc)
 print(t,tx-1,y)print(t,tx-1,y-1)print(t,tx,y-1)print(t,tx+1,y-1)
 print(t,tx+1,y)print(t,tx+1,y+1)print(t,tx,y+1)print(t,tx-1,y+1)
 print(t,tx,y,c)
end

--
function time_to_text(time)
 local hours,mins,secs,fsecs=flr(time/3600),flr(time/60%60),flr(time%60),flr((time%60)*10)%10
 if(hours<0 or hours>9)return "8:59:59"
 local txt=hours>0 and hours..":" or ""
 txt=txt..((mins>=10 or hours==0) and mins or "0"..mins)
 txt=txt..(secs<10 and ":0"..secs or ":"..secs).."."..fsecs
 return txt
end

--
function dot(x1,y1,x2,y2)
 return x1*x2+y1*y2
end

--
function mag(x,y)
  local d=max(abs(x),abs(y))
  local n=min(abs(x),abs(y))/d
  return sqrt(n*n+1)*d
end

--
function normalize(x,y)
  local m=mag(x,y)
  return x/m,y/m,m
end

--
function next_i(l,i)
 i+=1
 if(i>#l)i=1
 return i
end

--
function find_next_i(l,i,active_count)
 if active_count>=#l then
  return nil,0
 end
 
 local o=l[i]
 while o.active do
  i=next_i(l,i)
  o=l[i]
 end
 
 return o,i
end

--
function reflect(x,y,nx,ny,restitution,friction)
 local d=dot(x,y,nx,ny)
 
 if d>0 then
  return x,y
 end

 local vnx,vny=-d*nx,-d*ny
 local tx,ty=x+vnx,y+vny
 
 local rx,ry=restitution*vnx+friction*tx,restitution*vny+friction*ty
 return rx,ry
end

-- matrix math

--
function matrix_rot(a)
 local sa=sin(a)
 local ca=cos(a)
 return {ca,-sa,0,
         sa,ca,0,
         0,0,1} 
end

--
function matrix_scale(s)
 return {s,0,0,
         0,s,0,
         0,0,1} 
end

--
function matrix_trans(tx,ty)
 return {1,0,tx,
         0,1,ty,
         0,0,1} 
end

--
function matrix_mul(a,b)
 return { a[1]*b[1]+a[2]*b[4]+a[3]*b[7],a[1]*b[2]+a[2]*b[5]+a[3]*b[8],a[1]*b[3]+a[2]*b[6]+a[3]*b[9],
          a[4]*b[1]+a[5]*b[4]+a[6]*b[7],a[4]*b[2]+a[5]*b[5]+a[6]*b[8],a[4]*b[3]+a[5]*b[6]+a[6]*b[9], 
          a[7]*b[1]+a[8]*b[4]+a[9]*b[7],a[7]*b[2]+a[8]*b[5]+a[9]*b[8],a[7]*b[3]+a[8]*b[6]+a[9]*b[9] }
end

--
function transform(v,m)
 return m[1]*v.x+m[2]*v.y+m[3],m[4]*v.x+m[5]*v.y+m[6]
end

--
function rotate_point( x, y, cosa, sina )
 return x*cosa - y*sina, x*sina + y*cosa
end

--
function scale_point( x, y, scalex, scaley )
 return scalex*x, scaley*y
end

------------------------
-- arrow
------------------------
arrow = {}
arrow.size = 5
arrow.scale = 1
arrow_disabled_t=5
--arrow.min_scale = 1
--arrow.max_scale = 2
--arrow.min_col_scale = 0.5
--arrow.max_col_scale = 1.8
arrow.x = 80
arrow.y = 80
arrow.tx,arrow.ty=80,80
--arrow.colors = {8,9,10,7,12}
arrow.nx = 1
arrow.ny = 0

arrow.points =
{
 { 0, 0},
 { 2, 2},
 { 1, 2},
 { 1, 4},
 {-1, 4},
 {-1, 2},
 {-2, 2},
 { 0, 0},
 { 0, 0},
}

--------------------------

arrow.draw = function(color)
 local st = 0.8*sin(t)
 local scale = arrow.scale
 local col_scale = arrow.scale
 
 arrow.x+=.1*(arrow.tx-arrow.x)
 arrow.y+=.1*(arrow.ty-arrow.y)
 
 --[[
 if scale < arrow.min_scale then
  scale = arrow.min_scale
 elseif scale > arrow.max_scale then
  scale = arrow.max_scale
 end
 if col_scale < arrow.min_col_scale then
  col_scale = arrow.min_col_scale
 elseif col_scale > arrow.max_col_scale then
  col_scale = arrow.max_col_scale
 end
 --]]
 --local color_index = 1 + flr( ((col_scale - arrow.min_col_scale)/(arrow.max_col_scale - arrow.min_col_scale) ) * (#arrow.colors-1))
 --local color = arrow.colors[color_index]
 
 local x,y = scale_point(arrow.points[1][1], arrow.points[1][2], scale*(arrow.size+st), scale*(arrow.size-st))
 local cosa = arrow.ny
 local sina = arrow.nx
 x,y = rotate_point(x,y,cosa,sina)
 
 for i=2,#arrow.points do
  local px,py = x,y
  x,y = scale_point(arrow.points[i][1], arrow.points[i][2],scale*(arrow.size+st), scale*(arrow.size-st))
  x,y = rotate_point(x,y,cosa,sina)
  
  local ax = arrow.x+x
  local ay = arrow.y+y
  local pax = arrow.x+px
  local pay = arrow.y+py
  line(ax+1,ay,pax+1,pay, 0)
  line(ax-1,ay,pax-1,pay, 0)
  line(ax,ay+1,pax,pay+1, 0)
  line(ax,ay-1,pax,pay-1, 0)

  line(ax+1,ay+1,pax+1,pay+1, 0)
  line(ax-1,ay-1,pax-1,pay-1, 0)
  line(ax-1,ay+1,pax-1,pay+1, 0)
  line(ax+1,ay-1,pax+1,pay-1, 0)
 end 

 for i=2,#arrow.points do
  local px,py = x,y
  x,y = scale_point(arrow.points[i][1], arrow.points[i][2],scale*(arrow.size+st), scale*(arrow.size-st))
  x,y = rotate_point(x,y,cosa,sina)
  line(arrow.x+x,arrow.y+y,arrow.x+px,arrow.y+py, color)
 end 
 
end

--
parts={}
parts_next,parts_blink=1,0

for i=0,400 do
 add(parts,{t=0})
end

parts_flags_floor_bounce,parts_flags_blink,parts_flags_no_outline=0x01,0x02,0x04

-- 
function parts_reset()
 for k,p in pairs(parts) do
  p.t=0
 end
end

--
function parts_spawn(t,x,y,vx,vy,g,d,s,ds,c,bc,f)
 parts_next=next_i(parts,parts_next)
 
 local p=parts[parts_next]
 
 p.t,p.x,p.y,p.vx,p.vy,p.g,p.d,p.s,p.ds,p.c,p.bc,p.f=t,x,y,vx,vy,g,d,s,ds,c,bc,f
end

--
function parts_update()
 parts_blink+=one_frame
 
 for k,p in pairs(parts) do
  if p.t>0 then
   p.t-=one_frame
   
   p.vx*=p.d
   p.vy*=p.d
   
   p.x+=p.vx
   p.y+=p.vy
   
   p.s=max(0,p.s+p.ds)
   
   if p.s<=0 then
    p.t=0
   end
   
   --[[]]
   if band(p.f,parts_flags_blink)==parts_flags_blink then
    if parts_blink%.2>.1 then 
     p.c,p.bc=p.bc,p.c
    end
   end
   --]]
   
   --if band(p.f,parts_flags_floor_bounce)==parts_flags_floor_bounce and s_floor(p.x,p.y+p.s) then
   -- if abs(p.vy)>.2 then
   --  p.vy=-.8*p.vy
   -- end
   --else
    p.vy+=p.g
   --end
  end
 end
end

--
function part_draw(p,o,c)
 local s=p.s+o
 
 if s<=1 then
  pset(p.x,p.y,c)
 else
  circfill(p.x,p.y,s-1,c)
 end
end

--
function parts_draw()
 for k,p in pairs(parts) do
  if p.t>0 then
   if band(p.f,parts_flags_no_outline)!=parts_flags_no_outline then
    part_draw(p,1,p.bc)
   end
  end
 end

 for k,p in pairs(parts) do
  if p.t>0 then
   part_draw(p,0,p.c)
  end
 end
end

--
function explosions_spawn(px,py,t,intensity,s,ds,count,c,bc)
 for i=1,count do
  local an,ra=rnd(),intensity+rnd(intensity)
  local vx,vy=ra*cos(an),ra*sin(an)

--parts_spawn(t, x, y,vx,vy,g, d, s, ds,c,bc,f)
  parts_spawn(t,px,py,vx,vy,0,.9,s,ds,c,bc,parts_flags_no_outline)
 end
end

--
function explosions_spawn_uniform(px,py,t,intensity,s,ds,count,c,bc)
 local an=0
 for i=1,count do
  local ra=intensity
  local vx,vy=ra*cos(an),ra*sin(an)

--parts_spawn(t, x, y,vx,vy,g, d, s, ds,c,bc,f)
  parts_spawn(t,px,py,vx,vy,0,.8,s,ds,c,bc,parts_flags_blink)
 
  an+=1/count
 end
end

--
cam_shake_x,cam_shake_y,cam_shake_damp=0,0,0
cam_shake_time=0
cam_shake_max_radius=0

--
function screenshake(max_radius,time)
 cam_shake_max_radius=max_radius
 cam_shake_time=time
end

--
function update_screeneffects()
 cam_shake_time=max(0,cam_shake_time-one_frame)
 
 if cam_shake_time>0 then
  local a=rnd()
  cam_shake_x,cam_shake_y=cam_shake_max_radius*cos(a),cam_shake_max_radius*sin(a)
 else
  cam_shake_x,cam_shake_y=0,0
 end
end

----------------------
-- camera
----------------------
cam_a=0
cam_aa=.0005
cam_va=0
cam_s=0
cam_trans_s=1
cam_x=0
cam_y=0
cam_matrix=matrix_scale(cam_s)

mouse_on=false
mouse_x,mouse_y=0,0
mouse_up,mouse_down,mouse_left,mouse_right=false,false,false,false

----------------------

function cam_update()
 cam_va*=.9
 if(abs(cam_va)<=.0002)cam_va=0
 
 mouse_on=stat(34)
 
 mouse_x,mouse_y=stat(32),stat(33)
 
 if mouse_on==1 then
  mouse_right=mouse_x>64
  mouse_up=mouse_y<48
  mouse_left=mouse_x<64
  mouse_down=mouse_y>80
 else
  mouse_up,mouse_down,mouse_left,mouse_right=false,false,false,false
 end
 
 if btn(0) or mouse_left then
  -- left
  cam_va+=cam_aa
 end
 
 if btn(1) or mouse_right then
  -- right
  cam_va-=cam_aa
 end
 
 if(cam_va>.005)cam_va=.005
 if(cam_va<-.005)cam_va=-.005
 
 cam_a+=cam_va
 
 if level_t<1 then
  if abs(player.x-cam_x)>2 or abs(player.y-cam_y)>2 then
   cam_x+=.1*(-player.x-cam_x)
   cam_y+=.1*(-player.y-cam_y)
  end
 else
  if abs(current_circle.x-cam_x)>2 or abs(current_circle.y-cam_y)>2 then
   cam_x+=.1*(-current_circle.x-cam_x)
   cam_y+=.1*(-current_circle.y-cam_y)
  end
 end
 
 local cc_scale=(3.5-current_circle.r/16)/cam_trans_s
 
 if abs(cc_scale-cam_s)>.1 then
  cam_s+=.1*(cc_scale-cam_s)
 end
 
 cam_matrix=matrix_mul( matrix_scale(cam_s), matrix_mul(matrix_rot(cam_a),matrix_trans(cam_x,cam_y)) )
end

-- player
player={}

--
function player_reset()
 player.radius=3
 player.lx,player.ly=0,0
 player.x,player.y=0,0
 player.vx,player.vy=0,0
 player_t=0
 player_flash=0
end

--
function player_bounce_ball(nx,ny)
 local pvx,pvy=player.vx,player.vy
 player.vx,player.vy=reflect(player.vx,player.vy,nx,ny,.8,1)

 local vnx,vny,m=normalize(player.vx,player.vy)

 if player.vx*pvx<-.25 or player.vy*pvy<-.25 then
  player_flash=.1
  local px,py=transform(player,cam_matrix)
  explosions_spawn(px,py,.4*m,min(3,2*m),min(3,2*m),-.1,12,10,9)
  screenshake(min(3,2*m),min(.15,.05*m))
 
  if m>2.5 then
   sfx(0,3)
  elseif m>2 then
   sfx(1,3)
  elseif m>1.5 then
   sfx(2,3)
  elseif m>1 then
   sfx(3,3)
  end
 end
end

--
function player_update()
 if(level_t<1)return
  
 player_t+=one_frame

 player_flash=max(0,player_flash-one_frame)

 local cam_ax,cam_ay=cos(-cam_a-.25),sin(-cam_a-.25)

 local drop_mag=.05
 
 if btn(3) or btn(4) or btn(5) or mouse_down then
  drop_mag=.2
 end

 local player_max_speed=3
 
 if level_finished and not is_title_level then
  local nx,ny,m=normalize(goal_circle.x-player.x,goal_circle.y-player.y)
  player.vx+=nx*.1
  player.vy+=ny*.1
  player_max_speed=1
 else
  player.vx+=drop_mag*cam_ax
  player.vy+=drop_mag*cam_ay
  player_max_speed=3
 end

 local pvnx,pvny,m=normalize(player.vx,player.vy)
 
 if m>player_max_speed then
  m=player_max_speed
  player.vx=m*pvnx
  player.vy=m*pvny
 end
 
 player.lx,player.ly=player.x,player.y
 player.x+=player.vx
 player.y+=player.vy
 
 local player_onground,nx,ny,m=circles_check_collision(player)
 
 if player_onground then
  player_bounce_ball(nx,ny)
  
  local vnx,vny,m=normalize(player.vx,player.vy)
  if m>.5 then
   sfx(5,2)
  else
   sfx(-2,2)
  end
 else
  sfx(-2,2)
 end
 
 local player_onobstacle,nx,ny=circles_check_obstacles(player)
 
 if player_onobstacle then
  if current_circle.is_bumper then
   current_circle.bumped_t=.2
   player_bounce_ball(-1.5*nx,-1.5*ny)
   
   if current_circle.boss_damaged_t>0 then
    sfx(9,1)
   else
    sfx(8,1)
   end
   
  else
   player_bounce_ball(-nx,-ny)
  end
 end
 
 -- check level win condition
 if current_circle==goal_circle then
  local exit_active=is_exit_active()
  
  if exit_active then
   local m=mag(player.x-current_circle.x,player.y-current_circle.y)
   
   if not level_finished and m>0 and m<current_circle.r/2 then
    level_finished=true
    level_finished_t=0
    if(not is_title_level)sfx(11,1)
   
    game_finished=not is_title_level and level_finished and current_level==20
   end
  end
 end
end

--
function player_draw()
 if(level_t<1)return
 
 local px,py=transform(player,cam_matrix)

 local psize=player.radius*cam_s

 circfill(px,py,psize,player_flash>0 and 10 or 5)
 circfill(px,py,psize-1,6)
 circfill(px+psize/4,py-psize/4,1,7)
end

-- level circles

next_level=1
current_level=1
max_level=20

new_game_plus=0

game_finished=false
level_finished=false
level_finished_t=0

level_next_level=false
level_t=0
cam_trans_s=1

--
function circles_new_level()
 player_reset()
 pickups_reset()
 
 srand(new_game_plus+current_level/100)
 
 circles={}
 
 level_radius=1024
 
 is_boss_level=current_level%5==0

 if is_boss_level then
  boss_level=current_level/5
  max_boss_health=20+boss_level*20
  boss_health=20+boss_level*20
 end

 start_circle=circles_add(0,0,16,0)
 start_circle.obstacle_count=0
 add(circles,start_circle)
 start_circle.last_circle=nil

 local last_circle=start_circle

 for i=1,10+current_level do
  local circle=nil
  while circle==nil do
   local a=rnd()
   local r=rnd(level_radius)
   circle=circles_add(r*cos(a),r*sin(a),16+rnd(24),i)
  end
  
  -- make pickups
  if not is_boss_level then
   circle.pickup_count=8
   local ap=0
   for i=1,circle.pickup_count do
    local r=circle.r-5
    local x,y=circle.x+r*cos(ap),circle.y+r*sin(ap)
    pickups_spawn(x,y,ap,circle)
    ap+=1/8
   end
  end
  
  add(circles,circle)
  circle.last_circle=last_circle
  last_circle=circle
  
  local colors=bg_colors_tables[mid(1,current_level,#bg_colors_tables)]
  local c,bc=colors[#colors],5
  
  local x,y=transform(circle,cam_matrix)
  --explosions_spawn(px,py,t,intensity,s,ds,count,c,bc)
  explosions_spawn(x,y,.5,4,6,-.2,20,c,bc)
 end
 
 pickups_total=pickups_active_count
 
 current_circle=start_circle
 objective_circle=nil
 
 goal_circle=circles[#circles]
 goal_circle.obstacle_count=0
 goal_circle.is_bumper=false
 goal_circle.is_moving=false
 
 if is_boss_level then
  -- if we're on a boss level, the goal circle becomes the boss
  -- acts like a bumper, 10 hits and it jumps to the next circle until boss_health is zero
  circle_add_boss(goal_circle)
 end
end

--
function circles_new_title_level()
 player_reset()
 pickups_reset()
 
 srand(0)
 
 circles={}
 
 level_radius=1024
 
 is_title_level=true
 is_boss_level=false

 start_circle=circles_add(0,0,32,0)
 start_circle.obstacle_count=0
 add(circles,start_circle)
 start_circle.last_circle=nil

 local last_circle=start_circle
 
 pickups_total=0
 
 current_circle=start_circle
 
 goal_circle=start_circle
end

--
function circles_find_closest(x,y,r)
 local closest_circle=nil
 local closest_distance=level_radius
 
 for k,v in pairs(circles) do
  local nx,ny,m=normalize(v.x-x,v.y-y)
  local distance=m-v.r-r
  if distance<closest_distance then
   closest_distance=distance
   closest_circle=v
  end
 end
 
 return closest_circle
end

--
function circle_add_obstacle(circle)
 local max_obstacle_count=min(8,.5+current_level/2)
 local max_moving_chance=max(0,.8*current_level/20)
 local max_bumper_chance=max(0,.6*current_level/20)
 local max_expanding_chance=max(0,.4*current_level/20)
 
 --[[circle type]]
 circle.obstacle_count=flr(rnd(max_obstacle_count))
 circle.is_moving=rnd()<max_moving_chance
 circle.is_bumper=rnd()<max_bumper_chance
 circle.is_expanding=rnd()<max_bumper_chance
 
 circle.base_obstacle_r=(.3+rnd(.4))*circle.r/circle.obstacle_count
 circle.obstacle_r=circle.base_obstacle_r
 
 local single_static=not circle.is_moving and circle.obstacle_count==1
 local a=0
 for i=1,circle.obstacle_count do
  local ca=circle.ot+a
  local r=single_static and 0 or circle.r/3
  circle.mx[i],circle.my[i]=r*cos(ca),r*sin(ca)
  local r=single_static and 0 or circle.r/3*cam_s
  circle.dx[i],circle.dy[i]=r*cos(ca+cam_a),r*sin(ca+cam_a)
 
  a+=1/circle.obstacle_count
 end
 --]]
end

--
function circle_add_boss(circle)
 
 --[[circle type]]
 circle.obstacle_count=boss_level
 circle.is_moving=true
 circle.is_bumper=true
 circle.is_boss=true
 circle.is_expanding=true
 
 circle.base_obstacle_r=.8*circle.r/circle.obstacle_count
 circle.obstacle_r=circle.base_obstacle_r
 
 --common function:
 local single_static=not circle.is_moving and circle.obstacle_count==1
  local a=0
  for i=1,circle.obstacle_count do
   local ca=circle.ot+a
   local r=single_static and 0 or circle.r/3
   circle.mx[i],circle.my[i]=r*cos(ca),r*sin(ca)
   local r=single_static and 0 or circle.r/3*cam_s
   circle.dx[i],circle.dy[i]=r*cos(ca+cam_a),r*sin(ca+cam_a)
  
   a+=1/circle.obstacle_count
  end
 --]]
end

--
function circles_add(x,y,r,i)
 if #circles>0 then
  -- find closest circle
  local last_closest_circle=nil
  local closest_circle=circles_find_closest(x,y,r)
  
  local iter_count=0
  while last_closest_circle!=closest_circle and iter_count<20 do
   local nx,ny,m=normalize(closest_circle.x-x,closest_circle.y-y)
   local distance=closest_circle.r+r-4-rnd(2)
   x=closest_circle.x-nx*distance
   y=closest_circle.y-ny*distance
   
   last_closest_circle=closest_circle
   closest_circle=circles_find_closest(x,y,r)
   iter_count+=1
  end
  
  if iter_count>=20 then
   return nil
  end
 end

 local circle={x=x,y=y,mx={},my={},dx={},dy={},r=r,i=i,obstacle_count=0,obstacle_r=0,boss_damaged_t=0,bumped_t=0,ot=i/8}

 if not is_boss_level then
  circle_add_obstacle(circle)
 end
 
 return circle
end

--
function circles_check_collision(entity)
 local inside_circle=nil
 for k,circle in pairs(circles) do
  local cx,cy=circle.x,circle.y
  local dx,dy=entity.x-cx,entity.y-cy
  local m=mag(dx,dy)
  
  if m>0 and m<circle.r then
   if inside_circle then
    -- inside two circles, we're safe to roam out of one
    return false,0,0,0
   else
    inside_circle=circle
   end
  end
 end
 
 -- we're inside one circle
 if inside_circle then
  current_circle=inside_circle
 end
 
 local cx,cy=current_circle.x,current_circle.y
 local dx,dy=cx-entity.x,cy-entity.y
 local nx,ny,mag=normalize(dx,dy)
 if mag>current_circle.r-player.radius then
  mag=current_circle.r-player.radius
  entity.x,entity.y=cx-nx*mag,cy-ny*mag
   
  return true,nx,ny,m
 end
 
 return false,0,0,0
end


--
function circles_check_obstacles(entity)
 local hit=false
 local anx,any=0,0
 
 if is_boss_level then
  if boss_health<=0 then
  return false,0,0
  end
 end
 
 for i=1,current_circle.obstacle_count do
  local cx,cy=current_circle.x,current_circle.y
  
  cx+=current_circle.mx[i]
  cy+=current_circle.my[i]
  
  local dx,dy=cx-entity.x,cy-entity.y
  local nx,ny,mag=normalize(dx,dy)
  if mag<current_circle.obstacle_r+player.radius then
   mag=current_circle.obstacle_r+player.radius
   entity.x,entity.y=cx-nx*mag,cy-ny*mag
   anx+=nx
   any+=ny
   hit=true
   
   if is_boss_level and i==1 then
    
    current_circle.boss_damaged_t=.2
    current_circle.obstacle_r-=(current_circle.base_obstacle_r/2)/10
    
    arrow_disabled_t=5
    
    if current_circle.obstacle_r<current_circle.base_obstacle_r/2 then
     current_circle.obstacle_count=0
     current_circle.boss_damaged_done=true
     
     local ex,ey=transform(current_circle,cam_matrix)

     if current_circle.last_circle!=nil then
      current_circle.is_boss=false
      circle_add_boss(current_circle.last_circle)
      
      --big explosion
      --explosions_spawn_uniform(px,py,t,intensity,s,ds,count,c,bc)
      explosions_spawn_uniform(ex,ey,1,16,8,-.2,16,11,8)
      screenshake(3,.2)
--     else
--      --big explosion
--      --explosions_spawn_uniform(px,py,t,intensity,s,ds,count,c,bc)
--      explosions_spawn_uniform(ex,ey,1,14,16,-.3,20,11,8)
--      screenshake(3,.2)
     end
    else
     boss_health-=1
     
     local ex,ey=transform(current_circle,cam_matrix)
     
     if boss_health<=0 then
      current_circle.is_boss=false
      --big explosion
      --explosions_spawn_uniform(px,py,t,intensity,s,ds,count,c,bc)
      explosions_spawn_uniform(ex,ey,1,14,16,-.3,20,11,8)
      screenshake(3,.2)
     else
      --small explosion
      --explosions_spawn(px,py,t,intensity,s,ds,count,c,bc)
      explosions_spawn(ex,ey,.5,3.5,8,-.4,16,11,8)
      screenshake(2,.1)
     end
    end
   end
  end
 end
 
 if hit then
  anx,any=normalize(anx,any)
  return true,anx,any
 end
 
 return false,0,0
end

--
function is_exit_active()
 if is_boss_level then
  return boss_health<=0
 else
  return pickups_active_count<=0
 end
end

--
function closest_objective()
 
 local closest_circle=nil
 local closest_distance=1000
 
 for k,circle in pairs(circles) do
  if circle.is_boss then
   return circle
  end
  
  if circle.pickup_count and circle.pickup_count>0 then
   local dx,dy=circle.x-current_circle.x,circle.y-current_circle.y
   local nx,ny,m=normalize(dx,dy)
   if m<closest_distance then
    closest_distance=m
    closest_circle=circle
   end
  end
 end
 
 if closest_circle==nil then
  -- check for boss and then for exit
  
  return goal_circle
 end
 
 return closest_circle
end

--
function circles_update()
 arrow_disabled_t=max(0,arrow_disabled_t-one_frame)
 
 level_t=min(2,level_t+one_frame)
 
 if not is_title_level then
  if level_t<=1 then
   if level_t>=.5 then
    if level_next_level then
     level_next_level=false
     current_level=next_level
     circles_new_level()
     game_save()
    end
   
    cam_trans_s=1+(1-(level_t-.5)/.5)*40
   else
    cam_trans_s=1+(level_t/.5)*40
   end
  else
   if level_finished then
    cam_trans_s=2+1*sin(t()*.75)
   else
    if is_boss_level then
     cam_trans_s=1.2
    else
     cam_trans_s=1
    end
   end
  end
 end
 
 for k,circle in pairs(circles) do
  circle.bumped_t=max(0,circle.bumped_t-one_frame)
  circle.boss_damaged_t=max(0,circle.boss_damaged_t-one_frame)
  
  local a=circle.is_moving and t()/10 or 0
  
  local single_static=not circle.is_moving and circle.obstacle_count==1
  local expanding_r=circle.is_expanding and circle.r/6*sin(t()/4) or 0

  for i=1,circle.obstacle_count do
   local ca=circle.ot+a
   local r=single_static and 0 or circle.r/3+expanding_r
   circle.mx[i],circle.my[i]=r*cos(ca),r*sin(ca)
   local r_cam=r*cam_s
   circle.dx[i],circle.dy[i]=r_cam*cos(ca+cam_a),r_cam*sin(ca+cam_a)
  
   a+=1/circle.obstacle_count
  end
 end
 
 objective_circle=closest_objective()

 if objective_circle==current_circle then
  arrow_disabled_t=5
 end
end

--
function draw_circle_text(text,x,y,wave)
 local blink=t()%.4>.2

 for j=0,#text do
  local row=text[j]
  for i=0,#row do
   local cs=row[i]
   if cs!=0 then
    local a=cam_a+.375+.8*i/#row
    local r=cam_s*(28+3*j)*.7
    if(wave)r+=8*sin(t()*.5+i/#row+j/#text*.1)
    local ox,oy=r*cos(a),r*sin(a)
    circfill(x+ox,y+oy,3,blink and 2 or c)
   end
  end
 end

 for j=0,#text do
  local row=text[j]
  for i=0,#row do
   local cs=row[i]
   if cs!=0 then
    local a=cam_a+.375+.8*i/#row
    local r=cam_s*(28+3*j)*.7
    if(wave)r+=8*sin(t()*.5+i/#row+j/#text*.1)
    local ox,oy=r*cos(a),r*sin(a)
    circfill(x+ox,y+oy,2,7)
   end
  end
 end
end

--
function circles_draw()
 local draw_circs={}
 
 local px,py=transform(player,cam_matrix)

 for k,circle in pairs(circles) do
  local x,y=transform(circle,cam_matrix)
  add(draw_circs,{x=x,y=y,r=circle.r*cam_s,obs_r=(circle.obstacle_r+circle.obstacle_r*.5*circle.bumped_t*5)*cam_s,c=circle})
 end
 
 local colors=bg_colors_tables[mid(1,current_level,#bg_colors_tables)]

 local c,bc=colors[#colors],5
 
 for k,dc in pairs(draw_circs) do
  circ(dc.x,dc.y,dc.r+4,bc)
  circ(dc.x,dc.y,dc.r+3,bc)
 end

 for k,dc in pairs(draw_circs) do
  circ(dc.x,dc.y,dc.r+2,c)
  circ(dc.x,dc.y,dc.r+1,c)
  circ(dc.x,dc.y,dc.r,c)
 end
 
 fillp(0b0101101001011010)
 for k,dc in pairs(draw_circs) do
  circfill(dc.x,dc.y,dc.r-1,0x10)
 end
 fillp()

 --[[]]
 local exit_active=is_exit_active()
 
 for k,dc in pairs(draw_circs) do
  local s=dc.r*.5
  
  if dc.c.boss_damaged_done then
   circ(dc.x,dc.y,s*.25+2,8)
   circ(dc.x,dc.y,s*.25,8)
  end
  
  if dc.c==start_circle then
   circ(dc.x,dc.y,s,7)
   circ(dc.x,dc.y,s-2,7)
  elseif dc.c==goal_circle then
   if exit_active then
    s=dc.r*.5+2*sin(t())
    circfill(dc.x,dc.y,s,0)
   end
  
   circ(dc.x,dc.y,s,10)
   circ(dc.x,dc.y,s-2,10)
   
   if exit_active then
    print_outline("exit",dc.x+1,dc.y-2,7,5)
   end
  end
 end 
 --]]

 -- draw obstacles
 local draw_bumpers=not is_boss_level or boss_health>0
  
 if draw_bumpers then
  for k,dc in pairs(draw_circs) do
   local circle=dc.c
   
   for i=1,circle.obstacle_count do
    local x,y=dc.x+circle.dx[i],dc.y+circle.dy[i]
    local bc=circle.is_bumper and (is_boss_level and 11 or 8) or circle.is_moving and 13 or 5
    local s=dc.obs_r
    circfill(x,y,s+1,bc)
    
    if circle.is_bumper then
     circ(x,y,s+3,bc)
    end
   end
   
   for i=1,circle.obstacle_count do
    local x,y=dc.x+circle.dx[i],dc.y+circle.dy[i]
    
    local c,bc=13,5
    if is_boss_level then
     c,bc=3,11
    elseif circle.is_bumper then
     c,bc=7,8
    elseif circle.is_moving or circle.is_expanding then
     c,bc=12,13
    end
    
    local s=dc.obs_r
    
    circfill(x,y,s,c)
   end
  
   -- draw boss's eye
   if is_boss_level and boss_health>0 and circle.obstacle_count>0 then
    local x,y=dc.x+circle.dx[1],dc.y+circle.dy[1]
     
    local c,bc=3,11
    local s=dc.obs_r
    
    if circle.boss_damaged_t>0 then
     line(x-s/3,y,x+s/3,y,bc)
    else
     circfill(x,y,s/2,7)
     local nx,ny,m=normalize(x-px,y-py)
     circfill(x-s/5*nx,y-s/5*ny,s/5,0)
    end
   end
   
   -- draw title screen
   if is_title_level or game_finished then
    local x,y=dc.x,dc.y
    draw_circle_text(title_text,x,y,game_finished)
   end
  end
 end
 
 local x,y=transform(current_circle,cam_matrix)
 if is_title_level or game_finished then
  -- draw title screen
  draw_circle_text(title_text,x,y,game_finished)
 else
  if arrow_disabled_t<=.25 then
   if objective_circle and objective_circle!=current_circle then
    local ox,oy=transform(objective_circle,cam_matrix)
    local dx,dy=ox-x,oy-y
    local nx,ny,m=normalize(dx,dy)
    
    local r=(current_circle.r+4)*cam_s+4*sin(t())
    
    arrow.tx,arrow.ty=x+r*nx,y+r*ny
    arrow.nx,arrow.ny=nx,-ny
    arrow.scale=.8*(1-mid(0,arrow_disabled_t*4,1))
    
    local color=t()%.4>.2 and 11 or 3
    
    if is_boss_level and boss_health>0 then
     color=t()%.4>.2 and 11 or 8
    elseif objective_circle==goal_circle then
     color=t()%.4>.2 and 7 or 10
    end
   
    arrow.draw(color)  
   end
  end
 end
end

--
function scan_text(text)
  scan={}
  rectfill(0,0,#text*4+1,7,0)
  print(text,0,0,1)
  for y=0,7 do
    scan[y]={}
    for x=0,#text*4+1 do
      scan[y][x]=pget(x,y)
    end
  end
  return scan
end

title_text=scan_text("pinballvania!")

--
pickups={}

for i=1,400 do
 add(pickups,{active=false})
end

--
function pickups_reset()
 for k,pu in pairs(pickups) do
  pu.active=false
 end

 pickups_next,pickups_active_count,pickups_total=1,0,0
end

--
function pickups_spawn(x,y,ap,circle)
 local pu,i=find_next_i(pickups,pickups_next,pickups_active_count)

 if pu then
  pickups_next=i
  pickups_active_count+=1
  
  pu.active,pu.t,pu.x,pu.y=true,ap,x,y
  pu.circle=circle
 end
end

--
function pickups_update()
 for k,pu in pairs(pickups) do
  if pu.active then
   pu.t+=one_frame
 
   --check collisions with the player
   local pux,puy=pu.x,pu.y
   local px,py=player.x,player.y
   if abs(px-pux)<=8 and abs(py-puy)<=8 then
    pu.circle.pickup_count-=1
    pu.active=false
    pickups_active_count-=1
    local pucx,pucy=transform(pu,cam_matrix)
    explosions_spawn_uniform(pucx,pucy,.5,4,6,-.3,8,11,8)
    
    arrow_disabled_t=5
    sfx(7,3)
   end
  end
 end
end

--
function pickups_draw()
 for k,pu in pairs(pickups) do
  if pu.active then
   local pux,puy=transform(pu,cam_matrix)
   local s=(2+sin(pu.t))*cam_s
   circfill(pux,puy,s+1,3)
   circfill(pux,puy,s,11)
  end
 end
end

--
function ui_update()
 if(game_saved>0)game_saved-=one_frame
 
 if is_title_level or level_finished then
  level_finished_t+=one_frame
 
  if level_finished_t>1 and (btnp(2) or mouse_up) then
   if is_title_level then
    is_title_level=false
    next_level=current_level
   else
    if game_finished then
     new_game_plus+=1
     next_level=1
     game_time=0
    else
     next_level=min(max_level,current_level+1)
    end
   end

   sfx(10,1)
   level_next_level=true
   level_finished=false
   game_finished=false
   level_t=0
   arrow_disabled_t=5
  end
 end
end

--
function ui_draw()
 if is_title_level then
  print_outline("<press up to start>",64,112,7,t()%.4>.2 and 8 or 0)
  print_outline("guerragames 2019",64,120,7,0)
 elseif game_finished then
  print_outline("good job! game finished!",64,64+32,7,0)
  print_outline("brag about it on the webs!",64,64+32+8,7,0)
  
  local ngs=""
  if(new_game_plus>0)ngs=""..(new_game_plus+1)
  print_outline("<press up for ng+"..ngs..">",64,64+32+16,7,0)
 elseif level_finished then
  print_outline("level finished!",64,64+32,7,0)
  print_outline("<press up to continue>",64,64+32+8,7,0)
 end
 
 if game_saved>0 and game_saved%.2>.1 then
  print_outline("game saved",64,120,7,0)
 end
 
 local exit_active=is_exit_active()
 
 local c,bc=7,0
 if not is_title_level and exit_active and t()%.4>.2 then
  c,bc=0,10
 end
 
 print_outline((pickups_total-pickups_active_count).."/"..pickups_total,2,2,c,bc,align_l)
 print_outline(time_to_text(game_time),64,2,c,bc)
 
 local ngs=""
 if(new_game_plus>=1)ngs=new_game_plus.."."
 print_outline("lvl:"..ngs..current_level,127,2,c,bc,align_r)
 
 if is_boss_level then
  rect(2,9,125,19,7)
  local l_health=boss_health/max_boss_health*119
  if(l_health>=1)rectfill(4,11,4+l_health,17,8)
 
  print("boss",5,12,7)
 
 end
end

--
background_iter_count=50

--
function rndb()
 return 64-rnd(128)
end

--
function background_splatters(colors)
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local c=pget(x,y)
  
  local nx,ny,m=normalize(x,y)
  line(x,y,x+8*nx,y+8*ny,c)
  circfill(x+8*nx,y+8*nx,rnd(3),colors[flr(rnd(#colors))+1])
 end
end

--
function background_sphere(colors)
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local nx,ny,m=normalize(x,y)
  local s=min((128-m)/26,4)
  circfill(x,y,s,colors[flr(rnd(#colors))+1])
  circ(x,y,s,0)
 end
end

--
function background_linesandbubbles(colors)
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local c=pget(x,y)
  
  local nx,ny,m=normalize(x,y)
  line(0,0,128*nx,128*ny,c)
  circ(x,y,rnd(8),colors[flr(rnd(#colors+1))+1])
 end
end

--
function background_spiral(colors)
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local c=pget(x,y)
  local r=sqrt(x*x+y*y)
  local a=atan2(x,y)+r/128+t()/40
  
  local nx,ny,m=normalize(x,y)
  line(x,y,x+8*cos(a),y+8*sin(a),colors[flr(rnd(#colors+1))+1])
 end
end

--
function background_circles(colors)
 for i=0,background_iter_count do
  local x,y=128-rnd(256),128-rnd(256)
  circ(x,y,rnd(32),0)
  circ(0,0,x,colors[flr(rnd(#colors+1))+1])
 end
end

--
function background_blocks(colors)
 for i=0,background_iter_count do
  local color=colors[flr(rnd(#colors+1))+1]
  local r,dr=rnd(256),12
  local a,da=rnd(),.025
  local r1,r2=r+dr,r-dr
  local a1,a2=a+da,a-da
  local ca1,sa1,ca2,sa2=cos(a1),sin(a1),cos(a2),sin(a2)
  line(r1*ca1,r1*sa1,r2*ca1,r2*sa1,color)
  line(r1*ca2,r1*sa2,r2*ca2,r2*sa2,color)
  line(r1*ca1,r1*sa1,r1*ca2,r1*sa2,color)
  line(r2*ca1,r2*sa1,r2*ca2,r2*sa2,color)
 end
end

--
function background_bubbles(colors)
 for i=0,background_iter_count/5 do
  local x,y=rndb(),rndb()
  local r=2+rnd(8)
  circfill(x,y,r,colors[1])
  circfill(x,y,3*r/4,colors[2])
  circfill(x,y,r/2,colors[3])
  circfill(x,y,r/4,colors[4])
 end
end

--
function background_drip(colors)
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local c=colors[flr(rnd(#colors+1))+1]
  local nx,ny,m=normalize(x,y)
  line(x,y,x+8*nx,y+8*ny,c)
 end
end

--
function background_rainbow_splat(colors)
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local nx,ny,m=normalize(x,y)
  local c=colors[flr((m/8+t()/5)%#colors)+1]
  circfill(x,y,rnd(4),c)
 end
end

--
function background_rainbow_spiral(colors)
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local nx,ny,m=normalize(x,y)
  local a=atan2(nx,ny)
  local c=colors[flr((a*4*#colors+m/12-t()/10)%#colors)+1]
  circfill(x,y,rnd(3),c)
 end
end

--
function background_text(colors)
 local strs={"pico8","guerragames","pinballvania",}
 for i=0,background_iter_count do
  local x,y=128-rnd(256),128-rnd(256)
  local c=colors[flr(rnd(#colors+1))+1]
  rectfill(x,y,x+4,y+6,0)
  print(strs[flr(rnd(#strs))+1],flr(x/4)*4,flr(y/6)*6,c)
 end
end

--
function background_fire(colors)
 local time=t()/50
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local nx,ny,m=normalize(x,y)
  local a=atan2(nx,ny)
  local c=colors[flr((sin(m/32+time)+cos(a*3+time)+time*5)%#colors)+1]
  circfill(x,y,1,c)
 end
end

--
function background_star(colors)
 local time=t()/80
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local nx,ny,m=normalize(x,y)
  local a=atan2(nx,ny)
  local c=colors[flr(max(0,sin(m/16-time+m/128*cos(a*5+time/5)))*#colors)+1]
  circfill(x,y,1,c)
 end
end

--
function background_whitenoise(colors)
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local c=colors[flr(rnd(#colors+1))+1]
  
  if rnd()>.5 then
   line(x,y,x,y+5,c)
  else
   line(x,y,x+5,y,c)
  end
 end
end

--
function background_swirl(colors)
 local time=t()/80
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  
  local nx,ny,m=normalize(x,y)
  local a=atan2(nx,ny)+time
  local c=pget(x,y)
  line(x,y,x-m*.2*cos(a),y-m*.2*sin(a),c)
  if c==0 then
   local c=colors[flr(rnd(#colors+1))+1]
   pset(x,y,c)
  end
 end
end

--
function virus_function(x,y)
v=1
for i=-1,1 do
for j=-1,1 do
if(pget(x+i,y+j)!=0)v+=1
end
end
return v
end

--
function background_virus(colors)
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local v=virus_function(x,y)
   
  pset(x,y,colors[v])
  if rnd()>.9995 then
   circfill(rndb(),rndb(),rnd(24),0)
  end
 
  if rnd()>.999 then
   local c=colors[#colors]
   local n,m=rndb(),rndb()
   if(pget(n,m)==0)circfill(n,m,rnd(4),c)
  end
 end 
end

--
function background_maps(colors)
 local time=t()/40
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local r=abs(4*sin(time))
  rectfill(x-r,y-r,x+r,y+r,pget(x,y))
  if rnd()>.99 then
   local c=colors[flr(rnd(#colors+1))+1]
   rectfill(x-r,y-r,x+r,y+r,c)
  end
 end
end

--
function background_cthulhu(colors)
 local time=t()/160
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local a=atan2(x,y)+time/8
  local r=sqrt(x*x+y*y)/256*sin(time)
  local aa=time+sin(a)
  circfill(x,y,1,16*(r+a+aa)%4)
 end
end

--
function background_furryspiral(colors)
 local time=t()/160
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  local g=time-sin(time)-atan2(x,y)
  line(x,y,x+6*sin(g),y+6*cos(g),16*(sqrt(x*x+y*y)/128-g)%4)
 end
end

--
function background_blood(colors)
 if(rnd()>.95) then
  local x,y=rndb(),rndb()
  circfill(x,y,2+rnd(6),rnd()>.4 and 8 or 0)
 end
 
 for i=0,background_iter_count do
  local x,y=rndb(),rndb()
  if pget(x,y)!=8 then
   circ(x,y,1,0)
  else
   line(x,y+1,x,y+rnd(8),8)
  end
 end
end

--
bg_colors_tables={
{0,5,4},
{1,5,13},
{0,12,13},
{0,11,3},
{0,8},
{0,5,6,7},
{0,1,13,12},
{0,0,0,0,12,13,7},
{6,7,8,9,10,11,12,13,14},
{0,8,9,10,7,10,9,8},
{0,5,6,7},
{8,9,10,11,12,13,14},
{0,9,10,7,10,9},
{0,7,6},
{0,1,2,12,13,8},
{0,1,2,2,8,8,3,3,11,11},
{9,10,11,12},
{0,1,2,3},
{0,1,3,2},
{0,8},
}

--
bg_function_table=
{
 background_splatters,
 background_sphere,
 background_circles,
 background_spiral,
 background_linesandbubbles,
 background_blocks,
 background_bubbles,
 background_drip,
 background_rainbow_splat,
 background_fire, 
 background_text,
 background_rainbow_spiral,
 background_star,
 background_whitenoise,
 background_swirl,
 background_virus,
 background_maps,
 background_cthulhu,
 background_furryspiral,
 background_blood,
}

--
function background_draw()
 memcpy(0x6000,0x0,0x2000)

 background_iter_count=cpu<.9 and 50 or 20
  
 local colors=bg_colors_tables[mid(1,current_level,#bg_colors_tables)]
 local back_function=bg_function_table[mid(1,current_level,#bg_function_table)]

 back_function(colors)

 memcpy(0x0,0x6000,0x2000)
end

--
function _init()
 music(0,0,3)
 game_load()
 menuitem(1,"reset progress?!",game_reset)
 
 memcpy(0x0,0x6000,0x2000)
 circles_new_title_level()
end

--
function _update60()
 one_frame=1/stat(8)
 
 if(not is_title_level and not level_finished)game_time+=one_frame
 
 update_screeneffects()
 
 cam_update()
 
 circles_update()

 pickups_update()
 player_update()
 
 parts_update()
 
 ui_update()
end

--
function _draw()
 camera(cam_shake_x-64,cam_shake_y-64)
 
 background_draw()


 circles_draw()

 pickups_draw()
 
 parts_draw()
 player_draw()
 
 camera(0,0)
 ui_draw()
 
 cpu=stat(1)

 --[[stats and debug
 pal()
 color(7)
 y=122

 print("mem:"..stat(0),1,y)y-=6
 print("cpu:"..cpu,1,y)y-=6
 print("arrow.dis:"..arrow_disabled_t,1,y)y-=6
 
 --]]
end
__gfx__
77707770770077707770700070007070777077007770777000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700700707070707070700070007070707070700700707000000000000000000000000000000000000000000000000000000000000000000000000000000000
77700700707077007770700070007070777070700700777000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000700707070707070700070007770707070700700707000000000000000000000000000000000000000000000000000000000000000000000000000000000
70007770707077707070777077700700707070707770707000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01020000160730a07310073060530d033050130000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
01020000160630a06310053060430d023050130000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
01020000160430a04310033060330d023050130000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
01020000160230a02310023060130d013050130000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800040777004760027500574004720037200371003710037100170001700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000018554215540b5441e54408534155240651407504065040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504
00020000115402b540335301d52014520095100b51009510105000650000500005002e50000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000114610c45117451054411744109431154310942115421044210d411034110241100401004010040100401004010040100401004010040100401004010040100401004010040100401004010040100401
00030000103600c350203500534026340093301633009320193200432019310033100c3100b310003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700000b3140c3240f33413334183341c3441f34423344263442534425344233442864025640226401d6401864015640116400c640096400864005630066200362001610000000000000000000000000000004
0005000023314213241933412344183541c3641f36423364263542534425334233241e3241a33417344193541b3641e3642036422364203542634424334293242631401304003040030400304003040030400304
0007000023315213251933512335183351c3451f34523345263452534525335233251e3251a335173352c04531055370553905537055390553704539035370253901501605000050000500005000050000500005
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c7551c755007051c755217550070523755007051c7551c755007051c755237550070524755007051c7551c755007051c755247550070523755007051c7551c755007051c75523755007052175500705
011000001c333040701f3331c33321643040701c3331f3331c333040701f3331c33321643040701c3331f3331c333040701f3331c33321643040701c3331f3331c333040701f3331c33321643040701c3331f333
011000001c7551d7551f755040701f7552175504070217551c7551f755217550407021755237550407023755040702375524755217552475523755040701f75504070237551f755217551d7551f755040701d755
011000001c33321643216431c33321643216431c333216431c33321643216431c33321643216431c333216431c33321643216431c33321643216431c333216431c33321643216431c33321643040701c33321643
011000001c7551c755000051c755000051c75521755000051c7551c755000051c755217551c75523755000051c7551c755000051c755000051c75523755000051c7551c755000051c755237551c7552475500000
011000001c333040701f3331c33321643040701c3331f3331c333040701f3331c33321643040701c333216431c333040701f3331c33321643040701c3331f3331c333040701f3331c33321643040701c33321643
011000001c7551c7551d7551d7551f7551f75504070217551d7551d7551f7551f755217552175504070237551f7551f7552175521755237552375504070247552475523755217551f75523755217551f7551d755
011000001c333216431c3331c33321643216431c333216431c333216431c3331c33321643216431c333216431c333216431c3331c33321643216431c333216431c333216431c3331c33321643040701c33321643
011000002154521545005052354500505215452454500505215452154500505215452454521545265450050524545265450050524545005052654521545005052354524545005052354500505245452154500505
01100000090750907500000000000907509075000000000009075090750000000000090750907500000000002164321643090751c333216431c3331c333090752164321643090751c333216431c3331c33309075
011000002334524345003052334500300243452134500305233452434500305233452334524345213450030524345263450030524345003002634521345003002334524345003052334523345243452134500305
011000002164321643090751c33321643090751c333090752164321643090751c333216431c3331c333090752164321643090751c333216431c333090750907521643216430907509075216431c3331c33309075
011000002304524045000052304523045240450000023045230452404500005230452304524045210450000524045260450000524045240452604500000240452404526045000052404524045260452104500005
0110000021643216430907521643216431c3330907521643216431c3330907521643216431c333090750907521643216430907521643216431c3330907521643216431c3330907521643216431c3330907509075
01100000217451f745217450070023745217452374500700247452374524745237452474523745000000070023745217452374500000267452474526745000002874526745287452874529745287450000000000
01100000216431c3332164309075216431c3332164309075216431c3332164309075216431c3330000000000216431c3332164309075216431c3332164309075216431c3330907521643216431c3330000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 16 17 43 44
00 14 15 43 44
00 1a 1b 43 44
00 18 19 43 44
00 1c 1d 43 44
00 1e 1f 43 44
00 20 21 43 44
02 22 23 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
