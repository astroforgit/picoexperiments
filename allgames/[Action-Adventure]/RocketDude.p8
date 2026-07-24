pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- toy box jam start cart
-- by that tom hall & friends
-- sprites/sfx/code: that tom hall
-- sprites/sfx: lafolie
-- platforming anims: toby hefflin
-- music: gruber
-- additional code: see functions
-- if you did a function that is
-- uncredited, let me know!
-------------------------------
-- this contains a set of
-- creative assets to play
-- with. everyone has the same
-- set of "toys"... what will
-- you make of 'em?
-------------------------------
-- resources:
--
-- random useful sprites
--  (just go look or see asset list!)
-- random useful sfx
-- -00-21:sfx
-- -22-59:songs
-- -60-63:sfx

-- songs: by gruber
-- 00 happy land
-- 06 chill
-- 12 scary dungeon
-- 18 fight
-- 21 evil
-- 23 defeat
-- 24 celebrate
-- 25 puzzle
-- 29 sand

-- 33 read or wait my dude by that tom hall
-- (not on gruber level, but useful)

---------- Some Constants -----------

kshoplvl=10

---------- Level 1 Intro the Bombs -----------
function _initlevel1()
 _initplr(0,112)
 add(doors,{x=54,y=56,w=8,h=8,spr=3,destlevel=2})
 add(doors,{x=66,y=56,w=8,h=8,spr=3,destlevel=kshoplvl}) -- The store
 
 add(texts,{x=64,y=50,str='SHOP',color=7})
 
 --CHEAT doors
 --[[
 add(doors,{x=24,y=112,w=8,h=8,spr=3,destlevel=2})
 add(doors,{x=34,y=112,w=8,h=8,spr=3,destlevel=3})
 add(doors,{x=44,y=112,w=8,h=8,spr=3,destlevel=4})
 add(doors,{x=54,y=112,w=8,h=8,spr=3,destlevel=5})
 add(doors,{x=64,y=112,w=8,h=8,spr=3,destlevel=6})
 add(doors,{x=74,y=112,w=8,h=8,spr=3,destlevel=7})
 add(doors,{x=84,y=112,w=8,h=8,spr=3,destlevel=8})
 add(doors,{x=94,y=112,w=8,h=8,spr=3,destlevel=9})
 add(doors,{x=104,y=112,w=8,h=8,spr=3,destlevel=10})
 ]]--
 
 add(walls,{x=0,y=120,w=128,h=8,spr=1})
 add(walls,{x=0,y=88,w=16,h=8,spr=1})
 add(walls,{x=8,y=96,w=8,h=16,spr=1})
 add(walls,{x=40,y=40,w=8,h=24,spr=1})
 add(walls,{x=80,y=40,w=8,h=24,spr=1})
 add(walls,{x=40,y=64,w=48,h=8,spr=1})
 
 for x=24,104,16 do
  _addcoin(x,96)
  _addcoin(x,16)
 end
 for y=32,88,16 do
  _addcoin(24,y)
  _addcoin(104,y)
 end
 
 _addbomb(8,112)
 for x=16,120,8 do
  for y=112,0,-8 do
    _addbomb(x,y)
  end
 end
 for y=0,80,8 do
  _addbomb(0,y)
  _addbomb(8,y)
 end
 music(6)
end

---------- Level 2 The Bomb Chase -----------
function _initlevel2()
 _initplr(0,120)
 add(doors,{x=32,y=40,w=8,h=8,spr=3,destlevel=4})
 add(doors,{x=32,y=24,w=8,h=8,spr=3,destlevel=11}) -- Bonus coin level

 add(walls,{x=16,y=120,w=128,h=8,spr=1})
 add(walls,{x=0,y=96,w=112,h=8,spr=1})
 add(walls,{x=0,y=48,w=112,h=8,spr=1})
 add(walls,{x=0,y=16,w=128,h=8,spr=1})
 
 -- bombs
 _addbomb(8,120)
 
 for x=8,120,8 do
  _addbomb(x,112)
  _addcoin(x-8,104)
 end
 
 _addbomb(120,104)
 _addbomb(120,96)
 _addbomb(120,88)
 _addcoin(112,96)
 
 for x=8,120,8 do
  _addbomb(x,80)
  _addcoin(x-8,88)
 end
 
 _addcoin(0,80)
 _addcoin(0,72)
 _addcoin(0,64)
 _addbomb(8,72)
 --_addbomb(16,72)
 
 for x=8,120,8 do
  _addbomb(x,64)
  _addcoin(x-8,56)
 end
 
 _addbomb(120,56)
 _addbomb(120,48)
 _addbomb(120,40)
 
 for x=8,120,8 do
  _addbomb(x,32)
 end
 music(7)
end

---------- Level 3 Intro the spikies -----------

---------- Level 4 The Spiky Gauntlet -----------
function _initlevel4()
 _initplr(0,112)
 add(doors,{x=0,y=20,w=8,h=8,spr=3,destlevel=5})
 add(walls,{x=0,y=28,w=8,h=8,spr=1})
 
 add(spikes,{x=24,y=120,w=104,h=8,spr=58})
 add(spikes,{x=0,y=92,w=104,h=8,spr=58})
 add(spikes,{x=24,y=64,w=104,h=8,spr=58})
 add(spikes,{x=0,y=36,w=104,h=8,spr=58})
 add(spikes,{x=0,y=0,w=128,h=8,spr=58})
 
 for x=10,120,12 do
  _addcoin(x,106)
  _addcoin(x,78)
  _addcoin(x,50)
  _addcoin(x,22)
 end
 
-- local speed=0.1
-- local delay=-60 -- frames
-- _addwpenemy(24,96,{24,96,delay,delay,24,104},speed)

 music(8)
end

---------- Level 5 Intro the Flying Nasties -----------

function _initlevel5()
 _initplr(0,0)
 add(doors,{x=56,y=80,w=8,h=8,spr=3,destlevel=6})
 
 add(walls,{x=0,y=24,w=104,h=8,spr=1})
 _add2ptenemy(32,16,0,-16)
 _add2ptenemy(64,0,0,16)
 
 add(walls,{x=96,y=32,w=8,h=72,spr=1})
 _add2ptenemy(104,32,16,0)
 _add2ptenemy(104,48,16,0)
 _add2ptenemy(104,64,16,0)
 _add2ptenemy(104,80,16,0)
 _add2ptenemy(104,96,16,0)
 
 add(walls,{x=24,y=88,w=80,h=8,spr=1})
 add(walls,{x=32,y=96,w=8,h=8,spr=1})
 add(walls,{x=48,y=96,w=8,h=8,spr=1})
 add(walls,{x=64,y=96,w=8,h=8,spr=1})
 add(walls,{x=80,y=96,w=8,h=8,spr=1})
 
 _add2ptenemy(24,120,0,-24)
 _add2ptenemy(40,96,0,24)
 _add2ptenemy(56,120,0,-24)
 _add2ptenemy(72,96,0,24)
 _add2ptenemy(88,120,0,-24)
 
 add(walls,{x=16,y=56,w=8,h=48,spr=1})
 _add2ptenemy(8,56,0,48)
 _add2ptenemy(0,104,0,-48)
 
 add(walls,{x=24,y=56,w=40,h=8,spr=1})
 _add2ptenemy(88,32,-88,0)
 
 _addwpenemy(0,40,{0,40,88,40})
 _addwpenemy(16,40,{0,40,88,40})
 _addwpenemy(32,40,{0,40,88,40})
 _addwpenemy(48,40,{0,40,88,40})
 _addwpenemy(64,40,{0,40,88,40})
 _add2ptenemy(88,48,-88,0)
 _addwpenemy(88,48,{88,48,0,48})
 _addwpenemy(72,48,{88,48,0,48})
 _addwpenemy(72,48,{0,48,88,48})
 
 music (21)
end

function _add2ptenemy(x,y,w,h)
 _addwpenemy(x,y,{x,y,x+w,y+h})
end

---------- Level 6 Loadza Flying Nasties -----------
function _initlevel6()
 _initplr(0,112)
 add(doors,{x=96,y=112,w=8,h=8,spr=3,destlevel=7}) 
 
 add(walls,{x=0,y=120,w=128,h=8,spr=1})
 add(walls,{x=60,y=16,w=8,h=104,spr=1})
 
 -- lhs
 _addwpenemy(0,16,{0,16,52,16})
 _addwpenemy(8,24,{0,24,52,24})
 _addwpenemy(16,32,{0,32,52,32})
 _addwpenemy(24,40,{0,40,52,40})
 
 _addwpenemy(4,20,{0,20,52,60})
 _addwpenemy(20,20,{52,20,0,60})
 
 _addwpenemy(26,60,{0,40,52,80})
 _addwpenemy(2,40,{52,40,0,80})
 
 _addwpenemy(0,40,{0,40,52,80})
 _addwpenemy(36,40,{52,40,0,80})
 
 _addwpenemy(12,60,{0,60,52,100})
 _addwpenemy(51,60,{52,60,0,100})
 
 _addwpenemy(0,40,{0,40,52,40,52,80,0,80})
 _addwpenemy(52,80,{52,80,0,80,0,40,52,40})
 _addwpenemy(0,40,{0,40,0,80,52,80,52,40})
 _addwpenemy(52,80,{52,80,52,40,0,40,0,80})
 
 -- rhs
 _addwpenemy(68,16,{68,16,120,16})
 _addwpenemy(76,24,{68,24,120,24})
 _addwpenemy(84,32,{68,32,120,32})
 _addwpenemy(92,40,{68,40,120,40})
 
 _addwpenemy(68,16,{120,16,68,16})
 _addwpenemy(76,24,{120,24,68,24})
 _addwpenemy(84,32,{120,32,68,32})
 _addwpenemy(92,40,{120,40,68,40})
 
 for x=80,112,8 do
  for y=64,96,8 do
   _addcoin(x,y)
  end
 end
 
 music (21)
end

---------- Level 7 (Fly Gauntlet) -----------
function _initlevel7()
 _initplr(0,112)
 add(doors,{x=104,y=32,w=8,h=8,spr=3,destlevel=1})
 add(doors,{x=120,y=0,w=8,h=8,spr=3,destlevel=8})
 add(doors,{x=8,y=80,w=8,h=8,spr=3,destlevel=7,destdoor=4})
 add(doors,{x=0,y=32,w=8,h=8,spr=3,destlevel=7,destdoor=3})
 
 add(spikes,{x=24,y=120,w=64,h=8,spr=58})

 add(walls,{x=120,y=8,w=8,h=16,spr=1})
 add(walls,{x=0,y=88,w=112,h=8,spr=1})
 add(walls,{x=0,y=96,w=24,h=8,spr=1})
 add(walls,{x=0,y=40,w=128,h=8,spr=1})
 
 _addcoin(0,56)
 _addcoin(8,56)
 _addcoin(16,64)
 _addcoin(24,72)
 _addcoin(32,72)
 _addcoin(40,64)
 _addcoin(48,56)
 _addcoin(56,56)
 _addcoin(64,64)
 _addcoin(72,72)
 _addcoin(80,73)
 _addcoin(88,64)
 _addcoin(96,56)
 _addcoin(104,56)
 _addcoin(112,64)
 _addcoin(120,72)

 -- enemies
 _addenemyconveyer(16,112)
 
 local speed=0.1
 local delay=-120 -- frames (negative means delay)
 local y1=108 
 local y2=94
 
 for i=0,3,1 do
  x1=24+(i*16)
  x2=32+(i*16)
  doffset=i*80 -- delay before start
  _addwpenemy(x1,y1,{x1,y1,x1,y2,delay,delay},speed,doffset)
  _addwpenemy(x2,y1,{x2,y1,x2,y2,delay,delay},speed,doffset)
 end
 
 music (21)
end

---------- Level 8 (One with a link to the Store) -----------

function _initlevel8()
 _initplr(0,112)
 add(walls,{x=40,y=40,w=8,h=24,spr=1})
 add(walls,{x=80,y=40,w=8,h=24,spr=1})
 add(walls,{x=40,y=64,w=48,h=8,spr=1})
 
 add(doors,{x=54,y=56,w=8,h=8,spr=3,destlevel=9})
 add(doors,{x=66,y=56,w=8,h=8,spr=3,destlevel=kshoplvl}) -- The store
 add(texts,{x=64,y=50,str='SHOP',color=7})
 music(7)
end

---------- Level 9 (The Boss) -----------

function _initlevel9()
 _initplr(0,112)
 
 add(walls,{x=0,y=120,w=128,h=8,spr=1})
 add(walls,{x=0,y=0,w=128,h=8,spr=1})
 
 local bossrocket1={x=52,y=72,w=8,h=8,spr=73}
 local bossrocket2={x=68,y=72,w=8,h=8,spr=73}
 bossrockets={bossrocket1,bossrocket2} -- store these as a global for collision detection later
 add(sprites,bossrocket1)
 add(sprites,bossrocket2)
 
 add(sprites,{x=52,y=64,w=8,h=8,spr=119})
 add(sprites,{x=60,y=64,w=8,h=8,spr=120})
 add(sprites,{x=68,y=64,w=8,h=8,spr=121})
 add(sprites,{x=52,y=72,w=8,h=8,spr=143})
 add(sprites,{x=68,y=72,w=8,h=8,spr=143})
 
 -- A hacky way to display damage (I'm running out of time)
 damagespr1={x=54,y=66,w=8,h=8,spr=71}
 damagespr2={x=66,y=70,w=8,h=8,spr=71}
 
 add(bosses,{x=52,y=64,w=24,h=16})
 
 -- ToDo: Would be cool to have a delay before this animation
 add(sprites,{x=60,y=112,w=8,h=8,spr=117,target={x=60,y=72},speed=kbossskullspeed,ondone=_startboss}) -- skull
 inputfreeze=1000
 
 music(18)
end

---------- Level 10 (The Store,kshoplvl) -----------

function _initlevel10()
 _initplr(0,112)
 add(doors,{x=0,y=112,w=8,h=8,spr=3,destlevel=previouslevel})
 add(walls,{x=0,y=120,w=128,h=8,spr=1})
 add(walls,{x=0,y=0,w=128,h=8,spr=1})
 
 add(texts,{x=10,y=30,str='WHAT WOULD YOU LIKE TO BUY?',color=7})
 
 add(texts,{x=8,y=62,str='SIDE ROCKETS',color=7})
 add(sprites,{x=24,y=70,w=8,h=8,spr=95})
 add(sprites,{x=32,y=70,w=8,h=8,spr=95})
 add(sprites,{x=28,y=70,w=8,h=8,spr=96,oncollide=_buysiderockets})
 
 --add(texts,{x=70,y=62,str='BLASTRON 5000',color=7})
 add(texts,{x=70,y=62,str='A HAT',color=7})
 add(sprites,{x=78,y=70,w=8,h=8,spr=190,oncollide=_buyhat})
 music(10)
end

---------- Level 11 The Fun Level -----------

function _initlevel11()
 _initplr(0,0)
 add(doors,{x=120,y=120,w=8,h=8,spr=3,destlevel=previouslevel})
 add(walls,{x=0,y=8,w=8,h=8,spr=1})
 
 _addenemyconveyer(16,128)
 _addcoinrow(32)
 _addenemyconveyer(40,128)
 _addcoinrow(56)
 _addenemyconveyer(64,128)
 _addcoinrow(80)
 _addenemyconveyer(88,128)
 _addcoinrow(104)
 _addenemyconveyer(112,128)
 music(11)
end

---------- Populate Level Utility Functions -----------

function _initplr(x,y)
 plr={} plr.x=x plr.y=y plr.dx=0 plr.dy=0 plr.w=8 plr.h=8 -- Todo: I tried to make plr.w 7.95 but it interfered with the mechanics of level 2 
end

function _addcoinrow(y)
 for x=0,120,8 do
  _addcoin(x,y)
 end
end

function _addenemyconveyer(y,width) -- ToDo, Add a max row for level 7
 local y1=y
 local y2=y+8
 for x=0,width,16 do
  _addwpenemy(x,y1,{0,y1,0,y2,width,y2,width,y1})
  _addwpenemy(x+8,y2,{width,y2,width,y1,0,y1,0,y2})
 end
end

-------------------------------
function _initglobals()
 max_speed=1
 frame=0
 bomb_ttl=0.6
 blast_ext=2 -- n pixels
 flameh = 5 -- flame height
 flamew = 8 -- flame height
 f_to_light = 20 -- 60 frames of flame to light bombs
 f_to_reset = 20 -- 60 frames of no flame to reset a bomb 
 inputfreeze=30
 changedlevel=true
 inventory={coins=0}
 costs={siderockets=150,hat=200,blaster=4}
 paused=false
 modalstate={}
 respawnpos=nil
 previouslevel=1
 framessincesfx={0,0,0,0}
end

function _reset()
 walls,bombs,enemies,doors,spikes,texts,sprites,bosses={},{},{},{},{},{},{},{}
 if (changedlevel) coins={} -- Don't clear coins if going through a door but staying on the same level
 
 if (level==nil) level=1
 if level==1 then _initlevel1()
 elseif level==2 then _initlevel2()
 elseif level==3 then _initlevel3()
 elseif level==4 then _initlevel4()
 elseif level==5 then _initlevel5()
 elseif level==6 then _initlevel6()
 elseif level==7 then _initlevel7()
 elseif level==8 then _initlevel8()
 elseif level==9 then _initlevel9()
 elseif level==10 then _initlevel10()
 elseif level==11 then _initlevel11()
 end
 
 sfx(-2,-2) -- stop all
 
 win=false
 dead=false
 requirenoinput=false
 nextlevel=-1
 bossstate=nil
 
 if respawnpos~=nil then
  plr.x=respawnpos.x plr.y=respawnpos.y
 elseif destdoor~=nil and #doors>=destdoor then
  plr.x=doors[destdoor].x plr.y=doors[destdoor].y
  destdoor=nil
  respawnpos={x=plr.x,y=plr.y}
 else
  respawnpos=nil
 end
 
 _createbombslookup()
end

-- A lookup table to look up bombs by position
function _createbombslookup()
 bombslookup={}
 for i=1,16,1 do add(bombslookup,{}) end
 local x,y
 for b in all(bombs) do
  x=flr(b.x/8)+1
  y=flr(b.y/8)+1
  bombslookup[x][y]=b
 end
end

function _getclosestbombs(x,y)
 local bombs={}
 local xlookup=flr(x/8)+1
 local ylookup=flr(y/8)+1
 for i=xlookup-1,xlookup+1,1 do
  if i>0 and i<17 then
   for j=ylookup-1,ylookup+1,1 do
    if j>0 and j<17 then
     if bombslookup[i][j]~=nil then
      add(bombs,bombslookup[i][j])
     end
    end
   end
  end
 end
 return bombs
end

function _init()
 level=1
 _initglobals() 
 --inventory={coins=0,siderockets=true}
 _reset()
end

-->8
-- update tab

------Utility Init Functions---------

function _addbomb(x,y)
 add(bombs,{x=x,y=y,w=8,h=8,spr=153,ttl=-1,fcount=0,nfcount=0})
end

function _addcoin(x,y)
 if changedlevel then
  add(coins,{x=x,y=y,w=8,h=8,spr=66})
 end
end

function _addwpenemy(x,y,wp,speed,doffset) -- waypoint enemy
 add(enemies,{x=x,y=y,w=7.99,h=7.99,wp=wp,spr=182,fr=3,dx=0,dy=0,speed=speed,delay=doffset})
end

------Utility Function---------------
function _intersects(px,py,x,y,w,h) --pt intersects rect
 return px>=x and px<=x+w and py>=y and py<=y+h
end

function _rectoverlap(o1,o2) -- returns the overlapping rect
 return max(o1.x,o2.x),max(o1.y,o2.y),min(o1.x+o1.w,o2.x+o2.w),min(o1.y+o1.h,o2.y+o2.h);
end

function _isrectoverlap(o1,o2) -- is ovelapping
 local x5,y5,x6,y6=_rectoverlap(o1,o2)
 return x6-x5>=0 and y6-y5>=0
end

function _isvcollide(o1,o2) -- is vertical collision or horizontal most important
 local x5,y5,x6,y6=_rectoverlap(o1,o2)
 return y6-y5<x6-x5
end

function _dosfx(sample,channel)
 if framessincesfx[channel+1] > 10 then
  sfx(sample,channel)
  framessincesfx[channel+1]=0
 end
end

----- Boss Constants --------

-- Intro sequence
kbossrocketspeed=0.1 -- should be 0.05
kbossskullspeed=0.3 -- should be 0.3

-- Boss State machine
kbosswaspdelay=50
kbosswaspchance=0.8
kbossdamage=0.25 -- should be 0.25
kbossmode0speed=1
kbossmode0delay=100
kbossmode1delay=300
kbossmode1speed=1
kbossmode2delay=150
kbossmode2speed=1
kbossarctime=150 -- Mode 3 speed
kbossmode20delay=120 -- taking damage
kbossmode21delay=180

----- Boss Functions --------

function _startboss()
 -- Lower the rockets
 sprites[1].target={x=52,y=78}
 sprites[1].speed=kbossrocketspeed
 sprites[1].ondone=_onrocketsdone
 
 sprites[2].target={x=68,y=78}
 sprites[2].speed=kbossrocketspeed
 sprites[2].ondone=_onrocketintrodone
end

function _onrocketintrodone()
 inputfreeze=0
 bossstate={}
 bossstate.target={x=0,y=8}
 bossstate.speed=kbossmode0speed
 bossstate.mode=0 -- 1=Intro mode: fly to screen top left
 bossstate.nextmodedelay=kbossmode0delay
 bossstate.health=1
end

function _moveboss(x,y,rocketson)
 -- Assuming the boss and sprites exist
 local boss=bosses[1] 
 boss.x=x boss.y=y
 
 sprites[1].x=x
 sprites[2].x=x+16
 if rocketson then
  sprites[1].y=y+13
  sprites[2].y=y+13
 else
  sprites[1].y=y+8
  sprites[2].y=y+8
 end
 
 local offsets={0,0, 8,0, 16,0, 0,8, 16,8, 8,8}
 for i=0,5,1 do
  sprites[i+3].x=x+offsets[i*2+1]
  sprites[i+3].y=y+offsets[i*2+2]
 end
end

function _updateboss()
 
 local boss=bosses[1]
 if boss==nil or bossstate==nil then return end
 
 -- Process the boss mode
 if (bossstate.mode==0) then _updateboss0(boss) end
 if (bossstate.mode==1) then _updateboss1(boss) end
 if (bossstate.mode==2) then _updateboss2(boss) end
 if (bossstate.mode==3) then _updateboss3(boss) end
 if (bossstate.mode==20) then _updateboss20(boss) end
 if (bossstate.mode==21) then _updateboss21(boss) end
 
 _handlebossmodetransitions(boss)
 
 -- Check for boss damage
 local damagespot={x=boss.x+6,y=boss.y-2,w=12,h=8}
 if bossstate.damagethisround==nil and not dead and _isrectoverlap(damagespot,{x=plr.x,y=plr.y+plr.h,w=flamew-0.01,h=flameh}) and bottomrocket and not boss.dead then
     bossstate.mode=20
     bossstate.nextmodedelay=kbossmode20delay
     bossstate.health-=kbossdamage
     bossstate.damagethisround=true
    end
end

function _isbossdead()
 if bossstate==nil then return false end
 return bossstate.mode==22
end

function _handlebossmodetransitions(boss)
 -- Modes are: 
 -- 1. fly on screeen top, drop wasps
 -- 2. Transition to top left (or top right, flip a coin)
 -- 3. Circle down to the player posiiton
 -- 20. Taking damage, pause movement
 -- 21. Dead (Falling)
 -- 22. Dead (Resting)
 -- Transition between modes if needed
 if bossstate.health<=0 and bossstate.mode!=20 and bossstate.mode!=22 and bossstate.mode!=21 then
  bossstate.mode=21 -- Dead
  bossstate.target={x=boss.x,y=104}
  bossstate.speed=0.3
  bossstate.nextmodedelay=kbossmode21delay 
  boss.dead=true
  for r in all(bossrockets) do
   r.dead=true
  end
  for e in all(enemies) do
   e.dead=true
   e.pal1=3
   e.pal2=6
  end
  music(24) -- Win music
 end
 
 bossstate.nextmodedelay-=1
 if bossstate.nextmodedelay<=0 then
  if bossstate.mode==0 then
   bossstate.nextmodedelay=kbossmode1delay
   bossstate.mode=1
   bossstate.speed=kbossmode1speed
   bossstate.target=nil   
  elseif bossstate.mode==1 then
   bossstate.nextmodedelay=kbossmode2delay 
   bossstate.mode=2
   bossstate.speed=kbossmode2speed
   bossstate.target=nil
  elseif bossstate.mode==2 then
   bossstate.nextmodedelay=9999
   bossstate.mode=3
   bossstate.framesinmode3=0 -- For tracking mode 3
   bossstate.damagethisround=nil
  elseif bossstate.mode==20 then -- Back to mode 3 after mode 20, which is temporary
   bossstate.mode=3
   del(sprites,damagespr1) -- Clear the damage sprites
   del(sprites,damagespr2) -- Clear the damage sprites
  elseif bossstate.mode==21 then -- Dead falling, transition to resting
   bossstate.mode=22
   del(sprites,damagespr1) -- Clear the damage sprites
   del(sprites,damagespr2) -- Clear the damage sprites
  end
 end
end

function _updateboss0(boss) -- mode 0 (intro) updates
 local moved=_lerpboss(boss,bossstate.target,bossstate.speed)
end

function _updateboss1(boss) -- mode 1 update
 if bossstate.nextwaspdelay==nil then
  bossstate.nextwaspdelay=kbosswaspdelay
 else
  bossstate.nextwaspdelay-=1
  if bossstate.nextwaspdelay<0 then
   bossstate.nextwaspdelay=kbosswaspdelay
   if rnd(1)<kbosswaspchance then
    _bossspawnwasp(boss)
   end
  end
 end
 
 local moved=_lerpboss(boss,bossstate.target,bossstate.speed)
 
 -- Compute a new position to hover over and back at the top of the screen
 if not moved then
  local r1=rnd(30)
  r1=flr((r1*r1)/30) -- weight it towards the lower end
  if boss.x<64 then
   bossstate.target={x=96-r1,y=8}
  else
   bossstate.target={x=r1,y=8}
  end -- if boss.x...
 end -- if bossstate...
end -- function
 
 
function _updateboss2(boss) -- mode 2 update: Transition to top left (or top right, flip a coin)
 _lerpboss(boss,bossstate.target,bossstate.speed)
 if bossstate.target!=nil then return end -- Target already set
 if rnd(1)<0.5 then
  bossstate.target={x=0,y=8}
 else
  bossstate.target={x=96,y=8}
 end
end

function _updateboss3(boss) -- state 3 update: Circle down to the player posiiton
 if bossstate.framesinmode3==kbossarctime then
  bossstate.mode=1 -- 1=fly on screeen top, drop wasps
  bossstate.nextmodedelay=kbossmode1delay
  bossstate.speed=kbossmode1speed
 end

 if bossstate.framesinmode3 == 0 then -- initialize direction
  if boss.x < 48 then 
   bossstate.direction=-1
  else 
   bossstate.direction=1
  end
 end

 local theta=0.5*bossstate.framesinmode3/kbossarctime
 if bossstate.direction==-1 then
  theta=0.5-theta 
 end
 
 local x=48+cos(theta)*48
 local y=8-sin(theta)*90
 _moveboss(x,y,true)
 
 bossstate.framesinmode3+=1
end

function _updateboss20(boss) -- state 3 update
 if bossstate.framesinmode20==nil then bossstate.framesinmode20=0 end
 bossstate.framesinmode20+=1
 
 damagespr1.x=boss.x+2  
 damagespr1.y=boss.y+4
 damagespr2.x=boss.x+14
 damagespr2.y=boss.y+6

 if bossstate.framesinmode20%20==3 then
  add(sprites,damagespr1)
 elseif bossstate.framesinmode20%20==8 then
  add(sprites,damagespr2)
 elseif bossstate.framesinmode20%20==13 then
  del(sprites,damagespr1)
 elseif bossstate.framesinmode20%20==18 then
  del(sprites,damagespr2)
 end
end

function _updateboss21(boss)
 _updateboss20(boss)
 -- Fall to the ground
 _lerpboss(boss,bossstate.target,bossstate.speed)
end

function _lerpboss(boss,target,speed) -- could make this more general if I had time
 if target==nil then return false end
 local moved=false
 local newx=boss.x
 local newy=boss.y
 if abs(target.x-boss.x)>speed then
  newx=boss.x+sgn(target.x-boss.x)*speed
  moved=true
 end
 if abs(target.y-boss.y)>speed then
  newy=boss.y+sgn(target.y-boss.y)*speed 
  moved=true
 end
 
 _moveboss(newx,newy,newy<boss.y or (newy==boss.y and newx!=boss.x))
 return moved
end

function _bossspawnwasp(boss)
 local x=flr(boss.x+8)
 local y=flr(boss.y+16)
 local r1=flr(rnd(30))
 local r2=flr(rnd(30))
 _addwpenemy(x,boss.y+16,{x,40+r1,x,82+r2})
end

-------------------------------
-- Process collisions between the object and the specified list
function _collide(obj, list)
 local a=false b=false c=false d=false v=false -- player vertex collisions
 local o
 for o in all(list) do
  a=_intersects(obj.x,obj.y,o.x,o.y,o.w,o.h)
  b=_intersects(obj.x+obj.w,obj.y,o.x,o.y,o.w,o.h)
  c=_intersects(obj.x+obj.w,obj.y+obj.h,o.x,o.y,o.w,o.h)
  d=_intersects(obj.x,obj.y+obj.h,o.x,o.y,o.w,o.h)
  v=_isvcollide(obj,o)
  
  if ((a or b) and not c and not d and v) obj.y=o.y+o.h obj.dy=0
  if ((c or d) and not a and not b and v) obj.y=o.y-obj.h obj.dy=0
  if ((a or d) and not c and not b and not v) obj.x=o.x+o.w obj.dx=0
  if ((b or c) and not a and not d and not v) obj.x=o.x-obj.w obj.dx=0
 end 
end

function _applygravity(obj)
 obj.dy=obj.dy+0.03 -- gravity
 obj.dx*=0.95
 obj.dy*=0.95
 
 if (obj.dx > max_speed) obj.dx = max_speed
 if (obj.dx < -max_speed) obj.dx = -max_speed
 
 -- integrate position
 obj.y=obj.y+obj.dy
 obj.x=obj.x+obj.dx
 
 -- level bounds
 if (obj.y>120) obj.y=120 obj.dy=0
 if (obj.y<0) obj.y=0 obj.dy=0
 if (obj.x>120) obj.x=120 obj.dx=0
 if (obj.x<0) obj.x=0 obj.dx=0
end

function _updatebombs()
 -- plr proximity test
 local nearplr = _getclosestbombs(plr.x,plr.y)
 for b in all(nearplr) do
  if (bottomrocket and _isrectoverlap(b,{x=plr.x,y=plr.y+plr.h,w=flamew,h=flameh})) or
      (inventory.siderockets~=nil and leftrocket and not dead and _isrectoverlap(b,{x=plr.x-4,y=plr.y,w=4,h=plr.h})) or
      (inventory.siderockets~=nil and rightrocket and not dead and _isrectoverlap(b,{x=plr.x+plr.h,y=plr.y,w=4,h=plr.h})) then
   b.fcount+=1
   b.nfcount=0
  if (b.fcount>f_to_light and b.spr==153 and b.lit==nil) b.ttl=bomb_ttl b.lit=true
  else
   b.nfcount+=1
   if (b.nfcount>=f_to_reset) b.fcount = 0
  end
 end
 
 local nearbybombs={}
 for b in all(bombs) do
  if b.ttl > 0 then
   b.ttl-=0.01667
   b.palt=(b.ttl*10)%2
   if (b.ttl<=0 and b.spr==153) then 
    _dosfx(8,2)
    
    b.spr=71 b.ttl=0.1
    -- explode surrounding bombs
    nearbybombs=_getclosestbombs(b.x,b.y)
    for b2 in all(nearbybombs) do
     if b2.spr==153 and _isrectoverlap(b,b2) then
      b2.ttl = 0.2
     end
    end
   end
   if (b.ttl<=0 and b.spr==71) b.spr=72 b.ttl=0.1
   if (b.ttl<=0 and b.spr==72) b.spr=73 b.ttl=0.1
   if (b.ttl<=0 and b.spr==73) b.spr=74 b.ttl=0.1
   if b.ttl<=0 and b.spr==74 then del(bombs,b) end
   if (b.spr<74 and _isrectoverlap(plr,{x=b.x-blast_ext,y=b.y-blast_ext,w=b.w+(2*blast_ext),h=b.h+(2*blast_ext)}) and not dead) dead=true inputfreeze=30
  end
 end 
end

function _updateenemies()
 local targetx,targety,moved
 for e in all(enemies) do
  if e.dead==nil then
   local speed=0.3 -- px/frame
   if (e.speed != nil) speed=e.speed
   targetx=e.wp[1] targety=e.wp[2] gotonextwp=true
   
   if targetx<0 or (e.delay~=nil and e.delay>0) then -- targetx<0 represents a delay
    if (e.delay==nil) e.delay=-targetx
    e.delay-=1
    gotonextwp=e.delay<0
   else
    e.delay=nil
    if abs(targetx-e.x)>speed then
     e.flipx=sgn(targetx-e.x)==-1 e.x+=sgn(targetx-e.x)*speed gotonextwp=false
    end
    if abs(targety-e.y)>speed then
     e.y+=sgn(targety-e.y)*speed gotonextwp=false
    end
   end
   
   if gotonextwp then
    del(e.wp,targetx) del(e.wp,targety)
    add(e.wp,targetx) add(e.wp,targety)
   end
   if not dead and _isrectoverlap(e,{x=plr.x,y=plr.y+plr.h,w=flamew-0.01,h=flameh}) then -- and bottomrocket ToDo: Does the rocket need to be firing here? What's better
    e.dead=true
    e.pal1=3
    e.pal2=6
   end
   if inventory.siderockets~=nil and leftrocket and not dead and _isrectoverlap(e,{x=plr.x-4,y=plr.y+0.5,w=3.5,h=plr.h-1})  then
    e.dead=true
    e.pal1=3
    e.pal2=6
   end
   if inventory.siderockets~=nil and rightrocket and not dead and _isrectoverlap(e,{x=plr.x+8.5,y=plr.y+0.5,w=3.5,h=plr.h-1})  then
    e.dead=true
    e.pal1=3
    e.pal2=6
   end
     
  else
   _applygravity(e)
   _collide(e, walls)
   _collide(e, bombs)
  end --if dead
 end --for
end --function

function _dieoncollision(list,safety)
 if list==nil then return end
 for obj in all(list) do
  if (obj.dead==nil and _isrectoverlap(plr,{x=obj.x+safety,y=obj.y+safety,w=obj.w-(safety*2),h=obj.h-(safety*2)}) and not dead) dead=true requirenoinput=true inputfreeze=30
 end
end

function _collectoncollision(list,typename)
 for obj in all(list) do
  if (_isrectoverlap(plr,obj) and not dead) then
   del(list,obj)
   inventory[typename]+=1
   _dosfx(2,3)
  end
 end
end

function _updateplayer()
 if win then return end

 bottomrocket=btn(4) and not dead and inputfreeze<0
 leftrocket=btn(1) and not dead and inputfreeze<0
 rightrocket=btn(0) and not dead and inputfreeze<0
 if (bottomrocket) then
  plr.dy+=-0.075
  _dosfx(19,1)
 end
 
 -- Should I add a buff if inventory.siderockets is active
 local acc=0.05
 if (inventory.siderockets) acc=0.65
 if (leftrocket) plr.dx+=acc
 if (rightrocket) plr.dx-=acc
 
 _applygravity(plr)
 
 _collide(plr,walls)
 _collide(plr,bombs)
 _collide(plr,spikes)
 
 for d in all(doors) do
  if _isrectoverlap(plr,d) and btn(2) and inputfreeze<0 and not dead then
   win=true nextlevel=d.destlevel
   inputfreeze=15
   if (d.destdoor~=nil) destdoor=d.destdoor
  end
 end
end

function _updatesprites()
 for s in all(sprites) do
  if _isrectoverlap(plr,s) and s.oncollide~=nil then
   s.oncollide()
  end
  
  if s.target~=nil then
   -- ToDo: Maybe this could go in a LERP function because it's similar to how enemies are moved
   local done=true
   if abs(s.target.x-s.x)>s.speed then
    s.x+=sgn(s.target.x-s.x)*s.speed done=false
   end
   if abs(s.target.y-s.y)>s.speed then
    s.y+=sgn(s.target.y-s.y)*s.speed done=false
   end
  
   if done then
    s.target=nil
    if s.ondone~=nil then
     s.ondone()
    end
   end 
   
  end -- if s.target~=nil
 end -- for loop
end -- function

function _update60()
 for i=1,4,1 do
  framessincesfx[i]=(framessincesfx[i]+1)%999
  if framessincesfx[i]==100 then
   sfx(-2,i) -- Stop the sfx on this channel
  end
 end
  
 if (inputfreeze>=0) inputfreeze-=1
 
 local btn_pressed=btn(0) or btn(1) or btn(2) or btn(4)
 if (not btn_pressed) requirenoinput = false

 if modalstate.displaymessage!=nil then
  if inputfreeze<0 then 
   handlemodalinput() 
  end
  return
 end

 _updateplayer()
 _updatebombs()
 _updateenemies()
 _dieoncollision(enemies,0.05) -- 0.05 safety buffer
 _dieoncollision(spikes,0)
 
 _updatesprites()
 _updateboss()
 _dieoncollision(bosses,0) -- ToDo: Should this just push the player back like a wall?
 _dieoncollision(bossrockets,0)
 
 if level!=kshoplvl then _collectoncollision(coins,'coins') end -- kshoplvl is the shop, don't process coins
 
 if win then
  changedlevel=level~=nextlevel and level~=kshoplvl and nextlevel~=kshoplvl -- kshoplvl is the shop level. Don't renerate coins when entering the shop
  previouslevel=level
  level=nextlevel
  respawnpos=nil
  _reset()
  return
 end
 
 if dead then
  if btn_pressed and requirenoinput == false and inputfreeze<0 then
   changedlevel=false
   _reset()
  end -- if btn_pressed
 end -- if dead
end -- fn

-------- UI Functions ---------

function _buysiderockets()
 if inputfreeze>0 then return end
 if inventory.siderockets~=nil then return end
 paused=true
 
 if inventory.coins>=costs.siderockets then
  buyitem="siderockets"
  itemcost=costs.siderockets
  displaymodal("BUY FOR " .. costs.siderockets .. " COINS?",confirmbuy,cancelbuy)
 else
  displaymodal("YOU NEED " .. costs.siderockets .. " COINS\nTO BUY COOL ROCKETS",nil,nil)
 end
end

function _buyhat()
 if inputfreeze>0 then return end
 if inventory.hat~=nil then return end
 paused=true
 
 if inventory.coins>=costs.hat then
  buyitem="hat"
  itemcost=costs.hat
  displaymodal("BUY FOR " .. costs.hat .. " COINS? (BUT\nWHAT DOES IT DO?!?)",confirmbuy,cancelbuy)
 else
  displaymodal("YOU NEED " .. costs.hat .. " COINS\nTO BUY THE HAT",nil,nil)
 end
end

function confirmbuy()
 inventory[buyitem]=true
 inventory.coins-=itemcost
end

function cancelbuy()
 -- do we need to do anything here???
end

function displaymodal(msg,onconfirm,oncancel)
 modalstate={
  displaymessage=msg,
  onconfirm=onconfirm,
  oncancel=oncancel,
  confirmselected=true
 }
 requirenoinput=true
end

function handlemodalinput()
 if modalstate.displaymessage==nil then return end
 if requirenoinput==true then return end
  
 if modalstate.onconfirm~=nil and modalstate.oncancel~=nil then
  -- toggle between confirm and cancel
  if btn(0) then 
   modalstate.confirmselected=true
  elseif btn(1) then 
   modalstate.confirmselected=false
  elseif btn(4) then
   if modalstate.confirmselected then
    modalstate.onconfirm()
    modalstate.displaymessage=nil inputfreeze=30
   else
    modalstate.oncancel()
    modalstate.displaymessage=nil inputfreeze=30
   end -- modalstate.confirmselected
  end -- elseif btn(4)
 elseif modalstate.oncancel~=nil and btn(4) then
  modalstate.oncancel()
  modalstate.displaymessage=nil inputfreeze=30
 elseif btn(4) then
  if modalstate.onconfirm~=null then 
   modalstate.onconfirm() 
  end
  modalstate.displaymessage=nil inputfreeze=30
 end
end

-->8
--draw tab
-------------------------------
function _draw_objects(list)
 palt()
 local o,fr,flipx
 for o in all(list) do
  for x=o.x,o.x+o.w-1,8 do
   for y=o.y,o.y+o.h-1,8 do
    if o.palt ~= nil then
     palt(o.palt,true)
    else
     if o.pal1 ~= nil and o.pal2 != nil then
      pal(o.pal1, o.pal2)
     else
      pal()
      palt()
     end
    end
    
    fr = 0; -- frame for animation
    if (o.fr~=nil and o.dead==nil) fr=(frame/15)%o.fr -- don't animate dead things
    flipx=false
    if (o.flipx!=nil) flipx=o.flipx
    spr(o.spr+fr,x,y,1,1,flipx)
   end
  end
 end
end

function _draw()
 frame+=1
 local c1=8+((frame/5)%2)
 local c2=8+(((frame/5)+1)%2)
 cls ()
 
 if level~=kshoplvl then _draw_objects(coins) end
 _draw_objects(doors)
 
 if bottomrocket then
  spr(95,plr.x,plr.y+4)
 end
 if leftrocket and inventory.siderockets!=nil then
  spr(95,plr.x-4,plr.y)
 end
 if rightrocket and inventory.siderockets!=nil then
  spr(95,plr.x+4,plr.y)
 end
 
 _draw_objects(walls)
 _draw_objects(spikes)
 _draw_objects(sprites)
 
 for text in all(texts) do
  print(text.str,text.x,text.y,text.color)
 end
   
 _draw_objects(enemies)
 _draw_objects(bombs)
 
 palt()
 if dead then pal(9,6) end
 spr(96,plr.x,plr.y)
 pal()
 
 if inventory.hat!=nil then
  pal(0)
  spr(190,plr.x,plr.y)
  pal()
 end
 
 if _isbossdead() then
  rectfill(15,40,105,80,7)
  print("YAY. ROCKET DUDE\nHAS DEFEATED THE EVIL\nSKULL EMPIRE.\nTHANKS FOR PLAYING!!!",20,45,0)
 end
 
 if modalstate.displaymessage~=nil then
   rectfill(20,50,108,80,7)
   print(modalstate.displaymessage,24,54,0)
 
   if modalstate.onconfirm~=nil and modalstate.oncancel~=nil then
    if modalstate.confirmselected then
     print("[OK]",30,70,0) print("CANCEL",70,70,0)
    else
     print("OK",30,70,0) print("[CANCEL]",70,70,0)
    end
   elseif modalstate.oncancel~=nil then
    print("[CANCEL]",54,70,0)
   else
    print("[OK]",54,70,0)
   end
 end
  
 rectfill(30,0,96,4,0)
 print("LVL "..level,36,0,7)
 print("COINS "..inventory.coins,64,0,7)

end -- fn
------------------------------
__gfx__
00012000606660666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0666066606660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652206660666066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70660666066606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc07656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900090040405565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90090004005767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000702826007282060
a979979400e88000d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500602825006282050
a71991740e111800d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
2002821000028210202000000006822d02822222020220d000000000000000000000000000000000007665000076650005555555555555555555555055677655
0211111122111111022282100026cdcd1111110002200d0000000000000000000000000000000000075006500750065055666666666666666666665556555565
11ddcdcd01ddcdcd001111110216ddddddcdcddd21ddd00002000000000000000000000000000000065006500650000056676767676767676767766556677665
006ddddd106ddddd66ddcdcd0016dddd66666d0081cddd0022ddd000000000000000000000000000766666657666666556777777777777777777776556677665
006d5ddd006d5ddd600ddddd0015ddd066dddd001ddddd008dddd000002282000202820002222200766166657663666556777676767676767676776555677655
0065111d0065111d0005ddd00052111056d111111c66d1111dddd1000221166600211110002282dd766166657663666556766676666666666767766556555565
00520010005200100552211100520010052200000d6661001d66611100666c10011dddd000111110766666657666666556776756666666667577666556677665
0502001005020010500200100502001000502000000552221d666222666dddc066666666666dddd0655555556555555556766665555555555667766556677665
0028210020000000002821002200000002228200005000000000000000000000c0c6cc0000777700056650000000000056677665555575555566765555555555
02111110222821000211111002282100221116660205002002022210202221000cccccc0071111605600650007a00a7056776665565755665555555556677665
d21ddcd60111111021ddcdcd0111111000666c10022560220022822102282210cdd7d7d071111115607006000a9009a056677665565757676565565655555555
d1dd66660ddddcd0666ddddd0dddcdc0066dddcd101d5682011111111111111006ddddd071100115600006000000000056776665575757777576755757777775
00d66d00066dddd06066dd00066dddd05555dd0011ddd62206ddcdcd0ddcdcd00d665ddd71100115560065000000000056677665575756766557675675555557
202211000066dd00001221000066dd00021dd00000dd661260d5dddd6d5dddd000c5ccc071111115056694500a90000056776665565756666565565655677655
02000010002212000110020000221100200100000dd6dc116552ddd16522dd11005c00c0061111500000094507a0000056677665565755665555555556776665
0000000100012000000000200002100000100000d000c1105220011152220001050c00c000555500000000940000000056776665555575555567665556677665
0028226000000000628210000022000022000000222200001112000006822d0026822d0077777777002820000077770056776675555755555677666556776665
002222600028220026111100081d0000820d0000228110001112800026cdcd0016cdcd0000000000028e8200076566d056676756665575656577666556677665
061221600022222006dcdc00621d0000612d000011dcd00011dc600016dddd0006dddd000600600608e7e8007665666d56777667676575657667766555776655
06d11dd0061221160ddddd00611c0200611c0200d66665d5dddd656506dddd0006dddd000000000008eee8007665556d56677777777575757777766575555557
0dd1d1d00dd11ddd05dddd006cdd52016cdd5201dddd0d00ddd6060005ddd00005ddd00000500500028e82007666666d56667676767575756767666557777775
005111000dd1d1dd522dd0d0d66d5211d6665211211100001112000005221110052211100000000000282000076666d056666666666575656666666555555555
0015000000551110220100000d6652100dd6521020001000100020005002000150020001010100100028200000dddd0055666666665575656666665556677665
00105000001051000110000000dd510000dd51002000010010000200500000005000000000000000002820000000000005555555555755555555555055555555
062281100000000000400000202821000028210000282100000000000000000000000000000000007777777711111100566666660015d0005666666500000000
6d6dcdc00000122240900040111111102111111021111110030100000606330000003300000000007555555717777610655115510015d0006666666600000000
506dddd0000dd18090a040900ddbdbd00ddbdbd01ddbdbd003013300663138300031383000077000756556571777610065155551001d50006000000601111110
506dddd0000ddd11a00090a40666dddd1666dddd0666dddd00313830633313300633133000766700755555571776610051155551000d15006000000605555550
5006ddd000ddddd10405a00900d5dd0000d5dd0000d5dd00003313303331301363313013005665007555555717667610655115110001d5006000000605555550
00021111002d6dd00905004a005111000052110000521100033130131110000011100000000550007565565716116761655551510001d0006000000605155150
000200010222166d0a5000900520001005002000052201001110000010000000100000000000000075555557010016716555515100105d006000000605111150
0002000020011006dd1110a05020000050010000500001001000000000000000000000000000000077777777000001105111111500150d000000000005111150
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
__gff__
000101010181010001000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000c0000040400000000000000000000000000000000000000000000000000000000000c0c00000000000000000001000000000000000001000000
0000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c610385103451031510305102e5102d5101d6101d6101d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028630286301e6501a650186501664014640106400f6400c630096300663005630026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
010c00201125411255052550000000000112541125505255000000000011254112550525500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000705005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000205004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000005002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
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
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
010200002067021670316602f65031650336503365033650386503f6503f650326502f6502f650006002f6502e6502d650006002b650296502760024650216001e65019600116500a60000630066000161000010
010200000e6510c6530a6520b653056530000000000000000e6510c6530a652000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
011000000062200622006220062202622026220262202622006220062200622006220262202622026220262200622006220062200622026220262202622026220062200622006220062202622026220262202622
__music__
00 16 17 43 44
00 16 17 43 44
00 16 17 43 44
00 16 17 43 44
00 18 19 43 44
02 18 19 43 44
00 1a 42 43 44
01 1a 1b 43 44
00 1a 1b 43 44
00 1a 1c 43 44
00 1a 1c 43 44
02 1d 1e 43 44
01 1f 20 43 44
00 1f 21 43 44
00 1f 20 43 44
00 1f 21 43 44
00 22 23 43 44
02 1f 24 43 44
01 25 26 43 44
00 25 26 43 44
02 27 28 43 44
00 29 2a 43 44
03 2b 2c 43 44
04 2d 2e 43 44
04 2f 30 43 44
01 31 32 43 44
00 31 32 43 44
00 33 34 43 44
02 35 36 43 44
01 37 38 43 44
00 39 3a 43 44
00 37 3b 43 44
02 39 3b 43 44
03 3e 42 43 44
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
