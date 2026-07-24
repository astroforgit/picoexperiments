pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--"temple explorer"
--by aaron lack
--version 1.0
--final build for lmc 4400

function _init()
 --debugg
 --test
	debug = false
	
	if debug then
	 room = 19
	 gamestate = 1
	 initx = 8
	 inity = 10
	 song = 0
	 songtimer = 0
	 init_player(initx,inity)
	else
 	room = 0
	 gamestate = 0
 	song = 9
  songtimer = -1
  init_player(4,96)
 end
 
	gameoption = 1
	gravity = .3
	gmax = 4
	friction = .7
	slidemax = .7
 accelx = .6
 accelxmax = 1.9
	jump = -3
	camerax = 0
	cameray = 0
	movetimer = 0
	
	mapx = 0
	mapy = 0
	
	btndelay = false
	easymode = false
	if debug then
	 easymode = true
	end
	gameend = false
	
	--hat
	hatspawn = false
	hat = {}
	hat.x = 104
	hat.y = 16
	hat.x1 = 72
	hat.y1 = 16
	hat.x2 = 104
	hat.y2 = 16
	hat.x3 = 80
	hat.y3 = 368
	hat.x4 = 128*4 - 32
	hat.y4 = 16
	hat.color = 0
	hat.singlecolor = 0
	hat.color1 = 2
	hat.color2 = 3
	hat.color3 = 9
	hat.color4 = 10
	hat.numcollected = 0
	hat.animtime = 0
	hat.taken = false
	hat.taken1 = false
	hat.taken2 = false
	hat.taken3 = false
	hat.taken4 = false
	--[[if debug then
	 hat.numcollected = 3
	 hat.taken1 = true
	 hat.taken2 = true
	 hat.taken3 = true
	end]]
	purplereveal = false
	orangereveal = false
	goldhatreveal = false
	
	cutscene = false
	cutscenenum = 0
	cutscenetimer = 0
	cutscene1 = false
end

--sets up the player struct
function init_player(x,y)
 --player
 p = {}
	p.x = x
	p.y = y
	p.spawnx = x
	p.spawny = y
	p.oldx = 0
	p.oldy = 0
	p.dx = 0
	p.dy = 0
	p.hitx = 1
	p.hity = 2
	p.w = 5
	p.h = 5
	p.grounded = true
	p.jump = false
	p.jumpdelay = false
	p.walljump = false
	p.walljumptype = 0
	p.walljumptimer = 0
 p.climb = false
 p.wallclimb = false
 p.wallslide = false
 p.climbtimer = 0
 p.slippery = false
 p.hasgrapple = false
 --debugg
 if debug then
  p.hasgrapple = true
 end
 p.grapple = false
 p.swing = false
 p.hitbox = {x=1,y=2,w=5,h=5}
	p.dead = false
	p.respawn = false
	p.deathcounter = 0
	p.sprite = 16
	p.color = 1
	p.flip = false
	
	--grapple
	g = {}
	g.x = p.x
	g.y = p.y
	g.dx = 0
	g.dy = 0
	g.xstart = p.x + 4
	g.ystart = p.y + 4
	g.length = 0
	g.d = 1
	g.hit = false
 g.collision = false
 g.force = 8
 g.delay = false
 g.timer = 0
 g.swingtimer = 0
 
 --death circles
 b1 = {}
 b1.x = 0
 b1.y = 0
 b2 = {}
 b2.x = 0
 b2.y = 0
 b3 = {}
 b3.x = 0
 b3.y = 0
 b4 = {}
 b4.x = 0
 b4.y = 0
end

--game update function
function _update()
 if btndelay == true then
  if not btn(2) and
  not btn(3) and
  not btn(4) then
   btndelay = false
  end
 end
 if gamestate == 0 then
  str2spr(titleimg,0,0)
  if btnp(3) or btnp(2) and
  btndelay == false then
   btndelay = true
   if gameoption == 1 then
    gameoption = 2
   elseif gameoption == 2 then
    gameoption = 1
   elseif gameoption == 3 then
    gameoption = 4
   elseif gameoption == 4 then
    gameoption = 3
   end
  end
  if btnp(4) and
  gameoption == 1 and
  btndelay == false then
   btndelay = true
   gameoption = 3
  end
  if btnp(4) and 
  (gameoption == 3 or
  gameoption == 4) and
  btndelay == false then
   if gameoption == 4 then
    easymode = true
   end
   gamestate = 1
   reload(0x0,0x0,0x0fff)
   room = 1
   song = 10
   songtimer = 0
   sfx(-1,1)
   sfx(-1,2)
  elseif btnp(4) and
  gameoption == 2 then
   cls()
   stop("thanks for playing!")
  end
  if songtimer == -1 then
    sfx(9,1)
    songtimer = 0
  end
   --title screen music
  if song == 9 and
  songtimer > -1 then
   songtimer += 1
   if songtimer == 320 then
    sfx(21,2)
   end
  end
 elseif gamestate == 1 then
  if gameend == false then
   globalupdate()
   if cutscene then
 	  play_cutscene()
 	 end
   if not p.dead then
    playercontroller()
    playeranimation()
   elseif p.dead and
   p.respawn == false then
    death()
   elseif p.respawn == true then
    respawn()
   end
  else
   if song < 50 then
    sfx(-1,1)
    sfx(-1,2)
    sfx(-1,3)
    sfx(-1,0)
    sfx(21)
    song = 50
   end
   if btnp(4) and
   btndelay == false then
    run()
   end
  end
 end
end

function playercontroller()
 
 updatephitbox()
 p.oldx = p.x
 p.oldy = p.y

 --movement
 if not cutscene then
  if btn(0) and p.x >= -1 and
  not p.wallclimb then
 	 move = 1
 	 if p.dx > -accelxmax then
  	 p.dx += -accelx
  	elseif p.grounded or
    p.walljumptimer < 1 then
  	 p.dx += friction
  	 if p.grounded then
  	  p.dx += friction
  	 end
  	 if p.dx > -accelxmax then
  	  p.dx = -accelxmax
  	 end
  	end
   p.flip = true
 	elseif btn(1) and
 	not p.wallclimb then
 	 move = 2
 	 if p.dx < accelxmax then
  	 p.dx += accelx
  	elseif p.grounded or
    p.walljumptimer < 1 then
  	 p.dx += -friction
  	 if p.grounded then
  	  p.dx += -friction
  	 end
  	 if p.dx < accelxmax then
  	  p.dx = accelxmax
  	 end
  	end
   p.flip = false
  else
   if p.dx > 0 then
    if p.grounded or
    p.walljumptimer < 1 then
     p.dx += -friction
     if p.grounded then
  	   p.dx += -friction
  	  end
    else
     p.dx += -friction / 2
    end
    if p.dx < 0 then
     p.dx = 0
    end
   elseif p.dx < 0 then
    if p.grounded or
    p.walljumptimer < 1 then
     p.dx += friction
     if p.grounded then
  	   p.dx += friction
  	  end
    else
     p.dx += friction / 2
    end
    if p.dx > 0 then
     p.dx = 0
    end
   end
   move = 0
  end
 end

 --jumping!
 if btnp(4) and not p.jump and
 (p.grounded or p.wallclimb or
 p.wallslide) and
 not p.jumpdelay and
 not cutscene then
  p.jump = true
  p.jumpdelay = true
  if not p.wallslide then
   p.dy += jump
  end
  sfx(5)
  if p.wallclimb then
   p.walljump = true
   p.walljumptimer = 0
   p.wallclimb = false
   p.walljumptype = 1
  elseif p.wallslide then
   p.walljump = true
   p.walljumptimer = 0
   p.wallslide = false
   p.walljumptype = 2
  end
 end
 
 --walljumping
 if p.walljump then
  if p.walljumptimer == 0 then
   if p.flip then
    p.dx = 1
   else
    p.dx = -1
   end
   if p.walljumptype == 2 then
    p.dx = p.dx * 3.4
   end
  elseif p.walljumptimer == 1 then
   if p.walljumptype == 1 then
    p.dy = jump - .5
   else
    p.dy = (jump / 1.7) - .5
   end
  end
  p.walljumptimer += 1
  if p.walljumptimer > 5 then
   p.walljump = false
   p.walljumptimer = 0
  end
 end

 --moves player if:
 --no collisions
 --player isn't "ducking"
 --game isn't in a cutscene
 --player isn't wallclimbing*
 --*wallclimb logic up above
	if not collision_spr(room,p.hitx + p.dx,p.hity,p.h,p.w) then
		if not btn(3) or
		not p.grounded then
		 if not cutscene then
  		p.x += p.dx
  		if room == 1 and
		  p.hitx + p.dx < 0 then
		   p.x += -p.dx
		   p.dx = 0
		  end
  	end
  end
	else
		p.dx = 0
	end

 --end jump
 if p.jump and
 p.grounded and
 p.dy == 0 then
  p.jump = false
 end
 
 --jump delay
 if not p.jump and
 not btn(4) then
  p.jumpdelay = false
 end
 
 --gravity
 if not p.grounded and
 not p.climb then
  if not p.wallslide or
  p.dy <= 0 then
 	 p.dy += gravity
 	 if p.dy > gmax then
 	  p.dy = gmax
 	 end
 	else
 	 p.dy += gravity / 3
 	 if p.dy > slidemax then
 	  p.dy = slidemax
 	 end
 	end
	end

 --wall climbing
 if btn(5) and collisionw() and
 not p.slippery then
  if not p.climb then
   p.dy = 0
  end
  p.climb = true
  p.wallclimb = true
  p.grapple = false
  p.jump = false
  if btn(2) then
   --p.hity += -4
   if collisionw() then
    p.dy = -2
   else
    p.dy = 0
   end
   --p.hity += 4
   if p.climbtimer == 0 then
    p.climbtimer += 1
   end
  elseif btn(3) then
    p.dy = 2
   if p.climbtimer == 0 then
    p.climbtimer += 1
   end
  else
   p.climbtimer = 0
   p.dy = 0
  end
 elseif not p.grapple then
  p.wallclimb = false
  p.climb = false
  p.climbtimer = 0
 end

 --wall sliding
 if collisionw() and
 (not btn(5) or
 p.slippery) and p.dy > -.5 and
 ((p.flip and btn(0)) or
 (not p.flip and btn(1))) and
 not p.grounded then
  p.wallslide = true
  p.jump = false
 else
  p.wallslide = false
 end

 --shoot grapple
 g.xstart = p.x + 4
	g.ystart = p.y + 4
	 
 if btnp(5) and
 g.delay == false and
 p.grapple == false and
 p.climb == false and
 p.hasgrapple then
  sfx(6)
  p.grapple = true
  g.timer = 1
  g.x = g.xstart
  g.y = g.ystart
  if (btn(2) and btn(0)) or
  (btn(3) and btn(0)) then
   g.d = -2
  elseif (btn(2) and btn(1)) or
  (btn(3) and btn(1)) then
   g.d = 2
  elseif btn(2) then
   g.d = 0
  elseif p.flip then
   g.d = -1
  elseif not p.flip then
   g.d = 1
  end
 --grapple continues shooting
 --as long as you hold the
 --button
 elseif btn(5) and
 p.grapple == true then
  p.grapple = true
 else
  p.grapple = false
 end
 
 --graple delay
 if btn(5) then
	 g.delay = true
	elseif not btn(5) then
	 g.delay = false
	end

 --max grapple length
 if glength() > 45 then
  if g.hit then
   if pforce() > g.force then
    p.grapple = false
   else
    g.swingtimer += 1
    p.dx += -g.force / 4 * cos(atan2(p.x+4-g.x,p.y+4-g.y))
				p.dy += -g.force / 4 * sin(atan2(p.x+4-g.x,p.y+4-g.y))
    --[[if p.x > g.x then
     p.dx -= g.force * cos(gangle())
    elseif p.x < g.x then
     p.dx += g.force * cos(gangle())
    end
    p.dy += g.force * sin(gangle())]]
   end
  else
   g.delay = 0
   p.grapple = false
  end
 end

 --grapple timer
 if g.timer > 0 and
 p.grapple then
  if g.d == 0 then
   g.y += -4
  elseif g.d == 1 or
  g.d == -1 then
   g.x += 4 * g.d
   g.y += -1
  else
   g.x += g.d * 4/2
   g.y += -abs(g.d) - 1
  end 
  if collision(0,room,g.x+1*g.d,g.y) then
   if not p.slippery then
    sfx(20)
    g.timer = 0
    g.hit = true
   else
    p.grapple = false
   end
  end
 end

 --no hit if no grapple
 if not p.grapple then
  g.hit = false
  g.swingtimer = 0
 end

 --climbing the grapple
 if p.grapple and
 g.timer == 0 then
  if (p.x > g.x - 6 and
  p.x < g.x + 1) and
  btn(5) then
   if (btn(2) or
   not p.grounded) and
   not p.jump then
    p.climb = true
    g.swingtimer = 0
   end
  else
   p.climb = false
  end
  
  if p.climb then
   if btn(2) and p.y > g.y then
    if not collision_spr(room,p.hitx,p.hity+p.dy,p.w,p.h) and
    p.y > g.y then
     p.dy = -2
     if p.climbtimer == 0 then
      p.climbtimer += 1
     end
    else
     p.dy = 0
    end
   elseif btn(3) and
   not p.grounded then
    if not collision_spr(room,p.hitx,p.hity+p.dy,p.w,p.h) then
     p.dy = 2
     if p.climbtimer == 0 then
      p.climbtimer += 1
     end
    else
     p.grounded = true
    end
   elseif not btn(3) then
    if not p.jump then
     p.dy = 0
     p.climbtimer = 0
    end
   end
  end
 elseif not p.grapple and
 not p.wallclimb then
  p.climb = false
 end

 --climbtimer
 if p.climbtimer > -1 then
  if p.dy ~= 0 then
   p.climbtimer += 1
  end
  if p.climbtimer > 7 then
   p.climbtimer = 1
  end
 end

 --floor collision
 if collision_spr(room,p.hitx,p.hity + p.dy,p.h,p.w) then
  if p.dy > 0 then
   newy = flr(p.hity + p.dy)
   for i=0,30 do
    if collision_spr(room,p.hitx,newy,p.h,p.w) then
     newy -= 1
    else
     break
    end
   end
   p.y = newy - p.hitbox.y
   p.dy = 0
   p.grounded = true
  elseif p.dy < 0 then
   p.dy = 0
  end
 elseif p.dy != 0 then
	 p.y += p.dy
	 p.grounded = false
	elseif not collision_spr(room,p.hitx, p.hity + 1, p.w, p.h) then
	 p.grounded = false
	end
 
 --max running speed
--[[if abs(p.dx) > accelxmax and
 p.grounded then
  if p.dx < accelxmax then
   p.dx += friction
   if p.dx > -accelxmax then
    p.dx = -accelxmax
   end
  elseif p.dx > accelxmax then
   p.dx += -friction
   if p.dx < accelxmax then
    p.dx = accelxmax
   end
  end
 end]]
 
 --player can't go
 --above the screen
 if p.y < 0 then
  if p.y < -1 and
  (not p.jump or
  p.wallclimb) then
   p.y = -1
  else
   p.y = 0
  end
  if p.dy < 0 then
   p.dy = 0
  end
 end
 
 --fell below floor? dead.
 if p.y > 128 and
 room > 0 and room ~= 13 and
 room ~= 18 then
  p.dead = true
 elseif p.y > 800 then
  p.dead = true
 end
 
 --determine if player is
 --touching spikes
 if not easymode then
  spike_collision(room,p.hitx,p.hity,p.h,p.w)
 end

 --determine if player has
 --hit a checkpoint
 if collision_cp(room,p.hitx,p.hity,p.h,p.w) then
  p.spawnx = p.x
  p.spawny = p.y
 end

 --determine if player has
 --gotten a hat
 if hatspawn and
 not hat.taken then
  if collision_hat(room,p.hitx,p.hity,p.h,p.w) then
  hat.singlecolor = hat.color
  hat.taken = true
  hat.numcollected += 1
  if room == 4 then
   hat.taken1 = true
  elseif room == 12 then
   hat.taken2 = true
  elseif room == 18 then
   hat.taken3 = true
   mset(12,61,121)
   mset(12,63,4)
   mset(12,62,7)
   mset(13,62,7)
  elseif room == 20 then
   hat.taken4 = true
   for x=67,79 do
    for y=52,60 do
     mset(x,y,7)
    end
   end
  end
  sfx(13)
  end
 end

 --determine if player has
 --obtained the grapple
 if collision_g(room,p.hitx,p.hity,p.h,p.w) then
  mset(55,28,50)
  mset(56,28,51)
  sfx(-1)
  sfx(16)
  songtimer = -120
  p.hasgrapple = true
 end

 --determine if player has
 --beaten the game
 if collision_end(room,p.hitx,p.hity,p.h,p.w) and
 gameend == false then
  btndelay = true
  gameend = true
 end

end --end player update

function globalupdate()
  
 --moving between screens
	--room +1 (rooms 1-6)
	if room >= 1 and
	room <= 6 and
	p.x + p.dx > 121 then
	 room += 1
	 p.x = -1
	 p.grapple = false
	 if room == 2 then
 	 p.spawnx = 6
 	 p.spawny = 48
 	elseif room == 3 then
 	 p.spawnx = 6
 	 p.spawny = 80
 	elseif room == 4 then
 	 p.spawnx = 6
 	 p.spawny = 72
 	elseif room == 5 then
 	 p.spawnx = 6
 	 p.spawny = 88
 	elseif room == 6 then
 	 song = 0
 	 sfx(-1)
 	 songtimer = -1
 	 p.spawnx = 80
 	 p.spawny = 80
 	elseif room == 7 then
 	 p.spawnx = 8
	  p.spawny = 80
 	end
 --room -1 (rooms 2-7)
 elseif room >= 2 and
 room <= 7 and
 p.x + p.dx < -1 then
  room -= 1
  p.x = 121
  p.grapple = false
  if room == 2 then
   p.spawnx = 117
  	p.spawny = 80
  elseif room == 3 then
   p.spawnx = 116
 	 p.spawny = 72
 	elseif room == 4 then
 	 p.spawnx = 118
 	 p.spawny = 88
 	elseif room == 5 then
 	 p.spawnx = 108
 	 p.spawny = 72
  end
	--7 to 8
	elseif room == 7 and
	p.x >= 121+128 and btn(1) then
	 p.x = -1
	 room = 8
	 p.grapple = false
	 p.spawnx = 8
	 p.spawny = 24
	--8 to 7
	elseif room == 8 and
	p.x <= 0 and btn(0) then
	 p.x = 121+128
	 room = 7
	 p.grapple = false
	 p.spawnx = 244
	 p.spawny = 24
	--8 to 9
	elseif room == 8 and
	p.x >= 121+128 and btn(1) then
	 p.x = -1
	 room = 9
	 p.grapple = false
	 if not p.hasgrapple then
 	 song = 15
 	 sfx(-1)
 	 songtimer = -1
 	end
	--9 to 8
	elseif room == 9 and
	p.x <= 0 and btn(0) then
	 p.x = 121+128
	 room = 8
	 p.grapple = false
	 p.spawnx = 240
	 p.spawny = 72
	--9 to 10
	elseif room == 9 and
	p.x >= 121 and btn(1) then
	 p.x = -1
	 room = 10
	 p.grapple = false
	 p.spawnx = 4
	 p.spawny = 72
	--10 to 9
	elseif room == 10 and
	p.x <= 0 and btn(0) then
	 p.x = 121
	 room = 9
	 p.grapple = false
	--10 to 11
	elseif room == 10 and
	p.x + p.dx > 121 then
	 p.x = -1
	 room = 11
	 p.grapple = false
	 p.spawnx = 4
	 p.spawny = 104
	--11 to 10
	elseif room == 11 and
	p.x + p.dx < 0 then
	 p.x = 121
	 room = 10
	 p.grapple = false
	 p.spawnx = 116
	 p.spawny = 104
	--11 to 12
	elseif room == 11 and
	p.x + p.dx > 121 then
	 p.x = -1
	 room = 12
	 p.grapple = false
	 p.spawnx = 4
	 p.spawny = 104
	--12 to 11
	elseif room == 12 and
	p.x + p.dx < 0 then
	 p.x = 121
	 room = 11
	 p.grapple = false
	 p.spawnx = 116
	 p.spawny = 104
	--12 to 13
	elseif room == 12 and
	p.x + p.dx > 121 then
	 p.x = -1
	 room = 13
	 p.grapple = false
	 p.spawnx = 4
	 p.spawny = 104
	 if song == 15 then
 	 sfx(-1)
 	 songtimer = -5
 	 song = 7
 	end
	--13 to 12
	elseif room == 13 and
	p.x + p.dx < 0 and
	p.y < 128 then
	 p.x = 121
	 room = 12
	 p.grapple = false
	 p.spawnx = 116
	 p.spawny = 104
	--13 to 14
	elseif room == 13 and
	p.x + p.dx < 0 and
	p.y > 128 then
	 p.x = 121
	 p.y += -128
	 room = 14
	 p.grapple = false
	 p.spawnx = 117
	 p.spawny = 112
	--14 to 13
	elseif room == 14 and
	p.x + p.dx > 121 then
	 p.x = -1
	 p.y += 128
	 room = 13
	 p.grapple = false
	 p.spawnx = 4
	 p.spawny = 240
	--14 to 15
	elseif room == 14 and
	p.x + p.dx < 0 then
	 p.x = 121
	 room = 15
	 p.grapple = false
	 p.spawnx = 117
	 p.spawny = 112
	--15 to 14
	elseif room == 15 and
	p.x + p.dx > 121 then
	 p.x = -1
	 room = 14
	 p.grapple = false
	 p.spawnx = 4
	 p.spawny = 112
	--15 to 16
	elseif room == 15 and
	p.x + p.dx < 0 then
	 p.x = 121
	 room = 16
	 p.grapple = false
	 p.spawnx = 117
	 p.spawny = 16
	--16 to 15
	elseif room == 16 and
	p.x + p.dx > 121 then
	 p.x = -1
	 room = 15
	 p.grapple = false
	 p.spawnx = 0
	 p.spawny = 16
	--16 to 17
	elseif room == 16 and
	p.y + p.dy > 121 and
	p.x + p.dx > 88 then
	 p.y = -1
	 room = 17
	 p.grapple = false
	 p.spawnx = 108
	 p.spawny = 16
	--17 to 16
	elseif room == 17 and
	p.y + p.dy < 0 then
	 p.y = 121
	 room = 16
	 p.grapple = false
	 p.spawnx = 88
	 p.spawny = 112
	--17 to 18
	elseif room == 17 and
	p.x + p.dx < 0 then
	 p.x = 121
	 p.y += 128 * 2
	 room = 18
	 p.grapple = false
	 p.spawnx = 117
	 p.spawny = 368
	--18 to 17
	elseif room == 18 and
	p.x + p.dx > 121 then
	 p.x = -1
	 p.y -= 128 * 2
	 room = 17
	 p.grapple = false
	 p.spawnx = 4
	 p.spawny = 112
	--18 to 19
	elseif room == 18 and
	p.y + p.dy < 0 then
	 p.y = 121
	 room = 19
	 p.grapple = false
	 p.spawnx = 24
	 p.spawny = 112
	--19 to 18
	elseif room == 19 and
	p.y + p.dy > 121 then
	 p.y = -1
	 room = 18
	 p.grapple = false
	 p.spawnx = 16
	 p.spawny = 16
	--19 to 20
	elseif room == 19 and
	p.x + p.dx > 121+128 then
	 p.x = -1
	 room = 20
	 p.grapple = false
	 p.spawnx = 24
	 p.spawny = 112
	--20 to 19
	elseif room == 20 and
	p.x + p.dx < 0 then
	 p.x = 121+128
	 room = 19
	 p.grapple = false
	 p.spawnx = 114+128
	 p.spawny = 112
	--20 to 21
	elseif room == 20 and
	p.x + p.dx > 121+128*3 then
	 p.x = -1
	 room = 21
	 sfx(-1)
	 songtimer = -1
	 song = 0
	 p.grapple = false
	 p.spawnx = 24
	 p.spawny = 112
	--21 to 20
	elseif room == 21 and
	p.x + p.dx < 0 then
	 p.x = 121+128*3
	 room = 20
	 p.grapple = false
	 p.spawnx = 154+128*2
	 p.spawny = 112
	end
	
	--purple hat secret reveal
	if room == 3 and p.x < 30 and
	p.y == 16 and
	purplereveal == false then
 	revealpurplesecret()
 end
 
 --orange hat secret reveal
 if room == 18 and p.x < 16 and
 p.y > 350 and
 orangereveal == false then
  revealorangesecret()
 end
	
	--gold hat reveal
	if room == 20 and
	p.x > 128*3 - 60 and
	goldhatreveal == false then
	 goldhatreveal = true
	 goldenhatreveal()
	end
	
	--begin level music
	--first cutscene
	if room == 6 and
	p.x > 50 and
	songtimer == -1 then
	 if cutscene1 == false then
 	 cutscene = true
 	 cutscenenum = 1
 	 cutscenetimer = 0
 	 cutscene1 = true
 	end
	end
	
	if debug then
	 if cutscene and btnp(4) and
	 btnp(5) then
	  cutscene = false
	 end
	end
	
	if hatspawn then
	 hat.animtime += 1
	 if hat.animtime == 15 and
	 ((hat.y < hat.y1 + 3 and
	 room < 18) or
	 (hat.y < hat.y3 + 3 and
	 room == 18) or
	 (hat.y < hat.y4 + 3 and
	 room == 20)) then
	  hat.y += 1
	  hat.animtime = 1
	 elseif hat.animtime == 30 and
	 ((hat.y > hat.y1 and
	 room < 18) or
	 (hat.y > hat.y3 and
	 room == 18) or
	 (hat.y > hat.y4 and
	 room == 20)) then
	  hat.y += -1
	  hat.animtime = 16
	 elseif hat.animtime == 30 and
	 ((hat.y == hat.y1 and
	 room < 18) or
	 (hat.y == hat.y3 and
	 room == 18) or
	 (hat.y == hat.y4 and
	 room == 20)) then
	  hat.animtime = 1
	 end
 end

	--song
	if songtimer == 0 or
	(songtimer == 120 and
	(song == 0 or song == 1)) then
	 sfx(song)
	 if song == 0 then
	  sfx(2)
	  sfx(4)
	 elseif song == 1 then
	  sfx(4)
	  --sfx(3)
	 end
	 songtimer += 1
	end
	
	--for pauses before
	--the music starts
	if songtimer < -1 then
	 songtimer += 1
	 if songtimer == -2 then
	  songtimer = 0
	 end
	end
	
	--pre-temple music
	if songtimer > 0 then
	 songtimer += 1
	 if song == 10 or
	 song == 11 then
	  if songtimer == 121 then
	   if song == 10 then
	    song = 11
	   elseif song == 11 then
	    song = 10
	   end
	   songtimer = 0
	  end
	 elseif songtimer == 240 and
	 (song == 0 or song == 1) then
	  if song == 0 then
	   song = 1
	  elseif song == 1 then
	   song = 0
	  end
	  songtimer = 0
	 end
	end
	
	--grapple room music
	if songtimer == 441 and
	song == 15 then
	 songtimer = 0
	 sfx(song)
	end
	
	--grapple remix
	if song == 7 then
	 if songtimer == 0 or
	 songtimer == 209 then
	  sfx(song)
	  sfx(18)
	 elseif songtimer == 418 or
	 songtimer == 627 then
	  sfx(19)
	  sfx(18)
	 end
	 if songtimer == 836 then
	  songtimer = 0
	 end
	end
	
end --end global update


function playeranimation()
 
 --move timer
 if move > 0 and
 movetimer == 0 then
  movetimer = 1
 end
 if movetimer > 0 and
 move > 0 then
  movetimer += 1
  if movetimer == 10 then
   movetimer = 1
  end
  if p.oldx == p.x then
   movetimer = 0
  end
 else
  movetimer = 0
 end
 
 --player sprite
 if cutscene then
  p.sprite = 16
 elseif p.wallslide then
  p.sprite = 48
 elseif p.jump then
  p.sprite = 20
 elseif p.y > p.oldy and
 not p.climb then
  p.sprite = 19
 elseif movetimer > 4 and
 movetimer < 7 then
  p.sprite = 17
 elseif movetimer > 6 then
  p.sprite = 18
 elseif p.grounded and
 btn(3) and not p.climb then
  p.sprite = 32
 elseif p.grounded and
 btn(2) and not p.climb then
  p.sprite = 20
 else
  if p.climb then
   if p.climbtimer < 4 then
    p.sprite = 33
   elseif p.climbtimer < 8 then
    p.sprite = 34
   end
  else
   p.sprite = 16
  end
 end

end --end animation update

function updatephitbox()
 p.hitx = p.x + p.hitbox.x
 p.hity = p.y + p.hitbox.y
end

deathtimer = 0

--death animation
function death()
 p.grapple = false
 p.dx = 0
 if deathtimer == 0 then
  deathtimer = 1
  b1.x = p.x
  b1.y = p.y
  b2.x = p.x
  b2.y = p.y
  b3.x = p.x
  b3.y = p.y
  b4.x = p.x
  b4.y = p.y
  sfx(8)
 end
 b1.x += -2
 b1.y += -2
 b2.x += 2
 b2.y += -2
 b3.x += -2
 b3.y += 2
 b4.x += 2
 b4.y += 2
 deathtimer += 1
 if deathtimer == 10 then
  p.respawn = true
  deathtimer = 0
 end
end

--respawning!
function respawn()
 p.x = p.spawnx
 p.y = p.spawny
 p.dead = false
 p.respawn = false
 p.dy = 0
 p.dx = 0
 p.jump = false
 p.grounded = true
 p.sprite = 16
 p.deathcounter += 1
end

--purple hat secret reveal
function revealpurplesecret()
 purplereveal = true
 sfx(22)
 for y=0,5 do
  for x=22,28 do
   mset(x,y,42)
  end
  mset(29,y,45)
 end
 for x=33,34 do
  mset(x,2,43)
 end
 for x=30,34 do
  mset(x,3,43)
 end
 for x=30,33 do
  mset(x,4,43)
 end
 mset(30,5,25)
 mset(33,5,24)
 mset(30,0,43)
 mset(31,0,43)
 mset(32,2,15)
 mset(31,5,8)
 mset(32,5,8)
 for x=22,29 do
  mset(x,6,8)
 end
 mset(22,0,15)
 mset(22,1,15)
 for y=2,5 do
  mset(21,y,15)
 end
 mset(22,2,15)
 mset(21,2,41)
 mset(28,2,14)
 mset(28,1,25)
 for x=29,31 do
  mset(x,1,8)
 end
 mset(29,2,41)
end

--orange hat secret reveal
function revealorangesecret()
 orangereveal = true
 sfx(22)
 for x=2,11 do
  for y=60,62 do
   mset(x,y,7)
  end
 end
 mset(7,60,9)
 mset(8,60,10)
 mset(9,60,10)
 mset(10,60,110)
 mset(11,60,74)
 mset(12,60,111)
 mset(12,61,105)
 mset(12,62,105)
 mset(12,63,90)
 mset(11,63,4)
 mset(10,63,4)
 mset(9,63,3)
 for x=2,8 do
  mset(x,63,37)
 end
 mset(5,63,23)
 mset(10,62,127)
end

function bighat(hatx,haty)
 mset(hatx+1,haty,26)
 mset(hatx+1,haty+1,26)
 mset(hatx+5,haty,118)
 mset(hatx+5,haty+1,118)
 mset(hatx,haty+2,26)
 mset(hatx+6,haty+2,118)
 mset(hatx+2,haty,3)
 mset(hatx+3,haty,4)
 mset(hatx+4,haty,5)
 mset(hatx+2,haty+1,1)
 mset(hatx+3,haty+1,6)
 mset(hatx+4,haty+1,2)
 mset(hatx+1,haty+2,73)
 mset(hatx+2,haty+2,94)
 mset(hatx+3,haty+2,10)
 mset(hatx+4,haty+2,110)
 mset(hatx+5,haty+2,75)
end

function goldenhatreveal()
 local hatx
 local haty

 if hat.numcollected > 0 then
  hatx = 73
  haty = 58
  bighat(hatx,haty)
 end

 if hat.numcollected > 1 then
  hatx = 67
  haty = 55
  bighat(hatx,haty)
 end
 
 if hat.numcollected > 2 then
  hatx = 73
  haty = 52
  bighat(hatx,haty)
 end

end

function play_cutscene()
 --first cutscene
 if cutscenenum == 1 then
  p.sprite = 16
  if cutscenetimer == 0 then
   mset(81,6,12)
   mset(81,7,11)
   mset(80,6,6)
   mset(80,7,10)
   sfx(12)   
  elseif cutscenetimer == 14 then
   mset(81,7,2)
   mset(81,8,11)
   mset(80,7,6)
   mset(80,8,10)
   sfx(12)
  elseif cutscenetimer == 28 then
   mset(81,8,2)
   mset(81,9,11)
   mset(80,8,6)
   mset(80,9,10)
   sfx(12)
  elseif cutscenetimer == 42 then
   mset(81,9,2)
   mset(81,10,2)
   mset(81,11,28)
   mset(80,9,6)
   mset(80,10,6)
   mset(80,11,6)
   sfx(12)
  elseif cutscenetimer == 56 then
   songtimer = 0
   cutscene = false
  end
  cutscenetimer += 1
 end
end

--[[function tile_at(x,y)
 return mget((room-1) * 16 + x, 1 * 16 + y)
end
  
function floor_at(x,y)
 for i=max(0,flr(x/8)),min(15,(x+6-1)/8) do
  for j=max(0,flr(y/8)),min(15,(y+7-1)/8) do
   local tile = tile_at(x,y)
   if fget(tile,0) then
    anything = true
    p.y = j
   end
  end
 end
 return anything
end]]
 
function collision(s,room,x,y)
 if room < 8 then
  rx = (room-1) * 16
  ry = 0
 elseif room == 8 then
  rx = (room-7) * 16
  ry = 16
 elseif room >= 9 and
 room < 14 then
  rx = (room-6) * 16
  ry = 16
 elseif room >= 14 and
 room < 18 then
  rx = 320 - (room * 16)
  ry = 32
 elseif room == 18 then
  rx = 0
  ry = 16
 elseif room == 19 then
  rx = 16
  ry = 32
 elseif room == 20 then
  rx = 16
  ry = 48
 elseif room == 21 then
  rx = 80
  ry = 48
 end
 --[[if s == 0 and
 fget(mget(x/8+r,y/8),7) then
  p.dead = true
 end]]
 if s == 0 then
  if p.y < 116 or
  room == 18 then
   if fget(mget(x/8+rx,y/8+ry),6) then
    p.slippery = true
   else
    p.slippery = false
   end
   if not easymode then
    return fget(mget(x/8+rx,y/8+ry),0)
   else
    return fget(mget(x/8+rx,y/8+ry),0) or
    fget(mget(x/8+rx,y/8+ry),7)
   end
  else
   --determine which rooms
   --have bottomless pits
   if room == 2 or
   room == 3 or
   room == 4 or
   room == 5 then
    return false
   else
    if fget(mget(x/8+rx,y/8+ry),3) then
     p.slippery = true
    else
     p.slippery = false
    end
    if not easymode then
     return fget(mget(x/8+rx,y/8+ry),0)
    else
     return fget(mget(x/8+rx,y/8+ry),0) or
     fget(mget(x/8+rx,y/8+ry),7)
    end
   end
  end
 elseif s == 1 then
  return fget(mget(x/8+rx,y/8+ry),2)
 elseif s == 2 then
  return fget(mget(x/8+rx,y/8+ry),3)
 elseif s == 3 then
  return fget(mget(x/8+rx,y/8+ry),4)
 elseif s == 4 then
  return fget(mget(x/8+rx,y/8+ry),5)
 elseif s == 5 then
  return fget(mget(x/8+rx,y/8+ry),1)
 end
end

function collision_s(s,room,x,y)
 if room == 18 then
  rx = 0
  ry = 16
  if s == 0 and
  fget(mget(x/8+rx,y/8+ry),7) then
   if not easymode then
    p.dead = true
   end
   return fget(mget(x/8+rx,y/8+ry),7)
  end
  return fget(mget(x/8+rx,y/8+ry),7)
 else
  if room < 8 then
   rx = (room-1) * 16
   ry = 0
  elseif room == 8 then
   rx = (room-7) * 16
   ry = 16
  elseif room >= 9 and
  room < 14 then
   rx = (room-6) * 16
   ry = 16
  elseif room >= 14 and
  room < 19 then
   rx = 320 - (room * 16)
   ry = 32
  elseif room == 19 then
   rx = 16
   ry = 32
  elseif room == 20 then
   rx = 16
   ry = 48
  elseif room == 21 then
   rx = 80
   ry = 48
  end
  if s == 0 and
  fget(mget(x/8+rx,y/8+ry),7) then
   p.dead = true
   return fget(mget(x/8+rx,y/8+ry),7)
  end
  return fget(mget(x/8+rx,y/8+ry),7)
 end
end

function collision_spr(room,x,y,h,w)
 return collision(0,room,x,y) or
 collision(0,room,x+w,y) or
 collision(0,room,x+w,y+h) or
 collision(0,room,x,y+h)
end

function collision_cp(room,x,y,h,w)
 if mget(mapx + p.x/8,mapy + p.y/8) == 71 then
  if room ~= 18 or
  (room == 18 and
  p.y < 280) then
   mset(mapx + p.x/8,mapy + p.y/8,72)
   sfx(14)
  end
 end
 return collision(1,room,x,y) or
 collision(1,room,x+w,y) or
 collision(1,room,x+w,y+h) or
 collision(1,room,x,y+h)
end

function collision_g(room,x,y,h,w)
 return collision(2,room,x,y) or
 collision(2,room,x+w,y) or
 collision(2,room,x+w,y+h) or
 collision(2,room,x,y+h)
end

function collision_hat(room,x,y,h,w)
 return collision(3,room,x,y) or
 collision(3,room,x+w,y) or
 collision(3,room,x+w,y+h) or
 collision(3,room,x,y+h)
end

function collision_end(room,x,y,h,w)
 return collision(5,room,x,y) or
 collision(5,room,x+w,y) or
 collision(5,room,x+w,y+h) or
 collision(5,room,x,y+h)
end

function spike_collision(room,x,y,h,w)
 return collision_s(0,room,x+1,y+1) or
 collision_s(0,room,x+w-1,y+1) or
 collision_s(0,room,x+w-1,y+h-1) or
 collision_s(0,room,x+1,y+h-1)
end

--check for wall collision
function collisionw()
 if p.flip then
  return collision(0,room,p.hitx-1,p.hity)
 else
  return collision(0,room,p.hitx+p.w+1,p.hity)
 end
end

function glength()
 local glx
 local gly
 if p.grapple then
  glx = (g.x - (p.x + 4)) * (g.x - (p.x + 4))
  gly = (g.y - (p.y + 4)) * (g.y - (p.y + 4))
  return sqrt(glx + gly)
 else
  return -1
 end
end

function gangle()
 local glx
 local gly
 if p.grapple then
  glx = (g.x - (p.x + 4)) * (g.x - (p.x + 4))
  gly = (g.y - (p.y + 4)) * (g.y - (p.y + 4))
  tan = gly / glx
  return atan2(gly,glx)
 else
  return -1
 end
end

function pforce()
 return sqrt((p.dx*p.dx)+(p.dy*p.dy))
end

function _draw()
	if gamestate == 0 then
  rectfill(0,0,127,368,0)
  mapx = 112
  mapy = 48
  map(112,48,0,0,64,64)
  palt(0,false)
  sspr(0,0,64,32,32,30)
  if gameoption == 1 then
   print("a game by aaron lack",23,68,13)
   print("->",40,98,13)
   print("start",53,98,13)
   print("quit",55,110,13)
  elseif gameoption == 2 then
   print("a game by aaron lack",23,68,13)
   print("->",40,110,13)
   print("start",53,98,13)
   print("quit",55,110,13)
  elseif gameoption == 3 then
   print("choose a difficulty!",23,68,13)
   print("normal",51,105,0)
   print("easy",55,116,3)
   print("the game as intended.",21,79,5)
   print("challenging platforming",17,86,5)
   print("and higher stakes!",27,93,5)
   print("->",40,105,13)
  elseif gameoption == 4 then
   print("choose a difficulty!",23,68,13)
   print("normal",51,105,0)
   print("easy",55,116,3)
   print("a mode for beginners.",21,79,5)
   print("spikes won't hurt you,",19,86,5)
   print("and some jumps made easier.",9,93,5)
   print("->",40,116,13)
  end
 elseif gameend then
  camera(0,0)
  rectfill(0,0,128,128,3)
  print("you found the treasure!",20,10,0)
  print("total deaths: "..p.deathcounter,20,20,0)
  print("press z to restart.",20,40,0)
 else
 	palt(11,true)
 	palt(0,false)
 	if room < 5 then
 	 rectfill(0,0,127,127,13)
 	else
   rectfill(0,0,127,127,5)
  end
 end
 
 if gameend == false then
 --room map
  if room == 1 then
 	 map(0,0,0,0,16,16)
	  if p.x < 21 then
  	 print("z = jump",10,112,7)
	  elseif p.x > 20 then
  	 print("x = climb",54,104,7)
  	end
	 elseif room == 2 then
	  map(16,0,0,0,16,16)
	  if easymode then
	   mset(24,12,15)
	   mset(29,12,14)
	   mset(30,12,41)
	   mset(31,12,41)
	  end
	  if p.spawny < 80 then
  	 if p.x < 50 then
   	 print("wall jump:",64,20,7)
   	 print("z while climbing",51,30,7)
   	else
   	 print("wall slide:",61,8,7)
   	 print("press against the wall,",37,20,7)
   	 print("but don't hold x.",50,27,7)
   	 print("jumps from slides",50,39,7)
   	 print("launch you farther!",47,46,7)
   	end
   end
  elseif room == 3 then
   map(32,0,0,0,16,16)
   if easymode then
    mset(45,8,43)
   end
   print("you can slide",71,35,7)
   print("down ice blocks,",65,42,7)
   print("but you can't",71,49,7)
   print("climb them.",75,56,7)
   hatspawn = false
	 elseif room == 4 then
	  map(48,0,0,0,16,16)
	  if easymode then
	   mset(55,10,25)
	   mset(56,10,8)
	  end
	  hatspawn = true
	  if hat.color ~= hat.color1 then
	   hat.y = hat.y1
	  end
	  hat.color = hat.color1
	  hat.x = hat.x1
	  if hat.taken1 == false then
	   hat.taken = false
	  else
	   hat.taken = true
	  end
	 elseif room > 4 and
	 room < 7 then
	  map(room*16-16,0,0,0,16,16)
	  hatspawn = false
	 elseif room == 7 then
	  mapx = 96
	  mapy = 0
	  map(96,0,0,0,32,16)
	 elseif room == 8 then
	  mapx = 16
	  mapy = 16
	  map(16,16,0,0,32,16)
	 elseif room == 9 then
	  mapx = 48
	  mapy = 16
	  map(48,16,0,0,16,16)
	 elseif room == 10 then
	  mapx = 64
	  mapy = 16
	  map(64,16,0,0,16,16)
	  print("hold x to grapple",30,95,7)
	 elseif room == 11 then
	  mapx = 80
	  mapy = 16
	  map(80,16,0,0,16,16)
	  print("up+x",16,117,0)
	  hatspawn = false
	 elseif room == 12 then
	  map(96,16,0,0,16,16)
	  hatspawn = true
	  hat.x = hat.x2
	  if hat.color ~= hat.color2 then
	   hat.y = hat.y2
	  end
	  hat.color = hat.color2
	  if hat.taken2 == false then
  	 hat.taken = false
  	else
  	 hat.taken = true
  	end
	 elseif room == 13 then
	  mapx = 112
	  mapy = 16
	  hatspawn = false
	  map(112,16,0,0,16,32)
	 elseif room >= 14 and
	 room < 18 then
	  mapx = 320 - (room * 16)
	  mapy = 32
	  hatspawn = false
	  map(mapx,32,0,0,16,16)
	  if easymode then
	   mset(81,41,23)
	   mset(91,43,3)
	   mset(91,44,1)
	   mset(81,35,31)
	   mset(85,35,31)
	   mset(76,39,23)
	   mset(72,37,23)
	  end
	  if room == 14 and
	  easymode then
	   mset(110,41,7)
	  end
	  
	 elseif room == 18 then
	  mapx = 0
	  mapy = 16
	  map(0,16,0,0,16,64)
	  hatspawn = true
	  if hat.color ~= hat.color3 then
	   hat.y = hat.y3
	  end
	  hat.color = hat.color3
	  hat.x = hat.x3
	  if hat.taken3 == false and
	  orangereveal == true then
	   hat.taken = false
	  else
	   hat.taken = true
	  end
	 elseif room == 19 then
	  mapx = 16
	  mapy = 32
	  hatspawn = false
	  map(16,32,0,0,32,16)
	  if easymode then
	   for y=38,41 do
	    mset(20,y,1)
	   end
	  end
	 elseif room == 20 then
	  mapx = 16
	  mapy = 48
	  map(16,48,0,0,64,16)
	  if hat.numcollected < 3 and
	  p.x > 128*3 + 40 then
	   print("only the worthy",128*3+20,15,10)
	   print("are granted this hat...",128*3 + 5,22,10)
	   print("hats found:   / 3",128*3+16,035,10)
	   print(hat.numcollected,128*3+63,35,10)
	  elseif hat.numcollected == 3 and
	  p.x > 128*3 + 40 then
	   print("you are worthy...",128*3+16,15,10)
	   print("hats found:   / 3",128*3+16,25,10)
	   print(hat.numcollected,128*3+63,25,10)
	  end
	  hatspawn = true
	  if hat.color ~= hat.color4 then
	   hat.y = hat.y4
	  end
	  hat.color = hat.color4
	  hat.x = hat.x4
	  if hat.taken4 == false then
	   hat.taken = false
	  else
	   hat.taken = true
	  end
	 elseif room == 21 then
	  mapx = 80
	  mapy = 48
	  hatspawn = false
	  pal(6,10)
	  pal(13,9)
	  map(80,48,0,0,16,16)
   pal(6,6)
   pal(13,13)
	 end
 	
 	if (p.x < 60 or
 	(room > 0 and room < 7) or
 	room == 9 or
 	room == 10 or
 	room == 11 or
 	room == 12 or
 	room == 14 or
 	room == 15 or
 	room == 21) and room > 0 and
 	room ~= 13 and room ~= 18 then
 	 camerax = 0
 	 cameray = 0
 	elseif room == 7 or
 	room == 8 or
 	room == 19 then
 	 if p.x < 256-68 then
 	  camerax = p.x - 60
 	  cameray = 0
 	 else
 	  camerax = 256 - 128
 	  cameray = 0
  	end
  elseif room == 20 then
   if p.x < 128*4 - 68 then
    camerax = p.x - 60
    cameray = 0
   else
    camerax = 128*3
    cameray = 0
   end
  elseif room == 13 and
  (p.y < 64 or (p.x < 32 and
  p.y <= 104)) then
   camerax = 0
   cameray = 0
  elseif room == 13 and
  p.y > 256 - 64 then
   camerax = 0
   cameray = 256 - 128
  elseif room == 13 then
   camerax = 0
   cameray = p.y - 64
 	elseif room == 18 and
 	p.y > 384 - 64 then
 	 camerax = 0
 	 cameray = 384 - 128
 	elseif room == 18 and
 	p.y < 64 then
 	 camerax = 0
 	 cameray = 0
 	elseif room == 18 then
 	 camerax = 0
 	 cameray = p.y - 64
 	end
 	
 	camera(camerax,cameray)
  
  if hatspawn and
  not hat.taken then
   rectfill(hat.x+2,hat.y+1,hat.x+5,hat.y+2,hat.color)
   rectfill(hat.x+1,hat.y+3,hat.x+6,hat.y+3,hat.color)
   if hat.color == hat.color4 then
    rectfill(hat.x+5,hat.y+1,hat.x+5,hat.y+3,7)
    rectfill(hat.x+6,hat.y+3,hat.x+6,hat.y+3,7)
   end
  end
  
  if p.grapple then
   line(p.x+4,p.y+4,g.x,g.y,7)
   spr(21,g.x-2,g.y-2)
  end

  --player sprite
  if not p.dead and
  gamestate == 1 then
   --hat color
   --no hats taken
   if not hat.taken1 and
   not hat.taken2 and
   not hat.taken3 then
    pal(7,p.color)
    pal(6,p.color)
    pal(13,p.color)
    pal(5,p.color)
   --one hat taken
   elseif (hat.taken1 and
   not hat.taken2 and
   not hat.taken3) or
   (hat.taken2 and
   not hat.taken1 and
   not hat.taken3) or
   (hat.taken3 and
   not hat.taken1 and
   not hat.taken2) then
    pal(7,hat.singlecolor)
    pal(6,hat.singlecolor)
    pal(13,hat.singlecolor)
    pal(5,hat.singlecolor)
   --two hats taken
   elseif hat.taken1 and
   hat.taken2 and
   not hat.taken3 then
    pal(7,hat.color1)
    pal(6,hat.color1)
    pal(13,hat.color2)
    pal(5,hat.color2)
   elseif hat.taken1 and
   hat.taken3 and
   not hat.taken2 then
    pal(7,hat.color1)
    pal(6,hat.color1)
    pal(13,hat.color3)
    pal(5,hat.color3)
   elseif hat.taken2 and
   hat.taken3 and
   not hat.taken1 then
    pal(7,hat.color2)
    pal(6,hat.color2)
    pal(13,hat.color3)
    pal(5,hat.color3)
   --all hats taken
   elseif hat.taken1 and
   hat.taken2 and
   hat.taken3 then
    pal(7,hat.color1)
    pal(6,hat.color2)
    pal(13,hat.color2)
    pal(5,hat.color3)
   end
   if hat.taken4 then
    pal(7,hat.color4)
    pal(6,hat.color4)
    pal(13,hat.color4)
    pal(5,7)
    pal(1,hat.color4)
    pal(2,7)
    pal(4,7)
   else
    pal(2,1)
   end
   spr(p.sprite,p.x,p.y,1,1,p.flip)
   pal(7,7)
   pal(6,6)
   pal(13,13)
   pal(5,5)
   pal(1,1)
   pal(2,2)
   pal(4,4)
  elseif deathtimer > 0 then
   spr(35,b1.x,b1.y)
   spr(35,b2.x,b2.y)
   spr(35,b3.x,b3.y)
   spr(35,b4.x,b4.y)
  end
 end
 
 --debugg
 --[[if debug then
  print(p.x,camerax+5,cameray+5,7)
  print(p.y,camerax+5,cameray+15,7)
  print(p.spawnx,camerax+5,cameray+25,7)
  print(p.spawny,camerax+5,cameray+35,7)
  print(p.climbtimer,camerax+5,cameray+75,14)
 end]]
end
-->8
--code for implementing art
--without using existing
--sprite data
titleimg = "[gfz]4020666666606060006000060000000600060600000660000000000066666666666666660060611100000006060000000000000000000000000000060010666616666660601110100000000000000000000000000000000000000001006060166166060611010000000000000000000000000000000000000000000000000000661666601000000000000000000000000000000000000a0000000000000001066106661110000000000000000000000000000000000000000000000000000006066666611000000000000000000000000000000000000000a0000000000000000066661000000000000011111111100000000000000000000000000000000000016116100000000000111111111111c0000000000000900800000000000000006116661000000000011151111111111c0000000008000000000000000000000000100100000000001551111111111111c0000000a0000900000000000000000006666110000000015111111111111111c10000000000090980000000000000000016611000000001115111111111111c11111000000089099000000000000000001666000000001151111111111111c11111110000000999000000000000000000166600000000011111111111111111111111c0000009a909000a0000000000000166600000010011111111111011111111cc00000009aa990800000000000000066600000111100111111111111111111cc0000a09aaaaa998000000000000000666000011111100001000011111111cc0000000099aaa9990000000000000000666060001111111110111111111111c00000000099aaaaa900000000000000006660000000111111111111111111c00000000000099aaa99a00000000000000066000000000511111111111115ff0000000000009999a9000000000000000000660600000000500111111111ffff0000000000000994990a00000000000000066660000000005000000000055fff000000000000000440000000000000000006666660000000050000000055fff000000000000010040000000000000000000066061000000000500000055fff100000000000000f4f00000000000000000060666610000000000505055005111c000000000000fffff000000000000000000166666600000000100010011111111c00000000ccffffff000000000000006006666001100000110010001111111111000000ccc1ffffff000000000000000161666666100001115511011111111111c000001111cffff00000000000000011166660661100011105001111111111111c11111111144000000000000000611666666666611001550010111111111111111111111114000100000000001116666666666606666165006510111111011111111611114460010000606660166666666[/gfx]"

function str2spr(s,x,y)
	local w = ("0x"..sub(s,6,7))+0
	local h = ("0x"..sub(s,8,9))+0
 local n = 10
 for i=0,h-1 do
  for j=0,w-1 do
   sset(x+j,y+i,("0x"..sub(s,n,n))+0)
   n+=1 
  end
 end
end
__gfx__
eeeeeeee0d666666666666d00000000000000000000000006666666655555555333333330d66666666666666666666d066666666666666663444544445445443
eeeeeeee0d666666666666d00dddddddddddddddddddddd06666666655555555343343430d66666666666666666666d066666666666666663354444544544433
eeeeeeee0d666666666666d00d66666666666666666666d06666666655555555433445340d66666666666666666666d066666666666666663434454444444533
eeeeeeee0d666666666666d00d66666666666666666666d06666666655555555545444540d66666666666666666666d066666666666666663354445454544443
eeeeeeee0d666666666666d00d66666666666666666666d06666666655555555444544450d66666666666666666666d066666666666666663345444544454433
eeeeeeee0d666666666666d00d66666666666666666666d06666666655555555454445440d66666666666666666666d066666666666666663534454445444343
eeeeeeee0d666666666666d00d66666666666666666666d06666666655555555544454440dddddddddddddddddddddd0666666dddd6666663434544454445433
eeeeeeee0d666666666666d00d66666666666666666666d0666666665555555544544454000000000000000000000000666666d00d6666663354445444544453
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb76d5bbbb7bbbbbb77bbbbb0000000033333333333333335555555a11111111666666d00d666666054454447c7c7c7c
bb76d5bbbb76d5bbbb76d5bbbb76d5bbb776d55bb777bbbb7777bbbb0dddddd034343433335343435555555a11111111666666dddd66666604544445ccccccc7
b776d55bb776d55bb776d55bb776d55bbbf0f0bb77777bbb7777bbbb0d6666d043444343343445345555555a111111116666666666666666044445447ccc7ccc
bbf0f0bbbbf0f0bbbbf0f0bbbbf0f0bbbbffffbbb777bbbbb77bbbbb0d6666d054544433335444545555555a11111111666666666666666604544454ccccc7c7
bbffffbbbbffffbbbbffffbbbbffffbbbb1112bbbb7bbbbbbbbbbbbb0d6666d044454433334544455555555a111111116666666666666666044544457c7ccccc
bb1112bbbb1112bbbb1112bbbb1112bbbb1112bbbbbbbbbbbbbbbbbb0d6666d045444543354445445555555a11111111666666666666666605444544ccc7ccc7
bb1112bbbb11124bb41112bbbb1112bbbbbbbbbbbbbbbbbbbbbbbbbb0dddddd054445343343454445555555a111111116666666666666666044454447ccccccc
bb4bb4bbbb4bbbbbbbbb4bbbb4bbbb4bbb4bb4bbbbbbbbbbbbbbbbbb0000000044544433335444545555555a11111111666666666666666600000000c7c7c7c7
bbbbbbbbbbbbbbbbbbbbbbbbbb1bbbbb777077705555555555555000555555555500077745445444ccccccccddddddddd5555555ccdcdcdd4544544466666666
bbbbbbbbbb76d5bbbb76d5bbb111bbbb777077705555555555000777555555555077777744544445ccccccccdddddddd5d555555cccdcddd4454444566666666
bb76d5bbb776d55bb776d55b11111bbb777077705055505550777777550555055500077744444544ccccccccddddddddd5555555ccdcdcdd4444454466666666
b776d55bbbf0f0bbbbf0f0bbb111bbbb070507050705070555000777507050705555500054544454ccccccccdddddddd5d555555cccdcddd5454445466666666
bbf0f0bbbbffffbbbbfffffbbb1bbbbb070507050705070555555000507050705500077744454445ccccccccddddddddd5555555ccdcdcdd4445444566666666
bbffffbbbb1112fbbb1112bbbbbbbbbb070507057770777055000777077707775077777745444544ccccccccdddddddd5d555555cccdcddd4544454466666666
bb1112bbbb1112bbbb1112bbbbbbbbbb505550557770777050777777077707775500077754445444ccccccccddddddddd5555555ccdcdcdd5444544466666666
bb4114bbbbbb4b4bbbbb4b4bbbbbbbbb555555557770777055000777077707775555500044544454ccccccccdddddddd5d555555cccdcddd0000000066666666
bbbbbbbbbbbbbbbb55555555555555555555555555555555000555557770005507770777ccccccccccccccccccccccccbbbbbbbb00000000dddddddd0d0d0d0d
bb76d5bbbbbbbbbb55555555555555555555555555555755777000557777770507770777cccccccccccccc77ccccccccbbaaa7bb00000000ddddddddd0d0d0d0
b776d55bbbbbbbbb55555555555555555555555555557775777777057770005507770777cccc7777ccccc77777ccccccbaaaa77b00000000dddddddd000d000d
bb0f0fbbbbbbbbbb55555555555555555555555555577777777000550005555550705070cc7777777ccc77777777ccccbbf0f0bb00000000dddddddd00000000
bbffffbbbbbbbbbb55555555555555555555777777757775000555557770005550705070c777777777c777777777777cbbffffbb00000000dddddddd0d000d00
bb1112fbbbbbbbbb555500000000555555770000000057557770005577777705507050707777777777777777776677ccbbaaa7bb00000000dddddddd00000000
bb1112bbbbbbbbbb55000aaaaaa0005557000aaaaaa00055777777057770005555055505cc776666cccc7766c66cccccbbaaa7bb00000000dddddddd000d0000
bbbb4b4bbbbbbbbb550aaaa99aaaa055550aaaa99aaaa055777000550005555555555555ccccccccccccccccccccccccbb7bb7bb00000000d0d0d0d000000000
0000000066666666666666666666666666666666666666666666666654666665543333350000000000000000000000000000000000000000000000000d6666d0
0ddddddd666ddddd56ddddd56d5666d56dddd566d566666ddddd5666546ddd65543777350dddddddddddddddddddddd00ddddddddddddddddddddddddd6666d0
0d6d6d6d666ddddd56ddddd56dd56dd56ddddd56d566666ddddd5666546d6665543733350d66666666666666666666d00d6666666666666666666666666666d0
0dd6666666666d5666dd66666dddddd56d566d56d566666dd6666666546d6665543733350d66666666666666666666d00d6666666666666666666666666666d0
0d66666666666d5666ddd5666dddddd56ddddd56d566666ddd566666546ddd65543777350d66666666666666666666d00d6666666666666666666666666666d0
0dd6666666666d5666dd66666d5656d56dddd566d566666dd666666654666665543333350d66666666666666666666d00d6666666666666666666666666666d0
0d66666666666d5666ddddd56d5666d56d566666ddddd56ddddd566654555555545555550dddddddddddddddddddddd00d6666dddd666666666666dd666666d0
0dd6666666666d5666ddddd56d5666d56d566666ddddd56ddddd566654555555545555550000000000000000000000000d6666d00d666666666666d0666666d0
666666666666666666666666666666666666666666666666666666666666666650007770000000000d6666d0666666d00d6666d00d6666d00d6666660d6666d0
6666ddddd56d566d56dddd566d5666666dddd566dddd566ddddd56dddd566666077700050dddddd0dd6666dd666666dd0d6666dddd6666dddd666666dd6666d0
6666ddddd56ddddd56ddddd56d566666dddddd56ddddd56ddddd56ddddd56666500077700d6666d066666666666666660d6666666666666666666666666666d0
6666dd666666ddd566d566d56d566666d5666d56d566d56dd66666d566d56666077700050d6666d066666666666666660d6666666666666666666666666666d0
6666ddd566666d5666ddddd56d566666d5666d56ddddd56ddd5666ddddd56666500077700d6666d066666666666666660d6666666666666666666666666666d0
6666dd666666ddd566dddd566d566666d5666d56dddd566dd66666dddd566666077700050d6666d066666666666666660d6666666666666666666666666666d0
6666ddddd56ddddd56d566666ddddd56dddddd56d56dd56ddddd56d56dd56666500077700d6666d066666666666666dd0dddddddddddddddddddddddddddddd0
6666ddddd56d566d56d566666ddddd566dddd566d566d56ddddd56d566d56666077700050d6666d066666666666666d000000000000000000000000000000000
0d6666660000000066666dd00000000055555555a5a555aa40499994a5555555050505050d6666d00d6666d050005555555555550d666666666666d000000000
0dd66666ddddddd0666666d0dddddddd55555555559aa9a9404444449aa55555707070700d6666d00d6666dd0777000555555a550d666666666666ddddddddd0
0d6666666d6d6dd066666dd06d6d6d6d44444455555a9a99a9a999aa9a9aa5a5707070700d6666d00d66666650007770575555550d66666666666666666666d0
0dd66666666666d0666666d066666666000045555a99a99a9999a9a999979555707070700d6666d00d66666607770005a5a555550d66666666666666666666d0
0d66666666666dd066666dd06666666600aaaa5559aaa9999a7999999a9a9a55070707070d6666d00d66666650007770575555550d66666666666666666666d0
0dd66666666666d0666666d0666666664aaaaaa5a9a97a49a7979a999999aaa5070707070d6666d00d66666607770005555555550d66666666666666666666d0
0d66666666666dd066666dd06666666644444444aa99aaa94979999a79a9a99a070707070d6666d00d666666500077705555a5550d6666dddddddddddd6666d0
0dd66666666666d0666666d06666666640998899a999a44999949949a9949a9a505050500d6666d00d66666607770005555555550d6666d0000000000d6666d0
0d6666666666666666666dd0666666d0666666d005050505a5555555555a5555550505050d6666d00d6666d00d6666d066666666bbbbbbbb5000777055555555
0dd6666666666666666666d0666666d0666666dd70707070a555555555757555507070700d6666d00d6666dddd6666d066666666bbbbbbbb0777000555555555
0d6666666666666666666dd0666666d06666666670707070a5555555555a5555507070700d6666d00d666666666666d066666666bbbbbbbb5000777055555555
0dd6666666666666666666d0666666d06666666670707070a555555555555554507070700d6666d00d666666666666d066666666bbbbbbbb0777000555555555
0d6666666666666666666dd0666666d06666666607070705a55555555555a554070707070d6666d00d666666666666d066666666bbbbbbbb5000777055555555
0dd6d6d6d6d6d6d6d6d6d6d0666666d06666666607070705a555555555555555070707070d6666d00d666666666666d066666666bbbbbbbb0777000555555555
0dddddddddddddddddddddd0dd6666d0dd66666607070705a5555555a5a55555070707070dddddd00d6666dddd6666d0dd6666ddbbbbbbbb5000777055555555
0000000000000000000000000d6666d00d66666650505055a55555555a55555550505050000000000d6666d00d6666d00d6666d0bbbbbbbb5555000555555555
40507070708210602070629671707082c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0d060606060c0f1f1f1f1f1f1f1f1f1f197707097f1
f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1a0a0a0a0a0a0a0a0a0a0a0a0a0d06060c0a0a0b086868694a4a4a4b4707010
60207070708210602070709673707082207070707070707082f170707070707085707070857070707070a11060606060207070707070427070707070707070f1
f1707070707070707070717070707070707070707070707070707070707070f1f1707070707062f1f1f170707070106060207070707070707070707070707010
60207070708290a0b07070967370708220707070f1f1707082f170707070707085707070857070707070a11060606060207070707070707070707070707070f1
f1707070707070707070707070707070707070707070707070707070707070f1f1707170707062f1f1f170707070106060207070707070707070707070707010
6020707070707070707070967370707120707070f1f1707082f170707070707085707070857070707070a11060606060207070f1f1f1f1f186f1f1f1f1f1f1f1
f17070f1f1f1f1f17070707070f1f1f1f1707070f1707070f1707070707070f1f170f170707062f1f1f170f1f170106060207070629570707070707070707010
60207070707070707070709673707082f170707010f1527070f170707070f17085707070857070707070a1106060606020707070707070707070707070707010
f16370f1f1f1f1f17070707070f1f1f1f1707070707070707070707070f170f1f170f170707071f1f17070f1f170f16060207070629770707070707070707010
60207070707070707070709673707082f170707010f1f1f170f170707070f170e7707070e77070707070a1106060606020707070707070707070707070707010
f16370f1f1f1f1f17070707070f1f1f1f17070707070707070707070707070f1f170f170707062f1707070f1f170f16060207070707070707070707070707010
602070707070707070c4a4f573707071f1707070f1f1707070f195707070f17070707070707070707070a190d060606020525252527070727272f1f1f1707010
f1707062f1f1f1f17070707070f1f1f1f1707070707070707070f170707070f1f170f170707062f1707062f1f170f16060207070707070707070707070707010
a0b07070707070707096707070707082f1717070f1f1707070f196707070f1707070707070707070707070a11060606020f1f1f1f1f1f1f1f1f1f1f1f1707010
f1707062f1f1f1f17070707070f1f1f1f17070707070717070707070707070f1f170f1f1707062f17062f1f1f170f16060205270707272727272727272727210
73707070707070707096707070747082f1707070f1f1707070f197707070f170b670707070707070707070a190d060602070707070707070f170707070707010
f17062f1f1f1f1f17070707070f1f1f1f17070707070707070707070707070f1f17070f17070f1f1707062f19570f1d060b5b4707094a4a4a4a4a4d4404040d1
73707070707070707096703040404040f1707070f1f1637062f1f1f1f170707085707070b670707070707070a11060602070707070707070f170707070707010
f17070f1f1f1f1f17272727272f1f1f1f17070707070707070707070707070f1f17070f17071f1f1707062f196708310602070707070707070707090d0606060
73707070707070707096701060606060f1707070f1f1637062f1f1f1f1707070857070708570707070707070a190d0602070707070707070f170705270707010
f17070f1f1f1f1f1f1f1f1f1f1f1f1f1f17070707070707070707070707070f1f16370f17070f163707062f1f170701060c14040404040506370708290d06060
b4868686868686868697701060606060f1f17070f1f1707070f1f183f1f1707085707070857070707070707070a11060b070707070707070707070f163707010
f16370f1f1f1f1f1f1f1f1f1f1f1f1f1f170707070707070707070f1507070f1f16370f1f170f163707070f1f1707090a0a0a0a0a0a0a0475063707082106060
73707070707070707070701060606060f1707070f1f1707070f1427083f1707095707070857070707070707070a190a07070707070707070707070f163707010
f1637082f1f1707070707070707070f1f170707070707070707070f120707070707070f1f170f1f163707070f170707070707070707082904750637082106060
737070707070707070707090a0a0d060f170707010f1707070837070708370709670707085707070707070707070707070707070707094b4707070f163707010
f1637082f170707070707070707070f1f170707070707070707070f120707070707070f1f170f1f1f163707096707070707070707070708290e6b47082106060
73707070304040e4b4637083838310602070707010f1707070707074707070709670707085707070707070707070707070707070707070707070707070707010
f16370707070707070707070707070f1f170707070707070707070f120707070707070f1f1707070707070709670707070707070707070707070707082106060
7370707010606020737070707062106020707030d1c140404040404040404040f452525295525252304040404040404040404050525252525252525252525210
f1f1f1f1f1f1727272727295707095f1f172727272727272727272f1c1404040404040404040404040405052a640404040404040404040404040404040d16060
73707070106060207370707070621060606060606060c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0d0c0a0a0a0a0a0a0a0a0a0a0a0f1f1f1f1
f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1a0a0a0a0a0a0a0a0a0a0d07070707070707070707070707070707004363636363636363636363636363616
73707070106060207370707070621060606060606060206770707070707070707070707070707070707070707070a1f1f167707070707070707070a1f1f16770
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2142434445464f2f2f2f226
73707070106060207370707070f1d160606060606060206770707070707070707070707070707070707070707070a1f1f167707070707070707070a1f1f16770
707070707070707070707070f77070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f20515253545556575f2f2f226
73707070106060207370f17070f16060606060606060206770707070707070707070707070707070707070707070a1f1f167707070707070707070a1f1f16770
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
7370707090a0a0b07370f17070106060606060606060206770707070707070707070707070707070707070707070a1f1f167707070707070707070a1f1f16770
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
52527070707070707070f17070106060606060606060206770707070707070707070707070707070707070707070a1f1f167707070707070707070a1f1f16770
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
a4b47070707070707070f17070f160606060606060c0b06770707070707070707070707070707070707070707070a1f1f167707070707070707070a1f1f16770
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
42427070707030404040f47070f16060606060606020677070707070707070707070707070707070707070707070a190b067707070707070707070a1f1f16770
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
63707070707010606060f1707010606060606060602067707070707070707070707070707070707070707070707070707070707070707070707070a1f1f16770
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
63707070707090d06060f17070f1a0d060606060c0b0677070707070707070707070707070707070707070707070707070707070707070707070707070707070
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
63707070707070106060f17070707010606060602067707070707070707070707070707070707070707070707070707070707070a13040404040506770707070
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
63708786868686106060207070707090606060602067707070707070707070707070707070707070707070707070707070707070a190a0a0a0a0b06770707070
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
63703040404040d16060c14050637070a0a0a0a0b067707070707070707070707070707070707070707070707070707070707070707070707070707070707070
707070707070707070707070707070707070707070707070707070707070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
63701060606060606060606020637070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070
70707070707070707070707070707070707070707070707070c646c67070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
63701060606060606060606020637070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070
707070707070707070707070707070707070707070707070705666767070a1107070707070707070707070707070707006f2f2f2f2f2f2f2f2f2f2f2f2f2f226
637110606060606060606060c1404040404040404040404050525252525252525252525252525252525252525252525252525252525252525252525252525252
52f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f140404040404040404040d17070707070707070707070707070707007171717171717171717171717171727
__gff__
0001010101010100010101010101010100000000000000010101000001010141000000008080808080010000000001010000000008088080800000000000000000000000000000200401010101010101000000000000000080010101010101010000000002020202800101800201010100000001018000028001010101108010
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0e29292929292929292929292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b010606060606060606060606060606060606060606060606060606060606060c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0d060c0a0a0a0a0a0a0a
2a2a2a2a2a2a2a2a2a2a393a3b2a2a2a2a2a2a2a0e2929292929292929292929080808080808080808080808080808080808182b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b010606060606060606060606060606060606060606060606060606060606060237070707070707070707070707072801060237070707070707
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0e29292929292929292929292929292b2b2b2b1f0e2929292929292929290f2b2b2b2b2b2b7d2b2b2b2b2b2b2b2b2b2b2b2b2b010606060606060606060606060606060606060606060606060606060606060207070707070707070707470707072801060237070707070707
2a393a3b2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0e29292929292929292929292929291f2b2b2b1f0e2929292929292929290f2b2b2b2b494a4a4a4b2b2b2b2b2b2b2b2b2b2b2b090a0a0a0a0a0d0606060606060606060606060606060606060606060606060207070707494a4a4a4a4d040507072801060237070707070707
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0e292929292929292929292929291f1f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c07070707090d06060606060606060606060606060606060606060606060207070707070707072801060207072801060237070304040404
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0e2929292929292929292929290f1f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c0707070707090d060606060606060606060606060606060606060606060207070707070707072801060207070701060207070106060606
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0e2929292929292929292929290f1f2b2b2b1f1f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c070707070707090a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0b07070707070707070701060207070701060207070106060606
2a2a2a2a2a2a2a1908080808080808080808182a0e0f2a2a2a2a2a0e29292929290f1f2b2b2b1f1f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b030507070707070707070707070707070707070707070707070707070707070707070707170707070701060236070701060207070106060606
2a2a2a2a2a2a2a0e292929292929292929290f2a2a2a2a2a2a2a2a0e29292929290f1f2b2b1f1f1f2b2b2b2b2b1f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b011c05070707070707070707070707070707070707070707070707070707070707070707070707070701061c05360701060207280106060606
2a2a2a2a2a2a2a0e292929292929292929290f2a2a2a2a2a2a2a2a0e29292929290f1f2b2b1f1f2b2b2b2b2b2b1f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b01061c05070707070707070707070707070707070707070707070707070707070707070707070707070106060207070106020728090a0d0606
2a2a2a2a2a2a2a0e292929292929292929290f2a2a2a2a19182a2a2a2a2d2b2b2b2b2b2b2b1f1f2b2b2b2b2b2b1f1f1f1f1f2b2b2b2b2b2b19182b2b2b2b2b2b2b2b2b2b2b2b2b0106061c05070707070707070707070707070707070707070707070707070707070707070707070726010606020707010c0b07070707010606
2a2a2a2a2a2a2a0e292929292929292929290f2a2a2a2a0e0f2a2a2a2a19080808080808181f1f2b2b2b2b2b2b1f1f1f1f1f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b010606061c04040404040404040404040404040404040404040404040507070707070703040507072601060602070701023707070707010606
2a2a2a1908080829292929292929292929290f2a2a2a2a2a2a2a2a2a2a2d2b0e292929290f1f1f2b2b2b2b2b2b1f1f1f1f1f2b2b2b2b2b2b2b2b2b2b2b2b19080808182b2b2b2b090d060606060606060606060606060606060606060606060606060602070707070707010602070726010606020728090b3707070707010606
0808082929292929292929292929292929290f2a2a2a2a2a2a2a2a2a2a2d2b0e292929290f1f1f2b2b2b2b2b2b1f1f1f1f1f2b2b2b2b2b2b2b2b2b2b2b2b0e2929290f2b2b2b2b2b01060606060606060606060606060606060606060606060606060602070707070707090a0b07072601060602070707070707070707010606
2929292929292929292929292929292929290f2a2a2a2a2a2a2a2a2a2a2d2b0e292929290f1f1f3f3f3f3f3f3f1f1f1f1f1f3f3f3f3f3f3f3f3f3f3f3f3f0e2929290f3f3f3f3f3f090d060606060606060606060606060606060606060606060606060207070707070707070707072601060602070707070707070707010606
29292929292929292929292929292929292929080808182a2a2a2a2a2a2d2b0e292929290f1f1f3d3d3d3d3d3d1f1f1f1f1f3d3d3d3d3d3d3d3d3d3d3d3d0e2929290f3d3d3d3d3d3d0106060606060606060606060606060606060606060606060606022525252525252525252525260106061c0404040404040404041d0606
020707090a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0d0606060606060606060606060606060606060606060606060606060606060606060c0a0a0a0a0a0a0a0a0a0a0a0a0a0d1f1f1f1f1f0a0a0a0a0a0a0a0a0a0a0d0c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0d
0207070707070707070707070707071f07070707070707070707070707070707070707383807070707073838383838010606060606060606060606060606060606060606060606060606060606060606060207470707070707070707070707011f07070707070707070707070707070102070707070707070707070707070701
0207070707070707070707070707071f07070707070707070707070707070707070707070707070707070707070707010606060606060606060606060606060606060606060606060606060606060606060207171f07070707070707070707011f0707071707071707070707077d0701020707031f0707070707070707070701
5b4a4a4a4a4a4a4a4a4d04040507071f070707070707070707070707070707070707590707070727070707070707070106060606060606060606060606060606060606060606060606060606060606060c0b07071f07070707070707070707011f07070707070707070707070304041d023707011f0707070707070707070701
0238383838383838380106060207071f0404050707070707070707070707070707076a4e4a4a4a4a4a4a4a4a4b0707010606060606060606060606060606060606060606060606060606060606060606023707071f07070707070707070707011f07070707070707070707071f1f0606020707011f0707070707070707070701
020707070707070707090a0a1f07071f060602252525255925252525592525252525010207070707070707070707070106060606060c0a0a0a0a0d060606060606060c0a0a0a0a0d0606060606060606023707071f03050707070707070707011f07070707070707070707071f1f0606020707011f0707070707070703050701
0207070707070707073838070707071f0c0a6e4a4a4a4a5d4a4a4a4a5d4a4a4a4a4d1d0207070707070707070707270106060c0a0a0b07070707090a0a0d060606060207070728010606060606060606023707071f01020707070707070707011f0707170707070707070707071f0606020707011f0707070707070701020701
0207070707070707070707070707071f1f07070707070707070707070707070707090a0b07264c4a4a4a4a4a4a4a4a5e0a0a0b07070707070707070707090a0a0a0a0b07070728010606060606060606022525071f090b6868686868687507011f0707070707070707070707071f0606020726011f68686868686868090b0701
020707070707070703040404040404041f070707070707070707070707070707070707070726692424070707070707070707070707070707070707070707070707070707070728090a0a0d06060606061c0405071f1f370707070707070707011f0707070707070727070707071f0606020726011f3707070707070707070701
02070707070707266d0a0a0a0a0a0a0a1f070707070707070707070707070707070707070726690707070707070707070707070707070707070707070707070707070707070707070728090a0a0a0a0a0a0a0b07071f070707070707070707011f0707070707070717070707071f06060207495e1f3707070707070707070701
020707070707072669242407070707281f070707070707070707070707074707070707070726690707070707494d0404040405070707070707070707070304040404050707070707070707070707070707070707071f0707030404040404041d1f0707070707070707070707071f0606020707261f370707070707030404041d
020707070707072669070707070707281f0707077868681768686868494a4a4a4a4a4a4a4a4a5f0707070707280106060606020707070707070707070701060606060207070707070707070707070707070707071f1f0707010c0a0a0a0a0a0a1f070707070707070707070707090a0a0b370726690707070707070106060606
0b070707070703044f070759360707281f07070707070707070707070707070707070707070707070707070728010606060602070707073435070707070106060606020707070707070707070707070707070707261f0728090b2407070707070707070707070707070707070707070707070726690707077868680106060606
370707070707010602360769360707171f07070707070707070707070707070707070707070707070707070728010606060602070707030404050707070106060606020707070707070707070707070707070707261f07070707070707070707070707070707070707070707070707070707072669070707070707090a0a0a0d
370707070707010602070769360707281f070707070707070707070707070703040404040404040404040404041d060606061c0404041d06061c0404041d06060606020707070707070707070304040404040404051f0707070707070304040404040404040404040404040404040404040404044f0707070707070707070701
370707070728010602070769360707281f27272717252525251725252525250106060606060606060606060606060606060606060606060606060606060606060606022525252525252525250106060606060606021f2727030404041d0606060606060606060606060606060606060606060606020707070707470707070701
__sfx__
000f0000170301b00017030190001a0301c000170301d0001d00017000170301a0001a030190001c03019000170301a00017030009001a030009001703000900009000090017030009001a030009001903000900
000f0000081301710017130141001a13028100171302a100081302c10017130161001a130331001c1302d1000813017100171301a1001a1301a1001713017100081300010017130001001a130001001913000100
000f00001f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f8301f830
000f0000141301710023130141002613028100231302a100141302c10023130161002613033100281302d100141301710023130141002613028100231302a1001413000100231300010026130001002513000100
000f0000101432c103101432c1032c103101432c10310143101433410310143341031610310143171031014310143171031014317103011031014300103101431014315103101430010316103101430010310143
00070000085500b550165500050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000300001a77018770167701377010770117001370014700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
011a00001b1441b14214144141421b1441b1421e1441e1421d1441b1441914419142191421914218144191441b1441b142141441414217144171421b1441b1421914417144141441414214142141421214416144
000400002a22325223222231c22318223152230e22307223062030920301203012030820301203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
00280020250451c045150451c04525045250052604525045230451a045130451a04523045230052504526045250451c045150451c04525045250052604525045230451a045130451a04523045230052300523005
000f0000175351b50517505195051a5351c505175351d5051d50517505175051a5051a505195051553519505175351a50517505005051a535005051753500505005050050517535005051a535005051c53500505
000f0000175351b50517505195051a5351c505175351d5051d50517505175051a5051a505195051553519505175351a50517505005051a535005051753500505005050050517535005051a535005051953500505
0005000036663296331d6330b63305633026330060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
010700001f255232552b255352050020500205232552a2552d2553225500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205
000700001c0551f0552105524055280552d0552d00527005250051f0051f00528005220051b005100050600500005000050000500005000050000500005000050000500005000050000500005000050000500005
013700001b5501b55514550145551b5501b5551e5501e5551d5551b5551955019550195501955518555195551b5501b555145501455517550175551b5501b5551955517555145501455014550145551255516555
00100000092521025215252122520e252152521a252172521025214252172521a2521c2521c2521c2421c2421c2421c2321c2321c2321c2251c2251c2251c2251c2251c2151c2151c2151c2151c2151c2151c215
011a00001b1541b15214154141521b1541b1521e1541e1521d1541b1541915419152191521915218154191541b1541b152141541415217154171521b1541b1521915417154141541415214152141521215416154
001a00001333312333003031433312333003031533313333153331233300303143331233300303143331333316333133330030314333123330030315333123331533312333003031433312333003031633313333
011a00001df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df521df52
00100000167731e7031e7031e70300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
012800202550523534285342a5342c5342c5322d5342f5342a5342a5222a5222a525265242652226522265252550523534285342a5342c5342c5322d5342c5342a5342a5222a5222a52500000000000000000000
01070000192341923214232142321c2321c232192321923225232252322023220232252322523225232252322523225232252322523225232252322523225235232021a202132021a20223202232022320223202
001000002d7502d7502d7502d7501e7501e7501e7501e750257502575025750257503c7003c7003b700397003770035700327002e7002b7000000000000000000000000000000000000000000000000000000000
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
