pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
 blinkframe=0
 blinkspeed=10
 blink_col_i=1 --index
 gamestate="menu"
 
 part={}
 t=0
 music(0,3)
end

---------------

function startgame()

 t=61*60
 gamestate="game"
 
 time_col=9
 
 makenuts()
 make_speed()
 make_clock()

 enemies={}
 enemy_speed=0.5
 angry_timer=0
 
 addenemy(112,112)
 addenemy(8,16)
 addenemy(16,88)
 addenemy(96,64)
 addenemy(112,64)
 
 pilz_sp=pilznow
 pilz_x=64
 pilz_y=64
 pilz_mx = 0
 pilz_my = 0
 
 pilz_speed=1
  
 pilznow=1
 pilzrechts=33
 pilzlinks=17
 pilzvorne=1
 pilzhinten=49
 
 pilzmove=true
 walking=false
 hopping=false
 hop=0
 
 nuss_sp=9
 --powerups
 speed_sp=57
 speedtimer=0
 speedon=false
 
 clock_sp=42
 clock=false
 clocktimer=0
 clockon=false
 bonus_x=78
 bonus_y=2
 
 tp_sp=23
 end_tp_sp=39
 

 lasthit=false
 
 leben=3
 score=0
 
 flash=0
 flashpilz=0
 flashenemy=0
 
 shake=0
 
 blink_col=9
 time_blink_col=9
 blink_x=9
  
 key=false

 have_key=false
 
 key_sp=43
 key_x=64
 key_y=64
 
 tor=false
 
 clocktimer=0
 clockon=false
 
 teleport_rot=false
 teleport_blau=false
 teleport=true
 teleport_timer=0
 ankommen=false
 ankommen_timer=0
 
end
-------------------

function gameover()
 gamestate="over"
end

-------------------
function makenuts()
 
 nuss_map_pos = {}

 for y = 0, 63 do
  for x = 0, 127 do
   if mget(x, y) == 7 then
    -- nuss pos speichern
    add(nuss_map_pos,
        {x = x, y = y})
   end
  end
 end
end
----------------------
--make power up
function make_speed()
 speed_map_pos={}
 for y=0,63 do
  for x=0,127 do
   if mget(x,y) == 38 then
   add(speed_map_pos,
       {x=x,y=y})
   end
  end
 end
end
-------------------
function make_clock()
 clock_map_pos={}
 for y=0,63 do
  for x=0,127 do
   if mget(x,y) == 59 then
   add(clock_map_pos,
       {x=x,y=y})
   end
  end
 end
end
----------------------
function addenemy(ex,ey)
 newenemy={}
 newenemy.x=ex
 newenemy.y=ey
 newenemy.speedx=-enemy_speed
 newenemy.speedy=0
 newenemy.sp=31
 newenemy.angry_timer=0
 newenemy.speedboost=0
 add(enemies,newenemy)
end

-->8
--draw
function _draw()
 if gamestate=="menu" then
  draw_menu()
 elseif gamestate=="instructions" then
  draw_instructions()
 elseif gamestate=="ready"then
  draw_ready()
 elseif gamestate=="game" then
  draw_game()
 elseif gamestate=="over" then
  draw_over()
 elseif gamestate=="win" then
  draw_win()
 end
end

---------------

function draw_menu()
 
 print(t,64,8)
 cls(0)
 map(16,0)
 
 spr(162,80,72)
 spr(163,88,72)

 --spr(1,px,py)
end

---------------
function draw_instructions()
 cls()
 --pal(8,15)
 
 map(32,0)
-- pal()
 if btn(5) then
  pal(8,11)
  spr(162,64,64)
  spr(163,72,64)
 else 
  spr(162,64,64)
  spr(163,72,64)
 end
 pal()
 
 --print("instructions")
 print("press -c- to escape",27,112,time_blink_col)
 
 if btn(1) then
  pal(5,11) 
  spr(182,69,34)
 else spr(182,69,34)
 end
 pal()
  
 if btn(0) then
  pal(5,11) 
  spr(183,49,34)
 else spr(183,49,34)
 end
 pal()
  
 if btn(2) then
  pal(5,11) 
  spr(184,59,24)
 else spr(184,59,24) 
 end
 pal()
 
 if btn(3) then
  pal(5,11) 
  spr(185,59,34)
 else spr(185,59,34)
 end
 pal() 
end
----------------

function draw_over()
 cls()
 map(48,0)
 --print("over")
 print("press — to retry",32,122,time_blink_col)
 
end
---------------
function draw_win()
 t+=1
 cls()
 --part={}
 drawparts()
 map(64,0)
 --print("win")
 print("press — for menu",30,119,time_blink_col)
 
 if (t%48<=16) then
  spr(64,45,80,4,4)
 elseif (t%48>=32) then
  spr(68,45,80,4,4)
 else 
  spr(203,45,80,4,4)
 end
 
end
-----------------
function draw_game()
 t-=1
 cls(5)

--map zeichnen
 map(0,0)
 rectfill(95,0,127,10,3)
 rect(95,-1,128,10,0)
 rectfill(84,-1,95,10,3)
 rect(84,-1,95,10,0)
 
--zeit zeichnen
 print("time:"..flr(t/60),50,2,time_col)

 doshake()
 
--teleporter
 tp_rot()
 tp_blau()
 
--nach teleport erscheinen 
 if pilznow==12 and 
  pilz_x==24 and
  pilz_y==40 or
  pilznow==12 and
  pilz_x==112 and
  pilz_y==16 then
  ankommen=true
 end
 
 if teleport_timer>0 then
  teleport_timer-=1
 end

 if teleport_timer>=0.8*30 then
  pilznow=12
 elseif teleport_timer>=0.6*30 then
  pilznow=28
 elseif teleport_timer>=0.4*30 then
  pilznow=44
 elseif teleport_timer>=0.2*30 then
  pilznow=1
 elseif teleport_timer<=0 then
  ankommen=false 
  pilz_move=true 
 end

--schloss zu zeichnen
 spr(56,24,8)

--tor zeichnen
 if tor==false then
  spr(55,120,64)
 --begrenzung tor
  if pilz_x>=112 and 
   pilz_y==64 then
   pilz_x=112 
  end
 end
--key-sprite wechseln
 if t%36>=24 then 
  key_sp=26
 elseif t%36>=12 then
  key_sp=27
 else key_sp=43
 end

--key einsammeln
 --key inventar zeichnen
  spr(10,86,1) 
 --print(have_key,20,20)
  if score==100 then
  key=true
  spr(key_sp,key_x,key_y)
  
  --spr(44,82,2) 
  if pilz_x==key_x and
   pilz_y==key_y and
   btnp(5) 
   and score ==100 then
   have_key=true
   key=false
   score=101
   sfx(26)
  end
 end
 if have_key==true then
  
  spr(key_sp,86,1)
  if t%32>=16 then
   spr(56,24,8)
  else spr(25,24,8)
  end
 end
----schloss oeffnen  
 --print(tor,20,20)
 if have_key==true then
  if pilz_x==24 and
   pilz_y==8 and 
   btnp(5) then
   have_key=false
   sfx(4)
   
   tor=true
  end
 end
--offenes tor u schloss zeichnen
 if tor==true then
  spr(54,120,64)
  spr(58,24,8)
 end
   
 --flash pilz
 if flashpilz>0 then
  pal(15,14)
  flashpilz-=1
 end
 --particles
 drawparts()
 
--pilz zeichnen
 spr(pilznow,pilz_x,pilz_y)
-- print(pilz_x,0,54,8)
-- print(pilz_y,0,64,8)
 
 updateparts()
 --print("leben:"..leben,80,2,8)

 pal()

 --score zeichnen
 print(":"..score.."/100",10,2,9)
 spr(9,2,1)
 
 --lebensanzeige
 
  for d=1,3 do
   spr(4,126-d*9,1)
  end
  for l=1,leben do
   spr(20,126-l*9,1)
  end

--pilz geh-animation

 if walking==true then

  spawntrail(pilz_x+3,pilz_y+7)
 

  if t%12<4 then
   pilzrechts=33
   pilzlinks=17
   pilzvorne=1
   pilzhinten=49
  elseif t%12<8 then
   pilzrechts=34
   pilzlinks=18
   pilzvorne=2
   pilzhinten=50
  else
   pilzrechts=35
   pilzlinks=19
   pilzvorne=3
   pilzhinten=51
  end
 end
--animation ende
 if walking==false then
  if pilznow==pilzrechts then
   pilznow=33
  end
  if pilznow==pilzlinks then
   pilznow=17
  end
  if pilznow==pilzvorne then
   pilznow=1
  end
  if pilznow==pilzhinten then
   pilznow=49
  end
 end

--draw nuesse
 for n in all(nuss_map_pos) do
  spr(nuss_sp, n.x * 8, n.y * 8)
 end
 
--draw speed
 for s in all(speed_map_pos) do
  spr(speed_sp,s.x*8,s.y*8)
 end
 --draw clocks
 if clock==false then
  if t<=20*60 then
   sfx(5)
   clock=true
   for c in all(clock_map_pos) do
    place_clock_parts((c.x*8)+4,(c.y*8)+4)
   end
  end
 end

 pal()

--draw clock
 if clock==true then
  for c in all(clock_map_pos) do
   spr(clock_sp, c.x*8, c.y*8)  
  end
 end

--draw enemies
 local spoffset=0
 if speedon then spoffset=-1 end
 for e in all(enemies) do
  spr(e.sp+spoffset, e.x, e.y-flr(hop%2))
 end
 
 bonus_time()
  
end
---------------



-->8
--update
function _update60()
 doblink() 
 doblink_time()
 
 if gamestate=="menu" then
  update_menu()
  
 elseif gamestate=="instructions" then
  update_instructions()
 elseif gamestate=="ready" then
  update_ready()
 elseif gamestate=="game" then
  update_game()
 elseif gamestate=="over" then
  update_over()
 elseif gamestate=="win" then
  update_win()
 end
end
-----------------
function update_menu()
 
 if btnp(5) then
  gamestate="instructions"
 end
 
end
-----------------
function update_instructions()
 if btnp(4) then
  
  startgame()
  music(-1,300)
 -- music(16)
 end
end
-----------------
function update_over()
 
 if btnp(5) then
  startgame()
  music(-1,300)
 end
end 
------------------
function update_win()
 
 updateparts()
 
 if rnd()<0.3 then
 spawn_feuerwerk(rnd(128),rnd(128))
 end
 
 if btnp(5) then
  gamestate="menu"
  
 end
end

-----------------
-------------------
function update_game()
 
 walking=false
 --kollidiert=false
 key=false 
 
 if speedon then
  speedtimer-=1
  if speedtimer <= 0 then
   for e in all (enemies) do
    e.speedboost=0

   end
   speedon=false
  end
 end
--clock
 if clockon then
  clocktimer-=1  
  if clocktimer <= 0 then 
   clockon=false
  end
 end
 tic_toc()
 
 --pilz bewegen
 if pilz_move==true then
  move_pilz()
 end
 
 
 check_nuts()
 check_speed()
 check_clock()
 --zeit
 
 
 if t==0 then 
  music(-1,300)
  sfx(25)
  gameover()
  music(15)
  
 end
 
--win
 if pilz_x>120 then
  music(-1,300)
  sfx(21)
  
  gamestate="win"
  music(0)
 end
   
 --gegner bewegen
 for e in all(enemies) do
  move_enemy(e)
 end
 

--kollision pilz,gegner
 local hits=0
 for e in all(enemies) do
  if ezcollide(pilz_x,pilz_y,e.x,e.y) then
   hits+=1
   if lasthit==false then
    sfx(0)
    flashpilz=4
    shake=0.1
    leben-=1
    collide_parts(pilz_x,pilz_y)
    
   --  
    if speedon==false then
    --angry enemey nur 
    --wenn nicht eingefroren
     makeangry(e)
     e.angry_timer=60*4
     e.speedboost=0.25
    end 
   -- 
    lasthit=true
    if leben<=0 then
     gameover()
     --sfx(25) 
     music(15)
    end
   end
  end
 end
 if hits==0 then
  lasthit=false
 end
end
-----------------

--collide function

function collide (x1,y1,b1,h1,x2,y2,b2,h2)
 if x1+b1>x2 and x1<x2+b2 then
  if y1+h1>y2 and y1<y2+h2 then
   return true
  end
 end 
 return false 
end

function ezcollide(x1,y1,x2,y2)
 return collide (x1,y1,8,8,x2,y2,7,7)
end
-->8
--move pilz+labyrinth
function move_pilz()
 local old_x=pilz_x
 local old_y=pilz_y

 if btn(1) then 
  pilz_x+=pilz_speed
  pilznow=pilzrechts
  walking=true
 end
 if btn(0) then
  pilz_x-=pilz_speed
  pilznow=pilzlinks
  walking=true 
 end
 if hitwall(pilz_x,pilz_y,0) then
  if hitwall_sq(pilz_x,pilz_y,0) then
   pilz_x=old_x
  else
   if pilz_x<old_x then
    nudge("links")
   else
    nudge("rechts")
   end
   old_y=pilz_y
  end
 end
 if btn(2) then
  pilz_y-=pilz_speed
  pilznow=pilzhinten
  walking=true
 end
 if btn(3) then
  pilz_y+=pilz_speed
  pilznow=pilzvorne
  walking=true
 end
 
 if hitwall(pilz_x,pilz_y,0) then
  if hitwall_sq(pilz_x,pilz_y,0) then
   pilz_y=old_y
  else
   if pilz_y<old_y then
    nudge("oben")
   else
    nudge("unten")
   end
  end
 end
 
 pilz_mx = flr((pilz_x+4)/8)
 pilz_my = flr((pilz_y+4)/8)
 
-------------------- 
--teleport blau


 if pilz_x==8 and 
  pilz_y==112 and
  btnp(5) then
  sfx(2)
  teleport_timer=1*30
  teleport_blau=true
  --pilz_x=112 
 -- pilz_y=16
 end

--teleport blau 2 
 if pilz_x==48 and 
  pilz_y==16 and
  btnp(5) then
  sfx(2)
  teleport_timer=1*30
  teleport_blau=true
  --pilz_x=112 
 -- pilz_y=16
 end
 if pilz_x==112 and
  pilz_y==16 and
  btnp(5) then
  sfx(3)
 end 
 
--teleport rot
 
 if pilz_x==112 and
  pilz_y==96 and
  btnp(5) then
  teleport_timer=1*30
  teleport_rot=true
  sfx(2) 
  --pilz_x=24
  --pilz_y=40
 end
--
 if pilz_x==24 and
  pilz_y==40 and
  btnp(5) then

  sfx(3)
 end 
  
end
----------------------
function hitwall(_x,_y)--_pad)
 --if _pad==nil then _pad=0 end
 if (checkspot(_x,_y,0)) return true
 if (checkspot(_x+7,_y  ,0)) return true
 if (checkspot(_x,_y+7,0)) return true
 if (checkspot(_x+7,_y+7,0)) return true
 
 return false
end
---------------------
function checkspot(_x,_y,_flag)
 local tilex=_x/8
 local tiley=_y/8
 local tile=mget(tilex,tiley)
 return fget(tile,_flag)
end
-------------------------
--nuss essen
function check_nuts()

 for n in all(nuss_map_pos) do
  
  if pilz_mx == n.x
  and pilz_my == n.y then
   -- nuss aufsammeln
   del(nuss_map_pos, n)
   sfx(1)
   score+=1
   --particle
   nut_parts(pilz_x, pilz_y)
  end
 end
end
----------------------------
--speed essen
function check_speed()
 for s in all(speed_map_pos) do
  if pilz_mx==s.x
  and pilz_my==s.y then
  --speed aufsammeln
   del(speed_map_pos, s)
   --pilz_speed+=1
   speedtimer=60*5
   for e in all (enemies) do
    -- enemies unangry machen
    unangry(e)
    e.speedboost=-0.25
   end
   --slow_enemy()
   
   speedon=true
  end  
 end
end
--check clock
function check_clock()
 if clock==true then
  for c in all(clock_map_pos) do
   if pilz_mx==c.x
   and pilz_my==c.y then
    --clock aufsammeln
    sfx(6)
    clock_parts(pilz_x,pilz_y)
    t+=20*60 
    clocktimer=1*60
    clockon=true
    time_col=9
    del(clock_map_pos, c) 
   end  
  end
 end
end


-------------------------
--move enemy
function move_enemy(e)
 if e.angry_timer>0 then
 
  e.angry_timer-=1
  
  if e.angry_timer <= 0 then
   e.speedboost=0
   
  end
 end
 
 spawntrail_e(e.x+3,e.y+7)
 local old_x=e.x
 local old_y=e.y
 
 if  e.speedx!=0 then
  e.x+=e.speedx+e.speedboost*sgn(e.speedx)
  
 end
 if  e.speedy!=0 then
  e.y+=e.speedy+e.speedboost*sgn(e.speedy)
 end
 -- wandkollision 
 if hitwall(e.x,e.y) then
  e.x=old_x
  e.y=old_y
  
  -- kann man richtung aendern?
  if e.speedx!=0 then
   -- bei horizontaler bewegung
   if hitwall(e.x,e.y-8)==false then
    enemy_oben(e)
   elseif hitwall(e.x,e.y+8)==false then
    enemy_unten(e)  
   else
    enemy_umdrehen(e)
   end
  else
   -- bei vertikaler bewegung
   if hitwall(e.x-8,e.y)==false then
    enemy_links(e)
   elseif hitwall(e.x+8,e.y)==false then
    enemy_rechts(e)
   else    
    enemy_umdrehen(e)
   end  
  end
 end
   if hopping then
  hop+=0.02
 else
  hop=0
 end
end

function unangry(e)
 e.angry_timer=0
 if e.sp==37 then
  e.sp=63
 elseif e.sp==36 then
  e.sp=15
 elseif e.sp==52 then
  e.sp=31
 elseif e.sp==53 then
  e.sp=47
 end
end

function makeangry(e)
 e.angry_timer=0
 if e.sp==63 then
  e.sp=37
 elseif e.sp==15 then
  e.sp=36
 elseif e.sp==31 then
  e.sp=52
 elseif e.sp==47 then
  e.sp=53
 end
end

--enemymovements
function enemy_oben(e)
 e.speedx=0
 e.speedy=-enemy_speed
 e.sp=63
 hopping=true 
 if e.angry_timer>0 then
  e.sp=37
 end
end

function enemy_unten(e)
 e.speedx=0
 e.speedy=enemy_speed
 e.sp=15
 hopping=true
 if e.angry_timer>0 then
  e.sp=36
 end
end

function enemy_links(e)
 e.speedx=-enemy_speed
 e.speedy=0
 e.sp=31
 hopping=true
 if e.angry_timer>0 then
  e.sp=52
 end
end

function enemy_rechts(e)
 e.speedx=enemy_speed
 e.speedy=0
 e.sp=47
 hopping=true
 if e.angry_timer>0 then
  e.sp=53
 end
end

function enemy_umdrehen(e)
 if e.speedx==0 then
  if e.speedy<0 then
   enemy_unten(e)
  else
   enemy_oben(e)
  end
 else
  if e.speedx<0 then
   enemy_rechts(e)
  else
   enemy_links(e)
  end 
 end
end

-->8
--juice--

--shake
function doshake()

 local shakex=16-rnd(32)
 local shakey=16-rnd(32)

 shakex*=shake
 shakey*=shake
 
 camera(shakex,shakey)
 
 shake = shake*0.95
 if (shake<0.05) shake=0
end
----------------------
--do blinking
function doblink()
 blinkframe += 1
 if blinkframe>blinkspeed then
  blinkframe=0
  if blink_col==9 then
   blink_col=0
  else
   blink_col=9
  end
 end
end
------------
function doblink_time()
 local col_seq = {7,8,9,10}
 blinkframe += 1
 if blinkframe>blinkspeed then
  blinkframe=0
  
  blink_col_i+=1
  if blink_col_i > #col_seq then
   blink_col_i=1
  end
  time_blink_col=col_seq[blink_col_i]

 end
end
---------------------
function doblink_x()
 local col_seq = {7,8,9,10}
 blinkframe += 1
 if blinkframe>blinkspeed then
  blinkframe=0
  
  blink_col_i+=1
  if blink_col_i > #col_seq then
   blink_col_i=1
  end
  time_blink_col=col_seq[blink_col_i]

 end
end
----------------------
--time bonus
function bonus_time()
 
 if clock==true then
  if clocktimer>=0.9*60 then
   print("+20", pilz_x, pilz_y-4, time_blink_col)
 
  elseif clocktimer>=0.7*60 then
   print("+20", pilz_x, pilz_y-6, time_blink_col)
 
  elseif clocktimer>=0.5*60 then
   print("+20", pilz_x, pilz_y-8, time_blink_col)
 
  elseif clocktimer>=0.3*60 then
   print("+20", pilz_x, pilz_y-10, time_blink_col)
  elseif clocktimer>=0.1*60 then
   print("+20", pilz_x, pilz_y-12, time_blink_col)
  end
 end
end
---------------
--particles
-------------

--add partcile
function addpart(_x,_y,_dx,_dy,_type,_maxage,_col)
 local _p = {}
 _p.x = _x
 _p.y = _y
 _p.dx = _dx
 _p.dy = _dy
 
 _p.tpe = _type
 _p.mage = _maxage
 _p.age=0
 _p.col= _col
 add(part,_p) 
end
-------------
--spawn trail
function spawntrail(_x,_y)
 local _ang = rnd() --angle(1-360grad)
 local _ox = sin(_ang)*2--offset x
 local _oy = cos(_ang)*2
 
 addpart(_x+_ox,_y,0,0,0,5+rnd(7),2)
 
end
---------
function  spawntrail_e(_x,_y)
 local _ang = rnd()
 local _ox = sin(_ang)*2
 local _oy = cos(_ang)*2
 addpart(_x+_ox,_y,0,0,0,5+rnd(7),6)
end

--------------
--update particles
function updateparts()
 local _p
 for i=#part,1,-1 do
  _p = part[i]
  _p.age+=1
  if _p.age > _p.mage
   or _p.x>128
   or _p.x<0
   or _p.y>128
   or _p.y<0
   then
   del(part,part[i])
  else
  
  end
  --move particle
  _p.x+=_p.dx
  _p.y+=_p.dy
  
 end
end
-------------
--draw particles
function drawparts()
 for i=1,#part do
  _p = part[i]
  -- pixel particle
  if _p.tpe == 0 or 
     _p.tpe == 1 then
   pset(_p.x,_p.y,_p.col)
  end
  if _p.tpe ==2 then
   line(_p.x,_p.y,_p.x+_p.dx,
        _p.y+_p.dy,_p.col)
   if _p.age>15 then _p.col=8
    elseif _p.age > 10 then _p.col=9
    elseif _p.age > 5 then _p.col=10  
    else _p.col=7 
   end
  end
 
 end  
end
----------------
--nuss einsammeln particles
function nut_parts(_x,_y)
 for i=0,5 do
  local _ang = rnd()
  local _dx = sin(_ang)*1
  local _dy = cos(_ang)*1
  addpart(_x, _y, _dx, _dy, 
          0, 10 , 9)
 end
end
--------------------
function place_clock_parts(_x,_y)

 for i=0,5 do
  local _ang = rnd()
  local _dx = sin(_ang)*1
  local _dy = cos(_ang)*1
  addpart(_x, _y, _dx, _dy, 
          0, 10 , 8)
 end
end
-----------------
--kollision gegner parts
function collide_parts(_x,_y)
 for i=0,10 do
  local _ang = rnd()
  local _dx = sin(_ang)*0.5
  local _dy = cos(_ang)*0.5
  addpart(_x, _y, _dx, _dy, 
          0, 10 , 8)
 end
end
-------------------
--clock einsammeln parts
function clock_parts(_x,_y)
 for i=0,7 do
  local _ang = rnd()
  local _dx = sin(_ang)*1
  local _dy = cos(_ang)*1
  addpart(_x, _y, _dx, _dy, 
          0, 15 , 2)
 end
end
--------------------
--particles feuerwerk


function spawn_feuerwerk(_x,_y)
 for i=0,50 do
  local _ang = rnd()
  local speed =0.2+rnd(1)
  
  local _dx=(sin(_ang)*speed)
  local _dy=cos(_ang)*speed
  --local age=flr(rnd(25))
  --gravity
  _dy+=0.15
 
  addpart(_x,_y, _dx, _dy, 
          2, flr(rnd(25)) , 9)
 end
end

-----------------------

function tp_blau()
  if  pilz_x==8 and
     pilz_y==112 
  or pilz_x==48 and
     pilz_y==16 then
  rectfill(20,119,112,127,7)
  rect(20,119,112,127,blink_col)
  print("press -".."x".."- to teleport",25,121,0)
  if t%24>12 then
   pal(12,1)
  else 
   pal()
  end
 end
 
--blau tp zeichnen
 spr(39,112,16)
 pal()
end
-----------------
function tp_rot()
--hinweis roter tp
 if pilz_x==112 and 
  pilz_y==96 then
  rectfill(20,119,112,127,7)
  rect(20,119,112,127,blink_col)
  print("press -".."x".."- to teleport",25,121,0)
  if t%24>12 then
   pal(8,2)
  else 
   pal()
  end
 end
--rot tp zeichnen
 spr(40,24,40)
 pal()
 

----------------------
--teleport animation
------------------------
  if teleport_rot==true then
  teleport_timer-=1 
  if teleport_timer>=0.8*30 then
   pilznow=13
  elseif teleport_timer>=0.6*30 then
   pilznow=45
  elseif teleport_timer>=0.4*30 then
   pilznow=29
  elseif teleport_timer>=0.2*30 then
   pilznow=13
  elseif teleport_timer<=0 then   
   teleport_rot=false
    pilz_x=24
    pilz_y=40
    pilznow=12
    pilz_move=false
    ankommen=true
    teleport_timer=1*30
  end
 end
 -----------
 if teleport_blau==true then
  teleport_timer-=1 
  if teleport_timer>=0.8*30 then
   pilznow=1
  elseif teleport_timer>=0.6*30 then
   pilznow=45
  elseif teleport_timer>=0.4*30 then
   pilznow=29
  elseif teleport_timer>=0.2*30 then
   pilznow=13
  elseif teleport_timer<=0 then   
   teleport_blau=false
    pilz_x=112
    pilz_y=16
    pilznow=12
    pilz_move=false
    ankommen=true
   teleport_timer=1*30
  end
 end
 
end
--------time sound
 --sound zeit
function tic_toc()
 for i=10,1,-2 do
  if t==i*60 then
   shake=0.05
   sfx(7) 
   time_col=8
   
  end
 end
 for i=9,01,-2 do
  if t==i*60 then
   shake=0.05
   sfx(7) 
   time_col=9
   
  end
 end
end

-->8
--krystian's magic kollision

----------------------
function hitwall_sq(_x,_y)
 if (checkspot(_x+4,_y,0)) return true
 if (checkspot(_x,_y+4,0)) return true
 if (checkspot(_x+7,_y+4,0)) return true
 if (checkspot(_x+4,_y+7,0)) return true
 
 return false
end
----------------------
 --if (checkspot(_x+_pad,_y+_pad,0)) return true
 --if (checkspot(_x+7-_pad,_y+_pad  ,0)) return true
 --if (checkspot(_x+_pad,_y+7-_pad,0)) return true
 --if (checkspot(_x+7-_pad,_y+7-_pad,0)) return true

function nudge(_dir)
 if _dir=="links" then
  pilz_y=flr(pilz_y/8)*8
  if checkspot(pilz_x,pilz_y,0) then
   pilz_y+=8
  end
 elseif _dir=="rechts" then
  pilz_y=flr(pilz_y/8)*8
  if checkspot(pilz_x+7,pilz_y,0) then
   pilz_y+=8
  end 
 elseif _dir=="oben" then
  pilz_x=flr(pilz_x/8)*8
  if checkspot(pilz_x,pilz_y,0) then
   pilz_x+=8
  end
 elseif _dir=="unten" then
  pilz_x=flr(pilz_x/8)*8
  if checkspot(pilz_x,pilz_y+7,0) then
   pilz_x+=8
  end
 end
end
__gfx__
0000000000878800008788000087880000676600000000003333333355555555555555550000000033355533000000000000000000878800000cc0ff000440ff
000000000288872002888720028887200666676000000000333bb3335555555555555555004444003335333300000000000000000288872000c3c1fc004342f4
0070070027888882278888822788888267666666000000003b333333555d5555555d555504444440333553330000000000000000000000000dccc1fc0d4442f4
0007700009799790097997900979979005555550000000003b3333bb55555555555555550099990033353333000000000000000000000000000cc1cc00044244
00077000ffcffcffffcffcffffcffcff556556550000000033b33bb35555555d5555555d00ffff003335333300000000000000000000000000cccc1c00444424
007007000ffffff00ffffff00ffffff005555550000000003333bb335555555555555555000ff0003355553300000000000000000000000000cffc1c004ff424
0000000000f00f0000f0080000800f0000500500000000003333b333d5555555d555555500000000335335330000000000f00f000000000000cffcc0004ff440
00000000008008000080000000000800006006000000000033333333555555555555555500000000335555330000000000800800000000000cc00c0004400400
0000000000788200007882000078820000788800333333334444444455555555555d5555000770000009990000099900000000000087880000cc00fc004400f4
0000000008887820088878200888782008887880333333334444444455cccc555588885500700900000900000009000000000000028887200c3c0fcc04340f44
000000008888887288888872888888728888887833333333444444445c5d55c558555d8500a0090000099000000a90000000000027888882dccc0fccd4440f44
000000000979799009797990097979900f7ff7f033333333444444445c5cc5c55858858507a77a9000090000000a0000000000000979979000cc0ccc00440444
00000000ffcfcfffffcfcfffffcfcfffffcffcff33333333444444445c5cc5cd5858858d07aaaa9000090000000a0000ffcffcff000000000ccccccc04444444
000000000ffffff00ffffff00ffffff00ffffff033333333444444445c5555c55855558507aeaa9000999a0000a999000ffffff00000000000fc1cc000f42440
0000000000f00f0000f0080000800f0000f00f003333333344444444d5cccc55d588885507aaea9000900a000090090000f00f000000000000fcc10000f44200
000000000080080000800000000008000080080033333333444444445555555555555d5507aaaa900099a9000099990000800800000000000cccc00004444000
00000000002788000027880000278800000880ff008800ff55555555000000000000000000000000000000000009a9000000000000878800cf00cc004f004400
00000000028878800288788002887880008382f808380f885555555500000000000000000000000000022000000a00000000000002888720ccf0c3c044f04340
000000002888887828888878288888780d8882f8d888f888555d555500000000000000000000000000275200000a90002788888227888882ccf0cccd44f0444d
00000000099797900997979009979790000882880022f88055555555000cc000000880000000000002775720000900000979979009799790ccc0cc0044404400
00000000fffcfcfffffcfcfffffcfcff008888280082f8805555555d000cc00000088000000000000275572000090000ffcffcffffcffcffccccccc044444440
000000000ffffff00ffffff00ffffff0008ff828008888205555555500000000000000000000000000277200009999000ffffff00ffffff00cc1cf0004424f00
0000000000f00f0000f0080000800f00008ff880008ff800d5555555000000000000000000000000000220000090090000f00f0000000000001ccf0000244f00
0000000000800800008000000000080008800800088008805555555500000000000000000000000000000000009999000080080000000000000cccc000044440
00000000008878000088780000887800008800f88f00880049444494445d5555000aa00000000000000aa0005555555500000000000880ff00cc00ff004400ff
0000000002878820028788200287882008380f8888f083804a4444a4a955555500a0040000c6cc0000a000005555555500000000008382f80c3c0fcc04340f44
00000000278887822788878227888782d8880f8888f0888d55555d5544555d55009004000c6cccc000900000555d5555000000000d8882f8dcccfcccd444f444
0000000009999990099999900999999000880888888088005d555555445555550a9aa940001161000a9aaa405555555500000000000882880011fcc00022f440
00000000ffffffffffffffffffffffff08888888888888805555555d445d555d0a999940007677000a9999405555555d000000000088882800c1fcc00042f440
000000000ffffff00ffffff00ffffff000f8288008828f0055555555445555550a989940000770000a9b99405555555500000000008ff82800cccc1000444420
0000000000f00f0000f0080000800f0000f8820000288f00d5555555a95555550a998940000000000a99b940d555555500000000008ff88000cffc00004ff400
00000000008008000080000000000800088880000008888055555d5544555d550a999940000000000a9999405555555500000000088008000cc00cc004400440
000000000000000000000000000000000000000000000000000000000000000000000000000020000020000000000000bbbb33bb33333333bb3bbbbb00000000
000000000000000000000000000000000000000000000000000000000000000000000000000220000022000000000000b33bb33333333333b333b33b00000000
000000000000000000000000000000000000000000000000000000000000000000000000002222222224200000000000bb33333333333333b3333b3300000000
000000000000888888880000000000000000000000008888888800000000000000000000222ffffff422420000000000bb3333b333333333bb33333b00000000
0000000000088888888880000000000000000000000888888888800000000000000000022444ffff4442240000000000b3b33bb3333333333bb33bb300000000
000000000087788888888800000000000000000000877888888888000000000000000022444fffff4444272000000000b333bb3333333333b3b3bb3300000000
000000000887788888888880000000000000000008877888888888800000000000000024444ffff44444234000000000b333333333333333b333b33b00000000
000000008888888888887788000000000000000088888888888877880000000000000024444ffff44444424250000000bbb3bbbbbbbbbbbbb333333b00000000
00000008888888888887777880000000000000088888888888877778800000000000002444fffff44444424455000000bb3bb33b3bbbb13bbbbbbbbb00000000
00000088888888888887777788000000000000888888888888877777880000000000002444ffff4444444244420000003b133333b3231a13b3bb333b00000000
00000888888888888887777788800000000008888888888888877777888000000000002444ffff44444422442000000031a1333bb2a23133b3b3333b00000000
00008888888888888888777888880000000088888888888888887778888800000000000244ffff444444222200000000bb13bb333323b323b333333300000000
00088888888888888888888888888000000888888888888888888888888880000000000244fff4444444220000000000b33b33333bb332a2b3bbbb3300000000
00888877888888888888888888888800008888778888888888888888888888000000000024fff444444220000000000033333b2b3313332bbb333b3300000000
0888877778888888888888888888888008888777788888888888888888888880000000002ffff44444224400000000003333b2a231a1bb33b3333bbb00000000
8888877778888888888888888887778888888777788888888888888888877788000000022ffff44442244420000000003333332b331b33b3b333b33300000000
8888887788888888888888888887777888888877888888888888888888877778000000024ffff4442224442000000000bb33bbbbbbbbbbbb333bb33bb33bb33b
8888888888888888778888888887777888888888888888887788888888877778000000024fff4442224444420000000033b3333b333bb3333333bb3b3333bb3b
8888888888888888778888888887777788888888888888887788888888877777000000024fff4442224444420000000033333bbb3b333333b3333b33b3333b33
77888888888888888888888888888778778888888888888888888888888887780000000244ff44442244442000000000b333bb333b3333bbbb33333bbb33333b
77888889991119999991119999888888778888899911199999911199998888880000000244ff44442244442000000000bb33333b33b33bb33bb33bbb3bb33bbb
88888999991719999991719999988888888889999917199999917199999888880000022244fff444424442222200000033bb333b3333bb3333b3bb3bb3b3bb3b
888899ffff101ffffff101ffff998888888899ffff101ffffff101ffff99888800000242444ff444424422244220000033333bb33333b3333333b33bb333b33b
08889fffffc07ffffffc07fffff9888008889fffff70cffffff70cfffff9888000002442244fff44442422444442000033333b3bbbbbbbbb3bbb33bbb333333b
0000fffefecccffffffcccfefeff00000000ffefefcccffffffcccffefef0000000024442444ff444424444444420000b333bb3bb33bb33b3333333300000000
0000ffefefffffffffffffefefff00000000fefefffffffffffffffefeff0000000244444244ff44442444444442000033bb3b3bb333bb3b3333333300000000
00009ffff99ffffffffff99ffff9000000009ffff99ffffffffff99ffff900000002444444244ff44424444444420000b33333b3b3333b333b33bb3300000000
000fffff9987777777777899fffff000000fffff9987777777777899fffff0000002444444244ff44442444444420000b333333bbb33333b3b33333300000000
00fffffffff88eeeeee88fffffffff0000fffffffff88eeeeee88fffffffff0000024444444244ff4442444444420000b3bbbb3b3bb33bbb33b333b300000000
0999999fffff8eeeeee8fffff99999900999999fffff8eeeeee8fffff999999000002444444424fff4224444444200003b333b33b3b3bb3b33b3bb3300000000
0ffffff9fffff7eeee7fffff9ffffff00ffffff9fffff7eeee7fffff9ffffff0000024444444224ff424444444200000b3333bbbb333b33b3333b33300000000
f9f9f9ff9fffff7777fffff9ff9f9f9ff9f9f9ff9fffff7777fffff9ff9f9f9f00000222222222299222222222000000b333b33bbbbb33bbbbbbbbbb00000000
44444444ffffffff533333b00053333b533333b000533b00053333b0288e288e428888e4288888e4f53333bfff533bff533f533bf53333bf3333333300000000
44444444ffffffff533333b00533333b533333b0053333b05333333b288e288e2888888e288888e45333333bf53333bf533533bf5333333b3333333300000000
44444444ffffffff533b0000533b0000533b0000533b533b533b533b288e288e44288e44288e4444533b533b533b533b53333bff533b533b3333333300000000
44444444ffffffff533333b0533b0000533b0000533b533b533b533b2888888e44288e44288888e4533b533b533b533b5333bfff533b533b3333333300000000
44444444ffffffff533333b0053333b0533b00005333333b5333333b2888888e44288e44288888e45333333b5333333b5333bfff533333bf3333333300000000
44444444ffffffff533b00000005333b533b0000533b533b533333b0288e288e44288e44288e4444533333bf533b533b53333bff53333bff3333333300000000
44444444ffffffff533333b00533333b533333b0533b533b533b0000288e288e44288e44288888e4533bffff533b533b533533bf533333bf3333333300000000
44444444ffffffff533333b0053333b0533333b0533b533b533b0000288e288e44288e44288888e4533bffff533b533b533f533b5335333b3333333300000000
028888e0028888e0288888e0002ffff7028888e000288e0000278e0000288e00599999afff59999af59999afff599affff599affff599aff599affff599a599a
2888888e2888888e288888e002f444472888888e028888e0028888e0028888e0599999aff599999a5999999af59999aff59999afff599aff599affff599a599a
288e288e288e288e288e00002f47000000288e00288e288e2788788e288e288e599affff599affff599a599a599a599a599a599aff599aff599affff599a599a
288e288e288e288e288888e02f47000000288e00288e288e2888888e288e288e599999af599affff599a599a599a599a599a599aff599aff599affff599a599a
2888888e288888e0288888e00244447000288e00288e288e004ff7002888888e599999aff59999af599999af599a599a599a599aff599aff599affff599a599a
288888e028888e00288e00000002444700288e00288e288e004ff700288e288e599afffffff5999a59999aff599a599a599a599aff599aff599affff599a599a
288e0000288888e0288888e00244444700288e00028888e0004ff700288e288e599999aff599999a599999aff59999aff59999afff599aff599999aff59999af
288e00002882888e288888e00244447000288e0000288e00004ff700288e288e599999aff59999af5995999aff599affff599a99ff599aff599999aff59999af
88e00288288888e00000566666670000533333b44453333b533333b444533b44453333b4453333b4533b533b288888e4428888e444288e44428888e444444443
888e2888288888e00000586666870000533333b44533333b533333b4453333b45333333b5333333b533b533b288888e42888888e428888e48888888844444134
288e288e288e00000000568668670000533b4444533b4444533b4444533b533b533b533b44533b44533b533b288e4444288e288e288e288e88e8828844441a14
288e288e288e00000000566886670000533333b4533b4444533b4444533b533b533b533b44533b445333333b288888e4288e288e288e288e88e4428844443144
288e288e288e00000000566886670000533333b4453333b4533b44445333333b5333333b44533b445333333b288888e4288888e4288e288e88e4428844434444
288e288e288e00000000568668670000533b44444445333b533b4444533b533b533333b444533b44533b533b288e444428888e44288e288e88e4428844344444
2888888e288888e00000586666870000533333b44533333b533333b4533b533b533b444444533b44533b533b288e4444288888e4428888e488e4428843444444
028888e0288888e00002566666672000533333b4453333b4533333b4533b533b533b444444533b44533b533b288e44442882888e44288e4488e4428834444444
00288e0028e0288e0002f222222f2000344444440000028866666666666666666666666666655666028888e0288e288e0000000088e00288288e288e00288e00
00288e00288e288e000f09799790f000434444440000288e6665566666655666666556666665566688888888288e288e0000000088e00288288e288e00288e00
00288e002888e88e000f0fcffcf0f00044344444000288e06665556666555666665555666665566688e88288288e288e0000000088e00288028e28e000288e00
00288e002888888e000f0ffffff0f0004443244400288e005555555665555555655555566555555688e00288288e288e2222222288288e8800288e0000288e00
00288e002888888e000f09999990f0004442a2440288e0005555555665555555655555566555555688e00288288e288e2222222288288e8800288e0000288e00
00288e002882888e0000ffffffff000044442344288e00006665556666555666666556666655556688e00288288e288e0000000088288e8800288e0000000000
00288e00288e288e008000ffff0008004444443488e000006665566666655666666556666665566688e00288028888e0000000008888888800288e0000288e00
00288e00288e088e0088ffffffff8800444444438e0000006666666666666666666556666666666688e00288028888e000000000888e288800288e0000288e00
056666e000566e00056666e0566666e000566e0066e00566056666e0000000000000000000000000000000000000000000000000000000000000000000000000
5666666e056666e066666666566666e0056666e0666e56665666666e000000000000000000000000000000000000000000000000000000000000000000000000
56655550566e566e66e66566566e0000566e566e566e566e566e566e000000000000333333333000000000000000000000000000000000000000000000000000
56656600566e566e66e00566566666e0566e566e566e566e566e566e000000000333333333300000000000000000000000000000000000000000000000000000
5665666e5666666e66e00566566666e0566e566e566e566e566666e0000033333333330033333333300000000000000000000000000000000000000000000000
5665566e566e566e66e00566566e0000566e566e566e566e56666e00333333300000333300000000000000000000000000888888888888000000000000000000
566666e0566e566e66e00566566666e0056666e05666666e566666e0333330033333333333333333333033300000000008888888888888800000000000000000
05666e00566e566e66e00566566666e000566e00056666e05665666e330003333333333333333000033303330000000088888888888888880000000000000000
33333bb30000033333333333533333b000599a00599a000000000000303333333333333333003333300030330000000888888888888888888000000000000000
33333b330033333333b333335333333b00599a00599a000000000000333333333333333333330000000300000000008888778888888888888800000000000000
3333bb330333330033b333b3533b533b00599a00599a000000000000333300000333333333333b33333333330000088888778888888778888880000000000000
b333b3333003333333b33bb3533b533b00599a00599a00000000000033003333eee3333b33333b33333333330000888888888888888777788888000000000000
3b33b3b30033333333b33b33533b533b00599a00599a0000000000000033b33ee8e33e3bb3333b33333333330008888888888888888777788888800000000000
3b33bb333333333333b3bb33533b533b00599a00599a0000000000000333b33e88833e3333333b333b3333330088888888888888888877788888880000000000
3b33b3333333333333b333335333333b00599a00599999a000000000333333388882883333333b3333b333330888888888888888888877788888888000000000
333333333333333333333333533333b000599a00599999a00000000033333333888288333333333333b3333b8888888888888888888888888888888800000000
0059999a059999a0599999a000599a0000599a00333333333333333333333b33882888333333333333333b3b8888877888888888888888888888888800000000
0599999a5999999a599999a0059999a0059999a033333333333333333333b33388888833333333333b333b3b8888777788888888888888888887788800000000
599a0000599a599a599a0000599a599a599a599a3bb3b333333333333bb3b333888888333555e3333333b3b38888777788888888888888888887778800000000
599a0000599a599a599999a0599a599a599a599a3b33b333444333343b333b337788883335588eee333333338888877888888888778888888887777800000000
059999a0599999a0599999a0599a599a599a599a3b333344444443343b33b33e877888333588eeeeeeee3b338888888888888888778888888887777700000000
0005999a59999a00599a0000599a599a599a599a33333344444445443b3b33eeee7888333588eeeeeeeee3337788888888888888888888888887777800000000
0599999a599999a0599999a0059999a0059999a03333334fff4444533b3b37777881823355888888882333337788889999999999999999999988888800000000
059999a05995999a599999a000599a0000599a9933333f77fff444433333eeee781a1233588ee778b288833388888fffff171ffffff171fffff8888800000000
599a599a053333b000533b005330533b053333b03333f7ffffff4453333e8888e82122555888e872b22223330888ffffff101ffffff101ffffff888000000000
599a599a5333333b053333b0533533b05333333b333ffffffffff55533e88888882b255888778873333b33330000ffffffc07ffffffc07ffffff000000000000
599a599a533b533b533b533b53333b00533b533b33fffffffff99b55322b22b2222b535888877b33333b313300009ffefecccffffffcccfefef9000000000000
599a599a533b533b533b533b5333b000533b533b33fffbbfff999b53555bb5b5555b352888887b3333bb1a13000fffefefffffffffffffefeffff00000000000
599a599a5333333b5333333b5333b000533333b033fffbfff9995b5b333333b3b33335222822bb3333b3313b00fffffff99ffffffffff99fffffff0000000000
599a599a533333b0533b533b53333b0053333b00333f9b999b935bb333333b333b3333552223b3333b33b3b30999999f9987777777777899f999999000000000
059999a0533b0000533b533b533533b0533333b033939b99b3333b3333333b3333b3333353333333b333bb330ffffff9fff88eeeeee88fff9ffffff000000000
059999a0533b0000533b533b5330533b5335333b33333b33b33333333333333333bb33333333333b33333333f9f9f9ff9fff8eeeeee8fff9ff9f9f9f00000000
__gff__
0000000000000100000001000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000001010100000000000000000000000000010101000000000000000000000000000101010100000000000000000000000001010100
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1515154d151515151515151515151515050505050582838485868205050505058f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f000000000000000000000000008f00000000000000000000000000008f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6d086d6d6d5c6d6d6d6d6d5d6d5e05050580abacadae80888789800505058f8fb0b1939691a0a196b095b1938f8f8f00008fc0c1c2c3c4c5c3c60000008f00008f8fbe95bb8fbd95b1bf00008f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c0707070707177c070707070707086f050580818181818181818181818005058fbcbcbcbcbcbcbcbcbcbcbcbcbcbc8f8f00000000000000000000000000008f00000000000000000000000000008f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6f074c5d075e6d6e075e5d6d6d6c075c05808181999c9f9d9a9a989e818180058f8f8f8f8f8f8f8f8f8f8f8f8f8f008f8f000000000000000000000000008f8f008fbe95bb8f828384858682d3008f8f00000000000092b1d382bf00000000000000000000000000000000000000000000000000000000000000000000000000
6c070707076f0707076f0707077d077c0581818181818a8b8d8c8181818181058f00bb9392008f8f8f8f00949500008f8f000000000000000000000000008f8f00000000000000000000000000008f8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c6d5d085e6e074e077d074e0707076f058181808080808080808080808181058f000000008f8f8f8f8f8f000000008f8f000000000048494a4b000000008f8f00000000008f96879200000000008f8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c3b4c6d6e07077c0707077c074e077c058080050505050505050505058080058f0000000000ba95a09200000000008f8f000000008f58595a8f000000008f8f000000000000000000000000008f8f8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6f07070707075e7e6d6c076f077c076e05b4050505050505050505050505af058fbcbcbcbcbcbcbcbcbcbcbcbcbcbc8f8f0000008f8f68696a8f8f0000008f8f008fe0e4f0d4e1e1e2d5f1f2f4f38f8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c074c6d5d6d6e07085d077c3b6f073705b4050590919293930505050505af058f0090919293938f8f0000949500008f8f0000008f0078797a7b8f8f0000008f000000000000008f8f8f8f8f8f8f8f8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c07070707077d075e6e077d5c6e075e05b40505050505050505a2a30505af058f8f8f8f8f8f8f8fb2b38f8f8f8f008f8f00008f008fc7c8c9ca8f8f00008f8f000000008f0000008f8f8f8f8f8f8f8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c074c6d6c0707077c0707070707076f05b40505050505050505b2b30505af8f8f00008fb0b194929197a194008f8f8f8f00008f8fc7d1c8c9cac98f8f8f8f8f000000008fcbcbcbcbcbcb8f8fce8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6f07070707074e077d075e6c075d6d068fb4050594958f8f05050505058faf8f8fbcbcbcbcbcbcbcbcbcbcbcbcbcbc8f8f008fc7d08ed7d8d9dac8da8f8f8f8f0000000000cbcbcbcbcbcb8f8f8f8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c074e075e6d6e0707077c07077c187c8fb405050505059396979196058faf8f8fbd9794a1878f9687928f94b0ba928f8f8fd1d0d0d0e7e8e9ead0e5e6da8f8f8f0000008fcbcbcbcbcbcb8f8f8f8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d077d075c264c6d6d6d5d074c6e076f8fb45d050505058f8f8f8f8f055daf8f8f00000000000000000000000000008f8f8fd1d1d28ef7f8f9fa8ef5f6d08f8f0000000000cbcbcbcbcb8f8f8f8f8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6f1707076f070707070707070707077c8fb45c5d8f050505050505055d5caf8f8f00000000000000000000000000008f8f8f8fd1d1d28e8ed08ed28ed18f8f8f8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e008e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e00000000000000000000000000000000000000000000000000000000000000
066d6d6d066d6d6d6d6d5d6d6d6d6d6e4c7e7e7e6d6d6d6d6d6d6d6d7e7e7e6c8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e008e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e00000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606060606060606060606060605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0608080808060608080808080808080600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0608080808060607070707070707070600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0608080808060608080808080808080600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0607060606060606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0607060607070706060606060808080600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0607060607060706062706060838080600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0626080807060706060806060808080600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0606060607060706080708060608060600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0606060607070706070807060608060600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0606060606080606080708060608060600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0606060608080806060806060808080600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0617080808070806061806060828083700000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0606060608080806060606060808080600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
0606060606060606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050500000000000000000000000000
__sfx__
00160000100700a070290000e0702b000240001f0001d000180001700000000000000000000000000000000000000000002070000000000000000000000000000000000000000000000000000000000000000000
000400002a71032200322003020000000251000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000002311025110291202b1202c1302c14000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000000d7102773021740177300c7200771006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000001306015040190201b0202002025020290303203037030000003310000000190200000000000000003a0403b0000000000000000000000000000000001a000000000000000000000000000000000
000400002b7300f0002f00013000147201e00023000200002400027720266000000000000337502c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000000002401016020280101b0202b020200202f030221002b1002c10020100251002a1002f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b0000000002a010260202d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000290452904529045000001d0550000021055000001f0551d0551c0551a0551805500000000000000022045220452204500000220450000026045000002404500000000000000000000240452604528045
0114000029545295452955500000245452654528545295452b5452d5452f5452f5452f545000000000000000245451b5452b54522545295452b5452f545000002454500000000000000000000000002954529545
0114000029745297452974500000247452674528745297452b7452d7452f7452f7452f74500000000000000024745277452b7452e745297452b7452f745000002474500000000000000000000000002974529745
0114000024533000002d533130331703300000000000000024533000002d533130331703300000000000000024533000002d533130331703300000000000000024533000002d5331303317033000000000000000
01030000085640b7640e76412764175651b0651d0651e065000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000010052100520c0520c052100520c0520c052000000c052000000c052000000c0540c0540c0540000013052000000c0520c0520c0520000000000000000000000000000000000000000000000000000000
011e0000260322403228032290322b0322b0322d0322f0323003200000000000000028032290322f0322f032300320000000000290322d032000000000026032290320000029032000002b0322d0322603200000
011e0000180431a043280432404330043000000000000000180431a043280432404330043000000000000000180431a043280432404330043000000000000000180431a043280432404330043000000000000000
011e0000180641a06400000280641d06413064000000000018064000001a064280641d0641f06400000000000000018064000001a064280641d0641f06400000000000000018064000001a064280641d0641f064
011900002404200000260422b042290422b04224042290422f04230042320422b0422d0422f042320420000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011900002405400000000000000000000000000000000000000000000000000000000000000000000000000026054000002b054000002b0542b054000002d0542f05400000230543004439044000000000000000
00190000000000000000000000000000000000000000000000000000000000000000000000000000000000002b053000002b0532b053000002d0532f053000002f05330053000000000039053000003b05300000
0104000006050090500b050000001105000000000001a050000000000000000290500e04015040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000177101f72028730017002f7602f7602f760307002e7402e7402e7402f7502f7502f7502f7502f7502f750007000070000700007000070000500005000050000100001000000000000000000000000000
01140000290152901529015000001d0150000021015000001f0151d0151c0151a0151801500000000000000016015160151601500000160150000026015000002401500000000000000000000240152601528015
01140000290152901529015000001d0150000021015000001f0151d0151c0151a0151801500000000000000016015160151601500000160150000026015000002401500000000000000000000240152601528015
0010001c0c0000c0500d0500c0500c0000c0500b0000c040010000c0400c0000a05014050000001106010050000000e0500b0500d0500000015050000000c050000000e050110500d05000000000000000000000
0010001c187001875018750187500c000187500b0001874001000187400c0001675014750000001176010750000000e7500b7500d7500000009750000000c750000000e750117501975000000000000000000000
000800002176029730167303174019740397302e72000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002a7502e750327503a7503d7503d7003d7002a7002d700397003e700307003770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 08 42 43 44
00 08 09 43 44
00 08 42 0a 44
00 08 09 0a 44
00 08 09 0a 0b
00 08 09 0a 0b
02 08 09 0a 0b
00 00 00 00 00
03 06 42 43 44
00 00 00 00 00
01 11 13 43 44
02 11 12 13 44
00 00 00 00 00
01 0e 0f 43 44
02 0e 0f 10 44
00 19 42 43 44
03 19 18 43 44
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
04 00 00 00 00
00 00 00 00 00
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
