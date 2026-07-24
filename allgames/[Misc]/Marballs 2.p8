pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
-- marballs 2
-- by lucatron
-- 1.11

--game state
g = {
 scene = 0
}

--title scene
title = {
 t = 0,
 a = 0,
 sm=false,--if show menu
 my=129,--menu items y
 sx=0,--x offset of screen elements
 screen=0,--title or lvl screen
 ms=0,--menu selection
 ls=0,--lvl selection
 egg="________",
 code="rlrldduu",
 es={},--map gfx edges
}

--level scene
lvl = {
 sby=0--scoreboard y
}

--raw lvl information
--[1..4]   lvl dimensions
--[5..7]   player spawn
--[8..11]  goal dimensions
--[12..13] gold,ace times
--[14]     lvl name
--[15]     lvl creator name
--[16]     song id
--[17]     id (savedata index)
lvlsr = {
 {88,0,16,24,14,22,4,1,21,2,2,155,125,"simple","luca",1,0},
 {0,0,24,24,22,22,0,11,21,2,3,315,225,"climb","luca",4,1},
 {104,12,13,12,7.5,1.5,4,10,0,3,3,135,118,"orbs","luca",2,2},
 {104,0,24,12,16.5,1.5,0,3,9,3,3,270,220,"tetrominoes","luca",5,3},
 {72,0,16,24,4.5,11.5,0,11,11,1,1,260,225,"eight","luca",3,4},
 {117,12,11,12,9.5,10.5,0,9,0,2,3,135,106,"boost","luca",1,5},
 {24,0,24,24,12,4,3,11,3,2,2,210,180,"trampoline","luca",6,6},
 {48,0,24,24,1,10,0,10,0,2,2,495,409,"snake","luca",7,7}
}
lvlsn={"x","y","w","h",
 "sx","sy","sz",
 "gx","gy","gw","gh",
 "gt","at",
 "title","creator","song","id"}
--load raw lvl info into
-- an indexable table
lvls = {}--lvl information
for i=1,#lvlsr do
 lvls[i] = {}
 local l = lvls[i]
 for j=1,#lvlsn do
  l[lvlsn[j]] = lvlsr[i][j]
  l["bt"] = 0x7fff
  l["beat"] = false
 end
end

--player
p = {
 vmax=0.32,--max velocity
 r=0.25, --ball radius
 jv = 0.34, --jump velocity
 cb=11,co=3,--ball/outline colors,
 flp=true,flpt=0--flipped controls
}

egg = {
 cx=4.2,cy=0.5,cz=8.3,ca=0.84,
 res=1,
 hud=true
}

--music manager
mus = {
 playing = false,
 pauset = 0,
 --song start points
 songs = {3,41,27,19,12,34,14},
 ptn = 0, --current patern num
 prevnote = -1
}

--win screen
win = {
 t = 0
}

--falgs and constants
debug = false
skip_title = false
first_lvl = 1
tw = 24
th = tw/2
g.scene = 0


--general purpose functions
function sleep(n)
 --halt for n frames
 for i=1,n do flip() end
end

function round(x,n)
 --round x to n decimal places
 --return as zero-padded string
 local s=""..x

 for i=1,#s do
  --find the decimal point
  if sub(s,i,i)=="." then
   if #s-i<n then
    --missing zeros
    return s..sub("00000",0,n-(#s-i))
   end
   return sub(s,0,i+2)
  end
 end

 --x is a whole number
 return s..sub(".00000",0,n+1)
end

function tan(x)
 return sin(x)/cos(x)
end

function bold(s,x,y,cs,cb)
 --print bordered string
 for i=-1,1 do
  for j=-1,1 do
   print(s,x+i,y+j,cb)
  end
 end
 print(s,x,y,cs)
end

function center(s,y,c)
 --print horizontally centered string
 print(s,64-#s*2,y,c)
end

function boldc(s,y,cs,cb)
 --centered and bold
 bold(s,64-#s*2,y,cs,cb)
end

function totime(t,justsecs)
 --convert x in frames to m:s:ms
 --specify justsecs to omit minutes
 if justsecs == nil then
  return flr(t/1800)..":"..round(t/30%60,2)
 else
  return round(t/30%60,2)
 end
end


--gfx things
--8x8 bayer matrix
beyer = {
 { 0, 32, 8,  40, 2,  34, 10, 42},
 {48, 16, 56, 24, 50, 18, 58, 26},
 {12, 44, 4,  36, 14, 46, 6,  38},
 {60, 28, 52, 20, 62, 30, 54, 22},
 { 3, 35, 11, 43, 1,  33, 9,  41},
 {51, 19, 59, 27, 49, 17, 57, 25},
 {15, 47, 7,  39, 13, 45, 5,  37},
 {63, 31, 55, 23, 61, 29, 53, 21}
}
for i=1,8 do
 local i0 = i-1
 beyer[i0] = beyer[i]
 for j=1,8 do
  beyer[i0][j-1] = beyer[i0][j]/65
 end
end

--bithered fade out for n frames
function fade_out(n)
 n = n or 16
 n -= 1
 for i=0,n do
  local int=i/n
  for x=0,127 do
   for y=0,127 do
    local b=beyer[x%8][y%8]
    local di = int+(b-0.5)
    if (di>0.5) pset(x,y,0)
   end
  end
  flip()
 end
 cls()
end

--bithered fade into draw()
function fade_in(n)
 sleep(1) --fixes a weird rendering bug
 n = n or 24
 local len=flr(192/n)
 cls()
 for y=-32,160,len do
  draw()
  rectfill(0,y+32,127,128,0)
  for y2=y,y+31 do
   local int=(y2-y)/32
   for x2=0,127 do
    local b=beyer[x2%8][y2%8]
    local di = int+(b-0.5)
    if (di>0.5) pset(x2,y2,0)
   end
  end
  flip()
 end
end

--snes style pixel fades
function p_fade_out()
 local pw=2 --pixel width
 while pw < 128 do
  for x=0,127,pw do
   for y=0,127,pw do
    rectfill(x,y,x+pw-1,y+pw-1,pget(x+rnd(pw),y+rnd(pw)))
   end
  end
  flip()
  pw *= 2
 end
end

function p_fade_in()
 local pw=128
 while pw > 1 do
  cls()
  draw()
  for x=0,127,pw do
   for y=0,127,pw do
    rectfill(x,y,x+pw-1,y+pw-1,pget(x+rnd(1)*pw,y+rnd(1)*pw))
   end
  end
  pw = flr(pw/2)
  flip()
 end
end

--precalc title graphics
for i=8,14 do--from bottom to top
 for y=0,23 do
  for x=0,23 do
   if mget(x,y)==i then
    local h=mget(x,y)-8
    if (mget(x,y) != mget(x-1,y)) add(title.es,{x,y,x,y+1,h})
    if (mget(x,y) != mget(x+1,y)) add(title.es,{x+1,y,x+1,y+1,h})
    if (mget(x,y) != mget(x,y-1)) add(title.es,{x,y,x+1,y,h})
    if (mget(x,y) != mget(x,y+1)) add(title.es,{x,y+1,x+1,y+1,h})
   end
  end
 end
end


--music manager
function mus.update()
 --determine when next pattern
 --has started. slowest sfx
 --must be playing on channel 1
 if (not mus.playing) return

 local note = stat(21)
 if note < mus.prevnote then
  --check if looping pattern
  if peek(0x3101+mus.ptn*4) >= 128 then
   --find start
   for i=0,63 do
    if peek(0x3100+mus.ptn*4) >= 128 then
     break
    end
    mus.ptn -= 1
   end
  else
   --not looping
   mus.ptn += 1
  end
 end
 mus.prevnote = note
end

function mus.play(song, fade)
 mus.ptn = mus.songs[song]
 mus.resume(fade)
end

function mus.stop(fade)
 music(-1, fade)
 mus.playing = false
end

function mus.pause()
 music(-1)
 mus.playing = false
end

function mus.resume(fade)
 fade = fade or 0
 mus.prevnote = -1
 music(mus.ptn, fade)
 mus.playing = true
end

--draw tile screen
function draw_title()
 local rx = title.sx --render offset/camera pos
 local t = title.t

 --custom lvl screen
 if rx < -2 then
  camera(140+rx,0)
  boldc("want to make your own levels?",30,11,3)
  boldc("get the marballs_2_custom cart!",38,11,3)
  
  boldc("share your creation or play",60,8,2)
  boldc("others made the community.",68,8,2)
  
  boldc("selected custom levels will",90,12,1)
  boldc("be added to the official cart!",98,12,1)
  camera()
 end

 --main screen
 if rx > -125 and rx < 125 then
  local a = title.a
  local k=3.6--3.5
  local per = 1/(2+1*sin(a/3)^2)--map perspective
  local r = k*12*sqrt(2)--map width
  local x0 = 64+sin(a)*r-rx--map centre
  local y0 = 84+cos(a)*r*per

  --move map from bottom
  y0 += 80/(1+max(0,t-20)*0.025)

  --perspective transformation
  local da=0.375
  local sxx = cos(a-da)*k
  local sxy = sin(a-da)*k
  local syx = cos(a+da)*k*per
  local syy = sin(a+da)*k*per
  local dh=5*sin(a/4)^2

  --neon map thing!
  --using list of precalced edges title.es
  for e in all(title.es) do
   local x1,y1,x2,y2,h=e[1],e[2],e[3],e[4],e[5]

   local x3=x0+sxx*x1+sxy*y1
   local y3=y0+syx*x1+syy*y1
   local x4=x0+sxx*x2+sxy*y2
   local y4=y0+syx*x2+syy*y2
   line(x3,y3-dh*h,x4,y4-dh*h,h+8)
  end

  --neon logo
  for i=1,5 do palt(i,true) end
  sspr(0,48,80,15,24-rx,10)
  pal()

  --menu items
  local c=13
  if (title.ms == -1) c=7
  bold("custom",4-rx,title.my,0,c)
  c=13
  if (title.ms == 0) c=7
  bold("play",60-rx,title.my,0,c)
  c=13
  if (title.ms == 1) c=7
  bold("levels",103-rx,title.my,0,c)
 end

 --level screen
 if rx > 18 then
  local rx2 = rx-144
  local unlocked = lvls[title.ls+1].beat
  if (debug) unlocked = true

  --boxes
  rect(2-rx2,8,71-rx2,120,7)
  rect(74-rx2,8,124-rx2,58,7)
  rect(74-rx2,61,124-rx2,120,7)

  --level names
  for i=1,#lvls do
   local s
   local c
   local sel = (title.ls+1==i)

   print(i.." - ",6-rx2,4+i*8,6)

   if lvls[i].beat then
    --beaten
    s = lvls[i].title --title
    c = 13
    if (sel) c=7
   elseif i==1 or lvls[i-1].beat then
    --not beaten but can play
    s = lvls[i].title
    c = 3
    if (sel) c=11
   else
    --locked
    s = "???"
    c = 1
    if (sel) c=5
   end

   print(s,22-rx2,4+i*8,c)
  end

  if unlocked then
   --level unlocked

   --level preview
   --get level info
   local mx = lvls[title.ls+1].x
   local my = lvls[title.ls+1].y
   local mw = lvls[title.ls+1].w
   local mh = lvls[title.ls+1].h
   local gx = lvls[title.ls+1].gx
   local gy = lvls[title.ls+1].gy
   local gw = lvls[title.ls+1].gw
   local gh = lvls[title.ls+1].gh
   local a = title.t*0.003
   local dx = max(0,(mw-50)*0.7)*cos(a)
   local dy = max(0,(mh-50)*0.7)*cos(a)

   clip(75-rx2,9,49,49)
   for y=7,65 do--redundancy on bottom
    for x=75,123 do
     --preoject into map
     local x2=mw/2+(x-99)/2+(y-34)/2+dx
     local y2=mh/2-(x-99)/2+(y-34)/2+dy

     --if on map then draw
     if x2>=0 and x2<mw and
        y2>=0 and y2<mh then
      local tile = mget(mx+x2,my+y2)
      local h = tile%16-8
      if h >= 0 then
       if x2>=gx and x2<gx+gw and
          y2>=gy and y2<gy+gh then
        color(6+(x+y)%2)
       else
        color(h+8)
       end
       pset(x-rx2,y-h)
       line(x-rx2,y-h+1,x-rx2,y+1,1)
      end
     end
    end
   end
   clip()

   --scores
   local c
   local best = lvls[title.ls+1].bt
   if best <= lvls[title.ls+1].at then
    c = 12
   elseif best <= lvls[title.ls+1].gt then
    c = 10
   else
    c = 7
   end
   print("best time",78-rx2,65,6)
   print(totime(best),78-rx2,71,c)
   print("skill times",78-rx2,80,6)
   print("gold: "..totime(lvls[title.ls+1].gt,false),78-rx2,86,10)
   print("aced: "..totime(lvls[title.ls+1].at,false),78-rx2,92,12)
   --lvl creator
   print("created by\n"..lvls[title.ls+1].creator,78-rx2,106,13)
  else
   --level locked
   sspr(96,48,8,11,87-rx2,17,24,33)
  end
 end
end

function update_title()
 --pause on boot
 if title.t==0 then
  cls()
  music(8,5000)
  sleep(15)
 end

 --easter egg
 local chr="?"
 if (btnp(0)) chr="l"
 if (btnp(1)) chr="r"
 if (btnp(2)) chr="u"
 if (btnp(3)) chr="d"
 if chr != "?" then
  title.egg = chr..sub(title.egg,1,7)
  if title.egg == title.code then
   music(26)
   cls()
   sleep(10)
   g.scene = -1
   return
  end
 end

 --update logo animation
 --update state of a pixel
 local function check(x,y)
  if x>=0 and x<80 and
     y>=48 and y<=62 then
   if sget(x,y)==1 then
    --drawable, set temp mark
    sset(x,y,3)
   elseif sget(x,y)==2 then
    --guide, disable and check neighbours
    sset(x,y,5)
    check(x-1,y)
    check(x+1,y)
    check(x,y-1)
    check(x,y+1)
   end
  end
 end
 --find new pixels and set to
 --a temp value (two phase update)
 for x=0,79 do
  for y=48,62 do
   if sget(x,y) == 4 then
    sset(x,y,sget(x,63))
    check(x-1,y)
    check(x+1,y)
    check(x,y-1)
    check(x,y+1)
   end
  end
 end
 --set temp pixels to true val
 for x=0,79 do
  for y=48,62 do
   if sget(x,y) == 3 then
    sset(x,y,4)
   end
  end
 end


 if title.screen == -1 then
  --custom
  title.sx += (-139.5-title.sx)*0.08

  if btnp(1) or btnp(5) then
   title.screen = 0
  end
 elseif title.screen == 0 then
  --main screen
  title.sx += (0-title.sx)*0.07

  --menu stuff
  if title.sm then
   title.my += (120-title.my)*0.1

   if (btnp(0)) title.ms -= 1
   if (btnp(1)) title.ms += 1

   if btnp(4) or abs(title.ms) > 1 then
    if title.ms == 0 then
     --goto game
     --load first unfinished level
     local lvln = 1
     for i=1,#lvls do
      if not lvls[i].beat then
       lvln = i
       break
      end
     end
     goto_game(lvln)
     return
    elseif title.ms >= 1 then
     --goto level screen
     title.ms = 1
     title.screen = 1
    elseif title.ms <= -1 then
     --goto custom
     title.ms = -1
     title.screen = -1
    end
   end
  elseif btn(4) or btn(5) or title.t > 220 then
   title.sm = true
  end
 elseif title.screen == 1 then
  --level screen
  title.sx += (144-title.sx)*0.08

  --go back
  if btnp(0) or btnp(5) then
   title.screen = 0
  end

  --go to lvl
  if btnp(4) and
     (lvls[title.ls+1].beat or
      title.ls==0 or
      lvls[title.ls].beat) then
   goto_game(title.ls + 1)
   return
  end

  if (btnp(2)) title.ls -= 1
  if (btnp(3)) title.ls += 1
  title.ls = mid(0,title.ls,#lvls-1)
 end

 title.t += 1
 title.a += 0.004
end


--set player to spawn
function pspawn()
 p.x = lvl.sx
 p.y = lvl.sy
 p.z = lvl.sz
 p.vx = 0
 p.vy = 0
 p.vz = 0
 p.v1 = {x=1,y=0,z=0}
 p.v2 = {x=0,y=1,z=0}
 lvl.t = 0
 lvl.pause = false
 lvl.win = false
 lvl.ded = false
 lvl.orbn = 0
 for orb in all(lvl.orbs) do
  orb.got = false
  orb.gott = 0
 end
end

--restart level
function restart()
 p_fade_out()
 pspawn()
 p_fade_in()
end

--load level tiles
function load_lvl(n)
 --get lvl info
 for k,v in pairs(lvls[n]) do
  lvl[k] = v
 end
 lvl.n = n
 lvl.orbs = {} --table of orb tiles

 --load tiles
 lvl.tiles = {}
 --load in order of camera depth
 --and then in order of height
 for d=0,max(lvl.w,lvl.h)*2 do
  for th=0,7 do
   for x=0,d do
    local y = d-x
    local x2=x+lvl.x
    local y2=y+lvl.y

    if x < lvl.w and
       y < lvl.h then
     local h = mget(x2,y2)%16-8
     if (h < 0) h = -32

     if h == th then
      local tile = {x=x,y=y,h=h,d=d,t=flr(mget(x2,y2)/16)}

      --is a goal tile
      if x>=lvl.gx and x<lvl.gx+lvl.gw and
         y>=lvl.gy and y<lvl.gy+lvl.gh then
       tile.t=8
      end

      --is an orb tile
      if tile.t == 2 or
         tile.t == 3 then
       tile.ox = tile.x
       tile.oy = tile.y
       if tile.t == 3 then
        tile.ox -= 0.5
        tile.oy -= 0.5
        tile.t = 2
       end

       add(lvl.orbs,tile)
      end

      --set height of visble edges
      tile.rl=h+1 --left
      tile.rr=h+1 --right
      --get occlusion info
      local adj={{0,1,0},{1,0,0},{1,1,2}} --adjacent tile info
      for i=0,8 do
       for n=1,#adj do
        local x2,y2=tile.x+i+adj[n][1],tile.y+i+adj[n][2]
        if x2<lvl.w and y2<lvl.h and
           gth(x2,y2)>=0 then
         local dh=tile.h-gth(x2,y2)+i*2+adj[n][3]
         if (adj[n][2]==1) tile.rl=max(0,min(dh,tile.rl))
         if (adj[n][1]==1) tile.rr=max(0,min(dh,tile.rr))
        end
       end
      end
      --set height of renderable stuff
      tile.rh=max(tile.rr,tile.rl)*6

      add(lvl.tiles,tile)
     end
    end
   end
  end
 end

 --reset player
 pspawn()

 --init goal particles
 lvl.gps = {}
 for i=1,25 do
  local p={x=rnd(1),y=rnd(1),z=0,c=flr(6+rnd(2))}
  add(lvl.gps,p)
 end

 --music!
 mus.play(lvl.song,1000)
end

--isometric transformaion
function iso(x,y)
 return (x-y)/2,(x+y)/4
end

--get darker/lighter color
dark = {
   1,1,1,
 5,1,5,5,
 2,4,4,3,
 1,1,2,5
}
dark[0]=0
light = {
   13,8,11,
 9,6,7,7,
 7,7,7,7,
 7,7,7,7
}
light[0] = 1

function draw_ball()
 --get coordinates
 local bx = 64
 local by = 56
 if lvl.ded then
  bx += (p.x-p.dx-(p.y-p.dy))*tw
  by += (p.x-p.dx+(p.y-p.dy))*th-(p.z-p.dz)*6
 end

 --ball
 pal()
 pal(1,p.cb)
 pal(2,p.co)
 sspr(48,0,10,10,bx-5,by-5)
 pal()

 --dots
 local function rot(v,a,b)
  --rotate vec v by angle a on x-axis
  --and angle b on y-axis
  local v2={
   x=cos(b)*v.x+sin(a)*sin(b)*v.y+cos(a)*sin(b)*v.z,
   y=cos(a)*v.y-sin(a)*v.z,
   z=-sin(b)*v.x+sin(a)*cos(b)*v.y+cos(a)*cos(b)*v.z
  }
  local mag=sqrt(v2.x^2+v2.y^2+v2.z^2)
  v.x=v2.x/mag
  v.y=v2.y/mag
  v.z=v2.z/mag
 end

 if not lvl.pause then
  local k=0.32
  local a1=-p.vx*k
  local a2=p.vy*k
  rot(p.v1,a2,a1)
  rot(p.v2,a2,a1)
 end

 --draw the dots
 if lvl.win then
  color(8+lvl.t/3%5)
 else
  color(p.co)
 end

 for x=-1,1,2 do
  for y=-1,1,2 do
   local x2=x*p.v1.x+y*p.v2.x
   local y2=x*p.v1.y+y*p.v2.y
   local z2=x*p.v1.z+y*p.v2.z

   local r=1.5
   local rx=(x2-y2)*r+bx
   local ry=((x2+y2)/2-z2)*r+by
   local rad=(2.3+x2+y2)*0.15

   rectfill(rx-rad,ry-rad,rx+rad,ry+rad)
  end
 end
end


function all_orbs()
 return lvl.orbn == #lvl.orbs
end

function orb(x,y,c,gott)
 --draw an orb
 x += 12
 if (gott > 30) return

 local r=12/(1+gott*0.1)
 local c1,c2=7,15
 local t=lvl.t+(1+gott*0.2)^2

 local function circ2(x,y,r)
  pal(1,dark[c])
  local t=gott/15
  local k=t/(1+t)
  sspr(56,16,8,8,x-3+4*k,y+5+4*k,8-8*k,8-8*k)
  --spr(39,x-3,y+5)
  pal()
  y -= (1+gott*0.5)^2
  circfill(x,y,r,c1)
  circ(x,y,r,c2)
 end

 local a=t*0.045%0.5
 local x2,y2=cos(a),sin(a)
 local rx,ry=x2-y2,(x2+y2)/2
 local r2=r/2.3
 local dx,dy=rx*r2,ry*r2
 local r3 = flr(3.5/(1+gott*0.05))

 circ2(x+dx,y+dy,r3,c1,c2)
 circ2(x-dx,y-dy,r3,c1,c2)
end


--draw transparent black rect
--with white border
function window(x1,y1,x2,y2)
 rectfill(x1,y1,x2,y2,0)
 rect(x1+1,y1+1,x2-1,y2-1,7)
end

function draw_lvl()
 local pdx
 local pdy
 local pz,px,py
 local pr = false --if ball drawn
 local pd = p.x+p.y-1 --player depth

 if lvl.ded then
  px = p.dx
  py = p.dy
  pz = p.dz
 else
  px = p.x
  py = p.y
  pz = p.z
 end

 pdx,pdy = iso(px,py)

 for t in all(lvl.tiles) do
  --draw player if tile is
  --infront of ball
  if not pr and
     ((t.d > pd and pz < t.h) or
     (t.d > pd + 1)) then
   draw_ball()
   pr = true
  end

  --draw tile
  local dx, dy, rx, ry
  dx,dy = iso(t.x,t.y)

  local dh = flr((t.h-pz)*6)
  rx = (dx-0.5-pdx)*tw+64
  ry = flr(dy*tw)-flr(pdy*tw)-dh+60

  --check if on screen
  if rx>-tw and rx<128 and
     ry+t.rh>-th and ry<128 then

   --choose tile type
   if t.t == 0 then --normal
    pal(15,t.h+8)
    sspr(24,8,tw,th,rx,ry)
   elseif t.t == 1 then --boost pad
    for i=12,15 do
     if (i-lvl.t/3)%4 < 2 then
      pal(i,t.h+8)
     else
      pal(i,7)
     end
    end

    sspr(0,8,tw,th,rx,ry)
   elseif t.t == 2 then --orb
    pal(15,t.h+8)
    sspr(24,8,tw,th,rx,ry)

    if t.got then
     t.gott += 1
    end
    --t.oy%1 for type 3 offset
    orb(rx,ry-(t.oy%1)*th,t.h+8,t.gott)
   elseif t.t == 3 then

    sspr(24,20,tw,th,rx,ry)
   elseif t.t == 8 then --goal
    pal(15,7)
    sspr(24,8,tw,th,rx,ry)

    --particles
    if all_orbs() then
     for q in all(lvl.gps) do
      local x2,y2 = iso(q.x-0.5,q.y-0.5)
      y2 = y2*tw - q.z*1.4

      pset(rx+x2*tw+th,ry+y2+tw/4,q.c)
     end
    end
   end
   pal()
   palt()

   --edges
   for i=1,t.rr do --right edge
    sspr(12,20,12,11,rx+12,ry+6*i+1)
   end
   for i=1,t.rl do --left edge
    sspr(0,20,12,11,rx,ry+6*i+1)
   end

   --ball shadow
   if not lvl.ded and not pr and
      ((t.x==flr(p.x) and t.y==flr(p.y)) or
      (t.x==flr(p.x+1) and t.y==flr(p.y)) or
      (t.x==flr(p.x) and t.y==flr(p.y+1))) then
    local shy = 59-flr((t.h-p.z)*tw/4)
    local col = dark[t.h+8]
    --only draw pixels from shadow
    --sprite that are on the tile
    for x=0,7 do
     for y=0,3 do
      if sget(48+x,12+y)!=0 and
         (pget(60+x,shy+y)==t.h+8 or
          --pget(60+x,shy+y)==5 or
          pget(60+x,shy+y)==7) then
       pset(60+x,shy+y,col)
      end
     end
    end
   end
  end
 end

 --draw ball if not done already
 if (not pr) draw_ball()

 --ui displacement from win
 local winfade = 0
 if (lvl.win) winfade = (lvl.sby+64)*0.5

 --timer
 local t = lvl.t
 if (lvl.win) t = lvl.ct
 local tim = totime(t)
 local tx = 127-#tim*4
 tx += winfade
 bold(tim,tx,2,0,7)

 --orb count
 if #lvl.orbs > 0 then
  local ox = 4-winfade
  circfill(ox,4,3,7)
  circ(ox,4,3,15)
  ox += 6
  bold(lvl.orbn.."/"..#lvl.orbs,ox,2,0,7)
 end
 
 --control swap
 boldc("controls swapped",min(10,p.flpt/2)-8,7,0)
 p.flpt = max(0,p.flpt-1)
 
 --scoreboard windows
 if lvl.win then
  local wy=4
  window(20,lvl.sby+wy,107,lvl.sby+wy+27)
  wy += 7
  if lvl.nb then
   center("new best!",lvl.sby+wy-3,11)
   wy += 4
  end
  --clear time
  center("time: "..totime(lvl.ct),lvl.sby+wy,7)
  if (lvl.nb) wy -= 1
  --best time
  center("best: "..totime(lvl.bt),lvl.sby+wy+9,6)

  window(20,110-lvl.sby,107,124-lvl.sby)
  color(6)
  print("Ž next",25,115-lvl.sby)
  print("— restart",64,115-lvl.sby)
 end

 --death message
 if lvl.ded then
  window(20,lvl.sby,107,lvl.sby+19)
  center("Ž/— restart",lvl.sby+8,6)
 end

 --pause menu
 if lvl.pause then
  window(20,lvl.sby,107,lvl.sby+19)
  center("restart?",lvl.sby+4,7)
  center("Ž yes  — no",lvl.sby+11,6)
 end
end

--get tile height at x,y
function gth(x,y)
 if x < 0 or x > lvl.w or
    y < 0 or y > lvl.h or
    mget(lvl.x+x,lvl.y+y)==0 then
  return -32
 else
  return mget(lvl.x+x,lvl.y+y)%16-8
 end
end

--get tile type at x,y
function gtt(x,y)
 if x < 0 or x > lvl.w or
    y < 0 or y > lvl.h then
  return -1
 else
  return flr(mget(lvl.x+x,lvl.y+y)/16)
 end
end

--get player tile
function ptile()
 return gth(p.x,p.y)
end

--update lvl
function update_lvl()
 --music system
 mus.update()

 --goal particles
 for p in all(lvl.gps) do
  p.z += 1

  if rnd(1)<0.2 then
   p.z = 0
   p.x = rnd(1)
   p.y = rnd(1)
   p.c = flr(6+rnd(2))
  end
 end

 --lvl over, scoreboard stuff
 if lvl.win then
  --next lvl
  if btnp(4) then
   if lvl.t > 55 then
    next_lvl()
    return
   elseif lvl.t <= 40 then
    lvl.t += 10
   end
  end

  --restart
  if btnp(5) and lvl.t > 55 then
   restart()
   return
  end

  --scoreboard
  if lvl.t > 35 then
   lvl.sby += (0-lvl.sby)*0.08
  end

  --resume music
  if lvl.t == 50 then
   music(-1)
   mus.resume(1000)
  end

  --center player
  local a=0.07
  local da=0.94
  local h = gth(lvl.gx,lvl.gy)
  p.vx += (lvl.gx+lvl.gw/2-p.x)*a
  p.vx *= da
  p.vy += (lvl.gy+lvl.gh/2-p.y)*a
  p.vy *= da
  p.vz += (h+2-p.z)*a*0.4
  p.vz *= da
  p.x += p.vx
  p.y += p.vy
  p.z += p.vz
  --floor rebound
  if p.z<h then
   p.vz *= -0.5
   p.z = h
  end

  --win screen timer
  lvl.t += 1

  return
 end

 --player is dead
 if lvl.ded then
  --reset
  if btnp(4) or btnp(5) then
   restart()
   return
  end

  --update death camera
  p.dx += p.dvx
  p.dy += p.dvy
  p.dz += p.dvz
  local k = 0.85
  p.dvx *= k
  p.dvy *= k
  p.dvz *= k

  --move player
  p.x += p.vx
  p.y += p.vy
  p.z += p.vz
  p.z = max(-100,p.z)
  p.vz -= 0.035
  p.vx *= 0.9
  p.vy *= 0.9

  --messagebox
  lvl.sby += (96-lvl.sby)*0.09

  return
 end

 --pause
 if lvl.pause then
  lvl.sby += (96-lvl.sby)*0.1
  if btnp(5) then
   lvl.pause = false
   --to discourage abusing pause
   --add a frame of time if resuming
   lvl.t += 1
  elseif btnp(4) then
   restart()
  end
  return
 else
  if btnp(5) then
   lvl.pause = true
   lvl.sby = 124
   return
  end

  lvl.sby += (128-lvl.sby)*0.1
 end

 --player physics
 --determine if on ground
 local des = {{p.r,0},{-p.r,0},{0,p.r},{0,-p.r}}
 local hk = 0.05 --closeness constant
 local eak = 0.09 --edge slip acceleration

 local eog = false --edge on ground
 local ea = {x=0,y=0} --edge slip amount
 --check edges of ball
 for de in all(des) do
  local x,y=p.x+de[1],p.y+de[2]
  if abs(p.z-gth(x,y)) < hk then
   eog = true
  end
  --determine edge slip too
  if p.z-gth(x,y) > hk then
   ea.x += de[1]
   ea.y += de[2]
  end
 end
 --check base of ball
 local bog = abs(p.z-ptile()) < hk --centre on ground

 --overall if on ground
 p.og = eog or bog

 --apply edge slip
 if not bog then
  p.vx += ea.x*eak
  p.vy += ea.y*eak
 end

 --get input direction
 -- 1.1 weird hack to deal with
 -- rounding errors ('iv' is
 -- the diagonal speed used in 1.0)
 local ix,iy = 0,0
 local iv=1/sqrt(2)+1/sqrt(2)
 
 if (btn(0)) ix -= 1
 if (btn(1)) ix += 1
 if (btn(2)) iy -= 1
 if (btn(3)) iy += 1
 --flip for perspective
 if p.flp then
  ix,iy=iy+ix,iy-ix
 end
 --normalize
 if ix!=0 and iy==0 then
  ix=iv*sgn(ix)
 elseif iy!=0 and ix==0 then
  iy=iv*sgn(iy)
 elseif ix!=0 and iy!=0 then
  ix=1*sgn(ix)
  iy=1*sgn(iy)
 end

 --accelerate player
 local a = 0.029
 if (not p.og) a = 0.018

 p.vx += a*ix
 p.vy += a*iy
 if not p.og then
  p.vz -= 0.035 --gravity
 end

 --friction prop to velocity
 local v = sqrt(p.vx^2+p.vy^2)
 local da = (v/p.vmax)^2*a
 if (not p.og) da *= 0.8

 p.vx -= sgn(p.vx)*da*abs(p.vx/v)
 p.vy -= sgn(p.vy)*da*abs(p.vy/v)

 --slow more if low speed
 if v<0.01 then
  p.vx = 0
  p.vy = 0
 elseif v<0.12 then
  p.vx *= 0.83
  p.vy *= 0.83
 end


 --move player
 local n=10
 local nx = p.x
 local ny = p.y
 local nz = p.z
 local rbr = 0.7 --rebound reduction
 local rb=false--if rebound
 v = sqrt(p.vx^2+p.vy^2)

 --move in n steps, checking
 --collision every step
 for t=1,n do
  nx = p.x + p.vx/n
  ny = p.y + p.vy/n
  nz = p.z + p.vz/n

  --x direction
  if flr(p.z) < gth(nx+p.r*sgn(p.vx),ny) then
   if abs(p.vx) > 0.25 then
    sfx(4,0)
   elseif abs(p.vx) > 0.1 then
    sfx(5,0)
   end

   p.vx *= -rbr
  else
   p.x = nx
  end

  --y direction
  local yth = gth(nx,ny+p.r*sgn(p.vy))
  if flr(p.z) < yth then
   if abs(p.vy) > 0.25 then
    sfx(4,0)
   elseif abs(p.vy) > 0.1 then
    sfx(5,0)
   end

   p.vy *= -rbr
  else
   p.y = ny
  end

  --z direction
  local grounded = false
  if nz <= ptile() then
   --centre in/on ground
   grounded = true
   bog = true
  else
   --edge in/on ground
   for de in all(des) do
    if abs(p.z-gth(p.x+de[1],p.y+de[2])) < hk then
     grounded = true
     eog = true
     break
    end
   end
  end

  if p.vz <= 0 and grounded then
   --don't rebound off floor
   --when at speed and moving
   if v >= 0.3 and p.vz > -0.38 and p.vz < 0 and
      (ix != 0 or iy != 0) then
    p.z = flr(p.z)
    p.vz = 0
    sfx(3,0)
   else
    p.vz *= -0.4 --rebund
   end

   --rebound velocity too small
   if p.vz < 0.04 then
    p.vz = 0
    p.z = flr(p.z)
   else
    --rebound sound
    if not rb then
     if p.vz > 0.2 then sfx(4,0)
     elseif p.vz > 0.1 then sfx(1,0)
     else sfx(2,0) end
     rb=true
    end
   end

   --jump player
   if btn(4) and p.vz < p.jv then
    local k=1
    if gtt(p.x,p.y)==1 then
     --jump pad
     k=1.27
     sfx(6,0)
    else
     sfx(0,0)
    end

    p.vz = p.jv*k
   end
  else
   p.z = nz
  end

  --test if on orb
  --0.25 units of leniancy
  local orbd = 0.75
  for orb in all(lvl.orbs) do
   if not orb.got and
      abs(orb.ox+0.5-p.x) < orbd and
      abs(orb.oy+0.5-p.y) < orbd and
      abs(orb.h-p.z) < 1.5 then
    orb.got = true
    lvl.orbn += 1
    if all_orbs() then
     sfx(12,3)
    else
     sfx(11,3)
    end
   end
  end

  --test if on goal
  if p.x>=lvl.gx and p.x<lvl.gx+lvl.gw and
     p.y>=lvl.gy and p.y<lvl.gy+lvl.gh and
     p.z<ptile()+2 then
   if all_orbs() then
    lvl.win = true
    lvl.ct = lvl.t

    --cleared flags
    dset(lvl.id*2,1)
    lvls[lvl.n].beat = true

    if lvl.ct < lvl.bt then
     --new best time
     lvl.bt = lvl.ct
     dset(lvl.id*2+1,lvl.ct)
     lvls[lvl.n].bt=lvl.ct
     lvl.nb=true
    else
     lvl.nb=false
    end

    lvl.t = 0
    lvl.sby = -64

    mus.pause()
    music(26)
    return
   else
    --don't have all the gems
    --todo sfx
   end
  end
 end

 --test if dead
 if p.z <= -0.5 then
  sfx(7,0)
  lvl.ded = true
  lvl.sby = 128
  p.dx = p.x
  p.dy = p.y
  p.dz = p.z
  p.dvx = p.vx
  p.dvy = p.vy
  p.dvz = p.vz
  return
 end

 --timer
 lvl.t += 1
 if (lvl.t<0) lvl.t=0x7fff
end


--goto game at level n
function goto_game(n)
 music(-1,1000)
 g.scene = 1
 fade_out()
 sleep(5)
 load_lvl(n)
 fade_in()
end

--continue to next level
function next_lvl()
 if lvl.n + 1 > #lvls then
  --beat the final level
  goto_winner()
  return
 else
  music(-1,1200)
  fade_out()
  sleep(5)
  load_lvl(lvl.n + 1)
  fade_in()
  return
 end
end

--goto win screen
function goto_winner()
 mus.stop(1000)
 fade_out()
 g.scene = 2
 music(0,3000)
 fade_in(50)
end

--win screen
function draw_winner()
 cls()
 t = win.t

 --wireframe floor
 local function l(x1,y1,x2,y2,k)
  local len=sqrt((x1-x2)^2+(y1-y2)^2)
  local n = len*0.8
  for i=0,n do
   local i2=i/n
   local int = (1-abs(i2-0.5))*k
   local x,y=x1+(x2-x1)*i2,y1+(y2-y1)*i2
   if int+beyer[flr(x)%8][flr(y)%8]>0.98 then
	   pset(x,y,1)
	  end
  end
 end

 cls()
 local a=t*0.003
 local n=2
 local w=20
 local y0=72
 for j=0,1 do
  local a2 = a+j*0.25
	 local dx,dy=cos(a2)*64,sin(a2)*32
	 for i=-n,n do
	  local sx,sy=i*w*sin(a2),-i*w*cos(a2)/2
	  l(64+dx+sx,y0+dy+sy,64-dx+sx,y0-dy+sy,1-abs(i)/n*0.8)
	 end
	end

	--"congrats!"
	local wm=w*3
	local w=flr(abs(cos(a))*wm)
	local h=wm/2
	local s = 1
	if cos(a) > 0 then
	 w = -w
	 s = -1
	end
	for x=-w,w,s do
	 local i=(x+w)/2/w
	 local i2=x/w
	 if abs(i-(t/18%3-0.2))<0.1 then
	  for k,v in pairs(light) do
	   pal(k,v)
	  end
	 end
	 sspr(63.9*i,32,1,16,64+x,y0-h+sin(-a)*i2*wm/2,1,h)
	 pal()
	end

	local function txt(s,y)
	 center(s,y,1)
	 center(s,y+1,13)
	end
	--bottom text
	txt("thanks for playing!",116)
	
	win.t += 1
end


--menu callback
function goto_title()
 if (g.scene==0) return
 g.scene = 0
 music(-1,1000)
 fade_out(15)

 --reset title
 title.t = 0
 title.a = 0
 title.bx=0
 title.my=129
 title.sx=0
 title.screen=0
 title.ms=0
 title.ls=0
 --reset logo
 pal()
 for x=0,79 do
  for y=48,62 do
   local c=sget(x,y)
   if c==5 then
    sset(x,y,2)
   elseif c!=0 and c!=2 then
    sset(x,y,1)
   end
  end
 end
 sset(0,48,4)
 --fade
 fade_in(1)
end

function swap_controls()
 --swap arrow key controls
 p.flp = not p.flp
 p.flpt = 60
end


function update_egg()
 local ix,iy = 0,0
 if (btn(0)) ix -= 1
 if (btn(1)) ix += 1
 if (btn(2)) iy -= 1
 if (btn(3)) iy += 1

 if btn(4) then
  egg.cx += ix/5
  egg.cy += iy/5
 elseif btn(5) then
  egg.cz -= iy/10
  if (btnp(0)) egg.res -= 1
  if (btnp(1)) egg.res += 1
  egg.res = mid(1,egg.res,3)
 else
  egg.ca -= ix/200
  if (btnp(2)) egg.hud = not egg.hud
 end

 --draw it!
 if btn(4) and btn(5) then
  cls()
  --initial properties
  --fov=0.15
  local ry=1/tan(0.15)
  local a=egg.ca-0.25

  for x=0,127,egg.res do
   for y=64,127,egg.res do
    --ray direction
    local rx=(x-64)/64
    local rz=-(y-64)/64
    --get magnitude
    local m = sqrt(rx*rx+ry*ry+rz*rz)

    --rotate in camera direction
    local sx=cos(a)*rx-sin(a)*ry
    local sy=sin(a)*rx+cos(a)*ry
    local sz=rz

    --trace along ray path
    local k=0
    while k<50 do
     local px = egg.cx+sx*k
     local py = egg.cy+sy*k
     local pz = egg.cz+sz*k

     if k > 4 and
        (abs(px-12) > 12 or
        abs(py-12) > 12 or
        pz < -1) then
      break
     end

     local t=mget(px,py)
     local h=t-8
     if pz <= h then
      local col
      if pz+0.1 >= h then
       col=t
      else
       col=1
      end

      rectfill(x,y,x+egg.res-1,y+egg.res-1,col)
      break
     end

     k += 0.05
    end
   end
   
   flip()
  end
 end
end

function draw_egg()
 rectfill(0,0,127,32,0)
 if egg.hud then
  for x=0,23 do for y=0,23 do
   pset(x,y,mget(x,y))
  end end

  pset(egg.cx,egg.cy,7)
  line(egg.cx,egg.cy,egg.cx+16*cos(egg.ca),egg.cy+16*sin(egg.ca),6)
  print("x="..egg.cx,30,0)
  print("y="..egg.cy,65,0)
  print("z="..egg.cz,100,0)
  print("a="..egg.ca,30,8)
  print("res="..egg.res,65,8)
 else
  sspr(64,32,64,16,24,32)
  spr(109,91,32,1,2)
 end
end


--body functions
function _init()
 cls()
 --cartdata
 --each lvl has clear flag and best time
 local loaded
 loaded = cartdata("marballs_2")
 if not loaded then
  --set default values
  for i=0,31 do
   dset(i*2,0)--clear flag
   dset(i*2+1,29970)--best time
  end
 else
  --load saved data
  for lvl in all(lvls) do
   lvl.beat = dget(lvl.id*2)!=0
   lvl.bt = dget(lvl.id*2+1)
  end
 end

 --menuitems
 menuitem(1,"return to menu",goto_title)
 menuitem(2,"switch controls",swap_controls)

 --don't mind me
 if skip_title then
  g.scene=1
  load_lvl(first_lvl)
 end
end

function _update()
 if g.scene == 0 then
  update_title()
 elseif g.scene == 1 then
  update_lvl()
 elseif g.scene == 2 then
  if btnp(4) then
   music(-1,1500)
   fade_out()
   win.t = 0
   goto_title()
  end
 elseif g.scene == -1 then
  update_egg()
 end
end

function draw()
 if g.scene == 0 then
  draw_title()
 elseif g.scene == 1 then
  draw_lvl()
 elseif g.scene == 2 then
  draw_winner()
 elseif g.scene == -1 then
  draw_egg()
 end
end

function _draw()
 if (g.scene != -1) cls()
 draw()

 if debug then
  bold("cpu="..stat(1),0,122,7,1)
  bold("ptn="..mus.ptn,50,122,7,3)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000022220000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000002111120000000008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
000000000000000000000000000000000000000000000000021111112000000008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
000000000111111000000000000000000000000000000000211111111200000008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
0000000001cccc1000000000000000000000000000000000211111111200000008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
000000000111111000000000000000000000000000000000211111111200000008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
000000000000000000000000000000000000000000000000211111111200000008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
00000000000000000000000000000000000000000000000002111111200000000000000000000000000000000000000000000000000000000000000000000000
00000000005555000000000000000000005555000000000000211112000000000000000000000000000000000000000000000000000000000000000000000000
0000000055ffff55000000000000000055ffff5500000000000222200000070008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
00000055ffeeeeff5500000000000055ffffffff55000000000000000000077008777780097777900affffa00b7777b00c7777c00d7777d00e7777e00f7777f0
000055ffeeddddeeff550000000055ffffffffffff550000000000000000007008788780097997900afaafa00b7bb7b00c7cc7c00d7dd7d00e7ee7e00f7ff7f0
0055ffeeddccccddeeff55000055ffffffffffffffff5500001111000000000008788780097997900afaafa00b7bb7b00c7cc7c00d7dd7d00e7ee7e00f7ff7f0
55ffeeddccffffccddeeff5555ffffffffffffffffffff55111111110000000008777780097777900affffa00b7777b00c7777c00d7777d00e7777e00f7777f0
55ffeeddccffffccddeeff5555ffffffffffffffffffff55111111110000000008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
0055ffeeddccccddeeff55000055ffffffffffffffff550000111100000000000000000000000000000000000000000000000000000000000000000000000000
000055ffeeddddeeff550000000055ffffffffffff55000000000000011100000000000000000000000000000000000000000000000000000000000000000000
00000055ffeeeeff5500000000000055ffffffff55000000000000001111100007888870079999700faaaaf007bbbb7007cccc7007dddd7007eeee7007ffff70
0000000055ffff55000000000000000055ffff5500000000000000000111000008788780097997900afaafa00b7bb7b00c7cc7c00d7dd7d00e7ee7e00f7ff7f0
000000000055550000000000000000000055550000000000000000000000000008877880099779900aaffaa00bb77bb00cc77cc00dd77dd00ee77ee00ff77ff0
11000000000000000000001d000000000055550000000000000000000000000008877880099779900aaffaa00bb77bb00cc77cc00dd77dd00ee77ee00ff77ff0
111100000000000000001d1d0000000055ccdd5500000000000000000000000008788780097997900afaafa00b7bb7b00c7cc7c00d7dd7d00e7ee7e00f7ff7f0
1111110000000000001d1d1d00000055ccddeeff55000000000000000000000007888870079999700faaaaf007bbbb7007cccc7007dddd7007eeee7007ffff70
11111111000000001d1d1d1d000055ccddeeffccdd55000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111111100001d1d1d1d1d0055ccddeeffccddeeff550089abbcef000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111d1d1d1d1d1d55ccddeeffccddeeffccdd55244355250ffffff007777880077779900ffffaa007777bb007777cc007777dd007777ee007777ff0
0011111111111d1d1d1d1d0055ddeeffccddeeffccddee55000000000f7777f007777880077779900ffffaa007777bb007777cc007777dd007777ee007777ff0
0000111111111d1d1d1d00000055ffccddeeffccddee5500000000000f7777f007777880077779900ffffaa007777bb007777cc007777dd007777ee007777ff0
0000001111111d1d1d000000000055ddeeffccddee550000000000000f7777f007777880077779900ffffaa007777bb007777cc007777dd007777ee007777ff0
0000000011111d1d0000000000000055ffccddee55000000000000000f7777f008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
0000000000111d00000000000000000055ddee55000000000c7fa0000ffffff008888880099999900aaaaaa00bbbbbb00cccccc00dddddd00eeeeee00ffffff0
00000000000000000000000000000000005555000000000017679000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000110000100000100000155500000000000000100001100000110000000000000
2222220444444405555550033333330111111001111111022222220555550ddd077000d71000675000777777005dddd100006750017600001760000006776500
2888820499999405aaaa5503bbbbb301cccc1101ddddd102eeeee205fff50d6d17750177100077d00077dd7750777777100077d0057600005760000067777600
2822220494449405a555a503b3333301c11cc101d111d10222e22205f5f50d6d577d0d77000d7760017600d750775567500d7760057d000057d0000077005500
2820000494049405a505a503b3000001c101c101d101d10002e20005f5550d6d577607770006767001760167117600d710067670057d000057d0000067750000
2820000494049405a505a503b3000001c101c101d101d10002e20005f5000d6d5777d77700176d75057777760177d67600176d750d7d0000d7d000000d776000
2820000494049405a505a503b3000001c11cc101d111d10002e20005f5550d6d5767767700d7dd7d057777d00577777d00d7dd7d0d750000d750000000067d00
2820000494049405a505a503b3000001cccc1001ddddd10002e20005fff50d6dd7577577006777770d7d5760057d0067106777770d750000d75000057d1d7d00
2820000494049405a505a503b3000001c11cc101d111d10002e2000555f50d6dd756607601776d771d7506760d75006711776d771d777770d777770577777500
2820000494049405a505a503b3000001c101c101d101d10002e2000005f50d6dd75d51760d7d00675d7100770d77777d0d7d00675d777770d777770056765000
2820000494049405a505a503b3033301c101c101d101d10002e2000005f50d6d0000000000510000000000000d76650000510000000000000000000000000000
2820000494049405a505a503b303b301c101c101d101d10002e2000005f50ddd0000000000000000000000000000000000000000000000000000000000000000
2820000494049405a505a503b303b301c101c101d101d10002e2000555f500000000000000000000000000000000000000000000000000000000000000000000
2822220494449405a505a503b333b301c101c101d101d10002e20005f5f50ddd0000000000000000000000000000000000000000000000000000000000000000
2888820499999405a505a503bbbbb301c101c101d101d10002e20005fff50d6d0000000000000000000000000000000000000000000000000000000000000000
2222220444444405550555033333330111011101110111000222000555550ddd0000000000000000000000000000000000000000000000000000000000000000
4111111111100111111122111111000111111000111111100111222211100001111100000000000000000000000000000ddddd00067777000000000000000000
100000000010010000010010000110010000112210000010010100001010000100010000211111200000000000000000dd111dd04aaaaaa00000000000000000
101110111010010111210010110010010112010010111010010100001010000101010002100000120000000000000000dd100dd15ff05ff00000000000000000
101010101010010101010010101010010101010010101010010100001010000101110001000000010000000000000000dd100dd100002ee00000000000000000
1010101010100101010100101010100101012100101010100101000010100001010000010011200100000000000000000110ddd10002ddd00000000000000000
101010101010010111010010112010010110010010111010010100001010000101110001112010010000000000000000000dd111001ccc000000000000000000
101010101010010000010010200120010000120010200010010100001010222100010000000210010000000000000000000dd10003bbb0000000000000000000
101010101010010111010010110010010110010010111010010100001010200111010000002100210000000000000000000011005aaa00000000000000000000
101010101010010101010010101010010101210010101010010100001012200001010000021002100000000000000000000dd000499999900000000000000000
101010101010010101010010101010010101010010101010010100001010000001010000210021000000000000000000000dd100288888800000000000000000
10101010101001010101001010101001010101001010101001010000101000000101000010001000000000000000000000001100000000000000000000000000
10101010101001010101001010101001010101001010101001010000101000011101222100011111000000000000000000000000000000000000000000000000
10101010101001010101001010101001011201001010101001011100101110010101000100000001000000000000000000000000000000000000000000000000
10101010101001010101001010101001000011001010101001000100100010010001000100000001000000000000000000000000000000000000000000000000
11101110111221110111001110111221111110001110111221111100111110011111000111111111000000000000000000000000000000000000000000000000
8888888888800999999900aaaaaaa00bbbbbbb00ccccccc00ddddd00eeeee00fffff000777777777000000000000000000000000000000000000000000000000
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
0c0c0c0c0c0c0c0c08080808080809090909080809090909000000000000000000000000000000000000000000000000000c0c0c0c0c0c0000000e0e0e0e0e0e0e0e0e00000000000b0b0b0b0a0a0a0a0a000000000000000e0e0e0e0e0e0d0d0d0d0c0c0c0c0c0c0d0d0d0d0d0d0d0d0d0b0b0b0b0b0b0808080a0a0a0a0a0a
0c0c0c0c0c0c0c0c08080808080809090909080808080808000000000000000000000000000000000000000000000000000c0c0c0c0c0c0000000e0e0e0e0e0e0e0e0e00000000000b2b0b0b0a0a0a0a0a000000000000000e0e0e0e0e0e0d0d0d0d0c0c0c0c0c0c0d0d0d0d0d0d0d2d0d0b0b0b0b0b0b0808080a2a0a0a0a0a
0c0c0c0c0c0c0c0c08080808080809090909080808080808000000000000000000000b0b0b0b00000000000000000000000c0c00000c0c000000000000000000000e0e00000000000b0b0b0b0a0a0a2a0a000000000000000e0e0e0e0e0e0d0d0d0d0c0c0c0c0c0c0d0d0d0d0d0d0d0d0d0b0b0b0b0b0b0808080a0a0a0a0a0a
0c0c0c0c0c0c0c0c08080808080809090909080808080808000000000000000000000b0b0b0b0b0b0a0a0a0a0a000000000a0a00000c0c000000000000000000000e0e00000000000b0b0b0000000a0a0a0a0a09090909090e0e0e0e0e0e0d0d0d0d0c0c0c0c0c0c0c0c0c0d0d0d0b0b0b0b0b0b0808080808080a0a0a0a0a0a
0b0b0b0b0c0c0c0c08080808000000000000000008080808000000000000000000000b0b0b0b0b0b0a0a0a0a3a000000001a1a00000c0c000000000000000000000e0e00000000000c0c0c0000000a0a0a0a0a09090929090e0e0e0e00000000000000000c0c0c0c0c2c0c0d0d0d0b0b0b0b0b0b0808080808080a0a0a0a0a0a
0b0b0b0b0c0c0c0c08080808000000000000000008080808000000000000000000000b0b0b0b00000000000a0a000000001a1a00000c0c000000000000000e0e0e0e0e00000000000c0c0c0c0c0c0c0a0a0a0a09090909090e0e0e0e00000000000000000c0c0c0c0c0c0c0d0d0d0b0b0b0b0b0b0808080808080a0a0a0a0a0a
0b0b0b0b0c0c0c0c09090909000000000000000000000000000000000000000000000000000000000000000a0a000000000a0a0a000c0c000000000000000e0e0e0e0e00000000000c0c0c0c0c0c0c0000000000000909090e0e0e0e00000000000000000c0c0c0c0c0c0c0c0c0c0c0c0c0a0a0a080808000000000000090909
0b0b0b0b0c0c0c0c09090909000000000000000000000000000000000000000e0e0808080808080e0e00000a0a00000000000a0a0a0a0a0a0a0a0a0000000e0e00000000000000000c0c0c0c0c0c0c0000000000000909090e0e0e0e00000000000000000c0c0c0c0c0c0c0c0c0c0c0c0c0a2a0a082808000000000000090909
0a0a0a0a0c0c0c0c0a0a0a0a000000000000000008080808000000000000000e0e0808080808080e0e00000b0b0000000000000a0a0a0a0a0a0a0a0000000e0e0000000000000000000000000c2c0c0000000000000808080e0e0e0e00000000000000000c0c0c0c0c0c0c0c0c0c0c0c0c0a0a0a080808000000000000090909
0a0a0a0a0c0c0c0c0a0a0a0a000000000000000008080808000000000000000808000008080000080800000b0b00000008080000000c0c00000a0a0000000e0e0000000000000000000000000c0c0c0000000000000808080e0e0e0e0e0e000000000c0c0c0c0c0c0000000a0a0a0a0a0a0a0a0a000000090909090909090909
0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000808080800000b0b0b0b0008080019191919000808000b0b0b0b000008080000000c0c00000a0a0000000e0e0000000000000000080808080808090000090808080808080e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0000000a0a0a0a0a0a0a0a0a000000090909090909090909
0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000808080800000b0b0b0b0008080819191919080808000b0b0b0b000008080000000c0c0c0c0a0a0c0c0c0c0c0c0c0c0c00000000080808080808090000090808080808080e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0000000a0a0a0a0a0a0a0a0a000000090909090909090909
0a0a0a0a0a0a0a0a0a0a0a0a00000000080808080808080800000b0b0b0b0008080819191919080808000b0b0b0b000008080800000c0c0c0c0a0a0c0c0c0c0c0c0c0c0c000000000808080808080900000908080808080800000e0e0e0e0e0e0c0c0c0c0c0c00000c0c0c0c0c0c0c0c0c000c0c0c1e1e1e0000000000000f0f
0a0a0a0a0a0a0a0a0a0a0a0a00000000080808080808080800000b0b0b0b0008080019191919000808000b0b0b0b00000008080800000000000a0a0000000e0e00000c0c000000000808080000000000000c0c0c00000000000000000e0e0e0e0c0c0c0c000000000c2c0c0c0c0c0c0c0c000c0c0c1e1e1e0800080008000f0f
000000000c0c0c0c000000000000000008080808080808080000000b0b000008080000080800000808000000000000000000080800000000000a0a0000000e0e00000c0c000000000808080000000000000c2c0c00000000000000000e0e0e0e0c0c0c0c000000000c0c0c0c0c0c0c0c0c000c0c0c1e1e1e0000000000000f0f
000000000c0c0c0c000000000000000008080808080808080000000b0b00000e0e0808080808080e0e0000000000000000000808000000000a0a0a0000000e0e0e0e0c0c0e0e0e0e0909090000000000000c0c0c0c0c0c0c000000000e0e0e0e0c0c0c0c000000000c0c0c000000000000000c0c0c0000000000000000000000
000000000c0c0c0c000000000000000008080808000000000000000c0c00000e0e0808080808080e0e000000000000000a0a08080a0a0a0a0a0a0a0000000e0e0e0e0c0c0e0e0e0e0909090000000000000c0c0c0c0c0c0c000000000e0e0e0e0c0c0c0c000000000c0c0c00000c0c0c00000c0c0c0000000000000000000000
0c0c0c0c0c0c0c0c000000000000000008080808000000000000000c0c000000000000000000000000000000000000000a0a08080a0a0a0a0a0a00000000000000000c0c00000e0e09090909090a0a0a0a0c0c0c0c0c0c0c0000000e0e0e0e0e0c0c0c0c0c0000000c0c0c000c0c2c0c0c000c0c0c1c1c1c000a0a0a08181818
0c0c0c0c0c0c0c0c000000000000000008080808000000000000000c0c00000000000b0b0b0b000000000000000000000a0a08080808080800000000000000000c0c0c0c00000e0e09290909090a0a0a0a0a0000000c0c0c00000e0e0e0e0e0e0c0c0c0c0c0c00000c0c0c000c0c0c0c0c000c0c0c1c1c1c000a0a0a08181818
0d0d0d0d0c0c0c0c000000000000000008080808000000000000000c0c0c0c0c0b0b0b0b0b0b000000000000000000000a0a0808080808080000000000000c0c0c0c0c0c00000e0e09090909090a0a0a0a0a0000000b0b0b000e0e0e0e0e0e0e0c0c0c0c0c0c0c000c0c0c000c0c000c0c000c0c0c1c1c1c000a0a0a08181818
0d0d0d0d0c0c0c0c000000000000000008080808080808080000000c3c0c0c0c0b0b0b0b0b0b000000000000000000000a0a0000000008080000000000000c0c0c0c000000000e0e000000000000000a2a0a0a0a0b0b0b0b0e0e0e0e0e0e0e00000c0c0c0c0c0c0c0c0c0c0c0c0c000c0c0c0c0c0c0c0c0c000a0a0a00080808
0e0e0e0e0e0e0e0e0e0e0e0e0e0000000808080808080808000000000000000000000b0b0b0b000000000000000000000a0a0000000008080000000000000c0c0000000000000e0e000000000000000a0a0a0a0a0b0b2b0b0e0e0e0e0e0e000000000c0c0c0c0c0c0c0c2c0c0c0c000c0c0c2c0c0c0c0c0c0a1a1a1a00080808
0e0e0e0e0e0e0e0e0e0e0e0e0e00000008080808080808080000000000000000000000000000000000000000000000000a0a0a08181808080000000000000c0c0c1c1c0c0e0e0e0e000000000000000a0a0a0a0a0b0b0b0b0e0e0e0e0e0000000000000c0c0c0c0c000c0c0c0c0000000c0c0c0c000c0c0c0a1a1a1a00080808
0e0e0e0e0e0e0e0e0e0e0e0e0e00000008080808080808080000000000000000000000000000000000000000000000000a0a0a08181808080000000000000c0c0c1c1c0c0e0e0e0e000000000000000000000000000000000e0e0e0e00000000000000000c0c0c0c000000000000000000000000000c0c0c0a1a1a1a00080808
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200000155301543085500a5510c5410e5311152114511175001300013000100000a0000800006000060000400002000010000100003000030000300003000030000200001000020001a000000000000000000
000200000c05304033095150100302003000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000124002030020210200002000066030d600216000e6002060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000a62005540035350130001300013000130002300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000562309043030330100302003000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001342306543025030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000a0430f6330b0230f613093510a3510c3510f341103211131113000100000a0000800006000060000400002000010000100003000030000300003000030000200001000020001a000000000000000000
000a00002a5342853127531265312452122521205211f5211d5111b51119511175051550013500115000e5000a5002e5002d5002c5002b5002a50029500285002850027500265002550024500225002250000500
010a00001845018450134501345010450104501a4501a45015450154501a4501a4501c456154461c4361542612400124001240012400124001240012400124051540015400154001540015400154001540015400
010500000c2200c2200c220132000c2200c2200c220132000c2200c2200c220132050e2200e2200e220152000e2200e2200e220152000e2200e2200e220152050922009220092200922509200092001920019200
011000000c303040030a6050100302003000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106000021020260402a0502d05032040320303202032010320150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001a12021140261502d15032150261403213026120321102611532100261000010700107001070010700107001070010700107001070010700107001070010700107001070010700107001070010700107
011400200952410554175642057409524105541756420574091141013417144201540911410134171442005409024100441705420064090241004417054200640952410554175642057409524105541756420574
011400200921710227172372023709237102371722720217094171042717437204370943710437174272041709417104271743720437094371043717427204170931710327173372033709337103371732720317
01200020243552c3552c315243552c3552c315243552c355223552b3552b315223552b3552b315223552b35525355313553131525355313553131525355313552035530355303152035530355303152035530355
01240000190341a0441c06421064210141c0641c0241c0141a0541a0142106423064230142105421024210141a0341c0442305425064250142106421014250642501421054210142605426014250442103421014
012400000905009041090310902109011090150900009000040500404104031040210401104015090000900007050070410703107021070110701509000090000205002041020310202102011020150900009000
0109002007635006150c6150c604186151f605006150c6141f635306000c6150c604186151f605006150c60407635006150c6150c604186151f605006150c6141f635306000c6150c60407625006051f6350c615
01120020150432b003130031504321043000031f003210431f00321043150431f0032104300003000032104315043000031504300003210430000300003210430000321043150430000321043000032104321043
01200020202171d2571821711257202171d25718217112571f2171b257162170f2571f2171b257162170f25725217222571d2171625725217222571d21716257242171d257192170d257242171d257192170d257
0108001010073000000c615000001f625000001f6250000018373000000c615000001f625000001f6250000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400100902009041090400902109020090410904009021090200904109040090210902009041090400902100004000040000400004000040000400004000040000400004000040000400004000040000400004
012400001b4171e42722437274371b4371e4372243727437194171e4272243725437194371e43722437254371d41722427254372a4371d43722437254372a4371b4172042724437294371b437204372443729437
01240000030240304103040030400304003040030400304006024060410604006040060400604006040060400a0240a0410a0400a0400a0400a0400a0400a0400802408041080400804008040080401404403041
01240000273052730527305003000030025305253052230522305223052230500300003002230525305273052a3052a3052a3052a305003002a3052a305293052930529305293050030000300253552534527355
011200201006309403100630940332635326031c6052863510003286251006310403326350000028615000001006309403100630940332635000001c61532635100031c625100631000332635000002861500000
01240000273552733527325273150030025365253552236522355223352232522315003002236525365273652a3652a3552a3352a3152a3052a3652a355293652935529335293252931500300253652535527365
01240000030240304103140030400304003140030400304006024060410614006040060400614006040060400a0240a0410a1400a0400a0400a1400a0400a0400802408041081400804008040081401404403041
011800002835521305233552435526355283052435523355213550000521355243552835500005263552435523355000050000524355263550000528355000052435500005213550000521355000050000500005
011800000404010040040401004004040100400404010040090401504009040150400904015040090401504008040140400804014040040401004004040100400904015040090401504009040150400b0400c040
010c00200c6150000530615000050c6150000530615000050c6150000530615306150c6150000530615000050c6150000530615000050c6150000530615000050c61500005306150000530615000053061500005
01180000283052635523305293552d3552d3052b35529355283550030521305243552835500305263552435523355003052335524355263550030528355003052435500305213550030521355003050030500305
011800000e04002040040000204004000020400e040020400c040000400900000040090000c040000400c0400b040170400800017040040401004006000100400904015040090401504009040150000b0000c000
011000041007310000106251300013000100000200001000010000100001000010000100002000030000100001000010000100000000000000000000000000000000700007000070000700007000070000700007
0120000004600106001c6002860004604106001c60028600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000760010600106141c62128641
011000200417504135041150417504135041150417504135041150417504135041150417504135041750413504175041350411504175041350411504175041350411504175041350411504175041350217502135
012000201051617526125361a5461054617546125461a5460c51617526135361c5460c54617546135461c5461251617526135361a5461254617546135461a5460c51617526105361f5460c54617546105461f546
01100008100731c0021062524624150731c0021062513000010000100001000010000100002000030000100001000010000100000000000000000000000000000000700007000070000700007000070000700007
011000200417504135041150417504135041150417504135041150417504135041150417504135041750413500175001350011500175001350011500175001350011500175001350011500175001350017500135
011000200217502135021150217502135021150217502135021150217502135021150217502135021750213509175091350911509175091350911509175091350911509175091350911509175091350917509135
012000201051617526125361f5461055617556125561f5560c51617526135361e5460c55617556135561c5560b51612526155361a5460b55612556155561a5560e51615526195361e5460e55615556195561e556
014000000404404040040400404000044000400004000040070440704007040070400204402040020400204004134041300413004130001340013000130001300b1340b1300b1300b13002134021300213002130
011200200c063005051f605005052b6450000000505005050c063000000c063000002b6450000000505005050c0630000000000000002b64500000000000c0630c063000000c063000002b6450c505104052b605
012400001a2551a3151f304214551a2551a3151a305214551c2551c3151f304214551c2551c3151f304214551a2551a31518300214551a2551a3151830021455232552331521455212151e3551e4151c3551c415
012400000214502125021150710007100021450212502115061450612506115071000710006145061250611507145071250711507100071000714507125071150714507125071150710007100091450912509115
012400000714507125071150710007100071450712507115091450912509115071000710009145091250911502145021250211507100071000214502125021150214502125021150710007100021450212502105
012400001e4441f4411f4401f4111e4401e4111a4401a411194401943119411194151944019411194401a44015446154461c4401c4401c4311c4111c4151c40512446124461a4401a4401a4311a4111a4151a405
01480000265052d50532505345052a5052d50534505365052b5052f50536505375052d505345053950539505265452d54532545345452a5452d54534545365452b5452f54536545375452d545345453954528505
01200020050640516005064051600506405160050640516003064031600306403160030640316003064031600a0640a1600a0640a1600a0640a1600a0640a1600106401160010640116001064011600106401160
011e00002b2161c22623236282462b2161c22623236282462a2161c22623236282462a2161c22623236282462b2161c22623236282462b2161c22623236282462a2161a22621236282462a2161a2262123628246
011e00002b2161822623236282462b2161822623236282462a2161a22623236282462a2161a22623236282462b2161822623236282462b2161822623236282462a2161a22621236282462a2161a2262123628246
011e00000c0030c0030c0030c0031800318003180031800318605186050c60500605246052b605306053c6050c0630c0430c0230c0131806318043180231801318645186250c61500615246452b635306353c635
010f0020130730c615186250c615186250c615130730c615306552b615186250c615186250c615130730c615006350c615186250c615186250c615130730c615306552b615186250c615186250c615186250c615
011e00000415404141041210415504355044550405004041040310415504050100511035510150040550405004054040110415004111040500425004231020500205002150020500e1520e0550e2520205002031
011e000000054000410c1510025000151001310c1570c131021540225002154023510245509051021520203100054000410c1510035000151001310c2570c131020540215002054022500e0540e3500e0540e450
010f0020130730c615186250c615306250c615130730c615306552b615186250c615306250c615130730c615186250c6152405324013306250c615130730c615306552b615186250c615306250c615186250c615
013000001a3551a31521255212151f4551f4152625526215163551631521255212151f4551f4152625526215183551831521255212151f4551f4151c2551c2151a3551a31521255212151f4551f4152625526215
01300000020470e0470e04702047020470e0470e047020470a0470e0470e0470a0470a0470e0470e0470a04700047100471004700047000471004710047000470204715047150470204702047150471504702047
0150010a006140c6111861124611306113c6113061124611186110c61100611006110061400614006140061400604006040060400604006040060400604006040060400604006040060400604006040060400604
011000000700407000070000700502004020000200002005070040700007000070050200402000020000200509004090000900009005000040000000000000050700407000070000700502004020000200002005
011000000700407000070000700502004020000200002005070040700007000070050200402000020000200509004090000900009005000040000000000000050700407000070000700502004020000200002005
011000000700407000070000700502004020000200002005070040700007000070050200402000020000200509004090000900009005000040000000000000050700407000070000700502004020000200002005
011000000700407000070000700502004020000200002005070040700007000070050200402000020000200509004090000900009005000040000000000000050700407000070000700502004020000200002005
__music__
00 0f 14 43 44
00 0f 14 23 15
03 0f 14 15 31
00 41 0d 43 44
00 41 0d 43 44
00 41 0d 0e 44
00 41 0d 0e 44
03 41 0d 0e 16
00 41 17 18 44
00 19 17 18 1a
00 1b 17 18 1a
03 1b 17 1c 1a
01 41 1d 1e 1f
02 41 20 21 1f
01 41 23 22 24
00 41 25 22 24
00 41 25 26 27
00 41 25 26 28
02 41 2a 29 44
01 41 2c 2b 44
00 41 2c 2b 2d
00 41 2c 2b 2d
00 41 2e 2b 2f
00 41 2c 2b 2d
00 41 2c 2b 2d
02 41 30 2e 2f
04 41 42 08 09
01 41 10 11 44
00 41 10 11 44
00 41 10 11 13
00 41 10 11 13
00 41 11 13 12
00 41 11 13 12
02 41 13 12 44
01 41 32 43 44
01 41 33 34 44
00 41 32 35 36
00 41 33 35 37
00 41 32 38 36
00 41 33 38 37
02 41 36 35 44
00 41 39 43 44
00 41 39 3a 44
03 41 39 3a 3b
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
