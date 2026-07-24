pico-8 cartridge // http://www.pico-8.com
version 14
__lua__





 ------------------------------
 -------   cat bandit   -------
 -------  eggnog games  -------
 -------      2018      -------
 -------  andrew reist  -------
 ------- @platformalist -------
 ------------------------------
 ---- thanks for playing!! ----
 ------------------------------






cartdata("eggnog_catbandit_1")
state=0
menu=1
b1=0
b2=6
swipe=170
readycount=100
pause=false
pausepatch=false
banditmode=true
modename="bandit mode"
if dget(61)==1 then
 banditmode=false
 modename="normal mode"
end
titlepause=0
titleswipe=107
tss=0
bss=0
mss=0
lev30=false

 -----------  init  -----------

function _init()
 game={}
  game.level=1
  game.t=0
  game.timetarget=0
  game.x=0
  game.y=0  
  game.marquee="nvm"
  game.marqueelimit=#game.marquee*8
  game.marqueecount=0
  game.levx=1
  game.levy=1
  game.door=38
  game.slimed=false
  game.exitslime=40
  game.exitsplode=0
  game.currenttime=0
  game.targetlength=0
  game.swipetarget=0
  game.readyval=0
  game.wipecheck=false
  game.wipex=1
  game.banditunlock=true
  game.exitlevelmessage=nil
  game.exitlevelh=nil
  if dget(30)==1 then
   game.banditunlock=false
  end
  game.champion=true
  for i=1,60 do
   if dget(i)!=17 then
    game.champion=false
   end
  end

 cat={}
  cat.x=64
  cat.y=84
  cat.s=6
  cat.sf=false
  cat.spd=1
  cat.mom=.55
  cat.r=0
  cat.l=0
  cat.t=0
  cat.b=0
  cat.xc=0
  cat.yc=0
  cat.wsfx=true
  cat.lastbutton=1

 bullet={}
  bullet.hit=false

 bullethit={}
  for i=1,4 do
   bullethit[i]=0
  end

 button={}

 chimney={}

 coin={}

 diamond={}

 door={}

 exhaust={}

 fireball={}

 mud={}

 sentry={}
  sentry.hit=false

 sentryhit={}
  for i=1,4 do
   sentryhit[i]=0
  end

 shard={}

 slider={}

 smoke={}

 sparkle={}

 speeder={}

 starset={}
  for i=1,15 do
   starset[i]=0
  end
  starset.saveval=dget(game.level)
   
 vase={}

 wall={}

 zapper={}

 translate("tobin")

 vault=dget(63)

 setlevel()

 if menu==3 then
  music(6)
 end

end

function setlevel()
--set base level values
 game.diamondget=false
 game.vasebroken=false
 game.a=0
 game.coincount=0
 game.cointarget=0
 game.stealth=18
 game.exitswipe=0
 game.exitpause=10
 game.exitvibe=14
 game.menutimer=40
 game.exitvel=0 
 game.carx=0
 game.cary=0
 game.buttonhit=false 
 cat.boost=3
 cat.boosting=false
 cat.xd=0
 cat.yd=0
 cat.lastbutton=1
 game.displaytime=false
 readycount=100
 game.slimed=false
end

 -----------  menu  -----------

menuitem(1,"reset level", function() restartlevel() end)
menuitem(2,"quit to menu", function() quitlevel() end)
menuitem(3,"adjust color", function() brightness() end)
menuitem(4,"toggle cat sfx", function() walkingsfx() end)
menuitem(5,"wipe progress", function() wipedata() end)

function restartlevel()
 if state!=1 then
  demapper()
  swiper(0,2,0,0)
 else
  quitlevel()
 end
end

function quitlevel()
 gl=game.level
 swiper(0,1,10,29)
end

function brightness()
 if b2<12 then
  b2+=1
 else
  b2=5
 end
end

function walkingsfx()
 if cat.wsfx==true then
  cat.wsfx=false
 else
  cat.wsfx=true
 end
end

function wipedata()
 for i=1,61 do
  dset(i,1)
 end
 dset(63,0)
 game.banditunlock=false
 state=1
 menu=1
 banditmode=false
 modename="normal mode"
 _init()
end

 ----------  update  ----------

function _update()
 if state==0 then
  title()
 end
 if pause==false then
  if state==1 then
   intro()
  end
  if state==2 then
   catwalk()
   timer()
   foreach(sentry,sentrybehavior)
   foreach(bullet,bulletbehavior)
   foreach(zapper,zapperbehavior)
   foreach(smoke,smokebehavior)
   foreach(slider,sliderfall)
   foreach(speeder,speederfade)
   foreach(wall,wallbehavior)
   foreach(vase,vasebehavior)
   foreach(shard,shardbehavior)
   foreach(door,doorbehavior)
   foreach(coin,coinbehavior)
   foreach(button,buttonbehavior)
   foreach(diamond,diamondbehavior)
   foreach(mud,mudbehavior)
   foreach(fireball,fireballbehavior)
  end
  if state==3 then
   exitlevel()
   foreach(exhaust,exhaustbehavior)
  end
 else
  swipebehavior()
 end
 juicerules()
 readybehavior()
 foreach(sparkle,sparklebehavior)
 foreach(chimney,chimneybehavior)
end

function title()
 if titlepause==0 then
  sfx(41)
 end
 if titlepause<20 then
  titlepause+=1
 else
  titlepause=20
  if titleswipe>20 then
   titleswipe-=5
  else
   titleswipe=20
--set cartdata if never played
   if dget(1)==0 then
    wipedata()
   end
   state=1
   music(0)
  end
 end
end  

function starcheck()
--set array values based on
--player performance
 for i=1,5 do
  starset[i]=0
 end
 if game.diamondget==true then
  starset[1]=1
 end
 if game.coincount==game.cointarget then
  starset[2]=1
 end
 if game.vasebroken==false then
  starset[3]=1
 end
 if game.t-.11<game.timetarget then
  starset[4]=1
 end
 k=1
 for i=1,4 do
  if starset[i]!=1 then
   k=0
  end
 end
 starset[5]=k
--log current round to starset
--[11 to 15] for exit display
 for i=1,5 do
  starset[i+10]=starset[i]
 end
--check for existing save data
 starset.saveval=dget(game.level)
 translate("compare")
--compare old and new save data
 compare()
--adjust and save data to cart
 translate("tonum")
 starsave(game.level)
--set end-level message
 if dget(game.level)!=1 then
  game.exitlevelmessage="(x) next level\n(z) try again\n(up) level select"
  game.exitlevelh=5
 else
  game.exitlevelmessage="(z) try again\n(up) level select"
  game.exitlevelh=2
 end
end

function juicerules()
 if tss>0 then
  tss-=1
 end
 if bss>0 then
  bss-=1
 end
 if mss>0 then
  mss-=1
 end
--pause patch
 if pausepatch==true and
    state==1 and
    swipe==170 then
  pause=false
  pausepatch=false
 end
end

function juice(var,x,sound)
 if var==1 then
  tss=x
 elseif var==2 then
  bss=x
 elseif var==3 then
  mss=x
 end
 if sound!=0 then
  sfx(sound)
 end
end

function compare()
 for i=1,5 do
  if starset[i+5]>starset[i] then
   starset[i]=starset[i+5]
  end
 end
end

function starsave(l)
 dset(game.level,starset.saveval)
end

function translate(var)
 num(0,0,0,0,0,1,var)
 num(0,0,0,1,0,2,var)
 num(0,0,1,0,0,3,var)
 num(0,0,1,1,0,4,var)
 num(0,1,0,0,0,5,var)
 num(0,1,0,1,0,6,var)
 num(0,1,1,0,0,7,var)
 num(0,1,1,1,0,8,var)
 num(1,0,0,0,0,9,var)
 num(1,0,0,1,0,10,var)
 num(1,0,1,0,0,11,var)
 num(1,0,1,1,0,12,var)
 num(1,1,0,0,0,13,var)
 num(1,1,0,1,0,14,var)
 num(1,1,1,0,0,15,var)
 num(1,1,1,1,0,16,var)
 num(1,1,1,1,1,17,var)
end
 
function num(a,b,c,d,e,z,var)
--translate binary array to num
 if var=="tonum" then
  if starset[1]==a and
     starset[2]==b and
     starset[3]==c and
     starset[4]==d and
     starset[5]==e then
   starset.saveval=z
  end
--translate num to binary array
 elseif var=="tobin" then
  if starset.saveval==z then
   starset[1]=a
   starset[2]=b
   starset[3]=c
   starset[4]=d
   starset[5]=e
  end
 elseif var=="compare" then
  if starset.saveval==z then
   starset[6]=a
   starset[7]=b
   starset[8]=c
   starset[9]=d
   starset[10]=e
  end
 end
end

function timer()
--run timer with time cap
 if state==2 then
  if game.t<99.5 then
   game.t+=.03
  else
   game.t=99.5
  end
  if game.stealth==0 then
   game.a-=.1
  end
 end
--stealth bar limit
 if game.stealth<0 then
  game.stealth=0
 end
--flashing exit door
 if game.door==38 then
  game.door+=1.75
 else
  game.door-=.25
 end
--end level if time runs out
 if game.a<0 then
  statechange(0)
 end
end

function statechange(i)
 lev30=false
--set fail state
 if i==0 then
  game.a=0
  game.slimed=true
  game.menutimer=10
 else
--change message if level 30
  if game.level==30 then
   lev30=true
  end
 end
--change state
 state=3
end

function exitlevel()
 ges=game.exitswipe
--add cash stash to the vault
 if game.exitpause==1 and
    game.slimed==false then
  vault+=game.coincount
 end
--vault cap
 if vault>600 then
  vault=600
 end
--log vault to memory
 dset(63,vault)
--pause for a moment
 if game.exitpause>0 then
  game.exitpause-=1
 else 
  if ges<82 then
   game.exitswipe+=5
  elseif ges>82 and
         ges<89 then
   juice(2,2,0)
   timecheck()
   game.displaytime=true
   sfx(12)
   game.exitswipe=89
  end
 end
--vibrate car
 if ges==89 then
  if game.exitvibe>0 then
   game.exitvibe-=1
  else
   game.exitvibe=0
  end
  if game.menutimer>0 then
   game.menutimer-=1
   if game.menutimer==1 and
    game.slimed==true then
    music(9)
   end
  else
   game.menutimer=0
  end
 end
 local y=0
 if game.exitvibe%2==0 then
  y=1
 end
--accelerate car
 if game.exitvibe==0 and
    game.a>0 and
    game.exitvel<8 then
  game.exitvel+=.5
 end
--add exhaust
 if game.carx<100 then
  for i=1,5 do
   add(exhaust,make_exhaust(x,y,r,c))
  end
 end
 if game.carx>100 and
    game.carx<110 then
  music(2)
 end
--move car
 if game.carx<120 then 
  game.cary=y
  if game.a>0 then
   game.carx+=game.exitvel
  end
 else
  if game.exitsplode>0 then
   game.exitsplode-=1
  else
   game.exitsplode=18
   for i=1,11 do
    add(sparkle,make_sparkle(rnd(88)+14,rnd(88)+14,xd,yd,m,t))
   end
  end
 end
--restart and lev select
 if game.menutimer==0 then
--try again
  if btnp(4) then
   swiper(0,2,0,0)
--next level
  elseif btnp(5) and
         dget(game.level)!=1 then
   if game.level==30 then
    banditmode=true
    dset(61,2)
   end
   if game.level!=60 then
    game.level+=1
   end
   swiper(0,2,0,0)
--level select
  elseif btnp(2) then
   gl=game.level
   swiper(0,1,10,29)
  end
 end
--loop exitslime dance
 if game.exitslime<43.75 then
  game.exitslime+=.25
 else
  if game.exitslimesf==true then
   game.exitslimesf=false
  else
   game.exitslimesf=true
  end
  game.exitslime=40
 end
end

function timecheck()
 game.currenttime=flr(game.t*10)/10
 if game.timetarget>9 then
  game.targetlength=1
 else
  game.targetlength=0
 end
end

function changemode(a,b,v)
 banditmode=a
 dset(61,b)
 modename=v
 game.levx=1
 game.levy=1
end

function intro()
 rnds=flr(rnd(4)+34)
--opening screen actions
 if menu!=3 then
  if btn(2) then
   if tss<2 then
    sfx(rnds)
   end
   juice(1,3,0)
  end
  if btn(3) then
   if bss<2 then
    sfx(rnds)
   end
   juice(2,3,0)
  end
 end
 if menu==1 then
--select bandit mode if unlocked
  if game.banditunlock==true then
   if btnp(2) then
    if banditmode==false then
     changemode(true,2,"bandit mode")
    else
     changemode(false,1,"normal mode")
    end
   end
  end
--add chimney smoke
  for i=1,2 do
   add(chimney,make_chimney(98,36,r,d,xl,xr))
  end
--title screen actions
  if btnp(4) then
   pageturn(2)
  elseif btnp(5) then
   starset.saveval=dget(game.level)
   translate("tobin")
   pageturn(3)
  end
--credits screen actions
 elseif menu==2 then
  if btnp(5) then
   pageturn(1)
  elseif btnp(4) then
   juice(1,2,0)
   juice(2,2,rnds)
  end
--level select screen actions
 elseif menu==3 then
  if btnp(4) then
   pageturn(1)
  elseif btnp(5) then
   swiper(0,2,0,0)
  end
--set level and box coordinates
  if btnp(0) then
   if game.levx>1 then
    game.levx-=1
    sfx(rnds)
   else
    if lockcheck(game.level,4) then
     game.levx=6
     sfx(rnds)
    else
     locked()
    end
   end
  elseif btnp(1) then
   if game.levx<6 then
    if lockcheck(game.level,0) then
     game.levx+=1
     sfx(rnds)
    else
     locked()
    end
   else
    game.levx=1
    sfx(rnds)
   end
  end
  if btnp(2) then
   if game.levy>1 then
    game.levy-=1
    sfx(rnds)
   else
    if lockcheck(game.level,23) then
       game.levy=5
     sfx(rnds)
    else
     locked()
    end
   end
  elseif btnp(3) then
   if game.levy<5 then
    if lockcheck(game.level,5) then
     game.levy+=1
     sfx(rnds)
    else
     locked()
    end
   else
    game.levy=1
    sfx(rnds)
   end
  end
  gy=game.levy
  gx=game.levx
--alter level val if hard mode
  if banditmode==true then
   glv=30
  else
   glv=0
  end
  game.level=gx+((gy-1)*6)+glv
--grab save val, translate to
--binary array to display stars
  if btnp(0) or
     btnp(1) or
     btnp(2) or
     btnp(3) then
   starset.saveval=dget(game.level)
   translate("tobin")
   for i=1,5 do
    add(sparkle,make_sparkle(gx*12+18,gy*12+33,xd,yd,m,t))
   end
  end
 end
--set text & check string length
 if game.banditunlock==false then
  textset(1,"(x) level select                      (enter) menu                      (z) credits")
 else
  textset(1,"(up) change game mode                      (enter) menu                      (x) level select                      (z) credits")
 end
 textset(2,"(x) return")
 textset(3,"(x) select level                        (arrow keys) choose level                        (z) back")
 game.marqueelimit=(#game.marquee*4)+94
--scroll the text!
 if game.marqueecount>game.marqueelimit then
  game.marqueecount=0
 else
  game.marqueecount+=1
 end 
end

function pageturn(i)
 menu=i
 game.marqueecount=0
 juice(1,2,0)
 juice(2,2,rnds)
end

function locked()
 juice(3,2,0)
 sfx(40)
end

function lockcheck(l,v)
 if dget(l+v)!=1 then
  return true
 end
end

function textset(m,t)
 if menu==m then
  game.marquee=t
 end
end

function catwalk()
--movement
 if btn(0) then
   cat.xd=cat.spd*-1
   cat.sf=true
 elseif btn(1) then
   cat.xd=cat.spd
   cat.sf=false
 end
 if btn(2) then
   cat.yd=cat.spd*-1
 elseif btn(3) then
   cat.yd=cat.spd
 end
--set last btn pressed
 if btn(0) then
  cat.lastbutton=0
 elseif btn(1) then
  cat.lastbutton=1
 elseif btn(2) then
  cat.lastbutton=2
 elseif btn(3) then
  cat.lastbutton=3
 else
  cat.lastbutton=nil
 end
--animation
 if btn(0) or
    btn(1) or
    btn(2) or
    btn(3) then
  if cat.s<9.75 then
   cat.s+=.25
  else
   cat.s-=3.75
  end
 else
  cat.s=6.75
 end
--speed cap
 if btn(0)!=true and
    btn(1)!=true then 
  if cat.xd>.03 or
     cat.xd<-.03 then
   cat.xd*=cat.mom
  else
   cat.xd=0
  end
 end
 if btn(2)!=true and
    btn(3)!=true then
  if cat.yd>.03 or
     cat.yd<-.03 then
   cat.yd*=cat.mom
  else
   cat.yd=0
  end
 end
--drop boost speed
 if cat.spd>1 then
  cat.spd-=.5
 else
  cat.spd=1
 end
--start boost
 if btn(4) or
    btn(5) then
  if cat.boosting==false then
   juice(2,2,0)
   spdcatset(0,cat.spd*-1,0)
   spdcatset(1,cat.spd,0)
   spdcatset(2,0,cat.spd*-1)
   spdcatset(3,0,cat.spd)
   if cat.lastbutton==nil then
    if cat.sf==true then
     i=-3
    else
     i=3
    end
    spdcatset(nil,i,0)
   end
  end
 end
--add sparkles
 if cat.spd>1 then
  for i=1,10 do
   add(slider,make_slider(x,y,h,xd))
  end
   add(speeder,make_speeder(x,y,sf,s))
 end
--boost anim
 if cat.spd>1 then
  cat.s=10
  cat.mom=.9
 else
  cat.mom=.55
 end
--sounds
 if cat.s==7 or
    cat.s==9 then
  if cat.wsfx==true then
   sfx(0)
  end
 end
--move cat
 cat.x+=cat.xd
 cat.y+=cat.yd
--set hitbox
 cat.l=cat.x+1
 cat.r=cat.x+6
 cat.t=cat.y+2
 cat.b=cat.y+7
 cat.xc=cat.x+4
 cat.yc=cat.y+4
--hard edge limits
 if cat.x<19 then
  cat.x=19
 elseif cat.x>101 then
  cat.x=101
 end
 if cat.y<18 then
  cat.y=18
 elseif cat.y>100 then
  cat.y=100
 end
--disallow boosts when pressing
 if btn(4)==false and
    btn(5)==false then
  cat.boosting=false
 end
end

function spdcatset(i,j,l)
 if cat.lastbutton==i then
  cat.spd=3
  cat.xd=j
  cat.yd=l
  sfx(1)
  game.stealth-=1
  juice(2,2,0)
  if cat.boosting==false then
   cat.boosting=true
  end
 end
end

function wallflag(hit,x,y)
 k=mget(x,y)
 if fget(k,0) then
  return true
 end
end

function mapper()
 setlevel()
--grab map in norm / hard modes
 for i=1,2 do
  j=(i-1)*30
  k=(i-1)*2
  mapgrab(1+j,0,0,11+k)
  mapgrab(2+j,1,0,12+k)
  mapgrab(3+j,2,0,11+k)
  mapgrab(4+j,3,0,11+k)
  mapgrab(5+j,4,0,7+k)
  mapgrab(6+j,5,0,13+k)
  mapgrab(7+j,6,0,9+k)
  mapgrab(8+j,7,0,13+k)
  mapgrab(9+j,8,0,14+k)
  mapgrab(10+j,9,0,8+k)
  mapgrab(11+j,1,1,12+k)
  mapgrab(12+j,2,1,8+k)
  mapgrab(13+j,3,1,7+k)
  mapgrab(14+j,4,1,10+k)
  mapgrab(15+j,5,1,8+k)
  mapgrab(16+j,6,1,11+k)
  mapgrab(17+j,7,1,9+k)
  mapgrab(18+j,8,1,10+k)
  mapgrab(19+j,9,1,13+k)
  mapgrab(20+j,1,2,10+k)
  mapgrab(21+j,2,2,10+k)
  mapgrab(22+j,3,2,8+k)
  mapgrab(23+j,4,2,9+k)
  mapgrab(24+j,5,2,12+k)
  mapgrab(25+j,6,2,8+k)
  mapgrab(26+j,7,2,10+k)
  mapgrab(27+j,8,2,15+k)
  mapgrab(28+j,9,2,7+k)
  mapgrab(29+j,0,3,9+k)
  mapgrab(30+j,1,3,13+k)
 end
end

function mapgrab(l,x,y,tt)
 if game.level==l then
    game.levelx=x
    game.levely=y
--check 11x11 map grid for flags
  for i=1,11 do
   for j=1,11 do
    mx=j+(x*12)+.25
    my=i+(y*12)+.25
    d=mget(mx,my)
--set item and create if flagged
    ix=j*8+12
    iy=i*8+12
    itemdump(d,ix,iy)
   end
  end
 game.t=0
 game.a=10
 game.timetarget=tt
 end
end

function itemdump(d,ix,iy)
 if fget(d,1) then
  if fget(d,7) then
   add(wall,make_wall(ix,iy,w,h,1,18))
  elseif fget(d,6) then
   add(wall,make_wall(ix,iy,w,h,3,16))
  else
   add(wall,make_wall(ix,iy,w,h,2,17))
  end
 elseif fget(d,2) then
  if fget(d,7) then
   add(vase,make_vase(ix,iy,w,h,s))
  elseif fget(d,6) then
   add(button,make_button(ix,iy,w,h,s))
  else
   add(diamond,make_diamond(ix,iy,w,h))
  end
 elseif fget(d,3) then
  if fget(d,7) then
   add(door,make_door(ix,iy,w,h))
  elseif fget(d,6) then
   for i=1,2 do
    for j=1,2 do
     add(coin,make_coin(ix+i*4-3,iy+j*4-3,w,h))
     game.cointarget+=1
    end
   end
  else
   cat.x=ix-.9
   cat.y=iy-.9
  end
 elseif fget(d,4) then
  if fget(d,6) then
   add(sentry,make_sentry(ix,iy,w,h,s,"l",sf))
  elseif fget(d,7) then
   add(sentry,make_sentry(ix,iy,w,h,s,"r",sf))
  else
   add(mud,make_mud(ix,iy,w,h,s))
  end
 elseif fget(d,5) then
  if fget(d,6) then
   add(zapper,make_zapper(ix,iy,w,h,2,29,sf,t))
--bandit mode turrets
  elseif fget(d,7) then
   if banditmode==true then
    add(zapper,make_zapper(ix,iy,w,h,2,29,sf,t))
   end
  else  
   add(zapper,make_zapper(ix,iy,w,h,1,28,sf,t))
  end
 end
end

function screenmask()
--black bg masks
 rectfill(0,0,19,127,b1)
 rectfill(108,0,127,127,b1)
 rectfill(0,12,127,19,b1)
 rectfill(0,108,127,115,b1)
--ui borders
 map(0,13,12,12+mss,13,13)
 map(0,13,12,-3-tss,13,1)
 map(0,25,12,12-tss,13,1)
 map(0,13,12,108+bss,13,1)
 map(0,25,12,123+bss,13,25)
 spr(60,108,5-tss)
 spr(60,17,5-tss)
 spr(60,108,116+bss)
 spr(60,17,116+bss)
end

function swipebehavior()
 if swipe<170 then
  swipe+=8
 else
  swipe=170
  if readycount==100 then
   readycount=game.readyval
  end
 end
 if game.swipetarget!=0 and
    swipe>85 then
  if game.swipetarget!=1 then
   state=game.swipetarget
   mapper()
   game.swipetarget=0
  else 
   state=1
   pausepatch=true
   _init()
  end
 end
end

function readybehavior()
--wipe all objects after level
 if game.exitswipe>84 and
  game.exitswipe<89 then
  demapper()
 end
 if state!=1 then
  if readycount<30 then
   readycount+=1
  else
   readycount=100
  end
 end
 if readycount==29 and
    swipe>150 then
  pause=false
 end
--add sound to swipes
 if swipe==170 then
  if readycount==8 then
   sfx(32)
   juice(3,2)
  end
  if readycount==15 then
   sfx(33)
   juice(3,2)
  end
 end 
end

function drawvault()
 if vault>199 then
  spr(116,66,35)
 else
  spr(116,41,80)
 end
 if vault>399 then
  spr(116,74,35)
 else
  spr(116,81,80)
 end
 if vault>599 then
  spr(116,70,27)
 end
end

function swiper(l,j,r,z)
 music(-1)
 sfx(39)
 swipe=l
 readycount=r
 game.swipetarget=j
 pause=true
 game.readyval=z
end

function tutorial(l,i,k)
 if game.level==l then
  ti=27+mss
  rectfill(19,20+mss,107,ti,b1)
  line(19,ti,107,ti,b2)
  print(i,k,21+mss,b2)
 end
end

function winmessage(i,j)
 print(i,game.carx-101,j+game.exitswipe,b2)
end

 -----------  draw  -----------

function _draw()
 cls()
 pal(6,b2)
 lbss=117+bss
 tbss=6-tss
--intro
 if state==1 then
--title screen
  if menu==1 then
   foreach(chimney,draw_chimney)
   rectfill(18,2,109,13,b1)
   if game.banditunlock==false then
   print("2018 eggnog games",31,tbss,b2)
   else
    print(modename,43,tbss,b2)
   end
   map(1,49,20,19,11,11)
   drawvault()
--victory message
   if game.champion==true then
    rectfill(20,101,107,107,b1)
    line(20,100,107,100,b2)
    print("world-class thief",31,102,b2)
   end
--roof tiles
   map(2,61,28,44,9,3)
--credits page
  elseif menu==2 then
   print("credits",51,tbss,b2)
   rect(51,27,77,41,b2)
   print("eggnog",53,29,b2)
   print("games",55,35,b2)
   print("code, art & design:\nandrew reist\n@platformalist\n\nplaytesting:\nlaine and daniel\n@enargy\n\nthanks for playing!",25,49,b2)
--level select screen
  elseif menu==3 then
   rect(25,27+mss,102,101+mss,b2)
--diamonds
   for i=1,5 do
    if starset[i]==1 then
     spr(61,59+i*7,33+mss)
    else
     pset(61+i*7,34+mss,b2)
    end    
   end
   print("level select",41,tbss,b2)
   print("level",30,32+mss,b2)
   print(game.level,53,32+mss,b2)
   foreach(sparkle,draw_sparkle)
   for j=1,5 do
    for i=1,6 do
     w=12
     k=i*w
     g=j*w
--level select squares
     rectfill(k+18,g+28+mss,k+26,g+36+mss,b1)
     rect(k+18,g+28+mss,k+26,g+36+mss,b2)
--locked icons
     m=0
     if banditmode==true then
      m=30
     end
     l=j*6-7+i+m
     if dget(l)==1 then
      spr(59,k+19,g+29+mss)
     end
    end
   end
--selection box
  lsx=game.levx*w+18
  lsy=game.levy*w+33+mss
  lsw=game.levx*w+26
  lsh=game.levy*w+41+mss
  rect(lsx,lsy-5,lsw,lsh-5,b1)
  rect(lsx+1,lsy-4,lsw-1,lsh-6,b2)
  spr(3,lsx+2,lsy-3)
 end
--marquee text box
  print(game.marquee,110-game.marqueecount,lbss,b2)
 end
 
--gameplay
 if state==2 or
    state==3 then
  foreach(wall,draw_wall)
  foreach(vase,draw_vase)
  foreach(shard,draw_shard)
  foreach(door,draw_door)
  foreach(coin,draw_coin)
  foreach(button,draw_button)
  foreach(diamond,draw_diamond)
  foreach(mud,draw_mud)
  foreach(sentry,draw_sentry)
  foreach(slider,draw_slider)
  foreach(speeder,draw_speeder)
  foreach(fireball,draw_fireball)
  foreach(bullet,draw_bullet)
  palt(0,false)
  foreach(zapper,draw_zapper)
  palt()
  foreach(smoke,draw_smoke)
  foreach(sparkle,draw_sparkle)
 if game.diamondget==true then
  j=1
  ys=3
  if cat.sf==true then
   j=0
  end 
  if cat.s>6.75 and
     cat.s<9 then
   ys=2
  end
  if cat.s==10 then
   ys=1
  end
  spr(20,cat.x+j,cat.y-ys)
 end
 palt(0,false)
 palt(14,true)
--cat
 spr(cat.s,cat.x,cat.y+mss,1,1,cat.sf)
--tutorial blocks
  tutorial(1,"(arrow keys) walk",31)
  tutorial(4,"(z) dash attack",35)
  tutorial(10,"(up + z) vert dash",29)
 palt()
 end

--end of level
 if state==3 then
  xs=game.exitswipe
  if game.exitpause==0 then
   rectfill(20,20,107,19+xs,b1)
  end
--timer display
  line(20,19+xs,107,19+xs,b2) 
  pal(14,0)
  gx=game.carx
  gy=game.cary
--successful heist
  if game.a>0 then
   foreach(exhaust,draw_exhaust)
--cat
   spr(6,33+gx,-42+xs+gy)
--car
   spr(64,28+gx,-35+xs+gy,3,2)
--diamond
   if game.diamondget==true then
    spr(20,34+gx,-45+xs+gy)
    if lev30==true then
     winmessage("bandit mode unlocked!",-64)
     winmessage("change modes on title",-58)
     winmessage("screen with up arrow!",-52)
    else
     print("success!",gx-75,-57+xs,b2)
    end
   else
    print("escaped!",gx-75,-57+xs,b2)
   end
--level progress diamonds
   for i=1,5 do
    k=62
    if starset[i+10]==1 then
     k=61
    end
    spr(k,gx-100,-47+(i*6)+xs)
   end
   print("got the diamond!\nnabbed every coin!\ndodged the vases!\nbeat goal time!\nall 4 in 1!",gx-91,-42+xs,b2)
   print(game.exitlevelmessage,gx-91,xs-game.exitlevelh,b2)
   foreach(sparkle,draw_sparkle)
  else
--failed heist and car
   foreach(exhaust,draw_exhaust)
   spr(64,28,-35+xs+gy,3,2)
   print("the big heist\nwent sideways!",29,-58+xs,b2)
   if game.slimed==true then
    spr(game.exitslime,31,-41+xs+gy,1,1,game.exitslimesf)
   end
   if dget(game.level)!=1 then
    print("(z) try again\n(x) next level\n(up) level select",29,xs-9,b2)
   else
    print("(z) try again\n(up) level select",29,xs-6,b2)
   end
  end
 rectfill(0,0,127,17,b1)
 end

--ui
 if state==2 or
    state==3 then
--level number
  spr(67,22,tbss)
  print(game.level,28,tbss,b2)
--coin count
  i=4
  if game.coincount>9 then
   i=0
  end
  spr(83,93+i,tbss)
  print(game.coincount,99+i,tbss,b2)
--bottom stealth bar
  if game.stealth>0 then
   print("stealth",22,lbss,b2)
   for i=1,game.stealth do
    j=i*3
    rectfill(50+j,lbss,51+j,121+bss,b2)
   end
  else
   print("run!",22,lbss,b2)
   spr(game.door,41,116+bss)
   rectfill(53,lbss,53+game.a*5.2,121+bss,b2)
  end
 end
--time display mask
 if game.displaytime==true then
  rectfill(20,116+bss,107,122+bss,b1)
  print("time:",22,lbss,b2)
  if game.a>0 then
   print(game.currenttime,42,lbss,b2)
  else
   print("n/a",42,lbss,b2)
  end
  print("goal:",64,lbss,b2)
  print(game.timetarget,84,lbss,b2)
  print(".0",88+game.targetlength*4,lbss,b2)
 end
--swipe box
 if swipe<170 then 
  gs=swipe
  rectfill(107-gs,20,187-gs,107,b1)
  line(107-gs,20,107-gs,107,b2)
  line(187-gs,20,187-gs,107,b2)
  sspr(56,8,8,8,122-gs,32,64,64,true)
 end

--eggnog intro
 if state==0 then
  map(1,49,20,19,11,11)
  map(2,61,28,44,9,3)
  drawvault()
--blinds effect
  for i=1,44 do
   a=20
   b=titleswipe
   l=18+i*2
   line(a,l,b,l,b1)   
   a=107
   b=127-titleswipe
   l=19+(i*2)
   line(a,l,b,l,b1)
  end
  m=(titleswipe-107)*1.5
--eggnog logo
  if titleswipe>72 then
   rect(51,57+m,77,71+m,b2)
   print("eggnog",53,59+m,b2)
   print("games",55,65+m,b2)
  end
  if game.banditunlock==true then
   print(modename,28+titleswipe,6,b2)
  else
   print("2018 eggnog games",17+titleswipe,6,b2)
  end
 end
 screenmask()

--ready? sneak! intro
 if readycount!=100 and
    state!=1 and
    swipe==170 then
  pal(14,0)
  if readycount<8 then
   sspr(80,32,27,9,64-(readycount*6),64-(readycount*2),readycount*12,readycount*4)
  elseif readycount<15 then
   sspr(80,32,27,9,19,49+mss,90,30)
  elseif readycount<30 then
   sspr(80,40,27,9,19,49+mss,90,30)
  end
  pal()
 end
 pal()
end
-->8

 ---------  objects  ----------

function make_wall(x,y,w,h,v,s)
 local new_wall={
 x=x,
 y=y,
 w=x+8,
 h=y+8,
 v=v,
 s=s,
 }
 return new_wall
end

function draw_wall(thiswall)
 spr(thiswall.s,thiswall.x,thiswall.y+mss)
end

function wallbehavior(thiswall)  
--ignore all if broken wall
 if thiswall.s!=32 then
--check for basic cat overlap
  hdv=0
  if hitdetect(thiswall.x,thiswall.y,thiswall.w,thiswall.h) then
   hdv=1
   wx=thiswall.x+1
   ww=thiswall.w-1
   wy=thiswall.y+1
   wh=thiswall.h-1
   fl=thiswall.x-3
   fr=thiswall.w+3
   ft=thiswall.y-3
   fb=thiswall.h+3
--check 4 hitboxes around hitbox
   t=hitdetect(wx,ft,ww,wy)
   l=hitdetect(fl,wy,wx,wh)
   r=hitdetect(ww,wy,fr,wh)
   b=hitdetect(wx,wh,ww,fb)
--break if this is a window
   smash=false
   if l==true or
      r==true or
      t==true or
      b==true then
    if thiswall.v==2 and
       cat.boosting==true then
     smash=true
     sfx(10)
     for i=1,20 do
      add(shard,make_shard(thiswall.x,thiswall.y,thiswall.h-2,6,5))
     end 
     game.stealth-=4
     juice(2,3,0)
     del(wall,thiswall)
    end
   end
--adjust cat trajectory
   if smash==false then
    i=1
    j=1
--inner last-chance hitbox
    xfv=0
    yfv=0
    if hitdetect(thiswall.x+1,thiswall.y+1,thiswall.w-2,thiswall.h-2) then
     i=1.95
     j=1.75
     xfv=-.5
     yvf=-.5
     if l==true then
      xfv=.5
     end
     if t==true then
      yfv=.5
     end
    end    
    if t==true or
       b==true then
     cat.y-=cat.yd*i+yfv
     cat.yd=0
    end
    if l==true or
       r==true then
     cat.x-=cat.xd*j+xfv
     cat.xd=0
    end
   end
  end
--vanish if this is a gate
  if game.buttonhit==true and
     thiswall.v==3 then
    for i=1,20 do
     add(shard,make_shard(thiswall.x,thiswall.y,thiswall.h-1,6,5))
    end
   thiswall.s=32
  end 
 end
end

function make_zapper(x,y,w,h,v,s,sf,t)
 local new_zapper={
 x=x,
 y=y,
 w=x+4,
 h=y+4,
 v=v,
 s=s,
 sf=false,
 t=28,
 }
 return new_zapper
end

function draw_zapper(thiszapper)
 spr(thiszapper.s,thiszapper.x,thiszapper.y+mss,1,1,thiszapper.sf)
 if thiszapper.v==1 then
  for i=1,3 do
   pset(thiszapper.x+(rnd(4))+2,thiszapper.y+(rnd(2))+3,b2)
  end
 end
end

function zapperbehavior(thiszapper)
 if hitdetect(thiszapper.x,thiszapper.y+2,thiszapper.x+7,thiszapper.y+5) then
--destroy beams if touched
  if thiszapper.v==1 then
   game.stealth-=3
   juice(2,2)
   for i=1,10 do
    add(smoke,make_smoke(thiszapper.x+rnd(14)-2,thiszapper.y+rnd(14)-2,rnd(4)+5,1))  
   end   
   sfx(28)
   del(zapper,thiszapper)
--zap cat if touching turret
  else
   statechange(0)
  end
 end
--check tractor beam l&r hitboxes
 if thiszapper.v==1 then
  if hitdetect(19,thiszapper.y+1,thiszapper.x,thiszapper.y+6) then
   add(fireball,make_fireball(thiszapper.x-2,thiszapper.y+3,-1,t))  
   sfx(18)
  elseif hitdetect(thiszapper.x+7,thiszapper.y+1,120,thiszapper.y+6) then
   add(fireball,make_fireball(thiszapper.w+5,thiszapper.y+3,1,t))
   sfx(18)
  end
 end
--shoot pixel bomb if turret
 if thiszapper.v==2 then
  if thiszapper.t<1 then
   thiszapper.t=32
   bx,by=bulleted(thiszapper.x,thiszapper.y,cat.x,cat.y)
   add(bullet,make_bullet(thiszapper.x+4,thiszapper.y+4,r,rd,bx,by,v))  
   sfx(29)
  else
   thiszapper.t-=1
  end
--animate turret
  if thiszapper.t>29 then
   thiszapper.s=30
  else
   thiszapper.s=29
  end
  if cat.x<thiszapper.x then
   thiszapper.sf=true
  else
   thiszapper.sf=false
  end
 end
end

function bulleted(bx,by,cx,cy)
 a=cx-bx
 b=cy-by
 c=sqrt(a*a+b*b)
 return a/c,b/c
end

function make_fireball(x,y,d,t)
 local new_fireball={
 x=x,
 y=y+rnd(2)-1,
 d=d,
 t=9,
 }
 return new_fireball
end

function draw_fireball(thisfireball)
 fx=thisfireball.x
 fy=thisfireball.y
 line(fx,fy,fx,fy+2,b2)
end

function fireballbehavior(thisfireball)  
 v=2
 if hitdetect(thisfireball.x,thisfireball.y,thisfireball.x,thisfireball.y+1) then
  cat.spd=.25
 end
 if thisfireball.t>0 then
  thisfireball.x+=thisfireball.d*v
  thisfireball.t-=1
 else
  del(fireball,thisfireball)
 end
end

function make_bullet(x,y,r,rd,bx,by,v)
 local new_bullet={
 x=x,
 y=y,
 xd=bx,
 yd=by,
 v=3,
 }
 return new_bullet
end

function draw_bullet(thisbullet)
 pset(thisbullet.x,thisbullet.y,b1)
end

function bulletbehavior(thisbullet)
 thisbullet.x+=thisbullet.xd*thisbullet.v
 thisbullet.y+=thisbullet.yd*thisbullet.v
 tbx=thisbullet.x
 tby=thisbullet.y
--add smoke trail
 add(smoke,make_smoke(tbx,tby,3,2))  
--set hitbox
 bullethit[1]=tbx-1
 bullethit[2]=tby-1
 bullethit[3]=tbx+1
 bullethit[4]=tby+1
 foreach(wall,bulletdetect)
 if tbx<20 or
    tbx>108 or
    tby<20 or
    tby>108 then
  bullet.hit=true
 end
--detect walls
 if bullet.hit==true then
  sfx(30)
  for i=1,3 do
   add(smoke,make_smoke(tbx+rnd(4)-3,tby+rnd(4)-3,rnd(5)+2,2))  
  end   
  bullet.hit=false
  del(bullet,thisbullet)
 end
--end game if hits cat
 if hitdetect(tbx-1,tby-1,tbx+1,tby+1) and
    bullet.hit==false then
  statechange(0)
 end
end

function make_smoke(x,y,r,v)
 local new_smoke={
 x=x,
 y=y,
 r=r,
 v=v,
 }
 return new_smoke
end

function draw_smoke(thissmoke)
 if thissmoke.v==1 then
  circfill(thissmoke.x,thissmoke.y,thissmoke.r,b2)
 elseif thissmoke.v==2 then
  circ(thissmoke.x,thissmoke.y,thissmoke.r,b2) 
 end
end

function smokebehavior(thissmoke)  
 if thissmoke.r>0 then
  thissmoke.r-=(rnd(2)/4)*thissmoke.v
 else
  del(smoke,thissmoke)
 end
 if thissmoke.r<2 then
  thissmoke.x+=rnd(5)/10
  thissmoke.y-=rnd(5)/5
 end
end

function make_chimney(x,y,r,d,xl,xr)
 local new_chimney={
 x=x,
 y=y,
 r=rnd(2)/2,
 d=(rnd(2)-1)/2,
 xl=x-(rnd(3)+1),
 xr=x+(rnd(3)+1),
 }
 return new_chimney
end

function draw_chimney(thischimney)
 circfill(thischimney.x,thischimney.y,thischimney.r,b2)
end

function chimneybehavior(thischimney)  
 if thischimney.y>13 then
  thischimney.r+=rnd(1)/6
 else
  del(chimney,thischimney)
 end
--reverse movement direction
 if thischimney.x<thischimney.xl or
    thischimney.x>thischimney.xr then
  thischimney.d*=-1
 end
--move smoke upward and around
 thischimney.x+=thischimney.d
 thischimney.y-=.3
--delete if not proper mode
 if state!=1 or
    menu!=1 then
  del(chimney,thischimney)
 end
end

function make_exhaust(x,y,r,c)
 local new_exhaust={
 x=game.carx+25-rnd(3),
 y=game.exitswipe-23-rnd(3),
 r=rnd(2)+2.2,
 c=b2,
 }
 return new_exhaust
end

function draw_exhaust(thisexhaust)
 circfill(thisexhaust.x,thisexhaust.y,thisexhaust.r,thisexhaust.c)
end

function exhaustbehavior(thisexhaust)  
 if game.exitswipe<5 then
  del(exhaust,thisexhaust)
 end
 if thisexhaust.r>0 then
  thisexhaust.r-=rnd(2)/4
 else
  del(exhaust,thisexhaust)
 end
end

function make_sparkle(x,y,xd,yd,m,t)
 local new_sparkle={
 x=x+rnd(6),
 y=y+rnd(6),
 xd=rnd(6)-3,
 yd=rnd(6)-3,
 m=.8,
 t=flr(rnd(20)+14),
 }
 return new_sparkle
end

function draw_sparkle(thissparkle)
 pset(thissparkle.x,thissparkle.y,b2)
end

function sparklebehavior(thissparkle)  
--move the sparkle!
 thissparkle.x+=thissparkle.xd
 thissparkle.y+=thissparkle.yd
--apply momentum!
 thissparkle.xd*=thissparkle.m
 thissparkle.yd*=thissparkle.m
--sparkle life timer
 if thissparkle.t>0 then
  thissparkle.t-=1
 else
  del(sparkle,thissparkle)
 end
end

function make_coin(x,y,w,h)
 local new_coin={
 x=x,
 y=y,
 w=x+3,
 h=y+2,
 }
 return new_coin
end

function draw_coin(thiscoin)
 spr(24,thiscoin.x,thiscoin.y+mss)
end

function coinbehavior(thiscoin)  
--check for basic cat overlap
 if hitdetect(thiscoin.x-1,thiscoin.y-1,thiscoin.w,thiscoin.h) then
  game.coincount+=1
  sfx(2)
  del(coin,thiscoin)
 end
end

function make_door(x,y,w,h)
 local new_door={
 x=x,
 y=y,
 w=x+5,
 h=y+5,
 }
 return new_door
end

function draw_door(thisdoor)
 if game.stealth==0 then
  spr(game.door,thisdoor.x,thisdoor.y+mss)
 end
end

function doorbehavior(thisdoor)  
 if game.stealth==0 then
  if hitdetect(thisdoor.x+1,thisdoor.y,thisdoor.w+1,thisdoor.h+1) then
   starcheck()
   statechange(1)
  end
 end
end

function make_button(x,y,w,h,s)
 local new_button={
 x=x,
 y=y,
 w=x+4,
 h=y+4,
 s=21,
 }
 return new_button
end

function draw_button(thisbutton)
 spr(thisbutton.s,thisbutton.x,thisbutton.y+mss)
end

function buttonbehavior(thisbutton)  
 if hitdetect(thisbutton.x+2,thisbutton.y+2,thisbutton.w+2,thisbutton.h+2) then
  thisbutton.s=37
  if game.buttonhit==false then
   sfx(14) 
   game.stealth-=1
   juice(2,3,0)
  end
  game.buttonhit=true 
 end
end

function make_mud(x,y,w,h,s)
 local new_mud={
 x=x,
 y=y,
 w=x+8,
 h=y+8,
 s=25,
 }
 return new_mud
end

function draw_mud(thismud)
 spr(thismud.s,thismud.x,thismud.y+mss)
end

function mudbehavior(thismud)  
 if hitdetect(thismud.x+1,thismud.y+1,thismud.w,thismud.h-4) then
  cat.spd=.25
 end
end

function make_sentry(x,y,w,h,s,d,sf)
 local new_sentry={
 x=x,
 y=y,
 w=x+6,
 h=y+6,
 s=42+(flr(rnd(3))),
 d=d,
 sf=false,
 }
 return new_sentry
end

function draw_sentry(thissentry)
 spr(thissentry.s,thissentry.x,thissentry.y+mss,1,1,thissentry.sf)
end

function sentrybehavior(thissentry)  
 if thissentry.s<45.75 then
  thissentry.s+=.25
 else
  thissentry.s=42
  sfx(31)
 end
--set hitbox
 sentryhit[1]=thissentry.x
 sentryhit[2]=thissentry.y
 sentryhit[3]=thissentry.x+7
 sentryhit[4]=thissentry.y+7
 foreach(wall,sentrydetect)
 if thissentry.x<20 or
    thissentry.x>100 or
    thissentry.y<20 or
    thissentry.y>100 then
  sentry.hit=true
 end
--change direction if hit
 sd=thissentry.d
 if sentry.hit==true then
  if sd=="l" then
   thissentry.x+=1
   thissentry.d="u"
  elseif sd=="u" then
   thissentry.y+=1
   thissentry.d="r"
  elseif sd=="r" then
   thissentry.x-=1
   thissentry.d="d"
  elseif sd=="d" then
   thissentry.y-=1
   thissentry.d="l"
  end
 sentry.hit=false
 end
--move slug
 if sd=="l" then
  xd=-.5
  yd=0
  thissentry.sf=true
 elseif sd=="r" then
  xd=.5
  yd=0
  thissentry.sf=false
 elseif sd=="u" then
  xd=0
  yd=-.5
  thissentry.sf=true
 elseif sd=="d" then
  xd=0
  yd=.5
  thissentry.sf=false
 end
 thissentry.x+=xd
 thissentry.y+=yd 
--end round if slug hits cat
 if hitdetect(thissentry.x+1,thissentry.y+3,thissentry.x+5,thissentry.y+5) then
  statechange(0)
 end
end

function demapper()
--wipe all items at end of level
 destruct(sentry)
 destruct(smoke)
 destruct(bullet)
 destruct(fireball)
 destruct(zapper)
 destruct(diamond)
 destruct(button)
 destruct(vase)
 destruct(shard)
 destruct(coin)
 destruct(wall)
 destruct(door)
 destruct(slider)
 destruct(speeder)
 destruct(mud)
end

function destruct(j)
 for i in all(j) do
  del(j,i)
 end
end

function make_vase(x,y,w,h)
 local new_vase={
 x=x,
 y=y,
 w=x+5,
 h=y+6,
 s=19,
 }
 return new_vase
end

function draw_vase(thisvase)
 spr(thisvase.s,thisvase.x,thisvase.y+mss)
end

function vasebehavior(thisvase)  
--check for basic cat overlap
 if hitdetect(thisvase.x+1,thisvase.y+1,thisvase.w+1,thisvase.h+1) then
  if thisvase.s==19 then
   for i=1,20 do
    add(shard,make_shard(thisvase.x,thisvase.y,thisvase.h,5,5))
   end
   game.vasebroken=true
   game.stealth-=6
   juice(2,3,0)
   sfx(7)
  end
 thisvase.s=35
 end
end

function make_diamond(x,y,w,h)
 local new_diamond={
 x=x,
 y=y,
 w=x+5,
 h=y+4,
 }
 return new_diamond
end

function draw_diamond(thisdiamond)
 spr(20,thisdiamond.x,thisdiamond.y+mss)
end

function diamondbehavior(thisdiamond)  
--check for basic cat overlap
 if hitdetect(thisdiamond.x+1,thisdiamond.y+1,thisdiamond.w+1,thisdiamond.h+1) then
  game.diamondget=true
  game.stealth=0
  sfx(9)
  juice(2,2,0)
  del(diamond,thisdiamond)
 end
end

function make_shard(x,y,h,xv,yv)
 local new_shard={
 xv=xv,
 yv=yv,
 x=x+rnd(xv)+1,
 y=y+rnd(yv),
 h=h,
 }
 return new_shard
end

function draw_shard(thisshard)
 pset(thisshard.x,thisshard.y,b2)
end

function shardbehavior(thisshard)  
 if thisshard.y<thisshard.h then
  thisshard.y+=.5
 else
  del(shard,thisshard)
 end
end

function hitdetect(ox,oy,ow,oh)
 if cat.l<ow and
    cat.r>ox and
    cat.t<oh and
    cat.b>oy then
  return true
 end
end

function sentrydetect(thiswall)
 if sentryhit[1]<thiswall.w and
    sentryhit[3]>thiswall.x and
    sentryhit[2]<thiswall.h and
    sentryhit[4]>thiswall.y and
    thiswall.s!=32 then
  sentry.hit=true
 end
end

function bulletdetect(thiswall)
 if bullethit[1]<thiswall.w and
    bullethit[3]>thiswall.x and
    bullethit[2]<thiswall.h and
    bullethit[4]>thiswall.y and
    thiswall.s!=32 then
  bullet.hit=true
 end
end

function make_slider(x,y,h,xd)
 local f=rnd(2)/5-.5
 if cat.sf==true then
  f*=-1
 end
 local new_slider={
 x=cat.x+rnd(3)+2,
 y=cat.y-rnd(3)+6,
 h=cat.y+rnd(3)+4,
 xd=f,
 t=0,
 }
 return new_slider
end

function draw_slider(thisslider)
 pset(thisslider.x,thisslider.y,b2)
end

function sliderfall(thisslider)  
 thisslider.t+=1
 thisslider.x+=thisslider.xd
 thisslider.y+=rnd(2)/5
 if thisslider.y>thisslider.h or
    thisslider.x<19 or
    thisslider.x>108 or
    thisslider.y>108 then
  del(slider,thisslider)
 end
end

function make_speeder(x,y,sf,s)
 local f=false
 if cat.sf==true then
  f=true
 end
 local new_speeder={
 x=cat.x,
 y=cat.y,
 sf=f,
 s=11,
 }
 return new_speeder
end

function draw_speeder(thisspeeder)
 spr(thisspeeder.s,thisspeeder.x,thisspeeder.y,1,1,thisspeeder.sf)
end

function speederfade(thisspeeder)  
 thisspeeder.s+=.25
 if thisspeeder.s>13.5 then
  del(speeder,thisspeeder)
 end
end
__gfx__
0000000000000000eeeeeeee000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
0000000000000000eeeeeeee060600000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
0070070000000000eeeeeeee066600000000000000000000eee6ee6eeeeeeeeeeeeeeeeeeee6ee6eeeeeeeee0000000000000000000000000000000000000000
0007700000000000eeeeeeee066600000000000000000000eee6666eeee6ee6eeee6ee6eeee6666eeeeeeeee00000000000000000000000000000000000cc000
0007700000000000eeeeeeee000000000000000000000000eee6060eee66666eeee6666eeee6060eeee6ee6e00060060000000000000000000000000000cc000
0070070000000000eeeeeeee000000000000000000000000ee66666ee666060eee66060eee66666eee66666e0066666000060060000000000000000000000000
0000000000000000eeeeeeee000000000000000000000000e6666eeeee66666ee666666ee6666eeee666060e0666666000666660000606000000000000000000
0000000000000000eeeeeeee000000000000000000000000ee6e6eeeeeeee6eeee6e6eeeeee6eeeeee66666e0066666000066600000060000000000000000000
00666600006666000066660000000000000000000000000000000000000000006600000000000000000000000000000000000000000660000000000000000000
06000060060000600606666000666000006660000000000006060600000000006600000000060000000600000000600000000000006006600006600000000000
60000006600060066066600600060000066666000000000000000000006006000000000000006000006000000000060006600660006060060060066000000000
60066006600000066660000600666000006660000006600006000600006666000000000000600060066600000000666060000006006060060060600600000000
60666606600000066000006606660600000600000066660000000000006060000000000006000600006060000006060060000006006006600060600600000000
60000006600000066006600606666600000000000000000006060600006666000000000000060000066666000066666006600660006006000060066000000000
06000060060000600666006000666000000000000000000000000000000000000000000000006000000666600666600000000000006006000060060000000000
00666600006666000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000066666600666666000000000
00000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000600000000000000000000000000000000000
00000000000000000000000000000000000000000000000006060600006060000000006000000600000600000000060000000060000000000000000000000000
00000000000000000000000000000000000000000000000000000000060006000000060000006660000060000000666000000600000000600000000000000000
00000000000000000000000000000000000000000000000006000600000000000000666000060600000666000006060000006660000006000000000000000000
00000000000000000000000000060000000000000066660000000000060006000006060000066660006060000006666000060600000666600000000000000000
00000000000000000000000000666000000000000000000006060600006060000066666000666000066666000066600000666660006606000000000000000000
00666600000000000000000006666600000000000000000000000000000000000006600006660000666600000666000000066000066666600000000000000000
06666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666660000060600000000606000000000000000000600000000000060000000000000000006060000000060600000066600000000000000000000
00000000000000000000060600000000606000000000000000000660000000000660000000000000000006060066600060600000666660000060000000000000
00000000666666660000060600000000606000000000000000000066000000006600000000000000000006060060600060600000066600000000000000000000
00000000000000000000060600000000606000000000000000000000000000000000000000000000000006060666660060600000006000000000000000000000
00000000000000000000060600000000606000000000000000000000000000000000000000000000000006060666660060600000000000000000000000000000
00000000000000000000060666666666606000006600000000000000000000660000000000000000000006060666660060600000000000000000000000000000
00000000000000000000060600000000606000000660000000000000000006600000000000000000000006060000000060600000000000000000000000000000
00000000000000000000060666666666606000000060000000000000000006000000000000000000000006060000000000000000000000000000000000000000
00000000000066000006000060000000000666066066600006060000000006066666666606666666666666666666666666666666666000000000000000000000
000000666606006060606000600000000066666666666600060600000000060600000006060000006eeeeeeeeeeeeeeeeeeeeeeeee6000000000000000000000
000066000060000606606000600060000666666666666660060600000000060666666606060666666e666e666e666e66ee6e6e666e6000000000000000000000
000600000006006000066000600000000666666666666660060600000000060600000606060600006e6e6e6eee6e6e6e6e6e6eee6e6000000000000000000000
006000000000000660006000666000000066666666666600060600000000060600000606060600006e66ee66ee666e6e6e666ee66e6000000666666000000000
060000000000006006000600000000000006660660666000060666666666660600000606060600006e6e6e6eee6e6e6e6eee6eeeee6000006000000600000000
060000000000006006000060000000000000000000000000060000000000000600000606060600006e6e6e666e6e6e666e666ee6ee6000006000000600000000
600000000000000660000006000000000000000000000000066666666666666600000606060600006eeeeeeeeeeeeeeeeeeeeeeeee6000006000000600000000
60000000000000000000006606000000006660006000666660000000000000000000000000000000666666666666666666666666666000006000000600000000
600000000000000000000006666000000600000606000060000000000000000000000000000000006eeeeeeeeeeeeeeeeeeeeeeeee6000006000000600000000
600006666000006666000060600060006000006000600060000000000000600600000000000060006ee66e66ee666e666e6e6ee6ee6000006000660600000000
066660000600060000666600666000006000006000600060000000000000666600000000666606666e6eee6e6e6eee6e6e6e6ee6ee6000006000660600000000
000000660066600660000000060000006000006666600060000000000000600600000000060000006e666e6e6e66ee666e66eee6ee6000006000000600000000
000006666000006666000000000000000600006000600060000000000000600600000000060000006eee6e6e6e6eee6e6e6e6eeeee6000006000000600000000
000006666000006666000000000000000066606000600060000000000000600600000000060000006e66ee6e6e666e6e6e6e6ee6ee6000006000000600000000
000000660000000660000000000000000000000000000000000000000000600600000000606666666eeeeeeeeeeeeeeeeeeeeeeeee6000006000000600000000
00060600666606066060000000000606666600006000060060666000666660666660000000006000666666666666666666666666666000000000000000000000
00066600000006666060000000000606600060060600606060600600006000006000000000006000000000000000000000000000000000000000000000000000
00066600666006666666666666666666600060600060606060600060006000006000000000006000000000000000000000000000000000000000000000000000
00666000000066600000000000000000666600600060606060600060006000006000000066660666000000000000000000000000000000000000000000000000
00606000666060600000000000000000600060666660606060600060006000006000000006000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000600060600060606060600600006000006000000006000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000666600600060600600666000666660006000000006000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000060666666000000000000000000000000000000000000000000000000
00000000000000000000000066666666066666000000000000000606606000006600000000000066606000000000060660666666000000006000000600000000
00000000000000000000000000000000006060000000000000000606606000000060000000000600006000000000060000000000000000006000000600000000
00060060000000000000000066666666060006000000000000000606606000006060000000000606606000000000060600000000666666666666666600000000
00066660000000000000000000000000660066600000000000000606606000006060000000000606606000000000060600000000000000000000000000000000
00060600000600600000000000000000666006600000000000000606606000006060000000000606606000000000060600000000000000000000000000000000
00666660006666600000000000000000660006600000000000000606606000006060000000000606606000000000060600000000000000000000000000000000
06666000066606000000000000000000666066600000000000000606606000006060000000000606606000000000060600000000000000000000000000000000
00606000006666600000000000000000066666000000000000000606606000006060000000000606606000000000060600000000000000000000000000000000
00000000000000000000000020000091000141010091000020212121000000000021212120000021919100000000310020210021000000000021002120c12100
00317131000021c12000000000007100000000002000712100310031002100002021a121912161219121b121200000a100a100a1000000002000000000000000
00000000000000000000000020000091002101210091000020212121c1210021c121212120000021919100919100000020210021212161212121002120212121
00000000002121212000000000010101000000002000002121210021212100002021a121000071000021b1212021000000000000000000212000000000000000
00000000000000000000000020f0000000007100000000f02021a101000071000001b1212000000091c181c1910000002021f021002171210021f02120b100b1
010061000100b10020000000000141010000000020f0000000000000000000d12001a101000101010001b1012000008100314131008100002000000000000000
000000000000000000000000200021a12100610021a121002021a101000061000001b12120f0000091913191910000002000210000212121000021002000a100
0100f00001a100a12000000000010101000000002021212181210021812121212021212121214121212121212000002121212121212100002000000000000000
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202000000000000000
2000000000014101000000002021f0d1f0018121f0d1f02120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000000000101010000000020210000000101210000002120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20003100000000000000310020210000001100210000002120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2081310000f0f0f00000318120212100212100212141212120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000310000d1f0d10000310020210000b12100210000b12120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000f0f0f00000000020210031000151010031002120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000005100000000002021a10000210021a100002120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20212100212161212100212120212100212100212100212120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
202100b100212121b100b12120210000002100010000002120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20210000001171110000002120210021002101010021002120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021a100a121212100a1002120210071002181010061002120000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20004555650000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20004656667686000007750020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20973737373737373737378720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20670000000000000000007720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20670000000000000000007720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20b7373737373737373737a720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20670094840000009484007720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
206700647400e4006474007720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
206700000000e5000000007720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2036d7d7d7d7e7d7d7d7d72620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009595959595959595950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009696969696969696960000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009696969696969696960000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
000000080000000000000000000000a042028284044488084810509020606000000000000000000000000000000000000001010101010101010001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000001010000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000
0212121212121212121212120200000000000f0000000000020f0000130000001300000f0212121212121212121212120200000012121212120000000200000000001400000000000200000000121212000000000200000000000000121212120200000000121212000000000212121212121212121212120200000000000000
0200000000000000000000000200000000000000000000000200130000000000000013000200000000000000000000000200160011001100110014000200000012001200120000000200000000121712000000000200000012000012180018120200000012000f00120000000200000010001500100000000200000000000000
020000000013001300000000020000121212161212120000020000111111161111110000020018001312121213001800020000001212121212000000020018001200000012001800020000001212151212000000020000120f120012001300120200121200000000001212000200140010001300100018000200000000000000
0200000012121612120000000200001200000000001200000200001100000000001100000200000000111411000000000200000012000000120000000200000012121212120000000212121212001600121212120200001200120012180018120212150000001200000018120200000010001600100000000200000000000000
020000001200000012000000020000120000130000120000020000110018131800110000020018001312121213001800021300131200000012130013020f0000001316110000000f0200000000000000000000000212121215121212001212120212121213000000131212120210101010121112101010100200000000000000
021818181200140012181818021818120000140000121818020000110013141300110000020000000000160000000000021300131200000012131813021212121212001212121212020f1318130000001318130f021600100011171100100014021200000000000000000012020f0000000000000000000f0200000000000000
0200000012000000120000000200001200001300001200000200001100000000001100000200000013121212130000000213001312000000121300130212000000130013000000120200000000000000000000000212121218121212001212120212001212121212121200120200000000000000000000000200000000000000
0200000012121212120000000200001200000000001200000200001100000000001100000200000000111711000000000200000012000000120000000212001300000000001300120212121212101010121212120200001200120012180018120212171000181618001014120200000000000000000000000200000000000000
020000000000000000000000020000121212121212120000020000111111111111110000020000001312121213000000020000001212121212000000021200121212121212120012020000001212001212000000020000120f120012001300120212001212121212121200120200000000121112000000000200000000000000
02000f000000170000000f0002000000000000000000000002001300000000000000130002000f000000000000000f00020017001100110011000000021211001200170012001312020000000012141200000000020000001200001218001812021200000000180000000012020f0000001217120000000f0200000000000000
021212121212121212121212020000000000170000000000020f0000130017001300000f021212121212121212121212020000001212121212000f000200120000001200000012000200000000121212000000000200000000000000121212120200121212121212121212000212121212121212121212120200000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000
3733333333333333333333333500000012121212120000000200000000001200000000000200001212121212121200000212121212120012121212120200000f11001500110f0000020000000f121a120f0000000212121212120f12121212120200001212120f1212120000020f0000001314130000000f0200000000000000
3200000000000000000000003400001218001300181200000200000000121512000000000200120f00001400000f120002121800181200121b1b00120200110011001400110013000213131300121b1200131313021b0010000000000010001a0200120000000000000012000200000000001500000000000200000000000000
32000000000000000000000034000012130000001312000002121212121211121212121202121213000000000013121202120013001200121a1400120200000000001300000000110213151300121412001316130212121512120012121212120200120013000000130012000219191912191019121919190200000000000000
32000000000000000000000034000012000000000012000002000f000012111200000f00021218000000001b0000001202121800181015101a1a1a120200001010121212121000110213001300121012001300130218001b00100010001a00000200120000121112000012000200000000000000000000000200000000000000
3200000000000000000000003412120000000f00000012120200000000121112000000000200121212000000121212000212121212120012121212120200001200001b001b1000110200000000000000000000000212001212120012121212120212121300121812001312120212001919191019191900120200000000000000
3200000000000000000000003417120012000000120012150213000000000000000000130200120000001a00001812000200000000000000000000000200001200181618001200000211121212001200121212120218001a0010141000001a000212000000121811000000120200181b1b1b1b1b000018000200000000000000
320000000000000000000000340012001212121212001200021300130000170000130013020000121200000012120000020000001111111111000000021100101a001a000012000002001b1b12180018121b1b1b0212120012120012121212120212001313121212131300120212001919191019191900120200000000000000
3200000000000000000000003411120000000000000012110212111200001600001211120200001218001b0000120000020f0000001816180000000f0211001012121212101000000200001b121212121200000002181a0000100010001a00000212000017001500140000120200000000000000000000000200000000000000
3200000000000000000000003416000012121212120000000212181000121012001018120200000012001600120000000200000011111111110000000211000000000000000000000200000000001200000017000212001212120012121212120212121212121012121212120219191919191019191919190200000000000000
320000000000000000000000341012121211001112121210021212120012141200121212020000000012171200000000020000000000170000000000020013001100170011001100021a00001200120012000000021300000012171200000013021b1b1b1b1000101b1b1b1b0200000000001700000000000200000000000000
320000000000000000000000341811001100120011001114020000000012121200000000020000000000120000000000020000000000000000000000020000001100000011000000021a1a0012000000121a1a1a020000130011001000130016021a1a1a1a1016101a1a1a1a0200000000001600000000000200000000000000
3200000000000000000000003402020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000
363131313131313131313131381212121212121212121212020000000010141000000000020f00001919131919000000020012121212121212121200021b00181b00151b00181b000200000000000000000000000212121212121212121212120218000012121512120000180200000012121212120000000200000000000000
00000000000000000000000002180000000013000000001802000f000010101000000f0002000000191c181c19000000021212000000150000001212020000001a00001a00001a000200180000001d0000001800021d0000000000000000000f0200000010001b00120000000200000012001b00120000000200000000000000
0000000000000000000000000212120012001300120012120200000000001500000000000200001219190019190000000212000019121012190000120212001212120012121200120200000000000000000000000200000000121412000000000200000012001a001000000002000000121a171b120000000200000000000000
000000000000000000000000020012111200150012101200021212121c1210121c121212020000121919000000001300021218130012001200131812021c1200000000000000121c0200000f00000000000f00000200001212130013121200000200001312120012121300000200000012001a00120000000200000000000000
00000000000000000000000002001200121212121200120002000000000000000000000002000000191900191900130002121813191214121913181202001200121210121200120002000000000016000000000002000012000000000012111102000000000000000000000002001d001212161212001d000200000000000000
0000000000000000000000000200120000001800000012000200121212121c1212121200020017160000001919001400021200000012001200000012021c1200100014001000121c020000000000150000000000021800110000000000120000020000001d1200121d0000000200000000000000000000000200000000000000
000000000000000000000000020012190012121200191200021812000000000000001218020000001919001919001300021200121c1210121c120012020012001212101212001200020000131212121212130000021212120000000000121600020f1212000000000012120f02120f000000000000000f120200000000000000
__sfx__
010100001f41000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002a4402a440284402644024440224402144000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003c52500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011500000f240002000020000200002000020000200002000020000200002000c200002000f2000f2400a2400f2400020000200002000020000200002000020000200002000020000200002000f2000f2400d240
011500000b24000200002000020000200002000020000200002000020000200002000b2400a2400b2400f2400e24000200002000020000200002000020000200222400c200182000c20018200002000e2400a240
011500000c3530f7550f7550f7550c6730f7550f7550f7550c3530f7550f7550f7550c6730f7550f7550f7550c3530f7550f7550f7550c6730f7550f7550f7550c3530f7550f7550f7550c6730f7550f7550f755
011500000c3531275512755127550c6731275512755127550c3531275512755127550c6731275512755127550c3531675516755167550c6730a7550a7550a7550c3531775517755177550c67312755117550e755
010200003745300502000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000
010100003134300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002f55200500004000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002d3533c333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000008350163502535035350393502c3501735001350023500c3501e3502f3503935028350063500e350163501f3502835030350383500e3500b3501135025350323503c35015350023500a3501235022350
00020000023501f3501e3501a3501735014350113500b350083500030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000400002355000500005000050000500005000050000500005000050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001d35024350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003623300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000000000000000000000000000
000100003953300400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
010100001e33300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003e51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011500002955027550295502c5522c5522c5522c5522c5412c5312c5212c5112e5502c55029550275502955022550205502255027552275522755227552275412753127521275112955027550255502255025550
011500080d323000030d323000030d323000030d32300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011500000d3430000025665000000d3030d34325665000000d3430000025665000000d3030000025665256650d3430000025665000000d3030d34325665000000d3430000025665000000d303000002566525665
011500002957027570295702c5722c5722c5722c5722c5612c5512c5412c5312e5702c57029570275702957022570205702257027572275722757227572275612755127541275312957027570255702257020570
011500001e5701d5701e57020572205722057220570205702257020570225702557225572255722757025570295722957227570255702757527570275022557025500255012c5702c50031570195002e50020500
01150000085501d5000a5502050011550205001455011550110000f550225000d5500f5500a0000a5500150005550055000555001500085500a550085500b55001500015000a550085500a550015000155020500
01150000015700550001570015700157001500015700d57001570035000157001570015700a500015700d5700a570055000a5700a5700a5700a5000a570165700a570015000a5700a5700a570015000a57016570
0115000006570055000d5700f5700d57001500055700357005570035000d5700f570115700a5000a5700557003570055000857014570085700a500085700a5050157001500015700a50001570015000a5050a505
011500000d3430000025665256650d3030d30325665000000d3430000025665256650d3030000025665256050d3430000025665000000d3430d34325665000000d34300000256650000013343000002560525605
00010000142431d2501d25018250112500a2500325002250002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000000000000000000000000000
01020000063400c3400d3400b34009340033400134000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100000234301350013500135000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000775000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010700001d35300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700002935300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003334300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003534300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003134300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002e34324000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00002f3451733014330123301033014330103300c330003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000000
011400002f3311c35310333043131c300203001c30018300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000000
000100000225004250042500225000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
010400002d7702d770397703975139741397313972139711007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0105000021155201551e1551c1551e1551c1551a155191551a1551910517105151050020000200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01050000072500a2500925004250110000f05011050100500c0500400005050050500505003050020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011500002724524205242052420524205242052420524205242052420524205242052724510000222452220527245242052420524205242052420524205242052420524205242052420527245272052524525205
011500002324500200002000020000200002000020000200002000020000200002002324522245232452724526245002000020000200002000020000200002002e2450c200182000c20026245002002225522200
011500000c3530f7550f7550f7550c6730f7550f7550f7550c3530f7550f7550f7550c6730f7550f7550f7550c3530f7550f7550f7550c6730f7550f7550f7550c3530f7550f7550f7550c6730f7550f7550f755
011500000c3531275512755127550c6731275512755127550c3531275512755127550c6731275512755127550c3531675516755167550c6730a7550a7550a7550c3531775517755177550c67312755117550e755
001500000f0550000016055000001a055000001b055000000f0550000016055000001b0551800027055000000f0550000016055000001a055000001b055000000f0550000016055000000a055000000305500000
001500000b055000001705500000160550000012055000000b0550000017055000001605500000120550000011055000000f055000000e055000000b055000000505500000030550000002055000000a05500000
010100001245500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010200000f0050000016005000001a005000001b005000000f0050000016005000001b0051800027005000000f0050000016005000001a005000001b005000000f0050000016005000000a005000000300500000
000100003a0503105035050310502b050280501e05022050170501b0501105019050180500f050170501705017050160501605015050000000000000000000000000000000000000000000000000000000000000
012500000d5550c5550d55514555155551455512555105550f5550d5550c55514555005050d555005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
011500000c3430340303400034002a6550340003403034000c30303403034000c3432a655034000c343034000c3430340303400034002a6550340003403034000c30303403034000c3432a655034000c34303400
011500002a5522a5422a5322a5222a5102a5012a5012a5012a5012a5012a5012a5012855026552265422653229552295422953229522295102950129501295012855228542285302852026552245522454224532
012500002525503205032051533336635034050340520255252551b2050f205282552725525255242552c25524255152050c20515333366350f205032052025524255032050320524255202551e2551c2551b255
012500002d2550320503205153333663503405034052d2552c2551b2050f205282052525525205272552c20528255152050c20515333366350f205032052c2552a255130000320525255242552d2552c25524255
012500001925503205032051533336635034050340514255192551b2050f2051c2551b25519255182552025518255152050c20515333366350f2050320514255182550320503205182551425512255102550f255
01250000014450d44219445034002c60503400034030844510442194450d005184422c6052144520442104450c44518442084450f4002c6050f400034030844521442204450c000004452c6050c4451844218445
0125000001445014420d445034002c605034000340308445044420d4450d0050c4422c605154451444204445004450c442084450f4002c6050f400034030844515442144450c000004452c605004450c4420c445
012500000944508402104450f4420d4450b4000d4450f442144450f4050d405184021044510405124451240514445104020d405084051044512442104450440503445124050c400014420c4450c4051444518405
011a0000034030340303400034002c605034000340303400034031b4000f4000f4002c6050f4000f4000f40003403034030f4000f4002c6050f400034030f4000340303403034030f4002c6050f400034030f400
011a0000034030340303400034002c605034000340303400034031b4000f4000f4002c6050f4000f4000f40003403034030f4000f4002c6050f400034030f4000340303403034030f4002c6050f400034030f400
__music__
01 03 05 43 44
02 04 06 43 44
01 15 42 43 44
00 13 15 19 44
00 16 15 19 44
04 17 1b 1a 44
00 33 42 43 44
01 30 2c 43 44
02 31 2d 43 44
00 33 42 43 44
01 38 3b 43 44
00 3a 3c 43 44
02 39 3d 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
