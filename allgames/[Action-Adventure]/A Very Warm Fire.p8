pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--a very warm fire
--by jusiv

--[[
made from 1/2/2018 to 1/7/2018
for the winter break jam run by
worcester polytechnic 
institute's game development
club

all assets and code by
j. henry stadolnik iv

to follow my work, check out my
twitter: @jusiv_
]]

firstboot = true
tlast = 0 --used to track time
hscore = 0 --stores highscore
grays = {7,6,13,5,1}

--nmove = 0


function reset()
 trans = 20
 wait = 20
 title = true
 tfade = 25
 
 idle = 0
 still = 0
 smin = 120
 smax = 500
 
 score = 0
 dead = 0
 hp = 100
 hwait = 0 --if > 0, show hurt
 hwait2 = 0
 cold = 0
 cmax = 50
 fire = 100
 fmax = 100
 fadd = 0
 logs = 0
 llost = 0
 lval = 5
 lmax = 80
 sup = 0
 dup = 0
 effects = {0,1,2,3,4}
 coff = rnd(1)

 px = -15
 py = 15
 pmove = false
 pmir = false
 pframe = 0
 
 msg = ""
 mwait = 0
 mwmax = 0
  
 actors = {}
 a_popup = {}
 a_log = {}
 a_fire = {}
 a_tree = {}
 a_decor = {}
 a_lbeast = {}
 a_sstalk = {}
 a_spore = {}
 a_shreek = {}
 a_rquoon = {}
 a_hive = {}
 a_ffly = {}
 a_circle = {}
 a_spark = {}
 place_actors()
end


function place_actors()
 for i=0,349 do
    add_tree()
 end
 for i=0,449 do
    add_decor()
 end
 for i=1,lmax do
    add_log()
 end
 for i=0,9 do
    add_lbeast()
 end
 for i=0,11 do
    add_sstalk()
 end
 for i=0,7 do
    add_shreek()
 end
 for i=0,3 do
    add_rquoon()
 end
 for i=0,11 do
    add_hive()
 end
 for i=0,4 do
    add_circle(i)
 end
end
-->8
--actors

function add_popup(x,y,s,w)
 local a={}
 a.x = x
 a.y = y
 a.str = s
 a.t = 0
 a.tmax = w
 add(a_popup,a)
end

function update_popup(a)
 a.t += 1
 a.y -= 0.5
 if a.t > a.tmax then
    del(a_popup,a)
 end
end

function draw_popup(a)
 local s = a.str
 print(s,a.x-3-2*#s,a.y-6,grays[max(flr(6*a.t/a.tmax),1)])
end


--the forest shifts around you
function randomize()
 foreach(a_log,respawn)
 foreach(a_tree,respawn)
 foreach(a_lbeast,respawn)
 foreach(a_sstalk,respawn)
 foreach(a_shreek,respawn)
 foreach(a_rquoon,respawn)
 foreach(a_hive,respawn)
end

function respawn(a)
 local os = onscreen(a.x,a.y)
 if (os and title) or
    (os == false and flr(rnd(10)) == 0) then
    --nmove += 1 -- debug
    --[[
    2 = log
    3 = tree
    4 = decor
    5 = lbeast
    6 = sstalk
    7 = shreek
    8 = rquoon
    9 = hive
    ]]
    if a.id == 2 then
       add_log()
       del(a_log,a)
    elseif a.id == 3 then
       add_tree()
       del(a_tree,a)
    elseif a.id == 4 then
       add_decor()
       del(a_decor,a)
    elseif a.id == 5 then
       add_lbeast()
       del(a_lbeast,a)
    elseif a.id == 6 then
       add_sstalk()
       del(a_sstalk,a)
    elseif a.id == 7 then
       add_shreek()
       del(a_shreek,a)
    elseif a.id == 8 then
       add_rquoon()
       del(a_rquoon,a)
    elseif a.id == 9 then
       add_hive()
       del(a_hive,a)
    end
 end
end


--for list of all actors
function add_actor(a)
 if onscreen(a.x,a.y) then
    local pos = 96+flr(a.y)-flr(py)
    local l = actors[pos]
    add(l,a)
    actors[pos] = l
 end
end

function draw_actor(a)
 --[[
 0 = player
 1 = campfire
 2 = log
 3 = tree
 4 = decor
 5 = lbeast
 6 = sstalk
 7 = shreek
 8 = rquoon
 9 = hive
 10 = ffly
 11 = circle
 12 = spark
 ]]
 if a.id == 0 then
    draw_player()
 elseif a.id == 1 then
    draw_campfire()
 elseif a.id == 2 then
    draw_log(a)
 elseif a.id == 3 then
    draw_tree(a)
 elseif a.id == 4 then
    draw_decor(a)
 elseif a.id == 5 then
    draw_lbeast(a)
 elseif a.id == 6 then
    draw_sstalk(a)
 elseif a.id == 7 then
    draw_shreek(a)
 elseif a.id == 8 then
    draw_rquoon(a)
 elseif a.id == 9 then
    draw_hive(a)
 elseif a.id == 10 then
    draw_ffly(a)
 elseif a.id == 12 then
    draw_spark(a)
 elseif a.id == 11 then
    draw_circle(a)
 end
end

function add_player()
 local a={}
 a.id = 0
 a.x = px
 a.y = py
 add_actor(a)
end

function add_campfire()
 local a={}
 a.id = 1
 a.x = 0
 a.y = 2
 add_actor(a)
end


--fire
--fwoosh
function add_fire()
 if flr(rnd(fire+4)) < 3 then return end
 local a={}
 a.x = -3+rnd(6)
 a.y = 0
 a.t = 1
 a.tmax = 50+flr(rnd(50))
 a.r = max(1,rnd(3.5*fire/fmax))
 add(a_fire,a)
end

function update_fire(a)
 a.y -= rnd(1)
 a.t += 1
 if a.r > 0.9 then
    a.r -= 0.1
 end
 if a.t >= a.tmax then
    del(a_fire,a)
 end
end

function draw_fire(a)
 circfill(a.x,a.y,a.r,grays[ceil(5*a.t/a.tmax)])
end


--shadows
function draw_shadow_s(a)
 spr(3,a.x-4,a.y-1)
end

function draw_shadow_b(a)
 spr(6,a.x-8,a.y-1,2,1)
end


--log
--keep that fire burning
function add_log()
 local a={}
 a.id = 2
 a.x = px
 a.y = py
 while onscreen(a.x,a.y) do
    local aa = rnd(1)
    local rr = smin+flr(rnd(smax))
    a.x = rr*cos(aa)
    a.y = rr*sin(aa)
 end
 a.sp = 4+flr(rnd(2))
 a.mir = false
 if flr(rnd(2)) == 0 then
    a.mir = true
 end
 add(a_log,a)
end

function update_log(a)
 if checkprox(a.x,a.y) then
    logs += 1
    score += 10
    add_popup(a.x,a.y,"+10’",30)
    sfx(27)
    del(a_log,a)
 end
end

function draw_log(a)
 spr(a.sp,a.x-4,a.y-8,1,1,a.mir,false)
end


--tree
--just a barky twiggy thing
--note: sometimes a squishy
--spore-y thing
function add_tree()
 local a={}
 a.id = 3
 a.x = px
 a.y = py
 while onscreen(a.x,a.y) do
    local aa = rnd(1)
    local rr = smin+rnd(smax)
    a.x = rr*cos(aa)
    a.y = rr*sin(aa)
 end
 a.m = false
 if flr(rnd(2)) == 0 then
    a.m = true
 end
 if flr(rnd(3)) == 0 then
    a.sp1 = 108+2*flr(rnd(2))
    a.sp2 = 76+2*flr(rnd(2))
 else
    a.sp1 = 64+2*flr(rnd(3))
    a.sp2 = 70+2*flr(rnd(3))
 end
 add(a_tree,a)
end

function draw_tree(a)
 spr(a.sp2,a.x-8,a.y-29,2,2,a.m,false)
 spr(a.sp1,a.x-8,a.y-13,2,2,a.m,false)
end


--decor
--pretty things up a bit
function add_decor()
 local a={}
 a.id = 4
 a.x = px
 a.y = py
 while onscreen(a.x,a.y) do
    local aa = rnd(1)
    local rr = smin+rnd(smax)
    a.x = rr*cos(aa)
    a.y = rr*sin(aa)
 end
 a.m = false
 if flr(rnd(2)) == 0 then
    a.m = true
 end
 a.sp = 20+flr(rnd(8))
 add(a_decor,a)
end

function draw_decor(a)
 spr(a.sp,a.x-4,a.y-8,1,1,a.m,false)
end


--logbeast
--chases and pounces, will whump
--your face if you don't evade
function add_lbeast()
 local a={}
 a.id = 5
 a.x = px
 a.y = py
 while onscreen(a.x,a.y) do
    local aa = rnd(1)
    local rr = smin+rnd(smax)
    a.x = rr*cos(aa)
    a.y = rr*sin(aa)
 end
 a.d = rnd(100) --direction
 a.s = 1+sup --speed
 a.f = flr(rnd(16)) --frame
 a.m = false --mirrored
 a.act = 0
 add(a_lbeast,a)
end

function update_lbeast(a)
 local ang = a.d/100
 --react
 if a.act <= 0 then
    a.d = (a.d+96+rnd(8))%100
    a.s = 1+sup
    if onscreen(a.x,a.y) then
       local dd = dist(a.x,a.y,px,py)
       if dd < 50 then
          ang = angto(a.x,a.y)
          a.d = ang*100
          if dd < 32 then
             a.act = 60
          end
       end
    end
 else
    a.act -= 1
    if a.act == 56 then
       sfx(22)
    elseif a.act > 35 and a.act <= 55 then
       a.s = 2+sup
    else
       a.s = 0
    end
 end
 --move
 local dx = a.s*cos(ang)
 if dx < -0.5 then a.m = true
 elseif dx > 0.5 then a.m = false
 end
 a.x += dx
 a.y += a.s*sin(ang)
 a.f = (a.f+1)%16
 --collide
 if checkprox(a.x,a.y) then
    hurt_player(20,15)
 end
end

function draw_lbeast(a)
 local sp = 96
 if a.act <= 0 then
    sp += 2*flr(a.f/4)
 elseif a.act > 50 then
    sp = 104
 elseif a.act > 40 then
    sp = 106
 end
 spr(sp,a.x-8,a.y-16,2,2,a.m,false)
end


--scatterstalk
--releases spores if it senses
--unnatural movement (that means
--you, bucko)
function add_sstalk()
 local a={}
 a.id = 6
 a.x = px
 a.y = py
 while onscreen(a.x,a.y) do
    local aa = rnd(1)
    local rr = smin+rnd(smax)
    a.x = rr*cos(aa)
    a.y = rr*sin(aa)
 end
 a.s = 0.5+sup --speed
 a.d = rnd(100) --direction
 a.f = flr(rnd(16)) --frame
 a.w = flr(rnd(200)) --walk/wait
 a.act = 0
 add(a_sstalk,a)
end

function update_sstalk(a)
 a.d = (a.d+97+rnd(6))%100
 a.w -= 1
 if a.w <= 0 then
    a.w = flr(rnd(200))
 elseif a.w < 100 then
    --move
    local ang = a.d/100
    a.x += a.s*cos(ang)
    a.y += a.s*sin(ang)
    a.f = (a.f+1)%16
 end
 --react
 if onscreen(a.x,a.y) then
    if dist(a.x,a.y,px,py) < 44 and pmove then
       a.act = min(a.act+2,20)
    end
 end
 if a.act >= 10 then
    sfx(26)
    for i=0,4 do
       add_spore(a.x,a.y)   
    end
 end
 if a.act > 0 then a.act -= 1 end
end

function draw_sstalk(a)
 spr(128+2*flr(a.f/4),a.x-8,a.y-16,2,2)
end

function add_spore(x,y)
 if #a_spore > 120 then return end
 local a={}
 local aa = rnd(1)
 local rr = rnd(40)
 a.x = x+rr*cos(aa)
 a.y = y+rr*sin(aa)
 a.t = 0
 a.tmax = 20+flr(rnd(10))
 add(a_spore,a)
end

function update_spore(a)
 a.t += 1
 if a.t >= a.tmax then
    del(a_spore,a)
 end
 if checkprox(a.x,a.y) then
    hurt_player(2,5)
 end
end

function draw_spore(a)
 circfill(a.x,a.y,1,grays[1+flr(4*a.t/a.tmax+(idle%10)/5)])
end


--shreek
--shrieks when approached, aaand
--now you're lost
function add_shreek()
 local a={}
 a.id = 7
 a.x = px
 a.y = py
 while onscreen(a.x,a.y) do
    local aa = rnd(1)
    local rr = smin+rnd(smax)
    a.x = rr*cos(aa)
    a.y = rr*sin(aa)
 end
 a.d = rnd(100) --direction
 a.s = 0 --speed
 a.f = 0 --frame
 a.m = false --mirrored
 a.act = flr(rnd(300))
 a.fly = false
 add(a_shreek,a)
end

function update_shreek(a)
 local ang = a.d/100
 a.act -= 1
 --react
 if a.fly then
    a.f = (a.f+1)%12
    if onscreen(a.x,a.y) == false then
       add_shreek()
       del(a_shreek,a)
    end
 elseif onscreen(a.x,a.y) then
    if a.act == 10 then
       sfx(21)
    end
    local dd = dist(a.x,a.y,px,py)
    if dist(a.x,a.y,px,py) < 40 then
       a.fly = true
       a.s = 4
       for i=0,7 do
          randomize()
       end
       sfx(20)
    end
 end
 if a.act <= 0 then
    a.act = 100+flr(rnd(200))
 end
 --move
 local dx = a.s*cos(ang)
 if dx < -0.5 then a.m = true
 elseif dx > 0.5 then a.m = false
 end
 a.x += dx
 a.y += a.s*sin(ang)
end

function draw_shreek(a)
 local sp = 160
 if a.fly then
    sp = 166+2*flr(a.f/3)
 else
    if a.act <= 10 then
       sp = 164
    elseif a.act <= 20 then
       sp = 162
    end
 end
 spr(sp,a.x-8,a.y-16,2,2,a.m,false)
end


--rasquoon
--dang fuzzy log thief
function add_rquoon()
 local a={}
 a.id = 8
 a.x = px
 a.y = py
 while onscreen(a.x,a.y) do
    local aa = rnd(1)
    local rr = smin+rnd(smax)
    a.x = rr*cos(aa)
    a.y = rr*sin(aa)
 end
 a.d = 0 --direction
 a.s = 3+sup --speed
 a.f = flr(rnd(12)) --frame
 a.m = false --mirrored
 a.act = false
 a.nohit = true
 add(a_rquoon,a)
end

function update_rquoon(a)
 if onscreen(a.x,a.y) then
    if a.act then
       local dx = a.s*cos(a.d)
       if dx < -0.5 then a.m = true
       elseif dx > 0.5 then a.m = false
       end
       a.x += dx
       a.y += a.s*sin(a.d)
       a.f = (a.f+1)%12
    else
       a.d = angto(a.x,a.y)
       a.act = true
       sfx(24)
    end
    if a.nohit and checkprox(a.x,a.y) then
       logs = flr(logs/2)
       llost = 8
       a.nohit = false
       sfx(23)
    end
 elseif a.act then
    add_rquoon()
    del(a_rquoon,a)
 end
end

function draw_rquoon(a)
 spr(136+2*flr(a.f/3),a.x-8,a.y-16,2,2,a.m,false)
end


--fangfly hive
--not a rock
function add_hive()
 local a={}
 a.id = 9
 a.x = px
 a.y = py
 while onscreen(a.x,a.y) do
    local aa = rnd(1)
    local rr = smin+rnd(smax)
    a.x = rr*cos(aa)
    a.y = rr*sin(aa)
 end
 a.m = false --mirrored
 if flr(rnd(2)) == 0 then
    a.m = true
 end
 a.act = 0
 add(a_hive,a)
end

function update_hive(a)
 if a.act > 0 then
    a.act -= 1
 elseif onscreen(a.x,a.y) then
    if dist(a.x,a.y,px,py) < 48 then
       add_ffly(a.x,a.y)
       a.act = 50+flr(rnd(150))
    end
 end
end

function draw_hive(a)
 spr(174,a.x-8,a.y-16,2,2,a.m,false)
end

function add_ffly(x,y)
 local a={}
 a.id = 10
 a.x = x
 a.y = y
 a.d = angto(x,y)
 a.s = 2.5+sup
 a.f = flr(rnd(8))
 a.w = 0
 add(a_ffly,a)
 sfx(25)
end

function update_ffly(a)
 a.w += 1
 if a.w >= 31 then
    del(a_ffly,a)
 elseif a.w == 16 then
    a.d += 0.5
 end
 local dx = a.s*cos(a.d)
 if dx < -0.5 then a.m = true
 elseif dx > 0.5 then a.m = false
 end
 a.x += dx
 a.y += a.s*sin(a.d)
 a.f = (a.f+1)%8
 if checkprox(a.x,a.y) then
    hurt_player(5,15)
 end
end

function draw_ffly(a)
 spr(28+flr(a.f/2),a.x-4,a.y-11,1,1,a.m,false)
end


--"fairy circle"
--wtf kind of fairy would make
--this? are fairy cultists
--actually a thing now?
function add_circle(i)
 local a={}
 local aa = coff+(2*i+rnd(1))/10
 local rr = 375+rnd(50)
 a.id = 11
 a.x = rr*cos(aa)
 a.y = rr*sin(aa)
 local e = effects[1+flr(rnd(#effects))]
 del(effects,e)
 a.e = e
 --[[
 effects:
 0 = freeze faster
 1 = enemy speed up
 2 = fewer logs
 3 = logs burn less
 4 = extra damage
 ]]
 a.act = true
 add(a_circle,a)
end

function update_circle(a)
 if onscreen(a.x,a.y) then
    if a.act and flr(rnd(20)) and #a_spark < 15 then
       add_spark(a.x,a.y)
    end
    if a.act and checkprox(a.x,a.y) then
       local e = a.e
       if e == 0 then
          msg = "the cold grows harsher..."
          cmax -= 10
          if cold > cmax then
             cold = cmax
          end
       elseif e == 1 then
          msg = "the beasts hasten..."
          sup += 0.3
       elseif e == 2 then
          msg = "tinder grows scarce..."
          lmax -= 10
       elseif e == 3 then
          msg = "the fire's hunger grows..."
          lval -= 1
       elseif e == 4 then
          msg = "the wilds grow fierce..."
          dup += 1
       end
       mwmax = 3*#msg
       mwait = mwmax
       score += 200
       hp += 10
       add_popup(a.x-12,a.y,"+10‡",50)
       add_popup(a.x+14,a.y,"+200’",50)
       add(effects,a.e)
       a.act = false
       sfx(28)
    end
 elseif a.act == false then
    del(a_circle,a)
 end
end

function draw_circback(a)
 circ(a.x,a.y,10,13)
end

function draw_circle(a)
 spr(3,a.x-4,a.y)
 local yy = 6
 if a.act then
    yy = 11-1.5*sin(idle/50)
 end
 spr(13,a.x-8,a.y-yy,2,1)
end

function add_spark(x,y)
 local a={}
 a.id = 12
 local aa = rnd(1)
 a.x = x+10*cos(aa)
 a.y = y+10*sin(aa)
 a.t = 0
 a.tmax = 10+flr(rnd(10))
 add(a_spark,a)
end

function update_spark(a)
 a.t += 1
 if a.t >= a.tmax then
    del(a_spark,a)
 end
end

function draw_spark(a)
 pset(a.x,a.y-a.t/2,grays[max(flr(6*a.t/a.tmax),1)])
end
-->8
--main

--angle from given coords to player
function angto(x,y)
 return atan2(px-x,py-y)
end


--distance function (limited range)
function dist(x1,y1,x2,y2)
 local xx = (x2-x1)
 local yy = (y2-y1)
 return sqrt(xx*xx+yy*yy)
end


--check if player colliding with coord
function checkprox(x,y)
 return mid(x-8,x+8,px) == px and mid(y-8,y+8,py) == py
end


--check if coord is on-screen
function onscreen(x,y)
 return mid(x-80,x+80,px) == px and mid(y-96,y+96,py) == py
end


function hurt_player(n,w)
 if hwait <= 0 then
    hp = max(0,hp-n-dup)
    hwait = w
 end
end


function move_player()
 local dx = 0
 local dy = 0
 if btn(0) then dx -= 1 end
 if btn(1) then dx += 1 end
 if btn(2) then dy -= 1 end
 if btn(3) then dy += 1 end
 if dx == 0 and dy == 0 then
    px = flr(px)
    py = flr(py)
 elseif dx != 0 and dy != 0 then
    dx *= sqrt(1/2)
    dy *= sqrt(1/2)
 end
 px += dx
 py += dy
 --change player direction
 if dx > 0 then pmir = false
 elseif dx < 0 then pmir = true
 end
 --animate player
 if dx != 0 or dy != 0 then
    pmove = true
    pframe = (pframe+1)%16
    still = 0
 else
    pmove = false
    pframe = 0
    still = (still+1)%150
 end
end


function _init()
 cartdata("jusiv_verywarmfire")
 --setup
 reset()
 --load score
 hscore = dget(0)
 --start music
 music(0)
end


function _update()
 idle = (idle+1)%50
 if onscreen(0,0) then
    if flr(rnd(2)) == 0 then
       --sfx(31+flr(rnd(6)))
    end
 end
 if wait > 0 then wait -= 1 end
 if mwait > 0 then mwait -= 1 end
 if hwait > 0 then hwait -= 1 end
 if hwait2 > 0 then hwait2 -= 1 end
 if llost > 0 then llost -= 1 end
 if title then
    if trans > 0 then trans -= 1 end
    if wait <= 0 and (btn(4) or btn(5)) then
       title = false
       tlast = flr(time())
       firstboot = false
       sfx(28)
    end
 elseif hp <= 0 then
    if dead < 50 then
       if dead == 0 then
          if hscore < score then
             hscore = score
             dset(0,score)
          end
          sfx(29)
       end
       dead += 1
    elseif trans <= 0 then
       if btn(4) or btn(5) then
          trans = 1
       end
    else
       trans += 1
       if trans > 20 then
          reset()
       end
    end
 else
    if tfade > 0 then tfade -= 1 end
    --update clock
    if tlast != flr(time()) then
       tlast = flr(time())
       --reduce fire
       if fire > 0 then 
          fire -= 1
       end
       --update cold
       if fire > 5 and
          mid(-fire,fire,px) == px and
          mid(-fire,fire,py) == py and
          dist(px,py,0,0) < fire then
          cold = max(0,cold-2)
       elseif cold < cmax then
          cold += 1
       end
       --hurt player if too cold
       if cold >= cmax and hp > 0 then
          hp -= 1
          hwait2 = 5
       end
       --respawn logs
       if #a_log < lmax then
          add_log()
       end
       --score
       score += 1
       --nmove = 0 --debug
       randomize()
    end
    --get input + move player
    move_player()
    --collect logs
    foreach(a_log,update_log)
    --redeem logs
    if logs > 0 and checkprox(0,0) then
       fadd += lval*logs
       logs = 0
       sfx(30)
    end
    if fadd > 0 then
       fire += 1
       fadd -= 1
       add_fire()
    end
    --update enemies
    foreach(a_lbeast,update_lbeast)
    foreach(a_sstalk,update_sstalk)
    foreach(a_spore,update_spore)
    foreach(a_shreek,update_shreek)
    foreach(a_rquoon,update_rquoon)
    foreach(a_hive,update_hive)
    foreach(a_ffly,update_ffly)
    foreach(a_circle,update_circle)
    foreach(a_spark,update_spark)
 end
 add_fire()
 foreach(a_fire,update_fire)
 foreach(a_popup,update_popup)
end
-->8
--drawing

function bprint(str,y,c)
 local xx = 64-2*#str
 print(str,xx-1,y,0)
 print(str,xx+1,y)
 print(str,xx,y-1)
 print(str,xx,y+1)
 print(str,xx,y,c)
end

function draw_world()
 local scl = 0.2+fire/fmax
 local roff = 16+1.2*cos(idle/25)
 fillp(0b0101101001011010)
 circfill(0,0,(48+roff)*scl,1)
 fillp()
 circfill(0,0,(32+roff)*scl,1)
 fillp(0b0101101001011010.1)
 circfill(0,0,(16+roff)*scl,5)
 fillp()
 circfill(0,0,roff*scl,5)
end


function draw_player()
 local sp = 32
 if hp <= 0 then
    if dead < 20 then
       sp = 44
    else
       sp = 46
    end
 elseif pmove then
    sp += 2*flr(pframe/4)
 else
    if still >= 132 and still < 140 then
       sp = 42
    elseif still >= 122 then
       sp = 40
    end
 end
 spr(sp,px-8,py-16,2,2,pmir,false)
end


function draw_campfire()
 foreach(a_fire,draw_fire)
 spr(1,-8,-5,2,1)
end


function _draw()
 pal()
 local smax = (hwait+hwait2+llost)/2
 camera(px-63-smax+2*rnd(smax),py-63-smax+2*rnd(smax))
 rectfill(px-80,py-80,px+80,py+80,0)
 draw_world()
 if title then
    draw_campfire()
    spr(3,px-4,py-1)
    draw_player()
 else
    --draw ground details
    foreach(a_circle,draw_circback)
    foreach(a_log,draw_shadow_s)
    foreach(a_sstalk,draw_shadow_s)
    foreach(a_ffly,draw_shadow_s)
    foreach(a_lbeast,draw_shadow_b)
    foreach(a_shreek,draw_shadow_b)
    foreach(a_rquoon,draw_shadow_b)
    foreach(a_hive,draw_shadow_b)
    spr(3,px-4,py-1)
    --draw with depth
    --1. create a "bucket" for
    --   each on-screen y-coord.
    actors = {}
    for i=0,191 do
       local l = {}
       add(actors,l)
    end
    --2. for each actor, place
    --   it into a bucket if it
    --   is on-screen
    foreach(a_log,add_actor)
    foreach(a_tree,add_actor)
    foreach(a_decor,add_actor)
    foreach(a_lbeast,add_actor)
    foreach(a_sstalk,add_actor)
    foreach(a_shreek,add_actor)
    foreach(a_rquoon,add_actor)
    foreach(a_hive,add_actor)
    foreach(a_ffly,add_actor)
    foreach(a_circle,add_actor)
    foreach(a_spark,add_actor)
    add_player()
    add_campfire()
    --3. draw all actors placed
    --   in buckets, in depth
    --   order
    for i=1,192 do
       local l = actors[i]
       foreach(l,draw_actor)
    end
    if py < -70 then
       draw_campfire()
    end
    --draw overlaying actors
    foreach(a_spore,draw_spore)
    foreach(a_popup,draw_popup)
    --draw ui
    camera()
    if mwait > 0 then
       bprint(msg,80,grays[5-flr(4*mwait/mwmax)])
    end
    if dead < 50 then
       local cc = grays[1+flr(4*tfade/25+4*dead/40)]
       local cc2 = 8
       if dead >= 40 then
          cc2 = 1
       elseif dead >= 30 then
          cc2 = 2
       end
       pal(2,cc)
       if #effects > 0 then
          for i=1,#effects do
             spr(8+effects[i],119,127-8*i)
          end
       end
       local str = "’"..score
       print(str,124-4*#str,1,2)
       --print(logs.."/"..#a_log,2,8)
       if llost > 0 then
          pal(2,cc2)
       end
       spr(19,1,92)
       print(logs,11,94)
       if hwait+hwait2 > 0 or hp <= 0 then
          pal(2,cc2)
       else
          pal(2,cc)
       end
       spr(18,1,101)
       print(hp,11,103)
       if cold >= cmax then
          pal(2,cc2)
       else
          pal(2,cc)
       end
       spr(17,1,110)
       rect(11,112,31,116)
       rectfill(11,112,31-20*cold/cmax,116)
       if fire <= 0 then
          pal(2,cc2)
       else
          pal(2,cc)
       end
       spr(16,1,119)
       rect(11,121,31,125)
       rectfill(11,121,11+min(fire/5,20),125)
       if fire > 100 then
          print("+",33,121)
       end
    end
    pal()
    if dead > 25 then
       cc = grays[5-flr(4*(dead-25)/25)]
       bprint("you have perished",42,cc)
       bprint("your score: "..score,74,cc)
       bprint("best score: "..hscore,82,cc)
       bprint("Ž ",94+min(idle/25+trans,1),cc)
    end
 end
 camera()
 if tfade > 0 then
    local cc = grays[6-flr(tfade/5)]
    bprint("a very warm fire",80,cc)
    bprint("Ž ",90+min(idle/25+1-tfade/50,1),cc)
 end
 if trans > 0 then
    if trans <= 5 then
       fillp(0b1111010111110101.1)
    elseif trans <= 10 then
       fillp(0b1010010110100101.1)
    elseif trans <= 15 then
       fillp(0b1010000010100000.1)
    else
       fillp()
    end
    rectfill(0,0,127,127,0)
    fillp()
    if firstboot then
       pal(1,grays[1+flr((20-trans)/5)])
       spr(238,112,112,2,2)
       pal()
    end
 end
 --debug
 --print(stat(1),2,2,7)
 --print(flr(px)..","..flr(py),2,8)
 --print(nmove,2,14)
end
__gfx__
00000000000000000000000001111110000000000000000000111111111111000020000000220000000220000020000022022000606000000000060676d51028
00000000000000000000000011111111000000000000000001111111111111102020200000022000002222000222000022222000606060000006060676d51028
0070070000000000000000000111111000000000000d000000111111111111000222000022222200022222000202200020002000666060000006066600000000
000770000000000000000000000000000000d0000000500000000000000000002020200000022000200220002000200002220000006666777766660077766670
00077000000dd000000dd000000000000dd555500005000000000000000000000020000000220000200200002202200000200000000000d77d00000070760670
0070070000dd66066066dd0000000000d66d5555055555d000000000000000000000002000000020022000000222000000000020000000677600000077766670
0000000000d66d6666d66d0000000000d66d555555555d6d00000000000000000000022200000222000002220000022200000222000000077000000070060677
0000000000066d6666d66000000000000dd55550055555d000000000000000000000002000000020000000000000000000000020000000066000000000000000
000020000002200002200220000002200000000000000000006000000000000000000000000000000000000000000000000000000000000000000dd000000dd0
000220002202202220022222000022220000000000d6d00006660000000000000000000000000000000000000000000000000dd000000dd00660d5000600d500
02022200222222222022222200022222000dddd00ddddd000d66000000000000000000000000000000000600000000000000d5000600d5006665115066651150
022202200220022022222222002222200000dddd0d6ddd000ddd000000055000000000000000000000006d600006000000051150666511506666116d6666116d
02200222022002202222222202222200000006000ddd6d000ddd000d005d5500000000000000050000600600006d60000665116d6666116d0666556d6666556d
222000222222222202222220200220000ddd0600000600d00060000d05d555000550000005005d5006d605d0000600006666556d6666556d006506d0066506d0
2200002222022022002222002002000000600600000600600060d00605555d505d500550055055d50060050000d50000666506d0066506d00550000005500000
0222222000022000000220000220000000d00d000d0d00d000d0d00d05555550555505d55d505555005005000005000005500000055000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000006666600000000000000000000000000066666000000000000000000000000000000000000000000000000000000000000000000000
000000666660000000000666dd660000000000666660000000000666666600000000006666600000000000666660000000000000000000000000000000000000
000006666d660000000066ddddd600000000066666d6000000006666dddd0000000006666d660000000006666666000000000000000000000000000000000000
0000666dddd60000000066d7dd7600000000666ddddd00000000666d7dd700000000666dddd6000000006666dd66000000000066666600000000000000000000
000066d7dd760000000066ddddd60000000066dd7dd700000000666ddddd0000000066ddddd600000000666dddd60000000006666ddd60000000000000000000
000066ddddd600000000066ddd660000000066dddddd000000000666ddd60000000066d7dd760000000066ddddd6000000000666dddd60000000000000000000
0000066ddd66000000000066666000000000066dddd6000000000066666000000000066ddd6600000000066ddd6600000000066ddddd60000000000000000000
000000666660000000006666d66660000000006666600000000066666d666000000000666660000000000666666600000000066dddd660000000000000000000
00000666d666000000060066d6600600000006666d660000000600666d60060000000666d666000000000666d666000000000666666600000000000000000000
00006066d660600000000066d6600000000060666d606000000000666d60000000000666d666000000000666d6660000000006666d6600000000000000000000
00006066d66060000000006666600000000060666d606000000000666660000000000666d666000000000066d660000000000666d66600000000000006666600
00000066666000000000006000060000000000666660000000000006006000000000006666600000000000666660000000000666d66600000000000666666660
000000600060000000000600000600000000006000600000000000060600000000000060006000000000006000600000000000666660000000000066666ddd60
000000600060000000000000000000000000006000600000000000000000000000000060006000000000006000600000000006600d6000000000066d6d6ddd60
000005dddd500000000005dddd500000000005dddd50000000005500000000000000055500000000000000000005555000000000000000000000000000000000
000005dddd500000000005dddd500000000005dddd5000000000550000000000000055500000000000000555505d550000000000000000000000000000000000
000005dddd500000000005dddd500000000005dddd500000000550055000000000005d500000000000005555d5d5000000000000000000000000000066600000
000005dddd500000000005dddd500000000005dddd50000000055055000000000005d50000000000000055005dd5000000000000000000000000000666600000
00005ddddd500000000005ddddd5000000005ddddd5000000005d555055000000005d500055000000000050005d5000000000000000000000000000666600000
00005ddddd500000000055ddddd5000000005ddddd5500000005d500005055500005d50005550005000000005d50050000000000000000000000006d66600000
00005ddddd55000000005dddddd5000000005dddddd50000505d50000055d5000005dd500055005500000005d500050000000000000000000000006d6d600000
00005ddddd55000000005dddddd5000000005dddddd50000555d50550005d50000055d50005d50550055005d550055050000000d66d00000000000dd6d600000
00055dddddd5500000005dddddd5500000005dddddd500005d5d5005505d500050005d55005d55505555505d5005d5550000d66ddddd0000000000d66d660000
0005ddddddd550000005dddddddd500000055dddddd500005ddd5005d55d500055505dd5055ddd50555555d5005dd550000dd66dd66dd00000000dd6dd660000
0055dddddddd50000005ddd5dddd55000055ddddddd5500005dd50005dd5005005d55dd505ddd5005005d5d5505d5000000dddddd66dd0000000ddddddd60000
005dddddd5ddd50000555dd55d555500005555d5dd555500005dd50005d5555005dd5dd555dd50000005dddd55d5000500ddddddddddd0000000ddddddddd000
05555d5dd555555000555d555550555005550555555500000005d55055ddd500055ddddd5dd5555500055dddd5d5055500dd66ddddd000000000ddddddddd000
00005555d5505500055055550550000000000550555000000005dd555ddd55000055ddddddddd50000005dddddd55550000d66dd6600000000000dddddddd000
00055505550000000000055000550000000055000555000000005dddddd550000005dddddddd500000005ddddd555000000000066600000000000006dddd0000
00000000550000000000005000000000000000000000000000005dddddd5000000005dddddd50000000005dddd50000000000006660000000000000666000000
000ddddd000000000000dddd00000000000ddddd00000000000ddddd00000000000dd000000000000000dddd0000000000000006666000000000000666000000
0000dd7d00000000000ddd7d500000000000dd7d500000000000dd7d00000000000dddd000000000000ddd7d5000000000000000666000000000000666000000
00000ddd5000000000000ddd5000000000000ddd5000000000000ddd500000000000d7d00000000000000ddd5000000000000000666000000000000666000000
00000000500000000000555555555000000055555555500000000000500000000000ddd500000000000005555ddddd0000000000666000000000000666000600
0000555555555000000555555ddddd00005555555ddddd000000555555555000000000050000000000055555d11111d000d6d000666000000000000666000660
005555555ddddd0000555555d666d6d005555555d666d6d0005555555ddddd0000055555555500000055555d1111111d0dddd6006660000000000006666006d0
05555555d666d6d00555555d6dd6d66d0555555d6dd6d66d05555555d666d6d005555555ddddd0000555555d1111111d0d6ddd00666000000000000666600dd0
0555555d6dd6d66d0555555d666d666d0555555d666d666d0555555d6dd6d66d5555555d66dd6d000555555d1111111d00060000666000000060000666600d60
0555555d666d666d0555555d66d6dd6d055dd55d66d6dd6d0555555d666d666d555555d6dd11d6d0055dd555d11111d0000660066660000006d0000666600060
055dd55d66d6dd6d055dd555d6d666d005ddd555d6d666d0055dd55d66d6dd6d555555dd11111dd005ddd5555ddddd0000066666660000000dd0000666600060
05ddd555d6d666d005ddd5dd5ddddd0000ddd5dd5ddddd0005ddd555d6d666d055dd55d6d11dd6d005ddd5dd5555000000006666660000000dd0006666600060
00ddd5dd5ddddd0000ddd5ddd5500000000dd5dddd50000000ddd5dd5ddddd005ddd555d6dd66d0000ddd5dddd55000000000066660000000060006666600660
00ddd5ddd55000000ddd50ddd555000000ddd55dddd00000000dd5ddd55000000ddd5dd5ddddd0000dddd5ddddd55000000000d666d00000006000666660d66d
00dd50ddd55000000dd555ddd055500000dd5500dddd0000000dd50ddd5000000ddd5ddd550000000ddd55000dd5500000000d66d6d000000d6d0dd666dd0dd0
00d5000ddd5000000dd055ddd055500000d0050000dd5000000dd000ddd500000dd55dddd55000000d05000000000000000000dd0d00000000d000ddddd00000
00d50000ddd500000d00000ddd0000000000050000055500000d50000ddd500000d050ddddd55000000000000000000000000000000000000000000000000000
00000dd6ddd00000000000dd6dd000000000000000000000000000dd6dd000000000000000000000000000000000000000000000000000000000000000000000
000dd6ddddd6d00000006ddddd0000000000ddd6dddd00000000000ddd6dd0000000000000000000000000000000000000000000000000000000000000000000
0000dddddddd0000000ddddd00000000000dd6ddddd6d000000000000ddddd000000000000000000000000000000000000000000000000000000000000000000
000000066000000000dd6d660000000000000dddddd0000000000000666dd6d00000000000000000000000000000000000000000000000000000000000000000
0000000760000000000dd0670000000000000006600000000000000777000dd00055000000000000005500000000000005550000000000000555000000000000
00000007600000000000007770000000000000076600000000000067700000000055500000000000055550000000000005555000000000000055500000000000
00000007700000000000000677000000000000007700000000000067600000000555500006006000055550000000000005555000000000000555500006006000
00000006770000000000000067000000000000007700000000000077600000000555500006606600055500000600600000555000060060000555000006606600
000000067700000000000000760000000000000067000000000000076000000005550005d66066000550000006606600055505dd06606600055505d5d6606600
0000000077000000000000007600000000000000770000000000000776000000055005d5dd6dddd0055005d5d66066000555d5d5d66066000550d5d5dd6dddd0
00000000670000000000000077000000000000006700000000000000770000000555d5d5ddd75d570555d5d5dd6dddd0005dd5d5dd6dddd0055dd5d5ddd75d57
0000000066000000000000076600000000000000660000000000000066000000005dd5dddd55ddd5005dd5d5ddd75d57000dddd5ddd75d57005ddddddd55ddd5
0000000776000000000000777600000000000007760000000000000077700000000dddddd6dddd5d000ddddddd55ddd5000dd6dddd55ddd5000dd6ddd6dddd5d
00000077670000000000077767000000000000776700000000000076777700000000dd6d066d66600000d6dd6ddddd5d0000d66d6ddddd5d00000665066d6660
0000066677700000000007766770000000000777666000000000077667770000000006650060500000006650665d666000000065665d66600000065006050000
00000660777000000000000066700000000007706660000000000766000000000000065000000000000065000605000000000000605000000000000000000000
000000000d000000000000000000000000000000d00000000000000000000000000000000000000000000000000d6d0000000000000000000000000000000000
00000000dd500000000000000d00000000000000d000000000000000000000000000000000006dd000000000006dd000000000000000d6d00000000000000000
000000006d5d000000000000dd50000000000006d0000000000000000000000000000000000ddd000000000000dd0000000000000006dd000000000000000000
00000000dd5d0000000000006d5d00000000000dd000d000000000000000d6d5000000000556d00000000000055d000000000000055dd0000000000000000000
000000006d5d000000000000dd5d000000000006d000d000000000110556d55d00000005555d00d0000000055550000000000005555d00d00000000000000000
00000005d55d5000000000006d5d00000000000dd55d500005500115555d5dd0000001157755dd00000000057755ddd0000001157755dd000000000000000000
000000055775500000000005d55d50000000000557755000055501157755dd000000155567555000000000556755500000001555675550000000000550000000
00000005566500000000000557755000000000055665000005555555675550000055555555550000000005555555000000055555555500000000055515000000
00000055555550000000055556655000000000555555500005555555555550000555555d5555000000005555555000000055555d555500000000511555000000
000055555d5550000000555555555500000055555d555000000555d555550000055555d55550000000055555d55000000555555d55500000000051155d550000
000555555d550000000555555d555500000555555d550000005ddd555555000055dddd55500000000555555d5500000055ddddd55500000000005555d5115000
000d5555d55550000005555dd5555000000d5555d5555000555555555550000005555d50000000005555555d5000000005555d550000000000005dd555115000
0055dddd55550000005dddd5555555000055dddd5555000005555d55000000000000d50000000000000555d0000000000000d500000000000005d55555555500
0555555555000000555555555555500005555555550000000000d5000000000000000000000000000000dd0000000000000000000000000000555111555d5500
555550d0500000000555555555500000555550d0500000000000000000000000000000000000000000000000000000000000000000000000005511111515d500
000000d050000000000000d050000000000000d05000000000000000000000000000000000000000000000000000000000000000000000000055111115555500
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010001010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110101110
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110100100
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000805008050140550000008050080501505500000080500805014055000000805008050130550000006050060501205500000060500605013055000000605006050120550000006050060501105500000
00140000227242272525724257251e7241e7250000000000227242272525724257251e7241e7250000000000237142371526714267151f7141f7150000000000237142371526714267151f7141f7150000000000
00140000217242272526725257251f7241e7250000500005217242272526725257251f7241e725000050000524714237152771526715207141f715000050000524714237152771526715207141f7150000500005
00140000207242172525725247251e7241d7250000500005207242172525725247251e7241d7250000500005217142271526715257151e7141f7150000500005217142271526715267151f7141f7150000500005
001600000e7500e7500e7500e7500e7500e7500e7500e7500e75012750127501275012750127501275010730107300a7200a72005710057100771507710077500775007750077500775007750077500775007750
011400000d5140d5120d5120d5150d5140d5150d5140d51500000000000150001510025100151000000000000e5140e5120e5120e5150e5140e5150e5140e5150000000000000000151001500015100150000000
001400000d5140d5120d5120d5150d5140d5150d5140d51500000000000150001510035100151000000000000b5140b5120b5120b5150c5140c5150b5140b51500000000000000001510075100b5100a5100c510
011400000d5100d5100d5100d5100d5120d5120d5100d5100d5120d5120d5100d5100d5120d5120d5100d51113511135101351013512135121351013510135110c5110c5100c5100c5120c5120c5100c5100c510
011400000d5100d5100d5100d5100d5120d5120d5100d5100d5120d5120d5100d5100d5120d5120d5100d51111511115101151011512115121151011510115110a5110a5100a5100a5120a5120a5100a5100a510
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000231722c1723217234172351723517200002231522c1523215234152351523515200002231322c1323213234132351323513200002231122c112321123411235112351123f1023f1023f1023f1023f102
000b0000231522c152321523115231142351000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e00000b4540d4510c4420943108665000000240004405004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000000000000000000000
000900002e6431e633226231761317600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002d1342e1312e1252d1342f1312f1252d1342e1312e1250010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000400001e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e4221e4121e422
000a0000387423b74236742387323b73236732387223b72236722387123b712367120070000700007000070000700007000070000700007000070000700007000070000700007000070000700000000000000000
000a000021534265452d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000d574105720c5720b5750e554105520c5520b5550d534105320c5320b5350e514105120c5120b5150d500105000c5000b5000e500105000c5000b5000d500105000c5000b5000e500105000c5000b500
001000000a5700a5700a5620a55209560095600955209542025500255002540025300252002510025150000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a000004615085140f5150161403612056120a6120761202615026050e6020b602076021160218602146020b602046020460210602056020460208602166021560202602066021060200000000000000000000
000400000e61218612126121761211602056021160214602056020f6020760211602146020e6020b602076021160218602146020b602046020460210602056020460208602166021560202602066021060203602
000400000e61212612116120f61211602056021160214602056020f6020760211602146020e6020b602076021160218602146020b602046020460210602056020460208602166021560202602066021060203602
000400000d6120c612136120c61200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000400000d6120e612126121161200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000400001961225615156121861200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001a612206121c6121461211602056021160214602056020f6020760211602146020e6020b602076021160218602146020b602046020460210602056020460208602166021560202602066021060203602
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
01 41 42 43 08
00 41 42 43 08
00 41 42 0c 08
00 41 42 0d 08
00 41 42 0e 08
00 41 42 0f 08
00 41 42 0e 09
02 41 42 0f 0a
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
