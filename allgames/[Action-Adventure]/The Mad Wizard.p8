pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--mad wizard
--(c) 2014 robert l bryant
--ported by gradualgames

function _init()
 --disable button repeat
 poke(0x5f5c,0xff)
 inititems()
 initsave()
 initmenu()
 initcamera()
 initrooms()
 inithekl()
 anmtim=0
 flsh=0
 gtim=0
 ci=1
 tmpmsg=""
 tmpmsgt=0
 enemiesv=true
 boss=false
 bstate="noboss"
 gstate="title"
end

function _update()
 if cshk>0 then
  cshk-=1
  cx=(cshk%2)==0 and 0 or 1
 end
 if (flsh>0) flsh-=1
 anmtim+=1
 if gstate=="title" then
  if btnp(—) then
   startgame()
   gstate="main"
  end
 elseif gstate=="main" then
  colenemies()
  updhekl()
  updhproj()
  updntts(enemies)
  updntts(splodes)
  if boss then
   if bstate=="bossdefeated" then
    if ri!=0 then
     --remember boss defeated
     dset(lkpsave(ri),1)
    end
    sfx(10,-1,23)
    savehekl()
    hstate="passive"
    cshk=64
    bstate="openexits"
   elseif bstate=="openexits" then
    if cshk==0 then
     sfx(-1)
     music(15)
     _draw()
     wframes(64)
     --open exits
     enemies={}
     openexits()
     boss=false
     bstate="noboss"
     if ri!=0 then
      --restart music
      music(song)
      resthekl()
     else
      music(30)
      wc=0
      hstate="passive"
      gstate="wipe"
     end
    end
   end
  end
 elseif gstate=="initboss" then
  boss=true
  if ri==126 then
   --we're in beancy and flerg.
   --find them and install
   --their colors and correct
   --health. mark the bones
   --as the boss.
   for ntt in all(enemies) do
    if ntt.upd==updraven then
     ntt.col=split"1,7"
     ntt.h=24
     ntt.t=60
    elseif ntt.upd==updwalker then
     ntt.boss=true
     ntt.col=split"7,9,6,4,5,1"
     ntt.im=true
     ntt.it=true
     ntt.h=60
     ntt.upd=
      function(walker)
       if cntalventts(enemies)==1 then
        walker.im=false
        walker.it=false
       end
       updwalker(walker)
      end
    end
   end
  end
  music(-1)
  _draw()
  wframes(64)
  --close off exits
  closeexits()
  sfx(11)
  enemiesv=true
  _draw()
  wframes(48)
  music(8)
  wframes(32)
  gstate="main"
 elseif gstate=="die" then
  updhekl()
  if gtim>0 then
   gtim-=1
  else
   if hlifs>=0 then
    cls()
    wframes(10)
    resthekl()
    initroom()
    hhp=gethelthmax()
    gstate=boss and "initboss" or "main"
   else
    music(42)
    ci=1
    boss=false
    gstate="gameover"
   end
  end
 elseif gstate=="gameover" then
  if btnp(”) or
     btnp(ƒ) then
   ci+=1
   if (ci>2) ci=1
  elseif btnp(—) then
   cls()
   wframes(10)
   if ci==1 then
    startgame()
   else
    music(-1)
    inithekl()
    gstate="title"
   end
  end
 elseif gstate=="wipe" then
  wc+=1
  if wc>256 then
   gstate="ending"
  end
 end
end

function _draw()
 if gstate=="title" then
  cls()
  pal(14,getanmcol())
  pal(8,anmtim&4==0 and 8 or 9)
  local pixels=get_text_pixels("mad")
  scale_text(pixels,72,10,4,4,7,
   function(nx,ny)
    sspr(96,0,3,3,nx,ny)
   end)
  rectfill(0,0,127,6,0)
  pixels=get_text_pixels("the")
  scale_text(pixels,4,10,5,4,7,
   function(nx,ny)
    sspr(96,41,5,3,nx,ny)
   end)
  rectfill(0,0,127,6,0)
  pixels=get_text_pixels("wizard")
  scale_text(pixels,4,36,5,4,7,
   function(nx,ny)
    sspr(96,41,5,3,nx,ny)
   end)
  rectfill(0,0,127,6,0)
  spr(64,34,44)
  print("rob bryant's",10,0,7)
  print("",20,64,7)
  print("a candelabra chronicle\n\n        — game")
  print("(c) 2014 robert l bryant",20,90)
  tmpmsg=""
  tmpmsgt=1
  drwhud()
 elseif gstate=="main" or
    gstate=="initboss" or
    gstate=="die" then
  if flsh>0 then
   if flsh%2==1 then
    pal(0,8)
   else
    pal(0,0)
   end
  end
  rectfill(0,0,127,127,0)
  camera(cx,cy)
  --rect(0,0,127,127)
  drwroom()
  --print("ri: "..ri,4,4)
  --print(""..#enemies.." "..#splodes,4,4,7)

  --verify testing collision flags
--  for y=0,11 do
--   for x=0,15 do
--    if gettilesol(x,y) then
--     rect(x*8,y*8,x*8+7,y*8+7,8)
--    end
--   end
--  end
--  color(7)

  --show attribute values
--  for y=0,11 do
--   for x=0,15 do
--    print(tostr(gettileatt(x,y)),x*8,y*8)
--   end
--  end
--  color(7)

  --show enemy indices at their
  --spawn locations
  --point to enemy location data
  --in current room
--  local elocaddr=ri*58+50
--  local px,py=4,4
--  for i=0,3 do
--   local eindex=peekr(elocaddr+i)
--   local ecoord=peekr(elocaddr+i+4)
--   local x=ecoord&0xf
--   local y=flr(ecoord>>4)
--   if eindex!=0 then
--    print("Œ"..eindex,x*8,y*8,7)
--    --second line prints hidden
--    --enemy spawns like goblins
--    --but not positioned at
--    --spawn location
--    print("Œ"..eindex,px,py,7)
--    px+=20
--   end
--  end

  --show item index at its
  --spawn locationd
--  local ilocaddr=ri*58+48
--  local iindex=peekr(ilocaddr)
--  local icoord=peekr(ilocaddr+1)
--  local x=icoord&0xf
--  local y=flr(icoord>>4)
--  if iindex!=0 then
--   --print("‡"..iindex,4,16)
--   print("‡"..iindex,x*8,y*8)
--  end
  drwitem()
  drwhekl()
  drwprism()
  drwbridge()
  drwhproj()
  if enemiesv then
   drwntts(enemies)
   if (boss) drawexits()
  end
  drwntts(splodes)

  --show all collision rectangles
--  function drwrect(r,c)
--   rect(r[1],r[2],r[3],r[4],c)
--  end
--  for enemy in all(enemies) do
--   if enemy.a then
--    local er=enemy:gr()
--    drwrect(er,8)
--   end
--  end
--  if hprojalv then
--   local hr=getprojr()
--   drwrect(hr,8)
--  end
--  if halv then
--   local hr=getheklr()
--   drwrect(hr,8)
--  end
--  color()

  drwhud()
  animwater()
 elseif gstate=="gameover" then
  cls()
  drwroom()
  drwhud()
  box(32,16,64,20,0,7)
  print("continue?",36,20,7)
  print("yes",80,20,7)
  print("no",80,26,7)
  local cy=split"20,26"
  pal(8,getanmcol())
  spr(82,74,cy[ci])
  pal()
  anmtim+=1
  animwater()
 elseif gstate=="wipe" then
  rectfill(0,0,127,127,0)
  camera(cx,cy)
  --rect(0,0,127,127)
  drwroom()
  drwhud()
  local c=0
  for y=0,15 do
   for x=0,15 do
    rectfill(x*8,y*8,x*8+8,y*8+8,0)
    c+=1
    if c==wc then
     goto out
    end
   end
  end
  ::out::
  drwhekl()
 elseif gstate=="ending" then
  cls()
  print("",12,40,7)
  print("having rid the land of")
  print("amondus, hekl was a hero!")
  print("the king beckoned him, and")
  print("thus begins his role in")
  print("\"candelabra\".")
  print("the end",76,80)
 end
end

function initsave()
 cartdata("gradualgames_madwizard")
end

function initmenu()
 menuitem(
  1,
  "switch weapon",
  function()
   if (getthunder()==1) hwep=(hwep+1)%2
  end)
 menuitem(
  2,
  "reset progress",
  function()
   for k,v in pairs(saves) do
    dset(k,0)
   end
   run()
  end)
end

function startgame()
 song=nil
 --ri=1 --rant's revenge
 --ri=2 --floating palace
 --ri=3 --doorstep to doom
 --ri=15 --treetop atelier
 --ri=18 --dak's quarters
 --ri=23 --woodsman's watch
 --ri=24 --breeze in trees
 --ri=26 --tidy treehouse
 --ri=30 --fall of faith
 --ri=38 --the unreachable?
 --ri=47 --goblin gauntlet
 --ri=51
 ri=54 --hekl's home
 --ri=55 --the front yard
 --ri=58 --bush-e-faces
 --ri=60 --w. raven bridge
 --ri=61   --e. raven bridge
 --ri=62   --the elderwood
 --ri=63   --inside elderwood
 --ri=66 --strange strides
 --ri=69 --hekl's well
 --ri=73
 --ri=75 --scythe stone
 --ri=77 --pit of scorching
 --ri=78 --brimstone grotto
 --ri=79 --below the root
 --ri=83 --heavy barrels
 --ri=86 --old storage room
 --ri=88 --fluttering fangs
 --ri=91 --inner sanctum
 --ri=92 --burning heart
 --ri=93 --charwit reborn
 --ri=97 --the untrusted
 --ri=56
 --ri=98  --gargoyle toil
 --ri=100 --the magic loot
 --ri=102 --the lone golem
 --ri=103 --enemy mine
 --ri=104 --charwit
 --ri=105 --initial findings
 --ri=108 --general rant
 --ri=109 --hot hot feet
 --ri=114 --lizard's leap
 --ri=121 --fortune or folly
 --ri=124 --limestone path
 --ri=125 --fiendish aquifer
 --ri=127 --solemn alcove
 inithekl()
 initroom()
 savehekl()
 gstate="main"
end

--gets max float dist from
--save game data.

function getfltmaxsav()
 return dget(3)+dget(14)+dget(15)
end

function getfltmax()
 return 1+getfltmaxsav()
end

function getrismaxsav()
 return dget(2)+dget(4)
end

function getrismax()
 return 1+getrismaxsav()
end

function gethelthmax()
 return 2+dget(0)+dget(7)+dget(13)
end

function getspdsav()
 return dget(5)
end

function getflyspd()
 return (getspdsav()==1) and .5 or .25
end

function getrisspd()
 return (getspdsav()==1) and .5 or .25
end

function getprojlifsav()
 return (dget(9)+dget(12)+dget(16))
end

function getprojlif()
 return getprojlifsav()*8
end

function getprism()
 return dget(1)
end

function getteleport()
 return dget(8)
end

function getthunder()
 return dget(10)
end

function getbridge()
 return dget(11)
end

function gettricaster()
 return dget(6)
end

function initcamera()
 cx=0
 cy=0
 cshk=0
end

function getanmcol()
 return anmtim&4==0 and 14 or 11
end

function rotsprpx(s)
 for y=0,7 do
  local tly=flr(s/16)*8+y
  local tlx=flr(s%16)*8
  --now we know pixel coordinates
  --within sprite sheet, determine
  --address in memory
  local addr=tly*64+tlx/2
  local row=rotl(peek4(addr),4)
  poke4(addr,row)
 end
end

function animwater()
 if anmtim%2==0 then
  rotsprpx(42)
  rotsprpx(54)
 end
end

function drwhud()
 --hekl lives icon
 if hitc>0 then
  setheklcols(getanmcol())
 end
 spr(87,8,100)

 --health icons
 for x=8,8+hhp*5-5,5 do
  spr(80,x-2,106)
 end
 print("x"..max(hlifs,0),14,100,7)

 --weapon icon
 pal(8,getanmcol())
 spr(81,35,106)
 if getthunder()==1 then
  pal(14,7)
  spr(93,46,106)
 end
 spr(82,hwep==0 and 36 or 48,101)
 spr(83,35,115)
 line(36,116,38+getprojlifsav(),116,7)
 pal()

 --green movement icons
 spr(84,96,106)
 spr(85,106,106)
 spr(86,116,106)
 spr(83,96,114)
 line(96,115,96+getfltmaxsav()*2+1,115,7)
 spr(83,106,114)
 line(107,115,108+getrismaxsav()*2,115,7)
 spr(83,116,114)
 line(117,115,118+getspdsav()*4,115,7)

 if tmpmsgt>0 then
  tmpmsgt-=1
  print(tmpmsg,60,100,7)
 else
  print(sub(roomtitles,ri*16+1,ri*16+16),60,100,7)
 end

 if (getprism()==1) spr(89,60,108)
 if (getteleport()==1) spr(75,72,108)
 if (getbridge()==1) spr(91,84,108)
 if gettricaster()==1 then
  line(63,118,88,118,7)
  line(63,118,63,116,7)
  line(75,118,75,116,7)
  line(88,118,88,116,7)
 end

 --hud outline
 line(0,96,127,96,7)
 line(0,120,127,120,7)
 line(56,96,56,120,7)
end

function closeexits()
 settiletyp(0,ity,3)
 settiletyp(15,ity,3)
end

function openexits()
 settiletyp(0,ity,0)
 settiletyp(15,ity,0)
end

function drawexits()
 pal(8,getanmcol())
 local y=ity*8+1
 if (ri!=0) spr(109,1,y)
 spr(109,121,y)
 pal()
end

-->8
--hekl

function inithekl()
 halv=true
 htx=5
 hty=1
 hxo=0
 hyo=0
 hinc=0
 hfltdist=0
 hrisedist=0
 hlifs=2
 hitc=0
 hwep=0
 hprojwep=0
 hprojx=0
 hprojy=0
 hprojalv=false
 hprojxinc=0
 hprojlif=0
 hhp=gethelthmax()

 --prism cube vars
 hprismtx=htx
 hprismty=hty
 hprismanm=cranim(split"89,90",1)
 hprismv=false

 --spectral bridge vars
 hbridgetx={}
 hbridgety=hty
 hbridgeanm=cranim({92},1)
 hbridgev=false

 hwalk=split"64,65,66,65"
 hsrise={67}
 hrise=split"68,69"
 hfall={70}
 hclimb=split"71,72"
 hdie=split"73,0"
 hanim=cranim(hwalk,2)
 hflip=true
 hpause=0
 hstate="stand"
end

function savehekl()
 hstx=htx
 hsty=hty
 hsxo=hxo
 hsyo=hyo
 hsflip=hflip
 hsanim=hanim
 hsst=hstate
end

function resthekl()
 htx=hstx
 hty=hsty
 hxo=hsxo
 hyo=hsyo
 hflip=hsflip
 hanim=cranim(hsanim.frames,hsanim.s)
 hstate=hsst
end

function getheklr()
 local tlx,tly=
  htx*8+hxo,hty*8+hyo
 return {tlx+1,tly,tlx+6,tly+7}
end

function hithekl()
 if hitc==0 and
    hstate!="teleport" and
    hstate!="die" then
  sfx(15)
  sfx(16)
  if hhp>0 then
   hitc=32
   hhp-=1
  else
   hlifs-=1
   hanim=cranim(hdie,8)
   hstate="die"
   gtim=90
   gstate="die"
  end
 end
end

function checkitem()
 if hstate!="teleport" and
    dget(lkpsave(ri))==0 then
  local hr=getheklr()
  local ir=getitemr()
  if colrect(hr,ir) then
   tmpmsg=inams[ityp]
   if tmpmsg then
    dset(lkpsave(ri),1)
    sfx(12)
    sfx(13)
    sfx(14)
    tmpmsgt=90
    if (ityp==1) hhp=gethelthmax()
   end
  end
 end
end

function checkhurt()
 if gettiletyp(htx,hty)==2 then
  hithekl()
 end
end

function checkwater()
 if gettile(htx,hty)==42 then
  sfx(6)
  cls()
  drwhekl()
  wframes(32)
  resthekl()
  initroom()
 end
end

function toggleprism()
 if getprism()==1 then
  hprismv=not hprismv
  if not hprismv then
   eraseprism()
  end

  if hprismv==true then
   sfx(8,-1,18,32)
   hprismtx=htx+(hflip and -1 or 1)
   hprismty=hty
   --if was spawned,
   --make block solid
   if gettileop(hprismtx,hprismty) then
    settiletyp(hprismtx,hprismty,3)
   else
    hprismv=false
   end
  end
  if tilebeneath() then
   heklstand()
  else
   tryfall()
  end
 end
end

function eraseprism()
 settiletyp(hprismtx,hprismty,0)
 hprismtx=-1
 hprismty=-1
end

function drwprism()
 if hprismv then
  pal(14,getanmcol())
  spr(getanimspr(hprismanm),hprismtx*8,hprismty*8)
  pal()
 end
end

function togglebridge()
 if getbridge()==1 then
  hbridgev=not hbridgev
  if not hbridge then
   erasebridge()
  end
  if hbridgev==true then
   sfx(8,-1,18,32)
   local bdir=hflip and -1 or 1
   local btx=htx+bdir
   hbridgety=hty+1
   --if was spawned, make bridge
   hbridgetx={}
   for tx=btx,btx+bdir*2,bdir do
    if gettileop(tx,hbridgety) then
     add(hbridgetx,tx)
     settiletyp(tx,hbridgety,3)
    else
     break
    end
   end
   if (#hbridgetx==0) hbridgev=false
  end
  if tilebeneath() then
   heklstand()
  else
   tryfall()
  end
 end
end

function erasebridge()
 for tx in all(hbridgetx) do
  settiletyp(tx,hbridgety,0)
 end
 hbridgetx={}
end

function drwbridge()
 if hbridgev then
  pal(14,getanmcol())
  clip(0,hbridgety*8,127,4)
  for tx in all(hbridgetx) do
   local x=tx*8
   local y=hbridgety*8-anmtim%8
   spr(getanimspr(hbridgeanm),x,y)
   spr(getanimspr(hbridgeanm),x,y+8)
  end
  clip()
  pal()
 end
end

function teleport()
 if getteleport()==1 then
  cancelprism()
  cancelbridge()
  --save start point in case
  --of trying to teleport offscreen
  htsx=htx
  htsy=hty
  hinc=hflip and -1 or 1
  hstate="teleport"
 end
end

function cancelprism()
 if (hprismv and gettricaster()==0) toggleprism()
end

function cancelbridge()
 if (hbridgev and gettricaster()==0) togglebridge()
end

function startcast(func)
 if (func==togglebridge and getbridge()==1) or
    (func==toggleprism and getprism()==1) or
    (func==teleport and getteleport()==1) then
  cancelprism()
  cancelbridge()
  if tilebeneath() then
   togglefunc=func
   hanim=cranim(split"67,74",4)
   hpause=32
   hstate="cast"
  end
 end
end

function wpninput()
 if btnp(Ž) and
    not btn(”) and
    not hprojalv and
    hstate!="die" then
  if hwep==0 then
   sfx(8,-1,0,3)
   sfx(9,-1,0,7)
   hprojalv=true
   hprojwep=hwep
   hprojlif=26+getprojlif()
   local xoff=hflip and (getprojlif()>1 and 7 or 9) or -4
   hprojx=htx*8+xoff+hxo
   hprojy=hty*8-2+hyo
   hprojxinc=hflip and -2.25 or 2.25
  elseif hwep==1 then
   sfx(9,-1,7,11)
   hprojalv=true
   hprojwep=hwep
   hprojx=htx*8+2
   hprojy=-8
   hprojxinc=2
  end
 end
end

function groundinput()
 if btn(‹) then
  if (hflip==false) hpause=0
  hpause+=1
  hflip=true
  if not gettilesol(htx-1,hty) and
     hpause>=4 then
   hinc=-1
   hstate="walk"
  end
 elseif btn(‘) then
  if (hflip==true) hpause=0
  hpause+=1
  hflip=false
  if not gettilesol(htx+1,hty) and
     hpause>=4 then
   hinc=1
   hstate="walk"
  end
 end
 if btn(—) and not btn(”) and not btn(ƒ) then
  tryrise()
 elseif btnp(—) and btn(”) then
  if hprismv then
   toggleprism()
  else
   startcast(toggleprism)
  end
 elseif btnp(—) and btn(ƒ) then
  if hbridgev then
   togglebridge()
  else
   startcast(togglebridge)
  end
 elseif btnp(Ž) and btn(”) then
  startcast(teleport)
 else
  tryclimb()
 end
end

function airinput()
 if btn(‹) then
  if (hflip==false) hpause=0
  hpause+=1
  hflip=true
  if not gettilesol(htx-1,hty) and
     hpause>=4 then
   hrisedist=getrismax()
   hinc=-getflyspd()
   hstate="fly"
  end
 elseif btn(‘) then
  if (hflip==true) hpause=0
  hpause+=1
  hflip=false
  if not gettilesol(htx+1,hty) and
     hpause>=4 then
   hrisedist=getrismax()
   hinc=getflyspd()
   hstate="fly"
  end
 elseif btn(—) and not btn(”) and not btn(ƒ) then
  tryrise()
 elseif btn(”) then
  tryclimb()
 elseif btn(ƒ) then
  tryfall()
 end
end

function tryrise()
 if hrisedist<getrismax() then
  if not gettilesol(htx,hty-1) and
     not gettilelad(htx,hty) then
   if (hstate!="float") hanim=cranim(hsrise,1)
   hstate="rise"
  end
 end
end

function tilebeneath()
 return gettilesol(htx,hty+1) or
        gettilelad(htx,hty) or
        gettilelad(htx,hty+1)
end

function tryfall()
 if tilebeneath() then
  heklstand()
 else
  if hstate=="fly" and
     gettilelad(htx,hty) and
     gettileop(htx,hty+1) then
   hstate="float"
  else
   hanim=cranim(hfall,1)
   hstate="fall"
  end
 end
end

function tryclimb()
 if btn(ƒ) then
  if gettilelad(htx,hty+1) then
   hinc=1
   hanim=cranim(hclimb,4)
   hstate="climb"
  elseif gettileop(htx,hty+1) then
   hanim=cranim(hfall,1)
   hstate="fall"
  end
 elseif btn(”) then
  if gettilelad(htx,hty) then
   hinc=-1
   hanim=cranim(hclimb,4)
   hstate="climb"
  end
 end
end

function tryhoriztrans()
 if htx==0 then
  transroomleft()
  return true
 elseif htx==15 then
  transroomright()
  return true
 end
end

function updhit()
 if hitc>0 then
  hitc-=1
 end
end

function heklstand()
 hrisedist=0
 hfltdist=0
 hanim=cranim(hwalk,2)
 hstate="stand"
end

function updhekl()
 if hstate=="stand" then
  groundinput()
  if (not tilebeneath()) tryfall()
 elseif hstate=="walk" then
  if (hanim.frames[1]!=64) hanim=cranim(hwalk,2)
  hxo+=hinc
  if abs(hxo)==8 then
   htx+=hinc
   hxo=0
   local didt=tryhoriztrans()
   groundinput()
   tryfall()
   if (didt) savehekl()
  end
  uanim(hanim)
 elseif hstate=="rise" then
  hyo-=getrisspd()
  if flr(hyo)==-4 then
   hanim=cranim(hrise,4)
  end
  if hyo<=-8 then
   hrisedist+=1
   hty-=1
   hyo=0
   hstate="float"
   if (hty==0) transroomup()
  end
  uanim(hanim)
 elseif hstate=="float" then
  airinput()
  uanim(hanim)
 elseif hstate=="fly" then
  hxo+=hinc
  if abs(flr(hxo))==8 then
   htx+=sgn(hinc)
   hxo=0
   hfltdist+=1
   if hfltdist==getfltmax() or
      tilebeneath() then
    tryfall()
   else
    hstate="float"
   end
   tryhoriztrans()
  end
  uanim(hanim)
 elseif hstate=="fall" then
  hyo+=2
  if hyo==8 then
   hyo=0
   hty+=1
   if hty==11 then
    transroomdown()
   else
    tryfall()
   end
  end
  if (gettilesol(htx,hty+1)) heklstand()
  if (hstate=="stand") sfx(10,-1,25,4)
  uanim(hanim)
 elseif hstate=="climb" then
  hyo+=hinc
  if abs(hyo)==8 then
   hpause=0
   hyo=0
   hty+=hinc
   hstate="onlad"
   if hty==0 then
    transroomup()
   elseif hty==11 then
    transroomdown()
   else
    tryclimb()
   end
  else
   uanim(hanim)
  end
 elseif hstate=="onlad" then
  groundinput()
  if not gettilelad(htx,hty) or
     gettilelad(htx,hty) and
     gettilesol(htx,hty+1) then
   heklstand()
  end
  tryclimb()
 elseif hstate=="cast" then
  hpause-=1
  if hpause==0 then
   togglefunc()
  end
  uanim(hanim)
 elseif hstate=="teleport" then
  if htx<=15 and
     htx>=0 and
     gettiletyp(htx+hinc,hty)<2 then
   htx+=hinc
  else
   if htx>15 or htx<0 then
    htx=htsx
    hty=htsy
   else
    sfx(8,-1,3,15)
   end
   tryfall()
  end
 elseif hstate=="die" then
  uanim(hanim)
 end
 wpninput()
 checkitem()
 checkhurt()
 checkwater()
 updhproj()
 uanim(hprismanm)
 updhit()
end

function setheklcols(col)
 pal(1,col)
 pal(5,col)
 pal(12,col)
end

function drwhekl()
 if hitc>0 or hstate=="teleport" then
  local col=getanmcol()
  setheklcols(col)
 end
 spr(getanimspr(hanim),htx*8+hxo,hty*8+hyo,1,1,hflip)
 pal()
end

function getmprojr()
 return getprojlifsav()>1 and
 {hprojx,hprojy,hprojx+5,hprojy+5} or
 {hprojx,hprojy,hprojx+3,hprojy+3}
end

function gettprojr()
 return {hprojx+1,hprojy,hprojx+6,hprojy+5}
end

function getprojr()
 return hprojwep==0 and getmprojr() or gettprojr()
end

function updhproj()
 if hprojalv then
  if hprojwep==0 then
   hprojx+=hprojxinc
   hprojlif-=1
   hprojalv=hprojlif>0
  elseif hprojwep==1 then
   hprojx=htx*8+hxo
   hprojy+=hprojxinc
   if hprojy>hty*8-4 then
    hprojalv=false
   end
  end
 end
end

function drwhproj()
 if hprojalv then
  local col=getanmcol()
  pal(12,col)
  pal(14,col)
  pal(15,col)
  local misspr=getprojlifsav()>1 and 78 or 77
  spr(hprojwep==0 and misspr or 93,hprojx,hprojy)
  pal()
 end
end
-->8
--entities

function initentities()
 enemies={}
 splodes={}
 spfuncs={
  crghost,
  crtrent,
  crhbat,
  crvbat,
  crbones,
  crspider,
  noop,
  crgargoyle,
  crgolem,
  crraven,
  crgoblin,
  crlizard,
  crbird,
  crgargboss,
  cramondus
 }
end

function crntt(x,y)
 local ntt={
  a=true,
  e=false,
  ox=x,
  oy=y,
  x=x,
  y=y,
  f=false,
  col={}
 }
 return ntt
end

function updntts(ntts)
 for ntt in all(ntts) do
  if ntt.a then
   ntt:upd()
  else
   del(ntts,ntt)
  end
 end
end

function drwntts(ntts)
 for ntt in all(ntts) do
  if ntt.a then
   ntt:drw()
  end
 end
end

function cntalventts(ntts)
 local c=0
 for ntt in all(ntts) do
  c+=(ntt.a and ntt.e) and 1 or 0
 end
 return c
end

function getfirecol()
 return (song==24) and split"3,8,11,9,2,3" or {}
end

function applynttcol(ntt)
 for i=1,#ntt.col,2 do
  local c=ntt.col
  pal(c[i],c[i+1])
 end
end

function drwanimntt(ntt)
 applynttcol(ntt)
 spr(getanimspr(ntt.anim),ntt.x,ntt.y,1,1,ntt.f)
 pal()
end

function crsplode(x,y)
 return smoosh(crntt(x,y),{
  anim=cranim(split"96,97,98",2),
  upd=
   function(splode)
    uanim(splode.anim)
    if splode.anim.pc==1 then
     splode.a=false
    end
   end,
  drw=
   function(splode)
    pal(11,getanmcol())
    drwanimntt(splode)
    pal()
   end
 })
end

function crenemy(x,y,h)
 return smoosh(crntt(x,y),{
  e=true,
  im=false,
  it=false,
  boss=false,
  h=h,
  eproj={},
  gr=
   function(enemy)
    return {
     enemy.x+enemy.r[1],
     enemy.y+enemy.r[2],
     enemy.x+enemy.r[3],
     enemy.y+enemy.r[4]
    }
   end,
  colproj=enemycolproj,
  colhekl=enemycolhekl
 })
end

function colenemies()
 for enemy in all(enemies) do
  if enemy.a then
   enemy.hitw=-1
   enemy:colproj()
   enemy:colhekl()
  end
 end
end

function addeproj(enemy,proj)
 add(enemies,proj)
 add(enemy.eproj,proj)
end

function enemydie(enemy)
 if (enemy.boss) bstate="bossdefeated"
 for proj in all(enemy.eproj) do
  proj.a=false
 end
 enemy.a=false
 add(splodes,crsplode(enemy.x,enemy.y))
end

function enemycolproj(enemy)
 if hprojalv then
  local er,pr=enemy:gr(),getprojr()
  if colrect(er,pr) then
   if (enemy.im and hprojwep==0) or
      (enemy.it and hprojwep==1) then
    sfx(5)
    hprojalv=false
   else
    sfx(10,-1,0,4)
    enemy.hitw=hprojwep
    enemy.h-=((getprojlifsav()>1) and 2 or 1)
    if enemy.h<=0 then
     enemydie(enemy)
    end
    hprojalv=false
   end
  end
 end
end

function enemycolhekl(enemy)
 if halv then
  local er,hr=enemy:gr(),getheklr()
  if colrect(er,hr) then
   hithekl()
  end
 end
end

function crhbat(x,y)
 return smoosh(crenemy(x,y,4),{
  anim=cranim(split"99,100",3),
  r=split"0,0,7,5",
  upd=updhbat,
  drw=drwanimntt,
  oy=y+2,
  xinc=1
 })
end

function updhbat(hbat)
 hbat.y=hbat.oy+sin(time()*4)*2
 hbat.x+=hbat.xinc
 local xoff=hbat.xinc>0 and 8 or -1
 if not gettileop(pxtotx(hbat.x+xoff,hbat.y+4)) then
  hbat.xinc=-hbat.xinc
 end
 uanim(hbat.anim)
end

function crvbat(x,y)
 return smoosh(crenemy(x,y,4),{
  anim=cranim(split"99,100",3),
  r=split"2,0,5,7",
  upd=updvbat,
  drw=drwanimntt,
  ox=x+2,
  yinc=1
 })
end

function updvbat(vbat)
 vbat.x=vbat.ox+sin(time()*4)*2
 vbat.y+=vbat.yinc
 local yoff=vbat.yinc>0 and 8 or -1
 if not gettileop(pxtotx(vbat.x+4,vbat.y+yoff)) then
  vbat.yinc=-vbat.yinc
 end
 uanim(vbat.anim)
end

function crwalker(x,y,h,fms,xs)
 return smoosh(crenemy(x,y,h),{
  anim=cranim(fms,3),
  r=split"0,0,7,5",
  upd=updwalker,
  drw=drwanimntt,
  xinc=xs
 })
end

function updwalker(walker)
 walker.x+=walker.xinc
 local xoff=walker.xinc>0 and 8 or -1
 if not gettileflr(pxtotx(walker.x+xoff,walker.y+8)) then
  walker.xinc=-walker.xinc
 end
 walker.f=walker.xinc<0
 uanim(walker.anim)
end

function crspider(x,y)
 return crwalker(x,y,6,split"101,102",-1)
end

function crgolem(x,y)
 return smoosh(crenemy(x,y,7),{
  anim=cranim({103},1),
  r=split"0,0,7,5",
  upd=updgolem,
  drw=drwanimntt,
  c=64,
  state="stand"
 })
end

function updgolem(golem)
 golem.f=htx*8<golem.x
 if golem.state=="stand" then
  golem.c-=1
  if golem.c==0 then
   golem.anim=cranim({104},1)
   golem.c=8
   golem.state="rise"
  end
 elseif golem.state=="rise" then
  golem.y-=1
  golem.c-=1
  if golem.c==0 then
   golem.c=4
   golem.state="fall"
  end
 elseif golem.state=="fall" then
  golem.y+=2
  golem.c-=1
  if golem.c==0 then
   sfx(10,-1,4,10)
   addeproj(golem,crproj(htx*8+1,-8,{1,0,4,3},{105},0,2))
   cshk=8
   golem.anim=cranim({103},1)
   golem.c=64
   golem.state="stand"
  end
 end
end

function crbird(x,y)
 return smoosh(crenemy(x,y,33),{
  boss=true,
  anim=cranim(split"106,107",4),
  r=split"0,0,7,5",
  upd=updbird,
  drw=drwanimntt,
  xs=-1,
  ys=0,
  c=0,
  ft=0.0,
  state="main"
 })
end

function updbird(bird)
 if bird.state=="main" then
  bird.x+=bird.xs
  bird.y+=bird.ys
  local tx,ty=
   flr(bird.x>>3),
   flr(bird.y>>3)
  if flr(bird.x)%8==0 and
     flr(bird.y)%8==0 then
   if (bird.ys==0 and tx==htx and ty>=hty-1) bird.xs=-2
   if gettilesol(tx+direc(bird.xs),ty+direc(bird.ys)) then
    if bird.xs<0 then
     bird.xs=0
     bird.ys=-2
     bird.c=16
    elseif bird.ys<0 then
     bird.xs=2
     bird.ys=0
    elseif bird.xs>0 then
     bird.xs=0
     bird.ys=2
     bird.c=16
    elseif bird.ys>0 then
     bird.xs=ty>=hty-1 and -1 or -2
     bird.ys=0
    end
   end
   if tx==htx and
      tx>1 and
      ty<hty and
      bird.xs!=0 and
      (time()-bird.ft)>3 then
    sfx(10,-1,14,9)
    addeproj(bird,crfire(tx*8,ty*8,0,2.5))
    addeproj(bird,crfire(tx*8+5,ty*8,0,2.5))
    bird.ft=time()
    bird.c=32
    bird.state="fire"
   elseif tx==14 and ty==8 then
    sfx(10,-1,14,9)
    addeproj(bird,crfire(tx*8,ty*8-1,-2.5,0))
    addeproj(bird,crfire(tx*8,ty*8+4,-2.5,0))
    bird.ft=time()
    bird.c=32
    bird.state="fire"
   end
  end
  if bird.c>0 then
   bird.c-=1
   if (bird.c==0) bird.f=not bird.f
  end
  uanim(bird.anim)
 elseif bird.state=="fire" then
  bird.c-=1
  if (bird.c==0) bird.state="main"
  uanim(bird.anim)
 end
end

function crproj(x,y,r,fms,xs,ys)
 return smoosh(crenemy(x,y,1),{
  anim=cranim(fms,1),
  xs=xs,
  ys=ys,
  r=r,
  e=false,
  colproj=function(proj) end,
  upd=updproj,
  drw=drwanimntt
 })
end

function updproj(proj)
 proj.x+=proj.xs
 proj.y+=proj.ys
 local r=proj:gr()
 local px,py=hprismtx*8,hprismty*8
 local pr={px,py,px+7,py+7}
 if proj.x<-4 or
    proj.x>127 or
    proj.y>92 or
    colrect(r,pr) then
  proj.a=false
 end
end

function crfire(x,y,xs,ys)
 return crproj(x,y,split"0,0,3,3",{108},xs,ys)
end

function crtrent(x,y)
 return smoosh(crenemy(x,y,7),{
  it=true,
  anim=cranim({110},1),
  r=split"0,0,7,5",
  leaft=150,
  upd=updtrent,
  drw=drwanimntt
 })
end

function updtrent(trent)
 trent.f=htx*8>trent.x
 trent.leaft-=1
 if trent.leaft==0 then
  sfx(4)
  addeproj(trent,crleaf(trent.x+2,trent.y+2,trent.f and 2 or -2,0))
  trent.leaft=150
 end
end

function crleaf(x,y,xs,ys)
 return crproj(x,y,split"0,0,3,3",{111},xs,ys)
end

function crraven(x,y)
 return smoosh(crenemy(x,y,6),{
  anim=cranim(split"112,113",4),
  r=split"0,0,7,5",
  oy=8,
  xs=0,
  t=32,
  state="pause",
  upd=updraven,
  drw=drwanimntt
 })
end

function updraven(raven)
 raven.f=htx*8>raven.x
 local tx,ty=
  flr(raven.x>>3),flr(raven.y>>3)
 if raven.state=="pause" then
  raven.t-=1
  if raven.t==0 then
   raven.state="descend"
  end
 elseif raven.state=="descend" then
  raven.y+=1
  if ty>=hty then
   raven.xs=raven.f and 2 or -2
   raven.state="rush"
  end
 elseif raven.state=="rush" then
  if raven.x%8==0 and
     ((raven.xs<0 and tx<=htx) or
     (raven.xs>0 and tx>=htx)) then
   raven.state="rise"
  else
   raven.x+=raven.xs
  end
 elseif raven.state=="rise" then
  raven.y-=2
  if raven.y<=raven.oy then
   raven.y=raven.oy
   raven.t=32
   raven.state="pause"
  end
 end
 uanim(raven.anim)
end

function crbones(x,y)
 return crwalker(x,y,9,split"114,115,114,116",-.5)
end

function crgoblin(x,y)
 return smoosh(crenemy(x,y,6),{
  anim=cranim(split"117,118",4),
  col=getfirecol(),
  r=split"1,1,6,6",
  tx=flr(x>>3),
  ty=flr(((y==120) and -8 or y)>>3),
  txo=0,
  tyo=0,
  xs=-1,
  ys=1,
  state="walk",
  upd=updgoblin,
  drw=drwanimntt
 })
end

function checkgobjump(goblin)
 if goblin.ty>0 and
    gettilesol(goblin.tx+sgn(goblin.xs),goblin.ty) and
    not gettilesol(goblin.tx,goblin.ty-1) and
    not gettilesol(goblin.tx+sgn(goblin.xs),goblin.ty-1) then
  goblin.ys=-1
  goblin.state="jump"
  return true
 end
end

function checkgobhoriz(goblin)
 if goblin.tx+sgn(goblin.xs)<0 or
    goblin.tx+sgn(goblin.xs)>15 or
    gettilesol(goblin.tx+sgn(goblin.xs),goblin.ty) then
  goblin.xs=-goblin.xs
 end
end

function updgoblin(goblin)
 goblin.f=goblin.xs>0
 if goblin.state=="walk" then
  if (checkgobjump(goblin)) return
  goblin.txo+=goblin.xs
  if abs(goblin.txo)==8 then
   goblin.txo=0
   goblin.tx+=sgn(goblin.xs)
   if not gettilesol(goblin.tx,goblin.ty+1) then
    goblin.ys=1
    goblin.state="fall"
   else
    if not checkgobjump(goblin) then
     checkgobhoriz(goblin)
    end
   end
  end
  uanim(goblin.anim)
 elseif goblin.state=="fall" then
  goblin.tyo+=goblin.ys
  if abs(goblin.tyo)==8 then
   goblin.tyo=0
   goblin.ty+=sgn(goblin.ys)
   if gettilesol(goblin.tx,goblin.ty+1) then
    if not checkgobjump(goblin) then
     checkgobhoriz(goblin)
     goblin.state="walk"
    end
   end
  end
 elseif goblin.state=="jump" then
  goblin.tyo+=goblin.ys
  if abs(goblin.tyo)==8 then
   goblin.tyo=0
   goblin.ty+=sgn(goblin.ys)
   goblin.state="walk"
  end
 end
 goblin.x=goblin.tx*8+goblin.txo
 goblin.y=goblin.ty*8+goblin.tyo
 if goblin.y>88 then
  enemydie(goblin)
 end
end

function drwanimnttoff(ntt)
 spr(getanimspr(ntt.anim),ntt.x,ntt.y+16,1,1,ntt.f)
end

function crghost(x,y)
 return smoosh(crenemy(x,y,5),{
  anim=cranim({119},1),
  r=split"0,0,7,7",
  upd=updghost,
  drw=drwanimntt
 })
end

function updghost(ghost)
 local hx,hy=htx*8+hxo,hty*8+hyo
 ghost.x+=((ghost.x<=hx) and .4 or -.4)
 ghost.y+=((ghost.y<=hy) and .4 or -.4)
 if (abs(ghost.x-hx)<.4) ghost.x=hx
 if (abs(ghost.y-hy)<.4) ghost.y=hy
 ghost.f=ghost.x<hx
end

function crgargoyle(x,y,h)
 return smoosh(crenemy(x,y,h and h or 7),{
  anim=cranim(split"56,57",8),
  r=split"1,1,6,5",
  xs=2,
  t=128,
  upd=updgargoyle,
  drw=drwgargoyle
 })
end

function updgargoyle(gargoyle)
 if gettileop(pxtotx(gargoyle.x+4,gargoyle.y+4)) then
  if (gargoyle.xs<0 and not gettileop(pxtotx(gargoyle.x-1,gargoyle.y))) or
     (gargoyle.xs>0 and not gettileop(pxtotx(gargoyle.x+9,gargoyle.y))) then
   gargoyle.xs=-gargoyle.xs
   gargoyle.x+=gargoyle.xs
  else
   gargoyle.x+=gargoyle.xs
  end
  uanim(gargoyle.anim)
 end
 gargoyle.t-=1
 if gargoyle.t==0 then
  gargoyle.t=128
  addeproj(gargoyle,crproj(gargoyle.x+1,gargoyle.y,{0,2,5,5,},{120},0,1))
 end
end

function drwgargoyle(gargoyle)
 palt(12,true)
 palt(0,false)
 pal(0,getanmcol())
 drwanimntt(gargoyle)
 pal()
end

function crlizard(x,y)
 local wanim,tanim=
  split"121,122,121,123",split"123,124"
 local lizard=smoosh(crwalker(x,y,9,nil,1),{
  im=true,
  it=true,
  wanim=wanim,
  tanim=tanim,
  anim=cranim(wanim,4),
  col=getfirecol(),
  t=0,
  p=0,
  upd=updlizard,
  state="walk"
 })
 return lizard
end

function lizardthrow(lizard)
 local spear=crproj(lizard.x,lizard.ty,{1,0,4,0},{105},lizard.f and -2 or 2,0)
 spear.drw=
  function(spear)
   applynttcol(spear)
   line(spear.x,spear.y,spear.x+5,spear.y,2)
   pal()
  end
 spear.col=lizard.col
 addeproj(lizard,spear)
end

function updlizard(lizard)
 if lizard.state=="walk" then
  updwalker(lizard)
  lizard.t+=1
  lizard.f=(lizard.t&32==0) and true or false

  if lizard.y==hty*8 then
   lizard.im=false
   lizard.it=false
   lizard.f=lizard.x>htx*8
   lizard.ty=lizard.y
   lizardthrow(lizard)
   lizard.anim=cranim(lizard.tanim,4)
   lizard.state="throw"
  elseif lizard.y-8==hty*8 then
   lizard.im=false
   lizard.it=false
   lizard.ty=hty*8
   lizard.yinc=-2
   lizard.oy=lizard.y
   lizard.state="jump"
  else
  end
 elseif lizard.state=="jump" then
  lizard.y+=lizard.yinc
  if lizard.y<=lizard.oy-8 then
   lizard.f=lizard.x>htx*8
   lizardthrow(lizard)
   lizard.yinc=-lizard.yinc
  elseif lizard.y>=lizard.oy then
   lizard.anim=cranim(lizard.tanim,4)
   lizard.state="throw"
  end
 elseif lizard.state=="throw" then
  uanim(lizard.anim)
  if lizard.anim.f==2 then
   lizard.p=64
   lizard.state="pause"
  end
 elseif lizard.state=="pause" then
  if lizard.p>0 then
   lizard.p-=1
   return
  end
  lizard.im=true
  lizard.it=true
  lizard.anim=cranim(lizard.wanim,4)
  lizard.state="walk"
 end
 if (lizard.state!="walk") lizard.f=lizard.x>htx*8
end

function crgargboss(x,y)
 return smoosh(crgargoyle(x,y,65),{
  boss=true,
  oy=y,
  state="main",
  upd=updgargboss,
  drw=
   function(gargboss)
    pal(6,9)
    pal(7,10)
    drwgargoyle(gargboss)
    pal()
   end
 })
end

function updgargboss(gargboss)
 local c=cntalventts(enemies)
 gargboss.im=c>1
 gargboss.it=c>1
 if gargboss.state=="main" then
  if gargboss.x%8==0 then
   if gargboss.x==htx*8 then
    if rnd()>.5 then
     gargboss.state="slam"
     return
    end
   end
  end
  updgargoyle(gargboss)
 elseif gargboss.state=="slam" then
  gargboss.y+=4
  if gargboss.y%8==0 then
   if gettilesol(pxtotx(gargboss.x,gargboss.y+8)) then
    sfx(10,-1,4,10)
    cshk=32
    gargboss.state="pause"
   end
  end
 elseif gargboss.state=="pause" then
  if cshk==0 then
   gargboss.anim=cranim(split"56,57",1)
   gargboss.state="rise"
  end
 elseif gargboss.state=="rise" then
  gargboss.y-=4
  if gargboss.y==gargboss.oy then
   gargboss.xs=abs(gargboss.xs)
   gargboss.anim=cranim(split"56,57",8)
   gargboss.state="main"
  end
  uanim(gargboss.anim)
 end
end

function cramondus(x,y)
 return smoosh(crenemy(x,y,33),{
  boss=true,
  it=true,
  anim=cranim(split"125,126",4),
  spawns={
   split"1,1,8",
   split"1,2,8",
   split"3,5,8",
   split"11,3,2",
   split"12,9,9",
   split"4,3,12",
   split"12,5,12",
   split"7,11,1",
   split"14,2,10"
  },
  r=split"0,0,7,7",
  at=150,
  state="top",
  astate="wait",
  upd=updamondus,
  drw=drwanimntt,
 })
end

function updamondus(amondus)
 amondus.im=(amondus.state=="descend" or amondus.state=="ascend")
 if amondus.state=="top" then
  if (amondus.hitw==0) amondus.state="descend"
 elseif amondus.state=="descend" then
  amondus.y+=.5
  if (amondus.y>>3)==6 then
   amondus.state="bottom"
  end
 elseif amondus.state=="bottom" then
  if (amondus.hitw==0) amondus.state="ascend"
 elseif amondus.state=="ascend" then
  amondus.y-=.5
  if (amondus.y>>3)==2 then
   amondus.state="top"
  end
 end

 if amondus.astate=="wait" then
  amondus.at-=1
  if amondus.at==0 then
   amondus.at=30
   amondus.astate="laugh"
  end
 elseif amondus.astate=="laugh" then
  amondus.at-=1
  if amondus.at==0 then
   local x,y=amondus.x,amondus.y
   addeproj(amondus,cramondproj(x-2,y,-2,0))
   addeproj(amondus,cramondproj(x+6,y,2,0))
   addeproj(amondus,cramondproj(x-2,y+2,-1.5,1.5))
   addeproj(amondus,cramondproj(x+6,y+2,1.5,1.5))
   amondus.anim=cranim(split"125,126",4)
   amondus.at=150
   amondus.astate="wait"
  end
  uanim(amondus.anim)
 end

 if flsh==0 and cntalventts(enemies)<4 then
  sfx(9,-1,7,11)
  repeat
   local spawn=rnd(amondus.spawns)
   local x,y=spawn[1]*8,spawn[2]*8
   local dospawn=true
   for enemy in all(enemies) do
    if enemy.ox==x and
       enemy.oy==y then
     dospawn=false
     break
    end
   end
   if (dospawn) add(enemies,spfuncs[spawn[3]](x,y))
  until dospawn
  flsh=4
 end
end

function cramondproj(x,y,xs,ys)
 return smoosh(crproj(x,y,split"0,0,3,3",{77},xs,ys),{
  drw=drwamondproj
 })
end

function drwamondproj(proj)
 pal(14,getanmcol())
 spr(getanimspr(proj.anim),proj.x,proj.y)
 pal()
end
-->8
--items

function inititems()
 isprs=split"80,95,93,89,91,88,88,76,94,75"
 inams={
  "health sphere",
  "magic missile +1",
  "xecrom's thunder",
  "prism cube",
  "spectral bridge",
  "levitation y +1",
  "levitation x +1",
  "tri-caster",
  "levitation speed",
  "teleportation"
 }
 saves=split"100,84,105,127,66,107,33,15,101,79,26,46,83,20,81,38,0,1,93,104,108,126"
 saves[0]=54
end

--sets item location, sprite,
--and type. makes item visible.
function setitem(tx,ty,typ)
 --item 11 is apparently a
 --special item which means
 --to transition to a boss
 --fight.
 if typ==11 then
  --if this boss is defeated,
  --kill all enemies and return
  if dget(lkpsave(ri))==1 then
   enemies={}
   return
  end
  --otherwise hide enemies
  --and do boss intro
  enemiesv=false
  gstate="initboss"
 end
 itx=tx
 ity=(ty==15) and 9 or ty
 ityp=typ
end

function getitemr()
 return {itx*8,ity*8,itx*8+7,ity*8+7}
end

function drwitem()
 if lkpsave(ri) and dget(lkpsave(ri))==0 then
  pal(14,getanmcol())
  local x,y=itx*8,ity*8
  spr(isprs[ityp],x,y)
  pal()
 end
end

function lkpsave(ri)
 for k,v in pairs(saves) do
  if (ri==v) return k
 end
end

-->8
--rooms

function initrooms()
 metatiles="0000010301010000000500010300000d070102020200000a000f0f11000e0700100f0010000e000000051100040f0f00150018191800001900001e00001f0000210016002323232300000600071f000003000000012727272700001f00000023232300230024241600160007002a000000002c2e2d29072c000000181818002729000000160029002c2d2d000e0f0f00000e00072e00271b330034000000350101310000000023000023002900071800010003000000060500010000000003010702020107000b000f0f11000e000710000f00100e000000000014000f0f001518181a1800001d00190000001e0018180016180700232300000600181e000007000001002727272700001f00001823230023000024180016160016002a002d2e002c0000291600000000181818270000003100150000292c0700000f0000100000110f00230018333334340000350100310000270723000007002929181800010400030102020202070100050800070303000002020200100f0011100700000f0000000f000c05050000000f1015161b180017001c371f00001900001e2000221600232323000006060607001f190024261f19270027282727001f242423002300232300001600001607162b0000002c002d2d00071602020017180000002900000016152900162d2d000f0f100e0e0f00072d00271502021800353511010332000027363623362316000007000003000001020002020201000000090001070c000302020202100f001110000700000f00000f0d000505000000100f1516171818171b00001e37001d1937001818001618071523002306060018001e1d0025241e1d270028272700001f241800230023230000180016001616002b002d2d2c00000000162c000202171800270029293230160000291607000e0f0e0000000e000f0000001502021818003511010732002727363623360700160018185555655555555555555555555555a5575555d5555555555a5555555555555555555555555555d575a5a65555555555555566669aaa95659aa55956a5955a65a99a5555995577555555a5aa65aa5555555555555555ff5fffffffff5aa5aaaa5555555555555a5a555555556655ff55555555555555555555aaaaaaaaaaaaffffffffffff5555ffffffffff555555555555555555ff55ff5aaaaaaaaaffff5f55555555fffff5f555ffff5555556666003fc0f0cfcf0c3f3fcf37ccc00c00b077ddfef0f31f0f0f03fffff00fff4411f0cc33c030ff02080fcfc00000ffff0fff0000f0000000f00f30c00f03f00c0cc00cff00ddcffff0030fff0c44f00f0fd00f0f3fcffff0ffff0f0cf00f0f0cfcf3cc33cf0cf0c0cc33f00f770c000f33330ff0ccccf077cf0c0f03fffff033c0cf033303ff0ccc33ffddcc03ffcfcc3c0ccf3077cc30cc0f0f0f0000080aafffcdfff0033f10f00f00dd0cf33077f3"
 roomtitles="summoner amondusrant's revenge  floating palace doorstep to doomnevermore       trial by talons raven haven     blackbirds      the stratosphereamong the stars close to heaven the canopy      climbing titans high garden     jack's landing  treetop atelier demon foyer     violet halls    dak's quarters  master's fall   a new leaf      logger's lane   branching paths woodsman's watchbreeze in trees rustling leaves tidy treehouse  fearful foliage lumbering climb trunk tower     fall of faith   trent's hollow  the mad raven   nether palace   one easy way outthe void        strong limbs    detour de l'armethe unreachable?wooden bridge   dangerous arbor trunk trail     conjoined giantsnocturnal flyer fall guy        air of mystery  diamond in sky  goblin gauntlet the far side    stalking dead   fools 'n ghosts prim graveyard  parenchyma rise the back yard   hekl's home     the front yard  the primwoods   crossroads      bush-e-faces    primwoods east  w. raven bridge e. raven bridge the elderwood   inside elderwoodkyr temple ruinswalk of faith   strange strides damp dwelling   reservoir flood hekl's well     venomous turn   torchlit tunnelshead games      kaplan caverns  mine draft      scythe stone    burnt offerings pit of scorchingbrimstone grottobelow the root  collapsed stairsaltar top west  altar top east  heavy barrels   movin' on up    dank storage    old storage roomsplit decision  fluttering fangssnakes & laddersstone guardian  inner sanctum   burning heart   charwit reborn  salamanders     overpass rock   bottom stairwellthe untrusted   gargoyle toil   speedy ascensionthe magic loot  diamond in roughthe lone golem  enemy mine      charwit         initial findingsfirst in flight a trident shrinegeneral rant    hot, hot feet   toastin' goblinssearing trench  the under river undertow flow   lizard's leap   tails 'n scales drag the waters the updraft     the lost golem  hunter's choice twisted cistern fortune or follystyx and stones slippery steps  limestone path  fiendish aquiferbeancy & flerg  solemn alcove   "
 areamods={
  --overworld
  {split"3,0,15,3",{},0},
  --underworld
  {split"3,4,10,6",{},34},
  {split"0,4,2,6",split"4,5,9,6",34},
  {split"15,4,15,4",{},34},
  --airship
  {split"0,0,3,2",split"6,2,5,1"},
  {split"0,0,2,1",{},29},
  --water passage
  {split"0,7,15,7",split"2,3,4,5",16},
  --brimstone area
  {split"11,4,14,6",split"2,8,4,9",24},
  {split"15,5,15,6",split"2,8,4,9",24}
 }
 --create 2d array for collisions
 roomtyp={}
 for y=0,11 do
  roomtyp[y]={}
  for x=0,15 do
   roomtyp[y][x]=0
  end
 end
end

function initroom()
 hprismv=false
 hbridgev=false
 erasebridge()
 eraseprism()
 modarea(
  function(area)
   if area[3] and area[3]!=song then
    song=area[3]
    music(song)
   end
  end)
 spawnroomenemies()
 spawnroomitem()
 getroomtyps()
end

function spawnroomenemies()
  initentities()
  local elocaddr=ri*58+50
  for i=0,3 do
   local eindex=peekr(elocaddr+i)
   local ecoord=peekr(elocaddr+i+4)
   local x=(ecoord&0xf)*8
   local y=(flr(ecoord>>4)*8)
   local spfunc=spfuncs[eindex]
   if (spfunc) add(enemies,spfunc(x,y))
  end
end

function spawnroomitem()
  local ilocaddr=ri*58+48
  local iindex=peekr(ilocaddr)
  local icoord=peekr(ilocaddr+1)
  local x=icoord&0xf
  local y=flr(icoord>>4)

  setitem(x,y,iindex)
end

function getroomtyps()
 for y=0,11 do
  for x=0,15 do
   roomtyp[y][x]=ldtiletyp(x,y)
  end
 end
end

function peekr(a)
 return a<0x1000
  and peek(0x2000+a)
  or peek(a)
end

--gets metatile from current
--room. coordinates are
--large metatile coordinates
--which is a 2x2 set of
--8x8 tiles, starting at top
--left of current room.
--0-7 x 0-5 y
function getmetatile(x,y)
 local ti,res=
  peekr(ri*58+y*8+x),{}
 for i=ti,ti+875,175 do
  add(res,tonum("0x"..sub(metatiles,i*2+1,i*2+2)))
 end
 return res
end

--get tile for
--room tile at x and y in
--tile coordinates
function gettile(x,y)
 return
  getmetatile(flr(x>>1),flr(y>>1))
   [(y&1)*2+(x&1)+1]
end

--get one byte out of a six
--byte metatile
function gettiledat(x,y,i)
 return (getmetatile(flr(x>>1),flr(y>>1))[i]>>((3-((y&1)*2+(x&1)))*2))&0x3
end

--load tile type for
--room tile at x and y in
--tile coordinates
--0=open, 1=ladder, 2=hurt, 3=solid
function ldtiletyp(x,y)
 return gettiledat(x,y,6)
end

--get tile type for
--room tile at x and y in
--tile coordinates
--0=open, 1=ladder, 2=hurt, 3=solid
function gettiletyp(x,y)
 if (x<0 or x>15 or y<0 or y>11) return 0
 return roomtyp[y][x]
end

function gettileop(x,y)
 return gettiletyp(x,y)==0
end

function gettilelad(x,y)
 return gettiletyp(x,y)==1
end

function gettilehurt(x,y)
 return gettiletyp(x,y)==2
end

function gettilesol(x,y)
 return gettiletyp(x,y)==3
end

function gettileflr(x,y)
 return (gettilesol(x,y) and not gettilesol(x,y-1)) or
        (gettilelad(x,y) and gettileop(x,y-1))
end

--sets tile type
--x and y are in tile
--coordinates.
--0=open, 1=ladder, 2=hurt, 3=solid
function settiletyp(x,y,t)
 if (x<0 or x>15 or y<0 or y>11) return
 roomtyp[y][x]=t
end

--converts pixel coordinates
--to tile coordinates
function pxtotx(x,y)
 return flr(x>>3),flr(y>>3)
end

function drwtrans()
 cls()
 drwhekl()
 drwhud()
 flip()
end

function fintrans()
 hprojalv=false
 savehekl()
 initroom()
end

function transroom(xs,ys,d,rinc)
 for i=1,d do
  htx+=xs
  hty+=ys
  drwtrans()
 end
 ri+=rinc
 fintrans()
end

function transroomleft()
 transroom(1,0,14,-1)
end

function transroomright()
 transroom(-1,0,14,1)
end

function transroomup()
 transroom(0,1,10,-16)
end

function transroomdown()
 transroom(0,-1,10,16)
end

function drwroom()
 modarea(
  function(area)
   for i=1,#area[2],2 do
    pal(area[2][i],area[2][i+1])
   end
  end)
 for y=0,11 do
  for x=0,15 do
   local t,f=gettile(x,y),false
   if (t==53) f=(anmtim&4)==0
   spr(t,x*8,y*8,1,1,f)
  end
 end
 pal()
end

function modarea(func)
 local ry,rx=flr(ri>>4),flr(ri&0x0f)
 for area in all(areamods) do
  if rx>=area[1][1] and
     rx<=area[1][3] and
     ry>=area[1][2] and
     ry<=area[1][4] then
   func(area)
  end
 end
end
-->8
--animation

function cranim(frames,s)
 local anim={
  frames=frames,
  f=1,
  c=s,
  s=s,
  pc=0
 }
 return anim
end

function uanim(anim)
 anim.c-=1
 if anim.c==0 then
  anim.c=anim.s
  anim.f+=1
  if anim.f>#anim.frames then
   anim.pc+=1
   anim.f=1
  end
 end
end

function getanimspr(anim)
 return anim.frames[anim.f]
end
-->8
--utilities

function noop() end

--puts all kv pairs of b
--into a
function smoosh(a,b)
 for k,v in pairs(b) do
  a[k]=v
 end
 return a
end

function wframes(f)
 for i=1,f do flip() end
end

function box(x,y,w,h,i,o)
 local lx,rx,
       ty,by=
  x,x+w,
  y,y+h
 rectfill(lx+1,ty+1,rx-1,by-1,i)
 line(lx+1,ty,rx-1,ty,o)
 line(lx,ty+1,lx,by-1,o)
 line(lx+1,by,rx-1,by,o)
 line(rx,ty+1,rx,by-1,o)
end

--tests if two rects intersect
function colrect(a,b)
 return not
  (b[1]>a[3] or
  b[2]>a[4] or
  b[3]<a[1] or
  b[4]<a[2])
end

function direc(x)
 return x==0 and 0 or sgn(x)
end

--prints some text, then returns
--a table of pixel coords that
--can be used later for scaling
function get_text_pixels(text)
 local pixels={}
 print(text,0,0,7)
 for y=0,7 do
  for x=0,#text*8-1 do
   local col=pget(x,y)
   if col!=0 then
    add(pixels,{x,y})
   end
  end
 end
 return pixels
end

function scale_text(pixels,tlx,tly,sx,sy,col,func)
 for pixel in all(pixels) do
  func(pixel[1]*sx+tlx,pixel[2]*sy+tly)
 end
end
__gfx__
00000000044044409990999004404440777777704a99aa9400444400044444400000000000000002200000000200007008000000000000800444444024222244
00000000404400049044900440440004707000709404409904aa994000000000000000000077770200000000777707778a800000000008a84222222442200224
00000000440044004400440044004400700770709404494904aa994004444440200000000777777228000000077002228a800000000008a84224024242240242
0000000004400440044004400440044077000700a40490494aa99994000000002000000000777702280000008888888844400000000004440224422202244222
0000000000444044004440440044404470700700a40940494aa99994044444402022222222222202208800000088880005000000000000500022222200222222
00000000440044044400440444004404700770009494404904aa9940000000002088888888888802288880002088880244000000000000442042222020422220
00000000044004400440044004400440777070009904404904aa9940044444402082882882882802220020002088880204000000000000402442022024420220
00000000004400040044000400440004070070004a9a99a400444400000000002082882882882802200020002082820200000000000000002224422222244222
24222244044444400000000000000000077777770bb3bb3044444044404004404040044099099090999099990000000000000000999099999990900999909999
4220022442222224770077707700777007000707b30b303b444044444044040440440404b0404404404440400000000000000000404440404044499040444040
422402424224024207000070070000700707700740444404404444044044404440404044b0040044440404040000000000000000440404044404040444040404
022442220224422207007770070007700070007744440444444404440404404004044040b0404400004040400000000000000000004040400444440000404040
002222220022222207007000070000700070070740444440404444404400440444004404b404000000000000000000044000000000000bb00040004000000000
204222202042222077707770777077700007700744440444444404444444044440040404b00b00004004040400000004400000000000b0bb00b000b000000000
244202222442022200000000000000000007077744044404440444044440444404404404b00b0000044044040000004004000000000000b00b0b0b0b00000000
020040200200402000000000000000000007007004444444044444444040400440404004b00b000040404004000004444440000000000b00b00b000000000000
9990999999909999303b030366666600099909900999099009990990003b3b00003b3b0007777770000000001111111199999999565665650666666000000000
404440404044404003b303305555556090440404904404049044040403b3033003b3033077766666cc11cc111111111144444444565665656000000677707770
44040404440404043003b003555555604040404440404044404040443003b0033003b003776566561c111c111111111199999999565665650666666000707000
0040404000404040b3330b3000000000040440400404404004044040b3330b3003330b307766665611c111c11111111144440444565665656606606677707700
0000000000000000030b303066006666440044044400440444004404030b303300000000765666561c111c111111111140444440565665656650056670007000
0000000000000000304434035560555540040404400404004004040430b33b300000000076666556111111111111111144440444565665655056650577707000
00000000000000000003400055605555044044040440440004404404033b03300000000076555566111111111111111144044404565665655656656500000000
0000000000000000004434000000000040404004404040004040400430b3b3030000000006666660111111111111111104444444565665655656656500000000
00777500070000707777777640400440000000008008008800000000b00b0000c7cccc7c67cccc76000000000000000000000000000000000000000000000000
07666650007667007666666540440404404404040888080000000000b00bb000cc7667cc767cc767777077707770777077700770777077007770777077707770
76666665070660700767765040404044404040440880880000000000bb0b0000c706607c65666656007070700070707000707000007070700070700000707000
765655657670076700766500040440400404404088988980cc11cc11b00b0000767cc76766066066077077700770770007707000077070700770770007707700
666666656657756600756500440044044400440489a89a801c111c11b00bb00066577566c56cc65c007070700070707000707000007070700070700000707000
65655655750770570076650040040404400404048aa8aaa811c111c1b00b000075c77c57ccc77ccc777070707770777077700770777077707770777077707000
766666650666666007756550000000000440440489a8a9801c111c11b0bb0b00c666666cc666666c000000000000000000000000000000000000000000000000
6656566570700707766666650000000040404004089a880011111111bb0bb0007c7cc7c77c7cc7c7000000000000000000000000000000000000000000000000
0c00111000c11100000111c00c01110000011100000111000c0110000001100000011000000110000c011100000ee000000e70000ee0000007ee700000000000
c0c11ff00c1cff000011fc0cc0c1ff00c0cff000c0cff000c0cff100001111f00f111100000ff100c0c1ff00000ee00000e7e070eeee00007eeee70000000000
0c011ff000c1ff000011ffc00c11ff000c11ff000c11ff000c0ff00000c11c0000c11c00000ff1000c11f1000eeeee0e00e707e0eeee0000eeeeee0000000000
051c1c000051c0000011c050051c1c0fc0f11c0fc0f11c0f0f1cc1f00fcccc0000ccccf0f11cc110051c1c0fe00eeee0000e7e070ee00000eeeeee0000000000
0f11cc1000fcc100001cccf00f11cc100015cc100015cc1005c1c10000cc1c0000c1cc000011c10f0f11cc10000ee00000e7e77e000000007eeee70000000000
05011ccf0051cc000fcccc5005111c0000115c0000115c0005c11c000c11ccc00ccc11c00011cc0005111c0000eeee000e7e0ee00000000007ee700000000000
05011cc00051cc000011cc5005111c00011ccc00011ccc00c5c11c0c0ccc11000011ccc00011cc0005111c000ee00e00e7e00000000000000000000000000000
0011cccc001ccc00011cccc00111ccc01100c0c101cc0cc00c1001c0cc110000000011cc0c101cc00111ccc0e000e0007e000000000000000000000000000000
0000000006077060088800007777777700000000000bb000bbb000000011100000000ff0eeeeeeee0000000000000000000000000000eeee00000000e00e00e0
0000000060777706808080007000000700b00b0000bbbb0000000b00011ff00000c0ffffee0000ee00eeee00eeeeeeee00e000e0000eeee00007700000eee000
000ff0000707707008080000777777770b0000b00bbbbbb0000000b0011ff0000cccffffe00ee00e0ee00ee000e00e000e0e0e0e00eeee00000770000e0e0e00
00fccf00777657770080000000000000bbb00bbbbbbbbbbbbbbbbbbb1c1c000000cccff0e0e00e0e0e0ee0e0e00e00e0e000e0000eeee00000077000eee0eee0
00fccf00777567770000000000000000bbb00bbb000bb000000000b011cc10000ffcc000e0e00e0e0e0ee0e00e00e00e00000000000eee00007777000e0e0e00
000ff0000707707000000000000000000b0000b0000bb00000000b0000000000f0ff0000e00ee00e0ee00ee0e00e00e000e000e000eee0000eeeeee000eee000
0000000060777706000000000000000000b00b00000bb000bbb0000000000000f00f0000ee0000ee00eeee0000e00e000e0e0e0e0ee000000eeeeee0e00e00e0
00000000060770600000000000000000000000000000000000000000000000000ff00000eeeeeeee00000000eeeeeeeee000e000e000000000eeee0000000000
0070070000000000000000005050050500500500000033300003333000076700000767006770000009800900000900800993000080880800b03b030304030000
00077000007007000000000050500505005005000003bbb3003bbbb3006070500060705067707700988808900800000093890000087780000773033043340000
707bb70700077000000000008505505800055000003bb0b303bb00b3076676500066765007067700098808898c88889098830000877878003073b00303400000
007bb700007bb700000770008508805805088050003bb00003bb00007756007767560076070676000890889899888889039000008787780033330b3040430000
007bb700007bb700007bb700085555805555555503033b30303b30007565565776655676000070008c888889980889000000000008778000030b303003000000
707bb707007bb700007bb70000855800550550553b3003b3b300b300605665060656657000000000998899808088888000000000808808003044340300000000
0007700000077000000770000005500055055055b0b33bb30b33b300070670600075760000000000900900908088889000000000000000000003400000000000
0070070000700700000000000050050005500550000bbb3000bb3000766007760766576000000000009009000908900000000000000000000044340000000000
0100010000000000067760050000000500000005000220000002200000777700077700002b2222202b2222202b222220000bb000000330000000000000000000
11000110010110000707000706776007067760070003b2000003b20007777770777770000b3b03000b3b03000b3b0300003b0300003003000003300000000000
1110015018111111005670570707005707070057000bb200000bb20077077077707070000b3bbb200b3bbb200b3bbb20003bbb00303003033030030300000000
011011505511115006670576005675760056757600b23b0000023bb007777770770770000bb330220bb330220bb3302200bb3000030330300330033000000000
181115005101150005707760066767600667676000b32bb000b32bb0077777776767600000b33b2200b33b2200b33b22023bbb2230b00b0330b33b0300000000
55115000101110000776070005700700057007000002bb0000b23b00007777000606000000333b2200333b2200333b220033b220000bb000000bb00000000000
5050500010111000060700006675700077706000000b3300000b3300000700700777000000b3b0200033b02000b3302000333000330000333300003300000000
05050000000100000667700060577000750660000022002000020200000070070000000000b0b0000b00bb000b00bb000b00bb000b3003b00b3003b000000000
00c10000a15252525252525200ff606000007459ffff91919191919191a100000000000062a1c1c1c10000000002000062d1b1b1b15200000000000000025252
5252c1c1c1d100ff60400000ca63ffffa1a1a1a1a1a1a1a1a1919191919191a1020000000000009152d1b1b1c10000000200000000b1c10052525252e1525252
00ff30300000d4480000a191a1e1919191a1a100a1e100000002910091b1c10000520000000000e100a10000000000b1e1a15252c1c1c1c1c1a100ff40000000
23000000a1919191919191a102c200000000b2a152a2e100000000a1a172c100000062a1a10000a2c100a2a1a15252525252e1a100ff90000000c7ffffffa102
0202020202e2a1000000b8000022a10000b8c800b822a100b8c80200f822a1f1c802c1003242a1f1a1c1c1c1c15200ffc080b000a842e4ffd2020202020202a1
12f1520000b1e19112f1a1d900f1b10012f1a1b1e9b1005232f1a100d900f1a15252a1c1525252a100ff80b0b00031d3c9ffa1a1a10202a1a1a191910200c902
d2a1000000b1a200e80252000000a20000c1a1d9d9d9d9c9f152a1525252525252a100ff00000000ffffffffd2a19102020202e2129100000000002232b80000
00b8004209f8000000b1b85212e800c9c9b8c8a1d8c1525252c8a1a100ff00000000ffffffff249696969696b62424c696969624968696969696c68686b62424
24b696b686b62400a686b6a686b624a6a6a6a6a624b6306500000000ffffffff24005724242457f6242717000086172424005717000000f624570700271700f6
24002717000017f6240017171724172400ff500000005affffff47f11a1af600000047f1575757000000475700570007ca574700270000baca572400000000aa
0027470000000000000070d580508000607350ff00000000000000f600000000005700f657003700570000f6570047000027f1f6270057000086f1f600000000
0086f1f600ff1000000088ffffff644464646464646464f100000000b264646474744400006464c284944400946464000074f1a4a46464446464646464641076
90306000d6b349ffa1919191919191a1a1c200000000b202a1b1000000820000a1a2b1b100b1a200a18292928282f152a1525252525252a1602590b0000023b8
ffffa1919191919191a102c200000000b291000000000082000000c1d182a2b1d152520000b10000b2a1a1525252005252a100ff00000000ffffffffa1919191
919191a1917200000000b2020000b1000000000052d1d19282000000a10000b1b1928252a1525252525252a100ff9000000043ffffffa1919191919191a102c2
0000000000a100000000000000a1f1d1b1d1d1e162a15200000000e10002a1f152525252525200ff6040000035480000a1a1a191e1a1a1a1a1919172e19191a1
a10000f1b10000a1a1d1b1b1c10000a10200000000e1b1a152525252525252a100ff30400000a6580000a191919191919191a1c2000000000000a1e1d1d1d1d1
d1d1a1e1000000000000a1a2c10000000000a15252525252525200ff6060400069c333ff919191919191e1a1000000000000e1a1d1a2d1d1d1d1d1a100000000
0000b2a10000c100000062a1525252525252e1a100ff9000000093ffffffa1f10291919191a1d2b1e1c1000000a112a2e152e9e9e99112c1e102b800000012d9
c9b8c819b852d85252c8a1a1c8a100ffb080c00033d236ffa1910202d20202e2a100000032000022910000b8c9a2c9220000b8c8191919225219420202020242
a1a152e9e952525200ffb0b08080e6d932e2d2919191919191e2120000000000002212000000000000e212000000000000223200c90000c90042525252525252
5252b099d0000000d5ffffffa19191a1020202a1a1b8b8a1b8c100a1a13939a13900c1a1a13939a139c100a1023939a13900c19152c839a139c1c1c100ff80c0
c0c0b1d4b6d8a10202020202e239a100b12200b12239a1b12939b1b13939a100002200c119399100b8c8c9c92239c1c1c8a15252393900ff80b0c0b081ffb143
2400572424242424242717000000000724170027171700f62400270000001727240000170027000024e117172417172400ff50505000945adaff470000000000
00004700001a1a00000747000057571a1af657000000005757f60000000000000057241717171717171700ff808080807282b4c4000000000086f1f63700001a
1a86f1f6471a1a57570000f6475757000000f1f6570000172424f1f6171717242424172400ff8080808034447282644464646464646464f100000000b26464f1
f144f100946464f1f144f100746464f1f144f1a4e100646464646464646400ff90000000d4ffffff646464646464646464c200000000b26464a492f174848464
647474748400b2640000b4a400748464646464646464646440d400000000ffffffffa1a1a1a100919191d29191a10000000012000002b1b152525200000000b4
91a1a19200000092b2a1a152c100005252a120d900000000ffffffff9191919191919191000000000000000052d1d1d1d1d1d152a1000000000000a1a10000a2
000000a1a1525200005252a100ff9000000067ffffff91f19191919191a100f100000000b2a152b1e100000062a1a172b1d1d1e100a1a100000000e10002a152
52525252525200ff606040005549b300d2919191919191e212000000000000221200000000000022120000000000002232000000000000425252525252525252
b099d0000000d9ffffffa1919191919191e2a100000000000022a100000000000022a10000000000002202000082928200425252525252525252708700000000
ffffffffa19191919191e1a1d2c2c1c1c1c1c1a112f10000000000a112d1d1a2c10062a13200000000a2c1a152525252525252a100ff00000000ffffffffa1a1
a102e2a1a1a1a1a1a10042e2a1a1a1a1a1070042e2a1a1a1a1c8190042e2a1a1a1a1a1190042a1a1a1a1a1a15252807300000000ffffffffd2020202020202e2
12000000000000221200000000000022120000000000002232000000000000425252525252525252b099e08080806541c324a1a1e202020202a1a10242b80000
00a1a1b8d9c8190000a1a139b1020200b1e2023900b1b1b1b142525252c1c1c1e95200ff80c0500071d577ffa10239d2399191a1a100b1120000e9a1a1520012
000000a1a1e2a2b1b12900a10242d1e9e9e9d191d1c1c1c1c1c1c1c100ffb0b0b0b0dacaba33a102020291023939a100b80000c1d122a10039e9e9e9e822a1c9
c1c1c1c1b82291b10000c90039a1c1c152525252c8a100ff50c000008659ffffa1e19191919191e2a1e1000000000042a1c100000000c152a1000000000000a1
9100000000000091d6d6d6d6d6d6d6d600ff00000000ffffffffd2919191919191e2320000000000002252e1000000000042a1e100000000b10091b1b1b100c1
00d1d6d6d6d6d6d6d6d600ff00000000ffffffffd2919191919191e212000000000000423200000000000000000000b100c10052d100b10000000091d6d6d6d6
d6d6d6d600ffc000000075ffffffd2919191919191e232000000c1000022000000b1000000225200b10000b1004291d100000000a2c1d6d6d6d6d6d6d6d600ff
c0c00000b573ffffd2919191919191e2120000000000002212000000000000423200000000000000c1b10000a200c1c1d6d6d6d6d6d6d6d600ff00000000ffff
ffffd29191000091d2e212000000000032423200a200c100005200a200000000a2a1c1a2a2c100000091d6d6d6d6d6d6d6d600ff00000000ffffffffd2a1a100
00a102e2320202000091c1425252000000000000a1a1d1d1d1d152529191000000009191d6d6d6d6d6d6d6d600ff90600000d295ffffd2919191919191913200
000000000000002900b100a200d15200c1000000000091000000a200c1c1d6d6d6d6d6d6d6d600ff00000000ffffffff91919191919191910000000000000000
d1d1d100d1b1b1b10000000000000000c10000b10000a2c1d6d6d6d6d6d6d6d600ffb0b0c000e35377ff9191919191a191910000000000e20000b1b1c1b1d142
00520000000000b8a2a1c100b10000b10091d6d6d6d6d6d6d6d600ffb0b0c000735457ff9191919191919191000000000000000052c10000b100a252a100b100
00b100a19100000000000091d6d6d6d6d6d6d6d600ffc000000093ffffff91919191919191e200000000000000225200000000000022a100b100c10000429100
00000000a2c1d6d6d6d6d6d6d6d600ff00000000ffffffffd2919191919191e2120000c100c100221200b1000000c14232a200a200000052c1c1b1c100000091
d6d6d6d6d6d6d6d600ff00000000ffffffffd2919191919191e2120000000000002232005200520000425252a100a15252529191910091919191d6d6d6d6d6d6
d6d600ff00000000ffffffffd2919191919191e21200000000000022320000000000004252525252525252529191919191919191d6d6d6d6d6d6d6d6b05550a0
0000b5c3ffffd2a1a1a191a1a1a112e2a1910091a1a132229100000091a152420000000000a191d10000c1000091d6d6d6d6d6d6d6d6609800000000ffffffff
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
5f47474747474760610000000000006263004700004700626164000000004762610047000047004746464646464646460bf90f090c0227937b415f47474747474760614646464646466261464747474700626160000000000062476200000000009546464646464646460b990e00000054ffffff5f4747474747474661000000
00000000614661624747474661474747644861624747476400460062461e46464646006200ff08060400149921ff5fa2a2a2a2a2a2a20000000000000000464747000000000061000000000000596100000000005955610000000000555500ff00000000ffffffffa2a2a2a2a2a2a2a200000000000000000000595559000000
59555555555559005555555555555555555555555555555500ff0a00000038ffffffa2a2a2a2a2a2a2a200000000000000000000000000000000000000000000000055590000005a5559555500007e55555500ff0a00000034ffffffa2a2a2a2a2a2a2a200000000000000000000000000000000005a59005900000059555555
55555955555555555555555500ff0a00000026ffffffa2a2a2a2a2a2a2a2000000000000000000000000000000000000000000000000555900000000595555559600007e555500ff0a0a00003417ffffa2a2a2a2a2a2a2a200000000000000000000000000000000000000000000000055595a00000000005555550000000000
00ff0a0000009dffffffa2a2a2a2a2a2a2a2000000000000000000000000595a59000000595555555555007e555555555555005555555555555500ff00000000ffffffffa2a2a2a2a2a2a2a2000000000000000000595a595555555955555555555555555555555555555555555555555555555500ff0600000039ffffffa2a2
a2a2a2a2a25600000000000000005955555a590000005555555555555a00555555555555553b555555555555550000ff0600000033ffffff57555555555856a200564332560000000000433200000000000043325c3e0000525d5e4c000000000000434c0000000000ff00000000ffffffffa2585555555557a2000056433256
003b0000004332515300000000434c00000000395b40325b5b5b001f3b3f325c3e3c00ff02020000734cffffa2a2a2a2a2a2a27d525d5d5d5d5d5d7c00000000000000ae003b525d5d5d5dad3d000000000000ad525d5d5d5d5d5d7c00ff06060600ad2c6eff030303030303039f050000000000000a0b000000000000100b00
0000000000100b000001000000109f16169f0416019f0a7700000000ffffffff5f474747474747606100000048000048614747474646474761000000000048606100000048466462464646464646464600ff0c090300923364ff5f47474747474747640046474747474747474600484747466100461e00000062610047474747
0046464646464646464600ff02020b05927e3b79471e464646460062474700000000616246464646466461625f474747474861626147000000470062460000000000624600ff0100000058ffffff61000000000056556100000000000055610000000000000061000000000000006100000000000000610000000000000000ff
00000000ffffffff5555555555555555555555a359005555585596a4567f7e5500557f5555557e5500003b5c327f000000000000323e0000075800000000ffffffff555500007e5555555555960055555555555600007e5557567f00000000435c3e00000000004c000000000000004c000000ff00000000ffffffff55555555
5555555555555555555555555655563b325655553b3f0000323d437e00433a0032383f38543f000032383f3800ff00000000ffffffff55559600007e555555559600000055555556595559007e5596555555555a0058595959595a555a00595959595955550000ff0202000088a2ffff55555500000000005555559600000000
5555960059005955555700555555555532007e5555555555320000585855555500ff00000000ffffffff005555555555555500005658575555555555590000433200555555555a3f4c00555555555743325c555555570043325d00ff04030000599bffff5756565656565855570a030303110b580010111617060b4f00100600
060b0b004e100d0e500c0b0051531313131354520584030000001bffffff555555555555570055555555585700005c3f32000000000000433200000000000043323e595559005d5e4c7e5555555500ff060400007b57ffff0000434c000000000000434c00000000005c3f4c000000000000434c38000000005c3f4c00000000
555a43320000000000ff020200004369ffff001f3740325b3a0000000040323a000000000033325c5c0000395b40325c5c5c0000003f32000000000000433200000000ff02020000534dffff5b5b5b5b5b5b5b7d000000000000007c0054525d5d5d5d7c3e00003b525d5d7c000000000000007c000000000000007c00ff0b00
00004dffffff0303039f030303149f1606000000000aa0161500000000100416060000000010a0161500000006100416161616160b1000ff020202022244618360475f60475f6047624863624863624894006100006100008a000000000000008a000000000000008a0000000000000000ff0a00000052ffffff5f60475f6047
5f6063624863624863626100006100006100000000000000000000000000000000000000433800000000012700000000ffffffff47000000000062470000000000006200000000000000000000000000000000000000000000000000000000000000000000ff00000000ffffffff000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000ff00000000ffffffff00000000323a00000000003b32000000000000003200000000000000323a000000000000323800000000003c3200000000ff00000000ffffffff00000000004c000000000000004c000000000000004c5b3a00000000004c
0000000000000099797900000000009b000000ff00000000ffffffff374000003237403a004300003200433a00403a00323d430000430000320043007999797998799979009b00009a009b00021e06040000873affff565555555555570000555555555557000057435856320000000043000032000079799979794c00000000
9b00004c000000ff0600000089ffffff320000565555565532000000003200003200559600320000327e5557003200003200430000320000320043000032000000ff0a00000028ffffff555556560043326532000000004332003200000000433200320000000043320032000000004332383200000000434c7e00ff00000000
ffffffff65656565656565650000000000000000000000000000000000005955595559005955555555555559555555555555555500ff04040404544b375965664c005855555500434c0000437f5700434c00004300431f334c00004300433b3f3200004300437f4332000043004300ff0400000031ffffff5596433200000000
5800433200000000000043320000000000004332000000000000433200000000000043320000000000ff00000000ffffffff0000004332000000000000433200000000000043323a000000000043320000000000004332000000000000433200000000ff00000000ffffffff000000000000007c000000000000007c00000000
0000007c000000000000007d005955595a00007c7e5555559600007c027500000000ffffffff9f03030303030c109f5013131308169f0b1313131616160a50131316161616019f1316161616060a9f1116161616169f00ff0b0b0b0bf2f5f8fb8a000000000000008a000000000000008a000000000000008930308500000087
8900428430303030881e42424242424200ff060600005279ffff0000433d00000000000043000000000000003f00000000008600433e000000008683313683828300303030303030303000ff050100009768ffff0000000000000000000000000000000000000000000000000000838283000000002f30303030858330424242
4242843000ff0101000048a6ffff00000000000000000000000000000000000000000000000000000000000000004100008382818000303030303030303000ff050100009648ffff00000039320000000000003732000000000000003238000000000039320000000000003534360000302f2f3030302f2f00ff0600000097ff
ffff0000000000430000000000000043380000000000003f0000000000000043000000000000003136002fa9452f2f30302f00ff00000000ffffffffa2a2a2a2a2a2a2a200010203030304000005060708090a00000b0c0d0e0f100000111213131314001615161716161616014300000000ffffffff00004300004c00000000
4300393238370000433d003200000000433e3932000000004036353436352f3030303030303000ff00000000ffffffff32004300003200003200433d37320000323840000032380032004300003200003436313635343635303030303030303000ff0600000017ffffff3200000000434c7e3200000000434c00320000000043
4c003200000000434c00342f301e00314c363042421e3030303000ff060000009dffffff5555555555555555005643567f435600003c3f3e00403e0000004300004300000000313641313600303030303030303000ff0200000097ffffff96433200004300430043320000430043004332000040004300433200004300430031
323641313697303030303030304200ff020600009997ffff000043320000000000004332000000000000433200000000007a9998797979792f309b9a0000000042426d6d6d6d6d6d00ff0a00000018ffffff00000043320000000000004332000000000000433200000079797999987978000000009b9a00302f6d6d6d6d6d6d
424200ff050000006affffff7e5555559600007c005643560000007d000043380000377c00003f000000007c2f0031360041357b423030303030303000ff020206009b9947ff9f1103030303039f0303501313130c0a0b0b1313131313100b1113131313139f0b9f16160716000a0416161616160a9f00ff0b0b0b0bf9fcfff2
421e75757575754242421e0000701e704268727272751e6f7400717000687642746c006f00001e6f420071427171776f00ff05000000abffffff427575757575757573a1a16c707575757475750042007575747500756f716e6e747575006f000000741f6a6a4200000000ff080800002423ffff757575757542694275757575
00421f707575757575421f6f6e6e6e6e6e006e6f000000000000006f000000000000006f091d0505010017336dff4646464646464646462c000000002b464600004744464446460000001f464400460000494a46a5a8464446464646464600ff060304003d7353ff4646464646464646464a2c00000000464646000049000046
0000000047000046a8a84949a8a8a8a6464646464646464600ff0604040084835cff46444646464646464644610000002b464644a7a744004946466d6d4644494a46a6a6a6a6a54a4a46464646464646464600ff00000000ffffffff1a191a1a1a1a1a191a271919191919001a1f1c1c1c1c1c1c1a1f0000000000001a1f0000
__sfx__
010100010c05003600036000360003600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100010c15003100031000310003100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
010500000063500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00000905009010090100901000000000000000000000090500901009010090000905009010090500901009010090100901000000000000000000000000000000000000000000000000000000000000000000
010200000662000000066200000006620000000662000000066200660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000006203e520005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000276302462022620216101f6101f6101f61020610226102461025610256102661026610266102661026610256102361023610226102061020610216102161020610206102061020610206102061020610
010700001885018850188501885018850188501885018850188501885018850188501885018850188501885017850178501785017850178501785017850178501785017850178501785017850178501785017850
000312140040425424284242d750007002d750007002d750007002d750007002d750007002d750007002c75000700287501721017200004040040400404004040040400404004040040400404004040040400404
000400000261002610026100261002610026100261034620076002b62025620226201c6201761013610106100d610076100000000000000000000000000000000000000000000000000000000000000000000000
00031719166500365003620036203c6503a6503a62038620366503565026620236201f6501e6503f6103f6003f6103f6003f6103f6003f6103f6003f6101d6101d60011640036400364000600006000060000600
001000001a450264502f4003240025400264002540027400294002e4002b4002c400334002e4002f4003040031400244003240033400344003040031400334003440035400004000040000400004000040000400
001000001a0201a0201d0201a02024020240202402024020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001a4201a4201d4201a42024420244202442024420004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
001000001542015420184201542013420134201342013420004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
01030000184101c410194101c4101a410174101a4101a410184101a41019410174101c4101a410184101a4101b410174101a410194101541017410194101a410184101a4101c4101941018410194101c41019410
010300001141013410124100f410164101341014410134101541016410134101341014410144100e410114100f4100f4100f4101041010410114100e4101141011410134100f4101241011410114101341016410
010800000d0000e0510f0511c0511d0501d0501d0501d0501a0501a0501a0501a0501d0501d0501d0501d05020050200502005020050200502005020050200502005020050200502005000000000000000000000
0108000001900029510395110951119501195011950119500e9500e9500e9500e9501195011950119501195014950149501495014950149501495014950149501495014950149501495000900009000090000900
010800001490015951169512395124950249502495024950219502195021950219502495024950249502495027950279502795027950279502795027950279502795027950279502795007900079000790007900
010700001585015850158501585015850158501585015850158501585015850158501585015850158501585013850138501385013850138501385013850138501385013850138501385013850138501385013850
000700001585015850158501585015850158501585015850158501585015850158501585015850158501585011850118501185011850118501185011850118501385013850138501385013850138501385013850
010700001585015850158501585015850158501585015850158501585015850158501585015850158501585013850138501385013850138501385013850138501385013850138501385013850138501385013850
010700001c5301c5301c5301c5301c5301c5301c5301c530000000000000000000001c5501c5501c5501c5501a5501a5501a5501a550000000000000000000001a5501a5501a5501a55017550175501755017550
01070000155001550010500105001555015550105501055015550155501755017550155501555010550105501a5501a5501a5501a5501a5501a5501a5501a5501755017550175501755000000000001755017550
0107000015500155001050010500155501555010550105501555015550185501855015550155501055010550175501755017550175501055015550175501a5501a5501a5501a5501a55017550175501755017550
01070000155001550010500105001555015550105501055015550155501855018550175501755015550155501a5501a5501a5501a5501a5501a5501a5501a5501755017550175501755017550175501755017550
0112000004a200000004a200000004a200000004a200000004a200000004a200000004a200000004a200000004a200000004a200000004a200000004a200000004a200000004a200000004a200000004a2000000
0112000009850098400080000800008000980009850098400080000800008000080000800008000080000800098500984000800008000080000800098500984000800008000e8500e8400e8400e8400e8400e840
0112000009910099100a9100a9100b9100b9100c9100c9100d9100d9100c9100c9100b9100b9100a9100a91009910099100a9100a9100b9100b9100c9100c9100d9100d9100c9100c9100b9100b9100a9100a910
011c000000a5002a5004a5002a5000a5002a5004a5002a5000a5002a5004a5002a5000a5002a5004a5002a5000a5002a5004a5002a5000a5002a5004a5002a5000a5002a5004a5002a5000a5002a5004a5002a50
011c00001885518855188551885518855188551885518855188551885518855188551885518855188551885518855188551885518855188551885518855188551885518855188551885518855188551885518855
011c000009955099550c95509955109550c955129550c95509955099550c95509955109550c955129550c95509955099550c95509955109550c955129550c95509955099550c95509955109550c955129550c955
011c000017a350060500a350060517a350060500a350060517a350060500a350060517a350060500a350060517a350000000a350000017a350000000a350000017a350000000a350000017a350000000a3500000
011c000015810158101581015810158101581015810158101c8101c8101c8101c8101c8101c8101c8101c81015810158101581015810158101581015810158101c8101c8101c8101c8101c8101c8101c8101c810
011c000009930099100991009910099300991009910099100c9300c9100c9100c91009930099100991009910109301091010910109100c9300c9100c9100c910129301291012910129100c9300c9100c9100c910
010e00000903009030090300903009030090300903009030100301003010030100301003010030100301003013030130301303013030130301303013030130301003010030100301003010030100301003010030
010e00001a0301a0301a0301a0301a0301a0301a0301a030150301503015030150301503015030150301503018030180301803018030180301803018030180301303013030130301303013030130301303013030
010e00000e0300e0300e0300e0300e0300e0300e0300e03009030090300903009030090300903009030090300c0300c0300c0300c0300c0300c0300c0300c0301303013030130301303013030130301303013030
010e00000c5100c5100c5100c5100c5100c5100c5100c510115101151011510115101151011510115101151010510105101051010510105101051010510105100c5100c5100c5100c5100c5100c5100c5100c510
010e00000994009910099400991009940099100994009910099400991009940099100994009910099400991009940099100994009910099400991009940099100994009910099400991009940099100994009910
010e00000c0300c010090300901009030090103f6003f60011030110100e0300e0100e0300e0100000000000090300901000000000000d0300d0101003010010120301201010030100100c0300c0100000000000
010400000601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010
010400000b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b0100b010
010400000f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f010
010e000009940099200992009920149401492009940099200992009920149401492009940099200b9400b92009940099200992009920149401492009940099200992009920149401492009940099200b9400b920
010e00000994509945099450994509945099450994509945099450994509945099450994509945099450994509945099450994509945099450994509945099450994509945099450994509945099450994509945
010e0000150151501515015150150e0150e0150e0150e015150151501515015150150e0150e0150e0150e015150151501515015150150e0150e0150e0150e015150151501515015150150e0150e0150e0150e015
010e0000091100911009110091100911009110091100911009110091100911009110091100911009110091100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e110
010e0000091100911009110091100911009110091100911009110091100911009110091100911009110091100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c110
010e0000111101111011110111101111011110111101111011110111101111011110111101111011110111100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e110
010e0000214102141021410214102141021410214102141021410214102141021410214102141021410214101c4101c4101c4101c4101c4101c4101c4101c4101c4101c4101c4101c4101c4101c4101c4101c410
010e00000431000000000000000000000000000000000000043100000000000000000000000000000000000004310000000000000000000000000000000000000431000000000000000000000000000000000000
010e00001e300000001e310000001a3100000018310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e3100000000000000000000000000
010e000000000000001e310000001a31000000183100000000000000001e310000001a31000000183100000000000000001e310000001a31000000183100000000000000001e310000001a310000001831000000
010e00000e010000000e010000000e010000000e010000000e010000000e010000000e010000000e0100000009010000000901000000090100000009010000000c010000000c010000000c010000000c01000000
010e00001001000000100100000010010000001001000000100100000010010000001001000000100100000012010000001201000000120100000012010000001201000000120100000012010000001201000000
010e00001a0101a0101a0101a0101a0101a0101a0101a0101a0101a0101a0101a0101a0101a0101a0101a01015010150101501015010150101501015010150101801018010180101801018010180101801018010
010e00001c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101e0101e0101e0101e0101e0101e0101e0101e0101e0101e0101e0101e0101e0101e0101e0101e010
010e000010310073001c3100730010310073001c3100730010310073001c3100730010310073001c3100730010310073001c3100730010310073001c3100730010310073001c3100730010310073001c31007300
010e00000931000300153100030009310003001531000300093100030015310003000931000300153100030009310003001531000300093100030015310003000931000300153100030009310003001531000300
010e00000e0200e0200e0200000010020100201002000000090200902009020000000e0200e0200e020000000e0200e0200e0200000010020100201002000000090200902009020000000e0200e0200e02000000
010e00000902009020090200000009020090200902000000090200902009020000000902009020090200000009020090200902000000090200902009020000000902009020090200000009020090200902000000
010e0000150201502015010000001c0201c0201c010000001a0200000019020000001702017020170100000013020000001a0201802017010000001302000000150200000015020000001a0201a0201a01000000
__music__
00 3f 3e 43 44
01 3f 3d 3c 44
00 3f 3d 3c 44
00 3f 3d 3b 44
00 3f 3d 3b 44
00 3a 38 36 34
00 39 37 36 34
02 3f 3e 33 44
00 2a 2b 2c 44
01 2d 2f 30 44
00 2d 2f 30 44
00 2d 2f 30 44
00 2d 2f 30 44
00 2e 2f 31 44
02 2e 2f 32 44
00 11 12 13 44
01 29 28 27 44
00 29 28 27 44
00 29 28 27 44
00 29 28 27 44
00 29 28 27 44
00 29 28 27 44
00 24 25 26 44
02 24 25 26 44
01 23 22 21 44
00 23 22 21 44
00 23 22 21 44
00 23 22 21 44
02 20 1f 1e 44
03 1d 1c 1b 44
01 1a 16 43 44
00 19 15 43 44
00 18 14 43 44
02 17 07 43 44
00 41 3e 43 44
01 41 3d 3c 44
00 41 3d 3c 44
00 41 3d 3b 44
00 41 3d 3b 44
00 41 38 36 34
00 41 37 36 34
02 41 3e 33 44
03 03 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
