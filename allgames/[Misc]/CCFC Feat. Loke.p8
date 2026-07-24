pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--crazy cycling furry confusion
--ft loke made by the furluminati
versionnr = "1.4"

function _init()
 timestep = 0.0333
 world_w	= 128
 world_h = 128
 col_w	= 8
 line_h	= 8
 respawncd = 3
 respawnx = 8
 respawny = 8
 movecd = timestep*5
 carspeedmult = 0.05
 streetspawnmult = 1.5
 minstreetspawntime = 0.8;
 minspotspawntime = 0.5;
 missioncd = 10
 bonusdisptime = 1
 scene = "menu"
 splash = false
 badge = false
 deadpalsare = {} --keep em dead
 badgecycletime = 40
 badgecycleamp = 2 * #srccl
 initgame()
end

function _update()
 if (scene == "game") then
  updategame()
 elseif (scene == "menu") then
  updatemenu()
 elseif (scene == "end") then
  updateend()
 end 
end

function _draw()
 if (scene == "game") then
  drawgame()
 elseif (scene == "menu") then
  drawmenu()
 elseif (scene == "end") then
  drawend()
 end
end

function initgame()
 gametime = 0
 timer = 48
 partytime = 0
 curstreetspawnmult = streetspawnmult
 timeoutsound = false
 tosoundtime = 0
 players = {}
 loke = createloke()
 cart = createcart()
 blocks = {}
 missiontable = {}
 missionspots = {}
 missions = {}
 currentmissionuid = nil
 cars = {}
 marches = {}
 streets = {}
 createmissiontable()
 createstreets()
 createblocks()
 createmissionspots()
 rndspr = flr(rnd(#menusprites)+1)
end

function updatemenu()
bdgclindex = flr(badgecycleamp * sin((time()/badgecycletime)*2*3.14))
gametime = 0
 if (btnp(4) or btnp(5)) then
  scene = "game"
  music(0)
 end
 if (btnp(2,1)) then
  rndspr = flr(rnd(#menusprites)+1)
  badge = false
  splash = not splash
 end
 if (btnp(1,1)) then
  splash = false
  badge = not badge
 end
end

menusprites = {{x=56,y=96},{x=72,y=96},{x=88,y=96},{x=56,y=112},{x=72,y=112}}

function drawmenu()
 if (splash) then
  drawsplash()
  return
 elseif (badge) then
  drawbadge()
  return
 end
 cls(1)
 local textcl = 9
 local x = 22
 local y = 12 
 --pal(0,flr(rnd(16)))
 print("crazy cycling",x+16,y,7)
 print("c     c",x+16,y,8)
 print("furry confusion",x+12,y+10,7)
 print("f     c",x+12,y+10,8)
 sspr(104,96,24,16,42,38,48,32)
 palt(0,false)
 palt(10,true)
 sspr(menusprites[rndspr].x,menusprites[rndspr].y,16,16,26,38,32,32)
 pal()
 print("feat",x+3,y+64,7)
 print("loke greenthing",x+22,y+64,11)
 y =95
 --print("keep the party going",x+3,y,textcl)
 --y +=10
 print("missions extend time",x+3,y,textcl)
 y +=10
 print("arrows to move",x+15,y,textcl)
 y +=10
 print("z to start",x+23,y,textcl)
 print("v"..versionnr,110,120,2)
end

function drawsplash()
 cls(1)
 local x = 22
 local y = 12 
 sspr(80,24,24,8,24,10,96,32)
 --print("crazy cycling",x+16,y,7)
 --print("c     c",x+16,y,8)
 --print("furry confusion",x+12,y+10,7)
 --print("f     c",x+12,y+10,8)
 sspr(104,96,24,16,24,50,96,64)
 palt(0,false)
 palt(10,true)
 sspr(menusprites[rndspr].x,menusprites[rndspr].y,16,16,-8,50,64,64)
 pal()
end

srccl = {0,1,4,6,7,8,9,12,13,14}
targcl = {1,13,12,14,7}

function drawbadge()
 --printh("color index "..tostr(bdgclindex))
 cls(7)
 palt(0,false)
 palt(15,true)
 for i=1, #srccl do
  pal(srccl[i],targcl[(i+bdgclindex)%#targcl])
 end
 sspr(0,96,56,32,8,30,112,64)
 pal()
end

function updateend()
 if (btnp(4) or btnp(5)) then
  initgame()
  scene = "menu"
	end
end

function drawend()
  local x = 8
  local y = 73
  rectfill(x-1,y-9,x+116,128-4,1)
  x = 63
  if (partytime > 0) then
    pal(14,flr(rnd(16)))
    spr(235,12,69,2,2)
    spr(235,128-24,69,2,2)
    pal()
    local flip = flr(time())%2 == 0
    spr(237,27,96,2,2,flip)
    spr(237,128-37,96,2,2,not flip)
    pal(14,flr(rnd(16)))
    print("ragnar is pleased",x-30,y,14)
    pal()
    y = 88
    print("the party lasted for an extra",x-55,y,10)
    y +=14
    --pal(14,flr(rnd(16)))
    print(partytime.." hours",x-11,y,11)
    print("v"..versionnr,109,119,2)
  else 
    pal(14,8)
    spr(235,12,69,2,2)
    spr(235,128-24,69,2,2)
    print("ragnar is furious",x-30,y,14)
    pal()
    y = 88
    print("the party ended far too early",x-55,y,10)
  end
  y =116
  print("press z to restart",x-31,y,10)
end

function updategame()
 collisions()
 foreach(streets,updatestreet)
 foreach(cars,updatecar)
 foreach(missionspots,updatemissionspot)
 foreach(missions,updatemission)
 updateloke(loke)
 updatecart(cart)
 gametime += timestep
 timer -= timestep
 curstreetspawnmult = streetspawnmult*(0.95^(gametime/15))
 --printh("streetspawnmulti"..tostr(curstreetspawnmult))
 if (timer < timestep) then
  gametime += timer
  scene = "end"
  music(-1)
  sfx(10)
 end
 if (timer <= 10) then
  local mult = 5*(1-timer/10)+1
  --if (flr(gametime*mult) % 2 == 0 and not timeoutsound) then
  if (gametime >= tosoundtime and not timeoutsound) then
    timeoutsound = true
    sfx(11)
    tosoundtime = gametime + flr(timer)/10
  end
  --if (flr((gametime)*mult+1) % 2 == 0 and timeoutsound) then 
  if (gametime >= tosoundtime and timeoutsound) then
    timeoutsound = false
    sfx(12)
    tosoundtime = gametime + flr(timer)/10
  end
 end
end

function drawgame()
 cls()
 map(0,0)
 pal(14,flr(rnd(16)))
 spr(158,8*col_w,7*line_h,2,1)
 pal(14,flr(rnd(16)))
 spr(37,11*col_w,15*line_h,2,1)
 palt(0,false) --make black nontransparent
 palt(15,true) --make khaki transparent
 -- draw floaty spokguden era svin
 if (flr(gametime)%3==0) then
  spr(39,15*col_w,-1,1,2)
 elseif (flr(gametime)%2==0) then
  spr(39,15*col_w,0,1,2)
 else 
  spr(39,15*col_w,1,1,2)
 end
 pal()
 foreach(deadpalsare,drawdeadpalsare)
 drawloke(loke)
 drawcart(cart)
 foreach(cars,drawcar)
 foreach(missions,drawmission)
 rectfill(7*col_w,0,10*col_w,16,1)
 print("pts "..tostr(flr(partytime)),7*col_w+1,2,8)
 if (timer <= 10 and flr(timer)%2 != 0) pal(8,7)
 print("t "..tostr(flr(timer)),7.5*col_w+1,10,8)
 pal()
end

function drawdeadpalsare(dp)
  drawpalsare(dp.x,dp.y,dp.char,false)
  spr(61,dp.x,dp.y)
end

-- moves sprites and calls collision checking function
function move(s)
 -- todo collision handling
 --coll = checkcoll(s.x + s.vx, s.y + s.vy)
 --if (not coll) then
  s.x += s.vx
  s.y += s.vy
 --end
end

function lokemove(s)
  if (gametime < s.nextmove) return
  s.nextmove = gametime+s.movecd
  if (s.ax != 0) then 
    if (not checkblocks(s,s.x+col_w*sgn(s.ax),s.y)) then
      s.x += col_w*sgn(s.ax)
      return true
    end
  elseif (s.ay != 0) then 
    if (not checkblocks(s,s.x,s.y+line_h*sgn(s.ay))) then
      s.y += line_h*sgn(s.ay)
      return true
    end
  end
  return false
end

function stepmove(s)
  if (s.ax != 0) then 
    s.x += col_w*sgn(s.ax)
    return true
  elseif (s.ay != 0) then 
    s.y += line_h*sgn(s.ay)
    return true
  end
  return false
end

function checkblocks(a1,x,y)
  if (x<0 or x>=world_w or y<0 or y>=world_h) return true
	for a2 in all(blocks) do
    if x < a2.x+a2.w and
        a2.x < x+a1.w and
        y < a2.y+a2.h and
        a2.y < y+a1.h then
      --collide_event(a1, a2)
      return true
    end
  end
  return false
end

-->8
--loke controller
function createloke()
 local loke
 loke = createsprite("loke",64,64,0,0,0,0,8,8)
 loke.fw = 1
 loke.fh = 1
 loke.moveacc = 0.1
 loke.moving = false
 loke.nextmove = 0
 loke.movecd = movecd
 loke.maxv = 1
 loke.frames[1] = 0
 loke.frames[2] = 16
 loke.respawntime = nil
 loke.dir = "r"
 loke.dirf = {u=32,d=48,l=16,r=00}
 loke.lastx = loke.x-col_w 
 loke.lasty = loke.y
 loke.dead = false
 add(players, loke)
 return loke
end

function createcart()
 local cart
 cart = createsprite("cart",56,64,0,0,0,0,8,8)
 cart.fw = 1
 cart.fh = 1
 cart.frames[1] = 64
 cart.dir = "r"
 cart.dirf = {u=96,d=112,l=80,r=64}
 add(players, cart)
 return cart
end

function updateloke(l)
 if (l.dead) then
  l.x,l.y = respawnx*col_w,respawny*line_h
  l.lastx,l.lasty = (respawnx-1)*col_w,respawny*line_h 
  l.dir = "r"
  if (l.respawntime == nil) then
    l.respawntime = gametime + respawncd
  elseif (gametime >= l.respawntime) then
    l.dead = false
    l.respawntime = nil
  end
  return
 end
 if (btn(‹)) left(l)
 if (btn(‘)) right(l)
 if (btn(”)) up(l)
 if (btn(ƒ)) down(l)
 -- todo no strafe running
 --l.vx = min(abs(l.vx),l.maxv)*sgn(l.vx)
 --l.vy = min(abs(l.vy),l.maxv)*sgn(l.vy)
 local oldx,oldy = l.x,l.y
 if (l.ax != 0 or l.ay != 0) then
  if(lokemove(l)) l.lastx,l.lasty = oldx,oldy
 end
  l.ay = 0
  l.ax = 0
    --l.vx -= 0.9*l.maxv*sgn(l.vx)
    --l.vy -= 0.9*l.maxv*sgn(l.vy)
end

function updatecart(c)
  if (loke.lastx != cart.x or loke.lasty != cart.y) then
    cart.dir = loke.dir
   -- if (loke.lastx > cart.x) cart.dir = "r"
   -- if (loke.lastx < cart.x) cart.dir = "l"
   -- if (loke.lasty > cart.y) cart.dir = "d"
   -- if (loke.lasty < cart.y) cart.dir = "u"
   cart.x,cart.y = loke.lastx,loke.lasty
  end
end

function drawloke(l)
  -- blink dead loke
  if (l.dead and flr(gametime*10)%2==0) return
	drawdirsprite(l)
end

function drawcart(c)
  if (loke.dead and flr(gametime*10)%2==0) return
  drawdirsprite(c)
end

function left(l)
  l.dir = "l"
  l.ax = -l.moveacc
end

function right(l)
  l.dir = "r"
  l.ax = l.moveacc
end

function up(l)
  l.dir = "u"
  l.ay = -l.moveacc
end

function down(l)
  l.dir = "d"
  l.ay = l.moveacc
end

-->8
--car controller
function createcar(x,y,vx,vy,w,h,f,fw,fh,dir,dirf)
 local car
 car= createsprite("car",x,y,vx,vy,0,0,w,h)
 car.fw = fw
 car.fh = fh
 car.dir = dir
 car.dirf = dirf
 car.color = flr(rnd(15)+1)
 while (car.color == 5) do 
  car.color = flr(rnd(15)+1) 
 end
 add(cars,car)
 return car
end

function createupcar(s)
 local speed = s.speed*carspeedmult
 if (rnd(1)<0.5) then add(cars,createcar(s.x,s.y,0,-speed,8,8,45,1,1,"u",{u=45,d=44,l=29,r=28}))
 else add(cars,createcar(s.x,s.y,0,-speed,8,13,27,1,2,"u",{u=27,d=26,l=12,r=10}))
 end
end

function createdowncar(s)
 local speed = s.speed*carspeedmult
 if (rnd(1)<0.5) then add(cars,createcar(s.x,s.y,0,speed,8,8,44,1,1,"d",{u=45,d=44,l=29,r=28}))
 else add(cars,createcar(s.x,s.y,0,speed,8,13,26,1,2,"d",{u=27,d=26,l=12,r=10}))
 end
end

function createleftcar(s)
 local speed = s.speed*carspeedmult
 if (rnd(1)<0.5) then add(cars,createcar(s.x,s.y,-speed,0,8,8,29,1,1,"l",{u=45,d=44,l=29,r=28}))
 else add(cars,createcar(s.x,s.y,-speed,0,13,8,12,2,1,"l",{u=27,d=26,l=12,r=10}))
 end
end

function createrightcar(s)
 local speed = s.speed*carspeedmult
 if (rnd(1)<0.5) then add(cars,createcar(s.x,s.y,speed,0,8,8,28,1,1,"r",{u=45,d=44,l=29,r=28}))
 else add(cars,createcar(s.x,s.y,speed,0,13,8,10,2,1,"r",{u=27,d=26,l=12,r=10}))
 end
end

function updatecar(c)
 c.vx += c.ax
 c.vy += c.ay
 c.ax = 0
 c.ay = 0
 c.x += c.vx
 c.y += c.vy
 -- leftcar
 if (c.vx < 0 and c.x <= 0-col_w) del(cars,c)
 -- rightcar
 if (c.vx > 0 and c.x >= world_w) del(cars,c)
 -- upcar
 if (c.vy < 0 and c.y <= 0-line_h) del(cars,c)
 -- downcar
 if (c.vy > 0 and c.y >= world_h) del(cars,c)
end

-->8
--collisions
function collisions()
	for a in all(players) do
	 for b in all(cars) do
 		if(collide(a,b)) then
     if (a.type == "loke") then
      loke.dead = true
      sfx(5)
      if (currentmissionuid != nil) then
        sfx(7)
        adddeadpalsare(currentmissionuid,cart.x,cart.y)
        deletemission(currentmissionuid)
        currentmissionuid = nil
        return
      end
     elseif (a.type == "cart" and currentmissionuid != nil) then
      -- drop the current mission
      sfx(5)
      sfx(7)
      adddeadpalsare(currentmissionuid,a.x,a.y)
      deletemission(currentmissionuid)
      currentmissionuid = nil
      return
     end
    end
 	end
 end
end

function adddeadpalsare(uid,x,y)
  dp = {}
  dp.x,dp.y = x,y
  for i=1, #missions do
    if (missions[i].uid == uid) then
      dp.char = missions[i].palsare.cart[cart.dir]
    end
  end
  add(deadpalsare,dp)
  --dp.removetime = gametime+deadpalstimer
end

function collide(a1, a2)
 -- todo smaller hitboxes?
 if (a1==a2) then return end
 if a1.x < a2.x+a2.w and
    a2.x < a1.x+a1.w and
    a1.y < a2.y+a2.h and
    a2.y < a1.y+a1.h then
   --collide_event(a1, a2)
   return true
 end
 return false
end

-->8
--sprite handling

function createsprite(t,x,y,vx,vy,ax,ay,w,h)
 local sprite = {}
 sprite.type = t --type
 sprite.x = x
 sprite.y = y
 sprite.vx = vx
 sprite.vy = vy
 sprite.ax = ax
 sprite.ay = ay
 sprite.w = w
 sprite.h = h
 sprite.f = 1 
 sprite.fw = 1
 sprite.fh = 1
 sprite.animspeed = 1   
 sprite.frames = {}
 --add(sprites, sprite) 
 return sprite
end

function drawsprite(sprite)
 local flipx = false
 local flipy = false
 if(sprite.vx < 0) flipx = true 
 if(sprite.vy < 0) flipy = true 
 spr(sprite.frames[flr(sprite.f)], sprite.x, sprite.y, sprite.fw, sprite.fh, flipx, flipy)
end

function drawcar(sprite)
  if (sprite.fw == 2 or sprite.fh == 2) then
    pal(8,sprite.color)
  else
    pal(7,sprite.color)
  end
  if (sprite.color == 12) pal()
  spr(sprite.dirf[sprite.dir], sprite.x, sprite.y, sprite.fw, sprite.fh, flipx, flipy)
  pal()
end

function drawdirsprite(sprite)
  spr(sprite.dirf[sprite.dir], sprite.x, sprite.y, sprite.fw, sprite.fh, flipx, flipy)
end

-->8
--missions
missionspotsdata = {{x=7,y=5,delay=20,cd=6},
                    --{x=8,y=5,delay=30,cd=missioncd},
                    {x=9,y=5,delay=10,cd=6},
                    {x=7,y=8,delay=1.5,cd=6},
                    --{x=8,y=8,delay=10,cd=missioncd},
                    {x=9,y=8,delay=1,cd=6}}

missionsdata = {{stopx=1,stopy=2,chance=10,timebonus=6,bubble=128,marker=130}, --food
                {stopx=14,stopy=10,chance=10,timebonus=6,bubble=144,marker=146}, -- bread
                {stopx=14,stopy=1,chance=10,timebonus=6,bubble=160,marker=162}, -- era svin
                {stopx=1,stopy=5,chance=10,timebonus=6,bubble=176,marker=178}, -- trash
                {stopx=11,stopy=14,chance=10,timebonus=6,bubble=129,marker=131}, -- collective
                {stopx=1,stopy=14,chance=10,timebonus=6,bubble=145,marker=147}} -- systembolaget

palsare = {{char=79,cart={u=75,d=76,l=77,r=78}}, --zee
          {char=95,cart={u=91,d=92,l=93,r=94}}, --noah
          {char=111,cart={u=107,d=108,l=109,r=110}}, --cyanid
          {char=127,cart={u=123,d=124,l=125,r=126}}, --max
          {char=90,cart={u=86,d=87,l=88,r=89}}, --kryllan
}
-- hack to show trash icon
trash = {char=74,cart={u=70,d=71,l=72,r=73}} --max

-- weighted list of missions
function createmissiontable()
  missiontable = {}
  for i=1, #missionsdata do
    for j=1, missionsdata[i].chance do
      add(missiontable,i)
    end
  end
end

function createmissionspots()
  foreach(missionspotsdata,createmissionspot)

end

function createmissionspot(data)
  local missionspot = {}
  missionspot.x = data.x*col_w
  missionspot.y = data.y*line_h
  missionspot.delay = data.delay
  missionspot.cd = data.cd
  missionspot.active = false
  missionspot.occupied = false
  missionspot.spawntimer = 0 --time since last spawn
  missionspot.minspawntime = minspotspawntime
  missionspot.avgspawntime = data.cd --avarage spawn frequency
  missionspot.nextspawn = (nrand()+1)*missionspot.avgspawntime
  add(missionspots,missionspot)
end

function spawnmission(s)
  index = missiontable[flr(rnd(#missiontable)+1)]
  while (checkindex(missions,index)) do
    index = missiontable[flr(rnd(#missiontable)+1)]
  end
  --local mission = missionsdata[index]
  local mission = {}
  mission.index = index
  mission.chance = missionsdata[index].chance
  mission.timebonus = missionsdata[index].timebonus
  mission.bubble = missionsdata[index].bubble
  mission.marker = missionsdata[index].marker
  mission.uid = flr(rnd(30000))
  -- set startpoint to the mission spot that spawned the mission
  mission.startx,mission.starty = s.x,s.y
  mission.stopx = missionsdata[index].stopx*col_w
  mission.stopy = missionsdata[index].stopy*line_h
  mission.missionspot = s
  mission.bonusdisptimer = bonusdisptime
  mission.bonusdispy = 0
  mission.palsare = palsare[flr(rnd(#palsare)+1)]
  if (mission.bubble==176) mission.palsare = trash
  add(missions,mission)
  return mission
end

function updatemissionspot(s)
  if (gametime >= s.delay and s.active == false) then
    s.active = true
    s.spawntimer = 0
    return
  end
  if (not s.active) return
  if (s.occupied) return
  if (#missions == 0) then
    s.occupied = true
    spawnmission(s)
  end
  if (spawncheck(s)) then
    s.occupied = true
    spawnmission(s)
  end
end

function updatemission(m)
  if (currentmissionuid == nil and loke.x == m.startx and loke.y == m.starty) then
    sfx(8)
    currentmissionuid = m.uid
    m.missionspot.occupied = false
  elseif (currentmissionuid != nil and loke.x == m.stopx and loke.y == m.stopy) then
    m.bonusdispy -= 1
    currentmissionuid = nil
    sfx(6)
    partytime += m.timebonus
    timer += m.timebonus
  elseif (m.bonusdispy < 0) then
    printh("dispy is "..tostr(m.bonusdispy))
    printh("disptimer is "..tostr(m.bonusdisptimer))
    m.bonusdispy -= 0.3
    m.bonusdisptimer -= timestep
  end
  if (m.bonusdisptimer <= 0) then
    del(missions,m)
  end
end

function checkindex(table,index)
  for i=1, #table do
    if (table[i].index == index) then
      return true
    end
  end
  return false
end

function deletemission(uid)
  for i=1, #missions do
    if (missions[i].uid == uid) then
      del(missions,missions[i])
      return
    end
  end
end

function drawpalsare2(x,y,sprite,colors,flipped)
    palt(0,false) --make black non transparent
    palt(7,true) --make white transparent
    pal(6,colors.fur)
    pal(3,colors.hair)
    pal(5,colors.nose)
    pal(12,colors.eyes)
    pal(14,colors.mouth)
    pal(10,colors.shirt)
    pal(2,colors.pants)
    pal(0,colors.paws)
    spr(sprite,x,y,1,1,flipped)
    pal() --reset all palette changes
end

function drawpalsare(x,y,sprite,flipped)
    palt(0,false) --make black non transparent
    palt(10,true) --make that ugly yellow transparent
    spr(sprite,x,y,1,1,flipped)
    pal() --reset all palette changes
end

function drawmission(m)
  if (m.bonusdispy < 0) then
    pal(10,flr(rnd(16)))
    spr(23,m.stopx,m.stopy+m.bonusdispy,1,1)
    pal()
    return
  end
  if (currentmissionuid != m.uid) then
    --local flipped = (rnd(1)>0.5)
    --local flipped = false
    drawpalsare(m.startx,m.starty,m.palsare.char,flipped)
    -- draw mission bubble
    spr(m.bubble,m.startx,m.starty-line_h,1,1)
  elseif (currentmissionuid == m.uid) then
    drawpalsare(cart.x,cart.y,m.palsare.cart[cart.dir],m.palsare.colors,false)
    if (flr(gametime) % 2 == 0) then
      --spr(m.bubble,cart.x,cart.y-line_h,1,1)
    end
    if (flr(gametime*3) % 2 == 0) pal(10,1)
    spr(m.marker,m.stopx,m.stopy,1,1)
    pal()
  end
end


-->8
--streets, blocks
streetsx = {0,0,{d="u",t="c",v=10,s=2},0,0,0,{d="d",t="c",v=5,s=5},0,0,0,{d="u",t="c",v=5,s=5},0,0,{d="d",t="c",v=10,s=3},{d="u",t="c",v=10,s=3},0}
streetsy = {0,0,{d="r",t="c",v=5, s=5},0,0,{d="r",t="p",v=2,s=20},0,0,{d="l",t="p",v=2,s=20},0,0,{d="l",t="c",v=10,s=3},{d="r",t="c",v=10,s=3},0,{d="l",t="c",v=10,s=5},0}

blocksdata = {{x=0,y=0,w=1,h=2},{x=4,y=0,w=2,h=2},{x=7,y=0,w=3,h=2},{x=11,y=0,w=2,h=2},{x=15,y=0,w=1,h=2},
          {x=0,y=3,w=1,h=2},{x=4,y=3,w=2,h=2},{x=7,y=3,w=3,h=2},{x=11,y=3,w=2,h=2},{x=15,y=3,w=1,h=2},
                  {x=3,y=5,w=1,h=4},
          {x=0,y=6,w=2,h=1},{x=4,y=6,w=2,h=2},{x=7,y=6,w=3,h=2},{x=11,y=6,w=2,h=2},{x=15,y=6,w=1,h=2},
          {x=0,y=7,w=2,h=4},
                            {x=4,y=9,w=2,h=2},{x=7,y=9,w=3,h=2},{x=11,y=9,w=2,h=2},{x=15,y=9,w=1,h=2},
          {x=0,y=13,w=2,h=1},{x=4,y=13,w=2,h=1},{x=7,y=13,w=3,h=1},{x=11,y=13,w=2,h=1},{x=15,y=13,w=1,h=1},
          {x=0,y=15,w=2,h=1},{x=4,y=15,w=2,h=1},{x=7,y=15,w=3,h=1},{x=11,y=15,w=2,h=1},{x=15,y=15,w=1,h=1}
          
          }
                

function createstreets()
  for i=1, #streetsx do
    local street = createstreet(streetsx[i],i)
  end
  for i=1, #streetsy do
    createstreet(streetsy[i],i)
  end
end

function createstreet(data,i)
 if (data == 0) return {}
 local street = {}
 street.dir = data.d  --direction/, u=up d=down l=left r=right
 street.type = data.t --c=cars p=pedestrian
 street.speed = data.v 
 street.spawntimer = 0 --time since last spawn
 street.minspawntime = minstreetspawntime
 street.basespawntime = data.s
 street.avgspawntime = street.basespawntime*streetspawnmult --avarage spawn frequency
 street.nextspawn = (nrand()+1)*street.avgspawntime

 if (data.d == "d") then
  street.x = (i-1)*col_w
  street.y = -line_h
 elseif (data.d == "u") then
  street.x = (i-1)*col_w
  street.y = world_h
 elseif (data.d == "r") then
  street.x = -col_w
  street.y = (i-1)*line_h
 elseif (data.d == "l") then
  street.x = world_w
  street.y = (i-1)*line_h
 end
 add(streets, street) 
 return street
end

function createblocks()
  foreach(blocksdata,createblock)
end

function createblock(data)
  local block = {}
  block.x,block.y,block.w,block.h = data.x*col_w,data.y*line_h,data.w*col_w,data.h*line_h
  add(blocks,block)
  return block
end

function updatestreet(street)
  if (street.type != "c") return
  if (street.dir == "u" and spawncheck(street)) then
    createupcar(street)
    street.spawntimer = 0
  elseif (street.dir == "d" and spawncheck(street)) then
    createdowncar(street)
    street.spawntimer = 0
  elseif (street.dir == "l" and spawncheck(street)) then
    createleftcar(street)
    street.spawntimer = 0
  elseif (street.dir == "r" and spawncheck(street)) then
    createrightcar(street)
    street.spawntimer = 0
  end
end


-->8
--utility functions

-- normal distribution function
function nrand()
 local x1,x2,rad,c = 0,0,0,0
 while rad>=1 or rad==0 do
  x1=2*rnd()-1
  x2=2*rnd()-1
  rad=x1*x1+x2*x2
 end
 c=sqrt(-2*(rad*rad)/rad)
 return x1*c
end

-- for streets and spots
function spawncheck(s)
  s.spawntimer += timestep
  if (s.spawntimer>=s.nextspawn) then
    s.spawntimer = 0
    if (s.type == "c") s.avgspawntime = s.basespawntime * curstreetspawnmult
    s.nextspawn = (nrand()+1)*s.avgspawntime
    while (s.nextspawn < s.minspawntime) do
      s.nextspawn = (nrand()+1)*s.avgspawntime
    end
    return true
  else
    return false
  end
end

__gfx__
000066005555555566566656ddd6ddd55555555590a0a0a90544455addd6ddd50000000000000000000088888000000000000888880000005bb3bbccccbb33b5
b000babb5555555555555555d66d66d5555555559a0a0a09a556445addd6ddd50000000000000000008c88888c8000000008c88888c80000333bcccccccc33b3
bb088beb55555555555555556ddddd655555555595555559a5446440ddd6d0d5000000000000000008cc88888cc88000088cc88888cc8000343ccccddcccc433
bbc8b00055555555555555554cc44cc4555555555555555504644440ddd6d5d50000000000000000e8c888888cc88a00a88cc888888c8e00b4bccccddccccb43
9cc9bb9055555555555555554444444455555555555555550444445addd6ddd500000000000000008888c8cc88c88800888c88cc8c888800bbcdccccccccdc4b
01b0991051115555555555554a44ccc49a0a0a0955555555a554645ad0d6ddd50000000000000000e88cc8ccc8888a00a8888ccc8cc88e00bbcdccccccccdcbb
16bb016155111555555555554554ccc490a0a0a955555555a5464440d5d6ddd50000000000000000611888888811860068118888888116003cccddccccddcccb
0100001055555555555555554554ddd4955555595555555505444450ddd6ddd50000000000000000011000000011000000110000000110003cccccddddccccc3
006600005555555555555555555555555666666666666666666666650000000000000000000000000888888008a88a800000000000000000bccccccccccccccb
bbab000b56333365555555555555555556644444444444444444466500000000000000000000000008cccc80088888800077770000777700bccccccccccccccb
beb880bb6333333655555555555555555666666666666666666666650000aaa000000000000000001c8888c118cccc810777777007777770bdcdcccccccccdcb
000b8cbb63333336555555555555dd5556ffffffffffffffffffff650a00a00000000000000000001c8888c11c8888c187c7cc7977cc7c77bcdccdcccccdccdb
09bb9cc963b73336555555555555dd5556fcffcffcfcffcffcffcf65aaa0aaa0000000000000000008888880088888807cc7ccc77ccc7cc7bbddcccdcdccddbb
01990b10633b3336555555555555555556ffffffffffffffffffff650a00a0a00000000000000000088888800888888087777779977777783bcdddccccdddcbb
1610bb6163300336555555555555555556ff5fcffcff5fcffcf5ff650000aaa0000000000000000008cccc800c8888c061177116611771163bd5cddddddc5d3b
0100001056333365555555555555555556ff5fffffff5ffffff5ff650000000000000000000000000cccccc00cccccc001100110011001104bd444cccc444d33
00001000000000005555555655555555000000005666c66cc66c6665ffffffff333bbbb3555755750cccccc008cccc800077770000777700bb54445445444dbb
00066600000000005555555555555555000000006644444444444466fffff0ff33bbbb3355766766188888811888888117cccc7117cccc71bb554444444445bb
0b9bbb9b000000005555555655555555000000006464c4c4c44c4646ffff0fffb4b777b45576d76d18888881188888811777777117777771bbd5554444555d33
00888880000000005555555655555555000000006446ffffffff6446f0f00f0fbb75e5745576d76d08a88a800ee88ee0077cc770077cc770bbd4455555544d43
0008b800000000005555555655555555000000006446cfefeffc64460f0770f0b75eee575576d76d066666600666666007cccc7007cccc70b3d545444d545dbb
000cbc00000000005555555555555555000000006446dfdddffd644600f00f0075eeeeee5666666600000000000000001777777117777771b3d545445d545d3b
000b9b00000000005555555655555555000000006446bbbbbbbb6446f000000feeeeeee55655555500000000000000001697796116877861bbd445445d544d3b
00009000000000005555555655555555000000006446bbbbbbbb6446ff0000ff7eee55575656556500000000000000000066660000666600bbd445444d544dbb
00090000000000005555551500000000566666666666666666666665fff00fff7eee55575656666611111111111111111111000008000000bbd445444d544dbb
00666000000000005555511100000000664444444444444444444466fff00fffeeeeeee55655555511888118881888818881000000800808b4d445444d544d4b
00aba000000000005555511100000000646444444444444444444646fff00fff75eeeeee5666668618811188111811188111000000808080b45445444d54454b
08beb8000000000055555115000000006446ffffffffffffffff6446ffff0f0f775eee575688666618111181111888181111000088800000b44555444d55544b
b99999b00000000055555515000000006446cfcfcfcfcfcfcfcf6446fffff0ff7765e5775688688818111181111811181111000008088080b44444555544444b
00c9c0000000000055555555000000006446dddfdddfdddfdddf6446ffffffff776776775686686818811188111811188111000000808080b44444400444444b
00b9b0000000000055555555000000006446bbbbbbbbbbbbbbbb6446ffffffffb76776775655666611888118881811118881000008088808bb444440044444b3
000100000000000055555555000000006446bbbbbbbbbbbbbbbb6446ffffffffbb67767b56556666111111111111111111110000000808005b3b444554443b35
000000000000000000000000000000000000000000000000aaaaaaaaaaa1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa006aaaaa0000aa0000aaaaa006aaa
000000000000000000000000000000000000000000000000aaa11aaaaa16aaaaaaaaaa1aa1aaaaaaaaa11aaaaad5daaaaa0f6f0aaa0a6f0000f6a0aaa0f6f0aa
000000000000000000000000000000000000000000000000aa1111aaaaa11aaaaaaaaa6116aaaaaaaaa6aaaaaa000aaaaaa566aa0aa5666006665aa0aa56606a
000000000000000000000000000000000000000000000000aa1111aaaa1111aaaaa1111aa1111aaaaa111aaa6a000a6aa606e6060da6e660066e6ad0aa6e6a6a
000000090000000000000000000000000000000000000000aa1111aaaa1111aaaa11111aa11111aaa11111aa6000006aa6a000a6addaa00aa00aaddaaa00006a
099999900000000000000000000000000000000000000000aaaa61aaaa1111aaaaaaaaaaaaaaaaaaa111111aaa606aaaaaddddaaaaa666aaaa666aaaaa6ddaaa
099119900000000000000000000000000000000000000000aaaa1aaaaaaaaaaaaaaaaaaaaaaaaaaaaa11111aaaaaaaaaaa0a0aaaaaaaaaaaaaaaaaaaaa6dd65a
000110000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00aaa
000000000000000000000000000000000000000000000000aaaaaaaaaaaeecaaaaaeeeeaaeeeeaaaaeecaa77aaaaaaaaaaa6e6aaaaaaae6aa6eaaaaaaa6e6aaa
000000000000000000000000000000000000000000000000aa757aaaaaebcbeaaaeacbeeeebcaeaaebcbea7caa0e0aaaaaad6daaaaaa6d6ee6d6aaaaaad6daaa
000000000000000000000000000000000000000000000000aaeeeaaaaaa5ccea7aa5ccceeccc5aa7a5cce7a7aa666aaaaaae66aa0aae666ee666eaa0aae66a6a
0000000000000000000000000000000000000000000000007aeeea7aacc7e7cc7ca7e7ceec7e7ac7a7e7acac6a666a6aa606260602a6266aa6626a20aa626a6a
900000000000000000000000000000000000000000000000cceeeccaa7ac7ca7accaa7caac7aaccaac77cca7606e606aa6a000a6a22aa00aa00aa22aaa00006a
099999900000000000000000000000000000000000000000aacecaaaaaccccaaaaa7ccaaaacc7aaaac7caaacaa6e6aaaaa2222aaaaa666aaaa666aaaaa622aaa
099119900000000000000000000000000000000000000000aaaaaaaaaa7a7aaaaaaaaaaaaaaaaaaaa7ccc7c7aaaaaaaaaa0a0aaaaaaaaaaaaaaaaaaaaa62266a
000110000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa77aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00aaa
0000900000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaf4faaaaaaa4faaf4aaaaaaaf4faaa
0000900000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0b0aaaaaa9f9aaaaaaf9f44f9faaaaaa9f9aaa
0999999000000000000000000000000000000000000000000000000000000000000000000000000000000000aafffaaaaaabffaa0aabfff44fffbaa0aabffafa
0944449000000000000000000000000000000000000000000000000000000000000000000000000000000000fafffafaa00f3f0000af3ffaaff3fa00aaf3fa0a
194444910000000000000000000000000000000000000000000000000000000000000000000000000000000000f4f00aafa000afa00aa00aa00aa00aaa00000a
1999999100000000000000000000000000000000000000000000000000000000000000000000000000000000aaf4faaaaa0000aaaaaf00aaaa00faaaaa000aaa
1899998100000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa0a0aaaaaaaaaaaaaaaaaaaaaf00f4a
0996699000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00aaa
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaa7a7aaaaaaaa7aa7aaaaaaaa7a7aaa
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa424aaaaaac8caaaaaa8c8aa8c8aaaaaac8caaa
0999999000000000000000000000000000000000000000000000000000000000000000000000000000000000aa888aaaaaa288aa4aa5888aa8885aa4aa588a4a
09444490000000000000000000000000000000000000000000000000000000000000000000000000000000004a888a4aa487e78448a7e78aa87e7a84aa7e7a4a
19444491000000000000000000000000000000000000000000000000000000000000000000000000000000004878784aa4a444a4a88aa48aa84aa88aaa84484a
1999999100000000000000000000000000000000000000000000000000000000000000000000000000000000aa7a7aaaaa4444aaaaa448aaaa844aaaaa444aa4
1999999100000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa4a4aaaaaaaaaaaaaaaaaaaaa444847
0999999000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa44aaa
07677670077777705aaaaaa55aaaaaa5555555555555555555555555556555555555565556664444444466655555555555555555555555555555555555555555
7677677777777777aa6aa6aaaaaaaaaa566666666666666666666665566655555555666564646b3333b646465666666656666666566666666666666666666665
7767f47777777747a6aa6aaaaaaaaa4a564644444444444444446465646465555556464646f6463443646d645655555556555555561111111111111111111165
767ffb7776666647aa6af4aaa666664a56446666666666666666446544644644446446446fff64344346ddd65655555556555555561188811888188881888165
77fff77774444447a6affbaaa444444a5644644444444444444644654464444333444644fcfcf6b44b6dcdcd5655555556566565561881118811181118811165
77ff777774777747aafffaaaa4aaaa4a564464444444444444464465446444b343444644ffffffbbbbdddddd5655565556556565561811118111188818111165
0777777007777770aaffaaaaaaaaaaaa56446449b9b99bb994464465446444bb4b444644cf1fcf4444dcd1dc5655565556556565561811118111181118111165
00007000000070005aaaaaa55aaaaaa5564466666666666666664465446444bbbb444644ff1fff4444ddd1dd5655555556566565561881118811181118811165
57944775077777705aaaaaa55aaaaaa5564644444444444444446465446444333b44464456664444444466655655555556555555561188811888181111888165
7795477777477337aa944aaaaaaaaaaa56644444444444444444466546d644343b446d6464646b3333b646465655555556555555561111111111111111111165
7779477777477667aa954aaaaa4aa33a5666666666666666666666656ddd64343b46ddd646e64634436467645666666656666666566666666666666666666665
7444774474447667aaa94a44aa4aa66a56ffffffffffffffffffff65dcdcd6b4bb6dcdcd6eee6434434677765644444456666666544444444444444444444445
7454745976667337a444a459a444a66a56fccfccfccffccfccfccf65ddddddbbbbddddddecece6b44b67c7c7564cc4cc565556cc5466566444444444eee44445
7999749974447337a454a499a666a33a56ffffffffffffffffffff65cdddcd4444dcdddceeeeeebbbb7777775644444456555666546656644cc44ee4eee4ee45
7777777707777770a999aaaaa444a33a56ff5fccfccffccfccf5ff65dd1ddd4444ddd1ddce1ece44447c717c564454cc56555666546656644cc44ee4eee4ee45
55557555000070005aaaaaa55aaaaaa556ff5ffffffffffffff5ff65dd1ddd4444ddd1ddee1eee444477717756445444565556665466566444444444eee44445
07755770777777775aaaaaa55aaaaaa555555555555555550000000000000000666666665446444633bbbb66566c66c66c66c665555555555555555555555555
7756657777777777aaa00aaaaaaaaaaa566666666666666500000000000000005566655545464446343b33565664444444444665566666666666666666666665
7575575774477007aa0660aaa6aaa6aa56dddddddddddd6500000000000000005646465544564446b4bb4356566c66c66c66c665564644444444444444446465
7755557774477077a0a00a0aaa6a6a6a56dddddddddddd6500000000000000006446446545464446bbbb4b5656ffffffffffff65564466666666666666664465
7775577777744707aa0000aaaffffffa56dddddddddddd6500000000000000004446464646464446b3bbbb5656fcffcffcffcf65564464444444444444464465
7775575777744007aaa00aaaa999999a56ddd6dddd6ddd6500000000000000004446464646464446bbbbbb5656ffffffffffff65564464444444444444464465
0777557077777777aaa00a0aa444444a56ddd6dddd6ddd650000000000000000446d6446446d6446bbb3bb5656ff5fcffcf5ff65564464455bb5bb5b54464465
00000700000070005aaa00a55aaaaaa556dddddddddddd65000000000000000046ddd64646ddd646bb3bb35656ff5ffffff5ff65564466666666666666664465
07777770077117705aaaaaa50000000056dddddddddddd6556666666666666656ddddd666ddddd66bbbbbb565777777777777775564644444444444444446465
7777717777767777aaaaaaaa0000000056dddddddddddd655655555555555565ddddddd687878786b43bb3565777777777777775566444444444444444444665
7777761777111777aaaaa1aa0000000056666666666666655655555555555565cd11dcc687878786b33b3b565755555555555575566666666666666666666665
7711117771111177aaaaa61a0000000056ffcfcfcfcfcf655666666666666665cd11dcc6dcccd116b43bbb565766336666666675564444444444444444444465
7111117771111117aa1111aa0000000056ffffffffffff65564cc4cccc4cc465dd11ddd6ddddd116bbbbb5555753aa3600006575564cc4cc4cc44cc4cc4cc465
7111117777111117a11111aa0000000056ffcfcfcfcfcf6556444444444444655555555557557555555555565766336666666675564444444444444444444465
0777777007777770a11111aa0000000056515cc5cc515565564454cccc454465555555555775775555555555575ccc5ccc511575564454cc4cc44cc4cc454465
00000000000007005aaaaaa50000000056515cc5cc51556556445444444544656666666666666666666656565766666666611675564454444444444444454465
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaaaaaaaaaaaa4aaaaaaaaaaaaaaa00aaaaaaa0aaaa0aaaa000000000000003232300000
fffffffffffffffffffffffffffffff000ffffffffffff44ffffffffaaaaaaaaaaaf4aaaaaaaaaaaaaa600a0aaaaaaaaa4aaaaaa000000000000032bb3b00000
fffffffffffffffffffffffffffffff0000fffffffffff44ffffffffaaaaaaaaffa4444aaaaaaaaa6600000aaaaaaaaaa4aa4a0a0000000000bb02bbba3a0000
ffffffffffffffffffffffffffffffff000ffff1111ff44ff4ffffffaaaaaaaabbf4ffaaaaaaaaaa556060a0aaaa0aa4aa4a4aaa0000000000bb00bba2b2b000
fffffffff44411fffffffffffffffffff000fff1f11ff44444ffffffaaaaaaaafbff7fbbaaaaaaaa6566f655aaaaaaaa4a4aa4aa00000000000880b3bbbbb000
fffffff14444411ffffffffffffffffff000fff1ff11f4444fffffffaaaaaaaa4ff79fffaaaaaaaa066f5666aaaaaa4aaaaaa4a0000000000b00280b33322000
ffffff114222250ffffffffffffffffff000fff11f11f44ffff666ffaaaaaaaa4ffffff3aaaaaaa00666666eaaaaaaaaaa0aaaaa000000000bb0028888800000
fffff11122225250fffffffffffffffff000000f111f4444ff66f66faaaaaaafaaffff3faaaaaa06006666e6aaaaaaaaa06000aa000000000bb000889999bb00
ffff00112b222330fffffffffffbfbffff00000fffff44f4ff66f66faaaaaaff00affffaaaaaaa6666a6666aaaaaaaaaaa00000a0000000003bb08822292bb00
ffff0001bb323bbbfffffffffffbfbfffffffffffffffff44f6666ffaaaaaaafa000000aaaaaaaa6a000000aaaaaaaa0aa00000000000000033bb8cc2095d000
fff00000b33bbbaabffffffffffbbbffffffffffffffffffff66ffffaaaaaaaaaaaa0000aaaaaaaaaaaa0000aaaaaaaaaa0000000000000000339ccbb9995d00
fff00eeb33aaab3abffffffffffbbbbfffbbbbbffffffffffff66fffaaaaaaaaaa444449aaaaaaaaaa444449aaaaaaaaaa4444490044444999995ccbb9595d00
ffeeeeebbba3ab2abbfffffffffbbbbffbbbbbbbbfffffffffffffffaaaaaaaaaa445449aaaaaaaaaa445449aaaaaaaaaa44544900445449999599bb90565d00
ffeeeddbbba2abbbb5bffffffff1333ffbbbbbbbbbbfffffffffffffaaaaaaaaaa456549aaaaaaaaaa456549aaaaaaaaaa4565490045654999956bb900565d00
ffeedddbbbbbbbb5bbbffffffff0111fbbbbb88bbbbbbbffffffffffaaaaaaaaaa456549aaaaaaaaaa456549aaaaaaaaaa45654900456549999565bb00555500
ff0eddcbbbbbbbbbbbbfffffff00001fbbbb7889bb333fffffffffffaaaaaaaaaaaa5aaaaaaaaaaaaaaa5aaaaaaaaaaaaaaa5aaa000050000000550000055000
ff05dcc3bbbbb3bbbb2fffffffe000fbbbb77889933fffffffffffffaaaaaaaaaaaaaeeaaaaaaaaaaaaaaeaa0000000aa0000000000000323230000000000000
ff005ccc3bbbbb333222fffffdeeefbbbb6778899cffffffffffffffaaaaaaaaaaaceeaeaaaaaaaaaaa6eaaa0000c00aa00c00000000032bb3b0000000000000
ff1005cc93bbbbbbb555899ccddeffbbb66677899cccffffffffffffaaaaaaaacceeeeeaaaaaaaaa66aeeeea000cfcaaaacfc00000bb02bbba3a000000000000
ff11f5559933bb3377665559ccddfbb144667789ccdddfffffffffffaaaaaaaa77ceceaeaaaaaaaa776e66aa000cffc11cffc00000bb00bba2b2b00000000000
ff41fff55998337776664415555ff00114666789ccddddffffffffffaaaaaaaac7cc7c55aaaaaaaa676676ee0000ffc11cff0000000880b3bbbbb00000000000
ff4fffff55888777666441110005500114466799cdd335ffffffffffaaaaaaaaecc7bc77aaaaaaaae667e6770000cfccccfc00000b00280b3332200000000000
ff6fffff99887776664441150005500114466f9ccd3333ffffffffffaaaaaaaeecccc77eaaaaaaaae6666772000cacc77ccac0000bb002888880000000000000
ff6fffff9998777666444110005500555544f5555d53333fffbbffffaaaaaae7eeccc7e7aaaaaaa6aa666727000acc7aa7cca0000bb000889999bb0000000000
fffffffcc995556664441110055500114455577755d33333fbbbffffa777aa777cacc77aaaaaaa6666a6677a00ccc7aeea7ccc0003bb08822292bb0000000000
ffffffcccc55dd66644411000550011444666778885533333bbbbfffa777aae7ecccc77aaaaaaaa6a66dddda0aaccc7aa7cccaa0033bb8cc2095d00000000000
fffffddcc55ff5554441110005500114446667788999ccdd3bbbbfffa77ccaeeaa7ccc77aaaaaaaaaaaadddd0aa11cc77cc11aa000339ccbb9995d0000000000
fffffdddee000111554111005550011444666778899cccddbbbbbfffaacc77aac7444449aaaaaaaaaa444449aa1111cccc1111aa00995ccbb9595d0000000000
fffffddeee0011bbbf5555555500111444666788999ccdddbbbbffffaaa77cc7cc445449aaaaaaaaaa445449aaaaaaa11aaaaaaa000599bb90565d0000000000
ffffffeeee001bbbbbffffff5500111444fffff899cccddbbbbbffffaaaaac777a456549aaaaaaaaaa456549aaaaaaaccaaaaaaa00056bb900565d0000000000
ffffffffe00113bbbbfff5555ffffffffffffffff9ccdddbbbbfffffaaaaaaaaaa456549aaaaaaaaaa4565490000000000000000000565bb0055550000000000
ffffffffffffff3333fff555ffffffffffffffffffffdddfffffffffaaaaaaaaaaaa5aaaaaaaaaaaaaaa5aaa0000000000000000000055000005500000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000
__map__
a9aa221284860184858613848622122806000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b9ba221394961294959612949622a23806000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1282011212121212231212012312121206000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a8aa2223adaf13adaeaf12848622138b06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b8ba2204bdbf12bdbebf13949622329b06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12b2120612121212121212121212121206000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111122068887238d8e8f23a4a522138c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0f22069897329d9e9f12b4b522129c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1f220612121212121223121201121306000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2f2205878813adaeaf12878822122906060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3f2213979812bdbebf12979822923906060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1312121212231201121212122312231206060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020206060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b6b72232999a12898a89128a992213b606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1293121202023202020212830212011206000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbc22129a99133435361225262212b606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
000400002663036630356302b6301d6300c6300b2001020013200172001a2001e2001f2001f200212002120022200232000000000000000000000000000000000000000000000000000000000000000000000000
000400001a5502b55028550245502555027550295502b5501a5502b5502c5501e5502655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000175501a550215501a5501655014550125501155012550165501b5501c5501b5501955017550155501455013550135501255012550125501155011550115501255012550115500d550095500655002550
0002000021550235501d5501855014550105500b55007550045500f55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001005010050100501005010050103501005010050103501035010350103501335013350133501335013350133501335010450000000000000000000000000000000000000000000000000000000000000
000c0000180501d0501d000180501c0501f000240501d0501d0001d0501d0001d0501d0001d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001900001f75020700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001900002075020700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00 01 43 44
00 02 03 43 44
00 00 04 43 44
02 02 04 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
