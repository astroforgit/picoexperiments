pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- lil' satan's cake quest
--by guerragames
one_frame=1/60
epsilon=.001
max_air_time=6000

--
cartdata("lilsatancakequest")

--
function load_game()
 player_level,player_max_health,player_score,game_time,player_deaths=dget(0),dget(1),dget(2),dget(3),dget(4)
 if (player_max_health==0)player_max_health=6
end

--
function save_game()
 dset(0,player_level)
 dset(1,player_max_health)
 dset(2,player_score)
 dset(3,game_time)
 dset(4,player_deaths)
end

--
function reset_game()
 reset_score()
end

--
function reset_score()
 player_level,player_max_health,player_score,game_time,player_deaths=0,6,0,0,0
 save_game()
 run()
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
cam_shake_x,cam_shake_y=0,0
cam_shake_damp=0
screen_flash_timer=0
screen_flash_color=7

--
function screenflash(duration,color)
 screen_flash_timer=duration
 screen_flash_color=color
end

--
function screenshake(max_radius,damp)
 local a=rnd()
 cam_shake_x,cam_shake_y=max_radius*cos(a),max_radius*sin(a)
 cam_shake_damp=damp
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
   b.time_since_press=100
   b.time_held=0
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

jump_button=create_button(5)
shoot_button=create_button(4)

--
function round(x) return flr(x+.5) end
 
function map_coords(x,y)
 local ly=mid(cam_y,y,cam_y+128)
 return flr(round(x)/8),flr(round(ly)/8)
end

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

--
bg_lines={}

for i=0,60 do
 add(bg_lines,{})
end

--
function bg_rnd_line(l)
 l.y,l.s,l.vx=rnd(64),5+rnd(10),.01+rnd(.2)
end

--
function bg_init()
 for k,l in pairs(bg_lines) do
  l.x=rnd(128)
  bg_rnd_line(l)
 end
end

--
function bg_update()
 for k,l in pairs(bg_lines) do
  l.x-=l.vx
  
  if l.x+l.s<0 then
   l.x=128
   bg_rnd_line(l)
  end
 end
end

--
function bg_draw()
 camera(0,0)
 circfill(32,32,10,7)
 circfill(32-4,32-2,9,0)
 
 for k,l in pairs(bg_lines) do
  line(l.x,l.y,l.x+l.s,l.y,1)
 end
end


-- camera

function cam_update()
 local scroll_window=48
 if player_x+16+scroll_window>cam_x+128 then
  cam_x=min(7*128,player_x+16+scroll_window-128)
 end
 if player_x-scroll_window<cam_x then
  cam_x=max(0,player_x-scroll_window)
 end
end

-- part
parts={}
parts_next=1
parts_blink=0

for i=0,400 do
 add(parts,{t=0})
end

parts_flags_none=0x0
parts_flags_floor_bounce=0x01
parts_flags_blink=0x02
parts_flags_no_outline=0x04

--
function parts_spawn(t,x,y,vx,vy,g,d,sx,sy,dsx,dsy,c,bc,f)
 parts_next=next_i(parts,parts_next)
 
 local p=parts[parts_next]
 
 p.t,p.x,p.y,p.vx,p.vy,p.g,p.d,p.sx,p.sy,p.dsx,p.dsy,p.c,p.bc,p.f=t,x,y,vx,vy,g,d,sx,sy,dsx,dsy,c,bc,f
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
   
   p.sx=max(0,p.sx+p.dsx)
   p.sy=max(0,p.sy+p.dsy)
   
   if p.sx<=0 and p.sy<=0 then
    p.t=0
   end
   
   if band(p.f,parts_flags_blink)==parts_flags_blink then
    if parts_blink%.2>.1 then 
     p.c,p.bc=p.bc,p.c
    end
   end
   
   if band(p.f,parts_flags_floor_bounce)==parts_flags_floor_bounce and s_floor(p.x,p.y+p.sy) then
    if abs(p.vy)>.2 then
     p.vy=-.8*p.vy
    end
   else
    p.vy+=p.g
   end
  end
 end
end

--
function part_draw(p,o,c)
 rectfill(flr(p.x-p.sx/2)-o,flr(p.y-p.sy/2)-o,flr(p.x+p.sx/2)+o,flr(p.y+p.sy/2)+o,c)
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

-- pbullets
pbullets={}
pbullets_next=1
pbullets_active_count=0

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
  
  pb.t,pb.x,pb.y,pb.vx,pb.vy,pb.s=t,x,y,vx,vy,s
  
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
   
   parts_spawn(.1,pb.x,pb.y+1-rnd(2),0,0,0,0,1+rnd(pb.s),rnd(pb.s),-.2,-.2,7,12,parts_flags_none)
   
   for k,e in pairs(enemies) do
    if e.active then
     
     local scale=(e.type.scale or 1)
     
     if pb.x+1<e.x or
        pb.x-1>e.x+8*scale or
        pb.y+1<e.y or
        pb.y-1>e.y+16*scale then
     else
      pb.active=false
      pbullets_active_count-=1
      
      enemy_damage(e,pb,player_shooting_size)
      
      for i=1,20 do
       local a,r=rnd(),.5+rnd(2)
       local vx,vy=r*cos(a),r*sin(a)
       parts_spawn(.2,pb.x+1-rnd(2),pb.y+1-rnd(2),vx,vy,0,.9,rnd(pb.s),rnd(pb.s),-.2,-.2,7,12,parts_flags_none)
      end
     end
    end
   end
  end
 end
end

-- player
player_anim_idle=nl("2,2,2,2,2,2,2,2,32,32,32,32,32,32,32,32")
player_anim_run=nl("0,0,0,0,0,0,2,2,2,2,2,2")
player_anim_shoot=nl("36,36,36,36,36,36,4,4,4,4,4,4")
player_anim_chew=nl("6,6,6,6,6,6,4,4,4,4,4,4")
player_anim_launch={34}
player_anim_jump={0}
player_anim_fall={38}
player_anim_land={34}

player_jump_state_none,player_jump_state_launch,player_jump_state_arc,player_jump_state_fall,player_jump_state_land=0,1,2,3,4

--
function player_set_anim(anim)
 player_pre_anim=anim
end

--
function player_commit_anim()
 if player_anim!=player_pre_anim then
  player_anim=player_pre_anim
  player_anim_time=0
  player_anim_next=1
 end
end

--
function player_init()
 player_reset()
end

--
function player_reset()
 player_health=player_max_health
 player_adjust_health(0)
 
 cam_x,cam_y=0,player_level*128
 player_x,player_y=16,cam_y
 player_cx=0
 player_vx,player_vy=0,0
 player_gravity=.4
 
 player_cr=nil
 
 player_shooting_cooldown=0
 played_damaged=0
 
 player_air_time=max_air_time
 player_anim_flip=false
 player_set_anim(player_anim_idle)
 player_commit_anim()
 player_gameover=false
 player_gameover_timer=0
 
 player_jump_state=player_jump_state_none
 player_jump_state_timer=10
 
 player_eating_timer=10
 player_crumb=0
end

--
function player_damage()
 if played_damaged<=0 then
  sfx(7)
  
  played_damaged=2

  player_adjust_health(-2)
  
  local died=(player_health<=0)

  for i=1,died and 100 or 40 do
   local a,r=rnd(),.5+rnd(3)
   local vx,vy=r*cos(a),r*sin(a)
   
   if died then
    local size=1+rnd(6)
    parts_spawn(2,player_x+1+rnd(14),player_y+1+rnd(14),vx,vy,0,.96,size,size,-.1,-.1,8,2,parts_flags_none)
   else
    local size=1+rnd(3)
    parts_spawn(.4,player_x+1+rnd(14),player_y+1+rnd(14),vx,vy,0,.95,size,size,-.2,-.2,8,2,parts_flags_none)
   end
  end
 
  if died then
   player_deaths+=1
   dset(3,game_time)
   dset(4,player_deaths)
   player_gameover=true
   player_death_sentence=1+flr(rnd(#player_death_sentences))
  end
  
  screenshake(6,.7)
  screenflash(.05,8)
  
  player_vx=player_anim_flip and 3 or -3
 end
end

--
function player_adjust_health(val)
 player_health+=val
 player_health=mid(0,player_health,player_max_health)
 player_shooting_rate=mid(.05,.2-.15*(player_health-6)/14,.2)
 player_shooting_size=mid(1,1+4*(player_health-6)/14,5)
end

--
function player_pickup_update()
 player_eating_timer+=one_frame
 
 for k,pu in pairs(pickups) do
  if pu.active then
   if pu.x+8<player_x or
      pu.x  >player_x+16 or
      pu.y+8<player_y or
      pu.y  >player_y+16 then
   else
    sfx(rnd()>.5 and 4 or 5)
    pickups_active_count-=1
    pu.active=false
    
    player_eating_timer=0
    
    if pu.golden then
     player_max_health=min(24,player_max_health+2)
     player_adjust_health(player_max_health)
    else
     player_adjust_health(1)
    end
    
    player_score+=1

    for i=1,10 do
     player_cake_crumb()
    end
   end
  end
 end

 if player_eating_timer<1 then
  player_crumb-=one_frame
  if player_crumb<=0 then
    player_crumb=.1
    player_cake_crumb()
    sfx(rnd()>.5 and 4 or 5)
  end
 end
end

--
function player_cake_crumb()
 local size=.5
 local x=(player_anim_flip) and player_x+6 or player_x+10
 parts_spawn(1,x,player_y+12,rnd(4)-2,-1-rnd(3),.2,.9,size,size,0,0,10,9,parts_flags_floor_bounce)
end

-- 
function player_landp(c1,c2,ox,a)
 local c=(rnd()>.5) and c1 or c2 
 local vx,vy=2*cos(a),2*sin(a)
 parts_spawn(.2,player_x+ox,player_y+14,vx,vy,.1,.9,1,1,0,0,c,c,parts_flags_no_outline)
end

--
function player_land_particles()
 local c1=(cam_y<128) and 11 or (cam_y<256) and 9 or 7
 local c2=(cam_y<128) and  3 or (cam_y<256) and 4 or 6
 
 player_landp(c1,c2,2,5/12)
 player_landp(c1,c2,4,4/12)
 player_landp(c1,c2,12,2/12)
 player_landp(c1,c2,14,1/12) 
end

--
function player_update()
 if player_gameover then
   player_gameover_timer+=one_frame
   
   if player_gameover_timer>=1 then
    if btnp(4) then
     player_gameover=false
     load_game()
     level_restart()
    end
   end
   return
 end
 
 if(player_shooting_cooldown>0)player_shooting_cooldown-=one_frame
 if(played_damaged>0)played_damaged-=one_frame

 player_cr=collision_checks(player_x,player_y,player_vx,player_vy,1,14,1,14)
 player_x=player_cr.x
 player_y=player_cr.y
 
 player_x=mid(0,player_x,8*128-16)
 player_y=min(player_y,4*128-16)
 
 player_anim_next=next_i(player_anim,player_anim_next)
 player_anim_time+=one_frame
 
 if btn(0) then
  player_cx=-1
  player_vx=max(-1,player_vx-.2)
 elseif btn(1) then
  player_cx=1
  player_vx=min(1,player_vx+.2)
 else
  player_cx=0
  player_vx*=.8
 end

 if not player_cr.floor or player_gravity<=0 then
  player_vy+=player_gravity

  player_air_time+=one_frame
  if player_air_time>max_air_time then
   player_air_time=max_air_time
  end
 else
  if player_air_time>.1 then
   player_land_particles()
  end
  
  player_vy=0
  player_air_time=0
 end


 player_pickup_update()
 
 -- shooting
 if shoot_button.time_held>0 then
  player_vx,player_vy=0,0
  
  if player_shooting_cooldown<=0 then
   player_shooting_cooldown=player_shooting_rate
   pbullets_spawn(1,player_x+(player_anim_flip and 1 or 13),player_y+8,player_anim_flip and -3 or 3,0,player_shooting_size+1)
  end 
 end 
 
 player_jump_state_timer+=one_frame
 if player_jump_state==player_jump_state_none then
  if player_air_time>.1 then
   player_jump_state=player_jump_state_fall
   player_jump_state_timer=0
  end
  
  if player_air_time<.1 and jump_button.time_since_press<.2 then
   sfx(2)
   jump_button:button_consume()
   player_air_time=max_air_time
   player_vx,player_vy=0,0
   player_jump_state=player_jump_state_launch
   player_jump_state_timer=0
  end
 elseif player_jump_state==player_jump_state_launch then
  player_vx,player_vy=0,0
  if player_jump_state_timer>.05 then
   -- finished launching
   player_vy=-4
   player_gravity=0   
   player_jump_state=player_jump_state_arc
   player_jump_state_timer=0
  end
 elseif player_jump_state==player_jump_state_arc then
  if player_jump_state_timer<.05 then
   player_vy=-4
   player_gravity=0
  else
   player_gravity=.4
   
   if player_vy>=0 then
    player_jump_state=player_jump_state_fall
    player_jump_state_timer=0
   end
  end
 elseif player_jump_state==player_jump_state_fall then
   if player_cr.floor then
    sfx(8)
    player_jump_state=player_jump_state_land
    player_jump_state_timer=0
   end
 elseif player_jump_state==player_jump_state_land then
  if player_jump_state_timer<.05 then
   player_vx,player_vy=0,0
  else
   player_jump_state=player_jump_state_none
   player_jump_state_timer=0
  end
 end
 
 if player_cx<0 then
  player_anim_flip=true
  player_set_anim(player_anim_run)
 elseif player_cx>0 then
  player_anim_flip=false
  player_set_anim(player_anim_run)
 else
  player_set_anim(player_anim_idle)
 end

 -- anim state handling
 if shoot_button.time_held>0 then
  player_set_anim(player_anim_shoot)
 elseif player_jump_pressed then
   player_set_anim(player_anim_launch)
 elseif player_eating_timer<1 then
  player_set_anim(player_anim_chew)
 elseif player_jump_state==player_jump_state_launch then
  player_set_anim(player_anim_launch)
 elseif player_jump_state==player_jump_state_arc then
  player_set_anim(player_anim_jump)
 elseif player_jump_state==player_jump_state_fall then
  player_set_anim(player_anim_fall) 
 elseif player_jump_state==player_jump_state_land then
  player_set_anim(player_anim_land)
 end

 player_commit_anim()
end

--
function pdraw(ox,oy)
 spr(player_anim[player_anim_next],player_x+ox,player_y+oy,2,2,player_anim_flip)
end

player_death_sentences=
{
 "no more cake for satan!",
 "this is no piece of cake!",
 "this is no cakewalk!",
 "cake makes you fat!",
 "you had some cake!",
 "you take the cake!",
}

--
function draw_hud()
 local h=0
 local x=2
 while h<player_max_health do
  if player_health-h==1 then
   pal(14,0)
  elseif player_health-h>1 then
   pal(14,8)
  else
   pal(14,0)
   pal(8,0)
  end
  
  spr(67,cam_x+x%36,cam_y+1+flr(x/6))
  x+=6
  h+=2
 end 
 
 pal()

 print_outline("-"..time_to_text(game_time).."-",cam_x+64,cam_y+3,0,7)
 print_outline(""..player_score,cam_x+118,cam_y+3,0,7,align_r)
 spr(112,cam_x+119,cam_y+1)
end

--
function player_draw()
 if player_gameover then
  local blink=(player_gameover_timer%.2>.1)
  local c=blink and 0 or 10
  local bc=blink and 7 or 8
  
  local a=min(.25,player_gameover_timer/2)
  local y=cam_y-6-32*sin(a)
  
  print_outline("you died!",cam_x+64,y,c,bc)
  
  local y2=cam_y+128+90*sin(a)
  print_outline(player_death_sentences[player_death_sentence],cam_x+64,y2,c,bc)
  
  print_outline("deaths:"..player_deaths,cam_x+64,y2+8,c,bc)
  
  local a=min(.25,max(0,player_gameover_timer-1)/2)
  local y2=cam_y+130+64*sin(a)
  print_outline("press \142 to continue!",cam_x+62,y2,c,bc)
  
  return
 end
  
 if played_damaged>0 and played_damaged%.2>.1 then
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
 
 if player_eating_timer<1 then
  if player_eating_timer%.2>=.1 then  
   print_outline("nom!",player_x+8,player_y-6,0,7)
  end
 end
end

-- enemy bullets
ebs={}
ebs_next,ebs_blink,ebs_blink_on=1,0,true

for i=1,100 do
 add(ebs,{})
end

function ebs_reset()
 for k,eb in pairs(ebs)do
  eb.active=false
 end
end

function ebs_make_bullets(x,y,s,speed,count,inc_a,start_a)
 
 if x-cam_x>=-32 and x-cam_x<=128+32 then
  sfx(3)
 end
 
 local ia=start_a
 for i=1,count do
  local eb=ebs[ebs_next]
  eb.x,eb.y,eb.s=x,y,s
  eb.velx,eb.vely=speed*cos(ia),speed*sin(ia)
  eb.active,eb.t=true,4
  ebs_next=next_i(ebs,ebs_next)
  
  ia-=inc_a
 end 
end

--
function ebs_shoot_aimed(x,y,s,speed,count,angle)
 local nx,ny,mag=normalize(player_x+8-x,player_y+8-y)
 ebs_make_bullets(x,y,s,speed,count,angle/count,atan2(nx,ny))
end

--
function ebs_shoot_spread(x,y,s,speed,count,angle)
 ebs_make_bullets(x,y,s,speed,count,1/count,angle)
end

--
function ebs_check_player(eb)
 local s=eb.s/2
 if player_x+14<eb.x-s or
    player_x+2>eb.x+s or
    player_y+14<eb.y-s or
    player_y+2>eb.y+s then
 else
  eb.active=false
  player_damage()
 end
end

--
function ebs_update()
 if ebs_blink<=0 then
  ebs_blink=.05
  ebs_blink_on=not ebs_blink_on
 else
  ebs_blink-=one_frame
 end

 for k,eb in pairs(ebs)do
  if eb.active then
   if eb.t<=0 then
    eb.active=false
   elseif eb.y<-8 or eb.x<-8 or eb.y>(128*4+14) or eb.x>(128*8+14) then
    eb.active=false
   else
    eb.t-=one_frame
    eb.y+=eb.vely
    eb.x+=eb.velx
    
    if ebs_blink%.05>.03 then
     local ds=-.2*eb.s/4
     parts_spawn(.5,eb.x+eb.s/2-rnd(eb.s),eb.y+eb.s/2-rnd(eb.s),0,0,0,0,eb.s,eb.s,ds,ds,8,10,parts_flags_blink)
    end
    
    ebs_check_player(eb)
   end
  end
 end
end

-- enemies
enemy_types={}

--
function ef_flip_dir_init(e,max_time,separation)
 e.max_check_dir_time,e.check_dir_time,e.check_dir_separation=max_time,max_time,separation
end

--
function ef_flip_dir_update_timer(e)
 e.check_dir_time-=one_frame
end

--
function ef_flip_dir_update_checks(e)
 if e.check_dir_time<=0 then
  if abs(player_x+8-e.x-4)>e.check_dir_separation then
   e.check_dir_time=e.max_check_dir_time
  
   e.anim_flip=(player_x+8>e.x+4)
   e.vx=e.anim_flip and -e.type.vel_x or e.type.vel_x
  end
 end
end

--
function enemy_shooter_init(e,size,wait,rndwait)
 e.shoot_bullet_time=wait+rnd(rndwait)
 e.bullet_timer=e.shoot_bullet_time-one_frame
 e.bullet_size=size
end

--
function enemy_shooter_spread(e,speed,count,angle,check_flip)
 if e.bullet_timer<e.shoot_bullet_time then
  e.bullet_timer+=one_frame
   
  if e.bullet_timer>=e.shoot_bullet_time then
   e.bullet_timer=0
   
   local scale=(e.type.scale or 1)
   
   if check_flip and (e.x+4*scale>player_x+8) then
    angle+=.5
   end
   
   ebs_shoot_spread(e.x+4*scale,e.y+4*scale,e.bullet_size,speed,count,angle)
  end
 end
end

--
function enemy_shooter_aimed(e,speed)
 if e.bullet_timer<e.shoot_bullet_time then
  e.bullet_timer+=one_frame
   
  if e.bullet_timer>=e.shoot_bullet_time then
   e.bullet_timer=0
   local scale=(e.type.scale or 1)
   ebs_shoot_aimed(e.x+4*scale,e.y+4*scale,e.bullet_size,speed,1,0)
  end
 end
end

--
function enemy_spawner_init(e,time,spawn_type,max_minions)
 e.spawn_enemy_time,e.spawn_timer,e.spawn_type,e.max_minions=time,0,spawn_type,max_minions
end 

--
function enemy_spawner_update(e)
 if e.spawn_timer<e.spawn_enemy_time then
  e.spawn_timer+=one_frame
   
  if e.spawn_timer>=e.spawn_enemy_time then
   e.spawn_timer=0
   
   if enemies_active_count-1<e.max_minions then
    enemy_spawn(e.spawn_type,e.x,e.y)
   end
  end
 end
end 

--
et_skeleton_head_idle=nl("10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,")
default_anim_offset=nl("2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,")

-- skeleton
enemy_types[10]=
{
 idle_anim=et_skeleton_head_idle,
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,"),
 vel_x=-.1,
 health=5,
 
 init=function(e)
  ef_flip_dir_init(e,5,32)
 end,

 update=function(e)
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
 end,
}

-- skeleton boss
enemy_types[11]=
{
 idle_anim=et_skeleton_head_idle,
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("42,42,42,42,42,42,42,42,42,42,43,43,43,43,43,43,43,43,43,43,"),
 vel_x=0,
 health=200,
 scale=3,
 isboss=true,
 
 init=function(e)
  enemy_spawner_init(e,5,10,10)
  enemy_shooter_init(e,8,2,1)
  
  e.base_x=e.x
 end,

 update=function(e)
  enemy_spawner_update(e)
  enemy_shooter_aimed(e,1)
  
  e.x=e.base_x+32*sin(e.t/20)
 end, 
 
 allow_damage=function(e,pb)
  if pb.y<e.y+16*e.type.scale/2 then
   return true
  elseif e.anim_flip then
   return (pb.x<e.x+4*e.type.scale)
  else
   return (pb.x>e.x+4*e.type.scale)
  end
 end,
}

-- plant fwd
enemy_types[12]=
{
 idle_anim=nl("12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,"),
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,"),
 vel_x=0,
 health=20,

 init=function(e)
  enemy_shooter_init(e,4,2,1)
  ef_flip_dir_init(e,.1,0)
 end,

 update=function(e)
  enemy_shooter_spread(e,1,1,0,true)
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
 end,
}

-- flying plant boss
enemy_types[13]=
{
 idle_anim=nl("13,13,13,13,13,13,13,13,13,13,12,12,12,12,12,12,12,12,12,12,"),
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("61,61,61,61,61,61,61,61,61,61,60,60,60,60,60,60,60,60,60,60,"),
 vel_x=0,
 health=400,
 scale=3,
 g=0,
 ignorewalls=true,
 isboss=true,
 
 init=function(e)
  enemy_spawner_init(e,5,58,10)
  enemy_shooter_init(e,5,1,.5)
  ef_flip_dir_init(e,.1,0)
  
  e.base_x,e.base_y=e.x,e.y
  
 end,

 update=function(e)
  enemy_spawner_update(e)
  enemy_shooter_spread(e,1,5,-e.t*2,false)
  
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
  
  e.x,e.y=e.base_x+32*sin(e.t/16),e.base_y+16*sin(e.t/2)
 end,
}

-- demon
enemy_types[14]=
{
 idle_anim=nl("14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,"),
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,"),
 vel_x=-.8,
 health=15,
 
 init=function(e)
  ef_flip_dir_init(e,1,48)
 end,

 update=function(e)
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
 end,
}

-- demon boss, final boss
enemy_types[15]=
{
 idle_anim=nl("14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,"),
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,"),
 vel_x=-.5,
 health=1000,
 scale=5,
 isboss=true,
 
 init=function(e)
  ef_flip_dir_init(e,1,96)
  enemy_spawner_init(e,5,60,10)
  enemy_shooter_init(e,12,5,0)  
 end,

 update=function(e)
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
  
  enemy_spawner_update(e)
  enemy_shooter_aimed(e,1)
 end,
}

-- skeleton shield
enemy_types[42]=
{
 idle_anim=et_skeleton_head_idle,
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("42,42,42,42,42,42,42,42,42,42,43,43,43,43,43,43,43,43,43,43,"),
 vel_x=-.1,
 health=10,

 init=function(e)
  ef_flip_dir_init(e,5,32)
 end,

 update=function(e)
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
 end,
 
 allow_damage=function(e,pb)
  if pb.y<e.y+8 then
   return true
  elseif e.anim_flip then
   return (pb.x<e.x+4)
  else
   return (pb.x>e.x+4)
  end
 end,
}

-- plant up
enemy_types[44]=
{
 idle_anim=nl("44,44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45,45,45,"),
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,"),
 vel_x=0,
 health=20,

 init=function(e)
  enemy_shooter_init(e,4,2,1)
  ef_flip_dir_init(e,.1,0)
 end,

 update=function(e)
  enemy_shooter_spread(e,1,1,.25,false)
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
 end,
}


-- flying ghost
enemy_types[46]=
{
 idle_anim=nl("47,47,47,47,47,47,47,47,47,47,46,46,46,46,46,46,46,46,46,46,"),
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("63,63,63,63,63,63,63,63,63,63,62,62,62,62,62,62,62,62,62,62,"),
 vel_x=-.3,
 health=20,
 g=0,
 ignorewalls=true,

 init=function(e)
  ef_flip_dir_init(e,1.5,32)
  
  e.base_y=e.y
 end,

 update=function(e)
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
 
  e.y=e.base_y+16*sin(e.t)
 end,
}

-- skeleton bouncer
enemy_types[58]=
{
 idle_anim=et_skeleton_head_idle,
 anim_offset_y=nl("4,4,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,"),
 sub_idle_anim=nl("58,58,58,58,58,58,58,58,58,58,59,59,59,59,59,59,59,59,59,59,"),
 vel_x=-.3,
 health=10,
 
 init=function(e)
  ef_flip_dir_init(e,2,32)
 end,

 update=function(e)
  ef_flip_dir_update_timer(e)

  local scale=(e.type.scale or 1)
   
  if s_floor(e.x+4*scale,e.y+16*scale) then
   e.vy=-1.4
   e.y+=e.vy
   ef_flip_dir_update_checks(e)
  end
 end,
}

-- skeleton bouncer boss
enemy_types[59]=
{
 idle_anim=et_skeleton_head_idle,
 anim_offset_y=nl("4,4,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,"),
 sub_idle_anim=nl("58,58,58,58,58,58,58,58,58,58,59,59,59,59,59,59,59,59,59,59,"),
 vel_x=-.3,
 health=300,
 scale=4,
 isboss=true,
 
 init=function(e)
  ef_flip_dir_init(e,2,32)
  enemy_spawner_init(e,5,10,10)
  enemy_shooter_init(e,8,2,1)  
 end,

 update=function(e)
  ef_flip_dir_update_timer(e)
  enemy_spawner_update(e)
  enemy_shooter_aimed(e,1)

  local scale=(e.type.scale or 1)
   
  if s_floor(e.x+4*scale,e.y+16*scale) then
   e.vy=-2
   e.y+=e.vy
   ef_flip_dir_update_checks(e)
  end
 end,
}

-- flying plant
enemy_types[60]=
{
 idle_anim=nl("13,13,13,13,13,13,13,13,13,13,12,12,12,12,12,12,12,12,12,12,"),
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("61,61,61,61,61,61,61,61,61,61,60,60,60,60,60,60,60,60,60,60,"),
 vel_x=-.5,
 health=20,
 g=0,
 ignorewalls=true,

 init=function(e)
  ef_flip_dir_init(e,1.5,32)
  enemy_shooter_init(e,4,2,1)
  e.base_y=e.y
 end,

 update=function(e)
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
  enemy_shooter_aimed(e,1)
 
  e.y=e.base_y+16*sin(e.t/2)
 end,
}


-- flying demon
enemy_types[62]=
{
 idle_anim=nl("14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,"),
 anim_offset_y=default_anim_offset,
 sub_idle_anim=nl("63,63,63,63,63,63,63,63,63,63,62,62,62,62,62,62,62,62,62,62,"),
 vel_x=-.8,
 health=15,
 g=0,
 ignorewalls=true,

 init=function(e)
  ef_flip_dir_init(e,1,48)
  e.base_y=e.y
 end,

 update=function(e)
  ef_flip_dir_update_timer(e)
  ef_flip_dir_update_checks(e)
 
  e.y=e.base_y+48*sin(e.t/2)
 end,
}

-- block
enemy_types[109]=
{
 idle_anim={109},
 anim_offset_y={0},
 sub_idle_anim={109},
 vel_x=0,
 health=20,
}

enemies={}

for i=1,20 do
 add(enemies,{active=false})
end

--
function enemy_spawn(spr,x,y)
 
 local e,i=find_next_i(enemies,enemies_next,enemies_active_count)
 
 if e then
  enemies_next=i
  
  enemies_active_count+=1
  e.active=true
 
  e.type_i,e.type=spr,enemy_types[spr]
  e.anim,e.sub_anim=e.type.idle_anim,e.type.sub_idle_anim
  e.health=e.type.health
  e.x,e.y=x,y
  e.vy,e.vx=0,e.type.vel_x
  e.anim_flip=false
  e.anim_index=1
  e.t=0
  
  e.damaged_timer=0
 
  if(e.type.init)e.type.init(e)
  if(e.type.isboss)music(10,500)
 end
end

--
function enemy_kill(e,effect)
 e.active=false
 enemies_active_count-=1
 
 if e.type.isboss then
  music(20,500)
  
  if effect then
   sfx(6)
   screenshake(6,.7)
   screenflash(.1,7)
  end
  
  for k,ae in pairs(enemies) do
   if(ae.active)enemy_kill(ae,effect)
  end
  
  level_finished,level_finished_timer=true,0
 else
  if effect then
   sfx(6)
   screenshake(6,.7)
   screenflash(.025,7)
  end
 end
end

--
function enemy_damage(e,pb,d)
 
 local can_damage=(not e.type.allow_damage) or e.type.allow_damage(e,pb)
 
 if (not can_damage)return
 
 e.health-=d
 e.damaged_timer=.1
 if e.health<=0 then
  local golden=(e.type_i==14 or e.type_i==62) -- demons gives you health upgrade
  pickups_spawn(e.x,e.y,-3,golden)
  
  if e.type.isboss then
   for i=1,80 do
    local a,r=rnd(),.5+rnd(5)
    local vx,vy=r*cos(a),r*sin(a)
    local size=1+rnd(8)
    parts_spawn(2,e.x+1+rnd(6*e.type.scale),e.y+1+rnd(6*e.type.scale),vx,vy,0,.98,size,size,-.1,-.1,8,10,parts_flags_none)
   end
  else
   for i=1,20 do
    local a,r=rnd(),.5+rnd(3)
    local vx,vy=r*cos(a),r*sin(a)
    local size=1+rnd(3)
    parts_spawn(.4,e.x+1+rnd(6),e.y+1+rnd(6),vx,vy,0,.95,size,size,-.2,-.2,8,10,parts_flags_none)
   end
  end
  
  enemy_kill(e,true)
 end
end

--
function enemy_draw(e,ox,oy)
 local s=e.type.scale
 if s then
  local spr1x,spr1y=spr_index_to_xy(e.anim[e.anim_index])
  sspr(spr1x,spr1y,8,8,e.x+ox,e.y+oy+s*e.type.anim_offset_y[e.anim_index],s*8,s*8,e.anim_flip)
  
  local spr2x,spr2y=spr_index_to_xy(e.sub_anim[e.anim_index])
  sspr(spr2x,spr2y,8,8,e.x+ox,e.y+oy+s*8,s*8,s*8,e.anim_flip)
 else
  spr(e.anim[e.anim_index],e.x+ox,e.y+oy+e.type.anim_offset_y[e.anim_index],1,1,e.anim_flip)
  spr(e.sub_anim[e.anim_index],e.x+ox,e.y+oy+8,1,1,e.anim_flip)
 end
end

--
function enemy_check_player(e)
 local s=e.type.scale or 1
 if player_x+14<e.x or
    player_x+2>e.x+s*8 or
    player_y+14<e.y or
    player_y+2>e.y+s*16 then
 else
  player_damage()
 end
end

--
function enemies_update_level_spawn()
 while enemies_spawn_x<cam_x+128 do
  for y=cam_y,cam_y+128,8 do
   local mx,my=map_coords(enemies_spawn_x,y)
   
   local tile_spr=mget(mx,my)
   if fget(tile_spr,7) then
    enemy_spawn(tile_spr,mx*8,my*8)
   end
  end
  
  enemies_spawn_x+=8  
 end
end

--
function enemies_reset()
 for k,e in pairs(enemies) do
  e.active=false
 end
 
 enemies_next,enemies_active_count,enemies_spawn_x=1,0,0
end

--
function enemies_update()
 enemies_update_level_spawn()

 for k,e in pairs(enemies) do
  if e.active then
   e.t+=one_frame
   
   local damaged=(e.damaged_timer>0)
   
   if damaged then
    e.damaged_timer-=one_frame
   end
   
   if not damaged or e.type.isboss then
    e.anim_index=next_i(e.anim,e.anim_index)
    e.x+=e.vx
    
    local scale=(e.type.scale or 1)

    if not s_floor(e.x+4*scale,e.y+16*scale) then
     e.vy+=(e.type.g or .05)
     e.y+=e.vy
    else
     e.y=flr((e.y+1)/8)*8
    end
    
    -- check walls
    if not e.type.ignorewalls then
     if e.vx<0 then
      if s_lwall(e.x-1,e.y+8) or e.x<=-1 then
       e.vx=-e.vx
       e.anim_flip=true
      end
     elseif e.vx>0 then
      if s_rwall(e.x+9,e.y+8) or (e.x+8*scale)>=8*128 then
       e.vx=-e.vx
       e.anim_flip=false
      end
     end
    end
    
    -- check out of bounds kills
    if not e.type.isboss then
     if (e.y-cam_y)>128 then
      enemy_kill(e,false)
     else
      if abs(player_x-e.x)>3*128 then
       enemy_kill(e,false)
      end
     end
    end
   end
   
   enemy_check_player(e)
   
   if(e.type.update)e.type.update(e)
  end
 end
end

--
function enemies_draw()
 
 for k,e in pairs(enemies) do
  if e.active then
   for i=1,15 do
    pal(i,(e.damaged_timer>0) and 8 or 0)
   end
   
   enemy_draw(e, 1, 0)
   enemy_draw(e,-1, 0)
   enemy_draw(e, 0, 1)
   enemy_draw(e, 0,-1)
   
   if not e.type.isboss then
    enemy_draw(e, 1, 1)
    enemy_draw(e,-1,-1)
    enemy_draw(e,-1, 1)
    enemy_draw(e, 1,-1)
   end
   
   if e.damaged_timer>0 then
    pal()
    local scale=(e.type.scale or 1)
    print_outline(""..flr(e.health*10),e.x+4*scale,e.y-6,0,7)
    pal(7,8)pal(6,9)pal(5,8)
    pal(11,10)pal(3,9)pal(4,9)pal(13,9)pal(2,8)
    pal(8,10)
   else
    pal()
   end
  
   enemy_draw(e,0,0)
  end
 end

 pal()
end

-- pickups
pickups={}

pickup_types=nl("65,80,81,96,97,112,113")

for i=1,40 do
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
function pickups_spawn(x,y,vy,golden)
 local pu,i=find_next_i(pickups,pickups_next,pickups_active_count)

 if pu then
  pickups_next=i
  
  pickups_active_count+=1
  pu.active=true
  
  pu.golden=golden
  pu.x,pu.y=x,y
  pu.vy=vy
  pu.spr=pickup_types[1+flr(rnd(#pickup_types))]
 end
end

--
function pickups_update()
 for k,pu in pairs(pickups) do
  if pu.active then
   pu.y+=pu.vy
   
   if s_floor(pu.x+4,pu.y+8) then
    if abs(pu.vy)>.2 then
     pu.vy=-.8*pu.vy
    else
     pu.vy=-1.5
    end
   else
    pu.vy=min(pu.vy+.2,10)
   end
   
   if pu.y>cam_y+128+32 or pu.y<cam_y-32 then
    pickups_active_count-=1
    pu.active=false
   end
  end
 end
end

--
function pu_draw(pu,ox,oy)
 spr(pu.spr,pu.x+ox,pu.y+oy)
end

--
function pickups_draw()
   
 for k,pu in pairs(pickups) do
  if pu.active then
   local oc=pu.golden and 10 or 0
   
   for i=1,15 do
    pal(i,oc)
   end
   
   pu_draw(pu, 1, 0)
   pu_draw(pu, 1, 1)
   pu_draw(pu,-1, 0)
   pu_draw(pu,-1,-1)
   pu_draw(pu, 0, 1)
   pu_draw(pu,-1, 1)
   pu_draw(pu, 0,-1)
   pu_draw(pu, 1,-1)
 
   pal()
   pu_draw(pu,0,0)
  end
 end
end

-- level

function level_restart()
 level_timer=0
 cam_x=0
 player_reset()
 enemies_reset()
 ebs_reset()
 pickups_reset()
 
 music(0,500)
end

--
function level_update()
 level_timer+=one_frame
 
 if level_finished then
  level_finished_timer+=one_frame
 
  if level_finished_timer%.25>(.25-one_frame) then
   pickups_spawn(cam_x+rnd(128),cam_y-7,0,false)
  end
  
  if level_finished_timer>10 then
   level_finished,level_finished_timer=false,0
   
   if player_level<3 then
    player_level+=1
    save_game()
    
    level_restart()
   else
    game_finished=true
   end
  end
 end
end

--
function level_draw()
 pal(14,0)
 
 
 local level=flr(cam_y/128)
 if level==1 then
  pal(7,9)
  pal(6,4)
 elseif level==2 or level==3 then
  pal(12,9)
  pal(13,4)
 end
 
 local map_y=flr(cam_y/8)
 map(0,map_y,0,map_y*8,16*8,16,0x10)
 pal()
 
 if level_timer<2 then
  if level==0 then
   spr(level_timer%.2>.1 and 40 or 41,32-level_timer*32,88)
  end
   
  local names={"-forest-","-dungeon-","-keep-","-tower-"}
  
  if(level_timer%.4>.1)print_outline(names[level+1],cam_x+64,cam_y+48,0,7)
 end
end

--
local title="2d000170027701073c000170027701073c0002770171017701073b0001770117011102770200017002773600017701170111037701070377190001700377010704000170017701070200027701070b00017001770311067701070e000170037701070400017005770300017003770107047701070170057704000170017701110177011101710377011102770d0001700577010703000777020011770107020002770111017701170211027701110171017701070b000170077701070100017002770311027701070377011101710277021101710a770170017701170171027701170511017701070b0002770117031101710277010002770511047703110177011703110177011705110577011105770411017701070b00017701170511017103770117011103ee0111017102770117011101ee011e0171011701e101ee01110171061101710377011701110677011701710117017101770a0001700177011101e103ee011e01110377011101e103ee011e01110277011101e101ee011e0171011102ee011e011101e105ee0111011701710177011101710677011701710117017101770a000277011105ee0111017101770117011105ee011101710177011102ee011e021103ee011101e105ee01110117017101170171057701ee0177011e0211017101770a000177011701e105ee011e01110177011701e105ee011e0171011701e102ee011e011101e103ee011101e105ee011101170211067703ee031101770107080001700177011101e106ee01110177011106ee011e0111011701e102ee011e011101e103ee011104ee0211017101170211017701e7017e027701e705ee011101770107080001700177011107ee011e0177011107ee0111011701e102ee011e011101e103ee011103ee011e02110171011101170111017701e701ee027706ee01110171017708000277011107ee011e0177011103ee011103ee021101e102ee011e011101e102ee011e011103ee011e0171027701110177011107ee011e01e102ee011e0171017708000177011701e103ee011101e102ee011e011701e103ee011101e102ee011e011103ee011e011103ee011e011103ee0111017102770117021107ee011e01e102ee011e01710177010707000177011701e103ee021102ee0111011701e102ee011e011101e102ee011e011103ee011e011103ee011e011103ee0111017102770117011101e106ee01e105ee01110177010707000177011701e103ee021101e10211011701e102ee011e011101e102ee011e011108ee021103ee011e021101770117011102ee011102ee011e02e105ee0111027707000177011701e103ee0171011702110171011103ee011e011101e102ee011e011107ee011e021105ee011e0171011701e102ee011101ee011e021101e105ee01110171017707000177011701e103ee01710177011701710177011103ee011e011101e103ee011107ee011e021105ee011e0171011701e104ee011e021105ee011e01110171017707000177011701e103ee01710477011103ee021101e103ee011107ee0111011701e105ee011e0171011701e10aee04110171017707000177011701e103ee01710477011103ee0111011701e103ee011107ee0111011701e105ee01110177011701e107ee031101910199011101190171017707000177011701e103ee01710477011103ee021101e103ee011107ee0111011701e104ee011e01110177011701e105ee0111011e0311039901190171017707000177011701e103ee011101770117031103ee011e011104ee011107ee011e011101e103ee011e011101710177011701e104ee03110191059901190171017707000177011701e103ee01110177031101e104ee01e104ee011107ee011e011101e103ee011e01110277011701e101ee011e021101910199011106990119037706000177011701e103ee031101ee011e01e109ee011108ee011101e103ee011e0111027701170311019901110999011903770107050001770117011103ee011e011102ee011e01e109ee011103ee011e011103ee011e01e103ee011e021101770117021101910b9901110477050001700177011107ee011e01e109ee011103ee011e011103ee011e01e104ee011e011101710117019101190c9903110277050001700177011107ee011e01e109ee011103ee011e011101e102ee011e011105ee011e017101770111059901110799041101770107040001700177011701e106ee011e01e103ee011e011101e103ee011101e102ee011e011101e102ee011e011105ee011e01710177011701910399021107990111027701110177010705000177011701e106ee011101e103ee021101e103ee011101e102ee011e011101e103ee011105ee011e017102770111029907110191029901110177011701110177010705000277011105ee011e021103ee01110117011103ee011101e102ee011e021102ee011e011105ee011e017102770117019101990311049902110191031101710177060001700177011101e104ee01110171011103ee01110177011102ee011e021102ee01110171011101e101ee011e011101e104ee01110171027701170191029902110699041102770600017001770117011103ee011e01110171011101e102ee01110177011101e1011e01110177011101e1011e011101770117011101ee021101e103ee011e01110477011103990111079901110171027701070700027701170411017101770117011101e10111017101770117021101710177011702110171027703110177021101ee021101710377011701110b990111047707000170027705110277031108770211017103770711017102770117051107990119031101710277010707000177011706110277011701710177011701110171037701170311027701170711017101770117021101e101ee011e0111019103990119071101710277070001770117011103ee011e0111017103770117031101710277011101e101ee011101710177011101e105ee011e01110177021105ee01110299031101e104ee0211017101770107060001700177011105ee01110377011101e101ee011e01110277011103ee01110177011107ee01110117011106ee011e031108ee011e0111027706000277011105ee011101710277011103ee01110177011701e103ee011e021107ee021101e107ee021101e109ee01110171017706000277011106ee01110177011701e103ee01110171011701e103ee011e011101e107ee021108ee011e01110aee011e011101770107050001770117011106ee01110177011701e103ee011e0171011701e103ee011e011101e106ee011e011101e108ee011e01e10bee011101770107040001700177011701e106ee011e0171011704ee011e0171011104ee011e011101e104ee041101e104ee011e011102ee011e01e10bee011101770107030001700277011701e106ee011e0171011104ee011e0171011104ee011e011104ee011e0311011701e104ee021101e101ee011e01e10bee011101770107030001700277011701e106ee011e0171011104ee011e0171011104ee011e011104ee011e01110277011704ee011e0171011701e101ee011e01110bee01110177010703000277021108ee021104ee01110177011104ee011e011104ee011e01710277011704ee011e0171017704110aee011e011101770107020002770117011101e108ee011101e104ee01110177011104ee011e011104ee011e01710277011705ee01110177021101710117031107ee011101710177010702000277011701e103ee01e105ee011101e104ee01110177011104ee011e011104ee011e02110171011705ee011101710477031101e103ee011e03110277020001700277011101e102ee011e011105ee011101e103ee011e01710177011104ee011e011104ee011e041101e104ee011e01110677011101e103ee03110377020001700177021103ee021101e104ee011101e103ee011e01710177011104ee011e011107ee011e011101e105ee02110577011104ee01110477030001700177011101e103ee0111011701e104ee011101e103ee011e01710177011104ee011e011107ee011e011101e105ee011e011101710477011104ee011103770107030001770117011104ee0111011701e104ee011e01e103ee011e01710177011104ee011e011107ee011e0171011106ee011e01110477011104ee01110277010704000177011701e104ee0111011701e104ee011e01e103ee011e01710177011104ee011e01e107ee011e0171011101e106ee011101710377011104ee01110177010705000177011701e104ee01110117011104ee011e01e103ee011e01710177011104ee011e01e107ee011101770117011106ee011e01110377011104ee0111027705000177011701e104ee01110177011104ee011e01e103ee011e01710177011104ee011e01e107ee01110277011101e106ee011e01710277011104ee011e0171017705000177011701e104ee01110177011104ee011e01e103ee011e01710177011104ee011e01e105ee011e0111017102770117011101e105ee011e01110277011104ee011e0171017705000177011701e104ee01110177011104ee011e01e103ee011e01710177011104ee011e01e105ee021104770117011106ee01110277011104ee011e01710177050001700177011104ee0111011701e104ee011101e103ee011e031104ee011101e105ee01110677011101e105ee01110277011104ee011e01710177050001700177011104ee0111011701e104ee011101e104ee021101e104ee011101e105ee0111017105770117011105ee011101710177011104ee011e01710177050001700177011104ee021101e104ee011101e10bee011101e105ee021101710177011701710277011105ee011e01710177011104ee011e01710177050001700177011104ee011e011101e104ee011101e10bee011101e106ee0211011703110177011105ee011e01710177011104ee011e0171017706000177011704ee011e011105ee011101e10aee011e021107ee021101e1011e031105ee011e01710177011104ee011e0171017706000177011701e109ee011e017101110aee011e0171011107ee011e011103ee011106ee011e01710177011104ee011e0171017706000177011701e109ee011e017101110aee011e0171011107ee011e01110aee01110277011104ee011e01710177060001770117011109ee01110171011701e109ee01110177011107ee011e01110aee01110277011104ee011e01710177060001700177011109ee011e0171011701e109ee01110177011701e106ee011e011109ee011e01110277011104ee011e01710177060001700177011701e109ee01110177011108ee011e01710177011701e106ee011e011101e108ee011e01710277011101e103ee011e0171017707000177011701e109ee011e0171011101e107ee0111017101770117011106ee031107ee011e01110377011701e103ee011e0171017707000277011101e108ee011e01710117011106ee011e01110377011105ee011e01110177021106ee0111017103770117011103ee011102770700017001770117011103ee011e04ee011e01710177021104ee011e011101710377011701e103ee011e011101710277021101e102ee011e02110277010001700177021101ee02110177010708000277051101e103ee011e0171017701170711027701000177011705110171037701170611037701000170017701170311017101770107080001700277041101e103ee011e01710377041101710277010701000277011703110171067703110171037703000377011103770a000677011101e102ee011101710a770200017007770107010001700877010703000170057701070a000170057701170411027701700777040007770300017006770107050005770d000577011702110277010701000170057706000577060004770900017701071100017006773a00057701073b0003770107fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe00fe004900"


function hex_to_num(str)
	return ("0x"..str)+0
end

function load_rle()
	local index=0
	for i=1,#title,4 do
		local count=hex_to_num(sub(title,i,i+1))
		local col=hex_to_num(sub(title,i+2,i+3))
		for j=1,count do
   poke(index,col)
		 index+=1
		end
	end
end

function clear_sprsheet()
	reload(0x0,0x0,0x2000)
end

--
fe_view={}
fe_fade_in,fe_time,fe_eating_x=1.5,0,6

--
fe_view.start=function()
 load_rle()
end

--
fe_view.update=function()
 fe_time+=one_frame
 
 parts_update()
 
 if fe_fade_in>0 then
  fe_fade_in-=one_frame
 else
  fe_fade_in=0  
 end
 
  if btnp(4) or btnp(5) then
   sfx(rnd()>.5 and 4 or 5)
   
   cls()
   spr(0,0,0,16,16)
   circfill(fe_eating_x,8+rnd(2),12,0)
   circfill(fe_eating_x+4,28+rnd(2),13,0)
   circfill(fe_eating_x+4,48+rnd(2),13,0)
   circfill(fe_eating_x,68+rnd(2),12,0)
   
   fe_eating_x+=8
   memcpy(0x0,0x6000,0x2000)
  
   for i=1,40 do
    local a,r=rnd(),.5+rnd(2)
    local vx,vy,s=r*cos(a),r*sin(a),rnd(4)
    local c=i%2==0 and 9 or 14
    local bc=i%2==0 and 4 or 7
    parts_spawn(.5,fe_eating_x-12+rnd(24),10+rnd(80),vx,vy,.2,.95,s,s,-.2,-.2,c,bc,parts_flags_none)
   end  
  end
  
  if fe_eating_x>100 then
   current_view=game_view
   current_view.start()
  end

end

--
function draw_outline_title(c,outline,r,scale)
 pal(7,c)pal(1,c)pal(14,c)pal(9,c)
 sspr(0,0,16*8,11*8,0-outline+r*cos(fe_time/2),-128*scale+20-outline+r*sin(fe_time/2),16*8+outline*2,11*8+outline*2)
end

--
fe_view.draw=function()
 cls(1)

 local ft=-max(0,fe_fade_in-1)/.5
 local scale=ft*ft*ft*ft
 
 for j=-16,136,16 do
  local d=-16*flr(j%32/16)
  local y=j+9*cos(j/78-fe_time)
  for x=d,136,32 do
   if (j+x)%64>=32 then
    circfill(x,y+3,7,4)
    circfill(x,y,8,7)
    circfill(x,y-2,7,4)
    pset(x-2,y-6,5)
    pset(x+2,y-6,5)
    pset(x-4,y-3,5)
    pset(x+4,y-3,5)
    pset(x-2,y,5)
    pset(x+2,y,5)
   else
    circfill(x,y+4,7,4)
    circfill(x,y,8,9)
    circfill(x,y-2,6,7)
    circfill(x,y-5,2,8)
    pset(x-1,y-6,7)
   end
  end
 end
 
 draw_outline_title(4,6,3,scale)
 draw_outline_title(9,3,4,scale)
 
 pal()
 spr(0,6*cos(fe_time/2),-128*scale+20+6*sin(fe_time/2),16,11)
 
 print_outline("lil' satan's",40,16,7,2)
 
 if (fe_time%.4<.3)print_outline("press \142 to start!",64,111,14,2)

 print_outline("guerragames 2017",64,120,7,2)
 
 parts_draw()
end

--
game_view={}

game_finished,game_finished_timer=false,0
--
function game_finished_update()
  game_finished_timer+=one_frame

  bg_update()
  parts_update()
  
  if game_finished_timer%.5>.45 then
   local x,y=cam_x+rnd(128),cam_y+rnd(128)
   for i=0,20 do
    local a,r=rnd(),1+rnd(3)
    local vx,vy=r*cos(a),r*sin(a)
    parts_spawn(2,x,y,vx,vy,.1,.97,4,4,-.1,-.1,8,10,parts_flags_blink)
   end
  end  
end

--
function game_finished_draw()
 draw_hud()
 parts_draw()
 local spr1x,spr1y=spr_index_to_xy((game_finished_timer%.4>.2) and 4 or 6)
 sspr(spr1x,spr1y,16,16,cam_x-48+64,cam_y+72,48,48)
 
 local spr1x,spr1y=spr_index_to_xy(8)
 sspr(spr1x,spr1y,16,16,cam_x+64,cam_y+72,48,48)
  

 local blink=(game_finished_timer%.2>.1)
 local c=blink and 0 or 10
 local bc=blink and 7 or 8
 
 local a=min(.25,game_finished_timer/2)
 local y=cam_y-6-52*sin(a)
 
 print_outline("deaths:"..player_deaths,cam_x+64,cam_y+14,0,7)

 print_outline("congratulations lil' satan!",cam_x+64,y,c,bc)
 
 local y2=cam_y+128+70*sin(a)
 print_outline("the cake is real!",cam_x+64,y2,c,bc)
end

--
game_view.start=function()
 clear_sprsheet()
 
 jump_button:button_init()
 shoot_button:button_init()

 bg_init()
 player_init()

 level_restart()
end

--
game_view.update=function()
 if(not game_finished and not player_gameover)game_time+=one_frame
 
 update_screeneffects()
 
 jump_button:button_update()
 shoot_button:button_update()
 
 cam_update()
 
 if game_finished then
  game_finished_update()
  return
 end
 
 level_update()
 bg_update()
 
 enemies_update()
 ebs_update()
 
 pickups_update()
 player_update()
 pbullets_update()
 parts_update()
end

--
game_view.draw=function()
 
 if screen_flash_timer>0 then
  cls(screen_flash_color)
  return
 end
 
 cls()
 bg_draw()
 camera(cam_x+cam_shake_x,cam_y+cam_shake_y)
 
 if game_finished then
  game_finished_draw()
  return
 end
 
 level_draw()
 draw_hud()
 
 enemies_draw()
 
 pickups_draw()
 player_draw()
 parts_draw()
 
 camera(0,0)
end

--

current_view=fe_view
current_view.start()

--
function _init()
 menuitem(1,"reset progress!?",reset_game)
 music(0)
 
 load_game()
end

--
function _update60()
 current_view.update() 
end

--
function _draw()
 current_view.draw()
 
 --print_outline("mem:"..stat(0),1,116,0,7,align_l) 
 --print_outline("cpu:"..stat(1),1,122,0,7,align_l)
end
if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
00000000000000000000000000000000000100000001000000000000000000000000000000000000000000000066660000000000003333004000000440444404
000000000000000000000000000000000012170000121700000000000000000000000000000000000066660007777760003333000bbbbb308044440888888888
00000700000007000001000000010000012217700001770000000000000000000000000000000000077777607ddddd760bbbbb30bb787bb30888888009989980
000007700000770000121700001217000002102888820000000100000001000000000677776000007ddddd7677d7d776bb787bb3bbbbbbb38998998488888884
0000002888820000012217700001770000000288888820000012170000121700000677776777600077d7d77677777776bb787bb3808080b38888888488888884
010002888888200000021028888200000000288818818000012217700001770000677787787776007777777660606076bbbbbbb3000000b38888888470007084
121128881881800000000288888820000000288888888000000210288882000006776777777877606060607600000076808080b3000088b37000708400000084
12202888888880000000288818818000000028887070700000000288888820000778776787776760067777600677776003bbbb3003bbbb300088884000888840
1000288888888000000028888888800000002880000000000000288818818000077777777677776000000000000dd00000000000000420000088880044888800
0000288888888000088028888888800008802880000000000880288888888000046768787787764000000000000dd00000000000000420000028820044288200
00012888888880000810288888888000081028800000000008102880707070000446677777777440000dd00077dd7700000420000b3240000028440000288244
08100288888820000001288888888000000128887070700000012888888880000244476676646420007d7700770d77000004200003b23b000448440000088044
08800028888208000000128888882000000012888888200000001288888880000024644464444200007d7700000dd0000b3240000002b3000448800040088000
00002800000082000000002888820000000800288882008000000028888200000002444444442000000ddd0000ddd00003b23b00000420000002800044228000
0000800000000000000000000000000000028000000008200000000000000000000002222220000000d0077007700d000002b300002442000004420044000844
00000000000000000000008800880000000000000000000000000088008800000000000000000000077000000000077002424240024242400044420000000044
0000000000000000000000000000000000000000000000000000000000000000004440000000000000000000000dd00008bbb0000008bb000000000000666600
000000000000000000000000000000000010000000100000000000000000000000f1f40000444000000000005555500030bbbb003000bbb00066660006777760
00000700000007000000000000000000012170000121700000010000000100000044440000f1f4005555500052825700b8b77b30b008b7b30677776067d7d776
00000770000077000000000000000000122177000017700000121700001217000044f000004444005282570052825700b0b88b30b000b8b367d7d77667d7d776
00000028888200000001000000010000002102888820000001221770000177000ffffff00044f0005282570058885000b8b77b30b808b7b367d7d77667d7d776
0100028888882000001217000012170000002888888200000002102888820000000ff00000ffff0058885d0052825000b0bbbb30b800bbb367d7d77667777776
12112888188180000122177000017700000288818818000000000288888820000f8888f0000880005282577005550d003bbbb3003bbbbb306777777667777776
122028888888800000021028888200000002888888880000000028881881800000000000000f0f00055500000000077003333000033333000677776006777760
1000288888888000000002888888200000028887070700000000288888888000000000000000000000000000000550000004200000000000000dd00000000000
0000288888888000000028881881800088028800000000000880288888888000000000000000000000000000000dd000000420000000000000d77d0000000000
00012888888880000000288888888000810288000000000008102888888880000000000000000000000000000005500000024000b302403b0d7777d0000dd000
0810028888882000088028888888800000128887070700000001288888888000000000000000000000000000007dd700003243003b3243b3d777777d77777777
08800028888200000810288888888000000128888882000000001288888820000000000000000000000dd00007055070b302403b0002400077777777d777777d
0000000000000000000112888888200000800288882008000008802888820000000000000000000077055077000dd0003b0420b30004200000077d000d7777d0
0000000000000000000000000000000000280000000082000008000000000000000000000000000000dddd00007007000004000000004000000d7700000d77d0
00000088008800000000008800880000000000000000000000000000000880000000000000000000770000770070070000040000000004000000d7d00000d77d
00000000000400000000440000000000560056000000400011555511e9eee49ee94e99ee4499ee94e94eee941ccc111177777771066666000000000000000000
00000000004a40000004240007707700560056000000400015666651944e494e4944ee4494ee9e494444e4491cddd1cc7666666166eee6600000000000000000
0000000004787400004424407887ee70560056000000420056eeee654494444944494e49e994944494494e9e1dddd1cd716661616e5555600666660000000000
000000004a878a40004442407888ee70666056000000440056eeee654494944994494494eee444949449449e1dddd1dd111111116666666066eee66000000000
000000004444444400442224078ee700555566650004420056ebbe654944449449449444eee9449449449eee1111111177117777666555606e55556000000000
000000004a7777a404422224007e70005600550000042200563be365444494e44e444494eeee94494e44eeeecccc1cc166617666666666606666666000000000
000000004999999404224242000700005600560000022400153beb51949494e9ee494944eeeee4e49e9eeeeecddd1cd166617616655556606556566000000000
0000000004444440042444e400000000560056000004224011b3b3e1ee444e4ee4e4494eeeeeee4ee4eeeeee11111dd111111111666666606666666000000000
0044440000444400042244200000000000000000004224001cbe3b11000000000000000000000000177177711ccc11111ccc1111000000007777777600000000
0444444004eeee40224444240000000004400000004224001cb3b3ec060006000600000000000000766666611cddd1cc1cddd1cc000000007000000600000000
444994444ee7aee4422442220000004044444444004242001db3b3ed060006000600060000000600766166111dddd1cd1dddd1cd000600007006000600000000
449009444eeaaee4422444e20444444443223220000322001db3e3ed060066606660060006000600111111111dddd1dd1dddd1dd006000007060000600000000
9444444994eeee4944242242434443222300300000242400113b3b11666055555555666566600600771117711111111111111111000007007000070600000000
499444944944449444244242432203200000300000422000cc3e3ec155555600560055005555666566617666cccc1eeeeeee1cc1000070007000700600000000
049994400499994004244242230003000000000000424000cd3ebed156005600560056005600550016617166cddd1eeeeeee1cd1000000007000000600000000
0044440000444400042444e4000000000000000000423420111ebed15600560056005600560056001111111111111eeeeeee1dd1000000006666666600000000
00444400000000000e4442400000000000000000004e4400ebb3bb3bbebbbbebbbbebbebb3bb3bbeeeeeeeee1ccc11eeeeeee111777777710000000000000000
045454400999000024244240000000000000000000432000b3eb3ebbbbbebbbbbbebbebbbbe3be3beeeeeeee1cddd1eeeeeee1cc766666600000000000000000
44444444a999900024244244444000000000000000442400b3bebe3eeb3e3eb3e3ebeb3ee3ebeb3beeeeeeee1dddd1eeeeeee1cd706660610000000000000000
44544454a7999900242242440224444004000000002e40003be3e3beeee3e3b3eb3e3eebeb3e3eb3eeeeeeee1dddd1eeeeeee1dd111011110000000000000000
644454460aa999902e4442240003223444444440002e4200b3be3ebeebeee3e3ebe3ebebebe3eb3beeeeeeee1111111111111111771177770000000000000000
4744447400a7999022242224000300322234443400023400b3bebeeeebe3eeebeeebebeeeeebeb3beeeeeeeecccc1cc1cccc1cc1666076660000000000000000
04777740000aa94042242422000000300230223400042400b3e3beeee3e3eeebeeebeeeeeeeb3e3beeeeeeeecddd1cd1cddd1cd1666176060000000000000000
004444000000aa0022242440000000000030003200422400bebebeeeeeeeebeeeeeeebeeeeebebebeeeeeeee11111dd111111dd1101101110000000000000000
00000000000000004244424242244240424242400044e400000000000011110000000000777777711ccc1111e1ddcdcdcdddd11e000000000000000000000000
000780000940094022242242244424422ee4ee420042e30000000000001cc10000000000766666611cddd1cce1ddcccccdddd11e000000000000000000000000
00788a00aa0000aa222422224e444e444ee4ee440042420000000000001cd10000000000716661611dd111cde1ddcdcdcdddd11e000000000000000000000000
077777a094000094022222204ee4ee42244444420044200000000000001dd10000000000111111111d1ee1dde1dddcccddddd11e000000000000000000000000
077777a09a4009a40240202024e4e42424e4e42400404200000000001111111100000000eeeeeeee1111ee11e1ddcdcdcdddd11e000000000000000000000000
09999940a99aa99a02002000244444242eeeee240000400000000000cccc1cc100000000eeeeeeeecccc11c1e1ddcccccdddd11e000000000000000000000000
049994400a9a94a0020020004e4e4e244eeeee240000400000000000cddd1cd100000000eeeeeeeecddd1cd1e1ddcdcdcdddd11e000000000000000000000000
00444400000940000000000022e4e44222e4e442000000000000000011111dd100000000eeeeeeee11111dd1e1dddcccddddd11e000000000000000000000000
b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7c7a6c6b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4c4c4c4c4b4
b4b4b4b4b4b4b4b4c4c4a6b4b4c5b4b4b4b4b4b4b4b4b4b4b4b4b4b4777777777777040404040404040404040404040404040404040404040404040404040404
b4b4b4b4b4b4b4b4b4e5e5e5e5b4b4b4b4b7c7a6c5b4b4b5b4b4b4a7b4e5e5e5e5c6b4e5e5e5e5b4b4e5e5e5e5b4b4e5e5e5e5b4b4b4b4b4b4b4b4c4c4c4c4b4
b4b4b4e5e5e5e5b4c4c4a6c6e5e5e5e5b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4040404040404040404040404040404040404040404040404040404040404
b4b4b4b4c6b4b4b4b4e5d5d5e5b6b4b4b5b7c7a6b4b4b4c3c5b4b4b4b4e5d5d5e5b4b4e5d5d5e5b4b4e5d5d5e5c6b4e5d5d5e5b4b4b4b4b4b4b4b5c4c4c4c4c5
b4b4b5e5d5d5e5c5c4c4a6b4e5d5d5e5c5b4b4b4b4b4b4b4b4b4b4d6d6c4c4c4c4c4040404040404040404040404040404040404040404040404040404040404
b4b4b4b4b4b4b4b4b4e5d5d5e5b4b4b4b4b7c7a6c5b4b4c6b4b4b4c6b4e5d5d5e5b4b4e5d5d5e5c6b4e5d5d5e5b4b4e5d5d5e5b4b4b4b4b4b4b504d6d6d6d604
c5b4b4e5d5d5e5b4c4c4a6b4e5d5d5e5b4b4b4b4b4b4b4b4b4b4b4b4b4c4a6a6a6a6a67777777777777777c4c4c404040404040404040404d004040404040404
b4b4b4b4b4b4b4b4b4e5d5d5e5b4b4b5b4b7c7a6c6b4b4b4b4b4b4b4b4e5d5d5e5c5b4e5d5d5e5b4b4e5d5d5e5b4b4e5d5d5e5b4b4b4b4b4b504040404040404
04c5b4e5d5d5e5c5c4c4a6b4e5d5d5e5b4b4a5a5c5b4b4b4b4b4b4c4c4c4a6b4b4b4b4b4b4b4b4b4b4b4b4c4c4c4a67777040404040404040404040404777777
c6b4b4b4b4b4b4c6b4e5d5d5e5b4b5b5b4b7c7a6c6b4b4b4b4b5b4b4b4e5d5d5e5c0c5e5d5d5e5b4b4e5d5d5e5b4b4e5d5d5e5b4b4b4c4c4c4c4c4c4c4c4c4c4
c4c4a6e5d5d5e5b4d6d6a6b4e5d5d5e5b4b5c4a5a6b4b4b4b4b4b4c4c4a6a6b4b4b4b4b4b4b4c4c4c4c4c4c4c4c4a6b4b4777777040404040404777777b4b4b4
b4b4b4b4b4b4c6b4b4e5d5d5e5b4b5c3b4b7c7a6b5a6c5a6c5b4b4b4b4e5e5e5e5c6b4e5e5e5e5b4b4e5e5e5e5c6b4e5e5e5e5b4b4b4c4c4a6a6a6a6a6a6a6a6
a6a6a6e5e5e5e5b40404a6b4e5e5e5e5b5a6c4a5a6b4b4b4b4b4b4c4c4a6b4b4b4b4c4c4c4c4c4c4c4c4c4c4c4c4a6b4b4b4b4b4777777777777b4b4b4b4b4b4
b4b4b4b4b4b5b4c5b4e5e5e5e5b4b4b4b5b7c7a6b4a6a6a6a6b4b4a7979797979797a6b4b4c6b4b4b4b4b4c6c0b4b497979797a6b4b4c4c4a6b4b4b4b4b4b4b4
b4b4b4b4b4c6b4b5c4c4a6b4b4b4a5c4c4c4c4c4c4c4a5c4c5b4b4c4c4a6b4b4b4b4e3a6a6a6a6a6a6a6a6c4c4c476978697b4b4b4b4b4b4b4b4b4b497869797
b4b4c6b4b4b4b4b4c5b4a2b4b4b4b4b4b5b7c7a6a6a5c4c4a6b4b4b4c6c6b7c7a6b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7c7a6b4b4b4c4c4a6c6b4b4b4b4b4b4
b4b4b4b4b4b4b5a6c4c4a6b4b4b4b4b7c7a6a6a6a6a6c4c4a6b4b4c4c4a6b4b4b4b4b4b4b4b4b4b4b4b4b4c4c4c4a6b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4
b4b4b4b4b4b6b4b5c5c6b4b4b4b4b5b5a6a5c4c4c4c4c4c4a6c5b4b4b4b5b7c7a6c6b4b4b4b4c0c6b497979797a6b4b4b7c7a6b4b4b4c4c4a6b4c2b4b4b4b4c4
c4c4a5c4c4c4c4c4a5c4a6c6b4b4b4b7c7a6b4b4b4b4c4a5a6b4b4c4c4a6c5b4b4b4b4b4b4b4b4b4b4b4b4c4c4c4a6b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4
b4b4b4b4b4b4b5a6a5c4c4a5c4c4c4c4c4c4a6a6b7c7a6a6c6b4b4c5b4b6b7c7a6b4b4b4b4b4b4b4b4b4b7c7a6b4b4b4b7c7a6c6b4b4c4c4a6b4c6b4b4b4b4c4
c4a5c4c4a5c4c4c4c4c4a6c5b4b4b4b7c7a6b4b4b4b4c4c4a6b4b4c4c4c4c4c4c4c4c5b4b4b4b4b4b4b4b4c4c4c4a6b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4
b4b4b4b4b5a5a5c4c4a5a6a6b7c7a6a6a6a6a6c6b7c7a6b4b4b4b4b4c5b6b7c7a6b4b497979797a6b4b4b7c7a6b4b4b4b7c7a6b4b4b5c4c4c4c4c4a6b4b4b4b6
a6b7c7a6a6a6a6a6a5c4c4c4a5c4c4c4c4a5a6b4b4b4c4c4a6b4b4c4c4c4c4c4c4c4c4c4c4c4c5b4b4b4b4c4c4c4979776b4b4b4979776978697b4b4b4977697
b4b4b4b5a6c4a5c4c4a5a6b6b7c7a6b4b4b4b4b5b7c7a6b4b4b4b4b4b4b5b7c7a6c6b4b4b7c7a6b4b4b4b7c7a6c6b4b4b7c7a6b4b5a6c4c4c4c4c4a6c6b4b4b4
b4b7c7a6b4b4b4b4b6a6a6a6a6a6a6b7c7a6a6b4b4b4a5c4a6b4b4a6a6a6a6a6a6a6a6a6a6a6a6b4b4b4b4c4c4c4a6b4b4b4b4b4b4b4b7c7a6b4b4b4b4b4b4b4
a5a5a5c4c4c4a5d6d6d6a6b5b7c7a6b4b4b4b5a6b7c7e0b4b4b4b4b4b4b5b7c7a6b4b4b4b7c7a6c6b4b4b7c7a6b4b4e0b7c7a6c6d6d6d6d6c4c4c4a6b4b4b4b4
b4b7c7c2c2c2c2b4b4e0b4b4b4b4b4b7c7a6b4b4b4b4d6d6a6b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4c4c4c4a6b4b4b4b4b4b4b4b7c7a6b4b4b4b4b4b4b4
c4c4c4a5c4c4c4a6a6a6a6a6b7c7a6a6c5b5a6a6b7c7a6c5b4b4b4b4b4a5c4c4c4c4c4c4b7c7a6b4b4b4b7c7a6b4b4c6b7c7a6b4a6a6a6a6c4c4c4a6b4b4b4b4
b4b7c7a6b4c6b4b4b4b4b4b4b4b4b4b7c7a6b4b4b4b4a6a6a6b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4c4c4c4a6b4b4b4b4b4b4b4b7c7a6b4b4b4b4b4b4b4
c4a5c4c4c4c4a5c4c4a5a5c4a5c4c4c4a5c4c4a5a5c4c4c4c4c4a5c4c4c4a5c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4
c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a200a20000c0000000e20000
00e200000000000000a20000a3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000c3000000000000000000000000000000000000000000000000000000000000000000000000000000e2
00000000000000000000000000000000000000000000000000a30000000000000000a30000a300000000000000a3000000000000000000000000000000000000
000000000000009797979797977700000000000000000000000000000000000000000000c3009797979797970000c30000000000979797979797000000000000
000000000000000097979797979700000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000000000000
00000000000000b4b4b7c7a6b4b40000000000000000000000000000009797979700000000000000b7c7000000000000000000000077b7c70000000000e20000
00e20000000000000000b7c700000000000000000097979797979700000000000097979797979700000097979797979700000000009797979797970077000000
0000000000000000b4b7c7a6b40000c30000000000000000000000e30000b7c70000000000000000b7c700c3000000000000000077b4b7c7a6a200a2c00000e2
000000000000a200c077b7c70000a200c000a300000077b7c70000a300a30000000000b7c700000000000000b7c7000000000000000000b7c7a60077b4770000
000000000000000000b7c7a6b47700000077000097979797979700000077b7c7a600009797979700b7c700000000000000000077b4b4b7c7a677000077000000
000000000000000000b4b7c700000000000000000077b4b7c700000000000000000000b7c700a30000000000b7c7000000000000000077b7c7a677b4b4b47700
000077777777007700b7c7a6b4b4777777b477000000b7c7a600000000b4b7c7a6770000b7c7a600b7c7a67797979797979700b4b49797979797979797e20000
77e277979797979797a6b7c7979797979797979700b4b4b7c7a6979797979797007777b7c700000000000077b7c70000000000000000b4b7c7a6b4b4b4b4b400
0077b4b4b4b477b477b7c7a6b4b4b4b4b4b4b4770000b7c7a600007777b4b7c7a6b40077b7c7a677b7c7a6b4b400b7c7a67777b4b4b4b7c7b7c7a677b47777e2
b477b4b477b7c7a600b4b7c7a60077b7c7a6b47777b4b4b7c7a60000b7c7a6b400b4b4b797979797979700b4b7c70000979797979797a6b7c7a6979797979797
979797979797b4b4b4b7979797979797b4b4b4b47777b7c7a697979797a6b7c7a6b477b4b7c7a6b4b7c7a6b4b477b7c7a6b4b4b4b4b4b7c7b7c7a6a6b4b4a677
b4b4b4b4b4b7c7a677b4b7c7a600b4b7c7a6b4b4b4b4a3b7c7a6b477b7c7a6b477b4b4b7c7a3b7c7a67700b4b7c7a6770000b7c7a6b4b4b7c7a6b4b4b7c7a677
00b4b7c7a6b4b4b4b4b7c7a6b7c7a6b4b4b4b4b4b4b4b7c7a677b7c7a6b4b7c79797979797979797b7c7a6b4b4b4b7c7a6b4b4b4b4b4b7c7b7c7a69797979797
9797979797b7c7a6b4b4b7c7a677b4b7c7a6b4b4b4b500b7c7a677b4b7c7a6b4b4b4b4b7c7a6b7c7a6b477b4b7c7a6b40000b7c7a6b4b4b7c7a6b4b4b7c7a6b4
77b4b7c7a6b4b4b4b4b7c7a6b7c7a6b4b4b497979797b7c7a6b4b7c7a6b4b7c7a6b4b4b7c7c7a6b4b7c7a6a6c6b4b7c7979797979797b7c7b7c7a6a6a6b4b4b7
c7a6a6b4b4b7c7979797979797b4b4b7c7a6979797979797c7a6b5b4b7c7a6b4b4b4b4979797979797a6b4b4b7c7a6b47700b7c7a6b4b4b7979797979797a6b4
b4b4b7c7a6b4b4b4c2b7c7c2b7c7c2b4c2b4b4b7c7a6b7c7a6c2b7c7a6c2b7c7a6c2b4b7c7c7a6b4b7c7a6b4c2b4b7c7a6c2b7c7a6c2b7c7b7c7a6b4b4b4a6b7
c7a6b4b4b4b7c7a6b4b7c7c7a6b4b4b7c7a6b4b4b7c7a6b7c7a6a3b4b7c7a6b5a3c6b4b7c7b7c7c7a6b4b4b4b7c7a6b4b477b7c7a6b4b4b7c7a6b7c7b7c7a6b4
b4b4b7c7a6b4b4b4a6b7c7a6b7c7a6a6a6b4b4b7c7a6b7c7a6a6b7c7a6a6b7c7a6a6b4b7c7c7a6b4b7c7a6b4a6b6b7c7a6a6b7c7a6a6b7c7b7c7a6b4b4b4a6b7
c7a6b4b4b4b7c7a6b4b7c7c7a6b4b4b7c7a6b4b4b7c7a6b7c7a6a6a6b7c7a6a6a6c6b4b7c7b7c7c7a6b4a6b4b7c7a6b4b4b4b7c7a6b4b4b7c7a6b7c7b7c7a6b4
97979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797
97979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797979797
__gff__
000000000000000000008080808080800000000000000000000080808080808000000000000000000000808080808080000000000000000000008080808080800000100010101010101010101f101000000010101010101010101f10101010000000101010101311111910101080000000001010101000100011101010000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404049494a4849484848474a474747
404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400a0c4040404040404040404540404040404040454040404040404040404040404040404040404540404040404040404040404040404040404040404040494a48494848474a47474747
404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400c40400a40404040404040404040404540404040524040404040404062404040404040404540404040404040404040424040404040404540404040404540404040404040404040494948494848484a474849
4040404040404040404240404040404040404040404040404040404040404040404045404040404040404040404040404040404040686868684040404042404000646245404040404040524040404040404042404040404045400c4040624040400c454042404045404062404040454040404540404048484848484849474848
404040404040404040624040404040404040404040404040404040404042404040404240404040404040400000406868686840404047474a406354636462535400405262404040404540625400454040406352404045404042454540406240454045424062404042404062454040424045405542404049484848494747474a47
404040404540636464624040404040404040400a400c40404040636464524040404262535440404040400000004240494747686768474a404240406768676840004062525354404555535240406545404540525440624045626568686868686868686242624045624063626245456240624555524040404848480b4748486a48
4040404042404000406254404040404040404040404040404240404040625440645262404040400a0c4000404052535449474748474a404062645354404947400000527300404065654074404552654552426240405240427365525549484a5255425252730e4252544552525542524552556573404040484a48484848474747
40404040625354006374404040404040406768676868404052544040635240404052524040404040404040404552404040474a4a484040407340404040624747540062525440406555635240556265656252744040624552625562654248456265526252624552624555626265526255746555524040404849484a5b4b5c4947
40406364524040004052534040404040404049484a406364624040404073534040746253406868686840404042625440404a4a494840406352404040635240474700727200404065654052546573656552626253405268686868686562476574656868686868625255557452557352555265656240404048484a5b5b4b5c5c49
404040407354400040724040404068686768404840404040625354404072404063525240404947474a406353627240406868686868684040525440404074404966686940404040657564624075627575726262404062757249474a75724875627549484a5265627355555252656252655265656240404048485b5b4b4b4b5c5c
404040407240400040400a40400a4048400a40484040404072400a40400a40400e72724040404847400e40407240403a40474a494a40404072404040406240406648486869404075404072404072402a407272404072402a40480c403a483a723a0c47407275726275756262555262656767676740404048485b4b5b405c4b5c
585957595959575759584d59574d5748584e594859594d574e584d59584d5759584e59595958474859584d59584d57595847474747594d57404040404052404066484848695959574e584d59584d5759584e594d59594e5959474d5958475759584e48594040407240407262757262755247477240404048485b4b4040404b5c
67686868676867676868686868676867676868676768676767686867676768676768686867686768676868686868686867686868676867694040404040524040664848484868676868676868676868686768686767686868686768676768686767686869595959574e580075404072407247474000000048485b4b4040404b5c
474a49484847474848474847474748474a4947484747484848474947474747494747474847474849484748474747474747474748474748694040402c40722c40664848484747484848474847474747474847474849484747484a494747474747474747486768676867695959584d57595847475858585848485b5b4040405c4b
4a4040484848484849484848474847474a4947484849484a4a4848484a4847474a49474848484847484a494a4747474747474747484848694040404040404040664848484848484848484848474848474847474a40494a4040404049474847474747474848484848484868674c4c68674c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c
4a4040494a40494a404049484a494a4040404947474a474a4049494a4a4848484a4049474a494747474847484748474847474747474747696868686868686868684848474747474747484848484a494848494a404040404040404040494848484747474747474c4c4748484c4c474747474c4c4c47474c4c4c4c4c4c4c4c4c4c
4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7a4b
4b7a4b4b5b4b5b4b5c4b4b5b4b4b4b5c4b7a4b4b4b4b4b4b5b4b4b4b5c4b4b4b4b5b4b4b4b5c4b6c5b4b4b4b5c4b7a4b4b7a5b4b4b4b5c4b5b4b4b4b5c4b4b5b4b4b4b5c4b4b4b4b5b4b4b4b5c4b4b5b4b4b5b4b4b4b5c4b4b4b4b5b4b4b4b5c4b5b4b4b5b4b4b4b5c4b5b4b4b4b5c4b4b4b4b5b4b4b4b5c4b4b5b4b5b4b4b4b
4b4b4b4b595859574b7a4b595859574b4b4b5b5b4b4b4b4b595859574b4b4b4b4b595859574b4b4b595859574b4b4b4b4b4b595859574b4b595859574b4b4b595859574b4b4b5b4b595859574b4b4b4b4b4b595859574b5b4b5b4b595859574b4b4b4b4b595859574b4b595859574b4b4b4b4b595859574b4b7a4b4b59585957
4b4b4b6b444444444b4b6b444444444b4b4b5b6a6c4b4b6b444444444b4b6c4b6b444444444b4b6b444444444b4b4b4b4b6b444444444b6b444444444b4b6b444444444b4b4b4b6b444444444b4b4b5b4b6b444444445c4b6c6c5b444444444b4b7a4b6b444444444b6b444444444b4b4b4b6b444444444b4b4b4b6b44444444
4b4b4b5b444444444b4b4b444444444b4b7a4b6c6c4b7a4b444444444b4b4b4b4b444444444b4b4b444444444b4b4b4b7a4b444444444b4b444444444b4b4b444444444b4b4b4b4b444444444b4b4b4b4b4b44444444405c5c5c40444444444b4b4b5b4b444444444b4b444444444b4b7a5b4b444444444b4b5b4b4b44444444
4b7a4b4b444444446c4b4b444444446c4b4b4b5b4b4b4b4b444444446c4b5b4b4b444444446c4b4b444444446c4b4b4b4b4b442a2a446c4b442a2a446c4b4b444444446c4b5c4b4b444444446c4b7a4b4b4b444444440a0a0a0a0a444444446c4b4b4b4b444444446c4b444444446c4b4b4b4b444444446c5b405c4b44444444
4b4b4b5b444444445c5b6b444444444b4b4b4b4b4b4b4b6b444444444b4b4b4b6b444444444b4b6b444444444b4b4b4b4b6b444040444b6b444040444b4b6b444444444b4b4b4b6b444444444b4b4b5c4b6b44444444406c6c6c40444444444b4b5c4b6b444444444b6b444444444b4b4b4b6b444444446b403b406b44444444
4b6c4b4b4b6b4b6c4b4b7a4b6b4b6c4b6668675a4c796879796779797979797967797967796a4b4b4b6b4b6c7979687979687979797968794c684c4c67797968796a4b4b4b4c674c5c5c4b79794c687979797979797979797979796a4b4b4b6b4b4b4b3e6c6b4b6c4b4b4b6b4b6c7a4b4b4b4b4b6b4b6c4b6b406c4b4b6b4b6c
4b4b4b4b5b5b4b4b7a4b4b4b4b4b4b5b5a5a5a5a5a6a6c4b6b6c6c4b6b6c4b4b7b7c0c4b4b4b6c4b4b4b6c4b4b4b4b4b4b4b4b4b4b4b4b4b5a5a5a5a6a4b4b4b4b4b4b4b5b5a5a5a6a5b4b5b0c5a5a6a6c4b6b4b6b6c4b6b7b7c6a5c4b4b4b4b5b5c4b6b6c4b4b4b4b5c4b4b7a4b4b4b4b7a5b4b4b4b4b4b4b6c4b4b4b4b4b4b
4b7a4b4b595859574b4b6a5c4b4b5b6a5a5a5a685a6a4b5b2c5b6b4b6c4b7a4b7b7c6a6c4b4b4b4b7a4b4b4b4b4b6c4b4b5c4b6c4b4b4b4b4c5a675a6a4b4b4b4b4b5b5b6a5a5a4c6a5c4b6b0c5a5a6a4b5b4b4b4b4b7a4b7b7c797979796a4b6b6c4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b
4b4b4b6b444444446c4b6c4b4b5b4c5a5a4c5a5a5a4c5a6a6c4b2c5c4b4b796879797967796a464b797967796a4b7a4b4b464b4b4b4b7a4b5a5a5a4c6a464b4b79796879795a4c5a6a464b79795a5a6a4b4b4b4b464b4b4b7b7c6a7b7c6a5c7a4b4b4b4b7a4b5b5c5b2e4b5b6a5c4b4b4b4b4b4b4b4b4b4b4b4b4b5b4b4b7a4b
5c4b6c4b444444444b464b4b5b6a5a5a4c5a685a5a5a5a4c5a6a5c4b2c5c5b4b7b7c5c4b4b4b564b4b7b7c6a4b5c5b4b5b564b5b4b4b5b4b4c675a4c6a564b4b4b4b4b4b4b5a674c6a564b5b0c5a4c6a5c4b4b5c564b5b4b7b7c6a7b7c797979796a4b464b5b2e6a6b6c464b2e6c4b464b4b4b4b464b4b4b4b464b4b4b464b4b
6a4b4b4b6b4b6b4b4b564b5b665a4c5a5a685a5a5a4c5a685a4c5a6a6c4b2c5c7b7c0c4b4b7a564b4b7b7c6a2c4b0c4b2c560c4b2c4b0c4b6a7b7c0e6c564b7a4b4b5c4b5b5a4c4c6a564b79795a4c6a3a4b4b3a564b3a5c7b7c6a7b7c6a7b7c6a4b4b564b4b6c4b4b4b564b4b5c4b564b5b4b4b564b5b4b4b564b4b4b564b4b
6a5c5b5c5c5c4b4b6c565b6a5a5a5a5a5a5a5a4c5a4c5a5a5a5a5a685a6a5c4b7b7c6a5c4b4b564b5b7b7c6a6b4b6c4b6c566b4b6c4b6a5c4b7b7c6a4b564b4b4b4b4b5b6a5a4c5a6a564b4b4b5a5a6a4b4b4b4b564b4b4b7b7c6a7b7c6a7b7c6a5c4b564b4b5c5b4b4b564b4b5b4b564b4b7a4b564b4b4b4b564b5b4b564b4b
6a6a6a6a6a6a5c4b5b56664c5a685a4c5a000000685a5a4c5a685a5a5a5a5a5a5a5a5a5a5a6767675a5a5a5a4c67685a6768675a684c4c4c5a5a5a5a6768675a5a5a684c4c4c4c4c6867685a5a5a5a5a5a5a5a6768685a5a5a5a5a5a5a5a5a5a5a5a6767685a5c4b4b4b564b4b4b4b564b4b4b4b564b4b4b4b564b4b4b564b4b
4c4c4c4c5a675a676768684c5a5a5a5a00000000005a5a005a5a5a000000005a5a5a5a5a5a675a675a5a5a5a5a5a5a5a5a675a5a5a5a000000005a5a68685a5a5a000000005a5a5a5a5a685a5a5a5a5a5a5a5a67675a5a5a5a5a5a5a5a5a5a5a5a5a5a5a675a5a5a5a6768676767686767676767676767676868686768686767
__sfx__
00020000110501a0500b0500f050170501b0500e0501a0500d0501e0401a0400e0401e0301b0300a020140200c0200e0200a01000000000000000000000000000000000000000000000000000000000000000000
000200001c0500f0501c050100501b050190501805009050180501d0400f0401a0400e030190300b0201b0200d0200e0200a01000000000000000000000000000000000000000000000000000000000000000000
00020000085700c57010570115701257013570115700f5700d5700a57009570065700556003550015500153001520015000d50000500005000050000500005000050000500005000050000500005000050000500
00010000342400b240312400a2402f2400a2402a2400724023240062401524005240032400d2300c220042200b2100a2100421005210072000420003200022000120009200002000020000200002000020000200
00010000141410f1411314108141101410914111141131311012110111091110911114131101311013109131111310d1310b131101310d131061210d111061110111109101001010010100101001010010100101
00010000131410b1410f141061410f141131410a14116131081211611104111181110b1311513111131061310f1310e131071310a131091310212108111041110111109101001010010100101001010010100101
00020000184311d4411e4411e4411c44119441144410f4410b4410544102431014310143101421014210141101401014010140101401014010d40107401074010340107401054010540100401004010040100401
000200001a3520f3521d352113521f35211352203521235224352133522635210352253520e35220352083521f352073521b352063521835204342163420434215342033320f3320232206312003020030200302
00010000083400f3400a3400f340093400d340093400d340073400a34005340083300333006330043200132001310013000d30000300003000030000300003000030000300003000030000300003000030000300
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000095650b5620c5620b5650c5620e5620c5650e562105620e562105651156211562105650e5620c562105620e5650c5620b5620e5620c5650b562095620c5620b56509562085620956509562085620b562
011000002872028700287202d70028720287202d7202c720287200070028720007002c7202d7200070000700287200070028720007002d7202c72029720287202672028720007000070026720287202972028720
01100000287222872228702287222c72228722287022b702287222872228702287222d722287222c72200702287222872228702287222f722287222b702287022872228722007022872226722287222972228722
01100000287252972528725007002c7252d7252c725007002f725307252f72500700347253572534725007002c7252d7252c725007002f725307252f725007003472535725347250070038725397253872500700
01100000105651156214562115651456215562145651556217562155621756518562185621756515562145621756215565145621156215562145651156210562145621056511562105620e56210562105620e562
0110000028735287352c735297352c70529735297352d7352c735307052c7352c735307352f73534705007002c7352c735307352f735307052f7352f73532735307352f705307353073535735347353870500700
01100000387343573534735327353473134735327353473134731347313472134711307052f705347050070035734347353273530735327313273532735347313473129735287352c7352d735287052d7352d735
0110000018325183251a3251c3251d3251c3251a325183251a3251a3251c3251d325203251d3251c3251a3251c3251c3251d3252032521325203251d3251c325213252132523325243252432523325213251c325
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c0531c0531c6331c0531c0531c6031c0531c0531c6331c0531c0531c6031c0531c0531c633000001c0531c0531c6331c0531c0531c6031c0531c0531c6331c0531c0531c6031c0531c0531c6331c633
011000001c0531c0531c6331c0531c0031c0531c0531c0031c6331c0531c0531c6031c0531c0531c633000001c0531c0531c6331c0531c0031c0531c0531c0031c6331c0531c0531c6031c0531c0531c6331c633
011000001c0531c0531c6331c0531c6331c6331c0531c0531c6331c0531c6331c6331c0531c0531c633000001c0531c6331c0531c6331c0031c6331c0531c0531c6331c0531c6331c6331c0531c0531c63300000
011000001c0031c0031c6031c0031c0031c6031c0031c0031c6031c0031c0031c6031c0031c0031c603000001c0031c0031c6031c0031c0031c6031c0031c0031c0531c0531c0531c0531c6331c6331c6331c633
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c1451c145204211c1451c145214211d1451d145234211c1451c14524421201452014526421264011c1451c145234211c1451c145244211d1451d145264211c1451c1452842123145231452942121105
011000002d1452d145244212d1452d145264212f1452f145284212d1452d1452c42130145301452d421211052d1452d145344212d1452d145354212f1452f145384212d1452d1453b42139145371453c42134105
011000001c5421c502205221c5421c502215221d5421d502235221c5421c50224522205422050226522265021c5421c502235221c5421c502245221d5421d502265221c5421c5022852223542235022952221502
011000002d5422d502245222d5422d502265222f5422f502285222d5422d5022c52230542305022d522215022d5422d502345222d5422d502355222f5422f502385222d5422d5023b52239542375023c52234502
011000002824228122282222974228122281222b74228122282222d34228522281222b7422812228522292222834228722281222b54228122287222d2422812228522293422822228722282422b1222852228322
011000002114221322217222414221422235222134221222247222144221122232222114221522213222412221442211222352221742213222422221542214222172224442211222112223542212222132221422
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001033411334103341133410334113341033411334143341533414334153341433415334143341533417334183341733418334173341833417334183341433415334143341533414334153341433411334
011800001032300300003001032313623003000030010323103231030300300103231362313623003001032310323003000030010323136230030000300103231032313623003001032313623003001032313623
01180000045440454204532045320452204522045120451208541085420853208532085220852208512085120b5410b5420b5320b5320b5220b5220b5120b5120854108542085320853208522085220851208512
0118000017334183341733418334173341833417334183341c3341d3341c3341d3341c3341d3341c3341d33420334213342033421334203342133420334213342333424334233342433423334243342333424334
011800000b5440b5420b5320b5320b5220b5220b5120b512105411054210532105321052210522105121051214541145421453214532145221452214512145121754117542175321753217522175221751217512
011800002033421334203342133420334213342033421334233342433423334243342333424334233342433428334293342833429334283342933428334293342f334303342f334303342f334303342f33430334
011800002054420542205322053220522205222051220512235412354223532235322352223522235122351228541285422853228532285222852228512285122f5412f5422f5322f5322f5222f5222f5122f512
011800001033411334103341133414334153341433415334173341833417334183341c3341d3341c3341d3341c3341d3341c3341d334203342133420334213342333424334233342433428334293342833429334
0118000004544045420453204532085410854208532085320b5410b5420b5320b532105411054210532105321054410542105321053214541145421453214532175411754217532175321c5411c5421c5321c532
011000001013310133136331013310133136331013310133136331013310133136331013310633131332110310133101331363310133101331363310133101331363310133101331063313133136331313310633
011000001c1451c145101051c1451c145201051d1451d1451c1051c1451c14520105201452110521145211051c1451c145101051c1451c145201051d1451d1451c1051c1451c1452010523145241052414521105
011000002d1452d145101052d1452d145201052f1452f1451c1052d1452d14520105301452110532145211052d1452d145101052d1452d145201052f1452f1451c1052d1452d1452010539145371453514534145
0110000004142081420b14204142081420b14204142081420b14204142081420b14204142081420b1420b14210142141421714210142141421714210142141421714210142141421714210142141421714217142
01100000091420c14210142091420c14210142091420c14210142091420c14210142091420c142101421014215142181421c14215142181421c14215142181421c14215142181421c14215142181421c1421c142
__music__
01 0b 21 43 44
01 0b 0c 1e 44
00 0b 0d 1e 44
00 0b 0e 1f 44
01 0b 0c 1e 44
00 0b 0d 1e 44
00 0b 0e 20 44
00 0f 1f 10 44
00 0f 1f 11 44
02 0f 1f 12 44
01 39 3a 43 44
01 32 33 34 44
00 32 33 34 44
00 35 33 36 44
00 32 33 34 44
00 32 33 34 44
00 35 33 36 44
02 37 33 38 44
00 41 42 43 44
00 41 42 43 44
01 3b 3e 3c 44
00 3b 3f 3d 44
00 3b 3e 3c 44
00 3b 3f 3d 44
01 3b 3e 3c 44
00 3b 3f 3d 44
00 3b 3e 28 44
00 3b 3f 29 44
00 3b 3e 2a 44
00 3b 3f 2b 44
00 3b 3e 2c 44
00 3b 3f 2d 44
00 3b 3e 2c 44
02 3b 3f 2d 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 32 33 34 44
00 32 33 34 44
00 35 33 36 44
