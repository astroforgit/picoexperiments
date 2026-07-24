pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--4 giga boss fights
--by guerragames

poke(0x5f2d,1)

one_frame=1/30
cpu=stat(1)

--
cartdata("4gigabossfights")

game_saved=0
show_gameover=false

--
function game_load()
 regular_boss_level,regular_player_lives,regular_player_gameovers,
 attract_boss_level,attract_player_lives,
 permadeath_boss_level,permadeath_player_gameovers,permadeath_max_boss_level=
 dget(0),dget(1),dget(2),
 dget(3),dget(4),
 dget(5),dget(6),dget(7)

 regular_player_powerbar,attract_player_powerbar,permadeath_player_powerbar=dget(8),dget(9),dget(10)
 
 boss_level,player_lives,player_gameovers=regular_boss_level,regular_player_lives,regular_player_gameovers
 player_powerbar=regular_player_powerbar
end

--
function game_save()
 if game_mode==game_mode_regular then
  regular_boss_level,regular_player_lives,regular_player_gameovers=boss_level,(player_lives<2 and 2 or player_lives),player_gameovers
  regular_player_powerbar=player_powerbar
 elseif game_mode==game_mode_attract then
  attract_boss_level,attract_player_lives=boss_level,player_lives
  attract_player_powerbar=player_powerbar
 else --game_mode_permadeath
  if(boss_level>permadeath_max_boss_level)permadeath_max_boss_level=boss_level
  
  permadeath_boss_level=player_lives<0 and 0x0.0032 or boss_level
  
  permadeath_player_gameovers=player_gameovers
 
  permadeath_player_powerbar=player_lives<0 and 0 or player_powerbar
 end
 
 dset(0,regular_boss_level)
 dset(1,regular_player_lives)
 dset(2,regular_player_gameovers)
 
 dset(3,attract_boss_level)
 dset(4,attract_player_lives)
 
 dset(5,permadeath_boss_level)
 dset(6,permadeath_player_gameovers)
 dset(7,permadeath_max_boss_level)
 
 dset(8,regular_player_powerbar)
 dset(9,attract_player_powerbar)
 dset(10,permadeath_player_powerbar)
 
 game_saved=1
end

--
function game_reset()
 regular_boss_level,regular_player_lives,regular_player_gameovers,
 attract_boss_level,attract_player_lives,
 permadeath_boss_level,permadeath_player_gameovers,permadeath_max_boss_level=0x0.0032,0,0,0,0,0,0,0x0.0032
 boss_level,player_lives,player_gameovers=0,0,0
 
 regular_player_powerbar,attract_player_powerbar,permadeath_player_powerbar=0,0,0
 
 game_save()
 run()
end

--
function game_restart()
 if game_mode==game_mode_regular then
  if(regular_player_lives<2)regular_player_lives=2
  boss_level,player_lives,player_gameovers,player_powerbar=regular_boss_level,regular_player_lives,regular_player_gameovers,regular_player_powerbar
 elseif game_mode==game_mode_attract then
  boss_level,player_lives,player_gameovers,player_powerbar=attract_boss_level,attract_player_lives,0,attract_player_powerbar
 else --game_mode_permadeath
  if permadeath_player_gameovers>0 then
   boss_level,player_lives,player_gameovers,player_powerbar=0x0.0032,0,0,0
  else
   boss_level,player_lives,player_gameovers,player_powerbar=permadeath_boss_level,0,0,permadeath_player_powerbar
  end  
 end
 
 ebs_rattle_all()
 
 game_restarted=true
 next_boss_name=nil
 
 boss_initialized=true
 boss.dead=true
 boss_death_t=2.5
 boss_death_rattle=0
 
 show_gameover=false
 
 player_blink=3
end

--
function big_num_text(val)
 local s,v="",abs(val)
 repeat
  s=shl(v%0x0.000a,16)..s
  v/=10
 until v==0
 
 if val<0 then
  s="-"..s
 end
 
 return s
end

--
align_c,align_l,align_r=0,1,2

--
function print_bold(t,x,y,c,bc,a)
  local ox=#t*2 
  if a==align_l then
   ox=0
  elseif a==align_r then
   ox=#t*4
  end
  local tx=x-ox
  
  print(t,tx,y+1,bc)
  print(t,tx,y,c)
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
function ra_to_xy(r,a)
 return r*cos(a),r*sin(a)
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
   add(a,tonum(ns) or ns)
   ns=""
  else
   ns=ns..d
  end
  
  s=sub(s,2)
 end
 
 return a
end

--
function spr_index_to_xy(spr_index)
 return spr_index%16*8,flr(spr_index/16)*8
end

--
function spr_r(s,x,y,a,w,h,cpw,cph)
 local sw=(w or 1)*8
 local sh=(h or 1)*8
 local sx,sy=spr_index_to_xy(s)
 
 local hw=8*w*cpw
 local hh=8*h*cph
 
 local ca,sa=ra_to_xy(1,a)
 
 local hw_ca=hw*ca
 local hw_sa=-hw*sa
 local hh_ca=hh*ca
 local hh_sa=-hh*sa
 
 local ax,ay=-hw_ca+hh_sa,-hw_sa-hh_ca
 local bx,by=hw_ca+hh_sa,hw_sa-hh_ca
 
 local cx,cy=hw_ca-hh_sa,hw_sa+hh_ca
 local dx,dy=-hw_ca-hh_sa,-hw_sa+hh_ca
 
 local maxx=max(max(ax,bx),max(cx,dx))
 local minx=min(min(ax,bx),min(cx,dx))
 local maxy=max(max(ay,by),max(cy,dy))
 local miny=min(min(ay,by),min(cy,dy))
 
 for ix=minx,maxx do
  for iy=miny,maxy do
   local nx=ix*ca-iy*sa+hw
   local ny=ix*sa+iy*ca+hh
   
   if nx>=0 and nx<sw and ny>=0 and ny<sh then
    local c=sget(sx+nx,sy+ny)
    if c!=0 then
     pset(x+ix,y+iy,c)
    end
   end
  end
 end
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
shoot_button:button_init()

--
level_wind_t,level_wind_value=0,0

--
function level_update()
 if(game_saved>0)game_saved-=one_frame
 
 level_wind_max_vx=.5*60*one_frame
 level_wind_t+=one_frame
 level_wind_value=level_wind_max_vx*sin(level_wind_t/20)
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

   p.vy+=p.g
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
   part_draw(p,1,p.bc)
  end
 end

 for k,p in pairs(parts) do
  if p.t>0 then
   part_draw(p,0,p.c)
  end
 end
end

--
function explosions_spawn(px,py,t,intensity,count,c,bc)
 for i=1,count do
  local an,ra=rnd(),intensity+rnd(intensity)
  
  local vx,vy=ra_to_xy(ra,an)

  parts_spawn(t,px,py,vx,vy,0,.9,ra,-.2,c,bc)
 end
end

--
stars={}
stars_next,stars_active_count=1,0

for i=0,600 do
 add(stars,{active=false})
end

star_layers_count=8

--
function stars_spawn()
 local star,i=find_next_i(stars,stars_next,stars_active_count)
 
 if star then
  stars_next=i
  
  stars_active_count+=1
  star.active=true
  
  star.y,star.z=-10,1+flr(rnd(star_layers_count))
  
  local layer=(star_layers_count-star.z)
  star.size=layer+rnd(star_layers_count)
  
  if rnd()>.5 then
   star.x=64-layer*12-rnd(96/layer)
  else
   star.x=64+layer*12+rnd(96/layer)
  end
 
  star.vy=.1+.6*layer+rnd(1.5)
  star.vy*=60*one_frame
 end
end

--
function stars_update()
 if cpu<=.6 then
  for i=0,18*(.6-cpu)/.6 do
   stars_spawn()
  end
 end
 
 for k,star in pairs(stars) do
  if star.active then
   star.y+=star.vy
   star.x+=level_wind_value
   
   if star.y>128+10 then
    star.active=false
    stars_active_count-=1
   end
  end
 end
end

-- 
function stars_draw()
 local px,py=get_pxpy()

 for k,star in pairs(stars) do
  if star.active then
   local x,y,s=star.x-px/star.z,star.y-py/star.z,star.size/star.z
   circfill(x,y,s,1)
  end 
 end
end

--
player_x,player_y=64,96
player_vx,player_vy,player_cx,player_cy=0,0,0,0
player_damp=.9

player_mouse_on=0
player_mouse_ox,player_mouse_oy=64,64
player_mouse_x,player_mouse_y=64,64
player_mouse_sx,player_mouse_sy=0,0

player_facing_a=0

player_dying,player_blink=false,0

player_damage_target=nil
player_damage_target_t=10

player_spr_index=1
player_spr_list       =nl("32,34,36,38, 40, 42, 44, 46,  4,  6,  8,  10,  12,   14,   64,   66,   68,   70,   72,   74,   76,    78,")
player_ship_req_scores=nl(" 0,10,30,50, 70,100,150,200,250,300,400, 500, 750, 1000, 1250, 1500, 1750, 2000, 2500, 3000, 4000,  5000,")

player_spr_max_index=1
player_ship_unlocked_t=0

player_trail={}
player_trail_next,player_trail_active_count=1,0

for i=1,120 do
 add(player_trail,{active=false})
end

player_trail_explosion_t=0

--
function get_pxpy()
 return player_x-64,(player_y-64)*.5
end

--
function player_trail_spawn(big_particles)
 local pt,i=find_next_i(player_trail,player_trail_next,player_trail_active_count)
 
 if pt then
  player_trail_next=i
  
  player_trail_active_count+=1
  pt.active=true

  local rnda=big_particles and (.06-rnd(.12)) or (.025-rnd(.05))

  local a=player_facing_a+.25+rnda
  local aim_x,aim_y=ra_to_xy(-8,a)
  local speed=.3+rnd(.3)
  speed*=60*one_frame
  local t=.6+rnd(.4)+(big_particles and .6 or 0)
  local dt=big_particles and 3 or 1.5
  
  pt.x,pt.y,pt.vx,pt.vy=player_x+aim_x,player_y+aim_y,speed*aim_x,speed*aim_y
  pt.t,pt.dt=t,dt
 end

end

--
function player_trail_update()
 player_trail_explosion_t=max(0,player_trail_explosion_t-one_frame)
 
 player_trail_explosion=false
 if player_trail_explosion_wait and player_trail_explosion_t<.15 then
  player_trail_explosion_wait=false
  player_trail_explosion=true
 end
 
 if not player_dying and not show_gameover and not player_trail_explosion_wait then
  for i=1,4*60*one_frame do
   player_trail_spawn(player_trail_explosion)
  end
 end
 
 for k,pt in pairs(player_trail) do
  if pt.active then
   if pt.t<=0 or pt.y>140 then
    player_trail_active_count-=1
    pt.active=false
   else
    pt.t-=one_frame*pt.dt
    pt.x+=pt.vx
    pt.y+=pt.vy
    pt.vx+=level_wind_value/20
    pt.vy-=.05*60*one_frame
    if(pt.vy<1*60*one_frame)pt.vy=1*60*one_frame
   end
  end
 end
end

trail_colors=nl("8,8,8,8,8,9,9,10,10,7,7,7,7,7,7,7,7,7,7,7,7,")

--
function player_trail_draw()
 local trail_x,trail_y=-1,-1
 
 for k,pt in pairs(player_trail) do
  if pt.active then
   if pt.y<140 then
    if trail_x!=-1 then
     if pt.t<.45 then
      fillp(0b0101101001011010.1)
     else
      fillp()
     end
     circfill(pt.x,pt.y,16*(1-pt.t),5)
    end
    
    trail_x,trail_y=pt.x,pt.y
   end
  end
 end

 fillp()

 local trail_x,trail_y=-1,-1
 
 for k,pt in pairs(player_trail) do
  if pt.active then
   if pt.y<140 then
    if trail_x!=-1 then
     local c=trail_colors[1+flr(pt.t/2*#trail_colors)]

     circfill(pt.x,pt.y,4*pt.t-1,c)
    end
    
    trail_x,trail_y=pt.x,pt.y
   end
  end
 end
end

--
function player_update_mouse()
 local mouse_on=stat(34)
 
 local mx,my=stat(32),stat(33)
 
 if player_mouse_on==0 and mouse_on!=0 then
  player_mouse_ox,player_mouse_oy=mx,my
 end
 
 if player_mouse_on!=0 and mouse_on==0 then
  player_mouse_released=true
  player_mouse_sx,player_mouse_sy=(player_mouse_x-player_mouse_ox)*.05,(player_mouse_y-player_mouse_oy)*.05
 end
 
 player_mouse_on=mouse_on
 
 if player_mouse_on!=0 then
  player_mouse_x,player_mouse_y=mx,my
 end
end

--
function player_dying_update()
 if player_dying then
  if not boom_active then
   player_dying=false
   player_blink=3
  
   if player_lives<0 then
    player_gameovers+=1
    show_gameover=true
    ui_box_set_screen(ui_box_screen_gameover,20)
    game_select_active=true
    game_save()
   end
  end
 end
 
 if player_blink>0 then
  player_blink-=one_frame
 end
end

--
function player_shooting(oa,bs)
 local speed=4*60*one_frame

 local shooting_a=player_facing_a+oa+(.01-rnd(.02))
 local aim_x,aim_y=ra_to_xy(speed,shooting_a)
 pbullets_spawn(1,player_x+aim_x,player_y+aim_y,aim_x,aim_y,bs)

 return aim_x,aim_y
end

--
function player_update()
 
 player_ship_unlocked_t=max(0,player_ship_unlocked_t-one_frame)
 
 player_damage_target_t+=one_frame
 
 player_a=.25*60*one_frame
 player_max_speed=.25*60*one_frame
 
 player_update_mouse()
 
 player_cx,player_cy=0,0
 
 if not show_title and not game_select_active then
  -- directional controls stuff
  if player_mouse_on!=0 then
   player_cx,player_cy=(player_mouse_x-player_mouse_ox)*.05,(player_mouse_y-player_mouse_oy)*.05
  end
  
  if(btn(0))player_cx=-1
  if(btn(1))player_cx=1
  if(btn(2))player_cy=-1
  if(btn(3))player_cy=1
  
  if player_cx!=0 or player_cy!=0 then
   player_cx,player_cy,m=normalize(player_cx,player_cy)
   m=min(m,1)
   player_cx,player_cy=m*player_cx,m*player_cy
  end
 end
 
 player_vx+=player_a*player_cx
 player_vy+=player_a*player_cy
 
 player_vx*=player_damp
 player_vy*=player_damp
 
 local nvx,nvy,speed=normalize(player_vx,player_vy)
 
 local max_speed=player_max_speed
 
 if(speed>max_speed)speed=max_speed
 
 if not player_dying and not show_gameover then
  -- update player position
  player_vx,player_vy=speed*nvx,speed*nvy
  
  player_x+=player_vx
  player_y+=player_vy
  
  if(player_x<16)player_x=16
  if(player_x>128-16)player_x=128-16
  if(player_y<16)player_y=16
  if(player_y>128-8)player_y=128-8
 
  local target_a=-.125*player_vx/player_max_speed

  player_facing_a+=.1*(target_a-player_facing_a)*60*one_frame
  player_facing_a+=level_wind_value/100 
  player_facing_a=mid(-.125,player_facing_a,.125)
 end
 
 pbullet_last_time+=one_frame
 
 if not player_dying and boss_death_t<=0 and not show_gameover and not show_title and not game_select_active then
  if pbullet_last_time>=.05 then
   pbullet_last_time=0
   
   local bullet_size=1
   
   if btn(4) or btn(5) then
    local ppb=player_powerbar-1/50
    
    if ppb>0 then
     bullet_size=ppb>.5 and 4 or 2
     player_powerbar=ppb
     player_shooting(.29,bullet_size)
     player_shooting(.21,bullet_size)
    end   
   end   
   
   local aim_x,aim_y=player_shooting(.25,bullet_size)
   
   explosions_spawn(player_x+aim_x,player_y+aim_y,.2,1,4,10,9)
  end
 end 

 if rnd()>.96 then
  player_trail_explosion_wait=true
  player_trail_explosion_t=.2
 end
 
 player_trail_update()
end

--
function player_check_collision(ex,ey,es)
 if not player_dying and not show_gameover and player_blink<=0 then
  local res=es*.7071
  
  local not_colliding= player_x-1>ex+res or
                       player_x+1<ex-res or
                       player_y-1>ey+res or
                       player_y+1<ey-res
						 
	 if not not_colliding then
   return true      
	 end
 end

 return false
end

--
function player_death()
 if(boss_level==0xffff.ffff)return
  
 if game_mode==game_mode_attract then
  player_lives+=1
 else
  player_lives-=1
 end
 
 game_save()
 
 boom_spawn(player_x,player_y,boom_type_player)
 ebs_rattle_all()
 player_dying=true
end

--
function player_draw()
 if not show_gameover then
  if boom_type!=boom_type_player or not boom_active or boom_t<boom_t_hold then
   if player_blink<=0 or player_blink%.2>=.1 then
    
    local c=(game_mode==game_mode_permadeath and t()%.2>.1) and 10 or 13
    pal(13,c)
    
    local aim_x,aim_y=ra_to_xy(1,player_facing_a+.25)
    
    local ptet=player_trail_explosion_t
    local trail_explosion_mag=player_trail_explosion_wait and -2*((ptet-.15)/.05) or 2*ptet/.2
    local te_bx,te_by=ra_to_xy(trail_explosion_mag,player_facing_a+.25)
    local te_x,te_y=te_bx+rnd(ptet*4)-ptet*2,te_by+rnd(ptet*4)-ptet*2
    
    spr_r(player_spr_list[player_spr_index],player_x+te_x,player_y+te_y,-player_facing_a,2,2,.5,.5)
   
    spr(2,player_x+te_x-1.5,player_y+te_y-1.5)
    
    pal()
    
    if boom_type==boom_type_player and boom_t>0 and boom_t<boom_t_hold then
     local rt=mid(0,boom_t/.5,1)
     circ(player_x,player_y,rt*200,1)
     circ(player_x,player_y,rt*200+10,13)
     circ(player_x,player_y,rt*200+15,7)
    end
   end
  end
 end
 
 player_trail_draw()
end

--
function player_target_draw()
 if player_damage_target and player_damage_target_t<.5 then
  local size=player_damage_target.size+5+(3+1.5*sin(5*t()))

  local px,py=get_pxpy()
  local x,y=player_damage_target.x-px,player_damage_target.y-py
  local c=t()%.1>.05 and 8 or 10
  circ(x,y,size,c)
  circ(x-1,y,size,c)
  circ(x+1,y,size,c)
 end
end


--
pbullets={}
pbullets_next,pbullets_active_count=1,0

pbullet_last_time=1

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
  end
 end
end

--
function pbullets_draw()
 local c=game_mode==game_mode_permadeath and 7 or 8
 for k,pb in pairs(pbullets) do
  if pb.active then
   circfill(pb.x,pb.y,pb.s+1,10)
   circfill(pb.x,pb.y,pb.s,c)
  end
 end
end

--
ebs={}

for i=1,1000 do
 add(ebs,{})
end

ebs_draw_buckets={}

--
function ebs_reset()
 ebs_next,ebs_active_count=1,0

 for k,eb in pairs(ebs) do
  eb.active=false
 end
end

--
function ebs_rattle_all()
 for k,eb in pairs(ebs) do
  if eb.active then
   eb.drattle=.2
  end
 end
end
   
--
function ebs_spawn(x,y,vx,vy,s)
 local b,i=find_next_i(ebs,ebs_next,ebs_active_count)
 
 if b then
  ebs_next=i
  ebs_active_count+=1
 
  b.active,b.vx,b.vy,b.t,b.s,b.x,b.y,b.drattle=true,vx,vy,0,s,x,y,0
  
  local bucket_index=flr(b.s)
  local bucket=ebs_draw_buckets[bucket_index]
  if not bucket then
   bucket={}
   ebs_draw_buckets[bucket_index]=bucket
  end
  
  add(bucket,b)
 end
end

--
function ebs_update()
 local px,py=get_pxpy()

 for k,b in pairs(ebs) do
  if b.active then
   if b.drattle>0 then
    b.drattle-=one_frame
    
    if b.drattle<=0 then
     b.active=false
     ebs_active_count-=1
     
     local bucket_index=flr(b.s)
     del(ebs_draw_buckets[bucket_index],b)
    end
   end
  end
  
  if b.active then
   b.t+=one_frame

   b.x+=b.vx
   b.y+=b.vy

   if b.drattle<=0 then
    if player_check_collision(b.x-px,b.y-py,b.s) then
     player_death()
     b.drattle=.2
    end
   end

   if b.x<-128 or b.x>256 or b.y<-128 or b.y>256 then
    b.active=false
    ebs_active_count-=1
    local bucket_index=flr(b.s)
    del(ebs_draw_buckets[bucket_index],b)
   end   
  end
 end
end

--
function ebs_draw()
 local px,py=get_pxpy()

 for i=32,0,-1 do
  local bucket=ebs_draw_buckets[i]
  
  if bucket then
   for k,b in pairs(bucket) do
    if b.active then
     local ss=min(1,b.t*5)*b.s
     
     if(b.drattle>0)ss=max(0,b.drattle*10)*b.s
     
     local blink=b.t%.2>.1
     
     local x,y=b.x-px,b.y-py
     circfill(x,y,1+ss,blink and 8 or 12)

     circfill(x,y,ss,blink and 12 or 8)
    end
   end
  end
 end

end

--
boom_particles={}
boom_particles_next,boom_particles_active_count=1,0

boom_t,boom_active,boom_basex,boom_basey,boom_t_grow,boom_t_hold=0,false,0,0,1,1.2

boom_type_player,boom_type_boss=0,1
boom_type=boom_type_player

for i=0,400 do
 add(boom_particles,{active=false})
end

boom_smoke_particles={}
boom_smoke_next,boom_smoke_active_count=1,0

for i=0,600 do
 add(boom_smoke_particles,{active=false})
end

--
function boom_particle_spawn()
 local bp,i=find_next_i(boom_particles,boom_particles_next,boom_particles_active_count)
 
 if bp then
  boom_particles_next=i
  
  boom_particles_active_count+=1
  bp.active=true
  
  local is_boss=boom_type==boom_type_boss
 
  bp.delay,bp.t,bp.fade,bp.a,bp.r,bp.v,bp.s=.1+rnd(1),.1+rnd(.9),.1+rnd(1),rnd(),rnd(boom_maxr),0,0
  bp.vdamp=is_boss and (.8+.2*rnd()) or (.5+.2*rnd())
  
  bp.x,bp.y=ra_to_xy(bp.r,bp.a)
  
 end
end

--
function boom_reset()
 
 boom_particles_next,boom_particles_active_count=1,0
 for k,p in pairs(boom_particles) do
  p.active=false
 end
 
 boom_smoke_next,boom_smoke_active_count=1,0
 for k,p in pairs(boom_smoke_particles) do
  p.active=false
 end
end

--
function boom_spawn(x,y,bt,s)
 boom_reset()
 
 boom_basex,boom_basey=x,y

 boom_t=0
 boom_active=true
 boom_type=bt
 
 boom_holding=true
 
 sfx(8,3)
 
 local is_boss=boom_type==boom_type_boss
 
 if is_boss then
  boom_maxr,boom_maxs=s,9
 else
  boom_maxr,boom_maxs=12,5
 end
 
 for i=1,(is_boss and 300 or 200) do
  boom_particle_spawn()
 end
end

--
function boom_smoke_spawn(x,y,s)
 local bs,i=find_next_i(boom_smoke_particles,boom_smoke_next,boom_smoke_active_count)
 
 if bs then
  boom_smoke_next=i
  
  boom_smoke_active_count+=1
  bs.active=true
 
  bs.x,bs.y,bs.s,bs.t=x,y,s,.1+.1*rnd()
 end 
end

--
function boom_update()
 if boom_active then
  boom_t+=one_frame
  
  local is_boss=boom_type==boom_type_boss

  if boom_t>0 and boom_t<boom_t_grow then
   boom_active=true
   for k,p in pairs(boom_particles) do
    if p.active then
     if p.delay<=0 then
      p.s+=(is_boss and .8 or .4)*p.t
   
      p.x+=1-rnd(2)
      p.y+=1-rnd(2)
      
      if p.s>boom_maxs then
       p.s=boom_maxs
      end
      
     else
      p.delay-=one_frame
     end
    end
   end
  elseif boom_t>boom_t_hold then
   
   if boom_holding then
    sfx(7,3)
    boom_holding=false
   end
   
   for k,p in pairs(boom_particles) do
    if p.active then
     if p.v==0 then
      p.v=2+rnd(10)
      p.s*=1.5
     else
      p.s*=.9
      p.v*=p.vdamp
      if(p.v<1)p.v=1
     end
     
     if p.s>=.5 then
      p.r+=p.v
      p.x,p.y=boom_basex+p.r*cos(p.a),boom_basey+p.r*sin(p.a)

      boom_smoke_spawn(p.x+1-rnd(2),p.y+1-rnd(2),p.s*1.2+rnd(2))

     else
      p.active=false
      boom_particles_active_count-=1
     end
    end
   end
  end

  for k,p in pairs(boom_smoke_particles) do
   if p.active then
    if p.t>=0 then
     p.t-=one_frame
     p.s*=1.1
    else
     boom_smoke_active_count-=1
     p.active=false
    end
   end
   
   if boom_particles_active_count<=0 and boom_smoke_active_count<=0 then
    boom_active=false
   end
  end
 end 
end

player_boom_colors=nl("7,10,10,9,9,8,8,8,8,")
boss_boom_colors=nl("10,9,9,9,8,8,8,8,4,4,4,4,")

--
function boom_draw()
 if boom_active then
  local rx,ry=0,0
  
  if(boom_t<boom_t_hold)rx,ry=boom_basex+1-rnd(2),boom_basey+1-rnd(2)
 
  local colors=player_boom_colors
  local is_boss=boom_type==boom_type_boss
  if is_boss then
   colors=boss_boom_colors
  end
  
  for k,p in pairs(boom_smoke_particles) do
   if p.active then
    if p.t<.05 then
     fillp(0b0101101001011010.1)
    else
     fillp()
    end

    circfill(p.x,p.y,p.s,5)
   end
  end
  
  fillp()

  color_function=function(p)
   return colors[1+flr(max(0,min(#colors-1,#colors*(boom_maxs-p.s)/boom_maxs)))]
  end

  for k,p in pairs(boom_particles) do
   if p.active then
    if p.delay<=0 then
     if boom_t<boom_t_hold then
      circfill(p.x+rx,p.y+ry,p.s,is_boss and 9 or 10)
     else
	  
      circfill(p.x,p.y,p.s,color_function(p))
     end
    end
   end
  end
  
  if boom_t<boom_t_hold then
   for k,p in pairs(boom_particles) do
    if p.active then
     if p.delay<=0 then
      circfill(p.x+rx,p.y+ry,p.s-2,is_boss and 10 or 7)
     end
    end
   end 
  end	
 end
end

--
boss={}
boss_initialized=false
boss_death_t=0

weapon_type_bullet,weapon_type_laser=0,1

--
local function boss_mirror_children(target_children,boss_children)
 local add_children={}
 for k,child in pairs(boss_children) do
  local mchild={}
  
  mchild.a,mchild.da=-child.a,-child.da
  
  mchild.sinwave_t,mchild.r,mchild.size=child.sinwave_t,child.r,child.size
  
  mchild.firerate,mchild.fire_t,mchild.weapon_type=child.firerate,child.fire_t,child.weapon_type
  
  mchild.firecount,mchild.bulletspeed,mchild.bulletsize=child.firecount,child.bulletspeed,child.bulletsize
  
  mchild.damaged_t,mchild.max_health,mchild.health,mchild.dead=child.damaged_t,child.max_health,child.health,child.dead
 
  add(add_children,mchild)
  
  if child.children then
   mchild.children={}
   boss_mirror_children(mchild.children,child.children)
  end
 end
 
 for k,child in pairs(add_children) do
  add(target_children,child)
 end
end

--
local function boss_add_children(boss_children,current_size,a,da)
 local child={}
 
 child.a=a
 child.da=da
 child.sinwave_t=.3
 child.r=2+rnd(2*current_size)
 child.size=2+rnd(current_size/2)
 
 child.firerate=2+rnd(current_size/2)
 child.fire_t=child.firerate
 
 local bl=min(100,abs(shl(boss_level,16)))/100
 
 local laser_chance=.1*max(.2,bl)
 
 child.weapon_type=rnd()<laser_chance and weapon_type_laser or weapon_type_bullet
 
 if(child.weapon_type==weapon_type_laser)child.sinwave_t=.02
 
 child.firecount=flr(current_size/4+rnd(64/current_size))
 
 child.bulletspeed=.2+rnd(6/current_size)
 child.bulletsize=1+rnd(current_size/4)
 
 child.damaged_t=0
 
 child.max_health=2+rnd(4*current_size)+2*bl
 child.health=child.max_health
 child.dead=false
 
 add(boss_children,child)
 
 if rnd()>.2 and current_size/2>4 then
  child.children={}
  for i=1,1+rnd(current_size/6) do
   local a2=-.05*i
   boss_add_children(child.children,current_size/2,a2,da/2)
  end
 end
end

--
function rnd_sound(sfx_index,notes,root_note)
 local sfx_mem=0x3200
 local sfx_size=68
 local sfx_mem_addr=sfx_mem+sfx_index*sfx_size

 for i=sfx_mem_addr,sfx_mem_addr+32*2,2 do
  local old_note=band(peek(i),0b11000000)
  local new_note=notes[flr(#notes*rnd()+1)]
  if(i%8==0 or rnd()>.8)new_note=root_note
  poke(i,bor(old_note,new_note))
 end
end

--
function generate_boss_name(level)
 srand(level)
 name=""
 local maxi=2+flr(rnd(4))
 for i=1,maxi do
  if(rnd()>.7 and i!=1 and i!=maxi)name=name..(rnd()>.5 and "'" or "-")
  name=name..lovecraft_names_syl[1+flr(rnd(#lovecraft_names_syl))]
 end
 
 return name
end

--
function rearrange_music()
 
 local e_minor_notes=nl("0,2,4,6,7,9,11, 12,14,16,18,19,21,23, 24,26,28,30,31,33,35, 36,38,40,42,43,45,47,")
 local e_root_note=28
 rnd_sound(15,e_minor_notes,e_root_note)

 local a_minor_notes=nl("0,2,4,5,7,9,11, 12,14,16,17,19,21,23, 24,26,28,29,31,33,35, 36,38,40,41,43,45,47,")
 local a_root_note=33
 rnd_sound(16,a_minor_notes,a_root_note)

end

--
function boss_make_new()
 boss_initialized=true
 
 srand(boss_level)
 
 boss={}
 boss.children={}
 
 local bl=min(100,abs(shl(boss_level,16)))/100
 
 if bl<1 then
  boss.size=mid(12,32*bl,32)
 else
  boss.size=mid(12,12+rnd(32-12),32)
 end
 
 boss.offset_y=-128
 boss.x,boss.y=64,24
 boss.c1,boss.c2,boss.c3=flr(1+rnd(15)),flr(1+rnd(15)),flr(1+rnd(15))
 
 boss.damaged_t=0
 
 boss.max_health=4*boss.size+rnd(4*boss.size)+bl
 boss.health=boss.max_health
 boss.dead=false
 boss_death_t=0
 boss_death_rattle=0
 
 local current_size=boss.size
 
 for i=1,1+rnd(4) do
  local a=.1*i
  local da=.02
  boss_add_children(boss.children,current_size,a,da)
 end
 
 boss_mirror_children(boss.children,boss.children)
 
 rearrange_music()
 
 boss_name=generate_boss_name(boss_level)
 next_boss_name=generate_boss_name(boss_level+0x0000.0001)
end

--
function boss_check_damage(child,px,py)
 if(boss_level==0xffff.ffff)return

 child.damaged_t=max(0,child.damaged_t-one_frame)
 
 local pbdamage=game_mode==game_mode_permadeath and 2 or 1

 if not child.dead then
  local cx,cy,cs=child.x-px,child.y-py,child.size
  for k,pb in pairs(pbullets) do
   if pb.active then
    if pb.x-pb.s<cx+cs and pb.x+pb.s>cx-cs and pb.y-pb.s<cy+cs and pb.y+pb.s>cy-cs then
     pb.active=false
     pbullets_active_count-=1
     
     player_powerbar=min(1,player_powerbar+1/1000)
     
     child.health-=pb.s*pbdamage  --<-- amount of damage from player bullet
     child.damaged_t=.1

     player_damage_target=child
     player_damage_target_t=0
     
     if child.health<=0 then
      if(not boom_active)sfx(6,3)
      child.dead=true
      explosions_spawn(pb.x,pb.y,.8,4,20,10,9)
     else
      if(not boom_active)sfx(5,3)
      explosions_spawn(pb.x,pb.y,.4,2,4,10,9)
     end
    end
   end
  end
 end
end

--
local function boss_damage_all_children(boss_children)
 for k,child in pairs(boss_children) do
  if not child.dead then
   child.damaged_t=1
  end
  
  if child.children then
   boss_damage_all_children(child.children)
  end
 end
end

--
function boss_killed()
 boss.dead=true
 local px,py=get_pxpy()
 boss_death_t=0
 boss_death_rattle=1.2
 local bx,by=boss.x-px,boss.y-py
 boom_spawn(bx,by,boom_type_boss,boss.size*1.5)
 ebs_rattle_all()
 
 boss_damage_all_children(boss.children)
 
 music(0,0,7)
end

--
local function boss_update_children(boss_children,boss_x,boss_y,boss_a)
 local px,py=get_pxpy()
 
 for k,child in pairs(boss_children) do
  local a=boss_a+child.a+child.da*sin(t()*child.sinwave_t)
  local ox,oy=ra_to_xy(child.r,a)
  
  child.ta,child.x,child.y=a,boss_x+ox,boss_y+oy
  
  if(not show_title and not game_select_active) then
   if not child.dead then
    if child.fire_t then
     child.fire_t-=one_frame
     
     -- check for lazer collision
    if child.weapon_type==weapon_type_laser then
     if not player_dying and not show_gameover and player_blink<=0 then
      if child.fire_t<=child.firerate/2 then
       local nx,ny=ra_to_xy(1,child.ta)
       --check for line intersections against the player
       local p_to_cx,p_to_cy=child.x-px-player_x,child.y-py-player_y
       local dot=p_to_cx*nx+p_to_cy*ny
       local dx,dy=p_to_cx-dot*nx,p_to_cy-dot*ny
       
       if mag(dx,dy)<2 then
        player_death()
        child.fire_t=child.firerate*2
       end
      end
     end
    end
     
     if child.fire_t<=0 then
      if child.weapon_type==weapon_type_bullet then
       child.fire_t=child.firerate

       if cpu<=.8 then
        local ba=a
        for i=1,child.firecount do
         local vx,vy=ra_to_xy(child.bulletspeed,ba)
         ebs_spawn(child.x,child.y,vx,vy,child.bulletsize)
         ba+=1/child.firecount
        end
       end
      else
       child.fire_t=child.firerate*2
      end
     end
    end
   end
 
   boss_check_damage(child,px,py)
  end
  
  if child.children then
   boss_update_children(child.children,boss_x+ox,boss_y+oy,a)
  end
 end
end

--
function boss_update()
 if boss_death_t>5.5 then
  if not game_restarted then
   boss_level+=0x0.0001
  else
   game_restarted=false
  end
 
  if game_mode==game_mode_regular then
   if(player_lives<2)player_lives=2
  end
  
  game_save()
  boss_make_new()
  
  local old_max_ship=player_spr_max_index
  player_spr_max_index=player_ship_max_unlock()
  if player_spr_max_index>old_max_ship then
   player_spr_index,player_ship_unlocked_t=player_spr_max_index,2
  end
 end
 
 if(not boss_initialized)return
 if(boss_level==0xffff.ffff)return
 
 if not boss.dead then
  if show_gameover then
   boss.offset_y=max(-abs(2*boss.offset_y),-200)
  else
   boss.offset_y*=.9
  end
  
  local px,py=get_pxpy()
  boss.x,boss.y=64+8*cos(t()/10),24+4*sin(t()/7)+boss.offset_y
  
  local boss_was_alive=not boss.dead
  boss_check_damage(boss,px,py) 
  boss_update_children(boss.children,boss.x,boss.y,-.25)

  if boss_was_alive and boss.dead then
   boss_killed()
  end
 else
  boss_death_t+=one_frame
  boss_death_rattle=max(0,boss_death_rattle-one_frame)
 end
end

--
local function boss_draw_children(boss_children,boss_x,boss_y,sx,sy)
 local px,py=get_pxpy()

 for k,child in pairs(boss_children) do
  local x,y=child.x+sx-px,child.y+sy-py
  
  if not child.dead then
   local size=child.size*child.health/child.max_health+3
   circfill(x,y,size,boss.c1)
   line(x-1,y,boss_x-1,boss_y,boss.c1)
   line(x+1,y,boss_x+1,boss_y,boss.c1)
   line(x,y-1,boss_x,boss_y-1,boss.c1)
   line(x,y+1,boss_x,boss_y+1,boss.c1)
  else
   circfill(x,y,1,6)
  end
  
  if child.children then
   boss_draw_children(child.children,x,y,sx,sy)
  end
 end
end

--
local function boss_draw_children_cores(boss_children,boss_x,boss_y,sx,sy)
 local px,py=get_pxpy()
 
 for k,child in pairs(boss_children) do
  local x,y=child.x+sx-px,child.y+sy-py
  
  if not child.dead then
   local size=child.size*child.health/child.max_health+2

   if child.damaged_t<=0 then
    circfill(x,y,size,boss.c2)
   end
   
   line(x,y,boss_x,boss_y,boss.c2)
  else
   line(x,y,boss_x,boss_y,6)
  end
  
  if child.children then
   boss_draw_children_cores(child.children,x,y,sx,sy)
  end
 end
end

--
local function boss_draw_children_cores2(boss_children,boss_x,boss_y,sx,sy)
 local px,py=get_pxpy()
 
 for k,child in pairs(boss_children) do
  local x,y=child.x+sx-px,child.y+sy-py
  
  if not child.dead then
   local size=child.size*child.health/child.max_health
   
   if child.damaged_t<=0 then
    circfill(x,y,size,boss.c3)
   end
   
   if not boss.dead and child.weapon_type==weapon_type_laser then
    local ox,oy=x+160*cos(child.ta),y+160*sin(child.ta)
    
    if child.fire_t<=child.firerate/2 then
     circfill(x,y,size+2,2)
     for i=-2,2 do
      for j=-2,2 do
       line(x+i,y+j,ox+i,oy+j,2)
      end
     end
     
     circfill(x,y,size+1,8)
     for i=-1,1 do
      for j=-1,1 do
       line(x+i,y+j,ox+i,oy+j,8)
      end
     end
    elseif child.fire_t>child.firerate*2-0.1 then  --< 0.1 seconds in dissipation
     fillp(0b0101101001011010.1)
     circfill(x,y,size/2,8)
     line(x,y,ox,oy,8)
     fillp()
    elseif child.fire_t<child.firerate/2+0.4 then  --< 0.4 seconds in anticipation
     circfill(x,y,size/2,8)
     line(x,y,ox,oy,8)
    elseif child.fire_t<child.firerate/2+1.5 then  --< 1.5 seconds in pre-anticipation
     fillp(0b0101101001011010.1)
     circfill(x,y,size/2,2)
     line(x,y,ox,oy,2)
     fillp()
    end
   end
   
  end
  
  if child.children then
   boss_draw_children_cores2(child.children,x,y,sx,sy)
  end
 end
end

--
local function boss_draw_children_damaged(boss_children,boss_x,boss_y,sx,sy)
 local px,py=get_pxpy()
 
 for k,child in pairs(boss_children) do
  local x,y=child.x+sx-px,child.y+sy-py
  
  if not child.dead then
   local size=child.size*child.health/child.max_health
   
   if child.damaged_t>0 then
    circfill(x,y,size+7,boss.c2)
    circfill(x,y,size+5,boss.c3)
   end
  end

  if child.children then
   boss_draw_children_damaged(child.children,x,y,sx,sy)
  end
 end
end

--
function boss_draw()
 if(not boss_initialized)return
 if(boss_level==0xffff.ffff)return
 if(boss.dead and boss_death_rattle<=0)return

 local px,py=get_pxpy()
 local bx,by=boss.x-px,boss.y-py
 
 local sx,sy=0,0
 local health_percent=boss.health/boss.max_health
 
 if health_percent<.5 then
  local shake_mag=3*(.5-health_percent)/.5
  sx,sy=shake_mag-rnd(2*shake_mag),shake_mag-rnd(2*shake_mag)
  bx+=sx
  by+=sy
 end

 local damaged_size=0
 if boss.damaged_t>0 then
  damaged_size=5
 end

 circfill(bx,by,boss.size,boss.c1)
 boss_draw_children(boss.children,bx,by,sx,sy)
 
 circfill(bx,by,boss.size/2+damaged_size,boss.c2)
 boss_draw_children_cores(boss.children,bx,by,sx,sy)
 
 circfill(bx,by,boss.size/3+damaged_size,boss.c3)
 boss_draw_children_cores2(boss.children,bx,by,sx,sy)
 
 if boss_death_rattle>0 then
  local rt=200*mid(0,(1.2-boss_death_rattle)/.5,1)
  circ(bx,by,rt,1)
  circ(bx,by,rt+10,13)
  circ(bx,by,rt+15,7)
  
  local rt=300*mid(0,(1.2-boss_death_rattle)/1.2,1)
  local ax,ay=ra_to_xy(rt,t()/10)
  line(bx+ax,by+ay,bx-ax,by-ay,7)
  line(bx-ay,by+ax,bx+ay,by-ax,7)
 end
 
 boss_draw_children_damaged(boss.children,bx,by,sx,sy)
end

--

function print_spr(index,sw,sh,dx,dy,dw,dh)
 local sx,sy=spr_index_to_xy(index)
 
 pal(7,13)
 sspr(sx,sy,sw,sh,dx,dy+2,dw,dh)
 
 pal(7)
 sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end

--
lovecraft_names_syl=nl("ph,ng,lui,mg,lw,fh,cth,ul,hu,rl,yeh,wgah,na,gl,fht,agn,gol,gor,oth,nyar,la,tho,tep,yog,soth,oth,")

-- 
function ui_draw()
 local boss_txt=""
 local local_boss_name=""
 if boss_death_t>2.5 then
  boss_txt=game_restarted and big_num_text(boss_level) or big_num_text(boss_level+0x0000.0001)
  if(game_restarted)next_boss_name=next_boss_name or generate_boss_name(boss_level)
  local_boss_name=next_boss_name or ""
 else
  boss_txt=big_num_text(boss_level)
  local_boss_name=boss_name or ""
 end
 
 if(game_mode==game_mode_attract)pal(7,12)
 if(game_mode==game_mode_permadeath)pal(7,10)
 print_bold("boss #"..boss_txt,1,1,7,13,align_l)
 if(game_mode==game_mode_permadeath and game_select_active)print_bold("max boss #"..big_num_text(permadeath_max_boss_level),1,8,7,13,align_l)
 if(game_mode==game_mode_regular and game_select_active)print_bold("tries:"..regular_player_gameovers,122,8,7,13,align_r)
 
 pal()
 
 -- power bar
 local pby=125-player_powerbar*116
 rect(122,8,126,126,13)
 local c=(player_powerbar>=.5 and t()%.2>.1) and 10 or 8
 rectfill(123,125,125,pby,c)
 
 print_bold(""..max(0,player_lives),121,1,7,13,align_r)
 spr(3,122,1)
 
 -- draw boss fight transition!
 if boss_death_t>2.5 and boss_death_t<5 then
  local byt=boss_death_t<4 and mid(0,(boss_death_t-2.5)/.2,1) or mid(0,(.2-(boss_death_t-4.8))/.2,1)
  local by=-30+min(54,54*byt*byt)

  print_spr(128,38,5,2,by,121,32)

  local y=60
  local top_y,bottom_y=4-4*byt,-4+4*byt
  line(0,y-1+top_y,128,y-1+top_y,13)
  local shimmer_x=128*(boss_death_t-2.5)*2.2
  line(shimmer_x,y-1+top_y,shimmer_x+24,y-1+top_y,7)
  clip(0,y+top_y,128,2+8*byt,1)
  fillp(0b0101101001011010.1)
  rectfill(0,y+top_y,128,y+8+bottom_y,1)
  fillp()
  print_bold("#"..boss_txt.." - "..local_boss_name,64,y+2,7,13,align_c)
  clip()
  line(0,y+9+bottom_y,128,y+9+bottom_y,13)
  line(128-shimmer_x,y+9+bottom_y,128-shimmer_x-24,y+9+bottom_y,7)
 end
 
 if game_saved>0 and game_saved%.2>.1 then
  print_bold("game saved",64,120,7,13)
 else
  if player_ship_unlocked_t>0 and player_ship_unlocked_t%.2>.1 then
   print_bold("new ship unlocked!",64,120,7,13)
  end
 end
 
 if show_title or show_title_fade_t>0 then
  local fadeout_t=mid(0,show_title_fade_t/.5,1)
  local byt=show_title and mid(0,(t())/.5,1) or fadeout_t
  local by=-125+min(130,130*byt*byt)
  
  print_spr(133,4,5, 48,by,42,16)
  
  byt=show_title and mid(0,(t()-.5)/.5,1) or fadeout_t
  by=-125+min(150,150*byt*byt)
  print_spr(149,16,5, 36,by,60,16)
  
  byt=show_title and mid(0,(t()-1)/.5,1) or fadeout_t
  by=-125+min(170,170*byt*byt)
  print_spr(165,16,5, 36,by,60,16)
  
  byt=show_title and mid(0,(t()-1.5)/.5,1) or fadeout_t
  by=-125+min(190,190*byt*byt)
  print_spr(181,24,5, 21,by,90,16)
 
  byt=show_title and mid(0,t(),1) or fadeout_t
  by=8*byt
  print_bold("guerragames 2019",60,121+8-by,7,13)
  
  if(t()>2.5 and t()%.4>.2)print_bold("press \142 or \151 to start",60,110,7,13)
 
 else
  if not game_select_active and boss_level==0xffff.ffff then
   print_bold("you beat all 4 giga boss fights",64,40,7,13)
   print_bold("(i know you cheated, so whatevs)",64,50,7,13)
   print_bold("congratulations!",64,60,7,13)
   print_bold("you won!",64,70,7,13)
  end
 end
end

-- ui box

ui_box_center,ui_box_max_radius,ui_box_radius=48,28,0
ui_box_fade_in,ui_box_fade_out=.2,.2

ui_box_state_into,ui_box_state_loop,ui_box_state_out,ui_box_state_finished,ui_box_state_out_cancel,ui_box_state_canceled=0,1,2,3,4,5
ui_box_state,ui_box_state_timer=ui_box_state_into,0

ui_box_screen_gamemode,
ui_box_screen_ship,
ui_box_screen_fight,
ui_box_screen_gameover=0,1,2,3
ui_box_screen=ui_box_screen_gamemode

game_mode_regular,
game_mode_attract,
game_mode_permadeath=1,2,3
game_mode=game_mode_regular

game_modes_names={"normal","attract","permadeath"}

game_modes_desc={"3 lives, infinite continues",
                 "infinite lives",
                 "1 life, 2x pow, no continues"}

--
function ui_box_set_screen(screen,radius)
 ui_box_screen,ui_box_max_radius,ui_box_state,ui_box_state_timer=screen,radius,ui_box_state_into,0
end

-- 
function ui_box_check_buttons(disallow_cancel)
 if not disallow_cancel and (btnp(4) or ui_mouse_back()) then
  player_mouse_released=false
  ui_box_state_timer,ui_box_state=0,ui_box_state_out_cancel
 elseif btnp(5) or ui_mouse_fwd() then
  player_mouse_released=false
  ui_box_state_timer,ui_box_state=0,ui_box_state_out
 end
end

--
function ui_box_update()
 ui_box_state_timer+=one_frame

 if ui_box_state==ui_box_state_into then
  ui_box_radius=ui_box_max_radius*(ui_box_state_timer/ui_box_fade_in)
  
  if ui_box_state_timer>ui_box_fade_in then
   ui_box_state_timer,ui_box_state,ui_box_radius=0,ui_box_state_loop,ui_box_max_radius
  end
 elseif ui_box_state==ui_box_state_out or ui_box_state==ui_box_state_out_cancel then
  ui_box_radius=ui_box_max_radius*(1-ui_box_state_timer/ui_box_fade_out)
  
  if ui_box_state_timer>ui_box_fade_out then
   ui_box_state_timer,ui_box_radius=0,0
   ui_box_state=(ui_box_state==ui_box_state_out) and ui_box_state_finished or ui_box_state_canceled
  end
 end
end

-- 
function ui_box_draw()
 fillp(0b0101101001011010.1)
 rectfill(-1,ui_box_center-ui_box_radius,128,ui_box_center+ui_box_radius,1)
 fillp()
end

-- 
function ui_box_postdraw()
 rect(-1,ui_box_center-ui_box_radius,128,ui_box_center+ui_box_radius,13)
 
 local shimmer_x=256*ui_box_state_timer-128
 line(shimmer_x,ui_box_center-ui_box_radius,shimmer_x-24,ui_box_center-ui_box_radius,7)
 line(128-shimmer_x,ui_box_center+ui_box_radius,128-shimmer_x+24,ui_box_center+ui_box_radius,7)

end

-- game select screen
game_select_active=false

--
function player_ship_max_unlock()
 local best_score=shl(max(regular_boss_level,max(attract_boss_level/2,(permadeath_max_boss_level-0x0.0032)*5)),16)
--[[]]
 local best_i=1
 for i=1,#player_ship_req_scores do
  if(player_ship_req_scores[i]>best_score)return best_i
  best_i=i
 end
 --]]
 return #player_ship_req_scores
end

--
function game_select_update()
 if game_select_active then
  ui_box_update()
  
  --[[game mode select screen]]
  if ui_box_screen==ui_box_screen_gamemode then
   if ui_box_state==ui_box_state_finished then
    player_spr_max_index=player_ship_max_unlock()
    ui_box_set_screen(ui_box_screen_ship,28)
   end
   
   if btnp(2) or ui_mouse_left() then
    player_mouse_released=false
    game_mode=max(1,game_mode-1)
   end
   if btnp(3) or ui_mouse_right() then
    player_mouse_released=false
    game_mode=min(#game_modes_names,game_mode+1)
   end
   
   if game_mode==game_mode_regular then
    boss_level,player_lives=regular_boss_level,regular_player_lives
   elseif game_mode==game_mode_attract then
    boss_level,player_lives=attract_boss_level,attract_player_lives
   else --game_mode_permadeath
    boss_level,player_lives=permadeath_boss_level,0
   end
   
   if ui_box_state==ui_box_state_into or ui_box_state==ui_box_state_loop then
    ui_box_check_buttons(true)
   end
  end
   
  --[[ship select screen]]
  if ui_box_screen==ui_box_screen_ship then
   if ui_box_state==ui_box_state_finished then
    music(0,0,7)
    ui_box_set_screen(ui_box_screen_fight,32)
   elseif ui_box_state==ui_box_state_canceled then
    ui_box_set_screen(ui_box_screen_gamemode,28)
   end
   
   if ui_box_state==ui_box_state_into or ui_box_state==ui_box_state_loop then
    ui_box_check_buttons()
    
    if btnp(0) or ui_mouse_left() then
     --sfx(18)
     player_mouse_released=false
     player_spr_index=max(1,player_spr_index-1)
    end
    if btnp(1) or ui_mouse_right() then
     --sfx(18)
     player_mouse_released=false
     player_spr_index=min(player_spr_max_index,player_spr_index+1)
    end
   
   end
  end
   
  --[[fight screen]]
  if ui_box_screen==ui_box_screen_fight then
   if ui_box_state==ui_box_state_finished then
    player_x,player_y=64,96
    game_restart()
    game_select_active=false
   end
   
   if ui_box_state_timer>1 then
    ui_box_state_timer=0
    ui_box_state=ui_box_state_out
   end
  end
  
  --[[gameover screen]]
  if ui_box_screen==ui_box_screen_gameover then
   if ui_box_state==ui_box_state_loop and ui_box_state_timer>2 then
    ui_box_check_buttons(true)
   end
   
   if ui_box_state==ui_box_state_finished then
    --todo: continue?
    ui_box_set_screen(ui_box_screen_gamemode,28)
   end
  end
 end
end

--

select_ship_angle,select_ship_target_angle=0,0

--
function game_select_draw()
 if game_select_active then
  
  ui_box_draw()
  
  local oy=ui_box_center-ui_box_max_radius
  
  clip(-1,ui_box_center-ui_box_radius,130,2*ui_box_radius+1)

  --[[game mode select]]
  if ui_box_screen==ui_box_screen_gamemode then
   print_bold("game mode",66,oy+4,7,13)
   
   for i=1,#game_modes_names do
    local m=game_modes_names[i]
    local c=7
    
    if game_mode==i then
     m="+ "..m.." +"
     c=12
    end
    
    print_bold(m,64,oy+8+i*7,c,13)
   end
   
   print_bold(game_modes_desc[game_mode],64,oy+38,6,13)
   
   print_bold("\151ok",64,oy+48,7,13)
  end
  
  --[[ship select]]
  if ui_box_screen==ui_box_screen_ship then
   print_bold("choose your ship!",64,oy+4,7,13)

   select_ship_target_angle=.25+.8*player_spr_index/#player_spr_list -- 90 degrees spread
   
   if abs(select_ship_target_angle-select_ship_angle)<.005 then
    select_ship_angle=select_ship_target_angle
   else
    select_ship_angle+=(select_ship_target_angle-select_ship_angle)*.25
   end
   
   local centerx,centery,magx,magy=64,oy+44,76,32
  
   for i=1,#player_spr_list do
    local a=select_ship_angle-.8*i/#player_spr_list
    local x,y=centerx+magx*cos(a),centery+magy*sin(a)
    if(i>player_spr_max_index)pal(7,5)pal(6,5)pal(13,5)pal(8,5)
    spr(player_spr_list[i],x-8,y+2,2,2)
    pal()
   end
   
   spr(2,62,oy+20)
   print_bold("\139select\145",60,oy+36,7,13)
   
   print_bold("\151ok",64,oy+48,7,13)
  end
  
  --[[fight screen]]
  if ui_box_screen==ui_box_screen_fight then
   print_spr(144,24,5,4,oy+5,120,53)
  end
  
  --[[game over screen]]
  if ui_box_screen==ui_box_screen_gameover then
   print_spr(160,36,5,5,oy+5,120,29)
  end
  
  clip()
  ui_box_postdraw()
  
 end
end

--
function ui_mouse_fwd()
 return player_mouse_released and player_mouse_sy<-1
end

--
function ui_mouse_back()
 return player_mouse_released and player_mouse_sy>1
end

--
function ui_mouse_left()
 return player_mouse_released and player_mouse_sx<-1
end

--
function ui_mouse_right()
 return player_mouse_released and player_mouse_sx>1
end

--
game_load()

show_title,show_title_fade_t=true,0

--
function _init()
 music(1,0,7)
 menuitem(1,"reset progress?!",game_reset)

 ebs_reset()
end

--
function _update()
 one_frame=1/stat(8)
 
 game_select_update()
 
 if t()>2.5 and (show_title) then
  if btnp(4) or btnp(5) or ui_mouse_fwd() then
   player_mouse_released=false
   show_title,show_title_fade_t=false,.5
   game_select_active=true
  end
 end
 
 if(show_title_fade_t>0)show_title_fade_t-=one_frame
 
 shoot_button:button_update()
 level_update()
 stars_update()
 player_update()
 boss_update()
 pbullets_update()
 ebs_update()
 
 parts_update()
 boom_update()
 player_dying_update()
end

--
function _draw()
 camera(cam_shake_x,cam_shake_y)
 cls()
 
 stars_draw()
 boss_draw()
 player_draw()
 pbullets_draw()
 ebs_draw()
 
 player_target_draw()
 
 parts_draw()
 boom_draw()
 
 ui_draw()
 
 game_select_draw()
 
 cpu=stat(1)
 
 pal()
 color(7)
 y=110

 --print("mem:"..stat(0),1,y)y-=6
 --print("cpu:"..cpu,1,y)y-=6
 
end
__gfx__
00000000000000000cc000000606000000000000000000000000000000000000000000000000000000000dd00dd00000000000dddd0000000000000000000000
0000000000000000cbbc000007070000000000077000000000000dd00dd0000000000dd00dd000000000d770077d00000000dd6776dd00000000000000000000
0000000000000000cbbc00007dbd7000000000d77d0000000000d670076d00000000d770077d0000000d67d00d76d000000d67777776d0000000000000000000
00000000000000000cc000007dcd70000000007777000000000d77d00d77d000000d7d0000d7d00000d7770000777d0000d6777777776d000000000000000000
000000000000000000000000d777d00000000d7667d0000000d67d0000d76d000007d000000d700000d7dd7007dd7d0000d7776666777d000dd0000000000dd0
0000000000000000000000000ddd00000000d776677d00000d676d0000d676d0000d00000000d000000d00700700d0000d6776dddd6776d0d67000000000076d
00000000000000000000000000000000000077dddd7700000d77d000000d77d00000000000000000000000dddd0000000d776dddddd677d0d77000000000077d
00000000000000000000000000000000000d7dddddd7d000d676dd0000dd676d066000000000066000000dddddd00000d6776dddddd6776dd76000000000067d
0000000000000000000000000000000000077dddddd77000d676dddddddd676d677600000000677600000dddddd00000d7776dddddd6777dd7000dddddd0007d
0000000000000000000000000000000000d77dddddd77d00d776dddddddd677d677600000000677600000dddddd00000d7776dddddd6777dd7000dddddd0007d
00000000000000000000000000000000007776dddd677700d7776dddddd6777d07600000000006700000d7dddd7d0000d77776dddd67777dd70006dddd60007d
000000000000000000000000000000000077667777667700d77776dddd67777d0700000000000070000d77d00d77d000d67777666677776dd76006666660067d
000000000000000000000000000000000d776677776677d0d67766677666776dd70000677600007d000d67d00d76d0000d677777777776d0d77000677600077d
000000000000000000000000000000000777dd7667dd77700d66dddddddd66d0d7000dddddd0007d000dddd00dddd00000d66dddddd66d00d67777dddd77776d
00000000000000000000000000000000d76d88d66d88d67d00dd88888888dd00d000dd8888dd000d000d88d00d88d000000dd888888dd0000dd00d8888d00dd0
00000000000000000000000000000000d000dd0000dd000d0000dddddddd0000d0000dddddd0000d0000dd0000dd000000000dddddd00000000000dddd000000
0000000000000000000000000000000000000dd00dd0000000000000000000000000000000000000000000d00d00000000000000000000000000000000000000
00000dd00dd00000000000d00d0000000000d770077d0000000000d00d00000000000dd00dd000000000007dd70000000000000000000000000000d00d000000
0000d670076d000000000d6006d00000000d67d00d76d00000000d6006d000000000d670076d0000000d00777700d000000000000000000000000d6006d00000
000d77d00d77d0000000d670076d000000d6760000676d000d00d670076d00d0000d77d00d77d00000d6006776006d0000000000000000000000d670076d0000
00d67d0000d76d00000d67d00d76d0000d67dd6006dd76d0d70d67d00d76d07d00d67d0000d76d000d6d00077000d6d00dd0000000000dd0000d67d00d76d000
0d676d0000d676d0000d77d00d77d000d67d00700700d76dd70d77d00d77d07d0d676000000676d0d67000066000076dd67000000000076d00d677d00d776d00
0d77d000000d77d0000d7dd00dd7d000d7d000dddd000d7dd70d7dd00dd7d07d0d770000000077d0d7d000dddd000d7dd77000000000077d00d67dd00dd76d00
d676dd0000dd676d000d7dddddd7d000d7d00dddddd00d7dd7777dddddd7777dd67d00000000d76dd7d00dddddd00d7dd77600000000677d0d677dddddd776d0
d676dddddddd676d000d7dddddd7d000d7d00dddddd00d7dd7677dddddd7767dd7600dddddd0067dd7d00dddddd00d7dd7766dddddd6677d0d677dddddd776d0
d776dddddddd677d000d7dddddd7d000d7d00dddddd00d7dd7d67dddddd76d7dd7d00dddddd00d7dd7d00dddddd00d7dd7776dddddd6777d0d777dddddd777d0
d7776dddddd6777d000d76dddd67d000d67dd7dddd7dd76dd60d76dddd67d06dd70006dddd60007dd67dd7dddd7dd76dd77776dddd67777d0d7776dddd6777d0
d67776dddd67776d00d6777777776d000d6777d00d7776d00d00d777777d00d0d600066dd660006d0d6777d00d7776d0d77006666660077d0d677777777776d0
dd006667766600dd00d7766666677d0000dd76d00d67dd0000000d6666d00000d60000677600006d00dd76d00d67dd00d77000677600077d0d677666666776d0
00000dddddd0000000d66dddddd66d00000dddd00dddd00000000dddddd00000d0000dddddd0000d000dddd00dddd000d67000dddd00076d00d66dddddd66d00
0000dd8888dd0000000dd888888dd000000d88d00d88d00000000d8888d00000d000dd8888dd000d000d88d00d88d0000dd00d8888d00dd0000dd888888dd000
00000dddddd000000000dddddddd00000000dd0000dd0000000000dddd00000000000dddddd000000000dd0000dd0000000000dddd0000000000dddddddd0000
00000000000000000000000000000000000000000000000000000dd00dd000000000000000000000000000077000000000000000000000000000000000000000
70000060060000070000dd0000dd000000000dd00dd000000000d770077d000000000d6006d00000000000d77d000000000ddd0000ddd00000d7776006777d00
7000007007000007000d67000076d0000000d770077d0000000d67700776d0000000d770077d000000000067760000000d677760067776d00d760000000067d0
7d000070070000d700d6760000676d000000d770077d000000d6767007676d00000d76700767d00000000d7777d0000000000070070000000d700000000007d0
7d000076670000d700d7600000067d0000000dd00dd000000d67dd7667dd76d00007d070070d70000000d776677d00000d677766667776d00d677600006776d0
76000077770000670d670000000076d00000000000000000d67d00777700d76d000d00700700d0000000760000670000d67d06dddd60d76dd67d00000000d76d
77d00d7dd7d00d770d760000000067d000dd00000000dd00d7d000dddd000d7d00000d7dd7d00000000dd000000dd000d7000dddddd0007dd76000dddd00067d
676d7dddddd7d676d67000000000076d0d77d000000d77d0d7d000dddd000d7d0dd00dddddd00dd00007000000007000000d6dddddd6d00007000dddddd00070
d7777dddddd7777dd77000000000077d0d77d000000d77d0d7d000dddd000d7dd6777dddddd7776d00070000000070000d676dddddd676d007000dddddd00070
d7767dddddd7677dd77000000000077d00dd00000000dd00d7d000dddd000d7dd7760dddddd0677d00d7700000077d00d6700dddddd0076dd7000dddddd0007d
076d0dddddd0d670d77000000000077d0000000000000000d67d00000000d76d07600dddddd006700077700000077700d70d66dddd66d07dd76000dddd00067d
07d000dddd000d70d67600000000676d00007766667700000d677d0000d776d007d000dddd000d700076670000766700d60670666607606dd67606766760676d
d70000677600007d0d677777777776d0000777777777700000dd76d00d67dd00d70000677600007d0d766700007667d000d700d77d007d0000d777d77d777d00
d70000dddd00007d00d66dddddd66d00000d6dddddd6d000000dddd00dddd000d70000dddd00007d077dddd00dddd77000d600dddd006d0000d677dddd776d00
d0000d8888d0000d000dd888888dd0000000d888888d0000000d88d00d88d000d0000d8888d0000dd7d8888dd8888d7d000d0d8888d0d000000d0d8888d0d000
d00000dddd00000d00000dddddd0000000000dddddd000000000dd0000dd0000d00000dddd00000dd00dddd00dddd00d000000dddd000000000000dddd000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77700770077007700077707770077070707770007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707070700070000070000700700070700700007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77007070777077700077000700700077700700007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707070007000700070000700707070700700000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77707700770077000070007770777070700700000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77707770777077007070777000000000000000000770777007707770000000000000000000000000000000000000000000000000000000000000000000000000
70707000707070707070007000000000000000007000070070007070000000000000000000000000000000000000000000000000000000000000000000000000
77007700777070707770077000000000000000007000070070007770000000000000000000000000000000000000000000000000000000000000000000000000
70707000707070700070000000000000000000007070070070707070000000000000000000000000000000000000000000000000000000000000000000000000
70707770707077707770070000000000000000007770777077707070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07707770777077700770707077707770070000007770077007700770000000000000000000000000000000000000000000000000000000000000000000000000
70007070777070007070707070007070070000007070707070007000000000000000000000000000000000000000000000000000000000000000000000000000
70007770707077007070707077007700070000007700707077707770000000000000000000000000000000000000000000000000000000000000000000000000
70707070707070007070777070007070000000007070707000700070000000000000000000000000000000000000000000000000000000000000000000000000
77707070707077707700070077707070070000007770770077007700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007770777007707070777007700000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007000070070007070070070000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007700070070007770070077700000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007000070070707070070000700000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007000777077707070070077000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01020002180711a071000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
01010003185711c5711f5710050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501
0108000036670366703667034670316602f6602c66028660236501e64018630126200b61005610026100060000600006000060000600006000060000600006000060000600006000060000600006000060000600
01020002187711a771007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
0108000006670066700667004670016500b65008630046300b6200662000620066200b61005610026100060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010200001777208762117520674209722007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702
0003000026773247730a773217731f7730a7631d7531b75309743127430f733047330771305713007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
010a00003f4533f65331643306432e6332a6332a633256331f6331d6331b63319633176231662315623146231462313623126230f6230d6230a6130861305613036130161301613136030f6030b6030760300603
010800003b6422d64128631236311d6311963116631146310f6310c6310c6310b6310b6310a631096310963109631096310663105621046210362103621036210362103611036110161100611006110061100611
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001087010870108701087010870108701387013870128701387012870138701587013870128701587017870108701087010870108701087013870108701087013870108701387017870158701787013870
0110000010910109101091010910109101091010910109101d9101d9101d9101d9101d9101d9101d9101d9101a9101a9101a9101a9101c9101c9101d9101d9101c9101c9101d9101d9101a9101c9101d9101a910
011000001084110840108401084010840108401082210812138411384013840138401384013840138221381215841158401584015840158401584015822158121784117840178301781218841188401883018812
011000000c6230c6230c6230c6230c6230c6230c6130c61310633106331062310623106131061310613106130c6230c6230c6230c6230c6230c6230c6130c6131563315633156231562315613156131561315613
011000001cb311cb351fb351fb3521b3521b351fb351fb3523b3123b3521b3521b351fb351fb3521b3121b3521b3121b3521b3521b3523b3523b3521b3521b3524b3124b3523b3523b3521b3521b3523b3123b35
0110000021b3121b3521b3521b3523b3123b3521b3521b3524b3524b3523b3523b3121b3521b3523b3123b3523b3123b3523b3523b3524b3524b3123b3523b3526b3126b3524b3124b3523b3523b3524b3124b35
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000158411584015840158401584015840158221581218841188401884018840188401884018822188121a8411a8401a8401a8401a8401a8401a8221a8121c8411c8401c8301c8121d8411d8401d8301d812
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001cb351cb35000001fb351fb350000021b3521b350000023b3523b350000024b350000026b350000021b3521b350000023b3523b350000024b3524b350000026b3526b350000028b350000029b3500000
010f00001042210425000001042210412000001041210412134221342500000134221341200000134121341215422154250000015422154120000015412154121842218425000001842218412000001841218412
010f00000c6230c623000000c6230c623000000c6130c61310633106330000010623106130000010613106130c6230c623000000c6230c623000000c6130c6131563315633000001562315613000001561315613
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 18 1a 19 44
01 0d 0e 0f 44
00 0d 0e 0f 44
00 14 0e 10 44
02 14 0e 10 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
