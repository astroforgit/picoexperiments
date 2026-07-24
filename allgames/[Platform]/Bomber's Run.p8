pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- bombers run pico edition
-- @melvinsa and @gruber_music
-- code/design: melvin samuel
-- sound/music: chris donnelly

--  some helper variables
-- -----------------------------

init_lvl=0                   -- start level, use to cheat
last_lvl=20
bnsscr={50,100,150,200,200,200,200,200} -- score bonuses
time_limit=60*12                        -- game time limit
time_start=0
level_start=0
nobombbon=true
nodeathbon=true
game_time=time_limit                 -- game time limit
last_time=game_time
enddelay=60*1.5
trondeath=20
tckr=0                               -- total ticks
go=0                                 -- game start variable
ttt=0 
ftt=0
stm_h=2
ttl=0
ttl_dth=0
ttl_bm=0
ttl_mn=0
ver=1.07

-- sfx
m_lvlend=0   -- level end
s_bbounce=2 -- bomb bounce 
s_bthrow=3  -- bomb throw 
s_jump=4    -- jump 
s_nostun=5  -- hit without stun 
s_stun=6    -- hit stun 
s_grab=7    -- grab 
s_throw=8   -- throw 
s_bounce=9  -- bounce 
s_tick=10    -- bonus spawn / clock tick 
s_die=11     -- death 
s_exp=12     -- explo / mon fireball 
s_bns=13     -- bonus 
s_dmg=14     -- red bat stmp damage 
s_hammer=15   -- hammer fall ( hammer bro enemy ) 
s_fball=16   -- fireball shot ( red bat ) 
s_monexp=17  -- monster hits sound after bomb 
s_pickup=18  -- bomb pickup sound 
s_bsshit=19  -- boss hit 
s_bssexp=20  -- boss explode 
s_start=21   -- game start 
s_shake=22   -- stomp monster quake 
s_fall=23    -- stomp fall sound 

-- music
m_set1=1  -- 0,1,2
m_set2=7  -- 3,4,5
m_set3=15 -- 6,7,8
m_set4=19 -- 9,10,11
m_set5=25 -- 12,13,14
m_set6=31 -- 15,16,17
m_set7=37 -- 18,19
m_set8=43 -- 20


--  init function 

function _init()
 logs={}
 ents={}
 t=0
  init_menu()
end

--  draw function 

function _draw()
 cls()
 
 -- draw current main draw
 if mdraw then mdraw() end
 
 -- fade
  draw_fade()
 
 -- draw log
  draw_log()
end

-- generic update function
function _update()
 
 t+=1
 upd_flash()

 if loop then
  loop() 
 end
 
 if nsfx then
  sfx(nsfx)
  nsfx=nil
 end

end


-- init main menu 
function init_menu()
 
 reload()            
 camera()
 x=0
 t=0
 go=0

 music(-1)
 mdraw=draw_menu
end

-- begin helper functions
--  update bg flasher

function upd_flash()
  ftt-=1
  if ftt<=0 then
   ftt=0
   flash_bg=nil
  end
end

--  initialize fade functions

function fadeto(nxt,rev)
 fade_rev=rev
 fade_nxt=nxt
 fade_n=0
end

--  log function

function log(str)
 add(logs,str)
 while #logs>20 do
  del(logs,logs[1])
 end
end

--  log draw function

function draw_log()
 
 --log 
 cursor(0,0)
 color(7) 
 for l in all(logs) do
  print(l)
 end 
 
end
--]]

--  fade draw function

function draw_fade() 

 if fade_n then

  fade_n+=1
  n=fade_rev and fade_n or 15-fade_n
  
  for i=0,15 do
   -- uses lut starting at (8,4) to (8,8)
   pal(i,sget(8+i,4+flr(n/4)),1) 
  end

  if fade_n==15 then
   fade_nxt()
   fade_n=nil
   if fade_rev then
    fadeto(pal,false)
   end
  end 

 end  

end

-- make entity

function mkentity(fr,x,y)
 fr=fr or -1
 x=x or 0
 y=y or 0
 
 e={
  fr=fr,x=x,y=y,t=0,size=8,
  frict=1.0,
  flp=1, lp=true, vis=true,
  raymod=0,ofy=0,dp=1,
  bncx=function(e) e.vx=0 end,
  bncy=function(e) e.vy=0 end,
  van=kill,
  tdust=0,
  xpsmk=false
 }
 still(e)
 add(ents,e)
 return e
end

--  null function / no function

nf=function() end

--  get/set map x,y sprite 

function lget(x,y)
 return mget((lvl%8)*16+x,flr(lvl/8)*16+y)
end

function lset(x,y,n)
 return mset((lvl%8)*16+x,flr(lvl/8)*16+y,n)
end

--  set something ablaze .. fx

function burn(e)
 p=mka(e.x+rand(3)-1,e.y+rand(3)-1,16,12,4,4,4,2)
 p.rmp=e.rmp
end

function smoke(e)
 p=mka(e.x+rand(3)-1,e.y+rand(3)-1,48,0,4,4,4,2)
 p.rmp=e.rmp
end

-- value updates ever md ticks

function mod(md,lp)
 return flr(t/md)%lp
end

--  add impulse to entity

function impulse(e,an,spd)
 e.vx=cos(an)*spd
 e.vy=sin(an)*spd
end

-- random number helper

function rand(n)
 return flr(rnd(n))
end

-- make a time object with timer 

function delay(t,f,l)
 e=mkentity(-1,0,0)
 e.life=t
 e.ondeath=f
 e.upd=l
end

-- rand pick obj and return it

function takeone(a)
 local p=a[rand(#a)+1]
 del(a,p)
 return p
end

-- helper func. to draw popup 

function popup(h,sc,x,y,adds,tmer)
 tmer=tmer or 25
 adds=adds or false

 if adds and h then
  h.score+=sc
 end
 
 e=mkentity(-1,x,y-4)
 e.vy=-0.25
 e.life=tmer
 e.dp=0
 local s=sc..""
 local sx = hcenter(s)

 e.draw=function(e,x,y)
  for i=0,1 do
   cl=1
   if i==1 then
    cl=t%4<2 and 10 or 9
   end
   print(s,hcenter(s,x)-i,y+2-i,cl)
  end
 end
 
end

function drawstats(show,oft)
  show=show or true
  oft=oft or 0

  fscore=""..heroes[1].score
  lvls=""..lvl
  while #lvls<2 do lvls="0"..lvls end
  while #fscore<5 do fscore="0"..fscore end
  --local oft=-15

  if lvl < 10 then
   print("level:0"..lvl.."/20",2,70+oft,6)
  else
   print("level:"..lvl.."/20",2,70+oft,6)
  end
  print("score:"..fscore,2,78+oft,6)

  print("deaths:"..ttl_dth,2,86+oft,6)
  print("bombs:"..ttl_bm,2,95+oft,6)
  print("lvl avr:"..timeformat(ttl/(lvl+1)),2,103+oft,6)
  if show then
   print("run time:"..timeformat(game_time).." ("..timeformat(time_limit-game_time) ..")",2,111+oft,6)
  end

end

--  menu: gameover function call

function gamecomplete()
 pal()
 t=0
 mdraw=function()
  local ofs = -15
  rectfill(0,0,127,127,0)
  --print("congrats!",48,62+ofs,7,1)
  local str=""
  if game_time >= 90 then 
  str="amazing run, well done!"
  end

  sspr(0,96,16,24, 52, 15)

  print("congrats!!",43,54+ofs,8,1)
  print("----------",43,62+ofs,8,1)

  am=5+sin(t%30/30)
  for i=1,#str do
   print( sub(str,i,i), 14+i*4, 10+sin((t+i)%20/20)*am, 8+i%8)
  end  

  bspd=3
  drawstats(true,ofs)

  
  if btn(5) then
   game_time=time_limit
   init_menu()
  end
 end
 rectfill(0,0,127,127,0)
end

--  menu: gameover function call

function gameover()
 pal()
 t=0
 mdraw=function()
 local ofs = -15
  rectfill(0,0,127,127,0)
  print("time's up!",43,54+ofs,8,1)
  print("----------",43,62+ofs,8,1)
  bspd=3
  drawstats(true,ofs)


  if btn(5) then
   game_time=time_limit
   init_menu()
  end
 end
 rectfill(0,0,127,127,0)
end

-- timer

function timeformat(secs)
 if (secs < 1) then
  return "00:00:00"
 end
 local mins = "00"
 local msec = "00"

 if (secs > 59) then
  mins = flr(secs / 60)
  if (mins < 10) then
   mins = "0"..mins
  end
  secs = secs % 60
  msec = secs % 100
 end
 secs=flr(secs)
 msec=flr(msec*100%100)
 
 if (secs < 10) then
  secs = "0"..secs
 end
 if (msec < 10) then
  msec = "0"..msec
 end

 return mins..":"..secs..":"..msec
end


--  title screen draw

function draw_menu()
 

 -- if start increment go
 if go>0 then go+=1 end
 
 gosq=0

 m = "@melvinsa"
 g = "@gruber_music"

 hcenter(m)
 print(m,hcenter(m),98,1)
 print(g,hcenter(g),106,1)

 sspr(16,96,80,32, 26, 30)
 
 -- blink start
 pr=t%24<16

 -- blink every frame if start
 if go>0 then pr=(t%2<1 and go<39) end
 
 -- draw start game
 if pr then
  tx="x to start"
  print(tx,hcenter(tx),121,7)
 end
 
 -- if button x is press start game
 if btn(5) and go==0 and t>5 and not fade_n then
  sfx(s_start)
  music(-1)
  go=1
 end 
 
 -- after delay go to game
 if go==64 then
  init_game()
 end
end

-- -----------------------------

function hcenter(s,pt)
 pt=pt or 64

return pt-flr((#s*4)/2)

end

--  init for game
-- -----------------------------

function init_game()
 
 fadeto(pal,nil)
 monsters={}
 bombs={}
 heroes={} 
 ents={}
 nodeathbon=true
 nobombbon=true

 game_time=time_limit
 last_time=game_time

 ttl_dth=0
 ttl_bm=0
 ttl_mn=0

 blid=0
 lvb=4
 bnum=0
 pickups=48
 lives=2000

 boss=nil
 boss2=nil

 -- shuffle artefacts
 a={}
 apool={}
 for i=0,21 do
  add(a,mget(i,15))
 end
 while #a>0 do
  add(apool,takeone(a))
 end 

 -- hero
 act=1                
 i=0
 
 h=mkentity(32,0,0)
 del(ents,h)
 h.act=i==0   
 h.score=0
 h.bombs=5
 h.hid=i
 h.powerbombs={}
 for i=0,5 do h["bomb"..i]=1 end
 add(heroes,h)
 
 time_start=time() 

 goto_level(init_lvl)
 init_level()
 mdraw=draw_lvl
 

end

-- -----------------------------
--  init the current level
-- -----------------------------

function init_level()
 clean=false
 lt=0
 
 -- spawn based on active flag
 for h in all(heroes) do
  if h.act then spawn_hero(h) end
 end

 -- items
 items={}
 it=apool[1]
 del(apool,it)
 add(items,rand(128)==0 and 127 or it)
 --
 loop=upd_lvl
end

--  go to level
-- -----------------------------

function goto_level(n)
 lvl=n
 level_start = time()

 if n < 3 then
  music(m_set1)
 elseif n < 6 then
  music(m_set2)
 elseif n < 9 then
  music(m_set3)
 elseif n < 12 then
  music(m_set4)
 elseif n < 15 then
  music(m_set5)
 elseif n < 18 then
  music(m_set6)
 elseif n < 20 then
  music(m_set7)
 else
  music(m_set8)
 end

 bop={}                       -- spawn points
 ggpos={}                     -- grownd

 -- loop through level 
 for x=0,14 do for y=0,13 do

  -- get the frame at x,y
  fr=lget(x,y)
  gfr=lget(x,(y+1)%14)
  px=x*8+4
  py=y*8+4

  -- get ground positions
  if not fget(fr,0) and not fget(fr,1)
     and (fget(gfr,0) or fget(gfr,1) ) then
   add(ggpos,{x=px,y=py})
  end  
  
  -- spawn players 
  if fr==32 or fr==33 then  
   h=heroes[fr-31]
   h.spx=px
   h.spy=py   
  -- if enemies
  elseif fr>=64 and fr<=100 then
   mkmonster(fr-64,px,py)   
  end  
  
  -- 0,14 is always a blank tile
  if fget(fr,4) then
   lset(x,y,lget(0,14) )
  end
  
  end 
 end

 if lvl==last_lvl then
  boss=mkboss(130,44,120,44)
  boss.flp=-boss.flp
  boss2=mkboss(0,44,8,44)
 end

end

function mkboss(x1,y1,x2,y2)

  local e=mkentity(110,x1,y1)
  e.dp=2
  e.lp=false 
  e.size=16
  e.hp=4
  e.obj=true
  e.stp=0
  e.dead=false
  add(monsters,e)
  e.bad=true
  e.hit=function() end
  e.xpl=function(from)
   if e.flash then return end
   sfx(s_bsshit)
   e.hp-=1
   e.flash=10
   if e.hp==0 then
    e.upd=nil
    e.twc=nil   


    local kl = function()
     e.upd=nil
     e.twc=nil  
     kill_boss(e)
    end

    delay(20,kl)
  
   end
  
  end

  tw(e,x2,y2,64,0,intro_boss)--64
  return e

end

function kill_boss(e)
 --
 if e.dead then return end

 kill(e)
 flash_bg=0
 tt=7
 shk=16
 
 -- pieces
 for i=0,3 do
  dx=i%2
  dy=flr(i/2)
  p=mkentity(110+dx+dy*16,e.x+dx*8-4,e.y+dy*8-4)
  p.vx=dx*2-1
  p.vy=dy*2-1
  p.life=80
  p.flp=e.flp
  p.blink=40
  p.frict=0.92
  p.lp=false
 end
 
 sfx(s_bssexp)
 
end

function intro_boss()
 
 boss.upd=function(bss)
  if bss.t>64+rnd(50) then
   bss.t=0
   bss.cfocus=16
  end

  if bss.cfocus==1 then
   if rnd(10) <= 2 and getnummon() < 4 then
    e2=mkb(flr(rnd(3)),bss) 
    e2.x=bss.x+bss.flp*16
    e2.y=bss.y
    an=sgda(heroes[1],bss)
    impulse(e2,an,1)
   else
    fball(bss)
    if bss.y == 44 then
    tw(bss,bss.x,22,64,0,nil)
    else
     tw(bss,bss.x,44,64,0,nil)
    end

   end
  end
 end

 boss2.upd=boss.upd

end


--  function to spawn a hiro
-- -----------------------------

function spawn_hero(h)
 add(ents,h)
 h.vis=true
 h.fr=32
 h.dead=false
 h.x=h.spx
 h.y=h.spy
 h.we=0.5
 h.frict=0.9
 h.upd=upd_hero
 h.phys=true
 h.lp=true     
 h.special=nil
 h.tdust=0

 lt=0

end

--  make a monster
-- -----------------------------

function mkmonster(mt,x,y)
 
 local e=mkentity(64+mt,x,y) 
 e.raymod=2
 add(monsters,e)
 e.phys=true
 e.obj=true
 e.bad=true
 e.dmg=0
 e.res=3
 e.mt=mt
 e.spd=0.5 
 e.tdust=0
 e.hit=hit
 e.shoot_cd=80
 e.stomp=true

 e.upd=upd_mon
 e.draw=function(e,x,y)
  if e.stun and not e.stunshk then
		 sspr(mod(2,4)*8,8,8,4,x,y-4)
  end
 end 
 
 e.xpl=function(from)
  sfx(s_monexp)
  shk=4
		local b=mkb(e.mt,e)
  xpl(b)
  kill(e)
  ttl_mn+=1
  return b
 end  
 init_mon(e)

 return e
end


--  init monsters
-- -----------------------------

function init_mon(e)

 e.bhv=crawl
 e.wfrmax=2
 e.shoot=shoot
 e.bncx=function(e)
  e.flp=-e.flp
 end  
 
 -- bat
 if e.mt==1 then  
  e.wfrmax=3
  e.bhv=nil
		setfly(e,0.7)
 end 
 
 -- ogre
 if e.mt==2 then
  e.test_shoot=function(h)
   return abs(h.y-e.y)<8 and face(e,h)
  end
 end 
  
 -- hammer bro
 if e.mt==3 then
  e.test_shoot=function(h)
   return dst(h,e)<48 and face(e,h) and not e.rmpo
  end
 end
 
 -- saws
 if e.mt==32 then
  e.turn=1
  e.spd=1
  e.wfrmax=1
  e.stomp=false 
 end 
 
 -- stompster
 if e.mt==36 then
  e.wfrmax=1
  e.spd=0
  e.stomp=false
  e.bhv=waiter
  e.test_shoot=function(h)
   return abs(h.x-e.x)<9 and abs(h.y-e.y)<48 and h.y >= e.y
  end  
  e.shoot=dash
 end 
 
 -- red bat
 if e.mt==5 then 
  e.res=6
		setfly(e,0.5)
 end  
 
  
end


--  count the number of mon left
-- -----------------------------

function getnummon()
 sum=0
 for m in all(monsters) do
  if not m.blk then sum+=1 end
 end
 for h in all(heroes) do if h.lift then sum+=1 end end
 return sum
end


--  set fly for entity bird,vamp
-- -----------------------------

function setfly(e,spd)
 e.spd=spd
 e.bhv=fly
 e.vx=e.flp*e.spd
 e.vy=-e.spd
 e.bncy=nf
end

-- flying behaviour
-- -----------------------------

function fly(e)
	advf(e)

 e.we=0
 e.vx=e.flp*e.spd

 if e.t>64+e.y and e.mt==5 then
  e.t=0
  e.cfocus=16
 end

 if e.cfocus==1 then
  fball(e)
 end
 
end

function fball(el)
  h=hcl(el)
  sfx(s_fball)  
  an=sgda(h,el)           
  smax=e.mad and 1 or 1
  for i=0,smax do
   ba=(i-smax/2)*0.025
   f1=frshot(113,el)  
   impulse(f1,an+ba,1.25)
   f1.raymod=3
   f1.upd=function(f1)
    f1.flh=t%4<2 and 1 or nil
    burn(f1)
    f1.turn=1
   end
   if ba==0 then    
    e.bvx=-f1.vx
    e.bvy=-f1.vy
   end   
  end
end

-- shoot at player
-- -----------------------------

function frshot(fr,e)
 local f=mkentity(fr,e.x,e.y)  
 f.bad=true
 f.shot=true
 f.bncx=function(b)
  kill(b)
 end
 f.lp=false
 return f
end



function haunt(e)
 advf(e)
 h=hcl(e)
 
 local dx=mdx(h.x-e.x,60)
 local dy=mdy(h.y-e.y,56)
 local an=atan2(dx,dy) 
 spd=e.spd*(1+cos(t/40)*0.5)
 impulse(e,an,spd)
 e.spd+=0.001
 e.shot=true
 e.flp = sgn(mdx(h.x-e.x,64))
 if getnummon()==1 or lt<time_limit then 
  vanish(e)
 end
 
end

-- face direction of player
-- -----------------------------

function face(e,h)
 return e.flp==sgn(h.x-e.x) or e.mad 
end

-- adcance frame
-- -----------------------------
function advf(e)
 e.fr=64+e.mt+mod(4,e.wfrmax)*16
end

-- update monster
-- -----------------------------

function upd_mon(e)

  -- heal
 if e.dmg>=e.res then
  e.stuncd-=1
  if e.stuncd <= 0 then
   if e.stun then
    e.vy-=2
    init_mon(e)
    gomad(e) 
   end
   e.dmg=0
  end 
 end
 
 -- stun
 e.stun=e.dmg>=e.res
 if e.stun then
  e.we=0.25
  e.stunshk = e.stuncd<20 and t%2==0
  return
 end

 -- bhv
 if e.bhv then 
  e.bhv(e)
 end
 
 -- saw
 if e.mt==32 then
  e.turn=e.flp
 end


 if e.ground and abs(e.vx) >0.05 and e.tdust + 10 < e.t then
  e.tdust = e.t
  dust(0,e)
 end
 
end


-- make mosnter angry
-- -----------------------------

function gomad(e)

 if e.mad or e.mt==36 or e.mt==32 then return end
 e.mad=true
 e.rmp=1  
end

function hmod(n,md)
 n+=md
 n=n%(md*2)
 n-=md
 return n
end

-- monster crawl behaviour
-- -----------------------------
function waiter(e)

  h=heroes[1]
  hdy=hmod(h.y-e.y,60)

  -- try shoot
  scd=e.bad and e.shoot_cd or 8
  if e.t>scd and e.test_shoot and rand(4)==0 then
   h=hcl(e)
   if e.test_shoot(h) then
    e.t=0
    e.shoot(e,h)
   end
  end

  advf(e)
end

-- monster crawl behaviour
-- -----------------------------
function crawl(e) 

 h=heroes[1]
 hdy=hmod(h.y-e.y,60)
 
 if e.ground then
  if e.fall then
   e.vy=0
   e.fall=false
   if e.mt==32 then
    h=hcl(e)
    if h then
     e.flp=sgn(h.x-e.x)
    end
    if not e.mad then
     e.flp=rand(2)*2-1
    end
   end   
  end
  

  fall=e.mt==32 or (e.mad and hdy>2) 

  --uturn= (not seek or hdy<2) and e.mt!=4
  
  if col(e,e.flp*8,1)==0 and not fall then
   e.flp=-e.flp
  end
  e.vx = e.flp*e.spd
  advf(e)

  -- try jump
  if seek and hdy<-2 and rand(2)==0 then
   px=flr(e.x/8)
   py=flr(e.y/8) 
   ok=false
   for i=1,2 do
    fr=lget(px,(py-i)%15)
    if fget(fr,1) then
     ok=true
    end
   end
   if ok then
    e.bhv=mon_jmp
    e.t=0
    e.vx=0
    e.fr=64+e.mt
   end  
  end 
  
  -- try shoot
  scd=e.bad and e.shoot_cd or 8
  if e.t>scd and e.test_shoot and rand(4)==0 then
   h=hcl(e)
   if e.test_shoot(h) then
    e.t=0
    e.shoot(e,h)
   end
  end
  
  else
   -- fall
   e.vx=0
   e.vy=2
   e.fall=true
  end 
end

-- shoot behaviour
-- -----------------------------

function shoot(e,h)
 e.trg=h
 e.flp=sgn(h.x-e.x)
 e.bhv=mon_fire 
 e.vx=0  
 e.fr=96+e.mt
end

-- dash behaviour
-- -----------------------------

function dash(e,h,rt)
 rt=rt or false
 
 if not rt then
  sfx(s_fall)
 end 

 e.phys=true
 local an=flr(sgda(h,e,true)*4+0.5)/4
 still(e) 
 e.cgh=36
 local f=function(sh)
  delay(24,function() 
   

   init_mon(e)
   if not rt then
     dash(e,h,true)
   end
   
   end
   )
  shk=8
  sfx(s_shake)
  e.bhv=nil
  e.fr=116
  still(e)
  e.bncy=nf
 end 

 local acc=0.2
 local spd=0
 e.bhv=function()
  spd+=acc

  if not rt then
   impulse(e,0.75,spd)
  else
   impulse(e,0.25,spd)
  end

  if not e.cgh then   
   spd*=0.85
   acc=0
			if spd<0.1 then
			  init_mon(e)
    if not rt then
     dash(e,h,true)
    end
			end
  end
 end
 e.bncx=f
 e.bncy=f 
end

-- get the closest hiro to e
-- -----------------------------

function hcl(e) 
 best=nil
 bdist=999
 for h in all(heroes) do
  dd=dst(h,e)
  if dd<bdist and h.act then
   best=h
   bdist=dd
  end
 end
 if not best then
  return heroes[1]
 end
 return best
end

-- distance from a to b
-- -----------------------------

function dst(a,b)
 local dx=a.x-b.x
 local dy=a.y-b.y
	return sqrt(dx*dx+dy*dy)
end

-- monster behaviour shoot
-- -----------------------------

function mon_fire(e)
 
 if e.t==12 then 
  
  e.fr=112+e.mt
  local b=frshot(68,e)
  --b.y+=1
  b.x+=e.flp
  b.turn=1 
  
  if e.mt==3 then
   e.rmpo={5,0}
   b.lp=false
   b.rmp=e.rmp
   b.fr=112  
   b.raymod=2
   an=sgda(e.trg,b)
   b.we=0.25
   b.frict=0.99999
   
   sfx(s_hammer)
   b.vx=e.flp*(0.5+1/2)
   b.vy=-rnd(2)-2

   b.ondeath=function()
    e.rmpo=nil 
   end
   b.upd=function(b)

    --if b.t%4==0 then
     --sfx(s_hammer)
    --end

    smoke(b)
    
    if e.dead then
     --b.frict=1.0
    else--if b.t%5 then
     --[[spd+=0.15
     an=sgda(e,b)
     impulse(b,an,spd) ]]

     --spd+=0.25
     --if spd > 1 then spd=1 end
     --an=sgda(heroes[1],b)

     --if spd < 3 then
     --impulse(b,an,spd) 
     --log("dist ".. an)
    --end 
     

     if b.t > 1 then
      e.rmpo=nil     
     end
     if b.t > 300 then
      --sfx(s_dmg)
      kill(b)
      e.rmpo=nil     
     end
     
    end

   end
  else
   b.vx=e.flp*2      
   b.phys=true  
   b.upd=function(b)
    burn(b)
   end
   sfx(s_fball)
  end
 end
 
 if e.t==20 then
  e.bhv=crawl
 end 
 
end

-- -----------------------------

function sgda(a,b,xonly,yonly)
 xonly=xonly or false
 yonly=yonly or false


 local dx=a.x-b.x
 local dy=a.y-b.y
 
 if xonly then dx = 0 end
 if yonly then dy = 0 end


 return atan2(dx,dy)
end

-- monster behaviour jump
-- -----------------------------

function mon_jmp(e)

 lim=e.mad and 6 or 32
 if e.t<lim then
  e.flp =(flr(e.t/8)%2)*2-1
 elseif e.we==0 then
  e.fr=80+e.mt
  e.vy=-3.6
  e.we=0.25
  e.bncy=function(e)
   still(e)
   e.bhv=crawl
  end
 end
end

-- do this on hit
-- -----------------------------

function hit(e,n,sd) 
 e.flh=7
 ftt=2
 if e.dmg then 

   e.dmg+=n
   if e.dmg>=e.res then
    stun(e,sd)
   else
    sfx(s_nostun)
   end

 end 
end

-- behaviour stun
-- -----------------------------

function stun(e,sd)
 sfx(s_stun)
 e.stuncd=sd
 e.vx=0 
 e.fr=64+e.mt
 e.we=0.25
 e.bncy=function(e) e.vy=0 end
end

-- hiro logic for update
-- -----------------------------

function upd_hero(h)
 
 -- walking
 h.vx=0

 function walk(n)
  h.flp=n
  h.vx=n*1.5
 end  
 
 if btn(0,h.hid) then walk(-1) end
 if btn(1,h.hid) then walk(1) end
 
 -- jumping / anim
 if h.ground then 
  if btnp(4,h.hid) then
   sfx(s_jump)
   h.vy=-7.5
   dust(1,h)
   if btn(3,h.hid) then
    h.vy=2
    h.cgh=1
   end
  end

  -- walk
  h.fr=32
  if t%8<4 and h.vx!=0 then 
   h.fr=33 
  end

 else
  if not btn(4,h.hid) then
   if h.vy <= 0 then
    h.vy*=0.5
   end
  end

  h.fr=33 
  if h.vy > 1 then
   h.fr=35
  end
  if h.vy < -1 then
   h.fr=34
  end  
 end

 -- autograb
 m=moncol(h)
 if m and m.stun and not h.lift then
  kill(m)
  h.lift=m
  sfx(s_grab)
 elseif m and m.y < h.y+stm_h and not m.stun then
    hit(m,4,160)
    h.vy=-7.5
 end

 -- head stomp

 -- shooting / grab / drop
	if btnp(5,h.hid) then
	 
	 if h.lift then	 
	  --if h.ground and btn(3,h.hid) then
	  -- drop(h)   
	  --else
	   launch(h)
	  --end
	 --elseif #bombs<h.bomb0+3 then
  else 
   
   -- reduce bomb count
   local bomb=false
   for e in all(ents) do
    if e.blid==blid then
     bomb=true
    end
   end

   local prebomb = h.bombs
   if not bomb then 
    h.bombs-=1 
    if h.bombs < 0 then h.bombs = 0 end
   end

   if prebomb == 0 and not bomb then
    prebomb=1
    lostime(5)
   end

   if bomb or prebomb > 0 then

    if btn(2) then
     shoot_bomb(h,3.25)
    elseif btn(3) then
     shoot_bomb(h,-3.25)
    else
     shoot_bomb(h,2.3)
    end
   
   end

  end
 end
 
 -- invincible 
 h.vis=not h.cinv or h.cinv%2==1   
 
end

-- drop any objects your are carrying
-- -----------------------------

function drop(h)
 e=h.lift
 h.lift=nil
 add(monsters,e)
 add(ents,e)
 e.x=h.x+h.flp*8
 e.y=h.y	   
end

function lostime(te)
 
 h=heroes[1]
 local e=mkentity(-1,95,220)
 e.vy=-0.15
 e.draw=function(e)  

  print("-"..timeformat(te) ,h.x-20,h.y-10,7+(t%2))
 end
 e.life=34
 time_start-=te

end

-- kill player
-- -----------------------------

function die(h)
 kill(h)
 ttl_dth+=1
 
 
 nodeathbon=false

 if h.lift then
  drop(h)
 end

 lostime(trondeath)

 sfx(s_die)
 e=mkentity(36,h.x,h.y)
 e.size=7
 e.we=1
 e.phys=true
 e.vy=-5
 e.flp=h.flp
 e.bncy=function(e) 
  e.vy*=-0.75 
  if e.t>20 then 
   e.we=0
   e.vy=0
  end
 end
 e.life=40
 e.blink=12   
 if lives>0 then
  lives-=1
  life_lost=30
  e.ondeath=function()
   spawn_hero(h)
   h.cinv=64
   if h.bombs < 5 then
    h.bombs=1
   end
  end
 else
  h.act=false
  act-=1 	
 end
 
 shk=6
 flash_bg=0
 ftt=3 

 dust(5,h)
 
end

function dust(c,en,xf,yf)
  xf=xf or rnd(6)-e.flp*6
  yf=yf or -1

  for i=0,c do
  --e=mkentity(74,h.x,h.y)
  e=mka(en.x,en.y+2,0,12,4,4,4,2+rand(4))
  impulse(e,(i+xf)/5,yf)
  e.frict=0.5+rnd(0.15)
  
  --e.blid=h.hid

  e.phys=true
  e.we=0.1
  --e.size=0.5
  
  e.bncy=function(e) e.vy*=-0.15 end
  e.bncx=function(e) e.vx*=-0.15 end
  end


end

-- player shoot bomb
-- -----------------------------

function shoot_bomb(h,yang)


 sfx(s_bthrow)
 
 nobombbon=false

 for e in all(ents) do
  if e.blid==blid then
   sfx(s_exp)
   shk=32
   kill(e)
   return
  end
 end
 
 local bb=mkentity(-1,h.x,h.y)
 bb.pow=pw
 bb.raymod=-2
 bb.vx=h.flp*(0.5+h.bomb2/2)
 bb.vy=-yang
 bb.we=0.25 
 bb.phys=true
 bb.size=3
 bb.life=h.bomb1*60
 bb.blid=blid
 ttl_bm+=1

 bb.bncx=function(bb) 
  sfx(s_bbounce)
 end
 bb.bncy=function(bb)
  bb.vy=max(bb.vy,-2.5)
  sfx(s_bbounce)
 end 
 
 bb.upd=function(bb)
  burn(bb)
  
  for e in all(ents) do
   if e.hit and ecol(e,bb) then
  
    bb.vx*=-1 
    bb.bncx(e) 

   end
  end
 end 

 bb.ondeath=function(bb)
 
  apply_effect(-1,bb)
 end
 add(bombs,bb)
end
 
-- spawn thing you are throwing
-- -----------------------------

function mkb(mt,from)
 local e=mkentity(64+mt,from.x,from.y-3)
 e.mt=mt
 e.obj=true
 e.phys=true
 e.proj=true
 e.vx=2
 e.lvb=lvb
 bnum=bnum+1
 lvb=lvb+1
 e.stomp=false

 if lvb >=6 then
  lvb=4
 end 

 e.ondeath=function()bnum=bnum-1 end
 e.bncx=function(e)
  sfx(s_bounce)
  if e.proj then
   xpl(e)
   
   local bf=pickups
   delay(4,function() mkbonus(bf,e) end)
   pickups+=1
   if pickups>=53 then pickups=48 end
   sfx(s_monexp)
   shk=4  
  end
 end 
 
 local lim=32+rnd(48)
 e.bncy=function(e)
  sfx(s_bounce)
  if e.ground then
   e.t+=2
   if e.t>lim and not e.proj then

    if rnd(2)==0 then
     b=mkbonus(e.lvb,e)
    end

    e.phys=false
    e.lp=false
   end
  end
 end  
 
 e.rot=0
 e.turn=1
 e.upd=function(e)  
  m=moncol(e)

  if e.t>40 then 
   e.vy=0
   b=mkmonster(e.mt,e.x,e.y)
   stun(b,50)
   b.stun=true
   b.dmg=b.res
   kill(e)
  elseif m and not e.cdt then
   b=mkbonus(e.lvb,e)
   m.xpl(e) 
   xpl(e)
  end

 end
 return e

end

-- explode a entity
-- -----------------------------

function xpl(e)

 if e.proj then
  if bnsscr[e.mt+1] then
  popup(heroes[1],bnsscr[e.mt+1],e.x,e.y,true)
  end

  e.t=0
  e.proj=false
  e.lp=true
  e.vy=-1
  e.upd=nil
  e.frict=0.97
  e.we=0.25  
  
  if e.xpsmk then
   e.xpsmk=true
  end

 end

end

-- launch whatever you are carrying
-- -----------------------------

function launch(h)
 nsfx=s_throw
 e=mkb(h.lift.mt,h) 
 e.vx=h.flp*2
 h.lift=nil
 if e.y < 12 then
  e.y=12
 end

end

-- spawn a bonus item
-- -----------------------------

function mkbonus(fr,p)
 sfx(s_bns)
 e=mkentity(fr,p.x,p.y)
 e.obj=true
 e.van=vanish 
 e.dp=0
 e.vy=-2
 e.we=0.25
 e.phys=true 
 
 e.upd=function(e)
  local h=herocol(e)  
  if h then

   if fget(fr,6) then
    nsfx=s_tick
    popup(h,50*(fr-47),h.x+4,h.y,true)
   else
    apply_effect(fr,h)
   end
   kill(e)
  end  
 end
 e.life=240
 e.blink=60
 
 return e 
end

-- apply effect of item pickup
-- -----------------------------

function apply_effect(fr,h)
  
 -- grenade
 if fr==-1 then
  sfx(s_exp)
  shk=12
  local e3=mkentity(-1,h.x,h.y)
  e3.phys=false
  e3.killmon=true
  e3.xpsmk=true
  e3.turn=1
  e3.size=16
  ftt=3
  flash_bg=7
  dust(10,e3,8,10)

   e3.draw=function(e3)
    burn(e3)
    frms=4
    if e3.t <= frms/4 then
     circfill(e3.x, e3.y, e3.size/2, 1)
    elseif e3.t <=frms/2 then
     circfill(e3.x, e3.y,e3.size/1.5, 7)
    else 
     circ(e3.x, e3.y, e3.size/1.5, 7)
    end

    if e3.t >= 10 then
     kill(e3)
    end
  end

  local f3=mkentity(-1,h.x,h.y)
  f3.phys=false
  f3.killmon=false
  f3.turn=1
  f3.size=24
  f3.stunmon=true
  
  f3.draw=function(f3)
    if f3.t >= 10 then
     kill(f3)
    end
  end


 end

 -- bomb pickup
 if fr==4 then
  sfx(s_pickup)
  h.bombs+=1
  popup(h,50,h.x+4,h.y,true)
 end
 
 
end

-- are a and b colliding?
-- -----------------------------

function ecol(a,b)
 dx=a.x-b.x
 dy=a.y-b.y
 if a.lp and b.lp then
  dx=mdx(a.x-b.x,60)
  dy=mdy(a.y-b.y,54)
 end
 dx=abs(dx)+a.raymod+b.raymod
 dy=abs(dy)+a.raymod+b.raymod
 local l=(a.size+b.size)/2
 return dx<l and dy<l
end

-- is e collidng with a monster?
-- -----------------------------

function moncol(e)
 for m in all(monsters) do
  if ecol(m,e) and m.hit then
		 return m
  end
 end
 return nil
end

-- is e collidng with a hiro?
-- -----------------------------

function herocol(e)
 for h in all(heroes) do
  if h.act and ecol(h,e) and not h.dead then
		 return h
  end
 end
 return nil
end


-- -----------------------------

function tw(e,tx,ty,n,twj,nxt)
 e.sx=e.x
 e.sy=e.y
 e.tx=tx
 e.ty=ty
 e.twc=0
 e.twj=twj
 e.spc=1/n
 if n<0 then
  local dx=tx-e.x
  local dy=ty-e.y
  local dd=sqrt(dx*dx+dy*dy)
  if twj then dd+=twj*1.4 end
  e.spc=-n/dd
 end
 e.twnxt=nxt
end

-- update the entity
-- -----------------------------

function upe(e)
 e.t+=1
 e.ox=e.x
 e.oy=e.y
 
 -- counters
 for v,n in pairs(e) do
  if sub(v,1,1)=="c" then
   n-=1
   if n<=0 then
    e[v]=nil
   else
    e[v]=n
   end
  end
 end

 if e.upd then e.upd(e) end
 if e.obj or e.lift then objs+=1 end
 if e.turn and t%2==0 and not e.stun then
  e.rot=e.rot or 0
  e.rot=(e.rot+e.turn)%4 
 end
 e.vy+=e.we
 e.vx*=e.frict
 e.vy*=e.frict

 --and not col(e)

 local c=e.mad and 2 or 1
 local vvx=e.vx*c
 if e.bhv!=fly then c=1 end
 local vvy=e.vy*c

 if e.bvx then
  vvx+=e.bvx
  vvy+=e.bvy
  e.bvx*=0.85
  e.bvy*=0.85
 end
 
 if e.xpsmk then
  smoke(e)
 end

 if e.cfocus then
  vvx=0
  vvy=0
 end

	if e.phys and e.x then
	 -- horizontal
	 e.x+=vvx
	 sx=sgn(vvx)	 
	 if col(e)==2 then	
   brkcount=0  
	  while col(e)==2 and brkcount < 10 do
    brkcount+=1
	   e.x-=sx	  
	  end
	  e.vx*=-1	
	  e.bncx(e) 
	 end 
	 
	 -- vertical
	 pcol=col(e)
	 e.y+=vvy
	 sy=sgn(vvy)

	 function hcol(e)
	  local n=col(e)
	  if n==1 and e.cgh then 
	   n=0 
	  end
	  return n==2 or (n==1 and sy>0 and pcol==0)
	 end	 
	 
  if hcol(e) then	
   brkcount=0  
	  while hcol(e) and brkcount < 10 do
    brkcount+=1
	   e.y-=sy
	  end

   majground(e)
			e.vy*=-1
			e.bncy(e) 
	 end

  -- ground test
  majground(e)
  
  if e.ground and abs(e.vx) >0.5 and e.tdust + 10 < e.t then

   e.tdust = e.t
   dust(1,e)
  end

	else
	 e.x+=vvx
	 e.y+=vvy
	end
	
	-- tween
 if e.twc then
  tx=e.twt and e.twt.x or e.tx
  ty=e.twt and e.twt.y or e.ty
  e.twc=min(e.twc+e.spc,1)
  c=0.5-cos(e.twc*0.5)*0.5
  e.x=e.sx+(tx-e.sx)*c
  e.y=e.sy+(ty-e.sy)*c
  if e.twj then
   e.y+=sin(c*0.5)*e.twj
  end	
  if e.twc==1 then
   e.twc=nil  
   if e.twnxt then e.twnxt() end
  end
 end
 -- life
 if e.life then
  e.life-=1
  if e.blink and e.life < e.blink then
   e.vis=t%4<2
  end
  if e.life<=0 then
   e.van(e)
  end
 end
 
 -- ba
 if e.bad and not e.stun then
  h=herocol(e)
  if h and h.y+stm_h < e.y and e.stomp then 
   h.vy=-12.5 
   hit(e,4,160) 
  end
  if h and not h.cinv then
   if e.shot then kill(e) end
   
   if h.special==1 then
    if e.xpl then 
     e.xpl()
    end
   elseif h.y+stm_h >= e.y or not e.stomp then
    die(h)   
   end

  end
 end 

 
 if e.killmon then
  for m in all(monsters) do
   if ecol(m,e) then
   
    m.xpsmk=e.xpsmk
    m.xpl()
   
   end
  end
 end

 -- stunmon
 if e.stunmon then
  for m in all(monsters) do
   if ecol(m,e) and not m.stun then
    if not e == boss and not e == boss2 then 
     hit(m,4,160)   
     popup(h,"stun",m.x,m.y)
    end
   end
  end
 end
 
	-- mod
	if e.lp then
	 e.x=mdx(e.x)
	 e.y=mdy(e.y)
	else 
	 if out(e) and not e.ores then	  
	  kill(e)
	 end
	end
	
	
end

-- default vanish function
-- -----------------------------

function vanish(e)
 mka(e.x,e.y,32,8,8,8,3,4)
 kill(e)
end

-- grounded check 
-- -----------------------------

function majground(e)
 e.ground=col(e,0,1)>0 and col(e,0,0)==0
end

-- -----------------------------

function out(e)
 return e.x<-4 or e.y<-4 or e.x>132 or e.y>132
end

-- generic entity kill function
-- -----------------------------

function kill(e)
 e.dead=true
 del(ents,e)
 del(bombs,e)
 del(monsters,e)
 if e.ondeath then 
  e.ondeath(e) 
 end
end

-- -----------------------------

function mdx(n,k)
 k=k or 0
 n+=k
 return (n%120)-k
end
function mdy(n,k)
 k=k or 0
 n+=k
 return (n%112)-k
end

-- check collision dx dy direction
-- -----------------------------

function col(e,dx,dy)
 dx=dx or 0
 dy=dy or 0
	local x=mdx(e.x+dx-e.size/2)
	local y=mdy(e.y+dy-e.size/2)
	local ex=mdx(x+e.size-1)
	local ey=mdy(y+e.size-1)
 a={x,y,ex,y,ex,ey,x,ey}
 
 n=0
 for i=0,3 do
  x=a[i*2+1]/8
  y=a[i*2+2]/8
  local fr=lget(flr(x),flr(y))
  if n==0 and fget(fr,1) then
   n=1
  end
  if fget(fr,0) or fget(fr,4) then 
   return 2
  end  
 end 
 return n
 
end

-- draw and entity e
-- -----------------------------

function dre(e)
 if not e.vis or e.dp!=dp then return end
	fr=e.fr
	x=e.x-e.size/2
	y=e.y+e.ofy-e.size/2
	
	
	-- frame flag
	
 if fget(fr,0) then
	 y-=1
	end	


	if fget(fr,3) and e.t%4>2 then
	 fr+=1
		if fget(fr,2) then
		 kill(e)
		 return
		end	
		if fget(fr,1) then
			while not fget(fr-1,5) do
			 fr-=1
			end
		end	
	end
	e.fr=fr
	
	
 -- remap
	if e.rmp then
	 for i=0,15 do

    -- sget get from sprite loc x, y	  
   pal(i,sget(8+i,e.rmp))
	 
  end
	end

	if e.rmpo then
	 pal(e.rmpo[1],e.rmpo[2])
	end
	
	-- flh
	if e.flh then
	 for i=0,15 do
	  pal(i,e.flh)
  end
  if ftt<=0 then 
   e.flh=nil
  end
	end
	
	if e.flash then
	 e.flash-=1
	 for i=0,15 do
	  pal(i,8+rand(8))
  end
	 if e.flash==0 then
	  e.flash=nil
	 end
	end
	
	if e.stunshk then x+=1 end

	-- draw
	function dr(x,y) 
	 if e.lift then
   spr(64+e.lift.mt,x,y-6,1,1,e.flp==-1,-1)	
 	end
  
 

 	if e.rot then
   for gx=0,7 do for gy=0,7 do
	   px=flr(fr%16)*8
	   py=flr(fr/16)*8	 

	   if px+gx > 0 and py+gy > 0 then
     p=sget(px+gx,py+gy)
     if p>0 then
 	    dx=gx
 	    dy=gy	 
      for i=1,e.rot do
       dx,dy=7-dy,dx
      end
      pset(x+dx,y+dy,p)
     end
    end

	  end	end
 	else
	  spr(fr,x,y,e.size/8,e.size/8,e.flp==-1)
	 end
	 if e.draw then e.draw(e,x,y) end
	end
 dr(x,y) 
 if e.lp then
  if x<8 then dr(x+120,y) end
  if x>120-e.size then dr(x-120,y) end
  if y<8 then dr(x,y+112) end
  if y>112-e.size then dr(x,y-112) end


 end
 
 pal()

 -- draw mad !
 if e.mad and (t%4 == 0 or t%4 == 1) then
   spr(23,x,y-9,1,1,e.flp==-1,false) 
 end
 
end


-- update level
-- -----------------------------

function upd_lvl()
 -- ents
 if bnum==0 then lvb=4 end
	objs=0
 foreach(ents,upe)
 
 -- check gameover
 if act==0 or game_time<=0 then
  act=-1

  function f()
   loop=nil
   fadeto(gameover,true)
  end  
  delay(40,f) 
 end
 
 if objs==0 and not clean then
  if lvl+1 > last_lvl then
   function f()
    loop=nil
    fadeto(gamecomplete,true)
   end  
   delay(20,f) 
  else
   finish_lvl()
  end
 end

 -- timer
 if not clean then
  run_timer() 
 end



end

-- make entity stop moving
-- -----------------------------

function still(e)
 e.we=0
 e.vy=0
 e.vx=0
end

-- called when level is done
-- -----------------------------

function finish_lvl()

 clean=true
 music(m_lvlend)
 local kn=0
 for h in all(heroes) do
  if h.act then 

   h.t=0
   still(h)
   h.lp=false 
   
   local px=h.x
   local py=h.y
    
   h.upd=function()
     local offv= -20;
     if kn == 0 then
     local tx1 = "stage "..(lvl+1).." cleared!"
     local tx2 = "time: "..timeformat(time()-level_start).." sec"
     
     local cntr = 68
     popup(h,tx1,cntr,66+offv,false,enddelay)
     popup(h,tx2,cntr,76+offv,false,enddelay)
     ttl=ttl+time()-level_start
     extra=-10
     if nobombbon then
      local tx3 = "no bomb bonus:+"..20*(lvl+1)
      popup(h,tx3,cntr,86+offv,false,enddelay)
      h.score+=20*(lvl+1)
      extra=0
     end

     if nodeathbon then
      local tx4 = "no death bonus:+"..50*(lvl+1)
      popup(h,tx4,cntr,96+extra+offv,false,enddelay)
      h.score+=50*(lvl+1)
     end

     end

     if kn > enddelay then
      leave()
     end
     
     kn+=1
   end
   
  end
 end
end

-- clear ents go to next level
-- -----------------------------

function leave()
 ents={}
 monsters={}
 nxl=0
 nobombbon=true
 nodeathbon=true
 loop=nil
 goto_level(lvl+1) -- + 1

end

function spop(h,spd)
 return mka(h.x+rnd(8)-4,h.y+rnd(8)-4,40,5,3,3,5,spd)
end

--  make animated object
-- -----------------------------

function mka(x,y,dx,dy,dw,dh,fmax,spd)
 local e=mkentity(-1,x,y)
 e.lp=false
 e.size=dw
 e.draw=function(e,x,y)
  f=flr(e.t/spd)
  if f>=fmax then 
   kill(e) 
  else
   sspr(dx+dw*f,dy,dw,dh,x,y)
  end
 end
	return e
end

-- spawn item
-- -----------------------------

function spawn_item(it)
 --log("spawned :" .. it)
 p=takeone(bop)
 if p==nil then return end
 b=mkbonus(it,p)
 b.life=320
end

-- level timer function
-- -----------------------------

function run_timer()
 lt+=1
 game_time = time_limit + time_start + 3*lvl - time() 

 if game_time < 20 and last_time > flr(game_time) then 
 last_time=flr(game_time)
 sfx(s_tick)
 end

 h=heroes[1]  
 if getnummon()==0 and not h.lift then return end
  
  if #items>0 and rand(flr((time_limit-lt)/2))==0 then 
  spawn_item(takeone(items))
 end
 

end


-- draw a lvl tile map at y location 
-- -----------------------------

function drmap(lvl,dy)
 local bx=flr(lvl%8)*16
 local by=flr(lvl/8)*16

 map(bx,by,0,dy,15,14) 
 map(bx,by,120,dy,1,14)
 map(bx,by,0,112+dy,15,1)
 map(bx,by,120,112+dy,1,1)
end


-- draw a lvl
-- -----------------------------
function draw_lvl()

 -- shake
 ddx=0
 if shk then
  shk=-shk
  shk*=0.75
  if abs(shk)<1 then
   shk=nil
   ddx=0
  else 
   ddx=shk
  end
  
 end 
 camera(ddx,-8)
 
 -- flash the bg
 if flash_bg then  
  -- uses the first 3 luts for flashing bg
  rectfill(0,0,128,120,sget(ftt+flash_bg-1,flash_bg))
 end
 
 if nxl then
    nxl=nil
    fadeto(init_level,false)
 else
  drmap(lvl,0)

  for i=0,2 do
   dp=i
    foreach(ents,dre)
  end

 end

 -- inter
 camera(0,0)
 rectfill(0,0,127,7,0)
 
 -- score
 h=heroes[1]  
 sc=h.score..""
 while #sc<5 do sc="0"..sc end
 print(sc,108,1,7)
 
 -- bombs
 bc=h.bombs..""
 while #bc<2 do bc="0"..bc end
 print(bc,7,1,7)
 
 sspr(24,0,5,5,1,1)

 -- draw timer
 tc=timeformat(game_time)
 if game_time < 20 and t%2 == 0 then
  print(tc,47,1,8)
 else
  print(tc,47,1,7)
 end

 tckr+=1

end
__gfx__
000000000123456789abcdef915500009000000000040ab000600660060000000000100077777777dddddddd7777777711111111011d1000000100002eeeee82
00000000022222ef8efee8ef1a5550000a15d5000004300006766676666006000000c10066666666d1dd111d711c1cc711111111001d100000010000e7799982
000000000000000000000000555550000116dd5000bbb30007776766067600600000000067766776dddddddd71c1cc7c11111111001d100000101000e7999881
000000000000000000000000155510005d676dd000bab3000666066000600000cc11000056655665dddddd1d7c1cc7c111111111001d100000010000e9998821
00000000001151d62493d2ae01110000ddd6ddd00bbabb30bbbbbbbbbbbbbbbbccc10cc115511551ddddd1dd71cc7cc111111111001d10000001000089988221
000000000000105d1141515d000000005ddddd500babbb30bbbbbbbbbbbbbbbbccc10cc1d11dd11dd11ddddd1711111111111111001d10000010100089882221
0000000000000015002010150000000015ddd51003bbb330bbbbbbbbbbbbbbbb0c100011dddddddddddddddd0000000011111111001d10000001000088822221
000000000000000100100001000000000111110000333300bbbbbbbbbbbbbbbb00000000d1ddd11d1d1dd11d0000000011111111001d11000001000021111110
000000000000000000000000000020000000000000000000000000000000000000000000d6000000000000000000006d1000000000000000000110007666666d
0a000020020000a000200a00000a000000000000700000707007007000000000000000001d60000000000000000006d11100000000111100033110006ddddddd
aaa0000000000aaa0000aaa000aaa000000000000700070000000000000000000000000001d600000000000000006d10111000000010000003300330d1111111
0a000000000000a000000a00000a00000070700000000000000000000009a00000abbb00001d6000000000000006d100111100000010010000000331d11dd11d
000000000000000000800010010000000007000000000000700000700009a0000a3333100001d60000000000006d10001111100000100100110110117666666d
0770000000000000089802821220010000707000000000000000000000099000b313313100001d600000000006d100001111110000000100113310001ddddddd
777707700070000009a918980282002000000000070007000000000000000000b3133131000001dddddddddddd10000011111110001111000333003011111111
077007700070007008980282002000000000000070000070700700700009a000b333333100000011111111111100000011111111000000000000000000000000
000000070000000000c677700000007000000000a777777a0aaaaa90dddddddd00000000000000004222242200001000000000010000000044444444bbbbbbbb
00c6777000c6777700c6d7d700c6777000000000a999999aa4777a42dddddd6d00000000000000004222222200002100000000110d0111004222424433333333
00c6d7d000c6d7d00cc6d7d000c6d7d00000000724444444a7444442dd66667d000000000000000044222242000000000000011101000010444444443bb33bb3
0cc6d7d00cc6d7d00c6677700cc6d7d00006777012222221a7444242dd66667d0000000000000000422222222211000000001111010000104444444413311331
0c6677700c6677700c6667600c66777000c6d7d001111111a7444242dd66667d000c000000000000422242222221022100011111010000104444244421122112
0c6667600c666760ccc9a0000c6667600cc6d7d000000000aa422042dd66667d00cac00000000000442222222221022100111111010000104224422442244224
00c9a000ccc9a00000000000ccc9a0000c6677700000000094444422d677776d000c000000b00000422222920210001101111111001110104444444444444444
002020000000000000000000000000001c9667600000000002222220dddddddd000b000000b0b000422222220000000011111111000000002424422444244224
00040ab0000008800b000000004a2400000000002eeeee8202222240bbbbbbbbbabbbbbb00000000499999997666666622222424000000006777777629999999
00043000000b8788b0aa99000004a92000000000e7799922247aaa4233111133333333330000000094444444611dd11d222222240000000076dddd6d12222224
00bbb30003b0288203399990004aa492b828088be72222212744444211444411333ab33300a00000944444446666667624222244000000007d66666d12111124
00bab3003003022093ba999404aa94a97888882be92222112a4442424444444413b11b310aea000094422444dddddddd22222224000000007d66667d12222224
0bbabb3000088000a7a9a9949a794aa97828888b892221212a444042111111112112211200a00000222222221111111122224224000000007d66667d11111111
0babbb30008788009a7a999449447a943b8828b3882212112a420042000000004224422400b00000942492940000000024222224000110007d66667d00000000
03bbb3300028820009a999402a77a94013bbbb31822121114444442200000000444224440bb000b044244244000000002222229401111110766777dd00000000
00333300000220000054440002994400013333100111111002222220000000004444444400b0b0b0222222220000000022222224111111116ddddddd00000000
013333100000000000000000000000000000000000200020bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
13bbbb3100000000007006000011ddd00000000008200028bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3bbbbbb300200200007777fe001577700000000082820282bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3bbbb7b322a22a220867177f0cd11ddd0000000028262628bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3bb3b3b3a2aaa72a086677760cd21ddd0000000002821282bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3bb1b1b39aa2a2a9081666600c1577700000000000281820bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3b7bbbb32971919200211000011567650000000000021200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
13bbbb310229292000909000009090050000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000bbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0133331000200200077006000011ddd0bbbbbbbb00200020bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
13bbbb3102a22a20007777fe00157770bbbbbbbb02820282bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3bbbbbb34aaaa7a20867177f0cd11dddbbbbbbbb02268622bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3bbbb7b3aaa2a2aa086677760cd21dddbbbbbbbb08282828bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3bb3b3b3a271912a081666600c157770bbbbbbbb02281822bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3b71b1b3a229292a9221190091156765bbbbbbbb08221228bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
13bbbb31920000290000000000000005bbbbbbbb00800080bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0011110000000000000000000000000001d11d1000200020bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0066dd6666666600
011812100020020077006000011ddd001dddd55108200028bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb061d66dddddddd60
121dd11102a22a2007777fe001577700dddddd5d82820282bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb65d61166666621d6
01d17d812aaaa7a2867177f0cd11ddd51d7dd75128262628bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1511812d666666d6
18d71d112aa2a2a286677760c121ddd0151dd15102821282bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5116166655555561
111dd121a271912a81622600c1577750d577775d00281820bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1111611111151151
012181109229292912188000115676001587885100021200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1156122222212210
0011110020000002009090000909000001d11d0000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1561220001201210
0000000000000000000000000000000001d11d10bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1561800000800810
0000000000000000077006000011ddd01dddd551bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5619820000000000
00ddd00000000000007777fe00157770dddddd5dbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1619982000000000
00d5d000000220000867177f0cd11ddd1ddddd51bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1161998200000000
00ddd00000022000086777770cd21ddd15dddd51bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1156ddd111000000
0000000000000000081622600c157770d51dd150bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1511655dd5500000
0000000000000000002188000015676515222250bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1155166666600000
0000000000000000009090000909005001d11d10bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1511111111000000
838383838383838383838383e1e1e183838383838383838383838383838383836262626262626262626200000000006262626262626262626262626262626262
62626262626262626262626262626262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2e15400e1000054e1e1e100000000e2e1e100e000e0e1e1e2e2e1e1d000e1e16200000000000000000000000000006262000046000000000000000046000062
62000000000000000000000000000062000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c30000000000000000e10000000000c3000000e000e000e1a2c3e100d03400e1620000000000000000000000000000626200000034d200000000d23400000062
62d2d200000000000000000000d2d262000000000000000000000000000000000000000000000000acac00000000000000000000000000000000000000000000
c300060000e1e100000000003492e1c3e10093e081e092e1a2c38200d092920062d104005400d104d1d1000054d1d10062000000626252525252626200000062
62d2000000000000000000000000d26200000000000000000000000000000000ac000000000000ac00000000ac0000ac00000000000000000000000000000000
c37373f300000000000000f3737373e28373737373737373f3f3737383838383636262620000525252520000d1d162636200000000d0000000d0000000000062
62000000000000f1f10000000000006200000000000000000000000000000000acac0000000000ac00000000acac00ac00000000000000000000000000000000
c3e100d0000000e1000000d0000000a2c3e1e1000000000000d000e100e1e1e26362d1d10000e00000e00000d16263636200000000d0020000d0000000000062
6200000000000000000000000000006200000000000000000000000000000000acac0000000000000000000000ac00ac00000000000000000000000000000000
c30000d09281e1e1e19392d09292e1a2c3e100009300001400d000000000e1a262d1d1d10000e00000e000d16263636362000000525252525252525200000062
6200000000000000000000000000006200000000000000000000000000000000ac000000000000000000ac0000ac00ac00000000000000000000000000000000
c300e1838383838383838383838383e2c392340083000000e1830006922400a262d1d1d1d100e00000e062626363636362d20000d000d1d1d1d100d00000d262
62d2d2d2d2f1f1d2d2f1f1d2d2d2d26200000000000000000000000000000000ac0000000000000000000000000000ac00000000000000000000000000000000
c30000e1e1e1e100e1d00000e1e1e1e2c3737373f3e1000000f37373737373a262d1d1d1d100e00000e062636363636362d2d200d0d2d1d1d1d1d2d000d2d262
6200000000e000000000e00000000062000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2e192938200040082d0000000e1e1a2c3e1e100009200820000d00000e1e1a262d1d1d1d1d1d10000e000626263636363525262525252525252525262525263
6200000000e000c2c100e000000000620000000000000000000000000000000000ac0000000000ac000000000000000000000000000000000000000000000000
e283838383838383838381000000e1a2c3000000e1f373f3e193d000008100a262d1d1d1d1d1d1d1d1e0d1d10462636362d2000000000000000000000000d262
6200000000e000f1f100e000000000620000000000000000000000000000000000ac000000000000ac0000000000000000000000000000000000000000000000
e2e1e1000000000000e173e1000000a2c300000000e1e1e100837373737373a262d1d1d1d1d1d1d1d1e062626262626362005400000000240000000000540062
6200000000e000000000e0000000006200000000000000000000000000000000acac0000000000acacac00000000000000000000000000000000000000000000
c3e10000000000000000d000000000e2c30000000000000000e2e1000000e1a2636252525262d1d1d1d1e0d1d1d1d16263525200005252525252000000525263
62d2000000e000c2c100e0000000d26200000000000000000000000000000000acac00000000acacacac000000acacac00000000000000000000000000000000
c3000200818200928100d0929293e1e2c3e1930200810093e1e2e18254e1e1a2636302000062d1d1d104e0d1d1d1d16262d1d1d1d1d1d1d1d1d1d1d1d1d1d162
62d2d20200e0c26262c1e00000d2d26200000000000000000000000000000000acacac0000acacacacacacac00acacac00000000000000000000000000320000
0083838383838383838383838300000000838383838383838383838383838383d162626262636262626262d1d1d1d16200626262626262626262626262626262
00626262626262636362626262626262000000000000000000000000000000000000000000000000000000acacac000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006200000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000055555555d0000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0005d666666765d000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
005667777776dd5000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00d67777776dc00000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00d60077006dc00000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00d60077006dc00000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00d60077006dc01100000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00d60077006dc15100000000000000000000000000000000000000000000000000000000000000000111000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00d67777776dc15500000000000000000000000000000000000000000000000000000000000000000161000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00d66777076dc1d501111111111111111111111111111111111111111111111111111111111111111161111111111110bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
001d660066dc1d5101766666666d1766666666d1766666666d1766666666d1766666666d1766666666d1766666666d10bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0001dddddd01d5100166dddddd6d166dddddd6d166d666dd6d166dddddd6d166dddddddd166dddddd6d166dddddddd10bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0001110000155100016611111d6d16610000d6d1661d6d1d6d16611111d6d1661111111116611111d6d1661111111100bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
001d011111c010000166666666d116610000d6d16611d11d6d166666666d116666611111166666666d11666666666d10bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
01dd0ccccc5100000166dddddd6d16610000d6d16610101d6d166dddddd6d166ddd11111166dddddd6d1dddddddd6d10bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
01dd01c99c100000016611111d6d16611111d6d16610001d6d16611111d6d1661111111116611111d6d1111111116d10bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
001d101a9010000001666666666d1666666666d16610001d6d1666666666d1666666666d16610000d6d1666666666d10bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00010d101d10000001dddddddddd1dddddddddd1dd10001ddd1dddddddddd1dddddddddd1dd10000ddd1dddddddddd10bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00014d101d41000001111111111111111111111111100011111111111111111111111111111100001111111111111110bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000199411499100000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
001974411447910000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
001111111111110000000000000000000000000111111111111111000011111111111111100000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000000000000000000000000000000000000001766666666d1761000016d1766666666d100000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb00000000000000000000000166dddddd6d1661000016d166dddddd6d100000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb0000000000000000000000016611111d6d1661000016d16611111d6d100008000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb00000000000000000000000166666666d11661000016d16610000d6d100097600000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb00000000000000000000000166dddddd6d1661000016d16610000d6d100a777e0000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb0000000000000000000000016611111d6d1661111116d16610000d6d1000b7d00000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb0000000000000000000000016610000d6d1666666666d16610000d6d10000c000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb000000000000000000000001dd10000ddd1dddddddddd1dd10000ddd100000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb00000000000000000000000111100001111111111111111110000111100000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
__gff__
0000000004040404040101020404040100000000080808080404040404040402141111000402010104040100040401014040404040010102010401020104010210111010001000000100000000000000000001010000000100000002000000001000000010000001000101010102020002010000000000000000000001000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0f000000000f0f0f0f0f0f0f0f0f0f0f0f0f2b2b0f0f0f0f0f0f0f0f0000000000000f00000e000e00000f2f2f2f2f2f2f2f2f2f2f2f2f0000002f2f2f2f2e2e2f2f2f2f2f2f2e2e2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3a3a3a3a3a3a0c0c0c0c3a3a3a3a3a3a000000002b3a3a3a3a3a3a2b00000000
0f1b0000000e000000000e000000190f0f0e00000e0000000000000e00000e0f0f2d00000000000f00000e000e00000f1e1e000000000e00000e000000001e1e2e2e2e64001e1e1e1e1e1e00642e2e2e2e1e1e1e000000006400001e1e00642e2e2b2b000000400000400000002b2b2e00000000000d2b00002b0d000000002b
0f000000000e1f1f1f1f0e000000000f0f0e00000e0000000000000e00000e0f0f1f1f000000000f00000e000e002b0f1e1e1e0000000e00000e00400000001e2e1e1e0000001e1e1e1e0000001e1e2e2e1e410000000000000000000000002e3c2b00003a3a3a3a3a3a3a3a2b2b2b2a00003f3f000d000000000d003f3f0000
0f2b0000000e000e0e000e0000002b0f000e00000e0000000000000e00000e000f1b000000402d0f2b000e000e002b0f1e00000000000e00000e2f2f2f2f001e2e1e0000000000000000000000001e2e2e1e000000000000000000000000002e3c0000002b0d640000640d2b00002b2a00000d00003a004300003a00000d2b00
0f2b0000400e000e0e000e4000002b0f000e00000e4000000000400e00000e000f000000001f1f0f2b000e000e00000f0000000000000e00000e0000000000002e00000000000000400000000000002e2e00000000000000000000000000002e3c600000000d000000000d000000602a00000d00003f3a3a3a3a3f00000d0000
0f0f001f1f1f000e0e001f1f1f000f0f0f1f1f1f1f1f000000001f1f1f1f1f0f0f0000000000190f00000e400e00000f0000000000000e00000e0000000000000000000000003f3f3f3f000000000000000000000000000000000000000000002e3a3a3d3d0d000000000d3d3d3a3a2e00000d400000002b2b000000400d0000
0f00000e0000000e0e0000000e00000f0f1b000e000e000000000e000e00190f0f1f1f000000410f002d0f0f0f2d000f001e420000400e00000e4000000000000000420000000e00000e0000420000000000000000000000001e0040001e00002e3f3f3f3f0d000000000d3f3f3f3f2e3f3f3f3f00000000000000003f3f3f3f
0f00400e0000000e0e0000000e40000f0f00000e000e000040000e000e00000f0d0000000000000f00002d0f2d00000d2f2f2f2f2f2f0e00000e2f2f2f2f2f2f2f2f2f2f2f2f0e00000e2f2f2f2f2f2f2f2f2f2f1e1e2f2f2f2f2f2f2f2f2f2e3c002b00000d000000000d000000002a2b2b000d00000000000000000d000000
0f001f1f1f00001f1f00001f1f1f000f0f00000e000e0f0f0f0f0e000e00000f0d0000002b1f1f0f0000000d0000000d2e1e1e0000003f3f3f3f000000001e2e1e1e000000643f3f3f3f640000001e1e2e1e1e003f3f000000000000001e1e2e3c000000000d000000000d000000002a2b00420d2b0000000000002b0d420000
0f0000000d0000000000000d0000000f0f2d000e000f0d00000d0f000e002d0f0d200000002b190f0000000d0000000d2e1e000000000000000000000000002e1e00000000000e00000e00000000001e2e1e0000000000000000000000001e2e3c2b00003a3a3a41413a3a3a00002b2a00003f3f3f3f000000003f3f3f3f0000
0e0000000d0000000000000d0000000e0f2d200e00000d00000d00000e002d0f0f1f1f000000000f0000000d0000000f2e00400000000000000000000042002e0000000000000e40000e0000000000002e0000001e000000000000000040002e3c0000000000003d3d0000000000002a00004200000000000000000000420000
0e00001f1f1f000000001f1f1f00000e0f1f1f1f00000d00000d00001f1f1f0f0f1b002b2b00000f2b00000d00002b0f2e2f2f2f2f2f3f3f3f3f2f2f2f2f2f2e0000000000003f3f3f3f0000000000002e3f3f3f3f0000000000003f3f3f3f2e2e3f3f3f002c0c0c0c0c1c003f3f3f2e002b3a3a2b00003a3a00002b3a3a2b00
0e0000000d191a1a1a1a1b0d0000000e0f1b000000000d00000d00000000190f0f00000000002d0f2b402d0d2d402b0f2e1e000000000000000000000000002e000000000000000000000000000000002e00000000000000000000000000002e3c00003d2c0c0c0c0c0c0c1c3d00002a00002b2b0000000d0d0000002b2b0000
0f2d20000d0000000000000d00002d0f0f2d00402b000d2b2b0d2b0040002d0f0f2d001f1f002d0f1f1f1f1f1f1f1f0f2e000000000020000000000000001e2e00201e2f2f1e000000001e2f2f1e00002e200000000000000000000000401e2e3c202c0c0c0c0c0c0c0c0c0c0c1c002a000000000020000d0d0000000000002b
000f0f0f0f0f000000000f0f0f0f0f0f000f0f0f0f0f0f2b2b0f0f0f0f0f0f0f000000000000000f000000000000000f002f2f2f2f2f2f2f2f2f2f2f00002f2e002f2f2e2e2f2f2f2f2f2f2e2e2f2f2f002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f003a3a3a3a3a000000003a3a3a3a3a3a0000003a3a3a3a3a3a3a3a3a3a000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0d0000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e3e3e3e3e2727272727273e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e2d3e3e3e3e2d3e3e2d3e3e3e3e2d3e0a08080909090909090909090909090a090909090909090909090909090909090800000000000008080000000000000038383838383838000038383838383838
3c2b2b000d2b000000002b0d002b2b2a3e2d00002d3e272727273e2d00002d3e000000000000000000000000000000003e1a1a1a1a1b00000000191a1a1a1a3e0a08000000080808080808000800080a08080064080000080808000064000008000000000000000d0d000000000000082e1e1e1e00000e00000e00001e1e1e2e
3c2b00000d003f3f3f3f000d00002b2a3e004100002d3e3e3e3e2d000000003e000000000000000000000000000000003e00000000000060000000000000003e0a00000000000000000000000000000a08410000004100000041000000000000000000430000000d0d000043000000002e1e1e0000000e00000e0000001e1e2e
3c0040000d0000000000000d0040002a3e00000000000000000000000000433e000000430000000000000043000000003e2d0000002d3e3e3e3e2d0000002d3e0a00600000420043003d00000000410a0000000000000000000000000000000000080b0b0b08000d0d00080b0b0b08002e1e000000450e29450e450000001e2e
3c3f3f3f3f3a000000003a3f3f3f3f2a3e43000000000043000000002d3e3e3e003b3b3b000000000000003b3b3b00002d0000000000002d2d0000000000002d0a09090909090909090909090800000a00000041000000410000000041000000000000000000000d0d000000000000002e000000003f373737373f000000002e
3c0000000d2a000000003c0d00002b2a3e3e3e2d002d3e3e3e3e2d000000193e000d000d00003b3b3b00000d000d00002d00420000000000000000604200002d0000080800080000080a640a0b0b000a08000000000000000000000000000800000000080040000d0d004000080000002e001e1e00000e00000e00001e00002e
3c2b00000d2a2b0043003c0d002b2b2a3e1b000000000000000000000000003e000d000d00000d000d00000d000d00003e1f1f1f1f1f2d00002d1f1f1f1f1f3e0000000000000000000000000000000a0000000808600000006000080800000000410000000b0b0b0b0b0b00004100082e00001e1e000e00000e001e0000002e
3c3f3f3f3f3c3a3a3a3a2a3f3f3f3f2a3e00006000000000430000006000003e000d000d00000d000d00000d000d40003e1b2d000e0000000000000e002d193e000000413d0008000000004200003d0a090b0b09090b0b0b0b09090909090909000000000000080808080000000000002e1e000000290e29290e29001e001e2e
3c0000000d3f640000643f0d0000002a3e3e3e3e3e3b3b3b3b3b3b3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e1f1f1f3e2d00000e0000404300000e00002d3e000000000b0b0a09090909090909090a0a08080808000043000a0a0a0a0a0a0a000000000000000000000000000000001e000000003f373737373f0000001e1e
3c2b00000d0000000000000d00002b2a3e2d2d000000003d3d000000002d2d3e3e2d2d002d3e2727273e2d2d3e2d00003e0000000e001f3e3e1f000e0000003e0000000000000a080800080a646408080a08000000000009090a0a0a0a0a0a0a000808000000092000090000080043001e1e000000000e00000e000000001e1e
3c3a40000d0000000000000d00403a2a3e2d000000002c3e3e1c000000002d3e3e2d0000000064006400002d3e2d00003e0000000e002d3e3e2d000e0000003e0042003d00080a080000080a000800080a0000000000080a0a0a0a0a0a0a0a0a0b0b0b0b0b080a09090a080b0b0b0b0b1e1e29291e280e39000e181e2929001e
2a3c3f3f3f0000000000003f3f3f2a3c3e000000002c3e27273e1c000000003e3e00002d000000000000002d3e1f1f1f3e0000001f1f1f3e3e1f1f1f0000003e0909090909090a08000000080800000a0a000000000b0b0a0a0a0a0a0a0a0a0a0000000000000008080000000000000038373737373838383838383737373738
2b0000000d0000000000000d000000003e0000002c3e272727273e1c0000003e3e002d3e1c000000000000002d0000003e0000000e00193e3e1b000e0000003e0a08080000000000000000000000000a0a0000000000080a0a0a0a0a0a0a0a0a080000000000000000000008000000082e1e000000000e00000e000000001e2e
2b2b20000d003d00003d000d0000002b3e3d202c3e2727272727273e1c003d3e3e202d3e0c1c000000000040000000003e1920000e00003e3e00000e0000003e0a080000200000003d3d000000003d0a0a0800200008080a0a0a0a0a0a0a0a0a000008080000080800000000000008082e20001839290e00000e281828181e2e
003a3a3a3a3a3a3a3a3a3a3a3a3a3a3a003e3e3e3e3e3e3e3e3e3e3e3e3e3e3e003e3e273e3e3e3e3e3e3e3e3e3e3e3e003e3e3e3e3e3e3e3e3e3e3e3e3e3e3e0009090909090909090909090909090a000909090909090a0a0909090909090a000909090909090909090909090909090038383838383800003838383838382e
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01090000180351b0252001524015270152c0152c0021a0351d0252201526015290152e0152b1001c0351f02524015280152b0153001534015370153c0103c0150000000000000000000000000000000000000715
0109000014715185151b7152051524715275152c502167151a5151d7152251526715295152b700187351c5251f71524515287152b515307153051534710347150000000000000000000000000000000000000705
010200001554512005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000c1400e0411104114041170411704014041120410f0410c14100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
010800000f03013041170411800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002c33127531225311050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010700002c5212f0452c0350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001f54024541182050c20500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000d0400e041170411204100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000914512105001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
01040000277452c745317450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002763022630206201b6201661015610116100d6100b6100761005610036100261002610026100261001610016100161501600016000160001600000000000000000000000000000000000000000000000
010500001c5301f530245302453024535000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900003014101006000000000000000000000000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000014623136231162311623106230f6230e6230d6230c6230b6230a623086230762306623056230462303623026230162301625006030060300603006030060300603006030060300603006030060300603
010200001a6342253119624215211762420521166241e521156241d521146241c521136241a52111624185210f624175210e624145210c624125210b62410521096240d511066140a51104614075110161402511
010c000016043000001d103000000000000000000001d303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0107000023745287452d3021e105370021c0051330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021320207002070022b0011f0011f0021f0021f002
010500000c436186360c426186260c416186160c416186160c416186160c406184060040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
01070000386303062025610206101c61019610176101561012610106100f6100d6100b6100a613086130761306613046130361303613006050060500605006050060500605006050060500605006050060500605
010600000e0451074513045187451a0351c7351f0352473526025287252b025307253201534715370153c7153251534517375163c516005050050500505005050050500505005050050500505005050050500505
011c00000e143074030a1031f6050e103011050a10300600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012300000a04205031010210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7011b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70129515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0011d005
0112000003744030250a7040a005137441302508744080251b7110a704037440302524615080240a7440a02508744087250a7040c0241674416025167251652527515140240c7440c025220152e015220150a525
011200000c033247151f5152271524615227151b5051b5151f5201f5201f5221f510225212252022522225150c0331b7151b5151b715246151b5151b5051b515275202752027522275151f5211f5201f5221f515
011200000c0330802508744080250872508044187151b7151b7010f0251174411025246150f0240c7440c0250c0330802508744080250872508044247152b715275020f0251174411025246150f0240c7440c025
011200002452024520245122451524615187151b7151f71527520275202751227515246151f7151b7151f715295202b5212b5122b5152461524715277152e715275002e715275022e715246152b7152771524715
011200002352023520235122351524615177151b7151f715275202752027512275152461523715277152e7152b5202c5212c5202c5202c5202c5222c5222c5222b5202b5202b5222b515225151f5151b51516515
011200000c0330802508744080250872508044177151b7151b7010f0251174411025246150f0240b7440b0250c0330802508744080250872524715277152e715080242e715080242e715246150f0240c7440c025
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
010e000005145185111c725050250c12524515185150c04511045185151d515110250c0451d5151d0250c0450a0451a015190150a02505145190151a015050450c0451d0151c0150012502145187150414518715
010e000021745115152072521735186152072521735186052d7142b7142971426025240351151521035115151d0451c0051c0251d035186151c0251d035115151151530715247151871524716187160c70724717
010e000002145185111c72502125091452451518515090250e045185151d5150e025090451d5151d025090450a0451a015190150a02505045190151a015050450c0451d0151c0150012502145187150414518715
010e000029045000002802529035186152802529035000001a51515515115150e51518615000002603500000240450000023025240351861523025240350000015515185151c51521515186150c615280162d016
010e000002145185112072521025090452451518515090450e04521515265150e025090451d5151d01504045090451d01520015210250414520015210250404509045280152d0150702505145187150414518715
011a00000173401025117341102512734120250873408025127341202501734010251173411025087340802505734050250d7340d025147341402506734060250873408025127341202511734110250d7340d025
010d00200c0331b51119515195152071220712145151451518615317151d5151d515125050c03314515145150c0330150519515195150d517205161451514515186153171520515205150d5110c033145150c033
011a00000a7340a02511734110250d7340d02505734050250673406025147341402511734110250d7340d0250a7340a02511734110250d7340d02508734080250373403025127341202511734110250d7340d025
010d00200c0331b511295122951220712207122c5102c51018615315143151531514295150c03329515295150c0330150525515255150d517205162051520515186153171520515205150d5110c033145150c033
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
010700000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c53621036245262102624536330362452633026
__music__
05 00 01 43 44
01 18 19 43 44
00 18 19 43 44
01 18 19 43 44
00 18 19 43 44
00 1a 1b 43 44
02 1a 1b 43 44
01 1c 42 43 44
00 1c 42 43 44
01 1c 1d 43 44
00 1c 1d 43 44
01 1c 1d 43 44
00 1c 1d 43 44
00 1e 1f 43 44
02 21 20 43 44
01 22 23 43 44
00 24 25 43 44
00 22 26 43 44
02 24 26 43 44
00 28 42 43 44
01 28 27 43 44
00 28 27 43 44
00 28 29 43 44
00 2a 29 43 44
02 2a 2b 43 44
01 2c 2d 43 44
00 2c 2d 43 44
00 2e 2d 43 44
00 2e 2d 43 44
00 30 2f 43 44
02 2e 2f 43 44
01 31 42 43 44
01 31 32 43 44
00 31 32 43 44
00 33 32 43 44
00 31 34 43 44
02 33 34 43 44
01 35 36 43 44
00 35 37 43 44
00 35 36 43 44
00 35 37 43 44
00 39 38 43 44
02 35 3a 43 44
01 3f 42 43 44
01 3c 3b 43 44
00 3c 3b 43 44
02 3e 3d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
