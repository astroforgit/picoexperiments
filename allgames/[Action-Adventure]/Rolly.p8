pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--rolly
--by davbo and rory

function _init()
 --constants
 pixel=0.125
 
 --collision offset
 coloffset=0.001
 
 jumpframesoffset=5
 
 --jump physics consts
 airgravity,airtvel=0.04,0.45
 wallgravity,walltvel=0.02,0.275
 
 currentgravity=airgravity
 currenttvel=airtvel
 
 --checkpoint
 
 --keep hub
 xcp=63
 ycp=26
 
 cpanim=makeanimt(10,5,4)

 --avatar
 av={
  --movement consts
  xgroundacc=0.025,
  xgrounddecel=0.4,
  xairacc=0.02,
  xairdecel=0.9,
  
  xmaxvel=0.2,
  xrollmaxvel=0.25,
  xcurrentmaxvel=xmaxvel,
  
  yjumpforce=0.4,
  ywalljumpforce=0.46,
  
  maxstickframes=8,
  maxjumpframes=10+jumpframesoffset,
  
  --width and height consts
  w=pixel*8,
  h=pixel*8,
  
  --hitradius for game object
  -- circle colision
  r=pixel*4,
  
  --non-resetting vars
  inventory="none"
 }
 
 --death reset vars
 avreset()
 
 --creates based on x,y,h,w
 updatehitboxes()
 
 --game objects
 switches={}
 switchesanim=makeanimt(114,2,15)
 
 keys={}
 keysanim=makeanimt(45,5,4)
 keysflipped=false
 
 exitorbs={}
 
 --check map and convert
 -- to game objects
 for x=0,127 do
  for y=0,63 do
   if checkflag(x,y,4) and
      checkflag(x,y,5) then
    createswitch(x,y)
    mset(x,y,0)
   end
   
   if checkflag(x,y,4) and
      checkflag(x,y,6) then
    createkey(x,y)
    mset(x,y,0)
   end
   
   if not checkflag(x,y,4) and
      checkflag(x,y,5) and
      not checkflag(x,y,6) then
    local orb={
     x=x,
     y=y
    }
    add(exitorbs,orb)
   end
  end
 end
 
 --crumble blocks-tab 4
 initcbs()
 
 --backgrounds-tab 5
 initbgs()
 
 playingtune=""
 
 xmap,ymap=2,0
 lockcamera=false
 
 --swap these out for states
 currentupdate=updateintro
 currentdraw=drawintro
 
 --comment this...
 initintro()
 
 --...and uncomment these three
 -- to skip intro
 --currentupdate=updateplaying
 --currentdraw=drawplaying
 --menuitem(1,"reset to hub",avpausetohub)
 
 --stats for end screen
 deaths=0
 milliseconds,seconds,minutes,hours=0,0,0,0

	playendingtune=false
 musictimer=0
 musicnext=0
 
 ylogo=19
 ylogovel=0
 logocounter=0
 
 --y pos for orbs
 yorboffset=0
 ycen=0
 
 friends={}
 friendsanim=makeanimt(99,2,2)
 prevreactions={}
end

function _update()
 yorboffset=sin(milliseconds/30)*1.5
 ycen=26.2*8+yorboffset

 currentupdate()
end

function updateplaying()
 updateplaytime()
 updatecamera()
 updatesfx()
 
 if not av.warping then
  if inhub() and
     not inhub(xcp,ycp) then
   --reset prev
   mset(xcp,ycp,9)
   xcp,ycp=63,26
  end
  
  --needs to be before input
  updatespikecollision()
 end
 
 if not av.warping then
  if av.pauseanim=="none" or
     av.pauseanim=="squish" then
   updateinput()
  end
 
  updatecbs() --tab 4
  updatecollision()
  updateav()
 end
 updatefriends()

 updatehitboxes()
 updateanim()
 
 --if turning kick up dust
 -- #lastminute #throwitwherever
 if av.anim.basesprite==78 then
  initdustkick(sgn(av.xvel),-0.7,
   0.5,1,
   1,1)
 end

 updatekeys() --tab 4
 updatebgs() --tab 5
 updateparticles() --tab 6
 updatemusic()
end

function updateplaytime()
 milliseconds+=1
 
 if milliseconds==30 then
  seconds+=1
  milliseconds=0
  if seconds==60 then
   minutes+=1
   seconds=0
   if minutes==60 then
    hours+=1
    minutes=0
   end
  end
 end
end

function updatecamera()
 if (lockcamera) return

 --screen by screen
 -- don't allow camera off map
 if av.x>0 and av.x<127 then
  xmap=flr((av.x+av.w*0.5)/16)
 end

 if av.y>0 and av.y<63 then
  --boost if moving up a screen
  local ytempmap=flr((av.y+av.h*0.5)/16)
  if ytempmap<ymap then
   av.yvel=-av.yjumpforce
  end
  
  ymap=ytempmap
 end

 --focus on centerpiece
 if av.x>55.5 and av.x<71.5 and
    ymap==1 then
  xmap=3.5
 elseif inhub() and logocounter>=0 then
  --logo fly off
  logocounter=160
 end

 camera(xmap*128,ymap*128) 
end

--some sfx require releasing
function updatesfx()
 --dont interupt cutscenes
 if (av.pauseanim!="none") return

 --warping
 if av.warping and
    av.playingsfx=="none" then
  av.playingsfx="warping"
  sfx(45,2)
 end
 
 if --warping
   not av.warping and
   (av.playingsfx=="none" or
   av.playingsfx=="warping") then
  av.playingsfx="none"
  sfx(-2,2)
 end
 
 --walking sfx
 if (av.rolling=="none" or
    av.rolling=="jumping") and
    av.onground and
    not av.warping then
  if av.xvel!=0 then
   walksfx()
  else
   releasesfx()
  end
 end
 
 --release various sfx
 if --stop walking
   not av.warping
   and
   (not av.onground
   and
   (av.playingsfx=="whub" or
   av.playingsfx=="wcave"))
   or --stopped ground roll
   (av.rolling!="ground" and
   av.playingsfx=="ground") then
  releasesfx()
 end
end

function updatespikecollision()
 --spikes
 if spikecol() then
  releasesfx()
  avsfx(25)
  deaths+=1
  initdeath() --particles
  av.warping=true
  av.yvel,av.xvel=0,0
  if (av.inventory=="tempkey") keyreset()
 end
end

function updateinput()
 --roll
 if btnp(—) then
  if av.rolling!="air"
     and --in the air
     (not av.onground
     or --standing->air roll
     (btnp(Ž) or btn(”))
     or --ground roll->air roll
     av.rolling=="ground") then
   airroll()
  elseif av.onground and
         av.rolling=="none" then
   groundroll()
  end
 end

 --rolls have higher maxvel
 if av.rolling!="none" then
  av.xcurrentmaxvel=av.xrollmaxvel
 else
  av.xcurrentmaxvel=av.xmaxvel
 end

 --jump set dy
 if btnp(Ž) and
    (av.rolling=="none" or
    av.rolling=="ground") then
  jump()
 end
 
 --variable jump hight calcs
 if av.jumping and
    av.jumpframes<av.maxjumpframes then
  av.jumpframes+=1
 end

 if not btn(Ž) and
    av.jumping then
  local fraction=av.jumpframes/av.maxjumpframes
  av.yvel*=fraction
  av.jumpframes=jumpframesoffset
  av.jumping=false
 end
 
 if av.rolling=="none" or
    av.rolling=="jumping" then
  --x input reaction
  if av.onground then
   if btn(‹) then
    xaccelerate(av.xgroundacc,-1)
   elseif btn(‘) then
    xaccelerate(av.xgroundacc,1)
   else --ground decel
    av.xvel*=av.xgrounddecel
   end
  else --air x movement
   if btn(‹) then
    stickorfall(-1)
   elseif btn(‘) then
    stickorfall(1)
   else --air decel
    av.xvel*=av.xairdecel
    av.stickframes=av.maxstickframes
   end
  end
 end
end

function updatecollision()
 --prevent going into corner
 if av.yvel<0 and
   not av.onground and
   not mapcol(av.left,av.xvel,0,0) and
   not mapcol(av.right,av.xvel,0,0) and
   (mapcol(av.left,av.xvel,av.yvel,0) or
   mapcol(av.right,av.xvel,av.yvel,0)) and
 		mapcol(av.top,av.xvel,av.yvel,0) and
 		not mapcol(av.top,0,av.yvel,0) then
		av.yvel=0
 end
 
 --ground bounce
 if av.rolling=="air" and
    mapcol(av.bottom,0,av.yvel,3) then
  sfx(26)
  
  initdustkick(-0.8,-1.5,
   1.6,1,
   2,0,7,nil,true)

  moveavtoground()
  av.ypause=1
  
  --don't lose vel for
  -- this frame or ypause frame
  av.yvel+=currentgravity*2
  av.yvel*=-1
 end
 
 --on ground
 if mapcol(av.bottom,0,av.yvel,0) then
  resetswitches()
  moveavtoground()
  
  --land
  if not av.onground then
   sfx(30,2)
   initdustkick(av.xvel-0.5,-av.yvel*2,1,0.5,4,10)
   av.rolling="none"
   av.pauseanim="squish"
   av.animpause=2
  end
  
  if av.rolling=="ground" then
   if milliseconds%2==0 then
    initdustkick(av.xvel*-1,-0.5,sgn(av.xvel)*-1,1,0,0)
   end
  end
  
  av.yvel=0
  av.onground=true
  av.onleft,av.onright=false,false
 else
  av.onground=false

  --roll off edge
  if av.rolling=="ground" then
   av.rolling="air"
   avsfx(22)
  end

  --roof bounce or land
  if av.rolling=="air" and
     mapcol(av.top,0,av.yvel,3) then
   avsfx(26)
   
   initdustkick(-0.8,0.5,
    1.6,1,
    2,0,7,av.top,true)

   moveavtoroof()
   av.ypause=1
   av.yvel*=-1
  elseif mapcol(av.top,0,av.yvel,0) then
   av.yvel=0
   moveavtoroof()
  end
 end
 
 --apply bounce on bounce walls
 if (av.rolling=="air" or
    av.rolling=="ground")
    and
    mapcol(av.left,av.xvel,0,2) then
  sfx(26)
  moveavtoleft()

  initdustkick(-av.xvel,-0.8,
   1,1.6,
   2,0,7,av.left,true)

  av.xpause=1
  av.xvel*=-1
 elseif (av.rolling=="air" or
   av.rolling=="ground")
   and
   mapcol(av.right,av.xvel,0,2) then
  sfx(26)
  moveavtoright()
  
  initdustkick(-av.xvel-1,-0.8,
   1,1.6,
   2,0,7,av.right,true)

  av.xpause=1
  av.xvel*=-1
 else
  av.onleft=avsidecol(av.left,moveavtoleft)
  av.onright=avsidecol(av.right,moveavtoright)
 end
 
 --checkpoint
 if mapcol(av.hurtbox,0,0,4) then
 	-- save key
  if av.inventory=="tempkey" then
   av.inventory="key"
  end

  if xcp!=xhitblock or
     ycp!=yhitblock then
   --new checkpoint
   sfx(37,1)

   --[[reset previous cp
   if not in hub or start screen]]
   if not instart(xcp,ycp) and
      not inhub(xcp,ycp) then
    mset(xcp,ycp,9)
   end
   
   xcp,ycp=xhitblock,yhitblock
   mset(xcp,ycp,10)
   
   initburst(xcp,ycp,{7,10})
  end
 end
 
 if allboxcol(5) and
    allboxcol(6) then
  --put down friend in hub
  if inhub() and
     av.inventory=="friend" and
     av.onground then
   av.inventory="none"
   holdingfriend.x=av.x
   holdingfriend.y=av.y
   startfriendanim()
  end
 else
  --exit
  if allboxcol(5) and
     av.inventory=="friend" then
   --float anim
   startfloatanim()
   avsfx(47)
  end
  
  --chest
  if allboxcol(6) and
     av.onground and
     (av.inventory=="tempkey" or
     av.inventory=="key") then
   --no more key
   initburst(av.key.x,av.key.y,{7,10})
   av.inventory="trans"

   --open chest
   mset(xhitblock,yhitblock,31)
   sfx(41,2)

   --remember chest location
   xprevchest,yprevchest=xhitblock, yhitblock

   --get friend!
 		holdingfriend=nil
 		holdingfriend={
 		 x=av.x,
 		 y=av.y,
 		 s=99,
 		 flipped=av.flipped,
 		 colmap={},
 		 oncloud=false
 		}

   --friend level variations
   if inspikelvl() then
    holdingfriend.delay=5
   elseif inbouncelvl() then
    holdingfriend.delay=10
    holdingfriend.colmap={
     {6,14},
     {13,2},
     {1,15}}
   elseif inbreaklvl() then
    holdingfriend.delay=15
    holdingfriend.colmap={
     {6,11},
     {5,1},
     {1,11}}
   elseif inswitchlvl() then
    holdingfriend.delay=20
    holdingfriend.delay=10
    holdingfriend.colmap={
     {6,9},
     {13,15},
     {1,8}}
   end
 
 		add(friends,holdingfriend)
   startfriendanim()
  end
 end
 
 --game objects colision
 for s in all(switches) do
  if circlecollision(av,s) and
     s.active then
   
   if av.rolling!="ground" then
    initburst(s.x,s.y,{7,12})
    sfx(43,0)
   end
   
   s.active=false
   
   if av.rolling=="none" or
      av.rolling=="jumping" then
    if av.onground then
     groundroll()
    else
     av.rolling="air"
     av.rotvel=abs(av.xvel/2)
    end
   elseif av.rolling!="ground" then
    --keep apropriate maxvel
    if av.xvel==av.xrollmaxvel then
     av.rolling="jumping"
    else
     av.rolling="none"
    end
   end
  end
 end
 
 for k in all(keys) do
  if circlecollision(av,k) and
     av.inventory=="none" then
   sfx(32,1)
   initburst(k.x,k.y,{7,10})

   av.inventory="tempkey"
   av.key=k
   
   --if av has a temp key
   -- remember where to put it
   -- on death
   xtempkey,ytempkey=k.x,k.y
  end
 end
end

function updateav()
 --face correctly
 if av.pauseanim=="none" then
  if av.xvel>av.xgroundacc or
     av.onleft then
   av.flipped=false
  elseif av.xvel<av.xgroundacc*-1 or
         av.onright then
   av.flipped=true
  end
 end
 
 --update dy if falling
 if not av.onground then
  av.yvel+=currentgravity
  
  --prevent variable jump effect
  -- after jump apex
  if av.yvel>0 then
   av.jumping=false
   av.jumpframes=jumpframesoffset
  
   --slide down wall slower
   if av.onleft or
      av.onright then
    currentgravity=wallgravity
    currenttvel=walltvel
   else
    currentgravity=airgravity
    currenttvel=airtvel
   end
  end
  
  --terminal velocity
  if av.yvel>currenttvel then
   av.yvel=currenttvel
  end
 end
 
 if av.xpause<=0 then
  av.x+=av.xvel
 end
 
 if av.ypause<=0 then
  av.y+=av.yvel
 end
 
 if av.xpause<=0 and
    av.ypause<=0 and
    av.animpause<=0 then
  --finish anims
  if av.pauseanim=="getfriend" then
   if inhub() then
    --add friend obj to
    -- approp cloud
    -- and light approp eyes
    local cloudindex=1
  
     if inspikelvl(xprevchest,yprevchest) then
     cloudindex=2
     sset(112,50,12)
    elseif inbouncelvl(xprevchest,yprevchest) then
     cloudindex=6
     sset(108,51,14)
    elseif inbreaklvl(xprevchest,yprevchest) then
     cloudindex=7
     sset(123,52,11)
     sset(125,52,11)
    elseif inswitchlvl(xprevchest,yprevchest) then
     cloudindex=3
     sset(119,51,9)
    end
    
    holdingfriend.x=1-rnd(2)
    holdingfriend.y=1-rnd(2)
    holdingfriend.oncloud=true
    
    add(
     clouds[cloudindex].offsets,
     holdingfriend)
    
    xprevchest,yprevchest=nil,nil
   
    if gamecomplete() then
     --change gamestate
     initending()
     playendingtune=true
    end
   else
    av.inventory="friend"
   end
  elseif av.pauseanim=="float" then
   av.pauseanim="endtohub"
   if gamecomplete() then
    playendingtune=true
    menuitem(1)
   end
   avsfx(48)
   initburst(av.x,av.y,rollycolours)

   xcp,ycp=63,27
   av.x,av.y=63,27
   av.xpause,av.ypause=90,90
  elseif av.pauseanim=="endtohub" then
   --spin back
   startfloatanim()
   sfx(50,2)
   avsfx(49)
   initburst(av.x,av.y,rollycolours)
   av.pauseanim="hubfloat"
   av.rotvel=0.33
   lockcamera=false
   av.xvel=0
   av.yvel=0
  elseif av.pauseanim=="hubfloat" then
   releasesfx()
  end

  if av.xpause<=0 and
     av.ypause<=0 and
     av.animpause<=0 then
   av.pauseanim="none"
  end
 end

 if av.xpause>0 then
  av.xpause-=1
 end
 
 if av.ypause>0 then
  av.ypause-=1
 end
 
 if av.animpause>0 then
  av.animpause-=1
 end
 
 if av.xvel*sgn(av.xvel)<0.001 then
  av.xvel=0
 end
end

function gamecomplete()
 local chestleft=false

 for x=0,127 do
  for y=0,63 do
   if not checkflag(x,y,5) and
    checkflag(x,y,6) then
    chestleft=true
   end
  end
 end
 
 --no chests left-completed
 return not chestleft
end

function updatefriends()
 --this frame's friend instructions
 local reaction={
  s=friendsanim.sprite,
  x=av.x,
  y=av.y,
  rot=av.rot,
  flipped=av.flipped
 }
 
 add(prevreactions,reaction)
 
 if #prevreactions>30 then
  del(prevreactions,prevreactions[1])
 end

 if (not holdingfriend) return

 for f in all(friends) do
  local pr=prevreactions[#prevreactions-f.delay]
  f.s=pr.s
  f.rot=pr.rot*0.7
  f.flipped=pr.flipped
 end
 
 local pr=prevreactions[#prevreactions-holdingfriend.delay]
 
 if av.inventory=="friend" then
	 holdingfriend.x=pr.x
  holdingfriend.y=pr.y
 end
end

function updateanim()
 --tab 3
 
 --av and friend animate
 avanimfind(av.anim,friendsanim)
 updateanimt(av.anim)
 updateanimt(friendsanim)
 
 --checkpoints glow
 updateanimt(cpanim)
 
 if cpanim.sprite>=13 then
  cpanim.sprite=11
 end
 
 if not instart(xcp,ycp) and
    not inhub(xcp,ycp) then
  mset(xcp,ycp,cpanim.sprite)
 end
 
 --active switches glow
 updateanimt(switchesanim)
 
 if switchesanim.sprite>=
    switchesanim.basesprite+5 then
  switchesanim.sprite=
   switchesanim.basesprite
 end
 
 --keys rotate
 updateanimt(keysanim)
 
 if keysanim.sprite==keysanim.basesprite then
  keysflipped=not keysflipped
 end
 
 if flr(keysanim.sprite)==48 then
  keysanim.sprite=46
 end
end

function updatemusic()
 local tune=""
 local fade=1000
 
 if playendingtune then
  tune="win"
 elseif inhub() then
  tune="hub"
 else
  tune="cave"
 end
 
 if musictimer>0 then
  musictimer-=1
 elseif musictimer==0 then
  music(musicnext,fade)
  musictimer=-1
 end
 
 if tune!=playingtune then
  music(-1,fade)
  musictimer=30
  if tune=="hub" then
   musicnext=10
  elseif tune=="cave" then
   musicnext=0
  elseif tune=="win" then
   musicnext=13
   musictimer=30*9
  end
  
  playingtune=tune
 end
end

function _draw()
 currentdraw()
end

function drawplaying()
 drawgame()
end

function drawgame()
 cls()
 if (inhub()) cls(12)
 
 --tab 5
 drawbgs()
 
 --map
 map(xmap*16,ymap*16,xmap*128,ymap*128,16,16)
 
 --game objects
 for s in all(switches) do
  if s.active then
   spr(switchesanim.sprite,s.x*8,s.y*8)
  else
   spr(4,s.x*8,s.y*8)
  end
 end

 for k in all(keys) do
  spr(keysanim.sprite,k.x*8,k.y*8,1,1,keysflipped)
 end
 
 for o in all(exitorbs) do
  spr(95,o.x*8,((o.y-0.5)*8)+yorboffset)
 end
 
 --centerpiece orb
 pal(12,14)
 pal(1,8)
 pal(13,2)
 pal(6,15)
 spr(switchesanim.sprite,63*8,ycen)
 pal()

 --friend follow
 for f in all(friends) do
  if not f.oncloud and
     av.pauseanim!="endtohub" then
   mapcols(f.colmap)
  
   if f.s==84 then
    rspr(32,40,f.x*8,f.y*8,f.rot,1)
   else
    spr(f.s,f.x*8,f.y*8,1,1,f.flipped)
   end
   
   pal()
  end
 end
 
 --tab 6
 drawparticles(false)
 
 --draw avatar if alive
 if not av.warping and
    av.pauseanim!="endtohub" then
  if av.rolling=="air" or
     av.rolling=="ground" and
     av.pauseanim=="none" then

   rspr(0,0,av.x*8,av.y*8,av.rot,1)
  else
   spr(av.anim.sprite,av.x*8,av.y*8,1,1,av.flipped)
  end
 end
 
 drawparticles(true)
 
 if inhub() then
  drawlogo()
 end
 
 local wordscol=9
 local symbolscol=10
 
 --instructions yummy
 print("jump",33*8-3,8*8+2,wordscol)
 
 print("roll",53*8+5,6*8,wordscol)
 print("—",54*8+1,7*8-1,symbolscol)
 
 print("dive",55*8+4,7,wordscol)
 print("‘",58*8,7,symbolscol)
 print("—",59*8,8,symbolscol)
 
 print("hop",70*8+6,3*8+4,wordscol)
 print("”",70*8+5,4*8+3,symbolscol)
 print("—",71*8+3,5*8,symbolscol)
end

-->8
--collision

function moveavtoground()
 av.y+=av.yvel
 av.y-=av.y%pixel
 updatehitboxes()
 av.y+=distanceinwall(av.bottom,0,1,-1)+pixel
 updatehitboxes()
end

function moveavtoroof()
 av.y+=distancetowall(av.top,0,1,-1)
 av.y+=pixel-av.y%pixel
end

function moveavtoleft()
 --unsure why offset needed :(
 av.left.x+=coloffset 
 av.x+=distancetowall(av.left,1,0,-1)
 av.left.x-=coloffset
 av.x+=pixel-av.x%pixel
end

function moveavtoright()
 av.x+=distancetowall(av.right,1,0,1)
 av.x-=av.x%pixel
end

function distancetowall(box,checkx,checky,direction)
 local distancetowall=0

 while not mapcol(box,distancetowall*checkx,distancetowall*checky,0) do
  distancetowall+=(pixel*direction)
 end

 return distancetowall
end

function distanceinwall(box,checkx,checky,direction)
 local distanceinwall=0

 while mapcol
 (box,distanceinwall*checkx,
      distanceinwall*checky,0) do
  distanceinwall+=(pixel*direction)
 end

 return distanceinwall
end

--all sides collision(flag)
function allboxcol(f)
 if mapcol(av.top,0,0,f) and
    mapcol(av.bottom,0,0,f) and
    mapcol(av.left,0,0,f) and
    mapcol(av.right,0,0,f) then
  return true
 end
 return false
end

function anyboxcol(xvel,yvel,flag)
 if mapcol(av.top,xvel,yvel,flag) or
    mapcol(av.bottom,xvel,yvel,flag) or
    mapcol(av.left,xvel,yvel,flag) or
    mapcol(av.right,xvel,yvel,flag) then
  return true
 end
 return false
end

--spike collision
function spikecol()
 if mapcol(av.hurtbox,0,0,1) then
  if hitsprite==5 then
   --top
   if mapcol(
      makebox(0,4,8,4),0,0,1) then
    return true
   end
  elseif hitsprite==6 then
   --right
   if mapcol(
      makebox(1,-1,2,8),0,0,1) then
    return true
   end
  elseif hitsprite==7 then
   --left
   if mapcol(
      makebox(5,-1,4,8),0,0,1) then
    return true
   end
  elseif hitsprite==8 then
   --bottom
   if mapcol(
      makebox(1,1,8,3),0,0,1) then
    return true
   end
   --corners
  elseif hitsprite==20 then
   if mapcol(av.left,0,0,1) or
      mapcol(av.top,0,0,1) then
    return true
   end
  elseif hitsprite==21 then
   if mapcol(av.right,0,0,1) or
      mapcol(av.top,0,0,1) then
    return true
   end
  elseif hitsprite==22 then
   if mapcol(av.left,0,0,1) or
      mapcol(av.bottom,0,0,1) then
    return true
   end
  elseif hitsprite==23 then
   if mapcol(av.bottom,0,0,1) or
      mapcol(av.right,0,0,1) then
    return true
   end
  end
 end
 return false
end

--mapcollision
function mapcol(box,xvel,yvel,flag)
 return checkflagarea(box.x+xvel,box.y+yvel,box.w,box.h,flag)
end

function checkflagarea(x,y,w,h,flag)
 return
  checkflag(x,y,flag) or
  checkflag(x+w,y,flag) or
  checkflag(x,y+h,flag) or
  checkflag(x+w,y+h,flag)
end

function checkflag(x,y,flag)
 local s=mget(x,y)
 --remember the last hit block
 xhitblock,yhitblock=flr(x),flr(y)
 --remember last hit sprite
 hitsprite=s
 return fget(s,flag)
end

-- https://stackoverflow.com/questions/345838/ball-to-ball-collision-detection-and-handling
function circlecollision(s1,s2)
 
 --get distance from cen to cen
 local dx=s1.x-s2.x
 local dy=s1.y-s2.y
 
 local distance=(dx*dx)+(dy*dy)
 
 --if radiuses less than c2c, collision
 if distance<=((s1.r+s2.r)*(s1.r+s2.r)) then
  return true
 end
 return false
end

-->8
-- avatar utils

function avpausetohub()
 if (av.pauseanim=="getfriend") return

 xcp,ycp=63,26
 
 --reset objectives
 if av.inventory=="friend" then
  mset(xprevchest,yprevchest,30)
 end
 
 if av.inventory!="none" then
  if av.inventory=="friend" then
   av.key.x=xtempkey
   av.key.y=ytempkey
   
   del(friends,holdingfriend)
  end
  keyreset()
 end
 
 if not av.warping then
  sfx(25)
  initdeath()
  av.warping=true
  lockcamera=false
 end
end

function getmaploc(x,y)
 --assume current screen
 local xm=xmap
 local ym=ymap
 
 --override if specific location
 -- requested
 if x and y then
  xm=flr(x/16)
  ym=flr(y/16)
 end
 
 return xm,ym
end

function instart(x,y)
 local xm,ym=getmaploc(x,y)
 return xm==2 and ym==0
end

function inhub(x,y)
 local xm,ym=getmaploc(x,y)
 return
  xm>=3 and xm<5 and
  ym==1
end

function inspikelvl(x,y)
 local xm,ym=getmaploc(x,y)
 return
  xm<2 and ym<2 or
  xm==2 and ym==1
end

function inbouncelvl(x,y)
 local xm,ym=getmaploc(x,y)
 return xm<4 and ym>=2
end

function inbreaklvl(x,y)
 local xm,ym=getmaploc(x,y)
 return xm>=4 and ym>=2
end

function inswitchlvl(x,y)
 local xm,ym=getmaploc(x,y)
 return xm>=5 and ym<=2
end

function airroll()
 av.playingsfx="none"
 avsfx(31)
 
 currentgravity=airgravity
 currenttvel=airtvel
 
 av.rolling="air"
 av.rotvel=pixel*2
 av.xvel,av.yvel=0.0,-0.2
 
 --on wall dives
 if btn(‹) and
    not av.onleft then
  av.xvel=-av.xrollmaxvel
 elseif btn(‘) and
    not av.onright then
  av.xvel=av.xrollmaxvel
 else
  --normal dives
  setxrollvel()
 end
 
 --convert to hop
 if (not btn(‹) and
    not btn(‘)) or
    btn(”) then
  av.rotvel=pixel*0.5
  av.xvel*=0.5
  av.yvel-=0.2
  avsfx(22)
 end
end

function groundroll()
 av.playingsfx="ground"
 avsfx(23)
 av.rotvel=pixel
 
 av.rolling="ground"
 setxrollvel()
end

function setxrollvel()
 --todo:base off input?
 if av.flipped then
  av.xvel=-av.xrollmaxvel
 else
  av.xvel=av.xrollmaxvel
 end
end

function jump()
 av.playingsfx="none"

 currentgravity=airgravity
 currenttvel=airtvel
 
 if av.rolling=="ground" then
  av.rolling="jumping"
 end
 
 --different jumps
 --collision resets flags
 if av.onground==true then
  avsfx(20)
  av.jumping=true
  av.yvel=-av.yjumpforce
 elseif av.onleft==true then
  avsfx(21)
  av.jumping=true
  av.xvel=av.xcurrentmaxvel
  av.yvel=-av.ywalljumpforce
 elseif av.onright==true then
  avsfx(21)
  av.jumping=true
  av.xvel=-av.xcurrentmaxvel
  av.yvel=-av.ywalljumpforce
 end
end

function isavskidding()
 if av.onground and
     ((btn(‹) and av.xvel>0) or
     (btn(‘) and av.xvel<0 and
     not btn(‹))) then
  return true
 end
end

function xaccelerate(acc,sign)
 if (av.xvel*sign)<av.xcurrentmaxvel then
  --quick turn around
  if isavskidding() then
   av.xvel*=0.7
  end
  
  av.xvel+=acc*sign
 else
  av.xvel=av.xcurrentmaxvel*sign
 end
end

--stick to wall to give player
-- time to press jump
function stickorfall(sign)
 if (av.onleft or av.onright) and
    av.stickframes>0 then
  av.stickframes-=1
 else
  xaccelerate(av.xairacc,sign)
  av.stickframes=av.maxstickframes
 end
end

function avreset()
 av.xvel,av.yvel=0,0
 
 av.xcurrentmaxvel=av.xmaxvel
 av.stickframes=0
 av.jumpframes=jumpframesoffset
 
 av.jumping,av.onground=false,false
 av.onleft,av.onright=false,false
 av.flipped,av.warping=false,false
 
 --lock movement
 av.xpause,av.ypause=0,0
 
 --play specific anim
 -- w/o locking movement
 av.animpause=0
 
 --animations when locked
 av.pauseanim="none"

 av.anim=makeanimt()
 
 av.rot=0
 av.rotvel=0
 av.rolling="none"
 av.playingsfx="none"
 
 --key and friend persist death
 if av.inventory=="tempkey" then
  keyreset()
 end
 
 resetswitches()
 
 --reset crumble blocks
 for cbc in all(cbcontrollers) do
  cbc.timer=(cbrespawntime-cbanimspeed*2-1)
 end
 
 av.x,av.y=xcp,ycp
end

function keyreset()
 av.inventory="none"
 
 --av.key is a reference
 av.key.xdest=xtempkey
 av.key.ydest=ytempkey
 
 av.key=nil
end

function updatehitboxes()
 --smaller than av
 av.hurtbox=makebox(1,2,5,3)
 
 local off=coloffset*9
 
 --cover top and bottom
 av.bottom=makebox(
 1,7,
 6,1,
 0,coloffset)
 
 av.top=makebox(
 1,1,
 6,1,
 0,coloffset)
 
 --space between top and bottom
 av.left=makebox(
 1,2,
 1,5,
 coloffset)
 
 av.right=makebox(6,2,1,5)
end

function makebox(x,y,w,h,xo,wo)
 return {
 	x=av.x+av.w*pixel*x-(xo or 0),
 	y=av.y+av.h*pixel*y,
 	w=av.w*pixel*w-(wo or 0),
 	h=av.h*pixel*h
 }
end

function avsidecol(box,reaction) 
 if mapcol(box,av.xvel,0,0) then
  av.xvel=0
  av.rolling="none"

  reaction()

  --don't wallslide if onground
  return not av.onground
 end
 return false
end

--want movement sfx to interupt
-- each other
function avsfx(no)
 sfx(-1,3)
 sfx(no,3)
end

function walksfx()
 if av.pauseanim=="none" then
  if inhub() then
   if av.playingsfx!="whub" then
    avsfx(28)
    av.playingsfx="whub"
   end
  else
   if av.playingsfx!="wcave" then
    avsfx(29)
    av.playingsfx="wcave"
   end
  end
 else
  releasesfx()
 end
end

function releasesfx()
 sfx(-1,3)
 av.playingsfx="none"
end
-->8
-- animation tools

function makeanimt(bs,sd,sprs)
 local t={
  basesprite=bs,
  speed=sd,
  sprites=sprs,
  sprite=bs,
  along=0,
  counter=0
 }
 return t
end

function avanimfind(t,ft)
 --default to idle
 t.basesprite=71
 t.sprites=4
 t.speed=5
 
 ft.basesprite=99
 ft.sprites=2
 ft.speed=6
 
 if btn(ƒ) then
  t.basesprite=79
  t.sprites=1
 end
 
 if btn(”) then
  t.basesprite=77
  t.sprites=1
 end
 
 --running anim
 if abs(av.xvel)>0 then
  t.basesprite=87
  t.sprites=4
  t.speed=3
  
  ft.basesprite=101
  ft.sprites=2
  ft.speed=4
 end
 
 --skid/turning
 if isavskidding() and
    currentupdate==updateplaying then
  t.basesprite=78
  t.sprites=1
  
  ft.basesprite=100
  ft.sprites=1
 end
 
 --jumping
 if av.yvel<0 then
  t.basesprite=75
  t.sprites=1
  
  ft.basesprite=101
  ft.sprites=1
 elseif av.yvel>0 then
  t.basesprite=76
  t.sprites=1
  
  ft.basesprite=101
  ft.sprites=1
 end
 
 --wallslide
 if not av.onground and
    av.onleft or
    av.onright then
  t.basesprite=70
  t.sprites=1
  
  ft.basesprite=103
  ft.sprites=1
 end
 
 --rolling
 if av.rolling=="air" or
    av.rolling=="ground" then
  
  if av.flipped then
   av.rot-=av.rotvel
  else
   av.rot+=av.rotvel
  end
  
  --prevent overflow
  if abs(av.rot)>1 then
   av.rot=0
  end
  
  ft.basesprite=84
  ft.sprites=1
 end
 
 if av.warping then
  ft.basesprite=84
  ft.sprites=1
 end
 
 if av.pauseanim=="getfriend" then
  t.basesprite=77
  t.sprites=1
  
  ft.basesprite=99
  ft.sprites=1
  
  holdingfriend.y-=pixel*0.5
  holdingfriend.s=99
  holdingfriend.flipped=av.flipped
 elseif av.pauseanim=="float" then
  av.rolling="air"
  av.rotvel+=0.003
  --don't move behind rolly
  yorboffset=0
 elseif av.pauseanim=="endtohub" then
  if av.xpause<=30 then
   lockcamera=false
   holdingfriend.y=ycen/8
  end
 elseif av.pauseanim=="hubfloat" then
  av.y=ycen/8
  holdingfriend.y=av.y
  av.rolling="air"
  if av.rotvel>0 then
   av.rotvel-=0.003
  end
 elseif av.pauseanim=="squish" then
  t.basesprite=79
  t.sprites=1
 end
end

function startfriendanim()
 avsfx(40)
 av.rolling="none"
 
 av.pauseanim="getfriend"
 av.xpause,av.ypause=60,60
end

function startfloatanim()
 releasesfx()
 av.pauseanim="float"
 av.xpause,av.ypause=120,120
 av.x,av.y=xhitblock,yhitblock
 
 av.y-=pixel*4
 av.rotvel=0
 lockcamera=true
end

function updateanimt(t)
 t.counter+=1
 
 t.along=t.counter/t.speed
 
 if t.counter>=
    t.speed*t.sprites then
  t.along=0
  t.counter=0
 end
 
 t.sprite=t.basesprite+t.along
end

function movetopoint(obj,xdest,ydest,round,multi)
 local off=0
 if (round) off=pixel*4

 local xvec=obj.x-(xdest+off)*(multi or 1)
 local yvec=obj.y-(ydest+off)*(multi or 1)
 
 obj.xvel-=xvec*0.01
 obj.yvel-=yvec*0.01
 
 obj.xvel*=0.9
 obj.yvel*=0.9
 
 obj.x+=obj.xvel
 obj.y+=obj.yvel
end

--[[taken from
https://www.lexaloffle.com/bbs/?tid=3593
]]
function rspr(sx,sy,x,y,a,w)
 local ca,sa=cos(a),sin(a)
 local srcx,srcy,addr,pixel_pair
 local ddx0,ddy0=ca,sa
 local mask=shl(0xfff8,(w-1))
 w*=4
 ca*=w-0.5
 sa*=w-0.5
 local dx0,dy0=sa-ca+w,-ca-sa+w
 w=2*w-1
 for ix=0,w do
  srcx,srcy=dx0,dy0
  for iy=0,w do
   if band(bor(srcx,srcy),mask)==0 then
    local c=sget(sx+srcx,sy+srcy)
    if c!=0 then
     pset(x+ix,y+iy,c)
    end
   end
   srcx-=ddy0
   srcy+=ddx0
  end
  dx0+=ddx0
  dy0+=ddy0
 end
end

-->8
--game object management

--switch mgmt

function createswitch(x,y)
 s={
  x=x,
  y=y,
  r=pixel*3,
  active=true
 }
 add(switches,s)
end

function createkey(x,y)
 k={
  x=x,
  y=y,
  xvel=0,
  yvel=0,
  xdest=x,
  ydest=y,
  r=pixel*3
 }
 add(keys,k)
end

function resetswitches()
 for s in all(switches) do
  if not s.active then
   sfx(44,2)
  end
  s.active=true
 end
end

function updatekeys()
 for k in all(keys) do
  movetopoint(k,k.xdest,k.ydest,false)
 end
 
 if av.key then
  if (av.inventory=="tempkey" or
     av.inventory=="key") then
   av.key.ydest=av.y-0.5
   
   if av.flipped then
    av.key.xdest=av.x+0.5
   else
    av.key.xdest=av.x-0.5
   end
  else
   --move 'used' key from picture
   -- remember for if reset hub
   av.key.x=-5
   av.key.y=-5
   av.key.xdest=-5
   av.key.ydest=-5
  end
 end
end

--friend mgmt

function mapcols(colmap)
 for cm in all(colmap) do
  pal(cm[1],cm[2])
 end
end

--crumble block mgmt

function createcbcontroller(x,y)
 local cbc={
  x=x,
  y=y,
  r=pixel*3,
  timer=-1
 }
 add(cbcontrollers,cbc)
end

function initcbs()
 cbcontrollers={}
 
 --respawn in frames
 cbrespawntime=120
 cbanimspeed=3
end

function cbexists(x,y)
  for cbc in all(cbcontrollers) do
   if cbc.x==x and cbc.y==y then
    return true
   end
  end
  return false
end

function updatecbs() 
 --check each vel seperatley
 -- to match wall collision
 if (anyboxcol(av.xvel,0,7) or
    anyboxcol(0,av.yvel,7))
    and
    (av.rolling=="ground" or
    av.rolling=="air") then
  sfx(27)
  
  if not cbexists(xhitblock, yhitblock) then
   createcbcontroller(xhitblock, yhitblock)
  end
 end

 for cbc in all(cbcontrollers) do
  if cbc.timer<(cbanimspeed*2) or
     not circlecollision(av,cbc) then
   cbc.timer+=1
  end
  
  --animate out
  if cbc.timer<cbanimspeed then
   mset(cbc.x,cbc.y,2)
  elseif cbc.timer<cbanimspeed*2 then
   mset(cbc.x,cbc.y,3)
  else
   mset(cbc.x,cbc.y,0)
  end
  
  --sfx and animate in
  if cbc.timer==
     (cbrespawntime-cbanimspeed-1) then
   sfx(42)
  end
  
  --todo:rewrite to use animt
  if cbc.timer>
     (cbrespawntime-cbanimspeed) then
   mset(cbc.x,cbc.y,2)
  elseif cbc.timer>
    (cbrespawntime-cbanimspeed*2) then
   mset(cbc.x,cbc.y,3)
  end
 
  if cbc.timer==cbrespawntime then
   mset(cbc.x,cbc.y,1)
   del(cbcontrollers,cbc)
  end
 end
end

function drawlogo()
 --prevent overflow
 if ylogo<0 then
  return
 end

 local sign=0
 
 if currentupdate==
    updateplaying then
  sign=1
 else
  sign=-1
 end

 --i'm paranoyed about overflow
 if abs(logocounter)>1000 then
  logocounter=1
 end

 logocounter+=1*sign
  
 if logocounter>160 then
  ylogovel-=0.02
 else
  ylogovel=(sin(logocounter/40)/15)
 end
 
 ylogo+=ylogovel
 
 --shadow
 pal(3,1)
 pal(11,1)
 spr(104,62.2*8,ylogo*8,3,1)
 pal()
 
 spr(104,62*8,(ylogo-pixel+ylogovel*1.5)*8,3,1)
end

-->8
--backgrounds

bgs={}
clouds={}

function generatecloud(x,y,update)
 local cloudsprs={83,112,113}

 c={
  x=x,
  y=y,
  yinit=y,
  xvel=0,
  yvel=0,
  offsets={}
 }
 
 for i=0,15+flr(rnd(6)) do
  add(c.offsets,
     {x=1-rnd(2),y=1-rnd(2),
     s=cloudsprs[1+flr(rnd(3))],
     flipped=false})
 end
 
 c.update=update
 
 add(bgs,c)
 add(clouds,c)
end

function initbgs()
 inittiling(2)
 
 generatecloud(
  51+rnd(3),18+rnd(3),updatecloud)
  
 generatecloud(
  58+rnd(3),18+rnd(3),updatecloud)
  
 generatecloud(
  65+rnd(3),18+rnd(3),updatecloud)
  
 generatecloud(
  73+rnd(3),18+rnd(3),updatecloud)
  
  
 generatecloud(
  51+rnd(3),25+rnd(3),updatecloud)
  
 generatecloud(
  58+rnd(3),25+rnd(3),updatecloud)
  
 generatecloud(
  67+rnd(3),25+rnd(3),updatecloud)
  
 generatecloud(
  73+rnd(3),25+rnd(3),updatecloud)
end

function inittiling(s)
 bg={
  s=s,
  update=updatetiling,
  xoff=0,
  yoff=0
 }
 add(bgs,bg)
 
 tilingcounter=0
end

function updatebgs()
 for c in all(bgs) do
  c.update(c)
 end
end

function updatecloud(c)
 --move based on time
 -- sin ranges from 0-1 so get
 -- inputs to match then make
 -- small
 c.yvel+=sin((stat(95)%10)/10)/2000
 
 c.yvel*=0.9
 
 c.y+=c.yvel
 
 --prevent updrift
 if c.y<c.yinit-1 then
  c.yvel=0
 end
 
end

function updatetiling(bg)
 bg.x=xmap*16
 bg.y=ymap*16
 
 local factor=0
 
 tilingcounter+=1
 
 if tilingcounter==10 then
  factor=pixel
  tilingcounter=0
 end
 
 --level variations
 if inspikelvl() then
  bg.s=119
  bg.xoff-=factor
  bg.yoff-=factor
 elseif inbouncelvl() then
  bg.s=120
  bg.xoff-=factor
  bg.yoff+=factor
 elseif inbreaklvl() then
  bg.s=121
  bg.xoff+=factor
  bg.yoff+=factor
 elseif inswitchlvl() then
  bg.s=122
  bg.xoff+=factor
  bg.yoff-=factor
 else --tutorial or hub
  bg.s=-1
 end
 
 if abs(bg.xoff)>=1 then
  bg.xoff=0
 end
 
 if abs(bg.yoff)>=1 then
  bg.yoff=0
 end
 
 bg.offsets={}
 
 for x=-1,17 do
  for y=-1,17 do
   add(bg.offsets,
      {x=x+bg.xoff,y=y+bg.yoff,
      s=bg.s,flipped=false})
  end
 end
end

function drawbgs()
 for c in all(bgs) do
  for off in all(c.offsets) do
   local x=(c.x+off.x)*8
   local y=(c.y+off.y)*8
   
   if off.colmap then
    mapcols(off.colmap)
 		end
 		
   if flr(off.s)==84 then
    rspr(32,40,
        x,y,off.rot,1)
   else
    spr(off.s,
       x,y,1,1,
       off.flipped)
   end
   pal()
  end
 end
end

-->8
--particle effects

effects={}
rollycolours={3,7,11}
cavecolours={2,4,9,10}

function createeffect(update)
 e={
  update=update,
  front=false,
  particles={}
 }
 add(effects,e)
 return e
end

function updateparticles()
 for e in all(effects) do
  e.update(e)
 end
end

function drawparticles(front)
 for e in all(effects) do
  if e.front==front then
   for p in all(e.particles) do
    circfill(p.x,p.y,p.r,p.col)
   end
  end
 end
end

function createparticle(x,y,xvel,yvel,r,col)
 p={
  x=x,
  y=y,
  xvel=xvel,
  yvel=yvel,
  r=r,
  col=col
 }
 return p
end

function initdrip()
 e=createeffect(updatedrip)
 
 for i=1,3 do
  local p=createparticle(
   40*8+4+rnd(3)-1.5,-1,
   0,0,
   0,12)
   p.t=i*3-30
  add(e.particles,p)
 end
 
 local p=createparticle(
  40*8+4+rnd(3)-1.5,-1,
  0,0,
  0,7)
  p.t=-30
 add(e.particles,p)
  
end

function updatedrip(e)
 --only when onscreen
 -- to prevent sfx playing about
 if instart() then
  for p in all(e.particles) do
   if p.t<60 then
    --gather
    p.t+=1
    
    if p.t==0 then
     p.y=(3*8)-2+rnd(2)-1
    end
    
    if p.t==60 then
     sfx(38)
    end
   elseif p.y<12*8+4 then
    --fall
    p.yvel+=0.01
    p.y+=p.yvel
   else
    --land/reset
    p.r=0
    p.x=40*8+4+rnd(3)-1.5
    p.yvel=0
    p.y=-1
    p.t=-30
    
    sfx(39)
    
    --increase area
    if clipspace and clipspace<8.5 then
     clipspace+=1
    end
   end
  end
 end
end

function initdeath()
 e=createeffect(updatedeath)
 --create a bunch of particles
 for i=0,8 do
  local p=createparticle(
   av.x*8,av.y*8,
   av.xvel*rnd(25),
   av.yvel*rnd(25),
   1+rnd(2),rollycolours[1+flr(rnd(#rollycolours))])
  add(e.particles,p)
 end
end

function updatedeath(e)
 local cpcollision=true

 for p in all(e.particles) do
  --accelerate towards checkpoint
  movetopoint(p,xcp,ycp,true,8)
  
  --follow with camera..
  av.x=p.x/8
  av.y=p.y/8
  
  --.. until cp onscreen
  if xmap==flr(xcp/16) and
     ymap==flr(ycp/16) then
   lockcamera=true
  end
  
  --or in hub
  if inhub(xcp,ycp) and
     inhub() then
   lockcamera=false
  end
  
  if flr(p.x/8)!=xcp and
     flr(p.y/8)!=ycp then
   cpcollision=false
  end
 end
 
 --if cpcollision is still true
 -- all dots are colliding
 -- and check it's the right cp
 if cpcollision and
    flr(av.x)==xcp and
    flr(av.y)==ycp then
  initburst(xcp,ycp,rollycolours)
  releasesfx()
  sfx(46,1)
  avreset()
  del(effects,e)
  lockcamera=false
 end
end

function initdustkick(dx,dy,rdx,rdy,no,minlength,overridecol,overridebox,front)
 local e=createeffect(updatedustkick)
 e.front=front or false

 --create a bunch of particles
 for i=0,no do
 local col
  if inhub(av.x,av.y) then
   col=rollycolours[1+flr(rnd(#rollycolours))]
  else
   col=cavecolours[1+flr(rnd(#cavecolours))]
  end
  
  col=overridecol or col
  
  local lrdx=rnd(rdx)
  if rdx<0 then
   lrdx=rnd(abs(rdx))*-1
  end
  
  local box=overridebox or av.bottom
 
  local p=createparticle(
   (box.x+(box.w/2))*8,
   box.y*8,
   dx+lrdx,dy+rnd(rdy),
   0+flr(rnd(2)),col)
  
  p.timeout=minlength+rnd(10)
  add(e.particles,p)
 end
end

function updatedustkick(e)
 for p in all(e.particles) do
  p.x+=p.xvel
  p.y+=p.yvel
  
  p.timeout-=1
  
  if p.timeout<=0 then
   if p.r>0 then
    p.r=0
    p.timeout=5
   else
    del(e.particles,p)
   end
  end
 end
 
 if #e.particles==0 then
  del(effects,e)
 end
end

function initburst(x,y,cols)
 local e=createeffect(updatedustkick)

 for i=0,7 do
  local col=cols[1+flr(rnd(#cols))]

  local p=createparticle(
   (x+0.5)*8,(y+0.5)*8,
   rnd(1.6)-0.8,rnd(1.6)-0.8,
   0+flr(rnd(2)),col)
  
  	p.timeout=10+rnd(5)
  add(e.particles,p)
	end
end

-->8
--gamestates and management

function initintro()
 xcp=40
 ycp=12
 
 initdrip()
 
 chest={
  s=30,
  x=40*8,
  y=12*8,
  xbump=0,
  ybump=0
 }
 
 av.x=chest.x/8
 av.y=chest.y/8-2.5*pixel
 
 av.flipped=true
 openness=0
 clipspace=0
 instructiontimer=0
 bumpsfx={33,34,35}
end

function updateintro()
 updatecamera()
 updateparticles()
 
 --reduce bump
 chest.xbump*=0.9
 chest.ybump*=0.9
 
 if clipspace>0 then
  clipspace-=0.01
 end
 
 if instructiontimer<2000 then
  instructiontimer+=1
 end
 
 --allow bump
 if btnp(—) then
  sfx(bumpsfx[1+flr(rnd(3))])
  --instructiontimer=0
  chest.xbump=rnd(6)-3
  chest.ybump=rnd(6)-3
  
  openness+=0.1
  
  if clipspace<8.5 then
   clipspace+=1
  end
 end
 
 if openness>=1 then
  --break out
  sfx(36)
  airroll()
  
  --change state
  currentupdate=updateplaying
  currentdraw=drawplaying
  
  --activate menu
  menuitem(1, "reset to hub", avpausetohub)
 
  chest=nil
  openness=nil
  clipspace=nil
  instructiontimer=nil
 end
end

function drawintro()
 cls()
 
 --where drip is coming from
 map(38,0,38*8,0,5,3)
 
 if instructiontimer>=8*30 then
   print("press —",xmap*128+53-chest.xbump,
        ymap*128+60-chest.ybump,3)
 end
 
 clip(chest.x+chest.xbump-(xmap*128)+4.5-(clipspace*0.5),
      chest.y+chest.ybump+2-(ymap*128),
      clipspace,clipspace)
 
 spr(chest.s,
     chest.x+chest.xbump,
     chest.y+chest.ybump)
 clip()
 
 drawparticles(false)
end

function initending()
 currentupdate=updateending
 currentdraw=drawending
 
 --remove reset to hub option
 menuitem(1)
 
 av.xvel,av.yvel=0,0
 
 walkright=true
 ycredits=128
 logocounter=175
 ylogo=15
 ylogovel=0.3
end

function updateending()
 updatesfx()
 updatemusic()
 updatecollision()
 updateav()
 updatefriends()
 updatehitboxes()
 updateanim()
 updatebgs()
 updateparticles()
 
 --make rolly run around yaaay
 xaccelerate(av.xgroundacc,
  walkright and 1 or -1)

 if av.x<((xmap*16)+1.6) then
  walkright=true
 elseif av.x>((xmap*16)+13.2) then
  walkright=false
 end

 --randomly jump with joy!!
 if av.onground and
    (flr(rnd(20))==0 or
    (mapcol(av.left,av.xvel,av.yvel,0) or
    mapcol(av.right,av.xvel,av.yvel,0))) then
  jump()
  --bug patch, don't know why
  -- avsfx doesn't work here...
  sfx(20)
 end
 
 --scroll credits
 if ycredits>20 then
  ycredits-=1
 end
end

function drawending()
 drawgame()
 
 --credits
 s="by davbo and rory"
 outline(s,
 (xmap*128)+hw(s),(ymap*128)+ycredits+8,1,7)
 
 s="deaths: "..deaths
 outline(s,
 (xmap*128)+hw(s),(ymap*128)+ycredits+16,1,7)

 s="playtime: "..
 twodigit(hours)..":"..
 twodigit(minutes)..":"..
 twodigit(seconds).."."..
 twodigit(milliseconds)
 outline(s,
 (xmap*128)+hw(s),(ymap*128)+ycredits+24,1,7)

 s="thanks for playing!"
 outline(s,
 (xmap*128)+hw(s),(ymap*128)+ycredits+32,1,7)
end

function twodigit(val)
 if val>9 then
  return val
 else
  return "0"..val
 end
end

--half width for printing
function hw(s)
 return 64-#s*2
end

function outline(s,x,y,c1,c2)
 for i=0,2 do
  for j=0,2 do
   print(s,x+i,y+j,c1)
  end
 end
 print(s,x+1,y+1,c2)
end
__gfx__
0083330006666d6006666d6006660d6000111100949947490004ff499a000000000000000047a4000047a4000047a40000a7aa0009aaa99a99aaa99a9aa99aa0
09333330d115555ddd555ddddd6506dd0d551110474af77a0f7777f44f7a0000000000f000a7a90000a7a90000a7a9000077a700a4242444242424944442424a
8333b7336d11111661ddd15661d00d5615551111f770f7f000047f49f7777a0000a0007004a7a94004a7a9400977a7900777a770942222222222222222222229
33333b336511115d65d0611d0000006d1551dd11f7f04f40000000a94ffa00000070047499d7ad9999d7ad9997c77c7977c77c77422222222222222222222229
33333333dd1111d6dd600d16d6000000111ddd1197900f000000aff49a0000000a7a077f4947a4944947a4944947a494aa97a9aa942222222222222222222229
33333333d511111dd116dd1d61600066111dd0110f00040000a7777f94f74000077f0f7f99a7a99999a7a99999a7a9997aa7aa97942222222222222222222249
03333330d551551dd511561ddd60061d011111100f0000000000a7f44f7777f0af7fa4f402a7a94002a7a94002a7a94009a7a940924249422442494224424429
0033330005dddd5005ddd65005d006500011110000000000000000a994ff400094f49949007a9900007a9900007a9900007a9900099499999494999999949940
0aa9a99aaaa99a9aa99aa9a02222222200000049940000002449a949949a44420aaaa9a007769aa907a77a7777777a7777a777709aa976700000000009aaaa90
a9494249994944949494499a222222220f0097f44f7900f04a744af44fa447a492444249a76424449a66676667766766667666a744424767000000004111111a
aa42222222222222222222a92222222200f904a99a409f00477f09700790f774a222224a77224222a4242222242242222222424a222422a7049aaa9091111119
a42222222222222222222249252222220097a04aa40a790044f7a040040a7f49a422224976222222942242244242224242242249222226674114911a41111119
94222222222222222222224922252222090a7f4494f7a090a40a74000047a04a9922229a77242222a2222222222422222222222a222242779119911991111119
a92222222222222222222229224142220740f774477f04709a904f0000f409a99422222976222222942222222222222222222249222222679999a99499911994
a9222222222222222222224a444509424fa447a44a744af44f7400f00f0047f49422222976224222922222222222222222222229222422679119411491144114
a9222222222222222222224994000099949a94422444a949940000000000004994222249a7422222942222222222222222222249222224772111111221111112
94222222222222222222224922222222777a77a07622226707777a7007777a70a22222497622246a762222222222222222224267000770000007700000aa7700
a4222222222222222222224a2222222266676777a2422267a7676777676767a79422224a664222666642422222229222222222670007700000a007000a000070
a4222222222222222222229924aa422222422467772224677a42226772422247a222229976224277762222222222122222224277000aa00000a007000aa00a70
9a222222222222222222224a24999222222222777622227a76224276a42242a9a422224a77422267774222222222222222222467000a70000099a900009aaa00
942222222222222222222249299912222222426767242267a72222679922229a992222497624226a762422222222222222222277000990000009900000099000
a92222222222222222222229211122222422227a762224a7764222779422222994222229764224667642222222222aa222222467000aa000000aa000000aa000
a9222222222222222222224a2222222264a676777776767a7622242a942222299422224aa7422267774222222222249222224267000990000009a000009aa000
a4222222222222222222224a222222227777677007a7777076222267942222499422224a762422677624222222222112222224770009900000a9a000009aa000
9422222222222222222222492222222222222229222222220aaaa9a077777a779422224976222222942222222222222222222249222222670776777700000000
9222222222222222222222492222aa222222222122229aa292444249677667669222224976222422942222222222222222222249224222677a6a672600000000
94222222222222222222229922229a222222222222229942a222224a24224222a422229977242222a9222222222222222222229a22224277a722224200000000
942222222222222222222299222211222222222229221112a4222249424222424222224977224222a4222222422222422222224a222422777624222200000000
9422222222222222222222492222222222222222212222229922229a22222222a4222249762222229a42224222242224242224a9222222677722222200000000
9242222222222222222224492922222222222a922222222294222229242224229422222a77242222a4224222224222222224224a222246777642242211d61311
94444449444449424444424921222222222229a222222222944244296464664692424929a6744424a4999799676767766676667742444467777676660d663550
0994499994999999949994902222222222222112222222220499994077a676760999999007669449097a7a777677777777a777a0944946700a77a77711d65111
0bb3b33bbbb33b3bb33bb3b022222222b3b3bbbb0000000008980000089800000000000000000000000000000000000008980000089800000000000000000000
b3131213331311313131133b222228221313311100000000033333300333333008980000089800008333333083b3bbb00333333003b3bbb00899800000000000
bb12222222222222222222b3222289822222222200000000033b3bb003b3bbb0033333300333333003b3bbb00313331003b3bbb0031333100333333000000000
b122222222f2222222222213222258522222222200000000033133300313331003b3bbb003b3bbb0031333100333333003133310033333300bb3b33088988000
313222222fef22222e2222132222252222222222000000000533333003333330031333100313331003333330033333300533333003333330033313303b33bbbb
b322222225f52222efe222232222222222222222003000000d113300001133000333333003333330001133000011330000113300001133000333333031333331
b3222222225222225e52221b2222222222222222033003000dd5000005dd1500051133000011330000dd100005dd150000dd100005dd15000033115033333333
b322222222222222252222132222222222222222033bb3bb0d00000000d0d00000dd100005dd150005d0d500000000000000d00000d0d00000055d0005113350
3122222222222222222222130077f000000000000000000022222222000000000000000093333330898000000679a9999999a760b22222132222222200000000
b122222222d222222222221b0f77777000066000000000002aaaaaa28333333083333330833b3bb0033333307a4a9224444942773122221b2222222200022000
b12222222ded222222222233f7777f770077660000000000aa2222aa033b3bb0033b3bb003313330033b3bb07722222222222467b222223322222222007e8200
3b22222225d522222222221b7f7777f7066766d000000000aaaa2aaa033133300331333003333330033133307624222222222277b122221b2222222202e72820
332222222252222222222213f77777ff0d6666d000000000aaa2aaaa03333330033333300011330003333330772222222222426733222213222222220282e820
b12222222222222222222223f777777f00666d0000300000aa2222aa001133000011330005dd1500051133007642222222222277312222232222222200288200
b1222222222222222222221b077ff7f0000dd000003030002aaaaaa205dd150005dd1d000d000d000ddd1000772494444229a4a73122221b1311313100022000
b3222222222222222222221b000fff0000000000b33b3b002222222200d0d00000d00000000000000000d000067a9999999a97603122221b33b3133b00000000
b33bb3b0bbb33b3b2222223b00000000000000000000000000000000000000000111111000001101111001103122221b03b33b00000000010000000000000000
3131133b331311312222223b00010000000000000016660000010000010000001bbbbbb111113b13b1b113b13222221b0303000000010006dd00000100000000
222222b3222222222222223b00066600000100000006560000066600066600001bb113b13bb31b13b3bb1bb1b1222233000300000006660d1d1000ddd0000100
22222213222222222222221300056500000666000006660000065600065600001bb113b1b13b1b13b13bbb1022222213000000000006560ddd0000d1d00ddd00
22222213222222222222221b00066600000565000055d60000066600066600001bbbbb13b13b1b13b101bb10b122221b00000000000666011d0000dd1001d100
22222223222222222222223b0005600000066600000dd0000005d600055600001bb13bb1b13b13bb3b13b10031222223000000000005d600110001d1000ddd00
2222221b222222223121313b005dd500000d6000000d5500005dd0000d5000001bb013b13bb313bb331bb1003212132300000000005dd000110000110000d100
2222221322222222b33b3bb0000d5000005d550000000000000050000d0000000110011011110111110110000333333000000000000050010100001010051150
0f77ff00007fff0000dddd0000c7660000cccc0000ddcc0000dddd000001001000001000001000100000100000000000b322222215ddddddd66ddddddddd5551
f7ff77f007f7777007cc11d00c7611d00c7776c006dc777007cc11d00010000100100100010000010001000000000c003122222213316d33d36dddddd1561111
7777f77ff777777fdccc111dc76c111dc777611dddc7777cdccc1117010000000100001010001000001001000c00c0c032222222015311111111111111111110
77777777f7777f77dcc7dd1d76c7dd1dc776dd1ddc777776dcc7dd1710000000100000000001010001001001c00c0c0cb1222222001565365d6555551d161100
f7f7777ff77777f7d11ddd1d611ddd1dc76ddd1dd7777776d11dddc70000000100000001100010001001001000c0c0cc3322222200155dd5dd6dddd5d1111100
7f7777f77f7777ffd11ddc1d611ddc1dc61ddc1dd777776cd11ddc76010000100100001001000001001001000c0c0ccdb122222201511111dd5d555551111110
07777770077777f00d1111d00d1111d00c1111d00c7776c00111c76000100100001001000010001000001000c0c0ccdcb33113331513d1ddd6661111111d1511
00f77f00007fff0000dddd0000dddd0000dddd0000c66c0000777600000101000001000000010100000100000c0ccdcd0bbb3bbb155355555d61555555d111d1
41617151416150507113131313131313131313121212131313131213131313131313131313131312121212131313131212260000031313131313131313131312
12131313131313131313220000000212121212121213121313131313121313131313131312121212121212122550021212121313131313131313131313131332
71510071610000000000000000000000000000031225000000008200000000000000000000000050711323000000000222000000000000000000000000000002
2200000000100000000082000000023212331261500082000000000082000000000000000213131312b212122500711213230000000000000000100000000002
41610000000000004000000000000000000000000225000000000370000000000000000000000000004000000000900222900000000000000000000000000002
2200000000100000000082000000021212126100000082000000000083000090000000008200000003126150b600005000000001e0e0e0e0e0e0210000000002
61000000000000b5e011e0e0e011e0e0e0f00000026100808000000000000090000080808041e0e0e0e011210000011212b1b1b1518080a1c180a1b151000002
220000900010000000008200000002121212700000e18200000000000000d011210000008200000010500000c600000000000082000010000000830000000002
d10040000000000000715100412600000000e1000270000222000000000001111111615050500000000002220000021212123312131313131313237161000002
22000001e0f000000000820000d012123212700000d0221010810000000060123270000082000000000000000000900000000082000010000000000090000002
1211d1000000000000007151d5c6000000d011111270007133218080808002121261000000000000000002220000500212121223000000505000000040009002
2200008200000000000082000000021212610000000082000082100000006012220000008200000000000080808001111111e0230000011111e0e0e0e0e01112
12126100000000004000911226000000000002b26100000071131212121313132300000080000000000002220000000212122300000000000000000001111112
22000082000000000000820000000212127000000010037000838080808041122200000082000010001041121212121212336100000003326100000000000212
1261000000000000b5e0122500000001210002610000000000005050500000000000900082000062000002437000000212220000000000000000804133121212
220000820000000001112200000002122200100000000000006012131313131222000000025100000000c7e5e5e5e51212250000000000500000000000000212
c20000400000000000007125549055056100500000000000000000000000000111e0f06013706033700002b27000000212220000800000000000021212124312
2200008200000001131312f0000002122200109000000000006022000000000222000000021251000000c6000000000212250000000000100000000000000212
1211e0c50000000000000071444414125100000000000000000000000000011225c6c60000000050000002220000000212220000025100000041021212121212
2200008200000083000082000000021212e0e0f0000000808041220000f300022200000002121251000000000000000243250000000000100000008000000212
122300000000000000004000a21313131373737351000000000041b1b1b112122555f300000000000000022200000002122200000313b1b1b1b1121212121212
2200008200000000000083000000021222000000001060131313230000d011b21270000002531212518080801000000212250000000000100000802200000212
22004000000000000091e0e02300000000000000027000000000a2121313131313e014b1b1c18062806013230000800212220000000003615050507113131232
2200008200000000000010000000021222000060e0e0f00000000000000071122200006013131313131313230000601212125100000000100041122300000233
2200d0e0d1000000009200000000000055000000027000000000a223000000000000505071121212610000000000021212220000000000000000000000000212
22000082000000000000100000000212220000000000000000000000000000022200000000005000005000000000601212122200000000000002230000000212
229000009200000041c2000000000091240000000270000000412200000000000000000000505050000000000000031212225100000000000000000000000212
22000002112100000000100000000212220000000000000000000000000000022200000000000000000000000000000212122200000000000082000000000212
12f00001c280804112c20040000000a2250000041270000041531221000000012100900040000000000000000000000212121121000000000000000000000212
2200000233121111111111111111b212220000000000100000100000100000022200000000001000001000000090000212532200001080808082000000900212
22000002121212121212111111111112220000051270006012121212112100031211111111111111112180800111111212331212111111518080804121000212
22000002121212121212121212121212125180808080808080808080808041121211111151808080808080411111111212122280804112121222000001111212
22000002121213131313131313131313230000051270006012121313132300000313121212121312121213131313131212121313131313131313131322000312
22000002121313131313131312131313131313131312121312121313121212121212131313131313131313121313133212131313131212131323000002121353
2200d01312c200000000000000000000000000c71270000003220000000063000000031253230003122200000000000313230000000050505050505050000002
220000022200000000000000830000000000000000032300022300000313131313230000000000000000c6d50000000222000000000322000000000002230002
2200000002c200000000000000000000000000000270000000820000000000012100000322000000022200d02190000000000000000000000000000040009002
22000002220000000000001000000000000000000000000082000000100000000000000000000090550000b60063000222000000000092000000000082000002
2200000002c2000000000060510000900000000002700000008300000000000212210000830000000261000071e0e011111111d1000000000000000001111112
22000002220000000000810000000414060000000000900082000000100000000000000000000444240000400000000222000000000092000081101083d20002
1221000003c20040000000007111111111e0f000027000000000000080000002121221000000000002700000000000a2121212d3006042000000806012121212
2200000222000000d0e013e0e01112122200d011e0e0e0e022000000911111111111e0e0e0e01313134444211010100222000081101082000082000010000002
1222000000021111510000000071617122000000027000000000000002700002123312e0e021000002700000000000a2121212700000000000e3220050711212
22101002220000000000000000025312220000b60000000082000000931343121223000000000000c60543220080800222000082000082000082000010000002
1223000000021212127000000000804122000000027000008000000082000002121223000083000003510080000000a21212c200000000000000520000007112
22000002220000000000000000021212220000c60000000082000000000003122200000000000000000512220003131223000082000082000083000000d01112
2200000001131313137000004000a212220000d0220000008280000082000002122300000000000000820082000000a253126100007255000000000000006012
22000002220000000000000000021212220000000000000082000000000000a22200000000000121000512220000000270000082000082000000008080414312
22000000820000000000d260e0e0131322000000829000000243b1b12200000222000000000000000002e022510000a21212700000710600000001f000000071
22000002431121108080000000021312220000000000000082000000000000a22200000001111222000512532100000270000082006002210000000313131312
22000000820000000040800000000060220000000311e0e01313121226000002229000000080000000820071220000a2126100000000717373b1220000000041
22101003131313e01323000000820002125180801080804122000000000000a22200000050505050005050505000000221000082000050712100000000000002
22000001230060e0e0e023000000000122000000008200000000c725000000021211210000057000000251008200000212510000000000000071220000000002
22000000000000000000000000820002121212220003131323001000000000a222000000000000000000000040000002220000820000000071f0000000000002
220000057040000000000000008000022200000000820000000000b6000000021243220000055180411222808200000212c20000000000000000500000000002
220000000000000000000000008300021212b2220000000000000000000000a222000000001010101010101010b5e01323000082000000000000100000000002
220000c7e0e0e0e0e0e0e0e0e02300021311210000022100000000c6000054021212220000051212121212122200000212c20000000000b57000000000009002
22000000000000000000000010000002121212220000000000000000001000a22200001000000000000000000000000000000082000000000000000000000002
610000c6000000000000000000004002005050000003230000550000000004121261830000716150505050711370000212d3000000000000000000000000d012
220000000000009000000000000000021212122200000000a0000010000000a22200000000000000000000000000000090000083000000100000800000900002
70101010101010101010101010100112420000000040000091240090000434121251800000000000000000004000000222000000101000000000100000000002
12518080804111111111518080804112123312125180411111518080808041531251808080808080728080411111111111218080808010a1c180828001111112
5180808080808080808080808041121200011111111111111212444414121212121212b1b1b1b1b1b1b1b1b1b1b1111222808080808080808080808080808002
121212121212531212121212121212121212121212121212121212121212121212121212121212121212121232121212b2121212122280021212121212121212
__gff__
008d8d8d30020202021010101001010101010101020202020105090909054000010101010d0d0d09010505010550505001010101010101090105090909050d2001010101010000000000000000000000010101000000010000000005050101000101010000000000000000010000000000003030303030000000000001606060
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2131313131313131313134212121212121213121313131313131313131212121213131313205202121212205303131313131213131312121212121212b3131313131312131313131313131313131312b160505050505050517213131312131313131313131212131313131313131313131313131312121212121212121212121
16000000000000000000502121212b23212205280000000000000000001721212200000000003021232132000000000000002800000030313131313132000000000000280000000000000000000000200700000000000000005d0000005d0009000000000030210700000000000400000000000000202b160505050505173521
150000000000000000007c311617212121220828000000090000000000001721220000000000003013320000000000000000280000000000000000000000000000000028000000090000000000000020420000000000003f005d0000006b0010120000000006210700040000000d0f0900000000002016000000000000001721
2200000010120000000000050000172121210e32001011120000000000001421220000000000000000000000000000101200280000000000000000000000000000000038010110111200000000000020520000000400060e11620000006c0020330f000000062107000000000000174444420000002007000400040000000020
1600000005170700080000000000002034220000002033210e0e07000000202122000000000000000000000000101133220028000000000000000000000000000000000000002021220808080800002062000000000000002007000400000020210700040006211508081a070000000621520000000500000008000000000020
070000080000000828000008000000202122000000202b220000000000002021220000000000000000000d0e0e313121220028000010111200000000000d0e1111120000000020313131313131150020141514070000000020070000000000202107000000062121213522000004000621620000040000000030070000000020
07000028002d003032000028000000202122000000202122000000000000172121120000000d0f0000000000000000202200280000202122000000000000002035220000000038000000000000280020171605000000000020150808000808202107000400063421212122000000000621070000000000000000000000000020
1500003800000000003600280000002021220000062123520000000000000621212112000000000000000000000000202200280000303132000000000000002021310e0e0e1200000000000000280020120000000000040030212116040520232107000000062121213122000808081421150814070000000000000000090020
2200000818000000000000380000002021220000062121520000060e0f00062121212112000000000000000000000020220028000001000000001012000000202200000000380000101200000028002022000000000000000621210700002021220000000014212132002800302131212116050500000000000004000d111121
2200002022080808101112000000002021220000002033160000000000001421215621210e0e0f00000d0e0f000000202200300e61610e0e0e0e31310f0000202200000000000010160500000028002022000000080808081421330704002021220000000020213200002800002800202b444200000000040000000000303321
2200003031313131313116000000062121220000002021070000000008142121213131320000000000000000000010212200000020220000000000000000002022000000000000200700000045280020220000062205050505050500000030212200000000302200000028000038002021215200000000000000000000003021
220000000000000000000000000006212131070000203107000000007c313121220000000000000000000000001021212200000030220000000000000000002022001007000000200700000040220020220000000500000000000000080000202200000400000500000030070000002021355200000000000000000000000020
22090000000000451e550000000814212200000000280000000000000000002022000000000000451f5500001021212b22000000003800001012000000101134220020070000002007000000303200203200040000001e0000000000380400202112000000000000040000000009002021215200000400000000000000000020
210e0e0f00000040416000000030313132000000002800000000550000000020220000000000004041420000202121212200000000000000202112000020212122005007000900200700000000000020070000000006110700000000000000202135070000040000000000000d0e0e2121215200000000000000000900000020
2200000000004043215160000000000000000000002800090040420000000020220000000000403521216000202121212200000000000000202135111121212152005011111111211500000009000020070000000006210700000900000000202121070000000000000000000000142121215208080808080814111112000020
22001011111121212121211111111111111111151421111111212112000000202111111111112121212121112121212121111111111111112121212121212121527b5051212121352111111111111121150808080814211508101200000000202121150808080808080808080814212b21212121212121212121342122000020
2200303131213131313131313121212121213131313131313121212200000017213131313131313131212121313131313132000000000000000000000000000000000000000000000000000000000020212121213131313131313200000000202b21313131313131313131313131313131313131313131212121212122000020
220000000622000000000000001734352116000000000000007c312200000006220000000000000000050505000000000000000000000000000000000000000000000000000000000000000000000020432121220000000000000000000000202132000000000000000000000000000000000000000000172121212122000020
220000000622000000000000000017212200000000000000000000380000001422000000000000000000000000000000000000000000000000000000000000000000000000000000000000001800003021342122002f000000040000040000202200000000000000000000000000000009000000000000062121213132000020
22090000062200090000000800000020220000000000000900000000000014342200101200000000000000000000090000000000000000000000000000000000000000000040444460000000200f0000202121220000000000000000000000202200000000000000000004000000001011120000000000062121160000000020
210e070006350e0e070000280000002022000000061510605500000000002021220017220000000010111200000040446161600000000000000000000000000000000000007c5e515200000038000000202121220000000000000400000000172200000000000000000000000000002021310e0e0f0000062122000000000020
2200000006220000000000200700002022000000001716204142000000002021220014211508081421212b111111352121316200000000000000000000000000000000000000007c520000000000000030212122000400040000000000000006220000100f00000000000000060e0e3521070000000000062122000000000d35
22000000065200000000002007000020220000000000001731310e0e070621212200203131313131313131313131212122006c0000406141616142000000000000000000000000005d00000000000000002021220000000000000800000000062200003800000000000000000000002021070000000000062122000000000621
2200000814520000000000280000002021111200000000000000000000002021220028000000000000000000000030215200000000304321212162000000000000000000000000006b00000000000000002021211508000000002800000900142200000000040000000000000000002021070004000000063422000000000621
220006312122000000080616000000202121220000000000000000000000202322002800000000000000000000000020520000000000305e5e6200000000000000000000000000000000000040600000002021212121150808142b15081011332200000000000000000000000000002021070000000000062122000000000621
220000062122000000380000000000202121320000000000000000000000502122003800000000000000000612000020216142000000006c006c000000000000000000000000000000000000503200000020213521313131313131313131212122000000000000000000000d12000020210700000008081421310f0000000621
2200000005050000080000000000142b211600000000061b0700000000005021220000000010120000000006210f0020212152000000000000000000000000000000000000000000000000006b00000000202131320000000000000000003031310e0f0000000000000000002800002021070000003031313200000004000621
22000000000000002800000008142121220000000000142115000000000020212200000000202112000900062200002021212160000000000000000000006d6e6f000000000000000000000000000000003032000000000000000004000000000000000000000000000000003800002021070000000000000000000000000621
220000000800000028000006313131212200000000002023211500000000202134110e0e0e3131310e0e0e113200002021342162000000000000000000007d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002021070000000000000000000000000621
22000014211500002800000000006c5022095500000020212121070000003031313200000000000000000038000000202121320000000000454061616161616161616160000000000000000000000000000000000900000000000000000000000000000000000000040000000000002021070000000000000000000000081421
220014213421150d22000000553f455021614200001421212121150009000000000000001800000018000000000010212122000000406161612121212121212121212121444441444444420000000000000000101111111111111508000000000000090000000000000000000000002021150808081011111111111111332121
221421212321211520444144444444212121341111212121212121111111111111111111211111112111111111112123212200004021212121212121212121212121212121212121212152000000404441444421212121212b212121111111111111111115080808141111111111112121212121212121212121212121212121
__sfx__
01140000115351f0251103518525145351f0251103518525115351f0251103518525145351f02511035185250d5351f0251103518525145351f02511035185250f5351f0251103518525145351f025115351f025
01140000030000550003053050451163505525050550553503053055450553505045116350552505045055150304301535011250154511635010250d5120153503053035450f5250304511635035450f0450f525
01140000030530554505535050351162505535050550554503053055450552505045116250551505045055150305301545011250154511625010450d5220153503043035350f5250304511635035450f0450f525
01140000115351f0251103527524145351f0251103527525115351f0251103527524145351f0251103527525115351f0251103522524145351f0251103522525115351f0251103525524145351f0251103525525
01140000030000550003053050451163505535050550554503033055250854508045116250854203045035250304301535011250154511635010250d5120153503053035450f5350304511625035450304503525
011400000d5351f0251103518525145351f02211034185250d5351f0251103518525145351f02211035185210f5351f0251103518525145351f022115341f0250f5351f0251103518525145351f022115321f024
011400000305301545011250154511625010350d522015350305301545011250155511625010450d5220153503053035450f525030551162503545030250353203053035450f5220305511625035420f02503535
011400001153524725115351b5441453524025115351b5251153524025115351a5441453524725115351a525105351f7251053519544145351f0251053519525105351f0251053518544145351f7251053518525
01140000030000550003053050451163505525050450552503053055450553505045116250551505045055350305301545011350154511625010250d54201535030530c5450c5350c025116350c535180450c525
011400001153524025115351b5241453524725115351b5251153524725115351a5241453524025115351a5251353522025135351d5241453522725135351d5250f5351f7250f53516524145351f7250f53516525
01140000030000550003053050451163505525050450552503053055450553505045116250552505045055250305301545011350152511645010350d54201525030530c5450c5350c025116250c545180350c535
011a0020030331a70003000116250303303000116001d70018700187001d6251161511615116151161517700030331a70003000116250303303023116001d70018700187001162511615116001d6151160011615
011a00001c7411c0121f7401f0122374023022237152301523012180112672226022267252611526715180111f7411f012247402401226740260222671526015260122601129722290222972529115297151c711
011000000060000600245342472126012267312d7112d0112d7322d0222d0122d73209723090420c6430c000186000c633241342472126012267312b0112b0122b7322b0222b7122b03207723070420c64326700
011000002470024700245342472126012267312a7212a0122a7322a0222a0122a73206023067420c6430c000186000c633241342472126012267312b7212b0122b7322b0222b0122b73207023077420c64326700
011000200950009000095000900009500000530954509025090450953209022095150005309535000000953500005150541501515054150150005307545070250704507532070220751500053075350700007535
011000000600007544075150754407515000530653506025060450653206022065350005312535090000652500005065440651506544065150005307535070250704507532070220753500053135350700007525
011000002470000700007000070002000027002d73426725247352d72526735247252d735267252473524000246002d7342b7252673524725267002d734267252b7352d725267352b7252d735267252b73526700
011000222d7002d7342b7252673524725027002a73426725247352a72526735247252a735267252473500000006002a7342b7252673524725027002b73426725247352b72526735247252b735267252473502700
000300000c0000c0101003025040290402b0202b02028040280402b0202b02028040280402b0202b0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000013711137110e7210e7211f7311f7412475124751007000070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010000000000
0102000021711157111c7211072121731217412675126751000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000006100562102631156410c63211642136121f642116321161511600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500201f623056001a625057001d625077001f625117001f625057001f623077001d625117001f625077001f623056001a625057001d625077001f625117001f625057001f623077001d625117001f62507700
010600000e7111c7211f73121742237123474234732347223471234712347123471234712347121a70018700167001470011700107000d7000b7000a700087000670004700037000170001700000000000000000
0103000029251292551b251092450a24008235042200822012212032120d2120d2000d512012120d2120d20029200292001b2002120016200142001020014200122001b2000d2000d20035600050000d20019200
0102000013111137110e1110e7111f1211f7212413524131001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
010c00003062530600306153060030615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500203361500000000003361500000000003360000000336150000000000336150000000000000000000033615000000000033615000000000033600000003361500000000003361500000000000000000000
01050020296150000000000296151d600000000000000000296150000000000296151d600000000000000000296150000000000296151d600000000000000000296150000000000296151d600000000000000000
010900002463500043000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000246331d6421a645156310c632116220761107611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00002371529235283452373529235283252372529215285152830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00003465504053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00003565505053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000396550a053256001c60014600106000c6000b600096000760004600046000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000396702e670256631c66314653106430c6330b633096230762304613046130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000135652b755135452b745135352b735135252b72513515135002b700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000013011117211d0211d731290312b7410000031775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000201110721110211e7311e031207410100026775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c452234501c4501e442234401c4301e432234201c4201e422234201c4201e42223422234122341500000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002d6652e00625600396702e650256431c63314623106230c6130b61309600076000460004600000000000000000000001a600000000000000000000000000000000000000000000000000000000000000
010a00000c62518600186153060030615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000337252b021247251b72516021077250700002005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000000000e0001401019010190200a0300a0500000000000000003b0003b0003a0003a0003a0003a000390003800038000000003b0003b00000000000000000000000000000000000000000000000000000
0108000813535185251f5150052413535185251f51500524005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000013525185551f5250c55413555185551f555245550c522245150010000100001000010000100001000c000180000010000100001000010000100001000010000100001000010000100001000010000000
0109000815045177550e0451005415745170551a0451c75400000297002c7002f7003270035700387003870038700387003870038700387003870038700387003870038700387003870038700387003870038700
010400000c52413521185311f541245510c1433740024500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b0008120451975515045110550d7450b0550974506055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000027031230211f0311c04119041170411404112053125001250012500125001250012100000000000012500125001250012500125001210000000000001250012500125001250012500121000000000000
01100000007002a7252b7252672524725027002d72526725247252d72526725247252d725267252472500000006002d7252b7252672524725027002d725267252b7252d725267252b7252d725267252b72502700
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400002d0442d725260442672524044247252d0442d725260442672524044247252d0442d7252b0442b725260442672524044247252d0442d72526044267252b0442b7252d0442d72526044267252b0442b725
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
00 41 02 43 44
01 00 01 43 44
00 00 02 43 44
00 03 04 43 44
00 05 06 43 44
00 03 04 43 44
00 05 06 43 44
00 07 08 43 44
02 09 08 43 44
00 41 42 43 44
00 0b 0c 43 44
03 0b 0c 43 44
00 41 42 43 44
00 0d 0f 43 44
00 0e 10 43 44
01 0d 0f 33 44
02 0e 10 12 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
