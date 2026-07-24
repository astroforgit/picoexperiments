pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- fruit thieves
-- by @egordorichev

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

function oline(x1,y1,x2,y2,c)
 for x=-1,1 do
  for y=-1,1 do
   line(x1+x,y1+y,x2+x,y2+y,c)
  end
 end
end

function noprint(s,x,y,c)
 s=smallcaps(s)
 prnt(s,x+4-#s*2,y,c)
end

cls()
m()

cartdata("fruit_thieves")

music(0)

function ckd(i)
 return dget(i)==1
end
local osfx=sfx
local omusic=music

function sfx(s)
 if g_sfx then
  osfx(s)
 end
end

function music(s)
 if g_music then
  osfx(s)
 end
end

function _init()
 g_music=not ckd(17)
 g_sfx=not ckd(18)
 g_time,state,g_tut,shk=
  0,menu,not ckd(16),0
  g_shk=false
 --restart_level()
 poke(0x5f2d,1)
end

function _update()
 lbx=bx
 bx=btn(—)
 lmb=mb
 mx,my,mb=stat(32),stat(33),stat(34)
 mbp=(lmb==0 and mb~=0)
 
 if state==ingame then
 e_update_all()
 do_movement()
 do_collisions()
 state.update()
 end
 g_time+=2
end

function _draw()
 if(state~=menu) cls(12)
 if shk>0 then
  shk-=2
  camera(rnd(shk)-shk/2,
   rnd(shk)-shk/2)
 else
  camera() 
 end
 state.draw()
 if(btn(Ž)) oprint(stat(1),2,2,12)
 spr(16,mx,my)
end

function restart_level()
 reload(0x2000,0x2000,0x1000)

 g_started=false

 g_money,shk,
 g_ammo,rate,g_lives,
 g_lost,g_won,g_score,
 g_wave=
  50,0,(g_tut and 10 or 20),1,3,
  false,false,0,0
  
 g_ammoadded,g_placed,g_pressed=false,false,false
 
 entity_reset()
 collision_reset()
 
 g_lvl=e_add(level({
  base=v(mid(0,3,flr(rnd(4)))*16,0),
  size=v(16,16)
 }))
 
 getpath(flr(g_spawn.pos.x/8+0.5),
  flr(g_spawn.pos.y/8+0.5),
  flr(g_goal.pos.x/8),
  flr(g_goal.pos.y/8))
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
 draw_order=5,
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

 local w,h=
  s.width or 1,s.height or 1

 local flip_x=false
 local frames=s[e.state] or s.idle
 
 if s_get("flips") then
  flip_x=e.flipped
 end

 local delay=frames.delay or 1
 if (type(frames)~="table") frames={frames}
 local frm_index=flr(e.t/delay) % #frames + 1
 local frm=frames[frm_index]
 spr(frm,round(p.x),round(p.y),w,h,flip_x)

 return frm_index
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
   ent.t+=2
  end  
 end
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
 local a=drawables[5]
 if a then
  for i=1,#a do
   local j=i
   while j>1 and a[j-1].pos.y>a[j].pos.y do
    a[j],a[j-1]=a[j-1],a[j]
    j=j-1
    end
   end
 end
 for o=0,15 do  
  for ent in all(drawables[o]) do
   r_reset(prop)
   ent[prop](ent,ent.pos)
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
 
  if ev.x>0 then
   ent.facing="right"
  elseif ev.x<0 then
   ent.facing="left"
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
     if o~=e then
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
   if oc and box:overlaps(oc.b) then
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

function oprint(s,x,y,...)
 s=smallcaps(s)
 prnt(s,x,y,...)
end

function coprint(s,y,...)
 s=smallcaps(s)
 prnt(s,64-#s*2,y,...)
end

function prnt(s,x,y,c,o)
 if(not o) o=sget(97,c)
 
 for xx=x-1,x+1 do
  for yy=y-1,y+2 do
   print(s,xx,yy,0)
  end
 end
 print(s,x,y+1,o)
 print(s,x,y,c)
end

function oline(x1,y1,x2,y2,c)
 for x=-1,1 do
  for y=-1,1 do
   line(x1+x,y1+y,x2+x,y2+y,c)
  end
 end
end

function noprint(s,x,y,c)
 s=smallcaps(s)
 prnt(s,x+4-#s*2,y,c)
end

function oline(x,y,x2,y2,c)
 color(sget(97,c))
 for xx=-1,1 do
  for yy=-1,1 do
   line(x+xx,y+yy,x2+xx,y2+yy)
  end
 end
 line(x,y,x2,y2,c)
end

function msay(s,c,m)
 e_add(text_fx({
  pos=v(mx+4,my-9+(m or 0)),
  c=c,
  s=s
 }))
end

text_fx=entity:extend({
 draw_order=14
})

function text_fx:init()
 self.s=smallcaps(self.s)
 self.pos.x-=#self.s*2
 self.c2=sget(97,self.c)
end

function text_fx:render()
 self.pos.y-=0.2
 prnt(self.s,self.pos.x,self.pos.y,self.t>100 and self.c2 or self.c)
 if(self.t>120) self.done=true
end
-->8
-- level
 
function block_type(blk)
 if (fget(blk,0)) return solid
end

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
    mset(b.x+x,b.y+y,0)
    blk=0
   end
  end
 end
end

function level:render()
 map(self.base.x,self.base.y,0,0,self.size.x,self.size.y)
end
--[[
function fill(x,y,w,h,v,t)
 if(type(x)=="table") t=x v=y x=1 y=1 w=14 h=13
 for xx=x,x+w-1 do
  for yy=y,y+h-1 do
   if(not t or t[xx][yy]) mset(xx,yy,(v<9 or rnd()<0.7) and v or v+16)
  end
 end
end

function patch(s,n)
 local off,cur={},{}
 for x=0,15 do
  off[x]={}
  cur[x]={}
  for y=0,15 do
   off[x][y]=rnd()<s
  end
 end
 
 for i=1,n do
  for x=1,14 do
   for y=1,14 do
    local v,cnt=off[x][y],0
    
    for xx=x-1,x+1 do
     for yy=y-1,y+1 do
      if((xx~=x or yy~=y) and off[xx][yy])cnt+=1
     end
     
     cur[x][y]=((v and cnt>3)or(not v and cnt>4))
    end
   end
  end
  cur,off=off,cur
 end
 return off
end]]
-->8
-- entities

gen=entity:extend({
 
})

function gen:die_fx()
 for i=1,2 do
   e_add(particle({
    pos=v(self.pos.x+4,self.pos.y+4),
    c=rnd()>0.7 and 5 or 7,
    r=4
   }))
  end 
end

function gen:say(s,c)
 e_add(text_fx({
  pos=v(self.pos.x+4,self.pos.y),
  c=c,
  s=s
 }))
end

function gen:init()
 self.menu=false
 if(self.sprite) self.sprite.flips=true
end

function gen:check_mouse()
 self.active=mchk(self.pos.x,self.pos.y,8,8)

 if mbp then
  self.menu=self.active
 end
end

function gen:idle()
 self:check_mouse()
end

function mchk(x,y,w,h)
 return mx>=x and mx<=x+w-1 and
  my>=y and my<=y+h-1
end

particle=entity:extend()

function particle:init()
 self.vel=v(rnd(2)-1,rnd(2)-1)
end

function particle:render()
 self.vel*=0.9
 self.r-=0.1
 circfill(self.pos.x,self.pos.y,self.r,self.c)
 if(self.r<0) self.done=true
end

coin=gen:extend()

function coin:render()
 local x,y=self.pos.x,self.pos.y
 
 if self.active and mbp then
  self.done=true
  self:die_fx()
  sfx(12)
  local a=flr(rnd(100)+25)
  msay("+"..a,10)
  g_money+=a
  g_score+=a
 end
 
 if(self.active) pal(0,1)
 spr(75,x,y)
 
 if self.t>360 then
  self.done=true
  self:die_fx()
  sfx(8)
 end
end 
-->8
-- towers
tower=gen:extend({
 time=30,
 cost=20,
 dist_val=16,
 max_hp=10,
 tags={"tower"}
})

function tower:init()
 self.t=0
 self.lvl=1
 self.dist=self.dist_val
 self.hp=self.max_hp
 self.next=self:calc()
 for t in all(entities_tagged["tower"]) do
  t:added(self)
 end
end

function tower:calc()
 return round(self.cost*(self.lvl+1)*0.6)
end

function tower:render()
 if(self.active) pal(0,1) 
 spr(self.tile,self.pos.x,self.pos.y)
end

function tower:get_tar()
 for e in all(entities_tagged["enemy"]) do
  if self:dto(e)<=self.dist then
   return e
  end
 end
end

function tower:dto(e)
 local dx,dy=e.pos.x-self.pos.x,
 e.pos.y-self.pos.y
 return sqrt(dx*dx+dy*dy)
end

function tower:idle()
 if self.t%self.time==flr(self.time/2)
 or  self.t%self.time==flr(self.time/2) + 1 then
  if(self.tar==nil or self.tar.done or self:dto(self.tar)>self.dist) self.tar=self:get_tar()
  if(self.tar or self.no_tar) self:use(self.tar)
 end
end

function tower:hit()
 if(self.hp>0) self:say("-1",8) self.hp-=1
 if self.hp==0 then
  self:die_fx()
  self.done=true
  if(self.die) self:die()
  local x,y=self:flr()
  sfx(6)
  mset(x+g_lvl.base.x,y+g_lvl.base.y,33)
 end
end

function gen:flr()
 return flr(self.pos.x/8),
  flr(self.pos.y/8)
end

function gen:rnd()
 return round(self.pos.x/8),
  round(self.pos.y/8)
end

function ocirc(x,y,r,c)
 color(sget(97,c))
 for xx=x-1,x+1 do
  for yy=y-1,y+1 do
   circ(xx,yy,r)
  end
 end
 circ(x,y,r,c)
end

function tower:use()

end

function tower:render_hud()
 if(self.menu) ocirc(self.pos.x+4,self.pos.y+4,self.dist,8)
 
 local x,y=self.pos.x,self.pos.y-8
 
 if self.menu then
  if self.lvl<3 then
   local m,g=mchk(x-10,y-11,20,10),
    g_money>=self.next
   noprint("^upgrade",x,y-9,g and (m and 7 or 11) or 8)
   noprint(self.next,x,y,10)
  
   if mbp and m then
    if g then
     g_money-=self.next
     self.lvl+=1
     self.dist+=8
     g_score+=20
     if(self.lvlup) self:lvlup()
     
     self.next=self:calc()
     sfx(1)
    else
     shk=10
     sfx(0)
    end 
   end
  end 
 elseif self.active then
  noprint(self.hp.." hp",x,y-9,for_hp(self.hp))  
  noprint(self.lvl.." lvl",x,y,11)  
 end
 self:check_mouse()
end

archer=tower:extend({
 tile=64,
 open=true,
 desc="^fires bullets"
})

function archer:use(tar)
 if g_ammo>0 then
 sfx(5)
 g_ammo-=1
 
 e_add(bullet({
  tar=tar,
  pos=v(self.pos.x+2,
  self.pos.y+2),
  dmg=self.lvl,
  speed=self.lvl
 }))
 
 end
end

bullet=entity:extend({
 hitbox=box(0,0,4,4),
 collides_with={"enemy"}
})

function bullet:init()
 local dx,dy=self.tar.pos.x-self.pos.x+2,
  self.tar.pos.y-self.pos.y+2
 local d=sqrt(dx*dx+dy*dy)
 
 self.vel=v(dx/d*self.speed,dy/d*self.speed)
 self:part()
end

function bullet:idle()
 self.last=v(self.pos.x,self.pos.y)
 if(self.pos.x<-4 or self.pos.y<-4 or self.pos.x>128 or self.pos.y>128) self.done=true
end

function bullet:render()
 spr(76,self.last.x,self.last.y)
 spr(76,self.pos.x,self.pos.y)
end

function bullet:part()
 for i=1,2 do
  e_add(particle({
   pos=v(self.pos.x+2,self.pos.y+2),
   c=rnd()>0.7 and 5 or 7,
   r=2
  }))
 end 
end

function bullet:collide(o)
 o:hit(self.dmg)
 self.done=true
end

ice=tower:extend({
 time=60,
 tile=65,
 open=ckd(2),
 cost=50,
 dist_val=8,
 desc="^slows enemies down"
})

function tower:place(t,f,tt)
 local x,y=self:flr()
 local s=flr((self.dist or self.dist_val)/8)
 for xx=-s,s do
  for yy=-s,s do
   local d=sqrt(xx*xx+yy*yy)
   if d<=s then
   local l=mget(x+xx+
   g_lvl.base.x,
   y+yy+g_lvl.base.y)
   if f and fget(l,0) 
    or l==tt then
    mset(xx+x+g_lvl.base.x,yy+y+g_lvl.base.y,t)
   end
   end
  end
 end
end

function ice:init()
 self:lvlup()
end

function ice:lvlup()
 self:place(5,true)
end

function ice:die()
 self:place(34,false,5)
end

fire=tower:extend({
 time=60,
 cost=75,
 tile=66,
 open=ckd(3),
 dist_val=8,
 desc="^sets enemies on fire"
})

function fire:init()
 self:lvlup()
end

function fire:lvlup()
 self:place(21,true)
end
function fire:die()
 self:place(34,false,21)
end

energy=tower:extend({
 tile=67,
 draw_order=3,
 desc="^increases nearby towers speed"
})

function energy:init()

end

function energy:lvlup()
 self.ts={}
 for t in all(entities_tagged["tower"]) do
  self:added(t)
 end
end

function tower:added(t) end

function energy:render()
 for t in all(self.ts) do
  oline(t.pos.x+4,t.pos.y+4,
   self.pos.x+4,self.pos.y+4,10)
 end
 tower.render(self)
end

function energy:added(t)
 if (t.powered) return
 local dx,dy=t.pos.x-self.pos.x,
  t.pos.y-self.pos.y
 local d=sqrt(dx*dx+dy*dy)
 t.time=max(10,t.time-10)
 
 if d<=self.dist_val then
  add(self.ts,t)
   t.powered=true

 end
end

click=tower:extend({
 tile=68,
 cost=50,
 open=ckd(1),
 desc="^increases ammo per click"
})

function click:init()
 rate+=0.5
end

function click:lvlup()
 rate+=1
end

mine=tower:extend({
 tile=69,
 cost=200,
 time=300,
 dist_val=32,
 open=ckd(4),
 desc="^throws bombs"
})

function mine:use(tar)
 
 if g_ammo>3 then
 sfx(5)
 g_ammo-=3
 e_add(bomb({
  pos=v(self.pos.x,self.pos.y),
  tar=tar
 }))
 else
  self:say("^no ammo",8)
 end
end

bomb=entity:extend({
 sprite={idle={91,92,93,94,delay=15}}
})

function bomb:init()
 local t=self.tar.pos
 self.vel=v(
  (t.x-self.pos.x)/10,
  (t.y-self.pos.y)/10
 )
end

function bomb:idle()
 self.vel*=0.9
 if self.t>=47 then
  self.done=true
  gen.die_fx(self)
  for e in all(entities_tagged["enemy"]) do
   local dx,dy=e.pos.x-self.pos.x,
    e.pos.y-self.pos.y
   local d=sqrt(dx*dx+dy*dy)
   
   if d<16 then
    e:hit(25)
   end
  end
 end
end

gold=tower:extend({
 cost=300,
 tile=70,
 time=300,
 no_tar=true,
 open=ckd(5),
 desc="^generates money"
})

function gold:use()
 local a=self.lvl*10
 self:say("+"..a,10)
 g_money+=a
end

auto=tower:extend({
 cost=500,
 tile=71,
 time=300,
 no_tar=true,
 open=ckd(6),
 desc="^generates ammo"
})

function auto:use()
 if g_ammo<20 then
  local a=self.lvl*3
  self:say("+"..a,6)
  g_ammo=min(20,g_ammo+a)  
 end
end

classes={archer,click,ice,fire,
 energy,mine,gold,auto}
-->8
-- enemies

spawn=entity:extend({
 sprite={idle={19}}
})

spawn:spawns_from(19)

function spawn:init()
 g_spawn=self
 self.wdone=false
 self.left=0
 g_wave=1
 self:calc()
 g_wave=0
 self.speed=120
end

function spawn:calc()
 self.left+=(g_wave==15 and 3 or g_wave*4)
end

function spawn:next()
 self:calc()
 self.t=0
 g_wave+=1
 self.speed=max(30,self.speed-10)
 self.wdone=false
end

function spawn:idle()
 if (self.wdone and self.t>360 and not g_lost and not g_won) self:next()
 if (not g_started) self.t-=1 
 if g_started and self.t%self.speed==0 then
  if self.left>0 and (not entities_tagged["enemy"] or #entities_tagged["enemy"]<10) then
   if(self.boss) return
   sfx(8)
   self.left-=1
   local a={guy}
   if(g_wave>3) add(a,police)
   if(g_wave>6) add(a,bug)
   if(g_wave>9) add(a,slime)
   if(g_wave>12) add(a,breaker)
   local c=a[flr(rnd(#a))+1]
   if(g_wave==15 and not self.boss) self.boss=true c=boss
   e_add(c({
    pos=v(self.pos.x,self.pos.y)
   }))
   gen.die_fx(self)
  end
 end
 if self.left==0 and 
  not self.wdone and #entities_tagged["enemy"]==0 then
  self.wdone=true
  sfx(9)
  self.t=0
  if (g_wave==15) g_won=true fade() sfx(14)
  if classes[g_wave+1] then 
   classes[g_wave+1].open=true
   dset(g_wave,1)
  end
 end
end

function spawn:render_stuff()
 if(self.t~=0 and self.t<120) coprint(self.wdone and "^wave complete!" or "^wave "..g_wave.."!",60,(self.t>110 or self.t<10) and 5 or 7)
end

goal=entity:extend({
 sprite={idle={35}}
})

goal:spawns_from(35)

function goal:init()
 g_goal=self
end

enemy=gen:extend({
 tags={"enemy"},
 max_hp=5,
 hitbox=box(0,0,8,8),
 cost=5,
 speed=30
})

function enemy:init()
 self.t=rnd(1024)
 self.tt=0
 self.vel=v(0,0)
 self.hp=self.max_hp+g_wave-1
 self.invt=0
 self.ind=#path
 if rnd()>0.5 and not self.boss then
  self.extra=87+flr(rnd(4))
 end 
 self.speed=max(5,self.speed-g_wave+1)
 self.sprite={idle={self.tile,self.tile+16,delay=15}}
end

function enemy:render_hud()
 if self.active then
 
  noprint(self.hp.." hp",self.pos.x,self.pos.y-8,for_hp(self.hp))
 end
end

function for_hp(h)
 local c=11
  if(h<4) c=9
  if(h==1) c=8
  return c
end

function enemy:render()
 if(self.active) pal(0,1)
 if self.invt>0 then
  self.invt-=1
  for i=1,15 do
   pal(i,7)
  end
 end
 spr_render(self)
 if (self.extra) spr(self.extra,round(self.pos.x),round(self.pos.y-1))
end 

function enemy:hit(a)
 if(self.invt>0) return
 
 self.hp-=a
 self.invt=5
 
 if self.hp<=0 then
  self.done=true
  g_money+=self.cost
  sfx(6)
  g_score+=flr(self.cost/5)
  self:die_fx()
  if(self.die) self:die()
 end
end

function enemy:idle()
 local x,y=self:rnd()
 local t=mget(x+g_lvl.base.x,y+g_lvl.base.y)
 
 if t==5 then
  self.pos-=self.vel/2
 elseif t==21 then
  if(self.tt%30==0) self:hit(1) 
  --[[if self.tt%15==0 then
   e_add(particle({
    pos=v(self.pos.x+4,self.pos.y+4),
    c=rnd()>0.7 and 2 or 8,
    r=3
   }))
  end--]]
 end
 
 self:check_mouse()
 if(self.tt%(self.speed*(t==5 and 2 or 1))==0) self.pnt=nil
 self.tt+=1  
 if self.tw then
  if(self.tt%60==0) self.tw:hit()
  if(self.tw.done) self.tw=nil self:onpnt()
 elseif self.pnt==nil then
  self:onpnt()
 end
end
function enemy:onpnt()
 self:default()
end
function enemy:default()
 
  self.ind-=1
  local p=path[self.ind] 
  if p then  
   self.pnt={p[1]*8,p[2]*8}
   local dx,dy=
   self.pnt[1]-self.pos.x,
   self.pnt[2]-self.pos.y
   self.vel.x=dx/self.speed
   self.vel.y=dy/self.speed
    
  else
   self.done=true
   g_lives-=1
   shk=10
   if g_lives==0 then
    if(not g_lost) sfx(10) fade() g_lost=true
   else
    cls(7)
    sfx(7)
    flip() 
   end
  end 
end
plt={7,6,5,1,0}
function fade()
 for i=1,#plt do
  cls(plt[i])
  flip()
 end
end

guy=enemy:extend({
 tile=96
})

police=enemy:extend({
 tile=97,
 max_hp=20
})

bug=enemy:extend({
 tile=98,
 max_hp=60,
 speed=96,
 cost=10
})

slime=enemy:extend({
 tile=99,
 max_hp=70,
 speed=60,
 cost=15
})

breaker=enemy:extend({
 tile=100,
 max_hp=50,
 speed=40,
 cost=20
})

function breaker:onpnt()
 local tw
 for t in all(entities_tagged["tower"]) do
  local dx,dy=t.pos.x-self.pos.x,t.pos.y-self.pos.y
  local d=sqrt(dx*dx+dy*dy)
  if d<=9 then
   tw=t
   self.vel=v(0,0)
   break
  end
 end
 if tw then
  self.tw=tw
 else
  self:default()
 end
end

boss=enemy:extend({
 tile=101,
 max_hp=300,
 speed=100,
 boss=true
})

function boss:die()
  g_won=true fade() sfx(14)

end
-->8
-- path finding
-- https://www.lexaloffle.com/bbs/?tid=2570
dirs={{1,0},{0,1},{-1,0},{0,-1}}
 --{1,1},{-1,-1},{1,-1},{-1,1}}

function good(x,y)
 return fget(mget(x+
 g_lvl.base.x,y+g_lvl.base.y),0)
end

function neighbors(v)
	res={}
	for d in all(dirs) do
		neighbor={v[1]+d[1],v[2]+d[2]}
  local x,y=neighbor[1],neighbor[2]
		if (x==to[1] and y==to[2]) or good(x,y) then
		 add(res,neighbor)
	  -- rectfill(x*8,y*8,x*8+7,y*8+7,8)
	  -- for i=0,0 do flip() end
	 end
	end
	
	return res
end

function getpath(fx,fy,x,y)
	path={}
	start={fx,fy}
	to={x,y}
	flood={start}
	camefrom={}
	camefrom[sr(start)]=nil

	while #flood>0 do
		local current=flood[1]
		
		if (current[1]==x and current[2]==y) break		
		neighbs=neighbors(current)
		
		if #neighbs > 0 then
			for neighb in all(neighbs) do
				if camefrom[sr(neighb)] == nil and not contains(camefrom,neighb) then
					add(flood,neighb)
					camefrom[sr(neighb)] = current
					
				end
			end
		end

		del(flood,current)
	end

	local c = {x,y}		
	while camefrom[sr(c)] ~= nil do
		add(path,c)
		c = camefrom[sr(c)]
	end
end

function sr(t)
	return t[1].."_"..t[2]
end


function contains(t,v)
	for k,val in pairs(t) do
		if (val[1] == v[1] and val[2] == v[2]) return true
	end
	
	return false
end
-->8
-- states

ingame={}

function ingame.update()
 if g_started and g_time%300==200 and rnd()>0.9 then
  sfx(13)
  local p=path[flr(rnd(#path-1))+2]
  e_add(coin({
   pos=v(p[1]*8,p[2]*8)
  }))
 end
end

function ingame.draw()
 
 r_render_all("render")
 r_render_all("render_hud")
 
 local s=g_money..""
 local w=#s*4
 oprint(s,13,120,10)
 spr(75,15+w,119)
 
 rectfill(4,4,30,5,5)
 sspr(96,26,26,2,4,4)
 sspr(96,24,flr(26*(g_ammo/20)),2,4,4)
 
 spr(44,1,1,4,1)
 local s="^wave "..g_wave
 oprint(s,37,2,9)
 local x=36+#s*4
 local m=mchk(x,1,8,8)
 if (m) pal(0,1)
 if m and mbp then
  sfx(4) 
  g_tut=false
  dset(16,1)
  if g_spawn.wdone or not g_started then
   g_spawn:next() 
   g_started=true
  else
   sfx(0)
   msay("^wave is not finished",9,32)
  end
 end
 spr(57,x,m and (mb~=0 and 3 or 2) or 1)
 pal(0,0)
 g_spawn:render_stuff()
 local m=mchk(1,119,8,8)
 if(m) pal(0,1)
 spr(56,1,m and 
 (mb~=0
  and 121 or 120) or 119)
 local mm=(bx and not lbx)
 
 if (m and mbp) or mm then
   g_ammoadded=true
  if(g_ammo<20)g_ammo+=1*rate
  sfx(4)
 end
 pal(0,0)

 for i=1,3 do
  spr(i<=g_lives and 59 or 58,128-i*8,1)
 end
 
 local cls={}
 for c in all(classes) do
  if(c.open) add(cls,c)
 end
 
 for i=1,#cls do
  
  local c,x=cls[i],
   128-i*8
  
  local m,cs=mchk(x,120,8,8),c.cost
  if m then
   coprint(c.desc,62,6)
  end
  if mbp and m then
   if c.pressed then
    c.pressed=false
    g_pressed=false
    shk=5
   else
    if g_money>=cs then
     c.pressed=true
     g_pressed=true
    else
     msay("^not enough money",9)
     sfx(0)
     shk=5
    end
   end
   sfx(c.pressed and 2 or 0)
  end 
  
  if c.pressed then
   local nx,ny=
    mid(0,15,flr(mx/8)),
    mid(0,13,flr(my/8))
   local lx,ly=nx*8,ny*8
   local n=mchk(lx,ly,8,8)
   
   if mbp and n then
    local g=fget(mget(nx+g_lvl.base.x,ny+g_lvl.base.y),1)
    if g_money>=cs and g then
     e_add(c({
      pos=v(lx,ly)
     }))
     g_score+=flr(cs/5)
     shk=10
     g_placed=true
     g_money-=cs
     mset(nx,ny,49)
     sfx(1)
    else
     msay(g and "^not enough money" or 
      "^bad position",9)
     sfx(0)
     shk=5
    end
    if(g) c.pressed=false
   elseif mbp and not m then
    c.pressed=false 
  
   end
   
    
   spr(c.tile,lx,ly)
  end

  
  if(m) noprint(cs.."",x,112,7) pal(0,1)
  
  spr(c.tile,x,120)
  pal(0,0)
 end
 
 local m=mchk(32,92,64,9)
 local s=cos(g_time/200)*3.5
 if g_lost then
  coprint("ŒŒŒŒŒ     ",32+s,5)
  coprint("^your garden",42+s,7)
  coprint("was destroyed",52+s,7)
  coprint("ŒŒŒŒŒ     ",62+s,5)
 
  coprint(pad(g_score).." points",82,10)
  coprint("^try again?",92,m and 11 or 12)
 elseif g_won then
  coprint("’’’’’     ",32+s,10)
  coprint("^your garden",42+s,7)
  coprint("is safe!",52+s,7)
  coprint("’’’’’     ",62+s,10)
 
  coprint(pad(g_score).." points",82,10)
  coprint("^continue",92,m and 11 or 12)
 elseif g_tut then
  if g_ammoadded then
   if(not g_tt) g_tt=0
   g_tt+=1
   if g_tt<300 then
   coprint("^you can upgrade your towers",86+s,7)
   coprint("by clicking on them",96+s,11)
   else
   coprint("^once you are ready",86+s,7)
   coprint("press the green button",96+s,11)
   local s=cos(g_time/60)*2.5
   spr(55,75-s,10-s,1,1,true,true)
   end
   
  elseif g_placed then
  coprint("^your towers consume ammo",76+s,7)
  coprint("^press the button at the",86+s,7)
  coprint("bottom left to generate it",96+s,7)
  --coprint("^also — can be used",96+s,6)
  local s=cos(g_time/60)*2.5
  spr(55,10+s,110-s,1,1,true,false)
  spr(55,30-s,15-s,1,1,true,true)
  oprint("^that's your ammo",42,20,6)
  elseif g_pressed then
  coprint("^and place it",86+s,7)
  coprint("on the map",96+s,7)
  else
  coprint("^select tower from",86+s,7)
  coprint("the bottom right",96+s,7)
  local s=cos(g_time/60)*2.5
  spr(55,110+s,110+s)
  end
 elseif not g_started then
  coprint("^press — for tutorial",96+s,7)
  if(btnp(—)) sfx(10) g_ammo=10 g_tut=true fade() shk=10
 end 
 
 if((g_won or g_lost) and m and mbp) _init()
end

function pad(n)
 n=n..""
 while #n<6 do
  n="0"..n
 end
 return n
end

menu={}

function menu.update()

end
local clrs={0,0,1,2,4,9,10,7,
 10,9,4,2,1,0,0}

function menu.draw()
 r_reset() 
 for i=1,700 do
  local x=rnd(128)
  local y=rnd(128)
  local v=(g_time/100
   +(sin(y/128+0.5)+cos(x/128)))
  
  circ(x,y,1,clrs[flr(v%1*#clrs)])
 end
 if(g_time<30) return
 if(not g_shk) g_shk=true shk=10 sfx(1)
 for i=0,127,16 do
  spr(64+i/16%8,4+cos(g_time/60+i/56)*3.5,
   (i+g_time/2)%136-8)
  spr(64+i/16%8,116+cos(g_time/60+0.5+i/56)*3.5,
   (i+g_time/2)%136-8)
 end
 coprint("^fruit",32,7)
 sspr(0,64,94,32,17,40)
 local s=cos(g_time/200)*3.5
 coprint("‰‰‰‰‰    ",98+s,10)
 coprint("^press — to start ",108+s,7)
 coprint("‰‰‰‰‰    ",118+s,10)
 coprint("^by @egordorichev",73,6)
 coprint("^music by @gruber",80,6)
 if (btnp(—)) sfx(15) shk=10 restart_level() state=ingame fade()
 local m=mchk(19,30,8,8)
 if m and mbp then
  sfx(13)
  g_music=not g_music
  
  omusic(g_music and 0 or -1)
  
  dset(17,g_music and 0 or 1)
 end
 ospr(43-(g_music and 0 or 16),19,m and (mb~=0 and 32 or 31) or 30)
 local m=mchk(29,30,8,8)
 if m and mbp then
  sfx(13)
  g_sfx=not g_sfx
  dset(18,g_sfx and 0 or 1)
 end
 ospr(42-(g_sfx and 0 or 16),29,m and (mb~=0 and 32 or 31) or 30)

end

function ospr(s,x,y)
 for i=1,15 do pal(i,0) end
 for xx=x-1,x+1 do
  for yy=y-1,y+1 do
   spr(s,xx,yy)
  end
 end
 r_reset()
 spr(s,x,y)
end
__gfx__
00000000aabaabab99494994dd1dd1d1665656656c66c66c00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000abbbbbb394444442d1111110655555516ccccccd00000000000000000000000000000000000000000000000010000000000000000000000000000000
00700700bbb3bbb3444442421111111155555151cccccccc00000000000000000000000000000000000000000000000021000000000000000000000000000000
00077000ab3babbb94444944d1111110655556556ccccccd00000000000000000000000000000000000000000000000031000000000000000000000000000000
00077000abbabbb3442444421111111055155551cccccccd00000000000000000000000000000000000000000000000042000000000000000000000000000000
00700700bbbbbbbb94944444d1111111656555556ccccccc00000000000000000000000000000000000000000000000051000000000000000000000000000000
00000000abbbbbb394444442d1111110655555516ccccccd00000000000000000000000000000000000000000000000061000000000000000000000000000000
00000000b33b3b33424224221001010051511511cddcdcdd0000000000000000000000000000000000000000000000007d000000000000000000000000000000
e1eeeeeeaabaabab99494994bb3b3bb36656566598998989000000000000000000000000000000008eeeeeee8ee77eee82000000000000000000000000000000
161eeeeeabbbbbb394444442b333333165555551988888880000000000000000000000000000000028e77e7e28e777ee94000000000000000000000000000000
1761eeeebbbb1bbb4444644233331331555555518888888200000000000000000000000000000000e2877ee7e287ddeea9000000000000000000000000000000
17761eeeabb1adb394465544b333b3336555555598888888000000000000000000000000000000007728d7e7ee28eeeeb3000000000000000000000000000000
177761eebbbbdbb34465514233133331555555519888888200000000000000000000000000000000777287e7e7728eeec1000000000000000000000000000000
177111eeabbbbbbb94411444b3b33333655555558888888800000000000000000000000000000000d77728e7777728eed5000000000000000000000000000000
e1161eeeabbbbbb394444442b3333331655555519888888200000000000000000000000000000000edd7728dd77de28ee2000000000000000000000000000000
eeeeeeeeb3b33b334242242231131311515115118282282200000000000000000000000000000000eeedde2eeddeee2ef0000000000000000000000000000000
00000000abaabaab9949499499400049000000000000000000000000000000000000000000000000eeeeeeeeeee77eeeee0000000000000000000000000000ee
00000000abbbbbb394444442940ab104242442410000000000000000000000000000000000000000eee77e7eeee777eee077777777777777777777777777770e
00000000bbbbbbbb4444444200a3b310422222220000000000000000000000000000000000000000e7777ee7eee7ddee07000000000000000000000000000070
00000000abbbbbb394444444b101350b4222222100000000000000000000000000000000000000007777d7e7eee7eeee070eeeeeeeeeeeeeeeeeeeeeeeeee070
00000000bbbbbbb344444442331010b12121121100000000000000000000000000000000000000007777e7e7e777eeee070eeeeeeeeeeeeeeeeeeeeeeeeee070
00000000abbbbbbb94444444b15010b3000000000000000000000000000000000000000000000000d7777de77777eeee07000000000000000000000000000070
00000000abbbbbb39444444233150b3beeeeeeee0000000000000000000000000000000000000000edd77e7dd77deeeee077777777777777777777777777770e
00000000b33b3b334242242231b10bb3eeeeeeee0000000000000000000000000000000000000000eeeddedeeddeeeeeee0000000000000000000000000000ee
00000000abaabaabaabaabababaababb000000000000000000000000e00eeeeeeee00eeee0eeeeeeee0e0eeeee0e0eee88888888888888888888888888eeeeee
00000000abbbbbb3abbbbbbbabbbbbb30000000000000000000000000760ee0eee0cd0ee0b0eeeeee01020eee08080ee22222222222222222222222222eeeeee
00000000bbbbbbbbbbbbbbb000bbbbb300000000000000000000000007760070e00d100e0ab0eeee0122220e0878880e55555555555555555555555555eeeeee
00000000abbbbbb3abbbbb0ab10bbbbb000000000000000000000000e07760700cdc51500bbb0eee0122220e0888820e11111111111111111111111111eeeeee
00000000bbbbbbb3bbbbb0a13310bbb3000000000000000000000000ee0777700d1515500bb30eeee02220eee08820eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000abbbbbbbabbbb0b3b150bbb3000000000000000000000000ee007770e001500e0b30eeeeee020eeeee020eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000abbbbbb3abbb0b3b33150bbb000000000000000000000000e0777770ee0550ee030eeeeeeee0eeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000b33b3b33b33b0bb331b10b33000000000000000000000000ee00000eeee00eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eeee000eeeeee00eee000000000000000000000000e0000eeee00eeeee000000000000000000000000
e0e00e0ee0e00e0ee0e00e0ee0e00e0eee0eeeeeeee00eeee07a90eeee0760ee000000000000000000000000077aa0ee0940eeee000000000000000000000000
e006500ee006100ee00a800ee007400ee060eeeeee0650eee0a90eeee076110e0000000000000000000000000799a0ee0420eeee000000000000000000000000
e0d5510eee0cd0eee088280ee07a940ee0760eeee076510ee0aaa0eee065510e0000000000000000000000000a9a90eee00eeeee000000000000000000000000
ee0610eeee0d10eeee0980eee0a9440ee07760eee065110eee09a0eee065110e0000000000000000000000000a9a90eeeeeeeeee000000000000000000000000
ee0d50eee06c510eee0820eee0aa940ee07760eee066510ee07a90eee065510e0000000000000000000000000a9a90eeeeeeeeee000000000000000000000000
ee0610eee0cdc50eee0910eee0a9440ee07760eeee0510eeee0a0eeee065110e0000000000000000000000000aa940eeeeeeeeee000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000e0000eeeeeeeeeee000000000000000000000000
00000000000000000000000000000000000000000000000000000000e0e00e0eeee00eeeeee00eeeeee00eeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeee00000000
00000000000000000000000000000000000000000000000000000000e00a900eee0d10eeee09f0eeee0a80eeeeee080eeeee0eeeeeeeeeeeeeeeeeee00000000
00000000000000000000000000000000000000000000000000000000e0a9940ee0d1150ee09ff40ee0a8820eeee050eeeee080eeeee00eeeeee00eee00000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeee0ee0eeeeeeeeeeee0d10eeee0d10eeee0d10eeee0770ee00000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeee00eeeeeeeeeeeee0110eeee0110eeee0110eeee0760ee00000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeee00eeeeee00eeeeee00eee00000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
eee00eeeeee00eeeeeeeeeeeeeeeeeeeeee00eeeeee00eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0760eeee0d10eeeeeeeeeeeee00eeeee0940eeeee00eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee05f0eeee04f0eeee000eeee003300eee04f0eeee0ab0ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e067760ee061150ee021200ee037b30ee07b310eee0bb0ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
0f55510e0fd9150e0242120e037bbb30e0b3310ee000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000
e0677f0ee0d24f0e092146d003bbbb300fb24f0ee067d60e00000000000000000000000000000000000000000000000000000000000000000000000000000000
e0500010e0d0005002122d50e033330ee0b000100a0d101000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0bb0051000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee00eeeeee00eeeeeeeeeeeeee00eeeeee00eeeeee00eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0760eeee0d10eeeeeeeeeeee0330eeee0940eeeee00eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee05f0eeee04f0eeee000eeee037b30eee04f0eeee0ab0ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e067760ee061150ee021200ee07bb30ee07b310eee0bb0ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e05551f0e0d915f00242120ee03bb30ee0b3310ee000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000
e0f7760ee0f2450e09216d0ee03bb30ee0f241f0e061d60e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0500010e0d00050e0212d50ee033330e0b00010e0a0d701000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0bb0051000000000000000000000000000000000000000000000000000000000000000000000000000000000
e00000000000000000e000eeeeeee000e000e0000000000000e000eeeeeeee000e0000000000000e0000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00777777777777777000700eeeee007000700077777777777000700eeeeee007000777777777770007777777777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
07777777777777777707770eeeee077707770777777777777707770eeeeee077707777777777777077777777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0d777777777777777d07770eeeee077707770777777777777d07770eeeeee07770777777777777d0777777777777d0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00dddddd777dddddd007770eeeee077707770777ddddddddd007770eeeeee07770777ddddddddd00777ddddddddd00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0000000777000000007770eeeee077707770777000000000007770eeeeee07770777000000000007770000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770000000777077707770eeeeeeeee07770eeeeee077707770eeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee077777777777770777077700000000ee07770eeeeee0777077700000000ee07770000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee0777777777777707770777777777700e07770eeeeee07770777777777700e077777777777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee0777777777777707770777777777770e07770eeeeee07770777777777770e077777777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee0777ddddddd777077707777777777d0e07770eeeeee077707777777777d0e0d7777777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee0777000000077707770777ddddddd00e07770eeeeee07770777ddddddd00e00ddddddddd7770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee07770777077700000000ee07770eeeeee0777077700000000eee00000000007770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeeeeeeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeeeeeeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee07770eeeeee077707770eeeeeeeeeeeeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee077700eeee0077707770eeeeeeeeeeeeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee0777077707770eeeeeeeee0777700ee00777707770eeeeeeeeeeeeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee077707770777000000000007777700007777707770000000000e00000000007770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee07770777077777777777700d777777777777d07777777777770007777777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee07770eeeeee07770eeeee077707770777777777777700d7777777777d007777777777777077777777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee0d7d0eeeeee0d7d0eeeee0d7d0d7d0d77777777777d000d77777777d000d77777777777d0d77777777777d0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee00d00eeeeee00d00eeeee00d000d000ddddddddddd00e00dddddddd00ee0ddddddddddd000ddddddddddd00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee000eeeeeeee000eeeeeee000e000e0000000000000eee0000000000eeee000000000000e0000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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
0002010000010000000000000000000000020100000100000000000000000000000201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2113212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212113212121212121212121212121212121212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212222222222222222221222222121222222222222222222012222222213132222222221222222222221222222212122012222222222022222222222122121210121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212221112121212121212121222121222121212101212122212221212121212121212221222121112221122122212122212221210121211121212121222121212121212101212111212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2112220221222222222202220121222121222103030303032122212221030303211222022221222122222221220122212122212221222222222222222201222121212121212121212121212121012121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121222121210121222121222121222103030303032122212221030303212221212121222102212121222122212102212221222121212121212221222121212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122222222122101212121220222222121222121212121212122222221030303212222222202222122222222222122212122212221222122122222212221222121212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212121212121212121212121212121222222222222210121212121212121212111212121212101212121212122212122112221223223332102212221222121211121212121210121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212202222212212111222202222121212121212122212222220122222221212222222222222222222202222222212112212221222121212122012221222121212121212121212121210121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122112221212122212121222121222121212121212122212221222122212221212221212121212121212121212121212122212221222222222222212221022121212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212221212122012222222121122121222222222122212221221122212221211221222202212212222211222222212122210221212121212121112221222121012121212121212121211121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212222212122212221212121222121222121222122222221222222212221212221220122212221212201222102212122212222222222222212222221222121212121012121112121210121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212122210122212221212121222121222121222121212121212121212221212221222122212221212221222122212122212121212121212121212121222121212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122222222212122022211210121222121222121222222222222222222222221212222222122222221212222222122212122222222222222222222222222222121212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212132233332233321212121212121212121212121212121212121212121212121213223332121212121212121212121212121212121212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000000c35300325003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
002000000c35300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000b00001115500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
001000000c15300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
000a00000c15500100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
001000000f25400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204
010c00001a355113350a3150030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305
010900001d351113510a3510335500301003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
011000000c33505315003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305
0110000024355163251b3351f34500005000051830511305163050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
00100000223551b355133550a3350f325073150a30500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
00100000163730c353003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
001000001d25022250242000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
011000002715527105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
01100000223551635518355133550030516355223551b3551b3550030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305
001000000a355113550c35513355183551b3552435500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
011000200a0750a0650a0550a0450a0350a0150000500005000050000500005000050000500005000050000505075050650505505045050350501500005000050000500005000050000500005000050000500005
011000000c0750c0650c0550c0450c0350c015000050000500005000051604516035160251601516015160150f0750f0550f0450a0750a0550a04503075030650305503045030350301500005000050000500000
011000000f0750f0650f0550f0450f0350f015070750706507055070450702507015070050000500005000001607516065160550c0750c0650c05505075050650505505045050350502505015050050000000000
011000000c0750c0650c0550c0450c0250c01500075000650005500045000250001500005000050000000000070750706507055070450702507015000050000500005000050c0750c0650c0550c0450a0550a035
011000000a0750a0650a0550a0450a0250a0150a0750a0650a0550a0450a0250a015000050000500000000000c0750c0650c0550c0450c0250c0150007500065000550004500025000150a0750a0350f0750f035
011000000f0650a0550a0450a0350a025110650c0550c0450c0350c0250c0150f065070550704507035130650f0550f0450f0350f0250f0150f0050305203042030320302203012030150a0520a0420a0320a025
011000000c0750a065070550504503025000000000000000070750a0650c0550f035110150000000000000000c0750c0650c0550c0350c0250c0150000000000030520304203032030250a0520a0420a0320a025
01100020005530f5050f5050f505005530f5050f5050f505005530f5050f5050f505005530f5050f5050f5050055316505165051650500553165051650516505005531b5051b5051b50500553165051650516505
011000000000000000000000000000000000001675516735167151675516745167351672516715000050000500005000050000500005000050000511755117351171511755117451173511025110150000000000
011000000000000000000000000000000000001875518735187151875518745187351872518715167551673516715000001b7551b7351b7151675516735167150f7550f7350f7150f7551b7450f7351b7251b715
0110000000000000001d5141d5101d5121d5151675516735167151675516745167351672516715225142251024511245102451024512245122451511755117351171511755117451173511025110152751427510
011000001f5101f5101f5101f5121f5121f5151875518735187152751024510245102451224515167551673516715000001b7551b7351b7152e5142251022512225100f7350f7152b51429510275102751227510
011000002750027502275051b7451b7251b7151b7451b7251b7151374513725137151374513725137152b50420500205002050522745227252271522745227252271527745277252771527745277252771514745
01100000005530a5050a5050050000553245152751524515005532b5152451524515005532e51522515225150055324515275152451500553225152b51522515005531f515205152251500553275151b5151b515
011000002750027502275051b7451b7251b7151b7451b7251b7151374513725137151374513725137152b50420500205002050522745227252271522745227252271527745277252771527745277252771514745
01100000005532e515305152e51500553305152e5153051500553335152751527515005532b5152c5152e515005532c5153751533515005532e5152c5152b5150055329515275152951500553275151b5151b515
011000001f7041f7001f7241f7201f7201f72022720227202272022720227201b7201d7201d7201d7201d7201d7201d7251d7001b7201d7201d7221b7201d7201b7201d7201d7201d7201d7201d7221d71527700
01100020005530f5150f5150f515005530f5150f5150f515005530f5150f5150f515005530f5150f5150f5150055316515165151651500553165151651516515005531b5151b5151b51500553165151651516515
01100020005530f5150f5150f515005530f5150f5150f515005530f5150f5150f51500553165151651516515005531b5151b5151b51500553225152251522515005531b5151b5151b51500553165151651516515
011000200050327720247202472024722247221b7201b7201b7201b7201b7201b7221b7221b7250f505187201b7201b7201b720187201b7201f7201b7201b7201b7201b7201b7221b72500503165051650516505
011000202b7042b7002b7242b7202b7202b7202e7202e7202e7202e7202e720277202972029720297202972029720297252970027720297202972227720297202772029720297202972029720297222971533700
011000002702522025220252201522015290252402524025240252401524015270251f0251f0151f0152b0252702527025270252701527015270051b0221b0221b0221b0221b0221b01522022220222202222015
0110000000000000002702522025220252201522015290252402524025240252401524015270251f0251f0151f0152b0252702527025270252701527015270052702227022270222702227022270152e0222e022
001000002e0222e0222e0122e01500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 10 17 43 44
01 11 17 43 44
00 10 17 18 44
00 11 17 19 44
00 10 17 1a 44
00 11 17 1b 44
00 10 17 1a 44
00 11 17 1b 44
00 12 1d 1c 44
00 12 1f 1e 44
00 12 1d 1c 44
00 12 1f 1e 44
00 10 17 18 44
00 11 17 19 44
00 10 17 1a 44
00 11 17 1b 44
00 10 17 1a 44
00 11 17 1b 44
00 12 1d 1c 44
00 12 1f 1e 44
00 12 1d 1c 44
00 12 1f 1e 44
00 13 21 20 44
00 14 22 23 44
00 13 21 24 44
00 14 21 23 44
00 15 21 25 44
00 15 21 25 44
00 15 21 26 44
00 15 21 26 44
00 16 21 25 44
00 16 21 26 44
02 10 17 27 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
