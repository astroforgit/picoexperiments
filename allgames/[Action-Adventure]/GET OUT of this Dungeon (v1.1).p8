pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- get out of this dungeon
-- insanus + god

debug=false
time_count=false

function _init()
 t_delay=0
 t_reverse=false
 flicker=0
 lightning=0
 _update = menu_update
 _draw = menu_draw
 init_zombies()
 init_slimes()
 music(46,100,-1)
end

function thunder()
 lightning += 1
 if(lightning > 100) and
 (lightning < 105) or
 (lightning > 108) and
 (lightning < 115) then
  pal(0,0,1) pal(1,7,1) pal(2,7,1)
  pal(3,0,1) pal(4,7,1) pal(5,7,1)
  pal(7,7,1) pal(8,7,1) pal(9,7,1)
  pal(10,7,1) pal(11,7,1) pal(12,7,1)
  pal(13,7,1) pal(14,7,1) pal(15,7,1)
  if(lightning == 101) sfx(48,-1)
 end
 if(lightning > 400) lightning = 0
end

function menu_update() 
 if(btn(4) and btn(5))
 and(t_delay==40) then
  t_reverse=true
  music(-1,300)
  music(0,300,0)
  sfx(61)
 end
 if(t_delay==0)
 and(t_reverse==true) then
  t_delay=0
 	t_reverse=false
 	_update = game_update
 	_draw = game_draw
 end
end

function menu_draw()
 cls() 
 color_transition()
 map(112,48,0,0,16,16)
 
 snow_part(1,rnd(128),rnd(28)-28)
 lava_sparks(rnd(1)-0.8,rnd(16)+36,120)
 lava_sparks(rnd(1)-0.8,rnd(16)+80,120)
 
 flicker += 1 
 if(flicker <= 16) then
  print("press Ž + — to start",21,110,7)
  print("Ž",45,110,12)
  print("—",65,110,8)
 end
 if(flicker >= 32) flicker = 0
 
 print("v1.1",4,85,(flicker/4)+8)

 thunder()
end

p={
 --start position
 x=444,y=352,
 --first checkpoint
 cpx=51,cpy=43,
 --last checkpoint
 last_cpx=51,last_cpy=43,
 
 door=false,alive=true,
 speed=0,grav=3,armor=0,
 deathcount=0,death=0,
 jumps=0,jumpsmax=1,
 shake=0,heat=0,
 punch=false,punch_delay=0,
 dash=false,

 score=0,spider=0,key=0,
 gem1=0,gem2=0,gem3=0,
 gem4=0,gem5=0,gem6=0,
	msg_delay=0,msg_type=0,
	
 dirx=false, move=false,
 pcol=true, --allow collisions
 walk={
  first_i=2, start_i=2,
  size=4, speed=1/3,
 },
 punch_anim={
  first_i=4, start_i=4,
  size=3, speed=1/3,
 },
 cpfire={
  first_i=9, start_i=9,
  size=2, speed=1/3,
 },
 fire1={
  first_i=45, start_i=45,
  size=2, speed=1/3,
 },
 fire2={
  first_i=46, start_i=45,
  size=2, speed=1/3,
 }
}
--arrow
arw={ 
 speed=2, delay=60
}
--timer
t={
 ms=0, s=0, m=0
}

function timer()
 if(t.ms <= 60) t.ms+=2
 if(t.ms >= 60) then
  t.ms=0
  t.s+=1
 end
 if(t.s >= 60) then
  t.m+=1
  t.s=0
 end
end

--btn(4)=jump
--btn(5)=action
function controls() 
 local lx=flr((p.x+2)/8)*8
 //local lx=flr(p.x)
 if(p.alive) then
 	--ice inertia
  if(ice) then
   if(btn(0))
   and(p.speed<2) then
   	p.speed+=0.2
   	p.x-=flr(p.speed)
   	p.dirx=true
   elseif(p.dirx==true)
   and(p.speed>0) then
    p.x-=p.speed
    p.speed-=0.2
   end
   if(btn(1))
   and(p.speed<2) then
   	p.speed+=0.2
   	p.x+=flr(p.speed)
   	p.dirx=false
   elseif(p.dirx==false)
   and(p.speed>0) then
    p.x+=p.speed
    p.speed-=0.2
   end
  else --default speed
   if(btn(0)) then
   	p.speed=2
   	p.x-=p.speed
   	p.dirx=true
   end
   if(btn(1)) then 
   	p.speed=2
   	p.x+=p.speed
   	p.dirx=false
   end
   if(p.move) then
    p.speed=2
   else 
    p.speed=0
   end
  end
 
  if((btn(0) or btn(1))==true) then
   p.move=true
  else
   p.move=false
  end 
 end
 if(collision(0))
 or(collision(1))then
  p.x=lx
  p.move=false
 end
end

function gravity() --and jump
 local ly=flr((p.y+2)/8)*8 --last y
 p.y+=p.grav
 if(collision(0))
 or(collision(2))
 or(collision(3)) then
  p.jumps=p.jumpsmax
 else
  if(p.armor==0) p.jumps=p.jumpsmax-1
 end
 if(p.alive==true) then
  --jump
  if(btnp(4)) 
  and(p.grav==3)
  and(collision(0)) then
    p.jumps-=1
   	p.grav=-7
  		sfx(49)
  end
  --multijumps
  if(btnp(4)) 
  and(collision(0)==false) 
  and(p.jumps>0) then
    p.jumps-=1
   	p.grav=-7
  		sfx(49)
  end
 end
 if(p.grav<3) p.grav+=1
 if(collision(2)) then--ice
  p.y=ly
  ground=false
  ice=true
  lava=false
 elseif(collision(3)) then--lava
  p.y=ly
  ground=false
  ice=false
  lava=true
 elseif(collision(0)) then--ground
  p.y=ly
  ground=true
  ice=false
  lava=false
 elseif(collision(1)) then--wall
  p.y=ly
 else
  ground=false
  ice=false
  lava=false
 end
 --ignore hud position
 if(cely-(16*ry)==14) p.y+=16
 if(cely-(16*ry)==15) p.y-=16
end

-- 0=ground
-- 1=walls
-- 2=ice
-- 3=lava
function collision(flag)
 col=false
 if(p.pcol) then
  colx1 = (p.x)/8
  coly1 = (p.y)/8
  colx2 = (p.x+7)/8
  coly2 = (p.y+7)/8
 	a = fget(mget(colx1,coly1),flag)
 	b = fget(mget(colx1,coly2),flag)
 	c = fget(mget(colx2,coly2),flag)
 	d = fget(mget(colx2,coly1),flag)
  col = a or b or c or d
 end
 return col
end

function checkpoint()
  if(mget(celx,cely)==8) then
  sfx(55)
  p.msg_delay=20
  p.msg_type=3
  p.cpx=celx
  p.cpy=cely
  mset(p.last_cpx,p.last_cpy,8)
  cpfire=false
  p.last_cpx=p.cpx
  p.last_cpy=p.cpy
  --hide spite to show animation
  mset(celx,cely,0)
  cpfire=true
 end
end

function punching()
 if(p.punch_delay > 0) p.punch_delay-=1
 if(p.alive) then
  if(btn(5))
  and(p.punch==false)
  and(p.punch_delay == 0) then
   p.punch_delay = 18
   sfx(50)
  end
  if(p.punch_delay >= 10) then
   p.punch = true
  else
   p.punch = false
   p.punch_anim.first_i = 4
  end
  if(p.punch) 
  and(p.punch_delay >= 14)then
   if(btn(0)) then
    p.x -= 2
   end
   if(btn(1)) then
    p.x += 2
   end
  end
 end
end

function ladder()
 if(p.alive) then
  if(mget(celx,cely)==21) then
   p.grav = 0
   if(btn(2)) p.grav =- 2
   if(btn(3)) p.grav = 2
  end
 end
end

function ice_cube()
 --ice cube x+1
 if(mget(celx+1,cely)==12) then
  if(btnp(5)) then
   sfx(62)
   make_explosion(p.x+12,p.y+4,5)
   mset(celx+1,cely,0)
  end
 end
 if(mget(celx+1,cely)==11) then
  if(btnp(5)) then
   sfx(62)
   make_explosion(p.x+12,p.y+4,5)
   mset(celx+1,cely,12)
  end
 end
 --ice cube x-1
 if(mget(celx-1,cely)==12) then
  if(btnp(5)) then
   sfx(62)
   make_explosion(p.x-4,p.y+4,5)
   mset(celx-1,cely,0)
  end
 end
 if(mget(celx-1,cely)==11) then
  if(btnp(5)) then
   sfx(62)
   make_explosion(p.x-4,p.y+4,5)
   mset(celx-1,cely,12)
  end
 end
end

function item()
 --coins
 if(mget(celx,cely)==33) then
  p.score+=1
  mset(celx,cely,0)
  sfx(51)
  p.msg_delay=10
  p.msg_type=1
	end
	--chest
	if(mget(celx,cely)==22)
	 and (btn(5)) then
  p.score+=25
  mset(celx,cely,23)
  sfx(52)
  p.msg_delay=10
  p.msg_type=2
	end
		--armor
	if(mget(celx,cely)==39) then
  p.armor=1
  p.jumpsmax=2
  mset(celx,cely,0)
  sfx(54)
  p.msg_delay=90
  p.msg_type=9
	end
	if(mget(celx,cely)==40) then
  p.armor=2
  p.jumpsmax=2
  p.heat=80
  mset(celx,cely,0)
  sfx(54)
  p.msg_delay=90
  p.msg_type=10
	end
	--gems
	if(mget(celx,cely)==52) then
  p.gem1=1 p.score+=50
  mset(celx,cely,0)
  sfx(53)
  p.msg_delay=20
  p.msg_type=4.1
	end
	if(mget(celx,cely)==53) then
  p.gem2=1 p.score+=50
  mset(celx,cely,0)
  sfx(53)
  p.msg_delay=20
  p.msg_type=4.2
	end
	if(mget(celx,cely)==54) then
  p.gem3=1 p.score+=50
  mset(celx,cely,0)
  sfx(53)
  p.msg_delay=20
  p.msg_type=4.3
	end
	if(mget(celx,cely)==55) then
  p.gem4=1 p.score+=50
  mset(celx,cely,0)
  sfx(53)
  p.msg_delay=20
  p.msg_type=4.4
	end
	if(mget(celx,cely)==56) then
  p.gem5=1 p.score+=50
  mset(celx,cely,0)
  sfx(53)
  p.msg_delay=20
  p.msg_type=4.5
	end
	if(mget(celx,cely)==57) then
  p.gem6=1 p.score+=50
  mset(celx,cely,0)
  sfx(53)
  p.msg_delay=20
  p.msg_type=4.6
	end
end

function keys()
 --key
 if(mget(celx,cely)==24) then
  sfx(56) 
  p.key+=1
  mset(celx,cely,0)
  p.msg_delay=20
  p.msg_type=5
 end
 --door x+1
 if(mget(celx+1,cely)==25) then
  if(p.key>0) and(btn(5)) then
   sfx(61)
   p.key-=1
   mset(celx+1,cely,26)
  end
 end
 --door x-1
 if(mget(celx-1,cely)==25) then
  if(p.key>0) and(btn(5)) then
   sfx(61)
   p.key-=1
   mset(celx-1,cely,26)
  end
 end 
end

function traps()
 if(p.alive) then
  --spikes = 1
  if(mget(celx,cely)==42) then
   p.death=1
   sfx(57)
  end
 --ice sprike = 2
  if(mget(celx,cely)==43) then
   p.death=2
   sfx(57)
  end
	--lava = 3
  if(lava) and(p.heat<=0) then
 	 p.death=3
 	 sfx(59)
 	end
 	if(p.armor==2) and(p.alive) then
   if(lava) then
    if(p.heat>0) p.heat-=2 
   else
    if(p.heat<80) p.heat+=0.5
 	 end
  end
 end
	--arrow = 4
	arw.speed+=2
 arw.delay-=1
 if(arw.delay==0) then
  arw.delay=60
  arw.speed=0
 end	
end

function monsters()
 --spider web
 if(mget(celx,cely)==38) then
  p.grav=1
		if(btn(0)) then
  	p.x+=1
  end
  if(btn(1)) then 
  	p.x-=1
  end
 end
	--spider
 if(mget(celx,cely)==15) then
  sfx(63)
  p.spider+=1
  mset(celx,cely,0)
	end
end

function death()
	--death	
	if(p.death!=0)
	and(p.alive==true) then
	 p.deathcount+=1
	 p.shake=10
	 if(p.death!=2) p.grav=-5
	 p.alive=false
	end
	if(p.death!=0)
 and(p.alive==false)
	and(btn(5)) then
	 if(p.armor==2) p.heat=80
  p.x=p.cpx*8
  p.y=p.cpy*8
  p.death=0
  p.alive=true
	end
end

function theend()
 if(p.gem1)==1 and(p.gem2)==1 
 and(p.gem3)==1 and(p.gem4)==1 
 and(p.gem5)==1 and(p.gem6)==1 then
  door=true
 end
 if(door) then
  if(mget(celx,cely)==94)
  or(mget(celx,cely)==95) then
   if(btn(5)) then
    t_reverse=true	 
	   music(-1,300)
    music(47,300,0)
    sfx(61)
   end
 	end
	 if(t_reverse==true) 
	 and(t_delay==0) then	 
	  t_delay=0
  	t_reverse=false
  	_update = end_update
   _draw = end_draw
	 end
 end
end

function gameover()
 if(p.deathcount >= 100) then
 	 t_delay=0
  	t_reverse=false
  	music(-1,300)
   music(47,300,0)
   _update = gameover_update
   _draw = gameover_draw
 end
end

function anim(a)
 a.first_i += a.speed
 if (a.first_i >= a.start_i + a.size) then
  a.first_i = a.start_i
 end
 return flr(a.first_i)
end

function color_transition()
 if(t_delay<40) t_delay+=2
 if(t_reverse==true) t_delay-=4
 --color transition
 if(t_delay<5) then
  pal()
  pal(1,0) pal(2,0) pal(3,0) 
  pal(4,0) pal(5,0) pal(7,0)
  pal(6,0) pal(8,0) pal(9,0)
  pal(10,0) pal(11,0) pal(12,0)
  pal(13,1) pal(14,0) pal(15,0)
 elseif(t_delay<10) then
  pal()
  pal(1,1) pal(2,1) pal(3,1)
  pal(4,1) pal(5,1) pal(7,1)
  pal(6,1) pal(8,1) pal(9,1) 
  pal(10,1) pal(11,1)
  pal(12,1) pal(13,1)
  pal(14,1) pal(15,1)
 elseif(t_delay<15) then
  pal()
  pal(3,13) pal(4,1) pal(5,1) 
  pal(7,1) pal(6,5) pal(8,1) 
  pal(9,1) pal(10,1) pal(12,1) 
  pal(11,13) pal(14,2) pal(15,14)
 elseif(t_delay<20) then
  pal()
  pal(3,3) pal(7,12) pal(8,1) 
  pal(9,12) pal(10,12) 
  pal(11,11) pal(12,12) pal(13,13)
  pal(14,13) pal(15,13)
 elseif(t_delay<25) then
  pal() 
  pal(7,8) pal(8,2) 
  pal(9,8) pal(10,8) 
 elseif(t_delay<30) then
  pal() pal(7,9) pal(10,9) 
 elseif(t_delay<35) then
  pal() pal(7,9)
 else
  pal()
 end
end

--snowflakes
snowflakes={}

function snow_part(nb,nx,ny)
 while (nb>0) do
  snow={}
  snow.x=nx
  snow.y=ny
  snow.dirx=rnd(1)-0.5
  snow.diry=rnd(1)+0.5
  snow.col=7
  snow.f=0
  snow.maxf=rnd(56)+56 --max frames
  add(snowflakes,snow)
  nb-=1
 end
 for snow in all(snowflakes) do
  snow.x+=snow.dirx
  snow.y+=snow.diry
  snow.f+=1
  if(snow.f>56) snow.col=12
  pset(snow.x,snow.y,snow.col)
  if (snow.f>snow.maxf) then
   del(snowflakes,snow)
  end
 end
end

--sparks
sparks={}

function lava_sparks(nb,nx,ny)
 while (nb>0) do
  lav={}
  lav.x=nx
  lav.y=ny
  lav.dirx=(rnd(1)-0.5)/3
  lav.diry=(rnd(1)-1)/3
  lav.col=9
  lav.f=0
  lav.maxf=rnd(16)+16 --max frames
  add(sparks,lav)
  nb-=1
 end
 for lav in all(sparks) do
  lav.x+=lav.dirx
  lav.y+=lav.diry
  lav.f+=1
  if(lav.f>rnd(12)+6) lav.col=8
  if(lav.f>rnd(16)+8) lav.col=2
  pset(lav.x,lav.y,lav.col)
  if (lav.f>lav.maxf) then
   del(sparks,lav)
  end
 end
end

--dust
dust={}
dash_dust=0

function dust_part(nb,nx,ny)
 while (nb>0) do
  d={}
  d.x=nx
  d.y=ny
  if(p.dirx) then
   d.dirx=rnd(1)
  else 
   d.dirx=-(rnd(1))
  end
  d.diry=(rnd(1)-0.5)
  d.col=(flicker/4)+8
  d.f=0
  d.maxf=rnd(12)+12 --max frames
  add(dust,d)
  nb-=1
 end
 for d in all(dust) do
  d.x+=d.dirx
  d.y+=d.diry
  d.f+=1
  if(d.f>rnd(6)+18) d.col=2
  if(d.f>rnd(12)+12) d.col=9
  pset(d.x,d.y,d.col)
  if (d.f>d.maxf) then
   del(dust,d)
  end
 end
end

zombies={
 walk={
  first_i=13, start_i=13,
  size=2, speed=1/30,
 }
}

function init_zombies()
 make_zombie(42*8,44*8)
 
 make_zombie(28*8,2*8)
 
 make_zombie(42*8,12*8)
 make_zombie(83*8,44*8)
 make_zombie(82*8,12*8)
end

function make_zombie(zx,zy)
 local zombie={}
 zombie.x=zx
 zombie.y=zy
 zombie.dirx=true
 zombie.move=0
 zombie.spd=0.5
 add(zombies,zombie)
 return zombie
end

function zombie_move()
 for z in all(zombies) do
  --zombie move
 	if(z.dirx == true) then
 	 z.x += z.spd  
 	else
 	 z.x -= z.spd  
 	end
  --zombie collisions
  if(z.dirx) then
   if(mget(flr((z.x)/8)+1,flr(z.y/8)+1)==0)
   or(mget(flr((z.x)/8)+1,flr(z.y/8))!=0) then
    z.dirx = false
   end
  else
   if(mget(flr((z.x)/8),flr(z.y/8)+1)==0) 
   or(mget(flr((z.x)/8),flr(z.y/8))!=0) then
    z.dirx = true
   end
  end 
 end 
end

slimes={}

function init_slimes()
 make_slime(8*8,54*8)
 make_slime(27*8,60*8)
 make_slime(85*8,60*8)
 make_slime(122*8,44*8)
end

function make_slime(zx,zy)
 local slime={}
 slime.x=zx
 slime.y=zy
 slime.dirx=true
 slime.move=0
 slime.spd=0.5
 add(slimes,slime)
 return slime
end

function slime_move()
 for s in all(slimes) do
  --slime move
 	if(s.dirx == true) then
 	 s.x += s.spd  
 	else
 	 s.x -= s.spd  
 	end
  --slime collisions
  if(s.dirx) then
   if(mget(flr((s.x)/8)+1,flr(s.y/8)+1)==0)
   or(mget(flr((s.x)/8)+1,flr(s.y/8))!=0) then
    s.dirx = false
   end
  else
   if(mget(flr((s.x)/8),flr(s.y/8)+1)==0) 
   or(mget(flr((s.x)/8),flr(s.y/8))!=0) then
    s.dirx = true
   end
  end 
 end
end

explosions={}

function make_explosion(x,y,nb)
 while (nb>0) do
  ex={}
  ex.x=x+(rnd(2)-1)*5
  ex.y=y+(rnd(2)-1)*5
  ex.r=2+rnd(6) --rayon
  ex.c=7 --couleur
  add(explosions,ex)
  nb-=1
 end
end

function game_update()
 timer()
 controls()
 gravity()
 collision()
 punching()
 item()
 keys()
 checkpoint()
 ladder()
 ice_cube()
 traps()
 monsters()
 zombie_move()
 slime_move()
 death()
 theend()
 gameover()
end

function game_draw() 
 cls() 
 color_transition()

 --room position
 rx=flr((p.x+4)/128) --room x
 ry=flr((p.y+4)/128) --room y
 --current room draw position
 dx=(rx*128) --draw x
 dy=(ry*128) --draw y
 --cell position
 if(p.dirx==true) then
  celx = flr((p.x+3)/8)
 else
  celx = flr((p.x+4)/8)
 end
 cely = flr((p.y+3)/8)
 --room cell position
 rmx = (celx-(16*rx))
 rmy = (cely-(16*ry))
 --rect cell position
 rcx = rmx*8+dx
 rcy = rmy*8+dy
 
 --camera
 if(p.shake>1) then
  camera(rx*128+flr(rnd(4)-2),ry*128+flr(rnd(4)-2))
	 p.shake-=1
 else
  camera(rx*128,ry*128)
 end

 map(0,0,0,0,128,64)

 for z in all(zombies) do
  --draw zombie
  if(z.dirx) then
   spr(anim(zombies.walk),z.x,z.y,1,1,true)
  else
   spr(anim(zombies.walk),z.x,z.y,1,1,false)
  end
  --zombie hit player
  if(celx == flr((z.x+3)/8))
  and(cely == flr((z.y+3)/8)) then
   if(p.alive) sfx(58)
   p.death=5
  end
  --player hit zombie
  if(btn(5)) then
   if(p.dirx == true) then
    if(celx == flr((z.x+3)/8))
    and(cely == flr((z.y+3)/8))
    or(celx == flr((z.x+3)/8)+1)
    and(cely == flr((z.y+3)/8)) then
     p.score+=10
     sfx(57)
     p.msg_delay=10
     p.msg_type=6
     make_explosion(z.x+4,z.y+4,5)
     del(zombies,z)
    end
   else
    if(celx == flr((z.x+3)/8))
    and(cely == flr((z.y+3)/8))
    or(celx == flr((z.x+3)/8)-1)
    and(cely == flr((z.y+3)/8)) then
     p.score+=10
     sfx(57)
     p.msg_delay=10
     p.msg_type=6
     make_explosion(z.x+4,z.y+4,5)
     del(zombies,z)
    end
   end
  end
 end
 
 for s in all(slimes) do
  --draw slime
  if(s.dirx) then
   spr(31,s.x,s.y,1,1,false)
  else
   spr(31,s.x,s.y,1,1,true)
  end
  --slime hit player
  if(celx == flr((s.x+3)/8))
  and(cely == flr((s.y+3)/8)) then
   if(p.alive) sfx(58)
   p.death=6
  end
  --player hit slime
  if(btn(5)) then
   if(p.dirx == true) then
    if(celx == flr((s.x+3)/8))
    and(cely == flr((s.y+3)/8))
    or(celx == flr((s.x+3)/8)+1)
    and(cely == flr((s.y+3)/8)) then
     p.score+=10
     sfx(57)
     p.msg_delay=10
     p.msg_type=6
     make_explosion(s.x+4,s.y+4,5) 
     del(slimes,s)
    end
   else
    if(celx == flr((s.x+3)/8))
    and(cely == flr((s.y+3)/8))
    or(celx == flr((s.x+3)/8)-1)
    and(cely == flr((s.y+3)/8)) then
     p.score+=10
     sfx(57)
     p.msg_delay=10
     p.msg_type=6
     make_explosion(s.x+4,s.y+4,5)
     del(slimes,s)
    end
   end
  end
 end
 
 --smooth camera
 --camera(p.x-64<0 and 0 or p.x-64,p.y-64) 

 --timer
 if(time_count) then
  print(":",112+dx,4+dy,7)
  print(":",100+dx,4+dy,7)
  if(t.ms<10) then
   print(flr(t.ms),120+dx,4+dy,7)
   print("0",116+dx,4+dy,7)
  else
   print(flr(t.ms),116+dx,4+dy,7)
  end
  if(t.s<10) then
   print(t.s,108+dx,4+dy,7)
   print("0",104+dx,4+dy,7)
  else
   print(t.s,104+dx,4+dy,7)
  end
  if(t.m<10) then
   print(t.m,96+dx,4+dy,7)
   print("0",92+dx,4+dy,7)
  else
   print(t.m,92+dx,4+dy,7)
  end
 end

 --final door
 if(door) then
  --landscape
  rectfill(444,339,451,359,8)
  rectfill(447,338,448,359,8)
  rectfill(442,341,453,359,8)
  circfill(447,351,4,9)
  circfill(448,351,4,9)
  circfill(447,351,3,10)
  circfill(448,351,3,10)
  rectfill(442,352,453,359,1)
  line(444,353,451,353,12)
  line(446,355,449,355,12)
  --door left
  line(438,342,438,359,4)
  pset(438,341,9)
  line(436,340,436,359,4)
  pset(436,339,9)
  line(434,338,434,359,4)
  pset(434,337,9)
  rectfill(433,345,438,346,4)
  rectfill(433,353,438,354,4)
  pset(434,347,2) 
  pset(434,355,2)
  pset(436,347,2) 
  pset(436,355,2)
  pset(438,347,2) 
  pset(438,355,2)
  --door right
  line(457,342,457,359,4)
  pset(457,341,9)
  line(459,340,459,359,4)
  pset(459,339,9)
  line(461,338,461,359,4)
  pset(461,337,9)
  rectfill(457,345,462,346,4)
  rectfill(457,353,462,354,4)
  pset(457,347,2) 
  pset(457,355,2)
  pset(459,347,2) 
  pset(459,355,2)
  pset(461,347,2) 
  pset(461,355,2)
 end

 --check point fire
 if(cpfire) then
  spr(anim(p.cpfire),p.last_cpx*8,p.last_cpy*8)
 end 
 
 --check for fire sprite
 for fx=0,15 do
  for fy=0,13 do
   if(mget(flr(fx*8+dx)/8,(flr(fy*8+dy)/8))==45) then
    spr(anim(p.fire1),fx*8+dx,fy*8+dy)
   end
   if(mget(flr(fx*8+dx)/8,(flr(fy*8+dy)/8))==46) then
    spr(anim(p.fire2),fx*8+dx,fy*8+dy)
   end
  end
 end 
 
 --arrow dispenser left
 for alx=0,15 do
  for aly=0,13 do
   if(arw.delay>=0) then
    arw.lx=((alx+1)+flr(arw.speed/8))+(16*rx)
    arw.ly=aly+(16*ry)   	
  	 if(mget(flr(alx*8+dx)/8,(flr(aly*8+dy)/8))==111) then
     spr(126,(alx+1)*8+dx+arw.speed,aly*8+dy)      
     if(arw.lx==celx) and(arw.ly==cely) and(p.alive) then
    	 p.death=4
    	 sfx(60)
    	end
    end
   end
  end
 end

 --arrow dispenser right
 for arx=0,15 do
  for ary=0,13 do
   if(arw.delay>=0) then
    arw.rx=((arx-1)-flr(arw.speed/8))+(16*rx)
    arw.ry=ary+(16*ry)
    if(mget(flr(arx*8+dx)/8,(flr(ary*8+dy)/8))==110) then
     spr(126,(arx-1)*8+dx-arw.speed,ary*8+dy,1,1,true,false)
    	if(arw.rx==celx) and(arw.ry==cely) and(p.alive) then
    	 p.death=4
    	 sfx(60)
    	end
    end
   end
  end
 end
 
 --player dash
 if(p.punch) and(p.alive) then
  if(btn(0)) or(btn(1)) then
   dash_dust=3
  end
 else
  dash_dust=0
 end
 dust_part(dash_dust,p.x+rnd(8),p.y+rnd(8))

 if(p.punch) and(p.alive) then
  if(btn(0)) or(btn(1)) then
   p.dash=true
   pal(4,(flicker/4)+8)
   pal(2,(flicker/4)+8)
   pal(2,(flicker/4)+8)
   pal(9,(flicker/4)+8)
   pal(10,(flicker/4)+8)
   pal(12,(flicker/4)+8)
   pal(13,(flicker/4)+8)
  end
 end
 
 --player
 pal(1,0)
 if(p.alive) then
  if(p.armor==1) pal(4,12) pal(2,13) pal(9,13)
  if(p.armor==2) pal(4,10) pal(2,9) pal(9,8)
  --punch
  if(p.punch) then
   if(p.punch) then
    spr(anim(p.punch_anim),p.x,p.y,1,1,p.dirx)
   else
    spr(1,p.x,p.y,1,1,p.dirx) 
   end
  --walk
  elseif(ground) or(ice) or(lava) then
   if(p.move == true) then
    spr(anim(p.walk),p.x,p.y,1,1,p.dirx)
   else
    spr(1,p.x,p.y,1,1,p.dirx) 
   end
  --fall or jump
  else
   spr(7,p.x,p.y,1,1,p.dirx)
  end
  pal()
 else
  --player death
  if(p.grav<0) then
   spr(41,p.x,p.y,1,1,p.dirx,false)
  else
   spr(41,p.x,p.y+3,1,1,p.dirx,true)
  end
 end
 pal()
 
 for e in all(explosions) do
  circfill(e.x,e.y,e.r,e.c)
  e.r-=1
  if (e.r<=0) del(explosions,e)
 end
 
 --lava heat
 if(p.armor==2) and(p.alive) then
  if(p.heat<80) and(p.heat>0) then
   local colour=8+flr(p.heat/20)
   rectfill(p.x-1,p.y-6,p.x+flr(p.heat/10)+1,p.y-3,0)
   rectfill(p.x,p.y-5,p.x+flr(p.heat/10),p.y-4,colour)
  end
 end
 
 --item messages
 if(p.msg_delay>0) then
  p.msg_delay-=1
 end
  --msg print
 if(p.msg_delay>0) then
  if(p.msg_type==1) then --coin
	  rectfill(p.x-1,p.y-9,p.x+7,p.y-3,0)
	  print("+1",p.x,p.y-8,7)
  end
  if(p.msg_type==2) then --chest
  	rectfill(p.x-3,p.y-9,p.x+9,p.y-3,0)
   print("+25",p.x-2,p.y-8,7)
  end
  if(p.msg_type==3) then
   rectfill(p.x-17,p.y-9,p.x+23,p.y-3,0)
   print("checkpoint",p.x-16,p.y-8,12)
  end
  if(p.msg_type==4.1) then
   rectfill(p.x-5,p.y-9,p.x+11,p.y-3,0)
   print("ruby",p.x-4,p.y-8,8)
  end
  if(p.msg_type==4.2) then
   rectfill(p.x-9,p.y-9,p.x+11,p.y-3,0)
   print("quartz",p.x-8,p.y-8,14)
  end
  if(p.msg_type==4.3) then
   rectfill(p.x-11,p.y-9,p.x+17,p.y-3,0)
   print("diamond",p.x-10,p.y-8,12)
  end
  if(p.msg_type==4.4) then
   rectfill(p.x-5,p.y-9,p.x+15,p.y-3,0)
   print("pearl",p.x-4,p.y-8,6)
  end
  if(p.msg_type==4.5) then
   rectfill(p.x-5,p.y-9,p.x+15,p.y-3,0)
   print("amber",p.x-4,p.y-8,9)
  end
  if(p.msg_type==4.6) then
   rectfill(p.x-10,p.y-9,p.x+18,p.y-3,0)
   print("emerald",p.x-9,p.y-8,11)
  end
  if(p.msg_type==5) then --key
   rectfill(p.x-3,p.y-9,p.x+9,p.y-3,0)
   print("key",p.x-2,p.y-8,9)
  end
  if(p.msg_type==6) then --zombie
   rectfill(p.x-3,p.y-9,p.x+9,p.y-3,0)
   print("+10",p.x-2,p.y-8,7)
  end
  if(p.msg_type==9) then --ice armor
   snow_part(2,rnd(128)+dx,dy)
   rectfill(45+dx,48+dy,83+dx,56+dy,7)
   rectfill(44+dx,47+dy,82+dx,55+dy,12)
   print("ice armor",46+dx,49+dy,0)
   rectfill(25+dx,60+dy,101+dx,66+dy,0)
   print("you can double jump",26+dx,61+dy,7)
  end
  if(p.msg_type==10) then --lava armor
   lava_sparks(2,(rnd(36))+44+dx,dy+46)
   rectfill(43+dx,48+dy,85+dx,56+dy,8)
   rectfill(42+dx,47+dy,84+dx,55+dy,9)
   print("lava armor",44+dx,49+dy,0)
   rectfill(23+dx,60+dy,103+dx,66+dy,0)
   print("you can walk on lava",24+dx,61+dy,7)
  end
	end
 if(p.msg_delay==0) then
  p.msg_type=0
 end

 --deaths
 if(p.death>0) then
  if(p.death==1) then
   rectfill(29+dx,40+dy,97+dx,46+dy,0)
   print("spiky things hurt",30+dx,41+dy,7)
  end
  if(p.death==2) then
   rectfill(13+dx,40+dy,113+dx,46+dy,0)
   print("your body is already cold",14+dx,41+dy,12)
  end
  if(p.death==3) then
   rectfill(13+dx,40+dy,113+dx,46+dy,0)
   print("don't try to swim in lava",14+dx,41+dy,9)
  end
  if(p.death==4) then
   rectfill(7+dx,40+dy,119+dx,46+dy,0)
   print("something passed through you",8+dx,41+dy,9)
  end
  if(p.death==5) then
   rectfill(21+dx,40+dy,105+dx,46+dy,0)
   print("zombie eat your brain",22+dx,41+dy,11)
  end
  if(p.death==6) then
   rectfill(24+dx,40+dy,102+dx,46+dy,0)
   print("lava slimes are hot",25+dx,41+dy,9)
  end
  rectfill(29+dx,56+dy,97+dx,63+dy,0)
  print(100-p.deathcount,36+dx,58+dy,(flicker/4)+8)
  print("lives left",48+dx,58+dy,7)
  rectfill(29+dx,72+dy,97+dx,79+dy,0)
  print("press — to retry",30+dx,74+dy,8)
 end
 
 --skulls
 if(p.alive) then
 if(celx==71) and(cely==44) then
  print("there must be a way \n  to jump higher",28+dx,32+dy,7)
 end
 if(celx==46) and(cely==26) then
  print("where is this \n goddam key!",42+dx,82+dy,7)
 end
 if(celx==33) and(cely==12) then
  print("monsters deserves \na good punch in the face",4+dx,62+dy,7)
 end
 if(celx==62) and(cely==28) then
  print("guess where i took an arrow",10+dx,60+dy,7)
 end
 if(celx==122) and(cely==35) then
  print("you probably wonder how \n   i ended up there",20+dx,56+dy,7)
 end
 if(celx==81) and(cely==12) then
  print("   dash to go \nfaster and further",32+dx,56+dy,7)
 end
 if(celx==65) and(cely==28) then
  print("i like to keep my spiders\n      in my pockets",16+dx,88+dy,7)
 end
 if(celx==92) and(cely==60) then
  print("welcome to the pit",32+dx,56+dy,7)
 end
 end
 
 --snowflakes
 if(rx==5 and ry==2) or
 (rx==6 and ry==2) or
 (rx==4 and ry==1) or
 (rx==5 and ry==1) or
 (rx==6 and ry==1) or
 (rx==7 and ry==1) or
 (rx==7 and ry==2) or
 (rx==4 and ry==0) or
 (rx==5 and ry==0) or
 (rx==6 and ry==0) or
 (rx==7 and ry==0) or
 (rx==0 and ry==0) then
  snow_part(1,rnd(128)+dx,rnd(56)+dy)
 end
 
 --sparks
 if(rx==1 and ry==2) then
  lava_sparks(rnd(1)-0.8,rnd(16)+0+dx,104+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+24+dx,104+dy)
 end
 if(rx==1 and ry==1) then
  lava_sparks(rnd(1)-0.8,rnd(16)+8+dx,104+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+32+dx,104+dy)
 end
 if(rx==0 and ry==1) then
  lava_sparks(rnd(1)-0.8,rnd(16)+68+dx,56+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+16+dx,104+dy)
 end
 if(rx==0 and ry==2) then
  lava_sparks(rnd(1)-0.8,rnd(16)+104+dx,104+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+32+dx,104+dy)
 end
 if(rx==0 and ry==3) then
  lava_sparks(rnd(1)-0.8,rnd(16)+48+dx,56+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+80+dx,56+dy)
 end
 if(rx==1 and ry==3) then
  lava_sparks(rnd(1)-0.8,rnd(16)+40+dx,104+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+88+dx,104+dy)
 end
 if(rx==2 and ry==3) then
  lava_sparks(rnd(1)-0.8,rnd(16)+24+dx,104+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+64+dx,104+dy)
 end
 if(rx==4 and ry==3) then
  lava_sparks(rnd(1)-0.8,rnd(16)+40+dx,104+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+88+dx,104+dy)
 end
 if(rx==5 and ry==3) then
  lava_sparks(rnd(1)-0.8,rnd(16)+8+dx,104+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+48+dx,104+dy)
 end
 if(rx==7 and ry==2) then
  lava_sparks(rnd(1)-0.8,rnd(16)+48+dx,104+dy)
  lava_sparks(rnd(1)-0.8,rnd(16)+80+dx,104+dy)
 end
 
 --hud 
 rectfill(0+dx,112+dy,127+dx,127+dy,0)
 --score
 if(p.score<10) then
  print(p.score,112+dx,117+dy,7)
  print("000",100+dx,117+dy,1)
 elseif(p.score>99) then
  print(p.score,104+dx,117+dy,7)
  print("0",100+dx,117+dy,1)
 else
  print(p.score,108+dx,117+dy,7)
  print("00",100+dx,117+dy,1)
 end
 spr(51,115+dx,115+dy)
 --deathcount
 if(p.deathcount<10) then
  print(p.deathcount,8+dx,117+dy,8)
  print("0",4+dx,117+dy,1)
 else
  print(p.deathcount,4+dx,117+dy,8)
 end
 spr(41,12+dx,114+dy)
 --keys
 if(p.key>0) then
 print(p.key,84+dx,117+dy,7)
 else
 print(p.key,84+dx,117+dy,1)
 end
 spr(24,88+dx,115+dy)
 --gem1
 if(p.gem1==0) then
  pal(7,1) pal(8,1) pal(2,1)
 end
 spr(52,28+dx,116+dy) pal()
 --gem2
 if(p.gem2==0) then
  pal(7,1) pal(14,1) pal(15,1)
 end
 spr(53,36+dx,116+dy) pal()
 --gem3
 if(p.gem3==0) then
  pal(7,1) pal(12,1)
 end
 spr(54,44+dx,116+dy) pal()
 --gem4
 if(p.gem4==0) then
  pal(7,1) pal(6,1) pal(13,1)
 end
 spr(55,52+dx,116+dy) pal()
 --gem5
 if(p.gem5==0) then
  pal(7,1) pal(8,1) pal(9,1)
 end
 spr(56,60+dx,116+dy) pal()
 --gem6
 if(p.gem6==0) then
  pal(7,1) pal(3,1) pal(11,1)
 end
 spr(57,68+dx,116+dy) pal()
 --action
 if(mget(celx,cely)==22) or
  (mget(celx+1,cely)==25)
  and (p.key>0) or
  (mget(celx-1,cely)==25)
  and (p.key>0) then
  print("open",14+dx,4+dy,7)
  print("—",4+dx,4+dy,8)
 end
 
 if(door) then
  if(mget(celx,cely)==94)
  or(mget(celx,cely)==95) then
	  print("got out",14+dx,4+dy,7)
   print("—",4+dx,4+dy,8)
 	end
 end
 
 
 flicker += 1
 if(flicker >= 32) flicker = 0
 
 --[[
 if(debug) then
  --room position
  print(rx,108+dx,4+dy,10)
  print(ry,120+dx,4+dy,10)
  --player cell
  print(celx,4+dx,4+dy,8)
  print(cely,16+dx,4+dy,8)
  --player room cell
  rect(rcx,rcy,rcx+8,rcy+8,8)
  print(rmx,108+dx,12+dy,8)
  print(rmy,120+dx,12+dy,8)
  --player position
  print(p.x,32+dx,4+dy,11)
  print(p.y,64+dx,4+dy,11)
  --col 
  if(ground) then
   print("ground",4+dx,12+dy,12)
  end
  if(ice) then
   print("ice",32+dx,12+dy,12)
  end
  if(lava) then
   print("lava",64+dx,12+dy,12)
  end
  --jump
  if(btn(4)) print('jump',28+dx,12+dy,10)
 	--grav
 	print(p.grav,4+dx,20+dy,9)
	 --sprite
		print(mget(celx,cely),16+dx,20+dy,12)
	 --armor
	 print(p.armor,4+dx,28+dy,11)
	 --jumps
	 print(p.jumps,16+dx,28+dy,10)
	 --checkpoint
	 print(p.cpx,4+dx,36+dy,9)
	 print(p.cpy,16+dx,36+dy,9)
	 --cpu
	 print(flr(stat(0)),4+dx,108+dy,11)
	end
	]]

 thunder()

end

function end_update() 
 if(btnp(5)) then
  t_reverse=true
 end
 if(t_delay==0)
 and(t_reverse==true) then
  t_delay=0
 	t_reverse=false
 	_draw = credit_draw
 	_update = credit_update
 end
end

function end_draw()
 cls()
 color_transition()  
 camera()
 map(96,48,0,0,16,16)
 print("you found the way out",22,14,12)
 
 lava_sparks(rnd(1)-0.8,rnd(16)+16,120)
 lava_sparks(rnd(1)-0.8,rnd(16)+40,120)

 flicker += 1
 --timer
 if(t.ms<10) then
  print(flr(t.ms),76,29,(flicker/4)+8)
  print("0",72,29,(flicker/4)+8)
 else
  print(flr(t.ms),72,29,(flicker/4)+8)
 end
 print(":",68,29,(flicker/4)+8)
 if(t.s<10) then
  print(t.s,64,29,(flicker/4)+8)
  print("0",60,29,(flicker/4)+8)
 else
  print(t.s,60,29,(flicker/4)+8)
 end
 print(":",56,28,(flicker/4)+8)
 if(t.m<10) then
  print(t.m,52,29,(flicker/4)+8)
  print("0",48,29,(flicker/4)+8)
 else
  print(t.m,48,29,(flicker/4)+8)
 end
 if(flicker >= 32) flicker = 0
 
 --score
 print(p.score,44,50,7)
 death_bonus=0
 spider_bonus=0
 print(p.deathcount,44,66,8)
 if(p.deathcount==0) then
  print("+250",76,66,11)
  death_bonus=250
 else
  print("-"..p.deathcount*10,76,66,8)
 end
 spr(41,32,63)
 print(p.spider.."/16",44,82,12)
 if(p.spider==16) then
  print("+250",76,82,11)
  spider_bonus=250
 else
  print("+"..p.spider*10,76,82,12)
 end
 final_score=p.score-(p.deathcount*10)+(p.spider*10)+death_bonus+spider_bonus
 print("total score: "..final_score,30,98,9)
 print("press —",85,118,7)
 print("—",109,118,8)
end

function credit_update()

end

function credit_draw()
 cls()
 color_transition() 
 spr(64,8,0,14,4)
 rectfill(8,0,16,8,0)
 --jaycobs
 circ(49,54,4,8)
 circ(75,54,4,8)
 rect(49,50,75,58,8)
 rectfill(49,51,75,57,0)
 print("design + code",36,42,9)
 print("insanus",49,52,7)
 print("@lupusinsanus | jaycobs.fr",12,62,12)
 --bogdan
 circ(32,94,4,8)
 circ(94,94,4,8)
 rect(32,90,94,98,8)
 rectfill(32,91,94,97,0)
 print("music + sfx",42,82,9)
 print("bogdan raczynski",32,92,7)
 print("@bogdanraczynski",32,102,12)
 
 flicker += 1
 print("thanks for playing",28,120,(flicker/4)+8)
 if(flicker >= 32) flicker = 0

 snow_part(1,rnd(128),rnd(56))

 if(btnp(5)) then
  t_reverse=true
 end
 if(t_delay==0)
 and(t_reverse==true) then
  t_delay=0
 	t_reverse=false
 	run()
 end

end


function gameover_update()

end
   
function gameover_draw()
 poke(0x5f2c,3)
 cls()
 color_transition()
 camera()
 lava_sparks(1,rnd(64),rnd(12)+52)

 print("game\nover",24,24,8)
 --spr(41,28,16)

 if(btnp(5))	run()
end
__gfx__
00000000070244470702444700702447000074400070244000724400079244470000000000000000000000000cccccc000cc0000000b3880000b388000070000
000000000772141707721417007721470002741000772140007714000772141700000000000c000000000c00c77cc7c00c7c0cc0000a3a80000a3a8000070000
007007000028f4f00028f4f000028f40000248f000028f400028f4000f28f4ff0000000000ccc000000c0000c7cc77c00cc0c7c0000070300000703000868000
0007700000f8888000f8888000ff8880000ff88000ff8880002888000ff8888f0000000000c7cc0000ccc000ccc77cc0000c77c0000008300000083000606000
000770000ff4888f0ff988890ff9488900ff948000fff9800f44fff900f488800000000000c77c0000c7cc00cc77ccc0ccc0c7c0033bbbb0033bbbb000000000
007007000ff4444f0ff944490ff9444900ff9440000ff9400f444ff900044440002442000024420000244200c77cc7c0c77c0cc0030b33b0030b33b000000000
0000000009944229000442200004442000044420000444200924440000044220000220000002200000022000cccccc000cccc000000033b0000033b000000000
00000000000400200004000200040200004000200000402000200400000400020002200000022000000220000000000000000000000300b00000300b00000000
0dd1ddd1ddd1ddd1ddd1ddd000000000000000000400004000000000000000000000000004050405040504050000000000000000000000000000000000000000
1dd111111dd111111dd1111100000000000000000424442000000000000000000000000044050505000000000011000000000000000000000000000000000000
1111000011110000111101dd00000001000000000424424000000000944794490000000004557994000000000000011000000000011111100000000000088880
d110011000000110000001dd00001011011000000400004094444449000000000790000005059094000000000110111000000000000000000000000000899998
dd100110011101100111011100000011011010000400004094479449000000000999999005059095000000000110000000000011111110111110000009977979
dd100000011000000110001d00011000000000000244424000099000000000000990090005549995000000000000077000001011111110111111000008999998
11101100000011000000101d0001100110001100042442409444444994444449000000005504050500000000077077770000101111ddd0111111000008999980
11000000000000000000001100000011110000000400004082222228822222280000000005040505050405057777777700000000000000000000000089999980
d1011100000000000011011d00111011110000000d0d001060000006000000000000000000000000000000007ccc77c70001111d0ddddddd0ddddddd01111000
d101100000000000001101dd000110011001110000dd0011070660600000000000000000000000000000000007c707c70011111d0ddd8ddd0d8ddddd01111100
1100000000099000000001dd00000000000110000dd001010070070070dccc70709aaa70000000000000000007c70070001111dd0dd898dd0ddd8ddd0d111100
d1100110009499000111011100010110000000000d0d01100606706077d1c1707792a270006777700000000000700070000000000089a8000008980000000000
dd100110009974000110001d000001101101000000dd0010060060600d11110009222200066007000000000000700000001110dddd8a78dddd89a8dddd111000
dd100000000940000000101d000000001100000000d00000007007000d11110009222200066007000000070000000000001110dddd0440dddd0440dddd111000
d1101100000000000000101d0000000000000000000000000606607000000000000000000066707007000700000000000011101ddd0440dddd0440ddd1111000
11000000000000000000001100000000000000000000000060060006000000000000000000006600060706060000000000000000000020000000200000000000
d1011100000000000000001100000000000000000000000000000000000000000000000000000000999899987777777700011111011000110111100011111111
d1011000001100000011011d00000000000880000000000000000000000dd000000000000007b000899888887777077000001111011111110111000001111110
1100000100000110000001dd00079900007788000077770000ccc10000666600007779000077bb00888800000770000000001111011111110111000000001100
d110110001101110011001dd007449900077820007ffffe00c777c100d6776d0007998000777bbb0000002200000011000000000000000000000000000101100
dd100000011000000110011d009499400088820007ffffe000ccc1000d6766d0007998000bbb3330022202200111011000000001111110111000000000101100
dd1011110000111100001111009997400088720000eeee00000c1000006666000098880000bb3300022000000110000000000000011110100000000000101000
11111dd111111dd111111dd100094400000220000000000000000000000dd00000000000000b3000000022000000110000000000000000000000000000001100
01dd1ddd1ddd1ddd1ddd1dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100
42442244000000999999999aaaa00aaa999999999700777777777779900009aaaaa999999007799700007777900aaa9999977799000000000000050550500000
22222222000009999999aaaaaaa8aa99999999997707777777777799900099aaaa999999770799977008777998aaaa9999977999900000000000550000550000
000000000000999999aaaaaaaa88999999999977788777777777799980009aaaa99999997788997770887779988aaa9999977999900000000050000990000500
0442222000009999a8888aaaa98999999888888888888887777788888000aaaaa888899777889777708877999988888899977888800000000550990440990550
0222224000099aaaa8888a99998999998888888888888887779988888000aaaa9888897779887777708889999a88888899977888000000000000440440440000
00022200000aaaaa88888888888999998888888888808887799988888000aaa99888877799987777708889999a88888899977980000000005090440440440905
4422442200aaaaaa88888888888999997777778888008887999988880000aa99998887799978777777888999aa88888889777900000000005040440440440405
2222222200aaaaa988880000009999977777770000000009999980000000a999990087999778777777088999aaa0088889779900000000000040440440440400
000000000aaaa998888000000099977777777780000000099999800000009999990087997778877777088899aaa0088889779990000000005040440440440405
000000000a99999888999999009977788888888000000009999900000000999997008999777887777708889aaaa0008888779990000000005044444444444405
000000000999998889999999897777788888888000000099999900000000999977008997777887777700889aaaa9008888779999000000000044444444444400
000000009999998889999998877777788888888000000099999900000000999777008877777887777990889aaa99008888879999000000005020220220220205
000000009999988888999998877777888888888000000099999900000000997777008877777787777990888aaa99000888899999000000005040440440440405
000000099999988888999978777777888000000000000099999900000000977779008877777787779990888aaa99900888889999900000000040440440440400
000000099999988889999788777777888000000000000099999a00000000777799000877777788799990088aa999900888889999900000005040440440440405
00000099999999999997778877777777777799900000009999aa000000007777997777777777889999999aaaa999900088889999990000005040440440440405
0000009999999999997777887777777777799990000000999aa8000000008779997777777777889999999aaa999990008888999999000000d10111000011011d
000009999999999977777887777777777799999800000099aaa800000000879997777777777788999999aaaa9999990008888999999000009971100000110799
00000999999999977777788777777777799999980000009aaaa800000000099977777777777788999999aaaa9999990008888999999000000090000000000900
00000099999997777777888877777779999999880000009aaaa800000000089777777777777888899999aaa99999900008888899998000000090011001110900
00000008888888888888888808888888888888880000008888880000000008888888888888808888888888888880000008888888800000000040011001100400
00000000088888888888888000888888888888800000000888800000000000888888888888000888888888888800000000888888000000004440000000001444
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d11011000000101d
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000011
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000
000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000001000
00000cccc77777c777777ccc777777c77cc77c777777c777777ccc77777cc77cc77c777cc77c777777c777777cc77777c777cc77ccc000004400077000101100
00000ccc77cc77c77ccccccccc77ccc77cc77ccc77ccc77ccccccc77cc77c77cc77c7777c77c77ccccc77ccccc77cc77c7777c77ccc000000449997700101100
00000111771177177771111111771117777771117711177777711177117717711771771777717717771777711177117717717777111000004400066000101100
00000111cc11cc1cc111111111cc111cc11cc111cc1111111cc111cc11cc1cc11cc1cc11ccc1cc11cc1cc11111cc11cc1cc11ccc111000000000000000101000
00000111ccccc11cc111111111cc111cc11cc1cccccc1cccccc111ccccc11cccccc1cc111cc1cccccc1cccccc1ccccc11cc111cc111000000000000001101110
00000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000011111111
31131313131323000002311323000002000000003113131313132351000200000000002200000002000000000000000000000000000022000002000000000000
000031131313230000000002000000000000000022000002000031b1b1b1b1b1b1b1b1b141220012000200000000000000000000002200000231b1b1b1235102
2200000000f300000002220000000002000000002200000000000051000313410000002200830002003113131313134100000000000022000002000000000000
0000220000f3000000000003b1b1b1b1b1b1b1b1230000020000226200009100000000000222001200020031b1b1b1b1b1b1b1b1b12300000222b2b2b2005102
2200c1d1e10000121202220063000002000000002200c1d1e1000051000000023113132300000003132300000000000200000000311323000003134100000000
3113230000000000c1d1e1000000000000f3000000000002000022f00001b3b32100930002220012000200220000000000000000f30000000222000000005102
2200c2d2f20000011142321111210002311313132300c2d2f2000051006100022262000000000000000000000081000200000000220000000062000200000000
2200520000000000c2e2f200000000000000000000000003b1b123000002000022000000022200120003b1230000000000000000f71212000222920000005102
2200c3d3e30000031313131341226202225100000000c3d3e30001111111114222f00000000000c1d1e1000000000002000031132300000000f0000313410000
2200000000000000c3d3e3000000121200f7000000000000b2b200000002000032111111422200000000b200000001b321000001b3b3b3b34232210000011142
220000000000000000000000032362022251012100121200000003131313131323000000120000c2d2f200000111114200002200000000000000000000020000
220000c1d1e10000000000000001b3b3b3b321000000000012120000000200000000003113230000000000000000020022000002311313131313230000034100
2200000000121200000000000000f0022251023211112100000052000000000000000012001200c3d3e300000313134100002200c1d1e10000c1d1e100020000
220000c2d2f20000121200000002000000b12300000001b3b3b321000002000031b1b123006200c1d1e100000000020022000002220000000000000000000200
22000000011111210080000000000002225103131341220000000000000000000080000000000000000000005200000313132300c2d2f20000c2e2f200031313
230000c3d3e3000001210000a202000022b2520000000231b1b123000002000022b2b20000f000c2d2f2000000000200220000032300c1d1e100000012120200
22000000020000321111210000000002225100000003230000000000000001111111210000000000000000000000000000000000c3d3e30000c3d3e30000f300
000000000000000002220000014200002200000012000222b2b252000003b1b123000000000000c3d3e3000001b34200220000520000c2d2f200000111114200
32210000031313131341220000000002225100000000000000001212000002000000220000000111210000000000000000000000000000000000000000000000
00001212120000000222a2a20200000022000001b3b342220000000000c0b00000000000121200000000000003410000220000001200c3d3e300000313131341
31230000005200000002220000000002321121000000000000000121a2a202000000220000000313230000121200000000000000000000e4f400000000000000
0000011121000000023211114200000022000003b1b1b123000000000000b0c00000000000000012120000000002000022000001112100000000000000000002
220000000000000000022200000000031313230000121200000002321111420000002200000000f3000000012100000000f70080000000e5f50000008000f700
0000020022000000020000000000000022000000b2b2b200000001b3b3b3b3b3b3b3210000000000000000800002000022a2a202002200000000000000610002
22a2a20012120000000232112100000000121200000121a2a2a20200000000000000220400000000000000023211111111111111210000e5f500000111111111
1111420022040092020000000000000022000000000000000000020000000000000022a2a2a2a2a2a2a201b3b342000032111142002200000000000001111142
32a3a3a3a3a321000002000032a3a3a3a3a3a3a3a342321111114200000000000000321111111111111111420000000000000000321111111111114200000000
0000000032111111420000000000000032b3b3b3b3b3b3b3b3b342000000000000003211b3b3b311b3b3420000000000000000000032a3a3a3a3a3a342000000
00000000000022000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000022000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003113131323000002311313131341311313131313131313131313131341000031131313131313131313410000000031131313131313131313131313131313
13131313131313131313131313131313131313131313131313131313134100000031b1b1b1b1b1b1b1b1b1b1b1b1410031b1b1410031b1b1b1b1b1b1b1b1b141
00002212120000000003230000006202220000000000f300000000000062020000220000000000f3000000031313131323006262620012000000000000000000
0000000000f300000000910081000000000052000051510000000000000200000022000000000000000000000000020022b2b203b12300b2b20000b2b2b2b202
000022121200f700009100000000f002220000610000000000c1d1e1000003131323000000001200000000005200000000000062620121000000c1d1e1000000
00800000000000000000011111111111210000000000510000000000000200000022000000000000000000000000020023000000000000000000000000000002
00003211111111111111111121000002220001112100000000c2d2f2000000000000000000120012c1d1e1001200000000000000f00222000000c2d2f2000111
1111112100000000a2a202000000000032112100005151000121000000034100003211210000000000000000011142006200142434445464748494a4b4c4d403
31131313131313410000003123000002226202002200000000c3d3e3000012120000000000000000c2e2f2120012000000000000000222040000c3d3e3000341
00000022a2a200000111420000000000003123005151000002f600000000020031131323000000000000000003131341f005152535455565758595a5b5c5d500
22000000000000031313132300000002226203132300000000000000000111111111112100000000c3d3e3000000800000000000000232111121000000000002
000000321121000003131341000000000022620000510000022200000000e600220000000000000000000000005200020006162636465666768696a6b6c6d600
22000001210000000000000000000002220000520000000000000000000200000031132300000000000000000001111111210000000313131323000000000002
000031131323000052000002000000000022f000515100000232210000000341220000003300000000000000000000022107172737475767778797a7b7c7d7a2
2200000232a3a3a3a3a3a3a3a3a3a34222000000000000000121a2a2a20200000022004200c1d1e1000000000003410032230000000052000000000000000002
0000220000000000000000020031131313230000510000000200f600000000022200430000000000000000000073000222000000000000000000000000000001
22000003134100003113131313131313230000000000000002321111114200000022000000c2d2f20000000000000200220000c1d1e100000012121200000002
00002200120000000000000200220000000000005100000002002200000000e6220000000000000000000000000000022200100000000000121200d000610002
22000000000313132300000052000000000000000000011142311313131313410022000000c3d3e30000000000000200220000c2e2f200000111111121000002
000022001200a2a2a2a2000313230000c1d1e1000000000002003221000000022200530000000000000000000083000232111121a2a2a2011111111111111142
22000000000000f300000000000000000000800000000200002200000000000200220000000000000000000000000200220000c3d3e300000313131323000002
000022001200011111210000f3000000c2d2f20000120000034100f6000000022200000062000000000000000000000200000032111111420000000000000000
32210000000012121200000000000001111111210000031313230012121200031323000000000000000000006100020022a2a2a2a20000000000000000000002
00002200120003131323000000000000c3d3e30012001200000200220043000222006300f0000000000000000093000200000000000000000000311313134100
0022a2a201111111111121a2a2a2a2020000002200000000000000000000000000000000000000f700000001111142003211111121a2a2a2a2a2a2a2a2a2a202
000022000000000000000000f7000000000000000000000000020022928000022200000000000000000000000000000200311313131313131313230052000200
0032111142000000000032111111114200000032a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3420000000000000000321111111111111111111142
000032a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3420032111111422200000000000000000000000000000200220000000000000000000000000200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002200000000000000012100000000000200220000000000000000000000000200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000032a3a3a3a3a3a3a342220000000000020032a3a3a3a3a3a3a3a3a3a3a3a34200
__gff__
0000000000000000000000060600000001010100000000000002000200000000020002000000000000000000000000000202020000000000000008040000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000001000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
131b1b14000000131b1b1b311b313131313131141331313131313131313131313131313131313131313131140000000013313131313131313114131b1b1b1400131b1b1b1b1b1b1b1b1b1b1b1b1b1b14131b1b1b1b1b1b1b1b1b1b1b1b1b1b140000001b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b14000000000000001331313114
22262b30311b1b322b000025000000000000002022150000000000000000000000000000003f0000000000200000000022000000000000250020222b2b2b301b32000000000b0b0b0b000000002b2b202200000000000021212100000000006e0000221500000b0b00001500212121000000002000131b1b1b1b1b322b2b2b20
220f000000002b00000000001800000000160020221500000000000000007f00000000000000001c1d1e003031313114220000002121000000202200370019000000000000000b0b0b0b0000000000202200180010111111111111111200002000002215000b0b0b000015103b3b3b3b3b1200301b32003f0000000000000020
22000000002100000000103b3b3b3b1111111124221500101111111111111111111200000000002c2d2f00000000262022000000101200000020233b3b113b3b3b120000103b3b3b3b3b3b12000021202200000020131b1b1b1b1b1423120020131b3215103b3b3b3b1215301b1b1400006f0000000000002121000000000020
22000000211012000000301b1b1b1b1400000000221500303131313131313114002200000008003c3d3e000000000f202200000030320000003031313131311413320000301b1b1b1b1b142200001024222a00002022003f000000301b320020222b0015301b14131b3215002b2b200000233b3b3b3b3b3b3b3b3b3b12000020
22000010112422000000000000002b200013313132150000000000000000262000220000101112000000002121000020231200000000000000000000000000202200000000000000000020220000301423120000206f0000000021212100002022000015002b20222b00150000002000133131000000131b1b1b1b1422000020
220000301b1b320000000010120000200022003f00000000212100000000002000222a2a2000222a2a2a2a10120000201332000021210000000000080000002022002121000000002800202200002b201332000020220000101111111111112422000015000020220000000000002000222b2b301b1b32002121003032000020
22000025002b001c1d1e002022000020006f00000000001011120000000000200023111124002311111111242200002022260000101200000000101112000020220010122a2a2a103b3b2422210000202200000020220000301b1b1b1b1b1b14220000150000202312001500160020002200002500000000000000000000006e
220021000000002c2d2f0020220000200022003500000020002311120000002000000000000000000000000022000020220f0000303200000000200022000020220020231111112400000023120000202200002a2022000025000000000000202200000000003014233b3b3b3b3b2400220000000000103b3b3b3b3b3b3b3b24
233b3b120000003c3d3e0020220000200023111112000030313131320000002013313131313131313131313132000020220000000000000010112400220000202226301b1b14131b1b1b1b1b32000020220000102422002121001c1d1e00003032000000000000301b1b1b1b1b1b1b14220000103b3b24000000000000000000
13313132000021210000002022000020000000002200000000002500000010242200250000000000262600000000003032000000212100002013313132000020220f002b2b30322b00000b00000000202200003014233b3b12002c2d2f0000000000000008000000003f000000000020220000301b1b14131b1b1b1b1b1b1400
2200150000001012000000202200002013313131320000000000000000006e002200000000000000260000000000000000000000101200002022000025000020220000000000000000000b0b0000006e22000000301b1b1b32003c3d3e000000000000103b12000000000000212100206f000000000030320000210000003014
2200150000002022000000202200002022150000000021210000000010112400222900000016000000000000400000000000000020222a2a202200160000002022000000002121210010120b000000202229000000000000000000000040103b3b3b3b2400233b122a2a2a103b3b3b2422000000000000000021402100001520
2200150010112422000000202200002022151011111111111200000020000000001200001011111111111111111111111111111124231111242311111200002022000000103b3b3b3b24233b3b3b3b24233b3b3b3b3b3b3b3b3b3b3b3b3b240000000000000000231111112400000000233b120000103b3b3b3b3b3b3b121520
2200150020000022000000202200002022152000000000002200000020000000002200002000000000000000000000000000000000000000000000002200002022000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002200002000000000000000221520
2200150020000022000000202200002022152000000000002200000020000000002200002000000000000000000000000000000000000000000000002200002022000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002200002000000000000000221520
2200150030311422000000202200002022152000001331313200000030313131313200003031313131313131313131141331313114133131313131313200002022000000301b1b1b1b1b14131b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b00131b320000301b140000131b1b321520
22001500250030320000002022002a20221530313132000025000000000000000000000000000026262626000000002022000000202200260000003f0000002022000000003f00002b2b20220000000000000000150015001500150000002b2b2b000000000b0b00212121000015002022000000000b0020131b322b00001520
220000000000000000000020220010242215000019000000000000001c1d1e0000000000001011111111111111122620220027002022000f00000000000000202200212121000000000020220000000021210000150015001500150000000000000000103b3b3b3b3b3b3b3b121500202200000010120030322b000000001520
2200001c1e00000000000020220030142215001011111200000000002c2e2f00000000000030313131313131142226206f000000202200000021212100404020233b3b3b3b3b1200001024220000103b3b3b12000000150015001500000000000000002000131b1b1b1b1b1b3215002022001600202200000000000000101124
222a002c2f00212100000020220000202215003031142200080000003c3d3e000010120000000000000000262022002022000021202200001011111111111124131b1b1b1b1b3200003014220000200000002200000015001500000000103b3b3b12002000222b2b003f000000150020233b3b3b2422001c1d1e000000301400
2312003c3e00101200000020220000202215000000202311120000000000000000202200000000001c1d1e0f2022182022000010242200002013313131313114222b2b2b2b0000000026202200002000001b320000001500000000000020131b1b3200301b3200000000000000150020000000000022002c2d2f000000002000
1332000000002022000000202200006e2215001600200000222a2a2a1012000000202240000000002c2d2f00303200202221003014220000303200000000002022000000000000000000202200002000222600000000000000000000002022000000000b0b0000002121000000000020131b1b1b1b32003c3d3e002121002000
22000000000020233a3a3a24220000202311111111240000231111112422000000202311111112003c3d3e00250000202312000020220000250000000000006e220000000000212100006e2200002000220f00000000001c1d1e0000003032000000000b0b0000103b12001c1d1e0020220025000c0c00000000103b3b3b2400
6f0000000000200000000000222a002000000000000000000000000000220000003031313131320000000000000000201332002120220021212100101200002023120000103b3b3b3b3b242200002000220000000000002c2d2f000000250000000000000b0000301b32002c2d2f0020220000000b0c00000000301b1b140000
231200001011241331313114231200201331313114000000000000000022000000000000003f000000101200000000202200001024231111111111242200002013320000301b1b1b1b1b1b3200002000220000000000003c3d3e00000000000000000000000000002b00003c3d3e0030320000000b0b0000000000002b200000
13320000303131320000262000220020220000003031313131313131313200000000000000000000003032000000292022210030313131313131313132000020220000003f2b2b000000002500002000220000000000000000000000000000000000000000000000000000000000000019000000101200000008000000303114
22000000003f000000000f20002200202200180000000000000000150000000000000000000000000000000000101124231200000025000000000000000000206f000000000000002121000000002000220000160000000000007f00000000000010120b000000000000000000103b3b3b12000020220000103b120000001520
220021212100000000080020133200202200000000000010120000150000002121001012000000000021210000200000006f0000000000000000007f00002920222900007f0000000000000008002000222a103b1200000000103b122a2a2a2a2a20220b0b0000210010122a2a20000000222a2a202200002000220021001520
233a3a3a3a3a12000010112422000020233a3a3a3a3a3a2423111215001011111111242200000010111111111124000000231111111112000010111111111100233b3b3b3b3b1200000000103b3b2400233b2400220000103b2400233b3b3b3b3b24233b3b1200210020233b3b00000000001111242200002000233b3b121520
0000000000002200002000002200002000000000000000000000221500200000000000220000002000000000000000000000000000002200002000000000000000000000000022000000002000000000000000002200002000000000000000000000000000220000002000000000000000000000002200002000000000221520
0000000000002200002000002200002000000000000000000000221500200000000000220000002000000000000000000000000000002200002000000000000000000000000022000000002000000000000000002200002000000000000000000000000000220000002000000000000000000000002200002000000000221520
__sfx__
011a0000180001c00015000180001c000180001500010000170001d00010000170001d000170001100013000180001f00013000180001f0001800013000180001c00020000180001c00020000230002400000000
010d000009545000000000000000000000000000000000000c5450000000000000000000000000000000000510545000050000000000000000000000000000050c54500005000000000009545000000000000000
010d000008555000000000000000000000000000000000000e5550000000000000000000000000000000000014555000000000000000000000000000000000000e55500000000000000008555000000000000000
010d0000155450000000000145450000000000155450000018545000000000017545000000000518545000051c54500000000052154500000000051c545000051854500000000051754500000000051554500000
010d000014555000000000010555000000000017555000001a55500000000001755500000000001c555000002055500000000001d55500000000001a555000001a55500000000001755500000000001455500000
010d000015545000001454500000155450000017545000001854500000175450000518545000051a545000051c5450000521545000051c545000051a545000051854500005175450000515545000001454500000
010d000014555000001055500000175550000014555000001a5550000017555000001c555000001a5550000020555000001d555000001a5550000017555000001a55500000175550000014555000001055500000
010d0000000000000000000000001c100000001c200000001d300000000000000000174000000000000000001a700000001a500000001c4000000000000000001530000000000000000000000000000000000000
010d00000000000000000000000018200180001a10000000172000000000000000001530000000144000000010100000001a200000001c7000000017500000001540000000000000000000000000000000000000
010d000004135000000000000105041350010500105001050513500105001050010505135001050010500105001350c1050c1050c1050b1350c1050c1050c1050913500105001050010507132091410713109121
010d000009135000000000000000091350000000000000000b1350000000000000000b1350000000000000000c1350000000000000000e1550c1000c1000c100101550c1000c1000c10011155101411113110121
010d000000300003001c4141c4241c4341c424003040030400304003041a3141a3241a3341a324003040030400304003041b4141b4241b4341b424004040040400404004041d3141d3241d3341d3240030000300
010d000000005000051531515325153351532500000000000000000000174151742517435174250000500005000050000518315183251833518325000050000500005000051b4151b4251b4351b4250040500405
010d000004154041340411400500205000050007120005000000000000000000000000000000000000000000051540513405114215001f5000050008120005001c500005001f5001d50001120005001a50000000
010d00002941200000000022841200000007022441200000007022141200000000022041200000047022141204702000002241200000047022341205700007000070000000000000000000000000000000000000
010d0000040300000000000040300000000000040300000007030000000400000000040000b000044000b40002030000000000009030000000000002030000000505000000070000000002000000000200000000
01150000183001830021300213002130018300183001830021300000001f3001f3001f30000300003000030013300000001d3001d3001d300000001f300000001c3001a3001c3001d3001c3001d3001f30024300
01150000183001830021300223002330018300243001830021300000001f3002b3003730000000000000030013300000001c3001c3001c300000001a300000001830000000183000000018300000001830000000
010d00001554500000105450000015545000001054500000155450000010545000051554500005175250000518545000051654500005185450000016545000051854500005165250000518545000001c54500000
010d00001d555000001a555000051d555000051a555000051e5550000519555000051e5550000519555000051f555000051c555000051f555000051c5550000520555000051b5550000520555000051b55500005
010d00000000000000000000000007000000000000000000000000000000000000000300000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000
010d00000000000000000000000005000000000000000000000000000000000000000600000000000000000000000000000000000000070000000000000000000000000000000000000008000000000000000000
010d00001a555000001754500000145350000010525000001a545000001753500000145250000010515000001a535000001752500000145150000010515000001a52500000175150000014515000001051500000
010d00001100000000110000000011000000001100000000140000000014000000001800000000190000000013000000001300000000130000000013000000001600000000160000000017000000001300000000
010d000000300003001c4001c4001c4001c400003000030000300003001a3001a3001a3001a300003000030000300003001b4001b4001b4001b400004000040000400004001d3001d3001d3001d3000030000300
010d000000000000001530015300153001530000000000000000000000174001740017400174000000000000000000000018300183001830018300000000000000000000001b4001b4001b4001b4000040000400
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
011a000015012180221c03215042180321c022180121502510012170221d03210042170321d022170121102513012180221f03213042180321f0221801213025180121c02220032180421c032200222301224025
011a0000101101312018130101401315113145181311812511110151201a130151401a1551a1411d1351d1211a150171401313011121121311312114151131511512215136131451315611142111361012510116
011100000263102621026310262102611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000010500205005050080500a050021200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001165011640116301262012600126001260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002e0503200000000000000000031030000000000000000000001e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000184321c4221f412234121804224032300223c012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000c232102321f23218232282222b2223022234222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01050000185521860223502206021855222502185521800221552180021f552180022155218000000000000024552245422453224522000000000000000000000000000000000000000000000000000000000000
010500001354015000105401500013540150001854010000135400e00018540000002b5412b5412b5412b5312b5212b5110000000000000000000000000000000000000000000000000000000000000000000000
010800001d5452b535375252b51500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001d5531b5521a5431954218533175321652315512000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000110451c045270351a0350d025180250701506015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000c123131330c14313153101430f1330512304113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01070000285431c533105230461100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000065100000000000000000000006510064100631006210061100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001c645000001c635000001c625000001c61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000006110c6211a631286313563124621236110c611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01 42 43 44
00 02 42 43 44
00 01 09 43 44
00 02 0a 43 44
00 03 09 43 44
00 04 0a 43 44
00 05 09 43 44
00 06 0a 43 44
00 05 09 0b 44
00 06 0a 0c 44
00 16 42 43 44
00 09 0b 43 44
00 0a 0c 43 44
00 09 0b 43 44
00 0a 0c 43 44
00 09 0b 0e 44
00 0a 0c 0f 44
00 0f 0b 43 44
00 0f 0c 43 44
00 0f 0e 43 44
00 01 0f 43 44
02 02 0f 43 44
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
03 2e 00 00 00
03 2f 00 00 00
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
