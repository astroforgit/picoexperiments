pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--a coffeebreak roguelike of
--tactical espionage -mm2021
--#include main.lua
-- init
function _init ()	
 --flags
 solid       =0
 door        =1
 chest       =2
 noisy       =3
 -- ...
 block_sight =6
 stairs      =7

 -- globals
 t=0           -- global timer
 dt=0

 steps=0
 alerts=0
 knockouts=0
 pickups=0

 new_peek=false

 world={}      -- entity pool
 floats={}     -- floating numbers

 cam={x=0,y=0} -- camera

 alert={       -- alert status
  scroll=0,
  str=" ",
  col=1}
 alert_lvl=0

 p_hp=3        -- player HP
 p_hp_max=4

 level=1       -- current level
 next_lvl=false
 last_music=nil

 fde={
  i=15,
  dir=-1,
  delay=3,
  count=3,
  done=false
 }

 mis={
  i=0,
  x=128,
  done=false,
  failed=false,
  speed=16,
  txt="",
  y=0
 }

 debug={}

 -- fov
 unseen =0
 seen   =1
 visible=2

 -- etc
 door_speed =4

 -- lookup tables
 dirx=explodeval("-1,1,0,0,1,1,-1,-1")
 diry=explodeval("0,0,-1,1,-1,1,1,-1")

 mult={}
 mult[1]=explodeval("1,0,0,-1,-1,0,0,1")
 mult[2]=explodeval("0,1,-1,0,0,-1,1,0")
 mult[3]=explodeval("0,1,1,0,0,-1,-1,0")
 mult[4]=explodeval("1,0,0,1,-1,0,0,-1")

 fadetable={}
 fadetable[1]=explodeval("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")
 fadetable[2]=explodeval("1,1,1,1,1,1,1,0,0,0,0,0,0,0,0")
 fadetable[3]=explodeval("2,2,2,2,2,2,1,1,1,0,0,0,0,0,0")
 fadetable[4]=explodeval("3,3,3,3,3,3,1,1,1,0,0,0,0,0,0")
 fadetable[5]=explodeval("4,4,4,2,2,2,2,2,1,1,0,0,0,0,0")
 fadetable[6]=explodeval("5,5,5,5,5,1,1,1,1,1,0,0,0,0,0")
 fadetable[7]=explodeval("6,6,13,13,13,13,5,5,5,5,1,1,1,0,0")
 fadetable[8]=explodeval("7,6,6,6,6,13,13,13,5,5,5,1,1,0,0")
 fadetable[9]=explodeval("8,8,8,8,2,2,2,2,2,2,0,0,0,0,0")
 fadetable[10]=explodeval("9,9,9,4,4,4,4,4,4,5,5,0,0,0,0")
 fadetable[11]=explodeval("10,10,9,9,9,4,4,4,5,5,5,5,0,0,0")
 fadetable[12]=explodeval("11,11,11,3,3,3,3,3,3,3,0,0,0,0,0")
 fadetable[13]=explodeval("12,12,12,12,12,3,3,1,1,1,1,1,1,0,0")
 fadetable[14]=explodeval("13,13,13,5,5,5,5,1,1,1,1,1,0,0,0")
 fadetable[15]=explodeval("14,14,14,13,4,4,2,2,2,2,2,1,1,0,0")
 fadetable[16]=explodeval("15,15,6,13,13,13,5,5,5,5,5,1,1,0,0")

 baddie_name   =explodeval("ranger,soldier,cyberman,doggie")
 baddie_sprite =explodeval("195,192,198,201")
 baddie_sight  =explodeval("4,3,3,4")
 baddie_hear   =explodeval("4,4,4,5")

 alert_col     =explodeval("1,9,10,8")
 alert_str     =explode("all clear...,caution...,searching...,alert!!! ")
 mission_str   =explode("m,i,s,s,i,o,n, ,f,a,i,l,e,d")

 baddy={}
 baddy[1]      =explodeval("2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1")
 baddy[2]      =explodeval("2,2,2,2,2,1,2,1,2,1,1,1,1,1,1,1,1,1,1,1")
 baddy[3]      =explodeval("1,1,1,1,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3")
 baddy[4]      =explodeval("1,1,1,3,3,4,3,4,3,4,3,4,4,4,4,4,3,3,3,3")

 -- disable key repeat
 poke(0x5f5c,255)
 -- start
 start_intro()
end

-- callbacks
local fog=function (x,y)
 local col=0
 if fogger.fov.arr[x][y]==seen and fget(mget(x,y),solid) then
  rectfill(x*8,y*8,x*8+7,y*8+7,col)
  rectfill(x*8+2,y*8+2,x*8+5,y*8+5,col+1)
 elseif fogger.fov.arr[x][y]!=visible then
  rectfill(x*8,y*8,x*8+7,y*8+7,col)
 end
end

-- update loops
function _update60 ()
 t+=1
 _upd()
end

function _draw ()
 cls()
 if not fde.done then
  do_fade()
 end

 _drw()
end

--------------------------------------------------------------------------------
-- game states inits
--------------------------------------------------------------------------------
function start_level (lvl)
	--quickstart menu
	menuitem(1,"restart game", quick_boot)

 -- start level
 world={}
 floats={}
 p=nil
 mapgen(lvl)

 stamina=4

 if not last_music then
  if rnd()>0.5 then
   last_music=8
  else
   last_music=4
  end
 end

 last_music=last_music^^12
 music(last_music)

 -- init updates
 _upd=update_turn
 _drw=draw_game
 _last_upd=wait_player
end

function start_intro ()
 music(0)
 intro_bg={}
 inx=0
 inx2=0
 gen_intro_bg()
 
 reset_game()

 _upd=update_intro
 _drw=draw_intro
end

function reset_game ()
 p_hp=3
 level=1
 mis.failed=false

 steps=0
 alerts=0
 knockouts=0
 pickups=0
end

function quick_boot ()
	reset_game()
	
  init_fade()
 _upd=fade_wait
 _next_start=start_level
 _next_args=level
end

function end_game ()
 music(0)

 _upd=update_ending
 _drw=draw_ending
end

function update_ending ()
 --
end

function gen_intro_bg ()
 for i=1,36 do
  local x,y=flr(rnd(256))-128,flr(rnd(256)-128)
  local w,h=flr(rnd(32))+16,flr(rnd(32))+16
  add(intro_bg,{x,y,x+w,y+h,1})
 end
end

function update_intro ()
 if fde.done and btnp(4) then
  music(-1)
  sfx(55)
  init_fade()
  _upd=fade_wait
  _next_start=start_manual
 end
end

function start_manual ()
 _upd=update_manual
 _drw=draw_manual
end

function update_manual ()
 if fde.done and btnp(4) then
  init_fade()
  _upd=fade_wait
  _next_start=start_level
  level=1
  _next_args=level
 end
end

function fade_wait ()
 if fde.done then
  init_fade()
  _next_start(_next_args)
 end
end

function fade_delay (fr,next,next_args)
  dt+=1
  if dt>fr then
    init_fade()
    _upd=fade_wait
    _next_start=next
    _next_args=next_args
  end
end

function mission_failed_wait ()
 local fr=60*2.8
 if mis.done then
  dt+=1
  if dt>fr then
   --mis.failed=false
   init_fade()
   _upd=fade_wait
   reset_game()
   _next_start=start_level
   _next_args=level
  end
 end
end

function start_cutscene ()

end
--------------------------------------------------------------------------------
--tiny ecs v1.1
--by katrinakitten
--------------------------------------------------------------------------------
function ent(t)
 local cmpt={}
 t=t or {}
 setmetatable(t,{
  __index=cmpt,
  __add=function(self,cmp)
   assert(cmp._cn)
   self[cmp._cn]=cmp
   return self
  end,
  __sub=function(self,cn)
   self[cn]=nil
   return self
  end
 })
 return t
end

function cmp(cn,t)
 t=t or {}
 t._cn=cn
 return t
end

function sys(cns,f)
 return function(ents,...)
  for e in all(ents) do
   for cn in all(cns) do
    if(not e[cn]) goto _
   end
   f(e,...)
   ::_::
  end
 end
end

--#include ai.lua

function can_hear (e)
 local dist=sqrt((p.x-e.x)^2+(p.y-e.y)^2)
 return p.noisy and dist<=e.hear.dist
end

function find_target (e,target)
 local target=ai_check_for_p(e)
 if target then
  local r=a_star({e.x,e.y},{target.x,target.y})
  if r then
   local l=#r
   if e.path then
    e-="path"
   end
   e+=cmp("path",{route=r,step=l})
   return true
  end
 end
 return false
end

function state_stand (e)
 if e.status.ch then
  e.status.ch=nil
  e.status.lvl=0
 end
 local target=find_target(e)
 if target then
  sfx(63)
  e+=cmp("status",{ch="?",c=10,lvl=1})
  e.think.state=state_search
 end
end

function state_sleep (e)
 if not e.status.ch then
  e.status.ch="Zz"
  e.status.c=12
  e.status.lvl=0
  local sl=baddie_sprite[e.origin.typ]+16
  e.ani.fr={sl,sl,sl+1,sl+1}
  if not e.asleep then
   e+=cmp("asleep",{t=60})
  end
 end

 if can_hear(e) then
  e.asleep.t=0
 end

 if e.asleep.t>0 then
  e.asleep.t-=1
 else
  if not (e.x==p.x and e.y==p.y) then
   e-="asleep"
   e.ani.fr=setframes(baddie_sprite[e.origin.typ])
   local target=find_target(e)
   if target then
    sfx(63)
    e.status.ch="?"
    e.status.c=10
    e.status.lvl=1
    e.think.state=state_search
   else
    e.status.ch=nil
    e.status.lvl=0
    e.think.state=state_stand
   end
  end
 end
end

function state_search (e)
 local target=find_target(e)
 if target then
  sfx(62)
  alerts+=1
  e.status.ch="!"
  e.status.c=8
  e.status.lvl=3
  e.think.state=state_hunting
 else
  local done=take_step(e)
  if done then
   e.status.ch=nil
   e.status.lvl=0
   if e.x==e.origin.x and e.y==e.origin.y then
    e.think.state=e.origin.state
   else
    new_target(e,e.origin)
    e.think.state=state_walking
   end
  end
 end
end

function state_walking (e)
 local target=find_target(e)
 if target then
  sfx(63)
  e+=cmp("status",{ch="?",c=10,lvl=1})
  e.think.state=state_search
 else
  local done=take_step(e)
  if done then
   if e.x==e.origin.x and e.y==e.origin.y then
    e.status.ch=nil
    e.status.lvl=0
    e.think.state=e.origin.state
   else
    new_target(e,e.origin)
   end
  end
 end
end

function state_hunting (e)
 local target=find_target(e)
 if target then
  attack(e,target)
 else
  local done=take_step(e)
  if done then
   e.status.ch="\136"
   e.status.c=9
   e.status.lvl=2
   e+=cmp("wander",{c=8})
   e.think.state=state_frantic
  end
 end
end

function state_frantic (e)
 local target=find_target(e)
 if target then
  attack(e,target)
 else
  if e.wander.c>0 then
   local steps={}
   for i=1,4 do
    local dx,dy=dirx[i],diry[i]
    if not fget(mget(e.x+dx,e.y+dy),solid) then
     add(steps,{dx,dy})
    end
   end
   local step=steps[flr(rnd(#steps))+1]
   e.x+=step[1]
   e.y+=step[2]
   add_move(e,step[1],step[2])
   e.wander.c-=1
  else
   e.status.ch="?"
   e.status.c=10
   e.status.lvl=1
   new_target(e,e.origin)
   e.think.state=state_search
  end
 end
end

function state_patrol (e)
 if e.fov.arr and not e.patrol then
  local ptrl={}
  for x=0,15 do
   for y=0,15 do
    if e.fov.arr[x][y]==visible and x!=e.x and y!=e.y then
     add(ptrl,{x=x,y=y})
    end
   end
  end
  local d=ptrl[flr(rnd(#ptrl))+1]
  e+=cmp("patrol",{x=d.x,y=d.y})
 end
 if e.patrol then
  new_target(e,e.patrol)
  if not e.path then
   e.think.state,e.origin.state=state_stand,state_stand
  else
   e.think.state=state_walking
  end
 end
end

function attack (e)
 if e.typ==4 then
   -- bark
 else
   if not e.reloading then
    -- wiggle attacker
    e+=cmp("tween",{typ="shake",t=0})
    e.pos.x,e.pos.y=0,0
    -- create bullet entity
    sfx(57)
    spawn_bullet(e)
    -- subtract hp from player
    p_hp-=1
    -- flash or wiggle player
    add_float("-\135",p.x*8,p.y*8,8)
    p+=cmp("flashing",{d=20,col=7})
    -- add delay before next attack
    e+=cmp("reloading")
   else
    e-="reloading"
   end
 end
end

function spawn_bullet (e,targ)
 local b=ent({x=p.x,y=p.y})
 b+=cmp("pos",{x=0,y=0})
 b+=cmp("sprite",{sp=224,flp=false})
 b+=cmp("dead") -- destroy once tween is done

 local dx,dy=p.x-e.x,p.y-e.y
 b+=cmp("tween",{typ="move",x=-dx*8,y=-dy*8,t=0})

 add(world,b)
end

function new_target (e,targ)
 local r=a_star({e.x,e.y},{targ.x,targ.y})
 if r then
  local l=#r
  if e.path then
   e-="path"
  end
  e+=cmp("path",{route=r,step=l})
 end
end

function take_step (e)
 if e.path.step>0 then
  local dx=e.x-e.path.route[e.path.step][1]
  local dy=e.y-e.path.route[e.path.step][2]
  add_move(e,-dx,-dy)
  e.x=e.path.route[e.path.step][1]
  e.y=e.path.route[e.path.step][2]
  e.path.step-=1
 else
  return true
 end
 return false
end

--#include fov.lua

--------------------------------------------------------------------------------
-- fov
--------------------------------------------------------------------------------
function is_blocked (x,y)
 return x<0 or y<0 or x>15 or y>15 or fget(mget(x,y),block_sight)
end

function lit(e,x,y)
 return e.fov.arr[x][y]==visible
end

function set_lit (e,x,y)
 if x>=0 and x<=15 and y>=0 and y<=15 then
  e.fov.arr[x][y]=visible
 end
end

function cast_light (e,cx,cy,row,start,lend,radius,xx,xy,yx,yy)
 if start<lend then return end
 local radius_sq=radius*radius
 for j=row,radius+1 do
  local dx,dy=-j-1,-j
  local blocked=false
  while dx<=0 do
   dx+=1
   local x,y=cx+dx*xx+dy*xy,cy+dx*yx+dy*yy
   local lslope,rslope=(dx-0.5)/(dy+0.5),(dx+0.5)/(dy-0.5)
   if start<rslope then
    goto continue
   elseif lend>lslope then
    break
   else
    if dx*dx+dy*dy<radius_sq then
     set_lit(e,x,y)
    end
    if blocked then
     if is_blocked(x,y) then
      new_start=rslope
      goto continue
     else
      blocked=false
      start=new_start
     end
    else
     if is_blocked(x,y) and j<radius then
      blocked=true
      cast_light(e,cx,cy,j+1,start,lslope,radius,xx,xy,yx,yy)
      new_start=rslope
     end
    end
   end
   ::continue::
  end
  if blocked then break end
 end
end

function init_fov (e)
 e.fov.arr={}
 for x=0,15 do
  e.fov.arr[x]={}
  for y=0,15 do
   e.fov.arr[x][y]=unseen
  end
 end
end

function clear_fov (e)
 for x=0,15 do
  for y=0,15 do
   if not e.fog then
    e.fov.arr[x][y]=unseen
   else
    if e.fov.arr[x][y]==seen or e.fov.arr[x][y]==visible and fget(mget(x,y),solid)then
     e.fov.arr[x][y]=seen
    else
     e.fov.arr[x][y]=unseen
    end
   end
  end
 end
end

calc_fov=sys({"fov"}, function(e,calc_fov)
 -- init fov
 if not e.fov.arr then
  init_fov(e)
 end
 -- clear fov
 clear_fov(e)
 set_lit(e,e.x,e.y)

 for oct=1,8 do
  local x,y=e.x,e.y
  local radius=e.fov.sight
  cast_light(e,x,y,1,1.0,0.0,radius,mult[1][oct],
                                    mult[2][oct],
                                    mult[3][oct],
                                    mult[4][oct])
 end
end)

--#include systems.lua

-- update systems
function update_turn()
 if next_lvl then
  sfx(56)
  next_lvl=false
  level+=1
  if level>20 then
   -- end game
   _upd=fade_wait
   _next_start=end_game
  else
   _upd=fade_wait
   _next_start=start_level
   _next_args=level
  end
  init_fade()
 else
  calc_fov(world)
  update_ai(world)
  alert_lvl=0
  set_alert(world)
  -- go back to waiting for player or peeking
 	_upd=_last_upd
 end
end

-- draw systems
draw_doors=sys({"door"},function(e,draw_doors)
 if not e.open then mset(e.x,e.y,13+flr(t/15)%2*16)
 else
  mset(e.x,e.y,45+(16*(2-e.open.f)))
  e.open.t-=1
  if e.open.t==0 then
   e.open.f-=1
   if e.open.f==1 then
    --e.open.f-=1
    e.open.t=door_speed
   else
    mset(e.x,e.y,1)
    del(world,e)
   end
  end
 end
end)

draw_sprites=sys({"sprite","pos"}, function(e,draw_sprites)
 if e.flashing then
  e.flashing.d-=1
  if t%8==0 then
   for i=0,15 do
    pal(i,e.flashing.col)
   end
  end
  if e.flashing.d==0 then
   e-="flashing"
  end
 end
	spr(e.sprite.sp,e.x*8+e.pos.x,e.y*8+e.pos.y,1,1,e.sprite.flp)
 pal()
 if e.status and e.status.ch and flr(t/15)%2==0 then
  oprint8(e.status.ch,e.x*8+e.pos.x+6,e.y*8+e.pos.y-1,e.status.c)
 end
end)

update_frames=sys({"sprite","ani"}, function(e,update_frames)
	e.sprite.sp=getframe(e.ani.fr)
end)

update_tweens=sys({"tween","pos"}, function(e,update_tweens)
	e.tween.t=min(e.tween.t+0.125,1)
	-- move one tile
	if e.tween.typ=="move" then
		e.pos.x=e.tween.x*(1-e.tween.t)
		e.pos.y=e.tween.y*(1-e.tween.t)
	-- bump
	elseif e.tween.typ=="bump" then
		local tme=e.tween.t
		if e.tween.t>0.5 then
		 tme=1-e.tween.t
		end
	 e.pos.x=e.tween.x*tme
		e.pos.y=e.tween.y*tme
 elseif e.tween.typ=="peek" then
  if e.tween.t<0.5 then
   e.pos.x=e.tween.x*e.tween.t
   e.pos.y=e.tween.y*e.tween.t
  end
 elseif e.tween.typ=="shake" then
  e.pos.x=sin(e.tween.t)
	end
	-- remove tween
	if e.tween.t==1 then
		e-="tween"
	end
end)

update_dead=sys({"dead"}, function (e,update_dead)
 if not e.tween then
  del(world,e)
 end
end)

set_alert=sys({"status"}, function(e,set_alert)
 if e.status.lvl>alert_lvl then
  alert_lvl=e.status.lvl
 end
end)

update_ai=sys({"think"}, function(e,update_ai)
 e.think.state(e)
end)

--#include helpers.lua

-- component helpers
function add_move(e,dx,dy,da)
	if da then da=1.5 else da=1 end
	e+=cmp("tween",{typ="move",x=-dx*8*da,y=-dy*8*da,t=0})
 sprite_flip(e,dx)
	e.pos.x,e.pos.y=e.tween.x,e.tween.y
end

function add_bump(e,dx,dy)
	e+=cmp("tween",{typ="bump",x=dx*8,y=dy*8,t=0})
 sprite_flip(e,dx)
	e.pos.x,e.pos.y=0,0
end

function add_peek(e,dx,dy)
 e+=cmp("tween",{typ="peek",x=dx*8,y=dy*8,t=0})
 e+=cmp("peeking",{x=0,y=0,dx=dx,dy=dy})
 sprite_flip(e,dx)
 e.pos.x,e.pos.y=0,0
 e.ani.fr=setframes(243)
end

function end_peek(e)
 local dx,dy=e.peeking.dx,e.peeking.dy
 e+=cmp("tween",{typ="peek",x=-dx*8,y=-dy*8,t=0.5})
 e.pos.x,e.pos.y=e.peeking.x,e.peeking.y
 p-="peeking"
 new_peek=false
 p.ani.fr=setframes(240)
 fogger.x,fogger.y=p.x,p.y
 calc_fov({fogger})
end

function sprite_flip(e,dx)
	if dx<0 then
		e.sprite.flp=true
	elseif dx>0 then
		e.sprite.flp=false
	end
end

function add_float(_txt,_x,_y,_c)
 add(floats,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-4,t=0})
end

function spawn_mob (x,y,sp,si,so,flags)
 m=ent({x=x,y=y})
 m+=cmp("pos",{x=0,y=0})
 m+=cmp("sprite",{sp=sp,flp=false})
 m+=cmp("ani",{fr=setframes(m.sprite.sp)})
 if si then
  m+=cmp("fov",{arr=nil,sight=si})
 end
 if so then
  m+=cmp("hear",{dist=so})
 end
 if flags then
  for f in all(flags) do
   m+=cmp(f)
  end
 end

 add(world,m)
 return m
end

function spawn_fog (x,y,d)
 f=ent({x=x,y=y})
 f+=cmp("fov",{arr=nil,sight=d})
 f+=cmp("fog")

 add(world,f)
 return f
end

function spawn_door (x,y)
 d=ent({x=x,y=y})
 d+=cmp("door",{t=door_speed,f=2})

 add(world,d)
end

--#include player.lua

function wait_player()
 if p_hp<=0 then
  -- death music
  music(14)

  -- set death frame
  p.ani.fr={248}

  init_mission_failed()
  dt=0
  _upd=mission_failed_wait
 else
  local bt=-1
  if p.noisy then
   p-="noisy"
  end
  if not still_tweens() then
   if btnp(4) then
    new_peek=true
   end
   if btn(4) and new_peek then
    -- hold z to peek
    bt=get_dir()
    if bt>=0 then
     check_peek(dirx[bt+1],diry[bt+1])
    end
   elseif btnp(5) then
    -- tap x to pass a turn
    add_float("\147",p.x*8,p.y*8,12)
    _last_upd=wait_player
    pass_turn()
   else
    -- check move
    bt=get_dir()
    if bt>=0 then
     moveplayer(dirx[bt+1],diry[bt+1])
    end
   end
  end
 end
end

function pass_turn ()
 _upd=update_turn
end

function update_peek()
 if not btn(4) then
  end_peek(p)
  _upd=wait_player
 elseif btnp(5) then
  add_float("\147",p.x*8+4,p.y*8,12)
  _last_upd=update_peek
  pass_turn()
 else
  if stamina>0 then
    local bt=get_dir()
    if bt>=0 then
     -- check if next is open
     if p.peeking.dx == dirx[bt+1] and p.peeking.dy == diry[bt+1] then
       local dax,day=p.x+dirx[bt+1]*2,p.y+diry[bt+1]*2
       if not fget(mget(dax,day),solid) then
        local d=getmob(dax,day)
        if d then
         sfx(59)
         hit_mob(d)
        end
        add_float("\132",p.x*8+4,p.y*8,6)
        p.x=dax
        p.y=day
        p-="peeking"
        new_peek=false
        p.ani.fr=setframes(240)
        add_move(p,dirx[bt+1],diry[bt+1],true)

        fogger.x,fogger.y=p.x,p.y
        calc_fov({fogger})
        -- subtract stamina
        sfx(53)
        stamina-=1
        _last_upd=wait_player
        _upd=update_turn
       end
     end
   end
   --
  end
 end
end

function check_peek(dx,dy)
 if iswalkable(p.x+dx,p.y+dy) then
  add_peek(p,dx,dy)
  sprite_flip(p,dx)
  fogger.x+=dx
  fogger.y+=dy
  calc_fov({fogger})
  _upd=update_peek
 end
end

function get_dir ()
 for i=0,3 do
  if btnp(i) then
   return i
  end
 end
 return -1
end

function moveplayer(dx,dy)
	local destx,desty=p.x+dx,p.y+dy
	local tle=mget(destx,desty)
	if iswalkable(destx,desty) then
    steps+=1
		p.x+=dx
		p.y+=dy
  fogger.x=p.x
  fogger.y=p.y
  if fget(tle,noisy) then
   sfx(58)
   make_noise()
  elseif fget(tle,stairs) then
   -- stairs up
   next_lvl=true
  end
		-- add tween
		add_move(p,dx,dy)
  _last_upd=wait_player
  _upd=update_turn
	else
  local d=getmob(destx,desty)
  -- check bump
  if fget(tle,door) then
   -- it's a door, open it
   sfx(60)
   d+=cmp("open",{t=door_speed,f=2})
  elseif d then
   -- hit mob
   sfx(59)
   hit_mob(d)
   _last_upd=wait_player
   _upd=update_turn
  elseif fget(tle,chest) then
   -- open chest
   sfx(54)
   pickups+=1
   add_float("+\135",p.x*8+4,p.y*8,8)
   p_hp=min(p_hp+1,p_hp_max)
   mset(destx,desty,28)
   _last_upd=wait_player
   _upd=update_turn
  else
   -- it's a wall, make noise
   sfx(61)
   make_noise()
   _last_upd=wait_player
   _upd=update_turn
  end
		-- add tween
		add_bump(p,dx,dy)
	end
end

function hit_mob (e)
 knockouts+=1
 add_float("\146",e.x*8+4,e.y*8,10)
 e+=cmp("asleep",{t=15})
 e.status.ch=nil
 e.status.lvl=0
 e.think.state=state_sleep
end

function make_noise ()
 p+=cmp("noisy")
end

--#include generation.lua

--------------------------------------------------------------------------------
-- gen
--------------------------------------------------------------------------------
-- shuffle by kittenm4ster
function shuffle(t)
  -- do a fisher-yates shuffle
  for i = #t, 1, -1 do
    local j = flr(rnd(i)) + 1
    t[i], t[j] = t[j], t[i]
  end
end

function gen_stairs (mx,my,s)
 if s==false then
  mset(mx,my,1)
 else
  if p then
   mset(mx,my,31)
  else
   p=spawn_mob(mx,my,240,nil,nil,{"player"})
   fogger=spawn_fog(p.x,p.y,5)
   mset(mx,my,15)
  end
 end
end

function gen_chest (typ,mx,my)
 if not typ then
  --spawn chest
  mset(mx,my,12)
 else
  -- spawn elite
  gen_baddie(typ,mx,my)
 end
end

function gen_baddie (typ,mx,my,st)
 local m=spawn_mob(mx,my,
  baddie_sprite[typ],
  baddie_sight[typ],
  baddie_hear[typ])
 m+=cmp("think",{state=st or state_stand})
 m+=cmp("origin",{typ=typ,x=mx,y=my,state=st or state_stand})
 m+=cmp("status",{ch=nil,c=0,lvl=0})
 -- set the spawn tile to floor
 mset(mx,my,1)
end

function get_baddies (lvl)
 return {baddy[1][lvl],baddy[2][lvl],2,2}
end

function get_chests (lvl)
 return {baddy[3][lvl],baddy[4][lvl],false,false}
end

function mapgen (lvl)
 -- shuffle player stairs
 local s={true,true,false,false}
 -- get baddies and chests for lvl
 local b=get_baddies(lvl)
 local c=get_chests(lvl)
 shuffle(s)
 shuffle(b)
 shuffle(c)
 for q=0,3 do
  local r=flr(rnd(16))
  for x=0,7 do
   for y=0,7 do
    local tl=sget(x+r*8,32+y+q*8)
    local mx,my=x+(q%2)*8,y+flr(q/2)*8
    if tl==13 then
     -- doors
     mset(mx,my,tl)
     spawn_door(mx,my)
    elseif tl==15 then
     -- stairs and spawn p
     gen_stairs(mx,my,s[q+1])
    elseif tl==11 then
     -- green - 25% chance to spawn
     if rnd()<0.25 then
      gen_chest(c[q+1],mx,my)
     else
      mset(mx,my,1)
     end
    elseif tl==14 then
     -- pink - always spawn
     local r=flr(rnd(16))
     local st=state_stand
     if r==15 then
      --sleeping 1/16 chance
      st=state_sleep
     elseif r>9 then
      --patroling 4/16 chance
      --st=state_patrol
     end
     gen_baddie(b[q+1],mx,my,st)
    else
     mset(mx,my,tl+16*flr(rnd(4)))
    end
   end
  end
 end
end

--#include draws.lua

--------------------------------------------------------------------------------
-- draws
--------------------------------------------------------------------------------
function draw_ending ()
 local tx,ty=28,40
 camera()
 map(16,16,0,0,16,16)
 oprint8("mission complete!!",28,16,8,1)
 oprint8("steps taken:    "..steps,tx,ty,12,1)
 oprint8("knockouts:      "..knockouts,tx,ty+8,12,1)
 oprint8("alerts:         "..alerts,tx,ty+16,12,1)
 oprint8("health pickups: "..pickups,tx,ty+24,12,1)
end

function draw_manual ()
 color(8)
 print (" -- mission --")
 print("")
 color(6)
 print ("our hero, badger, has captured  ")
 print ("the plan for the bipedal nuclear")
 print ("weapon known only as rogue gear!")
 print ("clear 20 floors to escape!      ")
 print ("")
 color(8)
 print (" -- how to play --              ")
 print("")
 color(6)
 print ("use ”ƒ‹‘ to move a space    ")
 print ("move into an enemy to knock them")
 print (" out temporarily                ")
 print("")
	print ("tap — or x to pass a turn      ")
 print("")
	print ("hold Ž or z + tap ”ƒ‹ or ‘ ")
	print (" to peek ahead one space        ")
	print ("while peeking, tap ”ƒ‹ or ‘ ")
	print (" again to dash two spaces       ")
end

function draw_intro ()
 camera()
 for i=1,#intro_bg do
  local r=intro_bg[i]
  if i%2==0 then
   rect(r[1]+inx,r[2],r[3]+inx,r[4],r[5])
   rect(r[1]+inx-256,r[2],r[3]+inx-256,r[4],r[5])
  else
   rect(r[1]+inx2,r[2],r[3]+inx2,r[4],r[5])
   rect(r[1]+inx2-256,r[2],r[3]+inx2-256,r[4],r[5])
  end
 end

 inx+=0.25
 inx2+=0.5
 if inx>256 then inx=0 end
 if inx2>256 then inx2=0 end

 map(16,0,0,0,16,16)
 oprint8("TACTICAL ESPIONAGE ROGUELIKE",9,34,8)
 oprint8("press \142 or z to start",20,77,13)
 oprint8("2021 mike maclean",30,120,13)
end

function draw_game ()
 if p then
  cam.x,cam.y=p.x*8+p.pos.x-60,p.y*8+p.pos.y-60
 end
 camera(cam.x,cam.y)
 map(0,0,0,0,16,16)
 -- draw systems
	update_frames(world)
	update_tweens(world)
 if fde.i<8 then
	 draw_sprites(world)
 end
 update_dead(world)
 draw_doors(world)
 if fogger.fov.arr then
  mapfill(fog)
 end
 draw_ui()
end

function draw_ui ()
 if not mis.failed and fde.done then
  draw_floats()
  if p then
   draw_lives()
  end
  draw_alert()
 end
 if mis.failed then
  draw_mission_failed()
 end
end

function draw_lives ()
 local co=0
 for hp=1,p_hp_max do
  if p_hp>=hp then
   co=8
  else
   co=0
  end
  oprint8("\135",cam.x+hp*8,cam.y+8,co,1)
 end
 oprint8("f"..level,cam.x+41,cam.y+8,0,1)
 rect(cam.x+7,cam.y+15,cam.x+40,cam.y+17,1)
 for stam=1,4 do
   if stamina>=stam then
     co=12
   else
     co=0
   end
   rect(cam.x+stam*8,cam.y+16,cam.x+stam*8+7,cam.y+16,co)
 end
end

function draw_alert ()
 local ax,ay=cam.x+90,cam.y+6
 local ax2,ay2=cam.x+126,cam.y+20
 local c=alert_col[alert_lvl+1]
 local str=alert_str[alert_lvl+1]

 rectfill(ax,ay,ax2,ay2,c)
 rectfill(ax+1,ay+1,ax2-1,ay+6,0)
 print("STATUS",ax+7,ay+1,c)

 clip(ax+1-cam.x,ay-cam.y,ax2-1-cam.x,ay2-cam.y)
 print(str..str,ax+1+alert.scroll,ay+8,0)
 clip()

 alert.scroll-=t%2
 if alert.scroll<-(#str*4) then
  alert.scroll=0
 end
end

function draw_floats()
 for f in all(floats) do
  oprint8(f.txt,f.x,f.y,f.c,0)
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>48 then
   del(floats,f)
  end
 end
end

function draw_mission_failed()
 if not mis.done then
  mis.y+=0.25
  if mis.y>4 then
   mis.y=4
  end
  if mis.x>0 then
   mis.x-=mis.speed
   if mis.x<0 then
    mis.x=0
   end
  else
   mis.x=128-(mis.i+1)*4
   if mis.i>0 then
    mis.txt=mis.txt..mission_str[mis.i]
   end
   if mis.i<#mission_str then
    mis.i+=1
   else
    mis.done=true
   end
  end
 end
 --oprint8(mis.txt,15,60,8,0)
 rectfill(0+cam.x,54-mis.y+cam.y,128+cam.x,54+mis.y+cam.y,8)
 oprint8(mis.txt,36+cam.x,52+cam.y,8,0)
 oprint8(mission_str[mis.i],36+cam.x+mis.i*4+mis.x,52+cam.y,8,0)
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end
 print(_t,_x,_y,_c)
end

--#include tools.lua

--------------------------------------------------------------------------------
-- tools
--------------------------------------------------------------------------------
-- explode
function explode(s)
 local retval,lastpos={},1
 for i=1,#s do
  if sub(s,i,i)=="," then
   add(retval,sub(s, lastpos, i-1))
   i+=1
   lastpos=i
  end
 end
 add(retval,sub(s,lastpos,#s))
 return retval
end

function explodeval(_arr)
 return toval(explode(_arr))
end

function toval(_arr)
 local _retarr={}
 for _i in all(_arr) do
  add(_retarr,flr(tonum(_i)))
 end
 return _retarr
end

function ai_check_for_p (e)
 if can_hear(e) then
  return {x=p.x,y=p.y}
 end
 for x=0,15 do
  for y=0,15 do
   if e.fov.arr[x][y]==visible and p.x==x and p.y==y then
    return {x=x,y=y}
   end
  end
 end
 return false
end

-- check if tile is walkable
function iswalkable(x,y)
	if inbounds(x,y) then
		if not fget(mget(x,y),solid) then
   local m=getmob(x,y)
   if not m or m.asleep then
    return true
   end
   --return true
  end
			--return not getmob(x,y)
	end
	return false
end

function inbounds(x,y)
	return not (x<0 or y<0 or x>15 or y>15)
end

-- animation inits
function getframe(ani)
	return ani[flr(t/15)%#ani+1]
end

function setframes(st,n)
 local ct=n or 3
	local fr={}
	for i=0,ct do
		local j=i
		if j==3 then j=1 end
		add(fr,st+j)
	end
	return fr
end

-- iterate over map
function mapfill (callback)
 for x=0,15 do
  for y=0,15 do
   callback(x,y,z)
  end
 end
end

function still_tweens ()
 for e in all(world) do
  if e.tween then return true end
 end
 return false
end

-- fade screen
function init_fade ()
 fde.done=false
 fde.dir=-fde.dir
 fde.i+=fde.dir
 fde.delay=3
 fde.count=fde.delay
end

function init_mission_failed ()
 mis.x=-1
 mis.i=0
 mis.done=false
 mis.failed=true
 mis.txt=""
 mis.y=0
end

function do_fade ()
 if fde.i>-1 and fde.i<16 then
  fade(fde.i)
  fde.count-=1
  if fde.count==0 then
   fde.count=fde.delay
   fde.i+=fde.dir
  end
 else
  fde.done=true
 end
end

function fade(i)
 for c=0,15 do
  if flr(i+1)>=16 then
   pal(c,0)
  else
   pal(c,fadetable[c+1][flr(i+1)])
  end
 end
end

--------------------------------------------------------------------------------
-- pathfinding
--------------------------------------------------------------------------------
-- https://www.edureka.co/blog/a-search-algorithm/
function node(parent,pos)
 return {
  parent=parent or nil,
  pos=pos or nil,
  g=0,h=0,f=0
 }
end

function a_star (start, goal)
 start_node=node(nil,start)
 end_node=node(nil,goal)
 open_list={}
 closed_list={}
 add(open_list,start_node)
 while #open_list>0 do
  current_node=open_list[1]
  current_index=1
  for i=1,#open_list do
   if open_list[i].f<current_node.f then
    current_node=open_list[i]
    current_index=i
   end
  end
  deli(open_list,current_index)
  add(closed_list,current_node)
  -- if end
  if is_equal_node(current_node,end_node) then
   --add(debug,"end?")
   path={}
   current=current_node
   while current!=nil do
    add(path,current.pos)
    current=current.parent
   end
   --add(debug,#path)
   return path
  end
  -- children directions
  children={}
  for i=1,4 do
   node_pos={current_node.pos[1]+dirx[i],current_node.pos[2]+diry[i]}
   if is_valid_pos(node_pos) then
    new_node=node(current_node,node_pos)
    add(children,new_node)
   end
  end
  -- for all children
  for child in all(children) do
   if not in_list(child,closed_list) then
    child.g=current_node.g+1
    child.h=heuristic(child,end_node)
    child.f=child.g+child.h
    if not go_to_start(child) then
     add(open_list,child)
    end
   end
  end
 end
end

function go_to_start (n)
 local ol_node=in_list(n,open_list)
 if ol_node then
  if n.g>ol_node.g then
   return true
  end
 end
 return false
end

function in_list(n,l)
 for i in all(l) do
  if is_equal_node(n,i) then
   return i
  end
 end
 return false
end

function heuristic (a,b)
 return (a.pos[1]-b.pos[1])^2+(a.pos[2]-b.pos[2])^2
end

function is_equal_node (a,b)
 return a.pos[1]==b.pos[1] and a.pos[2]==b.pos[2]
end

function is_valid_pos (pos)
 return pos[1]>0 and pos[1]<15 and
  pos[2]>0 and pos[2]<15 and
  not fget(mget(pos[1],pos[2]),solid)
end

-- check if enemy is at x,y
function getmob(x,y)
 for m in all(world) do
  if m.x==x and m.y==y then
   return m
  end
 end
 return false
end
__gfx__
00000000000000001111111011111110111111100000000075757550777777702222222014444410005550000000000000000000000000000000000011111110
00000000000000001111111010101010111111100000000d55755550777777702222222044444440053335000bbbbbb005555500666666600eeeeee000000000
00700700000000001111111010101010010101006060606555555550777777702222222044444440535333500bbbbbb0577777501ddddd100eeeeee011000000
00077000000000001111111011111110101010100606060d55555550777777702222222014444410553335500bbbbbb0d66666d01d6661100eeeeee011011000
00077000000000000000000010101010000000006060606d00000000777777702222222055555550535553500bbbbbb0d66666d01dddd1800eeeeee011011010
00700700000100000001000010101010010101000d0d0d0d00010000777777702222222014444410533bb3500bbbbbb0dddbddd01ddddd100eeeeee011011010
000000000000000000000000111111100000000010101011000000007777777022222220444444400533b5000bbbbbb0d66666d0111111100eeeeee011011010
00000000000000000000000000000000000000000101010100000000000000000000000000000000105550100000000000000000000000000000000000000000
00000000000000001111011011111110111111100000000055555550777777702222222010550010005550000000000000000000000000000000000066000000
00000000000000001111011010101010111111100000000d55555550777777700222222005445500053335000bbbbbb005555500666666600eeeeee066066000
0000000000000000111010101b1b1b10010101006060606555555550777777702222222054444450533353500bbbbbb0511111501ddddd100eeeeee066066060
00000000000000000110111011111110101010100888880d55555550777776702222222054444445553335500bbbbbb0500000501d6661100eeeeee000066060
00000000000000000000000013131310000000006899986d00000000777777702222022015444445535553500bbbbbb0d00000d01dddd1b00eeeeee011000060
0000000000010000000100001b1b1b10010101000888880d00010000767777702222202041554450533333500bbbbbb0ddd8ddd01ddddd100eeeeee011011000
00000000000000000000010011111110000000001010101100000000666666602022220044115510053335000bbbbbb0d66666d0111111100eeeeee011011010
00000000000000000000000000000000000000000101010100000000000000000000000000000000105550100000000000000000000000000000000000000000
00000000000000001111111011111110111111100000000055555550777777702222222014444410005550000000000000000000000000000000000000000000
00000000000000001111111010111010111111100006000d55555550767777702222222044444440053335000bbbbbb000000000666660000eeeeee000000000
00000000000000001111111011111110010101006000606555555770777777602222222044444440535333500bbbbbb000000000dddd10000eeeeee000000000
00000000000000001111111011111110101010100606060d57557770777777702222222014444410553335500bbbbbb000000000666110000eeeeee000000000
00000000000000000000000011111110000000006060606d00700770777677702222222055555550535553500bbbbbb000000000ddd1b0000eeeeee000000000
00000000000100000001000010111010010101000d0d0d0d00010000777777702222222014444410533333500bbbbbb000000000dddd10000eeeeee000000000
00000000000000000000000011111110000000001010101100000000777777702222222044444440053335000bbbbbb000000000111110000eeeeee000000000
00000000000000000000000000000000000000000101010100000000000000000000000000000000105550100000000000000000000000000000000000000000
00000000000000001111111011111110111111100000000055171550777777702222222019844410005550000000000000000000000000000000000000000000
00000000000000000020020010101010111111100000000d55565550777777702222202094444440053335000bbbbbb000000000666000000eeeeee000000000
00000000000000000200200010001010010101006000006555575550777777702222222044444440535333500bbbbbb000000000dd1000000eeeeee000000000
00000000000000001111111011111110101010100000000d55171550777777702222222014444410553335500bbbbbb000000000611000000eeeeee000000000
00000000000000000000000010101010000000006000006d00060000777777702022222055555550535553500bbbbbb000000000d1b000000eeeeee000000000
00000000000100000001000010100010010101000d000d0d00010000777777702222222019444910533353500bbbbbb000000000dd1000000eeeeee000000000
00000000000000000000000011111100000000001000001100000000777777702202222048444490053535000bbbbbb000000000111000000eeeeee000000000
00000000000000000000000000000001000000000100010100000000000000000000000000000000105550100000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888000888888888888888888888888888888888000877777777777777777777777777777777
82222228822222288222822282222228822922288922222882222222000822288222222882222228822882288228000876666667766666677666666776666667
8f111138811f11128f1181118f1111128f191112841e111d81313131000811f8831111f88188881283188b3881f800087f191117731317f77f11113771311116
81999b18888888188111819881111118811913e181111118811111e188881aa881188888818228188a1221128118888879191ab7711117777999155779115557
8144411d822222188818814d888198888114111181a31ab88b91f991822214488198222281d1f8e884111111811222227414141d71111666744411b77431a1a7
8199911881b11118821221e882214228891199988fa11a1d814114418111111881483e188181181881188198811b11117555551771baaae1715555577fa14e46
81444138819113188b111118833133328411444881413418813111188b31ea1d83b888d8838888188ae8814881399e9171311317711444117e31131d71415557
81e1111881411e18813313388b1111e88111b118811111188111111881111418811222188b222212841221f28114414171e111177111113171111117713111b7
88888888888888888888880088888888888888888880888888888888888888888888888888888880888888888888888877777777777770007777777777777777
222222f822222228222228002222222822222228228082282f222228282282282822222822222288292222282222222866666667666670006666666766666667
11111198131f11381e311800111a33e8111113181e80811819991318183f8ab8b8f1111811f11128191111381e119f381b19f31731137777e7777717111111f7
13888148199991a811555888181488183e91991811888f1814441118e811d418388888d831939138141af1181911491811141117111e6667176667171a3aa1a7
11808138144441481111122838312218119f99b811222a181e11111818a181181222221811414118111999b8141114181515555711555af717b117f714144147
1e888b9819e991b8b31319f8128818183191441811313418131313b8188888d8398888e81b1111e813144418139913181e1991171111ba17177d77171a1ea1a7
1122214814144138111114181b221818114113181b111118111919181222223814822218318d81381e11111811441b1811144117113114171661661714155557
81111188888d888881888888888f88d8818888188881888888141418888d88888881888881818188881138888888881877111777777d77177d777777711313b7
8888d888888811888188118888881188888811888888181888881888888811118d88d88888811888888888d8888188887777177777771777777711177177d777
8222122282221122812211228228a1828228112282221212822812228229e331812212a28aa11aa282222212822122227666166600761666766ae11671661666
811111118b31113181e111b181f8888b83b81e138311111183e211b181f91331811111418aae144183991111811111e171111111007b11117f3a111171111111
8199e993811111118188199181122221811d131188d8819b88888881811411118e3113b18441133b8199e9318d8881317b77777e777555e1711419937b31ae91
8144144188819e318188144181131111811888818212819182222281811113318111a11185555551814414118122811171766671766111117111144171114141
81f9199b00819111812213f1851aae918d8822818f1981418f888181811ab33188814881811111118f9119318113813171d1f1717119155171a555517777139f
81141441008f8881811111118114414181221f8181148111818221d1811411110081f8818f9199318141b41181f181b17371117371f91131714111b100071141
88888888008880888888888888888888888888888888888888888888888888880088888888888888888888888888888877777777777777777777777700077777
8111111881133118811111188111111881111b38811111188111111881111118813111188111111881111b188111111871b1111771e111377111111771111b17
8181a118811e111821e311388e1f313888d8888881b13e3881888818213e13b881e11b18831b13188313191881e11b187aaa1ae77177777771f315577131aaa7
2181881883199918111111188119911882e22228819911188182281881991918813199188888881881111418813113387444141761766667619111a7711ea447
11838218d1194418111111b8d114411821888888814931382e81f8b82144141821118418822228e821119118d131133875551557717111b71e931147d13141f7
118181888b19f11881991138855155581182222881f88888818d88188111111881318f1881af181811119f18855199987111f197617d77771141111771111137
818e812883141318819411a88111aaa881888f188118000081212218d1af133881918118d1411d1813e398888111444871311347716166671119155771177777
8b8381f881111118214f114883b1444881d2219821180000811111188141133883438318831138381111480081111f1861111117711f113771141b3779370000
88888888888888888888888888888888888888888888000088888888888888888888888888888888888888008888888877777777777777777777777777770000
000000000ccccc0000000ccccc000000cccc00000000cccc00ccccccc00000000ccccccc0000000ccccc0000000ccccc00000cccc000ccc00cccccccccc00000
0000000cc11111ccc00cc11111ccc00c111d0000000c111d0c1111111cc00000c1111111cc000cc11111cc000cc11111cc00c111d000c1d0c111111111d00000
000000c111111111d0c1111111111d0c111d0000000c111d0c111111111d0000c111111111d0c111111111d0c111111111d0c111d000c1d0c111dddd11d00000
000000c1111ddd11d0c1111ddd111d0c111d0000000c111d0c111dddd11d0000c111ddd111d0c1111ddd11d0c1111ddd11d0c111d000c1d0c111d000ddd00000
000000c111c000ddd0c111d000c11d0c111d0000000c111d0c111d000c1d0000c111d00c11d0c111d000c1d0c111d000ddd0c111d000c1d0c111d00000000000
000000c111c0000000c111d000c11d0c111d0000000c111d0c111d000c1d0000c111d00c11d0c111d000c1d0c111d0000000c111d000c1d0c111d00000000000
000000c1111ccc0000c111d000c11d0c111d0000000c111d0c111d000c1d0000c111dcc111d0c111d000c1d0c111d0000000c111d000c1d0c111cccc00000000
000000c1111111cc00c111d000c11d0c111d0000000c111d0c111d000c1d0000c11111111d00c111d000c1d0c111d00cccc0c111d000c1d0c111111d00000000
0000000dd1111111d0c111d000c11d0c111d0000000c111d0c111d000c1d0000c11111111d00c111d000c1d0c111d00c11d0c111d000c1d0c111dddd00000000
000000000ddd1111d0c111d000c11d0c111d0000000c111d0c111d000c1d0000c111ddd111d0c111d000c1d0c111d00c11d0c111d000c1d0c111d00000000000
000000000000c111d0c111d000c11d0c111d0000000c111d0c111d000c1d0000c111d00c11d0c111d000c1d0c111d000c1d0c111d000c1d0c111d00000000000
000000ccc000c111d0c111d000c11d0c111d000ccc0c111d0c111d000c1d0000c111d00c11d0c111d000c1d0c111d000c1d0c111d000c1d0c111d000ccc00000
000000c11ccc1111d0c1111ccc111d0c1111ccc11d0c111d0c111dccc11d0000c111d00c11d0c1111ccc11d0c1111ccc11d0c1111ccc11d0c111ccccc1d00000
000000c111111111d0c1111111111d0c111111111d0c111d0c111111111d0000c111d00c11d0c111111111d0c111111111d0c111111111d0c111111111d00000
000000cdd11111dd000dd11111ddd00c111111111d0c111d0c1111111dd00000c111d00c11d00dd11111dd000dd11111dd000dd11111dd00c111111111d00000
000000000ddddd0000000ddddd00000cdddddddddd0cdddd0cddddddd0000000cdddd00cddd0000ddddd0000000ddddd0000000ddddd0000cdddddddddd00000
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
00000000000777700000000000000000000332300000000000000000000cccc00000000000000000000404000000000010001001101d0d0d02022020220220ee
000777700007777000077770000332300003333000033230000cccc0000cc5c0000cccc004040400400444400404040011100100100d00d02022020220220eee
0007777000078780000777700003333000028f8000033330000cc5c0000c8c80000cc5c0400444400404c4c040044440000000101100d0d0200202020220ee00
00078780000777700007878000028f800002fff000028f80000c8c80000cfff0000c8c804004c4c0040444424004c4c0222200000000000002020202020ee00e
0727777000727720007777700342fff0003433400032fff00cdcfff000cdccd000ccfff044144442041444440414444222222220222222ee00000202000000ee
772222070772227000772220334444030334443000334440ccdddd0c0ccdddc000ccddd0441444440441a10004144444000022220022200011110000111ddd0e
727777020727772000727700323333020323332000323300cdcccc0d0cdcccd000cdcc004221a100044224000421a100220000022200002e111111111111dd0e
00200200000220000020020000400400000440000040040000d00d00000dd00000d00d0040040400004040000400404000222220002e02ee000000000000000e
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000700000070000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010377011d0370d0007000000700000
0000777000000000000000000000323000000000000000000000ccc000000000000000000000000000000000000000000001000d01d0001d007001d007000000
000777700000777000000000000332300000333000000000000cccc00000ccc0000000000000000000000000000000001001111d01d0111d000001d00000000d
000777700007777000000000000333300003333000000000000cc5c0000cccc0000000000004040000040400000404001101111d01d0111d100001d000000ddd
072717100027777000727770034f1f1000433230003433300cdc1c1000dcccc000cdccc0041444400004444000044440110111dd01d011dd111101d011ddddd0
772222000727777007277770334444000343323003433320ccdddd000cdcc5c00cdcccc04414444204144442041444421000110010000ddd01110001111dd00d
727727207277272027272772323343403233434043432322cdccdcd0cdccdcd0dcdcdccd44a4114444a44414441a444410110011111dd0d010111111111d0ddd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100111000000dd0110111111110dddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110101111dd0d0010100000010ddd0
000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000201101110000d0d000111111111ddd0d
0009aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022011000111d0d0e00111101111dd01d
0000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022201111111dd02e0001110111dd011d
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888888888888888888888888888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000101444400100000001044440000000000444400000000000000000000440f00800000000000000000000000000000000000000000000000000000000
1014444001011110101444401011111f014444000111f000000000000000000041110d0000000000000000000000000000000000000000000000000000000000
00011110000f1f1000011110000f1f1d1011110001f1d000000044400000000011ffd80000000000000000000000000000000000000000000000000000000000
000f1f10000ffff0000f1f10000ffff000f1f1f01ffffd0000044440000044401fff118000000000000000000000000000000000000000000000000000000000
0d1ffff000d1dd1000dffff000d1dd100dffffd0001d1d000001111000044440081dd1d400000000000000000000000000000000000000000000000000000000
dd11110d0dd1111000dd11100d111100d01111000d1111000d1f1f1000144440fdd11dd000d14440000000000000000000000000000000000000000000000000
df1dd10f0dfdddf000dfdd000f1dd100f01dd1000f1dd100dd1111000d1111100088dd000d1d1440000000000000000000000000000000000000000000000000
004004000004400000400400004004000040040000400400dfdd4d40dfdd4d4080000d404d1df44f000000000000000000000000000000000000000000000000
__gff__
0000000800010041414141000543000000000008000100414141410000430080000000080001004141414100000000000000000800000041414141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000cccd000000000000cecf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000808182838485868788898a8b8c8d8e8f000000dcdd000000000000dedf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000909192939495969798999a9b9c9d9e9f000000eced000000000000eeef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
012000001a6050060500605006050e655006050e6450e6050e635006050e625006051a6150060500605006051a6050060500605006050e655006050e645006050e635006050e625006050e615006050060500605
012000000d7500d7400d7300d7200d7100d7000d7000d7000d7500d7400d7300d7200d7100d7000d7000d7000d7500d7400d7300d7200d7100d7000d7000d7000d7500d7400d7300d7200d7100d7000d7000d700
092000001355213552135521355213552135521355213552135521355213552135521355213552135521355210552105521055210552105521055210552105521055210552105521055210552105521055210552
01200000110521305218002110520f00211052180020d052180021000218002100021b0021b0021a00210002110521305218002110520f00211052180020d0521200200002000020000200002000020000200002
012000000c0530c0030c635000030c0030c0030c635000030c0530c0030c635000030c0030c0530c635000030c0530c0030c635000030c0030c0030c635000030c0530c0030c635000030c0530c6350c0530c635
0920000020530205302053020530205302053020530205301d5301d505195001d5001d5001d5001f5001f5001d5301f5301d5001d530205001d53019500195301950019500195001f5001f5001f5001c5001c500
19200000230031f0031c0031c0031a0031a003180031700300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f0331c0331803315033
5920000010425104250c40000400104250c4000c4000040010425104250c40000400104250c4000c4000040010425104250c40000400104250c4000c4000040010425104250c40000400104250c4000c40000400
012000001005015055150500000010050130501300000000100501105000000000001005013050000000000010050150551505000000100501305013000000001005011050000001005013050100001005010000
092000001054010540105401054010540105401054010540135401354013540135401354013540135401354010540105401054010540105401054010540105400e5400e5400e5400e5400e5400e5400e5400e540
1d2000000476504765007000070000700007000070000700007000070000700007000070000700007000070004765047650070000700007000070000700007000070000700007000070000700007000070000700
092000001c0501c0501c0501c0501a0501a0501a0501a050180501805018050180501005010050100501005010653106431063310623106132300010603106001060321000210002100010600210002100021000
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
00010000110501105011040110401104011040120301203012030110301103011030120301303014020150201602017020190201b0101d01020010260102b0103101034010001000010000100001000010000100
00010000090500a0500a0500a0500b0500c0500c0500e0500f04010040120401304014040170401a0401d0302003025030290202e02032020370203a0203a0200000000000000000000000000000000000000000
010800000c6600c6600c6400c6200c6400c6400c6200c6100c6300c6300c6200c6100c6200c6200c6100c6100c60023600216001d6001b60017600116000b6000660003600006000060000600006000060000600
00080000106400000000000000000f6300000010600000000f6200000000000000000e6102060000000000000000000000106001d600000000000000000000000000000000000000000000000000000000000000
000200002c630200501d0501a050140400e0300602005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e55023550255502253021520225102451000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00010000246302563024630200501e0501c0501905015050110500c05007050020500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a0500755007550065500754008540095400a5400b5300c5300e5300f5201052012520135101451015510175101851019510195101a5101a5101a5101a5101a5101a5101a5101a5101a5100050000500
00010000237501d050217501805013050297002970000700007000070000700007002270021700007000070024700237000070000700007000070000700007000070000700007000070000700007000070000700
0001000016150220501615022050171502405019150260501a150290501c1501e1501f15020150221502315024150241502515027150291502c1502e1502e1503015031150311500000000000000000000000000
000100001011010110101200f1200e1300d1400c1500b1500a15008150071500615006150081500a1500d150141401a14020130261302f13034120001001910027100211001f1000010000100001000010000100
__music__
00 00 01 43 44
00 00 01 43 44
00 00 01 02 44
02 00 01 02 44
01 03 04 43 44
00 03 04 43 44
00 03 04 05 06
02 03 04 05 44
01 07 42 09 0a
00 07 42 09 0a
00 41 08 09 44
00 41 08 09 0a
00 07 08 09 0a
02 07 08 09 0a
04 0b 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
