pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--infestation

--by remagamer (2019)

--big thanks to unii!

function _init()
 --initialize things.
 
 --set the screen mode to 64x64.
 poke(0x5f2c,3)
 
 --set up the game table.
 initgame()
 --set up the player table.
 initplayer()
 --set up various empty tables.
 bullets={} --for bullets.
 entities={} --for entities.
 visuals={} --for visuals.
 
 //controls message
 //cls()
 //message("this game is a\nwork in\nprogress.\nŽ continue\nby remagamer\nspecial thanks\nto unii")
 //message("your name,\njohn halo.\n\nyour mission,\nshoot alein.\n\nŽaccept")
 //message(gm.txt[3])
 
end

function _update()
 --update things.
 
 --update core game stuff.
 gmupdate()
 
 if gm.m=="game" then
  --update the player.
  plupdate()
  --update bullets.
  bulupdate()
  --update entities.
  entupdate()
  --update visuals.
  visupdate()
  --try to add environmental effects.
  enveffects()
 end

end

function _draw()
 --draw things.
 
 --clean up the screen.
 cls()
 camera()
 
 if gm.m=="game" then
  --move the camera.
  camera(gm.cx+rnd(gm.cs)-gm.cs/2,gm.cy+rnd(gm.cs)-gm.cs/2)
  --draw visuals.
  visdraw()
  --draw bullets.
  buldraw()
  --draw entities
  entdraw()
  --draw the player.
  pldraw()
  --draw the map.
  map(0,0,0,0,128,64,0x80)
  --draw the ui.
  uidraw()
  
 end
 
 --draw core stuff.
 gmdraw()

end

-->8
--initialization

function initgame()
 --set up the game table.
 
 gm={
  
  --€core stuff
  m="game", --mode
  s=0, --global sine.
  dbg=-1, --debug toggle.
  --€camera
  cx=0, --camera x
  cy=0, --camera y
  cs=0, --camera shake
  --€game variables
  g=.3, --gravity.
  gf={
   --flags.
   false, --boss 1
   false, --boss 2
   false, --boss 3
   false, --health upgrade
   false, --drone get
  },
  --€misc stuff
  tl=0, --transition level
  hpt={
   --health point text.
   {t="[error]",c=2},
   {t="offline",c=8},
   {t="failing",c=9},
   {t="fraying",c=10},
   {t="stable",c=11},
   {t="optimal",c=12},
   {t="charged",c=7},
  },
  --text tables
  txt={
   "you got the\ncleaner gun!\nthis gun fires\nslowly, but\nhits hard!",
   "you got the\nspread gun!\nthis gun is\nweak, but fires\nthree shots in\na wide spread!",
   "controls\n‹‘ move\n” jump\nŽ shoot\n— swap gun\n\nŽexit message",
   "you're powered\nup! fill your\npower bar to\nfire your gun\nfaster. being\nhit reduces\nyour power bar.",
   "you got the\nshield upgrade!\nyour shields\ncan take one\nmore hit!",
   "you got the\ndrone upgrade!\na little drone\nwill help you\nfight!",
   "you got the\nbounce gun!\nthis gun fires\nthree bouncing\nshots!",
  },
  --color tables
  ecp={ --enemy color palette
   2,
   8,
   14,
  },
  
 }
end

function initplayer()
 --set up the player table.
 
 pl={
  
  --€coordinate stuff
  x=156, --x coordinate
  y=96, --y coordinate
  vx=0, --x velocity
  vy=1, --y velocity
  sx=156, --spawn x
  sy=96, --spawn y
  --€sprite stuff
  s=64, --base sprite
  sf=0, --sprite frame
  sfl=false, --sprite flip flag.
  --€state stuff
  bsc=1, --bounce shot counter
  ba=0, --bullet angle
  il=15, --input lock.
  gr=false, --grounded.
  sgr=false, --special grounded flag.
  jl=false, --jump lock.
  jg=5, --jump grace.
  rl=0, --reload.
  pow=0, --power level
  pwr=false, --power flag
  pwrm=false, --power message flag
  inv=0, --invincibility frames.
  dt=0, --death timer.
  --€stat stuff
  jp=2.65, --jump power
  hp=5, --health points.
  mhp=5, --max health points.
  h=0, --heat percentage.
  --€gun stuff
  gn=1, --active gun.
  cleaner=false, --cleaner gun enabled.
  spread=false, --burst gun enabled.
  bounce=false, --bounce gun enabled.
  ultra=false, --ultra gun enabled.
  
 }
end

--€€entities€€

function addbird(x,y)
 --adds a bird.
 add(entities,{n="bird",x=x,y=y,dt="1spr",s=71,hp=4,hs=25,cd=1,dg=25,bc=45,fly=false,vx=0,vy=0})
end

function adddrone(x,y)
 --adds a drone (player-friendly)
 add(entities,{n="drone",x=x,y=y,dt="1spr",s=85,t=30,a=0})
end

function adddripper(x,y)
 --adds a dripper.
 add(entities,{n="dripper",x=x,y=y,dt="1spr",s=-1,t=30+rnd(30)})
end

function adddroplet(x,y,t)
 --adds a droplet.
 add(entities,{n="droplet",x=x,y=y,t=t,dt="1spr",s=69,vy=0,sfvl=true,cd=1,hs=25})
end

function addblocker(x,y,f)
 --adds a blocker.
 add(entities,{n="blocker",x=x,y=y,f=f})
end

function addmovingplatform(x,y)
 --adds a moving platform.
 add(entities,{n="movingplatform",dt="bspr",s=118,x=x,y=y,xs=2,ys=1,fl=1,pl=false})
end

function addupgdrone(x,y)
 --adds a drone (upgrade)
 add(entities,{n="upgdrone",dt="1spr",s=85,x=x,y=y,sy=y})
end

function addupghealth(x,y)
 --adds a health (upgrade)
 add(entities,{n="upghealth",dt="1spr",s=120,x=x,y=y,sy=y})
end

function addupgcleaner(x,y)
 --adds a cleaner (upgrade)
 add(entities,{n="upgcleaner",dt="1spr",s=96,x=x,y=y,sy=y})
end

function addupgspread(x,y)
 --adds a spread (upgrade)
 add(entities,{n="upgspread",dt="1spr",s=97,x=x,y=y,sy=y})
end

function addupgbounce(x,y)
 --adds a bounce (upgrade)
 add(entities,{n="upgbounce",dt="1spr",s=98,x=x,y=y,sy=y})
end

function addspawnpoint(x,y)
 --adds a spawnpoint.
 add(entities,{n="spawnpoint",dt="1spr",s=117,x=x,y=y,sy=y,tr=false})
end

function addpustule(x,y)
 --adds a pustule.
 add(entities,{n="pustule",dt="1spr",x=x,y=y,vy=1,s=68,hp=5,cd=1,dg=30,bc=25,hs=25})
end

function addeyeboss(x,y)
 --adds the eyeboss.
 add(entities,{n="eyeboss",dt="circf",x=x,y=y,r=3,c=2,hp=150,hs=36,rl=false,sc=2,a=0,tx=x+8,ty=y+4,ry=y,rx=x,mode="neutral",cld=120,sa=0,ncld=120,boss=true,dc=0,dv=0})
end

function addblob(x,y,vx)
 --adds a blob.
 add(entities,{n="blob",dt="1spr",r=3,s=68,hp=5,x=x,y=y,vx=vx,vy=0,dg=30,hs=25,cd=1,bc=25})
end

function addslime(x,y,vy)
 --adds a slime. only use 2 for vy
 add(entities,{n="slime",dt="1spr",x=x,y=y,vx=.5,s=69,hs=25,hp=5,dg=30,cd=1,sfvl=false,at=0,vm=false,vy=vy,w=0,bc=25,hs=25})
end

function addbattery(x,y)
 --adds a battery.
 add(entities,{n="battery",dt="1spr",s=101,x=x,y=y})
end

--€€bullets€€

function addpcleaner(x,y,a,sfl)
 --adds a player clearing bullet.
 add(bullets,{n="cleaner",dt="1spr",p=true,x=x,y=y,a=a,s=96,sfl=sfl,dmg=3,hs=9,pw=false,gc=3})
end

function addpspread(x,y,a,sfl)
 --adds a player spread bullet.
 add(bullets,{n="spread",dt="1spr",p=true,x=x,y=y,a=a,s=114,sfl=sfl,dmg=1,hs=9,pw=false,gc=1})
end

function addpbounce(x,y,a,sfl)
 --adds a player bounce bullet.
 add(bullets,{n="bounce",dt="1spr",p=true,x=x,y=y,a=a,s=86,sfl=sfl,dmg=3,hs=9,pw=true,gc=10,vy=-1,})
end

function addbiglaser(x,y,a,c)
 --adds a big laser.
 add(bullets,{n="biglaser",dt="circf",x=x,y=y,p=false,c=c,r=5,hs=64,dmg=2,a=a})
end

function addlaser(x,y,a,c,v)
 --adds a laser.
 add(bullets,{n="laser",dt="circf",x=x,y=y,p=false,c=c,r=2,a=a,dmg=1,hs=25,v=v})
end

--€€visuals€€

function addeyeback(x,y,c)
 --adds an eye back visual.
 add(visuals,{n="eyeback",dt="circf",x=x,y=y,c=c,r=7,lt=1})
end

function addglow(x,y,c,r)
 --adds a glow visual.
 add(visuals,{n="glow",dt="circf",x=x,y=y,c=c,r=r,vx=rnd(4)-2,vy=rnd(4)-2})
end

function addbug(x,y)
 --adds a bug visual.
 add(visuals,{n="bug",dt="pset",x=x,y=y,c=2,a=rnd(1),tm=5+rnd(30),v=rnd(1.5)})
end

function addgun(x,y)
 --adds a gun visual.
 add(visuals,{n="gun",dt="line",x=x,y=y,x2=x,y2=y,c=7,vx=pl.vx,vy=-2,a=0,va=.1})
end

function addshield(x,y)
 --adds a shield visual.
 add(visuals,{n="shield",dt="circ",c=gm.hpt[pl.hp+1].c,r=6,t=0,x=x,y=y})
end

function addhittext(t,x,y)
 --adds a hit text visual.
 add(visuals,{n="hit text",dt="text",x=x,y=y,t=t,vx=rnd(2)-1,vy=-2.5,lt=10,c=8})
end

function addgoo(x,y,vx,vy,r)
 --adds a goo visual.
 add(visuals,{n="goo",dt="circf",x=x+rnd(4)-2,y=y,c=2,r=r,vx=vx,vy=vy,hit=0})
end

function addlight(x,y,c)
 --adds a light visual.
 add(visuals,{n="light",dt="line",x=x,y=y,x2=x,y2=y,vy=-rnd(1),c=c})
end

function addlightning(x,y,x2,y2,c)
 --adds a lightning visual.
 add(visuals,{n="lightning",dt="line",x=x,y=y,x2=x2,y2=y2,c=c,lt=rnd(15)})
end

--€€flag guide€€
--0€solid
--1€shifts back one sprite when shot
--2€shifts forward one sprite when a new room is entered
--3€shifts back one sprite when shot with burst.
--4€shifts back one sprite when shot with bounce.
--5€n/a
--6€hurts player
--7€renders
-->8
--general

function isoffscreen(x,y)
 if x<gm.cx-8 or x>gm.cx+64 or y<gm.cy-8 or y>gm.cy+48 then
  return true
 else 
  return false
 end
end

function transition()
 --raises the "curtain".
 while gm.tl<64 do
  gm.tl+=1
  rectfill(gm.cx,gm.cy+64,gm.cx+64,gm.cy+64-gm.tl,0)
  flip()
 end
end

function enveffects()
 --tries to generate effects
 --based on tile flags.
 --tries 10 times.
 for t=1,10 do
  --get a tile on the screen.
  local nx=gm.cx+rnd(64)
  local ny=gm.cy+rnd(48)
  --flies off of infected tiles.
  if fmget2(nx,ny,1)==true then
   addbug(nx,ny)
  end
  --gas off of damaging tiles.
  if fmget2(nx,ny,6)==true then
   addgoo(nx,ny,rnd(2)-1,-2,rnd(2))
  end
  
 end
end

function message(t)
 --pops up a message that
 --freezes the game.
 
 --lock player input a bit.
 pl.il=5
 --set up variables.
 local txt={"","","","","",} --text message.
 local ty=0 --text y value.
 local tn=1 --text number.
 local tm=0 --time value
 --draw the textbox.
 rectfill(gm.cx+1,gm.cy+1,gm.cx+62,gm.cy+46,1)
 rectfill(gm.cx+2,gm.cy+2,gm.cx+61,gm.cy+45,13)
 while btn(4)==false or tm~=#t do
  print(sub(t,1,tm),gm.cx+3,gm.cy+3,7)  
  if tm<#t then
   tm+=1
  end
  if tm%4==0 and tm<#t then
   sfx(5)
  end
  flip()
 end
end
 

function fmget(x,y,f)
 --this function is a simplified
 --tile checker.
 return fget(mget((x+4)/8,(y+4)/8),f)
end

function fmget2(x,y,f)
 --this function is a simplified
 --tile checker.
 return fget(mget((x)/8,(y)/8),f)
end

function dist(x,y,x2,y2)
 --gets the distance between
 --two points.
 local dx, dy = x - x2, y - y2
 local res=(dx * dx + dy * dy)
 if res<0 then
  res=32767
 end
 return res
end

function angle(x,y,x2,y2)
 --this function returns an
 --angle between the two
 --coordinate sets.
 return atan2(x2-x,y2-y)
end
-->8
--core game stuff

function gmupdate()
 --updates core game stuff.
 
 --lower transition "curtain".
 if gm.tl>=0 then
  gm.tl-=1
 end
 --update sine.
 gm.s+=1/30
 if gm.s>=1 then
  gm.s=0
 end
 --update camera.
 local cy=gm.cy
 local cx=gm.cx
 gm.cx=(flr((pl.x+4)/64))*64
 gm.cy=(flr((pl.y+4)/48))*48
 gm.cs/=2
 --help transitioning between
 --horizontal floors.
 if gm.cy<cy then
  pl.vy=-4
 end
 --reload when entering a new room.
 if gm.cx~=cx or gm.cy~=cy then
  --clean up the old room.
  visuals={}
  bullets={}
  entities={}
  --spawn a drone, if the player has one.
  if gm.gf[5]==true then
   adddrone(pl.x,pl.y)
  end
  --spawn the new room's stuff.
  for x=(gm.cx+4)/8,((gm.cx+4)/8)+7 do
   for y=(gm.cy+4)/8,((gm.cy+4)/8)+5 do
    --regenerate tiles.
    if fget(mget(x,y),2)==true then
     mset(x,y,mget(x,y)+1)
    end
    local nx=x*8-4
    local ny=y*8-4
    --spawn pustules.
    if mget(x,y)==48 then
     addpustule(nx,ny)
    end
    --spawn blobs.
    if mget(x,y)==50 then
     addblob(nx,ny,1)
    end
    --spawn slimes. (upside down and right side up)
    if mget(x,y)==53 then
     addslime(nx,ny,-2)
    end
    if mget(x,y)==57 then
     addslime(nx,ny-1,2)
    end
    --spawn dripper
    if mget(x,y)==58 then
     adddripper(nx,ny,60)
    end
    --spawn upgcleaner.
    if mget(x,y)==51 then
     if pl.cleaner==false then
      addupgcleaner(nx+4,ny+4)
     else
      addspawnpoint(nx+4,ny+4)
     end
    end
    --spawn upgspread.
    if mget(x,y)==55 then
     if pl.spread==false then
      addupgspread(nx+4,ny+4)
     else 
      addspawnpoint(nx+4,ny+4)
     end
    end
    --spawn upgbounce.
    if mget(x,y)==61 then
     if pl.bounce==false then
      addupgbounce(nx+4,ny+4)
     else 
      addspawnpoint(nx+4,ny+4)
     end
    end
    --spawn upghealth.
    if mget(x,y)==56 then
     if gm.gf[4]==false then
      addupghealth(nx+4,ny+4)
     else 
      addspawnpoint(nx+4,ny+4)
     end
    end
    --spawn spawnpoint.
    if mget(x,y)==52 then
     addspawnpoint(nx+4,ny+4)
    end
    --spawn boss 1 (eye)
    if mget(x,y)==49 and gm.gf[1]==false then
     addeyeboss(nx+4,ny)
    end
    --spawn moving platform.
    if mget(x,y)==54 then
     addmovingplatform(nx,ny)
    end
    --spawn bird.
    if mget(x,y)==60 then
     addbird(nx,ny)
    end
    --spawn upgdrone.
    if mget(x,y)==59 then
     if gm.gf[5]==false then
      addupgdrone(nx+4,ny+4)
     else 
      addspawnpoint(nx+4,ny+4)
     end
    end
   end
  end
 end
 
end

function gmdraw()
 --draws core game stuff.
 
 --transition
 rectfill(gm.cx,gm.cy+64,gm.cx+64,gm.cy+64-gm.tl,0)
 --debug
 if gm.dbg==1 then
  print(stat(1),gm.cx,gm.cy,8)
 end
end

function uidraw()
 --draws the player's ui.
 
 --draw the window.
 rectfill(gm.cx,gm.cy+48,gm.cx+63,gm.cy+63,1)
 rectfill(gm.cx+1,gm.cy+49,gm.cx+62,gm.cy+62,13)
 --draw weapon.
 spr(112,gm.cx-7+pl.gn*8,gm.cy+49)
 spr(96,gm.cx+1,gm.cy+49,4,1)
 if pl.cleaner==false then
  spr(113,gm.cx+1,gm.cy+49)
 end
 if pl.spread==false then
  spr(113,gm.cx+9,gm.cy+49)
 end
 if pl.bounce==false then
  spr(113,gm.cx+17,gm.cy+49)
 end
 if pl.ultra==false then
  spr(113,gm.cx+25,gm.cy+49)
 end
 --power bar
 rectfill(gm.cx+2,gm.cy+58,gm.cx+32,gm.cy+61,0)
 rectfill(gm.cx+2,gm.cy+58,gm.cx+2+pl.pow/3.3,gm.cy+61,9+rnd(1.1))
 --health status
 rectfill(gm.cx+33,gm.cy+50,gm.cx+61,gm.cy+56,1)
 print(gm.hpt[pl.hp+1].t,gm.cx+34,gm.cy+51,gm.hpt[pl.hp+1].c)
 --buttons
 print("Ž",gm.cx+34,gm.cy+58,5)
 print("—",gm.cx+47,gm.cy+58,5)
 spr(115,gm.cx+40,gm.cy+56)
 spr(116,gm.cx+53,gm.cy+56)
end
-->8
--player

function plupdate()
 --update the player.

 --keep the power bar in min/max
 pl.pow=mid(0,pl.pow,100)
 --toggle power mode if at 100.
 if pl.pow>=100 and pl.pwr==false then
  sfx(29)
  pl.pwr=true
  if pl.pwrm==false then
   pl.pwrm=true
   message(gm.txt[4])
  end
 end
 --toggle power off if at 0.
 if pl.pow<=0 then
  pl.pwr=false
 end
 --power's visual effect.
 if pl.pwr==true then
  addglow(pl.x+4,pl.y+4,9+rnd(2),2.5)
 end
 --freeze the player if dead.
 if pl.hp==0 then
  pl.il=15
  pl.dt+=1
  if pl.dt==120 then
   pl.x=pl.sx
   pl.y=pl.sy
   pl.hp=5
   pl.dt=0
   transition()
  end
 end
 --tick down invincibility.
 if pl.inv>0 then
  pl.inv-=1
 end 
 --update grounded state.
 if fmget(pl.x,pl.y+4,0)==true or pl.sgr==true then
  if pl.gr==false then
   sfx(2)
  end
  pl.gr=true
  pl.jg=5
  pl.vy=min(0,pl.vy)
 else
  pl.gr=false
  if pl.jg>0 then
   pl.jg-=1
  end
 end
 --tick down special grounded flag.
 pl.sgr=false
 --apply gravity.
 if pl.gr==false then
  pl.vy+=gm.g
 end
 --keep the player out of the ground.
 while fmget(pl.x,pl.y+3,0)==true do
  pl.y-=1
 end
 --check for hurtful blocks.
 if fmget(pl.x,pl.y,6)==true and pl.inv<=0 then
  hurtplayer(1)
 end
 --get firing angle.
 if pl.sfl==false then
  pl.ba=0
 else
  pl.ba=.5
 end
 --if not input locked, take input.
 if pl.il<=0 then
  --take inputs.
  --move left
  if btn(0) then
   pl.vx-=.2
  end
  --move right
  if btn(1) then
   pl.vx+=.2
  end
  --jump
  if btn(2) and pl.gr==true and pl.jl==false or btn(2) and pl.jg>0 and pl.jl==false then
   pl.vy=-pl.jp
   --check for boost block.
   if mget((pl.x+4)/8,(pl.y+12)/8)==34 then
    pl.vy=-4.5
    sfx(16)
   end
   pl.jg=0
   pl.jl=true
   sfx(0)
  end
  if not btn(2) then
   pl.jl=false
  end
  --cool down reload.
  if pl.rl>0 then
   pl.rl-=1
   --reload faster if powered.
   if pl.pwr==true then
    pl.rl-=1
    pl.pow-=1
   end
  end
  --fire weapon
  if btn(4) and pl.rl<=0 then
   if pl.gn==1 then
    pl.rl=10
    if pl.cleaner==true then
     --cleaner
     addpcleaner(pl.x,pl.y,pl.ba,pl.sfl)
     sfx(7)
    else
     sfx(15)
    end
   end
   if pl.gn==2 then
    pl.rl=8
    if pl.spread==true then
     --spread
     addpspread(pl.x,pl.y,pl.ba-.05,pl.sfl)
     addpspread(pl.x,pl.y,pl.ba,pl.sfl)
     addpspread(pl.x,pl.y,pl.ba+.05,pl.sfl)
     sfx(18)
    else
     sfx(15)
    end
   end
   if pl.gn==3 then
    pl.rl=20
    if pl.bounce==true then
     --spread
     --trigger shot counter
     pl.bsc=16
     sfx(38)
    else
     sfx(15)
    end
   end
  end
  --swap weapon
  if btnp(5) then
   pl.gn+=1
   sfx(5)
   if pl.gn>=5 then
    pl.gn=1
   end
  end
 else
  --tick down input lock.
  pl.il-=1
 end
 --tick down the bounce gun.
 if pl.bsc>1 then
  pl.bsc-=1
 end
 --fire the bounce gun if %5.
 if pl.bsc%5==0 then
  addpbounce(pl.x,pl.y,pl.ba,pl.sfl)
 end
 --degrade/cap velocities.
 pl.vx=mid(-1.5,pl.vx,1.5)
 pl.vy=mid(-7,pl.vy,7)
 pl.vx/=1.15
 --process velocities.
 if fmget(pl.x+pl.vx,pl.y,0)==false then
  pl.x+=pl.vx
 else
  pl.vx=0
 end
 if fmget(pl.x,pl.y+pl.vy,0)==false then
  pl.y+=pl.vy
 else
  pl.vy=0
 end
 --figure out animations.
 
 --reset to default sprite.
 pl.s=64
 --cycle through walk animation.
 if abs(pl.vx)+abs(pl.vy)>.3 and pl.gr==true then
  pl.sf+=.4
  if pl.sf>4 then
   pl.sf=0
   sfx(1)
  end
 else
  pl.sf=0
 end
 --determine flip.
 if pl.gr==true and not btn(4) then
  if pl.vx>0 then
   pl.sfl=false
  elseif pl.vx<0 then
   pl.sfl=true
  end
 end
 --jump sprites.
 if pl.gr==false then
  if pl.vy<=1 then
   pl.s=82
  else
   pl.s=83
  end
 end
 --death sprites.
 if pl.hp<=0 then
  if pl.gr==true then
   pl.s=80
  else 
   pl.s=84
  end
  if pl.dt>=100 then
   if pl.dt==100 then 
    sfx(2)
   end
   pl.s=81
  end
  pl.sf=0
 end


 
end

function pldraw()
 --draw the player.
 
 if pl.inv<=0 or pl.inv%2==0 then
  spr(pl.s+pl.sf,pl.x,pl.y,1,1,pl.sfl)
 end
 
end

function hurtplayer(dmg,x,y)
 --hurts the player.
 if pl.hp-dmg>0 then
  addshield(pl.x+4,pl.y+4)
  sfx(10)
  if x~=nil and y~=nil then
   local a=angle(x,y,pl.x,pl.y)
   pl.vx+=3*cos(a)
   pl.vy+=3*sin(a)
  end
  pl.pow/=2
  pl.hp-=dmg
  pl.inv=30
  gm.cs=2.5
 else
  pl.hp=0
  if pl.dt==0 then
   pl.vx+=3*cos(a)
   pl.vy+=3*sin(a)
   pl.dt=1
   addgun(pl.x+4,pl.y+4)
   sfx(11)
  end
 end
end

function healplayer(hp)
 --heals the player.
 pl.hp+=hp
 pl.hp=min(pl.hp,pl.mhp)
 addshield(pl.x+4,pl.y+4)
 for n=1,20 do
  addlight(pl.x+rnd(12)-2,pl.y+rnd(8),gm.hpt[pl.hp+1].c)
 end
 sfx(14)
end
-->8
--entities

function entupdate()
 --updates entities.
 
 for n, i in pairs(entities) do
 
  --if offscreen, delete
  if isoffscreen(i.x,i.y)==true and i.boss~=true then
   del(entities,i)
  end
  --€entities below
  
  if i.n=="bird" then
   if #bullets>0 and i.fly==false then
    i.fly=true
    sfx(37)
   end
   if pl.x>i.x then
    i.sfl=true
   else
    i.sfl=false
   end
   if i.fly==true then
    if fmget(i.x,i.y+i.vy,0)==false then
     i.y+=i.vy
    else
     i.vy=0
    end
    if pl.y>i.y then
     i.vy+=.05
    else
     i.vy-=.2
    end
    if pl.x>i.x then
     i.vx+=.2
    else
     i.vx-=.1
    end
    i.vx=mid(-2,i.vx,2)
    if fmget(i.x+i.vx,i.y,o)==false then
     i.x+=i.vx
    else
     i.vx*=-.5
    end
    --fly.
    if i.s==71 then
     i.s=72
    else
     i.s=71
    end
   end
  end 
  if i.n=="upgdrone" then
   addlight(i.x+rnd(8),i.y+rnd(8),1)
   i.y=i.sy+3*sin(gm.s)
   if dist(pl.x,pl.y,i.x,i.y)<25 and gm.gf[5]==false then
    gm.gf[5]=true
    adddrone(pl.x,pl.y)
    sfx(17)
    message(gm.txt[6])
    del(entities,i)
   end
  end
  
  if i.n=="dripper" then
   --tick down counter
   i.t-=1
   if i.t<=0 then
    adddroplet(i.x,i.y-1,30)
    i.t=30+rnd(30)
    sfx(0)
   end
  end
  
  if i.n=="drone" then
   --player friendly drone
   i.x=pl.x+4*cos(gm.s)
   i.y=pl.y-5+2*sin(gm.s)
   i.sfl=pl.sfl
   --explode if the player dies.
   if pl.hp<=0 then
    for n=1,15 do
     addglow(i.x+3,i.y+3,8+rnd(3),1+rnd(3))
    end
    del(entities,i)
   end
   --fire at enemies.
   i.t-=1
   if i.t<=0 then
    --shoot at the first entity
    --that can be damaged.
    for n, i2 in pairs(entities) do
     if i2.hp~=nil then
      i.a=angle(i.x+4,i.y+4,i2.x+4,i2.y+4)
      addpspread(i.x+3,i.y+3,i.a,i.sfl)
      for n=1,5 do
       addglow(i.x+3,i.y+3,1,rnd(3))
      end
      sfx(36)
      break
     end
    end
    i.t=60
   end
  end
  
  if i.n=="eyeboss" then
   --reveal itself and lock player in.
   if dist(pl.x,0,i.x,0)<=64 and i.rl==false then
    for n=1,64 do
     addgoo(i.x,i.y,rnd(4)-2,rnd(4)-2,1+rnd(3))
    end
    i.rl=true
    i.sc=7
    i.c=8
    addblocker(256,220,1)
    addblocker(312,220,1)
    sfx(28)
   end
   --ai command.
   if i.rl==true then
    --sine wave movement.
    i.y=i.ry+3*sin(gm.s)
    i.x=i.rx+3*cos(gm.s)
    --if below 50% hp, attack faster.
    if i.hp<=75 then
     i.ncld=60
     i.sc=14
    end
    --check for death.
    if i.hp<=0 then
     i.mode="death"
    else
     --look at player.
     i.a=angle(i.x,i.y,pl.x+4,pl.y+4)
    end
    --death mode.
    if i.mode=="death" then
     i.tx=288
     i.ty=212
     if flr(i.a)%2==0 and i.dc<=150 then
      sfx(34)
      local x=i.x+rnd(32)-16
      local y=i.y+rnd(32)-16
      for n=1,20 do
       addglow(x,y,8+rnd(3),2+rnd(2))
      end
     end
     i.dc+=1
     --end fight.
     if i.dc>=150 then
      i.a=.75
      if i.dc>=180 then
       i.ty=300
       i.ry+=i.dv
       i.dv+=.1
       if i.ry>=300 then
        for n=1,50 do
         addglow(288,232,8+rnd(3),4+rnd(2))
         addgoo(264+rnd(40),220,rnd(6)-3,-rnd(4),2+rnd(4))
        end
        sfx(35)
        --flip the first boss flag.
        gm.gf[1]=true
        del(entities,i)
       end
      end
     else
      i.a+=.1
     end
    end
    --neutral mode.
    if i.mode=="neutral" then
     i.tx=288
     i.ty=212
     i.cld-=1
     if i.cld<=0 then
      i.cld=120
      --swap to a new attack.
      local rng=flr(rnd(3))+1
      --big laser
      if rng==1 then
       i.mode="top"
      end
      --targeting beams
      if rng==2 then
       i.mode="side"
       if i.x<=pl.x then
        i.tx=272
       else
        i.tx=304
       end
        i.ty=212
      end
      --tear spray
      if rng==3 then
       i.mode="bottom"
      end
     end
    end
    --tear spray (bottom)
    if i.mode=="bottom" then
     i.cld-=1
     i.tx=288
     i.ty=228
     if i.cld<=90 then
      addgoo(i.x,i.y,rnd(6)-3,-4,2+rnd(4))
      if i.cld%10==0 then
       sfx(0)
       adddroplet(264+rnd(40),199,90)
      end
     end
     if i.cld<=0 then
      --go back to neutral
      i.mode="neutral"
      i.cld=i.ncld
     end
    end
    --targeted laser mode (side)
    if i.mode=="side" then
     i.cld-=1
     --shoot at the player.
     if i.cld<=89 then
      if i.cld%30==20 then
       sfx(32)
      end
      if i.cld%30==0 then
       i.sa=angle(i.x,i.y,pl.x+4,pl.y+4)
       addlaser(i.x,i.y,i.sa,8,3)
       addlaser(i.x,i.y,i.sa,8,2.5)
       addlaser(i.x,i.y,i.sa,8,2)
       sfx(31)
      end
     end
     if i.cld<=0 then
      i.mode="neutral"
      i.cld=i.ncld
     end
    end
    --big laser mode (top)
    if i.mode=="top" then
     i.cld-=1
     --set target.
     if i.cld>60 then
      i.ty=200
      i.tx=flr(pl.x+4)
      if i.cld%10==0 then
       sfx(32)
      end
     elseif i.cld<=30 then
      --create bullets.
      addglow(i.x,i.y,gm.ecp[flr(rnd(#gm.ecp))+1],5)
      addbiglaser(i.x,i.y+4,.75,gm.ecp[flr(rnd(#gm.ecp))+1])
      sfx(31)
     end
     if i.cld<=0 then
      i.mode="neutral"
      i.cld=i.ncld
     end
    end
    
    --try to move to the target location.
    if i.rx>i.tx then
     i.rx-=1
    elseif i.rx<i.tx then
     i.rx+=1
    end
    if i.ry>i.ty then
     i.ry-=1
    elseif i.ry<i.ty then
     i.ry+=1
    end
   end
   --draw eyeback.
   addeyeback(i.x-3*cos(i.a),i.y-3*sin(i.a),i.sc)
  end
  
  if i.n=="droplet" then
   i.t-=1
   if i.t==1 then
    sfx(2)
    i.s=68
    i.sfvl=false
    for n=1,15 do
     addgoo(i.x+4,i.y+4,rnd(2)-1,-1,rnd(3))
    end
   end
   if i.t<=0 then
    i.vy+=.1
    i.y+=i.vy
    if fmget(i.x,i.y,0)==true then
     for n=1,15 do
      addgoo(i.x+4,i.y+4,rnd(2)-1,-1,rnd(3))
     end
     del(entities,i)
    end
   end
  end
  
  if i.n=="slime" then
   --grounded mode
   if i.vm==false then
    if i.vy==-2 then
     i.sfvl=false
    else 
     i.sfvl=true
    end
    --animate
    if i.at>=5 then
     if i.s==69 then
      i.s=70
     else
      i.s=69
     end
     i.at=0
    else
     i.at+=1
    end
    --move in the direction faced.
    if fmget(i.x+i.vx,i.y,0)==false and fmget(i.x+i.vx,i.y-i.vy*2,0)==true then
     i.x+=i.vx
    else
     i.vx*=-1
    end
    --if player is above, jump
    if dist(i.x,0,pl.x,0)<=8 then
     i.vm=true
     i.w=10
    end
   else
    --wait before launching
    if i.w<=0 then
     --flying mode
     i.s=68
     i.sfvl=false
     if fmget(i.x,i.y+i.vy*2,0)==false then
      i.y+=i.vy
     else
      i.vm=false
      i.vy*=-1
      if pl.x>=i.x then
       i.vx=abs(i.vx)
      else
       i.vx=-abs(i.vx)
      end
     end
    else
     i.w-=1
     i.s=70
     if i.w==0 then
      sfx(0)
     end
    end
   end     
  end
 
  if i.n=="movingplatform" then
   --move
   i.x+=i.fl*.5
   if i.pl==true then
    if fmget(pl.x+i.fl*.5,pl.y,0)==false then
     pl.x+=i.fl*.5
    end
    if pl.vy>0 then
     pl.y=i.y-8
    end
    pl.sgr=true
   end
   --check for collisions
   if fmget(i.x,i.y,0)==true or fmget(i.x+8,i.y,0)==true then
    i.fl*=-1
   end
   --check if the player is riding it.
   if dist(0,pl.y,0,i.y-8)<4 and dist(pl.x,0,i.x+4,0)<64 then
    i.pl=true
   else
    i.pl=false
   end
  end
    
  if i.n=="blocker" then
   --block player from moving through
   --the area.
   if dist(pl.x,0,i.x,0)<16 then
    local a=angle(pl.x+4,pl.y+4,i.x+4,i.y+4)
    pl.vx=-cos(a)*1
   end
   --create visual effects.
   addlightning(i.x+rnd(8),i.y-4,i.x+rnd(8),i.y+12,gm.ecp[flr(rnd(#gm.ecp))+1])
   addgoo(i.x+4,i.y-4,rnd(.5)-.25,0,rnd(2))
   --remove if flag is checked.
   if gm.gf[i.f]==true then
    del(entities,i)
   end
  end
  
  if i.n=="pustule" then
   i.y+=i.vy
   if fmget(i.x,i.y,0)==true then
    i.vy*=-1
    for n=1,10 do
     addgoo(i.x+4,i.y+4,rnd(2)-1,rnd(2)-1,rnd(3))
    end
    sfx(0)
   end
  end
  
  if i.n=="battery" then
   if fmget(i.x,i.y,0)==false then
    i.y+=1
   end
   if dist(i.x,i.y,pl.x,pl.y)<25 then
    healplayer(1)
    del(entities,i)
   end
  end
  
  if i.n=="upgcleaner" then
   i.y=i.sy+3*sin(gm.s)
   addlight(i.x+rnd(8),i.y+rnd(8),11)
   if dist(pl.x,pl.y,i.x,i.y)<25 then
    pl.cleaner=true
    del(entities,i)
    sfx(17)
    message(gm.txt[1])
   end
  end
  
  if i.n=="upgspread" then
   i.y=i.sy+3*sin(gm.s)
   addlight(i.x+rnd(8),i.y+rnd(8),1)
   if dist(pl.x,pl.y,i.x,i.y)<25 then
    pl.spread=true
    del(entities,i)
    sfx(17)
    message(gm.txt[2])
   end
  end
  
  if i.n=="upgbounce" then
   i.y=i.sy+3*sin(gm.s)
   addlight(i.x+rnd(8),i.y+rnd(8),10)
   if dist(pl.x,pl.y,i.x,i.y)<25 then
    pl.bounce=true
    del(entities,i)
    sfx(17)
    message(gm.txt[7])
   end
  end
  
  if i.n=="spawnpoint" then
   i.y=i.sy+3*sin(gm.s)
   if dist(pl.x,pl.y,i.x,i.y)<25 and i.tr==false then
    pl.sx=i.x
    pl.sy=i.y
    healplayer(999)
    i.tr=true
   end
  end
  
  if i.n=="upghealth" then
   addlight(i.x+rnd(8),i.y+rnd(8),3)
   i.y=i.sy+3*sin(gm.s)
   if dist(pl.x,pl.y,i.x,i.y)<25 and gm.gf[4]==false then
    pl.mhp+=1
    sfx(17)
    healplayer(999)
    message(gm.txt[5])
    gm.gf[4]=true
    del(entities,i)
   end
  end
  
  if i.n=="blob" then
   if fmget(i.x+i.vx,i.y,0)==false then
    i.x+=i.vx
   else
    i.vx*=-1
   end
   if fmget(i.x,i.y+i.vy,0)==false then
    i.y+=i.vy
   else
    for n=1,5 do
     addgoo(i.x+4,i.y+4,rnd(2)-1,rnd(2)-1,rnd(3))
    end
    sfx(0)
    i.vy*=-1
   end
   i.vy+=.2
  end
  
  --hit shake
  if i.hit~=nil then
   if i.hit>=0 then
    i.hit-=1
   end
  end
  --contact damage
  if i.cd~=nil then
   if pl.inv<=0 and dist(i.x,i.y,pl.x,pl.y)<i.hs then
    hurtplayer(i.cd,i.x,i.y)
   end
  end
  --death
  if i.hp~=nil then
   if i.hp<=0 and i.boss~=true then
    if i.bc~=nil then
     --loot drop.
     if rnd(100)<=i.bc then
      addbattery(i.x,i.y)
     end
    end
    if i.dg~=nil then
     --death goo.
     for n=1,i.dg do
      addgoo(i.x+4,i.y+4,rnd(4)-2,rnd(4)-2,rnd(3))
     end
    end
    sfx(13)
    del(entities,i)
   end
  end
  
 end
end

function entdraw()
 --draws entities.
 
 for n, i in pairs(entities) do
  
  local x=i.x
  local y=i.y
  if i.hit~=nil then
   if i.hit>0 then
    x+=rnd(4)-2
    y+=rnd(4)-2
   end
  end
  
  if i.dt=="1spr" then
   spr(i.s,x,y,1,1,i.sfl,i.sfvl)
  end
  
  if i.dt=="circf" then
   circfill(x,y,i.r,i.c)
  end
  
  if i.dt=="bspr" then
   spr(i.s,x,y,i.xs,i.ys,i.sfl)
  end
  
 end
end
-->8
--bullets

function bulupdate()
 --update bullets.
 
 for i, n in all(bullets) do
 
  --if offscreen, delete
  if isoffscreen(i.x,i.y)==true then
   del(bullets,i)
  end
  
  if i.n=="cleaner" or i.n=="spread" or i.n=="biglaser" then
   i.x+=4*cos(i.a)
   i.y+=4*sin(i.a)
  end
  
  if i.n=="bounce" then
   i.x+=2*cos(i.a)
   if fmget(i.x,i.y+i.vy,0)==false then
    i.y+=i.vy
   else
    i.vy*=-1
    i.s+=1
    i.dmg-=1
    sfx(0)
   end
   i.vy+=gm.g
   --if bounce is 0, activate collision
   if i.s==88 then
    i.pw=false
   end
  end
  
  if i.n=="laser" then
   i.x+=i.v*cos(i.a)
   i.y+=i.v*sin(i.a)
   addgoo(i.x,i.y,0,-1,rnd(2))
   i.c=gm.ecp[flr(rnd(#gm.ecp))+1]
  end
  
  --collision with solids
  if i.pw==false then
   if fmget(i.x,i.y,0)==true then
    --break breakables if shot
    --by the player
    if fmget(i.x,i.y,1)==true then
     mset((i.x+4)/8,(i.y+4)/8,mget((i.x+4)/8,(i.y+4)/8)-1)
    end
    if fmget(i.x,i.y,3)==true and i.n=="spread" then
     mset((i.x+4)/8,(i.y+4)/8,mget((i.x+4)/8,(i.y+4)/8)-1)
    end
    if fmget(i.x,i.y,4)==true and i.n=="bounce" then
     mset((i.x+4)/8,(i.y+4)/8,mget((i.x+4)/8,(i.y+4)/8)-1)
    end
    for n=1,8 do
     addglow(i.x+4,i.y+4,i.gc,3)
    end
    sfx(i.hs)
    del(bullets,i)
   end
  end
  --collision with enemies
  if i.p==true then
   for n, i2 in pairs(entities) do
    if i2.hp~=nil then
     if dist(i.x,i.y,i2.x,i2.y)<i2.hs then
      i2.hp-=i.dmg
      i2.hit=10
      pl.pow+=i.dmg*2
      pl.pow=mid(0,pl.pow,100)
      del(bullets,i)
      sfx(12)
      addhittext("-"..i.dmg,i2.x,i2.y)
      for n=1,8 do
       addglow(i.x+4,i.y+4,i.gc,3)
      end
     end
    end
   end
  end
  --collision with player
  if i.p==false then
   if pl.inv<=0 and dist(i.x,i.y,pl.x+4,pl.y+4)<i.hs then
    hurtplayer(i.dmg,i.x,i.y)
   end
  end
  
 end
 
end

function buldraw()
 --draw bullets.
 
 for n, i in pairs(bullets) do
  
  if i.dt=="1spr" then
   spr(i.s,i.x,i.y,1,1,i.sfl)
  end
  
  if i.dt=="circf" then
   circfill(i.x,i.y,i.r,i.c)
  end
  
 end
 
end
-->8
--visuals

function visupdate()
 --update visuals.
 
 for i, n in all(visuals) do
  
  if i.n=="eyeback" then
   if i.lt<=0 then
    del(visuals,i)
   end
   i.lt-=1
  end
  
  if i.n=="shield" then
   i.r-=.2
   i.t+=1
   i.x=pl.x+4
   i.y=pl.y+4
   if rnd(100)>50 then
    i.dt="circf"
   else
    i.dt="circ"
   end
   if i.t>30 then
    del(visuals,i)
   end
  end
  
  if i.n=="lightning" then
   i.lt-=1
   if i.lt<=0 then
    del(visuals,i)
   end
  end
  
  if i.n=="glow" then
   i.x+=i.vx
   i.y+=i.vy
   i.r-=.3
   if i.r<=0 then
    del(visuals,i)
   end
  end
  
  if i.n=="gun" then
   if fmget2(i.x+i.vx,i.y+i.vy,0)==false then
    i.x+=i.vx
    i.y+=i.vy
   else
    i.vx*=-.5
    i.vy*=-.5
    i.va/=1.2
    i.a=0
   end
   i.vy+=gm.g
   i.a+=i.va
   i.x2=i.x+4*cos(i.a)
   i.y2=i.y+4*sin(i.a)
  end
  
  if i.n=="goo" then
   i.x+=i.vx
   i.y+=i.vy
   i.vy+=.1
   if fmget2(i.x,i.y,0)==true then
    i.vx/=2
    i.vy/=2
    i.r-=.05
   end
   if i.r<=0 then
    del(visuals,i)
   end
  end
  
  if i.n=="hit text" then
   i.x+=i.vx
   i.y+=i.vy
   i.vy+=gm.g
   i.lt-=1
   if i.lt<=0 then
    del(visuals,i)
   end
  end
  
  if i.n=="light" then
   i.y+=i.vy
   i.y2=i.y+2
   i.vy-=.1
   if i.vy<=-4 then
    del(visuals,i)
   end
  end
  
  if i.n=="bug" then
   i.x+=i.v*cos(i.a)
   i.y+=i.v*sin(i.a)
   i.a+=rnd(.1)-.05
   i.tm-=1
   if i.tm<=0 then
    del(visuals,i)
   end
  end
  
 
 end
 
end

function visdraw()
 --draw bullets.
 
 for n, i in pairs(visuals) do
  
  if i.dt=="1spr" then
   spr(i.s,i.x,i.y,1,1,i.sfl)
  end
  
  if i.dt=="circ" then
   circ(i.x,i.y,i.r,i.c)
  end
  
  if i.dt=="circf" then
   circfill(i.x,i.y,i.r,i.c)
  end
  
  if i.dt=="line" then
   line(i.x,i.y,i.x2,i.y2,i.c)
  end
  
  if i.dt=="text" then
   print(i.t,i.x,i.y,i.c)
  end
  
  if i.dt=="pset" then
   pset(i.x,i.y,i.c)
  end
  
 end
 
end

-- 1. paste this at the very bottom of your pico-8 
--    cart
-- 2. hit return and select the menu item to save
--    a slow render gif (it's all automatic!)
-- 3. tweet the gif with #putaflipinit
-- 
-- notes: 
--
-- this relies on the max gif length being long
-- enough. this can be set with the -gif_len 
-- command line option, e.g.:
--
--   pico8.exe -gif_len 30
--
-- the gif is where it would be when you hit f9.
-- splore doesn't play nicely with this, you
-- need to save the splore cart locally and load
-- it.
--
-- you might need to remove unnecessary 
-- overrides to save tokens. pset() override
-- flips every 4th pset() call.
--
-- this doesn't always play nicely with optional
-- parameters, e.g. when leaving out the color 
-- param.
--
-- name clashes might happen, didn't bother
-- to namespace etc.

function cflip() if(slowflip)flip()
end
ospr=spr
function spr(...)
ospr(...)
cflip()
end
osspr=sspr
function sspr(...)
osspr(...)
cflip()
end
omap=map
function map(...)
omap(...)
cflip()
end
orect=rect
function rect(...)
orect(...)
cflip()
end
orectfill=rectfill
function rectfill(...)
orectfill(...)
cflip()
end
ocircfill=circfill
function circfill(...)
ocircfill(...)
cflip()
end
ocirc=circ
function circ(...)
ocirc(...)
cflip()
end
oline=line
function line(...)
oline(...)
cflip()
end
opset=pset
psetctr=0
function pset(...)
opset(...)
psetctr+=1
if(slowflip and psetctr%4==0)flip()
end
odraw=_draw
function _draw()
if(slowflip)extcmd("rec")
odraw()
if(slowflip)for i=0,99 do flip() end extcmd("video")cls()stop("gif saved")
end
menuitem(1,"put a flip in it!",function() slowflip=not slowflip end)
__gfx__
000000000666666066666660000006600660000011cccccccccccc11000000000000000000000000000000000500005000000000000000000000000000000000
000000006dddddd56dddddd500006dd56dd5000061111111111111150000000000000000000066d00d6600000050050050000005808088808080000010000001
007007006dddddd5055555550006ddd56ddd50006dddddd57dddddd500000000000000000006dd5005dd600000555500055555500800808080800000c111111c
000770006dddddd500000000006dddd56dddd5006dddddd57dddddd50000000000000000006dd550055dd60000500500005005000800888088800000cc1cc1cc
000770006dddddd50000000006ddddd56ddddd506dddddd57dddddd5000000000000000006dd55055055dd6000500500005005000000000000008008cc1cc1cc
007007006dddddd5000000006dddddd56dddddd56dddddd57dddddd5000000000000000008d5005555005d8000555500055555508080808080800000c111111c
000000006dddddd5000000006dddddd56dddddd56dddddd57dddddd5055555555555555000000000000000000050050050000005808080808880800810000001
00000000055555500000000005555550055555500555555005555550551111111111115500000000000000000500005000000000080800808080088000000000
06666660026262200000000002020220000000000121211006666660066666600000000004242440066000000000666000000000888088808880888088808880
6d5d56d52e2e28e2050502502e2e28e2050502501c1c17c16dddddd56dddddd50505025049494f946dd00000000006d500000000800080008000808080000800
65555dd562222ee20000055002222ee20000055021111cc16dddddd56dddddd500000550244449946dd50000000000d500000000888088808000880088800800
656d5555228e222500250000228e222000250000117c111205ddddd56ddddd500025000044f944426d000000000006d500000000008080008000888080000800
65dd5d5562ee2e250055050002ee2e200055050021cc1c12005dddd56dddd50000550500249949426d00000000066dd500000000888088808880808088800800
6655d5652822e265020050002822e200020050001711c1220005ddd56ddd5000020050004f4494226d550000000000d500000000000000000000000000000000
6dd55d552ee22e25055005002ee22e20055005001cc11c1200005dd56dd5000005500500499449426d0000000000000500000000000000000000000000000000
05555550022552500000000002200200000000000112212000000550055000000000000004422420055500000000555000000000000000000000000000000000
066666600000000001cccc10000000000202022005000050000000000aaaaaa00aaaaaa00000000022222222000080000550055000000000222222282e2e2ee2
6dddddd5000000006d1111d500050250282828e20555025055500005ab3b3b33a4444442050500502888888200086000005555000000000028222822e8e8e28e
6dd00505000000006dddddd50000055002222ee20055555002555550a34b4343a444444200500500282882820006d0000050050000000000222222222eeee88e
00500505000060006d1111d500250000228e2220002505000050050094434443a4444442050050002882288286d55680888888888888888822222282ee28eee2
00000000600060056dd11dd50055000002ee282000550500055555009444b442a4444442000500502882288208655d682222822228222822222222222e88e8e2
000000006606d0056dddddd50200000028228200025555000552555094443442a44444420050050028288282000d6000222222222222222222222222e2ee8e22
000000006ddddd056dd11dd5055005002ee22820055005005500025594444442a4444442050050502888888200068000222222822222228222222222e88ee8e2
0000000005555550055555500000000002200200050000500000000002222220022222200000000022222222000800002222222222222222222222222ee22e22
88888888888888888888855588888888888888888888855588888888888888888888888888888888888888888888888888888888888888880000000000000000
800e200887e7e7e8800e250583bba00880077008800000058dddddd8800c7008800aa0088e878e28802222088000000880e8220880f000080000000000000000
80e8e2088e76677880e8e205803bba088007c00880000555855555588001c008800ab00880e8e20880022008800660088e82222889a700080000000000000000
8e878e28876886e88e8785558003bba8877ccc18800000058111111881c71c788aabbb38800e2555800020088061cd088522222880a0af080000000000000000
82e88e288e68867882e885288003bba887ccc118800e25558000000881c71c788abbb338800000058000000880d1c508820022288009aa780000000000000000
802ee208877667e8802ee555803bba08800c100880e8e208800000088001c008800b300880000555800020088005500880000e288009aa780000000000000000
800220088e7e7e788002200883bba008800110088e878e2880000008800c70088003300880000005802000088000000880000e288000af080000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888555888888888888888888888888888888880000000000000000
000d1100000d1100000d1100000d1100000000000000000000000000000e2000000e20e200000000000000000000000000000000000000000000000000000000
00d1111000d1111000d1111000d11110000e2000000000000000000000e8220000e82e2200000000000000000000000000000000000000000000000000000000
0011111000111110001111100011111000e8e20000000000000000000e8222200e822e2200000000000000000000000000000000000000000000000000000000
033111000331110003311100033111000e878e2000000000000000006522222265222e2200000000000000000000000000000000000000000000000000000000
b6666666b6666666b6666666b666666602e88e20000e200000000000520022225020222000000000000000000000000000000000000000000000000000000000
6b663bb06b663bb06b663bb06b663bb0002ee20000e8e200000e200000000e220200022000000000000000000000000000000000000000000000000000000000
06500500060000500650050006033000000220000e878e2000e8e20000000e220000022000000000000000000000000000000000000000000000000000000000
00350350050000350035035000055000000000000eee2220eeee2222000520e20005200500000000000000000000000000000000000000000000000000000000
0000000000000000000d1100000d110000dd10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000d1111000d111100d11110000000000000aa000000000000000000000000000000000000000000000000000000000000000000000000000
000d11000000000000111110001111100111110000066000009aaf00000af000000f000000000000000000000000000000000000000000000000000000000000
00d11110000000000331110003311100031110000061cd0009a7aa700097a700009a700000000000000000000000000000000000000000000000000000000000
001111100000d110b6666666b6666666b033330000d1c50009aaaa70009aa700000a000000000000000000000000000000000000000000000000000000000000
03311130000d11116b663bb06b663bb00b333bb000055000009aaf00000af0000000000000000000000000000000000000000000000000000000000000000000
b033350b0331111106503500063003000030030000000000000aa000000000000000000000000000000000000000000000000000000000000000000000000000
0b30035b533333bb0500500000050050000500500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03bba000000c700000f0000005055050000ff0000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bba000001c00009a700000056650000aaa700006ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003bba001c71c7000a0af00056776500a9aaf70000fa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003bba001c71c700009aa70056776500a9aaf7000ddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bba000001c0000009aa700056650000aaa7000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
03bba000000c70000000af0005055050000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000006666666666666600000000000000000000000000000000000000000000000000000000000000000
7666666702200220000000000000000000000000000770006dddddddddddddd5000aa00000000000000000000000000000000000000000000000000000000000
760000670282282000000000003ba000000770000007c0000555555555555550000ab00000000000000000000000000000000000000000000000000000000000
7600006700288200001cc7000003ba0000700700077ccc1000011111111110000aabbb3000000000000000000000000000000000000000000000000000000000
7600006700288200001cc7000003ba000070676007ccc11000000000000000000abbb33000000000000000000000000000000000000000000000000000000000
760000670282282000000000003ba00000070600000c10000000000000000000000b300000000000000000000000000000000000000000000000000000000000
76666667022002200000000000000000000000000001100000000000000000000003300000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000b0b0000000005191b0b00000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10008300000000b0b0000000519191b0b00000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10400000301010101010222211111111100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10105060101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
00818181818181808080808080808080858384838089818180918080008080808080818083808081818001c0c0c081810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101111111010101010101010101010111110111010101010101010101010101010101010101010101010101010101011101110101010101010101010101011101110111010101010101010101010101010101010101
010000000000000b0b0000000000000b0b0000000000000b0b0000000000160101010117000016010117000016111111010a0000000016010117300000000901010000000000000101000000000000010100000000000001010030003000000b0b0000000000000b0b3a003a003a000b0b000000000016010101011700001601
010000000003010101010101010101010101010101010101010000000000000b0b00000000000001011d1e1f0019150b0b0000000000000b0b000030000000010100000000000001010000000000000101000000000000010100000000360001010432003203010b0b0000000000000b0b0311040000000b0b00000000000001
010000000317322020320000300032202032303900320011010000000000000b0b00000033000001010034000019150b0b0000000000000b0b00300000000001010000000000000101000000000000010100000000000001013600000000000101010101010101010100000000360001011119190000000b0b0000003d000001
010000030100002121003532000000212130003200000011010000000003010101010104000003010104000003111111010000030101010111112d2d04000001010000000000000101000000000000010100000000000001010101300030000b0b00000000000001010000000000000101000019000003010101010400000301
010c010111111111011111111111110101011111011a1b010101010c0c01010101010101050601010101050611111101010c0c012f2f2e2e2e2f2e2f110c0c0101010101010101010101010101010101010101010101010101010111011101010101010c0c010101010c0c0c0c0c0c01010c0c11110101010101010105060101
010c010101010101010101010111111111110101111a1b110101010c0c01011101010101010101010101010101010101010c0c012f2e2e2f2e2e2f2e010c0c1101010101010101010101010101010101010101010101010101011101110101010101010c0c010101010c0c0c0c0c0c01010c0c01010101010101010101010101
010000000000000b0b00300000000020200011011100001101131300000000010117000016010101010a000000000901010000012e2e2f2f2f2f2e2f1100001111110111111111010100000000003c01011700000000160101173913391320010100000000000001010000000000000101000000000000010100000000000001
0100000000160101010000000000002121000016010000110113130000000011010000000000000b0b0000000000000b0b0000012e2f2e2e2e2f2e2f1100000b0b0000151513000b0b00000000001601010000000000000101000039003900010100000000000001010000000000000101000000000000010100000000000001
01000000000000011101041330000001013200001300000b0b13000000001311010034000000000b0b0000000000000b0b0000012e2e2e2f2f2e2e2f1100000b0b0013151500000b0b000000000000000b0000000000000b0b0000000000000b0b0016222217000b0b0000000000000b0b0000000000000b0b00000000000001
01220000000000011101111313320311010432131313000b0b1300032201111101040000030101010100000000000001010122012e2e2e2e2e2e2f2e01220111110111111111011111040000000000000b0000000000000b0b0000000000000b0b0000000000000b0b0000000000000b0b0000000000000b0b00000000000001
01010101010c0c0101111111111101111111110101110101010101010111110101010506010101010101010c0c010101010101012f2e2e2e2e2e2e2e01011101010101010101010101010101010101010101010c0c01010101010101010101010101010c0c0101010101010101010101010101010101010101010101010c0c01
01010101010c0c0101010101010101010101010f0f010101010101010101010101010101011101010101010c0c0101010101010101012e2e0101010101010101111111011111011101010101010101010101010c0c01010101010101010101010101010c0c0101010101010101010101111111111111111101010101010c0c01
010030000100000101320039000032010117000000001601011101111117000b0b0000000000000b0b0000000000000b0b00000009012e2e011700001617002324131313133013110101010101010101010000000000000b0b0000000000000b0b000000000000010101011700001601110000000000000b1900000000000001
013000000100000101040000000003010100003400000001010a13133000000b0b0000000030000b0b0000000000000b0b00000000012e2f0100000000000001111332131313130b0b00000000001601010000000000000b0b0000000000000b0b0000000000000b0b00000000000001110000000000000b1936000000000001
010000000100000b0b1601010101170b0b0000000000000b0b00130000000301010111151511010101000001220000010101040000012e2f01003b0000000301013013003213130b0b0000000000000b0b000000000003010100350035360001010016222217000b0b0000003400000111360000000000111100000000360011
010000300122000b0b0000000000000b0b0003050604000b0b00133013030101010101000001010101012d2c2c2d01010101010000012e2e01040000030101011113131313131311010101010400000b0b0003222201010101211335133503010100000000000001010101040000030111110000003600111113000000001301
01010101010101010101010101010101010101010101010101010111110101010101010c0c01010101010101010101010101010c0c012f2e0101050601010101110c0c0c0c0c0c110101010101010101010101010101010101010111011101010101010c0c01010101010101050601011111112d2d2d2d111111110c0c011111
01110101011111011101010101010101010111011111110101011101111101010101010c0c01010101010101010101010101010c0c012e2e0101010101010101010c0c0c0c0c0c01112e2e2e2e2e2e11010101010101010101010101010101010101010c0c010101010101010101010101010101010101010101010c0c010101
010a390000000011110000000000000b0b0039000000000b0b0030000030000b0b0000000000000b0b000000000009010100000000012f2e0100000000000001010000000000000101112f112f112f01013c000000003c01013c0000000000010100000000000001010a00000000160101170000000009010100000000000001
0100000000000001110000000000000b0b0000000000000b0b0000000000000b0b0000000000000b0b0000000000000b0b00000000012e2e0100000000000001010000000000000101003a003a003a011111000000001111111100000000000b0b0000000000000b0b00000000000001010000000000000b0b00000000000001
010000000000000b0b0011110101011101000036000000010100003600000001112d112222112d11010011010000000b0b00000122112e2f0100000000000001010001010101000b0b0000000000000b0b0000000000000b0b0000000000000b0b0003222204000b0b0000000000000b0b0000000000000b0b00000000000001
013500000000000b0b0015130000111101012d2d2d2d2d01112d2d2d2d2d11112e2e2f2f2f2f2f2f112d2c1111012d0111112d0111012e2e010000000000000101000b00000b000b0b0000000000000b0b0000000000000b0b000000030101010101010101010101010400000000000b0b000000000003010101012222010101
0101010c0c11010111111101010c0101012e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2f2f012f2f012f2e2f2f2e2e2f2e2e2e2e2e2f2e2e2e2e2e010101010101010101012c2d2d2c01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010c0c01010101010101010c0101010101010101010101110111011111111111112f2f11111101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101170000090101010000000000090101000000000000010117000016011101110000003100001101010101010101010101011700001601010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001
010100000000000b0b0000000000000b0b0000000001000b0b000000000016111100000000000011011700000000000b0b00000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001
010104000000000b0b0000000000000b0b0001000001000b0b0034000000000b0b0000000000000b0b0000000000000b0b00000037000001010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001
0101010101010101010000003522010101000b36000b0001010400000304000b0b0000000000000b0b000003010101010101010400000301010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001
0101010101010101011124241101010101012c2d2d2c2d01010105060111111111112d11112d111101010101010101010101010105060101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101011123231101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0117000016010101010100000111111101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001010000000000000101000000000000010100000000000001
__sfx__
0004000012731197211f7112c7012d701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
010400000712307113071030010300103001030712307113001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103
0104000018033110230d0130700305003030030200300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
001000060712307123001030110300103001030010300103001030010300103001030010300103011030010301103011030010302103021030210302103021030310303103031030210302103021030110300103
000400003b0533b0532a016230161c0162e0051900300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
010700002c0352c0252c0152c0052c005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000800000000114311143111431114311003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100000
000400001963419624196141960400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400000
010800000000024321243112732127311003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301
0104000018633116230d6130760305603036030260300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
000400003c0562e0462c036130260e016010060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006
010c00001745317444174341742417414174431743417424174141741417433174241741417404174141742317414174141740417414004041741417404174040040400404004040040400404004040040400404
00040000294562c44632436334260e406014060040600406004060040600406004060040600406004060040600406004060040600406004060040600406004060040600406004060040600406004060040600406
00040000000000000000000000003545738447374372f427294171d4072f4072a407234071e407174071640700407004070040700407004070040700407004070040700407004070040700407004070040700407
01050000160551a0451f035260252e015360050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010600000e053090000a0500a0400a0300a0200a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000000411054211143116441154410f4310942103411084013940139401004013940138401384010040100401004010040100401004010040100401004010040100401004010040100401004010040100401
010c00002c5532c5442c5342c5242c5142c5432c5342c5242c5142c5142c5332c5242c5142c5042c5142c5232c5142c5142c5042c514155042c5142c5042c5040050400504005040050400504005040050400504
0004000039633376153563333615316332f6150060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
0108000034457374473d4373e42734447374373d4273e41734437374273d4173e41734427374173d4173e41700407004070040700407004070040700407004070040700407004070040700407004070040700407
0110000000000120111201112021120211203112031120211202112011120110d0010d0010d0010d0010d0010d0010e0110e0110e0210e0210e0310e0310e0210e0210e0110e0110000100001000010000100001
011000001302313023130530100313023130231305300003130231302313053130231302313053130031300313023130231305302003130231302313053020031302313023130531302313023130531302313023
001000001302313023136530100313023130231365300003130231302313653130231362313053136231300313023130231365313653130231302313653020031365313023136531302313653130531365313023
011000001c0551a05518055210551d0551c0551c0351c015210551f0551d055260552205521055210352101512055100550e05517055130551205512035120152805526055240552d05529055280552803528015
0110000011552115521155211552105521055210552105520e5520e5520e5520e5521155211552115521155200502005020050200502005020050200502005020050200502005020050200502005020050200502
011000001155211552115521155210552105521055210552155521555215552155521155211552115521155200502005020050200502005020050200502005020050200502005020050200502005020050200502
011000001155211552115521155210552105521055210552155521755215552175521855217552185521755200502005020050200502005020050200502005020050200502005020050200502005020050200502
011000003405532055300553704535045340453403532035300353902539025390253901539015390151a00512005100050e00517005130051200512005120052800526005240052d00529005280052800528005
010800003965337641356313362131611316113161100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
010800002535326353293532c3532f353323533835338343383333832338313003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303
010800003c71136701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010000000000
000800003032331333343433535331353293531d3530e343043330032300313003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303
010a00000561407624086340e644156541e6642567417604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604
010c00002c5532c5442c5342c5242c5142c5432c5342c5242c5142c5142c5332c5242c5142c5042c5142c5232c5142c5142c5042c514155042c5142c5042c5040050400504005040050400504005040050400504
00080000276532866226652236521d6421a6421963215632106220762205612036120060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602
010c0000276232863226652276532866226652236521d6421a6421963215632106220762205612036120261202612026120161201615006020060200602006020060200602006020060200602006020060200602
0004000039633376153560333605316032f6050060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
00040000324223743238442344523545238442374322f422294121d4022f4022a402234021e402174021640200402004020040200402004020040200402004020040200402004020040200402004020040200402
010800001275319741127531974112753197411f7311f701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
0008000012753197411f7313640038400324002c40124701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
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
01 15 42 43 44
00 16 42 43 44
01 16 42 18 44
00 16 42 19 44
00 16 42 18 44
00 16 42 1a 44
02 16 42 43 44
00 16 42 17 44
02 16 42 1b 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
