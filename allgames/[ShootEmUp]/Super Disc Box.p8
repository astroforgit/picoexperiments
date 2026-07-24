pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- super disc box
-- by farbs

version="1.0"

-- fixed palette
-- skin tones to yellow and orange
poke(0x5f2e,1) -- keep extended palette
pal(9,15+128,1) -- skin tone 1
pal(4,14+128,1) -- skin tone 2
pal(8,8+128,1) -- darker red
pal(1,2+128,1) -- darkest red
pal(11,4,1) -- ground
pal(3,4+128,1) -- ground
palt(0,false) -- black isn't transparent
palt(12,true) -- sky blue is!

-- no key repeat
poke(0x5f5c,255)

camerax=0
cameray=0

function _init()
 splash()
 title()
 music(13)
 restart()
end

function restart()
 sfx(17)
 playerx = 64
 playery = 64
 playerdx = 0
 playerdy = 0
 inputx = 0
 inputy = 0
 pspr = 6
 discs={}
 bullets={}
 weapon=pistol()
-- weapon=bazooka()
 weapons={revolver,machinegun,minigun,dualpistol,shotgun,discgun,katana,bazooka,grenadelauncher,mines,flamethrower,laserrifle}
 lastweapon=nil
 weaponcooldown=0
 boxcooldown=1
 weapongrabx=0
 weapongraby=0
 frame=0
 boxx=rnd(92)+16
 boxy=rnd(32)+16
 spawncooldown=60
 lasercooldown=0
 boxparticles()
 dead=false
 deadcooldown = 0
 restartcooldown = 0
 newhighscore=false
 showingbest=false
 score=0
 particles={}
 shake=0
 xflip=false
end

function _update60()
 if dead then
  deadcooldown-=1
  if deadcooldown<-120 then
   deadcooldown=30
   showingbest=(showingbest==false)
  end
  restartcooldown=max(restartcooldown-1,0)
 end

 -- player motion
 if dead==false then
	 inputx = 0
	 inputy = 0
	 if btnp(‹) then
	  flipx=true
	 end
	 if btnp(‘) then
	  flipx=false
	 end
	 if btn(‹) then
	  inputx -= 1
	 end
	 if btn(‘) then
	  inputx += 1
	 end 
	 if btn(”) then
	  inputy -= 1
	 end
	 if btn(ƒ) then
	  inputy += 1
	 end
	 if btnp(”) then
	  sfx(18)
	 end
	 if inputx != 0 and inputy != 0 then
	  -- chording
	  inputx *= 0.707
	  inputy *= 0.707
	 end
	 -- accelerate
	 playerdx += inputx * 1
	 playerdy += inputy * 1 + 0.25
	 -- cap speed
	 local spd = sqrt(playerdx*playerdx + playerdy*playerdy)
	 if inputx == 0 and inputy == 0 then
	  if spd <= 0.1 then
	   playerdx = 0
	   playerdy = 0
	  else
		  local spdscale = (spd-0.1)/spd
		  playerdx *= spdscale
		  playerdy *= spdscale
		 end
	 end
	 if spd > 2 then
	  playerdx *= 2 / spd
	  playerdy *= 2 / spd
	 end
	 
	 -- step
	 playerx += playerdx
	 playery += playerdy
	 
	 -- walls bounce
	 if playerx<0 then
	   playerx = 0
	   playerdx = abs(playerdx)
	  end
	  if playerx>=128 then
	   playerx = 128
	   playerdx = -abs(playerdx)
	  end
	  if playery<=0 then
	   playery = 0
	   playerdy = abs(playerdy)
	  end
	  if playery>=128 then
	   playery = 128
	   playerdy = -abs(playerdy)
	  end
	
	 
	 if inputx != 0 or inputy != 0 then
	  -- animate
	  local running = {6,8,10,12,14}
	  pspr = running[(flr(frame/3)%#running)+1]
	 else
	  local idle = {32,34,36,38,40}
	  pspr = idle[(flr(frame/4)%#idle)+1]
	 end
	 
	 -- smoke
	 if inputy < 0 then
	  local spark = oldspark()
	  spark.a=0
	  spark.cooldown=5+flr(rnd(5))
	  spark.x=playerx-1
	  spark.y=playery+2
	  if flipx then
	   spark.x+=5
	  else
	   spark.x-=5
	  end
	  spark.c=7
	  add(particles,spark)
	 end
	 
	 -- laser autofire
	 if lasercooldown>0 then
	  lasercooldown-=1
	  if lasercooldown <=0 then
    -- fire!
	   local xs = playerx
	   local xe = 0
	   if flipx then
	    xs-=4
	    xe=0
	   else
	    xs+=4
	    xe=128
	   end
	   add(bullets,makelaser(xs,xe,playery))
	   shake=max(shake,3)
	  end
	 end
	else
	 -- restart input
	 if deadcooldown<=0 and (btnp(Ž) or btnp(—)) then
	  restart()
	  return
	 end
	end
 
 -- particle update and finish
 for p in all(particles) do
  if p.update(p) == false then
   del(particles,p)
  end
 end
 
 -- check for box hit
 weaponcooldown=max(weaponcooldown-0.015,0)
 boxcooldown=max(boxcooldown-0.05,0)
 if abs(playerx-boxx)<8 and abs(playery-boxy)<8 then
  boxparticles() -- exit particles
  local boxa=rnd()
  boxx=(sin(boxa)*60+boxx-4)%120+4
  boxy=(cos(boxa)*60+boxy-4)%120+4
  boxparticles() -- entry particles  
  score+=1
  if score>$0x5e00 then
   newhighscore=true
   poke4(0x5e00,score)
  end
  
  -- new weapon!
  local options = {}
  for w in all(weapons) do
   if lastweapon!=w and (score>10 or w!=discgun) then
    add(options, w)
   end
  end
  lastweapon=options[flr(rnd()*#options)+1]
  weapon=lastweapon()
  if lastweapon==discgun then
   sfx(22)
  else
   sfx(14)
  end
  weapongrabx=playerx
  weapongraby=playery
  weaponcooldown=1
  boxcooldown=1
 end
 
 -- move discs
 for d in all(discs) do
  -- cool down or move
  if d.hitcooldown>0 then
   d.hitcooldown-=1
  end
  if d.cooldown > 0 then
   d.cooldown -= 1
  else
   -- seeking!
   if d.seek then
    local sdx = playerx-d.x
    local sdy = playery-d.y
    local sdlen = sqrt(sdx*sdx+sdy*sdy)
    d.dx *= 0.99
    d.dy *= 0.99
    if sdlen>5 then
     d.dx += sdx * 0.01 / sdlen
     d.dy += sdy * 0.01 / sdlen
    end
   end
	  d.x += d.dx
	  d.y += d.dy
	  local hit=false
	  if d.x<0 then
	   d.x = 0
	   d.dx = abs(d.dx)
	   hit=true
	  end
	  if d.x>=128 then
	   d.x = 128
	   d.dx = -abs(d.dx)
	   hit=true
	  end
	  if d.y<=0 then
	   d.y = 0
	   d.dy = abs(d.dy)
	   hit=true
	  end
	  if d.y>=128 then
	   d.y = 128
	   d.dy = -abs(d.dy)
	   hit=true
	  end
			if hit and d.r>10 then
			 shake=max(shake,4)
			 sfx(15)
			end
	  -- check for player collision
	  if dead==false then
		  local dx = playerx-d.x
		  local dy = playery-d.y
		  if dx*dx+dy*dy<(d.r+0)*(d.r+0) then
		   dead=true
		   deadcooldown=60
		   restartcooldown=60
		   sfx(16)
		   d.blood=true
		   for i=1,5 do
	 	   addsparks(d,2,10,0,1)
	 	   addsparks(d,2,20,0,1)
	 	   addsparks(d,2,30,0,1)
	 	   addsparks(d,8,40,0,1)
	 	   addsparks(d,8,50,0,1)
	 	  end
	 	  shake=15
		  end
		 end
	 end
	 -- spin regardless of movement
  d.frame = (d.frame+1)%8
 end
 
 -- spawn discs
 if dead==false then
	 spawncooldown -= 1
	 if spawncooldown <= 0 then
	  if score>=10 or #discs<max(score,1) then
		  local spawnx=rnd(128)
		  local spawny=rnd(128)
		  if rnd() < 0.5 then
		   -- three discs
				 local a = rnd()
				 local r = 1.5
	 			makedisc(7,20,false,60,spawnx,spawny,sin(a)*r,cos(a)*r)
	 			makedisc(7,20,false,75,spawnx,spawny,sin(a)*r,cos(a)*r)
	 			makedisc(7,20,false,90,spawnx,spawny,sin(a)*r,cos(a)*r)
	 		else
	 		 if rnd() < 0.5 then
	 		  -- big disc
					 local a = rnd()
					 local r = 0.75
	  	  makedisc(13,100,false,60,spawnx,spawny,sin(a)*r,cos(a)*r)
	  	 else
	  	  -- seeker
	  			makedisc(7,20,true,60,spawnx,spawny,0,0)
	  		end
	  	end
  	end
   spawncooldown = 180/(1+sqrt(score)*0.1)
	 end
  frame += 1
	end
	
	-- fire weapon
	if weapon.cooldown>0 then
	 -- cooldown, don't fire
	 weapon.cooldown-=1
	else
	 -- fire?
	 if dead==false then
		 local fire=false
		 if weapon.autofire then
		  fire=btn(—) or btn(Ž)
		 else
		  fire=btnp(—) or btnp(Ž)
		 end
		 if fire then
		  weapon.fire(weapon)
		  weapon.cooldown=weapon.fireperiod
		 end
		end
	end
	if dead==false then
 	weapon.update(weapon)
 end
	
	-- move bullets
	for b in all(bullets) do
	 if b.update(b) == false then
	  del(bullets,b)
	 end
	end
	
	-- camera motion
	camerax = camerax*0.9+(playerx-64)*0.375*0.1
	cameray = cameray*0.9+(playery-64)*0.375*0.1
 if shake>0 then
  local a=rnd()
  camerax+=sin(a)*shake*0.5
  cameray+=cos(a)*shake*0.5
  shake-=1
 end
end

function makedisc(r,health,seek,cooldown,x,y,dx,dy)
 local disc={}
 disc.x = x
 disc.y = y
 disc.r = r
 disc.seek = seek
 disc.health = health
 disc.hitcooldown=0
 disc.dx=dx
 disc.dy=dy
 disc.cooldown=cooldown
 disc.frame=flr(rnd(8))
 disc.blood=false
 add(discs, disc)
end

function _draw()
 cls(12)
 camera(camerax,cameray)
 --rectfill(0-2,0-2,128+2,128+2,0)
 --rectfill(0,0,128,128,12)

 -- background tiles
 map(0,0,-64,-64,32,32,1)
 
 -- box strings
 line(boxx-3,boxy,boxx-3,0,12)
 line(boxx-2,boxy,boxx-2,0,13)
 line(boxx-1,boxy,boxx-1,0,12)
 
 line(boxx+0,boxy,boxx+0,0,12)
 line(boxx+1,boxy,boxx+1,0,13)
 line(boxx+2,boxy,boxx+2,0,12)
 
 -- background discs
 for d in all(discs) do
  if d.cooldown>0 then
   local rx=flr(d.x-0.5)
   local ry=flr(d.y-0.5)
   circ(rx,ry,d.cooldown*0.5+d.r,13)
   circ(rx+1,ry,d.cooldown*0.5+d.r,13)
   circ(rx,ry+1,d.cooldown*0.5+d.r,13)
   circ(rx+1,ry+1,d.cooldown*0.5+d.r,13)
  end
 end
 drawdiscs(true)

 -- foreground tiles
 map(0,0,-64,-64,32,32,2)
 
 -- player
 if dead==false then
  -- body
	 spr(pspr, playerx-8, playery-8, 2, 2, flipx)

		-- weapon
		weapon.draw(weapon)
	else
	 circfill(playerx,playery,10,2)
	end
	
 -- foreground discs
 drawdiscs(false)
	
	-- box
 spr(21,boxx-4,boxy-4+boxcooldown*sin(boxcooldown)*-8)
	
	-- bullets
	for b in all(bullets) do
	 b.draw(b)
	end
	
	-- particles
	for p in all(particles) do
	 p.draw(p)
	end
	
	-- hud
	if weaponcooldown>0 then
	 local lift=((1-weaponcooldown)*0.0+1.0*(1-weaponcooldown)*(1-weaponcooldown))*-128
	 shadowprint(weapon.name,weapongrabx-#(weapon.name)*2,weapongraby-16+lift,7)
	end
	camera()
	if dead==false then
  scoreprint(score,64,2,2,newhighscore,true)
	else
	 -- background
	 rectfill(0,32,128,98,1)

	 -- game over
	 local write=min(60-deadcooldown,30)*2
	 pal(7,0)
	 sspr(1,122,write,5,64-write,32+8+2,write*2,10)
	 pal(7,7)
	 sspr(1,122,write,5,64-write,32+8,write*2,10)
	 
	 -- boxes:/best:
	 local box={33,116,37,5}
	 local number=score
	 local exclaim=newhighscore
	 if showingbest then
	  box={1,116,30,5}
	  number=$0x5e00
	  exclaim=false
	 end
	 local numstr=tostr(number)
	 local width=box[3]*2+4+(#numstr)*7*2+2
	 if exclaim then
	  width += 7*2
	 end
  write=min(max(30-deadcooldown,0),30)*width/30
  local y=32+8+10+6
	 pal(7,0)
	 sspr(box[1],box[2],box[3],box[4],64-write*0.5,y+2,box[3]*2,10)
	 pal(7,7)
	 sspr(box[1],box[2],box[3],box[4],64-write*0.5,y,box[3]*2,10)
	 scoreprint(number,64-write*0.5+box[3]*2+8,y,2,exclaim,false)
	 rectfill(64+write*0.5,y,y+128,y+12,1) -- hiding rect
	 local message="don't touch the discs!"
	 if newhighscore then
 	 message="new high score!"
 	elseif score>=10 then
  	 message="only " .. tostr($0x5e00-score+1) .. " to new highscore!"
 	end
 	shadowprintcentered(message, 64, 32+12+20+12, 7)
	 shadowprintcentered("press Ž or — to restart",64-4,32+12+20+12+8,7)
	end
end

function drawdiscs(background)
 for d in all(discs) do
  if (d.cooldown > 0 and background) or (d.cooldown==0 and background==false) then
	  if d.cooldown > 0 then
	   pal(0,13)
	   pal(1,12)
	   pal(7,12)
	   pal(6,12)
	   pal(5,12)
	  end
	  if d.blood or d.hitcooldown > 0 then
	   pal(7,14)
	   pal(6,8)
	   pal(5,2)
	  end
	  if d.seek==false then
	   if d.r>10 then
	  	 spr(64+flr(d.frame/2)*4, d.x-16, d.y-16, 4, 4, d.dx<0)
	  	else
	  	 spr(160+flr(d.frame/2)*2, d.x-8, d.y-8, 2, 2, d.dx<0)
	  	end
	  else
	 	 spr(168+flr(d.frame/2)*2, d.x-8, d.y-8, 2, 2, playerx<d.x)
	  end
		 pal(0,0)
		 pal(1,1)
		 pal(7,7)
		 pal(6,6)
		 pal(5,5)
		end
	end
end

function prettyprint(string, x, y, c)
 print(string,x-1,y-1,0)
 print(string,x,y-1,0)
 print(string,x+1,y-1,0)
 print(string,x-1,y,0)
 print(string,x+1,y,0)
 print(string,x-1,y+1,0)
 print(string,x,y+1,0)
 print(string,x+1,y+1,0)
 print(string,x,y,c)
end

function shadowprintcentered(string, x, y, c)
 local xc=x-(#string)*2
 shadowprint(string, xc, y, c)
end

function shadowprint(string, x, y, c)
 print(string,x,y+1,0)
 print(string,x,y,c)
end

function scoreprint(number,x,y,scale,exclaim,center)
 local chars=tostr(number)
 if exclaim then
  chars=chars.."!"
 end
 for i=1,#chars do
  local char=sub(chars,i,i)
  local sx=0
  if char=="0" then
   sx=0
  elseif char=="1" then
   sx=1
  elseif char=="2" then
   sx=2
  elseif char=="3" then
   sx=3
  elseif char=="4" then
   sx=4
  elseif char=="5" then
   sx=5
  elseif char=="6" then
   sx=6
  elseif char=="7" then
   sx=7
  elseif char=="8" then
   sx=8
  elseif char=="9" then
   sx=9
  elseif char=="!" then
   sx=10
  end
  sx=sx*4+1
  local startx=x+7*(i-1)*scale
  if center then
   startx=x-#chars*3.5*scale+7*(i-1)*scale
  end
  pal(7,0)
  sspr(sx,97,3,5,startx,y+2,6*scale,5*scale)
  pal(7,7)
  sspr(sx,97,3,5,startx,y,6*scale,5*scale)
 end
end

-->8
-- weapons
function defaultweapon()
 local default={}
 default.autofire=false
 default.cooldown=0
 default.name="unnamed"
 default.sprite=128
 default.sprwidth=1
 default.sprheight=1
 default.sprx=0
 default.spry=0
 default.update = function()
 end
 default.draw = function(w)
  local drawx = playerx
  local drawy = playery-4+w.spry
  if flipx then
   drawx-=4+8+w.sprx+8*(w.sprwidth-1)
  else
   drawx+=4+w.sprx
  end
  spr(w.sprite,drawx,drawy,w.sprwidth,w.sprheight,flipx)
 end
 return default
end

function knockback(dx)
 if flipx then
  playerdx+=dx
 else
  playerdx-=dx
 end
end

function pistol()
 local pistol=defaultweapon()
 pistol.fireperiod=6
 pistol.name="pistol"
 pistol.sprx=-1
 
 pistol.fire = function(r)
  local bx = 7
  local bdx = 4
  local by = 0
  local bdy = 0
  if flipx then
   bx = -bx
   bdx = -bdx
  end
  add(bullets,makebullet(playerx+bx,playery+by,bdx,bdy,10))
  shake=max(shake,2)
  knockback(1)
  sfx(19)
 end
 return pistol
end

function revolver()
 local revolver=defaultweapon()
 revolver.fireperiod=6
 revolver.name="revolver"
 revolver.sprite=150
 revolver.sprwidth=2
 
 revolver.fire = function(r)
  local bx = 7
  local bdx = 4
  local by = 0
  local bdy = 0
  if flipx then
   bx = -bx
   bdx = -bdx
  end
  local bullet=makebullet(playerx+bx,playery+by,bdx,bdy,50)
  bullet.sprite=130
  add(bullets,bullet)
  shake=max(shake,5)
  knockback(1)
  sfx(20)
 end
 return revolver
end

function machinegun()
 local machinegun=defaultweapon()
 machinegun.fireperiod=4
 machinegun.autofire=true
 machinegun.name="machinegun"
 machinegun.sprite=144
 machinegun.sprwidth=2
 machinegun.sprx=-4
 
 machinegun.fire = function(r)
  local bx = 7
  local bdx = 4
  local by = 0
  local bdy = rnd()*0.5-0.25
  if flipx then
   bx = -bx
   bdx = -bdx
  end
  add(bullets,makebullet(playerx+bx,playery+by,bdx,bdy,10))
  shake=max(shake,2)
  knockback(1)
  sfx(19,2)
 end
 return machinegun
end

function minigun()
 local minigun=defaultweapon()
 minigun.fireperiod=1
 minigun.autofire=true
 minigun.name="minigun"
 minigun.sprite=140
 minigun.sprx=-3
 minigun.spry=-8
 minigun.sprwidth=2
 minigun.sprheight=2
 
 minigun.fire = function(r)
  for i=1,3 do
	  local bx = 11
	  local bdx = 8
	  local by = 0
	  local bdy = rnd()*8-4
	  if flipx then
	   bx = -bx
	   bdx = -bdx
	  end
	  add(bullets,makebullet(playerx+bx,playery+by,bdx,bdy,5))
	 end
	 shake=max(shake,5)
  knockback(2)
  sfx(19,2)
 end
 return minigun
end

function dualpistol()
 local dualpistol=defaultweapon()
 dualpistol.fireperiod=6
 dualpistol.name="dual pistol"
 
 dualpistol.draw = function(r)
  local drawx = playerx
  local drawy = playery-4
  spr(128,drawx+3,drawy,1,1,false)
  spr(128,drawx-11,drawy,1,1,true)
 end
 
 dualpistol.fire = function(r)
  local bx = 7
  local bdx = 4
  local by = 0
  local bdy = 0
  add(bullets,makebullet(playerx+bx,playery+by,bdx,bdy,10))
  add(bullets,makebullet(playerx-bx,playery+by,-bdx,bdy,10))
  shake=max(shake,2)
  sfx(19)
 end
 return dualpistol
end

function shotgun()
 local shotgun=defaultweapon()
 shotgun.fireperiod=30
 shotgun.name="shotgun"
 shotgun.sprite=148
 shotgun.sprwidth=2
 shotgun.sprx=-5
 shotgun.spry=1
 
 shotgun.fire = function(r)
  for i=1,9 do
	  local bx = 7
	  local bdx = 2+rnd()*12
	  local by = 0
	  local bdy = rnd()*4-2
	  if flipx then
	   bx = -bx
	   bdx = -bdx
	  end
	  local b = makebullet(playerx+bx,playery+by,bdx,bdy,10)
	  b.drag=0.7
	  add(bullets,b)
	 end
  shake=max(shake,3)
  knockback(2)
  sfx(21)
 end
 return shotgun
end

function discgun()
 local discgun=defaultweapon()
 discgun.fireperiod=6
 discgun.name="disc gun?!"
 discgun.sprite=154
 discgun.sprx=-2
 
 discgun.fire = function(r)
  local bx = 7
  local bdx = 3
  local by = 0
  local bdy = 0
  if flipx then
   bx = -bx
   bdx = -bdx
  end
		makedisc(7,20,false,0,playerx+bx,playery+by,bdx,bdy)
  shake=max(shake,2)
  knockback(5)
  sfx(23)
 end
 return discgun
end

function katana()
 local katana=defaultweapon()
 katana.fireperiod=12
 katana.name="katana"
 katana.basedraw=katana.draw
 
 katana.draw = function(k)
  if k.cooldown==0 then
   k.sprite=198
   k.sprheight=2
   k.sprwidth=1
   k.sprx=-4
   k.spry=-1
  else
   k.sprite=199
   k.sprheight=1
   k.sprwidth=2
   k.sprx=3
   k.spry=0
  end
  k.basedraw(k)
 end
 
 katana.fire = function(r)
  local bx=16
  if flipx then
   bx = -bx
  end
  for d in all(discs) do
   if d.cooldown==0 then
	   local dx=max(abs(playerx+bx-d.x)-16,0)
	   local dy=playery-d.y
	   if dx*dx+dy*dy<(d.r+8)*(d.r+8) then
	    -- hit compressed space
	    hitdisc(d,50)
	    
	    if flipx then
	     d.dx=-abs(d.dx)
	    else
	     d.dx=abs(d.dx)
	    end
	   end
	  end
  end
  shake=max(shake,2)
  sfx(35)
 end
 return katana
end

function bazooka()
 local bazooka=defaultweapon()
 bazooka.fireperiod=60
 bazooka.name="bazooka"
 bazooka.sprite=146
 bazooka.sprwidth=2
 bazooka.sprx=-6
 
 bazooka.fire = function(r)
  local bx = 9
  local bdx = 1
  if flipx then
   bx = -bx
   bdx = -bdx
  end
  add(bullets,makeshell(playerx+bx,playery,bdx))
  shake=max(shake,3)
  sfx(36)
 end
 return bazooka
end

function grenadelauncher()
 local gl=defaultweapon()
 gl.fireperiod=60
 gl.name="grenade launcher"
 gl.sprite=158
 gl.sprwidth=2
 gl.sprx=-4
 
 gl.fire = function(g)
  local bx = 7
  local bdx = 3
  if flipx then
   bx = -bx
   bdx = -bdx
  end
  add(bullets,makegrenade(playerx+bx,playery,bdx))
  sfx(37)
 end
 return gl
end

function mines()
 local mines=defaultweapon()
 mines.fireperiod=60
 mines.name="mines"
 
 mines.draw = function(m)
  local drawx = playerx
  local drawy = playery
  pal(8,0)
  spr(137,drawx-4,drawy,1,1)
  pal(8,8)
 end
 
 mines.fire = function(m)
  add(bullets,makemine(playerx,playery+4))
  sfx(38)
 end
 return mines
end

function flamethrower()
 local ft=defaultweapon()
 ft.fireperiod=0
 ft.autofire=true
 ft.name="flamethrower"
 ft.sprite=152
 ft.sprwidth=2
 ft.sprx=-2
 ft.spry=0
 
 ft.fire = function(f)
  local bx = 7
  local bdx = 6+rnd()*3-1.5
  local bdy = -rnd()*2
  if flipx then
   bx = -bx
   bdx = -bdx
  end
  add(bullets,makeflame(playerx+bx,playery,bdx,bdy))
  sfx(39,2)
 end
 return ft
end

function laserrifle()
 local laserrifle=defaultweapon()
 laserrifle.fireperiod=60
 laserrifle.name="laser rifle"
 laserrifle.basedraw=laserrifle.draw
 
 laserrifle.update = function(l)
  if l.cooldown > 30 then
   -- collide with discs
   local hitx=playerx
   if flipx then
    hitx-=8
   else
    hitx+=8
   end
	  for d in all(discs) do
	   if d.cooldown==0 then
		   local dx=max(abs(d.x-hitx)-4,0)
		   local dy=playery-d.y
		   if dx*dx+dy*dy<(d.r+3)*(d.r+3) then
		    -- hit compressed space
		    hitdisc(d,100)
	    end
	   end
	  end
  end
 end
 
 laserrifle.draw = function(l)
  if l.cooldown>30 then
   l.sprite=138
   l.sprwidth=1
   l.sprx=5
   l.basedraw(l)
  end
  l.sprite=201
  l.sprwidth=2
  l.sprx=-3
  l.basedraw(l)
 end
 
 laserrifle.fire = function(l)
  sfx(40)
  lasercooldown=30
 end
 
 return laserrifle
end

-->8
-- bullets
function makebullet(x, y, dx, dy, damage)
 local bullet={}
 bullet.lastx = x
 bullet.x = x
 bullet.lasty = y
 bullet.y = y
 bullet.dx = dx
 bullet.dy = dy
 bullet.damage = damage
 bullet.drag=1
 bullet.sprite=129
 
 bullet.draw = function(b)
  spr(b.sprite,b.x-4,b.y-4)
  --line(b.lastx,b.lasty,b.x,b.y,7)
 end
 
 bullet.update = function(b)
  -- move
  b.lastx=b.x
  b.lasty=b.y
  b.x+=b.dx
  b.y+=b.dy
  b.dx *= b.drag
  b.dy *= b.drag
  
  -- collide with discs
  local hit=first_ray_hit(b.lastx,b.lasty,b.x,b.y,2)
  if hit != nil then
   hitdisc(hit,b.damage)
   return false
  end
  
  -- collide with edges
  local alive=b.x>=-2 and b.x<=129 and b.y>=-2 and b.y<=129
  if b.drag < 1 then
   if abs(b.dx)<0.1 and abs(b.dy)<0.1 then
    alive = false
   end
  end
  return alive
 end
 
 return bullet
end

-- bazooka shell
function makeshell(x, y, dx)
 local shell=makebullet(x, y, dx, 0, 0)
 shell.bulletupdate=shell.update
 shell.smokecooldown=0
 shell.update=function(s)
  -- regular bullet update
  local alive = s.bulletupdate(s)
  
  -- now speed up
  s.dx+=sgn(s.dx)*0.1
  
  -- if done, explode
  if alive==false then
   add(bullets,makeexplosion(s.x,s.y,20,30,30))
  else
   -- still going, smoke
   s.smokecooldown-=1
   if s.smokecooldown<=0 then
    add(particles,smokepuff(s.x,s.y,2,0.025,0))
    s.smokecooldown=4+rnd()*2
   end
  end
  
  -- return whether alive
  return alive
 end
 
 shell.draw = function(s)
  spr(131,s.x-4,s.y-4,1,1,s.dx<0)
 end
 

 return shell
end

-- grenade
function makegrenade(x, y, dx)
 local grenade={}
 grenade.lastx = x
 grenade.x = x
 grenade.lasty = y
 grenade.y = y
 grenade.dx = dx
 grenade.dy = -2
 grenade.fuse=60
 
 grenade.draw = function(g)
  spr(132,g.x-3.5,g.y-3.5)
 end
 
 grenade.update = function(g)
  -- move
  g.lastx=g.x
  g.lasty=g.y
  g.x+=g.dx
  g.y+=g.dy
  g.dy+=0.2
  
  -- collide with discs
  local hit=first_ray_hit(g.lastx,g.lasty,g.x,g.y,2)
  if hit != nil then
   g.fuse=0
  end
  
  -- bounce off edges
  if g.x<=0 then
   g.dx=abs(g.dx)*0.75
  end
  if g.x>=128 then
   g.dx=-abs(g.dx)*0.75
  end
  if g.y<=0 then
   g.dy=abs(g.dy)*0.75
  end
  if g.y>=128 then
   g.dy=-abs(g.dy)*0.75
  end
  
	 -- fuse!
	 g.fuse-=1
	 if g.fuse<=0 then
	  add(bullets,makeexplosion(g.x,g.y,20,30,30))
	  return false
	 else
	  return true
	 end
 end 
 
 return grenade
end

-- mine
function makemine(x, y)
 local mine={}
 mine.x = x
 mine.lasty = y
 mine.y = y
 mine.dy = 0
 mine.fuse=60
 
 mine.draw = function(m)
  if m.fuse>0 or frame%16<8 then
   pal(8,0)
  end
  spr(137,m.x-4,m.y-4)
  pal(8,8)
 end
 
 mine.update = function(m)
  -- move
  m.lasty=m.y
  m.y+=m.dy
  m.dy+=0.2
  if m.y>128 then
   m.y=128
   m.dy=0
  end
  
  -- fuse
  if m.fuse>0 then
   m.fuse-=1
  end
  
  -- collide with discs
  local alive=true
  if m.fuse<=0 then
	  local hit=first_ray_hit(m.x,m.lasty,m.x,m.y,3)
	  if hit != nil then
 	  add(bullets,makeexplosion(m.x,m.y,20,30,30))
 	  alive=false
	  end
  end
  return alive
 end
 
 return mine
end

-- flame
function makeflame(x, y, dx, dy)
 local flame={}
 flame.lastx = x
 flame.x = x
 flame.lasty = y
 flame.y = y
 flame.dx = dx
 flame.dy = dy
 flame.fuse=60

 flame.calcradius = function(f)
  flame.radius=(30-abs(flame.fuse-30))*0.375+2
 end
 flame.calcradius(flame)
 
 flame.draw = function(f)
  if rnd()<0.5 then
   if rnd()<0.5 then
    pal(7,10)
   else
    pal(7,8)
   end
  elseif rnd()<0.5 then
   pal(7,4)
  end
  sspr(40+flr(rnd()*4)*8,64,8,8,f.x-f.radius,f.y-f.radius,f.radius*2,f.radius*2,rnd()<0.5,false)
  pal(7,7)
 end
 
 flame.update = function(f)
  f.calcradius(f)
 
  -- move
  f.lastx=f.x
  f.lasty=f.y
  f.x+=f.dx
  f.y+=f.dy
  f.dy+=0.2
  f.dx*=0.9
  f.dy*=0.9
  
  -- collide with discs
  if rnd()<0.5 then
	  local hit=first_ray_hit(f.lastx,f.lasty,f.x,f.y,f.radius)
	  if hit != nil then
	   hitdisc(hit,1)
	  end
	 end
  
  -- bounce off edges
  if f.x<=0 then
   f.dx=abs(f.dx)
  end
  if f.x>=128 then
   f.dx=-abs(f.dx)
  end
  if f.y<=0 then
   f.dy=abs(f.dy)
  end
  if f.y>=128 then
   f.dy=-abs(f.dy)
  end
  
	 -- fuse!
	 f.fuse-=1
	 if f.fuse<=0 then
	  return false
	 else
	  return true
	 end
 end 
 
 return flame
end

-- lasers
function makelaser(xs, xe, y)
 local laser={}
 laser.xs = xs
 laser.xe = xe
 laser.y = y
 laser.cooldown=30
 
 laser.draw = function(l)
  sspr(88+5-flr(laser.cooldown/5),64,1,8,xs,y-4,xe-xs,8)
 end
 
 laser.update = function(l)
  -- collide with discs
  for d in all(discs) do
   if d.cooldown==0 then
	   local dx=max(abs(d.x-(l.xs+l.xe)*0.5)-abs(l.xs-l.xe)*0.5,0)
	   local dy=l.y-d.y
	   if dx*dx+dy*dy<(d.r+3)*(d.r+3) then
	    -- hit compressed space
	    hitdisc(d,100)
    end
   end
  end
  
  -- age
  laser.cooldown-=1
  return laser.cooldown>0
 end

 return laser
end


-- explosion
function makeexplosion(x,y,sr,er,p)
 local explosion={}
 explosion.x=x
 explosion.y=y
 explosion.sr=sr
 explosion.er=er
 explosion.p=p
 explosion.a=0
 shake=max(shake,10)
 sfx(12)
 
 explosion.draw = function(e)
  local col=7
  local alpha=e.a/e.p
  local radius=e.sr+(e.er-e.sr)*alpha
  if alpha>0.5 then
   col=0
  end
  circfill(e.x,e.y,radius,col)
 end
 
 explosion.update = function(e)
  e.a+=1
  local alpha=e.a/e.p  
  local radius=e.sr+(e.er-e.sr)*alpha
  for d in all(discs) do
   if d.cooldown<=0 then
	   local dx=d.x-e.x
	   local dy=d.y-e.y
	   if dx*dx+dy*dy<=(d.r+radius)*(d.r+radius) then
	    hitdisc(d,100)
	   end
	  end
		end
  return e.a<e.p
 end
 
 return explosion
end

-- util
function hitdisc(hit,damage)
 hit.health-=damage
 hit.hitcooldown=4
 if hit.health <= 0 then
		del(discs,hit)
	 addnewsparks(hit,2,0,1)
	 addnewsparks(hit,4,0,1)
	 addnewsparks(hit,8,0,1)
	 addnewsparks(hit,16,0,1)
  add(particles,makeflash(hit.x,hit.y,hit.r,10,5))
  -- death sound
  if hit.r<10 then
   if hit.seek then
    sfx(11)
   else
    sfx(10)
   end
  else
   sfx(13)
  end
 else
  -- damage sound
  sfx(9)
 end
end
-->8
-- collision utils
function first_ray_hit(xs, ys, xe, ye, r)
 local nearest=nil
 local nearest_dist=0
 local x=(xs+xe)*0.5
 local y=(ys+ye)*0.5
 local rdx=(xe-xs)*0.5
 local rdy=(ye-ys)*0.5
 local rlen = sqrt(rdx*rdx+rdy*rdy)
 for d in all(discs) do
  -- skip during cooldown :d
  if d.cooldown==0 then
	  -- get offset
	  local dx = d.x-x
	  local dy = d.y-y
	  
	  -- if zero length
	  -- otherwise do ray
	  if rlen==0 then
	   -- zero length, use radius
	   local sqdist=dx*dx+dy*dy
	   if (nearest==nil or sqdist < nearest_dist ) and sqdist<=(d.r+r)*(d.r+r) then
	    -- hit and nearest!
	    nearest = d
	    nearest_dist=sqdist
	   end
	  else
	   -- get offset in r space
	   local rsda=(dx*rdx+dy*rdy)/rlen
	   local rsdb=(dx*rdy-dy*rdx)/rlen
	   local comp_rsda=max(abs(rsda)-rlen,0)
	   if (nearest==nil or rsda < nearest_dist ) and comp_rsda*comp_rsda+rsdb*rsdb<=(d.r+r)*(d.r+r) then
	    -- hit and nearest!
	    nearest = d
	    nearest_dist=rsda
	   end   
	  end
	 end
	end
 
 -- return best hit
 return nearest
end
-->8
-- particles
function nullparticle()
 local particle={}
 particle.update = function(p)
  return false
 end
 particle.draw = function(p)
 end
 return particle
end

function oldspark()
 local spark=nullparticle()
 spark.update=function(s)
  s.oldx=s.x
  s.oldy=s.y
  s.cooldown=max(s.cooldown-1,0)
  s.x += sin(s.a)*s.cooldown*0.1
  s.y += cos(s.a)*s.cooldown*0.1
  return s.cooldown>0 or (s.c!=7 and s.c!=10)
 end
 spark.draw=function(s)
	 if s.cooldown > 0 then
	  local offsets={}
	  if s.c != 10 and s.c != 7 then
	   offsets={{0,0},{-1,0},{1,0},{0,-1},{0,1}}
	  else
	   offsets={{0,0},{0,1},{1,0},{1,1}}
	  end
	  for o in all(offsets) do
			 line(s.x+o[1], s.y+o[2], s.oldx+o[1], s.oldy+o[2], s.c)
			end
		else
		 circfill(s.x,s.y,2,2)
		end
	end
 return spark
end

function addsparks(d,c,minspeed,amin,amax)
 local ao=rnd()
 for i=1,8 do
  local spark = oldspark()
  spark.a=((ao+i/8)%1)*(amax-amin)+amin
  spark.cooldown=minspeed+flr(rnd(60)*rnd())
  spark.x=d.x+sin(spark.a-0.25)*d.r
  spark.y=d.y+cos(spark.a-0.25)*d.r
  spark.c=c
  spark.update(spark)
  add(particles,spark)
 end
end

function addnewsparks(d,minspeed,amin,amax)
 local ao=rnd()
 for i=1,8 do
  local a=((ao+i/8)%1)*(amax-amin)+amin
  local spark = newspark(d.x+sin(a-0.25)*d.r,d.y+cos(a-0.25)*d.r,a,minspeed+flr(rnd(6)*rnd()),d.r>10)
  spark.update(spark)
  add(particles,spark)
 end
end

function smokepuff(x,y,o,delta,lift)
 local puff=nullparticle()
 local a = rnd()
 local r = rnd()*o
 puff.x=x+sin(a)*o
 puff.y=y+cos(a)*o
 puff.age=0
 puff.delta=delta
 puff.lift=lift
 puff.update=function(p)
  p.age+=p.delta
  p.y-=p.lift
  return p.age<1
 end
 puff.draw=function(p)
  local r=(1-p.age)*6
  if r>4 then
 	 circfill(p.x,p.y+2,r,0)
 	end
  if r>2 then
 	 circfill(p.x,p.y+1,r,0)
	 end
	 circfill(p.x,p.y,r,5)
	end
 return puff
end

function boxparticles()
 for i=1,3 do
  add(particles,smokepuff(boxx,boxy,8,rnd()*0.05+0.025,1))
 end
end

function newspark(x,y,a,spd,big)
 local spark=nullparticle()
 spark.x=x
 spark.y=y
 spark.dx=sin(a)*spd
 spark.dy=cos(a)*spd
 if big then
  spark.offsets={{0,0},{-1,0},{1,0},{0,-1},{0,1}}
 else
  spark.offsets={{0,0},{0,1},{1,0},{1,1}}
 end
 
 spark.update=function(s)
  s.oldx=s.x
  s.oldy=s.y
  s.x += s.dx
  s.y += s.dy
  s.dy+=0.25
  return s.y<128
 end
 spark.draw=function(s)
  for o in all(s.offsets) do
		 line(s.x+o[1], s.y+o[2], s.oldx+o[1], s.oldy+o[2], 10)
		end
	 line(s.x, s.y, s.oldx, s.oldy, 10)
	end
 return spark
end

function makeflash(x,y,r,c,period)
 local flash=nullparticle()
 flash.x=x
 flash.y=y
 flash.r=r
 flash.c=c
 flash.cooldown=period
 flash.first=2

 flash.update=function(f)
  f.cooldown-=1
  return f.cooldown>0
 end
 
 flash.draw=function(f)
  local c=f.c
  -- white flash at first
  if f.first>0 then
   c=7
   f.first-=1
  end
	 circfill(f.x,f.y,f.r+f.cooldown-5,c)
	end
	
 return flash
end
-->8
-- menus
function splash()
 sfx(8)
 while btnp(Ž)==false and btnp(—)==false and time()<8 do
  cls(0)
  local string="fARBS"
  local len=flr(min(max(time()*6-6,0),#string))
  len=max(min(len,30-time()*6),0)
  string=sub(string,0,len)
  if (time()*4)%2<1 then
   string=string.."_"
  end
  if time()<7 then
   print(string,64-6*2,64-5,7)
  end
  if time()>=7 then
    sfx(-1)
  end
  flip()
 end
 cls(0)
 flip()
 sfx(-1)
end

function title()
 music(23)
 local scroll=0
 local frame=0
 while btnp(Ž)==false and btnp(—)==false do
  cls(12)
  camera(scroll,0)
  map(32,0,0,0,16*6,16)
  print("… V" .. version .. " … game: fARBS … music: gRUBER  thanks: fARBS jR, lAN, dINOpUNCHER, pYJAMADS ‡ greetz: dISC rOOM tEAM & vLAMBEER •", 128, 120, 9)
  
  camera()
  local alpha=min(frame/30,1)
  alpha=(1-sqrt(1-alpha*alpha))
  local scale=alpha*3+cos(frame/60)*1*(1-alpha)
  if frame>30 and frame<45 then
   alpha=1-(frame-30)/15
   alpha*=alpha*alpha
   camera(rnd()*alpha*10, rnd()*alpha*10)
  end
  pal(15,0)
  pal(4,0)
  pal(8,0)
  pal(2,0)
  for i=0,scale,0.1 do
   drawlogo(i)
  end
  pal(15,15)
  pal(4,4)
  pal(8,8)
  pal(2,2)
  drawlogo(scale)
  
  -- prompt to start
  if frame>120 and (frame%30<15) then
   prettyprint("press Ž or — to start",64-2*22, 80,7)
  end
  
  flip()
  scroll=(scroll+1)%(16*5*8)
  frame+=1
 end
end

function drawlogo(scale)
 local sw=36
 local sh=19
 sspr(88,96,sw,sh,64-sw*scale*0.5, 64-sh*scale*0.5-scale*9,sw*scale,sh*scale)
end
__gfx__
00000000888888888112228281122282ddddddddddcccdddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000222222228112228281621682ddddddddddccddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00700700111ccc118112228281121182dddcccddddcdddddccccccccccc0ccccccccc00c0000ccccccccc00c0000ccccccccccccccc0cccccccccccccccccccc
00077000c111c1118112228281122282cdddcddddddddcddccccc00c0000cccccccc000000000ccccccc00000000ccccccccc00c0000ccccccccc00c0000cccc
00077000cc22222c8112228281122282ccdddddcddddccddcccc00000000ccccccc000444440ccccccc000444440cccccccc00000000cccccccc00000000cccc
00700700ccc222cc8112228281621682cccdddccdddddcddccc000444440cccccc0709fffee0cccccc0709fffee0ccccccc000444440ccccccc000444440cccc
00000000888888888112228281121182ddddddddddcdddddcc0709ffeef0cccccc0609f0fee0cccccc0609f0fee0cccccc0709fffee0cccccc0709ffeef0cccc
00000000222222228112228281122282ddddddddddccddddcc06090fee00cccccc0509fffee0cccccc0509fffee0cccccc0609f0fee0cccccc06090fee00cccc
bbbbb9bbbb93339b4944994499949994ffffffff00000000cc0009ffeef0cccccc000400fff0cccccc0000440ff0cccccc0509fffee0cccccc0509ffeef0cccc
33333933339111939f94ff99f999ff99ffffffff0bffffb0cc00449ffff0cccccccc00400000cccccccc00000000cccccc000400fff0cccccc00049ffff0cccc
33333933339111939ff9fffff9f9ff9fffffffff0b3333b0cccc00000040ccccccccc00cc00cccccccccccc00ccccccccccc00040000ccccccc0440000040ccc
9999999999999999ffffffffffffffffffffffff0bbbbbb0cccccccccc00ccccccccccccc0ccccccccccccc0ccccccccccccccc00cccccccccc000ccccc00ccc
3393333333339333f9ffffffffffffffffffffff0bbbbbb0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
3343333333334333ffffff9fffffffffffffffff0bffffb0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
3343333333334333ffffffffffffffffffffffff03333330cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
4444444444444444ffffffffffffffffffffffff00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc00cccccccccccccc00c0000cccccccccccccccc0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc00000000cccccccc000000000cccccccc00c00000cccccccc00c00000ccccccc00000000cccccccccccccccccccccccc0cccccccccccccccc00c0000cccc
ccc0004444000cccccc000444440cccccccc00000000cccccccc00000000ccccccc0000440000cccccccc00cc00cccccccc00000000ccccccccc000000000ccc
cc0709ffeef0cccccc0709ffeef0ccccccc000444440ccccccc000444440cccccc0709ffeef0cccccccc04000040ccccccc004f0ff40ccccccc000444440cccc
cc06090fee00cccccc06090fee00cccccc0709ffeef0cccccc0709ffeef0cccccc06090fee00cccccccc0ffff94000ccccc004eeef00cccccc0709ffeef0cccc
cc0509ffeef0cccccc0509ffeef0cccccc06090fee00cccccc06090fee00cccccc0509ffeef0cccccccc0feeff9050ccccc004eeef0ccccccc06090fee00cccc
cc00049ffff0cccccc00049ffff0cccccc0509ffeef0cccccc0509ffeef0cccccc00049ffff0cccccccc00eef09060cccccc04ffff0ccccccc0509ffeef0cccc
cccc04000040cccccccc04000040cccccc00049ffff0cccccc00049ffff0cccccccc04000040cccccccc0feeff9070ccccc004f0f900cccccc00049ffff0cccc
cccc00cccc00cccccccc00cccc00cccccccc04000040cccccccc04000040cccccccc00cccc00cccccccc044444000cccccc000999440cccccccc04000040cccc
cccc0ccccc0ccccccccc0ccccc0ccccccccc00cccc00cccccccc00cccc00cccccccc0ccccc0cccccccc000000000cccccccc0000000cccccccccc00cc00ccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000c00cccccccccc07650cccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000cccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccc00cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00ccccccccccccccccc
cccccccccccccc000cccccccccccccccccccccccccccccccc000cccccccccccccccccccccc00cccccccc00cccccccccccccccccccccc000ccccccccccccccccc
cccccccccccccc000ccccccccccccccccccccccc00cccccc0000cccccccccccccccccccccc000ccccc0000cccccccccccccccccccccc000ccccccccccccccccc
ccccccccccccc0000ccccccccccccccccccccccc00cccc000000ccccccccccccccccccccc0000ccc000000ccccccccccccccccccccc0000cccc00000cccccccc
cccccc00cccc00000c00000000cccccccccccccc000cc000000cccccccccccccccccccccc000000000000cccccccccccccccccccccc0000000000000cccccccc
cccccc000cc0006000000000000ccccccccccccc000000006000000cccccccccccccccccc006000000000ccccccccccccccccccccc0000000000000ccccccccc
cccccc00000006600000000000ccccccccccccc000000066600000000000ccccccccccccc00600066600000ccccccccccccc000cc00066006666000ccccccccc
cccccc0000006666666666000cccccccccccccc000600666666660000000cccccccccccc000666666660000000cccccccccc0000c000666666660000cccccccc
cccccc000006666666666000ccccccccccccccc00066666666666650000cccccccc000cc006666666666660000000cccccccc00000066666666660000ccccccc
cccccc0006666656665666000cccccccccccccc0066666566656660000ccccccccc00000006666566656666500000cccccccc0000066665666566600000ccccc
cccccc000666666565666660000cccccccccccc006666665656666000ccccccccccc0000006666656566666000000cccccccc000006666656566666500000ccc
cccccc0006666665656666660000cccccc000000066666656566666000cccccccccc0000066666656566666000ccccccccccc0006666666565666665500000cc
cccccc00061001155510016550000cccccc000000610011555100166000cccccccccc005661001155510016000cccccccccccc005610011555100160000000cc
cc0000000650056555600665000000cccccc000006500565556006655000ccccccccc000565005655560066600cccccccccccc005650056555600660000ccccc
cc0000000665566010655660000000cccccc0005566556601065566555000ccccccccc005665566010655665000ccccccccccc00066556601065566600cccccc
ccc00005566666506066666000ccccccccccc000556666506066666000000ccccccccc000666665060666665000cccccccc00000066666506066666600cccccc
cccc0000556666666666666600cccccccccccc000566666666666660000000cccccccc0006666666666666500000ccccccc000000666666666666655000ccccc
ccccc000055666666666655600ccccccccccccc000666666666666600cccccccccccc000056666666666665000000cccccc000005556666666666555500ccccc
ccccccc0005666666666555500ccccccccccccc000666666666555600cccccccccc00000055556666666660000000cccccccc0000555666666666500500ccccc
cccccccc000666555665500500cccccccccccc0000555556665555600cccccccccc000000055556665556500cc000ccccccccc0000055666655650000000cccc
cccccccc000555555655000000ccccccccccc00005555555655000500cccccccccccc0000000056655555500cccccccccccccccc00005555555650000000cccc
ccccccc0000555000650000000cccccccccc000000000005550000500ccccccccccccccc0000005550005000cccccccccccccccccc0005555005000cc000cccc
cccccc000000000005000cc000cccccccccccc0000000000500000000ccccccccccccccccccc00550000000cccccccccccccccccc0000000000500cccccccccc
cccccc000000000005000ccc00ccccccccccccccccccc000000cc0000cccccccccccccccccc0000000c0000cccccccccccccccccc0000000000000cccccccccc
ccccccccccccccc00000ccccccccccccccccccccccccc00000cccc000cccccccccccccccccc000000cc0000ccccccccccccccccc000000ccc0000ccccccccccc
ccccccccccccccc0000cccccccccccccccccccccccccc0000cccccc0cccccccccccccccccc00000ccccc000ccccccccccccccccc000cccccc0000ccccccccccc
ccccccccccccccc000ccccccccccccccccccccccccccc000cccccccccccccccccccccccccc000ccccccc00cccccccccccccccccccccccccccc00cccccccccccc
ccccccccccccccc00cccccccccccccccccccccccccccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00cccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc000ccccccccccccccccccccc7c7cccccccccccccc7c7ccccc77cccccc00cccaaaaaaacaacccccccccccccccccccccccccccccccccccccc
ccccccccccc00cccc0aaa0ccc0000ccccc000ccccc7c77cccc7c7ccccc7777cccc777cccc008800c7777777a777aaccccccccccccccccccccccccccccccccccc
c0000ccccc0aa0ccc0aaa0ccc05770cccc060cccc777777cc77777cccc77777cc777777c067777607777777a77777acccccccccccccccccccccccccccccccccc
00000ccccc0aa0ccc0aaa0ccc05660cccc000cccc777777ccc77777cc77777cccc7777cc055555507777777a77aacccccccccccccccccccccccccccccccccccc
00ccccccccc00ccccc000cccc0000cccccccccccc77777ccc7777ccccc7777ccc7777ccc00000000aaaaaaacaccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccc7c7c7ccc7cc77cccc77c77cccc7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00cccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0c0ccccccccccccccccccccccccccc
cccccccccccccccc000cccc000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000ccccccccc00000cccccccc0cccc0ccccccccccccc
ccc00000000ccccc0200000020ccccccccc0000000ccccccc00000000ccccccc0000cc000ccccccc0000660c0000000002ee000000000000c00000000ccccccc
0003d6d6d60ccccc0e288882e0cccccc000d666660ccccccc0665d660ccccccc066600660ccccccc066d66000677776008880dd6d666d0d00d5775d60ccccccc
0bb30d5d000ccccc0212222120cccccc033003b300cccccc03dd00000ccccccc00d000000ccccccc0000dd0c055555500888055656665050c05665000ccccccc
033300050ccccccc0200000020cccccc000000000ccccccc0b000cccccccccccc0d0ccccc0ccccccc0c0000c000000000022000000000000cc0dd0cccccccccc
c000cc050ccccccc000cccc000cccccccccccccccccccccc00ccccccccccccccc000ccccccccccccccccccccccccccccc0000cccccccc0cccc0000cccccccccc
cccccc000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00ccccccccccccccccccccccccccccc0cccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccc0cccccccccccccccc0ccccccccccc00cc00cccccccccccc0cccccccccccccccc0cccccccccccccccc0ccccccccccc00cc00cccccccccccc0cccccccc
ccccccc060cccccccccc0000060cccccccccc060060ccccccccccc060000ccccccccccc070cccccccccc0000070cccccccccc060070ccccccccccc060000cccc
ccc0000666000ccccccc0666660ccccccccc06666660ccccccccc0666660ccccccc0000677000ccccccc0666770ccccccccc06667770ccccccccc0667770cccc
ccc0666666660ccccccc0666666000ccccc0666666660ccccc0006666660ccccccc0666677770ccccccc0666777000ccccc0666677770ccccc0006667770cccc
ccc0666666660ccccc006666666660ccc00666666666600ccc06666666660cccccc0666777770ccccc006667777770ccc00666677777700ccc06666777770ccc
cc06667666660cccc0166676666660ccc01666766666610ccc066676666660cccc06666777770cccc0166667777770ccc01666677777710ccc066667777770cc
c0166666666660cccc066666666660cccc066666666660cccc0666666666610cc0166666777770cccc066666777770cccc066666777770cccc0666667777710c
cc0156066606510ccc056606660650cccc056606660650ccc0156606660650cccc0156606660510ccc056660666050cccc056660666050ccc0156660666050cc
ccc05666666610cccc0556666666110cc01556666666510ccc015666666650ccccc05666777610cccc0556667776110cc01556667776510ccc015666777650cc
ccc0556565650ccccc011565656100ccc00155656565100cccc01565656110ccccc0555565650ccccc011555656100ccc00155556565100cccc01555656110cc
ccc0115551110ccccc0001555550ccccccc0155555510ccccccc0555551000ccccc0115551110ccccc0001555550ccccccc0155555510ccccccc0555551000cc
ccc0001510000cccccccc0511110cccccccc01511510cccccccc0111510cccccccc0001510000cccccccc0511110cccccccc01511510cccccccc0111510ccccc
cccccc010cccccccccccc0100000ccccccccc010010ccccccccc000010cccccccccccc010cccccccccccc0100000ccccccccc010010ccccccccc000010cccccc
ccccccc0cccccccccccccc0cccccccccccccc00cc00ccccccccccccc0cccccccccccccc0cccccccccccccc0cccccccccccccc00cc00ccccccccccccc0ccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc00ccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000cccc
c777c77cc777c777c7c7c777c7ccc777c777c777cc7cccccc0d0ccccccccccccccccccccccc000000ccccccc088888808800880888888088888808888880cccc
c7c7cc7cccc7ccc7c7c7c7ccc7ccccc7c7c7c7c7cc7cccccc060cccccccccccccccccccccc0aaaaa0ccccccc088000008800880880088088000008800880cccc
c7c7cc7cc777cc77c777c777c777ccc7c777c777cc7ccccccc060ccc00000000000cccccc06aaaaa0ccccccc088888808800880888888088880c08888800cccc
c7c7cc7cc7ccccc7ccc7ccc7c7c7ccc7c7c7ccc7cccccccccc060ccc00dddd666d0ccccc066daaaa0ccccccc000002202200220220000022000002200220cccc
c777c777c777c777ccc7c777c777ccc7c777ccc7cc7cccccccc0d0cccc00000000cccccc0ddd55500ccccccc022222202222220220ccc022222202200220cccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc0d0ccccccccccccccccccc0ddddd0cccccccc000000000000000000000000000000000000cccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc000cccccccccccccccccc0000000cccccccccccc0fffff00ffffff0ffffff0fffff0cccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc00ccccccccccccccccccccccccccccccccccccc0ff00ff000ff000ff00000ff0000cccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0ff00ff0c0ff0c0ffffff0ff0ccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0440044000440000000440440000cccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0444440044444404444440444440cccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000cccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0888888088888808800880ccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0880088088008808800880ccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0888880088008800888800ccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0220022022002202200220ccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0222222022222202200220ccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000ccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c777777c777777c777777c777777c77cc777777c777777c77cc77c777777c777777c77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c77cc77c77ccccc77ccccccc77ccc77cc77cc77c77cc77c77cc77c77ccccc77ccccc77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c77777cc7777ccc777777ccc77ccccccc77777cc77cc77cc7777cc7777ccc777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c77cc77c77ccccccccc77ccc77ccc77cc77cc77c77cc77c77cc77c77ccccccccc77c77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c777777c777777c777777ccc77ccc77cc777777c777777c77cc77c777777c777777c77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c777777c777777c77ccc77c777777cccc777777c77cc77c777777c777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c77ccccc77cc77c777c777c77cccccccc77cc77c77cc77c77ccccc77cc77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c77c777c777777c7777777c7777cccccc77cc77c77cc77c7777ccc77777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c77cc77c77cc77c77c7c77c77cccccccc77cc77c777777c77ccccc77cc77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c777777c77cc77c77ccc77c777777cccc777777ccc77ccc777777c77cc77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
__gff__
0002020201010000000000000000000002020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000500000000000005000000000000000005000000020000000500000000000000000500000002000000050000000000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000504040404040405000000000000000005000000020000000500000000000000000500000002000000050000000000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000500000000000005040404040404040405040404020404040504040404040404040500000003010101010101030000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000500000000000005000000000000000005000000020000000500000000000000000500000002000000050000020000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000500000000000005000000000000000005000000020000000500000000000000000500000002000000050000020000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000500000000000005000000000000000005000000020000000500000000000000000500000002000000050000020000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000500000000000005000000000000000005000000020000000500000000000000000500000002000000050000020000000000000000000000000000000000000000000000000000
0000000500000003010101010101010101010101010101010300000005000000000000000000000000000000000000000000000000000000000500000000000005000000000003010101010101030000000500000000000000000500000002000000050000020000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000500000000000005000000000002000005000000020000000504040404040404040504040402040404050404020404040000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000500000000000005000000000002000005000000020000000500000000000000000500000002000000050000020000050000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000504040404040405000000000002000005000000020000000500000000000000000500000002000000050000020000050000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000500000000000500000000000005000000000002000005000000020000000500000000000000000500000002000000050000020000050000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000500000000000500000000000005000000000002000005000000030000000500000000000000000500000003000000050000020000050000000005000000000000000000000000000000000000
0404040504040402040404050404040404040404050000000301010101010101101110101111101011101010111110101011101011101011111010101111111010101110101111111010111011111010111011101011111010101110111011101010111110111010101110111110101110111010111110101110101011111010
0000000500000002000000050000000000000000050000000200000005000000121312131312121312131312131213131313121212121312121313121212131213121312131312121212131312131212131213131212121312121313121213121312121312121313121213131212121312131213131212131213131213121313
0000000500000002000000050000000000000000050000000200000005000000141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010103000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000500000002000000050404040404040404050404040204040405040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000500000002000000050000000000000000050000000200000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000500000003000000050000000000000000050000000300000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111101011101111101011101110101111101010111011101110101011111011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121213131213121213121313121212131212131312121312131212131212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414141414141414141414141414141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
013d00200a6100f611156111c6112c6113161131611236111b6110d6110d6110c6110b6110a621096110861107611096110b6110161106611076110f611186111c61125611256111c61116611126110d61109611
0108080a1307014070180701806018050180401803018020180141801500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b0809245701d5701c5701c5601c5501c5401c5301c5201c5100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010200280c31500000000000000000000000000f2250000000000000000c3000c415000000000000000000000c3000000000000000000c30000000000000741500000000000c2150000000000000000c30000000
010300280000000000246250000000000000000000000000246150000000000000000c30018625000000000018000180002430018000180001800024300180001800018000000000000000000000000000000000
011000010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090004180701a07015070160700c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000000000000000000000000000000000
0109000418070160701307011070295052650529505265052d505295052950526505225051f5051d505215052e5052b50528505245052d5052d5052850528505265052e5052b5052850524505215051d50521505
010a00240000000000000000000000000000000000000000000000000000000000002475524745247352473524735247352473524735247352473524745307550070000600000000000000000000000000000000
010600000c25300655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001515300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00002805300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000d1633166400165296630016423655001531d655001431964500143166340012512623001240d625001230a6140011508613001140661500113046150011302614001150061300115007050070500705
012800003c6453c0003c0003c0003c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000241501c1502b1501c150305501c550375501c550305402854037540285403c5303453037530345303c5203452037520345203c5103451037510345103c5103451037510345103c510345103751034515
010600001024300645000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000186553015424151181510c151001510015300153000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00003055130555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011f00002462500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900001824300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002445318233000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00002465324631246112460124601306012415500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000241501b1502b1501b150305501b550375501b550305402754037540275403c5303353037530335303c52033520375203352030510275102b5102751030510275102b510275103c510335103751033515
010a00000c3700c370004700047000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00000c0330443504235134253f6150443513225044350c0331342513225044353f6150443513225134250c0330443504235134253f6150443513225044350c0331342513225044353f615044351322513425
010d000028535234252d2152b5352a4252b2152f53532225395103723536520374153b2303952537410342353652034215325352f2202d5152b2302a4252b510284352622623510214351f22023515284102a225
010d00002b5352a4252821523535214251f2151e5351c4252b215235352a425232152d5352b4252a2152b535284252a215285352642523215215351f4251c2151a535174251e2151a5351c4251e2151f53523225
010d00000c0330043500235104253f6150043510225004350c0330042500225104353f6150043510225104250c0330043500235104253f6150043510225004350c0331042510225004353f615004351022500435
010d00000c0330243502235124253f6150243512225024350c0331242512225024353f6150243502235124250c0330243502235124253f6150243512225024350c0330242512225024353f615124350222512425
010d00002b5352a43528235235352b5252a42528525235252b5152a01528515235152b0152a01528715237152b0152a01528715237151f7151e7151c715177151f7151e7151c715177151371512715107150b715
010c00200c0530c235004303a324004453c3253c3240c0533c6150c0530044000440002353e5253e5250c1530c0530f244034451b323034453702437522370253c6153e5250334003440032351b3230c0531b323
010c00200c05312235064303a324064453c3253c3240c0533c6150c0530644006440062353e5253e5250c1530c05311244054451b323054453a0242e5223a0253c6153e52503345054451323605436033451b323
010c00202202524225244202432422425243252432422325223252402522420242242222524425245252422522325222242442524326224252402424522220252452524524223252442522227244262432522325
010c0000224002b4202e42030420304203042033420304203042030222294202b2202e420302202b420272202a4202a4222a42227420274202742025421274212742027420274202722027422272222742227222
010c00002a4202a4222a422274202742027422272222742527400254202a2202e4202b2202a426252202a4202742027422274222442024222244222242124421244202442024420244202422024422182210c421
01050000006143c651306550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000016230462308623096230c6230f6231262315623186231a6231d6232062325623286232b6232d623306233362335623386233b6233d6233e613006033060300603006030060300603006030060300603
010c00002465318355000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500003c65522400272003f50027400375002b5002e200322003320033200304003040030400375002e4000000000000000000000000000000000000000000300503c0552c2002c2002c2002c4002c4003a400
011e00000065500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01050000001310113101131031310414105141081410b14110151171510070000700000533e053217511b75116741117410c73108731057210371101711007010070100701007010070100701007010070100701
011100000f22522425272253f51227425375122b5112e2252724027232272222444024430244222b511224422b4422b23220241202322023220420204153a425162351b4351f4401f4321f2201d4401d4321d222
007800000c8410c8410c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c84018841188401884018840188401884018840188402483124830248302483024830248302483024830
01780000269542694026930185351870007525075240752507534000002495424940249301d5241d7000c5250c5242952500000000002b525000001d5241d5250a5440a5450a5440a5201a7341a7350a0350a024
017800000072400735007440075500744007350072400715007340072500000057440575505744057350572405735057440575503744037350372403735037440375503744037350372403735037440373503704
017800000a0041f734219442194224a5424a5224a45265351a5341a5350000026934269421ba541ba501ba550c5340c5450c5540c555000001f9541f9501f955225251f5341f52522a2022a3222a452b7342b725
0110002005b4008b3009b200ab3009b4008b3006b2002b3001b4006b3006b2003b3002b4003b3005b2007b3008b4009b300ab200ab300ab4009b3008b2007b3005b4003b3002b2002b3002b4002b3004b2007b30
0118042000c260cc260cc2600c2600c2600c260cc260cc260cc2600c2600c260cc260cc260cc2600c2600c260cc2600c2600c2600c260cc260cc260cc2600c260cc2600c260cc260cc2600c260cc260cc2605c26
012000200cb200fb3010b4011b5010b400fb300db2009b3008b400db500db400ab3009b200ab300cb400eb500fb4010b3011b2011b3011b4010b500fb400eb300cb200ab3015b4015b5015b4015b300bb200eb30
012c002000000000000000000000000000000000000000001372413720137201372015724157201572015722137241872418720187201872018720187201872018725187021a7241c7211c7201c7201c7201c720
012800001c7201f7241f7201f7201f7201f720157241572015720157201572015720157201572215725000001c7241c7201c7201c7201c7201f7241f7201f7201f7201f722157241572015720157201572015720
012800001572015725000001f7241c7241c7201c7201c7201c7201c72215724137211372013720137201372013720137221872418720187201872018720187201872018720187201872218725187001870018705
012000000dd650dd550dd450dd351075510745107351072500c5517d5517d4517d3517d2517d2510755107450dd650dd550dd450dd351075510745107351072500c5417d5517d4517d3517d2517d250dd250dd35
011d0c201072519d5519d4519d3519d251005510045100351002517d550f7350f7350f7250f72510725107251072519d3519d3519d2519d250b0250b0350b7350b0250b7250b72517d3517d350f7350f7350f725
0120000012d6512d5512d4512d351575515745157351572500c5510d5510d4510d3510d2510d25157551574512d6512d5512d4512d35157551574500c54157351572519d5519d4519d3519d2519d250dd250dd35
011d0c20107251ed351ed351ed351ed251503515035150251502517d35147351472514725147251572515725157251ed351ed351ed251ed2515025150351573515025157251572519d3519d350f7350f7350f725
0120000019d5519d450dd3501d551405014040147321472223d3523d450bd350bd551505015040157321572219d5519d450dd3501d551705019040197321972223d3523d450bd350bd551c0501e0401e7321e722
012000001ed551ed4512d3506d552105021040217322172228d4528d3528d2520050200521e0401e7321e7221ed551ed4512d3506d552105021040257322572228d5528d4528d3528d251c0401e0301e7221e722
0112000024e4524e3521f251ff351ff451de3524f2524f3518e451de351fe251d73018e251de351fe451d7321ff4521f3524f252973029e252be352ee4524e3524e2524e3521f451ff351ff251de352473224f35
0112000024e2524e35219451ff352192524e3524e4524f3526f2526f351fe451d73232f4532f352be25297322bf252bf352df253573235e2537e353ae4530e3530e2530e352df452bf352bf2529e253073230f35
011200002de252de352af4528f3528f2526e352df452df3521e2526e3528e452673221e3526e2528e352673228f252af352df253273232e3534e2537e352de252de352de252af3528f2528f3526e252d7322df35
011200000a0550a0350a0250a0550a0350a0250a0550a0350a0250a0550a035050250a0550a0350a0250a0550a035050250a0550a0350a0250a0550a035050250a0550a035050250a0550a035050250a0550a035
011200000505505035050250505505035050250505505035050250505505035000250505505035050250505505035000250505505035050250505505035000250505505035000250505505035000250505505035
011200000705507035070250705507035070250705507035070250705507035020250705507035070250705502035020550205502035020250205502035090250205502035090250205502035090250205502035
__music__
00 08 09 43 44
00 08 0a 43 44
00 0b 09 43 44
00 0c 0a 43 44
00 0b 09 43 44
02 0c 0a 43 44
01 12 13 43 44
00 12 13 43 44
00 12 13 43 44
00 12 13 43 44
00 14 15 43 44
00 14 15 43 44
02 16 17 43 44
01 18 42 43 44
00 1b 42 43 44
00 1c 42 43 44
00 18 42 43 44
00 18 1a 43 44
00 1b 1a 43 44
00 1c 19 43 44
02 18 1d 43 44
00 1e 42 43 44
00 1f 42 43 44
01 1e 20 43 44
00 1f 20 43 44
00 1e 20 43 44
00 1f 20 43 44
00 1e 21 43 44
00 1f 22 43 44
00 1e 21 43 44
02 1f 22 43 44
00 23 42 43 44
00 23 42 43 44
01 23 24 43 44
00 23 24 43 44
00 25 29 43 44
00 25 26 43 44
00 23 27 43 44
02 23 28 43 44
03 2a 2b 2c 2d
01 2e 2f 30 31
00 2e 2f 30 32
02 2e 2f 30 33
01 34 35 43 44
00 34 35 43 44
00 36 37 43 44
00 34 38 43 44
00 34 38 43 44
02 36 39 43 44
00 0d 11 43 44
01 0d 11 43 44
00 0d 0e 43 44
00 0d 0e 43 44
00 0d 10 43 44
00 0d 10 43 44
02 0d 0f 43 44
01 3d 3a 43 44
00 3e 3a 43 44
00 3d 3b 43 44
00 3e 3a 43 44
00 3f 3c 43 44
02 3f 3c 43 44
00 41 42 43 44
00 41 42 43 44
