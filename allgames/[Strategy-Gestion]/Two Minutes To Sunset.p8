pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--sunset in two minutes

--by remagamer

--version 1.0

--’release

function _init()
 --inits stuff
 
 poke(0x5f2d, 1) --enable mouse

 initsettings() --inits settings
 initinput() --inits input
 
 ui={} --list of ui elements
 people={} --list of people
 infected={} --list of infected
 swarms={} --list of swarms
 visuals={} --list of visuals
 
 --preset buttons.
 mnubtns() --lays out menu buttons
 
 remagame() --my logo :)

end

function _update()
 --updates stuff
 
 if settings.mode=="logo" then
  --update input
  inpupdate()
  if inp.i==1 then
   settings.mode="mainmenu"
  end
 end
 
 if settings.mode=="mainmenu" then
  --update input
  inpupdate()
  --update ui
  uiupdate()
  
 end
 
 if settings.mode=="mapselect" then
  --update input
  inpupdate()
  --update ui
  uiupdate()
  
 end
 
 if settings.mode=="controls" then
  if btn(4) then
   inp.m="mouse"
   settings.mode="logo"
  end
  if btn(5) then
   inp.m="controller"
   settings.mode="logo"
  end
 end
 
 if settings.mode=="logo" then
  settings.mst+=1
  if settings.mst>=90 then
   settings.mode="mainmenu"
  end
 end
 
 if settings.mode=="game" then
  
  --update input
  inpupdate()
  --update ui
  uiupdate()
  --update people
  pplupdate()
  --update infected
  infupdate()
  --update swarms
  swmupdate()
  --update visuals
  visupdate()
  --victory check
  if settings.vc>=30 then
   settings.vdf=outcome()
   settings.vc=0
  else
   settings.vc+=1
  end
  --victory display
  if settings.vdf~="n/a" then
   settings.vdt-=1
   settings.vdm/=1.2
   if settings.vdt<=0 then
    if settings.vdf=="end" then
     settings.mps[settings.mx+1].pb=max(settings.mps[settings.mx+1].pb,inp.ts)
     settings.mps[settings.mx+1].bt=max(settings.mps[settings.mx+1].bt,flr(settings.ts))
     settings.mode="mapselect"
     fplbtns()
    end
    if settings.vdf=="victory" then
     settings.mx+=1
     if settings.mx==8 then
      --completing the campaign
      ctscn(settings.scns[9])
      --show results
      ui={}
      addbutton(59,117,92,0,"return to menu")
      settings.mode="results"
     else
      settings.cts+=8
      setupgm()
      sfx(16)
      ctscn(settings.scns[settings.mx+1])
     end
    end
    if settings.vdf=="defeat" then
     sfx(15)
     --failure cutscene
     ctscn(settings.scns[10])
     --show results
     ui={}
     addbutton(59,117,92,0,"return to menu")
     settings.mode="results"
    end
   end
  end
  --tick down time
  settings.tr-=1/30
  if flr(settings.tr)%10==0 and settings.tr<=30 then
   sfx(13)
  end
  --tick up time (for siege)
  settings.ts+=1/30
  
 end
 
 if settings.mode=="howto" then
  --update input
  inpupdate()
  --update ui
  uiupdate()
  
 end
 
 if settings.mode=="settings" then
  --update input
  inpupdate()
  --update ui
  uiupdate()
  
 end
 
 if settings.mode=="credits" then
  --update input
  inpupdate()
  --update ui
  uiupdate()
  
 end
 
 if settings.mode=="results" then
  --update input
  inpupdate()
  --update ui
  uiupdate()
  
 end
 
 --corruptor
 if settings.corrupt==1 then
  corrupt()
 end

end

function _draw()
 --draws stuff
 
 --clean the screen
 cls()
 camera()
 pal()
 
 if settings.mode=="logo" then
  --draw sun
  circfill(64,64,30,9)
  circfill(64,64,29,10)
  --draw mountains
  rectfill(0,64,127,127,0)
  bprint("two minutes to sunset",22,64,4)
 end
 
 if settings.mode=="mainmenu" then
  --draw text
  mmprint(settings.mnutxt)
  --draw ui
  uidraw()
  --draw input
  inpdraw()
 end
 
 if settings.mode=="mapselect" then
  --draw map
  map(settings.mx*16,16,0,0,16,16)
  --if random, draw ?
  if settings.mps[settings.mx+1].n=="random" then
   sspr(88,40,8,8,16,16,111,111)
  end
  --draw ui
  uidraw()
  --draw input
  inpdraw()
  
 end
 
 if settings.mode=="controls" then
  rectfill(31,39,97,81,7)
  rectfill(32,40,96,80,1)
  bprint("Ž ",42,64,7)
  bprint("— ",75,64,7)
  bprint("or",58,52,7)
  spr(96,40,48,2,2)
  spr(98,72,48,2,2)
 end  
 
 if settings.mode=="game" then
  --change the palette if sunset
  zpal()
  --draw the background
  rectfill(0,0,127,127,settings.mps[settings.mx+1].bc)
  --draw the map
  map(0,0,0,0,16,16)
  map(16,0,0,0,16,16)
  pal()
  --draw swarms
  swmdraw()
  --draw people
  ppldraw()
  --draw zombies
  infdraw()
  --draw visuals
  visdraw()
  --draw ui
  uidraw()
  --draw input
  inpdraw()
  --draw victory/defeat message
  if settings.vdf~="n/a" then
   if settings.vdf=="end" then
    circfill(64,64,90-settings.vdt,0)
    bprint("€complete€  ",40,53-settings.vdm,1)
   end
   if settings.vdf=="defeat" then
    circfill(64,64,90-settings.vdt,0)
    bprint("‚defeat..‚  ",40,53-settings.vdm,2)
   end
   if settings.vdf=="victory" then
    circfill(64,64,90-settings.vdt,1)
    bprint("’victory!’  ",40,53-settings.vdm,12)
   end
  end
  
 end
 
 if settings.mode=="howto" then
  --draw guide
  guide()
  --draw ui
  uidraw()
  --draw input
  inpdraw()
  
 end
 
 if settings.mode=="settings" then
  --draw settings
  stngs()
  --draw ui
  uidraw()
  --draw input
  inpdraw()
  
 end
 
 if settings.mode=="credits" then
  --draw settings
  credits()
  --draw ui
  uidraw()
  --draw input
  inpdraw()
  
 end
 
 if settings.mode=="results" then
  --draw results
  results()
  --draw ui
  uidraw()
  --draw input
  inpdraw()
 end
 
 --draw debug
 dbgdraw()
 
end
-->8
--init and genmap

function initsettings()
 --initializes the settings.
 
 settings={
  
  mode="controls", --mode
  submode="", --submode
  tzk=0, --total zombies killed
  tcs=0, --total civilians saved
  debug=-1, --debug
  corrupt=-1, --corruption
  tr=120, --time remaining
  ts=0, --time spent (for siege)
  str=0, --swarm timer
  mx=0, --map x
  mst=0, --main logo intro timer
  tdraw=true, --title draw
  cts=30, --campaign total saved
  vc=0, --victory check
  vdf="n/a", --victory/defeat flag
  vdm=60, --victory/defeat message offset
  vdt=90, --victory/defeat timer
  mps={ --map list
   {n="city",sr=5,df=1,bc=0,pb=0,bt=0,sx=52,sy=60},
   {n="canyon",sr=5,df=1,bc=15,pb=0,bt=0,sx=88,sy=60},
   {n="forest",sr=4,df=2,bc=3,pb=0,bt=0,sx=44,sy=36},
   {n="fortress",sr=3,df=3,bc=3,pb=0,bt=0,sx=32,sy=54},
   {n="beach",sr=3,df=3,bc=3,pb=0,bt=0,sx=64,sy=64},
   {n="warehouse",sr=2,df=4,bc=5,pb=0,bt=0,sx=64,sy=64},
   {n="playroom",sr=2,df=4,bc=15,pb=0,bt=0,sx=64,sy=64},
   {n="galaxy",sr=1,df=5,bc=0,pb=0,bt=0,sx=64,sy=64},
   {n="random",sr=3,df=10,bc=3,pb=0,bt=0},
   
  },
  mnutxt={ --menu text
   "€modes€  ",
   "campaign",
   "play through the story mode!",
   "freeplay",
   "play any map you like.",
   "siege",
   "survive a zombie onslaught.",
   "how to play",
   "settings",
   "credits" ,
  },
  scns={ --cutscenes
   --level 1
   {
    --data about the cutscene.
    {
     cn="level 1: city € save 30", --cutscene title.
     s1=100, --first sprite.
     s2=88, --second sprite.
     mx=0, --map x
     my=16, --map y
    },
    --the text in the conversation.
    "2two minutes to sunset, sir.",
    "2zombies will come in droves.",
    "1we'll have to hold them off,",
    "1so we can evacuate the area.",
    "1never fear, citizens!",
    "1george washington is here!",
   }, --end cutscene
   --level 2 cutscene
   {
    --data about the cutscene.
    {
     cn="level 2: canyon € save 38", --cutscene title.
     s1=100, --first sprite.
     s2=86, --second sprite.
     mx=16, --map x
     my=16, --map y
    },
    --the text in the conversation.
    "1whew...we escaped the city.",
    "1i think we're safe.",
    "2...brains...",
    "1...",
    "1yeah, those are zombies.",
    "1these things are everywhere.",
    "1let's get back to work!",
   }, --end cutscene
   --level 3 cutscene
   {
    --data about the cutscene.
    {
     cn="level 3: forest € save 46", --cutscene title.
     s1=100, --first sprite.
     s2=102, --second sprite.
     mx=32, --map x
     my=16, --map y
    },
    --the text in the conversation.
    "1well, this is a nice place.",
    "2hey, uh, george?",
    "1what is it?",
    "2well...why are we stopped?",
    "1the transport needs refueling.",
    "1back in my day, i tell ya...",
    "1we didn't need no gas stations!",
    "2riiiight....alright. see ya.",
    "1hmph. kids these days.",
    "1no respect.",
   }, --end cutscene
   --level 4 cutscene
   {
    --data about the cutscene.
    {
     cn="level 4: fortress € save 54", --cutscene title.
     s1=100, --first sprite.
     s2=88, --second sprite.
     mx=48, --map x
     my=16, --map y
    },
    --the text in the conversation.
    "2sir! there's a swarm building!",
    "2we can't hold them off!",
    "1hmm....",
    "1oh, how convenient!",
    "1there's a fortress nearby.",
    "1that's serendipitous.",
    "1...huh.",
   }, --end cutscene
   --level 5 cutscene
   {
    --data about the cutscene.
    {
     cn="level 5: beach € save 62", --cutscene title.
     s1=102, --first sprite.
     s2=104, --second sprite.
     mx=64, --map x
     my=16, --map y
    },
    --the text in the conversation.
    "1a day at  the beach, how nice!",
    "2yeah, it's really relaxing.",
    "1except for all the zombies.",
    "2yeah, that's true.",
    "2george has it covered, though.",
    "1niiiice.",
   }, --end cutscene
   --level 6 cutscene
   {
    --data about the cutscene.
    {
     cn="level 6: warehouse € save 70", --cutscene title.
     s1=100, --first sprite.
     s2=88, --second sprite.
     mx=80, --map x
     my=16, --map y
    },
    --the text in the conversation.
    "1this is a warehouse, right?",
    "2yes, sir.",
    "1can we find fuel here?",
    "2no...it's a banana warehouse.",
    "1huh. i guess you could say...",
    "2oh no.",
    "1that this is...",
    "2don't say it.",
    "1..pretty bananas! get it?",
    "2why?",
   }, --end cutscene
   --level 7 cutscene
   {
    --data about the cutscene.
    {
     cn="level 7: playroom € save 78", --cutscene title.
     s1=100, --first sprite.
     s2=86, --second sprite.
     mx=96, --map x
     my=16, --map y
    },
    --the text in the conversation.
    "1this doesn't seem right.",
    "1weren't we...ya know...",
    "1bigger?",
    "2brains?",
    "1yeah, i don't get it either.",
    "1maybe if we just do",
    "1what we've been doing...",
    "1it'll resolve itself. deal?",
    "2brains.",
   }, --end cutscene
   --level 8 cutscene
   {
    --data about the cutscene.
    {
     cn="level 8: galaxy € save 86", --cutscene title.
     s1=100, --first sprite.
     s2=88, --second sprite.
     mx=112, --map x
     my=16, --map y
    },
    --the text in the conversation.
    "1well. this is it.",
    "2what is happening?!?",
    "1the final battle.",
    "2we're in space?!?",
    "1everything i've done...",
    "1everywhere i've been...",
    "1it all led up to this.",
    "2this makes no sense!!!",
    "1can i do it?",
    "1one last time?",
   }, --end cutscene
   --victory cutscene
   {
    --data about the cutscene.
    {
     cn="’ congratulations ’", --cutscene title.
     s1=100, --first sprite.
     s2=88, --second sprite.
     mx=-16, --map x
     my=-16, --map y
    },
    --the text in the conversation.
    "1i did it!!!",
    "1i killed all the zombies!",
    "1me! george washington!",
    "2us too...",
    "1good job, me.",
   }, --end cutscene
   --defeat cutscene
   {
    --data about the cutscene.
    {
     cn="‚ defeat ‚", --cutscene title.
     s1=100, --first sprite.
     s2=86, --second sprite.
     mx=-16, --map x
     my=-16, --map y
    },
    --the text in the conversation.
    "1aw shoot, they got us!",
    "1i can't believe it...",
    "2brains!!!!",
    "1agh!",
   }, --end cutscene
  
  
  
  },
  --end
 }

end

function initinput()
 --initializes input.
 
 inp={
  x=64, --cursor x
  y=64, --cursor y
  i=0, --cursor interaction
  m="mouse", --cursor mode
  inm="none", --item name
  isp=-1, --item sprite
  ic=0, --item cost
  rs=3, --resources
  cl=false, --click flag
  rcl=false, --right click flag
  s=false, --signal
  rg=0, --rescue gauge
  vrg=0, --visual rescue gauge
  ex=-32, --evac x
  ey=-32, --evac y
  ea=0, --evac angle
  ec=0, --evac count
  epx=-32, --evac point x
  epy=-32, --evac point y
  epr=0, --evac point ring
  eb=0, --evac blades
  ts=0, --total saved
  mx=-32, --missile x
  my=-32, --missile y
  md=0, --missile delay
  dsx1=0, --direct soldiers x 1
  dsx2=0, --direct soldiers x 2
  dsy1=0, --direct soldiers y 1
  dsy2=0, --direct soldiers y 2
  dst=false, --direct soldiers toggle
  rt=0, --retreat timer
  mct=false, --menu choice toggle
  nsx=16, --nitrogen sweep
  
 }
 
end

function addperson(x,y,t)
 --adds a person.
 add(people,{
  t=t, --type of person
  x=x, --x coordinate
  y=y, --y coordinate
  a=rnd(1), --angle
  v=.1+rnd(.5), --speed
  c=rnd(14), --color of shirt
  cg=0, --charge
  sm=false, --soldier move
  dx=0, --destination x
  dy=0, --destination y
 })
end

function addinfected(x,y)
 --adds an infected.
 add(infected,{
  x=x, --x coordinate
  y=y, --y coordinate
  a=rnd(1), --angle
  v=.1+rnd(.3), --speed
  tg=flr(1+rnd(#people)), --target
  slp=30+rnd(60), --sleep
  rt=0, --retarget
 })
end

function addswarm(x,y,zc)
 --adds a swarm.
 add(swarms,{
  x=x, --x coordinate
  y=y, --y coordinate
  zc=zc, --zombie count
  })
  
end

function addbutton(x,y,s,c,f,tt)
 --adds a button.
 if tt==nil then
  tt=true
 end
 add(ui,{x=x,y=y,s=s,c=c,f=f,tt=tt})
end

function addshot(x,y,x2,y2)
 --adds a shot.
 add(visuals,{n="shot",x1=x,y1=y,x2=x2,y2=y2,c=8})
end

function addsmoke(x,y,bc,ec,s)
 --adds smoke.
 if bc==nil then
  bc=11
 end
 if ec==nil then
  ec=7
 end
 if s==nil then
  s=.1
 end
 add(visuals,{n="smoke",x=x,y=y,r=3+rnd(2),rs=rnd(.2),c=bc,ec=ec,s=s})
end

function addring(x,y,c,s,r,mr)
 ---adds a ring.
 if s==nil then
  s=.2
 end
 if r==nil then
  r=0
 end
 if mr==nil then
  mr=10
 end
 add(visuals,{n="ring",x=x,y=y,r=r,c=c,s=s,mr=mr})
end

function genmap()
 --generates a map in the 0,0-15,15
 --space.
 
 --seed pass, create random blocks
 for ox=0,15 do
  for oy=0,15 do
   mset(ox,oy,176)
   if rnd(100)>80 then
    mset(ox,oy,177)
   end
  end
  cls()
  map()
  flip()
 end
 --expand passes, expand blocks
 for p=1,3 do
  for ox=0,15 do
   for oy=0,15 do
    if fmget(ox*8,oy*8,0)==true and rnd(100)>50 then
     mset(ox+rnd(2)-1,oy+rnd(2)-1,177)
    end
   end
   cls()
   map()
   flip()
  end
 end
 --roof pass, make some blocks roofs
 for ox=0,15 do
  for oy=0,15 do
   if fmget(ox*8,oy*8,0)==true and fmget(ox*8,oy*8+8,0)==true and rnd(100)>90 then
    mset(ox,oy,179)
    mset(ox,oy+1,181)
   end
  end
  cls()
  map()
  flip()
 end
 --break pass, make some blocks breakable
 for ox=0,15 do
  for oy=0,15 do
   if fmget(ox*8,oy*8,0)==true and rnd(100)>65 then
    if mget(ox,oy)~=181 and mget(ox,oy)~=182 then
     mset(ox,oy,mget(ox,oy)+1)
     --roof exception
     if mget(ox,oy)==180 then
      mset(ox,oy+1,182)
     end
    end    
   end
  end
  cls()
  map()
  flip()
 end
 --carve passes, make lines through the map.
 for p=1,3 do
  local tx=flr(rnd(15))
  local ty=flr(rnd(15))
  for ox=0,15 do
   for oy=0,15 do
    if mget(ox,oy)<179 then
     if ox==tx then
      mset(ox,oy,176)
     end
     if oy==ty then
      mset(ox,oy,176)
     end
    end
   end
   cls()
   map()
   flip()
  end 
 end
 --clear the breakmap.
 for ox=16,31 do
  for oy=0,15 do
   mset(ox,oy,57)
  end
 end
 
 -- ’ convert to tileset ’
 --converts the map to an existing tileset.
 
 local ts=flr(1+rnd(1))
 --forest tileset
 if ts==1 then
  for ox=0,15 do
   for oy=0,15 do
    mset(ox,oy,mget(ox,oy)-16)
   end
   cls()
   map()
   flip()
  end
 end
 
 --add ui space
 for x=0,5 do
  for y=11,15 do
   mset(x,y,1)
  end
 end
 
 --set up scientist spawn if siege
 if settings.submode=="siege" then
  local sp=0
  while sp<1 do
   local x=rnd(128)
   local y=rnd(128)
   if fmget(x,y,0)==false then
    settings.mps[settings.mx+1].sx=x
    settings.mps[settings.mx+1].sy=x
    sp+=1
   end
  end
 end
 
 --let player look at the map
 for n=1,60 do
  flip()
 end
 
end
-->8
--general

function dbgdraw()
 --draws debug info
 
 if settings.debug==1 then
  oprint("#z:"..#infected.." #c:"..#people,0,0)
  oprint("cpu:"..flr(100*stat(1)).."% fps:"..stat(7),0,6)
 end
end

function setupgm()
 people={}
 infected={} 
 swarms={}
 visuals={} 
 initinput()
 inp.rs=settings.mps[settings.mx+1].sr
 settings.tr=120 
 settings.str=0
 settings.ts=0
 settings.vdf="n/a"
 settings.vdt=90
 settings.vdm=60
 --copy selected map to play area
 if settings.mps[settings.mx+1].n=="random" then
  genmap()
 else
  cpymap(settings.mx*16,16)
 end
 --generate people
 if settings.submode=="siege" then
  addperson(settings.mps[settings.mx+1].sx,settings.mps[settings.mx+1].sy,"scientist")
 else
  genppl()
 end
 --create gameplay buttons
 gmbtns()
end

function ctscn(scn)
 --plays a cutscene table.
 
 --the "init"
 add(scn,"")
 local an=0
 local as=1
 local ttmr=0
 local txt=2
 while txt<#scn do
  --the "update"
  an+=1
  if an>2 then
   an=0
   if as>0 then
    as=0
   else
    as=1
   end
  end
  ttmr+=1
  if ttmr>#scn[txt]*3+15 then
   ttmr=0
   txt+=1
  end
  if rnd(100)>70 and ttmr<#scn[txt]*3 then
   sfx(10+rnd(3))
  end
  --the "draw"
  cls()
  rectfill(0,0,128,128,settings.mps[settings.mx+1].bc)
  map(scn[1].mx,scn[1].my)
  circfill(0,120,15,0)
  circfill(128,120,15,0)
  if txt>#scn or ttmr>#scn[txt]*3 then
   spr(scn[1].s1,0,111)
   spr(scn[1].s2,120,111,1,1,true)
  else
   if sub(scn[txt],1,1)=="1" then
    spr(scn[1].s1+as,0,111)
    spr(106,8,108)
    spr(scn[1].s2,120,111,1,1,true)
    bprint(sub(scn[txt],2),1,99,7)
   else
    spr(scn[1].s2+as,120,111,1,1,true)
    spr(106,112,108,1,1,true)
    spr(scn[1].s1,0,111)
    bprint(sub(scn[txt],2),128-#scn[txt]*4,99,7)
   end
  end
  rectfill(0,119,127,127,1)
  oprint(scn[1].cn,1,120)
  flip()
 end
end

function mmprint(l)
 --prints the main menu.
 for n, i in pairs(settings.mnutxt) do
  if n<8 then
   if n%2==0 then
    bprint(i,10,1+n*11,3)
   else
    bprint(i,1,1+n*11,1)
   end
  else
   bprint(i,10,n*12-7,3)
  end
 end
end

function genswm()
 --generates a swarm
 --on valid tiles at the edges
 --of maps.
 local sd=flr(1+rnd(4))
 local x=0
 local y=0
 local tm=0
 --top of the map
 if sd==1 then
  x=rnd(128)
  y=4
  while fmget(x,y,0)==true do
   x=rnd(128)
   y=4
   tm+=1
   if tm>30 then
    sfx(9) 
    return
   end
  end
  addswarm(x,y,150-settings.tr)
 end
 --bottom of the map
 if sd==2 then
  x=rnd(128)
  y=124
  while fmget(x,y,0)==true do
   x=rnd(128)
   y=124
   tm+=1
   if tm>30 then
    sfx(9)
    return
   end
  end
  addswarm(x,y,150-settings.tr)
 end
 --left side of the map
 if sd==3 then
  x=4
  y=rnd(128)
  while fmget(x,y,0)==true do
   x=4
   y=rnd(128)
   tm+=1
   if tm>30 then
    sfx(9)
    return
   end
  end
  addswarm(x,y,150-settings.tr)
 end
 --bottom of the map
 if sd==4 then
  x=124
  y=rnd(128)
  while fmget(x,y,0)==true do
   x=124
   y=rnd(128)
   tm+=1
   if tm>30 then
    sfx(9)
    return
   end
  end
  addswarm(x,y,150-settings.tr)
 end
 --reset timer
 settings.str=0
end

function zpal()
 --if sunset, change palette.
 if settings.tr<=0 then
  pal(1,0)
  pal(2,5)
  pal(3,5)
  pal(4,2)
  pal(5,0)
  pal(6,13)
  pal(7,6)
  pal(8,2)
  pal(9,4)
  pal(10,9)
  pal(11,3)
  pal(12,13)
  pal(13,2)
  pal(14,13)
  pal(15,9)
 end
end

function outcome()
 --tests outcomes.
 
 --freeplay
 if settings.submode=="free play" then
  local c=0
  for n, i in pairs(people) do
   if i.t=="civilian" then
    c+=1
   end
  end
  if c<=0 then
   return "end"
  else
   return "n/a"
  end
 end
 --siege
 if settings.submode=="siege" then
  local f=false
  for n, i in pairs(people) do
   if i.t=="scientist" then
    f=true
   end
  end
  if f==false then
   return "end"
  else
   return "n/a"
  end
 end
 --campaign
 if settings.submode=="campaign" then
  if inp.ts>=settings.cts then
   return "victory"
  end
  local c=0
  for n, i in pairs(people) do
   if i.t=="civilian" then
    c+=1
   end
  end
  if c<=0 then
   return "defeat"
  end
  return "n/a"
 end
end

function genppl()
 --generates people.
 local n=0
 while n<120 do
  local x=rnd(128)
  local y=rnd(128)
  if fmget(x,y,0)==false then
   addperson(x,y,"civilian")
   n+=1
  end
 end
end

function cpymap(x,y)
 --copies a 16x16 space to 0,0
 --from the xy coordinates
 local dx=0
 local dy=0
 for ox=x,x+15 do
  for oy=y,y+15 do
   mset(dx,dy,mget(ox,oy))
   dy+=1
  end
  dx+=1
  dy=0
 end
 --clear the breakmap.
 for ox=16,31 do
  for oy=0,15 do
   mset(ox,oy,57)
  end
 end
end

function gmbtns()
 --lays out the gameplay
 --buttons.
 ui={}
 addbutton(1,97,118,0,"direct soldiers")
 --evac buttons (free play/campaign only)
 if settings.submode=="siege" then
  addbutton(12,97,116,9,"nitrogen sweep")
  addbutton(23,97,117,5,"shockwave")
 else
  addbutton(12,97,122,0,"land evac")
  addbutton(23,97,119,0,"liftoff evac")
 end
 addbutton(34,97,120,0,"retreat")
 addbutton(1,117,124,1,"soldier")
 addbutton(12,117,121,2,"sniper")
 addbutton(23,117,125,2,"barricade")
 addbutton(34,117,126,3,"missile")
 
end

function stnbtns()
 --lays out the setting
 --buttons.
 ui={}
 addbutton(0,12,68,0,"use mouse")
 addbutton(12,12,67,0,"use controller")
 addbutton(0,34,66,0,"debug on")
 addbutton(12,34,64,0,"debug off")
 addbutton(0,56,65,0,"corruptor on")
 addbutton(12,56,64,0,"corruptor off")
 addbutton(59,117,92,0,"return to menu")
 
 
end

function mnubtns()
 --lays out the menu play buttons.
 ui={}
 addbutton(0,23,80,0,"campaign",false)
 addbutton(0,45,81,0,"free play",false)
 addbutton(0,67,82,0,"siege",false)
 addbutton(0,89,83,0,"how to play",false)
 addbutton(0,101,84,0,"settings",false)
 addbutton(0,113,85,0,"credits",false)
end

function fplbtns()
 --lays out the free play buttons.
 ui={}
 addbutton(0,90,94,0,"previous map")
 addbutton(11,90,93,0,"select map")
 addbutton(22,90,95,0,"next map")
 addbutton(33,90,92,0,"return to menu")
end

function results()
 --reads you your campaign results.
 bprint("€results€  ",1,1,1)
 bprint("levels completed:"..settings.mx.."/8",1,12,1)
 bprint("civilians saved:"..settings.tcs,1,23,1)
 bprint("zombies killed:"..settings.tzk,1,34,1)
 --if you won, give special message
 if settings.mx==8 then
  bprint("’you won!’  ",1,45,10)
  bprint("thanks for playing :)",1,56,10)
 end
end

function angle(x,y,x2,y2)
 --this function returns an
 --angle between the two
 --coordinate sets.
 return atan2(x2-x,y2-y)
end

function dist(x,y,x2,y2)
 --gets the distance between
 --two points. faster than
 --the previous version.
 local dx, dy = x - x2, y - y2
 local res=(dx * dx + dy * dy)
 if res<0 then
  res=32767
 end
 return res
end

function olddist(x1,y1,x2,y2)
 --!!! this dist is old !!!
 
 --this gets the distance between
 --two points. scales down the
 --values to prevent overflow.
 
 --scale down
 local nx1=x1/10
 local ny1=y1/10
 local nx2=x2/10
 local ny2=y2/10
 --calculate
 local v=sqrt(((nx2-nx1)*(nx2-nx1))+((ny2-ny1)*(ny2-ny1)))
 --scale up
 v*=10
 --return
 return v

end

function fmget(x,y,f)
 --this function is a simplified
 --tile checker.
 return fget(mget((x)/8,(y)/8),f)
end

function bprint(m,x,y,c)
 --displays a text box.
 if type(m)~="string" then
  m=tostr(m)
 end
 local x=x+2
 local y=y+9
 rectfill(x-1,y-9,x-1+#m*4,y-1,c)
 rectfill(x-2,y-8,x+#m*4,y-2,c)
 oprint(m,x-1,y-8)
end

function oprint(text,x,y)
 --simplification of an outline
 --effect.
 print(text,x+2,y+1,0)
 print(text,x,y+1,0)
 print(text,x+1,y+2,0)
 print(text,x+1,y,0)
 print(text,x+2,y+2,0)
 print(text,x,y,0)
 print(text,x+2,y,0)
 print(text,x,y+2,0)
 print(text,x+1,y+1,7)
end

function guide()
 --draws the guide.
 bprint("€how to play€  ",1,1,7)
 bprint("save people, kill zombies!",1,12,5)
 bprint("people:  ",1,23,3)
 circfill(34,27,2,0)
 circfill(34,26,2,0)
 circfill(34,27,1,12)
 circfill(34,26,1,15)
 bprint("zombies:  ",41,23,2)
 circfill(78,27,2,8)
 circfill(78,26,2,8)
 circfill(78,27,1,2)
 circfill(78,26,1,11)
 bprint("‚ more zombies after sunset ‚  ",1,34,8)
 bprint("campaign ",1,45,6)
 bprint("save enough people to continue.",1,56,5)
 bprint("free play ",1,67,6)
 bprint("save as many as you can!",1,78,5)
 bprint("siege ",1,89,6)
 bprint("survive as long as possible!",1,100,5)
 bprint("’good luck’  ",1,111,3)
end

function stngs()
 bprint("€controls€  ",1,1,7)
 bprint("€debug€  ",1,23,6)
 bprint("€corruption€  ",1,45,6)
 
end

function remagame()
 --my logo :)
 
 --clean the screen
 cls()
 --set things up
 local nm="a remagame" --logo letters
 local ltr={} --letters
 for l=1,#nm do
  add(ltr,{n=sub(nm,l,l),tx=32+l*6,x=62,y=160+l*4,vy=11+l/3,c=4+l})
 end
 local bounce=false
 local ln={x=36,y=66,tx=128,vx=0}
 local done=false
 local tm=0
 --showtime!
 while done==false do
  cls()
  for l in all(ltr) do
   --update
   if tm==60 then
    l.vy=3+rnd(3)
    sfx(63)
   end
   l.y-=l.vy
   l.vy-=.6
   if l.y<=60 then
    bounce=true
   end
   if l.y-l.vy>=60 and l.vy<0 and tm<60 then
    l.vy*=-.25
    if abs(l.vy)<1 then
     l.vy=0
     l.y=60
    else
     sfx(63)
    end
   end
   if l.x>l.tx then
    l.x-=2
   end
   if l.x<l.tx then
    l.x+=2
   end
   --draw
   print(l.n,l.x,l.y,l.c)
  end
  --the line
  if bounce==true then
   if tm<60 then
    ln.vx+=1
    ln.x+=ln.vx
   else
    ln.vx-=1
    ln.x+=ln.vx
   end
   if ln.x>=96 then
    ln.x=96
   end
   tm+=1
   if tm==60 then
    ln.vx=0
    sfx(61)
   end
   if ln.x>35 then
    line(ln.x,ln.y,36,ln.y,7)
   end
  end
  if tm==1 then
   sfx(62)
  end
  if tm>90 then
   done=true
  end
  flip()
 end
end

function credits()
 --draws the credits
 bprint("’credits’  ",1,1,10)
 bprint("code, art, sound",1,12,12)
 bprint("remagamer",1,23,7)
 bprint("corruptor code",1,34,12)
 bprint("zep",1,45,7)
 bprint("special thanks",1,56,12)
 bprint("nick",1,67,7)
 bprint("’thank you for playing!’  ",1,78,10)
 
end

function corrupt()
 --corrupt code taken from
 --jelpi by zep. thank you :)
 for i=1,5 do
  poke(rnd(0x8000),rnd(0x100))
 end
end
-->8
--infected/swarm

function infupdate()
 
 --process infected
 for n, i in pairs(infected) do
  --cool down retargeting
  if i.rt>0 then
   i.rt-=rnd(.5)
  end
  if i.slp<=0 then
   --get angle
   if people[i.tg]~=nil then
    i.a=angle(i.x,i.y,people[i.tg].x,people[i.tg].y)
   else
    i.a+=(rnd(2)-1)*.1
   end
   if fmget(i.x+i.v*cos(i.a),i.y,0)==false then
    i.x+=i.v*cos(i.a)
   else
    i.rt+=1
   end
   if fmget(i.x,i.y+i.v*sin(i.a),0)==false then
    i.y+=i.v*sin(i.a)
   else
    i.rt+=1
   end
  else
   i.slp-=1
  end
  --retarget if blocked/target is lost
  if i.rt>=90 or people[i.tg]==nil and #people~=0 then
   if fmget(i.x+i.v*cos(i.a),i.y+i.v*sin(i.a),1)==true then
    mset(((i.x+i.v*cos(i.a))/8)+16,(i.y+i.v*sin(i.a))/8,mget(((i.x+i.v*cos(i.a))/8)+16,(i.y+i.v*sin(i.a))/8)+1)
    sfx(6)
    --break
    if mget(((i.x+i.v*cos(i.a))/8)+16,(i.y+i.v*sin(i.a))/8)==64 then
     mset(((i.x+i.v*cos(i.a))/8)+16,(i.y+i.v*sin(i.a))/8,57)
     mset(((i.x+i.v*cos(i.a))/8),(i.y+i.v*sin(i.a))/8,10)
     sfx(5)
    end
   end
   i.tg=flr(1+rnd(#people))
   i.rt=0
   i.slp=15
  end
  --constrain to screen
  i.x=mid(2,i.x,126)
  i.y=mid(2,i.y,126)
  --stuff
  if dist(i.x,i.y,inp.ex,inp.ey)<8 and dist(inp.ex,inp.ey,inp.epx,inp.epy)<1 then
   for n=1,inp.ec do
    addinfected(i.x,i.y)
   end
   inp.ec=0
  end
  
  for n, i2 in pairs(people) do
   if dist(i.x,i.y,i2.x,i2.y)<400 then
    if i2.t~="soldier" then
     i2.a=angle(i.x,i.y,i2.x,i2.y)
    end
    if dist(i.x,i.y,i2.x,i2.y)<16 and fmget(i2.x,i2.y,0)==false then
     addinfected(i2.x,i2.y)
     del(people,i2)
     i.tg=flr(rnd(#people))
     i.slp=15
    end
   end
  end
 end
end

function infdraw()
 --draws people
 
 for n, i in pairs(infected) do
  circfill(i.x,i.y,2,8)
  circfill(i.x,i.y-1,2,8)
 end
 
 for n, i in pairs(infected) do
  circfill(i.x,i.y,1,2)
  circfill(i.x,i.y-1,1,11)
 end
 
end

-- ’ swarm stuff ’

function swmupdate()
 --updates swarms.
 
 --spawn new swarms
 settings.str+=1
 if settings.tr<=0 then
  settings.str+=4
 end
 
 if settings.str>=300 then
  genswm()
 end
 --process swarms
 for n, i in pairs(swarms) do
  
  --spawn zombies
  if rnd(100)>99 and #infected<300 then
   addinfected(i.x,i.y)
   i.zc-=1
  end
  --delete swarm if empty
  if i.zc<=0 then
   del(swarms,i)
  end
  
 end

end

function swmdraw()
 --draws swarms
 
 //draw nothing for now :)
 
end
-->8
--people

function pplupdate()
 --updates people
 
 for n, i in pairs(people) do
  --civilian behavior
  if i.t=="civilian" then
   i.a+=(rnd(2)-1)*.1
   if fmget(i.x+i.v*cos(i.a),i.y,0)==false then
    i.x+=i.v*cos(i.a)
   end
   if fmget(i.x,i.y+i.v*sin(i.a),0)==false then
    i.y+=i.v*sin(i.a)
   end
  end
  --soldier behavior
  if i.t=="soldier" then
   --move if directed
   if i.sm==true then
    i.a=angle(i.x,i.y,i.dx,i.dy)
    if fmget(i.x+i.v*cos(i.a),i.y,0)==false then
     i.x+=i.v*cos(i.a)
    end
    if fmget(i.x,i.y+i.v*sin(i.a),0)==false then
     i.y+=i.v*sin(i.a)
    end
    if dist(i.x,i.y,i.dx,i.dy)<16 then
     i.sm=false
    end
   end
   --shoot
   if i.cg<=0 then
    for n, i2 in pairs(infected) do
     if dist(i.x,i.y,i2.x,i2.y)<225 then
      sfx(3)
      addshot(i.x,i.y,i2.x,i2.y)
      if rnd(100)>30 then
       del(infected,i2)
       settings.tzk+=1
      end
      i.cg=30
      break
     end
    end
   else
    i.cg-=1
   end
  end
  --sniper behavior
  if i.t=="sniper" then
   if i.cg<=0 then
    for n, i2 in pairs(infected) do
     if dist(i.x,i.y,i2.x,i2.y)<2025 then
      sfx(3)
      addshot(i.x,i.y,i2.x,i2.y)
      del(infected,i2)
      settings.tzk+=1
      i.cg=60
      break
     end
    end
   else
    i.cg-=1
   end
  end
  --scientist behavior
  if i.t=="scientist" then
   --generate resources
   inp.rg+=.05
   --move if directed
   if i.sm==true then
    i.a=angle(i.x,i.y,i.dx,i.dy)
    if fmget(i.x+i.v*cos(i.a),i.y,0)==false then
     i.x+=i.v*cos(i.a)
    end
    if fmget(i.x,i.y+i.v*sin(i.a),0)==false then
     i.y+=i.v*sin(i.a)
    end
    if dist(i.x,i.y,i.dx,i.dy)<16 then
     i.sm=false
    end
   end
  end
  --get out of impassable situations
  if fmget(i.x,i.y,0)==true and i.t~="sniper" then
   i.a+=(rnd(2)-1)*.1
   i.x+=i.v*cos(i.a)
   i.y+=i.v*sin(i.a)
  end
  --constrain to screen
  i.x=mid(2,i.x,126)
  i.y=mid(2,i.y,126)
 end
 
end

function ppldraw()
 --draws people
 
 for n, i in pairs(people) do
  if i.t=="civilian" then
   circfill(i.x,i.y,2,0)
   circfill(i.x,i.y-1,2,0)
  end
  if i.t=="soldier" or i.t=="sniper" then
   circfill(i.x,i.y,2,12)
   circfill(i.x,i.y-1,2,12)
  end
  if i.t=="scientist" then
   circfill(i.x,i.y,2,11)
   circfill(i.x,i.y-1,2,11)
  end
 end
 
 for n, i in pairs(people) do
  circfill(i.x,i.y,1,i.c)
  circfill(i.x,i.y-1,1,15)
 end
 
end
-->8
--visuals

function visupdate()
 --updates visuals
 
 for n, i in pairs(visuals) do
  
  if i.n=="shot" then
   i.c-=.2
   if i.c<=5 then
    del(visuals,i)
   end
  end
  
  if i.n=="ring" then
   i.r+=i.s
   if i.s>0 and i.r>i.mr then
    del(visuals,i)
   end
   if i.s<0 and i.r<0 then
    del(visuals,i)
   end
  end
  
  if i.n=="smoke" then
   i.y-=i.rs
   i.r-=.1
   i.c-=i.s
   if i.c<=i.ec then
    del(visuals,i)
   end
  end
  
 end
end

function visdraw()
 --draws visuals
 
 for n, i in pairs(visuals) do
  
  if i.n=="shot" then
   line(i.x1,i.y1,i.x2,i.y2,i.c)
  end
  
  if i.n=="ring" then
   circ(i.x,i.y,i.r,i.c)
  end
  
  if i.n=="smoke" then
   circfill(i.x,i.y,i.r,i.c-1)
   circ(i.x,i.y,i.r,i.c)
  end
  
 end
end










-->8
--ui

function uiupdate()
 --updates ui
 
 --rescue gauge
 if inp.rg*8.8>inp.vrg then
  inp.vrg+=(inp.rg*8.8-inp.vrg)/10
 end
 
 for n, i in pairs(ui) do
  if dist(inp.x,inp.y,i.x+4,i.y+4)<25 and inp.i==1 then
   if inp.rs>=i.c then
    inp.inm=i.f
    inp.isp=i.s
    inp.ic=i.c
   else
    sfx(0)
   end
  end
 end
 
end

function uidraw()
 --draws ui
 
 if settings.mode=="mapselect" then
  --box
  rectfill(0,88,47,127,0)
  --name of map
  bprint(settings.mps[settings.mx+1].n,1,101,1)
  --stars (free play)
  if settings.submode=="free play" then
   local stars="scr:"
   for n=1,3 do
    if settings.mps[settings.mx+1].pb>n*30 then
     stars=stars.."’"
    else
     stars=stars.."–"
    end
   end
   bprint(stars.."   ",1,111,1)
  end
  --best time (siege)
  if settings.submode=="siege" then
   bprint("best:"..settings.mps[settings.mx+1].bt.."s",1,111,1)
  end
  --difficulty
  for n=1,5 do
   if settings.mps[settings.mx+1].df>=n then
    spr(108,-8+n*9,121)
   else
    spr(109,-8+n*9,121)
   end
  end
  --extra difficulty beyond 5
  for n=5,10 do
   if settings.mps[settings.mx+1].df>=n then
    spr(107,-53+n*9,121)
   end
  end
 end
 
 if settings.mode=="game" then
  --box
  rectfill(0,88,47,127,0)
  --total saved (free play)
  if settings.submode=="free play" or settings.submode=="campaign" then
   oprint("‰"..inp.ts,0,89)
   --time left
   if settings.tr>0 then
    oprint("“"..flr(settings.tr),25,89)
   else
    oprint("“!!!",25,89)
   end
  end
  --time spent (siege)
  if settings.submode=="siege" then
   oprint("“"..flr(settings.ts),0,89)
  end
  --rescue gauge
  rect(1,112,46,114,1)
  rect(2,113,2+(inp.vrg),113,10)
  --power indicator
  for n=1,9 do 
   spr(110,-3+5*n,108)
  end
  for n=1,inp.rs do 
   spr(111,-3+5*n,108)
  end
 end
 
 for n, i in pairs(ui) do
  
  local y=0 --button click offset
  local dist=dist(i.x+4,i.y+4,inp.x,inp.y)
  if dist<25 and inp.i==1 then
   y+=1
  end
  --button
  if inp.rs<i.c then
   rectfill(i.x+2,i.y,i.x+9,i.y+9,2)
   rectfill(i.x+1,i.y+1,i.x+10,i.y+8,2)
   rectfill(i.x+2,i.y-1+y,i.x+9,i.y+8+y,8)
   rectfill(i.x+1,i.y+y,i.x+10,i.y+7+y,8)
  else
   rectfill(i.x+2,i.y,i.x+9,i.y+9,3)
   rectfill(i.x+1,i.y+1,i.x+10,i.y+8,3)
   rectfill(i.x+2,i.y-1+y,i.x+9,i.y+8+y,11)
   rectfill(i.x+1,i.y+y,i.x+10,i.y+7+y,11)
  end
  --sprite icon
  spr(i.s,i.x+2,i.y+y)
  --if moused over, show tooltip
  if dist<25 and i.tt==true then
   bprint(i.f,i.x,i.y-10,1)
   if i.c>0 then
    bprint("cost:"..i.c,i.x+4+#i.f*4,i.y-10,1)
   end
  end
   
 
 end
 
end
-->8
--player

function inpupdate()
 --updates player input.
 
 --move evac blades
 inp.eb+=.1
 if inp.eb>1 then
  inp.eb-=1
 end
   
 --restrain currency
 inp.rs=min(9,inp.rs)
 --mouse controls
 if inp.m=="mouse" then
  inp.x=stat(32)
  inp.y=stat(33)
  inp.i =stat(34)
  if inp.i~=1 then
   inp.cl=false
  end
  if inp.i~=2 then
   inp.rcl=false
  end
 end
 --controller controls
 if inp.m=="controller" then
  inp.i=0 --reset input.
  if btn(0) then
   inp.x-=2
  end
  if btn(1) then
   inp.x+=2
  end
  if btn(2) then
   inp.y-=2
  end
  if btn(3) then
   inp.y+=2
  end
  if btn(4) then
   inp.i=1
  else
   inp.cl=false
  end
  if btn(5) then
   inp.i=2
  end
 end
 --restrain
 inp.x=mid(0,inp.x,127)
 inp.y=mid(0,inp.y,127)
 
 --right click / — remove
 if inp.i==2 then
  inp.inm="none"
  inp.isp=-1
  inp.ic=0
 end
 --click sounds
 if inp.cl==false and inp.i==1 then
  sfx(1)
  inp.cl=true
 end
 if inp.rcl==false and inp.i==2 then
  sfx(2)
  inp.rcl=true
 end
 --check for unclick for menus
 if inp.i==0 and inp.mct==true then
  inp.mct=false
  inp.inm="none"
  inp.isp=-1
  inp.ic=0
 end
 --check for unclick for retreat
 if inp.i==0 and inp.inm=="retreat" then
  inp.rt=0
 end
 --check for unclick for direct soldiers
 if inp.i==0 and inp.inm=="ds2" then
  inp.inm="ds3"
 end
 --reset success marker
 local suc=false --successful use
 --item usages
 if inp.i==1 then
  if inp.inm=="soldier" and fmget(inp.x,inp.y-4,0)==false then
   addperson(inp.x,inp.y-4,"soldier")
   suc=true
  end
  if inp.inm=="barricade" and fmget(inp.x,inp.y-4,0)==false and fmget(inp.x+256,inp.y,7)==false then
   mset(inp.x/8,(inp.y-4)/8,9)
   suc=true
  end
  if inp.inm=="sniper" and fmget(inp.x,inp.y-4,2)==true and fmget(inp.x,inp.y-4,7)==false then
   addperson(inp.x,inp.y-4,"sniper")
   suc=true
  end
  if inp.inm=="land evac" and fmget(inp.x,inp.y-4,0)==false then
   inp.epx=inp.x
   inp.epy=inp.y-4
   inp.epr=30
   suc=true
   sfx(4)
  end
  if inp.inm=="missile" and fmget(inp.x,inp.y-4,7)==false then
   inp.mx=inp.x
   inp.my=inp.y-4
   inp.md=180
   suc=true
   sfx(9)
  end
  if inp.inm=="direct soldiers" then
   inp.dsx1=inp.x
   inp.dsy1=inp.y-4
   inp.dsx2=inp.x
   inp.dsy2=inp.y-4
   inp.inm="ds2"
   inp.dst=true
  end
  if inp.inm=="ds2" then
   inp.dsx2=inp.x
   inp.dsy2=inp.y-4
  end
  if inp.inm=="ds3" then
   for n, i in pairs(people) do
    if i.t=="soldier" or i.t=="scientist" then
     if mid(inp.dsx1,i.x,inp.dsx2)==i.x and mid(inp.dsy1,i.y,inp.dsy2)==i.y then
      i.a=angle(i.x,i.y,inp.x,inp.y-4)
      i.dx=inp.x+rnd(8)-4
      i.dy=inp.y-4+rnd(8)-4
      i.sm=true
     end
    end
   end
   suc=true
  end
  if inp.inm=="retreat" then
   inp.rt+=2
   if inp.rt>=128 then
    if settings.submode=="campaign" then
     --failure cutscene
     ctscn(settings.scns[10])
     --show results
     ui={}
     addbutton(59,117,92,0,"return to menu")
     settings.mode="results"
    else 
     settings.mps[settings.mx+1].pb=max(settings.mps[settings.mx+1].pb,inp.ts)
     settings.mps[settings.mx+1].bt=max(settings.mps[settings.mx+1].bt,flr(settings.ts))
     settings.mode="mapselect"
     fplbtns()
    end
    initinput()
    suc=true
   end
  else
   inp.rt=0
  end
 end
 --insta-success actions
 if inp.inm=="debug on" then
  settings.debug=1
  inp.mct=true
  suc=true
 end
 if inp.inm=="debug off" then
  settings.debug=-1
  inp.mct=true
  suc=true
 end
 if inp.inm=="corruptor on" then
  settings.corrupt=1
  inp.mct=true
  suc=true
 end
 if inp.inm=="corruptor off" then
  settings.corrupt=-1
  inp.mct=true
  suc=true
 end
 if inp.inm=="shockwave" then
  for n=1,10 do
   addring(64,64,9,n/2,0,n*10+20)
   addsmoke(60+rnd(8),60+rnd(8))
  end
  sfx(14)
  for n, i in pairs(infected) do
   i.slp+=240
  end
  suc=true
 end
 if inp.inm=="nitrogen sweep" then
  inp.nsx=0
  suc=true
 end
 if inp.inm=="liftoff evac" then
  inp.epx=-32
  inp.epy=-32
  suc=true
 end
 if inp.inm=="next map" and inp.mct==false and settings.mx+1<#settings.mps then
  settings.mx+=1
  inp.mct=true
  suc=true
 end
 if inp.inm=="previous map" and inp.mct==false and settings.mx>0 then
  settings.mx-=1
  inp.mct=true
  suc=true
 end
 if inp.inm=="select map" and inp.mct==false then
  --clean the gameplay lists
  setupgm()
  --begin
  settings.mode="game"
  inp.mct=true
  suc=true
 end
 if inp.inm=="campaign" then
  settings.mode="game"
  settings.submode="campaign"
  settings.mx=0
  settings.tzk=0
  settings.tcs=0
  inp.mct=true
  suc=true
  --load the first map
  setupgm()
  --play the cutscene
  ctscn(settings.scns[1])
 end
 if inp.inm=="use mouse" then
  inp.m="mouse"
  inp.mct=true
  suc=true
 end
 if inp.inm=="use controller" then
  inp.m="controller"
  inp.mct=true
  suc=true
 end
 if inp.inm=="free play" then
  settings.mode="mapselect"
  settings.submode="free play"
  fplbtns()
  inp.mct=true
  suc=true
 end
 if inp.inm=="siege" then
  settings.mode="mapselect"
  settings.submode="siege"
  fplbtns()
  inp.mct=true
  suc=true
 end
 if inp.inm=="return to menu" then
  settings.mode="mainmenu"
  mnubtns()
  inp.mct=true
  suc=true
 end
 if inp.inm=="how to play" then
  settings.mode="howto"
  ui={}
  addbutton(59,117,92,0,"return to menu")
  inp.mct=true
  suc=true
 end
 if inp.inm=="settings" then
  settings.mode="settings"
  stnbtns()
  inp.mct=true
  suc=true
 end
 if inp.inm=="credits" then
  settings.mode="credits"
  ui={}	
  addbutton(59,117,92,0,"return to menu")
  inp.mct=true
  suc=true
 end
 --success wipe
 if suc==true then
  inp.inm="none"
  inp.isp=-1
  inp.rs-=inp.ic
  inp.ic=0
 end
 
 --evac stuff
 
 --unload people
 if inp.epx==-32 and inp.epy==-32 and dist(inp.ex,inp.ey,inp.epx,inp.epy)<4 then
  inp.rg+=inp.ec
  inp.ts+=inp.ec
  inp.ec=0
 end
 --add currency
 if flr(inp.vrg)>=42 then
  inp.rg-=5
  inp.vrg=0
  inp.rs+=1
  sfx(8)
 end
 --signal people
 if inp.epx~=-32 and inp.epy~=-32 then
  for n, i in pairs(people) do
   if dist(inp.epx,inp.epy,i.x,i.y)<625 and dist(inp.epx,inp.epy,i.x,i.y)>225 and i.t~="soldier" then
    i.a=angle(i.x,i.y,inp.epx,inp.epy)
   end
  end
 end
 if inp.epr>=30 then
  addring(inp.epx,inp.epy,12)
  inp.epr=0
  if dist(inp.epx,inp.epy,inp.ex,inp.ey)>4 then
   sfx(7)
  end
 else
  inp.epr+=1
 end
 inp.ea=angle(inp.ex,inp.ey,inp.epx,inp.epy)
 if dist(inp.ex,inp.ey,inp.epx,inp.epy)>1 then
  inp.ex=inp.ex+1*cos(inp.ea)
  inp.ey=inp.ey+1*sin(inp.ea)
 else
  --collect people
  if inp.ec<10 then
   for n, i in pairs(people) do
    if dist(inp.ex,inp.ey,i.x,i.y)<64 and i.t=="civilian" and inp.ec<10 then
     del(people,i)
     settings.tcs+=1
     inp.ec+=1
     break
    end
   end
  end
 end
 --nitrogen sweep code
 if inp.nsx~=16 then
  for y=0,16 do
   addsmoke(inp.nsx*8-4,y*8-4,14,13,.05)
  end
  for i in all(infected) do
   if flr(i.x/8)==inp.nsx then
    del(infected,i)
    sfx(17)
    settings.tzk+=1
    if rnd(100)>50 then
     mset((i.x/8),i.y/8,188)
     mset((i.x/8)+16,i.y/8,57+rnd(5))
    end
   end
  end
  inp.nsx+=1
 end
 --missile code
 if inp.md>0 then
  --ring
  if inp.md%30==0 then
   addring(inp.mx,inp.my,8,-.5,15)
   sfx(9)
  end
  --count down
  inp.md-=1
  --explode
  if inp.md==1 then
   sfx(5)
   --kill people
   --(this uses all instead of
   -- pairs because pairs gets
   -- too out of sync to
   -- effectively delete stuff)
   for i in all(infected) do
    if dist(i.x,i.y,inp.mx,inp.my)<225 then
     del(infected,i)
     settings.tzk+=1
    end
   end
   for i in all(people) do
    if dist(i.x,i.y,inp.mx,inp.my)<225 then
     del(people,i)
    end
   end
   local mmx=flr(inp.mx/8)
   local mmy=flr(inp.my/8)
   for x=-1,1 do
    for y=-1,1 do
     --smoke
     for n=1,5 do
      addsmoke((mmx+x)*8+(rnd(8)-4),(mmy+y)*8+(rnd(8)-4))
     end
     --deletion of tiles
     if fmget((mmx+x)*8,(mmy+y)*8,7)==false then
      mset(mmx+x,mmy+y,10)
     end
    end
   end
   
   --end of missile effect
  end
 end
 
 --direct soldiers stuff
 
 
end

function inpdraw()
 --draws player input.
 
 local y=0
 if inp.i==1 then
  y=1
 end
 
 --evac
 circfill(inp.ex,inp.ey,4,5)
 circfill(inp.ex,inp.ey,3,6)
 --blades
 for n=0,1,.25 do
  line(inp.ex,inp.ey,inp.ex+5*cos(inp.eb+n),inp.ey+5*sin(inp.eb+n),7)
 end
 
 spr(inp.ec+69,inp.ex,inp.ey)
 
 --cursor
 spr(127,inp.x,inp.y+y)
 --held item
 spr(inp.isp,inp.x-4,inp.y-8+y)
 --missile
 if inp.md>0 then
  circ(inp.mx,inp.my,inp.md/2,8)
 end
 --direct soldiers
 if inp.inm=="direct soldiers" or inp.inm=="ds2" or inp.inm=="ds3" then
  rect(inp.dsx1,inp.dsy1,inp.dsx2,inp.dsy2,9)
 end
 --retreat fadeout
 if inp.rt>0 then
  circfill(64,64,inp.rt,0)
 end
 

end
__gfx__
00000000000000007666666676666666777777777777777799999999999999999444444909494940000500059444444900006565777777776565000094444444
00000000000000007116611676666666766666667116611691144114911441144499994499dddd44050050004499994400656565766666676565650044999999
0000000000000000711661167116611671166116711661169114411491144114499999944d9dd4d5000000004499999465656565766666676565656544999999
0000000000000000766666667116611671166116766666669999999999999999499949949dd94dd4505000054999999465656565766666676565656549999999
0000000000000000711661167666666676666666711661169119411491194114499999944dd45dd5000000504999999465656565766666676565656549999999
0000000000000000711661167116611671166116711661169119411491194114499499949d4dd5d4000500004999999465657777766666677777656549999999
00000000000000007666666671166116711661167666666699999999999999994499994444dddd55000000004499994465776666766666677666776544999949
00000000000000007660066676666666766666667660066694400494944444949444444904545450050005504999999467666666777777777666667549999999
555555555555555555555555500000053333333333355333ffffffff000049494949000000006565656500004999999400004949999999994949000044444449
50000000000000050000000000055000333b333333355333ffffff4f004949494949490000656565656565004999994400494949944444494949490099999944
5000000000000005000000000000000033b3333333b55333f4ffffff494949494949494965656565656565654499999449494949944444494949494994999994
50055050050550050550055005055050333333b3333553b3ffffffff494949494949494965656565656565654999999449494949944444494949494999999994
5005505005055005055005500505505033333b3333355b33ffffffff494949494949494965656565656565654999999449494949944444494949494999999994
5000000000000005000000000000000033b3333333b55333ffffffff494949494949494965656565656565654999999449499999944444499999994999999994
500550000005500500000000000550003b3333333b355333ffffff4f494949494949494965656565656565654499994449994444944444494444999994999944
500000055000000555555555500000053333333333355333ffffffff494949494949494965656565656565659444444949444444999999994444449999999994
50000005500000055000000594444444444444499999999949949994494949494949494965656565656565654999999999999994499999994444444499999994
50055000000550055005500544999949999999449999994949994994494949494949494965656565656565654999994999999944499999499999994999999944
500000000000000550055005449999999499999494999999f494994f494949494949494965656565656565654499999994999994449999999499999994999994
500550500505500550000005499999999999999499999999f499994f494949494949494965656565656565654999999999999994499999999999999999999994
50055050050550055000000549999999999999949999999949999994494949494949494965656565656565654999999999999994499999999999999999999994
50000000000000055005500549999999999999949999999949994994494999999999994965657777777765654999999999999994499999999999999999999994
50000000000000055005500544999949999999449999994949494994499944444444999965776666766677654999994999999944449999499999994999999944
55555555555555555000000594444444444444499999999949499494494444444444449967666666766666754999999999999994944444444444444444444449
55555555500000055000000550000005499494994994999499494994444444449999999900000000000220000002200000022000000220002002200222222002
00000000000550005005500000055005499994994999499499494994999999499999994900000000000000000002000000020000000202200202022022020220
00000000000000005000000000000005f4999949949949499499994f949999999499999900000000000000000200000002222000022220200222202022222020
05055050050550505005505005055005f4999949949999499499994f999999999999999900000000200000222200002222020022220220222202202222022022
05055050050550505005505005055005494994994999999499499994999999999999999900000000000000200000022000000220002002200020022002220222
00000000000000005000000000000005499494994994999499494994999999999999999900000000000000000020000000202200002022002020220020202202
00055000000000005005500000055005499494994949999499499494999999499999994900000000022000000220000002222000022220000222202002222020
50000005555555555000000550000005494994994949949499499494999999994444444400000000020000000200000002000000020002000200022022222220
00000000010000000110010001111110000110000001110000011000000111000001110000010100000111000001110000011100000111000001110001011100
0010010017110000177117101cc77bb10016610000122210001881000018881000188810001a1a10001aaa10001aaa10001ccc10001ccc10001ccc101b1bbb10
0171171001771110177117101cc88bb10176671000121210000181000001181000011810001a1a10001a1100001a110000011c10001c1c10001c1c101b1b1b10
0017710000117771011171001788887101655610001212100001810000188100000188100001aa100001aa10001aaa100001c100001ccc100001cc101b1b1b10
00177100017777100017111017888871017557100012221000188810001888100018881000001a10001aaa10001aaa10001c1000001ccc10001cc1001b1bbb10
01711710017711000171177117788771017777100001110000011100000111000001110000000100000111000001110000010000000111000001100001011100
00100100011171000171177117777771001771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000010000010011001111110000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100000110000111111001111110010110100110011000000000000222000000000003333330000000000011110000100000010000000001000000001000
01bb77100017710016bbbbb119999741171761611ee11ee10002220002222b2003333330333333330000000001cccc10018111001b1000000017100000017100
17bb1171017aa71016b3333119444651017666101e8ee88102222b2002228b8033333333044f1f100000000001c11c101888881001b100000177111001117710
1710017117aaaaa11633333119444651176116611e88888102228b8002b2bbb0044f1f1004f4fff0000000000011cc100181118101b100101777777117777771
17101710017aaa101533333119444651166116511e88888102b2bbb0002b220004f4fff0004fee0000000000001cc10000100181001b11b11777777117777771
1bb1881001aaaa1015111110194446510166651001888810002bbb0000bbbb00004fff00004fff00000000000001100001011181001b1b100177111001117710
1bb188101aa11aa11510000019444651161651510018810000bbbb0000bbbb0003333f3003333f3000000000001c1000181888100001b1000017100000017100
01101100011001100100000001111110010110100001100008888880088888800333313003333130000000000001000001011100000010000001000000001000
00000000000000000000000000000000000000000007770000000000000444000000000000099900777000000111111001111110011111100110000001100000
000007766770000005555555555555500007770007777f700004440004444f400009990009999f90770000001988888117666661100000011201000019a10000
0000777667770000056cc666666bb65007777f70077f1f1004444f4004441f1009999f9009991f1070000000100880011006600110000001100100001aa10000
000077766777000005cccc7777bbbb50077f1f1007fffff004441f1004f4fff009991f1009f9fff0000000001008800110066001100000010110000001100000
000777766777700005cccc7777bbbb5007fffff007ffee0004f4fff0044fee0009f9fff0009fee00000000001988882117666651100000010000000000000000
0007777667777000056cc778877bb65007ffff0000ffff00044fff0004ffff00009fff0000ffff00000000000128281001565610010000100000000000000000
0007776556777000056777888877765001115f5001111f1004ffff0000ffff0000ffff0000ffff00000000000011110000111100001111000000000000000000
0006666dd6666000056778888887765001111d1001111d1003333330033333300888888008888880000000000000000000000000000001000000000000000000
00077765567770000567788888877650011111100000100000001000000110000111111000000000000110000000000000000000011111100011110001000000
0007777667777000056777888877765017ccccc10101a10000019100001cc1001777777100111110001cc10000000000011111001dddddd10188881017100000
000777777777700005677778877776501ddccdd11a11aa100111991001cccc101777777101199991001cc10000000000199999101dddddd11811118117710000
000777777777700005677777777776501ddccdd1011aaa10199999911cccccc11777777119999910011cc11000000000199999101dddddd11818818117771000
0000777777770000056777777777765017cccc1101aaa11019999991011cc11017777710011199911cccccc100000000011199911dddddd11818818117777100
00007777777700000566666666666650011c1c1001aa11a101119910001cc100171111000001199101cccc1000000000000019911dddddd11811118117711000
0000077777700000055555555555555000111100001a101000019100001cc1001710000000000110001cc100000000000000011001dddd100188881011171000
00000000000000000000000000000000000000000001000000001000000110000100000000000000000110000000000000000000001111000011110000000000
fffffaa999999aa933bb3533333b533355555555555555553333333355755755333333333333333311111991119191119f33333333333f911111111111111111
ffffa9949999a9943bb35353333b5333577dd77dd77dd7753766376357657655333b3333333b333319999ff999f9f9919f3b3333333333f91111111111111111
f4aa999494aa9994bb3b353533bb35337665766576657665366636635765765533b3333333b3333319fff33fffbf3f9119f3333333b33f91111111c1111c11c1
ffa9999499a99994b3b3535533b35533555dd55dd55dd555366633335d5dd5d5333333b3333333b39f3333b33b333f919f3333b33b333f91111c11c111c11c11
fa9999949a999994bb3b35353b3b3553577dd77dd77dd775333337635d7dd7d533333b3333333b339f333b3333333bf99f333b3333333bf9111c11c11111c111
fa9999949a9999943bb355533bb353537665766576657665376636635765765533b3333333b3333319f333333333b3f919f333333333b3f91c11111111c11111
fa99994f9a99994933395333bbbb3555555dd55dd55dd55536663663576576553b33333ffb33333319f333333b3333f919f333333b3333f91c1111111c111111
a999994fa999994933944533333953335555555555555555333333335d5dd5d5333333f99f33333319f33333b33333f919f33333b33333f91111111111111111
5765766566576657766576655765766555555555555555555d7dd7d55d7dd7d5333333f99f33333319f3333333333f9111199191333333331111111111111111
5665666566566656666566655665666557777765d77dd77d5765765557657655333b333ff33b33339f3b3333333b33f9999ff9f9333b33331c1111111cc11111
566566656656665666656665566566655766665576657665576576555765765533b3333333b333339fb3333333b333f9fff33f3f33b3333311c1c11111111111
5555555555555555555555555555555557666655d55dd55d5d5dd5d55d5dd5d5333333b3333333b319f333b333333f91333333b3333333b311111c11111cc111
5576656757665766757665755576657557666655d77dd77d5d7dd7d55d7dd7d533333b3333333b339f333b3333333f9133333b3333333b33111c111111111111
556665665666566665666565556665655766665576657665576576555765765533b3333333b333339ff3ff3ffff33ff933b33333fff33fff1111c11111111111
5566656656665666656665655566656556555555d55dd55d57657655576576553b3333333b333333199f99f9999ff9913b333333999ff99911111c11111ccc11
5555555555555555555555555555555555555555555555555d5dd5d5555555553333333333333333111911911119911133333333111991111111111111111111
333333333333333333bb353377777777999999997777777799999999fffffffffffffffffffffffffff88ffffffbbffffff99fff111111115555555555555555
333b3333333b99333bb35353766666679444444971166116911441144444444444444444444444444489884444b7bb44449a9944111111110000000015151515
33b3333333994443bb3b3535766666679444444971166116911441149988888877bbbbbbaa999999488989844bb7b7b4499a9a94111111c100000000111111c1
333333b333944453b3b35355766666679444444976666666999999999ffffff87ffffffbaffffff989898988b7b7b7bb9a9a9a99111c11c105500550111c11c1
33333b3339444453bb3b3535766666679444444971166116911941148ffffff8bffffffb9ffffff989888988b7bbb7bb9a999a99111c11c105500550111c11c1
33b33333394444533bb35553766666679444444971166116911941148ffffff8bffffffb9ffffff9898ff888b7bffbbb9a9ff9991c111111000000001c111111
3b3333333944453333395333766666679444444976666666999999998ffffff8bffffffb9ffffff988ffff88bbffffbb99ffff991c111111000000001c111111
333333333455553333944533777777779999999976600666944004948ffffff8bffffffb9ffffff988888888bbbbbbbb99999999666666666666666611111111
0000000022222222511111152222222251111115522222255111111588888888bbbbbbbb99999999ffffffffffffffff00077000a999999aa999999a33333333
000000002522225215111151252222521511115155222255551511558ffffff8bffffffb9ffffff9455ff55444444444007cccc09999999999999999333b3333
00333300225225221111111122bbbb2211bbbb1152522525515115158f8888f8bfbbbbfb9f9999f9445ff54444444444007c3cc0f444444fa444444a33b33333
00333300222552221111111122bbbb2211bbbb1152222225511111158fff88f8bfbbbbfb9f99fff9444ff44444444444007333cc333333b394444449333333b3
00333300222552221111111122bbbb2211bbbb1152222225511111158f88fff8bfbffbfb9fff99f9444ff4444444444407c111cc33333b33a999999a33333b33
00333300225225221111111122bbbb2211bbbb1152522525515115158f8888f8bfbffbfb9f9999f9445ff5444444444407cc1ccc33b3333399999999f999999f
000000002522225215111151252222521511115155222255551151558ffffff4bffffff39ffffff4455ff554444444447ccccccc3b333333a444444aa444444a
0000000022222222511111152222222251111115522222255111111588888844bbbbbb3399999944ffffffffffffffffcccccccc333333339444444994444449
feeee676aaaaaaaaaaaffffffffffacaaaaaaaaaacaeeeeffffffacaacabbbbffffffacaacaccccf333333331111111111111111fffffffff9f9f9f9ffffffff
4e8885559999999999977444444ee91999999999919888e4444bb919919333b4444cc919919111c437777763111111c11c111111ffffff9f9f9f9f9ff9ffff9f
4e888565aaaaaaaaaaaff7444ee8891999119119919888e44bb33919919333b44cc11919919111c437666653111c1c1cc1c1c111fff9f9f9494949499f9f9fff
4e888555999999999999ff66e888891919919191919888e4b3333919919333b4c1111919919111c43766665f11c1c1c44c1c1c11ff9f9f949494949449f9f9ff
4e888565444444444444ff558888891911999919919888e433333919919333b411111919919111c4f7666653111c1c4994c1c111fff9f94944444444949f9fff
4e88855599999999999fff444888881919191919919888e443333319919333b441111119919111c4f766665f11c1c494494c1c11ff9f9494cccccccc4949f9ff
4888856544444444444ff44444488889999999999198888444433339919333344441111991911114f655555f1c1c49499494c1c1f9f9494c1c1c1c1cc4949f9f
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff11c4949ff9494c11ff9494ccc1c1c1c1cc4949ff
7666666628848848222222222222222294454454999999999999999900a0000000000000ffffffff3333333311c4949ff9494c119f944cc111111111c1c4949f
655555552884884824a4a4422a9999929445445494a4a449944444490aaa000000000a00ffffff9f333b33331c1c49499494c1c1f9494c1c11111c111cc449f9
65555555288488482a9a9a4229444442944544549a9a9a499444444900a0000000000000f9ffffff33b3333311c1c494494c1c119f944cc11111c1c1c1c4949f
655555552222222222222222294444429999999999999999944444490000000000000000ffffffff3f3f3fbf111c1c4994c1c111f9494c1c111111111cc449f9
655555552884884824a44442294444429445445494a4444994444449000000a00a000000ff8888fff3f3fbf311c1c1c44c1c1c119f944cc111111111c1c4949f
65555555288488482a9a4a4229444442944544549a9a4a499444444900000aaa00000a00ff8448ffffffffff111c1c1cc1c1c111f9494c1c111111111cc449f9
65555555288488482949a9a229444442944544549949a9a994444449000000a00000aaa0ff84489fffffff9f111111c11c1111119f944cc111c11111c1c4949f
655555552222222222222222222222229999999999999999999999990000000000000a00ffffffffffffffff1111111111111111f9494c1c111111111cc449f9
0077770000000000333311110000001111000000333333333111111100000000ffffffffff8888ffffffffffffffffffffffffffff9494cc1c1c1c1ccc4949ff
0776766000000000333113110000111111110000133333333311111100000000f9ffff9ff88aa88ffffff9ffffffffffffffff9ff9f9494cc1c1c1c1c4949f9f
7767666500000000333133110001111111111000133333333331111100000000ffff888f88a88a88f888fffff9fffffff9ffffffff9f9494cccccccc4949f9ff
767666550000000013311331001111111111110013333333333111110000a000ffff844f8a8aa8a8f448fffffffff9fffffffffffff9f94944444444949f9fff
77666565000000001333331101111111111111101133333333311111000aaa00ffff844f8a8aa8a8f448ffffffffffffffffffffff9f9f944949494949f9f9ff
766656550000000013333313011111111111111011333333333111110000a000ffff888f88a88a88f888fffffff9fffffffffffffff9f9f9949494949f9f9fff
0665655000000000333333331111111111111111111111333311111100000000ff9ffffff88aa88ff9ffff9fffffff9fffffff9fffffff9ff9f9f9f9f9ffffff
0055550001111110333333331111111111111111111111133331111100000000ffffffffff8888ffffffffffffffffffffffffffffffffff9f9f9f9fffffffff
000000000333333000000000111111111111111100000000111111110000000000000000ffffffffffffffff0000000088888888f999999ff9ffff5f11111111
000000030000000010000000111111111111111100000000111111110000000000000000f98448fffff7779f000000008778877794444445f944445f11111111
000000030000000010000000011111111111111000000000111111110000000000000000ff8448fff976667f0000000087878787944444459455554511111111
000000030000000010000000011111111111111000000000111111110000000000000000ff8888fff766667f00000000878787779444444594ffff4511111111
000000030000000010000000001111111111110000000000111111110000000000000000fffffffff666666f0000000088888888944444459444444511c11111
000000030000000010000000000111111111100000000000113333130000000000000000ffffff9ff566665f000000007788777894444445945555451c1c1111
000000030000000010000000000011111111000000000000133333330000000000000000f9ffffffff55559f0000000078787878f555555f94ffff4511111111
000000000000000000000000000000111100000000000000333333330000000000000000ffffffffffffffff0000000078787778f944445fffffffff11111111
__gff__
0081010101010303050300050105010500000000000020030301010503070305000000050505010303010105050505050000000001010105050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301030303030003000000000000010103030303070303030000000000000101000103050701030505050101010100010001030507010301010100000300000003030303030303030303010101000000000101070101070101000001010001000700050101050101000300000000000000000001010001000000010081050101
__map__
0000000000000000000000000000000039393939393939393939393939393939010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000003939010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000039010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000039010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000039010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000039393939393939393939393939393939010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
131212131212131212131212131212133838382f162b81382f162d2f162d258114831414838d8e8e9a9d9d9d9d8922141414828314141414141414141414141414141414141414141414141414141414d0d0d0d0d0d2d2d0d2d2d2d2d2d0d2d2bbbabbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000d7000000000000
220c0e221c1e220c0e221414220c0e2235353536162b2c353616343616342d3814148314828d8e9e9f9f9f9f9e8c22148314141414148214141414148314831414141414cadacacadadacacadaca1414d0d0d5d5d0d2d2d0d1d1d1d2d2d0d1d1bbc0c1c1c1c1c2bbbbbbbbbbbbbabbbb000000000000e7000000000000000000
2202022206062202033212123302022216161616162d2f16161616161616343583141414141d9e9f9f9f9f9e8e8c221414148314141414141483838214141414141414caebecebebebecececebecdacad0d0d5d5d0d1d1d0d0d0d0d1d1d0d0d0bbbbbabbbbbbbbbbbbc6c4c4c7bbbbbb00000000e000000000d800000000d700
131212131212131212331718321212132e2e1f161634361608162337241616161483838382069c9c9c9c8badad8c221414831414141483141482141414148314cacadaecebecebd9ebebebecd9ecebecd0d0d4d4d0d0d0d0d2d0d0d0d0d0d0d0a7bbbbbbbbbbbbbaacbbbbbbbbbabbbb00d80000000000e10000000000000000
221d1d221414221414220607220d0d2235352d24161616162616341b3608160b1483148214203012121212aeae12211414149495959495959595941414141414faececececece8e9eaecece8e9eaebecd0d0d0d0d0d5d5d0d1d0d0d2d2d0d3d3b7bbbbbbbbbbbbaab9acbbbbbbbba7bb000000000000e3e2e40000d800000000
2206062214100d11142215142202032216163436231f1616161616261626161b141483821482221483148dafaf8c141414149691919791919191961414831414ecececfdecececf9ececececf9ecebfad2d2d2d2d0d5d5d0d0d0d0d2d2d0d3d3bbbbbabbbbbbbbb7b8b9bbbbbbbbb7bb000000d800f0e6e5e6f20000000000e7
131212131233053212131212131212131f161616341b16160f24161616161634838214148314228214838d8e8e8c141483149614869386861486941414821414ecececfeecececd9ebecebebebebececd2d2d2d2d0d4d4d0d0d0d0d5d5d0d1d1bbbbbbbbaabbbbbbbbbbbbbabbbbbbbb000000000000f3f6f4e70000d8000000
22191a221420302114221414221c1e222f168016162616232f36161608161616141483141414221414148d8e8e8c141414149686868614148614931414141414cecfecececece8e9eafaececfafdececd1d1d1d1d0d0d0d0d0d0d0d5d5d0d0d0bbbbabbab7bbbbbbbbacbbbbbbbbbabb00000000000000f10000000000000000
2203022214142214142214142206072236161616161616343616161626160f37831414821482228214838d8e8e9a9d9d14149495959486148686861414148314dedbcfececebebf9ececececebfeececd0d0d0d0d0d2d0d0d5d5d0d4d4d0d0d0babbb8bbbbbbbbbbbbb9bbc3c4c5bbbb000000d8000000000000000000000000
221415320c0e1312121312121312121316160f1f161616161616161616162b81148314148314201211148d8e9e9f9f9f14149091919686868686871414148314ffdedbcfecececebececececececfaecd3d3d0d0d0d1d0d0d5d5d0d0d0d0d0d0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000d80000000000d700000000
311212210505220c0e221d1d220c0e2237372581371f161680162324160f812f148383141414821422828d9e9f9f9f9f14141414149485861484941414141414deffdedbcfececfaececebecececcdced3d3d0d0d0d0d0d0d5d5d0d0d0d0d0d0bbbbbbbbbbbbbbbbbbbbbbbbc8c4c4c900000000000000e700000000000000d7
010101010101220203220606220302220101010101011f1616163436162b2f3601010101010114822283989c9c9c9c9c01010101010193868690921414839d9d010101010101cececfececececcddcde010101010101d0d0d4d4d0d2d2d0d0d0010101010101bbbbbbbbbbbbbabbbbbb01010101010100000000000000000000
01010101010132121213121213121213010101010101251f16161616161b361601010101010114142012121183148214010101010101148614141414148d8f9f010101010101dededbcecececedcffde010101010101d0d0d0d0d0d2d2d2d0d2010101010101bbbbbbbbbbacbbbbbbbb010101010101000000d7000000000000
010101010101221414221c1e220c0e22010101010101812c1616161616261616010101010101148382148222821414140101010101019dbfbf9d9d9dbf9b8e8a010101010101dedeffdedededeffffde010101010101d0d0d6d0d0d1d1d1d0d1010101010101acbbbaacbbb9a9bbbbbb01010101010100000000000000000000
01010101010122141422070622030222010101010101252c16160f1f1616160f010101010101141414838222148314830101010101019fbebe9f9f9fbe9f8f8c010101010101deffdeffdeffdedeffde010101010101d0d0d4d0d0d0d0d0d0d0010101010101b9bbbbb9bbb8b9bbbabb01010101010100000000000000d70000
01010101010132121213121213121213010101010101812c16162b811f160f81010101010101821414148222821482140101010101019cbdbd9c9c9cbd9c9c83010101010101ffdededededeffffdede010101010101d0d0d0d0d0d2d2d0d0d0010101010101bbbbbbbbbbbabbbbbbbb01010101010100000000000000000000
__sfx__
000700002405322050220002405322050220040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003965500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
000c00003965506655006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
010c0000396532b643196331062300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
000a00003501135021350313501135021350313502135011000000000000001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
010c00000c6533f6523a65232652286421f6321162209612006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602
000c00003b6233f6323f6323c6223c6121f6021160209602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602
000e00002465424644246342465424644246342465424644246342460424604246040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
000800001c0401f0402305026050290502e0603206000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000370413c0513f0613f061370413c0513f0613f0613f0503f0303f011000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
010800003a0533d0002e0000000000000000000000000000000000000000000170002000000000000002500000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000380533d0002e0000000000000000000000000000000000000000000170002000000000000002500000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000180533d0002e0000000000000000000000000000000000000000000170002000000000000002500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000340113502137031390413b0513b0613b05139041370313502134011000000000000001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000900002e2532e2532e2533025734257352573625733257312472f23730227332173421733217002070020700207002070020700207002070020700207002070020700207002070020700207002070020700207
0008000032052300522b052250521f0521a0521605216042160321602216012000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
00080000260122f02232032380423b0523b0523b0523b0523b0423b0323b0223b0120000200002000020000200002000020000200002000020000200002000020000200000000000000000000000000000000000
010800002d6500464004640036300162001620026100c600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
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
000800002675326753267432674326733267332672326723267132671325703257030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
000400000c7220c7220e7220e72210732107321173211732137421374215742157421775217752177521775217742177421773217732177221772217712177120070200702007020070200702007020070200702
010800000875308730087100070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
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
