pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
camx = 0
camy = 384
camx_off = 0
camy_off = 0
smooth_camera=false

h_threshold=60
v_threshold=33

collided_side2=false

checkpoint_pos={}

object_types={}

objects={}

double_unlocked=false
glide_unlocked=false

show_timer=true

shake=0

first_dialog={"who are you?",
"that's not your\nproblem, i just want\nto see numenas.",
"i am looking for\nnumenas too, is he\nbehind that wall?",
"yeah, he is hiding\nthere and i need\n2 keys to enter.",
"i can go look for\nthem.",
"no, this is between\nnumenas and i, i\ncan't let you be here.",
"what do you mean?",
"i'll have to get rid\nof you."}
second_dialog={"i need to see\nnumenas and you can't\nstop me.",
"you'll need the keys\nthat are down the\ncastle."}
numenas_dialog={"you have no escape.",
"you're right...\nonly one can survive."}
last_dialog={"so this is the end...",
"this is only the\nbeggining.",
"w- was that you? you\nare still alive?",
"there's a lot we need\nto catch on.",
"what's happening?",
"you need to escape!\nquickly!",
"ha ha! try as hard as\nyou want.",
"go!"}
last_indixes={2,1,2,1,0,2,1,2}
dialog_used={}
dialog_active=false
dialog_window=1
dialog_current=""
dialog_timer=0
dialog_chara=1
state=0
free_cam=true
cutscene=false
jump_last=false

add_platform={23,12, 24,12,
60,13, 61,13, 62,13,
116,10, 117,10,
87,62, 88,62, 89,62,
34,61, 35,61}
delete={82,13, 91,28, 78,27, 43,27, 38,28, 21,21, 3,41, 1,43, 47,41, 82,37, 91,42, 85,54, 90,54}
add_hedge={38,10, 81,13, 78,27, 34,28, 40,28, 17,45, 82,37}
add_shooter={87,28, 42,27, 11,43, 92,37, 97,61}
add_mole={}

normal_collision=true

function stop_music()
 music(-1,500)
end

function trigger_descent()
 state=3
 dialog_chara=2
	for e in all(objects) do
  e.dead=false
  e.x=e.ix
  e.y=e.iy
  e.dir=false
  e.dx=0
  e.dy=0
  if e.type.die~=nil then
   e.type.die(e)
  end
  if e.type==unnamed then
   del(objects, e)
  end
 end
 for i=1,#add_platform-1,2 do
  mset(add_platform[i], add_platform[i+1], 64)
 end
 for i=1,#delete-1,2 do
  for j in all(objects) do
   if j.ix/8==delete[i] and j.iy/8==delete[i+1] then
    del(objects, j)
   end
  end
 end
 for i=1,#add_hedge-1,2 do
  init_object(hedge, add_hedge[i]*8, add_hedge[i+1]*8)
 end
 for i=1,#add_shooter-1,2 do
  init_object(shooter, add_shooter[i]*8, add_shooter[i+1]*8)
 end
 for i=1,#add_mole-1,2 do
  init_object(mole, add_mole[i]*8, add_mole[i+1]*8)
 end
 
 mset(13,24,40)
 mset(14,24,41)
 mset(13,25,56)
 mset(14,25,57)
 
 mset(83,57,42)
 mset(84,57,43)
 mset(83,58,58)
 mset(84,58,59)
end

function toint(b)
	if b then
		return 1
	else
		return -1
	end
end

function sign(a)
	if a>0 then
		return 1
	elseif a<0 then
		return -1
	else
		return 0
	end
end

function on_screen(x,y,w,h)
	if camx-16<x+w and camx+144>x then
		if camy-16<y+h and camy+144>y then
			return true
		end
	end
end

function create_smoke(x,y,n,c)
 for i=1,n do
  local s = init_object(smoke, x, y)
  s.c=c
 end
end

numenas = {
 tile=14,
 stare=true,
 init=function(this)
  this.x=60
  this.y=16
  this.phase=0
  this.timer=0
  this.final_speed=30
 end,
 update=function(this)
  this.timer+=1
  if this.phase==0 then
   if this.timer%45==0 then
    this.x=rnd(120)
    aim_bullet(this,p1,1.25)
   end
   if this.timer==300 then
    this.phase=1
    this.timer=0
    this.x=136
   end
  elseif this.phase==1 then
   if this.timer%20==0 then
    local b=init_object(bullet, -8, 48+rnd(64,104))
    b.velx=1.25
    b.vely=0
   end
   if this.timer==300 then
    this.timer=0
    this.phase=2
    this.x=60
   end
  elseif this.phase==2 then
   if this.timer%45==0 then
    aim_bullet(this,p1,1.25)
   end
   if this.timer%45==0 then
    local b=init_object(bullet, -8, 48+rnd(64,104))
    b.velx=1
    b.vely=0
   end
   if this.timer==600 then
    this.timer=0
    this.phase=3
   end
  elseif this.phase==3 then
   if this.timer%120==0 then
    local hole=flr(rnd(8))
    for i=-2,10 do
     if i~=hole then
      aim_bullet(this, {x=i*16, y=104}, 0.3)
     end
    end
   end
   if this.timer==479 then
    this.timer=0
    this.phase=4
    this.x=8
    this.fire_rate=45
   end
  elseif this.phase==4 then
   if this.timer%30==0 and this.timer>150 then
    aim_bullet(this,p1,1.5)
    if this.timer%90==0 then
     this.x=128-this.x
    end
   end
   if this.timer==600 then
    this.phase=5
    this.timer=0
    this.x=60
   end
  elseif this.phase==5 then
   if this.timer==this.final_speed and this.final_speed<80 then
    aim_bullet(this,p1,1.5-this.final_speed/75)
    this.final_speed+=10
    this.timer=0
   end
   if this.final_speed==80 and this.timer==200 then
    this.phase=6
    this.x=16
    this.y=104
   end
  end
  if this.phase==6 and this.stomping then
   p1.dy=p1.djump_speed
   sfx(1)
   create_smoke(this.x+4, this.y-4, 2, 7)
   this.spr=15
   this.dx=-1
   this.dy=-1
   state=11
   stop_music()
   cut_un=init_object(unnamed, 104, 104)
   create_smoke(116,104,2,8)
   this.phase+=1
  end
  if this.phase==7 then
	  this.dy+=p1.grav
	  this.dx=min(this.dx+0.05, 0)
	  this.x+=this.dx
	  this.y+=this.dy
	  this.y=min(this.y, 104)
  end
 end,
 die=function(this)
  numenas.init(this)
  camx=0
  p1.x=60
 end
}

unnamed = {
 tile=12,
 stare=true,
 init=function(this)
  this.x=112
  this.y=104
  this.dir=false
  this.phase=0
  this.timer=0
  this.e1={}
  this.e2={}
  this.fire_rate=45
  this.dx=0
  this.dy=0
 end,
 update=function(this)
  if not cutscene then
   this.timer+=1
  end
  if ticks2%20==0 then
   init_object(particle, this.x+4, this.y)
  end
  if this.phase<6 and this.phase~=3 and this.phase~=4 and this.timer%this.fire_rate==0 then
   aim_bullet(this, p1, 1.5)
  end
  if this.phase==0 then
   if p1.x>96 then
    this.phase=1
    this.x=32
   end
  elseif this.phase==1 then
   if p1.x<48 then
    this.phase=2
    this.timer=0
   end
  elseif this.phase==2 then
   if this.timer==1 then
    this.x=68
    this.y=16
   elseif this.timer==420 then
    this.phase=3
    this.timer=0
   end
  elseif this.phase==3 then
   if this.timer>60 and this.timer%10==0 then
    aim_bullet({x=120, y=104}, {x=0, y=104}, 1.75)
   end
   if this.timer==1 then
    this.x=130
    mset(5,9,64)
    mset(6,9,64)
   elseif this.timer==120 then
    mset(12,9,64)
    mset(13,9,64)
   elseif this.timer==180 then
    mset(5,9,0)
    mset(6,9,0)
   elseif this.timer==240 then
    mset(8,12,64)
    mset(9,12,64)
    mset(10,12,64)
   elseif this.timer==300 then
    mset(12,9,0)
    mset(13,9,0)
   elseif this.timer==320 then
    this.phase=4
    this.timer=0
   end
  elseif this.phase==4 then
   if this.timer==60 then
    mset(8,12,0)
    mset(9,12,0)
    mset(10,12,0)
    this.e1=init_object(shooter, 32, 104)
    this.e2=init_object(shooter, 112, 104)
   end
   if this.e1.dead and this.e2.dead then
    this.phase=5
    this.timer=0
   end
  elseif this.phase==5 then
   if this.timer==1 then
    this.x=68
    this.fire_rate=30
   elseif this.timer==420 then
    this.phase=6
   end
  elseif this.phase==6 then
   this.x=40
   this.y=104
  end
  
  if this.phase<7 and this.stomping then
   sfx(1)
   create_smoke(this.x+4,this.y-4,2,7)
   p1.dy=p1.djump_speed
   this.phase+=1
   this.timer=0
   if this.phase==7 then
    del(objects, this.e1)
    del(objects, this.e2)
   	this.dy=-1
   	this.dx=-1
   	this.spr=13
   	state=2
   	stop_music()
   end
  end
  if this.phase==7 then
	  this.dy+=p1.grav
	  this.dx=min(this.dx+0.05, 0)
	  this.x+=this.dx
	  this.y+=this.dy
	  this.y=min(this.y, 104)
  end
 end,
 die=function(this)
  del(objects, this.e1)
  del(objects, this.e2)
  this.type.init(this)
  mset(5,9,0)
  mset(6,9,0)
  mset(12,9,0)
  mset(13,9,0)
  mset(8,12,0)
  mset(9,12,0)
  mset(10,12,0)
 end
}

miniboss = {
 stare=true,
 init=function(this)
  if this.typ==0 then
  	this.x=104
  	this.y=192
  	this.side_timer=0
   this.side=true
   this.fire_rate=60
  else
   this.x=664
   this.y=456
   this.side=0
   this.fire_rate=50
  end
  this.size=16
  this.hits=0
  this.timer=0
  this.vulnerable=true
  this.invisi_timer=0
  this.visible=true
  this.damaging=true
  this.dir=true
 end,
 update=function(this)
  this.timer+=1
  if this.timer%this.fire_rate==0 then
	  aim_bullet({x=this.x+4, y=this.y+4}, p1, 1)
	 end
  if this.typ==0 then
   --first miniboss
	  if this.timer==240 then
	   this.timer=0
	   side=not side
	   this.side_timer=1
	  end
	  if this.side_timer>0 then
	   this.side_timer+=1
	   this.x+=toint(this.side)*104/36
	   this.y=192+0.5*(9-((this.side_timer-18)/6)^2)
	   if this.side_timer==38 then
	    this.side_timer=0
	    this.x=156+toint(this.side)*52
	    this.side=not this.side
	    this.y=192
	   end
	  end
	 else
	  --second miniboss
	  if this.timer==180 then
	   this.timer=0
	   this.side=(this.side+1)%3
	   create_smoke(this.x+12, this.y+4, 3, 7)
	   this.x=664+36*this.side
	   this.y=456
	   if this.side==1 then
	    this.y=480
	   end
	  end
	 end
  if not this.vulnerable then
   this.invisi_timer+=1
   if this.invisi_timer%15==0 then
    this.visible=not this.visible
   end
   if this.invisi_timer==120 then
    this.visible=true
    this.vulnerable=true
    this.invisi_timer=0
    this.damaging=true
   end
  end
  if this.vulnerable and this.stomping then
   this.hits+=1
   sfx(1)
   p1.dy=p1.djump_speed
   p1.gliding=false
   create_smoke(this.x+8, this.y, 1, 7)
   this.vulnerable=false
   this.visible=false
   this.damaging=false
   if this.hits==3 then
    sfx(2)
    if this.typ==0 then
     mset(19,21,75)
     mset(20,21,74)
     mset(21,21,76)
     mset(20,20,77)
     init_object(key, 160, 152)
    else
	    mset(87,54,75)
	    mset(88,54,74)
	    mset(89,54,76)
	    mset(88,53,77)
     init_object(gold_heart, 704, 416)
    end
    del(objects, this)
   end
  end
 end,
 draw=function(this)
  if this.typ==0 and this.side_timer>0 then
   line(this.x+8,this.y+8,164,136,7)
  end
  palt(14, true)
  if this.visible then
   sspr(64+this.typ*16, 16, 16, 16, this.x, this.y, 16, 16, not this.dir)
  end
  palt()
 end,
 die=function(this)
  this.type.init(this)
 end,
}

teleporter = {
 tile=55,
 update=function(this)
  if this.check_player(0, 0) then
   sfx(2)
   shake=3
   p1.x=80
   p1.y=88
   camy=0
   camx=32
   del(objects, this)
  end
  if ticks2%20==0 then
   init_object(particle, this.x+4, this.y+4).c=10
  end
 end
}

key = {
 tile=82,
 init=function(this)
  this.timer=0
 end,
 update=function(this)
  if this.check_player(0, 0) then
   sfx(2)
   create_smoke(this.x+4,this.y,1,10)
   free_cam=true
   state+=1
   del(objects, this)
   smooth_camera=true
   if state==8 then --last key
    init_object(teleporter, 704, 416)
    for i=0,2 do
     for j=0,13 do
      mset(i,j,0)
     end
    end
   end
  end
  this.timer=(this.timer+1)%60
  if this.timer%15==0 then
   this.spr=82+(this.spr-81)%4
  end
  if this.timer==0 then
   this.dir=not this.dir
  end
 end
}

particle = {
 init=function(this)
  this.x+=rnd(2)-5
  this.y+=rnd(2)-1
  this.x_off=rnd(5)-2
  this.time_off=rnd(60)
  this.dy=0.1
  this.c=8
  this.timer=0
  this.lifetime=120
 end,
 update=function(this)
  this.x=this.ix+this.x_off+3*sin((ticks2+this.time_off)/60)
  this.y+=this.dy
  this.timer+=1
  if this.timer==this.lifetime then
   del(objects, this)
  end
 end,
 draw=function(this)
  rectfill(this.x,this.y,this.x,this.y,this.c)
 end,
 die=function(this)
  del(objects, this)
 end
}

smoke = {
 init=function(this)
  this.x+=rnd(2)-5
  this.y+=rnd(2)-1
  this.dx=rnd(0.8)-0.4
  this.dy=-0.1
  this.spr=16
 end,
 update=function(this)
  this.x+=this.dx
  this.y+=this.dy
  this.spr+=0.25
  if this.spr==19 then
   del(objects, this)
  end
 end,
 draw=function(this)
  pal(7, this.c)
  spr(this.spr, this.x, this.y)
  pal()
 end,
 die=function(this)
  del(objects, this)
 end
}

checkpoint = {
 tile=79,
 init=function(this)
  this.colliding=false
  this.dir=true
 end,
 update=function(this)
  if this.check_player(0, 0) then
   if not this.colliding then
    checkpoint_pos.x=this.x
    checkpoint_pos.y=this.y
    life=max_life
    sfx(3)
    this.colliding=true
    this.spr=80
   end
  else
   this.colliding=false
  end
  if this.spr~=79 then
   this.spr+=0.25
   if this.spr==82 then
    this.spr=79
   end
  end
 end,
 die=function(this)
  this.dir=true
 end
}
add(object_types, checkpoint)

lorm = {
 tile=19,
 stompable=true,
 damaging=true,
 bump=true,
 update=function(this)
  this.x+=0.2*toint(this.dir)
  local tile_ux=mget(flr((this.x+4+toint(this.dir)*4)/8),flr(this.y+8)/8)
  local o=this.collide(toint(this.dir),0)
  if not fget(tile_ux, 0) and not fget(tile_ux, 1) or o and o.type.bump then
   this.dir = not this.dir
  end
 end
}
add(object_types, lorm)

flit = {
 tile=20,
 stompable=true,
 damaging=true,
 init=function(this)
  this.timer=0
 end,
 update=function(this)
  this.dx+=(p1.x-this.x-4)*0.0008
  this.dy+=(p1.y-this.y-4)*0.001
  if abs(this.dx)>0.8 then
   this.dx=sgn(this.dx)*0.8
  end
  if abs(this.dy)>1 then
   this.dy=sgn(this.dy)*1
  end
  this.x+=this.dx
  this.y+=this.dy
  this.timer+=1
  this.spr=20+flr(this.timer%30/15)
 end
}
add(object_types, flit)

rakne = {
 tile=26,
 stompable=true,
 damaging=true,
 init=function(this)
  this.timer=0
  this.base=this.y
  for ny=this.y/8, this.y/8-10,-1 do
   if fget(mget(this.x/8,ny),0) then
    this.space=this.y-ny*8-8
    break
   end
  end
 end,
 update=function(this)
  this.timer=(this.timer+0.01)%1
  this.y=this.base+8*sin(this.timer)
 end,
 draw=function(this)
  pal(14,0)
  spr(26, this.x, this.y)
  pal()
  rectfill(this.x+3, this.y, this.x+4, this.base-this.space, 7)
 end
}
add(object_types, rakne)

hedge = {
 tile=22,
 damaging=true,
 bump=true,
 update=function(this)
  this.x+=0.2*toint(this.dir)
  local tile_ux=mget(flr((this.x+4+toint(this.dir)*4)/8),flr(this.y+8)/8)
  local o=this.collide(toint(this.dir),0) 
  if not fget(tile_ux, 0) and not fget(tile_ux, 1) or o and o.type.bump then
   this.dir = not this.dir
  end
  --this.spr=22+(ticks2%30)/15
 end,
}

shooter = {
 tile=24,
 stompable=true,
 damaging=true,
 bump=true,
 stare=true,
 init=function(this)
  this.timer=0
 end,
 update=function(this)
  this.timer+=1
  if this.timer==20 then
   this.spr=24
  elseif this.timer==60 and state~=6 then
   this.timer=0
   local b=init_object(bullet, this.x+2+2*toint(this.dir), this.y+3)
   b.velx=toint(this.dir)
   b.vely=0
   this.spr=25
  end
 end
}
add(object_types, shooter)

bullet = {
 tile=28,
 damaging=true,
 init=function(this)
  this.size=2
  this.vuln=true
  this.dir=true
 end,
 update=function(this)
  this.x+=this.velx
  this.y+=this.vely
  if ticks2%20==0 then
   init_object(particle, this.x, this.y).lifetime=30
  end
  if this.vuln then
   if fget(mget(this.x/8, this.y/8), 0) then
    create_smoke(this.x+4,this.y,1,7)
    del(objects, this) 
   end
  else
   this.damaging=this.can_damage
   if p1.y<camy+56 then
    this.damaging=false
   end
  end
 end,
 die=function(this)
  del(objects, this)
 end
}

function aim_bullet(o1,o2,spd)
	local b=init_object(bullet, o1.x+4, o1.y+2)
	local diffx=o2.x-o1.x
 local diffy=o2.y-o1.y
 local len=sqrt(diffx^2+diffy^2)
	diffx/=len
 diffy/=len
 b.velx=diffx*spd
 b.vely=diffy*spd
 return b
end

mole = {
 tile=27,
 stompable=true,
 damaging=true,
 stare=true,
 init=function(this)
  this.activated=false
 end,
 update=function(this)
  if this.y>p1.y-3 and this.y<p1.y+3 then
   this.activated=true
  end
  if this.activated then
   this.dx+=(p1.x-this.x-4)*0.0008
   if abs(this.dx)>0.8 then
    this.dx=sgn(this.dx)*0.8
   end
   local tile_ux=mget(flr((this.x+4+sgn(this.dx)*4)/8),flr(this.y+8)/8)
   if not fget(tile_ux, 0) and not fget(tile_ux, 1) then
    this.dx=0
   end
   this.x+=this.dx
   this.y+=this.dy
  end
 end,
 die=function(this)
  this.activated=false
 end
}
add(object_types, mole)

gold_heart = {
 tile=63,
 update=function(this)
  if this.check_player(0, 0) then
   max_life+=1
   life=max_life
   sfx(2)
   create_smoke(this.x+4,this.y,1,10)
   del(objects, this)
   if state==6 then
    free_cam=true
    state=7
    smooth_camera=true
    mset(14,62,75)
    mset(15,62,74)
    mset(16,62,76)
    mset(15,61,77)
    init_object(key, 120, 480)
   end
  end
  if ticks2%20==0 then
   init_object(particle, this.x+4, this.y+4).c=10
  end
 end,
 draw=function(this)
  local s=63
  s=63-(ticks2-14)/15
  if ticks2>=45 then
   s+=2
  end
  spr(s,this.x,this.y)
 end
}
add(object_types, gold_heart)

orb = {
 tile=11,
 init=function(this)
  if this.y==35*8 then
   this.c=8
  else
   this.c=9
  end
 end,
 update=function(this)
  if this.check_player(0,0) then
   sfx(2)
   create_smoke(this.x+4,this.y,1,this.c)
   shake=3
   if this.c==8 then
    double_unlocked=true
    create_text("double jump unlocked", this.x+4, this.y-10)
   else
    glide_unlocked=true
    create_text("air gliding unlocked", this.x+4, this.y-10)
   end
   del(objects, this)
  end
  if ticks2%20==0 then
   init_object(particle, this.x+4, this.y+4).c=this.c
  end
 end,
 draw=function(this)
  pal(8, this.c)
  spr(this.spr, this.x, this.y)
  pal()
 end
}
add(object_types, orb)

function init_object(type, x, y)
 local e={}
 e.type=type
 e.spr=type.tile
 e.x=x
 e.y=y
 e.ix=e.x
 e.iy=e.y
 e.dx=0
 e.dy=0
 e.dead=false
 e.size=8
 e.damaging=e.type.damaging

 e.check_player=function(ox,oy)
  if p1.x+8 >= e.x+ox and 
   p1.y+8 >= e.y+oy and
   p1.x <= e.x+8+ox and 
   p1.y <= e.y+8+oy then
   return true
  end
  return false
 end
 
 e.collide=function(ox,oy)
  for i in all(objects) do
  	if i.x+8 >= e.x+ox and
  	i.y+8 >= e.y+oy and
  	i.x <= e.x+8+ox and
  	i.y <= e.y+8+oy and
  	i ~= e and
  	not i.dead then
  	 return i
  	end
  end
  return nil
 end

 if e.type.init then
  e.type.init(e)
 end
 add(objects, e)

 return e
end

function update_objects()
	for e in all(objects) do
  e.stomping=false
		if on_screen(e.x,e.y,8,8) then
		 if not e.dead then
	   if p1.y+7<e.y and p1.y+8>e.y-4 and p1.x>=e.x-8 and p1.x<=e.x+e.size then
	    e.stomping=true
	    if e.type.stompable then
	   		e.dead=true
	   		p1.dy=p1.djump_speed
	   		p1.jumping=false
	   		p1.gliding=false
	   		create_smoke(e.x+4,e.y-4,2,7)
	   		sfx(1)
	    end
	   elseif e.damaging then
	  		if p1.x>=e.x-5 and p1.x<=e.x+e.size-3 then
	  			if p1.y>=e.y-4 and p1.y<=e.y+e.size-4 then
	  				if not p1.inv and not p1.damaging then
	   				life-=1
	   				p1.damaging=true
	  				end
	  			end
	  		end
	  	end
	  	if e.type.stare then
     e.dir=false
     if p1.x+4>e.x+e.size/2 then
      e.dir=true
     end
    end
	   e.type.update(e)
	  end
	 else
	  if e.type==text or e.type==bullet then
	   del(objects, e)
	  end
		end
	end
end

function draw_objects()
	for e in all(objects) do
		if on_screen(e.x,e.y,8,8) and not e.dead then
   if e.type.draw~=nil then
    e.type.draw(e)
   else
    pal(14,0)
			 spr(e.spr,e.x,e.y,1,1,not e.dir)
    pal()
   end
		end
	end
end

function create_text(t,x,y)
 local te=init_object(text, x-#t*2,y)
 te.timer=0
 te.t=t
end

text = {
 update=function(this)
  this.timer+=1
  if this.timer>120 then
   del(objects, this)
  end
 end,
 draw=function(this)
  print(this.t, this.x, this.y, 7)
 end
}

function die()
 life=max_life
 deaths+=1
 p1.x=checkpoint_pos.x
 p1.y=checkpoint_pos.y
 p1.dx=0
 p1.dy=0
 p1.flipx=false
 p1.dam_timer=0
 p1.p_timer=0
 smooth_camera=false
 update_cam()
 camy=flr((p1.y+8)/128)*128
 for e in all(objects) do
  e.dead=false
  e.x=e.ix
  e.y=e.iy
  e.dir=false
  e.dx=0
  e.dy=0
  if e.type.die~=nil then
   e.type.die(e)
  end
 end
end

function collide_side(self)
 if normal_collision then
	 local offset=8/3
	 for i=-(8/3),(8/3),2 do
	  if self.dx>0 then
	   if fget(mget((self.x+4+(offset))/8,(self.y+4+i)/8),0) then
	    self.dx=0
	    self.x=(flr(((self.x+(offset))/8))*8)-(offset)+4
	    return true
	   end
	  elseif self.dx<0 then
	   if fget(mget((self.x+4-(offset)-1)/8,(self.y+4+i)/8),0) then
	    self.dx=0
	    self.x=(flr((self.x-(offset)-1)/8)*8)+8+(offset)-3
	    return true
	   end
	  end
	 end
 end
end

function collide_side2(self)
 if normal_collision then
	 local offset=self.w/3
	 for i=-(self.w/3),(self.w/3),2 do
	  if true then
	   if fget(mget((self.x+(offset)+6)/8,(self.y+4+i)/8),0) then
	    collided_side2=false
	    return true
	   end
	  end
	  if true then
	   if fget(mget((self.x-(offset)+1)/8,(self.y+4+i)/8),0) then
	    collided_side2=true
	    return true
	   end
	  end
	  return false
	 end
	 return false
 end
end

function collide_floor(self)
 if self.dy<0 then
  return false
 end
 if normal_collision then
	 local landed=false
	 for i=-(8/3),(8/3),2 do
	  local tile=mget((self.x+4+i)/8,(self.y+8)/8)
	  if fget(tile,0) or (fget(tile,1) and self.y%8<4) then
	   self.dy=0
	   self.y=(flr((self.y)/8)*8)
	   self.airtime=0
	   landed=true
	  end
	 end
	 return landed
	else
	 if p1.y>104 then
	  self.y=104
	  self.dy=0
	  self.airtime=0
	  self.landed=true
	  return true
	 end
	 return false
 end
end

function collide_roof(self)
 if normal_collision then
	 for i=-(8/3),(8/3),2 do
	  if fget(mget((self.x+4+i)/8,(self.y)/8),0) then
	   self.dy=0
	   self.y=flr((self.y-(self.h/2))/8)*8+8
	   self.jump_hold_time=0
	  end
	 end
	 if self.y<-4 then
	  self.dy=0
	  self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
	  self.jump_hold_time=0
	 end
	else
	 if self.y<0 then
	  self.y=0
	  self.dy=0
	  self.jump_hold_time=0
	 end
 end
end

function general_collision(self)
 local x=self.x-4
 local y=self.y-4
  
 local blocks={}
 blocks[1]={flr((x+10)/8), flr((y+12)/8)}
 blocks[2]={flr((x+5)/8), flr((y+12)/8)}
 blocks[3]={flr((x+10)/8), flr((y+4)/8)}
 blocks[4]={flr((x+5)/8), flr((y+4)/8)}
  
 foreach(blocks, function(b)
  local tile=mget(b[1], b[2])
   
  if tile==78 and (y+4)/8%1>0.5 and p1.dy>0 and normal_collision then
   die()
  end
 end)
end

function m_player(x,y)

	local p=
	{
		x=x,
		y=y,

		dx=0,
		dy=0,

		w=8,
		h=8,
		
		spdx=1.2,
  run_spdx=1.35,
		max_fall_spd=2,

  p_spdx=1.5,
  p_timer=0,
  p_time=180,
  p_time_air=30,
  p_extra_time=60,
  p_timer_wait=0,

		jump_speed=-2.5,
		acc=0.05,
		turn_acc=0.06,
		dcc=0.2,
		air_dcc=0.05,
		grav=0.1,
		fall_grav=0.2,
		jumping=false,
		double_jump=true,
		can_double=true,
		djump_speed=-3.5,
		
  collide_wall_start=false,
		wall_sliding=false,
		wall_dcc=0.1,
		wall_grav=0.01,
		wall_spdx=1.6,
		wall_spdy=-4,
		wall_time=0,
		can_wall_time=10,
		max_wall_fall=1,
		
		gliding=false,
		glide_grav=0.05,
		glide_max_fall=0.45,
		
		inv=false,
		inv_timer=0,
		inv_time=60,
		blink_time=20,
		
		damaging=false,
		dam_timer=0,
		dam_time=10,
		
		jump_button=
		{
			update=function(self)
 			self.pressed=false
 			if btn(4) and not cutscene then
 				if self.ticks_down<5 then
 					self.pressed=true
 				end
 				self.is_down=true
 				self.ticks_down+=1
 			else
 				self.is_down=false
 				self.pressed=false
 				self.ticks_down=0
 			end
			end,
			stop_pressing=function(self)
				self.pressed=false
				self.ticks_down=5
			end,
			
			is_pressed=false,
			is_down=false,
			ticks_down=0,
		},

		jump_btn_released=true,
		grounded=true,

		airtime=0,
		
		anims=
		{
			["stand"]=
			{
				ticks=1,
				frames={2},
			},
			["walk"]=
			{
    walk=true,
				ticks=8,
				frames={3,4,5,6},
			},
   ["run"]=
   {
    walk=true,
    ticks=4,
    frames={3,4,5,6},
   },
   ["prun"]=
   {
    walk=true,
    ticks=2,
    frames={3,6},
   },
			["jump"]=
			{
				ticks=1,
				frames={1},
			},
			["slide"]=
			{
				ticks=1,
				frames={7},
			},
			["wall"]=
			{
				ticks=1,
				frames={8},
			},
			["glide"]=
			{
				ticks=1,
				frames={9},
			},
		},

		curanim="walk",
		curframe=1,
		animtick=0,
		flipx=false,
		
		set_anim=function(self,anim)
			if(anim==self.curanim)return
			local a=self.anims[anim]
			self.animtick=a.ticks
			self.curanim=anim
			self.curframe=1
		end,
		
		update=function(self)
			general_collision(self)
			
   local bl=false
   local br=false
   if not cutscene then
			 bl=btn(0)
			 br=btn(1)
   end
			
			local desired = 0
			
  	if bl then
  		desired = -1
  		br=false
  	elseif br then
  		desired = 1
  		bl=false
  	end
			
			local can_slide=true
			local running=false
   local hor_spd=self.spdx
   if not cutscene then
	   if btn(5) and abs(self.dx)>=self.spdx*0.5 then
	    running=true
	    hor_spd=self.run_spdx
	    if self.p_timer >= self.p_time then
	     hor_spd=self.p_spdx
	    end
	    if self.grounded then
		    self.p_timer=min(self.p_timer+1, self.p_time)
		    if self.p_timer >= self.p_time then
		     self.p_timer=self.p_time+self.p_extra_time
		     self:set_anim("prun")
		    else
		     self:set_anim("run")
		    end
	    elseif self.p_timer_wait==0 then
	     self.p_timer-=1
	    else
	     self.p_timer_wait-=1
	    end
	   else
	    self.p_timer-=1
	   end
	  end

   if self.curanim=="prun" and ticks2%10==0 then
    create_smoke(self.x+4-4*sgn(self.dx),self.y+4,1,7)
   end

			desired *= hor_spd
			
			if desired ~= 0 then
				if not self.wall_sliding then
   		if sgn(self.dx) ~= sgn(desired) then
   			self.dx += (desired-self.dx)*self.turn_acc
   		else
   			self.dx += (desired-self.dx)*self.acc
   		end
   	elseif sgn(desired)==toint(self.flipx) then
   		self.wall_time+=1
   		if self.wall_time>=self.can_wall_time then
   			self.wall_time=0
   			can_slide=false
   			self.wall_sliding=false
   		end
   	else
   		self.wall_time=0
   	end
 		else
 				if self.wall_sliding then
 					self.wall_time+=1
   			if self.wall_time>=self.can_wall_time then
   				self.wall_time=0
   				can_slide=false
   				self.wall_sliding=false
   			end
 				else
   			if self.grounded then
  					self.dx += (desired-self.dx)*self.dcc
  				else
  					self.dx += (desired-self.dx)*self.air_dcc
  				end
 				end
 		end

			self.x+=self.dx
			
			self.x=mid(camx,self.x,camx+120)
			
			collide_side(self)
			
 		if collide_side2(self) and can_slide then
 			test=true
 			if -sign(desired) == toint(collided_side2) then
 				self.collide_wall_start=true
 			else
 				self.collide_wall_start=false
 			end
 		else
 		 test=false
 			self.collide_wall_start=false
 			self.wall_sliding=false
 		end
			
			self.jump_button:update()
			
			if self.jump_button.pressed then
				local on_ground=(self.grounded or self.airtime<5)
				if on_ground then
					self.dy=self.jump_speed
     self.p_timer_wait=self.p_time_air
					self.jumping = true
					self.jump_button:stop_pressing()
					sfx(0)
					create_smoke(self.x+4,self.y+4,1,7)
				else
					if self.wall_sliding then
						self.dx=-self.wall_spdx
      self.p_timer_wait=self.p_time_air
						if collided_side2 then
							self.dx=self.wall_spdx
						end
						self.dy=self.wall_spdy
						self.jump_button:stop_pressing()
						self.wall_sliding=false
						sfx(0)
						create_smoke(self.x+4-2*toint(self.flipx),self.y-4,1,7)
					elseif self.double_jump and self.can_double and double_unlocked then
						self.dy = self.djump_speed
						self.can_double=false
						self.jump_button:stop_pressing()
						sfx(0)
     elseif test then
       self.dx=-self.wall_spdx
      self.p_timer_wait=self.p_time_air
      if collided_side2 then
       self.dx=self.wall_spdx
      end
      self.dy=self.wall_spdy
      self.jump_button:stop_pressing()
      self.wall_sliding=false
      sfx(0)
      create_smoke(self.x+4-2*toint(self.flipx),self.y-4,1,7)
					end
				end
			end

			if not self.jump_button.is_down then
				self.jumping = false
				self.gliding = false
			end

			if not self.gliding then
				if self.wall_sliding then
					if self.dy > self.max_wall_fall then
   			self.dy = self.max_wall_fall
   		end
   	end
  	else
  		if self.dy > self.glide_max_fall then
  			self.dy = self.glide_max_fall
  		end
 		end
			self.y+=self.dy
			
			if not collide_floor(self) then
				if self.collide_wall_start or self.wall_sliding then
					self:set_anim("wall")
					self.wall_sliding=true
					self.gliding=false
					self.flipx=collided_side2
				elseif self.gliding then
					self:set_anim("glide")
				else
					self:set_anim("jump")
				end
				self.grounded=false
				self.airtime+=1
   else
    self.grounded=true
    self.can_double=true
    self.gliding=false
    self.can_glide=true
    if br then
     if self.dx<0 then
      self:set_anim("slide")
     else
      if not self.anims[self.curanim].walk or not running then
       self:set_anim("walk")
      end
     end
    elseif bl then
     if self.dx>0 then
      self:set_anim("slide")
     else
      if not self.anims[self.curanim].walk or not running then
       self:set_anim("walk")
      end
     end
    else
     self:set_anim("stand")
    end
			end

			collide_roof(self)
			
			self.y=mid(0,self.y,64*8-4)
			
   if not self.wall_sliding then
    if self.dy > 0 then
     if self.jump_button.is_down and glide_unlocked then
      self.gliding=true
     end
     if not self.gliding then
      self.dy+=self.fall_grav
     end
     self.jumping=false
    elseif not self.jumping then
     if not self.gliding then
      self.dy+=self.fall_grav
     end
     self.jumping=false
    end
    if self.gliding then
     self.dy+=self.glide_grav
    else
     self.dy+=self.grav
     if self.dy > self.max_fall_spd then
      self.dy = self.max_fall_spd
     end
    end
    if br then
     self.flipx=false
    elseif bl then
     self.flipx=true
    end
   else
    if self.dy < -0.05 then
     self.dy += (-self.dy)*self.wall_dcc
    else
     self.dy+=self.wall_grav
    end
   end
			
			if self.inv then
				self.inv_timer+=1
				if self.inv_timer>=self.inv_time then
					self.inv=false
				end
			end
			
			if self.damaging then
				self.dam_timer+=1
				if self.dam_timer==1 then
					self.dy=-2
					self.dx=toint(self.flipx)*self.spdx
				end
				if self.dam_timer>self.dam_time then
					self.damaging=false
					self.dam_timer=0
					self.inv=true
					self.inv_timer=0
				end
			end
			
			if life<=0 then
				die()
				self.inv=false
				self.inv_timer=0
				self.damaging=false
			end
			
			self.animtick-=1
			if self.animtick<=0 then
				self.curframe+=1
				local a=self.anims[self.curanim]
				self.animtick=a.ticks
				if self.curframe>#a.frames then
					self.curframe=1
				end
			end
		end,

		draw=function(self)
			pal(14,0)
			local a=self.anims[self.curanim]
			local frame=a.frames[self.curframe]
			if self.inv then
				if flr(self.inv_timer/self.blink_time)%2==0 then
  			frame=-1
 			end
 		else
 			if self.damaging then
 				frame=10
 			end
			end
   spr(frame,
    self.x,
    self.y,
    1,1,
    self.flipx,
    false)
			pal()
			
			--draw life
			for i=1,max_life do
				if life>=i then
					pal(10, 8)
				else
					pal(10, 0)
				end
				spr(63,camx-8+10*i,camy+2)
				pal()
			end

   --draw p-speed bar
   self.p_timer=max(self.p_timer, 0)
   if show_timer then
	   camera(0,0)
	   rectfill(1, 120, 16, 126, 7)
	   rectfill(2, 121, 2+13*min(self.p_timer, self.p_time)/self.p_time, 125, 6)
	   camera(camx, camy)
   end
		end,
	}

	return p
end

function update_cam()
 if free_cam then
  local desired_posx=camx
		if p1.x > camx+128-h_threshold then
			desired_posx = p1.x+h_threshold-128
		end
		if p1.x < camx+h_threshold then
			desired_posx = p1.x-h_threshold
		end
		if smooth_camera then
		 camx += (desired_posx-camx)*0.3
		 if abs(camx-desired_posx)<1 then
		  smooth_camera=false
		 end
		else
		 camx = desired_posx
		end
		
		camx=mid(0, camx, 112*8)
		
		if (camx==0 or camx==112*8) and not (camx==0 and camy<16) then
			local desired_posy=camy
			if p1.y > camy+128-v_threshold then
				desired_posy = p1.y+v_threshold-128
			end
			if p1.y < camy+v_threshold then
				desired_posy = p1.y-v_threshold
			end
			if abs(flr((p1.y+8)/128)*128-desired_posy)<=16 then
			 desired_posy=flr((p1.y+8)/128)*128
			end
			camy+=(desired_posy-camy)*0.1
		end
		
		camy=mid(0, camy, 48*8)
	end
end

function update_events()
 if dialog_active then
  dialog_timer+=1
  if dialog_timer==4 then
   dialog_current=sub(dialog_used[dialog_window], 1, #dialog_current+1)
   dialog_timer=0
  end
  if btn(4) and not jump_last then
   if dialog_current==dialog_used[dialog_window] then
    if dialog_window==#dialog_used then
     dialog_active=false
     dialog_timer=0
     dialog_window=1
     dialog_current=""
     p1.jump_button.ticks_down=5
     cutscene=false
     if state==2 then
      free_cam=true
      trigger_descent()
      music(6,500)
      mset(17,13,75)
      mset(18,13,74)
      mset(19,13,76)
      mset(18,12,77)
      init_object(gold_heart, 144, 88)
      init_object(gold_heart, 560, 344)
     elseif state==0 then
      state=1
      init_object(unnamed, 32, 104)
      music(11,500)
      mset(4,13,0)
      free_cam=false
      checkpoint_pos.x=40
      checkpoint_pos.y=104
     elseif state==9 then
      state=10
      music(2,500)
      checkpoint_pos.x=80
      checkpoint_pos.y=104
      num=init_object(numenas, 60, 16)
     elseif state==12 then
      del(objects, cut_un)
      music(13,500)
      create_smoke(116,104,2,8)
     elseif state==14 then
      state=15
     end
    else
     dialog_window+=1
     dialog_current=""
    end
   else
    dialog_current=dialog_used[dialog_window]
   end
  end
 else
  if camx==0 and camy<16 and state==0 then
   dialog_active=true
   camy=0
   p1.dx=0
   dialog_used=first_dialog
   stop_music()
   cutscene=true
  end
  if state==2 then
   dialog_active=true
   dialog_used=second_dialog
   cutscene=true
   stop_music()
  end
 end
 jump_last=btn(4)
 if state==3 then
  if camx<100 and camy>100 then
   free_cam=false
   camx=100
   state=4
   checkpoint_pos.x=160
   checkpoint_pos.y=168
   life=max_life
   mset(13,24,0)
   mset(14,24,0)
   mset(13,25,0)
   mset(14,25,0)
   local c=init_object(miniboss, 104, 192)
   c.typ=0
   miniboss.init(c)
  end
 elseif state==5 then
  if camx<=644 and camy>300 then
   free_cam=false
   camx=644
   state=6
   checkpoint_pos.x=704
   checkpoint_pos.y=432
   life=max_life
   mset(83, 57, 0)
   mset(84, 57, 0)
   mset(83, 58, 0)
   mset(84, 58, 0)
   local c=init_object(miniboss, 664, 456)
   c.typ=1
   miniboss.init(c)
  end
 elseif state==8 then
  if p1.x==0 and camy<16 then
   stop_music()
   state=9
   normal_collision=false
   camx=0
   camy=0
   p1.x=120
   p1.y=104
   cutscene=true
   dialog_active=true
   dialog_used=numenas_dialog
   for o in all(objects) do
    if o.type~=checkpoint then
     del(objects, o)
    end
   end
  end
 elseif state==11 then
  state=12
  normal_collision=true
  cutscene=true
  dialog_active=true
  dialog_used=last_dialog
 elseif state==12 then
  if p1.x==120 then
   p1.x=0
   state=13
   life=max_life
   del(objects,num)
  end
 elseif state==13 then
  if p1.x==0 and camy>360 then
   state=14
   cutscene=true
   dialog_active=true
   dialog_used={"you escaped this time.", "but i'll get you next\ntime."}
   stop_music()
  end
 end
end

function draw_dialog()
 camera(0,0)
 if dialog_active then
  rectfill(4, 10, 124, 43, 0)
  rect(4, 10, 124, 43, 7)
  local face=(dialog_window-1)%2*dialog_chara
  if state==12 then
   face=last_indixes[dialog_window]
  elseif state==14 then
   face=1
  end
  sspr(face*16, 16, 16, 16, 5, 11, 32, 32)
  print(dialog_current, 36, 12)
 end
 camera(camx, camy)
end

function init()
	music(0, 500)
	for x=1,128 do
		for y=1,64 do
			if mget(x,y)==2 then --player
				p1=m_player((x*8)+4,(y*8)+4)
				mset(x,y,0)
				checkpoint_pos.x=x*8+4
				checkpoint_pos.y=y*8+4
				org_x=x*8
				org_y=y*8
    p1:set_anim("walk")
    p1.jump_button.ticks_down=5
			elseif fget(mget(x,y),2) then --objects
    foreach(object_types, function(type)
     if type.tile==mget(x,y) then
      init_object(type, x*8, y*8)
     end
    end)
				mset(x,y,0)
			end
		end
	end
	music(4)
	state=0
end

function _init()
 state=-2
 deaths=0
 ticks=0
 ticks2=0
 life=1
 max_life=1
 music(8)
end

function _update60()
 if state>=0 and state<14 then
	 if not cutscene then
	  ticks2+=1
	 end
	 if ticks2==60 then
	  ticks+=1
	  ticks2=0
	 end
	 p1:update()
	 update_objects()
	 if not dialog_active and (state<9 or state>12) then
	  update_cam()
	 end
	 if state==13 then
	  if ticks%3==0 then
	   shake=2
	  end
	  --angry code
	  if ticks2==0 then
	   local b=aim_bullet({x=camx+16+rnd(96),y=camy},p1,1)
	   b.vuln=false
	   b.velx+=p1.dx/2
	   b.can_damage=true
	  end
	  if ticks2==30 then
	   b=aim_bullet({x=camx+16+rnd(96),y=camy},{x=camx+16+rnd(96),y=p1.y},1)
	   b.vuln=false
	   b.can_damage=false
	  end
	 end
 elseif state==-2 then
  if btnp(4) then
   state=-1
   stop_music()
   show_timer=btn(2)
  end
 elseif state==-1 then
  if btnp(4) then
   init()
   sfx(2)
  end
 end
 update_events()
end

function _draw()

	cls()
	camera(0,0)
 
 local minutes=tostr(flr(ticks/60))
	local seconds=ticks%60
	if seconds<10 then
	 seconds="0"..tostr(seconds)
	else
	 seconds=tostr(seconds)
	end
 if state>=0 and state<14 then
	 local offset=flr((camy-camy%4)/4)%2*2
		for y=camy-camy%4, camy-camy%4+128, 4 do
		 for x=64+0.9*camx, 96+0.9*camx, 4 do
		  rectfill(x+offset-camx, y-camy, x+offset+2-camx, y-camy+2, 2)
		 end
		 offset=2-offset
	 end
	 
	 if shake>0 then
	  if ticks2%5==0 then
		  shake-=1
	  	camx_off=-1+rnd(3)
	  	camy_off=-1+rnd(3)
	  end
	  camera(camx+camx_off,camy+camy_off)
	 else
	  camera(camx, camy)
	 end
	 
	 palt(0,false)
	 palt(14,true)
	 if state<9 or state>12 then
	  map(0,0,0,0,128,128)
	 else
	  for i=0,15 do
	   spr(69, i*8, 112)
	   spr(73, i*8, 120)
	  end
	 end
	 palt()
	 
	 draw_objects()
	 p1:draw()
	 
	 if show_timer then
	  local t=minutes..":"..seconds
	 	rect(camx+103,camy,camx+104+4*#t+3,camy+8,7)
	 	rectfill(camx+104,camy+1,camx+104+4*#t+2,camy+7,0)
	 	print(t,camx+106,camy+2,7)
	 end
	elseif state==15 then
 	local tenths=flr(ticks2/60*100)
 	if tenths<10 then
 		tenths="0"..tostr(tenths)
 	else
 		tenths=tostr(tenths)
 	end
 	print("the end", 50, 0)
 	print("time: "..minutes..":"..seconds.."."..tenths, 0, 16)
 	print("deaths: "..deaths, 0, 24)
 elseif state==-2 then
  palt(0,false)
  palt(14,true)
  map(29,48,0,0,128,128)
  palt()
  print("dungeon of numenas 2", 22, 16, 7)
  print("by amegpo", 46, 111)
  print("press c to start", 32, 96)
 elseif state==-1 then
  print("after defeating numenas, numenas\nwent into hiding in his castle,\nbut you had to find him, and so\nyou followed him into the\ncastle for one last showdown",0,0,7)
 end
 draw_dialog()
end
__gfx__
00000000004444000000000000000000000000000000000000000000000000000044400000444400000000000000000000888800000000000011100000000000
00000000044f4f0000444400000444400004444000044440000444400444400004f4f400044f4f400000000000077000088887800888800000aaaa0001110000
00700700f4fefef0044f4f400044f4f40044f4f40044f4f40044f4f444f4f40000efe4f004fefe000444400000788700088e7e8088887800011111100aaaa000
000770000cffff0004fefe00004fefe0004fefe0004fefe0004fefe04fefe00000fff00000ffff0044f4f400078888700887770088e7e80006fefe0011111100
0007700000ccc00000ffff00000ffff0000ffff0000ffff0000ffff000fff000000ccc0091cccc004fefe00007888870087770008877700000f666006fefe000
007007000099100000ccc0000fcccc000fcccc000fcccc000fcccc000fcc000000011c90001cccf000fff0000078870000aaa00087777000001166000f666000
00000000000110000f111f0009111000001990000011100000111000991100000000110001100c0000ccc990000770000799970000aaadd001111f0000166100
000000000000990009909900009099000099000009909900009900000990000000000090900000f000f111900000000005505500007999d01111110000f11110
00000000000000007000000000088888000000000000000000949000009490000088880000888800088888800009990088000000880000000000000000000000
0070000007700700070000070088aaa800888800008888000444440004444400088333800883338008e88e800099999088000000880000000000000000000000
007770000777000000000000008aeae88882288800822800049494400494944008333e8008333e3088eeee880099999900000000000000000000000000000000
077777700770000000000000008aaaa8828228280882288094444f9094444f9008333330083333308eeeeee80099990000000000000000000000000000000000
077777700000700000000000008aaaa8822222288822228844449ff044449ff0083333300833333088eeee880099977000000000000000000000000000000000
0077770000000770000000000888aa8888222288822222289494ffff9494ffff88833880888338308eeeeee80099777000000000000000000000000000000000
00007700000707700700007008aaa88008822880828228284ffffff04ffffff08333880083338800888ee8880099777000000000000000000000000000000000
0000000000000000000000000888880000888800888888880df0df000df0df008888800088888000008888000999999000000000000000000000000000000000
0000000000000000000000000000000000001111111100004444444744477444eeeeeeeeeeeeeeeeeeeeeeee33eeeeee00088880000888800008888000088880
00000000000000000000888888880000000aaaaaaaaaa0004444444744777744eeeeeeeeeeeeeeeeeeeeeee3333eeeee00888878008888780088887800888878
0004444444440000000888888888800000aaaaaaaaaaaa004444444747777774eeeeeeeeeeeeeeeeeeeeee333333eeee0088e7e80088e7e80088e7e80088e7e8
0044444444444000000888888888880000111111111111004444444747777774eeeeee5555eeeeeeeeee3333333333ee00887770008877700088777000887770
00444f4f44f44400008888888788880001111111111111104444444744777744eeeee555555eeeeeeeeee44fffff4eee00877700008777000087770000877700
0444fffff4ff4400008888878778880000666fffffff66004444444744477444eeee55855855eeeeeeeee4ffbffb4eee07aaaa0007aaaa0007aaaa0007aaaa00
0444fffffffff400088888808708880000066f00ff00f6004444444744777744eee5555555555eeeeeeee4ffffffeeee05999000009550000099900000999000
044fff00ff00f000088887807700880000066f00ff00f0004444444747777774eee5585885855eeeeeeeeef44444eeee00505500005500000550550000550000
044fff00ff00f000088887877777880000006ffffffff0004444444400000000eee5555555555eeeeeeeeeef4444eeee00000000000770000070070000700700
004ffffffffff00000887787777778000000ff666666f0004444444400077000eee5558558555eeeeeeeeee33444eeee00000000000770000077770007a77a70
004ffffffffff00000887777777708000000ff666666000044444444007aa700ee555555555555eeeeeeee3f3443feee000000000007700007aaaa707aaaaaa7
0004ffffffff0000000877777777080000000ff6666600004444444407aaaa70e5ee55588555ee5eeeeeee3f3343feee000000000007700007aaaa707aaaaaa7
0000cccccccc0000000877777770000000001111666600004444444407aaaa70e5ee5e5555e5ee5eeeeee3333333eeee000000000007700007aaaa707aaaaaa7
000cccccccccc0000088aaaaaaaa0000000111111666100044444444007aa700e5ee5e5ee5e5ee5eeeeee3333333eeee0000000000077000007aa70007aaaa70
000cccccccccc000008aaaaaaaaaa000000111111166100044444444000770005ee5ee5ee5ee5ee5eeee33333333eeee0000000000077000007aa700007aa700
00cccccccccccc00008aaaaaaaaaa000001111111111110044444444000000005ee5ee5ee5ee5ee5ee33333333333eee00000000000770000007700000077000
40404040e77777777777777e5550555775505550777777775550555755505550755055505550555066606660eee7777777777eeee777777eeeeeeeee0000c000
4040404075505550555055575550555775505550555055505550555755505550755055505550555066606660eee7666066607eee76606667eeeeeeee0ddcc0c0
0404040475505550555055575550555775505550555055505550555755505550755055505550555066606660eee7666066607eee76606667eeeeeeee0ddcccc0
eeeeeeee70000000000000070000000770000000000000000000000700000000700000000000000000000000777700000000077770000007eeeeeeee0ddc1cc0
eeeeeeee70555055505550575055505770555055505550555055505750555055705550555055505560666066706660666066606770666067eeeeeeee0dd10c10
eeeeeeee70555055505550575055505770555055505550555055505750555055705550555055505560666066706660666066606770666067e7e7e7e70dd00100
eeeeeeee70555055505550575055505770555055505550555055505750555055705550555055505560666066706660666066606770666067575757570dd00000
eeeeeeee70000000000000077777777ee7777777000000000000000777777777700000000000000000000000700000000000000770000007777777770dd00000
000000000000000c0000000000000000000000000000000076606660666066676660666776606660000000000000000000000000000000000000000000000000
0ddc0c000ddc00ccaaa900000aa900000000a00000009aa076606660666066676660666776606660000000000000000000000000000000000000000000000000
0ddccc000ddccccca09a00000a0a00000000a0000000a0a076606660666066676660666776606660000000000000000000000000000000000000000000000000
0ddcccc00ddcccc1a00aaaaa0a0aaaa00000a0000aaaa0a070000000000000070000000770000000000000000000000000000000000000000000000000000000
0dd1c1c00dd1cc10a09a099a0a0a09a00000a0000a90a0a070666066606660676066777777776066000000000000000000000000000000000000000000000000
0dd010c00dd01100aaa9090a0aa909a00000a0000a909aa0706660666066606760667eeeeee76066000000000000000000000000000000000000000000000000
0dd000100dd0000000000000000000000000000000000000706660666066606760667eeeeee76066000000000000000000000000000000000000000000000000
0dd000000dd0000000000000000000000000000000000000700000000000000777777eeeeee77777000000000000000000000000000000000000000000000000
00000000000000007770707077707770777077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770707070007000070070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004444444400007070707077007700070070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044404444440007070707070007000070070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044444440440007070077070007000777070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00440044444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00440044444444000770777077000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444444044004407000707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404444444400440700077707070700000000000000000000000000000000000e000000eeeeeeeee5ee5ee5ee00000000000000eeeeeeeeeeeeeeeee00000000
0144c44c44144c10707070707070707000000000000000000000000000000000ee1110eeeeeeeeee55e6eeeeee111011101111eeeeeeeee11eeeeeee10111011
01ccc1cccc1ccc10777070707070777000000000000000000000000000000000eee11eeeeeeeeeee6e55eeeeeee1101110111eeeeeeeee1110eeeeee10111011
001cc1cccc1cc100000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee6ee5eeeeeeee10111011eeeeeeeee011101eeeee10111011
001cc1cccc1cc100000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeee6eeeeeeeee000000eeeeeeeee00000000eeee00000000
001ccc1cc1ccc100000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeee6eeeeeeeeee1011eeeeeeeee0111011101eee11101110
0001cc1cc1cc1000000000000000000000000000000000000000000000000000eeeeeeeeee5eeeeeeee6eeeeeeeeeee01eeeeeeeee101110111011ee11101110
0001cc1cc1cc1000000000000000000000000000000000000000000000000000eeeeeeeee55ee5eeeeeeeeeeeeeeeeeeeeeeeeeee11011101110111e11101110
6400b7f7849474747474747474747474747474749494949494747474747474747474747474747474747474747474747474747474747474747494947474747474
74747474747474747474747474747474747474747474747474749494947474747474747474747474747474747474747474747474747494949494949494949494
640000b78464f7f7c700000000a7000000b7f7f78494949464f7f7f7c700a70000000000b7f7f7f7f7c700000000000000a7000000b7f7f7f78464f7f7f7f7c7
00000000000000a700000000000000000000000000a7000000b7447434f7c70000000000a7000000b7f7f7f7f7f7f7c700000000b7f784949494949494949494
640000048464f7c700000000000000000000b7f78494949464f7f7c7000000000000000000b7f7f7c700000000000000000000000000b7f7f78464f7f7f7c700
0000000000000000000000000000000000000000000000000000b7f7f7c70000000000000000000000b7f7f7f7f7c7000000000000b784949494949494949494
640000008464c7000000000000000000000000b78494949464f7c70000000000000000000000b7c700000000000000000000b000000000b7f78464f7f7c70000
000000000000000000000000000000000000000000000000000000b7c700000000000000000000000000b7f7f7c7000000000000000044747474747474747494
64000000846400000000000000000000000000008494949464c7000000000000000000000000000000000000000000000000d40000000000b78464f7c7000000
00000000000000000000000000000041000000000000000000000000000000000000000000000000000000b7c7000000000000000000000000a7000000b7f784
64000000846400000000000000000000000000008494949464000000000000000000000000000000000000000000000000b4a4c400000000008464c700000000
00000000000000000000000000000000000031009700000000000000000000000000000000000000000000000000000000000000000000f4000000000000b784
64000004443400000000000000000000000000008494949464000000000000000000000000000000000000000000000004040404040000000044340000000000
00000000000000000000000000000000001454545424040404041454240000000000000000000000000000000000000000000000000000142400000000000084
3400000000a7000000000000000000000000000044747474340000000000000000000000000000000000000000000000000000000000000000a7000000000000
00000000000000000000000000000000008494949464000000008494640000000000000000000000000000000000000000000000000000846404040404000084
0000000000000000000000000000000000000000000000a7000000000000f4970000000000000000000000000000000000000031000000000000000000000000
00000000000000000000000000000000008494949464000000004474340000000000000000000000000000000000000000000000000000846400000000000084
000000410000d7e70000410000000000000000000000000000000000001454240000000000000000000000000000004100000004040400000000000000000000
00000000000000000000000000000000d78494949464000000000000000000000000000000000000000000000000000000000000000000846400000000000084
0000000000d7f7f7e70000000000000000000000000000000000000000849464000000000000000000000000000004040400000000d7e7000000000000000000
000000000000000000000000000000d7f78494949464e70000000041000000000000000000000000000004040404040404040404040404846400000000000084
e7310097d7f7f7f7f7e700d7e7000000000000000000a10000000000008494640000000000000000000000000000000000000000d7f7f7e70000000000000000
000000000000f300000000000000d714549494949464f7e7000000000000000000000000000000000000000000000000000000000000d7846404040404000084
545454545454545454545424c70000d7e70000000000000000000000d7849464e7000000000000000000000000000000000000d7f7f7f7f7e700000000000000
000000000000d4000000000000d7f784949494949464f7f7e7000000d7e7000000000000d7e7000000000000000000000000000000d7f78464e7000000000084
9494949494949494949494643100d7f7f7e7970000000000000000d7f7849464f7e700000000000000000000000097000000d7f7f7f7f7f7f7e7000000970000
00f4000000b4a4c400009700d7f7f7849494949494945454545454545424e731000000d7f7f7e700970000000000000000000000d7f7f78464f7e70000000084
94949494949494949494949454545454545424e4e4e4e4e4e4e41454549494945424e4e4e4e4e4e4e4e4e4145454545454545454545454545454545454545454
545454545454545454545454545454949494949494949494949494949494545454545454545454545424e4e4e4e4e4e4e4e4e4145454549464f7f7e700000084
94949494949494949494949494949494949494545454545454549494949494949494545454545454545454949494949494949494949494949494949494949494
94949494949494949494949494949494949494949494949494949494949494949494949494949494949454545454545454545494949494949454542404000084
74747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474
74747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474749494946400000084
f7f7f7f7c70000000000a70000000000b7f7f7f7f7c700a700000000000000000000a7000000000000b7f7f7f7f7f7f7f7f7f7f7c7000000000000a7000000b7
f7f7f7f7f7f7f7f7c700000000a700000000000000b7f7f7f7f7f7c70000000000000000b7f7f7f7f7c7000000a7000000b7f7f7f7f7f7f78494946400000084
f7f7f7c700000000000000000000000000b7f7f7c7000000000000000000000000000000000000000000b7f7f7f7f7f7f7f7f7c7000000000000000000000000
b7f7f7f7f7f7f7c70000000000000000000000000000b7f7f7f7c700000000000000000000b7f7f7c7000000000000000000b7f7f7f7f7f78494946400000084
f7f7c7000000000000000000000000000000b7c70000000000000000000000000000000000000000000000b7f7f7f7f7f7f7c700000000000000000000000000
00b7f7f7f7f7c700000000000000000000000000000000b7f7c7000000000000000000000000b7c70000000000000000000000b7f7f7f7f78494946404000084
f7c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7f7f7f7f7c70000000000000000000000000000
0000b7f7f7c700000000000000000000000000000000000087000000000000000000000000000000000000000000000000000000b7f7f7f784949464e7000084
c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7f7f7c7000000000000000000000000000000
000000b7c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7f7f784949464f7e70084
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7c700000000000000000000000000000000
000000000000000000000000000000000000000000310000000031000000000000000000000000000000000000000000000000000000b7f784949464b7f7e784
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000004040404040404000000000000000000000000000000000000000000000000000000b78494946404b7f784
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000849494640000b784
0000000000000000000000000000000000000000000000000000000000d714240000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008494946400000084
00000000000000000000000000000000000000000000000000000000d7f78464e700000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008494946400000084
000000000000000000000000000000000000000000000000000000d714549464f7e7000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000004040400000000000404040000000000000000000000000000000000000000000000000000447474340400d784
00000000000000d7e70000000000000000000000000000000000d7f784949464f7c7000000000000000000000000000000000000000000000000970000000000
000000000000000000f300000000000000000000000000000000000000000000000000d7e7000000000000000000000000000000000000000000000000d7f784
000000000000d71424e7000000000000000000000000000000d7145494949464c7000000000000000000000000000000000000000000000000d7142400000000
d71424000000000000d4000000000000000000000000000000000000000000000097d7f7f7e700310000000000000000000000000000000000000000d7f7f784
0020000097d7f78464c70000000000000097000000000000d7f7849494949464000000000000970000f40000000000310000970000000000d7f78464000031d7
f784640000970000b4a4c40000f40000000000000000000000000000000000000014545454545424e4e4e40000d7e70097f4000000000000009700d7f7f7f784
545454545454549464e4e4e4e41454545424e4e4e4e4e4145454949494949464e4e4e4e4e4e414545454545424e4e41454545424e4e414545454949454545454
549464e4e41454545454545454545424e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e484949494949494545424e4e414545454545454545454545454545454545494
__gff__
0000000000000000000000040000000000000004040004000400040400000000000000000000010000000000000000000000000000000000000000000000000402010101010101010100000000000004000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
36362600000000000000000000000000000000000000000000007b7f7f7f7f48467f7c007b7f7f7f7f7c7b7f7f7c00000000007d4849467f7f7f7f7c00000000000000007b7f484949494949467c0000000000007b7f7f7f7f7f7f7f7f7f7f7f7f7c00000000007b7f7f7f7f7f7f7f7f7f7f7c0000007b7f7f7f484949494949
3636260000000000000000000000000000000000000000000000007b7f7f7f48467c0000007b7f7f7c00007b7c00000000007d7f4849467f7f7f7c000000000000000000007b4447474747474300000000000000007b7f7f7f7f7f7f7f7f7f7f7c000000000000007b7f7f7f7f7f7f7f7f7c00000000007b7f7f484949494949
363626000000000000000000000000000000000000000000000000007b7f7f484600000000007b7c000000000000000000007b7f4849467f7f7c0000000000000000000000007b7c0000007a000000000000000000007b7f7f7f7f7f7f7f7f7c0000000000000000007b7f7f7f7f7f7f7c000000000000007b7f484949494949
36362600000000000000000000000000000000000000000000000000007b7f48460000000000000000000000000000000000007b4849467f7c0000000000000000000000000000000000000000000000000000000000007b7f7f7f7f7f7f7c00000000000000000000007b7f7f7f7f7c0000000000000000007b444747474749
3636260000000000000000000000000000000000000000000000000000007b44430000000000000000004e4e4e4e4e4e0000007d4849467c00000000000000000000000000000000000000000000000000000000000000007b7f7f7f7f7c000000000000000000000000007b7f7f7c00000000000000000000007b7c7a7b7f48
36272600000000000000000000000000000000000000000000000000000000007a0000004040404000004145454545420000007b444743000000000000000000000000000000000000000000000000000000000000000000007b7f7f7c0000000000000000000000000000007b7c000000000000000000000000000000007b48
363626000000000000000000000000000000000000000000000000000000000000000000000000000000484949494946000000007b7c7a00000000000000000000000000000000000000000000000000000000000000000000007b7c000000000000000000000000000000000000000000000000000000000079000000000048
3636260000000000000000000000000000000000000000000000000000000000000000000000000000004849494949460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041454200000048
36272600000000000000000000000000000000000000000000000000000000000000000000000000007d4849494949460000000000000000000000000000000000000000007d7e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048494640000048
363626000000000000000000000000000000000000000000000000000000000000000000000000007d7f48494949494600414200000000000000000000000000000000007d41427e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007d48494600000048
3636260000000000000000000000000000000000000000000000000000000000000000007900007d7f7f4849494949467d484600000000000000000000000000000000007b48467c001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007d7f48494600000048
363626000000000000000000000000000000000000000000000000004e4e000000000041454545427f7f4849494949467f484600000000000000000000000000000000000048460000000000000000000000000000000000000000000000000000000000000000000000000b00000000000000000000007b7f48494600000048
3636260000000000000000000000000000000000000000000000000041427d7e7d7e7d48494949467f7c4849494949467c48467e0000000000000000000000000000000000484600000000001800007d7e00000000000000000000000000000000000000000000000000004d0000000000000000000000007b48494640000048
363626000c000000000000000000000000000000000000000000000048467c7b7c7b7c48494949467c004849494949460048467f7e4f0079000000000000000000000000004846000000000041454545427e1300790000000000000000000000000000007900004f00004b4a4c00007900000000000000000048494600000048
45454545454545454545454545454545454545424e4e4e4e4e4e4e4e48464e4e4e4e4e48494949464e4e4849494949464e484945454545424e4e4e4e4e4e4e4e4e4e4e4e4e48464e4e4e4e4e484949494945454545424e4e4e4e4e4e4e4e4e4e4e4e4e4e414545454545454545454545424e4e4e4e4e4e4e4e48494600000048
4949494949494949494949494949494949494949454545454545454549494545454545494949494945454949494949494549494949494949454545454545454545454545454949454545454549494949494949494949454545454545454545454545454549494949494949494949494949454545454545454549494600000048
4949494949494949494747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474749494949494949474747474747474747494949474747474749494947474747474747474747474747474747474749494640000048
4949494949494949467f7f7c000000007a000000007b7f7f7f7f7c007a00000000000000000000007b7f7f7f7f7f7f7f7f7f7f7c007a00000000007b7f7f7f7f7c007a000000007b7f7f7f7f484949494949467f7f7c000000007b7f4849467c000000004447437c000000007a000000000000007b7f7f7f7f4849467e000048
4949494949494949467f7c00000000000000000000007b7f7f7c0000000000000000000000000000007b7f7f7f7f7f7f7f7f7c0000000000000000007b7f7f7c00000000000000007b7f7f7f484949494949467f7c0000000000007b4849460000000000007b7c00000000000000000000000000007b7f7f7f4849467f7e0048
4947474747474747437c000000000000000000000000007b7c00000000000000000000000000000000007b7f7f7f7f7f7f7c00000000000000000000007b7c000000000000000000007b7f7f484949494949467c000000000000000044474300000000000000000000000000000000000000000000007b7f7f4849467b7f7e48
46007a000000000000000000000000000000000000000000000000000000000000000000000000000000007b7f7f7f7f7c000000000000000000000000000000000000000000000000007b7f484949494949460000000000000000007a00000000000000000000000000000000000000000000000000007b7f484946407b7f48
460000000000004f0000000000000000007d7e00001b000000000000000000000000000000000000000000007b7f7f7c0000000000000000000000000000000000000000000000000000007b444747474747430000000000000000000000000000000000001a0000000000000000000000000000000000007b48494600007b48
4600000000794145454200000000000000404040404040400000000000000000000000000000000000000000007b7c00000000000000000000000000000000000000000000000000000000007b7c007a000000000000000000000000000000000000000000000000000000000000000000000000000000000048494600000048
4600000041454949494600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007d7e000000000000000000000000000000000000000000000048494600000048
460000004849494949460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000079000000000000000000007d41427e0000000000000079000000000000000000000000000044474340000048
46000000484949494946000000000000000000000000000000007d7e000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000000000000000000000041420000000000000000007b48467c000000000000414200000000000000000000000000007a000000000048
460000404849494949467e000040400000000000000000000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000079000000000000000000004846000000000000001a000048460000000000007d4846000000000000000000000000000000000000000048
460000004849494949467c00000000000000000000000000000000000000000000007d7e00000000000000130000137d7e000000000000000000000000003f000000000000000000004142000000130000000000484600000000000000000000484600000000007d7f4846000000000000000000000000000000000000007d48
460000004849494949467e000000000000000000000000000000000000000000007d7f7f7e001b007d7e4145454545427f7e00791b0000000000000000004d0000000000000000007d4846000040404040400000484600000000001b00000000484600000000007b7f48460000000000790000004f00000000007900007d7f48
467e00004849494949467f7e00000000000000000000000000000000000079007d7f414545454545454549494949494945454545454545427e000000004b4a4c0079004f000000007b484600000000000000000048460040404040400000000048460000000000007b48464e4e4e4e4145454545454545454545454545454549
467f7e4048494949494945424e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4145454545494949494949494949494949494949494949494949494545454545454545454545454545424e4e48464e4e4e4e4e4e4e4e4e48464e4e4e4e4e4e4e4e4e4e48464e4e4e4e4e4e4e4849454545454949494949494949494949494949494949
467b7f7e48494949494949494545454545454545454545454545454545494949494949494949494949494949494949494949494949494949494949494949494949494949494949454549494545454545454545454949454545454545454545454949454545454545454949494949494949494949494949494949494949494949
__sfx__
0102000025751277412a7312d73131721377113370135701377010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000024651287412b7312f73133721366113370135701377010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002415528155241552815524155281550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002a7552f75534755225001f5001f5003150024500375003b500285003e50027500235001f5003f500185003c500365002d500175000150000000000000000000000000000000000000000000000000000
01100000180201802018020180121c0201c0201c0201c0121b0201b0201b0201b0121e0201e0201e0201e012190201902019020190121d0201d0201d0201d0121c0201c0201c0201c0121f0201f0201f0201f012
011000001805318053180531f00024635000001805318053180531b100246351f00024635000001b0001b0001805318053180531f00024635000001805318053180531b100246351f00024635000001b0001b000
0110000024030270302b0302e0302b0302b0352703027035240352403527030270352e0302e0302e0222e02524030270302b0302e0302b0302b0352703027035240352403527030270352b0302b0302b0222b025
011000002b0302b0352903029035270302703524030240352403027030290302b0302e0302e0352b030290352b0302b0352903029035270302703524030240352903029035270302703524030240302402522030
011000001305013050130501305113041130401304213042100501005010050100420c0500c0500c0500c0420f0500f0500f0500f04216050160501605016042130501305013050130420f0500f0500f0500f042
011000001a0551f05521050210551a0501a0501a0551a055210551f0551d0551c0551a0501a0551a0501a0501d0501d0501f0501f050210502105021050210551f0501f0551d0551a0551a0501a0501d0501d055
011000001d0501d0551b0501b0551a0501a05518050180551f0501f0552205022055210502105520050200551f0501f0501f0501f0501c0501c0501c0501c050180501805018050180501c0501c0501d0501d055
011000000e0500e0500e0500e052150521505015050150501105011050110501105215052150501505015050110501105011050110520e0520e0500e0500e050110501105011050110520e0520e0500e0500e050
01100000110501105011050110520e0520e0500e0500e0501305013050130501305210052100501005010055100501005010050100520c0520c0500c0500c0550c0500c0500c0500c0520e0520e0500e0500e055
011000000c0500c0500c0500c0500c0400c0400c0400c0400e0500e0500e0500e0500e0400e0400e0400e0400b0500b0500b0500b0500b0400b0400b0400b0400c0500c0500c0500c0400b0500b0500b0500b040
011000000705007050070500704007040070400f0500f05011050110501105011050110401104011040110500e0500e0500e0500e0500e0400e0400e0400e0400f0500f0500f0500f0400e0500e0500e0500e040
011000001805318053180532460024635246052460018053000001805318053000002463524605180030000018053180531805324600246352460524600180530000018053180530000024635246052463500000
011000001305013050130501304013040130401b0501b0501d0501d0501d0501d0501d0401d0401d0401d0501a0501a0501a0501a0501a0401a0401a0401a0401b0501b0501b0501b0401a0501a0501a0501a040
0110000018050180501805018050180401804018040180401a0501a0501a0501a0501a0401a0401a0401a04017050170501705017050170401704017040170401805018050180501804017050170501705017040
011000001b0501b0501b0501b0501d0501d0501d0501d0501a0501a0501a0501a0501e0501e0501e0501e05022050220502205022050210502105021050210501f0501f0501f0501f05021050210502105021050
011000001f0501f0501f0501f0501d0501d0501d0501d0501b0501b0501b0501b0501a0501a0501a0501a05022050220502205022050210502105021050210501f0501f0501f0501f05021050210502105021050
011000001605016050160501604213050130501305013042150501505015050150421105011050110501104216050160501605016042130501305013050130421605016050160501604213050130501305013042
01100000220502205521050210551f0501f0551d0501d0551d0551f05521050210551d0501d0501d0501d055210551f0551d0551b0551f0501f0501f0501f055220502205022050220551f0501f0501f0501f055
0110000022050220551f0501f0551a0501a05522050220551c0551d0551c0551f0552105021050210502104222050220551f0501f0551a0501a05522050220551f0501f0521f0521f0551d0501d0551b0501b055
011000001605016050160501604213050130501305013042150501505015050150511504115040150421504216050160501605016051160411604016042160421305013050130501304216050160501605016042
010c000011050110551d0501d05511050110551d0501d05511050110551d0501d05511050110551d0501d05511050110551d0501d05511050110551d0501d05511050110551d0501d05511050110551d0501d055
010c00000f0500f0551b0501b0550f0500f0551b0501b0550f0500f0551b0501b0550f0500f0551b0501b0550f0500f0551b0501b0550f0500f0551b0501b0550f0500f0551b0501b0550f0500f0551b0501b055
010c00001805318053180532460024635246052460018053000001805318053000002463524605180030000018053180531805324600246352460524600180530000018053180530000024635246052463500000
010c00002b0402b0402b0402b040270402704027040270402e0402e0402e0402e0402b0402b0402b0402b0402604026040260402604027040270402704027040290402904029040290402b0402b0402b0402b045
010c00002b0502b0502b0502b0502e0502e0502e0502e0502b0502b0502b0502b05027050270502705027050290502905029050290502b0502b0502b0502b050270502705027050270502e0502e0502e0502e050
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 04 42 43 44
00 04 05 43 44
01 08 05 06 44
02 08 05 07 44
00 0d 42 43 44
01 0d 0e 0f 44
01 0b 09 0f 44
02 0c 0a 0f 44
03 10 11 43 44
01 12 0f 43 44
02 13 0f 43 44
01 14 15 0f 44
02 17 16 0f 44
01 18 1b 1a 44
02 19 1c 1a 44
00 41 42 43 44
00 41 42 43 44
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
