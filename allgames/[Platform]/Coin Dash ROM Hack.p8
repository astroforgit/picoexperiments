pico-8 cartridge // http://www.pico-8.com
version 19
__lua__
-- -= coindash v??? by smelly  =-

ver="???"

gamestate=0
url=stat(102)

function _init()
 if url!="www.lexaloffle.com" and url!=0 then
  gamestate=4
  song=5
 end

  cartdata("coindash")
  ifreset=dget(0) or 0
  
  -- record stats
   highscore=dget(1) or 0
   besttime=dget(2) or 0
   ifsong=dget(3) or 0
   ifnocoin=dget(4) or 0
   if (ifnocoin==0) ifnocoin=""
   if (ifnocoin==1) ifnocoin="’"
  
 if ifreset==1 then
  camy=0
  ifreset=0
  dset(0,ifreset)
  gamestate=1
  
 end
 
 -- set time for the besttime
 for i=besttime%30,besttime do
  sec=flr(besttime/30)
 end
 for i=besttime%3600,besttime do
  minute=flr(besttime/1800)
 end
 
end
 
function _update()
 songs()
 
 if coins>minihighscore then
  minihighscore=coins
 end
 
 -- automaticly cahnge powerup
 -- names.. :\
 if powerup==0 then
  powerupname="none"
 elseif powerup==1 then
  powerupname="health"
 elseif powerup==2 then
  powerupname="beam"
 else
  powerupname="flag"
 end

 -- gamestate 0 titlescreen
 if gamestate==0 then
  mapbackground()
  camera(0,camy)
  if not titleintro then
   map(0,0,0,0,128,64,128)
   drawmob()
   map(0,0,0,0,128,64,65)
   mobmain()
   
   -- titlescreen stats
   ?"ver "..ver,1,370,7
   ?ifnocoin.."highscore "..highscore.." | ".."best time "..minute..":"..sec-minute*60,1,378,7
  end
  title()
 end
 
 -- gamestate 1 gameprep
 if gamestate==1 then
  prepgame()
 end
 
 -- gamestate 2 game
 if gamestate==2 then
  if leveltimer==0 then
   levelstart()
  end
  leveltimer+=1
  playermain()
  mobmain()
  objmain()
  
  -- level clear
  if iflevelclear then
   levelend()
  end
  
 end
--end

--function _draw()
 if gamestate==2 then
  -- cam
  cammove()
  camera(camx,camy)
 
  -- sky
  mapbackground()
 
  -- background tiles
  if area=="cave" then
   pal(4,1)
  elseif area=="night" then
   pal(4,0)
  end
  map(0,0,0,0,128,64,128)
  pal(4,4)
  -- draw all objs, mobs, player
  drawobj()
  beamball()
  
  -- draw credits and some stuff
  -- to screen
  credits()
  
  -- if not dead terrain over p
  if not ifdead then
   drawplayer()
  end
  
  if area=="sunset" then
   pal(2,1)
  end
  drawmob()
  pal(2,2)

  -- terrain
  if area=="night" then
   pal(11,3)
   pal(3,1)
  end
  map(0,0,0,0,128,64,65)
  pal(11,11)
  pal(3,3)
  
  -- ui
  ui()
  
  -- if dead p over terrain
  if ifdead then
   drawplayer()
  end
 end
 -- particles
 if area=="cave" then
  pal(4,13)
  pal(15,1)
 else
  pal(15,2)
 end
 particlemain()
 pal(4,4)
 pal(15,15)
 
 -- start gameover if dead
 if deathtimer==0 and ifdead then
  gamestate=3
 end
 
 --- menuitems
 -- restart
 if gamestate==1 or gamestate==2 then
  menuitem(1,"restart",
  function()
   ifreset=1
   dset(0,ifreset)
   run()
  end)
 else
   menuitem(1,"",
   function()
  end)
 end
 
 if highscore!=0 and gamestate==0 then
  menuitem(2,"reset highscore",
  function()
   sfx(8)
   highscore=0
   combinedtime=0
   dset(1,highscore)
   dset(2,best)
   dset(4,0)
   sec=0
   minute=0
  end)
 else
   menuitem(2,"",
   function()
  end)
 end
 
 if ifsong==1 then
  menuitem(3,"toggle music on",
   function()
   
    if ifsong==0 then
     ifsong=1
    else
     ifsong=0
    end
    dset(3,ifsong)
    sfx(23)
    
   end)
 else
  menuitem(3,"toggle music off",
   function()
   
    if ifsong==0 then
     ifsong=1
    else
     ifsong=0
    end
    dset(3,ifsong)
    sfx(7)
    
   end)
 end
 
 -- if gameover
 if gamestate==3 then
  gameover()
 end
 
 -- you wrecthed bug you!
 if gamestate==4 then
  cls(1)
  rect(0,0,127,127,0)
  ?"what?!?!?? you scammed",1,1,12
  ?"the rom-hadck ver!!?!?!? just ",1,9,12
  ?"visit www.lexaloffle.com",1,25,12
  ?"to play this and other",1,33,12
  ?"awsome games...",1,41,12
 end
end
-->8
--- player ---

-- player vars

-- movement
x=5
xv=0
xmem=0
y=5
yv=0
ymem=0
ifmove=false
ifgrounded=false
bumptimer=0

frozen=false

-- physics
x1=0
x2=0
y1=0
y2=0
sidebonk=false
sidebonktimer=0

-- sprite
s=1
f=false
face=0
vf=false
ani=0
walkanitimer=0
jumpanitimer=0

-- particle :\
--pposx=0
--pposy=0

-- cam
camx=0
camy=256

-- stats
powerupname="you shouldn't see this... crap"
powerup=0
powerupcooldown=0
powerupchoice=0
flashtimer=0
coins=0

-- ui
uiani=0
uitimer=0

--- states
-- flagclear
levelskip=false

-- dead
ifdead=false
deadinit=false
ifhurt=false
ifpit=false
deathtimer=0
dmgtimer=0
restimer=0
rescost=0

-- secret
ifgold=false

function playermain()
 playerdmg()
 input()
 playercollison()
 playerani()
 camspawn()
 mobcollison()
 objcollison()
 playerdmg()
 if ifdead then
  playerdeath()
 end
end


function drawplayer()
 if ifgold then
  pal(7,10)
  pal(6,9)
  pal(1,2)
 end
 spr(s+ani,x-4,y-7,1,1,f,vf)
  pal(1,1)
  pal(6,6)
  pal(7,7)
 --rect(x1,y1,x2,y2,8)
end

function playerhitbox()
 x1=x-3
 y1=y-5
 x2=x+2
 y2=y
end

function playercollison()
 ifgrounded=false
 
 -- side bonk
 if sidebonk==true then
  sidebonktimer-=1
 end
 if sidebonktimer==0 then
  sidebonk=false
  sidebonktimer=0
 end
 -- add volcity
   x+=xv
   y+=yv
  
  playerhitbox()
 -- only do collison if not dead 
 if not ifdead then
  
  -- only do collison in the lvl
  if x>levelx-1 and x<510+levelx and y-127<levely and y>levely then
 
   -- test of player is in ground
   if fget(mget(x1/8,y2/8),0) or
      fget(mget(x2/8,y2/8),0) then
    
   -- negate volcity   
   y-=yv
   yv=0
   ifgrounded=true
   end
 
   -- test if in ceiling
   if fget(mget(x1/8,y1/8),0) or
      fget(mget(x2/8,y1/8),0) then
    
    -- negate volcity   
    y+=yv
    yv=0
    if bumptimer==0 then   
     bumptimer=2
     sfx(3)
    end
   end
 
   -- test for wall to the right
   if fget(mget(x2/8,y1/8),0) and
      fget(mget(x2/8,y2/8),0) then
     
    -- negate volcity   
    x-=xv
    xv=0
    sidebonk=true
    sidebonktimer=8
    if bumptimer==0 then   
     bumptimer=10
     sfx(3)
    end
   end
 
   -- test for wall to the left
   if fget(mget(x1/8,y1/8),0) and
      fget(mget(x1/8,y2/8),0) then 
     
    -- negate volcity   
    x-=xv
    xv=0
    sidebonk=true
    sidebonktimer=8
    if bumptimer==0 then   
     bumptimer=10
     sfx(3)
    end
 
   end

   playerhitbox()
   -- if still in ground push up
   if fget(mget(x1/8,y2/8),0) or
      fget(mget(x2/8,y2/8),0) then
    y-=1
   end
 
 
   -- if still in ceiling
   if (fget(mget(x1/8,y1/8),0) or
      fget(mget(x2/8,y1/8),0)) and
      sidebonk==false then
    
    if bumptimer==0 then   
     bumptimer=8
     sfx(3)
    end
    y+=4
   end
 
  end
  
 end

 --- gravity
 yv+=.5
 
 --- volvcity cap
  xv/=1.8
  yv/=1.2
 
 -- bumptimer
 if bumptimer>=1 then
  bumptimer-=1
 end
 
 if y>128+levely and not  ifhurt then
  ifhurt=true
  deathtimer=100
 end
 
end




function input()
 ifmove=false
 
 if not frozen then
  if btn(‹) then
   xv-=1
   f=true
   ifmove=true
  end
  
  if btn(‘) then
   xv+=1
   f=false
   ifmove=true
  end
  
  if ifgrounded and
  (btnp(”) or btnp(—)) then 
   
    yv-=5
    sfx(3)
    jumpanitimer=30
    
  -- power ups
  elseif btnp(Ž) then
   if powerup==2 and powerupcooldown==0 then
    sfx(14)
    if f==true then
     face=-7
    else
     face=7
    end
     powerupcooldown=60
     addbeamball(x+face,y,face/7,60,"player")
   elseif powerup==3 and level!=4 then
    powerup=0
    iflevelclear=true
   end
  
  
  
  end
 end
end



function playerani()
 if ifmove then
  walkanitimer+=1
 else
  walkanitimer=0
  ani=0
 end
 
 if walkanitimer<=8 and walkanitimer!=0 then
  ani=1
  if (ifgold) addparticle(x,y,0)
 elseif walkanitimer>=8 and walkanitimer<=16 and walkanitimer!=0 then
  ani=2
 elseif walkanitimer>=16 and walkanitimer!=0 then
  walkanitimer=0
 end
 
 if walkanitimer==2 and ifgrounded then
  sfx(4)
  if mget(x/8,y/8+1)==64 then
   addparticle(x,y-2,4)
  end
 elseif walkanitimer==8 and ifgrounded then
  sfx(4)
  if mget(x/8,y/8+1)==64 or
     mget(x/8,y/8+1)==86 then
   addparticle(x,y-2,4)
  end
  if fget(mget(x/8,y/8),5) then
   addparticle(x,y-4,5)
  end
 end
 
 if jumpanitimer!=0 then
  jumpanitimer-=1
  ani=3
 end
 if ifgrounded then
  jumpanitimer=0
 end



end


-- cam scrolling and cam bounds
function cammove()
 if x-camx>64 and camx<384+levelx then
  camx+=2
 end
 
 
 -- bounds for player
 if x<=2+camx then
  x=2+camx
 elseif x>508+levelx then
  x=507+levelx
 end


end


-- spawn kill mobs / obj
function camspawn()
 -- mob / obj spawing
 for i=0,16 do
  iy=i+levely/8
  ix=17+camx/8
  
  isx=ix*8+2
  isy=iy*8+7
  
  -- sprout
  if     mget(ix,iy)==7 then 
     mset(ix,iy,0)
     addsprout(isx,isy,"simple",0)
     
  -- sprout w/ background
  elseif mget(ix,iy)==8 then 
     mset(ix,iy,77)
     addsprout(isx,isy,"simple",0)

  -- mush
  elseif mget(ix,iy)==11 then 
     mset(ix,iy,0)
     addsprout(isx,isy,"chase",1)
     
  -- mush w/ background
  elseif mget(ix,iy)==12 then 
     mset(ix,iy,77)
     addsprout(isx,isy,"chase",1)
  
  -- goldy
  elseif mget(ix,iy)==15 then 
     mset(ix,iy,0)
     addsprout(isx,isy,"simple",2)
  
  -- goldy w/ background   
  elseif mget(ix,iy)==16 then 
     mset(ix,iy,77)
     addsprout(isx,isy,"simple",2)
     
  -- gunner
  elseif mget(ix,iy)==19 then 
     mset(ix,iy,0)
     addsprout(isx,isy,"simple",3)
  
  -- gunner w/ background
  elseif mget(ix,iy)==20 then 
     mset(ix,iy,77)
     addsprout(isx,isy,"simple",3)
     
  -- bandera sprout
  elseif mget(ix,iy)==23 then 
     mset(ix,iy,0)
     addsprout(isx,isy,"simple",4)
     
  -- bandera sprout w/ background
  elseif mget(ix,iy)==24 then 
     mset(ix,iy,77)
     addsprout(isx,isy,"simple",4)
     
  -- flap
  elseif mget(ix,iy)==27 then 
     mset(ix,iy,0)
     addflap(isx,isy)

  -- flap w/ background
  elseif mget(ix,iy)==28 then 
     mset(ix,iy,77)
     addflap(isx,isy)
     
  -- coin
  elseif mget(ix,iy)==34 then 
     mset(ix,iy,0)
     addcoin(isx+2,isy-1,0)
     
  -- coin w/ background
  elseif mget(ix,iy)==35 then 
     mset(ix,iy,77)
     addcoin(isx+2,isy-1,0)
    
    
  -- redcoin
  elseif mget(ix,iy)==37 then 
     mset(ix,iy,0)
     addcoin(isx+2,isy-1,1) 
     
  -- redcoin w/ background
  elseif mget(ix,iy)==38 then 
     mset(ix,iy,77)
     addcoin(isx+2,isy-1,1)
      
  -- power pack
  elseif mget(ix,iy)==40 then 
     mset(ix,iy,0)
     addpowerpack(isx+2,isy)
     
  -- power pack w/ background
  elseif mget(ix,iy)==41 then 
     mset(ix,iy,77)
     addpowerpack(isx+2,isy)
       
  -- flag
  elseif mget(ix,iy)==52 then 
     mset(ix,iy,0)
     addflag(isx,isy,0)
  
  -- flag w/ background
  elseif mget(ix,iy)==53 then 
     mset(ix,iy,77)
     addflag(isx,isy,1)
    
  -- redflag
  elseif mget(ix,iy)==55 then 
     mset(ix,iy,0)
     addflag(isx,isy,1)
  
  -- redflag w/ background
  elseif mget(ix,iy)==56 then 
     mset(ix,iy,77)
     addflag(isx,isy,1)
    
  -- mushroom
  elseif mget(ix,iy)==58 then 
     mset(ix,iy,0)
     addmushroom(isx+2,isy)
     
  -- mushroom w/ background
  elseif mget(ix,iy)==59 then 
     mset(ix,iy,77)
     addmushroom(isx+2,isy)
  
  end
 end
   
 -- inital spawing
 if camx==0+levelx then
  
  for i2=0,16 do
   for i=0,16 do
    ix=i+levelx/8
    iy=i2+levely/8
    
    -- player cords /background
    -- share
    if mget(ix,iy)==1 or mget(ix,iy)==2 then 
       initx=(ix+.5)*8
       inity=(iy+.5)*8
       x=initx
       y=inity
       for i=1,20 do
        addparticle(x,y,3)
       end
     -- player cords
     if (mget(ix,iy)==1) mset(ix,iy,0)
     -- player cords + background
     if (mget(ix,iy)==2) mset(ix,iy,77)
     
    -- sprout
    elseif mget(ix,iy)==7 then 
       mset(ix,iy,0)
       addsprout((ix+.5)*8,(iy+.9)*8,"simple",0)
    
    -- mush
    elseif mget(ix,iy)==11 then 
       mset(ix,iy,0)
       addsprout((ix+.5)*8,(iy+.9)*8,"chase",1)
    
    -- goldy
    elseif mget(ix,iy)==15 then 
       mset(ix,iy,0)
       addsprout((ix+.5)*8,(iy+.9)*8,"simple",2)
    
    -- gunner
    elseif mget(ix,iy)==19 then 
       mset(ix,iy,0)
       addsprout((ix+.5)*8,(iy+.9)*8,"simple",3)
    
    -- flap
    --[[
    elseif mget(ix,iy)==27 then 
       mset(ix,iy,0)
       addflap((ix+.5)*8,(iy+.9)*8) ]]--
       
    -- bandera sprout
    elseif mget(ix,iy)==23 then 
       mset(ix,iy,0)
       addsprout((ix+.5)*8,(iy+.9)*8,"simple",4)
       
       
    -- coin 
    elseif mget(ix,iy)==34 then 
       mset(ix,iy,0)
       addcoin((ix+.5)*8,(iy+.8)*8,0)
    
    -- coin w/ background 
    elseif mget(ix,iy)==35 then 
       mset(ix,iy,77)
       addcoin((ix+.5)*8,(iy+.8)*8,0)

    -- redcoin 
    elseif mget(ix,iy)==37 then 
       mset(ix,iy,0)
       addcoin((ix+.5)*8,(iy+.8)*8,1)
       
    -- redcoin w/ background
    elseif mget(ix,iy)==38 then 
       mset(ix,iy,77)
       addcoin((ix+.5)*8,(iy+.8)*8,1)
    
    -- powerpack
    elseif mget(ix,iy)==40 then 
       mset(ix,iy,0)
       addpowerpack((ix+.5)*8,(iy+.9)*8)
       
    -- powerpack w/ background
    elseif mget(ix,iy)==41 then 
       mset(ix,iy,77)
       addpowerpack((ix+.5)*8,(iy+.9)*8)
    
    -- mushroom
    elseif mget(ix,iy)==58 then 
       mset(ix,iy,0)
       addmushroom((ix+.5)*8,(iy+.9)*8)
    
     -- mushroom w/ background
    elseif mget(ix,iy)==59 then 
       mset(ix,iy,77)
       addmushroom((ix+.5)*8,(iy+.9)*8)   
   
    end
   end
  end
   
 end
 
 -- kill any mobs if off screen
 for m in all(mob) do
  if     m.x-camx<-64 then
   del(mob,m)
  elseif m.x-camx>=192 then
   del(mob,m)
  elseif m.y>=levely+136 then
   del(mob,m)
  end
  
 end
 
 -- kill any objs if off screen
 for o in all(obj) do
  if     o.x-camx<-64 then
   del(obj,o)
  elseif o.x-camx>=192 then
   del(obj,o)
  elseif o.y>=levely+136 then
   del(obj,o)
  end
 end
 
end



function mobcollison()
 -- sprouts / mushys
 for m in all(mob) do
  if m.ai=="simple" or m.ai=="chase" then
  
   -- hit
   if x1<=m.x1 and x2>=m.x2 and
      y1-1<m.y2 and y2>=m.y2 and
      not m.ifdead and 
      dmgtimer==0 and 
      m.ty!=2  then
    ifhurt=true
   end
  
  
  
   -- bounce
   if (x1<=m.x1 and x2>=m.x2) 
   and y1<=m.y2 and y2>=m.y1 and
   not m.ifdead then
    yv=-7
    jumpanitimer=30
    m.ifdead=true
    sfx(8)
    
    if m.ty==1 then
     for i=1,16 do
      addparticle(m.x,m.y,6)
     end
    end
    if m.ty==2 then
     coins+=8
     sfx(6)
     for i=1,16 do
      addparticle(m.x,m.y,0)
     end
    else
     for i=1,8 do
      addparticle(m.x,m.y,3)
     end
    end
   end
   
  
  
  end
  
  if m.ai=="flight" then
  -- kill
   if x1<=m.x1 and x2>=m.x2 and
      y1-1<m.y2 and y2>=m.y2 and
      not m.ifdead and dmgtimer==0 then
      
    sfx(8)  
    yv=-8
    m.vf=true
    jumpanitimer=30
    m.ifdead=true
    for i=0,8 do
     addparticle(m.x,m.y,3)
    end
    
   end
  
  end
  -- explode poop bomb on player
  if m.ai=="drop" then
  -- kill
   if x1<=m.x1 and x2>=m.x2 and
      y1-1<m.y2 and y2>=m.y2 and
      not m.ifdead and dmgtimer==0 then
      
    for i=0,16 do
     addparticle(m.x,m.y-8,3)
    end
    sfx(12)
    if m.x>x-8 and m.x<x+8 and
     m.y>y-8 and m.y<y+4 then
     ifhurt=true
     yv-=8  
    end   
    del(mob,m)
    
   end
  
  end
 end





end

function objcollison()
 -- coin
 for o in all(obj) do
 
  -- coin col
  if o.coll=="coin" then
   if x1<=o.x1 and
      y1<=o.y2 and
      x2>=o.x2 and
      y2>=o.y1 then
      
    if o.col==0 then 
     sfx(5)
     del(obj,o)
     for i=1,4 do
      addparticle(o.x,o.y,0)
     end
     coins+=1
    else
     sfx(6)
     del(obj,o)
     for i=1,4 do
      addparticle(o.x,o.y,1)
     end
     coins+=8
    end
   end
  end
  
  --[[
  -- red coin col
  if o.coll=="red" then
   if x1<=o.x1 and
      y1<=o.y2 and
      x2>=o.x2 and
      y2>=o.y1 then
     
    sfx(6)
    del(obj,o)
    for i=1,4 do
     addglint(o.x,o.y,1)
    end
    coins+=4
   end 
   
  end
  ]]--
  -- power pack
  if o.coll=="power" then
   if x1<=o.x1 and
      y1<=o.y2 and
      x2>=o.x2 and
      y2>=o.y1 then
      
    if powerupchoice!=0 then
     sfx(13)
    end
    
    -- none
    if powerupchoice==0 then
     del(obj,o)
     sfx(8)
     for i=1,32 do
      addparticle(o.x,o.y,3)
     end
    -- health
    elseif powerupchoice==1 then
     del(obj,o)
     for i=1,32 do
      addparticle(o.x,o.y,1)
     end
     powerup=1
    
    -- beam
    elseif powerupchoice==2 then
     del(obj,o)
     for i=1,32 do
      addparticle(o.x,o.y,0)
     end
     powerup=2
    end
   end
  end
  
  
  -- flag coll
  if o.coll=="flag" then
   if x1<=o.x1 and
      y1<=o.y2 and
      x2>=o.x2 and
      y2>=o.y1 then
     
    sfx(7)
    flashtimer=0
    if o.ty==1 then
     levelskip=true
    end
    -- remove enemys
    for m in all(mob) do
     for i=1,4 do
      addparticle(m.x,m.y,3)
     end
     del(mob,m)
    end
    del(obj,o)
    for i=1,20 do
     addparticle(o.x,o.y,3)
    end
    iflevelclear=true
   end 
  end
  
  -- mushroom col
  if o.coll=="spring" then
   if x1<=o.x1 and
      y1<=o.y2 and
      x2>=o.x2 and
      y2>=o.y1 then
    
    sfx(11)
    for i=1,16 do
     addparticle(x,y-2,6)
    end
    yv=-10
   end
  end
  
  -- beam ball coll
  if o.coll=="harm" and o.owner=="gunner" then
   if x1<=o.x1 and
      y1<=o.y2 and
      x2>=o.x2 and
      y2>=o.y1 and
      restimer==0 then
      
     
    sfx(10)
    del(obj,o)
    for i=1,4 do
     addparticle(o.x,o.y,3)
    end
    ifhurt=true
   end
  end
    
 end
end

function playerdmg()

 -- dont live in pits ya doofus
 if y>levely+128 and ifpit==false then
  if flashtimer!=0 then
   levelthemes()
   flashtimer=0
  end
  restimer=0
  dmgtimer=0
  ifpit=true
 end


 if dmgtimer!=0 then
  dmgtimer-=1
 end
 if restimer!=0 then
  restimer-=1
 end
 
 if flashtimer!=0 then
  flashtimer-=1
  ifhurt=false
  if (flashtimer%2==1) addparticle(x-4,y-4,2)
 end
 -- reset song when flash s done
 if flashtimer==20 then
  levelthemes()
 end
 
 -- prevent dmg durning restimer
 if restimer!=0 then
  ifhurt=false
 end
 
 
 if dmgtimer==1 then
  s=1
 elseif dmgtimer>=1 then
  s=5
  ani=0
 end

 if ifhurt and dmgtimer==0 and flashtimer==0 and restimer==0 then
  if powerup==1 then
   powerup=0
   dmgtimer=50
   ifhurt=false
   yv=0
   sfx(9)
  else
  ani=0
   if not deadinit and restimer==0 then
    sfx(10)
    for i=1,64 do
     addparticle(x1,y,3)
    end
    deathtimer=100
    xmem=x
    ymem=y
    s=5
    vf=true
    frozen=true
    deadinit=true
    ifdead=true
   end
  end
 end
end





function ui()
 
 spr(40+uiani+powerup*3,camx,9+camy)
 ?powerupname,9+camx,12+camy,7
 
 -- make the coin red if you 
 -- have over 99
 if coins<99 then
  spr(34+uiani,0+camx,0+camy)
 else
  spr(37+uiani,0+camx,0+camy)
 end
 
 if coins>=rescost then
  ?"x"..coins,8+camx,3+camy,7
 else
  ?"x"..coins,8+camx,3+camy,8
 end
 
 
 uitimer+=1
 
 if uitimer==8 then
  uiani=1
 elseif uitimer==16 then
  uiani=2
 elseif uitimer>=24 then
  uiani=0
  uitimer=0
 end
 

end



function playerdeath()
 -- rip
 if coins<rescost then
  song=0
 end
 
 if deathtimer==1 then
  if coins>=rescost then
   coins-=rescost
   rescost+=4
   restimer=200
   ifdead=false
   frozen=false
   ifpit=false
   ifhurt=false
   s=1
   vf=false
   x=xmem
   powerup=0
   y=ymem
   deadinit=false
   
   -- if you die over pit still spawn da thing
    if ymem>levely+128 or
    (mget(x1/8-.2,levely/8+15)==0 or
     mget(x2/8+.2,levely/8+15)==0) and
     ymem>=levely+48 then
     
    y=104+levely
    restimer=200
    mset(x/8,(y+1)/8,127)
   end
   sfx(13)
   for i=1,16 do
    addparticle(x-4,y-4,0)
   end
  end
 end
 
 if deathtimer>0 then
  deathtimer-=1
 end
end
-->8
--- creatures ---
mob={}


-- adds a sprout
function addsprout(x,y,ai,ty)
 sp={
 
  -- mob id
  ai=ai,
  ty=ty,
  --position
  x=x,
  y=y,
  --movement
  xv=-1,
  yv=0,
  ifmove=true,
  grounded=true,
  -- sprite
  s=7+ty*4,
  f=true,
  vf=false,
  walkani=0,
  ani=0,
  -- sprite size
  sw=8,
  sh=7,
  -- particle
  --pposx=0,
  --pposy=0,
  -- hitbox size
  w=5,
  h=4,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  spawninit=true,
  -- state
  ifdead=false,
  despawntimer=0,
  cooldown=0,
 }
 add(mob,sp)
 return sp
end


-- combining sprout with goldys,
-- gunners, banderas, & mushys.
--[[

-- adds a mush
function addmush(x,y)
 mu={
  --position
  x=x,
  y=y,
  --movement
  xv=-1,
  yv=0,
  ifmove=true,
  grounded=true,
  -- sprite
  s=11,
  f=true,
  vf=false,
  walkani=0,
  ani=0,
  -- particle
  pposx=0,
  pposy=0,
  -- hitbox size
  w=5,
  h=4,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  -- aitype
  ai="chase",
  -- state
  ifdead=false,
  despawntimer=0,
  cooldown=0
  
 }
 add(mob,mu)
 return mu
end


-- adds a goldy
function addgold(x,y)
 gd={
  --position
  x=x,
  y=y,
  --movement
  xv=1,
  yv=0,
  ifmove=true,
  grounded=true,
  -- sprite
  s=15,
  f=false,
  vf=false,
  walkani=0,
  ani=0,
  -- particle
  pposx=0,
  pposy=0,
  -- hitbox size
  w=5,
  h=4,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  -- aitype
  ai="simple",
  -- state
  ifdead=false,
  despawntimer=0,
  cooldown=0,
  
  -- simple ai spesfic
  ifgold=true,
  ifgun=false,
  ifbandera=false
 }
 add(mob,gd)
 return gd
end

-- adds a gunner
function addgunner(x,y)
 gn={
  --position
  x=x,
  y=y,
  --movement
  xv=-1,
  yv=0,
  ifmove=true,
  grounded=true,
  -- sprite
  s=19,
  f=true,
  face=0,
  vf=false,
  walkani=0,
  ani=0,
  -- particle
  pposx=0,
  pposy=0,
  -- hitbox size
  w=5,
  h=4,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  -- aitype
  ai="simple",
  -- state
  ifdead=false,
  despawntimer=0,
  cooldown=0,
  
  -- simple ai spesfic
  ifgold=false,
  ifgun=true,
  ifbandera=false
 }
 add(mob,gn)
 return gn
end


-- adds a bandera sprout
function addbandera(x,y)
 sb={
  --position
  x=x,
  y=y,
  --movement
  xv=-1,
  yv=0,
  ifmove=true,
  grounded=true,
  -- sprite
  s=30,
  f=true,
  vf=false,
  walkani=0,
  ani=0,
  -- sprite size
  sw=8,
  sh=7,
  -- particle
  pposx=0,
  pposy=0,
  -- hitbox size
  w=5,
  h=4,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  -- aitype
  ai="simple",
  -- state
  ifdead=false,
  despawntimer=0,
  cooldown=0,
  
  -- simple ai spesfic
  ifgold=false,
  ifgun=false,
  ifbandera=true
 }
 add(mob,sb)
 return sb
end

]]--

-- adds a flap
function addflap(x,y)
 fp={
  --position
  x=x,
  y=y,
  --movement
  xv=-1,
  yv=0,
  ifmove=true,
  grounded=false,
  -- sprite
  s=27,
  f=true,
  vf=false,
  walkani=0,
  ani=0,
  -- particle
  --pposx=0,
  --pposy=0,
  -- hitbox size
  w=6,
  h=8,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  -- aitype
  ai="flight",
  -- state
  ifdead=false,
  despawntimer=0,
  cooldown=0,
  
  -- flap exclusive
  shit=true
 }
 add(mob,fp)
 return fp
end

-- adds a shit
function addshit(x,y)
 po={
  --position
  x=x,
  y=y,
  --movement
  xv=0,
  yv=0,
  ifmove=true,
  grounded=false,
  -- sprite
  s=31,
  f=true,
  vf=false,
  walkani=0,
  ani=0,
  -- particle
  pposx=0,
  pposy=0,
  -- hitbox size
  w=8,
  h=8,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  -- aitype
  ai="drop",
  -- state
  ifdead=false,
  despawntimer=0,
  cooldown=0,
 }
 add(mob,po)
 return po
end



-- main function for mobs
function mobmain()
 mobhitbox(m)
 mobcollsion()
 mobmove()
 animatemob()
end

-- update hitboxes
function mobhitbox(m)
 for m in all(mob) do
  m.x1=m.x+m.w/2
  m.x2=m.x-m.w/2
  m.y1=m.y-m.h
  m.y2=m.y
 end
end





-- collsion for all them mobs
function mobcollsion()
 for m in all(mob) do
 
  -- only do collison in the lvl
  if (m.x>levelx-1 and
     m.x<508+levelx  and
     m.y-127<levely and
     m.y>levely) or
     not titleend then
 
      -- do vertical
   if (fget(mget(m.x1/8,(m.y2+1)/8),0) or
       fget(mget(m.x2/8,(m.y2+1)/8),0)) then
    m.grounded=true
    m.yv=0
    
    -- poop bomb
    if m.ai=="drop" then
     for i=1,16 do
      addparticle(m.x,m.y-8,3)
     end
     sfx(12)
     if m.x>x-24 and m.x<x+24 and
        m.y>y-16 and m.y<y+16 then
      ifhurt=true  
     end   
     del(mob,m)
    end
   else 
    m.grounded=false
    m.yv=1
    
    -- prevent bandera sprouts for walking off ledges
    if m.ai=="simple" and m.ty==4 and not m.ifdead then
     m.yv=0
     m.xv/=-1
     m.f= not m.f
    
    
    end
   end
   
   -- cooldown (mushys)
   if m.ty==1 and m.cooldown!=0 then
    m.cooldown-=1
   end
   
   -- do horizontal sides
   if (fget(mget(m.x1/8,m.y1/8),0) or
      fget(mget(m.x2/8,m.y1/8),0) or
      fget(mget(m.x1/8,m.y1/8),0) or
      fget(mget(m.x1/8,m.y2/8),0)) then
   -- do horizontal
  
    -- ai types:
    if m.ai=="simple" or m.ty==3 then
     if not m.ifdead then
      sfx(3)
      -- flip mobs direction
      m.xv*=-1
      m.f= not m.f
     end
    end
    
    if m.ai=="chase" then
     if not m.ifdead then
      sfx(3)
      -- flip mobs direction
      m.xv*=-1
      m.f= not m.f
      m.y-=1
      m.cooldown=10
     end
    end
   end
  end
 end
end

-- moves all creatures with
-- their diffrent ai types.
function mobmove()
 for m in all(mob) do
  -- goldys move left
  if m.spawninit and m.ty==2 then
   m.xv=1
   m.f=false
   m.spawninit=false
  end
  if not m.ifdead then
    m.x+=m.xv
  end

  
  if m.ai!="flight" then
   m.y+=m.yv
  end
  if m.ai=="flight" and m.ifdead then
   m.y+=m.yv+.05
  end
  
  if m.ty==3 and m.xv==-1 then
   m.xv/=3
  end
  
  if m.ai=="drop" then
   m.yv+=1
   m.y+=m.yv
  end
  
  --- ai
  -- chase
  if m.ai=="chase" and 
     m.cooldown==0 and 
     not ifdead    and
     not m.ifdead  and 
     gamestate==2 then 
     
   -- chase player
   if m.x>x then
    m.xv=-1
    m.f=true
   elseif m.x<x then
    m.xv=1
    m.f=false
   end  
  end
  if m.ai=="flight" and m.shit then
   if m.x<=x+2 and m.x>=x-2 and m.y<y then
    sfx(9)
    m.shit=false
    addshit(m.x,m.y)
    m.ani=3
   end
  
  end
  
 end
 
end



function drawmob()
 -- draw all mobs
 for m in all(mob) do
  spr(m.s+m.ani,m.x-4,m.y-7,1,1,m.f,m.vf)
  --rect(m.x1,m.y1,m.x2,m.y2,8)
 end
end


function animatemob()
 for m in all(mob) do
 
  if not m.ifdead then
    -- if the mob moves (no snake)
   if m.ifmove then
    
    -- slow down gunners
    if m.ty!=3 then
     m.walkani+=1
    else
     m.walkani+=.5
    end
    
    if m.walkani==8 then
     m.ani=1
     if (m.ty==1) addparticle(m.x,m.y,6)
     for i=1,2 do
      if (m.ty==2) addparticle(m.x,m.y,0)
     end
    elseif m.walkani>=16 then
     m.ani=2
     if (m.ty==1) addparticle(m.x,m.y,6)
     m.walkani=0 
    end

   
    if m.grounded and m.walkani==8 or m.walkani==16 then
     sfx(4)
     
     if mget(m.x/8,m.y/8+1)==64 or
      mget(m.x/8,m.y/8+1)==86 then
      addparticle(m.x,m.y-2,4)
     end
     if fget(mget(m.x/8,m.y/8),5) then
      addparticle(m.x,m.y-4,5)
     end
    end
    
    if m.ty==3 then
     
     if m.f then
      m.face=-7
     else
      m.face=7
     end
     
     if m.walkani==15 then
      sfx(8)
      addbeamball(m.x+m.face,m.y,m.face/7,40,"gunner")
     end
    end
    
    
   -- if their not moving
   else
    m.walkani=0
    m.ani=0
   end
  else
   m.ani=3
   m.despawntimer+=1
  
   if m.despawntimer==50 then
    del(mob,m)
   end
  end
  
 end
end
-->8
--- objects ---
obj={}



-- coins
function addcoin(x,y,col)

 c={
  --position
  x=x,
  y=y,
  -- sprite
  col=col,
  s=34+col*3,
  ani=0,
  anitimer=0,
  -- hitbox
  w=5,
  h=5,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  
  -- coll type
  coll="coin"
  
 }
 add(obj,c)
 return c
end

-- red coin
--[[
function addredcoin(x,y)

 rc={
  --position
  x=x,
  y=y,
  -- sprite
  s=37,
  ani=0,
  anitimer=0,
  -- hitbox
  w=5,
  h=5,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  
  -- coll type
  coll="red"
 }
 add(obj,rc)
 return rc
end ]]--

-- power pack
function addpowerpack(x,y)

 pp={
  --position
  x=x,
  y=y,
  -- sprite
  s=40+powerupchoice*3,
  ani=0,
  anitimer=0,
  -- hitbox
  w=5,
  h=5,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  
  -- coll type
  coll="power"
  
 }
 add(obj,pp)
 return pp
end

-- flag
function addflag(x,y,ty)

 fg={
  --position
  x=x,
  y=y,
  -- is red flag?
  ty=ty,
  -- sprite
  s=52+ty*3,
  ani=0,
  anitimer=0,
  -- hitbox
  w=5,
  h=5,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  -- coll type
  coll="flag"
  
 }
 add(obj,fg)
 return fg
end

--[[
-- redflag
function addredflag(x,y)

 rfg={
  --position
  x=x,
  y=y,
  -- sprite
  s=55,
  ani=0,
  anitimer=0,
  -- hitbox
  w=5,
  h=5,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  
  -- is red flag?
  redflag=true,
  -- coll type
  coll="flag"
  
 }
 add(obj,rfg)
 return rfg
end ]]--


-- mushroom
function addmushroom(x,y)

 mu={
  --position
  x=x,
  y=y,
  -- sprite
  s=58,
  ani=0,
  anitimer=0,
  -- hitbox
  w=5,
  h=7,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  
  -- coll type
  coll="spring"
  
 }
 add(obj,mu)
 return mu
end

-- beamball
function addbeamball(x,y,xv,timer,owner)

 bb={
  --position
  x=x,
  y=y,
  xv=xv,
  -- sprite
  s=61,
  ani=0,
  anitimer=0,
  -- hitbox
  w=7,
  h=7,
  x1=0,
  x2=0,
  y1=0,
  y2=0,
  
  -- beam ball timer / owner
  timer=timer,
  owner=owner,
  -- coll type
  coll="harm"
  
 }
 add(obj,bb)
 return bb
end


function objmain()
 objani()
 objhitbox()
end



-- make obj hitboxes
function objhitbox()
 for o in all(obj) do
   -- coins and redcoins
   o.x1=o.x+o.w/2
   o.x2=o.x-o.w/2
   o.y1=o.y-o.h
   o.y2=o.y
 end
end


function drawobj()
 for o in all(obj) do
  spr(o.s+o.ani,o.x-4,o.y-7)
  --rect(o.x1,o.y1,o.x2,o.y2,8)
 end
end

-- animate objs
function objani()
 -- animate objects
 for o in all(obj) do
  o.anitimer+=1
  if o.anitimer==8 then
   o.ani=1
  elseif o.anitimer==16 then 
   o.ani=2
  elseif o.anitimer>=24 then
   o.ani=0
   o.anitimer=0
  end
 end
end


function beamball()

 -- cooldown
 if (powerupcooldown>0) powerupcooldown-=1

 
 for o in all(obj) do
  if o.coll=="harm" then
   o.x+=o.xv
   o.xv*=1.05
   
   if o.timer>0 then
    o.timer-=1
   else
    for i=1,8 do
     addparticle(o.x,o.y,3)
    end
    sfx(15)
    del(obj,o)
   end
   
   -- test for wall to the right
   if (fget(mget(o.x2/8,o.y1/8),0) or
      fget(mget(o.x2/8,o.y2/8),0)) and
      mget(o.x2/8,o.y1/8)!=127 and
      mget(o.x2/8,o.y2/8)!=127 then
      
    -- bounce  
    o.xv/=-1
    o.xv/=1.5
    o.x+=8
   end
 
   -- test for wall to the left
   if (fget(mget(o.x1/8,o.y1/8),0) or
      fget(mget(o.x1/8,o.y2/8),0)) and
      mget(o.x1/8,o.y1/8)!=127 and
      mget(o.x1/8,o.y2/8)!=127 then
        
    -- bounce  
    o.xv/=-1
    o.xv/=1.5
    o.x-=8
   end
   
   for m in all(mob) do
    if m.x1<=o.x1+1 and
       m.y1<=o.y2+2 and
       m.x2>=o.x2-1 and
       m.y2>=o.y1-2 and
       m.ty!=3 and
       not m.ifdead then
      
    
    sfx(7)
    powerupcooldown=5
    del(obj,o)
    for i=1,32 do
     addparticle(o.x,o.y,3)
    end
    if m.ty==2 then
     coins+=4
     sfx(6)
     for i=1,16 do
      addparticle(m.x,m.y,0)
     end
    end
    if m.ai=="flight" then
     m.vf=true
    end
    m.ifdead=true
    end
   end
   
  end
 end
end
-->8
--- particles ---
particle={}

function particlemain()
 particleani()
 drawparticle()
end

--[[
function addglint(x,y,col)
 gl={
 x=x,
 xv=0,
 y=y,
 yv=0,
 col=col,
 s=104+col*3,
 horzflip=false,
 ani=0,
 anitimer=0,
 sp=0,
 ty="sparkle"
 
 }

 add(particle,gl)
 return gl
end ]]--

-- (outdated) 
-- coplied red/blue glint into
-- glint for space

--[[
function addredglint(x,y)
 rgl={
 x=x,
 xv=0,
 y=y,
 yv=0,
 s=107,
 horzflip=false,
 ani=0,
 anitimer=0,
 sp=0,
 ty="sparkle"
 
 }

 add(particle,rgl)
 return rgl
end

function addblueglint(x,y)
 bgl={
 x=x,
 xv=0,
 y=y,
 yv=0,
 s=110,
 horzflip=false,
 ani=0,
 anitimer=0,
 sp=0,
 ty="sparkle"
 
 }

 add(particle,bgl)
 return bgl
end  ]]--

function addparticle(x,y,ty2)
 pa={
 x=x,
 xv=0,
 y=y,
 yv=0,
 ty="fast",
 ty2=ty2,
 s=104+ty2*3,
 horzflip=false,
 ani=0,
 anitimer=0,
 sp=0
 
 }
 
 if pa.ty2==4 then
  pa.ty="drop"
 elseif pa.ty2==5 then
  pa.ty="drift"
 elseif pa.ty2<3 then
  pa.ty="sparkle"
 end
 
 add(particle,pa)
 return pa
  
 
end


-- compiled all particles
-- into one func for space
--[[

function addpoof(x,y)
 pf={
 x=x,
 xv=0,
 y=y,
 yv=0,
 s=113,
 horzflip=false,
 ani=0,
 anitimer=0,
 sp=0,
 ty="fast"
 
 }
 
  add(particle,pf)
  return pf
end


function addground(x,y)
 gr={
 x=x,
 xv=0,
 y=y,
 yv=0,
 s=116,
 horzflip=false,
 ani=0,
 anitimer=0,
 sp=0,
 ty="drop"
 
 }
 
  add(particle,gr)
  return gr
end

function addleaf(x,y)
 lf={
 x=x,
 xv=0,
 y=y,
 yv=0,
 s=119,
 horzflip=false,
 ani=0,
 anitimer=0,
 sp=0,
 ty="drift"
 
 }
 
  add(particle,lf)
  return lf
end

function addspore(x,y)
 sp={
 x=x,
 xv=0,
 y=y,
 yv=0,
 s=122,
 horzflip=false,
 ani=0,
 anitimer=0,
 sp=0,
 ty="fast"
 
 }
 
  add(particle,sp)
  return sp
end

--]]

function drawparticle()

 for gl in all(particle) do
  spr(gl.s+gl.ani,gl.x,gl.y)
 end

end


function particleani()
 for gl in all(particle) do 
  if gl.ty=="sparkle" then
   gl.xv/=1.15
   gl.yv/=1.15
  
   gl.anitimer+=1
   
   if gl.anitimer==2 then
    gl.ani=1
   
   elseif gl.anitimer==4 then
    gl.ani=0
   elseif gl.anitimer==8 then
    gl.ani=1
   elseif gl.anitimer==12 then
    gl.ani=2
   elseif gl.anitimer==16 then
    gl.ani=1
   elseif gl.anitimer==20 then
    gl.ani=2
   elseif gl.anitimer>=32 then
    del(particle,gl)
   end
  end
  
  if gl.ty=="fast" then
   gl.anitimer+=1
   gl.xv/=1.01
   gl.yv/=1.01
   if gl.anitimer==8 then
    gl.ani=1
   
   elseif gl.anitimer==16 then
    gl.ani=2
   elseif gl.anitimer>=20 then
    del(particle,gl)
   end
  end
   
  if gl.ty=="drop" then
   gl.anitimer+=1
   gl.yv+=.1
   gl.xv/=1.05
   
   if gl.anitimer==2 then
    gl.ani=1
   
   elseif gl.anitimer==3 then
    gl.ani=2
   elseif gl.anitimer>=4 then
    del(particle,gl)
   end
  end
  
  if gl.ty=="drift" then
   gl.xv/=1.05
   gl.yv+=.05
   gl.anitimer+=1
   
   if gl.anitimer<0 then
    gl.yv-=.05
   end
   if gl.anitimer==2 then
    gl.ani=0
   
   elseif gl.anitimer==8 then
    gl.ani=1
   elseif gl.anitimer==16 then
    gl.ani=2
   elseif gl.anitimer==20 then
    gl.ani=1
    gl.horzflip=true
   elseif gl.anitimer==24 then
    gl.ani=0
   elseif gl.anitimer==28 then
    gl.ani=1
   elseif gl.anitimer==32 then
    gl.ani=2
   elseif gl.anitimer>=36 then
    del(particle,gl)
   end
  end
  
  
  
   if gl.sp==0 then
    gl.sp=rnd(1)-1   
    gl.xv=rnd(3.5)-1
    gl.yv=rnd(3.5)-1
    if gl.ty=="drift" and gl.yv>.5 then
     gl.yv/=-1
     if gl.yv<2 then
      gl.yv+=2
     end
    end
    gl.xv+=gl.sp
    gl.yv+=gl.sp
    gl.anitimer+=flr(rnd(20)*2/-1)
   end
   
   gl.x+=gl.xv
   gl.y+=gl.yv
   
 end


end
-->8
--- map ---


--- map vars ---

-- area stuff
area="night"

-- cloud
cloud={}

cloudrng=0
cloudcol=0
cloudcol2=0

-- lvlstuff
leveltimer=1
level=0
levelx=0
levely=0
levelcleartimer=0
iflevelstart=false
iflevelclear=false

function mapbackground()

 
 -- day
 if area=="day" then
  cls(12)
  rectfill(0,92+camy,1024,128+camy,1)
  rectfill(0,124+camy,1024,128+camy,0)
  cloudcol=7
  cloudcol2=6
 end
 
 -- sunset
 --[[if area=="sunset" then
  cls(10)
  rectfill(0,12+camy,1024,128+camy,9)
  rectfill(0,36+camy,1024,128+camy,8)
  rectfill(0,68+camy,1024,128+camy,2)
  rectfill(0,100+camy,1024,128+camy,1)
  cloudcol=1
  cloudcol2=0
 end]]
 
 -- night
 if area=="night" then
  cls(1)
  rectfill(0,92+camy,1024,128+camy,0)
  cloudcol=5
  cloudcol2=0
 end
 
 -- cave
 if area=="cave" then
  cls(0)
  rectfill(0,0+camy,1024,12+camy,1)
  rectfill(0,108+camy,1024,128+camy,1)
  rectfill(0,120+camy,1024,128+camy,13)
  cloudcol=6
  cloudcol2=5
  
  -- rom hack mushie spawners
  if leveltimer%100==1 and
     not iflevelclear  and
     #mob<30           then
     
   for i=0,63 do
    for i2=0,15 do
     for b=0,1 do
      if mget(i+(levelx/8),i2+(levely/8))==93+b then
       addsprout((i+.5)*8+levelx,(i2+.5)*8+levely,"chase",1)
       for a=1,20 do
        addparticle(i*8,i2*8+levely,6)
       end
      end
     end
    end
   end
  end
 end
 
 if area=="sky" then
  cls(12)
  rectfill(0+camx,0+camy,128+camx,12+camy,7)
  rectfill(0+camx,92+camy,128+camx,128+camy,7)
  rectfill(0+camx,116+camy,128+camx,128+camy,6)
  cloudcol=7
  cloudcol2=6
 end
 
 cloudfunc()
end


function levelthemes()

 if     level==1 then
  area="day"
  song=8
 elseif level==2 then
  area="night"
  song=9
 elseif level==3 then
  area="cave"
  song=8
 elseif level==4 then
  area="sky"
  song=10
 end

end






-- clouds, ya got to have em.
function addcloud(x,y,w,h,sp)

 cl={
  --position
  x=x,
  y=y,
  h=h,
  w=w,
  sp=sp
}
 add(cloud,cl)
 return cl
end


-- makes the clouds a reality!
function cloudfunc()
 -- determen amount
 if leveltimer==1 then
  cloudrng=ceil(rnd(3))+2
  
  -- caves have less clouds
  if area=="cave" then
   cloudrng-=4
  -- skys have more clouds
  --elseif area=="sky" then
   --cloudrng+=5
  end
  
 end
 
 -- add them in
 for cloud=0,16 do
  if cloudrng>=1 then
   addcloud(flr(rnd(140))-16,flr(rnd(48))+1,flr(rnd(16))+8,flr(rnd(6))+8,flr(rnd(2)+.5)+.3)
   cloudrng-=1
  end
 end

 
 -- cloud movement
 for cl in all(cloud) do
  cl.x+=cl.sp
  -- drawing them
  rectfill(cl.x+camx,cl.y+camy,cl.x+cl.w+camx,cl.y+cl.h+1+camy,cloudcol2)
  rectfill(cl.x+camx,cl.y+camy,cl.x+cl.w+camx,cl.y+cl.h+camy,cloudcol)
  
  if cl.sp>=2 and area=="cave" then
   cl.sp=2
  end
  
  if cl.x+camx>=160+camx then
   cl.x=-32
  end
  
  
 end
 
end



function levelstart()
 -- reset lvl timer /
 -- add to combined time
 combinedtime+=leveltimer
 leveltimer=0
 iflevelclear=false
 levelthemes()
 
 for cl in all(cloud) do
  del(cloud,cl)
 end
 
 
 -- set x & y
 levelx=512*((level-1)%2)
 levely=128*flr((level-3)/2)+128

 camx=levelx
 camy=levely
 
end


function levelend()
 levelcleartimer+=1
 if levelcleartimer==1 then
  song=3
  frozen=true
  powerupchoice=0
 elseif levelcleartimer==55 then
  s=5
 elseif levelcleartimer==65 then
  s=6
 elseif levelcleartimer==200 then
  levelcleartimer=0
  frozen=false
  iflevelclear=false
  s=1
  gamestate=1
  preptimer=0
  prepstate=0
 end
 ?combinedtime,camx,camy+80,7

end
-->8
---  gamestates ---

--- titlescreen
-- text / timers
titletimer=0
titleintro=true
textsway=0

-- creatures
titlemobspawnrng=0
titlemobrng=0
titlemobtimer=0

-- prep vars
preptimer=0
prepstate=0
prepani=0
prepanitimer=0

-- shop
shoptimer=0
shopoffset=0
menuselect=60
cost1=16
cost2=32
cost3=48

-- gameover
gameovertimer=0


-- prep screen 
function prepgame()
  
  preptimer+=1
  prepanitimer+=1
  
  if prepanitimer==8 then
   prepani=1
  elseif prepanitimer==16 then
   prepani=2
  elseif prepanitimer>=24 then
   prepani=0
   prepanitimer=0
  end
  
 if prepstate==0 then
  if preptimer==1 then
   level+=1
   if levelskip then
    level+=1
    levelskip=false
   end
   if coins!=0 then
    sfx(3)
    cls(0)
    ?"do you want to shop?",30+camx,camy+60,7
    ?"(Ž yes / — no)",38+camx,camy+70,7
   else
    prepstate=1
    preptimer=0
   end
  end
  
  if btnp(—) then
   prepstate=1
   preptimer=0
   sfx(3)
  elseif btnp(Ž) then
   prepstate=2
   preptimer=0
   sfx(5)
   song=5
  end
 end
 
 if prepstate==1 then
  cls(0)
  song=0
  if coins<99 then
   spr(34+prepani,54+camx,60+camy)
  else
   spr(37+prepani,54+camx,60+camy)
  end
  ?"x"..coins,62+camx,63+camy,7
  ?"level "..level,camx,camy,7
  if preptimer==100 then
   iflevelstart=true
   levelstart()
   gamestate=2
  end
 end
 
 -- shop screen
 if prepstate==2 then
  cls(0)
  
  shopoffset=sin(shoptimer/150)*2
  shoptimer+=1
  -- cursor
  rect(menuselect-1+camx,63+camy+shopoffset,menuselect+8+camx,72+camy+shopoffset,7)
  
  -- items
  spr(43+prepani,30+camx,camy+64+shopoffset)
  ?"x "..cost1,39+camx,camy+65+shopoffset,7
  spr(46+prepani,60+camx,camy+64+shopoffset)
  ?"x "..cost2,69+camx,camy+65+shopoffset,7
  spr(49+prepani,90+camx,camy+64+shopoffset)
  ?"x "..cost3,99+camx,camy+65+shopoffset,7
  
  -- ui
  ui()
  ?"(Ž to buy / press — to leave)",0+camx,120+camy,7
  
  if preptimer!=0 then
   if btnp(‘) then
    menuselect+=30
    --sfx(8) 
   elseif btnp(‹) then
    menuselect-=30
    --sfx(8)
    
   -- leaving
   elseif btnp(—) then
    preptimer=0
    sfx(4)
    prepstate=1
    
   -- buying
   elseif btnp(Ž) then
    if menuselect==30 then
     if coins>=cost1 then
      sfx(6)
      powerupchoice=1
      coins-=cost1
      preptimer=0
      prepstate=1
     else
      sfx(8)
     end
     
    elseif menuselect==60 then
     if coins>=cost2 then
      sfx(6)
      powerupchoice=2
      coins-=cost2
      preptimer=0
      prepstate=1
     else
      sfx(8)
     end
     
    elseif menuselect==90 then
     if coins>=cost3 then
      sfx(6)
      preptimer=0
      prepstate=1
      powerupchoice=3
      coins-=cost3  
     else
      sfx(8)
     end
    end
    
   end
  end
  
  if menuselect==30 then
   ?"health",camx,104+camy,8
   ?"this will give a extra hit!",camx,112+camy,8
  elseif menuselect==60 then
   ?"beam",camx,104+camy,10
   ?"shoot energy balls to fry foes!",camx,112+camy,10
  elseif menuselect==90 then
   ?"flag",camx,104+camy,11
   ?"skip a level if it's too hard.",camx,112+camy,11
  end
  
  -- cursor bounds
  if menuselect<30 then
   menuselect=30
   sfx(4)
  elseif menuselect>90 then
   menuselect=90
   sfx(4)
  end
  
 end
 
 


end














-- title screen
function title()
 if titletimer<9000 then
  titletimer+=1
 end
 if titlemobtimer!=0 then
  titlemobtimer-=1
 end
 
 if not titleintro then
  for i=0,1 do
   ?"coin dash romhack",30-i,42-i*2+sin(textsway/100)*(14-i*2)-i+camy,i*7
   --print("coin dash",44,40+sin(textsway/100)*12+camy,7)
   ?"press — to play",33-i,52-i*2+sin(textsway/100)*(12-i*2)-i+camy,i*7
   --print("press — to play",32,50+sin(textsway/100)*10+camy,7)
  end
  if textsway%5==0 then
   addparticle(flr(rnd(70))+30,flr(rnd(25))+35+camy,0)
  end
  if titlemobtimer==0 then
   titlemobspawnrng=flr(rnd(1000)+.5)

   if titlemobspawnrng<=3 then
    titlemobtimer=300
    titlemobrng=ceil(rnd(32))
    
    --[[if titlemobrng<=24 then
     addsprout(152,351,"simple",0) 
    elseif titlemobrng<=28 then
     addsprout(152,351,"chase",1)
    elseif titlemobrng<=31 then
     addsprout(152,359,"simple",4)
    else
     addsprout(152,304,"simple",2)
    end]]
   end
  end
  
  if titlemobtimer==0 then
   for m in all(mob) do
    del(mob,m)
   end
   
  end
  
 end
 
 if leveltimer==1 then
  if (highscore>=99) area="day"
  leveltimer=0
 end
 
 if not titleintro then
  if (titletimer>=9000 and highscore>=99) ifgold=true
  if btn(—) then
   gamestate=1
   for m in all(mob) do
    del(mob,m)
   end
   for o in all(obj) do
    del(obj,o)
   end
   for cl in all(cloud) do
    del(cloud,cl)
   end
   for par in all(particle) do
    del(particle,par)
   end
   
  end
 end
 
 if textsway<=70 or not titleintro then
   textsway+=1
 end
  
 if titletimer<=150 then
  ?"a smelly production",26,128-textsway+camy,7
 end
 if textsway==68 then
  sfx(5)
  for i=0,16 do
   addparticle(flr(rnd(70))+30,60+camy,0)
  end
 elseif titletimer==150 then
  texty=0
  sfx(3)
  for i=0,150 do
   addparticle(60,60+camy,3)
  end
 elseif titletimer==210 then
  sfx(7)
  titleintro=false
  for i=0,250 do
   addparticle(rnd(128),rnd(128)+camy,3)
  end
 elseif titletimer==220 then
  song=2
 end
end  








-- gg mate, hope there's tasty
-- food down there in their pit!
-- :p
function gameover()
 gameovertimer+=1
 if gameovertimer==1 then
  cls(7)
  if minihighscore>highscore then
   highscore=minihighscore
   dset(1,highscore)
  end
  
  for par in all(particle) do
   del(particle,par)
  end
  
 elseif gameovertimer==20 then
  cls(15)
 elseif gameovertimer==25 then
  cls(6)
 elseif gameovertimer==30 then
  cls(5)
  song=4
 elseif gameovertimer>=38 then
  cls(0)
 end
 if gameovertimer>=75 then
  for i=0,1 do
   i*=4
   ?"press — to try again",20+camx,74+camy-i+sin(gameovertimer/150)*(4+i*.75),1+i
   ?"press Ž to quit",28+camx,90+camy-i+sin(gameovertimer/150)*(4+i*.75),1+i
   ?"score:"..minihighscore,41+camx,120+camy,5
  end
  if     btn(—) then
   ifreset=1
   dset(0,ifreset)
   run()
  elseif btn(Ž) then
   run()
  end
  
 end
  ?"gameover",44+camx,56+camy,7
end
-->8
-- credits, music, savedata.. --
creditsflag=false
score=0
combinedtime=0
--highscore=0
minihighscore=0
--ifnocoin=""
--besttime=0
sec=0
minute=0
nodeath=0
--ifsong=false


-- yay for me
function credits()
 if level==4 and camx>=824+64 then
  if not creditsflag then
   combinedtime+=leveltimer
   creditsflag=true
   sfx(7)
   
   -- set stats
   score=coins+nodeath+16
   if (minihighscore==0) ifnocoin=1
   
   for i=combinedtime%30,combinedtime do
    sec=flr(combinedtime/30)
   end
   for i=combinedtime%3600,combinedtime do
    minute=flr(combinedtime/1800)
   end 
   
  end
  
  if rescost==0 then
   nodeath=16
  end
 
  if score>highscore then
   highscore=score
   dset(1,highscore)
  end
  
  if combinedtime<besttime or
     besttime==0 then
     
   besttime=combinedtime
   dset(2,besttime)
  end
  dset(4,ifnocoin)
 end
 
 if creditsflag then
   
  ?"score:",120*8+2,18*8+1,7
  ?score,120*8+28,18*8+1,10
  ?"time: "..minute..":"..sec-minute*60,120*8+2,19*8+1,9
 
 
  ?" credits ",120*8+2,21*8,7
  ?"made by smelly",120*8+2,22*8,7
  ?"thanks to marsh",120*8+2,23*8,7
  ?"for playing this",120*8+1,24*8,7
  ?"garbo.  :p",120*8+2,25*8,7
 end


end

function songs() 
 -- turn off music
 if     song==0 or ifsong==1 then
  music(0)
 -- title theme
 elseif song==2 then
  music(1)
 -- level clear
 elseif song==3 then
  music(9)
 -- gameover
 elseif song==4 then
  music(10)
 -- shop / credits
 elseif song==5 then
  music(12)
 -- ground1
 elseif song==6 then
  music(21)
 -- flash
 elseif song==7 then
  music(31)
 -- ground2
 elseif song==8 then
  music(33)
 -- underground
 elseif song==9 then
  music(39)
 elseif song==10 then
 -- ground3
  music(41)
 end
 
 -- only run music once
 if song!=1 then
  song=1
 end


end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000b303b000000000000eee00000eee00000eee000000000000000000
0000000006777770067777700677777006717710067777700617717000b303b000b303b00b00300b0000000000e2222000e22220000e22000000000000a909a0
007007000671771006717710067177100671771767177717061771700b00300b0b00300b0000300000000000000020000000200000e22220000000000a00900a
0007700006777770067777700677777006777770067171706777777700999900009999000099990000000000004444000044440000002000000000000077aa00
00077000677777776777777767777777067777700677777006777770099144100991441009914410000000000411511004115550004441100000000007a29920
00700700067777700677777006777770677777700677777006777770094444400944444009444440000b0b00045555500455511004115550000eee000a999990
00000000067777700677777706677770067777770677777006777770094444400944445dd54444400000300004555550d15555500555551d00e222200a999990
00000000060000700600000000000070060000000600007006000070d500005dd50000000000005dd441441dd100001d0000001dd1000000d511511d94000049
0000000000a909a000000000000d0d00000d0d00000a090000000000000000000000000000b303b0000000000000000000000000000000000000000000070000
00a909a00a00900a0000000000d505d000d505d000a505900000000000b303b000b303b00b00300b000000006607171600077700660777666607171600777000
0a00900a0000900000000000000050000000500000005000000000000b00300b0b00300b000030000000000006671aa006671aa006671aa006671aa007777700
0077aa000072aa2000000000002ddd20002ddd20020ddd0200150510008e8e80008e8e80008e8e8000000000077779aa667779aa077779aa077779aa07776600
07a2992007a29920000000000d2555110d2555110d25559a00015100099144100991441009914410000b0b007777009a7777009a7777009a0777009a00766000
0a9999900a999990000a0a000d5555110d5555110d55559900dddd00094444400944444009444440000030000000000000000000000000000070000000000000
0a99994994999990000090000d5555d00d5555d66d5555d00d115511094444400944445dd5444440008e8e800000000000000000000000000000000000000000
94000000000000494aa2a9246d0000d66d000000000000d66d555511d500005dd50000000000005dd441414d0000000000000000000000000000000000000000
00000000000000000000000000777700000000000000000000777700000000005dddddd55dddddd56dddddd62eeeeee22eeeeee27eeeeee74999999449999994
0007000000070000007777000777777000aaaa00007777000777777000eeee00d555555dd111111dd111111de888888ee228822ee888888e9aa4aaa99a4aaaa9
0077700000777000077aaaa0077aa7a00aa99990077eeee0077ee7e00ee88880d111111dd555555dd111111de228822ee222222ee228822e9aa44aa99aa44a49
007770000077700007a99a90077a77a00a94494007e88e80077e77e00e822820d111111dd111111dd555555de222222ee222222ee222222e9a4444499a4444a9
077776000777760007a9aa90077a77a00a94994007e8ee80077e77e00e828820d111111dd111111dd555555de222222ee822228ee222222e944444a99a4444a9
077766000777660007a9aa90077777a00a94994007e8ee80077777e00e828820d111111dd555555dd111111de822228ee882288ee822228e9aa44aa994a44aa9
007660000776660007aaaa9000aaaa000a99994007eeee8000eeee000e888820d555555dd111111dd111111de882288ee888888ee882288e9aaa4aa99aaaa4a9
00000000006660000099990000000000004444000088880000000000002222005dddddd55dddddd56dddddd62eeeeee22eeeeee27eeeeee74999999449999994
79999997311111133111111371111117000bb0000bb0000000000b3000088000088000000000082000000000000000000000000000a000000070070000000a00
9aaaa4a91bbbbbb11bbbbbb11bbbbbb10bb33b30033bbb300bbbb330088228200228882008888220000000000077ee000077ee0000000a000000000000a00000
94a44aa91b3333b11bbb33b11b33b3b10333333003333330033333400222222002222220022222400077ee0007eee22007eee220090aa00aa0077007900aa0a0
9a4444a91b3333b11b3333b11b3333b103300340000333400333304002200240000222400222204007eee2207ee222220ee222200099aa0000aa77000099aa00
9a4444a91bbbb3b11b33b3b11bbb33b10000004000000040000000400000004000000040000000407ee22222ee2222227e22222200999a0000aaa70000999a00
9aa44a491bbbb3b11bbbb3b11bbbb3b1000000400000004000000040000000400000004000000040ee222222000d1000ee0d1022900990a0a00aa0070909900a
9a4aaaa91bbbbbb11bbbbbb11bbbbbb1000000400000004000000040000000400000004000000040000d1000000d1000000d1000009000000000000000000900
7999999731111113311111137111111700000040000000400000004000000040000000400000004000d1110000d1110000d111000000090000a00a0000900000
24444444bbbbbbbbbbbbbbbbbbbbbb8b00000000000000000000000000bb03303300330000094330bbbbbbb30009400000094000444444444444444004444444
24444444b33bb33bbbbbbbbbbebbb8a800000000000000003300330033bb333333b33333bb3333b3b33333330009400000094000444444444444440000444444
2444444434433443b33bb33beaeb9b8b000b333333bb300033333b333333333b33333333bb333333b33333330009400000094000444444444444400000044444
244444442444444434433443be39a93b00333b3333bb33003333333333333333333333b333333333b33333330009400000094000444444444444000000004444
244444442444444424444444344394430333333333333330333bb33333333333b3333333333b3333b33333330009400000094000444444444440000000000444
2444444424444444244444442444444403333bb3333333303b3bb3333333333333333bb333333333b33333330009400000094000444444444400000000000044
2444444424444444244444442444444433b33bb33b333333333333333b33bb3333333bb333bb333b333333330094400000094000444444444000000000000004
22222222222222222222222222222222b3333333333333b3333333b33333bb333333333333bb3333000940000044440000094000444444440000000000000000
000000000000000044444444444440046666666666666666dddddddd1ddddddd1ddddddd0000000000000000000000000000000011111111000000e000000000
40000000000000044444444440044004155555551665566515555555155555dd1dd55555000000000000000000000000000000002211112200e0002000000000
44000000000000444444000440044444155555551555555515555555155555dd155555dd000000000000000000000000000000002222222e0020ee2000000000
4440000000000444444400044444444415555555155555551555555515555555155555dd00000000000000000000000000000000e2e2e220ee202e2e00000000
4444000000004444444400044444000415555555155555551555555515dd55551555555500ee00000000000008000e000d000800eee20220e22e2e2200000000
4444400000044444444444444444000415555555155555551555555515dd55551555dd550e2220e0000e00008a80eae0dad08a8000ee02e02222222200000000
44444400004444440044444444440004155555551555555515555555155555551555dd5500010e2200e220000800be000db0080000000ee02211112200000000
44444440044444440044444444444444111111111111111111111111111111111111111100110010000100000b00b00000b00b00000000001111111100000000
00000000000940000000000000000000000000000094440044444444aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000
00000000099949900990099009900990099009900094440044444444499449940009000000000000000000000008000000000000000000000000000000000000
0000000009494940094009400940094009400940009444004444444444444444000a0000000a000000000000000e000000080000000000000000000000000000
000000009949994909499949994999499949994000944400444444444444444409a7a90000a7a000000a000008e7e800008e8000000800000000000000000000
0000000044444444044444444444444444444440009444004444444444444444000a0000000a000000000000000e000000080000000000000000000000000000
00000000044944400440044004400440044004400094440044444444444444440009000000000000000000000008000000000000000000000000000000000000
00000000044444400440044004400440044004400044440044444444444444440000000000000000000000000000000000000000000000000000000000000000
00000000044444400440044004400440044004400022220022222222222222220000000000000000000000000000000000000000000000000000000000000000
00000000070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111116666666677777777
00000000707070700000000000000000000000000000000000000000000000000000000000000000000e000000000000000000001dd11dd11dd11dd17000000c
000000000707070700707000000000000000000000000000000000000000bb30003000000000000000e2200000020000000000001dddddd11dddddd17077000c
0000000070707070000707000007070000444000000000000000000000bbb30000b300000003bb0000020000002210000002000011dddd1111dddd117070000c
000000000707070700707000000000000044400000044000000000000bb33000000b300000003bb000010000000100000001000011dddd1111dddd117000000c
0000000070707070000707000007070000fff000000ff000000f000000000000000bb000000000000000000000000000000000001dddddd11dddddd17000000c
00000000070707070000000000000000000000000000000000000000000000000000b000000000000000000000000000000000001dd11dd11dd11dd17000000c
000000007070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111111cccccccc
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000a4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c4000000000000000000a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c4000000000000a40000c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c4000000000000c40000c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c4000000a400c5b4b500c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c4000014143424241424c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
36464494846404040404040404c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
142424341424240404040404049454c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404141424342414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000777777777777777777777777777777770cccccc00cccccc0000000000000000000000000
0000000000000000000000000000000000000000000000000000000077ccc777777cccc77777777777777777c777777cc777777c0000cccccccc000000000000
000000000000000000000000000000000000000000000000000000007c777c7777c7777c77cc7777777777777777777777777777cccc77777777cccc00000000
000000000000000000000000000000000000000000000000000000007c7777777777777c7c7777777777777777cc777777777777c77777777777777c00000000
000000000000000000000000000000000000000000000000000000007777777777cc777777777777777777777c777cc777777777c77777777777777c00000000
000000000000000000000000000000000000000000000000000000007777cc777c77c777777cc777777777777777777c77777777c77777777777777c00000000
00000000000000000000000000000000000000000000000000000000777777c77c77777777777c77777777777777777777777777777777777777777700000000
00000000000000000000000000000000000000000000000000000000777777777777777777777777777777777777777777777777777777777777777700000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101606060606060014040808080808080800101010101808080804040000040404040808080000000000000000000000000000000000000000000010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101010101010100
__map__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404040000000000000000000000000004a00000000000000000000000000000000000000000000000000000000004a0000000000000000000000004a00000000000000
0000000000000000000000000000004a0000000000000000000000000000000000000000000000000000000000000000000000000000000000004a000040404000000000000000000000000044494745000000000000000000000000000000000000000000000000004446414200000000000000000044474941420000000000
0000000000000000000000000000004c0000000000000000000000000000000000000000000000000000000000000000000000000000000000004c25004d40400000004a000000000000004441424241000000000000000000000000000000000000000000000000414242414000000000000000000041424241400000000000
0000000000000000000000000000004c0000000000000000000000000000000000000000000000000000000000000000000000000000000000004b00514d40400000004c000000000000424242414040000000000000000000000000000000000000000000000000404040404e0000000000000000004d404040403400000000
0000000000000000000000000000004b0000000000000000000000000000000000000000000000000000000000000000000000000000000000414141534d40404745004b0000000000004040404040400000000000000000000000000000000000000000000000004d404040000000000000000000004f4d4040414217000000
0000000000000000000000000000004141420000000000000000000000000000000000000000000000000000000000000000000000004a00414040404d4d4d4041424241000000000000004f4d40404d0000000000000000000000000000000000000000000000004f56565600000000000000000000004d4040404141000000
00000000000000000000000000000040404000000000222222000000000000000000000000004a0000000000000000000000000000004c0040404d4d4d4e00004040414241000000000000514d4d4d4e000000000000000000000000000000000000000000000000007f137f00000000000000000000004f5656564040000022
000000000000000000000000175b00404040000000004342415c00000000000000005c4a00004c000000000000004a0000000000001b4c004d4d4d4e00000000404040404d0000000000004d4d4d0000000000000000000000000000000000000022000000000000005655560000000000000000000000007f137f4e00000022
00000000000000000000004243410040404000000000404040410000000000000000414200004c0000004a0000004c000000000000004c00524d4d003400555440404d4d5350000000004d4d4d4d0000000000000000000000000000000000002200003a00000000000000000000000000000000000000005655560000000022
000000000000002222220040404000404040004a0000404040400000000000000000404041004c0000004c0000004c000000000000004c514d4d4d54555456564d4d4d4d4d4d0000005152232323500000000000000000003a000000000000220000514d000000000000000000003a000000000000000000000000000000003a
000000000000005c175b0040404051404d4d004c00514d4040400000000000000041424040004c0000004c0000004c002222224a5b004b414254545656565856524d4d2323235000004d4d4d4d4d4d5000000000000000004d0000000000000000004d4d500000000000000000004d500000002200000000000000000000004d
0000000000004241424100404040524d4d4d504c004d4d4d534d000000000000004f1c4040004b5b075c4b0000004c00444748424143414140404057565656404d024d534d4d4d00514d54555555544d003a0000000000004d50000000003a0000514d4d4d0000000000000000004d4d0000000022000000000000000000514d
00010044484740404040004d52404d4d4d4d4d4d4d4d524d4d4d50000000000000004d534d0041424342424100004c5141424341404040404040404040404040545555555459285a5456565658565655545500000000000000000000000000000000000000000000000000000000000000000000002200000000000000003a00
42414241414241404040514d4d4d4d4d2323234d4d4d4d08524d4d000000000000004f4d525040404040404d00004c4f4d40404040404040404040404040404056565856565455545656565656565656565600000000000000000000000000000000000000000000003a00000000000000000000000000000000000000000000
404040404040404040404d534d4d4d4d53084d4d41414141414d4d53505b00000000004d424243414040534e00004c004d4040404040404040404040404040405856565656565656565657565656565656560000000000000000000000000000000000000000000000000000000000000000000000003a000000000000000000
4040404040404040404041414141414141414141414040404041414342420000000000414040404040404d0000004c004f4d4040404040404040404040404040565656575656565656565656565656585656000000000000000000000000000000000000000000000000000000000000000000000000000000003a0000000000
5656585600000057565656565657565656575657565657565656575658565656565657565600565656565756565656565656565656575656565656565658565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5656565700000000565756565656565656565656565656565656565656565656565656564e00565657565656565656565657565656565658565756560056565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006767676767676767
56565600000000005656565756565657565658565657565656565756565756565856565600004f4d4d524d56565657565656565656565657565656560000565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666666666
575600000000514d56565656575656565656565656565656585656565656564d4d4d524e000000004f4d4d56565656565656565856565656565656000051585600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666666666
565650514d524d4d53565856565656565856565656565656565656565756564d534e000000002222224f4d4d565656575656565656565656565856000056565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666666666
5657534d4d4d4e004f5656575656565656565657565656574d4d4d565656564d4e0000000000000000004d524d4d56565656575656585656565656595156565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666666666
56584d4e00000000005656565656585656565656565656564d4e4f565d565600000000000000000000004f4d4d4d4d4e4f4d4d565d565657565656564f4d565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666666666
565600000000000000004f4d5656565656524d56565756574d00000000000000000000000000005e5a00004d4d530000004f524d0000565656565658004f5758000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001b00000000001b0000006666666666666666
575600000000000000000052575d564d4d4e004f535656564e0000000000000000000000000055545400004d4d4e000000004d4e0000565d5656000000005656000000000000000000000000000000000000000000000000000000000000000000000000000000000000001b0000000000000000000000006666666666666666
565659015a0000000000004f5600564e000000004f565d56000000000000005a00005900005956565800514d4d0000000000000000000000524d00000000005600000000000000000000000000000000000000000000000000000000000000007e7e000000000000000000000000000000000000000000006666666666666666
56585554550000222222220000000000222222000000000000000000005455555455545455545657565a4d534d505a5e59000000000000004d4d0000345a5e54000001000000000000000000000000000000000000000000000000000000007e7d7d000000000000000000000000000000000000000000006500000000000065
56565656560000595a2859005a00590000000000005a5900005a0000005656585656565656565656565555545455545555222222000000004f4d5000555455560041424100000000000000000000000000000000006263636364176263647e7d7d7d000000000000000000000000000000000000000000006500000000000065
5856565656545455555454555555545500000000005454555554002800575656565656565756565656565657565656565600005a00000000004d5354565658560040404063636364000000000017000000000000fdfcfcfbfcfcfcfcfcfbfaf8fafa000000000000000000000000000000000000000000fcfbfcfe000000fcfb
5656565656575656565656575656565800000054555656575656545554565656565756565656565756565656565657565854545500000000004f4d575656565641404041424241420007fdfcfcfbfcfe00170000fafaf8fafafafaf9faf7fafafafa000000000000000000000000000000000000000000f7fafafafcfdfcf9fa
565658565656565656585656565656560000005756565856565657565656585756565656565856565656565656565656565656565000000000005256565656574040404040404040fbfcfaf7faf9fafafcfe0000fafafafaf8fafafafafafafafafa000000000000000000000000000000000000000000fafaf9fafafaf8fafa
57565656565656575656565656565856000000565756565657565656585656565656575656565656565656575656585656565656524d500000004f56575656564040404040404040fafaf8fafafafafafaf80000faf9fafafafaf9fafafaf9fafafa000000000000000000000000000000000000000000faf8fafafafafafaf9
__sfx__
000505081f0301f5401f5401f5401f5421f5401f5421f540005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000a04081803018540185401854018540185421854018542005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00100000118550e8550c85513855158550c8550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000e00000000000001a0101c0101c0101c0101e010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000003201024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002b01030010340150000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002f01034010380150000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000250511d0411a041170211502114021130211202111021100210f0210f0210f0240a100091010710107101061010510102104000000000000000000000000000000000000000000000000000000000000
0007000012041120410d0310803105021000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000000500001080211c0511d0511c0511a04117041130310d02105011000110001100011000110001100013000000000000000000000000000000000000000000000000000000000000000000000000000
00040000100351b0412304137051380513705135041320412e041280312003119031100210b021070210101100013000000000000000000000000000000000000000000000000000000000000000000000000000
00060000055120a5210f52115531195311953118541175411654114531115310d5310952106521005140050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00040000206132a620396203f6203c620376212c621236111a6111661113611106110e6110c6110a6110961107611006110061100611006110061101601016010160500000000000000000000000000000000000
000400000551106511095110d51112511175111d511235112a5113151135511355130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000315104151041510515107151091510d15110151101511015110151115511255112551135511355112555181011010105101031030000000000000000000000000000000000000000000000000000000
00040000096131361022610236102361020611156110c611036110061100611006110061100611006110061100611006110061100611006110061100601006010060500600000000060000600000000060000000
001000001d8401d8311d8211d8111d815185001850018500219402193121921219112191500000000000000021840218302192021810219102181121911218111d8001d8001d8001a8001a8001a8001a8001a800
0010000821555000001f5511d55500000185000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000081f555050001d5511c55500000185000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000101a56505000185511d565000001a5711a5751a5751a5651a5651a5651a5511855518555185551856300000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001c215052001a2211f235002001c2111c2251c2351c2351c2351c2351c2311a2251a2251a221122131c215052001a2211f235002001c2111c2251c2351c2351c2351c2351c2351c2311c2313224137253
001000101c215050001a2211f235000001c2111c2251c2351c2351c2351c2351c2311a2251a2251a2251a21300000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00001f645156350000015635000001763500000186251a0531f0431f0331f0232101321013210132101321013210132107521013210552100021035210002101500000000000000000000000000000000000
000f000013051150520000015052000001705200000180521a0511f0521f0421f0322102221022210222102221012210150000000000000000000000000000000000000000000000000000000000000000000000
000f00001a2251a2251a2251a2251c2251c2251c2251c2251a2211f2221f2221f2222122221232212322123221242212450000000000000000000000000000000000000000000000000000000000000000000000
000f00001a8351a8351a8351a8451c8451c8451c8451c8451a8411f8411f8421f8422185221852218522186221862218651a10000000000000000000000000000000000000000000000000000000000000000000
002000100755007542000000755007542000000454005550000000754200000075400000004542055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000100b5500b542000000b5500b542000000755009540000000b542000000b5400000007552095400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000000752207522075220752207522075220752207522075220752207522075220752207522075220752205522055220552205522055220552205522055220952209522095220952209522095220952209522
0020000009522095220952209522095220952209522095220b5220b5220b5220b5220b5220b5220b5220b52209522095220952209522095220952209522095220952209522095220952207522075220752207532
002000100750009543000000552307500000000552309543000000552300000055230000004500095430000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100008116250560011625106001d64310625115001d800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100008116250560011625106001d643106251f1731f100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000081d8241f830218250e2001a8241d8301f92511800119001390015900152001520015200152001720000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000081f81421820188301d855208001d800188001d8001d800188001d800188001d8001d800188001d80000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001d1441d1421d1421d1421d1411c1441c1411c1421c1421c1421c1411a1441a1421a1421a1411c1441c1421c1421c1421c142001000010000100001000010000100001000010000100001000010000100
000400001f1441f1421f1421f1421f1411d1441d1411d1421d1421d1421d1411c1441c1421c1421c1411d1441d1421d1421d1421d142001000010000100001000010000100001000010000100001000010000100
000400001f1441f1421f1421f1421f1412114421141211422114221142211411a1441a1421a1421a1411d1441d1421d1421d1421d142001000010000100001000010000100001000010000100001000010000100
0004000021144211422114221142211411a1441a1411a1421a1421a1421a1411c1441c1421c1421c1411f1441f1421f1421f1421f142001000010000100001000010000100001000010000100001000010000100
00100008116350560011635106001d653106353713237133000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000041305315055170550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000041305317055130551100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001755500000175450000000000175350000000000175250000000000175150000000000000001751500000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000024822248222482224822248122481224811248151f8221f8221f8221f8221f8121f8121f8111f81517800178001780017800178001780017800178001d8001d8001d8001d8001d8001d8001f8001f800
0010000017822178221782217822178121781217811178151d8221d8221d8221d8221d8221d8221f8221f82200000000000000000000000000000000000000000000000000000000000000000000001563315655
0020000024225242252422524222242122421224211242151f2251f2251f2251f2221f2121f2121f2111f21517200178001780017800178001780017800178001d8001d8001d8001d8001d8001d8001f8001f800
00100020076110d61011610146101662017620186201862017610146100d6100b6100c6100e61012610166101a6101b6201d6201d6301d6301d6201a62017610146101261012610156101662015620116200a621
001000081c2251d8001c6001f22521235182251a8001a8001f8001d8001a8001c8001f8001d8001a8001a8001f8001d8001a8001c8001f8001d8001a8001a8001a8001a8001a8001a8001a8001a8001a8001a800
001000200061100610006100261004610056100661006610056100261000610006100061000610006100461008610096100b6100b6200b6200b61008610056100261000610006100361004610036100061000611
001000081f2251d8001c6002122526235242251a8001a8001f8001d8001a8001c8001f8001d8001a8001a8001f8001d8001a8001c8001f8001d8001a8001a8001a8001a8001a8001a8001a8001a8001a8001a800
001000001d8411d8311d8211d8111d8111d8111d8111d8111d8111d8111d8211d82500000000001a8411a8311a8211a8111a8111a8111a8111a8111a8111a8111a8211a8251a8001a8001a8001a8000000000000
001000041322515225102210e22517200172001720017200152001520015200152001520015200152001720000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002421124212242122421224212242122421224212232112321223212232122321223212232122321226211262122621226212262122621226212262122921129212292122921229212292152921529215
00100010212150a0001f2212423505000212112121521225212252123521235212311f2251f2251f2151f21305000050000500005000050000500005000050000000000000000000000000000000000000000000
001000081f2151d8001c6002122526225242151a8001a8001f8001d8001a8001c8001f8001d8001a8001a8001f8001d8001a8001c8001f8001d8001a8001a8001a8001a8001a8001a8001a8001a8001a8001a800
004000002da5529a550ea000ca0026a552ba55188541884118841188311882118815000002da5529a55000000000026a552ba551c8541c8411c8411c8311c8211c81121854218412183121821218152180000000
001000101f625000001c615000001f6152162500000000001f625000001c6151d600236131c625000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000101f6151f6151f6151a2001f6151f6151f615000001f6151f6151f6151d6001f6251f625371250000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040000030a5529a550ea000ca0028a5529a551885418841188411883118821188150000030a5535a55000000000032a5537a551c8541c8411c8411c8311c8211c81121844218512183121821218152180000000
001000101f2351f2251f2251a2251f2112121500000000001f235000001c2251d600232231c215000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000042d625000002b6150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000042d635000002b6251d62300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000021841218312182121811218112181121811218112181121811218212182500000000001f8411f8311f8211f8111f8111f8111f8111f8111f8111f8111f8211f8251a8001a8001a8001a8000000000000
0010000021241212312122121211212112121121211212112122121221212312124500000000001f2411f2311f2211f2111f2111f2111f2111f2211f231222312824137253376531a8001a8001a8000000000000
__music__
00 41 42 43 44
00 10 11 43 44
01 10 11 43 44
00 10 12 43 44
00 10 12 43 44
00 10 11 13 15
00 10 11 13 15
00 10 12 13 15
02 10 12 13 14
04 16 17 18 19
01 1a 1e 1c 44
02 1b 1e 1d 44
01 1f 42 43 44
00 20 21 22 23
00 20 21 22 24
00 20 21 22 23
00 20 21 22 24
00 20 21 22 25
00 20 21 22 26
00 20 21 22 25
02 27 21 22 26
00 28 2a 43 44
01 29 2a 43 44
00 28 2a 2b 44
00 29 2a 2c 44
00 28 2a 2b 44
00 29 2a 2c 44
00 28 2a 2b 2d
00 29 2a 2c 2d
00 28 2a 2b 2d
02 29 2a 2c 2d
01 2e 30 31 44
02 2f 32 31 44
00 1f 33 43 44
01 1f 33 15 34
00 1f 33 35 34
00 1f 36 15 34
00 1f 36 35 34
02 1f 33 36 44
01 41 38 37 39
02 3b 38 3a 39
00 2e 42 43 44
00 2f 30 43 44
00 2f 42 43 44
00 31 42 43 44
01 2f 32 3c 44
00 31 32 3c 44
00 2f 32 3c 44
00 31 32 3d 44
00 2f 3e 3d 3f
02 31 3e 3d 3f
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
