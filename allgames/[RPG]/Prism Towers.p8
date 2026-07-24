pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
//main

debug=false

plx = 56
ply = 56
pls = 2
plhp = 5
plmaxhp = 5
platk = 1
plspr = 2
plmoney = 0

worldx = 0
worldy = -17
area = "town"

pole = 0
head = 0

lensgot=false
steelkeygot=false
forestkeygot=false
lavakeygot=false
glasskeygot=false

steellens=false
forestlens=false
lavalens=false

helmetgot=false
vinegot=false
tailgot=false
kinggot=false

wintimer=0

lsrpx = 100
lsrpy = 56
lsrd = 50
left = true

atkt = 30
animt = 0
started = false
shopping = false


function start()
 cls()
 print("press any button so start",20,ply-30)
 print("z to attack, x to interact",18,ply+30)
 print("use the arrowkeys to move",20,ply+45)
 bigspr(140,plx+5,ply-20)
 bigspr(6,plx+5,ply)
 if(btn(0) or btnp(1) or btnp(2) or
    btn(3) or btnp(4) or btnp(5))then
  started = true
  atkt=0
 end
end


function makepl()
 plmaxhp=5+pole

 if(left == false)then
  //right
  spr(plspr, plx+0, ply+0)
  spr(plspr+1, plx+8, ply+0)
  spr(plspr+16, plx+0, ply+8)
  spr(plspr+17, plx+8, ply+8)
 end
 
 if(left == true)then
  //left
  spr(plspr, plx+8, ply+0,1,1,true)
  spr(plspr+1, plx+0, ply+0,1,1,true)
  spr(plspr+16, plx+8, ply+8,1,1,true)
  spr(plspr+17, plx+0, ply+8,1,1,true)
 end
end


function makeworld()
 if(area == "town")then
  maketown()
 end
 if(area == "house")then
  makeshop()
 end
 if(area == "castle")then
  makecastle()
 end
 if(area == "steel" and floor == 0)then
  makesteel0()
 elseif(area == "steel" and floor > 0 and floor < 8)then
  makesteel1to6()
 end
 if(area == "forest" and floor == 0)then
  makeforest0()
 elseif(area == "forest" and floor > 0 and floor < 9)then
  makeforest1to7()
 end
 if(area == "lava" and floor == 0)then
  makelava0()
 elseif(area == "lava" and floor > 0 and floor < 10)then
  makelava1to8()
 end
 if(area == "glass" and floor == 0)then
  makeglass0()
 elseif(area == "glass" and floor > 0 and floor < 11)then
  makeglass1to9()
 end
 
 if(floor>0)then
  if(worldx > 67)then
   worldx = 67
  end
  if(worldx < -75)then
   worldx = -75
  end
  if(worldy > 80)then
   worldy = 80
  end
  if(worldy < -57)then
   worldy = -57
  end
 end
end


function maketown()
 //water
 maketiles(worldx-21*8,worldy-29*8,43,49,133)
 
 //grass
 maketiles(worldx-15*8,worldy-15*8,31,29,128)
 
 //bridge
 maketiles(worldx-1*8,worldy-21*8,3,5,131)
 maketiles(worldx-21*8,worldy-3*8,43,1,131)
 maketiles(worldx-0*8,worldy+3*8,1,35,131)
 
 //house1
 house(worldx,worldy+2*8)
 
 //house2
 house(worldx+14*8,worldy+2*8)
 
 //house3
 house(worldx,worldy+14*8)
 
 //prismshop
 house(worldx+14*8,worldy+14*8)
 bigspr(166,worldx+7*8,worldy+5*8)
 
 //road
 maketiles(worldx-1*8,worldy-15*8,3,29,129)
 maketiles(worldx-15*8,worldy-3*8,31,1,129)
 maketiles(worldx-7*8,worldy+9*8,15,1,129)
 
 //castle entrance
 maketiles(worldx-3*8,worldy-23*8,7,1,128)
 
 //castle
 maketiles(worldx-15*8,worldy-29*8,31,5,134)
 bigspr(160,worldx-1*8,worldy-25*8)
 bigspr(160,worldx+1*8,worldy-25*8)
 
 //people
 bigspr(164,worldx+13*8,worldy+9*8)
 bigspr(226,worldx-14*8,worldy-13*8)
 
 if(worldx <-29 and worldy<5)then
  if(helmetgot==false)then
   dialogue(4)
  elseif(helmetgot==true)then
   dialogue(7)
  end
 end
 if(worldx >140 and worldy>130)then
  if(tailgot==false)then
   dialogue(5)
  elseif(tailgot==true)then
   dialogue(8)
  end
 end
 
 if(worldy > 241)then
  area = "castle"
  worldx = 12
  worldy = -24
 end
 if(worldx > 180)then
  area = "steel"
  worldx = 26
  worldy = 24
 end
 if(worldx < -67)then
  area = "forest"
  worldx = 96
  worldy = 24
 end
 if(worldy < -48)then
  area = "lava"
  worldx = 64
  worldy = 64
 end
 
 if(worldx < 16 and worldy < 16 and
    worldx > -16 and worldy > -16)then
  area = "house"
  worldx = -52
  worldy = 32
 end
 
 floor = 0
end


function makecastle() 
 //castle floors & floor
 maketiles(worldx-3*8,worldy-5*8,18,18,136)
 maketiles(worldx-1*8,worldy-3*8,14,14,138)
 //castle
 bigspr(160,worldx+4+4*8,worldy+12*8)
 bigspr(160,worldx+4+6*8,worldy+12*8)
 bigspr(160,worldx-3*8,worldy+2*8)
 bigspr(160,worldx+14*8,worldy+2*8)
 bigspr(174,worldx+4+5*8,worldy-3*8)
 bigspr(172,worldx+4+5*8,worldy-3*8)
 bigspr(168,worldx+12*8,worldy+3*8)
 bigspr(168,worldx-1*8,worldy+3*8)
 
 if(worldy>40)then
  if(forestlens==true and lavalens==true and steellens==true)then
   dialogue(10)
  elseif(steelkeygot==true)then
   dialogue(9)
  else
   dialogue(1)
  end
 end
 if(worldx>40)then
  dialogue(2)
 end
 if(worldx<-18)then
  dialogue(3)
 end
 
 if(worldx > 67)then
   worldx = 67
 end
 if(worldx < -43)then
   worldx = -43
 end
 if(worldy > 80 and steellens==true and forestlens==true and lavalens==true)then
  area = "glass"
  worldx = 64
  worldy = -6
 elseif(worldy > 80)then
  worldy = 80
 end

 if(worldy < -24)then
  area = "town"
  worldx = 56
  worldy = 239
 end
end


function makesteel0()
 //water
 maketiles(worldx-21*8,worldy-29*8,43,49,133)
 
 //grass
 maketiles(worldx-5*8,worldy-5*8,9,10,128)
 
 //bridge
 maketiles(worldx+5*8,worldy+4*8,10,1,131)
 
 //tower
 maketiles(worldx-3*8,worldy-5*8,5,5,132)
 bigspr(160,worldx-1*8,worldy-1*8)
 
 if(worldx > 99)then
  worldx = 99
 end
 if(worldy < 24)then
  worldy = 24
 end
 
 if(worldx < 22.5)then
  area = "town"
  worldx = 178
  worldy = 80
 elseif(worldy > 48 and steelkeygot==true)then
  floor += 1
  worldx = -59
  worldy = -42
 elseif(worldy > 48)then
  worldy=48
 end
end

function makeforest0()
 //water
 maketiles(worldx-21*8,worldy-29*8,43,49,133)
 
 //grass
 maketiles(worldx-5*8,worldy-5*8,9,10,128)
 
 //bridge
 maketiles(worldx-16*8,worldy+4*8,10,1,131)
 
 //tower
 maketiles(worldx-3*8,worldy-5*8,5,5,147)
 bigspr(160,worldx-1*8,worldy-1*8)
 
 if(worldx < 28)then
  worldx = 28
 end
 if(worldy < 24)then
  worldy = 24
 end
 
 if(worldx > 100)then
  area = "town"
  worldx = -65
  worldy = 80
 elseif(worldy > 48 and forestkeygot==true)then
  floor += 1
  worldx = -59
  worldy = -42
 elseif(worldy > 48)then
  worldy=48
 end
end

function makelava0()
 //water
 maketiles(worldx-21*8,worldy-29*8,43,49,133)
 
 //grass
 maketiles(worldx-5*8,worldy-1*8,9,10,128)
 
 //bridge
 maketiles(worldx-1*8,worldy-10*8,1,8,131)
 
 //tower
 maketiles(worldx-3*8,worldy+4*8,5,5,144)
 bigspr(160,worldx-1*8,worldy+4*8)
 
 if(worldx > 99)then
  worldx = 99
 end
 if(worldx < 29)then
  worldx = 29
 end
 
 if(worldy > 64)then
  area = "town"
  worldx = 56
  worldy = -48
 elseif(worldy < 40 and lavakeygot==true)then
  floor += 1
  worldx = -59
  worldy = -42
 elseif(worldy < 40)then
  worldy=40
 end
end


function makeglass0()
 //water
 maketiles(worldx-21*8,worldy-29*8,43,49,133)
 
 //grass
 maketiles(worldx-5*8,worldy-1*8,9,10,128)
 
 //bridge
 maketiles(worldx-1*8,worldy+10*8,1,8,131)
 
 //tower
 maketiles(worldx-3*8,worldy-5*8,5,5,149)
 bigspr(160,worldx-1*8,worldy-1*8)
 
 if(worldx > 99)then
  worldx = 99
 end
 if(worldx < 29)then
  worldx = 29
 end
 
 if(worldy <-8)then
  area = "castle"
  worldx = 56
  worldy = 78
 elseif(worldy > 48 and glasskeygot==true)then
  floor += 1
  worldx = -59
  worldy = -42
 elseif(worldy > 48)then
  worldy = 48
 end
end


function makeshop()
 maketiles(worldx+8*8,worldy+-8*8,12,12,137)

 if(worldy < 32)then
  area = "town"
  worldx = 0
  worldy = -17
 end
  
 bigspr(162,worldx+106,worldy-54)
 bigspr(196,worldx+106,worldy-52)
 bigspr(192,worldx+132,worldy-7)
 bigspr(194,worldx+124,worldy-7)
 bigspr(228,worldx+148,worldy-7)
 
 if(worldy > 80)then
  shopping = true
  shop()
 end
 
 if(worldy <80 and worldx<-70)then
  if(vinegot==false)then
   dialogue(11)
  elseif(vinegot==true)then
   dialogue(12)
  end
 end
 
 if(worldx < -99)then
  worldx = -99
 end
 if(worldx > -5)then
  worldx = -5
 end
end


function maketiles(posx,posy,w,h,s)
 for x=0,w do
  for y=0,h do
   spr(s,posx+x*8,posy+y*8)
  end
 end
end


function house(housex,housey)
 for x=0,5 do
  for y=0,3 do
   spr(131,housex-9*8+x*8,housey-9*8+y*8)
  end
 end
 
 for x=0,5 do
  for y=0,1 do
   spr(136,housex-9*8+x*8,housey-11*8+y*8)
  end
 end
 
 doorspr = 160
 doorx = housex-7*8
 doory = housey-7*8
 
 bigspr(doorspr,doorx,doory)
end


function bigspr(ogspr, ogx, ogy, ogflip)
 if(ogflip==true)then
  spr(ogspr, ogx+8, ogy+0,1,1,ogflip)
  spr(ogspr+1, ogx+0, ogy+0,1,1,ogflip)
  spr(ogspr+16, ogx+8, ogy+8,1,1,ogflip)
  spr(ogspr+17, ogx+0, ogy+8,1,1,ogflip)
 else
  spr(ogspr+1, ogx+8, ogy+0)
  spr(ogspr, ogx+0, ogy+0)
  spr(ogspr+17, ogx+8, ogy+8)
  spr(ogspr+16, ogx+0, ogy+8)
 end
end


function runani()
 if(animt > 3)then
  if(plspr < 8)then
   plspr += 2
  else
   plspr = 2
  end
  animt = 0
 else
  animt+=1
 end
end


function attack(wtype)
 platk = head+1

 if(atkt < 2 and wtype == "spear")then
  makespear()
  atkt += 1
 end
 
 if(atkt < 2 and wtype == "prism")then
  makeprism()
  atkt += 1
 end
end


function makespear()
 if(left == false)then
  //right
  //pole
  spr(48+pole,plx+0,ply+7)
  spr(48+pole,plx+8,ply+7)
  spr(48+pole,plx+16,ply+7)
  //head
  spr(32+head,plx+24,ply+7)
 end
 
 if(left == true)then
  //left
  //pole
  spr(48+pole,plx+8,ply+7,1,1,true)
  spr(48+pole,plx-0,ply+7,1,1,true)
  spr(48+pole,plx-8,ply+7,1,1,true)
  //head
  spr(32+head,plx-16,ply+7,1,1,true)
 end
end


function makeprism()
 if(left == false)then
  //right
  spr(63,plx+6,ply+4)
  line(plx+11,ply+8,lsrpx+6,worldy+lsrpy,8)
  lsrpx = 87 + lsrd
 end
 
 if(left == true)then
  //right
  spr(63,plx+2,ply+4,1,1,true)
  line(plx+4,ply+8,lsrpx+6,worldy+lsrpy,8)
  lsrpx = 28 - lsrd
 end
 
 if(btn(3)) then
	 lsrpy += 5
	elseif(btn(2)) then
	 lsrpy -= 5
 end
end


function _draw()
 if(started==false)then
 start()
 else
 cls()
 makeworld()
 if(plhp < 1)then
  plspr = 12
 end
 if(plhp < 0)then
  plhp = 0
 end
	makepl()
	
	if(plhp > 0 and kinggot==false)then
	if(plspr == 10 and atkt > 0)then
  plspr = 2
  atkt = 0
 end
	
	if(shopping == false)then
	 if(btn(4) and plspr != 0) then
	  plspr = 10
   animt = 0
   atkt = 0
	  attack("spear")
	 end
	
	 if(btn(5) and plspr != 0 and lensgot==true) then
	  plspr = 10
   animt = 0
   atkt = 0
	  attack("prism")
	 elseif(btn(5) and lensgot==false)then
	  dialogue(0)
	 end
	
	 if(btn(1) and atkt == 0) then
	  worldx-=pls
	  runani()
	  left = false
	 elseif(btn(0) and atkt == 0) then
	  worldx+=pls
	  runani()
	  left = true
	 elseif(btn(3) and atkt == 0) then
	  worldy-=pls
	  runani()
	 elseif(btn(2) and atkt == 0) then
   worldy+=pls 
   runani()
  end
  
 elseif(shopping == true)then
  menucontrol()
 end
 
 elseif(kinggot==true)then
  if(wintimer<250)then
   dialogue(13)
   bigspr(170,plx+25,ply)
   wintimer+=1
  elseif(wintimer<500)then
   dialogue(14)
   bigspr(170,plx+25,ply)
   wintimer+=1
  else
   cls()
   print("sir zelf",plx-7,ply-7)
   bigspr(42,plx,ply)
   dialogue(15)
  end
 else
  if(btnp(5))then
   rectfill(0,0,128,128,0)
   plhp = plmaxhp
   pls = 2
   plspr = 2
   plmoney /= 2
   plmoney=flr(plmoney)
   worldx = 0
   worldy = -17
   area = "town"
   emaketime=0 
  end
 end
 if(kinggot==false)then
  ui()
 end
 end
end
-->8
//towers

floor = 0
emaketime = 0

function makesteel1to6()
//steeltower
 towerbasics(132,130,7)
 if(floor==1)then
  enemy("cupblin",1)
 elseif(floor==2)then
  enemy("cupblin",2)
 elseif(floor==3)then
  enemy("eyebob",1)
 elseif(floor==4)then
  enemy("eyebob",2)
 elseif(floor==5)then
  enemy("bekon",1)
 elseif(floor==6)then
  enemy("shadowlight",1)
 end
 emaketime+=1
end

function makeforest1to7()
//steeltower
 towerbasics(147,146,8)
 if(floor==1)then
  enemy("cupblin",2)
 elseif(floor==2)then
  enemy("eyebob",2)
 elseif(floor==3)then
  enemy("nindipede",1)
 elseif(floor==4)then
  enemy("bekon",2)
 elseif(floor==5)then
  enemy("nindipede",1)
 elseif(floor==6)then
  enemy("cupblin",3)
 elseif(floor==7)then
  enemy("sabus",1)
 end
 emaketime+=1
end

function makelava1to8()
//lavatower
 towerbasics(145,144,8)
 if(floor==1)then
  enemy("cupblin",3)
 elseif(floor==2)then
  enemy("eyebob",3)
 elseif(floor==3)then
  enemy("nindipede",1)
 elseif(floor==4)then
  enemy("cupblin",4)
 elseif(floor==5)then
  enemy("nindipede",1)
 elseif(floor==6)then
  enemy("bekon",3)
 elseif(floor==7)then
  enemy("devtail",1)
 end
 emaketime+=1
end

function makeglass1to9()
//glasstower
 towerbasics(149,148,9)
 if(floor==1)then
  enemy("eyebob",3)
 elseif(floor==2)then
  enemy("cupblin",4)
 elseif(floor==3)then
  enemy("nindipede",2)
 elseif(floor==4)then
  enemy("bekon",3)
 elseif(floor==5)then
  enemy("nindipede",3)
 elseif(floor==6)then
  enemy("shadowlight",1)
 elseif(floor==7)then
  enemy("sabus",1)
 elseif(floor==8)then
  enemy("devtail",1)
 elseif(floor==9)then
  enemy("fallenbanana",1)
 end
 emaketime+=1
end

function towerbasics(spr1,spr2,maxfloor)
 //floor
 if(floor==maxfloor)then
  maketiles(worldx-16*8,worldy-16*8,50,50,238)
  maketiles(worldx-1*8,worldy-3*8,18,18,spr2)
  bigspr(224,worldx+16*8,worldy+14*8) 
  if(area=="glass")then
   bigspr(140,worldx+8*8,worldy+5*8)
   line(worldx+9*8,worldy+6*8,worldx+230,worldy+200,8)
   line(worldx+9*8,worldy+6*8,worldx+70,worldy+200,8)
   line(worldx+9*8,worldy+6*8,worldx-160,worldy+200,8)
   line(worldx+9*8,worldy+6*8,worldx+90,worldy-160,11)
   line(worldx+9*8,worldy+6*8,worldx+80,worldy-160,12)
   line(worldx+9*8,worldy+6*8,worldx+70,worldy-160,10)
   line(worldx+9*8,worldy+6*8,worldx+60,worldy-160,10)
  else
   bigspr(142,worldx+8*8,worldy+5*8)
   if((area=="steel" and steellens==true)or(area=="forest" and forestlens==true)or(area=="lava" and lavalens==true))then
    line(worldx+9*8,worldy+6*8,worldx+75,worldy-100,8)
   end
   dialogue(6)
  end
 else
  maketiles(worldx-3*8,worldy-5*8,22,22,spr1)
  maketiles(worldx-1*8,worldy-3*8,18,18,spr2)
  if(floor==2 or floor==4 or floor==6 or floor==8 or floor==10)then
   bigspr(224,worldx+16*8,worldy-3*8)
   bigspr(224,worldx+-1*8,worldy+14*8)
  else
   bigspr(224,worldx-1*8,worldy-3*8)
   bigspr(224,worldx+16*8,worldy+14*8)
  end 
 end
  
  if(floor==maxfloor)then
   if(worldx < -60 and worldy < -40)then
    floor -= 1
    worldx = 64
    worldy = 48
    emaketime=0
   end
  elseif(floor==2 or floor==4 or floor==6 or floor==8 or floor==10)then
   if(worldx < -60 and worldy > 64 and floor<maxfloor)then
    floor += 1
    worldx = -73
    worldy = -38
    emaketime=0
   end
 
   if(worldx > 51 and worldy < -42 and floor<=maxfloor)then
    floor -= 1
    worldx = 64
    worldy = 48
    emaketime=0
   end

  else
   if(worldx < -60 and worldy < -40 and floor<=maxfloor)then
    floor -= 1
    worldx = -60
    worldy = 48
    emaketime=0
   end
 
   if(worldx > 51 and worldy > 64 and floor<maxfloor)then
    floor += 1
    if(floor>1)then
     worldx = 64
     worldy = -42
    else
     worldx = 64
     worldy = 48
    end
    emaketime=0
   end
  end
end
-->8
//creatures
//plx > x+36 or plx < x-20 or ply > y+36 or ply < y-20


//new
function enemy(etype,level)
 if(emaketime<1)then
  if(etype=="cupblin")then
   x=80
   y=0
   sprite=6
   hp=3*level
   atk=1
   spd=1
   kback=5
   prize=flr(3+0.5*(level-0.5))
   ani=0
   atktime=50
  elseif(etype=="eyebob")then
   x=80
   y=0
   sprite=68
   hp=5*level
   atk=2
   spd=0.75
   kback=5
   prize=flr(4+0.5*(level-0.5))
   ani=0
   atktime=50
  elseif(etype=="bekon")then
   x=80
   y=0
   sprite=72
   hp=7+level*2
   atk=4
   spd=1.15
   kback=5
   prize=flr(8+0.5*(level-0.5))
   ani=0
   atktime=50
  elseif(etype=="nindipede")then
   x=80
   y=0
   sprite=96
   hp=8+level*3
   atk=3
   spd=1.1
   kback=5
   prize=flr(7+0.5*(level-0.5))
   ani=0
   atktime=50
  elseif(etype=="shadowlight")then
   x=80
   y=0
   sprite=76
   hp=20
   atk=2
   spd=1.05
   kback=20
   prize=15
   ani=0
   atktime=50
  elseif(etype=="sabus")then
   x=80
   y=0
   sprite=100
   hp=40
   atk=3
   spd=1.2
   kback=10
   prize=25
   ani=0
   atktime=50
  elseif(etype=="devtail")then
   x=80
   y=0
   sprite=104
   hp=60
   atk=4
   spd=1
   kback=15
   prize=35
   ani=0
   atktime=50
  elseif(etype=="fallenbanana")then
   x=0
   y=0
   sprite=232
   hp=100
   atk=4
   spd=1
   kback=50
   prize=100
   ani=0
   atktime=50
  end
 end
 
 xe=worldx+x
 ye=worldy+y

 bigspr(sprite,xe,ye,facedir)
 
 if(hp > 0)then
 print(etype,xe-5,ye-10,6+level) 
  if(plhp > 0)then //and (btn(0)or btn(1)or btn(2)or 
                   //btn(3)or btn(4)or btn(5)))then
   if(plx > xe)then x += spd
    facedir = true end
   if(plx < xe)then x -= spd
    facedir = false end
   if(ply > ye)then y += spd end
   if(ply < ye)then y -= spd end

   if(plx < xe+16 and
      plx > xe-16 and
      ply < ye+16 and
      ply > ye-16)then
    if(etype=="cupblin")then
     sprite=66
    elseif(etype=="eyebob")then
     sprite=70
    elseif(etype=="bekon")then
     sprite=74
    elseif(etype=="nindipede")then
     sprite=98
    elseif(etype=="shadowlight")then
     sprite=78
    elseif(etype=="devtail")then
     sprite=106
    elseif(etype=="sabus")then
     sprite=102
    elseif(etype=="fallenbanana")then
     sprite=234
    end
    
   if(atktime>20)then
    plhp-=atk
    atkt=0
    atktime=0
   end
   end
   if(atktime<50)then
    atktime+=1
    if(atktime<5)then
     if(plx+8<x)then
      worldx+=kback
     elseif(plx>x)then
      worldx-=kback
     elseif(ply<y)then
      worldy+=kback
     elseif(ply>y)then
      worldy-=kback
     end
    end
   end
   
   if(atktime>15)then
    if(etype=="cupblin")then
     sprite=64
    elseif(etype=="eyebob")then
     sprite=68
    elseif(etype=="bekon")then
     sprite=72
    elseif(etype=="nindipede")then
     sprite=96
    elseif(etype=="shadowlight")then
     sprite=76
    elseif(etype=="devling")then
     sprite=104
    elseif(etype=="sabus")then
     sprite=100
    elseif(etype=="fallenbanana")then
     sprite=232
    end
   end
 end
 else
  if(atktime<15)then
   sprite=110
   atktime+=1
   if(atktime==14)then
    pickup("money",prize,xe+5,ye+5,atktime)
   end
  else
   atktime=15
   sprite=14
   if(etype=="shadowlight" and area=="steel")then
    pickup("helmet",prize,xe+5,ye+5,atktime)
   elseif(etype=="sabus" and area=="forest")then
    pickup("vine",prize,xe+5,ye+5,atktime)
   elseif(etype=="devtail" and area=="lava")then
    pickup("tail",prize,xe+5,ye+5,atktime)
   elseif(etype=="fallenbanana" and area=="glass")then
    pickup("king",prize,xe+5,ye+5,atktime)
   else
    pickup("money",prize,xe+5,ye+5,atktime)
   end
  end
 end
 
 if(btnp(4) and plhp>0 and left==false and hp>0 and plspr!=0 and
  plx+24 < xe+16 and
  plx+32 > xe and
  ply+8 < ye+16 and
  ply+8 > ye)then
   hp -= platk
   sprite=108
   if(hp<1)then
    atktime=0
   end
 elseif(btnp(4) and plhp>0 and left==true and hp>0 and plspr!=0 and
  plx-16 < xe+16 and
  plx-16 > xe-8 and
  ply+8 < ye+16 and
  ply+8 > ye)then
   hp -= platk
   sprite=108
   if(hp<1)then
    atktime=0
   end
 end
 
 if(atktime<10 and hp>0)then
  plspr=0
 end
 if(debug==true)then
  print(xe,100,7)
  print(ye,100,14)
  print(atktime,100,28)
  print(sprite,100,21)
 end
end
-->8
//shop

cursorx = 3
cursory = 83
menu = 0

function shop()
 rect(0,80,127,127,6)
 rectfill(1,81,126,126,0)
 
 if(menu == 0)then
  print("spear heads",10,85,3)
  print("spear pole",10,95)	
  print("food",10,105)
  print("exit",10,115)		
 end
 
 if(menu == 1)then
  print("10g tin head +2 atk",10,85,5)
  print("20g copper head +3 atk",10,95)	
  print("30g nickel head +4 atk",10,105)
  print("next",10,115)		
 end
 
 if(menu == 2)then
  print("40g bronze head +5 atk",10,85,5)
  print("50g ir0n head +6 atk",10,95)	
  print("60g obsidian head+7 atk",10,105)
  print("next",10,115)		
 end
 
 if(menu == 3)then
  print("70g jade head +8 atk",10,85,5)
  print("80g imperial jade head +9 atk",10,95)	
  print("90g blue jade head +10 atk",10,105)
  print("next",10,115)		
 end
 
 if(menu == 4)then
  print("10gspruce pole +1 maxhp",10,85,9)
  print("20g maple pole +2 maxhp",10,95)	
  print("30g willow pole +3 maxhp",10,105)
  print("next",10,115)		
 end
 
 if(menu == 5)then
  print("40g cherry pole +4 maxhp",10,85,9)
  print("50g pine pole +5 maxhp",10,95)	
  print("60g oak pole +6 maxhp",10,105)
  print("next",10,115)		
 end
 
 if(menu == 6)then
  print("70g ash pole +7 maxhp",10,85,9)
  print("80g black alder pole +8 maxhp",10,95)	
  print("90g lingumvitae pole +9 maxhp",10,105)
  print("next",10,115)		
 end
 
 if(menu == 7)then
  print("2g bread +1 hp",10,85,9)
  print("6g steak +3 hp",10,95)	
  print("10g cake +5 hp",10,105)
  print("drinks",10,115)		
 end
 
 if(menu == 8)then
  print("10g apple juice spd+1/4",10,85,9)
  print("20g grape juice spd+1/2",10,95)	
  print("30g lemon juice spd+1",10,105)
  print("foods",10,115)	
 end
 
 if(menu==9)then
  print("i went over budget and",10,85,9)
  print("i have to sell my stuff",10,95)	
  print("oops",10,105)
  print("back",10,115)
 end
 
 cursormark()
end

function menucontrol()
 if(plmoney<0 and debug==false)then
  menu=9
 end

 if(btnp(4)) then
	 if(cursory==83 and menu==0)then
	  menu=1
	  elseif(cursory!=113 and (menu==1 or menu==2 or menu==3))then
	   head=((cursory-73)/10)+menu*3-3
	   plmoney-=(((cursory-73)/10)+menu*3-3)*10
   elseif(cursory!=113 and (menu==4 or menu==5 or menu==6))then
	   pole=((cursory-73)/10)+menu*3-12
	   plmoney-=(((cursory-73)/10)+menu*3-12)*10
   elseif(menu==7)then
    if(cursory==83)then
     plhp+=1
     plmoney-=2
    elseif(cursory==93)then
     plhp+=3
     plmoney-=6
    elseif(cursory==103)then
     plhp+=5
     plmoney-=10
    end
   elseif(menu==8)then
    if(cursory==83)then
     pls=2
     pls+=0.25
     plmoney-=10
    elseif(cursory==93)then
     pls=2
     pls+=0.5
     plmoney-=20
    elseif(cursory==103)then
     pls=2
     pls+=1
     plmoney-=30
    end
   end
	 if(cursory==93 and menu==0)then
	  menu=4
	 end
	 if(cursory==103 and menu==0)then
	  menu=7
	 end
	 if(cursory==113)then
	  if(menu==3)then
	   menu=1
	  elseif(menu==6) then
	   menu=4
	  elseif(menu==8) then
	   menu=7
	  elseif(menu==7) then
	   menu=8
	  elseif(menu==9) then
	   head=0
    pole=0
    plmoney=0	
	   menu=0
	   pls=2
	  elseif(menu==0)then
	   shopping = false
	   worldy-=6
   else
 	  menu+=1
 	 end
	 end
	elseif(btnp(5)) then
	 if(menu==9)then 
	  pole=0
	  head=0
	  money=0
	 end
	 menu=0
	elseif(btnp(2) and cursory >= 85) then
	 cursory-=10
	elseif(btnp(3) and cursory <= 105) then
  cursory+=10 
 end
end


function cursormark()
 spr(48+pole,cursorx-3,cursory)
 spr(32+head,cursorx,cursory)
end
-->8
//pickups

function pickup(ptype,amnt,x,y,timer)
 if(timer<15)then
  pickedup=false
 end
 if(pickedup==false)then
  if(ptype=="money")then
   spr(246,x,y)
  elseif(ptype=="helmet")then
   spr(60,x,y)
  elseif(ptype=="vine")then
   spr(61,x,y)
  elseif(ptype=="tail")then
   spr(62,x,y)
  elseif(ptype=="king")then
   bigspr(170,x,y)
  end
  if(plx < x+6 and
     plx > x-16 and
     ply < y+7 and
     ply > y-16)then
   if(ptype=="money")then
    plmoney+=amnt
   elseif(ptype=="helmet")then
    helmetgot=true
    plmoney+=amnt
   elseif(ptype=="vine")then
    vinegot=true
    plmoney+=amnt
   elseif(ptype=="tail")then
    tailgot=true
    plmoney+=amnt
   elseif(ptype=="king")then
    kinggot=true
   end
   pickedup=true
  end
 end
end
-->8
//dialogue

function dialogue(lognumber)
 if(btn(5) or kinggot==true)then
  //zelf
  if(lognumber==0)then
   text1="i was sent here to help the"
   text2="king who was kidnapped and had"
   text3="his people frozen in place. i"
   text5="northern part of the town. i"
   text4="think the castle is in the"
   text6="should go meet the princess."
  end
 
  //princess dumb dumb
  if(lognumber==1)then
   text1="what took you so long? hmph it"
   text2="was not easy to send a messan-"
   text3="ger to get some help from our"
   text4="allies. take this lens to talk"
   text5="to my people. get keys, climb"
   text6="towers and activate the lenses."
   lensgot=true
  end
  
  //guard
  if(lognumber==2 and lensgot==true)then
   text1="finally some back up! this has"
   text2="been the worst week of my life."
   text3="have this key to the steel"
   text4="tower. just go over the western"
   text5="bridge. be careful and be wary"
   text6="of the monsters!"
   steelkeygot=true
  end
  
  if(lognumber==3)then
   text1="if you need to recover health"
   text2="or upgrade your weaponry visit"
   text3="the store in the southern"
   text4="part of the town. good luck"
   text5="on your quest!"
   text6=""
  end
  
  //villager
  if(lognumber==4)then
   text1="you came to save us? i can give"
   text2="you the key to the eastern"
   text3="forest tower if you bring me"
   text4="the helmet of the shadowlight."
   text5="it is the boss of the steel"
   text6="tower. please help us."
  end
  
  //vilger kid
  if(lognumber==5)then
   text1="hey mister! i want you to"
   text2="bring me a flaming tail."
   text3="why? im not going to tell you"
   text4="mister! you might find one"
   text5="in the southern tower."
   text6=""
  end
  
  //lens
  if(lognumber==6)then
   text1=""
   text2=""
   text3="    the giant lens has been"
   text4="           activated"
   text5=""
   text6=""
   if(area=="steel")then
    steellens=true
   elseif(area=="forest")then
    forestlens=true
   elseif(area=="lava")then
    lavalens=true
   end
  end
  
  if(lognumber==7)then
   text1="thank you for bringing me"
   text2="the helmet. take the forest"
   text3="tower key. go east over the"
   text4="bridge. yahoo!"
   text5=""
   text6=""
   forestkeygot=true
  end
  
  if(lognumber==8)then
   text1=""
   text2="oh finally! thank you"
   text3="mister! now i can make a"
   text4="flamingsword. you can have"
   text5="this key to the glass tower."
   text6=""
   glasskeygot=true
  end
  
  if(lognumber==9)then
   text1="you got a key? well climb"
   text2="the tower and activate"
   text3="the giant lenses. now git!"
   text4="my father will not save"
   text5="himself. go!"
   text6=""
  end
  
  if(lognumber==10)then
   text1="most imprssive! you activated"
   text2="all the lenses. well now you"
   text3="can walk through the back wall"
   text4="of this castle and enter the"
   text5="glass tower. now go and save"
   text6="my father peasent boy!"
  end
  
  if(lognumber==11)then
   text1="oh! you came here to save us?"
   text2="could you please bring me the"
   text3="vine of the sabus. i need it"
   text4="for medicine. i you do, i'll"
   text5="give you the key to the"
   text6="southern tower."
  end
  
  if(lognumber==12)then
   text1="thank you very much! take the"
   text2="key to the lava tower. i hope"
   text3="you can unfreeze us soon. i"
   text4="have been waiting to drink my"
   text5="tea for a week."
   text6=""
   lavakeygot=true
  end
  
  if(lognumber==13)then
   text1="is the banana dead? thank you"
   text2="kind boy! you saved me and my"
   text3="country. i hope i can repay you"
   text4="soon. let us discuss it later."
   text5="i am sorry if my people caused"
   text6="trouble. they can be needy."
  end
  
  if(lognumber==14)then
   text1=""
   text2="uh, no not at all sir. i am"
   text3="happy to help you and your"
   text4="people. i can guide you back "
   text5="to your castle sir."
   text6=""
  end
  
  if(lognumber==15)then
   text1=""
   text2=""
   text3="  you saved the land and got"
   text4="   promoted in rank. good job"
   text5="           !the end!"
   text6=""
  end
  
  //text box
  rect(0,80,127,127,6)
  rectfill(1,81,126,126,0)
  print(text1,3,83,7)
  print(text2,3,90,7)
  print(text3,3,97,7)
  print(text4,3,104,7)
  print(text5,3,111,7)
  print(text6,3,118,7)
 end
end
-->8
function ui()
  if(debug==true)then
  print(worldx,0,0,7)
  print(worldy,0,10)
  print(floor,0,20)
  print(plmoney,0,27,10)
  print(head,0,34,8)
  print(pole,0,41,8)
  print(plhp,0,48,14)
  print(atkt,0,55,14)
  if(plmoney<0)then
   plmoney=0
  end
  
 
 //no debug
 else
  if(plhp>plmaxhp)then
   plhp=plmaxhp
  end
  print(plhp,3,7,14)
  if(plhp<10)then
   print("/",7,7,7)
   print(plmaxhp,12,7,14)
  elseif(plhp>9)then
   print("/",11,7,7)
   print(plmaxhp,16,7,14)
  end
  print("g:",3,14,10)
  print(plmoney,11,14,10)
  if(floor>0)then
   print("f:",3,22,10)
   print(floor,11,22,10)
  end
 end
  //keys
  if(steelkeygot==true)then
   spr(44,116,4)
  end
  if(forestkeygot==true)then
   spr(45,116,14)
  end
  if(lavakeygot==true)then
   spr(46,116,24)
  end
  if(glasskeygot==true)then
   spr(47,116,34)
  end
  //boss items
  if(helmetgot==true)then
   spr(60,106,4)
  end
  if(vinegot==true)then
   spr(61,106,14)
  end
  if(tailgot==true)then
   spr(62,106,24)
  end
end
__gfx__
0008888888888000000cccccccccc000000cccccccccc000000cccccccccc000000cccccccccc000000cccccccccc00000000000000000000000000000000000
008cccccccccc800000cccccccccc000000cccccccccc000000cccccccccc000000cccccccccc000000cccccccccc00000000000000000000000000000000000
008cccccccccc800000ccffcfccfc000000ccffcfccfc000000ccffcfccfc000000ccffcfccfc000000ccffcfccfc00000000000000000000000000000000000
008ccffcfccfc800000ff71ff17ff000000ff71ff17ff000000ff71ff17ff000000ff71ff17ff000000ffffffffff00000000000000000000000000000000000
008ff11ff11ff800000ff71ff17ff000000ff71ff17ff000000ff71ff17ff000000ff71ff17ff000000ff55ff55ff00000000000000000000000000000000000
008ffffffffff800000ffffffffff000000ffffffffff000000ffffffffff000000ffffffffff000000ffffffffff00000000000000000000000000000000000
008ffff67ffff800000fffff8ffff000000fffff8ffff000000fffff8ffff000000fffff8ffff000000ffff77ffff000000fff110ffffccc0000000000000000
0008888ff88880000000000ff00000000000000ff00000000000000ff00000000000000ff00000000000000ff0000000000fff110ffffccc0000000000000000
0081111111111800000111111111100000011111111110000001111111111000000111111111100000011111111110004ddd11110ff5ffcc0000000000000000
00811111111118000001111111111000000ff11111111000000111111111100000011111111ff000000fff11111fff004ddd11110ff5ffcc0000000000000000
008ff111111ff800000ff111111ff000000ff111111ff000000ff111111ff000000ff111111ff000000fff11111fff00000d1111f8fffccc0000000000000000
008ff111111ff800000ff111111ff0000000011111100000000ff111111ff00000000111111000000000011111100000000d1111f8ffffcc0000000000000000
008ffddddddff80000000dddddd0000000000dddd440000000000dddddd0000000000dddddd0000000000dddddd000004ddd11110ff5fccc0000000000000000
00088dd88dd8800000000dd00dd0000000000dd00440000000000dd00dd0000000000dd00440000000000dd00dd000004ddd11110ff5fccc0000000000000000
00008dd88dd8000000000dd00dd00000000004400000000000000dd00dd0000000000dd00440000000000dd00dd00000000fff110fffffcc0000000000000000
000084488448000000000440044000000000000000000000000004400440000000000440000000000000044004400000000fff110ffffccc0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccc0000000000000000000009888000001cc00
5500000055000000330000006600000099000000dd0000001100000033000000bb00000033000000000cccccccccc00000000000000000000090080000010000
565500006655000044330000556600004499000066dd000055110000bb33000033bb000011330000000ccffcfccfc0000000555533330000009008000001cc00
55565500666665009944330055556600444499006666dd0055551100bbbb33003333bb0011113300000ff71ff17ff00055556006b00b33330098880000010000
65555500666665009999990055555500444444006666660055555500bbbbbb003333330011111100000ff71ff17ff00060606006b00b0b0b00090000001ccc00
55560000665500009999000055550000444400006666000055550000bbbb00003333000011110000000ffff8fffff00060606666bbbb0b0b0009880000100c00
65000000550000009900000055000000440000006600000055000000bb0000003300000011000000ff0ffff88ffff0ff00000000000000000009000000100c00
00000000000000000000000000000000000000000000000000000000000000000000000000000000ff00000ff00000ff000000000000000000098800001ccc00
00000000000000000000000000000000000000000000000000000000000000000000000000000000fff111111a111fff00000000005555000000000000aaaa00
00000000000000000000000000000000000000000000000000000000000000000000000000000000fff111119aa11fff0000000005333350000000000a5555a0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000011119100000010000705355553500000000a566666a
577757779999999944444444454545454446444684448444644464645656565666566656545454540000011111100000011177700535555008008880a566666a
7757775794949494444444445555555546444644448444844646444665656565566656665454545400000dddddd0000001855e70055333508988a9a8a566676a
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd00dd0000001155770535555358a9a9898a566776a
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd00dd000000000000005333350088880800a6666a0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000004400440000000000000005555000000000000aaaa00
74444444470000000000077777770000000000111100000000000011110000000007000000007000000700000000700000000100007000000000555555550000
77777777770000000000744444007000000011111111000000001111111100000005700000075000000570000007500000000111777000000055777777775500
777777777700000000044400040070000001111111111000000111111111100000077777777770000007777777777000000001255e7000000577556665567750
7777777777000000004470000400700000111111111111000011111111111100000777777777700000077d7777d7700000000115577000000565766777556750
777777bb777777700440700040004400011111777711111001111177771111100007766776677000000776d77d67700000111111777777005767675667776775
777777eb7700000704007004400444000111177777711110011117788771111000077567756770000007756dd567700000111111777777005776656677656775
7777bbbb770000074477774477447477111177755777111111117788887711110007777777777000000777777777700000111111777777005776567777756775
777bbbbb770000074777447774477477111177555577111111117888888711110007777887777000000777788777700000111111777777005776577667556775
77757bbb7700000747747bbb44bb7477111177555577111111117888888711110666677776666000666667786666600000111111777777005776677665666775
7bbbbbbb7700000744477be44bbb4777111177755777111111117788887711110677777776777000067777788677700000111111777777005777656657756775
78bbbbbb7700000744777744bbb44777011117777771111001111778877111100000077777700000000007777770000000555555666666005767557576757675
7bbbbbbb770000074444444b7bb47777011111777711111001111177771111100000077777700000000007777770000000202555666e0e005767677776757675
77777777777777704474477b5b4b7777001111111111110000111111111111000000077777700000000007777770000000000550066000000566676666766650
777777777700000047777777744b7777000111111111100000011111111110000000077777700000000007777770000000000550066000000577555766776750
7777777777000000477777744b8b7777000011111111000000001111111100000000077007700000000007700770000000000550066000000055777777775500
77777777770000004444444777777777000000111100000000000011110000000000066006600000000066606660000000000550066000000000555555550000
22202222222202222220252222520222000000bbbb000000333300bbbb0033338000000000000008a80000000000008a88888888888888880000888888880000
2020111111110202202011511511020200000bbbbbb0000030030bbbbbb0300388000000000000889a800000000008a9888888888888888800889a9999998800
002011a11a110200202011a55a11020200000bbbbbb0000033030bbbbbb03033088888777788888089a8857777588a988888888888888888089988aaa88a9980
222022222222022220202222222202020000bbbbbbbb00000303bbbbbbbb303000078cc77cc8700008878c5775c87880888888888888888808989aa99988a980
200022877822000220202278872202020000bbbbbbbb00003303bbbbbbbb303300078cc77cc8700000078cc55cc87000888888888888888889a9a98aa999a998
22202227722202222020227887220202000bbb3bb3bbb0003003bb3bb3bb3003000888777788800000088877778880008888888888888888899aa8aa99a8a998
00200007700002002020007227000202000bbb3bb3bbb0003303bb3bb3bb30330007788ee88770000088888ee88888008888888888888888899a8a999998a998
2220222222220222202022222222020200bbbbbbbbbbbb0003b3bbbbbbbb3b300000000770000000089aa987789aa9808888888888888888899a899aa988a998
2000202222020002202020222202020200bbbbbbbbbbbb0033b3bbbbbbbb3b33000655577555600008a77a8778a77a808888888888888888899aa99aa8aaa998
222020222202022220202022220202020bbbbb3333bbbbb03bb3bb3333bb3bb3000555666655500008a77a8668a77a8088888888888888888999a8aa8998a998
002020222202020020202022220202020bbbb3bbbb3bbbb033bbb3bbbb3bbb330005565665655000089aa986689aa980888888888888888889a988989a989a98
2220205555020222202020555502020200bbbbbbbbbbbb0003bbbbbbbbbbbb3000077556655770000088885665888800888888888888888889a9a9999a989a98
2000208aa80200022020208aa8020202000bbbbbbbbbb000330bbbbbbbbbb033000004444448800000000444444a9800888888888888888808aaa9aaaa9aaa80
2000208aa80200022020208aa8020202000000444400000030000044440000030000044004408800000004400448a980888888888888888808aa8889aa99a980
200020899802000220202089980202020000004444000000330000444400003300000770077008800000077007708a9888888888888888880088999999998800
22222008800222222022200880022202000004444440000003000444444000300000077007700000000007700770088088888888888888880000888888880000
b3bbbbbb6656656666666666a9aaaaaa55555555ccccc1cc6656656611111111dddddddd9999999933333333000000000000000d600000000000aaaaaaaa0000
bbbbbb3b6656656665666656a9aaaaaa55555555c1cc1c1c55566555111111111d111111a9aaaaaa3bbbbbb3000000000000000d6000000000aa55555555aa00
bbb3bbbb555555556666666699999999556666551c1ccccc66566566177777111d111111999999993bbbbbb300000000000000d6660000000a556666666666a0
3bbbbbbb6656656666666666aaaaaa9a55666655cccccccc6656656617111711ddddddddaaaaaa9a3bbbbbb300000000000000d6660000000a566666666666a0
bbbbb3bb6656656666666666aaaaaa9a55666655cccccc1c6656656617777711111111d1999999993bbbbbb30000000000000d6666600000a56666666666666a
b3bbbbbb5555555566666666aaaaaa9a55666655cc1cc1c16656656617111711111111d1a9aaaaaa3bbbbbb30000000000000d6666600000a56666666666766a
bbbbbbb366566566656666569999999955555555c1c1cccc6655556617777711dddddddd999999993bbbbbb3000000000000d66666660000a56666666666766a
bbbb3bbb6656656666666666a9aaaaaa55555555cccccccc66566566111111111d111111aaaaaa9a33333333000000000000d66666660000a56666666666766a
888a88888888888833bb3333333333337777777777777777000000000000000000000000000000000000000000000000000d666666666000a56666666666766a
88888888899999983bbbb333333bb333cccccccc7cccccc7000000000000000000000000000000000000000000000000000d666666666000a56666666666766a
888888a889aaaa9833bb333333b44b33c11ccccc7cccccc700000000000000000000000000000000000000000000000000d6666666666600a56666666666766a
a888888889aaaa98b333333b3b4444b3cccccccc7cc11cc700000000000000000000000000000000000000000000000000d6666666666600a56666666667666a
8888a88889aaaa98bb3333bb3b4444b3cccccc117cc11cc70000000000000000000000000000000000000000000000000d666666666666600a666777777666a0
8888888889aaaa98b333bb3b33b44b33cccccccc7cccccc70000000000000000000000000000000000000000000000000d666666666666600a666666666666a0
88a8888889999998333bbbb3333bb333cccccccc7cccccc7000000000000000000000000000000000000000000000000d66666666666666600aa66666666aa00
8888888a888888883333bb3333333333ccc11ccc77777777000000000000000000000000000000000000000000000000d6666666666666660000aaaaaaaa0000
44444444444444440004444444444000000aaaaaaaaaa0000000000000000000000055555555000000000a0aa0a000000000000000000000000aaaaaaaaaa000
44444444444444440004444444444000000aaaaaaaaaa0000000055555500000000555555555500000099aaccaa990000000060660600000000a28888888a000
555555555555555500044f4f4f444000000aafafafaaa0000000555dd5550000000555555555500000099999999990000009966666699000000a25888858a000
4444444444444444000ff71ff17f4000000ff71ff17fa000000555d6665550000005572442755000000ff73ff37ff0000099999999999000000a28888888a000
4444444444444444000ff71ff17ff000000ff71ff17ff000005555d6665555000004472ff2744000000ff73ff37ff000009f9739f3799000000a28888888a000
4444444444444444000ffffffffff000000ffffffffff00005555d66666eeee0000ffffffffff000000fff9999fff000099ff73ff37ff000000a28888888a000
5555555555555555000ffff8fffff000000fffff8ffff00008888d66666cccc0000ffff8fffff000000fff9889fff000099ffffffffff000000a28888888a000
4aaa4444444444440000000ff00000000000000ff00000000888d6666666bbb00000000ff00000000000000990000000099fffff8ffff000000a28888888a000
4aaa444444444444000cccccccccc00000033333333330000555d6666666aaa0000555555555500000088888888880000999999ff9990000000a28888888a000
4aaa444444444444000cccccccccc0000003333333333000055d666666666550000555555555500000088888888880000998888888888000000a25888858a000
5555555555555555000ffcc9affff000000ff333333ff000055d666666666550000ff555555ff000000ff888888ff0000998888888888000000a22222222a000
4444444444444444000ffcc9affff000000ff333333ff000005d666666666500000ff555555ff000000ff888888ff000000ff888888ff00000a8888888888a00
44444444444444440066fdddddd00000000ffccccccff0000005555555555000000ff666666ff000000ff111111ff000000ff888888ff00000a8888888888a00
444444444444444400556dd00dd0000000000cc00cc000000000555555550000000006600660000000000110011000000000888888880000000aaaaaaaaaa000
555555555555555500550dd00dd0000000000cc00cc000000000055555500000000006600660000000000110011000000008888888888000000aaaaaaaaaa000
4444444444444444000004400440000000000440044000000000000000000000000004400440000000000440044000000000044004400000000aaaaaaaaaa000
00000000000000004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
00000000000000004040040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
00000000000000004044440400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
04444444444444404040040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
49999999999999944040040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
49949999977949944440044400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
49999999777999944040040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
49949999977949944040040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
49999999999999944444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
04444444444444404999999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888888
00049400004940004944449400000000444444444444444400000000000000000000000000000000000000000000000000000000000000008888888888888888
00049400004940004940049400000000444999999999944400000000000000000000000000000000000000000000000000000000000000008888888888888888
00049400004940004940049400000000449999999999994400000000000000000000000000000000000000000000000000000000000000008888888888888888
00049400004940004940049400000000499999999999999400000000000000000000000000000000000000000000000000000000000000008888888888888888
00049400004940004940049400000000499999999999999400000000000000000000000000000000000000000000000000000000000000008888888888888888
00004000000400000400004000000000499999999999999400000000000000000000000000000000000000000000000000000000000000008888888888888888
00055000000550000000000000000000000aaaaaaaaaa000000000000000000000000705507000000aa666666600aa000000000000000000ccc777cc00000000
00055555555550000000000000000000000aaaaaaaaaaa00000000000000000000000705507000000aa00000000aaaaa0000000000000000cc77777c00000000
00055555555550000000000000000000000aafffaffafa0000000000000000000000077aa7700000aa00000000aaa0aa0000000000000000ccc777cc00000000
00055000000550000000444444440000000ff72ff27ffaa000000000000000000000001aa1aaa000aaa000000aaa00060000000000000000cccccccc00000000
00055000000550000004444444444000000ff72ff27ffaa000000000000000000000008888aaa0000aaa0000aaa00006000000000000000077ccccc700000000
00055555555550000040f75ff57f0400000ffffffffffaa000000000000000000000008aa8aaaa0000aaa00aaa0000060000000000000000777ccc7700000000
00055555555550000040f75ff57f0400000ffff8fffffaa000000000000000000000000000aaaa00600aaa0aa00000060000000000000000777ccc7700000000
00055000000550000040ffffffff04000000000ffaaaaaa000000000000000000000000000aaaa006000aaa55aa00006000000000000000077ccccc700000000
00055111111550000000ffff8fff0000000ccccccccccaa000566600000000000000000000aaaa0060000aa55aaa000600000000000000000000000000000000
0015555555555100000f000ff0000000000ffccccccff0000005600000000000000000000aaaa0006000000aa0aaa00600000000000000000000000000000000
0115555555555110000ffeeeeeeff000000ffccccccff000000560000000000000000000aaaaa000600000aaa00aaa0000000000000000000000000000000000
1115511111155111000000eeee000000000ffccccccff00000566600000000000000000aaaaa000060000aaa0000aaa000000000000000000000000000000000
1115511111155111000000eeee0000000000cccccccc00000566666000000000000000aaaaaa00006000aaa000000aa000000000000000000000000000000000
111555555555511100000eeeeee00000000cccccccccc0000566666000000000000000aaaaa00000aa0aaa00000000aa00000000000000000000000000000000
01155555555551100000eeeeeeee000000cccccccccccc00056666600000000000000aaaaa000000aaaaa00000000aaa00000000000000000000000000000000
001551111115510000000040040000000000044004400000005666000000000000000aaaa000000000aa006666666aa000000000000000000000000000000000
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
