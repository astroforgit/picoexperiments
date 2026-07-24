pico-8 cartridge // http://www.pico-8.com
version 8
__lua__







------------stargust------------
----------eggnog games----------

-----a game by andrew reist-----
---------@platformalist---------
------thanks for playing!!------






--------------init--------------

hiscore={}
 hiscore.val=0
 
function _init()
cloud={}
 cloud.x=60
 cloud.y=60
 cloud.xdir=0
 cloud.ydir=0
 cloud.face=".."
--radius varied based on xdir
 cloud.rv=0
 cloud.rvv=0
 cloud.xcount=0
 cloud.ycount=0
 cloud.water=0
 cloud.attract=false
 cloud.tc=0
 cloud.puc=0

rain={}

zap={}
 zap.contact=0
 zap.contactt=0

flower={}
 flower.s=1
 flower.x=10
 flower.y=104
 flower.power=9.6
 flower.sd=0
 flower.hitbox=59
 flower.rpower=9.6
 flower.rsd=0
 flower.rhitbox=71
 flower.starc=0
 flower.rstarc=0
 flower.alldead=1

battery={}
 battery.power=9.6
 battery.l=60
 battery.r=69
 battery.activedrop=.5
 
water={}
 water.s=3

bg={}
 bg.ss=0
 bg.ssc=0

poof={}
 poof.x=0
 poof.y=0

star={}
 star.gen=0
 star.count=0

spark={}
 spark.xgen=0
 spark.ygen=0
 spark.fall=0

wind={}
 wind.s=8
 wind.sa=10 
 wind.power=0

missile={}
 missile.s=24
 missile.trailx=0
 missile.traily=0
 missile.t=0
 missile.note=31

trail={}

dust={}

chomper={}
 chomper.leat=1
 chomper.reat=1
 chomper.t=0
 chomper.sfxt=0
 
gust={}
 gust.contact=0
 gust.contactt=0

spinner={}

endgame={}
 endgame.pause=false
 endgame.t=0
 endgame.goy=16
 endgame.gox=47
 endgame.hsy=112
 endgame.hsx=47
 endgame.gsx=129
 endgame.tv=0

startgame={}
 startgame.pause=true
 startgame.x=20
 startgame.y=24
 startgame.tc=7
 startgame.t=0
 startgame.eggx=-320
 startgame.eggy=-320
 startgame.eggw=768
 startgame.eggh=768
 startgame.chomperx=132
 startgame.chompery=64
 startgame.chomperspr=40
 startgame.bgr=100
 startgame.roll=0
 startgame.lastwiper=0
 startgame.tstar=-10
 startgame.twind=-10
 startgame.twater=10
 startgame.telec=10
 startgame.elecbar=0
 startgame.finalswipe=false
 startgame.finalswiper=80
 startgame.scrollclick=true

snow={}

end
 
-------------update-------------

function _update()
--gameplay
 if endgame.pause==false and
    startgame.pause==false then
  movecloud()
  bganim()
  powerup()
  foreach(rain,raindrop)
  foreach(zap,zapdrop)
  foreach(poof,poofshrink)
  foreach(star,starfloat)
  foreach(spark,sparkfall)
  foreach(missile,missilefall)
  foreach(trail,trailfade)
  foreach(dust,dustattract)
  foreach(chomper,chompereat)
  foreach(gust,gustblow)
  foreach(spinner,spinnerflip)
  decay()
  decayr()
  stargen()
  missiletimer()
  statedetect()
 end
 screenshake()
--game over
 if endgame.pause==true then
  endgameanim()
 end
--intro
 if startgame.pause==true then
  startgameanim()
  chomperloop()
  foreach(snow,snowfall)
 end
end

function make_snow(x,y,xdir,t)
 local new_snow={
 x=rnd(128),
 y=rnd(170)-170,
 xdir=rnd(5)/10,
 t=flr(rnd(20)),
 }
 return new_snow
end

function draw_snow(thissnow)
 local j=false
 local b=false
 if thissnow.x<16 or
    thissnow.x>112 then
  j=true
 end
 if thissnow.y<16 or
    thissnow.y>112 then
  b=true
 end
 if j==true or
    b==true then
  circfill(thissnow.x,thissnow.y,0,7)
 end
end

function snowfall(thissnow)
 if thissnow.t<21 then
  thissnow.t+=.5
 else
  thissnow.t=0
  thissnow.xdir*=-1
 end
 if thissnow.xdir>-0.05 and
    thissnow.xdir<0.05 then
  thissnow.xdir+=.3
 end
 thissnow.x+=thissnow.xdir
 if thissnow.y<130 then
  thissnow.y+=.5
 else 
  add(snow,make_snow(x,y,xdir,t))
  del(snow,thissnow)
 end 
end

function statedetect()
 if battery.power<0 then
  if star.count>hiscore.val then
   hiscore.val=star.count
  end
  endgame.pause=true
 end
end

function endgameanim()
 if endgame.t<41 then
  endgame.t+=1
 end
--drop game over panel
  if endgame.goy<50 then
   endgame.goy+=6
  else
   endgame.goy=50
  end
 if endgame.t==7 then
  bg.ssc+=5
  sfx(20)
 end
--raise hiscore panel
 if endgame.t>14 then
  if endgame.hsy>70 then
   endgame.hsy-=8
  else endgame.hsy=64
  end
 end
 if endgame.t==20 then
  bg.ssc+=4
  sfx(21)
 end
--shimmy sideline text away
 if endgame.t>6 and
    endgame.t<9 then
    endgame.tv+=2
 elseif endgame.t>20 and
        endgame.t<25 then
        endgame.tv+=2
 end
 if endgame.t==30 then
 music(6)
 end
--restart button and anim
 if endgame.t>40 and
    endgame.gsx==129 and
    btn(5) then
  endgame.gsx=128
  sfx(37)
 end
 if endgame.gsx<129 and
    endgame.gsx>-30 then
  endgame.gsx-=5
 end
 if endgame.gsx<-20 then
   _init()
 end
end

function chomperloop()
 if startgame.chomperx<132 and
    startgame.chomperx>-20 then
  startgame.chomperx-=2.8
 end
 if startgame.chomperspr<43 then
  startgame.chomperspr+=.5
 else
  startgame.chomperspr=40
  if startgame.chomperx>-10 and
     startgame.chomperx<128 then
  sfx(2)
  end
 end
end

function startgameanim()
 if startgame.t<120 then
  startgame.t+=1
 end
 if startgame.eggx<0 and
    startgame.t<28 then
  startgame.eggx+=16
  startgame.eggy+=16
  startgame.eggw-=38.4
  startgame.eggh-=38.4
 else
  startgame.eggx=0
  startgame.eggy=0
  startgame.eggw=0
  startgame.eggh=0
 end
--eggnog smackdown!
 if startgame.t==19 then
  bg.ssc+=3
  sfx(1)
 end
--unleash the chomper!
 if startgame.t==33 then
  startgame.chomperx=131
 end
--shrink the bg circle
 if startgame.t>75 and 
    startgame.bgr>-5 then
  startgame.bgr-=5
 end
 if startgame.t==80 then
  sfx(3)
 end
 if startgame.t==100 then
  for i=1,20 do
   add(snow,make_snow(x,y,xdir,t))
  end
 end
 if startgame.t==115 then
  music(2)
 end
--kicking off the game
 if startgame.t>100 then
  if btn(5) then
   if startgame.lastwiper<1 then
    startgame.lastwiper+=1
   end
  end
--instruction scrolling
  if btn(2) and
   startgame.roll>0 then
   startgame.y+=2
   startgame.roll-=1
   startgame.scrollclick=true
  elseif btn(3) and
   startgame.roll<331 then
   startgame.y-=2
   startgame.roll+=1
   startgame.scrollclick=true
  else
   startgame.scrollclick=false
  end
--scroll click
  if startgame.roll%7==0 and
     startgame.scrollclick==true then
   sfx(11)
  end
 end
--final swipe anim with text
 if startgame.lastwiper>0 and
    startgame.lastwiper<100 then
  music(-1)
  if startgame.lastwiper>0 and
     startgame.lastwiper<3 then
   sfx(17)
  end
  startgame.lastwiper+=2
  startgame.tstar+=.2
  startgame.telec-=.2
  startgame.twind+=.2
  startgame.twater-=.2
  startgame.elecbar+=1.94
 end
 if startgame.lastwiper>99 then
  startgame.pause=false
 end
--shrink swipe to reveal bg
 if startgame.lastwiper>70 then
  startgame.finalswipe=true
 end
 if startgame.finalswipe==true then
  startgame.finalswiper-=6
 end
end

function make_spinner(x,y,s,xdir,ydir,t)
 if gust.contact>64 then
  b=.5
 else
  b=-.5
 end
 local new_spinner={
 x=gust.contact,
 y=112,
 s=56,
 xdir=b*(rnd(2)+2),
 ydir=-4,
 t=0,
 }
 return new_spinner
end

function draw_spinner(thisspinner)
 spr(thisspinner.s,thisspinner.x,thisspinner.y)
end

function spinnerflip(thisspinner)
 thisspinner.x+=thisspinner.xdir
 thisspinner.y+=thisspinner.ydir
 thisspinner.ydir+=.2
 thisspinner.t+=1
--bounce on ground
 if thisspinner.ydir>0 and
    thisspinner.y>110 then
  thisspinner.y*=-1
 end
 if thisspinner.t>40 or
    thisspinner.x<16 or
    thisspinner.y>112 or
    thisspinner.y<16 or
    thisspinner.x>112 then
  del(spinner.thisspinner)
 end
--spin animation
 if thisspinner.t%2==0 then
  if thisspinner.s<59 then
   thisspinner.s+=1
  else thisspinner.s=56
  end
 end
end

function make_gust(x,y,xdir,ydir,t)
 local new_gust={
 x=cloud.x+(rnd(6)-3),
 y=cloud.y+(rnd(6)-3),
 xdir=cloud.xdir*9,
 ydir=8+rnd(3),
 t=0,
 }
 return new_gust
end

function draw_gust(thisgust)
 circfill(thisgust.x,thisgust.y+bg.ss,0,7)
end

function gustblow(thisgust)
 thisgust.x+=thisgust.xdir
 thisgust.y+=thisgust.ydir
 thisgust.t+=1
 thisgust.ydir*=.8
 thisgust.xdir*=.9
--bounds
 if thisgust.t>25 or
    thisgust.x<12 or
    thisgust.x>112 then
  del(gust,thisgust)
 end
--log contact with bottom
 if thisgust.y>107 then
  gust.contact=thisgust.x
  gust.contactt=3
 elseif thisgust.y>112 then
  del(gust,thisgust)
 end
--damage plants with wind
 if gust.contact<flower.hitbox then
  flower.power-=0.001
 elseif gust.contact>flower.rhitbox then
  flower.rpower-=0.001
 end
end

function make_chomper(x,y,t,sf,s,tt,lim,ydir)
 local a=rnd(10)
 local j=0
 local b=true
 if a>5 then
  j=12
 else j=112
 end
 if j==12 then
  b=true
 else
  b=false
 end
 local new_chomper={
 x=j,
 y=104,
 t=0,
 sf=b,
 s=40,
 tt=0,
 lim=60,
 ydir=0,
 }
 return new_chomper
end

function draw_chomper(thischomper)
 spr(thischomper.s,thischomper.x,thischomper.y+bg.ss,1,1,thischomper.sf)
end

function chompereat(thischomper)
 thischomper.tt+=1
--chomping animation
 if thischomper.t<2 then
  thischomper.t+=1
 else
  if thischomper.s<43 then
   thischomper.s+=1
  else
   thischomper.s=40
  sfx(2)
  end
  thischomper.t=0
 end
--l-r movement limits
 if thischomper.sf==true then
  if thischomper.tt<300 then
   thischomper.lim=35.25
  elseif thischomper.tt<600 then
   thischomper.lim=87.75
  else
   thischomper.lim=120
  end
--move l-r chomper
  if thischomper.x<thischomper.lim then
   thischomper.x+=.25
  end
--r-l movement limits
 else if thischomper.tt<300 then
   thischomper.lim=87.75
  elseif thischomper.tt<600 then
   thischomper.lim=35.25
  else
   thischomper.lim=8
  end
--move r-l chomper
  if thischomper.x>thischomper.lim then
   thischomper.x-=.25
  end
 end
--edible area and chomp rate
 if thischomper.x>86 and
    thischomper.x<89 then
  chomper.reat=5
 elseif thischomper.x>34 and
        thischomper.x<37 then
  chomper.leat=5
 else
  chomper.reat=1
  chomper.leat=1
 end
 if thischomper.x>122 or
    thischomper.x<10 then
  del(chomper,thischomper)
 end
--hit by wind gust
 if thischomper.x>(gust.contact-7) and
    thischomper.x<(gust.contact+6) then
  add(spinner,make_spinner(x,y,s,xdir,ydir,t))
  chomper.reat=1
  chomper.leat=1
  sfx(35)
  del(chomper,thischomper)
 end
--hit by lightning
 if thischomper.x>(zap.contact-7) and
    thischomper.x<(zap.contact+6) then
  thischomper.ydir-=1+(rnd(10)/5)
 end
--jump when zapped
 thischomper.y+=thischomper.ydir
 if thischomper.y<104 then
  thischomper.ydir+=.4
 else thischomper.y=104
  thischomper.ydir=0
 end
end

function make_dust(x,y,t)
 local new_dust={
 x=cloud.x+(rnd(34)-17),
 y=cloud.y+(rnd(34)-17),
 t=0,
 }
 return new_dust
end

function draw_dust(thisdust)
 circfill(thisdust.x,thisdust.y+bg.ss,0,7)
end

function dustattract(thisdust)
 if thisdust.x<cloud.x then
  thisdust.x+=1
 elseif thisdust.x>cloud.x then
  thisdust.x-=1
 end
 if thisdust.y<cloud.y then
  thisdust.y+=1
 elseif thisdust.y>cloud.y then
  thisdust.y-=1
 end
 if thisdust.x>cloud.x-1 and
    thisdust.x<cloud.x+1 then
  del(dust,thisdust)
 end
 if thisdust.y>cloud.y-1 and
    thisdust.y<cloud.y+1 then
  del(dust,thisdust)
 end
 if thisdust.t<15 then
  thisdust.t+=1
 else
  del(dust,thisdust)
 end
--damage battery
 if thisdust.x>battery.l and
    thisdust.x<battery.r and
    thisdust.y>108 then
  battery.power-=.005
 end
end
 
function missiletimer()
--drops increase with score
 local l=0
 if star.count<30 then
  l=star.count*20
 elseif star.count>29 then
  l=750
 end
 if missile.t<(1400-(l*1.5)) then
  missile.t+=1
 else
  add(missile,make_missile(x,y,s,t,sfxt))
  missile.t=0
 end
 if chomper.t<(1000-l) then
  chomper.t+=1
 else
  add(chomper,make_chomper(x,y,t,sf,s,tt,lim,ydir))
  chomper.t=0
 end
--reset gust.contact after t
 if gust.contactt>0 then
  gust.contactt-=1
 else
  gust.contactt=0
  gust.contact=0
 end
--reset zap.contact after t
 if zap.contactt>0 then
  zap.contactt-=1
 else
  zap.contactt=0
  zap.contact=0
 end
end

function make_trail(x,y,r)
 local new_trail={
 x=missile.trailx,
 y=missile.traily,
 r=rnd(2)+1.2,
 }
 return new_trail
end

function draw_trail(thistrail)
 circfill(thistrail.x,thistrail.y+bg.ss,thistrail.r,7)
end

function trailfade(thistrail)
 thistrail.r-=.05
 if thistrail.r<.5 then
  thistrail.y-=1
 end
 if thistrail.r<.2 then
  del(trail,thistrail)
 end
end

function make_missile(x,y,s,t,sfxt)
 local new_missile={
 x=rnd(80)+24,
 y=12,
 s=24,
 t=0,
 sfxt=0,
 }
 return new_missile
end

function draw_missile(thismissile)
 spr(thismissile.s,thismissile.x,thismissile.y+bg.ss)
end

function missilefall(thismissile)
 thismissile.y+=.2
--make jaws sound as it falls
 j=flr(96-thismissile.y)
 if thismissile.sfxt<j then
  thismissile.sfxt+=1
 else
  if missile.note==31 then
   missile.note=32
  else
   missile.note=31
  end
  thismissile.sfxt=0
 end
 if thismissile.sfxt==0 then
  sfx(missile.note)
 end
--float toward the battery
 if thismissile.x<59 then
  thismissile.x+=.1
  thismissile.s=26
 elseif thismissile.x>61 then
  thismissile.x-=.1
  thismissile.s=25
 elseif cloud.attract==false then
  thismissile.x=60
  thismissile.s=24
 end
--damage battery on landing
 if thismissile.y>104 then
  if thismissile.x>battery.l-1 and
     thismissile.x<battery.r+1 then
   battery.power-=4
  else
   star.gen=thismissile.x
   add(star,make_star(x,y,s))
  end
--damage flowers on landing
  if thismissile.x<(flower.hitbox-2) then
   if flower.power>0 then
    flower.power-=1
   end
  end
  if thismissile.x>(flower.rhitbox+2) then
   if flower.rpower>0 then
    flower.rpower-=1
   end
  end
--blow up regardless of target
  bg.ssc=15
  poof.x=thismissile.x
  poof.y=thismissile.y
  for i=1,39 do
   add(poof,make_poof(x,y,r))
  end
  sfx(18)
  del(missile,thismissile)
 end
--add trail in 4-frame loop
 if thismissile.t<5 then
  thismissile.t+=1
 else
  if thismissile.s==24 then
   missile.trailx=thismissile.x+4
   missile.traily=thismissile.y-4
  elseif thismissile.s==25 then
   missile.trailx=thismissile.x+9
   missile.traily=thismissile.y-1
  elseif thismissile.s==26 then
   missile.trailx=thismissile.x-1
   missile.traily=thismissile.y-1
  end 
  add(trail,make_trail(x,y,r))
  thismissile.t=0
 end
--magnesis
 if cloud.attract==true then
  if thismissile.x>cloud.x then
   thismissile.x-=.75
  elseif thismissile.x<cloud.x then
   thismissile.x+=.75
  else
   thismissile.x+=0
  end
  if thismissile.y>cloud.y then
   thismissile.y-=.08
  elseif thismissile.y<cloud.y then
   thismissile.y+=.08
  else
   thismissile.y+=0
  end
 end
end

function make_spark(x,y,xdir,ydir)
 local new_spark={
 x=spark.xgen,
 y=spark.ygen,
 xdir=rnd(7)-3.5,
 ydir=rnd(9)-spark.fall,
 }
 return new_spark
end

function draw_spark(thisspark)
 circfill(thisspark.x,thisspark.y+bg.ss,0,7)
end

function sparkfall(thisspark)
 thisspark.x+=thisspark.xdir
 thisspark.y+=thisspark.ydir
 if thisspark.ydir>0.2 then
  thisspark.ydir*=.8
 else
  thisspark.ydir+=.3
 end
 thisspark.xdir*=.9
 if thisspark.y>112 or
    thisspark.y<16 or
    thisspark.x<16 or
    thisspark.y>112 then
  del(spark,thisspark)
 end
end

function make_star(x,y,s,t)
 local new_star={
 x=star.gen+(rnd(30)-15),
 y=112,
 s=36,
 t=0,
 }
 return new_star
end

function draw_star(thisstar)
 spr(thisstar.s,thisstar.x,thisstar.y+bg.ss)
end

function starfloat(thisstar)
--animation
 if thisstar.t%2==0 then
  if thisstar.s<38 then
   thisstar.s+=1
  else thisstar.s=36
  end
 end
--movement
 if thisstar.t<85 then
  thisstar.y-=.2
 end
--collect star
 if thisstar.x<(cloud.x+10) and
    thisstar.x>(cloud.x-15) and
    thisstar.y<(cloud.y+12) and
    thisstar.y>(cloud.y-12) then
  star.count+=1
  spark.xgen=thisstar.x
  spark.ygen=thisstar.y
  spark.fall=11
  for i=1,15 do
  add(spark,make_spark(x,y,xdir,ydir))
  end
  sfx(28)
  del(star,thisstar)
 end
--star vanishes after time
 if thisstar.t<200 then
  thisstar.t+=1
 else
  spark.xgen=thisstar.x
  spark.ygen=thisstar.y
  spark.fall=0
  for i=1,15 do
   add(spark,make_spark(x,y,xdir,ydir))
  end
  sfx(36)
  del(star,thisstar)
 end
--star movement variance
 if thisstar.t<75 then
  thisstar.x+=.04
 elseif thisstar.t<150 then
  thisstar.x-=.04
 elseif thisstar.t<225 then
  thisstar.x+=.04
 elseif thisstar.t<300 then
  thisstar.x-=0.04
 end
 if thisstar.t<35 then
  thisstar.y+=.04
 elseif thisstar.t<110 then
  thisstar.y-=.04
 elseif thisstar.t<185 then
  thisstar.y+=.04
 elseif thisstar.t<300 then
  thisstar.y-=.04
 end
end

function stargen()
-- timers for creating stars
 if flower.power>6 and
    flower.starc<400 and
    flower.starc>0 then
  flower.starc+=1
 end
 if flower.starc>399 then
  star.gen=35
  add(star,make_star(x,y,s))
  flower.starc=1
 end
 if flower.rpower>6 and
    flower.rstarc<400 and
    flower.rstarc>0 then
  flower.rstarc+=1
 end
 if flower.rstarc>399 then
  star.gen=88
  add(star,make_star(x,y,s))
  flower.rstarc=1
 end
end
  
function screenshake()
 if bg.ssc%2==0 then
  bg.ss=0
 else bg.ss=2
 end
 if bg.ssc>0 then
  bg.ssc-=1
 end
end

function bganim()
 if cloud.xcount%15==0 then
  if water.s==3 then
   water.s=4
   wind.s=9
   wind.sa=11
  else 
   water.s=3
   wind.s=8
   wind.sa=10
  end
 end
end

function powerup()
--get water from the tap
 if cloud.x>93 and
    cloud.y<45 then
  if cloud.water<9.5 then
   cloud.water+=.2
   if btn(4)==false then
    sfx(24)
   end
  end
 end
--drain at 1/2 speed till ready
 if star.count>5 then
  battery.activedrop=1
 end
--slowly drain battery
 if battery.power>0 then
  battery.power-=((.006*flower.alldead)*battery.activedrop)
 end
--get wind from the fans
 if cloud.x<36 and
    cloud.y<45 then
  if wind.power<9.5 then
   wind.power+=.2
   if btn(4)==false then
    sfx(25)
   end
  end
 end
end

function usegoodpower()
 if cloud.water>.2 then
  for i=1,2 do
   add(rain,make_rain(x,y)) 
  end
  if wind.power<.4 then
  sfx(29)
  end
  cloud.water-=.2
 end
 if wind.power>.2 then
  cloud.attract=true
  wind.power-=.1
  for i=1,10 do
   add(dust,make_dust(x,y,t)) 
  end
  sfx(34)
 else
  cloud.attract=false
 end
end

function usenastypower()
 if cloud.water>5 then
  add(zap,make_zap(x,y,s,t,ts)) 
  cloud.water-=5
 end
 if wind.power>0 then
  for i=1,5 do
   add(gust,make_gust(x,y,xdir,ydir,t))
  end
  sfx(33)
  wind.power-=.28
 end
end

function decay()
 if flower.power>0 then
  flower.power-=(.007*chomper.leat)
 end
 if flower.power<2 then
  flower.sd=32
 elseif flower.power<5.5 then
  flower.sd=16
 else
  flower.sd=0
 end
 if flower.power<2 and
    flower.rpower<2 then
  flower.alldead=1.3
 else
  flower.alldead=1
 end  
end

function decayr()
 if flower.rpower>0 then
  flower.rpower-=(.007*chomper.reat)
 end
 if flower.rpower<2 then
  flower.rsd=32
 elseif flower.rpower<5.5 then
  flower.rsd=16
 else
  flower.rsd=0
 end
end

function make_rain(x,y)
 local new_rain={
 x=cloud.x+(rnd(20)-10),
 y=cloud.y+(rnd(10)-5),
 }
 return new_rain
end

function draw_rain(thisrain)
 rectfill(thisrain.x,thisrain.y,thisrain.x,thisrain.y,7)
end

function raindrop(thisrain)
 if thisrain.y<112 then
  thisrain.y+=.8
 else
--give left side rain power
 if thisrain.x<flower.hitbox then
  flower.power+=.1
  sfx(30)
  if flower.starc==0 then
   flower.starc=1
  end
  if flower.power>9.6 then
   flower.power=9.6
  end 
 end
--give right side rain power
 if thisrain.x>flower.rhitbox then
  flower.rpower+=.1
  sfx(30)
  if flower.rpower>9.6 then
   flower.rpower=9.6
  end
  if flower.rstarc==0 then
   flower.rstarc=1
  end
 end
--damage battery
 if thisrain.x>battery.l and
    thisrain.x<battery.r then
  battery.power-=.08
 end
 del(rain,thisrain)
 end
end

function make_zap(x,y,s,t,ts)
 local new_zap={
 x=cloud.x,
 y=cloud.y,
 s=18,
 t=0,
 ts=0,
 }
 return new_zap
end

function draw_zap(thiszap)
 spr(thiszap.s,thiszap.x,thiszap.y)
end

function zapdrop(thiszap)
 if thiszap.ts==0 then
  sfx(19)
  thiszap.ts=1
 end
 if thiszap.y<104 then
  thiszap.y+=3
 else
--damage flowers
  if thiszap.x<(flower.hitbox-2) then
   if flower.power>0 then
    flower.power-=4
   end
  end
  if thiszap.x>(flower.rhitbox+2) then
   if flower.rpower>0 then
    flower.rpower-=4
   end
  end
--power up battery
  if thiszap.x>battery.l-2 and
     thiszap.x<battery.r+2 then
   battery.power+=2.25
   spark.xgen=thiszap.x
   spark.ygen=thiszap.y
   spark.fall=11
   for i=1,15 do
    add(spark,make_spark(x,y,xdir,ydir))
   end
   if battery.power>9.3 then
    battery.power=9.6
   end
  end
  bg.ssc=7
  poof.x=thiszap.x
  poof.y=thiszap.y
--hit ground
  for i=1,31 do
   add(poof,make_poof(x,y,r))
  end
  sfx(18)
  zap.contact=thiszap.x
  zap.contactt=2
  del(zap,thiszap)
 end
 if thiszap.t<5 then
  thiszap.s+=1
  thiszap.t+=1
 elseif thiszap.t<10 then
  thiszap.s-=1
  thiszap.t+=1
 else
  thiszap.s=18
  thiszap.t=0
 end
end

function make_poof(x,y,r)
 local new_poof={
 x=poof.x+(rnd(20)-10),
 y=poof.y+(rnd(20)-20),
 r=rnd(9)+5,
 }
 return new_poof
end

function draw_poof(thispoof)
 circfill(thispoof.x,thispoof.y,thispoof.r,7)
end

function poofshrink(thispoof)
 if thispoof.r>0 then
  thispoof.r-=.3
 else
  del(poof,thispoof)
 end
 if thispoof.r<3 then
  thispoof.x+=1
  thispoof.y-=1
 end
end

function movecloud()
 if btn(0) and
  cloud.xdir>-1 then
  cloud.xdir-=.2
  cloud.rv=-1
 elseif btn(1) and
  cloud.xdir<1 then
  cloud.xdir+=.2
  cloud.rv=1
 end
 if btn(2) and
  cloud.ydir>-1 then
  cloud.ydir-=.2
  cloud.rvv=-1
 elseif btn(3) and
  cloud.ydir<1 then
  cloud.ydir+=.2
  cloud.rvv=1
 end
--make movement sound
 if btn(0) or
    btn(1) or
    btn(2) or
    btn(3) then
  if cloud.tc<5 then
   cloud.tc+=1
  else
   cloud.tc=0
  end
  if cloud.tc==1 then
   sfx(23)
  end
 else
  cloud.tc=0
 end
--move cloud
 cloud.x+=cloud.xdir
 cloud.y+=cloud.ydir
--slow and stop movement
 cloud.xdir*=.8
 cloud.ydir*=.8
 if cloud.xdir<.1 and
    cloud.xdir>-.1 then
  cloud.xdir=0
 end
 if cloud.ydir<.1 and
    cloud.ydir>-.1 then
  cloud.ydir=0
 end
--cloud position variance
 if cloud.xcount<30 then
  cloud.x+=.08
  cloud.xcount+=1
 elseif cloud.xcount<59 then
  cloud.x-=.08
  cloud.xcount+=1
 else
  cloud.xcount=0
 end
 if cloud.ycount<50 then
  cloud.y+=.08
  cloud.ycount+=1
 elseif cloud.ycount<100 then
  cloud.y-=.08
  cloud.ycount+=1
 else
  cloud.ycount=0
 end
--bounds
 if cloud.x<28 then
  cloud.x=28
 elseif cloud.x>99 then
  cloud.x=99
 end
 if cloud.y<26 then
  cloud.y=26
 elseif cloud.y>100 then
  cloud.y=100
 end
--face change
 if btn(4) then
  if wind.power>.3 then
   cloud.mood=13
  else
   cloud.mood=6
  end
  usegoodpower()
 elseif btn(5) then
  if wind.power>.3 then
   cloud.mood=12
  else
   cloud.mood=7
  end
   usenastypower()
 else
  cloud.mood=0
  cloud.attract=false
 end
end

--------------draw--------------

function _draw()
 cls()
--background
 rectfill(0,0,128,128,3)
 rect(16,16+bg.ss,112,112+bg.ss,7)
--flowers
 for i=1,5 do
  spr(flower.s+flower.sd,flower.x+i*8,flower.y+bg.ss)
 end
 for i=1,5 do
  spr(flower.s+flower.rsd,flower.x+53+i*8,flower.y+bg.ss,1,1,true)
 end
--faucet
 spr(2,104,17+bg.ss)
--water and basket
 spr(water.s,104,25+bg.ss)
 spr(5,103,32+bg.ss)
 rectfill(102,40+bg.ss,112,40+bg.ss,7)
--fans and air
 spr(wind.s,17,18+bg.ss)
 spr(wind.s,17,34+bg.ss)
 spr(wind.sa,17,26+bg.ss)
--battery
 rect(battery.l,101+bg.ss,battery.r-1,112+bg.ss,7)
 rectfill(battery.l+3,99+bg.ss,battery.r-4,100+bg.ss,7)
 spr(35,battery.l+1,103+bg.ss)
--cloud powers
 foreach(rain,draw_rain)
 foreach(zap,draw_zap)
 foreach(poof,draw_poof)
 foreach(star,draw_star)
 foreach(spark,draw_spark)
 foreach(missile,draw_missile)
 foreach(trail,draw_trail)
 foreach(dust,draw_dust)
 foreach(chomper,draw_chomper)
 foreach(gust,draw_gust)
 foreach(spinner,draw_spinner)
--start screen
 if startgame.pause==true and
    startgame.finalswipe==false then
  rectfill(17,17,111,111,3)
  foreach(snow,draw_snow) 
--game name and intro
  if startgame.roll>-10 and
     startgame.roll<50 then
   map(0,2,startgame.x,startgame.y+2,11,8)
   print("-----------------------",startgame.x-1,startgame.y+65,startgame.tc)
   if hiscore.val==0 then
    print("        press ƒ        ",startgame.x-3,startgame.y+72,startgame.tc)
   else
    print("  press [x] to start  ",startgame.x-1,startgame.y+72,startgame.tc)
   end
   print("-----------------------",startgame.x-1,startgame.y+79,startgame.tc)
  end
--panel 1 introduction
  if startgame.roll>-10 and
     startgame.roll<100 then
   print("you are a cloud",startgame.x+15,startgame.y+96,startgame.tc)
   print("move with ”ƒ‹‘",startgame.x+9,startgame.y+166,startgame.tc)
   map(29,1,startgame.x,startgame.y+89,39,11)
   map(0,10,startgame.x+34,startgame.y+125,3,12)
  end
--panel 2 show off dif powers
  if startgame.roll>40 and
     startgame.roll<150 then
   map(17,1,startgame.x,startgame.y+184,27,11)
   rectfill(startgame.x+1,startgame.y+255,startgame.x+86,startgame.y+270,3)
   print("touch the faucet or",startgame.x+6,startgame.y+249,startgame.tc)
   print("fan to charge your",startgame.x+8,startgame.y+255,startgame.tc)
   print("wind or water powers",startgame.x+4,startgame.y+261,startgame.tc)
   map(0,10,startgame.x+34,startgame.y+217,3,12)
   print("fan",32,startgame.y+191,startgame.tc)
   print("[wind]",32,startgame.y+197,startgame.tc)
   print("faucet",73,startgame.y+191,startgame.tc)
   print("[water]",69,startgame.y+197,startgame.tc)
  end
--panel 3 water powers
  if startgame.roll>80 and
     startgame.roll<200 then
   map(17,1,startgame.x,startgame.y+279,27,11)
   rectfill(startgame.x+1,startgame.y+280,startgame.x+86,startgame.y+300,3)
   map(0,10,startgame.x+10,startgame.y+325,3,12)
   map(0,10,startgame.x+58,startgame.y+325,3,12)
   rectfill(startgame.x+40,startgame.y+346,startgame.x+86,startgame.y+365,3)
   spr(124,83,startgame.y+359)
   print("water powers",startgame.x+21,startgame.y+285,startgame.tc)
   print("rain [z]",startgame.x+5,startgame.y+295,startgame.tc)
   print("keeps",startgame.x+5,startgame.y+301,startgame.tc)
   print("flowers",startgame.x+5,startgame.y+307,startgame.tc)
   print("happy",startgame.x+5,startgame.y+313,startgame.tc)
   print("zap [x]",startgame.x+56,startgame.y+295,startgame.tc)
   print("charges",startgame.x+56,startgame.y+301,startgame.tc)
   print("the",startgame.x+72,startgame.y+307,startgame.tc)
   print("battery",startgame.x+56,startgame.y+313,startgame.tc)
   spr(18,83,startgame.y+347)
   spr(66,35,startgame.y+344)
   spr(67,35,startgame.y+352)
   spr(6,35,startgame.y+330)
   spr(7,84,startgame.y+330)
  end
--panel 4 wind powers
  if startgame.roll>130 and
     startgame.roll<250 then
   map(17,1,startgame.x,startgame.y+374,27,11)
   rectfill(startgame.x+1,startgame.y+375,startgame.x+86,startgame.y+395,3)
   map(0,10,startgame.x+10,startgame.y+420,3,12)
   map(0,10,startgame.x+58,startgame.y+420,3,12)
   rectfill(startgame.x+1,startgame.y+441,startgame.x+46,startgame.y+460,3)
   spr(124,35,startgame.y+454)
   print("wind powers",startgame.x+23,startgame.y+380,startgame.tc)
   print("magnet [z]",startgame.x+5,startgame.y+390,startgame.tc)
   print("redirects",startgame.x+5,startgame.y+396,startgame.tc)
   print("dangerous",startgame.x+5,startgame.y+402,startgame.tc)
   print("missiles",startgame.x+5,startgame.y+408,startgame.tc)
   print("gust [x]",startgame.x+52,startgame.y+390,startgame.tc)
   print("blows",startgame.x+64,startgame.y+396,startgame.tc)
   print("away",startgame.x+68,startgame.y+402,startgame.tc)
   print("chompers",startgame.x+52,startgame.y+408,startgame.tc)
   spr(24,35,startgame.y+442)
   spr(66,79,startgame.y+439)
   spr(67,71,startgame.y+447)
   spr(13,35,startgame.y+425)
   spr(12,84,startgame.y+425)
   spr(41,65,startgame.y+453,1,1,true)
  end
--panel 5 get stars
  if startgame.roll>180 and
     startgame.roll<300 then
   map(17,1,startgame.x,startgame.y+469,27,11)
   rectfill(startgame.x+1,startgame.y+470,startgame.x+86,startgame.y+490,3)
   map(0,10,startgame.x+10,startgame.y+515,3,12)
   map(0,10,startgame.x+58,startgame.y+515,3,12)
   rectfill(startgame.x+33,startgame.y+536,startgame.x+48,startgame.y+555,3)
   print("keep your flowers",startgame.x+11,startgame.y+475,startgame.tc)
   print("happy and they",startgame.x+16,startgame.y+481,startgame.tc)
   print("will produce stars",startgame.x+8,startgame.y+487,startgame.tc)
   spr(36,60,startgame.y+496)
   print("[rain]",28,startgame.y+507,7)
   print("[gust]",77,startgame.y+507,7)
   spr(66,79,startgame.y+534)
   spr(67,71,startgame.y+542)
   spr(66,35,startgame.y+534)
   spr(67,35,startgame.y+542)
   spr(6,35,startgame.y+520)
   spr(12,84,startgame.y+520)
   spr(41,65,startgame.y+548,1,1,true)
  end
--panel 6 stay alive
  if startgame.roll>230 and
     startgame.roll<350 then
   map(17,1,startgame.x,startgame.y+564,27,11)
   rectfill(startgame.x+1,startgame.y+565,startgame.x+86,startgame.y+585,3)
   map(0,10,startgame.x+10,startgame.y+610,3,12)
   map(0,10,startgame.x+58,startgame.y+610,3,12)
   rectfill(startgame.x+1,startgame.y+641,startgame.x+86,startgame.y+650,3)
   print("keep your battery",startgame.x+11,startgame.y+570,startgame.tc)
   print("charged to stay",startgame.x+15,startgame.y+576,startgame.tc)
   print("alive",startgame.x+35,startgame.y+582,startgame.tc)
   spr(34,60,startgame.y+591)
   print("[magnet]",24,startgame.y+602,7)
   print("[zap]",78,startgame.y+602,7)
   spr(13,35,startgame.y+615)
   spr(7,84,startgame.y+615)
   spr(24,34,startgame.y+632)
   spr(124,35,startgame.y+644)
   spr(124,84,startgame.y+644)
   spr(18,84,startgame.y+632)
  end
----panel 7 good luck
  if startgame.roll>270 and
     startgame.roll<350 then
   map(17,1,startgame.x,startgame.y+659,27,11)
   map(0,10,startgame.x+34,startgame.y+703,3,12)
   spr(6,60,startgame.y+708)
   print("balance wind and",startgame.x+13,startgame.y+665,startgame.tc)
   print("water to collect",startgame.x+13,startgame.y+671,startgame.tc)
   print("as many stars as",startgame.x+13,startgame.y+677,startgame.tc)
   print("possible until",startgame.x+17,startgame.y+683,startgame.tc)
   print("you run out of",startgame.x+17,startgame.y+689,startgame.tc)
   print("power",startgame.x+35,startgame.y+695,startgame.tc)
   print("good luck!",startgame.x+25,startgame.y+725,startgame.tc)
   print("press [x] to start",startgame.x+9,startgame.y+731,startgame.tc)
  end
--patch rect
  rect(16,16,112,112,7)
--startgame swipe
  if startgame.lastwiper>0 and
     startgame.finalswipe==false then
   circfill(64,64,startgame.lastwiper,3)
   circ(64,64,startgame.lastwiper,7)
   rect(16,16,112,112,7)
  end
 end
--final startgame swipe
 if startgame.pause==true and
    startgame.finalswipe==true then
  circfill(cloud.x,cloud.y-1+bg.ss,6+cloud.rv-cloud.rvv,7)
  circfill(cloud.x+3,cloud.y+5+bg.ss,3+cloud.rv+cloud.rvv,7)
  circfill(cloud.x-3,cloud.y+5+bg.ss,4-cloud.rv+cloud.rvv,7)
  circfill(cloud.x-6,cloud.y+bg.ss,3-cloud.rv-cloud.rvv,7)
  circfill(cloud.x+6,cloud.y+bg.ss,4+cloud.rv-cloud.rvv,7)
  print(cloud.face,cloud.x+(cloud.rv*3)-3,cloud.y+(cloud.rvv*3)-2+bg.ss,3)
  spr(cloud.mood,cloud.x+(cloud.rv*3)-3,cloud.y+(cloud.rvv*3)-2+bg.ss)
  circfill(64,64,startgame.finalswiper,3)
  circ(64,64,startgame.finalswiper,7)
  rect(16,16,112,112,7)
 end
--cloud
 if startgame.pause==false then
  circfill(cloud.x,cloud.y-1+bg.ss,6+cloud.rv-cloud.rvv,7)
  circfill(cloud.x+3,cloud.y+5+bg.ss,3+cloud.rv+cloud.rvv,7)
  circfill(cloud.x-3,cloud.y+5+bg.ss,4-cloud.rv+cloud.rvv,7)
  circfill(cloud.x-6,cloud.y+bg.ss,3-cloud.rv-cloud.rvv,7)
  circfill(cloud.x+6,cloud.y+bg.ss,4+cloud.rv-cloud.rvv,7)
  print(cloud.face,cloud.x+(cloud.rv*3)-3,cloud.y+(cloud.rvv*3)-2+bg.ss,3)
  spr(cloud.mood,cloud.x+(cloud.rv*3)-3,cloud.y+(cloud.rvv*3)-2+bg.ss)
 end
--bg mask boxes
 rectfill(0,0,15,128,3)
 rectfill(0,0,128,15,3)
 rectfill(0,113,128,128,3)
 rectfill(113,0,128,128,3)
--power bar colorset
 local wfill=7
 local bfill=7
 local sfill=7
 local wifill=7
 if cloud.water<0.21 then
  wfill=3
 end
 if battery.power<.02 then
  bfill=3
 end
 if star.count<1 then
  sfill=3
 end
 if wind.power<0.21 then
  wifill=3
 end
--power bars
--water
 rectfill(115,16+bg.ss,116,16+(cloud.water*10)+1+bg.ss,wfill)
--battery
 rectfill(16,115+bg.ss,16+(battery.power*10)+1,116+bg.ss,bfill)
--wind
 rectfill(12,16+bg.ss,13,16+(wind.power*10)+1+bg.ss,wifill)
--stars
 if star.count>0 then
  if star.count<50 then
   for i=1,star.count do
    rectfill(14+(i*2),12+bg.ss,14+(i*2),13+bg.ss,7)
   end
  elseif star.count>49 then
   for i=1,49 do
    rectfill(14+(i*2),12+bg.ss,14+(i*2),13+bg.ss,7)
   end
  end
 end
--sketchy patches
 rectfill(11,113,13,115,3)
 rectfill(115,113,117,115,3)
--border text
 print("stars",55,5+bg.ss,7)
 print("electricity",43,119+bg.ss,7)
 print("w",7,53+bg.ss,7)
 print("i",7,59+bg.ss,7)
 print("n",7,65+bg.ss,7)
 print("d",7,71+bg.ss,7)
 print("w",119,50+bg.ss,7)
 print("a",119,56+bg.ss,7)
 print("t",119,62+bg.ss,7)
 print("e",119,68+bg.ss,7)
 print("r",119,74+bg.ss,7)
 if startgame.pause==true then
--bg mask boxes
  rectfill(0,0,15,128,3)
  rectfill(0,0,128,15,3)
  rectfill(0,113,128,128,3)
  rectfill(113,0,128,128,3)
  circfill(64,64,startgame.bgr,3)
  circ(64,64,startgame.bgr,7)
  if startgame.t<75 then
   sspr (48,40,32,32,49+startgame.eggx,57+startgame.eggy+bg.ss,32+startgame.eggw,32+startgame.eggh)
   rectfill(startgame.chomperx+3,64,128,72,3)
   rectfill(startgame.chomperx+11,56,128,63,3)
  end
  spr(startgame.chomperspr,startgame.chomperx,startgame.chompery)
  spr(startgame.chomperspr,startgame.chomperx+8,startgame.chompery-8)
 end
--endgame
 if endgame.pause==true then
--game over box and text
  rectfill(17,17,112,endgame.goy+14+bg.ss,3)
  rect(16,16,112,endgame.goy+14+bg.ss,7)
  print("game over",endgame.gox,endgame.goy+bg.ss-14,7)
  print("press [x] to continue",endgame.hsx-24,endgame.goy+bg.ss-7,7)
--hiscore box and text
  rectfill(17,endgame.hsy+bg.ss,112,112,3)
  rect(16,endgame.hsy+bg.ss,112,112,7)
  print("your star count:",endgame.hsx-24,endgame.hsy+bg.ss+19,7)
  print(star.count,endgame.hsx+40,endgame.hsy+bg.ss+19,7)
  print("best star count:",endgame.hsx-24,endgame.hsy+bg.ss+26,7)
  print(hiscore.val,endgame.hsx+40,endgame.hsy+bg.ss+26,7)
--patch to clean up anim
  rectfill(0,0,15,128,3)
  rectfill(0,0,128,15,3)
  rectfill(0,113,128,128,3)
  rectfill(113,0,128,128,3)
  print("stars",55,5+bg.ss-endgame.tv,7)
  print("electricity",43,119+bg.ss+endgame.tv,7)
  print("w",7-endgame.tv,53+bg.ss,7)
  print("i",7-endgame.tv,59+bg.ss,7)
  print("n",7-endgame.tv,65+bg.ss,7)
  print("d",7-endgame.tv,71+bg.ss,7)
  print("w",119+endgame.tv,50+bg.ss,7)
  print("a",119+endgame.tv,56+bg.ss,7)
  print("t",119+endgame.tv,62+bg.ss,7)
  print("e",119+endgame.tv,68+bg.ss,7)
  print("r",119+endgame.tv,74+bg.ss,7)
--main green swipe
  rectfill(129,-1,endgame.gsx,129,3)
  rect(129,-1,endgame.gsx,129,7)
 end
--bring in text during intro wipe
 if startgame.lastwiper>0 and
    startgame.pause==true then
  print("stars",55,5+startgame.tstar,7)
  print("electricity",43,119+startgame.telec,7)
  print("w",7+startgame.twind,53,7)
  print("i",7+startgame.twind,59,7)
  print("n",7+startgame.twind,65,7)
  print("d",7+startgame.twind,71,7)
  print("w",119+startgame.twater,50,7)
  print("a",119+startgame.twater,56,7)
  print("t",119+startgame.twater,62,7)
  print("e",119+startgame.twater,68,7)
  print("r",119+startgame.twater,74,7)
  rectfill(16,115,16+startgame.elecbar,116,7)
 end
--intro snowfall
 if startgame.pause==true and
    startgame.finalswipe==false then
  foreach(snow,draw_snow) 
 end 
end
__gfx__
00000000000000000000000000700000070000000000000000000000000000007077777070777770000707000000700000000000000000000000000000000000
00000000000000000007777007000000007000007000007000000000300000300700000707000007000070000007070030000030000000000000000000000000
00700700070007000000770000700000070000007777777000000000030003000707070707007007000707000000700003000300030003000000000000000000
00077000707070700777777707000000007000007000007000000000000000000700700707077707000070000007070000000000003030000000000000000000
00077000070007000777777700700000070000007707077000000000000000000707070707007007000707000000700000000000030003000000000000000000
00700700007000700770000007000000007000007070707000000000000000000700000707000007000070000007070000030000000000000000000000000000
00000000007700770770000000700000070000000700070000300300000000007077777070777770000707000000700000303000000000000000000000000000
00000000007000700000000007000000007000000077700000033000000000000000000000000000000000000000000000030000000300000000000000000000
00000000000000000000077700007700000770000007700000770000777000000070707000007000000070000000000000000000000000077777000000000000
00000000000000000000777000007700000770000007700000770000077700000007770000707770007770700000000000000000000000777777700000000000
00000000000000000007770000007000000700000000700000070000007770000077077000077070007077000000000000000000000007777777770000000000
00000000070007000077000000070000000700000000700000007000000077000007770000777777077777700000000000000000000077777777777770000000
00000000707070700007700000070000000700000000700000007000000770000007770000777700000777700000000000000000007777777777777777700000
00000000070007000077000000700000000700000000700000000700000077000007770007077070007077070000000000000000077777777777777777700000
00000000007000700700000000700000007000000000070000000700000000700007070007700000000000770000000000000000777777777777777777700000
00000000070007007000000007000000007000000000070000000070000000070000700000000000000000000000000000000000777777777777777777770000
00000000000000000000000000000000000700000007000000070000000700000000700000000000000000000000000000000000777777777777777777770000
00000000000000000000777000007700007770000007000000070000000700000007700700070070000000000007007000000000077777737773777777770000
00000000000000000007770000077000777777700777770000777000077777000770777000077770007007000007777000000000007777777777777777700000
00000000000000000077000000770000077777000077700000777000007770000077707000707070000777700070707000000000007777777777777777700000
00000000000000000007700000077000007770000077700000777000007770000007777707777770007070700777777000000000007777777777777770000000
00000000000000000077000000770000077077000077700000777000007770000007777000077777077777700007777700000000007777777777777700000000
00000000007000700700000007000000770007700700070000707000070007000777777007777770077777770777777000000000000777777777777700000000
00000000770777070000000000000000000000000000000000000000000000000007007000070700007007000007070000000000000777777777777000000000
00000000000000000000000000000000000000000000000000000000000000000000070000707000000000000000000000000000000777777707770000000000
00000000000000000000000000000000000000000000000000000000000000000777777007777770070700000007007000000000000007770000000000000000
00000000000000000000000000000000000000000000000000000000000000000070777777777000070770000007777000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000077777007777770777707700070707000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000770777707070700077777000777777000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000007707007777000777707000007777700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000707007007000077777700777777000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000007000000007070000000000000000000000000000000000
77777777777777770000700000000700000000000000000000000000000000000000000000000000000000007777777700077000000007770000000000000000
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700077000000077700000000000000000
70000000000000000700000000700000000000000000000000000000000000000000000000000000000000000007770700777700000777000700070000000000
70000000000000000000000700007000000000000000000000000000000000000000000000000000000000000000700700777700007700007070707000000000
70000000000000000007000000000007000000000000000000000000000000000000000000000000000000000077777707777770000770000700070000000000
70000000000000000000000007000000000000000000000000000000000000000000000000000000000000000077777707777770007700000070007000000000
70000000000000000000070000000700000000000000000000000000000000000000000000000000000000000077000707777770070000000077007700000000
70000000000000000700000000000000000000000000000000000000000000000000000000000000000000000077000700777700700000000070007000000000
70000000700000077777777700000000000700000000000000777777777777777777777777777000000000007777777770000007000077000000000000007000
70000000700000077000000700000000000700000000000000700000000000000000000000007000000000007000000007000070000000700007007000707770
70000000700000077000000700000000000700000000000000707770077007707700077007707000000000007707777000000000070707000007777000077070
70000000700000077000000700000000000700000000000000707000700070007070707070007000000000007070000700077000000000000070707000777777
70000000700000077000000700000000000700000000000000707700700070007070707070007000000000007070700700077000000000000777777000777700
70000000700000077000000700000000000700000000000000707000707070707070707070707000000000007070070700000000070707000007777707077070
70000000700000077000000700000000000700000000000000707770777077707070770077707000000000007070000707000070000000700777777007700000
70000000700000077000000777777777000700000000000000700000000000000000000000007000000000007707777070000007000077000007070000000000
00000007777777777000000000000000000000000000000000700007707770777077700770007000000000000000000700000007000000077000000077077770
00000007000000077000000000000000070000000000000000700070007070777070007000007000000000000007000707777707000000077000070070700007
00000007000000077000000000000000007000000000000000700070007770707077007770007000000000000070000707000707000000077000700070707007
00000007000000077000000000000000000700000000000000700070707070707070000070007000000000000007000707000707000000077000070070700707
00000007000000077000000000000000000070070000000000700077707070707077707700007000000000000070000700777007000000077000700070700007
00000007000000077000000000000000000007070000000000700000000000000000000000007000000000000007000777777777000000007000070077077770
00000007000000077000000000000000000000070000000000777777777777777777777777777000000000000070000700000007000000007000700070000000
00000007000000077777777700000000000077770000000000000000000000000000000000000000000000000007000700000007000000777000000070000000
00000000000000070000000077770000000000000000777700000000000000000000000000000000000000000000000000077000707777700000000000000000
00000000000000070000000070000000000000700000000700000000000000000000000000000000000000000700070007777770070000070000000000000000
00000000000000070000000070700000000007000000070700000000000000000000000000000000000000007070707007000070070707070000000000000000
00000000000000070000000070070000000070000000700700000000000000000000000000000000000000000700070007007070070070070000000000000000
00000000000000070000000000007000700700000007000000000000000000000000000000000000000000000070007007070070070707070000000000000000
00000000000000070000000000000700707000000070000000000000000000000000000000000000000000000077007707007070070000070000000000000000
00000000000000070000000000000070700000000700000000000000000000000000000000000000000000000070007007000070707777700000000000000000
77777777777777770000000000000000777700000000000000000000000000000000000000000000000000007777777777777777000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005b4141414141414141414b00404141414141414141416100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40410061410040610040610000000000006e0000000000000000006b00500000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62700060000062710062710000000000006f0000000000000000006c00500000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071006000005060005054000000000000500000000000000000006000500000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000500000000000000000006000500000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041005060004041006141000000000000500000000000000000006000500000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5070005060006270006000000000000000500000000000000000006000500000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6271006271007071006000000000000000500000000000000000006000500000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000500000000000000000006000500000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1e1f0000000000000000000000000000500000000000000000006000500000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2e2f0000000000000000000000000000627b7b7b707c707b7b7b7100625353535353535353537100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d3e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0102000008170091700a1700c17010170111700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001a3701e3701e3701d3701a3701737014370103700c3700a37008370053700437003370023700237000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001e5701a5701a5701f57000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000017575155751357511575105750e5750c50511505115050c50012500155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01260000183752137500005000052137522375213751f3751d37521375183050030500305003050030515305213751c375183051c3051c3751d3751c3751a375183751c3751d3751e3751f375000000000000000
01260000243752237500305003052237526375003052937500305243752137500305003052b37529375003052b3752d37500305213052d3752e3752d3752b375293751d305003051c3051c3051c3051a3051a305
0156000011174111511113111111111741115111131111111317413151131311311113174131511313113111181741815118131181110e1740e1510e1310e111161741615116131161110c1740c1510c1310c111
01560000131741315115134151310e1740e1510e1310e111161741615115134151311017410151101311011111174111511d1341d131221742215121134211311f1741f15121134211311f1741f1511f1311f111
015600001117411151111311111115174151510c1340c1111a1741a1511a1311a1111017410151101311011111174111511113111111161741615115134151111317413151131341311113174131511513415111
01560000181741815115134151110e1740e15113134131111117411151111311111113174131511313113111151741515115131151110e1740e1510e1310e1111617416151151341513110174101511013110111
012b001000003000000f0730f00300003000030f0730000300003000030f0730000300003000030f0730000300003000030f0730000300003000030f0730000300003000030f0730000300003000030f07300003
010100002a33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
016900000517405151051310511105174051510513105111071740715107131071110717407151071310711100174001510013100111021740215102131021110a1740a1510a1310a11100174001510013100111
0169000007174071510713107111021740215102131021110a1740a1510a1310a1110417404151041310411105174051311113411111161541613115134151111315413131151341511113154131511313113111
0169000005174051510513105111091740913100134001110a1740a1710a1610a1510a1410a1310a1210a1110517405151051310511115154151510c1340c1111615416151161311611105134051310513105131
016900000c1740c13109134091110217402131071340711105174051710516105151051410513105121051110c1740c15115134151110e1540e15113134131111115411131111311113111114111111111111111
000500001457512575105750e5750d5750c5750c50511505115050c50012500155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000055500555015550255502555035550455504555055550655506555075550855508555095550a5550a5550b5550c5550c5550d5050e5050e5050f5050e5550c5550b5550955507555055550455502555
010100001b3702137028370233701d3701837013370103700d3700b37008370053700437003370043000430000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002c0702b070290702707025070240702107020070004000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000193701d3701e370183700f3700b3700837005370023700137001370063000430002300043000430000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000153701c37020370173700f3700b37008370063700437002370023700d3000c3000a300093000830007300003000000000000000000000000000000000000000000000000000000000000000000000000
010100000a0200b0200d02011020140201a0201b5001a000180001800400004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000016010170101901011000140001a0001b5001a000180001800400004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003901500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018170211701f1701d1701c1701d1701c1701a170241702e1702d1702b1702917029170281701d1701f170211701817018170211701a1701817022170211701f1701d1701d1701c1701d1701f1701d170
011800002e1752d1752b17529175281752917529175301751d1053970139701397013970121700217000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000037135351353413535135351353c13529105301051d1053970139701397013970121700217000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003e11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003711000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f0000044101d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000541019000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002637100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000241702617027170281702b1702e1702c1702917027170211701c17018170121700b170081700617000100000000000000000000000000000000000000000000000000000000000000000000000000000
01030000301553515535105341053210530105291053010537105110001000011000110000c000217000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001855517555165551555514555135551255511555105550f5550e5550d5550c55508505095050a5050a5050b5050c5050c5050d5050e5050e5050f5050e5050c5050b5050950507505055050450502505
01260000241752d17500105001052d1752e1752d1752b175291752d1751810500105001050010500105151052d17528175181051c105281752917528175261752417528175291752a1752b175003000010000100
01260000301752e17500305003052e17532175001053517500105301752d175001050010537175351750010537175391750010521105391753a1753917537175351751d105001051c1051c1051c1051a1051a305
01260000181451d145211051a105181451814522145211451f145211451d1451814518105181051810521145211451f1451c14518145181451c145211451f1451c145181451d1051e1051a145181451810500105
01a4000005134051310512105111051010910100104001010a1040a1010a1010a1010a1010a1010a1010a1010510405101051010510115104151010c1040c1011610416101161011610105104051010510105101
01a400000c1340c1310c1210c111091040910100104001010a1040a1010a1010a1010a1010a1010a1010a1010510405101051010510115104151010c1040c1011610416101161011610105104051010510105101
01a4000011134111211111111101091040910100104001010a1040a1010a1010a1010a1010a1010a1010a1010510405101051010510115104151010c1040c1011610416101161011610105104051010510105101
01a4000013134131211311113101091040910100104001010a1040a1010a1010a1010a1010a1010a1010a1010510405101051010510115104151010c1040c1011610416101161011610105104051010510105101
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
00 04 42 43 44
00 05 42 43 44
01 0c 0d 43 44
02 0e 0f 43 44
00 26 42 43 44
04 27 42 43 44
00 29 2a 2b 2c
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
