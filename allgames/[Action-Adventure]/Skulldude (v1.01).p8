pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
-- skull dude
--by guerragames

one_frame=1/60
epsilon=.001

--
cartdata("skulldude")

--
function load_game()
 player_deaths,game_time=dget(0),dget(1)
 lup_range,lup_power,lup_rate,lup_health=dget(2),dget(3),dget(4),dget(5)
 pickups_levels_cleared1,pickups_levels_cleared2,enemies_levels_cleared1,enemies_levels_cleared2=dget(6),dget(7),dget(8),dget(9)
 player_health=dget(10)
 if(player_health==0)player_health=lup_healths[lup_health+1]
end

--
function save_game()
 dset(0,player_deaths)
 dset(1,game_time)
 dset(2,lup_range)
 dset(3,lup_power)
 dset(4,lup_rate)
 dset(5,lup_health)
 dset(6,pickups_levels_cleared1)
 dset(7,pickups_levels_cleared2)
 dset(8,enemies_levels_cleared1)
 dset(9,enemies_levels_cleared2)
 dset(10,player_health)
end

--
function reset_game()
 -- save state vars
 player_deaths,game_time=0,0
 lup_range,lup_power,lup_rate,lup_health=0,0,0,0
 pickups_levels_cleared1,pickups_levels_cleared2,enemies_levels_cleared1,enemies_levels_cleared2=0,0,0,0
 player_health=lup_healths[lup_health+1]
 save_game()
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
cam_shake_x,cam_shake_y,cam_shake_damp=0,0,0
screen_flash_timer,screen_flash_color=0,7

--
function screenflash(duration,color)
 screen_flash_timer,screen_flash_color=duration,color
end

--
function screenshake(max_radius,damp)
 local a=rnd()
 cam_shake_x,cam_shake_y,cam_shake_damp=max_radius*cos(a),max_radius*sin(a),damp
end

--
function update_screeneffects()
 cam_shake_x*=cam_shake_damp+rnd(.1)
 cam_shake_y*=cam_shake_damp+rnd(.1)
 
 if abs(cam_shake_x)<1 and abs(cam_shake_y)<1 then
  cam_shake_x,cam_shake_y=0,0
 end

 if screen_flash_timer>0 then
  screen_flash_timer-=one_frame
 end
end

--
function nl(s)
 local a={}
 local ns=""
 
 while #s>0 do
  local d=sub(s,1,1)
  if d=="," then
   add(a,ns+0)
   ns=""
  else
   ns=ns..d
  end
  
  s=sub(s,2)
 end
 
 return a
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
function fix_angle(a)
 while a>.5 do
  a-=1
 end
 
 while a<-.5 do
  a+=1
 end
 
 return a
end

--
function force_sep(fo,mo,min_sep,max_sep)
  local xdiff,ydiff=fo.x-mo.x,fo.y-mo.y
  local nx,ny,mag=normalize(xdiff,ydiff)
  local min_sep,max_sep=mag-min_sep,mag-max_sep
  if max_sep>0 then
   mo.x+=nx*max_sep
   mo.y+=ny*max_sep
  elseif min_sep<0 then
   mo.x+=nx*min_sep
   mo.y+=ny*min_sep
  end
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
function time_to_text(time)
 local mins,secs=flr(time/60),flr(time%60)
 
  if mins >= 100 then
   return "99:59"
  elseif mins > 0 then
   if secs < 10 then
    return mins..":0"..secs
   else
    return mins..":"..secs
   end
  else
   return ""..secs
  end
end

--
function spr_index_to_xy(spr_index)
 return spr_index%16*8,flr(spr_index/16)*8
end

--
function create_button(btn_num)
 return 
 {
  time_since_press=100,
  time_held=0,
  button_number=btn_num,

  button_init=function(b)
   b.time_since_press,b.time_held=100,0
  end,

  button_update=function(b)
   b.time_since_press+=one_frame

   if btn(b.button_number) then
    if b.time_held==0 then
     b.time_since_press=0
    end
  
    b.time_held+=one_frame
   else
    b.time_held=0
   end
  end,

  button_consume=function(b)
   b.time_since_press=100
  end,
 }
end

--
shoot_button=create_button(4)
dash_button=create_button(5)
shoot_button:button_init()
dash_button:button_init()


--
function round(x) return flr(x+.5) end

--
function map_coords(x,y)
 return flr(round(x)/8),flr(round(y)/8)
end

--
function solid_tall(x,y)
 local mx,my=map_coords(x,y)
 local val=mget(mx,my)
 return not fget(val,4) and (fget(val,0) or fget(val,1) or fget(val,2) or fget(val,3))
end


--
function s_floor(x,y)
 local mx,my=map_coords(x,y)
 local val,val2=mget(mx,my),mget(mx,my-1)
 return fget(val,0) and not fget(val2,2)
end

function s_ceil(x,y)
 local mx,my=map_coords(x,y)
 local val,val2=mget(mx,my),mget(mx,my+1)
 return fget(val,2) and not fget(val2,0)
end

function s_lwall(x,y)
 local mx,my=map_coords(x,y)
 local val,val2=mget(mx,my),mget(mx+1,my)
 return fget(val,3) and not fget(val2,1)
end

function s_rwall(x,y)
 local mx,my=map_coords(x,y)
 local val,val2=mget(mx,my),mget(mx-1,my)
 return fget(val,1) and not fget(val2,3)
end

--
function collision_checks(x,y,vx,vy,ws,we,hs,he)
 local new_x,new_y=x,y
 
 local on_floor,on_ceiling,on_lwall,on_rwall=false,false,false,false
 
 local nvx,nvy,vel_mag=normalize(vx,vy)
 
 local keep_looking=true
 
 while keep_looking do
  local temp_x,temp_y=new_x,new_y
  
  if vel_mag>epsilon then
   local i_vx=(vel_mag>=1) and nvx or (vel_mag*nvx) 
   local i_vy=(vel_mag>=1) and nvy or (vel_mag*nvy)
        
    if not on_floor and not on_ceiling then
     if i_vy>0 then
      if s_floor(new_x+ws+1,new_y+he+1) and not s_floor(new_x+ws+1,new_y+he-1) or 
         s_floor(new_x+we-1,new_y+he+1) and not s_floor(new_x+we-1,new_y+he-1) then
       on_floor=true
       temp_y=round(temp_y)
       nvy=0
       i_vy=0
      end
     else
      if s_ceil(new_x+ws+1,new_y+hs-1) and not s_ceil(new_x+ws+1,new_y+hs+1) or
         s_ceil(new_x+we-1,new_y+hs-1) and not s_ceil(new_x+we-1,new_y+hs+1) then
       on_ceiling=true
       temp_y=round(temp_y)
       nvy=0
       i_vy=0
      end
     end
    end
    
    if not on_rwall and not on_lwall then
     if i_vx > 0 then
      if s_rwall(new_x+we+1,new_y+hs+1) and not s_rwall(new_x+we-1,new_y+hs+1) or
         s_rwall(new_x+we+1,new_y+he-1) and not s_rwall(new_x+we-1,new_y+he-1) then
       on_rwall=true
       temp_x=round(temp_x)
       nvx=0
       i_vx=0
      end
     else
      if s_lwall(new_x+ws-1,new_y+hs+1) and not s_lwall(new_x+ws+1,new_y+hs+1) or
         s_lwall(new_x+ws-1,new_y+he-1) and not s_lwall(new_x+ws+1,new_y+he-1) then
       on_lwall=true
       temp_x=round(temp_x)
       nvx=0
       i_vx=0
      end
     end
    end
    --[[]]
    if abs(i_vy)>epsilon and abs(i_vx)>epsilon and not on_floor and not on_ceiling and not on_lwall and not on_rwall then
    if not on_floor and not on_ceiling then
     if i_vy > 0 then
      if s_floor(new_x+ws-1,new_y+he+1) and not s_floor(new_x+ws+1,new_y+he-1) or 
         s_floor(new_x+we+1,new_y+he+1) and not s_floor(new_x+we-1,new_y+he-1) then
       on_floor=true
       temp_y=round(temp_y)
       nvy=0
       i_vy=0
      end
     else
      if s_ceil(new_x+ws-1,new_y+hs-1) and not s_ceil(new_x+ws+1,new_y+hs+1) or
         s_ceil(new_x+we+1,new_y+hs-1) and not s_ceil(new_x+we-1,new_y+hs+1) then
       on_ceiling=true
       temp_y=round(temp_y)
       nvy=0
       i_vy=0
      end
     end
    end
    
    if not on_floor and not on_ceiling and not on_rwall and not on_lwall then
     if i_vx > 0 then
      if s_rwall(new_x+we+1,new_y+hs-1) and not s_rwall(new_x+we-1,new_y+hs+1) or
         s_rwall(new_x+we+1,new_y+he+1) and not s_rwall(new_x+we-1,new_y+he-1) then
       on_rwall=true
       temp_x=round(temp_x)
       nvx=0
       i_vx=0
      end
     else
      if s_lwall(new_x+ws-1,new_y+hs-1) and not s_lwall(new_x+ws+1,new_y+hs+1) or
         s_lwall(new_x+ws-1,new_y+he+1) and not s_lwall(new_x+ws+1,new_y+he-1) then
       on_lwall=true
       temp_x=round(temp_x)
       nvx=0
       i_vx=0
      end
     end
    end
    end
    --]]
    if not on_floor and not on_ceiling then
     temp_y+=i_vy
    end
  
    if not on_rwall and not on_lwall then
     temp_x+=i_vx
    end    
  
    vel_mag-=1
  else
   keep_looking=false
  end

  new_x,new_y=temp_x,temp_y
  
  if on_floor or on_ceiling then
   new_y=round(new_y)
  end
 
  if on_rwall or on_lwall then
   new_x=round(new_x)
  end
 end
 
 return {x=new_x,y=new_y,floor=on_floor,lwall=on_lwall,rwall=on_rwall,ceil=on_ceiling}
end

-- part
parts={}
parts_next=1

for i=0,400 do
 add(parts,{t=0})
end

--
function parts_spawn(t,x,y,vx,vy,d,s,ds,c,bc)
 parts_next=next_i(parts,parts_next)
 
 local p=parts[parts_next]
 
 p.t,p.x,p.y,p.vx,p.vy,p.d,p.s,p.ds,p.c,p.bc=t,x,y,vx,vy,d,s,ds,c,bc
end

--
function parts_explode(count,br,rr,t,bx,by,rx,ry,d,s,rs,ds,c,bc)
 for i=1,count do
  local a,r=rnd(),br+rnd(rr)
  local vx,vy=r*cos(a),r*sin(a)
  parts_spawn(t,bx+rnd(rx),by+rnd(ry),vx,vy,d,s+rnd(rs),ds,c,bc)
 end
end

--
function parts_update()
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
  end
 end
end

--
function part_draw(p,o,c)
 circfill(flr(p.x),flr(p.y),p.s+o,c)
end

--
function parts_draw()
 for k,p in pairs(parts) do
  if p.t>0 then
   part_draw(p,1,p.bc)
  end
 end

 for k,p in pairs(parts) do
  if p.t>0 then
   part_draw(p,0,p.c)
  end
 end
end


-- pbullets
pbullets={}
pbullets_next=1
pbullets_active_count=0

pbullets_speed=3

for i=0,50 do
 add(pbullets,{active=false})
end

--
function pbullets_spawn(t,x,y,vx,vy,s)
 local pb,i=find_next_i(pbullets,pbullets_next,pbullets_active_count)
 
 if pb then
  pbullets_next=i
  
  pbullets_active_count+=1
  pb.active=true
  
  pb.t,pb.sx,pb.sy,pb.x,pb.y,pb.vx,pb.vy,pb.s=t,x,y,x,y,vx,vy,s
  
  sfx(rnd()>.5 and 0 or 1)
 end
end

--
function pbullets_update()
 for k,pb in pairs(pbullets) do
  if pb.active then
   pb.t-=one_frame
   
   if pb.t<0 then
    pb.active=false
    pbullets_active_count-=1
   end
   
   pb.x+=pb.vx
   pb.y+=pb.vy
   
   parts_spawn(.1,pb.x,pb.y+1-rnd(2),0,0,0,1+rnd(pb.s),-.2,8,0)
   
   
   if solid_tall(pb.x,pb.y) then
    pb.active=false
    pbullets_active_count-=1

    parts_explode(20,.5,2,.2,pb.x-1,pb.y-1,2,2,.9,0,pb.s,-.2,8,0)
   end
   
   
   local m=mag(pb.x-pb.sx,pb.y-pb.sy)
   if m>=lup_ranges[lup_range+1] then
    pb.active=false
    pbullets_active_count-=1
   end
   
   --[[]]
   local x,y=pb.x,pb.y
   for k,e in pairs(enemies) do
    if e.active then
     local size=e.size
     if x+1<e.x-size or
        x-1>e.x+size or
        y+1<e.y-size or
        y-1>e.y+size then
      if(e.type.pbullets_check)e.type.pbullets_check(e,pb)
     else
      pb.active=false
      pbullets_active_count-=1
      
      enemy_damage(e,pb,lup_powers[lup_power+1])
     end
    end
   end
   --]]
  end
 end
end

-- camera

function cam_reset()
 cam_x,cam_y,target_cam_x,target_cam_y=0,0,0,0
end

--
function cam_update()
 if player_x>cam_x+128 then
  target_cam_x+=128
  enemies_reset()
 elseif player_x<cam_x then
  target_cam_x-=128
  enemies_reset()
 end
 
 if player_y>cam_y+128 then
  target_cam_y+=128
  enemies_reset()
 elseif player_y<cam_y then
  target_cam_y-=128
  enemies_reset()
 end

 if abs(cam_x-target_cam_x)>1 then
  cam_x+=.15*(target_cam_x-cam_x)
 end
 if abs(cam_y-target_cam_y)>1 then
  cam_y+=.15*(target_cam_y-cam_y)
 end
end

-- player
player_z=0

player_acc,player_damp,player_dash_rate=.2,.8,.3

lup_ranges={48,72,96,180}
lup_powers={1,2,3,4}
lup_rates={.3,.25,.2,.1}
lup_healths={3,4,5,6}

--
function player_level_up_menu()
 level_up_menu,level_up_menu_t,level_up_menu_sel,level_up_menu_sel_t=true,0,0,0
end

--
function player_level_up_update()
 level_up_menu_t+=one_frame
 
 if level_up_menu_t>1 and
    (shoot_button.time_since_press<.05 or dash_button.time_since_press<.05) and 
    level_up_menu_sel_t==0 then
  if level_up_menu_sel==0 then
   if lup_range<3 then
    lup_range+=1
    level_up_menu_sel_t=.5
   end
  elseif level_up_menu_sel==1 then
   if lup_power<3 then
    lup_power+=1
    level_up_menu_sel_t=.5
   end
  elseif level_up_menu_sel==2 then
   if lup_rate<3 then
    lup_rate+=1
    level_up_menu_sel_t=.5
   end
  elseif level_up_menu_sel==3 then
   if lup_health<3 then
    lup_health+=1
    player_health=lup_healths[lup_health+1]
    level_up_menu_sel_t=.5
   end
  end
 end
 
 if level_up_menu_sel_t>0 then
  level_up_menu_sel_t-=one_frame
  if level_up_menu_sel_t<=0 then
   level_up_menu=false
   save_game()
  end
 else
  if btnp(2) then
   level_up_menu_sel=max(0,level_up_menu_sel-1)
  end
  if btnp(3) then
   level_up_menu_sel=min(3,level_up_menu_sel+1)
  end
 end
end

--
function draw_level_up_text(t,y,index)
print_outline(t,43,y,level_up_menu_sel==index and 8 or 0,7,align_l)
end

-- 
function drawdot(i,mi,x,y)
 if(i<=mi)circfill(x,y,2,8)
 circ(x,y,2,7)
end

--
function player_level_up_draw()
 local scale=min(level_up_menu_t*level_up_menu_t,.2)*5
 
 if(level_up_menu_sel_t>0 and level_up_menu_sel_t<.2)scale=min(level_up_menu_sel_t,.2)*5
 
 local base_y=-80+scale*80+32
 
 if(level_up_menu_t>.2)base_y+=3*sin(level_up_menu_t)
 
 rectfill(32,base_y-9,96,base_y+40,0)
 rect(34,base_y-7,94,base_y+38,7)
 
 print_outline("power-up!",65,base_y-4,0,7)
 draw_level_up_text("range:",base_y+6,0)
 draw_level_up_text("power:",base_y+14,1)
 draw_level_up_text(" rate:",base_y+22,2)
 draw_level_up_text(" life:",base_y+30,3)

 for i=0,3 do
  local x=70+i*6
  drawdot(i,lup_range,x,base_y+8)
  drawdot(i,lup_power,x,base_y+16)
  drawdot(i,lup_rate,x,base_y+24)
  drawdot(i,lup_health,x,base_y+32)
 end

 print_outline(">",37,base_y+6+level_up_menu_sel*8,8,7,align_l)
end

--
function player_reset()
 player_t,player_x,player_y,player_speed,player_va,player_vx,player_vy,player_fa,player_sa,player_shooting_cooldown,player_dash_cooldown,player_closest_time,player_damaged=0,64,64,0,0,0,0,0,0,0,0,0,0
 
 player_fx,player_fy=1,0
 player_sx,player_sy=1,0
 player_closest_e=nil
 level_up_menu=false 
 
 player_gameover,player_gameover_timer=false,0
end

--
function player_damage()
  player_damaged=2

  player_health-=1
  
  local died=(player_health<=0)

  for i=1,died and 100 or 40 do
   local a,r=rnd(),.5+rnd(3)
   local vx,vy=r*cos(a),r*sin(a)
   
   if died then
    parts_spawn(2,player_x-3+rnd(6),player_y-5+rnd(6),vx,vy,.96,2+rnd(6),-.1,8,7)
   else
    parts_spawn(.4,player_x-3+rnd(6),player_y-5+rnd(6),vx,vy,.95,2+rnd(4),-.2,8,7)
   end
  end

  if died then
   sfx(9)
   player_deaths+=1
   player_gameover=true
  else
   sfx(8)
  end

  screenshake(6,.7)
  screenflash(.05,8)

  save_game()
end

--
function player_find_closest_enemy()
 local ce=nil
 local closest_m=lup_ranges[lup_range+1]

 for k,e in pairs(enemies) do
  if e.active and not e.type.chest then
   local dx,dy=e.x-player_x,e.y-(player_y-2)
   local nx,ny,m=normalize(dx,dy)
    
   if m<closest_m then
    ce=e
    closest_m=m
   end
  end
 end
 
 if ce!=player_closest_e then
  player_closest_e,player_closest_time=ce,0
 end
end

--
function player_update_aiming()
 player_closest_time+=one_frame
 
 if shoot_button.time_held<=0 then
  player_find_closest_enemy()
 else
  if player_closest_e==nil then
   player_find_closest_enemy()
  end
 end
 
 --[[]]
 if player_closest_e then
  local e=player_closest_e
   
  local closest_m=lup_ranges[lup_range+1]
   
   if e.active then
    local dx,dy=e.x-player_x,e.y-(player_y-2)
   
    if abs(dx)<closest_m and abs(dy)<closest_m then
     local nx,ny,m=normalize(dx,dy)
     
     if m<closest_m then
      
      local t=m/pbullets_speed
      
      local dx,dy=e.x+e.vx*t-player_x,e.y+e.vy*t-(player_y-2)
      local nx,ny,m=normalize(dx,dy)
      
      player_sx,player_sy=nx,ny
      player_sa=atan2(player_sx,player_sy)
     else
      player_closest_e=nil
     end
    else
     player_closest_e=nil
    end
   else
    player_closest_e=nil
   end
  end
 --]]
 
 if player_closest_e==nil then
  player_sx,player_sy,player_sa=player_fx,player_fy,player_fa
 end
end

--
function player_update()
 player_t+=one_frame
 
 if player_y<0 and not game_finished then
  game_finished,game_finished_timer=true,0
 end
 
 if game_finished then
  game_finished_timer+=one_frame
  return
 end
 
 if player_gameover then
   player_gameover_timer+=one_frame
   
   if player_gameover_timer>=1 then
    if btnp(4) or btnp(5) then
     player_gameover=false
     game_view.start()
     player_health=lup_healths[lup_health+1]
     save_game()
    end
   end
   return
 end 
 
 if(player_shooting_cooldown>0)player_shooting_cooldown-=one_frame
 if(player_dash_cooldown>0)player_dash_cooldown-=one_frame
 if(player_damaged>0)player_damaged-=one_frame
 
 local cx,cy=0,0
 
 if(btn(0))cx-=1
 if(btn(1))cx+=1
 if(btn(2))cy-=1
 if(btn(3))cy+=1
 
 local ncx,ncy,m=normalize(cx,cy)
 
 if m>0 then
  local ca=atan2(ncx,ncy)
  player_fa=atan2(player_fx,player_fy)
  
  local angle_diff=fix_angle(ca-player_fa)
  
  if abs(angle_diff)>.25 then
   player_fa=ca
  else
   player_fa+=mid(-.04,angle_diff,.04)
  end

  player_fx,player_fy=cos(player_fa),sin(player_fa) 
 end
 
 if m>0 and player_dash_cooldown<=player_dash_rate/2 then
  local max_speed=shoot_button.time_held>.2 and .4 or 1

  
  player_speed=mid(0,player_speed+player_acc,max_speed)
 else
  player_speed*=player_damp
 end
 
 -- dash mechanic
 if dash_button.time_since_press<.2 then
  if player_dash_cooldown<=0 then
   sfx(2)
   dash_button:button_consume()
   player_dash_cooldown,player_speed=player_dash_rate,6
  end
 end
 
 player_update_aiming()
 
 player_vx,player_vy=player_speed*player_fx,player_speed*player_fy
 
 
 player_cr=collision_checks(player_x,player_y,player_vx,player_vy,-3,3,-3,3)
 player_x,player_y=player_cr.x,player_cr.y
 
 if level_boss_arena then
   if (player_x-3<cam_x+9)player_x=cam_x+12
   if (player_x+3>cam_x+117)player_x=cam_x+114
   if (player_y-5<cam_y+9)player_y=cam_y+14
   if (player_y+1>cam_y+117)player_y=cam_y+116
 end
 
 if shoot_button.time_held>0 then
  if player_shooting_cooldown<=0 then
   player_shooting_cooldown=lup_rates[lup_rate+1]
   pbullets_spawn(1,player_x,player_y-2,pbullets_speed*player_sx,pbullets_speed*player_sy,lup_powers[lup_power+1])
  end
 end
 
 local shooting=(player_shooting_cooldown>0 or player_speed>.5)
 
 if shooting then
  player_z=-6+sin(player_t*10)
 else
  player_z=-6+2*sin(player_t)
 end
 
 if player_dash_cooldown<=player_dash_rate/2 then
  parts_spawn(.2+rnd(.4),player_x,player_y+player_z+4,-.2+rnd(.4),-.5-rnd(),.95,4,-.2,8,0)
 else
  parts_spawn(.2+rnd(.4),player_x,player_y+player_z+4,0,0,.95,4,-.2,8,0)
 end
end

--
function pdraw(ox,oy)
 local spri=(player_dash_cooldown>player_dash_rate/2) and 1 or 2
 spr(spri,player_x-3+ox,player_y+player_z+oy)
end

--
function player_draw()
 if player_gameover then
  local blink=(player_gameover_timer%.2>.1)
  local c=blink and 8 or 0
  local bc=blink and 0 or 8
  
  local a=min(.25,player_gameover_timer/2)
  local x,y=cam_x+64,cam_y-128+128*16*a*a
  
  print_outline("you died... again!",x,y+48,c,bc)
  print_outline("deaths:"..player_deaths,x,y+64,c,bc)
  print_outline("press any button",x,y+80,c,bc)
  print_outline("to continue!",x,y+86,c,bc)
  
  return
 end
 
 if player_damaged>0 and player_damaged%.2>.1 then
  return
 end

 for i=1,15 do
  pal(i,0)
 end 
  
 pdraw( 1, 0)
 pdraw( 1, 1)
 pdraw(-1, 0)
 pdraw(-1,-1)
 pdraw( 0, 1)
 pdraw(-1, 1)
 pdraw( 0,-1)
 pdraw( 1,-1)
 
 pal()
 
 pdraw(0,0)
end

--
function player_draw_hud()
 pal(14,0)
 for i=1,lup_healths[lup_health+1] do
  spr((i<=player_health) and 18 or 19,6*i-5,1)
 end
 pal()
 
 print_outline("-"..time_to_text(game_time).."-",64,3,8,0)
end

--
function player_draw_crosshair()
 
 if player_closest_e then
  local e=player_closest_e
  local x,y=e.x,e.y
  local s=12*mid(.6,player_closest_time*4,1)+sin(player_t*4)
  local xc=x-1
  color(0)
  circ(xc-1,y,s)
  circ(xc+1,y,s)
  circ(xc,y-1,s)
  circ(xc,y+1,s)
  circ(xc,y+2,s)
  circ(xc,y,s,8)
 
  for i=0,2,2/5 do
   local t=player_t/2+i
   local x1,y1=x+s*cos(t),y+s*sin(t)
   local x2,y2=x+s*cos(t+5/8),y+s*sin(t+5/8)
   
   line(x1+1,y1,x2+1,y2,0)
   line(x1-1,y1,x2-1,y2,0)
   line(x1,y1+1,x2,y2+1,0)
   line(x1,y1-1,x2,y2-1,0)
   line(x1,y1,x2,y2,8)   
  end
  
  rectfill(cam_x+80,cam_y+1,cam_x+126,cam_y+5,7)
  rectfill(cam_x+81,cam_y+2,cam_x+125,cam_y+4,0)
  local d=42*e.health/e.type.health
  rectfill(cam_x+82,cam_y+3,cam_x+82+d,cam_y+3,8)
 end
end

-- enemy bullets
ebs={}
ebs_next=1

for i=1,400 do
 add(ebs,{})
end

function ebs_reset()
 for k,eb in pairs(ebs)do
  eb.active=false
 end
end

function ebs_make_bullets(x,y,s,speed,count,inc_a,start_a)
 sfx(3)
 
 local ia=start_a
 for i=1,count do
  local eb=ebs[ebs_next]
  eb.x,eb.y,eb.s,eb.velx,eb.vely=x,y,s,speed*cos(ia),speed*sin(ia)
  eb.active,eb.t=true,10
  ebs_next=next_i(ebs,ebs_next)
  
  ia-=inc_a
 end 
end

--
function ebs_shoot_aimed(x,y,s,speed,count,angle)
 local nx,ny,mag=normalize(player_x-x,player_y-2-y)
 ebs_make_bullets(x,y,s,speed,count,angle/count,atan2(nx,ny))
end

--
function ebs_shoot_spread(x,y,s,speed,count,angle)
 ebs_make_bullets(x,y,s,speed,count,1/count,angle)
end

--
function ebs_check_player(eb)
 if(player_dash_cooldown>player_dash_rate/2) return
 if (player_damaged>0) return
 
 local s=eb.s/2
 
 if player_x+1<eb.x-s or
    player_x-1>eb.x+s or
    player_y-1<eb.y-s or
    player_y-3>eb.y+s then
 else
  eb.active=false
  player_damage()
 end
end

--
function ebs_update()
 for k,eb in pairs(ebs)do
  if eb.active then
   if eb.t<=0 then
    eb.active=false
   else
    eb.t-=one_frame
    eb.y+=eb.vely
    eb.x+=eb.velx
    
    if solid_tall(eb.x,eb.y) then
     eb.active=false

     parts_explode(10,.5,2,.2,eb.x-1,eb.y-1,2,2,.9,0,eb.s,-.2,7,8)
    end

    ebs_check_player(eb)
   end
  end
 end
end

--
function ebs_draw()
 for k,eb in pairs(ebs)do
  if eb.active then
   local c,bc=7,8
   if(eb.t%.2>.1)c,bc=8,7
   circfill(eb.x,eb.y,eb.s,bc)
   circfill(eb.x,eb.y,eb.s-1,c)
  end
 end
end

-- enemies
enemy_types={}

--
function enemy_shooter_init(e,size,wait)
 e.shoot_bullet_time,e.bullet_size=wait,size
 e.bullet_timer=e.shoot_bullet_time-one_frame
end

--
function enemy_shooter_adjust(e,max_shoot_rate,max_health)
 e.shoot_bullet_time=max_shoot_rate+(1-max_shoot_rate)*e.health/max_health
 if(e.bullet_timer>e.shoot_bullet_time)e.bullet_timer=e.shoot_bullet_time-one_frame
end

--
function enemy_shooter_spread(e,speed,count,angle)
 if e.bullet_timer<e.shoot_bullet_time then
  e.bullet_timer+=one_frame
   
  if e.bullet_timer>=e.shoot_bullet_time then
   e.bullet_timer=0
   ebs_shoot_spread(e.x,e.y,e.bullet_size,speed,count,angle)
  end
 end
end

--
function enemy_shooter_aimed(e,speed)
 if e.bullet_timer<e.shoot_bullet_time then
  e.bullet_timer+=one_frame
   
  if e.bullet_timer>=e.shoot_bullet_time then
   e.bullet_timer=0
   ebs_shoot_aimed(e.x,e.y,e.bullet_size,speed,1,0)
  end
 end
end

-- 
function enemy_follow_player(e,maxd,speed,aspeed)
 local nx,ny,m=normalize(player_x-e.x,player_y-e.y)

 local va,angle_diff=atan2(e.vx,e.vy),0
 
 if m>0 and m<=maxd then
  local ca=atan2(nx,ny)
  angle_diff=fix_angle(ca-va)
 else
  angle_diff=rnd(2*aspeed)-aspeed
 end

 va+=mid(-aspeed,angle_diff,aspeed)
 e.vx,e.vy=speed*cos(va),speed*sin(va) 
end

--
function enemy_follow_player_and_bounce(e,maxd,chance)
  if rnd()<chance then
   enemy_follow_player(e,maxd,e.type.speed,e.type.aspeed)
  end
  
  if (e.cr.rwall or e.cr.lwall)e.vx*=-1
  if (e.cr.floor or e.cr.ceil)e.vy*=-1
end

--
function boss_init_children(e,counter,size)
  e.children={}
  e.size,e.next_child_counter,e.next_child_size=6,counter,size
end

--
function boss_damage_spawn_children(e,d,child_counter,child_size_inc)
 local retval=nil
 if d>0 then
  e.next_child_counter-=d
  
  if e.next_child_counter<=0 then
   e.next_child_counter=child_counter
   retval={x=e.x,y=e.y,bs=e.next_child_size,size=0,t=0}
   add(e.children,retval)
   e.next_child_size+=child_size_inc
  end
 end
 
 return retval
end

--
function boss_children_pbullets_check(e,pb)
 local x,y=pb.x,pb.y
 for k,v in pairs(e.children) do
  local size=v.size
  if x+1<v.x-size or
     x-1>v.x+size or
     y+1<v.y-size or
     y-1>v.y+size then
      
  else
   pb.active=false
   pbullets_active_count-=1
   
   enemy_damage(e,pb,0)
  end
 end
end

--
function boss_draw_children(e,o,c)
 for k,v in pairs(e.children) do
  circfill(v.x,v.y,v.size+o,c)
 end
end

--
function boss_draw_eye(e)
 local x,y=e.x,e.y
 circfill(x,y,6,8)
 circfill(x,y,5,7)

 local nx,ny,m=normalize(player_x-x,player_y-y)
 circfill(x+2*nx,y+2*ny,2,0)
end

--
function boss_draw(e)
 boss_draw_children(e,1,0)
 circfill(e.x,e.y,7,0)
 boss_draw_children(e,0,8)
 boss_draw_eye(e)
end


-- angry slime
enemy_types[10]=
{
 idle_anim=nl("10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11"),
 health=10,
 speed=.5,
 aspeed=.02,
 
 init=function(e)
  enemy_shooter_init(e,2,.3)
 end,

 update=function(e)
  enemy_shooter_aimed(e,1)
  enemy_follow_player_and_bounce(e,32,.9)
 end,
}

-- hidden chest
enemy_types[16]=
{
 idle_anim={16},
 health=5,
 chest=true,
}

-- chest
enemy_types[17]=
{
 idle_anim={17},
 health=1,
 chest=true,
}

-- blob
enemy_types[32]=
{
 idle_anim=nl("32,32,32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33,33,33,"),
 health=4,
 speed=.1,
 aspeed=.04,

 update=function(e)
  enemy_follow_player_and_bounce(e,32,.8)
 end,
}

-- fast shooter
enemy_types[34]=
{
 idle_anim=nl("34,34,34,34,34,34,34,34,34,34,35,35,35,35,35,35,35,35,35,35,"),
 health=10,
 
 init=function(e)
  enemy_shooter_init(e,2,.3)
  e.shoot_a=0
 end,

 update=function(e)
  e.shoot_a+=.0005
  enemy_shooter_spread(e,.5,4,e.shoot_a)
 end,
}

-- chomper
enemy_types[36]=
{
 idle_anim=nl("36,36,36,36,36,36,36,36,36,36,37,37,37,37,37,37,37,37,37,37,"),
 health=20,
 speed=.5,
 aspeed=.01,
 
 update=function(e)
  enemy_follow_player_and_bounce(e,32,.8)
 end,
}

-- puffer
enemy_types[38]=
{
 idle_anim=nl("38,38,38,38,38,38,38,38,38,38,39,39,39,39,39,39,39,39,39,39,"),
 health=20,
 
 init=function(e)
  enemy_shooter_init(e,3,2)
  e.shoot_a=0
 end,

 update=function(e)
  e.shoot_a+=.0004
  enemy_shooter_spread(e,.5,4,e.shoot_a)
 end,
}

-- shooter blob
enemy_types[40]=
{
 idle_anim=nl("40,40,40,40,40,40,40,40,40,40,41,41,41,41,41,41,41,41,41,41,"),
 health=10,
 speed=.1,
 aspeed=.04,
 
 init=function(e)
  enemy_shooter_init(e,2,1)
 end,

 update=function(e)
  enemy_follow_player_and_bounce(e,48,.8)
  enemy_shooter_aimed(e,.6)
 end,
}


-- big boom blob
enemy_types[42]=
{
 idle_anim=nl("42,42,42,42,42,42,42,42,42,42,43,43,43,43,43,43,43,43,43,43,"),
 health=40,
 speed=.1,
 aspeed=.1,
 
 init=function(e)
  enemy_shooter_init(e,4,1)
 end,

 update=function(e)
  enemy_follow_player_and_bounce(e,96,.5)
  enemy_shooter_aimed(e,.8)
 end,
}

-- circle shooter
enemy_types[56]=
{
 idle_anim=nl("56,56,56,56,56,56,56,56,56,56,57,57,57,57,57,57,57,57,57,57,"),
 health=30,
 
 init=function(e)
  enemy_shooter_init(e,3,2)
  e.shoot_a=0
 end,

 update=function(e)
  e.shoot_a+=.0001
  enemy_shooter_spread(e,.5,16,e.shoot_a)
 end,
}

-- tiny seeker
enemy_types[58]=
{
 idle_anim=nl("58,58,58,58,58,58,58,58,58,58,59,59,59,59,59,59,59,59,59,59,"),
 health=2,
 speed=.75,
 aspeed=.01,
 
 update=function(e)
  enemy_follow_player_and_bounce(e,16,.9)
 end,
}

-- spikes
enemy_types[60]=
{
 idle_anim=nl("60,60,60,60,60,60,60,60,60,60,61,61,61,61,61,61,61,61,61,61,"),
 health=2,
}

-- growing snake boss
enemy_types[63]=
{
 idle_anim={63},
 health=100,
 speed=.8,
 aspeed=.01,

 isboss=true,
 
 init=function(e)
  enemy_shooter_init(e,2,1)
  enemy_shooter_adjust(e,.05,100)
  boss_init_children(e,5,5)
 end,

 update=function(e)
  enemy_follow_player_and_bounce(e,128,.25)
  enemy_shooter_aimed(e,1.5)
  
  local fo=e
  for k,mo in pairs(e.children) do
   mo.t+=one_frame
   mo.size=5*min(.2,mo.t)*mo.bs+sin(mo.t*3)
   
   force_sep(fo,mo,8,8)
   fo=mo
   
   enemy_check_player(mo)
  end
 end,
 
 damaged=function(e,d)
  boss_damage_spawn_children(e,d,5,.5)
  enemy_shooter_adjust(e,.05,100)
 end,
 
 pbullets_check=boss_children_pbullets_check,
 
 draw=boss_draw,
}

-- child circle boss
enemy_types[47]=
{
 idle_anim={47},
 health=250,
 speed=.5,
 aspeed=.01,

 isboss=true,
 
 init=function(e)
  enemy_shooter_init(e,2,1)
  enemy_shooter_adjust(e,.2,250)
  boss_init_children(e,5,4)

  e.shoot_a=0
 end,

 update=function(e)
  enemy_follow_player_and_bounce(e,128,.25)
  
  e.shoot_a+=.0005
  enemy_shooter_spread(e,.8,4,e.shoot_a)

  local a_sep,a,r=1/#e.children,e.t/10,40*sin(e.t/13)*(1-e.health/100)+45
  
  for k,mo in pairs(e.children) do
   mo.t+=one_frame
   mo.size=5*min(.2,mo.t)*mo.bs+sin(mo.t*3)
   
   local dx,dy=e.x+r*cos(a),e.y+r*sin(a)
   local nx,ny,m=normalize(dx-mo.x,dy-mo.y)
   
   local mag=min(1,.1*m)
   mo.x+=mag*nx
   mo.y+=mag*ny
   
   a+=a_sep
   
   enemy_check_player(mo)
  end
 end,

 damaged=function(e,d)
  boss_damage_spawn_children(e,d,5,0)
  enemy_shooter_adjust(e,.2,250)
 end,
 
 pbullets_check=boss_children_pbullets_check,
 
 draw=boss_draw,
 
}

-- poop children boss
enemy_types[46]=
{
 idle_anim={46},
 health=500,
 speed=.5,
 aspeed=.01,
 isboss=true,
 
 init=function(e)
  enemy_shooter_init(e,2,1)
  enemy_shooter_adjust(e,.15,500)
  boss_init_children(e,10,6)

  e.shoot_a=0
 end,

 update=function(e)
  enemy_follow_player_and_bounce(e,128,.25)
  
  e.shoot_a+=.002
  enemy_shooter_spread(e,.8,5,e.shoot_a)
  
  local fo=e
  for k,mo in pairs(e.children) do
   mo.t+=one_frame
   mo.size=5*min(.2,mo.t)*mo.bs+4*sin(mo.t/9)
   
   if rnd()>.9 then
    enemy_follow_player(mo,128,.2,.01)
   end
   
   mo.x+=mo.vx
   mo.y+=mo.vy

   local sep=fo.size+mo.size-2
   force_sep(fo,mo,sep,sep)
   fo=mo
   
   enemy_check_player(mo)
  end
 end,

 damaged=function(e,d)
  local child=boss_damage_spawn_children(e,d,10,0,2,.15)
  if child then
   child.vx,child.vy=0,0
  end
  
  enemy_shooter_adjust(e,.15,500)
 end,
 
 pbullets_check=boss_children_pbullets_check,
 
 draw=boss_draw,
}


-- final boss
enemy_types[62]=
{
 idle_anim={62},
 health=800,
 speed=.3,
 isboss=true,
 no_collison=true,
  
 init=function(e)
  enemy_shooter_init(e,2,.3)
  enemy_shooter_adjust(e,2,.2,800)
  boss_init_children(e,5,5)

  e.shoot_a=0
 end,

 update=function(e)
  local bx,by=cam_x+64,cam_y+64
  
  local a=e.t/8
  
  local sint=sin(a/4)
  
  local ox,oy=e.x,e.y
  e.x,e.y=bx+48*sint*cos(a),by+48*sint*sin(a)
  e.vx,e.vy=e.x-ox,e.y-oy
  
  e.shoot_a+=.001+.0005*sint
  enemy_shooter_spread(e,.5,6,e.shoot_a)

  for k,mo in pairs(e.children) do
   a-=.03
   
   mo.t+=one_frame
   mo.size=5*min(.2,mo.t)*mo.bs+sin(mo.t)

   local r=48*sin(a/4)
   dx,dy=bx+r*cos(a),by+r*sin(a)

   local nx,ny,m=normalize(dx-mo.x,dy-mo.y)
   
   local mag=min(1,.1*m)
   mo.x+=mag*nx
   mo.y+=mag*ny
   
   enemy_check_player(mo)
  end
 end,

 damaged=function(e,d)
  boss_damage_spawn_children(e,d,10,0)
  enemy_shooter_adjust(e,.2,800)
 end,
 
 pbullets_check=boss_children_pbullets_check,
 
 draw=function(e)
  circfill(e.x,e.y,7,0)
  boss_draw_children(e,0,8)
  boss_draw_eye(e)
 end,
}

--
enemies={}

level_boss_arena=false

for i=1,30 do
 add(enemies,{active=false})
end

--
function enemy_spawn(spr,x,y,level_cleared)
 
 local e,i=find_next_i(enemies,enemies_next,enemies_active_count)
 
 if e then
  enemies_next=i+1
  
  enemies_active_count+=1
  e.active=true
  
  e.type_i,e.type=spr,enemy_types[spr]
  e.anim=e.type.idle_anim
  e.health=e.type.health
  e.spawned,e.spawn_x,e.spawn_y,e.x,e.y=true,x,y,x+4,y+4
  
  local speed,a=e.type.speed or 0,rnd()
  
  e.vy,e.vx=speed*cos(a),speed*sin(a)
  
  e.size,e.anim_index,e.t,e.damaged_timer=3,1,0,0
 
  if(e.type.init)e.type.init(e)
 
  if level_cleared then
   if (e.type.isboss or e.type.chest) and not pickups_level_cleared() then
    enemy_kill(e,false,false)
   else
    enemy_kill(e,false,level_cleared)
   end
  end
 end
 
 return e
end

----
function enemy_kill(e,effect,level_precleared)
 e.active=false
 enemies_active_count-=1
 
 enemies_check_level_cleared()
 
 if(not level_precleared and (e.type.isboss or e.type.chest))pickups_spawn(e.x,e.y)
 
 if e.type.isboss then
  level_boss_arena=false

  if(effect)screenflash(.1,7)sfx(7)

 else
  if(effect)screenflash(.025,7)sfx(5)
 end

 if(effect)screenshake(6,.7)
end

--
function enemy_damage(e,pb,d)
 
 if(e.type.chest and enemies_active_count>1)return

 if d>0 then
  e.health-=d
  if(e.type.damaged)e.type.damaged(e,d)
  e.damaged_timer=.1
 end
 
 if e.health<=0 then
  if e.type.isboss then
   parts_explode(80,.5,5,2,e.x+1,e.y+1,6,6,.98,1,8,-.1,8,0)
  else
   parts_explode(20,.5,3,.4,e.x+1,e.y+1,6,6,.95,1,3,-.2,8,0)
  end
  
  enemy_kill(e,true,false)
 else
  parts_explode(10,.5,2,.2,pb.x+1,pb.y+1,2,2,.9,0,pb.s+2,-.2,8,0)
 end
end

--
function enemy_draw(e,ox,oy)
 spr(e.anim[e.anim_index],e.x-4+ox,e.y-4+oy,1,1,e.anim_flip)
end

--
function enemy_check_player(e)
 if(e.type and e.type.chest)return
 if(player_dash_cooldown>player_dash_rate/2) return
 if (player_damaged>0) return
 
 local size=e.size
 if player_x+1<e.x-size or
    player_x-1>e.x+size or
    player_y-1<e.y-size or
    player_y-3>e.y+size then
 else
  player_damage()
 end
end

--
function enemies_update_level_spawn()
 level_boss_arena=false
 
 local level_cleared=false 
 local level_mask1,level_mask2=cam_to_level_mask()
 if band(enemies_levels_cleared1,level_mask1)!=0 or band(enemies_levels_cleared2,level_mask2)!=0 then
  level_cleared=true
 end
 
 for x=target_cam_x,target_cam_x+128,8 do
  for y=target_cam_y,target_cam_y+128,8 do
   local mx,my=map_coords(x,y)
   
   local tile_spr=mget(mx,my)
   if fget(tile_spr,7) then
    local e=enemy_spawn(tile_spr,mx*8,my*8,level_cleared)
   
    if(not level_cleared and e.type.isboss)level_boss_arena=true
   end
  end
 end
end

--
function cam_to_level_num()
 return flr(target_cam_y/128)*8+flr(target_cam_x/128)
end

--
function cam_to_level_mask()
 local level_num=cam_to_level_num()
 
 if level_num<16 then
  return shl(0x1,level_num),0
 else
  return 0,shl(0x1,level_num-16)
 end
end

--
function enemies_check_level_cleared()
 if enemies_active_count<=0 then
  local level_mask1,level_mask2=cam_to_level_mask()
  enemies_levels_cleared1,enemies_levels_cleared2=bor(enemies_levels_cleared1,level_mask1),bor(enemies_levels_cleared2,level_mask2)
  save_game()
 end
end

--
function enemies_reset()
 pickups_reset()
 
 for k,e in pairs(enemies) do
  e.active,e.spawned=false,false
 end
 
 enemies_next,enemies_active_count,enemies_spawn_x=1,0,0
 
 enemies_update_level_spawn()
end

--
function enemies_update()
 for k,e in pairs(enemies) do
  if e.active then
   e.t+=one_frame
   
   local damaged=(e.damaged_timer>0)
   
   if damaged then
    e.damaged_timer-=one_frame
   end
   
   if not damaged or e.type.isboss then
    e.anim_index=next_i(e.anim,e.anim_index)
   end
   
   enemy_check_player(e)
   
   if not e.type.no_collison then
    e.cr=collision_checks(e.x,e.y,e.vx,e.vy,-e.size,e.size,-e.size,e.size)
    e.x,e.y=e.cr.x,e.cr.y
   end
  
   if (e.x<target_cam_x+8)e.x=target_cam_x+8
   if (e.x>target_cam_x+120)e.x=target_cam_x+120
   if (e.y<target_cam_y+8)e.y=target_cam_y+8
   if (e.y>target_cam_y+120)e.y=target_cam_y+120
  
   if(e.type.update)e.type.update(e)
   
   if(e.anim_flip and e.vx>.01)e.anim_flip=false
   if(not e.anim_flip and e.vx<-.01)e.anim_flip=true
  end
 end
 
end

--
function enemies_level_draw()
 --[[]]
 for k,e in pairs(enemies) do
  if e.spawned then
   local mx,my=map_coords(e.spawn_x,e.spawn_y)
   local tile_spr=mget(mx-1,my)
   spr(tile_spr,e.spawn_x,e.spawn_y)
  end
 end
 --]]
 
 if level_boss_arena then 
  rect(cam_x+10,cam_y+10,cam_x+118,cam_y+118,8)
  rect(cam_x+8,cam_y+8,cam_x+120,cam_y+120,8)
 end
end

--
function enemies_draw()
 
 for k,e in pairs(enemies) do
  if e.active then
   if not e.type.isboss then
    for i=1,15 do
     pal(i,(e.damaged_timer>0) and 7 or 0)
    end
    
    enemy_draw(e, 1, 0)
    enemy_draw(e,-1, 0)
    enemy_draw(e, 0, 1)
    enemy_draw(e, 0,-1)
    enemy_draw(e, 1, 1)
    enemy_draw(e,-1,-1)
    enemy_draw(e,-1, 1)
    enemy_draw(e, 1,-1)
   end
   
   if e.damaged_timer>0 then
    pal(7,8)
    pal(8,7)
   else
    pal()
   end
   
   if(not e.type.isboss)enemy_draw(e,0,0)
   
   if(e.type.draw)e.type.draw(e)
  end
 end

 pal()
end


-- pickups
pickups={}

for i=1,12 do
 add(pickups,{active=false})
end

--
function pickups_reset()
 for k,pu in pairs(pickups) do
  pu.active=false
 end

 pickups_next,pickups_active_count=1,0
end

--
function pickups_check_level_cleared()
 local level_mask1,level_mask2=cam_to_level_mask()
 pickups_levels_cleared1,pickups_levels_cleared2=bor(pickups_levels_cleared1,level_mask1),bor(pickups_levels_cleared2,level_mask2)
 save_game()
end

--
function pickups_level_cleared()
 local level_mask1,level_mask2=cam_to_level_mask()
 return band(pickups_levels_cleared1,level_mask1)!=0 or band(pickups_levels_cleared2,level_mask2)!=0
end

--
function pickups_spawn(x,y)
 if(pickups_level_cleared())return
 
 local pu,i=find_next_i(pickups,pickups_next,pickups_active_count)

 if pu then
  pickups_next=i
  
  pickups_active_count+=1
  pu.active,pu.x,pu.y,pu.t=true,x,y,0  
 end
end

--
function pickups_update()
 for k,pu in pairs(pickups) do
  if pu.active then
   pu.t+=one_frame
   
   -- check for player touch
   if pu.x+3<player_x-3 or
      pu.x-3>player_x+3 or
      pu.y+3<player_y-3 or
      pu.y-3>player_y+3 then
   else
    sfx(4)
    pickups_active_count-=1
    pu.active=false
    pickups_check_level_cleared()
    if lup_range>=3 and lup_power>=3 and lup_rate>=3 and lup_health>=3 then
     player_health=lup_healths[lup_health+1]
    else
     player_level_up_menu()
    end
   end
  end
 end
end

--
function pickups_draw()
   
 for k,pu in pairs(pickups) do
  if pu.active then
   pal(14,0)
   spr(5,pu.x-3,pu.y-5-2*sin(pu.t*2))
   pal()
  end
 end
end


-- level

function level_draw()
 map(0,0,0,0,128,64,0x20)
 enemies_level_draw()
end

-- front end
fe_view={}

fe_time,fe_button_presses,fe_button_impulse,fe_fullscale=0,0,0,false

--
fe_view.start=function()
end

--
fe_view.update=function()
 fe_time+=one_frame
 
 if not fullscale then
  if(fe_time*fe_time>.5)fe_fullscale=true
 end
 
 if shoot_button.time_since_press<.2 or dash_button.time_since_press<.2 then
  shoot_button:button_consume()
  dash_button:button_consume()
  fe_button_presses+=.4
  fe_button_impulse=.1
  
  sfx(6)
  
  if fe_button_presses>3 then
   current_view=game_view
   current_view.start()
  end
 end
 
 
 if fe_button_presses>0 then
  fe_button_impulse,fe_button_presses=max(0,fe_button_impulse-one_frame),max(0,fe_button_presses-one_frame)
  
  parts_spawn(4+rnd(4),64,88,-2+rnd(4),-2-rnd(4),.97,36*min(1,fe_button_presses)+50*fe_button_impulse,-1-rnd(.5),8,7)
 end
 
 parts_update()
end

--
function draw_big_skull(ox,oy,s)
 pal(14,0)
 local spr1x,spr1y=spr_index_to_xy(12)
 sspr(spr1x,spr1y,16,16,64-s/2+ox,64-s/2+oy,s,s)
end

--
fe_view.draw=function()
 --[[
 cls()
 map(0,0,0,0,128,64)
 --]]
 
 --[[
 for r=100,0,-4 do
  v=r/64+fe_time
  circfill(64+8*sin(v),77+8*cos(v),r,flr(r/8%2)*7)
 end 
 --]]
 
 --[[]]
  local t=fe_time/2
  for r=220,0,-8 do
   circfill(61+cos(t)*r*.55,77+sin(t)*r*.55,r,flr(r/8%2)*7)
  end 
 --]]
 
 parts_draw()
 
 local scale=fe_fullscale and 1 or 2*min(.5,fe_time*fe_time)
 
 draw_big_skull(rnd(4*fe_button_presses)-2,rnd(4*fe_button_presses)+14,64*scale)

 pal()
 print_outline("skulldude",64,40*scale-8,8,0)
 print_outline("press any button to start!",64,172-64*scale,8,0)
 print_outline("guerragames 2017",64,181-60*scale,8,7)

end

-- game view
game_view={}

--
game_view.start=function()
 cam_reset()
 enemies_reset()
 player_reset()
end

--
game_view.update=function()
 if(not game_finished and not player_gameover)game_time+=one_frame

 update_screeneffects()
 if screen_flash_timer>0 then
  return
 end
 
 if level_up_menu then
  player_level_up_update()
  return
 end
 
 --[[debug cheats
 if btnp(0,1) then
  if flr(player_x/128)>0 then
   enemies_check_level_cleared()
   target_cam_x-=128
   cam_x-=128
   player_x-=128
   enemies_reset()
  end
 end
 if btnp(1,1) then
  if flr(player_x/128)<7 then
   enemies_check_level_cleared()
   target_cam_x+=128
   cam_x+=128
   player_x+=128
   enemies_reset()
  end
 end
 if btnp(2,1) then
  if flr(player_y/128)>0 then
   enemies_check_level_cleared()
   target_cam_y-=128
   cam_y-=128
   player_y-=128
   enemies_reset()
  end
 end
 if btnp(3,1) then
  if flr(player_y/128)<3 then
   enemies_check_level_cleared()
   target_cam_y+=128
   cam_y+=128
   player_y+=128
   enemies_reset()
  end
 end
 --]]

 parts_update()
 player_update()
 enemies_update()
 ebs_update()
 cam_update()
 pbullets_update()
 pickups_update() 
end

--
function drawswirls(scale,os,c)
 for r=0,90*scale do
  local q=.05*sin(r/32-player_t)
  for a=0,1,.1 do
   circfill(64+r*cos(a+q),64+r*sin(a+q),r/14+os,c)
  end
 end
end

--
game_view.draw=function()
 cls()
 
 --if(not game_finished)game_finished_timer=0
 --game_finished=true
 if game_finished then
  local scale=min(2,game_finished_timer)/2
  drawswirls(scale,0,8)
  local s=max(0,64*scale+24*sin(player_t/2))
  draw_big_skull(8*cos(player_t/4),8*sin(player_t),s)
  
  pal()
  player_draw_hud()
  
  print_outline("congratulations!",64,56,8,0)
  print_outline("skulldude's reign of terror",64,64,8,0)
  print_outline("prevails!",64,72,8,0)
  print_outline("deaths:"..player_deaths,64,88,8,0)
  return
 end
 
 if screen_flash_timer>0 then
  cls(screen_flash_color)
  return
 end
 
 camera(cam_x+cam_shake_x,cam_y+cam_shake_y)
 
 level_draw()
 
 player_draw_crosshair()
 enemies_draw()
 parts_draw()
 pickups_draw()
 player_draw()
 ebs_draw()
 
 camera()
 player_draw_hud()
 
 if level_up_menu then
  player_level_up_draw()
 end
end


--

current_view=fe_view
current_view.start()

--
function _init()
 music(0)
 --menuitem(1,"level up!",player_level_up_menu)
 menuitem(1,"reset progress!?",reset_game)

 load_game()
end

--
function _update60()
 shoot_button:button_update()
 dash_button:button_update()
 
 current_view.update()
end

--
function _draw()
 current_view.draw()
 
 --print_outline("mem:"..stat(0),1,116,0,7,align_l) 
 --print_outline("cpu:"..stat(1),1,122,0,7,align_l) 
end
__gfx__
000000000000000000000000000000000770770000eeee0000000000000000000000000000000000000000000000000000eeeeeeeeeeee000000000000000000
00000000000000000777770000000000788788700ee77ee000000000000000000000000000000000007770000000000000e7777777777e000000000000000000
0000000000777000777777700077700078888870ee7887ee000000000000000000000000000000000777770000777000eee7777777777eee0000000000000000
0000000007878700700700700707070007888700e787887e000000000000000000000000000000007787778007777700e77777777777777e0000777777770000
0000000007777700708780700787870000787000e788887e000000000000000000000000000000007778787077877780e77777777777777e0007777777777000
0000000000777000777777700777770000070000ee7887ee000000000000000000000000000000007777777077787870e77777777777777e0007777777777700
00000000000000000707070000707000000000000ee77ee0000000000000000000000000000000007777777077777770e77eeee77eeee77e0077787777778700
000000000000000000000000000000000000000000eeee00000000000000000000000000000000000777770007777700e77e00e77e00e77e0077788777788700
00000000000000000eeeee000eeeee000eeeee000eeeee00000000000000000000000000000000000000000000000000e77e00e77e00e77e0077788877888700
0000000007777770ee8e8ee0ee7e7ee0ee777ee0ee777ee0000000000000000000000000000000000000000000000000e77eeee77eeee77e0777777777777700
0000000077888777e88888e0e7e7e7e0e7e7e7e0e7eee7e0000000000000000000000000000000000000000000000000e77777777777777e0777777777777700
0007000078888877e88888e0e7eee7e0e78787e0e7eee7e0000000000000000000000000000000000000000000000000e77777777777777e0777787878787700
0000000077777777ee888ee0ee7e7ee0e77777e0e7e7e7e0000000000000000000000000000000000000000000000000eee77ee77ee77eee0777787878787700
00000000788788770ee8ee000ee7ee00ee7e7ee0ee7e7ee000000000000000000000000000000000000000000000000000e77ee77ee77e000777787777787700
000000007888887700eee00000eee0000eeeee000eeeee0000000000000000000000000000000000000000000000000000eeeeeeeeeeee000077777777777000
00000000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777777770000
00000000000000000077770000000000007770000000000000000000007777000000000000000000000000000007700000000000000000000000000000000000
00777000000000000777777000777700077777700077700000777700077887700077700000000000000000000078870000000000000000000770077707700777
07777700007770000787787007777770777888770777777007788770777777770777770000777000007777000788887000000000000000000707000707070007
77787870077777000787787007877870777777777777888707888870770770777788888007777700078888700787877000000000000000000770077707700777
77787870777878700070070007877870707070707777777707788770700000077788788077888880788787870788887000000000000000000707000707070700
77777770777878700070070000700700700000007070707007777770700000077777777077887880788888870788887000000000000000000770077707700777
77777770777777700007700000077000770707077707070707700770770770777777777077777770788888870788887000000000000000000000000000000000
07777700077777000007700000777700077777700777777000777700077777700777770007777700077777700077770000000000000000000000000000000000
00077000000000000000000077700777070770770000000000070070000000000077770000000000000000000000000000000000000000000000000000000000
00077000007007000077770077000077700777770707707700007770000700700078870007777770000770000000000007000700000000000770070707700070
07777770007007000778877077000077700087800707777707007887000077700777777007888870007777000007700000707000707070700707070707070770
77877877077777707778877707777770070077707000878070007777000078870707007077777777007878000077770007787700077877000770077707700070
77877877788778877777777700788700077770707000777070007700077077770700007070070007007777000078780000888000008880000707000707070070
07777770777777777700007700788700077770000777707070077770700077000700007070000007007777000077770007787700077877000770000707700777
00700700077007707000000700777700700007000777700007777700700777000700707077007077000000000000000000707000707070700000000000000000
00700700007007007000000700000000000000000700700000777000077770700077770007777770000000000000000007000700000000000000000000000000
00000000000000000000000070707070707070707070707000000000000000000777770007777770777777770000000070000070007770707070707000000000
00000000000000000000000000000000000000000000000000000000000000000700070007000070700000070000000000770000000000000000000000000000
00707070707070707070707070777777777777777777707000077077700770000707070007077070707777070000000070707000000770700777077700770077
00000000000070000000700000770707070707070707700000707707007070700700070007077070707777070000000000777070007070000707070707070707
00707770777000707070007070700077007700770077707000777777777700000777770007000070707777070000000070000000007770700077007707770777
00000000777707707077700000770000000000000000700000007000007700007000007007777770700000070000000000770000000000000000000000000000
00770770777707707077707070707077700700070007707000077070707070000000000770000007777777770000000070707000000770707007000770707070
00000770000007700000000000777070000000000070700000707000007770700000000000000000000000000000000000777070007070000000000000000000
00707770777077707770707070700070000000000077707000777070707000700000000000000000000000007000700070707070000000000000000000000000
00000000777000007770700000770000000000000000700000007000007700000707070707070707070707000707770007070707077707070707770000000000
00707770077077700770707070707000000000000007707000077777777070000077777777777777777770000077707077707070070007070700700000000000
00007777000077770000000000777070000000000070700000707707007070000777777777777777777777000777000707070707077000700700700000000000
00707770077077700707077070700000000000000077707000777077700770700077777777777777777770007770707770707770070007070700700000000000
00000000777000007707000000770000000000000000700000000000000000700777777777777777777777000700077707077777077707070700700000000000
00770770777707707707707070707000000000000007707000070007700077700077777777777777777770000070777077707770000000000000000000000000
00000770000007700000000000777070000000000070700000000000000000000777777777777777777777000007770707070707000000000000000000000000
00707770777077707777077070700000000000000077707077707770770777700077777777777777777770007000700077707770707077700000000000000000
00000000777000007000000000770000000000000000700077707000770777700777777777777777777777000707070770700000707000000000000000000000
00707770000077700077707070707077007700770077707007707070000000000077777777777777777770000070007007707770077077700000000000000000
00000777777077707777700000777707070707070707700007000070777077770777777777777777777777000707000700007077000070070000000000000000
00770770007077700077707070777777777777777777707000070770777077700077777777777777777770007000707007707770077077700000000000000000
00000000700000007000000000000000000000000000000077070000000077700777777777777777777777000700070070700000707000000000000000000000
00707070707070707070707070707070707070707070707077077070707077700077777777777777777770007070707077770770707707700000000000000000
00000000000000000000000000000000000000000000000000000000000000000777777777777777777777000007000700000770000007000000000000000000
70707070700700707007007777707770007777707007007077077070007077700077777777777777777770007770777077707770000000000000000000000000
00000000007770000077700077077707070000070070700077007000000077700777777777777777777777000000000070700000000000000000000000000000
07070707700700707777007070707070700707000700070707700070707000000077777777777777777770007077707700707770000000000000000000000000
00000000770007777700077707770777707000707007007700007000000077770777777777777777777777000000000070700077000000000000000000000000
70707070700700707007777077707770700000000700070707707770777077700077777777777777777770007770777000707770000000000000000000000000
00000000007770000077700007077707707000700070700077700770777077700707070707070707070707000000000070700000000000000000000000000000
07070707700700707007007770707077700707007007007077770770777077700000000000000000000000007077707777707770000000000000000000000000
00000000770007707700077707770777070000070077700700000000000000000000000000000000000000000000000000000070000000000000000000000000
34444444444444444444444444444454344444444444750525654444444444543444444444447505256544444444445434444444444444444444444444444454
34444444444475052565444444444454344444444444750525654444444444543444444444447505256544444444445434444444444475052565444444444454
35041414141414141414141414142455350414141414147767141414141424553504141414141477671414141414245535041414141414141414141414142455
350414141414147767141414141424553504141424a4047767141414141424553504141414141477671414141414245535041414141414776714141414142455
35051515151582151582151515152555350515621515151515151515621525553505178217821717171782178217255535051515151515151515151515152555
350566161616161616161616167625d4c405171725a4051717171717171725553505d6d6d6d6d6d6d6d6d6d6d6d625553505c6c6c6c6c6c6c6c6c6c6c6c62555
35056616167615151515661616762555350515151515151515151515151525553505176616761717171766167617255535051511151515151515151515c32555
350525b7b7b7b7b7b7b7b7b7b70525d4c405171725a4051717171717171725553505d6d6d6d6d6d6d6d6d6d6d6d625553505c6c6c6c6c6c6c6c6c6c6c6c62555
350525575705661616762557570525553505151585959595959595a5151525553505172584051717171725840517255535051515151515151515151515c32555
350525b7b7b7b7b7b7b7b7b7b70525553505171725a4051717171717171725553505d6d6d6d6d6d6d6d6d6d6d6d625553505c6c6c6c6c6c6a3c6a3c642c62555
350525575705258484052557570525553505151586969697979696a6151525d4c405172584051717171725840517255535051515158315151515151515c32555
350525b7b7b7b7b7b7b7b7b7b70525553505171725a4051717171717171725553505d6d6d6d6d6d6d6d6d6d6d6d625553505c6c6c6c6c6c6a3c6a3c642c62555
35056714147725848405671414772565750515158696a784848796a6151525d4c406162684061616161626840616265535051515151515151515151515c32565
750525b7b7b7b7b7b7b7b7b7b70525553505171725a4051717171717171725553505d622d6d6a0d6d6a0d6d6d6d625657505c6c6c6c6c6c6a3c6a3c642c62555
350515151515258484051515151567141477151586a68484848486a61515255535a4a4a4a4a4a4a4a4a4a4a4a4a4a45535051515151515151515151515c36714
147725b7b7b7b7a3b7a3b7a3b70525553505171725a405171717171717a025d4c405d6d6d6d6d6d6d6d6d6d6d6d667141477c6c6c6c6c6c6a3c6a3c642c62555
350566161616268484061616161616161676151586a68484848486a61515255535a4a4a4a4a4a4a4a4a4a4a4a4a4a45535051515151515151515151515c36616
167625b7b7b7b7a3b7a3b7a3b70525553505171725a405171717171717a025d4c405d6d6d6d6d6d6d6d6d6d6d6d666161676c6c6c6c6c6c6a3c6a3c642c62555
350525a4a4a4a48484a4a4a4a4848464740515158696a584848596a6151525553504142484041414141424840414245535051515151515151515151515c32564
740525b7b7b7b7a3b7a3b7a3b70525553505171725a4051717171717171725553505d622d6d6a0d6d6a0d6d6d6d625647405c6c6c6c6c6c6a3c6a3c642c62555
350567141414141414141414141424553505151586969695959696a6151525553505172584051717171725840517255535051515151515151515831515c32555
350525b7b7b7b7a3b7a3b7a3b70525553505171725a4051717171717171725553505d6d6d6d6d6d6d6d6d6d6d6d625553505c6c6c6c6c6c6a3c6a3c642c62555
350515151515151515151515151525553505151587979797979797a7151525553505172584051717171725840517255535051515151515151515151515c32555
350525b7b7b7b7a3b7a3b7a3b70525553505171725a4051717171717171725553505d6d6d6d6d6d6d6d6d6d6d6d625553505c6c6c6c6c6c6a3c6a3c642c62555
35051582151566161676151582152555350515151515151515151515151525553505176714771717171767147717255535051515151515151515151515c32555
350525b7b7b7b7b7b7b7b7b7b70525553505171725a4051717171717171725553505d622d6d622d6d622d6d6d6d625553505c6c6c6c6c6c6c6c6c6c6c6c62555
35051515151525575705151515152555350515621515151515151515621525553505178217821717171782178217255535051515151515151515151515152555
350567141414141414141414017725553505171125a4051717171717171725553505d6d6d6d6d6d6d6d6d6d6d6d625553505c6c6c6c6c6c6c6c6c6c6c6c62555
35061616161626575706161616162655350616161616167666161616161626553506161616161676661616161616265535061616161616766616161616162655
350616161616161616161616161626553506161626a4067666161616161626553506161616161616161616161616265535061616161616766616161616162655
36464646464674575764464646464656364646464646740525644646464646563646464646467405256446464646465636464646464674052564464646464656
36464646464646464646464646464656364646464646740525644646464646563646464646464646464646464646465636464646464674052564464646464656
34444444444475575765444444444454344444444444750525654444444444543444444444447505256544444444445434444444444475052565444444444454
34444444444444444444444444444454344444444444750525654444444444543444444444444444444444444444445434444444444475052565444444444454
3557575757575757575757575757575535041414141414776724a40414142455350414141414147767141414141424553585959595959595959595959595a555
350414141414141414141414141424553504141414141477671414141414245535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535041414141414776714141414142455
3557575757575757575757575757575535050707070707070725a40507622555350507070707661616760707070725553586969696969696969696969696a655
35051515a3661616161616761515255535058595959595959595959595a5255535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535051515151515151515151515152555
3557575757575757575757575757575535050707070707070725a40507072555350507070707258484050707070725553586969696429696429642969696a655
35051515a325a4a4a4a4a40515a3255535058637373737373737373737a6255535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535051515151515151515151515152555
3557575757575757575757575757575535050707070707070725a40507072555350507070707258484050707070725553586969696969696969696969696a655
35051515a36714141424a4051515255535058637373737373737373737a6255535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535051515151515150215151502152555
3557575757575757575757575757575535050707661676070725a40507072555350507070707671414770707070725553586969696969696969696969696a655
35061616161676151525a4051515255535058637373737373737373737a6255535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535051515151502151515021515152555
3557575757575757575757575757575535050702258405070225840507072565750566161676070707076616167625657586969696969696969696429696a665
75a4a4a4a4a405151525a40515a3256575058637373737373737373737a6255535b6b6b6b6b6b6b6b6b6b6b6b6b6b66575061676151515150215151502152555
3557575757575757575757575757575535050707258405070725840507076714147725848405070722072584840567141486969696969696969696964296a614
1414141414147715a325a4051515671414778637373737373737373737a6255535b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b605151502151515021515152555
3557575757575757575757575757575535050782258405078225840507076616167625848405070707072584840566161686969696969696969696964296a616
1616161616167615a325a40515156616167686373737373737a237a237a6255535b6b6b6b6b6b6e2b6b6b6b6b6b6b6b6b6b6b605151515150215151502152555
35575757575757f357575757575757553505070725a405070725a40507072564740567141477070707076714147725647486969696969696969696429696a664
74a4a4a4a4a405151525a40515a325647405863737373737a237a23737a6255535b6b6b6b6b6b6b6b6b6b6b6b6b6b66474041477151502151515021515152555
355757575757575757575757575757553505070725a406161626a40507072555350507070707661616760707070725553586969696969696969696969696a655
35041414141477151525a40515152555350586373737373737a237a237a6255535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535051515021515151115151502152555
355757575757575757575757575757553505070725a4a48484a4a40507072555350507070707258484050707070725553586969696429696429642969696a655
35051515a36616161626a405151525553505863737373737a237a23737a6255535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535051515151502151515021515152555
3557575757575757575757575757575535050707671414141414147707072555350507070707258484050707070725553586969696969696969696969696a655
35051515a325a4a4a4a4a40515a3255535058637373737373737373711a6255535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535051515021515150215151502152555
3557575757575757575757575757575535050707070707074207070707072555350507070707671414770707070725553586969696969696969696969696a655
35051515a3671414141414771515255535058797979797979797979797a7255535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535051515151502151515021515152555
3557575757575757575757575757575535061616161616161616161616162655350616161616161616161616161626553587979797979797979797979797a755
350616161616161616161616161626553506161616161616161616161616265535b6b6b6b6b6b6b6b6b6b6b6b6b6b65535061616161616161616161616162655
36464646464646464646464646464656364646464646464646464646464646563646464646464646464646464646465636464646464646464646464646464656
36464646464646464646464646464656364646464646464646464646464646563646464646464646464646464646465636464646464646464646464646464656
__gff__
000000000000000000008080000080008080000000000000000000000000000080808080808080808080808000008080000000000000000080808080808080802020202f2f2f2f2f2f3f3f00202020202020202f202f2f2f20202020202020002020202f2f2f2020202020202020000020202020202020202020202020000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4344444444444444444444444444444543444444444444444444444444444445434444444444444444444444444444454344444444444444444444444444444543444444444444444444444444444445434444444444444444444444444444454344444444444444444444444444444543444444444457545456444444444445
5340414141414141414141414141425553404141414141414141414141414255534041414141414141414141414142555340414141414141414141414141425553404141414141414141414141414255536b6b6b6b6b6b6b6b6b6b6b6b6b6b555340414141414141414141414141425553545454545454545454545454545455
5350515151515151515151515151524d4c505111515151515151515151515255535066616161616161616161616752555350666161616167666161616167525553506661616161676661616161675255536b6b6b6b6b6b6b6b6b6b6b6b6b6b5553506661616161616161616161675255535454545454545d5e54545454545455
535051515151515151515151515152555350515151515151245151515151525553505273737373733c737373735052555350527373737350527373737350525553505273737373505273737311505255536b6b6b6b6b6b6b6b6b6b6b6b6b6b555350525b5b5b5b5b5b5b5b5b1050525553545454545454545454545454545455
5350516661675151515166616751525553505151515151515151515151515255535052732a73733c7373732a73505255535052732273735052733a737350525553505273247373505273732473505255536b6b6b6b3c6b6b6b3c6b6b6b6b6b555350525b5b5b5b5b5b5b285b5b50525553545454545454545454545454545455
5350515248505859595a5248505152555350515151515151515151515151525553505273737373733c73737373505255535052737373735052733a737350525553505273737373606273737373505255536b6b6b3c6b3c6b3c6b3c6b6b6b6b555350525b5b5b5b5b5b285b285b50525553545454545454543e54545454545455
5350515248506869696a52485051525553505151515151512451515151515256575052732873733c7373732873505256575052737373735052733a737350525657505273737373737373737373505255536b6b3c6b6b6b3c6b6b6b3c6b6b6b565750525b5b5b5b5b285b285b2850525553545454545454545454545454545455
5350515248506869696a5248505152555350515151515151515151515151764141775273737373733c73737373507641417752737373735052733a737350764141777641414273733873404141775255536b6b6b3c6b6b386b6b3c6b6b6b6b414177525b5b5b5b5b5b285b285b50525553545454545454545454545454545455
5350515248507879797a52485051525553505151515151515151515151516661616752737373733c737373737350666161675273733a7350527373737350666161676661616273737373606161675255536b6b6b3c6b226b226b3c6b6b6b6b616167525b5b5b5b5b5b5b285b5b50525553545454545454545454545454545455
535051764177515151517641775152555360616161616161616161616161624647505273287373733c7373287350524647505273733a7350527373737350524647505273737373737373737373505255536b6b3c6b6b6b3c6b6b6b3c6b6b6b464750525b5b5b5b5b5b5b5b5b5b50525553545454545454545454545454545455
53505151516661616161675151515255534a4a4a4a4a4a4a4a4a4a4a4a4a4a55535052737373733c737373737350525553505273733a7350527373737350525553505273737373404273737373505255536b6b6b3c6b3c6b3c6b3c6b6b6b6b555350525b5b5b5b5b5b5b5b5b5b50525553545454545454545454545454545455
5350515151524a4a4a4a50515151525553404141412641414141264141414255535052732a7373733c73732a7350525553505273733a7350527373227350525553505273247373505273732473505255536b6b6b6b3c6b6b6b3c6b6b6b6b6b555350525b5b5b5b5b5b5b5b5b5b50525553545454545454545454545454545455
5350515151764141414177515151525553505151515151515151515151515255535052737373733c73737373735052555350527373737350527373737350525553505273737373505273737373505255536b6b6b6b6b6b6b6b6b6b6b6b6b6b555350525b5b5b5b5b5b5b5b5b5b50525553545454545454545454545454545455
5350515151515151515151515111525553505151515151515151515151515255535076414141414141414141417752555350764141414177764141414177525553507641414141777641414141775255536b6b6b6b6b6b6b6b6b6b6b6b6b6b555350764141414141414141414177525553545454545454545454545454545455
5360616161616167666161616161625553606161616161676661616161616255536061616161616766616161616162555360616161616161616161616161625553606161616161676661616161616255536b6b6b6b6b6b6b6b6b6b6b6b6b6b555360616161616167666161616161625553545454545454545454545454545455
6364646464644750524664646464646563646464646447505246646464646465636464646464475052466464646464656364646464646464646464646464646563646464646447505246646464646465636464646464475052466464646464656364646464644750524664646464646563646464646447545446646464646465
4344444444445750525644444444444543444444444457505256444444444445434444444444575052564444444444454344444444444444444444444444444543444444444457505256444444444445434444444444575052564444444444454344444444445750525644444444444543444444444457545456444444444445
5340414141414177764141414141425553404141414141777641414141414255534041414141417776414141414142555374747474747474747474747474745553404141414248505248404141414255534041414141417776414141414142555340414141414177764141414141425553404141425422545422544041414255
53505120515151515151515151205255535051515151515151515151515152555350727272727272727272727272525553747474747474747474747474747455535051515152485052485051515152555350666161616161616161616167525553507c207c7c7c7c7c7c7c7c7c20525553505151525438545438545051515255
53505166616161616161616161616255535051205151666161675151285152555350727272727272727272727272525553747474747474747474747474747455535051225152485052485051225152555350525c5c5c5c5c5c5c5c5c5c50525553507c206661677c7c6661677c20525553505151764254545454407751515255
535051524a4a4a4a4a4a4a4a4a4a4a55535051515151524848505151515152555350727266616161616161616161625553747474747474747474747474747455535051515176417776417751515152555350525c285c5c5c5c5c5c285c50525553507c666248606766624860677c525553505151515254545454505151515255
535051524a40414141414141414142555350515151517641417751515151525553507272524a4a4a4a4a4a4a4a4a4a5553747474747474747474747474747455535051515166616161616751515152555350525c5c5c5c5c5c5c5c5c5c50525553507c524848485052484848507c525553505138517642545440775138515255
535051524a50515151515859595a52565750516661675859595a6661675152555350727276414141414141414141425553747474747474747474747474747456576061616162747474745051515152565750525c5c5c5c5c5c5c5c245c50525553507c764248407776424840777c525553505151515176414177515151515255
535051524a50515151516869696a76414177515248506869696a5248505152555350722a723c723c723c723c722a525553747474747474742f74747474747474747474747474747474745051515176414177525c5c5c5c225c5c5c5c5c50525553507c287641777c7c7641777c28525553505151515151515151515151515255
535051524a50515120516869696a66616167515248506869116a52485051525553507272723c723c723c723c7272525553747474747474747474747474747474747474747474747474745051515166616167525c5c5c5c5c225c5c5c5c50525553507c286661677c7c6661677c28525553505151512251515151225151515255
535051524a50515151517879797a52464750517641777879797a7641775152555360616161616161616161677272525553747474747474747474747474747446474041414142747474745051515152464750525c5c5c5c5c5c5c5c5c5c50525553507c666248606766624860677c525553505151515151515151515151515255
535051524a505151666161616161625553505151515166616167515151515255534a4a4a4a4a4a4a4a4a4a507272525553747474747474747474747474747455535051515176414141417751515152555350525c5c5c5c5c5c5c5c245c50525553507c524848485052484848507c525553505151515151515151515151515255
535051524a505151524a4a4a4a4a4a55535051515151524848505151515152555340414141414141414141777272525553747474747474747474747474747455535051515166616766616751515152555350525c5c5c5c5c5c5c5c5c5c50525553507c764248407776424840777c525553505151515151515151515151515255
53505176417751517641414141414255535051205151764141775151285152555350722a7272727272727272722a525553747474747474747474747474747455535051225152485052485051225152555350525c285c5c5c5c5c5c285c50525553507c7c7641777c7c7641777c7c525553505151515151515151515151515255
53505120515151515151515151205255535051515151515151515151515152555350721172727272727272727272525553747474747474747474747474747455535051515152485052485051515152555350764141414141414141414177525553507c2a7c0a7c7c7c7c0a7c2a7c525553505151515151515151515151515255
5360616161616161616161616161625553606161616161676661616161616255536061616161616766616161616162555374747474747474747474747474745553606161616248505248606161616255536061616161616766616161616162555360616161616167666161616161625553606161616161676661616161616255
6364646464646464646464646464646563646464646447505246646464646465636464646464475052466464646464656364646464646464646464646464646563646464646447505246646464646465636464646464475052466464646464656364646464644750524664646464646563646464646447505246646464646465
__sfx__
000100001a332243322d332323322e3322b3322a33227332243321e33217332123320c33208322073220331200302003020030200302003020030200302003020030200302003020030200302003020030200302
0001000013332203322a3322f3322c33227332253321e3321c3321a33217332123320c33208322073220331200702007020070200702007020070200702007020070200702007020070200702007020070200702
000300000452105521085210b5211252119521275211d521165111251108511055001a5000f500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00020000195431954319543185431754314543115430d543095430654302543015430154314503135031350313503115030f5030c5030a5030950309503095030750305503055030050300503005030050301503
01080000240752607528075240752607528075290752607528075290752b07528075290752b0752d0752f07530072300723007230062300623005230052300423004230032300223001200005000050000501005
000400001815012350186500d35012650083500a630043300662001120011100310001100101000c1000a10005100031000110001100001000010000100001000010000100001000010000100001000010000100
000300002e6202f620306102f6102f6102d6102a61026610226101c6101b610166101561014610136101361013610116100f6100c6100a6100961009610096100761005610056100060000600006000060000600
000800001f65020650206502065020650206501f6501e6501d6501c6501a650196501565012640106400d6400d6300b6300963007620056100361001610016100161001610016100161000100001000010000100
000800002c6432b6430b64324643236430a6431b64319643096431564314633046330f6330d623066230a62308613036130260307603056030360301603016030160301603016030160300103001030010300103
000800003b6533b6531165335653356530f6532b6532b6530e65323653236530a6531c6531b653066531465315643076431364313633056330c6330d633016230661304623016030160300103001030010300103
011300001f7341f7321f7321f7321f7321f7321f7321f7322973129732297322973223731237322373223732247312473224732247321d7311d7321d7321d7322973129732297322973228735287352973529735
011300001a7341a7321a7321a7321a7321a7321a7321a7321f7311f7321f7321f73223731237322373223732217312173221732217321873118732187321873218732187321873218732237351f7351c73518735
011300002d7342d7322d7322d7322d7322d7322d7322d732307313073230732307322f7312f7322f7322f732307313073230732307322b7312b7322b7322b7322b7322b7322b7322b7322f7352d7352b73529735
0113000028734287322873228732287322873228732287322d7312d7322d7322d7322b7312b7322b7322b7322d7312d7322d7322d732267312673226732267322673226732267322673228735297352b7352f735
011300002133321303153031530315303153032133321303216331530315303153032130315303213331530321333153031530315303153031530321333213032163321303213332130321633003032163321633
011300002133321303153031530321633213032133321333216331530315303153032163315303213332163321333153031530315303216331530321333213332163321303213332130321633213332163321633
011300001355218552135521c5521355218552135521c55211552155521155218552175521a552175521d552185521c552185521f552115521555211552185521d552215521d5522455223552235522455224552
011300001a5521d5521a552215521a5521d5521a552215521f552235521f552265522355226552235521d552215522455221552285521d552215521d55224552295522d5522955230552265522f5522b55228552
011300002155224552215522855221552245522155228552185521c552185521f552235522655223552295522455228552245522b5521f552235521f552265522b5522f5522b552325521a552185522355221552
011300001c5521f5521c552235521c5521f5521c55223552215522455221552285521f552235521f55226552215522455221552285521a5521d5521a552215522655229552265522d5521f552215522355226552
011300001f7551f755237551f7551f755237551f7551f7551d7551d755217551d75523755247552375526755247552675524755287551d7551f7551d755217551d755237551d7552475528755287552975529755
011300001a7551a7551d7551a7551a7551d7551a7551a7551f7551f755217551f7552375523755267552375521755237552175524755247552675524755287552475529755247552b7552f7552b7552875524755
011300002d7552d755307552d7552d755307552d7552d755307553075534755307552f7552f755327552f755307553275530755347552b7552d7552b7552f7552b755307552b755327552f7552d7552b75529755
0113000028755287552b75528755287552b75528755287552d7552d755307552d7552b7552b7552f7552b7552d7552f7552d7553075526755287552675529755267552b755267552d7553475535755377553b755
011300002133321303216332133321633213032133321333216331530321333213332163315303213332163321333153032163321333216331530321333213332163321303213332133321633213332163321633
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 0a 42 43 44
00 0b 42 0e 44
00 0c 42 0e 44
00 0d 42 0e 44
00 0a 14 0f 44
01 0b 15 0f 44
00 0c 16 0f 44
00 0d 17 0f 44
00 0a 10 18 44
00 0b 11 18 44
00 0c 12 18 44
00 0d 13 18 44
00 41 14 43 44
00 0b 15 0f 44
00 0c 16 0f 44
00 0d 17 0f 44
00 41 10 43 44
00 0b 11 18 44
00 0c 12 18 44
00 0d 13 18 44
02 0a 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
