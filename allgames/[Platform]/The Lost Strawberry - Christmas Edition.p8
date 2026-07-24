pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- the lost strawberry x-mas edition
-- by @egordorichev


cartdata("xmas_7")
colors={
 {8,3,7},
 {11,13,7},
 {4,5,7},
 {3,9,7},
 {2,1,7},
 {8,2,10},
 {3,1,11}
}

-- logo ;p
local a="0000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555550000000000000000000005555555555550000000000000000000555155555555500000000000000000005551555555555000000000000000000055555555555550000000000000000000555555555555500000000000000000005555555555555000000008888888800055555550000000000000008888888880555555500000000000000008880008888555555555500000000000080000000558888000000000000005000000000005555558000000000000050000000005555555500000000000000550000005555555555555000000000005550000555555555550050000000000055550055555555555500500000000000555555555555555555000000000000005555555555555555550000000000000005555555555555555500000000000000055555555555555550000000000000000055555555555555500000000000000000055555555555550000000000000000000055555555555000000000000000000000055555555500000000000000000000000055550555000000000000000000000000555000550000000000000000000000005500000500000000000000000000000050000005000000000000000000000000555000055500000000000000000000000000000000000000000000"function b() for c=0,31 do for d=1,31 do e=d+c*32 pset(d+48,c+48,tonum(sub(a,e,e))) end end end function f() print("@egordorichev",38,81,7) b() flip() for e=1,5 do flip() end end function g(h,i,j) for e=h,i,j do local k=l[e] pal(8,k[1]) pal(1,k[2]) pal(5,k[3]) pal(7,k[4]) f() end end l={{0,0,0,0},{2,0,1,1},{4,0,1,5},{4,1,5,6},{8,1,5,7}} function m() g(1,#l,1) g(#l,1,-1) pal() end

function _init()
 g_time=0
 g_index=(dget(0) or 0)
 g_hat=max(1,dget(10) or 1)
 --g_money=(dget(11) or 0)
 g_strawberries=(dget(1) or 0)
 g_deaths=(dget(2) or 0)
 g_minutes=(dget(3) or 0)
 g_seconds=(dget(4) or 0)
 g_hours=(dget(5) or 0)
 g_color=(dget(7) or 1)
 
 menuitem(3,"restart the lvl",function()
  g_lost=true
  restart_level()
 end)
 
 menuitem(4,"reset progress",function()
  reset()
  dset(11,0)
  dset(10,1)
 end)
 
 g_c=colors[g_color]
 if not g_c then
  g_color=1
  g_c=colors[g_color]
 end

 cls()
 
 g_state=menu 
 music(17)
 
 restart_level()
end

function next_palt()
 g_color+=1
 if g_color>#colors then
  g_color=1
 end
 g_c=colors[g_color]

 dset(7,g_color)
end

local obtn=btn
function btn(b,p)
 if b==4 or b==5 then
  return obtn(4,p) or obtn(5,p)
 end
 return obtn(b,p)
end
local obtnp=btnp
function btnp(b,p)
 if b==4 or b==5 then
  return obtnp(4,p) or obtnp(5,p)
 end
 return obtnp(b,p)
end

function _update60()
 g_state:update()
 g_time+=1
 
 if g_time%60==0 and not g_guy.won then
  g_seconds+=1
  if g_seconds>=60 then
   g_minutes+=1
   g_seconds=0
   if g_minutes>=60 then
    g_minutes=0
    g_hours+=1
   end
  end
 end
 
 if (btnp(4,1)) next_palt()
end
function _draw()
 g_state:draw()
end
function reset()
 for i=0,6 do
  dset(i,0)
 end
 _init()
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
 dynamic=true,
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
 if s.turns then
  frames=frames.r
  flip_x=(e.facing=="left")
 end
 if s_get("flips") then
  flip_x=e.flipped
 end

 local delay=frames.delay or 1
 if (type(frames)~="table") frames={frames}
 local frm_index=flr(e.t/delay) % #frames + 1
 local frm=frames[frm_index]
 local f=(e.bold and ospr or spr)
 f(frm,round(sp.x),round(sp.y),w,h,flip_x,false,e)

 return frm_index
end

function ospr(s,x,y,w,h,f,hr,e)
 for i=0,15 do pal(i,0) end
 for xx=x-1,x+1 do
  for yy=y-1,y+1 do
   spr(s,xx,yy,w,h,f)
  end
 end
 r_reset()
 e:set_pal()
 spr(s,x,y,w,h,f)
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
   del(entities_with[t],e)
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
-->8
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
   ent[prop](ent,ent.pos)
  end
 end
end

function r_reset()
 pal()
 palt(0,false)
 palt(3,true)
 pal(8,g_c[1])
 pal(11,g_c[2])
 pal(7,g_c[3])
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
      if o~=e then
       local ec,oc=
        c_collider(e),c_collider(o)
       if ec and oc then
        c_one_collision(ec,oc)
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
        c_one_collision(ec,oc)
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
   if oc and oc.e.state~="hidden" and box:overlaps(oc.b) then
    return oc.e
   end
  end
 end
 return nil
end

function c_one_collision(ec,oc)
 if ec.b:overlaps(oc.b) then
  c_reaction(ec,oc)
  c_reaction(oc,ec)
 end
end

function c_reaction(ec,oc)
 local reaction,param=
  event(ec.e,"collide",oc.e)
 if type(reaction)=="function" then
  reaction(ec,oc,param)
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

function c_push_out(oc,ec,allowed_dirs)
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
   e.supported_by=support
   if support and support.vel then
    e.pos+=support.vel
   end
  end
 end
end
-->8
sbox=box(0,0,8,8)
nobox=box(0,0,0,0)

-- entities
particle=entity:extend()
 function particle:init()
  self.draw_order=(rnd()>0.75 and 10 or 1)
  self.pos=v(rnd(128),rnd(128))
  self.sz=self.draw_order/10
  self.sp=0.3+rnd(1)
  self.t=rnd(100)
 end
 function particle:render()
  local x,y,sz=self.pos.x,
   self.pos.y,self.sz
  rectfill(x,y,x+sz,y+sz,7)
 end 
 function particle:idle(t)
  self.pos+=v(self.sp,cos(t/100)/2)
  if (self.pos.x>128) self.pos=v(-10,rnd(128)) 
 end
 
bar=entity:extend({
 draw_order=0
})
 function bar:init()
  self.pos=v(rnd(128),rnd(128))
  self.sz=v(rnd(5)+5,rnd(3)+2)
  self.spd=rnd(1)+0.3
 end
 function bar:idle()
  self.pos.x+=self.spd
  if self.pos.x>128 then
   self.pos=v(-20,rnd(128))
  end
 end
 function bar:render()
  local x,y=self.pos.x,self.pos.y
  rectfill(x,y,x+self.sz.x,y+self.sz.y,11)
 end

-- level

function block_type(blk)
 if (fget(blk,0)) return solid
 if (fget(blk,1)) return support
 return nil
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
     mset(b.x+x,b.y+y,25)
     blk=0
    end
    local bt=block_type(blk)
    if bt then
     bl=bt({
      pos=v(x,y)*8,
      map_pos=b+v(x,y),
      typ=bt,
      tile=blk
     })
     if (bl.needed) e_add(bl)
    end
   end
  end
 end
 function level:render()
  pal(10,0)
  map(self.base.x,self.base.y,
   0,0,self.size.x,self.size.y)
 end
solid=static:extend({
 tags={"walls"},
 hitbox=sbox
})

support=solid:extend({
 tags={"walls","bridge"},
 hitbox=box(0,0,8,1)
})

 function solid:init()
  local dirs={v(-1,0),v(1,0),v(0,-1),v(0,1)}
  local allowed={}
  local needed=false
  for i=1,4 do
   local np=self.map_pos+dirs[i]
   allowed[i]=
    block_type(mget(np.x,np.y))
     ~=solid
   needed=needed or allowed[i]
  end
  self.allowed=allowed
  self.needed=needed
 end
 
 function solid:collide(e)
  if (e.nocol) return
  return c_push_out,self.allowed
 end
 
 function support:collide(e)
  if (not e.vel) return
  local dy,vy=e.pos.y-self.pos.y,e.vel.y
  if vy>0 and dy<=vy+1 then
   return c_push_out,{false,false,true,false}   
  end
 end
 
launcher=entity:extend({
 sprite={
  idle={3},
  extended={2},
  toext={92},
  toidle={92}
 },
 draw_order=5,
 hitbox=box(0,5,8,8),
 collides_with={"guy"}
})
 launcher:spawns_from(3)
 function launcher:collide(o)
  if self.state=="idle" and   g_guy.state~="to_spawn" and   not o.supported_by then
   o:become("fly")
   o.vel.y=-4.25
   o.chr=0
   self:become("toext")
   sfx(26)
  end
 end
 function launcher:extended(t)
  if (t>=2) self:become("toidle")
 end
 function launcher:toidle(t)
  if (t>=2) self:become("idle")
 end
 function launcher:toext(t)
  if (t>=2) self:become("extended")
 end
 
spikes=entity:extend({
 draw_order=3,
 hitboxes={
  [21]=box(1,4,7,8),
  [20]=box(1,0,7,4),
  [4]=box(0,1,4,7),
  [5]=box(4,1,8,7)
 },
 collides_with={"guy"}
})
 spikes:spawns_from(
  21,20,4,5
 )
 function spikes:init()
  self.hitbox=spikes.hitboxes[self.tile]
  self.sprite={idle={self.tile}}
 end
 function spikes:collide(o)
  if(g_guy.state~="to_spawn" and o:is_a("guy")) o:kill()
 end
 function spikes:render()
  local t=self.t
  --[[if t%30<15 then
   pal(1,g_c[2])
   pal(2,g_c[1])
  end]]
  spr_render(self)
 end
 
ladder=entity:extend({
 draw_order=3,
 tags={"ladder"},
 hitbox=box(2,0,3,8)
}) 
 ladder:spawns_from(
  6,22,7
 )
 function ladder:init()
  self.sprite={idle={self.tile}}
 end

key=entity:extend({
 draw_order=5,
 hitbox=box(1,0,6,8),
 sprite={
  idle={11,14,15,14,delay=30},
  follow={11,14,15,14,delay=30}
 },
 tags={"key"},
 chn=v(0,0),
 collides_with={"guy"}
})
 key:spawns_from(11,15)
 function key:init()
  g_keys+=1
  self.t=rnd(100)
  self.start_pos=self.pos.y
  if(self.tile==11) self.pos.x-=4
 end
 function key:idle(t)
  self.pos.y=self.start_pos+cos(t/100)*2-4
 end
 function key:collide(o)
  if self.state=="idle" then
   if (g_guy.state=="to_spawn") return
   add(g_guy.keys,self)
   self.flw=(#g_guy.keys>1 and g_guy.keys[#g_guy.keys-1] or o)
   self.flw.sec=self
   prts(self.pos)
   self.hitbox=box(0,0)
   self:become("follow")
   sfx(5)
	 end
 end
 function key:follow(t)
  if (not self.flw) self.flw=g_guy
  local ds=(self.flw.pos-self.pos-self.flw.chn+self.chn)
  local d=ds:len()
  if d>10 then
   self.pos+=ds/d
  else
   self.pos.y+=cos(t/100)/10
  end 
 end
 function key:unlock()
  local ds=(self.dr.pos+v(4,0)-self.pos)
  local d=ds:len()

  if d<10 then
   prts(self.pos)
   g_keys-=1
   self.dr:check()
   self.done=true
    del(g_guy.keys,self)
   
   if self.sec then
    self.sec.flw=self.flw
    self.flw.sec=self.flw
    -- self.sec.done=true
   else
    self.flw.sec=nil 
   end
  else
   self.pos+=ds/d*1.3
  end
 end

door=entity:extend({
 open=false,
 draw_order=7,
 sprite={
  idle={12},
  breaking={61},
  width=2
 },
 hitbox=box(0,0,16,8),
 collides_with={"guy","key"}
})
 door:spawns_from(12)
 function door:idle(t)
  for k in all(g_guy.keys) do
   if k:is_a("key") and k.state=="follow" then
    local d=(k.pos-self.pos):len()
    if d<60 then
     k:become("unlock")
     k.dr=self
    end
   end 
  end
 end
 function door:check()
  if g_keys==0 then
   self:become("breaking")
  end
 end
 function door:breaking(t)
  if t==2 then
   shake_screen(10)
   sfx(5)
  end
  if(t>=10) self.done=true  
 end
 function door:collide(o)
  return c_push_out
 end

enargy=entity:extend({
 sprite={
  idle={27,28,delay=10},
  tovis={91,90,27,delay=10},
  toinvis={27,90,91,delay=10},
  hidden={25}
 },
 hitbox=box(1,1,6,6),
 draw_order=4,
 tags={"enargy"},
 collides_with={"guy"}
})
 enargy:spawns_from(27)
 function enargy:init()
  self.t=rnd(100)
  self.start_pos=self.pos.y
 end
 function enargy:tovis(t)
  if (t>=29) self:become("idle") self:unhide() sfx(27)
 end
 function enargy:toinvis(t)
  if (t>=29) self:become("hidden")
 end
 function enargy:idle(t)
  self.pos.y=self.start_pos+cos(t/100)*2-4
 end
 function enargy:hidden(t)
  if t>=120 then
   self:become("tovis")
  end
 end
 function enargy:unhide()
   self:become("idle")
   -- prts(self.pos)
 end
 function enargy:collide(o)
  if (g_guy.state=="to_spawn") return
  if (self.state~="idle") return
  
  o.enargy+=1
  self:become("toinvis")
  sfx(3)
  shake_screen(15)
  o.chr=1
  -- prts(self.pos)
  for e in all(entities_tagged["destr"]) do
   e.done=true
  end
 end

breakable=entity:extend({
 draw_order=3,
 tags={"walls"},
 collides_with={"guy"},
 hitbox={idle=sbox,breaking=sbox,nobox},
 sprite={
  idle={23},
  hidden={25},
  breaking={39,55,delay=8},
  tovis={107,108,109,110,111,123,23,delay=5},
 }
})
breakable:spawns_from(23,124)
 function breakable:init()
  self.sprite.idle={self.tile}
 end
 function breakable:collide(o)
  if o:is_a("guy") then
   if (self.state=="hidden") return
   if (g_guy.state=="to_spawn") return
   if (self.state=="idle") sfx(39)
 
   self:become("breaking")
  end 
  return c_push_out
 end
 function breakable:hidden(t)
  if (t>=120) self:become("tovis")   
 end
 function breakable:tovis(t)
  if (t>=34) sfx(27) self:become("idle")
 end
 function breakable:breaking(t)
  if t>=15 then
   if self.tile==124 then 
    self.done=true
   else
    self:become("hidden")
   end
  end
 end
 
platform=entity:extend({
 tags={"walls","platform"},
 sprite={
  idle={56},
  moving={56},
  width=2
 },
 state="waiting",
 draw_order=3,
 hitbox=box(0,0,16,8),
 collides_with={"walls"}
})
 platform:spawns_from(56,57)
 function platform:init()
  self.oldvel=v(-0.5,0)
  self.vel=v(0,0)
 end
 function platform:waiting(t)
  if t>=30 then 
   self.vel=self.oldvel
   if self.tile==57 then
    if self.vel.x==0.5 then
     self.vel=v(0,-0.5)
    elseif self.vel.y==-0.5 then
     self.vel=v(-0.5,0)
    elseif self.vel.x==-0.5 then
     self.vel=v(0,0.5)
    else
     self.vel=v(0.5,0)
    end 
   elseif self.tile==56 then
    self.vel.x*=-1 
   end
   self:become("idle")
  end
 end
 function platform:collide(o)
  if(o.state=="to_spawn") return

  if o:is_a("walls") and not self.ignore and (o.state=="idle" or o:is_a("platform")) then
   self.oldvel=v(self.vel.x,self.vel.y)
   self.vel=v(0,0)
   self:become("waiting")
   sfx(33)
   return c_move_out
  elseif o:is_a("guy") then
   return c_push_out
  end
 end
 
strawberry=entity:extend({
 draw_order=5,
 hitbox=box(2,1,6,6),
 sprite={
  idle={43}
 },
 chn=v(0,0),
 collides_with={"guy"},
 tags={"strawberry"}
})
 strawberry:spawns_from(43)
 function strawberry:init()
  self.t=rnd(100)
  self.start_pos=self.pos.y
  self.pos.x-=4
 end
 function strawberry:idle(t)
  self.pos.y=self.start_pos+cos(t/100)*2-4
 end
 function strawberry:follow(t)
  if (not self.flw) self.flw=g_guy
  local ds=(self.flw.pos-self.pos-self.flw.chn+self.chn)
  local d=ds:len()
  if d>10 then
   self.pos+=ds/d
  else
   self.pos.y+=cos(t/100)/10
  end
 end
 function strawberry:collide(o)
  if (g_guy.state=="to_spawn") return

  if self.state~="follow" then
   sfx(2)
   self.hitbox=nobox
   add(g_guy.keys,self)
   self.flw=(#g_guy.keys>1 and g_guy.keys[#g_guy.keys-1] or o)
   self.flw.sec=self
   self:become("follow")
   prts(self.pos)
  end
 end
 
cloud=platform:extend({
 sprite={
  idle={58},
  waiting={58},
  width=2
 },
 draw_order=3,
 hitbox=box(0,0,16,1),
 draw_order=4
})
 cloud:spawns_from(58,59)
 function cloud:idle()
  self.vel=v(0.5*(self.tile==58 and 1 or -1),0) 
  if self.pos.x>142 then
   self.pos.x=-16
  elseif self.pos.x<-16 then
   self.pos.x=142
  end
 end
 function cloud:collide(e)
  if(e.state=="to_spawn") return

  if e:is_a("guy") then
   local dy,vy=e.pos.y-self.pos.y,e.vel.y
   if vy>0 and dy<=vy+1 then
    return c_push_out,{false,false,true,false}   
   end
  else
   return c_push_out
  end
 end

invis=entity:extend({
 hitbox={
  sbox,
  hidden=nobox
 },
 sprite={
  idle={60},
  tovis={29},
  toinvis={29},
  nvis={25}
 },
 draw_order=8,
 state="nvis",
 collides_with={"guy"},
 tags={"walls"}
})
 invis:spawns_from(60,61,62)
 function invis:init()
  -- todo: opposite blocks
  
 end
 function invis:idle()
  local d=(g_guy.pos-self.pos-v(4,6)):len()
  local vis=(d<16 and g_guy.state~="to_spawn")
  -- if (self.tile==61 or self.tile==62) vis=not vis
  if (vis and not (self.state=="vis" or self.state=="tovis")) self:become("tovis")
  if (not vis and not (self.state=="nvis" or self.state=="toimvis")) self:become("toinvis")
 end
 function invis:vis()
  self:idle()
 end
 function invis:nvis()
  self:idle() 
 end
 function invis:toinvis(t)
  if(t>=4) self:become("nvis")
 end
 function invis:tovis(t)
  if(t>=4) self:become("vis")
 end
 function invis:collide(o)
  if (self.state~="nvis") return c_push_out
 end

 
trap=entity:extend({
 hitbox=sbox,
 sprite={
  idle={53}
 },
 draw_order=7,
 tags={"wall"}
})
 trap:spawns_from(53)
 function trap:idle(t)
  if (g_guy.state=="to_spawn") return
  if t%60==0 then
   local b=bullet()
   b.pos=v(self.pos.x+8,self.pos.y+2)
   e_add(b)
  end
 end

bullet=entity:extend({
 hitbox=box(0,0,4,4),
 sprite={
  idle={54}
 },
 draw_order=8,
 weight=0,
 collides_with={"guy","walls","destr"}
})
 function bullet:idle()
  self.pos.x+=1
  if (self.pos.x>128) self.done=true
 end
 function bullet:collide(o)
  if o:is_a("guy") then 
   o:kill()
  elseif o:is_a("walls") then
   self.done=true 
   prts(v(self.pos.x-2,self.pos.y-2))
  end
 end
 

fly=entity:extend({
 sprite={
  idle={63,95,delay=10}
 },
 draw_order=9
})
 fly:spawns_from(63,95)
 function fly:init()
  self.t=rnd(100)
 end 
 function fly:idle(t)
  t=t/100
  self.pos.x+=cos(t)/10
  self.pos.y+=sin(t)/6
 end

light=entity:extend({
 sprite={
  idle={119,120,delay=15}
 },
 draw_order=5
})
 light:spawns_from(119,120)
 function light:init()
  self.t=rnd(128)
 end
 
snake=entity:extend({
 sprite={
  idle={44},
  hidden={29},
  toidle={45},
  tohid={45}
 },
 collides_with={"guy"},
 tags={"walls","snk"},
 hitbox=sbox,
 draw_order=8
})
 snake:spawns_from(29,44)
 function snake:init()
  if self.tile==29 then
   self:become("hidden")
  elseif not g_ssnk then
   g_ssnk=self
  end
 end
 function snake:tohid(t)
  if(t>=5) self:become("hidden")
 end
 function snake:toidle(t)
  if(t>=5) self:become("idle")
 end
 function snake:idle(t)
  local a=10
  if t==a then
   local en
   local en2
   for e in all(entities_tagged["snk"]) do
    if e~=self then
     local dx=abs(e.pos.x-self.pos.x)/8
     local dy=abs(e.pos.y-self.pos.y)/8
     local s=dx+dy
     if e.state=="hidden" and s<=2 then
      if(s<2) en=e break
      if(s==2) en2=e
     end
    end
   end
   -- self:become("hidden")
   if en then 
    en:become("toidle")
   elseif en2 then
    en2:become("toidle")  
   else
    g_ssnk:become("toidle")
   end
  elseif t==a*4 then
   self:become("tohid")
  end
 end
 function snake:collide(e)
  if self.state=="idle" then   
   return c_push_out,{false,false,true,false}
  end
 end
 
spear=entity:extend({
 sprite={idle={30}},
 hitbox=box(0,0,8,5),
 draw_order=8,
 collides_with={"guy","walls"}
})
 spear:spawns_from(30)
 function spear:init()
  self.start=self.pos
  self.vel=v(0,0)
 end
 function spear:idle()
  local dx=self.pos.x+4-g_guy.pos.x
  local dy=self.pos.y-g_guy.pos.y
 
  if abs(dx)<3 and dy<0 and dy>-48 then
   self.vel.y=1
   self:become("to")
  end
 end
 function spear:collide(o)
  if (o.kill) o:kill()
  if o:is_a("walls") then
   if self.state=="to" then 
    self:become("back")
    self.vel.y=-1
   else
    self:become("idle")
    self.vel.y=0
   end
   return c_move_out
  end
 end
 function spear:render()
  line(self.pos.x+3,self.pos.y,self.start.x+3,self.start.y,8)
  line(self.pos.x+4,self.pos.y,self.start.x+4,self.start.y,7)
  spr_render(self)
 end
 
toggle=entity:extend({
 tags={"walls","jmp"},
 collides_with={"guy"},
 hitbox=sbox,
 sprite={
  idle={46},
  hidden={47}
 }
})
 toggle:spawns_from(46,47)
 function toggle:collide()
  if(self.state=="idle") return c_push_out
 end
 function toggle:init()
  if(self.tile==47) self:become("hidden")
 end
 function toggle:jump()
  if self.state=="idle" then
   self:become("hidden")
  else 
   self:become("idle")
  end
 end
-->8
hats={94,122,125,126,127}

-- guy
guy=entity:extend({
 tags={"guy"},
 vel=v(0,0),
 state="to_spawn",
 weight={0.2,to_spawn=0},
 sprite={
  walk={75,76,77,delay=5},
  idle={79},
  fly={74},
  climb={78,93,delay=10},
  dead={25},
  offset=v(-4,-9),
  flips=true
 },
 keys={},-- todo: convert to string table
 enargy=0,
 bold=true,
 chn=v(0,9),
 chr=0,
 won=false,
 on_lader=false,
 draw_order=10,
 collides_with={"walls","ladder"},
 hitbox=box(0,0,0,0),
 nocol=true,
 feetbox=box(-4,-4,4,-0.999)
})
guy:spawns_from(79)

 function guy:init()
  g_guy=self
  self.vel=v(0,0)
  self.pos.x+=4
  self.pos.y+=8
  self.supported_by=false
  self.to=self.pos.y
  self.pos.y=132
  self.keys={}
 end
 function guy:become(state)
  if self.state~="dead" and state~=self.state then
   self.state,self.t=state,0
  end
 end
 
 function guy:to_spawn()
  self.pos.y-=2
  if self.pos.y<=self.to then
   self.hitbox=box(-4,-9,4,-1)
   self:become("idle")
   self.pos.y=self.to
   self.nocol=false
  end
 end
 
 function guy:dead(t)
  self.vel=v(0,0)
  if(t>=15) ingame.t=0 schedule(restart_level)
 end
 
 function guy:kill()
  if (self.state=="dead" or self.won) return
  sfx(20)
  cls(g_c[1])
  flip()
  flip()
  flip()
  self.keys={}
  g_lost=true
  self:become("dead")
 end
 
 function guy:climb()
  if (self.state=="dead") return
  if btnp(4) then
   self:become("fly") 
   self.vel.y=-1.75
   self.on_lader=false
   self:onjump()
   return
  end
  if not self.on_ladder then
   self:become("fly")
   return
  end
  self.chr=0
  self.vel=v(0,0)
  
  local sp=self.supported_by
  if btn(0) then	
   self.vel.x-=1 if sp then self:become("walk") end
  end
  if btn(1) then 
   self.vel.x+=1  if sp then self:become("walk") end
  end
  if (btn(2)) self.vel.y-=1 
  if (btn(3)) self.vel.y+=1
  
  if self.vel.y==0 then
   self.t-=1
  end
  
  --self:check_vertical()  
  self:common()
  self.on_ladder=false
  --self.vel*=0.5
 end
 
 function guy:collide(o)
  if o:is_a("ladder") and self.state~="dead" then
   self.on_ladder=true
  end
 end
 function guy:onjump()
  for e in all(entities_tagged["jmp"]) do
   e:jump()
  end
 end
 
 function guy:fly(t)
  if btn(4) and t<10 and self.vel.y<=0 then
   self.vel.y=-1.75
  elseif self.chr>0 and btnp(5) then
   sfx(1)
   self:onjump()
   self.vel.y=-3.5
   self.vel.x*=2
   self.chr-=1
   prts(v(self.pos.x-4,self.pos.y-2),4,5)
  end
  
  if (btn(0)) self.vel.x-=0.3
  if (btn(1)) self.vel.x+=0.3
  self.vel.x*=(1/1.25)
  
  if self.supported_by and self.vel.y>0 then
   self.vel=v(0,0)
   self:become("idle")
   prts(v(self.pos.x-4,self.pos.y-2),4,5)
   sfx(29)
  end
  self:common()
  self:do_ladders()
 end
 function guy:idle(t)
  self:walk(t)
 end
 function guy:walk(t)
  self:move()
  self:common()
  self:check_vertical()
  self.chr=0
  if self.state=="walk" and t%10==0 then
   sfx(28)
  end
  self:do_ladders()
 end
 function guy:do_ladders()
  if self.on_ladder and (btn(2) or btn(3)) then
   self:become("climb")
  end
 end
 function guy:move()
  self.vel=v(0,0)
  if (btn(0)) self.vel.x=-1
  if (btn(1)) self.vel.x=1 
  if self.vel.x~=0 then
   self:become("walk")
  else
   self:become("idle")
  end
 end
 function guy:check_vertical()
  if not self.supported_by then
   self:become("fly")
   return
  end
  if btn(4) then
   sfx(0)
   self:onjump()
   self:become("fly")
   prts(v(self.pos.x-4,self.pos.y-2),4,5)
   self.vel.y=-1.75
  end
 end
 function guy:common()
  self.pos.x=mid(self.pos.x,5,124)
  if self.pos.y>125 then
   self:kill()
   self.pos.y=125
  elseif self.pos.y<0 and not self.won then
   g_lost=false
   schedule(next_level)
  end
  if self.supported_by and
   self.supported_by.collide then
   self.supported_by:collide(self)
  end
 end
 function guy:set_pal()
  local c=(self.chr>0 and g_c[2] or g_c[1])
  pal(14,c)
 end
 function guy:render()
  local flp=self.flipped
  spr_render(self)
  if(self.state~="dead") spr(hats[g_hat],self.pos.x-5+(flp and 2 or 0),self.pos.y-12,1,1,flp)
  r_reset()
 end
 function guy:render_hud()
  -- print(g_index.." lvl",1,1,7)
  if self.state=="dead" then
   local t=self.t
   local r=t+3
   for i=1,10 do
    local a=i/10+t/100
    circfill(sin(a)*r+self.pos.x-4,cos(a)*r+self.pos.y-6,2,7)
   end
  elseif self.chr>0 then
   text("— press",self.pos.x-18,self.pos.y-16,8)
  end
  if g_level.t<120 and g_lost and not self.won then
   text(pd(g_hours)..":"..pd(g_minutes)..":"..pd(g_seconds).."\n"..g_deaths.." deaths",2,2,8)
  end
  if self.won then
   textc("time: "..pd(g_hours)..":"..pd(g_minutes)..":"..pd(g_seconds),69,8)
   textc(g_deaths.." deaths",79,8)
   textc(g_strawberries.." berries",89,8)
  
   if g_time%30>=15 then
    pal(8,g_c[3])
    pal(7,g_c[1])
   end
   
   if btnp(5,1) then
    saveg()
    reset()
   end
   
   text("‡‰you won!‰‡",32,49,8)
   text("press tab to get to menu!",11,115,8)
  end
 end

 function textc(s,y,c,c2)
  text(s,64-#s*2,y,c,c2)
 end
 
 function pd(n)
  local s=tostr(n)
  if(#s<2) s="0"..s
  if(#s<2) s="0"..s
  return s
 end
-->8
-- game states
ingame={t=0,ft=15}
shk=0
function ingame:update()
 if scheduled then
  scheduled()
  scheduled=nil
 end
 if self.t>=15 and self.ft<=1  then
  e_update_all()
  do_movement()
  do_collisions()
  do_supports()
 end
end

function shake_screen(a)
 shk=a
end

g_pat={
  0b1111111111111111.1,
  0b0111111111111111.1,
  0b0111111111011111.1,
  0b0101111111011111.1,
  0b0101111101011111.1,
  0b0101101101011111.1,
  0b0101101101011110.1,
  0b0101101001011110.1,
  0b0101101001011010.1,
  0b0001101001011010.1,
  0b0001101001001010.1,
  0b0000101001001010.1,
  0b0000101000001010.1,
  0b0000001000001010.1,
  0b0000001000001000.1
}

function ingame:draw()
 if not g_guy.won and g_index==29 and g_guy.pos.y<=32 then
  music(15)
  g_main=false
  dset(8,1)
  g_guy.won=true
  --g_money+=g_strawberries
  saveg()
 end

 cls()
 if shk>0  then
  shk-=1
  camera(rnd(5)-2,rnd(5)-2)
 else
  camera()
 end 
 r_render_all("render")
 camera()
 r_render_all("render_hud")
 
 if self.ft>0 then
  self.ft=0
  cls(1)
  --fillp(g_pat[flr(16-self.ft)+1])
  --rectfill(0,0,127,127,1)
 --- fillp() 
 elseif self.t<15 then
  self.t+=0.5
  r_reset()
  fillp(g_pat[flr(16-self.t+0.5)])
  rectfill(0,0,127,127,8)
  fillp()
 end
end

function next_level()
 if not g_main then
  music(1)
  g_main=true
 end
 g_index+=1
 -- todo: check for winning
 restart_level()
 saveg()
end

function saveg()
 
 dset(0,g_index)
 dset(1,g_strawberries)
 dset(2,g_deaths)
 dset(3,g_minutes)
 dset(4,g_seconds)
 dset(5,g_hours)
 dset(10,g_hat)
 --dset(11,g_money)
end

function restart_level()
 g_keys=0
 g_ssnk=nil
 reload(0x1000,0x1000,0x1000)
 reload(0x2000,0x2000,0x1000)
 
 if entities_tagged and not g_lost then
  for e in all(entities_tagged["strawberry"]) do
   g_strawberries+=1
  end
 end

 if g_lost then
  g_deaths+=1
 end
 
 entity_reset()
 collision_reset()
 
 g_level=e_add(level({
  base=v(g_index%8*16,flr(g_index/8)*16),
  size=v(16,16)
 }))
 
 for i=1,20 do
  e_add(bar())
 end
 
 for i=1,40 do
  e_add(particle())
 end
 
 for c in all(cor) do
  e_add(c)
 end
 
 ingame.ft=15
end

g_trans=false
menu={}
function menu:update()
 if btnp(5) and not g_trans then
  g_trans=true
  g_time=0
  sfx(19)
  music(-1)
 end
 
 if btnp(0) then
  g_hat=max(1,g_hat-1)
  sfx(3)
 elseif btnp(1) then
  g_hat=min(#hats,g_hat+1)
  sfx(3)
 end

 --[[if btnp(4) and dget(8)==1 then
  sfx(31)
  g_state=peek_level
 end]]
 
 if g_trans and g_time>120 then
  g_state=ingame
  if g_index==0 then
   music(0)
   g_main=false
   saveg()
  elseif not g_main then
   music(1) 
   g_main=true
   saveg()
  end
  g_trans=false
  ingame.t=0
  cls(1)
  flip()
 end
end

function rr()
 cls()
 local tt=time()*0.005 
 for j=1,2 do
  local a=35*j
  local m=48*j
  
  for i=1,a do
   local t=(tt+i/a)*(j==2 and 1 or -1)
   local x,y=sin(t)*m+64+cos(t*60)*16,
    cos(t)*m+64+sin(t*60)*16
   circfill(x,y,(cos(i/a+tt*5)+1)*2+1,7+i%2)
  end
 end
 local j=0
 local t=time()*20
 for i=1,#patrons do
  local c=sub(patrons,i,i)
  text(c,(j*4+2-t+128)%(700+4)-4,
   115+cos(t/40+j/10)*3,0,8)
  j+=1
 end
end
patrons="made possible by my awesome patrons! roy fielding, pizza, brian nicolucci, francesco maida, gabriel crowe, szymon walter. thank you! patreon.com/egordorichev"

function menu:draw()
 
 pal(11,g_c[2])
 if g_trans and g_time%16>8 then
  pal(8,0)
  pal(11,0)
  pal(7,g_c[1])
 else
  pal(8,g_c[1])
  pal(7,g_c[3])
 end
 rr()
 
 palt(0,false)
 palt(3,true)
 sspr(0,32,80,32,24,32)
 textc("press —/x to start",100,(g_time%60>30 and 8 or 7),0)
 --if dget(8)==1 then
 -- textc("press Ž/z to select level",110,(g_time%60<30 and 8 or 7),0)
 --end
 text("by    egordorichev",27,74,11,0) 
 spr(106,42,72)
 text("x-mas edition",47,62,7,0)
 text("‹   ‘",50,86,8)
 spr(hats[g_hat],60,84)
end
--[[
peek_level={}
function peek_level:update()
 if btnp(2) or btnp(0) then
  g_index=max(0,g_index-1) 
  dset(0,g_index)
  sfx(31)
  return
 end
 if btnp(3) or btnp(1) then
  g_index=min(29,g_index+1)
  sfx(31)
  dset(0,g_index)
  return
 end
 if btnp(5) then
  sfx(31)
  _init()
  g_state=ingame
  music(1)
  g_main=true
 end
end
function peek_level:draw()
 cls()
 rr()
 spr(43,60,45+cos(g_time/100)*2)
 textc("select level: "..g_index,64,7,0)
 text("press —/x to start",25,74,(g_time%60<30 and 8 or 7),0)
end--]]

-- util
local dirs={
 {v(-1,-1),0},
 {v(-1,1),0},
 {v(1,-1),0},
 {v(1,1),0},
 {v(-1,0),0},
 {v(1,0),0},
 {v(0,-1),0},
 {v(0,1),0},
 {v(0,0),1}
}
function text(s,x,y,c,c2)
 for i=1,#dirs do
  local d=dirs[i]
  local ps=v(x,y)+d[1]
  local cl=(d[2]==1 and c or (c2 and c2 or 7))
  print(s,ps.x,ps.y,cl) 
 end
end
part=entity:extend({
 draw_order=7,
 wegiht=0
})
 function part:set(x,y,s,c,vl)
  self.pos=v(x,y)
  self.sz=s
  self.clr=c
  self.vl=(vl and vl or v(rnd(2)-1,rnd(2)-1))
 end
 function part:idle()
  self.pos+=v(self.vl.x,self.vl.y)
  self.vl*=0.9
  self.sz-=0.1
  if (self.sz<0) self.done=true
 end
 function part:render()
  circfill(self.pos.x,self.pos.y,self.sz,self.clr)
 end 
 
function prts(pos,s,a)
 for i=1,(a and a or 10) do
  local p=part()
  p:set(pos.x+(s and s or 4),pos.y+4,3,7)
  e_add(p)
 end
end

control_o=entity:extend({
 draw_order=5
})
 control_o:spawns_from(91)
 function control_o:render()
  text("Ž/z to jump",self.pos.x,self.pos.y,1)
 end
 
control_x=entity:extend({
 draw_order=5,
 tags={"walls"},
 hitbox=sbox
})
 control_x:spawns_from(90)
 function control_x:render()
  text("—/x to dash",self.pos.x,self.pos.y,1)
 end
-->8
-- enemies

skull=entity:extend({
 tags={"destr"},
 draw_order=8,
 weight=0,
 collides_with={"guy"},
 sprite={
  idle={52}
 },
 hitbox=box(0,0,8,8)
})
 skull:spawns_from(52)
 function skull:idle()
  local t=self.t/100
  local ds=(g_guy.pos-v(4,6)+v(sin(t)*8,cos(t)*8))-self.pos
  local d=ds:len()*4 
  self.pos+=ds/d

  if self.t%2==0 then  
   local p=part()
   p:set(self.pos.x+4,self.pos.y+4,3,7)
   e_add(p)
  end
 end
 function skull:collide(o)
  if (o:is_a("guy"))  o:kill()
 end
 
cls() m()
controls=entity:extend({
 draw_order=5
})
 controls:spawns_from(73)
 function controls:render()
  local s=(g_index==0 and 
   "‹‘”ƒ to move\n— to jump" or
   "— to dash when\nyou touch a bulb")
  text(s,self.pos.x+1,self.pos.y,8,7)
 end
__gfx__
00000000aa8aaa8a3333333333333333b00333333333300b3077b033333003333bbbbbbbbbbbbbbbbbbbbbb33087780300000000000000003308033330877803
00000000a8aaa8aa3333333330000003b78003333330087b307b8033330b8033b3b333b333b333b333b333bb3077070307778888888888703307033330707703
007007008aaa88883333333307888880b78780333308787b30b8703330b87033b33b333b333b333b333b333b3070070307000788887000803307033330700703
00077000aaaaaaaa3333333330078003b78003333330087b3087703330877033bbbbbbbbbbbbbbbbbbbbbbbb3087780307000700007000803308033330877803
00077000aa88888a3333333330700803b00333333333300b3077b0333077b033b33b3333333333333333b33b3307003308000700007000803307033333007033
00700700a88888aa3333333333078033b78003333330087b307b8033307b8033b33b3333333333333333b33b3307780308000770077000803308033330877033
000000008aaa8aaa3000000330700803b78780333308787b30b8703330b87033b3bb3333333333333333b3bb3307003307888887788888703307033333007033
00000000aaa8aaa80788888033078033b78003333330087b3087703330877033bb3b3333333333333333bb3b3308780300000000000000003308033330878033
377777777777777777777733aa8aaaa7bbbbbbbb333333333077b03337777773b33b3333333333333333b33b3300003333077033333333330000000000000000
777777777777777777777773a8aaa8a77770777033333333307b803378888887b33b3333333333333333b33b3077770333077033333333330887777000000000
7777777777777777777777778aaa88a7888088803033303330b8703378888887b3bb3333333333333333b3bb0777787030777703338778333088770300000000
777777777777777777777777aaa888a707030703080308033087703373333337bb3b3333333333333333bb3b0777807030700703337337333308803300000000
777777777777777777777777aa8a88aa08030803070307033307b03373333337b33b3333333333333333b33b0788007030708703337337333330033300000000
77aaaaaaaaaaaaaaaaaaaa77a8aa88aa3033303388808880330b803373333337b33b3333333333333333b33b0770007030788803338778333333333300000000
7aaa8aaa8aaa88888aaa8aa78aaa8aaa33333333777077703330703373333337b3bb3333333333333333b3bb3077770330777703333333333333333300000000
7aa8aaa8aaa88888aaa8aaa7aaa8aaaa33333333bbbbbbbb3333033337777773bb3b3333333333333333bb3b3300003333077033333333333333333300000000
7a8aaa8aaa8aaa8aaa8aaaa73777777300000000000000000000000033777773b33b3333333333333333b33b0b0b00b037777773333333333777777338888883
7aaaa8aaa8aaa8aaa8aaa8a77777777788777877777877787778877737888887b33b3333333333333333b33b30bbbb0373383387337777337777777788888888
7aaaa8aa8aaa8aaa8aaa88a77777777780707070707070707070070737887887b3bb3333333333333333b3bb308bb80373833837378338737777777788888888
7aa8a8a8aaa8aaa8aaaa88a777a8aa7788707877707877707078877773373737bb3b3333333333333333bb3b0878888078338337373383737788887788000088
7a88a88aaa8aaa8aaa8a88a77a8aa8a700777000777000887770000073733737bbbbbbbbbbbbbbbbbbbbbbbb0888878073383387373833737088880783000038
7a88a8aaa8aaa8aaa88a88a778aa8aa733000333000333000003333337377337b33b333b333b333b333b333b3088880373833837378338737088880783000038
7a88aaaa8aaa8aaa8a8a8aa77aa8aa8733333333333333333333333337773337b3b333b333b333b333b333bb3087880378338337337777337700007788333388
7a88aaa8aaa8aaa8aa8aaaa737777773333333333333333333333333333777733bbbbbbbbbbbbbbbbbbbbbb33308803337777773333333333777777338888883
7a8aaa8aaa8aaa8aaa8aa8a77aaaaa8a300000333777777338833333333333333000000000000003300000000000000387777778000000000000000033333333
7aa888aaa8aaa8aaa8aa88a77aaaa8aa078887037bbbbbb787783333338887770877777777777780087777777777778073333337000000000000000030033003
7a8b0b8a8aaa88888aaaaaa77aaa8aaa008880037bbbb88787083333377773870777777777777770070000000000007073833337000777777777700007700770
7a80b088aaaaaaaaaaa888a77aa8aaa8000800037bbb8008388333333373377707000000000000703070000000000703733333370070080000800700300bb003
7a8b0b8aaa88888aa8a8a8a7aa8aaa8a078887037bbb8008333333333373337307000000000000703307700000077033733333370070080000800700330bb033
7aa888aaa88888aa88a88aa7a8aaa8aa307770337bbbb88733333333373377730700000000000070333008777780033373333337000777777777700033300333
37aaaaaaaaaaaaaaaaaaaa738aaa8aaa300000337bbbbbb733333333337733330877777777777780333330000003333373333337000000000000000033333333
337777777777777777777733aaa8aaa8333333333777777333333333337773333000000000000003333333333333333387777778000000000000000033333333
00000000000000003300000000000000003330000033333000000000000000000000000000000033333e33333eeeee33333e3333333e33333333e333333e3333
088888888800888033088800888888888033308880333330888888888008888888008888888880333eeeee333eeeeee33eeeee333eeeee3333eeee333eeeee33
088888888800888033088800888888888033308880333330888888888008888888008888888880333eeeeee3eeee77e33eeeeee33eeeeee33eeeee333eeeeee3
0bbb888bbb0088803308880088bbbbbbb033308880333330888bbb88800888bbbb00bbb888bbb033eeee77e3eee77073eeee77e3eeee77e33eeeeee3eeee77e3
00008880000088803308880088000000003330888033333088800088800888000000000888000033eee77023ee777733eee77073eee770733eeeeee3eee77073
333088803330888033088800880333333333308880333330888030888008880333333308880333333e77773338888833ee777733ee7777333e7777e3ee777733
33308880333088803308880088033333333330888033333088803088800888033333330888033333338888338333338338888833388888333388883338888833
33308880333088803308880088033333333330888033333088803088800888033333330888033333383333833333333338333383833383333333338338338333
333088803330888000088800880000000333308880333330888030888008880333333308880333333333333333333333333333333333e3333333333333333333
3330888033308888888888008888888803333088803333308880308880088803333333088803333333000033333333333333333333eeee333300333333333333
333088803330888888888800888888880333308880333330888030888008880000033308880333333077780333300333333333333eeeee333077003333000033
333088803330888bbbb8880088bbbbbb0333308880333330888030888008888888033308880333333077780333077033300000033eeeeee330788803307bb703
333088803330888000088800880000000333308880333330888030888008888888033308880333333077880333078033078888803eeeeee308888880070bb070
333088803330888033088800880333333333308880333330888030888008888888033308880333333088880333300333300780033e7777e30888800030300303
33308880333088803308880088033333333330888033333088803088800000088803330888033333330000333333333330700803338888330880033333333333
33308880333088803308880088033333333330888033333088803088803333088803330888033333333333333333333333078033383333333003333333333333
33308880333088803308880088033333333330888033333088803088803333088803330888033333003000033333333333333333333333333777777337777773
33308880333088803308880088000000003330888000000088800088800000088803330888033333800b88b03333333333333333337777337333333778888887
33308880333088803308880088888888803330888888880088888888800888888803330888033333888888803337733333777733373333737333333773333337
33308880333088803308880088888888803330888888880088888888800888888803330888033333888888b03373373337333373373333737333333773333337
3330bbb03330bbb0330bbb00bbbbbbbbb03330bbbbbbbb00bbbbbbbbb00bbbbbbb03330bbb033333b88888033373373337333373373333737333333773333337
333000003330000033000000000000000033300000000000000000000000000000033300000333330b8880333337733333777733373333737333333773333337
333333333333333333333333333333333333333333333333333333333333333333333333333333338888b0333333333333333333337777337333333773333337
33330000000000000000000000000000000000000000333333333333333333333333333333333333000003333333333333333333333333333777777337777773
33300880888088808880808088808880888088808080333333333333703330077033300733333333333333333777777337777773333333333333333333333333
3330800008008080808080808080800080808080808033333333333307000b70070008703333333333003333788888877bbbbbb7333333333003333330033333
333088800800880088808080880088008800880088803333333333333087bbb030b788803333333330770033788888877bbbbbb7333888330770003307700033
3330008008008080808088808080800080808080008033333333333308880b030bbb080333333333307bb803733333377333333738800083077bbb03077bb803
333088000800808080808880888088808080808088803333333333333080303330b03033333333330bb88bb07333333773333337800000080bbbbbb008b8bbb0
33300003000000000000000000000000000000000000333333333333330333333303333333333333088bb0007333333773333337800008880bbbb0000bbbb000
333333333333333333333333333333333333333333333333333333333333333333333333333333330bb003337333333773333337800883330bb003330b800333
33333333333333333333333333333333333333333333333333333333333333333333333333333333300333333777777337777773388333333003333330033333
12121012226002121212121212121212121212131313131313121212220000020000008100813241414132810000000112121213131313131313131323000000
12121212121212121212230000000000121212131313131323000000008100810000021212121212121212121212121212121012121212220000000212121212
1212121222600212121212121212121212122377a17781777703121222c000020000008100810000000000810000011212132377777781777777a17777000000
131313131313131313230000d1d1d1d112132377777777a177000000008100815262021212121313131313131212121212121213131313239090900312101212
1212121323610212121212121212101212220000a100810000770212229292022100008100810000f30000810111121222777700000111111111112100000000
777777777777777777770000d100000022777700f30000a100000000011111110000021212227777a17781770212101212122377817777770000007703121212
12132377770002121212121012121212122200000111210000b002122200b1023111111111112100000001111213132322000000013312121212123111111111
d1d1d1d1d1d1d1d1d1d1d1d1d100f300220000000000000121000001331212120000021213230000a10081b20212121212227700810000000000e20077031212
22777770c3c30313131313121212121212230000021231210000021222000002121212131313234252620313238787872200f300031313131312121213131312
d1000000000000000000000000000000220000000000013323c00003121212124262032377770050011111113312121212220000810000f20000000000770312
2200c360c30077777777700313121212237700000212122200000312229292021313238787818700000087818700000022000000777781777703132377777702
d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d13121909090013322770000810312121200007777f3000050031313121213131212220000810000000000000000000003
22c3c361c3c3c3c3c3c36077770212120000b10002121222000077022200b102878787000081000000000081000000b231210000000081000000a10000000002
000000000000000000000000000000d112311111113312225252008100021212000000000000000077777703237777021231210081e2000000b1000000000000
227000000000c30070c361c3c3031312000000000212122200f50003230000020000000000810000300000012100000012311111111111111111111121424202
d1d1d1d1d1d1d1d1d1d100d1d1d100d1121313131212122200000001113310127171717171011121000000a17700000212122200810000000000000000000000
2261c3c3c3c3c3c360c300f57077600200f4000003121231210000a177000003a000f30000810111111111332200000012131313131313121212121223000002
d10000000000000000d100d100d100d1224000500210122240f05002121212120000000000021222000000a100000002121231111111112100000000b1000000
220000007000f5c360c3c3c360c360021121929292031212220000a100b10081a100000000013310121212122200000022777777777781031313122277000002
d1d1d1d1d1d1d1d100d1d1d100d1d1d12340f0500212122240525002121313129090a00000021231210000a100f3000213131312121212312100000000000000
22c3c3c360c300c360c3000061c360021222000000410312312100a100000081a100000000031313121210122300b1005300b200000081777777022200000002
00000000000000d10000000000000000770000000313122240005002227750020000a100f3031212311111112100000277778103131313132300000000000000
2200000060c300c3600000011121600212312100f5007702123121a100000082a1000000008787870313132387000000220000000000810000000323f3000002
f40000d1d1d100d1d1d1d1d1d1d1d10000f400007777022240b1500222f050020000a10000a10313131313132300000200008177777777817700000000426252
3121c3c360c3c3c3610111331223610212122200000000031212311121d1d10021f400000000f300818781870000000053000000000081012100a17700000002
112100c200d10000000000000000d10011112100f3000323400050022200500200f4a10000a17777e17777e1770000020000810000000081000000f300000000
1222000061c3000000021212220000021212312100000077031313132300d1d1312100000000000081008100000000003121f400011111333111210000000002
1231210000d100000000f3000000d100121231210000778100000003230050021121a10000a1000000000000f300300200f48100f30000810000000000000000
12312100f4000001113312122200b2021212122200b2000077777777770000d11231210000000000810081011111111112311111331212121212312100009302
1212220000d1d1d1d1d1d1d1d1d1d100121212312100008100000081a1000133123111111121000000000000000001111111210000f20081e20000f20000e200
1212311111111133121212123111113312121222c2d1d1d1d1d1d1d1d1d1d1d11212311111111111111111331212121212121212121212121212123111111133
12123121000000000000000000000000121212123111111111111111111133121212121212311111111111111111111112122242424200810000000000000000
220000031212121213131313131312121313131313131313131313131212220012121213131323c0600313131212121222c06003131313131313131313131302
12121212220000000000000212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22000077031313237777777777770312777777777777817777777777031222001212230000a10000600000000313121222006177777777777777777777777702
12121212236242000042420312121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000077777777000000000000770300f400000000810000000000000222b11222000000a1000060000000000003122200d1d1d1d1d151d1d1d1d1d1d10002
12121222770000000000007703121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
312190a0000000000000000000000077111111111111111111210000000222921222929292a2000060f300b0000000022300d1000000d132d100000000d10002
1212122362000000f300004242021212000000000000000000000000f30000000000000000000000000000000000000000000000000000000000000000000000
122200a100000000000000000000000012121313131313131231210000022200122200b100b0000060b10000000000027700d1000000d141d1f0003232d10002
12122292929292929292929292031212777777777777774201210000000000000000000000000000000000000000000000000000000000000000000000000000
122200a100000001111111210000000012237777e17777e103132300000222b1122300000000000060000000b10000020000d1000000d1d1d100004141d10002
12122300000000000000000000770212000000000000000133220000000000000000000000000000000000000000000000000000000000000000000000000000
123121a10000013313131331112162002200000000000000a10081000002229222a100000000f30060000000000000020000d10000000000003000d1d1d10002
12236262000000000000004242011212000000000000000212226277777777770000000000000000000000000000000000000000000000000000000000000000
121231111111332277777702122200002200000000000000a10081000133220022a100000000000061000000000000020000d100f0008090903200d100000003
2277000000f30000000000000002121200000000f300013312220000000000000000000000000000000000000000000000000000000000000000000000000000
121213121212122300b2000312220000227777011111111111111111331222b122a1b1000000b10000000000b000f3020000d10000f3810000a100d100b10077
22626200000000000000000001121212000000000000021212312100000000000000000000000000000000000000000000000000000000000000000000000000
122377031313239292929292032300002200000312121313131313131212239222a10000b000000000000000000000020000d1000000829292a200d100000000
22000000000000f30000424202121212777777777742021212122200000000000000000000000000000000000000000000000000000000000000000000000000
2377007777777700b10000007777b10022000077032377e17777e1770323770022a10000000000000000b10000000002f400d10000000000000000d1d1d10000
31219090909090909090909002121212000000000000021212122262777777770000000000000000000000000000000000000000000000000000000000000000
77000000000000000000000000000000220000007781000000000000777700b122a10000b100000000000000000000022100d1000000d1d1d100000000d1f300
12311121620000000042424203121212000000000001331212122200000000000000000000000000000000000000000000000000000000000000000000000000
00f400000000000000000000000000002200000000810000000000000000000022a10000000000000000000000300112220000000000c200d100000000d10000
121212220000000000000000000212120000000001331212121231210000f3000000000000000000000000000000000000000000000000000000000000000000
11112177e277f277e277f277e277011131112100008100000000000000000000312190909090909090909090900133122200c2d1d1d1d100d1d1d1d1d1d10000
12121222620000000000006262021212000000013312121212121231210000000000000000000000000000000000000000000000000000000000000000000000
1212220000000000000000000000021212123121008100011121909090900111122200f400300000003000011133121222000000000000000000000000000000
1212122200000000f40000000002121200f401331212121212121212312100000000000000000000000000000000000000000000000000000000000000000000
12122251515151515151515151510212121212311111113312311111111133121231111111111111111111331212121222000000000000000000000000000000
12121222425252426242526242021212111133121212121212121212123111110000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000001010101000000000000000000000000010001010202020000000000000001010101010100000000000002020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2121213131312121012121212200002021212121212131313131212121220000220000000000103321212121212121210121212131313131313131320c18202121212121220000202121212121212121012131313131313131312121220c24202101212121212121212121313200002021212131313121212121212200062001
212132141414302121313121220024202121312121227777777720212122001b22000000001033212121210121212121212131320000001a000000180018302121212121320c2430212121212121212121227777777777777777303132000030210121013131313131313277770000203131322a77773031212131320c063021
21221a000000773032771820220000202132773021131200002b20212122000022292929103331212131313131210101212218000000001a3f00002525180020212131320000001830212121210121212122000000000000000077771a00007721212132292a7777771800000000002000000000000077773032777718067720
21221a000000001800001830320c00202277007730212200001033212122000022002425303200303214141414302121213218002b00001a00000000001800202132292a000000180030313121212121213200000000002b000000001a2426002131320000000000001800000000103300002b00000b00007777000b18060020
21221a0b00000018000018777700242022003f0077303200003021212122000022000000001800002829292929292021220018000000001012000000001011332200000024252618000000073021212132770000002425262600003f1a3400002277770000000000001800001011332129292929292929292929292910111133
0113111111120018000018003f0000202200000000777700007720212132001b131200000018000000000000000030212200180000001033131209090930212122000b003400001800000006003031210000000000000000000000001a00000022262626000000003828292930312121111200000000007c0000252520212121
21213131311311111111111200000020220909090a00001b00002021227700002113111111111200003f000000000720320018001b0030212113120000003021222526000008101112000006000000200000001b00000000000000001a00242522000000003f000000000000000030212132003f10111209090a000030212121
21227777063031313131212224252620220000001a0000000000302122000000212131312121131200000000000006200000180000000020210122000b00002022003f00101133011312000600000020004f000000003f00000000001a00000013120000000000000000000000000620221a000030313200001a000077202121
2132000006777706777730320000002022001b0010111200000077303209090931320000302121320024252626000620000018000000003021212200003f0020220909093021210121320006000000201111111200000000000000001a00000021131200000038080909090910120620221a000018000000001a000000202121
3200000006000006000006770809092022000000202122000000007777001b00001a002b003032000000000000000620004f180000000000202113120000002022002b00143031313200001600000b2021213132090909090a0000101112030031313200000000282929292930320620221a0b0018000000001a000024202121
1a000000060000063f3f06001800002022090909202113120000000000000000001a00000000180000001b0000001620111112000000000030313132090910332200000000000018000000000024262021227777000000001a1515202113111177771800000000000000000077770620321a000018000000001a3f0000202121
1a00000016000016000016001800002022001b00202121220000000000000000001a4f00000018000000000000000020212113121717000000000000002420212200000000000018000b0000000000202122000b0000001011111133212121210000180000003f000000000000001620292a0000180b0000151a000000202121
1a00004f000000000000000018030020220000002021212200003f0000001b0000101111120018000000003f000010332101212200000000003f0000000020212209090a000b00182426003f0000103321131226260000202121212121210121004f18000000000000000000000000204f00000028292929252a000010332121
1111111111121515151515151011113322090909492121220000000000000000113321211312180000000000000020212121212224260017170000000000202113124f1a242500180000000000103321212122000000002001212101212121211111123800000000000038000000103312390000000000000000000020212121
4921212121131111111111113321012113124f0020212113111111111200000021212101211311122929292929292001212101220909090a000017170010330121131112000000180008090910332121212122090909092021212121212121212121222929292929292929292929202113111209090909090909091033212121
212101212121212121212121212121210113111133212121212121211311111121212121212121220000000000002021212121220000001a000000000020212121212122000000180018000020210121212122000000002021212121212121212121220000000000000000000000202121212200000000000000002021212121
00001a00302121012121212132000000213131313131313121212121320c0020220c0020213131313131313131312121313131313131313131313131320c06300121313131313131313132060030010121212121212121212121212121213200212131313131320c003031313121212121213131320000000000000000302121
00001a00773031313131313277002b002277777728292929302121321a0000202200002022770000180677067706302177777777067777067777067777000677213277771a771a7777777716001430013131313131212121212121212122000021327777777777000077777777302121213277771800000000003f0000773021
003c1a0000777777777777770000003c22000b1d1d1d1d00773032292a000b20220924301312000b1806000600067720002b00000600000600000600000006003200000010121a0000000000000006207777777777202131312121212122001b2200002b00000000000000000077303122770000180015151011122600007720
00001a3c00000000000000000000071522001d1d00001d1d007777001d1d1d202200000630131111120600160016002023230000060000060000060000000600773f00103313120024262600000006200000003f0030327777302121212200002200000015151515151515153b00777722002b00180010113321222929292920
00001a00003c00003f0000000000162322001d00002b001d1d001d1d1d001d20131200067730212122060000000000207706000006080a060000060000000600000000200101220000000000000006201d1d1d000077770000772021212200003200101111111111111111122626000013111111111133313121220000000020
00001a00000000000000000000000000221d1d0008090a001d1d1d15153f1d20211312060077303132160000000000200a06000006181a06000006003f0016001b1011332101320a000000002b00062012041d051011122929292021213200002929303131313131312121220000000021212131313132777730321717000020
03001011111111120000000000000000221d000028292a0000000010121d1d202121320600001a777708090a001b00201a06000006181a060000160000000000003031313132292a0000003f0000062022041d0520212204000030313277001b000077777777777777302122000000002121321a777777000077770000000020
11113321212121131111111112242526321d000b001d1d1d1d1d0020221d00202132770600001a0000183c1a000000301a06000016282a0600000000000008090077777777770000000000000000162022041d05202122040000777777000000001d1d1d1d1d1d1d00772022090909092132771a0000003f0000000000001033
31212131313131313131313132000000771d0000001d003f001d0020221d0020327700163f001a000028292a003f001a1a06000000000016000809090910111115151515151515151515000000003b2022042c05202113120a00000000000000000b00001011121d1d1d20220000000b2277001a000000000000000010113321
77303277777777777777777777000000001d001d1d1d10120a1d0030321d1d202929292929292a0b000000000000001a1a0600000015151500180000002021211111111111111111111200000000002022041d05202121221a00003c3c001b000000000020012200001d2022000000002200001a171717171717171730312121
00777700000000000000000000000000001d001d000020221a1d000000001d200000000000000000000000000003001a1a06003f0510111204180b08092021213131313131313131313200001b00002022041d05202121131200003f000000000a0000003031322c1d1d303200003f001312001a00000000000000001a772021
000000000000003f0000000000000300001d001d1d1d20222a1d0000001d1d204f002c1d00001d1d1d1d1d00101111111a060000053031320418001800202121777718777777771a777700000000002022041d103321212122000000000000001a3f00001a77180000001a77000000002122292a0000000000003f001a003021
004f08090909090909090909091011114f000000001d2022151d000b1d1d00201112001d0000000000001d00303131211a060000001414140018341800202121004f1800003a001a000000000000002032001d303131312113122929292929291a0000001a0018001b001a00000000002122171717171717171717001a000020
11111200003c0000003c000010332121122c1d1d1d1d2013121d1d1d1d0015202122001d1d00000000001d00777777201a060000000000000018001800202121111112000000001a00003f0000000020773f1d771877772021220000000000001a0000001a00180000001a00000000002122000000000000000000001a001033
2121221515151515151515152021012113121515151520212215151515151033212200001d001d1d1d1d1d0000002b201a16004f000000000018001800202121212113122929292a00000000082525202c1d1d00184f00202113120000000300124f00001a00180000001a00390010112113124f00000000000000001a103321
2101131111111111111111113321212121131111111133011311111111113301211312001d1d1d000000000010111133111111111111111111111111113321210121212200000000000000001800002011111111111111332121131111111111131112001a3c18003c3c1a3c0010332121212111111111111111111111332121
__sfx__
01020100095400e550175600050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010200000f410114101341016410336103361032610306102e6102e6102d6102d6102a61026610226101f61016610146100c61003610016000160001600000000000000000000000000000000000000000000000
010600001e7302a730217002370023700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
01050000217302b730221001a10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01031f200c6400c6200c2100c6250c6300c4250c6200c6200c6200c6300c6200c6200c6200c6200c6250c6200c6200c6250c6300c6200c6200c6250c6200c6200c6200c6200c6250c1250c6300c2350c6250c625
010500002403227032290322d03200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
010200000c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c0700c070
010200000c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c6100c610
010d00001c610106751063510615196051d605116051e6051a6052160513605176051b605186051260518605176051660515605201051d1051a105131050a1051110515105171051610515105101050610501105
011800200c0150e7251001513725180151a7251c01524725150150e7251001513725180151a7251c015247250c0150e7251001513725180151a7251c01524725150150e7251001513725180151a7251c01524725
011800201b5250c5140e5140f514135150c5140e5140f514225250c5140e5140f514135150c5140e5140f51422525165140e5140f514135150c5140e5140f51422525165140e5140f514135150c5140e5140f514
01100000006140061000610006200c6200c6200c6300c630006300062000620006200c6100c6100c6100c615006010c6010060100601006010060100601006010060100601006010060100601006010060100601
011800200c0330ce310ce310f615000000c04310525105250c03300000000001b6150c02313e3113e310c0230c0330ce310ce310f615000000c04310525105250c03300000000000f6150c02313e1113e110c023
011800201c5250c5140e5141c514135150c5140e514105141d5250c5140e5141c514135150c5140e514105141f525175140e5141c514135150c5140e514105141c5251d5140e5141c514135150c5140e51410514
011800201c52500e2000e241c514135150ce500ce54105141d5251ce201ce241c514135151ce201ce24105141f5251de201de241c514135151de201de24105141c52513e2013e241c51413e4313e2013e2313e50
011800001c1100ce500ce500ce500ce540ca0000000101101d11010e5010e5010e5010e540000000000111101f11011e5011e5011e5011e540000000000131101c11013e5013e5013e5013e54000000000010110
011800200fe530fe330fe530fe230fe330fe530fe330fe5311e5311e3311e5311e2311e3311e5311e3311e5313e5313e3313e5313e2313e3313e5313e3313e530fe530fe330fe530fe230fe330fe530fe330fe53
011000000c8230c8230c8230c8230c8230e8230e8230e8230e8230e8230e8230e8230e8230c8230c8230c8230c8230c8230c8230c8230c8230c8230c8230e8230e8230e8230e8230e8230e8230e8230e82300000
001000000af5008f500af300af5009f5006f5004f5004f5007f5008f400af5009f3007f3006f3004f3003f5003f5003f5003f5004f5005f5003f5002f6001f4001f4003f5006f5006f5006f5005f5005f5004f50
0008002003f5005f4006f3007f3005f4004f4002f4001f5001f5003f5005f5005f5003f5005f5005f5004f5003f4003f3003f3003f4003f5004f5002f5001f5001f5002f5004f4006f4006f4004f5003f5004f50
0104000027130221301d1301a13015120101200c1200a120071300512504115021150010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
010c00200b0030be750c5450be750c1350e0030ce750d0030e0030c1350b5450c5550b1350c1350e0030c5750b0030be750c5450be750c1350e0030ce750d0030f0030c1350b5450b5550c1350b135100030b555
010c000016115181250e0050a01519025161050c1150d0250b003181150e0050a1350b003161050c0350d115160251a1050a0150c0251a105160050e1050a0151a105160050d0350a1051a005160350c0050d125
000100002b7572b7572a757287572775726757147570a7570a7570e75713757117570e75716757137570d75716757147570e75714757117570d757117570e7570e7570d7570e757117570f75712757107570c757
01180000100631ae6018e651ae601006318e651ae60100631ae601006318e651ae60100631ae65100631ae60100631ae601ae651ae60100631ae601ae60100631ae60100631ae601ae60100631ae65100631ae60
011800001a5351c525185161ae261ce15185251a5151c535185351a5251c51518e251ae151f5251a51618d361c53518525185151ce261ae16185251c5151a5351c535185261a5161ce261ce15185251c51518535
010300001b5301f530255302b54031500135001750000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000
010200001002016020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000c15501005010050100500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010300001364500005076450000000000000000000507605000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
011000200c1500e1401013011130131300c1500e1401013011130131300c1551314510155131450c1551314510155131450c1551314510155131450c1551314510155131450c1551314510155131450c1550c145
01030000197351e745237550010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500000
0110000015053110030000315053000032d615150530000315053000031505300003150532d6151505300003150532d6151505300003150532d615150530000315053000031505300003150532d6151505300003
010f00000c7730e703007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
01020000106101a610106101a610106101a610106101a610106101a610106101a6100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010c00200b0730ae050c5050ae050c1050e0730ce050d0730e0730c1050a5050c5050a1050c1050e0730c5050e0730c1050a5050c5050a1050d0730c5050d0730f0730c1050a5050a5050c1050a1050f0730a505
010c00200b0630ae050c5050ae050b0630e0030ce050d0030b0630ae050c5050ae050b0630e0030ce050d0030b0630ae050c5050ae050b0630e0030ce050d0030b0630ae050c5050ae050b0630e0030ce050d003
010c00200b0633cb153db153cb1523610176153cb153db150b063236143cb153db1523610176153cb150b0630b0633cb153db153cb1523610176153cb153db150b0633db15236143db1523610176150b0630b063
010c000016115181250e0050a0150b063190250c1150d0250b003181150e0050a1350b063161050c0350d1150b0031a1050a0150c0250b063160050e1050a0150b003160050d0350a1050b063160350c0050d125
0106000011c300cc5011c300cc5011c300cc5011c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000000f7500f750017500f7500f0500f0501f7501f7501f7501f7501f053ca4001b5001f0501c5001f0500f7500f750017500f7500f053ca4001f7501f7501f7501f7501f0500a4001b503f3143dc1001f05
0110000000e7500e750007500e753d91000e0501e7501e750107501e7501e053d9003de053d90001e0501e0500e7500e750007500e7500e0500e0501e7501e750107501e7501e0501e0501e050c0130c0230c033
011800200c0330ce310ce310f615000000c04310525105250c03310e3110e311b6150c02307e3107e310c0230c03311e3111e310f615000000c04310525105250c03313e3113e310f6150c02307e1107e110c023
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
03 41 12 43 44
01 09 13 43 44
00 09 0c 13 44
00 09 42 0c 13
00 0d 09 13 44
00 0e 42 2a 13
00 0f 09 13 44
02 0f 09 13 44
00 41 42 43 44
00 17 42 43 44
00 15 16 43 44
00 15 16 24 44
03 15 26 25 44
03 41 42 43 44
03 41 42 43 44
00 1e 20 43 44
03 12 42 43 44
03 41 29 28 13
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
