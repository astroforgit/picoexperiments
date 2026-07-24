pico-8 cartridge // http://www.pico-8.com
version 21
__lua__
-- whiny slime!
-- bright moth games
-- 2.0
cartdata"bmg_slime"
statetime,titletime,logo,title,pregame,postgame,gameplay=0,0,0,1,2,3,4
speed,framerate,frametime,state,nextstate,logotimer=2,2,0,logo,logo,0
titlefade,startcolours,titleidx,groundtop = false,{ 7, 7, 7, 6, 13, 6},1,66
camx,camy,actiondelay = 0,0,120
fadex,fadey,fadew,fadeh=-1,-1,0,0
lastspawn,doneintro,drawactions,onintro,onseqline,introcontrol=0,dget(0)==1,{},false,false,false
-- dialogue text box library by oli414. minimized.
function dtb_init(n) dtb_q={}dtb_f={}dtb_n=3 if n then dtb_n=n end _dtb_c() end function dtb_disp(t,c)local s,l,w,h,u s={}l=""w=""h=""u=function()if #w+#l>26 then add(s,l)l=""end l=l..w w=""end for i=1,#t do h=sub(t,i,i)w=w..h if h==" "then u()elseif #w>28 then w=w.."-"u()end end u()if l~=""then add(s,l)end add(dtb_q,s)if c==nil then c=0 end add(dtb_f,c)end function _dtb_c()dtb_d={}for i=1,dtb_n do add(dtb_d,"")end dtb_c=0 dtb_l=0 end function _dtb_l()dtb_c+=1 for i=1,#dtb_d-1 do dtb_d[i]=dtb_d[i+1]end dtb_d[#dtb_d]=""sfx(2)end function dtb_update()if #dtb_q>0 then if dtb_c==0 then dtb_c=1 end local z,x,q,c z=#dtb_d x=dtb_q[1]q=#dtb_d[z]c=q>=#x[dtb_c]if c and dtb_c>=#x then if btnp(4) then if dtb_f[1]~=0 then dtb_f[1]()end del(dtb_f,dtb_f[1])del(dtb_q,dtb_q[1])_dtb_c()sfx(2)return end elseif dtb_c>0 then dtb_l-=1 if not c then if dtb_l<=0 then local v,h v=q+1 h=sub(x[dtb_c],v,v)dtb_l=1 if h~=" " then sfx(0)end if h=="." then dtb_l=6 end dtb_d[z]=dtb_d[z]..h end if btnp(4) then dtb_d[z]=x[dtb_c]end else if btnp(4) then _dtb_l()end end end end end function dtb_draw()if #dtb_q>0 then local z,o z=#dtb_d o=0 if dtb_c<z then o=z-dtb_c end rectfill(22,125-z*6,123,124,0)if dtb_c>0 and #dtb_d[#dtb_d]==#dtb_q[1][dtb_c] then print("\x8e",118,120,2)end for i=1,z do print(dtb_d[i],22,i*6+119-(z+o)*6,7)end end end
--end dialog text box by oli414
--use dtb_disp(txt, callback) to write to text box


--[[
 new animation system!
 start with a sequence of 3 sequences of equal length
 one each for head, body, and legs in order
 optionally, add a rate if it should have its own independent
 frame rate
]]

--lexicon
idle={
    {1,1,5,1,1,1},
    {17,17,17,17,17,24},
    {33,33,33,33,33,33},
    rate=60
}
running={
    {1,1,1,1,1,2,2,2,2,2},
    {18,18,18,19,19,20,20,20,19,19},
    {34,35,36,36,34,34,35,36,36,34}
}
walk={
    {1,1,1,2,2,2},
    {17,21,22,23,22,21},
    {37,38,39,53,54,55},
    rate=8,
}
strike={
    {1,1,2,4,4,4,4,2,2,2},
    {24,40,24,40,41,41,25,25,25,24},
    {33,49,49,38,38,39,39,39,39,38},
    rate=4
}
strike2={
    {2,1,3,3,3,2,2,2},
    {25,23,56,56,57,57,57,24},
    {39,38,49,49,53,53,38,38},
    rate=4
}

--attacks
lexbeam=nil

--slime girl
slimeidle={
    {10,12,10,10,12,10},
    {26,26,26,26,27,27},
    {42,42,42,42,42,42},
    rate=45
}
slimerun={
    {10,10,11,11,10,10,11,11,11,10},
    {27,27,27,28,28,28,29,29,28,28},
    {43,44,45,45,43,43,44,45,45,43}
}
tantrum={
    {14,14,14,14,14,14,15,15,15,15},
    {26,26,26,30,30,31,31,30,26,30},
    {42,42,42,42,46,47,42,46,47,42},
    rate=8
}
complain={
    {10,10,10,14,14,10,13,15,15,13},
    {26,26,26,30,30,31,31,30,26,30},
    {42,42,42,42,42,42,42,46,47,42},
    rate=8
}
comment={
    {10,10,10,10,10,10,13,13,13,13},
    {26,26,26,30,30,31,31,30,26,30},
    {42,42,42,42,42,42,42,42,42,42},
    rate=8
}
lilslime={58,59,60,61,60,59,rate=16}
lilslimeeat={61,62,63,58,63,58,61,60,59,rate=8}

tubes={112,117,122}
doors={112,116,120,124}
songs,songid={8,40},1
--monsters
fox,wasp,bug,flower={
  hp=4,
  run={204,201,202,203, rate=4},
  bite={204,205,206,205,206,204,rate=6},
  idle={200},
  down={207}
},{
  hp=3,
  idle={219,220,rate=1,shdwh=17},
  spawn={219,220,219,220,219,220,219,220,rate=1,shdwh=9,terminal=1},
  run={219,220,rate=1,shdwh=17},
  bite={221,222,rate=1,shdwh=17},
  down={223,223,223,223,terminal=1}
},{
  hp=2,
  run={234,235,rate=4},
  bite={235,236,237,238,237,236,rate=5},
  idle={235},
  down={239}
},{
  hp=2,
  idle={251},
  pew={251,252,253,253,252,rate=6},
  down={254,255,terminal=1},
  spawn={217,218,251,rate=8,terminal=1}
}

seedshot={
    {sx=80,sy=120},
    {sx=84,sy=120},
    {sx=80,sy=124},
    {sx=84,sy=124},
}

prefabs={
 {x=0,y=0},
 {x=16,y=0},
 {x=32,y=0},
 {x=48,y=0},
 {x=64,y=0},
 {x=80,y=0},
 {x=96,y=0},
 {x=112,y=0},
 {x=0,y=13},
 {x=16,y=13},
 {x=32,y=13},
 {x=48,y=13},
 {x=64,y=13},
 {x=80,y=13},
 {x=96,y=13},--door room, connects to previous door
 {x=96,y=13} --goal room, has tube
}

intromap={
 {12,6}
}

map1={
  {12,13,15},
  {15,1,10,13,15},
  {15,4,5,6,15},
  {15,7,9,8,15},
  {15,3,14,15},
  {15,2,16}
}

--game objects
droppablebads={
    fox,
    wasp,
    bug,
    flower,
}

temperchance={90,80,70,60,50,40,30,20}


function _init()
 dtb_init()
 inittitlestars()
 poke(0x5f5c, 30)
 poke(0x5f5d, 30)
 if(rnd(2)==1) songid = 2
 --triggerdialog("get back here! seriously do you even care? ugh i hate this stupid ship... i hope you die. I'll just get eaten whatever.",246)
end

function _update60()
 commitstate()
 if state == title then
  updatetitle()
  return
 elseif state==logo then return
 elseif state == pregame then
  statetime -= 1
  fadex+=1
  fadey+=1
  fadew-=2
  fadeh-=2
  camera(0)
  if titlefade and statetime < -32 then
   statetime = 0
   titlefade = false
   if onintro then music"5"
   else music(songs[songid]) end
   lastspawn = 900

   return
  end
  if not titlefade and statetime > 0 then
   statetime -= 1
  elseif not titlefade and statetime <= 0 then
   nextstate = gameplay
   if(onintro) add(actions, cocreate(function() dointrodialog() end)) add(drawactions, cocreate(function() dodrawintro() end))

  end
 end

 if state==gameplay then
  if(not paused and not onintro) updategame()
  if(onintro) updateintro()
  for c in all(actions) do
    if costatus(c) ~= 'dead' then
      assert(coresume(c))
    else
      del(actions,c)
    end
  end
 end
end

function _draw()
 cls()
 
 pal()
 if state==logo then
  drawlogo()
 elseif state==title then
  drawtitle()
 else
  drawgame()
 end

 if titlefade and state ~= pregame then
  local idx = mid(0, flr(statetime / 8), 7)
  fadepalette(idx, 1)
 elseif state ~= logo then
  initpal()
 end
end

-->8
-- initialisation
function startgame(forceintro)
 titlefade = true
 makestars(96)
 if forceintro then initintro()
 else initgame() end
 
 music(0xffff, 144)
 sfx"63"
end

function initmap(map)
 rooms={}
 local lastdoor=nil
 for m in all(map) do
  local room={w=0,h=104}
  room.doors={}
  for sect in all(m) do
   add(room, prefabs[sect])
   if sect == 15 then
    local door={}
    door.pos = v_new(room.w + 48, 68)
    door.door = rndchoice(doors)
    door.exit = door.pos.x + 12
    door.room = room
    if lastdoor then 
      door.to = lastdoor.room
      door.toexit = lastdoor.exit
      lastdoor.to = room
      lastdoor.toexit = door.exit
      lastdoor = nil
    else lastdoor = door end
    add(room.doors, door)
   elseif sect == 16 then 
    room.slimeexit=v_new(room.w+60,68) 
    room.slimeexit.groundpos = 68
    room.tube=rndchoice(tubes)
   end
   room.w += 128
  end
  add(rooms, room)
 end

 currentroom=rooms[1]
end

function initintro()
 initgame()
 initmap(intromap)
 del(entities, slimegirl)
 add(entities, slime)
 metslime = false
 onintro = true
 slime.x = 180
 slime.flip = true
 slime.y = 59
 activeslime=nil
end

function initgame(noclearactions)
 initmap(map1)
 transformstate, gtransformstate, slimewinstate,metslime = nil,nil,nil,true

 bullets={}
 bodies={}
 baddies={}
 entities={}
 if(not noclearactions)actions={}
 crates={}
 camx=0
 player={
    x=60,
    y=62,
    lgoffset=11,
    hoff=-1,
    large=1,
    shdwh=20,
 }
 slime={
    x=74,
    y=74,
    shdwh=9
 }
 slimegirl={
    x=48,
    y=63,
    lgoffset=10,
    large=1,
    shdwh=19
 }

 songid+=1
 if(songid>#songs) songid = 1
 slimehp,slimeate,tempertime,activeslime,stagecomplete,stagefailed,finaltext,showwin=7,false,0,slimegirl,false,false,false,false
 currentroom=rooms[1]
 fadex,fadey,fadew,fadeh=-1,-1,0,0
 setanim(player,idle)
 setanim(slime,lilslime)
 setanim(slimegirl, slimeidle)
 lastspawn = 900
 add(entities, slimegirl)
 add(entities, player)

 for obj in all(entities) do
  setgroundpos(obj)
 end
end

-->8
-- updates
function updatetitle()
 titletime += 1
 if(titletime > 8) titleidx += 1 titletime = 0
 if(titleidx > 6) titleidx = 1
 if titlefade then
  statetime += 1
  if statetime >= 72 then
   nextstate = pregame
   statetime = 72
   fadex,fadey,fadew,fadeh=0,0,128,128
  end
 elseif btnp"5" or btnp"4" then
  if doneintro and btnp"4" then startgame(true)
  else startgame() end
 end
end

function updategame()
 for obj in all(entities) do
  updateanim(obj)
 end
 if lexbeam and lexbeam.ft >= 12 then
  del(entities, lexbeam)
  lexbeam = nil
 end
 handleinput()
 updateslime(activeslime)

 slimepos = v_new(activeslime.x+4,activeslime.y)
 slimepos.groundpos = activeslime.groundpos
 dtb_update()
 lastspawn += 1
 if lastspawn > 900 then
  local count = flr(rnd(3))
  spawnrandommob()
  for i=1,count,1 do
   spawnrandommob(true)
  end
  lastspawn =0
 end

 for bull in all(bullets) do
  updatebullet(bull)
 end
 for bad in all(baddies) do
  updatebaddy(bad)
 end
 for crate in all(crates) do
  if crate.landtime then
   crate.landtime += 1
   if crate.landtime == 30 then
    setanim(crate,{199})
    sfx"35"
    spawnmob(crate.x, crate.y-1, false, crate.contents)
   elseif crate.landtime == 90 then
    del(crates, crate)
    del(entities, crate)
   end
  else 
   crate.y +=2
   crate.shdwh -= 2
   if crate.shdwh == 9 then
    crate.landtime = 0
    sfx"35"
   end
  end
 end
 for obj in all(entities) do
  setgroundpos(obj)
 end
 for bug in all(bodies) do
  if bug.type == wasp and bug.shdwh > 9 then
   bug.y += 1 bug.shdwh -= 1
  end
 end
 camx = mid(0, player.x - 64, currentroom.w - 128)
 sortByY(entities)
 
 for door in all(currentroom.doors) do
  if door
    and player.x > door.pos.x+8 
    and player.x < door.pos.x+24
    and player.groundpos < groundtop + 4
    and activeslime.x > door.pos.x -8 
    and activeslime.x < door.pos.x + 40
    and activeslime.groundpos < groundtop + 32 then
     add(actions, cocreate(function() doroomchange(door) end))
     return
    end
  end
end

function updateintro()
 dtb_update()
 for obj in all(entities) do
  updateanim(obj)
 end
 if(introcontrol) handleinput()
 if(activeslime) updateslime(activeslime)
 for obj in all(entities) do
  setgroundpos(obj)
 end
 if(player.x >= 158 and player.x < 202 and player.y <= 58) metslime = true
 camx = mid(0, player.x - 64, currentroom.w - 128)
 sortByY(entities)
end

function updatebullet(obj)
 local blmove = obj.dir
 obj.x += blmove.x * .25
 obj.y += blmove.y * .25
 ydiff = obj.groundpos-slimepos.groundpos
 if obj.x+4 < 0 or obj.x > currentroom.w or obj.groundpos < groundtop or obj.y >= 104 then
  del(bullets, obj)
  del(entities, obj)
  return
 elseif lexbeam then
  local lxcenter,center,lexy,oy = lexbeam.x+8, obj.x+4,lexbeam.groundpos, obj.groundpos
  if(lexbeam.flip) lxcenter -= 26
  if(lexbeam.ft > 3 and lexbeam.flip) lxcenter-=8
  if abs(center-lxcenter) < 10 and abs(oy-lexy) < 4 then
   del(bullets, obj)
   del(entities, obj)
   sfx"35"
  end
 elseif abs(obj.x+4 -slimepos.x) < 4 and ydiff < 4 and ydiff > -6 then
  if(not activeslime.lasthit) hitslime()
  del(bullets, obj)
  del(entities, obj)
 end
end

function updatebaddy(obj)
 --getting hit and reacting
 if not obj.lasthit and lexbeam then
  local lxcenter,center,lexy,oy = lexbeam.x+8, obj.x+4,lexbeam.groundpos, obj.groundpos
  if(lexbeam.flip) lxcenter -= 26
  if(lexbeam.ft > 3 and lexbeam.flip) lxcenter-=8
  if abs(center-lxcenter) < 10 and abs(oy-lexy) <= 6 then
   obj.hp -= 1
   obj.lasthit = 0
   sfx"35"
  end
 end
 if obj.hp <= 0 and obj.anim ~= obj.type.down then
  obj.lasthit = nil
  setanim(obj, obj.type.down, true)
  del(baddies, obj)
  add(bodies, obj)
  return
 end
 if obj.lasthit then
  obj.lasthit += 1
  if(obj.lasthit > 15) obj.lasthit = nil
  return
 end
 
 --spawning
 if obj.anim == wasp.spawn then
  if(obj.ft == 0) obj.y -= 1 obj.shdwh += 1
  if(obj.ft > 1) setanim(obj, wasp.idle)
 elseif obj.anim == flower.spawn and obj.ft > flower.spawn.rate then setanim(obj, flower.idle)
 end
 
 --action time and target setup
 if(obj.atime) obj.atime -= 1
 if(obj.atime and obj.atime <= 0) obj.atime = nil
 if(obj.lastturned) obj.lastturned -= 1
 if(obj.lastturned and obj.lastturned <= 0) obj.lastturned = nil
 pos = v_new(obj.x+4,obj.y)
 slimepos.groundpos = activeslime.groundpos pos.groundpos = obj.groundpos
 xdist,movdir,chance,diff = pos.x-slimepos.x, (obj.dir or v_new(0,0)), rnd(100), v_subtr(pos, slimepos)
 absdist,dist = abs(xdist),9999
 if(xdist < 64) dist = v_len(diff.x,diff.y)

 --monster bite!
 if obj.anim == obj.type.bite  then
   if(obj.reset) setanim(obj, obj.type.idle) obj.atime = actiondelay obj.dir = nil return
   if (obj.frame > 1 and dist < 6 and not activeslime.lasthit and not obj.atime) hitslime()
 end
 if (obj.acting and obj.type ~= flower) return

 --flower
 if obj.anim == flower.idle and not obj.atime then
  if(absdist < 128) setanim(obj, flower.pew) obj.flip = xdist < 0
 elseif obj.anim == flower.pew then
  if obj.reset then setanim(obj, flower.idle)
  elseif obj.frame == 3 and obj.ft == 0 then
   obj.atime = 330
   spawnbullet(obj)
   sfx(40)
  end
 --fox
 elseif obj.type == fox or obj.type == wasp or obj.type == bug then
  if dist > 16 or activeslime.lasthit or obj.atime then
   movdir.y = 0
   if not obj.lastturned and chance > 75 then 
    obj.flip = not obj.flip
    setanim(obj, obj.type.run)
    obj.lastturned = 60
    movdir.x = .5
    if(not obj.flip) movdir.x *= -1
   elseif not obj.lastturned and chance < 15 then
    setanim(obj, obj.type.idle)
    obj.lastturned = 45
    movdir = v_new(0,0)
   end
  else
   if dist < 6 then
    movdir = v_new(0,0)
    obj.flip = diff.x > 0
    if(not activeslime.lasthit and not obj.atime) setanim(obj, obj.type.bite, true, 38)
   else
    obj.flip = diff.x > 0
    movdir = v_normalised(diff)
    movdir.x *= .5
    movdir.y *= .25
   end
  end
 elseif obj.type == wasp then
  --todo different behaviour
 elseif obj.type == bug then
 --todo different behaviour
 end
 
 obj.x += movdir.x
 obj.y += movdir.y
 obj.dir = movdir
end

function updateslime(s)
 if s.lasthit then
  s.lasthit -= 1
  if(s.lasthit <= 0) s.lasthit = nil
 end
 if(slimehp <= 0 and not stagefailed) actions={} gtransformstate=nil transformstate=nil add(actions, cocreate(function() doslimedie() end))
 if(s.blocked) return
 if s==slime and s.acting and slimebug and s.frame == 3 then
   del(bodies, slimebug)
   del(entities, slimebug)
   slimehp += 1
   slimeate = true
   slimebug = nil
   return
 end
 if(s.acting) return
 local exit = currentroom.slimeexit or v_new(99999,99999)
 local pdist,exdist,diff,movdir = player.x - s.x, exit.x - s.x,nil,nil
 local abspdist,absxdist,dist = abs(pdist),abs(exdist)
 local bugdist,closebug = 9999,nil
 for b in all(bodies) do
  local bdist = abs(b.x - s.x)
  if(bdist < bugdist) bugdist = bdist closebug = b
 end
 --[[ priorites:
     slime-pod
     dead bug (health < max) half screen
     door
     player
 ]]

 --[[ tantrums:
    check every 5 seconds, when not fussing
    100% 25%
    25%  90%
    random chance, lower health, higher chance.
    no tantrum if on way to bug, unless full health.
  ]]
 
 -- to exit
 if absxdist < 32 then
  diff = v_subtr(s, exit)
  movdir = v_normalised(diff)
  if v_len(diff.x,diff.y) <= 1 then 
   s.x=exit.x
   s.y=exit.y - s.shdwh
   movdir = nil diff = nil
   add(actions, cocreate(function() doslimeexit() end))
  end
 --getbug
 elseif slimehp < 8 and bugdist < 48 and closebug then
  diff = v_subtr(s, closebug)
  dist = v_len(diff.x,diff.y)
  movdir = v_normalised(diff)
  slimebug = closebug
  if(dist < 6 and s == slimegirl) add(actions, cocreate(function() doslimegirltransform() end)) return
  if(dist < 1) sfx"36" movdir = nil setanim(s, lilslimeeat, true) return
 --door
 --elseif theres a door
 --go to it!
 --follow 
 elseif abspdist < 40 then
  diff = v_subtr(s, player)
  dist = v_len(diff.x,diff.y)
  if dist >= 24 and dist <= 48 then
   if(not metslime) metslime = true return
   movdir = v_normalised(diff) 
  end
 else diff = nil  
 end

 if(s == slime and s.reset and not slimebug) add(actions, cocreate(function() doslimetransform(s) end)) return
 if(s.anim == lilslimeeat and s.reset) setanim(s, lilslime)
 --tantrum
 if s == slimegirl then
  tempertime += 1
  if tempertime >= 300 then
   tempertime = 0
   if flr(rnd(100))+1 < temperchance[max(1,slimehp)] then
    --do a tantrum!
    local txt,antype,frm=nil,nil,nil
    if slimehp > 6 then txt = rndchoice(fhcomments)
    elseif slimehp > 4 then txt = rndchoice(mhcomments)
    elseif slimehp > 2 then txt = rndchoice(lhcomments)
    else txt = rndchoice(chcomments) end
    frm = txt[2]

    if (frm==213 or frm==246) antype = comment
    if (frm==230) antype = tantrum
    if(not antype) antype = complain
    slimegirl.blocked = true
    setanim(slimegirl, antype, true)
    triggerdialog(txt[1], frm)
    sfx"42"
    return
   end
  end
 end

 if(diff) s.flip = diff.x < 0
 if movdir then
  s.x += movdir.x * .25
  s.y += movdir.y * .125
  if(s == slimegirl) setanim(slimegirl, slimerun)
 else setanim(slimegirl, slimeidle) end
end

-->8
-- draws
function drawlogo()
 local fl = false
 if(rnd"4">2) fl = true
 palt(0b0000000000001000)
 rectfill(0,0,128,128,13)
 sspr(64,48,64,16,32,68)
 spr(78,56,48,2,2,fl)
 print("p r e s e n t s",34,86,0)
 if logotimer == 0 then
  logotimer += 1
  sfx"62" --picocity sound
 end
 if logotimer >= 128 then
  titlefade = true
  statetime += 1
 end
 if logotimer > 200 or btnp() ~= 0 then
  initpal()
  nextstate = title
  titlefade = false
  statetime = 0
  sfx(-1,0)
  music"0"
  cls()
  palt()
 else
  logotimer += 1
 end
end

function drawtitle()
 drawtitlestars()
 spr(160,31,24,8,2)
 spr(168,31,44,8,2)

 sspr(24,96,16,16,4,68,32,32)
 sspr(40,96,16,16,93,68,32,32)
 print("lexicon", 50, 8,13)
 print("in", 60,16,7)
 print("— to start", 42, 86, startcolours[titleidx])
 if(doneintro) print("Ž to see intro", 33, 92, startcolours[titleidx])
 print("art & design: @heynetters\ndevelopment: @alturos\nsound & maps: @robinsongtweets", 4, 110, 7)
end

function drawgame()
 for star in all(stars) do
  pset(star.x,star.y,star.c)
 end
 camera(camx,camy)
 palt(0b0001000000000000)
 for i=1,#currentroom,1 do
  local r = currentroom[i]
  map(r.x,r.y,(i-1)*128,0,16,13)
 end
 if(currentroom.slimeexit) map(currentroom.tube,20,currentroom.slimeexit.x-16,16,5,7)
 for door in all(currentroom.doors) do
  map(door.door,13,door.pos.x,16,4,7)
 end
 for c in all(drawactions) do
  if costatus(c) ~= 'dead' then
      assert(coresume(c))
    else
      del(drawactions,c)
    end
 end
 palt()

 for obj in all(entities) do
  if obj.groundpos and obj ~= lexbeam and not obj.small and not (obj == slime and slimewinstate) then
   rectfill(obj.x-1, obj.groundpos-2, obj.x+8,obj.groundpos-1,2)
  end

  if(obj.lasthit and obj.lasthit % 3 == 0) pal({10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10})

  if obj == slime and transformstate then
   drawslimetransform(obj)
  elseif obj == slimegirl and gtransformstate then
   drawslimegirltransform(obj)
  elseif obj == slime and slimewinstate then
   drawslimewin(obj)
  elseif obj.large then drawlarge(obj)
  elseif obj.small then drawsmall(obj)
  elseif obj.anim then spr(obj.anim[obj.frame],obj.x,obj.y, 1, 1, obj.flip)
  elseif obj == lexbeam then
   local dx = lexbeam.x
   if(lexbeam.inverse) pal(10,13) pal(15,14) pal(9,2) pal(11,13)
   if(lexbeam.flip) dx -= 18
   if(lexbeam.ft > 3 and lexbeam.flip) dx-=8
   if lexbeam.ft < 4 then spr(48, dx, lexbeam.y, 1, 1, lexbeam.flip)
   elseif lexbeam.ft < 8 then
    spr(6, dx, lexbeam.y, 2, 1, lexbeam.flip)
   elseif lexbeam.ft < 12 then
    spr(8, dx, lexbeam.y, 2, 1, lexbeam.flip)
   end
  end
  pal()
 end

 camera()
 if fadeh > 0 then
  rectfill(fadex,fadey,fadex+fadew,min(103,fadey+fadeh),0)
 end
 if(showwin) drawwin(32,48)
 --textbox

 spr(192,0,104, 1, 3)
 spr(194,120,104, 1, 3)
 for x=8, 112, 8 do
  spr(193,x,104)
  spr(225,x,120)
 end
 if currentmood == -1 then
  rectfill(6,108, 19, 123,8)
  rectfill(5,109, 20, 122,8)
  rectfill(5,110, 20, 121,2)
  line(7,119, 18, 119, 7)
  line(8,120, 17, 120, 7)
  circfill(8,113,2,7)
  circfill(17,113,2,7)
 else
  if(currentportait) spr(currentportait,4,108,2,2,currentportaitflip)
  if(currentmood) spr(currentmood,12,116,1,1,currentportaitflip)
 end
 dtb_draw()
 --print("oh no everything's awful!",24, 107,7)
 --print("you better go fix it!", 24, 113,7)
 --print("like, now!?",24, 119,7)
end

function drawslimetransform(s)
 spr(transformstate.leg,s.x,s.y,1,1,s.flip)
 spr(transformstate.head,s.x, s.y-transformstate.yoff,1,1,s.flip)
 if(transformstate.body) spr(transformstate.body,s.x,s.y-4,1,1,s.flip)
end

function drawslimegirltransform(s)
 if(gtransformstate.leg) spr(gtransformstate.leg,s.x,s.y+s.lgoffset,1,1,s.flip)
 if(gtransformstate.body) spr(gtransformstate.body,s.x,s.y+6,1,1,s.flip)
 spr(gtransformstate.head,s.x, s.y+gtransformstate.yoff,1,1,s.flip)
end

function drawslimewin(s)
 local frame = slimewinstate.frame
 if(frame == 255) pal(10,6)
 if frame == 215 then spr(frame, s.x, s.y, 2, 1, s.flip)
 else spr(frame, s.x, s.y, 1, 1, s.flip) end
 pal()
end

function drawtitlestars()
    local speed = 5
    for s in all(titlestars) do
        pln(vec3(s.x,s.y,s.z),vec3(s.x,s.y,s.z+speed/3),12)
        pln(vec3(s.x,s.y,s.z+speed/3),vec3(s.x,s.y,s.z+2*speed/3),14)
        pln(vec3(s.x,s.y,s.z+2*speed/3),vec3(s.x,s.y,s.z+speed),7)

        --move titlestars.
        --use a fraction of speed to
        --create effect of star trails
        --being longer than distance
        --the titlestars actually move.
        s.z += speed/10

        -- reset star once it goes
        -- behind camera
        if s.z > 0 then
            s.x = rnd(40)-20
            s.y = rnd(40)-20
            s.z = -60
            s.col = 5
        end
    end
end

function drawwin(x,y)
 rectfill(x-2,y-1,x+61,y+16,0)
 rectfill(x-1,y-2,x+60,y+17,0)
 sspr(0,80,17,16,x,y)
 sspr(30,80,19,16,x+17,y)
 line(x+35,y+1,x+35,y+4,2)
 pal(1,2)
 sspr(90,80,06,16,x+37,y+1,6,16,false,true)
 pal()
 spr(197,x+44,y,2,2)
end

-->8
-- coroutines
function doslimetransform(s)
 transformstate={
    yoff=0,
    leg=43,
    body=nil,
    head=63
 }
 sfx"48"
 slime.blocked = true
 slimegirl.blocked = true
 for i=0,20,1 do
  if (i==5) transformstate.leg = 42
  if (i==6) transformstate.body = 29
  if (i==7) transformstate.body = 28
  if (i==8) transformstate.body = 30
  if (i==9) transformstate.body = 26
  transformstate.yoff = min(i,11)
  if(i == 12) transformstate.head = 58
  if(i == 13) transformstate.head = 15
  if(i == 14) transformstate.head = 11
  if(i == 15) transformstate.head = 10
  yields"4"
 end
 del(entities,s)
 slimegirl.x = s.x
 slimegirl.y = s.y - 10
 slimegirl.flip = s.flip
 activeslime = slimegirl
 setanim(slimegirl, slimeidle)
 setgroundpos(slimegirl)
 add(entities,slimegirl)
 slime.blocked = false
 slimegirl.blocked = false
 transformstate = nil
 if(slimehp >= 8 and slimeate) triggerdialog("i'm full now!") setanim(slimegirl, comment, true)
end

function doslimegirltransform()
 gtransformstate={
    yoff=0,
    leg=42,
    body=26,
    head=10
 }
 sfx"47"
 slimeate = false
 slime.blocked = true
 slimegirl.blocked = true
 yield()
 for c in all({15,14,63,58,61}) do
  gtransformstate.head = c
  yields"4"
 end
 for i=0,14,1 do
  if (i==1) gtransformstate.body = 30
  if (i==2) gtransformstate.body = 28
  if (i==3) gtransformstate.body = 29
  if (i==5) gtransformstate.body = nil
  if (i==9) gtransformstate.leg = nil
  gtransformstate.yoff = min(i,11)
  yields"4"
 end
 del(entities,slimegirl)
 slime.x = slimegirl.x
 slime.y = slimegirl.y + 10
 slime.flip = slimegirl.flip
 activeslime = slime
 setanim(slime, lilslime)
 setgroundpos(slime)
 add(entities,slime)
 slime.blocked = false
 slimegirl.blocked = false
 gtransformstate = nil
end

function doslimeexit()
 music(-1,30)
 if(activeslime == slimegirl) doslimegirltransform()
 slime.blocked = true
 slimegirl.blocked = true
 slimewinstate={
   frame=61
 }
 yields"4"
 slimewinstate.frame=255
 yields"4"
 slimewinstate.frame=215
 slime.x -= 4
 yields"4"
 for i=1,8,1 do
  slime.y -= 1
  yields"4"
 end
 music"56"
 slime.x+=4
 slimewinstate.frame = 61
 slime.y -= 1 
 yields"4"
 slime.y -= 1 
 slimewinstate.frame = 60
 yields"4"
 slimewinstate.frame = 59
 yields"4"
 slimewinstate = nil
 doslimetransform(slime)
 slime.blocked = true
 slimegirl.blocked = true
 yields"4"
 stagecomplete = true
 setanim(slimegirl, comment)
 triggerdialog("my tank! my warm and gooey tank! you saved me! and the ship too i guess. let's get going and bring these bugs to... wait, are there any bugs left?",213)
 yields"90"
 add(actions, cocreate(function() dogamewin() end))
end

function doslimedie()
 dtb_init()
 cleardialog()
 music(-1,30)
 triggerdialog("aaaaaaaaaaaaaaaaaaaaaahh!",71)
 stagefailed = true
 sfx(49)
 if(activeslime == slimegirl) doslimegirltransform()
 slime.blocked = true
 slimegirl.blocked = true
 slimewinstate={
   frame=61
 }
 yields"4"
 slimewinstate.frame=255
 yields"4"
 slime.x -= 4
 slimewinstate.frame=215
 add(actions, cocreate(function() dosweepfade() end))
 yields"30"
 dtb_init()
 cleardialog()
 txt=rndchoice(gameoverlines)
 finaltext = true
 triggerdialog(txt[1],txt[2],true)
end

function dogamewin()
 add(actions, cocreate(function() dosweepfade() end))
 yields"45"
 showwin=true
end

function doroomchange(door)
 paused = true
 dosweepfade()
 currentroom = door.to
 player.x = door.toexit
 player.y = 64
 activeslime.x = door.toexit - 8
 activeslime.y = 60
 camx = mid(0, player.x - 64, currentroom.w - 128)

 for b in all(baddies) do
  del(entities, b)
 end
 for b in all(bullets) do
  del(entities, b)
 end
 for b in all(bodies) do
  del(entities, b)
 end
 bullets,bodies,baddies={},{},{}
 lastspawn = 900
 doreversefade()
 paused=false
end

function dointrodialog()
 index,dialog,seqcomplete = 0, gameintro, false
 repeat
  if not onseqline then
   index+=1
   if index > #dialog then seqcomplete = true
   else
    local mood = dialog[index][2]
    triggerdialog(dialog[index][1], mood, mood ~= -1, function() onseqline = false end)
    onseqline = true
   end
  end
  yield"1"
 until seqcomplete
 cleardialog()
 introcontrol = true
 index = 0
 dialog = findslime
 seqcomplete = false
 onseqline = false
 repeat
  yield"1"
 until metslime

 introcontrol = false
 setanim(player, idle)
 doslimetransform(slime)
 slimegirl.blocked = true
 setanim(slimegirl, slimeidle)
 repeat
  if not onseqline then
   index+=1
   if index > #dialog then seqcomplete = true
   else
    local mood = dialog[index][2]
    local islex = mood ~= 197 and mood ~= 229 and mood ~= 230 and mood ~= 245 and mood ~= 246
    if not islex then setanim(slimegirl, comment)
    else setanim(slimegirl, slimeidle) end
    triggerdialog(dialog[index][1], dialog[index][2], islex, function() onseqline = false end)
    onseqline = true
   end
  end
  yield"1"
 until seqcomplete
 cleardialog()
 music(-1,1500)
 dosweepfade()
 initmap(map1)
 initgame(true)
 doreversefade()
 music(songs[songid])
 dset(0, 1) -- done intro
 onintro = false
 
end

function dodrawintro()
  local btime,bdraw = 0 ,true
  repeat
  btime+=1
  palt(0b0001000000000000)
  pal(6,0) pal(5,0) pal(10,0)
  if(btime > 45) bdraw = not bdraw btime = 0
  if(bdraw) spr(149, 64,24)
  pal()
  palt()
  spr(215, 147, 58, 2, 1)
  spr(215, 195, 58, 2, 1)
  spr(215, 175, 62, 2, 1)
  yield"1"
  until not onintro
end

-->8
-- logic
function handleinput()
 -- input
 local left,right,up,down,actiona,actionb=btn"0",btn"1",btn"2",btn"3",btnp"4",btn"5"
 if(currenttext) actiona = false
 if player.acting then
  if player.anim == strike then
   if(player.frame == 5) spawnlexbeam(player.flip)
   if(player.frame >= 6 and player.frame < 9 and actiona) local ft = player.ft setanim(player, strike2, true) sfx(34)
  elseif player.anim == strike2 then
   if(player.frame == 3) spawnlexbeam(not player.flip)
   if(player.frame > 6 and actiona) setanim(player, strike, true) player.frame = 3 sfx(34)
  end

  return
 end
  
 local move={x=0,y=0}
 if(left and player.x > 0) move.x -= .25 player.flip = true
 if(right and player.x < currentroom.w - 8) move.x += .25 player.flip = false
 if(up and player.groundpos > groundtop) move.y -= .125
 if(down and player.groundpos < 104) move.y += .125

 if(actiona) then
  setanim(player, strike, true)
  sfx(34)
 elseif(move.x ~= 0 or move.y ~= 0) then
  if(actionb) then
   setanim(player, running)
   if(player.frame == 5 and player.ft == 0) sfx(32)
   if(player.frame == 10 and player.ft == 0) sfx(33)
   move = v_mult(move, 3)
  else
   setanim(player, walk)
   if(player.frame == 3 and player.ft == 0) sfx(32)
   if(player.frame == 6 and player.ft == 0) sfx(33)
  end
  v_addto(move, player)
 elseif(not actiona) then
  setanim(player, idle)
 end
end

function hitobject(m,range)
 range = range or 2
 --[[
 for bx in all(boxes) do
  local ldelt,rdelt = m.x - (bx.x + 7),bx.x - (m.x + 7)
  if(bx.floor == m.floor
  and bx ~= m.box
  and not (m == fufu and minx.box == bx and m.rolling)
  and ((m.flip and ldelt >= 0 and ldelt <= range)
   or (not m.flip and rdelt >= 0 and rdelt <= range))) then
   return bx
  end
 end
 ]]
 return false
end

function hitwall(obj)
 --[[
 for w in all(walls) do
  local ldelt,rdelt = obj.x - (w.x + 7), w.x - (obj.x + 7)
  if w.floor == obj.floor
   and ((obj.flip and ldelt >= 0 and ldelt <= 1)
   or (not obj.flip and rdelt >= 0 and rdelt <= 1)) then
   return w
  end
 end
 ]]
 return false
end

function setgroundpos(obj)
 obj.groundpos = obj.y + (obj.shdwh or 9)
end

function spawnlexbeam(inverse)
 del(entities,lexbeam)
 lexbeam={
   flip=player.flip,
   ft=0,
   y=player.y + 4,
   x=player.x + 9,
   shdwh = 16,
   inverse = inverse
 }
 setgroundpos(lexbeam)
 if(inverse) lexbeam.y +=1
 add(entities, lexbeam)
end

function spawnbullet(owner)
 slimepos.groundpos = activeslime.groundpos
 local b = {
   x = owner.x - 4,
   y = owner.y,
   flip = owner.flip,
   small=1,
 }
 if(flip) b.x += 8
 setgroundpos(b)
 b.dir = v_normalised(v_subtr(b, slimepos))
 setanim(b, seedshot)
 add(bullets, b)
 add(entities, b)
end

function spawnmob(x, y, flip, type)
  local b = {
    x=x,
    y=y,
    flip=flip,
    type=type,
    hp=type.hp,
  }
  if(b.shdwh) b.y-= (b.shdwh - 9)
  setanim(b, type.spawn or type.idle)
  add(baddies, b)
  add(entities, b)
end

function spawnrandommob(nosound)
 local crate = {
     x = flr(rnd(128)) + camx,
     y = -7,
     shdwh = (flr(rnd(5)) * 8) + groundtop + 9,
     contents = rndchoice(droppablebads)
 }
 if(not nosound) sfx(25)
 setanim(crate,{209})
 add(crates, crate)
 add(entities, crate)
end

function hitslime()
 activeslime.lasthit = 30
 slimehp -= 1
 sfx"41"
end

function triggerdialog(text,mood,islex,callback)
 dtb_disp(text,callback or cleardialog)
 currentmood = mood
 currentportait = 197
 currenttext=text
 currentportaitflip = true
 if(islex) currentportait = 195 currentportaitflip = false
end

function cleardialog()
 currentmood = nil
 currentportait = nil
 currenttext = nil
 if(finaltext) initgame() music(songs[songid]) return
 if(stagecomplete) nextstate = title
 if(not stagecomplete and slimegirl.blocked and (slimegirl.anim == complain or slimegirl.anim == comment or slimegirl.anim == tantrum)) slimegirl.blocked = false setanim(slimegirl, slimeidle)
end

-->8
-- anim utils
function drawlarge(obj)
  local x,frame,y,anim,flip,hoff = obj.x,obj.frame,obj.y,obj.anim,obj.flip,obj.hoff or 0
  if(flip and hoff) hoff*=-1
  spr(anim[3][frame], flr(x), flr(y+obj.lgoffset), 1, 1, flip)
  spr(anim[1][frame], flr(x)+hoff, flr(y)-1, 1, 1,flip)
  if(obj == player and obj.flip and anim == strike) pal(10,13) pal(15,14) pal(9,2) pal(11,13)
  if(obj == player and obj.flip and anim == strike2) pal(13,11) pal(14,15) pal(2,9) pal(11,13)
  spr(anim[2][frame], flr(x), flr(y+6), 1, 1, flip)
  pal()
end

function drawsmall(obj)
    local frame = obj.anim[obj.frame]
    sspr(frame.sx, frame.sy, 4, 4, obj.x, obj.y, 4, 4, obj.flip)
end

function setanim(obj, anim, acting, fx)
 if(anim == obj.anim) return
 anim.count = #anim
 if(anim.shdwh) obj.shdwh = anim.shdwh
 if(obj.large) anim.count = #anim[1]
 if(obj.small) anim.count = 4
 anim.rate = anim.rate or framerate
 obj.ft = 0
 obj.frame = 1
 obj.anim = anim
 
 if(acting) obj.acting = true
 if(fx) sfx(fx)
end

function updateanim(obj)
 obj.ft += 1
 obj.reset = nil
 if(not obj.anim) return
 if obj.ft > obj.anim.rate then
  obj.frame += 1
  obj.ft = 0
 end
 if obj.frame > obj.anim.count then
  if(obj.anim.terminal) obj.frame = obj.anim.count obj.ft = obj.anim.rate + 1 return
  obj.frame = 1
  if(obj.acting) obj.acting = false
  obj.reset = true
 end
end

-->8
-- utils
function yields(to)
 for i=1,to,1 do
  yield()
 end
end

-- starfield code by chase!
function rndchoice(t)
 return t[flr(rnd(#t))+1]
end

function makestars(n)
 local starcolors={15,14,7,15,7}
 stars = {}
 for i=1,n do
  add(stars, {
   x=flr(rnd(128)),
   y=flr(rnd(groundtop-2)),
   c=rndchoice(starcolors)
  })
 end
end

function inittitlestars()
 --initialize table of stars
 --to random positions.
 titlestars = {}
 for i = 1, 128 do
  add(titlestars, {
  x = rnd(80)-40,
  y = rnd(80)-40,
  z = -rnd(60),
  col = 5}) --color
 end
 -- camera vector
 starcam = vec3(0,0,0)
 -- perspective line function
 pln = pline(starcam)
end

function vec3(x, y, z)
   return {x = x, y = y, z = z}
end

function sortByY(a)
   for i=1,#a do
       local j = i
       while j > 1 and a[j-1].groundpos > a[j].groundpos do
           a[j],a[j-1] = a[j-1],a[j]
           j = j - 1
       end
   end
end

function v_normalised(v)
 local len,nv = v_len(v.x, v.y), v_new(v.x,v.y)
 if(len ~= 0) nv.x /= len nv.y /= len
 return nv
end

function v_subtr(source,target)
 return v_new((target.x + 4) - (source.x + 4),
 target.groundpos - source.groundpos)
end

function v_new(x,y)
 return {x=x,y=y}
end

function v_len(x, y)
  local d = max(abs(x),abs(y))
  local n = min(abs(x),abs(y)) / d
  return sqrt(n*n + 1) * d
end

function v_mult(v,f)
 return v_new(v.x*f, v.y*f)
end

function v_add(a,b)
 return v_new((b.x + (b.ox or 0)) + (a.x + (a.ox or 0)), (b.y + (b.oy or 0)) + (a.y + (a.oy or 0)))
end

function v_addto(a, b)
 b.x += a.x
 b.y += a.y
end

function commitstate()
 if(nextstate ~= state) then
  prevstate = state
  state = nextstate
 end
end

function dosweepfade()
 fadex,fadey,fadew,fadeh=64,56,2,2
 for i=0,64,1 do
  fadex-=1
  fadey-=1
  fadew+=2
  fadeh+=2
  yield"4"
 end
end

function doreversefade()
 fadex,fadey,fadew,fadeh=0,0,128,128
 for i=0,64,1 do
  fadex+=1
  fadey+=1
  fadew-=2
  fadeh-=2
  yield"4"
 end
end

function fadepalette(idx, fullscreen)
 pal(1, sget(idx, 9), fullscreen)
 pal(2, sget(idx, 10), fullscreen)
 pal(3, sget(idx, 11), fullscreen)
 pal(4, sget(idx, 12), fullscreen)
 pal(5, sget(idx, 13), fullscreen)
 pal(6, sget(idx, 14), fullscreen)
 pal(7, sget(idx, 15), fullscreen)
 pal(8, sget(idx, 16), fullscreen)
 pal(9, sget(idx, 17), fullscreen)
 pal(10, sget(idx, 18), fullscreen)
 pal(11, sget(idx, 19), fullscreen)
 pal(12, sget(idx, 20), fullscreen)
 pal(13, sget(idx, 21), fullscreen)
 pal(14, sget(idx, 22), fullscreen)
 pal(15, sget(idx, 23), fullscreen)
end

function pline(c)
   local function project(x, y, z)
     -- world space to camera space.
     x, y, z = x-c.x, y-c.y, z-c.z

     -- camera space to screen space.
     x, y = -x/z, -y/z

     -- screen space to raster space.
     x, y = x*64+64, -y*64+64

     return flr(x), flr(y)
   end

   return function(p1, p2, col)
     -- ignore if both points are in front of near plane.
     if p1.z > (c.z-0.1) and p2.z > (c.z-0.1) then return end

     -- final line points.
     local x1, y1, x2, y2

     -- if p1 is in front of near plane,
     if p1.z > (c.z-0.1) then
       -- find the point of intersection and update p1.

       -- update x.
       local m = (p1.x - p2.x) / (p1.z - p2.z)
       local x = m*(c.z-0.1) + p2.x

       -- update y.
       m = (p1.y - p2.y) / (p1.z - p2.z)
       local y = m*(c.z-0.1) + p2.y

       -- update z.
       local z = c.z-0.1

       x1, y1 = project(x, y, z)
     else
       x1, y1 = project(p1.x, p1.y, p1.z)
     end

     -- if p2 is in front of near plane,
     if p2.z > (c.z-0.1) then
       -- find the point of intersection and update p2.

       -- update x.
       local m = (p2.x - p1.x) / (p2.z - p1.z)
       local x = m*(c.z-0.1) + p1.x

       -- update y.
       m = (p2.y - p1.y) / (p2.z - p1.z)
       local y = m*(c.z-0.1) + p1.y

       -- update z.
       local z = c.z-0.1

       x2, y2 = project(x, y, z)
     else
       x2, y2 = project(p2.x, p2.y, p2.z)
     end

     line(x1, y1, x2, y2, col)
   end
end

function initpal()
 -- force custom pal persistence
 poke(0x5f2e,1)

 -- set custom palette 1-15
 pal({130,1,137,4,3,11,7,5,2,136,14,132,140,13,135},1)
end
-->8
--dialog
--blocking sequential
gameintro={
  {"another successful digibug hunt, the system is clean for another few cycles!",212},
  {"lexicon! we have a problem in the ship's digisystems! the whole place is going haywire!",-1},
  {"it's the slime drive, it's lost power somehow! is there a slime leak?",228},
  {"you should find out, but be careful! i'm seeing that some... no, most of the cages holding the digibugs are offline!",-1},
  {"i'd better clean up that mess then. are my blast bracelets charged?",227},
  {"yep! just remember, if you want to combo punch, it's all in the timing! try not to get distracted, though, you'll lose your focus.",-1},
  {"that's not ominous. okay, let's do this. lex away!",228},
}
findslime={
  {"are you from the slime drive? i didn't know you were sentient... how did you get here?",228},
  {"i was tubing through the slime engine and got dumped out!",229},
  {"i bet the slime tank lost pressure when we hit that space rock. let's get you back home.",227},
  {"okay but i'm cold and hungry, got any digibugs to eat?",245},
  {"i suspect we'll find some along the way...",212}
}

--one off
gameoverlines={
  {"farewell, animated lubricant. enjoy life as monster indigestion.",244},
  {"i guess i'm getting out the space paddles and rowing my way home.",244},
  {"did you hear something, slime? sounded like... aaaaaaaaaaaaaah or such. slime?",228},
  {"finally! i'm rid of that complaining ball of life-saving engine fluid! wait. that's bad.",243},
  {"if i find out you died on purpose, there will be heck to pay when i reconstitute you.",227}
}
fhcomments={
  {"i can't tell if there's too many digibugs or not enough.",213},
  {"the air is sticky!no, wait, that's me.",229},
  {"what do you do when there's no bugs to punch?",246},
  {"question... nevermind i forgot.",213},
  {"how come you aren't eating any bugs?",213},
  {"i can't run, because i don't want to.",246},
  {"can't you just carry me?",245},
  {"why don't i get punchy thingies?",245},
  {"you're lost, and you're making me lost.",246}
}
mhcomments={
  {"these bugs aren't my favorite yet.",246},
  {"spend more time punching, and less time... not.",230},
  {"did you see the size of that thing?",229},
  {"you don't know where you left my tube, do you.",246},
  {"great. just great. great. greeeeeeeat... great.",246},
  {"i don't even know what umbrellas are for.",213},
  {"let's stop and sing something.",213},
  {"i don't even think those flowers are really bugs.",229}
}
lhcomments={
  {"you are being really slow, did you know that?",213},
  {"i'm hungry and angry. i'm hungangry.",230},
  {"stupid bugs eating me, i'll just eat you back!",230},
  {"let's just go along the outside of the ship, it's easier.",213},
  {"if i'm here and you're here, who's piloting the ship?",229},
  {"what if your spaceship didn't run on slime? what would you even do?",246},
  {"you're not punching the right bugs. go for the meatier ones. that one.",246},
  {"i know it's not possible for me to stub my toe, but it's like i just did.",213},
  {"look, slimes are normally super fast. but only when we're in all those tubes.",213}
}
chcomments={
  {"getting eaten by digibugs was not in the job description!",230},
  {"i'm not gonna shut up. and i know you didn't say shut up but you were thinking it!",230},
  {"oh i'm sorry is this adventure not adventurey enough? i could do more screaming for help... help! no seriously. help.",229},
  {"you're probably trying to keep all those bugs for yourself... learn sharing!",230},
  {"when we get back to my tank, there better not be any floaties in it... you need to clean my tank okay?",246},
  {"i'm just going to stop right here. you get my tank, put it on a cart, and wheel it here. kay?",246},
  {"i don't think i should have to thank you for catching all the digibugs you already caught once!",246},
}
__gfx__
0022222000222220002e2220002e22000022222000222220bbfff777aa99000000000000000000000056666000566660005666600056ff60005666600056ff60
02e2222202e22222022222220222222002ee222202e2222200aabff77ffba900bbffff77aa990000056f6ff6556ffff6056f6ff605f665f6056f6ff605f665f6
22222222222222222e222222e2222222222222222222222200000abf777ffa9009aabbff7ffbaa90566665f656f66565566665f656661616566165f156616661
2e2288822e228882222288822228882222e228822e2288820000000a7777ffba000009ab777ffbaa56f516166665161656f566665665161556f5151556651615
2228e7e72228eeee2228eeee22eeeee222228eee2228eeee0000000a7777ffba000009bf777fbaa9565616166f561616565615165f5b6a6b565616165f5b6a6b
2224e7e72224e7e72224e7e722e7e7e222284e7e2224eeee00000abf777ffa9009aabff77fbbaa90565b66b5655b66b5565b66b556566a65565b66b556566a65
02224440022244400222444002244420022244400222444000aabff77ffba900bbfff777aa990000565555505555555056555550565555505655555056555550
0000cc000000cc000000cc000000cc000000cc000000cc00bbfff777aa9900000000000000000000055655000556550005565500565655000556550056565500
76d5e2d5000000000000000000000000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000660066
11000000005666000c55664400466600cc5566cc0056660000556600005556000446660005449a44005566500055665000556650005566500555665055665566
2110000005c55500c5445a440c455500944555aa005455000054550000545500a44555c005549a440556ff600556ff60056fff60056ff6605f5ff6606565f660
331100000c45640011c449a009a449ccaa556c9900946c0000c460000c5c40009ac56c11005560005f6665500f6665660f6665660f6666606566556656555560
44221000099c190011cc490009a449cc44cc400000aa21000019a000011c9a00000cc0aa00ccc000565555560655656506665565066656506666556600566000
5511000004400ac0cc0000000000000044000000004409c000ca44000cc0a440000000cc00000000665000660000000000000000000000000000000000000000
66dd5100044000c00c0000000000000000000000004400c000c044000cc00440000000cc00000000000000000000000000000000000000000000000000000000
7776d510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8884210000ff3000003ff000003f3000000f30000003f0000003f0000003f000bffb000000000b7f000000000000000000000000000000000000000000000000
9994210000ff33000033f0000033f300003f30000003ff00000ff300000ff300f44f660005449a4400555000000f6600000f6000000f60000055550000555000
aa99421003f333000075f300003344400033f3000033ff00003ff300003f3300f44f55c005bbf77f05f65500000f660000066500005f6500005f555000f65000
bbb331000440cc0000f5544000cc444075cc4400000c440000044c000044cc00bffb6c11bbff77f00f6665000005650000566500005655000056656505666500
ccdd51000440cc0000f6644065cc0567f55c4400000c440000044c000544cc00000cc0aa0bbbb0000660565000566500005665000566560006f655650f656500
dd511000056065000075c000556c05f0f6c06560076560000056550075505600000000cc00000000565006500566500000666500566066005665065056505550
ee444210565055600055000076000700700005570f55600005565f70f6605500000000cc00000000660056600666500006656650665065006600066556000665
fff942107f707ff7007f70000f700000000007f0007ff70007ff70000f77ff700000000000000000665056650066650005665000066566506650000066505665
f77fa90000ff3000003ff000003f3000000f30000003f000000f30000003f0000000000000007dd7000000000000000000000000000000000005600000056000
0af77fa003ff3300003f3000003f3300003f3000000ff300003ff0000033f3000c5666000c56d77d00055000000550000000000000000000005f6660005ff600
01af77fa3f33330000333300003fcc000033f3000033f3000033f30000333f00045edde00955d77e005ff600005ff600000550000000000005f61b6605f66f60
009af77f4400cc000f544c000044ccc075044c0000044c0000c4400000cc4400095d77d9aa557de705666f6005f66660055ff6600555ff605616655005616165
009af77f4400ccc00f544c0005440567f5644cc000044c0000cc440005cc4400aacd77d944cc4cde5f666666566161665f61616655f666665f6651005fb666b5
01af77fa0560656007656000756005f0f6440560075540000556560075565600440edde044000ded566161665f61616656616166556161665fb5111056666665
0af77fa05650556000556000f6000700700005570f56c00005605670f6055600440000dd000000d255b666b555b666b555bf66b555b666b556651111566f6550
f77fa9007f707ff7007ff7000f700000000007f000f7f70007f7ff000707ff700000000000000020055666500556665005555650055555500555555505555555
9999999999999999999999999999655678edeeed188888888888888855115611eeeeeeee1eeee1d2eeee9eeeee55665e0000000000000000ccccccc8cccccccc
92222222222222225562222222265225789299e21221122211222112569166919a9e9a9e188881d27777b777e55e665577777b477e475d54ccccccc98ccccccc
91818181818181819155818181858181789299e212111121991211116616666188888888185681d2eeee9eee55ee6655fbcfbfbcefeddfddccccccfa9fcccccc
912121212121212191256621555521217d2299e212211222112221126bb666668888888818558888eee9eeee55e655e5bfb00b00fbf5dfd505cccc7777cccc50
91818181818181819181855565818181e89999e212222222222222225bb6aaa68880d288188881d28898888855e665ee0b0006000f5005000005c07ff70c5000
912121212121212191212165256121217e9999ed1221122211222112056aaaaa8800d288111111d2111111d25ee66e5556005650065056500600500ff0050060
99999999999999999999999999569999789999e21219912111121991005aabba8000dddfddddd89addddd89ad5d66e5dd655d652556dd65d5002050440502005
222222222222222222222222222556227d2299e2122112221122211200000566000822242222289922222899225566e226226522256222656506005dd5006056
2888888888888888eeedeeed7777e777eeeede88888e888e80898089ee4884ee17eeee7100000000000000000566e550e66556eee55655edc65000522500056c
28ecc8888888cce8e99299e288881888999ede888989898980898089e22ee22e7888888777777777777777777766e554f65555fe55e9e5529465565665655649
28c88888c88888c8e99299e288818888999e298881898189808980894884488488856888ffffffffffffffffff666e5cf656e5655e996e52ac00602dd20600ca
288888ccecc8888811111111a111111a999e29e88289828980898089244ee442888568880000000000000000005e6ee5655655655e2569e2c56000022000065c
28c88888c88888c8eeeeeeee88888888222d228e80898089808980898e8ee8e828888882000000000005000005ee60005e56655e599e5992c65005600650056c
28ecc8888888cce88888ee88111a9111eeeee2888089808980898089484224848222222800000000600506000ee560005e556565e99e559d9c6556a55a6556c9
2888888888888888888ee888888888889999e28880898089808980892428824288e8e7e8dddddddd5565d6565e5662dd56e5556fe996e552ca966999999669ac
2111111111111111eeeeeeeeaabaaaba9999e28880898089888988898288882818e8e7e1222222226556556522666222e66e555622262e22cccc44999944cccc
eeeeeeeeeeeeeeeeeeeedeeeeeedeeedeeedeeedeeeedeeee2e2e2222e2e2e28ccccccccccccccccccccccccccccccccc0cccccccccc0ccccccccccccccccccc
e888888888888888999edeeee99299e2e99299e2999edeeee18181ee2e2e2e28cccccccccccccccccccccccccccccccc0c0cccccccc0c0cccccccccccccccccc
e8888e8888e88888999e2999e99299e2e99299e2999e2999e1eee18e2e2e2e280ccccccccccccccccccccc00ccccccccc0c0cccccc0c0cccccccccccc000cccc
e888888888888888999e2999e22299e2e22299e2999e2999e188818e18181818000000ccccccc00ccccc000ccccc000ccccc000000cccccccccc000c000ccccc
e888888888888888222d2291129999e2e29999e2222d2299e18b818e1eeeee18000cc00ccccc00ccccccc00cccc000ccccc00000000cccccccc000ccc00ccccc
e8888e8888e88888eeeee21ee19999ede29999edeeeee299e18a818e18888818c00cc00cccccccccccccc00ccccc00c00c00cc00cc00cccccccc00c0000c0ccc
e8888888888888889999e2e88e9999e2e29999e29999e299e1888a8e18562818c00000cc0c00c00c0000c00c0c000000c000cc00cc000cc00c000000c00000cc
81111111111111119999e288882299e2d22299e29999e222e18b8a8ea8222818c0000cc0000c00c00c00000000c0000cc0000c00c0000c0000c0000cc00c00cc
999999eeee999999e99299888899e999e99299e29999e999e18a81bb18656818c00c00cc00cc00c00c00c00c00cc00ccc0000c00c0000000c00c00ccc00c000c
111eee8888eee111e99299188122d229e99299e29222d229e188818e18888818c00cc00c00cc00c00c00c00c00cc00ccc0000c00c0000c00c00c00ccc00cc00c
9ee9988888899ee9e99299e11299e929e99299e22299e929e1eee18e11111118c00ccc00000cc00c0000000c00c000c0cc000c00c000cc00c00000cc000cc00c
e888888ee888888ee99299e29999e929e99299e29999e929e188818e1eeeee18c00ccc00c0ccc0ccc000c0c00ccc000ccc00cc00cc00ccc0000c000cc0cc000c
8e999888888998e8e99299e29999e929e99299e29999e929e1eee18e1eeeee18c00cc000ccccccc00c00ccc0ccccc0cc0c0cc0000cc0c0cc00ccc0ccccc000cc
18eee888888eee81eeedeeedeeeeeedeeeedeeedeeeeeedee188818e18888818c000000cccccc000000ccccc0cccccccc0cccccccccc0cccccccccccccc00ccc
99888eeeeee88899888828882888828888882888288882888eeeee88eeeeeee8000000cccccccc00ccccccccccccccccccccccccccccccccccccccccccc0cccc
1111188888811111aaaabaaabaaaabaaaaaabaaabaaaabaa888888888888888800cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0ccc
220000000000000000056500000000222000000233658533111c1c11c188c8c18556676888888888855667688666676882000e088888888882222e0882200e08
20007777770007000052025007770002007f7e003556585394999499888888888556676866686666855666866866766880220e0800080000822222802820e008
200000000000000005062025000e70020000007055583555c111881111c1c1118556676877778777855668677787665882220e08eeee8eee8222282eee8e0008
0000000000000000066062060000e700000000005885633394999994999988998856678866668666855586666668665888220e88000080008020822222280008
00065000000000000506202500000e00006500005365533311c111c881111c118588886866668666185866666666858182888808022282221808222222228081
00000000000000000052025000000000000000003355553344949949998888998556676866668666188555666666588182220e08022282221880222222220881
00065505065600500005650000000700006560003368553311111111111111118556676855585555918855555555881982220e08202822229188000220008819
00000000000000000000000000000000200000023366855399999999999999998556676888888888991188888888119982220e08888888889911888888881199
00000000000000000656000000000000e899998e56563a3aeeeeeeeeeeeeeeee855667688e88ee88888881999911888882000e088e88ee888888811999118888
000000000000000000000000000000008800008833333a3ae8888888888888888555576866588e88666668199188566680220e0800088e880000088191880000
000000000000000003303030000000009566500965633333e0208100800182108555575875558e88777768e11e85666782220e08e0008e88eeee08e81880000e
000000000000000000000000000000009600600933333a3ae8888888888888882855578265558e88666686811858667628220e8200008e8800008008182800e0
00065600050560000500000000000000951aa10966663333e020801080018120e288882e65558e886668676885568766e288882e00008e8822280e0882228e22
200000000000000000000000000000029aa16a0933336333e888888888888888ee2222ee65558e886686676885566866ee2222ee00008e8822820e0882222822
2006656656060056050565005606000288006a8833333633e002822282108120eeeeeeee55588e885866676885566785eeeeeeee20088e8828000e0882000e82
22000000000000000000000000000022e899998e33333363e888888888888888888888888888ee888566676885566768888888888888ee8880000e0880000e08
055500000000555000550000055000000000000000000550055000000550000000f77ff661110000066000000000000006600000000066600006666666600000
6655500000056555056550006655000ff500055500005655ff552000f65500000f77ffff77f6611167f600000007f6007776100000067ff610677fffff661000
f66552200006665526f65200ff55206666505f652200ff65ff552200f6552000f77f6666f77f661167f61000006ff66077761100000777f611677ffff6661100
ff6552200006f65526f65220f665225666525f655220ff65f6552200f6552200f7f661166fff66617f661100006f66617fff6110006777f6116fff6666611100
666552200006f66526f6522066652205552256665220ff655665222066552200f761111111666661ff66110000066611f66f6610006fff66116f661111111000
66655220000066652666522066652202222266665522f6652665522666552200f7666111011166117666110000001111f66f661106f6ff66166f611100000000
66652266500056652666522066652200222066666552f6652566555665522200ff666660000111167666110000006610f666666116f6f6661677f77660000000
566526666500066526666f6566652206f50066666555f665225ff6665552200006ff6666666000067666110000077f61f66666616ff6f66616777fff66100000
5666266665500665266666666665226f66526665665566652205666655222000006fff6666661006f66111000007ff617666f6666f66f66616ff6ff666110000
5666566566550665266655666665526f6652f6656665666522005f6652220000001116fffff66106f66110000007f6617766ff66ff61f66616f6666661110000
05f666656665665526f65555666552566652f6655666666522005f65522000000660111177ff6616f6611000006f6661f6661ff66661ff6616f6661111100000
05f666552666665526f6522266655255665266652566666522005f655220000067f60011f7ff661666611000006f6661ff6616666611fff616f6611100000000
055665552666665526f6522266652205665266652256666522005665522000006fff6666f7f6661666666677611f66616f66166666106ff6167f666666611000
0555555220566555256652206665200555525f652225665522005665522000006ff6fffff66666116fffffff661ff6616ff6116661106ff616777fffff661100
00555522202555522565520056552002552256652222555220005565522000000666666666666110666666666616f661666611011100666616fff66666661100
00055522002222220055220005522002222005522000222220000555220000000016666666661100066666666111661006611000000006610166666666611000
0d77ddddddddddddd777d7d000022220222220000000066666550000000000004000400040004000000000000000000040004000004004000400400000000000
dddeeeeeeeeeeeeeeeeeed7d00222ee2222222000005666666665500000000004404400044044000400c4c004000400044044000004444004444400000000000
ddee1111111111111111eedd0222222e2222e22000666666ff666500000000004444400044444cc044c44cc044044cc04444400004f4f4004f4f400000000000
dde100000000000000001edd222ee22222222e2006666f66ffff66500e0000004f4f4c404f4f4ccc444441104444411c4f4f4c4007174c4044444c4040004000
dee000000000000000000eed22e2222222222220566fff66666f666500e00e00c444cc44c444cc114f4f41104f4f411cc444cc1101114c1117174c1144044c40
de10000000000000000001ed22e222222222220066ff6666666666650cececce01c1c41101c1c411c444cc11c444cc1001c1c411071744117171441144444c44
de00000000000000000000ed22222228888882206666666665fff665c4e4e4ec01c144111010010101c1c40101c1c10001c144c10444c4c10444c4c1499941c1
de00000000000000000000ed02222288888888225666666665fff665cccccccc0101c111000001011010000001010000010101010101010101010101144411c1
de00000003444440000000ed2222288eeeeeeee2551156115555f665000000000000000000000000000000007700077700000000770007770000000000000000
de00000034a33a44000000ed2e22448e77ee77e25691669166556655000000000000000000000000000000007e707ee700000000abab7ee7abab000000000000
de0000004ccccccc000000ed22224c4ee7eee7e066916691665566650000000000000000000000000000000007aaaa70e7aa77e0bbbbee70bbbb7e000a000000
de000000c1e1e1ec000000ed2222444eeeeeeee06bb66666bb566f650000000000000000000000000000f000bbbbaab9bbbba777909ba7009e9ba7e0a0099bb0
de000000c1e7e7ec000000ed02222244444444005bb6aaa6bb56666500000ff66665500000000000000faf00abab0b9babab0b9b909aab00979aab77ab000ba0
de000000c1e1e1ec000000ed00022224411144000566abb665566655000056666666665500fff0000006f500909000bb909000bb0009bb000009bb00bb9abbb0
de000000c1e1e1ec000000ed000000c44aa1400000555555565665000556556666665550000f5000000650009090000a9090000aa0bb9900a0bb9900b9baa700
de000000cccccccc000000ed000000ccccc00000000005666655550000055555555550000065000000650000000000a0000000a00aabb0000aabb00009bbee77
de00000000000000000000edeeeeeee2eeeeeee2551156115516566182565666666677667656552800000000000000000000000000fdf00000fdf00000000000
de00000000000000000000ed7eeee7e2e7eee7e2569166915691669182565666666677667656552800000000000000000000000000ddd00000ddd00000000000
dee000000000000000000eed77ee77e0e7eee7e066116611669166918256566666667766765655280000000000000000000000000099d800007ad80000000000
dde000000000000000000e7deeeeeee0eeeeeee06bb666666bb6666682565666666777667656552800000000000000000fdf0000008e8e0000dde80000000000
ddee0000000000000000eedd44444400444444005bb6aa665bb6aa6682565666666777667656552800eeeddd00eeeddd0dddeddd0808eedd008e8edd80800080
dddeeeeeeeeeeeeeeeeeeddd4411440044444400056aaaa60566aaa6825656666667776676565528fdf8e8ddfdf8e8dd00e8e8dd000088dd0080e8dd080808dd
1dddddddddddddddddddddd14491400044914000005555550055abb5825656666667776676565528ddd808ddddd808dd008888dd000080dd000080ddddd8e8dd
011111111111111111111110ccc00000ccc0000000000566000005668256566666677766765655280080080008008080000080800000808000008080999eeddd
00000002cccccccccccccccc77ee77e2eeeeeee255615616556656668256755555577755755655280430043000ff000000ff00000fbbf0000000000000000000
02020222c0e0e0ecc0e0e0ece7eee7e2eeeeeee25691669156966661885555755555775575555588c44ccccc0faaf000fbaabf00fb77bf0000000a0000000000
00020222c000000ec0e0e0ec77ee77e0777777e066916691669166918888555577757755555588880cc004400faaf000fbaabf00fb77bf0000af000000000000
00000222c000000cc0e0e0eceeeeeee0eeeeeee06bb666666bb666668988888888888888888888980000000000ff600000ff65000fbbf50000000f0000000000
00000022c000000cc0e0e0ec44444400444444005bb6aa665bb6aa668989899999999999999898980cc00cc00000655000000650000006500f0600f000000000
00000082ce2222ecc2e2e2ec41114400411144000566aaa60566ab66198989baeeeeeeeeab989891c43cc43c005650000056065500560550f055600000000000
8111111ec1e111ecc1e1e1ec4911400044444000005555550055555511898999e656565e999898110440c44c000650000000560000005600000065500a5665f0
99999999ccccccccccccccccccc00000ccc00000000005660000056611118988eeeeeeee8898111100000cc000650000005660000056600000660000ff66a655
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
656252525252525263646564625252639b89898989898b888888885665646564656465655d5c5d655c5d5c5c5d6464646564659f8d8d8f658a9a65649f8f6564656564656488646252525252526388646564659f8d6765646564668d8d8d676465646564659f8d8d8d8d8d8d8d8d8d8f64656465646564656464656488649f9d
7554000000000000447475755400004488000000449b898b8888885675747574757475495a5b4d5a5c5b5c5c5d7474747574758c53535353638862528c525263759b8989898b745400000000004488747574948c84777574759476849b89777475747574758c74757475747574757475746252525263559f9d9b99648a9a8c65
65540000000000004464655554000044880000004488529b8b88885252526364656455484a5c4a4a4b5c4b5c646564646564558c82919293448854008c0000446588646564656472535353535373886465668d8f67898989678989898b678c6462525263668f62525252525252525263645400000044568c9f88659f9d888c9b
7554000000000000447475567253537388000000448800880088880000004474757456495a5b5a4d5a5b5b5d747574747574568c4a4a4a4a738854008c000044758874757475749f8d8d8d8d8d8d887475768989777475747774757475778c7454000044769454f1f2f2f1f2f1f2f1447454000000445558705171588d888c88
655400000000000044645564656564658a9a53537388008800888a898989899a656465484a4a4a4a4a4b4b5d646564646564558c625252639f8d8d8d8f000044658864656465648c646564656465886465646564808266949b89896784668c6454000044808354f2f0d1f0f2f0f2f244645400000044566758675866898b8c88
757253535353535373745674757574757488749b89898989898b000000004488757475495a4d4c4d5a5b5b67747574747574568c548083448c885400000000447588749f8d8d8d8c7467666774758874757475749093768d887475778d768c7454000044929354f2f1f2f2d1f2f2f04474540000004455776657667689898c8b
6565666766676767646465556667656667886567648800880000000000004488656465484a5c4a4a4a4b4a77646564646564558c549093448c8854000000004465668d8c6467948c648092839b898b6465646789668989898b67656494648c6454000044646554f0f2f1f2d1f2f1f2446454000000445658766676588d8d8f64
757576777677777775747556767775767788757774885388535353535353738875747575745d7475745d7475747574747574569c725353739c987253535353737576749c7477749c7477767798757474757477847674757475778d8d8d8d8f747253537374757253535353535353537374725353537374536776675373747572
40505150518687505150516061606140418897969788978a8989899a40404188414042434243428642434286424387404140414041404041414140414141414041404141414041404141404140414140414186878786707187864041414140414141404140417050555055505550517141404141404141414041414041414140
50515051505150515051707160616061408a8989898860617140418841559b8b404041418743424387434243874140414040414041415051414140414041404140414196979697969740414141404041404141404141414041414041404140404041404141414170566056605660617140414140414041414546454141404141
405051454650515051505160616061404140419b898b97609b89898841568840414041404141864342864141404155404141414041505186878687454640414041414041414140405541404140414140414041404141404141404141414041414141414041404140414140404140414041414145464546454655464546414040
5051505145465051505150516061606140417088616061618840418a89898841404140414041404342438740414056414041414041415051414041414040414140414140414041415696979697404141414140414141414041414041414140414041414141404141414041404141404140414041454645464556454641404141
4050515051505150515051606160614041706198606161719841414140569840414040404141404087414041404141404140414040414150514141404141414041404141414140414041404141404140414041404140414140414140414141414141404141414041414140414140414041414041414140454640414140414040
646252525263646564658c6488656465656465646564656465625252525263645c646465645d5c5c5d645d5d5d4b5c4b646464656564646564646564656464656465666564656465676564656465646564656465648864656465646464648c6564886465646564656465646564889a6560505160435d5d42605051609f8d8d9e
745467586744747574758c7488757475625252526362525263540000000044745d747574755d5c5d5d645d5d645c4b5d656252525252525252525252525263647475765252525263775252525263747574759b89898b749f8d8d8d8d8d8d8f757488749b89899a74749b8989898b887560616061424342436061606158898958
6454775777449f8d8d8d8f648a89899a5400000044540000447253535353736448595a4c595a49625d52525d5252635c64540000000000000000000000004465648083f2f0f2f18083f1f2f1f2446465646588656465648c485a4d594c5a4965648864886465646564656465646588654a4a4a4a5c5c4b4b535353539f8d8d9e
7454808183448c74747574757475728854950000445400004475747575747475494a4a4a4a4a4a54850000850000445d655400000008e0009500000000004464748291f1f2d1f29291f1f1f0f2447475747588759f8d8d8f494a5c4a4a4a4a757488748874757475747574757475887566c0c2665cc0c25b53c0c2538cc0c28c
6454908293448c646465649b8989898b5400f1004472535373625252525252634859595a4c59495400000085000044646454000000d28d8d8d8d9d0000004465649291f0f1f0f29192f0d1f2f0446465646588648c485a4c595a5b595a4c4965648a898b646564656465646564658a9a76d0d2764bd0d25d53d0d2538cd0d28c
7454675867448c898989898b9474757454000000446675746754000000000044494a4a4a4a4a4a725353535c53537375655400000008c0000000000000006764749093f2f0f2f19093f2f0f2f14474759f8d8d8d8f494a4b4a4a5c4a4a4a4a757475887574757475747574757475748867d0d2675dd0d26766d0d2669cd0d29c
6454778477898c6464646665646465647253535373926564847253535353537348595a594d5a4948595a5a5b4d59496464540000000000000000000000008465646566535353537367535353537364658c485a4d5a5a595b4c5a5b5a595a49659b898b6564656465646564656465648861505160435051427050517161505160
7472535353739c74757476757474757475747574757675747774757475747574494a4a4a4a4a4a4a4a4a4a5c4a4a4a7474725353535353575353535353537774747576757475747577757475747574759c494a5c4a4a4a5c4a4a4b4a4a4a4a75987574757475747574757475747574989b8989899a6252525263555353535500
4041404140414041404140414041404140414055404140414041404140414041414140414041404140864342438640416061616160616061606160616061404160616061969760616061969760616061408642434342434243424343424387415560614546454645464546454660615588705771885470577166567057715600
4140414041454640414041404140414041404156414041404140414041404140404141709771414041424370977141406160616061606150516061606160614061606160616061606160616061606160414342434243438643428687434286405655606145464546454645466061555688e7e8e98866e7e8e98455e7e8e95500
4041404140414546404140414041404140414055706061969760616061714041414140414041404140418742864140416061606160615051505160616061404160616061606160616061606160616061408743434243877071434242438740414156556061454645464546606155564088e7e8e98884e7e8e97656e7e8e95600
4040414041404145464041404140414040404156414041404140414041404140404141404140417097714140874041406160616061606150516061606140414061606160616061969760616061606160418640874342434387874342864141404041565560616061606160615556404188e7e8e98876e7e8e98455e7e8e95500
4041404140414041404140414041404140414055404140414041404140414041414140414041404140414041404140416061606160616061606160614041404160616061606160616061969760616061404041408641874342864143414140414140415641404140414041405640414098f7f8f99853f7f8f97656f7f8f95600
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041969496414145944641418694874100
0a0000000000000000000000000000000a0000000000000000000000000000000a0000000000000000000000000000000a0000000000000000000000000000000a0000000000000000000000000000000a0000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0104000024752187320c72200112003020030000200000000000000000000000000000000000003c0003c0001d000120000f000120000f0000000000000000000000000000000000000000000000000000000000
010400080d172011260d172011260d172011260d17201126000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002191011560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c61100615006000060000600006000060000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003003024021180150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00000c820008001a8200080018820008001c82023844188200080011820008001d820008001a820008001c820008001f820008001c8200080023820188441f820008001c820008001d820008002182000800
010f000005040050450000000000000000000009040090450c0400c04500000000000504005045040400404507040070450000000000000000000000000000000e0400e045070400704507040070450504005045
010f00001d820008001f8200080021820008001d8201d8441f8200080023820008001f82000800238200080021820008002382000800248200080028820268441c82000800268200080024820002000020000200
010f00000c0400c04500000000000000000000100401004513040130450c0400c0450c0400c0450b0400b0450904009045000000000000000000000c0400c0450000000000090400904509040090450000000000
010f00000d77318000226151960319622196130d773000000d77300000000000000019622196130d773000000d77300000226150000019622196130d773000000d77300000000002260519622196130d77322615
010f00200d773180002260519603196221961316615000000d773000000000000000196221961316615000000d773000002261500000196221961316615000000d77300000000002260519622196131661522600
010f00000f9100f9330d9510f9231b9101b933199511b923279102793325951279233391033933319512794333944000000000000000339340000033903000003392400000000000000033914000000000000000
010f000005000050050000000000000000000009000090050c0000c00500000000000500005005040000400507000070050000000000000000000000000000000e0400e045070000704007045070050504005045
013c0000131551515518155181151215513155171551711513155151551815518115121551315517155171151315515155181551811517155181551c1551c1151b1551c1551f1551f1151c1551b1551e1551e115
013c00000b7520b7410b7310b7120c7520c7410c7310c7120b7520b7410b7310b7120c7520c7410c7310c7120f7520f7410f7310f7120b7520b7410b7310b7121275212741127311271213752137411373113712
0110000000610006530c6710c6510c6410c6310062100615000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d0020107321073512732127351c7321c7321c7321c7351e7321e7321e7321e7321e7321e7321e7321e7321e7321e7321e7321e7321e7321e7351c7321c7321c7321c7321c7321c73517732177321773217735
010d00200477300000047750000000770000000477500000107730000010773000001077500000047750000004773000000477500000047750000004775000001077300000107750000004773000000677500000
010d002019c4419c3019c2019c1000c0000c0000c0019c0025c2000c0019c2000c000dc2000c0019c2019c0017c2000c0000c0000c0000c0000c0000c0000c0025c2000c0019c2000c0008c2000c0015c2000c00
010d002017c2017c003bc013bc0100c0000c0000c0000c0023c2000c0019c2000c000dc2000c001bc2000c0010c2000c0000c0000c0000c0000c0000c0000c0034c2000c0028c2000c001cc2000c0028c2000c00
011000201193718a232690410a361f9172ba130c9041a91610a311d91624a430ea041ca17299160ca331a90429a37139031aa342890311a14219162494315a141892724a360ea031ca14299270ca031a93428a16
0109000023014210211f0311d0411c0511a0611807110b710eb510cb1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d0020127321273217732177321e7321e7321e7321e73223732237322373223732237322373223732237322373223732237322373223732237321e7321e7321e7321e7321e7321e7321c7321c7321c7321c732
010d00200677300000067750000000770000000677500000127730000012773000001277500000067750000006773000000677500000067750000006775000001277300000127750000006773000000677500000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000cb2213b25006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000007b2200b25000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000000b110cb2118b3124b4130b513cb611867500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000067135233292231d21311b150c4020c4020c402004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000010751177710c7610cb4100b10000000000000000000000000000b1000000000000000000000000000000000000000000000000b100000000000000000000000000000000000000000000000000000000
0103000000b11124510544004430024200cb100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000c9322bb652490014974199520e93200b2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000ca52191651ba721a17510a721517500a1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000004141341228b25184021840236b1729422284121a4120cb153c4023c3000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000c2160e21210216112221322615222172360c23217236152421324611242102360e2320c2360e2221022611222132160c2120cb160cb1200200002000030000000000000000000000000000000000000
01060000189121a9221c9321d9421f95221962239722495223942219321f9221c9120000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00000c053000000c0530000030b700000000000000000c073000000c0530000030b7030b6030b40000000c053000000c0530000030b700000000000000000c053000000c0530cb7230b7230b6230b4000000
010f0000233551c3551a3550030500305003051a3550030500305003051a3551735500305003051535500305213551a3551735500305003050030517355003050030500305173551535518305183051235500305
010f000028355213551e3550030500305003051e3550030500305003051e3551c35500305003051a35500305263551e3551c3550030500305003051c3550030500305003051c3551a35500305003051735500305
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000115111352115541135211151110511115211354111521105110c5110e521105410e5210c5112ab110f7110c0150000000000000000000000000000000000000000000000000000000000000000000000
010800000c5110e521105410e5210c5111051111521135411152110511115111352115541135211151112b3113711230150000000000000000000000000000000000000000000000000000000000000000000000
011000000f0500f0300f0200f01509050090400903009015120621205212042120321203212022120221201500000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00000c053000000c0030000030b700000000000000000c003000000c0530000030b7030b6030b40000000c053000000c0030000030b700000000000000000c003000000c0530cb7230b7230b6230b4000000
010f00000b3200000000000003000b3200000000000003000b3200000000000003000b3200000000000003000e3200000000000003000e3200000000000003000e3200000000000003000e320000000030000300
010f00001232000000000000030012320000000000000300123200000000000003001232000000000000030010320000000000000300103200000000000003001032000000000000030010320003000000000000
010f0000173551c3051a3050030500305003050e3550030500305003050e3551730500305003051530500305153551a305173050030500305003050b3550030500305003050b3551530518305183051230500305
010f00001c355213051e30500305003050030512355003050030500305123551c30500305003051a305003051a3551e3051c30500305003050030510355003050030500305103551a30500305003051730500305
011e00001056410551105411055110561105511054110555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e0000100000b5640b5510b5410b5510b5610b5510b545000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e000000000000001c5641c5511c5411c5511c5611c551300712401724015000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000302003020010200102003020030200102001020030200302003020030200302003020030200302003020030200302003020030200302003020030200300033015030000300033003030053301503005
01060000181401d1401f14024140181301d1301f13024130181201d1201f12024120181101d1101f1102411000100001000010000100001000010000100001000010000100001000010000100001000010000100
__music__
01 0f 0e 0d 44
01 08 09 0c 44
02 0a 0b 0c 44
00 41 09 0d 44
02 41 0b 0d 44
03 10 11 43 44
00 41 42 43 44
00 41 42 43 44
01 41 15 43 44
01 14 15 16 44
00 1c 15 17 44
00 14 15 16 44
00 1c 15 17 44
00 14 15 16 44
00 1c 15 17 44
00 14 15 43 44
00 1c 15 43 44
00 14 15 43 44
00 1c 15 43 44
00 41 15 43 44
02 41 15 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 2f 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 41 34 33 44
00 41 35 33 44
00 41 34 33 44
00 41 35 33 44
00 2c 34 2b 44
00 2d 35 2b 44
00 2c 34 2b 44
00 2d 35 2b 44
00 2c 42 33 44
00 2d 42 33 44
00 36 42 33 44
02 37 42 33 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
04 38 39 3a 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
