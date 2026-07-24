pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--cardinal ramship pirate
--by st33d


-- €‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™
-- ƒ ‹ ‘ ” Ž —

--Utils
-- based on https://github.com/jonstoler/class.lua
-- i removed the getter setters, no idea if that
-- broke it but it seems to still work
classdef = {}

-- default (empty) constructor
function classdef:init(...) end

-- create a subclass
function classdef:extend(obj)
  local obj = obj or {}
  local function copytable(table, destination)
    local table = table or {}
    local result = destination or {}
    for k, v in pairs(table) do
      if not result[k] then
        if type(v) == "table" and k ~= "__index" and k ~= "__newindex" then
          result[k] = copytable(v)
        else
          result[k] = v
        end
      end
    end
    return result
  end
  copytable(self, obj)
  obj._ = obj._ or {}
  local mt = {}
  -- create new objects directly, like o = object()
  mt.__call = function(self, ...)
    return self:new(...)
  end
  setmetatable(obj, mt)
  return obj
end

-- create an instance of an object with constructor parameters
function classdef:new(...)
  local obj = self:extend({})
  if obj.init then obj:init(...) end
  return obj
end

function class(attr)
  attr = attr or {}
  return classdef:extend(attr)
end


-- for when you need to send a list of stuff to print
joiner=","
function joinstr(...)
  local args = {...}
  local s = ""
  for i in all(args) do
    if type(i)=="boolean" then
      i = i and "true" or "false"
    end
    if s == "" then
      s = i
    else
      s = s..joiner..i
    end
  end
  return s
end

--print to debug
function debugp(...)
  joiner=","
  add(debug,joinstr(...))
end

-- method is a function(c,r)
function forinrect(x,y,w,h,method)
  for c=x,(x+w)-1 do
    for r=y,(y+h)-1 do
      method(c,r)
    end
  end
end

function shuffle(v)
  local j,x
  for i=#v,1,-1 do
    j=rnd1(i)
    x=v[i]
    v[i]=v[j]
    v[j]=x
  end
end

function rnd1(n)
  return 1+flr(rnd(n))
end
function rnd0(n)
  return flr(rnd(n))
end

function log_say(s,c)
  -- debugp(s)
  log_str=s
  log_c=1
  log_col=c or 5
end

--Game

--globals

keydir={
  [0]={x=-1,y=0},[1]={x=1,y=0},[2]={x=0,y=-1},[3]={x=0,y=1},[-1]={x=0,y=0}
}
name_dir={
  [0]="left",[1]="right",[2]="up",[3]="down",[4]="fire"
}
flipdir={
  [0]=1,[1]=0,[2]=3,[3]=2,[4]=4
}
--flags
f_player = shl(1, 0)--us
f_wall = shl(1, 1)--hard surface
f_trap = shl(1, 2)--area we scan for ids
f_crate = shl(1, 3)--pushable box, causes bugs
f_win = shl(1, 4)--win tiles
f_slow = shl(1, 5)--slow floor
f_fuel = shl(1, 6)--fuel floor
f_crumble = shl(1, 7)--crumble wall
--pico 8 doesn't use flags this high, so it works for out-of-bounds
f_outside = shl(1, 8)

cartdata(0)
best=dget(0)--best score
--physical objects
-- blox = {}--physics list
-- pickups = {}--collectable loot list
-- effects = {}--fx
-- chunkdecks = {}--3 decks of chunks
chunkdeck_lib={}
-- chunkdeck_backup_a,chunkdeck_backup_b,chunkdeck_backup_c = {},{},{}--chunks of 16x16 map
chunked = {}--drawn chunks
blokmap = {x=0,y=0,w=128,h=64}--defines room boundaries
impactdamp = 0.9
mindamage = 0.4
speed_min = 0.1
dropdamp = 0.98--default falling friction
grav = 0.37--set g on a blok to simulate gravity
minmove = 0.1--avoid micro-sliding, floating point error can lead to phasing


us = nil--the player

--add to print out debug
debug = {}
-- the coordinates of the upper left corner of the camera
cam_x,cam_y = 0,0
-- screen shake offset
-- shkx,shky = 0,0
shky = 0
-- screen shake speed
-- shkdelay,shkxt,shkyt=2,2,2
shkdelay,shkyt=2,2

function _k(x,y) return x..","..y end

-- map chunking
function get_chunk(x,y)
  local ch={}
  local x16,y16=x*16,y*16
  forinrect(x16,y16,16,16,function(c,r)
    ch[_k(c-x16,r-y16)]=mget(c,r)
    mset(c,r,0)
  end)
  return ch
end

function create_chunk(chunk, x, y, is_start)
  -- override, draw final room
  if(chunkcount==finish_chunk_index) chunk,finish_k = finish_chunk,_k(x,y)

  chunked[_k(x,y)]=true
  local x16,y16=x*16,y*16
  forinrect(0,0,16,16,
  function(c,r)
    local sp=chunk[_k(c,r)]
    c,r=c+x*16,r+y*16
    if sp == 1 then
      us = player(c,r)
      add(blox, us)
    elseif sp >= 12 and sp<=14 then
      -- max 32 chunks
      local range = flr(chunkcount/2)
      local crate = ship(c,r,sp,f_crate,is_start and 6 or range+2, range)
      --local crate = ship(c,r,sp,f_crate,is_start and armory_total or chunkcount, chunkcount)
      add(blox, crate)

      --crate:autoequip(get_loot(1,0))
    else
      mset(c,r,sp)
    end
  end)
  chunkcount+=1
end

function get_chunk_group(x,y,w,h)
  local tbl={}
  forinrect(x,y,w,h,function(c,r)
    add(tbl,get_chunk(c,r))
  end)
  add(chunkdeck_lib,tbl)
end


--init----------------------
function _init()
  
  --LOAD THE CHUNKS
  get_chunk_group(0,3,8,1)
  get_chunk_group(1,1,7,2)
  get_chunk_group(0,0,8,1)

  start_chunk=get_chunk(0,1)
  finish_chunk=get_chunk(0,2)
  new_game()

  mnu.visible=true
end


--- NEW GAME ------------------------
function new_game()
  completed,score,chunkcount,chunkdeck,chunked,blox,pickups,effects,visited=false,0,0,{},{},{},{},{},{}

  chunk_lib_index,finish_k=1,nil
  finish_chunk_index=25+rnd0(4)
  -- finish_chunk_index=4
  forinrect(0,0,128,64,function(c,r)mset(c,r,0)end)

  create_chunk(start_chunk,rnd0(6),rnd0(3),true)


  stars = {}--generate the stars
  for i=1,100 do
    local v,c = rnd(0.7),5
    if(v > 0.5) c=1
    add(stars, {x=rnd(127),y=rnd(127),v=v,c=c} )
   end
  camx,camy=us:campos()
  camxp,camyp=camx,camy
  
  mnu = mnu_new()
  mnu_init(mnu)
  awake_rect={x=-128,y=-128,w=384,h=384}
  mines,sleeping={},{}

  collect_loot(get_loot(3,rnd0(4)))
  
  chunk_look()
  
  log_say("welcome c.r.pirate")
end

function chunk_look()
  --check for creating chunks
  local pc,pr=flr(us.x/128),flr(us.y/128) 
  visited[_k(pc,pr)]=true
  
  forinrect(pc-1,pr-1,3,3,function(c,r)
    c,r=mid(0,c,7),mid(0,r,3)
    if not chunked[_k(c,r)] then
      
      if #chunkdeck==0 then
        -- debugp("new chunkdeck:"..chunk_lib_index)
        for c in all(chunkdeck_lib[chunk_lib_index]) do
          add(chunkdeck, c)
        end
        shuffle(chunkdeck)
        if(chunk_lib_index<3)chunk_lib_index+=1
      end
      local ch=chunkdeck[rnd1(#chunkdeck)]
      del(chunkdeck,ch)
      create_chunk(ch,c,r)
    end
  end)
end


--update----------------------
function _update()
  
  -- clear colision data
  for a in all(blox) do
    a.touchx,a.touchy = nil,nil
    --set sleep
    if not a:intersectsblok(awake_rect) then
      a.active=false
      add(sleeping, a)
      --debugp("sleep "..a.n.." "..#sleeping)
    end
  end
  --set awake
  local refresh,ri={},1
  for a in all(sleeping) do
    if a:intersectsblok(awake_rect) then
      a.active=true
      add(blox, a)
      --debugp("wake "..a.n.." "..#sleeping-1)
    else
      refresh[ri]=a
      ri+=1
    end
  end
  sleeping=refresh

  mnu_upd(mnu)

  if not mnu.visible and not completed then

    -- UPDATE PLAYER / PLAYER-AI
    if(us.active) us:upd()--player 1st for feels

    --LEVEL GEN
    chunk_look()

    awake_rect.x,awake_rect.y=us.x-124,us.y-124
    
    --NORMAL TIME CONTINUES
    if us.burn>0 then
      -- check for pickups
      if us.active then
        for a in all(pickups) do
          if a.active then
            if a:intersectsblok(us) then
              collect_loot(a.loot)
              sfx(13)
              a.active=false
            else
              a:upd()
            end
          end
        end
        --check for traps
        local tx,ty=us.tx,us.ty
        local us_map_sp=mget(tx,ty)
        local flag=fget(us_map_sp)
        if band(flag,f_win)~=0 then
          --win trap
          completed=true
          score*=10
          add_score(0) -- update score
          set_best()
          sfx(15)
          return
        elseif band(flag,f_fuel)~=0 then
          --fuel trap
          mset(tx,ty,0)
          if us_map_sp==15 then
            -- it's gold instead
            sfx(23)
            add_score(1)
            log_say("got gold")
            spark_rect(tx*8+1,ty*8+1,6,6,0.5,gold_sparks)
          else
            us:addfuel(15)
            sfx(14)
            log_say("got fuel")
            spark_rect(tx*8+1,ty*8+1,6,6,0.5,fuel_sparks)
          end
        elseif us_map_sp==20 then
          --mine trap
          mset(tx,ty,0)
          add(mines,{active=true,x=tx*8,y=ty*8,t=60})
          sfx(21)
        end
      else
        for a in all(pickups) do
          if a.active then
            a:upd()
          end
        end
      end

      --update mines
      for m in all(mines) do
        m.t-=1
        if m.t<=0 then
          m.active=false
          local x,y,r=m.x+4,m.y+4,16
          local obs=getobstacles(x-r,y-r,r*2,r*2,f_trap)
          for a in all(obs) do
            if blok.intersectscircle(a,x,y,r) then
              -- debugp("hit",a.n)
              if band(a.flag,f_crumble)~=0 then
                crumble_hit(a)
              elseif a.adddamage then
                a:adddamage(5)
              end
            end
          end
          sfx(22)
          circsmallers(x,y,{r,r-2},{9,10})
        end
      end

      
      
      
      --update other blox
      for a in all(blox) do
        if(a ~= us and a.active) a:upd()
      end
    end
  end

  -- garbage collect
  blox=garbage_collect(blox)
  pickups=garbage_collect(pickups)
  mines=garbage_collect(mines)
end


function set_best()
  if best<score then
    best=score
    dset(0,best)
  end
end

function  garbage_collect(tbl)
  local good,i = {},1
  for a in all(tbl) do
    if a.active then
      good[i] = a
      i += 1
    end
  end
  return good
end

--draw----------------------
function _draw()
  cls()
  
  camx,camy=us:campos()
  -- camera(camx+shkx, camy+shky)
  camera(camx, camy+shky)
  shake_upd()
  --map border
  local ax,ay,bx,by=max(camx-1,-1),max(camy-1,-1),min(camx+128,1024),min(camy+128,512)
  rect(ax,ay,bx,by,5)
  rect(ax-2,ay-2,bx+2,by+2,1)
-- draw stars
  for st in all(stars) do
    local x,y,v,c = st.x,st.y,st.v,st.c
    x+=(camx-camxp)*v
    y+=(camy-camyp)*v
    if(x<camx)x+=128
    if(x>camx+127)x-=128
    if(y<camy)y+=128
    if(y>camy+127)y-=128
    pset(x,y,c)
    st.x,st.y=x,y
  end
  camxp,camyp=camx,camy

  local c,r=flr(camx/8)-1,flr(camy/8)-1
  map(c,r,c*8,r*8,18,18)
  -- draw mines
  for a in all(mines) do
    circ(a.x+4,a.y+4,16,2)
    spr(a.t%4>1 and 21 or 22,a.x,a.y)
  end
  -- draw pickups
  for a in all(pickups) do
    if a.active then a:draw() end
  end
  -- draw blox
  for a in all(blox) do
    if a.active then a:draw() end
  end
  -- draw effects
  for a in all(effects) do
    if a.active then a:draw(us.burn>0) end
  end
  effects=garbage_collect(effects)

  -- reset cam for ui
  camera()

  if completed then
    rectfill(20,80,108,108,1)
    rectfill(21,81,107,107,0)
    print("yarr the space booty\nis all yours!",23,84,6)
    print("score:"..score.." best:"..best,26,99,6)
  end

  mnu_draw(mnu)

  -- draw UI
  --stats
  rectfill(0,0,127,7,0)
  line(0,7,128,7,1)
  local damagex = abs(us.vx)+us:attack(us.vx>0 and 1 or 0)
  damagex=damagex<mindamage and 0 or ceil(damagex)
  local damagey = abs(us.vy)+us:attack(us.vy>0 and 3 or 2)
  damagey=damagey<mindamage and 0 or ceil(damagey)
  joiner=""
  print(joinstr("†",us.fuel,"/",us.fuel_max," ‡",us.hp,"/",us.hp_max," “",us.burn,"/",us.burn_max," …x",damagex,",y",damagey),1,2,6)
  --log
  rectfill(0,120,128,128,0)
  line(0,120,128,120,1)
  print(sub(log_str,0,log_c),1,122,log_col)
  if(log_c<#log_str)log_c+=1
  --warning
  local col
  if us.hp<=5 or us.fuel<=0 then
    col=8
  elseif us.hurt>0 then
    col=2
  elseif us.fuel<20 then
    col=3
  end
  if(col)rect(0,8,127,119,col)

  -- print out values added to debug
  local total,ty,good=#debug,0,{}
  for i=1,total do
    local s = debug[i]
    print(s,1+cam_x,1+cam_y+ty,14)
    ty += 8
    if(i > total-15) add(good, s)
  end
  debug = good
end


-- set screen shake
function shake(y)
  -- if(abs(x)>abs(shkx)) shkx,shkxt=x,shkdelay+1
  if(abs(y)>abs(shky)) shky,shkyt=y,shkdelay+1
end
--update screen shake
function shake_upd()
  -- if shkxt > 0 then
  --   shkxt-=1
  --   if shkxt == 0 then
  --     local sn = sgn(shkx)
  --     if sn > 0 then
  --       shkx = -shkx
  --     else
  --       shkx= -(shkx+1)
  --     end
  --     shkxt=shkdelay
  --   end
  -- end
  if shkyt > 0 then
    shkyt-=1
    if shkyt == 0 then
      local sn = sgn(shky)
      if sn > 0 then
        shky = -shky
      else
        shky= -(shky+1)
      end
      shkyt=shkdelay
    end
  end
end



--Engine
-- aabb recursive moving entity
blok = class()
blokn = 0--track instances of blok for debugging

-- x,y,w,h: bounds
-- flag: a pico 8 map flag
-- ignore: flags we want this blok to ignore
-- sp: sprite
function blok:init(x,y,w,h,flag,ignore,sp)
  self.active,self.x,self.y,self.w,self.h,self.flag,self.ignore,self.sp=
    true,x or 0,y or 0,w or 8,h or 8,flag or 0,ignore or 0,sp or 1
  self.vx,self.vy,self.dx,self.dy,self.touchx,self.touchy=
    0,0,0,0,0,nil,nil
  blokn+=1
  self.n=blokn
end

--update
function blok:upd()
  --move x, then y, allowing us to slide off walls
  --avoid micro-sliding, floating point error can cause phasing
  if abs(self.vx) > 0.1 then
    self:movex(self.vx)
  end
  if abs(self.vy) > 0.1 then
    self:movey(self.vy)
  end
  --apply damping
  self.vx*=self.dx
  self.vy*=self.dy
end

function blok:movex(v, crush)
  local x,y,w,h = self.x,self.y,self.w,self.h
  local edge,obstacles = v>0 and x+w or x,{}
  if v>0 then
    obstacles=getobstacles(x+w,y,v,h,self.ignore,self)
    sort(obstacles,rightwards)
  elseif v<0 then
    obstacles=getobstacles(x+v,y,abs(v),h,self.ignore,self)
    sort(obstacles,leftwards)
  end
  if #obstacles>0 then
    for ob in all(obstacles) do
      local obedge=v>0 and ob.x or ob.x+ob.w
      --break if v reduced to no overlap
      if (v>0 and obedge > edge+v) or (v<0 and obedge < edge+v) then break end
      --how far should it move?
      local shdmove = (edge+v)-obedge
      self.touchx=ob
      if ob.movex then
        --swap velocities
        ob:shuntx(self)
        self:shuntx(ob)
        self.vx,ob.vx=ob.vx,self.vx
      else
        self:impactx(ob)
        if band(ob.flag,f_crumble)~=0 then
          self.vx*=0.5
        else
          self.vx=0
        end
      end
        v -= shdmove
        --quit or shdmove will work in reverse
      if(abs(v)<0.001)break
    end
  end
  self.x+=v
  return v
end

function blok:shuntx(source) end
function blok:impactx(target) end

function blok:movey(v, crush)
  local x,y,w,h = self.x,self.y,self.w,self.h
  local edge,obstacles = v>0 and y+h or y,{}
  if v>0 then
    obstacles=getobstacles(x,y+h,w,v,self.ignore,self)
    sort(obstacles,downwards)
  elseif v<0 then
    obstacles=getobstacles(x,y+v,w,abs(v),self.ignore,self)
    sort(obstacles,upwards)
  end
  if #obstacles>0 then
    for ob in all(obstacles) do
      local obedge=v>0 and ob.y or ob.y+ob.h
      --break if v reduced to no overlap
      if (v>0 and obedge > edge+v) or (v<0 and obedge < edge+v) then break end
      --how far should it move?
      local shdmove = (edge+v)-obedge
      self.touchy=ob
      if ob.movey then
        --swap velocities
        ob:shunty(self)
        self:shunty(ob)
        self.vy,ob.vy=ob.vy*impactdamp,self.vy*impactdamp
      else
        self:impacty(ob)
        if band(ob.flag,f_crumble)~=0 then
          self.vy*=0.5
        else
          self.vy=0
        end
        -- self:impacty(ob)
        -- self.vy=0
      end
      v -= shdmove
      --quit or shdmove will work in reverse
      if(abs(v)<0.001)break
    end
  end
  self.y+=v
  return v
end
function blok:shunty(src) end
function blok:impacty(target) end


function blok:death(src)--source of death
  self.active=false
end

function blok:draw(sp)
  sp = sp or self.sp
  local x,y=self:center()
  spr(sp,-4+x,-4+y,1,1,self.vx<0)
  --print(self.n,x,y,7)
end

function blok:center()
  return self.x+self.w*0.5,self.y+self.h*0.5
end

function blok:centertile()
  local x,y=self:center()
  return flr(x/8),flr(y/8)
end

function blok:intersectsblok(a)
  return not (a.x>=self.x+self.w or a.y>=self.y+self.h or self.x>=a.x+a.w or self.y>=a.y+a.h)
end

function blok:intersects(x,y,w,h)
  return not (x>=self.x+self.w or y>=self.y+self.h or self.x>=x+w or self.y>=y+h)
end

-- function blok:contains(x,y)
--   return x>=self.x and y>=self.y and x<self.x+self.w or y<self.y+self.h
-- end

--this fails at long distance
--the overflow causes 0,0,0 to be returned, watch for it
function blok:normalto(bx,by)
  local ax,ay = self:center()
  local vx,vy = (bx-ax),(by-ay)
  local len = sqrt(vx*vx+vy*vy)
  if(len > 0) return vx/len,vy/len,len
  return 0,0,0
end
function blok:distm(ob)
  local ax,ay = self:center()
  local bx,by = blok.center(ob)
  return abs(bx-ax) + abs(by-ay)
end
function blok:dirto(ob)
  local ax,ay = self:center()
  local bx,by = blok.center(ob)
  if abs(bx-ax) > abs(by-ay) then
    if bx < ax then return 0
    else return 1 end
  else
    if by < ay then return 2
    else return 3 end
  end
end

function blok:intersectscircle(cx,cy,r)
  local tx,ty,x,y,w,h = cx,cy,self.x,self.y,self.w,self.h
  if(tx<x)tx=x
  if(tx>x+w-1)tx=x+w-1
  if(ty<y)ty=y
  if(ty>y+h-1)ty=y+h-1
  return (cx-tx) * (cx-tx) + (cy-ty) * (cy-ty) < r * r
end

--x,y:position or x is an blok, v:speed, d:damping
-- function blok:moveto(x,y,v,d)
--   local tx,ty,len = self:normalto(x,y)
--   if(v > len) v = len
--   self.vx,self.vy,self.dx,self.dy = tx*v,ty*v,d,d
-- end

-- collision utils

-- function centertile(c,r,w,h)
--   w,h = (w or 0),(h or 0)
--   return (4+c*8)-w*0.5,(4+r*8)-h*0.5
-- end

-- function intersectsmap(x,y,w,h)
--   local xmin, ymin = flr(x/8),flr(y/8)
--   local xmax, ymax = flr((x+w-0.001)/8),flr((y+h-0.001)/8)
--   for c=xmin,xmax do
--     for r=ymin,ymax do
--       if (fget(mget(c,r))>0) then
--         return true
--       end
--     end
--   end
--   return false
-- end

--return a table of objects describing tiles on the map
--ignore: do not return anything with this flag
--result: a table of results to add to
function mapobjects(x,y,w,h,ignore,result)
  result,ignore = result or {},ignore or 0
  local xmin, ymin = flr(x/8),flr(y/8)
  -- have to deduct a tiny amount, or we end up looking at a neighbour
  local xmax, ymax = flr((x+w-0.001)/8),flr((y+h-0.001)/8)
  local rxmin,rymin,rxmax,rymax = blokmap.x,blokmap.y,blokmap.x+blokmap.w-1,blokmap.y+blokmap.h-1
  for c=xmin,xmax do
    for r=ymin,ymax do
      --bounds check
      if c<rxmin or r<rymin or c>rxmax or r>rymax then
        add(result, {x=c*8,y=r*8,w=8,h=8,flag=f_outside,sp=0})
      else
        local sp=mget(c,r)
        local f = fget(sp)
        if f > 0 and band(f, ignore) == 0 then
          add(result, {x=c*8,y=r*8,w=8,h=8,flag=f,sp=sp})
        end
      end
    end
  end
  return result
end

--return all blox or tiles in an area,
--excluding source from the list and anything with a flag it ignores
--tiles returned are basic versions of blox
function getobstacles(x,y,w,h,ignore,source)
  local result = {}
  ignore = ignore or 0
  mapobjects(x,y,w,h,ignore,result)
  for a in all(blox) do
    if a ~= source and a.active then
      if band(ignore, a.flag)==0 and a:intersects(x,y,w,h) then
        add(result, a)
      end
    end
  end
  return result
end

-- sorting comparators
function rightwards(a,b)
  return a.x>b.x
end
function leftwards(a,b)
  return a.x<b.x
end
function downwards(a,b)
  return a.y>b.y
end
function upwards(a,b)
  return a.y<b.y
end

--insertion sort
function sort(a,cmp)
  for i=1,#a do
    local j = i
    while j > 1 and cmp(a[j-1],a[j]) do
        a[j],a[j-1] = a[j-1],a[j]
    j = j - 1
    end
  end
end

-- space craft
ship = blok:extend()

function ship:init(c,r,sp,flag,loot_range,hp_max)
  self.sc, self.sr = c,r -- spawn column & row
  blok.init(self,c*8,r*8,8,8,flag,f_trap,sp)
  self.dx,self.dy=0.97,0.97
  self.hp,self.hp_max,self.fuel,self.fuel_max,self.burn,self.burn_max,self.dir=3,3,10,10,0,0,4
  self.scandist,self.hurt=2*8,0
  self.slots,self.speed={},0
  -- crates always weak
  if (sp==14) self.hp,self.hp_max,hp_max,loot_range = 2,2,0,ceil(loot_range/2)
  local n=0

  for i=0,3 do
    if(loot_range) n=rnd0(min(loot_range,armory_total))
    -- self.slots[i]=get_loot("thruster",i,1,nil,0,6)
    self.slots[i]=get_loot(n,i)
  end
  -- self.slots[4]=get_spell("wait",4,0,nil,6,function() log_say("wait") end,"do nothing",0)
  if(loot_range) n=rnd0(min(loot_range/2,spell_total))
  self.slots[4]=get_loot(n,4)

  if hp_max then
    self:addhp_max(hp_max)
    self.hp=self.hp_max
  end
    -- self.hp=100
end

function ship:upd()
  self.tx,self.ty=self:centertile()
  if(self.burn==0) self:ai()
  if self.burn>0 then
    self.burn-=1
    if self.dir<4 then
      local loot,d=self.slots[flipdir[self.dir]],keydir[self.dir]
      self.vx+=d.x*loot.speed
      self.vy+=d.y*loot.speed
      --simulate
    end
    local floor_flag = fget(mget(self.tx,self.ty)) 
    if band(floor_flag, f_slow) ~= 0 then
      self.dx,self.dy=0.8,0.8
    --speed floor uses crumble flag
    elseif band(floor_flag, f_crumble) ~= 0 then
      self.dx,self.dy=1.025,1.025
    else
      self.dx,self.dy=0.98,0.98
    end
    blok.upd(self)
  end
  if self.hurt>0 then
    self.hurt-=0.1 
    add(effects,spark(self.x+rnd(self.w),self.y+rnd(self.h),-0.5+rnd(),-0.5+rnd(),ship_sparks))
  end
end

function ship:death(src)
  self.active=false
  self:droploot()
  local x,y=self:center()
  circsmallers(x,y,{12,10},{8,10})
  -- shake(0,self==us and 5 or 3)
  shake(self==us and 5 or 3)
  if self~=us then
    add_score(1)
    if sp==14 then
      sfx(5)
    else
      sfx(4)
    end
  else
    sfx(6)
  end
end

function ship:droploot()
  local x,y=self:center()
  for i=0,4 do
    local loot=self.slots[i]
    if(loot.scrap) add(pickups,pickup(x,y,loot,self))
  end
end

-- attaches loot if slot empty or slot-loot has no scrap value
function ship:autoequip(loot)
  if not self.slots[loot.dir].scrap then
     self.slots[loot.dir]=loot
     return true
  end
end

function crumble_hit(ob)
  local x,y=blok.center(ob)
  circsmallers(x,y,{8,6},{4,9})
  spark_rect(ob.x,ob.y,ob.w,ob.h,1,crumble_sparks)
  mset(flr(ob.x/8),flr(ob.y/8),0)
  sfx(3)
end

function ship:hit(v,src,dir)
  local dmg=abs(v) + (src.attack and src:attack(dir) or 0) - self:defence(flipdir[dir])
  --debugp(dir, self:defence(flipdir[dir]))
  if self==us then
    if(dmg<0.6) return
  else
    if(dmg<mindamage) return
  end
  dmg=ceil(dmg)
  if(src==us or self==us)shake(dmg)
  --is it a crumble tile?
  if band(src.flag,f_crumble)~=0 then
    crumble_hit(src)
    return
  end
  -- range of dmg sounds
  if (self==us or src==us) sfx(7+min(dmg,5))

  self:sparks(dir)
  
  self:adddamage(dmg)

  if src.attack then
    --push
    local d,loot=keydir[dir],src.slots[dir]
    if self.active and src.active then
      --velocity swap is called after contact
      src.vx+=d.x*loot.push
      src.vy+=d.y*loot.push
    end
    --drain
    if loot.name=="fangs" then
      src:addhp(dmg/2)
    elseif loot.name=="fangs" then
      src:addfuel(dmg*3)
    end
  end

  -- debugp(dmg, self==us)
end

function ship:adddamage(dmg)
  self.hurt+=dmg
  self.hp-=dmg
  if(self.hp<=0 and self.active) self:death(src)
end

function ship:addhp(hp)
  self.hp=min(self.hp_max,self.hp+flr(hp))
end

function ship:addhp_max(hp_max)
  self.hp_max+=hp_max
  local m,x,y,w,h=self.hp_max,self.x,self.y,self.w,self.h
  if(self==us)m-=8
  if m>=14 then
    w=16
  elseif m>=12 then
    w=14
  elseif m>=10 then
    w=12
  elseif m>=8 then
    w=10
  end
  if w>self.w then
    local dif=w-self.w
    self.x,self.y,self.w,self.h=x-dif*0.5,y-dif*0.5,w,h+dif
  end 
end

function ship:addfuel(fuel)
  self.fuel=min(self.fuel_max,self.fuel+flr(fuel))
end


function ship:sparks(dir)
  local d,x,y=keydir[flipdir[dir]],self:center()
  local dx,dy=d.x*self.w*0.5,d.y*self.h*0.5
  for i=1,16 do
    add(effects,
      spark(x+dx-dy+rnd()*dy*2, y+dy-dx+rnd()*dx*2,rnd()*-self.vx,rnd()*-self.vy,
      ship_sparks))
  end
end


function ship:attack(dir) return self.slots[dir].attack end

function ship:defence(dir) return self.slots[dir].defence end

function ship:shuntx(src)
  
  if(abs(src.vx)<abs(self.vx)) return
  
  self:hit(src.vx,src,src.vx>0 and 1 or 0)
  --debugp("shunt x "..src.vx)
end

function ship:shunty(src)

  if(abs(src.vy)<abs(self.vy)) return

  self:hit(src.vy,src,src.vy>0 and 3 or 2)
  --debugp("shunt y "..src.vy)
end

function ship:impactx(target)
  local dir=self.vx>0 and 1 or 0
  self:hit(self.vx,target,self.vx>0 and 0 or 1)
  --debugp("impact x "..self.vx)
end
function ship:impacty(target)
  local dir=self.vy>0 and 3 or 2
  self:hit(self.vy,target,self.vy>0 and 2 or 3)
  --debugp("impact y "..self.vy)
end

function ship:drawscan()
  local dist=self.scandist
  local x,y,w,h=(self.x-dist)+self.vx,(self.y-dist)+self.vy,self.w,self.h
  rect(x, y, x+dist*2+w, y+dist*2+h,12)
  if self.scan then
    local s=self.scan
    rect(s.x, s.y, s.x+s.w-1, s.y+s.w-1,12)
  end
end

function ship:ai()
  if self.sp==12 or self.sp==13 then
    -- scan for options
    local dir=4 -- wait
    local best,best_dir=99999,4
    local best_ob
    local x,y,w,h=self.x,self.y,self.w,self.h
    local dist=self.scandist
    local obstacles=getobstacles((x-dist)+self.vx,(y-dist)+self.vy,dist*2+w,dist*2+h,bor(self.ignore,f_crumble),self)
  
    if #obstacles>0 then
      for ob in all(obstacles) do
        if best_ob then
          local dist=self:distm(ob)
          if dist<best then
            best_ob,best,best_dir=ob,dist,self:dirto(ob)
          end
        else
          best_ob,best,best_dir=ob,self:distm(ob),self:dirto(ob)
        end
      end
    end
    -- obstacle detected, avoid (or chase if it's us)
    if best_ob then
      self.scan=best_ob
      if best_ob==us then
        dir=best_dir
      else
        local d=keydir[best_dir]
        dir=flipdir[best_dir]
        -- if (d.x==0 and self.vy * d.y > 0) or (d.y==0 and self.vx * d.x > 0) then
        -- end
      end
    else
      -- no obstacles, chase player
      -- debugp(self:distm(us),self.scandist*3)
      if self:distm(us) < self.scandist*(self.sp==13 and 8 or 5) then
        dir=self:dirto(us)
        self.scan=us
      end
    end
    --debugp(dir)
    self.dir=dir
    local loot=self.slots[flipdir[dir]]
    self.burn,self.burn_max,self.speed=loot.burn,loot.burn,loot.speed
    
  else --crate
    self.burn=12
  end
end

function ship:bloodied() return self.hp<=self.hp_max*0.5 end

-- ship draw
function ship:draw()
  -- base
  local x,y,w,h=self.x,self.y,self.w,self.h
  rectfill(x,y,x+w-1,y+h-1,0)
  rect(x,y,x+w-1,y+h-1,1)
  x,y=self:center()
  -- flames
  local dir=self.dir
  if self.burn>0 and dir~=4 then
    local n = (3/self.burn_max) * self.burn + self.speed / 0.05
    local bframe = min(flr(n),5)
    if(dir==1)spr(69-bframe,x-12,y-4)
    if(dir==0)spr(69-bframe,x+4,y-4,1,1,true)
    if(dir==3)spr(85-bframe,x-4,y-12)
    if(dir==2)spr(85-bframe,x-4,y+4,1,1,false,true)
  end
  -- loot
  for i=0,3 do
    local d=keydir[i]
    local loot=self.slots[i]
    spr(loot.sp,x+d.x*8-4,y+d.y*8-4,1,1,loot.flipx,loot.flipy)
  end
  -- direction line
  local dx,dy,len=self:normalto(x+self.vx,y+self.vy)
  if len > 0.1 then
    dx,dy=x+dx*max(len*4,8),y+dy*max(len*4,8)
    line(x,y,dx,dy,1)
    pset(dx,dy,12)
  end
  -- icon
  blok.draw(self,self:bloodied() and self.sp+16 or self.sp)
  --debug ai
  --if(self~=us)self:drawscan()
end


--it's you murphy
player = ship:extend()

function player:init(c,r)
  ship.init(self,c,r,1,f_player)

  self.hp,self.hp_max,self.fuel,self.fuel_max=10,10,250,250
end

function player:campos(offx,offy)
  offx,offy=offx or 0,offy or 0
  return (self.x+offx)-60,(self.y+offy)-60
end

function player:ai()
  -- move
  local dir=-1
  if(btn(0)) dir=0
  if(btn(1)) dir=1
  if(btn(2)) dir=2
  if(btn(3)) dir=3
  --fire
  if(btn(4)) dir=4
  self.dir=dir
  if dir>=0 then
    self.burn,self.burn_max=6,6
    local loot=self.slots[flipdir[dir]]
    if dir==4 then
      loot.call()
    end
    self.burn,self.burn_max,self.speed=loot.burn,loot.burn,loot.speed
    if dir==4 then
      sfx(16)
    elseif loot.name=="thruster" then
      sfx(1)
    elseif loot.name=="booster" then
      sfx(2)
    else
      sfx(0)
    end
    -- burn fuel (or hp)
    local cost=loot.fuel_cost
    if cost>0 then
      if self.fuel>0 then
        self.fuel-=cost
        if self.fuel<=20 and self.fuel+cost>20 then
           log_say("low fuel!",11)
           sfx(19)
        end
        if self.fuel<0 then
          cost+=self.fuel
        else
          cost=0
        end
        if(self.fuel<=0)log_say("out of fuel!",7)
      end
      if cost>0 then
        self.hp-=cost
        local d=dir
        if(d==4)d=rnd0(4)
        self:sparks(d)
        if(self.hp<=0)self:death(self)
      end
    end
  end
end

function player:death(src)--src: source of death
  ship.death(self, src)
  self.burn=16 -- rest of world keeps running
  set_best()
  log_say("you died, score:"..score)
end


spark=class()
function spark:init(x,y,vx,vy,cols)
  self.active,self.x,self.y,self.vx,self.vy,self.cols,self.f=true,x,y,vx,vy,cols,rnd1(4)
end
function spark:draw(adv)
  pset(self.x,self.y,self.cols[self.f])
  if adv then
    self.x+=self.vx
    self.y+=self.vy
    self.f+=1
    if(self.f>#self.cols) self.active=false
  end
end
crumble_sparks={9,9,9,9,4,4,4,4,4,4,5,5,5,5,4,5,4,5,1,5,1,1,1}
ship_sparks={7,7,7,7,10,10,10,9,9,9,8,8,2,2,8,2,8,8,2,8,2,2,2}
fuel_sparks={10,10,10,10,11,11,11,3,3,3,11,11,3,3,11,3,1,1,3,1,3,1,1}
gold_sparks={7,7,7,7,10,7,10,7,10,7,10,10,9,10,9,10,9,10,9,9,4,9,4,9,4,4,2,4,2,2,2}
function spark_rect(x,y,w,h,power,tbl)
  forinrect(x,y,w,h,function(c,r)
    add(effects,
      spark(c,r,-power+rnd(power*2),-power+rnd(power*2),tbl))
  end)
end



circsmaller=class()
function circsmaller:init(x,y,r,col,spd)
  self.active,self.x,self.y,self.r,self.col,self.spd=true,x,y,r,col,spd or 0.5
end
function circsmaller:draw(adv)
  circfill(self.x,self.y,self.r,self.col)
  if adv then
    self.r-=self.spd
    if(self.r<=0) self.active=false
  end
end
function circsmallers(x,y,rs,cols,spd)
  for i=1,#rs do
    add(effects, circsmaller(x,y,rs[i],cols[i],spd))
  end
end

-->8
-- loot and menu system ----------------------------------------------
pickup=blok:extend()
function pickup:init(x,y,loot,shp)
  blok.init(self,x-3,y-3,6,6,f_trap,bor(f_player,f_crate))
  if shp then
    local range,r=1+rnd(1),rnd()
    self.vx,self.vy=cos(r)*range,sin(r)*range
  end
  self.dx,self.dy=0.97,0.97
  self.loot=loot
  -- debugp(self.vy,self.vy)
end
function pickup:draw()
  local loot = self.loot
  spr(loot.sp,self.x-2,self.y-2,1,1,loot.flipx,loot.flipy)
end

function add_score(n)
  score+=n
  score_mnu_item.desc=score.." best:"..best
end

--item menu
function collect_loot(loot,init)
  local branch = slots_mnu.tbl[loot.dir+1].call
  local item = mnu_add(loot.name,branch,loot_mnu,nil,nil,nil,loot_select)
  -- debugp(#mnu_dir.tbl..loot.name)
  item.loot=loot
  if not init then
     if(us:autoequip(loot)) branch.n = #branch.tbl
  end
  log_say("got "..name_dir[loot.dir].." "..loot.name)

end

armory_total=17
spell_total=1
function get_loot(id,dir)
  local name,dir,fuel_cost,scrap,burn,speed,attack,defence,push,flipx,flipy,sp,call,desc=
    "thrust",dir,1,nil,10,0.05,0,0,0,dir==1,dir==3,32,nil,""
    --6053
  if dir==4 then
    if id==0 then
      name,sp,fuel_cost,burn,call,desc=
        "wait",127,1,14,function() log_say("wait") end,"do nothing"
    end
  else
    if id==1 then
      name,sp,attack,speed,scrap=
        "dagger",46,0.25,0.06,get_scrap(1,20)
    elseif id==2 then
      name,sp,defence,burn,scrap=
        "buckler",33,0.5,6,get_scrap(4,5)
    elseif id==3 then
      name,sp,attack,push,burn,scrap=
        "mace",47,0.5,0.25,8,get_scrap(2,20)
    elseif id==4 then
      name,sp,attack,burn,scrap=
        "sword",37,1,8,get_scrap(1,20,1)
    elseif id==5 then
      name,sp,push,burn,scrap=
        "coil",39,1,8,get_scrap(3,20)
    elseif id==6 then
      name,sp,speed,burn,scrap=
        "thruster",44,0.1,7,get_scrap(0,100,0,10)
    elseif id==7 then
      name,sp,attack,push,burn,scrap=
        "hammer",36,1,0.5,7,get_scrap(3,20,1)
    elseif id==8 then
      name,sp,defence,push,burn,scrap=
        "shield",34,1,0.25,5,get_scrap(10,10,4)
    elseif id==9 then
      name,sp,attack,burn,scrap=
        "blades",97,1.5,7,get_scrap(2,30)
    elseif id==10 then
      name,sp,attack,push,burn,scrap=
        "warhammer",96,1.5,1,6,get_scrap(5,30,2)
    elseif id==11 then
      name,sp,defence,attack,push,burn,scrap=
        "s-shield",35,1,0.5,0.25,4,get_scrap(15,10,4)
    elseif id==12 then
      name,sp,attack,burn,scrap=
        "fangs",42,1.5,7,get_scrap(2,30,3)
    elseif id==13 then
      name,sp,push,burn,scrap=
        "spring",40,2,7,get_scrap(3,30,0,5)
    elseif id==14 then
      name,sp,attack,push,burn,scrap=
        "refuel",43,1,0.25,7,get_scrap(2,30,0,25)
    elseif id==15 then
      name,sp,speed,burn,scrap=
        "booster",45,0.2,6,get_scrap(0,200,0,50)
    elseif id==16 then
      name,sp,attack,burn,scrap=
        "axe",37,2,5,get_scrap(5,40,3)
    end
    if(dir>=2)sp+=16
  end

  return{
    name=name
    ,dir=dir
    ,fuel_cost=fuel_cost
    ,scrap=scrap
    ,flipx=flipx
    ,flipy=flipy
    ,sp=sp
    ,id=id
    ,burn=burn
    ,speed=speed
    ,attack=attack
    ,defence=defence
    ,push=push
    ,id=id
    ,call=call
    ,desc=desc
  }
end

function loot_select(item,branch)
  local loot=item.loot
  --loot_mnu.n=1
  loot_mnu.loot=loot
  loot_mnu.branch=branch
  loot_mnu.item=item
  joiner=""
  local s=joinstr(name_dir[loot.dir]," ",loot.name,"\n\n†:",loot.fuel_cost,"\n","“:",loot.burn,"\n")
  
  if loot.dir==4 then
    s=s..loot.desc
  else
    s=joinstr(s,"speed:",loot.speed,"\nattack:",loot.attack,"\ndefence:",loot.defence,"\npush:",loot.push)
  end
  us.slots[loot.dir]=loot
  local scrap=loot.scrap
  if(scrap)s=joinstr(s,"\n\nscrap value:\n†",scrap.fuel," ‡",scrap.hp,"\n+†",scrap.fuel_max," +‡",scrap.hp_max)
  loot_mnu.tbl[1].call=s
  -- debugp("select loot")
end

function get_scrap(hp,fuel,hp_max,fuel_max)
  hp_max,fuel_max=hp_max or 0,fuel_max or 0
  return{hp=hp,fuel=fuel,hp_max=hp_max,fuel_max=fuel_max}
end

function scrap_item()
  local loot=loot_mnu.loot
  local scrap=loot.scrap
  -- us.hp_max+=scrap.hp_max
  us:addhp_max(scrap.hp_max)
  us.fuel_max+=scrap.fuel_max
  us:addhp(scrap.hp)
  us:addfuel(scrap.fuel)
  mnu_del(loot_mnu.item,loot_mnu.branch)
  -- was the item equipped?
  for i=0,4 do
    if us.slots[i]==loot then
      local branch=slots_mnu.tbl[i+1].call
      loot_select(branch.tbl[branch.n],branch)
      break
    end
  end
  joiner=""
  log_say(joinstr("scrapped:†",scrap.fuel," ‡",scrap.hp," +†",scrap.fuel_max," +‡",scrap.hp_max))

  -- debugp("scrap "..us.hp.." "..us.fuel)
end

function cant_scrap()
  local scrap=loot_mnu.loot.scrap
  if(not scrap or not us.active)return true
  return scrap.hp_max==0 and scrap.fuel_max==0 and hp==us.hp_max and us.fuel==us.fuel_max
end


function get_slot_branch()
  local branch = mnu_branch()
  mnu_add("left", branch, mnu_branch())
  mnu_add("right", branch, mnu_branch())
  mnu_add("up", branch, mnu_branch())
  mnu_add("down", branch, mnu_branch())
  return branch
end


-- definte the menu contents
function mnu_init(mnu)

  --mnu_add(name,branch,call,backup,desc,disabled,onselect)
  local root = mnu.root
  --create menu tree
  loot_mnu = mnu_branch()
  mnu_add("info",loot_mnu,"blah")
  mnu_add("scrap",loot_mnu,scrap_item,1,"convert",cant_scrap)
  
  slots_mnu = mnu_branch()
  mnu_add("left", slots_mnu, mnu_branch())
  mnu_add("right", slots_mnu, mnu_branch())
  mnu_add("up", slots_mnu, mnu_branch())
  mnu_add("down", slots_mnu, mnu_branch())
  mnu_add("fire", slots_mnu, mnu_branch())
  for i=0,4 do
    collect_loot(us.slots[i],true)
  end
  
  restart_mnu = mnu_branch()
  mnu_add("no", restart_mnu)
  mnu_add("yes", restart_mnu, new_game)

  
  debug_mnu = mnu_branch()
  mnu_add("get item", debug_mnu, function()
    -- collect_loot(get_loot("boost",0,2,get_scrap(2,3,4,5),1,9,0.5,0,0,0),true)
    collect_loot(get_loot(2,1))
  end)
  
  local function branch_reset(item, branch)
    item.call.n=1
  end
  
  mnu_add("welcome", root, "cardinal\nramship\npirate\n\nram kill loot\nscrap for †‡\nfind gold chest\n\nnavigate:\nƒ‹‘”\nwait:Ž\ntoggle menu:—")
  mnu_add("slots", root, slots_mnu)
  map_mnu_item = mnu_add("map",root,"")
  score_mnu_item = mnu_add("score", root, function()end, nil,"0 best:"..best,function() return true end)
  mnu_add("restart", root, restart_mnu, nil, nil, nil, branch_reset)
  --mnu_add("debug", root, debug_mnu)

end

-->8
--cardinal menu system
function mnu_new()
  --"n": selection
  --"tbl": items in the branch
  local mnu={
    visible=false,
    root=mnu_branch(),
    prev={},
    steps=0,
    x=28,
    y=42,
    h=8,
    w=40,
    strh=75,
    strw=58,
    select_count=0,
    select_item=nil
  }
  mnu.branch=mnu.root
  return mnu
end

function mnu_branch(item) return {n=1,tbl={}} end

function mnu_add(name,branch,call,backup,desc,disabled,onselect)
  local item={name=name,call=call,backup=backup,desc=desc,disabled=disabled,onselect=onselect}
  add(branch.tbl, item)
  return item
end

function mnu_del(item,branch)
  local t,tbl,n={},branch.tbl,1
  for i=1,#tbl do
    if tbl[i]~=item then
      t[n]=tbl[i]
      n+=1
    else
      if(branch.n>1 and branch.n<=i)branch.n-=1
    end
  end
  branch.tbl=t
end

function mnu_drawitem(x,y,item,c,bc,mnu)
  rectfill(x,y,x+mnu.w,(y-1)+mnu.h,bc)
  print(item.name,x+1,y+2,c)
end

function mnu_drawbranch(x,y,branch,mnu)
  y-=(branch.n-1)*mnu.h
  rectfill(x-1,y-1,x+1+mnu.w,y+mnu.h*#branch.tbl,5)
  for i=1,#branch.tbl do
    local item = branch.tbl[i]
    local active=item.call and not (item.disabled and item.disabled(item)) 
    if(type(item.call)=="table" and #item.call.tbl==0) active=false
    local c = active and 6 or 5
    if(branch.n==i and branch==mnu.branch) c = active and 7 or 6
    mnu_drawitem(x, y, item, c, (branch==mnu.branch and branch.n==i) and 5 or 0,mnu)
    y += mnu.h
  end
end

function mnu_upd(mnu)
  if mnu.visible then
    local branch=mnu.branch
    local item=branch.tbl[branch.n]
    local n=branch.n
    --selection animation
    if mnu.select_count>0 then
      mnu.select_count-=1
      --execute
      if mnu.select_count==0 then
        local item=mnu.select_item
        --walk back to root or as many steps as the item demands
        if item.backup then
          if(item.backup>0)mnu.branch=mnu.prev[mnu.steps-(item.backup-1)]
          mnu.steps-=item.backup
        else
          mnu.branch,mnu.steps=mnu.root,0
        end
        --call the menu function, pass in locals
        item.call(item,branch,mnu)
        return;
      else
        return;
      end
    end

    if btnp(0) then
      -- left: previous menu
      if mnu.steps>0 then
        mnu.branch=mnu.prev[mnu.steps]
        mnu.steps-=1
      end
    elseif btnp(1) then
      -- right: call function / next menu
      if(item.disabled and item.disabled(item)) return
      local val=type(item.call)
      if val=="function" then
        mnu.select_item,mnu.select_count=item,10
        sfx(18)
      elseif val=="table" and #item.call.tbl>0 then
        mnu.steps+=1
        mnu.prev[mnu.steps]=mnu.branch
        mnu.branch=item.call
      end
    elseif btnp(2) then
      -- up: select above
      branch.n-=1
      if(branch.n<1)branch.n=#branch.tbl
    elseif btnp(3) then
      -- down: select below
      branch.n+=1
      if(branch.n>#branch.tbl)branch.n=1
    elseif btnp(5) then
      mnu.visible=false
      sfx(17)
    end
    --onselect callback
    local item_current=mnu.branch.tbl[mnu.branch.n]
    if item_current~=item then
      sfx(17)
      if (item_current.onselect) item_current.onselect(item_current, mnu.branch, mnu)
    end

  elseif btnp(5) then
    sfx(17)
    mnu.visible=true
  end
end

function mnu_draw(mnu)
  if(not mnu.visible)return

  local x,y,h,w=mnu.x,mnu.y,mnu.h,mnu.w
  -- draw previous branch
  if mnu.steps>0 then
    mnu_drawbranch(x-w,y,mnu.prev[mnu.steps],mnu)
  end
  -- draw current branch
  local branch=mnu.branch
  mnu_drawbranch(x,y,branch,mnu)
  -- draw the current target
  local item=branch.tbl[branch.n]
  local disabled=item.disabled and item.disabled(item,branch,mnu)
  local val=type(item.call)
  if val=="function" then
    local selecting=mnu.select_count>0
    rectfill(x-1+w,y-1,x+1+w+mnu.strw,y+h,5)
    rectfill(x+w,y,x+w+mnu.strw,(y-1)+h,selecting and 7 or 0)
    if disabled then
      print((item.desc and item.desc or "disabled"),x+1+w,y+2,5)
    else
      print((item.desc and item.desc or "select").." ‘",x+1+w,y+2,selecting and 0 or 7)
    end
  elseif val=="table" then
    if(not disabled and #item.call.tbl>0)mnu_drawbranch(x+mnu.w,y,item.call,mnu)
  elseif val=="string" then
    local strh = item.name~="map" and mnu.strh or 31
    rectfill(x-1+w,y-1-mnu.h,x+1+w+mnu.strw,y+strh-mnu.h,5)
    rectfill(x+w,y-mnu.h,x+w+mnu.strw,y-1+strh-mnu.h,0)
    print(item.call,x+1+w,y+2-mnu.h,6)
    -- map edge case
    if item.name=="map" then
      x,y,s=x+w+1,y-mnu.h+1,7
      local pc,pr=flr(us.x/128),flr(us.y/128)
      for r=0,3 do
        for c=0,7 do
          local cs,rs=x+c*s,y+r*s
          rect(cs,rs,cs+s,rs+s,5)
          if c==pc and r==pr then
            rectfill(cs+1,rs+1,cs+s-1,rs+s-1,6)
          elseif visited[_k(c,r)] then
            rectfill(cs+1,rs+1,cs+s-1,rs+s-1,1)
          end
          if(_k(c,r)==finish_k) rectfill(cs+2,rs+2,cs+s-2,rs+s-2,10)
        end
      end
    end
  end
end


__gfx__
00000000600550065555555005555555000001000100010000000000000000000010000000000010111111100101111190055009940550494005500400000000
00000000077777705dd55dd55ddd5dd11001001012101000100333000000001000100000010011c1115515511515515104444440494444940444444000000000
007007000667776051111dd55ddd1111012000100100001000311b300033300011c1000000000010100005510115500104999940049999400415514000077000
000770005661716511111111551111550010112101001121003111300311b300001001000010000000000000000000005111c7155111c71554511545007aa900
000770005777777515511111111111110100001000010010003111300311130000100000001000100000000000000000544444455449994554511545009a9900
00700700011777101551111111111551000010010120000000033300031113000000010011c10100010110010111001001114410049111900415514000099000
000000000116661011111151115515510101210010011000000000000033300000101c1100100000000110000111000001111110491111940444444000000000
00000000600550060011111011111110000010000000010000100000000000100000010000100000000000000000000090055009940550494005500400000000
00000000060550060441141004504450200000022000000280000008011101100551111055511110000000000000000009055009940550494005500400000000
05555550057777705445145154514551016666100166661001666610144514515d1111515dd15511011000000011011004144440441444940444411000000000
05000050066177605555155155515511067226600678866006788660544515515d1111115dd15511011000100000011004119940041149400415114000000000
05055050516771651111511115111110062412600687a8600684186055511111551111115511551100000000000000005111c7155911c7955451154500000000
0505505051777775144114510111455106211250068aa85006811850151144515dd1111155111111000000000000000051144445544991455451154500000000
05000050011771105445151115511111055225500558855005588550111155115dd115515dd11111000000000000000004114100049114100411514000000000
05555550016161101151111111111111015555100155551001555510155111115dd115515dd11511000000000000000004111110441114144114444000000000
00000000600550600111011001101110200000022000000280000008011101105551111005511110000000000000000090055090940550490005500400000000
00000000000000000000005000000000000000000000000000077770000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000500000056000000050000077700000006000666660000056500000565000000060000022500000000000000051000005510000000000005500
0000005500000560000005600000656000007770000000500000060000006060000060600000656000067776000053550000057c0005577c0000000500000660
000000050000057500000575000005750000777500066665000005550000707500607075007575750000028500007b660000066c0006666c0000066500005665
000000050000057500000575000005750000666500777775000005550000607500707075005565650000028500007b660000056c0005566c0000777500005665
00000055000005600000056000006560000066600000005000000600000000600060606000006560000677760000535500000551000555510000000500000770
00000000000000500000056000000050000066600000006000666660000000500006505000000060000022500000000000000051000005510000000000005500
00000000000000000000005000000000000000000000000000077770000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000007000006000060000000000067600000075000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000007600076000067000000000600000000055000006006000000000000000000005655000000000000000000
00000000000000000000000000600600077766600007600076000067000676500567765000676600027007200057750000000000005655000007000005055050
0000000000555500055555500055550007776660000760007665566700000060000000600055550002722720003bb30000565500057665500007600005766650
00500500056776505667766505677650077766600657656076055067056776500567765006676660057887500056650005766550057665500007600000766600
00555500000550000005500000055000000550000005500000055000000550000005500000055000006556000056650001ccc11001ccc1100055550000055000
00089998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555555555555551101155555555
088aa79900008899000000880000008800000008000000000000000000000000000000000000000000000000000000005ddd55dd5dd5ddd55dd110515dddddd5
8aa7777a008899aa0000889a0000089900000089000000080000000000000000000000001000000000011000000000015d000000000000d55dd110515dd11dd5
aa777777889aa77700889a77000089a70000089a0000008900000000000000000000000010101010101111010101010111011111111110115d11105111111111
aa777777889aa77700889a77000089a70000089a000000890000000000000000000000000010101010100101010101001501d111111d10115d11105111111111
8aa7777a008899aa0000889a00000899000000890000000800000000000000000000000010000000000110000000000111011dddddd110555dd1105100000000
088aa79900008899000000880000008800000008000000000000000000000000000000000000000000000000000000001101155ddd5110115dd1105115555551
00089998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011011551d15110115551101111111111
008aa800000880000000000000000000000000000000000000000000000000000000000000000000000000000011010015011dddddd110155555555555555555
08aaaa8000088000000000000000000000000000000000000000000000000000000000000000000001111110000000001101111ddd1110115dddddd55dddddd5
08a77a80008998000008800000000000000000000000000000000000000000000000000000000000011111100001100051011115551110115dd111d55d0000d5
8a7777a8008aa800000880000000000000000000000000000000000000000000000000000000000001111110000000001101d111111d10111111111115000051
9a7777a9089aa9800089980000088000000000000000000000000000000000000000000000000000010110100001100011011111111110111111111115000051
9777777908977980008aa80000899800000880000000000000000000000000000000000000000000010000100000000011000000000000111511155115000051
9977779909a77a9008977980089aa980008998000008800000000000000000000000000000000000011111100001100055511111111115551555555115555551
89a77a9809a77a9008a77a8008977980089aa9800089980000000000000000000000000000000000000000000000000055515551155115551111111111111111
00066600000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000199999999999999100000000
000666000077775000000000000000000000000000000000000000000000000000000000000000000111111000000000000000004aaaaaaaaaaaaaa400000000
000666000006666500000000000000000000000000000000000000000000000000000000000000000111001000011000000000004aaaaaaaaaaaaaa400000000
00566656000000500000000000000000000000000000000000000000000000000000000000000000011110100011010000000000499999999999999400000000
00577756000000500000000000000000000000000000000000000000000000000000000000000000011110100011010000000000499999999999999400000000
00077700007777750000000000000000000000000000000000000000000000000000000000000000011100100001100000000000594999994499499500000000
00077700000666500000000000000000000000000000000000000000000000000000000000000000011111100000000000000000555555555555555500000000
00077700000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000111111111111111100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014aaa4aaaa4aaa4100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000449995911959994400000000
00055000070007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000459995911959995400000000
77776666076007600000000000000000000000000000000000000000000000000000000000000000000000000001100000000000459995999959995400000000
77776666076007600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000459995999959995400000000
77776666076007600000000000000000000000000000000000000000000000000000000000000000000000000001100000000000559999999999995500000000
00055000056557500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155995599559955100000000
00066000005005000000000000000000000000000000000000000000000000000000000000000000000000000011010000000000111551155115511100000000
f5309090000000d000000000803020f5213131000000000021000000000021212171210000000031000000000071317150500000000000000000000000005050
8090000000909080908090000000908021310000000000000000000000003121713100000000000000000000008090f020303020203021000000000000313020
9190808090800000000080009080e581717100713100000000000000000000213121006000007100000000000000712150000000000000000000000000000050
90000000000000000000000000000080210000000000000000000000000000317121000000000000000000000080809081b0b0b0a02091000000000000007120
3090909030f4f4f4f4f4308090800091310000000000213100000000000000003100f00000000000000000000060003100000050505000000000005050000000
00000000000000000000000000000000000000000000000000000000000000002131000000000000000000008080908091b0a1b1a1a081000000000000000031
90809020302020303020203080908030212100f00021000000000000600000210000000000000000000000210000000000005000000000000000000000500000
0000008090900000000090809000000000000000000000000000000030000000210000000000c000000000709080000081a0a1a1b1a09121000000c000000000
00908191800000908090808181800000210000000000000000000000000000310000310000000000000000007100000000005000000000000000000000500000
0000009060800000000090708000000000000000000000000000000020000000000000000000000000000080808060003020b0a1a1a020300000000000000000
0000e4810000000000418081e4900000003121000000002100210000000021000021000000c0000000000000000000000000500000f000000000c00000500000
8000008090800000000080809000009000000000000000000000000030000000000000000000000000008080900000002130a0a0b0a0a1300000000000000000
d000e49100d6e600f5008091e4000000000000000071000000000000210000000000000000000000000000000000000000000000000000505000000000000000
9000000000000000000000000000008000000000000000000000000030000000000000000000000000809080000000000030302030303030306000f000000000
0000e49100d7e70081009091e400d000210071310000007090600000710000210000000000000000000000000000000050000000000050607050000000000050
80000000000000c00000000000000080000000000000000000000060203000000000000090f09080808080800000000000000000213120b03031600000000000
800030f4f4f4f4f430808081e40000003100003100000040c0800000000000710071000000000000000000000000000050000000000050706050000000000050
9000000000000000f0000000000000800000000000000000c000310020200000603121303020202030308080000000000000000000702130a030700000000000
900080809080000080419081e4800000000000710000007050600000000000000000310000000000c00000000000310000000000000000505000000000000000
90000000000000000000000000000090000000000000000000f000602030000021302020a0b0b0a0a030309000000000000000000000006030b0302100000000
8080909080000080908080918180900000310000000000000000000000000000000000000000000000007100000000310000500000c000000000f00000500000
8000009080900000000080909000008000000000000000003100217030a0300030a0a0a1b1b1a1b1b03020800000c000000000000000f0003130203000000000
3090900030302020303020a030809030210000000000210000000000210000000000000000000000000000310000000000005000000000000000000000500000
0000009070900000000090608000000000000000000060007060706030a0200020a0b1b1a1a1b1b1a03020900000000000000000c0000000602171e500000000
919090000020f4f4f4f4f43090909081000000007000000000000000000000003100006000000000000000000000000000005000000000000000000000500000
00000090909000000000809090000000000000302020303020203030a0b130302030a0b0b0a0b0a0303030900000000000000000000000000000000000000000
302080000000000000000090908090810000000000000000003171000000f00031710000000000000000000070f0002100000050505000000000505050000000
00000000000000000000000000000000000000000000000030302030a0b1a0303020202020303030303021000000000000000000000000000000000000316031
91919000000000d00000000000903020312100000000000000000000000000217171310000002100000000000000217150000000000000000000000000000050
900000000000000000000000000000903100000000000000000000003020a0202020303030000000700000000000000020210000000000000000000000607131
f53020000000000000000000003020f5000021000031310000000021310031317171213100000031000000000031713150500000000000000000000000005050
80800000009090808090800000009080213100000000000000000000000030303030f00000000000000000000000000030300000000000000000000000217121
00000000000000000000000000000000f5f4000000000000000000000000f4f50000000000000000000000000000000000000000000000303000000000000000
71710000002030000000002020203020312100003100210000003020202030200000000000000000000000712100000000000000000000000000000000000000
00000000000000000000000000000000e42000000000000000000000000030e40000000000000000000000000000000000000000003171202000000000000000
310000000000000000000030a0b0b1912100000000000000203020b0b0b0a0910000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000003131303000000000000000
0000003100007000710000603030b081000000000000000020b0b0b1a1b1b0200000000000000000000000000000000000000000000000000000000000c00000
00000000000000210000000000000000000000213191000000008121210000000000000000000000000000000000000000000000713030b03021000000000000
0000000000000000000031000081a08100000000000000002181f4f4f4f4f5200000007100002171000021000000000000000000000070000000000000000000
0000000000000000000000000000000000000021f0e400000000e4602100000000003121f00060000000000000700000000000002130b0a030310000c0000000
00710000000000000000000000e4b0812100000000000000317060f06070e4910000000000000000000000000000000000000000000021302020000000000000
00000000f5307060000000000000000000000030f4300000000020f43000000000313030303021317021312121000000000000000020a0b13000000000000000
000000000000000000000000f0e4a0912100000000000000716000000060e420000000000000000000000000000071000000000000212030a020210000000000
0000000081303160600000000000000000000000000000706000000000000000002120a0a03021212131303030210000000000007030a0b12060000000000000
00000000000000000000310000e4b0910000000000000000210000e00000e49100210000000000000000000000002100000000007020b0a0b0b0216000000000
00000000003171f03100000000000000000000000000602131600000000000003030a0b0a12030303030a0b0a030303000000000f03020a13000000000000000
0000000000c000000000717000e4b0810000000000000000716000000070e4910000000000c000000000000000000000000000002120f4f4f4f4207100000000
00000000000070602171310000000000000000000000703121700000000000003030303030202030a0a0a1a1b0203030000000006071713030f0000000000000
00000000000000000000310000e4b09121000000c0000000317070f06060e4200000000000000000002020303020000000000000000000000000002021000000
0000000000000000702130300000000000000000000000607000000000000000000021002171313030a0a0b03021317100000000707131303021000000000000
00000000000000000000000000e4a08121000000000000002191f4f4f4f4f5200020207000000000003020a0a020200000000000000000f0006000e420000000
00000000000000000081a0e40000000000000030f4300000000020f4300000000000000000312130202030303071000000000000000021303031710000000000
003100000000000000000000f0e4b091000000000000000020b0a1b1a1b130912030306070f000007030a0b1a1b020000000702020200000e00000e430710000
00000000000031000030f4f5000000000000003160e400000000e4f03100000000000000700000713121f021313100000000000000000030a0b0200000000000
00000000000000000000210000e4a091000000000000000081a0a1b1a1a1b09120a0a020306060302020a0a1b1a1a02000002120a1e4006000f000e4a0302100
000000000000000000000000000000000000007121910000000091213100000000000000000000000000006000000000000000c000000030b0b0200000000000
0000002100000000310000700091a081000000000000000081b0a1b1a1b1b02030b0b1202020202020a0b0b1b1b1b02000202020a1e40000000000e4a1202000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007030a020200000000000
0000000000006000000000002030a1810000000000000000302030b0a0a1a09120b0a1b1b0a0a0a0a0b1a1b1a1a1b0203020a1a1a1f5f4f4f4f4f4f5a1b02020
00000000000000000000000000000000e430000000000000000000000000e5e4000000000000c00000000000000000000000000000000020b031210000000000
210000000000000000000030a0a1a19121000021003100000000203030a0a02020a0a0a0b0a03030a0a0a0a0a0b0a020302020a1a1a1a1a1a1a1a1a1a1a12020
00000000000000000000000000000000f5f4000000000000000000000000f4f50000000000000000000000000000000000000000000000303021000000000000
31210000003020000000202020303081712100000000000000000000002030303030202020302020303020303030303020302020f4f4f4f420f4f430f4f4f430
__gff__
0001020224244444848402020808084400018282040000820202020208080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202000000000000000000000000020202020000000000000000000000000014140000000000000000000000000000141400
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1712000000000000000000000000121309080000000000000000000000000909000000031800000000000018030000000203121700001212000012030303030208080409000000080900000008040809121713121712131312171712131317120000000000000018190000000000000002030000000000000000001903020302
121400140000000000000000140014120800000000000000000000000000000800000003190000000000001903000000021700000013000000000000000012020905080000000805050900000009050813000000000000131300000000000012000000080000094e4e000000000000000302000000000000000000180a0b0b03
000000000000001217000000000000000000080809090808080808080808000000005f02190000000d000018035f0000120000140000000017120014000000120409000009091404041408090000090417000000000000171200000000000017000800000000084e4e00000000000000030200000000000d0000001809000000
00140000000000131200000000001400000009080809090808080908090800000303020000000000000000000002030300130000000000000000000000000017080000080800000405000009080000081300000d00000013130000000d000013000000000000094e4e0700000000000002030000000000000000001808001400
000000000d0000171300000c00000000000008080909080908080908080900000303020000000000000000000002030300000000000d000000001300001400000000080900001405051400000809000013000000000000171700000000000013000900000c08084e4e07000c0000000000000000000000000000001808000000
0000000000000f12130000000000000000000809090809090808090808090000000000000000001217000f00000000000000140000000000000000000000001300000800000000040500000000090000130000000000061312060f00000000130000000008090819180606000000000000000008081805050504191909001400
0000000000000712170600000000000000000809080900000000090808080000000000000000131414120000000000001200000006000000000007000000000000081400140014040514001400140800120000000007071213060700000000120000080908080f0a0b0f06070600000000140009084e050707054e1908000000
00001312121713060712121713120000000008090908000d0d0009090908000000000c0000121406061417000000000017000000000000070000000000000017080504050405040d0f0405050504040812131313171217131713121713121317034f4f4f4f030a1b1a0a034f4f4f4f0300000000084e06060f074e0809001400
00001217121213070613171317120000000008080808000d0d00080809080000000000000013140606141200000c000013000000000007001400000000140013090505040505040f0e0404050405050913121312131212131213131317131312024f4f4f4f030a1a1b0b034f4f4f4f0300140008084e060f06064e0908000000
000000000000061313070000000000000000080808080000000009080909000000000000000017141412000000000000001200000000000000000000000000000008140014001404051400140014080012000000000706131707060000000017140014001400140b0b0404040500050000000008094e050607054e0808001400
0000000000000012130f0000000000000000080808080908080808080808000000000000000f00131200000000000000000017130006000006000000000000120000090000000005050000000008000012000000000f071712060000000000120000000000000018190405050000000000140009081805040504180900000000
000000000c0000171700000d00000000000008090908090909090909080800000303020000000000000000000002030300000f00001200000000000d000000170000080800001404051400000909000013000000000000131300000000000017000014000c00144e4e05000c0004000000000008081900000000000000001819
0014000000000012120000000000140000000808090908080808080908080000030302000000000000000000000203031200000e000000000000000000000012090000080900000405000008080000081200000d00000013120000000d000013000000000000004e4e0000000000050000140009001900000000000000004e19
000000000000001317000000000000000000080808090909080908080809000000005f021900000d00000018025f0000130000000f00140017000000140000170509000009091404041409090000090412000000000000131200000000000013000014001400144e4e0500000400000000000008185f00000d00000000004e19
121400140000000000000000140014120900000000000000000000000000000800000003180000000000001903000000021200000000000000000000000012020805090000000805040800000008040917000000000000171200000000000012000000000000004e4e00000000000000020a0b0b180000000000000000004e18
1712000000000000000000000000131708090000000000000000000000000809000000031900000000000018030000000317001217120000000012000012030308080509000000090800000008040908121213171212121213121313171312120000000000001418190000000000000003020303190000000000000000001919
4c4d4f5f4f5f025e034f494a4a4b035f000000000000000000000000000000000404000400000000000000000000040404040000040000000000000000000400000000000000000000000000000000000203030308080000000c0000000000005f03090809000004050000090908035f00000000000000000000000000000000
5c5d494a4a4b5e4e020000000000000200000000000000000000000000000000040000000000000000000000000004040400000000000000000000040000000400000000000000000000000000000000030303030808080000000000000000000208080800000502030400000908090200000000000000000000000000000000
4e5b00000000004e000000000000005b00005f4f494a4b4f4f494a4b4f5f000000005f0203121713000004040004000000000000000000000000000000000000000000000000000000000000000d00000000020208090809000000001200000009090900000705030205070000090809000000034f4f02171200001303000000
5f6b000000000017000000004e00006b00004e5e494a4b0303494a4b5e4e0000000019070700000000000000040000000000000004040404000000000000040000000000000000000000000000000000000003030908080803030303031200000908000f050417020213040500000908000003034f4f02031700140002030000
4e6b000001000012000700004e00006b00005b5b00000000000000005b5b0000000018070f0000000008080800040000000000040f07000004040000000000000000000000000000000203000000000000000202080809080712171203021200080000050303020b0a03031305000009000000000000031913000000194e0000
5f7b000000000000000000000000006a00006b6b00000000000000006b6b000000001200000c00000908080000040000000000040706070000000000000000000000000000000000020a0a03000000000000020308080809080806171703170000000704020b0a1a1a0b0b0204060000000000001400031919000007184e0000
025e000000001200000000070000006b00007b7b00000000000000007b7b000000001300000009000800080000000000000000040007000000000004000000000000000000000012021b0a0200000000000003031209080809090f071202000000050413020a1a1a1b1a0a0213040500000013000000190007000000184e0000
5e4f4f1217000007000000000013006b00004e190000000d00000000194e000000001700000000080809000000000000000000040000000c0000000004000000000000080000091703030200000000000000030203170808080e080806030000040203020b1a1b0a1b1a1a0b02030304000019000012181400170f06194e0000
0302000000000000000000000017006b00004e18000000000f000000184e00000000000000000908090000000000000000000000040000000c000700040000000000000807001217121712000000000000000003031217080f09080808030000050302030a1a1b1a0b1b1a0a0202020500004e001307180e07000607194e0000
4e00000000070000000600120000006b00005b5b00000000000000005b5b000000000400000008080009000000130000000000000400000000000000040000000007000f0917081209080000000000000000000002031206090808090302000000040513020a1a1b1b1a0b020304050000004e001400190f0014030303020000
5b00000000000000000000000013006b00006b6b00000000000000006b6b0000000004000000080000000c000017000000000000040000000007070004000000000006081709090000000000000000000000000000030312080908080303000000000705030a0b1a1a0b0a030406000000004e00000607000c00130014000000
6b000000000000000013000e0000006a00007b7b00000000000000007b7b000000000000000808000000000f07030000000000000400000700070f04000000001200080808120807000000000000000000000000000703170808090802030000090000041702030b0b03021705000009000018070f0600140007000000000000
6b00004f4f000000000000000f17006b00004e5e494a4b0303494a4b5e4e0000000004040400000000000007074e0000000000000004000000040400000000001709120912080f00060000000000000000000c000000031217070809030300000809000005041303021305040f00090800000218140007170000140000170000
7b00000000000017130012001217007b00005f4f494a4b4f4f494a4b4f5f00000400040004040400001213034f5f00040000000000000000040000000004000012120812080600000000000000020a020000000000000203121209080202020308080800000705020305060000090908000000034f4f4f4f4f4f4f4f03000000
03000000000000000000000000000002000000000000000000000000000000000400000000000000000000000000000404000000000000040000000000000000121712090000000000000000000b0302000000000000000608090808030302020209080900000402030400000808090200000000000000000000000000000000
5f02494a5a4a4a4a4a4a4a5a4a4b035f00000000000000000000000000000000040400040000000000000000000404040404000400000000000000000000040412171212000000000000000000020303000000000000000000080908080003035f03080908000004050000080909035f00000000000000000000000000000000
__sfx__
000100000261003610046200362002610016100061000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000063100b3200c6300963006620056200261000610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000091200c130116300f6300c630086200561003610016100061000610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000276502064022630246402562026600276402762027630276402663025600246102363022620206301e6101c610196201662014610126200f6100d6100a60008610076100561004610036000261002610
00020000296502024022630252402562026640276402522027630276402663025620222402363022620206301e6101c610106201462016610136200f6100d6100a600086100b6100c61004610036000261002610
000200002965013040226300e0402562008040276400f02027630276400a030256200a0402363022620060301e61007010106200502016610136200f610040100a600086100b6100301004610036000261002610
00040000366502e240366302c2403462026140306301d2202c63013540276300a52022640035301b6200053015610126100f6000d6200a6100860007610056100463003610026000161000600006100060000500
000200001063006620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001563011240116200760004210036100061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000156500b340116200760004610036100061000000000000261001620006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000186500e320053300b65004610036100061000000000000261001620006100000000000026200061000610000000000004610006100061000000000000000000000000000000000000000000000000000
000300002365013320013300b65004610036100061000000000000263002620006100000000000026200263000610000000000004610006200061000000000000000001620016200000000000026000060000000
00030000236400b420134301064008430036200061000000000000143002600026300062000000024200260000610006100000003420006000062000000000000261000410016100000000000024100061000000
000300000f52007420025100252009420115200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000090400503002030000200002002030075400d540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000a7400f730127301433016740177401835017740177401543014720137200e4200e7300b7300974006730037200372002720037200473005740067200571004710027200172000730007300072000710
000200000903004010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000051009000256002460023600216001e6001a60017600126000d6000a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000552014030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e00000e040080200e0400802000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000012720000001a7301d70019720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001764026600370203702000000000003704037040000003700037020370200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002b65018340306301a340276202365027640276302a63027640266300f350083102363022620286301e6101c61010620063201461012620176100d6100510008610076100a61004610036000961002610
000400002c520335203a0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
