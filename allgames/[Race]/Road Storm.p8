pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- road storm
-- 16/01/2018:06:25pm
-- 01/06/2018:12:03pm
-- twitter:@arashi256

-- changelog: v1.1 16-06-2018
-- - optimised codebase
-- - added previous title screen
-- - muted alert sound when low on ammo/fuel
-- - added btn(5) (x) as alternative accelerator button

version="1.1"
state_start,state_game,state_levelend,state_levelstart,state_endgame,state_complete=0,1,2,3,4,5
state=state_start
stype_border,stype_decoration,stype_start,stype_end,stype_bordercount,stype_deccount=1,2,3,4,0,0
cstate_car,cstate_fuel,cstate_bullets,t_start_text=1,2,3,"press \142 or z to start"
is_left,is_straight,is_right=1,2,3
camera_speed,z_depth,view_depth,ground_height,start_z,z_clip=2.5,15,15,-35,15,.2
sc_x,sc_y,hud_offset=64,45,19
last_y=10/z_depth
current_road_width=136
max_decs,border_edge,max_borders,fin_dist=8,70,5,20
start_text,finish_text,end_text,complete_text="get ready!!","winner!!","game over","congratulations"
text_x,high_score=128,0

car_type_colour={
 { c1=10,c2=3,c3=11 },
 { c1=2,c2=14,c3=10 }
}
level_details={ 
 { terrain_c1=3,terrain_c2=11,curve_strength=4,odds_of_curve=.45,odds_same_curve=.5,max_cars=4,max_car_time=50,distance=230,backg_c1=10,backg_c2=14,backg_c3=2,s_coll_x=16,s_sprite_x=17,s_sprite_y=50,s_width=25,s_height=34,d_col_x=25*2,d_sprite_x=0,d_sprite_y=50,d_width=17,d_height=10,s_scale=3,d_scale=2 },
 { terrain_c1=9,terrain_c2=10,curve_strength=5,odds_of_curve=.55,odds_same_curve=.4,max_cars=5,max_car_time=40,distance=270,backg_c1=8,backg_c2=14,backg_c3=12,s_coll_x=19*3,s_sprite_x=79,s_sprite_y=100,s_width=19,s_height=19,d_col_x=19*3,d_sprite_x=0,d_sprite_y=116,d_width=19,d_height=12,s_scale=3,d_scale=2 },
 { terrain_c1=1,terrain_c2=12,curve_strength=5,odds_of_curve=.65,odds_same_curve=.4,max_cars=6,max_car_time=30,distance=310,backg_c1=10,backg_c2=9,backg_c3=4,s_coll_x=14*3,s_sprite_x=114,s_sprite_y=99,s_width=14,s_height=29,d_col_x=14*4,d_sprite_x=0,d_sprite_y=50,d_width=17,d_height=10,s_scale=4,d_scale=3 },
 { terrain_c1=2,terrain_c2=14,curve_strength=6,odds_of_curve=.65,odds_same_curve=.35,max_cars=6,max_car_time=20,distance=50,backg_c1=10,backg_c2=11,backg_c3=3,s_coll_x=15*4,s_sprite_x=98,s_sprite_y=99,s_width=16,s_height=28,d_col_x=19*3,d_sprite_x=0,d_sprite_y=116,d_width=19,d_height=12,s_scale=4,d_scale=3 }
}

function level_detail_num(l)
 local level=flr(l/3.5)+1
 if l==10 then level+=1 end
 return level
end

function create_noticetext(x,y,nt)
 add(notice_text,{x=flr(x-((#nt*4)/2))+3,y=y,text=nt,age=80})
end

function update_noticetext()
 for t in all(notice_text) do
  t.age-=1
  t.y-=0.2
  if t.age<=0 then
   del(notice_text,t)
  end
 end
end

function draw_noticetext()
 local c
 for t in all(notice_text) do
  if t.age>40 then c=rnd(14)+1
  elseif t.age>30 then c=6
  elseif t.age>20 then c=5
  else c=1
  end
  print(t.text,t.x,t.y,c)
 end
end

function initial_scenery()
 local pos_inc=0
 for i=1,max_borders do
  if start_z-pos_inc>0 then
   add(scenery_list,new_scenery(-1*(current_road_width/2+border_edge),ground_height,start_z-pos_inc,cl_s_width*cl_s_scale,cl_s_height*cl_s_scale,cl_s_sprite_x,cl_s_sprite_y,cl_s_width,cl_s_height,false,stype_border,cl_s_coll_x)) 
   add(scenery_list,new_scenery(1*(current_road_width/2+border_edge),ground_height,start_z-pos_inc,cl_s_width*cl_s_scale,cl_s_height*cl_s_scale,cl_s_sprite_x,cl_s_sprite_y,cl_s_width,cl_s_height,true,stype_border,cl_s_coll_x)) 
   stype_bordercount+=1
   pos_inc+=3
  end
 end
 for i=1,max_decs do
  add(scenery_list,new_scenery(random_sign()*((current_road_width/2+60)+rnd(300)),ground_height,rnd(10)+1,cl_d_width*cl_d_scale,cl_d_height*cl_d_scale,cl_d_sprite_x,cl_d_sprite_y,cl_d_width,cl_d_height,false,stype_decoration,cl_d_col_x))
  stype_deccount+=1
 end
 add(scenery_list,new_scenery(0-34,0,0.7,8*2,20*2,0,84,8,20,false,stype_start,0))
 add(scenery_list,new_scenery(0,26,0.71,27*2,7*2,8,84,27,7,false,stype_start,0))
 add(scenery_list,new_scenery(34,0,0.7,8*2,20*2,0,84,8,20,true,stype_start,0))
 sort_scenery(scenery_list)
end

function new_scenery(x,y,z,width,height,sprite_x,sprite_y,sprite_width,sprite_height,b_flip,stype,cwidth) 
 return {
  x=x,
  y=y,
  z=z,
  width=width,
  height=height,
  sprite_x=sprite_x,
  sprite_y=sprite_y,
  sprite_width=sprite_width,
  sprite_height=sprite_height,
  collide_width=cwidth,
  b_flip=b_flip,
  stype=stype
 }
end

function update_scenery()
 local remainder=0
 for the_scenery in all(scenery_list) do
  if the_scenery.stype==stype_start or the_scenery.stype==stype_end then  
   the_scenery.z-=player_vz/2
  else
   the_scenery.z-=player_vz
  end
  if the_scenery.z<0 then
   remainder=abs(the_scenery.z)
   if the_scenery.stype==stype_border then 
    stype_bordercount-=0.5
   end
   if the_scenery.stype==stype_decoration then 
    stype_deccount-=1 
   end 
   del(scenery_list,the_scenery) 
  end
 end
 if stype_bordercount+0.5<max_borders then
  add(scenery_list,new_scenery(-1*(current_road_width/2+border_edge),ground_height,start_z-remainder,cl_s_width*cl_s_scale,cl_s_height*cl_s_scale,cl_s_sprite_x,cl_s_sprite_y,cl_s_width,cl_s_height,false,stype_border,cl_s_coll_x)) 
  add(scenery_list,new_scenery(1*(current_road_width/2+border_edge),ground_height,start_z-remainder,cl_s_width*cl_s_scale,cl_s_height*cl_s_scale,cl_s_sprite_x,cl_s_sprite_y,cl_s_width,cl_s_height,true,stype_border,cl_s_coll_x)) 
  stype_bordercount+=1
 end
 if stype_deccount<=max_decs then
  add(scenery_list,new_scenery(random_sign()*((current_road_width/2+60)+rnd(300)),ground_height,start_z+rnd(15)-7,cl_d_width*cl_d_scale,cl_d_height*cl_d_scale,cl_d_sprite_x,cl_d_sprite_y,cl_d_width,cl_d_height,false,stype_decoration,cl_d_col_x))
  stype_deccount+=1
 end
 sort_scenery(scenery_list)
end

function sort_scenery(a)
 for i=1,#a do
  j=i
  while j>1 and a[j-1].z<a[j].z do
   a[j],a[j-1]=a[j-1],a[j]
   j=j-1
  end
 end
end

function random_sign()
 if(rnd(1)>.5) then
  return 1 
 else 
  return -1 
 end
end

function format_number(s,n)
 local display_num=""..s
 local display_num_count=flr(#display_num)
 for i=flr(display_num_count),n do
  display_num="0"..display_num
 end
 return display_num
end

function draw_3d_sprite(rc_x,rc_y,rc_z,width,height,sprite_x,sprite_y,sprite_width,sprite_height,is_flip)
 if rc_z>z_clip and rc_z<view_depth then
  pw=width/rc_z
  ph=height/rc_z
  px=sc_x+(rc_x+camera_x)/rc_z
  py=sc_y-(rc_y+player_y)/rc_z-ph
  sspr(sprite_x,sprite_y,sprite_width,sprite_height,px-pw/2,py,pw,ph,is_flip,false)
 end
end

function draw_ground_segment(rc_x,rc_y,rc_z,width,pattern,py)
 pal(6,cl_terrain_c1)
 pal(5,cl_terrain_c2)
 sprite_width,sprite_height,sprite_x=16,1,49
 sprite_y=pattern*sprite_height 
 px=sc_x+(rc_x+camera_x)/rc_z
 py=sc_y-(rc_y+py)/rc_z 
 pw=width/rc_z
 ph=1 
 sspr(sprite_x,sprite_y,sprite_width,sprite_height,0,py,136,ph)
 pal()
end

function draw_road_segment(rc_x,rc_y,rc_z,width,pattern,py)
 sprite_width,sprite_height,sprite_x=48,1,0
 sprite_y=pattern*sprite_height 
 px=sc_x+(rc_x+camera_x)/rc_z
 py=sc_y-(rc_y+py)/rc_z 
 pw=width/rc_z
 ph=1
 if state==state_start then pal(13,0) end 
 sspr(sprite_x,sprite_y,sprite_width,sprite_height,px-pw/2,py,pw,ph)
 if state==state_start then pal() end
end

function road_x_at_z(rz)
 return the_curve_strength*rz^2
end

function draw_start_line()
 sy=40
 while sy<55 do
  sy+=1
  rz=(-ground_height)/sy
  sz=rz-world_z+.4
  draw_start_segment(road_x_at_z(sz),ground_height,sz,current_road_width,rz*8%4,0)
 end
 if sz<0 then can_draw_start=false end
end

function draw_start_segment(rc_x,rc_y,rc_z,width,pattern,py)
 sprite_width,sprite_height,sprite_x=48,1,0
 sprite_y=16+pattern*sprite_height 
 px=sc_x+(rc_x+camera_x)/rc_z
 py=sc_y-(rc_y+py)/rc_z 
 pw=width/rc_z
 ph=3
 palt(0,false)
 palt(14,true)
 sspr(sprite_x,sprite_y,sprite_width,sprite_height,px-pw/2,py,pw,ph)
 pal()
end

function draw_road()
 sy,ry=1,ground_height
 rz=-ry/sy
 while sy<67 do
  sy+=1
  rz=-ry/sy
  draw_ground_segment(road_x_at_z(rz),ground_height,rz,128,(rz+world_z)*8%16,0)
  draw_road_segment(road_x_at_z(rz),ground_height,rz,current_road_width,(rz+world_z)*8%16,0)
 end
 if can_draw_start then 
  draw_start_line()
 end
 if state==state_game or state==state_levelend then
  if dst>=cl_distance then
   if not fin_create then
    add(scenery_list,new_scenery(-34,0,10.5,8*2,20*2,0,84,8,20,false,stype_end,0))
    add(scenery_list,new_scenery(0,26,10.5,27*2,7*2,8,91,27,8,false,stype_end,0))
    add(scenery_list,new_scenery(34,0,10.5,8*2,20*2,0,84,8,20,true,stype_end,0))
    sort_scenery(scenery_list)
    fin_create=true
   end
   fin_dist-=player_vz
   draw_end_line()
  end
 end
end

function draw_end_segment(rc_x,rc_y,rc_z,width,pattern,py)
 sprite_width,sprite_height,sprite_x=48,1,0
 sprite_y=20+pattern*sprite_height 
 px=sc_x+(rc_x+camera_x)/rc_z
 py=sc_y-(rc_y+py)/rc_z 
 pw=width/rc_z
 ph=2.3
 palt(0,false)
 palt(14,true)
 pal(15,rnd(7)+8)
 sspr(sprite_x,sprite_y,sprite_width,sprite_height,px-pw/2,py,pw,ph)
 pal()
end

function draw_end_line()
 sy=30
 while sy<40 do
  sy+=1
  rz=(-ground_height)/sy
  sz=rz+fin_dist
  draw_end_segment(road_x_at_z(sz),ground_height,sz,current_road_width,rz*16%3.5,0)
 end
 if not race_finished and sz<=1 then
  text_x=128
  race_finished=true 
 end
end

function process_game_update()
 if not player_is_exploded then
  last_x=player_x
  last_z=world_z
  player_vx+=the_curve_strength*1*player_vz
  player_x+=player_vx
  player_vx*=player_x_friction
  if(player_vz<-0) then player_vz=0 end
  player_vz*=player_z_friction
  if not race_finished then
   world_z+=player_vz
  else
   player_vz=0
   if player_z<20 then
    player_z+=.2
   else
    boomshake=0
    state=state_levelend
   end
  end
 else
  if #pcrash_list==0 then
   player_invuln_flash()
   if player_crash_x>0 then
    if player_x>0 then
     player_x-=1.5
     if player_x<=0 then
      player_not_crashed()
     end
    end
   end
   if player_crash_x<0 then
    if player_x<0 then
     player_x+=1.5
     if player_x>=0 then
      player_not_crashed()
     end
    end
   end
  end
 end
 if check_scenery_collide() or check_enemy_collide() and not player_is_exploded and not race_finished then
  player_crashed()
 end
 player_car_x=-player_x
 camera_x=player_x*.25+camera_x*.75
 distance_to_next_curve+=player_vz
 the_curve_strength=current_curve_strength+(next_curve_strength-current_curve_strength)*(distance_to_next_curve/total_distance_to_next_curve)
 if distance_to_next_curve>total_distance_to_next_curve then
  distance_to_next_curve=0
  current_curve_strength=next_curve_strength
  if rnd(100)/100<odds_of_curve then 
   if dst+20<=cl_distance then
    next_curve_strength=rnd(curve_strength)+rnd(curve_strength)-curve_strength
   else
    next_curve_strength=0
   end
  else 
   next_curve_strength=0 
  end
  total_distance_to_next_curve=10+rnd(8)
 end
 dst=flr(world_z/2)
 if (player_x-player_width/2<-current_road_width/2+2) or (player_x+player_width/2>current_road_width/2-2) then 
  player_vz*=.98 
 end
 if player_cur_fuel==0 and not race_finished then
  player_vz*=.99
  if player_vz<=0 and not player_is_exploded and not player_is_invuln then 
   boomshake=0
   gameover=true
   state=state_levelend
  end
 end
end

function player_invuln_flash()
 if player_is_invuln then
  player_invuln_timer+=1
  if player_invuln_timer>4 then
   player_invuln_timer=0
   player_is_visible=not player_is_visible
  end
 end
end

function player_crashed()
 player_vz,player_vx,player_is_turning_right,player_is_turning_left,player_car_anim_num,player_crash_x,player_is_invuln=0,0,false,false,is_straight,player_x,true
 if not player_is_exploded then 
  create_explosion(player_car_x,player_y,player_z)
  player_is_exploded,player_is_visible=true,false
 end
end

function player_not_crashed()
 player_x,player_crash_x,player_is_exploded,player_is_visible,player_invuln_timer,player_is_invuln=0,0,false,true,0,false
end

function check_collide(px1,pz1,px2,pz2,cx1,cz1,cx2,cz2)
 if ((px2>cx1 and px2<cx2) or (px1>cx1 and px1<cx2)) and ((pz2>cz1 and pz2<cz2) or (pz1>cz1 and pz1<cz2)) then
  return true
 end
end

function check_scenery_collide()
 for the_scenery in all(scenery_list) do
  if the_scenery.collide_width>0 then
   local cx1=the_scenery.x-the_scenery.collide_width/2
   local cz1=the_scenery.z
   local cx2=the_scenery.x+the_scenery.collide_width/2
   local cz2=the_scenery.z+.2 
   local px1=player_x-player_width/2-player_vx
   local pz1=player_z+player_vz
   local px2=player_x+player_width/2-player_vx
   local pz2=player_z+.2+player_vz
   if check_collide(px1,pz1,px2,pz2,cx1,cz1,cx2,cz2) then 
    return true
   end
  end
 end
 return false
end

function check_enemy_cars_collide(check_car)
 for the_car in all(enemy_car_list) do
  local cx1=the_car.x-(the_car.width/2)
  local cz1=the_car.z
  local cx2=the_car.x+(the_car.width/2)
  local cz2=the_car.z+.2  
  local px1=check_car.x-(check_car.width/2)
  local pz1=check_car.z
  local px2=check_car.x+(check_car.width/2)
  local pz2=check_car.z+.2
  if check_collide(px1,pz1,px2,pz2,cx1,cz1,cx2,cz2) then
   return true  
  end
 end
 return false
end

function check_enemy_collide()
 local height,width
 for the_car in all(enemy_car_list) do
  width=the_car.width
  height=the_car.height
  local cx1=the_car.x-width/2
  local cz1=the_car.z
  local cx2=the_car.x+width/2
  local cz2=the_car.z+.2  
  local px1=player_car_x-player_width/2
  local pz1=player_z
  local px2=player_car_x+player_width/2
  local pz2=player_z+.2
  if(check_collide(px1,pz1,px2,pz2,cx1,cz1,cx2,cz2)) then
   if the_car.state==cstate_car then
    create_explosion(the_car.x,the_car.y,the_car.z)
    del(enemy_car_list,the_car)
    return true
   elseif the_car.state==cstate_fuel or the_car.state==cstate_bullets then 
    del(enemy_car_list,the_car)
    if the_car.state==cstate_fuel then
     player_cur_fuel+=10
     create_noticetext(128/2,128/2+10,"+10 fuel",true)
     score+=10
     if player_cur_fuel>player_tot_fuel then player_cur_fuel=player_tot_fuel end
    elseif the_car.state==cstate_bullets then
     bullet_store+=5
     create_noticetext(128/2,128/2+10,"+5 ammo",true)
     score+=10
     if bullet_store>max_bullets then bullet_store=max_bullets end
    end
    sfx(17,2)
    return false  
   end
  end
 end
 return false
end

function change_to_powerup()
 local num=flr(rnd(6)+1)
 if num<=2 then return true else return false end
end

function player_controls()
 local sx=player_car_x
 local tx1=(sx-5)
 local tx2=(sx+5)
 local tz=player_z+bullet_range
 local ty=1
 speed=.15
 if can_start and not player_is_exploded then
  local wtl=player_is_turning_left
  local wtr=player_is_turning_right
  if player_vz>.025 then
   if player_is_turning_right or player_is_turning_left then player_car_anim_timer+=1 end
   player_is_turning_left,player_is_turning_right=false,false
   if btn(1) then
    player_is_turning_right=true
    if player_vz<.30 then
     player_vx-=player_vz*3
    else
     player_vx-=player_drag
    end
   end
   if btn(0) then
    player_is_turning_left=true
    if player_vz<.30 then
     player_vx+=player_vz*3
    else
     player_vx+=player_drag
    end
   end
  end
  if (wtl!=player_is_turning_left or wtr!=player_is_turning_right) or (not player_is_turning_left and not player_is_turning_right) then
   if player_car_anim_timer>player_turn_delay then player_car_anim_timer=0 end
  end
  if not player_is_turning_right and not player_is_turning_left then player_car_anim_timer=0 end
  player_drag=2.8-(player_vz*5)
  if player_drag>4.5 then player_drag=4.5 end
  if player_vx>player_max_vx then player_vx=player_max_vx end
  if player_vx<-player_max_vx then player_vx=-player_max_vx end
  if btn(2) or btn(5) and player_cur_fuel>0 then 
   player_vz+=player_z_speed
   player_drag+=player_z_speed
   if player_vz>player_z_speed_max then 
    player_vz-=player_z_speed
    player_drag-=player_z_speed
   end
   player_fuel_timer+=1
   if player_fuel_timer>=30 then 
    player_cur_fuel-=1.75
    player_fuel_timer=0
    if player_cur_fuel<=0 then player_cur_fuel=0 end
   end
  end
  if btn(3) then 
   player_vz*=.97 
   player_brakes=true
  else
   player_brakes=false
  end
  if btnp(4) and can_fire then
   if bullet_store>0 then 
    if player_car_anim_num==is_right then
     speed*=30
     sx+=5
     tx1=sx+170
     tx2=sx+170
    elseif player_car_anim_num==is_left then
     speed*=30
     sx-=5
     tx1=sx-170
     tx2=sx-170
    elseif player_car_anim_num==is_straight then
     tx1=sx-5
     tx2=sx+5
     speed=.15
    end
    can_fire=false
    create_bullet(sx-5,player_y,1,tx1,tz,speed)
    create_bullet(sx+5,player_y,1,tx2,tz,speed)
    bullet_store-=1
    sfx(15,3)
   else
    sfx(16,3)
   end
  end
  if not can_fire then 
   fire_timer+=1
   if fire_timer>=5 then 
    can_fire=true 
    fire_timer=0
   end 
  end
 end
end

function create_bullet(x,y,z,tx,tz,speed)
 add(bullet_list,{ x=x,y=y,z=z,tx=tx,tz=tz,width=8,height=8,sprite_x=43,sprite_y=80,sprite_width=4,sprite_height=4,speed=speed })
end

function update_bullets()
 local tmp_x,tmp_z,dist
 for b in all(bullet_list) do
  tmp_x=b.tx-b.x
  tmp_z=b.tz-b.z
  dist=sqrt((tmp_x*tmp_x)+(tmp_z*tmp_z))
  tmp_x*=b.speed/dist
  tmp_z*=b.speed/dist
  b.x+=tmp_x
  b.z+=tmp_z
  if b.z>b.tz then del(bullet_list,b) end
  for the_car in all(enemy_car_list) do
   if the_car.state==cstate_car then 
    local cx1=the_car.x-the_car.width/2
    local cz1=the_car.z
    local cx2=the_car.x+the_car.width/2
    local cz2=the_car.z+.2  
    local px1=b.x-b.width/2
    local pz1=b.z
    local px2=b.x+b.width/2
    local pz2=b.z+.2
    if(check_collide(px1,pz1,px2,pz2,cx1,cz1,cx2,cz2)) then
     create_explosion(the_car.x,the_car.y,the_car.z,true)
     if change_to_powerup() then
      if flr(rnd(4)+1)<=2 then the_car.state=cstate_fuel else the_car.state=cstate_bullets end
     else
      del(enemy_car_list,the_car)
     end
     del(bullet_list,b)
     score+=25
    end
   end
  end
  if b.z>b.tz then del(bullet_list,b) end
 end
end

function draw_bullets()
 for b in all(bullet_list) do
  draw_3d_sprite(b.x,b.y,b.z,b.width,b.height,b.sprite_x,b.sprite_y,b.sprite_width,b.sprite_height,false)
 end
end

function reset_level()
 load_level_data(level_detail_num(level))
 camera_x,camera_vz,player_vx,player_vz=0,0,0,0
 player_width,player_height,player_x_friction,player_z_speed,player_z_speed_max,player_z_friction=23,17,.85,.002,.5,.995
 player_x,player_y,player_z=0,-22,.7
 player_anim_wheel_timer,player_anim_wheel_bool,player_anim_accel,player_accel_timer=0,false,0,0
 player_brakes,player_drag,player_car_anim_num,player_car_anim_timer,player_is_turning_left,player_is_turning_right=false,1,2,0,false,false
 player_tot_fuel,player_cur_fuel,player_pct_fuel,player_pct_fuel=100,100,0,0
 player_fuel_pixel,player_fuel_timer,player_alrt_timer,player_alrt_show,player_turn_delay=0,0,0,false
 player_turn_delay,player_max_vx,player_is_visible,player_is_exploded,player_crash_x,player_invuln_timer,player_is_invuln=10,4.5,true,false,0,0,false
 world_z,last_x,last_y,last_z=0,player_x,player_y,world_z
 odds_of_curve,odds_same_curve,curve_strength,current_curve_strength,next_curve_strength=cl_odds_of_curve,cl_odds_same_curve,cl_curve_strength,0,0
 the_curve_strength,total_distance_to_next_curve,distance_to_next_curve=current_curve_strength,10,0
 hud_is_up,indi_left,indi_right,background_scenery_x=false,false,false,0
 stype_bordercount,stype_deccount,scenery_list=0,0,{}
 can_draw_start,race_finished=true,false
 initial_scenery()
 start_timer,can_start,dst,fin_create,lvlendlinetimer,lvlendshowline,player_car_x,score=0,false,0,false,0,0,player_x,0
 explosion_list,pcrash_list,boomshake,text_x,enemy_car_list,time_to_next_car,max_cars={},{},0,128,{},cl_max_car_time,cl_max_cars
 start_beep1,start_beep2,start_beep3,end_engine,play_start,can_fire,fire_timer=false,false,false,false,false,true,0                       
 bullet_list,bullet_range,max_bullets,bullet_store,default_bullet_speed,fin_dist,notice_text={},5,20,20,.15,20,{}
 sfx(0,1)
end

function load_level_data(n)
 cl_terrain_c1=level_details[n].terrain_c1
 cl_terrain_c2=level_details[n].terrain_c2
 cl_curve_strength=level_details[n].curve_strength
 cl_odds_of_curve=level_details[n].odds_of_curve
 cl_odds_same_curve=level_details[n].odds_same_curve
 cl_max_cars=level_details[n].max_cars
 cl_max_car_time=level_details[n].max_car_time
 cl_distance=level_details[n].distance
 cl_backg_c1=level_details[n].backg_c1
 cl_backg_c2=level_details[n].backg_c2
 cl_backg_c3=level_details[n].backg_c3
 cl_s_coll_x=level_details[n].s_coll_x
 cl_s_sprite_x=level_details[n].s_sprite_x
 cl_s_sprite_y=level_details[n].s_sprite_y
 cl_s_width=level_details[n].s_width
 cl_s_height=level_details[n].s_height
 cl_d_col_x=level_details[n].d_col_x
 cl_d_sprite_x=level_details[n].d_sprite_x
 cl_d_sprite_y=level_details[n].d_sprite_y
 cl_d_width=level_details[n].d_width
 cl_d_height=level_details[n].d_height
 cl_s_scale=level_details[n].s_scale
 cl_d_scale=level_details[n].d_scale
end

function create_enemy_car(x,y,z,width,height)
 return {
  x=x,
  y=y,
  z=z,
  old_z=z,
  width=width,
  height=height,
  sprite_x=sprite_x,
  sprite_y=sprite_y,
  sprite_width=width,
  sprite_height=height,
  speed=speed,
  speed=.1,
  ctype=flr(rnd(3)+1),
  state=cstate_car,
  car_anim_num=is_straight,
  anim_wheel_timer=0,
  anim_wheel_bool=false
 }
end

function update_enemy_cars()
 time_to_next_car-=1
 if time_to_next_car<0 then
  if #enemy_car_list<max_cars and can_start and player_vz>0.15 then
   the_car=create_enemy_car(rnd((current_road_width-32))-(current_road_width-32)/2,ground_height,11-rnd(2),23,12)
   while(check_enemy_cars_collide(the_car,false)) do the_car.z+=0.4 end
   the_car.speed=rnd(.2)+.2
   add(enemy_car_list,the_car)
  end
  time_to_next_car=rnd(max_time_to_next_car)
 end
 for the_car in all(enemy_car_list) do
  the_car.old_z=the_car.z
  if the_car.z>15 then
   del(enemy_car_list,the_car)
  end
  the_car.z+=the_car.speed
  the_car.z-=player_vz
  if not race_finished and the_car.state==cstate_car then
   if the_car.old_z>player_z and the_car.z<player_z then sfx(5,2) end
   if the_car.old_z<player_z and the_car.z>player_z then sfx(5,2) end
  end
  the_car.anim_wheel_timer+=1
  if the_car.anim_wheel_timer>1.5 then
   the_car.anim_wheel_timer=0
   the_car.anim_wheel_bool=not the_car.anim_wheel_bool
  end
  if (check_enemy_cars_collide(the_car,false)) do the_car.x-=flr(rnd(4))-2 end
  if the_car.x-the_car.width/2<-current_road_width/2+8 then the_car.x+=1 end
  if the_car.x+the_car.width/2>current_road_width/2-8 then the_car.x-=1 end
  if the_car.z<=-5 or (the_car.z<=0 and the_car.state==cstate_fuel or the_car.state==cstate_ammo) then del(enemy_car_list,the_car) end
 end
end

function draw_enemy_cars()
 local the_car
 local anim_wheelb_x
 sort_scenery(enemy_car_list)
 for the_car in all(enemy_car_list) do
  if the_car.ctype<3 then
   pal(4,car_type_colour[the_car.ctype].c1)
   pal(9,car_type_colour[the_car.ctype].c2)
   pal(10,car_type_colour[the_car.ctype].c3)
  end
  if the_car.state==cstate_car then 
   if the_car.anim_wheel_bool then
    anim_wheelb_x=64
   else
    anim_wheelb_x=67
   end
   if the_car.z<3 then
    if the_car.z<=2 then
     if the_car.x+(the_car.width/2)<player_car_x-(player_width/2) then
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z),the_car.y,the_car.z+.0,(the_car.width+1)*1.4,(the_car.height+3)*1.4,46,104,the_car.width+1,the_car.height+3,false)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)-14,the_car.y+3,the_car.z+.0,4,7,anim_wheelb_x,8,3,5)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)+13,the_car.y+3,the_car.z+.0,4,7,anim_wheelb_x,8,3,5)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)-8,the_car.y+13,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)+14,the_car.y+13,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
     elseif the_car.x-(the_car.width/2)>player_car_x+(player_width/2) then
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z),the_car.y,the_car.z+.0,(the_car.width+1)*1.4,(the_car.height+3)*1.4,46,104,the_car.width+1,the_car.height+3,true)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)-13,the_car.y+3,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)+14,the_car.y+3,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)-14,the_car.y+12,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)+8,the_car.y+13,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
     else
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z),the_car.y,the_car.z+.0,the_car.width*1.4,(the_car.height+2)*1.4,23,104,the_car.width,the_car.height+2,false)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)-13,the_car.y+2,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)+13,the_car.y+2,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)-11,the_car.y+12,the_car.z+.0,2,5,anim_wheelb_x,8,3,5)
      draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)+11,the_car.y+12,the_car.z+.0,2,5,anim_wheelb_x,8,3,5)
     end
    else
     draw_3d_sprite(the_car.x+road_x_at_z(the_car.z),the_car.y,the_car.z+.0,the_car.width*1.4,(the_car.height+2)*1.4,23,104,the_car.width,the_car.height+2,false)
     draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)-13,the_car.y+2,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
     draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)+13,the_car.y+2,the_car.z+.0,3,6,anim_wheelb_x,8,3,5)
     draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)-11,the_car.y+12,the_car.z+.0,2,5,anim_wheelb_x,8,3,5)
     draw_3d_sprite(the_car.x+road_x_at_z(the_car.z)+11,the_car.y+12,the_car.z+.0,2,5,anim_wheelb_x,8,3,5)
    end
   else
    draw_3d_sprite(the_car.x+road_x_at_z(the_car.z),the_car.y,the_car.z+.0,the_car.width*1.4,the_car.height*1.4,0,104,the_car.width,the_car.height,false)
   end
  elseif the_car.state==cstate_fuel then
   draw_3d_sprite(the_car.x+road_x_at_z(the_car.z),the_car.y,the_car.z,10*2,9*2,69,111,10,9)
  elseif the_car.state==cstate_bullets then
   pal(3,8)
   pal(11,14)
   draw_3d_sprite(the_car.x+road_x_at_z(the_car.z),the_car.y,the_car.z,10*2,9*2,69,111,10,9)
   pal()
  end
  if the_car.ctype<3 then
   pal()
  end
 end
end

function create_explosion(x,y,z,is_moving)
 for i=0,40 do
  add(pcrash_list,create_particle(x,y,z))
 end
 add(explosion_list,{ x=x,y=y,z=z,sprite_x=35,sprite_y=84,timer=0,frame=0,scale=1,is_moving=is_moving })
 boomshake+=0.5
 sfx(4,2)
end

function create_particle(x,y,z) 
 local angle=rnd()
 local speed=.01+rnd(2)+1
 return {
  x=x,
  y=y,
  z=z,
  sprite_x=0,
  sprite_y=80,
  dx=sin(angle)*speed,
  dy=cos(angle)*speed,
  dz=sin(angle)*speed,
  age=flr(rnd(25)),
  scale=1
 }
end

function update_explosions()
 for e in all(explosion_list) do
  screenshake()
  e.timer+=1
  if e.timer>=6 then
   e.timer=0
   if e.frame>=5 then
    del(explosion_list,e)
   else
    if e.is_moving then e.z-=player_vz*1.17 end
    e.sprite_x+=15
    e.frame+=1
    e.scale+=.5
   end
  end
 end
end

function update_particles()
 for p in all(pcrash_list) do
  if p.age>120 or p.y<ground_height then
   del(pcrash_list,p)
  else
   p.x+=p.dx
   p.y+=p.dy
   p.age+=1
   p.dy-=0.04
   p.scale+=0.05
  end
 end
end

function draw_explosions()
 for e in all(explosion_list) do
  palt(14,true)
  pal(9,rnd(7)+8)
  draw_3d_sprite(e.x+road_x_at_z(e.z),e.y,e.z,e.scale*15,e.scale*15,e.sprite_x,e.sprite_y,15,15,false)
  pal()
 end
end

function draw_particles()
 for p in all(pcrash_list) do
  pal(5,rnd(7)+8)
  draw_3d_sprite(p.x+road_x_at_z(p.z),p.y,p.z,p.scale*2,p.scale*2,p.sprite_x,p.sprite_y,2,2,false)
  pal()
 end
end

function reset_game()
 level,hiscore_check,has_hiscore,hud_y,total_score,gameover=1,false,false,110,0,false
 reset_level()
end

function draw_scenery()
 local at_start=false
 for the_scenery in all(scenery_list) do
  if the_scenery.stype==stype_start then
   at_start=true
   if not can_start and state==state_game then
    start_timer+=1
   end
   if start_timer>=160 then
    if not start_beep1 then sfx(1,3) start_beep1=true end
    pal(2,8)
   end
   if start_timer>=320 then
    if not start_beep2 then sfx(1,3) start_beep2=true end
    pal(4,9)
   end
   if start_timer>=480 then
    if not start_beep3 then sfx(2,3) start_beep3=true end
    pal(3,11)
    can_start=true
   end
  end
  if the_scenery.stype==stype_end then
   pal(15,rnd(7)+8)
  end
  draw_3d_sprite(the_scenery.x+road_x_at_z(the_scenery.z),the_scenery.y,the_scenery.z,the_scenery.width,the_scenery.height,the_scenery.sprite_x,the_scenery.sprite_y,the_scenery.sprite_width,the_scenery.sprite_height,the_scenery.b_flip)
 end
 pal()
 if at_start then
  if not play_start and state==state_game then 
   play_start=true
   sfx(13,3)
  end
  if not can_start and state==state_game then
   if text_x>0-(#start_text*4) then 
    text_x-=1.5
    dropshadow_text(start_text,text_x,128/2,1,rnd(7)+8)
   end
  end
 end
 if race_finished and text_x>0-(#finish_text*4) then
  text_x-=1.5
  dropshadow_text(finish_text,text_x,128/2,1,rnd(7)+8)
 end
end

function _init()
 cls()
 load_hiscore()
 reset_title()
end

function reset_title()
 frame,t_flash_start,t_display_start,world_z,camera_x,the_curve_strength=0,0,false,0,0,0
 cl_backg_c1,cl_backg_c2,cl_backg_c3,cl_terrain_c1,cl_terrain_c2=0,0,0,0,0
 t_t1_x,t_t2_x=-60,128
 is_t1,is_t2,t_showstart,t_grid_start=false,false,false,5
 t_grid_lineh={}
 t_grid_lineh.movenum={}
 t_grid_lastime,t_grid_startlinenum=time(),0
 t_grid_linecontl,t_grid_linecontr,t_grid_linenuml,t_grid_linenumr={},{},0,0
 t_grid_vertnum=t_grid_start
 t_grid_hozdir=false
 t_grid_mover=0
 t_grid_lineeach=t_grid_start
end

function update_title()
 local half_screen_t1=128/2-(60/2)
 local half_screen_t2=128/2-(80/2)
 if t_t1_x<=half_screen_t1 and not is_t1 then
  t_t1_x+=4
 else
  is_t1=true
 end
 if t_t2_x>=half_screen_t2 and not is_t2 then
  t_t2_x-=4.75
 else
  is_t2=true
 end
 if is_t1 and is_t2 and not t_showstart then 
  t_t1_x=half_screen_t1
  t_t2_x=half_screen_t2
  t_showstart=true 
 end
 t_flash_start+=1
 if t_flash_start>10 then
  t_flash_start=0
  t_display_start=not t_display_start
 end

 t_flash_start+=1
 if t_flash_start>10 then
  t_flash_start=0
  t_display_start=not t_display_start
 end
 if btnp(4) then
  start_game()
 end
end

function update_player()
 if player_car_anim_timer>player_turn_delay then
  if player_is_turning_right then player_car_anim_num=is_right end
  if player_is_turning_left then player_car_anim_num=is_left end
 else
  player_car_anim_num=is_straight
 end
 player_accel_timer=1-(player_vz*2)
 player_accel_timer=player_accel_timer*5*2/2.2
 player_anim_wheel_timer+=1
 if player_vz>.003 then 
  if player_anim_wheel_timer>player_accel_timer then
   player_anim_wheel_timer=0
   player_anim_wheel_bool=not player_anim_wheel_bool
  end
 end
end

function start_game()
 reset_game()
 state=state_game
end 

function update_game()
 if not race_finished then player_controls() end
 process_game_update()
 update_enemy_cars()
 update_player()
 update_scenery()
 update_bullets()
 update_explosions()
 update_particles()
 update_hud()
 update_noticetext()
 engine_sound(player_vz*3)
end

function engine_sound(speed)
 local sspd=speed*3
 if not race_finished and player_cur_fuel>0 then
  if (sspd>=1) sspd=speed*1.2
  if (sspd>=1) sspd=speed*0.7
  if (sspd>=1) sspd=speed*0.49
  sspd=sspd-flr(sspd)+speed/5
  poke(0x3200,sspd*20)
  poke(0x3202,sspd*18)
 else
  sfx(-2,1)
  if not end_engine then 
   end_engine=true
   sfx(3,2)
   if race_finished then sfx(18,1) end
  end
 end
end

function update_hud()
 if player_vz>0 then
  score+=flr(1*flr(player_vz*10)/2)
 end
 if next_curve_strength>2 then
  if not indi_right then sfx(10,3) end
  indi_left,indi_right=false,true
 elseif next_curve_strength<-2 then
  if not indi_left then sfx(10,3) end
  indi_left,indi_right=true,false
 else
  indi_left,indi_right=false,false
 end
 player_pct_fuel=100-(player_tot_fuel-player_cur_fuel)
 player_fuel_pixel=flr((player_pct_fuel/100)*8)
 if player_pct_fuel<=25 or bullet_store<=5 then
  player_alrt_timer+=1
  if player_alrt_timer>10 then
   player_alrt_timer=0
   player_alrt_show=not player_alrt_show
   if player_alrt_show then sfx(9,3) end
  end
 end
end

function _update()
 if state==state_start then
  update_title()
 elseif state==state_game then
  update_game()
 elseif state==state_levelend then
  update_levelend()
 elseif state==state_levelstart then
  update_levelstart()
 elseif state==state_complete then
  update_completed()
 end 
end

function update_completed()
 check_hiscore()
 if btnp(1) or btnp(2) or btnp(3) or btnp(4) or btn(5) then
  reset_title()
  state=state_start
 end
end

function check_hiscore()
 if not hiscore_check then 
  if total_score>high_score then
   save_hiscore()
   has_hiscore=true
  end
  hiscore_check=true
 end
end

function load_hiscore()
 cartdata("arashi256_the_node_roadstorm_1_0")
 --dset(0,0)
 high_score=dget(0)
end

function save_hiscore()
 high_score=total_score
 dset(0,high_score)
end

function draw_completed()
 fancy_text((128/2)-((#complete_text*4)/2),128/2-30,complete_text,4,10)
 dropshadow_text("you have completed road storm!",5,60,5,7)
 dropshadow_text("your final score is...",5,66,5,7)
 dropshadow_text(format_number(total_score,4),128/2-((5*4)/2),80,5,rnd(7)+8)
 if has_hiscore then
  dropshadow_text("new high score!",128/2-((15*4)/2),95,8,9)
 end
 dropshadow_text("press any key to finish",128/2-((23*4)/2),120,5,7)
end

function update_levelstart()
 engine_sound(0)
 hud_y+=2
 update_hud()
 if hud_y>=110 then 
  hud_y=110
  state=state_game
 end
end

function draw_levelstart()
 draw_background(1)
 draw_background_scenery()
 draw_road()
 draw_scenery()
 draw_player()
 palt(0,false)
 rectfill(0,127,127,hud_y+18,0)
 palt()
 draw_hud()
 spr(128,0,hud_y+18)
 spr(128,128-8,hud_y+18,1,1,true,false)
 for x=1,14 do
  spr(129,8*x,hud_y+18) 
 end
 for y=3,14 do
  spr(144,0,hud_y+(8*y))
  spr(144,120,hud_y+(8*y),1,1,true,false) 
 end
 spr(128,0,hud_y+120,1,1,false,true)
 spr(128,128-8,hud_y+120,1,1,true,true)
 for x=1,14 do
  spr(129,8*x,hud_y+120,1,1,false,true)
 end
end

function update_levelend()
 local score_inc
 if not hud_is_up then
  player_alrt_show=false
  hud_y-=2
  if hud_y<=0 then 
   hud_is_up,next_line,levelscorecount,lvlendshowline,count_timer,distcount,temp_score=true,true,0,0,0,0,total_score
  end
 else
  if lvlendshowline<=8 then
   if next_line then
    lvlendlinetimer+=1
    if lvlendlinetimer>=30 then
     lvlendlinetimer=0
     lvlendshowline+=1
     next_line=false
     if lvlendshowline>1 and lvlendshowline<5 or lvlendshowline==6 then sfx(8,3) end
    end
   else
    if lvlendshowline==1 then
     if not gameover then 
      sfx(7,1)
     else
      sfx(11,1)
     end
     next_line=true
    elseif lvlendshowline==2 then
     count_timer+=1
     if count_timer>=5 then
      count_timer=0
      if levelscorecount+1<=score then
       score_inc=returncountdigits(levelscorecount-score)
       levelscorecount+=score_inc
       sfx(6,3)
      else
       next_line=true
      end
     end
    elseif lvlendshowline==3 then
     count_timer+=1
     if count_timer>=5 then
      count_timer=0
      if distcount+1<=dst then
       score_inc=returncountdigits(distcount-dst)
       distcount+=score_inc
       sfx(6,3)
      else
       next_line=true
      end
     end
    elseif lvlendshowline==4 then
     count_timer+=1
     if count_timer>=5 then
      count_timer=0
      if total_score+1<=temp_score+score+dst then
       score_inc=returncountdigits(total_score-(temp_score+score+dst))
       total_score+=score_inc
       sfx(6,3)
      else
       next_line=true
      end
     end
    elseif lvlendshowline==5 then
     if gameover then 
      check_hiscore() 
      if has_hiscore then
       sfx(17,3)
      end
     end
     next_line=true
    else
     next_line=true
    end
   end
  else
   if not gameover then
    level+=1
    if level>12 then
     state=state_complete
    else
     reset_level()
     state=state_levelstart
    end
   else
    reset_title()
    state=state_start
   end
  end
 end
end

function returncountdigits(num)
 if countdigits(num)==1 then return 1 end
 if countdigits(num)==2 then return 1 end
 if countdigits(num)==3 then return 10 end
 if countdigits(num)==4 then return 100 end
 if countdigits(num)==5 then return 1000 end
end

function countdigits(n)
 local count,num,isneg=0,0,false
 if n<0 then
  num=abs(n)
  isneg=true
 else
  num=n
 end
 if num==0 then
  return 1
 else
  while num>0 do
   num=flr(num/10)
   count=count+1
  end
  if isneg==true then
   return count+1
  else
   return count
  end
 end
end

function draw_levelend()
 local c1,c2,c3,c4
 if not gameover then
  c1,c2,c3,c4,lvlend_string1,lvlend_string5=3,11,8,10,"stage complete","prepare for next race!"
 else
  c1,c2,c3,c4,lvlend_string1,lvlend_string5,lvlend_string6=2,8,5,7,"game over","please wait","new high score!"
 end
 if not hud_is_up then
  draw_background(1)
  draw_background_scenery()
  draw_road()
  draw_player()
  draw_scenery()
  palt(0,false)
  rectfill(0,127,127,hud_y+18,0)
  palt()
 else
  rectfill(0,0,128,128,1)
  if lvlendshowline>=1 then
   fancy_text((128/2)-((#lvlend_string1*4)/2),128/2-30,lvlend_string1,c1,c2)
  end
  if lvlendshowline>=2 then
   lvlend_string2="score:           "..format_number(levelscorecount,4)
   dropshadow_text(lvlend_string2,20,60,5,7)
  end
  if lvlendshowline>=3 then
   lvlend_string3="distance:         "..format_number(distcount,3)
   dropshadow_text(lvlend_string3,20,70,5,7)
  end
  if lvlendshowline>=4 then
   lvlend_string4="total score:     "..format_number(total_score,4)
   dropshadow_text(lvlend_string4,20,80,5,7)
  end
  if lvlendshowline>=5 and gameover then
   if has_hiscore then dropshadow_text(lvlend_string6,128/2-((#lvlend_string6*4)/2),93,8,9) end
  end
  if lvlendshowline>=6 then
   fancy_text((128/2)-((#lvlend_string5*4)/2),105,lvlend_string5,8,10)
  end
 end
 draw_hud()
 spr(128,0,hud_y+18)
 spr(128,128-8,hud_y+18,1,1,true,false)
 for x=1,14 do
  spr(129,8*x,hud_y+18) 
 end
 for y=3,14 do
  spr(144,0,hud_y+(8*y))
  spr(144,120,hud_y+(8*y),1,1,true,false) 
 end
 spr(128,0,hud_y+120,1,1,false,true)
 spr(128,128-8,hud_y+120,1,1,true,true)
 for x=1,14 do
  spr(129,8*x,hud_y+120,1,1,false,true)
 end
end

function draw_title()
 print("v"..version,1,1,7)
 sspr(19,119,9,6,128-45,1)
 dropshadow_text("nodesoft",128-33,1,1,12)
 draw_grid()
 dropshadow_text("high score: "..format_number(high_score,4),128/2-((17*4)/2),128/2+20,5,7)
 sspr(51,50,60,13,t_t1_x,15)
 sspr(42,63,80,15,t_t2_x,30)
 if t_display_start then
  fancy_text(128/2-(#t_start_text*4)/2,100,t_start_text,8,10)
 end
end

function fancy_text(x,y,s,c1,c2)
 local offset=1
 x+=rnd(z)
 y+=rnd(z) 
 for _x=-offset,offset do
  for _y=-offset,offset do
   print(s,x+_x,y+_y,c1)
  end
 end
 print(s,x,y,c2)
end

function draw_background(clear)
 rectfill(0,0,128,128,1)
 rectfill(0,66,128,128,13)
 rectfill(0,55-hud_offset,128,66-hud_offset,cl_backg_c1)
 rectfill(0,45-hud_offset,128,55-hud_offset,cl_backg_c2)
 rectfill(0,37-hud_offset,128,47-hud_offset,cl_backg_c3)
 line(0,54-hud_offset,128,54-hud_offset,cl_backg_c1)
 line(0,52-hud_offset,128,52-hud_offset)
 line(0,46-hud_offset,128,46-hud_offset,cl_backg_c2)
 line(0,44-hud_offset,128,44-hud_offset)
 line(0,42-hud_offset,128,42-hud_offset)
 line(0,35-hud_offset,128,35-hud_offset,cl_backg_c3)
 line(0,33-hud_offset,128,33-hud_offset)
 line(0,31-hud_offset,128,31-hud_offset)
end

function draw_background_scenery()
 local remainder=0
 if background_scenery_x<-128 then background_scenery_x+=128 end
 if background_scenery_x>128 then background_scenery_x-=128 end
 background_scenery_x-=the_curve_strength*.5*player_vz
 sspr(0,43,128,8,flr(background_scenery_x),40)
 if background_scenery_x<0 then
  remainder=128+flr(background_scenery_x)
  remainder=128-remainder
  sspr(0,43,remainder,8,background_scenery_x+128,40)
 end
 if background_scenery_x+128>128 then
  remainder=(background_scenery_x+128)-128
  sspr(128-remainder,43,remainder,8,background_scenery_x-remainder,40)
 end
end

function draw_game()
 draw_background(1)
 draw_background_scenery()
 draw_road()
 draw_enemy_cars()
 draw_scenery()
 draw_explosions()
 draw_bullets()
 draw_player()
 draw_particles()
 draw_noticetext()
 draw_hud()
end

function draw_hud()
 local spd_x,spd_y,dist_x,dist_y,ammo_x,ammo_y,sy,height,fuel_clr=20,hud_y+7,105,hud_y+7,77,hud_y+7,110,29,3
 dropshadow_text("total: "..format_number(total_score,4),2,2,5,7)
 dropshadow_text("stage: "..format_number(score,4),2,8,5,7)
 dropshadow_text("race: "..get_stage(level),90,2,5,7)
 palt(15,true)
 palt(0,false)
 sspr(0,24,128,20,0,hud_y)
 palt(0,false)
 print("888",spd_x,spd_y,1)
 print("spd ",spd_x-13,spd_y,7)
 print(format_number(flr(player_vz*500),2),spd_x,spd_y,8)
 print("8888",dist_x,dist_y,1)
 print("dst ",dist_x-13,dist_y,7)
 print(format_number(dst,3),dist_x,dist_y,8)
 print("88",ammo_x,ammo_y,1)
 if bullet_store>=5 then print(format_number(bullet_store,1),ammo_x,ammo_y,10) end
 if player_alrt_show and bullet_store<=5 then 
  print(format_number(bullet_store,1),ammo_x,ammo_y,8) 
  palt(0,true)
  sspr(48,16,12,5,56,hud_y+5)
 end
 pal()
 if indi_right then sspr(95,9,8,9,64,hud_y+5) end
 if indi_left then sspr(95,0,8,9,52,hud_y+5) end
 if player_vz<0.001 then player_vz=0 end
 if player_cur_fuel>0 then
  if  player_pct_fuel<=50 then fuel_clr=9 end
  if  player_pct_fuel<=25 then fuel_clr=8 end
  rectfill(38,hud_y+13,48,hud_y+13-player_fuel_pixel,fuel_clr)
 end
 if player_alrt_show and player_pct_fuel<=25 then
  sspr(48,16,12,5,56,hud_y+5)
  if player_cur_fuel==0 then print("e",42,hud_y+7,7) end
 end
end

function get_stage(level)
 local remainder=0
 local world=level%3
 local stage=level%3
 if world==0 then
  remainder=level/3
  remainder=(remainder*3)/3
  world=level/remainder
 end
 if stage==0 then 
  stage=world
 end
 return level_detail_num(level).."-"..stage
end

function dropshadow_text(string,x,y,c1,c2)
 print(string,x,y,c1)
 print(string,x+1,y,c2)
end

function draw_player()
 local p_w1,p_w2,p_w3,p_w4,p_sx
 local pflip=false
 local anim_wheelb_x
 if player_brakes then
  pal(3,11)
 else
  pal()
 end
 if player_anim_wheel_bool then
  anim_wheelb_x=64
 else
  anim_wheelb_x=67
 end
 if player_car_anim_num==is_straight then
  p_w1,p_w2,p_w3,p_w4,p_sx,pflip=9.5,9,8,7.5,72,false
 elseif player_car_anim_num==is_left then 
  p_w1,p_w2,p_w3,p_w4,p_sx,pflip=9.5,9,9.5,6.5,103,false
 elseif player_car_anim_num==is_right then
  p_w1,p_w2,p_w3,p_w4,p_sx,pflip=9.5,9,6.5,9.5,103,true
 end
 if player_is_visible then
  draw_3d_sprite(player_car_x+road_x_at_z(player_z),player_y,player_z+.0,player_width,player_height,p_sx,player_sprite_y,player_width,player_height,pflip)
  draw_3d_sprite(player_car_x+road_x_at_z(player_z)-p_w1,player_y+2,player_z+.0,3,5,anim_wheelb_x,8,2,5)
  draw_3d_sprite(player_car_x+road_x_at_z(player_z)+p_w2,player_y+2,player_z+.0,3,5,anim_wheelb_x,8,2,5)
  draw_3d_sprite(player_car_x+road_x_at_z(player_z)-p_w3,player_y+10,player_z+.0,2,4,anim_wheelb_x,8,3,4)
  draw_3d_sprite(player_car_x+road_x_at_z(player_z)+p_w4,player_y+10,player_z+.0,2,4,anim_wheelb_x,8,2,4)
 end
end

function _draw()
 cls()
 if state==state_start then
  draw_title()
 elseif state==state_game then
  draw_game()
 elseif state==state_levelend then
  draw_levelend()
 elseif state==state_levelstart then
  draw_levelstart()
 elseif state==state_complete then
  draw_completed()
 end
end

function screenshake()
 local shakex=16-rnd(32)
 local shakey=16-rnd(32)
 shakex*=boomshake
 shakey*=boomshake
 camera(shakex,shakey)
 boomshake=boomshake*0.90
 if boomshake<0.05 then boomshake=0 end
end

function draw_grid_horz(n)
 local lines
 for i=1,800 do
  if i<n then
   t_grid_lineh.movenum[i]=(t_grid_lineh.movenum[i]*1.15)/1.1
   t_grid_lineeach=t_grid_lineh.movenum[i]
   if (t_grid_lineeach<168) then
    t_grid_lineeach=t_grid_lineeach
   else 
    t_grid_lineeach=168
   end
  else
   t_grid_lineh.movenum[i]=t_grid_start
  end 
  lines=line(0,((t_grid_lineeach+(t_grid_mover/20))+65),180,((t_grid_lineeach-(t_grid_mover/20))+65),11)
 end  
 line(0,((t_grid_start+(t_grid_mover/20))+65),180,((t_grid_start-(t_grid_mover/20))+65),11)
end

function draw_grid_vert()
 for i=5,1,-1 do
  t_grid_linecontl[i]=(t_grid_linenuml*i)*i
  line(64,(t_grid_start+65),((t_grid_linecontl[i]+60)+t_grid_mover),128,11)
 end 
 for i=1,5,1 do
  t_grid_linecontr[i]=(t_grid_linenumr*i)*i
  line(64,(t_grid_start+65),((t_grid_linecontr[i]+60)+t_grid_mover),128,11)
 end 
 if t_grid_linenuml<40 and t_grid_linenumr>-40 then
  t_grid_linenuml+=1
  t_grid_linenumr-=1
 end
end

function draw_grid()
 camera(0,-65)
 rectfill(0,2,127,4,10)
 rectfill(0,-4,127,1,14)
 rectfill(0,-11,127,-5,2)
 rectfill(0,-18,127,-12,1)
 line(0,0,127,0,10)
 line(0,-2,127,-2,10)
 line(0,-6,127,-6,14)
 line(0,-8,127,-8,14)
 line(0,-13,127,-13,2)
 line(0,-15,127,-15,2)
 line(0,-20,127,-20,1)
 line(0,-22,127,-22,1)
 camera()
 if time()-t_grid_lastime>.20  then
  t_grid_startlinenum+=1
 if t_grid_start>39 and not t_grid_hozdir then
  t_grid_start+=1
  t_grid_hozdir=true
 elseif t_grid_start>=70 and t_grid_hozdir then
  t_grid_start-=1
  t_grid_hozdir=false
 end
 t_grid_lastime=time()
 end
 draw_grid_horz(t_grid_startlinenum)
 draw_grid_vert()
end
__gfx__
777dddddddddddddddddddddddddddddddddddddddddd7776666666666666666cc0cc0cc00000000700000700000000900000000000070000070000000000000
777dddddddddddd77dddddddddddddd77dddddddddddd7776666666666666666cc0cc0cc00000006760006760000000990000000000676000676000000000000
777dddddddddddd77dddddddddddddd77dddddddddddd77766666666666666660000000000018a86569a96568a810009a900000018a86569a96568a810000000
777dddddddddddd77dddddddddddddd77dddddddddddd7776666666666666666000cc0000011a882659a956288a11009aa9000011a882659a956288a11000000
777dddddddddddd77dddddddddddddd77dddddddddddd7776666666666666666000cc0000011922c5222225c22911009aaa900011922c5222225c28911000000
777dddddddddddd77dddddddddddddd77dddddddddddd777666666666666666600000000001182c22c676c22c28110097aaa9001182c22cc676ccc2811000000
777dddddddddddd77dddddddddddddd77dddddddddddd77766666666666666660000000000118822c67776c2288110097aaaa90118822cc67776c28211000000
777dddddddddddddddddddddddddddddddddddddddddd777666666666666666600000000000082882222222882800009777aaa90008282222222282820000000
888dddddddddddddddddddddddddddddddddddddddddd88855555555555555551112220000002888889a988888200009999999900028888889a9888882000000
888dddddddddddddddddddddddddddddddddddddddddd8885555555555555555111ddd0001118888222222288881110000000090111888822222228888111000
888dddddddddddddddddddddddddddddddddddddddddd8885555555555555555ddd11100111a883385555583388a11100000099111a883385555583388a11100
888dddddddddddddddddddddddddddddddddddddddddd88855555555555555552221110011198833822222833889111000009a91119883382222283388911100
888dddddddddddddddddddddddddddddddddddddddddd88855555555555555551111110011188888889a9888888811100009aa911188888889a9888888811100
888dddddddddddddddddddddddddddddddddddddddddd888555555555555555500000000111822722222222272281110009aa791118227222222222722811100
888dddddddddddddddddddddddddddddddddddddddddd88855555555555555550000000011125676589a98567652111009aaa7911125676589a9856765211100
888dddddddddddddddddddddddddddddddddddddddddd8885555555555555555000000000111611160000061116111009aaaa790111611160000061116111000
eee770077007700770077007700770077007700770077eee888888888888000000aaaa00000006760000000676000009aa777790000067600000006760000000
eee770077007700770077007700770077007700770077eee08eeeeeeee800000aaaaaaaa00000000000000000000000999999990000000000000000000000000
eee007700770077007700770077007700770077007700eee008e7777e8000000caaaaaac00000000000000000000000000000000000000000000000000000000
eee007700770077007700770077007700770077007700eee0008eeee80000000cccccccc00000000000000000000000000000000000000000000000000000000
eee770077007700770077007700770077007700770077eee00008888000000000cccccc000000000000000000000000000000000000000000000000000000000
eee00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee770077007700770077007700770077007700770077eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
fff77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777fff
ff7555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555557ff
f756666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666657f
75666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666657
5666ddddddddddddddddddddddddddddddd66ddddddddddddd6d766dddddddddddddd667d6ddddddddddddd66ddddddddddddddddddddddddddddddddddd6665
6666d00000000000000000000000000000766d0000000000076d476d2222222222227674d6d00000000000766d00000000000000000000000000000000076666
6666d00000000000000000000000000000766d0000000000076d4476d222222222276744d6d00000000000766d00000000000000000000000000000000076666
6767d00000000000000000000000000000776d0000000000076d44476d22222222777444d7d00000000000776d00000000000000000000000000000000077676
7676d00000000000000000000000000000767d0000000000077d444476d2222227774444d6d00000000000767d00000000000000000000000000000000076767
7777d00000000000000000000000000000777d0000000000077d4444477d222277744444d7d00000000000777d00000000000000000000000000000000077777
7777d00000000000000000000000000000777d0000000000077d44444477777777444444d7d00000000000777d00000000000000000000000000000000077777
6767d00000000000000000000000000000776d0000000000076d44444447676774444444d7d00000000000776d00000000000000000000000000000000077676
7676d00000000000000000000000000000767d0000000000077d44444444767744444444d6d00000000000767d00000000000000000000000000000000076767
6666d00000000000000000000000000000766d0000000000076d44444444766744444444d6d00000000000766d00000000000000000000000000000000076666
6666d77777777777777777777777777777766d7777777777776d77777777766777777777d6d77777777777766d77777777777777777777777777777777776666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
00000077777000000000007700000000000000000000670000000000000777777770000000000000000000000000067000000000000077777777000000000000
0000006cdc7077770000066670055000007777000000670000050000700666666670070000000005000777700000067000005000070066666667007000777700
07777066667066670550ccdcdc055050056dc7555500cd07770500006706cdcdcdc00600050055550056dc7550000cd07770500006706cdcdcdc0060006dc755
06dc706cdc756cd70550066670055550056667677770675667055005cd56666666700607055555550056667677770670667555555cd566666667556070666755
56667566667566675550006700055550056dc76dcc70cd5dc77777756756cdcdcdc55657055555555556dc76dcc75cd0dc77777756756cdcdcdc5565706dc755
56dc756cdc756cd75555556755666666676667666675675667666675cd56666666777667555666666676667666675675667666675cd566666667776675666755
56667566667566675ccd6567556cdcdc676dc76dcc75cd5dc7dccd756756cdcdcdc66dc75556cdcdc676dc76dcc75cd5dc7dccd756756cdcdcdc66dc756dc755
5666756666766cd75666656755666666676666666675675666666675676666666676666755566666667666666667567566666667567666666667666675666655
00000111111110000000000011110000000000000000000000000008888888888880000000000000000000000000000000000000000000000000000000000000
000017757557511000000001b3bb1100000000000000000000000008cccccccccc88000000000000000000000000000000000008888880000000000000000000
001177775577775100000001b333bb10000000000000000000000008cccc8888ccc8000000000000000088888888880000000008cccc80000000000000000000
01755777577776751000000013333b10000000000000000000000088cccc808cccc800888888888800008cccccccc80000000008cccc88000000000000000000
16675575777766661000000111133bb100000000000000000000008cccc8888cccc8088cccccccc888008cccccccc880008888888cccc8000000000000000000
16566677777666661000011bbbb133b1000110000000000000000087777777777888877778888777780088888887777800877777777778000000000000000000
165556666666655610001bbb33bb33bb111bb1000000000000000087777777777800877778008777780008888887777888877777777778000000000000000000
16655555665555651001bb33bb33333b1bbbbb100000000000000087777777788800877778008777780887777777777887777888877778000000000000000000
0166566565566551001bb33b11b33bbbbb333bb10000000000000081111881111800811118008111188111188881111881111800811118000000000000000000
0015666665556610001b311113b3b3b3333333b10000000000000081111881111888811118888111188111188881111881111888811118800000000000000000
000000000000000001b33100133333333331bb3b100000000000088dddd8888dddd8888dddddddd888088dddddddddd8088ddddddddddd800000000000000000
000000000000000001b3100113b4333bbb101133b1000000000008dddd8008ddddd8008dddddddd800008dddddddddd8008ddddddddddd800000000000000000
0000000000000000013310133b4444333bb101bb3100000000000888888008888888008888888888000088888888888800888888888888800000000000000000
00000000000000000011013bb144493133bb101b3100000888888888800000000000000000000000000000000000000000000000000000000000000000000000
6666666666666666000013b111949131133bb10131008888cccccccc888000088888800000000000000000000000000000000000000000000000000000000000
666666666666666600001331014991100133b10010008ccccc8888cccc800008cccc800000000000000000000000000000000000000000000000000000000000
6666666666666666000001101944910001b3310000008cccc8808ccccc888888cccc888880008888888888008888888888888008888888008888880000000000
66657777777777770000000014491000001b100000008cccc80088888888cccccccccccc80008cccccccc8008ccccccccccc8008ccccc8008cccc80000000000
66650000000000000000000014491000001310000000877778888888000877777777777788888777777778888777777777778888777778888777788880000000
66650000000000000000000194910000000100000000888777777778000888887777888888777778888777788777778888777788877777777777777780000000
66650000000000000000000144910000000000000000087777777778880000087777800008777778008777788877778008777780877777777777777780000000
66650000000000000000000149910000000000000000088888888111180000881111800008111118008111180811118008888880811111111111111180000000
66650000000000000000000144910000000000000008888880088111180000811111800008111118008111180811118000000000811111111111111188000000
66650000000000000000001949100000000000000088111180081111180000811111800008111118008111180811118000000000811118881188111118000000
6665000000000000000000194910000000000000008ddddd8888ddddd800008ddddd888888ddddd8888dddd808dddd80000000008ddddd88dd88ddddd8000000
666500000000000000000014991000000000000000888ddddddddd88880000888ddddddd8888ddddddddd88808dddd80000000008ddddd8888888dddd8000000
666500000000000000000014491000000000000000008ddddddddd80000000008ddddddd8008ddddddddd80008dddd80000000008ddddd8000008dddd8000000
66650000000000000000001499100000000000000000888888888880000000008888888880088888888888000888888000000000888888800000888888000000
66650000000000000000014449100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66650000000000000000019499100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55000000000000000000019449910000000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000
55000000000000000000014444910000000000000008aa8000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000194449910000000000000008aa8000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000194444991000000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777000007777700000777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55545552eeeeeeeee255552eeeee000
0008c000662227700066444770006633377eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9ee9eeeeeeee44444444eeeeee5545400000552eeeee5552525522ee000
00065777627722777764774477776377337eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee89999999955eee4459944499111eee4594440000555eee5555555555eee000
00068998627222755564744475556373337eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee999a999999999e45999944994444e249944404000055ee522eee222eeee000
00065665622222756664444475666333337eeeeeeeeeeeeeeeeeeee999eeeeeeeaa779999899999e49994444444444e249544094400005eee2e2ee2eeeeee000
00065000662226700066444670006633367eeeeeeeeeeeeeeeeee499999e9eeeeaa79aa99a99999944555949a94454125455944944405eeeeeeeee2eeeeee000
00650000066666000006666600000666660eeee9999eeeeeeeeea779979999aeeea99aa99f799999e44459aa9a9455125544949994402eeeeeeeee2eeeeee000
00650000077777777777777777777777770eee999999aeeeeeeaaa799f79999aee99899a9aa9594ee59999a4aa9455e2555994494405eeeeeeeeeeeeeeeee000
0065000066ffff666ffff6666ff666ff667ee999a9aaaaeeeeea7799997f999aeeaa98aa9994115ee99999a544445eee2555945500052eeeeeeeeeeeeeeee000
006500006ff66ff6ff66ff66ffff66ff667ee99aaaf77aeeeeea7999999799aaee9a99aaa4488855e99999a55555511e2555494444002eeeeeeeeeeeeeeee000
006500006ff66666ff66ff6ff66ff6ff667ee9aaaa77aaaeeee77999799999aaee9999a7aaaa811ee5599aa9944411eee254994444002eeeeeeeeeeeeeeee000
006500006ff6fff6ff66ff6ffffff6ff667ee9a777777aaaeee77999779999aaeee99aaaaaaa115eee11aaaa944111ee525499940005eeeeeeeeeeeeeeeee000
006500006ff66ff6ff66ff6ff66ff6ff667eeaa7777777aaeeea7997779aa7aeeee999aaaaa115eeee511aaaa4111ee2555549440005eeeeeeeeeeeeeeeee000
0065000066ffff666ffff66ff66ff6fff67eeea7777777aaeeeeaaa7777a7aeeeeee888aa55111eeee5511aa41111ee2255555555555eeeeeeeeeeeeeeeee000
00650000066666666666666666666666660eeee7777777aeeeeeea777777aeeeeeee8888885555eeeee55511111111ee2555555555552eeeeeeeeeeeeeeee000
06650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111000000111100000
06500000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000177777777777777100001b3bb10000
06500000000000000000000000000000000000000000000000000000000000000000000000000000000000013310000110155555555555557100001bbb310000
065000000000000000000000000000000000000000000000000000000000000000000000000000000000001333b1001bb1157c57c57c57c57100013b33bb1000
666600000000000000000000000000000000000000000000000000000000000000000000000000000000001313b1001b31157c57c57c57c5710001b3333b1000
00001199444444499110000000000009aaaaa900000000000000000009aaaaa9000000000000000000000013331111b311157c57c57c57c571001b31b313b100
0001199944999449991100000011449aaaaaaa9441100000000011449aaaaaaa94411000000000000000001333b1b13131157757757757757101b311b3113b10
0001a9444444444449a10000011149a4444444a94111000000011149a4444444a9411100000000000000001331b1b33310155555555555557101310133101310
0001aa99999999999aa1000001119c99aaaaa99c911100000001119ccaaaaaacc9911100000000000000001333b1b33100157c57c57c57c57100101b33b10100
0111444499aaa9944441110001119c944444449c911100000001199c4444444cc9911100000000000110001333b1111000157c57c57c57c57100001b33b10000
111aaaaa4aaaaa4aaaaa111001119cc99aaa99cc91110000000119ccaaaaaccc999111000000000013b1001313b1000000157c57c57c57c5710001b3b33b1000
111a888a4577754a888a1110000aa99944444999aa0000000000999444449999a00000000000000013b1001333b100000015775775775775710013b33b3bb100
111a888a4555554a888a1110111444499aaa99444411100111444499aaa994444111000011110000131b111333110000001555555555555571001b313b13b100
1119997999aaa9997999111111aaaaa4aaaaa4aaaaa111111aaaaa4aaaaa4aaaaa111001333310001333bb1333b1000000157c57c57c57c57101b3113b113b10
1119567659aaa9567659111111a888a4577754a888a111111a888a4577754a888a111013b333310001333b1333b1000000157c57c57c57c5710131133b311310
01116111600000611161110111a888a4555554a888a111111a888a4555554a888a11113b7b33531000131b1313b1000000157c57c57c57c571001013bbb10100
000006760000000676000001119997999aaa99979991111119997999aaa9997999111133b33353100001111333b1000000157757757757757100013bb3b31000
000000000000000111000001119567659aaa95676591111119567659aaa9567659111133333553100000001331b100000015555555555555710001b3b33b1000
011110000000011999100000111611160000061116111001116111600000611161110013355531000000001133b1000000157c57c57c57c571001b31bb13b100
199991100001199444100000000067600000006760000000000676000000067600000001333310000000001333b1000000157c57c57c57c57101b31194113b10
19449991001994444911cc1cc1cc0111111110000000000000000000000000000000000011110000000000000000000000157c57c57c57c5711b3101941013b1
01114449199444411101cc1cc1cc1777799991007777000066660000555500000000000000000000000000000000000000157757757757757101100149100110
0000119491444410000111111111017aaaa910007777000066660000555500000000000000000000000000000000000000155555555555557100000194100000
00111144494491100000001cc0000017aa9100007777000066660000555500000000000000000000000000000000000000157c57777757c57100000144100000
01999994444999911000001cc0000001791000007777000066660000555500000000000000000000000000000000000000157c57c7c757c57100000199100000
19444449449444499100001110000001791000000000777700006666000055550000000000000000000000000000000000157c57c7c757c57100000194100000
14441149949944444910000000000001791000000000777700006666000055550000000000000000000000000000000000157757c7c757757100000199100000
14110014444991111410000000000017444100000000777700006666000055550000000000000000000000000000000000155557777755557100001449110000
01000019444491000100000000000174444410000000777700006666000055550000000000000000000000000000000000000000000000000000014994941000
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
0002000214050100500c050070500c050070500c050070500c050070500c050070500c050070500c050070500c050070500c050070500c050070500c050070500c050070500c050070500c050070500c05007050
0004000012750127501275012750127501275012750127501275012750127502e7002e7002e7002e7002e7002e7002e7002e7002e700000000000000000000000000000000000000000000000000000000000000
000600001d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d750190001d000190001d000190001d000190001d000190001d000190001d000190001c00019000
0004000014040130501206011070100700f0700d0700c0700b0700a07009070070700607005070040700307002070010700107001070010700106001050010400103001020010100100001000010000100001000
000600000102005030050400b05010060110600b05006050040500205001050010500105001050010500104001030010200101001600016000160001600016000160001600016000160002600026000260002600
000500000f7400f7500f7600f7700f7700f7700f7700f7700f7700f7700f7700f7700f7700f7700f7700e7700d7700b7700a77008770077700677005770047700377002770017700176001750017400173001720
000200001005015050100500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001a5301a5401a5501a5501a5501a55003700037001a5501a5500a7000a7001a5501a5500a7002105021750215502155021550215502155021540215302152021510000000000000000000000000000000
00050000057301275019750057301550015500155001550015500165001650017500195001b5001c5001e5001e500000000000000000000000000000000000000000000000000000000000000000000000000000
00090000060300b770060300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c000006530095400b5500c5500c5500c5400c5300c5200c5100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001601016020160301604007000130501305013050130501305007000080500805008050080500805008050080500805008050080500805008050080500805008050080500805008040080300802008010
000200000171001720017300174001750017500175001750017500405006050030500b05006050047500475004750047500475004750047500475004750047500475004750047500475004740047300472004710
000f00000b7500e75010750127501575017750187501a7501a7501a7501a7501a7501a7401a7301a7201a7101a7001a7000000000000000000000000000000000000000000000000000000000000000000000000
000500000272005030027200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001f7500a750020500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000b750031500b7500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007000002510025200253002540025500255006550065500a5500a5500d5500d5500d5500d5500d5500d5500d5500d5400d5300d5200d5100d5000d5000d5000d50000000000000000000000000000000000000
000600001275012750127500f7500f7500f7501675016750167501a7501a7501a7501a750217001a7501a7501a7501a7501a0001d7501d7501d7501d7501d7501d7501d7501d7501d7401d7301d7201d7101a000
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
