pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
 g_time,state,g_index=
  0,menu,0

 g_stars=0
 g_starreg={}

 wo={
  y=128
 }

 mn={
  y=-128
 }
 
 mn2={
  y=-128
 }

 shk=0
 
 local o=tween(mn,{y=0},1,"back_out")
 o.delay=0.3
 o.onend=function()
  shk=10
  tween(mn2,{y=0},1,"back_out").delay=0.3
 end
 
 
 -- ƒ€’Š‹ƒ‰ƒ€’
 m()
end

function _update60()
 g_time+=1
 state.update()
 tween_update(1/60)
end

function _draw()
 if shk~=0 then
  shk-=0.5
  camera(rnd(shk)-shk/2,rnd(shk)-shk/2)
 end

 state.draw()
end

function restart_level()
 fade()
 shk=3
 reload(0x2000,0x2000,0x1000)
 collision_reset()
 entity_reset()
 
 g_won=false
 g_fruit=0
 g_guy=nil
 
 g_level=e_add(level({
  base=v(g_index%8*16,flr(g_index/8)*16),
  size=v(16,16)
 }))
 
 g_from_right=false
end
-->8
-- oop

function deep_copy(obj)
 if (type(obj)~="table") return obj
 local cpy={}
 setmetatable(cpy,getmetatable(obj))
 for k,v in pairs(obj) do
  cpy[k]=deep_copy(v)
 end
 return cpy
end

function index_add(idx,prop,elem)
 if (not idx[prop]) idx[prop]={}
 add(idx[prop],elem)
end

function event(e,evt,p1,p2)
 local fn=e[evt]
 if fn then
  return fn(e,p1,p2)
 end
end

function state_dependent(e,prop)
 local p=e[prop]
 if (not p) return nil
 if type(p)=="table" and p[e.state] then
  p=p[e.state]
 end
 if type(p)=="table" and p[1] then
  p=p[1]
 end
 return p
end

function round(x)
 return flr(x+0.5)
end

-------------------------------
-- objects
-------------------------------

object={}
 function object:extend(kob)
  -- printh(type(kob))
  if (kob and type(kob)=="string") kob=parse(kob)
  kob=kob or {}
  kob.extends=self
  return setmetatable(kob,{
   __index=self,
   __call=function(self,ob)
	   ob=setmetatable(ob or {},{__index=kob})
	   local ko,init_fn=kob
	   while ko do
	    if ko.init and ko.init~=init_fn then
	     init_fn=ko.init
	     init_fn(ob)
	    end
	    ko=ko.extends
	   end
	   return ob
  	end
  })
 end
 
-------------------------------
-- vectors
-------------------------------

vector={}
vector.__index=vector
 function vector:__add(b)
  return v(self.x+b.x,self.y+b.y)
 end
 function vector:__sub(b)
  return v(self.x-b.x,self.y-b.y)
 end
 function vector:__mul(m)
  return v(self.x*m,self.y*m)
 end
 function vector:__div(d)
  return v(self.x/d,self.y/d)
 end
 function vector:__unm()
  return v(-self.x,-self.y)
 end
 function vector:dot(v2)
  return self.x*v2.x+self.y*v2.y
 end
 function vector:norm()
  return self/sqrt(#self)
 end
 function vector:len()
  return sqrt(#self)
 end
 function vector:__len()
  return self.x^2+self.y^2
 end
 function vector:str()
  return self.x..","..self.y
 end

function v(x,y)
 return setmetatable({
  x=x,y=y
 },vector)
end

-------------------------------
-- collision boxes
-------------------------------

cbox=object:extend()

 function cbox:translate(v)
  return cbox({
   xl=self.xl+v.x,
   yt=self.yt+v.y,
   xr=self.xr+v.x,
   yb=self.yb+v.y
  })
 end

 function cbox:overlaps(b)
  return
   self.xr>b.xl and
   b.xr>self.xl and
   self.yb>b.yt and
   b.yb>self.yt
 end

 function cbox:sepv(b,allowed)
  local candidates={
   v(b.xl-self.xr,0),
   v(b.xr-self.xl,0),
   v(0,b.yt-self.yb),
   v(0,b.yb-self.yt)
  }
  if type(allowed)~="table" then
   allowed={true,true,true,true}
  end
  local ml,mv=32767
  for d,v in pairs(candidates) do
   if allowed[d] and #v<ml then
    ml,mv=#v,v
   end
  end
  return mv
 end
 
 function cbox:str()
  return self.xl..","..self.yt..":"..self.xr..","..self.yb
 end

function box(xl,yt,xr,yb) 
 return cbox({
  xl=min(xl,xr),xr=max(xl,xr),
  yt=min(yt,yb),yb=max(yt,yb)
 })
end

function vbox(v1,v2)
 return box(v1.x,v1.y,v2.x,v2.y)
end

-------------------------------
-- entities
-------------------------------

entity=object:extend({
 state="idle",t=0,
 last_state="idle",
 dynamic=true,
 draw_order=3,
 spawns={}
})

 function entity:init()
  if self.sprite then
   self.sprite=deep_copy(self.sprite)
   if not self.render then
    self.render=spr_render
   end
  end
 end
 
 function entity:become(state)
  if state~=self.state then
   self.last_state=self.state
   self.state,self.t=state,0
  end
 end
 
 function entity:is_a(tag)
  if (not self.tags) return false
  for i=1,#self.tags do
   if (self.tags[i]==tag) return true
  end
  return false
 end
 
 function entity:spawns_from(...)
  for tile in all({...}) do
   entity.spawns[tile]=self
  end
 end

static=entity:extend({
 dynamic=false
})

function spr_render(e)
 local s,p=e.sprite,e.pos

 function s_get(prop,dflt)
  local st=s[e.state]
  if (st~=nil and st[prop]~=nil) return st[prop]
  if (s[prop]~=nil) return s[prop]
  return dflt
 end

 local sp=p+s_get("offset",v(0,0))

 local w,h=
  s.width or 1,s.height or 1

 local flip_x=false
 local frames=s[e.state] or s.idle
 local delay=frames.delay or 1
 
 if s.turns and type(frames[1])~="number" then
  if e.facing=="up" then
   frames=frames.u
  elseif e.facing=="down" then
   frames=frames.d
  else
   frames=frames.r
  end
  flip_x=(e.facing=="left")
 end
 if s_get("flips") then
  flip_x=e.flipped
 end

 if (type(frames)~="table") frames={frames}
 local frm_index=flr(e.t/delay) % #frames + 1
 local frm=frames[frm_index]
 local f=e.bold and ospr or spr
 f(e.exr_sprite or frm,
 (sp.x),(sp.y),w,h,flip_x)

 return frm_index
end

function ospr(s,x,y,...)
 for i=0,15 do pal(i,7) end
 spr(s,x-1,y,...)
 spr(s,x+1,y,...)
 spr(s,x,y-1,...)
 spr(s,x,y+1,...)
 r_reset()
 spr(s,x,y,...)
end

-------------------------------
-- entity registry
-------------------------------

function entity_reset()
 entities,entities_with,
  entities_tagged={},{},{}
end

function e_add(e)
 add(entities,e)
 for p in all(indexed_properties) do
  if (e[p]) index_add(entities_with,p,e)
 end
 if e.tags then
  for t in all(e.tags) do
   index_add(entities_tagged,t,e)
  end
  c_update_bucket(e)
 end
 return e
end

function e_remove(e)
 del(entities,e)
 for p in all(indexed_properties) do
  if (e[p]) del(entities_with[p],e)
 end
 if e.tags then
  for t in all(e.tags) do
   del(entities_tagged[t],e)
   if e.bkt then
    del(c_bucket(t,e.bkt.x,e.bkt.y),e)
   end
  end
 end
 e.bkt=nil
end

indexed_properties={
 "dynamic",
 "render","render_hud",
 "vel",
 "collides_with",
 "feetbox"
}

-- systems

-------------------------------
-- update system
-------------------------------

function e_update_all()
 for ent in all(entities_with.dynamic) do
  local state=ent.state
  if ent[state] then
   ent[state](ent,ent.t)
  end
  if ent.done then
   e_remove(ent)
  elseif state~=ent.state then
   ent.t=0
  else
   ent.t+=1
  end  
 end
end

function schedule(fn)
 scheduled=fn
end

-------------------------------
-- render system
-------------------------------

function r_render_all(prop)
 local drawables={}
 for ent in all(entities_with[prop]) do
  local order=ent.draw_order or 0
  if not drawables[order] then
   drawables[order]={}
  end
  add(drawables[order],ent)  
 end
 for o=0,15 do  
  for ent in all(drawables[o]) do
   r_reset(prop)
   if not ent.done then ent[prop](ent,ent.pos) end
  end
 end
end

function r_reset(prop)
 pal()
 palt(0,false)
 palt(14,true)
end

-------------------------------
-- movement system
-------------------------------

function do_movement()
 for ent in all(entities_with.vel) do
  local ev=ent.vel
  ent.pos+=ev
  if ev.x~=0 then
   ent.flipped=ev.x<0
  end
  if ev.x~=0 and abs(ev.x)>abs(ev.y) then
  
   ent.facing=
    ev.x>0 and "right" or "left"
  elseif ev.y~=0 then
   ent.facing=
    ev.y>0 and "down" or "up"
  end
  if (ent.weight) then
   local w=state_dependent(ent,"weight")
   ent.vel+=v(0,w)
  end
 end
end

-------------------------------
-- collision
-------------------------------

function c_bkt_coords(e)
 local p=e.pos
 return flr(shr(p.x,4)),flr(shr(p.y,4))
end

function c_bucket(t,x,y)
 local key=t..":"..x..","..y
 if not c_buckets[key] then
  c_buckets[key]={}
 end
 return c_buckets[key]
end

function c_update_buckets()
 for e in all(entities_with.dynamic) do
  c_update_bucket(e)
 end
end

function c_update_bucket(e)
 if (not e.pos or not e.tags) return 
 local bx,by=c_bkt_coords(e)
 if not e.bkt or e.bkt.x~=bx or e.bkt.y~=by then
  if e.bkt then
   for t in all(e.tags) do
    local old=c_bucket(t,e.bkt.x,e.bkt.y)
    del(old,e)
   end
  end
  e.bkt=v(bx,by)  
  for t in all(e.tags) do
   add(c_bucket(t,bx,by),e) 
  end
 end
end

function c_potentials(e,tag)
 local cx,cy=c_bkt_coords(e)
 local bx,by=cx-2,cy-1
 local bkt,nbkt,bi={},0,1
 return function()
  while bi>nbkt do
   bx+=1
   if (bx>cx+1) bx,by=cx-1,by+1
   if (by>cy+1) return nil
   bkt=c_bucket(tag,bx,by)
   nbkt,bi=#bkt,1
  end
  local e=bkt[bi]
  bi+=1
  return e
 end 
end

function collision_reset()
 c_buckets={}
end

function do_collisions()
 c_update_buckets()
 for e in all(entities_with.collides_with) do
  for tag in all(e.collides_with) do
   if entities_tagged[tag] then
   local nothers=
    #entities_tagged[tag]  
   if nothers>4 then
    for o in c_potentials(e,tag) do
     if o~=e and not e.nocol and not o.nocol  then
      local ec,oc=
       c_collider(e),c_collider(o)
      if ec and oc then
       c_one_collision(ec,oc,e,o)
      end
     end
    end
   else
    for oi=1,nothers do
     local o=entities_tagged[tag][oi]
     local dx,dy=
      abs(e.pos.x-o.pos.x),
      abs(e.pos.y-o.pos.y)
     if dx<=20 and dy<=20 then
      local ec,oc=
       c_collider(e),c_collider(o)
      if ec and oc then
       c_one_collision(ec,oc,e,o)
      end
     end
    end
   end     
   end
  end 
 end
end

function c_check(box,tags)
 local fake_e={pos=v(box.xl,box.yt)} 
 for tag in all(tags) do
  for o in c_potentials(fake_e,tag) do
   local oc=c_collider(o)
   if oc and not o.nocol and box:overlaps(oc.b) then
    return oc.e
   end
  end
 end
 return nil
end

function c_one_collision(ec,oc,e,o)
 if ec.b:overlaps(oc.b) then
  c_reaction(ec,oc,e,o)
  c_reaction(oc,ec,e,o)
 end
end

function c_reaction(ec,oc,e,o)
 local reaction,param=
  event(ec.e,"collide",oc.e)
 if type(reaction)=="function" then
  reaction(ec,oc,param,e,o)
 end
end

function c_collider(ent)
 if ent.collider then 
  if ent.coll_ts==g_time or not ent.dynamic then
   return ent.collider
  end
 end
 local hb=state_dependent(ent,"hitbox")
 if (not hb) return nil
 local coll={
  b=hb:translate(ent.pos),
  e=ent
 }
 ent.collider,ent.coll_ts=
  coll,g_time
 return coll
end

function c_push_out(oc,ec,allowed_dirs,e,o)
 local sepv=ec.b:sepv(oc.b,allowed_dirs)
 ec.e.pos+=sepv
 
 if ec.e.vel then
  local vdot=ec.e.vel:dot(sepv)
  if vdot<0 then
   if (sepv.y~=0) ec.e.vel.y=0
   if (sepv.x~=0) ec.e.vel.x=0
  end
 end
 ec.b=ec.b:translate(sepv)
end

function c_move_out(oc,ec,allowed)
 return c_push_out(ec,oc,allowed)
end

-------------------------------
-- support
-------------------------------


function do_supports()
 for e in all(entities_with.feetbox) do  
  local fb=e.feetbox
  if fb then
   fb=fb:translate(e.pos)
   local support=c_check(fb,{"walls"})
-- ) support=nil
   e.supported_by=support
   if support and support.vel then
    e.pos+=support.vel
   end
  end
 end
end
local a="0000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555550000000000000000000005555555555550000000000000000000555155555555500000000000000000005551555555555000000000000000000055555555555550000000000000000000555555555555500000000000000000005555555555555000000008888888800055555550000000000000008888888880555555500000000000000008880008888555555555500000000000080000000558888000000000000005000000000005555558000000000000050000000005555555500000000000000550000005555555555555000000000005550000555555555550050000000000055550055555555555500500000000000555555555555555555000000000000005555555555555555550000000000000005555555555555555500000000000000055555555555555550000000000000000055555555555555500000000000000000055555555555550000000000000000000055555555555000000000000000000000055555555500000000000000000000000055550555000000000000000000000000555000550000000000000000000000005500000500000000000000000000000050000005000000000000000000000000555000055500000000000000000000000000000000000000000000"

function b(y,xx,yy) 
 for c=0,31 do
  for d=1,31 do 
   local e=d+c*32 
   local m=tonum(sub(a,e,e))
   if (m~=0) pset(d+48+xx,c-48+y+yy,m)
  end 
 end
end 

function oprint(s,x,y,...)
 s=smallcaps(s)
 prnt(s,x,y,...)
end

function coprint(s,y,c,m,n)
 s=smallcaps(s)
 prnt(s,64-#s*2+(m or 0),y,c,nil,n)
end

function prnt(s,x,y,c,o,n)
 if(not o) o=sget(97,c)
 
 for xx=x-1,x+1 do
  for yy=y-1,y+2 do
   print(s,xx,yy,n or 0)
  end
 end
 
 print(s,x,y+1,o)
 print(s,x,y,c)
end
local gt=0
function f(e)
 cls()
 gt=min(0.5,gt+0.03) 
 local y=96+cos(gt)*5
 for xx=-1,1 do
  for yy=-1,1 do
   if abs(xx)+abs(yy)==1 then
    coprint("^rexellent ^games",
     y+yy,0,xx,7)
   end
  end
 end

 coprint("^rexellent ^games",
  y,7)

 for i=0,15 do pal(i,l[e][6]) end
 for xx=-1,1 do
 for yy=-1,1 do
  if(abs(xx)+abs(yy)==1)b(y,xx,yy)
 end
 end
 pl(e)
 b(y,0,0)
 flip()
end 
 
function g(h,i,j) 
 for e=h,i,j do 
  for m=1,5 do
   pl(e)
   f(e) 
  end
 end 
end 

function pl(e)
 local k=l[e]
 pal()
 pal(8,k[1]) 
 pal(1,k[2]) 
 pal(5,k[3]) 
 pal(7,k[4])
 pal(13,k[5]) 
end

l={
 {0,0,0,0,0,1},
 {2,0,1,1,1,5},
 {4,0,1,5,13,5},
 {4,1,5,6,13,6},
 {8,1,5,7,13,7}
} 
 
function m() 
 g(1,#l,1) 
 g(#l,1,-1) 
 pal() 
 fade()
end

function smallcaps(s)
 s=s..""
  local d=""
  local c
  for i=1,#s do
    local a=sub(s,i,i)
    if a!="^" then
      if not c then
        for j=1,26 do
          if a==sub("abcdefghijklmnopqrstuvwxyz",j,j) then
            a=sub("\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92",j,j)
          end
        end
      end
      d=d..a
      c=true
    end
    c=not c
  end
  return d
end

function noprint(s,x,y,c)
 s=smallcaps(s)
 prnt(s,x+4-#s*2,y,c)
end


pltt={7,6,5,1,0}
function fade()
 shk=20
 for i=1,#pltt do
  cls(plt[i])
  flip()
 end
end
-->8
-- level

level=entity:extend({
 draw_order=2
})

function level:init()
 local b,s=self.base,self.size
 for x=0,s.x-1 do
  for y=0,s.y-1 do
   local blk=mget(b.x+x,b.y+y)
   local cl=entity.spawns[blk]
   if cl then
    local e=cl({
     pos=v(x,y)*8,
     tile=blk
    })
    e_add(e)
    mset(b.x+x,b.y+y,1+rnd(3))
    blk=0
   end
  end
 end
end

function level:render()
 for i=1,15 do pal(i,0) end
 for xx=-1,1 do
  for yy=-1,1 do
   if(abs(xx+yy)==1) map(self.base.x,self.base.y,xx,yy)
  end
 end
 r_reset()
 map(self.base.x,self.base.y,0,0)
end
-->8
-- entities
star=entity:extend({
 hitbox=box(0,0,8,8),
 collides_with={"snake"}
})

star:spawns_from(18)

function star:render()
 spr(self.tile,self.pos.x,self.pos.y+sin(self.t/120)*1.5)
end

function star:init()
 if g_starreg[g_index]==1 then
  self.done=true
 end
end

function star:collide(o)
 if o:is_a("snake") then
  self.done=true
  g_stars+=1
  g_starreg[g_index]=1
  parts(self.pos.x,self.pos.y,5,4,10)
  sfx(1)
 end
end

fruit=entity:extend({
 hitbox=box(0,0,8,8),
 collides_with={"snake"}
})

fruit:spawns_from(32,33,34)

function fruit:render()
 spr(self.tile,self.pos.x,self.pos.y+sin(self.t/120)*1.5)
end

function fruit:init()
 g_fruit+=1
end

function fruit:collide(o)
 if o:is_a("snake") then
  self.done=true
  if self.tile==34 then o:shrink()
  else o:grow() end
  sfx(1)
 
  g_fruit-=1
  parts(self.pos.x,self.pos.y,5,4,7)

  if g_fruit==0 then
   local xx,yy,x,y
   
   repeat 
    xx,yy,x,y=find_tile(37)
    if xx~=nil then
     mset(xx,yy,38)
     parts(x*8,y*8,5,4,7)
    end
   until x==nil
   
   xx=nil
   
   repeat 
    xx,yy,x,y=find_tile(36)
    if xx~=nil then
     mset(xx,yy,37)
     parts(x*8,y*8,5,4,7)
    end
   until x==nil
  end
 end
end

function find_tile(tl,ex,ey)
 for x=0,15 do
  for y=0,15 do
   local xx,yy=x+g_level.base.x,y+g_level.base.y
   if xx~=ex or yy~=ey then
   if(mget(xx,yy)==tl) return xx,yy,xx-g_level.base.x,yy-g_level.base.y
   end
  end
 end
end

key=entity:extend({
 hitbox=box(0,0,8,8),
 collides_with={"snake"}
})

key:spawns_from(41,42,43,44)

function key:render()
 ospr(self.tile,self.pos.x,self.pos.y+sin(self.t/120)*1.5)
end

function key:collide(o)
 if o:is_a("snake") then
  self.done=true
  parts(self.pos.x,self.pos.y,5,4,7)
  while true do
  local x,y,xx,yy=find_tile(self.tile+16)
  
  sfx(1)

  if x then
   mset(x,y,1)
   parts(xx*8,yy*8,5,4,7)
  else 
   break
  end
  end
 end
end
-->8
-- player

player=entity:extend({
 tags={"snake"},
 hitbox=box(0,0,8,8)
})

player:spawns_from(16)

function player:init()
 if g_guy~=nil then
  if g_from_right then
   g_guy.done=true
  else
   self.done=true
   return
  end
 end
 
 g_guy=self
 self.sx=self.pos.x
 self.sy=self.pos.y

 self.len=g_index>1 
  and (g_index>8 and 7 or 5)
  or 2

 self.seg={}
 for i=1,self.len do
  self.seg[i]={
   x=self.pos.x,y=self.pos.y
  }
 end
end

function player:grow()
 self.len+=1
 self.seg[self.len]={
   x=self.pos.x,y=self.pos.y
 }
end

function player:shrink()
 self.seg[self.len]=nil
 self.len-=1
end

function player:render()
 --[[for i=1,self.len do
  local s=self.seg[i]
  local tx,ty
  
  if i==1 then
   tx,ty=self.pos.x,self.pos.y
  else
   local s2=self.seg[i-1]
   tx,ty=s2.x,s2.y
  end
  
  line(tx+4,ty+4,s.x+4,s.y+4,0)
  line(tx+3,ty+3,s.x+3,s.y+3,1)
 end]]
 
 for i=1,self.len do
  local s=self.seg[i]
  spr(17,s.x,s.y)
 end
 spr(16,self.pos.x,self.pos.y)
end

function player:idle()
 local xx,yy=0,0
 
 if(btnp(‹)) xx-=1
 if(btnp(‘)) xx+=1
 if(btnp(”)) yy-=1
 if(btnp(ƒ)) yy+=1
 
 if xx~=0 or yy~=0 then
  if(xx~=0) yy=0
  
  local n=self.pos+v(xx,yy)*8
  local lx=n.x/8+g_level.base.x
  local ly=n.y/8+g_level.base.y
  local t=mget(lx,ly)
   
  if (n.x<0 and not g_from_right and self.pos.x==self.sx and self.pos.y==self.sy) or n.x+g_level.base.x<0 or (not fget(t,0) and lx<127) then
   return
  end
  
  for i=1,self.len do
   local s=self.seg[i]
   if s.x==n.x and s.y==n.y then
    sfx(3)
    restart_level()
   end
  end
  
  for i=self.len,1,-1 do
   local s=self.seg[i]
   if i==1 then
    s.x=self.pos.x
    s.y=self.pos.y
   else
    local s2=self.seg[i-1]
    s.x,s.y=s2.x,s2.y
   end
  end
  self.pos=n
  sfx(0)
  
  if self.pos.x>127 then
   if g_index==15 then
    g_won=true
   else
   g_index+=1
   restart_level()
   end
  elseif self.pos.x<0 then
   g_index-=1
   g_from_right=true
   restart_level()
  else
   if (t>=13 and t<=15) or t==29 then
    local x,y,xx,yy=find_tile(t,lx,ly)
    parts(self.pos.x,self.pos.y,5,4,7)
    self.pos.x=xx*8
    self.pos.y=yy*8   
    parts(self.pos.x,self.pos.y,5,4,7)
    sfx(4)
   end 
  end
 end
end
-->8
-- fx

part=entity:extend({
 draw_order=10
})

function part:idle()
 self.r-=(self.spd~=nil and self.spd(self.t) or 0.1)
 self.vel*=(self.mul or 0.9)
 if self.r<0 then
  self.done=true
 end
end

function part:render()
 circfill(self.pos.x,self.pos.y,self.r,0)

end

function part:render_hud()
 circfill(self.pos.x,self.pos.y,self.r-1,self.c)
 
end

function parts(x,y,a,r,c)
 for i=1,a do
  e_add(part({
   pos=v(x,y),
   vel=v(rnd(2)-1,rnd()),
   r=r,
   c=rnd()>0.7 and c or sget(97,c)
  }))
 end
end

-->8
-- tween engine
-- by @egordorichev

local back=1.70158

-- feel free to remove unused functions to save up some space
functions={
["linear"]=function(t) return t end,
["quad_out"]=function(t) return -t*(t-2) end,
["quad_in"]=function(t) return t*t end,
["quad_in_out"]=function(t) t=t*2 if(t<1) return 0.5*t*t
    return -0.5*((t-1)*(t-3)-1) end,
["back_in"]=function(t) local s=back  return t*t*((s+1)*t-s) end,
["back_out"]=function(t) local s=back t-=1 return t*t*((s+1)*t+s)+1 end,
["back_in_out"]=function(t) local s=back t*=2 if (t<1) s*=1.525 return 0.5*(t*t*((s+1)*t-s))
 t-=2 s*=1.525  return 0.5*(t*t*((s+1)*t+s)+2) end
}

local tasks={}

function tween(o,vl,t,fn)
 local task={
  vl={},
  rate=1/(t or 1),
  o=o,
  progress=0,
  delay=0,
  fn=functions[fn or "quad_out"]
 }

 for k,v in pairs(vl) do
  local x=o[k]
  task.vl[k]={start=x,diff=v-x}
 end

 add(tasks,task)
 return task
end

function tween_update(dt)
 for t in all(tasks) do
  if t.delay>0 then
   t.delay-=dt
  else
   t.progress+=dt
   local p=t.progress
   local x=t.fn(p>=1 and 1 or p)
   for k,v in pairs(t.vl) do
    t.o[k]=v.start+v.diff*x
   end

   if p>=1 then
    del(tasks,t)
    if (t.onend) t.onend()
   end 
  end
 end
end
-->8
-- states

menu={}

function menu.update()
 if btnp(—) then
  state=ingame
  sfx(2)
  restart_level()
 end
end

--plt={0,1,2,4,9,10,7,10,9,4,2,1,0}
plt={0,1,3,11,10,7,10,11,3,1,0}
local st=false
function menu.draw()
 for i=1,700 do
  local x,y=rnd(128),rnd(128)
  local c=0
  local xx,yy=64-x,64-y
  local d=sqrt(xx*xx+yy*yy)
  
  c+=cos(x/128-g_time/500)*8
  c+=sin(y/128+g_time/400)*8
  
  c+=d/4+atan2(yy,xx)*24+g_time/20
  
  --c+=atan2(64-y,64-x)*8+g_time/100
  
  rect(x,y,x+rnd(3),y+rnd(3),plt[flr(c)%(#plt+1)])
 end
 r_reset()
 local y=mn.y
 if y>=0 and not st then
  st=true
  shk=3
  sfx(6)
  music(0)
 end
 local xy=74
 local s=cos(g_time/200)*3.5
 coprint("by @egordorichev",58-s+y,6)
 coprint("^press — ",100+y,g_time%60>30 and 6 or 7)

 for i=0,15 do pal(i,7) end
 for xx=-1,1 do
  for yy=-1,1 do
   if(abs(xx)+abs(yy)==1) sspr(0,32,128,32,2+xx,yy+32-s+y) spr(30,54+xx,xy+mn2.y-s+yy,2,2)
  end
 end
 r_reset()
 sspr(0,32,128,32,2,32-s+y)
 spr(30,54,xy+mn2.y-s,2,2)
end

ingame={}

function ingame.update()
 e_update_all()
 do_movement()
 do_collisions()
end

function ingame.draw()
 cls(12)
 
 r_render_all("render")
 r_render_all("render_hud")
 
 if g_won then
  local y=sin(g_time/120)*1.5
  rect(31,0,97,127,0)
  rectfill(32,0,96,127,1)
  coprint("…†‡‡†…      ",32+y,10)
  coprint("^you won!",42+y,7)
  coprint("…†‡‡†…      ",52+y,10)
 
  coprint(g_stars.." ’ collected ",72+y,9)
  coprint("^thanks for",92+y,11)
  coprint("playing!",100+y,11)
 end
end


local a="0000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555550000000000000000000005555555555550000000000000000000555155555555500000000000000000005551555555555000000000000000000055555555555550000000000000000000555555555555500000000000000000005555555555555000000008888888800055555550000000000000008888888880555555500000000000000008880008888555555555500000000000080000000558888000000000000005000000000005555558000000000000050000000005555555500000000000000550000005555555555555000000000005550000555555555550050000000000055550055555555555500500000000000555555555555555555000000000000005555555555555555550000000000000005555555555555555500000000000000055555555555555550000000000000000055555555555555500000000000000000055555555555550000000000000000000055555555555000000000000000000000055555555500000000000000000000000055550555000000000000000000000000555000550000000000000000000000005500000500000000000000000000000050000005000000000000000000000000555000055500000000000000000000000000000000000000000000"

function b(y,xx,yy) 
 for c=0,31 do
  for d=1,31 do 
   local e=d+c*32 
   local m=tonum(sub(a,e,e))
   if (m~=0) pset(d+48+xx,c-48+y+yy,m)
  end 
 end
end 

function oprint(s,x,y,...)
 s=smallcaps(s)
 prnt(s,x,y,...)
end

function coprint(s,y,c,m,n)
 s=smallcaps(s)
 prnt(s,64-#s*2+(m or 0),y,c,nil,n)
end

function prnt(s,x,y,c,o,n)
 if(not o) o=sget(97,c)
 
 for xx=x-1,x+1 do
  for yy=y-1,y+2 do
   print(s,xx,yy,n or 0)
  end
 end
 
 print(s,x,y+1,o)
 print(s,x,y,c)
end
local gt=0
function f(e)
 cls()
 gt=min(0.5,gt+0.03) 
 local y=96+cos(gt)*5
 for xx=-1,1 do
  for yy=-1,1 do
   if abs(xx)+abs(yy)==1 then
    coprint("^rexellent ^games",
     y+yy,0,xx,7)
   end
  end
 end

 coprint("^rexellent ^games",
  y,7)

 for i=0,15 do pal(i,l[e][6]) end
 for xx=-1,1 do
 for yy=-1,1 do
  if(abs(xx)+abs(yy)==1)b(y,xx,yy)
 end
 end
 pl(e)
 b(y,0,0)
 flip()
end 
 
function g(h,i,j) 
 for e=h,i,j do 
  for m=1,5 do
   pl(e)
   f(e) 
  end
 end 
end 

function pl(e)
 local k=l[e]
 pal()
 pal(8,k[1]) 
 pal(1,k[2]) 
 pal(5,k[3]) 
 pal(7,k[4])
 pal(13,k[5]) 
end

l={
 {0,0,0,0,0,1},
 {2,0,1,1,1,5},
 {4,0,1,5,13,5},
 {4,1,5,6,13,6},
 {8,1,5,7,13,7}
} 
 
function m()
 
 g(1,#l,1) 
 g(#l,1,-1) 
 pal() 
 fade()
end
__gfx__
00000000a9494994a9499494a4994994111111111111121111112111eeeeeeee11111111eeeeeeeeeeeabeee0000000001000000a9777794a9777794a9777794
00000000944444424444444294444442111111111311131111113131ee4eee4e11111111eeeeeeeeeeab3bee0000000010000000970000729700007297000072
00700700444444449424444244444444eeeeeeeee2e2e2eee2ee2e2eea44ea42ee2111eeeebb31eeeab3b31e000000002100000070a22a077073370770711707
00077000944444429494424494494442eeeeeeeee3e3e3eee3ee3e3ee942e944ee4222eeebb3b31eeb3b311e000000003100000070288207703bb307701cc107
00077000444444424444494294249442eeeeeeeee3ebe3eeebee3e3e19421444eee22eeeebbb311eeab3131e000000004200000070288207703bb307701cc107
00700700944444449444444444424444eeeeeeeee3eeebeeeeeebe3e14441444eee42eeebb33b331eb33311e000000005100000070a22a077073370770711707
00000000944444429444444294444442eeeeeeeeebeeeeeeeeeeeebee442e942eee22eeebb3b3111e3b3131e0000000065000000970000729700007297000072
00000000422424214224242142424241eeeeeeeeeeeeeeeeeeeeeeee00000000eee42eee00000000eb33311e000000007d000000427777214277772142777721
eee11eeeeeeeeeeeeee77eee7656566500000000000000000000000000000000eee42eee00000000e333131e0000000082000000a9777794eee011111110eeee
e11ab00eeee11eeeee7007ee6555555100000000000000000000000000000000eee22eee00000000eb3131ee000000009400000097000072ee01bbbbbbb10eee
e1a77b0eee1ab0eee70f907e5555555500000000000000000000000000000000eee42eee00000000ee3341ee00000000a900000070799707e01bb33333bb10ee
1a710610e1ab310e70faa9076555555100000000000000000000000000000000eee42eee00000000eee14eee00000000b3000000709aa907e1bb3bbbbb3bb1ee
1b705610e1b3110ee709407e5555555100000000000000000000000000000000eee22eee00000000eee92eee00000000c1000000709aa907e1b3bb111bb3b1ee
e1b6610eee0110ee70a009076555555500000000000000000000000000000000eee22eee00000000eee44eee00000000d500000070799707e1b3b10e01b3b1ee
e001100eeee00eeee707707e6555555100000000000000000000000000000000eee42eee00000000ee9442ee00000000e200000097000072e1b3b1ee01b3b1ee
eee00eeeeeeeeeeeee7ee7ee5115151000000000000000000000000000000000eee22eee000000000000000000000000f000000042777721e1bbb1e01bb3b1ee
ee7777eeeee77eeeee7777eea9777794a7777774a9494994a777777400000000eee42eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000e0111001bb3bb1ee
e711117eee7117eee711117e9700007270000007901111027000000700000000eee22eeee111eeeee111eeeee111eeeee111eeee00000000eeeee01bb3bb10ee
717ab307e717a07e717a9807702882077076650741a994147076650700000000eee42eee17fa011e17ab011e17cd011e17a9011e00000000eeee01bb3bb10eee
71ab3107717a940771a982077088880770600107919012127060010700000000eee42eee1f094a901a0b3ab01c0d1cd01a08298000000000ee011bb3bb1110ee
71b3310771a94207719882077028820770600107419102127060010700000000eee22eee1a9909401bb30b301dd10d101988082000000000ee1bbb3bbbbbb1ee
71311007e704207e718221077001100770511007914221047051100700000000eee22eeee000e00ee000e00ee000e00ee000e00e00000000ee1b33333333b1ee
e700007eee7007eee700007e9700007270000007901110027000000700000000eee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000ee1bbbbbbbbbb1ee
ee7777eeeee77eeeee7777ee4277772147777771422424214777777100000000eee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000ee011111111110ee
000000000000000000000000000000000000000000000000000000000000000011111111a7777774a7777774a7777774a7777774000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111170000007700000077000000770000007000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000eee00eee707aa907707aab07707ccd0770a99807000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000eee42eee70a9940770abb30770cdd10770988207000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000eee22eee70a9940770abb30770cdd10770988207000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000eee42eee7094420770b3310770d1100770822107000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000eee11eee70000007700000077000000770000007000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000eee00eee47777771477777714777777147777771000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee011110eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1bbbb1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee011110eeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1b33b1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1bbbb1eeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1b33b1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1b33b1eeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1b33b1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1b33b1eeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1b33b1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1b33b1eeeeee0110eeeeeeeeee
eee01111111110e0111111111110eee011111111110eeeee01111111101b33b1ee0111110e01111111111110011111111111101b33b1eee0111bb1110eeeeeee
ee01bbbbbbbbb1e1bbbb1bbbbbb10ee1bbbbbbbbbb10eee01bbbbbbbb11b33b1e01bbbbb0e1bbbbbbbbbbbb11bbbbbbbbbbbb11b33b1ee01bbbbbbbb10eeeeee
e01bb3333333b1e1b33bbb3333bb1ee1b33333333bb1ee01bb333333b11b33b101bb3bb10e1b3333333333b11b3333333333b11b33b1e01bb333333bb10eeeee
e1bb3bbbbbbbb1e1b333bbbbb33b10e1bbbbbbbbb3b10e1bb33bbbbbb11b33b11bb3bb10ee1bbbbbbb333bb11bbbbbbb333bb11b33b1e1bb3bbbbbb3bb1eeeee
e1b33b11111110e1b333b111bb3bb1e011111111b3bb101b33bb1111101b33b1bb3bb10eee0111111b33bb100111111b33bb101b33b101b3bb1111b33b1eeeee
e1b33b1111110ee1b33bb1e01b33b1eee0111111b33b11bb3bb10eeeee1b33b1b3bb10eeeeeeeee01b3bb10eeeeee01b3bb10e1b33b11bb3b11111b33b10eeee
e1bb3bbbbbbb10e1b33b10ee1b33b1e011bbbbbbb33b11b33b10eeeeee1b33bbbbb10eeeeeeeee01bbbb10eeeeee01bbbb10ee1b33b11b33bbbbbbb33bb1eeee
e01bb333333bb1e1b33b1eee1b33b101bbb33333333b11b33b1eeeeeee1b33333b11eeeeeeeee01bb3b10eeeeee01bb3b10eee1b33b11b333333333333b1eeee
ee01bbbbb333b101b33b1eee1b33b11bb3bbbbbbb33b11b33b1eeeeeee1b33333bb10eeeeeee01bb3bb1eeeeee01bb3bb1eeee1b33b11b33bbbbbbbbbbb1eeee
eee01111bbb3bb11b33b1eee1b33b11b33b11111b33b11b33b10eeeeee1b33bbb3bb10eeeee01bb3bb10eeeee01bb3bb10eeee1b33b11b33b11111111110eeee
eeeeeee011b33b11b33b1eee1b33b11b33b1ee01b33b11bb3bb10eeeee1b33b1bb3bb10eee01bb33b10eeeee01bb33b10eeeee1b33b11bb3b10eeee0110eeeee
e011111111b33b11b33b1eee1b33b11b33b1111bb33b101b33bb1111101b33b11bb3bb10ee1bb333b11111101bb333b11111101b33b101b3bb111111bb1eeeee
e1bbbbbbbbb3bb11b33b1eee1b33b11bb3bbbbbbb33b1e1bb33bbbbbb11b33b101bb3bb10e1b3333bbbbbbb11b3333bbbbbbb11b33b1e1bb3bbbbbbbbb1eeeee
e1b33333333bb101b33b1eee1b33b101bb333bb1b33b1e01bb333333b11b33b1e01bb3bb101b3333333333b11b3333333333b11b33b1e01bb3333333bb1eeeee
e1bbbbbbbbbb10e1bbbb1eee1bbbb1e01bbbbb11bbbb1ee01bbbbbbbb11bbbb1ee01bbbbb01bbbbbbbbbbbb11bbbbbbbbbbbb11bbbb1ee01bbbbbbbbb10eeeee
e011111111110ee011110eee011110ee0111110011110eee0111111110011110eee01111100111111111111001111111111110011110eee01111111110eeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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
0001010100000000000000000001010101000001000000000000000000010000000000010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1001010101200101000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000010101030000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040404040404040100000000000000000000000000000000000000000000000000000101010000000000000000060100090000000021040501000000000000000000000101020201000000000001020110010201013a010329000000000000000000000000000000000000000000000000000000000000003a2b010100000000
0000000000000001000000000000000000000000000000000000000000000000000012040101010103010101010103100224000000020301010000000000000000000001040604010000090000030504040504040106010401000000000000000000000000000000000900000009000000000000000009000104040100000000
000000000000002100000000000000000000000001210300000001210100000000000102010406040804040404040104060100000004040401000900000000000000000102200101210101000001000000000000010001010200000000000a000000000000000000010102010301010110010000000001030101010300000000
000000000000000100000000000000000000000003050107070702040100000000000504040000001800000000010400002001010001030101000102010000000000000104040401050420000001000000000000010004050400090900001a0000000000000007073c0406040404040604010900000001060204060400000000
00000000000000010000000000000000000000000120030321010120010000000000000000000000180000000005000000010401000104040100010401000000000000032101000302010100000200000000000001020101010301010239010110020000000001020100000000000000000301012a390101010000000a000000
000000000000000100000000000000000000090004040104040401040500000000000000000000001800000000000000000201032501000025012000030000000000000104200004040805000003000000000000030001040406050404060405060100000a002c0501000000000000000006040105040104040009001a000000
000000000000000101012001010101011001010201010220002001000000000000000000000000001800000000000000000406040401000001000101010000000000000101010000001800000001000000000000012a03000000000000000000000100001a0001003b0000000000000000000001010101030101010102013b01
000000000000000404040404040404040402050106040401010106000000000a000a00000120010018000000000000000000000a000102010100040504000000000a0001040600000018000000240000000000000508040000000000000000000002000001013a01200100000000000000000002050104060504040604040404
000000000000000000000000000000000001010300000004010400000900001a001a09000106010028000707070707000000001a000104040100000000090000001a000200000000001801010103000000000000001800000000000000000000000100000304062b042a00000000000000000001000200000000000000000000
0000000000000000000000000000000000050408000000000201030102012403100102012101212401010301010101011001020103010121010101020303240110010101000000000018010404010000000000000018000000000000000000000001020101010201250124000000000000000001290100000000000000000000
0000000000000000000000000000000000000018000000000104040404010504040504040104020408040405040406040504040404080504080404040604040404060401000900000028010707010000000000000018000000000000120102000004080605040404080501000000000000000005080400000000000000000000
0000000000000000000000000000000000000018000000000101030101010000000000000120010018000000000000000000000000180000180000000000000000000001030101020101010101010000000000000018000000000000030401000000280000000000280003000000000000000000180000000000000000000000
0000000000000000000000000000000000000018000000000504040608040000000000000408050018000000000000000000000000180000180000000000000000000004040405050408040404060000000000000018000000000000010201100201010103030101010201000000000000000000180000000000000000000000
0000000000000000000000000000000000000018000000000000000018000000000000000018000018000000000000000000000000180000180000000000000000000000000000000018000000000000000000000018000000000000040804040404080404040404080404000000000000000000180000000000000000000000
0000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000101020103010202011002010d000a000000000000000000000000000000000000000101011d001d1001010e0000000000000000000000000000000000000000000000000000000000000000000020010302010001200102000000000000000000000000000000000000000000032901000d01010000000000
0000000000090039040605040404040504010629001a00090000090000000000000000000000000000010408010004040408000000000000000000000000000000000000000000000000000000000000000000000001040504030001040501000000000000000000000900000000000000000000010402000204010000000000
000000000e0101020000000000000000000d010139010101020103010f000000000000000000000000011201010000000018000000000000000000000000000000000000000000000000000000000000000000000002000000010003000002000000000000000301020101010d00000000000000010101000101120000000000
00000000040204010000000000000000000604040104030501040404010000000000000f000000000005060805000000001800000000000000000000000000000000000009000000000000000000000000000000000d03010201001d012201000000000000000104043b04050400000000000900042504000508040000000000
00000000000301010d00000000000000000000000201010003010e00030000000000002a000002010301010200000a00001800000000000000000000000000000000000002200300000000000000000000000000000404040806000806040800000000000a0001010301000000000000000022010201200000180000000a0000
000000000004080405000a000000000000012b0004083a0001040400010000000000003a000003050204040100001a000018090000000000000000000000000000000e000104020f000000000000000000000d00000e00002800000103200100000000091a0005040404000000000000000001040405010000180009001a0000
000000000000180000001a000000000000010300002802000f0102012a000000000e01020301020102010301020f03021002030d0000000000000000000a0000000001002900010400000000000000000000010201250001030101290504022410010201010203010201010e0220010d10020300000001000d01030102010324
00000000000018000003012902000000000201000301020004050804040000000004040404040504040604080606050405082b040009000000000909001a00000000240039003a000000000000000900000001050401000106040401000001000404050404040406040404010401040505040100090001000408060401040405
1001020e00001800000206040300000000010200013801000009280000000900000000000900000000090918000000000018023a0301392a0103010302030100000003023b010100000a00000001010210030100000100010301010e03010100000000090000000000000002000100000000200101022000012a010001000000
0404080600001800000103010d000000000e01000101033b01030201010203011001020103020101010201030d030e0000180504043b04040604040406040200000f020502060400091a00000002040505040103010100040805040804040800000e010201242a01000000010103000000000604390404000300020001000000
0000180000001800000504080400000000050400040805040404080504060404040404390405040104010401040604000018000000020000000000000d29010000042a000100022c020301000003000000001d0604390000180000200120010000030404010406010000003a0605090000000000010122010101010001000000
00001800000018000000001800000000000000000018000000001800000000000000002900000003000201010000000000180000000f00000000000004060400000001002b000104040420000002000000000800000f000018000001050602000001000001000003000001010302010000000000080604043a08040003000000
00001800000018000000001800000000000000000018000000001800000000000000000d00000002000104080000000000180000000800000000000e020f03011002013c03253c0101010200000e00000000180000080000180000030000010000020101033a0102000002040405010000000000180000000101010102000000
0000180000001800000000180000000000000000001800000000180000000000000000050000000101030018000000000018000000180000000000040406040404080d040504040d060804000008000000001800001800001800000f030320000004080404040804000001012b01020000000000180000000408040406000000
0000180000001800000000180000000000000000001800000000180000000000000000000000000408040018000000000018000000180000000000000000000000180400000000040018000000180000000018000018000018000008040408000000180000001800000004080508040000000000180000000018000000000000
__sfx__
000500001155500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00090000275502b550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f55518500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d0000225501b550165500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000c0500f050160501d05029050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000113551b35516355133551d355183551b35500005243052730500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010d00001805316013000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
01180000100551004510025100151000500005000050000513055130451302513015000050000500005000050e0550e0450e0250e015000050000500005000051505515045150251501500005000050000500005
011800000c03300003000030c03300003000030c033000030e03300003000030e0330000300003000030000313033000030000313033000030000313033000030e03300003000030e03300003000030000300003
011800001c5521c5411c5221c511105150c5050c5050c5051f5551f5411f5251f511135150c5050c5050c5051a5521a5411a5221a5110e5150c5050c5050c5052155521541215252151115515005050050500505
0118002104552045410452204511105150050500505005050755507541075250751113515005050050500505025520254102522025110e5150050500505005050955509541095250951115515005050050500505
011800000c03300003306150c03300003000030c033000030e03300003306150e0330000330615000030000313033000033061513033000030000313033306150e03300003306150e03300003306153061500003
0118002004555045450452504515105151051510515105150755507545075250751513515135151351513515025550254502525025150e5150e5150e5150e5150955509545095250951515515155151551515515
0118002004551045410452104511105111051110511105110755107541075210751113511135111351113511025510254102521025110e5110e5110e5110e5110955109541095210951115511155111551115511
010c00200455504545045250451513515135151351513515075550754507525075150e5150e5150e5150e51502555025450252502515155151551515515155150955509545095250951510515105151051510515
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
01 07 08 43 44
00 07 08 43 44
00 09 08 43 44
00 09 08 43 44
00 0a 0b 43 44
00 0a 0b 43 44
00 0c 0b 43 44
00 0c 0b 43 44
00 0d 0b 43 44
00 0d 0b 43 44
00 0e 0b 43 44
02 0e 0b 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
