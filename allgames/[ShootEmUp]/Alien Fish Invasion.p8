pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- alien fish invasion
-- by dishmoth

function _init()
 starwidth=12*128 -- x-period of the starfield
 gamewidth=5*128 -- x-period of the game
 morphtime=30 -- tick duration of a wave morph

 cartdata("dishmoth_alienfish")
 init_hiscores()
 
 tick=0
 score=0
 score_delay=0
 hiscore_index=0
 level=0
 bomb_timer=0
 wave_timer=0
 state=0 -- 0=>titles, 1=>game, 2=>game over, 3=>hiscores
 state_timer=20
 init_stars()
 init_plyr()
 beams={}
 expls={}
 tags={}
 waves={}
 debug_str=""
end

function _update()
 tick+=1
 score_delay=max(0,score_delay-2)
 update_plyr()
 update_waves()
 update_beams()
 update_expls()
 update_bomb()
 update_tags()
 hit_enmys()
 hit_plyr()
 state_timer=max(0,state_timer-1)
 if state_timer==0 then
  if state==2 then
   state=3
   state_timer=300
  elseif state==3 then
   state=0
   tick=0
  end
 end
 if (state==0 and state_timer==0) or state==3 then
  if btn(5) then
   state=1
   start_game()
  end
 end
end

function _draw()
 if bomb_timer>0 then
  rectfill(0,0,127,127,8) 
  for k=0,15 do
   pal(k,0)
  end
 else
  rectfill(0,0,127,127,col) 
 end
 draw_stars()
 draw_bkgrnd()
 draw_enmys()
 draw_shield()
 draw_plyr()
 draw_beams()
 draw_expls()
 draw_tags()
 pal();
 draw_scan()
 draw_score()
 draw_lives()
 draw_text()
 print(debug_str,0,16,7)
end

function start_game()
 score=0
 level=0
 plyr.y=60
 plyr.reload=0
 plyr.lives=3
 plyr.shield=45
 plyr.respawn=20
 plyr.bombnum=0
 wave_timer=0
 waves={}
end

function init_stars()
 stars={}
 stars.x={}
 stars.y={}
 stars.colours={1,2,5}
 stars.speeds={1/4,1/3,1/2}

 local reseed=rnd()
 srand(3)
 for k=1,90 do
  stars.x[k]=rnd(128)
  stars.y[k]=rnd(112)
 end
 srand(reseed)
end

function draw_stars()
 if bomb_timer>0 then
  return
 end
 local x0=plyr.xstar-plyr.xcam
 for k=1,#stars.x do
  local index=flr((k-1)/30)+1
  local x=(stars.x[k]-x0*stars.speeds[index])%128
  local y=stars.y[k]+16
  local col=stars.colours[index]
  pset(x,y,col) 
 end
end

function draw_bkgrnd()
 if bomb_timer>0 then
  return
 end
 for k=1,5 do
  local x0=near_plyr(128*(k-1))
  map(16*(k-1),0, x0+plyr.xcam-plyr.x,18, 16,13)
 end
end

function init_plyr()
 plyr={}
 plyr.xstar=0 -- x-position, 0 to starwidth
 plyr.x=flr(rnd()*gamewidth) -- x-position, 0 to gamewidth
 plyr.y=60 -- y-position, 0 (top) to 104 (bottom)
 plyr.dx=1.0 -- x-velocity, normally +/-2.0, up to +/-8.0
 plyr.dy=0.0 -- y-velocity, up to +/-4.0
 plyr.dir=1 -- direction, -1 or +1
 plyr.xcam=8 -- player x-position relative to camera, 16 to 104
 plyr.jetspr=16 -- engine sprite
 plyr.reload=0 -- timer for firing effects
 plyr.dead=true -- whether the player is currently on screen
 plyr.lives=3 -- number of lives remaining
 plyr.shield=45 -- countdown until shield vanishes
 plyr.respawn=0 -- countdown until player reappears
 plyr.bombnum=0 -- number of bomb points earned
end

function update_plyr()
 local left=false
 local right=false
 local up=false
 local down=false
 local fire=false
 if not plyr.dead then
  left=btn(0)
  right=btn(1)
  up=btn(2)
  down=btn(3)
  fire=btn(5)
 end

 local jet=false

 -- buttons up, down
 if up and not down then
  if plyr.dy>0 then 
   plyr.dy-=0.9
  else
   plyr.dy=max(-4.0, plyr.dy-0.5)
  end
 elseif down and not up then
  if plyr.dy<0 then
   plyr.dy+=0.9
  else
   plyr.dy = min(4.0, plyr.dy+0.5)
  end
 else
  if abs(plyr.dy) > 0.6 then
   plyr.dy -= 0.6*sgn(plyr.dy)
  else
   plyr.dy = 0
  end
 end
 
 -- buttons left, right
 if left and not right then
  plyr.dir = -1
  if plyr.dx>0 then
   plyr.dx-=1.6
  else
   plyr.dx=max(-8.0, plyr.dx-0.8)
  end
  jet=(plyr.dx<-4.0)
 elseif right and not left then
  plyr.dir = 1
  if plyr.dx<0 then
   plyr.dx+=1.6
  else
   plyr.dx=min(8.0, plyr.dx+0.8)
  end
  jet=(plyr.dx>4.0)
 else
  local dx0=2.0*plyr.dir
  if abs(plyr.dx-dx0) > 0.6 then
   plyr.dx-=0.6*sgn(plyr.dx-dx0)
  else
   plyr.dx=dx0
  end
 end
 
 -- shift camera
 if plyr.dir<0 then
  plyr.xcam = min(104, plyr.xcam+16)
 else
  plyr.xcam = max(16, plyr.xcam-16)
 end
 if plyr.xcam>16 and plyr.xcam<104 then
  local h=(plyr.xcam-16)/(104-16)
  plyr.dx=2.0-4.0*h
 end

 -- apply velocity
 plyr.x+=plyr.dx
 plyr.y+=plyr.dy
 if plyr.y<0 then
  plyr.y=0
  plyr.dy=0
 elseif plyr.y>104 then
  plyr.y=104
  plyr.dy=0
 end
 plyr.x=(plyr.x%gamewidth)
 plyr.xstar=((plyr.xstar+plyr.dx)%starwidth)
 
 -- animate jet
 if jet then
  plyr.jetspr=32
 else
  plyr.jetspr=16
 end
 if tick%6<3 then
  plyr.jetspr+=1
 end
 
 -- fire laser beams
 if plyr.reload==0 and fire then
  plyr.reload=9
  sfx(0)
 end
 if plyr.reload>0 then
  if plyr.reload>2 then
   add_beam()
  end
  plyr.reload-=1
 end

 -- respawn
 plyr.shield=max(0,plyr.shield-1)
 if plyr.respawn>0 then
  plyr.respawn-=1
  if plyr.respawn==0 then
   if plyr.lives>0 then
    plyr.shield=45
    plyr.dead=false
   else
    state=2
	state_timer=45
	update_hiscores()
	sfx(14)
   end
  end
 end
 
end

function draw_plyr()
 if plyr.dead then
  return
 end
 if plyr.dir>0 then
  spr(1, plyr.xcam, plyr.y+16)
  spr(plyr.jetspr, plyr.xcam-8, plyr.y+16)
 else
  spr(1, plyr.xcam, plyr.y+16, 1,1,true)
  spr(plyr.jetspr, plyr.xcam+8, plyr.y+16, 1,1,true)
 end 
end

function draw_shield()
 if plyr.dead or plyr.shield==0 or bomb_timer>0 then
  return
 end
 local flash=flr(plyr.shield/3)
 if flash<=5 and flash%2==1 then
  return
 end
 local cols={2,2,8,14}
 local offs={0,1,2,3}
 for k=1,4 do
  local col=cols[flr(rnd(#cols))+1]
  del(cols,col)
  local off=offs[flr(rnd(#offs))+1]
  del(offs,off)
  circ(plyr.xcam+3+(off%2), plyr.y+19+flr(off/2), 9, col)
 end
end

function add_beam()
 beam={}
 beam.dir=plyr.dir -- direction, +1 or -1
 beam.maxlen=0 -- furthest x-distance from origin
 beam.minlen=0 -- nearest x-distance from origin
 beam.xmin=0 -- start x-position
 beam.xmax=0 -- end x-position
 beam.y=flr(plyr.y)+6 -- y-position
 add(beams,beam)
end

function update_beams()
 for beam in all(beams) do
  beam.maxlen=min(104,beam.maxlen+20)
  if beam.maxlen>20 then
   beam.minlen+=9+flr(beam.maxlen/20)
  end
  local x=plyr.x-1+9*(beam.dir+1)/2
  local x0=x+beam.dir*beam.minlen
  local x1=x+beam.dir*beam.maxlen
  beam.xmin=min(x0,x1)
  beam.xmax=max(x0,x1)
  if beam.minlen>90 then
   del(beams,beam)
  end
 end
end

function draw_beams()
 for beam in all(beams) do
  local x0=plyr.xcam-1+9*(beam.dir+1)/2
  local y0=beam.y+16
  local gap=1+beam.minlen/30
  local fade=beam.minlen+5
  local f=0
  while f<fade do
   local df=flr(rnd(4)+1)
   line(x0+(beam.minlen+f)*beam.dir, y0, 
        x0+(beam.minlen+f+df)*beam.dir, y0, 8)
   f+=df+flr(rnd(gap)+2)
  end
  line(x0+(beam.minlen+f)*beam.dir, y0, 
       x0+beam.maxlen*beam.dir, y0, 8)
 end
end

function add_wave()
 local x0=plyr.x+gamewidth/4+flr(rnd(gamewidth/2))
 local y0=-16
 local dx0=rnd(1.0)-0.5
 local dy0=(0.3+rnd(0.3))*rnd_sgn()
 if rnd(1)<0.5 then
  y0=120
  dy0=-dy0
 end
 wave={}
 wave.phase=0 -- formation type, 0 to 8
 wave.morph=0 -- timer for phase change, 0 when finished
 wave.x=x0 -- reference x-position
 wave.y=y0 -- reference y-position
 wave.dx=dx0 -- reference x-velocity
 wave.dy=dy0 -- reference y-velocity
 wave.timer=0 -- general purpose timer
 wave.enmys={} -- list of enemies
 for k=1,9 do
  local x=x0+rnd(16)-8
  local y=y0+rnd(16)-8
  enmy={}
  enmy.hits=0 -- damage count
  enmy.heal=0 -- ticks until healed
  enmy.dir=0 -- direction, -1 or +1
  -- current position and velocity
  enmy.x=0
  enmy.y=0
  enmy.dx=0
  enmy.dy=0
  -- position and velocity according to wave
  enmy.wx=x
  enmy.wy=y
  enmy.wdx=0
  enmy.wdy=0
  -- position and velocity at start of morph
  enmy.mx=0
  enmy.my=0
  enmy.mdx=0
  enmy.mdy=0
  add(wave.enmys,enmy)
 end
 add(waves,wave)
end

function new_waves()
 if plyr.dead then
  return
 end
 wave_timer-=1
 if wave_timer<=0 then
  add_wave()
  wave_timer=75+flr(rnd(50))
  if level>0 and #waves<level+3 then
   wave_timer=flr(wave_timer/3)
  end
 end
end

function update_waves()
 new_waves()
 for wave in all(waves) do
  if wave.phase==0 then
   -- wave phase 0
   local px=plyr.x+64*plyr.dir-near_plyr(wave.x)
   local py=plyr.y-wave.y
   if abs(px)<128 and not plyr.dead then
    local pang=atan2(px,py)
    local h=min(1, (128-px)/32)
    wave.x+=(1-h)*wave.dx+h*4.0*cos(pang)
    wave.y+=(1-h)*wave.dy+h*4.0*sin(pang)
   else
    wave.x+=wave.dx
    wave.y+=wave.dy
   end
   if wave.y<24 and wave.dy<0 then
    wave.dy=0.1+rnd(0.5)
   elseif wave.y>96 and wave.dy>0 then
    wave.dy=-(0.1+rnd(0.5))
   end
   wave.y=max(0,min(104,wave.y))
   local meanx=0
   local meany=0
   for k=1,#wave.enmys do
    local enmy=wave.enmys[k]
    local dx=near_to(wave.x-enmy.wx,0)
    local dy=wave.y-enmy.wy
    local ang=atan2(dx,dy)
    enmy.wdx+=0.2*cos(ang)
    enmy.wdy+=0.2*sin(ang)
    
    local i=flr(rnd(#wave.enmys-1))+1
    local other=wave.enmys[(k+i)%#wave.enmys+1]
    local dx=near_to(enmy.wx-other.wx,0)
    local dy=enmy.wy-other.wy
    local d=max(1,sqrt(dx*dx+dy*dy))
    if d<16 then
     local f=0.4*(1-d/16)
     enmy.wdx+=f*dx/d
     enmy.wdy+=f*dy/d
     other.wdx-=f*dx/d
     other.wdy-=f*dy/d
    end

    enmy.wdx=max(-1.5,min(1.5,enmy.wdx))
    enmy.wdy=max(-1.5,min(1.5,enmy.wdy))

    enmy.wx=near_plyr(enmy.wx+enmy.wdx)
    enmy.wy=enmy.wy+enmy.wdy
    meanx+=near_to(enmy.wx,wave.x)
    meany+=enmy.wy
   end
   wave.x=near_plyr(meanx/#wave.enmys)
   wave.y=meany/#wave.enmys
  elseif wave.phase==1 then
   -- wave phase 1
   wave.x=near_plyr(wave.x+wave.dx)
   wave.y+=wave.dy
   if wave.y>=104 and wave.dy>0 then
    wave.y=104
    wave.dy=-wave.dy
   elseif wave.y<=0 and wave.dy<0 then
    wave.y=0
    wave.dy=-wave.dy
   end
   local kmid=(#wave.enmys+1)/2
   for k=1,#wave.enmys do
    local enmy=wave.enmys[k]
    enmy.wx=wave.x-8*(k-kmid)*wave.dx
    enmy.wy=wave.y-4*(k-kmid)*wave.dy
    enmy.wx=near_plyr(enmy.wx)
    enmy.wdx=wave.dx
    enmy.wdy=wave.dy
    if enmy.wy<0 then
     enmy.wy=-enmy.wy
     enmy.wdy=-enmy.wdy
    elseif enmy.wy>104 then
     enmy.wy=2*104-enmy.wy
     enmy.wdy=-enmy.wdy
    end
   end
  elseif wave.phase==2 then
   -- wave phase 2
   wave.x=near_plyr(wave.x+wave.dx)
   wave.dx+=0.1*sgn(wave.dx)
   wave.dx=max(-3,min(3,wave.dx))
   for k=1,#wave.enmys do
    local enmy=wave.enmys[k]
    enmy.wx=wave.x-4*flr((k-1+(#wave.enmys%2))/2)*sgn(wave.dx)
    enmy.wy=wave.y+8*flr(k/2)*(2*(k%2)-1)
    enmy.wdx=wave.dx
    enmy.wdy=0
   end
  elseif wave.phase==3 then
   -- wave phase 3
   wave.x=near_plyr(wave.x+wave.dx)
   wave.dx+=0.1*sgn(wave.dx)
   wave.dx=max(-1.5,min(1.5,wave.dx))
   local kmid=(#wave.enmys+1)/2
   for k=1,#wave.enmys do
    local enmy=wave.enmys[k]
    enmy.wx=wave.x+8*(k-kmid)
    enmy.wy=wave.y+16*sin(enmy.wx/128)
    enmy.wdx=wave.dx
    enmy.wdy=0
   end
  elseif wave.phase==4 then
   -- wave phase 4
   wave.x=near_plyr(wave.x+wave.dx)
   wave.dx+=0.1*sgn(wave.dx)
   wave.dx=max(-1.6,min(1.6,wave.dx))
   wave.y+=wave.dy
   if wave.y>92 then
    wave.dy=-abs(wave.dy)
   elseif wave.y<12 then
    wave.dy=abs(wave.dy)
   end
   for k=1,#wave.enmys do
    local enmy=wave.enmys[k]
    enmy.wx=wave.x+16*cos(k/5-wave.x/128)
    enmy.wy=wave.y+16*sin(k/5-wave.x/128)
    enmy.wdx=wave.dx
    enmy.wdy=wave.dy
   end   
  elseif wave.phase==5 then
   -- wave phase 5
   wave.x=near_plyr(wave.x+wave.dx)
   wave.dx+=0.1*sgn(wave.dx)
   wave.dx=max(-1.4,min(1.4,wave.dx))
   wave.timer=(wave.timer+0.05*sgn(wave.dx))%1.0
   local dx=12*(sin(wave.timer)+1)/2
   local dy1=8*(sin(wave.timer+0.3)+1)/2
   local dy2=8*(sin(wave.timer+0.7)+1)/2
   for k=1,#wave.enmys do
    local enmy=wave.enmys[k]
    local dy=dy1
    if k%2==1 then
     dy=dy2
    end
    enmy.wx=wave.x+(4+dx)*(2*(k%2)-1)
    enmy.wy=wave.y+(4+dy)*((k+(k%2))-3)
    enmy.wdx=wave.dx
    enmy.wdy=wave.dy
   end   
  elseif wave.phase==6 then
   -- wave phase 6
   wave.x=near_plyr(wave.x+wave.dx)
   wave.y+=wave.dy
   wave.timer-=1
   if wave.timer<=0 then
    wave.timer=60+rnd(60)
    wave.dx=-wave.dx
    local dy=(8+rnd(88))-wave.y
    wave.dy=dy/wave.timer
    wave.dy=max(-50,min(50,wave.dy))
   elseif wave.timer<20 then
    wave.dx=sgn(wave.dx)*2.0*wave.timer/20
   else
    wave.dx+=0.1*sgn(wave.dx)
    wave.dx=max(-2.0,min(2.0,wave.dx))
   end
   local f=wave.dx/2.0
   for k=1,#wave.enmys do
    local enmy=wave.enmys[k]
    enmy.wx=wave.x-10*f*abs(k-2)
    enmy.wy=wave.y+(12-5*abs(f))*(k-2)
    enmy.wdx=wave.dx
    enmy.wdy=wave.dy
   end   
  elseif wave.phase==7 then
   -- wave phase 7
   wave.x=near_plyr(wave.x+wave.dx)
   wave.timer-=0.04
   local d=0.0
   if wave.timer<0 then
    wave.timer+=1
	wave.y=flr(wave.y)
    if wave.y<=32 then
     wave.dy=1
    elseif wave.y>=72 then
     wave.dy=-1
    else
     wave.dy=rnd_sgn()
    end 
   elseif wave.timer<0.5 then
    d=(1+cos(wave.timer/0.5-0.5))/2
    wave.y+=1.5*d*wave.dy
   end
   for k=1,#wave.enmys do
    local enmy=wave.enmys[k]
    enmy.wx=wave.x
    enmy.wy=wave.y+(4+12*d)*(2*k-3)
    enmy.wdx=wave.dx
    enmy.wdy=0
   end   
  else
   -- wave phase 8
   wave.x=near_plyr(wave.x+wave.dx)
   wave.y+=wave.dy
   wave.dx+=0.2*sgn(wave.dx)
   wave.dx=max(-3.5,min(3.5,wave.dx))
   local enmy=wave.enmys[1]
   enmy.wx=wave.x
   enmy.wy=wave.y
   enmy.wdx=wave.dx
   enmy.wdy=wave.dy
  end
 end
 morph_waves()
 for wave in all(waves) do
  for enmy in all(wave.enmys) do
   if wave.phase>0 and wave.morph==0 then
    enmy.dir=sgn(wave.dx)
   else
    enmy.dir=sgn(enmy.dx)
   end
   if enmy.heal>0 then
    enmy.heal-=1
    if enmy.heal==0 then
     enmy.hits=0
    end
   end
  end
 end
end

function morph_waves()
 for wave in all(waves) do
  if wave.morph==0 then
   for enmy in all(wave.enmys) do
    enmy.dx=enmy.wx-enmy.x
    enmy.dy=enmy.wy-enmy.y
    enmy.x=enmy.wx
    enmy.y=enmy.wy
   end
  else
   wave.morph=max(0,wave.morph-1/morphtime)
   local u=wave.morph -- 1 at start, 0 at end
   local a0=(2*u+1)*(u-1)*(u-1) -- a0(0)=1
   local a1=u*u*(3-2*u) -- a1(1)=1
   local b0=u*(u-1)*(u-1)/morphtime -- deriv(b0)(0)=1
   local b1=u*u*(u-1)/morphtime -- deriv(b1)(1)=1
   for enmy in all(wave.enmys) do
    enmy.mx=near_to(enmy.mx, enmy.wx)
    local x=a0*enmy.wx + a1*enmy.mx
           + b0*enmy.wdx + b1*enmy.mdx
    local y=a0*enmy.wy + a1*enmy.my
           + b0*enmy.wdy + b1*enmy.mdy
    enmy.dx=x-near_to(enmy.x,x)
    enmy.dy=y-enmy.y
    enmy.x=near_plyr(x)
    enmy.y=y
   end
  end
 end
end

function start_morph(wave)
 local x0=0
 local y0=0
 for enmy in all(wave.enmys) do
  enmy.mx=enmy.x
  enmy.my=enmy.y
  enmy.mdx=enmy.dx
  enmy.mdy=enmy.dy
  x0+=near_to(enmy.x,wave.x)
  y0+=enmy.y
 end
 x0=near_plyr(flr(x0/#wave.enmys))
 y0=flr(y0/#wave.enmys)
 
 wave.morph=1
 wave.phase=9-#wave.enmys
 if wave.phase==1 then
  -- start phase 1
  wave.x=x0
  wave.y=max(1, min(103, y0))
  wave.dx=rnd_sgn()
  wave.dy=rnd_sgn()
 elseif wave.phase==2 then
  -- start phase 2
  local ysize=8*#wave.enmys
  wave.x=x0
  wave.y=max(ysize/2-4, min(108-ysize/2, y0))
  wave.dx=0.1*rnd_sgn()
  wave.dy=0
 elseif wave.phase==3 then
  -- start phase 3
  wave.x=x0
  wave.y=max(16, min(88, y0))
  wave.dx=0.5*rnd_sgn()
  wave.dy=0
 elseif wave.phase==4 then
  -- start phase 4
  wave.x=x0
  wave.y=max(16, min(92, y0))
  wave.dx=1.0*rnd_sgn()
  wave.dy=0.1*(1+rnd(1))*rnd_sgn()
 elseif wave.phase==5 then
  -- start phase 5
  wave.x=x0
  wave.y=max(8, min(96, y0))
  wave.dx=0.1*rnd_sgn()
  wave.dy=0
  wave.timer=0.0
 elseif wave.phase==6 then
  -- start phase 6
  wave.x=x0
  wave.y=max(8, min(96, y0))
  wave.dx=0
  wave.dy=0
  wave.timer=10
 elseif wave.phase==7 then
  -- start phase 7
  wave.x=x0
  wave.y=max(12, min(92, y0))
  wave.dx=1.0*rnd_sgn()
  wave.dy=0
  wave.timer=1.0
 else
  -- start phase 8
  wave.x=x0
  wave.y=max(0, min(104, y0))
  if abs(wave.dx)<0.1 then
   wave.dx=0.1*rnd_sgn()
  else
   wave.dx=-0.1*sgn(wave.dx)
  end
  wave.dy=0
  wave.morph=0
 end
end

function draw_enmys()
 for wave in all(waves) do
  for enmy in all(wave.enmys) do
   local sprite=3+wave.phase
   if enmy.hits>0 then
    sprite=2
   end
   spr(sprite, enmy.x+plyr.xcam-plyr.x, enmy.y+16, 
       1,1, (enmy.dir>0))
  end
 end
end

function hit_enmys()
 if #beams==0 or bomb_timer>0 then
  return
 end
 
 local xmin=32767
 local xmax=-32767
 local ymin=32767
 local ymax=-32767
 for beam in all(beams) do
  xmin=min(xmin,beam.xmin)
  xmax=max(xmax,beam.xmax)
  ymin=min(ymin,beam.y)  
  ymax=max(ymax,beam.y)
 end
 xmin-=7
 ymin-=7

 local kill_sfx=-1
 for wave in all(waves) do
  local kill=false
  for enmy in all(wave.enmys) do
   if enmy.x>=xmin and enmy.x<=xmax and 
      enmy.y>=ymin and enmy.y<=ymax then
    for beam in all(beams) do
     if enmy.x>=beam.xmin-7 and enmy.x<=beam.xmax and
        enmy.y>=beam.y-7 and enmy.y<=beam.y then
      enmy.heal=4
      enmy.hits+=1
      kill_sfx=max(kill_sfx,1)
      if enmy.hits>=5 then
       add_expl(enmy,false)
       del(wave.enmys,enmy)
       score+=1
       kill=true
      end
      break
     end
    end
   end
  end
  if kill then
   kill_sfx=max(kill_sfx,10-#wave.enmys)
   if #wave.enmys==0 then
    local text=""
    if plyr.lives<3 then
     plyr.lives+=1
     text="+1"
	else
	 plyr.bombnum+=1
	 if plyr.bombnum<level+3 then
	  text="++"
	 end
     kill_sfx=max(kill_sfx,11)
    end
    add_tag(wave.x,wave.y+1,text)
    del(waves,wave)
   else
    for enmy in all(wave.enmys) do
     enmy.hits=min(1,enmy.hits)
    end
    start_morph(wave)
   end
  end
 end
 if plyr.bombnum>=level+3 and bomb_timer==0 then
  bomb_timer=6
  plyr.shield=45
  kill_sfx=max(kill_sfx,12)
 end
 if kill_sfx>=1 then
  sfx(kill_sfx)
 end 
end

function hit_plyr()
 if plyr.dead or plyr.shield>0 then
  return
 end
 for wave in all(waves) do
  for enmy in all(wave.enmys) do
   if enmy.x>=plyr.x-7 and enmy.x<=plyr.x+7 and 
      enmy.y>=plyr.y-7 and enmy.y<=plyr.y+7 then
    add_expl(plyr,true)
    plyr.dead=true
    plyr.lives-=1
    plyr.respawn=30
    sfx(13)
    beams={}
    break
   end
  end
 end
end

function add_expl(thing,is_plyr)
 expl={}
 expl.x=thing.x -- x-position
 expl.y=thing.y -- y-position
 expl.dir=thing.dir -- direction, +1 or -1
 expl.plyr=is_plyr -- bool
 expl.t=0 -- ticks since created
 expl.bits={} -- shrapnel pieces
 local num_bits=10
 local dr_rnd=0.5
 if is_plyr then
  num_bits=20
  dr_rnd=1.2
 end
 for k=1,num_bits do
  local ang=rnd(1)
  bit={}
  bit.dx=cos(ang) -- x-direction
  bit.dy=sin(ang) -- y-direction
  bit.r=3.5+rnd(1) -- distance from origin
  bit.dr=0.1+rnd(dr_rnd) -- radial speed
  add(expl.bits,bit)
 end
 add(expls,expl)
end

function update_expls()
 for expl in all(expls) do
  expl.x=near_plyr(expl.x)
  expl.t+=1
  for bit in all(expl.bits) do
   bit.r+=bit.dr
  end
  if expl.t>8 then
   del(expls,expl)
  end
 end
end

function draw_expls()
 for expl in all(expls) do
  local xs=expl.x+plyr.xcam-plyr.x
  local ys=expl.y+16
  if expl.t<=2 then
   local sp=20
   if expl.plyr then
    sp=18
   end
   spr(sp, xs-4, ys-4, 2,2, (expl.dir>0))
  end
  for bit in all(expl.bits) do
   pset(xs+3.5+bit.dx*bit.r, ys+3.5+bit.dy*bit.r, 8)
  end
 end
end

function update_bomb()
 if bomb_timer==0 then
  return
 end
 bomb_timer-=1
 if bomb_timer==0 then
  for wave in all(waves) do
   for enmy in all(wave.enmys) do
    if abs(enmy.x-plyr.x)<=128 then
     add_expl(enmy,false)
    end
    score_delay+=1
   end
  end
  score_delay+=50
  score+=score_delay
  waves={}
  plyr.bombnum=0
  level+=1
  wave_timer=30
 end
end

function add_tag(x,y,text)
 if #text==0 then
  return
 end
 tag={}
 tag.x=x -- x-position
 tag.y=y -- y-position
 tag.t=0 -- ticks since added
 tag.text=text -- tag string
 add(tags,tag)
end

function update_tags()
 for tag in all(tags) do
  tag.t+=1
  if tag.t>20 then
   del(tags,tag)
  end
 end
end

function draw_tags()
 if bomb_timer>0 then
  return
 end
 for tag in all(tags) do
  local xs=tag.x+plyr.xcam-plyr.x
  local ys=tag.y+16
  print(tag.text,xs,ys,7)
 end
end

alien_cols={{5,6},{9,2},{12,1},{11,4},{15,8},{2,14},{1,9},{3,2},{8,14}}

function draw_scan()
 rectfill(0,0, 127,15, 0)
 line(23,0, 23,15, 5)
 line(24,0, 25,0, 5)
 line(24,15, 25,15, 5)
 line(103,0, 103,15, 5)
 line(101,0, 102,0, 5)
 line(101,15, 102,15, 5)
 for wave in all(waves) do
  local scan_col=alien_cols[wave.phase+1][1]
  for enmy in all(wave.enmys) do
   draw_on_scan(enmy.x,enmy.y,scan_col)
  end
 end
 if not plyr.dead then
  draw_on_scan(plyr.x,plyr.y,7)
 end
end

function draw_on_scan(x,y,col)
 if bomb_timer>0 and col~=7 then
  col=8
 end
 local px=flr((x-plyr.x+4)/8)
 local py=flr((y+4)/8)
 if px>=-39 and px<=39 and py>=0 and py<=13 then
  pset(px+63,py+1,col)
 end
end

function draw_score()
 if score>0 then
  print((score-score_delay).."0",0,1,5)
 else
  print("0",0,1,5)
 end
end
 
function draw_lives()
 for k=0,2 do
  local sp=48
  if k>=plyr.lives then
   sp+=1
  end
  spr(sp, 111+6*k, 1)
 end
 if plyr.bombnum>0 then
  local h=min(1.0,plyr.bombnum/(level+3))
  if h<1.0 then
   local d=flr(10*h)
   rect(113,9, 125,12, 5)
   rectfill(114,10, 114+d,11, 8)
  else
   rect(113,9, 125,12, 7)
   rectfill(114,10, 124,11, 8)
  end
 end
end

title_text={{54,55,56,57,58},{59,56,60,61},{56,58,62,54,60,56,63,58}}

function draw_text()
 if state==0 then
  local cols=alien_cols[(flr(tick/30)%#alien_cols)+1]
  pal(7,cols[1])
  pal(5,cols[2])
  local y=64-6*#title_text
  for i=1,#title_text do
   local text=title_text[i]
   local x=65-4*#text
   for j=1,#text do
    local sp=text[j]
    spr(sp,x,y)
	x+=8
	if sp==56 then
	 x-=1
	end
   end
   y+=14
  end
  pal()
 elseif state==2 or state==3 then
  if state==2 or #hiscores==0 then
   print("game over",46,61,7)
  else
   local y=61-3*#hiscores
   print("high scores",42,y,7)
   y+=12
   for k=1,#hiscores do
    local str=hiscores[k]..'0'
	local x=64-2*#str
	local col=7
	if k==hiscore_index and (tick/8)%1.0<0.5then
	 col=14
	end
    print(str,x,y,col)
	y+=6
   end
  end
 end
 if state==0 or state==3 then
  print("press \151 to play",32,120,5)
 end
end

function init_hiscores()
 hiscores={}
 local num_hi=min(6,max(0,dget(0)))
 for k=1,num_hi do
  local val=dget(k)
  if val>0 and (#hiscores==0 or val<=hiscores[#hiscores]) then
   add(hiscores,val)
  end
 end
end

function update_hiscores()
 hiscore_index=0
 if score<=0 then
  return
 end
 new_hiscores={}
 for i=1,#hiscores do
  if score>hiscores[i] and hiscore_index==0 then
   hiscore_index=i
   add(new_hiscores,score)
  end
  if #new_hiscores<6 then
   add(new_hiscores,hiscores[i])
  end
 end
 hiscores=new_hiscores
 if hiscore_index==0 and #hiscores<6 then
  add(hiscores,score)
  hiscore_index=#hiscores
 end
 if hiscore_index>0 then
  dset(0,#hiscores)
  for k=1,#hiscores do
   dset(k,hiscores[k])
  end
 end
end

function rnd_sgn()
 return 2*flr(rnd(2))-1 -- random -1 or +1
end

function near_to(x, x0)
 local dx=x-x0
 dx=(dx+gamewidth/2)%gamewidth - gamewidth/2
 return x0+dx
end

function near_plyr(x)
 return near_to(x, plyr.x)
end

__gfx__
00000000000eee000000888800006666000022220000111100004444000088880000eeee00009999000022220000eeee00000000000000000000000000000000
0000000000eeeee000888880005556600099922000ccc11000bbb44000fff88000222ee0001119900033322000888ee000000000000000000000000000000000
000000000eee777e0888888005f55550091999900c4cccc00babbbb00f5ffff00292222001f111100373333008f8888000000000000000000000000000000000
000000008eeeee7e888888005ff5560091199200c44cc100baabb400f55ff80029922e001ff11900377332008ff88e0000000000000000000000000000000000
0000000088eeeeee888888805555556099999920cccccc10bbbbbb40ffffff80222222e01111119033333320888888e000000000000000000000000000000000
000000008ee8e0000888888805566556099229920cc11cc10bb44bb40ff88ff8022ee22e0119911903322332088ee88e00000000000000000000000000000000
0000000000ee8e8008888888065556660299922201ccc11104bbb44408fff8880e222eee09111999023332220e888eee00000000000000000000000000000000
00000000000ee0000088880000665500002299000011cc000044bb000088ff0000ee2200009911000022330000ee880000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000890000090000000088888000000000000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009900009808900000880008800000000008880000800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000890000090000008800000880000000088000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008000000088000000880000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008000000008000000800000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008000000008000000800000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008888000008000000880000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000008000000000800000888000000080000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000890000090000000888008800000000088000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009900009808900000008888000000000008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000890000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eee0000055500000000000000000000000000000000000000777000770000007777770077777770770007707777777007777770770007707700077007777700
8e77e000550050000000000000000000000000000000000007777700770000007777770077777770777007707777777077777770770007707700077077777770
8eeee000555550000000000000000000000000000000000077707770770000000077000077000000777707707700000077000000770007707700077077000770
8e8e0000550500000000000000000000000000000000000077000770770000000077000077777000777777707777700077777700777777707700077077000770
0ee80000055000000000000000000000000000000000000077777770770000000077000077777000770777707777700007777770777777707700077077000770
00000000000000000000000000000000000000000000000057777750570000000055000057000000570077505700000000000750570007505570755057000750
00000000000000000000000000000000000000000000000055000550555555505555550055555550550005505500000055555550550005500555550055555550
00000000000000000000000000000000000000000000000055000550555555505555550055555550550005505500000055555500550005500055500005555500
66666666666666666666666d00000066660000000000000660000000000000666666666666000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5000066dddd6600000000006dd6000000000006dddddddddddd600000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd50006dddddddd6000000006dddd600000000006dddddddddddd600000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5006dddddddddd60000006dddddd6000000006dddddddddddddd50000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd506dddddddddddd500006dddddddd600000006dddddddddddddd50000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd506dddddddddddd50006dddddddddd600000005dddddddddddd500000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd56dddddddddddddd506dddddddddddd60000005dddddddddddd500000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd56dddddddddddddd56dddddddddddddd6000000555555555555000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd56dddddddddddddd55dddddddddddddd5000000000000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd56dddddddddddddd505dddddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd506dddddddddddd50005dddddddddd500000000000000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd506dddddddddddd500005dddddddd5000000000000000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5005dddddddddd50000005dddddd50000000660000000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd50005dddddddd5000000005dddd500000066dd6600000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5000055dddd5500000000005dd50000006dddddd50000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5000000555500000000000005500000006dddddd50000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5dddddd6666ddddddddddddd66ddddddd6dddddd50000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5dddd66dddd66dddddddddd6dd6dddddd6dddddd50000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5ddd6dddddddd6dddddddd6dddd6ddddd6dddddd50000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5dd6dddddddddd6dddddd6dddddd6dddd6dddddd50000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5d6dddddddddddd5dddd6dddddddd6ddd6dddddd50000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd5d6dddddddddddd5ddd6dddddddddd6dd6dddddd50000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddd56dddddddddddddd5d6dddddddddddd6d6dddddd50000000000000000000000000000000000000000000000000000000000000000
d555555555555555555555556dddddddddddddd56dddddddddddddd66dddddd50000000000000000000000000000000000000000000000000000000000000000
dddddddd00000000000000006dddddddddddddd55dddddddddddddd56dddddd50000000000000000000000000000000000000000000000000000000000000000
d111111d00000000000000006dddddddddddddd5d5dddddddddddd5d6dddddd50000000000000000000000000000000000000000000000000000000000000000
d111116d0000000000000000d6dddddddddddd5ddd5dddddddddd5dd055dd5500000000000000000000000000000000000000000000000000000000000000000
d111116d0000000000000000d6dddddddddddd5dddd5dddddddd5ddd000550000000000000000000000000000000000000000000000000000000000000000000
d111116d0000000000000000dd5dddddddddd5dddddd5dddddd5dddd000000000000000000000000000000000000000000000000000000000000000000000000
d111116d0000000000000000ddd5dddddddd5dddddddd5dddd5ddddd000000000000000000000000000000000000000000000000000000000000000000000000
d166666d0000000000000000dddd55dddd55dddddddddd5dd5dddddd000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd0000000000000000dddddd5555ddddddddddddd55ddddddd000000000000000000000000000000000000000000000000000000000000000000000000
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
0000404200404200404200404200000000000000000000000000434141414141414141414144000000000000000000000000404200404200404200000000000000000000000000434141440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4341414141414141414141414141440000000000000000000000505150616161616161525152000000000000000000004341414141414141414141440000000000004341414141414141414141440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051506161616161616161615251520000000000000000000000505050707070707070525252000000000000000000005051506161616161615251520057000057005051506161616161615251520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050507070707070707070705252520000000000000000000000505150414141414141525152000000000000000000005050507070707070705252524167414167415050507070707070705252520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051504141414141414141415251520000000000000000000000536161616161616161616154000000000000000000005051504141414141415251526167616167615051504141414141415251520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5361616161616161616161616161540000000000000000000000000050520000000050520000000000000000000000005361616161616161616161540077505277005361616161616161616161540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000606200536161540000505200000000000000000040420040420050520000000050520000404200004042000000000000505200000000606200000000505200000000000000536161540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005052000000505200000000000000434141414141414141414144004550524645505246455052460000000047484849000000000000000000505200000000000000005052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5700000045414141414600505200000000000000505150616161616161525152414156554141565541415655414141414141515200000000000000575743414144570000000045414141414600000057000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6741414150636463645241414141414141414141505050707070707070525252616146456161464561614645616161616161515200000000000043676750636452670000000050636463645241414167410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6761616150737473745261616161616161616161505150414141414141525152005550525655505256555052560000000047484849000000000053676750737452670000000050737473745261616167610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7700000055616161615600505200000000000000536161616161616161616154000050520000606200006062000000000000606200000000000000777753616154770000000055616161615600000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000606200000000000000000000000000000000000000000060620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010300000c4171341718417154171841713417184170c417004070040700407004070040700407004070040700407004070040700407004070040700407004070040700407004070040700407004070040700407
010300002b51318503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
01070000134010c433074230c40300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
01070000134110c423074130c40300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
01070000154110c423074130c40300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
01070000174110c423074130c40300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
01070000184110c423074130c40300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
010700001a4110c423074130c40300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
010700001c4110c423074130c40300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
010700001d4110c423074130c40300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
010700001f4110c423074133951326513355132651326503004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
010700001f4110c423305112b51130521130001f50121307004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
010700002b4210c4331c42115423305112b5113052129511245111d5110c511004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
01080000244231f41318413134130c413074130040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403004030040300403
010a00001f513105130c5130751300513005130050300505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
010700002450318503105030c50307503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
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
