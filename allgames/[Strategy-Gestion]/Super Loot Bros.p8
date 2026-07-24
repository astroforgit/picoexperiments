pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- super loot bros
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

cartdata("the_super_loot_bros")

function chkd(i)
 return dget(i)==1
end

local pl=-1

function pmusic(n)
 if(pl~=n) pl=n music(n)
end

local omusic=music
local osfx=sfx

function sfx(s)
 if(g_sfx) osfx(s)
end

function music(s)
 if (g_music) omusic(s)
end

function _init()
 
unlocks={
 {"^world 2 unlocked!",function() dset(0,1) end,true},
 {"^world 3 unlocked!",function() dset(1,1) end,true},
 {"^mage class unlocked!",function() dset(2,1) end},
 {"^thief class unlocked!",function() dset(3,1) end},
 {"^healer class unlocked!",function() dset(4,1) end},
 {"^meta mode unleashed!",function() dset(5,1) end,true},
 {"^world 4 unlocked!",function() dset(6,1) end,true}
}
 
 for i=1,#unlocks do
 unlocks[i][4]=chkd(i-1)
 end


 worlds={}
 worlds[2]=chkd(0)
 worlds[3]=chkd(1)
 worlds[4]=true
 worlds[5]=chkd(6)
 worlds[6]=true
 meta=chkd(15)
 g_time,shk,mb,state,g_level,g_mod,
  g_coins,g_tut=
 0,10,false,menu,1,0,(dget(17) or 0),not chkd(20)
 
 g_music=not chkd(32)
 g_sfx=not chkd(33)
 
 cls()
 poke(0x5f2d,1)
 eblocked={}
 cblocked={}
 for x=0,15 do
  eblocked[x]={}
  cblocked[x]={}
  for y=0,15 do
   eblocked[x][y]=false
   cblocked[x][y]=false
  end
 end
 restart_level()
end

function _update() 
 g_time+=2
 state.update()
end

function s(n)
 return n==1 and "" or "s"
end

function _draw()
 if (state~=menu) cls(12)
 state.draw()
 r_reset()
 spr(16,mx,my)
end

function restart_level()
 reload(0x2000,0x2000,0x1000)
 camera()
 
 g_curr_en,g_turns,g_enemies,
 g_lost,g_stop,g_won,g_score,
 g_kills,g_unlockstr,unlock=0,3,0,
 false,false,false,0,0

 entity_reset()
 
 e_add(level({
  base=v(0,0),
  size=v(16,16)
 }))
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
  x=(x or 0),y=(y or 0)
 },vector)
end

-------------------------------
-- entities
-------------------------------

entity=object:extend({
 state="idle",t=0,
 dynamic=true
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
 spr(frm,p.x*8,
  p.y*8+(e.z or 0),w,h,flip_x)

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
  end
 end
end

indexed_properties={
 "dynamic",
 "render","render_hud",
 "vel"
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
 local a=drawables[2]
 if a then
  for i=1,#a do
   local j=i
   while j>1 and a[j-1].pos.y+a[j-1].z<a[j].pos.y+a[j].z do
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
 if (prop~="render_hud" and g_cam) g_cam:set()
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
  --if ev.x~=0 and abs(ev.x)>abs(ev.y) then
  
  if ev.x>0 then
   ent.facing="right"
  elseif ev.x<0 then
   ent.facing="left"
  end
   --ent.facing=
   -- ev.x>0 and "right" or "left"
  --elseif ev.y~=0 then
  -- ent.facing=
   -- ev.y>0 and "down" or "up"
  --end
  if (ent.weight) then
   local w=state_dependent(ent,"weight")
   ent.vel+=v(0,w)
  end
 end
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
 if(not o) o=sget(113,c)
 
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
-->8
-- level

level=entity:extend({})

function level:init()
 self.index=0
 local f,s,t,b,h=g_level==1,
  g_level==2,g_level==3,g_level==4,
  g_level==5 or g_level==6
 
 fill(0,0,16,16,0)
 fill(1,1,14,13,(t or h) and 8 or (b and 13 or 9))
 fill(1,14,14,1,2)
 
 if (b) return
 
 if (not t) fill(patch(s and 0.55 or 0.4,3),13)

 if(f) fill(patch(0.4,2),12)
 if(not s) fill(patch(h and 0.45 or 0.5,5),f and 10 or (h and 81 or 15))
 
 if(f) fill(patch(0.3,3),11)
 
 for x=1,14 do
  for y=1,14 do
   local t=mget(x,y) 
   if rnd()<0.1 then
    if ((t==9 or t==25) and not h) mset(x+16,y,19)
    if (t==15 or t==31) mset(x+16,y,4)
   end
  end
 end
end

function level:render()
 rectfill(7,7,120,117,0)
 map()
 map(16,0)
end

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
end
-->8
-- entities

gen=entity:extend({
 draw_order=2,
 max_hp=3
})

function gen:init()
 self.sprite={idle=self.tile==7 and {7} or {
 self.tile,self.tile+16,
  self.tile+32,self.tile+16,
  delay=20}}
 self.t=flr(rnd(128))
 self.z=0
 self.invt=0
 self.hp=self.max_hp
 self.ox=0
 self.oy=0
end

function gen:hit(a)
 self.hp-=a
 sfx(4)
 e_add(dmg_fx({
  tx="-"..a,
  c=8,
  c2=2,
  pos=v(self.pos.x+0.25,self.pos.y+0.6)
 }))
 for i=1,10 do
  e_add(hit_fx({
  pos=v(self.pos.x+0.5,self.pos.y+0.5) 
  }))
 end
 if not self.bad then
  
   g_score=max(0,g_score-a*50)
 end
 if self.hp<=0 then
  self:death()
  self:idle()
  for i=1,5 do
   e_add(die_fx({
    pos=v(self.pos.x+0.5,self.pos.y+0.5) 
   }))
  end

  self.done=true
  if not self.bad then
   local t=tomb()
   sfx(28)
   t.pos=v(self.pos.x,self.pos.y)
   e_add(t)
   g_placed-=1
   if (g_placed<=0) sfx(6) fade() g_lost=true g_stop=true
  else
   g_enemies-=1
   g_kills+=1
   g_score+=100
   if g_enemies==0 then 
    fade() sfx(5) g_won=true g_stop=true
    
    if (g_level==1) unlock=unlocks[1]
    if (g_level==2) unlock=unlocks[2]
    if (g_level==4) unlock=unlocks[7]
   
   
    if not unlock or unlock[4] then
     for u in all(unlocks) do
      if(not u[3] and not u[4]) unlock=u break
     end
    end
   
    if (unlock and not unlock[4]) g_unlockstr=unlock[1]    
   end
  end
 end
 shk=6
 self.invt=15
end

function gen:render_hud()
 if self.active then
  local h=self.hp
  local s,c=h.."hp",8
  if(h>1) c=(h>2 and 11 or 9)
  oprint(s,self.pos.x*8-#s*2+4,
   self.pos.y*8-8,c)
 end
end

function gen:render()
 self.invt=max(self.invt-1,0)
 if sx==self.pos.x and sy==self.pos.y and not g_stop then
  if not self.active then 
  self.active=true
  if rnd()>0.92 then
   self:tell(random({
    "^stop touching me!",
    "@_@","^ouch","^stop it"}))
  end
  end
  pal(0,1)
 else
  --if(self.menu) pal(0,1)
  self.active=false  
 end
 
 if self.invt>0 then
  for i=1,15 do
   pal(i,7)
  end
 end
 spr_render(self)
 self.ox=flr(self.pos.x)
 self.oy=flr(self.pos.y)
end

function gen:idle()
 local x,y=flr(self.pos.x),flr(self.pos.y)
 local a=(self.bad and eblocked or cblocked)
 
 if state==ingame and  a[self.ox][self.oy]==self then
  a[self.ox][self.oy]=false
 end
 if(state==pick or self.hp>0) a[x][y]=self
end

magic=entity:extend({
 sprite={idle={118}},
 d=0
})

function magic:idle()
 local f,t=self.pos,self.to
 local dx,dy=t[1]-f.x,t[2]-f.y
 local d=sqrt(dx*dx+dy*dy)
  
 if d<0.1 then
  self.done=true
  g_mdone=true
  g_en=nil
  for i=1,10 do
   e_add(hit_fx({
    pos=v(self.pos.x+0.5,self.pos.y) 
   }))
  end
  
  local e=eblocked[t[1]][t[2]]
  local c=cblocked[t[1]][t[2]]
  if (e)e:hit(1)
  if (c)c:hit(1)
 else
  self.pos.x+=dx/d/5
  self.pos.y+=dy/d/5
 end
end

fx=entity:extend({
 draw_order=5
})

heal_fx=fx:extend({

})

function heal_fx:render()
 self.pos.y-=0.04
 if(self.t>30) pal(8,2)
 spr(87,self.pos.x*8,self.pos.y*8)
 if(self.t>60) self.done=true
end

dmg_fx=fx:extend({

})

function dmg_fx:init()
 self.tx=smallcaps(self.tx)
 self.pos.x-=#self.tx/4
end

function dmg_fx:render_hud()
 self.pos.y-=0.02
 prnt(self.tx,self.pos.x*8,self.pos.y*8,self.t>100 and self.c2 or self.c)
 if(self.t>120) self.done=true
end

hit_fx=fx:extend({

})

function hit_fx:init()
 self.vel=v(rnd(2)-1,rnd(2)-1)/8
end

function hit_fx:render()
 self.vel*=0.9
 circfill(self.pos.x*8,self.pos.y*8,1,7)
 
 if (self.t>20) self.done=true
end

die_fx=fx:extend({

})

function die_fx:init()
 self.pos.x+=rnd(1)-0.5
 self.pos.y+=rnd(1)-0.5
 self.t=rnd(30)
end

function die_fx:render()
 self.pos.y-=0.05
 circfill(self.pos.x*8,self.pos.y*8,4-self.t/20,5)
 
 if (self.t>60) self.done=true
end
-->8
-- char

char=gen:extend({
 tags={"char"},
 dmg_val=1,
 speed=1,
 cost=25
})

function mchk(x,y,w,h)
 return mx>=x and mx<=x+w-1 and
  my>=y and my<=y+h-1
end

function gen:tell(s)
 e_add(dmg_fx({
  tx=s,  
  c=7,
  c2=5,
  pos=v(self.pos.x+0.5,self.pos.y-0.5)
 })) 
end 

names={
[88]="^move",
[89]="^heal",
[86]="^fire"
}

function char:init()
 self.dmg=self.dmg_val
 self.actions={88}
 
 if self.extra then
  for a in all(self.extra) do
   add(self.actions,a)
  end
 end
 
 gen.idle(self)
end

function char:death()
 self:tell(random({"^r^i^p",
  "^i will be back",
  "^you can't lose!",
  "^ouch",
  "^that was too much"}))
end

function random(a)
 return a[flr(rnd(#a))+1]
end

function char:render_hud()
 if (state~=ingame) return
 
 if self.menu then
  g_men=true
  local ar=self.actions
  
  for i=1,#ar do
   local x,y,b=self.pos.x*8
    +i*9-#ar*4-5,
    self.pos.y*8-9+cos(g_time/100+i/#ar)*1.5,
    ar[i]
   
   if mchk(x,y,8,8) then
    
    local st=names[b]
    oprint(st,x+8-#st*2,y-8,7)
    pal(0,1)
    
    if mbp and not g_en_turn then
     g_mdone=false
     if b==88 then
      self.move=true 
      g_move=true
      self.fn=function(self,pts)
       self.moves=pts
      end 
     elseif b==89 then
      if g_turns>0 then
      sfx(7)
      
      for xx=-1,1 do
       for yy=-1,1 do
        if (xx~=0 or y~=0) then
         local c=cblocked[self.pos.x+xx][self.pos.y+yy]
         if c and c~=self then
          c.hp+=1
          e_add(heal_fx({
           pos=v(c.pos.x,c.pos.y)
          }))
         end
        end
       end
      end 
      g_turns-=1
      else
       shk=10
       sfx(16)
       self:tell("^not enough turns")
      end
      self.menu=false
     elseif b==86 then
      sfx(8)
      self.move=true
      self.fn=function(self,pts)
       e_add(magic({
        to=pts[#pts],
        pos=v(self.pos.x,self.pos.y)
       }))
      end 
     end
    end
   end 
   
   spr(b,x,y) 
   pal(0,0)
  end
 else
  gen.render_hud(self) 
  if self.t%600==0 and rnd()>0.6 then
   self:tell(random({
    "^zzz","^come on!",
    "^let's finish this game",
    "^you are so slow",
    "^lets go!",
    "^click me",
    "^i want to move",
    "^gota go faaaast"
   }))
  end
 end

 local s=self.s
 if s then
  oprint(s,self.pos.x*8-#s*2+4,
  self.pos.y*8+(self.dy<0 and -7 or 8),self.f and 8 or 11)
  self.s=nil
 end
 if(mbp) self.menu=self.active
 if self.active and mbp and rnd()>0.8 then
  self:tell(random({
   "^get back into your world!",
   "^stop touching me!","@_@",
   "-1000","move your mouse away",
   "^that hurts","^ouch","^stop it"}))
 end
end

function block(x,y,f)
 if(f) local v=cblocked[x][y]  return v~=false and not v.done
 local v=eblocked[x][y]
 return v~=false and not v.done
end

function char:render()
 self.pts={}
 local x,y=self.pos.x,self.pos.y
 if self.move then
  local dx,dy,mx,my,b=abs(x-sx),abs(y-sy),x<sx and 1 or -1,y<sy and 1 or -1
  local err,pts=dx-dy,{}
  local first=true
  
  while true do
  	if(not first and (block(x,y,true) or fget(mget(x,y),0))) b=true break
 
  	first=false 
  	if x==sx and y==sy then
    self.att=block(x,y)
  	 break
  	end
  	
   if(block(x,y)) b=true break
  	
  	e2=err*2
  	add(pts,{x,y})
  	if (e2>-dx) err-=dy x+=mx
  	if(e2<dx) err+=dx y+=my
  end
  add(pts,{x,y})
  local x,y=self.pos.x,self.pos.y
 
  local d=max(1,flr(sqrt(dx*dx+dy*dy)*self.speed))
  self.f=d>g_turns or b
  r_reset()
  for i=2,#pts do
   local p,op=pts[i],pts[i-1]
   local dx,dy=op[1]-p[1],op[2]-p[2]
   local a=atan2(dx,dy)
   oline(p[1]*8+4,p[2]*8+4,op[1]*8+4,op[2]*8+4,0)
   line(p[1]*8+4,p[2]*8+4,
   op[1]*8+4,op[2]*8+4,self.f and 8 or 3)
  end
 
  if (not self.f) pal(8,3) pal(2,1)
  for i=1,#pts do
   local p=pts[i]
   spr(102,p[1]*8,p[2]*8)
  end
  r_reset()
  gen.render(self)
  if(d==0) return
  r_reset()
  self.s=(self.f and 
  (b and "blocked" or "too far") or
  d.." ^turn"..s(d))
  self.dy=y-sy
  if mbp then
    self.move=false
   if not self.f then
    self.last=pts[#pts-1]
    g_turns-=d
    self.fn(self,pts)
   else
       shk=10
       sfx(16)
       self:tell("^not enough turns")
      
   end
  end
 else
  gen.render(self)
 end
 
 if self.moves then
  g_mdone=false
  local m=self.moves[1]
  local dx,dy=m[1]-x,m[2]-y
  local d=sqrt(dx*dx+dy*dy)
  if d>0.1 then
   d*=10
   self.pos.x+=dx/d*2
   self.pos.y+=dy/d*2
   self.z=-abs(cos(self.t/40))*4
  else
   self.pos.x,self.pos.y=m[1],m[2]
   del(self.moves,m)
   if #self.moves==0 then
    if self.att and self.last then
     add(self.moves,self.last)
     self.last=nil
     self.att=false
     local e=eblocked[self.pos.x]
      [self.pos.y]
     if e then
      e:hit(self.dmg_val)
      if e.hp<=0 then
       self:tell(random({
       "^e^z","^g^g",
       "^r^i^p","^too easy for me",
       "^know your place"}))
      end
     end
    else 
     g_mdone=true
     if(not g_movedone) g_mtime=g_time g_movedone=true
     self.moves=nil self.z=0  
    end
  else
   
   sfx(14)
   end 
  end
 end
end

tomb=entity:extend({
 sprite={idle={22}}
})

warrior=char:extend({
 tile=32,
 max_hp=4,
 dmg_val=2,
 cost=0,
 name="^warrior"
})

mage=char:extend({
 tile=34,
 extra={86},
 speed=0.5,
 cost=10,
 name="^mage"
})

thief=char:extend({
 tile=35,
 cost=40,
 speed=0.3,
 name="^thief"
})

healer=char:extend({
 tile=38,
 max_hp=1,
 extra={89},
 cost=50,
 name="^healer"
})
-->8
enemy=gen:extend({
 tags={"enemy"},
 bad=true,
 dmg_val=1,
 speed=1	
})

function enemy:init()
 self.dmg=self.dmg_val
 g_enemies+=1
end

function enemy:getcloser()
 local t=self.tar.pos
 getpath(self.pos.x,self.pos.y,t.x,t.y)
 if #path>0 then
  self.last={self.pos.x,self.pos.y}
  self.m=path[#path]
 else
  g_en=nil
 end
end

function enemy:turn()
 local m=32000
 for c in all(entities_tagged["char"]) do
  local dx,dy=c.pos.x-self.pos.x,c.pos.y-self.pos.y
  local d=sqrt(dx*dx+dy*dy)
  if d<m then
   m,self.tar=d,c
  end
 end
 self.d=m
 self:default()
end

function enemy:default()
 self:getcloser()
end

function enemy:idle()
 if self.m then
  local x,y=self.pos.x,self.pos.y
  local m=self.m
  local dx,dy=m[1]-x,m[2]-y
  local d=sqrt(dx*dx+dy*dy)
  if d>0.1 then
   d*=10
   self.pos.x+=dx/d
   self.pos.y+=dy/d
   self.z=-abs(cos(self.t/40))*4
  else
   sfx(14)
   self.pos.x,self.pos.y=m[1],m[2]
   local t=self.tar.pos
   self.turns-=1
   if (m[1]==t.x and m[2]==t.y) and not self.at then
    self.at=true
    self.m=self.last
    self.tar:hit(self.dmg)
    self.turns=0
   else
    if self.turns<=0 then
     self.at=false
     g_en=nil
     self.m=nil
     self.z=0
    else
     self:turn()
    end 
   end
  end
 end
 gen.idle(self)
end

slime=enemy:extend({
 tile=39,
 max_hp=1
})

bat=enemy:extend({
 tile=42,
 max_hp=2
})

knight=enemy:extend({
 tile=43,
 max_hp=5,
 dmg_val=2
})

skele=enemy:extend({
 tile=44,
 speed=2
})

archer=enemy:extend({
 tile=37
})

function archer:default()
 if(self.d>3) g_en=nil return
 local t=self.tar.pos
 e_add(magic({
  to={t.x,t.y},
  pos=v(self.pos.x,self.pos.y)
 }))
end

dark_mage=enemy:extend({
 tile=45,
 max_hp=1
})

small_slime=enemy:extend({
 tile=40,
 speed=2,
 max_hp=1
})

function small_slime:default()
 if (not self.dn) self.dn=true g_en=nil return
 self:getcloser() 
end

local drs={{-1,0},{1,0},{0,1},{0,-1}}
function dark_mage:default()
 if self.d<3 then
  self:spawn()
  self:tp()
 end
 
 g_en=nil
end

function enemy:tp()
 
  repeat
   x=flr(rnd(14))+1
   y=flr(rnd(14))+1
  until good(x,y)
  for i=1,10 do
     e_add(hit_fx({
     pos=v(self.pos.x+0.5,self.pos.y+0.5) 
     }))
    end
  self.pos.x,self.pos.y=x,y
  for i=1,10 do
     e_add(hit_fx({
     pos=v(self.pos.x+0.5,self.pos.y+0.5) 
     }))
    end
end

boss=enemy:extend({
 max_hp=10,
 tile=46,
 dmg_val=3,
 speed=2
})

function boss:default()
 if rnd()>0.75 and self.d>6 then
  self:spawn(1)
 else
  self:getcloser()
 end
end

function enemy:spawn(a)
 local x,y
 local i=1
  for d in all(drs) do
   local xx,yy=self.pos.x+d[1],self.pos.y+d[2]
   if good(xx,yy) then
    e_add(small_slime({
     pos=v(xx,yy)
    }))
    for i=1,10 do
     e_add(hit_fx({
     pos=v(xx+0.5,yy+0.5) 
     }))
    end
    if(a and i>=a) g_en=nil return
    i+=1
   end
  
  end
 g_en=nil
end

chest=enemy:extend({
 tile=7,
 max_hp=1
})

mimic=enemy:extend({
 max_hp=5,
 tile=7,
 dmg_val=2
})

function mimic:init()
 g_enemies-=1
end

function mimic:hit(a)
 gen.hit(self,a)
 if (self.found) return
 self.found=true
 g_enemies+=1
 self.sprite.idle={41,57,delay=30}
end

function mimic:render_hud()
 if(self.found) gen.render_hud(self)
end

function mimic:default()
 if not self.found then
  g_en=nil 
 else 
  self:getcloser()
 end
end

function chest:init()
 g_enemies-=1
end

function chest:default()
 g_en=nil
end

function gen:death()
 
end

function chest:death()
 local a=(5+flr(rnd(30)))
 g_enemies+=1
 g_coins+=a
 g_score+=1000
 dset(17,g_coins)
 e_add(dmg_fx({
  tx="+"..a.." coins",
  c=10,
  c2=9,
  pos=v(self.pos.x+0.25,self.pos.y-1.5)
 }))
end

function chest:render_hud()
 
end

imp=enemy:extend({
 tile=67,
 max_hp=6,
 dmg_val=3,
 speed=3
})

function imp:default()
 if self.d>5 then
  self:tp()
  g_en=nil
 else
  self:getcloser()
 end
end

red_slime=enemy:extend({
 speed=2,
 dmg_val=2,
 hp_val=3,
 tile=68
})

boss2=enemy:extend({
 max_hp=20,
 speed=3,
 dmg_val=2,
 tile=69
})

function boss2:default()
 if self.d>6 then
  if rnd()>0.5 then
   self:spawn()
  else
   local t=self.tar.pos
  e_add(magic({
   to={t.x,t.y},
   pos=v(self.pos.x,self.pos.y)
  }))
  end
 else
  self:getcloser()
 end
end

classes={
 {slime,bat},
 {archer,skele},
 {knight,dark_mage},
 {boss},
 {imp,red_slime},
 {boss2}
}
-->8
-- path finding
-- https://www.lexaloffle.com/bbs/?tid=2570
dirs={{1,0},{0,1},{-1,0},{0,-1},
 {1,1},{-1,-1},{1,-1},{-1,1}}

function good(x,y)
 return not fget(mget(x,y),0) and not block(x,y) and not block(x,y,true)
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

function mouse()
 lmb=mb
 mx,my,mb=stat(32),stat(33),stat(34)
 mbp=(lmb~=1 and mb==1)
 if(mbp) sfx(3)
 sx,sy=mid(1,14,flr(mx/8)),
  mid(1,14,flr(my/8))
 
 e_update_all()
 do_movement()
end

pick={}

function pick.update()
 if not clss then
  pmusic(0)
  clss={warrior} 
  if(chkd(2)) add(clss,mage)
  if(chkd(3)) add(clss,thief)
  if(chkd(4)) add(clss,healer)
  g_placed=0
  for c in all(clss) do
   c.menu=false
  end
 end
 mouse()
end

local clrs={0,14,8,0}

function pick.draw()
 shake(-16)
 sy-=2
 r_render_all("render")
 r_render_all("render_hud")
 local s=cos(g_time/150)*3.5
  
 if g_tut and g_placed==0 then
  if g_men then
   coprint("^click on a free tile",86+s,7)
   coprint("to place him",96+s,7)
  else
   coprint("^select your troops",86+s,7)
   coprint("and place it on the map",96+s,7)
  end
 elseif g_placed==0 then
  coprint("^press — for a tutorial",96+s,6) 
  if(btnp(—)) fade() g_tut=true
 end
 
 for i=1,4 do
  line(-8,33+i,135,33+i,clrs[i])
 end
 
 g_men=false
 sy+=2
 camera()
 local s=#clss
 for i=1,s do
  local y=cos(g_time/100+i/s)*1.5+8
  local c,a=clss[i],
   mchk(i*8,y,8,8)
  c.active=a 
  if a then 
   if not c.menu then
    local x=#clss*8+17
    local st=c.name
    local v=c.cost
    oprint(st,x,4,7)
    oprint(v==0 and "free" or v,x+#st*4,4,10)
    oprint(c.max_hp.."‡ "..(c.dmg_val).."’",x,14,14)
   end
   pal(0,1)
   if mbp then
    if g_coins>=c.cost then
    for n in all(clss) do if n~=c then n.menu=false end end
    c.menu=not c.menu
    sfx(c.menu and 15 or 16)
    else
     sfx(16)
     shk=10
    end
   end
  end
  
  
  if c.menu then 
   g_men=true
   local x,y=sx*8,mid(3,5,sy)*8
   local g=good(x/8,y/8-2)
   if  mbp then
    if mchk(x,y,8,8) and g then
    del(clss,c)
    e_add(c({
     menu=false,
     pos=v(x/8,y/8-2)
    }))
    shk=10
    g_placed+=1
    g_coins-=c.cost
    dset(17,g_coins)
    sfx(9)
    return
    elseif sy>1 then
     sfx(16)
    end
   end
   
   spr(c.tile,x,y)
   if (not g) spr(1,x,y)
  end
  
  spr(c.menu and 47 or c.tile,i*8,y)
 
  pal(0,0)
 end
 
  local a=g_coins..""
  prnt(a,113-#a*4,8,10)
  spr(20,114,8)
  
 if g_placed>0 then
  local a=mchk(32,84,64,24)
  if a then
   if mbp then
    sfx(11)
    
    fade()
    state=ingame clss=nil shk=7
    local ar=classes[g_level]
    local mbs={}
    for i=1,((g_level==4 or g_level==6) and 1*(g_mod+1) or g_placed*2+g_mod*4*g_placed+flr(g_level/2)) do
     mbs[i]=ar[flr(rnd(
      #ar))+1]
    end
    for i=1,g_placed do
     add(mbs,rnd()>0.7 and mimic or chest)
    end
    for i=1,#mbs do
     local x,y
     repeat
      x,y=flr(rnd(13))+1,
       flr(rnd(6))+7
     until not fget(mget(x,y),0) and not block(x,y) and not block(x,y,true)
     eblocked[x][y]=e_add(mbs[i]({pos=v(x,y)}))
    end
   end
  end
  coprint("’’’’’     ",84+s,10)
  coprint("^start!",94+s,a and 12 or 11)
  coprint("’’’’’     ",104+s,10)
 end
end

ingame={}

function ingame.update()
 mouse()
 g_en_turn=(g_turns==0 and g_mdone)
 
 if g_en_turn and not g_en then
  local a=entities_tagged["enemy"]
  if(g_curr_en==#a) then
   e_add(dmg_fx({
    tx="^next turn",
    c=11,
    c2=3,
    pos=v(48+24,110)/8
   }))
   g_curr_en=0 g_en_turn=false g_turns=3 return
  end
  g_curr_en+=1
  g_en=a[g_curr_en]
  if g_en and not g_stop then
   g_en.turns=g_en.speed
   g_en:turn()
  else
   g_en=nil
   g_curr_en=0 g_en_turn=false g_turns=3 return
  end
 end
end

function ingame.draw()
 shake()
 r_render_all("render")
 r_render_all("render_hud")
 r_reset()
 
 local sm=cos(g_time/200)*3.5-8
 
 if g_tut then
  if g_movedone then
   coprint("^g^g! ^now you know the basics",86+sm,7)
   coprint("^good luck!",96+sm,7)
 
   if g_time-g_mtime>180 then
    g_tut=false
    dset(20,1)
   end
  elseif g_move then
   coprint("^you can move onto an enemy",86+sm,7)
   coprint("to hit it",96+sm,8)
  elseif g_men then
   coprint("^each action costs turns",86+sm,7)
   coprint("^try to move any troop",96+sm,7)
  else
   coprint("^click on any troop to",86+sm,7)
   coprint("select his action",96+sm,7)
  end
 end
 g_men=false
 
 if not g_stop then
  oprint(pad(g_score).." ’",8,120,10) 
  oprint(g_turns.." turn"..s(g_turns).." left",48,120,7)
  local p=mchk(106,120,32,32)
  oprint("^skip",105,120,p and 8 or 9)
  if (p and mbp) sfx(13) g_turns=0 g_mdone=true g_en_turn=true
 end
 
 --[[for x=0,15 do
  for y=0,15 do
   eblocked[x][y]=false
   cblocked[x][y]=false
  end
 end]]

 if g_lost then
  coprint("ŒŒŒŒŒ     ",32+sm,5)
  coprint("‰ ^you lost ‰  ",42+sm,7)
  coprint("ŒŒŒŒŒ     ",52+sm,5)
  coprint(pad(g_score).." points",72+sm,9)
  coprint(g_kills.." enemies killed",82+sm,6)
  local c=(mchk(32,102,64,8) and 10 or (g_time/30%2>1 and 7 or 11)) 
  if c==10 and mbp then
   sfx(12)
   fade()
   _init()
  end
  coprint("^try again?",102,c)
 elseif g_won then
  coprint("’’’’’     ",32+sm,10)
  coprint("‰ ^you won! ‰  ",42+sm,7)
  coprint("’’’’’     ",52+sm,10)
  coprint(pad(g_score).." points",72+sm,9)
  coprint(g_kills.." enemies killed",82+sm,6)
  if(g_unlockstr) coprint(g_unlockstr,92+sm,12)
  
  local c=(mchk(32,102,64,8) and 10 or (g_time/30%2>1 and 7 or 11)) 
  if c==10 and mbp then
   if(unlock) unlock[2]()
   
   sfx(12)
   if g_level==6 then
    g_level=1
    g_mod+=1
    state=pick
    restart_level()
   elseif not worlds[g_level+1]  then
    _init()
    state=pick
   else
    
    state=pick
    g_level+=1
    restart_level()
   end
   fade()
  end
  coprint("^continue",102,c)
 end
end

function pad(s)
 s=s..""
 while #s<6 do
  s="0"..s
 end
 return s
end

menu={}

function menu.update()
 mouse()
end

p={0,0,1,2,4,9,10,9,4,2,1,0,0}
 
function menu.draw() 
 for i=0,400 do
  local x=64-rnd(128)
  local y=64-rnd(128)
  
  circfill(x+64,y+64,1,
   p[1+flr(16*atan2(x,y)-
   sqrt(x*x+y*y)/1.5-g_time/10)%#p])
 end
 if (g_time<30) return
 if (g_time>=30 and not g_sfxd) g_sfxd=true sfx(1)
 if (g_time>=60 and not g_musd) g_musd=true music(9) 
 shake()
  
 r_reset()
 
 for i=0,16 do
  spr(32+i%7+flr((g_time/30+i*0.3)%2)*16,(i*8+g_time/2)%136-8,16+cos(g_time/100+i/4)*3.5)
  spr(32+i%7+flr((-g_time/30+i*0.3)%2)*16,(i*8-g_time/2)%136-8,76+cos(g_time/100+i/4)*3.5)
 end
 oprint("^super",3,28,6)
 oprint("v0.6",3,65,9)
 oprint("^by @egordorichev",63,65,7)
 sspr(0,96,128,32,0,32)
 local y=cos(g_time/150)*3.5+104
 local c=6+g_time/30%2
 coprint("’’’’    ",y-10,10)
 coprint("^press — to start!",y,c)
 coprint("’’’’    ",y+10,10)
 
 local m=mchk(96,31,8,8)
 ospr(g_music and 107 or 91,96,m and (mb~=0 and 33 or 32) or 31)
 if (mbp and m) g_music=not g_music dset(32,g_music and 0 or 1) omusic(g_music and 9 or -1)
  m=mchk(106,31,8,8)
 ospr(g_sfx and 108 or 92,106,m and (mb~=0 and 33 or 32) or 31)
 if (mbp and m) g_sfx=not g_sfx dset(33,g_sfx and 0 or 1)
 
 spr(39+flr(g_time/15)%3*16,10,110)
 spr(44+flr(g_time/15)%3*16,110,110)
 
 if btnp(—) then
  state=pick
  sfx(2)
  
  fade()
  shk=10
 end
end

function ospr(s,x,y)
 for i=1,15 do pal(i,0) end
 spr(s,x-1,y)
 spr(s,x+1,y)
 spr(s,x,y-1)
 spr(s,x,y+1)
 r_reset()
 spr(s,x,y)
end

clrp={7,6,5,1,0}
function fade()
 for i=1,#clrp do
  cls(clrp[i])
  flip()
 end
end

function shake(n)
 if shk>0 then
  shk-=1
  local v=shk/2
  camera(rnd(shk)-v,rnd(shk)-v+(n or 0))
 else
  camera(0,n)
 end
end
__gfx__
00000000eee00eee00000000aab00babeee00eee0000000000000000eeeeeeee4242442294949944abaababbd1d1dd1177a7a77a66565665000000007c7c77cc
00000000e008800e24244222ab0bb0b3ee06d0ee0000000000000000ee0000ee4222222194444442abbbbbb3d11111107aaaaaa965555551100000007ccccccd
00700700e08ee80e42222221b07b310be061d10e0000000000000000e0a4420e2222222244444444bbbbbbb311111110aaaaaaa95555555121000000cccccccd
0007700008e8ee804222222107b3b31006ddd01000000000000000000f4444204222222194444442abbbbbbbd11111117aaaaaaa65555555310000007ccccccc
0007700008ee8e80212121120b393110061d6d100000000000000000052762102222222144444442abbbbbb3111111107aaaaaa95555555140000000cccccccd
00700700e08ee80eeeeeeeeeb0b42103e067610e0000000000000000094444104222222294444444bbbbbbbbd1111111aaaaaaaa65555555510000007ccccccc
00000000e008800eeeeeeeeeab0420b3ee0760ee0000000000000000094444102222222144444442abbbbbb3d11111107aaaaaa955555551610000007ccccccd
00000000eee00eeeeeeeeeeeb302103beeeeeeee0000000000000000eeeeeeee2112121142242422b3b33b3310100100a99a9a94515115117d000000cdcddcdd
e0eeeeeee77ee77e00000000eeeeeeeeeee00eeeeee00eeeeee0eeee000000004242442294949944abaababbd1d1dd1177a7a77a66565665820000007c7c77cc
060eeeee76eeee6700000000eeeeeeeeee0790eeee0760eeee060eee000000004222222194444442abbbbbb3d11111107a9aaaa965555551940000007ccccccd
0760eeee7eeeeee700000000eeeeeeeee079a90ee077760ee06d10ee000000002222212244442444bbb3bbb311111110aa7a9aa955155551a9000000cccdcccd
07760eeeeeeeeeee00000000e0e0ee0ee0a9a90e07676760ee060eee000000004222242194424942ab3babbbd11111117aaa7aaa65655555b30000007cdc7ccc
077760eeeeeeeeee000000000b0b00b0e0a9a90e07777760ee060eee000000002212222144449442abbabbb3111111107a9aaa9955555151c1000000ccc7cccd
07700eee7eeeeee70000000003b0b030ee0a90ee07676760e093b0ee000000004242222294444444bbbbbbbbd1111111aa7a9a7a65555655d00000007ccccccc
e0060eee76eeee6700000000e03bb30eeee00eee077677600944430e000000002222222144444442abbbbbb3d11111107aaa7aa955555551e20000007ccccccd
eeeeeeeee77ee77e00000000eeeeeeeeeeeeeeee07777760eeeeeeee000000002112121142242422b3b33b3310100100a99a9a9451511511f0000000cdcddcdd
eee00eeeee0000eeee0000eeeee00eeeee000eeeeee00eeeeee00eeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeee000eeeeee00eeeee0000eeeee0000eeee00eee
ee07d0eee0d1150ee0a8820eee07f0eee08940eeee0420eeee0440eeeeeeeeeeeeeeeeeee0a4420eeeeeeeeee08940eee00760eee0d1150eee0d5110ee0550ee
ee06f0eeee0420eeee04f0eeee0ff0eeee08f00eee0230eeee04f0eeee0000eeeeeeeeee06555510e00ee00eee08f00e0606500eee0420eee07cd510ee0550ee
e076d50ee07d150ee07a820ee0ab350ee0fa9820e06d150ee0a7860ee033330eeee00eee0127821001d00510e0fa9820e0777650e07d150ee0d55110e055550e
e06d510ee0d1500ee0a8210ee0b3510ee0a94820e0d1520ee078820e0377bb30ee0710ee00882000e01d510ee0a94820e006500ee0d1500ee0d51810e055550e
e0f42f0ee021520ee0f82f0ee0f31f0ee0f42780e0b1530ee0f72f0e03bbbb10e07dd10e09824410ee0550eee0f42780077770eee021520ee000000ee0f55f0e
e060010ee0d0050ee0a0010ee0b0010ee0a0040ee0d0020ee070050ee033310ee011110e09444410eee00eeee0a0040ee000050ee0d0050e07565610e050050e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000eeeeeeeee
eeeeeeeeee000eeeeee000eeeee00eeeeee00eeeeee00eeeeee00eeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeee00eeeeee00eeeee000eeeee0000eeeeeeeeee
eee00eeee0d110eeee08820eee07f0eeee0940eeee0420eeee0440eeeee00eeeeeeeeeeee0a4420ee00ee00eee0940eeee0760eee0d110eee0d5110eeee00eee
ee0760eeee01550ee0a820eeee0ff0eee088f00eee0230eeee04f0eeee0330eeeee00eee0655551001d00510e088f00eee0650eeee01550e07cd510eee0550ee
e076f50eee0420eeee04f0eee0ab350ee0fa9820e06d150ee0a7860ee037b30eee0710ee01272110011d5110e0fa9820e077760eee0420ee0d55110ee055550e
e06d510ee061500ee0a8210ee0b3510ee0a94820e0d1520ee078820e037bbb30e07dd10e00082000e005500ee0a9482006065050e061500e0d51b10ee055550e
0f6421f0e021520ee0f82f0e0fb311f00fa427800bd152300f7722f003bbbb10e01dd10e09482410eee00eee0fa42780e007700ee021520ee000000e0f5555f0
e060010ee0d0050ee0a0010ee0b0010ee0a0040ee0d0020ee070050ee033310eee0110ee09444410eeeeeeeee0a0040ee070050ee0d0050e07565610e050050e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000eeeeeeeee
eeeeeeee00000000eee00eeeeeeeeeee00000000eeeeeeeeeeeeeeeeeee00eeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeee00eeeeee00eee00000000eee00eee
eee00eee00000000ee0880eeeee00eee00000000eee00eeeeee00eeeee0330eeeee00eeee0a4420eee0ee0eeee000eeeee07600eee0110ee00000000ee0550ee
ee0760ee00000000e0a8820eee07f0ee00000000ee0420eeee0440eee037b30eee0170ee06555510e0d0050ee089400ee0065050e0d1150e00000000ee0550ee
e076f50e00000000ee04f0eee0aff50e00000000e062350ee0a4f60ee07bb30eee07d0ee01272110011d5110e008f8200677760eee0420ee00000000e055550e
e06d510e00000000e0a8210ee0b3510e00000000e0d1520ee078820ee03bb30eee01d0ee0008820001055010e0a94820e006500ee061500e00000000e055550e
0f6421f0000000000fa821f00fb311f0000000000bd152300f7725f0e03bb10eee01d0ee09448810e0e00e0e0fa42780ee07765002d1502000000000e0f55f0e
e060010e00000000e0a0010ee0b0010e00000000e0d0020ee070050eee0310eeee0110ee09444410eeeeeeeee0a0040ee070000ee0d0050e00000000e050050e
eeeeeeee00000000eeeeeeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeee
000000007878778800000000ee0ee0eeeeeeeeeee00ee00eeeeee00eee0eeeeeeeee0eeeeee00eee000000008ee77eee8eeeeeee0000000000000000eeeeeeee
000000007888888200000000e050050eeeeeeeee0b100b10eeee0780e080e0eeeee070eeee0780ee0000000028e777ee28e77e7e0000000000000000eee00eee
000000008888888800000000e068260eee0000ee07b33510eee008800888080ee000bb0ee008800e00000000e287ddeee2877ee70000000000000000ee0550ee
000000007888888200000000ee0210eee088880e0b0b1010ee09400ee080888007bbbbb00788888000000000ee28eeee7728dee70000000000000000e055550e
000000008888888200000000e087820e087722800bb33110e09420eeee0e080e0bbbbb300888822000000000e7728eee77728ee70000000000000000e0f55f0e
000000007888888800000000ee0820ee08222280e0bb110e09420eeeeeeee0eee000b30ee008200e00000000777728eed77728e70000000000000000e055550e
000000008888888200000000e080020ee088880ee0b0010e0420eeeeeeeeeeeeeee030eeee0820ee00000000d77de28eedd7728d0000000000000000e050050e
000000008228282200000000eeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeee0eeeeee00eee00000000eddeee2eeeedde2e0000000000000000eeeeeeee
000000007878778800000000e0eeee0eeeeeeeeee00ee00eeeeeeeee00000000000000000000000000000000eee77eeeeeeeeeee0000000000000000eeeeeeee
00000000788888820000000005000050eee00eee09200920eee00eee00000000000000000000000000000000eee777eeeee77e7e0000000000000000eee00eee
000000008828888800000000e068260eee0880ee07988520ee0780ee00000000000000000000000000000000eee7ddeee7777ee70000000000000000ee0550ee
000000007878888200000000ee0210eee087280e09092020e078820e00000000000000000000000000000000eee7eeee7777dee70000000000000000e055550e
000000008888828200000000e087820e0872228009988220e088820e00000000000000000000000000000000e777eeee7777eee700000000000000000f5555f0
000000007888878800000000ee0820ee08222280e099220eee0220ee000000000000000000000000000000007777eeeed7777ee70000000000000000e055550e
000000008888888200000000e080020ee088880ee090020eeee00eee00000000000000000000000000000000d77deeeeedd77e7d0000000000000000e050050e
000000008228282200000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000eddeeeeeeeeddede0000000000000000eeeeeeee
000000000000000000000000e0eeee0eeee00eee00000000eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000005000050ee0880ee00000000eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000e068260ee087280e00000000eee00eee000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ee0210eee072280e00000000ee07a0ee000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ee0780eee082280e00000000ee0a90ee000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000e088220ee082280e00000000eee00eee000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000e080020eee0880ee00000000eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000eeeeeeeeeeeeeeee00000000eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e00000eeeeeeeee0000000000000ee0000000000000ee0000000000000eeeeeeeee0000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0077700eeeeeee007777777777700007777777777700007777777777700eeeeeee0077777777777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0777770eeeeeee077777777777770077777777777770077777777777770eeeeeee07777777777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0777770eeeeeee077777777777770077777777777770077777777777770eeeeeee077777777777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0777770eeeeeee077777777777770077777777777770077777777777770eeeeeee077777777777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0777770eeeeeee077777ddd777770077777ddd7777700d77777777777d0eeeeeee0777777777777777770e00000000000ee0000000000000ee0000000000000e
0777770eeeeeee07777d000d7777007777d000d7777000dd7777777dd00eeeeeee0777777ddddd77777700077777777700007777777777700007777777777700
0777770eeeeeee0777700e00777700777700e0077770e000d77777d000eeeeeeee077777d00000d7777700777777777770077777777777770077777777777770
0777770eeeeeee077770eee077770077770eee077770eee007777700eeeeeeeeee07777700eee007777700777777777770077777777777770077777777777770
0777770eeeeeee077770eee077770077770eee077770eeee0777770eeeeeeeeeee07777700eee007777700777777777770077777777777770077777777777770
0777770eeeeeee077770eee077770077770eee077770eeee0777770eeeeeeeeeee07777770000077777d007777777777700777777777777700777777777777d0
0777770eeeeeee077770eee077770077770eee077770eeee0777770eeeeeeeeeee077777777777777dd0007777777777d0077777dddd777700777777dddddd00
0777770eeeeeee077770eee077770077770eee077770eeee0777770eeeeeeeeeee07777777777777700000777777dddd00077777000077770077777d0000000e
0777770eeeeeee077770eee077770077770eee077770eeee0777770eeeeeeeeeee0777777777777770000077777d00000e0777770ee07777007777770000000e
0777770eeeeeee077770eee077770077770eee077770eeee0777770eeeeeeeeeee077777777777777770007777700eeeee0777770ee077770077777777777700
0777770eeeeeee077770eee077770077770eee077770eeee0777770eeeeeeeeeee0777777ddddd77777700777770eeeeee0777770ee077770077777777777770
0777770eeeeeee077770eee077770077770eee077770eeee0777770eeeeeeeeeee077777d00000d7777700777770eeeeee0777770ee077770077777777777770
0777770eeeeeee077770eee077770077770eee077770eeee0777770eeeeeeeeeee07777700eee007777700777770eeeeee0777770ee0777700d7777777777770
0777770eeeeeee0777700e00777700777700e0077770eeee0777770eeeeeeeeeee07777700eee007777700777770eeeeee0777770ee07777000ddddddd777770
0777770000000e077777000777770077777000777770eeee0777770eeeeeeeeeee07777770000077777700777770eeeeee0777770ee077770e00000000d77770
07777777777700077777777777770077777777777770eeee0777770eeeeeeeeeee07777777777777777700777770eeeeee077777000077770e00000000777770
07777777777770077777777777770077777777777770eeee0777770eeeeeeeeeee07777777777777777700777770eeeeee077777777777770007777777777770
07777777777770077777777777770077777777777770eeee0777770eeeeeeeeeee07777777777777777700777770eeeeee077777777777770077777777777770
07777777777770077777777777770077777777777770eeee0777770eeeeeeeeeee07777777777777777700777770eeeeee077777777777770077777777777770
0d7777777777d00d77777777777d00d77777777777d0eeee0d777d0eeeeeeeeeee0d777777777777777d00d777d0eeeeee0d77777777777d00d77777777777d0
00dddddddddd0000ddddddddddd0000ddddddddddd00eeee00ddd00eeeeeeeeeee00ddddddddddddddd0000ddd00eeeeee00ddddddddddd0000ddddddddddd00
e000000000000ee0000000000000ee0000000000000eeeeee00000eeeeeeeeeeeee00000000000000000ee00000eeeeeeee0000000000000ee0000000000000e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__gff__
0100010100000000000002030202000000000000000000000000020302020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
01050000183521a3521c3522435219302213021530210302003020030200302003020030200302003020030200302003020030200302003020030200302003020030200302003020030200302003020030200302
01150000103530c213003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303
011000001f355223051d3552235227352183511f35511305163050530500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305
010b00001d11500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
011000001035300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303
0110000022255032051b355222510735127255223512925513355162552430105205033053020533305052051b30522205243050520513305222051b305162051f20503305052050020500205002050020500205
011000001f3551b3051b2550f352162520a355132550f352072550535207255033550000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
011000001b35413154223540000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
00100000000001f250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011700002425300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
011000001d3520f35218351073540c35322352163510a3531b3520c35316351133521d354163541135324352163520a3512235424353273520a3510c3521b3520c35416351053530f352133541b3521635424352
011000001b3551f355163551d355243551b3550000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0110000011255162551f25513255222550f2551825500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205
01070000224501f450134500f4500c400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
011100001622316205002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
001000001f35500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
01100000133550c355000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
01180020163521b455113520f455133520f4551635211455183551b4551635211455163520f4550c3550f45216355184521b355184551635213452113550f4550c35513452183551645213355164551b35218455
011800001305516005000051b0551d00500005110550f005000051b05518005000052205524005000050c0550f005000051805516005000051305511005000050c0550c0050f005110050f0050c0050a0050a005
011000200a0750a0650a0550a0450a0350a0150000500005000050000500005000050000500005000050000505075050650505505045050350501500005000050000500005000050000500005000050000500005
001000000c0750c0650c0550c0450c0350c01500005000050000500005000051607516065160551604516035160150f0750f0550f0450a0750a0550a045030750305503045000050000500005000050000500005
011000000f0750f0650f0550f0450f0350f0150707507065070550704507025070150700500005000051607516065160551604516025160150c0750c0650c0550c0450c0250c0150000505075050550502505015
00100000180751806518055180451802518015000050000500005000050000500005000050000507075070650705507045070250701500005000050000500005000050c0750c0650c0550c0450c0250c0150c005
0110000016075160651605516045160251601516075160651605516045160251601500005000050c0750c0650c0550c0450c0250c0150c0750c0650c0550c0450c0250c01500005000050a0750a0350f0750f035
001000000f0750a0550a0450a0350a025110750c0550c0450c0350c0250f07507055070450703507025130750f0550f0450f0350f025000050000503072030520305203025000050a0720a0520a0520a02500005
011000000c0720c0520c0520c0250000000000000000000000000000000c0750a06507055050450302500000000000000000000070750a0650c0550f0351101500000000000c0750c0650c0550c0350c0250c015
00180000001051f13516115001051d1350f11500105221351b115001051f1350c1150010500105001051d1350f115001051b1351111500105001051d13516115001051d1350f1251812511105221151b11500105
011800031312511125161250010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
001000001b350133500f3500a35000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
011400001055210552125521255213552135521555215552125521255212552125521355213552155521555215552155511755117552175521755217552175521755217552175521755215552155521255212552
011400001355213552155521555212552125521055210552105521055212552105520e5520e5520e5510e55110552105521255212552135521355215552155521255212552125521255213552135521555215552
011400001555215552175521755217552175521755217552175521755217552175511555115552125521255213552135521555215552125521255210552105520e5520e551105511055210552105521055210552
011400001755217552175521755215552155521255212552135521355215552155521255212552105520e55210552105511255112552125521255212552125521755217552175521755215552155521255212552
0114000013552135521555215552125521255210552105520e5520e55112551125521255212552125521255210552105521255212551135511355215552155521255212552125521255213552135521555215552
011400001555215552175521755217552175521755217555175521755217552175521555215552125521255213552135521555215552125521255210552105510e5510e551105511055110551105511055110551
011400200417404162041520415204142041320412204115021740216202152021520214202132021220211500174001620015200152001420013200122001150217402162021520215202142021320212202115
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
01 13 42 43 44
00 14 42 43 44
00 15 42 43 44
00 16 42 43 44
00 17 42 43 44
00 18 42 43 44
02 19 42 43 44
03 1a 1b 43 44
00 41 42 43 44
01 1d 23 43 44
00 1e 23 43 44
00 1f 23 43 44
00 20 23 43 44
00 21 23 43 44
02 22 23 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
