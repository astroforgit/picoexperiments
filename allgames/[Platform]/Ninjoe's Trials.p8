pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- ninjoe's trials
-- by svntax

--main
--1=title
--2=gameplay
--3=game over
--4=transition
--5=win!
game_state=1
start_timer=0
dying_timer=0
prompt_outline_col=1
outline_timer=0
outline_count=0

screenshake_timer=0
small_shake_timer=0
screenshake_length=0
screenshake_size=0

disc_timer=0

ninja_discs={}
enemies={}
particles={}
items={122,75,107}
collected_items={true,true,true}
item_index=0

current_lvl=0
exit_locked=true

exit_x=0
exit_y=0
item_x=-24
item_y=-24

function _init()
 setup_asciitables()
 ninjoe=player:new(60,112)
 title_screen()
end

function title_screen()
 game_state=1
 music(6)
 collected_items={}
 current_lvl=0
 item_index=0
 outline_count=0
 prompt_outline_col=1
end

--start level transition
function start_lvl_transitionl()
 transition_timer=0
end

function load_level()
 --music
 if current_lvl<3 then
  music(6)
 elseif current_lvl==3 then
  music(18)
 elseif current_lvl<7 then
  music(29)
 elseif current_lvl==7 then
  music(18)
 end
 
 if current_lvl~=1
 and current_lvl~=2
 and current_lvl~=5 then
  item_y=400
 end

 --reset tables
 ninja_discs={}
 enemies={}
 particles={}
 
 exit_locked=true
 
 ninjoe.x=60
 ninjoe.y=112

 local offx=16*(current_lvl%8)
 local offy=16*flr(current_lvl/8)
 for i=0,15 do
  for j=0,15 do
   local tile=mget(i+offx,j+offy)
   local tx=8*i
   local ty=8*j
   --exit
   if tile==116 then
    exit_x=tx
    exit_y=ty
   elseif tile==98 then
    --blue enemy
    local be=ground_enemy:new(tx,ty)
    add(enemies,be)
   elseif tile==100 then
    --red enemy
    local re=ground_enemy:new(tx,ty)
    re.is_red_version=true
    add(enemies,re)
   elseif tile==101 then
    --boss red enemy
    local bre=ground_enemy:new(tx,ty)
    bre.is_red_boss=true
    bre.lives=24
    add(enemies,bre)
   elseif tile==104 then
    --snake enemy
    local se=ground_enemy:new(tx,ty)
    se.is_snake=true
    se.lives=2
    add(enemies,se)
   elseif tile==68 then
    --sun boss enemy
    local sbe=sun:new(tx,ty)
    add(enemies,sbe)
   elseif is_in(tile,items) then
    item_x=tx
    item_y=ty
    item_index+=1
   end
  end
 end
end

function collect_item()
 item_x=-50
 sfx(1)
 collected_items[item_index]=true
end

--duration,magnitude
function screenshake(n,m)
 is_screenshake=true
 screenshake_length=n
 screenshake_size=m
end

function stop_screenshake()
 is_screenshake=false
 small_shake_timer=0
 screenshake_timer=0
end
-->8
-- update tab
last_time=time()
curr_t=0
function _update()
 local now=time()
 dt=now-last_time
 last_time=now
 curr_t+=dt
 
 if game_state==5 then
  if btnp(4) then
   title_screen()
  end
 elseif game_state==3 then
  camera(0,0)
  --game over state
  if btnp(4) and done_dying then
   --back to title screen
   title_screen()
   done_dying=false
  end
  if not done_dying then
   dying_timer+=dt
   if dying_timer>2.5 then
    done_dying=true
    dying_timer=0
   end
  end
 elseif game_state==1 then
  for disc in all(ninja_discs) do
	  disc:update()
	 end
	 
	 disc_timer+=dt
	 if disc_timer>1.4 then
	  disc_timer=0
	  local disc=ninja_disc:new(48,77,7,0)
   add(ninja_discs,disc)
  end
  
  if btnp(4) or btnp(5) then
   --start game transition
   if not is_game_starting then
    is_game_starting=true
    music(-1)
    sfx(12)
   end
  end
  if is_game_starting then
	  start_timer+=dt
	  if start_timer>2 then
	   --finished menu->game transition
	   ninjoe=player:new(60,112)
	   start_timer=0
	   load_level()
	   game_state=2
	   is_game_starting=false
	  end
	  --outline flash effect
	  if outline_count<5 then
		  outline_timer+=dt
		  if outline_timer>0.1 then
		   outline_timer=0
		   outline_count+=1
		   if prompt_outline_col==1 then
		    prompt_outline_col=12
		   elseif prompt_outline_col==12 then
		    prompt_outline_col=1
		   end
		  end
		 end
  end
 elseif game_state~=1 then
	 ninjoe:update()
	 for disc in all(ninja_discs) do
	  disc:update()
	 end
	 
	 for e in all(enemies) do
	  e:update()
	 end
	 
	 --screenshake handling
	 if is_screenshake then
	  small_shake_timer+=dt
	  if small_shake_timer>0.02 then
	   small_shake_timer=0
	   --one shaking instance
	   local cx=rnd(screenshake_size*2)-screenshake_size
	   local cy=rnd(screenshake_size*2)-screenshake_size
	   camera(cx,cy)
	  end
	  screenshake_timer+=dt
	  if screenshake_timer>screenshake_length then
	   --end screenshake
	   screenshake_timer=0
	   is_screenshake=false
	   small_shake_timer=0
	   camera(0,0)
	  end
	 end
	 
	 --level exit logic
	 if game_state==2 then
		 if #enemies<=0 then
		  exit_locked=false
		  if coll_obj(ninjoe.x,ninjoe.y,8,8,
			 exit_x+3,exit_y+18,2,14) then
			  --touched exit
			  music(24)
			  game_state=4
			  ninjoe:set_state(state_idle)
			  start_lvl_transitionl()
			 end
		 end
	 end
 end
 if game_state==4 then
  transition_timer+=dt
  if transition_timer>3 then
   --next level
   transition_timer=0
   current_lvl+=1
   if current_lvl>=8 then
    --win! beat last level
    game_state=5
    exit_locked=true
    item_x=-50
    music(0)
   else
	   load_level()
	   game_state=2
   end
  end
 end
 
 for p in all(particles) do
  p:update()
 end
 
end
-->8
--draw tab
joe_idle={
 frames={128,129},
 duration=0.4
}

function _draw()
 cls()
 
 if game_state==1 then
  sprint("ninjoe's",4,5,7,12,1)
  sprint("trials",5,7,7,12,1)
  printo("press z/— to start",25,104,7,prompt_outline_col)
  anim(joe_idle,48,77)
  
  for disc in all(ninja_discs) do
	  disc:draw()
	 end
  return
 end
 
 if current_lvl>3
 and current_lvl<8 then
  --desert levels
  rectfill(0,0,128,128,14)
  --sun
  if current_lvl<7 then
	  local sx=21
	  local sy=17
	  if current_lvl==5 then
	   sx=69
	   sy=9
	  elseif current_lvl==6 then
	   sx=78
	   sy=11
	  end
	  spr(68,sx,sy)
	  spr(68,sx+8,sy,1,1,true)
	  spr(68,sx,sy+8,1,1,false,true)
	  spr(68,sx+8,sy+8,1,1,true,true)
  end
 end
 
 local offx=16*(current_lvl%8)
 local offy=16*flr(current_lvl/8)
 --draw solids
 --pal(6,13)
 --pal(7,6)
 map(offx,offy,0,0,16,16,1)
 pal()
 --draw bg tiles
 map(offx,offy,0,0,16,16,4)
 pal()
 if current_lvl<=3 then
  pal(6,1)
  pal(5,0)
 else
  palt(0,false)
  pal(0,5)
  pal(6,13)
 end
 map(offx,offy,0,0,16,16,2)
 pal()
 
 --exit door
 if game_state~=5 then
	 spr(116,exit_x,exit_y)
	 if current_lvl>3 then
	  rectfill(exit_x-1,exit_y+16,
	  exit_x+8,exit_y+31,1)
	 end
	 if exit_locked then
	  rectfill(exit_x+2,exit_y+16,
	  exit_x+5,exit_y+31,5)
	  spr(138,exit_x,exit_y+20)
	 end
 end
 
 --item collectible
 if item_index>0 and item_index<=#items then
  spr(items[item_index],item_x,item_y)
 end
 
 for e in all(enemies) do
  e:draw()
 end
 
 ninjoe:draw()
 for disc in all(ninja_discs) do
  disc:draw()
 end
 
 for p in all(particles) do
  p:draw()
 end
 
 --ui
 if game_state~=5 then
	 for i=1,ninjoe.lives do
	  spr(64,10+(i-1)*9,8)
	 end
 end
 
 if game_state==3 then
  sprint("game over!",3,7,7,8,2)
 elseif game_state==5 then
  draw_win(24,24,128-48,128-48,15,4)
  sprint("you win!",4,4,7,4,4)
  printo("items collected",35,51,7,1)
  printo("press z to return",32,88,7,4)
  for i=1,3 do
   if collected_items[i] then
    spr(items[i],36+i*12,66)
   else
    pal(10,1)
    pal(9,1)
    pal(7,1)
    pal(4,1)
    pal(11,1)
    pal(3,1)
    pal(13,1)
    pal(12,1)
    spr(items[i],36+i*12,66)
   end
   pal()
  end
 end
end
-->8
--misc
cos1=cos function cos(angle) return cos1(angle/(3.1415*2)) end
sin1=sin function sin(angle) return sin1(-angle/(3.1415*2)) end

--obj w/ anim data,flip,oneshot
function anim(o,x,y,fl,os)
 if(not o.timer) o.timer=0
 if(not o.frame) o.frame=1

 o.timer+=dt

 if(o.timer>=o.duration) then
   o.frame+=1
   o.timer=0
   if o.frame>#o.frames then
	   if o.oneshot then
	    o.frame=#o.frames
	   else
	    o.frame=1
	   end
   end
 end
 
 spr(o.frames[o.frame],x,y,1,1,fl)
end

function signum(n)
 return n==0 and 0 or sgn(n)
end

function is_in(val,t)
 for k,v in pairs(t) do
  if v==val then
   return true
  end
 end
 return false
end

function coll_map(o)
 --custom for this game
 local offx=16*(current_lvl%8)
 local offy=16*flr(current_lvl/8)

 local x1=o.x/8+offx
 local y1=o.y/8+offy
 local x2=(o.x+7)/8+offx
 local y2=(o.y+7)/8+offy
 local a=fget(mget(x1,y1),0)
 local b=fget(mget(x1,y2),0)
 local c=fget(mget(x2,y2),0)
 local d=fget(mget(x2,y1),0)
 return a or b or c or d
end

function coll_map_size(o)
 --custom for this game
 local offx=16*(current_lvl%8)
 local offy=16*flr(current_lvl/8)

 local x1=o.x/8+offx
 local y1=o.y/8+offy
 local x2=(o.x+o.width)/8+offx
 local y2=(o.y+o.height)/8+offy
 local a=fget(mget(x1,y1),0)
 local b=fget(mget(x1,y2),0)
 local c=fget(mget(x2,y2),0)
 local d=fget(mget(x2,y1),0)
 return a or b or c or d
end

function coll_obj(x1,y1,w1,h1,x2,y2,w2,h2)
 return x1<=x2+w2 and
 x1+w1>=x2 and
 y1<=y2+h2 and
 y1+h1>=y2
end


function draw_win(_x,_y,_w,_h,_c1,_c2)
 rectfill(_x,_y,_x+_w,_y+_h,_c1)
 rect(_x,_y,_x+_w,_y+_h,_c2)
end

particle={}
function particle:new(x,y,t)
 local o = {}
 setmetatable(o, self)
 self.__index = self
 o.x=x
 o.y=y
 o.c=7
 o.velx=0
 o.vely=0
 o.lifetime=t
 o.timer=0
 o.size_timer=0 
 return o
end

function particle:set_size(w,h)
 self.w=w
 self.h=h
end

function particle:set_vel(x,y)
 self.velx=x
 self.vely=y
end

function particle:draw()
 if self.sprite then
  spr(self.sprite,self.x,self.y)
 else
  local x1=self.x - self.w/2
  local y1=self.y - self.h/2
  if self.is_circle then
   circfill(x1,y1,self.w,self.c)
  else
  	rectfill(x1,y1,
  	x1+self.w,y1+self.h,self.c)
  end
 end
end

function particle:update()
 self.x+=self.velx
 self.y+=self.vely
 if self.gravity then
  self.vely+=self.gravity
  if self.vely>4 then self.vely=4 end
 end
 self.timer+=dt
 if self.shrinking then
  self.size_timer+=dt
  if self.size_timer>=self.lifetime/3 then
   self.size_timer=0
   if self.w>0 and self.h>0 then
    self.w-=1
    self.h-=1
   end
  end
 end
 if self.timer>=self.lifetime then
  del(particles,self)
 end
end

---------------------------
function setup_asciitables()
 chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`|€€‚ƒ„…†‡ˆ‰Š‹ŽŒŽ‘’“”•–—˜™~"
 -- '
 s2c={}
 c2s={}
 for i=1,#chars do
  c=i+31
  s=sub(chars,i,i)
  c2s[c]=s
  s2c[s]=c
 end
end
---------------------------
function asc(_chr)
 return s2c[_chr]
end
---------------------------
function chr(_ascii)
 return c2s[_ascii]
end
---------------------------
function sprint(_str,_x,_y,_c,_c2,_c3)
 local i, num
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  spr(num,(_x+i-1)*8,_y*8)
 end
 pal()
end
--------------------------
function printo(str, x, y, c0, c1)
for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, x+xx, y+yy, c1)
 end
end
print(str,x,y,c0)
end
-->8
--player

player={}
player_speed=2
player_gravity=1
player_max_y_speed=6
jump_spd=9
state_idle=1
state_run=2
state_jump=3
state_fall=4
state_stunned=5

function player:new(x,y)
 local o={}
 setmetatable(o, self)
 self.__index=self
 
 o.x=x
 o.y=y
 o.velx=0
 o.vely=0
 o.accely=-1.7
 o.facing_left=false
 o.width=8
 o.height=8
 o.state=state_idle
 o.prev_state=state_idle
 o.on_ground=true
 o.y_dir=0
 o.lives=3
 o.immune_timer=0
 o.vulnerable=true
 o.idle={
  frames={128,129},
  duration=0.4
 }
 o.run={
  frames={144,145,146,147},
  duration=0.15
 }
 o.dead={
  frames={132,133,134},
  duration=0.6,
  oneshot=true
 }
 return o
end

function player:draw()
 if game_state==5 then return end
 if game_state==3 then
  anim(self.dead,self.x,self.y,self.facing_left)
  return
 end

 if self.state==state_idle then
  anim(self.idle,self.x,self.y,self.facing_left)
 elseif self.state==state_run then
  anim(self.run,self.x,self.y,self.facing_left)
 elseif self.state==state_jump then
  local fr=131
  if self.vely>-0.2 then
   fr=128
  end
  spr(fr,self.x,self.y,1,1,self.facing_left)
 elseif self.state==state_fall then
  spr(130,self.x,self.y,1,1,self.facing_left)
 elseif self.state==state_stunned then
  spr(132,self.x,self.y,1,1,self.facing_left)
 end
end

function player:update()
 --friction
 if self.velx>0 then
  self.velx-=1
 elseif self.velx<0 then
  self.velx+=1
 end
 
 --movement input
 if btn(0) then
  if self:can_move() then
   self.velx=-player_speed
   self.facing_left=true
  end
 end
 if btn(1) then
  if self:can_move() then
   self.velx=player_speed
   self.facing_left=false
  end
 end
 if btnp(4) then
  if self:can_jump() then
   --jump code
   self.vely=-jump_spd
   self:set_state(state_jump)
  end
 end
 --throw disc
 self.y_dir=0
 if btn(2) then
  self.y_dir-=1 --look up
 end
 if btn(3) then
  self.y_dir+=1 --look down
 end
 if btnp(5) and self:can_move() then
  self:throw_disc(self.facing_left,self.y_dir)
 end
 
 --player physics
 
 --floaty jump
 if not self.on_ground and self.vely<-2 then
  self.vely+=player_gravity
 elseif not self.on_ground and abs(self.vely)<=2 then
  self.vely+=player_gravity*0.7
 else
  self.vely+=player_gravity*0.4
 end
 
 local min_y_spd=self.state==state_jump and -jump_spd or -6
 self.vely=max(self.vely,min_y_spd)
 self.vely=min(self.vely,player_max_y_speed)
 
 local nextx=self.x+self.velx
 local nexty=self.y+self.vely
 
 if not coll_map({x=nextx,y=self.y})
 and nextx>0 and nextx<127 then
  self.x=nextx
 end
 local amnt=abs(nexty-self.y)
 for i=1,amnt-1 do
  local nextyy=self.y+signum(self.vely)
  if not coll_map({x=self.x,y=nextyy}) then
   self.y=nextyy
  end
 end
 
 --check ground
 if coll_map({x=self.x,y=nexty+1}) then
  self.vely=0
  self.on_ground=true
  if self.state==state_jump
  or self.state==state_fall then
   self:set_state(state_idle)
  elseif self.state==state_run
  and self.velx==0 then
   self:set_state(state_idle)
  elseif self.state==state_idle
  and self.velx~=0 then
   self:set_state(state_run)
  end
 else
  --if previously on ground
  if self.vely>2 and
  (self.state==state_idle
  or self.state==state_run
  or self.state==state_jump) then
   self:set_state(state_fall)
  end
  self.on_ground=false
 end
 
 --enemy collision
 if self.vulnerable then
	 for e in all(enemies) do
	  local ex=e.x
	  local ey=e.y
	  local ew=e.width
	  local eh=e.height
	  if e.is_red_boss then
	   ey-=40
	   ew=48
	   eh=48
	  elseif e.is_red_minion then
    ey-=16
    ew=24
    eh=24
   end
	  if coll_obj(self.x+2,self.y+2,5,5,
	  ex,ey,ew,eh) then
	   if self.lives>1 then
	    self:hit()
	    --knockback
	    if e.x<self.x then
	     self.velx=4
	    else
	     self.velx=-4
	    end
	    self:set_state(state_stunned)
	   else
	    --game over
	    if game_state~=3 then
	     self:hit()
	     stop_screenshake()
	     game_state=3
	     music(23)
	    end
	   end
	   self.vulnerable=false
	  end
	 end
 else
  self.immune_timer+=dt
  if self.immune_timer>0.2 then
   if self.state==state_stunned then
    self:set_state(state_idle)
   end
  end
  if self.immune_timer>1 then
   self.immune_timer=0
   self.vulnerable=true
  end
 end
 
 --collectibles collision
 if coll_obj(self.x,self.y,8,8,
	item_x,item_y,8,8) then
  collect_item()
 end
 
 --hacky game win state
 if game_state==5 then
  self.x=-50
  self.y=-50
 end
end

function player:hit()
 self.lives-=1
 sfx(11)
 if not is_screenshake then
  screenshake(0.4,2)
 end
end

function player:throw_disc(xdir,ydir)
 if #ninja_discs>=3 then return end
 local dx=0
 local dy=ydir*disc_spd
 if xdir then
  --facing left
  dx=-disc_spd
 else
  --facing right
  dx=disc_spd
 end
 local disc=ninja_disc:new(self.x,self.y,dx,dy)
 add(ninja_discs,disc)
 sfx(8,-1,0,3)
end

function player:can_jump()
 if game_state>=3 then return false end
 local s=self.state
 return s==state_idle
 or s==state_run
end

function player:can_move()
 if game_state>=3 then return false end
 return self.state~=state_stunned
end

function player:set_state(new_state)
 self.prev_state=self.state
 self.state=new_state
 
 --reset frames when exit state
 if self.prev_state==state_idle then
  self.idle.frame=1
 elseif self.prev_state==state_run then
  self.run.frame=1
 end
 
end

ninja_disc={}
disc_friction=0.1
disc_spd=7
disc_cols={10,6,12,7}
function ninja_disc:new(x,y,vx,vy)
 local o={}
 setmetatable(o, self)
 self.__index=self
 
 o.x=x
 o.y=y
 o.velx=vx
 o.vely=vy
 o.width=8
 o.height=8
 o.timer=0
 o.col_index=0
 o.col_timer=0
 
 return o
end

function ninja_disc:draw()
 pal(1,disc_cols[self.col_index])
 spr(153,self.x,self.y)
 pal()
end

function ninja_disc:update()
 self.col_timer+=dt
 if self.col_timer>0.06 then
  self.col_timer=0
  self.col_index+=1
  if self.col_index>3 then
   self.col_index=1
  end
 end

 self.timer+=dt
 if self.timer>2 then
  del(ninja_discs,self)
 end
 
 --movement
 local nextx=self.x+self.velx
 local nexty=self.y+self.vely
 local amnt=abs(nextx-self.x)
 for i=1,amnt-1 do
  local nextxx=self.x+signum(self.velx)
  if not coll_map({x=nextxx,y=self.y}) then
   self.x=nextxx
  elseif game_state==1 then
   self.x=nextxx
  else
   sfx(3,-1,13)
   self.velx*=-1
  end
 end
 amnt=abs(nexty-self.y)
 for i=1,amnt-1 do
  local nextyy=self.y+signum(self.vely)
  if not coll_map({x=self.x,y=nextyy}) then
   self.y=nextyy
  else
   sfx(3,-1,13)
   self.vely*=-1
  end
 end
 
 --enemy collision
 for e in all(enemies) do
  local ex=e.x
  local ey=e.y
  local ew=e.width
  local eh=e.height
  if e.is_red_boss then
   ey-=40
   ew=48
   eh=48
  elseif e.is_red_minion then
   ey-=16
   ew=24
   eh=24
  end
  if coll_obj(self.x,self.y,8,8,
  ex,ey,ew,eh) then
   if e.is_red_boss
   or e.is_red_minion then
    e:damage(self.x+3,self.y+3)
   elseif e.is_rock then
    sfx(16,-1,0,2)
    del(enemies,e)
   elseif e.is_fire then
    sfx(16,-1,0,2)
   else
    e:damage()
   end
   del(ninja_discs,self)
  end
 end
 
 --friction
 if self.velx>0 then
  self.velx-=disc_friction
 else
  self.velx+=disc_friction
 end
 if self.vely>0 then
  self.vely-=disc_friction
 else
  self.vely+=disc_friction
 end
end
-->8
--enemies
dmg_cols_red={2,8,9}
dmg_cols_blue={1,2,12}
fire_cols={8,10,7}

ground_enemy={}
function ground_enemy:new(x,y)
 local o={}
 setmetatable(o, self)
 self.__index=self
 
 o.x=x
 o.y=y
 o.velx=0.5
 o.vely=0
 o.width=8
 o.height=8
 o.immune_timer=0
 o.spit_timer=0
 o.idle={
  frames={98,99},
  duration=0.6
 }
 o.red_idle={
  frames={100,101},
  duration=0.2
 }
 o.snake_walk={
  frames={104,105},
  duration=0.2
 }
 o.big_spr_frame=1
 o.big_frame_timer=0
 return o
end

function ground_enemy:draw()
 if self.is_red_version then
  anim(self.red_idle,self.x,self.y)
 elseif self.is_snake then
  anim(self.snake_walk,self.x,self.y,self.velx<0)
 elseif self.is_red_boss
 or self.is_red_minion then
  --custom anim handling for
  --red boss and minions
  if self.big_spr_frame==1 then
   if self.is_red_boss then
    sspr(32,48,8,8,self.x,self.y-40,48,48)
   elseif self.is_red_minion then
    sspr(32,48,8,8,self.x,self.y-16,24,24)
   end
  else
   if self.is_red_boss then
    sspr(40,48,8,8,self.x,self.y-40,48,48)
   elseif self.is_red_minion then
    sspr(40,48,8,8,self.x,self.y-16,24,24)
   end
  end
  --update frame for scaled spr
  self.big_frame_timer+=dt
  if self.big_frame_timer>0.2 then
   self.big_frame_timer=0
   self.big_spr_frame+=1
   if self.big_spr_frame>2 then
    self.big_spr_frame=1
   end
  end
 else
  anim(self.idle,self.x,self.y)
 end
end

function ground_enemy:update()
 if not self.vulnerable then
  self.immune_timer+=dt
  if self.immune_timer>0.2 then
   self.vulnerable=true
   self.immune_timer=0
  end
 end

 if self.is_red_version
 or self.is_snake then
  local nextx=self.x+self.velx
  if (not coll_map({x=nextx,y=self.y}))
  and coll_map({x=nextx+8*signum(self.velx),y=self.y+1}) then
	  self.x=nextx
	 else
	  self.velx*=-1
	 end
	 --snake spit
	 if self.is_snake then
	  self.spit_timer+=dt
	  if self.spit_timer>1.5 then
	   self.spit_timer=0
	   self:spit_rock()
	  end
	 end
	 --if y movement enabled
	 if self.can_fall then
	  --physics
	  local nexty=self.y+self.vely
	  local amnt=abs(nexty-self.y)
		 for i=1,amnt-1 do
		  local nextyy=self.y+signum(self.vely)
		  if not coll_map({x=self.x,y=nextyy}) then
		   self.y=nextyy
		  end
		 end
		 --gravity
		 self.vely+=1
		 if self.vely>4 then
		  self.vely=4
		 end
	 end
 elseif self.is_red_boss then
  local nextx=self.x+self.velx
  --hard-coded b/c boss will
  --always be in these spots
  if nextx>=24 and nextx<=56 then
	  self.x=nextx
	 else
	  self.velx*=-1
	 end
 elseif self.is_red_minion then
  local nextx=self.x+self.velx
  --hard-coded for minions too
  if nextx>=24 and nextx<=80 then
   self.x=nextx
  else
   self.velx*=-1
  end
 end
end

function ground_enemy:damage(bx,by)
 if not self.vulnerable then return end
 
 sfx(15)
 screenshake(0.15,1)
 if self.is_red_boss then
  if self.lives>0 then
   self.lives-=1
   spawn_blood(4,bx or self.x,by or self.y)
  else
   --spawn mid-sized minions
   spawn_blood(25,self.x+24,self.y-24)
   local e1=ground_enemy:new(self.x,self.y)
   e1.is_red_minion=true
   e1.velx=0.5
   e1.lives=12
   add(enemies,e1)
   local e2=ground_enemy:new(self.x+23,self.y)
   e2.is_red_minion=true
   e2.velx=-0.5
   e2.lives=12
   add(enemies,e2)
   del(enemies,self)
  end
 elseif self.is_red_minion then
  if self.lives>0 then
   self.lives-=1
   spawn_blood(4,bx or self.x,by or self.y)
  else
   --spawn normal red enemies
   spawn_blood(20,self.x,self.y)
   local e1=ground_enemy:new(self.x,self.y)
   e1.is_red_version=true
   e1.velx=1
   add(enemies,e1)
   local e2=ground_enemy:new(self.x+15,self.y)
   e2.is_red_version=true
   e2.velx=1
   add(enemies,e2)
   local e3=ground_enemy:new(self.x+7,self.y)
   e3.is_red_version=true
   e3.velx=-1
   add(enemies,e3)
   del(enemies,self)
  end
 else
  if self.lives and self.lives>0 then
   self.lives-=1
   spawn_blood(4,bx or self.x,by or self.y)
  else
	  spawn_blood(15,self.x,self.y)
	  del(enemies,self)
	 end
 end
end

function ground_enemy:spit_rock()
 local r=rock:new(self.x,self.y)
 if self.velx>0 then
  r.velx=4
 elseif self.velx<0 then
  r.velx=-4
 end
 rock.is_fire=false
 add(enemies,r)
end

function spawn_blood(n,x,y)
 for i=1,n do
  local pt=rnd(1)+.2
  local size=flr(rnd(2))
  local vx=rnd(4)-2
  local vy=-rnd(3)
  local px=x+4+flr(rnd(4))-2
  local py=y-flr(rnd(2))
  local p=particle:new(px,py,pt)
  local col=dmg_cols_red[flr(rnd(#dmg_cols_blue)+1)]
  p:set_size(size,size)
  p:set_vel(vx,vy)
  p.gravity=0.4
  p.is_circle=true
  p.c=col
  add(particles,p)
 end
end

rock={}
function rock:new(x,y,dx,dy)
 local o={}
 setmetatable(o, self)
 self.__index=self
 
 o.x=x
 o.y=y
 o.velx=dx or 0
 o.vely=dy or 0
 o.width=6
 o.height=6
 o.is_rock=true
 o.is_fire=true
 o.fire_timer=0
 o.fire_effect_timer=0
 return o
end

function rock:draw()
 if not self.is_rock then
  pal(9,8)
  spr(106,self.x,self.y)
  pal()
 else
  --spr(85,self.x,self.y)
  sspr(40,40,8,8,self.x,self.y,5,5)
 end
end

function rock:update()
 self.x+=self.velx
 if self.is_rock then
  --rock projectile logic
	 self.y+=self.vely
	 --solids collision
	 if coll_map(self) then
	  del(enemies,self)
	 end
 elseif self.is_fire then
  --fire object logic
  --lifetime
  self.fire_timer+=dt
  if self.fire_timer>1.5 then
   self.fire_timer=0
   del(enemies,self)
  end
  
  --particles
  self.fire_effect_timer+=dt
  if self.fire_effect_timer>0.1 then
   self.fire_effect_timer=0
   local px=self.x+rnd(8)
   local ps=flr(rnd(2))
   local pc=flr(rnd(3))+1
   local pt=rnd(1)+.5
   local p=particle:new(px,self.y,pt)
   p.shrinking=true
   p.is_circle=true
   p:set_size(ps,ps)
   p.vely=-.5
   p.c=fire_cols[pc]
   add(particles,p)
  end
  
  --physics
  local nexty=self.y+self.vely
  local amnt=abs(nexty-self.y)
	 for i=1,amnt-1 do
	  local nextyy=self.y+signum(self.vely)
	  if not coll_map({x=self.x,y=nextyy}) then
	   self.y=nextyy
	  end
	 end
	 --gravity
	 self.vely+=1
	 if self.vely>4 then
	  self.vely=4
	 end
 end
end
-->8
--bosses

sun={}
function sun:new(x,y)
 local o={}
 setmetatable(o, self)
 self.__index=self
 
 o.x=x
 o.y=y
 o.spawnx=x
 o.spawny=y
 o.offx=0
 o.offy=0
 o.velx=1
 o.width=16
 o.height=16
 o.is_sun_boss=true
 o.lives=39
 o.shoot_timer=0
 return o
end

function sun:draw()
	circfill(self.offx+self.x+8,self.y+8,9,2)
	circfill(self.x+7,self.offy+self.y+8,9,2)
 circfill(self.offx+self.x+8,self.offy+self.y+8,9,8)
 spr(68,self.x,self.y)
	spr(68,self.x+8,self.y,1,1,true)
	spr(68,self.x,self.y+8,1,1,false,true)
	spr(68,self.x+8,self.y+8,1,1,true,true)
end

function sun:update()
 --sine wave path
 self.x=self.spawnx+37*cos(2*time())
 self.y=self.spawny+18*cos(6*time())
 self.offx=1*cos(8*time())
 self.offy=1*cos(7*time())
 
 --shoot
 self.shoot_timer+=dt
 if self.shoot_timer>0.8 then
  --drop fire and snakes
  local choice=rnd(1)
	 if choice<0.8 then
	  --fire
	  local f=rock:new(self.x+4,self.y+4,0,0)
	  f.is_fire=true
	  f.is_rock=false
	  add(enemies,f)
	 else
	  --snake
	  local se=ground_enemy:new(self.x+4,self.y+4)
   se.is_snake=true
   se.lives=2
   se.can_fall=true
   add(enemies,se)
	 end
  self.shoot_timer=0
 end
end

function sun:damage(bx,by)
 sfx(15)
 screenshake(0.15,1)
 if self.lives>0 then
  self.lives-=1
  spawn_blood(8,bx or self.x,by or self.y)
 else
  spawn_blood(20,self.x,self.y)
	 del(enemies,self)
 end
end
__gfx__
00012000606660666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0666066606660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652206660666066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70660666066606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc07656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900090040405565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90090004005767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000702826007282060
a979979400e88000d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500602825006282050
a71991740e111800d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
2002821000028210202000000006822d02822222020220d000000000000000000000000000000000007665000076650005555555555555555555555055677655
0211111122111111022282100026cdcd1111110002200d0000000000000000000000000000000000075006500750065055666666666666666666665556555565
11ddcdcd01ddcdcd001111110216ddddddcdcddd21ddd00002000000000000000000000000000000065006500650000056676767676767676767766556677665
006ddddd106ddddd66ddcdcd0016dddd66666d0081cddd0022ddd000000000000000000000000000766666657666666556777777777777777777776556677665
006d5ddd006d5ddd600ddddd0015ddd066dddd001ddddd008dddd000002282000202820002222200766166657663666556777676767676767676776555677655
0065111d0065111d0005ddd00052111056d111111c66d1111dddd1000221166600211110002282dd766166657663666556766676666666666767766556555565
00520010005200100552211100520010052200000d6661001d66611100666c10011dddd000111110766666657666666556776756666666667577666556677665
0502001005020010500200100502001000502000000552221d666222666dddc066666666666dddd0655555556555555556766665555555555667766556677665
0028210020000000002821002200000002228200005000000000000000000000c0c6cc0000777700056650000000000056677665555575555566765555555555
02111110222821000211111002282100221116660205002002022210202221000cccccc0071111605600650007a00a7056776665565755665555555556677665
d21ddcd60111111021ddcdcd0111111000666c10022560220022822102282210cdd7d7d071111115607006000a9009a056677665565757676565565655555555
d1dd66660ddddcd0666ddddd0dddcdc0066dddcd101d5682011111111111111006ddddd071100115600006000000000056776665575757777576755757777775
00d66d00066dddd06066dd00066dddd05555dd0011ddd62206ddcdcd0ddcdcd00d665ddd71100115560065000000000056677665575756766557675675555557
202211000066dd00001221000066dd00021dd00000dd661260d5dddd6d5dddd000c5ccc071111115056694500a90000056776665565756666565565655677655
02000010002212000110020000221100200100000dd6dc116552ddd16522dd11005c00c0061111500000094507a0000056677665565755665555555556776665
0000000100012000000000200002100000100000d000c1105220011152220001050c00c000555500000000940000000056776665555575555567665556677665
0028226000000000628210000022000022000000222200001112000006822d0026822d0077777777002820000077770056776675555755555677666556776665
002222600028220026111100081d0000820d0000228110001112800026cdcd0016cdcd0000000000028e8200076566d056676756665575656577666556677665
061221600022222006dcdc00621d0000612d000011dcd00011dc600016dddd0006dddd000600600608e7e8007665666d56777667676575657667766555776655
06d11dd0061221160ddddd00611c0200611c0200d66665d5dddd656506dddd0006dddd000000000008eee8007665556d56677777777575757777766575555557
0dd1d1d00dd11ddd05dddd006cdd52016cdd5201dddd0d00ddd6060005ddd00005ddd00000500500028e82007666666d56667676767575756767666557777775
005111000dd1d1dd522dd0d0d66d5211d6665211211100001112000005221110052211100000000000282000076666d056666666666575656666666555555555
0015000000551110220100000d6652100dd6521020001000100020005002000150020001010100100028200000dddd0055666666665575656666665556677665
00105000001051000110000000dd510000dd51002000010010000200500000005000000000000000002820000000000005555555555755555555555055555555
062281100000000000400000202821000028210000282100000000000000000000000000000000007777777711111100566666660015d0005666666500000000
6d6dcdc00000122240900040111111102111111021111110030100000606330000003300000000007555555717777610655115510015d0006666666600000000
506dddd0000dd18090a040900ddbdbd00ddbdbd01ddbdbd003013300663138300031383000077000756556571777610065155551001d50006000000601111110
506dddd0000ddd11a00090a40666dddd1666dddd0666dddd00313830633313300633133000766700755555571776610051155551000d15006000000605555550
5006ddd000ddddd10405a00900d5dd0000d5dd0000d5dd00003313303331301363313013005665007555555717667610655115110001d5006000000605555550
00021111002d6dd00905004a005111000052110000521100033130131110000011100000000550007565565716116761655551510001d0006000000605155150
000200010222166d0a5000900520001005002000052201001110000010000000100000000000000075555557010016716555515100105d006000000605111150
0002000020011006dd1110a05020000050010000500001001000000000000000000000000000000077777777000001105111111500150d000000000005111150
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
__gff__
000202000080000000000000000001010000000000000000000000000000020000040000000000000000000000000000000000000000000400000001010101010000000000000c000004040000000000000000000000000004000000020000000000000000000000000000000000000000000001000000010101000001000000
0000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3e3b3b3b3b3b3b3b3b3b3b3b3b3b3b3e3e3b3b3b3b3b3b3b3b3b3b3b3b3b3b3e3e3b3b3b3b3b3b3b3b3b3b3b3b3b3b3e3e3b3b3b3b3b3b3b3b3b3b3b3b3b3b3e3e00000000000000000000000000003e3e00000000000000000000000000003e3e00000000000000000000000000003e3e00000000000000000000000074003e
3f01010101010101010101017402013f3f01010101010101010101010102013f3f01010102010101010101010102013f3f01010102010101010101010174023f3f00000000000000000000007400003f3f00740000000000000000000000003f3f00740000000000000000000068003f3f00003c00003c00003c00007778793f
3f01020201010101010101777879013f3f01017402010101010101010101013f3f01010101010101016401010101013f3f01010201010101020201017778793f3f00000000000000000000777879003f3f77787900000000000000000000003f3f77787900000000000000003c3c003f3f00000000000000000000005800583f
3f01010101010101010101580058013f3f01777879010101010101010101013f3f0101013f3f3f3f3f3e3f3f3d01013f3f01010202010101010202015800583f3f00000000000000000000580058003f3f58005800000000000000000000003f3f58005800000000000068000001003f3f62000000000000000000005800583f
3f01010164010101010101580058013f3f01580058010101010101010101013f3f0101013d010101013f01010101013f3f3c010102013c01010102015800583f3f00000000000000000000580058003f3f58005800006800006800000000003f3f58005800000000003c3c000001003f3f3c000000000000000000003d3d3d3f
3f0102013c3c010102023d3c3c3c3d3f3f01580058010201020201010101013f3f0101013d620101023f01010164013f3f010101010101010201013f3d3d3d3f3f0000000000003f3f00003d3d3d003f3f3d3d3d3f3f3f3f3f3f3f3f3f00003f3f3d3d3d00000068000001000001683f3f00000000000000000000000000003f
3f01010101010101010101010101013f3f3d3c3c3c3d3d01010101013d3d3d3f3f3d02013f3f3f01013f01013d3f3f3f3f01010102020101010101010101013f3f003f3f3f000000000000010101003f3f01020202000000000000000000003f3f00000000003c3c00000100003c3c3f3f62000000000000000000000000003f
3f01010101010101010101010102013f3f01010101010101010101010102013f3f01020101010101013f01010102013f3f3c020101010101010101010102013f3f00010101000000000000010101003f3f02010101006800000068000000683f3f00000068000001000001680001003f3f3c000000000044000000000000003f
3f3c3c0101010101010101020262013f3c01620101620101010101026402013f3f64020101010201013f0102024b013f3f01020101010201010101020201013f3f00010101000000000000016801003f3f02023f3f3f3f3f3f3f3f3f3f3f3f3f3f0000003c3c000100003c3c0001003f3f00000000000000000000000000003f
3f0101010201010101010101013d013f3f3f3f3f3f3f0101010101013d3d3d3f3c3f3f3f3f3c0101023c01013d3d3d3f3f02010101010101020101010101013f3f003f3f3f0000000000003f3f3f003f3f02020101000000000000000000003f3f00620001000001680001000001683f3f62000000000000000000000000003f
3f01010102013c3c01010101013d013f3f01010101010101010101010101013f3f010101013f0101013f01010101013f3f3c010102020201010101010101013f3f00000000000000000000000000003f3f01010168000000680000000000003f3f003c000100003c3c000100003c3c3f3f3c000000000000000000000000003f
3f01010101013c3c0101013c3f3f3f3c3c017a0101620101010101016401013f3f010162013f0101013f01020174023f3f01010102650201010101020101023f3f00000000000000680000000000003f3f3f3f3f3f3f3f3f3f3f3f000000003f3f00376801000001000001682137003f3f00000000000000000000000000003f
3f01620101010101010101010101013f3f3f3f3f3f3f0101010101013d3d3d3f3f01013f3f3c3f01023c01027778793f3f02013f3f3f3f3f3f3f3f3f3f01013f3f00002100003c3b3b3c00000000003f3f00210000000202010100000021003f3f00373c3c00000100003c3c2137003f3f00000000003700003700000000003f
3f3d3d3d01010101010101010101013f3f01010101010101010101010101013f3f01010101010101023f01025800583f3f01020101010101020101020101013f3f00002100003702023700000021003f3f6b216800000102020100000021623f3f21370001000001000001002137003f3f3c000000003702023700000000003f
3f3d3d3d01010101010101010162013f3f01620101620101010101010101013f3f01010101010101013f01025800583f3f01010101010101010101020101013f3f00002100003702023700210021003f3f0e0e0e0e3f01010101000000213c3f3f21370001000001000001002137003f3f00000000003702023700000000003f
3e3f3f3f3f3f3c3d3d3c3f3f3f3f3f3e3e3f3f3f3f3f3c3d3d3c3f3f3f3f3f3e3e3f3f3f3f3f3c3d3d3c3f3d3c3c3c3e3e3f3f3f3f3f3c3d3d3c3f3f3f3f3f3e3e0e0e0e0e0e3c3d3d3c0e0e0e0e0e3e3e0e0e0e0e3f3c3d3d3c0e0e0e0e0e3e3e0e0e0e0e3f3c3d3d3c0e0e0e0e0e3e3e0e0e0e0e0e3c3d3d3c0e0e0e0e0e3e
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
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000300002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c620385503455031550305502e5502d5501d6201d6201d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028620286201e6401a640186401663014630106300f6300c620096200662005620026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
000c00201125411255052550000000000112541125505255000000000011254112550525500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000705005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000205004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000005002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
001400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
000200002067021670316602f65031650336503365033650386503f6503f650326502f6502f650006002f6502e6502d650006002b650296502760024650216001e65019600116500a60000630066000161000010
010200000e6510c6530a6520b653056530000000000000000e6510c6530a652000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
001000000062200622006220062202622026220262202622006220062200622006220262202622026220262200622006220062200622026220262202622026220062200622006220062202622026220262202622
__music__
00 16 17 43 44
00 16 17 43 44
01 16 17 43 44
00 16 17 43 44
00 18 19 43 44
02 18 19 43 44
00 1a 42 43 44
01 1a 1b 43 44
00 1a 1b 43 44
00 1a 1c 43 44
00 1a 1c 43 44
02 1d 1e 43 44
01 1f 20 43 44
00 1f 21 43 44
00 1f 20 43 44
00 1f 21 43 44
00 22 23 43 44
02 1f 24 43 44
01 25 26 43 44
00 25 26 43 44
02 27 28 43 44
00 29 2a 43 44
03 2b 2c 43 44
04 2d 2e 43 44
04 2f 30 43 44
01 31 32 43 44
00 31 32 43 44
00 33 34 43 44
02 35 36 43 44
01 37 38 43 44
00 39 3a 43 44
00 37 3b 43 44
02 39 3b 43 44
03 3e 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
