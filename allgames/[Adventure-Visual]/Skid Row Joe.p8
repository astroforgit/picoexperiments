pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
hobo = {}
hobo.x = 64-16
hobo.y = 24
hobo.sprt = 128
hobo.tmr = 0
hobo.flp = false
hobo.wkspd = 5
hobo.hlth = 8
hobo.alc = 2
hobo.money = 40
hobo.bank = 0
hobo.glass = 0 
hobo.plastic = 0
hobo.rides = 1
hobo.down = false
hobo.up = false
hobo.shave = false
hobo.shavetmr = 0
hobo.shavedtime = 4
hobo.home_a = 0
hobo.home_b = 0
hobo.home_c = 0
hobo.gym = 0
hobo.hometmr_a = 0
hobo.hometmr_b = 0
hobo.hometmr_c = 0
hobo.gymtmr = 0
hobo.hometime = 7
hobo.gymtime = 30
hobo.ged = 0
hobo.uni = 0
peep = {}
peep.x = 0
peep.y = 20
peep.w = 1
peep.sprt = 0
peep.sprts1 = 0
peep.sprts2 = 0
peep.tmr = 0
peep.flp = false
peep.sd = "left"
peep.ver = "guy1"
peep.dia = "hello"
peep.on = false
peep.mood = 0
world = {}
world.cnt = 0
world.hr = 6
world.day = 1
world.hrcnt = 600
world.neglimx = 0
world.poslimx = 0
world.neglim = 0
world.poslim = 0
sign = {}
sign.tcol = 0
sign.rcol = 0
inside={}
inside.txt1 = ""
inside.txt2 = ""
inside.txt3 = ""
inside.txt4 = ""
inside.txt5 = ""
inside.txt6 = ""
inside.location = ""
inside.give = false
inside.hlth = 0
inside.alc = 0
inside.money = 0
inside.bank = 0
inside.time = 0
inside.shave = false
gamestate = 0 -- state of the game
gametmron = false 
introcnt = 0
timeoday = 0 -- 0 = day 6 = night
todsidewk = 0 -- time of day for the sidewalk 0 = day 2 = night
savgam = 0
--define the buildings
--values 1-16 are map collums
--17 is the text of a sign
--18 is the x pos of text
--19 is the y pos of text
--20 is the x pos of the rect top l
--21 is the y pos of the rect top l
--22 is the x pos of the rect bot r
--23 is the y pos of the rect bot r
--24 is the day color of the rect
--25 is the night color of the rect
--26 is the day color of the text
--27 is the night color of the text
rpt={"r","e","t","r","o","p","u","t","e"}
a={21,22,3,3,3,4,4,4,5,3,3,3,4,5,3,3}
a1={51,52,3,3,13,14,15,16,3,3,3,3,3,3,3,3}
--bank b and b1
b={51,52,3,3,3,8,9,3,8,9,3,8,9,3,8,9,"gierig bank",80,2,78,0,124,7,8,1,10,13}
b1={3,8,9,3,8,9,3,14,14,15,16,3,48,49,50,3,"atm",102,8,100,6,115,14,7,10,0,0}
--blippo's c
c={21,22,31,31,56,53,54,55,56,31,29,29,29,29,30,31,"blippo's",84,8,82,6,116,14,10,13,0,0}
--the dump
c1={41,41,41,41,42,43,43,43,51,52,3,4,4,4,5,3,"city dump",2,35,0,33,39,41,13,0,10,1}
--gabrio / haut monde polo club (h.m.p.c.)
c2={106,105,105,106,107,107,107,109,110,111,108,108,108,106,105,105,"gabrio",57,10,0,0,0,0,0,0,7,0}
c3={106,112,112,112,112,113,43,43,43,40,112,112,112,112,113,43,"h.m.p.c.",12,35,10,33,42,41,5,0,10,1}
--agrio wines
c4={22,106,3,8,9,3,106,101,101,101,106,3,8,9,3,106,"wine",60,2,0,0,0,0,0,0,0,0}
--fitness
f={21,22,77,78,77,78,79,80,81,80,82,78,77,78,77,78,"fitness 24/7",44,8,42,6,94,14,1,12,8,14}
--bobs liquor g
g={21,22,3,8,8,8,8,8,9,3,14,15,14,15,16,3,"bob's liquor",76,5,76,4,126,10,12,9,0,0}
--food ranch 
g1={21,22,31,31,31,23,28,28,23,23,28,28,23,31,31,31,"food ranch +",40,8,16,6,128,14,11,1,7,5}
--lovelace park
h={41,41,41,41,41,41,41,41,42,43,43,43,43,40,41,41,"lovelace park",10,35,8,33,62,41,7,7,0,0}
h1={41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41}
h2={41,41,41,41,41,41,41,41,42,43,43,43,43,43,43,43}
--jail k
k={21,22,3,1,1,1,3,36,37,38,39,3,1,1,1,3,"jail",64,5,60,4,82,10,7,10,0,0}
--24/7
l={51,52,70,71,71,71,71,72,70,73,76,74,76,75,70,70}
--motel
m={21,22,58,59,60,58,59,60,58,61,62,62,65,62,62,63,"lord jim motel",72,2,71,1,128,7,7,7,0,0}
m1={58,59,60,58,59,60,58,59,60,58,59,60,58,59,60,58}
--adult school
n={22,3,4,5,3,4,5,13,14,14,15,16,3,4,5,3,"adult school",57,8,56,6,104,14,7,7,0,0}
--csun
n1={22,31,29,30,31,29,30,31,29,30,31,23,28,28,23,31,"c.s.u.n.",16,2,8,0,128,8,8,2,7,5}
n2={29,30,31,29,30,31,29,30,31,29,30,31,29,30,31,31,"c.s.u.n.",16,2,0,0,128,8,8,2,7,5}
--outside
o={43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43}
--mexicali
p={22,115,115,119,120,121,115,115,116,116,116,116,116,117,115,115,"mexicali",20,8,0,0,0,0,0,0,0,0}
--mc denny's
p1={22,122,123,123,124,122,125,118,126,118,127,122,123,123,124,122,"mc denny's",48,8,0,0,0,0,0,0,10,0}
--sunchucks
p2={21,22,31,29,29,29,29,29,30,31,23,28,28,23,31,31,"sunchuck's coffee",36,8,16,7,128,13,3,3,7,7}
--curley sue
q={22,88,88,86,87,88,89,90,91,90,92,88,86,87,88,88,"curley sue",48,8,46,6,88,14,14,1,7,5}
--casa de rata
q1={22,93,93,94,95,93,96,97,98,97,99,93,94,95,93,93,"casa de rata",44,8,0,0,0,0,0,0,0,0}
--casa de oro
q2={22,102,103,103,104,102,100,101,101,101,100,102,103,103,104,102}
--subway
s={21,22,66,66,66,66,66,67,68,69,66,66,84,85,66,66,"subway",92,8,0,0,0,0,0,0,0,10}
--south sub
s1={21,22,66,67,68,69,66,67,68,69,66,67,68,69,66,66,"north    east    west",24,8,0,0,0,0,0,0,0,10}
--east sub
s2={21,22,66,67,68,69,66,67,68,69,66,67,68,69,66,66,"north   south    west",24,8,0,0,0,0,0,0,0,10}
--west sub
s3={21,22,66,67,68,69,66,67,68,69,66,67,68,69,66,66,"north   south    east",24,8,0,0,0,0,0,0,0,10}
--north sub
s4={21,22,66,67,68,69,66,67,68,69,66,67,68,69,66,66,"south    east    west",24,8,0,0,0,0,0,0,0,10}
--hipster alley bar
z={21,22,0,64,61,62,63,64,0,43,43,44,45,46,47,43}
--newsstand
y1={43,43,43,43,51,52,31,53,54,55,31,43,43,43,43,43,"news",60,2,0,0,0,0,0,0,0,0}
--shalgumbayeva imports ltd
x={21,22,106,105,106,105,105,109,110,110,111,105,105,106,105,106,"shalgumbayeva",48,10,0,0,0,0,0,0,7,11}
--perez-siegel
w={21,22,31,29,29,29,29,29,29,30,31,23,28,28,23,31,"perez-siegel",26,20,0,0,0,0,0,0,7,5}
--corporate investments limited
v={22,31,30,31,30,31,30,31,23,28,23,28,23,31,30,31,"corporate investments ltd",20,8,8,6,128,14,12,12,0,0}
--retropute
u={21,22,88,34,34,34,34,32,32,32,34,34,34,34,34,88,"retropute",52,8,24,0,120,15,14,1,7,8}
--recycle sally
t={41,41,41,42,43,43,43,51,52,3,4,5,3,4,5,3,"recycle sally",74,35,72,33,128,41,10,10,0,0}
--the city
aa = {o,b,b1,k,c,s,s1,m,m1,g,h,h1,h1,h2,o,o,o,y1,o,o,l,f,p1,q,s,s2,p2,p,n,z,a1,a,a1,c1,a,a1,a,t,s,s3,p2,q1,p1,n1,n2,g1,l,o,o,o,o,a1,s,s4,a,v,u,x,c4,o,l,o,w,p2,q2,c2,c3,o}
-- c blippos should be 5th
mv = 0
offa = -128
offb = 0
offc = 128
masterpos=0
townside ="west"
startpos = 4
shifty = startpos
relative =0
treasure = false
person = false
dospawnt = false
dospawnp = false
choosetch = 0
choosepch = 0
whatt = 0
whatp = 0
whatpside = 0
relative2 =0
pickup = false
spawnside = 128
tsprite = 17
telecnt = 0
parkproblem = 0
investing = false
function _init()
cartdata("retropute001srj1_0")
world.neglimx = (#aa-startpos)*-1
world.poslimx = (#aa-1)-(world.neglimx*-1)
world.neglim = (world.neglimx*256)+10
world.poslim = (world.poslimx*256)-10
end
function _update()
--game timer
--game timer needs to run durring all 
--game play states. it dosn't run durring
--the intro scenes...
-- might not need it afterall 
--if gametmron == true then
--gametmr()
--end
--game timer end
hobolimits()
deathcheck()
if gamestate == 0 then
savgam = dget(17)
introcnt+=1
if introcnt == 1 then
sfx(2)
end
if introcnt > 100 then
gamestate = 1 -- should be 1
introcnt = 0
end
end--end gamestate 0
if gamestate == 1 then
if btnp(4) then
gamestate = 2
end
if btnp(5) and savgam == 1 then
hobo.hlth = dget(0)
hobo.money = dget(1)
hobo.bank = dget(2)
hobo.alc = dget(3)
hobo.rides = dget(4)
hobo.gym = dget(5)
hobo.home_a = dget(6)
hobo.home_b = dget(7)
hobo.home_c = dget(8)
hobo.hometmr_a = dget(9)
hobo.hometmr_b = dget(10)
hobo.hometmr_c = dget(11)
hobo.gymtmr = dget(12)
hobo.ged = dget(13)
hobo.uni = dget(14)
world.day = dget(15)
world.time = dget(16)
gamestate = 2
teleport(0,0,0,true)
end
end--end gamestate 1
if gamestate == 2 then
if btnp(4) and btnp(5) then
savgam = 1
dset(0,hobo.hlth)
dset(1,hobo.money)
dset(2,hobo.bank)
dset(3,hobo.alc)
dset(4,hobo.rides)
dset(5,hobo.gym)
dset(6,hobo.home_a)
dset(7,hobo.home_b)
dset(8,hobo.home_c)
dset(9,hobo.hometmr_a)
dset(10,hobo.hometmr_b)
dset(11,hobo.hometmr_c)
dset(12,hobo.gymtmr)
dset(13,hobo.ged)
dset(14,hobo.uni)
dset(15,world.day)
dset(16,world.time)
dset(17,savgam)
end
gametmr()
if world.hr >= 19 or world.hr <= 5 then
timeoday = 6
todsidewk = 2
else
timeoday = 0
todsidewk = 0
end
updatemap(.5) -- .5
--put new people spawn below
if world.cnt%(abs(world.hr*20-240)+25) == 0 then
if dospawnp == false then
choosep()
end
end
--end new people spawn 
if masterpos%256 == 251 then
chooset()
spawnside = 133
end
if masterpos%256 == 5 then
chooset()
spawnside = -21
end
checkshave()
checkhome()
checkt()
checkp()
movep()
if masterpos == world.poslim or masterpos == world.neglim then
gamestate = 8
end
end--end gamestate 2
if gamestate == 3 then
dospawnp = false
peep.x = 0
--most places
if btn(4) then
 if inside.give == true then
 hobo.money += inside.money
 hobo.bank += inside.bank
 hobo.hlth += inside.hlth
 hobo.alc += inside.alc
 world.hr += inside.time
--subway ticketing
 if inside.location == "subway ticketing" then
 hobo.rides +=1
 end
--recycle sally's
 if inside.location == "recycle sally's" then
  if hobo.glass == 6 then
  hobo.glass = 0
  end
  if hobo.plastic == 6 then
  hobo.plastic = 0
  end
 end
--hotels motels
 if inside.location == "lord jim motel" then
 world.hr = 6
 world.day +=1
 homengym()
 hobo.shave = true
 hobo.shavetmr = 2 
 end
--park
 if inside.location == "lovelace park" then
 parkproblem = rnd(100)
  if parkproblem < 75 then
  hobo.money = 0
  end
 end
-- casa de ratta
 if inside.location == "casa de rata appartments" then
  if hobo.home_a !=1 then
  hobo.home_a = 1
  hobo.hometmr_a = hobo.hometime
  else
  world.hr = 6
  world.day +=1
  homengym()
  hobo.shave = true
  hobo.shavetmr = hobo.shavedtime
  checkinvest()
  end
 end
 -- curley sue
 if inside.location == "curly sue appartments" then
  if hobo.home_b !=1 then
  hobo.home_b = 1
  hobo.hometmr_b = hobo.hometime
  else
  world.hr = 6
  world.day +=1
  homengym()
  hobo.shave = true
  hobo.shavetmr = hobo.shavedtime
  checkinvest()
  end
 end
 -- casa de oro
 if inside.location == "casa de oro appartments" then
  if hobo.home_c !=1 then
  hobo.home_c = 1
  hobo.hometmr_c = hobo.hometime
  else
  world.hr = 6
  world.day +=1
  homengym()
  hobo.shave = true
  hobo.shavetmr = hobo.shavedtime
  checkinvest()
  end
 end
  -- fitness 24
 if inside.location == "fitness 24" then
  if hobo.gym !=1 then
  hobo.gym = 1
  hobo.gymtmr = hobo.gymtime
  else
  hobo.shave = true
  hobo.shavetmr = hobo.shavedtime
  end
 end
 --adult education center
 if inside.location == "adult education center" then
  if hobo.ged <3 then
  hobo.ged +=1
  end
 end
  --csun
 if inside.location == "c.s.u.n." then
  if hobo.uni <10 then
  hobo.uni +=1
  end
 end
--invest
 if inside.location == "corporate investments ltd" then
  if investing == false then
  investing = true
  end
 end
 gamestate = 2
 if world.hr>23 then
 world.hr=0+world.hr-23
 world.day+=1
 hobo.shavetmr -=1
 homengym()
 checkinvest()
 end
 end
end
if btn(5) then
gamestate = 2
end
end--end gamestate 3
if gamestate == 4 then
if btn(5) then
gamestate = 2
end
end--end gamestate 4
if gamestate == 5 then
telecnt +=1
 if telecnt > 50 then
 gamestate = 2
 telecnt = 0
 end
end--end gamestate 5
if gamestate == 6 then
if btn(5) then
gamestate = 2
end
end--end gamestate 6
if gamestate == 7 then
if btnp(5) or btnp(4) then
gamestate = 1
hobo.hlth = 10
hobo.money = 40
hobo.bank = 0
hobo.rides = 1
hobo.alc = 2
hobo.home_a = 0
hobo.home_b = 0
hobo.home_c = 0
hobo.hometmr_a = 0
hobo.hometmr_b = 0
hobo.hometmr_c = 0
hobo.gymtmr = 0
hobo.ged = 0
hobo.uni = 0
hobo.gym = 0
hobo.glass = 0
hobo.plastic = 0
hobo.shave = false
hobo.shavetmr = 0
world.hr = 0
world.day = 1
teleport(0,0,0,true)
end
end--end gamestate 7
if gamestate == 8 then
if btnp(4) then
gamestate = 2
 if masterpos >0 then
 teleport(2,512,0,true)
 else
 teleport(63,-59*256,0,true)
 end
end
if btnp(5) then
gamestate = 7
end
end--end gamestate 8
end--end update
--********* _draw() ***********
function _draw()
if gamestate == 0 then
retropute()
end--end gamestate 0
if gamestate == 1 then
cls()
print("skid row joe",40,10,11)
spr(128,48,30,4,4)
print("dedicated to bob keener",16,84,12)
print("(c) 2017 retropute",26,94,12)
if savgam == 1 then
print("(z) start new       (x) resume saved",4,120,10)
else
print("(z) start new",4,120,10)
end
end--end gamestate 1
if gamestate == 2 then
cls()
drawmap(aa[shifty-1],aa[shifty],aa[shifty+1])
--hobo
spr(hobo.sprt,hobo.x,hobo.y,4,4,hobo.flp)
--try to get rid of beard of hobo
if hobo.shave == true then
if hobo.down == false and hobo.up == false then
if hobo.flp == true then
line(60,37,63,37,15)
line(58,38,64,38,15)
line(58,39,61,39,14) --mouth
line(62,39,64,39,15)
line(58,40,65,40,15) -- should be 15 flesh color
else
line(64,37,68,37,15)
line(64,38,69,38,15)
line(66,39,69,39,14) --mouth
line(64,39,66,39,15)
line(62,40,69,40,15) -- should be 15 flesh color 
end
end
end
--end get rid of beard
displaystats()
displaypeeptalk()
if btn(4) and btn(5) then
print("game saved",44,20,7)
end
end--end gamestate 2
if gamestate == 3 then
drawinside()
end -- end gamestate 3
if gamestate == 4 then
drawinside()
end -- end gamestate 4
if gamestate == 5 then
cls()
print("rides remaining... "..hobo.rides,34,32,7)
end--end gamestate 5
if gamestate == 6 then
cls()
displaynews()
end--end gamestate 6
if gamestate == 7 then
cls()
print("game over",46,64,7)
end--end gamestate 6
if gamestate == 8 then
cls()
print("you reach the city limits,",12,20,7)
print("here's your chance to walk",12,26,7)
print("off into the sunset...",12,32,7)
print("(z) go back      (x) give up",12,64,7)
end
end--end _draw()
--update map function
function updatemap(speed)
--moving the world
if btn(1) then 
 if hobo.down == false and hobo.up == false then
 hobowalk(false)
if masterpos > world.neglim then
 mv-=speed
 masterpos-=1
 relative-=1
 relative2-=1
 sign.x-=0.5 
end--added for limit
 if dospawnp == true then
 peep.x -=0.3 
 end
 end
 hobo.down = false
 hobo.up = false
end
if btn(0) then
if hobo.down == false and hobo.up == false then
 hobowalk(true)
if masterpos < world.poslim then
 mv+=speed
 masterpos+=1
 relative+=1
 relative2+=1
 sign.x+=0.5 
end --added for limit
 if dospawnp == true then
 peep.x +=0.3
 end
end
hobo.down = false
hobo.up = false
end
if btn(2) then
hobo.down = false
hobo.up = true
hobo.sprt= 140
checkinside()
end
if btn(3) then
hobo.sprt=136
hobo.flp = false
hobo.down = true
 if dospawnt == true then
	 if pickup == true then
	   dospawnt = false
    sfx(1)
    if tsprite == 17 then
    hobo.money +=1
    end
    if tsprite == 23 then
    hobo.hlth +=3
    end
    if tsprite == 19 then
    hobo.plastic +=1
    end
    if tsprite == 21 then
    hobo.glass +=1
    end
	  -- pickup = false
	 end
 end
end
if masterpos == 0 then
shifty = startpos
--i think this will fix it
mv=0
relative = 0
sign.x = 0 -- trying
relative3 = 0
--if not well...
end
if masterpos != 0 then
	if masterpos%256==0 then	
		if relative > 0 then
		shifty-=1
		relative = 0
		mv=0
  sign.x = 0
		end
		if relative < 0 then
		shifty+=1
		relative = 0
		mv=0
  sign.x = 0
		end	
	end
end
end
--end update map function
function drawmap(mapa,mapb,mapc)
for i=0,15 do
map(mapa[i+1],timeoday,offa+(i*8)+mv,0,1,6)
map(mapb[i+1],timeoday,(i*8)+mv,0,1,6)
map(mapc[i+1],timeoday,offc+(i*8)+mv,0,1,6)
end
for j=0,3 do
map(24,todsidewk,offa+(j*32)+mv,48,4,2)
map(24,todsidewk,(j*32)+mv,48,4,2)
map(24,todsidewk,offc+(j*32)+mv,48,4,2)
end
drawsign()
spawnt(dospawnt,spawnside,tsprite,2,2)
spawnp(dospawnp,peep.x,peep.sprt,peep.w,4)
end--end drawmap()
function drawsign()
if world.hr <=5 or world.hr >=19 then -- night
sign.rcol = 25
sign.tcol = 27
else-- day
sign.rcol = 24
sign.tcol = 26
end
if aa[shifty-1][17] != nil then
rectfill(sign.x+aa[shifty-1][20]+offa,aa[shifty-1][21],sign.x+aa[shifty-1][22]+offa,aa[shifty-1][23],aa[shifty-1][sign.rcol])
print(aa[shifty-1][17],sign.x+aa[shifty-1][18]+offa,aa[shifty-1][19],aa[shifty-1][sign.tcol])
end
if aa[shifty][17] != nil then
rectfill(sign.x+aa[shifty][20],aa[shifty][21],sign.x+aa[shifty][22],aa[shifty][23],aa[shifty][sign.rcol])
print(aa[shifty][17],sign.x+aa[shifty][18],aa[shifty][19],aa[shifty][sign.tcol])
end
if aa[shifty+1][17] != nil then
rectfill(sign.x+aa[shifty+1][20]+offc,aa[shifty+1][21],sign.x+aa[shifty+1][22]+offc,aa[shifty+1][23],aa[shifty+1][sign.rcol])
print(aa[shifty+1][17],sign.x+aa[shifty+1][18]+offc,aa[shifty+1][19],aa[shifty+1][sign.tcol])
end
end--end drawsign()
----------spawnt()
--spawn treasure 
--st -bool that says go ahead and spawn treasure
--sidet -the side of the screen to spawn it
--mv is added to sidet, maybe it should be relative2?
--snt -sprite number for treasure
--swt -sprite witdth for treasure
--sht -sprite hight for treasure
function spawnt(st,sidet,snt,swt,sht)
if mv > -126 then
	if st == true then --check to see if you should spawn
	spr(snt,sidet+mv,64,swt,sht) -- spawn
	end
end
if mv < 126 then
 if st == true then --check to see if you should spawn
 spr(snt,sidet+mv,64,swt,sht) -- spawn
 end
end
end
----------chooset()
--choose treasure
--choosetch -choose treasre chance
--dospawnt -yes, do spawn a treasure
--relative2 - a relative position based on center
--pickup -bool to indicat that the treasure can be picked up
function chooset()
choosetch = rnd(100)
whatt = rnd(100)
	if choosetch < 50 then--and dospawnp == false then
	dospawnt = true
 else 
	dospawnt = false
	end
if whatt < 20 then
tsprite = 17
end
if whatt >= 20 and whatt < 50 then
tsprite = 19
end
if whatt >= 50 and whatt < 80 then
tsprite = 21
end
if whatt >= 80 then
tsprite = 23
end
end --end chooset()
function checkt()
if relative2%256==0 then
relative2=0
end
if dospawnt == true then
if relative2<0 then
	if relative2<-140 then
		if relative2>-170 then
		pickup = true
		else
		pickup = false
		end
	else
	pickup = false
	end
end
 --add for other side
if relative2>0 then
 if relative2<180 then
  if relative2>140 then
  pickup = true
  else
  pickup = false
  end
 else
 pickup = false
 end
end
 --end add for other side
end 
end-- end checkit()
--hobowlk function
function hobowalk(flp)
hobo.tmr+=1
hobo.flp = flp
 if hobo.tmr<hobo.wkspd then
 hobo.sprt=132
 end
 if hobo.tmr>hobo.wkspd then
 hobo.sprt=128
 end
 if hobo.tmr>hobo.wkspd*2 then
 hobo.tmr=0
 sfx(0)
 end
end--end hobowalk()
--spawnp()
function spawnp(sp,sidep,snp,swp,shp)
--if mv > -126 then
 if sp == true then --check to see if you should spawn
 spr(snp,sidep+peep.x,peep.y,swp,shp,peep.flp) -- spawn
 end
end
--end spwanp()
function movep()
if dospawnp == true then
if peep.ver == "robber" then
if world.cnt%7 == 0 then
sfx(3)
end
end
 peep.tmr +=1
 if peep.x < 140 and peep.sd == "left" then 
 peep.x +=0.5
  if peep.tmr < 5 then
  peep.sprt = peep.sprts1
  end
  if peep.tmr > 5 then
  peep.sprt = peep.sprts2
  end
  if peep.tmr > 10 then
  peep.tmr = 0
  end 
 end
 if peep.x > -20 and peep.sd == "right" then
 peep.x -=0.5
  if peep.tmr < 5 then
  peep.sprt = peep.sprts1
  end
  if peep.tmr > 5 then
  peep.sprt = peep.sprts2
  end
  if peep.tmr > 10 then
  peep.tmr = 0
  end
 end
 if peep.x >= 100 or peep.x < -10 then
 peep.on = false
 dospawnp = false
 peep.x = 0
 end
end
end -- end movep()
--choosep()
--choose person
function choosep()
choosepch = rnd(100)
whatp = rnd(100)
whatpside = rnd(100)
peep.mood = rnd(100)
 if choosepch < 50 then
 dospawnp = true
 peep.on = true
 else 
 dospawnp = false
 end
if whatp < 20 then
pdefine(64,65,1,"gal1")
end
if whatp >= 20 and whatp < 40 then
pdefine(66,67,1,"guy1")
end
if whatp >= 40 and whatp < 60 then
pdefine(68,69,1,"gal2")
end
if whatp >= 60 and whatp < 90 then
pdefine(70,71,1,"guy2")
end
if whatp >= 90 and whatp < 95 then
pdefine(72,74,2,"cop")
end
if whatp >= 95 then
pdefine(76,78,2,"robber")
end
if whatpside <= 50 then
peep.x = 70
peep.sd = "right"
peep.flp = true
else
peep.x = 0
peep.sd = "left"
peep.flp = false
end
end -- end choosep()
function checkp()
if peep.ver != "cop" and peep.ver != "robber" then
if peep.mood < 5 and hobo.shave == false then
peep.dia = "here, have some money..."
    if flr(peep.x) == 32 then
    hobo.money +=1
    end
else
peep.dia = ""
end
 end
if peep.ver == "cop" then
 if hobo.shave == false then
 peep.dia = "hey you! stop!"
 else
 peep.dia = "keep out of trouble."
 end
end
if peep.ver == "robber" then 
 peep.dia = "gimmi all yer money!"
end
if peep.x < 36 and peep.x > 29 then
--cop
 if peep.ver == "cop" then
  if hobo.shave == false then
  gotojail("vagrancy")  
  end
 end
--robber
 if peep.ver == "robber" then
 hobo.money = 0
 end
end
end--end checkp()
function displaypeeptalk()
if peep.x < 40 and peep.x > 20 then
print(peep.dia,64-(#peep.dia*2),64,7)
end
end--end displaypeeptalk()
function gotojail(crime)
peep.x = 0
dospawnp = false
gamestate = 4
hobo.hlth = 100
hobo.alc = 0
shifty = startpos
masterpos = 0
mv = 0
relative = 0
relative2 = 0
world.day += 1
hobo.hometmr_a -=1
hobo.hometmr_b -=1
hobo.hometmr_c -=1
hobo.gymtmr -=1
checkinvest()
world.hr = 6
inside.location = "city jail"
inside.txt1 = "you have been arrested for"
inside.txt2 = crime
inside.txt3 = "you get a meal and a bed"
inside.txt4 = "and you are relased at 6am"
inside.txt5 = ""
inside.txt6 = "                  (x) exit"
end
function atm()
doinside("bank atm")
inside.txt1 = "gierig bank atm..."
inside.money = 10
inside.bank = -10
inside.hlth = 0
inside.alc = 0
inside.time = 0
 if hobo.bank >=10 then 
 inside.txt2 = "you are authorized to withdraw"
 inside.txt3 = "$10 per visit"
 inside.txt4 = ""
 inside.txt5 = ""
 inside.txt6 = "(z) withdraw $10         (x) exit"
 inside.give = true
 else  
 inside.txt2 = "you need a balance of"
 inside.txt3 = "at least $10 to withdraw"
 inside.txt4 = "transaction declined!"
 inside.txt5 = ""
 inside.txt6 = "                        (x) exit" 
 inside.give = false
 end
end--end atm()
function subway()
doinside("subway ticketing")
inside.txt1 = "tickets are $2 per ride,"
inside.txt2 = "rides are added to your"
inside.txt3 = "metro card."
if hobo.money >= 2 then
inside.money = -2
inside.bank = 0
end
if hobo.money < 2 and hobo.bank >=2 then
inside.money = 0
inside.bank = -2
end
inside.hlth = 0
inside.alc = 0
inside.time = 0
 if hobo.money >= 2 or hobo.bank >=2 then 
 inside.txt4 = ""
 inside.txt5 = ""
 inside.txt6 = "(z) add ride $2         (x) exit"
 inside.give = true
 else
 inside.txt4 = ""
 inside.txt5 = "you don't have $2!"
 inside.txt6 = "                        (x) exit"
 inside.give = false
 end
end--end subway
function twentyfourseven()
doinside("24/7 convenience")
checknchrg(2,4,0,false)
insidetxtdisp("we're always open!",
              "",
              "snacks are $2",
              "")
end--end twentyfourseven()
function mcdennys()
if world.hr >= 6 and world.hr <= 22 then
doinside("mc denny's")
if world.hr == 6 then
checknpay(60,8,flr(hobo.hlth*-.5),true,false,false)
insidetxtdisp("here for the dishwasher job?",
              "it pays $60",
              "",
              "")
else
checknchrg(7,10,0,false)
insidetxtdisp("welcome to mc denny's!",
              "we do it all for you!",
              "a big den burger combo",
              "is $7")
end
end
end--end mcdennys
function sunchucks()
if world.hr >= 6 and world.hr <= 22 then
doinside("sunchucks")
if world.hr == 6 then
checknpay(100,8,flr(hobo.hlth*-.5),false,true,false)
insidetxtdisp("here for the barista job?",
              "it pays $100",
              "",
              "")
else
checknchrg(4,1,-1,false)
insidetxtdisp("welcome to sunchucks!",
              "",
              "a mocha lata late is $4",
              "")
end
end
end--end sunchucks
function appartment(rnt,nbr)
if nbr == 1 then
if hobo.home_a == 1 then
athome()
else
getappart(rnt)
end
end
if nbr == 2 then
if hobo.home_b == 1 then
athome()
else
getappart(rnt)
end
end
if nbr == 3 then
if hobo.home_c == 1 then
athome()
else
getappart(rnt)
end
end
end--end appartment()
function getappart(rnt)
 if hobo.money >= rnt or hobo.bank >= rnt then
  if hobo.money >= rnt then
  inside.money = rnt*-1
  else
  inside.bank = rnt*-1
  end 
 inside.hlth = 0
 inside.alc =  0
 inside.time = 0
 insidetxtdisp("we have a flat for rent",
               "only $"..rnt.." a week.",
               "",
               "")
 inside.txt5 = ""
 inside.txt6 = "(z) rent        (x) exit"
 inside.give = true
 else
 insidetxtdisp("we have a flat for rent",
               "only $"..rnt.." a week.",
               "",
               "")
 inside.txt5 = "but you lack the funds!"
 inside.txt6 = "                (x) exit"
 inside.give = false 
 end
end--end getappart()
function athome()
 inside.money = 0
 inside.bank = 0
 inside.hlth = 20
 inside.alc = -15
 inside.time = 0
 insidetxtdisp("it's nice to be home!",
               "",
               "",
               "")
 inside.txt5 = ""
 inside.txt6 = "(z) sleep        (x) exit"
 inside.give = true
end--end athome()
function drawinside()
cls()
rectfill(0,8,128,15,10)
print(inside.location,64-(#inside.location*2),10,0)
print(inside.txt1,64-(#inside.txt1*2),20,7)
print(inside.txt2,64-(#inside.txt2*2),30,7)
print(inside.txt3,64-(#inside.txt3*2),40,7)
print(inside.txt4,64-(#inside.txt4*2),50,7)
print(inside.txt5,64-(#inside.txt5*2),60,7)
print(inside.txt6,64-(#inside.txt6*2),70,7)
end
function doinside(inloc)
sfx(1)
gamestate = 3
inside.location = inloc
end
function checkinside()
--bobs
if masterpos >=-1625 and masterpos <=-1585 then
if world.hr >= 9 and world.hr <= 24 then
doinside("bob's liquor")
checknchrg(2,0,2,true)
insidetxtdisp("cheap wine is $2",
              "",
              "",
              "")
end
end
--agrio wines
if masterpos >=-14095 and masterpos <=-14082 then
if world.hr >= 9 and world.hr <= 24 then
doinside("agrio wines")
checknchrg(60,0,8,false)
insidetxtdisp("we have a lovley merlot for $60",
              "",
              "",
              "")
end
end
--hipster alley
if masterpos >=-6620 and masterpos <=-6610 then
if world.hr >= 17 or world.hr <= 2 then
doinside("hipster alley bar")
checknchrg(8,0,3,true)
insidetxtdisp("microbrew ipa is $8 a pint.",
              "",
              "",
              "")
end
end
--food ranch
if masterpos >=-10810 and masterpos <=-10725 then
if world.hr >= 9 and world.hr <= 18 then
doinside("food barn")
checknchrg(5,5,0,true)
insidetxtdisp("a bag of groceries is $5",
              "",
              "",
              "")
end
end
--blippos
if masterpos >=-238 and masterpos <=-224 then
if world.hr >= 9 and world.hr <= 22 then
doinside("blippo's subs")
if world.hr == 9 then
checknpay(50,10,flr(hobo.hlth*-.6),true,false,false)
insidetxtdisp("we're looking for a dishwasher",
              "the job pays $50 per day.",
              "",
              "")
else
checknchrg(5,5,0,true)
insidetxtdisp("a delux sub sandwich is $5",
              "",
              "",
              "")
end
end
end
--mexicali
if masterpos >=-6095 and masterpos <=-6080 then
if world.hr >= 9 and world.hr <= 23 then
doinside("mexicali restaurant")

if world.hr == 9 then

checknpay(100,10,flr(hobo.hlth*-.8),true,false,false)
insidetxtdisp("we're looking for a busser",
              "the job pays $100 per day.",
              "",
              "")
else
checknchrg(10,5,0,true)
insidetxtdisp("a taco platter is $10",
              "",
              "",
              "")
end
end
end
--gabrio
if masterpos >=-15885 and masterpos <=-15878 then
if world.hr >= 17 or world.hr <= 2 then
doinside("gabrio restaurant")
if world.hr == 16 then
checknpay(100+flr(rnd(200)),11,flr(hobo.hlth*-.8),false,true,false)
insidetxtdisp("we're looking for a server",
              "the job pays $100 per shift.",
              "plus tips!",
              "")
else
checknchrg(95,5,5,false)
insidetxtdisp("the tasting menu is $95.",
              "wine is included.",
              "",
              "")
end
end
end
--recycle sally's
if masterpos >=-8700 and masterpos <=-8658 then
if world.hr >= 5 and world.hr <= 17 then
doinside("recycle sally's")
insidetxtdisp("welcome to recycle sally's!",
              "we buy lots of six bottles",
              "plastic bottles - 6 for $1",
              "glass bottles - 6 for $2")
if hobo.glass == 6 and hobo.plastic !=6 then
inside.money = 2
end
if hobo.plastic == 6 and hobo.glass !=6 then
inside.money = 1
end
if hobo.glass == 6 and hobo.plastic ==6 then
inside.money = 3
end
inside.bank = 0
inside.hlth = 0
inside.alc = 0
inside.time = 0 
 if hobo.glass == 6 or hobo.plastic == 6 then
 inside.txt5 = ""
 inside.txt6 = "(z) sell bottles         (x) exit"
 inside.give = true
 else
 inside.txt5 = "you don't have enough bottles!"
 inside.txt6 = "                    (x) exit"
 inside.give = false
 end
end
end
--bank
if masterpos >=240 and masterpos <=250 then
if world.hr >= 9 and world.hr <=16 then
doinside("gierig bank")
inside.txt1 = "welcome to gierig bank"
inside.money = -10
inside.bank = 10
inside.hlth = 0
inside.alc = 0
inside.time = 0
 if hobo.money >=10 then
 inside.txt2 = "keep your money safe"
 inside.txt3 = "minimum deposit is $10"
 inside.txt4 = "get cash at any atm"
 inside.txt5 = "pay with debit at most places"
 inside.txt6 = "(z) deposit $10         (x) exit"
 inside.give = true
 else  
 inside.txt2 = "you need at least $10"
 inside.txt3 = "to deposit"
 inside.txt4 = ""
 inside.txt5 = ""
 inside.txt6 = "                        (x) exit" 
 inside.give = false
 end
end
end
--atm bank
if masterpos >=162 and masterpos <=172 then
atm()
end
--atm hipster
if masterpos >=-6750 and masterpos <=-6738 then
atm()
end
--dumpster
if masterpos >=-7688 and masterpos <=-7651 then
doinside("dumpster")
insidetxtdisp("wow! bottles!",
              "",
              "",
              "")
inside.txt5=""
inside.txt6="             (x) take um!"
inside.give=false
hobo.glass = 6
hobo.plastic = 6
end
--public restroom
if masterpos >=-7400 and masterpos <=-7390 then
--if masterpos >=1 and masterpos <=10 then
doinside("public restroom")
insidetxtdisp("if you wash up you'll",
              "be a lot more presentable.",
              "",
              "")
inside.txt5=""
inside.txt6="             (x) wash up!"
inside.give=false
hobo.shave = true
hobo.shavetmr = 2
end
--lord jim motel
if masterpos >=-1130 and masterpos <=-1060 then
if world.hr >=19 or world.hr <=5 then
doinside("lord jim motel")
inside.txt1 = "welcome to the lord jim!"
if hobo.money >= 25 then
inside.money = -25
else
inside.bank = -25
end
inside.hlth = 20
inside.alc = -10
inside.time = 0
 inside.txt2 = "our rate is $25"
 inside.txt3 = "per night in our"
 inside.txt4 = "delux roach suite."
 if hobo.money >= 25 or hobo.bank >= 25 then
 inside.txt5 = "will you stay?"
 inside.txt6 = "(z) check-in        (x) exit"
 inside.give = true
 else
 inside.txt6 = "                    (x) exit"
 inside.txt5 = "sadly you lack the funds."
 inside.give = false
 end
end
end
--park
if masterpos >=-1865 and masterpos <=-1825 then
doinside("lovelace park")
insidetxtdisp("you are at a city park.",
              "you can try to sleep",
              "on a hard bench",
              "for a couple hours,")
 inside.txt5 = "but you might get robbed."
 inside.txt6 = "() sleep        () exit"
 inside.give = true
 inside.money = 0
 inside.bank = 0
 inside.hlth = flr(rnd(5))
 inside.alc = -3
 inside.time = flr(rnd(3))+1
end
--adult education center
if masterpos >=-6435 and masterpos <=-6415 then
if world.hr == 7 then
 inside.money = 0
 inside.bank = 0
 inside.hlth = -8
 inside.alc = -3
 inside.time = 8
 doinside("adult education center")
 if hobo.ged <3 then
 inside.give = true
 insidetxtdisp("get a g.e.d. certificat free!",
              "you need to attend three",
              "classes to get your g.e.d",
              "certificate. classes start")
 inside.txt5 ="at 7am every day."
 inside.txt6 ="(z) attend class    (x) exit" 
 else
 inside.give = false
 insidetxtdisp("congratulations, you have",
               "the g.e.d. certificat!",
               "you might want to go",
               "to the local university next.")
 inside.txt5 ="classes start at 9am at csun."
 inside.txt6 ="                      (x) exit"  
 end
end
end
--csun
if masterpos >=-10330 and masterpos <=-10310 then
if world.hr == 9 and hobo.ged == 3 then
 if hobo.money >=100 then
 inside.money = -100
 end
 if hobo.bank >=100 and hobo.money <100 then
 inside.bank = -100
 end
 inside.hlth = hobo.hlth*-.8
 inside.alc = -3
 inside.time = 8
 doinside("c.s.u.n.")
 if hobo.money >= 100 or hobo.bank >= 100 then
  if hobo.uni <10 then 
  inside.give = true
  insidetxtdisp("welcome to city state",
                "university of the nation.",
                "get a university education.",
                "tuition is $100 classes start")
  inside.txt5 = "at 9am every day." 
  inside.txt6 = "(z) attend class    (x) exit" 
  else
  inside.give = false
  insidetxtdisp("congratulations, you have",
                "graduated c.s.u.n.",
                "you have a university",
                "education. good luck alum!")
  inside.txt5 = ""
  inside.txt6 = "                      (x) exit"  
  end
 else
 inside.give = false  
 insidetxtdisp("you need $100 per class.",
               "",
               "",
               "")
 inside.txt5 = ""
 inside.txt6 = "                      (x) exit" 
 end
end
end
--24/7 east
if masterpos >=-4425 and masterpos <=-4390 then
twentyfourseven()
end
--24/7 west
if masterpos >=-11080 and masterpos <=-11045 then
twentyfourseven()
end
--24/7 north
if masterpos >=-14660 and masterpos <=-14635 then
twentyfourseven()
end
--mc denny's east
if masterpos >=-4890 and masterpos <=-4853 then
mcdennys()
end
--mc denny's west
if masterpos >=-10011 and masterpos <=-9975 then
mcdennys()
end
--sunchucks east
if masterpos >=-5960 and masterpos <=-5940 then
sunchucks()
end
--sunchucks west
if masterpos >=-9545 and masterpos <=-9525 then
sunchucks()
end
--sunchucks north
if masterpos >=-15433 and masterpos <=-15415 then
sunchucks()
end
--casa de rata
if masterpos >=-9754 and masterpos <=-9717 then
doinside("casa de rata appartments")
appartment(100,1)
end
--curley sue
if masterpos >=-5145 and masterpos <=-5110 then
doinside("curley sue appartments")
appartment(250,2)
end
--casa de oro
if masterpos >=-15630 and masterpos <=-15617 then
doinside("casa de oro appartments")
appartment(1000,3)
end
--fitness 24
if masterpos >=-4634 and masterpos <=-4595 then
doinside("fitness 24")
if hobo.gym != 1 then
checknchrg(50,0,0,false)
insidetxtdisp("gym membership is $50",
              "for 30 days!",
              "get fit now!",
              "free towls and razors!")
else
 insidetxtdisp("hi welcome back.",
              "enjoy your workout",
              "",
              "")
 inside.txt5 =""
 inside.txt6 ="(z) workout              (x) exit"
 inside.money =0
 inside.time = 2
 inside.bank = 0
 inside.hlth =1
 inside.alc =0
 inside.give = true
end
end
--haut monde polo club
if masterpos >=-16140 and masterpos <=-16115 then
if world.hr == 6 then
doinside("haut monde polo club")
checknpay(250,12,flr(hobo.hlth*-.9),false,true,false)
insidetxtdisp("we need a groundskeeper.",
              "the job pays $250 per day.",
              "",
              "")
end
end
--shalgumbayeva
if masterpos >=-13850 and masterpos <=-13830 then
if world.hr == 8 then
doinside("shalgumbayeva imports")
checknpay(200+flr(rnd(800)),12,flr(hobo.hlth*-.8),false,false,true)
insidetxtdisp("we need a sales person.",
              "the job pays $200 per day.",
              "plus commisions!",
              "")
end
end
--perez siegel
if masterpos >=-15189 and masterpos <=-15170 then
if world.hr == 9 then
doinside("perez-siegel law")
checknpay(400,8,flr(hobo.hlth*-.9),false,false,true)
insidetxtdisp("we need a legal secratary.",
              "the job pays $400 per day.",
              "",
              "")
end
end
--retropute
if masterpos >=-13585 and masterpos <=-13565 then
if world.hr == 10 then
doinside("retropute video game co.")
checknpay(500,12,flr(hobo.hlth*-.9),false,false,true)
insidetxtdisp("we need a game programer.",
              "the job pays $500 per day.",
              "",
              "")
end
end
--investments
if masterpos >=-13370 and masterpos <=-13335 then
if world.hr >= 9 and world.hr <= 17 then
if investing == false and hobo.bank >= 10000then
doinside("corporate investments ltd")
checknchrg(1000,0,0,false)
insidetxtdisp("hire an investment",
              "specialist to grow",
              "your nest egg! requires $1k fee",
              "")
end
end
end
--south subway ticketing
if masterpos >=-600 and masterpos <=-585 then
subway()
end
--east subway ticketing
if masterpos >=-5465 and masterpos <=-5440 then
subway()
end
--west subway ticketing
if masterpos >=-9050 and masterpos <=-9025 then
subway()
end
--north subway ticketing
if masterpos >=-12635 and masterpos <=-12610 then
subway()
end
--news
if masterpos >=-3600 and masterpos <=-3585 then
gamestate = 6
end
--south subway transits
--to north 
if masterpos >=-720 and masterpos <=-695 then
teleport(53,256*-49,3,false) --north
end 
--to east
if masterpos >=-785 and masterpos <=-760 then
teleport(25,256*-21,1,false) --east
end
--to west
if masterpos >=-850 and masterpos <=-825 then
teleport(39,256*-35,2,false) --west
end
--east subway transits
--to north
if masterpos >=-5585 and masterpos <=-5560 then
teleport(53,256*-49,2,false) --north
end
--to south
if masterpos >=-5650 and masterpos <=-5625 then
teleport(6,256*-2,1,false) --south
end
--to west
if masterpos >=-5715 and masterpos <=-5690 then
teleport(39,256*-35,1,false) --west
end
--west subway transits
--to north
if masterpos >=-9170 and masterpos <=-9145 then
teleport(53,256*-49,1,false) --north
end
--to south
if masterpos >=-9235 and masterpos <=-9210 then
teleport(6,256*-2,2,false) --south
end
--to east
if masterpos >=-9300 and masterpos <=-9275 then
teleport(25,256*-21,1,false) --east
end
--north subway transits
--to south
if masterpos >=-12755 and masterpos <=-12730 then
teleport(6,256*-2,3,false) --south
end
--to east
if masterpos >=-12815 and masterpos <=-12790 then
teleport(25,256*-21,2,false) --east
end
--to west
if masterpos >=-12885 and masterpos <=-12855 then
teleport(39,256*-35,1,false) --west
end
end--end checkinside()
function teleport(loc,mps,trt,rdovrd)
--loc = location as in shifty number
--mps = masterpos 
--trt = travel time as in how many hours elapse 
if rdovrd == true or hobo.rides > 0 then
if rdovrd == false then
gamestate = 5
end
hobo.rides -=1
peep.x = 0
dospawnp = false
shifty = loc
masterpos = mps
mv = 0 
relative = 0 
relative2 = 0
sign.x = 0 
world.hr += trt
end
end--end teleport
function checknchrg(prc,fd,alc,cod)
--prc = price of transaction
--cod - true = cash only
inside.time = 0
if cod == true then
 if hobo.money >= prc then
 inside.money = prc*-1
 inside.hlth = fd
 inside.alc = alc
 inside.give = true
 inside.txt5 = ""
 inside.txt6 = "(z) buy            (x) exit"
 else
 inside.give = false
 inside.txt5 = "cash only!"
 inside.txt6 = "                    (x) exit"
 end
else
 if hobo.money >= prc or hobo.bank >= prc then
  inside.hlth = fd
  inside.alc = alc
  inside.give = true
  inside.txt5 = ""
  inside.txt6 = "(z) buy            (x) exit"
  if hobo.money >= prc then
  inside.money = prc*-1
  else
  inside.bank = prc*-1
  end
 else
 inside.give = false
 inside.txt5 = "you need money!"
 inside.txt6 = "                    (x) exit"
 end
end
end--end checknchrg
function checknpay(pay,tm,rst,no,hs,un)
if hobo.alc <=0 and hobo.shave == true then
 if no == true then
 inside.money = pay
 inside.bank = 0
 inside.time = tm
 inside.hlth = rst
 inside.give = true
 inside.txt5 = "you got the job!"
 inside.txt6 = "(z) take job        (x) exit"
 end
 if hs == true then
  if hobo.ged >= 3 then
  inside.money = 0
  inside.bank = pay
  inside.time = tm
  inside.hlth = rst
  inside.give = true
  inside.txt5 = "you got the job!"
  inside.txt6 = "(z) take job        (x) exit"
  else
  inside.give = false
  inside.txt5 = "you need a ged certificat!"
  inside.txt6 = "                    (x) exit"
  end
 end
 if un == true then
  if hobo.uni >=10 then
  inside.money = 0
  inside.bank = pay
  inside.time = tm
  inside.hlth = rst
  inside.txt5 = "you got the job!"
  inside.txt6 = "(z) take job        (x) exit"
  inside.give = true
  else
  inside.give = false
  inside.txt5 = "university education required!"
  inside.txt6 = "                    (x) exit"
  end
 end
 else
 inside.give = false
 inside.txt5 = "we don't hire hobos!"
 inside.txt6 = "                     (x) exit"
 end
end--end checinvest
function checkinvest()
if investing == true and hobo.money >= 1000 then
hobo.bank += flr(hobo.bank*.0005)
end
end--end checkinvest
function insidetxtdisp(tx1,tx2,tx3,tx4)
 inside.txt1 = tx1
 inside.txt2 = tx2
 inside.txt3 = tx3
 inside.txt4 = tx4
end--end insidetxtdisp
function displaystats()
rectfill(0,83,128,95,7)
rectfill(0,84,hobo.hlth*4,88,11)
if hobo.alc < 10 then
rectfill(0,90,hobo.alc*4,94,10)
end
if hobo.alc < 14 and hobo.alc >= 9 then
rectfill(0,90,hobo.alc*4,94,9)
end
if hobo.alc >= 14 then
rectfill(0,90,hobo.alc*4,94,8)
end
print("food/rest",2,84,0)
print("alcohol",2,90,0)
if hobo.ged > 0 then
rectfill(66,90,66+hobo.ged*4,94,12)
end
if hobo.uni > 0 then
rectfill(87,90,87+hobo.uni*4,94,8)
end
print("ged  university",66,90,0)
rectfill(60,90,64,94,0)
rectfill(80,90,84,94,0)
print(world.hr..":00",0,97,12)
--print(" :00",4,97,12)
print("$"..hobo.money,0,103,11)
--print(hobo.money,6,103,11)
if hobo.bank >0 then
print("bank bal $",30,103,7)
print(hobo.bank,72,103,9)
end
print("day:"..world.day,100,103,7)
--print(world.day,116,103,7)
if hobo.home_a >0 or hobo.home_b >0 or hobo.home_c >0 then
spr(255,0,109)
end
if hobo.rides > 0 then
spr(254,0,115)
end
if hobo.plastic > 0 then
 for ii = 1,hobo.plastic do
 spr(19,ii*16+ii,105,2,2)
 end
end
if hobo.glass > 0 then 
 for iii = 1,hobo.glass do
 spr(21,iii*16+iii,115,2,2)
 end
end
end--end displaystats
function displaynews()
print("help wanted",0,0,7)
print("job desc      time place",0,10,7)
print("dishwasher    9am  blippo's",0,20,11)
print("busser        9am  mexicali",0,26,11)
print("cook          6am  mc denny's",0,32,11)
print("barista       6am  sunchucks",0,38,10)
print("waiter        3pm  gabrio",0,44,10)
print("groundskeeper 6am  hlpc",0,50,10)
print("sales         8am  shalgumbayeva",0,56,8)
print("programer     10am retropute",0,62,8)
print("legal sec     9am  perez-seigel",0,68,8)
print("no education required",0,74,11)
print("requires minimum ged edu",0,84,10)
print("requires university edu",0,94,8)
print("adult edu cntr open 7am",0,114,7)
end
function retropute()
cls()
for iiii = 1,9 do
print(rpt[iiii],20+(iiii*9),25,iiii+6)
end
print("presents skid row joe",64-44,74,7)
print("(c) 2017 retropute",64-36,94,7)
end--end retropute()
function checkshave()
if hobo.shavetmr <= 0 then
hobo.shavetmr = 0
end
if hobo.shave == true and hobo.shavetmr == 0 then
hobo.shave = false
end
end--end checkshave
function checkhome()
if hobo.hometmr_a <= 0 then
hobo.hometmr_a = 0
hobo.home_a = 0
end
if hobo.hometmr_b <= 0 then
hobo.hometmr_b = 0
hobo.home_b = 0
end
if hobo.hometmr_c <= 0 then
hobo.hometmr_c = 0
hobo.home_c = 0
end
if hobo.gymtmr <= 0 then
hobo.gymtmr = 0
hobo.gym = 0
end
end--end checkhome
function hobolimits()
if hobo.money <= 0 then
hobo.money = 0
end
if hobo.hlth >=30 then
hobo.hlth = 30
end
if hobo.hlth <=0 then
hobo.hlth = 0
end
if hobo.alc >=15 then
hobo.alc = 0
gotojail("public drukenness")
end
if hobo.alc <=0 then
hobo.alc = 0
end
if hobo.plastic >=6 then
hobo.plastic = 6
end
if hobo.plastic <=0 then
hobo.plastic =0
end
if hobo.glass >=6 then
hobo.glass = 6
end
if hobo.glass <=0 then
hobo.glass =0
end
end--end hobolimits
function deathcheck()
if hobo.hlth <=0 and hobo.alc <= 0 then
gamestate = 7
end
end
--gametmr() keeps track of the
--time in the game and subtracts
--one from hobo.hlth every world.hr
--and also subtracts one from hobo.alc
--every three hours %3
function gametmr()
world.cnt+=1
if world.cnt > world.hrcnt then
 world.hr+=1
 hobo.hlth-=1
 --hobo.shavetmr -=1 -- added for shaving 
if world.hr%3==0 then
hobo.alc-=1
 if hobo.alc<0 then
 hobo.alc=0
 end
end
  if hobo.hlth<0 then
  hobo.hlth = 0
  end
 if world.hr >=24 then
 world.day+=1
 world.hr=0
 hobo.shavetmr -=1 -- added for shaving
 homengym()
 checkinvest()
 end
world.cnt = 0
end
end--end gametimer
--code optimizing things
function homengym()
 hobo.hometmr_a -=1
 hobo.hometmr_b -=1
 hobo.hometmr_c -=1
 hobo.gymtmr -=1
end
function pdefine(ps1,ps2,pww,pvv)
 peep.sprts1 = ps1
 peep.sprts2 = ps2
 peep.w = pww
 peep.ver = pvv
end
__gfx__
000000003bbbbbb31cccccc198888889000000007777777755555555010110100000000066666666666606666666666666666666666666661111111000000000
00000000b3bbbb3bc1cccc1c89888898111011107777777755555555010110100011110066666666666660666666666666666666666666661111111055555500
00000000bb3333bbcc1111cc88999988111011107777777755555555010110100100001066666666666666066666666666666666666666661111111055555550
00000000bb3bb3bbcc1cc1cc889889881110111077777777555555550101101001011010666666666666666066666666666666666666666611111110dddddddd
00000000bb3bb3bbcc1cc1cc88988988000000007777777755555555010110100101101066666666666666660666666666666666666666660000000000000000
00000000bb3333bbcc1111cc88999988101111007777777755555555010110100100001066666666666666666066666666666666666666660000000066666666
00000000b3bbbb3bc1cccc1c89888898101111007777777755555555010110100011110066666666666666666606666666666666666666660000000066666666
000000003bbbbbb31cccccc198888889101111007777777755555555010110100000000066666666666666666660666666666666666666660000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000066666666666666666666066666666666110111101111111100011110
11111111000000000000000000000000000000000000000000000000000000000000000066666666666666666666606666666666110111101111111100011110
11111111000000000000000000000000000000000000000000000000000000000000000066666666666666666666660666666666110111101111111100011110
11111111bbbbbb000000000000000000000000000000000000000000000000000000000066666666666666666666666066666666110111101111111100011110
11111111bbbbbbbbbbb0000000000000000000000000000000000000000000000000000066666666666666666666666606666666000111100000000000011110
11111111bbbbbbbb0bbbbbbb00000000000000000000000000000000000044444444000055555555555555555555555505555555000111100000000000011110
11111111b0bbbbb000bbbbbb0222eeee222000000333bbbb33300000000444444444400055555555555555555555555505555555000111100000000000011110
11111111b0bbbbb0bbbbbbbb2222eeee222000003333bbbb33300000004444444444440055555555555555555555555505555555000111100000000000011110
00000000b0bbbbb000bbbb0b2222eeee2222222d3333bbbb3333333d8888aa88aa88a88800000000000011000000110055555550660666606666666600055550
11110111bbbbbbbbb0bbbb0b2222eeee2222222d3333bbbb3333333d88aa88aa88aa888855555555555511000000110066656660660666606666666600055550
11110111bbbbbbb000bbbb0b2222eeee2222222d3333bbbb3333333d004444444444440055555555555511000000110066656660660666606666666600066660
11110111bbbbbbbb0bbbbbbb2222eeee222000003333bbbb33300000000444444444400022222222222211000000110066656660660666606666666600066660
0000000000000bbbbbbbbbbb0222eeee222000000333bbbb33300000000044444444000000000000000011000000110055555550000666600000000000066660
1011110100000000000bbbbb00000000000000000000000000000000000000000000000011111111111111000000110065666650000666600000000000066660
10111101000000000000000000000000000000000000000000000000000000000000000011111111111111000000110065666650000666600000000000066660
10111101000000000000000000000000000000000000000000000000000000000000000000000000000000000000110065666650000666600000000000066660
77777777555555556767767666666666000000000000660000005500555555550000660066666666555555550000000055555555555555556666666000066660
88887888666566666767767666777766555555555555660000005500555555550000660066666666555556660000011155555666666566666666666000066660
88887888666566666767767667666676555555555555660000006600555555550000660066666666555556660000011155555666666566666666666000066660
88887888666566666767767667677676dddddddddddd660000006600555555550000660066666666555556660000011155555666666566666666666000066660
77777777555555556767767667677676000000000000660000006600555555550000660066666666555555550000000005555555555555550000000000066660
87888878656666566767767667666676666666666666660000006600555555550000660066666666555556660000011100555666666566650000000000066660
87888878656666566767767666777766666666666666660000006600555555550000660066666666555556660000011100055666666566650000000000066660
87888878656666566767767666666666000000000000000000006600555555550000660066666666555556660000011100005666666566650000000000066660
0000aa000000aa000dddddd00dddddd000001100000011000eeeeee00eeeeee00111111110000000011111111000000000000000000000000000000000000000
000aaaa0000aaaa00dddddd00dddddd000011110000111100eeeeee00eeeeee00011111100000000001111110000000000000000000000000000000000000000
00aaaaaa00aaaaaadddddddddddddddd0011111100111111eeeeeeeeeeeeeeee0011111a000000000011111a0000000000055550000000000005555000000000
00aaffff00aaffff0111fff00111fff0001144440011444401114440011144400055555555500000005555555550000000555555000000000055555500000000
0aaff4f40aaff4f4011fff1f011fff1f0114434301144343011444140114441400444fff0000000000444fff0000000000555555000000000055555500000000
0aafffff0aafffff01ffffff01ffffff0114444401144444014444440144444400444ffcff00000000444ffcff00000000111111000000000011111100000000
0aafff8f0aafff8f01ffffff01ffffff01144484011444840144444401444444004fffffff000500004fffffff00000001111b1b000000000111111b00000000
aaffffffaaffffff01ffffe001ffffe01144444411444444014444e0014444e0004fffffff000500004fffffff00050000ff11110000000000ff111100000000
aaffff00aaffff00dddffff0dddffff01144440011444400eee44440eee44440004fff4400000500004fff4400000500055ffffff0000000055ffffff0000000
aaffff00aaffff00dddddddddddddddd1144440011444400eeeeeeeeeeeeeeee055ffffe00000500055ffffe000005000ddfffee000000000ddffffe00000000
aaafffc0aaafffc0dddddddfdddddddf111444b0111444b0eeeeeeefeeeeeeef011555ff00000500011555ff000005000dd555ff000000000dd555ff00000000
aaaacfccaaaacfccdddddddfdddddddf1111b4bb1111b4bbeeeeeeefeeeeeeef011115555000050001111555500005000dddd555000000000dddd55500000000
aaacccccaaacccccdddddddfdddddddf111bbbbb111bbbbbeeeeeeefeeeeeeef011111111000050001111111100005000ddddddd000000000ddddddd00000000
aaccccccaaccccccdddddddddddddddd11bbbbbb11bbbbbbeeeeeeeeeeeeeeee11111111100005001111111110000500dddddddd00000000dddddddd00000000
0ccccccc0cccccccdfffddddddfffddd0bbbbbbb0bbbbbbbefffeeeeeefffeee1111111aa111ff001111111aa0000500dddddddd05555550dddddddd05555550
0cccccc00cccccc0dfffddddddfffddd0bbbbbb00bbbbbb0efffeeeeeefffeee11111111a111ff0011111111a111ff00ddddddddd5f50000ddddddddd5f50000
00ccccc000ccccc0444444400444444400bbbbb000bbbbb04444444004444444111111111111ff00111111111111ff00ddddddddd5f00000ddddddddd5f00000
00ccccc000ccccc0444444400444444400bbbbb000bbbbb044444440044444441111111111000000111111111111ff00dddddddd00000000dddddddd00000000
00cfffc000ccfff0444444400444444400b444b000bb4440444444400444444411555511110000001115555111000000d555dddd00000000ddd555dd00000000
00cffccc00ccffcc444444400444444400b44bbb00bb44bb444444400444444411ffff1111000000111ffff111000000dfffdddd00000000dddfffdd00000000
0ccccccc0ccccccc44444440044444440bbbbbbb0bbbbbbb444444400444444411fff11111000000111fff1111000000dffddddd00000000dddffddd00000000
cccccccccccccccc4444444004444444bbbbbbbbbbbbbbbb444444400444444411fff11111000000111fff1111000000dddddddd00000000dddddddd00000000
cccccccccccccccc0ddddd000ddddd00bbbbbbbbbbbbbbbb0eeeee000eeeee0011111111110000001111111111000000dddddddd00000000dddddddd00000000
cccccccccccccccc0ddddd000ddddd00bbbbbbbbbbbbbbbb0eeeee000eeeee0011111111110000001111111111000000dddddddd00000000dddddddd00000000
00ffff0000ffff000ddddd000ddddd0000444400004444000eeeee000eeeee005555555555000000555555555500000055555555000000005555555500000000
00ffff0000ffff000ddddd000ddddd0000444400004444000eeeee000eeeee000011111000000000000111110000000000111110000000000011111000000000
00ffff0000ffff000ddddd000ddddd0000444400004444000eeeee000eeeee000011111000000000000111110000000000111110000000000011111000000000
00ccff0000ffcc000ddddd000ddddd0000bb44000044bb000eeeee000eeeee000011111000000000000111110000000000111110000000000011111000000000
00cccc0000ffccc00ddddd000ddddd0000bbbb000044bbb00eeeee000eeeee000011111000000000000111110000000000111110000000000011111000000000
00c0cc0000ccc00c0ddddd000ddddd0000b0bb0000bbb00b0eeeee000eeeee000011111000000000000111110000000000111110000000000011111000000000
0000ccc000ccc00001111110011111000000bbb000bbb00001111110011111000055555550000000000555555500000000555555000000000055555550000000
0000c00c00c00c0001111000000111100000b00b00b00b0001111000000111100005555550000000000555555000000000555555500000000005555550000000
00000000000011110000000000000000000000000000111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000111111111100000000000000000000001111111111000000000000000000000000000000000000000000000000000000011111000000000000000
00000000000011111111000000000000000000000000111111110000000000000000000000000000000000000000000000000000000011111100000000000000
00000000000001111110000000000000000000000000011111100000000000000000000000000000000000000000000000000000000011111110000000000000
00000000000001111110000000000000000000000000011111100000000000000000000000000000000000000000000000000000000001111111100000000000
00000000000001111110000000000000000000000000011111100000000000000000000000000000000000000000000000000000000000111111100000000000
00000000000001111110000000000000000000000000011111100000000000000000000000000000000000000000000000000000000000111110000000000000
00000000001111111110000000000000000000000011111111100000000000000000000000000000000000000000000000000000000000111110000000000000
00000000001111111111111000000000000000000011111111111110000000000000000000000000000000000000000000000000000011111111100000000000
00000000000111111111110000000000000000000001111111111100000000000000000000001111110000000000000000000000000111111111110000000000
00000000000001111fff00000000000000000000000001111fff0000000000000000000000011111111000000000000000000000000001111111000000000000
00000000000001ff1ff1ff000000000000000000000001ff1ff1ff0000000000000000000001111111110050000000000000000bbb001b111111100000000000
00000000000011ff1fffff000000000000000000000011ff1fffff000000000000000000000111111111005bbb000000000000000b0bbb111111100000000000
0b0000b00000111f4444ff00000000000b0000b00000111f4444ff000000000000000000000011111110005bbbb00000000000000bbb11111111100000000000
0bb00bb0000111ff44444400000000000bb00bb0000111ff44444400000000000000000000001111111000bbbbbb000000000000bbbbbb111111100000000000
00bbbb0000011fff44ffff000000000000bbbb0000011fff44ffff0000000000000000000011111111111bbbbbbb000000000000bbbbbb111111100000000000
000bb000000cc1444444440000ffff00000bb000000cc1444444440000ffff00000000000011111111111b5bbbbb000000000000bbbbbb1111111c1000000000
0555555555ccc1c111111c5555ffff000555555555ccc1c111111c5555ffff00000000000011111111111b5bbbb0000000000000bbbbbb111111cc1100000000
0bbbbbb00ccccc11cccbbbcccc11ff000bbbbbb00ccccc11cccbbbcccc11ff00000000000011111111111b5bbb00000000000000bbbbbb11111ccccc11000000
0bbbbbb00ccc111111ccbb1cccccff000bbbbbb00cc1111111ccbb1cccccff00000000000cc111111111cc5ccc00000000000001bbbbbbcccccccccccc000000
0bbbbbb00cc1cccccc11bb1ccccc00000bbbbbb00c1ccccccc11bb1ccccc0000000000000ccc1111111ccc5ccc0000000000000cbbbbbbcccccccccccc000000
00bbbb000cc1ccccccccbbbccc00000000bbbb000c1cccccccccbbbccc0000000000000cccccc11111cccffccc0000000000000cbbbbcccccccccccccc000000
000bb0000ccc1111cccccbbc00000000000bb0000c1111cccccccbbc000000000000000cccc1cc111bcccffccc0000000000000ccccccccccccccccccc000000
00000000ccccfffffccccbbc0000000000000000ccfffffccccccbbc000000000000000cccc1cccbbbcccffccc00000000000001cccccccccccccccccc000000
00000000ccccffffcccccccc0000000000000000ccffffcccccccccc000000000000000cccc1cccbbbcccffccc00000000000000cccccccccccccccccc000000
00000000cccccccccccccccccc00000000000000cccccccccccccccccc0000000000000cccc1ccbbbbbccffccc00000000000000cccccccccccccc1111000000
00000000cccccccccccccccccc00000000000000cccccccccccccccccc0000000000000cccc1ccbbbbbcccc00000000000000000ccccccccccccccc000000000
00000000001111111111111000000000000000000011111111111110000000000000000ccc11ccbbbbbcccc00000000000000000ccccccccccccccc000000000
0000000000004444444400000000000000000000000044444444000000000000000000011111111bbb1111100000000000000000011111111111111000000000
00000000000044444444000000000000000000000000444444440000000000000000000ffffff44bbb4444400000000000000000004444400444440000000000
00000000000055555555000000000000000000000000555555555550000000000000000ffff44440b44444400000000000000000004444400444440000000000
00000000000000005555555000000000000000000000555555500000000000000000000ffff55550055555500000000000000000005555500555550000000000
cccccccc88888888cccccccc00000000cccccccc0000660000005500555555550000660066666666000000000000100000000000000000002222222200000000
cccccccc88888888555555cc5555550055555555555566000000550055555555000066006666666600000000000001000000000000000000222222220a0cccc0
cccccccc888888885555555c555555505555555555556600000066005555555500006600666666660000000000000010000000000000000022222222000cccc0
cccccccc88888888dddddddd22222222dddddddddddd6600000066005555555500006600666666660000000000000001000000000000000022222222080cccc0
cccccccc8888888800000000000000000000000000006600000066005555555500006600666666660000000000000000100000000000000022222222000cccc0
cccccccc88888888666666661111111166666666666666000000660055555555000066006666666600000000000000000100000000000000222222220b000000
cccccccc888888886666666611111111666666666666660000006600555555550000660066666666000000000000000000100000000000002222222200077770
cccccccc888888880000000000000000000000000000000000006600555555550000660066666666000000000000000000010000000000002222222200000000
5555555555555555cccccccc00000000ccccc55500000111222221115555566655555666999999990000000000000000000010000000000033333333eeeeeeee
0055555555555555cccccd5500000255ccccc55500000111222221115555566655555666999999990000000000000000000001000000000033333333eeeeeeee
0000555555555555ccccc0d500000025ccccc55500000111222221115555566655555666777777770000000000000000000000100000000033333333eeeeeeee
0000005555555555ccccc60d00000102ccccc55500000111222221115555566655555666bbbbbbbb0000000000000000000000010000000033333333eeeeeeee
0000000055555555ccccc56000000110ccccc55500000111222221110555566655555666bbbbbbbb1111111111111111111111111111111133333333eeeeeeee
0000000000555555ccccc55600000111ccccc55500000111222221110055566655555666777777770000000000000000000000001000000033333333eeeeeeee
0000000000005555ccccc55600000111ccccc55500000111222222110005566655555666888888880000000000000000000000001000000033333333eeeeeeee
0000000000000055ccccc55000000111ccccc55500000111222222210000000055555666888888881111111111111111111111111111111133333333eeeeeeee
1111111111111111055550000005555011111111111111110055550022222111222221117777777701111aaaaa1111aaaaa111105555555555555555aaaaaaaa
0011111111111111055550000005555022111111111111110055550022222111222221117999878701111aaaaa1111aaaaa111105555555555555555aaaaaaaa
0000111111111111066660000006666022221111111111110066660022222111222221117779878701111aaaaa1111aaaaa111100000005555000000aaaaaaaa
0000001111111111066660000006666022222211111111110066660022222111222221117999888701111aaaaa1111aaaaa111100000005555000000aaaaaaaa
0000000011111111066660000006666022222222111111110066660002222111222221117977778701111aaaaa1111aaaaa111100000005555000000aaaaaaaa
0000000000111111066660000006666022222222221111110066660000222111222221117977778701111aaaaa1111aaaaa111100000005555000000aaaaaaaa
0000000000001111066660000006666022222222222211110066660000022111222221117999778701111aaaaa1111aaaaa111100000005555000000aaaaaaaa
0000000000000011066660000006666022222222222222110066660000002111222221117777777701111aaaaa1111aaaaa111100000005555000000aaaaaaaa
066666660111111106666000011110000001111000111100006666009999999966666666aaaaaaaaaaaa1100aaaa110055000000000000550222220000000000
0666666601111111066660000111100000011110001111000066660099999999666666665555555555551100aaaa110055000000000000550ddddd0000000000
0666666601111111066660000111100000011110001111000066660099999999666666665555555555551100aaaa110055000555555000550d222d00aaa00000
0666666601111111066660000111100000011110001111000066660099999999666666662222222222221100aaaa110055000500005000550dd2dd00a0aaaaaa
0000000000000000066660000111100000011110001111000066660099999999666666660000000000001100aaaa110055000500005000550dd2dd00a0aaaaaa
0000000000000000066660000111100000011110001111000066660099999999666666661111111111111100aaaa110055000500005000550dd2dd00aaa00a0a
0000000000000000066660000111100000011110001111000066660099999999666666661111111111111100aaaa110055555555555555550ddddd0000000000
0000000000000000066660000111100000011110001111000066660099999999000000000000000000000000aaaa110055555555555555550222220000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
303100313131313131313131313131313103373706373705090a0b0c05050505373706c731313131c0c0c0c0c0c0c0c0313131373705050505053000363030303030c9c9c9c90505050505050537053705370600c9c90036dfdfdfdfdff70036f7f7f7f7050505003633333333333333c0c0c0dfdfdfc1dfdfdfc1c1c1c1c1c1
3036003100360036003631313131313d3d03373706373705191a1b1c05050505373706c731313131c0c0c0c0c0c0c0c03131313737dedfdedfde303435dfdfdfdfdfc9c9c9c9d9d9d9d9e9d9d905370537050500c9c93435dfdfdfdfdff73435f7f7f7f73333050038de32fcfddededec0c0c0df0036c1dfdfdfc1c1c1c1c1c1
303800313435003800383636002c002f3a033700363737e6cacbcccd0000360500e2e62fe237372fc0c0c0c0d2c4c4c23434343737e2002f0505303030e2002f30e6c90000d8050036e2e62f003705e200e62f00eeeddfdfdfe200e62ff7f7f7e200e62f3200050038de32fcfde2002fc0c0c0f7003800e2002fc10036e2e62f
303100313131343500383538002c2e2d3a033700383737f6dadbdcdd0000380500f2f63ff237373fd2c4c2c0d4e2cfe3e2cfe33737f2003f0505300036f2003f30f6c90000d8050038f2f63f000537f200f63f00fcfd0036dff200f63ff70036f200f63f3200053435de32fcfdf2003fc4c2c0f7003800f2003fc10038f2f63f
303100313131313134353135002c003f3a03373435c7c7f6000000000034350500f2f63ff237373fd43131c0d43434343434343737f2003f0505303435f2003f30f6c90000d8053435f2f63f003705f200f63f000d0d3435dff200f63ff73435f200f63f3200050505de32fcfdf2003fdedec0ef343500f2003fef3435f2f63f
303100313131313131313131002c2e3e3c03373737d0d1f6000000000005050500f2f63ff237373fc7313106c7c9c9c93131313737f2003f0505303030f2003f30f6f80000d7050505f2f63f000537f200f63f00f8f8dfdfdff200f63ff7f7f7f200f63f330033333333333333f2003fdedec7efefef00f2003fefefeff2f63f
2020002020202020202020202020202020021010101010100000000010101010101010102020202000000000000000002020201010101010101020002b2020202020101010101010101010101010ce10ce1010001010002b101010101010002b10101010101010002b0808080808080800000010101010101010101010101010
202b0020002b002b002b20202020202020021010101010100000000010101010101010102020202000000000000000002020201010c7cec7cec720292acecececece10101010d9d9d9d9e9d9d9ce10ce10cece001010292a101010101010292a10101010080810002bce07fcfdcecece00000010002b10101010101010101010
202b0020292a002b002b2b2b0004001f3b0210002b1010f50000000000002b1000f3f5f4f310101f00000000d32929c32929291010f31ef41010202020f300f420f5100000e810effbeaebecef10ceeaefebec00eeed101010f300f51f101010f300f5f4070010002bce07fcfdf300f4000000ce002b00f3f5f410002bf3f5f4
202000202020292a002b2a2b00041e1d3b0210002b1010f50000000000002b1000f3f5f4f310101fd329c300d5f3cff4f3cff41010f31ef4101020002bf300f420f5100000e810effbeaebecefce10eaefebec00fcfd002b10f300f51f10002bf300f5f4070010292ace07fcfdf300f429c300ce002b00f3f51d10002bf3f5f4
2020002020202020292a202a0004001f3b0210292a1010f50000000000292a1000f3f5f4f310101fd5202000d52929292929291010f31ef4101020292af300f420f5100000e810f9faeaebecef10ceeaefebec001010292a10f300f51f10292af300f5f40700101010ce07fcfdf300f4cece0006292a00f3f51dce292af3f5f4
20200020202020202020202000041e0e3b02101010e0e1f5000000000010101000f3f5f4f310101fd62020ced6101010202020e4e5f310f41010202020f300f420f5100000e7101010eaebecefce10eaefebec001010101010f300f51f101010f300f5f4080008080808080808f300f4cece0006060600f3f5f4cececef3f5f4
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
000100001665016600106000000000000000000000016600000000000000000000000000000000036000000017600166500000000000000000000000000000000000000000000000000000000000000000000000
00010000010500105002050030500505007050090500c0500f050110501205014050150501705018050190501a0501a0501a0501a0501a0501a0501b0501b0501c0501d0501e0501f05021050230502605029050
001000000e25018250232500a200032001320010200122002e200352003b250192001d200202001120002200222002e200312000d2000c2000820001200000000000000000000000000000000000000120000000
000500000334003350033700335003340203000560007600033000330003300033000330002300213002130003300033000330003300033002c700017002370003300033000330003300033001e3000570000000
00100000046000b5000b5000b500046000b5000b5000b5000b5000b5000b5000d5000f5001050010500105000e5000c5000b50009500085000750007500075000750007500026000650007500065000350002600
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
