pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- go:f
-- by @egordorichev

--[[function srch(t)
 local c=0
 for x=0,127 do
  for y=0,31 do
   if(mget(x,y)==t)c+=1
  end
 end
 printh(t..": "..c)
end

srch(117)
srch(73)]]

local osfx=sfx
function sfx(id)
 if (not g_mute_sfx) osfx(id)
end

function play_music(id)
 if (not g_mute_music) music(id)
end

function _init()

 g_time,state,g_index=
 0,ingame,
 
 18
  	 
 g_moves=0 
 shk=0
 g_cookies=0
 g_presents=0
 g_steps=0
 g_remove={}
 g_bonks=0
 g_moves={}
 g_pines={}
 g_ck={}
 g_guy_talked=false
 g_mob_talked=false
 
 restart_level()
 -- –Š‰ƒ‡’€‹ƒ‡Š’€‹
 --m()
 music(13)
 g_mus=0
 if(g_index==18)say("^by @egordorichev.")
 
end

function _update60()
 state.update()
 tween_update(1/60)
 g_time+=1
end

function _draw() 
 state.draw()
end

function restart_level()
 if g_mus==0 then
  if(g_index~=9 and g_index~=18 and g_index~=0 and g_mus==0) music(14) g_mus=1
 elseif g_mus==1 then
  if(g_index==11) music(1) g_mus=2 say("mus2")
 end
 
 local g=g_guy
 reload(0x2000,0x2000,0x1000)
 reload(0x1000,0x1000,0x1000)
 
 entity_reset()
 collision_reset()
 
 if g_index==22 or g_index==23 then
	 g_grid={}
	 
	 for y=0,127 do
	  g_grid[y]={}
	  for x=0,31 do
	   g_grid[y][x]=false
	  end
	 end
	elseif g_index~=9 and g_index~=3 and g_index~=4 and g_index~=16 then
	 for i=1,20 do
	  e_add(snow())
	 end
 end
 
 g_level=e_add(level({
  base=v(g_index%9*14,flr(g_index/9)*8),
  size=v(14,8),
  pos=v(8,8)
 }))
 
 g_level:fr(function(t,x,y)
  if(g_remove[t]) mset(x,y,0)
  if(t==73 and g_pines[g_index]) mset(x,y,74)
  if(t==117 and g_ck[g_index.."."..x]) mset(x,y,101)
 end)
 
 g_level:load()

 g_text=""
 g_pog=0

 if(g_guy)g_guy.done=true
 if not g then
  g=guy({pos=v(0,0)})
 else
  local sx,sy=g_level.size.x,g_level.size.y
  g.pos=v(g.tx,g.ty)
  if(g.tx<8)g.pos.x+=sx*8
  if(g.tx>119)g.pos.x-=(sx)*8
  if(g.ty<8)g.pos.y+=sy*8
  if(g.ty>55)g.pos.y-=sy*8
  g.tx=g.pos.x
  g.ty=g.pos.y
  g:become("idle")
 end
 
 g.done=false
 e_add(g)
 g:setup()
 g_remove[106]=nil
end

function lget(x,y)
 return mget(x+g_level.base.x,y+g_level.base.y)
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
  local ml,mv=32000
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
 dtile=2,
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
 
function entity:mpx()
 return (self.pos.x-g_level.pos.x)\8+g_level.base.x
end

function entity:mpy()
 return (self.pos.y-g_level.pos.y)\8+g_level.base.y
end

static=entity:extend({
 dynamic=false
})

function spr_render(e,ps,x,y)
 local s,p=e.sprite,e.pos
 
 if x then
  p=v(p.x+x,p.y+y)
 end

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
 local frm_index=flr((e.tt or e.t)/delay) % #frames + 1
 local frm=frames[frm_index]
 
 if e.scl then
	 local sx=e.scl.x
	 local sy=e.scl.y
	 sspr(
	  frm%16*8,flr(frm/16)*8,
	  8,8,
	  sp.x+e.org.x*(1-sx),sp.y+e.org.y*(1-sy),
	  8*sx,8*sy)

  return frm_index
 end
 
 local f=e.bold and ospr or spr
 f(e.exr_sprite or frm,
 (sp.x),(sp.y),w,h,flip_x,e.vert)

 return frm_index
end

function ospr(s,x,y,...)
 for i=0,15 do pal(i,0) end
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

poke(0x5f2e,1)

function r_reset(prop)
 pal()
 palt(0,false)
 palt(14,true)
 pal(8,8+128,1)
 pal(0,128,1)
 pal(1,130,1)
 pal(9,128+15,1)
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
   ent.vel+=v(g_grav_x*w,g_grav_y*w)
  end
 end
end
g_grav_x=0
g_grav_y=1

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

function c_check(box,tags,sm)
 local fake_e={pos=v(box.xl,box.yt)} 
 for tag in all(tags) do
  for o in c_potentials(fake_e,tag) do
   if o~=sm then
	   local oc=c_collider(o)
	   if oc and not o.nocol and box:overlaps(oc.b) then
	    return oc.e
	   end
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

function c_push_out(oc,ec,
 allowed_dirs,e,o)
 local sepv=ec.b:sepv(oc.b,allowed_dirs)
 if (sepv==nil) return
 -- cls() print(ec.b) print(oc.b)
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
 local vl=v(g_grav_x,g_grav_y)
 for e in all(entities_with.feetbox) do  
  local fb=e.feetbox
  if fb then
   fb=fb:translate(e.pos+vl)
   local support=c_check(fb,{"support"},e)
-- ) support=nil
   e.supported_by=support
   if support and support.vel then
    --e.pos+=support.vel
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

function sprint(s,...)
 print(smallcaps(s),...)
end

function coprint(s,y,c,m,n)
 s=smallcaps(s)
 prnt(s,64-#s*2+(m or 0),y,c,nil,n)
end

function prnt(s,x,y,c,o,n)
 if(not o) o=13--o=sget(97,c)
 
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

pltt={,–,˜,™,,€}
function fade()
 clip(8,8,112,64)
 for i=1,#pltt do
  fillp(pltt[i])
  rectfill(0,0,127,127,0)
  for j=1,3 do flip() end
 end
 fillp()
 clip()
end
function fadein()
 shk=3
 for i=1,#pltt do
  cls()
  _draw()
  clip(8,8,112,64)
  fillp(pltt[#pltt-i+1])
  rectfill(0,0,127,127,0)
  clip()
  fillp()
  for j=1,3 do flip() end
 end
end
-->8
-- level

function block_type(blk)
 --if (fget(blk,0)) return solid
 --if (fget(blk,1)) return support
end

level=entity:extend({
 draw_order=2
})

function map(x,y,px,py,sx,sy)
 for tx=x,x+sx-1 do
  for ty=y,y+sy-1 do
   if (g_index~=22 and g_index~=23) or g_grid[ty][tx] then
    local t=mget(tx,ty)
    if(t>0) spr(t,(tx-x)*8+px,(ty-y)*8+py)
   end
  end
 end
end

function level:load()
 local b,s=self.base,self.size
 for x=0,s.x-1 do
  for y=0,s.y-1 do
   local blk=mget(b.x+x,b.y+y)
   local cl=entity.spawns[blk]
   if cl then
    local e=cl({
     pos=v(x,y)*8+self.pos,
     map_pos=b+v(x,y),
     tile=blk
    })
    local xx,yy=b.x+x,b.y+y
    if(not e.norem)mset(xx,yy,e.trr or 0)
    e_add(e)
    blk=0
   end
   local bt=block_type(blk)
   if bt then
    bl=bt({
     pos=v(x,y)*8,
     map_pos=b+v(x,y),
     tile=blk,
     typ=bt
    })
    if (bl.needed) e_add(bl)
   end
  end
 end
end

function level:render()
 map(self.base.x,self.base.y,
 self.pos.x,self.pos.y,
 self.size.x,self.size.y)
end
 
solid=static:extend({
 tags={"walls","support"},
 hitbox=box(0,0,8,8),
 draw_order=2
})
local dirs={v(-1,0),v(1,0),v(0,-1),v(0,1)}

function solid:init()
 local allowed={}
 local needed=false
 for i=1,4 do
  local np=self.map_pos+dirs[i]
  allowed[i]=
   np.x>0 and np.y>0 and
   block_type(mget(np.x,np.y))
    ~=solid
  needed=needed or allowed[i]
 end
 
 self.allowed=allowed
 self.needed=needed
end

function solid:collide(e)
 return c_push_out,self.allowed
end

support=solid:extend({
 hitbox=box(0,0,8,1)
})
 
function support:collide(e)
 if (not e.vel) return
 local dy,vy=e.pos.y-self.pos.y,e.vel.y
 if vy>0 and dy<=vy+1 then
  return c_push_out,{false,false,true,false}   
 end
end

function level:fr(c)
 local bx,by=self.base.x,self.base.y
 for x=bx,self.size.x+bx do
  for y=by,self.size.y+by do
   c(mget(x,y),x,y)
  end
 end
end
-->8
-- entities
function msay(s) 
 return function()
  say(s) 
  sfx(16)
 end
end

drmap={}

function adoor(a,b)
 drmap[a]=b
 drmap[b]=a
end

adoor(0,9)
adoor(2,3)
adoor(10,19)
adoor(4,13)
adoor(15,16)

lmap={}

function aladder(a,b)
 lmap[a]=b
 lmap[b]=a
end

aladder(22,14)
aladder(20,15)
aladder(18,0)
aladder(17,16)
aladder(27,25)

ac={
-- locked door
[114]=msay("^the door is tightly\nlocked"),
-- sign
[89]=function()
 sfx(16)
 say(g_index==17 and 
 "^sign: ^what's 10*4+8/2*10+1?" or 
 (g_index==33 and "^sign: ^beware: ^the lost woods" or "^sign: ^snowvile"))
end,
-- snowman
[69]=msay("^nice"),
-- up sign
[151]=msay("^sign: ^watch your step!"),
-- closed door
[113]=function()
 say("*^knock knock*")
 sfx(21)
 return 65
end,
-- collumn
[150]=function(p,o)
 if o.x==109 then
	 sfx(14)
	 fade()
	 g_index=27
	 g_tp=true
	 restart_level()
	 fadein()
  say("^oh, there is something")
 else
  say("*confused bonk noises*")
 end
end,
-- open door
[65]=function()
 sfx(14)
 fade()
 g_index=drmap[g_index]
 g_tp=true
 restart_level()
 fadein()
end,
-- ladder down
[122]=function()
 sfx(14)
 fade()
 g_index=lmap[g_index]
 g_tp=true
 restart_level()
 fadein()
end,
-- ladder up
[123]=function()
 sfx(14)
 fade()
 g_index=lmap[g_index]
 g_tp=true
 restart_level()
 fadein()
end,
-- iron bars
[106]=msay("^iron bars are too high\nto climb over"),
-- painting
[87]=msay("^nice painting"),
-- present
[139]=function(p)
 p:become("won")
 sfx(15)
 --g_won=true
 say("^you won, have a present\ntoo, ^santa!\n\n"..g_presents.."/8 presents delivered\n"..g_cookies.."/9 cookies eaten\n"..g_steps.." moves made")
 music(-1)
end,
-- another painting
[76]=msay("^where the sun raises\nascend.\n\n^hm, ^i wonder what that\nmeans..."),
-- cookie
[117]=function(p,o)
 sfx(17)
 g_cookies+=1
 g_ck[g_index.."."..o.x]=1
 say("^mmm, what a cookie that was!")
 return 101
end,
-- pinetree
[73]=function()
 sfx(18)
 g_presents+=1
 g_pines[g_index]=1
 say("^every pinetree needs\na present under it!")
 return 74
end,
-- toy car
[90]=function()
 sfx(15)
 say("^you found a car!")
 g_got_car=true
 return 0
end,
-- tube
[81]=function()
 sfx(14)
 fade()
 g_index=drmap[g_index]
 g_tp=true
 restart_level()
 g_remove[90]=1
 fadein()
end,
-- key
[91]=function()
 sfx(15)
 say("^you found a key!")
 g_got_key=true
 g_remove[91]=1
 return 0
end,
-- book
[78]=function()
 sfx(15)
 say("^you found a book!")
 g_got_book=true
 g_remove[78]=1
 return 0
end,
-- room lock
[115]=function()
 sfx(16)
 if(not g_got_key) say("^the lock looks really heavy") return
 say("^the key you found matched\nthe lock!")
 g_got_key=true
 g_remove[91]=1
 return 0
end,
-- numbers
[157]=msay("^sign: ^nice, but no"),

[141]=function()
 sfx(14)
 fade()
 g_index=31
 g_tp=true
 restart_level()
 say("^sign: ^correct!")
 fadein()
 return 0
end,
}

local a={140,142,143,156,158,159,172,173}
for n in all(a) do
 ac[n]=msay("^sign: ^no")
end

snow=entity:extend({
 draw_order=8
})

function snow:init()
 if not self.r then
  self.pos=v(rnd(128),rnd(160)-10)
 else 
  self.pos=v(rnd(128),-rnd(30))
 end
 
 self.r=rnd(2)
 self.t=rnd(1000)
end

function snow:idle()
 self.pos.y+=self.r*0.25
 self.pos.x+=sin(self.t*self.r*0.001)*0.2
 if(self.pos.y>72) self:init()
end

function snow:render()
 rectfill(self.pos.x,
 self.pos.y,self.pos.x+self.r,
 self.pos.y+self.r,7)
 --circfill(self.pos.x,self.pos.y,self.r,7)
end

tube=entity:extend({
 norem=true
})

tube:spawns_from(81)

function tube:render()
 if self.t>20 then
  self.t=-rnd(4)
 
  e_add(part({
   pos=v(self.pos.x+4,self.pos.y),
   vel=v(rnd(2)-1,-0.5),
   r=rnd(4)+2,
   draw_order=2,
   c=rnd(3)+5  
  }))
 end
end

spawn=entity:extend({
 tags={"spawn"}
})
spawn:spawns_from(88)

box=entity:extend({
 tags={"box"}
})
box:spawns_from(120,121)

function box:render()
 if(g_index==22 and not g_grid[self:mpy()][self:mpx()])return
 spr(self.tile,self.pos.x,self.pos.y)
end

function npc(s,l,n,z)
 local a=entity:extend({
  sprite={idle={s,s+1,delay=10}},
  norem=true,
  tags={"s"..s}
 })
 if z then
	 function a:init()
	  if(z()) self.done=true mset(self.map_pos.x,self.map_pos.y,0)	 
	 end
 end
 function a:render()
	 if(g_index==22 and not g_grid[self:mpy()][self:mpx()])return
	 spr_render(self)
	end
 
 a:spawns_from(s)
 ac[s]=n or msay(l)
end

npc(2,"^blob: *blurp*")
npc(22,"^snek: ^the path in the woods\ngoes ”‘ƒ‘")
npc(20,"^very old man: ^i still can't\nsolve this :(\n^guess i'm stuck here\nforever")
npc(8,"^cat: ^do you ever just like...\nwant to sle.e..\n*z^zz*")
npc(4,0,function()
 sfx(16)
 if(not g_got_car) say("^boy: *sob* ^i've lost\nmy car *sob*") return
 say("^you found my car!\nthank you so much!")
 entities_tagged["s4"][1].done=true
 g_guy_talked=true
 
 return 0 
end,function()return g_guy_talked end)
npc(133,0,function()
 sfx(16)
 say("^computer: ^random numbers\nare so cool!\n^here is my favoirte one: "..flr(rnd(256)-128))
end)

npc(6,0,function()
 sfx(16)
 if(not g_got_book) say("^???: ^hm, what should i read\nnext?") return
 say("???: ^oh, fancy hair 101?\n^thank you so much!")
 entities_tagged["s6"][1].done=true
 g_mob_talked=true
 
 return 0 
end,function()return g_mob_talked end)


npc(10,0,function()
 sfx(16)
 say(g_bonks==0 and
  "^wow, you haven't bonked\na single time!" 
  or "^you have bonked "..g_bonks.."\ntimes!")
end)
-->8
-- guy

guy=entity:extend({
 sprite={
  idle={16,17,18,19,delay=8},
  won={34,35,36,37,delay=8},
  move={32,17,33,16,delay=8}
 }
})

guy:spawns_from(16)

function guy:won()
 self.tt+=1
end

function guy:setup()
 if self.dx==nil then
  self.dx=0
  self.dy=0
 end
 
 self.tt=0
 g_guy=self
 
 if not g_tp and self.pos.x~=0 then
  if not fget(mget(
   (self.pos.x-g_level.pos.x)\8+g_level.base.x,
   (self.pos.y-g_level.pos.y)\8+g_level.base.y
  ),0) and self.pos.x>=0 and self.pos.y>=0 and self.pos.x<=128 and self.pos.y<=64 then
   return
  end
 end
 local s=entities_tagged["spawn"]
 
 if(not s)return
 local md,sp=32000
 
 for i=1,#s do
  local d=#(s[i].pos-self.pos)
  if(d<md or not sp) sp,md=s[i],d
 end
 
 self.pos.x=sp.pos.x 
 self.pos.y=sp.pos.y
 self.tx=self.pos.x
 self.ty=self.pos.y
 self.ox=self.tx
 self.oy=self.ty
 self.fail=false
 self:become("idle")
 self.t=0
 g_tp=false
 if(g_index==22 or g_index==23) self:exp()

end


function guy:ex(x,y)
 x=mid(0,127,x)
 y=mid(0,31,y)
 g_grid[y][x]=true
end


function can_see(x0,y0,x1,y1)
 dx=abs(x0-x1)
	dy=abs(y0-y1)
	sx=x0<x1 and 1 or -1
	sy=y0<y1 and 1 or -1
	err=dx-dy
	fnd=false
	while true do
		if(fnd) return false
		local t=mget(x0,y0)
		if(fget(t,0)) fnd=true
		if(x0==x1 and y0==y1) break
		e2=err*2

		if e2>-dx then
			err-=dy
			x0+=sx
  end

		if e2<dx then
			err+=dx
			y0+=sy
		end
	end

	return true
end

function guy:exp()
 local x,y=
 (self.pos.x-g_level.pos.x)/8+
 g_level.base.x,
 (self.pos.y-g_level.pos.y)/8+g_level.base.y
 local d=6
 
 for xx=-d,d do
  for yy=-d,d do
   if sqrt(xx*xx+yy*yy)<=d and 
    can_see(x,y,xx+x,yy+y) then
    self:ex(xx+x,yy+y)
   end
  end
 end
end

bonk={"*bonk*","^ouch","*^b^o^n^k*"}

function guy:idle()
 self.tt+=1
 if(self.t<0) return

 local dx,dy=self.dx,self.dy
 
 if dx==0 and dy==0 then
	 if(btn(‹))dx=-1
	 if(btn(‘))dx+=1
	 if(btn(”))dy=-1
	 if(btn(ƒ))dy+=1
 end
 
 if dx~=0 or dy~=0 then
  if(dx~=0) dy=0
  
  self.bx=nil
  local bx,by=g_level.base.x,g_level.base.y
  
  local tx,ty=
  (self.pos.x-g_level.pos.x)\8+bx,
  (self.pos.y-g_level.pos.y)\8+by
  local ttx,tty=tx+dx,ty+dy
  local t=mget(ttx,tty)
  local out=ttx<bx or tty<by or ttx>=g_level.size.x+bx or tty>=g_level.size.y+by
  
  if not out and ac[t] then
   t=ac[t](self,{
    x=ttx,
    y=tty,
    t=t
   })
   if(t~=nil) mset(ttx,tty,t)
   self.t=-20
   self.dx,self.dy=0,0
   return
  end
  
  self.ice=self.dx~=0 or self.dy~=0
  if(fget(t,0))self.fail=true self.b=self.ice and "*bounce*" or bonk[flr(rnd(#bonk))+1]
  
  self.dx=dx
  self.dy=dy
  self.ttx=ttx
  self.tty=tty
  self.ox=self.pos.x
  self.oy=self.pos.y
  self.tx=self.pos.x+dx*8
  self.ty=self.pos.y+dy*8
  
  if out then
   if g_index==18 or
	   (g_index==0 and g_presents==0)
	   or (dy==1 and g_index==12 and g_presents<2) then 
	    self.fail=true
	    self.b=g_index==18 and "*bonk*" or "^i should leave a present in\nthe house first"
   elseif g_index==9 then
    self.fail=true
   elseif g_index==34 then
    if dx==1 and #g_moves>2
     and g_moves[1]==3 
     and g_moves[2]==1
     and g_moves[3]==4
     then
	    g_index=35
	    restart_level()   
    else
     add(g_moves,(dx~=0 and (dx>0 and 1 or 2) or (dy>0 and 4 or 3)))
     if(#g_moves>3) del(g_moves,g_moves[1])
     if(dx==-1)g_index=33
     restart_level()
    end
   else
    g_index+=dx+dy*9
    restart_level()
   end
  end
  
  if not self.fail and entities_tagged["box"] then
   for b in all(entities_tagged["box"]) do
    if b.pos.x==self.tx and b.pos.y==self.ty then
     if(fget(mget(ttx+dx,tty+dy),0))self.fail=true self.b="^uhhh" break
				 for bb in all(entities_tagged["box"]) do
					 if b~=bb and bb.pos.x==self.pos.x+dx*16 and bb.pos.y==self.pos.y+dy*16 then
					  self.b="^this box be heavy doe"
					  self.fail=true
					  break
					 end
					end

				 if(not self.fail) self.bx=b
     break
    end
   end
  end
  
  if not self.fail then
   if(not ice)g_steps+=1
   if(mget(ttx,tty)==75)butn(false)
  else
   self.dx,self.dy=0,0
  end
  
  self:become("move")
  return
 end
end

function butn(on)
 g_level:fr(function(t,x,y)
  if(on and t==106) mset(x,y,107) sfx(22)
  if(not on and t==107) mset(x,y,106)  sfx(23)
 end)
 if(on)g_remove[106]=1 say("^something activated")
end

function guy:move()
 self.tt+=1
 self.pos.x+=(self.tx-self.pos.x)*0.2
 self.pos.y+=(self.ty-self.pos.y)*0.2
 local dx,dy=self.dx,self.dy
 
 if(self.fail and self.t>=4)self.fail=false self.tx,self.ty=self.ox,self.oy say(self.b) self.t=-4 g_bonks+=(self.ice and 0 or 1)
 if self.t>=8 then
  if(not fget(mget(self.ttx,self.tty),1)) self.dx,self.dy=0,0
  self:become("idle") self.pos=v(self.tx,self.ty)
  if(g_index==22 or g_index==23)self:exp()
 end
 if self.bx then
  self.bx.pos=v(self.pos.x+dx*8,self.pos.y+dy*8)
  if(self.state~="move" and mget(self.ttx+dx,self.tty+dy)==75) butn(true)
 end
 if(self.state=="idle")self:idle()
end
-->8
-- fx

spark=entity:extend({
 draw_order=10,
 sprite={idle={delay=4,13,14,15,29,30,31,45}}
})

function spark:idle()
 if(self.t>=28) self.done=true return
end

part=entity:extend({
 draw_order=0,
 tags={"part"}
})

function part:idle()
 self.r-=(self.spd~=nil and self.spd(self.t) or 0.1)
 self.vel.x*=(self.mul or 0.9)
 if self.r<0 then
  self.done=true
 end
end

function part:render()
 circfill(self.pos.x,self.pos.y,self.r,self.c)
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
   t.progress+=dt*t.rate
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

ingame={}

function ingame.update()
 e_update_all()
 do_movement()
 do_collisions()
 do_supports()
end

function ingame.draw()
 cls()
 
 if shk>0.1 then
  shk-=0.5
  camera(rnd(shk)-shk/2,rnd(shk)-shk/2)
 else
  camera()
 end	
 
 clip(8,8,112,64)
 r_render_all("render")
 clip()
 camera()
 rect(4,4,123,75,2)
 rect(4,80,123,123,2)
 
 spr(221,0,0)
 spr(253,0,72)
 spr(221,0,76)
 spr(253,0,120)
 
 spr(223,120,0)
 spr(255,120,72)
 spr(223,120,76)
 spr(255,120,120)
 
 if(g_pog<#g_text)g_pog+=0.5
 sprint(sub(g_text,1,g_pog),8,84,7)
 
 if(g_index==18) coprint("‹‘”ƒ    ",75,7)
 --if(g_guy)print(g_guy.pos.x..":"..g_guy.pos.y,1,1,7)
end

function say(t)
 g_pog=0
 g_text=t or "error"
end
__gfx__
0000000010101010eeeeeeeeee0000eeeeeeeeeeeee00eeeee00000eeee000eeee028210eee000eee000000eeeeeeeee00000000000000000000000000000000
0000000000000002ee0000eee028820eeee00eeeee09f0eee0677760ee06760ee0288807ee02821003bbbbc0e000000e00000000000000000000000000000000
0070070010555500e028820e0088880eee09f0eeee0990eee0778870e0676860e0128200e02888070b0dd0b003bbbbc000000000000000000000000000000000
00077000005005020288882001888820ee0990eee012210e08060070e0070070e077770ee01282000b300cb00b0dd0b000000000000000000000000000000000
00077000105005001288888202228820e012210ee022220e2068886208161170e011110ee077770e03bbbb300b300cb000000000000000000000000000000000
0070070000555502222888820202802008222280e022220e0028888020688862e011220ee011110ee033cc0e03bbbb3000000000000000000000000000000000
00000000100000001022280201128120e014410e08144180e022888000228880e071270ee011220e0d33bbd00d33bbd000000000000000000000000000000000
000000000202020201222210e012210ee022220ee022220ee0200020e0200020e011210ee071270ee030030ee030030e00000000000000000000000000000000
eee00eeeee0880eeee0880eeeee00eeeee0000eeeee00eeeeee02882ee0288200000000000000000000000000000000000000000000000000000000000000000
ee0880eeee0880eeee0880eeee0880eee09ff90eee0990eeeee08787ee0878700000000000000000000000000000000000000000000000000000000000000000
ee0880eeee0220eee082280e00888800e0ffff0e009ff900eee08282ee0828200000000000000000000000000000000000000000000000000000000000000000
00822800e088880e028888208282282800067000f0ffff0feee08800ee08820e0000000000000000000000000000000000000000000000000000000000000000
828888280288882080888808008888009827728f08067080eee0880eee02880e0000000000000000000000000000000000000000000000000000000000000000
008888008081180800211200e028820e00277800e027720ee000280ee00028200000000000000000000000000000000000000000000000000000000000000000
e021120e00200200e080080ee081180ee027680ee027680e01282220012822200000000000000000000000000000000000000000000000000000000000000000
e080080ee080080ee080080ee080080ee012880ee017780e12228882122288820000000000000000000000000000000000000000000000000000000000000000
ee0880eeeee00eeeeee00eeeee0aa0eeee0bb0eeeee00eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0880e0ee0880eeee0880eeee0aa0eeee0bb0eeee0cc0ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e08228080e0880eeee0880eeee0990eee0b33b0e00cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000
028888208082280e00822800e0aaaa0e03bbbb30cdcddcdc00000000000000000000000000000000000000000000000000000000000000000000000000000000
8088880e028888208288882809aaaa90b0bbbb0b00cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0021120ee088880800888800a0a11a0a00311300e0dccd0e00000000000000000000000000000000000000000000000000000000000000000000000000000000
08000080e0211200e021120e00900900e0b00b0ee0c11c0e00000000000000000000000000000000000000000000000000000000000000000000000000000000
e0eeee0eee0880eee080080ee0a00a0ee0b00b0ee0c00c0e00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444044411111111212821280001300000030000000220000000000000000000000000000003100000031000000000004444044466606670028888200dd0ddd0
44442444244414428188818800033000000b30000024440000111100001111000111111000037000000370000028820049ff7794666d666d0282218000000000
2444444442000024818881880033b3000013b300000670000111111001011210011111100016b1001016b100028888202f000074666d666d02888880000dd000
244424444000000421221122013bbb30003bb31000000000011111100111111001111110008b3800008ba8a0088828802627a974555d555d0281288000000000
2444244440000004882128880353bbb000b3353040677602011111100101101001111110033673b00336faf1088288802f9a7274ddd5ddd50288888000000000
244444442000000488818888013b3330003b53100268774001111110011100100111111001355b1001358f80028888202f0000f4000000000222221000000000
24444444200000048881888800135b0000133100006677000011110000111100011111100002400010012920012882102966ff94000000000177777000000000
211222212000000422212122000240000000200000d6860000000000000000000000000000000000000029200011110011122221000000000111221000000000
111101110d6666d08828882844442444444444442422222214444441444404440000000000000000eeeeeeee0000000000000000000000006660666066606660
4444244406dddd60882888284444122225444444444444444999f9f449ff77940e0000e000002000000000ee000000000000000000000000666d6660666d6660
881111880655556088288828244424444444444444424444244444422f5dd57400000000024444422889820ed66d00000000000000000000666d6660666d6660
21a9aa120d6666d0221221222444244444444444444444444338c9a426dddd74000ee000041414148ccc7d206006567d0000000000000000555d5550555d5550
88a9998805dddd50888882881222144444444444444444442132ca942f8dbd74000ee000024444428dccc780600600d6000000006660666066650000000d6660
21a999121055d50188888288244404444445542244444444244994922f2833f4000000000000100028888892d66d000600000000666d666d6660000000056660
882211881055d508888882882444244444444444444222422f9a3bc42966ff940e0000e00000200085d885da0000000000000000666d666d6660000000006660
24442444201551022222212202112221222222224444444419aabbc21112222100000000000020002d582d520000000000000000555d555d5550000000005550
5dddddd5110111111111000149999994444444444444444411011911d6155d6d4415dd44119110110000000000000000ddd0ddd0ddd0ddd0666d666066600000
dddddddd110101111111110199999999444444444d6666d411010911665555664415d6441190101106600660000000000000000000000000666d6d6066600000
dddddddd1100111010111100999999994441442246555562110014106611116624555d44014100110660066000000000d0ddd000d0ddd0ddd66d666066600000
dddd5ddd0000000000000000999999994444444446dddd6402449200d6dd6d6d2415d544002944200dd00dd0000000000000000000000000555d555055500000
ddd5dddd1101011011011110999999994444444446dddd6414444210155555d12415dd440124444105d005d0000000000000000000000000666d66d066600000
dddddddd111101111101111199999999444444444d6666d4144442115000000d2455dd441124444105d00dd0000000000000000000000000666d666066600000
dddddddd0111001101010011999999992444444221dddd12012221115000000d2411dd44111222100dd005d0055005d00000000000000000666d666066600000
5dddddd50000000000000000499999944444444444111144020002005111111511155d210020002005d005d0015005500000000000000000555d555055500000
5dddddd5111111111111111100d66d00441221444444444400f00f00288888820499994000000000000000000d6600000dd0ddd0666000000000666000006660
dddddddd244414422444144200600600441220444d6666d4029449408888888809244290049999400d6666d00666000000000000666000000000666d00006660
dddddddd420000244200002400600600240110444604427200900900888888880499994009999990065500600666d6d0000dd0dd666000000000666d00006660
dddddddd40244204402d62040d6776d0241220444644446402f42f40888888880244442004999940065d1560066dd66000000000555000000000555d00005550
dddddddd404444044046640406666660141220444624046400f00f00888888880414424002444420065d156005d5d66000000000ddd000000000ddd500006660
dddddddd2044440420d00d04066dd660241021444d6666d402f42f40888888880411414004144440065d15600dd5d6d000000000000000000000000000006660
dddddddd20444a0420dd66040d6666d02412214421dddd1200900f008888888802444420024444200d6666d00dd5555000000000000000000000000000006660
5dddddd52044440420d66d0400000000041221444211112402f42f40288888820000000000000000000000000000000000000000000000000000000000005550
000000000000000060666060606660606660666000000000000000000001300024440444dddddddd00144100009f0f9000000000000000000000000000000000
0000000000000000605550606055506066606660066666d0066666d00003300022442444dddddddd0014410002ff9ff2d0d05d505d505d00dd50d0d0dd505dd0
000000000000000060d66060d66066d0666066600d6666600d6666600033b30012244444ddddd7dd0000000009aaaaa9d0d0d0d0d0d00d0000d0d0d000d0d000
000000000000000050656050555055505550555005dddd5005dddd500131323012224444dddd7ddd000000000288a8825dd0d0d0ddd00d005d505dd05d505d50
66600000000066606066d06066606660d66066d00d0000d00d0300d0035323b022221444ddd7dddd000000000122922100d0d0d0d0d00d00d00000d0d00000d0
666000000000666d6055506066606660655055600d0000d00d0000d00131323022221244dd6ddddd000000000222922200d05d505d505d505dd000505dd0dd50
666000000000666d60666060666066606066606005d66dd005d66dd000135b0022221224dddddddd000000000222922200000000000000000000000000000000
555000000000555d5065605055505550506d60500555dd500555dd500002400022221221dddddddd000000000122422100000000000000000000000000000000
28888882288888820444444400000000000670000006000000d66600000020000777600677000077600677706006777000000000000000000000000000000000
888888888888888800444444400000000007700000076000006666000244444275dd7777d577775d7777dd577777dd57d0d05d505d505d50005d50005dd05d00
88888888888888880002442244000000006776000067760000666d00044474447dddddddddddddddddddddd7ddddddd7d0d000d0d000d0d000d0d000d0000d00
88882888888888880000444444400000017767600077676000dddd00044676447dddddddddddddddddddddd7ddddddd75dd05d50dd505dd000d0d0005d500d00
888288888888888800000444444400000353777000b73530000550000464746467dddd7dddddddddddd6dd76ddddddd700d0d000d0d000d000d0d00000d00d00
88888888888888880000004444454000013b3330003b5710005555000444744407ddd7dddddddddddd7ddd70ddddddd700d05d505d505d50005d5000dd505d50
8888888888888888000000044444440000135b000013310000d55d000244444207dd6dddddddddddd6dddd707777dd5700000000000000000000000000000000
288888822888888200000000422422400002400000002000005dd5000000100067dddddddddddddddddddd766006777000000000000000000000000000000000
00000000000000000000000000000000000080000000000000000000000000007dddddddddddddddddddddd77700007700000000000000000000000000000000
000000000000000000000000000000000008800000000000000000000000000075dddddddddddddddddddd57d577775d5dd0dd505d505d500000000000000000
000000000000000000000000000000000008800000000000000000000000000007dddddddddddddddddddd70ddddddddd00000d000d0d0d00000000000000000
000000000000000000000000000000000400002000000000000000000000000007dddddddddddddddddddd70dddddddddd5005d50d50d0d00000000000000000
000000000000000000000000000000004408802200000000000000000000000007dddddddddddddddddddd70ddddddddd0d000d000d0d0d00000000000000000
000000000000000000000000000000044408802220000000000000000000000007dddddddddddddddddddd70dddddddd5d5000d05d505d500000000000000000
000000000000000000000000000000000008200000000000000000000000000075dddddddddddddddddddd57d577775d00000000000000000000000000000000
00000000000000000000000000009990994763330330000000000000000000007dddddddddddddddddddddd77700007700000000000000000000000000000000
000000000000000000000000000009909996713303330000000000000000000067dddddddddddddddddddd760777777067dddd767dddddd70777600600000000
000000000000000000000000000000000005d00000000000000000000000000007dddd6dddddddddddd6dd7075dddd5707dddd7075dddd5775dd777700000000
00000000000000000000000000000001110dd05550000000000000000000000007ddd7dddddddddddd7ddd707dddddd707dddd7007dddd707ddddddd00000000
00000000000000000000000000000000110dd05500000000000000000000000067dd6dddddddddddd7dddd767dddddd767dddd7607dddd707ddddddd00000000
00000000000000000000000000000000010000500000000000000000000000007dddddddddddddddddddddd767dddd767dddddd707dddd707ddddddd00000000
00000000000000000000000000000000000dd0000000000000000000000000007dddddddddddddddddddddd707dddd707dddddd707dddd707ddddddd00000000
00000000000000000000000000000000000dd00000000000000000000000000075dd7777d577775d7777dd5707dddd7075dddd5775dddd5775dd777700000000
00000000000000000000000000000000000d000000000000000000000000000007776006770000776006777067dddd76077777707dddddd70777600600000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012820000000028210000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000120000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000080000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000080000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000020000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000080000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000180000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012820000000088210000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000101010100000001010001010000010101010101010100000100000101010000000101010001010001000000010100000101010100000000000100010101
0101010101010000010200000000000000000101010101000202020200000000000000000000010102020202000000000000000000000000020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4343434343434343434344434344434343444343434343434343434343444344444443434343434344436363636363636363636368636363636363636363636363636363636301010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000
4443000000000044444400004344434300000000434343434444444343430052425252525252524243436388534c40405640534068404063638840405340404040638840406301000000000000010000000000010100000000000000000000000001010000000000000000000000000101000000000000000000000000010000
4300000042524242515200000043430000000000000000000043444343000052525252525252517743436362620061626148616167586153567861614862006161634961466301000000000001010100000000010100000100010100000000000001010000000000000100000000000101000001010100000000000000010000
4300450042425252424200000000580000430000000200000043444443590052424252425252527743436361446263636363636160606162626170616955556661636278796301000000000001010100000000010100000101010100000000000001010000000000010100000000000101000001010100000000000000010000
4300000074504071537400464647624647470000000000004648465858000000745574406440747643436346466263884040636260606161616160616964656661636363486301000000000000000000000000010100000001010000000000000001010000000000010100000000000101000001010100000000000000010000
4300000000005846464746480000430000464846464846464647464661460000747274504050747647436362436263664862404870606263636160616954546661534040736301000000000000000000000000010100000000000000000000000001010000000000010000000000000101000000000000000000000000010000
4343000000007b0000000000434343430000000000000000434344444300464647464646004300009743636161626346484846624661626363614861628a8a6161616258616301000000000000000000000000010100000000000000000000000001010000000000000000000000000101000000000000000000000000010000
4343434343444343434344434343434443434443434443444443434343434444444300470044004647436363637263636363636363636363636363636363636363636341636301010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000
0000635640405357406388406856434343434444434395434444434343444443444346464344004846434344434344434343444443434343524252424252524343434344434443434343434343434343434344430000000000000000000000000000636363636363636863636363636300815d5d5d5d5d5d5d5d5d8000000000
63636361616161616140616167614343636300484848636300004b43434400000058474643430046004344430046004343878787874343435252524252525243430000474343434444430000004444464343444300815d5d5d5d5d5d5251525252426388404053534068406353404063816e8c6e9f6e8e6e8f6e9e6e80000000
4053406161616161616161626161436a416300485a4840400000004343440000464600434300474700434400450000004387434300000043404054504150544343475b4643434443434344000046460000444443007f7c6d6d6d6d6d52425252525263919191919090679163919091637f7c004f004f004f004f006c6e800000
616161616363636263636361706143586363634848484300000058460046000046484604464646000043434555756600878743000046464343434300580000004346004643434343000043434346460045004443007f007b0048004974415450746463904966626269629163917b91637f007a0059006162000000146c6f0000
626060616388536140564061606194004040404343780046000046464646460000460043000000004343436954544500434343004600464344430000470000004343064343434300005800434343470000004343007f005800000048480000006f0063906261626262629163639163637f0058000046000000620046006f0000
5555706263616161616262616062940000004300000000007800004344440048000000434300004343434300458a0000434343434758464647464800004600464800460046464647487a00434343434300434343007f000000006e00000000006f0063906261636363619140409140637e5f000000000000000000005e7d0000
647566626361615861616361496243430000007800430000000043434344430000004343444343434344434300004743434343434743434443430000004647000000004343434343000000434343434343484800007e4d4d4d4d4d4d4d4d4d4d7d006390919163006390919191909163007fad6e9c6eac6e9d6e8d5e7d000000
54546161636363416363636161614343434343434343444444434343434444434443434343434444444443434343434344444343474343444343434343434443434343434343434344434343434344440048004800000000000000000000000000006363416363006363636363636363007e4d4d4d4d4d4d4d4d4d7d00000000
0000000000540000540000000000000000000000000000434343434343434343434343434343434343434344444443434344444346434343815d5d5d5d5d5d5d5d5d5d5d5d8044434394434495959543434343434343434343436363636363434343434343434343434343434343434394944343434395959543434343430000
00645575000000000000555555000063636363630000434343434444434b43000000004600000000004344000044444343444444485800437f756d6d856e7c6d6d6d6c6e4f6f4400430000004300000043430043434343bb00006340405363004300000000000000000000960000434394430000000000000000000043430000
006400000055555593006400000000634140566300004344434344434300989999999b46000046004887870000989a4444439899999a55437f7b84466e6e006e785e6e6e4e6f4300000043000000440000950043439899aa430063000062630000000096000000a3a4a5000000000043430094000046008b4800009400430000
006400550064000055006455000000635869556300004343444344444300b8b9b9ba0000000000000043440098a9aa004398a989a9aa75437f5882486e6d006c00847c6d006f959500949443434444430095000058b8b9b9ab9b63614961400043005800000096b3b4b500000000004343000000004658004600000000950000
009254540064000064005400000000630000756300004343434443434343436a43440000004800009899999989a9a99999a9a9a989aa54447f0082006c006e5f48836a5e6e6f940000430000000043000043004394000000430063610000610000000000000000000000000000960043430000000048000a0000000000950000
000000000092545454000000000000636363636300004343434443444443467a4644007800480058b8b9b9b9a9a9a9b9b9b9b9b9b9ba8a437f0083006e006d84004f006e6d6f43004343004343874300434300954300000000006363006363004300000096000000009600000000004344009400004847004800009400950000
004300580046484600477a004300004040404040000000434343444343434658464400000000000044434344b8b9ba4343000000004600437f004f006e0000834b6e006c006f43000000004300000000000000954343000043004040624040000000000000000000434343434343434344430000000000000000000043430000
00000000000000000000000000000000000000000000004443444443434487434343434343444443434343444443874443444443434343437e4d4d4d4d4d4d4d4d4d4d4d4d7d434343580043434343444343439543434343000043430043434343434343434343430000434300434343434343434343989a4343434394430000
434343434343444443434343439401010101010101010101010101014443874343434343434444434344444343434643439443434343944343434343434343434343439595434343436a6a43944343949443444444434343005843430043434343434343434343435800434387434343954395434343b8aa4343944394940000
4343007b5800000000006200434301000000000000000000000000014400000000000000000000000043444343000000434343004843434344989a949899999a9498ab9a44954343be99999a43439595000043434443000000000047000000004343444444439443000087878743954395434300989a43bd43989a4343430000
430046000000460000000000004401000000000000000000000000014400440044004444440000480043444300005555484300080000006287a8b999a989a989abba94a89a94944378a889aa4b444400000000434300000000000000480000000043434343444343000043434343434343000098a9a999a999a9a99a43430000
430000556455556464756400004301000101000000000000000000014300440044000044000000480043449500007554004300000000624344bc58b8a9a9a9aa959498a9a9ab9b5898a9a9a99a4443001600004343000000614848614648005946005800000000000000000000000058580098a9a9a9a9a989a9a9aa43430000
956100545454646464545500944301010100000000000000000000014300444944000044000000000043444346008a8a435555750000474343449494a8a9a989999989b9aa949562a8a9a9a9aa44430000620000000000004846624847610000000000000000000000000000000000000000a8a9a989a9a9a9a9a9ba43430000
449500008a000000008a0000004301000000000000000000000000014300440044004444440000460043444346460000435454544646434394449494b889a9a9a9a9aa94bd949561b8a9a989aa43944300009494430000020000000048004600004343434343434300004343434344434343b8a9a9a9b9a9a9a9ba4343440000
434348464500450045004500434301000000000000000000000000014300000000000000000000000043434343000043438a438a004343434444444494b8b9b9b9b9b9abba43434443b8b9b9ba4443949595949543430000000000460000000043434394439543430000434349434344434343b8b9ba43b8b9ba434344440000
4343434343444443434343434343010101010101010101010101010143434343434344444343434343434343434395434343434943439443444444444394434343944343954343434395434395434343959543434343434343434343434343434343434343434343580043438743434343434343434343949494434343430000
__sfx__
002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000200e035110321103513000130351603113032100350e0351103211035130001303416035150351500513035100300e03510000150351503110035100050e03513030130351000016035150321303511032
011000200e053100000e655130000e053160000e6050e6050e053000000e6550e6050e0530e6050e0530e6050e053000000e655000000e05300000000000e6550e053000000e655000000e053000000e6540e655
012000200211205112091120411202100091120410202112021120511209112041120510209112041020211202112051120911204112021050911204102021120211205112091120411202112051150911204115
01200020021020511209112041120210205102091020410202102021120511209112041120510209102041020210209112021120511209112041120910204102021020511209112041020a115091120711505112
011000200217502155021350010502175021550213500105091750915509135001050917509155091350010505175051550513500105051750515505135001050417504155041350010504175041550413500105
011000200e0750e0550e035000050e0450e0250e01500005150751505515035000051503515025150150000511075110551103500005110351102511015000051007510055100350000510035100251001500005
011000200e1010e1010e145151250e105001070e145151250e10500107151451112515105001071514511125151050010713145111251110500107111450e1051110500107101450e1251010500107101420e122
011000200e135111051113513105131351610513135101050e135111051113513105161351610515135151050e135101051313510105151351510510135101050e13513105131051010516135151051313511105
011000210e535115051153515535135351650513535155350e535115051153511535165351650515535115350e535105051353511535155351550510535105050e53513505105350e5051653515505135350e505
017408100261402612026120261502614026150262402625026140261202613026140261202614026150261400000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200e013100000e615130000e013160000e6050e6050e013000000e6150e6050e0130e6050e0130e6050e013000000e615000000e01300000000000e6150e013000000e615000000e013000000e6140e615
011000200c145101050c14510105131450e1451314513105101450c145071450b1450e1451314517145171051314517145091450b1050e145151450e1450e105151450e1450b14510105131450e1051314513105
011000200c33510335133350e335133350c305103350c3350b33510335133350e33513335003050e335133350c33510335133350e305093350b3350e3350b3050b33510335133350e33513335003050e33513335
011000000c635000000c625000000c615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001054215545000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000c1220e122001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102
011000000e14613146151460000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006
011000001314500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000018134131340f1340c1340c1040c1040f10400104001040010400104001040010400104001040010400104001040010400104001040010400104001040010400104001040010400104001040010400104
010c00000c073120030c0730000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
010900000c3550f3551335518351183551b3050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305
01100000223551b355000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0109000016155221551d1050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
001000001f15522105000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
011000001b15500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
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
00 02 42 43 44
00 02 04 43 44
00 02 03 43 44
00 02 01 03 44
00 02 01 03 44
01 02 05 07 44
00 02 05 07 44
00 02 05 08 44
00 02 05 08 44
00 02 05 09 44
00 02 05 09 44
00 02 05 06 44
02 02 05 06 44
03 0a 42 43 44
03 0b 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
