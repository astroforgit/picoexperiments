pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- road rex
-- by @powersaurus
-- the car is based on the toyota yaris,
-- i don't know why, it just came to
-- mind when i wanted a sensible
-- car to reference
--8064
timer=0
max_shock=8
max_distance=1760
type_warning=0
type_speed_cam=1
type_speed_cam_warn=2
type_junction=3
type_junction_warn=4
sounds_on=true --false
help_msg=""
help_msg_timer=0

function set_help_msg(msg,timer,fixed)
 fixed=fixed or false
 help_msg_col=7
 if help_msg_fixed and help_msg_timer>0 then
  return
 end
 if fixed then 
  help_msg_fixed=fixed
 end
 help_msg=msg
 help_msg_timer=timer
 
end

function sound(id,chan)
 chan=chan or 0
-- if sounds_on and stat(16+chan)~=id then
 if sounds_on and stat(16+chan)==-1 then
  sfx(id,chan)
 end
end

function clamp(val,minval,maxval)
 return max(min(val,maxval),minval)
end

function rand(x)
 return flr(rnd(x))
end

function _init()
 music(0)
 palt(14,true)
 palt(0,false)
 
 make_clouds()
 
 _draw=draw_title
 _update=update_title
end

--7682 -> 7653
function make_dino()
 return {
  x=38,
  y=125,
  floor=108,
  vx=0,
  vy=0,
  angle=320,
  jump_time=0,
  laser_time=0,
  lasers_on=false,
  laser_charge=100,
  shockwave_timer=0,
  peak=floor,
  is_dino=true,
  points=0,
  power_up_timer=0,
  speed_bonus=0
 }
end
function init_level()
 timer=0
 music(0)
 palt(14,true)
 palt(0,false)
 dino=make_dino()
 blue_dino=make_dino()
 blue_dino.is_blue_dino=true
 blue_dino.is_dino=false
 blue_dino.x=0
 blue_dino.y=-64
-- blue_dino.active=true
 
 make_clouds()
 
 lanes={{},{},{}}

 for i=1,5 do
  local cr=make_car({})
  cr.x+=128
 end
 add_car_to_lane(dino,lane_for_dino(dino))
 add_car_to_lane(blue_dino,lane_for_dino(dino))

 heli_plans={} 
 helis={}
 for i=0,6 do
  local heli_position=
   rnd(max_distance-100)+100
  add(heli_plans,{distance=heli_position})
 end

 particles={}
 points={}
 sign_plans={}
 signs={}

 global_speed=60
 dino_speed=global_speed
 distance=max_distance
 
 halfway=false
 warnings=3
 
 local speed_cam_position=rnd(max_distance-100)+100
 add(sign_plans,{distance=max_distance/2,typ=type_junction_warn})
 add(sign_plans,{distance=300,typ=type_warning})
 add(sign_plans,{distance=200,typ=type_warning})
 add(sign_plans,{distance=100,typ=type_warning})
 add(sign_plans,{distance=0,typ=type_junction})
 add(sign_plans,{distance=speed_cam_position,typ=type_speed_cam_warn})
 add(sign_plans,{distance=speed_cam_position-50,typ=type_speed_cam})
 
 snapshot=nil
 shown_snapshot=false
 shown_scores=false
 shown_cut_scene=false
 cut_scene_progress=0
 news_reports={}
 number_reports=0

 points_timer=0 
 help_msg_timer=0
 set_help_msg("i need to get home!",90,false)
end

function make_clouds()
 clouds={}
 for i=1,30 do
  clouds[i]=make_cloud({})
  clouds[i].x=rnd(256)
 end
end

function make_sign(x,y,sp,h,w)
 return {
  x=x,
  y=y,
  sp=sp,
  w=w,
  h=h
 }
end

function make_particle(x,y,vx,vy,life,sp,sz,frames,frame_speed)
 frame_speed=frame_speed or 0
 local spx=0
 local spy=0
 
 spy=flr(sp/16)*8
 spx=sp%16*8
  
 local particle={
  spx=spx,
  spy=spy,
  x=x,
  y=y,
  vx=vx,
  vy=vy,
  life=life,
  sz=sz,
  sc=8,
  frame=0,
  frames=frames,
  frame_speed=frame_speed
 }
 return particle
end

function make_cloud(cloud)
 local size=rand(4)
  
 cloud.x=256+rnd(30)
 cloud.size=size

 local y=rnd(16)+64
 if size==0 then
  y=rnd(32)
 elseif size==1 then
  y=rnd(16)+32
 elseif size==2 then
  y=rnd(16)+48
 end
 cloud.y=y
 return cloud
end

contents={{n="bread",s=56},
  {n="beans",s=238},
  {n="cheese",s=254},
  {n="glue",s=58},
  {n="gravy",s=57},
  {n="eggs",s=255},
  {n="milk",s=58},
  {n="chilli",s=59},
  {n="kebabs",s=239},
  {n="curry",s=59},
  {n="crisps",s=202},
  {n="shoes",s=202}
  }

function lane_for_dino(d)
 if d.floor==108 then
  return 1
 elseif d.floor==116 then
  return 2
 elseif d.floor==125 then
  return 3
 end
end

function lane_for_car(c)
 if c.floor==90 then
  return 1
 elseif c.floor==99 then
  return 2
 elseif c.floor==108 then
  return 3
 end
end

function add_car_to_lane(c,l)
 add(lanes[l],c)
end

function remove_car_from_lane(c,l)
 del(lanes[l],c)
end

function make_car(car)
 car.respawn=true
 car.vx=rnd(6)
 car.vy=0
 car.base_speed=50-10*car.vx
 car.x=rnd(64)+256
 if rand(2)==0 then
  car.x=-48
 end
-- 108/117/126
 car.y=90+(flr(car.vx/2)*9)
 car.floor=car.y
 car.life=36
 car.flash_timer=0
 car.col=rand(3)
 local typ=rand(5)
 car.typ=0
 car.points=15
 if typ>3 then
  car.typ=1
  car.life=150
  car.points=50
 end
 if car.typ==1 then
  local contents=contents[rand(12)+1]
  car.contents=contents
 end
 car.id=rand(30000)
 
 add_car_to_lane(car,lane_for_car(car))
 return car
end

function make_heli()
 local l_or_r=rand(2)*2-1
 --7653 -> 7644
 local heli={
  x=128+l_or_r*170,
  y=40,
  vy=0,
  vx=0,
  col=rand(3),
  flash_timer=0,
  life=70,
  snap_delay=60+rand(30),
  points=75
 }
 
 return heli
end

function update_level()
 timer+=1
 
 if help_msg_timer>0 then
  help_msg_timer-=1
 end
 if points_timer>0 then
  points_timer-=1
 end
 
 if not dino.on_lorry then
  if btn(0) then
   if dino.y==dino.floor then
    dino.vx-=0.001
   else
    dino.vx-=0.1
   end
  end
  if btn(1) then
   if dino.y==dino.floor then
    dino.vx+=0.7
   else
    dino.vx+=0.8
   end
  end
 end
 if btn(2) and dino.lasers_on then
  dino.angle=(dino.angle-5)%360
 end
 if btn(3) and dino.lasers_on then
  dino.angle=(dino.angle+5)%360
 end
 if btnp(2) and not dino.jumping and not dino.lasers_on then
  dino.jump_time=5
  jump(dino)
  dino.switched_lanes=true
  dino.quick_switch=true
  dino.switch_up=true
 end
 if btnp(3) and not  dino.jumping and not dino.lasers_on then
  dino.jump_time=5
  jump(dino)
  dino.switched_lanes=true
  dino.quick_switch=true
  dino.switch_down=true
 end
 if btn(4)
 and dino.jump_time<15
 and not dino.jumping then
  if dino.jump_time==0 then
   sound(3,1)
  end
  dino.jump_time+=1
 elseif dino.jump_time>0 then
  jump(dino)
 end

 if not dino.super_lasers then
  if btn(5) then
   if not dino.lasers_on then
    dino.laser_time=0
   end
   dino.lasers_on=true
  else
   dino.lasers_on=false
  end
 end
 
 update_dino(dino)
 update_blue_dino(blue_dino)
 update_clouds(clouds)
 update_cars()
 update_helis()
 update_particles()
 update_points()

 distance-=(dino_speed/2.045)/30
 
 if distance<0
 and not dino.reached_junction then
  dino.reached_junction=true
  if dino.floor~=108 then
   dino.missed_junction=true
   set_help_msg("you missed your turn!",600,true)
  else
   dino.speed_bonus=2200-timer
   set_help_msg("exited the motorway!",600,true)
   for i=1,3 do
    local lane=lanes[i]
    for c in all(lane) do
     c.respawn=false
    end
   end
  end
 end
 
 if distance<-100 and not fading_out then
  level_end_time=timer

  _update=update_results
  _draw=draw_results
  next_screen()
 end
 
 update_signs(signs,sign_plans)
 
end

function draw_lost()
 timer=0
 dino.x=54
 dino.y=120
 dino.lasers_on=false
 dino.shockwave_timer=0
 fade_pal(4)
 draw_world(
  -1,
  {x=0,y=0},--dino
  clouds,--clouds
  signs,
  {},
  {},
  {},
  1600,
  reset_pal)
 
 reset_pal()
 
 draw_dino(dino)
 colour_print("great,i'm lost!",36,20,7,1)
end

function update_clouds(clouds)
 local mod=0
 if (dino_speed>100) mod=-4
 for c in all(clouds) do
  c.x+=-1/(c.size+1)+(mod+4-global_speed/12.5)/(c.size+1)
  if c.x<-32 then
   make_cloud(c)
  end
 end
end

function update_signs(signs,sign_plans)
 local spd=global_speed/12.5
 for s in all(signs) do
  s.x-=spd
  
  if s.action then
   s:action()
  end
  
  if s.x<-32 then
   del(signs,s)
  end
 end
 
 for s in all(sign_plans) do
  if distance<s.distance then
   if s.typ==type_warning then
    local warning_sign=make_sign(128,63,70,2,2)

    warning_sign.action=function (s)
     set_help_msg("get in the exit lane!",30)
     help_msg_col=8
    end
    
    add(signs,warning_sign)
   elseif s.typ==type_junction_warn then
    add(signs,make_sign(128,63,70,2,2))
   elseif s.typ==type_speed_cam then
    local speed_cam=make_sign(128,63,96,2,1)
    speed_cam.action=function (s)
     if s.x<32
     and not s.snapped
					and dino_speed>70
     then
      snapshot=take_snapshot(true)
      s.snapped=true
      s.snap_time=timer
      set_help_msg("speed camera!!!",60)
     end
    end
    speed_cam.draw=function(s)
     if s.snapped then
      local radius=7-12*sin(2*(timer-s.snap_time)/16)
      circfill(s.x+18,s.y+5,radius+1,0)
      circfill(s.x+18,s.y+5,radius,7)
     end
    end
    add(signs,speed_cam)
   elseif s.typ==type_speed_cam_warn then
    add(signs,make_sign(128,63,102,2,2))
   elseif s.typ==type_junction then
    add(signs,make_sign(128,63,68,3,2))
   end
   del(sign_plans,s)  
  end
 end
end

function init_level_with_fade()
 _draw=draw_level
 _update=update_level
 init_level()
end

function update_title()
 if btnp(5) and not fading_out then
  sound(5)
  init_level_with_fade()
 end
 timer+=1
end

cut_scene_button_press=false
function update_cut_scene()
 timer+=1
 if btnp(5) and not cut_scene_button_press then
  if cut_scene_progress==1 then
    sound(20)
  end
  cut_scene_progress+=1
  cut_scene_button_press=true
  if dino.missed_junction and cut_scene_progress==1 then
   cut_scene_progress=99
   news_reports={}
   sound(19)
  elseif cut_scene_progress==3
  or cut_scene_progress==4
  or cut_scene_progress==100 then
   _update=update_results
   next_screen()
    sound(20)
  end
 else
  cut_scene_button_press=false
 end
end

function update_results()
 if btnp(5) and not fading_out then
  next_screen()
 end
 global_speed=50
 timer+=1
 update_clouds(clouds)
end

potential_responses={
"what was that?!",
"unbelievable!",
"that could be anyone!",
"not how i remember it",
"i *really* wanted to\nget home!",
"the camera loves me!"
}

function next_screen()
 music(-1)
 if shown_scores then
  sound(5)
  init_level_with_fade()
 elseif snapshot and not shown_snapshot then
  shown_snapshot=true
  f_draw_results=draw_snapshot
 elseif not shown_cut_scene then
  shown_cut_scene=true
  f_draw_results=draw_cut_scene
  _update=update_cut_scene
  response=potential_responses[rand(6)+1]
 elseif #news_reports>0 then
  local report=news_reports[1]
  del(news_reports,report)
  report_timer=rand(400)
  f_draw_results=function()
   draw_news_report(report)
  end
  sound(20)
 elseif cut_scene_progress==3 then
  f_draw_results=draw_cut_scene
  _update=update_cut_scene
      
  sound(19)

 else
  shown_scores=true
  f_draw_results=draw_score
  music(0)
 end
end

function snapshot_dino(dino)
 return {
  x=dino.x,
  y=dino.y,
  lasers_on=dino.lasers_on,
  angle=dino.angle,
  shockwave_timer=dino.shockwave_timer,
  peak=dino.peak,
  floor=dino.floor,
  jump_time=dino.jump_time,
  laser_time=dino.laser_time,
  is_dino=true
 }
end

function take_snapshot(speed_cam)
 local messages={}
 local s_dino=snapshot_dino(dino)
 local snapshot={
  date=(rand(28)+1).."-"..(rand(12)+1).."-"..(rand(40)+1980),
  speed=dino_speed,
  timer=timer,
  dino=s_dino,
  distance=distance
 }

 snapshot.blue_dino=snapshot_dino(blue_dino)
 snapshot.blue_dino.is_blue_dino=true
 snapshot.blue_dino.is_dino=false
 
 snapshot.clouds={}
 for c in all(clouds) do
  add(snapshot.clouds,{x=c.x,y=c.y,size=c.size})
--  add(snapshot.clouds,c)
 end
 
 snapshot.lanes={{},{},{}}
 
 local bounced_cars=0
 local spilled_loads=0
 for i=1,3 do
 local lane=lanes[i]
 for c in all(lane) do
  if not is_dino(c) then
   local col=c.col
   if speed_cam then
    col=99
   end
   add(snapshot.lanes[i],{
    x=c.x,
    y=c.y,
    life=c.life,
    flash_timer=0,
    col=col,
    typ=c.typ,
    contents=c.contents
   })
   if c.typ==1 and c.spilled_load then
    spilled_loads+=1
   end
   if c.life<=0 and c.y<128then
    bounced_cars+=1
   end
  end
 end -- each car
 end -- lane
 
 snapshot.spilled_loads=spilled_loads
 snapshot.bounced_cars=bounced_cars
 
 snapshot.helis={}
 local exploding_helis=0
 local helis_in_shot=0
 for h in all(helis) do
  local col=h.col
  if speed_cam then
   col=99
  end
  add(snapshot.helis,{
   x=h.x,
   y=h.y,
   flash_timer=h.flash_timer,
   face_right=h.face_right,
   col=col,
   photographed=true
  })
  if h.life<0 then
   exploding_helis+=1
  end
  if h.x>-16 and h.x<120 
  and h.y>-16 and h.y<120 then
   helis_in_shot+=1
  end 
 end
 
 add(snapshot.lanes[lane_for_dino(s_dino)],s_dino)
 if snapshot.blue_dino then
  add(snapshot.lanes[lane_for_dino(snapshot.blue_dino)],snapshot.blue_dino)
 end
 
 snapshot.particles={}

 local explosions=0 
 for p in all(particles) do
  add(snapshot.particles,
   {
    spx=p.spx,
    spy=p.spy,
    frame=p.frame,
    sz=p.sz,
    sc=p.sc,
    x=p.x,
    y=p.y
   })
  if p.sp==132 then
   explosions+=1
  end
 end
 
 snapshot.signs={}
 
 for s in all(signs) do
  add(snapshot.signs,s)
 end
 
 if abs(blue_dino.x-dino.x)<64 then
  add_message(messages,"double dino",100)
 end
 if dino.lasers_on then
  if dino.on_lorry then
   add_message(messages,"lasers on a truck",100)
  else
   add_message(messages,"lasers",100)
  end
 end
 if dino.y~=dino.floor then
  add_message(messages,"jumping",25)
 end
 if dino.on_lorry then
  add_message(messages,"on a truck",100)
 end
 if spilled_loads>0 then
  add_message(messages,spilled_loads.."x spilled loads",50)
 end
 if explosions>0 then
  add_message(messages,explosions.."x explosions",explosions)
 end
 if bounced_cars>0 then
  add_message(messages,bounced_cars.."x bounced cars",bounced_cars*5) 
 end
 if helis_in_shot>0 then
  add_message(messages,helis_in_shot.."x helicopters",helis_in_shot*5) 
 end
 if exploding_helis>0 then
  add_message(messages,exploding_helis.."x exploding helicopters",exploding_helis*20) 
 end
 local px=dino.x
 local py=dino.y-85
 if px>32 and px<90 
 and py>5 then
  add_message(messages,"nice composition",50)
 end
 if dino_speed>90 then
  add_message(messages,"ridiculous speed",50)
 end
 snapshot.messages=messages
 
 return snapshot
end

function build_headline(snapshot)
 local potential_headlines={}
 local s_dino=snapshot.dino
 if s_dino.y<64 then
  add(potential_headlines,"drivers report dinosaur on evening commute")
 end

 if s_dino.lasers_on then
  add(potential_headlines,"laser dinosaur wreaks havoc")
 end
 if snapshot.bounced_cars and snapshot.bounced_cars>3 then
  add(potential_headlines,"multi-car pile up due to unruly dinosaur")  
 end
 if s_dino.on_lorry then
  add(potential_headlines,"dangerous dinosaur surfs on lorry")
 end
 if snapshot.spilled_loads then
  add(potential_headlines,"lorry spills load after dinosaur damage")
 end
 
 if #potential_headlines==0 then
  add(potential_headlines,"road users report 'great commute!'")
 end  
 return potential_headlines[1+rand(#potential_headlines)]
end

function add_message(messages,deets,points)
 add(messages,{m=deets,p=points}) 
end

function update_points()
 for p in all(points) do
  p.y-=(p.y-11)/5
  p.x+=(cam_x+118-p.x)/5
  if p.x>117 and p.y<12 then
   dino.points+=p.points
   points_timer=5
   del(points,p)
  end
 end
end

function update_particles()
 for p in all(particles) do
  p.life-=1
  if p.gravity then
   p.vy+=p.gravity
  end
  p.x+=p.vx
  p.y+=p.vy
  if timer%p.frame_speed==0 and p.frame<p.frames-1 then
   p.frame+=1
  end
  if p.floor and p.y>p.floor then
   p.y-=p.vy
   p.vy*=-1
   if p.dampening then
    p.vy*=p.dampening
   end
  end
  if p.pickup and not p.collected and p.life<=90 then
   if p.x>dino.x-16 and p.y>dino.y-48
   and p.x<dino.x+25 and p.y<dino.y then
    if p.pickup_timer<4 then
     p.pickup_timer+=1
    else
     sound(5)
     p.collected=true
     p.life=8
     p.vx=0
     p.vy=-3
     p.gravity=0
     -- dino should show 
     -- the pickup you got
     p.flash=true
     if p.typ==0 then
      dino.laser_charge=100
      set_help_msg("full lasers!",60)
     elseif p.typ==1 then
      dino.vx=30
--      blue_dino.vx-=10
      
      for lane in all(lanes) do
       for c in all(lane) do
        if not is_dino(c) then
         c.vx-=2
        end
       end
      end
      
      dino.power_up=1
      dino.power_up_timer=30
      set_help_msg("speed boost!",60)
      sound(17,1)
     elseif p.typ==2 then
      dino.super_lasers=true
      dino.laser_charge=100
      dino.angle=320
      dino.lasers_on=true
      dino.power_up_timer=60
      set_help_msg("super lasers!",60)
     elseif p.typ==3 then
      for i=0,20 do
       local c=make_car({})
       c.respawn=false
       c.x=128+rnd(8)*16
      end
      set_help_msg("traffic!",60)      
     end
    end
   end
  end
  if p.life<=0 then
   del(particles,p)
  end
 end
end

function update_helis()
 for h in all(helis) do
  update_heli(h)
  
  if h.life<0 and h.y>200 then
   del(helis,h)
  elseif h.y<-60 then
   if h.snapshot then
    add(news_reports,h.snapshot)
    number_reports+=1
    set_help_msg(
    "traffic copter got some footage!",60)
   end
   del(helis,h)
  end
 end
 
 for p in all(heli_plans) do
  if distance<p.distance then
   add(helis,make_heli())
   del(heli_plans,p)
  end
 end
end

function update_heli(h)
 local hx=h.x+24
 local hy=h.y+16
 local max_y=300
 local min_y=-40
 
 -- think
 if h.life>0 then
  max_y=80
  if hx>dino.x+40 then
   h.vx=max(h.vx-0.1,-3)
   h.face_right=false
  else
   h.vx=min(h.vx+0.1,3)
   h.face_right=true 
  end
  if hy>dino.y-85 then
   h.vy=max(h.vy-0.1,-2) 
  else
   h.vy=min(h.vy+0.1,2)
  end
  if dino.lasers_on then
   if dino.angle>90 and dino.angle<270 then
    h.vy=min(h.vy+0.2,2)
   else
    h.vy=max(h.vy-0.2,-2)   
   end
  end
  if h.snap_time and timer-h.snap_time>90 then
   h.vy=max(h.vy-0.2,-2)   
   min_y=-150
  end
 else
  h.vy+=1
  explode(h)
  if dino.super_lasers then
   explode(h)
  end
 end
 
 -- move
 h.x=clamp(h.x+h.vx,-70,198)
 h.y=clamp(h.y+h.vy,min_y,max_y)
 
 if h.flash_timer>0 then
  h.flash_timer-=1
 end
 if h.snap_delay>0 then
  h.snap_delay-=1
 end
 if h.snap_delay==0
 and not h.snapshot
 and (
  (h.x>dino.x and not h.face_right) or
  (h.x<dino.x and h.face_right))
 then
  h.snapshot=take_snapshot(false)
  h.snapshot.headline=build_headline(h.snapshot)
  local ch={1,2,3,13}
  h.snapshot.channel=ch[1+rand(4)]
  h.snap_time=timer
 end
end

function update_lorry(l)
 if l.life<70 and not l.spilled_load then
  l.spilled_load=true
  for i=0,50 do
   local angle=rnd(0.25)
   local speed=5+rnd(3)
   local vx=sin(angle)*speed-1
   local vy=cos(angle)*speed
   local par=make_particle(l.x,l.y,vx,vy,150,l.contents.s,1,1,0)
   par.floor=l.floor
   par.gravity=1
   par.dampening=0.9
   add(particles,par)
  end
 end
end

function update_cars()
 if timer%80==0 then
  make_car({})
 end
 local reached_junction=
  dino.reached_junction and
  not dino.missed_junction
  
 for lane in all(lanes) do
 for c in all(lane) do
  if not is_dino(c) then
   if c.typ==1 then
    update_lorry(c)
   end
   c.vy=clamp(c.vy+1,-10,10)
   if reached_junction then
    c.vx-=0.5
   end
   c.x+=(c.vx-(dino_speed-50)/10)
   if not dino.on_lorry 
   or c.id~=dino.lorry then
    c.x+=0 --0(4-global_speed/12.5)
   end
   c.y+=c.vy
   
   if (((c.x<-48 or c.x>256)
   and c.life>0)
   or c.y>1000)
   and not reached_junction 
   and not c.tmp then
    remove_car_from_lane(c,lane_for_car(c))
    if c.respawn then
     make_car(c)
    end
   end
   if c.life>0 and c.y>c.floor then
    c.y=c.floor
    c.vy=0
   end
   if c.flash_timer>0 then
    c.flash_timer-=1
   end
   if dino.shockwave_timer>0 and c.y==c.floor then
    if abs(c.x-dino.x)<5*(max_shock-dino.shockwave_timer)
    and c.life>0 then
     hurt(c,6*(max_shock-dino.shockwave_timer))
    else
     c.vy-=4
    end
   end
  end
 end --each car
 end --lane
end

function kill(car)
 car.vy-=7
 car.life=-1
 add(points,
  {
   x=car.x+16,
   y=car.y,
   points=car.points
  })
end

function is_dino(c)
 return c.is_dino or c.is_blue_dino
end

blue_think_timer=0
blue_do=function(d)
 d.vx+=0.7
end

function update_blue_dino(bdino)
-- dino.leave_timer-=1
--[[ if not bdino.active then
  return
 end]]
--[[ elseif dino.leave_timer<=1 then
  dino.vy=-15
 end
 if dino.y<0 and dino.leave_timer==-1 then
  dino.active=false
  dino.x=0
 end]]
 
 bdino.vx+=0.7
 if blue_think_timer==0 then
 
  if rand(2)==0 then
   blue_think_timer=100
   blue_do=function(d)
    if not d.jumping and (
     d.jump_time<10)
    then
     d.jump_time+=1
    elseif d.jump_time>=10 then
     d.vy=0
     jump(d)
     if d.x>80 then
      d.vx-=1
     else
      d.vx+=1
     end
    end
   end
  elseif rand(2)==0 then
   bdino.lasers_on=not bdino.lasers_on
   blue_think_timer=60
  elseif rand(2)==0 then
   blue_do=function(d)
    if rand(2)==0 then
     d.angle=(d.angle-5)%360
    else
     d.angle=(d.angle+5)%360
    end
   end
  else
   blue_do=function(d)
    d.vx+=0.05
   end
   blue_think_timer=30
  end
 else
  blue_think_timer-=1
 end
 
 blue_do(bdino) 

 local tmp_global_speed=global_speed
 local tmp_dino_speed=dino_speed
 
 update_dino(bdino)
 bdino.vx-=dino.vx/4
 
 global_speed=tmp_global_speed
 dino_speed=tmp_dino_speed
end

function jump(dino)
 sound(-1,1)
 sound(4)
 dino.vy-=dino.jump_time
 dino.peak=dino.y
 dino.y-=0.001
 dino.jumping=true
 dino.switched_lanes=false
 dino.jump_time=0
end

function update_dino(dino) 
 dino.vy+=1
 if not dino.on_lorry then
  dino.vx-=0.4 -- not accelerating
 else

 end
 if dino.power_up_timer>0 then
  dino.power_up_timer-=1
  dino.x=clamp(dino.x,0,70)
--  dino.vx+=0.3
 else
  dino.power_up=-1
  dino.super_lasers=false
  dino.vx*=0.9 -- friction
 end
 global_speed=clamp(global_speed+dino.vx/2,50,100)
 dino_speed=
  clamp(dino_speed+dino.vx*2,
  50,130)
 
 local dx=dino.x+16
 local dy=dino.y
 local tx=dino.x+dino.vx
 local ty=dino.y+dino.vy
 local move_lateral=true
 local move_vertical=true
 local cx=0
 local cy=0
 
 dino.on_lorry=false
 if dino.y==dino.floor then
  for c in all(lanes[lane_for_dino(dino)]) do
   if not is_dino(c)
   and abs(dino.x-c.x)<16
   and c.life>0 then
--    c.hit=true
--    dino.hit=true
    sound(2)

    if dino.vx>2.4 then
     hurt(c,30+dino.power_up_timer)
     c.vx+=5
     c.vy-=5
    end
    
    if dino.power_up~=1 then
     dino.vx=-5 --max(dino.vx-8,-5)
    end
        
    local spd=4
    local a=rnd(1)
    local vx=sin(a)*spd
    local vy=cos(a)*spd
    add(particles,make_particle(
     c.x+16,
     c.y+8,
     vx,
     vy,
     spd*4,
     162,
     1,
     1
    ))
    if dino.power_up_timer>0 then
     hurt(c,60)
    end
   end
  end
 end
 
 for lane in all(lanes) do
 for c in all(lane) do
  if c.typ==1 and not dino.on_lorry then
   if dy<=c.y-9
   and collides(dx,dy,tx,ty,c.x,c.y-9,c.x+48,c.y-9) then
    if dino.jumping then
     sound(2)
     hurt(c,50)
    end
    move_vertical=false
    dino.jumping=false
    dino.on_lorry=true
    dino.lorry=c.id
    dino.vx=c.vx  
    dino.vy=0
    dino_speed=c.vx*10+50
   end
  end
 end
 end
 
 if dino.on_lorry then
  dino.x+=(dino.vx-(dino_speed-50)/10)
 else
  if move_lateral then 
   if dino.is_blue_dino then
    dino.x=clamp(dino.x+dino.vx,-300,600)
   else
    dino.x=clamp(dino.x+dino.vx,0,110)
   end
  else
   dino.x=cx
  end
  if move_vertical then
   dino.y=clamp(dino.y+dino.vy,0,128)
  else
   dino.y=cy
  end
 end
  
 if dino.shockwave_timer>0 then
  dino.shockwave_timer-=1
 end
 
 if dino.jumping then
  if dino.y<dino.peak then
   dino.peak=dino.y
  end
  
  if not dino.switched_lanes
  and dino.y<=108 then
   remove_car_from_lane(dino,lane_for_dino(dino))
   if dino.floor==125 then
    dino.floor=108
   elseif dino.floor==108 then
    dino.floor=116
   else
    dino.floor=125
   end
   dino.switched_lanes=true
   add_car_to_lane(dino,lane_for_dino(dino))
  end
  if dino.quick_switch and dino.vy>-0.2 then
   remove_car_from_lane(dino,lane_for_dino(dino))
   if dino.floor==125 then
    dino.floor=116
   elseif dino.floor==116 then
    if dino.switch_down then
		   dino.floor=125
		  elseif dino.switch_up then
		   dino.floor=108
    end
   else
    dino.floor=116
   end
   add_car_to_lane(dino,lane_for_dino(dino))
   dino.quick_switch=false
   dino.switch_down=false
   dino.switch_up=false
  end
 end
 
 if dino.y>=dino.floor then
  dino.vy=0
  dino.y=dino.floor
  if dino.jumping then
   if dino.peak<50 then
    max_shock=12
    sound(0)
   else
    max_shock=8
    sound(1,1)
   end
   dino.shockwave_timer=max_shock

  end
  dino.jumping=false
 end

 if dino.lasers_on then
  if dino.super_lasers then
   sound(16)
  else
   sound(8)
  end
  dino.laser_time+=1
  dino.laser_charge=clamp(dino.laser_charge-0.6,0,100)
  
  if dino.laser_charge==0 then
   dino.lasers_on=false
  end
  
  local px=dino.x
  local py=dino.y-85
  local laser_length=clamp(dino.laser_time*18,0,200)
  local a=(dino.angle+5*sin(20*timer%360/360))/360
  local x=px+cos(a)
  local y=py-sin(a)
  local laser_end_x=x+laser_length*sin(a)
  local laser_end_y=y+laser_length*cos(a)
  
  for lane in all(lanes) do
  for c in all(lane) do
   if not is_dino(c) then    
    check_laser_hits(c,px,py,laser_end_x,laser_end_y,dino.super_lasers)
   end
  end
  end
  
  for c in all(helis) do
   if c.life>0 then
    check_laser_hits(c,px,py,laser_end_x,laser_end_y,dino.super_lasers)
   end
  end
 else
  dino.laser_charge=clamp(dino.laser_charge+0.7,0,100)
 end
end

function hurt(c,amount)
 c.life-=amount
 if c.flash_timer==0 then
  explode(c)
  if dino.super_lasers then
   explode(c)
  end
 end
 flash(c)
 if stat(16)~=9 then
  sound(9)
 end
 if c.life<=0 then
  kill(c)
  explode(c)
  sound(7,1)
  
  if rand(8)==0 then
--  if true then
--  if false then
   local vx=-1.5 -- sin(angle/360)*speed-1
   local vy=-10 --cos(angle/360)*speed
   local pickup_spr=172
  
   local typ=rand(4)
   if typ==1 then
    pickup_spr=187
   elseif typ==2 then
    pickup_spr=173
   elseif typ==3 then
    pickup_spr=188
   end
   
   local par=make_particle(c.x+32,c.y,
    vx,vy,100,pickup_spr,1,1,0)
   par.pickup=true
   par.typ=typ
   par.floor=c.floor
   par.gravity=1
   par.dampening=0.9
   par.sc=16
   par.pickup_timer=0
   add(particles,par)
  end
 end
end

function check_laser_hits(c,px,py,laser_end_x,laser_end_y,super)
 if collides(px+11,py+10,laser_end_x,laser_end_y,c.x,c.y,c.x,c.y+16)
 or collides(px+11,py+10,laser_end_x,laser_end_y,c.x,c.y,c.x+32,c.y)
 or collides(px+11,py+10,laser_end_x,laser_end_y,c.x+32,c.y,c.x+32,c.y+16)
 or collides(px+11,py+10,laser_end_x,laser_end_y,c.x,c.y+16,c.x+32,c.y+16)
 then
  if c.life>0 then
   if super then
    hurt(c,6)
   else
    hurt(c,4)
   end
  end
 end
end

function flash(c)
 if c.flash_timer==0 then
  c.flash_timer=2
  explode(c)
 end
end

function explode(c)
 local angle=rnd(1)
 local p=make_particle(
  c.x+cos(angle)*rnd(16),
  c.y+sin(angle)*rnd(16),
  0,
  0,
  10,
  132,
  2,
  5,
  2
 )
 p.sc=16
 add(particles,p)
end
function collides(pox,poy,p1x,p1y,p2x,p2y,p3x,p3y)
 local s1x=p1x-pox
 local s1y=p1y-poy
 local s2x=p3x-p2x
 local s2y=p3y-p2y
 
 local s=
  (-s1y*(pox-p2x)+s1x*(poy-p2y))/
  (-s2x*s1y+s1x*s2y)
 local t=
  (s2x*(poy-p2y)-s2y*(pox-p2x))/
  (-s2x*s1y+s1x*s2y)
 
 return s>=0 and s<=1 and t>=0 and t<=1
end

function draw_snapshot()
-- cls()
 --global_speed=0
 set_snapshot_pal()
 timer=snapshot.timer
 
 set_cam(snapshot.dino)
 draw_world(
  -1,
  {x=snapshot.dino.x,y=0},--dino
  snapshot.clouds,--clouds
  snapshot.signs,
  snapshot.lanes,
  snapshot.helis,
  snapshot.particles,
  snapshot.timer,
  set_snapshot_pal,
  true)
 
 camera()
 for i=1,#snapshot.messages do
  local m=snapshot.messages[i]
  colour_print(m.m,126-#(m.m)*4,2+(i-1)*8,7,0)
 end
 
 colour_print("date:"..snapshot.date,1,120,7,0)
 colour_print("speed:"..snapshot.speed.."mph",65,120,7,0)
end


ch_names={
"blorb news",
"zzz news",
"arf network",
"glooptv!"
}
function draw_news_report(snapshot)
-- cls()
 reset_pal()
 timer=snapshot.timer
 report_timer+=1
 
 draw_world(
  0,
  {x=snapshot.dino.x,y=0},--dino
  snapshot.clouds,--clouds
  snapshot.signs,
  snapshot.lanes,
  snapshot.helis,
  snapshot.particles,
  snapshot.timer,
  reset_pal)
  
 camera()
 rectfill(0,110,128,120,0)
 rectfill(0,111,128,119,snapshot.channel)
 local headline="evening news - "..snapshot.headline
 print(headline,128-report_timer%(#headline*8),113,7)
end

cam_x=0
cam_y=0

function set_cam(dino)
 cam_x=max(dino.x-32,0)
 cam_y=max(0,dino.y-128)
 camera(cam_x,cam_y)
end

function draw_level()
-- cls()
 
 set_cam(dino)
 
 draw_world(
  global_speed,
  dino,
  clouds,
  signs,
  lanes,
  helis,
  particles,
  timer,
  reset_pal)
 
 for p in all(points) do
  draw_number(p.points,p.x,p.y,1,1)
 end

 camera()
 
 draw_hud(cam_x,cam_y)
 spr(160,112,110,2,1)
 draw_number(flr(dino_speed),96,110,2,2)
 
-- print(timer,32,32,8)
 
 if help_msg_timer>0 and timer%10<5 then
  colour_print(help_msg,64-(#help_msg*4)/2,60,help_msg_col,0)
 end
 
-- print(""..dino.x.."\n"..blue_dino.x,32,16,14)
-- print(""..dino.x.."\n"..blue_,32,16,14)
-- print(""..dino.vx,32,16,14)
end

skies={
 {13,6,7,0,7},
 {9,15,7,0,10},
 {4,9,10,1,8},
 {1,13,15,1,10},
 {1,1,13,2,10}
}
function sky_for(timer)
 if timer>1200 then
  return 5
 elseif timer>1000 then
  return 4
 elseif timer>700 then
  return 3
 elseif timer>350 then
  return 2
 else
  return 1
 end
end

function draw_world(global_speed,dino,clouds,signs,lanes,helis,particles,timer,default_palette,snapshot)
 local sky=skies[sky_for(timer)]
 rectfill(0,0,256,128,sky[1])--9
 rectfill(0,68,256,76,sky[2])--15
 rectfill(0,76,256,80,sky[3])
 
 camera()
 local sun_y=-10+(timer/10)
 circfill(sun_y+10,sun_y,10,sky[5])
 set_cam(dino)
 draw_clouds(clouds)

 local spd=global_speed/12.5
 local bgspeed=(timer*spd)%16
 -- i am so sorry for the hack
 -- on the next line.
 if global_speed>=0 then
  fade_pal(sky[4])
 end
 for i=-16,255 do
  sspr(24+i%8,32,1,32,i+bgspeed*0.5,
  77+i%3 ---(distance+i)
  ,1,32)
 end
 default_palette()
 for i=0,16 do
  --local y=90+(i/4)+(i%3)
--  sspr(80,32,16,16,
--   i*16-bgspeed*0.5,80)
  sspr(64,32,16,32,
   i*16-bgspeed,96)
 end

 draw_signs(signs)
 
 local lorry=dino.lorry
 
 for i=1,3 do
  local lane=lanes[i]
  local dino=nil
  local blue_dino=nil
  for c in all(lane) do
   if c.is_dino then
    dino=c
   elseif c.is_blue_dino then
    blue_dino=c
   else
    draw_car(c,default_palette)
   end
  end
  if dino then
   draw_dino(dino)
  end
  if blue_dino then
   if (not snapshot) set_pal(3)
   draw_dino(blue_dino)
   reset_pal()
  end
 end
 
 for h in all(helis) do
  draw_heli(h,default_palette)
 end
 
 for p in all(particles) do
  local flash=p.flash and p.life%3==0
  if flash then
   flash_pal()
  end
  sspr(
   p.spx+(p.frame*p.sz*8),p.spy,
   p.sz*8,p.sz*8,p.x,p.y,p.sc,p.sc
  )
  if flash then
   reset_pal()
  end
 end
end

function draw_signs(signs)
 for s in all(signs) do
  spr(s.sp,s.x,s.y,2,s.h)
  if s.w==2 then
   spr(116,s.x,s.y+8*s.h,2,1)
  else
   spr(74,s.x,s.y+8*s.h,1,1)
  end
  if s.draw then
   s:draw()
  end
 end
end

function draw_clouds(clouds)
 for c in all(clouds) do
  if c.size==0 then
   sspr(96,32,32,16,c.x,c.y)
  elseif c.size==1 then
   sspr(80,48,16,8,c.x,c.y)
  elseif c.size==2 then
   sspr(80,56,16,8,c.x,c.y)  
  else
   spr(124,c.x,c.y)
  end
 end
end

function fade_pal(fade_level)
 if fade_level==99 then
  for i=0,5 do
   pal(i,5)
  end 
  for i=6,15 do
   pal(i,6)
  end
 else
  for i=0,15 do
   pal(i,sget(112+i,64+fade_level))
  end
 end
end

function draw_title()
 
 rectfill(0,0,128,128,9)
 rectfill(0,68,128,96,15)
 rectfill(0,96,128,115,7)
 
 draw_clouds(clouds)

 for i=0,97 do --0.22
  local y=i%3+116+30*sin((i+80)/360)
  sspr(24+i%8,32,1,32,i,y,1,32)
 end
 for i=85,128 do
  local y=clamp(213-i,115,128)
  sspr(68+i%5,32,1,32,i,y,1,32)
 end
 
 for i=0,1 do
  local x=15+i*61
  rectfill(x,82,x,111,0)
  rectfill(x+1,82,x+1,112,0)
  rectfill(x+2,82,x+2,112,5)
  rectfill(x+3,82,x+3,112,5)
  rectfill(x+4,82,x+4,112,0)
  rectfill(x+5,82,x+5,111,0)
 end
 
 rectfill(13,13,84,84,0) 
 rectfill(15,15,82,82,7) 
 rectfill(16,16,81,81,1)
 rectfill(18,18,79,79,13)
 
 rectfill(21,66,31,76,0)
-- print("17",22,70,7)
 sspr(24,80,48,8,21,21,48,16)
 spr(169,53,69,2,1)
 print("     the\ncommutasaurus\n\n\n\n 17",19,39,7)
 
 rectfill(73,23,76,76,7)
 rectfill(74,21,75,76,7)
 
 line(72,76,52,56,7)
 line(72,75,52,55,7)
 line(72,74,52,54,7)
 line(72,73,52,53,7)
 line(73,73,53,53,7)
 line(74,73,54,53,7)

 if timer%10<5 then
  colour_print("press — to rage!",35,118,7,0)
 end 
 
end

function draw_cut_scene()
 cls()
 reset_pal()
 if cut_scene_progress==99 then
  draw_lost()
 elseif cut_scene_progress==0 then
  print("that evening...",40,60,7)
 else
  circfill(96,96,90,1)
  circfill(96,96,70,13)
  circfill(96,96,55,6)
  for i=0,64 do
   local height=90+20*sin((90+i)/360)
--   local height=90+20*sin(0.25+i/5.6)
   
   line(i,128,i,height,0)
   line(i,128,i,height+1,2)
  end
  line(64,80,64,100,0)
  line(0,100,64,100,0)
  line(0,108,64,108,0)
  rectfill(64,108,70,128,2)
  circfill(66,100,8,0)
  circfill(66,100,7,2)
  circ(70,100,8,0)
  if cut_scene_progress==1 then
   colour_print("let's see whats on tv",24,32,7,0)
   fade_pal(1)
  end
  dino_sprite(24,48,0,0,0)
  reset_pal()
  
  if cut_scene_progress>1 then
   local radius=42+8*sin(20*(timer%360/360))
   circfill(96,96,radius+1,0)
   circfill(96,96,radius,7)
   if cut_scene_progress==3 then
--    colour_print(responses[cut_scene_progress-2],24,32,7,0)
    colour_print(response,24,32,7,0)
    line(31,50,35,54,0)
   end
  end
  rectfill(68,76,128,128,0)
  rectfill(69,77,128,128,5)
  line(68,76,76,80,0)
  rectfill(76,80,128,128,0)
  rectfill(77,81,128,128,1)
 end
end

f_draw_results=nil
function draw_results()
 camera()
 f_draw_results()
end

function draw_score()
 reset_pal()
 draw_world(50,
 {x=0,y=0},
 clouds,
 {},
 {},
 {},
 {},
 50,
 reset_pal)
 
 local total=dino.points+dino.speed_bonus*2
 if (snapshot) total-=500
 if (dino.x>blue_dino.x) total+=700
 
 total-=number_reports*70

 total=max(total,0)

 colour_print("final score",42,40,7,0) 
 local sc=1.5*abs(sin(timer*4%360/360))
 draw_number(total,82+sc*8,48,2+sc,2+sc)
 colour_print("rating: "..rating_for_total(total),42,80,7,0) 
--  print(level_end_time,64,110,14)
--  print(total,64,110,14)
 if timer%10<5 then
  colour_print("press — to rage again!",20,118,7,0)
 end 
end

function rating_for_total(total)
 if total>5000 then
  return "aaa"
 elseif total>4500 then
  return "aa"
 elseif total>4000 then
  return "a"
 elseif total>3000 then
  return "b"
 elseif total>2000 then
  return "c"
 elseif total>1000 then
  return "d"
 else
  return "e"
 end
end

function draw_car(c,default_palette)
 if c.is_dino then
  default_palette()
  draw_dino(c)
 elseif c.is_blue_dino then
  set_pal(3)
  draw_dino(c)
 else
  if c.flash_timer>0 then
   flash_pal()
  else
   set_pal(c.col)
  end
  if c.typ==0 then
--   if lane_for_car(c)==lane_for_dino(dino) then rectfill(c.x,c.y,c.x+32,c.y+16,14) end
   if c.life>0 then
    spr(192,c.x,c.y,4,2) 
   else
    spr(224,c.x,c.y,4,2) 
   end
  else
   spr(196,c.x,c.y-16,6,4) 
   colour_print(c.contents.n,c.x+5,c.y-8,10,12)
--   pset(c.x,c.y,15)
  end
--   line(c.x,c.y,c.x+64,c.y,7+c.col)
  default_palette()
--  colour_print(c.y,c.x,c.y,14,0)
 end
end

function draw_heli(h,default_palette)
 --8058->8050
 local hx=h.x
 local hy=h.y
 local tail_x=hx+16
 local rotor_y=4
 
 if h.face_right then
  tail_x-=32
  rotor_y=-4
 end
 if h.flash_timer>0 then
  flash_pal()
 else
  set_pal(h.col)
 end
 sspr(80,104,32,24,hx,hy+8,32,24,h.face_right,false)
 sspr(96,96,32,16,tail_x,hy,32,16,h.face_right,false)
 if timer%3==0 or h.photographed then
  line(hx+17,hy+3,hx+40,hy+3-rotor_y,0)
 end
 if timer%3==1 or h.photographed then
  line(hx+15,hy+3,hx-8,hy+3+rotor_y,0)
 end
 
 if h.snap_delay==0 
 and h.snapshot
 and timer-h.snap_time<30 then
  local flash_x=hx
  if h.face_right then
   flash_x=hx+40
  end
  local radius=7-12*sin(2*(timer-h.snap_time)/16)
  circfill(flash_x,hy+28,radius+1,0)
  circfill(flash_x,hy+28,radius,7)
 end

 default_palette()
end

function set_snapshot_pal()
 pal(0,0)
 pal(1,0)
 pal(2,0)
 pal(3,5)
 pal(4,5)
 pal(5,5)
 pal(6,6)
 pal(7,7)
 pal(8,5)
 pal(9,6)
 pal(10,7)
 pal(11,7)
 pal(12,6)
 pal(13,6)
 pal(14,6)
 pal(15,6)
end

function set_pal(col)
 if fading_in or fading_out then return end
 
 if col==0 then
  pal(3,2)
  pal(11,9)
  pal(12,4)
  pal(15,9)
 elseif col==1 then
  pal(3,1)
  pal(8,7)
  pal(9,6)
  pal(2,13)
  pal(10,7)
  pal(11,6)
  pal(12,13)
  pal(15,2)
 elseif col==2 then
  pal(3,1)
  pal(8,9)
  pal(9,10)
  pal(2,4)
  pal(10,10)
  pal(11,9)
  pal(12,4)--4
  pal(15,3)
 elseif col==3 then
  pal(9,13)
  pal(4,1)
  pal(2,0)
  pal(10,12)
 elseif col==99 then
  set_snapshot_pal()
 else
  pal(10,7)
  pal(11,6)
  pal(12,13)
 end
end

function flash_pal()
 if fading_in or fading_out then return end
 for i=0,15 do
  pal(i,7)
 end
end

function reset_pal()
 if fading_in or fading_out then return end
 
 for i=0,15 do
  pal(i,i)
 end
end

function draw_number(number,x,y,scale_x,scale_y)
 scale_x=scale_x or 1
 scale_y=scale_y or 1
 
 local sprite_start_x=0
 local sprite_start_y=88

 if number==0 then
  sspr(sprite_start_x,sprite_start_y,8,8,x,y,8*scale_x,8*scale_y)
 else
  local unit=10
  local remaining=number
  while remaining>0 do
   local cur=remaining%unit
   local div=unit/10
 
   -- pico-8 overflow hack  
   if unit<0 then
    cur=flr(remaining/10000)
    div=1
    remaining=0
   else  
    remaining-=cur
    unit*=10
   end
   
   sspr(sprite_start_x+(cur/div)*8,sprite_start_y,8,8,x,y,8*scale_x,8*scale_y)
   
   x-=(8*scale_x)
  end
 end
end

function draw_dino(dino)
 local px=dino.x
 local py=dino.y-85
 local angle=dino.angle
 local hswing=sin(clamp(dino.vx,1,1.5)*20*timer%360/360)
 local legswing=hswing
 if dino.on_lorry then legswing=0 end
 local jump_crouch=dino.jump_time/2
 local lasers=dino.lasers_on
 
 if lasers then draw_laser(px+16,py+8+3*hswing+jump_crouch,-5,angle,dino.laser_time,dino.super_lasers) end
 
-- rectfill(px,dino.y-16,px+32,dino.y,12)
 dino_sprite(px,py,hswing,legswing,jump_crouch)

 if lasers then draw_laser(px+11,py+10+3*hswing+jump_crouch,5,angle,dino.laser_time,dino.super_lasers) end
 
 if dino.shockwave_timer>0 then
  if dino.peak<50 then    
   spr(128,px-5*(max_shock-dino.shockwave_timer),dino.floor-16,4,2)
   spr(128,px+5*(max_shock-dino.shockwave_timer),dino.floor-16,4,2,true,false)   
  else
   spr(108,px-5*(max_shock-dino.shockwave_timer),dino.floor-10,2,1)
   spr(110,px+5*(max_shock-dino.shockwave_timer),dino.floor-10,2,1)
  end
 end
-- colour_print(dino.vx,32,32,14,0)
-- rectfill(px,py,px+8,py+8,14)
-- rectfill(dino.x,dino.y,dino.x+8,dino.y-8,14)
-- rectfill(dino.x-16,dino.y-16,dino.x+29,dino.y,14)
-- pset(dino.x,dino.y,8)
end

function dino_sprite(px,py,hswing,legswing,jump_crouch)
 --tail
 sspr(64,0,32,24,px-37-hswing,jump_crouch+py+42-hswing*2)
 --lleg 
 sspr(96,16,32,16,px-2*legswing,py+62-legswing*2) 
 --larm
 sspr(0,32,24,16,px+10+3*hswing,py+30) 
 --middle
 sspr(32,0,32,32,px-6,jump_crouch+py+29) 
 --rarm
 sspr(0,32,24,16,px+-3*hswing,py+36) 
 --rleg
 sspr(96,0,32,32,px-9+2*legswing,py+52+legswing*2)
 --head
 sspr(0,0,32,32,px,jump_crouch+py+3*hswing) 
end

function num_length(number)
 local length=1
 local unit=10
 local remaining=number
 
 while remaining>=unit do
  local cur=remaining%unit

  if unit<0 then
   remaining=-1
   unit=1
  else  
   remaining-=cur
   unit*=10
  end
  length+=1
 end
 
 return length
end

function draw_hud(cx,cy) 

 if dino_speed>70 or dino.power_up_timer>0 then
  for i=0,6 do
   local len=rnd(30)
   local x=rand(100)
   local y=rand(90)
   line(x,10+i*3,x+len,10+i*3,0)
   line(x,127-i*3,x+len,127-i*3,0)
   line(dino.x-cx,dino.y-y,(dino.x-cx)-len,dino.y-y,0)
  end
 end
 
 local laser_charge=2+(dino.laser_charge/100)*123
 rectfill(1,1,126,6,0)
 rectfill(3,4,124,3,1)
 rectfill(2,2,laser_charge,5,9)
 rectfill(2,3,laser_charge-1,5,2)
 rectfill(3,3,laser_charge-1,4,8)
 
-- rectfill(1,8,126,9,0)
 spr(175,clamp(128-((distance+(dino.x-blue_dino.x))/max_distance)*128,0,120),6)
 spr(174,clamp(128-(distance/max_distance)*128,0,120),6)

--dino.points=578
 spr(75,117-num_length(dino.points)*8,11)
 local scalep=1
 if (points_timer>0) scalep=1.3
 draw_number(dino.points,118,11,scalep,scalep)
 
-- print(num_length(dino.points),4,16,7)
 if distance<=300 then
  pal(7,8)
  if(timer%10>5) spr(191,120,96)
 end
 
 draw_number(abs(distance),118,20,1,1)
 spr(158,110-8*num_length(abs(distance)),21,2,1)
 pal(7,7)
-- print(dino_speed.." "..(dino_speed/2.045),10,29,8)
-- line(dino.x,0,dino.x,128,7)
-- line(dino.x,100,dino.x+16,100,7)
end

function draw_laser(px,py,s,angle,laser_time,super)
-- local col={7,8,2,0}
 local col={2,8,7,7,7,7,7,7}
 col[0]=0
 local laser_length=clamp(laser_time*18,0,200)
 local laser_size=4
 if super then
  laser_size=8
 end
 for i=-laser_size,laser_size do
  local a=(angle+s*sin(20*timer%360/360))/360
  local x=px+i*cos(a)
  local y=py-i*sin(a)
  local laser_end_x=x+laser_length*sin(a)
  local laser_end_y=y+laser_length*cos(a)
  
  line(
   x,
   y,
   laser_end_x,
   laser_end_y,
   col[laser_size-abs(i)])
 end

end

function colour_print(s,x,y,light,dark)
 for lx=-1,1 do
  for ly=-1,1 do
   print(s,x+lx,y+ly,dark)
  end
 end
 print(s,x,y,light)
end
__gfx__
eeeeeee00000000eeeeeeeeeeeeeeeeee00000000999999999999000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000004eeeeeeeeee444944eeeeeeeeeeeeeeee
eeeee009999999900000000eeeeeeeee0224420499999994499aaa990eeeeeeee0e0000eeeeeeeeeeeeeeeeee0242220eeeeee2442244994eeeeeeeeeeeeeeee
eeee099999aaaaaaa4444440eeeeeeeee02242044999999949aa9aaa900eeeee09002220eeeeeeeeeeeeeeeee0244420eeee44242242249400eeeeeeeeeeeeee
eeee099949aaaaaaaa9004400eeeeeeee02222044499999999aa44aaa940eeee09022420eeeeeeeeeeeeeeeee0244200eee44424444244994009eeeeeeeeeeee
eee0449999999000aaaa994990eeeeeeee022022949999999aaaa4aaaa940eee09022420eeeeee0eeeeeeeeee0222204ee242224222244994409999eeeeeeeee
ee0444994444444009aaa994a900eeeeee020442994499999aaa44aaaaa990ee04902220eeeee020eee00eeeee020044ee2442444244449994099999eeee990e
ee04299099994224099aaa49aa490eeeeee04422999499999aaaaaaaaaaa90ee04490220eee00220ee02200ee0909424ee24224444244499940999499ee9990e
ee0229440000044444999aa49a9990eee000004444999999aaaaaaaaaaaaa90e044990090e0222220e02422009999424e444244442244499940999999999990e
ee044944022280444999449aaaa9990e0022202444999994aaaaaaaaaa44aa0e04449999902224420e02444220999224e244444422444499990099999999990e
ee04494902888009999994999999490e0242202444499999aaaaaaaaaaa4aa0e02444999902222220e02442209949444e244224424444499994099999499990e
e04249999088009094999994999999900222022444499999aaaaaaaaaa44aa90e0444499990002220002220099449224e24442242444449994409999444990ee
e04249449900999994999999999499900222044444449999aaaaaaaaaaaaaa90e0224449499990009902209999999424e42222222422499994409994449440ee
e02249949999999999499499999aaa900220224444444999aaaaaaaaaaaaaa90ee044444999949499990099949999224e4442244442249999400994499440eee
e044444499944494999aaaaaaaaaa4900204422444444999aaaaa4aaaaa4aa90ee024442449944499499499449999444e442244244249999940999499400eeee
e044499999994499999aaaaaaaaaa9900024224444449999a4aaaaaaaaaaaaa0eee04444444999999444499999999944e04444424444999aa909999400eeeeee
0422499999999999449999000aaaa0004442444444449999aaaaaaaaa4aaaaa0eeee0444444449999999999949499944ee004422444499aaa0000000eeeeeeee
0442494494099999949499044aaaa4404442444444449999a4aaaaaaaaaaaaa0eeee0244444444499999999944499944eeee00444444aaaaeeeeeeeeeeeeeeee
042249949900049999999994aaaaa9404422442444449999aaaaaaaaaaaa44a0eeeee024424424444999999999999444eeee0444449aaaa0eeeeeeeeeeeeeeee
044494449901100499999499aaaaa94022444444444999999aaaaaaaaaaaa4a0eeeeee04422444444444444444444224ee00444499aaaa00eeeeeeeeeeeeeeee
0444949999407110099999449aaaa94042442244449999949aaaaaaaaa4a44a0eeeeeee0444444244442444442444424e00444499aaaa00eeeeeeeeeeeeeeeee
04244444994061171049999449aa9940224442444999994499aaaaaaaaaaaaa0eeeeeeee00444422444444444222422400444499aaaa00eeeeeeeeeeeeeeeeee
0444999499440171170099999999990e444422444999999999aaaa4aaaa4aaa0eeeeeeeeee004444444444244444444404444999aaa00eeeeeeeeeeeeeeeeeee
042244449922416171110000000900ee44224422499999994999aaaaaaaaaa90eeeeeeeeeeee0000000000044442444400449999a00eeeeeeeeeeeeeeeeeeeee
04444449994220006117164646100eee44424442449999999999aaaaaaaaaa90eeeeeeeeeeeeeeeeeeeeeee000000000e0044999a0eeeeeeeeeeeeeeeeeeeeee
04444999999422440006161717100eee442244222299999999949aaaaaaaaa90e00000eeeeeee00eeeeee00eeeeeeeeee0044999a00eeeeeeeeeeeeeeeeeeeee
04224494449942224440000000090eee444444444249994999499aa4aaaaa99009aa990e00000d60eee00080e000e00eee0044999a0000eeeeeeeeeeeeeeeeee
0442444944999442222244499990eeee4442444422499900099999aaaaaa9990066660900d566556ee07dd20077d4990eee004499aaaa000000eeeeeeeeeeeee
044242244999994444000000000eeeee4422444444499999009999aaaa999990e06604400d566600e0777d0e0dd72490eeee04449999aaaaaa000000000eeeee
0444442499499999990eeeeeeeeeeeee44422422244499999009999999499990e06604400d25550e07777d0e00000000eeee0044449999999999990dd70eeeee
0422444499449999990eeeeeeeeeeeee4442244424449999990999999949990ee06d020e0024440e0d77d0ee0a7777a0eeeee00044444499990000000000eeee
0442444499999999990eeeeeeeeeeeee422444224442499999009994999990eee0dd020ee022240e0ddd0eee049aa940eeeeee0004444444440dd7770d70eeee
e04444444999999990eeeeeeeeeeeeee44244444444449999990999999000eeee000000eee0000eee000eeeee000000eeeeeeee000044444440000000000eeee
eeeeeeeeeeeeeeeeeeeeeeee000000000000eeeeeeeeeeee0000eeeeeeeeeeee00000000000000000650eeeeeee0000eeeeeeeeeeeeeeeee000000eeeeeeeeee
eee04eeeeeeeeeeeeeeeeeee0000000001100000eeeeeeee01110000eeeeeeee11111111111111110650eeeeee077770eeeeeeeeeeeeeee07777700ee000eeee
eee04499eeeeeeeeeeeeeeeeaa0000aa011111110000eeee01dd11110000eeee11111111111111110650eeeee0770000eeeeeeeeeee000007777777000700eee
eee04499a0eeeeeeeeeeeeeeaaaa00aa01ddddd11111000001d7dddd1111000051515151515151510650eeee0777770eeeeeeeeeee0777d077777dd077770eee
eee04499a0eeeeeeeeeeeeeeaaabaaaa01ddddddddd1111001d77777dddd111011111111111111110650eeee0070000eeeeeeeeeee0777777777dd0777770eee
eee0449a00eeeeeee00000eeabaaabab01d77ddddddddd1001ddddd777dddd101515151515151515065000330770d700eeeeee000007777dd77dd0777777000e
eee0449a0eee00000099900ea99abaa901ddd77ddddddd1001dddddddddddd1055515151515151510000003307d77770eeee00077d077777dddd077777777700
eee0449a0ee00a9aaa94070e9a999aba01ddddd777d7dd1001000ddddddddd1000055555555500000000033e0000000ee00007777d0077777ddd777777777770
eee0449a0e09999999900070ab9b9a9b01d77dddddd77d1001070ddddddddd107770555555507777eeee0000eeeeeeee00ddd777ddd007777777777777777770
eee044490009944444490000b9ba9b9a01ddd777ddd77d1001000ddddddddd107705555555077777eee0d7d7eeeeeeee0dddddddddddd77777d777777dddddd0
eee044449999400000040000a9a9baa901ddddddddd77d1001dddddddddddd1070555dd550777777e007d7d7eee0000e0dddddddddddddd77ddd77ddddd00000
eee04444999400eeee000d0eb9b9a99b01ddddddddd77d1001111ddddddddd100d555555dd0000000777d7d7ee07770e0000000ddddddddddddddddddd00eeee
eee0044444400eeeeee0070e9a9399a901d77dddddd77d10000011111ddddd10555555555555555507dddddde07770eeeeeeee00d000dddddddddd00000eeeee
eeee00444400eeeeeeee000e9399ba9301ddddddddd77d10051000001111111055555555555555550dd00000e0000eeeeeeeeee000e00000000dd00eeeeeeeee
eeeeee04400eeeeeeeeeeeeeb9a999a901ddddd7ddd77d100510eeee0000111055555555d5555555000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeee
eeeeeee000eeeeeeeeeeeeeea3ba939b01000d777dd77d100610eeeeeeee000055555dd5555555550eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeee000ee9939393901070dd777d77d100000eeeeeeeeeeee5555555555555555eeeeee000eeeeeeeeee777eeeeeeeeeeeeeeeeee777eeeee
eeeeeeeeeeeeeeeeee0550ee339b9b9b01000ddd77777d1006660000eeeeeeee5555555555555555eeeee077700eeeeeeed676eeeeeeeeeeeeeeeeeee77777ee
eeeeeeeeeeeeeeeeee0450eeb993393901ddddddd7777d10067766660000eeee55555555555dd555eee00d777770eeeeed6767eeeeeeeeeeeeeeeeeeeee676de
eeeeeeeeeeeeeeeeee0f00ee9399939301111ddddd777d100677777766660000555555ddd5555555ee07dd77777d000eed6767eeeeeeeeeeeeeeeeeeeee676de
ee00000000eeeeeee0e010ee3b9339b9000011111ddddd100677007777776660000d5555555d0000e07dddd777d0d770ed66777eeeeeeeeeeeeeeeeeee7676de
ee0500555500eeee030030ee939393930510000011111110067700007777776077705555555077770dddddddddddddd0edd6767777eeeeeeeeeeeeee77776dde
ee055500555500ee033310ee939999990510eeee00001110067700000077776077055555550777770000000000000000eddd666677777777777776666666ddde
e005a95500000000000030ee339939390610eeeeeeee000006770770705077607015551550777777eeeeeeeeeeeeeeeeeedddddddddeeeeeeeee6ddddddddeee
0505aa9950555550e01130ee993993990610eeeeeeee051006770770005007600151515151000000eeeeeeeeeeeeeeeeeeeeeeeee0000eeee0000eeee0000eee
0505aaa950555550013300ee999393930610eeeeeeee051006770000005007601515151515151515eeeeeeeeeeeeeeeeeeeeeeeee071000ee011000ee011000e
0505aaaa5055555003030eee993399990610eeeeeeee061006777700005077601111111111111111eeeeeeeeeeeeeeeeeeeeeeeee017710ee07dd10ee01dd10e
050055aa5055551003030eee43993949060000eee0ee061006666777007777605151515151515151ee00eeeeee00eeeeee0eeeeee07dd70ee017710ee07dd10e
065000555055511000310eee3993999300000eeee00e061000006666677777601111111111111111e0d7000000d700eee070000ee017710ee07dd70ee017710e
0650ee0050551110030310ee33494333eeeeeeeeee000610051000006666666011111111111111110ddd77777dddd70e0dd77770e07dd70ee017710ee01dd70e
0650eeee00000000e0e030ee34333393ee0eeeeeeee006100510eeee000066601111111111111111000000000000000000000000e007710ee000170ee000110e
0650eeeeeeeeeeeeeeee0eee93393934eee0eee0eeee00000610eeeeeeee00000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeee00070eee00000eee00000e
e000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000eeeeeeeeee0000ee000eeeeee000eee000eeee0123456789abcdef
02244a9a7a0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000eeeeeeeee04999400eeeee0000990004420eeee09990e00940eee012345562493d599
049a97770000eeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee024999420eeeeee004a9aaa420eee0249aa999999420eee0aa70e07a940ee0121215622435288
049797a900a70eeeeeeeeeeee0a0eeeeeeeeeeeeeeeeeeeeee049aa9aa920eeee00499a77a9440eee0a7777779a9940eee07770e077a90ee0111211512221124
0497a7777a70eeeeeeeeeeee0a70eeeeeeeeee0000eeeeeee049a97779aa40ee0249a777977a940e09777ee79099a940ee0000e0777a90ee0000111511211112
04977779a70eeeeeeeeeeeeee00eeeeeeeeee049940eeeeee0997777777a920e029a77e7e777794009aa77e7909a7790eeeeeee0777a90ee0000000001111111
04979a77970eeeeeeeeeeeeeeeeeeeeeeeee04a7a90eeeee029a77777777a40e04a97eeeeee79a90049a777900777a90eeeeeeee077790ee0000000000000111
04977797770eeeeeee0eeeeeeeeeeeeeeeee0977790eeeee049977777777a90e09a77eeeeee77790024999420977e790eeeeeeeee0000eee0000000000000000
049777a7a0eeeeeee0a0eeeee00eeeeeeeee0977a90eeeee04977777777a990e09a77eeeeee77a90e0000000277ee790eeeeeeeeeeeeeeeeee00000000000000
029a97977a0eeeee0a70eee00a70ee7eeeee04aa940eeeee02977777777990ee049a77eeee77a92002494220477ee790eeeeeeeeeeeeeeeee077000707707770
0249a9a977a0eee0a9770ee0a770eeeeeeeee04940eeeeeee09a9777777a90eee09777eee77a940e049a99e097777790eeeeeeeee0000eeee070707070000700
01249a777970eee0777a0e0a970eeeeeeeeeee000eeeeeeee049aa77799940eee04a77777ea9420e09a779e099777a90ee0eeeeee07a90ee070770700770700e
e01249977a770ee09a790007770eeeeeeeeeeeeeeeeeeeeeee0499a9a9400eeee029a777aa9420ee0097a9909999420ee070eeeee09420ee077707077700700e
ee012449999a7000777777779770000eeeeeeeeeeeeeeeeeeee00499940eeeeeee04999aa9420eee00499a999aa420ee09a70eeeee000eee00000000000000ee
eee001244449aa77aa999999aa797770eeeeeeeeeeeeeeeeeeeee00000eeeeeeeee004999420eeeee00009a9a79000eee09a0eeeeeeeeeeeeeeeeeeeeeeeeeee
eeeee000022222222222222222222222eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000eeeeeeeee0000000eeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeee
ee00000000000000eeeeeeee67776ddd676ddd676dd7776dddddd67776dd67777d76dd67dd6ddddddddddddd00000000ee0000eeee0000eeee000eeeee000eee
e007077077707070e000eeee777776d67776d67776d77776ddddd777776d77776d777777d67ddddddddddddd00000000e049020ee022870ee099a0eee0cc60ee
e070707070707770e09900ee77d777d77d77d77d77d77d77ddddd77d777d77ddddd6776ddd7dd7dddddddddd000000000492878002287770e0989a0ee0c8c60e
007070777707770ee09aa0ee77d777d77d77d77d77d77d77ddddd77d777d7776dddd77dddd7d7ddddddddddd000000000928780002877780044949a00ddcdc60
070007070007070ee09a770e7777ddd77d77d77777d77d77ddddd7777ddd7777dddd77ddddd7d67d6d67dddd000000000027829008777820049494900dcdcdc0
00000000000000eeee0770ee77776dd77d77d77777d77d77ddddd77776dd77ddddd6776ddd7d6d7d77777ddd0000000002782990077782200244440e01dddd0e
eeeeeeeeeeeeeeeeeee0000e77d776d67776d77d77d77776ddddd77d776d77776d777777d7ddd7dd7d7d7ddd00000000e082040ee078220e022200ee011100ee
eeeeeeeeeeeeeeeeeeeeeeee67d777dd676dd76d67d7776dddddd67d777d77777d76dd67dddd777d7ddd7ddd00000000ee0000eeee0000eee000eeeee000eeee
eee0000eeee0000eee00000ee000000eee000000ee000000eee0000eee000000eee0000eee000000eeeeeeeeee0000eeee0000eeee0000ee00000000eeee000e
ee077770ee07770ee0777770e0d77770e0770770e0777770ee07770ee0777770ee077770e0777770eeeeeeeee044940ee015510ee01dd10e00000000eee06660
e0770770e077770e07777770ee007770077077700777770ee07770ee07777770e077077007700770eeeeeeee0070004001d8851001dddd1000000000ee06bb60
e0770770e00770ee0000770ee077777007777700077000eee07700ee00007770ee07777007777770eeeeeeee11d78710018d84d001020dd000000000e06bbb60
0770770eee0770eeee0770000000770e0000770e0077700e0770770eeee077000077700ee0077700eeeeeeee1772e7d108288880022922d000000000e50bbbb0
0770770ee0770eeee07777700d7770eeeee070eee007770e0770770eee07770e0770770eee07770eeeeeeeee00000000050550500097920000000000ee503330
077770eee0770eee0777770e077770eeee0770ee0777770e0777770ee07770ee077770eee07770eeeeeeeeeee024940ee01dd10ee029900e00000000eee50000
e0000eeee0000eee000000ee00000eeeee000eee000000eee00000eee0000eeee0000eeee0000eeeeeeeeeeeee0000eeee0000eeee0000ee00000000eeee5555
eee00000000000000000eeeeeeeeeeeeee000000000000000000000000000000eeeeeeeeeeeeeeee0000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000e
ee0888000000080000000eeeeeeeeeeee0caaaaaaaaaabaaaaaaaabaaaaaaaac0e0000eeeeeeeeee0d66d000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0890e
e058205555555055555000eeeeeeeeeee0aaaaaaaaaabaaaaaaaaaabaaaaaaaa0e088900eeeeeeee0dddd060eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee08890e
e05280566dd6505dd655500eeeeeeeeee0bbbbbbbbbcbbbbbbbbbbbbcbbbbbbb0e0288890eeeeeee0dddd060eeeeeeeeee5eeeeeeeeeeeeeeeeeeeeeee0890ee
05820566dd66505566d65500000eeeeee0bbbbbbbbbcbbbbbbbbbbbbbbbbbbbb0e02888890eeeeee0dddd060eeeeeeee500eeeeeeeeeeeeeeeeeeeeee08890ee
0582056dd66d5005dd66d550888000eee0bbbbbbbbbcbbbbbbbbbbbbcbbbbbbb0e028888890eeeee0dddd060eeeeeeee000eeeeeeeeeeeeeeeeeeeee088890ee
0528055566555005566555009999980ee0bbbbbbbbbbbbbbbbbbbbbbcbbbbbbb0e0222288890eeee000dd060eeeeeeee050e000eeeeeeeeeeeeeeee088880eee
08828000000002800000008889999980e0bbbbbbbbbcbbbbbbbbbbbbcbbbbbbb0ee000000000eeeeeee00000eeeeeeee0500aaa0eeeeeeeee000000880080eee
0882299222999992299999999888d770e0bbbbbbbbbcbbbbbbbbbbbbcbbbbbbb0e000000000000eeeeeeeeeeeeee0000aaaaaa00000000000999999888880eee
0892222228888288888889222222dd70e0bbbbbbbbbcbbbbbbbbbbbbcbbbbbbb000000000000090eeeeeeeeeeee0fffffaaaaa051080999998000080000890ee
02210000128222228888821000012dd0e0bbbbbbbbbcbbbbbbbbbbbbcbbbbbbb000155555555080eeeeeeeeeeee0ffffffffff05008088888802800eee0890ee
08200dd502888128222882006dd02820e0bbbbbbbbbcbbbbbbbbbbbbcbbbbbbb00015dd6dd60900eeeeeeeeeeee0ffff00000001500908820000280eeee080ee
0820d06d028801288882800606602280e0bbbbbbbbbcbbbbbbbbbbbbcbbbbbbb00015d6dd660800eeeeeeee00000000088aaa99000000200eeee00eeeee0890e
e000d6dd018801222222800d6d608880e0bbbbbbbbbbbbbbbbbbbbbbcbbbbbbb0001566d66d0800eeeeeee0509998828800ff889929900eeeeeeeeeeeee0890e
ee005dd0000000000000000d6600000e00bbbbbbbbbcbbbbbbbbbbbbbbbbbbbb000156dd6dd0000eeeeee055088800020550f98828290eeeeeeeeeeeeeee090e
eeee0000eeeeeeeeeeeeeee0000eeeee00bbbbbbbbbcbbbbbbbbbbbbcbbbbbbb0e0155555555080eeeee0665080055020560f98288820eeeeeeeeeeeeeee00ee
eeeeee0000000000000000eeeeeeeeee00bbbbbbbbbcbbbbbbbbbbbbcbbbbbb00e0000000005080eeee05d6608066502805d089828200eeeeeeeeeeeeee000ee
eeeee0990005550055555200000000ee00bbbbbbbbbbbbbbbbbbbbbbbbbbbb010e0222888280080eee06ddd5020566502056082882800eeeeeeeeeeeee03300e
eeee0580d66028800289820d6602890ee0bbbbbbbbbbbbbbbbbbbbbbbbbbbb010e02888882888890ee066d500205dd502065029288800eeee550555ee0388420
eee058505dd0000000000505dd50000ee0cccccccccccccccccccccccccccc010e00000002888880e05d6d5082056650200028882800eeee0605ddd503004090
ee0585050500000000000050050000eee00000000000000000000000000000000005555500888880e055550082800008f3fff2828800eeee0665111500420990
e05850000001110011111010000100eee01555555555555555555555555555510000000050288800000000888288888ff3fff822220eeeee0665111004009940
e05850500105550055551010100100eee00000000000000000000000000000000011111005000050088888000820000003fff222200eeeeee550000e0099400e
e0885000110555015555011010100eeeee010eee051111110ee01111111111100100000005555500080000d5082056550333322220eeeeeeeeeeeeeee0000eee
e085000010055501155101011000eeeeee050ee05105555000e055555555555010055550015550700205d66022205dd50033222201eeeeeeeeeeeeeeeeeeeeee
e055000110555005111115010100eeeee0850ee5105dddd50100000000000000105dddd50055507002000002222300000033200001eeeeeeeee000eeeee00eee
e050000110555011111110000000eeeee0250e051056506501001111111111101056506500155500000000002233333330000eee001eeeeeee0a90eeee0770ee
e00000010555501555111010100eeeeeee000e051056006501005555555555501056006500011150eeeeee00000000000eeeeeeee01e01eee0aa90eee077760e
e00000010111001155150000000eeeeee000ee05105d66d50100000000000000005d66d500e0000eee00000eee01eeeeeeeeee00000001ee0aaa90eee077660e
ee000000000501111110010100eeeeeeeeeeeeee00055550000eeeeeeeeeeeee000555500eeeeeeee09550e00e01eeeeee00000000001eee09aa990ee0666d0e
eee0050000000000000500000eeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeee00000000eeeeeeee09550e0000000000000011eeeeeeeeee099090ee0d6dd0e
eeeeee5500eeeeeeeeee5500eeeeeeeeeeeeeeeeee000000eeeeeeeeeeeeeeeeee000000eeeeeeeee0000eee11000000011eeeeeeeeeeeeeee0000eeee0000ee
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000300000361003320056100532009610093200761008320076100732005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000133001730013300173001330017300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001b61019010166101201012610100100f6100e0100d6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000030300303004030040300503005030060300703008030090300a0300b0300c0300d0300e03010030110301203012030130301403016030170301703018030190301a0301a0301b0301d0301f03020030
000300000a7700b7700f77012770177701e7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000a7500d7501075013750157500d750107501375016750197501275015750187501b7501e75021750217502175021750377003e7000000000000000000000000000000000000000000000000000000000
000100000461003600036100360003610026000261002600026100260002610036000361002600026100360005610056000561005600056100560005610056000561005600056100560005610056000561005600
000400000962009620000000000009620086200000000000064100441004410044100341003410014100000000000000000540005400044000440002500000000000000000000000000000000000000000000000
0002000006020090200d0201002012020130201302012020100200d0200902007020060200602007020090200c0200f0201202014020150201502014020100200d0200a020080200702006020060200502005020
000300001773014730107300a73008730037300170001700037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004002001610067300160001000067300673001600067000b5200b53002600010000673006730016000161001610067300260006700067300673002600067000952009530016000670006730067300160001610
0004002001610067300670006700067300673006700067000b5200b53006700067000673006730067000161001610067300670006700067200673008700087000873008730087300973009730097300973001610
0004002001610097500970009700097500975009700097000b5200b53009700017000975009750097000161001610097500970009700097500975009700097000652006530097000970009750097500970001610
000400000161001750015000170001740017400150001700015500155001500017000174001740017000161001610015500150001700017400174001500017000155001550015000170001740017400150001610
00040020016100b7500b7000d7000b7500b7500c7000c7000b5400b5500b7000b7000b7500b7500b70001610016100b7500b7000b7000b7500b7500b7000b7000e5400f5500b7000b7000b7500b7500b70001610
00040020227502275004200112000875008750000000e7000d5500d55000000087000875008750000000d70008750087500e70010700087500875008750087500875008750087500875008750087500875000000
0002000024050240502405021050150001500024050240502405021050150002405024050240502105015000150001d0001e000140001400014000140001400014000140002b000140001400014000210001d000
00030000253201d3201832013320113200f3200e3200d3200c3200a3200a320093200732007320063200632005320053200432004320043200432003320033200232001320013200132001320013200132001320
0003000009620096200962000000000000963009620096200000019700096300963009630096300a6400000000000000000000017700177001770018700000000000000000000000000000000000000000000000
000900000805008050080500600002050020500205002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000161001610017000160001700016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 41 42 0a 44
00 41 42 0a 44
00 41 42 0a 44
00 41 42 0b 44
00 41 42 0c 44
00 41 42 0c 44
00 41 42 0c 44
00 41 42 0c 44
00 41 42 0e 44
00 41 42 0e 44
00 41 42 0e 44
00 41 42 0e 44
00 41 42 0d 44
00 41 42 0d 44
00 41 42 0d 44
02 41 42 0d 44
02 41 42 0d 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
