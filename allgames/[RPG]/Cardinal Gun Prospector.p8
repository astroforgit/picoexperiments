pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--rog
--by 

--Utils
-- globals

-- lookup
keydir={
  [0]={x=-1,y=0},[1]={x=1,y=0},[2]={x=0,y=-1},[3]={x=0,y=1},[-1]={x=0,y=0}
}
lite_init=4
lite_max=9
fuel_get=20
cartdata(0)
best,new_best=dget(0),false
fuel_max=400
--fuel_max=5
loot_deck_size=30
mw,mh=128,128
hp_max=4

state="wait"
turn_f=0
turn_c=0
anim2=false
--add to print out debug
debug = {}
debug_draw = {}
can_rotate_gun=false

camtween=nil

-- screen shake offset
shkx,shky = 0,0
-- screen shake speed
shkdelay,shkxt,shkyt=2,2,2

-- recursive shadow casting
-- adapted from https://www.lexaloffle.com/bbs/?pid=28780 by cheepicus

visible={}
corona={}
corona_v=0.18

function do_fov(x,y,r)
  visible={[x..","..y]=true}
  corona={}
  local p={x=x,y=y}
  for oct=0,7 do
   fov(p,1,0,1,oct,r)
  end
end

function fov(p,d,lo_slp,hi_slp,oct,r)
  -- distance, height from player
  -- to map xy
  -- flips/transposes per octant
  function dhtoxy(d,h)
   local x,y=p.x,p.y
   if band(oct,0x1)>0 then d=-d end
   if band(oct,0x2)>0 then h=-h end
   if band(oct,0x4)>0 then 
    return x+h,y+d
   end
   return x+d,y+h
  end

  if d>r then
   return
  end
  local mapx,mapy,lo,hi
  local in_gap
  lo=flr(lo_slp*d+0.5)
  hi=flr(hi_slp*d+0.5)

  for h=lo,hi do
   mapx,mapy=dhtoxy(d,h)
   
   local dist=dist_to(p.x,p.y,mapx,mapy)
   if dist<r then
    visible[mapx..","..mapy]=true
    if dist>r-1.5 then corona[mapx..","..mapy]=true end
   end
   
   if is_opaque(mapx,mapy) then
    if in_gap then
     -- reached end of gap
     fov(p,d+1,lo_slp,(h-0.5)/d,oct,r)
    end
    lo_slp=(h+0.5)/d
    in_gap=false
   else
    in_gap=true
    if h==hi then
     -- end of gap
     fov(p,d+1,lo_slp,hi_slp,oct,r)
    end
   end
  end
end

--returns 0 at high distances due to overflow
function dist_to(ax,ay,bx,by)
  local vx,vy=ax-bx,ay-by
  return sqrt(vx*vx+vy*vy)
end


function is_opaque(x,y)
  local w=walls[x..","..y]
  if w and w~=1 then return false end
  return true
end



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
      s = s..","..i
    end
  end
  return s
end

function pick1(a,b)
  if rnd(2)>1 then
    return a
  end
  return b
end

--print to debug
function debugp(...)
  add(debug,joinstr(...))
end
--draw to debug
function debugd(p)
  add(debug_draw,p)
end

function add2(obj, ...)
  local args = {...}
  for table in all(args) do
    add(table, obj)
  end
end

-- method is a function(c,r)
function forinrect(x,y,w,h,method)
  for c=x,(x+w)-1 do
    for r=y,(y+h)-1 do
      method(c,r)
    end
  end
end

function fadepal(val)--0 to 1
  local p=flr(mid(0,val,1)*100)
  local kmax,col,dpal,j,k
  dpal={0,1,1, 2,1,13,6,
           4,4,9,3, 13,1,13,14}
  for j=1,15 do
   col = j
   kmax=(p+(j*1.46))/22
   for k=1,kmax do
    col=dpal[col]
   end
   if j==12 then backcol=col end--set background col
   pal(j,col)
  end
end

function shuffle(v)
  local j,x
  for i=#v,1,-1 do
    j=rng1(i)
    x=v[i]
    v[i]=v[j]
    v[j]=x
  end
  return v
end

function digits(n,total)
  local s=""..n
  while #s<total do
    s="0"..s
  end
  return s
end

function rng(n)
  return flr(rnd(n))
end

function rng1(n)
  return 1+flr(rnd(n))
end



--tween a position - used for camera pans
tween = class()
-- sx,sy: start tx,ty:target, method:easing function, delay:total frames
function tween:init(sx,sy,tx,ty,method,delay)
  self.x,self.y,self.sx,self.sy=sx,sy,sx,sy
  self.cx,self.cy,self.method,self.t,self.delay=tx-sx,ty-sy,method,0,delay
  self.done = false
end

function tween:upd()
  self.t+=1
  if(self.t >= self.delay) self.done = true
  self.x=self.method(self.t,self.sx,self.cx,self.delay)
  self.y=self.method(self.t,self.sy,self.cy,self.delay)
end
--http://gizma.com/easing/
--time,startvalue,change,duration
function ease_linear(t,b,c,d)
  return c*t/d+b
end
function ease_nope(t,b,c,d)
  if t>d*0.5 then
    return c*(d-t)/d+b
  else
    return c*t/d+b
  end
end

--Game
function _init()
  new_game()
end

function new_game()
  turn_f=0
  turn_c=0
  frame_c=0
  new_map()
  
  init_prefabs()
  
  log_say("welcome c.g.prospector",13)
end

function new_map()
  local inset=1
  walls={}
  effects={}
  dngr={}
  loot={}
  us_shot={}
  them_shot={}
  spawns={}
  dig_border(0,0,mw-1,mh-1,function(x,y,n) set_wall(x,y,1) end)
  
  start={x=flr(mw/2),y=flr(mh/2)}
  local x,y,size=start.x,start.y,2
  dig_rect(x-size,y-size,x+size,x+size)
  fill_loot_deck(loot_deck_size)
  
  home={
    [_k(x-1,y-1)]=128,
    [_k(x,y-1)]=129,
    [_k(x+1,y-1)]=130,
    [_k(x-1,y)]=144,
    [_k(x,y)]=145,
    [_k(x+1,y)]=146,
    [_k(x-1,y+1)]=160,
    [_k(x,y+1)]=161,
    [_k(x+1,y+1)]=162
  }
  plyr=ent(x,y,3)
  plyr.lite,plyr.gp,plyr.fuel,plyr.hp=lite_init,0,fuel_max/2,hp_max
  plyr.gun_c=0
  plyr.ally=true
  dig_rect(x-1,y-1,x+1,y+1)
  
  --plyr.guns[0]=3
  --plyr.guns[1]=2
  --plyr.guns[2]=2
  --plyr.guns[3]=3
  
  loot[(x+2)..","..y+1]={5}
  --loot[(x+2)..","..y]={11}
  --set_wall(x+3,y,mon(x+3,y,12))
  
  set_wall(x,y,plyr)
  
  do_fov(x,y,plyr.lite)
  them={}
  paths=get_paths({plyr},plyr.lite+1,them)
  state="wait"
end



function _update()
  if state=="wait" then
    state_wait()
  elseif state=="us_anim" then
    state_us_anim()
  elseif state=="them_anim" then
    state_them_anim()
  elseif state=="death" then
    if not key_held and (btn(4) or btn(5)) then
      if death_gap<20 then
        new_game()
      end
    end
    if not (btn(4) or btn(5)) then
      key_held=false
    end
  end
  frame_c+=1
  anim2=frame_c%16>10
end

function state_wait()
  local bp=-1
  if(btnp(0)) bp=0
  if(btnp(1)) bp=1
  if(btnp(2)) bp=2
  if(btnp(3)) bp=3
  if(btnp(4)) bp=4
  if(btnp(5)) bp=5

  if bp>=0 and bp<=3 then
    plyr.nope=false
    local d=keydir[bp]
    local px,py=plyr:campos()
    plyr.ob=plyr:move(plyr.x+d.x,plyr.y+d.y)
    if plyr.ob then
      if plyr.ob~=0 then
        plyr.nope=true
      else
        local x,y=plyr:campos()
        camtween=tween(px,py,x,y,ease_linear,8)
      end
      if not plyr.nope then
        plyr.dn=bp
      end
    else
      plyr.nope=true
    end
    go_us_anim()
    
  elseif bp==4 or bp==5 then
    
    for i=0,3 do
      local g,d=plyr.guns[i],keydir[i]
      if g then
        local b=bullet(plyr.x,plyr.y,i,g,true)
        add(us_shot,b)
        sfx(b_sfx[g])
        plyr.nope=false
        plyr.gun_c=0
      end
    end
    go_us_anim()
    
    
    
  -- debug rotate gun
  elseif bp==5 then
    if can_rotate_gun then
      local tmp={}
      for i=0,3 do
        tmp[i]=plyr.guns[i]
      end
      for i=0,3 do
        plyr.guns[i]=tmp[(i+1)%4]
      end
    end
    
  end
end

function go_us_anim()
  if not plyr.nope then
    do_fov(plyr.x,plyr.y,plyr.lite)
    them={}
    --fill 'them'
    paths=get_paths({plyr},plyr.lite+1,them)
    --need to get homing bullet paths
    paths=get_paths(them,plyr.lite+1)
    --activate player bullets
    for e in all(us_shot) do
      if e.active then e:act() end
    end
  else
    sfx(18)
  end
  turn_f=4
  state="us_anim"
  state_us_anim()
end

function state_us_anim()
  if turn_f>0 then
    turn_f-=1
  else
    --has the player moved?
    if not plyr.nope then
      --get loot
      local k=plyr.x..","..plyr.y
      local stuff,got_fuel=loot[k],false
      if stuff then
        loot[k]=nil
        for n in all(stuff) do
          --gold
          if n==1 then
            plyr.gp+=1
            log_say("+1 gold",9)
            sfx(5)
          --fuel
          elseif n==2 then
            plyr.fuel,got_fuel=min(plyr.fuel+fuel_get,fuel_max),true
            log_say("+"..fuel_get.." fuel",3)
            sfx(4)
          --health
          elseif n==3 then
            if plyr.hp>=hp_max then
              drop_loot(plyr.x,plyr.y,3)
            else
              plyr.hp+=1
              log_say("restored health",8)
              sfx(15)
            end
          --light
          elseif n==4 then
            if plyr.lite<lite_max then
              plyr.lite+=1
              log_say("increased light",7)
              sfx(16)
            end
          --guns
          elseif n>=5 then
            local slot=plyr.guns[plyr.dn]
            if slot then
              drop_loot(plyr.x,plyr.y,slot+4)
            end
            plyr.guns[plyr.dn]=n-4
            log_say("equipped "..b_name[n-4],13)
            sfx(3)
          end
        end
      end
      --hit bullets
      shot_chk()
      do_fov(plyr.x,plyr.y,plyr.lite)
      
      if not got_fuel then
        plyr.fuel-=1
        if plyr.fuel==fuel_get*2 then
          log_say("low fuel!",11)
        end
      end
        
      local alive=plyr.active and plyr.fuel>0
      
      if alive then
        --get paths to player, refill them
        them={}
        paths=get_paths({plyr},plyr.lite+1,them)
        --activate enemy
        spawns={}
        for e in all(them) do
          if e.active then e:act() end
        end
        --add spawns to list
        for e in all(spawns) do
          add(them,e)
        end
        if #spawns>0 then sfx(19) end
        for e in all(them_shot) do
          if e.active then e:act() end
        end
        turn_f=4
        state="them_anim"
      else
        go_death()
        return
      end
    else
      state="wait"
    end
  end
  for e in all(us_shot) do
    e:upd()
  end
  plyr:upd()
  
  if state=="them_anim" then
    state_them_anim()
  end
end

function state_them_anim()
  if turn_f>0 then
    turn_f-=1
  else
    --hit bullets
    shot_chk()
    do_fov(plyr.x,plyr.y,plyr.lite)
    if plyr.active then
      state="wait"
      turn_c+=1
    else
      go_death()
    end
  end
  
  for e in all(them_shot) do
    e:upd()
  end
  for e in all(them) do
    e:upd()
  end
  
  if state=="wait" then
    state_wait()
  end
end

function go_death()
  if plyr.gp>best then
    best=plyr.gp
    new_best=true
    dset(0,best)
  else
    new_best=false
  end
  state="death"
  death_gap=120
  death_cause=(plyr.fuel<=0 and "no fuel" or "death")
  key_held=btn(4) or btn(5)
end

function shot_chk()
  for e in all(us_shot) do
    if(e.active)e:hit_chk()
  end
  us_shot=gc_tbl(us_shot)
  for e in all(them_shot) do
    if(e.active)e:hit_chk()
  end
  them_shot=gc_tbl(them_shot)
end

function gc_tbl(tbl)
  local nu={}
  for e in all(tbl) do
    if e.active then add(nu,e) end
  end
  return nu
end





function _draw()
  cls()
  local camx,camy
  if camtween then
    camtween:upd()
    camx,camy=camtween.x,camtween.y
    if camtween.done then
      camtween=nil
    end
  else
    camx,camy=plyr:campos()
  end
  
  camera(camx+shkx, camy+shky)
  
  forinrect(plyr.x-8,plyr.y-8,17,17,draw_at)
  
  for e in all(us_shot) do
    if e.active and e:visible() then
      e:draw()
    end
  end
  for e in all(them_shot) do
    if e.active and e:visible() then
      e:draw()
    end
  end
  
  for e in all(them) do
    if e.active and e:visible() then
      e:draw()
    end
  end
  
  if plyr.active then
    plyr:draw()
  end
  
  -- draw fx
  pal()
  effects = draw_active(effects)
  
  shake_upd()
  
  -- reset cam for ui
  camera()
  -- death ui
  if state=="death" then
    local dy=64
    rectfill(0,dy-(death_gap+120),128,dy-death_gap,0)
    rectfill(0,dy+death_gap,128,dy+death_gap+120,0)
    if death_gap>16 then
      death_gap-=2
    else
      print("press Ž or — to restart",2,dy+(death_gap+12),6)
    end
    print(death_cause,2,dy-(death_gap+24),7)
    local scr="score:"..plyr.gp
    if new_best then
      scr=scr.." new best!"
    else
      scr=scr.." best:"..best
    end
    print(scr,2,dy-(death_gap+12),7)
    
  end
  -- stats / log
  draw_ui()
  -- print out values added to debug
  local total,ty,good=#debug,0,{}
  for i=1,total do
    local s = debug[i]
    print(s,1,1+ty,7)
    ty += 8
    if(i > total-15) add(good, s)
  end
  debug = good
  -- draw values added to debug_draw
  camera(plyr:campos())
  for p in all(debug_draw) do
    local x,y,c=p.x*8,p.y*8,p.c or 7
    rect(x,y,6+x,6+y,c)
  end
end

function draw_at(x,y,tbl)
  tbl=tbl or walls
  local k,tx,ty=x..","..y,x*8,y*8
  if visible[k] then
    if corona[k] then
      fadepal(corona_v)
    else
      pal()
    end
    local w=tbl[k]
    if w then
      local h=home[k]
      if h then
        spr(h,tx,ty)
      end
      if w==0 then
        if(not h)spr(1,tx,ty)--floor
      elseif w==1 then
        local n=136+((x+y)%8)
        spr(n,tx,ty)--indestructible
      elseif w.draw then
        --an entity, draw the floor
        if not h then
          spr(1,tx,ty)
          --is the monster hiding?
          if not paths[k] and w.active then
            w:draw()
          end
        end
      elseif w.s then
        spr(w.s,tx,ty)
      else
        --unknown
        spr(2,tx,ty)
      end
      if loot[k] then
        for n in all(loot[k]) do
          if n==1 then
            spr(anim2 and 17 or 16,tx,ty)--gold
          elseif n==2 then
            spr(anim2 and 33 or 32,tx,ty)--fuel
          elseif n==3 then
            spr(anim2 and 36 or 35,tx,ty)--health
          elseif n==4 then
            spr(anim2 and 38 or 37,tx,ty)--light
          elseif n>=5 then
            spr(43+n,tx,ty)--gun
          end
        end
      end
      if not got_key and k==key_k then
        spr(32,tx,ty)
      end
    else
      if k==exit_k then
        spr(33,tx,ty)
      else
        --wall, null space
        spr((x+y)%2==0 and 2 or 18,tx,ty)
      end
    end
  else
    --debug digging
    if not walls[k] then
      --rect(tx+1,ty+1,tx+6,ty+6,1)
    end
    --show bounds
    if x<0 or y<0 or x>=mw or y>=mh then
      rectfill(tx+1,ty+1,tx+6,ty+6,1)
    end
  end
  
  --debug pathfinding
  if paths[k] then
    --print(paths[k],tx,ty,11)
  end
  
  
  
end

function draw_ui()
  --stats
  rectfill(0,0,127,7,0)
  line(0,7,128,7,1)
  local x=0
  for i=1,hp_max do
    if i<=plyr.hp then
      spr(131,x,0)
    else
      spr(132,x,0)
    end
    x+=8
  end
  x=52
  spr(134,x,0)
  x+=8
  print(digits(plyr.gp,3),x,2,6)
  x=108
  spr(133,x,0)
  x+=8
  if plyr.fuel>fuel_get or (not anim2) then
    print(digits(plyr.fuel,3),x,2,6)
  end
  --log
  rectfill(0,120,128,128,0)
  line(0,120,128,120,1)
  print(sub(log_str,0,log_c),1,122,log_col)
  if(log_c<#log_str)log_c+=1
end

function log_say(s,c)
  log_str=s
  log_c=1
  log_col=c or 1
end

-- garbage collect drawings on the fly
function draw_active(table)
  local good,i = {},1
  for a in all(table) do
    if a.active then
      a:draw()
      good[i] = a
      i += 1
    end
  end
  return good
end

-- set screen shake
function shake(x,y)
  if(abs(x)>abs(shkx)) shkx,shkxt=x,shkdelay+1
  if(abs(y)>abs(shky)) shky,shkyt=y,shkdelay+1
end
--update screen shake
function shake_upd()
  if shkxt > 0 then
    shkxt-=1
    if shkxt == 0 then
      local sn = sgn(shkx)
      if sn > 0 then
        shkx = -shkx
      else
        shkx= -(shkx+1)
      end
      shkxt=shkdelay
    end
  end
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
ent=class()
entn=0
function ent:init(x,y,sp,ally)
  self.active,self.x,self.y,self.sp=
    true,x or 0,y or 0,sp or 1
  self.flipx,self.flipy=false,false
  self.sx,self.sy=x*8,y*8
  self.tween=nil
  self.ally=ally or false--friendly to the player
  self.hp,self.num_c,self.anim=1,1,true
  self.guns={[0]=false,[1]=false,[2]=false,[3]=false}
  self.anim=true
  entn+=1
  self.n=entn
end
--do your thing
function ent:act()
  local d=self:chase()
  if d then
    local ob=self:move(self.x+d.x,self.y+d.y)
    if ob==plyr then
      self:bump(ob)
    elseif ob~=0 then
      self.tween=nil
    end
  end
end
--update
function ent:upd()
  if self.tween then
    if self.tween.done then self.tween=nil else
      self.tween:upd()
      self.sx,self.sy=self.tween.x,self.tween.y
    end
  end
end
--move
function ent:move(x,y)
  local px,py=self.x,self.y
  local ob=move_entity(self,x,y)
  if ob==0 then
    self.tween=tween(px*8,py*8,x*8,y*8,ease_linear,4)
  else
    self.tween=tween(px*8,py*8,x*8,y*8,ease_nope,4)
  end
  return ob
end
--spawn
function ent:spawn(d)
  local px,py=self.x-d.x,self.y-d.y
  self.tween=tween(px*8,py*8,self.x*8,self.y*8,ease_linear,4)
  self.was_spwn=true
end
--hurt
function ent:hit(source)
  self.hp-=1
  local cx,cy=self:center()
  if self.hp<=0 then
    self.active=false
    set_wall(self.x,self.y,0)
    if self==plyr then
      sfx(12)
      squode(cx,cy,10,12,effects,7)
      shake(0,5)
    else
      sfx(13)
      squode(cx,cy,6,9,effects,10)
      --no camping the spawners
      if (not self.was_spwn) then
        drop_loot(self.x,self.y)
      end
    end
  else
    squode(cx,cy,4,8,effects,14)
    if self==plyr then
      shake(0,4)
      sfx(11)
    else
      sfx(17)
    end
  end
end
--attack
function ent:bump(ob)
  ob:hit()
end

function ent:chase()
  local best=9999
  local dir=0
  for i=0,3,1 do
    local d=keydir[(i+turn_c)%4]--allows kiting
    local p={x=self.x+d.x,y=self.y+d.y}
    local k=p.x..","..p.y
    local dist=paths[k]
    if dist then
      local w=walls[k]
      if w and w~=1 then
        if w==0 or w.ally~=self.ally then
          if dist<best then
            best=dist
            dir=d
          end
        end
      end
    end
  end
  if dir~=0 then return dir end
end

function ent:chase_n()
  local best=9999
  local dir=-1
  for i=0,3,1 do
    local n=(i+turn_c)%4--allows kiting
    local d=keydir[n]
    local p={x=self.x+d.x,y=self.y+d.y}
    local k=p.x..","..p.y
    local dist=paths[k]
    if dist then
      local w=walls[k]
      if w and w~=1 then
        if w==0 or w.ally~=self.ally then
          if dist<best then
            best=dist
            dir=n
          end
        end
      end
    end
  end
  if dir~=-1 then return dir end
end

function ent:campos(offx,offy)
  offx,offy=offx or 0,offy or 0
  return (self.x+offx)*8-60,(self.y+offy)*8-60
end

function ent:visible()
  return visible[self.x..","..self.y]
end

function ent:liting()
  local k=self.x..","..self.y
  if corona[k] then
    fadepal(corona_v)
  else
    pal()
  end
end

function ent:center()
  return 4+self.x*8,4+self.y*8
end

--draw
function ent:draw(sp)
  self:liting()
  local x,y=self.sx,self.sy
  for i=0,3 do
    local g,d=self.guns[i],keydir[i]
    if g then
      spr(47+g,x+d.x*3,y+d.y*3)
    end
  end
  if self==plyr then
    --176-191, total=15
    sp=176
    local n=plyr.gun_c
    if n<=18 then
      sp+=n
      plyr.gun_c+=1
    end
  else
    sp=sp or self.sp
    if(self.anim and anim2)sp+=16
  end
  spr(sp,x,y,1,1,self.flipx,self.flipy)
  
end


mon=ent:extend()
--[[
ids
1: basic
2: 2hp
3: waller
4: burst
5: miner
6-9: turret
10: spawner
11: shooter
12: spawner 2hp
--]]
mon_spwn={1,1,1,3,3,2,2,2,5,5,5,6,6,11,11,11,4}
mon_sp={[1]=5,[2]=6,[3]=7,[4]=12,[5]=13,[6]=8,[7]=9,[8]=10,[9]=11,[10]=14,[11]=15,[12]=135}
function mon:init(x,y,id)
  --promote spawner to 2hp in late game
  if(id==10 and prefab_c>30)id=12
  ent.init(self,x,y,mon_sp[id])
  self.id=id
  self.hp=(id==2 or id==12) and 2 or 1
  if(id==10 or id==12)self.spwn_id=mon_spwn[min(1+flr(prefab_c/3),#mon_spwn)]
end

function mon:act()
  local id=self.id
  --shooter
  if id==11 then
    if turn_c%2==0 then
      local dn=self:chase_n()
      if dn then
        self:shoot(dn)
        self.tween=nil
        return
      end
    end
  --spawner
  elseif id==10 or id==12 then
    self.tween=nil
    if turn_c%4==0 then
      local d=self:chase()
      if d then
        local x,y=self.x+d.x,self.y+d.y
        local ob=get_wall(x,y)
        if ob==0 then
          local id=self.spwn_id
          --face turrets in spawn direction
          if id==6 then
            if(d.x==1)id=7
            if(d.y==-1)id=8
            if(d.y==1)id=9
          end
          local e=mon(x,y,id)
          e:spawn(d)
          add(spawns,e)
          set_wall(x,y,e)
          self.tween=tween(self.x*8,self.y*8,x*8,y*8,ease_nope,4)
        elseif ob==plyr then
          self:bump(ob)
        end
      end
    end
    return
  --turret
  elseif id>=6 and id<=9 then
    local d=self.id-6
    if d<=1 then
      if abs(plyr.y-self.y)<=1 and abs(plyr.x-self.x)<=b_t[1]+1 then
        if (d==0 and plyr.x<self.x) or (d==1 and plyr.x>self.x) then self:shoot(d) end
      end
    else
      if abs(plyr.x-self.x)<=1 and abs(plyr.y-self.y)<=b_t[1]+1 then
        if (d==2 and plyr.y<self.y) or (d==3 and plyr.y>self.y) then self:shoot(d) end
      end
    end
    return
  end
  local px,py=self.x,self.y
  ent.act(self)
  if px~=self.x or py~=self.y then
    if id==3 then
      --poop wall
      if not loot[px..","..py] then
        set_wall(px,py,nil)
      end
    elseif id==5 then
      --lay mine
      add(them_shot,bullet(px,py,-1,3,false))
    end
  end
end

function mon:hit()
  ent.hit(self)
  if(self.id==2)self.sp,self.id=mon_sp[1],1
  if(self.id==12)self.sp,self.id=mon_sp[10],10
  if not self.active then
    sfx(10)
    --burster
    if self.id==4 then
      for i=0,3 do
        local b=bullet(self.x,self.y,i,1,false)
        add(them_shot,b)
      end
      local cx,cy=self:center()
      squode(cx,cy,6,14,effects,7)
    end
  end
end

function mon:shoot(d)
  local ammo=self.id==11 and 4 or 1
  add(them_shot,bullet(self.x,self.y,d,ammo,false))
end

function mon:draw()
  if (self.id==10 or self.id==12) and turn_c%4==0 then
    if(self.id==10)ent.draw(self,30)--spawn warning
    if(self.id==12)ent.draw(self,151)--spawn warning
  else
    ent.draw(self)
  end
end


bullet=ent:extend()
--[[
ids
1: basic
2: 2hp
3: mine
4: homing
5: splitter
6: fast
7: split-mine
8: mine-mine
9: dig
--]]

gun_order_list={
  {3,1,9,6,2,8,4,7,5},
  {3,3,1,9,6,6,9,2,8,7,4,5},
  {3,3,1,1,9,6,2,8,7,5,4},
  {3,1,3,1,6,6,2,2,8,8,9,9,4,7,5},
  {3,3,1,1,9,9,6,6,2,2,8,8,4,7,5},
  {3,1,1,9,9,6,2,8,4,7,5},
  {3,3,1,1,9,9,6,2,2,8,8,4,7,5},
  {1,1,3,3,9,6,6,2,2,8,4,5,7},
  {3,3,1,9,6,6,2,8,8,7,5,4},
  {3,1,3,1,9,9,6,2,2,8,4,7,5},
  {3,3,1,1,9,6,6,2,2,8,4,5,7},
  {1,1,3,3,9,6,2,2,8,8,4,7,5},
  {3,3,9,9,6,6,2,2,8,8,4,5,7},
  {3,3,1,9,6,2,2,8,4,7,5}
}
gun_order={3,1,9,2,6,8,4,7,5}
b_left_sp={[1]=64,[2]=68,[3]=98,[4]=96,[5]=100,[6]=70,[7]=102,[8]=104,[9]=72}
be_left_sp={[1]=66,[3]=99,[4]=97}
b_up_sp={[1]=65,[2]=69,[3]=98,[4]=96,[5]=101,[6]=71,[7]=103,[8]=104,[9]=73}
be_up_sp={[1]=67,[3]=99,[4]=97}
b_name={[1]="shot",[2]="pierce",[3]="mines",[4]="homing",[5]="b-shot",[6]="fast",[7]="b-mines",[8]="m-mines",[9]="dig"}
--sound when player shoots
b_sfx={[1]=1,[2]=2,[3]=24,[4]=7,[5]=8,[6]=9,[7]=26,[8]=25,[9]=22}
--bullet life span
b_t={[1]=6,[2]=4,[3]=8,[4]=5,[5]=4,[6]=5,[7]=4,[8]=4,[9]=7}
function bullet:init(x,y,dn,id,ally)
  self.id=id
  ent.init(self,x,y,0,ally)
  if(id==2)self.hp=2
  self.dn,self.t=dn,b_t[id]
  self:setsp()
end

function bullet:setsp()
  local sp,dn,id,left,up=0,self.dn,self.id,b_left_sp,b_up_sp
  if not self.ally then
    left,up=be_left_sp,be_up_sp
  end
  if dn<2 then
    sp=left[id]
    self.flipx=dn==1
  else
    sp=up[id]
    self.flipy=dn==3
  end
  self.sp=sp
end

function bullet:act()
  self.t-=1
  if self.t<=0 then
    self:hit()
    return
  end
  local px,py,d=self.x,self.y,self.dn
  if d then
    d=keydir[d]
    --homing (after turn 1)
    if self.id==4 and self.t<b_t[self.id]-1 then
      local c=self:chase()
      if(c)d=c
    end
    self.x,self.y=px+d.x,py+d.y
    --fast: move again if no hit
    if self.id==6 then
      if not self:hit_chk() then
        self.x+=d.x
        self.y+=d.y
      end
    end
    self.tween=tween(px*8,py*8,self.x*8,self.y*8,ease_linear,4)
    --mine: stop moving
    if self.id==3 or self.id==8 then
      self.mine_dn=self.dn
      self.dn=-1
    end
  end
end

function bullet:hit_chk()
  local x,y=self.x,self.y
  local w=get_wall(x,y)
  if(self.id==9)self:dig()
  if w then
    if w==1 then
      self:hit()
      --sfx(14)
      return true
    elseif w~=0 and w.ally~=self.ally then
      self:hit()
      w:hit()
      return true
    end
  else
    sfx(6)
    local cx,cy=self:center()
    squode(cx,cy,4,5,effects,4)
    self:hit()
    set_wall(x,y,0)
    --spawn cave?
    local dn=self.dn==-1 and self.mine_dn or self.dn
    local bnds=can_cave(x,y,keydir[dn])
    if bnds then
      spawn_cave(bnds)
    end
    return true
  end
  return false
end

function bullet:dig()
  local dir=keydir[self.dn]
  for i=0,3 do
    local d=keydir[i]
    local x,y=self.x+d.x,self.y+d.y
    local w=get_wall(x,y)
    if not w then
      sfx(6)
      squode(4+x*8,4+y*8,4,5,effects,4)
      set_wall(x,y,0)
      --spawn cave?
      local bnds=can_cave(x,y,d)
      if bnds then
        spawn_cave(bnds)
      end
    end
  end
end   

function bullet:hit()
  local cx,cy=self:center()
  squode(cx,cy,3,self.ally and 12 or 14,effects,7)
  self.hp-=1
  if self.hp==0 then
    self.active=false
    --split
    if self.id==5 or self.id==7 or self.id==8 then
      local id=self.id==5 and 1 or 3
      for i=0,3 do
        local b=bullet(self.x,self.y,i,id,self.ally)
        b.t=flr(b.t/2)
        if self.ally then
          add(us_shot,b)
        else
          add(them_shot,b)
        end
        sfx(b_sfx[1])
      end
    end
  else
    if(self.id==2)self.id=1
    self:setsp()
    self.t=flr(b_t[self.id]/2)
  end
end

function bullet:draw()
  self:liting()
  local sp=self.sp
  if self.t==1 then
    fadepal(corona_v)
  else
    pal()
  end
  if anim2 then
    sp+=16
  end
  spr(sp,self.sx,self.sy,1,1,self.flipx,self.flipy)
end


-- just a sprite from the sheet
anim = class()
function anim:init(x,y,sps,t,flipx,track)
  self.active,self.x,self.y,self.sps,self.i,self.t,self.flipx,self.track=
    true,(track and x-track.sx or x),(track and y-track.sy or y),sps,1,t or 0,flipx,track
end
function anim:draw()
  local sp=self.sps[self.i]
  if self.track then
    if(sp)spr(sp,self.x+self.track.x,self.y+self.track.y,1,1,self.flipx)
  else
    if(sp)spr(sp,self.x,self.y,1,1,self.flipx)
  end
  if self.sps[2] then
    self.i+=1
    if self.i>#self.sps then self.i=1 end
  end
  if self.t>0 then
    self.t-=1
    if self.t<=0 then
      self.active=false
    end
  end
end

--square splode
squode = class()
function squode:init(x,y,r,col,tbl,colw)
  self.active,self.x,self.y,self.r,self.t,self.col,self.colw,tbl=
    true,x or 64,y or 64,r or 8,0,col or 7,colw or 7,tbl or effects
  -- add to a list for drawing
  add(tbl, self)
end
function squode:draw()
  local t,x,y,r,col,colw = flr(self.t*0.5),self.x,self.y,self.r,self.col,self.colw
  if t < 2 then
    --full
    squarfill(x,y,r,col)
    squarfill(x,y,r-1,colw)
  else
    --shrink
    if t <= r then
      for rf=t,r do
        if rf==r then
          squar(x,y,rf,col)
        else
          squar(x,y,rf,colw)
        end
      end
    else
      self.active = false
    end
  end
  self.t+=1
end
function squar(x,y,s,c)
  rect(x-s,y-s,-1+x+s,-1+y+s,c)
end
function squarfill(x,y,s,c)
  rectfill(x-s,y-s,-1+x+s,-1+y+s,c)
end



--Dungeon
cave_size=8
cave_look=cave_size+2
function can_cave(x,y,d)
  --1st, there needs to be a through-line from the bullet
  local s={x=x+d.x*2,y=y+d.y*2}
  local p={x=s.x,y=s.y}
  for i=1,cave_look do
    if get_wall(p.x,p.y) then
      return false
    end
    p.x+=d.x
    p.y+=d.y
  end
  --great, now repeat this, stepping sideways
  local left,right={x=d.y,y=-d.x},{x=-d.y,y=d.x}
  size_l,size_r=0,0
  --left
  for j=1,cave_size do
    p={x=s.x+left.x*j,y=s.y+left.y*j}
    --no gaps into other rooms
    if get_wall(p.x-d.x,p.y-d.y) then
      --size_l-=1
      break
    end
    local len
    for i=1,cave_look do
      if get_wall(p.x,p.y) then
        break
      end
      len=i
      p.x+=d.x
      p.y+=d.y
    end
    if len==cave_look then
      size_l+=1
    else
      size_l-=1
      break
    end
  end
  --right
  for j=1,cave_size do
    p={x=s.x+right.x*j,y=s.y+right.y*j}
    --no gaps into other rooms
    if get_wall(p.x-d.x,p.y-d.y) then
      --size_r-=1
      break
    end
    local len
    for i=1,cave_look do
      if get_wall(p.x,p.y) then
        break
      end
      len=i
      p.x+=d.x
      p.y+=d.y
    end
    if len==cave_look then
      size_r+=1
    else
      size_r-=1
      break
    end
  end
  --debugp("arms",size_l,size_r)
  if 1+size_l+size_r>=cave_size+2 then
    --we have room
    local p0={x=s.x+left.x*(size_l-1),y=s.y+left.y*(size_l-1)}
    local p1={x=s.x+right.x*(size_r-1),y=s.y+right.y*(size_r-1)}
    --debugp(p0.x,p0.y,p1.x,p1.y)
    p1.x+=d.x*(cave_size-1)
    p1.y+=d.y*(cave_size-1)
    --p0.c,p1.c=11,11
    --debugd(p0)
    --debugd(p1)
    return {x0=min(p0.x,p1.x),y0=min(p0.y,p1.y),x1=max(p0.x,p1.x),y1=max(p0.y,p1.y)}
  end
  return false
end

function spawn_cave(bnds)
  local w=abs(bnds.x0-bnds.x1)
  local h=abs(bnds.y0-bnds.y1)
  --debugp("size",w,h)
  local x,y=bnds.x0,bnds.y0
  if(w>=cave_size)x+=rng(w-(cave_size-2))
  if(h>=cave_size)y+=rng(h-(cave_size-2))
  --dig_rect(x,y,x+cave_size-1,y+cave_size-1)
  dig_prefab(x,y)
end




--dungeon generator
--create prefabs from the map

--prefabs={{x=1,y=0},{x=2,y=0},{x=3,y=0},{x=4,y=0},{x=5,y=0},{x=6,y=0},{x=7,y=0}}
prefabs={{x=0,y=0}}
prefabs_max=1
prefabs_min=15
prefab_c=0
wall_fab={[0]=0,[34]=1}
mon_fab={[5]=1,[6]=2,[7]=3,[12]=4,[13]=5,[8]=6,[9]=7,[10]=8,[11]=9,[14]=10}
loot_fab={[40]=0,[16]=1,[32]=2,[35]=3,[37]=4,[48]=5,[49]=6,[50]=7,[51]=8,[52]=9,[53]=10}
function init_prefabs()
  prefabs_max=3
  prefabs_min=0
  gun_max=0
  prefab_c=0
  local i,total=0,48
  gun_order=gun_order_list[rng1(#gun_order_list)]
  prefabs={}
  for y=0,4 do
    for x=0,15 do
      if i>0 then
        add(prefabs,{x=x,y=y})
      end
      i+=1
      if(i>=total)break
    end
    if(i>=total)break
  end
  --debugp("total prefabs "..#prefabs)
end

function dig_prefab(c,r)
  --debugp("yo")
  local fn=prefabs_min+rng1(min(#prefabs,prefabs_max-prefabs_min))
  --debugp(prefabs_max,prefabs_min,fn)
  local f=prefabs[fn]
  --debugp(f.x,f.y)
  --local f={x=0,y=0}
  for x=0,cave_size-1 do
    for y=0,cave_size-1 do
      local s=mget(x+f.x*8,y+f.y*8)
      local cx,ry=c+x,r+y
      if wall_fab[s] then
        set_wall(cx,ry,wall_fab[s])
      elseif mon_fab[s] then
        set_wall(cx,ry,mon(cx,ry,mon_fab[s]))
      elseif loot_fab[s] then
        set_wall(cx,ry,0)
        local id=loot_fab[s]
        --random gun
        if id==0 then
          --drop a gun every 3 rooms
          --must be odd number to alternate when 2 rooms spawned
          if prefab_c%3==0 then
            --local g=gun_order[rng1(gun_max)]
            local g=gun_order[1+(gun_max%#gun_order)]
            drop_loot(cx,ry,4+g)
            log_say(b_name[g].." gun nearby x:"..(cx-plyr.x).." y:"..(ry-plyr.y),12)
            sfx(20)
            --debugp(b_name[g])
            --if(gun_max<#gun_order)
            gun_max+=1
          else
            drop_loot(cx,ry,1)--gold
          end
        elseif id==3 then
          --drop a heart every 5 rooms
          if prefab_c%5==0 then
            drop_loot(cx,ry,id)
          else
            drop_loot(cx,ry,2)--fuel
          end
        elseif id==4 then
          --drop a light every 4 rooms
          if plyr.lite<lite_max then
            drop_loot(cx,ry,id)
          else
            drop_loot(cx,ry,2)--gold
          end
        else
          drop_loot(cx,ry,id)
        end
      end
    end
  end
  --increase sel
  if prefabs_max<#prefabs then
    prefabs_max+=1
    prefabs_min=flr(prefabs_max/2)
  end
  prefab_c+=1
end

function populate(start,x0,y0,x1,y1,total,ids)
  local free,n=shuffle(get_free(x0,y0,x1,y1)),0
  for i=1,total do
    local p=free[i+n]
    while dist_to(start.x,start.y,p.x,p.y)<3 and i+n<=#free do
      n+=1
      p=free[i+n]
    end
    set_wall(p.x,p.y,mon(p.x,p.y,ids[1+(i%#ids)]))
  end
end

function dig_rect(x0,y0,x1,y1,func)
  for x=x0,x1 do
    for y=y0,y1 do
      if func then func(x,y,0) else
      set_wall(x,y,0) end
    end
  end
end

function dig_border(x0,y0,x1,y1,func)
  for x=x0,x1 do
    for y=y0,y1 do
      if x==x0 or y==y0 or x==x1 or y==y1 then
        if func then func(x,y,0) else
        set_wall(x,y,0) end
      end
    end
  end
end

function get_free(x0,y0,x1,y1)
  local free={}
  for x=x0,x1 do
    for y=y0,y1 do
      if(get_wall(x,y)==0)add(free,{x=x,y=y})
    end
  end
  return free
end

function spray(x,y,w,h,total,func)
  local tiles={}
  forinrect(x,y,w,h,function(x,y)
    add(tiles,{x=x,y=y})
  end)
  shuffle(tiles)
  for i=1,total do
    local t=tiles[i]
    func(t.x,t.y)
  end
end

function dig_to(x0,y0,x1,y1)
  local x,y,tog=x0,y0,rnd(1)>0.5
  set_wall(x,y,0)
  while x~=x1 or y~=y1 do
    if tog then
      if x>x1 then
        x-=1
      elseif x<x1 then
        x+=1
      end
    else
      if y>y1 then
        y-=1
      elseif y<y1 then
        y+=1
      end
    end
    set_wall(x,y,0)
    tog=not tog
  end
end



function _k(x,y) return x..","..y end
  
function set_wall(x,y,w)
  walls[x..","..y]=w
end
function get_wall(x,y)
  return walls[x..","..y]
end

function move_wall(ax,ay,bx,by)
  local ak,bk=ax..","..ay,bx..","..by
  local tmp=walls[ak]
  walls[ak]=walls[bk]
  walls[bk]=tmp
end

function move_entity(e,x,y)
  local w=get_wall(x,y)
  if w then
    if w==0 then
      move_wall(e.x,e.y,x,y)
      e.x,e.y=x,y
    end
    return w
  end
  return nil
end

function fill_loot_deck(total)
  loot_deck={}
  local gold,fuel=2+rng1(3),total/3
  for i=1,total do
    if i<=gold then
      add(loot_deck,1)
    elseif i<=fuel then
      add(loot_deck,2)
    else
      add(loot_deck,0)--nothing
    end
  end
  shuffle(loot_deck)
end

function drop_loot(x,y,n)
  if not n then
    if(#loot_deck==0)fill_loot_deck(loot_deck_size)
    n=loot_deck[#loot_deck]
    del(loot_deck,n)
  end
  if n>0 then
    if n==4 and plyr.lite>=lite_max then n=1 end
    local k=x..","..y
    if not loot[k] then
      loot[k]={}
    end
    add(loot[k],n)
  end
end

function fill_sq(x,y,r,n)
  local s=1+r*2
  forinrect(x-r,y-r,s,s,function(x,y) walls[x..","..y]=n end)
end

function do_sides(x,y,tbl,func)
  for i=0,3,1 do
    local d=keydir[(i+turn_c)%4]--allows kiting
    local item=tbl[x+d.x..","..y+d.y]
    if item then
      func(item)
    end
  end
end

function get_paths(pts,steps,tbl)
  local q,paths,d={},{},0
  for p in all(pts) do
    add(q,p)
    paths[p.x..","..p.y]=0
  end
  while #q>0 and steps>0 do
    steps-=1
    local c,qi,nextq=#q,1,{}
    while c>0 do
      c-=1
      local n=q[qi]
      qi+=1
      for i=0,3,1 do
        local dir=keydir[i]
        local p={x=n.x+dir.x,y=n.y+dir.y}
        local k=p.x..","..p.y
        local w=walls[k]
        if w and w~=1 and (not paths[k]) then
          paths[k]=d+1
          add(nextq,p)
          if tbl and type(w)=="table" then
            add(tbl,w)
          end
        end
      end
    end
    d+=1
    q,nextq=nextq,{}
    --debugp(#q)
  end
  return paths
end

--within a rect, call function(x,y,dist)
--flooding from all seeds {}
function flood(seeds,x,y,w,h,steps,func)
  local q,vis,d={},{},0
  for p in all(seeds) do
    func(p.x,p.y,0)
    vis[p.x..","..p.y]=true
    add(q,p)
  end
  while #q>0 and steps>0 do
    steps-=1
    local c,qi,nextq=#q,1,{}
    while c>0 do
      c-=1
      local n=q[qi]
      qi+=1
      for i=0,3,1 do
        local dir=keydir[i]
        local p={x=n.x+dir.x,y=n.y+dir.y}
        if p.x>=x and p.y>=y and p.x<x+w and p.y<y+h then
          local k=p.x..","..p.y
          if not vis[k] then
            func(p.x,p.y,d+1)
            vis[k]=true
            add(nextq,p)
          end
        end
      end
    end
    d+=1
    q,nextq=nextq,{}
    --debugp(#q)
  end
end


__gfx__
0000000000000000044444400000000000000000000000000666666008888880222222200222222228eeee822222222200000000088888800000000002888820
000000000500005044444455077777700eeeeee0088ee880778ee87788888882828282a22a282828228ee8222a9229a2008ee8008e8e8ee80888888029288292
0070070000000000444445550d1111d00e2222e028eeee8266eeee6688888822e8e8e892298e8e8e28eeee82228ee82208eeee808e8282888e8228e882888828
000770000000000044444555061cc1600e2aa2e028eeee8211eeee1188882222eeeeee2222eeeeee228ee82228eeee82089ee980882002e88829928888822888
0007700000000000444555550d1cc1d008299280088ee8800611116028822222eeeeee2222eeeeee28eeee82228ee82209a99a908e2002888829928888822888
0070070000000000455555550d111110082222800a2882a00a2222a022222222e8e8e892298e8e8e228ee82228eeee8202988920882828882882288282888882
0000000005000040555555550dddddd00888888008088080080880802a2222a2828282a22a2828282a9229a2228ee822002222002a88e8a22288882229288292
000000000000000005555550000000000000000000000000000000000222222022222220022222220222222028eeee8200000000022222200222222002222220
00000000000000000444444000000000000000000000000000000000000000002222222002222222228ee8222222222208eeee80088888800888888008822880
0077790000aaa90044444445077777700eeeeee0000000000666666008888880282888922988828228eeee822a9229a28eeeeee88e8e8ee88ee888e88a2882a8
077aa7900aaaa790444444550d1111d00e2222e0028ee820778ee877888888828e8ee8a22a8ee8e8228ee822288ee882eaaeeaae8e2228888e89988882822828
0777799007aa799044445555061cc1600e2992e028eeee8266eeee6688888822eeeeee2222eeeeee28eeee8228eeee82a77aa77a888002e8889aa98828200282
0977999009779990445555550d1cc1d0082aa280288ee882118ee81188882222eeeeee2222eeeeee28eeee8228eeee82a77aa77a8e200888889aa98828200282
0999999009999990555555550d111110082222800288882001111110222222228e8ee8a22a8ee8e8288ee882228ee822eaaeeaa8828222282889988282822828
0099990000999900555555550dddddd00888888009288290092222902922229228288892298882822a9229a228eeee828ee88ee82928e292228888222a2882a2
0000000000000000055555500000000000000000000000000000000002222220222222200222222202222220228ee82208822880022222200222222002822820
000000000000000077777777000000000000000000aaaa000066660000aaaa000000000077777777777777770000000000000000000000000ee888e000000000
00033000000bb0007666666108800880000000000a7777a0060000600a0000a0066666607666666d7666666d000000000000000000000000ee99998e00000000
000bb00000033000761111718e888e88008888000a7aa7a0060660600a0000a0060000007600007d766666dd000000000000000000000000e9aaaa9800000000
03b33b300b3bb3b0761dd6718888888808e8e8800a7777a0060000600a0000a0060666607600007d76666ddd00000000000000000000000089a77a9800000000
03b33b300b3bb3b0761d667128888882028888200a7aa7a0060660600a0000a0060660607600007d7666dddd00000000000000000000000089a77a9800000000
000bb00000033000761666710288882000288200005555000055550000555500060000607600007d766ddddd00000000000000000000000089aaaa9800000000
00033000000bb000767777710028820000022000005665000056650000566500066666607677777d76dddddd0000000000000000000000002899998200000000
0000000000000000711111110002200000000000000550000005500000055000000000007ddddddd7ddddddd0000000000000000000000000288882000000000
000000000000000000000000000000001d7777d1001661006d7777d66710017600d66d0000000000000000000000000000000000044444000444440000000000
0000000001d66d100671176001d66d10d667766d00166100d167761d7dd66dd70001100000000000000000000000000000000000455544404555444000000000
00d77d000dd77dd007d66d700d7777d076d77d6711d77d1176dddd671dccccd1d0d77d0d00000000000000000000000000000000455944404559444000000000
007cc700067cc760016cc610067cc760777cc777667cc76677dccd7706c77c60617cc71600000000000000000000000000000000459440404594404000000000
007cc700067cc760016cc610067cc760777cc777667cc76677dccd7706c77c60617cc71600000000000000000000000000000000444400504444005000000000
00d77d000dd77dd007d66d700d7777d076d77d6711d77d1176dddd671dccccd1d0d77d0d00000000000000000000000000000000444005504440055000000000
0000000001d66d100671176001d66d10d667766d00166100d167761d7dd66dd70001100000000000000000000000000000000000044455000444550000000000
000000000000000000000000000000001d7777d1001661006d7777d66710017600d66d0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000077000000000000777777000000000000770000c1100000cc77cc0000000000000000000000000000000000000000000000000
00000000007777000000000000777700777c1000077777700000000000077000c0000000c000000c000000000000000000000000000000000000000000000000
077c100000777700077e800000777700777c1100077777700000000000077000c077c10010777701000000000000000000000000000000000000000000000000
0777c10000c77c007777e80000e77e007777c1000cc77cc07777c1000007700070777c1010777701000000000000000000000000000000000000000000000000
0777c100001cc1007777e800008ee8007777c100011cc1107777c100000cc00070777c1000c77c00000000000000000000000000000000000000000000000000
077c100000011000077e800000088000777c1100000110000000000000011000c077c100001cc100000000000000000000000000000000000000000000000000
00000000000000000000000000000000777c1000000000000000000000000000c000000000011000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000c11000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000077000000000000777777000000000000770000110000001cccc10000000000000000000000000000000000000000000000000
0000000000777700000000000077770077cc10000777777000000000000770001000000010000001000000000000000000000000000000000000000000000000
07cc100000c77c0007ee800000e77e0077cc11000cc77cc00000000000077000c07cc10010777701000000000000000000000000000000000000000000000000
077cc10000cccc00777ee80000eeee00777cc1000cccccc0777cc100000cc000c077cc1000c77c00000000000000000000000000000000000000000000000000
077cc100001cc100777ee800008ee800777cc100011cc110777cc100000cc000c077cc1000cccc00000000000000000000000000000000000000000000000000
07cc10000001100007ee80000008800077cc1100000110000000000000011000c07cc100001cc100000000000000000000000000000000000000000000000000
0000000000000000000000000000000077cc10000000000000000000000000001000000000011000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000
00000000000000000010010000000000cccccc10c777777ccccccc10c777777c00c00c0000000000000000000000000000000000000000000000000000000000
001111000008800001c11c10000ee00077777cc1c777777c777777c1c7cccc7c0c7cc7c000000000000000000000000000000000000000000000000000000000
01cccc10008ee8001cccccc100e77e00777777c1c777777c7cccc7c1c7c77c7cc777777c00000000000000000000000000000000000000000000000000000000
01c77c1008e77e8001c77c100e7ee7e0777777c1c777777c7c77c7c1c7c77c7c0c7117c000000000000000000000000000000000000000000000000000000000
01c77c1008e77e8001c77c100e7ee7e0777777c1c777777c7c77c7c1c7cccc7c0c7117c000000000000000000000000000000000000000000000000000000000
01cccc10008ee8001cccccc100e77e00777777c1cc7777cc7cccc7c1c777777cc777777c00000000000000000000000000000000000000000000000000000000
001111000008800001c11c10000ee00077777cc11cccccc1777777c11cccccc10c7cc7c000000000000000000000000000000000000000000000000000000000
00000000000000000010010000000000cccccc1001111110cccccc100111111000c00c0000000000000000000000000000000000000000000000000000000000
00000000000880000010010000088000ccccc110c777777cccccc110c777777c0171171000000000000000000000000000000000000000000000000000000000
001111000087780001c11c10008778007777cc11c777777c77777c11c7cccc7c1c7cc7c100000000000000000000000000000000000000000000000000000000
01777710087777801c7777c1087ee78077777c11c777777c7ccc7c11c7c77c7c7777777700000000000000000000000000000000000000000000000000000000
01777710877777780177771087e88e7877777c11c777777c7c7c7c11c7cccc7c1c7cc7c100000000000000000000000000000000000000000000000000000000
01777710877777780177771087e88e7877777c11cc7777cc7c7c7c11c777777c1c7cc7c100000000000000000000000000000000000000000000000000000000
01777710087777801c7777c1087ee78077777c111cccccc17ccc7c111cccccc1c777777700000000000000000000000000000000000000000000000000000000
001111000087780001c11c10008778007777cc111111111177777c11111111111c7cc7c100000000000000000000000000000000000000000000000000000000
00000000000880000010010000088000ccccc11001111110ccccc110011111100171171000000000000000000000000000000000000000000000000000000000
11111111111111111111111106606600066066000066600000666000666666667777777777777777777777777777777777777777777777777777777777777777
1000000000000000000000017e8788707007007000737000077aa7006888888676666661766666617dddddd17666666d76666661766666617666666176666661
1011111111111111111111016888886060000060666b666067aaa7607e8228e776111171761111717d1111617611117176111171766666617666666176000071
101000000000000000000101688888606000006063b3b3606777796078299287761dd671761006717d17d161761dd6dd76166671766666617661176176000071
101000000000000000000101528882505000005053b3b3505977995068299286761d6671761006717d1dd661761d667176166671766666617661676176000071
1010077777777777777001010528250005000500555b5550599999506882288676166671761666717d111111761666dd76166671766666617667776176000071
101007000000000000700101005250000050500000535000059995001288882176777771767777717d666661767d7d7176777771766666617666666176777771
10100707777777777070010100050000000500000055500000555000111111117111111171111111711111117d1d1d1171111111711111117111111171111111
10100d070000000070d0010100000000000000000000000000000000666666660000000000000000000000000000000000000000000000000000000000000000
10100d0d01111110d0d00101000000000000000000000000000000006ee888e60000000000000000000000000000000000000000000000000000000000000000
1010060d01000010d0600101000000000000000000000000000000007e8998870000000000000000000000000000000000000000000000000000000000000000
10100606010110106060010100000000000000000000000000000000789aa9870000000000000000000000000000000000000000000000000000000000000000
10100606010110106060010100000000000000000000000000000000689aa9860000000000000000000000000000000000000000000000000000000000000000
10100606010000101060010100000000000000000000000000000000688998860000000000000000000000000000000000000000000000000000000000000000
1010060d011111101010010100000000000000000000000000000000128888210000000000000000000000000000000000000000000000000000000000000000
10100d0d000000001010010100000000000000000000000000000000111111110000000000000000000000000000000000000000000000000000000000000000
10100d0dddddddddd010000100000000000000000000000000000000666666660000000000000000000000000000000000000000000000000000000000000000
10100d000000000000100001000000000000000000000000000000007e9999870000000000000000000000000000000000000000000000000000000000000000
10100dddddddddddddd000000000000000000000000000000000000079aaaa970000000000000000000000000000000000000000000000000000000000000000
1010000000000000000000000000000000000000000000000000000079a77a970000000000000000000000000000000000000000000000000000000000000000
1010000000000000000000000000000000000000000000000000000079a77a970000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111000000000000000000000000000000000069aaaa960000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000000000000000000000000000000689999860000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111100000000000000000000000000000000111111110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777007777770077777700777777007777770077777700777777007777770077777700777777007777770077777700777777007777770
0d1111d00d1111d00d1111d00d1111d00d1111d00d1111d00d1111d00d1111d00d1111d00d1111d00dc111d00dcc11d00dccc1d00dccccd00dccccd00dccccd0
061cc160061111600611116006111160061111600611116006111160061111600611116006c1116006c1116006c1116006c1116006c1116006c11c6006c11c60
0d1cc1d00d1111d00d1111d00d1111d00d1111d00d1111d00d1111d00d1111d00dc111d00dc111d00dc111d00dc111d00dc111d00dc111d00dc111d00dc11cd0
0d1111100d1111100d1111c00d111cc00d111cc00d11ccc00d1cccc00dccccc00dccccc00dccccc00dccccc00dccccc00dccccc00dccccc00dccccc00dccccc0
0dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dccccd00dccccd00d1cc1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06cccc6006cccc6006cccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dccccd00dccccd00dccccd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dccccc00dcccc100d1cc11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddddd00dddddd00dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000010202040401040404040404040400000102020404010404040404040404010100000002020202000000000004000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000000000004000000000000000000020000000000040000000000000000000000000000000400000000000000000202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000200020200020000000002000000000000000000000000020b020b020b02022222220000000000000000000000000002022200002202020002020000020200000000000000000002220000000202022202000000000222000000000000000000000000000000000000000000002222
00222222002222000000000000000000021002050502100200000002000000000000000000000000020000000000000800000000002222220002220222220200020202000022020202020900000b020200022202022202000209000000220b22020200000000020200022222222202000002222202220200000000000008020b
002200000000220000000202020200000002000202000200000005020605000000000206070200000900000000000002000005222022000000220506072022002222220a0a220222020b000000000802002220000020220002220005000000000000020a0a02000000220b0b0b0b220000220900202022000000000000220200
0000000000000000000002100e02000002050220280205020000062825020202000007281006000002000023280000080000050d10050000000205060f282200000005280c000000000000232800000000020d0d0d0d02000000002823050000000008280e09000000220f06060f220000220c0c280002000000200f28000000
000000000f00000000000205280200000205022320020502020202231006000000000623100700000900001020000002000000280d050000000205060f1022000000000c23050000000000100e0000000022060a0a06220000000520100000000000082310090000000220102820020000220c0c100002000000000e0f200000
002200000000220000000202020200000002000202000200000005060205000000000207060200000200000000000008000022232200000000220506072322002202220b0b222222020a000000000a02002210282310220000000000050022020000020b0b020000002223000020220000220900202322000002220000000000
00222200222222000000000000000000021002050502100200000000020000000000000000000000090000000000000222222200000000000002220222220200020222000002020202020900000802020002222222220200220a2200000008020202000000000202000222020222020000022222022202000a02090000000000
0000000000000000000000000000000000020002020002000000000002000000000000000000000002021a021a021a020000000022222222000000000000000002022200002202020002020000020200000000000000000002020200000022022202000000000222000000000000000000000000000000002222000000000000
0200020002000200020002000200020000000000000200000000000000000000000000000000000022000000000000220200000002020202050502020606020200000022220000000000000000000000000222020222020000000000000000000000000000000022020202222202020200000002020000000202020000020202
0002060206020002000207020002070200000000000200000000020202020000000000000000000000020000000002000200000002050000050502020606020200000202020200000002220000020200020f050000050f020000220a0a2200000000000000000022020f060000060f0200000502020500000222020505022202
0200020e0206020002070200020002000202020a0a0200000002220f0c2202000000020d02020000000022070c2200000205050a0205000002020e0f020206060002280505250200000222060722220022050206060205220022020d0c022200000000000000200202060000000006020005220f072205000202020f0f020202
00020602280200020002000e28020002000008282309000000020c10230f0200000002280e0d000000000c100e070000020202282509000002020f10020206062202050f06050222000007280e060000020006281006000200080c23280d0900000000280d2222022200000e10000022020207280e0f020200050f23280f0500
0200021002060200020002230e000200000008201009000000020f0e280c020000000d201002000000000723280c0000000008230e02020206060202280f0202220205060f0502220000062010070000020006100e06000200080d10200c09000222220d0e000000220000282300002202020f251007020200050f10200f0500
000206022302000200020002000207020000020b0b0202020002220c0f220200000002020d0200000000220c07220000000005020b050502060602020f0e02020002200505100200002222070622020022050206060205220022020c0d02220002200000000000000206000000000602000522070f2205000202020f0f020202
0200020602060200020702000207020000000200000000000000020202020000000000000000000000020000000002000000050200000002020206060202050500000202020200000002020000220200020f050000050f020000220b0b2200002200000000000000020f060000060f0200000502020500000222020505022202
0002000200020002000200020002000200000200000000000000000000000000000000000000000022000000000000220202020200000002020206060202050500000022220000000000000000000000000222020222020000000000000000002200000000000000020202222202020200000002020000000202020000020202
020202020200020200000002000000000000000000000000220000222200002200000002020000000e0b0b0b0b0b0b0e000000000000000000020000000000000000000000000000000000000000000010220000000000000000000000000000220000000000002200000000000000000e0000000000000e0e0e0e0e0e0e0e0e
02000000000000020000000200000000000000020200000000000000000000000000000202000000090000000000000800002200002200000002000000020202000000000000000000222222222222002222020022230000002222220222220000000000000000000002000000000200000e000000000e000e0000000000000e
0000020505020002000022220a220000000022231022000000000e00000e000000000e00000e0000090000000000000800220f02020f220000020e02020e00000000070e00070000002211111111220000020e022222002200220e00000e22000000000f2200000000000f0f0f0f000000000e00230e00000e0011111111000e
0200050e0605000200000828202202020002100e0e28020022000011280000220202000c230002020900002823000008000002230f020000000002280e02000000000028100e00000022110c0c1122000000020c0200000000220000000c02000000220e2302000000000f280c0f00000000280e0e0000000e0011282811000e
020005062805000202022220100900000002280e0e1002002200002311000022020200280c00020209000023280000080000020f280200000000020e2802000000000e10230000000022110c0c112200222222020c0200000002000000232200000002280e22000000000f0c230f00000000000e0e2800000e0011282811000e
02000205050200000000220b22220000000022102322000000000e00000e000000000e00000e0000090000000000000800220f02020f220000000e02020e0200000007000e070000002211111111000000282200020e020000220e0c23342200000000220f00000000000f0f0f0f000000000e23000e00000e0011111111000e
02000000000000020000000002000000000000020200000000000000000000000000000202000000090000000000000800002200002200000202020000000200000000000000000000222222222222220000000000022222002222022222220000000000000000000002000000000200000e000000000e000e0000000000000e
020200020202020200000000020000000000000000000000220000222200002200000002020000000e0a0a0a0a0a0a0e000000000000000000000000000002000000000000000000000000000000000000002200002210000000000000000000220000000000002200000000000000000e0000000000000e0e0e0e0e0e0e0e0e
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002220c0c220200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020c28230c0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020c20100c0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002220c0c220200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000136101061003010070200c0201003018020097000b7000d700137000c3000d3000d3000d3000d30000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e6101a620130300f0300d0300a0300802005020030100101000010000100001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000028610206201603012030100300d0200a02009020080200602005010040100301003010020100201002010020100000000000000000000000000000000000000000000000000000000000000000000000
000200000822029610211100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00000f1100d5100f01011520041002e1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000071003710067100a71010710297301471035720347001300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001b620146200d6200a61005610016100061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000261003610066100a3100e320133201932000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000156201462013220102200e2100c2100b21009210082100721005210042100421003210022100221000210002100021000210002100021000200002000020000000000000000000000000000000000000
00010000366101e620103300d33008320043100131005000030000100000000000000100001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000386201d420102200722003220226101e6101a6101861014610116100e6100c6100761005610056100761008610096100a6100c6100c6100b610086100561004610036100261002610006100061000000
000100000d62025430174200a42004210012100021000200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000386502e65029320273202a32031320263202e6202e6202c6202b620296202662024620206201d6201962015620116200d6200b6200762005620036200262001620006200062000620006100061000610
000200001842021420256202262020620194201642013410104100d4100a410084100641004410034100241001410004100041003600026000260002600016000160000000000000000000000000000000000000
0002000011220036102c3200261001600016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000140101401016010180201d0300000018020000001d0200300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002b1102e110000003111000000000003d11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002261019120151200862002620006100161001610006100061000610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000130300d030080300800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000018110141101011009120062100d210122100c120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000b2100d100102200000007210000000b22000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000156201462013210102100e2100c2100b21009210082100721005210042100421003210022100221000210002100021000210002100021000200002000020000000000000000000000000000000000000
00010000236101a620130300f0300d0300a0300802005020030100101000010000100002000620006300062000620006100061000610006000060000600006000060000600006000060000600006000060000600
00010000156201462013220102200e2100c2100b21009210082100721005210042100421003210022100221000210002100021000210002100021000200002000020000000000000000000000000000000000000
000300000b3100731005320063100d010120100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000801005310013100431007010000000b0100000009010000000b010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000136201462013310102200e2100a3100a31009210082100721005210032100221002210012100021000200002000020000200003000030000200002000020000000000000000000000000000000000000
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
