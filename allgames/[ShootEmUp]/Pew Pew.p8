pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- pew-pew (earth-defender) v1.8 
-- created by jason rowe
cartdata("pewpew_earth_defender")
--high-scores
hsnew=false
hsidx=1
hsnum=1
hs={}
for i=1,10 do
 local nid=dget(2*i-2)
 local scr=dget(2*i-1)
 if nid == 0 then
  nid=0102.03
 end
 if scr == 0 then
  scr=(11-i)*10
 end
 add(hs,{
  name=nid,
  score=scr
 })
end

function _init()
 -- display properties
 found=false -- is the earth known?
 screen = {
  size=1024, --map size
  x = 512-64, --ship start pos
  y = 512-64,
  bx = 40,    --boundary scroll
  by = 128-40,
  t=0,        --elapsed time
  nstars=64, --number of bkg stars
  ebarpx=106, --energybar xpos
  ebarpy=3,    --  ypos
  ebarw=20,    --  width
  ebarh=3,     --  height
  pebarpx=80, --planet energybar xpos
  pebarpy=3,   --  ypos
  pebarw=20,   --  width
  pebarh=3,    --  height
  mmpx=100,   --mimi-map x-pos
  mmpy=100,    --mimi-map y-pos
  mms=22,      --mini-map size
  mmsc=0,      --mini-map scale (calculated below)
  lewarn=0.2, --when energy fraction below, set warning
  cpulimit=0.95, -- if cpuload exceeds, stop spawn/ebullets
  version=1.8 --game version
 }
 screen.mmsc=screen.size/screen.mms
 --menu properties
 menu = {
  pos = 1,
  cols = {p0=10,p1=8,p2=8}
 }
 -- enemy properties
 enp = {
  gbr=500,  -- fighter generation rate higher -> slower generation
  bgr=2000, -- battle station generation rate
  bfr=20,   -- base fire rate
  lfr=100,  -- fighter fire rate
  fspd=0.5, -- fighter speed
  sspd=0.1, -- battle station speed
  llt=5,    -- laser-lifetime
  lrg=40,   -- laser range
  bsp=2,    -- enemy bullet speed
  bdg=8,    -- bullet damage
  cdg=10,   -- collision damage
  ldg=3,     -- laser damage
  nfight=0,  -- number of fighters
  nfightmax=75, --max number of fighters
  nstat=0,   -- number of stations 
  nstatmax=25, --max number of stations
  nbatt=0,   -- number of battle stations
  nbattmax=50, -- max number of battle stations
  nstatkill=0, -- number of stations killed 
  level=1,    -- difficulty level
  lv1k=10, -- kills to get past level-1
  lv2k=20  -- kills to get past level-2
 }
 -- ship properties
 ship = {
  x  = screen.x+60, --map x-pos
  y  = screen.y+60, --map y-pos
  sx = 60,  --screen x-pos
  sy = 60,  --screen y-pos
  dx = 0,   --motion x
  dy = 0,   --motion y
  sp = 2,   --ship sprite 
  spd = 1*1.4142,  --ship speed 
  box = {x1=0,y1=0,x2=7,y2=7},
  xc = 0, --sprite x-center (calc below)
  yc = 0, --sprite y-center 
  p=0,        --game points
  enermax=300,--maxhealth
  energy=300, --health
  enerfra=1.0,--health fraction
  lowen=false,--low energy flag
  t=0,        --ship timer
  imm=false,  --invincible
  bgs=3       --# of bigshots
 }
 ship.xc=(ship.box.x1+ship.box.x2)/2
 ship.yc=(ship.box.y1+ship.box.y2)/2
 --home planet
 earth={
  x = screen.x+80,
  y = screen.y+64,
  sx = 80,
  sy = 64,
  sp = {s1=0,s2=0,s3=2,s4=2},
  box = {x1=1,y1=1,x2=16,y2=16},
  spdead = {s1=2,s2=0,s3=4,s4=2},
  xc = 8,
  yc = 8,
  enermax=800,
  energy=800,
  enerfra=1.0,--health fraction
  lowen=false, --low energy flag
  rfield=30,
  egr=0.5, --energy regen rate
  found=false 
 }
 --boss
 bossspr={
  {0,2,2,4}, --boss sprites
  {2,2,4,4},
  {4,2,6,4}
 }
 bullets={}  --good bullets
 ebullets={} --bad bullets
 biggun={}   --big bad weapon
 lasers={}   --laser beams
 bfire = {   
  dx = 1,
  dy = 1
 }
 enemies={}  --bad guys
 explosions={} 
 stars = {}  --background stars
 for i=1,screen.nstars do
  add(stars,{
   sx=rnd(128),
   sy=rnd(128),
   s=rnd(2)+1
  })
 end
 start()
end

function levelup(level)
 if level==1 then
  enp.gbr=1000
  enp.bgr=4000
  enp.bsp=2
  enp.fspd=0.5
  enp.sspd=0.1
 elseif level==2 then
  enp.gbr=500
  enp.bgr=2900
  enp.bsp=3
  enp.fspd=0.7
  enp.sspd=0.15
 elseif level==3 then
  enp.gbr=300
  enp.bgr=1000
  enp.bsp=3
  enp.fspd=0.9
  enp.sspd=0.3
 end
end

--opening screen
function update_opening()
 screen.t+=0.1

 if enp.nbatt+enp.nstat <= 0 then
  respawn()
 end

 if enp.nfight < enp.nfightmax/2 then
  for i=1,enp.nfightmax/2 do 
   local bx=rnd(screen.size)
   local by=rnd(screen.size)
   spawnfighter(bx,by)
  end
 end

 for e in all(enemies) do

  e.x+=e.dx
  e.y+=e.dy
  
   --keep enemy on map
  if e.x < 0 then 
   e.x+=screen.size
  end
  if e.x > screen.size-1 then
   e.x-=screen.size
  end
  if e.y < 0 then 
   e.y+=screen.size
  end
  if e.y > screen.size-1 then
   e.y-=screen.size
  end
  --update screen pos with wrap
  e.sx=e.x-screen.x
  local stest = e.sx-screen.size
  if stest > 0 then
   e.sx=stest
  end
  stest = e.sx+screen.size
  if stest < 128 then
  e.sx=stest
  end
  e.sy=e.y-screen.y
  stest = e.sy-screen.size
  if stest > 0 then
   e.sy=stest
  end
  stest = e.sy+screen.size
  if stest < 128 then
   e.sy=stest
  end
 
 -- determine if enemy in view
  if e.sx < 128 and 
   e.sx > 0 and 
   e.sy < 128 and
   e.sy > 0 then
   if abs(e.sx-ship.sx) < enp.lrg and
      abs(e.sy-ship.sy) < enp.lrg then
    e.hot=2
   else 
    e.hot=1
   end
  else
   e.hot=0
  end
 
 end
 
 if btnp(2) then
  menu.pos-=1
 end
 if btnp(3) then
  menu.pos+=1
 end
 menu.pos=min(2,menu.pos)
 menu.pos=max(0,menu.pos)
 
 if menu.pos==0 then
  menu.cols.p0=10 
  menu.cols.p1=8
  menu.cols.p2=8
 elseif menu.pos==1 then
  menu.cols.p0=8 
  menu.cols.p1=10
  menu.cols.p2=8
 else
  menu.cols.p0=8 
  menu.cols.p1=8
  menu.cols.p2=10
 end
  
 if btnp(4) then
  enp.level=1+menu.pos
  levelup(enp.level)
  screen.t=0
  game_start() 
 end
 
 if screen.t > 30 then
  highscores()
 end
 
end

function draw_opening()
 cls()
 draw_game()
 --print(screen.t,50,25,1)
 print("earth defender",36,35,8+screen.t%3)
 print(screen.version,58,42,8+screen.t%3)
 print("     easy     ",36,72,menu.cols.p0)
 print("    medium    ",36,82,menu.cols.p1)
 print("     hard     ",36,92,menu.cols.p2)
 print("hit fire to start",30,105,8+screen.t%3)
end

function start()
 screen.t=0
 _update = update_opening
 _draw = draw_opening
end

function game_start()
 _update = update_game
 _draw = draw_game
end

function highscores()
 screen.t=0
 _update = update_highscores
 _draw = draw_highscores
end
 
function update_highscores()
 screen.t+=0.1
 if screen.t > 30 or btnp(4) then
  start()
 end
end

function draw_highscores()
 cls()
 print('high scores',42,5,8+screen.t%3)
 local i=0
 for h in all(hs) do
  i+=1
  local nchar = getnchar(h.name,1)
  local char=numtochar(nchar)
  print(char,40,10+i*10,1+(i+screen.t)%10)
  local nchar = getnchar(h.name,2)
  local char=numtochar(nchar)
  print(char,44,10+i*10,1+(i+screen.t)%10)
  local nchar = getnchar(h.name,3)
  local char=numtochar(nchar)
  print(char,48,10+i*10,1+(i+screen.t)%10)
  print(h.score,75,10+i*10,1+(i+screen.t)%10)
 end
end

function getnchar(hname,i)
 local n=1
 if i < 3 then
  n=flr((hname-10^(6-2*i)*flr(hname/10^(6-2*i)))/10^(4-2*i))
 else
  n=flr(100*(hname+0.001-flr(hname)))
 end
 return n
end

function numtochar(v)
  local chars = 'abcdefghijklmnopqrstuvwxyz'
  return sub(chars, v, v)
end

function youwin()
 check_hiscores()
 screen.t=0
 _update = update_win
 _draw = draw_win
end

function check_hiscores()
 --check high-scores
 local i=0
 local loop=true
 for i=1,10 do
  if ship.p > hs[i].score and loop then
   hsnew=true
   hsidx=i+0
   loop=false
  end
 end
 --update high-score
 if hsnew then
  --move other scores down
  local j=0
  for j=#hs,hsidx+1,-1 do
   hs[j].name=hs[j-1].name
   hs[j].score=hs[j-1].score
  end
  hs[hsidx].score=ship.p
 end
end

function draw_win()
 cls()
  --display planet
 map(earth.sp.s1,earth.sp.s2,
     56,35,
     earth.sp.s3,earth.sp.s4)
 print("you win!",50,10,8+screen.t%3)
 print("the earth is safe!",30,20,8+screen.t%3)
 print("your score:", 30, 60,8+screen.t%3)
 print(ship.p,85,60,8+screen.t%3)
 if hsnew then
  display_hiscore()
 end
end

function display_hiscore()
  print("new high-score!",35,70,1+(5*screen.t)%10)
  print("#",15,80,10)
  print(hsidx,25,80,10)
  local i
  for i=1,3 do
   local nchar = getnchar(hs[hsidx].name,i)
   local char=numtochar(nchar)
   if i==hsnum then
    print(char,36+i*4,80,10+screen.t%2)
   else
    print(char,36+i*4,80,10)
   end
  end
  print(hs[hsidx].score,75,80,10)
  rect(30,77,98,87,14)
  --print(hs[hsidx].name,75,90,10)
  --print(hsnum,40,110,10)
  print('  ”        ',42,90,6)
  print('‹  ‘  Ž—',42,95,6)
  print('  ƒ        ',42,100,6)
  print('use arrows to enter name',18,108,6)
  print('     hit — to save     ',18,115,6)
end

function update_win()
 screen.t+=0.1

 if hsnew then
  hiscore_input()
 else
  if screen.t > 30 then 
   _init() 
  end
 end
 
 if btnp(5) and screen.t > 30 then 
  screen.t=0
  _init() 
 end
end

function hiscore_input()
 local nchar={}
 add(nchar,getnchar(hs[hsidx].name,1))
 add(nchar,getnchar(hs[hsidx].name,2))
 add(nchar,getnchar(hs[hsidx].name,3))
 if btnp(0) then
  hsnum-=1
 elseif btnp(1) then
  hsnum+=1
 elseif btnp(2) then
  nchar[hsnum]+=1
 elseif btnp(3) then
  nchar[hsnum]-=1
 elseif btnp(4) then
  hsnum+=1
 end
 if btnp(5) and screen.t > 5 then
  local i
  for i=1,10 do
   dset(2*i-2,hs[i].name)
   dset(2*i-1,hs[i].score)
  end
  hsnew=false
  screen.t=31.0
 end
 nchar[hsnum]=min(26,nchar[hsnum])
 nchar[hsnum]=max(1,nchar[hsnum])
 hsnum=min(3,hsnum)
 hsnum=max(1,hsnum)
 hs[hsidx].name=flr(100*nchar[1])+flr(nchar[2])+(nchar[3]+0.001)/100
end

function game_over()
 check_hiscores()
 screen.t=0
 _update = update_over
 _draw = draw_over
end

function draw_over()
 cls()
 map(earth.spdead.s1,earth.spdead.s2,
     56,26,
     earth.spdead.s3,earth.spdead.s4)
 print("game over",45,5,8+screen.t%3)
 print("your planet is dead",25,15,8)
 print("   way to go ...   ",30,50,8)
 print("your score:", 30, 60,8+screen.t%3)
 print(ship.p,80,60,8+screen.t%3)
 if hsnew then
  display_hiscore()
 end
end

function update_over()
 screen.t+=0.1
 if hsnew then
  hiscore_input()
 else
  if screen.t > 30 then 
   _init() 
  end
 end
 -- if screen.t > 100 then _init() end
 if btnp(5) and screen.t > 20 then 
  screen.t=0
  _init() 
 end
end

function respawn()
 levelup(1) -- reset level
 local n = enp.nstatmax
 local i
 for i=1,n do
  local dist = 0
  local ex = 0
  local ey = 0 
  while dist < 50 do
   ex=rnd(screen.size)
   ey=rnd(screen.size)
   local dist1 = abs(ex-ship.x)
   local dist2 = abs(ey-ship.y)
   dist=max(dist1,dist2)
  end
  local ety=flr(rnd(2))
  addenemy(ex,ey,0)
 end
 for i=1,n do
  local dist = 0
  local ex = 0
  local ey = 0 
  while dist < 50 do
   ex=rnd(screen.size)
   ey=rnd(screen.size)
   local dist1 = abs(ex-ship.x)
   local dist2 = abs(ey-ship.y)
   dist=max(dist1,dist2)
  end
  local ety=flr(rnd(2))
  addenemy(ex,ey,1)
 end
end

function addenemy(ex,ey,ety)
 if stat(1) < screen.cpulimit then
  if ety==0 then
   esp=4
   ebox={x1=-1,y1=0,x2=7,y2=7}
   epoint=100
   edx=0
   edy=0
   espd=0.0
   enp.nstat+=1
  elseif ety==1 then
   esp=20
   ebox={x1=-1,y1=1,x2=7,y2=7}
   epoint=5
   edx=0
   edy=0
   espd=enp.sspd
   enp.nbatt+=1
  else 
   esp=36
   ebox={x1=0,y1=2,x2=5,y2=5}
   epoint=1
   local sprnd=rnd(1)
   edx=cos(sprnd)
   edy=sin(sprnd)
   espd=enp.fspd
   enp.nfight+=1
  end
  local exc=(ebox.x1+ebox.x2)/2
  local eyc=(ebox.y1+ebox.y2)/2
  add(enemies, {
   x=ex,
   y=ey,
   sx=0,
   sy=0,
   dx=edx,
   dy=edy,
   spd=espd,
   sp=esp,
   etype=ety,
   box=ebox,
   xc=exc,
   yc=eyc,
   p=epoint,
   hot=0,
   lt=0  --laser-on time
  })  
 end
end

function spawnfighter(bx,by)
 if enp.nfight < enp.nfightmax then 
  addenemy(bx,by,2)
 end
end

function spawnbatt(bx,by)
 if enp.nbatt < enp.nbattmax then 
  addenemy(bx,by,1)
 end
end

function spawnstat(bx,by)
 if enp.nstat < enp.nstatmax then 
  addenemy(bx,by,0)
 end
end

function explode(x,y,xc,yc)
 if stat(1) < screen.cpulimit then
  add(explosions,{
   x=x+xc,
   y=y+yc,
   sx=0,
   sy=0,
   t=0
  })
 end
end

function laserfire(esx,esy,ssx,ssy)
 local l = {
  sx1=esx,
  sx2=ssx,
  sy1=esy,
  sy2=ssy
 }
 add(lasers,l)
 sfx(1)
end

function fire()
 local b = {
  sp=18,
  sx=ship.sx,
  sy=ship.sy,
  dx=3*bfire.dx,
  dy=3*bfire.dy,
  box = {x1=3,y1=3,x2=4,y2=4}
 }
 add(bullets,b)
 sfx(0)
end

function firebiggun()
 ship.bgs-=1
 local bg = {
  t=0,
  tmax=64,
  x=ship.x+ship.xc,
  y=ship.y+ship.yc,
  sx=0,
  sy=0,
  r=1,
  dr=2
 }
 add(biggun,bg)
end

function enemyfire(ex,ey,edx,edy)
 if stat(1) < screen.cpulimit then
  local norm = sqrt(edx*edx+edy*edy)
  local b = {
   sp=52,
   x=ex,
   y=ey,
   sx=0,
   sy=0,
   dx=edx/norm*enp.bsp,
   dy=edy/norm*enp.bsp,
   box = {x1=3,y1=3,x2=4,y2=4}
  }
  add(ebullets,b)
  sfx(2)
 end
end

function abs_box(s)
 local box = {}
 box.x1 = s.box.x1 + s.sx
 box.y1 = s.box.y1 + s.sy
 box.x2 = s.box.x2 + s.sx
 box.y2 = s.box.y2 + s.sy
 return box
end

function coll(a,b)
  local box_a = abs_box(a)
  local box_b = abs_box(b)
  if box_a.x1 > box_b.x2 or
     box_a.y1 > box_b.y2 or
     box_b.x1 > box_a.x2 or
     box_b.y1 > box_a.y2 then
     return false
  end
  return true
end

function update_game()

 --don't let counter overflow
 if screen.t > 32000 then screen.t=0 end

 if enp.nstatkill >= enp.lv1k and enp.level < 2 then
  enp.level=2
  levelup(enp.level)
 elseif enp.nstatkill >= enp.lv2k and enp.level < 3 then
  enp.level=3
  levelup(enp.level)
 end

 --update earth knowledge
 earth.found=false
 if earth.energy < earth.enermax then
  earth.energy+=earth.egr
 end
 
 --ship position and status
 if ship.imm then
  ship.t += 1
  if ship.t >30 then
   ship.imm = false
   ship.t = 0
  end
 end

 --explosions
 for ex in all(explosions) do
  ex.t+=1
  if ex.t==13 then
   del(explosions, ex)
  end
 end
 
 --start over  if no enemies left
 if enp.nbatt+enp.nstat <= 0 then
  --respawn()
  youwin()
 end

 --clear all previous lasers
 for l in all(lasers) do
  del(lasers,l)
 end

 --big gun
 for bg in all(biggun) do
  bg.sx=bg.x-screen.x
  local stest = bg.sx-screen.size
  if stest > 0 then
   bg.sx=stest
  end
  stest = bg.sx+screen.size
  if stest < 128 then
   bg.sx=stest
  end
  
  bg.sy=bg.y-screen.y
  stest = bg.sy-screen.size
  if stest > 0 then
   bg.sy=stest
  end
  stest = bg.sy+screen.size
  if stest < 128 then
   bg.sy=stest
  end

  bg.r+=bg.dr
  bg.t=bg.t+1
  for b in all(ebullets) do
   local d=sqrt((bg.sx-b.sx)^2+(bg.sy-b.sy)^2)
   if d <= bg.r then
    del(ebullets,b)
   end
  end
  for e in all(enemies) do
   if abs(bg.sx-e.sx)<=bg.r and 
      abs(bg.sy-e.sy)<=bg.r then
    local d=sqrt((bg.sx-e.sx)^2+(bg.sy-e.sy)^2)
    if d <= bg.r then
     if e.etype == 0 then
      enp.nstat-=1
      enp.nstatkill+=1
     elseif e.etype == 1 then
      enp.nbatt-=1
     else
      enp.nfight-=1
     end
     del(enemies,e)
    end
   end
  end
  if bg.t > bg.tmax then
   del(biggun,bg)
  end
 end

 -- enemy bullets
 for b in all(ebullets) do
  b.x+=b.dx
  b.y+=b.dy

  b.sx=b.x-screen.x
  local stest = b.sx-screen.size
  if stest > 0 then
   b.sx=stest
  end
  stest = b.sx+screen.size
  if stest < 128 then
   b.sx=stest
  end
  
  b.sy=b.y-screen.y
  stest = b.sy-screen.size
  if stest > 0 then
   b.sy=stest
  end
  stest = b.sy+screen.size
  if stest < 128 then
   b.sy=stest
  end

  if b.sx < 0 or b.sx > 128 or
   b.sy < 0 or b.sy > 128 then
   del(ebullets,b)
  end
  if coll(ship,b) and not ship.imm then
   --ship.imm = true
   ship.energy -= enp.bdg
   del(ebullets,b)
   if ship.energy <= 0 then
    game_over()
   end
  end
  if coll(earth,b) then
   earth.energy -= enp.bdg
   explode(b.x,b.y,3,3)
   del(ebullets,b)
   if earth.energy <= 0 then
    game_over()
   end
  end

 end
 
 --friendly bullets
 for b in all(bullets) do
  b.sx+=b.dx
  b.sy+=b.dy
    
  if b.sx < 0 or b.sx > 128 or
   b.sy < 0 or b.sy > 128 then
   del(bullets,b)
  end
  
  for e in all(enemies) do
   if coll(b,e) then
    if e.etype == 0 then
     enp.nstat-=1
     enp.nstatkill+=1
    elseif e.etype == 1 then
     enp.nbatt-=1
    else
     enp.nfight-=1
    end
    del(enemies,e)
    del(bullets,b)
    ship.p += e.p*enp.level
    explode(e.x,e.y,e.xc,e.yc)
   end
  end  
 end
 
 --ship and screen movement
 ship.dx = 0
 ship.dy = 0
 if btn(0) then ship.dx-=ship.spd end
 if btn(1) then ship.dx+=ship.spd end
 if btn(2) then ship.dy-=ship.spd end
 if btn(3) then ship.dy+=ship.spd end
  -- reduce diagonal to unit-motion
 if ship.dx!=0 and ship.dy!=0 then
  ship.dx=ship.dx*0.7071
  ship.dy=ship.dy*0.7071
 end
 ship.x+=ship.dx
 ship.y+=ship.dy
 
 local shipsx=ship.sx+ship.dx
 local shipsy=ship.sy+ship.dy
 if shipsx > screen.bx and shipsx < screen.by then
  ship.sx=shipsx
 else
  screen.x+=ship.dx
  --background stars
  for st in all(stars) do
   st.sx-=ship.dx
   if st.sx < 0 then st.sx=128 end
   if st.sx > 128 then st.sx=0 end
  end
 end
 if shipsy > screen.bx and shipsy < screen.by then
  ship.sy=shipsy
 else
  screen.y+=ship.dy
  --background stars
  for st in all(stars) do
   st.sy-=ship.dy
   if st.sy < 0 then st.sy=128 end
   if st.sy > 128 then st.sy=0 end
  end
 end
 
 earth.sx=earth.x-screen.x
 earth.sy=earth.y-screen.y
 
 if ship.x < 0 then 
  ship.x+=screen.size
  screen.x+=screen.size 
 end
 if ship.x > screen.size-1 then
  ship.x-=screen.size
  screen.x-=screen.size 
 end
 if ship.y < 0 then 
  ship.y+=screen.size
  screen.y+=screen.size 
 end
 if ship.y > screen.size-1 then
  ship.y-=screen.size
  screen.y-=screen.size 
 end
 if ship.dx< 0 and ship.dy> 0 then ship.sp=33 end
 if ship.dx==0 and ship.dy> 0 then ship.sp=34 end
 if ship.dx> 0 and ship.dy> 0 then ship.sp=35 end
 if ship.dx< 0 and ship.dy==0 then ship.sp=17 end
 if ship.dx> 0 and ship.dy==0 then ship.sp=19 end
 if ship.dx< 0 and ship.dy< 0 then ship.sp=1 end
 if ship.dx==0 and ship.dy< 0 then ship.sp=2 end
 if ship.dx> 0 and ship.dy< 0 then ship.sp=3 end
 if ship.dx!=0 or ship.dy!=0 then 
  bfire.dx=ship.dx
  bfire.dy=ship.dy
 end

 --if inside earth shield add energy
 local xdist=ship.sx-earth.sx
 local ydist=ship.sy-earth.sy
 if abs(xdist) < earth.rfield and
    abs(ydist) < earth.rfield then
  local dist=sqrt(xdist*xdist+ydist*ydist)
  if dist <= earth.rfield then
   if ship.energy < ship.enermax then ship.energy+=earth.egr end
  end
 end   

 --enemy movement and attacks 
 for e in all(enemies) do
 
  --enemy generation
  if e.etype == 0 then
   local genbad = flr(rnd(enp.gbr))
   if genbad < 2 then
    spawnfighter(e.x,e.y)
   end
   genbad = flr(rnd(enp.bgr))
   if genbad < 2 then
    local rang=rnd(1)
    spawnbatt(e.x+2*e.box.x2*cos(rang),e.y+2*e.box.y2*sin(rang))
   end
  end
  
  --enemy movement
   --if earth found, move station
  if e.etype == 1 and found then
   local ldx = earth.x-e.x+e.xc
   local ldy = earth.y-e.y+e.yc
   local aldx = abs(ldx)
   local aldy = abs(ldy)
   local edist = 61
   if aldx < 64 and aldy < 64 then
    edist=sqrt(ldx*ldx+ldy*ldy)
   end
   if aldx > 1 and edist > earth.rfield then e.x+=ldx/(aldx+aldy)*e.spd end
   if aldy > 1 and edist > earth.rfield then e.y+=ldy/(aldx+aldy)*e.spd end
   -- if planet in sight.. fire
   if edist < 60 then

    local rfire=flr(rnd(enp.bfr))
    if rfire < 2 then
     if e.hot > 0 then
      enemyfire(e.x,e.y,ldx,ldy)
     else
      earth.energy-=enp.bdg*2
     end
     if earth.energy <= 0 then
      game_over()
     end
    end
    
   end
  end 
  
  if e.etype == 2 then
   if e.hot > 0 then
    local ldx = ship.sx-e.sx
    local ldy = ship.sy-e.sy
    if abs(ldx) < 100 and abs(ldy) < 100 then
     local norm=sqrt(ldx*ldx+ldy*ldy)
     if norm > 0 then
      e.x+=ldx/norm*e.spd
      e.y+=ldy/norm*e.spd
     end
    else
      e.x+=ldx/abs(ldx)*e.spd
      e.y+=ldy/abs(ldy)*e.spd
    end
   elseif e.hot == 0 then
    local mrnd=rnd(1)
    if mrnd < 0.7 then
     e.x+=e.dx*e.spd
     e.y+=e.dy*e.spd
    else
     local ldx = earth.x-e.x+e.xc
     local ldy = earth.y-e.y+e.yc
     local aldx = abs(ldx)
     local aldy = abs(ldy)
     if aldx > 1 then e.x+=ldx/aldx*e.spd end
     if aldy > 1 then e.y+=ldy/aldy*e.spd end
    end
   elseif e.hot == -1 then
    local ldx = earth.x-e.x+e.xc
    local ldy = earth.y-e.y+e.yc
    dist=sqrt(ldx*ldx+ldy*ldy)
    if dist > earth.rfield then
     e.x+=ldx/dist
     e.y+=ldy/dist
    end
   end   
  end 
  --keep enemy on map
  if e.x < 0 then 
   e.x+=screen.size
  end
  if e.x > screen.size-1 then
   e.x-=screen.size
  end
  if e.y < 0 then 
   e.y+=screen.size
  end
  if e.y > screen.size-1 then
   e.y-=screen.size
  end
  --update screen pos with wrap
  e.sx=e.x-screen.x
  local stest = e.sx-screen.size
  if stest > 0 then
   e.sx=stest
  end
  stest = e.sx+screen.size
  if stest < 128 then
   e.sx=stest
  end
  e.sy=e.y-screen.y
  stest = e.sy-screen.size
  if stest > 0 then
   e.sy=stest
  end
  stest = e.sy+screen.size
  if stest < 128 then
   e.sy=stest
  end

  -- check for collisions
  if coll(ship,e) and not ship.imm then
   ship.imm = true
   ship.energy -= enp.cdg
   if ship.energy <= 0 then
    game_over()
   end 
   explode(e.x,e.y,e.xc,e.yc)
   if e.etype == 0 then
    enp.nstat-=1
    enp.nstatkill+=1
   elseif e.etype == 1 then
    enp.nbatt-=1
   else
    enp.nfight-=1
   end
   del(enemies,e)
   if ship.energy <= 0 then
    game_over()
   end
  end

  -- determine if enemy in view
  if e.sx < 128 and 
   e.sx > 0 and 
   e.sy < 128 and
   e.sy > 0 then
   if abs(e.sx-ship.sx) < enp.lrg and
      abs(e.sy-ship.sy) < enp.lrg then
    e.hot=2
   else 
    e.hot=1
   end
  else
   e.hot=0
  end
  if abs(earth.x-e.x) < 64 and
   abs(earth.y-e.y) < 64 then
    earth.found=true
    if e.hot <= 0 then e.hot = -1 end
  end

  --enemy fire
  -- laser update
  if e.lt >= 1 then
   e.lt+=1
   if e.lt > enp.llt then
    e.lt=0
   else
    local lx1 = e.sx+e.xc
    local ly1 = e.sy+e.yc
    local lx2 = ship.sx+ship.xc
    local ly2 = ship.sy+ship.yc
    laserfire(lx1,ly1,lx2,ly2)
   end
  end
  if e.hot>0 and e.etype==1 then
   local rfire=flr(rnd(enp.bfr))
   if rfire < 2 then
    local distx=(ship.sx-e.sx)
    local disty=(ship.sy-e.sy)
    local dist=sqrt(distx*distx+disty*disty)
    local sprex=ship.sx+ship.dx*dist/enp.bsp
    local sprey=ship.sy+ship.dy*dist/enp.bsp
    distx=sprex-e.sx
    disty=sprey-e.sy
    enemyfire(e.x,e.y,distx,disty)
		 end
		elseif e.hot>1 and e.etype==2 and e.lt==0 then
   --engage laser
   local lfire=flr(rnd(enp.lfr))
   if lfire < 2 then
    if not ship.imm then ship.energy-=enp.ldg end
    e.lt=1
    local lx1 = e.sx+e.xc
    local ly1 = e.sy+e.yc
    local lx2 = ship.sx+ship.xc
    local ly2 = ship.sy+ship.yc
    laserfire(lx1,ly1,lx2,ly2)
   end
  end

 end
 
 for ex in all(explosions) do
  ex.sx=ex.x-screen.x
  ex.sy=ex.y-screen.y
 end
 
 if btnp(4) then fire() end
 if btnp(5) then 
  if ship.bgs > 0 then firebiggun() end 
 end
 
 --check energy levels
 earth.enerfra=earth.energy/earth.enermax
 ship.enerfra=ship.energy/ship.enermax
 if earth.enerfra < screen.lewarn then
  earth.lowen=true
 else
  earth.lowen=false
 end
 if ship.enerfra < screen.lewarn then
  ship.lowen=true
 else
  ship.lowen=false
 end
 if ship.lowen or earth.lowen then
  if screen.t%10>9 then sfx(3) end
 end   
 
 screen.t+=0.2
 found=earth.found
end

function draw_game()
 cls()
 --display planet field
 circfill(earth.sx+earth.xc,earth.sy+earth.yc,earth.rfield,1)
 --display stars
 for st in all(stars) do
  pset(st.sx,st.sy,st.s)
 end
 --display big-gun explode
 for bg in all(biggun) do
  circfill(bg.sx,bg.sy,bg.r,3)
  circ(bg.sx,bg.sy,bg.r,8+bg.t%3)
 end
 --minimap
 rectfill(screen.mmpx,screen.mmpy,screen.mmpx+screen.mms,screen.mmpy+screen.mms,1)
 rect(screen.mmpx-1,screen.mmpy-1,
  screen.mmpx+screen.mms+1,screen.mmpy+screen.mms+1,12)
 pset(screen.mmpx+earth.x/screen.mmsc,screen.mmpy+earth.y/screen.mmsc,12)
 pset(screen.mmpx+ship.x/screen.mmsc,screen.mmpy+ship.y/screen.mmsc,8)
 for e in all(enemies) do
  if e.etype==1 then
   pset(screen.mmpx+e.x/screen.mmsc,screen.mmpy+e.y/screen.mmsc,10)  
  elseif e.etype==0 then
   pset(screen.mmpx+e.x/screen.mmsc,screen.mmpy+e.y/screen.mmsc,11)  
  end
 end
 --display planet
 map(earth.sp.s1,earth.sp.s2,
     earth.sx,earth.sy,
     earth.sp.s3,earth.sp.s4)
 for ex in all(explosions) do
  circ(ex.sx,ex.sy,ex.t/3,8+ex.t%3)
 end
 --display laser shots
 for l in all(lasers) do
  line(l.sx1,l.sy1,l.sx2,l.sy2,8)
 end
 --display enemies
 for e in all(enemies) do
  if e.hot > 0 then 
   spr(e.sp+screen.t%2,e.sx,e.sy)
  end
 end
 --display ship
 if not ship.imm or ship.t%8 < 4 then
  spr(ship.sp,ship.sx,ship.sy) 
 end
 --display bullets
 for b in all(bullets) do
  spr(b.sp,b.sx,b.sy)
 end
 --display enemy bullets
 for b in all(ebullets) do
  spr(b.sp,b.sx,b.sy)
 end  
 --print level info
 print('level',3,123,9)
 print(enp.level,25,123,9)
 --print # of enemies
 print('sts: ',1,3,8)
 print(enp.nstat,18,3,8)
 --print game points
 print('score:',30,3,9)
 print(ship.p,55,3,9)
 --energy-bar
 if ship.lowen and screen.t%8<3 then
  print(' low ',screen.ebarpx,screen.ebarpy,9)
 else
  rectfill(screen.ebarpx,screen.ebarpy,
   screen.ebarpx+screen.ebarw,
   screen.ebarpy+screen.ebarh,8)
  rectfill(screen.ebarpx,screen.ebarpy,
   screen.ebarpx+screen.ebarw*ship.energy/ship.enermax,
   screen.ebarpy+screen.ebarh,11)
 end
--planet energy-bar
 if earth.lowen and screen.t%8<3 then
  print(' low ',screen.pebarpx,screen.pebarpy,9)
 else
  rectfill(screen.pebarpx,screen.pebarpy,
   screen.pebarpx+screen.pebarw,
   screen.pebarpy+screen.pebarh,8)
  rectfill(screen.pebarpx,screen.pebarpy,
   screen.pebarpx+screen.pebarw*earth.energy/earth.enermax,
   screen.pebarpy+screen.pebarh,12)
 end
 if earth.found then
  spr(50+screen.t%2,72,1)
 else
  spr(50,72,1)
 end
 --big gun shot indicator
 local i
 for i=1,ship.bgs do
  spr(49,100+6*i,7)
 end
 --print(screen.x,3,120,9)
 --print(stat(1),40,123,9)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000008800000000800000bb000000bb00000000007700000000000000770000000000000055000000000000005500000000000000550000000
0070070008880000000880000000888000bbbb0000bbbb0000000cc77cc000000000088777800000000005555550000000000555555000000000055555500000
00077000008b8cc0000bb0000cc8b8000bbbbbb00bbbbbb000003c77ccc300000000f877888f0000000055555555000000005555555500000000555555550000
00077000000884c000c88c000c488000babababaabababab00093337c33330000009f9f78f8ff000000655555555600000065555555560000006555555556000
00700700000c44a00cc44cc00a44c0000bbbbbb00bbbbbb000c3363c33363300008ff9f8f8f9ff00001166666666110000116666666611000011666666661100
00000000000cca00000aa00000acc00000bbbb0000bbbb0000c36cccc3363c00008f69988996f800005111111111150000511111111115000051111111111500
00000000000000000000000000000000000bb000000bb0000ccc9ccc669ccc900888998866988890055555555555555005555555555555500555555555555550
00000000000000000000000000000000000b0000000b00000cc396cc66cc69900888968869886990068555555555568006655555555556600865555555555860
0000000000000c000000000000c00000000100000001000000333c6ccccc990000f8f86989889900001866886688610000188668866881000016886688668100
000000000000cc000000000000cc000000aaaa0000aaaa00003366ccccc6690000ff668998866900001111111111110000111111111111000011111111111100
00000000088b84a0000770000a48b8800aaaaaa00aaaaaa00003c33ccccc3000000f8ff888899000000555555555500000055555555550000005555555555000
00000000088b84a0000770000a48b88090399039399039900000cccccccc00000000888888990000000066555566000000006655556600000000665555660000
000000000000cc000000000000cc00000aaaaaa00aaaaaa000000777777000000000077777700000000001666610000000000166661000000000016666100000
0000000000000c000000000000c0000000aaaa0000aaaa0000000007700000000000000770000000000000055000000000000005500000000000000550000000
00000000000000000000000000000000000880000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000cca00000aa00000acc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000c44a00cc44cc00a44c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000884c000c88c000c48800000080000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008b8cc0000bb0000cc8b8000aaaaa000aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008880000000880000000888000aaa00000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000008800000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000cc00000bbbb0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ca8c0000bb7b0000887800000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c8ac0000bbbb0000888800000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000cc00000bbbb0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0607080900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617181900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0b0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b1c1d1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00030000220601e0601a060140600f060080600106007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800003501034000340003400034000340000000000000340000000000000000000000000000000000000034000000000000000000000000000000000000003400000000000000000000000000000000000000
000900000e0500e0000d0000d000090000d00000000000000e0000d0000000000000000000000000000000000e000000000000000000000000000000000000000e00000000000000000000000000000000000000
00100000260201e0001e0001d000110000f0000d0000c0000a0000800007000050000500003000030000300003000000000000000000000000000000000000000000000000000000000000000000000000000000
000e00002505019000160001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 01 02 03 04
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
