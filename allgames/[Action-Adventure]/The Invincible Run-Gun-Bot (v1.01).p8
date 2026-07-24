pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--run-gun-bot
--by guerragames

one_frame,epsilon,max_air_time=.0166667,.001,6000

-- 64x64 screen mode
poke(0x5f2c,3)

--
cartdata("rungunbot")

--
function load_game()
 player_checkpoint_x,player_checkpoint_y,game_time,player_score,player_hits,mirror_mode,gun_types_flags=dget(0),dget(1),dget(2),dget(3),dget(4),dget(5),dget(6)

 if(player_checkpoint_x==0)player_checkpoint_x=16
 if(gun_types_flags==0)gun_types_flags=1

 for i=1,8 do
  pickup_save_masks[i]=dget(50+i)
 end
 
 mirror_mode_bool=mirror_mode==1
 
 if mirror_mode_bool then
  for i=0,127 do
   for j=0,31 do
    poke(0x6000+i+j*128,mget(127-i,j))
    poke(0x7000+i+j*128,mget(127-i,j+32))
   end
  end
  memcpy(0x2000,0x6000,0x1000)
  memcpy(0x1000,0x7000,0x1000)
 end
end

--
function save_game()
 dset(0,player_checkpoint_x)
 dset(1,player_checkpoint_y)
 dset(2,game_time)
 dset(3,player_score)
 dset(4,player_hits)
 dset(5,mirror_mode)

 dset(6,gun_types_flags)
 
 for i=1,8 do
  dset(50+i,pickup_save_masks[i])
 end

 show_hud_timer=3
end

--
function new_game()
 player_checkpoint_x,player_checkpoint_y,game_time,player_score,player_hits,gun_types_flags=16,0,0,0,0,1

 for i=1,8 do
  pickup_save_masks[i]=0
 end
 
 save_game()
 run()
end

--
function reset_game()
 mirror_mode=0
 new_game()
end

--
function reset_game_mirrored()
 mirror_mode=1
 new_game()
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
function unpack(y,i)
 i=i or 1
 local g=y[i]
 if(g)return g,unpack(y,i+1)
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
cam_shake_x,cam_shake_y,cam_shake_damp=0,0,0
screen_flash_timer,screen_flash_color=0,7

--
function screenflash(duration,color)
 screen_flash_timer,screen_flash_color=duration,color
end

--
function screenshake(max_radius,damp,cor)
 local a=rnd()
 cam_shake_x,cam_shake_y=max_radius*cos(a),max_radius*sin(a)
 cam_shake_damp,cam_shake_corruption=damp,cor
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
function screenshake_corruption_draw()
 if cam_shake_corruption then
  if abs(cam_shake_x)<1 and abs(cam_shake_y)<1 then
  else
   for i=0,20 do
    local m1=0x6000+rnd(0x2000-128)
    local m2=m1+rnd(64)
    memcpy(m1,m2,rnd(64))
   end
  end
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
 local hours,mins,secs=flr(time/3600),flr(time/60%60),flr(time%60)
 if(hours<0 or hours>9)return "8:59:59"
 local txt=hours>0 and hours..":" or ""
 txt=txt..((mins>=10 or hours==0) and mins or "0"..mins)
 txt=txt..(secs<10 and ":0"..secs or ":"..secs)
 return txt
end

--
function create_button(btn_num)
 return 
 {
  time_since_press=100,
  last_time_held=0,
  time_held=0,
  time_released=0,
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
    if(b.time_held!=0)b.time_released=0
    b.last_time_held=b.time_held
    b.time_held=0
    b.time_released+=one_frame
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
 
--
function map_coords(x,y)
 return flr(round(x)/8),flr(round(y)/8)
end

--
function set_tile_if(x,y,ov,nv)
 local mx,my=map_coords(x,y)
 if mget(mx,my)==ov then
   if ov==87 then
    if(flr(x/64)!=flr(player_x/64) or flr(y/64)!=flr(player_y/64))return false
    
    game_finished,game_finished_timer=true,0
    save_game()
   end
   
   mset(mx,my,nv)
   return true
 end
 
 return false
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
   local i_vx=(vel_mag>=1) and nvx or vel_mag*nvx 
   local i_vy=(vel_mag>=1) and nvy or vel_mag*nvy
        
    if not on_floor and not on_ceiling then
     if i_vy>0 then
      if s_floor(new_x+ws+1,new_y+he+1) and not s_ceil(new_x+ws+1,new_y+he-1) or 
         s_floor(new_x+we-1,new_y+he+1) and not s_ceil(new_x+we-1,new_y+he-1) then
       on_floor=true
       temp_y=round(temp_y)
       nvy,i_vy=0,0
      end
     else
      if s_ceil(new_x+ws+1,new_y+hs-1) and not s_floor(new_x+ws+1,new_y+hs+1) or
         s_ceil(new_x+we-1,new_y+hs-1) and not s_floor(new_x+we-1,new_y+hs+1) then
       on_ceiling=true
       temp_y=round(temp_y)
       nvy,i_vy=0,0
      end
     end
    end
    
    if not on_rwall and not on_lwall then
     if i_vx > 0 then
      if s_rwall(new_x+we+1,new_y+hs+1) and not s_lwall(new_x+we-1,new_y+hs+1) or
         s_rwall(new_x+we+1,new_y+he-1) and not s_lwall(new_x+we-1,new_y+he-1) then
       on_rwall=true
       temp_x=round(temp_x)
       nvx,i_vx=0,0
      end
     else
      if s_lwall(new_x+ws-1,new_y+hs+1) and not s_rwall(new_x+ws+1,new_y+hs+1) or
         s_lwall(new_x+ws-1,new_y+he-1) and not s_rwall(new_x+ws+1,new_y+he-1) then
       on_lwall=true
       temp_x=round(temp_x)
       nvx,i_vx=0,0
      end
     end
    end

    if abs(i_vy)>epsilon and abs(i_vx)>epsilon and not on_floor and not on_ceiling and not on_lwall and not on_rwall then
    if not on_floor and not on_ceiling then
     if i_vy > 0 then
      if s_floor(new_x+ws-1,new_y+he+1) and not s_ceil(new_x+ws+1,new_y+he-1) or 
         s_floor(new_x+we+1,new_y+he+1) and not s_ceil(new_x+we-1,new_y+he-1) then
       on_floor=true
       temp_y=round(temp_y)
       nvy,i_vy=0,0
      end
     else
      if s_ceil(new_x+ws-1,new_y+hs-1) and not s_floor(new_x+ws+1,new_y+hs+1) or
         s_ceil(new_x+we+1,new_y+hs-1) and not s_floor(new_x+we-1,new_y+hs+1) then
       on_ceiling=true
       temp_y=round(temp_y)
       nvy,i_vy=0,0
      end
     end
    end
    
    if not on_floor and not on_ceiling and not on_rwall and not on_lwall then
     if i_vx > 0 then
      if s_rwall(new_x+we+1,new_y+hs-1) and not s_lwall(new_x+we-1,new_y+hs+1) or
         s_rwall(new_x+we+1,new_y+he+1) and not s_lwall(new_x+we-1,new_y+he-1) then
       on_rwall=true
       temp_x=round(temp_x)
       nvx,i_vx=0,0
      end
     else
      if s_lwall(new_x+ws-1,new_y+hs-1) and not s_rwall(new_x+ws+1,new_y+hs+1) or
         s_lwall(new_x+ws-1,new_y+he+1) and not s_rwall(new_x+ws+1,new_y+he-1) then
       on_lwall=true
       temp_x=round(temp_x)
       nvx,i_vx=0,0
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
   new_y=round(new_y/8)*8
  end
 
  if on_rwall or on_lwall then
   new_x=round(new_x)
  end
 end
 
 return {x=new_x,y=new_y,floor=on_floor,lwall=on_lwall,rwall=on_rwall,ceil=on_ceiling}
end

-- camera
cam_res=64

--
function cam_reset()
 local mpx,mpy=flr(player_x/cam_res)*cam_res,flr(player_y/cam_res)*cam_res
 cam_x,cam_y,target_cam_x,target_cam_y=mpx,mpy,mpx,mpy
 enemies_spawn_check()
end

--
function cam_update()
 local pcx,pcy=player_x+4,player_y+4
 
 if pcx>target_cam_x+cam_res then
  target_cam_x+=cam_res
  enemies_spawn_check()
 elseif pcx<target_cam_x then
  target_cam_x-=cam_res
  enemies_spawn_check()
 end
 
 if pcy>target_cam_y+cam_res then
  target_cam_y+=cam_res
  enemies_spawn_check()
 elseif pcy>0 and pcy<target_cam_y then
  target_cam_y-=cam_res
  enemies_spawn_check()
 end

 if abs(cam_x-target_cam_x)>1 then
  cam_x+=.15*(target_cam_x-cam_x)
 else
  cam_x=target_cam_x
 end
 if abs(cam_y-target_cam_y)>1 then
  cam_y+=.15*(target_cam_y-cam_y)
 else
  cam_y=target_cam_y
 end
end

-- part
parts={}
parts_next,parts_blink=1,0

for i=0,400 do
 add(parts,{t=0})
end

parts_flags_floor_bounce,parts_flags_blink,parts_flags_no_outline=0x01,0x02,0x04

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
   
   if band(p.f,parts_flags_blink)==parts_flags_blink then
    if parts_blink%.2>.1 then 
     p.c,p.bc=p.bc,p.c
    end
   end
   
   if band(p.f,parts_flags_floor_bounce)==parts_flags_floor_bounce and s_floor(p.x,p.y+p.s) then
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

-- pbullets
pbullets={}
pbullets_next,pbullets_active_count=1,0

for i=0,50 do
 add(pbullets,{active=false})
end

--
function pbullets_spawn(x,y,vnx,vny)
 local pb,i=find_next_i(pbullets,pbullets_next,pbullets_active_count)
 
 if pb then
  pbullets_next=i
  
  pbullets_active_count+=1
  pb.active=true
  
  local gt=gun_types[player_current_gun]
  pb.t,pb.x,pb.y,pb.vx,pb.vy=gt.maxt,x,y,gt.speed*vnx,gt.speed*vny
  pb.gt=gt
  pb.g=gt.g
  
  sfx(player_current_gun)
 end
end

--
function pbullets_crash(pb)
 pb.active=false
 pbullets_active_count-=1
 
 for i=1,20 do
  local a,r=rnd(),.5+rnd(2)
  local vx,vy=r*cos(a),r*sin(a)
  parts_spawn(2*pb.gt.pt,pb.x+1-rnd(2),pb.y+1-rnd(2),vx,vy,0,.9,rnd(pb.gt.size+1),-.2,7,pb.gt.color)
 end
end

--
function pbullets_update()
 for k,pb in pairs(pbullets) do
  if pb.active then
   pb.t-=one_frame
   
   local pbgt=pb.gt
   
   if pb.t<0 then
    if band(pbgt.f,gt_flag_timeout_explode)!=0 then
     pbullets_crash(pb)
    else
     pb.active=false
     pbullets_active_count-=1
    end
   end
   
   pb.vy+=pb.g
   
   local check_collision=(band(pbgt.f,gt_flag_no_collision)==0)
   
   local replace_tile=pbgt.rtile or 64
   local destroy_tile=pbgt.dtile
   
   local pb_cr=nil
   if check_collision then
    pb_cr=collision_checks(pb.x,pb.y,pb.vx,pb.vy,0,0,1,1)
    pb.x,pb.y=pb_cr.x,pb_cr.y
   else
    pb.x+=pb.vx
    pb.y+=pb.vy
    if(set_tile_if(pb.x,pb.y,destroy_tile,replace_tile))pbullets_crash(pb)
   end
   
   local pbx,pby=pb.x,pb.y
   
   if check_collision and pb_cr and (pb_cr.floor or pb_cr.ceil or pb_cr.lwall or pb_cr.rwall) then
    local destroyed_tile=false
    if destroy_tile then
     if(pb_cr.floor)destroyed_tile=set_tile_if(pbx,pby+1,destroy_tile,replace_tile)
     if(pb_cr.ceil)destroyed_tile=set_tile_if(pbx,pby-1,destroy_tile,replace_tile)
     if(pb_cr.rwall)destroyed_tile=set_tile_if(pbx+1,pby,destroy_tile,replace_tile)
     if(pb_cr.lwall)destroyed_tile=set_tile_if(pbx-1,pby,destroy_tile,replace_tile)
    end
    
    if not destroyed_tile and band(pbgt.f,gt_flag_bounce)!=0 then
     if (pb_cr.floor or pb_cr.ceil)pb.vy*=-.6
     if (pb_cr.lwall or pb_cr.rwall)pb.vx*=-.6
     if (abs(pb.vy)<1)pb.vy=pb_cr.floor and -1 or 1
    else
     pbullets_crash(pb)
    end
   else
    local pb_size=pbgt.size
    
    parts_spawn(pbgt.pt,pbx,pby+1-rnd(2),0,0,pbgt.pg,1,1+rnd(pb_size),pbgt.pds,7,pbgt.color)
    
     -- check for bubblegum gun
    if pbgt.color==14 then
     if pb.t<=pbgt.maxt-.5 then
      if pbx+pb_size<player_x or
         pbx-pb_size>player_x+8 or
         pby+pb_size<player_y or
         pby-pb_size>player_y+8 then
      else
       player_vy=-3
       pbullets_crash(pb)
      end
     end
      
     for k,eb in pairs(ebs)do
      if eb.active then
       local s=eb.s/2
       if pbx+pb_size<eb.x-s or
          pbx-pb_size>eb.x+s or
          pby+pb_size<eb.y-s or
          pby-pb_size>eb.y+s then
       else
        eb.active=false
       end
      end
     end
    end
    
    for k,e in pairs(enemies) do
     if e.active then
      if pbx+pb_size<e.x or
         pbx-pb_size>e.x+8 or
         pby+pb_size<e.y or
         pby-pb_size>e.y+8 then
      else
       enemy_damage(e,pbgt.damage)
       
       pbullets_crash(pb)
      end
     end
    end
   end
  end
 end
end

-- player
player_anim_idle=nl("0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2")
player_anim_run=nl("16,16,16,16,17,17,17,17,18,18,18,18")
player_anim_run_up=nl("48,48,48,48,49,49,49,49,50,50,50,50")
player_anim_run_down=nl("32,32,32,32,33,33,33,33,34,34,34,34")
player_anim_shoot={3}
player_anim_shoot_up={35}
player_anim_shoot_down={19}
player_anim_launch,player_anim_jump,player_anim_fall,player_anim_land={51},{52},{53},{51}

player_anim_crouch_idle={54}

player_jump_state_none,
player_jump_state_launch,
player_jump_state_arc,
player_jump_state_fall,
player_jump_state_land=0,1,2,3,4

--
gt_flag_bounce,gt_flag_timeout_explode,gt_flag_no_collision=0x01,0x02,0x04

--
function make_gun(c,s,d,sp,r,mt,grav,ra,pgrav,ptime,pdspeed,dt,rt,flags)
 return {color=c,size=s,damage=d,speed=sp,rate=r,maxt=mt,g=grav,rnda=ra,pg=pgrav,pt=ptime,pds=pdspeed,dtile=dt,rtile=rt,f=flags}
end

-- 
gun_types={
 -- none: vanilla gun (light gray)
 make_gun(unpack(nl("6,1,1,3,.2,1,0,0,0,.1,-.2,-1,-1,0,"))),
 
 -- granade launcher: bounces around, destroys ground blocks (dark green)
 make_gun(unpack(nl("3,3,3,2,.5,1,.1,0,0,.3,-.2,116,-1,3,"))),
 
 -- grapple: launch player in facing direction (brown)
 make_gun(unpack(nl("4,1,.25,3,.1,1,0,0,0,.1,-.01,-1,-1,0,"))),
 
 -- rocket launcher: allows for "double" jump by shooting down, destroys brick blocks (red)
 make_gun(unpack(nl("8,5,3,2,.8,1,0,0,0,.5,-.2,120,-1,0,"))),
 
 -- flame thrower: burns brambles, hovers, short, powerful range (orange) 
 make_gun(unpack(nl("9,4,1,1,.1,.4,0,.04,0,.4,-.2,115,-1,4,"))),
 
 -- freeze gun: (blue), freezes red hot lava blocks
 make_gun(unpack(nl("12,1,1,3,.2,.5,.2,0,.01,.8,-.02,89,88,4,"))),
  
 -- bubble gum: bounce up on projectile
 make_gun(unpack(nl("14,7,3,.4,1.4,3,0,0,0,.2,-.2,-1,-1,0,"))),
 
 -- green goo power
 make_gun(unpack(nl("11,5,3,3,.2,1,0,0,0,.6,-.1,87,-1,4,"))),

}

--
function player_set_anim(anim)
 player_pre_anim=anim
end

-- 
function player_set_running_anim()
 player_set_anim(btn(2) and player_anim_run_up or btn(3) and player_anim_run_down or player_anim_run)
end

--
function player_commit_anim()
 if player_anim!=player_pre_anim then
  player_anim,player_anim_time,player_anim_next=player_pre_anim,0,1
 end
end

--
function player_reset()
 player_x,player_y=player_checkpoint_x,player_checkpoint_y

 player_cx,player_max_vx=0,1
 
 player_vx,player_vy,player_shoot_nx,player_shoot_ny,player_shoot_ox,player_shoot_oy=0,0,0,0,0,0
 player_gravity=.2
 
 player_current_gun,player_crouched_timer,player_grapple_t=1,0,0
 
 player_cr=nil
 
 player_shooting_cooldown,played_damaged,player_gun_disabled=0,0,0
 
 player_air_time=max_air_time
 player_anim_flip=player_x%64>32
 player_set_anim(player_anim_idle)
 player_commit_anim()
 
 player_jump_state=player_jump_state_none
 player_jump_state_timer=10
 
end

--
function player_damage()
 if played_damaged<=0 then
  sfx(11)
  
  player_hits+=1
  played_damaged,player_gun_disabled=1,2
  
  screenshake(6,.8,true)
  screenflash(.05,8)

  player_vx=player_anim_flip and 3 or -3
 end
end

--
function pickup_check(pu,spr,mask)
 if(pu.spr==spr)gun_types_flags=bor(gun_types_flags,mask)save_game()
end

-- 
function pickup_grab_fx(x,y,size)
 for i=1,10 do
  parts_spawn(.4,x,y,cos(i*.1),sin(i*.1),0,.95,size,-.05,7,10)
 end
end

--
function player_pickup_update()
 if(level_boss_arena)return
 
 for k,pu in pairs(pickups) do
  if pu.active then
   local x,y=pu.x,pu.y
   if x+6<player_x or
      x+2>player_x+8 or
      y+6<player_y or
      y+2>player_y+8 then
   else
    pickups_active_count-=1
    pu.active=false
    
    pickup_check(pu,4, 0x2)
    pickup_check(pu,21,0x4)
    pickup_check(pu,5, 0x8)
    pickup_check(pu,6, 0x10)
    pickup_check(pu,20,0x20)
    pickup_check(pu,22,0x40)
    pickup_check(pu,55,0x80)
    
    if pu.type==pickup_type_coin then
     sfx(9)
     pickup_map_save(x,y)set_tile_if(x,y,7,23)
    else
     sfx(15)
    end
    
    pickup_grab_fx(x+4,y+4,pu.type==pickup_type_coin and 2 or 3)
   end
  end
 end
end

-- 
function player_landp(ox,a)
 parts_spawn(.2,player_x+ox,player_y+8,2*cos(a),2*sin(a),.1,.9,1,0,6,6,parts_flags_no_outline)
end

--
function player_land_particles()
 player_landp(2,.417)
 player_landp(4,.333)
 player_landp(4,.167)
 player_landp(6,.083) 
end

--
function player_dampen_vx()
 player_vx*=.8
 if(abs(player_vx)<epsilon)player_vx=0
end

--
function player_update_shooting()
 if player_grapple_t<=0 then 
  player_max_vx=1 
 else
  player_grapple_t-=one_frame
 end
 
 -- shooting
 player_shoot_nx=btn(0) and -1 or btn(1) and 1 or 0
 player_shoot_ny=btn(2) and -1 or btn(3) and 1 or 0
   
 if player_shoot_nx==0 and player_shoot_ny==0 then
  player_shoot_nx=player_anim_flip and -1 or 1
 end
   
 player_shoot_nx,player_shoot_y=normalize(player_shoot_nx,player_shoot_ny)
 local ox=player_anim_flip and 0 or 1
 player_shoot_ox,player_shoot_oy=ox+5*player_shoot_nx,flr(5*player_shoot_ny)
 player_shoot_ox=player_shoot_ox>0 and -flr(-player_shoot_ox) or flr(player_shoot_ox)
 
 local gt=gun_types[player_current_gun]
 
 if shoot_button.time_released<.2 
    and shoot_button.last_time_held>.2
    then
  if gt.color==4 and player_grapple_t<=0 and (btn(0) or btn(1)) then -- grapple
   player_vy,player_grapple_t,player_max_vx,player_gravity=.1,.1,10,0
   player_vx=player_anim_flip and -player_max_vx or player_max_vx
  end
 else
  player_gravity=.2
 end
 
 if shoot_button.time_held>0 then
  
  if gt.color==9 then -- flame thrower
   if(player_air_time>.1)player_vy=.1 player_max_vx=.25
  end
  
  if player_shooting_cooldown<=0 then
   player_shooting_cooldown=gt.rate
   
   if player_gun_disabled>0 then
    -- no shooting while getting damaged (punishment for getting hit)
    sfx(0)
    
    local a=atan2(player_shoot_nx,player_shoot_ny)
    for i=0,4 do
     parts_spawn(.1,player_x+3+player_shoot_ox,player_y+4+player_shoot_oy,2*cos(a+i/8-.25),2*sin(a+i/8-.25),unpack(nl("0,.95,2,-.2,5,13,")))
    end
   else
    if gt.rnda>0 then
     local a=atan2(player_shoot_nx,player_shoot_ny)
     a+=rnd(2*gt.rnda)-gt.rnda
     player_shoot_nx,player_shoot_ny=cos(a),sin(a)
    end
   
    local pox=player_shoot_ox>0 and -flr(-player_shoot_ox/2) or flr(player_shoot_ox/2)
    pbullets_spawn(player_x+3+pox,player_y+4+flr(player_shoot_oy/2),player_shoot_nx,player_shoot_ny)
   
    if gt.color==8 then -- rocket launcher
     if(player_air_time>.1)player_vy=-2.5
    end
   end
  end
 end 
end

--
function player_select_next_gun()
 repeat
  player_current_gun+=1
  if(player_current_gun>#gun_types)player_current_gun=1
 
  gt_mask=shl(0x1,player_current_gun-1)
 
 until band(gun_types_flags,gt_mask)!=0
end

--
function player_select_prev_gun()
 repeat
  player_current_gun-=1
  if(player_current_gun<1)player_current_gun=#gun_types
  
  gt_mask=shl(0x1,player_current_gun-1)
 
 until band(gun_types_flags,gt_mask)!=0
end

--
function player_update()
 if player_crouched_timer>.2 then
  if btnp(1) then
   player_select_next_gun()
  end
  if btnp(0) then
   player_select_prev_gun()
  end 
 end

 if(player_shooting_cooldown>0)player_shooting_cooldown-=one_frame
 if(played_damaged>0)played_damaged-=one_frame
 if(player_gun_disabled>0)player_gun_disabled-=one_frame

 player_cr=collision_checks(player_x,player_y,player_vx,player_vy,1,6,1,8)
 player_x,player_y=player_cr.x,player_cr.y
 
 player_x,player_y=mid(0,player_x,1016),min(player_y,504) -- 8*128-8,4*128-8
 
 if level_boss_arena or game_finished then
  if(player_x<target_cam_x)player_x=target_cam_x
  if(player_x>target_cam_x+56)player_x=target_cam_x+56
  if(player_y<target_cam_y)player_y=target_cam_y
  if(player_y>target_cam_y+56)player_y=target_cam_y+56
 end

 -- checkpoint checks 
 local mx,my=map_coords(player_x+4,player_y+6)
 if mget(mx,my)==56 then
  local omx,omy=map_coords(player_checkpoint_x,player_checkpoint_y)
  if(mget(omx,omy)==57)mset(omx,omy,56)
  
  mset(mx,my,57)
  player_checkpoint_x,player_checkpoint_y=mx*8,my*8
  save_game()
  sfx(16)
  
  pickup_grab_fx(player_checkpoint_x+4,player_checkpoint_y+6,2)
 end
 
 player_anim_next=next_i(player_anim,player_anim_next)
 player_anim_time+=one_frame
 
 if btn(3) and 
    abs(player_vx)<.1 and 
    shoot_button.time_held<=0 and
    player_air_time<.1 then
  player_crouched_timer+=one_frame
 else
  player_crouched_timer=0
 end

 
 if btn(0) and player_grapple_t<=0 then
  player_cx=-1
  
  if player_crouched_timer>.2 or shoot_button.time_held>.2 and player_air_time<.1 then
   player_dampen_vx()
  else
   player_vx=max(-player_max_vx,player_vx-.2)
  end
 elseif btn(1) and player_grapple_t<=0 then
  player_cx=1
  
  if player_crouched_timer>.2 or shoot_button.time_held>.2 and player_air_time<.1 then
   player_dampen_vx()
  else
   player_vx=min(player_max_vx,player_vx+.2)
  end
 else
  player_cx=0
  player_dampen_vx()
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
  
  player_vy,player_air_time=0,0
 end

 player_pickup_update()
 
 player_update_shooting()
 
 player_jump_state_timer+=one_frame
 if player_jump_state==player_jump_state_none then
  if player_air_time>.1 then
   player_jump_state=player_jump_state_fall
   player_jump_state_timer=0
  end
  
  if player_air_time<.05 and jump_button.time_since_press<.2 then
   sfx(12)
   jump_button:button_consume()
   player_air_time=max_air_time
   player_vy=0
   player_jump_state=player_jump_state_launch
   player_jump_state_timer=0
  end
 elseif player_jump_state==player_jump_state_launch then
  player_vy=0
  if player_jump_state_timer>.05 then
   -- finished launching
   if(player_vy>-1.5)player_vy=-1.5
   player_gravity=0   
   player_jump_state=player_jump_state_arc
   player_jump_state_timer=0
  end
 elseif player_jump_state==player_jump_state_arc then
  if btn(5) and player_jump_state_timer<.1 then
   if(player_vy>-1.5)player_vy=-1.5
   player_gravity=0
  else
   player_gravity=.2
   
   if player_vy>=0 then
    player_jump_state=player_jump_state_fall
    player_jump_state_timer=0
   end
  end
 elseif player_jump_state==player_jump_state_fall then
   if player_cr.floor then
    sfx(10)
    player_jump_state=player_jump_state_land
    player_jump_state_timer=0
   end
 elseif player_jump_state==player_jump_state_land then
  if player_jump_state_timer<.05 then
   player_vy=0
  else
   player_jump_state=player_jump_state_none
   player_jump_state_timer=0
  end
 end
  
 -- anim flip state
 if player_crouched_timer<.2 and player_cx<0 then
  player_anim_flip=true
  player_set_running_anim()
 elseif player_crouched_timer<.2 and player_cx>0 then
  player_anim_flip=false
  player_set_running_anim()
 elseif btn(2) then
  player_set_anim(player_anim_shoot_up)
 elseif btn(3) then
  -- check if the player is not doing anything else but press down.
  if player_crouched_timer>.2 then
   player_set_anim(player_anim_crouch_idle)
  else
   player_set_anim(player_anim_shoot_down)
  end
 else
  player_set_anim(player_anim_idle)
 end

 -- anim state handling
 if abs(player_vx)<.1 and shoot_button.time_held>0 then
  if btn(2) then
   player_set_anim(player_anim_shoot_up)
  elseif btn(3) then
   player_set_anim(player_anim_shoot_down)
  else
   player_set_anim(player_anim_shoot)
  end
 elseif player_jump_pressed then
   player_set_anim(player_anim_launch)
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
 
 -- check if the level damages the player
 if player_cr.floor then
  local mx,my=map_coords(player_x+4,player_y+9)
  if(mget(mx,my)==89)player_damage() -- standing on lava tile hurts the player
 end
end

--
function pdraw(ox,oy)
 spr(player_anim[player_anim_next],player_x+ox,player_y+oy,1,1,player_anim_flip)
end

--
function draw_hud()
 if show_hud_timer>0 then
  local by=cam_y+58
  local y=(show_hud_timer>2.9) and by+20*(show_hud_timer-2.9) or (show_hud_timer>1) and by or by+10*(1-show_hud_timer)
  if(player_score==128)pal(7,10)
  print_outline(time_to_text(game_time),cam_x+1,y,7,1,align_l)
  print_outline(player_score.."/128",cam_x+64,y,7,1,align_r)
  pal(15,1)
  spr(36,cam_x,y-7)
  spr(7,cam_x+57,y-7)
  pal()
 end
end

--
function player_draw()
 if(played_damaged>0 and played_damaged%.2>.1)return
 
 for i=1,15 do
  pal(i,0)
 end 
 
 if(player_air_time<.1)clip(player_x-1-cam_x,player_y-1-cam_y,10,9)
 pdraw( 1, 0)
 pdraw( 1, 1)
 pdraw(-1, 0)
 pdraw(-1,-1)
 pdraw( 0, 1)
 pdraw(-1, 1)
 pdraw( 0,-1)
 pdraw( 1,-1)
 clip()
 
 pal()
 
 local gt=gun_types[player_current_gun]
 
 local px,py=player_x+3+player_shoot_ox,player_y+4+player_shoot_oy
 
 rect(px-1,py-1,px+1,py+1,0)
 if(player_shooting_cooldown>gt.rate-.1)circfill(px,py,2,7)
 
 local gd=player_gun_disabled>0 and player_gun_disabled%.1>.05
 
 pal(12,gd and 5 or gt.color)

 pset(px,py,12)
 pdraw(0,0)
 pal()
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

function ebs_make_bullets(x,y,s,speed,count,inc_a,start_a,lifetime)
 if(x<target_cam_x or x>target_cam_x+63 or y<target_cam_y or y>target_cam_y+63)return
 
 sfx(13)
 
 local ia=start_a
 for i=1,count do
  local eb=ebs[ebs_next]
  eb.x,eb.y,eb.s=x,y,s
  eb.velx,eb.vely=speed*cos(ia),speed*sin(ia)
  eb.active,eb.t=true,lifetime or 4
  ebs_next=next_i(ebs,ebs_next)
  
  ia-=inc_a
 end 
end

--
function ebs_check_player(eb)
 local s=eb.s/2
 if player_x+6<eb.x-s or
    player_x+2>eb.x+s or
    player_y+6<eb.y-s or
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
   elseif eb.y<-8 or eb.x<-8 or eb.y>526 or eb.x>1038 then
    eb.active=false
   else
    eb.t-=one_frame
    eb.y+=eb.vely
    eb.x+=eb.velx
    
    local s=eb.s
    if ebs_blink%.05>.03 then
     parts_spawn(.5,eb.x+s/2-rnd(s),eb.y+s/2-rnd(s),0,0,0,0,s,-.05*s,8,10,parts_flags_blink)
    end
    
    ebs_check_player(eb)
   end
  end
 end
end

-- enemies
enemy_types={}

--
function enemy_shooter_init(e,size)
 e.bullet_size,e.bullet_timer=size,0
end

--
function enemy_shooter_update(e,wait,speed,count,angle,check_flip,lifetime)
 e.shoot_bullet_time=wait
 if e.bullet_timer<e.shoot_bullet_time then
  e.bullet_timer+=one_frame
 end
 
 if e.bullet_timer>=e.shoot_bullet_time then
   e.bullet_timer=0
   
   if(check_flip and e.anim_flip)angle+=.5
    if angle<0 then
     angle=atan2(normalize(player_x-e.x,player_y-e.y))
    end
    
    ebs_make_bullets(e.x+4,e.y+4,e.bullet_size,speed,count,1/count,angle,lifetime)
 end
end

--
function enemy_spawner_init(e,time,spawn_type)
 e.spawn_enemy_time,e.spawn_enemy_max_time,e.spawn_timer,e.spawn_type,e.children=time,time,0,spawn_type,0
end 

--
function enemy_spawner_update(e)
 if e.spawn_timer<e.spawn_enemy_time then
  e.spawn_timer+=one_frame
   
  if e.spawn_timer>=e.spawn_enemy_time then
   e.spawn_timer=0
   e.spawn_enemy_time=e.spawn_enemy_max_time+rnd()
   
   local x,y=e.x,e.y
   if(x<target_cam_x or x>target_cam_x+63 or y<target_cam_y or y>target_cam_y+63)return
   
   if e.children<10 then
    e.children+=1
    sfx(18)
    enemy_spawn(e.spawn_type,x,y,0,0,e)
    for i=1,10 do
     parts_spawn(.2,x+4,y+6,1.5*cos(.1*i),1.5*sin(.1*i),unpack(nl("0,.95,3,-.2,11,8,")))
    end
   end
  end
 end
end 

--
function enemy_ledge_behavior_turn(e)
 if e.x+4>e.last_ledge_x then
  e.vx=e.type.vel_x
 else
  e.vx=-e.type.vel_x
 end
end

-- demon flyer
enemy_types[8]=
{
 idle_anim=nl("8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,"),
 vel_x=.5,
 health=4,
 g=0,
}

-- demon flyer mini-boss
enemy_types[9]=
{
 idle_anim=nl("8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,"),
 vel_x=.2,
 health=20,
 g=0,

 init=function(e)
  enemy_shooter_init(e,4)
 end,

 update=function(e) 
  enemy_shooter_update(e,3,.3,1,-1)
 end,
}

-- demon dude
enemy_types[24]=
{
 idle_anim=nl("24,24,24,24,24,24,25,25,25,25,25,25,"),
 vel_x=.5,
 health=4,
}

-- demon dude self-destruct
enemy_types[25]=
{
 idle_anim=nl("24,24,24,24,24,24,25,25,25,25,25,25,"),
 vel_x=.5,
 health=2,
 
 init=function(e)
  enemy_shooter_init(e,3)
  e.max_t=.5+rnd(2.5)
 end,
 
 update=function(e)
  if e.t>e.max_t then
   enemy_shooter_update(e,.01,.5,10,-1,false,.6)
   enemy_kill(e)
  end
 end,
}

-- alien dude no stop at ledges
enemy_types[26]=
{
 idle_anim=nl("26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,"),
 vel_x=.15,
 health=4,
}

-- floating alien dude stop at ledges
enemy_types[10]=
{
 idle_anim=nl("10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,"),
 vel_x=.05,
 health=4,

 ledge_behavior=enemy_ledge_behavior_turn,
}

--
function create_spread_shooter_enemy(anim,vx,h,bsize,bwait,bspeed,bcount,bangle,bangle_inc,check_flip)
 return
 {
  idle_anim=anim,
  vel_x=vx,
  health=h,

  init=function(e)
   e.a=bangle
   enemy_shooter_init(e,bsize)
   e.jump_cooldown=0
  end,

  update=function(e)
   e.jump_cooldown-=one_frame
   
   e.a+=bangle_inc
   enemy_shooter_update(e,bwait,bspeed,bcount,e.a,check_flip)
  end,
  
  ledge_behavior=enemy_ledge_behavior_turn,
 }

end

-- shooter horned dude
enemy_types[28]=create_spread_shooter_enemy(nl("28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,"),unpack(nl(".1,6,3,4,.5,1,0,0,1,")))

-- spiral shooter roller
enemy_types[58]=create_spread_shooter_enemy(nl("58,58,58,58,58,58,59,59,59,59,59,59,"),unpack(nl(".05,10,3,.2,.5,1,0,.01,")))

-- 8-way shooter horned roller
enemy_types[60]=create_spread_shooter_enemy(nl("60,60,60,60,60,60,61,61,61,61,61,61,"),unpack(nl(".05,14,3,1,.5,8,0,0,")))

-- miniboss dude #1 - the rabbit
enemy_types[14]=create_spread_shooter_enemy(nl("14,14,14,14,14,14,15,15,15,15,15,15,"),unpack(nl(".5,60,5,1.5,.4,1,-1,0,")))

-- miniboss dude #2 - the ponytail
enemy_types[30]=create_spread_shooter_enemy(nl("30,30,30,30,30,30,31,31,31,31,31,31,"),unpack(nl(".5,60,3,.7,.5,1,-1,0,")))

-- miniboss dude #3 - the skull jr
enemy_types[46]=create_spread_shooter_enemy(nl("46,46,46,46,46,46,46,46,46,46,47,47,47,47,47,47,47,47,47,47,"),unpack(nl(".1,60,3,1,.4,4,0,.005,")))

-- miniboss dude #4 - black death
enemy_types[62]=create_spread_shooter_enemy(nl("62,62,62,62,62,62,62,62,63,63,63,63,63,63,63,63,"),unpack(nl(".2,60,3,2,.5,10,0,0,")))


--
function create_spawner_enemy(anim,h,time,spawn_type)
 return 
 {
 idle_anim=anim,
 vel_x=0,
 health=h,
 
  init=function(e)
   enemy_spawner_init(e,time,spawn_type)
  end,

  update=enemy_spawner_update,
 }
end

-- static spawner head
enemy_types[37]=create_spawner_enemy(nl("37,37,37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38,38,38,"),20,2,26)

-- static spawner head boss
enemy_types[38]=create_spawner_enemy(nl("37,37,37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38,38,38,"),30,2,26)

-- static spawner demonhead
enemy_types[40]=create_spawner_enemy(nl("40,40,40,40,40,40,40,40,40,40,41,41,41,41,41,41,41,41,41,41,"),20,1,25)

-- static spawner demonhead boss
enemy_types[41]=create_spawner_enemy(nl("40,40,40,40,40,40,40,40,40,40,41,41,41,41,41,41,41,41,41,41,"),60,1,25)

-- static alien shooter
enemy_types[42]=create_spread_shooter_enemy(nl("42,42,42,42,42,42,42,42,42,42,43,43,43,43,43,43,43,43,43,43,"),unpack(nl("0,4,3,2,1,1,0,0,1,")))

-- static aimed shooter horned head
enemy_types[44]=create_spread_shooter_enemy(nl("44,44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45,45,45,"),unpack(nl("0,6,3,2,.5,1,-1,0,")))

-- static 3-way shooter horned head
enemy_types[12]=create_spread_shooter_enemy(nl("12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,"),unpack(nl("0,8,3,1,.5,3,0,.005,")))

-- static horned head mini-bosses
enemy_types[45]=create_spread_shooter_enemy(nl("44,44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45,45,45,"),unpack(nl("0,20,4,2,.5,1,-1,0,")))

-- skulldude final boss
enemy_types[39]=
{
 idle_anim={39},
 vel_x=.05,
 vel_y=.03,
 health=100,
 g=0,
 ignorecollision=true,

 init=function(e)
  e.a=0
  enemy_shooter_init(e,4)
 end,

 update=function(e) 
  e.a+=.01
  local bspeed=.4+.4*(1-e.health/e.type.health)
  local bwait=.5+e.health/e.type.health
  
  if e.a%.02>=.01 then
   enemy_shooter_update(e,bwait,bspeed,1,-1)
  else
   enemy_shooter_update(e,bwait,bspeed,5,e.a)
  end
  
  parts_spawn(.2+rnd(.4),e.x+4,e.y+4,-.2+rnd(.4),-.5-rnd(),unpack(nl("0,.95,6,-.2,8,0,")))
 end,
}

--
enemies={}

for i=1,100 do
 add(enemies,{active=false})
end

--
function enemy_spawn(spr,x,y,mx,my,pe)
 
 -- check if we already have an active enemy with those coords.
 if not pe then
  for k,e in pairs(enemies) do
   if(e.active and mx==e.mx and my==e.my)return
  end
 end
 
 local e,i=find_next_i(enemies,enemies_next,enemies_active_count)
 
 if e then
  enemies_next=i
  
  enemies_active_count+=1
  e.active=true
  e.pe=pe
  e.type_i,e.type=spr,enemy_types[spr]
  e.anim,e.health=e.type.idle_anim,e.type.health
  e.x,e.y,e.mx,e.my=x,y,mx,my
  e.vy,e.vx=e.type.vel_y or 0,(rnd()>.5 and 1 or -1)*e.type.vel_x
  e.anim_flip,e.anim_index,e.t=e.type.vel_x<0,1,0
  e.boss,e.damaged_timer=level_boss_arena,0
 
  if(e.type.init)e.type.init(e)
 end
end

--
function enemy_disable(e)
 e.active=false
 enemies_active_count-=1
 
 if(e.pe)e.pe.children-=1
end

--
function enemy_kill(e)
 enemy_disable(e)
 
 if(e.type_i==39)reload()load_game()
 
 if(e.mx!=0 or e.my!=0)mset(e.mx,e.my,64)
 
 
 if level_boss_arena then
  level_boss_arena=false
  for k,ae in pairs(enemies) do
   if(ae.active and ae.boss)level_boss_arena=true
  end
  
  if not level_boss_arena then
   music(0)
  end
 end

 sfx(14)
 screenshake(6,.7)
 screenflash(.025,7) 
end

--
function enemy_damage(e,damage)
 if(e.t<.2)return
 
 e.health-=damage
 e.damaged_timer=.3
 if e.health<=0 then
  
  for i=1,10 do
   parts_spawn(.3,e.x+4,e.y+4,1.5*cos(.1*i),1.5*sin(.1*i),unpack(nl("0,.95,3,-.2,8,9,")))
  end
  
  enemy_kill(e)
 else
  sfx(17)
 end
end

--
function enemy_draw(e,ox,oy)
 if(e.type.g==0)oy+=2*sin(2*e.t)
 spr(e.anim[e.anim_index],e.x+ox,e.y+oy,1,1,e.anim_flip)
end

--
function enemy_check_player(e)
 if player_x+6<e.x or
    player_x+2>e.x+8 or
    player_y+6<e.y or
    player_y+2>e.y+8 then
 else
  player_damage()
 end
end

--
function enemies_spawn_check()
 level_boss_arena=false
 local found_enemies=false

 local start_x,end_x,inc_x=mirror_mode_bool and target_cam_x+63 or target_cam_x,mirror_mode_bool and target_cam_x or target_cam_x+63,mirror_mode_bool and -8 or 8
 
 for x=start_x,end_x,inc_x do
  for y=target_cam_y,target_cam_y+63,8 do
   local mx,my=map_coords(x,y)
   
   local tile_spr=mget(mx,my)
   
   if(tile_spr==65)level_boss_arena=true
   
   if fget(tile_spr,7) then
    enemy_spawn(tile_spr,mx*8,my*8,mx,my)
    found_enemies=true
   elseif fget(tile_spr,6) then
    pickups_spawn(mx*8,my*8,tile_spr)
   end
   
  end
 end
 
 if not found_enemies then
  level_boss_arena=false
 else
  if(level_boss_arena)music(40)
 end
end

--
function enemies_reset()
 for k,e in pairs(enemies) do
  e.active=false
 end
 
 enemies_next,enemies_active_count=1,0
end

--
function enemies_update()
 for k,e in pairs(enemies) do
  if e.active then
   e.t+=one_frame
   
   local damaged=(e.damaged_timer>0)
   
   if(damaged)e.damaged_timer-=one_frame
   
   if not damaged then
    e.anim_index=next_i(e.anim,e.anim_index)
    e.x+=e.vx
    
    if e.type.ignorecollision or not s_floor(e.x+4,e.y+8) then
     e.vy+=(e.type.g or .05)
     e.y+=e.vy
    else
     e.y=flr((e.y+1)/8)*8
    end
    
    local x,y=e.x,e.y
    
    if not e.type.ignorecollision then
     if e.vx<0 then
      if s_lwall(x-1,y+4) or x<=-1 then
       e.vx=-e.vx
      end
     elseif e.vx>0 then
      if s_rwall(x+9,y+4) or x+8>=1024 then
       e.vx=-e.vx
      end
     end
    end
    
    if e.type.ledge_behavior then
     if s_floor(x+4,y+9) then
      if e.vx>0 and not s_floor(x+7,y+9) then
       e.last_ledge_x=x+7
       e.type.ledge_behavior(e)
      elseif e.vx<0 and not s_floor(x-1,y+9) then
       e.last_ledge_x=x-1
       e.type.ledge_behavior(e)
      end
     end
    end
    
    if e.boss then
     if (x<target_cam_x-1)e.vx=abs(e.vx)
     if (x>target_cam_x+56)e.vx=-abs(e.vx)
     if (y<target_cam_y-1)e.vy=abs(e.vy)
     if (y>target_cam_y+56)e.vy=-abs(e.vy)
    elseif (x<target_cam_x or x>target_cam_x+63 or y<target_cam_y or y>target_cam_y+63) then
     if e.t>60 then
      enemy_disable(e)
     end
    end
   
    e.anim_flip=(e.vx==0 and player_x+4<x+4 or e.vx<0)
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
    pal(i,e.damaged_timer>.2 and 10 or 0)
   end
   
   local x,y=e.x,e.y
   
   if(not e.type.ignorecollision and s_floor(x+4,y+9))clip(x-1-cam_x,y-1-cam_y,10,9)
   enemy_draw(e, 1, 0)
   enemy_draw(e,-1, 0)
   enemy_draw(e, 0, 1)
   enemy_draw(e, 0,-1)
   enemy_draw(e, 1, 1)
   enemy_draw(e,-1,-1)
   enemy_draw(e,-1, 1)
   enemy_draw(e, 1,-1)
   clip()
   
   if e.damaged_timer>.2 then
    local f=nl("1,2,3,4,5,6,7,8,9,10,11,12,13,14")
    local t=nl("8,8,9,9,8,9,8,10,8,8,8,10,9,8")
    for i=1,#f do
     pal(f[i],t[i])
    end
   else
    pal()
   end
  
   enemy_draw(e,0,0)
   
   if e.damaged_timer>0 then
    local hs=e.health/e.type.health
    line(x+1,y+8,x+6,y+8,0)
    line(x+1,y+8,x-flr(-6*hs),y+8,hs>.25 and 10 or 8)
   end
  end
 end

 pal()
end

--
pickups={}

pickup_type_gun,pickup_type_coin=1,2

for i=1,150 do
 add(pickups,{active=false})
end

--
function pickups_reset()
 for k,pu in pairs(pickups) do
  pu.active=false
 end

 pickups_next,pickups_active_count=1,0
end


pickup_save_masks={0,0,0,0,0,0,0,0}

--
function pickup_map_ids(x,y)
 local rx,ry=flr(round(x)/64),flr(round(y)/64)
 local pickup_save_index=ry+1
 local pickup_mask=shl(0x1,rx)
 return pickup_save_index,pickup_mask
end

--
function pickup_map_save(x,y)
 local pickup_save_index,pickup_mask=pickup_map_ids(x,y)
 pickup_save_masks[pickup_save_index]=bor(pickup_save_masks[pickup_save_index],pickup_mask)
 player_score+=1
 save_game()
end

--
function pickup_map_check(x,y)
 local pickup_save_index,pickup_mask=pickup_map_ids(x,y)
 return band(pickup_save_masks[pickup_save_index],pickup_mask)!=0
end

--
function pickups_spawn(x,y,spr)
 if spr==7 then
  pu_type=pickup_type_coin
  
  if pickup_map_check(x,y) then
   set_tile_if(x,y,7,23)
   return
  end
 else
  pu_type=pickup_type_gun
  
  if(spr==4  and band(gun_types_flags,0x2)!=0)return
  if(spr==21 and band(gun_types_flags,0x4)!=0)return
  if(spr==5  and band(gun_types_flags,0x8)!=0)return
  if(spr==6  and band(gun_types_flags,0x10)!=0)return
  if(spr==20 and band(gun_types_flags,0x20)!=0)return
  if(spr==22 and band(gun_types_flags,0x40)!=0)return
  if(spr==55 and band(gun_types_flags,0x80)!=0)return

 end
 
    
 for k,pu in pairs(pickups) do
  if(pu.active and pu.x==x and pu.y==y)return
 end
    
 local pu,i=find_next_i(pickups,pickups_next,pickups_active_count)

 if pu then
  pickups_next=i
  pickups_active_count+=1
  
  pu.active,pu.t,pu.x,pu.y,pu.spr,pu.type=true,0,x,y,spr,pu_type
 end
end

--
function pickups_update()
 for k,pu in pairs(pickups) do
  if(pu.active)pu.t+=one_frame
 end
end

--
function pickups_draw()
 pal(15,0)
 if(level_boss_arena)pal(9,5)pal(10,6)
 for k,pu in pairs(pickups) do
  if(pu.active)spr(pu.spr,pu.x,pu.y+2*sin(pu.t))
 end
 pal()
end

-- level

show_hud_timer=0

--
function level_restart()
 player_reset()
 ebs_reset()
 pickups_reset()
 enemies_reset()
 
 music(0)
end

--
function level_update()
 if(show_hud_timer>0)show_hud_timer-=one_frame
 if(title_active)show_hud_timer=2.9
end

--
function level_draw()
 local map_y=flr(cam_y/8)
 
 map(0,0,0,0,128,64,0x10)
 
 if level_boss_arena then
  fillp(game_time%.3>.2 and 0xcc33 or game_time%.3>.1 and 0x6996 or 0x33cc)
  rect(cam_x,cam_y,cam_x+63,cam_y+63,8)
  fillp()
 end 
end

--
fe_fade_in,fe_time=3,0
title_active=true

--
function title_update()
 fe_time+=one_frame

 if title_active then
  if(btn()!=0)title_active=false
 else
  fe_fade_in=max(0,fe_fade_in-one_frame)
 end
end

--
function title_draw()
 local oy=fe_fade_in<1 and 30*(1-fe_fade_in*fe_fade_in) or 0
 if(player_score==128)pal(7,10)

 print_outline("run-gun-bot",32,32+2*sin(fe_time*2)-2*oy,7,1)

 print_outline("guerragames",32,2-oy,7,1)
 print_outline("2018",32,8-oy,7,1)
 pal()
end

--
game_finished,game_finished_timer=false,0

--
function game_finished_update()
  show_hud_timer=2.9
  game_finished_timer+=one_frame

  parts_update()
  
  if game_finished_timer%.5>.45 then
   local x,y=cam_x+rnd(64),cam_y+rnd(64)
   for i=0,20 do
    local a,r=rnd(),1+rnd(3)
    parts_spawn(2,x,y,r*cos(a),r*sin(a),.1,.97,4,-.1,mirror_mode_bool and 14 or 11,mirror_mode_bool and 8 or 3,parts_flags_blink)
   end
  end  
end

--
function game_finished_draw()
 draw_hud()
 parts_draw()
 player_draw()
 
 if(player_score==128)pal(7,10)
 local blink=(game_finished_timer%.2>.1)
 local c,bc=blink and 0 or 10,blink and 7 or 8
 
 local a=min(.25,game_finished_timer/2)
 local y=cam_y-24-26*sin(a)

 if(mirror_mode_bool)pal(11,14)pal(3,8)
 local xoffset=mirror_mode_bool and 16 or 40
 spr(blink and 126 or 127,cam_x+xoffset,cam_y+40,1,1,mirror_mode_bool)
 pal()
 
 local txt=mirror_mode_bool and "slimette!" or "your bro!"
 
 print_outline("congratulations",cam_x+32,y,c,bc)
 print_outline("run-gun-bot!",cam_x+32,y+6,c,bc)
 print_outline("you rescued",cam_x+32,y+16,c,bc)
 print_outline(txt,cam_x+32,y+22,c,bc)
 
 print_outline("hit "..player_hits.." times",cam_x+32,y+32,c,bc)
end

--
function game_view_start()
 jump_button:button_init()
 shoot_button:button_init()

 player_reset()
 level_restart()
 cam_reset()
 
end

--
function game_view_update()
 if(not game_finished and not title_active)game_time+=one_frame
 
 update_screeneffects()
 
 jump_button:button_update()
 shoot_button:button_update()
 
 if game_finished then
  player_update()
  pbullets_update()
  game_finished_update()
  return
 end
 
 level_update()
 
 local game_paused=player_crouched_timer>.2
 
 if not game_paused then
  enemies_update()
  ebs_update()
  pickups_update()
 end
 
 player_update()
 cam_update()
 
 if not game_paused then
  pbullets_update()
  parts_update()
 end
end

--
function game_view_draw()
 
 if screen_flash_timer>0 then
  cls(screen_flash_color)
  return
 end
 
 cls()
 camera(cam_x+cam_shake_x,cam_y+cam_shake_y)
 
 if(game_finished)game_finished_draw()return
 
 level_draw()
 pickups_draw()
 draw_hud()
 
 parts_draw()
 
 enemies_draw()
 player_draw()
 
 camera(0,0)
end

--
function _init()
 load_game()
 
 menuitem(1,"\145 next gun",player_select_next_gun)
 menuitem(2,"\139 prev gun",player_select_prev_gun)
 menuitem(3,"reset game!?",reset_game)
 menuitem(4,"reset game+!?",reset_game_mirrored)

 game_view_start()
end

rotating_screen_timer=0

--
function _update60()
 game_view_update() 
 title_update()
end

--
function _draw()
 game_view_draw()
 title_draw()
 
 screenshake_corruption_draw()
end
__gfx__
00000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000
000cccc000000000000cccc00000cccc00677600006776000067760000f9f0000000000000800800000000000000000000000000070000700777777077000077
000c7c70000cccc0000c7c700000c7c70d6336d00d6886d00d6996d00f979f000080080000888800000000000000000007000070077777707079790700777700
000cccc0000c7c70000cccc00000cccc0d3333d00d8888d00d9999d0f97aa9f000888800008a8a0000bbbb000000000007777770007878000077770000787800
00000000000cccc00000000000c000000d3333d00d8888d00d9999d00f9a9f00408989040488884000b2b20000bbbb0000727200007777000000700000777700
0c0770000000000000c77000000077000d6336d00d6886d00d6996d000f9f000408888040408084000bbbb0000b8b80000777700000000000600006000007000
0000000000c770000000000000000000006776000067760000677600000f000000080800040000400003300000bbbb0000000000000000000600006000000000
00c00c0000c00c0000c00c0000c00c00000000000000000000000000000000000000000000000000000000000003300002e2e2e00e2e2e200000000000660600
00000000000000000000000000000000000000000000000000000000000000000080080000000000000000000000000007000070000000000000000000000000
000cccc000000000000cccc00000000000677600006776000067760000050000008888000080080000bbbb000000000007777770070000700044440000000000
000c7c70000cccc0000c7c700000cccc0d6cc6d00d6446d00d6ee6d000505000008989000088880000b2b20000bbbb0000727200077777700949490090444400
000cccc0000c7c70000cccc00000c7c70dccccd00d4444d00deeeed00500050000888800008a8a0000bbbb0000b8b80000777700007878009044440009494900
00000000000cccc0000000000000cccc0dccccd00d4444d00deeeed00050500000080800008888000003300000bbbb0000022000007777000009900000444400
00c077000c00000000c07c0000c000000d6cc6d00d6446d00d6ee6d0000500000400004000080800030000300003300002000020000220000900009000099000
000000c0000c77000000000000007700006776000067760000677600000000000400004000000000030000300000000002000020000000000900009000000000
00c0000000000c000000c00000c00c00000000000000000000000000000000000000000000440400000000000033030000000000002202000000000000990900
0000000000000000000000000000000000fff00000bbbb0000000000000000000080080000000000000000000000000007000070000000000000000000000000
0000cccc000000000000cccc00cccc000f777f0000b2b20000bbbb0007777700008888000080080000bbbb000000000007777770070000700077770000000000
0000c7c70000cccc0000c7c700c7c700f77f77f000bbbb0000b8b80077777770008989000088880000b2b20000bbbb0000727200077777700079790000777700
0000cccc0000c7c70000cccc00cccc00f77ff7f00b3333b000bbbb007007007004888840008a8a0000bbbb0000b8b80000777700007878000077770000787800
000000000000cccc0000000000000000f77777f00b2222b00b3333b07007007004282840048888400000000000bbbb0000000000007777000007070000777700
00c077000c00000000c07c000c0770000f777f00b321123bb322223b777777700421124004282840000300000000000000020000000000000600006000070700
000000c0000c7700000000000000000000fff000b321123bb321123b070707000421124004211240000300000003000000020000000200000600006000000000
00c0000000000c000000c00000c00c0000000000b321123bb321123b000000004421124444211244000300000003000000222000002220000000000000660600
00000000000000000000000000000000000cccc0000000000000000000000000000000000000000000b3b300003b3b0000e2e200002e2e000000000000000000
00cccc000000000000cccc0000000000000c7c700000000000000000006776000000000000888882030000b00b00003007000070000000000011110000000000
00c7c70000cccc0000c7c70000000000000cccc0000cccc0000000000d6bb6d0006d0000006d8820b0bbbb033000000b07777770070000700012120000111100
00cccc0000c7c70000cccc00000cccc000000000000c7c70000000000dbbbbd0006d00000088888230b2b20bb0bbbb032072720e077777700011110000181800
0000000000cccc0000000000000c7c70000770000c0cccc0000000000dbbbbd000888200006d0000b0bbbb0330b8b80be07777022078780e0001100000111100
00c077000c00000000c07c00000cccc00c0000000000000000cccc000d6bb6d000682000006d00003003300bb0bbbb032002200ee07777020100001000011000
000000c0000c7700000000000c077000000000000007700000c7c7000067760000888200006d00000b000030030330b00e000020020220e00100001000000000
00c0000000000c000000c00000c00c0000c0c0000c0000c000cccc00000000000666d0000666d000003b3b0000b3b300002e2e0000e002000000000000110100
00000000000000000000000000555330330055000eeeeee000000000099994900999949099049940990499402999222217777777111111007777777777777777
0000000008888000020000000bbb3500bb353b30e1222215020102019440494999444949994944949949449429ddd29916666666110001111717117117117171
0000000008000800000000003333b350b335b3b5e2ee552500000000949444449449404440490040040900402dddd2dd16111116010000101117011017011110
000000000888800000000200b3bb3b5335003b35e211112501020101949494449449444400040040000400402dddd2dd16171716010000100011000011000000
0000000008000800000000003b33bb55553b5500e2ee552500000000494444994944944900400040000004002222222216111116010000100000000000000000
00000000080008000000000033bb3b535bbbbb03e211112501020102944494044044449400000000000000009999299216777776111111110000000000000000
0000000008888000000200003b33b550053b550be122221500000000949494099049494900000000000000009ddd29d216666666100001000000000000000000
00000000000000000000000003bb503030b3503b05555550020102010404404004044040000000000000000022222dd211111111100001000000000000000000
00000000003000000022000035053b303b3035500eeeeee0eeeeeee200aaaa0007cd7c700a98a9a0070000709999999904224420004442400444444444404440
022002200003000000000000553b55500055503be2222225522522550abbbba0cdddcdc79888989a067777d0d2d2d2d222444424242442424344432222242244
0000000000000000020002205bbbbb53bb530bbbe2eeee1525505520abb7bbb37c7ddccca9a8899900666d002222222242244222242442444322032000030034
000000000000000000000000553b5503505b503be2eee51502000200ab7bbbb3ccd7cddd998a9888000000000000000042244402242242442300030000030032
002000000300030000000000303350bb553b3033e2ee551500000000ab7bbbb3ddddddd78888888a0006d0000000000044242242204442240000000000000030
0000000000300030000220003305555005553350e2e5551500000000abbbbbb3dcddd7cc89888a990006d0000000000044244242222422240000000000000000
000000200000003000000000bb353b353b35bb30e21111151000000003bbbb307dcdcdd7a898988a00766d000000000004244242422424220000000000000000
000000000000000000000002b330b3b0b3b0b300055555500000000000333300077ddc700aa889a0066666d00000000004244404222424400000000000000000
0000000000000000000022003b3b3b3b3b3b3b3b0011110001100110000000000000000007717710000000000449999009999990080000000000000000000000
000000000300030000000000b535b3b3b3b353b3012222101c211c2100000000000ddd0077c17cc1000000004488888997888884000020000111022200000000
000030003000300000000020005b05b00b305b30122c2221122112210d000000000000007cc17cc1020000004887888904444440000000000121021200000000
030000000000000002220000000b00b00b000b0012c222210110011000000d0000d00dd01117ccc1000002009878888400000000000000800111022200000000
00000000000000000000000000b0000000b0000012c2222100000000000000000000000077711cc100002d209878888400000000000000000000000000000000
00000030000030000000000000000000000000001222222100000000000000000dd000007cc771c1000002009888884400000000020000000222011102220111
00030000000300030000002000000000000000000122221000000000000d00000000dd001cccc711000000009888844400000000000800020212012102120121
00000000000000032002000000000000000000000011110000000000000000000000000001111110000000000994444000000000000000000222011102220111
00000000000000000000000000909090095990900110011000000000000000000771711000000000777177710800000000000000000000000000000000000000
00000000000000200022200009b9b339944059591c2111c10101020200000000771010c100200000ccc7c7c00800208000040000000000000000000000000000
0400000000000000000002209b0b39b004044044122c2121000000000000000071c17c1102d20000000c0c00000200800024400000000000000bb30000000000
02420000000240000002000009393034905094500112211001020101010000001017c0c1002000200000000000000080002440000000008000bbbb3000bbb300
0040000000040000220000229b03b3b04904059900111100000000000000000071711c0100000000000000000200000804242000020000080b7b7bb30bbbbb30
000400400004004000022000043434349040945401c2111002020102020101027c0770c100000000000000000208020004244200020802000b7b7bb3bb7b7bb3
00040420000404020220002093b0b3045454540901221c2100000000000000001cc0171100002000000000000008000204244240000800020bbbbbb3bb7b7bb3
200404002004040000000000044404400404404000110110010201010201020201111110000000000000000000008000042444200000800000bbbb300bbbbb30
74242524c22504042404040424040424262725247074747474000074747496969696969696969696967614d5d5047096c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4
c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c45604040404545404145454040404040404040404040404040454540404545404
74240404747474747474a4a4a4747474747474747474747474240000007600007000007686867676767604d5d5760496c470f6f6f6f6f6c4c4f6f6f6f6f670c4
c470f6c3c3f6f6f6f6f6f6f6f6f670c4c4f6f6f6f6f6f6f6f6f6f6f6f6f670c45604049704045404040454700497040404240404047004240454040470540404
74040404747604048787874724242427262524048024277474747476000076007600767676760000000476d5d5767696c414e6e6e6e6e6c4c4e6e6e6e6e6e6c4
c4e6e6e4f4e6e6e6e6e6e6e6e6e6e6c4c4e6e6e6e6e6e670e6e6e6e6e6e6e6c45656c20404040454049704540424040404040424040404045404040454040497
74040470740476768787474747474726242404802425267496867600767686969696969696969696960404d5d5048696c4e6e6e6e6e6e6c4c4e6e6e6e6e6e6c4
c4e6e6e6e6e6e6c4c4e6e6e6e6e6e6c4c4e6e6e6e6e682c4c4e6e6808080e6c45656560404042404046604040466042497040404049704040404970404042404
74250496960476868787707474474747470424272525047496760076009696969686767686760000760404d5d5047696c4e6e6e6e6e6e6c4c4e6e6e6e6e6e6f6
f6e6e6e6e6e6e6c4c4e6e6e6e6e6e6c4c4e6e6e4e4e4f4c4c4e6808080e6e6c456565656040404040404040404042404040404040424040424040404040404c2
742404968676047687877474747447474725262404242674968676007600709696767600760000000076e5e5d5767696c4e6e6e6e6e6e6f6f6e6e6e6e6e6e6e6
e6e6e6e6e6e6e6c4c4e6e6e661e6e6c4c4e6e6e6e6e6e6c4c4e6e6e6e6e6e6f60404040466665604246604970466040404040404040404240404042497040456
74042496768676048774747474747474969696867696969696967600007686969600767696969696968676d5d5e08696c4e6e3e6e6e6e6e6e6e6e6e6e6e6e6c4
c4e6e6e6e6e6e6c4c4e6e6e6a5e6e6c4c4e6e6e6c4e6e6c4c4e6e6e6e6e6e6e60404040404705604040404e10404040404040483040404040404040404045656
742404960404769674747474747474749696967600768696969686007686969696768600969696969696969696969696c4c4c4c4c4c4c4c4c4e6e6c4c4c4c4c4
c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4e6e6c4c4c4c4e6e6c4c4c45656565656565656565757575756666666665656565695959595959504045656
74250496047604969696969696969696968676a7a7007696969696760096969696a77686969696969686d5d5d5d58696c4c4c4c4c4c4c4c4c4e6e6c4c4c4c4c4
c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4e6e6c4c4c4c470e6c4c4c45604240424970404565656575656040404040404040404040404709504040456
7404049686a7a796969696969686760076767676a7a7a79696700000a78086969686760000007686007600d5d5768696c470f6f6f6f6f6c4c4e6e6f6f6f670c4
c4f6c0c0c0c070c4c4c2f670f6f6f6c4c470f6f6f6e6e6c4c4f6f6e6e6f6f6c456040497040404972404565656a6046666040404970404040404049556049756
74047696c276709696969696867676000000868676c1709696867676007676969696969696007676760076d5d5c17696c4e6e6e6e6e6e6c4c4e6e6e6e6e6e6c4
c4e6e4e4f4e4e6c4c4e4e6e6e6e6e6f6f6e6e6e6e6f4f4c4c4e6e6e6e6e6e6c456a604040424a604040404970404045656970404040404049704049556240456
74047696969696969670768676007696969696969696969686a7a7008676800076867686969696007676c1d5e5e5e596c4e6e6e6e6e6e6c4c4f4f4e4e6e6e6c4
c4e6e6e6e6e6e6c4c4e6e6e6e6e6e6e6e6e6e6e6e6e6e6c4c4e6e6e6e6e6e6c45666665697049595959504040404975656570404040495959595959556970456
74769696969686769600007600768686760076868676047600000076867600760076007686969696969696d5d5760096c4e6e6e6e6e6e6f6f6e6e6e6e6e6e6f6
f6e6e6e6e6e6e6c4c4e6e6e6e6e6e6c4c4e6e6e6e6e6e6c4c4a3e6e6e6e6e6f60404705624045657575604045656565756560404a60404049704045656242456
747686969686760076007676a7a7a7a7767676767600007676007686767676969696967676760076007096d5d5c17696c4e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6
e6e6e6e6e6e6e6f6f6e6e6e6e6e6e6c4c4e6e6e4e4e6e6f6f6e4f4e4e4e6e6e60424975656245656565604045657570456560497240404040424040456045657
7476869686767676867683000076000076867600c100000000007600007686969696968600007676869696d5d5f5e596c4e6e6e6e6e6e6c4c4e6e6e6e6e6e6c4
c4e6e6e6e6e6e6e6e6e6e6e6e6e6e6c4c4e6e6e6e6e6e6e6e6e6e6e6e6e6e6c45656565756049724045666045656567056560404040457045704972404045657
74007696760076969696969696969696969696969696969696969600769696969696969600709696969600d5d5007696c4e6e6c4c4c4c4c4c4959595959595c4
c4959595959595c4c4959595959595c4c49595959595c4c4c4e6e6e6e6c4c4c457575757560424040456970404560404575670045656575656566666a6245657
7400769676a7a7969696969696969696969696969696969614000076760000709696969600869600700000d5e5e50096c4e6e6c4c4c4c4c4b6b6b6b6b6b6b6b6
b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6c4e6e6e6e6c4c4c45757565600045656565756040497040424040404045656565600042497045657
74000096c27600969686867676000076768676008676709662c200000076c26296969686769696007676c1d5d5760096c4e6e6f6f6f670c4b670d7d7d7d7d7b6
b614d7d7d7d770b6b614d7d7d7d7d770d7d7d7d7d7d7d7b6c4e4f4e6e6f6f6c4575604240404565656565756040404040497240404a697042497565656565757
74007696a7a7769696767600007676868676c20076760096a7a700767686a7a7969696760096867600e5e5d5d5c17696c4e6e6e6e6e6e6c4b6c6d6b7b7d6d6b6
b6d6b7b7b7d6d6b6b6d6d6b7d6d6d6b6b6d6b7b7b7b7b7b6c470e6e6e6e680c4575600009724040404975657565656565656562466660456000024a624565757
740000960076c296960076967600009696a7a7760000769686007686867676009696860086967600767600d5e5e57696c4e6e6e6e6e6e6c4b6d6b7b7b7b7d6b6
b6b7b7b7b7b7d6b6b6d6b7b7b705d6b6b6d6b7b7b7b7b7b6c4e6e6f4e4e6e6c456a6240004a62470040404565697002404045604972404565656562404045657
7470009676a7a79696768696867600969676867600a286967600867676000076007600769696a7a7a7a700d5d5768696c4e6e6e6e6e6e6c4b6b7b7b7b7b7b7b6
b6b7b7b7b7b7b7b6b6d6b7b7b7b7d6b6b6d6b7b7b7b7d6b6c480e6e6e6e6e6c45624000056565656040404565604049704040466665656565756a62497045657
969676968676009696767696a70000969676760000a7a7968676760076007686000086969686760000c200d5d5007696c4e6e6e6e6e6e6c4b6d6b7d6b7b7b7d7
d7b7b7b7b7b7d6d7d705b7b7b7b7d6b6b6b7b7b7b7d6d6b6c4e6e6e6e6f4e4c45600970400565757569704565604040424040404705656565656040404247056
96867696a7a77686760086967081819696867600007686969696867676869696000096968676767600e5e5e5d5768696c4e6e6e6e6e6e6c4b6d6b7d6d6b7d6d6
d6d6b7b7b7e1d6d6d6d6d6b7b7e2d6b6b6d6b7b7d670d6b6c4e6e6e6e6e6e6c4560000a6245656565600a65656a697240497046666240424a69704045704a656
96867696969696969696969696969696969696967600969696969696969696969600967076000086867600d5d5768696c4c4c4c4c4e6e6c4b6b6b6d6d6b6b6b6
b6b6b6c6c6b6b6b6b6b6b6b6b6b6b6b6b6d6d6b7b7c6c6b6c4c4c4e6e6c4c4c45756565604a6240456560470560404a604242400042424042404045756245656
967600969696969696969696969696969696969600009696149076867690867696769696969696969696e5e5d57676878770d7d7d7d6d6b6b6b6b6d6d6b6b6b6
b6b6b6d6d6b6b6b614d7d7d7d7d7d7d7b614d6b7b7d6d6b6c4c4c4e6e6c4c4c457575756a6240497565604975604045656565656000497045757565756705756
9600000086767096967086474776869696700000a700869670009076907686767686968676000070000000d5d5c2769696d6d6b7b7b7d6b6b614d7d605d670b6
b6b6d7c6c6d7b6b6b7b7c672b7c6b7b7d7d6b7b7b7d6d6b6c470f6f4e4f6f6c457575757565656245656242456047056565656575604a624561424a6a604a656
960000767676009696c17647470076969600760076a7769676760090007676769696967686760000000000d5e5e5009696d6b7b7b7b7d6b6b6d6b7b7d6d6d6b6
b6d7b7d670d6d7b6b7b7b7b7b7b7b7d6b6d6b7b7b7b705b6c4e6c2e6e6c2e6c45757565657575604565604245656040404240456560424a6560424a624a62424
96007686767686969696964747007600007676a7867676960086760076768686969696760076767600e5e5d5d576c19696b7b7b7b7b7b7b6b6d6c6c6c6c6d6b6
d7d6b7c6c6b7b7d7c6b7b7c6c6b7b7c6b6b7b7b7b7b705b6c4e4e4e6e6e4f4c45656700456575604565624045656a60404049756575656565624040404240404
9676868676007600007600000000007600760076a776009676767686767600767676767600760086760000d574f5e59696d6b7b7b7b7d6b6b6d6d6d6b7d6d6b6
d6d6b7b7b7b7b7d6d6b7b7b7b7b7b7d6b6b7b7b7b7d6d6b6c4e6e6e6e6e6e6f6040404040456560456560497565656565600a656565656565624a60424040404
96a7a7767676000076867600007696969676a78676764096867600867676768676768376760000007676747474007686d7d6b7b7b7d6d6d7d705d6b7b7b7d6b6
d673d6c6c6b7b7d6d6b7c6b7b7c6d6d6b6d6b7b7b7d605b6c4e6e6e4f4e6e6e604040404040404045656040424040424042424040424a60404a6046666662404
9686768181767696968686c176869696968683760086a596968676760076869696969686767600000074747474747076d6d6d683d6d6d6d6d6d6d6d6b7d6e0b6
d6a5d6d6b7b7d6d6d6d6b7b7b7b7d670b6d6d6b7d6e370b6c4e6e6a1a1e6e6c4c4c4048304970404040466665756040497a6565656565670040424e297240404
969696969696969696969696969696969696969696969696969696969696969696969696969696967474747474747474b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6
b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6c4c4c4c4c4c4c4c4c4c4c4c456565656565656565757565656565757575757565656565656565656
__gff__
000000004040404080808080808080800000000040404010808080808080808000000000408080808080808080808080000000000000104010108080808080800000101f1f1f101f1f11111f1f1011111110101f1f1f111f1f1f1f111010111110101011111f1110101f101f111010101010101f1f1f10101f10111010100000
1f1f00000000000000000000000000001f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
40424040424040404040404040404042625d0a404040404040404040404040404040404040404040404040404240084040084042404040404240404042404042622c404240402c404240404042404042410742525d525242424042400740514060614354445454435140616161604354545444445d0743545454447373737373
4240404000004040427c404040402a52725d5f5f5e40404040404240400740407c07404040404040404040084042404040407c4042404b424b624b424b07424b424b787878784b424b40424b404b404b404b40725d29525242404040406051616040607373434443606161514051604343516043445443725d43527273737307
5240405242406242425d400a40405f5e5f5d40404040404040404040404040405d404040404040404040627c5240404240405d0740404b4b4b4b4b4b4b4b4b4b4b4b4d4d4d4d4b4b4b4b4b4b4b4b4b4b4b4b42525e5e5e404040404060514343616061730773736161404343606140615160425d5d435d625d5d62625d73735e
7c40404200004262625d5f5e4042402a005c6240402a40407042407c404050425d404040404240400840425d42400742402c5d5e5e52724b4b4d4d4d4d4d4d4d4b4b4d074d4d4b4b4d4d4d4d4d4d074b4b4242725d5242424040406051614454605143437373736051515454544360515142525d5d625d525d5d72525d5d5272
5d40405200406242725c72624040405f5f5c72520a4949474752405d404042725c404040627c40404062725d40425e5e5f5f5c726240424b4b4d4d4d4d4d4d4d4b4b5b5b4d4d4b4b4d4d4d4d4d4d4b4b4b5272525d7c42474360385140515454616143545454544361607373544444436463425d5d525d625d5d52625d5d6262
5d07404200425f5f5e5d624042404052725c5f5e5e072a474772425d424050525d404040425d40404042625c4052426272725c52424242724b4d054d4d4d4d4d4b4b4d4d5b5b4b4b4d4d4d4d4d4d4d4d4d4052725d5d52475464645160515444516460607373736064647373510754544262525d5d3a47725d5d62525d5d7252
5c5e406252005252725c5272074042405f5e725240524a474770525c524040425c404242625d52714038425d4240404052625c62504262424b4d5a3c4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d3c4b4b4240425d5d7247445161515161444451614051737373406160737361514454523a725d474747475d5d38625d5d5252
5d42404042004042525f5f5f5f404052725d6242404272474747725c725240425c425242404747474747405c4240404240625d72625040404b4b4b4b4b4b4b4b4b4b4b4d4d4b4b4b4b4b4b4b4b4b4b4b4b4747474747474754544340514344544360606043444461604054545444444347474747474747474747474747476252
5c4242520000005e5f5c725242404007525c4040404052474747715d524240525c725240714747474747425c5242074041405d424052002d4b4b4b4b4b4b4b4b4b4b4b5b5b4b4b4b4b4b4b4b4b4b4b4b545444445443444454544360514344444360516044445444545443514252524042404262404252404240400747476262
5c40425200005242525d5f5e40525f5f5f5f5e5e404240474747475d404052725d524040474740074747625d72624040405f5f5e4040425b4b074d4d2c4d4d4d4d4d4d4d4d4d4d074d7878784d4d4d4b540773737373737373616061606061616060646473075443075160404240426240522c422c4042624052424247474962
5c624040007c0740625d6242627c4042725d62424040074747474747404052505d40402a475242404747725c6242524262725d405240002d4b4d4d4d4b4d4d4d4d4d4d5b5b4d4d4d4d78784b184d4d4b4473737373737373732c40605160605160516051737354516040420c5545455656565656564545554042524047424242
5d724240005d5e62725c62620a5d5e40525d52400047474747474747474042405c4070474772424a4747425d424040425e5e5e424042005b4b4d5b5b4b4b4d4d4d4d4d4d4d4d4d4d4d784b4b5b5b4d4b447373435454445444544444435454444364646073444360420c72455577777676767676767777554542404242424249
5d5e4040425d625f5f5c525f5f5d0a40425c42404747474747787872404040405d404747474940404747715d4040424042625d524040422d4b4d4d4d4d4b4b4d4d4d4d5b5b4d4d4d4d4b4b4d4d4d184b547373434454544443544454544444444360514073445140424545557776764646467676767676775545550c42424272
5c6262405f5d4062725d5e5e525c5e5f005d52427878724207787842404040715d4747786252424a4747475d5252404042625e5f5f40524b4b4b4b4d4d4d4b4b4b4d4d4d4d4d4d4b4b4b4d4d4d5b5b4b5460516051516060516061406160516140615161544340424545777776767676764646460c4646467777454542624949
5d714242425d7062715d7152705c7142705d727078784270007878401a4070474747787842407162474747477271404070725d72714000074d4d4b4d4d4d4d4b4b4d4d5b5b4d4d4b4b074d4d4d4d4d4b4451512c60605160402a4040516140606161605154514245457776764646454545454545454576464646774545424262
474940424a474847474748474747474747474747475959595959474747474747477278784a494747474747474747474747474747474b4b4b4b4d4b4d4d5b5b4b4b4d4d384d4d4d4b4b5959595959594b545160435444445454436107406043545454445443404545774646454545457777777707774545455576767745456242
4752406272474747477262424040424042427262424040404042407242404040404078784062474747474747724207474b074d4d4d4d4d4d4d4d4b4d4d4d4d4b4b4b4b4b4b4b4b4b4b4d4d4d4d4d074b546051546140514061614060616140074454444340424577467645457777774676767676767777775555767677454507
4749404042524747476242402c404040404042404240402c404062421c421c40407278474747474747726242524040474b4d4d4d4d5b5b4b4b4b4b5b5b4d4d4d4d4d4d084d4d4d4d4d4d4d4d4d4d4d4b435151546060616161516463605151404407614042555546765555774646464646764676767646467745764646774555
4771404062400747474240474747474747624240404040474747474747474747474747474747474747404042404252474b4d4d4d4d4d4d4b4b074d4d4d4d4d3a4d4d4d4d4d4d4d4d3a4d4d4d4d4d4d4b446061546363616051515161406025514461604055557776555577764676767676761c1c1c4646767645767646467745
47494242405272474740404042524040477262424042404772525272624074747262400747474747472c4040404072474b4d4d4d4d5b5b4b4b4d4d4d4d4b4b4b4b4d4d074d4d4d4b4b4b4b5b5b4d4d4b446140446051606364606161606463605461400c45774676457776554545454545454545454545557655565655767655
4c5252424042524c474762424040400747494940424062476240425242427474424240404747474747474240404262474b4d4d4d4d4d4d4b4b4d4d084d4d4d4d4d4d4d4d084d4d4d4d4d4d4d4d4d4d4b5460075460515151606151254051606143514055557655554576767777777777777777772c7777457677467645767677
4c4a72704257424c47477242424040474773734040427247072c404040527474404042524742404042404040424042424d4d4d4d4d5b5b78784d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d5b4b5460614361616060406064636061616144600c4577464545457646464646464646764646565676555556467645764676
4c4a494a725a704c474747624042524747077340404a49474747404262727474424062724740404040400a0a0a0a40424d4d0a4d0a4d4d78784d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4b44616144605163646160515164646006544055554655454545764676760c765555567646762c76774576467645764646
4c4c4c4c4c4c4c4c474747404047474747474747474747474740424047474747474747474740424747474747474747474b4b4b4b4b4b4b4b4b4b4b4d4d4b4b4b4b4d4d4d4d4d4d4b4b4b4b4d4d4b4b4b4361604440515143435160616125405a4442457746454545455656565656074545077676765656764576567645767646
47474707405242404040404040404042527262074040404240404018474747474747474747424947400740404040404040674067676740404b074d4d4d4d4d4d4d4d4d074d4d4d4d4d4d4d4d4d4d074b445160430740434454544444544354444340454656555545457676464676764545567646467676074576460c45760746
477262494952726240402a49492a404042524240402a52404040494a4042404007404040426272474040676740674067404067676740404d4b4d4d5b5b4d4d4d4d4d4d084d4d4d4d4d4d4d4d4d4d4d4b4451405164647373737373737373615160424576467777454576565656565645450c7646565656564576465645767646
4762420a5242724240494a40524a494040524040524a49494a4940404240384040420a404747474740676740406767404067674040404d4d4b4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4b43516061616073737373616040736040404255455576464545565656565676454556767676760c7645760c7645464646
4742474a4a406240404242404052404a494040404052424240424040184047474747474747724200676767407c67674040674007404d4d4d4d4d4d4d4d4b4b4b4b4b4d4d4d4d4d4b4b4b4b4d4d4d4d4b545161616464737373731c601c7340404038777777765645457656565656564545767676565656764576567645467676
4740620a726240474740624040404240404949404240404040747474474747720000006252420042004067405d406869696767004d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d2c4d4b54516040604073737373737373436363455576767676464545565656565676454556761c1c1c4676450c767655767676
4742404a4a4740474740404040404040404040405252427474747474524000525200420000155247696740405d4067696968404d4d4d4d4b4b4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d5b5b4b446151606464737373737373735460075545454545554645455656467676144545565656565656764556467677764646
476240620a620a4747072562404052404062406272474747475242000062426272725218425a72476968677c5d40406969694d384d4b4b4b4b4b4b4d4d4d4d3a4d4d4d4d4d4d3a4d4d4d4d4d4d3a4d4b5460614061607373737373737354636340405545077776454507760c46765a45454646462c4646764576464646467676
4740404747474747474747474747474747474a494a474747474200000747474747474747474747476967405d5d40406969694b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b435444544454444354444444544360404040404545454555554545454545455555464655454545455545454545454545
__sfx__
000400001f553175431d533135130c50303503095030350318503095031a5030e5031e5031b5030a503145030c5030e5030a50300503005030050300503005030050300503005030050300503005030050300503
000200001d5500f5501f5500e55013550105501d540135400d5301e5301a5200e5101e5101b5000a500145000c5000e5000a50000500005000050000500005000050000500005000050000500005000050000500
00030000175701c5700f5601856011550085401053004520085001050001500015000150001500015000150001500015000d50000500005000050000500005000050000500005000050000500005000050000500
000200000a4310a4310a4310a42103421024210241101411054110440103401024010140101401014010140101400014000140001400014000d40007400074000340007400054000540000400004000040000400
00030000160511d051130511b0510905112051070410d0410603108021030210601101011040010300101001010010d0010a001050010100105001160010400115001030010f0010200106001000010000100001
000200000a621136211262118621106210c6210e61109611136210b6210f6110d61114611106011060109601116010d6010b601106010d601066010d601066010160109600006000060000600006000060000600
00040000183441d3441734408344153440633413334033240f324013140931401314013041530411304063040f3040e304073040a304093040230408304043040130409304003040030400304003040030400304
00020000100420604216052090521a0520b0521d0520b0521c052100421b0420804213042080421103204022090220401202012010120100201002010020100201002030020f0020200206002000020000200002
000300000b551145510455111551045510b551075410d5410653108521035210651101511045010350101501015010d5010a501055010150105501165010450115501035010f5010250106501005010050100501
010600002d7552d7552676530765347452f745347150d70510705087050a705057050470504705017050270500705007050070500705007050070500705007050070500705007050070500705000050000500005
0001000008340143400e3401c3400e34015330103300c320093200c31006310083000530008300073000130004300013000d30000300003000030000300003000030000300003000030000300003000030000300
000200001a341114410e4411f3410e441144511a3510d4510a4510e45115351074511234107441074410243111331034310d321044210d3110e31103411093110241101411003010030100301003010030100301
000200000a7501c7500f75020750117401f7400d74018740087301073001730017200171001700017000170001700017000d70000700007000070000700007000070000700007000070000700007000070000700
000200002f741287411e74123741187411a741187411373110731187310d721087210e721087210571107711027110a7010470105701077010470103701027010170109701007010070100701007010070100701
00030000263432d3430b3432f333143432e34307343293430434320333063331a343093330f323053130331303303013030d303003030d3030e30300303093030030300303003030030300303003030030300303
010800002d7501503029750110302f7501703030750180302d7501503034750347503474234742347323473234722347120070200702007020070200702007020070200702007020000200002000020000000000
010800001d750110302175015030247500c0302175015030247501803028750280302d7502d7502d7422d7422d7322d7322d7222d712007020070200702007020070200702007020070200702000020000200002
000400001d053210430a323053131d0032e00307003290030400320003060031a003090030f003050030300303003010030d003000030d0030e00300003090030000300003000030000300003000030000300003
00040000217532675310763257630d763247630b763137531b7530f74314743197330f7330b723087130471302713017130d703007030d7030e70300703097030070300703007030070300703007030070300703
00040000183041d3041730408304153040630413304033040f304013040930401304013041530411304063040f3040e304073040a304093040230408304043040130409304003040030400304003040030400304
010e00000c0630c0630c635090600c0630c0600c635090600c063000030c635090600c0630e0600c635090600c0630c0630c635090600c0630c0600c635090600c063000030c635090600c063100600c63509060
010e00002102521025280252102521025260252102521025240252102521025230252102521025280212802521025210252802521025210252602521025210252402521025210252302521025210252902129025
010e00002102521025280252102521025260252102521025240252102521025230252102521025260252802521025210252802521025210252602521025210252402521025210252302521025210252802529025
010e00001c0251c025230251c0251c025210251c0251c0251f0251c0251c0251d0251c0251c0251a0251c0251c0251c025230251c0251c025210251c0251c0251f0251c0251c0251d0251c0251c0251d0251c025
010e00001c0251c025230251c0251c025210251c0251c0251f0251c0251c0251c0251d0251f0251d0251c0251c0251c025230251c0251c025210251c0251c0251f0251c0251c0251c0251d0251f0252102523025
010e00000c0630c0630c635040600c063050600c635040600c063000030c635040600c063070600c635040600c0630c0630c635040600c063050600c635040600c063000030c635040600c063090600c63509060
010e00000c6350c6350c0630c6350c6350c0630c6350c63500003000030000300003000030000300003000030c6350c6350c0630c6350c6350c0630c6350c63500003000030c635000030c6350c6350c6350c635
010e00002d73000703307302d730327302d730307302d7312d7302d7302d7222d7222d7122d71200703007032d73000703307302d730327302d730307302d730307302d730327302d730307302d7302d7222d712
010e00000c6350c6350c0630c6350c6350c0630c6350c6350c0630c6350c6350c0630c6350c0630c635000030c6350c6350c0630c6350c6350c0630c6350c6350c0630c6350c6350c0630c6350c6350c63500003
010e00002d5352d53500503305353053500503325353253500503305353053500503325350050334535005032f5352f5350050332535325350050334535345350050332535325350050334535005033553500503
010e0000090220c022100220c0221002213022100221302215022180221c022180221c0221f0221c0221f02221022240222802224022280222b022280222b0222d02230022340223002234022370223402230022
010e0000217212172021720217202171221712217352672028720287202871228712287352873528722267202472024720247122472524725247252472526725237252372523725237252472023720217201f720
010e00000c0630000300003000030c0630c0630c063000030c6350000300003000030c063000030c063000030c0630000300003000030c0630c063000030c0630c6350000300003000030c0630c0630c0630c063
010e0000217252172521705217252172521705217352872529725297252970529715297352970529725287252b7252b7252b7052b7252b7252972528725267252972528725267252472528725267252472521725
010e00000c0630c0630c063000030c0630c0630c063000030c0630c0630c063000030c0630c0630c063000030c0630c0630c063000030c0630c0630c063000030c0630c0630c063000030c0630c0630c0630c063
010e000015525151251552500505185251812518525005051c5251c1251c525005051f5251f1251f5250050521525211252152500505185251812518525005051c5251c1251c5252450513525131251352513125
010e000028312283152631524315263152831526315243152d315003052d3152d315003052d3152d315003052b3122b3122b315003052f315003052b315003052d315003052d3152d315003052d3152d31500305
010e00000c0630c0030c0630c0630c6350c0030c0630c0630c0630c0030c0630c0630c6350c0030c0630c0630c0630c0030c0630c0630c6350c0030c0630c0630c0630c0030c0630c0630c6350c0030c0630c635
010e00002d5222d5252d5252f5253052532525305252f525285252d50528525285250050528525285250050526522265222652500505295250050526525005052852500505285252852500505285252852500505
010e000021725237252472523725007052372524725267252472500705267252872529725287250070500705267252872529725287250070528725297252b7252972500705297252b7252d7252b7250070500705
010e00000c0630c6350c0630c0630c0030c0630c6350c0630c0630c0030c0630c6350c6350c6350c0030c0030c0630c6350c0630c0630c0030c0630c6350c0630c0630c0030c0630c6350c6350c6350c0030c003
010e0000325353253530503355353553530503375353753530503355353553530503375353050339535305033953537535355353453537535355353453532535355353453532535305353453532535305352f535
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c000015030150321502215012180351503015022150121503015032150221501218035150351a035150351503015032150221501218035150301502215012150301503215022150121a035150351c03515035
010c000015530155321552215512185351553015522155121553015532155221551218535155351a535155351553015532155221551218535155301552215512155351553515525155151a5351c5351d5351c535
010c000010530105321052210512135351053510522175351053510522185351053517535105351853510535105301053210522105121753510535105221853510535105221a5351053518535105351a53510535
010c00001053010532105221051213535105351051217535105351051218535105351753510535185351053510530105321052210512175351053510522175351853517535155351353517535155351353511535
010c00000c0630c003091400c0630c6350c063091300c0630c0630c003091300c0630c6350c0630c0030c0630c0630c003091400c0630c6350c063091300c0630c0630c003091300c0630c6350c0630c0030c635
010c00000c0630c003041400c0630c6350c063041300c0630c0630c003041300c0630c6350c0630c0030c0630c0630c003041400c0630c6350c063041300c0630c0630c003041300c0630c6350c063101300c635
010c00000c06304135041400c0630c6350c063041300c0630c06304135041350c0630c6350c063101350c0630c06304135041400c0630c6350c063041300c0630c0630c6350c6350c0630c0630c6350c6350c635
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 1e 42 43 44
00 14 15 43 44
00 14 16 43 44
00 19 17 43 44
00 19 18 43 44
00 1c 1d 43 44
00 14 15 43 44
00 14 16 43 44
00 19 17 43 44
00 19 18 43 44
00 1c 1d 43 44
00 1a 1b 43 44
00 22 23 43 44
00 20 1f 43 44
00 20 21 43 44
00 22 23 43 44
00 20 1f 43 44
00 20 21 43 44
00 1a 1b 43 44
00 24 25 43 44
00 26 25 43 44
00 24 25 43 44
00 26 25 43 44
00 27 28 43 44
00 22 23 43 44
00 1c 1d 43 44
00 1c 29 43 44
02 1a 1b 43 44
02 41 42 43 44
02 41 42 43 44
02 41 42 43 44
02 41 42 43 44
02 41 42 43 44
02 41 42 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 32 36 43 44
00 33 36 43 44
00 34 37 43 44
02 35 38 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 1c 1d 43 44
00 1c 1d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
02 41 42 43 44
02 41 42 43 44
